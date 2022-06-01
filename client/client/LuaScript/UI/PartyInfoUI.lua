local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local PartyInfoUI = class("UI.PartyInfoUI", UIBase)
local UnitConst = require("Unit.UnitConst")
local UIFuncs = require("UI.UIFuncs")

PartyInfoUI.need_sync_load = true

function PartyInfoUI:DoInit()
    PartyInfoUI.super.DoInit(self)
    self.prefab_path = "UI/Common/PartyInfoUI"
    self.dy_party_data = ComMgrs.dy_data_mgr.party_data
    self.guest_go_list = {}
end

function PartyInfoUI:OnGoLoadedOk(res_go)
    PartyInfoUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function PartyInfoUI:Show(party_info)
    self.party_info = party_info
    if self.is_res_ok then
        self:InitUI()
    end
    PartyInfoUI.super.Show(self)
end

function PartyInfoUI:InitRes()
    UIFuncs.GetInitTopBar(self, self.main_panel, "PartyInfoPanel")

    self.unit_parent = self.main_panel:FindChild("Lover/UnitParent")

    self.party_id_text = self.main_panel:FindChild("PartyInfo/PartyId"):GetComponent("Text")
    self.guest_num_text = self.main_panel:FindChild("PartyInfo/GuestNum"):GetComponent("Text")

    local guest_list_go = self.main_panel:FindChild("GuestList")
    self.guest_go_parent = guest_list_go:FindChild("Viewport/Content")
    self.guest_go_temp = self.guest_go_parent:FindChild("Temp")
    self.guest_go_temp:SetActive(false)

    local title = guest_list_go:FindChild("Title")
    title:FindChild("Player/Text"):GetComponent("Text").text = UIConst.Text.PLAYER_TEXT
    title:FindChild("Server/Text"):GetComponent("Text").text = UIConst.Text.PLAYER_SERVER
    title:FindChild("Gift/Text"):GetComponent("Text").text = UIConst.Text.PARTY_GIFT

    local middle_btn_list = self.main_panel:FindChild("MiddleBtnList")
    self.invite_btn = middle_btn_list:FindChild("InviteBtn")
    self.invite_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.INVITE_FRIEND
    self:AddClick(self.invite_btn, function()
        self:InviteBtnOnClick()
    end)

    self.get_party_point_btn = middle_btn_list:FindChild("GetPartyPointBtn")
    self.get_party_point_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.PARTY_COMMEND_LOVER
    self:AddClick(self.get_party_point_btn, function()
        self:GetPartyPointBtnOnClick()
    end)

    self.join_party_btn = middle_btn_list:FindChild("JoinPartyBtn")
    self.join_party_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.JOIN
    self:AddClick(self.join_party_btn, function()
        self:JoinPartyBtnOnClick()
    end)

    self.start_game_btn = middle_btn_list:FindChild("StartGameBtn")
    self.start_game_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.START_PARTY_GMAE
    self:AddClick(self.start_game_btn, function()
        self:StartGameBtnOnClick()
    end)

    self.talk_parent = self.main_panel:FindChild("Talk")

    local party_info = self.main_panel:FindChild("Tip")
    self.party_info_go = party_info:FindChild("MyPartyInfo")
    self.top_lover_name_text = self.party_info_go:FindChild("Lover/Name"):GetComponent("Text")
    self.top_lover_level_text = self.party_info_go:FindChild("Lover/Level"):GetComponent("Text")
    self.top_add_point_ratio_text = self.party_info_go:FindChild("ScoreAddRatio"):GetComponent("Text")
    self.top_point_can_get_text = self.party_info_go:FindChild("Score"):GetComponent("Text")
    self.other_party_go = party_info:FindChild("OtherPartyInfo")
    self.other_party_info_text = self.other_party_go:FindChild("Text"):GetComponent("Text")
    local bottom_bar = self.main_panel:FindChild("BottomBar")
    self.remain_time_go = bottom_bar:FindChild("RemainTime")
    self.remain_time_text = bottom_bar:FindChild("RemainTime"):GetComponent("Text")
    self.end_party_btn = bottom_bar:FindChild("EndPartyBtn")
    self.end_party_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.END_PARTY
    self:AddClick(self.end_party_btn, function()
        self:EndPartyBtnOnClick()
    end)
end


function PartyInfoUI:Update(delta_time)
    if not self.count_down_data then return end
    local reamin_time = UIFuncs.GetReaminTime(self.count_down_data.start_time, self.count_down_data.max_cool_time)
    local remain_time_str
    if reamin_time > 0 then
        remain_time_str = UIFuncs.GetCountDownDayStr(reamin_time)
        remain_time_str = string.format(UIConst.Text.REMAIN_TIME, remain_time_str)
        self.count_down_data.text.text = remain_time_str
    else
        remain_time_str = UIConst.Text.PARTY_ALREADY_END_WITH_COLOR
        self.count_down_data.text.text = remain_time_str
        self.count_down_data = nil
    end
end

function PartyInfoUI:InitUI()
    self.dy_party_data:RegisterUpdatePartyInfo(self.class_name, function (_, party_info)
        if party_info.party_id and party_info.party_id == self.party_info.party_id then
            self.party_info = party_info
            self:UpdatePanel()
        end
    end)
    self:UpdatePanel()
    self:ClearTalkCmp()
    self.talk_cmp = self:GetTalkCmp(self.talk_parent, 2, false, self.GetTalkStr)
    self.dy_party_data:SendGetPartyInfo(self.party_info.party_id)
end

function PartyInfoUI:UpdatePanel()
    if not self.party_info then return end
    self:UpdateCache()
    self:UpdateBtn()
    self:UpdateUnit()
    self:UpdatePartyInfo()
    self:UpdateGuest()
    self:UpdateTalk()
end

function PartyInfoUI:GetTalkStr()
    local str
    local party_info = self.party_info
    local end_type = party_info.end_type
    local end_type_dict = CSConst.Party.EndType
    if self.is_my_party then
        if end_type then
            if end_type == end_type_dict.EnemyEnd then
                local enemy_name = party_info.enemy_info.role_info.name
                str = string.format(UIConst.Text.PARTY_ALREADY_END_BY_ENEMY, enemy_name)
            elseif self.dy_party_data:IsPartyFull(self.party_info) then
                str = UIConst.Text.PARTY_GUEST_FULL
            else
                str = UIConst.Text.PARTY_GUEST_NOT_FULL
            end
        else
            str = UIConst.Text.PARTY_NOT_END
        end
    elseif self.my_guest_info then
        if end_type then
            if end_type == end_type_dict.EnemyEnd then
                local enemy_name = party_info.enemy_info.role_info.name
                str = string.format(UIConst.Text.PARTY_ALREADY_END_BY_ENEMY, enemy_name)
            elseif end_type == end_type_dict.HostEnd then
                str = UIConst.Text.PARTY_ALREADY_END_BY_HOST
            else
                str = UIConst.Text.PARTY_ALREADY_END
            end
        else
            str = string.format(UIConst.Text.WELCOM_TO_WHOS_PARTY, party_info.host_info.name)
        end
    else
        str = UIConst.Text.WELCOM_TO_PARTY
    end
    return str
end

function PartyInfoUI:UpdateTalk()
    if self.talk_cmp then
        self.talk_cmp:UpdateTalkContent()
    end
end

function PartyInfoUI:UpdatePartyInfo()
    local is_show_party_info = (self.is_my_party or self.my_guest_info) and true or false
    local party_info = self.party_info
    self.party_info_go:SetActive(is_show_party_info)
    self.other_party_go:SetActive(not is_show_party_info)
    self.party_id_text.text = string.format(UIConst.Text.PARTY_ID, party_info.party_id)
    if self.is_my_party then
        local lover_id = party_info.lover_id
        local lover_name = SpecMgrs.data_mgr:GetLoverData(lover_id).name
        self.top_lover_name_text.text = lover_name
        local serv_lover_data = ComMgrs.dy_data_mgr.lover_data:GetServLoverDataById(lover_id)
        local point_add_ratio = math.floor(self.dy_party_data:GetLoverPartyPointAddRatio(serv_lover_data.level) * 100)
        self.top_lover_level_text.text = serv_lover_data.level
        self.top_add_point_ratio_text.text = string.format(UIConst.Text.POINT_ADD_RATIO, point_add_ratio)
        local _, base_point, add_point = self.dy_party_data:GetPartyPoint(party_info)
        self.top_point_can_get_text.text = string.format(UIConst.Text.PARTY_POINT_CAN_GET, base_point, add_point)
    elseif self.my_guest_info then
        local lover_id = self.my_guest_info.lover_id
        local lover_name = SpecMgrs.data_mgr:GetLoverData(lover_id).name
        self.top_lover_name_text.text = string.format(UIConst.Text.JOIN_PARTY_LOVER_NAME, lover_name)
        local serv_lover_data = ComMgrs.dy_data_mgr.lover_data:GetServLoverDataById(lover_id)
        local point_add_ratio = math.floor(self.dy_party_data:GetLoverPartyPointAddRatio(serv_lover_data.level) * 100)
        self.top_lover_level_text.text = serv_lover_data.level
        self.top_add_point_ratio_text.text = string.format(UIConst.Text.POINT_ADD_RATIO, point_add_ratio)
        self.top_point_can_get_text.text = string.format(UIConst.Text.PARTY_POINT_ALREADY_GET, self.my_guest_info.integral)
    else
        self.other_party_info_text.text = string.format(UIConst.Text.WHO_TEH_PARTY_BELONG, party_info.host_info.name)
    end
    local str
    local reamin_time = UIFuncs.GetReaminTime(party_info.start_time, self.party_type_data.time)
    if self.is_party_end or reamin_time <= 0 then
        self.count_down_data = nil
        str = UIConst.Text.PARTY_ALREADY_END_WITH_COLOR
    else
        str = UIFuncs.GetCountDownDayStr(reamin_time)
        str = string.format(UIConst.Text.REMAIN_TIME, str)
        self.count_down_data = {text = self.remain_time_text, start_time = party_info.start_time, max_cool_time = self.party_type_data.time}
    end
    self.remain_time_text.text = str
end

function PartyInfoUI:UpdateCache()
    local party_info = self.party_info
    self.is_my_party = self.dy_party_data:IsMyParty(party_info)
    if not self.is_my_party then
        self.my_guest_info = self.dy_party_data:GetMyGuestInfoByPartyInfo(party_info)
    end
    self.is_party_end = self.dy_party_data:IsPartyEnd(party_info)
    self.party_type_data = SpecMgrs.data_mgr:GetPartyData(party_info.party_type_id)
end

function PartyInfoUI:UpdateBtn()
    self.invite_btn:SetActive(self.is_my_party and not self.is_party_end)
    self.end_party_btn:SetActive(self.is_my_party and not self.is_party_end)
    self.get_party_point_btn:SetActive(self.is_my_party and self.is_party_end) -- 自己宴会结束
    self.start_game_btn:SetActive(not self.is_party_end and not self.is_my_party and self.my_guest_info and true or false) -- 已赴宴未完成游戏
    self.join_party_btn:SetActive(not self.is_party_end and not self.is_my_party and not self.my_guest_info and true or false) -- 未赴宴
end

function PartyInfoUI:UpdateGuest()
    local guest_info_list = self.party_info.guests_list
    self:ClearGoDict("guest_go_list")
    local cur_guest_num = #guest_info_list
    local max_guest_num = self.party_type_data.guests_max_num
    local str = string.format(UIConst.Text.SPRIT, cur_guest_num, max_guest_num)
    self.guest_num_text.text = str
    for _, guest_info in ipairs(guest_info_list) do
        local go = self:GetUIObject(self.guest_go_temp, self.guest_go_parent)
        self:InitGuestGo(go, guest_info)
        table.insert(self.guest_go_list, go)
    end
end

function PartyInfoUI:InitGuestGo(go, guest_info)
    go:FindChild("Player/Text"):GetComponent("Text").text = guest_info.role_info.name
    local server_data = SpecMgrs.data_mgr:GetServerData(guest_info.role_info.server_id)
    local guest_gift_data = SpecMgrs.data_mgr:GetPartyGiftData(guest_info.gift_id)
    go:FindChild("Server/Text"):GetComponent("Text").text = server_data.name
    go:FindChild("Gift/Text"):GetComponent("Text").text = guest_gift_data.cost_item_count_list[1]
end

function PartyInfoUI:UpdateUnit()
    local unit_id = SpecMgrs.data_mgr:GetLoverData(self.party_info.lover_id).unit_id
    if self.unit_id and self.unit_id == unit_id then return end
    self:ClearUnit("unit")
    self.unit_id = unit_id
    self.unit = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = unit_id, parent = self.unit_parent})
    self.unit:SetPositionByRectName({parent = self.unit_parent, name = UnitConst.UnitRect.Full})
end

function PartyInfoUI:Hide()
    self.dy_party_data:UnregisterUpdatePartyInfo(self.class_name)
    self:ClearTalkCmp()
    self:ClearUnit("unit")
    self.unit_id = nil
    self:ClearGoDict("guest_go_list")
    self.is_my_party = nil
    self.my_guest_info = nil
    self.is_party_end = nil
    PartyInfoUI.super.Hide(self)
end

function PartyInfoUI:ClearTalkCmp()
    if self.talk_cmp then
        self.talk_cmp:DoDestroy()
        self.talk_cmp = nil
    end
end

function PartyInfoUI:InviteBtnOnClick()
    SpecMgrs.ui_mgr:ShowUI("PartyInviteUI")
end

function PartyInfoUI:GetPartyPointBtnOnClick()
    if not self.is_my_party then return end
    SpecMgrs.msg_mgr:SendPartyReceiveIntegral({}, function (resp)
        if resp.errcode ~= 0 then
            PrintError("Get wrong errcode from serv in SendPartyReceiveIntegral")
            return
        end
        self:Hide()
    end)
end

function PartyInfoUI:JoinPartyBtnOnClick()
    if self.is_my_party then return end
    if not self.dy_party_data:CanJoinParty(self.party_info, true) then
        return
    end
    SpecMgrs.ui_mgr:ShowUI("JoinPartyUI", self.party_info)
end

function PartyInfoUI:EndPartyBtnOnClick()
    if not self.is_my_party then return end
    local confirm_cb = function ()
        self:SendPartyEnd()
    end
    local param_tb = {content = UIConst.Text.PARTY_END_TIP, confirm_cb = confirm_cb}
    SpecMgrs.ui_mgr:ShowMsgSelectBox(param_tb)
end

function PartyInfoUI:SendPartyEnd()
    SpecMgrs.msg_mgr:SendPartyEnd({}, function (resp)
        if resp.errcode ~= 0 then
            PrintError("Get wrong errcode from serv in SendPartyEnd", self.party_info)
        end
    end)
end

function PartyInfoUI:StartGameBtnOnClick()
    if self.is_my_party then return end
    if not self.dy_party_data:CanStartGame(true) then
        return
    end
    SpecMgrs.ui_mgr:ShowUI("SelectPartyGameUI")
end

return PartyInfoUI