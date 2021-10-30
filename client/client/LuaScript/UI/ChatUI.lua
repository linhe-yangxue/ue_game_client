local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local UISlideSelectCmp = require("UI.UICmp.SlideSelectCmp")

local ChatUI = class("UI.ChatUI", UIBase)

local kChatItemPadding = 20
local kChatContentOffset = 40
local kChatContentTotalBorderX = 60
local kChatContentBorderY = 20
local kTotalHeightWithoutChatText = 138
local kChatTextMaxWidth = 564
local kSeparateLinePadding = 10
local kResetBtnOffsetX = 20

local kChatInputMaxHeight = 250
local kInputTextBorder = 16
local kInputFieldBorder = 71

local kExpandTime = 0.5
local kCheckChatUpdateInterval = 0.2
local kScrollBarHideTime = 1

local kChatItemCount = 20
local kEmoticonCount = 49
local kEmoticonCountPerPage = 40

function ChatUI:DoInit()
    ChatUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ChatUI"
    self.dy_chat_data = ComMgrs.dy_data_mgr.chat_data
    self.dy_dynasty_data = ComMgrs.dy_data_mgr.dynasty_data
    self.dy_friend_data = ComMgrs.dy_data_mgr.friend_data
    self.channel_btn_dict = {}
    self.channel_content_dict = {}
    self.chat_item_list = {}
    self.emoticon_item_list = {}
    self.page_dot_list = {}
    self.emoticon_page_index = 1
    self.chat_msg_max_cache_count = SpecMgrs.data_mgr:GetParamData("chat_msg_max_cache_count").f_value
    self.translation_item_dict = {}
end

function ChatUI:OnGoLoadedOk(res_go)
    ChatUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function ChatUI:Hide()
    self.default_channel = nil
    self.role_info = nil
    self.dy_chat_data:UnregisterNewChatMsgEvent("ChatUI")
    self.dy_chat_data:UnregisterUpdateUnreadIndexEvent("ChatUI")
    self:ClearUpdateChatTimer()
    self:ClearChatItem()
    ChatUI.super.Hide(self)
end

function ChatUI:Show(default_channel, role_info)
    self.default_channel = default_channel
    self.role_info = role_info
    if self.is_res_ok then
        self:InitUI()
    end
    ChatUI.super.Show(self)
end

function ChatUI:InitRes()
    local content = self.main_panel:FindChild("Content")
    self.content_rect_cmp = content:GetComponent("RectTransform")
    self.content_height = self.content_rect_cmp.rect.height
    self.content_pos_cmp = content:GetComponent("UITweenPosition")
    self.bottom_pos = Vector2.New(0, -self.content_height)
    self.top_pos = Vector2.zero
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("Content/TopBar"), "ChatUI", function ()
        self.emoticon_panel:SetActive(false)
        if self.chat_input_cmp.touchScreenKeyboard then self.chat_input_cmp.touchScreenKeyboard.active = false end
        self.content_rect_cmp.offsetMin = Vector2.zero
        self:ShowChatContent(false)
    end)

    local channel_panel = self.main_panel:FindChild("Content/ChannelPanel/View/Content")

    self.local_server_channel_btn = channel_panel:FindChild("LocalServer")
    self.local_server_channel_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.LOCAL_SERVER_CHANNEL
    self.local_server_channel_btn:FindChild("Select/Text"):GetComponent("Text").text = UIConst.Text.LOCAL_SERVER_CHANNEL
    self:AddClick(self.local_server_channel_btn, function ()
        self:InitChatMsg(CSConst.ChatType.World)
    end)
    self.channel_btn_dict[CSConst.ChatType.World] = self.local_server_channel_btn

    self.cross_server_channel_btn = channel_panel:FindChild("CrossServer")
    self.cross_server_channel_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CROSS_SERVER_CHANNEL
    self.cross_server_channel_btn:FindChild("Select/Text"):GetComponent("Text").text = UIConst.Text.CROSS_SERVER_CHANNEL
    self:AddClick(self.cross_server_channel_btn, function ()
        self:InitChatMsg(CSConst.ChatType.Cross)
    end)
    self.channel_btn_dict[CSConst.ChatType.Cross] = self.cross_server_channel_btn

    self.dynasty_server_channel_btn = channel_panel:FindChild("DynastyServer")
    self.dynasty_server_channel_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_SERVER_CHANNEL
    self.dynasty_server_channel_btn:FindChild("Select/Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_SERVER_CHANNEL
    self:AddClick(self.dynasty_server_channel_btn, function ()
        self:InitChatMsg(CSConst.ChatType.Dynasty)
    end)
    self.channel_btn_dict[CSConst.ChatType.Dynasty] = self.dynasty_server_channel_btn

    self.private_channel_btn = channel_panel:FindChild("Private")
    self.private_channel_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.PRIVATE_SERVER_CHANNEL
    self.private_channel_btn:FindChild("Select/Text"):GetComponent("Text").text = UIConst.Text.PRIVATE_SERVER_CHANNEL
    self:AddClick(self.private_channel_btn, function ()
        self:InitChatMsg(CSConst.ChatType.Private)
    end)
    self.channel_btn_dict[CSConst.ChatType.Private] = self.private_channel_btn

    self.chat_content_panel = self.main_panel:FindChild("Content/ChatContent")
    self:AddClick(self.chat_content_panel, function ()
        self.is_show_keyboard = false
        self.content_rect_cmp.offsetMin = Vector2.zero
        self.emoticon_panel:SetActive(false)
        self.keyboard_btn:SetActive(false)
        self.emoticon_btn:SetActive(true)
    end)
    self.channel_content_dict[CSConst.ChatType.World] = self.chat_content_panel:FindChild("LocalServer")
    self.channel_content_dict[CSConst.ChatType.Cross] = self.chat_content_panel:FindChild("CrossServer")
    self.channel_content_dict[CSConst.ChatType.Dynasty] = self.chat_content_panel:FindChild("DynastyServer")
    self.channel_content_dict[CSConst.ChatType.Private] = self.chat_content_panel:FindChild("Private")

    self.chat_empty_panel = self.chat_content_panel:FindChild("Empty")
    self.chat_empty_panel:FindChild("Dialog/Text"):GetComponent("Text").text = UIConst.Text.NO_CHAT_MSG

    self.input_panel = self.main_panel:FindChild("Content/InputPanel")
    self:AddClick(self.input_panel:FindChild("HornBtn"), function ()
        -- TODO 喇叭
    end)
    self.chat_input = self.input_panel:FindChild("ChatInput")
    self.chat_player_panel = self.input_panel:FindChild("ChatPlayer")
    self.chat_info = self.chat_player_panel:FindChild("Text"):GetComponent("Text")
    self.chat_input_cmp = self.chat_input:GetComponent("InputField")
    self.chat_input_rect_cmp = self.chat_input:GetComponent("RectTransform")
    self:AddInputFieldValueChange(self.chat_input, function ()
        local text_height = self.chat_input_cmp.preferredHeight

        local text_rect_cmp = self.chat_input:FindChild("View/Text"):GetComponent("RectTransform")
        text_rect_cmp.sizeDelta = Vector2.New(text_rect_cmp.sizeDelta.x, text_height)

        local text_input_size = self.chat_input_rect_cmp.sizeDelta
        local input_size = text_height + 2 * kInputTextBorder
        text_input_size.y = input_size > kChatInputMaxHeight and kChatInputMaxHeight or input_size
        self.chat_input_rect_cmp.sizeDelta = text_input_size

        local input_panel_size = self.input_panel:GetComponent("RectTransform").sizeDelta
        input_panel_size.y = text_input_size.y + kInputFieldBorder
        self.input_panel:GetComponent("RectTransform").sizeDelta = input_panel_size
        self.chat_content_panel:GetComponent("RectTransform").offsetMin = Vector2.New(0, input_panel_size.y)
    end)
    self.emoticon_btn = self.input_panel:FindChild("EmoticonBtn")
    self:AddClick(self.emoticon_btn, function ()
        if self.chat_input_cmp.touchScreenKeyboard then self.chat_input_cmp.touchScreenKeyboard.active = false end
        self.is_show_keyboard = false
        self.content_rect_cmp.offsetMin = Vector2.New(0, self.emoticon_panel:GetComponent("RectTransform").sizeDelta.y)
        self.emoticon_panel:SetActive(true)
        self.emoticon_btn:SetActive(false)
        self.keyboard_btn:SetActive(true)
    end)
    self.keyboard_btn = self.input_panel:FindChild("KeyboardBtn")
    self:AddClick(self.keyboard_btn, function ()
        self.emoticon_panel:SetActive(false)
        if self.chat_input_cmp.touchScreenKeyboard then
            self.chat_input_cmp.touchScreenKeyboard.active = true
        else
            self.content_rect_cmp.offsetMin = Vector2.zero
        end
        self.emoticon_btn:SetActive(true)
        self.keyboard_btn:SetActive(false)
    end)
    local send_btn = self.input_panel:FindChild("SendBtn")
    send_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SEND_MSG_TEXT
    self:AddClick(send_btn, function ()
        self.dy_chat_data:SendChatMsg(self.cur_channel, self.chat_input_cmp.text, self.role_info)
        self.chat_input_cmp.text = ""
        self.channel_content_dict[self.cur_channel]:GetComponent("ScrollRect").verticalNormalizedPosition = 0
    end)

    local prefab_list = self.main_panel:FindChild("PrefabList")
    self.chat_item = prefab_list:FindChild("ChatItem")
    self.self_chat_item = prefab_list:FindChild("SelfChatItem")
    self.emoticon_item = prefab_list:FindChild("EmoticonItem")
    self.separate_line = prefab_list:FindChild("SeparateLine")
    self.translation_item = prefab_list:FindChild("Translation")
    self.reset_btn = prefab_list:FindChild("ResetBtn")

    self.emoticon_panel = self.main_panel:FindChild("EmoticonPanel")
    self.emoticon_page = self.emoticon_panel:FindChild("EmoticonPage")
    self.emoticon_pref = self.emoticon_panel:FindChild("EmoticonItem")
    self.page_index_item = self.emoticon_panel:FindChild("PageIndexDot")
    self.emoticon_view = self.emoticon_panel:FindChild("View")
    self.emoticon_content = self.emoticon_view:FindChild("Content")
    self.emoticon_page_panel = self.emoticon_panel:FindChild("PageIndexPanel")

    self.emoticon_slide_cmp = UISlideSelectCmp.New()
    self.emoticon_slide_cmp:DoInit(self, self.emoticon_content)

    self.mask = self.main_panel:FindChild("Mask")
end

function ChatUI:InitUI()
    self.chat_input_cmp.text = ""
    self:InitUnreadRedPoint()
    self:InitEmoticonPanel()
    self.dy_chat_data:RegisterNewChatMsgEvent("ChatUI", self.AddChatMsg, self)
    self.dy_chat_data:RegisterUpdateUnreadIndexEvent("ChatUI", self.UpdateUnreadIndex, self)
    self:InitChatMsg(self.default_channel or CSConst.ChatType.World)
    self.default_channel = nil

    self.content_rect_cmp.anchoredPosition = self.bottom_pos
    self:ShowChatContent(true)
end

function ChatUI:ShowChatContent(is_open)
    self.content_pos_cmp.from_ = is_open and self.bottom_pos or self.top_pos
    self.content_pos_cmp.to_ = is_open and self.top_pos or self.bottom_pos
    self.content_pos_cmp:Play()
    self.mask:SetActive(true)
    self:AddTimer(function ()
        self.mask:SetActive(false)
        if not is_open then self:Hide() end
    end, kExpandTime)
end

function ChatUI:InitUnreadRedPoint()
    for _, chat_type in pairs(CSConst.ChatType) do
        if chat_type ~= CSConst.ChatType.System then
            self.channel_btn_dict[chat_type]:FindChild("RedPoint"):SetActive(self.dy_chat_data:GetUnreadFlagWithType(chat_type))
        end
    end
end

function ChatUI:InitEmoticonPanel()
    if not self.have_init_emoticon then
        local page_count = math.ceil(kEmoticonCount / kEmoticonCountPerPage)
        local view_rect = self.emoticon_view:GetComponent("RectTransform").rect
        local content_width = view_rect.width * page_count
        self.emoticon_content:GetComponent("RectTransform").sizeDelta = Vector2.New(content_width, view_rect.height)
        local rest_count = kEmoticonCount % kEmoticonCountPerPage
        for i = 1, page_count do
            local page = self:GetUIObject(self.emoticon_page, self.emoticon_content)
            page:GetComponent("RectTransform").sizeDelta = Vector2.New(view_rect.width, view_rect.height)
            local start_index = (i - 1) * kEmoticonCountPerPage + 1
            local end_index = start_index + (i == page_count and rest_count or kEmoticonCountPerPage) - 1
            for j = start_index, end_index do
                local go = self:GetUIObject(self.emoticon_pref, page)
                local emoticon_no = string.format("%03d", j)
                UIFuncs.AssignUISpriteSync("UIRes/Emoticon/Normal/Emoji" .. emoticon_no, "Emoji" .. emoticon_no, go:GetComponent("Image"))
                self:AddClick(go, function ()
                    self.editing_emoticon = true
                    self.chat_input_cmp.text = self.chat_input_cmp.text .. "#" .. emoticon_no
                end)
            end
            local page_dot = self:GetUIObject(self.page_index_item, self.emoticon_page_panel)
            self:AddClick(page_dot, function()
                self.emoticon_slide_cmp:SlideToIndex(i - 1)
            end)
            table.insert(self.page_dot_list, page_dot)
        end
        self.emoticon_slide_cmp:SetParam(view_rect.width, page_count)
        self.emoticon_slide_cmp:SetDraggable(page_count > 1)
        self.emoticon_slide_cmp:ListenSlideEnd(function (index)
            self.page_dot_list[self.emoticon_page_index]:FindChild("Select"):SetActive(false)
            self.emoticon_page_index = index + 1
            self.page_dot_list[self.emoticon_page_index]:FindChild("Select"):SetActive(true)
        end)
        self.have_init_emoticon = true
    end
    self.keyboard_btn:SetActive(false)
    self.emoticon_btn:SetActive(true)
    self.emoticon_page_index = 1
    self.page_dot_list[self.emoticon_page_index]:FindChild("Select"):SetActive(true)
    self.emoticon_slide_cmp:SetToIndex(0)
end

function ChatUI:InitChatMsg(channel)
    if channel == CSConst.ChatType.Dynasty and not self.dy_dynasty_data:GetDynastyId() then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.JOIN_DYNASTY_LIMIT)
        return
    end
    local last_channel_content = self.channel_content_dict[self.cur_channel]
    if self.cur_channel then
        self.channel_btn_dict[self.cur_channel]:FindChild("Select"):SetActive(false)
        last_channel_content:SetActive(false)
        self:RemoveUIChatViewUpdate(last_channel_content)
    end

    self.cur_channel = channel
    self.channel_btn_dict[self.cur_channel]:FindChild("Select"):SetActive(true)
    self.dy_chat_data:SetUnreadIndexWithType(self.cur_channel)
    self.chat_player_panel:SetActive(self.cur_channel == CSConst.ChatType.Private)
    if self.cur_channel == CSConst.ChatType.Private then
        self.chat_player_panel:SetActive(self.role_info ~= nil)
        if self.role_info then
            self.chat_info.text = string.format(UIConst.Text.PRIVATE_CHAT_FORMAT, self.role_info.name, self.role_info.server_id)
        end
    end
    self:ClearChatItem()

    local cur_channel_content = self.channel_content_dict[self.cur_channel]
    local channel_scroll_rect = cur_channel_content:GetComponent("ScrollRect")

    local msg_list = self.dy_chat_data:GetChatMsgByChannel(self.cur_channel)
    self.chat_empty_panel:SetActive(not msg_list or #msg_list == 0)
    if msg_list then
        local msg_count = msg_list:Count()
        self.cache_index = msg_count > kChatItemCount and kChatItemCount or msg_count
        for i = self.cache_index - 1, 0, -1 do
            self:AddChatItem(msg_list:Get(msg_count - i))
        end
        channel_scroll_rect.verticalNormalizedPosition = 0
    end
    cur_channel_content:GetComponent("UIChatSwipeView"):Init()
    self:ClearUpdateChatTimer()
    self.update_chat_timer = SpecMgrs.timer_mgr:AddTimer(function ()
        local vertical_pos = channel_scroll_rect.verticalNormalizedPosition
        if vertical_pos >= 1 then
            local msg_list = self.dy_chat_data:GetChatMsgByChannel(self.cur_channel)
            if not msg_list then return end
            local msg_count = msg_list:Count()
            if self.cache_index == msg_count then return end
            self.last_cache_index = self.cache_index
            self.cache_index = msg_count > self.cache_index + kChatItemCount and self.cache_index + kChatItemCount or msg_count
            for i = self.last_cache_index, self.cache_index - 1 do
                self:AddChatItem(msg_list:Get(msg_count - i), i + 1)
            end
        elseif vertical_pos <= 0 then
            self.dy_chat_data:SetUnreadIndexWithType(self.cur_channel)
        end
    end, kCheckChatUpdateInterval, 0)
    cur_channel_content:SetActive(true)
end

function ChatUI:AddChatMsg(_, msg)
    if msg.chat_type == self.cur_channel then
        self.chat_empty_panel:SetActive(false)
        self.cache_index = math.clamp((self.cache_index or 0) + 1, 0, self.chat_msg_max_cache_count)
        local scroll_rect_cmp = self.channel_content_dict[self.cur_channel]:GetComponent("ScrollRect")
        local content_rect_cmp = self.channel_content_dict[self.cur_channel]:FindChild("View/Content"):GetComponent("RectTransform")

        local content_pos = content_rect_cmp.anchoredPosition
        local new_chat_height = self:AddChatItem(msg) + kChatItemPadding
        if scroll_rect_cmp.verticalNormalizedPosition < 0.001 or self.content_height > content_rect_cmp.sizeDelta.y then
            self.dy_chat_data:SetUnreadIndexWithType(self.cur_channel)
            return
        end
        content_pos.y = content_pos.y - new_chat_height
        content_rect_cmp.anchoredPosition = content_pos
    end
end

function ChatUI:UpdateUnreadIndex(_, chat_type, unread_flag)
    self.channel_btn_dict[chat_type]:FindChild("RedPoint"):SetActive(unread_flag)
end

function ChatUI:AddChatItem(chat_msg, index)
    local channel_content = self.channel_content_dict[self.cur_channel]:FindChild("View/Content")

    local chat_item_count = #self.chat_item_list
    if chat_item_count == self.chat_msg_max_cache_count then
        local remove_go = table.remove(self.chat_item_list, chat_item_count)
        local emoticon_list = table.remove(self.emoticon_item_list, chat_item_count)
        for _, emoticon_go in ipairs(emoticon_list) do
            self:DelUIObject(emoticon_go)
        end
        local instance_id = remove_go:GetInstanceID()
        if self.translation_item_dict[instance_id] then
            self:DelUIObject(self.translation_item_dict[instance_id].separate_line)
            self:DelUIObject(self.translation_item_dict[instance_id].translation)
            self:DelUIObject(self.translation_item_dict[instance_id].reset_btn)
            for _, emoticon_go in ipairs(self.translation_item_dict[instance_id].emoticon_go_list) do
                self:DelUIObject(emoticon_go)
            end
            self.translation_item_dict[instance_id] = nil
        end
        self:DelUIObject(remove_go)
    end
    local is_self = ComMgrs.dy_data_mgr:ExGetRoleUuid() == chat_msg.sender_uuid
    local go = self:GetUIObject(is_self and self.self_chat_item or self.chat_item, channel_content)
    if index then go:SetSiblingIndex(0) end
    if chat_msg.sender_title then
        local title = go:FindChild("NamePanel/Title")
        title:SetActive(true)
        UIFuncs.AssignSpriteByItemID(chat_msg.sender_title, title:GetComponent("Image"))
    end
    local role_look_data = SpecMgrs.data_mgr:GetRoleLookData(chat_msg.sender_role_id)
    local role_icon = go:FindChild("Image/RoleIcon")
    UIFuncs.AssignSpriteByIconID(role_look_data.head_icon_id, role_icon:GetComponent("Image"))
    local vip = go:FindChild("NamePanel/Vip")
    local vip_data = SpecMgrs.data_mgr:GetVipData(chat_msg.sender_vip)
    vip:SetActive(vip_data ~= nil)
    if vip_data then UIFuncs.AssignSpriteByIconID(vip_data.icon, vip:GetComponent("Image")) end
    if chat_msg.chat_type == CSConst.ChatType.Private then
        if is_self then
            go:FindChild("NamePanel/Name"):GetComponent("Text").text = string.format(UIConst.Text.PRIVATE_CHAT_OTHER_FORMAT, chat_msg.private_name)
        else
            go:FindChild("NamePanel/Name"):GetComponent("Text").text = string.format(UIConst.Text.PRIVATE_CHAT_NAME_FORMAT, chat_msg.sender_name)
        end
    else
        go:FindChild("NamePanel/Name"):GetComponent("Text").text = chat_msg.sender_name
        -- go:FindChild("NamePanel/Name"):GetComponent("Text").text = string.format(UIConst.Text.CHAT_NAME, chat_msg.sender_vip, chat_msg.sender_name)
    end
    local chat_bg = go:FindChild("ChatPanel")
    local chat_text = chat_bg:FindChild("Text")
    local chat_text_cmp = chat_text:GetComponent("TextPic")
    local emoticon_go_list = self:SetTextContent(chat_text, FilterBadWord(chat_msg.content))

    local go_rect_cmp = go:GetComponent("RectTransform")
    local chat_bg_rect_cmp = chat_bg:GetComponent("RectTransform")
    local chat_text_rect = chat_text:GetComponent("RectTransform")

    local text_width = chat_text_cmp.preferredWidth < kChatTextMaxWidth and chat_text_cmp.preferredWidth or kChatTextMaxWidth
    chat_text_rect.sizeDelta = Vector2.New(kChatTextMaxWidth, chat_text_rect.sizeDelta.y)
    local text_height = chat_text_cmp.preferredHeight

    if text_width < kChatTextMaxWidth then
        chat_text_rect.sizeDelta = Vector2.New(text_width, text_height)
    end

    local content_height = text_height + 2 * kChatContentBorderY
    local content_width = text_width + kChatContentTotalBorderX

    local total_height = kTotalHeightWithoutChatText + content_height
    chat_bg_rect_cmp.sizeDelta = Vector2.New(content_width, content_height)
    go_rect_cmp.sizeDelta = Vector2.New(go_rect_cmp.sizeDelta.x, total_height)

    if not is_self then
        local cb_dict = {
            [UIConst.OtherPlayerMsgOption.PrivateChat] = function ()
                SpecMgrs.ui_mgr:HideUI("OtherPlayerMsgOption")
            end,
        }
        self:AddClick(role_icon, function ()
            self.dy_friend_data:ShowPlayerInfo(chat_msg.sender_uuid, cb_dict)
        end)
        local translate_btn = chat_bg:FindChild("TranslateBtn")
        -- translate_btn:SetActive(true)
        -- self:AddClick(translate_btn, function ()
        --     self:AddTranslationText(go, chat_msg.content)
        -- end)
    end

    table.insert(self.chat_item_list, index or 1, go)
    table.insert(self.emoticon_item_list, index or 1, emoticon_go_list)

    return total_height
end

function ChatUI:ChangePrivateChat(role_info)
    self.role_info = role_info
    self:InitChatMsg(CSConst.ChatType.Private)
end

function ChatUI:AddTranslationText(chat_go, content)
    local chat_panel = chat_go:FindChild("ChatPanel")
    local translate_btn = chat_panel:FindChild("TranslateBtn")
    translate_btn:SetActive(false)
    local separate_line = self:GetUIObject(self.separate_line, chat_panel)
    local translation = self:GetUIObject(self.translation_item, chat_panel)
    local reset_btn = self:GetUIObject(self.reset_btn, chat_panel)
    reset_btn:GetComponent("RectTransform").anchoredPosition = Vector2.New(kResetBtnOffsetX, 0)
    local translation_text = "翻译后的文字"
    local emoticon_go_list = self:SetTextContent(translation, translation_text)

    local chat_text_cmp = chat_panel:FindChild("Text"):GetComponent("TextPic")
    local translation_text_cmp = translation:GetComponent("TextPic")
    local separate_line_rect = separate_line:GetComponent("RectTransform")
    local chat_go_rect = chat_go:GetComponent("RectTransform")
    local chat_panel_rect = chat_panel:GetComponent("RectTransform")

    local chat_panel_size = chat_panel_rect.sizeDelta
    local chat_go_size = chat_go_rect.sizeDelta

    local translation_width = math.min(translation_text_cmp.preferredWidth, kChatTextMaxWidth)
    local translation_height = translation_text_cmp.preferredHeight

    local chat_text_width = math.min(chat_text_cmp.preferredWidth, kChatTextMaxWidth)
    local chat_text_height = chat_text_cmp.preferredHeight
    local separate_line_size = separate_line_rect.sizeDelta
    separate_line_size.x = math.max(chat_text_width, translation_width)

    separate_line_rect.sizeDelta = separate_line_size
    local separate_line_pos_y = kChatContentBorderY + chat_text_height + kSeparateLinePadding
    separate_line_rect.anchoredPosition = Vector2.New(kChatContentOffset, -separate_line_pos_y)

    local translation_pos_y = separate_line_pos_y + separate_line_size.y + kSeparateLinePadding
    translation:GetComponent("RectTransform").anchoredPosition = Vector2.New(kChatContentOffset, -translation_pos_y)

    local content_height = translation_pos_y + translation_height + kChatContentBorderY
    chat_panel_rect.sizeDelta = Vector2.New(separate_line_size.x + kChatContentTotalBorderX, content_height)
    chat_go_rect.sizeDelta = Vector2.New(chat_go_rect.sizeDelta.x, content_height + kTotalHeightWithoutChatText)

    local instance_id = chat_go:GetInstanceID()
    self.translation_item_dict[instance_id] = {}
    self.translation_item_dict[instance_id].separate_line = separate_line
    self.translation_item_dict[instance_id].translation = translation
    self.translation_item_dict[instance_id].reset_btn = reset_btn
    self.translation_item_dict[instance_id].emoticon_go_list = emoticon_go_list

    self:AddClick(reset_btn, function ()
        translate_btn:SetActive(true)
        self:DelUIObject(separate_line)
        self:DelUIObject(translation)
        self:DelUIObject(reset_btn)
        for _, emoticon_go in ipairs(emoticon_go_list) do
            self:DelUIObject(emoticon_go)
        end
        self.translation_item_dict[instance_id] = nil
        chat_panel_rect.sizeDelta = chat_panel_size
        chat_go_rect.sizeDelta = chat_go_size
    end)
end

function ChatUI:SetTextContent(text_go, text)
    local emoticon_go_list = {}
    local text_pic_cmp = text_go:GetComponent("TextPic")
    local emoticon_id_list = text_pic_cmp:SetTextPicValue(text)
    for i = 0, emoticon_id_list.Length - 1 do
        local emoticon_go = self:GetUIObject(self.emoticon_item, text_go)
        local emoticon_img_cmp = emoticon_go:GetComponent("Image")
        UIFuncs.AssignUISpriteSync("UIRes/Emoticon/Normal/" .. emoticon_id_list[i], emoticon_id_list[i], emoticon_img_cmp)
        emoticon_go:GetComponent("RectTransform").sizeDelta = Vector2.New(52, 52)
        -- emoticon_img_cmp:SetNativeSize()
        emoticon_go:SetActive(false)
        table.insert(emoticon_go_list, emoticon_go)
    end
    self:AddTextPicPopulateMesh(text_go, function ()
        local emoticon_pos_list = text_pic_cmp.ImgPosList
        for i = 0, text_go.childCount - 1 do
            local emoticon_go = text_go:GetChild(i)
            emoticon_go.localPosition = Vector3.New(emoticon_pos_list[2 * i], emoticon_pos_list[2 * i + 1] - 10)
            emoticon_go:SetActive(true)
        end
        self:RemoveTextPicPopulateMesh(text_go)
    end)
    self:AddTextPicOnClickHref(text_go, function (href_key)
        self.dy_chat_data:AnalysisHyperlinkData(href_key)
    end)
    return emoticon_go_list
end

function ChatUI:Update(delta_time)
    if self.chat_input_cmp.isFocused and not self.is_show_keyboard then
        if self.chat_input_cmp.touchScreenKeyboard then
            self.chat_input_cmp.touchScreenKeyboard.hideInput = true
            local input_height = self.chat_input_cmp.touchScreenKeyboard.area.height
            self.main_panel:GetComponent("RectTransform").offsetMin = Vector2.New(0, input_height)
        end
        self.is_show_keyboard = true
    end
end

function ChatUI:ClearChatItem()
    for _, emoticon_list in ipairs(self.emoticon_item_list) do
        for _, emoticon_go in ipairs(emoticon_list) do
            self:DelUIObject(emoticon_go)
        end
    end
    self.emoticon_item_list = {}
    for _, chat_go in ipairs(self.chat_item_list) do
        local instance_id = chat_go:GetInstanceID()
        if self.translation_item_dict[instance_id] then
            self:DelUIObject(self.translation_item_dict[instance_id].separate_line)
            self:DelUIObject(self.translation_item_dict[instance_id].translation)
            self:DelUIObject(self.translation_item_dict[instance_id].reset_btn)
            for _, emoticon_go in ipairs(self.translation_item_dict[instance_id].emoticon_go_list) do
                self:DelUIObject(emoticon_go)
            end
        end
        self:DelUIObject(chat_go)
    end
    self.chat_item_list = {}
    self.translate_flag_dict = {}
end

function ChatUI:ClearUpdateChatTimer()
    if self.update_chat_timer then
        SpecMgrs.timer_mgr:RemoveTimer(self.update_chat_timer)
        self.update_chat_timer = nil
    end
end

return ChatUI