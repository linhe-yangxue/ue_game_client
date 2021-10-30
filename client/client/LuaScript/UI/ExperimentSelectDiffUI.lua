local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local FConst = require("CSCommon.Fight.FConst")
local EventUtil = require("BaseUtilities.EventUtil")
local ExperimentSelectDiffUI = class("UI.ExperimentSelectDiffUI",UIBase)

EventUtil.GeneratorEventFuncs(ExperimentSelectDiffUI, "BattleEnd")

local diff_count = 3

--  试炼选择难度
function ExperimentSelectDiffUI:DoInit()
    ExperimentSelectDiffUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ExperimentSelectDiffUI"
end

function ExperimentSelectDiffUI:OnGoLoadedOk(res_go)
    ExperimentSelectDiffUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function ExperimentSelectDiffUI:Show(stage_id, is_curr_stage)
    self.stage_id = stage_id
    self.is_curr_stage = is_curr_stage
    if self.is_res_ok then
        self:InitUI()
    end
    ExperimentSelectDiffUI.super.Show(self)
end

function ExperimentSelectDiffUI:InitRes()
    self.title = self.main_panel:FindChild("Frame/Title"):GetComponent("Text")
    self.show_small_lineup_btn = self.main_panel:FindChild("Frame/ShowSmallLineupBtn")
    self:AddClick(self.show_small_lineup_btn, function()
        SpecMgrs.ui_mgr:ShowUI("SmallLineupUI")
    end)
    self.show_small_lineup_btn_text = self.main_panel:FindChild("Frame/ShowSmallLineupBtn/ShowSmallLineupBtnText"):GetComponent("Text")
    self.clearance_condition_text = self.main_panel:FindChild("Frame/ClearanceConditionText"):GetComponent("Text")
    self.close_btn = self.main_panel:FindChild("Frame/CloseBtn")
    self:AddClick(self.close_btn, function()
        self:Hide()
    end)
    self.monster_name_text = self.main_panel:FindChild("Frame/MonsterNameText"):GetComponent("Text")
    self.select_diff_text = self.main_panel:FindChild("Frame/SelectDiffText"):GetComponent("Text")
    self.diff_grid = self.main_panel:FindChild("Frame/DiffGrid"):GetComponent("Text")
    self.unit_point = self.main_panel:FindChild("Frame/UnitPoint")
    self.talk_parent = self.main_panel:FindChild("Frame/TalkParent")
    self.diff_mes_obj_list = {}
    for i = 1, diff_count do
        table.insert(self.diff_mes_obj_list, self.main_panel:FindChild("Frame/DiffGrid/DiffMes" .. i))
    end
end

function ExperimentSelectDiffUI:InitUI()
    self:SetTextVal()
    self:UpdateData()
    self:UpdateUIInfo()
end

function ExperimentSelectDiffUI:UpdateData()
    self.stage_data = SpecMgrs.data_mgr:GetTrainData(self.stage_id)
end

function ExperimentSelectDiffUI:UpdateUIInfo()
    local unit_name = SpecMgrs.data_mgr:GetUnitData(self.stage_data.show_role).name
    local stage_name = string.format(self.stage_data.name, self.stage_data.id)
    self.title.text = string.format(UIConst.Text.SPACE_FORMAT, stage_name, unit_name)
    local str = SpecMgrs.data_mgr:GetVictoryData(self.stage_data.victory_id).str_list[1]
    self.clearance_condition_text.text = string.format(UIConst.Text.CLEARANCE_FORMAT, str)
    self.monster_name_text.text = unit_name

    for i, diff_mes in ipairs(self.diff_mes_obj_list) do
        self:AddClick(diff_mes:FindChild("ChallengeBtn"), function()
            if not self.is_curr_stage then
                SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.NOT_CURRENT_STAGE)
                return
            end
            local last_all_star = ComMgrs.dy_data_mgr.experiment_data.experiment_msg.layer_all_star
            local callback = function(resp)
                if not ComMgrs.dy_data_mgr.night_club_data:CheckHeroLineup(true) then return end
                self:Hide()
                ComMgrs.dy_data_mgr.experiment_data:SetCurLayerReward(resp.layer_reward)
                ComMgrs.dy_data_mgr.experiment_data:SetLastLayerStar(last_all_star + i)
                SpecMgrs.ui_mgr:EnterHeroBattle(resp.fight_data, UIConst.BattleScence.ExperimentUI)

                local reward_dict
                if resp.is_win then
                    reward_dict = resp.reward_dict
                    for k, v in pairs(reward_dict) do
                        if v.crit then
                            local crit_data = SpecMgrs.data_mgr:GetTrainCritData(v.crit)
                            v.tip = string.format(UIConst.Text.CRIT_FORMAT, crit_data.show_color, crit_data.name)
                        end
                    end
                end
                SpecMgrs.ui_mgr:RegiseHeroBattleEnd("ExperimentSelectDiffUI", function()
                    local is_win = resp.is_win
                    local param_tb = {
                        is_win = is_win,
                        reward = is_win and reward_dict,
                        win_tip = is_win and UIConst.Text.BATTLE_WIN_TIP_TEXT,
                    }
                    SpecMgrs.ui_mgr:AddCloseBattlePopUpList("BattleResultUI", param_tb)
                end)
                SpecMgrs.ui_mgr:RegisterHeroBattleUIClose("ExperimentSelectDiffUI", function()
                    self:DispatchBattleEnd()
                end)
            end
            SpecMgrs.msg_mgr:SendMsg("SendTrainChallengeStage", {difficulty = i}, callback)
        end)
        diff_mes:FindChild("ChallengeBtn/ChallengeBtnText"):GetComponent("Text").text = UIConst.Text.CHALLENGE_TEXT
        self:SetTextPic(diff_mes:FindChild("RewardStarText"), string.format(UIConst.Text.CAN_GET_STAR_FORMAT, self.stage_data.star_num_list[i]))

        local reward_data = SpecMgrs.data_mgr:GetRewardData(self.stage_data.reward_list[i])
        local reward_item_list = reward_data.reward_item_list
        local reward_num_list = reward_data.reward_num_list

        self:SetTextPic(diff_mes:FindChild("RewardObjText1"), self:GetItemNumStr(reward_item_list[1], reward_num_list[1]))
        self:SetTextPic(diff_mes:FindChild("RewardObjText2"), self:GetItemNumStr(reward_item_list[2], reward_num_list[2]))
        diff_mes:FindChild("BattlePointText"):GetComponent("Text").text = string.format(UIConst.Text.MILITARY_VAL_FROMAL, self.stage_data.score_list[i])
    end
    local unit = self:AddHalfUnit(self.stage_data.show_role, self.unit_point)

    local length = #SpecMgrs.data_mgr:GetAllTrainTalkData()
    local talk_str = SpecMgrs.data_mgr:GetTrainTalkData(math.random(1, length)).talk
    self.talk = self:GetTalkCmp(self.talk_parent, 1, false, function ()
        return talk_str
    end)
end

function ExperimentSelectDiffUI:GetItemNumStr(item_id, num)
    local icon_id = SpecMgrs.data_mgr:GetItemData(item_id).icon
    return string.format(UIConst.Text.SMALL_ITEM_ICON_NUM_FORMAT, icon_id, num)
end

function ExperimentSelectDiffUI:SetTextVal()
    self.select_diff_text.text = string.format(UIConst.Text.SELECT_DIFF_TEXT)
end

function ExperimentSelectDiffUI:Hide()
    self:DelAllCreateUIObj()
    self:RemoveAllUIEffect()
    if self.talk then self.talk:DoDestroy() end
    ExperimentSelectDiffUI.super.Hide(self)
end

return ExperimentSelectDiffUI
