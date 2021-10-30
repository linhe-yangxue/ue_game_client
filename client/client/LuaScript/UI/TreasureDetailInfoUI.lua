local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local DyDataConst = require("DynamicData.DyDataConst")
local CSFunction = require("CSCommon.CSFunction")

local TreasureDetailInfoUI = class("UI.TreasureDetailInfoUI", UIBase)

local kSuitTreasureCount = 3

function TreasureDetailInfoUI:DoInit()
    TreasureDetailInfoUI.super.DoInit(self)
    self.prefab_path = "UI/Common/TreasureDetailInfoUI"
    self.suit_effect_list = {}
    self.star_limit = SpecMgrs.data_mgr:GetParamData("hero_star_lv_limit").f_value
    self.star_list = {}
    self.dy_night_club_data = ComMgrs.dy_data_mgr.night_club_data
    self.dy_bag_data = ComMgrs.dy_data_mgr.bag_data
    self.spell_item_dict = {}
end

function TreasureDetailInfoUI:OnGoLoadedOk(res_go)
    TreasureDetailInfoUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function TreasureDetailInfoUI:Hide()
    self:ClearSpellItem()
    self.dy_bag_data:UnregisterUpdateBagItemEvent("TreasureDetailInfoUI")
    TreasureDetailInfoUI.super.Hide(self)
end

function TreasureDetailInfoUI:Show(guid)
    self.treasure_guid = guid
    if self.is_res_ok then
        self:InitUI()
    end
    TreasureDetailInfoUI.super.Show(self)
end

function TreasureDetailInfoUI:InitRes()
    local content = self.main_panel:FindChild("Content")
    local top_bar = content:FindChild("TopBar")
    UIFuncs.InitTopBar(self, top_bar, "TreasureDetailInfoUI")
    self.treasure_type = top_bar:FindChild("CloseBtn/Title"):GetComponent("Text")

    local detail_info_panel = content:FindChild("DetailInfoPanel")
    self.treasure_grade = detail_info_panel:FindChild("TreasureInfo/Grade"):GetComponent("Image")
    self.treasure_img = detail_info_panel:FindChild("TreasureInfo/TreasureImg"):GetComponent("Image")
    local treasure_tip = detail_info_panel:FindChild("TreasureInfo/TreasureTip")
    self.treasure_quality = treasure_tip:FindChild("Quality/Title"):GetComponent("Text")
    self.treasure_potential = treasure_tip:FindChild("Potential/Text"):GetComponent("Text")
    self.treasure_name = detail_info_panel:FindChild("InfoPanel/TreasureName/Text"):GetComponent("Text")
    local info_panel = detail_info_panel:FindChild("InfoPanel/Viewport/Content")
    self.info_panel_rect_cmp = info_panel:GetComponent("RectTransform")
    -- 强化属性
    self.strength_attr_panel = info_panel:FindChild("StrengthAttrPanel")
    self.strength_attr_panel:FindChild("Header/Title"):GetComponent("Text").text = UIConst.Text.STRENGTH_ATTR_TEXT
    local strength_content = self.strength_attr_panel:FindChild("Content")
    self.strength_lv = strength_content:FindChild("StrengthLv"):GetComponent("Text")
    self.strength_attr = strength_content:FindChild("StrengthAttr"):GetComponent("Text")
    self.strength_extra_attr = strength_content:FindChild("ExtraAttr"):GetComponent("Text")
    self.strength_btn = strength_content:FindChild("StrengthBtn")
    self.strength_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.STRENGTH_TEXT
    self:AddClick(self.strength_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("TreasureCultivateUI", self.treasure_guid, CSConst.TreasureCultivateOperation.Strengthen)
    end)
    -- 精炼属性
    self.refine_attr_panel = info_panel:FindChild("RefineAttrPanel")
    self.refine_attr_panel:FindChild("Header/Title"):GetComponent("Text").text = UIConst.Text.REFINE_ATTR_TEXT
    local refine_content = self.refine_attr_panel:FindChild("Content")
    self.refine_lv = refine_content:FindChild("RefineLv"):GetComponent("Text")
    self.refine_attr = refine_content:FindChild("RefineAttr"):GetComponent("Text")
    self.refine_extra_attr = refine_content:FindChild("ExtraAttr"):GetComponent("Text")
    self.refine_btn = refine_content:FindChild("RefineBtn")
    self.refine_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.REFINE_TEXT
    self:AddClick(self.refine_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("TreasureCultivateUI", self.treasure_guid, CSConst.TreasureCultivateOperation.Refine)
    end)
    -- -- 升星属性
    self.add_star_attr_panel = info_panel:FindChild("AddStarPanel")
    -- self.add_star_attr_panel:FindChild("Header/Title"):GetComponent("Text").text = UIConst.Text.ADD_STAR
    -- local add_star_content = self.add_star_attr_panel:FindChild("Content")
    -- local star_lv_panel = add_star_content:FindChild("StarLvPanel")
    -- self.star_lv = add_star_content:FindChild("StarLv"):GetComponent("Text")
    -- self.star_attr = add_star_content:FindChild("StarAttr"):GetComponent("Text")
    -- self.star_extra_attr = add_star_content:FindChild("ExtraAttr"):GetComponent("Text")
    -- self.add_star_btn = add_star_content:FindChild("AddStarBtn")
    -- self.add_star_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ADD_STAR
    -- self:AddClick(self.add_star_btn, function ()
    --     -- TODO 前往宝物升星
    -- end)
    -- 神兵技能
    self.spell_panel = info_panel:FindChild("SpellPanel")
    self.spell_panel:FindChild("Header/Title"):GetComponent("Text").text = UIConst.Text.TREASURE_SPELL_TEXT
    self.spell_content = self.spell_panel:FindChild("Content")
    self.spell_item = self.spell_content:FindChild("SpellItem")
    -- --升星技能
    self.star_spell_panel = info_panel:FindChild("StarSpellPanel")
    self.star_spell_panel:FindChild("Header/Title"):GetComponent("Text").text = UIConst.Text.TREASURE_STAR_SPELL_TEXT
    self.star_spell_content = self.star_spell_panel:FindChild("Content")
    self.star_spell_item = self.star_spell_content:FindChild("StarSpellItem")
    -- 描述
    self.desc_panel = info_panel:FindChild("DescPanel")
    self.desc_panel:FindChild("Header/Title"):GetComponent("Text").text = UIConst.Text.DESC_TEXT
    self.desc = self.desc_panel:FindChild("Content/Desc"):GetComponent("Text")

    local bottom_panel = content:FindChild("BottomPanel")
    local unload_btn = bottom_panel:FindChild("UnloadBtn")
    unload_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.UNLOAD_TEXT
    self:AddClick(unload_btn, function ()
        SpecMgrs.msg_mgr:SendLineupUnwearEquip({lineup_id = self.treasure_info.lineup_id, part_index = self.treasure_data.part_index}, function (resp)
            if resp.errcode ~= 0 then
                SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.UNLOAD_FAILED_TEXT)
                return
            end
            self:Hide()
        end)
    end)
    local replace_btn = bottom_panel:FindChild("ReplaceBtn")
    replace_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.REPLACE_TEXT
    self:AddClick(replace_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("SelectEquipUI", {lineup_id = self.treasure_info.lineup_id, part_index = self.treasure_data.part_index})
        self:Hide()
    end)
end

function TreasureDetailInfoUI:InitUI()
    self.treasure_info = self.dy_bag_data:GetBagItemDataByGuid(self.treasure_guid)
    if not self.treasure_info then
        self:Hide()
        return
    end
    self.treasure_data = SpecMgrs.data_mgr:GetItemData(self.treasure_info.item_id)
    self.equipment_quality_data = SpecMgrs.data_mgr:GetQualityData(self.treasure_data.quality)
    self:InitBasicData()
    self:InitStrengthAttrPanel()
    self:InitRefineAttrPanel()
    self:InitAddStarPanel()
    self:InitSpellPanel()
    self:InitAddStarSpellPanel()
    self:InitDescPanel()
    self.info_panel_rect_cmp.anchoredPosition = Vector2.zero
    self.dy_bag_data:RegisterUpdateBagItemEvent("TreasureDetailInfoUI", self.UpdateTreasureInfo, self)
end

function TreasureDetailInfoUI:UpdateTreasureInfo(_, op, item)
    if op == DyDataConst.BagItemOpType.Update and item.guid == self.treasure_guid then
        self.treasure_info = self.dy_bag_data:GetBagItemDataByGuid(self.treasure_guid)
        self:InitStrengthAttrPanel()
        self:InitRefineAttrPanel()
        self:InitSpellPanel()
    end
end

function TreasureDetailInfoUI:InitBasicData()
    self.treasure_type.text = SpecMgrs.data_mgr:GetEquipPartData(self.treasure_data.part_index).name
    UIFuncs.AssignSpriteByIconID(self.treasure_data.icon, self.treasure_img)
    UIFuncs.AssignSpriteByIconID(self.equipment_quality_data.ground, self.treasure_grade)
    self.treasure_name.text = self.treasure_data.name
    local item_quality_data = SpecMgrs.data_mgr:GetQualityData(self.treasure_data.quality)
    self.treasure_quality.text = item_quality_data.name
    -- TODO 潜力
end

function TreasureDetailInfoUI:InitStrengthAttrPanel()
    local treasure_strength_lv_list = SpecMgrs.data_mgr:GetAllStrengthenLvData()
    local max_strength_lv = #treasure_strength_lv_list
    local color = self.treasure_info.strengthen_lv < max_strength_lv and UIConst.Color.Red1 or UIConst.Color.Default
    self.strength_lv.text = string.format(UIConst.Text.STRENGTH_LV_FORMAT, color, self.treasure_info.strengthen_lv, max_strength_lv)
    local attr_dict = CSFunction.get_equip_strengthen_attr(self.treasure_data.id, self.treasure_info.strengthen_lv)
    local base_attr = self.treasure_data.base_attr_list[1]
    self.strength_attr.text = UIFuncs.GetAttrStr(base_attr, attr_dict[base_attr] or 0)
    local extra_attr = self.treasure_data.base_attr_list[2]
    self.strength_extra_attr.text = UIFuncs.GetAttrStr(extra_attr, attr_dict[extra_attr] or 0)
    self.strength_btn:GetComponent("Button").interactable = self.treasure_info.strengthen_lv < max_strength_lv
    self.strength_btn:FindChild("Disable"):SetActive(self.treasure_info.strengthen_lv >= max_strength_lv)
    self.strength_btn:FindChild("RedPoint"):SetActive(self.dy_bag_data:CheckTreasureStrength(self.treasure_guid) == true)
    self.strength_attr_panel:SetActive(true)
end

function TreasureDetailInfoUI:InitRefineAttrPanel()
    local refine_lv_list = SpecMgrs.data_mgr:GetTreasureRefineLvList()
    local max_refine_lv = #refine_lv_list + 1
    local color = self.treasure_info.refine_lv < max_refine_lv and UIConst.Color.Red1 or UIConst.Color.Default
    self.refine_lv.text = string.format(UIConst.Text.REFINE_LV_FORMAT, color, self.treasure_info.refine_lv, max_refine_lv)
    local attr_dict = CSFunction.get_equip_refine_attr(self.treasure_data.id, self.treasure_info.refine_lv)
    local base_attr = self.treasure_data.refine_attr_list[1]
    self.refine_attr.text = UIFuncs.GetAttrStr(base_attr, attr_dict[base_attr] or 0)
    local extra_attr = self.treasure_data.refine_attr_list[2]
    self.refine_extra_attr.text = UIFuncs.GetAttrStr(extra_attr, attr_dict[extra_attr] or 0)
    self.refine_btn:GetComponent("Button").interactable = self.treasure_info.refine_lv < max_refine_lv
    self.refine_btn:FindChild("Disable"):SetActive(self.treasure_info.refine_lv >= max_refine_lv)
    self.refine_btn:FindChild("RedPoint"):SetActive(self.dy_bag_data:CheckTreasureRefine(self.treasure_guid) == true)
    self.refine_attr_panel:SetActive(true)
end

function TreasureDetailInfoUI:InitAddStarPanel()
    -- if self.treasure_data.star_cost then
    --     for i = 1, self.star_limit do
    --         self.star_list[i]:SetActive(self.treasure_info.star_lv >= i)
    --     end
    --     local attr_data = SpecMgrs.data_mgr:GetAttributeData(self.treasure_data.star_attr_list[1])
    --     local star_attr_value = self.treasure_data.star_attr_list_value[1] * self.treasure_info.star_lv
    --     self.star_attr.text = string.format(UIConst.Text.ATTR_VALUE_FORMAT, attr_data.name, star_attr_value)
    --     local extra_attr_data = SpecMgrs.data_mgr:GetAttributeData(self.treasure_data.star_attr_list[2])
    --     local extra_attr_value = self.treasure_data.star_attr_list_value[2] * self.treasure_info.star_lv
    --     self.star_extra_attr.text = string.format(UIConst.Text.ATTR_VALUE_FORMAT, extra_attr_data.name, extra_attr_value)
    --     self.add_star_btn:GetComponent("Button").interactable = self.treasure_info.star_lv < self.star_limit
    --     self.add_star_btn:FindChild("Disable"):SetActive(self.treasure_info.star_lv >= self.star_limit)
    -- end
    -- self.add_star_attr_panel:SetActive(self.treasure_data.star_cost ~= nil)
    self.add_star_attr_panel:SetActive(false)
end

function TreasureDetailInfoUI:InitAddStarSpellPanel()
    self.star_spell_panel:SetActive(false)
end

function TreasureDetailInfoUI:InitSpellPanel()
    self:ClearSpellItem()
    if self.treasure_data.refine_spell_list then
        for i, refine_spell_id in ipairs(self.treasure_data.refine_spell_list) do
            local spell_item = self:GetUIObject(self.spell_item, self.spell_content)
            self.spell_item_dict[refine_spell_id] = spell_item
            local is_active = self.treasure_info.refine_lv >= self.treasure_data.refine_level_list[i]
            local desc = UIFuncs.GetEquipSpellDesc(refine_spell_id, self.treasure_data.refine_level_list[i], is_active)
            local spell_color = is_active and UIConst.Color.ActiveColor or UIConst.Color.UnactiveColor
            spell_item:GetComponent("Text").text = string.format(UIConst.Text.SIMPLE_COLOR, spell_color, desc)
        end
    end
    self.spell_panel:SetActive(self.treasure_data.refine_spell_list and #self.treasure_data.refine_spell_list > 0)
end

function TreasureDetailInfoUI:InitDescPanel()
    self.desc.text = self.treasure_data.desc
    self.desc_panel:SetActive(true)
end

function TreasureDetailInfoUI:ClearSpellItem()
    for _, spell_item in pairs(self.spell_item_dict) do
        self:DelUIObject(spell_item)
    end
    self.spell_item_dict = {}
end

return TreasureDetailInfoUI