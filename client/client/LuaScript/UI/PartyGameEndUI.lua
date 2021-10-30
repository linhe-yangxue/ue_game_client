local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local PartyGameEndUI = class("UI.PartyGameEndUI", UIBase)
local UnitConst = require("Unit.UnitConst")
local UIFuncs = require("UI.UIFuncs")

PartyGameEndUI.need_sync_load = true

function PartyGameEndUI:DoInit()
    PartyGameEndUI.super.DoInit(self)
    self.prefab_path = "UI/Common/PartyGameEndUI"
    self.show_reward_item_id = SpecMgrs.data_mgr:GetParamData("party_integral").item_id
end

function PartyGameEndUI:OnGoLoadedOk(res_go)
    PartyGameEndUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function PartyGameEndUI:Show(reward_count)
    self.reward_count = reward_count
    if self.is_res_ok then
        self:InitUI()
    end
    PartyGameEndUI.super.Show(self)
end

function PartyGameEndUI:InitRes()
    self:AddClick(self.main_panel:FindChild("CloseBg"), function()
        SpecMgrs.ui_mgr:HideUI(self)
    end)
    local content_go = self.main_panel:FindChild("Frame/Content")
    self.main_panel:FindChild("Frame/Up/Text"):GetComponent("Text").text = UIConst.Text.CONGRATULATE_GET
    self.main_panel:FindChild("Frame/Text"):GetComponent("Text").text = UIConst.Text.CLOSE_TIP_TEXT
    self.reward_item_go = UIFuncs.GetIconGo(self, content_go:FindChild("Item"), nil, UIConst.PrefabResPath.Item)
    self.reward_item_count_text = content_go:FindChild("Text"):GetComponent("Text")
end

function PartyGameEndUI:InitUI()
    local item_data = SpecMgrs.data_mgr:GetItemData(self.show_reward_item_id)
    local param_tb = {item_data = item_data, go = self.reward_item_go}
    UIFuncs.InitItemGo(param_tb)
    self.reward_item_count_text.text = string.format(UIConst.Text.ITEM_NAME_COUNT, item_data.name, self.reward_count)
end

function PartyGameEndUI:Hide()
    self.reward_count = nil
    PartyGameEndUI.super.Hide(self)
end

return PartyGameEndUI