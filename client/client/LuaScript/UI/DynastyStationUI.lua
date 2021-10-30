local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local DynastyStationUI = class("UI.DynastyStationUI", UIBase)

function DynastyStationUI:DoInit()
    DynastyStationUI.super.DoInit(self)
    self.prefab_path = "UI/Common/DynastyStationUI"
    self.dy_dynasty_data = ComMgrs.dy_data_mgr.dynasty_data
    self.dynasty_battle_start_time = SpecMgrs.data_mgr:GetParamData("dynasty_compete_start_time").f_value * CSConst.Time.Hour
    self.dynasty_battle_apply_day = SpecMgrs.data_mgr:GetParamData("dynasty_compete_apply_day").f_value
    self.dynasty_battle_fight_day = SpecMgrs.data_mgr:GetParamData("dynasty_compete_fight_day").day_dict
    self.dynasty_compete_apply_member_count = SpecMgrs.data_mgr:GetParamData("dynasty_compete_apply_member_count").f_value
    self.building_item_dict = {}
    self.deploy_member_item_list = {}
end

function DynastyStationUI:OnGoLoadedOk(res_go)
    DynastyStationUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function DynastyStationUI:Hide()
    local dynasty_battle_report_ui = SpecMgrs.ui_mgr:GetUI("DynastyBattleReportUI")
    if dynasty_battle_report_ui then
        dynasty_battle_report_ui:Hide()
    end
    self.cur_building = nil
    self:RemoveDynamicUI(self.battle_tip)
    self:RemoveUpdateCountDownTimer()
    self:ClearDeployMemberItem()
    DynastyStationUI.super.Hide(self)
end

function DynastyStationUI:Show(dynasty_id)
    self.dynasty_id = dynasty_id
    if dynasty_id then
        self:_Show()
    else
        self:CheckDynastyBattleState()
    end
end

function DynastyStationUI:_Show()
    if self.is_res_ok then
        self:InitUI()
    end
    DynastyStationUI.super.Show(self)
end

function DynastyStationUI:InitRes()
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "DynastyStationUI")

    local info_panel = self.main_panel:FindChild("InfoPanel")
    self.name = info_panel:FindChild("Info/Name/Text"):GetComponent("Text")
    local info_content = info_panel:FindChild("Info/InfoList")
    self.hp_panel = info_content:FindChild("Hp")
    self.hp_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.HP_FORMAT
    local hp_bar = self.hp_panel:FindChild("HpBar")
    self.hp_value = hp_bar:FindChild("Value"):GetComponent("Image")
    self.hp_text = hp_bar:FindChild("Text"):GetComponent("Text")
    local dynasty_record_panel = info_content:FindChild("DynastyRecord")
    dynasty_record_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_TOTAL_SCORE
    self.dynasty_total_score = dynasty_record_panel:FindChild("Value"):GetComponent("Text")
    local member_total_record_panel = info_content:FindChild("MemberTotalRecord")
    member_total_record_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.PERSONAL_TOTAL_SCORE
    self.personal_total_score = member_total_record_panel:FindChild("Value"):GetComponent("Text")
    local member_daily_record_panel = info_content:FindChild("MemberDailyRecord")
    member_daily_record_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.PERSONAL_TODAY_SCORE
    self.personal_daily_score = member_daily_record_panel:FindChild("Value"):GetComponent("Text")
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
    local building_content = self.main_panel:FindChild("Building")
    for building_id, building_data in pairs(SpecMgrs.data_mgr:GetAllDynastyBuildingData()) do
        local building_item = building_content:FindChild(building_data.btn_name)
        self.building_item_dict[building_id] = building_item
        self:AddClick(building_item:FindChild("Btn"), function ()
            if self.dynasty_id then
                if building_data.defend_member_count == 1 and not self.dy_dynasty_data:CheckCanAttackHeadquarter(self.dynasty_id) then
                    SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.ATTACK_HEAD_QUARTER_LIMIT)
                    return
                end
                SpecMgrs.ui_mgr:ShowUI("DynastyBuildingUI", self.dynasty_id, building_id)
            else
                self.dy_dynasty_data:UpdateDynastyMemberInfo(function ()
                    self.cur_building = building_id
                    self.dy_dynasty_data:UpdateDynastyBattleData()
                    self.deploy_panel:SetActive(true)
                    self.member_list_rect_cmp.anchoredPosition = Vector2.zero
                end)
            end
        end)
        self:AddClick(building_item:FindChild("Disable"), function ()
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.BUILDING_DESTROY_TEXT)
        end)
    end
    local bottom = self.main_panel:FindChild("Bottom")
    self.battle_info = bottom:FindChild("BattleInfo")
    self.attack_count = self.battle_info:FindChild("BattleCount/CurCount"):GetComponent("Text")
    self:AddClick(self.battle_info:FindChild("BattleCount/AddBtn"), function ()
        self.dy_dynasty_data:SendBuyBattleCount()
    end)
    self.battle_tip = self.battle_info:FindChild("BattleTip")
    self.battle_tip_text = self.battle_tip:GetComponent("Text")
    self.prepare_count_dowm = bottom:FindChild("Tip")
    self.prepare_count_dowm_text = self.prepare_count_dowm:GetComponent("Text")

    self.apply_panel = self.main_panel:FindChild("ApplyPanel")
    local apply_content = self.apply_panel:FindChild("Content")
    apply_content:FindChild("Title"):GetComponent("Text").text = UIConst.Text.APPLY_DYNASTY_BATTLE_TEXT
    self:AddClick(apply_content:FindChild("CloseBtn"), function ()
        self:Hide()
    end)
    apply_content:FindChild("Tip"):GetComponent("Text").text = UIConst.Text.APPLY_BATTLE_TIP
    local apply_btn = apply_content:FindChild("BtnPanel/ApplyBtn")
    apply_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.APPLY_TEXT
    self:AddClick(apply_btn, function ()
        self:SendApplyDynastyBattle()
    end)

    self.deploy_panel = self.main_panel:FindChild("DeployPanel")
    local top_bar = self.deploy_panel:FindChild("TopBar")
    UIFuncs.InitTopBar(self, top_bar, "DeployMemberUI", function ()
        self.deploy_panel:SetActive(false)
    end)
    self.deploy_title = top_bar:FindChild("CloseBtn/Title"):GetComponent("Text")
    local head_panel = self.deploy_panel:FindChild("MemberList/Head")
    head_panel:FindChild("Member"):GetComponent("Text").text = UIConst.Text.MEMBER_TEXT
    head_panel:FindChild("Score"):GetComponent("Text").text = UIConst.Text.SCORE_TEXT
    head_panel:FindChild("Level"):GetComponent("Text").text = UIConst.Text.LEVEL_TEXT
    head_panel:FindChild("State"):GetComponent("Text").text = UIConst.Text.STATE_TEXT
    self.member_list = self.deploy_panel:FindChild("MemberList/View/Content")
    self.member_list_rect_cmp = self.member_list:GetComponent("RectTransform")
    self.member_item = self.member_list:FindChild("MemberItem")
    self.member_item:FindChild("DeployBtn/Text"):GetComponent("Text").text = UIConst.Text.DEPLOY_TEXT
    self.member_item:FindChild("CancelBtn/Text"):GetComponent("Text").text = UIConst.Text.CANCEL
    local bottom_panel = self.deploy_panel:FindChild("Bottom")
    bottom_panel:FindChild("Tip"):GetComponent("Text").text = UIConst.Text.DEPLOY_TIP_TEXT
    self.deploy_count = bottom_panel:FindChild("DeployCount"):GetComponent("Text")
end

function DynastyStationUI:CheckDynastyBattleState()
    self.dy_dynasty_data:UpdateDynastyBattleData(function ()
        self.dy_dynasty_data:UpdateDynastyMemberInfo(function ()
            -- 加入公会
            if not self.dy_dynasty_data:CheckJoinDynastyTimeLimit() then
                SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.JOIN_DYNASTY_TIME_LIMIT)
                return
            end
            if self.dy_dynasty_data:GetDynastyBattleApplyState() then
                if self.dy_dynasty_data:CheckInBattleTime() then
                    SpecMgrs.ui_mgr:ShowUI("DynastyBattleUI")
                else
                    self:_Show()
                end
            else
                self.dy_dynasty_data:UpdateDynastyMemberInfo(function ()
                    if self.dy_dynasty_data:GetSelfInfo().job == CSConst.DynastyJob.Member then
                        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.APPLY_BATTLE_JOB_LIMIT)
                    else
                        self.dy_dynasty_data:UpdateDynastyBasicInfo(function (base_info)
                            if base_info.dynasty_level < self.dynasty_compete_apply_level_limit then
                                SpecMgrs.ui_mgr:ShowMsgBox(string.format(UIConst.Text.APPLY_BATTLE_LEVEL_LIMIT,self.dynasty_compete_apply_level_limit))
                                return
                            end
                            if base_info.member_count < self.dynasty_compete_apply_member_count then
                                SpecMgrs.ui_mgr:ShowMsgBox(string.format(UIConst.Text.APPLY_BATTLE_MEMBER_LIMIT,self.dynasty_compete_apply_member_count))
                                return
                            end
                            self:_Show()
                        end)
                    end
                end)
            end
        end)
    end)
end

function DynastyStationUI:InitUI()
    -- self:RegisterEvent(ComMgrs.dy_data_mgr, "UpdateCurrencyEvent", function (_, currency)
    --     UIFuncs.UpdateCurrencyItemNum(self._item_to_text_list, currency)
    -- end)
    self:RegisterEvent(self.dy_dynasty_data, "UpdateDynastyBattleInfoEvent", function ()
        self:UpdateDeployPanel()
        self:UpdateBuildingInfo()
    end)
    self.dy_dynasty_data:UpdateDynastyBattleData(function (battle_info)
        self:InitDynastyInfo()
        self:UpdateDynastyInfo()
        local is_apply = self.dy_dynasty_data:GetDynastyBattleApplyState() == true
        self.apply_panel:SetActive(not is_apply)
        if not self.dynasty_id and is_apply then SpecMgrs.ui_mgr:ShowUI("DynastyBattleReportUI") end
    end)
    self:RegisterEvent(self.dy_dynasty_data, "DynastyBattleEndEvent", function ()
        self:Hide()
    end)
end

function DynastyStationUI:InitDynastyInfo()
    self.hp_panel:SetActive(self.dynasty_id ~= nil)
    self.situation_btn:SetActive(self.dynasty_id ~= nil)
    self.prepare_count_dowm:SetActive(self.dynasty_id == nil)
    self.battle_info:SetActive(self.dynasty_id ~= nil)
    if self.dynasty_id then
        self.name.text = self.dy_dynasty_data:GetDynastyCompetitorInfo(self.dynasty_id).dynasty_name
        local battle_end_time = Time:GetServerTime() - Time:GetCurDayPassTime() + CSConst.Time.Day
        self:AddDynamicUI(self.battle_tip, function ()
            self.battle_tip_text.text = string.format(UIConst.Text.ROUND_END_TIP, UIFuncs.TimeDelta2Str(battle_end_time - Time:GetServerTime()))
        end, 1, 0)
    else
        SpecMgrs.msg_mgr:SendGetDynastyBasicInfo({}, function (resp)
            if resp.errcode ~= 0 then
                SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_DYNASTY_BASIC_INFO_FAILED)
            else
                self.name.text = resp.dynasty_base_info.dynasty_name
            end
        end)
        self:UpdateCountDownTimer()
    end
end

function DynastyStationUI:UpdateCountDownTimer()
    local battle_start_time = Time:GetServerTime() - Time:GetCurDayPassTime()
    local cur_week_day = Time:GetServerWeekDay()
    for i = 0, CSConst.DaysInWeek - 1 do
        local temp_week_day = (cur_week_day + i) % CSConst.DaysInWeek
        if self.dynasty_battle_fight_day[tostring(temp_week_day)] then
            battle_start_time = battle_start_time + i * CSConst.Time.Day + self.dynasty_battle_start_time
            break
        end
    end
    local rest_second = battle_start_time - Time:GetServerTime()
    self.battle_start_timer = self:AddTimer(function ()
        local param_tb = {
            content = UIConst.Text.DYNASTY_BATTLE_STRAT_TIP,
            confirm_cb = function ()
                self:Hide()
                SpecMgrs.ui_mgr:ShowUI("DynastyBattleUI")
            end,
            cancel_cb = function ()
                self:Hide()
            end,
            delay_time = 10,
        }
        SpecMgrs.ui_mgr:ShowMsgSelectBox(param_tb)
        self.battle_start_timer = nil
    end, rest_second)
    local time_table = UIFuncs.TimeDelta2Table(rest_second, 4)
    if time_table[4] > 0 then
        self.prepare_count_dowm_text.text = string.format(UIConst.Text.NEXT_BATTLE_TIME_FORMAT, time_table[4] .. UIConst.Text.TIME_TEXT[4])
        self:RemoveUpdateCountDownTimer()
        self.add_count_down_timer = self:AddTimer(function ()
            self:UpdateCountDownTimer()
        end, CSConst.Time.Day)
    else
        self:AddDynamicUI(self.prepare_count_dowm, function ()
            self.prepare_count_dowm_text.text = string.format(UIConst.Text.NEXT_BATTLE_TIME_FORMAT, UIFuncs.TimeDelta2Str(battle_start_time - Time:GetServerTime()))
        end, 1, 0)
    end
end

function DynastyStationUI:UpdateBuildingInfo()
    if not self.dy_dynasty_data:GetDynastyBattleApplyState() then return end
    for building_id, building_item in pairs(self.building_item_dict) do
        local building_data = SpecMgrs.data_mgr:GetDynastyBuildingData(building_id)
        local defender_count
        if self.dynasty_id then
            self.attack_count.text = string.format(UIConst.Text.REST_DYNASTY_BATTLE_COUNT, self.dy_dynasty_data:GetDynastyBattleAttackCount())
            defender_count = self.dy_dynasty_data:CalcDynastyBuildingRestDefenderCount(self.dynasty_id, building_id)
            local is_destroy = self.dy_dynasty_data:CheckBuildingIsDestroyed(self.dynasty_id, building_id)
            building_item:FindChild("Disable"):SetActive(is_destroy)
            building_item:FindChild("Disable/Name/Text"):GetComponent("Text").text = string.format(UIConst.Text.BUILDING_DEFEND_COUNT_FORMAT, building_data.color, building_data.name, defender_count, building_data.defend_member_count)
            building_item:FindChild("Btn"):SetActive(not is_destroy)
        else
            building_item:FindChild("Disable"):SetActive(false)
            building_item:FindChild("Btn"):SetActive(true)
            defender_count = self.dy_dynasty_data:GetDynastyBuildingDefendCount(building_id)
        end
        building_item:FindChild("Btn/Name/Text"):GetComponent("Text").text = string.format(UIConst.Text.BUILDING_DEFEND_COUNT_FORMAT, building_data.color, building_data.name, defender_count, building_data.defend_member_count)
    end
end

function DynastyStationUI:UpdateDynastyInfo()
    if self.dynasty_id then
        local cur_hp = self.dy_dynasty_data:CalcDynastyHp(self.dynasty_id)
        local max_hp = self.dy_dynasty_data:GetDynastyBattleMaxHp()
        self.hp_value.fillAmount = cur_hp / max_hp
        self.hp_text.text = string.format(UIConst.Text.PER_VALUE, cur_hp, max_hp)
    end
    local score_dict = self.dy_dynasty_data:GetDynastyBattleScore()
    self.dynasty_total_score.text = score_dict.dynasty_total_score or 0
    self.personal_total_score.text = score_dict.personal_total_score or 0
    self.personal_daily_score.text = score_dict.personal_daily_score or 0
    self.battle_count.text = score_dict.battle_count or 0
end

function DynastyStationUI:UpdateDeployPanel()
    if not self.cur_building then return end
    local is_member = self.dy_dynasty_data:GetSelfInfo().job == CSConst.DynastyJob.Member
    local building_data = SpecMgrs.data_mgr:GetDynastyBuildingData(self.cur_building)
    self.deploy_title.text = building_data.name
    self:ClearDeployMemberItem()
    local member_list = self.dy_dynasty_data:GetDynastyBuildingInfo(self.cur_building)
    for _, member_info in ipairs(member_list) do
        local member_item = self:GetUIObject(self.member_item, self.member_list)
        table.insert(self.deploy_member_item_list, member_item)
        local role_look_data = SpecMgrs.data_mgr:GetRoleLookData(member_info.role_id)
        UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetUnitData(role_look_data.unit_id).icon, member_item:FindChild("IconBg/Icon"):GetComponent("Image"))
        member_item:FindChild("Name"):GetComponent("Text").text = member_info.name
        member_item:FindChild("Vip"):GetComponent("Text").text = string.format(UIConst.Text.VIP, member_info.vip or 0)
        member_item:FindChild("Score"):GetComponent("Text").text = UIFuncs.AddCountUnit(member_info.fight_score)
        member_item:FindChild("Level"):GetComponent("Text").text = member_info.level
        local defend_building_data = SpecMgrs.data_mgr:GetDynastyBuildingData(member_info.defend_building)
        member_item:FindChild("State"):GetComponent("Text").text = defend_building_data and string.format(UIConst.Text.SIMPLE_COLOR, defend_building_data.color, defend_building_data.name) or UIConst.Text.NONE
        local deploy_btn = member_item:FindChild("DeployBtn")
        deploy_btn:SetActive(not is_member and defend_building_data == nil)
        self:AddClick(deploy_btn, function ()
            if self.dy_dynasty_data:GetDynastyBuildingDefendCount(self.cur_building) >= building_data.defend_member_count then
                SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.BUILDING_DEFEND_COUNT_LIMIT)
                return
            end
            self:SendDefendDynastyBuilding(member_info.uuid, self.cur_building)
        end)
        local cancel_btn = member_item:FindChild("CancelBtn")
        cancel_btn:SetActive(not is_member and defend_building_data ~= nil)
        self:AddClick(cancel_btn, function ()
            self:SendDefendDynastyBuilding(member_info.uuid)
        end)
    end
    self.deploy_count.text = string.format(UIConst.Text.DEFENDER_COUNT_FORMAT, self.dy_dynasty_data:GetDynastyBuildingDefendCount(self.cur_building), building_data.defend_member_count)
end

-- msg
function DynastyStationUI:SendApplyDynastyBattle()
    SpecMgrs.msg_mgr:SendApplyDynastyCompete({}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.APPLY_DYNASTY_BATTLE_FAILED)
        else
            self.dy_dynasty_data:UpdateDynastyBattleData()
            self.apply_panel:SetActive(false)
            SpecMgrs.ui_mgr:ShowUI("DynastyBattleReportUI")
        end
    end)
end

function DynastyStationUI:SendDefendDynastyBuilding(uuid, building)
    SpecMgrs.msg_mgr:SendDefendDynastyBuilding({uuid = uuid, building_id = building}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.BUILDING_DEFEND_FIALED)
        end
        self.dy_dynasty_data:UpdateDynastyBattleData()
    end)
end

function DynastyStationUI:RemoveUpdateCountDownTimer()
    if self.add_count_down_timer then
        self:RemoveTimer(self.add_count_down_timer)
        self.add_count_down_timer = nil
    end
end

function DynastyStationUI:ClearDeployMemberItem()
    for _, item in ipairs(self.deploy_member_item_list) do
        self:DelUIObject(item)
    end
    self.deploy_member_item_list = {}
end

return DynastyStationUI