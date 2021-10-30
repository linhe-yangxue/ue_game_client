local EventUtil = require("BaseUtilities.EventUtil")
local UIConst = require("UI.UIConst")
local CSConst = require("CSCommon.CSConst")
local CheckData = class("DynamicData.CheckData")

EventUtil.GeneratorEventFuncs(CheckData, "UpdateWeekCheck")
EventUtil.GeneratorEventFuncs(CheckData, "UpdateMonthCheck")
EventUtil.GeneratorEventFuncs(CheckData, "UpdateFirstWeekCheck")

local first_week_sub_id_format = "%sDay%s"

function CheckData:DoInit()
    self.week_check_info = {}
    self.month_check_info = {}
    self.first_week_check_info = {}
end

-- 每周签到
function CheckData:NotifyUpdateWeekCheckInfo(msg)
    for k,v in pairs(msg) do
        self.week_check_info[k] = v
    end
    self.week_check_info = msg
    self:DispatchUpdateWeekCheck()
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Welfare.WeekCheck, {self:CheckWeekCheckCanRecive() and 1 or 0})
end

function CheckData:CheckWeekCheckCanRecive()
    if not next(self.week_check_info) then return false end
    for i, v in ipairs(self.week_check_info.check_in_reward) do
        if v == CSConst.RewardState.pick then
            return true
        end
    end
    return false
end

--  每月签到
function CheckData:NotifyUpdateMonthCheckInfo(msg)
    for k,v in pairs(msg) do
        self.month_check_info[k] = v
    end
    self.month_check_info.check_in_count = self.month_check_info.check_in_count or 0
    self:DispatchUpdateMonthCheck()
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Welfare.MonthCheck, {self:CheckMonthCheckCanRecive() and 1 or 0})
end

function CheckData:CheckMonthCheckCanRecive()
    if not next(self.month_check_info) then return false end
    for i,v in ipairs(self.month_check_info.check_in_date_reward) do
        if Time:GetServerDate().day == i and v == CSConst.RewardState.pick then
            return true
        end
        if v == CSConst.RewardState.pick and self.month_check_info.replenish_remain_today > 0 and self.month_check_info.replenish_num > 0 then
            return true
        end
    end
    for i, v in ipairs(self.month_check_info.check_in_chest_reward) do
        if v == CSConst.RewardState.pick then
            return true
        end
    end
    return false
end

--  首周
function CheckData:NotifyUpdateFirstWeekCheckInfo(msg)
    for k,v in pairs(msg) do
        self.first_week_check_info[k] = v
    end
    local end_day_count = SpecMgrs.data_mgr:GetParamData("max_recive_day").f_value
    self.first_week_check_end_time = self.first_week_check_info.start_time + (CSConst.Time.Day * end_day_count)
    local day_sell_dict = {}
    for i = 1, #self.first_week_check_info.daily_sell do
        local sell_info = self.first_week_check_info.daily_sell[i]
        day_sell_dict[i] = sell_info.sell_info
    end
    self.first_week_check_info.day_sell_dict = day_sell_dict

    local start_time = self:GetDayWholePointTime(self.first_week_check_info.start_time)
    local day_index = math.ceil((Time:GetServerTime() - start_time) / CSConst.Time.Day)
    self.first_week_check_info.day_index = day_index
    self:DispatchUpdateFirstWeekCheck()
    self:_UpdateFirstWeekRedPoint()
end

function CheckData:CheckFirstWeekCheckOpen()
    if not self.first_week_check_end_time then return false end
    local end_day_count = SpecMgrs.data_mgr:GetParamData("max_recive_day").f_value
    return Time:GetServerTime() < self.first_week_check_end_time
end

function CheckData:GetFirstWeekCheckRemainTime()
    if not self.first_week_check_end_time then return end
    return self.first_week_check_end_time - Time:GetServerTime()
end

function CheckData:GetDayWholePointTime(time)
    local date = os.date("*t", time)
    return os.time({year = date.year, month = date.month, day = date.day, hour = 0})
end

--刷新首周签到红点
function CheckData:_UpdateFirstWeekRedPoint()
    if not next(self.first_week_check_info) then return end
    local param_dict = {}
    for day = 1, self.first_week_check_info.day_index do
        local state_dict = self:_CheckDayRecive(day)
        if state_dict and next(state_dict) then
            param_dict[day] = 1
            for index, state in pairs(state_dict) do
                local sub_id = string.format(first_week_sub_id_format, day, index)
                param_dict[sub_id] = state
            end
        end
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Welfare.FirstWeek, param_dict)
end

--检查该天是否有可以领取的奖励
function CheckData:_CheckDayRecive(day)
    local day_data = SpecMgrs.data_mgr:GetFirstWeekData(day)
    if not day_data then return end
    local state_dict = {}
    for index, task_list in ipairs(day_data.task_id_list) do
        for i, id in ipairs(task_list) do
            local task_data = SpecMgrs.data_mgr:GetFirstWeekTaskData(id)
            if not self.first_week_check_info.recive_dict[id] and task_data.require_count <= self.first_week_check_info.task_dict[task_data.task_type] then
                state_dict[index] = 1
                break
            end
        end
    end
    return state_dict
end

function CheckData:CheckDayOptionCanRecive(day, index)
    local day_data = SpecMgrs.data_mgr:GetFirstWeekData(day)
    if index > #day_data.task_id_list then return false end
    local can_recive = false
    local task_list = day_data.task_id_list[index]
    for i, id in ipairs(task_list) do
        local task_data = SpecMgrs.data_mgr:GetFirstWeekTaskData(id)
        if not self.first_week_check_info.recive_dict[id] and task_data.require_count <= self.first_week_check_info.task_dict[task_data.task_type] then
            can_recive = true
        end
    end
    return can_recive
end

function CheckData:GetSellNum(sell_id, day)
	return self.first_week_check_info.day_sell_dict[day][sell_id]
end

function CheckData:NotifyUpdateFirstWeekTaskInfo(msg)
    self.first_week_check_info.task_dict[msg.task_type] = msg.progress
    self:_UpdateFirstWeekRedPoint()
end

return CheckData