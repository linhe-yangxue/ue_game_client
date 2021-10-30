local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local UnitConst = require("Unit.UnitConst")
local CSFunction = require("CSCommon.CSFunction")
local AttrUtil = require("BaseUtilities.AttrUtil")

local EquipmentCultivateUI = class("UI.EquipmentCultivateUI", UIBase)

local kCultivateEffectTriggerName = {
    Strength = "strength",
    Refine = "refine",
    AddStar = "star",
    LianHua = "smelt",
    Reset = "reset",
}
local kResetDuration = 0.2
local kStarAnimDuration = 0.085
local kStarEffectDelay = 1.67
local kHudHideDelay = 1
local kMaxStar = 5

local kStrengthenEffectDuration = 0.7
local kRefineEffectDuration = 1.3

local kRefineInterval = 0.2

function EquipmentCultivateUI:DoInit()
    EquipmentCultivateUI.super.DoInit(self)
    self.prefab_path = "UI/Common/EquipmentCultivateUI"
    self.dy_night_club_data = ComMgrs.dy_data_mgr.night_club_data
    self.dy_bag_data = ComMgrs.dy_data_mgr.bag_data
    self.cultivate_op_data = {}
    self.equip_star_list = {}
    self.effect_star_list = {}
    self.strengthen_cost_money = SpecMgrs.data_mgr:GetParamData("strengthen_equip_cost_coin").item_id
    self.star_cost_money = SpecMgrs.data_mgr:GetParamData("equip_star_cost_coin").item_id
    self.equip_refine_item_list = SpecMgrs.data_mgr:GetParamData("equip_refine_item_list").item_list
    self.lianhua_open_cost_diamond_level = SpecMgrs.data_mgr:GetParamData("open_smelt_cost_diamond_level").f_value
    self.lianhua_open_cost_fragment_level = SpecMgrs.data_mgr:GetParamData("open_smelt_cost_fragment_level").f_value
    self.refine_btn_dict = {}
    self.effect_item_list = {}
    self.hud_attr_item_list = {}
    self.strengthen_hud_list = {}
    self.easy_refine_material_list = {}
    self.add_star_attr_item_list = {}

    self.equip_level_up_sound = SpecMgrs.data_mgr:GetParamData("equip_level_up_sound").sound_id
end

function EquipmentCultivateUI:OnGoLoadedOk(res_go)
    EquipmentCultivateUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function EquipmentCultivateUI:Hide()
    self.cultivate_op = nil
    self:ClearAddStarAttrItemList()
    self:ClearAttrHudItem()
    ComMgrs.dy_data_mgr:UnregisterUpdateRoleInfoEvent("EquipmentCultivateUI")
    EquipmentCultivateUI.super.Hide(self)
end

function EquipmentCultivateUI:Show(equip_guid, operation)
    self.cultivate_equip_guid = equip_guid
    self.cultivate_op = operation
    if self.is_res_ok then
        self:InitUI()
    end
    EquipmentCultivateUI.super.Show(self)
end

function EquipmentCultivateUI:InitRes()
    self.content = self.main_panel:FindChild("Content")
    UIFuncs.InitTopBar(self, self.content:FindChild("TopBar"), "EquipmentCultivateUI", function ()
        self:Close()
        self:Hide()
    end)
    self.effect_animator = self.content:GetComponent("Animator")

    local tab_panel = self.content:FindChild("TabPanel")
    local tab_content = tab_panel:FindChild("TabList/View/Content")
    for _, op in pairs(CSConst.EquipCultivateOperation) do
        self.cultivate_op_data[op] = {}
    end
    self.effect_mask = self.content:FindChild("EffectMask")
    self.strengthen_btn = tab_content:FindChild("StrengthenBtn")
    self.cultivate_op_data[CSConst.EquipCultivateOperation.Strengthen].btn = self.strengthen_btn
    self.cultivate_op_data[CSConst.EquipCultivateOperation.Strengthen].effect_name = kCultivateEffectTriggerName.Strength
    self.cultivate_op_data[CSConst.EquipCultivateOperation.Strengthen].effect_time= kStrengthenEffectDuration
    self.strengthen_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.STRENGTH_TEXT
    self.strengthen_btn:FindChild("Select/Text"):GetComponent("Text").text = UIConst.Text.STRENGTH_TEXT
    self:AddClick(self.strengthen_btn, function ()
        self:UpdateCultivatePanel(CSConst.EquipCultivateOperation.Strengthen)
    end)
    self.refine_btn = tab_content:FindChild("RefineBtn")
    self.cultivate_op_data[CSConst.EquipCultivateOperation.Refine].btn = self.refine_btn
    self.cultivate_op_data[CSConst.EquipCultivateOperation.Refine].effect_name = kCultivateEffectTriggerName.Refine
    self.cultivate_op_data[CSConst.EquipCultivateOperation.Refine].effect_time = kRefineEffectDuration
    self.refine_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.REFINE_TEXT
    self.refine_btn:FindChild("Select/Text"):GetComponent("Text").text = UIConst.Text.REFINE_TEXT
    self:AddClick(self.refine_btn, function ()
        self:UpdateCultivatePanel(CSConst.EquipCultivateOperation.Refine)
    end)
    self.lianhua_btn = tab_content:FindChild("LianHuaBtn")
    self.cultivate_op_data[CSConst.EquipCultivateOperation.LianHua].btn = self.lianhua_btn
    self.cultivate_op_data[CSConst.EquipCultivateOperation.LianHua].effect_name = kCultivateEffectTriggerName.LianHua
    self.cultivate_op_data[CSConst.EquipCultivateOperation.LianHua].effect_time = kRefineEffectDuration
    self.lianhua_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.LIANHUA_TEXT
    self.lianhua_btn:FindChild("Select/Text"):GetComponent("Text").text = UIConst.Text.LIANHUA_TEXT
    self:AddClick(self.lianhua_btn, function ()
        self:UpdateCultivatePanel(CSConst.EquipCultivateOperation.LianHua)
    end)
    self.star_btn = tab_content:FindChild("StarBtn")
    self.cultivate_op_data[CSConst.EquipCultivateOperation.AddStar].btn = self.star_btn
    self.cultivate_op_data[CSConst.EquipCultivateOperation.AddStar].effect_name = kCultivateEffectTriggerName.AddStar
    self.star_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ADD_STAR
    self.star_btn:FindChild("Select/Text"):GetComponent("Text").text = UIConst.Text.ADD_STAR
    self:AddClick(self.star_btn, function ()
        self:UpdateCultivatePanel(CSConst.EquipCultivateOperation.AddStar)
    end)

    self.equip_info_panel = self.content:FindChild("EquipmentInfo")
    self.equip_name = self.equip_info_panel:FindChild("NamePanel/Text"):GetComponent("Text")
    self.star_item_content = self.equip_info_panel:FindChild("StarPanel")
    self.star_item = self.star_item_content:FindChild("Star")
    self.equip_img = self.equip_info_panel:FindChild("EquipmentImg")
    self.equip_img_cmp = self.equip_img:GetComponent("Image")
    local star_effect_list = self.equip_info_panel:FindChild("zhuangbei_shengxing/StartLevelPart/StarLevelPart")
    for i = 1, kMaxStar do
        self.effect_star_list[i] = star_effect_list:FindChild("Star" .. i)
    end

    self.level_up_hud = self.equip_info_panel:FindChild("LevelUpHud")
    self.level_up_master_hud_panel = self.level_up_hud:FindChild("MasterPanel")
    self.level_up_master_hud_level = self.level_up_master_hud_panel:FindChild("MasterLv"):GetComponent("Text")
    self.level_up_hud_attr = self.level_up_master_hud_panel:FindChild("Attr")
    self.level_up_attr_hud_panel = self.level_up_hud:FindChild("AttrPanel")
    self.level_up_hud_level = self.level_up_attr_hud_panel:FindChild("Level"):GetComponent("Text")

    -- 升级
    self.strengthen_panel = self.content:FindChild("StrengthPanel")
    self.cultivate_op_data[CSConst.EquipCultivateOperation.Strengthen].panel = self.strengthen_panel
    self.cultivate_op_data[CSConst.EquipCultivateOperation.Strengthen].init_func = self.InitStrengthenPanel
    self.cultivate_op_data[CSConst.EquipCultivateOperation.Strengthen].update_cost_func = self.UpdateStrengthenCost
    self.cultivate_op_data[CSConst.EquipCultivateOperation.Strengthen].master_lv_format = UIConst.Text.ES_MASTER_LV_UP_FORMAT

    local left_attr_panel = self.strengthen_panel:FindChild("LeftAttrPanel")
    self.before_strengthen_lv = left_attr_panel:FindChild("Level"):GetComponent("Text")
    self.before_strengthen_attr = left_attr_panel:FindChild("Attr"):GetComponent("Text")

    self.upgrate_img = self.strengthen_panel:FindChild("Image")
    self.upgrate_right_attr_panel = self.strengthen_panel:FindChild("RightAttrPanel")
    self.after_strengthen_lv = self.upgrate_right_attr_panel:FindChild("Level"):GetComponent("Text")
    self.after_strengthen_attr = self.upgrate_right_attr_panel:FindChild("Attr"):GetComponent("Text")

    local bottom_panel = self.strengthen_panel:FindChild("BottomPanel")
    local equip_strengthen_btn = bottom_panel:FindChild("StrengthBtn")
    equip_strengthen_btn:FindChild("MaterialCost/Text"):GetComponent("Text").text = UIConst.Text.STRENGTH_TEXT
    self.equip_strengthen_btn_cmp = equip_strengthen_btn:GetComponent("Button")
    self.equip_strengthen_disable = equip_strengthen_btn:FindChild("Disable")
    self:AddClick(equip_strengthen_btn, function ()
        if UIFuncs.CheckItemCount(CSConst.Virtual.Money, self.strengthen_cost, true) then
            self:SendStrengthenEquipment()
        else
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.STRENGTHEN_COST_FAILED)
        end
    end)
    self.strengthen_five_btn = bottom_panel:FindChild("StrengthFiveBtn")
    self.strengthen_five_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.STRENGTHEN_FIVE_TEXT
    self.strengthen_five_btn_cmp = self.strengthen_five_btn:GetComponent("Button")
    self.strengthen_five_disable = self.strengthen_five_btn:FindChild("Disable")
    self:AddClick(self.strengthen_five_btn, function ()
        if UIFuncs.CheckItemCount(CSConst.Virtual.Money, self.strengthen_cost, true) then
            self:SendStrengthenEquipmentFive()
        else
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.STRENGTHEN_COST_FAILED)
        end
    end)
    self.strengthen_cost_text = equip_strengthen_btn:FindChild("MaterialCost/CostCount"):GetComponent("Text")
    -- 精炼
    self.refine_panel = self.content:FindChild("RefinePanel")
    self.cultivate_op_data[CSConst.EquipCultivateOperation.Refine].panel = self.refine_panel
    self.cultivate_op_data[CSConst.EquipCultivateOperation.Refine].init_func = self.InitRefinePanel
    self.cultivate_op_data[CSConst.EquipCultivateOperation.Refine].update_cost_func = self.UpdateRefineCost
    self.cultivate_op_data[CSConst.EquipCultivateOperation.Refine].master_lv_format = UIConst.Text.ER_MASTER_LV_UP_FORMAT

    left_attr_panel = self.refine_panel:FindChild("LeftAttrPanel")
    left_attr_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ATTR_ACCUMULATE
    self.before_refine_attr = left_attr_panel:FindChild("Attr"):GetComponent("Text")
    self.before_refine_extra_attr = left_attr_panel:FindChild("ExtraAttr")
    self.before_refine_extra_attr_text = self.before_refine_extra_attr:GetComponent("Text")
    self.refine_right_attr_panel = self.refine_panel:FindChild("RightAttrPanel")
    self.after_refine_lv = self.refine_right_attr_panel:FindChild("Text"):GetComponent("Text")
    self.after_refine_attr = self.refine_right_attr_panel:FindChild("Attr"):GetComponent("Text")
    self.after_refine_extra_attr = self.refine_right_attr_panel:FindChild("ExtraAttr")
    self.after_refine_extra_attr_text = self.after_refine_extra_attr:GetComponent("Text")
    bottom_panel = self.refine_panel:FindChild("BottomPanel")
    self.refine_lv = bottom_panel:FindChild("RefineLv"):GetComponent("Text")
    local refine_exp_bar = bottom_panel:FindChild("RefineExpBar")
    self.refine_exp_value = refine_exp_bar:FindChild("CurExp"):GetComponent("Image")
    self.cur_refine_value = refine_exp_bar:FindChild("ExpValue"):GetComponent("Text")
    self.effect_list = bottom_panel:FindChild("EffectList")
    self.effect_duaration = self.effect_list:FindChild("EffectItem1"):GetComponent("UITweenPosition"):GetDurationTime()
    for i, item_id in ipairs(self.equip_refine_item_list) do
        local item_data = SpecMgrs.data_mgr:GetItemData(item_id)
        local quality_data = SpecMgrs.data_mgr:GetQualityData(item_data.quality)
        local item_go = bottom_panel:FindChild("RefineItem" .. i)
        item_go:FindChild("Effect"):GetComponent("Text").text = string.format(UIConst.Text.ADD_EXP_FORMAT, item_data.add_exp)
        local refine_item_btn = item_go:FindChild("Item/Icon")
        UIFuncs.AssignSpriteByIconID(item_data.icon, refine_item_btn:GetComponent("Image"))
        UIFuncs.AssignSpriteByIconID(quality_data.bg, item_go:FindChild("Item"):GetComponent("Image"))
        UIFuncs.AssignSpriteByIconID(quality_data.frame, item_go:FindChild("Item/Frame"):GetComponent("Image"))
        local item_disable = item_go:FindChild("Item/Disable")
        UIFuncs.AssignSpriteByIconID(item_data.icon, item_disable:GetComponent("Image"))
        self.refine_btn_dict[item_id] = {}
        self.refine_btn_dict[item_id].item_btn_cmp = refine_item_btn:GetComponent("Button")
        self.refine_btn_dict[item_id].item_disable = item_disable
        self.refine_btn_dict[item_id].count = item_go:FindChild("Item/Count/Text"):GetComponent("Text")
        local effect_item = self.effect_list:FindChild("EffectItem" .. i)
        UIFuncs.AssignSpriteByIconID(item_data.icon, effect_item:GetComponent("Image"))
        self.refine_btn_dict[item_id].effect_item = effect_item
        self:AddClick(refine_item_btn, function ()
            self:SendRefineEquipment(item_id)
            self:ClearRefineTimer()
        end)
        self:AddLongPress(refine_item_btn, function ()
            self.refine_timer = self:AddTimer(function ()
                if not self:SendRefineEquipment(item_id) then
                    self:ClearRefineTimer()
                end
            end, kRefineInterval, 0)
        end)
        self:AddRelease(refine_item_btn, function ()
            self:ClearRefineTimer()
        end)
    end
    self.easy_refine_btn = bottom_panel:FindChild("EasyRefineBtn")
    self.easy_refine_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.EASY_REFINE
    self.easy_refine_btn_cmp = self.easy_refine_btn:GetComponent("Button")
    self:AddClick(self.easy_refine_btn, function ()
        self.result_refine_lv_list = self.dy_bag_data:CalcEquipRefineExp(self.cultivate_equip_guid)
        if #self.result_refine_lv_list == 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.STRENGTHEN_MATERIAL_NOT_ENOUGH)
        else
            self:InitEasyRefinePanel()
        end
    end)
    self.easy_refine_disable = self.easy_refine_btn:FindChild("Disable")
    self.easy_refine_panel = self.content:FindChild("EasyRefinePanel")
    local easy_refine_content = self.easy_refine_panel:FindChild("Content")
    easy_refine_content:FindChild("Title"):GetComponent("Text").text = UIConst.Text.EASY_REFINE
    self:AddClick(easy_refine_content:FindChild("CloseBtn"), function ()
        self.result_refine_lv_list = nil
        self.cur_selelct_refine_lv_data = nil
        self.easy_refine_panel:SetActive(false)
    end)
    self.easy_refine_equip_bg = easy_refine_content:FindChild("EquipIcon"):GetComponent("Image")
    self.easy_refine_equip_icon = easy_refine_content:FindChild("EquipIcon/Icon"):GetComponent("Image")
    self.easy_refine_equip_frame = easy_refine_content:FindChild("EquipIcon/Frame"):GetComponent("Image")
    self.easy_refine_equip_name = easy_refine_content:FindChild("EquipName"):GetComponent("Text")
    local level_panel = easy_refine_content:FindChild("LevelPanel")
    self.cur_easy_refine_lv = level_panel:FindChild("CurLv"):GetComponent("Text")
    self.next_easy_refine_lv = level_panel:FindChild("NextLv"):GetComponent("Text")
    local easy_select_panel = easy_refine_content:FindChild("SelectPanel")
    self:AddClick(easy_select_panel:FindChild("ReduceTen"), function ()
        self:UpdateEasyRefinePanel(-10)
    end)
    self:AddClick(easy_select_panel:FindChild("Reduce"), function ()
        self:UpdateEasyRefinePanel(-1)
    end)
    self.easy_refine_select_lv = easy_select_panel:FindChild("Count/Text"):GetComponent("Text")
    self:AddClick(easy_select_panel:FindChild("Add"), function ()
        self:UpdateEasyRefinePanel(1)
    end)
    self:AddClick(easy_select_panel:FindChild("AddTen"), function ()
        self:UpdateEasyRefinePanel(10)
    end)
    easy_refine_content:FindChild("Text"):GetComponent("Text").text = UIConst.Text.COST_TEXT
    local easy_refine_material_panel = easy_refine_content:FindChild("MaterialPanel")
    for i, item_id in ipairs(self.equip_refine_item_list) do
        local item_data = SpecMgrs.data_mgr:GetItemData(item_id)
        local material_item = easy_refine_material_panel:FindChild("Material" .. i)
        UIFuncs.AssignSpriteByIconID(item_data.icon, material_item:FindChild("Image"):GetComponent("Image"))
        local material_count = material_item:FindChild("Count"):GetComponent("Text")
        table.insert(self.easy_refine_material_list, material_count)
    end
    local easy_refine_cancel_btn = easy_refine_content:FindChild("BtnPanel/CancelBtn")
    easy_refine_cancel_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CANCEL
    self:AddClick(easy_refine_cancel_btn, function ()
        self.result_refine_lv_list = nil
        self.cur_selelct_refine_lv_data = nil
        self.easy_refine_panel:SetActive(false)
    end)
    local easy_refine_submit_btn = easy_refine_content:FindChild("BtnPanel/SubmitBtn")
    easy_refine_submit_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CONFIRM
    self:AddClick(easy_refine_submit_btn, function ()
        self:SendQuickRefineEquipment()
    end)
    -- 炼化
    self.lianhua_panel = self.content:FindChild("LianHuaPanel")
    self.cultivate_op_data[CSConst.EquipCultivateOperation.LianHua].panel = self.lianhua_panel
    self.cultivate_op_data[CSConst.EquipCultivateOperation.LianHua].init_func = self.InitLianHuaPanel
    self.cultivate_op_data[CSConst.EquipCultivateOperation.LianHua].update_cost_func = self.UpdateLianHuaCost
    self.lianhua_hud = self.lianhua_panel:FindChild("LianHuaHud")
    self.lianhua_crit_img = self.lianhua_hud:FindChild("zhuangbei_lianhua_baoji")
    self.failed_hud = self.lianhua_hud:FindChild("Failed")
    self.failed_hud:FindChild("Text"):GetComponent("Text").text = UIConst.Text.FAILED
    self.luck_hud = self.failed_hud:FindChild("Luck"):GetComponent("Text")
    self.succeed_hud = self.lianhua_hud:FindChild("Succeed")
    self.succeed_text = self.succeed_hud:FindChild("Text"):GetComponent("Text")
    self.succeed_attr = self.succeed_hud:FindChild("Attr"):GetComponent("Text")
    self.succeed_exp = self.succeed_hud:FindChild("Exp"):GetComponent("Text")

    left_attr_panel = self.lianhua_panel:FindChild("LeftAttrPanel")
    left_attr_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ATTR_ACCUMULATE
    self.before_lianhua_attr = left_attr_panel:FindChild("Attr"):GetComponent("Text")
    self.lianhua_right_attr_panel = self.lianhua_panel:FindChild("RightAttrPanel")
    self.after_lianhua_lv = self.lianhua_right_attr_panel:FindChild("Text"):GetComponent("Text")
    self.after_lianhua_attr = self.lianhua_right_attr_panel:FindChild("Attr"):GetComponent("Text")
    self.after_lianhua_extra_attr = self.lianhua_right_attr_panel:FindChild("ExtraAttr"):GetComponent("Text")
    bottom_panel = self.lianhua_panel:FindChild("BottomPanel")
    local lianhua_exp_bar = bottom_panel:FindChild("ExpBar")
    self.cur_lianhua_exp = lianhua_exp_bar:FindChild("CurExp"):GetComponent("Image")
    self.lianhua_exp_value = lianhua_exp_bar:FindChild("ExpValue"):GetComponent("Text")
    local rate_panel = bottom_panel:FindChild("RatePanel")
    self.lianhua_success_rate = rate_panel:FindChild("SuccessRate"):GetComponent("Text")
    self.lianhua_luck = rate_panel:FindChild("LuckValue")
    self.lianhua_luck_text = self.lianhua_luck:GetComponent("Text")
    local lianhua_material_panel = bottom_panel:FindChild("MaterialPanel")

    self.lianhua_money_cost = lianhua_material_panel:FindChild("Money")
    self.lianhua_money_toggle = self.lianhua_money_cost:FindChild("MoneyToggle")
    self:AddToggle(self.lianhua_money_toggle, function (is_on)
        self.cur_select_lianhua_material = CSConst.Virtual.Money
    end)
    self.lianhua_money_cost:FindChild("Text"):GetComponent("Text").text = UIConst.Text.LIANHUA_COST_MONEY
    self.lianhua_money_count = self.lianhua_money_cost:FindChild("Count"):GetComponent("Text")

    self.lianhua_diamond_cost = lianhua_material_panel:FindChild("Diamond")
    self.lianhua_diamond_toggle = self.lianhua_diamond_cost:FindChild("DiamondToggle")
    self:AddToggle(self.lianhua_diamond_toggle, function (is_on)
        self.cur_select_lianhua_material = CSConst.Virtual.Diamond
    end)
    self.lianhua_diamond_cost:FindChild("Text"):GetComponent("Text").text = UIConst.Text.LIANHUA_COST_DIAMOND
    self.lianhua_diamond_count = self.lianhua_diamond_cost:FindChild("Count"):GetComponent("Text")

    self.lianhua_fragment_cost = lianhua_material_panel:FindChild("Fragment")
    self.lianhua_fragment_toggle = self.lianhua_fragment_cost:FindChild("FragmentToggle")
    self:AddToggle(self.lianhua_fragment_toggle, function (is_on)
        self.cur_select_lianhua_material = self.equip_data.fragment
    end)
    self.lianhua_fragment_text = self.lianhua_fragment_cost:FindChild("Text"):GetComponent("Text")
    self.lianhua_fragment_count = self.lianhua_fragment_cost:FindChild("Count"):GetComponent("Text")
    self.lianhua_attr = bottom_panel:FindChild("Attr"):GetComponent("Text")
    self.equip_lianhua_btn = bottom_panel:FindChild("LianHuaBtn")
    self.equip_lianhua_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.LIANHUA_TEXT
    self.equip_lianhua_btn_cmp = self.equip_lianhua_btn:GetComponent("Button")
    self:AddClick(self.equip_lianhua_btn, function ()
        self.equip_lianhua_btn_cmp.interactable = false
        self:SendSmeltEquipment()
    end)
    self.lianhua_disable = self.equip_lianhua_btn:FindChild("Disable")
    -- 升星
    self.star_panel = self.content:FindChild("StarPanel")
    self.cultivate_op_data[CSConst.EquipCultivateOperation.AddStar].panel = self.star_panel
    self.cultivate_op_data[CSConst.EquipCultivateOperation.AddStar].init_func = self.InitAddStarPanel
    self.cultivate_op_data[CSConst.EquipCultivateOperation.AddStar].update_cost_func = self.UpdateAddStarCost
    left_attr_panel = self.star_panel:FindChild("LeftAttrPanel")
    left_attr_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ATTR_ACCUMULATE
    self.before_star_atk = left_attr_panel:FindChild("Atk"):GetComponent("Text")
    self.before_star_element_attr = left_attr_panel:FindChild("ElementAttr")
    self.before_star_element_attr_text = self.before_star_element_attr:GetComponent("Text")
    self.star_right_attr_panel = self.star_panel:FindChild("RightAttrPanel")
    self.after_star_lv = self.star_right_attr_panel:FindChild("Text"):GetComponent("Text")
    self.after_star_atk = self.star_right_attr_panel:FindChild("Atk"):GetComponent("Text")
    self.after_star_element_attr = self.star_right_attr_panel:FindChild("ElementAttr")
    self.after_star_element_attr_text = self.after_star_element_attr:GetComponent("Text")
    bottom_panel = self.star_panel:FindChild("BottomPanel")
    local star_material_panel = bottom_panel:FindChild("MaterialPanel")
    self.star_material_item = star_material_panel:FindChild("Item")
    self.star_material_name = star_material_panel:FindChild("Name")
    self.star_material_count = star_material_panel:FindChild("Count"):GetComponent("Text")
    self.equip_star_btn = bottom_panel:FindChild("StarBtn")
    self.equip_star_btn:FindChild("MoneyCost/Text"):GetComponent("Text").text = UIConst.Text.ADD_STAR
    self.equip_star_btn_cmp = self.equip_star_btn:GetComponent("Button")
    self.equip_star_disable = self.equip_star_btn:FindChild("Disable")
    self:AddClick(self.equip_star_btn, function ()
        self:SendAddEquipmentStar()
    end)
    self.star_money_cost = self.equip_star_btn:FindChild("MoneyCost/Count"):GetComponent("Text")
    local add_star_result_content = self.star_panel:FindChild("InfoPanel/InfoContent")
    add_star_result_content:FindChild("SpellPanel/SpellText"):GetComponent("Text").text = UIConst.Text.UNLOCK_SPELL
    self.add_star_result_spell_desc = add_star_result_content:FindChild("SpellPanel/SpellDesc"):GetComponent("Text")
    self.add_star_before_lv = add_star_result_content:FindChild("BeforeLv"):GetComponent("Text")
    self.add_star_after_lv = add_star_result_content:FindChild("AfterLv"):GetComponent("Text")
    self.info_content = add_star_result_content:FindChild("Info")
    self.add_star_attr_item = self.info_content:FindChild("Attr")

    local reset_btn = self.content:FindChild("ResetBtn")
    reset_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CLICK_FOR_CONTINUE
    self:AddClick(reset_btn, function ()
        self.effect_animator:SetTrigger(kCultivateEffectTriggerName.Reset)
        self:AddTimer(function ()
            self:UpdateEquipmentInfo()
            self:ShowScoreUpUI()
            self.cultivate_op_data[self.cur_cultivate_op].init_func(self)
        end, kResetDuration)
    end)
end

function EquipmentCultivateUI:InitUI()
    if not self.cultivate_equip_guid then
        self:Hide()
        return
    end
    self.equip_info = self.dy_bag_data:GetBagItemDataByGuid(self.cultivate_equip_guid)
    self.equip_data = SpecMgrs.data_mgr:GetItemData(self.equip_info.item_id)
    self.last_score = ComMgrs.dy_data_mgr:ExGetRoleScore()
    self.last_fight_score = ComMgrs.dy_data_mgr:ExGetFightScore()
    self.lineup_data = self.dy_night_club_data:GetLineupData(self.equip_info.lineup_id)
    self.fragment_data = SpecMgrs.data_mgr:GetItemData(self.equip_data.fragment)
    self.quality_data = SpecMgrs.data_mgr:GetQualityData(self.equip_data.quality)
    self.star_limit = self.quality_data.equip_star_lv_limit
    self.star_offset = math.floor(kMaxStar / 2 - self.star_limit / 2)
    self.star_btn:SetActive(self.star_limit > 0)
    if self.star_limit > 0 then
        for i = 1, self.star_limit do
            local star_item = self:GetUIObject(self.star_item, self.star_item_content)
            table.insert(self.equip_star_list, star_item)
        end
    end
    self.strengthen_limit = CSConst.StrengthenLimitRate * ComMgrs.dy_data_mgr:ExGetRoleLevel()
    self.refine_lv_limit = #SpecMgrs.data_mgr:GetEquipmentRefineLvList()
    self.lianhua_lv_limit = #SpecMgrs.data_mgr:GetAllEquipSmeltData()
    self.lianhua_btn:SetActive(self.quality_data.can_smelt == true)
    self:UpdateCultivatePanel(self.cultivate_op)
    UIFuncs.AssignSpriteByIconID(self.equip_data.img, self.equip_img_cmp)
    UIFuncs.AssignSpriteByIconID(self.equip_data.img, self.result_equip_img)
    self:RegisterEvent(ComMgrs.dy_data_mgr, "UpdateCurrencyEvent", function (_, currency)
        UIFuncs.UpdateCurrencyItemNum(self._item_to_text_list, currency)
        self:UpdateCultivateCost()
    end)
    self:RegisterEvent(self.dy_bag_data, "UpdateBagItemEvent", function ()
        self:UpdateCultivateCost()
    end)
end

function EquipmentCultivateUI:UpdateCultivateCost()
    local cur_op_data = self.cultivate_op_data[self.cur_cultivate_op]
    if cur_op_data.update_cost_func then
        cur_op_data.update_cost_func(self)
    end
end

function EquipmentCultivateUI:UpdateCultivatePanel(cultivate_op)
    if self.cur_cultivate_op and self.cur_cultivate_op ~= cultivate_op then
        local last_cultivate_op_data = self.cultivate_op_data[self.cur_cultivate_op]
        last_cultivate_op_data.btn:FindChild("Select"):SetActive(false)
        last_cultivate_op_data.panel:SetActive(false)
        if last_cultivate_op_data.result_panel then last_cultivate_op_data.result_panel:SetActive(false) end
    end
    self.cur_cultivate_op = cultivate_op
    local cur_cultivate_op_data = self.cultivate_op_data[self.cur_cultivate_op]
    cur_cultivate_op_data.btn:FindChild("Select"):SetActive(true)
    cur_cultivate_op_data.panel:SetActive(true)
    if cur_cultivate_op_data.result_panel then cur_cultivate_op_data.result_panel:SetActive(true) end
    self:UpdateEquipmentInfo()
    cur_cultivate_op_data.init_func(self)
end

function EquipmentCultivateUI:UpdateEquipmentInfo()
    self.equip_info = self.dy_bag_data:GetBagItemDataByGuid(self.cultivate_equip_guid)
    self.equip_name.text = self.equip_data.name
    for i = 1, self.star_limit do
        self.equip_star_list[i]:FindChild("Active"):SetActive(i <= self.equip_info.star_lv)
    end
end

function EquipmentCultivateUI:InitStrengthenPanel()
    local cur_attr_dict = CSFunction.get_equip_strengthen_attr(self.equip_data.id, self.equip_info.strengthen_lv)
    self.before_strengthen_lv.text = string.format(UIConst.Text.STRENGTHEN_LEVLE_FORMAT, self.equip_info.strengthen_lv, self.strengthen_limit)
    local strength_attr = self.equip_data.base_attr_list[1]
    self.before_strengthen_attr.text = UIFuncs.GetAttrStr(strength_attr, cur_attr_dict[strength_attr] or 0)

    self.equip_strengthen_btn_cmp.interactable = self.equip_info.strengthen_lv < self.strengthen_limit
    self.equip_strengthen_disable:SetActive(self.equip_info.strengthen_lv >= self.strengthen_limit)
    self.strengthen_five_btn_cmp.interactable = self.equip_info.strengthen_lv < self.strengthen_limit
    self.strengthen_five_disable:SetActive(self.equip_info.strengthen_lv >= self.strengthen_limit)

    local next_strength_lv = self.equip_info.strengthen_lv + 1
    self.upgrate_right_attr_panel:SetActive(next_strength_lv <= self.strengthen_limit)
    self.upgrate_img:SetActive(next_strength_lv <= self.strengthen_limit)
    self.strengthen_cost = nil
    if next_strength_lv > self.strengthen_limit then return end

    self.after_strengthen_lv.text = string.format(UIConst.Text.NEXT_STRENGTHEN_LEVLE_FORMAT, next_strength_lv, self.strengthen_limit)
    local next_attr_dict = CSFunction.get_equip_strengthen_attr(self.equip_data.id, next_strength_lv)
    self.after_strengthen_attr.text = UIFuncs.GetAttrStr(strength_attr, next_attr_dict[strength_attr] or 0, true)
    self.strengthen_cost = CSFunction.get_equip_strengthen_cost(self.equip_data.id, next_strength_lv)
    self:UpdateStrengthenCost()
end

function EquipmentCultivateUI:UpdateStrengthenCost()
    if not self.strengthen_cost then return end
    local cost_color = self.strengthen_cost >= self.dy_bag_data:GetBagItemCount(self.strengthen_cost_money) and UIConst.Color.Red1 or UIConst.Color.Default
    self.strengthen_cost_text.text = string.format(UIConst.Text.SIMPLE_COLOR, cost_color, UIFuncs.AddCountUnit(self.strengthen_cost))
end

function EquipmentCultivateUI:InitRefinePanel()
    local cur_attr_dict = CSFunction.get_equip_refine_attr(self.equip_data.id, self.equip_info.refine_lv)
    local attr_id = self.equip_data.refine_attr_list[1]
    self.before_refine_attr.text = UIFuncs.GetAttrStr(attr_id, cur_attr_dict[attr_id] or 0)
    local extra_attr_id = self.equip_data.refine_attr_list[2]
    self.before_refine_extra_attr:SetActive(extra_attr_id ~= nil)
    if extra_attr_id then
        self.before_refine_extra_attr_text.text = UIFuncs.GetAttrStr(extra_attr_id, cur_attr_dict[extra_attr_id] or 0)
    end
    self.easy_refine_btn_cmp.interactable = self.equip_info.refine_lv < self.refine_lv_limit
    self.easy_refine_disable:SetActive(self.equip_info.refine_lv >= self.refine_lv_limit)
    self.refine_lv.text = string.format(UIConst.Text.REFINE_LEVEL_FORMAT, self.equip_info.refine_lv)
    self:UpdateRefineExp()

    local next_refine_lv = self.equip_info.refine_lv + 1
    self.refine_right_attr_panel:SetActive(next_refine_lv <= self.refine_lv_limit)
    if next_refine_lv > self.refine_lv_limit then return end
    local next_attr_dict = CSFunction.get_equip_refine_attr(self.equip_data.id, next_refine_lv)
    self.after_refine_lv.text = string.format(UIConst.Text.NEXT_TARGET_FORMAT, next_refine_lv)
    self.after_refine_attr.text = UIFuncs.GetAttrStr(attr_id, next_attr_dict[attr_id] or 0, true)
    if extra_attr_id then
        self.after_refine_extra_attr_text.text = UIFuncs.GetAttrStr(extra_attr_id, next_attr_dict[extra_attr_id] or 0, true)
    end
end

function EquipmentCultivateUI:UpdateRefineExp()
    local refine_lv_list = SpecMgrs.data_mgr:GetEquipmentRefineLvList(self.equip_info.refine_lv)
    local cur_level_total_exp = refine_lv_list[self.equip_info.refine_lv]["total_exp_q" .. self.equip_data.quality]
    local cur_level_exp = refine_lv_list[self.equip_info.refine_lv]["exp_q" .. self.equip_data.quality]
    if self.equip_info.refine_lv >= self.refine_lv_limit then
        self.refine_exp_value.fillAmount = 1
        self.cur_refine_value.text = string.format(UIConst.Text.PER_VALUE, cur_level_exp, cur_level_exp)
    else
        self.refine_exp_value.fillAmount = (self.equip_info.refine_exp - cur_level_total_exp) / cur_level_exp
        self.cur_refine_value.text = string.format(UIConst.Text.PER_VALUE, self.equip_info.refine_exp - cur_level_total_exp, cur_level_exp)
    end
    self:UpdateRefineCost()
end

function EquipmentCultivateUI:InitEasyRefinePanel()
    UIFuncs.AssignSpriteByIconID(self.quality_data.bg, self.easy_refine_equip_bg)
    UIFuncs.AssignSpriteByIconID(self.equip_data.icon, self.easy_refine_equip_icon)
    UIFuncs.AssignSpriteByIconID(self.quality_data.frame, self.easy_refine_equip_frame)
    self.easy_refine_equip_name.text = string.format(UIConst.Text.SIMPLE_COLOR, self.quality_data.color, self.equip_data.name)
    self.cur_easy_refine_lv.text = string.format(UIConst.Text.REFINE_LEVEL_FORMAT, self.equip_info.refine_lv)
    self:UpdateEasyRefinePanel(1)
    self.easy_refine_panel:SetActive(true)
end

function EquipmentCultivateUI:UpdateEasyRefinePanel(add_lv)
    local next_refine_lv = add_lv + (self.cur_selelct_refine_lv_data and self.cur_selelct_refine_lv_data.level or self.equip_info.refine_lv)
    self.cur_selelct_refine_lv_data = self.result_refine_lv_list[1]
    for i, refine_lv_data in ipairs(self.result_refine_lv_list) do
        if next_refine_lv >= refine_lv_data.level then
            self.cur_selelct_refine_lv_data = refine_lv_data
        end
    end
    self.next_easy_refine_lv.text = string.format(UIConst.Text.NEXT_REFINE_LEVEL_FORMAT, self.cur_selelct_refine_lv_data.level)
    self.easy_refine_select_lv.text = self.cur_selelct_refine_lv_data.level - self.equip_info.refine_lv
    for i, item_id in ipairs(self.equip_refine_item_list) do
        self.easy_refine_material_list[i].text = string.format(UIConst.Text.PER_VALUE, self.cur_selelct_refine_lv_data.item_dict[item_id] or 0, self.dy_bag_data:GetBagItemCount(item_id))
    end
end

function EquipmentCultivateUI:UpdateRefineCost()
    for item_id, btn_data in pairs(self.refine_btn_dict) do
        local item_count = self.dy_bag_data:GetBagItemCount(item_id)
        btn_data.item_disable:SetActive(item_count == 0)
        btn_data.count.text = item_count
    end
end

function EquipmentCultivateUI:InitLianHuaPanel()
    local attr_data = SpecMgrs.data_mgr:GetAttributeData(self.equip_data.smelt_attr)
    self.lianhua_right_attr_panel:SetActive(self.equip_info.smelt_lv < self.lianhua_lv_limit)
    self.equip_lianhua_btn_cmp.interactable = self.equip_info.smelt_lv < self.lianhua_lv_limit
    self.lianhua_disable:SetActive(self.equip_info.smelt_lv >= self.lianhua_lv_limit)

    self:UpdateLianHuaExp()

    local next_smelt_lv = self.equip_info.smelt_lv + 1
    self.lianhua_right_attr_panel:SetActive(next_smelt_lv <= self.lianhua_lv_limit)
    self.lianhua_cost_dict = nil
    if next_smelt_lv > self.lianhua_lv_limit then return end

    self.after_lianhua_lv.text = string.format(UIConst.Text.NEXT_TARGET_FORMAT, next_smelt_lv)
    self.after_lianhua_attr.text = string.format(UIConst.Text.ATTR_VALUE_FORMAT, attr_data.name, self.equip_data.smelt_attr_value[next_smelt_lv])
    self.after_lianhua_extra_attr.text = string.format(UIConst.Text.EXTRA_ADDITION_FORMAT, self.equip_data.smelt_extra_attr_value[next_smelt_lv])
    self.lianhua_cost_dict = CSFunction.get_equip_smelt_cost(self.equip_data.id, next_smelt_lv)
    self:UpdateLianhuaCost()
    self.lianhua_diamond_cost:SetActive(self.equip_info.smelt_lv >= self.lianhua_open_cost_diamond_level)
    self.lianhua_fragment_cost:SetActive(self.equip_info.smelt_lv >= self.lianhua_open_cost_fragment_level)
    if self.equip_info.smelt_lv >= self.lianhua_open_cost_fragment_level then
        self.lianhua_fragment_text.text = string.format(UIConst.Text.LIANHUA_COST_FORMAT, UIFuncs.GetItemName({item_id = self.equip_data.fragment}))
    end
    local equip_smelt_data = SpecMgrs.data_mgr:GetEquipSmeltData(next_smelt_lv)
    local attr_value = math.floor(self.equip_data.smelt_attr_value[next_smelt_lv] / equip_smelt_data.exp * equip_smelt_data.each_exp)
    self.lianhua_attr.text = string.format(UIConst.Text.ATTR_ADD_VALUE_FORMAT, attr_data.name, attr_value)
    if not self.cur_select_lianhua_material then
        self.cur_select_lianhua_material = CSConst.Virtual.Money
        self.lianhua_money_toggle:GetComponent("Toggle").isOn = true
    end
end

function EquipmentCultivateUI:UpdateLianHuaExp()
    local cur_attr_dict = CSFunction.get_equip_smelt_attr(self.equip_data.id, self.equip_info.smelt_lv, self.equip_info.smelt_exp)
    local attr_data = SpecMgrs.data_mgr:GetAttributeData(self.equip_data.smelt_attr)
    self.before_lianhua_attr.text = string.format(UIConst.Text.ATTR_VALUE_FORMAT, attr_data.name, math.floor(cur_attr_dict[attr_data.id] or 0))

    local smelt_lv_list = SpecMgrs.data_mgr:GetAllEquipSmeltData()
    local cur_level_exp = smelt_lv_list[self.equip_info.smelt_lv] and smelt_lv_list[self.equip_info.smelt_lv].exp or 0
    if self.equip_info.smelt_lv >= self.lianhua_lv_limit then
        self.cur_lianhua_exp.fillAmount = 1
        self.lianhua_exp_value.text = string.format(UIConst.Text.PER_VALUE, cur_level_exp, cur_level_exp)
    else
        local next_level_exp = smelt_lv_list[self.equip_info.smelt_lv + 1].exp
        self.cur_lianhua_exp.fillAmount = self.equip_info.smelt_exp / next_level_exp
        self.lianhua_exp_value.text = string.format(UIConst.Text.PER_VALUE, self.equip_info.smelt_exp, next_level_exp)
    end
    local cur_smelt_data = SpecMgrs.data_mgr:GetEquipSmeltData(self.equip_info.smelt_lv + 1)
    if cur_smelt_data then
        local cur_smelt_rate = cur_smelt_data.luck_limit > 0 and math.min(cur_smelt_data.init_rate + (1 - cur_smelt_data.init_rate) * self.equip_info.lucky_value / cur_smelt_data.luck_limit, 1) or 1
        local rate_desc_list = SpecMgrs.data_mgr:GetAllSmeltRateDescData()
        for i, rate_data in ipairs(rate_desc_list) do
            if cur_smelt_rate <= rate_data.rate then
                self.lianhua_success_rate.text = string.format(UIConst.Text.SUCCESS_RATE_FORMAT, rate_data.color, rate_data.desc)
                break
            end
        end
    end
    self.lianhua_luck:SetActive(self.equip_info.smelt_lv > 0)
    if self.equip_info.smelt_lv > 0 then
        self.lianhua_luck_text.text = string.format(UIConst.Text.SMELT_LUCK_VALUE_FORMAT, self.equip_info.lucky_value)
    end
end

function EquipmentCultivateUI:UpdateLianhuaCost()
    if not self.lianhua_cost_dict then return end
    local own_money_count = self.dy_bag_data:GetBagItemCount(CSConst.Virtual.Money)
    local money_cost_color = own_money_count >= self.lianhua_cost_dict[CSConst.Virtual.Money] and UIConst.Color.Default or UIConst.Color.Red1
    self.lianhua_money_count.text = string.format(UIConst.Text.SIMPLE_COLOR, money_cost_color, UIFuncs.AddCountUnit(self.lianhua_cost_dict[CSConst.Virtual.Money]))

    if self.equip_info.smelt_lv >= self.lianhua_open_cost_diamond_level then
        local own_diamond_count = self.dy_bag_data:GetBagItemCount(CSConst.Virtual.Diamond)
        local diamond_cost_color = own_diamond_count >= self.lianhua_cost_dict[CSConst.Virtual.Diamond] and UIConst.Color.Default or UIConst.Color.Red1
        self.lianhua_diamond_count.text = string.format(UIConst.Text.SIMPLE_COLOR, diamond_cost_color, UIFuncs.AddCountUnit(self.lianhua_cost_dict[CSConst.Virtual.Diamond]))
    end

    if self.equip_info.smelt_lv >= self.lianhua_open_cost_fragment_level then
        local own_frag_count = self.dy_bag_data:GetBagItemCount(self.equip_data.fragment)
        local cost_frag_color = own_frag_count >= self.lianhua_cost_dict[self.equip_data.fragment] and UIConst.Color.Default or UIConst.Color.Red1
        self.lianhua_fragment_count.text = string.format(UIConst.Text.SIMPLE_COLOR, cost_frag_color, self.lianhua_cost_dict[self.equip_data.fragment])
    end
end

function EquipmentCultivateUI:InitAddStarPanel()
    local cur_attr_list = AttrUtil.ConvertAttrDictToList(CSFunction.get_equip_star_attr(self.equip_data.id, self.equip_info.star_lv))
    local attr_data = SpecMgrs.data_mgr:GetAttributeData(cur_attr_list[1].attr)
    local attr_format = attr_data.is_pct and UIConst.Text.ATTR_VALUE_PCT_FORMAT or UIConst.Text.ATTR_VALUE_FORMAT
    local next_attr_format = attr_data.is_pct and UIConst.Text.NEXT_ATTR_VALUE_PCT_FORMAT or UIConst.Text.NEXT_ATTR_VALUE_FORMAT
    self.before_star_atk.text = string.format(attr_format, attr_data.name, cur_attr_list[1].value or 0)
    self.before_star_element_attr:SetActive(cur_attr_list[2] ~= nil)
    local extra_attr_data
    if cur_attr_list[2] then
        extra_attr_data = SpecMgrs.data_mgr:GetAttributeData(cur_attr_list[2].attr)
        local extra_attr_format = extra_attr_data.is_pct and UIConst.Text.ATTR_VALUE_PCT_FORMAT or UIConst.Text.ATTR_VALUE_FORMAT
        local next_extra_attr_format = extra_attr_data.is_pct and UIConst.Text.NEXT_ATTR_VALUE_PCT_FORMAT or UIConst.Text.NEXT_ATTR_VALUE_FORMAT
        self.before_star_element_attr_text.text = string.format(extra_attr_format, extra_attr_data.name, cur_attr_list[2].value or 0)
    end

    self.equip_star_btn_cmp.interactable = self.equip_info.star_lv < self.star_limit
    self.equip_star_disable:SetActive(self.equip_info.star_lv >= self.star_limit)

    local next_star_lv = self.equip_info.star_lv + 1
    local fragment_count = self.dy_bag_data:GetBagItemCount(self.equip_data.fragment)
    self.add_star_cost_dict = nil
    if next_star_lv > self.star_limit then
        self.star_material_count.text = string.format(UIConst.Text.PER_VALUE, fragment_count, 0)
        self.after_star_lv.text = UIConst.Text.ADD_STAR_LIMIT
        return
    end
    local next_attr_list = AttrUtil.ConvertAttrDictToList(CSFunction.get_equip_star_attr(self.equip_data.id, next_star_lv))
    self.after_star_lv.text = string.format(UIConst.Text.NEXT_STAR_FORMAT, next_star_lv)
    self.after_star_atk.text = string.format(next_attr_format, attr_data.name, next_attr_list[1].value)
    self.after_star_element_attr:SetActive(extra_attr_data ~= nil)
    if extra_attr_data then
        self.after_star_element_attr_text.text = string.format(next_extra_attr_format, extra_attr_data.name, next_attr_list[2].value)
    end

    self.add_star_cost_dict = CSFunction.get_equip_star_cost(self.equip_data.id, next_star_lv)
    UIFuncs.InitItemGo({
        ui = self,
        go = self.star_material_item,
        item_data = self.fragment_data,
        name_go = self.star_material_name,
        change_name_color = true,
    })
    self:UpdateAddStarCost()
    self.add_star_before_lv.text = string.format(UIConst.Text.STAR_LV, self.equip_info.star_lv)
    self.add_star_after_lv.text = string.format(UIConst.Text.NEXT_STAR_FORMAT, next_star_lv)
    self:ClearAddStarAttrItemList()
    for i, attr_tb in ipairs(next_attr_list) do
        local add_star_attr_data = SpecMgrs.data_mgr:GetAttributeData(attr_tb.attr)
        local attr_item = self:GetUIObject(self.add_star_attr_item, self.info_content)
        attr_item:FindChild("AttrName"):GetComponent("Text").text = add_star_attr_data.name
        attr_item:FindChild("BeforeAttr"):GetComponent("Text").text = cur_attr_list[i].value
        attr_item:FindChild("AfterAttr/Text"):GetComponent("Text").text = string.format(UIConst.Text.ATTR_VALUE_FORMAT, add_star_attr_data.name, attr_tb.value)
        table.insert(self.add_star_attr_item_list, attr_item)
    end
end

function EquipmentCultivateUI:UpdateAddStarCost()
    if not self.add_star_cost_dict then return end
    local cur_money_count = ComMgrs.dy_data_mgr:ExGetCurrencyCount(self.star_cost_money) or 0
    local money_cost_color = cur_money_count < self.add_star_cost_dict[self.star_cost_money] and UIConst.Color.Red1 or UIConst.Color.Default
    self.star_money_cost.text = string.format(UIConst.Text.SIMPLE_COLOR, money_cost_color, UIFuncs.AddCountUnit(self.add_star_cost_dict[self.star_cost_money]))
    local fragment_count = self.dy_bag_data:GetBagItemCount(self.equip_data.fragment)
    self.star_material_count.text = UIFuncs.GetPerStr(fragment_count, self.add_star_cost_dict[self.equip_data.fragment])
end

function EquipmentCultivateUI:ShowCultivateEffect()
    local op_data = self.cultivate_op_data[self.cur_cultivate_op]
    self.effect_animator:SetTrigger(op_data.effect_name)
    self:PlayUISound(self.equip_level_up_sound, false, true, true)
    if op_data.effect_time then
        self.cultivate_effect_timer = self:AddTimer(function ()
            self:UpdateEquipmentInfo()
            self:ShowScoreUpUI()
            op_data.init_func(self)
            self.effect_animator:SetTrigger(kCultivateEffectTriggerName.Reset)
            self.cultivate_effect_timer = nil
        end, op_data.effect_time)
    end
    if self.cur_cultivate_op == CSConst.EquipCultivateOperation.AddStar then
        local cur_star_lv = self.dy_bag_data:GetBagItemDataByGuid(self.cultivate_equip_guid).star_lv
        self:AddTimer(function ()
            local cur_star = 0
            self:AddTimer(function ()
                cur_star = cur_star + 1
                self.effect_star_list[self.star_offset + cur_star]:SetActive(true)
            end, kStarAnimDuration, self.star_limit)
        end, kStarEffectDelay)
        self:AddTimer(function ()
            local cur_star = 0
            self:AddTimer(function ()
                cur_star = cur_star + 1
                self.effect_star_list[self.star_offset + cur_star]:FindChild("Effect"):SetActive(true)
            end, kStarAnimDuration, cur_star_lv)
        end, kStarEffectDelay + (kStarAnimDuration * cur_star_lv - 1))
    end
end

function EquipmentCultivateUI:ShowScoreUpUI()
    SpecMgrs.ui_mgr:ShowScoreUpUI(self.last_score, self.last_fight_score)
    self.last_score = ComMgrs.dy_data_mgr:ExGetRoleScore()
    self.last_fight_score = ComMgrs.dy_data_mgr:ExGetFightScore()
end

function EquipmentCultivateUI:ShowEquipmentCultivateSuccessPanel()
    self:UpdateEquipmentInfo()
    if self.cultivate_op_data[self.cur_cultivate_op].result_panel then
        self.result_panel:SetActive(true)
        self.content:SetActive(false)
    else
        self.cultivate_op_data[self.cur_cultivate_op].init_func(self)
    end
end

-- msg

function EquipmentCultivateUI:SendStrengthenEquipment()
    local last_master_lv = self.lineup_data and self.lineup_data.strengthen_master_lv[CSConst.EquipPartType.Equip]
    ComMgrs.dy_data_mgr:ExSetIgnoreScoreUpFlag(true)
    SpecMgrs.msg_mgr:SendStrengthenEquipment({item_guid = self.cultivate_equip_guid}, function (resp)
        ComMgrs.dy_data_mgr:ExSetIgnoreScoreUpFlag(false)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.STRENGTH_FAILED)
        else
            local master_lv_data
            if self.lineup_data and self.lineup_data.strengthen_master_lv[CSConst.EquipPartType.Equip] > last_master_lv then
                master_lv_data = SpecMgrs.data_mgr:GetESmasterData(self.lineup_data.strengthen_master_lv[CSConst.EquipPartType.Equip])
            end
            self:ShowCultivateLevelUpHud(master_lv_data)
            self:ShowCultivateEffect()
        end
    end)
end

function EquipmentCultivateUI:SendStrengthenEquipmentFive()
    local last_master_lv = self.lineup_data and self.lineup_data.strengthen_master_lv[CSConst.EquipPartType.Equip]
    ComMgrs.dy_data_mgr:ExSetIgnoreScoreUpFlag(true)
    SpecMgrs.msg_mgr:SendStrengthenEquipmentFive({item_guid = self.cultivate_equip_guid}, function (resp)
        ComMgrs.dy_data_mgr:ExSetIgnoreScoreUpFlag(false)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.STRENGTH_FAILED)
        else
            local master_lv_data
            if self.lineup_data and self.lineup_data.strengthen_master_lv[CSConst.EquipPartType.Equip] > last_master_lv then
                master_lv_data = SpecMgrs.data_mgr:GetESmasterData(self.lineup_data.strengthen_master_lv[CSConst.EquipPartType.Equip])
            end
            self:ShowCultivateLevelUpHud(master_lv_data)
            self:ShowCultivateEffect()
        end
    end)
end

function EquipmentCultivateUI:SendRefineEquipment(cost_item)
    if self.equip_info.refine_lv >= self.refine_lv_limit then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.EQUIPMENT_REFINE_LIMIT)
        return
    end
    if UIFuncs.CheckItemCount(cost_item, 1, true) then
        local last_master_lv = self.lineup_data and self.lineup_data.refine_master_lv[CSConst.EquipPartType.Equip]
        ComMgrs.dy_data_mgr:ExSetIgnoreScoreUpFlag(true)
        SpecMgrs.msg_mgr:SendRefineEquipment({item_guid = self.cultivate_equip_guid, cost_item_id = cost_item}, function (resp)
            ComMgrs.dy_data_mgr:ExSetIgnoreScoreUpFlag(false)
            if resp.errcode ~= 0 then
                SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.REFINE_FAILED)
            else
                local effect_item = self:GetUIObject(self.refine_btn_dict[cost_item].effect_item, self.effect_list)
                table.insert(self.effect_item_list, effect_item)
                if not self.refine_effect_timer then
                    self.refine_effect_timer = self:AddTimer(function ()
                        local effect_item = table.remove(self.effect_item_list, 1)
                        if effect_item then self:DelUIObject(effect_item) end
                        if #self.effect_item_list == 0 then self:ClearRefineEffectTimer() end
                    end, 0.2, 0)
                end
                local equip_info = self.dy_bag_data:GetBagItemDataByGuid(self.cultivate_equip_guid)
                if equip_info.refine_lv == self.equip_info.refine_lv then
                    self:UpdateEquipmentInfo()
                    self:UpdateRefineExp()
                else
                    local master_lv_data
                    if self.lineup_data and self.lineup_data and self.lineup_data.refine_master_lv[CSConst.EquipPartType.Equip] > last_master_lv then
                        master_lv_data = SpecMgrs.data_mgr:GetERmasterData(self.lineup_data.refine_master_lv[CSConst.EquipPartType.Equip])
                    end
                    self:ShowCultivateLevelUpHud(master_lv_data)
                    self:ClearRefineTimer()
                    self:ShowCultivateEffect()
                end
            end
        end)
        return true
    else
        self:ClearRefineTimer()
        return false
    end
end

function EquipmentCultivateUI:SendQuickRefineEquipment()
    local last_master_lv = self.lineup_data and self.lineup_data.refine_master_lv[CSConst.EquipPartType.Equip]
    ComMgrs.dy_data_mgr:ExSetIgnoreScoreUpFlag(true)
    SpecMgrs.msg_mgr:SendQuickRefineEquipment({item_guid = self.cultivate_equip_guid, cost_item_dict = self.cur_selelct_refine_lv_data.item_dict}, function (resp)
        ComMgrs.dy_data_mgr:ExSetIgnoreScoreUpFlag(false)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.REFINE_FAILED)
        else
            self.result_refine_lv_list = nil
            self.cur_selelct_refine_lv_data = nil
            self.easy_refine_panel:SetActive(false)
            local master_lv_data
            if self.lineup_data and self.lineup_data and self.lineup_data.refine_master_lv[CSConst.EquipPartType.Equip] > last_master_lv then
                master_lv_data = SpecMgrs.data_mgr:GetERmasterData(self.lineup_data.refine_master_lv[CSConst.EquipPartType.Equip])
            end
            self:ShowCultivateLevelUpHud(master_lv_data)
            self:ShowCultivateEffect()
        end
    end)
end

function EquipmentCultivateUI:ShowCultivateLevelUpHud(master_lv_data)
    local equip_info = self.dy_bag_data:GetBagItemDataByGuid(self.cultivate_equip_guid)
    self.level_up_master_hud_panel:SetActive(master_lv_data ~= nil)
    local op_data = self.cultivate_op_data[self.cur_cultivate_op]
    if master_lv_data then
        self.level_up_master_hud_level.text = string.format(op_data.master_lv_format, master_lv_data.level)
        for i, attr in ipairs(master_lv_data.attr_list) do
            local attr_hud_item = self:GetUIObject(self.level_up_hud_attr, self.level_up_master_hud_panel)
            attr_hud_item:GetComponent("Text").text = UIFuncs.GetAttrStr(attr, master_lv_data.attr_value_list[i])
            table.insert(self.hud_attr_item_list, attr_hud_item)
        end
    end
    local attr_list
    local last_attr_dict
    local cur_attr_dict
    if self.cur_cultivate_op == CSConst.EquipCultivateOperation.Strengthen then
        self.level_up_hud_level.text = string.format(UIConst.Text.STRENGTH_LV_ADD_FORMAT, equip_info.strengthen_lv - self.equip_info.strengthen_lv)
        attr_list = self.equip_data.base_attr_list
        last_attr_dict = CSFunction.get_equip_strengthen_attr(self.equip_data.id, self.equip_info.strengthen_lv)
        cur_attr_dict = CSFunction.get_equip_strengthen_attr(self.equip_data.id, equip_info.strengthen_lv)
    elseif self.cur_cultivate_op == CSConst.EquipCultivateOperation.Refine then
        self.level_up_hud_level.text = string.format(UIConst.Text.ER_LEVEL_UP_FORMAT, self.equip_data.name, equip_info.refine_lv)
        attr_list = self.equip_data.refine_attr_list
        last_attr_dict = CSFunction.get_equip_refine_attr(self.equip_data.id, self.equip_info.refine_lv)
        cur_attr_dict = CSFunction.get_equip_refine_attr(self.equip_data.id, equip_info.refine_lv)
    end
    for _, attr in ipairs(attr_list) do
        local attr_hud_item = self:GetUIObject(self.level_up_hud_attr, self.level_up_attr_hud_panel)
        table.insert(self.hud_attr_item_list, attr_hud_item)
        attr_hud_item:GetComponent("Text").text = UIFuncs.GetAttrStr(attr, cur_attr_dict[attr] - (last_attr_dict[attr] or 0))
    end
    self.level_up_hud:SetActive(true)
    self.hide_hud_timer = self:AddTimer(function ()
        self.level_up_hud:SetActive(false)
        self:ClearAttrHudItem()
        self.hide_hud_timer = nil
    end, kHudHideDelay)
end

function EquipmentCultivateUI:SendAddEquipmentStar()
    if not UIFuncs.CheckItemCount(self.star_cost_money, self.add_star_cost_dict[self.star_cost_money], true) then return end
    if not UIFuncs.CheckItemCount(self.equip_data.fragment, self.add_star_cost_dict[self.equip_data.fragment], true) then return end
    ComMgrs.dy_data_mgr:ExSetIgnoreScoreUpFlag(true)
    SpecMgrs.msg_mgr:SendAddEquipmentStar({item_guid = self.cultivate_equip_guid}, function (resp)
        ComMgrs.dy_data_mgr:ExSetIgnoreScoreUpFlag(false)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.ADD_STAR_FAILED)
        else
            self:ShowCultivateEffect()
        end
    end)
end

function EquipmentCultivateUI:SendSmeltEquipment()
    if not self:CalcLianhuaCost() then return end
    ComMgrs.dy_data_mgr:ExSetIgnoreScoreUpFlag(true)
    SpecMgrs.msg_mgr:SendSmeltEquipment({item_guid = self.cultivate_equip_guid, cost_item_id = self.cur_select_lianhua_material}, function (resp)
        ComMgrs.dy_data_mgr:ExSetIgnoreScoreUpFlag(false)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.SMELT_FAILED)
        else
            self.equip_lianhua_btn_cmp.interactable = true
            local cur_smelt_lv_data = SpecMgrs.data_mgr:GetEquipSmeltData(self.equip_info.smelt_lv + 1)
            if resp.is_success then
                local attr_data = SpecMgrs.data_mgr:GetAttributeData(self.equip_data.smelt_attr)
                self:ShowCultivateEffect()
                if resp.crit and resp.crit > 1 then
                    self.succeed_text.text = string.format(UIConst.Text.SMELT_CRIT_FORMAT, resp.crit == CSConst.SmeltCritRate1 and CSConst.SmeltCritRate1 or CSConst.SmeltCritRate2)
                else
                    self.succeed_text.text = UIConst.Text.SUCCESS
                end
                local add_exp = cur_smelt_lv_data.each_exp * (resp.crit or 1)
                local add_attr = self.equip_data.smelt_attr_value[self.equip_info.smelt_lv + 1] / cur_smelt_lv_data.exp * add_exp
                self.succeed_attr.text = string.format(UIConst.Text.ADD, attr_data.name, math.floor(add_attr))
                self.succeed_exp.text = string.format(UIConst.Text.ADD_SMELT_EXP_FORMAT, math.floor(add_exp))
                self:ShowCultivateEffect()
            else
                self.luck_hud.text = string.format(UIConst.Text.ADD_LUCKY_FORMAT, cur_smelt_lv_data.add_luck)
                self:UpdateEquipmentInfo()
                self:UpdateLianHuaExp()
            end
            self.lianhua_crit_img:SetActive(resp.is_success and resp.crit ~= nil)
            self.failed_hud:SetActive(not resp.is_success)
            self.succeed_hud:SetActive(resp.is_success)
            self.lianhua_hud:SetActive(true)
            self.effect_mask:SetActive(true)
            self.hide_lianhua_hud_timer = self:AddTimer(function ()
                self.lianhua_hud:SetActive(false)
                self.hide_lianhua_hud_timer = nil
                self.effect_mask:SetActive(false)
            end, self.cultivate_op_data[CSConst.EquipCultivateOperation.LianHua].effect_time)
        end
    end)
end

function EquipmentCultivateUI:CalcLianhuaCost()
    local cost_num = self.lianhua_cost_dict[self.cur_select_lianhua_material]
    local ret = false
    if self.equip_info.smelt_lv < self.lianhua_lv_limit then
        ret = UIFuncs.CheckItemCount(self.cur_select_lianhua_material, cost_num, true)
    end
    if not ret then self.equip_lianhua_btn_cmp.interactable = true end
    return ret
end

function EquipmentCultivateUI:ClearRefineTimer()
    if self.refine_timer then
        self:RemoveTimer(self.refine_timer)
        self.refine_timer = nil
    end
end

function EquipmentCultivateUI:ClearAddStarAttrItemList()
    for _, attr_item in ipairs(self.add_star_attr_item_list) do
        self:DelUIObject(attr_item)
    end
    self.add_star_attr_item_list = {}
end

function EquipmentCultivateUI:ClearRefineEffectTimer()
    if self.refine_effect_timer then
        self:RemoveTimer(self.refine_effect_timer)
        self.refine_effect_timer = nil
    end
end

function EquipmentCultivateUI:ClearRefineEffectItem()
    for _, item in ipairs(self.effect_item_list) do
        self:DelUIObject(item)
    end
    self.effect_item_list = {}
end

function EquipmentCultivateUI:ClearAttrHudItem()
    for _, hud_item in ipairs(self.hud_attr_item_list) do
        self:DelUIObject(hud_item)
    end
    self.hud_attr_item_list = {}
end

function EquipmentCultivateUI:ClearAllTimer()
    if self.hide_hud_timer then
        self:RemoveTimer(self.hide_hud_timer)
        self.hide_hud_timer = nil
    end
    if self.hide_lianhua_hud_timer then
        self:RemoveTimer(self.hide_lianhua_hud_timer)
        self.hide_lianhua_hud_timer = nil
    end
    if self.cultivate_effect_timer then
        self:RemoveTimer(self.cultivate_effect_timer)
        self.cultivate_effect_timer = nil
    end
end

function EquipmentCultivateUI:Close()
    local last_cultivate_op_data = self.cultivate_op_data[self.cur_cultivate_op]
    last_cultivate_op_data.btn:FindChild("Select"):SetActive(false)
    last_cultivate_op_data.panel:SetActive(false)
    if last_cultivate_op_data.result_panel then last_cultivate_op_data.result_panel:SetActive(false) end
    for _, star_item in ipairs(self.equip_star_list) do
        self:DelUIObject(star_item)
    end
    self.equip_star_list = {}
    self.cur_cultivate_op = nil
    self.cultivate_equip_guid = nil
    self.cur_select_lianhua_material = nil
    self:ClearAllTimer()
    self:ClearRefineTimer()
    self:ClearRefineEffectItem()
end

return EquipmentCultivateUI