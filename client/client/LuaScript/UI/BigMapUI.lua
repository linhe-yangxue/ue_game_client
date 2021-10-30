local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local BigMapUI = class("UI.BigMapUI", UIBase)

function BigMapUI:DoInit()
    BigMapUI.super.DoInit(self)
    self.prefab_path = "UI/Common/BigMapUI"
end

function BigMapUI:OnGoLoadedOk(res_go)
    BigMapUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function BigMapUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    BigMapUI.super.Show(self)
end

function BigMapUI:Hide()
    BigMapUI.super.Hide(self)
end

function BigMapUI:InitRes()
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "BigMapUI", function ()
        SpecMgrs.stage_mgr:GotoStage("MainStage")
    end)
    local game_scene_panel = self.main_panel:FindChild("GameScenePanel")

    self.secret_visit_btn = game_scene_panel:FindChild("SecretVisit")
    self.secret_visit_btn:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.SECRET_VISIT
    self:AddClick(self.secret_visit_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("SecretTravelUI")
    end)

    self.gangster_prison_btn = game_scene_panel:FindChild("GangsterPrison")
    self.gangster_prison_btn:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.GANGSTER_PRISON
    self:AddClick(self.gangster_prison_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("PrisonUI")
    end)

    self.gangster_melee_btn = game_scene_panel:FindChild("GangsterMelee")
    self.gangster_melee_btn:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.GANGSTER_MELEE
    self:AddClick(self.gangster_melee_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("StrategyMapUI")
    end)

    self.playment_entry_btn = game_scene_panel:FindChild("PlaymentEntry")
    self.playment_entry_btn:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.PLAYMENT_ENTRY
    self:AddClick(self.playment_entry_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("PlaymentEntryUI")
    end)

    self.black_boxing_btn = game_scene_panel:FindChild("BlackBoxing")
    self.black_boxing_btn:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.BLACK_BOXING
    self:AddClick(self.black_boxing_btn, function ()
        if not ComMgrs.dy_data_mgr.night_club_data:CheckHeroLineup(true) then return end
        SpecMgrs.ui_mgr:ShowUI("ArenaUI")
    end)

    self.hunting_area_btn = game_scene_panel:FindChild("HuntingArea")
    self.hunting_area_btn:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.HUNTING_AREA
    self:AddClick(self.hunting_area_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("HuntingGroundUI")
    end)

    self.rare_anima_btn = game_scene_panel:FindChild("ChallengeRareAnimalBtn")
    self.rare_anima_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CHALLENGE_RARE_ANIMAL
    self:AddClick(self.rare_anima_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("HuntingRareAnimalUI")
    end)
end

function BigMapUI:InitUI()
    self:RegisterEvent( ComMgrs.dy_data_mgr, "UpdateCurrencyEvent", function (_, currency)
        UIFuncs.UpdateCurrencyItemNum(self._item_to_text_list, currency)
    end)
    self:RegisterEvent(ComMgrs.dy_data_mgr, "LevelUpEvent", function ()
        self:UpdateChallengeRare()
    end)
    self:UpdateChallengeRare()
end

function BigMapUI:UpdateChallengeRare()
    local level = ComMgrs.dy_data_mgr:ExGetRoleLevel()
    if SpecMgrs.data_mgr:GetRareAnimalData(1).open_level <= level then
        self.rare_anima_btn:SetActive(true)
    else
        self.rare_anima_btn:SetActive(false)
    end
end

return BigMapUI