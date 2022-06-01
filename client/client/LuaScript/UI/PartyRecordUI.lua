local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local TabViewCmp = require("UI.UICmp.TabViewCmp")
local UIFuncs = require("UI.UIFuncs")
local PartyRecordUI = class("UI.PartyRecordUI", UIBase)

local panel_name_list = {
    "invite_msg_panel",
    "party_record_panel",
    "enemy_record_panel",
}

local kSelectFunc = {
    "InitInviteMsgPanel",
    "InitPartyRecordPanel",
    "InitEnemyRecordPanel",
}

local panel_index_map = {
    invite = 1,
    record = 2,
    enemy = 3
}

function PartyRecordUI:DoInit()
    PartyRecordUI.super.DoInit(self)
    self.prefab_path = "UI/Common/PartyRecordUI"
    self.dy_party_data = ComMgrs.dy_data_mgr.party_data
    self.party_type_data_list = SpecMgrs.data_mgr:GetAllPartyData()
    self.ip_item_dict = {}
    self.rp_item_list = {}
    self.ep_item_list = {}
end

function PartyRecordUI:OnGoLoadedOk(res_go)
    PartyRecordUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function PartyRecordUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    PartyRecordUI.super.Show(self)
end

function PartyRecordUI:InitRes()
    UIFuncs.GetInitTopBar(self, self.main_panel, "PartyRecordPanel")

    self.tag_list = {}
    self.panel_list = {}
    self.item_parent_list = {}
    self.item_temp_list = {}
    self.empty_go_list = {}
    local btn_text_list = {UIConst.Text.INVITE_MSG, UIConst.Text.PARTY_RECORD, UIConst.Text.ENEMY}
    local empty_text_list = {UIConst.Text.NO_INVITE_MSG, UIConst.Text.NO_PARTY_RECORD, UIConst.Text.NO_ENEMY}
    local content = self.main_panel:FindChild("Content")
    local btn_parent = self.main_panel:FindChild("SelectBtnList")
    for i, panel_name in ipairs(panel_name_list) do
        local panel_go = content:FindChild(i)
        self[panel_name] = panel_go
        table.insert(self.panel_list, panel_go)
        local empty_go = panel_go:FindChild("Empty")
        table.insert(self.empty_go_list, empty_go)
        empty_go:FindChild("Dialog/Text"):GetComponent("Text").text = empty_text_list[i]
        local panel_btn = btn_parent:FindChild(i)
        panel_btn:FindChild("Text"):GetComponent("Text").text = btn_text_list[i]
        panel_btn:FindChild("Selected/Text"):GetComponent("Text").text = btn_text_list[i]
        self[panel_name .. "_btn"] = panel_btn
        table.insert(self.tag_list, panel_btn)
        local item_parent = panel_go:FindChild("Viewport/ItemList")
        table.insert(self.item_parent_list, item_parent)
        local item_temp = item_parent:FindChild("Item")
        item_temp:SetActive(false)
        table.insert(self.item_temp_list, item_temp)
        self:InitItemTempBtnText(item_temp, i)
        local icon_path = i == panel_index_map.record and UIConst.PrefabResPath.LoverIcon or UIConst.PrefabResPath.RoleIcon
        UIFuncs.GetIconGo(self, item_temp:FindChild("Icon"), nil, icon_path)
    end

    self.refuse_all_btn = self.invite_msg_panel:FindChild("BottomBar/RefuseAllBtn")
    self.refuse_all_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.REFUSE_ALL
    self:AddClick(self.refuse_all_btn, function ()
        self:RefuseAllBtnOnClick()
    end)
    local toggle_go = self.invite_msg_panel:FindChild("BottomBar/RemindToggle")
    toggle_go:FindChild("Label"):GetComponent("Text").text = UIConst.Text.NOT_RECEIVE_INVITE
    self.refuse_toggle = toggle_go:GetComponent("Toggle")
    self:AddToggle(toggle_go, function ()
        if self.is_set_toggle_by_ui then
            self.is_set_toggle_by_ui = nil
            return
        end
        self:RefuseToggleOnClick()
    end)

    local param_tb = {
        tag_list = self.tag_list,
        panel_list = self.panel_list,
        select_cb = self.TabViewSelectCb,
        init_select = false,
        select_colors = UIConst.Color.SelectTextColorList
    }
    self.tag_view_cmp = TabViewCmp.New()
    self.tag_view_cmp:DoInit(self, param_tb)
end

function PartyRecordUI:InitUI()
    self.tag_view_cmp:Select(self.cur_select_index or 1)
    self:RegisterEvent(self.dy_party_data, "UpdateReceiveInviteDict", function ()
        self:InitInviteMsgPanel()
    end)
end

function PartyRecordUI:TabViewSelectCb(index)
    local func_name = kSelectFunc[index]
    self.cur_select_index = index
    self[func_name](self)
end

function PartyRecordUI:Hide()
    self.cur_select_index = nil
    self:ClearAllGo()
    self:ClearData()
    PartyRecordUI.super.Hide(self)
end

function PartyRecordUI:ClearData()
    self.invite_list = nil
    self.record_list = nil
    self.enemy_list = nil
end

function PartyRecordUI:ClearAllGo()
    self:ClearGoDict("ip_item_dict")
    self:ClearGoDict("rp_item_list")
    self:ClearGoDict("ep_item_list")
end

function PartyRecordUI:_GetItem(index)
    local item_temp = self.item_temp_list[index]
    local item_parent = self.item_parent_list[index]
    return self:GetUIObject(item_temp, item_parent)
end

function PartyRecordUI:InitInviteMsgPanel()
    self:_SetToggle(self.refuse_toggle, self.dy_party_data:GetNotReceiveInvite())
    self.empty_go_list[panel_index_map.invite]:SetActive(false)

    local invite_list = self.dy_party_data:GetReceiveInviteList()
    self:_GetInviteListCb(invite_list)
end

function PartyRecordUI:_SetToggle(toggle, is_on)
    self.is_set_toggle_by_ui = true
    toggle.isOn = is_on
end

function PartyRecordUI:_GetInviteListCb(invite_list)
    if not self.is_res_ok then return end
    self:ClearGoDict("ip_item_dict")
    self.invite_list = invite_list
    if not invite_list or not next(invite_list) then
        self.empty_go_list[panel_index_map.invite]:SetActive(true)
        return
    end
    --for i, party_info in ipairs(invite_list) do
        local go = self:_GetItem(panel_index_map.invite)
        self.ip_item_dict[invite_list.host_info.uuid] = go
        --table.insert(self.ip_item_dict, go)
        self:_InitInviteItem(go, invite_list)
    --end
end

function PartyRecordUI:_InitInviteItem(go, party_info)
    local host_info = party_info.host_info
    --go:FindChild("PartyInfo/Name"):GetComponent("Text").text = string.format(UIConst.Text.WHO_TEH_PARTY_BELONG, host_info.name)
    --go:FindChild("PartyInfo/Level"):GetComponent("Text").text = string.format(UIConst.Text.LEVEL_FORMAT_TEXT_WITH_GREEN_COLOR, host_info.level)

    --go:FindChild("PartyInfo/Name"):GetComponent("Text").text = string.format(UIConst.Text.WHO_TEH_PARTY_BELONG, host_info.name)
    go:FindChild("PartyInfo/PartyType"):GetComponent("Text").text = string.format(UIConst.Text.WHO_TEH_PARTY_BELONG, host_info.name)
    go:FindChild("PartyInfo/Level"):GetComponent("Text").text = string.format(UIConst.Text.LEVEL_FORMAT_TEXT_WITH_GREEN_COLOR, host_info.level)


    local max_guest_num = self.party_type_data_list[party_info.party_type_id].guests_max_num
    --party_info_go:FindChild("GuestNum"):GetComponent("Text").text = string.format(UIConst.Text.GUEST_NUM, #party_info.guests_list, max_guest_num)
    go:FindChild("PartyInfo/GuestNum"):GetComponent("Text").text = string.format(UIConst.Text.GUEST_NUM, #party_info.guests_list, max_guest_num)
    local param_tb = {go = go:FindChild("Icon/Item"), role_id = host_info.role_id}
    UIFuncs.InitRoleIcon(param_tb)
    self:AddClick(go:FindChild("Right/ConfirmBtn"), function ()
        self:ConfirmInviteBtnOnClick(party_info)
    end)
    self:AddClick(go:FindChild("Right/RefuseBtn"), function ()
        self:RefuseBtnOnClick(party_info)
    end)
end

function PartyRecordUI:ConfirmInviteBtnOnClick(party_info)
    SpecMgrs.ui_mgr:ShowUI("PartyInfoUI", party_info)
end

function PartyRecordUI:InitPartyRecordPanel()
    if self.is_wait_record_cb then return end
    self.empty_go_list[panel_index_map.record]:SetActive(false)
    self.is_wait_record_cb = true
    SpecMgrs.msg_mgr:SendMsg("SendPartyGetRecordList", {}, function(resp)
        self.is_wait_record_cb = nil
        self:_GetRecordCb(resp.record_list)
    end)
end

function PartyRecordUI:_GetRecordCb(record_list)
    if not self.is_res_ok then return end
    self.record_list = record_list
    self:ClearGoDict("rp_item_list")
    if not record_list or not next(record_list) then
        self.empty_go_list[panel_index_map.record]:SetActive(true)
        return
    end
    for i, party_info in ipairs(record_list) do
        local go = self:_GetItem(panel_index_map.record)
        table.insert(self.rp_item_list, go)
        self:_InitRecordItem(go, party_info)
    end
end

function PartyRecordUI:_InitRecordItem(go, party_info)
    local party_type_data = self.party_type_data_list[party_info.party_type_id]
    go:FindChild("PartyInfo/PartyType"):GetComponent("Text").text = party_type_data.name
    local time_str = UIFuncs.TimeToFormatStr(party_info.end_time, UIConst.Text.PARTY_TIME)
    go:FindChild("PartyInfo/Time"):GetComponent("Text").text = time_str
    local max_guest_num = self.party_type_data_list[party_info.party_type_id].guests_max_num

    go:FindChild("PartyInfo/GuestNum"):GetComponent("Text").text = string.format(UIConst.Text.GUEST_NUM, #party_info.guests_list, max_guest_num)
    local param_tb = {go = go:FindChild("Icon/Item"), lover_id = party_info.lover_id}
    UIFuncs.InitLoverGo(param_tb)
    go:FindChild("PartyInfo/LoverLevel/Text/Text"):GetComponent("Text").text = party_info.lover_level
    go:FindChild("Right/Score"):GetComponent("Text").text = party_info.integral_count
    self:AddClick(go:FindChild("Right/CheckBtn"), function()
        SpecMgrs.ui_mgr:ShowUI("PartyDetailUI", party_info)
    end)
end

function PartyRecordUI:InitEnemyRecordPanel()
    if self.is_wait_enemy_cb then return end
    self.empty_go_list[panel_index_map.enemy]:SetActive(false)
    self.is_wait_enemy_cb = true
    SpecMgrs.msg_mgr:SendMsg("SendPartyGetEnemyList", {}, function(resp)
        self.is_wait_enemy_cb = nil
        self:_GetEnemyCb(resp.enemy_list)
    end)
end

function PartyRecordUI:_GetEnemyCb(enemy_list)
    if not self.is_res_ok then return end
    self.enemy_list = enemy_list
    self:ClearGoDict("ep_item_list")
    if not enemy_list or not next(enemy_list) then
        self.empty_go_list[panel_index_map.enemy]:SetActive(true)
        return
    end
    for i, enemy_info in ipairs(enemy_list) do
        local go = self:_GetItem(panel_index_map.enemy)
        table.insert(self.ep_item_list, go)
        self:_InitEnemyItem(go, enemy_info)
    end
end

function PartyRecordUI:_InitEnemyItem(go, enemy_info)
    local role_info = enemy_info.role_info
    go:FindChild("Info/Name"):GetComponent("Text").text = UIFuncs.GetRoleNameWhihServerName(role_info.name, role_info.server_id)
    go:FindChild("Info/Level"):GetComponent("Text").text = string.format(UIConst.Text.LEVEL_FORMAT_TEXT_WITH_GREEN_COLOR, role_info.level)
    go:FindChild("Info/Id"):GetComponent("Text").text = string.format(UIConst.Text.ROLE_UUID_TEXT_GREEN, role_info.uuid)
    go:FindChild("Right/Time"):GetComponent("Text").text = UIFuncs.TimeToFormatStr(enemy_info.interrupt_time)
end

function PartyRecordUI:InitItemTempBtnText(temp, index)
    if index == panel_index_map.invite then
        temp:FindChild("Right/ConfirmBtn/Text"):GetComponent("Text").text = UIConst.Text.JOIN_PARTY
        temp:FindChild("Right/RefuseBtn/Text"):GetComponent("Text").text = UIConst.Text.REFUSE
    elseif index == panel_index_map.record then
        temp:FindChild("Right/CheckBtn/Text"):GetComponent("Text").text = UIConst.Text.CHECK_DETAIL
        temp:FindChild("Right/Title"):GetComponent("Text").text = UIConst.Text.GET_TOTAL_SCORE
    elseif index == panel_index_map.enemy then
        temp:FindChild("Right/Title"):GetComponent("Text").text = UIConst.Text.BREAK_PARTY_TIME
    end
end


function PartyRecordUI:RefuseBtnOnClick(party_info)
    local uuid = party_info.host_info.uuid
    SpecMgrs.msg_mgr:SendMsg("SendPartyRefuseInvite", {uuid = party_info.host_info.uuid}, function()
        self:DelUIObject(self.ip_item_dict[uuid])
        self.ip_item_dict[uuid] = nil
    end)
end

function PartyRecordUI:RefuseAllBtnOnClick()
    if not self.invite_list then return end
    SpecMgrs.msg_mgr:SendMsg("SendPartyRefuseInvite", {}, function()
        self:ClearGoDict("ip_item_dict")
    end)
end

function PartyRecordUI:RefuseToggleOnClick()
    SpecMgrs.msg_mgr:SendMsg("SendPartySetReceiveInvite", {set_value = self.refuse_toggle.isOn})
end

return PartyRecordUI