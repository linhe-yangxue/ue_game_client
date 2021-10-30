local RedPointBase = require("UI.RedPointTypeClass.RedPointBase")

local RedPointHighLight = class("UI.RedPointTypeClass.RedPointHighLight", RedPointBase)

function RedPointHighLight:DoInit(param_tb)
    if not RedPointHighLight.super.DoInit(self, param_tb) then
        return false
    end
    self.is_show = false
    local rect = self.go:GetComponent("RectTransform")
    local anchor_v2 = param_tb.anchor_v2 or Vector2.New(0.5, 0.5)
    local pivot_v2 = param_tb.pivot_v2 or Vector2.New(0.5, 0.5)
    rect.anchorMin = anchor_v2
    rect.anchorMax = anchor_v2
    rect.pivot = pivot_v2
    return true
end

function RedPointHighLight:DoDestroy()
    self.is_show = nil
    RedPointHighLight.super.DoDestroy(self)
end

function RedPointHighLight:Show()
    if not RedPointHighLight.super.Show(self) then
        return false
    end
    if not self.is_show then
        self.go:SetActive(true)
        self.is_show = true
    end
    return true
end

function RedPointHighLight:Hide()
    if not RedPointHighLight.super.Hide(self) then
        return false
    end
    if self.is_show then
        self.go:SetActive(false)
        self.is_show = false
    end
    return true
end

return RedPointHighLight