local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local FloatMsgCmp = require("UI.UICmp.FloatMsgCmp")
local ItemUtil = require("BaseUtilities.ItemUtil")
local CSFunction = require("CSCommon.CSFunction")
local TraitorBossUI = class("UI.TraitorBossUI",UIBase)

local my_server_index = 1

--  叛军boss
function TraitorBossUI:DoInit()
    TraitorBossUI.super.DoInit(self)
    self.prefab_path = "UI/Common/TraitorBossUI"
    self.cross_traitor_boss_name = SpecMgrs.data_mgr:GetParamData("cross_traitor_boss_name").f_string
    self.traitor_boss_name = SpecMgrs.data_mgr:GetParamData("traitor_boss_name").f_string

    self.cross_traitor_boss_fight_score = SpecMgrs.data_mgr:GetParamData("cross_traitor_boss_fight_score").f_value
    self.cross_traitor_boss_hurt = SpecMgrs.data_mgr:GetParamData("cross_traitor_boss_hurt").f_value
    self.traitor_boss_end_time = SpecMgrs.data_mgr:GetParamData("traitor_boss_open_time").tb_int[2] -- 1 start_time, 2 end_time
    self.cross_boss_show_unit = SpecMgrs.data_mgr:GetParamData("cross_boss_show_unit").unit
end

function TraitorBossUI:OnGoLoadedOk(res_go)
    TraitorBossUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function TraitorBossUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    TraitorBossUI.super.Show(self)
end

function TraitorBossUI:InitRes()
    self:InitTopBar()
    self.mes_list = self.main_panel:FindChild("MesList")
    self.my_glory_text = self.main_panel:FindChild("MesList/MyGlory/MyGloryText"):GetComponent("Text")
    self.max_hurt_text = self.main_panel:FindChild("MesList/MaxHurt/MaxHurtText"):GetComponent("Text")
    self.rank_text = self.main_panel:FindChild("MesList/Rank/RankText"):GetComponent("Text")
    self.my_server_rank_btn = self.main_panel:FindChild("MyServerRankBtn")
    self:AddClick(self.my_server_rank_btn, function()
        SpecMgrs.ui_mgr:ShowRankUI(UIConst.Rank.TraitorBoss)
    end)
    self.cross_server_rank_btn = self.main_panel:FindChild("CrossServerRankBtn")
    self:AddClick(self.cross_server_rank_btn, function()
        SpecMgrs.ui_mgr:ShowRankUI(UIConst.Rank.CrossTraitorBoss)
    end)
    self.reward_btn = self.main_panel:FindChild("RewardBtn")
    self:AddClick(self.reward_btn, function()
        self:ShowRewardPanel()
    end)
    self.change_boss_btn = self.main_panel:FindChild("ChangeBossBtn")
    self:AddClick(self.change_boss_btn, function()
        self:SwithBossType()
    end)

    self.boss_mes = self.main_panel:FindChild("BossMes")
    self.boss_mes_text = self.main_panel:FindChild("BossMes/BossNameText"):GetComponent("Text")
    self.no_activity_panel = self.main_panel:FindChild("NoActivityPanel")
    self.rank_list = self.main_panel:FindChild("NoActivityPanel/RankList")
    self.open_date_text = self.main_panel:FindChild("NoActivityPanel/OpenDateText"):GetComponent("Text")
    self.boss_score_rank_text = self.main_panel:FindChild("NoActivityPanel/RankText"):GetComponent("Text")

    self.activity_panel = self.main_panel:FindChild("ActivityPanel")
    self.hp_slider = self.main_panel:FindChild("ActivityPanel/HpSlider/HpSlider"):GetComponent("Image")
    self.hp_slider_text = self.main_panel:FindChild("ActivityPanel/HpSlider/Text"):GetComponent("Text")
    self.skip_battle_toggle = self.main_panel:FindChild("ActivityPanel/Toggle"):GetComponent("Toggle")
    self.background = self.main_panel:FindChild("ActivityPanel/Toggle/Background"):GetComponent("Image")
    self.skip_battle_text = self.main_panel:FindChild("ActivityPanel/Toggle/Label"):GetComponent("Text")
    self.boss_revive_text = self.main_panel:FindChild("ActivityPanel/BossReviveText"):GetComponent("Text")
    self.killer_text = self.main_panel:FindChild("ActivityPanel/KillerText"):GetComponent("Text")

    self.hurt_box = self.main_panel:FindChild("HurtMsgBox")
    self.hurt_msg_item = self.main_panel:FindChild("HurtMsgBox/HurtMsgItem")

    self.down_challenge_time_frame = self.main_panel:FindChild("DownChallengeTimeFrame")
    self.array_btn = self.main_panel:FindChild("DownChallengeTimeFrame/ArrayBtn")
    self:AddClick(self.array_btn, function()
        SpecMgrs.ui_mgr:ShowSmallLineupUI()
    end)

    self.battle_mes_btn = self.main_panel:FindChild("DownChallengeTimeFrame/BattleMesBtn")
    self:AddClick(self.battle_mes_btn, function()
        self:ShowBattleResultPanel()
    end)

    self.buy_challenge_button = self.main_panel:FindChild("DownChallengeTimeFrame/BuyChallengeButton")
    self:AddClick(self.buy_challenge_button, function()
        self:BuyChallengeTime()
    end)
    self.today_challenge_time_text = self.main_panel:FindChild("DownChallengeTimeFrame/TodayChallengeTimeText"):GetComponent("Text")
    self.add_challenge_count_down_text = self.main_panel:FindChild("DownChallengeTimeFrame/AddChallengeCountDownText"):GetComponent("Text")

    self.left_unit = self.main_panel:FindChild("LeftUnit")
    self.middle_unit = self.main_panel:FindChild("MiddleUnit")
    self.right_unit = self.main_panel:FindChild("RightUnit")
    self.boss_death = self.main_panel:FindChild("BossDeath")
    self.boss_death_text = self.main_panel:FindChild("BossDeath/BossDeathText"):GetComponent("Text")

    --  奖励
    self.reward_panel = self.main_panel:FindChild("RewardPanel")
    self.reward_panel_close_btn = self.main_panel:FindChild("RewardPanel/Top/CloseBtn")
    self:AddClick(self.reward_panel_close_btn, function()
        self:HideRewardPanel()
    end)
    self.reward_panel_title = self.main_panel:FindChild("RewardPanel/Top/Text"):GetComponent("Text")
    self.reward_panel_list = self.main_panel:FindChild("RewardPanel/RewardPanelList"):GetComponent("Text")
    self.reward_panel_content = self.main_panel:FindChild("RewardPanel/RewardPanelList/View/Content")
    self.reward_panel_content_temp = self.main_panel:FindChild("RewardPanel/RewardPanelList/View/Content/Temp")
    self.one_key_recive_btn = self.main_panel:FindChild("RewardPanel/OneKeyReciveBtn")

    --  战况
    self.boss_battle_result_panel = self.main_panel:FindChild("BossBattleResultPanel")
    self.record_panel_close_btn = self.main_panel:FindChild("BossBattleResultPanel/Top/CloseBtn")
    self:AddClick(self.record_panel_close_btn, function()
        self:HideBattleResultPanel()
    end)
    self.record_panel_title = self.main_panel:FindChild("BossBattleResultPanel/Top/Text"):GetComponent("Text")
    --self.my_server_boss_list = self.main_panel:FindChild("BossBattleResultPanel/MyServerBossList")
    self.my_server_boss_record = self.main_panel:FindChild("BossBattleResultPanel/MyServerBossList")
    self.my_server_boss_list = self.main_panel:FindChild("BossBattleResultPanel/MyServerBossList/View/Content")
    self.my_server_boss_list_temp = self.main_panel:FindChild("BossBattleResultPanel/MyServerBossList/View/Content/Temp")
    self.server_option = self.main_panel:FindChild("BossBattleResultPanel/OptionList/ServerOption")
    self.cross_server_option = self.main_panel:FindChild("BossBattleResultPanel/OptionList/CrossServerOption")
    self.end_count_down_text = self.main_panel:FindChild("BossBattleResultPanel/EndCountDownText"):GetComponent("Text")
    self.cross_server_boss_record = self.main_panel:FindChild("BossBattleResultPanel/CrossServerMes")
    self.cross_server_record_text_title = self.main_panel:FindChild("BossBattleResultPanel/CrossServerMes/RewardTitle"):GetComponent("Text")
    self.cross_server_mes_list = self.main_panel:FindChild("BossBattleResultPanel/CrossServerMes/MesList")
    self.cross_server_record_text = self.main_panel:FindChild("BossBattleResultPanel/CrossServerMes/MesList/RewardTitle")

    self.click_area = self.main_panel:FindChild("ClickArea")
    self:AddClick(self.click_area, function()
        self:ClickEnterBattle()
    end)
    self.mask = self.main_panel:FindChild("Mask")

    self.boss_mes_up_pos = self.main_panel:FindChild("BossMesUpPos"):GetComponent("RectTransform").anchoredPosition
    self.boss_mes_down_pos = self.main_panel:FindChild("BossMesDownPos"):GetComponent("RectTransform").anchoredPosition

    self.cross_boss_frame = self.main_panel:FindChild("CrossBossFrame")
    self.boss_rect = self.main_panel:FindChild("CrossBossFrame/BossRect")
    self.player_temp = self.main_panel:FindChild("CrossBossFrame/PlayerTemp")
    self.player_point_list_go = self.main_panel:FindChild("CrossBossFrame/PlayerPointList")
    self.cross_boss_name = self.main_panel:FindChild("CrossBossFrame/CrossBossName")
    self.cross_boss_name_text = self.main_panel:FindChild("CrossBossFrame/CrossBossName/CrossBossNameText"):GetComponent("Text")
    self.battle_count_down_text = self.main_panel:FindChild("CrossBossFrame/BattleCountDownText"):GetComponent("Text")
    self.challenge_count_down_text = self.main_panel:FindChild("CrossBossFrame/ChallengeCountDownText"):GetComponent("Text")

    self.player_point_list = {}
    for i = 1, self.player_point_list_go.childCount do
        table.insert(self.player_point_list, self.player_point_list_go:GetChild(i - 1))
    end

    self:SetTextVal()

    self.boss_show_pos_list = {
        self.left_unit,
        self.middle_unit,
        self.right_unit,
    }
    self.rank_obj_list = {}
    for i = 1, self.rank_list.childCount do
        table.insert(self.rank_obj_list, self.rank_list:GetChild(i - 1))
    end
    self.reward_panel:SetActive(false)
    self.boss_battle_result_panel:SetActive(false)
    self.my_server_boss_list_temp:SetActive(false)
    self.cross_server_record_text:SetActive(false)
    self.reward_panel_content_temp:SetActive(false)
    self.player_temp:SetActive(false)
end

function TraitorBossUI:InitUI()
    SpecMgrs.msg_mgr:SendEnterTraitorBoss(nil, nil)
    self.is_in_click_battle_cd = false
    self.is_show_my_server = true
    self.dy_boss_data = ComMgrs.dy_data_mgr.traitor_boss_data
    local cb = function(resp)
        if not self.is_res_ok then return end
        self:AffterAcceptData(resp)
    end
    SpecMgrs.msg_mgr:SendGetTraitorBossData(nil, cb)
    self:RemoveUnitList(self.boss_unit_list)
    self.boss_unit_list = {}
    local show_unit_list = SpecMgrs.data_mgr:GetParamData("traitor_boss_show_unit").unit_list
    for i, unit_id in ipairs(show_unit_list) do
       if i > #self.boss_show_pos_list then break end
       local unit = self:AddFullUnit(unit_id, self.boss_show_pos_list[i])
       table.insert(self.boss_unit_list, unit)
    end
    self.skip_battle_toggle.isOn = false
    self.float_mes = FloatMsgCmp.New()
    self.float_mes:DoInit(self, self.hurt_box, self.hurt_msg_item)
end

function TraitorBossUI:Update(delta_time)
    self.float_mes:Update(delta_time)
    local ts = (self.dy_boss_data.challenge_num_ts or 0) - Time:GetServerTime()
    if ts < 0 then ts = 0 end
    local str = string.format(UIConst.Text.BOSS_RECOVER_FORMAT, UIFuncs.TimeDelta2Str(ts, 3))
    self.add_challenge_count_down_text.text = str

    if self.traitor_boss_info and self.traitor_boss_info.revive_ts then
        local ts = self.traitor_boss_info.revive_ts - Time:GetServerTime()
        if ts < 0 then ts = 0 end
        self.boss_revive_text.text = string.format(UIConst.Text.BOSS_RECIVE_TEXT, ts)
        self.killer_text.text = string.format(UIConst.Text.KILLER_FORMAT, self.traitor_boss_info.killed_role)
    else
        self.boss_revive_text.text = ""
        self.killer_text.text = ""
    end

    if self.boss_battle_result_panel.activeSelf then
        local date = os.date("*t", Time:GetServerTime())
        date.hour = self.traitor_boss_end_time
        date.min = 0
        date.sec = 0
        local end_ts = os.time(date)
        ts = end_ts - Time:GetServerTime()
        if ts < 0 then
            self.end_count_down_text.text = UIConst.Text.BOSS_ALREADY_END_TIME_FORMAT
        else
            self.end_count_down_text.text = string.format(UIConst.Text.BOSS_END_TIME_FORMAT, UIFuncs.TimeDelta2Str(ts, 3))
        end
    end
    if self.cross_boss_frame.activeSelf then
        self:UpdateCrossBossCountDown()
    end
end

function TraitorBossUI:AffterAcceptData(init_data)
    self.init_data = init_data
    self:UpdateData(init_data)
    self:UpdateUIInfo(init_data)
    self:ShowMyServerBossUI()

    ComMgrs.dy_data_mgr.traitor_boss_data:RegisterUpdateTraitorBossInfo("TraitorBossUI", function()
        self:UpdateData()
        if self.cross_boss_frame.activeSelf then return end
        self:ShowMyServerBossUI()
        self:ShowHurtMes()
    end)
    ComMgrs.dy_data_mgr.traitor_boss_data:RegisterTraitorBossInfoRevive("TraitorBossUI", function()
        self:UpdateData()
        if self.cross_boss_frame.activeSelf then return end
        self:ShowMyServerBossUI()
    end)
    ComMgrs.dy_data_mgr.traitor_boss_data:RegisterUpdateCrossTraitorFight("TraitorBossUI", function()
        self:BattleWithCrossBoss()
    end)
    ComMgrs.dy_data_mgr.traitor_boss_data:RegisterUpdateCrossTraitorInfo("TraitorBossUI", function()
        if self.cross_boss_frame.activeSelf then
            self:UpdateCrossBossUI()
        end
    end)
    ComMgrs.dy_data_mgr.traitor_boss_data:RegisterUpdateTraitorChallengeNum("TraitorBossUI", function()
        self.today_challenge_time_text.text = string.format(UIConst.Text.BOSS_CHALLENGE_TIME_FORMAT, self.dy_boss_data.challenge_time)
    end)
end

function TraitorBossUI:UpdateData(init_data)
    if init_data then
        self.traitor_boss_info = init_data
        if self.traitor_boss_info.hp_dict then
            self.traitor_boss_info.cur_hp = table.sum(self.traitor_boss_info.hp_dict)
        end
        self.dy_boss_data:UpdateTraitorChallengeNum(init_data)
        self.reward_dict = init_data.reward_dict
        self.cur_info = init_data
        self.buy_challenge_num = init_data.buy_challenge_num
    else
        self.traitor_boss_info = self.dy_boss_data.traitor_boss_info
    end
end

function TraitorBossUI:UpdateUIInfo(init_data)
    self.my_glory_text.text = string.format(UIConst.Text.MY_BOSS_SCORE_FORMAT, init_data.honour or 0, self:GetRankText(init_data.honour_rank))
    self.max_hurt_text.text = string.format(UIConst.Text.BOSS_MAX_HURT_FORMAT, init_data.max_hurt or 0, self:GetRankText(init_data.max_hurt_rank))
    self.rank_text.text = string.format(UIConst.Text.BOSS_DYNASTY_RANK_FROMAT, self:GetRankText(init_data.dynasty_rank))
    self.today_challenge_time_text.text = string.format(UIConst.Text.BOSS_CHALLENGE_TIME_FORMAT, init_data.challenge_num)
    self.boss_mes_text.text = string.format(UIConst.Text.BOSS_NAME_LEVEL_FORMAT, self.traitor_boss_name, self.traitor_boss_info.boss_level or 0)
end

function TraitorBossUI:GetRankText(rank)
    if rank == nil then
        return UIConst.Text.NONE
    else
        return string.format(UIConst.Text.RANK_FORMAT, rank)
    end
end

function TraitorBossUI:ShowMyServerBossUI()
    if self.init_data.is_open then
        self:ShowOpenActivityUI()
    else
        self:ShowCloseActivityUI()
    end
end

function TraitorBossUI:SwithBossType()
    if not self:CheckCanTurnCrossBoss(true) then return end
    self.is_show_my_server = not self.is_show_my_server
    if self.is_show_my_server then
        self:HideCrossBossUI()
        self:ShowMyServerBossUI()
    else
        self:HideOpenActivityUI()
        self:ShowCrossBossUI()
    end
end

--  开始活动
function TraitorBossUI:ShowOpenActivityUI()
    self.no_activity_panel:SetActive(false)
    self.activity_panel:SetActive(true)
    self.boss_mes:SetActive(true)
    self.cross_boss_frame:SetActive(false)
    self.down_challenge_time_frame:SetActive(true)
    self.change_boss_btn:SetActive(true)
    self.hurt_box:SetActive(true)
    for i, unit in ipairs(self.boss_unit_list) do
        unit:SetVisible(true)
    end
    local cur_hp
    if self.traitor_boss_info.revive_ts then
        self:SetBossDeath()
        self.hp_slider.fillAmount = 0
        cur_hp = 0
        self.boss_death:SetActive(true)
    else
        self:SetBossAlive()
        cur_hp = self.traitor_boss_info.cur_hp or 0
        self.boss_death:SetActive(false)
    end
    self.hp_slider.fillAmount = cur_hp / self.traitor_boss_info.max_hp
    self.hp_slider_text.text = string.format(UIConst.Text.PER_VALUE, UIFuncs.AddCountUnit(cur_hp), UIFuncs.AddCountUnit(self.traitor_boss_info.max_hp))
    self.boss_mes:GetComponent("RectTransform").anchoredPosition = self.boss_mes_down_pos
end

function TraitorBossUI:ClickEnterBattle()
    if not self.init_data.is_open then return end
    if not self:CheckCanChallenge() then return end
    if self.traitor_boss_info.revive_ts then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.BOSS_DEATH_TIP)
        return
    end
    if not self.dy_boss_data:CanChallengeBoss() then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.CANNOT_CONTINUITY_CHALLENGE_TIP)
        return
    end
    local is_skip_battle = self.skip_battle_toggle.isOn
    local cb = function(resp)
        if not self.is_res_ok then
            SpecMgrs.msg_mgr:SendStageFightEnd(nil, nil)
            return
        end
        self.dy_boss_data:SetNextChallengeTime()
        self:RefleshData()
        if is_skip_battle then
            SpecMgrs.msg_mgr:SendStageFightEnd(nil, nil)
            return
        end
        SpecMgrs.ui_mgr:EnterHeroBattle(resp.fight_data, UIConst.BattleScence.TraitorBossUI)
        SpecMgrs.ui_mgr:RegiseHeroBattleEnd("TraitorBossUIBoss", function()
            local param_tb = {
                is_win = resp.is_win,
                show_level = true,
                reward = {resp.lucky_reward, resp.kill_reward},
                win_tip = resp.is_win and UIConst.Text.BATTLE_WIN_TIP,
            }
            SpecMgrs.ui_mgr:AddCloseBattlePopUpList("BattleResultUI", param_tb)
        end)
    end
    SpecMgrs.msg_mgr:SendMsg("SendChallengeTraitorBoss", nil, cb)
end

function TraitorBossUI:RefleshData()
    local cb = function(resp)
        if not self.is_res_ok then return end
        self:AffterAcceptData(resp)
    end
    SpecMgrs.msg_mgr:SendGetTraitorBossData(nil, cb)
    return
end

function TraitorBossUI:ShowHurtMes()
    local name = self.dy_boss_data.traitor_boss_info.role_name
    local hurt = self.dy_boss_data.traitor_boss_info.role_hurt
    if not name or not hurt then return end
    local boss_name = string.format(UIConst.Text.BOSS_NAME_LEVEL_FORMAT, self.traitor_boss_name, self.dy_boss_data.traitor_boss_info.boss_level or 0)
    local str = string.format(UIConst.Text.BOSS_HURT_FORMAT, name, boss_name, UIFuncs.AddCountUnit(hurt))
    self.float_mes:ShowMsg(str)
end

function TraitorBossUI:HideOpenActivityUI()
    self.no_activity_panel:SetActive(false)
    self.activity_panel:SetActive(false)
    self.boss_death:SetActive(false)
    self.boss_mes:SetActive(false)
    for i, unit in ipairs(self.boss_unit_list) do
        unit:SetVisible(false)
    end
end
--  开始活动end

--  活动关闭
function TraitorBossUI:ShowCloseActivityUI()
    self:SetBossDeath()
    self.no_activity_panel:SetActive(true)
    self.activity_panel:SetActive(false)
    self.boss_death:SetActive(false)
    self.cross_boss_frame:SetActive(false)
    self.boss_mes:SetActive(true)
    self.down_challenge_time_frame:SetActive(false)
    self.change_boss_btn:SetActive(false)
    self.hurt_box:SetActive(false)
    for i, item in ipairs(self.rank_obj_list) do
        local rank_info = self.init_data.three_honour_rank and self.init_data.three_honour_rank[i]
        if rank_info then
            item:FindChild("Rank"):SetActive(true)
            item:FindChild("Rank/NameText"):GetComponent("Text").text = rank_info.name
            item:FindChild("Rank/LevelText"):GetComponent("Text").text = string.format(UIConst.Text.LEVEL, rank_info.level)
            item:FindChild("Rank/RankValText"):GetComponent("Text").text = UIFuncs.AddCountUnit(rank_info.rank_score)
            item:FindChild("NoneText"):SetActive(false)
        else
            item:FindChild("Rank"):SetActive(false)
            item:FindChild("NoneText"):SetActive(true)
            item:FindChild("NoneText"):GetComponent("Text").text = UIConst.Text.NONE_RANK_TEXT
        end
    end
    local open_date_list = SpecMgrs.data_mgr:GetParamData("traitor_boss_open_day").tb_int
    local day_str = ""
    for i,v in ipairs(open_date_list) do
        if v == 0 then v = 7 end
        if i == #open_date_list then
            day_str = day_str .. UIConst.Text.WEED_TEXT[v]
        else
            day_str = day_str .. UIConst.Text.WEED_TEXT[v] .. UIConst.Text.COMMA
        end
    end
    local open_time_list = SpecMgrs.data_mgr:GetParamData("traitor_boss_open_time").tb_int
    local hour = string.format(UIConst.Text.HOUR_INTERVAL, open_time_list[1], open_time_list[2])
    self.open_date_text:GetComponent("Text").text = string.format(UIConst.Text.BOSS_OPEN_DATE_FORMAT, day_str, hour)
    self.boss_mes:GetComponent("RectTransform").anchoredPosition = self.boss_mes_up_pos
end
--  活动关闭end

function TraitorBossUI:SetBossDeath()
    for i, unit in ipairs(self.boss_unit_list) do
        unit:ChangeToGray()
        unit:SetTimeScale(0)
    end
end

function TraitorBossUI:SetBossAlive()
    for i, unit in ipairs(self.boss_unit_list) do
        unit:ChangeToNormalMaterial()
        unit:SetTimeScale(1)
    end
end

--  战报
function TraitorBossUI:ShowBattleResultPanel()
    self.boss_battle_result_panel:SetActive(true)
    self.mask:SetActive(true)
    self.war_report_obj_list = {}
    local cb = function(resp)
        if not self.is_res_ok or not self.boss_battle_result_panel.activeSelf then return end
        self.boss_record_data = resp.boss_record
        self.cross_boss_record_data = resp.cross_boss_record
        self.record_option_selector:SelectObj(my_server_index)
    end
    SpecMgrs.msg_mgr:SendGetTraitorBossRecord(nil, cb)
    local option_list = {self.server_option, self.cross_server_option}
    self.record_option_selector = UIFuncs.CreateSelector(self, option_list, function(index)
        if index == my_server_index then
            self:ShowBossRecord()
        else
            if self:CheckCanTurnCrossBoss(true) then
                self:ShowCrossBossRecord()
            else
                self.record_option_selector:SelectObj(my_server_index)
            end
        end
    end)
end

function TraitorBossUI:ShowBossRecord()
    self:DelObjDict(self.war_report_obj_list)
    self.war_report_obj_list = {}
    if not self.boss_record_data then return end
    self.my_server_boss_record:SetActive(true)
    self.cross_server_boss_record:SetActive(false)
    local index = math.floor(#self.boss_record_data / 2)
    for i = 1, index do
        local lucky_record = self.boss_record_data[i * 2 - 1]
        local kill_record = self.boss_record_data[i * 2]
        local item = self:GetUIObject(self.my_server_boss_list_temp, self.my_server_boss_list)
        table.insert(self.war_report_obj_list, item)

        local boss_data = SpecMgrs.data_mgr:GetTraitorBossData(lucky_record.boss_level)
        local title = string.format(UIConst.Text.BOSS_NAME_LEVEL_FORMAT, self.traitor_boss_name, boss_data.level)
        item:FindChild("RewardTitle"):GetComponent("Text").text = title
        local str = string.format(UIConst.Text.LUCKY_BOSS_RECODE_FORMAT, UIFuncs.GetHourMinDate(lucky_record.time), lucky_record.role_name, UIFuncs.GetItemXCountStr(lucky_record.item_id, lucky_record.item_count))
        item:FindChild("FirstText"):GetComponent("Text").text = str
        str = string.format(UIConst.Text.KILL_BOSS_RECODE_FORMAT, UIFuncs.GetHourMinDate(kill_record.time), kill_record.role_name, UIFuncs.GetItemXCountStr(kill_record.item_id, kill_record.item_count))
        item:FindChild("SecondText"):GetComponent("Text").text = str
    end
end

function TraitorBossUI:ShowCrossBossRecord()
    self:DelObjDict(self.war_report_obj_list)
    self.war_report_obj_list = {}
    if not self.cross_boss_record_data then return end
    self.my_server_boss_record:SetActive(false)
    self.cross_server_boss_record:SetActive(true)
    for i, record in ipairs(self.cross_boss_record_data) do
        local item = self:GetUIObject(self.cross_server_record_text, self.cross_server_mes_list)
        item:GetComponent("Text").text = string.format(UIConst.Text.CROSS_BOSS_RECORD_FORMAT, UIFuncs.GetHourMinDate(record.time), record.role_name, record.hurt, UIFuncs.GetItemXCountStr(record.item_id, record.item_count))
        table.insert(self.war_report_obj_list, item)
    end
end

function TraitorBossUI:HideBattleResultPanel()
    self.boss_battle_result_panel:SetActive(false)
    self.mask:SetActive(false)
    self:DelObjDict(self.war_report_obj_list)
end

--  战报end

--  奖励
function TraitorBossUI:ShowRewardPanel()
    self.reward_panel:SetActive(true)
    self.mask:SetActive(true)
    self:DelObjDict(self.reward_obj_list)
    self.can_recive_count = 0
    self.reward_obj_list = {}
    self.reward_effect_list = {}
    self:CreateRewardContent()
    self:AddClick(self.one_key_recive_btn, function()
        if self.can_recive_count == 0 then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.NO_REWARD_TIP)
            return
        end
        self:SendReciveReward()
    end)
end

function TraitorBossUI:CreateRewardContent()
    local data_list = SpecMgrs.data_mgr:GetAllTraitorBossRewardData()
    local recive_list = {}
    local can_recive_list = {}
    local can_not_recive_list = {}
    for i, data in ipairs(data_list) do
        if self.cur_info.reward_dict[i] == nil then
            table.insert(recive_list, data)
        elseif self.cur_info.reward_dict[i] == true then
            table.insert(can_recive_list, data)
        elseif self.cur_info.reward_dict[i] == false then
            table.insert(can_not_recive_list, data)
        end
    end
    self:CreateRewardList(can_recive_list)
    self:CreateRewardList(can_not_recive_list)
    self:CreateRewardList(recive_list)
    self.can_recive_count = #can_recive_list
end

function TraitorBossUI:CreateRewardList(data_list)
    for i, data in ipairs(data_list) do
        local item = self:GetUIObject(self.reward_panel_content_temp, self.reward_panel_content)
        local title = item:FindChild("RewardTitle"):GetComponent("Text")
        if data.require_honour then
            title.text = string.format(UIConst.Text.BOSS_SCORE_NEED_FORMAT, self.cur_info.honour, data.require_honour)
        else
            title.text = string.format(UIConst.Text.BOSS_LEVEL_NEED_FORMAT, self.cur_info.boss_level - 1, data.require_boss_level)
        end
        local item_list = ItemUtil.GetSortedRewardItemList(data.reward_id)
        local ret = self:SetItemList(item_list, item:FindChild("ItemList/ViewPort/Content"))

        local not_reach = item:FindChild("AwardNotReach")
        local reach = item:FindChild("AwardReach")
        local btn = item:FindChild("ReciveBtn")

        not_reach:SetActive(false)
        reach:SetActive(false)
        btn:SetActive(false)
        if self.cur_info.reward_dict[data.id] == nil then
            reach:SetActive(true)
        elseif self.cur_info.reward_dict[data.id] == true then
            btn:SetActive(true)
            self:AddClick(btn, function()
                self:SendReciveReward(data.id)
            end)
            local effect = UIFuncs.AddCompleteEffect(self, btn)
            table.insert(self.reward_effect_list, effect)
        elseif self.cur_info.reward_dict[data.id] == false then
            not_reach:SetActive(true)
        end
        table.mergeList(self.reward_obj_list, ret)
        table.insert(self.reward_obj_list, item)
    end
end

function TraitorBossUI:SendReciveReward(reward_id)
    local cb = function(resp)
        if not self.is_res_ok or not self.reward_panel.activeSelf then return end
        self.cur_info.reward_dict = resp.reward_dict
        self:DelObjDict(self.reward_obj_list)
        self:CreateRewardContent()
    end
    SpecMgrs.msg_mgr:SendGetTraitorBossReward({reward_id = reward_id}, cb)
end

function TraitorBossUI:HideRewardPanel()
    self.reward_panel:SetActive(false)
    self.mask:SetActive(false)
    self:DelObjDict(self.reward_obj_list)
    self.reward_obj_list = {}
    self:RemoveEffectList(self.reward_effect_list)
    self.reward_effect_list = {}
end
--  奖励end

--  跨服boss
function TraitorBossUI:ShowCrossBossUI()
    self.down_challenge_time_frame:SetActive(true)
    self.cross_boss_frame:SetActive(true)
    self.hurt_box:SetActive(false)
    SpecMgrs.msg_mgr:SendEnterCrossTraitorBoss(nil, nil)
    self:ClearCrossBossRes()
    self.pos_item_list = {}
    self.pos_unit_list = {}
    for i = 1, CSConst.CrossTraitorBossPosNum do
        local item = self:GetUIObject(self.player_temp, self.player_point_list[i])
        table.insert(self.pos_item_list, item)
    end

    self.cross_boss_unit = self:AddFullUnit(self.cross_boss_show_unit, self.boss_rect)
    local cb = function(resp)
        if not self.is_res_ok or not self.cross_boss_frame.activeSelf then return end
        self:UpdateCrossBossUI(resp)
    end
    SpecMgrs.msg_mgr:SendGetCrossTraitorBossData(nil, cb)
end

function TraitorBossUI:UpdateCrossBossUI(data)
    if data then
        self.cross_boss_info = data
        self.dy_boss_data:UpdateCrossCoolingTs(data)
    else
        self.cross_boss_info = self.dy_boss_data.cross_traitor_info
    end
    for i = 1, CSConst.CrossTraitorBossPosNum do
        local pos_info = self.cross_boss_info.pos_dict[i]
        local item = self.pos_item_list[i]
        if next(pos_info) then
            item:FindChild("PlayerNameText"):SetActive(true)
            item:FindChild("BattleScore"):SetActive(true)
            item:FindChild("ProtectText"):SetActive(true)
            item:FindChild("Emtpy"):SetActive(false)
            local unit_id = SpecMgrs.data_mgr:GetRoleLookData(pos_info.role_id).unit_id
            item:FindChild("PlayerNameText"):GetComponent("Text").text = string.format(UIConst.Text.PLAYER_NAME_FORMAT, pos_info.role_name, pos_info.server_id)
            item:FindChild("BattleScore/BattleScoreText"):GetComponent("Text").text = string.format(UIConst.Text.SCORE_FORMAT_TEXT, UIFuncs.AddCountUnit(pos_info.fight_score))

            local unit = nil
            if self.pos_unit_list[i] then
                if self.pos_unit_list[i].unit_id == unit_id then
                    unit = self.pos_unit_list[i]
                else
                    self:RemoveUnit(self.pos_unit_list[i])
                    self.pos_unit_list[i] = nil
                end
            end
            if not unit then
                unit = self:AddFullUnit(unit_id, item:FindChild("UnitRect"))
                self.pos_unit_list[i] = unit
            end
        else
            item:FindChild("PlayerNameText"):SetActive(false)
            item:FindChild("BattleScore"):SetActive(false)
            item:FindChild("ProtectText"):SetActive(false)
            item:FindChild("Emtpy"):SetActive(true)
            self:RemoveUnit(self.pos_unit_list[i])
            self.pos_unit_list[i] = nil
        end
        self:AddClick(item:FindChild("ChallengeBtn"), function()
            self:OccupyPos(i)
        end)
    end
end

function TraitorBossUI:OccupyPos(index)
    if not self:CheckCanChallenge() then return end
    local pos_info = self.cross_boss_info.pos_dict[index]
    if pos_info then
        if ComMgrs.dy_data_mgr:ExGetRoleUuid() == pos_info.uuid then
            return
        end
        if pos_info.protect_ts then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.IS_IN_PROTECT_STATE)
            return
        end
    end
    SpecMgrs.msg_mgr:SendMsg("SendCrossTraitorBossOccupyPos", {pos_id = index}, function(resp)
        if not self.is_res_ok or not self.cross_boss_frame.activeSelf then return end
        if not resp.fight_data then return end
        SpecMgrs.ui_mgr:EnterHeroBattle(resp.fight_data, UIConst.BattleScence.TraitorBossUI)
        SpecMgrs.ui_mgr:RegiseHeroBattleEnd("TraitorBossUIPlayer", function()
            local param_tb = {
                is_win = resp.is_win,
                win_tip = resp.is_win and UIConst.Text.BATTLE_WIN_TIP,
            }
            SpecMgrs.ui_mgr:AddCloseBattlePopUpList("BattleResultUI", param_tb)
        end)
    end)
end

function TraitorBossUI:UpdateCrossBossCountDown()
    if not self.cross_boss_info then return end
    self.battle_count_down_text.text = self:GetCountDownStr(self.cross_boss_info.fight_ts, UIConst.Text.CROSS_BOSS_COUNT_DOWN_FORMAT)
    self.challenge_count_down_text.text = self:GetCountDownStr(self.dy_boss_data.challenge_cooling_ts, UIConst.Text.CROSS_BOSS_CHALLENGE_COUNT_DOWN_FORMAT)
    for k, item in ipairs(self.pos_item_list) do
        local end_ts = self.cross_boss_info.pos_dict[k] and self.cross_boss_info.pos_dict[k].protect_ts or 0
        item:FindChild("ProtectText"):GetComponent("Text").text = self:GetCountDownStr(end_ts, UIConst.Text.PROTECT_TIME_FORMAT)
    end
end

function TraitorBossUI:GetCountDownStr(end_time, count_down_format, finish_str)
    end_time = end_time or 0
    local ts = end_time - Time:GetServerTime()
    if ts < 0 then return finish_str or "" end
    return string.format(count_down_format, UIFuncs.TimeDelta2Str(ts, 3))
end

function TraitorBossUI:ClearCrossBossRes()
    self:RemoveUnitList(self.pos_unit_list)
    self.pos_unit_list = {}
    self:DelObjDict(self.pos_item_list)
    self.pos_item_list = {}
end

function TraitorBossUI:BattleWithCrossBoss()
    local fight_info = self.dy_boss_data.cross_traitor_fight_info
    ComMgrs.dy_data_mgr.bag_data:SetShowAddBagItem(false)
    if SpecMgrs.ui_mgr:IsInBattleScence() then  -- 在战斗中 待修改
        SpecMgrs.msg_mgr:SendStageFightEnd(nil, nil)
        return
    end
    SpecMgrs.ui_mgr:EnterHeroBattle(fight_info.fight_data, UIConst.BattleScence.TraitorBossUI)
    SpecMgrs.ui_mgr:RegiseHeroBattleEnd("TraitorBossUICrossBoss", function()
        local param_tb = {
            is_win = fight_info.is_win,
            win_tip = fight_info.is_win and UIConst.Text.BATTLE_WIN_TIP,
            reward_dict = fight_info.reward_dict,
        }
        SpecMgrs.ui_mgr:AddCloseBattlePopUpList("BattleResultUI", param_tb)
        ComMgrs.dy_data_mgr.bag_data:SetShowAddBagItem(true)
    end)
end

function TraitorBossUI:HideCrossBossUI()
    self:ClearCrossBossRes()
    self:RemoveUnit(self.cross_boss_unit)
    self.cross_boss_frame:SetActive(false)
    SpecMgrs.msg_mgr:SendQuitCrossTraitorBoss(nil, nil)
end

--  跨服boss end
function TraitorBossUI:CheckCanChallenge()
    if self.dy_boss_data.challenge_time == 0 then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.NOT_CHALLENGE_TIME_TIP)
        return false
    end
    return true
end

function TraitorBossUI:CheckCanTurnCrossBoss(is_show_tip)
    if self.cur_info.cross_boss_button == 0 then
        return true
    elseif self.cur_info.cross_boss_button == 1 then
        if is_show_tip then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.CROSS_BOSS_NOT_OPEN_TIP)
        end
        return false
    elseif self.cur_info.cross_boss_button == 2 then
        if is_show_tip then
            SpecMgrs.ui_mgr:ShowTipMsg(string.format(UIConst.Text.SWITCH_BOSS_TIP, UIFuncs.AddCountUnit(self.cross_traitor_boss_hurt), UIFuncs.AddCountUnit(self.cross_traitor_boss_fight_score)))
        end
        return false
    end
end

function TraitorBossUI:BuyChallengeTime()
    local max_buy_time = CSFunction.get_tratior_challenge_buy_time(ComMgrs.dy_data_mgr.vip_data:GetVipLevel())
    if max_buy_time == self.buy_challenge_num then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.NO_BUY_TIME_TEXT)
        return
    end
    local cost_item_id = SpecMgrs.data_mgr:GetAllTraitorBossCNData()[1].cost_item
    if not UIFuncs.CheckItemCount(cost_item_id, SpecMgrs.data_mgr:GetAllTraitorBossCNData()[self.buy_challenge_num + 1].cost_num, true) then return end
    local data = {
        title = UIConst.Text.BUT_BOSS_CHALLENGE_COUNT,
        get_content_func = function (select_num)
            local cost_dict = {}
            local count = 0
            local buy_time = self.buy_challenge_num
            for i = buy_time + 1, buy_time + select_num do
                count = count + SpecMgrs.data_mgr:GetAllTraitorBossCNData()[i].cost_num
            end
            local item_data = SpecMgrs.data_mgr:GetItemData(cost_item_id)
            local cost_str = string.format(UIConst.Text.COST_ITEM_FORMAT, item_data.name, count)
            local ret_str = string.format(UIConst.Text.BUT_BOSS_CHALLENGE_COUNT_FORMAT, cost_str, select_num)

            cost_dict[cost_item_id] = count
            return {item_dict = cost_dict, desc_str = ret_str}
        end,
        max_select_num = max_buy_time - self.buy_challenge_num,
        confirm_cb = function (select_num)
            SpecMgrs.msg_mgr:SendBuyTraitorBossChallengeNum({buy_num = select_num}, function(resp)
                if not self.is_res_ok then return end
                self.dy_boss_data.challenge_time = resp.challenge_num
                self.buy_challenge_num = resp.buy_challenge_num
                self.today_challenge_time_text.text = string.format(UIConst.Text.BOSS_CHALLENGE_TIME_FORMAT, resp.challenge_num)
            end)
        end,
    }
    SpecMgrs.ui_mgr:ShowSelectItemUseByTb(data)
end

function TraitorBossUI:SetTextVal()
    self.cross_server_rank_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CROSS_SERVER_RANK_TEXT
    self.reward_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.REWARD_TEXT
    self.my_server_rank_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SERVER_RANK_TEXT
    self.change_boss_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.BOSS_CHANGE_TEXT
    self.array_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.LINEUP
    self.battle_mes_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.BATTLE_REPORT_TEXT
    self.skip_battle_text.text = UIConst.Text.SKIP_BATTLE
    self.boss_score_rank_text.text = UIConst.Text.BOSS_SCROE_RANK_TEXT
    self.boss_death_text.text = UIConst.Text.BOSS_DEATH_TEXT

    self.server_option:FindChild("Text"):GetComponent("Text").text = self.traitor_boss_name
    self.cross_server_option:FindChild("Text"):GetComponent("Text").text = self.cross_traitor_boss_name
    self.record_panel_title.text = UIConst.Text.BOSS_BATTLE_RECORD
    self.reward_panel_title.text = UIConst.Text.BOSS_REWARD_TITLE
    self.reward_panel_content_temp:FindChild("AwardNotReach/Text"):GetComponent("Text").text = UIConst.Text.NOT_FINISH_TEXT
    self.reward_panel_content_temp:FindChild("AwardReach/Text"):GetComponent("Text").text = UIConst.Text.ALREADY_RECEIVE_TEXT
    self.reward_panel_content_temp:FindChild("ReciveBtn/Text"):GetComponent("Text").text = UIConst.Text.RECEIVE_TEXT
    self.one_key_recive_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ONEKEY_RECEIVE_TEXT
    self.cross_boss_name_text.text = self.cross_traitor_boss_name
    self.player_temp:FindChild("Emtpy/Text"):GetComponent("Text").text = UIConst.Text.BOSS_LINE_UP
    self.cross_server_record_text_title.text = self.cross_traitor_boss_name
end

function TraitorBossUI:Hide()
    self.float_mes:ClearRes()
    ComMgrs.dy_data_mgr.traitor_boss_data:UnregisterUpdateTraitorBossInfo("TraitorBossUI")
    ComMgrs.dy_data_mgr.traitor_boss_data:UnregisterTraitorBossInfoRevive("TraitorBossUI")
    ComMgrs.dy_data_mgr.traitor_boss_data:UnregisterUpdateCrossTraitorFight("TraitorBossUI")
    ComMgrs.dy_data_mgr.traitor_boss_data:UnregisterUpdateCrossTraitorInfo("TraitorBossUI")
    ComMgrs.dy_data_mgr.traitor_boss_data:UnregisterUpdateTraitorChallengeNum("TraitorBossUI")
    if self.cross_boss_frame.activeSelf then
        SpecMgrs.msg_mgr:SendQuitCrossTraitorBoss(nil, nil)
    end
    TraitorBossUI.super.Hide(self)
end

return TraitorBossUI
