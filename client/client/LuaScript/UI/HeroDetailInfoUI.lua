local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local UnitConst = require("Unit.UnitConst")
local CSFunction = require("CSCommon.CSFunction")

local HeroDetailInfoUI = class("UI.HeroDetailInfoUI", UIBase)

local kBottomPos = Vector2.New(0, -1920)
local kTopPos = Vector2.New(0, 0)
local kExpandTime = 0.2

function HeroDetailInfoUI:DoInit()
    HeroDetailInfoUI.super.DoInit(self)
    self.prefab_path = "UI/Common/HeroDetailInfoUI"
    self.dy_night_club_data = ComMgrs.dy_data_mgr.night_club_data
    self.expanded = false
    self.blend_time = 0
    self.info_text_dict = {}
    self.star_go_list = {}
    self.star_limit = SpecMgrs.data_mgr:GetParamData("hero_star_lv_limit").f_value
    self.max_lineup = #(SpecMgrs.data_mgr:GetAllLineupUnlockData())
end

function HeroDetailInfoUI:OnGoLoadedOk(res_go)
    HeroDetailInfoUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function HeroDetailInfoUI:Show(hero_list, select_index, close_cb, is_hide_change_btn)
    self.select_index = select_index
    self.hero_list = {}
    for _, hero_info in ipairs(hero_list) do
        table.insert(self.hero_list, hero_info)
    end
    self.close_cb = close_cb
    self.is_hide_change_btn = is_hide_change_btn
    if self.is_res_ok then
        self:InitUI()
    end
    HeroDetailInfoUI.super.Show(self)
end

function HeroDetailInfoUI:GetHeroList()
    local hero_data_list = {}
    for i = 1, self.max_lineup do
        local hero_id = ComMgrs.dy_data_mgr.night_club_data:GetLineupHeroId(i)
        if hero_id then
            local hero_data = SpecMgrs.data_mgr:GetHeroData(hero_id)
            table.insert(hero_data_list, hero_data)
        end
    end
    return hero_data_list
end

function HeroDetailInfoUI:Hide()
    self:_RemoveRedPoints()
    self.hero_list = nil
    self.dy_night_club_data:UnregisterUpdateHeroEvent("HeroDetailInfoUI")
    HeroDetailInfoUI.super.Hide(self)
end

function HeroDetailInfoUI:InitRes()
    self.content = self.main_panel:FindChild("Content")
    self.content_pos_cmp = self.content:GetComponent("UITweenPosition")
    UIFuncs.InitTopBar(self, self.content:FindChild("TopBar"), "HeroDetailInfoUI", function ()
        self:ExpandDetailInfoPanel()
    end)

    self.detail_info_panel = self.content:FindChild("DetailInfoPanel")
        --detail hero
    local detail_hero_img = self.detail_info_panel:FindChild("DetailHeroImg")
    local cur_hero_panel = detail_hero_img:FindChild("CurHero")
    self.cur_hero_tag1 = cur_hero_panel:FindChild("Tag1")
    self.cur_hero_tag2 = cur_hero_panel:FindChild("Tag2")
    self.cur_hero_icon = cur_hero_panel:FindChild("HeroIcon")
    self.cur_hero_name = cur_hero_panel:FindChild("NameBg/Name"):GetComponent("Text")
    self.cur_hero_lv = cur_hero_panel:FindChild("LvBg/Lv"):GetComponent("Text")
    self.cur_hero_grade = cur_hero_panel:FindChild("Grade"):GetComponent("Image")
    self.cur_hero_star_list = cur_hero_panel:FindChild("StarList")
    self:AddClick(detail_hero_img:FindChild("PreBtn"), function ()
        if #self.hero_list == 1 then return end
        self.select_index = math.Repeat(self.select_index - 2, #self.hero_list) + 1
        self:UpdateHeroDetailInfo()
    end)
    self:AddClick(detail_hero_img:FindChild("NextBtn"), function ()
        if #self.hero_list == 1 then return end
        self.select_index = math.Repeat(self.select_index, #self.hero_list) + 1
        self:UpdateHeroDetailInfo()
    end)
    self.detail_info_panel:FindChild("InfoPanel/Image/Text"):GetComponent("Text").text = UIConst.Text.DETAIL
    self:AddClick(self.detail_info_panel:FindChild("InfoPanel/Image"), function ()
        self:ExpandDetailInfoPanel()
    end)
    local detail_info_content = self.detail_info_panel:FindChild("InfoPanel/Viewport/Content")
    self.detail_info_rect_cmp = detail_info_content:GetComponent("RectTransform")
    local base_content = detail_info_content:FindChild("BasePanel/BaseContent")
    detail_info_content:FindChild("BasePanel/Header/Title"):GetComponent("Text").text = UIConst.Text.BASE_ATTR_TEXT
    self.lv = base_content:FindChild("Lv"):GetComponent("Text")
    self.atk = base_content:FindChild("Atk"):GetComponent("Text")
    self.hp = base_content:FindChild("Hp"):GetComponent("Text")
    self.def = base_content:FindChild("Def"):GetComponent("Text")
    self.business = base_content:FindChild("Business"):GetComponent("Text")
    self.management = base_content:FindChild("Technology"):GetComponent("Text")
    self.renown = base_content:FindChild("Renown"):GetComponent("Text")
    self.battle = base_content:FindChild("Battle"):GetComponent("Text")
    self.upgrate_btn = base_content:FindChild("BtnPanel/UpgrateBtn")
    self.upgrate_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.UPGRADE
    self.upgrate_btn_cmp = self.upgrate_btn:GetComponent("Button")
    self.upgrate_disable = self.upgrate_btn:FindChild("Disable")
    self:AddClick(self.upgrate_btn, function ()
        self:ShowHeroCultivateUI(CSConst.CultivateOperation.Upgrade)
    end)
    self.break_btn = base_content:FindChild("BtnPanel/BreakBtn")
    self.break_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.BREAK
    self.break_btn_cmp = self.break_btn:GetComponent("Button")
    self.break_disable = self.break_btn:FindChild("Disable")
    self:AddClick(self.break_btn, function ()
        self:ShowHeroCultivateUI(CSConst.CultivateOperation.Break)
    end)
    self.cultivate_btn = base_content:FindChild("BtnPanel/CultivateBtn")
    self.cultivate_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CULTIVATE
    self.cultivate_btn_red_point = self.cultivate_btn:FindChild("RedPoint")
    self.cultivate_btn_cmp = self.cultivate_btn:GetComponent("Button")
    self.cultivate_disable = self.cultivate_btn:FindChild("Disable")
    self:AddClick(self.cultivate_btn, function ()
        self:ShowHeroCultivateUI(CSConst.CultivateOperation.Cultivate)
    end)

    self.star_panel = detail_info_content:FindChild("StarPanel")
    self.star_panel:FindChild("Header/Title"):GetComponent("Text").text = UIConst.Text.STAR_LEVLE
    local star_content = self.star_panel:FindChild("Content")
    for i = 1, self.star_limit do
        self.star_go_list[i] = star_content:FindChild("Star" .. i .."/Active")
    end
    self.star_btn = star_content:FindChild("StarBtn")
    self.star_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ADD_STAR
    self.star_btn_cmp = self.star_btn:GetComponent("Button")
    self.star_disable = self.star_btn:FindChild("Disable")
    self:AddClick(self.star_btn, function ()
        self:ShowHeroCultivateUI(CSConst.CultivateOperation.AddStar)
    end)

    self.star_attr_panel = detail_info_content:FindChild("StarAttrPanel")
    self.star_attr_panel:FindChild("Header/Title"):GetComponent("Text").text = UIConst.Text.STAR_ATTR_TEXT
    local star_attr_content = self.star_attr_panel:FindChild("Content")
    self.star_lv = star_attr_content:FindChild("Lv"):GetComponent("Text")
    self.star_atk = star_attr_content:FindChild("Atk"):GetComponent("Text")
    self.star_hp = star_attr_content:FindChild("Hp"):GetComponent("Text")
    self.star_def = star_attr_content:FindChild("Def"):GetComponent("Text")
    self.star_business = star_attr_content:FindChild("Business"):GetComponent("Text")
    self.star_management = star_attr_content:FindChild("Technology"):GetComponent("Text")
    self.star_renown = star_attr_content:FindChild("Renown"):GetComponent("Text")
    self.star_battle = star_attr_content:FindChild("Battle"):GetComponent("Text")

    self.skill_panel = detail_info_content:FindChild("SkillPanel")
    self.skill_panel:FindChild("Header/Title"):GetComponent("Text").text = UIConst.Text.SPELL_TEXT
    self.skill_content = self.skill_panel:FindChild("SkillContent")
    self.destiny_panel = self.skill_panel:FindChild("ExtraContent/DestinyPanel")
    self.destiny_lv = self.destiny_panel:FindChild("DestinyLv"):GetComponent("Text")
    self.destiny_panel:FindChild("DestinyTips"):GetComponent("Text").text = UIConst.Text.DESTINY_TIPS
    self.destiny_btn = self.destiny_panel:FindChild("DestinyBtn")
    self.destiny_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DESTINY
    self.destiny_btn_cmp = self.destiny_btn:GetComponent("Button")
    self.destiny_disable = self.destiny_btn:FindChild("Disable")
    self:AddClick(self.destiny_btn, function ()
        self:ShowHeroCultivateUI(CSConst.CultivateOperation.Destiny)
    end)

    self.gift_panel = detail_info_content:FindChild("GiftPanel")
    self.gift_panel:FindChild("Header/Title"):GetComponent("Text").text = UIConst.Text.GIFT_TEXT
    self.gift_content = self.gift_panel:FindChild("GiftContent")

    self.fate_panel = detail_info_content:FindChild("FatePanel")
    self.fate_panel:FindChild("Header/Title"):GetComponent("Text").text = UIConst.Text.FATE_TEXT
    self.fate_content = self.fate_panel:FindChild("FateContent")

    self.desc_panel = detail_info_content:FindChild("DescPanel")
    self.desc_panel:FindChild("Header/Title"):GetComponent("Text").text = UIConst.Text.HERO_DESC
    self.desc_text = self.desc_panel:FindChild("Desc/Text"):GetComponent("Text")

    self.info_text_item = self.main_panel:FindChild("PrefabList/TextItem")

    self.bottom_bar = self.content:FindChild("BottomBar")
    self.change_hero_btn_go = self.main_panel:FindChild("Content/BottomBar/ChangeHeroBtn")
    self.change_hero_btn_go:FindChild("Text"):GetComponent("Text").text = UIConst.Text.REPLACE_TEXT
    self:AddClick(self.change_hero_btn_go, function ()
        self:ChangeHeroBtnOnClick()
    end)
end

function HeroDetailInfoUI:ChangeHeroBtnOnClick()
    local hero_id = self.hero_list[self.select_index].id
    local lineup_id = ComMgrs.dy_data_mgr.night_club_data:GetHeroLineupId(hero_id)
    SpecMgrs.ui_mgr:ShowUI("ChangeHeroUI", {lineup_id = lineup_id})
end

function HeroDetailInfoUI:InitUI()
    self:UpdateHeroDetailInfo()
    self.bottom_bar:SetActive(self.is_hide_change_btn ~= true)
    self:ExpandDetailInfoPanel()
    self:RegisterEvent(ComMgrs.dy_data_mgr, "UpdateCurrencyEvent", function (_, currency)
        UIFuncs.UpdateCurrencyItemNum(self._item_to_text_list, currency)
    end)
    self:RegisterEvent(ComMgrs.dy_data_mgr.night_club_data, "UpdateLineupEvent", function ()
        self.hero_list = self:GetHeroList()
        self:UpdateHeroDetailInfo()
    end)
    self.dy_night_club_data:RegisterUpdateHeroEvent("HeroDetailInfoUI", self.UpdateHeroDetailInfo, self)
end

function HeroDetailInfoUI:UpdateHeroDetailInfo()
    self:UpdateHeroImageInDetail()
    self:ClearAllInfoText()
    self:_AddRedPoints()
    local hero_data = self.hero_list[self.select_index]
    -- base panel
    local hero_info = self.dy_night_club_data:GetHeroDataById(hero_data.id)
    local upgrate_lv_limit = CSFunction.get_hero_level_limit(ComMgrs.dy_data_mgr:ExGetRoleLevel())
    self.upgrate_btn_cmp.interactable = hero_info.level < upgrate_lv_limit
    self.upgrate_disable:SetActive(hero_info.level >= upgrate_lv_limit)
    local break_lv_limit = #SpecMgrs.data_mgr:GetHeroBreakLvList()
    self.break_btn_cmp.interactable = hero_info.break_lv < break_lv_limit
    self.break_disable:SetActive(hero_info.break_lv >= break_lv_limit)
    local destiny_lv_limit = #SpecMgrs.data_mgr:GetHeroDestinyLvList()
    self.destiny_btn_cmp.interactable = hero_info.destiny_lv < destiny_lv_limit
    self.destiny_disable:SetActive(hero_info.destiny_lv >= destiny_lv_limit)
    self.star_btn_cmp.interactable = hero_info.star_lv < self.star_limit
    self.star_disable:SetActive(hero_info.star_lv >= self.star_limit)
    self.cultivate_btn_red_point:SetActive(self.dy_night_club_data:CheckHeroCultivate() == true)

    local attr_dict = hero_info.attr_dict
    local color = hero_info.level < upgrate_lv_limit and UIConst.Color.Red1 or UIConst.Color.Default
    self.lv.text = string.format(UIConst.Text.LEVEL_WITH_LIMIT_FORMAT, color, hero_info.level, upgrate_lv_limit)
    self.atk.text = string.format(UIConst.Text.ATK_ATTR_FORMAT, math.floor(attr_dict.att))
    self.hp.text = string.format(UIConst.Text.HP_ATTR_FORMAT, math.floor(attr_dict.max_hp))
    self.def.text = string.format(UIConst.Text.DEF_ATTR_FORMAT, math.floor(attr_dict.def))
    self.business.text = string.format(UIConst.Text.BUSINESS_ATTR_FORMAT, math.floor(attr_dict.business))
    self.management.text = string.format(UIConst.Text.MANAGEMENT_ATTR_FORMAT, math.floor(attr_dict.management))
    self.renown.text = string.format(UIConst.Text.FAME_ATTR_FORMAT, math.floor(attr_dict.renown))
    self.battle.text = string.format(UIConst.Text.BATTLE_ATTR_FORMAT, math.floor(attr_dict.fight))
    -- star panel
    for i = 1, self.star_limit do
        self.star_go_list[i]:SetActive(hero_info.star_lv >= i)
    end
    -- star attr panel
    local star_attr_dict = CSFunction.get_hero_star_attr(hero_info.hero_id, hero_info.star_lv)
    self.star_lv.text = string.format(UIConst.Text.STAR_LEVEL_WITH_LIMIT_FORMAT, hero_info.star_lv, self.star_limit)
    self.star_atk.text = string.format(UIConst.Text.ATK_ATTR_FORMAT, math.floor(star_attr_dict.att))
    self.star_hp.text = string.format(UIConst.Text.HP_ATTR_FORMAT, math.floor(star_attr_dict.max_hp))
    self.star_def.text = string.format(UIConst.Text.DEF_ATTR_FORMAT, math.floor(star_attr_dict.def))
    self.star_business.text = string.format(UIConst.Text.BUSINESS_ATTR_FORMAT, math.floor(star_attr_dict.business))
    self.star_management.text = string.format(UIConst.Text.MANAGEMENT_ATTR_FORMAT, math.floor(star_attr_dict.management))
    self.star_renown.text = string.format(UIConst.Text.FAME_ATTR_FORMAT, math.floor(star_attr_dict.renown))
    self.star_battle.text = string.format(UIConst.Text.BATTLE_ATTR_FORMAT, math.floor(star_attr_dict.fight))
    -- skill panel
    for _, spell_id in ipairs(hero_data.spell) do
        local spell_data = SpecMgrs.data_mgr:GetSpellData(spell_id)
        if not spell_data.spell_unit then
            local go = self:GetUIObject(self.info_text_item, self.skill_content)
            self.info_text_dict[spell_id] = go
            go:GetComponent("Text").text = UIFuncs.GetHeroSpellDesc(hero_info.hero_id, spell_data, hero_info.dynasty_lv, true)
        end
    end
    if hero_data.combo_spell then
        for _, spell in ipairs(hero_data.combo_spell) do
            local go = self:GetUIObject(self.info_text_item, self.skill_content)
            self.info_text_dict[spell] = go
            local combo_spell_data = SpecMgrs.data_mgr:GetSpellData(spell)
            go:GetComponent("Text").text = UIFuncs.GetHeroSpellDesc(hero_info.hero_id, combo_spell_data, hero_info.dynasty_lv, true)
        end
    end
    self.destiny_lv.text = string.format(UIConst.Text.DESTINY_TEXT, hero_info.destiny_lv)
    -- talent panel
    for i, talent_id in ipairs(hero_data.talent) do
        local talent_data = SpecMgrs.data_mgr:GetTalentData(talent_id)
        local go = self:GetUIObject(self.info_text_item, self.gift_content)
        local is_active = hero_info.break_lv >= i
        local talent_str = UIFuncs.GetHeroTalentDescWithName(talent_id, i, is_active)
        local talent_color = is_active and UIConst.Color.ActiveColor or UIConst.Color.UnactiveColor
        go:GetComponent("Text").text = string.format(UIConst.Text.SIMPLE_COLOR, talent_color, talent_str)
        self.info_text_dict[talent_id] = go
    end
    -- fate panel
    if hero_data.fate then
        for _, fate_id in ipairs(hero_data.fate) do
            local go = self:GetUIObject(self.info_text_item, self.fate_content)
            local fate_data = SpecMgrs.data_mgr:GetFateData(fate_id)
            local flag
            if fate_data.fate_hero then
                flag = self.dy_night_club_data:CheckHeroIsLineUp(SpecMgrs.data_mgr:GetHeroData(fate_data.fate_hero).unit_id)
            elseif fate_data.fate_item then
                flag = self.dy_night_club_data:CheckHeroWearEquip(hero_data.id, fate_data.fate_item)
            end
            local color = flag and UIConst.Color.ActiveColor or UIConst.Color.UnactiveColor
            go:GetComponent("Text").text = string.format(UIConst.Text.SIMPLE_COLOR, color, UIFuncs.GetFateDescStr(fate_id, flag))
            self.info_text_dict[fate_id] = go
        end
    end
    -- desc panel
    self.desc_text.text = hero_data.desc
    self.detail_info_rect_cmp.anchoredPosition = Vector2.zero
end

function HeroDetailInfoUI:UpdateHeroImageInDetail()
    local basic_data = self.hero_list[self.select_index]
    local quality_data = SpecMgrs.data_mgr:GetQualityData(basic_data.quality)
    local extra_data = self.dy_night_club_data:GetHeroDataById(basic_data.id)
    local unit_data = SpecMgrs.data_mgr:GetUnitData(basic_data.unit_id)

    local tag2_data = SpecMgrs.data_mgr:GetTagData(basic_data.tag[2])
    local tag3_data = SpecMgrs.data_mgr:GetTagData(basic_data.tag[3])
    UIFuncs.AssignSpriteByIconID(quality_data.grade, self.cur_hero_grade)
    UIFuncs.AssignSpriteByIconID(quality_data.hero_card_bg, self.cur_hero_icon:GetComponent("Image"))
    UIFuncs.AssignSpriteByIconID(tag2_data.icon, self.cur_hero_tag1:GetComponent("Image"))
    self.cur_hero_tag2:SetActive(#basic_data.tag > 2)
    if #basic_data.tag > 2 then
        UIFuncs.AssignSpriteByIconID(tag3_data.icon, self.cur_hero_tag2:GetComponent("Image"))
    end
    if self.hero_model then ComMgrs.unit_mgr:DestroyUnit(self.hero_model) end
    self.hero_model = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = basic_data.unit_id, parent = self.cur_hero_icon})
    self.hero_model:SetPositionByRectName({parent = self.cur_hero_icon, name = UnitConst.UnitRect.Card})
    self.hero_model:StopAllAnimationToCurPos()
    self.cur_hero_name.text = basic_data.name
    self.cur_hero_lv.text = string.format(UIConst.Text.LEVEL, extra_data.level)
    for i = 1, self.star_limit do
        self.cur_hero_star_list:FindChild("Star" .. i .. "/Active"):SetActive(i <= extra_data.star_lv)
    end
end

function HeroDetailInfoUI:ShowHeroCultivateUI(op)
    SpecMgrs.ui_mgr:ShowTrainHeroUI(self.hero_list, self.select_index, op, function (index)
        self.select_index = index
        self:UpdateHeroDetailInfo()
    end)
end

function HeroDetailInfoUI:ExpandDetailInfoPanel()
    if self.expanding then return end
    self.expanding = true
    self.content_pos_cmp.from_ = self.expanded and kTopPos or kBottomPos
    self.content_pos_cmp.to_ = self.expanded and kBottomPos or kTopPos
    self.content_pos_cmp:Play()
    self:AddTimer(function ()
        self.expanded = not self.expanded
        if not self.expanded then
            local hero_id = self.hero_list[self.select_index].id
            SpecMgrs.ui_mgr:HideUI(self)
            if self.close_cb then
                self.close_cb(hero_id)
                self.select_index = nil
                self.close_cb = nil
            end
        end
        self.expanding = false
    end, kExpandTime)
end

function HeroDetailInfoUI:ClearAllInfoText()
    for _, go in pairs(self.info_text_dict) do
        self:DelUIObject(go)
    end
    self.info_text_dict = {}
end

function HeroDetailInfoUI:_AddRedPoints()
    if self.is_add_redpoint_ok then
        self:_RemoveRedPoints()
    end
    local hero_id = self.hero_list[self.select_index].id
    self.break_redpoint = SpecMgrs.redpoint_mgr:AddRedPoint(self, self.break_btn, CSConst.RedPointType.Normal, {CSConst.RedPointControlIdDict.NightClub.Break}, hero_id)
    self.upgrade_redpoint = SpecMgrs.redpoint_mgr:AddRedPoint(self, self.upgrate_btn, CSConst.RedPointType.Normal, {CSConst.RedPointControlIdDict.NightClub.LevelUp}, hero_id)
    self.destiny_redpoint = SpecMgrs.redpoint_mgr:AddRedPoint(self, self.destiny_btn, CSConst.RedPointType.Normal, {CSConst.RedPointControlIdDict.NightClub.Destiny}, hero_id)
    self.addstar_redpoint = SpecMgrs.redpoint_mgr:AddRedPoint(self, self.star_btn, CSConst.RedPointType.Normal, {CSConst.RedPointControlIdDict.NightClub.AddStar}, hero_id)
    self.is_add_redpoint_ok = true
end

function HeroDetailInfoUI:_RemoveRedPoints()
    if not self.is_add_redpoint_ok then
        return
    end
    SpecMgrs.redpoint_mgr:RemoveRedPoint(self.break_redpoint)
    SpecMgrs.redpoint_mgr:RemoveRedPoint(self.upgrade_redpoint)
    SpecMgrs.redpoint_mgr:RemoveRedPoint(self.destiny_redpoint)
    SpecMgrs.redpoint_mgr:RemoveRedPoint(self.addstar_redpoint)
    self.break_redpoint = nil
    self.upgrade_redpoint = nil
    self.destiny_redpoint = nil
    self.addstar_redpoint = nil
    self.is_add_redpoint_ok = false
end

return HeroDetailInfoUI