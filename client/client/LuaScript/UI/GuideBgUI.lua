local UIBase = require("UI.UIBase")

local GuideBgUI = class("UI.GuideBgUI", UIBase)

function GuideBgUI:DoInit()
    GuideBgUI.super.DoInit(self)
    self.prefab_path = "UI/Common/GuideBgUI"
end

function GuideBgUI:OnGoLoadedOk(res_go)
    GuideBgUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function GuideBgUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    GuideBgUI.super.Show(self)
end

function GuideBgUI:Hide()
    GuideBgUI.super.Hide(self)
end

function GuideBgUI:InitRes()
end

function GuideBgUI:InitUI()
end

return GuideBgUI