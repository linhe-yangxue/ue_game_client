local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local CSFunction = require("CSCommon.CSFunction")
local UIFuncs = require("UI.UIFuncs")
local AttrUtil = require("BaseUtilities.AttrUtil")
local SelectTreasureUI = class("UI.SelectTreasureUI",UIBase)

function SelectTreasureUI:DoInit()
    SelectTreasureUI.super.DoInit(self)
    self.prefab_path = "UI/Common/SelectTreasureUI"
    self.guid_to_item = {}
    self.guid_to_toggle = {}
    self.is_guid_selected = {}
    self.select_num = 0
end

function SelectTreasureUI:OnGoLoadedOk(res_go)
    SelectTreasureUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function SelectTreasureUI:Show(param_tb)
    self.treasure_list = param_tb.treasure_list --在外面已经排序好的 这里不再进行排序
    self.comfirm_cb = param_tb.comfirm_cb
    self.is_guid_selected = param_tb.is_guid_selected or {}
    self.select_num = param_tb.select_num or 0
    if self.is_res_ok then
        self:InitUI()
    end
    SelectTreasureUI.super.Show(self)
end

function SelectTreasureUI:InitRes()
    self.close_btn = self.main_panel:FindChild("TopMenuPanel/CloseBtn")
    self:AddClick(self.close_btn, function()
        self:Hide()
    end)
    self.main_panel:FindChild("TopMenuPanel/Title"):GetComponent("Text").text = UIConst.Text.SELECT_TREASURE
    self.main_panel:FindChild("BottomPanel/ChangeBtn/Text"):GetComponent("Text").text = UIConst.Text.CONFIRM
    self.item_parent = self.main_panel:FindChild("Scroll View/Viewport/Content")
    self.item_temp = self.main_panel:FindChild("Scroll View/Viewport/Content/Temp")
    self.item_temp:SetActive(false)
    self.selected_num_text = self.main_panel:FindChild("BottomPanel/SelectedNum"):GetComponent("Text")
    self.change_btn = self.main_panel:FindChild("BottomPanel/ChangeBtn")
    self:AddClick(self.change_btn, function()
        self:ComfirmBtnOnClick()
    end)
end

function SelectTreasureUI:InitUI()
    for i, treasure_data in ipairs(self.treasure_list) do
        local item = self:GetUIObject(self.item_temp, self.item_parent)
        local guid = treasure_data.guid
        self.guid_to_item[guid] = item
        item.name = guid
        local go = item:FindChild("Item")
        local native_treasure_data = SpecMgrs.data_mgr:GetItemData(treasure_data.item_id)
        local tb = {go = go, item_data = native_treasure_data, level = treasure_data.strengthen_lv}
        UIFuncs.InitItemGo(tb)
        go:FindChild("Name"):GetComponent("Text").text = UIFuncs.GetItemName({item_id = treasure_data.item_id})
        go:FindChild("Level"):GetComponent("Text").text = string.format(UIConst.Text.LEVEL, treasure_data.strengthen_lv)
        local attr_list = AttrUtil.GetSortedEquipAttrList(treasure_data.guid)
        local attr_key = native_treasure_data.base_attr_list[1]
        for i = 1, 2 do
            local text_go = item:FindChild("Middle/" .. i)
            if attr_list[i] then
                text_go:SetActive(true)
                text_go:GetComponent("Text").text = UIFuncs.GetAttrStr(attr_list[i].attr_key, attr_list[i].attr_num)
            else
                text_go:SetActive(false)
            end
        end
        tb.quality = native_treasure_data.quality
        tb.is_change_color = true
        item:FindChild("Middle/Type"):GetComponent("Text").text = UIFuncs.GetEquipPartName(tb)
        local toggle_go = item:FindChild("Toggle")
        local toggle_comp  = toggle_go:GetComponent("Toggle")
        toggle_comp.isOn = self.is_guid_selected[guid] or false
        self.guid_to_toggle[guid] = toggle_comp
        self:AddToggle(toggle_go, function ()
            self:ToggleOnClick(guid)
        end)
    end
    self.selected_num_text.text = string.format(UIConst.Text.SELECT_TREASURE_NUM, self.select_num)
end

function SelectTreasureUI:Hide()
    self.treasure_list = nil
    self.comfirm_cb = nil
    for _, go in pairs(self.guid_to_item) do
        self:DelUIObject(go)
    end
    self.guid_to_item = {}
    self.guid_to_toggle = {}
    self.is_guid_selected = {}
    self.select_num = 0
    SelectTreasureUI.super.Hide(self)
end

function SelectTreasureUI:ComfirmBtnOnClick()
    if self.comfirm_cb then
        self.comfirm_cb(self.is_guid_selected, self.select_num)
    end
    self:Hide()
end

function SelectTreasureUI:ToggleOnClick(guid)
    local is_selected = self.guid_to_toggle[guid].isOn
    self.is_guid_selected[guid] = is_selected
    local change_num = is_selected and 1 or -1
    self.select_num = self.select_num + change_num
    self.selected_num_text.text = string.format(UIConst.Text.SELECT_TREASURE_NUM, self.select_num)
end

return SelectTreasureUI
