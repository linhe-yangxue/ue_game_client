local EventUtil = require("BaseUtilities.EventUtil")
local DyDataConst = require("DynamicData.DyDataConst")

local DailyDareData = class("DynamicData.DailyDareData")

EventUtil.GeneratorEventFuncs(DailyDareData, "UpdateDailyDareData")

function DailyDareData:DoInit()
    self.dare_list = {}
    self.dare_dict = {}
end

function DailyDareData:NotifyUpdateDailyDareData(msg)
    for i, dare_data in ipairs(msg.dare_list) do
        self.dare_dict[dare_data.dare_id] = dare_data
    end
    self:_UpdateDailyDareRedPoint()
    self:DispatchUpdateDailyDareData()
end

function DailyDareData:GetOpenDareList()
    return self.dare_dict
end

function DailyDareData:GetNotOpenList()
    local ret = {}
    local data_list = SpecMgrs.data_mgr:GetAllDailyDareData()
    for dare_id, dare_data in ipairs(data_list) do
        if not self.dare_dict[dare_id] then
            table.insert(ret, dare_data)
        end
    end
    return ret
end

function DailyDareData:_UpdateDailyDareRedPoint()
    local param_dict = {}
    for dare_id, dare_data in pairs(self.dare_dict) do
        if not dare_data.is_passing then
            param_dict[dare_id] = 1
        end
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Playment.DaliyBattle, param_dict)
end

return DailyDareData