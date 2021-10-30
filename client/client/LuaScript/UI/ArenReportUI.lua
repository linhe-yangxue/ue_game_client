local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local CSConst = require("CSCommon.CSConst")
local UIFuncs = require("UI.UIFuncs")
local ItemUtil = require("BaseUtilities.ItemUtil")
local ArenReportUI = class("UI.ArenReportUI",UIBase)

local fix_reward_list = {
    CSConst.Virtual.Money,
    CSConst.Virtual.Exp,
    CSConst.Virtual.ArenaCoin,
}

--  扫荡战报
function ArenReportUI:DoInit()
    ArenReportUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ArenReportUI"
end

function ArenReportUI:OnGoLoadedOk(res_go)
    ArenReportUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function ArenReportUI:Show(challenge_time, reward_dict, random_reward)
    self.challenge_time = challenge_time
    self.reward_dict = reward_dict
    self.random_reward = random_reward

    if self.is_res_ok then
        self:InitUI()
    end
    ArenReportUI.super.Show(self)
end

function ArenReportUI:InitRes()
    self.sweep_end_btn = self.main_panel:FindChild("Panel/SweepEndBtn")
    self:AddClick(self.sweep_end_btn, function()
        self:Hide()
    end)
    self.sweep_end_btn_text = self.main_panel:FindChild("Panel/SweepEndBtn/SweepEndBtnText"):GetComponent("Text")
    self.consume_text = self.main_panel:FindChild("Panel/Titile/ConsumeText"):GetComponent("Text")
    self.obtain_text = self.main_panel:FindChild("Panel/Titile/ObtainText"):GetComponent("Text")
    self.content = self.main_panel:FindChild("Panel/Content")
    self.item = self.main_panel:FindChild("Panel/Temp/Item")
    self.sweep_time_text = self.main_panel:FindChild("Panel/SweepTimeText"):GetComponent("Text")
    self.win_time_text = self.main_panel:FindChild("Panel/WinTimeText"):GetComponent("Text")
    self.consume_val_text = self.main_panel:FindChild("Panel/ConsumeItem/ItemValText"):GetComponent("Text")
    self.consume_item_text = self.main_panel:FindChild("Panel/ConsumeItem/ItemText"):GetComponent("Text")
    self.fix_item1 = self.main_panel:FindChild("Panel/FixItem1")
    self.fix_item2 = self.main_panel:FindChild("Panel/FixItem2")
    self.fix_item3 = self.main_panel:FindChild("Panel/FixItem3")

    self.item:SetActive(false)
end

function ArenReportUI:InitUI()
    self:SetTextVal()
    self:UpdateData()
    self:UpdateUIInfo()
end

function ArenReportUI:UpdateData()

end

function ArenReportUI:UpdateUIInfo()
    self.sweep_time_text.text = string.format(UIConst.Text.SWEEP_TIME_FORMAT, self.challenge_time)
    self.win_time_text.text = string.format(UIConst.Text.WIN_TIME_FORMAT, self.challenge_time)

    for id, num in pairs(self.reward_dict) do
        if id == fix_reward_list[1] then
            UIFuncs.AssignItemMes(self.fix_item1, fix_reward_list[1], num)
        end
        if id == fix_reward_list[2] then
            UIFuncs.AssignItemMes(self.fix_item2, fix_reward_list[2], num)
        end
        if id == fix_reward_list[3] then
            UIFuncs.AssignItemMes(self.fix_item3, fix_reward_list[3], num)
        end
    end
    self:SetItemList(ItemUtil.ItemDictToItemDataList(self.random_reward), self.content)

    self.consume_val_text.text = self.challenge_time * SpecMgrs.data_mgr:GetParamData("arena_cost_vitality").f_value
    self.consume_item_text.text = UIConst.Text.VITALITY_TEXT
end

function ArenReportUI:SetTextVal()
    self.consume_text.text = UIConst.Text.TOTAL_CONSUME_TEXT
    self.obtain_text.text = UIConst.Text.TOTAL_GET
end

function ArenReportUI:Hide()
    self:DelAllCreateUIObj()
    ArenReportUI.super.Hide(self)
end
return ArenReportUI
