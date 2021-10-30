local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local DynastyBattleReportUI = class("UI.DynastyBattleReportUI", UIBase)

function DynastyBattleReportUI:DoInit()
    DynastyBattleReportUI.super.DoInit(self)
    self.prefab_path = "UI/Common/DynastyBattleReportUI"
    self.dynasty_compete_fight_day = SpecMgrs.data_mgr:GetParamData("dynasty_compete_fight_day").tb_string
    self.dynasty_battle_start_time = SpecMgrs.data_mgr:GetParamData("dynasty_compete_start_time").f_value
    self.dy_dynasty_data = ComMgrs.dy_data_mgr.dynasty_data
    self.defend_item_list = {}
end

function DynastyBattleReportUI:OnGoLoadedOk(res_go)
    DynastyBattleReportUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function DynastyBattleReportUI:Hide()
    DynastyBattleReportUI.super.Hide(self)
end

function DynastyBattleReportUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    DynastyBattleReportUI.super.Show(self)
end

function DynastyBattleReportUI:InitRes()
    local content = self.main_panel:FindChild("Content")
    content:FindChild("Title"):GetComponent("Text").text = UIConst.Text.LAST_BATTLE_REPORT
    self:AddClick(content:FindChild("CloseBtn"), function ()
        self:Hide()
        local dynasty_battle_ui = SpecMgrs.ui_mgr:GetUI("DynastyBattleUI")
        if dynasty_battle_ui then dynasty_battle_ui:Hide() end
    end)
    self.battle_tip = content:FindChild("Tip/Text"):GetComponent("Text")
    local dynasty_report_panel = content:FindChild("DynastyReport")
    self.dynasty_badge = dynasty_report_panel:FindChild("Badge"):GetComponent("Image")
    local total_score_panel = dynasty_report_panel:FindChild("TotalScore")
    total_score_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_TOTAL_SCORE
    self.dynasty_total_score = total_score_panel:FindChild("Value"):GetComponent("Text")
    local attack_score_panel = dynasty_report_panel:FindChild("AttackScore")
    attack_score_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.LAST_ATTACK_SCORE
    self.dynasty_attack_score = attack_score_panel:FindChild("Value"):GetComponent("Text")
    local defend_score_panel = dynasty_report_panel:FindChild("DefendScore")
    defend_score_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.LAST_DEFEND_SCORE
    self.dynasty_defend_score = defend_score_panel:FindChild("Value/Text"):GetComponent("Text")
    self:AddClick(defend_score_panel:FindChild("Value/InfoBtn"), function ()
        self.defend_info_panel:SetActive(true)
    end)
    self.reward_text = dynasty_report_panel:FindChild("Reward"):GetComponent("Text")
    local personal_report_panel = content:FindChild("PersonalReport")
    self.personal_icon = personal_report_panel:FindChild("IconBg/Icon"):GetComponent("Image")
    self.personal_name = personal_report_panel:FindChild("Name"):GetComponent("Text")
    local personal_last_score_panel = personal_report_panel:FindChild("LastScore")
    personal_last_score_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.LAST_BATTLE_SCORE
    self.personal_last_score = personal_last_score_panel:FindChild("Value"):GetComponent("Text")
    local personal_total_score_panel = personal_report_panel:FindChild("TotalScore")
    personal_total_score_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.TOTAL_BATTLE_SCORE
    self.personal_total_score = personal_total_score_panel:FindChild("Value"):GetComponent("Text")
    self.next_battle_tip = content:FindChild("BottomPanel/Text"):GetComponent("Text")

    self.defend_info_panel = self.main_panel:FindChild("DefendInfo")
    local defend_info_content = self.defend_info_panel:FindChild("Panel")
    local top_panel = defend_info_content:FindChild("Top")
    top_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DEFEND_SCORE_TITLE
    self:AddClick(top_panel:FindChild("CloseBtn"), function ()
        self.defend_info_panel:SetActive(false)
    end)
    local info_list = defend_info_content:FindChild("InfoList")
    for i = 1, CSConst.DynastyBattleCompetiorCount do
        self.defend_item_list[i] = info_list:FindChild("InfoItem" .. i)
    end
    self.defend_score = defend_info_content:FindChild("Bottom/Text"):GetComponent("Text")
end

function DynastyBattleReportUI:InitUI()
    self.dy_dynasty_data:UpdateDynastyBattleData(function ()
        self:InitBaseInfo()
        self:InitDefendInfo()
    end)
end

function DynastyBattleReportUI:InitBaseInfo()
    local cur_round
    local cur_day = Time:GetServerWeekDay()
    for i, day in ipairs(self.dynasty_compete_fight_day) do
        if cur_day == tonumber(day) then
            cur_round = i
            break
        end
    end
    self.battle_tip.text = cur_round and string.format(UIConst.Text.BATTLE_END_REPORT_FORMAT, cur_round) or UIConst.Text.LAST_BATTLE_END_TITLE
    self.dy_dynasty_data:UpdateDynastyBasicInfo(function (base_info)
        UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetDynastyBadgeData(base_info.dynasty_badge).icon, self.dynasty_badge)
    end)
    local battle_score_dict = self.dy_dynasty_data:GetDynastyBattleScore()
    self.dynasty_total_score.text = battle_score_dict.dynasty_total_score
    self.dynasty_attack_score.text = battle_score_dict.pre_attack_score
    self.dynasty_defend_score.text = battle_score_dict.pre_defend_score
    self.reward_text.text = string.format(UIConst.Text.DYNASTY_BATTLE_REWARD, self.dy_dynasty_data:CalcDynastyExpReward())
    local role_data = SpecMgrs.data_mgr:GetRoleLookData(ComMgrs.dy_data_mgr:ExGetRoleId())
    UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetUnitData(role_data.unit_id).icon, self.personal_icon)
    self.personal_name.text = ComMgrs.dy_data_mgr:ExGetRoleName()
    self.personal_last_score.text = battle_score_dict.personal_daily_score
    self.personal_total_score.text = battle_score_dict.personal_total_score
    self.next_battle_tip.text = string.format(UIConst.Text.NEXT_BATTLE_TIP, UIConst.Text.NUMBER_TEXT[tonumber(self.dynasty_compete_fight_day[cur_round or 1])], self.dynasty_battle_start_time)

    self.defend_score.text = string.format(UIConst.Text.DYNASTY_DEFEND_SCORE, battle_score_dict.pre_defend_score)
end

function DynastyBattleReportUI:InitDefendInfo()
    for i, building_defend_info in ipairs(self.dy_dynasty_data:GetDynastyDefendInfo()) do
        local defend_item = self.defend_item_list[i]
        defend_item:FindChild("Name/Text"):GetComponent("Text").text = building_defend_info.dynasty_name
        for building_id, building_data in ipairs(SpecMgrs.data_mgr:GetAllDynastyBuildingData()) do
            local building = defend_item:FindChild("Building" .. building_id)
            building:FindChild("Name"):GetComponent("Text").text = building_data.name
            local defend_num = building_defend_info.building_dict[building_id]
            building:FindChild("Info"):GetComponent("Text").text = string.format(UIConst.Text.DEFEND_INFO_FORMAT, defend_num, defend_num * building_data.defend_param)
        end
    end
end

return DynastyBattleReportUI