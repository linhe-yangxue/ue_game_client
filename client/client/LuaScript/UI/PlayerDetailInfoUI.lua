local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local PlayerDetailInfoUI = class("UI.PlayerDetailInfoUI", UIBase)

local kBottomPos = Vector2.New(0, -1920)
local kTopPos = Vector2.New(0, 0)
local kExpandTime = 0.2
local kExpandStateRotation = Quaternion.Euler(Vector3.New(0, 0, -90))
local kCloseStateRotation = Quaternion.Euler(Vector3.zero)

function PlayerDetailInfoUI:DoInit()
    PlayerDetailInfoUI.super.DoInit(self)
    self.prefab_path = "UI/Common/PlayerDetailInfoUI"
    self.dy_dynasty_data = ComMgrs.dy_data_mgr.dynasty_data
    self.dy_hero_data = ComMgrs.dy_data_mgr.night_club_data
    self.dy_lover_data = ComMgrs.dy_data_mgr.lover_data
    self.dy_child_data = ComMgrs.dy_data_mgr.child_center_data
    self.expanded = false
    self.hero_score_item_list = {}
    self.info_item_list = {}
    self.is_expand_gangster_info = true
    self.is_expand_score_info = true
    self.is_expand_assets_info = true
end

function PlayerDetailInfoUI:OnGoLoadedOk(res_go)
    PlayerDetailInfoUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function PlayerDetailInfoUI:Hide()
    self:ClearHeroScoreItem()
    self:ClearInfoItem()
    self.is_expand_gangster_info = true
    self.is_expand_score_info = true
    self.is_expand_assets_info = true
    PlayerDetailInfoUI.super.Hide(self)
end

function PlayerDetailInfoUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    PlayerDetailInfoUI.super.Show(self)
end

function PlayerDetailInfoUI:InitRes()
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "PlayerDetailInfoUI", function ()
        self:ExpandDetailInfoPanel()
    end)
    self.content_pos_cmp = self.main_panel:GetComponent("UITweenPosition")

    local basic_info_panel = self.main_panel:FindChild("BasicInfoPanel")
    self.role_icon = basic_info_panel:FindChild("IconBg/Icon"):GetComponent("Image")
    self.role_name = basic_info_panel:FindChild("NamePanel/Name"):GetComponent("Text")
    self.role_vip = basic_info_panel:FindChild("NamePanel/Vip")
    self.role_vip_img = basic_info_panel:GetComponent("Image")
    self.role_dynasty = basic_info_panel:FindChild("Dynasty"):GetComponent("Text")
    self.role_score = basic_info_panel:FindChild("Score"):GetComponent("Text")
    self.role_fight_score = basic_info_panel:FindChild("FightScore"):GetComponent("Text")
    local level_panel = basic_info_panel:FindChild("Level")
    level_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.LEVEL_FORMAT
    self.role_level = level_panel:FindChild("Value"):GetComponent("Text")
    local exp_panel = basic_info_panel:FindChild("ExpPanel")
    exp_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.EXP_TEXT
    self.role_exp = exp_panel:FindChild("ExpBar/Exp"):GetComponent("Image")
    self.role_exp_value = exp_panel:FindChild("ExpBar/Value"):GetComponent("Text")

    local detail_info_panel = self.main_panel:FindChild("DetailInfoPanel")
    detail_info_panel:FindChild("CloseBtn/Text"):GetComponent("Text").text = UIConst.Text.DETAIL
    self:AddClick(detail_info_panel:FindChild("CloseBtn"), function ()
        self:ExpandDetailInfoPanel()
    end)
    local info_content = detail_info_panel:FindChild("View/Content")
    self.info_content_rect_cmp = info_content:GetComponent("RectTransform")

    local gangster_info_panel = info_content:FindChild("GangsterInfo")
    local gangster_info_title = gangster_info_panel:FindChild("Title")
    gangster_info_title:FindChild("Text"):GetComponent("Text").text = UIConst.Text.GANGSTER_INFO_TITLE
    self.gangster_info_state = gangster_info_title:FindChild("ExpandState"):GetComponent("RectTransform")
    self:AddClick(gangster_info_title, function ()
        self.is_expand_gangster_info = not self.is_expand_gangster_info
        self.total_score_panel:SetActive(self.is_expand_gangster_info)
        self.gangster_info_state.localRotation = self.is_expand_gangster_info and kExpandStateRotation or kCloseStateRotation
        self.gangster_info_content:SetActive(self.is_expand_gangster_info)
    end)
    self.total_score_panel = gangster_info_panel:FindChild("TotalScore")
    self.total_score_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.GANGSTER_SCORE_TEXT
    self.total_score_text = self.total_score_panel:FindChild("Value"):GetComponent("Text")
    self.gangster_info_content = gangster_info_panel:FindChild("Info")
    local business_panel = self.gangster_info_content:FindChild("Business")
    business_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.BUSINESS_ATTR
    self.business_attr = business_panel:FindChild("Value"):GetComponent("Text")
    local management_panel = self.gangster_info_content:FindChild("Management")
    management_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.MANAGEMENT_ATTR
    self.management_attr = management_panel:FindChild("Value"):GetComponent("Text")
    local renown_panel = self.gangster_info_content:FindChild("Renown")
    renown_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.FAME_ATTR
    self.renown_attr = renown_panel:FindChild("Value"):GetComponent("Text")
    local fight_panel = self.gangster_info_content:FindChild("Fight")
    fight_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.BATTLE_ATTR
    self.fight_attr = fight_panel:FindChild("Value"):GetComponent("Text")
    local hero_panel = self.gangster_info_content:FindChild("HeroCount")
    hero_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.HERO_COUNT_TEXT
    self.hero_count = hero_panel:FindChild("Value"):GetComponent("Text")
    local lover_panel = self.gangster_info_content:FindChild("LoverCount")
    lover_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.LOVER_COUNT_TEXT
    self.lover_count = lover_panel:FindChild("Value"):GetComponent("Text")
    local child_panel = self.gangster_info_content:FindChild("ChildCount")
    child_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CHILD_COUNT_TEXT
    self.child_count = child_panel:FindChild("Value"):GetComponent("Text")

    local score_info_panel = info_content:FindChild("ScoreInfo")
    local score_info_title = score_info_panel:FindChild("Title")
    score_info_title:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SCORE_INFO_TITLE
    self.score_info_state = score_info_title:FindChild("ExpandState"):GetComponent("RectTransform")
    self:AddClick(score_info_title, function ()
        self.is_expand_score_info = not self.is_expand_score_info
        self.total_fight_score_panel:SetActive(self.is_expand_score_info)
        self.score_info_state.localRotation = self.is_expand_score_info and kExpandStateRotation or kCloseStateRotation
        self.score_info_content:SetActive(self.is_expand_score_info)
    end)
    self.total_fight_score_panel = score_info_panel:FindChild("TotalScore")
    self.total_fight_score_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.TOTAL_SCORE_TEXT
    self.total_fight_score_text = self.total_fight_score_panel:FindChild("Value"):GetComponent("Text")
    self.score_info_content = score_info_panel:FindChild("Info")
    self.hero_score_item = self.score_info_content:FindChild("HeroItem")

    local assets_info_panel = info_content:FindChild("AssetsInfo")
    local assets_info_title = assets_info_panel:FindChild("Title")
    assets_info_title:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ASSETS_INFO_TITLE
    self.assets_info_state = assets_info_title:FindChild("ExpandState"):GetComponent("RectTransform")
    self:AddClick(assets_info_title, function ()
        self.is_expand_assets_info = not self.is_expand_assets_info
        self.assets_info_content:SetActive(self.is_expand_assets_info)
        self.assets_info_state.localRotation = self.is_expand_assets_info and kExpandStateRotation or kCloseStateRotation
    end)
    self.assets_info_content = assets_info_panel:FindChild("Info")
    self.info_item = self.assets_info_content:FindChild("InfoItem")
end

function PlayerDetailInfoUI:InitUI()
    self:InitBasicInfoPanel()
    self:InitGangsterInfoPanel()
    self:InitScoreInfoPanel()
    self:InitAssetsInfoPanel()
    self:ExpandDetailInfoPanel()
    self.info_content_rect_cmp.anchoredPosition = Vector2.zero
end

function PlayerDetailInfoUI:InitBasicInfoPanel()
    local role_info = ComMgrs.dy_data_mgr:ExGetMainRoleInfoData()
    local role_unit_id = SpecMgrs.data_mgr:GetRoleLookData(role_info.role_id).unit_id
    UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetUnitData(role_unit_id).icon, self.role_icon)
    self.role_name.text = role_info.name
    local vip_level = role_info.vip or 0
    self.role_vip:SetActive(vip_level > 0)
    if vip_level > 0 then UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetVipData(vip_level).icon, self.role_vip_img) end
    if not self.dy_dynasty_data:GetDynastyId() then
        self.role_dynasty.text = string.format(UIConst.Text.ROLE_DYNASTY_FORMAT, UIConst.Text.NONE)
    else
        self.dy_dynasty_data:UpdateDynastyBasicInfo(function (basic_info)
            self.role_dynasty.text = string.format(UIConst.Text.ROLE_DYNASTY_FORMAT, basic_info.dynasty_name)
        end)
    end
    self.role_score.text = string.format(UIConst.Text.GANGSTER_SCROE_FORMAT, role_info.score)
    self.role_fight_score.text = string.format(UIConst.Text.GANGSTER_FIGHT_SCROE_FORMAT, role_info.fight_score)
    self.role_level.text = role_info.level
    local level_data = SpecMgrs.data_mgr:GetLevelData(role_info.level)
    self.role_exp.fillAmount = (role_info.exp - level_data.total_exp) / level_data.exp
    self.role_exp_value.text = string.format(UIConst.Text.PER_VALUE, role_info.exp - level_data.total_exp, level_data.exp)
    self.total_score_text.text = role_info.score
    self.total_fight_score_text.text = role_info.fight_score
end

function PlayerDetailInfoUI:InitGangsterInfoPanel()
    self.total_score_panel:SetActive(self.is_expand_gangster_info)
    self.gangster_info_content:SetActive(self.is_expand_gangster_info)
    self.gangster_info_state.localRotation = kExpandStateRotation
    self.business_attr.text = ComMgrs.dy_data_mgr:ExGetAtributeValue(CSConst.RoleAttrName.Business)
    self.management_attr.text = ComMgrs.dy_data_mgr:ExGetAtributeValue(CSConst.RoleAttrName.Management)
    self.renown_attr.text = ComMgrs.dy_data_mgr:ExGetAtributeValue(CSConst.RoleAttrName.Renown)
    self.fight_attr.text = ComMgrs.dy_data_mgr:ExGetAtributeValue(CSConst.RoleAttrName.Fight)
    self.hero_count.text = self.dy_hero_data:GetOwnHeroCount()
    self.lover_count.text = #self.dy_lover_data:GetAllLoverInfo()
    self.child_count.text = self.dy_child_data:GetAllChildCount()
end

function PlayerDetailInfoUI:InitScoreInfoPanel()
    self.total_fight_score_panel:SetActive(self.is_expand_score_info)
    self.score_info_content:SetActive(self.is_expand_score_info)
    self.score_info_state.localRotation = kExpandStateRotation
    for _, lineup_data in pairs(self.dy_hero_data:GetAllLineupData()) do
        if lineup_data.hero_id and lineup_data.pos_id then
            local hero_score_item = self:GetUIObject(self.hero_score_item, self.score_info_content)
            table.insert(self.hero_score_item_list, hero_score_item)
            hero_score_item:FindChild("Name"):GetComponent("Text").text = SpecMgrs.data_mgr:GetHeroData(lineup_data.hero_id).name
            hero_score_item:FindChild("Score"):GetComponent("Text").text = self.dy_hero_data:GetHeroDataById(lineup_data.hero_id).score
        end
    end
end

function PlayerDetailInfoUI:InitAssetsInfoPanel()
    self.assets_info_content:SetActive(self.is_expand_assets_info)
    self.assets_info_state.localRotation = kExpandStateRotation
    for _, item_data in ipairs(SpecMgrs.data_mgr:GetRoleInfoItemList()) do
        local info_item = self:GetUIObject(self.info_item, self.assets_info_content)
        table.insert(self.info_item_list, info_item)
        info_item:FindChild("Name"):GetComponent("Text").text = item_data.name
        info_item:FindChild("Count"):GetComponent("Text").text = ComMgrs.dy_data_mgr:ExGetItemCount(item_data.id)
    end
end

function PlayerDetailInfoUI:ExpandDetailInfoPanel()
    if self.expanding then return end
    self.expanding = true
    self.content_pos_cmp.from_ = self.expanded and kTopPos or kBottomPos
    self.content_pos_cmp.to_ = self.expanded and kBottomPos or kTopPos
    self.content_pos_cmp:Play()
    self:AddTimer(function ()
        self.expanded = not self.expanded
        if not self.expanded then self:Hide() end
        self.expanding = false
    end, kExpandTime)
end

function PlayerDetailInfoUI:ClearHeroScoreItem()
    for _, item in ipairs(self.hero_score_item_list) do
        self:DelUIObject(item)
    end
    self.hero_score_item_list = {}
end

function PlayerDetailInfoUI:ClearInfoItem()
    for _, item in ipairs(self.info_item_list) do
        self:DelUIObject(item)
    end
    self.info_item_list = {}
end

return PlayerDetailInfoUI