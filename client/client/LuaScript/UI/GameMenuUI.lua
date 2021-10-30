local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local GameMenuUI = class("UI.GameMenuUI", UIBase)
local kNoticeScrollSpeed = 80
local kChatMsgScrollTime = 0.5

function GameMenuUI:DoInit()
    GameMenuUI.super.DoInit(self)
    self.prefab_path = "UI/Common/GameMenuUI"
    self.dy_chat_data = ComMgrs.dy_data_mgr.chat_data
    self.dy_hero_data = ComMgrs.dy_data_mgr.night_club_data
    self.sys_notice_queue = Queue.New()
    self.chat_msg_queue = Queue.New()
    self.chat_msg_interval = SpecMgrs.data_mgr:GetParamData("chat_msg_interval").f_value
    self.text_width = 0
    self.temp_emoticon_list = {}
    self.cur_emoticon_list = {}
end

function GameMenuUI:OnGoLoadedOk(res_go)
    GameMenuUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function GameMenuUI:Show(is_hide_chat)
    self.is_hide_chat = is_hide_chat
    if self.is_res_ok then
        self:InitUI()
    end
    GameMenuUI.super.Show(self)
end

function GameMenuUI:Hide()
    self.is_hide_chat = nil
    -- ComMgrs.dy_data_mgr:UnregisterUpdateRoleInfoEvent("GameMenuUI")
    self.dy_chat_data:UnregisterNewChatMsgEvent("GameMenuUI")
    self.dy_chat_data:UnregisterUpdateUnreadIndexEvent("GameMenuUI")
    GameMenuUI.super.Hide(self)
end

function GameMenuUI:InitRes()
    -- 系统公告
    self.msg_container = self.main_panel:FindChild("SysNotice")
    self.container_width = self.msg_container:GetComponent("RectTransform").rect.width
    self.sys_notice = self.msg_container:FindChild("NoticeText")

    -- 游戏菜单
    self.game_menu_panel = self.main_panel:FindChild("GameMenuPanel")
    local line_up_panel = self.game_menu_panel:FindChild("LineUp")
    line_up_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.LINEUP
    self:AddClick(line_up_panel:FindChild("Btn"), function ()
        local lineup_ui = SpecMgrs.ui_mgr:GetUI("LineupUI")
        if lineup_ui and lineup_ui.is_showing then return end
        SpecMgrs.ui_mgr:ShowUI("LineupUI")
    end)
    local bag_panel = self.game_menu_panel:FindChild("WareHouse")
    bag_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.WAREHOUSE_TEXT
    self:AddClick(bag_panel:FindChild("Btn"), function ()
        local bag_ui = SpecMgrs.ui_mgr:GetUI("BagUI")
        if bag_ui and bag_ui.is_showing then return end
        SpecMgrs.ui_mgr:ShowUI("BagUI")
    end)
    local daily_target_panel = self.game_menu_panel:FindChild("DailyTarget")
    daily_target_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DAILY_TARGET_TEXT
    self:AddClick(daily_target_panel:FindChild("Btn"), function ()
        local daily_active_ui = SpecMgrs.ui_mgr:GetUI("DailyActiveUI")
        if daily_active_ui and daily_active_ui.is_showing then return end
        SpecMgrs.ui_mgr:ShowUI("DailyActiveUI")
    end)
    local achievement_panel = self.game_menu_panel:FindChild("Achievement")
    achievement_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ACHIEVEMENT_TEXT
    self:AddClick(achievement_panel:FindChild("Btn"), function ()
        SpecMgrs.ui_mgr:ShowUI("AchievementUI")
    end)
    self.welfare_panel = self.game_menu_panel:FindChild("Welfare")
    self.welfare_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.WELFARE_TEXT
    self:AddClick(self.welfare_panel:FindChild("Btn"), function ()
        SpecMgrs.ui_mgr:ShowUI("WelfareUI")
    end)
    local shop_panel = self.game_menu_panel:FindChild("Shop")
    shop_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SHOPPING_MARKET_TEXT
    self:AddClick(shop_panel:FindChild("Btn"), function ()
        SpecMgrs.ui_mgr:ShowUI("ShoppingUI", UIConst.ShopList.NormalShop)
    end)
    self.chat_btn = self.main_panel:FindChild("ChatBtn")
    self.emoticon_item = self.chat_btn:FindChild("ChatBg/EmoticonItem")
    self:AddClick(self.chat_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("ChatUI")
    end)
    self.temp_chat = self.chat_btn:FindChild("ChatBg/ChatText")
    local temp_chat_rect = self.temp_chat:GetComponent("RectTransform")
    self.chat_height = temp_chat_rect.rect.height
    self.temp_chat_pos = temp_chat_rect.anchoredPosition
    self.cur_chat = self.chat_btn:FindChild("ChatBg/ChatText1")
    self.cur_chat_pos = self.cur_chat:GetComponent("RectTransform").anchoredPosition
end

function GameMenuUI:InitUI()
    self.scroll_timer = 0
    self.dy_chat_data:RegisterNewChatMsgEvent("GameMenuUI", self.AddChatMsg ,self)
    self.dy_chat_data:RegisterUpdateUnreadIndexEvent("GameMenuUI", self.UpdateUnreadIndex ,self)
    self.temp_chat:GetComponent("Text").text = ""
    self.chat_btn:SetActive(self.is_hide_chat ~= true)
end

function GameMenuUI:AddChatMsg(_, msg)
    if msg.chat_type == CSConst.ChatType.World or msg.chat_type == CSConst.ChatType.Private then
        self.chat_msg_queue:Enqueue(msg)
        -- 当前没有聊天或当前聊天消息已超过暂留时间且当前为下一个聊天消息
        if not self.cur_chat_timer then self:NextChat() end
    end
    if msg.chat_type == CSConst.ChatType.System then
        self.sys_notice_queue:Enqueue(msg.content)
    else
        self.chat_btn:FindChild("RedPoint"):SetActive(true)
    end
end

function GameMenuUI:UpdateUnreadIndex()
    local unread_flag = false
    for _, chat_type in pairs(CSConst.ChatType) do
        if chat_type ~= CSConst.ChatType.System then
            unread_flag = self.dy_chat_data:GetUnreadFlagWithType(chat_type)
            if unread_flag then break end
        end
    end
    self.chat_btn:FindChild("RedPoint"):SetActive(unread_flag)
end

function GameMenuUI:NextChat()
    local chat_msg = self.chat_msg_queue:Dequeue()
    if not chat_msg then
        --当前聊天消息已超过暂留时间且下一聊天未到达
        self.cur_chat_timer = nil
        return
    end
    local chat_text_cmp = self.cur_chat:GetComponent("TextPic")
    local msg_content
    local chat_msg_content = FilterBadWord(chat_msg.content)
    if chat_msg.chat_type == CSConst.ChatType.Private then
        local is_self = chat_msg.sender_uuid == ComMgrs.dy_data_mgr:ExGetRoleUuid()
        local sender_name = is_self and UIConst.Text.PLAYER_SP_NAME or chat_msg.sender_name
        local reciever_name = is_self and chat_msg.role_name or UIConst.Text.PLAYER_SP_NAME
        msg_content = string.format(UIConst.Text.PRIVATE_CHAT_CONTENT, sender_name, reciever_name, chat_msg_content)
    else
        msg_content = string.format(UIConst.Text.CHAT_CONTENT, chat_msg.sender_vip, chat_msg.sender_name, chat_msg_content)
    end
    local emoticon_id_list = chat_text_cmp:SetTextPicValue(msg_content)
    for _, emoticon_go in ipairs(self.cur_emoticon_list) do
        self:DelUIObject(emoticon_go)
    end
    self.cur_emoticon_list = {}
    for i = 0, emoticon_id_list.Length - 1 do
        local emoticon_go = self:GetUIObject(self.emoticon_item, self.cur_chat)
        local emoticon_img_cmp = emoticon_go:GetComponent("Image")
        UIFuncs.AssignUISpriteSync("UIRes/Emoticon/Normal/" .. emoticon_id_list[i], emoticon_id_list[i], emoticon_img_cmp)
        -- emoticon_img_cmp:SetNativeSize()
        emoticon_go:GetComponent("RectTransform").sizeDelta = Vector2.New(52, 52)
        emoticon_go:SetActive(false)
        table.insert(self.cur_emoticon_list, emoticon_go)
    end
    self:AddTextPicPopulateMesh(self.cur_chat, function ()
        local emoticon_pos_list = chat_text_cmp.ImgPosList
        for i = 0, self.cur_chat.childCount - 1 do
            local emoticon_go = self.cur_chat:GetChild(i)
            emoticon_go.localPosition = Vector3.New(emoticon_pos_list[2 * i], emoticon_pos_list[2 * i + 1] - 10)
            emoticon_go:SetActive(true)
        end
        self:RemoveTextPicPopulateMesh(self.cur_chat)
    end)

    self.cur_chat_target_pos_y = self.cur_chat_pos.y + self.chat_height
    self.temp_chat_target_pos_y = self.temp_chat_pos.y + self.chat_height
    self.scroll_chat = true
    self.cur_chat_timer = self.chat_msg_interval
end

function GameMenuUI:Update(delta_time)
    if self.sys_notice_queue.count > 0 and not self.is_hide_chat then
        self.msg_container:SetActive(true)
        self.sys_notice:GetComponent("RectTransform").anchoredPosition = Vector2.zero
        self.sys_notice:GetComponent("Text").text = self.sys_notice_queue:Dequeue()
        self.is_scrolling = true
    end
    if self.is_scrolling then
        if not (self.text_width > 0) then self.text_width = self.sys_notice:GetComponent("RectTransform").rect.width end
        local anchored_position = self.sys_notice:GetComponent("RectTransform").anchoredPosition
        if self.sys_notice:GetComponent("RectTransform").anchoredPosition.x > - self.text_width - self.container_width then
            self.sys_notice:GetComponent("RectTransform").anchoredPosition = self.sys_notice:GetComponent("RectTransform").anchoredPosition - Vector2.New(kNoticeScrollSpeed * delta_time, 0)
            return
        else
            self.msg_container:SetActive(false)
            self.is_scrolling = false
            self.text_width = 0
        end
    end
    if self.scroll_chat then
        self.scroll_timer = self.scroll_timer + delta_time
        local height_offset = math.lerp(0, self.chat_height, self.scroll_timer / kChatMsgScrollTime)
        self.cur_chat:GetComponent("RectTransform").anchoredPosition = Vector2.New(self.cur_chat_pos.x, self.cur_chat_pos.y + height_offset)
        self.temp_chat:GetComponent("RectTransform").anchoredPosition = Vector2.New(self.temp_chat_pos.x, self.temp_chat_pos.y + height_offset)
        if math.abs(self.cur_chat:GetComponent("RectTransform").anchoredPosition.y - self.cur_chat_target_pos_y) < 0.01 then
            self.scroll_chat = nil
            self.scroll_timer = 0
            self.cur_chat, self.temp_chat = self.temp_chat, self.cur_chat
            self.temp_emoticon_list, self.cur_emoticon_list = self.cur_emoticon_list, self.temp_emoticon_list
            self.cur_chat:GetComponent("TextPic").text = ""
            self.cur_chat:GetComponent("RectTransform").anchoredPosition = self.cur_chat_pos
        end
    end
    if self.cur_chat_timer and self.cur_chat_timer > 0 then
        self.cur_chat_timer = self.cur_chat_timer - delta_time
        if self.cur_chat_timer < 0 then self:NextChat() end
    end
end

return GameMenuUI