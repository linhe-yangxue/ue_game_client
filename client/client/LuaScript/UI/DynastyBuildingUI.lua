local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local UnitConst = require("Unit.UnitConst")

local DynastyBuildingUI = class("UI.DynastyBuildingUI", UIBase)

function DynastyBuildingUI:DoInit()
    DynastyBuildingUI.super.DoInit(self)
    self.prefab_path = "UI/Common/DynastyBuildingUI"
    self.dy_dynasty_data = ComMgrs.dy_data_mgr.dynasty_data
    self.defender_item_dict = {}
    self.defender_unit_dict = {}
end

function DynastyBuildingUI:OnGoLoadedOk(res_go)
    DynastyBuildingUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function DynastyBuildingUI:Hide()
    self:ClearDefenderItem()
    self:RemoveDynamicUI(self.battle_tip)
    self.mask:SetActive(false)
    DynastyBuildingUI.super.Hide(self)
end

function DynastyBuildingUI:Show(dynasty_id, building)
    self.dynasty_id = dynasty_id
    self.building = building
    if self.is_res_ok then
        self:InitUI()
    end
    DynastyBuildingUI.super.Show(self)
end

function DynastyBuildingUI:InitRes()
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "DynastyBuildingUI")

    local info_panel = self.main_panel:FindChild("InfoPanel")
    self.building_name = info_panel:FindChild("Name"):GetComponent("Text")
    local hp_bar = info_panel:FindChild("Hp")
    self.building_hp = hp_bar:FindChild("Value"):GetComponent("Image")
    self.building_hp_text = hp_bar:FindChild("Text"):GetComponent("Text")
    local reward_panel = info_panel:FindChild("RewardPanel")
    reward_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.BATTLE_REWARD_TEXT
    self.reward_text = reward_panel:FindChild("Reward"):GetComponent("Text")
    local condition_panel = info_panel:FindChild("ConditionPanel")
    condition_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.BATTLE_VICTORY_CONDITION_TEXT
    condition_panel:FindChild("Guard/Text"):GetComponent("Text").text = UIConst.Text.GUARD_CONDITION_TEXT
    condition_panel:FindChild("Defense/Text"):GetComponent("Text").text = UIConst.Text.DEFENSE_CONDITION_TEXT
    local guard_panel = self.main_panel:FindChild("GuardList")
    local lineup_btn = guard_panel:FindChild("LineupBtn")
    lineup_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.LINEUP
    self:AddClick(lineup_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("SmallLineupUI")
    end)
    self.defender_list = guard_panel:FindChild("View/Content")
    self.defender_list_rect_cmp = self.defender_list:GetComponent("RectTransform")
    self.defender_view_width = guard_panel:FindChild("View"):GetComponent("RectTransform").rect.width
    self.defender_item = self.defender_list:FindChild("GuardItem")
    self.defender_item_width = self.defender_item:GetComponent("RectTransform").rect.width
    local bottom_panel = self.main_panel:FindChild("Bottom")
    self.reward_tip = bottom_panel:FindChild("Tip/Text"):GetComponent("Text")
    local battle_info = bottom_panel:FindChild("BattleInfo")
    local battle_count_panel = battle_info:FindChild("BattleCount")
    self.battle_count = battle_count_panel:FindChild("CurCount"):GetComponent("Text")
    self:AddClick(battle_count_panel:FindChild("AddBtn"), function ()
        self.dy_dynasty_data:SendBuyBattleCount()
    end)
    self.battle_tip = battle_info:FindChild("BattleTip")
    self.battle_tip_text = self.battle_tip:GetComponent("Text")
    self.mask = self.main_panel:FindChild("Mask")
end

function DynastyBuildingUI:InitUI()
    if not self.building or not self.dynasty_id then
        self:Hide()
        return
    end
    self.dy_dynasty_data:UpdateDynastyBattleData()
    self:InitBuildingInfo()
    self:InitDefenderList()
    self:RegisterEvent(self.dy_dynasty_data, "UpdateDynastyBattleInfoEvent", function ()
        if self.dy_dynasty_data:CheckBuildingIsDestroyed(self.dynasty_id, self.building) then
            self:Hide()
            return
        end
        self:UpdateBuildingInfo()
        self:UpdateDefenderList()
    end)
    self:RegisterEvent(self.dy_dynasty_data, "DynastyBattleEndEvent", function ()
        self:Hide()
    end)
end

function DynastyBuildingUI:InitBuildingInfo()
    self.building_data = SpecMgrs.data_mgr:GetDynastyBuildingData(self.building)
    self.building_name.text = string.format(UIConst.Text.SIMPLE_COLOR, self.building_data.color, self.building_data.name)
    self.reward_text.text = string.format(UIConst.Text.ATTACK_BUILDING_REWARD, self.building_data.dynasty_exp_reward)
    self.dy_dynasty_data:UpdateDynastyBasicInfo(function (base_info)
        self.reward_tip.text = string.format(UIConst.Text.ATTACK_BUILDING_TIP, self.building_data.win_hp, self.building_data["dedicate_" .. base_info.dynasty_level])
    end)
    local battle_end_time = Time:GetServerTime() - Time:GetCurDayPassTime() + CSConst.Time.Day
    self:AddDynamicUI(self.battle_tip, function ()
        self.battle_tip_text.text = string.format(UIConst.Text.ROUND_END_TIP, UIFuncs.TimeDelta2Str(battle_end_time - Time:GetServerTime()))
    end, 1, 0)
    self:UpdateBuildingInfo()
end

function DynastyBuildingUI:UpdateBuildingInfo()
    self.building_info = self.dy_dynasty_data:GetDynastyCompetitorInfo(self.dynasty_id).building_dict[self.building]
    self.building_hp.fillAmount = self.building_info.building_hp / self.building_data.building_hp
    self.building_hp_text.text = string.format(UIConst.Text.PER_VALUE, self.building_info.building_hp, self.building_data.building_hp)
    self.battle_count.text = string.format(UIConst.Text.REST_DYNASTY_BATTLE_COUNT, self.dy_dynasty_data:GetDynastyBattleAttackCount())
end

function DynastyBuildingUI:InitDefenderList()
    local building_data = SpecMgrs.data_mgr:GetDynastyBuildingData(self.building)
    local defender_list = self.dy_dynasty_data:GetDynastyBuildingDefenderList(self.dynasty_id, self.building)
    for _, defender_info in ipairs(defender_list) do
        local defender_item = self:GetUIObject(self.defender_item, self.defender_list)
        self.defender_item_dict[defender_info.uuid] = defender_item
        local info = defender_item:FindChild("Info")
        info:FindChild("Name/Text"):GetComponent("Text").text = defender_info.role_name
        info:FindChild("Score"):GetComponent("Text").text = string.format(UIConst.Text.SCORE_FORMAT_TEXT, defender_info.fight_score)
        info:FindChild("DefendCount"):GetComponent("Text").text = string.format(UIConst.Text.DEFEND_COUNT_FORMAT, defender_info.defend_num)
        local role_data = SpecMgrs.data_mgr:GetRoleLookData(defender_info.role_id)
        local defender_model = defender_item:FindChild("GuardModel")
        self:AddClick(defender_model, function ()
            self.dy_dynasty_data:UpdateDynastyBattleData(function ()
                self:SendDynastyCompeteFight(defender_info)
            end)
        end)
        local defender_unit = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = role_data.unit_id, parent = defender_model})
        defender_unit:SetPositionByRectName({parent = defender_model, name = UnitConst.UnitRect.Full})
        if defender_info.defend_num == 0 then
            defender_unit:ChangeToGray()
            defender_unit:StopAllAnimationToCurPos()
        end
        self.defender_unit_dict[defender_info.uuid] = defender_unit
    end
    self.defender_list_rect_cmp.anchoredPosition = Vector2.New((math.max(0, self.defender_item_width * building_data.defend_member_count - self.defender_view_width)) / 2, 0)
end

function DynastyBuildingUI:UpdateDefenderList()
    local defender_list = self.dy_dynasty_data:GetDynastyBuildingDefenderList(self.dynasty_id, self.building)
    for i, defender_info in ipairs(defender_list) do
        local defender_item = self.defender_item_dict[defender_info.uuid]
        local info = defender_item:FindChild("Info")
        info:FindChild("DefendCount"):GetComponent("Text").text = string.format(UIConst.Text.DEFEND_COUNT_FORMAT, defender_info.defend_num)
        local defender_unit = self.defender_unit_dict[defender_info.uuid]
        if defender_info.defend_num == 0 then
            defender_unit:ChangeToGray()
            defender_unit:StopAllAnimationToCurPos()
        end
        defender_item:SetSiblingIndex(i)
    end
end

-- msg
function DynastyBuildingUI:SendDynastyCompeteFight(defender_info)
    if not ComMgrs.dy_data_mgr.night_club_data:CheckHeroLineup(true) then return end
    if self.dy_dynasty_data:GetDynastyBattleAttackCount() <= 0 then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.ATTACK_COUNT_LIMIT)
        return
    end
    self.mask:SetActive(true)
    self.dy_dynasty_data:UpdateDynastyBasicInfo(function (base_info)
        SpecMgrs.msg_mgr:SendMsg("SendDynastyCompeteFight", {dynasty_id = self.dynasty_id, building_id = self.building, uuid = defender_info.uuid}, function (resp)
            self.mask:SetActive(false)
            if resp.errcode ~= 0 and resp.tips_id then
                local tip_str = UIConst.DynastyBattleErrorTips[resp.tips_id]
                if tip_str then SpecMgrs.ui_mgr:ShowTipMsg(tip_str) end
            end
            if resp.errcode == 0 then
                self.dy_dynasty_data:SetDynastyBattleState(true)
                if not resp.fight_data then return end
                SpecMgrs.ui_mgr:EnterHeroBattle(resp.fight_data, UIConst.BattleScence.DynastyBuildingUI)
                SpecMgrs.ui_mgr:RegiseHeroBattleEnd("DynastyBuildingUI", function()
                    self:BattleEnd(resp, base_info.dynasty_level, defender_info.role_name)
                end)
            end
        end)
    end)
end

function DynastyBuildingUI:BattleEnd(resp, dynasty_level, name)
    local reward_dict = {}
    reward_dict[CSConst.Virtual.Dedicate] = math.floor(self.building_data["dedicate_" .. dynasty_level] * (resp.is_win and 1 or self.building_data.fail_reward_ratio))
    local win_tip
    if resp.is_destroy_building then
        local building_name = string.format(UIConst.Text.SIMPLE_COLOR, self.building_data.color, self.building_data.name)
        win_tip = string.format(UIConst.Text.DESTROY_BUILDING_TEXT, name, building_name, self.building_data.dynasty_exp_reward)
    elseif resp.is_win then
        win_tip = string.format(UIConst.Text.DEFEAT_DEFENDER_TEXT, name)
    else
        win_tip = string.format(UIConst.Text.BATTLE_FAILED_TEXT, name)
    end
    local param_tb = {
        is_win = resp.is_destroy_building or resp.is_win,
        reward = reward_dict,
        win_tip = win_tip,
        func = function ()
            self.dy_dynasty_data:SetDynastyBattleState(false)
        end,
    }
    SpecMgrs.ui_mgr:AddCloseBattlePopUpList("BattleResultUI", param_tb)
end

function DynastyBuildingUI:ClearDefenderItem()
    for _, unit in pairs(self.defender_unit_dict) do
        ComMgrs.unit_mgr:DestroyUnit(unit)
    end
    self.defender_unit_dict = {}
    for _, item in pairs(self.defender_item_dict) do
        self:DelUIObject(item)
    end
    self.defender_item_dict = {}
end

return DynastyBuildingUI