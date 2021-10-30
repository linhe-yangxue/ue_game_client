local UIBase = require("UI.UIBase")

local LoadingUI = class("UI.LoadingUI", UIBase)

function LoadingUI:DoInit()
    LoadingUI.super.DoInit(self)
    self.prefab_path = "UI/Common/LoadingUI"
end

function LoadingUI:OnGoLoadedOk(res_go)
    LoadingUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function LoadingUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    LoadingUI.super.Show(self)
end

function LoadingUI:Hide()
    LoadingUI.super.Hide(self)
end

function LoadingUI:InitRes()
end

function LoadingUI:InitUI()
end

return LoadingUI