local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local DynastyUI = class("UI.DynastyUI", UIBase)

local kChatMsgScrollTime = 0.5
local kFixedRankItemCount = 3

function DynastyUI:DoInit()
    DynastyUI.super.DoInit(self)
    self.prefab_path = "UI/Common/DynastyUI"
    self.dynasty_compete_apply_level_limit = SpecMgrs.data_mgr:GetParamData("dynasty_compete_apply_level_limit").f_value
    self.dynasty_compete_apply_member_count = SpecMgrs.data_mgr:GetParamData("dynasty_compete_apply_member_count").f_value
    self.chat_msg_queue = Queue.New()
    self.dy_chat_data = ComMgrs.dy_data_mgr.chat_data
    self.dy_dynasty_data = ComMgrs.dy_data_mgr.dynasty_data
    self.dynasty_rank_item_list = {}
    self.cur_emoticon_list = {}
    self.temp_emoticon_list = {}
end

function DynastyUI:OnGoLoadedOk(res_go)
    DynastyUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function DynastyUI:Hide()
    self:ClearDynastyRankItem()
    self.dy_chat_data:UnregisterNewChatMsgEvent("DynastyUI")
    self.dy_chat_data:UnregisterUpdateUnreadIndexEvent("DynastyUI")
    self.dy_dynasty_data:UnregisterKickedOutDynastyEvent("DynastyUI")
    DynastyUI.super.Hide(self)
end

function DynastyUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    DynastyUI.super.Show(self)
end

function DynastyUI:InitRes()
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "DynastyUI")

    local building_panel = self.main_panel:FindChild("BuildingPanel")
    local shop_btn = building_panel:FindChild("Shop")
    shop_btn:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.SHOP_TEXT
    self:AddClick(shop_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("ShoppingUI", UIConst.ShopList.DynastyShop)
    end)
    local hegemony_btn = building_panel:FindChild("Hegemony")
    hegemony_btn:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_HEGEMONY_TEXT
    self:AddClick(hegemony_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("DynastyStationUI")
    end)
    local management_btn = building_panel:FindChild("Management")
    management_btn:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_MANAGEMENT_TEXT
    self:AddClick(management_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("DynastyManageUI")
    end)
    local challenge_btn = building_panel:FindChild("Challenge")
    challenge_btn:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_CHALLENGE_TEXT
    self:AddClick(challenge_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("DynastyChallengeUI")
    end)
    local office_btn = building_panel:FindChild("Office")
    office_btn:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_OFFICE_TEXT
    self:AddClick(office_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("DynastyOfficeUI")
    end)
    local institute_btn = building_panel:FindChild("Institute")
    institute_btn:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_INSTITUTE_TEXT
    self:AddClick(institute_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("DynastyInstituteUI")
    end)

    self.chat_btn = self.main_panel:FindChild("ChatBtn")
    self.emoticon_item = self.chat_btn:FindChild("ChatBg/EmoticonItem")
    self:AddClick(self.chat_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("ChatUI", CSConst.ChatType.Dynasty)
    end)
    self.temp_chat = self.chat_btn:FindChild("ChatBg/ChatText")
    local temp_chat_rect = self.temp_chat:GetComponent("RectTransform")
    self.chat_height = temp_chat_rect.rect.height
    self.temp_chat_pos = temp_chat_rect.anchoredPosition
    self.cur_chat = self.chat_btn:FindChild("ChatBg/ChatText1")
    self.cur_chat_pos = self.cur_chat:GetComponent("RectTransform").anchoredPosition

    local info_panel = self.main_panel:FindChild("InfoPanel")
    self.dynasty_icon = info_panel:FindChild("Icon"):GetComponent("Image")
    self.dynasty_name = info_panel:FindChild("Name"):GetComponent("Text")
    info_panel:FindChild("CountPanel/Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_MEMBER_COUNT
    self.dynasty_member_count = info_panel:FindChild("CountPanel/Count"):GetComponent("Text")
    self.dynasty_score = info_panel:FindChild("Score"):GetComponent("Text")
    local detail_info_btn = info_panel:FindChild("DetailInfoBtn")
    detail_info_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_INFO_TEXT
    self:AddClick(detail_info_btn, function ()
        self.dy_dynasty_data:UpdateDynastyBasicInfo(function (dynasty_info)
            if not self.is_res_ok then return end
            self:InitDynastyDetailInfo(dynasty_info)
        end)
    end)

    self.detail_info_panel = self.main_panel:FindChild("DetailInfoPanel")
    local detail_info_content = self.detail_info_panel:FindChild("Panel")
    local detail_top_panel = detail_info_content:FindChild("Top")
    detail_top_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_INFO_TEXT
    self:AddClick(detail_top_panel:FindChild("CloseBtn"), function ()
        self.detail_info_panel:SetActive(false)
    end)
    local info_content = detail_info_content:FindChild("Info")
    self.detail_info_name = info_content:FindChild("Name"):GetComponent("Text")
    self.detail_info_icon = info_content:FindChild("Icon"):GetComponent("Image")
    self.detail_info_member_count = info_content:FindChild("CountPanel/Text"):GetComponent("Text")
    self.detail_info_score = info_content:FindChild("Score"):GetComponent("Text")
    local detail_exp_bar = info_content:FindChild("ExpBar")
    self.detail_info_exp = detail_exp_bar:FindChild("Exp"):GetComponent("Image")
    self.detail_info_exp_value = detail_exp_bar:FindChild("ExpValue"):GetComponent("Text")
    self.detail_info_no = info_content:FindChild("DynastyNo"):GetComponent("Text")
    local detail_declaration_panel = detail_info_content:FindChild("DeclarationPanel")
    detail_declaration_panel:FindChild("Title"):GetComponent("Text").text = UIConst.Text.DYNASTY_DECLARATION_TEXT
    self.detail_info_declaration = detail_declaration_panel:FindChild("DeclarationBg/Text"):GetComponent("Text")
    local detail_announcement_panel = detail_info_content:FindChild("AnnouncementPanel")
    detail_announcement_panel:FindChild("Title"):GetComponent("Text").text = UIConst.Text.DYNASTY_ANNOUNCEMENT_TEXT
    self.detail_info_announcement = detail_announcement_panel:FindChild("AnnouncementBg/Text"):GetComponent("Text")
    local dynasty_rank_btn = detail_info_content:FindChild("BtnPanel/DynastyRankBtn")
    dynasty_rank_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_RANK_TEXT
    self:AddClick(dynasty_rank_btn, function ()
        self:InitDynastyRankList()
    end)
    local quit_dynasty_btn = detail_info_content:FindChild("BtnPanel/QuitDynastyBtn")
    quit_dynasty_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.QUIT_DYNASTY_TEXT
    self:AddClick(quit_dynasty_btn, function ()
        self:QuitDynasty()
    end)

    self.dynasty_rank_panel = self.main_panel:FindChild("RankPanel")
    self.dynasty_rank_list_content = self.dynasty_rank_panel:FindChild("RankList/View/Content")
    self.dynasty_rank_item = self.dynasty_rank_list_content:FindChild("RankItem")
    local first = self.dynasty_rank_list_content:FindChild("First")
    table.insert(self.dynasty_rank_item_list, first)
    local second = self.dynasty_rank_list_content:FindChild("Second")
    table.insert(self.dynasty_rank_item_list, second)
    local third = self.dynasty_rank_list_content:FindChild("Third")
    table.insert(self.dynasty_rank_item_list, third)
    local head_panel = self.dynasty_rank_panel:FindChild("RankList/Head")
    head_panel:FindChild("Rank"):GetComponent("Text").text = UIConst.Text.RANK_TEXT
    head_panel:FindChild("Name"):GetComponent("Text").text = UIConst.Text.DYNASTY_TEXT
    head_panel:FindChild("Count"):GetComponent("Text").text = UIConst.Text.DYNASTY_MEMBER_COUNT
    head_panel:FindChild("Score"):GetComponent("Text").text = UIConst.Text.TOTAL_SCORE_TEXT
    local dynasty_rank_top_panel = self.dynasty_rank_panel:FindChild("TopBar")
    dynasty_rank_top_panel:FindChild("CloseBtn/Title"):GetComponent("Text").text = UIConst.Text.DYNASTY_RANK_TEXT
    self:AddClick(dynasty_rank_top_panel:FindChild("CloseBtn"), function ()
        self.dynasty_rank_panel:SetActive(false)
    end)
    local dynasty_rank_bottom_panel = self.dynasty_rank_panel:FindChild("BottomPanel")
    self.dynasty_rank_name = dynasty_rank_bottom_panel:FindChild("Name"):GetComponent("Text")
    self.dynasty_rank_icon = dynasty_rank_bottom_panel:FindChild("Icon"):GetComponent("Image")
    self.dynasty_rank_text = dynasty_rank_bottom_panel:FindChild("Rank"):GetComponent("Text")
    self.dynasty_rank_creater_name = dynasty_rank_bottom_panel:FindChild("CreaterName"):GetComponent("Text")
    self.dynasty_rank_member_count = dynasty_rank_bottom_panel:FindChild("Count"):GetComponent("Text")
    self.dynasty_rank_score = dynasty_rank_bottom_panel:FindChild("Score"):GetComponent("Text")
end

function DynastyUI:InitUI()
    self.scroll_timer = 0
    self.detail_info_panel:SetActive(false)
    self.dynasty_rank_panel:SetActive(false)
    self.temp_chat:GetComponent("Text").text = ""
    self.dy_chat_data:RegisterNewChatMsgEvent("DynastyUI", self.AddChatMsg ,self)
    self.dy_chat_data:RegisterUpdateUnreadIndexEvent("DynastyUI", self.UpdateUnreadIndex ,self)
    self.dy_dynasty_data:RegisterKickedOutDynastyEvent("DynastyUI", self.Hide, self)
    self.dy_dynasty_data:UpdateDynastyBasicInfo(function (dynasty_info)
        if not self.is_res_ok then return end
        self:InitDynastyInfo(dynasty_info)
    end)
    self:RegisterEvent(self.dy_dynasty_data, "UpdateDynastyInfoEvent", function (_, dynasty_info)
        self.dynasty_info = dynasty_info
        self:InitDynastyInfo(dynasty_info)
    end)
end

function DynastyUI:InitDynastyInfo(dynasty_info)
    UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetDynastyBadgeData(dynasty_info.dynasty_badge).icon, self.dynasty_icon)
    self.dynasty_name.text = string.format(UIConst.Text.DYNASTY_NAME_WITH_LV_FORMAT, dynasty_info.dynasty_name, dynasty_info.dynasty_level)
    local dynasty_level_data = SpecMgrs.data_mgr:GetDynastyData(dynasty_info.dynasty_level)
    self.dynasty_member_count.text = string.format(UIConst.Text.PER_VALUE, dynasty_info.member_count, dynasty_level_data.max_num)
    self.dynasty_score.text = string.format(UIConst.Text.TOTAL_SCORE_FORMAT, UIFuncs.AddCountUnit(dynasty_info.dynasty_score))
end

function DynastyUI:InitDynastyDetailInfo(dynasty_info)
    if not dynasty_info then return end
    self.detail_info_name.text = string.format(UIConst.Text.DYNASTY_NAME_WITH_LV_FORMAT, dynasty_info.dynasty_name, dynasty_info.dynasty_level)
    UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetDynastyBadgeData(dynasty_info.dynasty_badge).icon, self.detail_info_icon)
    local dynasty_level_data = SpecMgrs.data_mgr:GetDynastyData(dynasty_info.dynasty_level)
    self.detail_info_member_count.text = string.format(UIConst.Text.PER_VALUE, dynasty_info.member_count, dynasty_level_data.max_num)
    self.detail_info_score.text = string.format(UIConst.Text.TOTAL_SCORE_FORMAT, UIFuncs.AddCountUnit(dynasty_info.dynasty_score))
    local next_dynasty_level_data = SpecMgrs.data_mgr:GetDynastyData(dynasty_info.dynasty_level + 1)
    if not next_dynasty_level_data then
        self.detail_info_exp.fillAmount = 1
        self.detail_info_exp_value.text = UIConst.Text.DYNASTY_LEVEL_LIMIT
    else
        self.detail_info_exp.fillAmount = (dynasty_info.dynasty_exp - dynasty_level_data.exp)/(next_dynasty_level_data.exp - dynasty_level_data.exp)
        self.detail_info_exp_value.text = string.format(UIConst.Text.PER_VALUE, dynasty_info.dynasty_exp - dynasty_level_data.exp, next_dynasty_level_data.exp - dynasty_level_data.exp)
    end
    self.detail_info_no.text = string.format(UIConst.Text.DYNASTY_NO_FORMAT, dynasty_info.dynasty_id)
    self.detail_info_declaration.text = dynasty_info.dynasty_declaration
    self.detail_info_announcement.text = dynasty_info.dynasty_notice
    self.detail_info_panel:SetActive(true)
end

function DynastyUI:InitDynastyRankList()
    SpecMgrs.msg_mgr:SendGetDynastyRank({}, function (resp)
        if not self.is_res_ok then return end
        local self_dynasty_info = resp.self_dynasty_info
        self.dy_dynasty_data:UpdateDynastyBasicInfo()
        self.dynasty_rank_name.text = string.format(UIConst.Text.DYNASTY_NAME_WITH_LV_FORMAT, self_dynasty_info.dynasty_name, self_dynasty_info.dynasty_level)
        UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetDynastyBadgeData(self_dynasty_info.dynasty_badge).icon, self.dynasty_rank_icon)
        self.dynasty_rank_text.text = resp.self_rank
        self.dynasty_rank_creater_name.text = string.format(UIConst.Text.DYNASTY_CREATER_FORMAT, self_dynasty_info.godfather_name)
        local self_dynasty_level_data = SpecMgrs.data_mgr:GetDynastyData(self_dynasty_info.dynasty_level)
        self.dynasty_rank_member_count.text = string.format(UIConst.Text.PER_VALUE, self_dynasty_info.member_count, self_dynasty_level_data.max_num)
        self.dynasty_rank_score.text = UIFuncs.AddCountUnit(self_dynasty_info.dynasty_score)

        self:ClearDynastyRankItem()
        local count = #resp.dynasty_list
        for i = 1, kFixedRankItemCount do
            self.dynasty_rank_item_list[i]:SetActive(i <= count)
        end
        for rank, dynasty_info in ipairs(resp.dynasty_list) do
            local dynasty_rank_item = rank <= kFixedRankItemCount and self.dynasty_rank_item_list[rank] or self:GetUIObject(self.dynasty_rank_item, self.dynasty_rank_list_content)
            if rank > kFixedRankItemCount then dynasty_rank_item:FindChild("Rank"):GetComponent("Text").text = rank end
            dynasty_rank_item:FindChild("Self"):SetActive(dynasty_info.dynasty_id == self_dynasty_info.dynasty_id)
            UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetDynastyBadgeData(dynasty_info.dynasty_badge).icon, dynasty_rank_item:FindChild("Icon"):GetComponent("Image"))
            dynasty_rank_item:FindChild("Name"):GetComponent("Text").text = string.format(UIConst.Text.DYNASTY_NAME_WITH_LV_FORMAT, dynasty_info.dynasty_name, dynasty_info.dynasty_level)
            dynasty_rank_item:FindChild("CreaterName"):GetComponent("Text").text = string.format(UIConst.Text.DYNASTY_CREATER_FORMAT, dynasty_info.godfather_name)
            dynasty_rank_item:FindChild("Score"):GetComponent("Text").text = UIFuncs.AddCountUnit(dynasty_info.dynasty_score)
            local dynasty_level_data = SpecMgrs.data_mgr:GetDynastyData(dynasty_info.dynasty_level)
            dynasty_rank_item:FindChild("Count"):GetComponent("Text").text = string.format(UIConst.Text.PER_VALUE, dynasty_info.member_count, dynasty_level_data.max_num)
            table.insert(self.dynasty_rank_item_list, dynasty_rank_item)
        end
        self.dynasty_rank_panel:SetActive(true)
    end)
end

function DynastyUI:QuitDynasty()
    local confirm_cb = function ()
        SpecMgrs.msg_mgr:SendQuitDynasty({}, function (resp)
            if resp.errcode ~= 0 then
                SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.QUIT_DYNASTY_FAILED)
            else
                SpecMgrs.ui_mgr:ShowMsgBox(string.format(UIConst.Text.QUIT_DYNASTY_RESULT_FORMAT, self.dynasty_info.dynasty_name))
                self.dy_dynasty_data:SetDynastyId()
                self:Hide()
            end
        end)
    end
    local param_tb = {content = UIConst.Text.QUIT_DYNASTY_REMIND, confirm_cb = confirm_cb}
    SpecMgrs.ui_mgr:ShowMsgSelectBox(param_tb)
end

function DynastyUI:AddChatMsg(_, msg)
    if msg.chat_type == CSConst.ChatType.Dynasty then
        self.chat_msg_queue:Enqueue(msg)
        -- 当前没有聊天或当前聊天消息已超过暂留时间且当前为下一个聊天消息
        if not self.cur_chat_timer then self:NextChat() end
        self.chat_btn:FindChild("RedPoint"):SetActive(true)
    end
end

function DynastyUI:UpdateUnreadIndex()
    local unread_flag = false
    for _, chat_type in pairs(CSConst.ChatType) do
        if chat_type ~= CSConst.ChatType.System then
            unread_flag = self.dy_chat_data:GetUnreadFlagWithType(chat_type)
            if unread_flag then break end
        end
    end
    self.chat_btn:FindChild("RedPoint"):SetActive(unread_flag)
end

function DynastyUI:NextChat()
    local chat_msg = self.chat_msg_queue:Dequeue()
    if not chat_msg then
        --当前聊天消息已超过暂留时间且下一聊天未到达
        self.cur_chat_timer = nil
        return
    end
    local chat_text_cmp = self.cur_chat:GetComponent("TextPic")
    local chat_msg_content = FilterBadWord(chat_msg.content)
    local emoticon_id_list = chat_text_cmp:SetTextWithEllipsis(string.format(UIConst.Text.CHAT_CONTENT, chat_msg.sender_vip, chat_msg.sender_name, chat_msg_content))
    for _, emoticon_go in ipairs(self.cur_emoticon_list) do
        self:DelUIObject(emoticon_go)
    end
    self.cur_emoticon_list = {}
    for i = 0, emoticon_id_list.Length - 1 do
        local emoticon_go = self:GetUIObject(self.emoticon_item, self.cur_chat)
        local emoticon_img_cmp = emoticon_go:GetComponent("Image")
        UIFuncs.AssignUISpriteSync("UIRes/Emoticon/Normal/" .. emoticon_id_list[i], emoticon_id_list[i], emoticon_img_cmp)
        emoticon_img_cmp:SetNativeSize()
        emoticon_go:SetActive(false)
        table.insert(self.cur_emoticon_list, emoticon_go)
    end
    self:AddTextPicPopulateMesh(self.cur_chat, function ()
        local emoticon_pos_list = chat_text_cmp.ImgPosList
        for i = 0, self.cur_chat.childCount - 1 do
            local emoticon_go = self.cur_chat:GetChild(i)
            emoticon_go.localPosition = Vector3.New(emoticon_pos_list[2 * i], emoticon_pos_list[2 * i + 1])
            emoticon_go:SetActive(true)
        end
        self:RemoveTextPicPopulateMesh(self.cur_chat)
    end)

    self.cur_chat_target_pos_y = self.cur_chat_pos.y + self.chat_height
    self.temp_chat_target_pos_y = self.temp_chat_pos.y + self.chat_height
    self.scroll_chat = true
    self.cur_chat_timer = self.chat_msg_interval
end

function DynastyUI:Update(delta_time)
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

function DynastyUI:ClearDynastyRankItem()
    for i = kFixedRankItemCount, #self.dynasty_rank_item_list do
        self:DelUIObject(table.remove(self.dynasty_rank_item_list, kFixedRankItemCount + 1))
    end
end

return DynastyUI