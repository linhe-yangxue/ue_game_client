local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local DynastyOfficeUI = class("UI.DynastyOfficeUI", UIBase)

local kOpEnum = {
    Build = 1,
    Active = 2,
}

function DynastyOfficeUI:DoInit()
    DynastyOfficeUI.super.DoInit(self)
    self.prefab_path = "UI/Common/DynastyOfficeUI"
    self.dy_bag_data = ComMgrs.dy_data_mgr.bag_data
    self.dy_dynasty_data = ComMgrs.dy_data_mgr.dynasty_data
    self.dynasty_progress_max_count = SpecMgrs.data_mgr:GetParamData("dynasty_progress_max_count").f_value
    self.member_active_max_count = SpecMgrs.data_mgr:GetParamData("member_active_max_count").f_value
    self.treasure_box_id = SpecMgrs.data_mgr:GetParamData("dynasty_office_treasure_box").treasure_box_id
    self.op_btn_data_dict = {}
    self.build_btn_state_list = {}
    self.build_reward_box_list = {}
    self.active_reward_box_list = {}
    self.mission_item_dict = {}

end

function DynastyOfficeUI:OnGoLoadedOk(res_go)
    DynastyOfficeUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function DynastyOfficeUI:Hide()
    self:UpdateOptionPanel()
    self:ClearResetTimer()
    self:ClearActiveMissionItem()
    self.dy_dynasty_data:UnregisterUpdateDynastyActiveEvent("DynastyOfficeUI")
    self.dy_dynasty_data:UnregisterKickedOutDynastyEvent("DynastyOfficeUI")
    self.dy_dynasty_data:UnregisterUpdateDynastyBuildInfoEvent("DynastyOfficeUI")
    DynastyOfficeUI.super.Hide(self)
end

function DynastyOfficeUI:Show(tab_panel)
    self.init_tab_panel = tab_panel
    if self.is_res_ok then
        self:InitUI()
    end
    DynastyOfficeUI.super.Show(self)
end

function DynastyOfficeUI:InitRes()
    local tab_panel = self.main_panel:FindChild("TabPanel")
    local build_btn = tab_panel:FindChild("BuildBtn")
    build_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_BUILD_TEXT
    local build_select = build_btn:FindChild("Select")
    self.op_btn_data_dict[kOpEnum.Build] = {}
    self.op_btn_data_dict[kOpEnum.Build].select = build_select
    build_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_BUILD_TEXT
    self:AddClick(build_btn, function ()
        self:UpdateOptionPanel(kOpEnum.Build)
    end)
    local active_btn = tab_panel:FindChild("ActiveBtn")
    active_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_ACTIVE_TEXT
    local active_select = active_btn:FindChild("Select")
    self.op_btn_data_dict[kOpEnum.Active] = {}
    self.op_btn_data_dict[kOpEnum.Active].select = active_select
    active_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_ACTIVE_TEXT
    self:AddClick(active_btn, function ()
        self:UpdateOptionPanel(kOpEnum.Active)
    end)

    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "DynastyOfficeUI")

    local prefab_list = self.main_panel:FindChild("PrefabList")
    local schedule_item = prefab_list:FindChild("ScheduleItem")
    self.active_mission_item = prefab_list:FindChild("MissionItem")
    self.active_mission_item:FindChild("GotoBtn/Text"):GetComponent("Text").text = UIConst.Text.GOTO_TEXT
    self.active_mission_item:FindChild("FinishBtn/Text"):GetComponent("Text").text = UIConst.Text.FINISH
    self.active_mission_item:FindChild("Finished/Text"):GetComponent("Text").text = UIConst.Text.HAVE_FINISHED

    -- 建设
    local build_panel = self.main_panel:FindChild("BuildPanel")
    self.op_btn_data_dict[kOpEnum.Build].panel = build_panel
    self.op_btn_data_dict[kOpEnum.Build].init_func = self.InitBuildInfoPanel
    local basic_info_panel = build_panel:FindChild("BasicInfoPanel")
    self.badge_icon = basic_info_panel:FindChild("Info/BadgeIcon"):GetComponent("Image")
    self.dynasty_name = basic_info_panel:FindChild("Info/DynastyName"):GetComponent("Text")
    self.dynasty_lv = basic_info_panel:FindChild("Info/DynastyLv"):GetComponent("Text")
    local exp_bar = basic_info_panel:FindChild("Info/ExpBar")
    self.dynasty_exp = exp_bar:FindChild("Exp"):GetComponent("Image")
    self.dynasty_exp_value = exp_bar:FindChild("ExpValue"):GetComponent("Text")

    local build_schedule_panel = build_panel:FindChild("SchedulePanel")
    local build_schedule_bar = build_schedule_panel:FindChild("ScheduleBar")
    self.dynasty_build_schedule = build_schedule_bar:FindChild("Schedule"):GetComponent("Image")
    local build_schedule_item_list = build_schedule_panel:FindChild("ScheduleItemList")
    local build_schedule_list_width = build_schedule_item_list:GetComponent("RectTransform").rect.width
    for i, progress_data in ipairs(SpecMgrs.data_mgr:GetAllProgressRewardData()) do
        local schedule_item = self:GetUIObject(schedule_item, build_schedule_item_list)
        local reward_box = UIFuncs.GetTreasureBox(self, schedule_item:FindChild("Box"), self.treasure_box_id)
        self.build_reward_box_list[i] = reward_box
        schedule_item:FindChild("ScheduleText"):GetComponent("Text").text = progress_data.progress
        schedule_item:GetComponent("RectTransform").anchoredPosition = Vector2.New(progress_data.progress / self.dynasty_progress_max_count * build_schedule_list_width, 0)
        self:AddClick(reward_box, function ()
            SpecMgrs.ui_mgr:ShowUI("RewardPreviewUI", {
                reward_id = progress_data.reward_id,
                reward_state = UIFuncs.TransRewardState(self.dy_dynasty_data:GetBuildRewardState(i)),
                confirm_cb = function ()
                    self:SendGetDynastyBuildReward(i)
                end,
            })
        end)
    end
    self.cur_build_schedule = build_schedule_panel:FindChild("BuildSchedule"):GetComponent("Text")
    self.cur_build_count = build_schedule_panel:FindChild("BuildCount"):GetComponent("Text")

    local select_panel = build_panel:FindChild("SelectPanel")
    for i, build_data in ipairs(SpecMgrs.data_mgr:GetAllDynastyBuildData()) do
        local build_item = select_panel:FindChild("BuildItem" .. i)
        build_item:FindChild("Name"):GetComponent("Text").text = build_data.name
        local reward_panel = build_item:FindChild("RewardPanel")
        local exp_reward_panel = reward_panel:FindChild("ExpPanel")
        exp_reward_panel:FindChild("Name"):GetComponent("Text").text = UIConst.Text.EXP_TEXT
        exp_reward_panel:FindChild("Count"):GetComponent("Text").text = build_data.dynasty_exp
        local dedicate_panel = reward_panel:FindChild("DedicatePanel")
        dedicate_panel:FindChild("Name"):GetComponent("Text").text = UIConst.Text.CONTRIBUTION_TEXT
        dedicate_panel:FindChild("Count"):GetComponent("Text").text = build_data.dedicate
        local progress_reward_panel = reward_panel:FindChild("ProgressPanel")
        progress_reward_panel:FindChild("Name"):GetComponent("Text").text = UIConst.Text.PROGRESS_TEXT
        progress_reward_panel:FindChild("Count"):GetComponent("Text").text = build_data.progress
        local material_panel = build_item:FindChild("MaterialPanel")
        material_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.COST_TEXT
        UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetItemData(build_data.build_cost).icon, material_panel:FindChild("Icon"):GetComponent("Image"))
        material_panel:FindChild("Count"):GetComponent("Text").text = build_data.cost_num
        local build_btn = build_item:FindChild("BuildBtn")
        build_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.BUILD_TEXT
        self.build_btn_state_list[i] = {}
        self.build_btn_state_list[i].build_btn = build_btn
        self.build_btn_state_list[i].material_panel = material_panel
        self:AddClick(build_btn, function ()
            local own_count = self.dy_bag_data:GetBagItemCount(build_data.build_cost)
            if own_count < build_data.cost_num then
                local cost_data = SpecMgrs.data_mgr:GetItemData(build_data.build_cost)
                SpecMgrs.ui_mgr:ShowMsgBox(string.format(UIConst.Text.ITEM_NOT_ENOUGH, cost_data.name))
                return
            end
            self:SendBuildDynasty(i)
        end)
        local have_built = build_item:FindChild("HaveBuilt")
        have_built:FindChild("Text"):GetComponent("Text").text = UIConst.Text.HAVE_BUILT
        self.build_btn_state_list[i].have_built = have_built
    end
    self.build_reset_count_down = build_panel:FindChild("BottomPanel/CountDown")
    self.count_down_text = self.build_reset_count_down:GetComponent("Text")

    -- 活跃界面
    local active_panel = self.main_panel:FindChild("ActivePanel")
    self.op_btn_data_dict[kOpEnum.Active].panel = active_panel
    self.op_btn_data_dict[kOpEnum.Active].init_func = self.InitActivePanel
    local active_schedule_panel = active_panel:FindChild("SchedulePanel")
    local active_schedule_bar = active_schedule_panel:FindChild("ScheduleBar")
    self.active_schedule = active_schedule_bar:FindChild("Schedule"):GetComponent("Image")
    local active_schedule_item_list = active_schedule_panel:FindChild("ScheduleItemList")
    local active_schedule_list_width = active_schedule_item_list:GetComponent("RectTransform").rect.width
    for i, active_reward in ipairs(SpecMgrs.data_mgr:GetAllDynastyActiveRewardData()) do
        local schedule_item = self:GetUIObject(schedule_item, active_schedule_item_list)
        local reward_box = UIFuncs.GetTreasureBox(self, schedule_item:FindChild("Box"), self.treasure_box_id)
        self.active_reward_box_list[i] = reward_box
        schedule_item:FindChild("ScheduleText"):GetComponent("Text").text = active_reward.active
        schedule_item:GetComponent("RectTransform").anchoredPosition = Vector2.New(active_reward.active / self.member_active_max_count * active_schedule_list_width, 0)
        self:AddClick(reward_box, function ()
            local data = {}
            data.reward_id = active_reward.reward_id
            local cur_active_count = self.dy_dynasty_data:GetDynastyDailyActive()
            if self.dy_dynasty_data:GetDynastyDailyActiveRewardState(i) then
                data.reward_state = CSConst.RewardState.picked
            elseif cur_active_count < active_reward.active then
                data.reward_state = CSConst.RewardState.unpick
            else
                data.reward_state = CSConst.RewardState.pick
            end
            data.confirm_cb = function ()
                self:SendGetDynastyActiveReward(i)
            end
            SpecMgrs.ui_mgr:ShowUI("RewardPreviewUI", data)
        end)
    end
    self.cur_active = active_schedule_panel:FindChild("CurActive"):GetComponent("Text")
    active_schedule_panel:FindChild("ResetTip"):GetComponent("Text").text = UIConst.Text.ACTIVE_RESET_TIP
    self.active_mission_content = active_panel:FindChild("MissionPanel/View/Content")
end

function DynastyOfficeUI:InitUI()
    self:UpdateOptionPanel(self.init_tab_panel or kOpEnum.Build)
    self:RegisterEvent( ComMgrs.dy_data_mgr, "UpdateCurrencyEvent", function (_, currency)
        UIFuncs.UpdateCurrencyItemNum(self._item_to_text_list, currency)
    end)
    self.dy_dynasty_data:RegisterUpdateDynastyActiveEvent("DynastyOfficeUI", self.InitActivePanel, self)
    self.dy_dynasty_data:RegisterKickedOutDynastyEvent("DynastyOfficeUI", self.Hide, self)
    self.dy_dynasty_data:RegisterUpdateDynastyBuildInfoEvent("DynastyOfficeUI", self.UpdateBuildPanelBaseInfo, self)
end

function DynastyOfficeUI:UpdateOptionPanel(op_tab)
    if self.cur_op == op_tab then return end
    self:RemoveDynamicUI(self.build_reset_count_down)
    self:ClearResetTimer()
    if self.cur_op then
        local last_op_data = self.op_btn_data_dict[self.cur_op]
        last_op_data.select:SetActive(false)
        last_op_data.panel:SetActive(false)
    end
    self.cur_op = op_tab
    if not self.cur_op then return end
    local cur_op_data = self.op_btn_data_dict[self.cur_op]
    cur_op_data.select:SetActive(true)
    cur_op_data.init_func(self)
    cur_op_data.panel:SetActive(true)
end

function DynastyOfficeUI:InitBuildInfoPanel()
    self:UpdateBuildPanelBaseInfo()
    self.reset_time = Time:GetServerTime() - Time:GetCurDayPassTime() + CSConst.Time.Day
    self.reset_build_progress_timer = SpecMgrs.timer_mgr:AddTimer(function ()
        self:InitBuildInfoPanel()
        self.reset_build_progress_timer = nil
    end, self.reset_time - Time:GetServerTime())
    self:AddDynamicUI(self.build_reset_count_down, function ()
        self.count_down_text.text = string.format(UIConst.Text.REFRESH_TIME_FORMAT, UIFuncs.TimeDelta2Str(self.reset_time - Time:GetServerTime()))
    end, 1, 0)
end

function DynastyOfficeUI:UpdateBuildPanelBaseInfo()
    SpecMgrs.msg_mgr:SendGetDynastyBasicInfo({}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_DYNASTY_BASIC_INFO_FAILED)
        else
            if not self.is_res_ok then return end
            self.dynasty_info = resp.dynasty_base_info
            UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetDynastyBadgeData(self.dynasty_info.dynasty_badge).icon, self.badge_icon)
            self.dynasty_name.text = self.dynasty_info.dynasty_name
            self.dynasty_lv.text = string.format(UIConst.Text.LEVEL, self.dynasty_info.dynasty_level)
            local cur_lv_data = SpecMgrs.data_mgr:GetDynastyData(self.dynasty_info.dynasty_level)
            local next_lv_data = SpecMgrs.data_mgr:GetDynastyData(self.dynasty_info.dynasty_level + 1)
            if not next_lv_data then
                self.dynasty_exp.fillAmount = 1
                self.dynasty_exp_value.text = string.format(UIConst.Text.PER_VALUE, self.dynasty_info.dynasty_exp - cur_lv_data.total_exp, UIConst.Text.MAX_VALUE)
            else
                self.dynasty_exp.fillAmount = (self.dynasty_info.dynasty_exp - cur_lv_data.total_exp) / next_lv_data.exp
                self.dynasty_exp_value.text = string.format(UIConst.Text.PER_VALUE, self.dynasty_info.dynasty_exp - cur_lv_data.total_exp, next_lv_data.exp)
            end
            self:UpdateBuildPanelBuildInfo()
        end
    end)
end

function DynastyOfficeUI:UpdateBuildPanelBuildInfo()
    SpecMgrs.msg_mgr:SendGetDynastyBuildInfo({}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_DYNASTY_BUILD_INFO_FAILED)
            self:Hide()
        else
            self.dynasty_build_schedule.fillAmount = resp.build_progress / self.dynasty_progress_max_count
            self.cur_build_schedule.text = string.format(UIConst.Text.CUR_DYNASTY_BUILD_PROGRESS_SCHEDULE, resp.build_progress)
            self.cur_build_count.text = string.format(UIConst.Text.CUR_BUILD_DYNASTY_MEMBER_COUNT, resp.build_num, self.dynasty_info.member_count)
            for i, progress_data in ipairs(SpecMgrs.data_mgr:GetAllProgressRewardData()) do
                local reward_box = self.build_reward_box_list[i]
                local reward_state = self.dy_dynasty_data:GetBuildRewardState(i)
                UIFuncs.UpdateTreasureBoxStatus(reward_box, reward_state)
            end
            local build_type = self.dy_dynasty_data:GetDynastyBuildType()
            for i, build_btn_state_data in ipairs(self.build_btn_state_list) do
                build_btn_state_data.build_btn:SetActive(build_type == 0)
                build_btn_state_data.material_panel:SetActive(build_type == 0)
                build_btn_state_data.have_built:SetActive(build_type == i)
            end
        end
    end)
end

function DynastyOfficeUI:InitActivePanel()
    self:UpdateActiveSchedule()
    self:UpdateActiveMission()
end

function DynastyOfficeUI:UpdateActiveSchedule()
    local cur_active_count = self.dy_dynasty_data:GetDynastyDailyActive()
    self.active_schedule.fillAmount = cur_active_count / self.member_active_max_count
    self.cur_active.text = string.format(UIConst.Text.MEMBER_DYNASTY_ACTIVE, cur_active_count)
    for i, active_reward in ipairs(SpecMgrs.data_mgr:GetAllDynastyActiveRewardData()) do
        local reward_box = self.active_reward_box_list[i]
        local cur_active_count = self.dy_dynasty_data:GetDynastyDailyActive()
        if self.dy_dynasty_data:GetDynastyDailyActiveRewardState(i) then
            UIFuncs.UpdateTreasureBoxStatus(reward_box)
        elseif cur_active_count < active_reward.active then
            UIFuncs.UpdateTreasureBoxStatus(reward_box, false)
        else
            UIFuncs.UpdateTreasureBoxStatus(reward_box, true)
        end
    end
end

function DynastyOfficeUI:UpdateActiveMission()
    self:ClearActiveMissionItem()
    for i, mission in ipairs(self.dy_dynasty_data:GetTaskList()) do
        local task_type_data = SpecMgrs.data_mgr:GetDynastyTaskTypeData(mission.task_type)
        local mission_data = SpecMgrs.data_mgr:GetDynastyTaskData(mission.task_info.task_id)
        local task_list = SpecMgrs.data_mgr:GetDyanstyTaskList()[mission.task_type].task_list
        local mission_item = self:GetUIObject(self.active_mission_item, self.active_mission_content)
        self.mission_item_dict[mission.task_type] = mission_item
        mission_data = mission_data or task_list[#task_list]
        UIFuncs.AssignSpriteByIconID(task_type_data.icon, mission_item:FindChild("MissionImg"):GetComponent("Image"))
        mission_item:FindChild("MissionDesc"):GetComponent("Text").text = string.format(mission_data.desc, mission_data.progress)
        mission_item:FindChild("Reward"):GetComponent("Text").text = string.format(UIConst.Text.ACTIVE_TASK_REWARD_FORMAT, mission_data.reward_active_num)
        local goto_btn = mission_item:FindChild("GotoBtn")
        local progress = mission_item:FindChild("Progress")
        progress:SetActive(mission.task_info.task_id ~= nil)
        if mission.task_info.task_id then
            progress:GetComponent("Text").text = UIFuncs.GetPerStr(mission.task_info.progress, mission_data.progress)
        end
        goto_btn:SetActive(mission.task_info.task_id ~= nil and mission.task_info.is_finish ~= true)
        self:AddClick(goto_btn, function ()
            SpecMgrs.ui_mgr:ShowUI(task_type_data.goto_ui, task_type_data.goto_panel)
        end)
        local finish_btn = mission_item:FindChild("FinishBtn")
        finish_btn:SetActive(mission.task_info.is_finish == true)
        self:AddClick(finish_btn, function ()
            self:SendFinishTask(mission.task_type)
        end)
        mission_item:FindChild("Finished"):SetActive(mission.task_info.task_id == nil)
    end
end

-- msg
function DynastyOfficeUI:SendGetDynastyBuildReward(reward_index)
    SpecMgrs.msg_mgr:SendGetDynastyBuildReward({reward_index = reward_index}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_BUILD_REWARD_FIALED)
        else
            UIFuncs.PlayOpenBoxAnim(self.build_reward_box_list[reward_index])
            self:UpdateBuildPanelBuildInfo()
        end
    end)
end

function DynastyOfficeUI:SendBuildDynasty(build_type)
    SpecMgrs.msg_mgr:SendBuildDynasty({build_type = build_type}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.DYNASTY_BUILD_FAILED)
        else
            self:InitBuildInfoPanel()
        end
    end)
end

function DynastyOfficeUI:SendGetDynastyActiveReward(reward_index)
    SpecMgrs.msg_mgr:SendGetDynastyActiveReward({reward_index = reward_index}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_ACTIVE_REWARD_FIALED)
        else
            UIFuncs.PlayOpenBoxAnim(self.active_reward_box_list[reward_index])
        end
    end)
end

function DynastyOfficeUI:SendFinishTask(task_type)
    SpecMgrs.msg_mgr:SendGetDynastyTaskReward({task_type = task_type}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.FINISH_MISSION_FAILED)
            -- self:UpdateActiveMission()
        end
    end)
end

function DynastyOfficeUI:ClearResetTimer()
    if self.reset_build_progress_timer then
        SpecMgrs.timer_mgr:RemoveTimer(self.reset_build_progress_timer)
        self.reset_build_progress_timer = nil
    end
end

function DynastyOfficeUI:ClearActiveMissionItem()
    for _, item in pairs(self.mission_item_dict) do
        self:DelUIObject(item)
    end
    self.mission_item_dict = {}
end

return DynastyOfficeUI