local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local SelectEquipUI = class("UI.SelectEquipUI",UIBase)
local UIFuncs = require("UI.UIFuncs")
local ItemUtil = require("BaseUtilities.ItemUtil")
local AttrUtil = require("BaseUtilities.AttrUtil")

local kDefaultHideWearedEquip = false

function SelectEquipUI:DoInit()
    SelectEquipUI.super.DoInit(self)
    self.prefab_path = "UI/Common/SelectEquipUI"
    self.equip_list = {}
    self.equip_to_go = {}
    self.dy_hero_data = ComMgrs.dy_data_mgr.night_club_data
end

function SelectEquipUI:OnGoLoadedOk(res_go)
    SelectEquipUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function SelectEquipUI:Show(param_tb)
    self.lineup_id = param_tb.lineup_id
    self.part_index = param_tb.part_index
    local equip_list = ComMgrs.dy_data_mgr.bag_data:GetBagItemListByPartIndex(self.part_index) or {}
    self.equip_list = {}
    for i, v in ipairs(equip_list) do
        self.equip_list[i] = v
    end
    ItemUtil.SortEuqipItemList(self.equip_list)
    if self.is_res_ok then
        self:InitUI()
    end
    SelectEquipUI.super.Show(self)
end

function SelectEquipUI:InitRes()
    local top_bar = self.main_panel:FindChild("TopBar")
    self.title_text = top_bar:FindChild("CloseBtn/Title"):GetComponent("Text")
    self:AddClick(top_bar:FindChild("CloseBtn"), function()
        SpecMgrs.ui_mgr:HideUI(self)
    end)
    self:AddToggle(self.main_panel:FindChild("TopBar/Toggle"), function ()
        self:HideToggleOnClick()
    end)
    self.hide_toggle = self.main_panel:FindChild("TopBar/Toggle"):GetComponent("Toggle")
    self.main_panel:FindChild("TopBar/Toggle/Text"):GetComponent("Text").text = UIConst.Text.HIDE_EQUIP_ALREADY_WEAR
    self.equip_go_parent = self.main_panel:FindChild("Scroll View/Viewport/Content")
    self.equip_go_temp = self.equip_go_parent:FindChild("Temp")
    self.equip_go_temp:FindChild("WearBtn/Text"):GetComponent("Text").text = UIConst.Text.WEAR
    self.equip_go_temp:SetActive(false)
    self.no_equip = self.main_panel:FindChild("Empty")
    self.no_equip:FindChild("Dialog/Text"):GetComponent("Text").text = UIConst.Text.NO_EQUIP
end

function SelectEquipUI:UpdateEquipGo(go, equip_data)
    local item_icon_go = go:FindChild("Item")
    local native_item_data = equip_data.item_data or SpecMgrs.data_mgr:GetItemData(equip_data.item_id)
    UIFuncs.InitItemGo({go = item_icon_go, item_data = native_item_data})
    go:FindChild("Middle/Name/Level"):GetComponent("Text").text = string.format(UIConst.Text.LEVEL, equip_data.strengthen_lv)
    go:FindChild("Middle/Name"):GetComponent("Text").text = native_item_data.name
    local attr_list = AttrUtil.GetSortedEquipAttrList(equip_data.guid)
    local attr_key = native_item_data.base_attr_list[1]
    for i = 1, 2 do
        local text_go = go:FindChild("Middle/" .. i)
        if attr_list[i] then
            text_go:SetActive(true)
            text_go:GetComponent("Text").text = UIFuncs.GetAttrStr(attr_list[i].attr_key, attr_list[i].attr_num)
        else
            text_go:SetActive(false)
        end
    end
    local refine_go = go:FindChild("Middle/RefineLevel")
    local is_show_refine_go = equip_data.refine_lv and equip_data.refine_lv > 0 and true or false
    refine_go:SetActive(is_show_refine_go)
    if is_show_refine_go then
        refine_go:FindChild("Text"):GetComponent("Text").text = string.format(UIConst.Text.REFINE_LEVEL, equip_data.refine_lv)
    end
    local hero_wear_go = go:FindChild("HeroWear")
    local is_show_hero_wear = equip_data.lineup_id and true or false
    hero_wear_go:SetActive(is_show_hero_wear)
    local wear_btn = go:FindChild("WearBtn")
    local wear_btn_image = wear_btn:GetComponent("Image")
    local wear_btn_text = wear_btn:FindChild("Text"):GetComponent("Text")
    if is_show_hero_wear then
        local hero_id = self.dy_hero_data:GetLineupHeroId(equip_data.lineup_id)
        local hero_data = SpecMgrs.data_mgr:GetHeroData(hero_id)
        hero_wear_go:GetComponent("Text").text = hero_data.name
    end
    self:AddClick(wear_btn, function()
        self:WearBtnOnClick(equip_data.guid, self.lineup_id)
    end)
end

function SelectEquipUI:InitUI()
    self.no_equip:SetActive(#self.equip_list == 0)
    self:ChangeTitle(self.part_index)
    self:CleanEquipGoDict()
    for i, equip_data in ipairs(self.equip_list) do
        if not equip_data.lineup_id or equip_data.lineup_id ~= self.lineup_id then -- 隐藏当前已装备在该位置道具
            local go = self:GetUIObject(self.equip_go_temp, self.equip_go_parent)
            self.equip_to_go[equip_data.guid] = go
            self:UpdateEquipGo(go, equip_data)
        end
    end
    self.hide_toggle.isOn = kDefaultHideWearedEquip
    self:HideToggleOnClick()
end

function SelectEquipUI:Hide()
    self:CleanEquipGoDict()
    self.lineup_id = nil
    self.part_index = nil
    self.equip_list = {}
    SelectEquipUI.super.Hide(self)
end

function SelectEquipUI:ChangeTitle(equip_index)
    local equip_data = SpecMgrs.data_mgr:GetEquipPartData(equip_index)
    self.title_text.text = string.format(UIConst.Text.SELECT_EQUIP_TITLE, equip_data.name)
end

function SelectEquipUI:CleanEquipGoDict()
    for _, go in pairs(self.equip_to_go) do
        self:DelUIObject(go)
    end
    self.equip_to_go = {}
end

function SelectEquipUI:HideToggleOnClick()
    local is_show_equip_already_wear = not self.hide_toggle.isOn
    for i, equip_data in ipairs(self.equip_list) do
        if equip_data.lineup_id then
            if self.equip_to_go[equip_data.guid] then
                self.equip_to_go[equip_data.guid]:SetActive(is_show_equip_already_wear)
            end
        end
    end
end

function SelectEquipUI:WearBtnOnClick(equip_guid)
    SpecMgrs.msg_mgr:SendMsg("SendLineupWearEquip",{lineup_id = self.lineup_id, part_index = self.part_index, item_guid = equip_guid}, function (resp)
        SpecMgrs.ui_mgr:HideUI(self)
    end)
end

return SelectEquipUI
