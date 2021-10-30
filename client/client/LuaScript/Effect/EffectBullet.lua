local Effect3D = require("Effect.Effect3D")
local AnimationCurve = require("CommonTypes.AnimationCurve")
local EffectBullet = class("Effect.EffectBullet", Effect3D)

--  子弹特效
function EffectBullet:DoInit()
    EffectBullet.super.DoInit(self)
    self.cur_fly_time = nil
end

function EffectBullet:DoDestroy()
    EffectBullet.super.DoDestroy(self)
end

function EffectBullet:Update(delta_time)
    if self.is_end then
        return
    end
    self:_TickBulletPos(delta_time)
end

function EffectBullet:BuildEffect(param_tb)
    EffectBullet.super.BuildEffect(self, param_tb)
    self.t_pos = param_tb.t_pos
    self.fly_time = param_tb.fly_time -- 飞行时间或速度
    self.fly_speed = param_tb.fly_speed
    local t_pos = self.t_pos or self.attach_ui_go:GetPosition()
    self.cur_fly_time = 0
    self.speed_curve = param_tb.speed_curve
    self.move_curve = param_tb.move_curve
    self.scale_curve = param_tb.scale_curve
    self:SetPosition(self.re_pos)
    self.start_scale = param_tb.scale
    self.end_scale = param_tb.end_scale
    self.fly_dis = Vector3.Distance(self.re_pos, self.t_pos)
    if self.fly_speed and self.fly_speed ~= 0 then
        self.fly_time = self.fly_dis / self.fly_speed
    end
end

function EffectBullet:_InitEffect()
    EffectBullet.super._InitEffect(self)
    self.fly_dir = self.t_pos - self.re_pos
    self.fly_dir:SetNormalize()

    if self.t_pos.x < self.re_pos.x then
        self.vertical_vector = Vector3.New(self.fly_dir.y, -self.fly_dir.x, 0) * self.fly_dis -- 垂直于飞行方向
    else
        self.vertical_vector = Vector3.New(-self.fly_dir.y, self.fly_dir.x, 0) * self.fly_dis
    end
    local up_dir = Vector3.Cross(Vector3.forward, self.fly_dir) -- 子弹方向朝右
    self.go.rotation = (Quaternion.LookRotation(Vector3.forward, up_dir))
end

function EffectBullet:_TickBulletPos(delta_time)
    if self.fly_time and self.vertical_vector then
        self.cur_fly_time = self.cur_fly_time + delta_time
        if self.cur_fly_time > self.fly_time then
            self:SetPosition(self.t_pos)
            self:EffectEnd()
        else
            local lerp = math.min(1, self.cur_fly_time / self.fly_time)
            local scale = Vector3.Lerp(self.start_scale, self.end_scale, AnimationCurve.EvaluateCurve(self.scale_curve, lerp))
            lerp = AnimationCurve.EvaluateCurve(self.speed_curve, lerp)
            local new_pos = Vector3.Lerp(self.re_pos, self.t_pos, lerp) + self.vertical_vector * AnimationCurve.EvaluateCurve(self.move_curve, lerp)
            self:SetScale(scale, "Spell")
            self:SetPosition(new_pos)
        end
    end
end

return EffectBullet