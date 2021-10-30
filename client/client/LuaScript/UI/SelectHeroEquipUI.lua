local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local AttrUtil = require("BaseUtilities.AttrUtil")

local SelectHeroEquipUI = class("UI.SelectHeroEquipUI", UIBase)

function SelectHeroEquipUI:DoInit()
    SelectHeroEquipUI.super.DoInit(self)
    self.prefab_path = "UI/Common/SelectHeroEquipUI"
    self.star_limit = SpecMgrs.data_mgr:GetParamData("hero_star_lv_limit").f_value
    self.item_go_list = {}
end

function SelectHeroEquipUI:OnGoLoadedOk(res_go)
    SelectHeroEquipUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function SelectHeroEquipUI:Hide()
    self:ClearItemGo()
    SelectHeroEquipUI.super.Hide(self)
end

-- hero_list:有序的英雄信息列表 or equip_list:有序的装备信息列表
-- confirm_cb, cancel_cb
function SelectHeroEquipUI:Show(data)
    self.data = data
    if self.is_res_ok then
        self:InitUI()
    end
    SelectHeroEquipUI.super.Show(self)
end

function SelectHeroEquipUI:InitRes()
    local top_bar = self.main_panel:FindChild("TopBar")
    UIFuncs.InitTopBar(self, top_bar, "SelectHeroEquipUI", function ()
        if self.data.cancel_cb then self.data.cancel_cb() end
        self:Hide()
    end)
    self.title = top_bar:FindChild("CloseBtn/Title"):GetComponent("Text")
    self.item_content = self.main_panel:FindChild("Content/View/Content")
    self.hero_item = self.item_content:FindChild("HeroItem")
    self.hero_item:FindChild("SelectBtn/Text"):GetComponent("Text").text = UIConst.Text.SELECT_TEXT
    self.equip_item = self.item_content:FindChild("EquipItem")
    self.equip_item:FindChild("SelectBtn/Text"):GetComponent("Text").text = UIConst.Text.SELECT_TEXT
    self.empty_panel = self.main_panel:FindChild("Content/Empty")
    self.empty_dialog_text = self.empty_panel:FindChild("Dialog/Text"):GetComponent("Text")
end

function SelectHeroEquipUI:InitUI()
    if not self.data then
        self:Hide()
        return
    end
    if self.data.hero_list then
        self.title.text = UIConst.Text.SELECT_HERO
    elseif self.data.equip_list then
        self.title.text = UIConst.Text.SELECT_EQUIPMENT
    elseif self.data.treasure_list then
        self.title.text = UIConst.Text.SELECT_TREASURE
    end
    self:InitHeroList()
    self:InitEquipList()
    self.item_content:GetComponent("RectTransform").anchoredPosition = Vector2.zero
end

function SelectHeroEquipUI:InitHeroList()
    if not self.data.hero_list then return end
    self.empty_panel:SetActive(#self.data.hero_list == 0)
    if #self.data.hero_list == 0 then
        self.empty_dialog_text.text = self.data.empty_tip or UIConst.Text.NO_SELECTABLE_HERO
        return
    end
    for _, hero_info in ipairs(self.data.hero_list) do
        local hero_data = SpecMgrs.data_mgr:GetHeroData(hero_info.hero_id)
        local unit_data = SpecMgrs.data_mgr:GetUnitData(hero_data.unit_id)
        local quality_data = SpecMgrs.data_mgr:GetQualityData(hero_data.quality)
        local item_go = self:GetUIObject(self.hero_item, self.item_content)
        UIFuncs.InitHeroGo({go = item_go:FindChild("Hero"), hero_data = hero_data})
        item_go:FindChild("NamePanel/Name"):GetComponent("Text").text = hero_data.name
        item_go:FindChild("NamePanel/Lv"):GetComponent("Text").text = string.format(UIConst.Text.LEVEL, hero_info.level)
        item_go:FindChild("ItemPanel/BreakLv"):GetComponent("Text").text = string.format(UIConst.Text.BREAK_FORMAT_WITH_SIZE, hero_info.break_lv)
        item_go:FindChild("ItemPanel/DestinyLv"):GetComponent("Text").text = string.format(UIConst.Text.DESTINY_FORMAT_WITH_SIZE, hero_info.destiny_lv)
        local star_list = item_go:FindChild("StarList")
        star_list:SetActive(hero_info.star_lv and hero_info.star_lv > 0)
        if hero_info.star_lv and hero_info.star_lv > 0 then
            for i = 1, self.star_limit do
                star_list:FindChild("Star" .. i .. "/Active"):SetActive(i <= hero_info.star_lv)
            end
        end
        self:AddClick(item_go:FindChild("SelectBtn"), function ()
            if self.data.confirm_cb then self.data.confirm_cb(hero_info) end
            self:Hide()
        end)
        table.insert(self.item_go_list, item_go)
    end
end

function SelectHeroEquipUI:InitEquipList()
    local equip_list = self.data.equip_list or self.data.treasure_list
    if not equip_list then return end
    self.empty_panel:SetActive(#equip_list == 0)
    if #equip_list == 0 then
        self.empty_dialog_text.text = self.data.empty_tip or UIConst.Text.NO_SELECTABLE_EQUIP
        return
    end
    for _, equip_info in ipairs(equip_list) do
        local quality_data = SpecMgrs.data_mgr:GetQualityData(equip_info.item_data.quality)
        local item_go = self:GetUIObject(self.equip_item, self.item_content)
        UIFuncs.InitItemGo({
            ui = self,
            go = item_go:FindChild("Item"),
            item_data = equip_info.item_data,
            name_go = item_go:FindChild("NamePanel/Name"),
            change_name_color = true,
        })
        item_go:FindChild("NamePanel/StrengthenLv"):GetComponent("Text").text = string.format(UIConst.Text.LEVEL, equip_info.strengthen_lv)

        local item_panel = item_go:FindChild("ItemPanel")
        local attr_dict = AttrUtil.GetEquipAttrDict(equip_info.guid)
        local attr_item = item_panel:FindChild("Attr")
        local attr = equip_info.item_data.refine_attr_list[1]
        local show_attr_flag = attr ~= nil and attr_dict[attr] ~= nil and attr_dict[attr] > 0
        attr_item:SetActive(show_attr_flag)
        if show_attr_flag then
            attr_item:GetComponent("Text").text = UIFuncs.GetAttrStr(attr, math.floor(attr_dict[attr]))
        end
        local extra_attr_item = item_panel:FindChild("ExtraAttr")
        local extra_attr = equip_info.item_data.refine_attr_list[2]
        local show_extra_attr_flag = extra_attr ~= nil and attr_dict[extra_attr] ~= nil and attr_dict[extra_attr] > 0
        extra_attr_item:SetActive(show_extra_attr_flag)
        if show_extra_attr_flag then
            extra_attr_item:GetComponent("Text").text = UIFuncs.GetAttrStr(extra_attr, math.floor(attr_dict[extra_attr]))
        end
        item_panel:FindChild("RefineLv/Text"):GetComponent("Text").text = string.format(UIConst.Text.REFINE_LEVEL, equip_info.refine_lv)
        local star_list = item_go:FindChild("StarList")
        star_list:SetActive(equip_info.star_lv and equip_info.star_lv > 0)
        if equip_info.star_lv and equip_info.star_lv > 0 then
            for i = 1, self.star_limit do
                star_list:FindChild("Star" .. i .. "/Active"):SetActive(i <= equip_info.star_lv)
            end
        end
        self:AddClick(item_go:FindChild("SelectBtn"), function ()
            if self.data.confirm_cb then self.data.confirm_cb(equip_info) end
            self:Hide()
        end)
        table.insert(self.item_go_list, item_go)
    end
end

function SelectHeroEquipUI:ClearItemGo()
    for _, item_go in ipairs(self.item_go_list) do
        self:DelUIObject(item_go)
    end
    self.item_go_list = {}
end

return SelectHeroEquipUI