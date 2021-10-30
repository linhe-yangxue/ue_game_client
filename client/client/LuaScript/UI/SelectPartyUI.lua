local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local SelectPartyUI = class("UI.SelectPartyUI", UIBase)
local UnitConst = require("Unit.UnitConst")
local UIFuncs = require("UI.UIFuncs")

SelectPartyUI.need_sync_load = true

function SelectPartyUI:DoInit()
    SelectPartyUI.super.DoInit(self)
    self.prefab_path = "UI/Common/SelectPartyUI"
    self.party_type_data_list = SpecMgrs.data_mgr:GetAllPartyData()
    self.dy_party_data = ComMgrs.dy_data_mgr.party_data
    self.random_party_id_to_go = {}
    self.search_party_id_to_go = {}
    self.party_id_to_count_down_data = {} -- {text =  , start_time = , max_cool_time = }
end

function SelectPartyUI:OnGoLoadedOk(res_go)
    SelectPartyUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function SelectPartyUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    SelectPartyUI.super.Show(self)
end

function SelectPartyUI:Update(delta_time)
    if not next(self.party_id_to_count_down_data) then return end
    local remove_list = {}
    for k, v in pairs(self.party_id_to_count_down_data) do
        local reamin_time = UIFuncs.GetReaminTime(v.start_time, v.max_cool_time)
        local remain_time_str
        if reamin_time > 0 then
            remain_time_str = UIFuncs.GetCountDownDayStr(reamin_time)
        else
            remain_time_str = UIConst.Text.PARTY_ALREADY_END_WITH_COLOR
        end
        v.text.text = remain_time_str
        if reamin_time <= 0 then
            table.insert(remove_list, k)
        end
    end
    for _, party_id in ipairs(remove_list) do
        self.party_id_to_count_down_data[party_id] = nil
    end
end

function SelectPartyUI:InitRes()
    UIFuncs.GetInitTopBar(self, self.main_panel, "SelectPartyPanel")

    local content_go = self.main_panel:FindChild("Content")
    self.random_party_part_go = content_go:FindChild("RandomParty")
    self.random_party_go_parent = self.random_party_part_go:FindChild("Viewport/ItemList")
    self.party_go_temp = self.random_party_go_parent:FindChild("Item")
    self.party_go_temp:SetActive(false)
    self.party_go_temp:FindChild("Right/CheckBtn/Text"):GetComponent("Text").text = UIConst.Text.CHECK
    self.party_go_temp:FindChild("Right/Text"):GetComponent("Text").text = string.format(UIConst.Text.COLON, UIConst.Text.REMAIN_TIME1)
    UIFuncs.GetIconGo(self, self.party_go_temp:FindChild("LoverIcon"), nil, UIConst.PrefabResPath.LoverIcon)
    self.search_party_part_go = content_go:FindChild("SearchParty")
    self.search_party_part_go:FindChild("Tip"):GetComponent("Text").text = UIConst.Text.SEARCH_PARTY
    self.search_input_field = self.main_panel:FindChild("Content/SearchParty/InputField"):GetComponent("InputField")
    self.search_party_btn = self.search_party_part_go:FindChild("SearchPartyBtn")
    self.search_party_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.INQUIRE
    self:AddClick(self.search_party_btn, function()
        self:SearchPartyBtnOnClick()
    end)
    self.search_party_go_parent = self.search_party_part_go:FindChild("Viewport/ItemList")
    self.show_random_party_btn = self.main_panel:FindChild("SelectBtnList/RandomParty")
    self.show_random_party_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.RANDOM_PARTY_TEXT
    self.show_random_party_btn:FindChild("Selected/Text"):GetComponent("Text").text = UIConst.Text.RANDOM_PARTY_TEXT
    self:AddClick(self.show_random_party_btn, function()
        self:ShowRandomPartyPanel()
    end)
    self.show_search_party_btn = self.main_panel:FindChild("SelectBtnList/SearchParty")
    self.show_search_party_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SEARCH_PARTY_TEXT
    self.show_search_party_btn:FindChild("Selected/Text"):GetComponent("Text").text = UIConst.Text.SEARCH_PARTY_TEXT
    self:AddClick(self.show_search_party_btn, function()
        self:ShowSearchPartyPanel()
    end)
    self.no_party_go = self.main_panel:FindChild("Content/RandomParty/NoParty")
    self.no_party_go:GetComponent("Text").text = UIConst.Text.NO_PARTY
end

function SelectPartyUI:InitUI()
    self.dy_party_data:RegisterUpdatePartyRandom("SelectPartyUI", function(_, party_list)
        self.party_info_list = party_list
        self:UpdateRandomPartyPart()
    end)
    self:RegisterEvent(SpecMgrs.ui_mgr, "HideUIEvent", function ()
        self.dy_party_data:SendGetPartyRandom()
    end)
    self.dy_party_data:SendGetPartyRandom()
    self:ShowRandomPartyPanel()
end

function SelectPartyUI:UpdateRandomPartyPart()
    self:ClearPartyGo("random_party_id_to_go")
    self.no_party_go:SetActive(not next(self.party_info_list) and true or false)
    for _, party_info in ipairs(self.party_info_list) do
        if not self.dy_party_data:GetMyGuestIndex(party_info) then -- 筛除已经参加过的派对
            local go = self:GetUIObject(self.party_go_temp, self.random_party_go_parent)
            self.random_party_id_to_go[party_info.party_id] = go
            self:InitPartyGo(go, party_info)
        end
    end
end

function SelectPartyUI:Hide()
    self.dy_party_data:UnregisterUpdatePartyRandom("SelectPartyUI")
    self:ClearPartyGo("random_party_id_to_go")
    self:ClearPartyGo("search_party_id_to_go")
    self.party_id_to_count_down_data = {}
    SelectPartyUI.super.Hide(self)
end

function SelectPartyUI:ClearPartyGo(part_id_to_go_name)
    local party_id_to_go = self[part_id_to_go_name]
    for party_id, go in pairs(party_id_to_go) do
        self.party_id_to_count_down_data[party_id] = nil
        self:DelUIObject(go)
    end
end

function SelectPartyUI:InitPartyGo(go, party_info)
    local party_info_go = go:FindChild("PartyInfo")
    party_info_go:FindChild("PartyName"):GetComponent("Text").text = string.format(UIConst.Text.WHO_TEH_PARTY_BELONG, party_info.host_info.name)
    party_info_go:FindChild("PartyId"):GetComponent("Text").text = string.format(UIConst.Text.PARTY_ID, party_info.party_id)
    local max_guest_num = self.party_type_data_list[party_info.party_type_id].guests_max_num
    party_info_go:FindChild("GuestNum"):GetComponent("Text").text = string.format(UIConst.Text.GUEST_NUM, #party_info.guests_list, max_guest_num)
    local remain_time_str
    local party_type_data = self.party_type_data_list[party_info.party_type_id]
    local text = go:FindChild("Right/Time"):GetComponent("Text")
    if party_info.end_type then
        remain_time_str = UIConst.Text.PARTY_ALREADY_END_WITH_COLOR
    else
        local reamin_time = UIFuncs.GetReaminTime(party_info.start_time, party_type_data.time)
        if reamin_time > 0 then
            remain_time_str = UIFuncs.GetCountDownDayStr(reamin_time)
            remain_time_str = string.format(UIConst.Text.REMAIN_TIME, remain_time_str)
            self.party_id_to_count_down_data[party_info.party_id] = {text = text, start_time = party_info.start_time, max_cool_time = party_type_data.time}
        else
            remain_time_str = UIConst.Text.PARTY_ALREADY_END_WITH_COLOR
        end
    end
    text.text = remain_time_str

    local lover_data = SpecMgrs.data_mgr:GetLoverData(party_info.lover_id)
    UIFuncs.InitLoverGo({lover_data = lover_data, go = go:FindChild("LoverIcon/Item")})
    go:FindChild("PartyInfo/LoverLevel/Text/Text"):GetComponent("Text").text = party_info.lover_level
    self:AddClick(go:FindChild("Right/CheckBtn"), function()
        self:CheckPartyOnClick(party_info)
    end)
end

function SelectPartyUI:SearchPartyBtnOnClick()
    local uuid = self.search_input_field.text
    if uuid == "" then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.PLEASE_INPUT_PLAYER_ID)
        return
    end
    SpecMgrs.msg_mgr:SendFindParty({uuid = uuid}, function (resp)
        local party_info = resp.party_info
        if resp.errcode ~= 0 or not party_info then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.PALAER_DO_NOT_HAVE_PARTY)
        else
            self:ClearPartyGo("search_party_id_to_go")
            local go = self:GetUIObject(self.party_go_temp, self.search_party_go_parent)
            self:InitPartyGo(go, party_info)
            self.search_party_id_to_go[party_info.party_id] = go
        end
    end)
end

function SelectPartyUI:ShowRandomPartyPanel()
    self:HideSearchPartyPanel()
    self.show_random_party_btn:FindChild("Selected"):SetActive(true)
    self.random_party_part_go:SetActive(true)
end

function SelectPartyUI:HideRandomPartyPanel()
    self.random_party_part_go:SetActive(false)
    self.show_random_party_btn:FindChild("Selected"):SetActive(false)
end

function SelectPartyUI:ShowSearchPartyPanel()
    self:HideRandomPartyPanel()
    self.search_party_part_go:SetActive(true)
    self.show_search_party_btn:FindChild("Selected"):SetActive(true)
    self.search_input_field.text = nil
end

function SelectPartyUI:HideSearchPartyPanel()
    self.search_party_part_go:SetActive(false)
    self.show_search_party_btn:FindChild("Selected"):SetActive(false)
end

function SelectPartyUI:CheckPartyOnClick(party_info)
    SpecMgrs.ui_mgr:ShowUI("PartyInfoUI", party_info)
end

return SelectPartyUI