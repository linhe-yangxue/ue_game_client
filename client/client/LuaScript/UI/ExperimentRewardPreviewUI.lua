local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local ItemUtil = require("BaseUtilities.ItemUtil")
local ExperimentRewardPreviewUI = class("UI.ExperimentRewardPreviewUI",UIBase)

local stage_count = 3

--  试炼奖励预览
function ExperimentRewardPreviewUI:DoInit()
    ExperimentRewardPreviewUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ExperimentRewardPreviewUI"
end

function ExperimentRewardPreviewUI:OnGoLoadedOk(res_go)
    ExperimentRewardPreviewUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function ExperimentRewardPreviewUI:Show(stage_id, star_num)
    self.stage_data = SpecMgrs.data_mgr:GetTrainData(stage_id)
    self.star_num = star_num
    if self.is_res_ok then
        self:InitUI()
    end
    ExperimentRewardPreviewUI.super.Show(self)
end

function ExperimentRewardPreviewUI:InitRes()
    self.close_btn = self.main_panel:FindChild("Frame/CloseBtn")
    self:AddClick(self.close_btn, function()
        self:Hide()
    end)

    self.reward_preview_title = self.main_panel:FindChild("Frame/RewardPreviewTitle"):GetComponent("Text")
    self.star_reward_tip_text = self.main_panel:FindChild("Frame/StarRewardTipText")

    self.title_list = {}
    for i = 1, stage_count do
        table.insert(self.title_list, self.main_panel:FindChild("Frame/Title" .. i))
    end

    self.reward_item_content_list = {}
    for i = 1, stage_count do
        table.insert(self.reward_item_content_list, self.main_panel:FindChild("Frame/RewardItemList" .. i))
    end
end

function ExperimentRewardPreviewUI:InitUI()
    self:SetTextVal()
    self:UpdateData()
    self:UpdateUIInfo()
end

function ExperimentRewardPreviewUI:UpdateData()
    self.layer_data = SpecMgrs.data_mgr:GetTrainLayerData(self.stage_data.layer)
    self.reward_data_list = {}
    for i, v in ipairs(self.layer_data.reward_list) do
        table.insert(self.reward_data_list, ItemUtil.GetSortedRewardItemList(v))
    end
end

function ExperimentRewardPreviewUI:UpdateUIInfo()
    local tip_text = string.format(UIConst.Text.REWARD_PREVIEW_TIP_FORMAT, self.star_num, self.layer_data.stage_list[1], self.layer_data.stage_list[stage_count])
    self:SetTextPic(self.star_reward_tip_text, tip_text)
    for i, title_obj in ipairs(self.title_list) do
        self:SetTextPic(title_obj, string.format(UIConst.Text.ACHIEVE_STAR_FORMAT, self.layer_data.star_num_list[i]))
    end
    for i, content in ipairs(self.reward_item_content_list) do
        UIFuncs.SetItemList(self, self.reward_data_list[i], content)
    end
end

function ExperimentRewardPreviewUI:SetTextVal()
    self.reward_preview_title.text = UIConst.Text.REWARD_PREVIEW_TITLE
end

function ExperimentRewardPreviewUI:Hide()
    self:DelAllCreateUIObj()
    ExperimentRewardPreviewUI.super.Hide(self)
end

return ExperimentRewardPreviewUI
