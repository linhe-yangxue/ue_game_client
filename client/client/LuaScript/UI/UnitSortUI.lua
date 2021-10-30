local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UnitSortUI = class("UI.UnitSortUI",UIBase)

--  用于排序单位的ui
function UnitSortUI:DoInit()
    UnitSortUI.super.DoInit(self)
    self.prefab_path = "UI/Common/UnitSortUI"
end

function UnitSortUI:OnGoLoadedOk(res_go)
    UnitSortUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function UnitSortUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    UnitSortUI.super.Show(self)
end

function UnitSortUI:InitRes()

end

function UnitSortUI:InitUI()
    self:SetTextVal()
    self:UpdateData()
    self:UpdateUIInfo()
end

function UnitSortUI:UpdateData()

end

function UnitSortUI:UpdateUIInfo()

end

function UnitSortUI:SetTextVal()
end

return UnitSortUI
