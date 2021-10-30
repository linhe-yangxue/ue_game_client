local RedPointBase = require("UI.RedPointTypeClass.RedPointBase")

local RedPointWithNumber = class("UI.RedPointTypeClass.RedPointWithNumber", RedPointBase)

function RedPointWithNumber:DoInit(param_tb)
    if not RedPointWithNumber.super.DoInit(self, param_tb) then
        return false
    end
    self.is_active = false
    local rect = self.go:GetComponent("RectTransform")
    local anchor_v2 = param_tb.anchor_v2 or Vector2.New(1, 1)
    local pivot_v2 = param_tb.pivot_v2 or Vector2.New(0.5, 0.5)
    rect.anchorMin = anchor_v2
    rect.anchorMax = anchor_v2
    rect.pivot = pivot_v2
    self.number_text = self.go:FindChild("Text"):GetComponent("Text")
    return true
end

function RedPointWithNumber:DoDestroy()
    self.is_active = nil
    self.number_text = nil
    RedPointWithNumber.super.DoDestroy(self)
end

function RedPointWithNumber:Show(param_dict)
    if not RedPointWithNumber.super.Show(self) then
        return false
    end
    local sum = 0
    for control_id, v in pairs(param_dict) do
        sum = sum + v
    end
    self.number_text.text = sum
    if not self.is_active then
        self.go:SetActive(true)
        self.is_active = true
    end
    return true
end

function RedPointWithNumber:Hide()
    if not RedPointWithNumber.super.Hide(self) then
        return false
    end
    if self.is_active then
        self.go:SetActive(false)
        self.is_active = false
    end
    return true
end

return RedPointWithNumber