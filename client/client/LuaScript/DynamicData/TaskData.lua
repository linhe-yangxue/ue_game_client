local EventUtil = require("BaseUtilities.EventUtil")
local UIFuncs = require("UI.UIFuncs")

local TaskData = class("DynamicData.TaskData")

EventUtil.GeneratorEventFuncs(TaskData, "UpdateTaskInfoEvent")

function TaskData:DoInit()
    self.show_comment_group_index_list = SpecMgrs.data_mgr:GetParamData("comment_show_task_group_index").tb_float
end

function TaskData:NotifyUpdateTaskInfo(msg)
    --  检测任务组奖励
    local comment_index = table.index(self.show_comment_group_index_list, self.group_id)
    if self.group_id and comment_index then
        if self.group_id ~= msg.group_id then
            SpecMgrs.ui_mgr:ShowCommentUI(comment_index)
        end
    end
    self.group_id = msg.group_id
    self.task_id = msg.task_id
    self.progress = msg.progress
    if self.is_finish == false and msg.is_finish == true then
        self:ShowMiniTaskUI()
    end
    self.is_finish = msg.is_finish
    self:DispatchUpdateTaskInfoEvent()
end

function TaskData:GetCurTaskGroup()
    return SpecMgrs.data_mgr:GetTaskGroupData(self.group_id)
end

function TaskData:GetCurTaskInfo()
    if not self.task_id then return end
    return {task_id = self.task_id, progress = self.progress, is_finish = self.is_finish}
end

function TaskData:GetTaskDesc(task_data)
    if CSConst.TaskType.Stage == task_data.task_type then
        local stage_id = task_data.task_param[1]
        local stage_data = SpecMgrs.data_mgr:GetStageData(stage_id)
        local city_data = SpecMgrs.data_mgr:GetCityData(stage_data.city_id)
        local desc = string.format(task_data.desc, city_data.name, UIFuncs.GetStageNameById(stage_id))
        return desc
    else
        local desc = string.format(task_data.desc, table.unpack(task_data.task_param))
        return UIFuncs.Format(desc, task_data.task_param)
    end
end

function TaskData:ShowMiniTaskUI()
    local mini_task_ui = SpecMgrs.ui_mgr:GetUI("MiniTaskUI")
    if mini_task_ui and mini_task_ui:IsVisible() then return end
    local trigger_ui_name = SpecMgrs.ui_mgr:GetCurShowTopUIName()
    -- 主界面已存在主线任务信息
    if trigger_ui_name == "MainSceneUI" then return end
    SpecMgrs.ui_mgr:ShowUI("MiniTaskUI", trigger_ui_name)
end

return TaskData