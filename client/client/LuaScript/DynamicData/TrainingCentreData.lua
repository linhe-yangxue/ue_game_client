local EventUtil = require("BaseUtilities.EventUtil")

local TrainingCentreData = class("DynamicData.TrainingCentreData")

EventUtil.GeneratorEventFuncs(TrainingCentreData, "UpdateTrainEvent")

function TrainingCentreData:DoInit()
    self.event_dict = {}
    self.event_list = {}
    self.dy_lover_data = ComMgrs.dy_data_mgr.lover_data
end

function TrainingCentreData:NotifyUpdateLoverTrainInfo(msg)
    self.quicken_num = msg.quicken_num or self.quicken_num
    self.grid_num = msg.grid_num or self.grid_num
    self.event_list = {}
    self.event_dict = msg.event_dict
    if msg.event_dict then
        for id, event in pairs(msg.event_dict) do
            table.insert(self.event_list, event)
            -- 插入排序事件的状态 方便排序
            if not event.lover_id then
                self.event_dict[id].state = CSConst.TrainEventState.Idle
            elseif event.is_finish then
                self.event_dict[id].state = CSConst.TrainEventState.Finished
            elseif event.lover_id and not event.is_finish then
                self.event_dict[id].state = CSConst.TrainEventState.Training
            end
        end
        self:_UpdateRedPoint(self.event_dict)
    end
    table.sort(self.event_list, function (event1, event2)
        local event_data1 = self.event_dict[event1.event_id]
        local event_data2 = self.event_dict[event2.event_id]
        return event_data1.state < event_data2.state
    end)
    self:DispatchUpdateTrainEvent()
end

function TrainingCentreData:NotifyLoverTrainFinish(msg)
    self.event_dict[msg.event_id].is_finish = true
    self.event_dict[msg.event_id].state = CSConst.TrainEventState.Finished
    self:_UpdateRedPoint(self.event_dict)
    self:DispatchUpdateTrainEvent()
end

function TrainingCentreData:GetTrainningGridCount()
    local ret = 0
    for _, event in pairs(self.event_dict) do
        if event.state ~= CSConst.TrainEventState.Idle then
            ret = ret + 1
        end
    end
    return ret
end

function TrainingCentreData:GetGridNum()
    return self.grid_num
end

function TrainingCentreData:GetQuickenNum()
    return self.quicken_num
end

function TrainingCentreData:GetEventList()
    return self.event_list
end

function TrainingCentreData:GetAllEventData()
    return self.event_dict
end

function TrainingCentreData:GetEventDataById(id)
    return self.event_dict[id]
end

function TrainingCentreData:ReduceAccelerateCount()
    self.quicken_num = self.quicken_num - 1
    self:DispatchUpdateTrainEvent()
end

function TrainingCentreData:GetIdleLoverList()
    local idle_lover_list = {}
    local own_lover_list = self.dy_lover_data:GetAllLoverInfo()
    for _, lover in ipairs(own_lover_list) do
        local flag = true
        for _, event in pairs(self.event_dict) do
            if event.lover_id == lover.lover_id then
                flag = false
                break
            end
        end
        if flag then table.insert(idle_lover_list, lover) end
    end
    table.sort(idle_lover_list, function (lover1, lover2)
        if lover1.level == lover2.level then
            local total_attr1 = lover1.attr_dict.etiquette + lover1.attr_dict.culture + lover1.attr_dict.charm + lover1.attr_dict.planning
            local total_attr2 = lover2.attr_dict.etiquette + lover2.attr_dict.culture + lover2.attr_dict.charm + lover2.attr_dict.planning
            return total_attr1 > total_attr2
        else
            return lover1.level > lover2.level
        end
    end)
    return idle_lover_list
end

function TrainingCentreData:_UpdateRedPoint(event_dict)
    local param_dict = {}
    for event_id, event in pairs(event_dict) do
        if event.state == CSConst.TrainEventState.Finished then
            param_dict[event_id] = 1
        end
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.TrainingCenter, param_dict)
end

return TrainingCentreData