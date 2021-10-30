local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local FConst = require("CSCommon.Fight.FConst")
local DaliyBattleChooseLevelUI = class("UI.DaliyBattleChooseLevelUI",UIBase)

-- 日常挑战选择难度
function DaliyBattleChooseLevelUI:DoInit()
    DaliyBattleChooseLevelUI.super.DoInit(self)
    self.prefab_path = "UI/Common/DaliyBattleChooseLevelUI"
end

function DaliyBattleChooseLevelUI:OnGoLoadedOk(res_go)
    DaliyBattleChooseLevelUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function DaliyBattleChooseLevelUI:Show(dare_data, dare_info)
    self.dare_data = dare_data
    self.dare_info = dare_info
    if self.is_res_ok then
        self:InitUI()
    end
    DaliyBattleChooseLevelUI.super.Show(self)
end

function DaliyBattleChooseLevelUI:InitRes()
    self.close_button = self.main_panel:FindChild("Frame/StageChestCloseButton")
    self:AddClick(self.close_button, function()
        self:Hide()
    end)
    self.content = self.main_panel:FindChild("Frame/Scroll View/Viewport/Content")
    self.title = self.main_panel:FindChild("Frame/Title"):GetComponent("Text")
    self.map_level = self.main_panel:FindChild("Frame/Scroll View/Viewport/Content/MapLevel")

    self.map_level:SetActive(false)
end

function DaliyBattleChooseLevelUI:InitUI()
    self:SetTextVal()
    self:UpdateData()
    self:UpdateUIInfo()
end

function DaliyBattleChooseLevelUI:UpdateData()

end

function DaliyBattleChooseLevelUI:UpdateUIInfo()
    for i, v in ipairs(self.dare_data.difficult_list) do
        local obj = self:GetUIObject(self.map_level, self.content)
        if self.dare_info.difficult_list[i] then
            self:SetSelectDifficultyPanel(obj, i, false)
        else
            self:SetSelectDifficultyPanel(obj, i, true)
        end
    end
end

function DaliyBattleChooseLevelUI:SetTextVal()
    self.title.text = UIConst.Text.SELECT_DIFF_TEXT
end

function DaliyBattleChooseLevelUI:SetSelectDifficultyPanel(panel, index, is_lock)
    local level_image = panel:FindChild("LevelImage"):GetComponent("Image")
    local challenge_button = panel:FindChild("ChallengeButton")

    self:AddClick(challenge_button, function()
        if not ComMgrs.dy_data_mgr.night_club_data:CheckHeroLineup(true) then return end
        SpecMgrs.msg_mgr:SendMsg(
        "SendDailyDarefight", {dare_id = self.dare_data.dare_id, difficult_id = self.dare_data.difficult_list[index]}, function (resp)
            if resp.errcode == 0 then
                if self.is_res_ok then
                    self:Hide()
                end
                local param_tb = {
                    is_win = resp.is_win,
                    reward = resp.is_win and {[self.dare_data.drop_item] = self.dare_data.drop_item_count[index]},
                }
                SpecMgrs.ui_mgr:EnterHeroBattle(resp.fight_data, UIConst.BattleScence.DaliyBattleUI)
                SpecMgrs.ui_mgr:RegiseHeroBattleEnd("DaliyBattleChooseLevelUI", function()
                    SpecMgrs.ui_mgr:AddCloseBattlePopUpList("BattleResultUI", param_tb)
                end)
            end
        end)
    end)
    local challenge_button_text = panel:FindChild("ChallengeButton/ChallengeButtonText")
    local recommend_text = panel:FindChild("RecommendText")
    local unlock_text = panel:FindChild("UnlockText")
    local difficult_level = self.dare_data.difficult_list[index]
    local icon_id = SpecMgrs.data_mgr:GetDareDifficultData(difficult_level).icon

    UIFuncs.AssignSpriteByIconID(icon_id, level_image)

    local count = self.dare_data.drop_item_count[index]

    UIFuncs.SetItem(self, self.dare_data.drop_item, count, panel:FindChild("RewardItem"))
    challenge_button:FindChild("ChallengeButtonText"):GetComponent("Text").text = UIConst.Text.CHALLENGE_TEXT
    if is_lock then
        unlock_text:SetActive(true)
        recommend_text:SetActive(false)
        challenge_button:SetActive(false)
        unlock_text:GetComponent("Text").text = string.format(UIConst.Text.LEVEL_LOCK_FORMAT, self.dare_data.open_level[index])
    else
        unlock_text:SetActive(false)
        recommend_text:SetActive(true)
        challenge_button:SetActive(true)
        recommend_text:GetComponent("Text").text = string.format(UIConst.Text.RECOMMEND_COMAT_FORMAT, self.dare_data.suggest_power[index])
    end
end

function DaliyBattleChooseLevelUI:Hide()
    self:DelAllCreateUIObj()
    DaliyBattleChooseLevelUI.super.Hide(self)
end

return DaliyBattleChooseLevelUI
