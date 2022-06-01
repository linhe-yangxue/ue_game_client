local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local HoldPartyUI = class("UI.HoldPartyUI", UIBase)
local UnitConst = require("Unit.UnitConst")
local UIFuncs = require("UI.UIFuncs")

HoldPartyUI.need_sync_load = true
local default_select_party_id = 1
local default_privite_staus = false
function HoldPartyUI:DoInit()
    HoldPartyUI.super.DoInit(self)
    self.prefab_path = "UI/Common/HoldPartyUI"
    self.party_data_list = SpecMgrs.data_mgr:GetAllPartyData()
    self.dy_party_data = ComMgrs.dy_data_mgr.party_data
    self.lover_id_to_go = {}
end

function HoldPartyUI:OnGoLoadedOk(res_go)
    HoldPartyUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function HoldPartyUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    HoldPartyUI.super.Show(self)
end

function HoldPartyUI:InitRes()
    UIFuncs.GetInitTopBar(self, self.main_panel, "HoldPartyPanel")

    local top_part = self.main_panel:FindChild("TopPart")
    self.lover_unit_parent = top_part:FindChild("Lover/UnitParent")
    local right_go = top_part:FindChild("Right")
    right_go:FindChild("Title"):GetComponent("Text").text = UIConst.Text.HOLD_PARTY
    local party_type_parent = right_go:FindChild("PartyTypeList")
    local party_type_temp = party_type_parent:FindChild("Temp")
    party_type_temp:SetActive(false)
    self.party_type_go_list = {}
    for i, v in ipairs(self.party_data_list) do
        local go = self:GetUIObject(party_type_temp, party_type_parent)
        local first_cost_item_id = v.cost_item_list[1]
        local item_data = SpecMgrs.data_mgr:GetItemData(first_cost_item_id)
        self:AssignSpriteByIconID(item_data.icon, go:FindChild("Toggle/Image"):GetComponent("Image"))
        go:FindChild("Toggle/Label"):GetComponent("Text").text = string.format(UIConst.Text.COUNT, v.cost_item_count_list[1])
        self.party_type_go_list[i] = go
        go:FindChild("Toggle"):GetComponent("Toggle").isOn = false
        self:AddToggle(go:FindChild("Toggle"), function (isOn)
            if isOn then
                self:PartyTypeOnToggle(i)
            end
        end)
        go:FindChild("Text"):GetComponent("Text").text = string.format(UIConst.Text.PARTY_TITLE_WITH_JOIN_NUM, v.name, v.guests_max_num)
    end
    local bottme1_go = right_go:FindChild("Bottom1")
    self.private_party_toggle = bottme1_go:FindChild("PrivatePartyToggle"):GetComponent("Toggle")
    self:AddToggle(self.private_party_toggle.gameObject, function (isOn)
        self.is_private_party = isOn
    end)
    self.private_party_toggle.gameObject:FindChild("Background/Label"):GetComponent("Text").text = UIConst.Text.PRIVATE_PARTY
    self.second_cost_item_go = bottme1_go:FindChild("CastItem")

    self.init_point_text = bottme1_go:FindChild("InitPoint"):GetComponent("Text")
    self.point_add_ratio_text = bottme1_go:FindChild("PointAddRatio"):GetComponent("Text")

    self.start_party_btn = right_go:FindChild("Bottom2/StartPartyBtn")
    self.start_party_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.START_PARTY
    self:AddClick(self.start_party_btn, function()
        self:StartPartyBtnOnClick()
    end)

    local title = self.main_panel:FindChild("LoverList/Title")
    title:FindChild("Lover/Text"):GetComponent("Text").text = UIConst.Text.LOVER
    title:FindChild("Level/Text"):GetComponent("Text").text = UIConst.Text.LOVER_LEVEL
    title:FindChild("Score/Text"):GetComponent("Text").text = UIConst.Text.POINT_EARN
    self.lover_go_parent = self.main_panel:FindChild("LoverList/Viewport/Content")
    self.lover_go_temp = self.lover_go_parent:FindChild("Temp")
    self.lover_go_temp:FindChild("Resting/Text"):GetComponent("Text").text = UIConst.Text.RESTING
    self.lover_go_temp:SetActive(false)
    self.lover_go_temp:FindChild("Level/Item/Name"):GetComponent("Text").text = UIConst.Text.LOVER_LEVEL
    top_part:FindChild("Tip/Text"):GetComponent("Text").text = UIConst.Text.SELECT_WHICH_LOVER_TO_HOLD_PARTY
end

function HoldPartyUI:InitUI()
    self:RegisterEvent(ComMgrs.dy_data_mgr, "UpdateCurrencyEvent", function (_, currency)
        UIFuncs.UpdateCurrencyItemNum(self._item_to_text_list, currency)
    end)
    self:RegisterEvent(ComMgrs.dy_data_mgr.bag_data, "UpdateBagItemEvent", function (_, _, item)
        if item.item_id == self.cur_party_type_data.cost_item_list[2] then
            self:UpdatePartyCostItemCount()
        end
    end)
    for i, go in ipairs(self.party_type_go_list) do
        go:FindChild("Toggle"):GetComponent("Toggle").isOn = i == default_select_party_id
    end
    self.private_party_toggle.isOn = default_privite_staus
    self.is_private_party = default_privite_staus
    self:PartyTypeOnToggle(default_select_party_id)
    self:UpdateLoverListCache()
end

function HoldPartyUI:_UpdateLoverUnit(unit_id)
    if self.lover_unit_id and self.lover_unit_id == unit_id then return end
    self:CleanLoverUnit()
    self.lover_unit_id = unit_id
    self.lover_unit = self:AddFullUnit(unit_id, self.lover_unit_parent)
end

function HoldPartyUI:CleanLoverUnit()
    if self.lover_unit then
        ComMgrs.unit_mgr:DestroyUnit(self.lover_unit)
        self.lover_unit = nil
        self.lover_unit_id = nil
    end
end

function HoldPartyUI:Hide()
    self:ClearAllLoverGo()
    self:CleanLoverUnit()
    self.wait_for_serv_cb = nil
    HoldPartyUI.super.Hide(self)
end

function HoldPartyUI:PartyTypeOnToggle(party_type_id)
    local party_type_data = SpecMgrs.data_mgr:GetPartyData(party_type_id)
    self.cur_party_type_data = party_type_data
    local item_id = party_type_data.cost_item_list[2]
    local item_data = SpecMgrs.data_mgr:GetItemData(item_id)
    self:UpdatePartyCostItemCount()
    UIFuncs.AssignSpriteByIconID(item_data.icon,  self.second_cost_item_go:FindChild("Image"):GetComponent("Image"))
    self.second_cost_item_go:FindChild("Text"):GetComponent("Text").text = string.format(UIConst.Text.COST_ITEM, item_data.name)
    self.init_point_text.text = string.format(UIConst.Text.INIT_PARTY_POINT, party_type_data.init_party_point)
end

function HoldPartyUI:UpdatePartyCostItemCount()
    local item_id = self.cur_party_type_data.cost_item_list[2]
    local cur_count = ComMgrs.dy_data_mgr:ExGetItemCount(item_id)
    local need_count = self.cur_party_type_data.cost_item_count_list[2]
    local str = UIFuncs.GetPerStr(cur_count, need_count, cur_count >= need_count)
    self.second_cost_item_go:FindChild("Image/Text"):GetComponent("Text").text = str
end

function HoldPartyUI:StartPartyBtnOnClick()
    if self.wait_for_serv_cb then return end
    local party_data = self.cur_party_type_data
    local lover_id = self.cur_lover_id
    if not self.dy_party_data:CheckLoverCanHoldParty(lover_id, true) then return end
    if not UIFuncs.CheckItemCountByList(party_data.cost_item_list, party_data.cost_item_count_list, true) then
        return
    end
    local party_type_id = party_data.id
    local is_private = self.is_private_party
    local item_dict = {}
    for i, item_id in pairs(party_data.cost_item_list) do
        item_dict[item_id] = party_data.cost_item_count_list[i]
    end

    local desc = UIFuncs.GetCastItemStr(item_dict, UIConst.Text.HOLD_PARTY)
    local param_tb = {
        item_dict = item_dict,
        desc = desc,
        title = UIConst.Text.HOLD_PARTY,
        confirm_cb = function()
            self:SendPartyStart(lover_id, party_type_id, is_private)
        end,
    }
    SpecMgrs.ui_mgr:ShowItemUseRemindByTb(param_tb)
end

function HoldPartyUI:SendPartyStart(lover_id, party_type_id, is_private)
    if self.wait_for_serv_cb then return end
    self.wait_for_serv_cb = function (party_info)
        SpecMgrs.ui_mgr:HideUI(self)
        local party_info = self.dy_party_data:GetMyPartyInfo()
        SpecMgrs.ui_mgr:ShowUI("PartyInfoUI", party_info)
    end
    local param_tb = {lover_id = lover_id, party_type_id = party_type_id, is_private}
    SpecMgrs.msg_mgr:SendPartyStart(param_tb, function(resp)
        if resp.errcode ~= 1 then
            if self.wait_for_serv_cb then
                self.wait_for_serv_cb(resp.party_info)
            end
        else
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.PARTY_ONLY_ONE)
        end
    end)
end

function HoldPartyUI:UpdateLoverListCache()
    self.lover_data_list = self.dy_party_data:GetPartyLoverList(true)
    self:ClearAllLoverGo()
    for i, serv_lover_data in ipairs(self.lover_data_list) do
        local go = self:GetUIObject(self.lover_go_temp, self.lover_go_parent)
        self.lover_id_to_go[serv_lover_data.lover_id] = go
        local native_lover_data = SpecMgrs.data_mgr:GetLoverData(serv_lover_data.lover_id)
        go:FindChild("Lover/Text"):GetComponent("Text").text = native_lover_data.name
        go:FindChild("Selected"):SetActive(false)
        go:FindChild("Level/Item/Num"):GetComponent("Text").text = serv_lover_data.level

        local point_add_ratio = math.floor(self.dy_party_data:GetLoverPartyPointAddRatio(serv_lover_data.level) * 100)
        go:FindChild("Score/Text"):GetComponent("Text").text = string.format(UIConst.Text.EXTRA_POINT_ADD_RATIO, point_add_ratio)
        self:AddClick(go, function ()
            self:LoverGoOnClick(serv_lover_data, native_lover_data)
        end)
        local is_show_resting = not self.dy_party_data:CheckLoverCanHoldParty(serv_lover_data.lover_id)
        go:FindChild("Resting"):SetActive(is_show_resting)
    end
    self:LoverGoOnClick(self.lover_data_list[1])
end

function HoldPartyUI:ClearAllLoverGo()
    for _, go in pairs(self.lover_id_to_go) do
        self:DelUIObject(go)
    end
    self.lover_id_to_go = {}
    self.cur_lover_id = nil
end

function HoldPartyUI:LoverGoOnClick(serv_lover_data, native_lover_data)
    local lover_id = serv_lover_data.lover_id
    if self.cur_lover_id and self.cur_lover_id == lover_id then return end
    if self.cur_lover_id then
        self.lover_id_to_go[self.cur_lover_id]:FindChild("Selected"):SetActive(false)
    end
    local native_lover_data = native_lover_data or SpecMgrs.data_mgr:GetLoverData(lover_id)
    self.cur_lover_id = lover_id
    local go = self.lover_id_to_go[lover_id]
    go:FindChild("Selected"):SetActive(true)
    local point_add_ratio = math.floor(ComMgrs.dy_data_mgr.party_data:GetLoverPartyPointAddRatio(serv_lover_data.level) * 100)
    self.point_add_ratio_text.text = string.format(UIConst.Text.POINT_ADD_RATIO, point_add_ratio)
    self:_UpdateLoverUnit(native_lover_data.unit_id)
end

return HoldPartyUI