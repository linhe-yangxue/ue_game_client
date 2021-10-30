local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local ItemUtil = require("BaseUtilities.ItemUtil")
local UIFuncs = require("UI.UIFuncs")
local ExperimentReportUI = class("UI.ExperimentReportUI",UIBase)

local layer_stage_count = 3
local kRewardAnimDuration = 1

function ExperimentReportUI:DoInit()
    ExperimentReportUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ExperimentReportUI"
    self.reward_item_list = {}
    self.timer = nil
end

function ExperimentReportUI:OnGoLoadedOk(res_go)
    ExperimentReportUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function ExperimentReportUI:Show(result, layer_reward_id, layer, get_star)
    self.result_list = result
    self.layer_reward_id = layer_reward_id
    self.layer = layer
    self.get_star = get_star
    if self.is_res_ok then
        self:InitUI()
    end
    ExperimentReportUI.super.Show(self)
end

function ExperimentReportUI:InitRes()
    self.sweep_end_btn = self.main_panel:FindChild("Panel/SweepEndBtn")
    self.sweep_end_btn_text = self.main_panel:FindChild("Panel/SweepEndBtn/SweepEndBtnText"):GetComponent("Text")
    self.reward_item = self.main_panel:FindChild("Panel/Temp/RewardItem")
    self.money_reward_item = self.main_panel:FindChild("Panel/Temp/MoneyRewardItem")
    self.treasure_reward_item = self.main_panel:FindChild("Panel/Temp/TreasureRewardItem")
    self.content = self.main_panel:FindChild("Panel/List/ViewPort/Content")
    self.dialog_box = self.main_panel:FindChild("Panel/DialogBox")
    self.unit_point = self.main_panel:FindChild("Panel/UnitPoint")
    self:AddClick(self.sweep_end_btn, function()
        SpecMgrs.ui_mgr:HideUI(self)
    end)
end

function ExperimentReportUI:InitUI()
    self:SetTextVal()
    self:UpdateData()
    self:UpdateUIInfo()
end

function ExperimentReportUI:UpdateData()
    self.layer_data = SpecMgrs.data_mgr:GetTrainLayerData(self.layer)
end

function ExperimentReportUI:UpdateUIInfo()
    local stage_id_list = {}
    local index = 1
    self:AddTimer(function ()
        local item = self:GetUIObject(self.money_reward_item, self.content)
        local result_data = self.result_list[index]
        local item_data_list = {}
        for item_id, reward in pairs(result_data.reward_dict) do
            table.insert(item_data_list, {item_id = item_id, count = reward.count, crit = reward.crit})
        end
        local result = ItemUtil.SortRoleItemList(item_data_list)

        table.insert(self.reward_item_list, item)
        local stage_data = SpecMgrs.data_mgr:GetTrainData(result_data.stage_id)
        item:FindChild("TitleText"):GetComponent("Text").text = string.format(stage_data.name, stage_data.id)
        self:SetTextPic(item:FindChild("FirstRewardText"), self:GetRewardText(result[1]))
        self:SetTextPic(item:FindChild("SecondRewardText"), self:GetRewardText(result[2]))
        table.insert(stage_id_list, result_data.stage_id)
        index = index + 1
        if index > #self.result_list then self:UpdateTreasure(stage_id_list) end
    end, kRewardAnimDuration, #self.result_list)

    self:AddHalfUnit(UIConst.Unit.Housekeeper, self.unit_point)
    self.cur_talk = self:GetTalkCmp(self.dialog_box, 1, false, function ()
        return UIConst.Text.EXPERIMENT_REPORT_TEXT
    end)
end

function ExperimentReportUI:UpdateTreasure(stage_id_list)
    local treasure_item = self:GetUIObject(self.treasure_reward_item, self.content)
    treasure_item:FindChild("TitleText"):GetComponent("Text").text = UIConst.Text.TREASURE_REWARE
    treasure_item:FindChild("TipText"):GetComponent("Text").text = string.format(UIConst.Text.TREASURE_REWARE_TIP, stage_id_list[1], stage_id_list[#stage_id_list], self.get_star)

    local reward_data_list = ItemUtil.GetSortedRewardItemList(self.layer_reward_id)
    self:SetItemList(reward_data_list, treasure_item:FindChild("Content"))
end

function ExperimentReportUI:GetRewardText(reward_data)
    local item_data = SpecMgrs.data_mgr:GetItemData(reward_data.item_id)
    local ret = string.format(UIConst.Text.REWARD_FORMAT, item_data.name, item_data.icon, reward_data.count)
    if reward_data.crit then
        local crit_data = SpecMgrs.data_mgr:GetTrainCritData(reward_data.crit)
        ret = string.format(UIConst.Text.REWARD_CRIT_FORMAT, ret, crit_data.show_color, crit_data.name)
    end
    return ret
end

function ExperimentReportUI:SetTextVal()
    self.sweep_end_btn_text.text = UIConst.Text.SWEEP_END_BTN_TEXT
end

function ExperimentReportUI:Hide()
    if self.cur_talk then
        self.cur_talk:DoDestroy()
    end
    self:DelAllCreateUIObj()
    ExperimentReportUI.super.Hide(self)
end

return ExperimentReportUI
