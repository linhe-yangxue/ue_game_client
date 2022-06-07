local EventUtil = require("BaseUtilities.EventUtil")
local UIConst = require("UI.UIConst")
local CSFunction = require("CSCommon.CSFunction")

local DynastyData = class("DynamicData.DynastyData")

EventUtil.GeneratorEventFuncs(DynastyData, "UpdateDynastyInfoEvent")
EventUtil.GeneratorEventFuncs(DynastyData, "UpdateQuitTsEvent")
EventUtil.GeneratorEventFuncs(DynastyData, "JoinDynastyEvent")
EventUtil.GeneratorEventFuncs(DynastyData, "KickedOutDynastyEvent")
EventUtil.GeneratorEventFuncs(DynastyData, "UpdateDynastyJobEvent")
EventUtil.GeneratorEventFuncs(DynastyData, "UpdateApplyEvent")
EventUtil.GeneratorEventFuncs(DynastyData, "UpdateDynastyBuildInfoEvent")
EventUtil.GeneratorEventFuncs(DynastyData, "UpdateDynastyApplyEvent")
EventUtil.GeneratorEventFuncs(DynastyData, "UpdateDynastyActiveEvent")
EventUtil.GeneratorEventFuncs(DynastyData, "UpdateDynastyChallengeInfoEvent")
EventUtil.GeneratorEventFuncs(DynastyData, "UpdateDynastyBattleInfoEvent")
EventUtil.GeneratorEventFuncs(DynastyData, "DynastyBattleEndEvent")

function DynastyData:DoInit()
    self.dynasty_battle_apply_day = tonumber(SpecMgrs.data_mgr:GetParamData("dynasty_compete_apply_day").str_value)
    self.dynasty_battle_start_day = SpecMgrs.data_mgr:GetParamData("dynasty_compete_fight_day").day_dict
    self.dynasty_battle_start_time = SpecMgrs.data_mgr:GetParamData("dynasty_compete_start_time").f_value * CSConst.Time.Hour
    self.apply_dict = {}
    self.apply_count = 0
    self.task_dict = {}
    self.member_dict = {}
    self.apply_dynasty_dict = {} --玩家申请的王朝
    self.dynasty_apply_dict = {} --申请进入玩家王朝的其他玩家
    self.self_spell_dict = {}
    self.dynasty_spell_dict = {}
    self.build_progress_reward = {}
    self.max_hp = 0
    for _, building_data in ipairs(SpecMgrs.data_mgr:GetAllDynastyBuildingData()) do
        self.max_hp = self.max_hp + building_data.building_hp
    end
    ComMgrs.dy_data_mgr:RegisterUpdateCurrencyEvent("DynastyData", self.UpdateCurrencyListener, self)
end

-- msg recieve -------------------
function DynastyData:NotifyUpdateDynastyInfo(msg)
    if msg.apply_dict then
        self.apply_dynasty_dict = msg.apply_dict
        self:CalcApplyCount()
    end
    if msg.dynasty_id then self.dynasty_id = msg.dynasty_id end
    self:NotifyUpdateDynastyActiveInfo(msg)
    self:NotifyUpdateDynastyBuildInfo(msg)
    if msg.spell_dict then self.self_spell_dict = msg.spell_dict end
    self:_UpdateLearnRedPoint()
end

function DynastyData:NotifyUpdateDynastyActiveInfo(msg)
    if msg.daily_active then self.daily_active = msg.daily_active end
    if msg.active_reward then self.active_reward = msg.active_reward end
    if msg.task_dict then
        for task_type, task_data in pairs(msg.task_dict) do
            self.task_dict[task_type] = task_data
        end
        self:UpdateTaskList()
    end
    self:DispatchUpdateDynastyActiveEvent()
    self:_UpdateActiveRedPoint()
end

function DynastyData:NotifyUpdateDynastyBuildInfo(msg)
    if msg.build_type then self.build_type = msg.build_type end
    if msg.build_progress_reward then self.build_progress_reward = msg.build_progress_reward end
    if msg.build_type or msg.build_progress_reward then
        self:DispatchUpdateDynastyBuildInfoEvent()
        self:_UpdateBuildRedPoint()
    end
end

function DynastyData:NotifyUpdateDynastyQuitTs(msg)
    self.quit_ts = msg.quit_ts
end

function DynastyData:NotifyJoinDynasty(msg)
    self.dynasty_id = msg.dynasty_id
    self:DispatchJoinDynastyEvent(self.dynasty_id)
    self:_UpdateBuildRedPoint()
end

function DynastyData:NotifyKickedOutDynasty(msg)
    self.dynasty_id = msg.dynasty_id
    self:DispatchKickedOutDynastyEvent()
    self:_UpdateBuildRedPoint()
end

function DynastyData:NotifyUpdateMemberApplyDict(msg)
    if msg.member_dict then
        self.member_dict = msg.member_dict
    end
    if msg.apply_dict then
        self.dynasty_apply_dict = msg.apply_dict
        self:_UpdateApplyRedPoint()
        self:DispatchUpdateDynastyApplyEvent()
    end
end

function DynastyData:NotifyUpdateMemberJob(msg)
    --if msg.member_dict then
    --    self.member_dict = msg.member_dict
    --end
    local self_uuid = ComMgrs.dy_data_mgr:ExGetRoleUuid()
    if self.member_dict and self.member_dict[self_uuid] then
        self.member_dict[self_uuid].job = msg.job
        local job_data = SpecMgrs.data_mgr:GetDynastyJobData(msg.job)
        --SpecMgrs.ui_mgr:ShowTipMsg(string.format(UIConst.Text.DYNASTY_JOB_CHANGE_FORMAT, job_data.name))
        self:_UpdateApplyRedPoint()
        self:DispatchUpdateDynastyJobEvent()
    end
end

function DynastyData:NotifyUpdateDynastySpellInfo(msg)
    self.dynasty_spell_dict = msg.spell_dict
    self:_UpdateLearnRedPoint()
end
-- msg recieve -------------------

function DynastyData:NotifyDynastyBattleClosed()
    self.dynasty_battle_closed = true
    if not self.is_playing_battle then
        SpecMgrs.ui_mgr:ShowUI("DynastyBattleReportUI")
        self:DispatchDynastyBattleEndEvent()
    end
end

function DynastyData:NotifyRefreshDynastyChallenge()
    SpecMgrs.msg_mgr:SendGetDynastyChallengeInfo({}, function (resp)
        if resp.errcode == 0 then
            local param_dict = {}
            if self:CheckHaveClearReward(resp.challenge_info) then
                param_dict.reward = 1
            end
            for chapter, _ in pairs(SpecMgrs.data_mgr:GetAllDynastyChallengeData()) do
                if self:CheckChapterHaveUnpickReward(resp.challenge_info, chapter) then
                    param_dict[chapter] = 1
                end
            end
            self:DispatchUpdateDynastyChallengeInfoEvent(resp.challenge_info)
            SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Dynasty.Challenge, param_dict)
        end
    end)
end

function DynastyData:NotifyRefreshDynastyBattle()
    self:UpdateDynastyBattleData(function (battle_info)
        local param = nil
        if battle_info.attack_num > 0 then
            param = 1
        end
        SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Dynasty.Battle, {param})
        SpecMgrs.msg_mgr:SendGetCompeteRewardInfo({}, function (resp)
            if resp.errcode == 0 and resp.compete_reward then
                local param_dict = {}
                for id, _ in ipairs(SpecMgrs.data_mgr:GetAllCompeteRewardData()) do
                    if resp.compete_reward[id] == true then
                        param_dict[id] = 1
                    end
                end
                SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Dynasty.BattleReward, param_dict)
            end
        end)
    end)
end

function DynastyData:UpdateTaskList()
    self.task_list = {}
    for task_type, task_info in pairs(self.task_dict) do
        local task_data = {task_type = task_type, task_info = task_info}
        table.insert(self.task_list, task_data)
    end
    table.sort(self.task_list, function (task1, task2)
        if task1.task_info.task_id ~= task2.task_info.task_id and not (task1.task_info.task_id and task2.task_info.task_id) then
            return task1.task_info.task_id ~= nil
        end
        if task1.task_info.is_finish ~= task2.task_info.is_finish then
            return task1.task_info.is_finish
        end
        return task1.task_type < task2.task_type
    end)
end

function DynastyData:GetTaskList()
    return self.task_list
end

function DynastyData:CalcApplyCount()
    self.apply_count = 0
    for _, apply_info in pairs(self.apply_dict) do
        self.apply_count = self.apply_count + 1
    end
end

function DynastyData:GetDynastyApplyList()
    local apply_list = {}
    for _, apply_info in pairs(self.dynasty_apply_dict) do
        table.insert(apply_list, apply_info)
    end
    table.sort(apply_list, function (apply1, apply2)
        if apply1.score ~= apply2.score then return apply1.score > apply2.score end
        return apply2.level > apply1.level
    end)
    return apply_list
end

function DynastyData:GetDynastyId()
    return self.dynasty_id
end

function DynastyData:GetApplyDataByDynastyId(dynasty_id)
    return self.apply_dynasty_dict[dynasty_id]
end

function DynastyData:GetApplyCount()
    return self.apply_count
end

function DynastyData:GetQuitTs()
    return self.quit_ts
end

function DynastyData:SetDynastyId(dynasty_id)
    self.dynasty_id = dynasty_id
end

-- 获取王朝活跃值
function DynastyData:GetDynastyDailyActive()
    return self.daily_active
end

-- 获取王朝活跃宝箱领取状态
function DynastyData:GetDynastyDailyActiveRewardState(reward_index)
    return self.active_reward[reward_index] == true
end

-- 个人技能等级
function DynastyData:GetSelfSpellLevel(spell_id)
    return self.self_spell_dict[spell_id] or 0
end

-- 王朝技能等级
function DynastyData:GetDynastySpellLevel(spell_id)
    return self.dynasty_spell_dict[spell_id] or 0
end

function DynastyData:GetBuildRewardState(reward_index)
    return self.build_progress_reward[reward_index]
end

function DynastyData:GetDynastyBuildType()
    return self.build_type
end

function DynastyData:CalcJanitorHp(hp_dict)
    local cur_hp = 0
    for _, hp in pairs(hp_dict) do
        cur_hp = cur_hp + hp
    end
    return cur_hp
end

function DynastyData:CalcOpenMapCount(cur_stage)
    local map_data_list = SpecMgrs.data_mgr:GetDynastyChallengeMapList()
    local stage_count, map_count = 0
    for i, map_data in ipairs(map_data_list) do
        stage_count = stage_count + map_data.chapter_count
        if stage_count >= cur_stage then
            map_count = i + 1
            break
        end
    end
    return map_count
end

function DynastyData:CheckHaveClearReward(challenge_info)
    for i = 1, challenge_info.max_victory_stage do
        if challenge_info.challenge_reward[i] ~= true then
            return true
        end
    end
    return false
end

function DynastyData:CheckChapterHaveUnpickReward(challenge_info, chapter)
    if not challenge_info.stage_dict[chapter] then return false end
    local chapter_data = SpecMgrs.data_mgr:GetDynastyChallengeData(chapter)
    local chapter_box_dict = challenge_info.box_dict[chapter]
    for index, janitor_id in ipairs(chapter_data.janitor_list) do
        local hp = self:CalcJanitorHp(challenge_info.stage_dict[chapter].janitor_dict[janitor_id].hp_dict)
        if hp == 0 and chapter_box_dict ~= nil and chapter_box_dict.box_dict[janitor_id] ~= true then return true end
    end
    return false
end

-- 王朝争霸
function DynastyData:UpdateDynastyBattleData(cb)
    SpecMgrs.msg_mgr:SendGetDynastyCompeteInfo({}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_DYNASTY_BATTLE_INFO_FAILED)
        else
            self.dynasty_battle_info = resp
            self.dynasty_battle_info.enemy_list = {}
            for dynasty_id, dynasty_info in pairs(self.dynasty_battle_info.enemy_dict) do
                dynasty_info.dynasty_id = dynasty_id
                table.insert(self.dynasty_battle_info.enemy_list, dynasty_info)
            end
            table.sort(self.dynasty_battle_info.enemy_list, function (dynasty_info1, dynasty_info2)
                return dynasty_info2.dynasty_id < dynasty_info1.dynasty_id
            end)
            if cb then cb(resp) end
            self:DispatchUpdateDynastyBattleInfoEvent()
        end
    end)
end

function DynastyData:CheckInApplyTime()
    return Time:GetServerWeekDay() == self.dynasty_battle_apply_day
end

function DynastyData:CheckInBattleTime()
    if not self.dynasty_battle_start_day[Time:GetServerWeekDay()] then
        return false
    end
    return self.dynasty_battle_start_time < Time:GetCurDayPassTime()
end

function DynastyData:UpdateDynastyMemberInfo(cb)
    if not self.dynasty_id then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.NOT_JOIN_DYNASTY)
        return
    end
    SpecMgrs.msg_mgr:SendGetDynastyMemberInfo({}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_DYNASTY_MEMBER_INFO_FAILED)
        else
            self.member_dict = resp.member_dict
            cb(resp.member_dict)
        end
    end)
end

function DynastyData:GetMemberList(member_dict)
    local member_list = {}
    for _, member_info in pairs(member_dict) do
        table.insert(member_list, member_info)
    end
    table.sort(member_list, function (member1, member2)
        if member1.job ~= member2.job then return member1.job < member2.job end
        if member1.score ~= member2.score then return member1.score > member2.score end
        if member1.history_dedicate ~= member2.history_dedicate then return member1.history_dedicate > member2.history_dedicate end
        return member2.level > member1.level
    end)
    return member_list
end

function DynastyData:GetSelfInfo()
    return self.member_dict[ComMgrs.dy_data_mgr:ExGetRoleUuid()]
end

function DynastyData:GetDynastyBadge()
    return self.base_info.dynasty_badge
end

function DynastyData:GetDynastyBattleEnemyList()
    return self.dynasty_battle_info.enemy_list
end

function DynastyData:UpdateDynastyBasicInfo(cb)
    SpecMgrs.msg_mgr:SendGetDynastyBasicInfo({}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_DYNASTY_BASIC_INFO_FAILED)
        else
            self.base_info = resp.dynasty_base_info
            if cb then cb(resp.dynasty_base_info) end
            self:DispatchUpdateDynastyInfoEvent(resp.dynasty_base_info)
        end
    end)
end

function DynastyData:GetDynastyBattleApplyState()
    return self.dynasty_battle_info.is_apply
end

function DynastyData:GetDynastyBattleScore()
    return {
        dynasty_total_score = self.dynasty_battle_info.dynasty_total_mark,
        personal_total_score = self.dynasty_battle_info.self_total_mark,
        personal_daily_score = self.dynasty_battle_info.self_daily_mark,
        battle_count = self.dynasty_battle_info.total_attack_num,
        pre_attack_score = self.dynasty_battle_info.attack_mark,
        pre_defend_score = self.dynasty_battle_info.defend_mark,
    }
end

-- 王朝争霸场次
function DynastyData:GetDynastyBattleIndex()
    return self.dynasty_battle_info.compete_index
end

function DynastyData:GetDynastyDefendInfo()
    local result_list = {}
    for dynasty_id, defend_info in pairs(self.dynasty_battle_info.defend_info) do
        defend_info.dynasty_id = dynasty_id
        table.insert(result_list, defend_info)
    end
    table.sort(result_list, function (info1, info2)
        return info2.dynasty_id < info1.dynasty_id
    end)
    return result_list
end

function DynastyData:GetDynastyBuildingInfo(building)
    local sort_func = function (info1, info2)
        return info1.fight_score > info2.fight_score
    end
    local merge_list_func = function (list1, list2)
        for _, info in ipairs(list2) do
            table.insert(list1, info)
        end
    end
    local result_list = {}
    for uuid, _ in pairs(self.dynasty_battle_info.building_dict[building].member_dict) do
        local member_info = self.member_dict[uuid]
        member_info.defend_building = building
        table.insert(result_list, member_info)
    end
    table.sort(result_list, sort_func)
    local empty_member_list = {}
    for uuid, member_info in pairs(self.member_dict) do
        local empty_flag = true
        for _, building_info in pairs(self.dynasty_battle_info.building_dict) do
            if building_info.member_dict[uuid] then
                empty_flag = false
                break
            end
        end
        if empty_flag then
            member_info.defend_building = nil
            table.insert(empty_member_list, member_info)
        end
    end
    table.sort(empty_member_list, sort_func)
    merge_list_func(result_list, empty_member_list)
    for i = #SpecMgrs.data_mgr:GetAllDynastyBuildingData(), 1, -1 do
        if i ~= building then
            local building_list = {}
            for uuid, _ in pairs(self.dynasty_battle_info.building_dict[i].member_dict) do
                local member_info = self.member_dict[uuid]
                member_info.defend_building = i
                table.insert(building_list, member_info)
            end
            table.sort(building_list, sort_func)
            merge_list_func(result_list, building_list)
        end
    end
    return result_list
end

function DynastyData:GetDynastyBuildingDefendCount(building)
    local defend_count = 0
    for uuid, _ in pairs(self.dynasty_battle_info.building_dict[building].member_dict) do
        defend_count = defend_count + 1
    end
    return defend_count
end

function DynastyData:GetDynastyBuildingDefenderList(dynasty_id, building)
    local result_list = {}
    for uuid, defender_info in pairs(self.dynasty_battle_info.enemy_dict[dynasty_id].building_dict[building].role_dict) do
        defender_info.uuid = uuid
        table.insert(result_list, defender_info)
    end
    table.sort(result_list, function (role1, role2)
        if role1.defend_num == role2.defend_num and role1.defend_num == 0 then
            return role2.fight_score < role1.fight_score
        end
        if role1.defend_num == 0 or role2.defend_num == 0 then
            return role1.defend_num ~= 0
        end
        return role2.fight_score < role1.fight_score
    end)
    return result_list
end

function DynastyData:GetDynastyCompetitorInfo(dynasty_id)
    return dynasty_id and self.dynasty_battle_info.enemy_dict[dynasty_id] or self.dynasty_battle_info.enemy_dict
end

-- 个人剩余攻打次数
function DynastyData:GetDynastyBattleAttackCount()
    return self.dynasty_battle_info.attack_num
end

function DynastyData:GetDynastyBuyBattleCount()
    return self.dynasty_battle_info.buy_attack_num
end

function DynastyData:CheckBuildingIsDestroyed(dynasty_id, building)
    if self.dynasty_battle_info.enemy_dict[dynasty_id].building_dict[building].building_hp == 0 then return true end
    for uuid, defender_info in pairs(self.dynasty_battle_info.enemy_dict[dynasty_id].building_dict[building].role_dict) do
        if defender_info.defend_num > 0 then return false end
    end
    return true
end

function DynastyData:CheckDynastyIsDestroyed(dynasty_id)
    for building, _ in pairs(self.dynasty_battle_info.enemy_dict[dynasty_id].building_dict) do
        if not self:CheckBuildingIsDestroyed(dynasty_id, building) then return false end
    end
    return true
end

function DynastyData:CalcDynastyExpReward()
    local reward_count = 0
    for dynasty_id, info in pairs(self.dynasty_battle_info.enemy_dict) do
        for building_id, building_info in pairs(info.building_dict) do
            if self:CheckBuildingIsDestroyed(dynasty_id, building_id) then
                reward_count = reward_count + SpecMgrs.data_mgr:GetDynastyBuildingData(building_id).dynasty_exp_reward
            end
        end
    end
    return reward_count
end

function DynastyData:CheckCanAttackHeadquarter(dynasty_id)
    for building_id, building_info in pairs(self.dynasty_battle_info.enemy_dict[dynasty_id].building_dict) do
        if self:CheckBuildingIsDestroyed(dynasty_id, building_id) then
            return true
        end
    end
    return false
end

function DynastyData:CheckJoinDynastyTimeLimit()
    return Time:GetServerTime() - self:GetSelfInfo().join_ts >= CSConst.Time.Day
end

function DynastyData:GetDynastyBattleMaxHp()
    return self.max_hp
end

function DynastyData:CalcDynastyHp(dynasty_id)
    local cur_hp = 0
    for _, building_info in pairs(self.dynasty_battle_info.enemy_dict[dynasty_id].building_dict) do
        cur_hp = cur_hp + building_info.building_hp
    end
    return cur_hp
end

function DynastyData:CalcDynastyBuildingRestDefenderCount(dynasty_id, building)
    local rest_defender_count = 0
    for _, role_info in pairs(self.dynasty_battle_info.enemy_dict[dynasty_id].building_dict[building].role_dict) do
        if role_info.defend_num > 0 then rest_defender_count = rest_defender_count + 1 end
    end
    return rest_defender_count
end

function DynastyData:CalcDynastyBuildingRestDefendCount(dynasty_id, building)
    local rest_defend_count = 0
    for _, role_info in pairs(self.dynasty_battle_info.enemy_dict[dynasty_id].building_dict[building].role_dict) do
        rest_defend_count = rest_defend_count + role_info.defend_num
    end
    return rest_defend_count
end

function DynastyData:SendBuyBattleCount()
    local cur_buy_count = self.dynasty_battle_info.buy_attack_num
    local max_buy_count = #SpecMgrs.data_mgr:GetAllCompeteNumData()
    if cur_buy_count >= max_buy_count then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.BUY_BATTLE_COUNT_LIMIT)
        return
    end
    local data = {
        title = UIConst.Text.BUY_BATTLE_COUNT,
        get_content_func = function (select_num)
            local cost_dict = {}
            for i = cur_buy_count + 1, cur_buy_count + select_num do
                local cost_data = SpecMgrs.data_mgr:GetChallengeNumData(i)
                cost_dict[cost_data.cost_item] = (cost_dict[cost_data.cost_item] or 0) + cost_data.cost_num
            end
            local cost_str
            for item_id, count in pairs(cost_dict) do
                local item_data = SpecMgrs.data_mgr:GetItemData(item_id)
                local cur_str = string.format(UIConst.Text.COST_ITEM_FORMAT, item_data.name, count)
                if not cost_str then
                    cost_str = cur_str
                else
                    cost_str = string.format(UIConst.Text.AND_VALUE, cost_str, cur_str)
                end
            end
            local ret_str = string.format(UIConst.Text.BUT_CHALLENGE_COUNT_FORMAT, cost_str, select_num)
            return {item_dict = cost_dict, desc_str = ret_str}
        end,
        max_select_num = max_buy_count - cur_buy_count,
        confirm_cb = function (select_num)
            SpecMgrs.msg_mgr:SendBuyCompeteAttackNum({buy_num = select_num}, function(resp)
                if resp.errcode ~= 0 then
                    SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.BUY_BATTLE_COUNT_FAILED)
                else
                    self:UpdateDynastyBattleData()
                end
            end)
        end,
    }
    SpecMgrs.ui_mgr:ShowSelectItemUseByTb(data)
end

function DynastyData:SetDynastyBattleState(state)
    self.is_playing_battle = state
    if not self.is_playing_battle then
        if self.dynasty_battle_closed then
            SpecMgrs.ui_mgr:ShowUI("DynastyBattleReportUI")
            self:DispatchDynastyBattleEndEvent()
        else
            self:UpdateDynastyBattleData()
        end
    end
end

--监听虚拟货币变化
function DynastyData:UpdateCurrencyListener(_, currency)
    if currency[CSConst.Virtual.Dedicate] then
        self:_UpdateLearnRedPoint()
    end
end

--王朝申请红点
function DynastyData:_UpdateApplyRedPoint()
    local count = 0
    local self_info = self:GetSelfInfo()

    if not self_info then return end
    if SpecMgrs.data_mgr:GetDynastyJobData(self_info.job).is_manager then
        for _, info in pairs(self.dynasty_apply_dict) do
            count = count + 1
        end
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Dynasty.Apply, { count })
end

--王朝建设红点
function DynastyData:_UpdateBuildRedPoint()
    if not self.dynasty_id then return end
    local param_dict = {}
    if self.build_type == 0 then
        param_dict.build = 1
    end
    for _, state in pairs(self.build_progress_reward) do
        if state then
            param_dict.reward = 1
            break
        end
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Dynasty.Build, param_dict)
end

--王朝活跃红点
function DynastyData:_UpdateActiveRedPoint()
    local param_dict = {}
    for task_type, task_data in pairs(self.task_dict) do
        if task_data.is_finish then
            param_dict[task_type] = 1
        end
    end
    for index, active_reward in ipairs(SpecMgrs.data_mgr:GetAllDynastyActiveRewardData()) do
        if self.daily_active >= active_reward.active then
            if not self.active_reward[index] then
                param_dict.reward = 1
                break
            end
        else
            break
        end
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Dynasty.Active, param_dict)
end

--王朝技能学习
function DynastyData:_UpdateLearnRedPoint()
    local param_dict = {}
    local current_dedicate = ComMgrs.dy_data_mgr:ExGetCurrencyCount(CSConst.Virtual.Dedicate)
    for spell_id, spell_level in pairs(self.dynasty_spell_dict) do
        local self_level = self.self_spell_dict[spell_id] or 0
        if self_level < spell_level then
            local cost = CSFunction.get_dynasty_spell_cost(spell_id, self_level + 1).player_cost
            if cost <= current_dedicate then
                param_dict[spell_id] = 1
            end
        end
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Dynasty.Learn, param_dict)
end

return DynastyData