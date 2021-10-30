local RedPointBase = require("UI.RedPointTypeClass.RedPointBase")

local RedPointNormal = class("UI.RedPointTypeClass.RedPointNormal", RedPointBase)

function RedPointNormal:DoInit(param_tb)
    if not RedPointNormal.super.DoInit(self, param_tb) then
        return false
    end
    self.is_show = false
    local rect = self.go:GetComponent("RectTransform")
    local anchor_v2 = param_tb.anchor_v2 or Vector2.New(1, 1)
    local pivot_v2 = param_tb.pivot_v2 or Vector2.New(0.5, 0.5)
    rect.anchorMin = anchor_v2
    rect.anchorMax = anchor_v2
    rect.pivot = pivot_v2
    return true
end

function RedPointNormal:DoDestroy()
    self.is_show = nil
    RedPointNormal.super.DoDestroy(self)
end

function RedPointNormal:Show()
    if not RedPointNormal.super.Show(self) then
        return false
    end
    if not self.is_show then
        self.go:SetActive(true)
        self.is_show = true
    end
    return true
end

function RedPointNormal:Hide()
    if not RedPointNormal.super.Hide(self) then
        return false
    end
    if self.is_show then
        self.go:SetActive(false)
        self.is_show = false
    end
    return true
end

return RedPointNormal