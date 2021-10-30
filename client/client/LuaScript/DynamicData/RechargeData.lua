local EventUtil = require("BaseUtilities.EventUtil")
local UIConst = require("UI.UIConst")
local CSConst = require("CSCommon.CSConst")
local ItemUtil = require("BaseUtilities.ItemUtil")
local UIFuncs = require("UI.UIFuncs")
local RechargeData = class("DynamicData.RechargeData")

EventUtil.GeneratorEventFuncs(RechargeData, "UpdateFirstRechargeEvent")
EventUtil.GeneratorEventFuncs(RechargeData, "UpdateSingleRechargeInfo")

EventUtil.GeneratorEventFuncs(RechargeData, "EndSingleRechargeInfo")
EventUtil.GeneratorEventFuncs(RechargeData, "CloseSingleRechargeInfo")

EventUtil.GeneratorEventFuncs(RechargeData, "UpdateRechargeDrawInfo")

EventUtil.GeneratorEventFuncs(RechargeData, "UpdateLuxuryCheckin")
EventUtil.GeneratorEventFuncs(RechargeData, "UpdateAccumRecharge")

-- [ "daily_recharge_activity_list" ] = {
-- },
-- [ "first_recharge_activity" ] = 1,
-- [ "recharge_draw_activity" ] = 10,
    -- [ "accum_recharge_activity" ] = 9,
    -- [ "luxury_check_activity" ] = 11,

function RechargeData:DoInit()
    self.is_first_recharge = false
    self.daily_recharge_dict = {}
    self.first_recharge_state = {}
    self.recharge_draw_info = {}
    self.daliy_recharge_system_name_dict = {}
    self.accum_recharge_info = {}
    self.luxury_recharge_info = {}

    local activity_id = SpecMgrs.data_mgr:GetTLActivityData("first_recharge_activity")
    self.first_recharge_name = SpecMgrs.data_mgr:GetTLActivityData(activity_id).system_name

    activity_id = SpecMgrs.data_mgr:GetTLActivityData("recharge_draw_activity")
    self.recharge_draw_name = SpecMgrs.data_mgr:GetTLActivityData(activity_id).system_name

    local activity_id_list = SpecMgrs.data_mgr:GetTLActivityData("daily_recharge_activity_list")
    for i, v in ipairs(activity_id_list) do
        local data = SpecMgrs.data_mgr:GetTLActivityData(v)
        if data.recharge_activity == SpecMgrs.data_mgr:GetRechargeActivityData("accum_recharge_activity") then
            self.accum_recharge_name = data.system_name
        elseif data.recharge_activity == SpecMgrs.data_mgr:GetRechargeActivityData("luxury_check_activity") then
            self.luxury_check_name = data.system_name
        else
            self.daliy_recharge_system_name_dict[data.recharge_activity] = data.system_name
        end
    end
end

function RechargeData:UpdateFirstRechargeState(msg)
    self.first_recharge_state = msg.recharge_info
end

function RechargeData:UpdateFirstRechargeInfo(is_first_recharge)
    self.is_first_recharge = is_first_recharge
    self:DispatchUpdateFirstRechargeEvent()

    SpecMgrs.redpoint_mgr:SetControlIdActive(self.first_recharge_name, {self.is_first_recharge and 1 or 0})
    ComMgrs.dy_data_mgr.tl_activity_data:UpdateRechargeActivitySwitch()
end

function RechargeData:UpdateSingleRechargeInfo(msg)
    self.daily_recharge_dict = msg.recharge_dict
    self:DispatchUpdateSingleRechargeInfo()
    for id, v in pairs(self.daily_recharge_dict) do
        local have_red_point = self:CheckSingleRechargeRedPoint(id)
        local system_name = self.daliy_recharge_system_name_dict[id]
        SpecMgrs.redpoint_mgr:SetControlIdActive(system_name, {have_red_point and 1 or 0})
    end
end

function RechargeData:CheckSingleRechargeRedPoint(activity_id)
    local ret = false
    local info = self.daily_recharge_dict[activity_id]
    for i, v in pairs(info.reach_dict) do
        if v > 0 then
            ret = true
        end
    end
    return ret
end

function RechargeData:EndRechargeActivity()
    self:DispatchEndSingleRechargeInfo()
    ComMgrs.dy_data_mgr.tl_activity_data:UpdateRechargeActivitySwitch()
end

function RechargeData:CloseRechargeActivity()
    self:DispatchCloseSingleRechargeInfo()
    ComMgrs.dy_data_mgr.tl_activity_data:UpdateRechargeActivitySwitch()
end

function RechargeData:GetDailyRechargeState(activity_id, recharge_rank)
    local limit_time = SpecMgrs.data_mgr:GetSingleRechargeData(recharge_rank).limit_num
    local time = limit_time - self.daily_recharge_dict[activity_id].receive_count_dict[recharge_rank]
    local receive_num = self.daily_recharge_dict[activity_id].reach_dict[recharge_rank]
    return {remain_time = time, can_recive = receive_num > 0}
end

function RechargeData:CheckDailyRechargeOpen(recharge_activity_id)
    local data = SpecMgrs.data_mgr:GetRechargeActivityData(recharge_activity_id)
    if data.activity_type == CSConst.RechargeActivity.LuxuryCheckin then
        return self:CheckLuxuryCheckinIsOpen()
    elseif data.activity_type == CSConst.RechargeActivity.AccumeRecharge then
        return self:CheckAccumRechargeIsOpen()
    end
    if not data.activity_start_timestamp then
        return true
    end
    if Time:GetServerTime() >= data.activity_start_timestamp and Time:GetServerTime() <= data.activity_close_timestamp then
        return true
    end
    return false
end

-- 抽奖
--  开启
function RechargeData:CheckRechargeDrawOpen(activity_id)
    local data = SpecMgrs.data_mgr:GetRechargeActivityData(activity_id)
    if Time:GetServerTime() >= data.activity_start_timestamp and Time:GetServerTime() <= data.activity_close_timestamp then
        return true
    end
    return false
end

function RechargeData:UpdateRechargeDrawInfo(msg)
    for k,v in pairs(msg) do
        self.recharge_draw_info[k] = v
    end
    local activity_data = SpecMgrs.data_mgr:GetRechargeActivityData(self.recharge_draw_info.activity_id)
    local recharge_count = self.recharge_draw_info.recharge_count
    local recharge_index = nil
    for i = #activity_data.recharge_count_list, 1, -1 do
        if recharge_count >= activity_data.recharge_count_list[i] and not recharge_index then
            recharge_index = i
        end
    end
    local draw_need_count = activity_data.draw_diff_count[recharge_index]
    local next_draw_need_count = draw_need_count - (recharge_count - activity_data.recharge_count_list[recharge_index]) % draw_need_count

    self.recharge_draw_info.draw_need_count = draw_need_count
    self.recharge_draw_info.next_draw_need_count = next_draw_need_count
    self:DispatchUpdateRechargeDrawInfo()

    local have_red_point = self:CheckRechargeDraw(self.recharge_draw_info)
    SpecMgrs.redpoint_mgr:SetControlIdActive(self.recharge_draw_name, {have_red_point and 1 or 0})
end

function RechargeData:CheckRechargeDraw(info)
    if info.draw_count > 0 then
        return true
    end
    return self:CheckCanBuyRechargeDraw()
end

function RechargeData:CheckCanBuyRechargeDraw()
    local can_buy = false
    local shop_list = SpecMgrs.data_mgr:GetAllDrawShopData()
    for k, data in ipairs(shop_list) do
        local buy_time = ComMgrs.dy_data_mgr:ExGetDrawShopBuyTime()[data.id] or 0
        if data.forever_num then
            local can_buy_time = data.forever_num - buy_time
            if can_buy_time > 0 then
                if UIFuncs.CheckItemCount(data.cost_item_list[1], data.cost_item_value[1]) then
                    can_buy = true
                end
            end
        else
            if UIFuncs.CheckItemCount(data.cost_item_list[1], data.cost_item_value[1]) then
                can_buy = true
            end
        end
    end
    return can_buy
end

--  累充
function RechargeData:NotifyUpdateAccumRecharge(msg)
    for k, v in pairs(msg) do
        self.accum_recharge_info[k] = v
    end
    local have_red_point = false
    for k, state in pairs(self.accum_recharge_info.reward_state_dict) do
        if state == CSConst.RewardState.pick then
            have_red_point = true
        end
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(self.accum_recharge_name, {have_red_point and 1 or 0})
    self:DispatchUpdateAccumRecharge()
end

function RechargeData:GetAccumRechargeList()
    local ret = {}
    for k, v in pairs(self.accum_recharge_info.reward_state_dict) do
        table.insert(ret, SpecMgrs.data_mgr:GetSingleRechargeData(k))
    end
    table.sort(ret, function(a, b)
        return a.id < b.id
    end)
    return ret
end

function RechargeData:GetAccumRechargeRewardID(id)
    return SpecMgrs.data_mgr:GetSingleRechargeData(id).reward_list[self.accum_recharge_info.level_gear]
end

function RechargeData:GetAccumRechargeState(recharge_rank)
    local remain_time = 1
    if self.accum_recharge_info.reward_state_dict[recharge_rank] == CSConst.RewardState.picked then
        remain_time = 0
    end
    return {remain_time = remain_time, can_recive = self.accum_recharge_info.reward_state_dict[recharge_rank] == CSConst.RewardState.pick}
end

function RechargeData:GetAccumRechargeAmount()
    return self.accum_recharge_info.recharge_amount
end

function RechargeData:GetAccumRechargeStopTs()
    return self.accum_recharge_info.stop_ts
end

function RechargeData:GetAccumRechargeEndTs()
    return self.accum_recharge_info.end_ts
end

function RechargeData:CheckAccumRechargeIsEnd()
    return self.accum_recharge_info.state ~= CSConst.ActivityState.started
end

function RechargeData:CheckAccumRechargeIsOpen()
    return next(self.accum_recharge_info) and Time:GetServerTime() < self.accum_recharge_info.end_ts
end

-- 豪华签到
function RechargeData:NotifyUpdateLuxuryCheckin(msg)
    --local recharge_activity_data = self:GetRechargeActivityData("luxury_check_activity")
    for k, v in pairs(msg.checkin_data) do
        for j, v1 in pairs(msg.checkin_data[k]) do
            if not self.luxury_recharge_info[k] then
                self.luxury_recharge_info[k] = {}
            end
            self.luxury_recharge_info[k][j] = v1
        end
    end
    local have_red_point = false
    for i,v in pairs(self.luxury_recharge_info) do
        if v.reward_state == CSConst.RewardState.pick then
            have_red_point = true
        end
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(self.luxury_check_name, {have_red_point and 1 or 0})
    self:DispatchUpdateLuxuryCheckin()
end

function RechargeData:GetLuxuryCheckList()
    local ret = {}
    for k, v in pairs(self.luxury_recharge_info) do
        table.insert(ret, SpecMgrs.data_mgr:GetSingleRechargeData(k))
    end
    table.sort(ret, function(a, b)
        return a.recharge_rank < b.recharge_rank
    end)
    return ret
end

function RechargeData:GetLuxuryCheckRewardID(id)
    return self.luxury_recharge_info[id].reward_id
end

function RechargeData:GetLuxuryRechargeState(recharge_rank)
    local time = self.luxury_recharge_info[recharge_rank].recharge_times
    return {remain_time = time, can_recive = self.luxury_recharge_info[recharge_rank].reward_state == CSConst.RewardState.pick}
end

function RechargeData:GetRechargeActivityData(key)
    local recharge_activity_id = SpecMgrs.data_mgr:GetRechargeActivityData(key)
    return SpecMgrs.data_mgr:GetRechargeActivityData(recharge_activity_id)
end

function RechargeData:CheckLuxuryCheckinIsOpen()
    return self.luxury_recharge_info ~= {}
end

return RechargeData