local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local RewardPreviewUI = class("UI.RewardPreviewUI", UIBase)

function RewardPreviewUI:DoInit()
    RewardPreviewUI.super.DoInit(self)
    self.prefab_path = "UI/Common/RewardPreviewUI"
    self.reward_item_list = {}
end

function RewardPreviewUI:OnGoLoadedOk(res_go)
    RewardPreviewUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function RewardPreviewUI:Hide()
    self.reward_data = nil
    self:ClearRewardItem()
    RewardPreviewUI.super.Hide(self)
end

-- item_list or reward_id, confirm_cb, cancel_cb
function RewardPreviewUI:Show(data)
    self.reward_data = data
    if self.is_res_ok then
        self:InitUI()
    end
    RewardPreviewUI.super.Show(self)
end

function RewardPreviewUI:InitRes()
    local content = self.main_panel:FindChild("Box")
    self.title = content:FindChild("Title"):GetComponent("Text")
    self.desc = content:FindChild("Desc"):GetComponent("Text")
    self:AddClick(content:FindChild("CloseBtn"), function ()
        if self.reward_data.cancel_cb then self.reward_data.cancel_cb() end
        self:Hide()
    end)
    self.reward_content = content:FindChild("RewardContent/View/Content")
    self.reward_item = self.reward_content:FindChild("Item")
    self.op_btn_panel = content:FindChild("OpBtnPanel")
    local cancel_btn = self.op_btn_panel:FindChild("CancelBtn")
    cancel_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CANCEL
    self:AddClick(cancel_btn, function ()
        if self.reward_data.cancel_cb then self.reward_data.cancel_cb() end
        self:Hide()
    end)
    local submit_btn = self.op_btn_panel:FindChild("ConfirmBtn")
    submit_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CONFIRM
    self:AddClick(submit_btn, function ()
        if self.reward_data.confirm_cb then self.reward_data.confirm_cb() end
        self:Hide()
    end)
    self.reward_state_panel = content:FindChild("RewardStatePanel")
    self.obtain_btn = self.reward_state_panel:FindChild("ObtainBtn")
    self.obtain_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.GET_REWARD
    self.obtain_btn_cmp = self.obtain_btn:GetComponent("Button")
    self:AddClick(self.obtain_btn, function ()
        if self.reward_data.confirm_cb then self.reward_data.confirm_cb() end
        self:Hide()
    end)
    self.obtain_disable = self.obtain_btn:FindChild("Disable")
    self.obtained = self.reward_state_panel:FindChild("Obtained")
    self.obtained:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ALREADY_RECEIVE_TEXT
end

function RewardPreviewUI:InitUI()
    if not self.reward_data then
        self:Hide()
        return
    end
    self.title.text = self.reward_data.title or UIConst.Text.REWARD_PREVIEW_TITLE
    self.desc.text = self.reward_data.desc or UIConst.Text.REWARD_PREVIEW_DESC
    self:ClearRewardItem()
    self.op_btn_panel:SetActive(self.reward_data.reward_state == nil)
    self.reward_state_panel:SetActive(self.reward_data.reward_state ~= nil)
    if self.reward_data.item_list then
        for _, reward_data in ipairs(self.reward_data.item_list) do
            self:SetRewardContent(reward_data.item_id, reward_data.count)
        end
    elseif self.reward_data.reward_id then
        local reward_data = SpecMgrs.data_mgr:GetRewardData(self.reward_data.reward_id)
        for i, reward_item in ipairs(reward_data.reward_item_list) do
            self:SetRewardContent(reward_item, reward_data.reward_num_list[i])
        end
    end
    if self.reward_data.reward_state then self:InitRewardStateBtn() end
end

function RewardPreviewUI:SetRewardContent(item_id, count)
    local reward_item = self:GetUIObject(self.reward_item, self.reward_content)
    UIFuncs.InitItemGo({
        ui = self,
        go = reward_item:FindChild("Item"),
        item_id = item_id,
        change_name_color = true,
        count = count,
    })
    table.insert(self.reward_item_list, reward_item)
end

function RewardPreviewUI:InitRewardStateBtn()
    self.obtain_btn:SetActive(self.reward_data.reward_state ~= CSConst.RewardState.picked)
    self.obtained:SetActive(self.reward_data.reward_state == CSConst.RewardState.picked)
    self.obtain_btn_cmp.interactable = self.reward_data.reward_state == CSConst.RewardState.pick
    self.obtain_disable:SetActive(self.reward_data.reward_state == CSConst.RewardState.unpick)
end

function RewardPreviewUI:ClearRewardItem()
    for _, reward_item in ipairs(self.reward_item_list) do
        self:DelUIObject(reward_item)
    end
    self.reward_item_list = {}
end

return RewardPreviewUI