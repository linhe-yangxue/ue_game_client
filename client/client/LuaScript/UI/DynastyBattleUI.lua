local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local DynastyBattleUI = class("UI.DynastyBattleUI", UIBase)

function DynastyBattleUI:DoInit()
    DynastyBattleUI.super.DoInit(self)
    self.prefab_path = "UI/Common/DynastyBattleUI"
    self.dy_dynasty_data = ComMgrs.dy_data_mgr.dynasty_data
    self.competite_dynasty_list = {}
end

function DynastyBattleUI:OnGoLoadedOk(res_go)
    DynastyBattleUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function DynastyBattleUI:Hide()
    self:RemoveDynamicUI(self.battle_tip)
    DynastyBattleUI.super.Hide(self)
end

function DynastyBattleUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    DynastyBattleUI.super.Show(self)
end

function DynastyBattleUI:InitRes()
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "DynastyBattleUI")

    local info_panel = self.main_panel:FindChild("InfoPanel")
    local info_content = info_panel:FindChild("Info")
    local dynasty_total_score_panel = info_content:FindChild("DynastyRecord")
    dynasty_total_score_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_TOTAL_SCORE
    self.dynasty_total_score = dynasty_total_score_panel:FindChild("Value"):GetComponent("Text")
    local personal_total_score_panel = info_content:FindChild("MemberTotalRecord")
    personal_total_score_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.PERSONAL_TOTAL_SCORE
    self.personal_total_score = personal_total_score_panel:FindChild("Value"):GetComponent("Text")
    local personal_daily_score_panel = info_content:FindChild("MemberDailyRecord")
    personal_daily_score_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.PERSONAL_TODAY_SCORE
    self.personal_daily_score = personal_daily_score_panel:FindChild("Value"):GetComponent("Text")
    local battle_count_panel = info_content:FindChild("BattleCount")
    battle_count_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_BATTLE_COUNT
    self.battle_count = battle_count_panel:FindChild("Value"):GetComponent("Text")
    local rank_btn = info_panel:FindChild("RankBtn")
    rank_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.RANK_LIST_TEXT
    self:AddClick(rank_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("DynastyRankListUI", CSConst.DynastyBattleRankListCode.DynastyRank)
    end)
    local reward_btn = info_panel:FindChild("RewardBtn")
    reward_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.BATTLE_REWARD_TEXT
    self:AddClick(reward_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("DynastyBattleRewardUI")
    end)
    self.situation_btn = info_panel:FindChild("SituationBtn")
    self.situation_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.VIEW_BATTLE_TEXT
    self:AddClick(self.situation_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("ViewBattleUI")
    end)

    local self_dynasty = self.main_panel:FindChild("SelfDynasty")
    self.self_dynasty_name = self_dynasty:FindChild("Name/Text"):GetComponent("Text")
    self.self_dynasty_server = self_dynasty:FindChild("Server"):GetComponent("Text")
    for i = 1, CSConst.DynastyBattleCompetiorCount do
        local dynasty_item = self.main_panel:FindChild("Dynasty" .. i)
        self:AddClick(dynasty_item:FindChild("Btn"), function ()
            SpecMgrs.ui_mgr:ShowUI("DynastyStationUI", self.dy_dynasty_data:GetDynastyBattleEnemyList()[i].dynasty_id)
        end)
        self:AddClick(dynasty_item:FindChild("Disable"), function ()
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.DYNASTY_DEFEAT_TEXT)
        end)
        self.competite_dynasty_list[i] = dynasty_item
    end

    local bottom_panel = self.main_panel:FindChild("Bottom")
    local battle_count_panel = bottom_panel:FindChild("BattleCount")
    self.cur_battle_count = battle_count_panel:FindChild("CurCount"):GetComponent("Text")
    self:AddClick(battle_count_panel:FindChild("AddBtn"), function ()
        self.dy_dynasty_data:SendBuyBattleCount()
    end)
    self.battle_tip = bottom_panel:FindChild("BattleTip")
    self.battle_tip_text = self.battle_tip:GetComponent("Text")
end

function DynastyBattleUI:InitUI()
    local battle_end_time = Time:GetServerTime() - Time:GetCurDayPassTime() + CSConst.Time.Day
    self:AddDynamicUI(self.battle_tip, function ()
        self.battle_tip_text.text = string.format(UIConst.Text.ROUND_END_TIP, UIFuncs.TimeDelta2Str(battle_end_time - Time:GetServerTime()))
    end, 1, 0)
    self.battle_end_timer = self:AddTimer(function ()
        self.dy_dynasty_data:NotifyDynastyBattleClosed()
        self.battle_end_timer = nil
    end, battle_end_time - Time:GetServerTime())
    self.dy_dynasty_data:UpdateDynastyBattleData(function ()
        self:InitBaseInfoPanel()
        self:InitDynastyBuilding()
        self:UpdateDynastyBuilding()
    end)
    self:RegisterEvent(self.dy_dynasty_data, "UpdateDynastyBattleInfoEvent", function ()
        self:InitBaseInfoPanel()
        self:UpdateDynastyBuilding()
    end)
    self.dy_dynasty_data:UpdateDynastyBasicInfo(function (base_info)
        self.self_dynasty_name.text = base_info.dynasty_name
        local server_data = SpecMgrs.data_mgr:GetServerData(ComMgrs.dy_data_mgr:ExGetServerId())
        local partition_data = SpecMgrs.data_mgr:GetPartitionData(server_data.partition)
        self.self_dynasty_server.text = string.format(UIConst.Text.SERVER_FORMAT, partition_data.area, server_data.id)
    end)
end

function DynastyBattleUI:InitBaseInfoPanel()
    local score_dict = self.dy_dynasty_data:GetDynastyBattleScore()
    self.dynasty_total_score.text = score_dict.dynasty_total_score
    self.personal_total_score.text = score_dict.personal_total_score
    self.personal_daily_score.text = score_dict.personal_daily_score
    self.battle_count.text = score_dict.battle_count
    self.cur_battle_count.text = string.format(UIConst.Text.REST_DYNASTY_BATTLE_COUNT, self.dy_dynasty_data:GetDynastyBattleAttackCount())
end

function DynastyBattleUI:InitDynastyBuilding()
    for i, enemy_info in ipairs(self.dy_dynasty_data:GetDynastyBattleEnemyList()) do
        local dynasty_item = self.competite_dynasty_list[i]
        dynasty_item:FindChild("Disable/Name/Text"):GetComponent("Text").text = enemy_info.dynasty_name
        dynasty_item:FindChild("Btn/Name/Text"):GetComponent("Text").text = enemy_info.dynasty_name
        local server_data = SpecMgrs.data_mgr:GetServerData(enemy_info.server_id)
        local partition_data = SpecMgrs.data_mgr:GetPartitionData(server_data.partition)
        dynasty_item:FindChild("Server"):GetComponent("Text").text = string.format(UIConst.Text.SERVER_FORMAT, partition_data.area, enemy_info.server_id)
    end
end

function DynastyBattleUI:UpdateDynastyBuilding()
    for i, enemy_info in ipairs(self.dy_dynasty_data:GetDynastyBattleEnemyList()) do
        local dynasty_item = self.competite_dynasty_list[i]
        local hp_bar = dynasty_item:FindChild("Hp")
        local is_destroy = self.dy_dynasty_data:CheckDynastyIsDestroyed(enemy_info.dynasty_id)
        hp_bar:SetActive(not is_destroy)
        dynasty_item:FindChild("Btn"):SetActive(not is_destroy)
        dynasty_item:FindChild("Disable"):SetActive(is_destroy)
        if not is_destroy then
            local cur_hp = self.dy_dynasty_data:CalcDynastyHp(enemy_info.dynasty_id)
            local max_hp = self.dy_dynasty_data:GetDynastyBattleMaxHp()
            dynasty_item:FindChild("Hp/Value"):GetComponent("Image").fillAmount = cur_hp / max_hp
            dynasty_item:FindChild("Hp/Text"):GetComponent("Text").text = string.format(UIConst.Text.PER_VALUE, cur_hp, max_hp)
        end
    end
end

return DynastyBattleUI