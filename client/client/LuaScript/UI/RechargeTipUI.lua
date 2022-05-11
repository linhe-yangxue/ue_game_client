local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local RechargeTipUI = class("UI.RechargeTipUI",UIBase)

--  充值提示
function RechargeTipUI:DoInit()
    RechargeTipUI.super.DoInit(self)
    self.prefab_path = "UI/Common/RechargeTipUI"
end

function RechargeTipUI:OnGoLoadedOk(res_go)
    RechargeTipUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function RechargeTipUI:Show(need_diamond)
    self.need_diamond = need_diamond
    if self.is_res_ok then
        self:InitUI()
    end
    RechargeTipUI.super.Show(self)
end

function RechargeTipUI:InitRes()
    self.tip = self.main_panel:FindChild("Tip"):GetComponent("Text")
    self.unit_rect = self.main_panel:FindChild("UnitRect")
    self.cancel_btn = self.main_panel:FindChild("CancelBtn")
    self:AddClick(self.cancel_btn, function()
        self:Hide()
    end)
    self.confirm_btn = self.main_panel:FindChild("ConfirmBtn")
    self:AddClick(self.confirm_btn, function()
        self:Hide()
        SpecMgrs.ui_mgr:ShowUI("RechargeUI")
        self:Hide()
    end)
    self:SetTextVal()
end

function RechargeTipUI:InitUI()
    self:DestroyAllUnit()
    self:UpdateData()
    self:UpdateUIInfo()
end

function RechargeTipUI:UpdateData()
    self.recharge_tip_unit_id = SpecMgrs.data_mgr:GetParamData("recharge_tip_unit").unit_id
    self.main_panel:FindChild("NeedDiamondText"):GetComponent("Text").text = self.need_diamond
end

function RechargeTipUI:UpdateUIInfo()
    self:AddFullUnit(self.recharge_tip_unit_id, self.unit_rect)
end

function RechargeTipUI:SetTextVal()
    self.tip.text = UIConst.Text.RECHARGE_TIP
    self.cancel_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CANCEL
    self.confirm_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.GO_TO_RECHARGE
end

function RechargeTipUI:Hide()
    RechargeTipUI.super.Hide(self)
end

return RechargeTipUI
