local UIBase = require("UI.UIBase")
local UIFuncs = require("UI.UIFuncs")
local UIConst = require("UI.UIConst")
local SlideSelectCmp = require("UI.UICmp.SlideSelectCmp")
local ServerFundUI = class("UI.ServerFundUI", UIBase)

local kOpenServerFundId = 1
local kAnimTime = 2
local kOpIndex = {
    ServerFund = 1,     -- 开服基金
    FundWelfare = 2,    -- 全民福利
}

local kCountUnitDict = {
    ["Single"] = 1,
    ["Ten"] = 10,
    ["Hundreds"] = 100,
    ["Thousands"] = 1000,
}

function ServerFundUI:Hide()
    self.dy_activity_data:UnregisterUpdateServerFundCountEvent("ServerFundUI")
    self.dy_activity_data:UnregisterUpdateServerFundRewardEvent("ServerFundUI")
    self.dy_activity_data:UnregisterUpdateFundWelfareRewardEvent("ServerFundUI")
    ComMgrs.dy_data_mgr.vip_data:UnregisterUpdateVipInfo("ServerFundUI")
    self:CloseCurTabPanel()
    self:ClearServerFundTaskItem()
    self:ClearFundWelfareTaskItem()
    self:RemoveServerFundBuyEffect()
    self:ClearUnitModel()
    self.count_offset = 0
    self.wait_anim_count = 0
    self.is_count_moving = nil
    ServerFundUI.super.Hide(self)
end

function ServerFundUI:DoInit(ui)
    ServerFundUI.super.DoInit(self)
    self.parent_ui = ui
    self.server_fund_unit_id = SpecMgrs.data_mgr:GetParamData("server_fund_unit").unit_id
    self.fund_welfare_unit_id = SpecMgrs.data_mgr:GetParamData("fund_welfare_unit").unit_id
    self.dy_activity_data = ComMgrs.dy_data_mgr.activity_data
    self.tab_op_data = {}
    self.server_fund_task_item_dict = {}
    self.server_fund_recieve_effect_dict = {}
    self.fund_welfare_task_item_dict = {}
    self.fund_welfare_recieve_effect_dict = {}
    self.buy_count_slide_cmp_dict = {}
    self.count_offset = 0
    self.wait_anim_count = 0
end

function ServerFundUI:InitRes()
    local server_fund_panel = self.parent_ui.main_panel:FindChild("ServerFundFrame")
    -- 开服基金
    self.server_fund_tab_panel = server_fund_panel:FindChild("FundPanel")
    local fund_info_panel = self.server_fund_tab_panel:FindChild("InfoPanel")
    self.fund_buy_count = fund_info_panel:FindChild("Count/Text"):GetComponent("Text")
    self.server_fund_lover_model = fund_info_panel:FindChild("LoverModel")
    local server_fund_data = SpecMgrs.data_mgr:GetOpenServiceFundData(kOpenServerFundId)
    local cost_info_panel = fund_info_panel:FindChild("Reward/Cost")
    cost_info_panel:FindChild("Count"):GetComponent("Text").text = server_fund_data.item_num
    local cost_item_data = SpecMgrs.data_mgr:GetItemData(server_fund_data.item_id)
    UIFuncs.AssignSpriteByIconID(cost_item_data.icon, cost_info_panel:FindChild("Icon"):GetComponent("Image"))
    local get_info_panel = fund_info_panel:FindChild("Reward/Get")
    local total_reward_count = 0
    for _, reward_data in pairs(SpecMgrs.data_mgr:GetAllOpenServiceRewardData()) do
        total_reward_count = total_reward_count + reward_data.item_num
    end
    get_info_panel:FindChild("Count"):GetComponent("Text").text = total_reward_count
    local vip_panel = fund_info_panel:FindChild("Vip")
    vip_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CUR_VIP_LEVEL
    self.vip_img = vip_panel:FindChild("Img")
    self.not_vip_text = vip_panel:FindChild("NotVip")
    self.not_vip_text:GetComponent("Text").text = UIConst.Text.NONE
    local condition_panel = fund_info_panel:FindChild("Condition")
    local condition_vip_data = SpecMgrs.data_mgr:GetVipData(server_fund_data.vip_level)
    UIFuncs.AssignSpriteByIconID(condition_vip_data.icon, condition_panel:FindChild("Img"):GetComponent("Image"))
    condition_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.VIP_CONDITION_TEXT
    self.server_fund_buy_btn = fund_info_panel:FindChild("BuyBtn")
    self.server_fund_buy_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.BUY_TEXT
    self.server_fund_buy_disable = fund_info_panel:FindChild("Disable")
    self.server_fund_buy_disable:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ALREADY_BUY_TEXT
    self:AddClick(self.server_fund_buy_btn, function ()
        self:SendBuyServerFund()
    end)
    self.fund_task_list = self.server_fund_tab_panel:FindChild("TaskList/View/Content")
    self.fund_task_list_rect = self.fund_task_list:GetComponent("RectTransform")
    self.fund_task_item = self.fund_task_list:FindChild("TaskItem")
    self.fund_task_item:FindChild("Reward/State/Picked/Text"):GetComponent("Text").text = UIConst.Text.ALREADY_RECEIVE_TEXT
    self.fund_task_item:FindChild("Reward/State/RecieveBtn/Text"):GetComponent("Text").text = UIConst.Text.RECEIVE_TEXT

    -- 全民福利
    self.fund_welfare_tab_panel = server_fund_panel:FindChild("WelfarePanel")
    local welfare_info_panel = self.fund_welfare_tab_panel:FindChild("InfoPanel")
    self.fund_welfare_lover_model = welfare_info_panel:FindChild("LoverModel")
    local count_panel = welfare_info_panel:FindChild("CountPanel")
    for name, _ in pairs(kCountUnitDict) do
        local count_slide_cmp = SlideSelectCmp.New()
        count_slide_cmp:DoInit(self, count_panel:FindChild(name))
        count_slide_cmp:ListenSelectUpdate(function ()
            self.wait_anim_count = self.wait_anim_count - 1
            if self.wait_anim_count == 0 and self.count_offset > 0 then
                self:PlayCountAnim()
            elseif self.wait_anim_count == 0 then
                self.is_count_moving = false
            end
        end)
        self.buy_count_slide_cmp_dict[name] = count_slide_cmp
    end
    welfare_info_panel:FindChild("Tip"):GetComponent("Text").text = UIConst.Text.BUY_SERVER_FUND_TEXT
    self.fund_welfare_buy_btn = welfare_info_panel:FindChild("BuyBtn")
    self.fund_welfare_buy_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.BUY_TEXT
    self.fund_welfare_buy_disable = welfare_info_panel:FindChild("Disable")
    self.fund_welfare_buy_disable:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ALREADY_BUY_TEXT
    self:AddClick(self.fund_welfare_buy_btn, function ()
        self:SendBuyServerFund()
    end)
    self.welfare_task_list = self.fund_welfare_tab_panel:FindChild("TaskList/View/Content")
    self.welfare_task_list_rect = self.welfare_task_list:GetComponent("RectTransform")

    local tab_panel = server_fund_panel:FindChild("TabPanel")
    local server_fund_tab_data = {}
    local server_fund_btn = tab_panel:FindChild("ServerFund")
    server_fund_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SERVER_FUND_TEXT
    local server_fund_select = server_fund_btn:FindChild("Select")
    server_fund_tab_data.select = server_fund_select
    server_fund_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SERVER_FUND_TEXT
    self:AddClick(server_fund_btn, function ()
        self:UpdateTabPanel(kOpIndex.ServerFund)
    end)
    server_fund_tab_data.panel = self.server_fund_tab_panel
    self.tab_op_data[kOpIndex.ServerFund] = server_fund_tab_data

    local fund_welfare_tab_data = {}
    local fund_welfare_btn = tab_panel:FindChild("FundWelfare")
    fund_welfare_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.WHOLE_WELFARE_TEXT
    local fund_welfare_select = fund_welfare_btn:FindChild("Select")
    fund_welfare_tab_data.select = fund_welfare_select
    fund_welfare_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.WHOLE_WELFARE_TEXT
    self:AddClick(fund_welfare_btn, function ()
        self:UpdateTabPanel(kOpIndex.FundWelfare)
    end)
    fund_welfare_tab_data.init_func = self.InitFundBuyCount
    fund_welfare_tab_data.panel = self.fund_welfare_tab_panel
    self.tab_op_data[kOpIndex.FundWelfare] = fund_welfare_tab_data
end

function ServerFundUI:InitUI()
    self.dy_activity_data:RegisterUpdateServerFundCountEvent("ServerFundUI", self.UpdateServerFundCount, self)
    self.dy_activity_data:RegisterUpdateServerFundRewardEvent("ServerFundUI", self.InitServerFundTaskList, self)
    self.dy_activity_data:RegisterUpdateFundWelfareRewardEvent("ServerFundUI", self.InitFundWelfareTaskList, self)
    ComMgrs.dy_data_mgr.vip_data:RegisterUpdateVipInfo("ServerFundUI", self.UpdateVipInfo, self)
    self.server_fund_unit = self:AddHalfUnit(self.server_fund_unit_id, self.server_fund_lover_model)
    self.fund_welfare_unit = self:AddHalfUnit(self.fund_welfare_unit_id, self.fund_welfare_lover_model)
end

function ServerFundUI:Show()
    self:UpdateServerFundBuyState()
    self:InitServerFundPanel()
    self:InitFundWelfarePanel()
    self:UpdateTabPanel(kOpIndex.ServerFund)
end

function ServerFundUI:UpdateServerFundBuyState()
    self:RemoveServerFundBuyEffect()
    local already_buy = self.dy_activity_data:GetServerFundBuyState()
    self.server_fund_buy_btn:SetActive(already_buy ~= true)
    self.server_fund_buy_disable:SetActive(already_buy == true)
    self.fund_welfare_buy_btn:SetActive(already_buy ~= true)
    self.fund_welfare_buy_disable:SetActive(already_buy == true)
    local cur_vip = ComMgrs.dy_data_mgr:ExGetRoleVip()
    local server_fund_data = SpecMgrs.data_mgr:GetOpenServiceFundData(kOpenServerFundId)
    if cur_vip >= server_fund_data.vip_level and not self.dy_activity_data:GetServerFundBuyState() then
        self.server_fund_buy_effect = UIFuncs.AddCompleteEffect(self.parent_ui, self.server_fund_buy_btn)
        self.fund_welfare_buy_effect = UIFuncs.AddCompleteEffect(self.parent_ui, self.fund_welfare_buy_btn)
    end
end

function ServerFundUI:UpdateTabPanel(op_index)
    if self.cur_op_index == op_index then return end
    self:CloseCurTabPanel()
    self.cur_op_index = op_index
    local cur_tab_data = self.tab_op_data[self.cur_op_index]
    cur_tab_data.select:SetActive(true)
    if cur_tab_data.init_func then cur_tab_data.init_func(self) end
    cur_tab_data.panel:SetActive(true)
end

function ServerFundUI:CloseCurTabPanel()
    if self.cur_op_index then
        local cur_tab_data = self.tab_op_data[self.cur_op_index]
        cur_tab_data.select:SetActive(false)
        cur_tab_data.panel:SetActive(false)
        self.cur_op_index = nil
    end
end

function ServerFundUI:InitServerFundPanel()
    self.fund_buy_count.text = string.format(UIConst.Text.CUR_SERVER_FUND_BUY_COUNT, self.dy_activity_data:GetServerFundCount())
    self:UpdateVipInfo()
    self:InitServerFundTaskList()
end

function ServerFundUI:UpdateVipInfo()
    local cur_vip = ComMgrs.dy_data_mgr:ExGetRoleVip()
    local vip_data = SpecMgrs.data_mgr:GetVipData(cur_vip)
    self.vip_img:SetActive(vip_data ~= nil)
    self.not_vip_text:SetActive(vip_data == nil)
    if vip_data then
        UIFuncs.AssignSpriteByIconID(vip_data.icon, self.vip_img:GetComponent("Image"))
    end
end

function ServerFundUI:InitServerFundTaskList()
    self:ClearServerFundTaskItem()
    local server_fund_data = SpecMgrs.data_mgr:GetOpenServiceFundData(kOpenServerFundId)
    for _, task_data in ipairs(self.dy_activity_data:GetServerFundTaskList()) do
        local task_item = self.parent_ui:GetUIObject(self.fund_task_item, self.fund_task_list)
        self.server_fund_task_item_dict[task_data.id] = task_item
        task_item:FindChild("Title/Text"):GetComponent("Text").text = string.format(UIConst.Text.GET_SERVER_FUND_REWARD_LIMIT, task_data.required_level)
        UIFuncs.InitItemGo({
            go = task_item:FindChild("Reward/Item"),
            item_id = server_fund_data.item_id,
            count = task_data.item_num,
            change_name_color = true,
            ui = self,
        })
        local task_state = self.dy_activity_data:GetServerFundRewardState(task_data.id)
        self:InitTaskItemState(task_data.id, task_item, task_state, self.server_fund_recieve_effect_dict, self.SendGetServerFundReward)
    end
    self.fund_task_list_rect.anchoredPosition = Vector2.zero
end

function ServerFundUI:InitTaskItemState(task_id, task_item, task_state, effect_dict, recieve_cb)
    local picked = task_item:FindChild("Reward/State/Picked")
    local recieve_btn = task_item:FindChild("Reward/State/RecieveBtn")
    picked:SetActive(task_state == CSConst.RewardState.picked)
    recieve_btn:SetActive(task_state ~= CSConst.RewardState.picked)
    recieve_btn:GetComponent("Button").interactable = task_state == CSConst.RewardState.pick
    recieve_btn:FindChild("Disable"):SetActive(task_state == CSConst.RewardState.unpick)
    if task_state == CSConst.RewardState.pick then
        self:AddClick(recieve_btn, function ()
            recieve_cb(self, task_id)
        end)
        local effect = UIFuncs.AddCompleteEffect(self.parent_ui, recieve_btn)
        effect_dict[task_id] = effect
    end
end

function ServerFundUI:ClearServerFundTaskItem()
    for id, effect in pairs(self.server_fund_recieve_effect_dict) do
        local effect_go = self.server_fund_task_item_dict[id]
        self:RemoveUIEffect(effect_go:FindChild("Reward/State/RecieveBtn"), effect)
    end
    self.server_fund_recieve_effect_dict = {}
    for _, task_item in pairs(self.server_fund_task_item_dict) do
        self.parent_ui:DelUIObject(task_item)
    end
    self.server_fund_task_item_dict = {}
end

function ServerFundUI:InitFundWelfarePanel()
    self:InitFundBuyCount()
    self:InitFundWelfareTaskList()
end

function ServerFundUI:UpdateServerFundCount(_, cur_count)
    self.fund_buy_count.text = string.format(UIConst.Text.CUR_SERVER_FUND_BUY_COUNT, cur_count)
    if cur_count <= self.cur_buy_count then return end
    self.count_offset = cur_count - self.cur_buy_count
    if self.is_count_moving then return end
    self.is_count_moving = true
    self:PlayCountAnim()
end

function ServerFundUI:PlayCountAnim()
    local target_count = self.cur_buy_count + self.count_offset
    for name, count_unit in pairs(kCountUnitDict) do
        local count_slide_cmp = self.buy_count_slide_cmp_dict[name]
        local target_unit_num = math.floor((target_count % (count_unit * 10)) / count_unit)
        local cur_unit_num = math.floor((self.cur_buy_count % (count_unit * 10)) / count_unit)
        local num_offset = (target_unit_num - cur_unit_num) % 10
        if num_offset > 0 then
            self.wait_anim_count = self.wait_anim_count + num_offset
            count_slide_cmp:SlideByOffset(-num_offset)
        end
    end
    self.cur_buy_count = target_count
    self.count_offset = 0
end

function ServerFundUI:InitFundBuyCount()
    self.cur_buy_count = self.dy_activity_data:GetServerFundCount()
    for name, count_unit in pairs(kCountUnitDict) do
        local count_slide_cmp = self.buy_count_slide_cmp_dict[name]
        count_slide_cmp:ResetLoopOffset()
        local count_offset = math.floor((self.cur_buy_count % (count_unit * 10)) / count_unit)
        count_slide_cmp:SetToIndex(-count_offset)
    end
    self.count_offset = 0
    self.is_count_moving = false
end

function ServerFundUI:InitFundWelfareTaskList()
    self:ClearFundWelfareTaskItem()
    for i, task_data in ipairs(self.dy_activity_data:GetFundWelfareTaskList()) do
        local task_item = self.parent_ui:GetUIObject(self.fund_task_item, self.welfare_task_list)
        self.fund_welfare_task_item_dict[task_data.id] = task_item
        task_item:FindChild("Title/Text"):GetComponent("Text").text = string.format(UIConst.Text.GET_FUND_WELFARE_REWARD_LIMIT, task_data.required_count)
        UIFuncs.InitItemGo({
            go = task_item:FindChild("Reward/Item"),
            item_id = task_data.item_id,
            count = task_data.item_num,
            change_name_color = true,
            ui = self,
        })
        local task_state = self.dy_activity_data:GetFundWelfareRewardState(task_data.id)
        self:InitTaskItemState(task_data.id, task_item, task_state, self.fund_welfare_recieve_effect_dict, self.SendGetFundWelfareReward)
    end
    self.welfare_task_list_rect.anchoredPosition = Vector2.zero
end

function ServerFundUI:SendBuyServerFund()
    if self.dy_activity_data:GetServerFundBuyState() then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.HAVE_BUY_SERVER_FUND)
        return
    end
    local server_fund_data = SpecMgrs.data_mgr:GetOpenServiceFundData(kOpenServerFundId)
    if ComMgrs.dy_data_mgr:ExGetRoleVip() < server_fund_data.vip_level then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.SERVER_FUND_VIP_LIMIT)
        return
    end
    if not UIFuncs.CheckItemCount(server_fund_data.item_id, server_fund_data.item_num, true) then return end
    local item_name = UIFuncs.GetItemName({item_id = server_fund_data.item_id})
    local confirm_cb = function ()
        SpecMgrs.msg_mgr:SendBuyServerFund({id = kOpenServerFundId}, function (resp)
            if resp.errcode ~= 0 then
                SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.BUY_SERVER_FUND_FAILED)
            else
                self:UpdateServerFundBuyState()
                SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.BUY_SERVER_FUND_SUCCESS)
            end
        end)
    end
    local param = {
        item_id = server_fund_data.item_id,
        need_count = server_fund_data.item_num,
        confirm_cb = confirm_cb,
        desc = string.format(UIConst.Text.MONEY_COST_TIPS, server_fund_data.item_num, item_name, UIConst.Text.BUY_SERVER_FUND_REMIND_TEXT),
        title = UIConst.Text.SERVER_FUND_TEXT,
    }
    SpecMgrs.ui_mgr:ShowItemUseRemindByTb(param)
end

function ServerFundUI:SendGetServerFundReward(reward_id)
    SpecMgrs.msg_mgr:SendGetServerFundReward({id = reward_id}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_SERVER_FUND_REWARD_FAILED)
        end
    end)
end

function ServerFundUI:SendGetFundWelfareReward(reward_id)
    SpecMgrs.msg_mgr:SendGetFundWelfareReward({id = reward_id}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_FUND_WELFARE_REWARD_FAILED)
        end
    end)
end

function ServerFundUI:RemoveServerFundBuyEffect()
    if self.server_fund_buy_effect then
        self.parent_ui:RemoveUIEffect(self.server_fund_buy_btn, self.server_fund_buy_effect)
        self.server_fund_buy_effect = nil
    end
    if self.fund_welfare_buy_effect then
        self.parent_ui:RemoveUIEffect(self.fund_welfare_buy_btn, self.fund_welfare_buy_effect)
        self.fund_welfare_buy_effect = nil
    end
end

function ServerFundUI:ClearFundWelfareTaskItem()
    for id, effect in pairs(self.fund_welfare_recieve_effect_dict) do
        local effect_go = self.fund_welfare_task_item_dict[id]
        self:RemoveUIEffect(effect_go:FindChild("Reward/State/RecieveBtn"), effect)
    end
    self.fund_welfare_recieve_effect_dict = {}
    for _, task_item in pairs(self.fund_welfare_task_item_dict) do
        self.parent_ui:DelUIObject(task_item)
    end
    self.fund_welfare_task_item_dict = {}
end

function ServerFundUI:ClearUnitModel()
    if self.server_fund_unit then
        self:RemoveUnit(self.server_fund_unit)
        self.server_fund_unit = nil
    end
    if self.fund_welfare_unit then
        self:RemoveUnit(self.fund_welfare_unit)
        self.fund_welfare_unit = nil
    end
end

return ServerFundUI