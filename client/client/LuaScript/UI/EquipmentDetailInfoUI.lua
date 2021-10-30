local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local DyDataConst = require("DynamicData.DyDataConst")
local CSFunction = require("CSCommon.CSFunction")
local AttrUtil = require("BaseUtilities.AttrUtil")

local EquipmentDetailInfoUI = class("UI.EquipmentDetailInfoUI", UIBase)

local kSuitEquipmentCount = 4
local kSuitEffectBorder = 10
local kSuitAttrTextBorder = 40
local kEffectWidthPer = 0.75
local replace_control_id_list = {CSConst.RedPointControlIdDict.ReplaceEquip}
local default_vector2 = Vector2.New(1, 1)

function EquipmentDetailInfoUI:DoInit()
    EquipmentDetailInfoUI.super.DoInit(self)
    self.prefab_path = "UI/Common/EquipmentDetailInfoUI"
    self.suit_effect_list = {}
    self.star_item_list = {}
    self.dy_bag_data = ComMgrs.dy_data_mgr.bag_data
    self.suit_equip_item_dict = {}
    self.suit_item_attr_list = {}
    self.suit_item_spell_list = {}
    self.spell_item_dict = {}
end

function EquipmentDetailInfoUI:OnGoLoadedOk(res_go)
    EquipmentDetailInfoUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function EquipmentDetailInfoUI:Hide()
    SpecMgrs.redpoint_mgr:RemoveRedPoint(self.replace_redpoint)
    self.replace_redpoint = nil
    self:ClearAllGo()
    self.dy_bag_data:UnregisterUpdateBagItemEvent("EquipmentDetailInfoUI")
    EquipmentDetailInfoUI.super.Hide(self)
end

function EquipmentDetailInfoUI:Show(guid)
    self.equipment_guid = guid
    if self.is_res_ok then
        self:InitUI()
    end
    EquipmentDetailInfoUI.super.Show(self)
end

function EquipmentDetailInfoUI:InitRes()
    local content = self.main_panel:FindChild("Content")
    local top_bar = content:FindChild("TopBar")
    UIFuncs.InitTopBar(self, top_bar, "EquipmentDetailInfoUI")
    self.equipment_type = top_bar:FindChild("CloseBtn/Title"):GetComponent("Text")

    local detail_info_panel = content:FindChild("DetailInfoPanel")
    self.equipment_grade = detail_info_panel:FindChild("EquipInfo/Grade"):GetComponent("Image")
    self.equipment_img = detail_info_panel:FindChild("EquipInfo/EquipmentImg"):GetComponent("Image")
    self.equipment_name = detail_info_panel:FindChild("InfoPanel/EquipmentName/Text"):GetComponent("Text")
    local equipment_tip = detail_info_panel:FindChild("EquipInfo/EquipmentTip")
    self.equipment_quality = equipment_tip:FindChild("Quality/Title"):GetComponent("Text")
    self.equipment_potential = equipment_tip:FindChild("Potential/Text"):GetComponent("Text")
    local info_panel = detail_info_panel:FindChild("InfoPanel/Viewport/Content")
    self.info_content_rect_cmp = info_panel:GetComponent("RectTransform")
    -- 强化属性
    self.strength_attr_panel = info_panel:FindChild("StrengthAttrPanel")
    self.strength_attr_panel:FindChild("Header/Title"):GetComponent("Text").text = UIConst.Text.STRENGTH_ATTR_TEXT
    local strength_content = self.strength_attr_panel:FindChild("Content")
    self.strength_lv = strength_content:FindChild("StrengthLv"):GetComponent("Text")
    self.strength_attr = strength_content:FindChild("StrengthAttr"):GetComponent("Text")
    self.strength_btn = strength_content:FindChild("StrengthBtn")
    self.strength_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.STRENGTH_TEXT
    self.strength_btn_red_point = self.strength_btn:FindChild("RedPoint")
    self:AddClick(self.strength_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("EquipmentCultivateUI", self.equipment_guid, CSConst.EquipCultivateOperation.Strengthen)
    end)
    -- 精炼属性
    self.refine_attr_panel = info_panel:FindChild("RefineAttrPanel")
    self.refine_attr_panel:FindChild("Header/Title"):GetComponent("Text").text = UIConst.Text.REFINE_ATTR_TEXT
    local refine_content = self.refine_attr_panel:FindChild("Content")
    self.refine_lv = refine_content:FindChild("RefineLv"):GetComponent("Text")
    self.refine_attr = refine_content:FindChild("RefineAttr"):GetComponent("Text")
    self.refine_extra_attr = refine_content:FindChild("ExtraAttr")
    self.refine_extra_attr_text = self.refine_extra_attr:GetComponent("Text")
    self.refine_btn = refine_content:FindChild("RefineBtn")
    self.refine_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.REFINE_TEXT
    self.refine_btn_red_point = self.refine_btn:FindChild("RedPoint")
    self:AddClick(self.refine_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("EquipmentCultivateUI", self.equipment_guid, CSConst.EquipCultivateOperation.Refine)
    end)
    self.refine_btn_cmp = self.refine_btn:GetComponent("Button")
    self.refine_disable = self.refine_btn:FindChild("Disable")
    -- 升星属性
    self.add_star_attr_panel = info_panel:FindChild("AddStarPanel")
    self.add_star_attr_panel:FindChild("Header/Title"):GetComponent("Text").text = UIConst.Text.ADD_STAR
    local add_star_content = self.add_star_attr_panel:FindChild("Content")
    local star_lv_panel = add_star_content:FindChild("StarLvPanel")
    star_lv_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.STAR_LEVEL_FORMAT
    self.star_list = star_lv_panel:FindChild("StarList")
    self.star_item = self.star_list:FindChild("Star")
    self.star_attr = add_star_content:FindChild("StarAttr"):GetComponent("Text")
    self.star_extra_attr = add_star_content:FindChild("ExtraAttr")
    self.star_extra_attr_text = self.star_extra_attr:GetComponent("Text")
    self.add_star_btn = add_star_content:FindChild("AddStarBtn")
    self.star_btn_red_point = self.add_star_btn:FindChild("RedPoint")
    self.add_star_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ADD_STAR
    self:AddClick(self.add_star_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("EquipmentCultivateUI", self.equipment_guid, CSConst.EquipCultivateOperation.AddStar)
    end)
    self.add_star_btn_cmp = self.add_star_btn:GetComponent("Button")
    self.add_star_disable = self.add_star_btn:FindChild("Disable")
    -- 炼化属性
    self.lianhua_attr_panel = info_panel:FindChild("LianHuaAttrPanel")
    self.lianhua_attr_panel:FindChild("Header/Title"):GetComponent("Text").text = UIConst.Text.LIANHUA_ATTR_TEXT
    local lianhua_content = self.lianhua_attr_panel:FindChild("Content")
    self.lianhua_lv = lianhua_content:FindChild("LianHuaLv"):GetComponent("Text")
    self.lianhua_attr = lianhua_content:FindChild("LianHuaAttr"):GetComponent("Text")
    self.lianhua_btn = lianhua_content:FindChild("LianHuaBtn")
    self.lianhua_btn_red_point = self.lianhua_btn:FindChild("RedPoint")
    self.lianhua_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.LIANHUA_TEXT
    self:AddClick(self.lianhua_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("EquipmentCultivateUI", self.equipment_guid, CSConst.EquipCultivateOperation.LianHua)
    end)
    self.lianhua_btn_cmp = self.lianhua_btn:GetComponent("Button")
    self.lianhua_disable = self.lianhua_btn:FindChild("Disable")
    -- 神兵技能
    self.spell_panel = info_panel:FindChild("SpellPanel")
    self.spell_panel:FindChild("Header/Title"):GetComponent("Text").text = UIConst.Text.TREASURE_SPELL_TEXT
    self.spell_content = self.spell_panel:FindChild("Content")
    self.spell_item = self.spell_content:FindChild("SpellItem")
    -- 套装属性
    self.suit_panel = info_panel:FindChild("SuitPanel")
    self.suit_panel:FindChild("Header/Title"):GetComponent("Text").text = UIConst.Text.SUIT_TEXT
    local suit_content = self.suit_panel:FindChild("Content")
    self.suit_name = suit_content:FindChild("SuitName/Text"):GetComponent("Text")
    self.suit_equipment_content = suit_content:FindChild("SuitEquipmentPanel/Content")
    self.suit_equipment_item = self.suit_equipment_content:FindChild("SuitEquipmentItem")
    self.suit_attr_panel = suit_content:FindChild("SuitAttrPanel")
    self.suit_attr_item = self.suit_attr_panel:FindChild("Attr")
    self.suit_spell_panel = suit_content:FindChild("SuitSpellPanel")
    self.suit_spell_item = self.suit_spell_panel:FindChild("SpellItem")
    self.desc_panel = info_panel:FindChild("DescPanel")
    self.desc_panel:FindChild("Header/Title"):GetComponent("Text").text = UIConst.Text.DESC_TEXT
    self.desc = self.desc_panel:FindChild("Content/Desc"):GetComponent("Text")

    local bottom_panel = content:FindChild("BottomPanel")
    local unload_btn = bottom_panel:FindChild("UnloadBtn")
    unload_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.UNLOAD_TEXT
    self:AddClick(unload_btn, function ()
        SpecMgrs.msg_mgr:SendLineupUnwearEquip({lineup_id = self.equipment_info.lineup_id, part_index = self.equipment_data.part_index}, function (resp)
            if resp.errcode ~= 0 then
                SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.UNLOAD_FAILED_TEXT)
                return
            end
            SpecMgrs.ui_mgr:HideUI(self)
        end)
    end)
    self.replace_btn = bottom_panel:FindChild("ReplaceBtn")
    self.replace_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.REPLACE_TEXT
    self:AddClick(self.replace_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("SelectEquipUI", {lineup_id = self.equipment_info.lineup_id, part_index = self.equipment_data.part_index})
        SpecMgrs.ui_mgr:HideUI(self)
    end)
end

function EquipmentDetailInfoUI:InitUI()
    self.equipment_info = self.dy_bag_data:GetBagItemDataByGuid(self.equipment_guid)
    if not self.equipment_info then
        SpecMgrs.ui_mgr:HideUI(self)
        return
    end
    self.equipment_data = SpecMgrs.data_mgr:GetItemData(self.equipment_info.item_id)
    self.equipment_quality_data = SpecMgrs.data_mgr:GetQualityData(self.equipment_data.quality)
    self:InitInfoPanel()
    self.dy_bag_data:RegisterUpdateBagItemEvent("EquipmentDetailInfoUI", self.UpdateEquipmentInfo, self)
    self.replace_redpoint = SpecMgrs.redpoint_mgr:AddRedPoint(self, self.replace_btn, CSConst.RedPointType.Normal, replace_control_id_list, self.equipment_guid, default_vector2, default_vector2)
end

function EquipmentDetailInfoUI:InitInfoPanel()
    self:InitBasicData()
    self:InitStrengthAttrPanel()
    self:InitRefineAttrPanel()
    self:InitAddStarPanel()
    self:InitLianHuaAttrPanel()
    self:InitSpellPanel()
    self:InitSuitPanel()
    self:InitDescPanel()
    self.info_content_rect_cmp.anchoredPosition = Vector2.zero
end

function EquipmentDetailInfoUI:UpdateEquipmentInfo(_, op, item)
    if op == DyDataConst.BagItemOpType.Update and item.guid == self.equipment_guid then
        self.equipment_info = self.dy_bag_data:GetBagItemDataByGuid(self.equipment_guid)
        self:InitStrengthAttrPanel()
        self:InitRefineAttrPanel()
        self:InitAddStarPanel()
        self:InitLianHuaAttrPanel()
        self:InitSpellPanel()
    end
end

function EquipmentDetailInfoUI:InitBasicData()
    self.equipment_type.text = SpecMgrs.data_mgr:GetEquipPartData(self.equipment_data.part_index).name
    UIFuncs.AssignSpriteByIconID(self.equipment_data.img, self.equipment_img)
    UIFuncs.AssignSpriteByIconID(self.equipment_quality_data.ground, self.equipment_grade)
    self.equipment_name.text = self.equipment_data.name
    self.equipment_quality.text = self.equipment_quality_data.name
    -- TODO 潜力
end

function EquipmentDetailInfoUI:InitStrengthAttrPanel()
    local max_strength_lv = CSConst.StrengthenLimitRate * ComMgrs.dy_data_mgr:ExGetRoleLevel()
    local color = self.equipment_info.strengthen_lv < max_strength_lv and UIConst.Color.Red1 or UIConst.Color.Default
    self.strength_lv.text = string.format(UIConst.Text.STRENGTH_LV_FORMAT, color, self.equipment_info.strengthen_lv, max_strength_lv)
    local attr_dict = CSFunction.get_equip_strengthen_attr(self.equipment_data.id, self.equipment_info.strengthen_lv)
    local strength_attr = self.equipment_data.base_attr_list[1]
    self.strength_attr.text = UIFuncs.GetAttrStr(strength_attr, (attr_dict[strength_attr] or 0) + self.equipment_info.item_data.base_attr_value[1])
    self.strength_btn:GetComponent("Button").interactable = self.equipment_info.strengthen_lv < max_strength_lv
    self.strength_btn:FindChild("Disable"):SetActive(self.equipment_info.strengthen_lv >= max_strength_lv)
    self.strength_btn_red_point:SetActive(self.dy_bag_data:CheckEquipStrength(self.equipment_guid) == true)
    self.strength_attr_panel:SetActive(true)
end

function EquipmentDetailInfoUI:InitRefineAttrPanel()
    local refine_lv_list = SpecMgrs.data_mgr:GetEquipmentRefineLvList()
    local max_refine_lv = #refine_lv_list
    local color = self.equipment_info.refine_lv < max_refine_lv and UIConst.Color.Red1 or UIConst.Color.Default
    self.refine_lv.text = string.format(UIConst.Text.REFINE_LV_FORMAT, color, self.equipment_info.refine_lv, max_refine_lv)
    local attr_dict = CSFunction.get_equip_refine_attr(self.equipment_data.id, self.equipment_info.refine_lv)
    local base_attr = self.equipment_data.refine_attr_list[1]
    self.refine_attr.text = UIFuncs.GetAttrStr(base_attr, attr_dict[base_attr] or 0)
    local extra_attr = self.equipment_data.refine_attr_list[2]
    self.refine_extra_attr:SetActive(extra_attr ~= nil)
    if extra_attr then
        self.refine_extra_attr_text.text = UIFuncs.GetAttrStr(extra_attr, attr_dict[extra_attr] or 0)
    end
    self.refine_btn_cmp.interactable = self.equipment_info.refine_lv < max_refine_lv
    self.refine_disable:SetActive(self.equipment_info.refine_lv >= max_refine_lv)
    self.refine_btn_red_point:SetActive(self.dy_bag_data:CheckEquipRefine(self.equipment_guid) == true)
    self.refine_attr_panel:SetActive(true)
end

function EquipmentDetailInfoUI:InitAddStarPanel()
    if self.equipment_quality_data.equip_star_lv_limit > 0 then
        for _, star_item in ipairs(self.star_item_list) do
        self:DelUIObject(star_item)
        end
        self.star_item_list = {}
        for i = 1, self.equipment_quality_data.equip_star_lv_limit do
            local star_item = self:GetUIObject(self.star_item, self.star_list)
            star_item:FindChild("Active"):SetActive(i <= self.equipment_info.star_lv)
            table.insert(self.star_item_list, star_item)
        end
        local attr_list = AttrUtil.ConvertAttrDictToList(CSFunction.get_equip_star_attr(self.equipment_data.id, self.equipment_info.star_lv))
        local attr_data = SpecMgrs.data_mgr:GetAttributeData(attr_list[1].attr)
        self.star_attr.text = string.format(UIConst.Text.ATTR_VALUE_FORMAT, attr_data.name, math.floor(attr_list[1].value or 0))
        self.star_extra_attr:SetActive(attr_list[2] ~= nil)
        if attr_list[2] then
            local extra_attr_data = SpecMgrs.data_mgr:GetAttributeData(attr_list[2].attr)
            self.star_extra_attr.text = string.format(UIConst.Text.ATTR_VALUE_FORMAT, extra_attr_data.name, math.floor(attr_list[2].value or 0))
        end
        self.add_star_btn_cmp.interactable = self.equipment_info.star_lv < self.equipment_quality_data.equip_star_lv_limit
        self.add_star_disable:SetActive(self.equipment_info.star_lv >= self.equipment_quality_data.equip_star_lv_limit)
        self.star_btn_red_point:SetActive(self.dy_bag_data:CheckEquipAddStar(self.equipment_guid) == true)
    end
    self.add_star_attr_panel:SetActive(self.equipment_quality_data.equip_star_lv_limit > 0)
end

function EquipmentDetailInfoUI:InitLianHuaAttrPanel()
    if self.equipment_quality_data.can_smelt == true then
        self.lianhua_lv.text = string.format(UIConst.Text.LIANHUA_LV_FORMAT, self.equipment_info.smelt_lv)
        local attr_data = SpecMgrs.data_mgr:GetAttributeData(self.equipment_data.smelt_attr)
        local attr_value = 0
        for i = 1, self.equipment_info.smelt_lv do
            attr_value = attr_value + self.equipment_data.smelt_attr_value[i] + self.equipment_data.smelt_extra_attr_value[i]
        end
        local smelt_list = SpecMgrs.data_mgr:GetAllEquipSmeltData()
        local attr_dict = CSFunction.get_equip_smelt_attr(self.equipment_data.id, self.equipment_info.smelt_lv, self.equipment_info.smelt_exp)
        self.lianhua_attr.text = string.format(UIConst.Text.ATTR_VALUE_FORMAT, attr_data.name, math.floor(attr_dict[attr_data.id] or 0))
        self.lianhua_btn_cmp.interactable = self.equipment_info.smelt_lv < #smelt_list
        self.lianhua_disable:SetActive(self.equipment_info.smelt_lv >= #smelt_list)
        self.lianhua_btn_red_point:SetActive(self.dy_bag_data:CheckEquipSmelt(self.equipment_guid) == true)
    end
    self.lianhua_attr_panel:SetActive(self.equipment_quality_data.can_smelt == true)
end

function EquipmentDetailInfoUI:InitSpellPanel()
    if self.equipment_data.refine_spell_list then
        for i, refine_spell_id in ipairs(self.equipment_data.refine_spell_list) do
            local spell_item = self:GetUIObject(self.spell_item, self.spell_content)
            self.spell_item_dict[refine_spell_id] = spell_item
            local is_active = self.equipment_info.refine_lv >= self.equipment_data.refine_level_list[i]
            local desc = UIFuncs.GetEquipSpellDesc(refine_spell_id, self.equipment_data.refine_level_list[i], is_active)
            local spell_color = is_active and UIConst.Color.ActiveColor or UIConst.Color.UnactiveColor
            spell_item:GetComponent("Text").text = string.format(UIConst.Text.SIMPLE_COLOR, spell_color, desc)
        end
    end
    self.spell_panel:SetActive(self.equipment_data.refine_spell_list ~= nil and #self.equipment_data.refine_spell_list > 0)
end

function EquipmentDetailInfoUI:InitSuitPanel()
    local suit_data = SpecMgrs.data_mgr:GetSuitData(self.equipment_data.suit)
    local quality_data = SpecMgrs.data_mgr:GetQualityData(self.equipment_data.quality)
    if not suit_data then
        self.suit_panel:SetActive(false)
        return
    end
    self.suit_name.text = string.format(UIConst.Text.SIMPLE_COLOR, quality_data.color1, suit_data.name)
    local suit_count = 0
    for _, equip_item in ipairs(suit_data.suit_equipment) do
        local suit_equip_item = self:GetUIObject(self.suit_equipment_item, self.suit_equipment_content)
        self.suit_equip_item_dict[equip_item] = suit_equip_item
        UIFuncs.InitItemGo({
            go = suit_equip_item:FindChild("Item"),
            ui = self,
            item_id = equip_item,
            name_go = suit_equip_item:FindChild("Name"),
            change_name_color = true,
        })
        local is_wear = self.dy_bag_data:CheckEquipIsWear(equip_item, self.equipment_info.lineup_id)
        if is_wear then
            suit_count = suit_count + 1
            UIFuncs.AddSelectEffect(self, suit_equip_item:FindChild("Item"))
        end
    end
    for i, count in ipairs(suit_data.equip_attr_count) do
        local attr_item = self:GetUIObject(self.suit_attr_item, self.suit_attr_panel)
        attr_item:FindChild("Title/Text"):GetComponent("Text").text = string.format(UIConst.Text.SUIT_EFFECT_FORMAT, self.equipment_quality_data.color1, count)
        local effect_color = suit_count < count and UIConst.Color.UnactiveColor or UIConst.Color.ActiveColor
        attr_item:FindChild("Effect/Text"):GetComponent("Text").text = string.format(UIConst.Text.SIMPLE_COLOR, effect_color, suit_data.attr_desc[i])
        table.insert(self.suit_item_attr_list, attr_item)
    end
    self.suit_spell_panel:SetActive(suit_data.equip_spell_count ~= nil and #suit_data.equip_spell_count > 0)
    if suit_data.equip_spell_count ~= nil and #suit_data.equip_spell_count > 0 then
        for i, count in ipairs(suit_data.equip_spell_count) do
            local spell_item = self:GetUIObject(self.suit_spell_item, self.suit_spell_panel)
            local spell_color = suit_count < count and UIConst.Color.UnactiveColor or UIConst.Color.ActiveColor
            spell_item:GetComponent("Text").text = string.format(UIConst.Text.SIMPLE_COLOR, spell_color, suit_data.spell_desc[i])
            table.insert(self.suit_item_spell_list, spell_item)
        end
    end
    self.suit_panel:SetActive(true)
end

function EquipmentDetailInfoUI:InitDescPanel()
    self.desc.text = self.equipment_data.desc
    self.desc_panel:SetActive(true)
end

function EquipmentDetailInfoUI:ClearAllGo()
    self:ClearStarItem()
    for _, suit_equip_item in pairs(self.suit_equip_item_dict) do
        self:DelUIObject(suit_equip_item)
    end
    self.suit_equip_item_dict = {}
    for _, attr_item in pairs(self.suit_item_attr_list) do
        self:DelUIObject(attr_item)
    end
    self.suit_item_attr_list = {}
    for _, attr_item in pairs(self.suit_item_spell_list) do
        self:DelUIObject(attr_item)
    end
    self.suit_item_spell_list = {}
    for _, spell_item in pairs(self.spell_item_dict) do
        self:DelUIObject(spell_item)
    end
    self.spell_item_dict = {}
end

function EquipmentDetailInfoUI:ClearStarItem()
    for _, star_item in ipairs(self.star_item_list) do
        self:DelUIObject(star_item)
    end
    self.star_item_list = {}
end

return EquipmentDetailInfoUI