local UIBase = require("UI.UIBase")
local DyDataConst = require("DynamicData.DyDataConst")

local MaskUI = class("UI.MaskUI", UIBase)

function MaskUI:DoInit()
    MaskUI.super.DoInit(self)
    self.prefab_path = "UI/Common/MaskUI"
end

function MaskUI:OnGoLoadedOk(res_go)
    MaskUI.super.OnGoLoadedOk(self, res_go)
end

function MaskUI:Hide()
    MaskUI.super.Hide(self)
end

return MaskUI