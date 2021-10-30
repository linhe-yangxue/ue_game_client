local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
-- local UIFuncs = require("UI.UIFuncs")

local MoneyCostUI = class("UI.MoneyCostUI", UIBase)

function MoneyCostUI:DoInit()
    MoneyCostUI.super:DoInit(self)
    self.prefab_path = "UI/Common/MoneyCostUI"
    self.dy_bag_data = ComMgrs.dy_data_mgr.bag_data
end

function MoneyCostUI:OnGoLoadedOk(res_go)
    MoneyCostUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function MoneyCostUI:Show(data)
    self.cost_data = data
    if self.is_res_ok then
        self:InitUI()
    end
    MoneyCostUI.super.Show(self)
end

function MoneyCostUI:Hide()
    if self.cost_data and self.cost_data.cancel_cb then
        self.cost_data.cancel_cb()
        self.cost_data = nil
    end
    MoneyCostUI.super.Hide(self)
end

function MoneyCostUI:InitRes()
    local top_panel = self.main_panel:FindChild("Content/TopPanel")
    self.title = top_panel:FindChild("Title"):GetComponent("Text")
    self:AddClick(top_panel:FindChild("CloseBtn"), function ()
        self:Hide()
    end)
    local content_panel = self.main_panel:FindChild("Content/ContentPanel")
    self.tips_text = content_panel:FindChild("TipsText"):GetComponent("Text")
    self.remind_toggle = content_panel:FindChild("RemindToggle"):GetComponent("Toggle")
    self.remind_toggle.isOn = false
    self:AddClick(content_panel:FindChild("CancelBtn"), function ()
        if self.cost_data.cancel_cb then self.cost_data.cancel_cb() end
        self:Hide()
    end)
    self:AddClick(content_panel:FindChild("ConfirmBtn"), function ()
        if self.dy_bag_data:GetBagItemCount(self.cost_data.currency_id) < self.cost_data.count then
            local item_data = SpecMgrs.data_mgr:GetItemData(self.cost_data.currency_id)
            SpecMgrs.ui_mgr:ShowMsgBox(string.format(UIConst.Text.ITEM_NOT_ENOUGH, item_data.name))
            self.cost_data = nil
            self:Hide()
            return
        end
        self.cost_data.confirm_cb()
        if self.remind_toggle.isOn == true then
            ComMgrs.dy_data_mgr:ExSetItemUseNoLongerRemind(self.cost_data.remind_tag)
        end
        self.cost_data = nil
        self:Hide()
    end)
end

function MoneyCostUI:InitUI()
    if not self.cost_data or not self.cost_data.currency_id then
        self:Hide()
        return
    end
    self:UpdateMoneyCostUI()
end

function MoneyCostUI:UpdateMoneyCostUI()
    local currency_data = SpecMgrs.data_mgr:GetItemData(self.cost_data.currency_id)
    self.title.text = self.cost_data.title or UIConst.Text.MONEY_COST_DEFAULT_TITLE
    self.tips_text.text = string.format(UIConst.Text.MONEY_COST_TIPS, self.cost_data.count, currency_data.name, self.cost_data.result_str)
end

function MoneyCostUI:UpdateMoneyCostCount(count)
    self.cost_data.count = count
    self:UpdateMoneyCostUI()
end

function MoneyCostUI:UpdateMoneyCostCountByOffset(offset)
    self.cost_data.count = self.cost_data.count + offset
    self:UpdateMoneyCostUI()
end

return MoneyCostUI