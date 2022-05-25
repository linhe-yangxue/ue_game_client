local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local UnitConst = require("Unit.UnitConst")
local CSFunction = require("CSCommon.CSFunction")
local AttrUtil = require("BaseUtilities.AttrUtil")
local SlideSelectCmp = require("UI.UICmp.SlideSelectCmp")

local TrainHeroUI = class("UI.TrainHeroUI", UIBase)

local kUpgradeEffectDuration = 1.3
local kResetDuration = 0.3
local kCultivateEffectDuration = 0.9
local kEffectPosAnimDuration = 0.35
local kCountAnimDuration = 0.6
local kCountAnimInterval = 0.02
local kAutoDestinyInterval = 0.1
local kDestinyClickAnimDuration = 0.5

local kAttrItemDict = {
    ["Business"] = CSConst.RoleAttrName.Business,
    ["Management"] = CSConst.RoleAttrName.Management,
    ["Renown"] = CSConst.RoleAttrName.Renown,
    ["Fight"] = CSConst.RoleAttrName.Fight,
    ["Random"] = "random",
}

local kDragEffectTriggerName = "drag"
local kCultivateEffectTriggerName = {
    Upgrade = "upgrade",
    Break = "break",
    AddStar = "star",
    Destiny = "destiny",
    Cultivate = "upgrade",
    Reset = "reset",
}

local kHeroIndex = {
    Pre = 0,
    Cur = 1,
    Next = 2,
}

function TrainHeroUI:DoInit()
    TrainHeroUI.super.DoInit(self)
    self.prefab_path = "UI/Common/TrainHeroUI"
    self.dy_night_club_data = ComMgrs.dy_data_mgr.night_club_data
    self.dy_bag_data = ComMgrs.dy_data_mgr.bag_data
    self.cultivate_op_data = {}
    self.star_limit = SpecMgrs.data_mgr:GetParamData("hero_star_lv_limit").f_value
    self.upgrade_cost_currency = SpecMgrs.data_mgr:GetParamData("hero_levelup_cost_coin").item_id
    self.break_cost_currency = SpecMgrs.data_mgr:GetParamData("hero_break_cost_coin").item_id
    self.break_cost_item = SpecMgrs.data_mgr:GetParamData("hero_break_cost_item").item_id
    self.add_star_cost_currency = SpecMgrs.data_mgr:GetParamData("hero_star_cost_coin").item_id
    self.destiny_cost_item = SpecMgrs.data_mgr:GetParamData("hero_destiny_cost_item").item_id

    self.long_destiny_sound = SpecMgrs.data_mgr:GetParamData("long_destiny_sound").sound_id
    self.destiny_click_sound = SpecMgrs.data_mgr:GetParamData("destiny_sound").sound_id
    self.hero_upgrade_sound = SpecMgrs.data_mgr:GetParamData("hero_level_up_sound").sound_id

    self.hero_star_list = {}
    self.attr_tag_btn_dict = {}
    self.attr_effect_text_dict = {}
    self.cultivate_attr_item_list = {}
    self.hero_model_dict = {}
    self.hero_break_model_dict = {}
    self.hero_unit_dict = {}
    self.attr_item_list = {}
end

function TrainHeroUI:OnGoLoadedOk(res_go)
    TrainHeroUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function TrainHeroUI:Hide()
    self.cultivate_op = nil
    if self.cultivate_effect_timer then
        self:RemoveTimer(self.cultivate_effect_timer)
        self.cultivate_effect_timer = nil
    end
    self:ClearEffectResetTimer()
    self:ClearHeroCultivateTab()
    self:RemoveAfterBreakUnit()
    self:RemoveAutoDestinyTimer()
    self:RemoveCloseDestinyEffectTimer()
    self.dy_night_club_data:UnregisterUpdateHeroEvent("TrainHeroUI")
    self.dy_night_club_data:UnregisterUpdateLineupEvent("TrainHeroUI")
    ComMgrs.dy_data_mgr:UnregisterUpdateRoleInfoEvent("TrainHeroUI")
    TrainHeroUI.super.Hide(self)
end

function TrainHeroUI:Show(hero_list, index, operation, cb)
    self.hero_list = hero_list
    self.hero_count = #hero_list
    self.cultivate_hero_index = index
    self.cultivate_hero_id = self.hero_list[index].id
    self.cultivate_op = operation
    self.close_cb = cb
    if self.is_res_ok then
        self:InitUI()
    end
    TrainHeroUI.super.Show(self)
end

function TrainHeroUI:InitRes()
    self.content = self.main_panel:FindChild("Content")
    UIFuncs.InitTopBar(self, self.content:FindChild("TopBar"), "TrainHeroUI", function ()
        self:Close()
        self:Hide()
    end)

    self.effect_animator = self.content:GetComponent("Animator")

    local tab_panel = self.content:FindChild("TabPanel")
    self:AddClick(tab_panel:FindChild("Left"), function ()
        self.tab_content_rect_cmp.anchoredPosition = Vector2.zero
    end)
    self:AddClick(tab_panel:FindChild("Right"), function ()
        self.tab_content_rect_cmp.anchoredPosition = Vector2.New(-self.tab_content_rect_cmp.rect.width, 0)
    end)
    local tab_content = tab_panel:FindChild("TabList/View/Content")
    self.tab_content_rect_cmp = tab_content:GetComponent("RectTransform")
    for _, op in pairs(CSConst.CultivateOperation) do
        self.cultivate_op_data[op] = {}
    end
    self.upgrate_btn = tab_content:FindChild("UpgrateBtn")
    self.cultivate_op_data[CSConst.CultivateOperation.Upgrade].btn = self.upgrate_btn
    self.cultivate_op_data[CSConst.CultivateOperation.Upgrade].trigger_name = kCultivateEffectTriggerName.Upgrade
    self.cultivate_op_data[CSConst.CultivateOperation.Upgrade].effect_time = kUpgradeEffectDuration
    self.upgrate_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.UPGRADE
    self.upgrate_btn:FindChild("Select/Text"):GetComponent("Text").text = UIConst.Text.UPGRADE
    self.upgrate_btn_cmp = self.upgrate_btn:GetComponent("Button")
    self:AddClick(self.upgrate_btn, function ()
        self:UpdateCultivatePanel(CSConst.CultivateOperation.Upgrade)
    end)
    self.break_btn = tab_content:FindChild("BreakBtn")
    self.cultivate_op_data[CSConst.CultivateOperation.Break].btn = self.break_btn
    self.cultivate_op_data[CSConst.CultivateOperation.Break].trigger_name = kCultivateEffectTriggerName.Break
    self.break_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.BREAK
    self.break_btn:FindChild("Select/Text"):GetComponent("Text").text = UIConst.Text.BREAK
    self.break_btn_cmp = self.break_btn:GetComponent("Button")
    self:AddClick(self.break_btn, function ()
        self:UpdateCultivatePanel(CSConst.CultivateOperation.Break)
    end)
    self.star_btn = tab_content:FindChild("StarBtn")
    self.cultivate_op_data[CSConst.CultivateOperation.AddStar].btn = self.star_btn
    self.cultivate_op_data[CSConst.CultivateOperation.AddStar].trigger_name = kCultivateEffectTriggerName.AddStar
    self.star_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ADD_STAR
    self.star_btn:FindChild("Select/Text"):GetComponent("Text").text = UIConst.Text.ADD_STAR
    self.star_btn_cmp = self.star_btn:GetComponent("Button")
    self:AddClick(self.star_btn, function ()
        self:UpdateCultivatePanel(CSConst.CultivateOperation.AddStar)
    end)
    self.destiny_btn = tab_content:FindChild("DestinyBtn")
    self.cultivate_op_data[CSConst.CultivateOperation.Destiny].btn = self.destiny_btn
    self.cultivate_op_data[CSConst.CultivateOperation.Destiny].trigger_name = kCultivateEffectTriggerName.Destiny
    self.destiny_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DESTINY
    self.destiny_btn:FindChild("Select/Text"):GetComponent("Text").text = UIConst.Text.DESTINY
    self.destiny_btn_cmp = self.destiny_btn:GetComponent("Button")
    self:AddClick(self.destiny_btn, function ()
        self:UpdateCultivatePanel(CSConst.CultivateOperation.Destiny)
    end)
    self.cultivate_btn = tab_content:FindChild("CultivateBtn")
    self.cultivate_op_data[CSConst.CultivateOperation.Cultivate].btn = self.cultivate_btn
    self.cultivate_op_data[CSConst.CultivateOperation.Cultivate].trigger_name = kCultivateEffectTriggerName.Cultivate
    self.cultivate_op_data[CSConst.CultivateOperation.Cultivate].effect_time = kCultivateEffectDuration
    self.cultivate_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CULTIVATE
    self.cultivate_btn:FindChild("Select/Text"):GetComponent("Text").text = UIConst.Text.CULTIVATE
    self:AddClick(self.cultivate_btn, function ()
        self:UpdateCultivatePanel(CSConst.CultivateOperation.Cultivate)
    end)

    self.hero_info = self.content:FindChild("HeroInfo")
    self.hero_name = self.hero_info:FindChild("NamePanel/Text"):GetComponent("Text")
    self.hero_grade = self.hero_info:FindChild("NamePanel/Grade"):GetComponent("Image")
    local star_panel = self.hero_info:FindChild("StarPanel")
    for i = 1, self.star_limit do
        self.hero_star_list[i] = star_panel:FindChild("Star" .. i)
    end
    local hero_img_panel = self.hero_info:FindChild("HeroImg")
    local hero_model = hero_img_panel:FindChild("HeroModel")
    local hero_model_width = hero_model:GetComponent("RectTransform").rect.width
    local hero1 = hero_model:FindChild("Hero1")
    self.hero_model_dict[kHeroIndex.Pre] = hero1
    hero1:GetComponent("RectTransform").anchoredPosition = Vector2.New(-hero_model_width, 0)
    local hero2 = hero_model:FindChild("Hero2")
    self.hero_model_dict[kHeroIndex.Cur] = hero2
    local hero3 = hero_model:FindChild("Hero3")
    self.hero_model_dict[kHeroIndex.Next] = hero3
    hero3:GetComponent("RectTransform").anchoredPosition = Vector2.New(hero_model_width, 0)
    self.hero_slide_cmp = SlideSelectCmp:New()
    self.hero_slide_cmp:DoInit(self, hero_model)
    self.hero_slide_cmp:ListenSlideBegin(function ()
        self.effect_animator:SetTrigger(kDragEffectTriggerName)
    end)
    self.hero_slide_cmp:ListenSlideEnd(function (move_dir)
        self.move_dir = move_dir
        if move_dir ~= 0 then
            self.cultivate_hero_index = math.Repeat(self.cultivate_hero_index + move_dir - 1, self.hero_count) + 1
            self.cultivate_hero_id = self.hero_list[self.cultivate_hero_index].id
            self:InitHeroInfo()
            self.cultivate_op_data[self.cur_cultivate_op].init_func(self)
        end
    end)
    self.hero_slide_cmp:ListenSelectUpdate(function (index)
        if index >= 0 then self:RefreshModel(index) end
        self.effect_animator:SetTrigger(kCultivateEffectTriggerName.Reset)
    end)

    self.hero_quality = hero_img_panel:FindChild("Quality"):GetComponent("Image")
    self.add_destiny_effect = hero_img_panel:FindChild("tianming_qianghua")
    self.hero_hud_point = hero_img_panel:FindChild("HudPoint")

    -- 升级
    self.upgrate_panel = self.content:FindChild("UpgratePanel")
    self.cultivate_op_data[CSConst.CultivateOperation.Upgrade].panel = self.upgrate_panel
    self.cultivate_op_data[CSConst.CultivateOperation.Upgrade].init_func = self.InitUpgratePanel
    self.cultivate_op_data[CSConst.CultivateOperation.Upgrade].update_cost_func = self.UpdateUpgradeCost
    self.upgrade_img = self.upgrate_panel:FindChild("Image")
    self.upgrade_left_attr_panel = self.upgrate_panel:FindChild("LeftAttrPanel")
    self.before_upgrate_lv = self.upgrade_left_attr_panel:FindChild("Level"):GetComponent("Text")
    self.upgrate_right_attr_panel = self.upgrate_panel:FindChild("RightAttrPanel")
    self.after_upgrate_lv = self.upgrate_right_attr_panel:FindChild("Level"):GetComponent("Text")

    local bottom_panel = self.upgrate_panel:FindChild("BottomPanel")
    self.hero_upgrade_btn = bottom_panel:FindChild("UpgrateBtn")
    self.hero_upgrade_btn_cmp = self.hero_upgrade_btn:GetComponent("Button")
    self.cultivate_op_data[CSConst.CultivateOperation.Upgrade].btn_cmp = self.hero_upgrade_btn_cmp
    self.hero_upgrade_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.UPGRADE
    self:AddClick(self.hero_upgrade_btn, function ()
        self.hero_upgrade_btn_cmp.interactable = false
        self:SendHeroUpgrate()
    end)
    self.ten_grade_toggle = bottom_panel:FindChild("TenGrade")
    self.ten_grade_toggle:FindChild("Label"):GetComponent("Text").text = UIConst.Text.TEN_GRADE
    self.ten_grade_toggle_cmp = self.ten_grade_toggle:GetComponent("Toggle")
    self:AddToggle(self.ten_grade_toggle, function (is_on)
        self.is_upgrate_ten = is_on
        self:InitUpgratePanel()
    end)
    self.upgrate_cost_panel = self.hero_upgrade_btn:FindChild("CostPanel")
    self.upgrate_cost_text = self.upgrate_cost_panel:FindChild("CostCount"):GetComponent("Text")
    self.upgrate_panel:SetActive(false)
    -- 突破
    self.break_panel = self.content:FindChild("BreakPanel")
    self.cultivate_op_data[CSConst.CultivateOperation.Break].panel = self.break_panel
    self.cultivate_op_data[CSConst.CultivateOperation.Break].init_func = self.InitBreakPanel
    self.cultivate_op_data[CSConst.CultivateOperation.Break].update_cost_func = self.UpdateBreakCost

    local left_hero_list = self.break_panel:FindChild("LeftHeroList")
    local left_hero_model_width = left_hero_list:GetComponent("RectTransform").rect.width
    local break_hero1 = left_hero_list:FindChild("Hero1")
    break_hero1:GetComponent("RectTransform").anchoredPosition = Vector2.New(-left_hero_model_width, 0)
    self.hero_break_model_dict[kHeroIndex.Pre] = break_hero1:FindChild("HeroModel")
    local break_hero2 = left_hero_list:FindChild("Hero2")
    break_hero2:GetComponent("RectTransform").anchoredPosition = Vector2.zero
    self.hero_break_model_dict[kHeroIndex.Cur] = break_hero2:FindChild("HeroModel")
    local break_hero3 = left_hero_list:FindChild("Hero3")
    break_hero3:GetComponent("RectTransform").anchoredPosition = Vector2.New(left_hero_model_width, 0)
    self.hero_break_model_dict[kHeroIndex.Next] = break_hero3:FindChild("HeroModel")
    self.hero_break_slide_cmp = SlideSelectCmp.New()
    self.hero_break_slide_cmp:DoInit(self, left_hero_list)
    self.hero_break_slide_cmp:ListenSlideBegin(function ()
        self.effect_animator:SetTrigger(kDragEffectTriggerName)
    end)
    self.hero_break_slide_cmp:ListenSlideEnd(function (move_dir)
        self.move_dir = move_dir
        if move_dir ~= 0 then
            self.cultivate_hero_index = math.Repeat(self.cultivate_hero_index + move_dir - 1, self.hero_count) + 1
            self.cultivate_hero_id = self.hero_list[self.cultivate_hero_index].id
            self:InitHeroInfo()
            self:RemoveAfterBreakUnit()
            self:InitBreakPanel()
        end
    end)
    self.hero_break_slide_cmp:ListenSelectUpdate(function (index)
        if index >= 0 then self:RefreshModel(index) end
        self.effect_animator:SetTrigger(kCultivateEffectTriggerName.Reset)
    end)

    local left_hero_panel = self.break_panel:FindChild("LeftHeroPanel")
    self.before_break_name = left_hero_panel:FindChild("NamePanel/Text"):GetComponent("Text")
    self.before_break_grade = left_hero_panel:FindChild("NamePanel/Grade"):GetComponent("Image")
    self.lv_limit = left_hero_panel:FindChild("LvLimit")
    self.lv_limit_text = self.lv_limit:GetComponent("Text")

    self.right_hero_panel = self.break_panel:FindChild("RightHeroPanel")
    self.after_break_name = self.right_hero_panel:FindChild("NamePanel/Text"):GetComponent("Text")
    self.after_break_grade = self.right_hero_panel:FindChild("NamePanel/Grade"):GetComponent("Image")
    local right_hero_model = self.right_hero_panel:FindChild("HeroImg")
    self.after_break_img = right_hero_model:FindChild("HeroModel")
    self.talent_name = self.right_hero_panel:FindChild("Talent"):GetComponent("Text")
    self.talent_desc = self.right_hero_panel:FindChild("TalentDesc"):GetComponent("Text")

    local attr_panel = self.break_panel:FindChild("AttrPanel")
    attr_panel:FindChild("Title/Left"):GetComponent("Text").text = UIConst.Text.CUR_LEVEL_ATTR
    self.break_left_attr_panel = attr_panel:FindChild("LeftAttr")
    self.before_break_lv = self.break_left_attr_panel:FindChild("BreakLv"):GetComponent("Text")
    self.after_break_title = attr_panel:FindChild("Title/Right"):GetComponent("Text")
    self.break_right_attr_panel = attr_panel:FindChild("RightAttr")
    self.after_break_lv = self.break_right_attr_panel:FindChild("BreakLv"):GetComponent("Text")

    bottom_panel = self.break_panel:FindChild("BottomPanel")
    bottom_panel:FindChild("Image/Title"):GetComponent("Text").text = UIConst.Text.BREAK_MATERIAL_TEXT
    local break_material_content = bottom_panel:FindChild("MaterialPanel")
    self.break_cost_material_item = break_material_content:FindChild("CostItem")
    self.break_cost_item_count = self.break_cost_material_item:FindChild("Count"):GetComponent("Text")
    self.break_cost_fragment_item = break_material_content:FindChild("FragmentItem")
    self.break_cost_fragment_count = self.break_cost_fragment_item:FindChild("Count"):GetComponent("Text")
    self.hero_break_btn = bottom_panel:FindChild("BreakBtnPanel/BreakBtn")
    self.hero_break_btn_cmp = self.hero_break_btn:GetComponent("Button")
    self.cultivate_op_data[CSConst.CultivateOperation.Break].btn_cmp = self.hero_break_btn_cmp
    self.hero_break_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.BREAK
    self:AddClick(self.hero_break_btn, function ()
        self.hero_break_btn_cmp.interactable = false
        self:SendHeroBreakThrough()
    end)
    self.break_cost_panel = bottom_panel:FindChild("BreakBtnPanel/MoneyCost")
    self.break_cost = self.break_cost_panel:FindChild("Count"):GetComponent("Text")

    local break_result_info_content = self.break_panel:FindChild("InfoPanel/Info")
    self.break_result_before_name = break_result_info_content:FindChild("BeforeName"):GetComponent("Text")
    self.break_result_after_name = break_result_info_content:FindChild("AfterName"):GetComponent("Text")
    self.break_info_content = break_result_info_content:FindChild("InfoScroll/View/Content")
    self.break_info_content_rect = self.break_info_content:GetComponent("RectTransform")
    self.break_result_talent = break_result_info_content:FindChild("TalentPanel/Talent"):GetComponent("Text")
    self.break_result_talent_desc = break_result_info_content:FindChild("TalentPanel/TalentDesc"):GetComponent("Text")
    self.break_panel:SetActive(false)

    -- 升星
    self.add_star_panel = self.content:FindChild("StarPanel")
    self.cultivate_op_data[CSConst.CultivateOperation.AddStar].panel = self.add_star_panel
    self.cultivate_op_data[CSConst.CultivateOperation.AddStar].init_func = self.InitAddStarPanel
    self.cultivate_op_data[CSConst.CultivateOperation.AddStar].update_cost_func = self.UpdateAddStarCost
    self.add_star_img = self.add_star_panel:FindChild("Image")
    self.star_left_attr_panel = self.add_star_panel:FindChild("LeftAttrPanel")
    self.before_add_star_desc = self.star_left_attr_panel:FindChild("StarDesc"):GetComponent("Text")
    self.before_add_star_panel = self.star_left_attr_panel:FindChild("StarPanel")
    self.add_star_right_attr_panel = self.add_star_panel:FindChild("RightAttrPanel")
    self.after_add_star_desc = self.add_star_right_attr_panel:FindChild("StarDesc"):GetComponent("Text")
    self.after_add_star_panel = self.add_star_right_attr_panel:FindChild("StarPanel")

    bottom_panel = self.add_star_panel:FindChild("BottomPanel")
    self.add_star_fragment_item = bottom_panel:FindChild("MaterialPanel")
    self.add_star_fragment_count = self.add_star_fragment_item:FindChild("Count"):GetComponent("Text")
    self.hero_add_star_btn = bottom_panel:FindChild("StarBtn")
    self.hero_add_star_btn_cmp = self.hero_add_star_btn:GetComponent("Button")
    self.cultivate_op_data[CSConst.CultivateOperation.AddStar].btn_cmp = self.hero_add_star_btn_cmp
    self.hero_add_star_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ADD_STAR
    self:AddClick(self.hero_add_star_btn, function ()
        self.hero_add_star_btn_cmp.interactable = false
        self:SendHeroAddStar()
    end)
    self.add_star_cost_panel = self.hero_add_star_btn:FindChild("CostPanel")
    self.add_star_cost = self.add_star_cost_panel:FindChild("Count"):GetComponent("Text")

    local star_result_info_content = self.add_star_panel:FindChild("InfoPanel/Info")
    self.add_star_result_before_name = star_result_info_content:FindChild("BeforeName"):GetComponent("Text")
    self.add_star_result_after_name = star_result_info_content:FindChild("AfterName"):GetComponent("Text")
    self.star_info_content = star_result_info_content:FindChild("InfoScroll/View/Content")
    self.add_star_info_rect = self.star_info_content:GetComponent("RectTransform")
    self.add_star_spell = star_result_info_content:FindChild("SpellPanel/GodSpell"):GetComponent("Text")
    self.add_star_talent = star_result_info_content:FindChild("SpellPanel/GodTalent"):GetComponent("Text")
    self.add_star_panel:SetActive(false)

    -- 天命
    self.destiny_panel = self.content:FindChild("DestinyPanel")
    self.cultivate_op_data[CSConst.CultivateOperation.Destiny].panel = self.destiny_panel
    self.cultivate_op_data[CSConst.CultivateOperation.Destiny].init_func = self.InitDestinyPanel
    self.cultivate_op_data[CSConst.CultivateOperation.Destiny].update_cost_func = self.UpdateDestinyCost
    self.destiny_left_attr_panel = self.destiny_panel:FindChild("LeftAttrPanel")
    self.before_destiny_desc = self.destiny_left_attr_panel:FindChild("DestinyDesc"):GetComponent("Text")
    self.destiny_right_attr_panel = self.destiny_panel:FindChild("RightAttrPanel")
    self.after_destiny_desc = self.destiny_right_attr_panel:FindChild("DestinyDesc"):GetComponent("Text")

    bottom_panel = self.destiny_panel:FindChild("BottomPanel")
    local destiny_item_panel = bottom_panel:FindChild("DestinyItem")
    self.destiny_item_btn = destiny_item_panel:FindChild("Icon")
    UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetItemData(self.destiny_cost_item).icon, self.destiny_item_btn:GetComponent("Image"))
    self.destiny_item_btn_cmp = self.destiny_item_btn:GetComponent("Button")
    self.cultivate_op_data[CSConst.CultivateOperation.Destiny].btn_cmp = self.destiny_item_btn_cmp
    self.destiny_item_disable = self.destiny_item_btn:FindChild("Disable")
    UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetItemData(self.destiny_cost_item).icon, self.destiny_item_disable:GetComponent("Image"))
    self.destiny_item_count = destiny_item_panel:FindChild("CountBg/Count"):GetComponent("Text")
    local destiny_bar = bottom_panel:FindChild("DestinyBar")
    self.cur_destiny_value = destiny_bar:FindChild("DestinyValue"):GetComponent("Text")
    self.destiny_bar_value = destiny_bar:FindChild("Value"):GetComponent("Image")
    self:AddClick(self.destiny_item_btn, function ()
        if self.auto_destiny_timer then
            self.auto_destiny_toggle_cmp.isOn = false
            self:RemoveAutoDestinyTimer()
        else
            local hero_data = self.dy_night_club_data:GetHeroDataById(self.cultivate_hero_id)
            local destiny_data = SpecMgrs.data_mgr:GetHeroDestinyData(hero_data.destiny_lv)
            if self.auto_destiny then
                self.auto_destiny_sound = self:PlayUISound(self.long_destiny_sound, true, false)
                self.auto_destiny_timer = self:AddTimer(function ()
                    self:SendAddDestiny(destiny_data.cost_num)
                end, 0.2, 0)
            else
                self:SendAddDestiny(destiny_data.cost_num)
            end
        end
    end, self.destiny_click_sound)
    self:AddLongPress(self.destiny_item_btn, function ()
        local hero_data = self.dy_night_club_data:GetHeroDataById(self.cultivate_hero_id)
        local destiny_lv_list = SpecMgrs.data_mgr:GetHeroDestinyLvList()
        if hero_data.destiny_lv >= #destiny_lv_list then return end
        if not self.auto_destiny_timer then
            local destiny_data = SpecMgrs.data_mgr:GetHeroDestinyData(hero_data.destiny_lv)
            self.auto_destiny_sound = self:PlayUISound(self.long_destiny_sound, true, false)
            self.auto_destiny_timer = self:AddTimer(function ()
                self:SendAddDestiny(destiny_data.cost_num)
            end, kAutoDestinyInterval, 0)
        end
    end)
    bottom_panel:FindChild("Cost/Text"):GetComponent("Text").text = UIConst.Text.COST_TEXT
    self.destiny_cost = bottom_panel:FindChild("Cost/Count"):GetComponent("Text")
    self.auto_destiny_toggle = bottom_panel:FindChild("AutoDestiny")
    self.auto_destiny_toggle_cmp = self.auto_destiny_toggle:GetComponent("Toggle")
    self:AddToggle(self.auto_destiny_toggle, function (is_on)
        self.auto_destiny = is_on
        self:RemoveAutoDestinyTimer()
    end)
    bottom_panel:FindChild("TipPanel/Tip"):GetComponent("Text").text = UIConst.Text.DESTINY_RESET_TIP
    self.probability = bottom_panel:FindChild("TipPanel/Probability")
    self.probability_text = self.probability:GetComponent("Text")

    local destiny_result_info_content = self.destiny_panel:FindChild("InfoPanel/Info")
    local destint_info_content = destiny_result_info_content:FindChild("InfoScroll/View/Content")
    self.destiny_info_rect = destint_info_content:GetComponent("RectTransform")
    local atk_panel = destint_info_content:FindChild("Atk")
    atk_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ATK_TEXT
    self.destiny_result_before_atk = atk_panel:FindChild("BeforeAtk"):GetComponent("Text")
    self.destiny_result_after_atk = atk_panel:FindChild("AfterAtk"):GetComponent("Text")
    local hp_panel = destint_info_content:FindChild("Hp")
    hp_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.HP_TEXT
    self.destiny_result_before_hp = hp_panel:FindChild("BeforeHp"):GetComponent("Text")
    self.destiny_result_after_hp = hp_panel:FindChild("AfterHp"):GetComponent("Text")
    local def_panel = destint_info_content:FindChild("Def")
    def_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DEF_TEXT
    self.destiny_result_before_def = def_panel:FindChild("BeforeDef"):GetComponent("Text")
    self.destiny_result_after_def = def_panel:FindChild("AfterDef"):GetComponent("Text")
    self.destiny_result_low_spell_panel = destint_info_content:FindChild("LowSpell")
    self.destiny_result_low_spell_name = self.destiny_result_low_spell_panel:FindChild("SpellName/Text"):GetComponent("Text")
    self.destiny_result_before_low_spell_lv = self.destiny_result_low_spell_panel:FindChild("BeforeLv"):GetComponent("Text")
    self.destiny_result_after_low_spell_lv = self.destiny_result_low_spell_panel:FindChild("AfterLv"):GetComponent("Text")
    self.destiny_result_high_spell_panel = destint_info_content:FindChild("HighSpell")
    self.destiny_result_high_spell_name = self.destiny_result_high_spell_panel:FindChild("SpellName/Text"):GetComponent("Text")
    self.destiny_result_before_high_spell_lv = self.destiny_result_high_spell_panel:FindChild("BeforeLv"):GetComponent("Text")
    self.destiny_result_after_high_spell_lv = self.destiny_result_high_spell_panel:FindChild("AfterLv"):GetComponent("Text")
    self.destiny_result_lv = destiny_result_info_content:FindChild("DestinyLv/Text"):GetComponent("Text")
    self.destiny_panel:SetActive(false)

    -- 培养
    local cultivate_panel = self.content:FindChild("CultivatePanel")
    self.cultivate_op_data[CSConst.CultivateOperation.Cultivate].panel = cultivate_panel
    self.cultivate_op_data[CSConst.CultivateOperation.Cultivate].init_func = self.InitCultivateHeroPanel
    local cultivate_attr_panel = cultivate_panel:FindChild("AttrPanel")
    self.cultivate_total_attr = cultivate_attr_panel:FindChild("TotalAttr")
    self.cultivate_total_attr_text = self.cultivate_total_attr:GetComponent("Text")

    for attr_name, attr in pairs(CSConst.RoleAttrName) do
        local attr_tb = {}
        local attr_panel = cultivate_attr_panel:FindChild(attr_name)
        attr_tb.attr = attr_panel:FindChild("Value")
        attr_tb.attr_text = attr_panel:FindChild("Value"):GetComponent("Text")
        attr_tb.effect = attr_panel:FindChild("Effect")
        attr_tb.effect_text = attr_panel:FindChild("Effect/Value"):GetComponent("Text")
        self.attr_effect_text_dict[attr] = attr_tb
    end

    local item_panel = cultivate_panel:FindChild("ItemPanel")
    local ten_toggle = item_panel:FindChild("TenToggle")
    ten_toggle:FindChild("Bg/Text"):GetComponent("Text").text = UIConst.Text.AWARD_TEN_TEXT
    self.ten_toggle_cmp = ten_toggle:GetComponent("Toggle")
    self:AddToggle(ten_toggle, function (is_on)
        self.is_send_ten_item = is_on
    end)
    self.cultivate_item_list = item_panel:FindChild("List")
    self.cultivate_list_center_pos = self.cultivate_item_list:GetComponent("RectTransform").rect.size / 2
    self.cultivate_item = self.cultivate_item_list:FindChild("Item")
    self.cultivate_icon_offset = self.cultivate_item:FindChild("IconBg"):GetComponent("RectTransform").anchoredPosition
    self.cultivate_effect_item = item_panel:FindChild("EffectList/EffectItem")
    self.cultivate_effect_item_rect = self.cultivate_effect_item:GetComponent("RectTransform")
    self.cultivate_effect_anim_cmp = self.cultivate_effect_item:GetComponent("UITweenPosition")
    local tag_list = cultivate_panel:FindChild("TagList")
    for name, attr in pairs(kAttrItemDict) do
        local tab_btn = tag_list:FindChild(name)
        self.attr_tag_btn_dict[attr] = tab_btn
        local attr_data = SpecMgrs.data_mgr:GetAttributeData(attr)
        tab_btn:FindChild("Text"):GetComponent("Text").text = attr_data and attr_data.name or UIConst.Text.RANDOM
        self:AddClick(tab_btn, function ()
            self:UpdateCultivateItemList(attr)
        end)
    end
    cultivate_panel:SetActive(false)

    local reset_btn = self.content:FindChild("ResetBtn")
    reset_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CLICK_FOR_CONTINUE
    self:AddClick(reset_btn, function ()
        local cur_op_data = self.cultivate_op_data[self.cur_cultivate_op]
        self.effect_animator:SetTrigger(kCultivateEffectTriggerName.Reset)
        self.effect_reset_timer = self:AddTimer(function ()
            self:ShowScoreUpUI()
            self:UpdateHeroInfo()
            cur_op_data.init_func(self)
            if cur_op_data.btn_cmp then
                cur_op_data.btn_cmp.interactable = true
            end
            self.effect_reset_timer = nil
        end, kResetDuration)
    end)
    self:AddClick(self.content:FindChild("Left"), function ()
        self.effect_animator:SetTrigger(kDragEffectTriggerName)
        local slide_cmp = self.cur_cultivate_op == CSConst.CultivateOperation.Break and self.hero_break_slide_cmp or self.hero_slide_cmp
        slide_cmp:SlideByOffset(-1)
    end)
    self:AddClick(self.content:FindChild("Right"), function ()
        self.effect_animator:SetTrigger(kDragEffectTriggerName)
        local slide_cmp = self.cur_cultivate_op == CSConst.CultivateOperation.Break and self.hero_break_slide_cmp or self.hero_slide_cmp
        slide_cmp:SlideByOffset(1)
    end)
    self.left_attr_item = self.content:FindChild("PrefabList/LeftAttrItem")
    self.right_attr_item = self.content:FindChild("PrefabList/RightAttrItem")
    self.result_attr_item = self.content:FindChild("PrefabList/BreakResultItem")
end

function TrainHeroUI:InitUI()
    if not self.cultivate_hero_id then
        self:Hide()
        return
    end
    self.last_score = ComMgrs.dy_data_mgr:ExGetRoleScore()
    self.last_fight_score = ComMgrs.dy_data_mgr:ExGetFightScore()
    self:InitHeroInfo()
    self:UpdateCultivatePanel(self.cultivate_op)
    self:RegisterEvent(ComMgrs.dy_data_mgr, "UpdateCurrencyEvent", function (_, currency)
        UIFuncs.UpdateCurrencyItemNum(self._item_to_text_list, currency)
        self:UpdateCultivateCost()
    end)
    self:RegisterEvent(self.dy_bag_data, "UpdateBagItemEvent", function ()
        self:UpdateCultivateCost()
    end)
    self.dy_night_club_data:RegisterUpdateHeroEvent("TrainHeroUI", self.UpdateDestinyBottomPanel, self)
end

function TrainHeroUI:InitHeroInfo()
    self.hero_data = SpecMgrs.data_mgr:GetHeroData(self.cultivate_hero_id)
    self.hero_quality_data = SpecMgrs.data_mgr:GetQualityData(self.hero_data.quality)
    UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetQualityData(self.hero_data.quality).ground, self.hero_quality)
    UIFuncs.AssignSpriteByIconID(self.hero_quality_data.grade, self.hero_grade)
    UIFuncs.AssignSpriteByIconID(self.hero_quality_data.grade, self.before_break_grade)
    UIFuncs.AssignSpriteByIconID(self.hero_quality_data.grade, self.after_break_grade)
    self:UpdateHeroInfo()
    self:InitCostItem()
end

function TrainHeroUI:UpdateCultivateCost()
    local cur_op_data = self.cultivate_op_data[self.cur_cultivate_op]
    if cur_op_data.update_cost_func then
        cur_op_data.update_cost_func(self)
    end
end

function TrainHeroUI:InitCostItem()
    UIFuncs.InitItemGo({
        go = self.break_cost_material_item:FindChild("Item"),
        item_id = self.break_cost_item,
        name_go = self.break_cost_material_item:FindChild("Name"),
        change_name_color = true,
        ui = self,
        click_cb = function ()
            SpecMgrs.ui_mgr:ShowItemPreviewUI(self.break_cost_item)
        end,
    })
    UIFuncs.InitItemGo({
        go = self.break_cost_fragment_item:FindChild("Item"),
        item_id = self.hero_data.fragment_id,
        name_go = self.break_cost_fragment_item:FindChild("Name"),
        change_name_color = true,
        ui = self,
        click_cb = function ()
            SpecMgrs.ui_mgr:ShowItemPreviewUI(self.hero_data.fragment_id)
        end,
    })
    UIFuncs.InitItemGo({
        go = self.add_star_fragment_item:FindChild("Item"),
        item_id = self.hero_data.fragment_id,
        name_go = self.add_star_fragment_item:FindChild("Name"),
        change_name_color = true,
        ui = self,
        click_cb = function ()
            SpecMgrs.ui_mgr:ShowItemPreviewUI(self.hero_data.fragment_id)
        end,
    })
end

function TrainHeroUI:UpdateCultivatePanel(cultivate_op)
    if self.cur_cultivate_op == cultivate_op then return end
    if self.cur_cultivate_op then
        self:RemoveAutoDestinyTimer()
        self:ClearHeroCultivateTab()
        self:RemoveAfterBreakUnit()
        local last_cultivate_op_data = self.cultivate_op_data[self.cur_cultivate_op]
        last_cultivate_op_data.btn:FindChild("Select"):SetActive(false)
        last_cultivate_op_data.panel:SetActive(false)
        if self.cur_attr_type then
            self:UpdateCultivateItemList()
            self.is_send_ten_item = false
        end
    end
    self.cur_cultivate_op = cultivate_op
    local cur_cultivate_op_data = self.cultivate_op_data[self.cur_cultivate_op]
    cur_cultivate_op_data.btn:FindChild("Select"):SetActive(true)
    cur_cultivate_op_data.panel:SetActive(true)
    cur_cultivate_op_data.init_func(self)
    self.hero_info:SetActive(self.cur_cultivate_op ~= CSConst.CultivateOperation.Break)
    self:InitHeroModel()
    self:UpdateHeroInfo()
end

function TrainHeroUI:InitHeroModel()
    local is_break_operation = self.cur_cultivate_op == CSConst.CultivateOperation.Break
    local slide_cmp = is_break_operation and self.hero_break_slide_cmp or self.hero_slide_cmp
    local parent_dict = is_break_operation and self.hero_break_model_dict or self.hero_model_dict
    self:RemoveUnitModel()
    slide_cmp:ResetLoopOffset()
    local cur_hero_unit_id = SpecMgrs.data_mgr:GetHeroData(self.cultivate_hero_id).unit_id
    self.hero_unit_dict[kHeroIndex.Cur] = self:AddFullUnit(cur_hero_unit_id, parent_dict[kHeroIndex.Cur])
    slide_cmp:SetDraggable(self.hero_count > 1)
    local pre_hero_unit_id = self.hero_list[math.Repeat(self.cultivate_hero_index - 2, self.hero_count) + 1].unit_id
    self.hero_unit_dict[kHeroIndex.Pre] = self:AddFullUnit(pre_hero_unit_id, parent_dict[kHeroIndex.Pre])
    local next_hero_unit_id = self.hero_list[math.Repeat(self.cultivate_hero_index, self.hero_count) + 1].unit_id
    self.hero_unit_dict[kHeroIndex.Next] = self:AddFullUnit(next_hero_unit_id, parent_dict[kHeroIndex.Next])
end

function TrainHeroUI:RefreshModel(index)
    self:RemoveUnit(self.hero_unit_dict[index])
    local new_unit_id = self.hero_list[math.Repeat(self.cultivate_hero_index + self.move_dir - 1, self.hero_count) + 1].unit_id
    local is_break_operation = self.cur_cultivate_op == CSConst.CultivateOperation.Break
    local parent_dict = is_break_operation and self.hero_break_model_dict or self.hero_model_dict
    self.hero_unit_dict[index] = self:AddFullUnit(new_unit_id, parent_dict[index])
end

function TrainHeroUI:RemoveUnitModel()
    for _, unit in pairs(self.hero_unit_dict) do
        self:RemoveUnit(unit)
    end
    self.hero_unit_dict = {}
end

function TrainHeroUI:UpdateHeroInfo()
    local hero_info = self.dy_night_club_data:GetHeroDataById(self.cultivate_hero_id)
    self.hero_name.text = UIFuncs.GetHeroName(self.cultivate_hero_id)
    for i = 1, self.star_limit do
        self.hero_star_list[i]:FindChild("Active"):SetActive(i <= hero_info.star_lv)
        self.hero_star_list[i]:FindChild("Effect"):SetActive(false)
    end
end

function TrainHeroUI:InitUpgratePanel()
    self:ClearAllAttrItem()
    self.ten_grade_toggle_cmp.isOn = self.is_upgrate_ten == true
    local hero_data = self.dy_night_club_data:GetHeroDataById(self.cultivate_hero_id)
    -- 升级前属性
    self.before_upgrate_lv.text = string.format(UIConst.Text.LEVEL_FORMAT_TEXT, hero_data.level)
    local cur_level_attr_dict = CSFunction.get_hero_level_attr(hero_data.hero_id, hero_data.level, hero_data.break_lv)
    for _, attr_data in ipairs(AttrUtil.ConvertAttrDictToList(cur_level_attr_dict)) do
        local attr_item = self:GetUIObject(self.left_attr_item, self.upgrade_left_attr_panel)
        table.insert(self.attr_item_list, attr_item)
        attr_item:GetComponent("Text").text = UIFuncs.GetAttrStr(attr_data.attr, attr_data.value)
    end

    -- 升级后属性
    local upgrate_lv_limit = CSFunction.get_hero_level_limit(ComMgrs.dy_data_mgr:ExGetRoleLevel())
    self.upgrate_right_attr_panel:SetActive(hero_data.level < upgrate_lv_limit)
    self.upgrade_img:SetActive(hero_data.level < upgrate_lv_limit)
    self.upgrate_cost_panel:SetActive(hero_data.level < upgrate_lv_limit)
    self.upgrate_cost = nil
    if hero_data.level >= upgrate_lv_limit then return end

    local next_level = hero_data.level + (self.is_upgrate_ten and 10 or 1)
    local lv_limit = ComMgrs.dy_data_mgr:ExGetRoleLevel()
    next_level = next_level < upgrate_lv_limit and next_level or upgrate_lv_limit
    self.after_upgrate_lv.text = string.format(UIConst.Text.LEVEL_FORMAT_WITH_COLOR, UIConst.Color.Green1, next_level)
    local next_level_attr_dict = CSFunction.get_hero_level_attr(hero_data.hero_id, next_level, hero_data.break_lv)
    for _, attr_data in ipairs(AttrUtil.ConvertAttrDictToList(next_level_attr_dict)) do
        local attr_item = self:GetUIObject(self.right_attr_item, self.upgrate_right_attr_panel)
        table.insert(self.attr_item_list, attr_item)
        attr_item:GetComponent("Text").text = UIFuncs.GetAttrStr(attr_data.attr, attr_data.value, true)
    end
    -- 升级消耗
    self.upgrate_cost_panel:SetActive(hero_data.level < next_level)
    if hero_data.level < next_level then
        self.upgrate_cost = CSFunction.get_hero_level_cost(hero_data.hero_id, hero_data.level, next_level)[self.upgrade_cost_currency]
        self:UpdateUpgradeCost()
    end
end

function TrainHeroUI:UpdateUpgradeCost()
    if not self.upgrate_cost then return end
    self:SetCostText(self.upgrate_cost_text, self.upgrade_cost_currency, self.upgrate_cost)
end

function TrainHeroUI:InitBreakPanel()
    self:ClearAllAttrItem()
    local hero_data = self.dy_night_club_data:GetHeroDataById(self.cultivate_hero_id)
    local break_lv_list = SpecMgrs.data_mgr:GetHeroBreakLvList()
    local next_break_level = hero_data.break_lv + 1
    local next_break_data = break_lv_list[next_break_level]

    local break_before_name = UIFuncs.GetHeroName(self.cultivate_hero_id)
    self.before_break_name.text = break_before_name
    self.lv_limit:SetActive(hero_data.level < next_break_data.level_limit)
    self.lv_limit_text.text = string.format(UIConst.Text.LEVEL_LIMIT, hero_data.level, next_break_data.level_limit)
    local cur_break_level_attr_dict = CSFunction.get_hero_level_attr(hero_data.hero_id, hero_data.level, hero_data.break_lv)
    self.before_break_lv.text = string.format(UIConst.Text.BREAK_FORMAT, hero_data.break_lv)
    for _, attr_data in ipairs(AttrUtil.ConvertAttrDictToList(cur_break_level_attr_dict)) do
        local attr_item = self:GetUIObject(self.left_attr_item, self.break_left_attr_panel)
        table.insert(self.attr_item_list, attr_item)
        attr_item:GetComponent("Text").text = UIFuncs.GetAttrStr(attr_data.attr, attr_data.value)
    end

    self.break_right_attr_panel:SetActive(next_break_data ~= nil)
    self.break_cost_panel:SetActive(next_break_data ~= nil)
    self.after_break_title.text = next_break_data and UIConst.Text.NEXT_LEVEL_ATTR or UIConst.Text.BREAK_LV_LIMIT
    self.break_cost_dict = nil
    if not next_break_data then
        local own_count = self.dy_bag_data:GetBagItemCount(self.break_cost_item)
        self.break_cost_item_count.text = UIFuncs.GetPerStr(own_count, 0)
        self.break_cost_fragment_item:SetActive(false)
        return
    end

    self.lv_limit:SetActive(hero_data.level < next_break_data.level_limit)
    self.lv_limit_text.text = string.format(UIConst.Text.LEVEL_LIMIT, hero_data.level, next_break_data.level_limit)
    -- 突破后属性
    if not self.after_break_unit then
        self.after_break_unit = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = self.hero_data.unit_id, parent = self.after_break_img, color = Color.New(0.5, 0.5, 0.5, 1)})
        self.after_break_unit:SetPositionByRectName({parent = self.after_break_img, name = "full"})
        self.after_break_unit:StopAllAnimationToCurPos()
    end

    local break_after_name = UIFuncs.GetHeroName(self.cultivate_hero_id, next_break_level)
    self.after_break_name.text = break_after_name
    local unlock_talent_data = SpecMgrs.data_mgr:GetTalentData(self.hero_data.talent[next_break_level])
    local talent_name = string.format(unlock_talent_data.name, next_break_level)
    local talent_desc = UIFuncs.GetHeroTalentDesc(unlock_talent_data, next_break_level)

    self.talent_name.text = string.format(UIConst.Text.UNLOCK_TALENT, talent_name)
    self.talent_desc.text = talent_desc
    local next_break_level_attr_dict = CSFunction.get_hero_level_attr(hero_data.hero_id, hero_data.level, next_break_level)
    self.after_break_lv.text = string.format(UIConst.Text.BREAK_FORMAT_WITH_COLOR, UIConst.Color.Green1, next_break_level)
    -- 突破成功
    self.break_result_before_name.text = break_before_name
    self.break_result_after_name.text = break_after_name
    self.break_result_talent.text = string.format(UIConst.Text.UNLOCK_TALENT, talent_name)
    self.break_result_talent_desc.text = talent_desc
    for _, attr in ipairs(AttrUtil.ConvertAttrDictToList(next_break_level_attr_dict)) do
        local attr_item = self:GetUIObject(self.left_attr_item, self.break_right_attr_panel)
        table.insert(self.attr_item_list, attr_item)
        attr_item:GetComponent("Text").text = UIFuncs.GetAttrStr(attr.attr, attr.value, true)

        local attr_data = SpecMgrs.data_mgr:GetAttributeData(attr.attr)
        local result_attr_item = self:GetUIObject(self.result_attr_item, self.break_info_content)
        table.insert(self.attr_item_list, result_attr_item)
        result_attr_item:FindChild("Text"):GetComponent("Text").text = attr_data.name
        result_attr_item:FindChild("BeforeAttr"):GetComponent("Text").text = UIFuncs.GetAttrValue(attr.attr, cur_break_level_attr_dict[attr_data.id])
        result_attr_item:FindChild("AfterAttr"):GetComponent("Text").text = UIFuncs.GetAttrValue(attr.attr, next_break_level_attr_dict[attr_data.id])
    end
    self.break_info_content_rect.anchoredPosition = Vector2.zero
    -- 突破消耗
    self.break_cost_dict = CSFunction.get_hero_break_cost(hero_data.hero_id, next_break_level)
    self.break_cost_material_item:SetActive(self.break_cost_dict[self.break_cost_item] ~= nil)
    self.break_cost_fragment_item:SetActive(self.break_cost_dict[self.hero_data.fragment_id] ~= nil)
    self:UpdateBreakCost()
end

function TrainHeroUI:UpdateBreakCost()
    if not self.break_cost_dict then return end
    self:SetCostText(self.break_cost, self.break_cost_currency, self.break_cost_dict[self.break_cost_currency])
    if self.break_cost_dict[self.break_cost_item] then
        local own_count = self.dy_bag_data:GetBagItemCount(self.break_cost_item)
        self.break_cost_item_count.text = UIFuncs.GetPerStr(own_count, self.break_cost_dict[self.break_cost_item])
    end
    if self.break_cost_dict[self.hero_data.fragment_id] then
        local own_count = self.dy_bag_data:GetBagItemCount(self.hero_data.fragment_id)
        self.break_cost_fragment_count.text = UIFuncs.GetPerStr(own_count, self.break_cost_dict[self.hero_data.fragment_id])
    end
end

function TrainHeroUI:InitAddStarPanel()
    self:ClearAllAttrItem()
    local hero_data = self.dy_night_club_data:GetHeroDataById(self.cultivate_hero_id)
    -- 升星前属性
    self.before_add_star_desc.text = string.format(UIConst.Text.STAR_DESC, hero_data.star_lv)
    for i = 1, self.star_limit do
        self.before_add_star_panel:FindChild("Star" .. i .. "/Active"):SetActive(hero_data.star_lv >= i)
    end
    local cur_star_attr_dict = CSFunction.get_hero_star_attr(hero_data.hero_id, hero_data.star_lv)
    for _, attr_data in ipairs(AttrUtil.ConvertAttrDictToList(cur_star_attr_dict)) do
        local attr_item = self:GetUIObject(self.left_attr_item, self.star_left_attr_panel)
        table.insert(self.attr_item_list, attr_item)
        attr_item:GetComponent("Text").text = UIFuncs.GetAttrStr(attr_data.attr, attr_data.value)
    end
    -- TODO 神意技能

    local next_star_level = hero_data.star_lv + 1
    self.add_star_right_attr_panel:SetActive(next_star_level <= self.star_limit)
    self.add_star_cost_panel:SetActive(next_star_level <= self.star_limit)
    self.add_star_img:SetActive(next_star_level <= self.star_limit)
    self.add_star_cost_dict = nil
    if next_star_level > self.star_limit then
        local own_count = self.dy_bag_data:GetBagItemCount(self.hero_data.fragment_id)
        self.add_star_fragment_count.text = UIFuncs.GetPerStr(own_count, 0)
        return
    end

    -- 升星后属性
    self.after_add_star_desc.text = string.format(UIConst.Text.STAR_DESC, next_star_level)
    local next_star_attr_dict = CSFunction.get_hero_star_attr(hero_data.hero_id, next_star_level)
    for i = 1, self.star_limit do
        self.after_add_star_panel:FindChild("Star" .. i .. "/Active"):SetActive(next_star_level >= i)
    end
    -- 升星成功
    local name = UIFuncs.GetHeroName(hero_data.hero_id)
    self.add_star_result_before_name.text = string.format(UIConst.Text.HERO_NAME_WITH_STAR, hero_data.star_lv, name)
    self.add_star_result_after_name.text = string.format(UIConst.Text.HERO_NAME_WITH_STAR, next_star_level, name)
    for _, attr in ipairs(AttrUtil.ConvertAttrDictToList(next_star_attr_dict)) do
        local attr_item = self:GetUIObject(self.right_attr_item, self.add_star_right_attr_panel)
        table.insert(self.attr_item_list, attr_item)
        attr_item:GetComponent("Text").text = UIFuncs.GetAttrStr(attr.attr, attr.value, true)

        local attr_data = SpecMgrs.data_mgr:GetAttributeData(attr.attr)
        local result_attr_item = self:GetUIObject(self.result_attr_item, self.star_info_content)
        table.insert(self.attr_item_list, result_attr_item)
        result_attr_item:FindChild("Text"):GetComponent("Text").text = attr_data.name
        result_attr_item:FindChild("BeforeAttr"):GetComponent("Text").text = UIFuncs.GetAttrValue(attr.attr, cur_star_attr_dict[attr_data.id])
        result_attr_item:FindChild("AfterAttr"):GetComponent("Text").text = UIFuncs.GetAttrValue(attr.attr, next_star_attr_dict[attr_data.id])
    end
    -- TODO 神意技能 self.add_star_god_spell
    self.add_star_info_rect.anchoredPosition = Vector2.zero

    self.add_star_cost_dict = CSFunction.get_hero_star_cost(hero_data.hero_id, next_star_level)
    self.add_star_fragment_item:SetActive(self.add_star_cost_dict[self.hero_data.fragment_id] ~= nil)
    self:UpdateAddStarCost()
end

function TrainHeroUI:UpdateAddStarCost()
    if not self.add_star_cost_dict then return end
    self:SetCostText(self.add_star_cost, self.add_star_cost_currency, self.add_star_cost_dict[self.add_star_cost_currency])
    if self.add_star_cost_dict[self.hero_data.fragment_id] then
        local own_count = self.dy_bag_data:GetBagItemCount(self.hero_data.fragment_id)
        self.add_star_fragment_count.text = UIFuncs.GetPerStr(own_count, self.add_star_cost_dict[self.hero_data.fragment_id])
    end
end

function TrainHeroUI:InitDestinyPanel()
    self:ClearAllAttrItem()
    self.auto_destiny_toggle_cmp.isOn = self.auto_destiny == true
    local hero_data = self.dy_night_club_data:GetHeroDataById(self.cultivate_hero_id)
    self.cur_destiny_level = hero_data.destiny_lv

    self.before_destiny_desc.text = string.format(UIConst.Text.DESTINY_DESC, hero_data.destiny_lv)
    local cur_destiny_attr_dict = CSFunction.get_hero_destiny_attr(hero_data.hero_id, hero_data.destiny_lv)
    for _, attr_data in ipairs(AttrUtil.ConvertAttrDictToList(cur_destiny_attr_dict)) do
        local attr_item = self:GetUIObject(self.left_attr_item, self.destiny_left_attr_panel)
        table.insert(self.attr_item_list, attr_item)
        attr_item:GetComponent("Text").text = UIFuncs.GetAttrStr(attr_data.attr, attr_data.value)
    end
    for _, spell_id in ipairs(self.hero_data.spell) do
        local spell_data = SpecMgrs.data_mgr:GetSpellData(spell_id)
        if spell_data.spell_type == CSConst.SpellType.Low or spell_data.spell_type == CSConst.SpellType.High then
            local attr_item = self:GetUIObject(self.left_attr_item, self.destiny_left_attr_panel)
            table.insert(self.attr_item_list, attr_item)
            attr_item:GetComponent("Text").text = string.format(UIConst.Text.SPELL_LEVEL_DESC, spell_data.name, hero_data.destiny_lv)
        end
    end

    local next_destiny_level = hero_data.destiny_lv + 1
    local next_destiny_data = SpecMgrs.data_mgr:GetHeroDestinyData(next_destiny_level)
    self:UpdateDestinyBottomPanel()

    self.destiny_right_attr_panel:SetActive(next_destiny_data ~= nil)
    if not next_destiny_data then return end

    self.after_destiny_desc.text = string.format(UIConst.Text.DESTINY_DESC, next_destiny_level)
    local next_destiny_attr_dict = CSFunction.get_hero_destiny_attr(hero_data.hero_id, next_destiny_level)
    for _, attr_data in ipairs(AttrUtil.ConvertAttrDictToList(next_destiny_attr_dict)) do
        local attr_item = self:GetUIObject(self.right_attr_item, self.destiny_right_attr_panel)
        table.insert(self.attr_item_list, attr_item)
        attr_item:GetComponent("Text").text = UIFuncs.GetAttrStr(attr_data.attr, attr_data.value)
    end

    self.destiny_result_before_atk.text = string.format(UIConst.Text.ADD_PERCENT, cur_destiny_attr_dict.att_pct)
    self.destiny_result_before_hp.text = string.format(UIConst.Text.ADD_PERCENT, cur_destiny_attr_dict.max_hp_pct)
    self.destiny_result_before_def.text = string.format(UIConst.Text.ADD_PERCENT, cur_destiny_attr_dict.def_pct)

    self.destiny_result_after_atk.text = string.format(UIConst.Text.ADD_PERCENT, next_destiny_attr_dict.att_pct)
    self.destiny_result_after_hp.text = string.format(UIConst.Text.ADD_PERCENT, next_destiny_attr_dict.max_hp_pct)
    self.destiny_result_after_def.text = string.format(UIConst.Text.ADD_PERCENT, next_destiny_attr_dict.def_pct)
    self.destiny_info_rect.anchoredPosition = Vector2.zero

    self.destiny_result_low_spell_panel:SetActive(false)
    self.destiny_result_high_spell_panel:SetActive(false)
    for _, spell_id in ipairs(self.hero_data.spell) do
        local spell_data = SpecMgrs.data_mgr:GetSpellData(spell_id)
        if spell_data.spell_type == CSConst.SpellType.Low or spell_data.spell_type == CSConst.SpellType.High then
            local attr_item = self:GetUIObject(self.right_attr_item, self.destiny_right_attr_panel)
            table.insert(self.attr_item_list, attr_item)
            attr_item:GetComponent("Text").text = string.format(UIConst.Text.SPELL_LEVEL_DESC_WITH_COLOR, spell_data.name, UIConst.Color.Green1, next_destiny_level)
        end
        if spell_data.spell_type == CSConst.SpellType.Low then
            self.destiny_result_low_spell_panel:SetActive(true)
            self.destiny_result_low_spell_name.text = spell_data.name
            self.destiny_result_before_low_spell_lv.text = string.format(UIConst.Text.LV_TEXT, hero_data.destiny_lv)
            self.destiny_result_after_low_spell_lv.text = string.format(UIConst.Text.LV_TEXT, next_destiny_level)
        elseif spell_data.spell_type == CSConst.SpellType.High then
            self.destiny_result_high_spell_panel:SetActive(true)
            self.destiny_result_high_spell_name.text = spell_data.name
            self.destiny_result_before_high_spell_lv.text = string.format(UIConst.Text.LV_TEXT, hero_data.destiny_lv)
            self.destiny_result_after_high_spell_lv.text = string.format(UIConst.Text.LV_TEXT, next_destiny_level)
        end
    end
    self.destiny_result_lv.text = string.format(UIConst.Text.DESTINY_DESC, next_destiny_level)
end

function TrainHeroUI:UpdateDestinyBottomPanel()
    if self.cur_cultivate_op ~= CSConst.CultivateOperation.Destiny then return end
    local hero_data = self.dy_night_club_data:GetHeroDataById(self.cultivate_hero_id)
    local cur_destiny_data = SpecMgrs.data_mgr:GetHeroDestinyData(hero_data.destiny_lv)
    local next_destiny_data = SpecMgrs.data_mgr:GetHeroDestinyData(hero_data.destiny_lv + 1)
    self.destiny_item_btn_cmp.interactable = next_destiny_data ~= nil
    self.destiny_item_disable:SetActive(next_destiny_data == nil)
    if not next_destiny_data then
        self.cur_destiny_value.text = string.format(UIConst.Text.DESTINY_PER_VALUE, cur_destiny_data.exp_limit, cur_destiny_data.exp_limit)
        self.destiny_bar_value.fillAmount = 1
    else
        self.cur_destiny_value.text = string.format(UIConst.Text.DESTINY_PER_VALUE, hero_data.destiny_exp, cur_destiny_data.exp_limit)
        self.destiny_bar_value.fillAmount = hero_data.destiny_exp / cur_destiny_data.exp_limit
    end
    self:UpdateDestinyCost()
    self.destiny_cost.text = cur_destiny_data.cost_num
    local destiny_range_level = 0
    for i, range in ipairs(cur_destiny_data.upgrade_range) do
        if range > cur_destiny_data.exp_limit then break end
        if hero_data.destiny_exp < range then
            destiny_range_level = i - 1
            break
        end
    end
    self.probability:SetActive(destiny_range_level > 0)
    if destiny_range_level > 0 then
        self.probability_text.text = string.format(UIConst.Text.DESTINY_PROBABILITY, cur_destiny_data.rate_color[destiny_range_level], cur_destiny_data.rate_desc[destiny_range_level])
    end
end

function TrainHeroUI:UpdateDestinyCost()
    self.destiny_item_count.text = self.dy_bag_data:GetBagItemCount(self.destiny_cost_item)
end

function TrainHeroUI:InitCultivateHeroPanel()
    self.ten_toggle_cmp.isOn = self.is_send_ten_item == true
    local hero_info = self.dy_night_club_data:GetHeroDataById(self.cultivate_hero_id)
    self.cultivate_total_attr_text.text = string.format(UIConst.Text.CULTIVATE_TOTAL_ATTR, math.floor(AttrUtil.CalcTotalAttr(hero_info.attr_dict)))
    for _, attr in pairs(CSConst.RoleAttrName) do
        local attr_effect_data = self.attr_effect_text_dict[attr]
        local attr_data = SpecMgrs.data_mgr:GetAttributeData(attr)
        attr_effect_data.attr_text.text = string.format(UIConst.Text.KEY_VALUE, attr_data.name, math.floor(hero_info.attr_dict[attr] or 0))
        attr_effect_data.effect:SetActive(false)
    end

    for _, attr in pairs(kAttrItemDict) do
        local attr_tab_btn = self.attr_tag_btn_dict[attr]
        local have_item_flag = false
        for _, item_data in ipairs(SpecMgrs.data_mgr:GetAttrItemListWithType(attr)) do
            if self.dy_bag_data:GetBagItemCount(item_data.id) > 0 then have_item_flag = true end
        end
        attr_tab_btn:FindChild("RedPoint"):SetActive(have_item_flag)
    end

    self:UpdateCultivateItemList(self.cur_attr_type or kAttrItemDict.Business)
end

function TrainHeroUI:UpdateCultivateItemList(attr_type)
    if self.cur_attr_type == attr_type then return end
    self:ClearCultivateAttrItem()
    self:ClearHeroCultivateTab()
    self.cur_attr_type = attr_type
    if not self.cur_attr_type then return end
    self.attr_tag_btn_dict[self.cur_attr_type]:FindChild("Unactive"):SetActive(false)

    local attr_data = SpecMgrs.data_mgr:GetAttributeData(attr_type)
    for _, item_data in ipairs(SpecMgrs.data_mgr:GetAttrItemListWithType(attr_type)) do
        local cultivate_item = self:GetUIObject(self.cultivate_item, self.cultivate_item_list)
        table.insert(self.cultivate_attr_item_list, cultivate_item)
        cultivate_item:FindChild("Name"):GetComponent("Text").text = item_data.name
        local item_icon = cultivate_item:FindChild("IconBg/Image/Icon")
        UIFuncs.AssignSpriteByIconID(item_data.icon, item_icon:GetComponent("Image"))
        self:AddClick(item_icon, function ()
            self:SendCultivateHero(cultivate_item, item_data.id)
        end)
        local effect_str
        if attr_data then
            effect_str = string.format(UIConst.Text.HERO_ATTR_ADD_FORMAT, attr_data.name, item_data.random_attr_value_list[1])
        else
            effect_str = string.format(UIConst.Text.RANDOM_ATTR_ADD_FORMAT, item_data.random_attr_value_list[1])
        end
        cultivate_item:FindChild("Effect/Text"):GetComponent("Text").text = effect_str
        cultivate_item:FindChild("Count"):GetComponent("Text").text = self.dy_bag_data:GetBagItemCount(item_data.id)
    end
end

function TrainHeroUI:ClearHeroCultivateTab()
    if self.cur_attr_type then
        self.attr_tag_btn_dict[self.cur_attr_type]:FindChild("Unactive"):SetActive(true)
        self.cur_attr_type = nil
    end
end

function TrainHeroUI:ShowCultivateEffect()
    self:PlayUISound(self.hero_upgrade_sound)
    local cur_op_data = self.cultivate_op_data[self.cur_cultivate_op]
    if cur_op_data.trigger_name then
        self.effect_animator:SetTrigger(cur_op_data.trigger_name)
    end
    if cur_op_data.effect_time then
        self.cultivate_effect_timer = self:AddTimer(function ()
            self:UpdateHeroInfo()
            if cur_op_data.btn_cmp then
                cur_op_data.btn_cmp.interactable = true
            end
            cur_op_data.init_func(self)
            self:ShowScoreUpUI()
            self.effect_animator:SetTrigger(kCultivateEffectTriggerName.Reset)
            self.cultivate_effect_timer = nil
        end, cur_op_data.effect_time)
    end
end

function TrainHeroUI:ShowScoreUpUI()
    SpecMgrs.ui_mgr:ShowScoreUpUI(self.last_score, self.last_fight_score)
    self.last_score = ComMgrs.dy_data_mgr:ExGetRoleScore()
    self.last_fight_score = ComMgrs.dy_data_mgr:ExGetFightScore()
end

function TrainHeroUI:SetCostText(text_cmp, currency_id, cost_count)
    local cost_text = string.format(UIConst.Text.COUNT, UIFuncs.AddCountUnit(cost_count))
    local cost_color = self.dy_bag_data:GetBagItemCount(currency_id) < cost_count and UIConst.Color.Red or UIConst.Color.White
    text_cmp.text = string.format(UIConst.Text.SIMPLE_COLOR, cost_color, cost_text)
end

-- msg

function TrainHeroUI:CheckUpgradeCondition()
    local upgrade_lv_limit = CSFunction.get_hero_level_limit(ComMgrs.dy_data_mgr:ExGetRoleLevel())
    if self.dy_night_club_data:GetHeroDataById(self.cultivate_hero_id).level >= upgrade_lv_limit then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.UPGRADE_LV_LIMIT)
        self.hero_upgrade_btn_cmp.interactable = true
        return false
    end
    return UIFuncs.CheckItemCount(self.upgrade_cost_currency, self.upgrate_cost, true)
end

function TrainHeroUI:SendHeroUpgrate()
    if self:CheckUpgradeCondition() then
        ComMgrs.dy_data_mgr:ExSetIgnoreScoreUpFlag(true)
        SpecMgrs.msg_mgr:SendUpgradeHeroLevel({hero_id = self.cultivate_hero_id, ten_level = self.is_upgrate_ten}, function (resp)
            ComMgrs.dy_data_mgr:ExSetIgnoreScoreUpFlag(false)
            if resp.errcode ~= 0 then
                SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.UPGRATE_FAILED)
            else
                self:ShowCultivateEffect()
            end
            self.hero_upgrade_btn_cmp.interactable = true
        end)
    else
        self.hero_upgrade_btn_cmp.interactable = true
    end
end

function TrainHeroUI:CheckHeroBreakCondition()
    local hero_info = self.dy_night_club_data:GetHeroDataById(self.cultivate_hero_id)
    local next_break_level_data = SpecMgrs.data_mgr:GetHeroBreakLvList()[hero_info.break_lv + 1]
    if not next_break_level_data then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.BREAK_LV_LIMIT)
        return false
    end
    if hero_info.level < next_break_level_data.level_limit then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.BREAK_FAILED_OF_LEVEL)
        return false
    end
    if not UIFuncs.CheckItemCount(self.break_cost_currency, self.break_cost_dict[self.break_cost_currency], true) then return false end
    if not UIFuncs.CheckItemCount(self.hero_data.fragment_id, self.break_cost_dict[self.hero_data.fragment_id], true) then return false end
    if not UIFuncs.CheckItemCount(self.break_cost_item, self.break_cost_dict[self.break_cost_item], true) then return false end
    return true
end

function TrainHeroUI:SendHeroBreakThrough()
    if self:CheckHeroBreakCondition() then
        ComMgrs.dy_data_mgr:ExSetIgnoreScoreUpFlag(true)
        SpecMgrs.msg_mgr:SendHeroBreakThrough({hero_id = self.cultivate_hero_id}, function (resp)
            ComMgrs.dy_data_mgr:ExSetIgnoreScoreUpFlag(false)
            if resp.errcode ~= 0 then
                SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.BREAK_FAILED)
            else
                self:ShowCultivateEffect()
            end
            self.hero_break_btn_cmp.interactable = true
        end)
    else
        self.hero_break_btn_cmp.interactable = true
    end
end

function TrainHeroUI:CheckHeroAddStarCondition()
    if self.dy_night_club_data:GetHeroDataById(self.cultivate_hero_id).star_lv >= self.star_limit then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.STAR_LV_LIMIT)
        return false
    end
    if not UIFuncs.CheckItemCount(self.add_star_cost_currency, self.add_star_cost_dict[self.add_star_cost_currency], true) then return false end
    if not UIFuncs.CheckItemCount(self.hero_data.fragment_id, self.add_star_cost_dict[self.hero_data.fragment_id], true) then return false end
    return true
end

function TrainHeroUI:SendHeroAddStar()
    if self:CheckHeroAddStarCondition() then
        ComMgrs.dy_data_mgr:ExSetIgnoreScoreUpFlag(true)
        SpecMgrs.msg_mgr:SendUpgradeHeroStarLevel({hero_id = self.cultivate_hero_id}, function (resp)
            ComMgrs.dy_data_mgr:ExSetIgnoreScoreUpFlag(false)
            if resp.errcode ~= 0 then
                SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.ADD_STAR_FAILED)
            else
                local cur_star_lv = self.dy_night_club_data:GetHeroDataById(self.cultivate_hero_id).star_lv
                self.hero_star_list[cur_star_lv]:FindChild("Effect"):SetActive(true)
                self:ShowCultivateEffect()
            end
            self.hero_add_star_btn_cmp.interactable = true
        end)
    else
        self.hero_add_star_btn_cmp.interactable = true
    end
end

function TrainHeroUI:SendAddDestiny(item_cost)
    local destiny_lv_list = SpecMgrs.data_mgr:GetHeroDestinyLvList()
    if self.dy_night_club_data:GetHeroDataById(self.cultivate_hero_id).star_lv >= #destiny_lv_list then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.DESTINY_LV_LIMIT)
        return
    end
    if not UIFuncs.CheckItemCount(self.destiny_cost_item, item_cost, true) then
        self:RemoveAutoDestinyTimer()
    else
        ComMgrs.dy_data_mgr:ExSetIgnoreScoreUpFlag(true)
        SpecMgrs.msg_mgr:SendUpgradeHeroDestinyLevel({hero_id = self.cultivate_hero_id}, function (resp)
            ComMgrs.dy_data_mgr:ExSetIgnoreScoreUpFlag(false)
            if resp.errcode ~= 0 then
                SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.DESTINY_ITEM_USE_FAILED)
                self:RemoveAutoDestinyTimer()
            else
                self.add_destiny_effect:SetActive(true)
                SpecMgrs.ui_mgr:ShowHud({hud_type = UnitConst.UNITHUD_TYPE.Cure, value = item_cost, point_go = self.hero_hud_point})
                local hero_data = self.dy_night_club_data:GetHeroDataById(self.cultivate_hero_id)
                if not self.auto_destiny_timer or hero_data.destiny_lv > self.cur_destiny_level then
                    self:RemoveCloseDestinyEffectTimer()
                    self.remove_destiny_click_effect_timer = self:AddTimer(function ()
                        self.add_destiny_effect:SetActive(false)
                        self.remove_destiny_click_effect_timer = nil
                    end, kDestinyClickAnimDuration)
                end
                if hero_data.destiny_lv > self.cur_destiny_level then
                    self.destiny_item_btn_cmp.interactable = false
                    self:ShowCultivateEffect()
                    self:RemoveAutoDestinyTimer()
                end
            end
        end)
    end
end

function TrainHeroUI:RemoveCloseDestinyEffectTimer()
    if self.remove_destiny_click_effect_timer then
        self:RemoveTimer(self.remove_destiny_click_effect_timer)
        self.remove_destiny_click_effect_timer = nil
    end
end

function TrainHeroUI:SendCultivateHero(attr_item, item_id)
    if not UIFuncs.CheckItemCount(item_id, 1, true) then return end
    local count = math.min(self.is_send_ten_item and 10 or 1, self.dy_bag_data:GetBagItemCount(item_id))
    local last_attr_dict = self.dy_night_club_data:GetHeroDataById(self.cultivate_hero_id).attr_dict
    ComMgrs.dy_data_mgr:ExSetIgnoreScoreUpFlag(true)
    SpecMgrs.msg_mgr:SendCultivateHero({hero_id = self.cultivate_hero_id, item_id = item_id, item_count = count}, function (resp)
        ComMgrs.dy_data_mgr:ExSetIgnoreScoreUpFlag(false)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.CULTIVATE_HERO_FAILED)
        else
            attr_item:FindChild("Count"):GetComponent("Text").text = self.dy_bag_data:GetBagItemCount(item_id)
            UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetItemData(item_id).icon, self.hero_attr_effect)
            self.cultivate_hero_effect_timer = self:AddTimer(function ()
                self.cultivate_effect_item:SetActive(false)
                self.cultivate_hero_effect_timer = nil
                local total_attr = 0
                local attr_dict = self.dy_night_club_data:GetHeroDataById(self.cultivate_hero_id).attr_dict
                for _, attr in pairs(CSConst.RoleAttrName) do
                    local add_value = attr_dict[attr] - last_attr_dict[attr]
                    if add_value > 0 then
                        local effect_data = self.attr_effect_text_dict[attr]
                        effect_data.effect_text.text = math.floor(add_value)
                        effect_data.effect:SetActive(true)
                        local attr_data = SpecMgrs.data_mgr:GetAttributeData(attr)
                        self:AddCountEffect(attr_data.name, effect_data.attr, effect_data.attr_text, last_attr_dict[attr], attr_dict[attr])
                    end
                    total_attr = total_attr + attr_dict[attr]
                end
                if total_attr > 0 then
                    self:AddCountEffect(UIConst.Text.TOTAL_ATTR, self.cultivate_total_attr, self.cultivate_total_attr_text, AttrUtil.CalcTotalAttr(last_attr_dict), total_attr)
                end
            end, self.cultivate_effect_anim_cmp:GetDurationTime())
            self:ShowCultivateEffect()
        end
    end)
end

function TrainHeroUI:AddCountEffect(attr_name, text_go, text_cmp, last_value, cur_value)
    local add_value = cur_value - last_value
    local count = kCountAnimDuration / kCountAnimInterval
    local temp_value = last_value
    self:AddDynamicUI(text_go, function ()
        temp_value = math.min(temp_value + add_value / count, cur_value)
        text_cmp.text = string.format(UIConst.Text.KEY_VALUE, attr_name, math.floor(temp_value))
    end, kCountAnimInterval, count)
end

function TrainHeroUI:RemoveAutoDestinyTimer()
    if self.auto_destiny_timer then
        SpecMgrs.sound_mgr:DestroySound(self.auto_destiny_sound)
        self.auto_destiny_sound = nil
        self:RemoveCloseDestinyEffectTimer()
        self.add_destiny_effect:SetActive(false)
        self:RemoveTimer(self.auto_destiny_timer)
        self.auto_destiny_timer = nil
    end
end

function TrainHeroUI:ClearCultivateAttrItem()
    for _, item in ipairs(self.cultivate_attr_item_list) do
        self:DelUIObject(item)
    end
    self.cultivate_attr_item_list = {}
end

function TrainHeroUI:ClearAllAttrItem()
    for _, item in ipairs(self.attr_item_list) do
        self:DelUIObject(item)
    end
    self.attr_item_list = {}
end

function TrainHeroUI:RemoveAfterBreakUnit()
    if self.after_break_unit then
        ComMgrs.unit_mgr:DestroyUnit(self.after_break_unit)
        self.after_break_unit = nil
    end
end

function TrainHeroUI:RemoveCultivateHeroEffect()
    for _, attr in pairs(CSConst.RoleAttrName) do
        local attr_effect_data = self.attr_effect_text_dict[attr]
        self:RemoveDynamicUI(attr_effect_data.attr)
        attr_effect_data.effect:SetActive(false)
    end
end

function TrainHeroUI:ClearEffectResetTimer()
    if self.effect_reset_timer then
        self:RemoveTimer(self.effect_reset_timer)
        self.effect_reset_timer = nil
        self:ShowScoreUpUI()
    end
end

function TrainHeroUI:Close()
    local last_cultivate_op_data = self.cultivate_op_data[self.cur_cultivate_op]
    last_cultivate_op_data.btn:FindChild("Select"):SetActive(false)
    last_cultivate_op_data.panel:SetActive(false)
    if self.hero_model then
        ComMgrs.unit_mgr:DestroyUnit(self.hero_model)
        self.hero_model = nil
    end
    if self.before_break_model then
        ComMgrs.unit_mgr:DestroyUnit(self.before_break_model)
        self.before_break_model = nil
    end
    if self.after_break_model then
        ComMgrs.unit_mgr:DestroyUnit(self.after_break_model)
        self.after_break_model = nil
    end
    self:RemoveCultivateHeroEffect()
    self:ClearCultivateAttrItem()
    if self.close_cb then self.close_cb(self.cultivate_hero_index) end
    self.cultivate_hero_index = nil
    self.cur_cultivate_op = nil
    self.cultivate_hero_id = nil
    self.is_upgrate_ten = nil
    self.auto_destiny = nil
    self.cur_attr_type = nil
end

return TrainHeroUI