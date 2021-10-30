local UIFuncs = require("UI.UIFuncs")
local target_position_x = -780

local HonorTitlePanel = class("UI.ChurchUI.HonorTitlePanel")

function HonorTitlePanel:InitRes(go, root_ui)
    self.go = go
    self.root_ui = root_ui
    self.canvasGroup = go:GetComponent("CanvasGroup")
    self.rectTransform = go:GetComponent("RectTransform")
    self.role_info_panel = go:FindChild("RoleInfoPanel")
    self.title_img = go:FindChild("TitleImg"):GetComponent("Image")
    self.roleName_txt = go:FindChild("RoleInfoPanel/RoleNameText"):GetComponent("Text")
    self.vip_gameObject = go:FindChild("RoleInfoPanel/RoleNameText/VipImg")
    self.vip_img = self.vip_gameObject:GetComponent("Image")
end

function HonorTitlePanel:UpdateTitleId(title_id, direction)
    if self.ticker then
        self.root_ui:RemoveTicker(self.ticker)
    end
    self.current_title_id = title_id
    local finish_funs = function()
        self:UpdateContent()
        self.canvasGroup.alpha = 0
        self.rectTransform.anchoredPosition = Vector2.New(0, 0)
        self.ticker = self.root_ui:AddTicker(0.2, function(delta)
            return self:_ShowingAnimation(delta)
        end, function()
            self.ticker = nil
        end)
    end
    self.ticker = self.root_ui:AddTicker(0.2, function(delta)
        return self:_HidingAnimation(delta, direction)
    end, finish_funs)
end

function HonorTitlePanel:UpdateContent()
    local item_data = SpecMgrs.data_mgr:GetItemData(self.current_title_id)
    UIFuncs.AssignSpriteByIconID(item_data.icon, self.title_img)
    local title_data = ComMgrs.dy_data_mgr.church_data:GetTitleDataById(self.current_title_id)
    local current_name = title_data.current_name
    if current_name then
        self.roleName_txt.text = current_name
        local current_vip = title_data.current_vip
        if current_vip > 0 then
            local icon_id = SpecMgrs.data_mgr:GetVipData(current_vip).icon
            UIFuncs.AssignSpriteByIconID(icon_id, self.vip_img)
            self.vip_gameObject:SetActive(true)
        else
            self.vip_gameObject:SetActive(false)
        end
        self.role_info_panel:SetActive(true)
    else
        self.role_info_panel:SetActive(false)
    end
end

function HonorTitlePanel:_ShowingAnimation(delta)
    if IsNil(self.go) then
        return false
    end
    self.canvasGroup.alpha = delta
    return true
end

function HonorTitlePanel:_HidingAnimation(delta, direction)
    if IsNil(self.go) then
        return false
    end
    self.rectTransform.anchoredPosition = Vector2.New(direction * target_position_x * delta, 0)
    return true
end

function HonorTitlePanel:ResetAnimation()
    if self.ticker then
        self.root_ui:RemoveTicker(self.ticker)
        self:UpdateContent()
        self.canvasGroup.alpha = 1
        self.rectTransform.anchoredPosition = Vector2.New(0, 0)
        self.ticker = nil
    end
end

return HonorTitlePanel