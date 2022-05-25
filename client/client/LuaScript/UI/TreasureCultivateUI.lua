local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local UnitConst = require("Unit.UnitConst")
local CSFunction = require("CSCommon.CSFunction")

local TreasureCultivateUI = class("UI.TreasureCultivateUI", UIBase)

local kMaxStrengthenMaterialCount = 10
local kMaterialDisapearDuation = 0.4
local kStrenghtenEffectDuration = 1
local kRefineEffectDuration = 1.3

function TreasureCultivateUI:DoInit()
    TreasureCultivateUI.super.DoInit(self)
    self.prefab_path = "UI/Common/TreasureCultivateUI"
    self.dy_bag_data = ComMgrs.dy_data_mgr.bag_data
    self.dy_night_club_data = ComMgrs.dy_data_mgr.night_club_data
    self.cultivate_op_data = {}
    self.material_item_list = {}
    self.cur_select_material_guid_list = {}
    self.cur_select_material_guid_dict = {}
    self.treasure_item_dict = {}
    self.select_treasure_dict = {}
    self.select_count = 0
    self.select_total_exp = 0
    self.cur_select_total_exp = 0
    self.auto_select_max_quality = SpecMgrs.data_mgr:GetParamData("auto_select_strengthen_material_max_quality").quality_id
    self.easy_strengthen_remind_quality_purple = SpecMgrs.data_mgr:GetParamData("remind_easy_strengthen_quality_purple").quality_id
    self.easy_strengthen_remind_quality_orange = SpecMgrs.data_mgr:GetParamData("remind_easy_strengthen_quality_orange").quality_id
    self.treasure_refine_cost_item = SpecMgrs.data_mgr:GetParamData("refine_treasure_cost_item").item_id
    self.treasure_refine_cost_coin = SpecMgrs.data_mgr:GetParamData("refine_treasure_cost_coin").item_id
    self.easy_material_list = {}
    self.red_treasure_item_list = SpecMgrs.data_mgr:GetParamData("grab_init_red_treasure_list").item_list
    self.gold_quality = SpecMgrs.data_mgr:GetParamData("gold_quality").quality_id
    self.hud_attr_item_list = {}
    self.select_refine_material_dict = {}

    self.treasure_cost_sound = SpecMgrs.data_mgr:GetParamData("treasure_cost_sound").sound_id
    self.treasure_upgrade_sound = SpecMgrs.data_mgr:GetParamData("treasure_upgrade_sound").sound_id
end

function TreasureCultivateUI:OnGoLoadedOk(res_go)
    TreasureCultivateUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function TreasureCultivateUI:Hide()
    self.cultivate_op = nil
    self:ClearAllTimer()
    self:ClearAttrHudItem()
    self:ClearSelectRefineMaterialItem()
    self:ClearTreasureItem()
    TreasureCultivateUI.super.Hide(self)
end

function TreasureCultivateUI:Show(treasure_guid, operation)
    self.cultivate_treasure_guid = treasure_guid
    self.cultivate_op = operation
    if self.is_res_ok then
        self:InitUI()
    end
    TreasureCultivateUI.super.Show(self)
end

function TreasureCultivateUI:InitRes()
    self.content = self.main_panel:FindChild("Content")
    UIFuncs.InitTopBar(self, self.content:FindChild("TopBar"), "TreasureCultivateUI", function ()
        self:Close()
        self:Hide()
    end)

    local tab_panel = self.content:FindChild("TabPanel")
    local tab_content = tab_panel:FindChild("TabList/View/Content")
    for _, op in pairs(CSConst.TreasureCultivateOperation) do
        self.cultivate_op_data[op] = {}
    end
    self.strengthen_btn = tab_content:FindChild("StrengthenBtn")
    self.strengthen_btn_cmp = self.strengthen_btn:GetComponent("Button")
    self.cultivate_op_data[CSConst.TreasureCultivateOperation.Strengthen].btn = self.strengthen_btn
    self.strengthen_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.STRENGTH_TEXT
    self.strengthen_btn:FindChild("Select/Text"):GetComponent("Text").text = UIConst.Text.STRENGTH_TEXT
    self:AddClick(self.strengthen_btn, function ()
        self:UpdateCultivatePanel(CSConst.TreasureCultivateOperation.Strengthen)
    end)
    self.refine_btn = tab_content:FindChild("RefineBtn")
    self.refine_btn_cmp = self.refine_btn:GetComponent("Button")
    self.cultivate_op_data[CSConst.TreasureCultivateOperation.Refine].btn = self.refine_btn
    self.refine_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.REFINE_TEXT
    self.refine_btn:FindChild("Select/Text"):GetComponent("Text").text = UIConst.Text.REFINE_TEXT
    self:AddClick(self.refine_btn, function ()
        self:UpdateCultivatePanel(CSConst.TreasureCultivateOperation.Refine)
    end)

    self.treasure_info_panel = self.content:FindChild("TreasureInfo")
    self.treasure_name = self.treasure_info_panel:FindChild("NamePanel/Text"):GetComponent("Text")
    self.treasure_img = self.treasure_info_panel:FindChild("TreasureImg")
    self.treasure_img_cmp = self.treasure_img:GetComponent("Image")
    self.cultivate_op_data[CSConst.TreasureCultivateOperation.Refine].effect = self.treasure_info_panel:FindChild("zhuangbei_jinglian1")
    self.cultivate_op_data[CSConst.TreasureCultivateOperation.Refine].effect_time = kRefineEffectDuration

    self.level_up_hud = self.content:FindChild("LevelUpHud")
    self.level_up_master_hud_panel = self.level_up_hud:FindChild("MasterPanel")
    self.level_up_master_hud_level = self.level_up_master_hud_panel:FindChild("MasterLv"):GetComponent("Text")
    self.level_up_hud_attr = self.level_up_master_hud_panel:FindChild("Attr")
    self.level_up_attr_hud_panel = self.level_up_hud:FindChild("AttrPanel")
    self.level_up_hud_level = self.level_up_attr_hud_panel:FindChild("Level"):GetComponent("Text")

    -- 升级
    self.strengthen_panel = self.content:FindChild("StrengthPanel")
    self.cultivate_op_data[CSConst.TreasureCultivateOperation.Strengthen].panel = self.strengthen_panel
    self.cultivate_op_data[CSConst.TreasureCultivateOperation.Strengthen].init_func = self.InitStrengthenPanel
    self.cultivate_op_data[CSConst.TreasureCultivateOperation.Strengthen].update_cost_func = self.UpdateStrengthenCost
    self.cultivate_op_data[CSConst.TreasureCultivateOperation.Strengthen].master_lv_format = UIConst.Text.TS_MASTER_LV_UP_FORMAT
    local strengthen_content = self.strengthen_panel:FindChild("Content/StrengthContent")
    local material_panel = strengthen_content:FindChild("MaterialPanel")
    for i = 1, kMaxStrengthenMaterialCount do
        local material_item = material_panel:FindChild("Material" .. i)
        local material_data = {}
        material_data.route_effect = material_item:FindChild("RouteEffect")
        material_data.item_icon = material_item:FindChild("IconBg")
        local add_btn = material_item:FindChild("Add")
        self:AddClick(add_btn, function ()
            if self.treasure_info.strengthen_lv >= self.strengthen_lv_limit then
                SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.STRENGTHEN_LIMIT)
                return
            end
            self:InitTreasureMaterialPanel()
        end)
        material_data.add_btn_cmp = add_btn:GetComponent("Button")
        local remove_btn = material_item:FindChild("Remove")
        self:AddClick(remove_btn, function ()
            local guid = table.remove(self.cur_select_material_guid_list, i)
            local item_info = self.dy_bag_data:GetBagItemDataByGuid(guid)
            self.cur_select_total_exp = self.cur_select_total_exp - item_info.strengthen_exp - item_info.item_data.add_exp
            self.cur_select_material_guid_dict[guid] = nil
            self:UpdateStrengthenMaterialList()
        end)
        material_data.remove_btn = material_item:FindChild("Remove")
        local strengthen_effect = material_item:FindChild("StrengthenEffect")
        material_data.strengthen_effect = strengthen_effect
        material_data.effect_icon = strengthen_effect:FindChild("dbwf_dj4"):GetComponent("Image")
        self.material_item_list[i] = material_data
    end
    self.strengthen_treasure_icon = strengthen_content:FindChild("TreasureIcon"):GetComponent("Image")
    self.strengthen_treasure_name = strengthen_content:FindChild("TreasureIcon/Name/Text"):GetComponent("Text")
    self.cultivate_op_data[CSConst.TreasureCultivateOperation.Strengthen].effect = strengthen_content:FindChild("StrengthenEffect")
    self.cultivate_op_data[CSConst.TreasureCultivateOperation.Strengthen].effect_time = kStrenghtenEffectDuration
    local bottom_panel = self.strengthen_panel:FindChild("BottomPanel")
    self.cur_strenghthen_lv = bottom_panel:FindChild("LevelPanel/Level"):GetComponent("Text")
    self.add_strengthen_lv = bottom_panel:FindChild("LevelPanel/AddLevel")
    self.add_strengthen_lv_text = self.add_strengthen_lv:GetComponent("Text")
    local strengthen_exp_bar = bottom_panel:FindChild("ExpBar")
    self.cur_strengthen_exp = strengthen_exp_bar:FindChild("CurExp"):GetComponent("Image")
    self.pre_strengthen_exp = strengthen_exp_bar:FindChild("PreExp")
    self.pre_strengthen_exp_img = self.pre_strengthen_exp:GetComponent("Image")
    self.cur_strengthen_exp_value = strengthen_exp_bar:FindChild("ExpValue"):GetComponent("Text")
    local attr_info_panel = bottom_panel:FindChild("AttrInfoPanel")
    local attr_panel = attr_info_panel:FindChild("AttrPanel")
    self.strengthen_attr_name = attr_panel:FindChild("Text"):GetComponent("Text")
    self.strengthen_attr_value = attr_panel:FindChild("Attr"):GetComponent("Text")
    self.strengthen_attr_add_value = attr_panel:FindChild("AddAttr")
    self.strengthen_attr_add_value_text = self.strengthen_attr_add_value:GetComponent("Text")
    self.extra_attr_panel = attr_info_panel:FindChild("ExtraAttrPanel")
    self.strengthen_extra_attr_name = self.extra_attr_panel:FindChild("Text"):GetComponent("Text")
    self.strengthen_extra_attr_value = self.extra_attr_panel:FindChild("ExtraAttr"):GetComponent("Text")
    self.strengthen_attr_add_extra_value = self.extra_attr_panel:FindChild("AddExtraAttr")
    self.strengthen_attr_add_extra_value_text = self.strengthen_attr_add_extra_value:GetComponent("Text")
    self.easy_strengthen_btn = bottom_panel:FindChild("EasyStrengthenBtn")
    self.easy_strengthen_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.EASY_STRENGTHEN_TEXT
    self:AddClick(self.easy_strengthen_btn, function ()
        if self.treasure_info.strengthen_lv >= self.strengthen_lv_limit then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.STRENGTHEN_LIMIT)
            return
        end
        self.use_purple_treasure = true
        self.use_orange_treasure = true
        local easy_material_list = self.dy_bag_data:CalcTreasureStrengthenLv(self.cultivate_treasure_guid)
        if easy_material_list then
            self:InitEasyStrengthenPanel(easy_material_list)
            self.purple_toggle:GetComponent("Toggle").isOn = false
            self.orange_toggle:GetComponent("Toggle").isOn = false
            self.select_count_panel:SetActive(true)
        elseif easy_material_list == nil then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.STRENGTHEN_MATERIAL_NOT_ENOUGH)
        else
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.STRENGTHEN_COST_FAILED)
        end
    end)
    self.treasure_strengthen_btn = bottom_panel:FindChild("StrengthenBtn")
    self.treasure_strengthen_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.STRENGTH_TEXT
    self:AddClick(self.treasure_strengthen_btn, function ()
        self:SendStrengthenTreasure()
    end)
    self.auto_add_btn = bottom_panel:FindChild("AutoAddBtn")
    self.auto_add_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.AUTO_ADD_TEXT
    self:AddClick(self.auto_add_btn, function ()
        self:AutoAddStrengthenMaterial()
    end)
    self.treasure_strengthen_btn:FindChild("MoneyCost/Text"):GetComponent("Text").text = UIConst.Text.COST_TEXT
    self.strenghthen_money_cost_count = self.treasure_strengthen_btn:FindChild("MoneyCost/Count"):GetComponent("Text")

    -- 精炼
    self.refine_panel = self.content:FindChild("RefinePanel")
    self.refine_img = self.refine_panel:FindChild("Image")
    self.cultivate_op_data[CSConst.TreasureCultivateOperation.Refine].panel = self.refine_panel
    self.cultivate_op_data[CSConst.TreasureCultivateOperation.Refine].init_func = self.InitRefinePanel
    self.cultivate_op_data[CSConst.TreasureCultivateOperation.Refine].update_cost_func = self.UpdateRefineCost
    self.cultivate_op_data[CSConst.TreasureCultivateOperation.Refine].master_lv_format = UIConst.Text.TR_MASTER_LV_UP_FORMAT
    self.cur_refine_lv = self.refine_panel:FindChild("RefineLv"):GetComponent("Text")
    local left_attr_panel = self.refine_panel:FindChild("LeftAttrPanel")
    left_attr_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CUR_STAGE_ATTR
    self.before_refine_attr = left_attr_panel:FindChild("Atk"):GetComponent("Text")
    self.before_refine_extra_attr = left_attr_panel:FindChild("ExtraAttr"):GetComponent("Text")
    self.refine_right_attr_panel = self.refine_panel:FindChild("RightAttrPanel")
    self.refine_right_attr_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.NEXT_STAGE_ATTR
    self.after_refine_attr = self.refine_right_attr_panel:FindChild("Atk"):GetComponent("Text")
    self.after_refine_extra_attr = self.refine_right_attr_panel:FindChild("ExtraAttr"):GetComponent("Text")
    local bottom_panel = self.refine_panel:FindChild("BottomPanel")
    local material_panel = bottom_panel:FindChild("MaterialPanel")
    local refine_cost_item = material_panel:FindChild("CostItem")
    UIFuncs.InitItemGo({
        go = refine_cost_item:FindChild("Item"),
        ui = self,
        item_id = self.treasure_refine_cost_item,
        name_go = refine_cost_item:FindChild("Name"),
        change_name_color = true,
    })
    self.refine_cost_item_count = refine_cost_item:FindChild("Count"):GetComponent("Text")

    self.refine_cost_treasure = material_panel:FindChild("TreasureItem")
    self.refine_cost_treasure_item = self.refine_cost_treasure:FindChild("Item")
    self.refine_cost_treasure_name = self.refine_cost_treasure:FindChild("Name")
    self.refine_cost_treasure_count = self.refine_cost_treasure:FindChild("Count"):GetComponent("Text")

    self.treasure_refine_btn = bottom_panel:FindChild("RefinePanel/RefineBtn")
    self.treasure_refine_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.REFINE_TEXT
    self.treasure_refine_btn_cmp = self.treasure_refine_btn:GetComponent("Button")
    self:AddClick(self.treasure_refine_btn, function ()
        self:SendRefineTreasure()
    end)
    self.treasure_refine_disable = self.treasure_refine_btn:FindChild("Disable")
    self.treasure_refine_money_cost = bottom_panel:FindChild("RefinePanel/MoneyCost/Count"):GetComponent("Text")

    self.select_material_panel = self.main_panel:FindChild("SelectMaterialPanel")
    local top_panel = self.select_material_panel:FindChild("TopBar")
    top_panel:FindChild("CloseBtn/Title"):GetComponent("Text").text = UIConst.Text.SELECT_MATERIAL_TEXT
    self:AddClick(top_panel:FindChild("CloseBtn"), function ()
        self.select_count = 0
        self.select_treasure_dict = {}
        self.select_material_panel:SetActive(false)
        self:ClearTreasureItem()
    end)
    self:AddClick(top_panel:FindChild("HelpBtn"), function ()
        UIFuncs.ShowPanelHelp("SelectStrengthenMaterial")
    end)
    self.select_material_content = self.select_material_panel:FindChild("Content/View/Content")
    self.select_treasure_item = self.select_material_content:FindChild("TreasureItem")
    bottom_panel = self.select_material_panel:FindChild("BottomPanel")
    self.cur_select_exp = bottom_panel:FindChild("CurExp"):GetComponent("Text")
    self.need_exp = bottom_panel:FindChild("NeedExp"):GetComponent("Text")
    local select_material_submit_btn = bottom_panel:FindChild("SubmitBtn")
    select_material_submit_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CONFIRM
    self:AddClick(select_material_submit_btn, function ()
        self.select_count = 0
        self.cur_select_material_guid_list = {}
        for guid, _ in pairs(self.select_treasure_dict) do
            table.insert(self.cur_select_material_guid_list, guid)
            self.cur_select_material_guid_dict[guid] = true
        end
        self.cur_select_total_exp = self.select_total_exp
        self.select_treasure_dict = {}
        self.select_material_panel:SetActive(false)
        self:UpdateStrengthenMaterialList()
        self:ClearTreasureItem()
    end)

    self.select_count_panel = self.main_panel:FindChild("SelectCountPanel")
    local select_count_content = self.select_count_panel:FindChild("Content")
    select_count_content:FindChild("Title"):GetComponent("Text").text = UIConst.Text.EASY_STRENGTHEN_TEXT
    self:AddClick(select_count_content:FindChild("CloseBtn"), function ()
        self.select_count_panel:SetActive(false)
    end)
    self.item_panel = select_count_content:FindChild("Item")
    self.icon_frame = self.item_panel:FindChild("Frame"):GetComponent("Image")
    self.icon_in_count_panel = self.item_panel:FindChild("Icon"):GetComponent("Image")
    self.treasure_name_in_count_panel = self.item_panel:FindChild("Name"):GetComponent("Text")
    self.cur_strengthen_lv_in_count_panel = self.item_panel:FindChild("LvPanel/Lv"):GetComponent("Text")
    self.select_strengthen_lv_in_count_panel = self.item_panel:FindChild("LvPanel/SelectLv"):GetComponent("Text")

    local cost_panel = select_count_content:FindChild("CostPanel")
    cost_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.COST_TEXT
    self.easy_cost_money = cost_panel:FindChild("Money/Count"):GetComponent("Text")
    self.easy_cost_exp = select_count_content:FindChild("Exp/Count"):GetComponent("Text")

    local select_panel = select_count_content:FindChild("SelectPanel")
    self:AddClick(select_panel:FindChild("ReduceTen"), function ()
        self:SetNearestStrengthenLevel(self.cur_select_lv - 10)
        self:UpdateSelectStrengthenLvPanel()
    end)
    self:AddClick(select_panel:FindChild("Reduce"), function ()
        self:SetNearestStrengthenLevel(self.cur_select_lv - 1)
        self:UpdateSelectStrengthenLvPanel()
    end)
    self.cur_strengthen_count = select_panel:FindChild("Count/Text"):GetComponent("Text")
    self:AddClick(select_panel:FindChild("Add"), function ()
        self:SetNearestStrengthenLevel(self.cur_select_lv + 1)
        self:UpdateSelectStrengthenLvPanel()
    end)
    self:AddClick(select_panel:FindChild("AddTen"), function ()
        self:SetNearestStrengthenLevel(self.cur_select_lv + 10)
        self:UpdateSelectStrengthenLvPanel()
    end)

    self.purple_toggle = select_count_content:FindChild("PurpleToggle")
    self.purple_toggle:FindChild("Label"):GetComponent("Text").text = UIConst.Text.USE_PURPLE_TREASURE
    self:AddToggle(self.purple_toggle, function (is_on)
        self.use_purple_treasure = is_on
        self:InitEasyStrengthenPanel(self.dy_bag_data:CalcTreasureStrengthenLv(self.cultivate_treasure_guid))
    end)
    self.orange_toggle = select_count_content:FindChild("OrangeToggle")
    self.orange_toggle:FindChild("Label"):GetComponent("Text").text = UIConst.Text.USE_ORANGE_TREASURE
    self:AddToggle(self.orange_toggle, function (is_on)
        self.use_orange_treasure = is_on
        self:InitEasyStrengthenPanel(self.dy_bag_data:CalcTreasureStrengthenLv(self.cultivate_treasure_guid))
    end)

    local cancel_btn = select_count_content:FindChild("BtnPanel/CancelBtn")
    cancel_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CANCEL
    self:AddClick(cancel_btn, function ()
        self.cur_select_lv = 0
        self.easy_material_list = {}
        self.select_count_panel:SetActive(false)
    end)
    local easy_strengthen_submit_btn = select_count_content:FindChild("BtnPanel/SubmitBtn")
    easy_strengthen_submit_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CONFIRM
    self:AddClick(easy_strengthen_submit_btn, function ()
        if self.cur_select_lv == self.treasure_info.strengthen_lv then
            self.select_count_panel:SetActive(false)
            return
        end
        self.cur_select_material_guid_list = {}
        self.cur_select_material_guid_dict = {}
        self.cur_select_total_exp = 0
        for _, material_list in ipairs(self.easy_material_list) do
            if material_list.level <= self.cur_select_lv then
                for _, guid in ipairs(material_list.guid_list) do
                    table.insert(self.cur_select_material_guid_list, guid)
                    self.cur_select_material_guid_dict[guid] = true
                end
            end
        end
        self.easy_material_list = {}
        self.select_count_panel:SetActive(false)
        self:UpdateStrengthenMaterialList()
        self:SendStrengthenTreasure()
    end)

    -- 选择精炼材料
    self.select_refine_material_panel = self.main_panel:FindChild("SelectRefineMaterial")
    local select_refine_material_content = self.select_refine_material_panel:FindChild("Content")
    select_refine_material_content:FindChild("Title"):GetComponent("Text").text = UIConst.Text.SELECT_TREASURE
    self:AddClick(select_refine_material_content:FindChild("CloseBtn"), function ()
        self.select_refine_material_panel:SetActive(false)
    end)
    self.select_treasure_panel = select_refine_material_content:FindChild("TreasurePanel")
    self.treasure_item = self.select_treasure_panel:FindChild("TreasureItem")
    local select_submit_btn = select_refine_material_content:FindChild("BtnPanel/SubmitBtn")
    select_submit_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CONFIRM
    self:AddClick(select_submit_btn, function ()
        self.cur_select_refine_material = self.temp_select_refine_material
        self:InitRefinePanel()
        self.select_refine_material_panel:SetActive(false)
    end)
    self.effect_mask = self.main_panel:FindChild("EffectMask")
end

function TreasureCultivateUI:InitUI()
    if not self.cultivate_treasure_guid then
        self:Hide()
        return
    end
    self.treasure_info = self.dy_bag_data:GetBagItemDataByGuid(self.cultivate_treasure_guid)
    self.last_score = ComMgrs.dy_data_mgr:ExGetRoleScore()
    self.last_fight_score = ComMgrs.dy_data_mgr:ExGetFightScore()
    self.lineup_data = self.dy_night_club_data:GetLineupData(self.treasure_info.lineup_id)
    self.treasure_data = SpecMgrs.data_mgr:GetItemData(self.treasure_info.item_id)
    self.quality_data = SpecMgrs.data_mgr:GetQualityData(self.treasure_data.quality)
    self.fragment_data = SpecMgrs.data_mgr:GetItemData(self.treasure_data.fragment)
    self.treasure_name.text = self.treasure_data.name
    UIFuncs.AssignSpriteByIconID(self.treasure_data.icon, self.treasure_img_cmp)
    self.strengthen_lv_limit = #SpecMgrs.data_mgr:GetAllStrengthenLvData()
    self.refine_lv_limit = #SpecMgrs.data_mgr:GetTreasureRefineLvList()
    self:UpdateCultivatePanel(self.cultivate_op)
    self:RegisterEvent(ComMgrs.dy_data_mgr, "UpdateCurrencyEvent", function (_, currency)
        UIFuncs.UpdateCurrencyItemNum(self._item_to_text_list, currency)
        self:UpdateCultivateCost()
    end)
    self:RegisterEvent(self.dy_bag_data, "UpdateBagItemEvent", function ()
        self:UpdateCultivateCost()
    end)
end

function TreasureCultivateUI:UpdateCultivateCost()
    local cur_op_data = self.cultivate_op_data[self.cur_cultivate_op]
    if cur_op_data.update_cost_func then
        cur_op_data.update_cost_func(self)
    end
end

function TreasureCultivateUI:UpdateBtnState()
    self.strengthen_btn_cmp.interactable = self.treasure_info.strengthen_lv < self.strengthen_lv_limit
    self.refine_btn_cmp.interactable = self.treasure_info.refine_lv < self.refine_lv_limit
end

function TreasureCultivateUI:UpdateCultivatePanel(cultivate_op)
    if self.cur_cultivate_op and self.cur_cultivate_op ~= cultivate_op then
        local last_cultivate_op_data = self.cultivate_op_data[self.cur_cultivate_op]
        last_cultivate_op_data.btn:FindChild("Select"):SetActive(false)
        last_cultivate_op_data.panel:SetActive(false)
        if last_cultivate_op_data.result_panel then last_cultivate_op_data.result_panel:SetActive(false) end
    end
    self.cur_cultivate_op = cultivate_op
    self.treasure_info_panel:SetActive(self.cur_cultivate_op ~= CSConst.TreasureCultivateOperation.Strengthen)
    local cur_cultivate_op_data = self.cultivate_op_data[self.cur_cultivate_op]
    cur_cultivate_op_data.btn:FindChild("Select"):SetActive(true)
    cur_cultivate_op_data.panel:SetActive(true)
    if cur_cultivate_op_data.result_panel then cur_cultivate_op_data.result_panel:SetActive(true) end
    cur_cultivate_op_data.init_func(self)
end

function TreasureCultivateUI:InitStrengthenPanel()
    self.strengthen_treasure_name.text = self.treasure_data.name
    UIFuncs.AssignSpriteByIconID(self.treasure_data.icon, self.strengthen_treasure_icon)
    self.strengthen_treasure_name.text = self.treasure_data.name
    local cur_attr_dict = CSFunction.get_equip_strengthen_attr(self.treasure_data.id, self.treasure_info.strengthen_lv)
    self.strengthen_attr_data = SpecMgrs.data_mgr:GetAttributeData(self.treasure_data.base_attr_list[1])
    self.strengthen_attr_name.text = self.strengthen_attr_data.name
    local attr_format = self.strengthen_attr_data.is_pct and UIConst.Text.ADD_PERCENT or UIConst.Text.ADD_VALUE_FORMAL
    local attr_value = cur_attr_dict[self.strengthen_attr_data.id] or 0
    if not self.strengthen_attr_data.is_pct then attr_value = UIFuncs.AddCountUnit(attr_value or 0) end
    self.strengthen_attr_value.text = string.format(attr_format, attr_value)
    self.strengthen_extra_attr_data = SpecMgrs.data_mgr:GetAttributeData(self.treasure_data.base_attr_list[2])
    self.extra_attr_panel:SetActive(self.strengthen_extra_attr_data ~= nil)
    if self.strengthen_extra_attr_data then
        self.strengthen_extra_attr_name.text = self.strengthen_extra_attr_data.name
        local extra_attr_format = self.strengthen_extra_attr_data.is_pct and UIConst.Text.ADD_PERCENT or UIConst.Text.ADD_VALUE_FORMAL
        local extra_attr_value = cur_attr_dict[self.strengthen_extra_attr_data.id] or 0
        if not self.strengthen_attr_data.is_pct then attr_value = UIFuncs.AddCountUnit(extra_attr_value or 0) end
        self.strengthen_extra_attr_value.text = string.format(extra_attr_format, extra_attr_value)
    end
    self.cur_strenghthen_lv.text = string.format(UIConst.Text.LV_TEXT, self.treasure_info.strengthen_lv or 0)
    self:InitStrengthenMaterialList()
    self:UpdateStrengthenExp()
end

function TreasureCultivateUI:UpdateStrengthenExp()
    local treasure_info = self.dy_bag_data:GetBagItemDataByGuid(self.cultivate_treasure_guid)
    local strengthen_lv_list = SpecMgrs.data_mgr:GetAllStrengthenLvData()
    local strengthen_lv_data = strengthen_lv_list[treasure_info.strengthen_lv]
    local next_level_exp = strengthen_lv_data and strengthen_lv_data["exp_q" .. self.treasure_data.quality] or 0
    if treasure_info.strengthen_lv >= self.strengthen_lv_limit then
        self.cur_strengthen_exp.fillAmount = 1
        self.cur_strengthen_exp_value.text = string.format(UIConst.Text.PER_VALUE, next_level_exp, next_level_exp)
        self.cur_strengthen_need_exp = 0
    else
        local cur_level_exp = strengthen_lv_data["total_exp_q" .. self.treasure_data.quality]
        self.cur_strengthen_exp.fillAmount = (treasure_info.strengthen_exp - cur_level_exp) / next_level_exp
        self.cur_strengthen_exp_value.text = string.format(UIConst.Text.PER_VALUE, treasure_info.strengthen_exp - cur_level_exp, next_level_exp)
        self.cur_strengthen_need_exp = next_level_exp - treasure_info.strengthen_exp
    end
    self.pre_strengthen_exp:SetActive(false)
    if treasure_info.strengthen_lv > self.treasure_info.strengthen_lv then
        self:ShowCultivateEffect()
    else
        self.treasure_info = treasure_info
    end
end

function TreasureCultivateUI:InitStrengthenMaterialList()
    self.cur_select_material_guid_list = {}
    self.cur_select_material_guid_dict = {}
    self.cur_select_total_exp = 0
    for i, material_item in ipairs(self.material_item_list) do
        material_item.strengthen_effect:SetActive(false)
    end
    self.add_strengthen_lv:SetActive(false)
    self.strengthen_attr_add_value:SetActive(false)
    self.strengthen_attr_add_extra_value:SetActive(false)
    self:UpdateStrengthenMaterialList()
end

function TreasureCultivateUI:UpdateStrengthenMaterialList()
    local total_exp = 0
    self.strengthen_cost = 0
    local select_treasure_count = #self.cur_select_material_guid_list
    self.auto_add_btn:SetActive(select_treasure_count == 0)
    self.treasure_strengthen_btn:SetActive(select_treasure_count > 0)
    for i = 1, kMaxStrengthenMaterialCount do
        local material_data = self.material_item_list[i]
        local material_guid = self.cur_select_material_guid_list[i]
        material_data.route_effect:SetActive(material_guid ~= nil)
        material_data.item_icon:SetActive(material_guid ~= nil)
        material_data.add_btn_cmp.interactable = material_guid == nil
        material_data.remove_btn:SetActive(material_guid ~= nil)
        if material_guid then
            local material_info = self.dy_bag_data:GetBagItemDataByGuid(material_guid)
            UIFuncs.AssignSpriteByIconID(material_info.item_data.icon, material_data.item_icon:FindChild("Icon"):GetComponent("Image"))
            UIFuncs.AssignSpriteByIconID(material_info.item_data.icon, material_data.effect_icon:GetComponent("Image"))
            total_exp = total_exp + material_info.strengthen_exp + material_info.item_data.add_exp
            self.strengthen_cost = self.strengthen_cost + material_info.item_data.cost_coin
        end
    end
    self:UpdateStrengthenCost()
    self.pre_strengthen_exp:SetActive(total_exp > 0)
    if total_exp > 0 then
        local strengthen_lv_list = SpecMgrs.data_mgr:GetAllStrengthenLvData()
        local cur_level_data = strengthen_lv_list[self.treasure_info.strengthen_lv]
        local cur_level_exp = cur_level_data["total_exp_q" .. self.treasure_data.quality]
        local next_level_exp = cur_level_data["exp_q" .. self.treasure_data.quality]
        local cur_total_exp = total_exp + self.treasure_info.strengthen_exp
        local strengthen_lv = 0
        for i, strenghten_data in ipairs(strengthen_lv_list) do
            if cur_total_exp < strenghten_data["total_exp_q" .. self.treasure_data.quality] then
                strengthen_lv = i - self.treasure_info.strengthen_lv - 1
                break
            elseif i == self.strengthen_lv_limit then
                strengthen_lv = i - self.treasure_info.strengthen_lv
            end
        end
        self.pre_strengthen_exp_img.fillAmount = (cur_total_exp - cur_level_exp) / next_level_exp
        self.add_strengthen_lv:SetActive(strengthen_lv >= 1)
        self.strengthen_attr_add_value:SetActive(strengthen_lv >= 1)
        self.strengthen_attr_add_extra_value:SetActive(strengthen_lv >= 1 and self.strengthen_extra_attr_data ~= nil)
        if strengthen_lv >= 1 then
            self.add_strengthen_lv_text.text = string.format(UIConst.Text.ADD_VALUE_FORMAL, strengthen_lv)
            local cur_attr_dict = CSFunction.get_equip_strengthen_attr(self.treasure_data.id, self.treasure_info.strengthen_lv)
            local next_attr_dict = CSFunction.get_equip_strengthen_attr(self.treasure_data.id, self.treasure_info.strengthen_lv + strengthen_lv)
            local attr_add_value = next_attr_dict[self.strengthen_attr_data.id] - (cur_attr_dict and cur_attr_dict[self.strengthen_attr_data.id] or 0)
            local attr_format = self.strengthen_attr_data.is_pct and UIConst.Text.ADD_PERCENT or UIConst.Text.ADD_VALUE_FORMAL
            if not self.strengthen_attr_data.is_pct then attr_add_value = UIFuncs.AddCountUnit(attr_add_value or 0) end
            self.strengthen_attr_add_value_text.text = string.format(attr_format, attr_add_value)
            if self.strengthen_extra_attr_data then
                local extra_attr_format = self.strengthen_extra_attr_data.is_pct and UIConst.Text.ADD_PERCENT or UIConst.Text.ADD_VALUE_FORMAL
                local extra_attr_add_value = next_attr_dict[self.strengthen_extra_attr_data.id] - (cur_attr_dict and cur_attr_dict[self.strengthen_extra_attr_data.id] or 0)
                if not self.strengthen_extra_attr_data.is_pct then extra_attr_add_value = UIFuncs.AddCountUnit(extra_attr_add_value or 0) end
                self.strengthen_attr_add_extra_value_text.text = string.format(extra_attr_format, extra_attr_add_value)
            end
        end
    else
        self.add_strengthen_lv:SetActive(false)
        self.strengthen_attr_add_value:SetActive(false)
        self.strengthen_attr_add_extra_value:SetActive(false)
    end
end

function TreasureCultivateUI:UpdateStrengthenCost()
    if self.treasure_info.strengthen_lv >= self.strengthen_lv_limit then return end
    if not self.strengthen_cost then return end
    local cost_color = self.dy_bag_data:GetBagItemCount(CSConst.Virtual.Money) < self.strengthen_cost and UIConst.Color.Red1 or UIConst.Color.Default
    self.strenghthen_money_cost_count.text = string.format(UIConst.Text.SIMPLE_COLOR, cost_color, self.strengthen_cost)
end

function TreasureCultivateUI:GetTreasureList()
    local treasure_list = {}
    for i, treasure_data in pairs(self.dy_bag_data:GetAllTreasure()) do
        if treasure_data.guid ~= self.cultivate_treasure_guid and treasure_data.item_data.quality < self.auto_select_max_quality then
            local treasure_info = self.dy_bag_data:GetBagItemDataByGuid(treasure_data.guid)
            if not treasure_info.lineup_id then
                table.insert(treasure_list, treasure_info)
            end
        end
    end
    table.sort(treasure_list, function (treasure1, treasure2)
        local treasure1_exp = treasure1.strengthen_exp + treasure1.item_data.add_exp
        local treasure2_exp = treasure2.strengthen_exp + treasure2.item_data.add_exp
        if treasure1_exp ~= treasure2_exp then
            return treasure1_exp < treasure2_exp
        end
        return treasure1.item_data.quality < treasure2.item_data.quality
    end)
    return treasure_list
end

function TreasureCultivateUI:InitTreasureMaterialPanel()
    self.select_total_exp = self.cur_select_total_exp
    self.select_count = #self.cur_select_material_guid_list
    self.select_treasure_dict = {}
    for guid, _ in pairs(self.cur_select_material_guid_dict) do
        self.select_treasure_dict[guid] = true
    end
    local max_exp = SpecMgrs.data_mgr:GetStrengthenLvData(self.strengthen_lv_limit)["total_exp_q" .. self.treasure_data.quality] - self.treasure_info.strengthen_exp
    local treasure_list = self:GetTreasureList()
    for i, treasure_data in ipairs(treasure_list) do
        if treasure_data.guid ~= self.cultivate_treasure_guid then
            local treasure_info = self.dy_bag_data:GetBagItemDataByGuid(treasure_data.guid)
            local treasure_item = self:GetUIObject(self.select_treasure_item, self.select_material_content)
            local quality_data = SpecMgrs.data_mgr:GetQualityData(treasure_info.item_data.quality)
            UIFuncs.AssignSpriteByIconID(quality_data.bg, treasure_item:FindChild("IconBg"):GetComponent("Image"))
            UIFuncs.AssignSpriteByIconID(quality_data.frame, treasure_item:FindChild("IconBg/Frame"):GetComponent("Image"))
            UIFuncs.AssignSpriteByIconID(treasure_info.item_data.icon, treasure_item:FindChild("IconBg/Icon"):GetComponent("Image"))
            treasure_item:FindChild("NamePanel/Name"):GetComponent("Text").text = string.format(UIConst.Text.SIMPLE_COLOR, quality_data.color1, treasure_info.item_data.name)
            treasure_item:FindChild("NamePanel/StrengthenLv"):GetComponent("Text").text = string.format(UIConst.Text.LEVEL_FORMAT_TEXT, treasure_info.strengthen_lv)

            local equip_part_data = SpecMgrs.data_mgr:GetEquipPartData(treasure_info.item_data.part_index)
            treasure_item:FindChild("Type"):GetComponent("Text").text = equip_part_data and equip_part_data.name or UIConst.Text.EXP_TREASURE
            local attr = treasure_item:FindChild("ItemPanel/Attr")
            local extra_attr = treasure_item:FindChild("ItemPanel/ExtraAttr")
            attr:SetActive(treasure_info.item_data.base_attr_list ~= nil)
            extra_attr:SetActive(treasure_info.item_data.base_attr_list ~= nil)
            if treasure_info.item_data.base_attr_list then
                local attr_dict = CSFunction.get_equip_all_attr(treasure_info)
                local attr_data = SpecMgrs.data_mgr:GetAttributeData(treasure_info.item_data.base_attr_list[1])
                attr:GetComponent("Text").text = string.format(UIConst.Text.ATTR_VALUE_FORMAT, attr_data.name, attr_dict[attr_data.id])
                local extra_attr_data = SpecMgrs.data_mgr:GetAttributeData(treasure_info.item_data.base_attr_list[2])
                extra_attr:GetComponent("Text").text = string.format(UIConst.Text.ATTR_VALUE_FORMAT, extra_attr_data.name, attr_dict[extra_attr_data.id])
            end
            local refine_lv_item = treasure_item:FindChild("ItemPanel/RefineLv")
            refine_lv_item:SetActive(treasure_info.refine_lv > 0)
            if treasure_info.refine_lv > 0 then
                refine_lv_item:FindChild("Text"):GetComponent("Text").text = string.format(UIConst.Text.REFINE_LEVEL, treasure_info.refine_lv)
            end

            local treasure_exp = treasure_info.strengthen_exp + treasure_info.item_data.add_exp
            treasure_item:FindChild("Exp"):GetComponent("Text").text = string.format(UIConst.Text.EXP_UP, treasure_exp)
            local select_toggle = treasure_item:FindChild("SelectToggle")
            select_toggle:GetComponent("Toggle").isOn = self.cur_select_material_guid_dict[treasure_data.guid] ~= nil
            self:AddToggle(select_toggle, function (is_on)
                if is_on then
                    if self.select_count < kMaxStrengthenMaterialCount then
                        if self.select_total_exp >= max_exp then
                            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.STRENGTHEN_EXP_ENOUGH)
                            select_toggle:GetComponent("Toggle").isOn = false
                            return
                        end
                        self.select_treasure_dict[treasure_info.guid] = true
                        self.select_total_exp = self.select_total_exp + treasure_exp
                        self.cur_select_exp.text = string.format(UIConst.Text.GET_STRENGTHEN_TEXT, self.select_total_exp)
                        self.select_count = self.select_count + 1
                    else
                        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.SELECT_COUNT_LIMIT)
                        select_toggle:GetComponent("Toggle").isOn = false
                    end
                else
                    if self.select_treasure_dict[treasure_info.guid] then
                        self.select_treasure_dict[treasure_info.guid] = nil
                        self.select_total_exp = self.select_total_exp - treasure_exp
                        self.select_count = self.select_count - 1
                        self.cur_select_exp.text = string.format(UIConst.Text.GET_STRENGTHEN_TEXT, self.select_total_exp)
                    end
                end
            end)
            self.treasure_item_dict[treasure_info.guid] = treasure_item
        end
    end
    self.select_material_content:GetComponent("RectTransform").anchoredPosition = Vector2.zero
    self.cur_select_exp.text = string.format(UIConst.Text.GET_STRENGTHEN_TEXT, self.select_total_exp)
    self.need_exp.text = string.format(UIConst.Text.NEED_EXP_TEXT, self.cur_strengthen_need_exp)
    self.select_material_panel:SetActive(true)
    if #treasure_list == 0 then SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.WITHOUT_STRENGTHEN_MATERIAL) end
end

function TreasureCultivateUI:AutoAddStrengthenMaterial()
    if self.treasure_info.strengthen_lv >= self.strengthen_lv_limit then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.STRENGTHEN_LIMIT)
        return
    end
    local max_exp = SpecMgrs.data_mgr:GetStrengthenLvData(self.strengthen_lv_limit)["total_exp_q" .. self.treasure_data.quality] - self.treasure_info.strengthen_exp

    if self.cur_select_total_exp >= max_exp then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.STRENGTHEN_EXP_ENOUGH)
        return
    end
    local treasure_list = self:GetTreasureList()
    if #treasure_list == 0 then
        UIFuncs.ShowItemItemAccessUI(self.treasure_data.id)
    end
    local total_exp = self.cur_select_total_exp
    for _, treasure_data in ipairs(treasure_list) do
        if #self.cur_select_material_guid_list == kMaxStrengthenMaterialCount then
            break
        end
        if treasure_data.guid ~= self.cultivate_treasure_guid and not self.cur_select_material_guid_dict[treasure_data.guid] then
            if treasure_data.strengthen_lv == 1 and treasure_data.strengthen_exp == 0 and treasure_data.refine_lv == 0 then
                total_exp = total_exp + treasure_data.strengthen_exp + treasure_data.item_data.add_exp
                table.insert(self.cur_select_material_guid_list, treasure_data.guid)
                self.cur_select_material_guid_dict[treasure_data.guid] = true
                if total_exp >= max_exp then break end
            end
        end
    end
    --如果不满足等级1级、经验是0，精良是0的装备是不能通过自动添加加入的，所以加了下面的提示框
    if #self.cur_select_material_guid_list == 0 then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.STRENGTHEN_EMPTY)
    end
    self.cur_select_total_exp = total_exp
    self:UpdateStrengthenMaterialList()
end

function TreasureCultivateUI:InitRefinePanel()
    self.cur_refine_lv.text = string.format(UIConst.Text.CUR_REFINE_LV_FORMAT, self.treasure_info.refine_lv)
    local attr_id = self.treasure_data.refine_attr_list[1]
    local extra_attr_id = self.treasure_data.refine_attr_list[2]
    local before_attr_dict = CSFunction.get_equip_refine_attr(self.treasure_data.id, self.treasure_info.refine_lv)
    self.before_refine_attr.text = UIFuncs.GetAttrStr(attr_id, before_attr_dict[attr_id] or 0)
    self.before_refine_extra_attr.text = UIFuncs.GetAttrStr(extra_attr_id, before_attr_dict[extra_attr_id] or 0)

    local next_refine_lv = self.treasure_info.refine_lv + 1
    self.refine_right_attr_panel:SetActive(next_refine_lv <= self.refine_lv_limit)
    self.treasure_refine_btn_cmp.interactable = next_refine_lv <= self.refine_lv_limit
    self.treasure_refine_disable:SetActive(next_refine_lv > self.refine_lv_limit)
    self.refine_img:SetActive(next_refine_lv > self.refine_lv_limit)

    if next_refine_lv > self.refine_lv_limit then return end

    local after_attr_dict = CSFunction.get_equip_refine_attr(self.treasure_data.id, next_refine_lv)
    self.after_refine_attr.text = UIFuncs.GetAttrStr(attr_id, after_attr_dict[attr_id] or 0, true)
    self.after_refine_extra_attr.text = UIFuncs.GetAttrStr(extra_attr_id, after_attr_dict[extra_attr_id] or 0, true)

    local cost_data = SpecMgrs.data_mgr:GetTreasureRefineLvList()[self.treasure_info.refine_lv]
    local refine_material_cost_count = self.treasure_data.quality == self.gold_quality and cost_data.treasure_count or cost_data.treasure_num
    self.refine_cost_treasure:SetActive(refine_material_cost_count > 0)
    self:UpdateRefineCost()
    if refine_material_cost_count == 0 then return end
    local cost_treasure_data
    if self.treasure_data.quality == self.gold_quality then
        if self.cur_select_refine_material then
            cost_treasure_data = SpecMgrs.data_mgr:GetItemData(self.cur_select_refine_material)
        else
            for _, item_id in ipairs(self.red_treasure_item_list) do
                local item_data = SpecMgrs.data_mgr:GetItemData(item_id)
                if item_data.part_index == self.treasure_data.part_index then
                    self.cur_select_refine_material = item_id
                    cost_treasure_data = item_data
                    break
                end
            end
        end
    else
        cost_treasure_data = self.treasure_data
    end
    UIFuncs.InitItemGo({
        go = self.refine_cost_treasure_item,
        ui = self,
        item_data = cost_treasure_data,
        name_go = self.refine_cost_treasure_name,
        change_name_color = true,
        click_cb = function ()
            if self.treasure_data.quality < self.gold_quality then
                SpecMgrs.ui_mgr:ShowItemPreviewUI(cost_treasure_data.id)
            else
                self:InitSelectMaterialPanel()
            end
        end,
    })
end

function TreasureCultivateUI:UpdateRefineCost()
    if self.treasure_info.refine_lv >= self.refine_lv_limit then return end
    local cost_data = SpecMgrs.data_mgr:GetTreasureRefineLvList()[self.treasure_info.refine_lv]
    local own_item_num = self.dy_bag_data:GetBagItemCount(self.treasure_refine_cost_item)
    self.refine_cost_item_count.text = UIFuncs.GetPerStr(own_item_num, cost_data.item_num)
    local own_coin_num = self.dy_bag_data:GetBagItemCount(self.treasure_refine_cost_coin)
    local cost_coin_color = own_coin_num >= cost_data.coin_num and UIConst.Color.Default or UIConst.Color.Red1
    self.treasure_refine_money_cost.text = string.format(UIConst.Text.SIMPLE_COLOR, cost_coin_color, UIFuncs.AddCountUnit(cost_data.coin_num))
    local refine_material_cost_count = self.treasure_data.quality == self.gold_quality and cost_data.treasure_count or cost_data.treasure_num
    if refine_material_cost_count > 0 then
        local cost_treasure_item = self.cur_select_refine_material or self.treasure_data.id
        local own_treasure_count = self.dy_bag_data:GetTreasureItemCountWithoutCultivate(cost_treasure_item)
        self.refine_cost_treasure_count.text = UIFuncs.GetPerStr(own_treasure_count, refine_material_cost_count)
    end
end

function TreasureCultivateUI:ShowCultivateEffect()
    self.treasure_info = self.dy_bag_data:GetBagItemDataByGuid(self.cultivate_treasure_guid)
    if self.cur_cultivate_op == CSConst.TreasureCultivateOperation.Refine then
        self:AddTimer(function ()
            self:PlayUISound(self.treasure_upgrade_sound)
        end, 0.4)
    else
        self:PlayUISound(self.treasure_upgrade_sound)
    end
    if self.cultivate_op_data[self.cur_cultivate_op].effect then
        self.effect_mask:SetActive(true)
        self.cultivate_op_data[self.cur_cultivate_op].effect:SetActive(true)
        self.cultivate_effect_timer = self:AddTimer(function ()
            self:ShowTreasureCultivateSuccessPanel()
            self:ShowScoreUpUI()
            self.cultivate_op_data[self.cur_cultivate_op].effect:SetActive(false)
            self.effect_mask:SetActive(false)
            self.cultivate_effect_timer = nil
        end, self.cultivate_op_data[self.cur_cultivate_op].effect_time)
    else
        self:ShowTreasureCultivateSuccessPanel()
    end
end

function TreasureCultivateUI:ShowScoreUpUI()
    SpecMgrs.ui_mgr:ShowScoreUpUI(self.last_score, self.last_fight_score)
    self.last_score = ComMgrs.dy_data_mgr:ExGetRoleScore()
    self.last_fight_score = ComMgrs.dy_data_mgr:ExGetFightScore()
end

function TreasureCultivateUI:ShowTreasureCultivateSuccessPanel()
    if self.cultivate_op_data[self.cur_cultivate_op].result_panel then
        self.result_panel:SetActive(true)
        self.content:SetActive(false)
    else
        self.cultivate_op_data[self.cur_cultivate_op].init_func(self)
    end
end

function TreasureCultivateUI:InitEasyStrengthenPanel(easy_material_list)
    if not easy_material_list then return end
    self.easy_material_list = {}
    UIFuncs.AssignSpriteByIconID(self.treasure_data.icon, self.icon_in_count_panel)
    local quality_data = SpecMgrs.data_mgr:GetQualityData(self.treasure_data.quality)
    UIFuncs.AssignSpriteByIconID(quality_data.bg, self.item_panel:GetComponent("Image"))
    UIFuncs.AssignSpriteByIconID(quality_data.frame, self.icon_frame)
    self.treasure_name_in_count_panel.text = string.format(UIConst.Text.SIMPLE_COLOR, quality_data.color1, self.treasure_data.name)
    self.cur_strengthen_lv_in_count_panel.text = string.format(UIConst.Text.CUR_LEVEL_FORMAT, self.treasure_info.strengthen_lv)
    for lv, guid_list in pairs(easy_material_list) do
        local data = {level = lv, guid_list = guid_list}
        table.insert(self.easy_material_list, data)
    end
    table.sort(self.easy_material_list, function (data1, data2)
        return data1.level < data2.level
    end)
    self.cur_select_lv = self.treasure_info.strengthen_lv
    self:UpdateSelectStrengthenLvPanel()
end

function TreasureCultivateUI:SetNearestStrengthenLevel(level)
    if self.cur_select_lv < level then
        for _, material_list in ipairs(self.easy_material_list) do
            if material_list.level >= level then
                self.cur_select_lv = material_list.level
                return material_list
            end
        end
        self.cur_select_lv = #self.easy_material_list > 0 and self.easy_material_list[#self.easy_material_list].level or self.treasure_info.strengthen_lv
        if #self.easy_material_list > 0 then return self.easy_material_list[#self.easy_material_list] end
    elseif self.cur_select_lv > level then
        for i = #self.easy_material_list, 1, -1 do
            local material_list = self.easy_material_list[i]
            if material_list.level <= level then
                self.cur_select_lv = material_list.level
                return material_list
            end
        end
        self.cur_select_lv = self.treasure_info.strengthen_lv
    end
end

function TreasureCultivateUI:InitSelectMaterialPanel()
    self:ClearSelectRefineMaterialItem()
    for _, item_id in ipairs(self.red_treasure_item_list) do
        local treasure_item_data = SpecMgrs.data_mgr:GetItemData(item_id)
        if treasure_item_data.part_index == self.treasure_data.part_index then
            local select_treasure_item = self:GetUIObject(self.treasure_item, self.select_treasure_panel)
            UIFuncs.InitItemGo({
                go = self.treasure_item:FindChild("Item"),
                ui = self,
                item_data = treasure_item_data,
                name_go = self.treasure_item:FindChild("Name"),
                change_name_color = true,
            })
            select_treasure_item:GetComponent("Toggle").isOn = item_id == self.cur_select_refine_material
            self:AddToggle(select_treasure_item, function (is_on)
                if is_on then
                    select_treasure_item:FindChild("Select"):SetActive(true)
                    self.temp_select_refine_material = item_id
                else
                    select_treasure_item:FindChild("Select"):SetActive(false)
                end
            end)
            if item_id == self.cur_select_refine_material then
                select_treasure_item:FindChild("Select"):SetActive(true)
                self.temp_select_refine_material = self.cur_select_refine_material
            end
            self.select_refine_material_dict[item_id] = select_treasure_item
        end
    end
    self.select_refine_material_panel:SetActive(true)
end

-- msg

function TreasureCultivateUI:SendStrengthenTreasure()
    if UIFuncs.CheckItemCount(CSConst.Virtual.Money, self.strengthen_cost, true) then
        local last_master_lv = self.lineup_data and self.lineup_data.strengthen_master_lv[CSConst.EquipPartType.Treasure]
        ComMgrs.dy_data_mgr:ExSetIgnoreScoreUpFlag(true)
        SpecMgrs.msg_mgr:SendStrengthenEquipment({item_guid = self.cultivate_treasure_guid, cost_item_list = self.cur_select_material_guid_list}, function (resp)
            ComMgrs.dy_data_mgr:ExSetIgnoreScoreUpFlag(false)
            if resp.errcode ~= 0 then
                SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.STRENGTH_FAILED)
            else
                self.effect_mask:SetActive(true)
                for i, material_item_data in ipairs(self.material_item_list) do
                    if not self.cur_select_material_guid_list[i] then break end
                    material_item_data.item_icon:SetActive(false)
                    material_item_data.remove_btn:SetActive(false)
                    material_item_data.strengthen_effect:SetActive(true)
                end
                self:PlayUISound(self.treasure_cost_sound)
                self.strengthen_timer = self:AddTimer(function ()
                    local lineup_data = self.dy_night_club_data:GetLineupData(self.treasure_info.lineup_id)
                    local master_lv_data
                    if self.lineup_data and self.lineup_data.strengthen_master_lv[CSConst.EquipPartType.Treasure] > last_master_lv then
                        master_lv_data = SpecMgrs.data_mgr:GetTSmasterData(self.lineup_data.strengthen_master_lv[CSConst.EquipPartType.Treasure])
                    end
                    self:ShowCultivateLevelUpHud(master_lv_data)
                    self:UpdateStrengthenExp()
                    self:InitStrengthenMaterialList()
                    self.effect_mask:SetActive(false)
                    self.strengthen_timer = nil
                end, kMaterialDisapearDuation, 1)
            end
        end)
    end
end

function TreasureCultivateUI:SendRefineTreasure()
    if self.treasure_info.refine_lv >= self.refine_lv_limit then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.TREASURE_REFINE_LIMIT)
        return
    end
    local cost_data = SpecMgrs.data_mgr:GetTreasureRefineLvList()[self.treasure_info.refine_lv]
    if not UIFuncs.CheckItemCount(self.treasure_refine_cost_item, cost_data.item_num, true) then return end
    if not UIFuncs.CheckItemCount(CSConst.Virtual.Money, cost_data.coin_num, true) then return end
    local refine_material_cost_count = self.treasure_data.quality == self.gold_quality and cost_data.treasure_count or cost_data.treasure_num
    if refine_material_cost_count > 0 then
        local cost_treasure_item = self.cur_select_refine_material or self.treasure_data.id
        local own_count = self.dy_bag_data:GetTreasureItemCountWithoutCultivate(cost_treasure_item)
        if own_count < refine_material_cost_count then
            --UIFuncs.ShowItemNotEnough(cost_treasure_item)
            UIFuncs.ShowItemItemAccessUI(cost_treasure_item)
            return
        end
    end
    local last_master_lv = self.lineup_data and self.lineup_data.refine_master_lv[CSConst.EquipPartType.Treasure]
    ComMgrs.dy_data_mgr:ExSetIgnoreScoreUpFlag(true)
    SpecMgrs.msg_mgr:SendRefineEquipment({item_guid = self.cultivate_treasure_guid, cost_item_id = self.cur_select_refine_material}, function (resp)
        ComMgrs.dy_data_mgr:ExSetIgnoreScoreUpFlag(false)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.REFINE_FAILED)
        else
            local master_lv_data
            if self.lineup_data and self.lineup_data.refine_master_lv[CSConst.EquipPartType.Treasure] > last_master_lv then
                master_lv_data = SpecMgrs.data_mgr:GetTRmasterData(self.lineup_data.refine_master_lv[CSConst.EquipPartType.Treasure])
            end
            self:ShowCultivateLevelUpHud(master_lv_data)
            self:ShowCultivateEffect()
        end
    end)
end

function TreasureCultivateUI:ShowCultivateLevelUpHud(master_lv_data)
    local treasure_info = self.dy_bag_data:GetBagItemDataByGuid(self.cultivate_treasure_guid)
    self.level_up_master_hud_panel:SetActive(master_lv_data ~= nil)
    local op_data = self.cultivate_op_data[self.cur_cultivate_op]
    if master_lv_data then
        self.level_up_master_hud_level.text = string.format(op_data.master_lv_format, master_lv_data.level)
        for i, attr in ipairs(master_lv_data.attr_list) do
            local attr_hud_item = self:GetUIObject(self.level_up_hud_attr, self.level_up_master_hud_panel)
            table.insert(self.hud_attr_item_list, attr_hud_item)
            attr_hud_item:GetComponent("Text").text = UIFuncs.GetAttrStr(attr, master_lv_data.attr_value_list[i], true)
        end
    end
    local attr_list
    local last_attr_dict
    local cur_attr_dict
    if self.cur_cultivate_op == CSConst.TreasureCultivateOperation.Strengthen then
        self.level_up_hud_level.text = string.format(UIConst.Text.STRENGTH_LV_ADD_FORMAT, treasure_info.strengthen_lv - self.treasure_info.strengthen_lv)
        attr_list = self.treasure_data.base_attr_list
        last_attr_dict = CSFunction.get_equip_strengthen_attr(self.treasure_data.id, self.treasure_info.strengthen_lv)
        cur_attr_dict = CSFunction.get_equip_strengthen_attr(self.treasure_data.id, treasure_info.strengthen_lv)
    elseif self.cur_cultivate_op == CSConst.TreasureCultivateOperation.Refine then
        self.level_up_hud_level.text = string.format(UIConst.Text.ER_LEVEL_UP_FORMAT, self.treasure_data.name, treasure_info.refine_lv)
        attr_list = self.treasure_data.refine_attr_list
        last_attr_dict = CSFunction.get_equip_refine_attr(self.treasure_data.id, self.treasure_info.refine_lv)
        cur_attr_dict = CSFunction.get_equip_refine_attr(self.treasure_data.id, treasure_info.refine_lv)
    end
    for _, attr in ipairs(attr_list) do
        local attr_hud_item = self:GetUIObject(self.level_up_hud_attr, self.level_up_attr_hud_panel)
        table.insert(self.hud_attr_item_list, attr_hud_item)
        attr_hud_item:GetComponent("Text").text = UIFuncs.GetAttrStr(attr, (cur_attr_dict[attr] or 0) - (last_attr_dict[attr] or 0))
    end
    self.level_up_hud:SetActive(true)
    self.hide_hud_timer = self:AddTimer(function ()
        self.level_up_hud:SetActive(false)
        self:ClearAttrHudItem()
        self.hide_hud_timer = nil
    end, op_data.effect_time)
end

function TreasureCultivateUI:UpdateSelectStrengthenLvPanel(material_list)
    self.cur_strengthen_count.text = self.cur_select_lv - self.treasure_info.strengthen_lv
    self.select_strengthen_lv_in_count_panel.text = string.format(UIConst.Text.TREASURE_NEXT_REFINE_LEVEL_FORMAT, self.cur_select_lv)
    local total_cost = 0
    local total_exp = 0
    for _, material_list in ipairs(self.easy_material_list) do
        if material_list.level > self.cur_select_lv then break end
        for _, guid in ipairs(material_list.guid_list) do
            local treasure_info = self.dy_bag_data:GetBagItemDataByGuid(guid)
            total_cost = total_cost + treasure_info.item_data.cost_coin
            total_exp = total_exp + treasure_info.strengthen_exp + treasure_info.item_data.add_exp
        end
    end
    self.easy_cost_money.text = total_cost
    self.easy_cost_exp.text = total_exp
end

function TreasureCultivateUI:Close()
    local last_cultivate_op_data = self.cultivate_op_data[self.cur_cultivate_op]
    last_cultivate_op_data.btn:FindChild("Select"):SetActive(false)
    last_cultivate_op_data.panel:SetActive(false)
    if last_cultivate_op_data.result_panel then last_cultivate_op_data.result_panel:SetActive(false) end
    self.cur_cultivate_op = nil
    self.cultivate_treasure_guid = nil
    self.cur_select_material_guid_list = {}
    self.cur_select_material_guid_dict = {}
    self.cur_select_total_exp = 0
    self.select_total_exp = 0
    self.temp_select_refine_material = nil
    self.cur_select_refine_material = nil
end

function TreasureCultivateUI:ClearSelectRefineMaterialItem()
    for _, item in pairs(self.select_refine_material_dict) do
        self:DelUIObject(item)
    end
    self.select_refine_material_dict = {}
end

function TreasureCultivateUI:ClearAttrHudItem()
    for _, hud_item in ipairs(self.hud_attr_item_list) do
        self:DelUIObject(hud_item)
    end
    self.hud_attr_item_list = {}
end

function TreasureCultivateUI:ClearTreasureItem()
    for _, item in pairs(self.treasure_item_dict) do
        self:DelUIObject(item)
    end
    self.treasure_item_dict = {}
end

function TreasureCultivateUI:ClearAllTimer()
    if self.cultivate_effect_timer then
        self:RemoveTimer(self.cultivate_effect_timer)
        self.cultivate_effect_timer = nil
    end
    if self.strengthen_timer then
        self:RemoveTimer(self.strengthen_timer)
        self.strengthen_timer = nil
    end
    if self.hide_hud_timer then
        self:RemoveTimer(self.hide_hud_timer)
        self.hide_hud_timer = nil
    end
end

return TreasureCultivateUI