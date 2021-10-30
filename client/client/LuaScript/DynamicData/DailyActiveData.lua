local EventUtil = require("BaseUtilities.EventUtil")
local DailyActiveData = class("DynamicData.DailyActiveData")

EventUtil.GeneratorEventFuncs(DailyActiveData, "UpdateDailyActiveInfo")

function DailyActiveData:DoInit()
end

function DailyActiveData:NotifyUpdateDailyActiveInfo(msg)
    if msg.task_dict then
        self.task_dict = msg.task_dict
        self:_UpdateTaskRedPoint()
    end
    if msg.active_value then
        self.active_value = msg.active_value
    end
    if msg.chest_dict then
        self.chest_dict = msg.chest_dict
        self:_UpdateChestRedPoint()
    end
    if msg.unlock_chest_num then
        self.unlock_chest_num = msg.unlock_chest_num
    end
    self:DispatchUpdateDailyActiveInfo(msg)
end

function DailyActiveData:GetTaskDict()
    return self.task_dict
end

function DailyActiveData:CheckRewardCanGet(task_id)
    return self.task_dict[task_id].is_receive
end

function DailyActiveData:_UpdateTaskRedPoint()
    local param_dict = {}
    for task_id, data in pairs(self.task_dict) do
        if data.is_receive then
            param_dict[task_id] = 1
        end
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.DailyActiveTask, param_dict)
end

function DailyActiveData:_UpdateChestRedPoint()
    local param_dict = {}
    for progress_id, state in pairs(self.chest_dict) do
        if state then
            param_dict[progress_id] = 1
        end
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.DailyActiveChest, param_dict)
end

function DailyActiveData:GetSortedTaskList()
    local sorted_task_list = {}
    for k, v in pairs(self.task_dict) do
        if self:CheckDailyActiveShow(k) then
            v.id = k
            table.insert(sorted_task_list, v)
        end
    end
    local status1
    local status2
    table.sort(sorted_task_list, function (data1, data2)
        status1 = self:TransChestStatus(data1.is_receive)
        status2 = self:TransChestStatus(data2.is_receive)
        if status1 ~= status2 then
            return status1 < status2
        end
        return data1.id < data2.id
    end)
    return sorted_task_list
end

function DailyActiveData:CheckDailyActiveShow(daily_active_id)
    local daily_active_data = SpecMgrs.data_mgr:GetDailyActiveData(daily_active_id)
    local daily_active_type_data = SpecMgrs.data_mgr:GetDailyActiveData(daily_active_data.task_type)
    if not daily_active_type_data.func_unlock_id then return true end
    if ComMgrs.dy_data_mgr.func_unlock_data:IsFuncUnlock(daily_active_type_data.func_unlock_id) then
        return true
    else
        return false
    end
end

function DailyActiveData:TransChestStatus(is_receive)
    if is_receive == true then
        return 1
    elseif is_receive == false then
        return 2
    else
        return 3
    end
end

function DailyActiveData:GetActiveValue()
    return self.active_value
end

function DailyActiveData:GetChestDict()
    return self.chest_dict
end

function DailyActiveData:GetUnlockChestNum()
    return self.unlock_chest_num
end

return DailyActiveData