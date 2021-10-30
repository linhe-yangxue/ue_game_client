local RedPointBase = require("UI.RedPointTypeClass.RedPointBase")
local UIFuncs = require("UI.UIFuncs")

local RedPointBubble = class("UI.RedPointTypeClass.RedPointBubble", RedPointBase)

function RedPointBubble:DoInit(param_tb)
    if not RedPointBubble.super.DoInit(self, param_tb) then
        return false
    end
    self.ui = param_tb.ui
    local rect = self.go:GetComponent("RectTransform")
    local anchor_v2 = param_tb.anchor_v2 or Vector2.New(0, 1)
    local pivot_v2 = param_tb.pivot_v2 or Vector2.New(0, 0)
    rect.anchorMin = anchor_v2
    rect.anchorMax = anchor_v2
    rect.pivot = pivot_v2
    self.ui_tween_alpha = self.go:GetComponent("UITweenAlpha")
    self.icon_image = self.go:FindChild("Icon"):GetComponent("Image")
    self.chat_text = self.go:FindChild("BubbleDialog/Text"):GetComponent("Text")
    return true
end

function RedPointBubble:DoDestroy()
    if self.bubble_timer then
        SpecMgrs.timer_mgr:RemoveTimer(self.bubble_timer)
        self.bubble_timer = nil
    end
    self.ui = nil
    self.ui_tween_alpha = nil
    self.icon_image = nil
    self.chat_text = nil
    RedPointBubble.super.DoDestroy(self)
end

function RedPointBubble:Show(param_dict)
    if not RedPointBubble.super.Show(self) then
        return false
    end
    local bubble_dialog_data_list = {}
    for control_id, _ in pairs(param_dict) do
        local dialog_data = SpecMgrs.data_mgr:GetBubbleDialogData(control_id)
        if dialog_data then
            table.insert(bubble_dialog_data_list, dialog_data)
        end
    end
    if #bubble_dialog_data_list < 1 then
        return self:Hide()
    end
    self:_UpdataBubbleData(bubble_dialog_data_list)
    return true
end

function RedPointBubble:Hide()
    if not RedPointBubble.super.Hide(self) then
        return false
    end
    if self.bubble_timer then
        SpecMgrs.timer_mgr:RemoveTimer(self.bubble_timer)
        self.bubble_timer = nil
    end
    self.go:SetActive(false)
    return true
end

function RedPointBubble:_UpdataBubbleData(bubble_dialog_data_list)
    if self.bubble_timer then
        SpecMgrs.timer_mgr:RemoveTimer(self.bubble_timer)
    end
    local func_before_loop = function()
        if IsNil(self.go) then
            SpecMgrs.timer_mgr:RemoveTimer(self.bubble_timer)
            self.bubble_timer = nil
            return
        end
        local index = 1
        self.go:SetActive(true)
        self:_UpdataBubbleContent(bubble_dialog_data_list[index])
        local func_begin_loop = function()
            index = index % #bubble_dialog_data_list + 1
            self:_UpdataBubbleContent(bubble_dialog_data_list[index])
        end
        self.bubble_timer = SpecMgrs.timer_mgr:AddTimer(func_begin_loop, 10, 0)
    end
    self.bubble_timer = SpecMgrs.timer_mgr:AddTimer(func_before_loop, math.random(1, 6), 1)
end

function RedPointBubble:_UpdataBubbleContent(bubble_dialog_data)
    if IsNil(self.go) then
        SpecMgrs.timer_mgr:RemoveTimer(self.bubble_timer)
        self.bubble_timer = nil
        return
    end
    if bubble_dialog_data.res_path and bubble_dialog_data.res_name then
        UIFuncs.AssignUISpriteSync(bubble_dialog_data.res_path, bubble_dialog_data.res_name, self.icon_image)
        self.icon_image:SetNativeSize()
    end
    local dialog_list = bubble_dialog_data.dialog_list
    local dialog_text = ""
    if dialog_list and #dialog_list > 0 then
        dialog_text = dialog_list[math.random(#dialog_list)]
    end
    self.ui_tween_alpha:Play()
    UIFuncs.AddTypeEffectText(self.ui, self.chat_text, dialog_text, 0.1)
end

return RedPointBubble