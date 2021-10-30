local EventUtil = require("BaseUtilities.EventUtil")
local ActivityData = class("DynamicData.ActivityData")

EventUtil.GeneratorEventFuncs(ActivityData, "UpdateActivityStateEvent")
EventUtil.GeneratorEventFuncs(ActivityData, "UpdateRankActivityStateEvent")
EventUtil.GeneratorEventFuncs(ActivityData, "UpdateRankActivityRankingEvent")
EventUtil.GeneratorEventFuncs(ActivityData, "UpdateStrengthRecoverStateEvent")
EventUtil.GeneratorEventFuncs(ActivityData, "UpdateStrengthRecoverInfoEvent")
EventUtil.GeneratorEventFuncs(ActivityData, "UpdateServerFundCountEvent")
EventUtil.GeneratorEventFuncs(ActivityData, "UpdateServerFundRewardEvent")
EventUtil.GeneratorEventFuncs(ActivityData, "UpdateFundWelfareRewardEvent")

function ActivityData:DoInit()
    self.activity_info_dict = {}
    self.activity_reward_list = {}
    self.activity_list = {}

    self.rank_activity_info_dict = {}
    self.strength_recover_info = {}
    self.server_fund_info = {}
end

-- TL activity data
function ActivityData:NotifyUpdateActivityData(msg)
    if msg.activity_dict then
        for activity_id, activity_info in pairs(msg.activity_dict) do
            if not self.activity_info_dict[activity_id] then self.activity_info_dict[activity_id] = {} end
            if activity_info.progress_dict then
                self.activity_info_dict[activity_id].progress_dict = activity_info.progress_dict
            end
            if activity_info.reward_dict then
                self.activity_info_dict[activity_id].reward_dict = activity_info.reward_dict
                self:UpdateActivityRewardList(activity_id)
                self:UpdateActivityList(activity_id)
            end
            if activity_info.state then
                self.activity_info_dict[activity_id].state = activity_info.state
                if activity_info.state == CSConst.ActivityState.invalid then
                    self.activity_info_dict[activity_id] = nil
                end
                self:DispatchUpdateActivityStateEvent(activity_id, activity_info.state)
            end
            self:UpdateActivityRedPoint(activity_id)
        end
    end
    self:UpdateAllActivityRedPoint()
end

function ActivityData:UpdateActivityRewardList(activity_id)
    self.activity_reward_list[activity_id] = {}
    for activity, activity_progress in pairs(self.activity_info_dict[activity_id].progress_dict) do
        self.activity_reward_list[activity_id][activity] = {}
        for i, reward_id in ipairs(SpecMgrs.data_mgr:GetActivityDetailData(activity).activity_reward_list) do
            table.insert(self.activity_reward_list[activity_id][activity], reward_id)
        end
        table.sort(self.activity_reward_list[activity_id][activity], function (reward1, reward2)
            local state1 = self.activity_info_dict[activity_id].reward_dict[reward1]
            local state2 = self.activity_info_dict[activity_id].reward_dict[reward2]
            if state1 == state2 then return reward2 > reward1 end
            if state1 == CSConst.RewardState.pick or state2 == CSConst.RewardState.pick then
                return state1 == CSConst.RewardState.pick
            end
            return state2 == CSConst.RewardState.picked
        end)
    end
end

function ActivityData:UpdateActivityList(activity_id)
    self.activity_list[activity_id] = {}
    for activity, _ in pairs(self.activity_info_dict[activity_id].progress_dict) do
        table.insert(self.activity_list[activity_id], activity)
    end
    table.sort(self.activity_list[activity_id], function (activity1, activity2)
        local state1 = self:GetCurActivityState(activity_id, activity1)
        local state2 = self:GetCurActivityState(activity_id, activity2)
        if state1 == state2 then return activity2 > activity1 end
        if state1 == CSConst.RewardState.pick or state2 == CSConst.RewardState.pick then
            return state1 == CSConst.RewardState.pick
        end
        return state2 == CSConst.RewardState.picked
    end)
end

function ActivityData:GetActivityList(activity_id)
    if not activity_id then return end
    if self.activity_list[activity_id] then return self.activity_list[activity_id] end
    local activity_list = {}
    for _, activity_group in ipairs(SpecMgrs.data_mgr:GetActivityData(activity_id).activity_group_list) do
        for _, activity in ipairs(SpecMgrs.data_mgr:GetActivityGroupData(activity_group).activity_detail_list) do
            table.insert(activity_list, activity)
        end
    end
    table.sort(activity_list, function (activity1, activity2)
        return activity2 > activity1
    end)
    return activity_list
end

function ActivityData:GetActivityIndex(activity_id, cur_activity)
    local activity_list = self:GetActivityList(activity_id)
    if not activity_list then return end
    for i, activity in ipairs(activity_list) do
        if activity == cur_activity then return i end
    end
end

function ActivityData:GetActivityRewardList(activity_id, activity)
    if not activity_id or not activity then return end
    if self.activity_reward_list[activity_id] then
        return self.activity_reward_list[activity_id][activity]
    else
        return SpecMgrs.data_mgr:GetActivityDetailData(activity).activity_reward_list
    end
end

function ActivityData:GetActivityRewardIndex(activity_id, activity, reward_id)
    local reward_list = self:GetActivityRewardList(activity_id, activity)
    if not reward_list then return end
    for i, reward in ipairs(reward_list) do
        if reward == reward_id then return i end
    end
end

function ActivityData:GetActivityRewardState(activity_id, reward_id)
    if self.activity_info_dict[activity_id] then
        return self.activity_info_dict[activity_id].reward_dict[reward_id]
    else
        return CSConst.RewardState.unpick
    end
end

function ActivityData:GetActivityProgress(activity_id, activity)
    return self.activity_info_dict[activity_id] and self.activity_info_dict[activity_id].progress_dict[activity] or 0
end

function ActivityData:GetCurActivityState(activity_id, activity)
    local activity_data = SpecMgrs.data_mgr:GetActivityDetailData(activity)
    for _, reward_id in ipairs(activity_data.activity_reward_list) do
        local state = self:GetActivityRewardState(activity_id, reward_id)
        if state ~= CSConst.RewardState.picked then return state end
    end
    return CSConst.RewardState.picked
end

function ActivityData:GetCurActivityProgressIndex(activity_id, activity)
    local activity_data = SpecMgrs.data_mgr:GetActivityDetailData(activity)
    local cur_progress = self:GetActivityProgress(activity_id, activity)
    for i, progress in ipairs(activity_data.activity_cond_list) do
        if cur_progress < progress then return i end
    end
    return #activity_data.activity_reward_list
end

function ActivityData:GetProgressIndex(activity_id, reward)
    local activity_data = SpecMgrs.data_mgr:GetActivityDetailData(activity_id)
    for i, reward_id in ipairs(activity_data.activity_reward_list) do
        if reward_id == reward then return i end
    end
end

function ActivityData:UpdateActivityRedPoint(activity_id)
    local activity_data = SpecMgrs.data_mgr:GetActivityData(activity_id)
    SpecMgrs.redpoint_mgr:SetControlIdActive(activity_data.system_name, {self:CheckActivityRedPoint(activity_id) and 1 or 0})
end

function ActivityData:CheckActivityRedPoint(activity_id)
    if not self.activity_info_dict[activity_id] then return false end
    for activity, _ in pairs(self.activity_info_dict[activity_id].progress_dict) do
        if self:GetCurActivityState(activity_id, activity) == CSConst.RewardState.pick then
            return true
        end
    end
    return false
end

function ActivityData:UpdateAllActivityRedPoint()
    for activity_id, _ in pairs(self.activity_info_dict) do
        local activity_data = SpecMgrs.data_mgr:GetActivityData(activity_id)
        SpecMgrs.redpoint_mgr:SetControlIdActive(activity_data.system_name, {self:CheckActivityRedPoint(activity_id) and 1 or 0})
    end
end

function ActivityData:GetActivityState(activity_id)
    return self.activity_info_dict[activity_id] and self.activity_info_dict[activity_id].state or CSConst.ActivityState.invalid
end

function ActivityData:GetOpenActivityList()
    local activity_list = {}
    for activity_id, _ in pairs(self.activity_info_dict) do
        table.insert(activity_list, SpecMgrs.data_mgr:GetActivityData(activity_id))
    end
    table.sort(activity_list, function (activity1, activity2)
        return activity2.id > activity1.id
    end)
    return activity_list
end
-- TL activity data end


-- rank activity data
function ActivityData:NotifyUpdateRankActivityData(msg)
    for activity_id, activity_info in pairs(msg.activity_dict) do
        if not self.rank_activity_info_dict[activity_id] then
            self.rank_activity_info_dict[activity_id] = {}
        end
        if activity_info.self_rank then
            local rank = (activity_info.self_rank > 0 and activity_info.self_rank) or nil
            self.rank_activity_info_dict[activity_id].self_rank = rank
            self:DispatchUpdateRankActivityRankingEvent(activity_id, self.rank_activity_info_dict[activity_id].self_rank)
        end
        if activity_info.start_ts then
            self.rank_activity_info_dict[activity_id].start_ts = activity_info.start_ts
            self.rank_activity_info_dict[activity_id].stop_ts = activity_info.stop_ts
            self.rank_activity_info_dict[activity_id].end_ts = activity_info.end_ts
        end
        if activity_info.state then
            self.rank_activity_info_dict[activity_id].state = activity_info.state
            if activity_info.state == CSConst.ActivityState.invalid then
                self.rank_activity_info_dict[activity_id] = nil
            end
            self:DispatchUpdateRankActivityStateEvent(activity_id, activity_info.state)
        end
    end
end

-- 定时更新冲榜活动排名
function ActivityData:RefreshRankActivity(activity_id)
    SpecMgrs.msg_mgr:SendRefreshRankActivity({activity_id = activity_id}, function (resp)
        if resp.rank_dict then
            for activity, rank in pairs(resp.rank_dict) do
                local activity_rank = (rank > 0 and rank) or nil
                self.rank_activity_info_dict[activity].self_rank = activity_rank
                self:DispatchUpdateRankActivityRankingEvent(activity, activity_rank)
            end
        end
    end)
end

function ActivityData:GetRankActivityList()
    local rank_activity_list = {}
    for activity_id, activity_info in pairs(self.rank_activity_info_dict) do
        table.insert(rank_activity_list, activity_id)
    end
    table.sort(rank_activity_list, function (activity1, activity2)
        local activity_info1 = self.rank_activity_info_dict[activity1]
        local activity_info2 = self.rank_activity_info_dict[activity2]
        if activity_info1.state ~= activity_info2.state then
            return activity_info2.state < activity_info1.state
        end
        if activity_info1.start_ts ~= activity_info2.start_ts then
            return activity_info2.start_ts > activity_info1.start_ts
        end
        if activity_info1.end_ts ~= activity_info2.end_ts then
            return activity_info2.end_ts > activity_info1.end_ts
        end
        return activity2 > activity1
    end)
    return rank_activity_list
end

function ActivityData:GetNewestRankActivity()
    local rank_activity_list = self:GetRankActivityList()
    local rank_activity_count = #rank_activity_list
    if rank_activity_count == 0 then return end
    return rank_activity_list[rank_activity_count]
end

function ActivityData:GetRankActivityInfo(rank_activity_id)
    return self.rank_activity_info_dict[rank_activity_id]
end
-- rank activity end

-- strength recover
function ActivityData:NotifyUpdateStrengthRecoverActivity(msg)
    if msg.data_id then
        self.strength_recover_info.data_id = msg.data_id
        self.strength_recover_info.lover_id = msg.lover_id
        self:DispatchUpdateStrengthRecoverInfoEvent()
    end
    if msg.reward_status then
        self.strength_recover_info.reward_status = msg.reward_status
        self:DispatchUpdateStrengthRecoverStateEvent()
        SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Welfare.Strength, {self:CheckStrengthRecover() and 1 or 0})
    end
end

function ActivityData:GetStrengthRecoverLover()
    if not self.strength_recover_info.lover_id then return end
    local lover_data = SpecMgrs.data_mgr:GetLoverData(self.strength_recover_info.lover_id)
    return lover_data.unit_id
end

function ActivityData:CheckStrengthRecover()
    return self.strength_recover_info.reward_status == CSConst.RewardState.pick
end

function ActivityData:GetCurStrengthRecoverData()
    return SpecMgrs.data_mgr:GetActionPointData(self.strength_recover_info.data_id)
end
-- strength recover end

-- server fund
function ActivityData:NotifyUpdateServerFundInfo(msg)
    if msg.count then
        self.server_fund_info.count = msg.count
        self:DispatchUpdateServerFundCountEvent(self.server_fund_info.count)
    end
    if msg.fund_reward then
        self.server_fund_info.fund_reward = msg.fund_reward
        self:DispatchUpdateServerFundRewardEvent()
        self:_UpdateFundRedPoint()
    end
    if msg.welfare_reward then
        self.server_fund_info.welfare_reward = msg.welfare_reward
        self:DispatchUpdateFundWelfareRewardEvent()
        self:_UpdateWelfareRedPoint()
    end
    if msg.is_buy then self.server_fund_info.is_buy = msg.is_buy end
end

function ActivityData:GetServerFundCount()
    return self.server_fund_info.count
end

function ActivityData:GetServerFundBuyState()
    return self.server_fund_info.is_buy
end

function ActivityData:GetServerFundRewardState(reward_id)
    return self.server_fund_info.fund_reward[reward_id]
end

function ActivityData:GetServerFundTaskList()
    local task_list = {}
    for id, task_data in pairs(SpecMgrs.data_mgr:GetAllOpenServiceRewardData()) do
        table.insert(task_list, task_data)
    end
    table.sort(task_list, function (task_data1, task_data2)
        local task_state1 = self:GetServerFundRewardState(task_data1.id)
        local task_state2 = self:GetServerFundRewardState(task_data2.id)
        if task_state1 ~= task_state2 and (task_state1 == CSConst.RewardState.picked or task_state2 == CSConst.RewardState.picked) then
            return task_state2 == CSConst.RewardState.picked
        end
        return task_data2.required_level > task_data1.required_level
    end)
    return task_list
end

function ActivityData:GetFundWelfareRewardState(reward_id)
    return self.server_fund_info.welfare_reward[reward_id]
end

function ActivityData:GetFundWelfareTaskList()
    local task_list = {}
    for id, task_data in pairs(SpecMgrs.data_mgr:GetAllOpenServiceWelfareData()) do
        table.insert(task_list, task_data)
    end
    table.sort(task_list, function (task_data1, task_data2)
        local task_state1 = self:GetFundWelfareRewardState(task_data1.id)
        local task_state2 = self:GetFundWelfareRewardState(task_data2.id)
        if task_state1 ~= task_state2 and (task_state1 == CSConst.RewardState.picked or task_state2 == CSConst.RewardState.picked) then
            return task_state2 == CSConst.RewardState.picked
        end
        return task_data2.required_count > task_data1.required_count
    end)
    return task_list
end

--刷新开服基金红点
function ActivityData:_UpdateFundRedPoint()
    local param_dict = {}
    for reward_id, state in pairs(self.server_fund_info.fund_reward) do
        if state == CSConst.RewardState.pick then
            param_dict[reward_id] = 1
        end
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Welfare.ServerFund, param_dict)
end

--刷新全民福利红点
function ActivityData:_UpdateWelfareRedPoint()
    local param_dict = {}
    for reward_id, state in pairs(self.server_fund_info.welfare_reward) do
        if state == CSConst.RewardState.pick then
            param_dict[reward_id] = 1
        end
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Welfare.FundWelfare, param_dict)
end
-- server fund end

return ActivityData