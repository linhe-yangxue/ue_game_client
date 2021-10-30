local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local ItemUtil = require("BaseUtilities.ItemUtil")
local DailyActiveUI = class("UI.DailyActiveUI", UIBase)

function DailyActiveUI:DoInit()
    DailyActiveUI.super.DoInit(self)
    self.prefab_path = "UI/Common/DailyActiveUI"
    self.dy_daily_active_data = ComMgrs.dy_data_mgr.daily_active_data
    self.treasure_data_list = SpecMgrs.data_mgr:GetAllDailyActiveChestData()
    self.task_item_dict = {}
    self.treasure_go_list = {}
    self.progress_go_list = {}
    self.item_go_list = {}
    self.effect_list = {}
end

function DailyActiveUI:OnGoLoadedOk(res_go)
    DailyActiveUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function DailyActiveUI:Hide()
    self:ClearAllCompleteEffect()
    self:ClearGoDict("item_go_list")
    self:ClearGoDict("task_item_dict")
    self:ClearGoDict("treasure_go_list")
    self:ClearGoDict("progress_go_list")
    DailyActiveUI.super.Hide(self)
end

function DailyActiveUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    DailyActiveUI.super.Show(self)
    self:UpdateAllTreasure()
end

function DailyActiveUI:Recover()
    self:UpdateAllTreasure()
end
function DailyActiveUI:InitRes()
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "DailyActiveUI")

    local prefab_list = self.main_panel:FindChild("PrefabList")
    self.active_task_item = prefab_list:FindChild("TaskItem")
    self.active_task_item:FindChild("GotoBtn/Text"):GetComponent("Text").text = UIConst.Text.GOTO_TEXT
    self.active_task_item:FindChild("FinishBtn/Text"):GetComponent("Text").text = UIConst.Text.RECEIVE_TEXT
    self.active_task_item:FindChild("Finished/Text"):GetComponent("Text").text = UIConst.Text.HAVE_FINISHED
    self.reward_temp = self.active_task_item:FindChild("Scroll View/Viewport/Content/Item")
    UIFuncs.GetIconGo(self, self.reward_temp)
    self.reward_temp:SetActive(false)
    -- 活跃界面
    local active_panel = self.main_panel:FindChild("ActivePanel")
    local active_treasure_panel = active_panel:FindChild("TreasurePanel")
    local active_treasure_bar = active_treasure_panel:FindChild("TreasureBar")
    self.progress_slider = active_treasure_bar:GetComponent("Slider")
    self.progress_item_parent = active_treasure_bar:FindChild("Fill Area/AwardList")
    self.progress_item_temp = self.progress_item_parent:FindChild("Item")
    self.progress_item_temp:SetActive(false)
    self.cur_active_text = active_treasure_panel:FindChild("CurActive"):GetComponent("Text")
    active_treasure_panel:FindChild("ResetTip"):GetComponent("Text").text = UIConst.Text.ACTIVE_RESET_TIP
    self.active_task_content = active_panel:FindChild("TaskPanel/View/Content")
end

function DailyActiveUI:InitUI()
    self:RegisterEvent(self.dy_daily_active_data, "UpdateDailyActiveInfo", function ()
        self:InitActiveTreasure()
        self:UpdateActivePoint()
        self:UpdateActiveTask()
        self:UpdateTreasureSliderValue()
        self:UpdateAllTreasure()
    end)
    self:InitActiveTreasure()
    self:UpdateActivePoint()
    self:UpdateTreasureSliderValue()
    self:UpdateActiveTask()
end

function DailyActiveUI:InitActiveTreasure()
    self:ClearGoDict("treasure_go_list")
    self:ClearGoDict("progress_go_list")
    local unlock_treasure_num = self.dy_daily_active_data:GetUnlockChestNum()
    for i = 1, unlock_treasure_num do
        local chest_data = self.treasure_data_list[i]
        local progress_go = self:GetUIObject(self.progress_item_temp, self.progress_item_parent)
        table.insert(self.progress_go_list, progress_go)
        local treasure_parent = progress_go:FindChild("Image/TreasureBoxParent")
        local treasure_go = UIFuncs.GetTreasureBox(self, treasure_parent, chest_data.treasure_box_id)
        self:AddClick(treasure_go, function ()
            self:ProgressGoOnClick(i)
        end)
        table.insert(self.treasure_go_list, treasure_go)
        progress_go:FindChild("Image/Text"):GetComponent("Text").text = chest_data.require_active
    end
end

function DailyActiveUI:UpdateActivePoint()
    local cur_active_count = self.dy_daily_active_data:GetActiveValue()
    self.cur_active_text.text = string.format(UIConst.Text.MEMBER_DYNASTY_ACTIVE, cur_active_count)
end

function DailyActiveUI:UpdateAllTreasure()
    local ChestDict = self.dy_daily_active_data:GetChestDict()
    for i, go in ipairs(self.treasure_go_list) do
        UIFuncs.UpdateTreasureBoxStatus(go, ChestDict[i])
    end
end

function DailyActiveUI:UpdateTreasureSliderValue()
    local progress_list = {}
    local unlock_treasure_num = self.dy_daily_active_data:GetUnlockChestNum()
    local chest_data_list = SpecMgrs.data_mgr:GetAllDailyActiveChestData()
    for i = 1, unlock_treasure_num do
        table.insert(progress_list, chest_data_list[i].require_active)
    end
    local cur_active_count = self.dy_daily_active_data:GetActiveValue()
    self.progress_slider.value = UIFuncs.CalculateTreasureSliderValue(cur_active_count, progress_list)
end

function DailyActiveUI:ProgressGoOnClick(progress_id)
    local progress_data = SpecMgrs.data_mgr:GetDailyActiveChestData(progress_id)
    local is_can_pick = self.dy_daily_active_data:GetChestDict()[progress_id]
    local data = {
        confirm_cb = function ()
            self:SendGetActiveReward(progress_id)
        end,
        title = UIConst.Text.DAILY_TASK_REWARD,
        desc = UIConst.Text.TREASURE_PREVIEW_DESC,
        reward_state = UIFuncs.TransRewardState(is_can_pick),
        reward_id = progress_data.reward_id,
    }
    SpecMgrs.ui_mgr:ShowUI("RewardPreviewUI", data)
end

function DailyActiveUI:UpdateActiveTask()
    self:ClearAllCompleteEffect()
    self:ClearGoDict("item_go_list")
    self:ClearGoDict("task_item_dict")
    local task_list = self.dy_daily_active_data:GetSortedTaskList()
    for i, task_info in ipairs(task_list) do
        local task_item = self:GetUIObject(self.active_task_item, self.active_task_content)
        self.task_item_dict[task_info.id] = task_item
        local task_data = SpecMgrs.data_mgr:GetDailyActiveData(task_info.id)
        UIFuncs.AssignSpriteByIconID(task_data.icon, task_item:FindChild("Icon"):GetComponent("Image"))
        local progress = task_info.progress
        local require_progress = task_info.require_progress
        task_item:FindChild("Desc"):GetComponent("Text").text = string.format(task_data.desc_format, require_progress)
        local reward_item_list = ItemUtil.GetSortedRewardItemList(task_data.reward_id)
        local reward_parent = task_item:FindChild("Scroll View/Viewport/Content")
        for i, item_info in ipairs(reward_item_list) do
            local reward_go = self:GetUIObject(self.reward_temp, reward_parent)
            table.insert(self.item_go_list, reward_go)
            item_info.go = reward_go:FindChild("Item")
            item_info.ui = self
            UIFuncs.InitItemGo(item_info)
        end

        local goto_btn = task_item:FindChild("GotoBtn")
        local progress_go = task_item:FindChild("Progress")
        local is_show_progress = task_info.is_receive ~= nil
        progress_go:SetActive(is_show_progress)
        if is_show_progress then
            progress_go:GetComponent("Text").text = UIFuncs.GetPerStr(progress, require_progress, progress >= require_progress)
        end
        goto_btn:SetActive(task_info.is_receive == false)
        self:AddClick(goto_btn, function ()
            SpecMgrs.ui_mgr:JumpUI(task_data.jump_ui)
        end)
        local finish_btn = task_item:FindChild("FinishBtn")
        local effect = UIFuncs.AddCompleteEffect(self, finish_btn)
        table.insert(self.effect_list, effect)
        finish_btn:SetActive(task_info.is_receive == true)
        self:AddClick(finish_btn, function ()
            self:SendGetTaskReward(task_info.id)
        end)
        task_item:FindChild("Finished"):SetActive(task_info.is_receive == nil)
    end
end

function DailyActiveUI:SendGetTaskReward(task_id)
    if not self.dy_daily_active_data:CheckRewardCanGet(task_id) then return end
    SpecMgrs.msg_mgr:SendMsg("SendReceiveActiveTaskReward", {task_id = task_id})
end

function DailyActiveUI:SendGetActiveReward(chest_id)
    SpecMgrs.msg_mgr:SendMsg("SendReceiveActiveChestReward", {chest_id = chest_id})
end

function DailyActiveUI:ClearAllCompleteEffect()
    for _, effect in ipairs(self.effect_list) do
        effect:EffectEnd()
    end
    self.effect_list = {}
end

return DailyActiveUI