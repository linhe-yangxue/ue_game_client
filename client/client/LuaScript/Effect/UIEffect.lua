local Actor = require("CommonBase.Actor")
local EventUtil = require("BaseUtilities.EventUtil")
local GConst = require("GlobalConst")
local UIEffect = class("Effect.UIEffect", Actor)

EventUtil.GeneratorEventFuncs(UIEffect, "EffectEndEvent")
EventUtil.GeneratorEventFuncs(UIEffect, "EffectDestroyEvent")

function UIEffect:DoInit()
    UIEffect.super.DoInit(self)
    self.is_end = false
end

function UIEffect:BuildEffect(param_tb)
    local attach_ui = param_tb.attach_ui
    if attach_ui == nil then
        attach_ui = SpecMgrs.ui_mgr:ShowUI("EffectUI")
    end
    self.attach_ui = attach_ui

    local guid = param_tb.guid
    local effect_id = tostring(param_tb.effect_id)
    local effect_type = param_tb.effect_type
    local life_time = param_tb.life_time
    local scale = param_tb.scale or 1
    local pos_tb = param_tb.pos_tb
    local pos = pos_tb and Vector3.NewByTable(pos_tb) or param_tb.pos
    local speed = param_tb.speed or 1
    local effect_data = effect_id and SpecMgrs.data_mgr:GetEffectData(effect_id)
    local euler = param_tb.euler
    if not effect_data then
        PrintError("BuildEffect Error Can't Find EffectID", effect_id)
    end

    self.guid = guid
    self.effect_id = effect_id
    self.effect_type = effect_type
    self.life_time = life_time or (effect_data and effect_data.time)
    self.res_path = effect_data.res_path
    self.re_pos = pos
    self.is_direct_del = effect_data and effect_data.is_direct_del
    self:SetScale(scale)
    self:SetEuler(euler or Vector3.zero)
    self:SetLayerRecursive(GConst.UILayer)
    self.effect_speed = speed
    self:SetEffectSpeed(speed)
    self.need_sync_load = param_tb.need_sync_load
    self.effect_data = effect_data

    self.attach_ui_go = param_tb.attach_ui_go
    self.anchors_tb = param_tb.anchors_tb
    self.offset_tb = param_tb.offset_tb
    self.pivot = param_tb.pivot
    self.re_rot = param_tb.rot
    self.local_scale = param_tb.local_scale
    self.size_delta = param_tb.size_delta
    self.keep_world_pos = param_tb.keep_world_pos
    self:DoLoadGo(self.res_path)
    if not self.is_res_ok then return end
    self:_UpdateEffectRectCompInfo()
end

function UIEffect:OnGoLoadedOk(res_go)
    res_go:ResetEffect()
    UIEffect.super.OnGoLoadedOk(self, res_go)
    self:SetEffectSpeed(self.effect_speed)
    self:_InitEffect()
end

function UIEffect:SetEffectSpeed(speed)
    if self.go then
        self.go:SetEffectPlaySpeed(speed)
    end
end

function UIEffect:_InitEffect()
    if self:IsDestroy() then
        return
    end
    self.go:SetSortOrder(self.attach_ui.sort_order + 1)
    self:_UpdateEffectRectCompInfo()
end

function UIEffect:_UpdateEffectRectCompInfo()
    local rect_comp = self.go:GetComponent("RectTransform")
    if not rect_comp then
        PrintError("UIEffect: not recttransform comp", self.effect_id)
        self:EffectEnd()
        return
    end
    if self.anchors_tb then
        rect_comp.anchorMin = Vector2.New(self.anchors_tb[1] or 0.5, self.anchors_tb[2] or 0.5)
        rect_comp.anchorMax = Vector2.New(self.anchors_tb[3] or 0.5, self.anchors_tb[4] or 0.5)
    end
    if self.offset_tb then
        rect_comp.offsetMin = Vector2.New(self.offset_tb[1] or 0, self.offset_tb[4] or 0)
        rect_comp.offsetMax = -Vector2.New(self.offset_tb[2] or 0, self.offset_tb[3] or 0)
    end
    if self.pivot then
        rect_comp.pivot = self.pivot
    end
    if self.re_pos then
        self:SetPosition(self.re_pos)
    end
    if self.re_rot then
        self.go.localRotation = self.re_rot
    end
    if self.local_scale then
        rect_comp.localScale = self.local_scale
    end
    self.go:SetParent(self.attach_ui.main_panel, false)  -- 先缩放位置

    if not IsNil(self.attach_ui_go) then
        self:SetNewAttachGo(self.attach_ui_go)
    elseif self.attach_ui.main_panel then
        self:SetNewAttachGo(self.attach_ui.main_panel)
    end
end

function UIEffect:SetNewAttachGo(ui_go)
    if self.keep_world_pos then
        local world_pos = Vector3.NewByVector3(self.go.position)
        self.go:SetParent(ui_go, false)
        self.go.position = world_pos
    else
        self.go:SetParent(ui_go, false)
    end
end

function UIEffect:Update(delta_time)
    UIEffect.super.Update(self, delta_time)
    if self.is_end then
        if self.delay_kill_time > 0 then
            self.delay_kill_time = self.delay_kill_time - delta_time
            if self.delay_kill_time <= 0 then
                SpecMgrs.effect_mgr:DestroyEffect(self)
            end
        end
    else
        if self.life_time and self.life_time > 0 then
            self.life_time = self.life_time - delta_time
            if self.life_time <= 0 then
                self:EffectEnd()
            end
        end
    end
end

function UIEffect:EffectEnd()
    self.is_end = true
    self:DispatchEffectEndEvent()
    if self.target then
        self.target:UnregisterGoLoadedOkEvent("Effect" .. self.guid)
    end
    self.delay_kill_time = 0
    if not self.is_direct_del and not IsNil(self.go) then
        self.delay_kill_time = self.go:BeginDelayKill()
    end
    if self.delay_kill_time > 10 then
        PrintWarn("Effect: effect kill time", self.delay_kill_time, self.effect_id)
        self.delay_kill_time = 10
    end
    if self.delay_kill_time <= 0 then
        SpecMgrs.effect_mgr:DestroyEffect(self)
    end
end

function UIEffect:DoDestroy()
    if IsNil(self.go) then return end  -- 父物体销毁时
    if self.target then
        self.target:UnregisterGoLoadedOkEvent("Effect" .. self.guid)
    end
    if self.go then
        self.go:ClearDelayKill()
    end
    self:DispatchEffectDestroyEvent()
    UIEffect.super.DoDestroy(self)
end

return UIEffect