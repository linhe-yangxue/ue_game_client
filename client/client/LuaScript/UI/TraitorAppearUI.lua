local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local TraitorAppearUI = class("UI.TraitorAppearUI", UIBase)

function TraitorAppearUI:DoInit()
    TraitorAppearUI.super.DoInit(self)
    self.prefab_path = "UI/Common/TraitorAppearUI"
    self.dy_traitor_data = ComMgrs.dy_data_mgr.traitor_data
end

function TraitorAppearUI:OnGoLoadedOk(res_go)
    TraitorAppearUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function TraitorAppearUI:Hide()
    self:RemoveUnit(self.traitor_unit)
    TraitorAppearUI.super.Hide(self)
end

function TraitorAppearUI:Show(traitor_info)
    if not traitor_info then return end
    self.traitor_info = traitor_info
    if self.is_res_ok then
        self:InitUI()
    end
    TraitorAppearUI.super.Show(self)
end

function TraitorAppearUI:InitRes()
    local content = self.main_panel:FindChild("Content")
    self.traitor_model = content:FindChild("TraitorModel")
    self.traitor_info_text = content:FindChild("Text"):GetComponent("Text")
    local later_btn = content:FindChild("LaterBtn")
    later_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.WAIT_TO_NAMING
    self:AddClick(later_btn, function ()
        self:Hide()
    end)
    local immediately_btn = content:FindChild("ImmediatelyBtn")
    immediately_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.IMMEDIATELY_ATTACK_TRAITOR
    self:AddClick(immediately_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("TraitorPreviewUI", self.traitor_info)
        self:Hide()
    end)
end

function TraitorAppearUI:InitUI()
    local traitor_data = SpecMgrs.data_mgr:GetTraitorData(self.traitor_info.traitor_id)
    self.traitor_unit = self:AddHalfUnit(traitor_data.unit_id, self.traitor_model)
    local traitor_name = self.dy_traitor_data:GetTraitorName(self.traitor_info.traitor_id, self.traitor_info.quality)
    self.traitor_info_text.text = string.format(UIConst.Text.TRAITOR_APPEAR_TEXT, traitor_name)
end

return TraitorAppearUI