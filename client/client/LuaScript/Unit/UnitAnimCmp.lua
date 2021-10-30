local UnitConst = require("Unit.UnitConst")
local AnimCmp = class("Unit.UnitAnimCmp")

local normal_color = Color.white

function AnimCmp:DoInit(unit_owner)
    self.owner = unit_owner
    self:_ResetValue()
    self.anim_time = 0
    self.time_scale = 1
    self.gray_material = SpecMgrs.res_mgr:GetMaterialSync(UnitConst.MaterialGrayPath)
    self.default_material = SpecMgrs.res_mgr:GetMaterialSync(UnitConst.MaterialDefaultPath)
end

function AnimCmp:_ResetValue()
    self:RemoveInitTimeScaleTimer()
    self.anim_go = nil
    self.anim_state = nil
    self.graphic = nil
    self.anim_time = 0
end

function AnimCmp:InitByGo(go)
    self.anim_go = go
    if self.owner.is_3D_model then
        self.skeleton_animation = go:GetComponent("SkeletonAnimation")
        self.anim_state = self.skeleton_animation.AnimationState
        self.renderer = self.skeleton_animation:GetComponent("Renderer")
    else
        self.graphic = go:GetComponent("Graphic")
        self.skeleton_graphic = go:GetComponent("SkeletonGraphic")
        self.anim_state = self.skeleton_graphic.AnimationState
    end
    self:SetColor(normal_color)
end

-- 将轨道当前动画及队列后的所有动画替换成该动画
-- track_index 轨道索引 等同于Mecanim的层级
-- mix_duration 当前动画切换到该动画的混合时间
function AnimCmp:PlayAnim(anim_name, loop, mix_duration, track_index, time_scale)
    if not anim_name then return end
    self:RemoveInitTimeScaleTimer()
    self.anim_time = self.anim_state:PlayAnimation(track_index or 0, anim_name, loop == true or false, mix_duration or 0)
    self:SetTimeScale(time_scale or 1)
    if self.time_scale == 1 or self.time_scale == 0 or loop == true then return self.anim_time end
    self.anim_time = self.anim_time / (time_scale or 1)
    self.init_time_scale_timer = SpecMgrs.timer_mgr:AddTimer(function ()
        self:SetTimeScale(1)
        self.init_time_scale_timer = nil
    end, self.anim_time)
    return self.anim_time
end

function AnimCmp:AddAnim(anim_name, loop, mix_duration, track_index, delay)
    if not anim_name then return end
    local time = self.anim_state:AddAnim(track_index or 0, anim_name, loop == true or false, delay or 0, mix_duration or 0)
    self.anim_time = time + (loop == true and 0 or self.anim_time)
    return self.anim_time
end

-- 清空该轨道的所有动画，并过渡到setup pose
function AnimCmp:StopAllAnimation(mix_duration)
    mix_duration = mix_duration or 0
    self.default_anim = nil
    self.anim_state:SetEmptyAnimations(mix_duration)
end

-- 暂停当前动画，并停留在当前pose
function AnimCmp:StopAllAnimationToCurPos()
    self:SetTimeScale(0)
end

-- 暂停到当前pos
function AnimCmp:SetTimeScale(time_scale)
    if self.time_scale == time_scale then return end
    self.anim_state.TimeScale = time_scale
    self.time_scale = time_scale
end

function AnimCmp:SetUnitFlip(is_flip_x, is_flip_y)
    if self.owner.is_3D_model then
        self.skeleton_animation:SetSkeletonFlip(is_flip_x == true, is_flip_y == true)
    else
        if self.skeleton_graphic.skeletonDataAsset == nil then
            PrintError(self.owner.unit_id .. "模型错误")
        end
        self.skeleton_graphic:SetSkeletonFlip(is_flip_x == true, is_flip_y == true)
    end
end

function AnimCmp:GetAnimationDuration(anim_name)
    return self.anim_state:GetAnimDuration(anim_name)
end

function AnimCmp:SetDefaultAnim(anim_name)
    self.default_anim = anim_name
end

function AnimCmp:GetMaterialModifyer()
    if not self.material_modifyer then
        self.material_modifyer = UnityEngine.MaterialPropertyBlock()
    end
    return self.material_modifyer
end

function AnimCmp:SetColor(color, is_add)
    if self.owner.is_3D_model then
        local material_modifyer = self:GetMaterialModifyer()
        material_modifyer:SetColor(is_add and "_Black" or "_Color", color)
        self.renderer:SetPropertyBlock(material_modifyer)
    else
        self.graphic.color = color
    end
end

function AnimCmp:CrossFadeColor(color, duration, ignore_scale, use_alpha)
    if self.graphic then self.graphic:CrossFadeColor(color, duration, ignore_scale, use_alpha) end
end

function AnimCmp:CrossFadeAlpha(alpha, duration, ignore_scale)
    if self.graphic then self.graphic:CrossFadeAlpha(alpha, duration, ignore_scale) end
end

-- function AnimCmp:GetColor(is_add)
--     if self.owner.is_3D_model then
--         local material_modifyer = self:GetMaterialModifyer()
--         return is_add and material_modifyer:GetColor("_Black") or material_modifyer:GetColor("_Color")
--     else
--         return self.graphic.color
--     end
-- end

function AnimCmp:Update(delta_time)
    if self.time_scale == 0 then return end
    if self.anim_time == -1 then return end
    if self.anim_time > 0 then self.anim_time = self.anim_time - delta_time end
    if self.anim_time <= 0 and self.default_anim then
        self:AddAnim(self.default_anim, true, 0.1, 0)
    end
end

function AnimCmp:CreateGhost(ghost_disappear_time, start_color, disappear_color)
    return SkeletonGraphicGhost.CreateSkeletonGraphicGhost(
        self.owner.go,
        self.anim_go,
        ghost_disappear_time,
        start_color,
        disappear_color,
        self.owner.go.localScale.x
    )
end

function AnimCmp:GetAnimName()
    return self.skeleton_animation.AnimationName
end

function AnimCmp:RemoveInitTimeScaleTimer()
    if self.init_time_scale_timer then
        SpecMgrs.timer_mgr:RemoveTimer(self.init_time_scale_timer)
        self:SetTimeScale(1)
        self.init_time_scale_timer = nil
    end
end

function AnimCmp:ChangeToGray()
    self.skeleton_graphic.material = self.gray_material
end

function AnimCmp:ChangeToNormalMaterial()
    self.skeleton_graphic.material = self.default_material
end

function AnimCmp:DestroyRes()
    self:_ResetValue()
end

function AnimCmp:DoDestroy()
    self:DestroyRes()
end

return AnimCmp