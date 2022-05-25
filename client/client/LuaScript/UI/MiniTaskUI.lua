local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local MiniTaskUI = class("UI.MiniTaskUI", UIBase)
local kTaskCloseTrigger = "close"
local kTaskAnimTime = 0.4

function MiniTaskUI:DoInit()
    MiniTaskUI.super.DoInit(self)
    self.prefab_path = "UI/Common/MiniTaskUI"
    self.dy_task_data = ComMgrs.dy_data_mgr.task_data
end

function MiniTaskUI:OnGoLoadedOk(res_go)
    MiniTaskUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function MiniTaskUI:Hide()
    MiniTaskUI.super.Hide(self)
end

function MiniTaskUI:Show(close_trigger_ui)
    self.close_trigger_ui = close_trigger_ui
    if self.is_res_ok then
        self:InitUI()
    end
    MiniTaskUI.super.Show(self)
end

function MiniTaskUI:InitRes()
    self.anim_controller = self.main_panel:GetComponent("Animator")
    self.content = self.main_panel:FindChild("Content")
    self.mission_icon = self.content:FindChild("Icon/Mask/Img"):GetComponent("Image")
    self:AddClick(self.content:FindChild("CloseBtn"), function ()
        self:CloseMiniTask()
    end)

    local mission_info_panel = self.content:FindChild("MissionInfo")
    self.mission_info_width_limit = mission_info_panel:GetComponent("RectTransform").rect.width
    local mission_desc = mission_info_panel:FindChild("Desc")
    self.mission_desc_text = mission_desc:GetComponent("TextPic")
    self.mission_desc_rect = mission_desc:GetComponent("RectTransform")
    self.mission_desc_height = self.mission_desc_rect:GetComponent("RectTransform").rect.height
    self.progress_text = mission_info_panel:FindChild("Progress"):GetComponent("Text")

    local jump_btn = self.content:FindChild("Btn")
    self.jump_btn_cmp = jump_btn:GetComponent("Button")
    self:AddClick(jump_btn, function ()
        SpecMgrs.stage_mgr:GotoStage("MainStage")
        if not SpecMgrs.guide_mgr:IsInGuideState() then
            SpecMgrs.ui_mgr:ShowUI("TaskUI")
        end
    end)
end

function MiniTaskUI:InitUI()
    if not self.close_trigger_ui then
        self.close_trigger_ui = SpecMgrs.ui_mgr:GetCurShowTopUIName()
    end
    self:InitTaskInfo()
    self:RegisterEvent(self.dy_task_data, "UpdateTaskInfoEvent", function ()
        self:UpdateTaskProgress()
    end)
    self:RegisterEvent(SpecMgrs.ui_mgr, "HideUIEvent", function (_, ui)
        if ui.class_name == self.close_trigger_ui then
            self:CloseMiniTask()
        end
    end)
    self.content:SetActive(ComMgrs.dy_data_mgr:ExGetBattleState() ~= true)
    self:RegisterEvent(ComMgrs.dy_data_mgr, "UpdateBattleStateEvent", function (_, battle_state)
        self.content:SetActive(battle_state ~= true)
    end)
    self:RegisterEvent(ComMgrs.dy_data_mgr.lover_data, "UpdateLoverSpoilStateEvent", function (_, spoil_state)
        self.content:SetActive(spoil_state ~= true)
    end)
end

function MiniTaskUI:InitTaskInfo()
    local cur_task_info = self.dy_task_data:GetCurTaskInfo()
    local task_data = SpecMgrs.data_mgr:GetTaskData(cur_task_info.task_id)
    local task_type_data = SpecMgrs.data_mgr:GetTaskTypeData(task_data.task_type)
    UIFuncs.AssignSpriteByIconID(task_type_data.icon, self.mission_icon)
    self:UpdateTaskProgress()
end

function MiniTaskUI:UpdateTaskProgress()
    local cur_task_info = self.dy_task_data:GetCurTaskInfo()
    local task_data = SpecMgrs.data_mgr:GetTaskData(cur_task_info.task_id)
    local task_desc = self.dy_task_data:GetTaskDesc(task_data)
    local progress_text
    self.jump_btn_cmp.interactable = cur_task_info.is_finish == true
    if cur_task_info.is_finish then
        progress_text = UIConst.Text.MISSION_COMPLETE_TEXT
    else
        local mission_progress = task_data.task_param[#task_data.task_param]
        progress_text = string.format(UIConst.Text.MISSION_PROGRESS_FORMAT, cur_task_info.progress, mission_progress)
    end
    self.progress_text.text = progress_text

    local desc_width_limit = self.mission_info_width_limit - self.progress_text.preferredWidth
    self.mission_desc_rect.sizeDelta = Vector2.New(desc_width_limit, self.mission_desc_height)
    self.mission_desc_text:SetTextWithEllipsis(task_desc)
    self.mission_desc_rect.sizeDelta = Vector2.New(self.mission_desc_text.preferredWidth, self.mission_desc_height)
end

function MiniTaskUI:CloseMiniTask()
    self.anim_controller:SetTrigger(kTaskCloseTrigger)
    self.close_timer = self:AddTimer(function ()
        self:Hide()
        self.close_timer = nil
    end, kTaskAnimTime)
end

return MiniTaskUI