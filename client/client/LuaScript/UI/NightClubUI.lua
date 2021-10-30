local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local GConst = require("GlobalConst")
local UnitConst = require("Unit.UnitConst")
local SlideSelectCmp = require("UI.UICmp.SlideSelectCmp")

local NightClubUI = class("UI.NightClubUI", UIBase)

local kHeroIndex = {
    Pre = 0,
    Cur = 1,
    Next = 2,
}
local kSyncLoadInterval = 0.2
local kSyncLoadCount = 9

function NightClubUI:DoInit()
    NightClubUI.super.DoInit(self)
    self.prefab_path = "UI/Common/NightClubUI"
    self.dy_night_club_data = ComMgrs.dy_data_mgr.night_club_data
    self.hero_go_dict = {}
    self.cur_select_index = 0
    self.cur_select_id = 0
    self.cur_select_power = 0
    self.power_go_dict = {}
    self.tab_btn_dict = {}
    self.hero_sprite_dict = {}
    self.hero_model_dict = {}
    self.hero_unit_dict = {}
    self.star_limit = SpecMgrs.data_mgr:GetParamData("hero_star_lv_limit").f_value
    self.hero_redpoint_list = {}
    self.redpoint_control_id_list = {}
    for _, id in pairs(CSConst.RedPointControlIdDict.NightClub) do
        table.insert(self.redpoint_control_id_list, id)
    end
end

function NightClubUI:OnGoLoadedOk(res_go)
    NightClubUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function NightClubUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    NightClubUI.super.Show(self)
end

function NightClubUI:Hide()
    self:UpdateHeroList()
    self:ClearHeroList()
    self.dy_night_club_data:UnregisterUpdateHeroEvent("NightClubUI")
    self.dy_night_club_data:UnregisterAddHeroEvent("NightClubUI")
    NightClubUI.super.Hide(self)
end

function NightClubUI:InitRes()
    -- Top Menu
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "NightClubUI", function ()
        if self.cur_select_id == 0 then
            -- 在hero_list
            SpecMgrs.ui_mgr:HideUI(self)
        else
            -- 在info_panel
            self:HideInfoPanel()
        end
    end)

    -- Hero List
    self.hero_list_panel = self.main_panel:FindChild("HeroListPanel")
        -- tab btn
    local hero_tab_panel = self.hero_list_panel:FindChild("HeroTabPanel")
    self.all_tab_btn = hero_tab_panel:FindChild("All")
    self:AddClick(self.all_tab_btn, function ()
        self:UpdateHeroList(CSConst.HeroTag.All)
    end)
    self.all_tab_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.HERO_TAG_ALL
    self.all_tab_btn:FindChild("Select/Text"):GetComponent("Text").text = UIConst.Text.HERO_TAG_ALL
    self.tab_btn_dict[CSConst.HeroTag.All] = self.all_tab_btn

    self.business_tab_btn = hero_tab_panel:FindChild("Business")
    self:AddClick(hero_tab_panel:FindChild("Business"), function ()
        self:UpdateHeroList(CSConst.HeroTag.Business)
    end)
    self.business_tab_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.HERO_TAG_BUSINESS
    self.business_tab_btn:FindChild("Select/Text"):GetComponent("Text").text = UIConst.Text.HERO_TAG_BUSINESS
    self.tab_btn_dict[CSConst.HeroTag.Business] = self.business_tab_btn

    self.management_tab_btn = hero_tab_panel:FindChild("Technology")
    self:AddClick(hero_tab_panel:FindChild("Technology"), function ()
        self:UpdateHeroList(CSConst.HeroTag.Management)
    end)
    self.management_tab_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.HERO_TAG_MANAGEMENT
    self.management_tab_btn:FindChild("Select/Text"):GetComponent("Text").text = UIConst.Text.HERO_TAG_MANAGEMENT
    self.tab_btn_dict[CSConst.HeroTag.Management] = self.management_tab_btn

    self.fame_tab_btn = hero_tab_panel:FindChild("Fame")
    self:AddClick(hero_tab_panel:FindChild("Fame"), function ()
        self:UpdateHeroList(CSConst.HeroTag.Fame)
    end)
    self.fame_tab_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.HERO_TAG_FAME
    self.fame_tab_btn:FindChild("Select/Text"):GetComponent("Text").text = UIConst.Text.HERO_TAG_FAME
    self.tab_btn_dict[CSConst.HeroTag.Fame] = self.fame_tab_btn

    self.fighting_tab_btn = hero_tab_panel:FindChild("Fighting")
    self:AddClick(hero_tab_panel:FindChild("Fighting"), function ()
        self:UpdateHeroList(CSConst.HeroTag.Fighting)
    end)
    self.fighting_tab_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.HERO_TAG_FIGHTING
    self.fighting_tab_btn:FindChild("Select/Text"):GetComponent("Text").text = UIConst.Text.HERO_TAG_FIGHTING
    self.tab_btn_dict[CSConst.HeroTag.Fighting] = self.fighting_tab_btn

    self.power_tab_btn = hero_tab_panel:FindChild("Power")
    self:AddClick(hero_tab_panel:FindChild("Power"), function ()
        if not self.cur_select_tag then return end
        self.own_panel:SetActive(false)
        self.without_panel:SetActive(false)
        self.tab_btn_dict[self.cur_select_tag]:FindChild("Select"):SetActive(false)
        self.cur_select_tag = nil
        self.tab_btn_dict[CSConst.HeroTag.Power]:FindChild("Select"):SetActive(true)
        self:UpdatePowerList()
    end)
    self.power_tab_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.HERO_TAG_POWER
    self.power_tab_btn:FindChild("Select/Text"):GetComponent("Text").text = UIConst.Text.HERO_TAG_POWER
    self.tab_btn_dict[CSConst.HeroTag.Power] = self.power_tab_btn
        -- list content
    self.hero_list_content = self.hero_list_panel:FindChild("HeroList/Viewport/Content")
    self.own_panel = self.hero_list_content:FindChild("OwnPanel")
    self.own_list = self.own_panel:FindChild("OwnList")
    self.without_panel = self.hero_list_content:FindChild("WithoutPanel")
    self.without_list = self.without_panel:FindChild("WithoutList")

    -- Without Hero Info
    -- self.without_hero_panel = self.main_panel:FindChild("WithoutHeroInfoPanel")
    -- self:AddClick(self.without_hero_panel:FindChild("Title/CloseBtn"), function ()
    --     self.without_hero_panel:SetActive(false)
    -- end)
    -- self.without_info_panel = self.without_hero_panel:FindChild("InfoPanel")
    -- self.without_hero_name = self.without_info_panel:FindChild("NamePanel/Name"):GetComponent("Text")
    -- local tag_panel = self.without_info_panel:FindChild("TagPanel")
    -- self.without_hero_tag1 = tag_panel:FindChild("Tag1")
    -- self.without_hero_tag2 = tag_panel:FindChild("Tag2")
    -- local aptitude_panel = self.without_info_panel:FindChild("AptitudePanel")
    -- self.without_hero_total_aptitude = aptitude_panel:FindChild("TotalAptitudePanel/TotalAptitude"):GetComponent("Text")
    -- self.without_power_aptitude = aptitude_panel:FindChild("PowerPanel/Power"):GetComponent("Text")
    -- self.without_business_aptitude = aptitude_panel:FindChild("BusinessPanel/Business"):GetComponent("Text")
    -- self.without_technology_aptitude = aptitude_panel:FindChild("TechnologyPanel/Technology"):GetComponent("Text")
    -- self.without_renown_aptitude = aptitude_panel:FindChild("RenownPanel/Renown"):GetComponent("Text")
    -- self.without_fight_aptitude = aptitude_panel:FindChild("FightPanel/Fight"):GetComponent("Text")
    -- self.obtain_way = self.without_info_panel:FindChild("ObtainWayPanel/ObtainWay"):GetComponent("Text")

    -- Hero Info
    self.hero_info_panel = self.main_panel:FindChild("HeroInfoPanel")
    -- self.hero_bg = self.hero_info_panel:FindChild("HeroBg"):GetComponent("Image")
        -- basic info
    self.basic_info_panel = self.hero_info_panel:FindChild("BasicInfoPanel")
    self.hero_sprite = self.basic_info_panel:FindChild("HeroModel")
    self.hero_model_width = self.hero_sprite:GetComponent("RectTransform").rect.width
    self.hero1 = self.hero_sprite:FindChild("Hero1")
    self.hero_sprite_dict[kHeroIndex.Pre] = self.hero1
    self.hero1:GetComponent("RectTransform").anchoredPosition = Vector2.New(-self.hero_model_width, 0)
    self.hero2 = self.hero_sprite:FindChild("Hero2")
    self.hero_sprite_dict[kHeroIndex.Cur] = self.hero2
    self.hero3 = self.hero_sprite:FindChild("Hero3")
    self.hero_sprite_dict[kHeroIndex.Next] = self.hero3
    self.hero3:GetComponent("RectTransform").anchoredPosition = Vector2.New(self.hero_model_width, 0)
    for _, hero_item in pairs(self.hero_sprite_dict) do
        self:AddClick(hero_item, function ()
            self:ShowHeroDetailInfo()
        end)
    end
    self.basic_info_slide = SlideSelectCmp.New()
    self.basic_info_slide:DoInit(self, self.hero_sprite)
    self.basic_info_slide:ListenSlideBegin(function ()
        self.info_panel:SetActive(false)
    end)
    self.basic_info_slide:ListenSlideEnd(function (move_dir)
        self.move_dir = move_dir
        if move_dir ~= 0 then
            self:ReFreshInfoPanel(move_dir)
        end
        self.info_panel:SetActive(true)
    end)
    self.basic_info_slide:ListenSelectUpdate(function (index)
        if index >= 0 then self:RefreshModel(index) end
    end)
    self:AddClick(self.basic_info_panel:FindChild("PreBtn"), function ()
        self.basic_info_slide:SlideByOffset(1)
    end)
    self:AddClick(self.basic_info_panel:FindChild("NextBtn"), function ()
        self.basic_info_slide:SlideByOffset(-1)
    end)
    self.tag1 = self.basic_info_panel:FindChild("Tag1")
    self.tag2 = self.basic_info_panel:FindChild("Tag2")

    self.info_panel = self.basic_info_panel:FindChild("InfoPanel")
    self.basic_name = self.info_panel:FindChild("NameBg/Name"):GetComponent("Text")
    self.hero_grade = self.info_panel:FindChild("NameBg/Grade"):GetComponent("Image")
    self.star_panel = self.info_panel:FindChild("StarList")
        -- attr panel
    local attr_panel = self.info_panel:FindChild("AttrPanel")
    local level = attr_panel:FindChild("Level")
    level:FindChild("Text"):GetComponent("Text").text = UIConst.Text.LEVEL_TEXT
    self.level = level:FindChild("Value"):GetComponent("Text")
    local score = attr_panel:FindChild("Score")
    score:FindChild("Text"):GetComponent("Text").text = UIConst.Text.TOTAL_SCORE_TEXT
    self.score = score:FindChild("Value"):GetComponent("Text")
    local total_attr = attr_panel:FindChild("TotalAttr")
    total_attr:FindChild("Text"):GetComponent("Text").text = UIConst.Text.TOTAL_ATTR
    self.total_attr = total_attr:FindChild("Value"):GetComponent("Text")
    local power = attr_panel:FindChild("Power")
    power:FindChild("Text"):GetComponent("Text").text = UIConst.Text.POWER
    self.power = power:FindChild("Value"):GetComponent("Text")
    local business_attr = attr_panel:FindChild("BusinessAttr")
    business_attr:FindChild("Text"):GetComponent("Text").text = UIConst.Text.BUSINESS_ATTR
    self.business_attr = business_attr:FindChild("Value"):GetComponent("Text")
    local management_attr = attr_panel:FindChild("TechnologyAttr")
    management_attr:FindChild("Text"):GetComponent("Text").text = UIConst.Text.MANAGEMENT_ATTR
    self.management_attr = management_attr:FindChild("Value"):GetComponent("Text")
    local fame_attr = attr_panel:FindChild("FameAttr")
    fame_attr:FindChild("Text"):GetComponent("Text").text = UIConst.Text.FAME_ATTR
    self.fame_attr = fame_attr:FindChild("Value"):GetComponent("Text")
    local battle_attr = attr_panel:FindChild("BattleAttr")
    battle_attr:FindChild("Text"):GetComponent("Text").text = UIConst.Text.BATTLE_ATTR
    self.battle_attr = battle_attr:FindChild("Value"):GetComponent("Text")

    self:AddClick(self.hero_info_panel:FindChild("BottomPanel"), function ()
        self:ShowHeroDetailInfo()
    end)
    self.hero_info_panel:SetActive(false)
    -- Prefab List
    local prefab_list = self.main_panel:FindChild("PrefabList")
    self.hero_item = prefab_list:FindChild("HeroItem")
    self.without_hero_item = prefab_list:FindChild("WithoutHeroItem")
    self.info_text_item = prefab_list:FindChild("TextItem")
    self.power_item = prefab_list:FindChild("PowerItem")
end

function NightClubUI:InitUI()
    self:UpdateHeroList(CSConst.HeroTag.All)
    self:RegisterEvent(ComMgrs.dy_data_mgr, "UpdateCurrencyEvent", function (_, currency)
        UIFuncs.UpdateCurrencyItemNum(self._item_to_text_list, currency)
    end)
    self.dy_night_club_data:RegisterUpdateHeroEvent("NightClubUI", self.UpdateHero, self)
    self.dy_night_club_data:RegisterAddHeroEvent("NightClubUI", self.AddHero, self)
end

function NightClubUI:UpdateHeroList(tag)
    if self.cur_select_tag == tag then return end
    if not self.cur_select_tag then
        self.own_panel:SetActive(true)
        self.without_panel:SetActive(true)
    end
    self.tab_btn_dict[self.cur_select_tag or CSConst.HeroTag.Power]:FindChild("Select"):SetActive(false)
    self.cur_select_tag = tag
    if not self.cur_select_tag then return end
    self.tab_btn_dict[tag]:FindChild("Select"):SetActive(true)
    self:InitHeroList()
end

function NightClubUI:InitHeroList()
    -- 前kSyncLoadCount个同步加载 后面所有异步
    self:ClearHeroList()
    local hero_list = self.dy_night_club_data:GetHeroList(self.cur_select_tag)
    local owned_hero_count = #hero_list
    for index, data in ipairs(hero_list) do
        self:AddHeroItem(index, data.id, true, self.own_list, index <= kSyncLoadCount)
    end
    local without_hero_list = self.dy_night_club_data:GetWithoutHeroList(self.cur_select_tag)
    self.without_panel:SetActive(#without_hero_list > 0)
    for index, data in ipairs(without_hero_list) do
        self:AddHeroItem(index, data.id, false, self.without_list, index + owned_hero_count <= kSyncLoadCount)
    end
end

function NightClubUI:AddHeroItem(index, id, owned, parent, is_sync)
    local data = SpecMgrs.data_mgr:GetHeroData(id)
    local hero_info = self.dy_night_club_data:GetHeroDataById(id)
    local quality_data = SpecMgrs.data_mgr:GetQualityData(data.quality)
    local item_pref = owned and self.hero_item or self.without_hero_item
    local go = self:GetUIObject(item_pref, parent)
    go.name = data.id
    go:FindChild("NameBg/Name"):GetComponent("Text").text = data.name
    UIFuncs.AssignSpriteByIconID(quality_data.grade, go:FindChild("Grade"):GetComponent("Image"))
    local unit_data = SpecMgrs.data_mgr:GetUnitData(data.unit_id)
    local lv_panel = go:FindChild("LvBg")
    -- UIFuncs.AssignSpriteByIconID(unit_data.icon, go:FindChild("HeroIcon"):GetComponent("Image"))
    local hero_icon = go:FindChild("HeroIcon")
    UIFuncs.AssignSpriteByIconID(quality_data.hero_card_bg, go:FindChild("HeroIcon"):GetComponent("Image"))
    local hero_model = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = data.unit_id, parent = hero_icon, need_sync_load = is_sync})
    --local hero_model = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = data.unit_id, parent = hero_icon})
    hero_model:SetPositionByRectName({parent = hero_icon, name = UnitConst.UnitRect.Card})
    hero_model:StopAllAnimationToCurPos()
    if not owned then hero_model:ChangeToGray() end
    self.hero_unit_dict[data.id] = hero_model

    UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetTagData(data.tag[2]).icon, go:FindChild("Tag1"):GetComponent("Image"))
    local tag2 = go:FindChild("Tag2")
    tag2:SetActive(data.tag[3] ~= nil)
    if data.tag[3] then UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetTagData(data.tag[3]).icon, tag2:GetComponent("Image")) end

    if owned then
        local star_list = go:FindChild("StarList")
        for i = 1, self.star_limit do
            star_list:FindChild("Star" .. i .. "/Active"):SetActive(i <= hero_info.star_lv)
        end
        lv_panel:FindChild("Lv"):GetComponent("Text").text = string.format(UIConst.Text.LEVEL, self.dy_night_club_data:GetHeroDataById(id).level)
        self:AddClick(go, function ()
            self.cur_select_id = data.id
            self.cur_select_index = index
            self.cur_select_power = data.power
            self:UpdateHeroBasicInfo()
            self:InitHeroModel()
            self.hero_info_panel:SetActive(true)
            self.hero_list_panel:SetActive(false)
        end)
    else
        self:AddClick(go, function ()
            local fragment_data = SpecMgrs.data_mgr:GetItemData(data.fragment_id)
            SpecMgrs.ui_mgr:ShowItemPreviewUI(fragment_data.hero)
        end)
    end
    self.hero_go_dict[data.id] = go
    local redpoint = SpecMgrs.redpoint_mgr:AddRedPoint(self, go, CSConst.RedPointType.HighLight, self.redpoint_control_id_list, data.id)
    table.insert(self.hero_redpoint_list, redpoint)
end

function NightClubUI:UpdatePowerList()
    self:ClearHeroList()
    -- local power_list = SpecMgrs.data_mgr:GetAllHeroDataWithPower()
    for _, power in ipairs(SpecMgrs.data_mgr:GetPowerList()) do
        local power_go = self:GetUIObject(self.power_item, self.hero_list_content)
        power_go:FindChild("PowerTitle/Image/Text"):GetComponent("Text").text = power.name
        for index, data in ipairs(self.dy_night_club_data:GetPowerHeroList(power.id)) do
            self:AddHeroItem(index, data.id, true, power_go:FindChild("PowerList"))
        end
        for _, data in ipairs(self.dy_night_club_data:GetWithoutPowerHeroList(power.id)) do
            self:AddHeroItem(nil, data.id, false, power_go:FindChild("PowerList"))
        end
        self.power_go_dict[power.id] = power_go
    end
end

function NightClubUI:UpdateHeroBasicInfo()
    local extra_data = self.dy_night_club_data:GetHeroDataById(self.cur_select_id)
    local basic_data = SpecMgrs.data_mgr:GetHeroData(extra_data.hero_id)
    local quality_data = SpecMgrs.data_mgr:GetQualityData(basic_data.quality)

    local tag2_data = SpecMgrs.data_mgr:GetTagData(basic_data.tag[2])
    local tag3_data = SpecMgrs.data_mgr:GetTagData(basic_data.tag[3])
    UIFuncs.AssignSpriteByIconID(tag2_data.icon, self.tag1:GetComponent("Image"))
    self.tag2:SetActive(#basic_data.tag > 2)
    if #basic_data.tag > 2 then
        UIFuncs.AssignSpriteByIconID(tag3_data.icon, self.tag2:GetComponent("Image"))
    end

    for i = 1, self.star_limit do
        self.star_panel:FindChild("Star" .. i .."/Active"):SetActive(i <= extra_data.star_lv)
    end
    self.basic_name.text = UIFuncs.GetHeroName(self.cur_select_id)
    UIFuncs.AssignSpriteByIconID(quality_data.grade, self.hero_grade)
    self.level.text = extra_data.level
    self.power.text = SpecMgrs.data_mgr:GetPowerData(basic_data.power).name
    local attr = extra_data.attr_dict
    self.score.text = extra_data.score
    self.total_attr.text = math.floor(attr.business + attr.management + attr.renown + attr.fight)
    self.business_attr.text = math.floor(attr.business)
    self.management_attr.text = math.floor(attr.management)
    self.fame_attr.text = math.floor(attr.renown)
    self.battle_attr.text = math.floor(attr.fight)
end

function NightClubUI:ReFreshInfoPanel(offset)
    local hero_list = self:GetHeroList()
    self.cur_select_index = math.Repeat(self.cur_select_index + offset - 1, #hero_list) + 1
    self.cur_select_id = hero_list[self.cur_select_index].id
    self:UpdateHeroBasicInfo()
end

function NightClubUI:InitHeroModel()
    self:RemoveUnitModel()
    self.basic_info_slide:ResetLoopOffset()
    local cur_hero_unit_id = SpecMgrs.data_mgr:GetHeroData(self.cur_select_id).unit_id
    local cur_hero_unit = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = cur_hero_unit_id, parent = self.hero_sprite_dict[kHeroIndex.Cur]})
    cur_hero_unit:SetPositionByRectName({parent = self.hero_sprite_dict[kHeroIndex.Cur], name = "full"})
    self.hero_model_dict[kHeroIndex.Cur] = cur_hero_unit

    local hero_list = self:GetHeroList()
    for i, hero in ipairs(hero_list) do
        if hero.id == self.cur_select_id then
            self.cur_select_index = i
            break
        end
    end
    self.basic_info_slide:SetDraggable(#hero_list > 1)
    local pre_hero_unit_id = hero_list[math.Repeat(self.cur_select_index - 2, #hero_list) + 1].unit_id
    local pre_hero_unit = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = pre_hero_unit_id, parent = self.hero_sprite_dict[kHeroIndex.Pre]})
    pre_hero_unit:SetPositionByRectName({parent = self.hero_sprite_dict[kHeroIndex.Pre], name = "full"})
    self.hero_model_dict[kHeroIndex.Pre] = pre_hero_unit

    local next_hero_unit_id = hero_list[math.Repeat(self.cur_select_index, #hero_list) + 1].unit_id
    local next_hero_unit = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = next_hero_unit_id, parent = self.hero_sprite_dict[kHeroIndex.Next]})
    next_hero_unit:SetPositionByRectName({parent = self.hero_sprite_dict[kHeroIndex.Next], name = "full"})
    self.hero_model_dict[kHeroIndex.Next] = next_hero_unit
end

function NightClubUI:RefreshModel(index)
    ComMgrs.unit_mgr:DestroyUnit(self.hero_model_dict[index])
    local hero_list = self:GetHeroList()
    -- self.cur_select_index = math.Repeat(self.cur_select_index + self.move_dir - 1, #hero_list) + 1
    local new_unit_id = hero_list[math.Repeat(self.cur_select_index + self.move_dir - 1, #hero_list) + 1].unit_id
    local new_model = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = new_unit_id, parent = self.hero_sprite_dict[index]})
    new_model:SetPositionByRectName({parent = self.hero_sprite_dict[index], name = "full"})
    self.hero_model_dict[index] = new_model
end

function NightClubUI:UpdateHero(_, hero_data)
    if self.cur_select_id == hero_data.hero_id then
        self:UpdateHeroBasicInfo()
    end
end

function NightClubUI:AddHero(_, hero_data)
    local hero = SpecMgrs.data_mgr:GetHeroData(hero_data.hero_id)
    if not self.cur_select_tag then
        self:UpdatePowerList()
        if self.cur_select_id ~= 0 and self.cur_select_power == hero.power then
            self.cur_select_index = self.dy_night_club_data:GetPowerHeroIndex(hero.power, hero.id)
            self:ChangeCurSelectHero(0)
        end
    else
        for _, tag in ipairs(hero.tag) do
            if self.cur_select_tag == tag then
                self:UpdateHeroList(self.cur_select_tag)
                if self.cur_select_id == 0 then return end
                self.cur_select_index = self.dy_night_club_data:GetHeroIndex(tag, hero.id)
                self:ChangeCurSelectHero(0)
                break
            end
        end
    end
end

-- function NightClubUI:ShowWithoutHeroInfo(id)
--     local data = SpecMgrs.data_mgr:GetHeroData(id)

--     self.without_hero_name.text = data.name
--     self:SetHeroTagImage(self.without_hero_tag1, self.without_hero_tag2, data.tag)

--     self.without_hero_total_aptitude.text = data.business + data.technology + data.renown + data.fight
--     self.without_power_aptitude.text = data.power
--     self.without_business_aptitude.text = data.business
--     self.without_technology_aptitude.text = data.technology
--     self.without_renown_aptitude.text = data.renown
--     self.without_fight_aptitude.text = data.fight
--     self.obtain_way.text = string.format(UIConst.Text.OBTAIN_WAY, data.obtain)
--     self.without_hero_panel:SetActive(true)
-- end

function NightClubUI:GetHeroList()
    local temp_list = {}
    if self.cur_select_tag then
        temp_list = self.dy_night_club_data:GetHeroList(self.cur_select_tag)
    else
        temp_list = self.dy_night_club_data:GetPowerHeroList(self.cur_select_power)
    end
    local hero_list = {}
    for _, hero in ipairs(temp_list) do
        table.insert(hero_list, hero)
    end
    return hero_list
end

function NightClubUI:ShowHeroDetailInfo()
    local hero_list = self:GetHeroList()
    SpecMgrs.ui_mgr:ShowHeroDetailInfo(hero_list, self.cur_select_index, function (hero_id)
        self.cur_select_id = hero_id
        self:UpdateHeroBasicInfo()
        self:InitHeroModel()
    end, true)
end

function NightClubUI:HideInfoPanel()
    self.cur_select_id = 0
    self.cur_select_index = 0
    self:RemoveUnitModel()
    if self.cur_select_tag then
        self:InitHeroList()
    else
        self:UpdatePowerList()
    end
    self.hero_list_panel:SetActive(true) -- 打开英雄列表
    self.hero_info_panel:SetActive(false) -- 整体隐藏英雄信息界面
end

function NightClubUI:RemoveUnitModel()
    for _, model in pairs(self.hero_model_dict) do
        ComMgrs.unit_mgr:DestroyUnit(model)
    end
    self.hero_model_dict = {}
end

function NightClubUI:ClearHeroList()
    for _, redpoint in ipairs(self.hero_redpoint_list) do
        SpecMgrs.redpoint_mgr:RemoveRedPoint(redpoint)
    end
    self.hero_redpoint_list = {}
    for _, go in pairs(self.hero_unit_dict) do
        ComMgrs.unit_mgr:DestroyUnit(go)
    end
    self.hero_unit_dict = {}
    for _, go in pairs(self.hero_go_dict) do
        self:DelUIObject(go)
    end
    self.hero_go_dict = {}
    for _, go in pairs(self.power_go_dict) do
        self:DelUIObject(go)
    end
    self.power_go_dict = {}
end

return NightClubUI