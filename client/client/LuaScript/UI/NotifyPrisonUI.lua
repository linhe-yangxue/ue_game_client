local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local NotifyPrisonUI = class("UI.NotifyPrisonUI",UIBase)
local UIFuncs = require("UI.UIFuncs")

NotifyPrisonUI.need_sync_load = true

function NotifyPrisonUI:DoInit()
    NotifyPrisonUI.super.DoInit(self)
    self.prefab_path = "UI/Common/NotifyPrisonUI"
end

function NotifyPrisonUI:OnGoLoadedOk(res_go)
    NotifyPrisonUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function NotifyPrisonUI:Show(prison_id)
    self.prison_data = SpecMgrs.data_mgr:GetPrisonData(prison_id)
    if not self.prison_data then
        PrintWarn("There is no prison data  prison_id", prison_id)
        return
    end
    if self.is_res_ok then
        self:InitUI()
    end
    NotifyPrisonUI.super.Show(self)
end

function NotifyPrisonUI:InitRes()
    --tip_panel 以下 tp
    local content = self.main_panel:FindChild("Content")
    self.main_panel:FindChild("Content/Top/Title"):GetComponent("Text").text = UIConst.Text.CIRMINAL_SHOW
    self.unit_parent = content:FindChild("Criminal/UnitParent")
    self.tp_description_text = content:FindChild("BottonBar/Description"):GetComponent("Text")
    self:AddClick(content:FindChild("Top/CloseBtn"), function()
        self:Hide()
    end)
    self:AddClick(self.main_panel:FindChild("CloseBg"), function()
        self:Hide()
    end)
end

function NotifyPrisonUI:InitUI()
    self.tp_description_text.text = string.format(UIConst.Text.ARREST_CRIMINAL, self.prison_data.name)
    self.unit = self:AddHalfUnit(self.prison_data.hero_unit_id, self.unit_parent)
end

function NotifyPrisonUI:Hide()
    NotifyPrisonUI.super.Hide(self)
end

return NotifyPrisonUI