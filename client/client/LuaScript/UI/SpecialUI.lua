local UIBase = require("UI.UIBase")
local UnitConst = require("Unit.UnitConst")

local SpecialUI = class("UI.SpecialUI",UIBase)

function SpecialUI:DoInit()
    SpecialUI.super.DoInit(self)
    self.prefab_path = "UI/Common/SpecialUI"
    self.info_root_dict = {}
    self.info_pref_dict = {}
end

function SpecialUI:OnGoLoadedOk(res_go)
    SpecialUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
end

function SpecialUI:InitRes()
    self.info_panel = self.main_panel:FindChild("InfoPanel")
    local temp_group = self.main_panel:FindChild("Temp")
    self.info_root = temp_group:FindChild("InfoRoot")
    for info_type, index in pairs(UnitConst.UNITINFO_TYPE) do
        self.info_pref_dict[index] = temp_group:FindChild(info_type)
    end
end

function SpecialUI:AddUnitInfoRoot(unit)
    return self:GetUIObject(self.info_root, self.info_panel)
    -- -- TODO 注册单位死亡事件隐藏单位信息
    -- unit:RegisterUnitDeathBeginEvent("SpecialUI", self.RemoveUnitInfo, self)
end

function SpecialUI:GetInfoItem(info_type)
    local temp = self.info_pref_dict[info_type]
    if not temp then return end
    local go = self:GetUIObject(temp)
    return go
end

function SpecialUI:DelInfoItem(item)
    self:DelUIObject(item)
end

return SpecialUI