local EventUtil = require("BaseUtilities.EventUtil")
local UIConst = require("UI.UIConst")
local CSConst = require("CSCommon.CSConst")
local ChatData = class("DynamicData.ChatData")

EventUtil.GeneratorEventFuncs(ChatData, "NewChatMsgEvent")
EventUtil.GeneratorEventFuncs(ChatData, "UpdateUnreadIndexEvent")

local kEmoticonCount = 49

function ChatData:DoInit()
    self.chat_record_with_type = {}
    self.unread_index_with_type = {}
    self.chat_msg_max_cache_count = SpecMgrs.data_mgr:GetParamData("chat_msg_max_cache_count").f_value
    for _, chat_type in pairs(CSConst.ChatType) do
        self.unread_index_with_type[chat_type] = 0
    end
    -- 超链接处理方法 hyper_type => handle_func
    self.hyper_link_handle_func_dict = {
        [CSConst.HyperLinkType.BattleReport] = function(param_tb)
            self:HandleBattleReport(param_tb)
        end,
    }
end

function ChatData:HandleBattleReport(param_tb)
    SpecMgrs.ui_mgr:ShowUI("BattleDetailUI", param_tb[1], param_tb[2], param_tb[3], param_tb[4])
end

function ChatData:NotifyNewChat(msg)
    if not self.chat_record_with_type[msg.chat_type] then
        self.chat_record_with_type[msg.chat_type] = Queue.New()
    end
    local cur_msg_count = self.chat_record_with_type[msg.chat_type]:Count()
    if cur_msg_count == self.chat_msg_max_cache_count then
        self.chat_record_with_type[msg.chat_type]:Dequeue()
    end
    self.chat_record_with_type[msg.chat_type]:Enqueue(msg)
    self.unread_index_with_type[msg.chat_type] = math.clamp(self.unread_index_with_type[msg.chat_type] + 1, 0, self.chat_msg_max_cache_count)
    if msg.chat_type ~= CSConst.ChatType.System then
        self:DispatchUpdateUnreadIndexEvent(msg.chat_type, true)
    end
    self:DispatchNewChatMsgEvent(msg)
end

function ChatData:GetChatMsgByChannel(chat_type)
    return self.chat_record_with_type[chat_type]
end

function ChatData:GetUnreadFlagWithType(chat_type)
    return self.unread_index_with_type[chat_type] > 0
end

function ChatData:GetChatMsgCountByType(chat_type)
    return self.chat_record_with_type[chat_type] and self.chat_record_with_type[chat_type]:Count() or 0
end

function ChatData:SetUnreadIndexWithType(chat_type)
    if not self.chat_record_with_type[chat_type] then return end
    self.unread_index_with_type[chat_type] = 0
    self:DispatchUpdateUnreadIndexEvent(chat_type, false)
end

function ChatData:AnalysisHyperlinkData(href_key)
    local href_data = json.decode(href_key)
    local param_tb = href_data.param_tb
    local handle_func = self.hyper_link_handle_func_dict[href_data.link_type]
    if handle_func then handle_func(param_tb) end
end

-- channel, link_type, param_tb, content, color
function ChatData:SendChatMsgWithHyperlink(param)
    if ComMgrs.dy_data_mgr.func_unlock_data:CheckFuncIslock(CSConst.FuncUnlockId.Chat, true) then
        return false
    end
    if param.channel and param.channel == CSConst.ChatType.Dynasty then
        if not ComMgrs.dy_data_mgr.dynasty_data:GetDynastyId() then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.JOIN_DYNASTY_LIMIT)
            return false
        end
    end
    local chat_content = string.render(UIConst.Text.CHAT_HYPER_LINK_MATCH, {
        href = json.encode({link_type = param.link_type, param_tb = param.param_tb}),
        color = param.color or UIConst.Color.Blue1,
        content = param.content or UIConst.Text.HYPERLINK_DEFAULT_NAME,
    })
    self:SendChatMsg(param.channel or CSConst.ChatType.World, chat_content)
    return true
end

function ChatData:SendChatMsg(channel, msg_text, role_info)
    local role_name = role_info and role_info.name
    local role_uuid = role_info and role_info.uuid
    if channel == CSConst.ChatType.Private and not role_info then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.NO_PRIVATE_CHAT_PLAYER)
        return
    end
    if not msg_text or msg_text == "" then return end
    -- 表情图标 ("#001")
    for word in string.gmatch(msg_text, "#%d%d%d") do
        local emoticon_no, _ = string.gsub(word, "#", "")
        local emoticon_index = tonumber(emoticon_no)
        if emoticon_index and emoticon_index < kEmoticonCount then
            msg_text = string.gsub(msg_text, word, string.format(UIConst.EmoticonFormat, emoticon_no, 52))
        end
    end
    SpecMgrs.msg_mgr:SendChatMsg({chat_type = channel, content = FilterBadWord(msg_text), private_uuid = role_uuid, private_name = role_name}, function (resp)
        if resp.errcode ~= 0 then
            local err_tip = UIConst.ChatErrorTips[resp.tips_id]
            if err_tip then
                SpecMgrs.ui_mgr:ShowTipMsg(err_tip)
            else
                SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.SEND_CHAT_MSG_FAILED)
            end
        end
    end)
end

return ChatData