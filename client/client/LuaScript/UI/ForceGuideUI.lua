local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")

local ForceGuideUI = class("UI.ForceGuideUI", UIBase)

ForceGuideUI.need_sync_load = true

function ForceGuideUI:DoInit()
    ForceGuideUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ForceGuideUI"
end

function ForceGuideUI:OnGoLoadedOk(res_go)
    ForceGuideUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

-- taget_go 以这个物体的位置和大小设置黑框
-- guide_type 1: click 2 drag
-- alpha 遮罩透明度 0.7 或 0
function ForceGuideUI:Show(target_go, guide_type, alpha)
    self.target_go = target_go or self.can_not_touch
    self.guide_type = guide_type or 1
    self.alpha = alpha or 0
    if self.is_res_ok then
        self:InitUI()
    end
    ForceGuideUI.super.Show(self)
end

function ForceGuideUI:DoDestroy()
    ForceGuideUI.super.DoDestroy(self)
end

function ForceGuideUI:InitRes()
    self.guide_mask_comp = self.main_panel:GetComponent("GuideMask")
    self.can_not_touch = self.go:FindChild("CanNotTouch")
    local rect_trans = self.main_panel:GetComponent("RectTransform")
    self.can_not_touch:GetComponent("RectTransform").anchoredPosition = Vector2.New(rect_trans.rect.width / 2 + 20,rect_trans.rect.height / 2 + 20)
end

function ForceGuideUI:InitUI()
    self:SetGuideGo()
end

function ForceGuideUI:SetGuideGo()
    local guide_data = self.guide_data
    self.guide_mask_comp:SetTarget(self.target_go, self.guide_type, self.alpha)
end

return ForceGuideUI