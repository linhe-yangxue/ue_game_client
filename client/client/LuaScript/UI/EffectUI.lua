local UIBase = require("UI.UIBase")

EffectUI = class("UI.EffectUI", UIBase)

function EffectUI:DoInit()
    EffectUI.super.DoInit(self)
    self.prefab_path = "UI/Common/EffectUI"
end

function EffectUI:OnGoLoadedOk(res_go)
    EffectUI.super.OnGoLoadedOk(self,res_go)
end

function EffectUI:DoDestroy()
    self.super.DoDestroy(self)
end

return EffectUI