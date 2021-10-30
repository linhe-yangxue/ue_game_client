local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local LayoutRebuilder = UnityEngine.UI.LayoutRebuilder

local TrainingCentreUI = class("UI.TrainingCentreUI", UIBase)

function TrainingCentreUI:DoInit()
    TrainingCentreUI.super.DoInit(self)
    self.prefab_path = "UI/Common/TrainingCentreUI"
    self.dy_training_centre_data = ComMgrs.dy_data_mgr.training_centre_data
    self.lover_go_list = {}
    self.reward_go_list = {}
    self.event_go_list = {}
    self.train_event_time = SpecMgrs.data_mgr:GetParamData("lover_train_time").f_value * 60
    self.max_quicken_count = SpecMgrs.data_mgr:GetParamData("lover_event_quicken_num").f_value
end

function TrainingCentreUI:OnGoLoadedOk(res_go)
    TrainingCentreUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function TrainingCentreUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    TrainingCentreUI.super.Show(self)
end

function TrainingCentreUI:Hide()
    self.dy_training_centre_data:UnregisterUpdateTrainEvent("TrainingCentreUI")
    TrainingCentreUI.super.Hide(self)
end

function TrainingCentreUI:InitRes()
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "TrainingCentreUI")

    local event_panel = self.main_panel:FindChild("EventPanel")
    local event_content = event_panel:FindChild("Viewport/Content")
    self.train_grid_list = event_content:FindChild("TrainGridList")
    local prefab_panel = event_panel:FindChild("PrefPanel")
    self.train_grid_pref = prefab_panel:FindChild("TrainGridPref")
    local op_btn_panel = self.train_grid_pref:FindChild("OperationBtnPanel")
    op_btn_panel:FindChild("TrainPanel/TrainBtn/Text"):GetComponent("Text").text = UIConst.Text.TRAIN
    op_btn_panel:FindChild("TrainPanel/TrainInfo"):GetComponent("Text").text = UIConst.Text.SEND_TRAINNING
    op_btn_panel:FindChild("AcceleratePanel/AccelerateBtn/Text"):GetComponent("Text").text = UIConst.Text.ACCELERATE
    op_btn_panel:FindChild("FinishPanel/FinishBtn/Text"):GetComponent("Text").text = UIConst.Text.FINISH
    self.reward_item_pref = prefab_panel:FindChild("RewardItemPref")
    self.expand_grid = event_content:FindChild("ExpandTrainGrid")
    self.expand_grid:FindChild("Text"):GetComponent("Text").text = UIConst.Text.EXPAND_TRAIN_GRID
    self:AddClick(self.expand_grid:FindChild("ExpandBtn"), function ()
        self:ExpandTrainGrid()
    end)

    local bottom_panel = self.main_panel:FindChild("BottomPanel")
    local shed_info_panel = bottom_panel:FindChild("ShedInfoPanel")
    self.shed_count = shed_info_panel:FindChild("ShedCount"):GetComponent("Text")
    self:AddClick(shed_info_panel:FindChild("ExpandShedBtn"), function ()
        self:ExpandTrainGrid()
    end)
    self.accelerate_count = bottom_panel:FindChild("AccelerateCount"):GetComponent("Text")
    local easy_finish_panel = bottom_panel:FindChild("EasyFinishPanel")
    self.tip_text = easy_finish_panel:FindChild("TipText")
    self.tip_text:GetComponent("Text").text = UIConst.Text.EXPAND_TIPS
    self.easy_finish_btn = easy_finish_panel:FindChild("EasyFinishBtn")
    self.easy_finish_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.EASY_FINISH
    self:AddClick(self.easy_finish_btn, function ()
        local event_dict = self.dy_training_centre_data:GetAllEventData()
        for _, event in pairs(event_dict) do
            if event.is_finish then
                self:GetTrainEventReward(event.event_id)
            end
        end
    end)
end

function TrainingCentreUI:InitUI()
    self:InitTrainCentre()
    self.dy_training_centre_data:RegisterUpdateTrainEvent("TrainingCentreUI", self.InitTrainCentre, self)
    self:RegisterEvent(ComMgrs.dy_data_mgr, "UpdateCurrencyEvent", function (_, currency)
        if self._item_to_text_list then
            UIFuncs.UpdateCurrencyItemNum(self._item_to_text_list, currency)
        end
    end)
end

function TrainingCentreUI:InitTrainCentre()
    self:InitEventList()
    self:InitBottomPanel()
end

function TrainingCentreUI:InitEventList()
    self.expand_grid:SetActive(self.dy_training_centre_data:GetGridNum() < #SpecMgrs.data_mgr:GetAllEventGridData())
    self:ClearEventGo()
    for _, event in ipairs(self.dy_training_centre_data:GetEventList()) do
        local train_data = self.dy_training_centre_data:GetEventDataById(event.event_id)
        local event_go = self:GetUIObject(self.train_grid_pref, self.train_grid_list)
        local event_data = SpecMgrs.data_mgr:GetTrainEventData(train_data.event_id)
        UIFuncs.AssignSpriteByIconID(event_data.icon, event_go:FindChild("EventImg"):GetComponent("Image"))
        event_go:FindChild("EventImg/Finish"):SetActive(train_data.state == CSConst.TrainEventState.Finished)
        event_go:FindChild("EventName"):GetComponent("Text").text = event_data.name
        event_go:FindChild("EventDesc"):GetComponent("Text").text = event_data.desc
        event_go:FindChild("RewardPanel/Text"):GetComponent("Text").text = UIConst.Text.REWARD
        for index, reward in ipairs(event_data.attr_list) do
            local reward_go = self:GetUIObject(self.reward_item_pref, event_go:FindChild("RewardPanel/RewardList"))
            local reward_data = SpecMgrs.data_mgr:GetAttributeData(reward)
            UIFuncs.AssignSpriteByIconID(reward_data.icon, reward_go:FindChild("RewardIcon"):GetComponent("Image"))
            reward_go:FindChild("RewardCount"):GetComponent("Text").text = reward_data.name .. "+" .. event_data.attr_value_list[index]
            table.insert(self.reward_go_list, reward_go)
        end
        local operation_btn_panel = event_go:FindChild("OperationBtnPanel")
        local train_panel = operation_btn_panel:FindChild("TrainPanel")
        train_panel:SetActive(train_data.state == CSConst.TrainEventState.Idle)
        local train_btn = train_panel:FindChild("TrainBtn")

        local accelerate_panel = operation_btn_panel:FindChild("AcceleratePanel")
        accelerate_panel:SetActive(train_data.state == CSConst.TrainEventState.Training)
        local accelerate_btn = accelerate_panel:FindChild("AccelerateBtn")

        local finish_panel = operation_btn_panel:FindChild("FinishPanel")
        finish_panel:SetActive(train_data.state == CSConst.TrainEventState.Finished)
        local finish_btn = finish_panel:FindChild("FinishBtn")

        local lover_data = SpecMgrs.data_mgr:GetLoverData(train_data.lover_id)
        local unit_data = lover_data and SpecMgrs.data_mgr:GetUnitData(lover_data.unit_id)
        -- 派遣
        if train_data.state == CSConst.TrainEventState.Idle then
            self:AddClick(train_panel:FindChild("TrainBtn"), function ()
                SpecMgrs.ui_mgr:ShowUI("SelectLoverUI", self.dy_training_centre_data:GetIdleLoverList(), function (lover_id)
                    SpecMgrs.msg_mgr:SendLoverTrain({event_id = event_data.id, lover_id = lover_id}, function (resp)
                        if resp.errcode ~= 0 then
                            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.SEND_TRAIN_FAILED)
                        end
                    end)
                end)
            end)
        end
        -- 加速
        if train_data.state == CSConst.TrainEventState.Training then
            UIFuncs.AssignSpriteByIconID(unit_data.icon, accelerate_panel:FindChild("Icon"):GetComponent("Image"))
            accelerate_panel:FindChild("AccelerateInfo"):GetComponent("Text").text = string.format(UIConst.Text.IN_TRAINING, lover_data.name)
            local rest_time_text = accelerate_panel:FindChild("RestTime"):GetComponent("Text")
            self:AddDynamicUI(rest_time_text, function ()
                local rest_time = self.train_event_time + train_data.train_ts - Time:GetServerTime()
                if rest_time < 0 then
                    self:RemoveDynamicUI(rest_time_text)
                end
                rest_time_text.text = UIFuncs.TimeDelta2Str(rest_time)
            end, 1, 0)
            self:AddClick(accelerate_btn, function ()
                self:AccelerateTrain(train_data)
            end)
        end
        -- 完成
        if train_data.state == CSConst.TrainEventState.Finished then
            UIFuncs.AssignSpriteByIconID(unit_data.icon, finish_panel:FindChild("Icon"):GetComponent("Image"))
            if self.cur_accelerate_event_id and self.cur_accelerate_event_id == train_data.event_id then
                SpecMgrs.ui_mgr:HideUI("MoneyCostUI")
                self.cur_accelerate_event_id = nil
            end
            finish_panel:FindChild("FinishInfo"):GetComponent("Text").text = string.format(UIConst.Text.FINISH_TRAINING, event_data.name)
            self:AddClick(finish_btn, function ()
                self:GetTrainEventReward(event_data.id)
            end)
        end
        table.insert(self.event_go_list, event_go)
    end
end

function TrainingCentreUI:InitBottomPanel()
    local grid_count = self.dy_training_centre_data:GetGridNum()
    self.shed_count.text = string.format(UIConst.Text.CUR_EXPAND_GRID, self.dy_training_centre_data:GetTrainningGridCount(), grid_count)
    self.accelerate_count.text = string.format(UIConst.Text.REST_ACCELERATE_COUNT, self.dy_training_centre_data:GetQuickenNum(), self.max_quicken_count)
    self.tip_text:SetActive(grid_count < 5)
    self.easy_finish_btn:SetActive(grid_count >= 5)
end

function TrainingCentreUI:AccelerateTrain(train_data)
    if self.dy_training_centre_data:GetQuickenNum() <= 0 then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.QUICKEN_LIMIT)
        return
    end
    local time_table = UIFuncs.TimeDelta2Table(self.train_event_time + train_data.train_ts - Time:GetServerTime(), 2)
    local cost_item_data = SpecMgrs.data_mgr:GetItemData(CSConst.Virtual.Diamond)
    local data = {
        item_id = CSConst.Virtual.Diamond,
        need_count = time_table[2] + 1,
        confirm_cb = function ()
            SpecMgrs.msg_mgr:SendLoverTrainQuicken({event_id = train_data.event_id}, function (resp)
                if resp.errcode ~= 0 then
                    SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.ACCELERATE_FAILED)
                else
                    self.dy_training_centre_data:ReduceAccelerateCount()
                end
            end)
            self.cur_accelerate_event_id = nil
        end,
        cancel_cb = function ()
            self.cur_accelerate_event_id = nil
        end,
        remind_tag = "LoverTrainQuicken",
        title = UIConst.Text.ACCELERATE_TEXT,
        desc = string.format(UIConst.Text.ACCELERATE_SUBMIT_TIP, cost_item_data.name, time_table[2] + 1)
    }
    SpecMgrs.ui_mgr:ShowItemUseRemindByTb(data)
end

function TrainingCentreUI:GetTrainEventReward(event_id)
    local lover_id = self.dy_training_centre_data:GetEventDataById(event_id).lover_id
    SpecMgrs.msg_mgr:SendGetLoverTrainReward({event_id = event_id}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_TRAIN_REWARD_FAILED)
        else
            local event_data = SpecMgrs.data_mgr:GetTrainEventData(event_id)
            local ret_str = SpecMgrs.data_mgr:GetLoverData(lover_id).name .. "  "
            for i, attr in ipairs(event_data.attr_list) do
                local attr_data = SpecMgrs.data_mgr:GetAttributeData(attr)
                ret_str = ret_str .. string.format(UIConst.Text.ADD, attr_data.name, event_data.attr_value_list[i])
            end
            SpecMgrs.ui_mgr:ShowTipMsg(ret_str)
        end
    end)
end

function TrainingCentreUI:ExpandTrainGrid()
    local event_grid_data = SpecMgrs.data_mgr:GetEventGridData(self.dy_training_centre_data:GetGridNum() + 1)
    if not event_grid_data then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.EXPAND_FAILED)
        return
    end
    local item_data = SpecMgrs.data_mgr:GetItemData(event_grid_data.cost_name)
    local data = {
        item_id = event_grid_data.cost_name,
        need_count = event_grid_data.cost_value,
        confirm_cb = function ()
            SpecMgrs.msg_mgr:SendLoverUnlockEventGrid({}, function (resp)
                if resp.errcode ~= 0 then
                    SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.EXPAND_FAILED)
                end
            end)
        end,
        remind_tag = "ExpandTrainGrid",
        title = UIConst.Text.EXPAND_TEXT,
        desc = string.format(UIConst.Text.EXPAND_TRAIN_GRID_FORMAT, item_data.name, event_grid_data.cost_value)
    }
    SpecMgrs.ui_mgr:ShowItemUseRemindByTb(data)
end

function TrainingCentreUI:ClearLoverGo()
    for _, go in pairs(self.lover_go_list) do
        self:DelUIObject(go)
    end
    self.lover_go_list = {}
end

function TrainingCentreUI:ClearEventGo()
    for _, go in ipairs(self.reward_go_list) do
        self:DelUIObject(go)
    end
    for _, go in ipairs(self.event_go_list) do
        self:DelUIObject(go)
    end
    self.reward_go_list = {}
    self.event_go_list = {}
end

return TrainingCentreUI