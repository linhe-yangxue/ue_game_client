local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local TaskUI = class("UI.TaskUI", UIBase)

function TaskUI:DoInit()
    TaskUI.super.DoInit(self)
    self.prefab_path = "UI/Common/TaskUI"
    self.dy_task_data = ComMgrs.dy_data_mgr.task_data
    self.reward_box_id = SpecMgrs.data_mgr:GetParamData("task_reward_box").treasure_box_id
    self.reward_item_list = {}
end

function TaskUI:OnGoLoadedOk(res_go)
    TaskUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function TaskUI:Hide()
    self:ClearRewardItem()
    self.dy_task_data:UnregisterUpdateTaskInfoEvent("TaskUI")
    TaskUI.super.Hide(self)
end

function TaskUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    TaskUI.super.Show(self)
end

function TaskUI:InitRes()
    local content = self.main_panel:FindChild("Content")
    self.title = content:FindChild("Title"):GetComponent("Text")
    self:AddClick(content:FindChild("CloseBtn"), function ()
        self:Hide()
    end)
    local reward_info_panel = content:FindChild("RewardInfo")
    local mission_group_progress_bar = reward_info_panel:FindChild("ProgressBar")
    self.mission_group_progress = mission_group_progress_bar:FindChild("Value"):GetComponent("Image")
    self.mission_group_progress_text = mission_group_progress_bar:FindChild("Text"):GetComponent("Text")
    self.mission_group_progress_tip = reward_info_panel:FindChild("ProgressTip"):GetComponent("Text")
    self.group_reward = reward_info_panel:FindChild("Reward")
    self.reward_box = UIFuncs.GetTreasureBox(self, self.group_reward, self.reward_box_id)
    self:AddClick(self.reward_box, function ()
        self:ShowGroupRewardPreview()
    end)

    local task_info_panel = content:FindChild("TaskInfo")
    self.empty = task_info_panel:FindChild("Empty")
    self.empty:GetComponent("Text").text = UIConst.Text.TASK_GROUP_COMPLETE
    self.task = task_info_panel:FindChild("Task")
    self.task_icon = self.task:FindChild("Bg/Icon"):GetComponent("Image")
    self.task_name = self.task:FindChild("Name"):GetComponent("Text")
    local mission_progress_bar = self.task:FindChild("ProgressBar")
    self.mission_progress = mission_progress_bar:FindChild("Value"):GetComponent("Image")
    self.mission_progress_text = mission_progress_bar:FindChild("Text"):GetComponent("Text")
    self.reward_list = self.task:FindChild("RewardList")
    self.reward_item = self.reward_list:FindChild("Reward")
    self.reward_btn = self.task:FindChild("RewardBtn")
    self.reward_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.RECEIVE_TEXT
    self:AddClick(self.reward_btn, function ()
        self:SendGetTaskReward()
    end)
    self.goto_btn = self.task:FindChild("GotoBtn")
    self.goto_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.GOTO_TEXT
    self:AddClick(self.goto_btn, function ()
        SpecMgrs.ui_mgr:JumpUI(self.task_type_data.goto_ui)
        local ui_data = SpecMgrs.data_mgr:GetGotoUIData(self.task_type_data.goto_ui)
        SpecMgrs.ui_mgr:ShowUI("MiniTaskUI", ui_data.ui)
        self:Hide()
    end)
end

function TaskUI:InitUI()
    self:InitTaskInfo()
    self.dy_task_data:RegisterUpdateTaskInfoEvent("TaskUI", self.InitTaskInfo, self)
end

function TaskUI:InitTaskInfo()
    self.group_data = self.dy_task_data:GetCurTaskGroup()
    if not self.group_data then
        self:Hide()
        return
    end
    self:ClearRewardItem()
    self.cur_task_info = self.dy_task_data:GetCurTaskInfo()
    self.title.text = self.group_data.desc
    local max_group_progress = #self.group_data.task_list
    local cur_group_progress = self.cur_task_info and self.group_data.index_dict[self.cur_task_info.task_id] - 1 or max_group_progress
    self.mission_group_progress.fillAmount = cur_group_progress / max_group_progress
    self.mission_group_progress_text.text = string.format(UIConst.Text.PER_VALUE, cur_group_progress, max_group_progress)
    if cur_group_progress == max_group_progress then
        self.mission_group_progress_tip.text = UIConst.Text.MISSION_GROUP_PROGRESS_FINISH
    else
        self.mission_group_progress_tip.text = string.format(UIConst.Text.MISSION_GROUP_PROGRESS_TIP, max_group_progress - cur_group_progress)
    end
    local group_complete_flag = cur_group_progress == max_group_progress and self.cur_task_info == nil
    self.reward_state = group_complete_flag and CSConst.RewardState.pick or CSConst.RewardState.unpick
    -- self.group_reward_btn:SetActive(group_complete_flag)
    UIFuncs.UpdateTreasureBoxStatus(self.reward_box, group_complete_flag)
    self.task:SetActive(self.cur_task_info ~= nil)
    self.empty:SetActive(self.cur_task_info == nil)
    if self.cur_task_info then
        local task_data = SpecMgrs.data_mgr:GetTaskData(self.cur_task_info.task_id)
        self.task_type_data = SpecMgrs.data_mgr:GetTaskTypeData(task_data.task_type)
        UIFuncs.AssignSpriteByIconID(self.task_type_data.icon, self.task_icon)
        self.task_name.text = self.dy_task_data:GetTaskDesc(task_data)
        local max_progress = task_data.task_param[#task_data.task_param]
        self.mission_progress.fillAmount = self.cur_task_info.progress / max_progress
        self.mission_progress_text.text = string.format(UIConst.Text.PER_VALUE, self.cur_task_info.progress, max_progress)
        local reward_data = SpecMgrs.data_mgr:GetRewardData(task_data.reward_id)
        for i, item_id in ipairs(reward_data.reward_item_list) do
            local item_data = SpecMgrs.data_mgr:GetItemData(item_id)
            local reward_item = self:GetUIObject(self.reward_item, self.reward_list)
            table.insert(self.reward_item_list, reward_item)
            UIFuncs.AssignSpriteByIconID(item_data.icon, reward_item:FindChild("Icon"):GetComponent("Image"))
            reward_item:FindChild("Count"):GetComponent("Text").text = string.format(UIConst.Text.COUNT, UIFuncs.AddCountUnit(reward_data.reward_num_list[i]))
        end
        self.reward_btn:SetActive(self.cur_task_info.is_finish == true)
        self.goto_btn:SetActive(self.cur_task_info.is_finish ~= true and self.task_type_data.goto_ui ~= nil)
    end
end

function TaskUI:ShowGroupRewardPreview()
    local data = {
        reward_id = self.group_data.reward_id,
        reward_state = self.reward_state,
        confirm_cb = function ()
            SpecMgrs.msg_mgr:SendGetTaskGroupReward({}, function (resp)
                if resp.errcode ~= 0 then
                    SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_GROUP_REWARD_FAILED)
                end
            end)
        end,
    }
    SpecMgrs.ui_mgr:ShowUI("RewardPreviewUI", data)
end

-- msg

function TaskUI:SendGetTaskReward()
    SpecMgrs.msg_mgr:SendGetTaskReward({}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_TASK_REWARD_FAILED)
        end
    end)
end

function TaskUI:ClearRewardItem()
    for _, reward in ipairs(self.reward_item_list) do
        self:DelUIObject(reward)
    end
    self.reward_item_list = {}
end

return TaskUI