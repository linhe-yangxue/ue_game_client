local Actor = require("CommonBase.Actor")
local EventUtil = require("BaseUtilities.EventUtil")
local EffectConst = require("Effect.EffectConst")
local GConst = require("GlobalConst")

local Effect3D = class("Effect.Effect3D", Actor)

local kCheckActiveTime = 1

EventUtil.GeneratorEventFuncs(Effect3D, "EffectEndEvent")
EventUtil.GeneratorEventFuncs(Effect3D, "EffectDestroyEvent")

function Effect3D:DoInit()
    Effect3D.super.DoInit(self)
    self.effect_speed = 1
    self.is_end = false
    self.delay_kill_time = 0
    self.check_active_time = kCheckActiveTime
end

function Effect3D:BuildEffect(param_tb)
    local guid = param_tb.guid
    local effect_id = tostring(param_tb.effect_id)
    local res_path = param_tb.res_path
    local effect_type = param_tb.effect_type
    local target_go = param_tb.target_go

    local life_time = param_tb.life_time
    local attach_time = param_tb.attach_time

    local attach_name = param_tb.attach_name
    local scale = param_tb.scale or 1
    local pos_tb = param_tb.pos_tb
    local euler_tb = param_tb.euler_tb
    local pos = pos_tb and Vector3.NewByTable(pos_tb) or param_tb.pos
    local euler = euler_tb and Vector3.NewByTable(euler_tb) or param_tb.euler

    local speed = param_tb.speed or 1

    local effect_data = effect_id and SpecMgrs.data_mgr:GetEffectData(effect_id)
    if not res_path and not effect_data then
        PrintError("BuildEffect Error Can't Find EffectID", effect_id)
    end
    self.guid = guid
    self.effect_id = effect_id
    self.effect_type = effect_type
    self.target_go = target_go
    self.life_time = life_time or (effect_data and effect_data.time)
    self.res_path = res_path or effect_data.res_path

    self.attach_name = attach_name
    self.attach_time = attach_time
    self.re_pos = pos or Vector3.zero
    self.re_euler = euler or Vector3.zero

    self.is_direct_del = effect_data and effect_data.is_direct_del

    self:SetScale(scale)
    self:SetEuler(self.re_euler)
 
    self:SetLayerRecursive(GConst.DefaultLayer)
    self:SetEffectSpeed(speed)
    self.need_sync_load = param_tb.need_sync_load
    self:DoLoadGo(self.res_path)
end

function Effect3D:OnGoLoadedOk(res_go)
    res_go:ResetEffect()
    Effect3D.super.OnGoLoadedOk(self, res_go)
    self:SetEffectSpeed(self.effect_speed)
    self:_InitEffect()
end

function Effect3D:_InitEffect()
    if self:IsDestroy() then
        return
    end
    if self.target_go then
        self.go.localPosition = self.re_pos
        self.go:SetParent(self.target_go, true)
    else
        self:SetPosition(self.re_pos)
    end
end

function Effect3D:SetEffectSpeed(speed)
    self.effect_speed = speed or 1
    if self.go then
        self.go:SetEffectPlaySpeed(speed)
    end
end

function Effect3D:Update(delta_time)
    delta_time = self.effect_speed * delta_time
    Effect3D.super.Update(self, delta_time)
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

function Effect3D:EffectEnd()
    self.is_end = true
    self:DispatchEffectEndEvent()
    self:SetEffectSpeed(1)
    self.delay_kill_time = 0
    if not self.is_direct_del and self.go then
        self.delay_kill_time = self.go:BeginDelayKill()
    end
    if self.delay_kill_time > 10 then
        PrintWarn("Effect3D: Effect3D kill time", self.delay_kill_time, self.effect_id)
        self.delay_kill_time = 10
    end
    if self.delay_kill_time <= 0 then
        SpecMgrs.effect_mgr:DestroyEffect(self)
    end
end

function Effect3D:DoDestroy()
    if IsNil(self.go) then return end  -- 父物体销毁时
    if self.target then
        self.target:UnregisterGoLoadedOkEvent("Effect3D" .. self.guid)
    end
    if self.go then
        self.go:ClearDelayKill()
    end
    self:DispatchEffectDestroyEvent()
    Effect3D.super.DoDestroy(self)
end

return Effect3D
