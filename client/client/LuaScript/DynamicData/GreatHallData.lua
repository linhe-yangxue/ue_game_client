local EventUtil = require("BaseUtilities.EventUtil")
local GreatHallData = class("DynamicData.GreatHallData")
local UIFuncs = require("UI.UIFuncs")
local CSFunction = require("CSCommon.CSFunction")

local serv_redpoint_control_id = 2
local cmd_redpoint_control_id = 1

EventUtil.GeneratorEventFuncs(GreatHallData, "UpdateInfoEvent")
EventUtil.GeneratorEventFuncs(GreatHallData, "UpdateCmdEvent")

function GreatHallData:DoInit()
    self.info_serv_data = {}
    self.cmd_serv_data = {}
end

function GreatHallData:NotifyUpdateData(msg)
    if msg.info then
        for k, v in pairs(msg.info) do
            self.info_serv_data[k] = v
        end
        self:DispatchUpdateInfoEvent()
    end
    if msg.cmd_dict then
        for index, cmd in pairs(msg.cmd_dict) do
            self.cmd_serv_data[index] = cmd
            cmd.num = cmd.num or 0
            self:DispatchUpdateCmdEvent(index)
        end
    end
    self:_UpdateMainSceneRedPoint()
end


function GreatHallData:_UpdateMainSceneRedPoint()
    if self.info_serv_data.num then
        SpecMgrs.redpoint_mgr:SetControlIdActive(serv_redpoint_control_id, {self.info_serv_data.num})
    end
    local cmd_num = 0
    for _, cmd_data in pairs(self.cmd_serv_data) do
        if cmd_data.num then
            cmd_num = cmd_num + cmd_data.num
        end
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(cmd_redpoint_control_id, {cmd_num})
end

function GreatHallData:GetInfoCount()
    return self.info_serv_data.num
end

function GreatHallData:GetCmdCount(index)
    local count = 0
    if not index then
        for _, v in ipairs(self.cmd_serv_data) do
            count = count + v.num
        end
    else
        count = self.cmd_serv_data[index] and self.cmd_serv_data[index].num or 0
    end
    return count
end

function GreatHallData:GetInfoCoolDownTime()
    local last_time = self.info_serv_data.last_time
    local max_cool_time = self:_GetLevelData().info_cooldown
    if not last_time then return end
    return self:_GetRemainTime(max_cool_time, last_time)
end

function GreatHallData:_GetRemainTime(max_cool_time, last_time)
    local next_cooldown_time = last_time + max_cool_time
    local remain_time = next_cooldown_time - Time:GetServerTime()
    if remain_time < 0 then return end
    return remain_time
end

function GreatHallData:GetCmdCoolDownTime(index)
    local score = ComMgrs.dy_data_mgr:ExGetRoleScore()
    local max_cool_time = CSFunction.get_cmd_cooldown(score)
    local last_time = self.cmd_serv_data[index] and self.cmd_serv_data[index].last_time
    if not last_time then return end
    return self:_GetRemainTime(max_cool_time, last_time)
end

function GreatHallData:GetInfoId()
    return self.info_serv_data.info_id
end

function GreatHallData:GetInfoData()
    return self.info_serv_data
end

function GreatHallData:GetCmdData(index)
    if index then
        return SpecMgrs.data_mgr:GetLevyData(index)
    end
    return SpecMgrs.data_mgr:GetAllLevyData()
end

function GreatHallData:_GetLevelData()
    local level = ComMgrs.dy_data_mgr:ExGetRoleLevel()
    return SpecMgrs.data_mgr:GetLevelData(level)
end

function GreatHallData:GetInfoMaxCount()
    return self:_GetLevelData().info_max_count or 0
end

function GreatHallData:GetCmdMaxCount(index)
    return self:_GetLevelData().cmd_max_count[index] or 0
end

function GreatHallData:GetInfoExp()
    return self:_GetLevelData().info_exp
end

function GreatHallData:ClearAll()
    self.info_serv_data = {}
    self.cmd_serv_data = {}
end

return GreatHallData
