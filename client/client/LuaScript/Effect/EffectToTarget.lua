local EffectConst = require("Effect.EffectConst")
local UIEffect = require("Effect.UIEffect")
local EffectToTarget = class("Effect.EffectToTarget", UIEffect)

--  有目标位置的effect
function EffectToTarget:BuildEffect(param_tb) 
    EffectToTarget.super.BuildEffect(self, param_tb)
    
    local end_pos_tb = param_tb.end_pos_tb
    self.end_pos = end_pos_tb and Vector3.NewByTable(end_pos_tb) or param_tb.end_pos
end

function EffectToTarget:_InitEffect()
    EffectToTarget.super._InitEffect(self)
    self:SetCSTarget()
end

function EffectToTarget:SetCSTarget()  -- 设置目标
    local class_name = "UIAnimReciveRes"
    local comp = self.go:GetComponent(class_name)
    if comp then
        comp:Init(self.end_pos)
    end
end
    
return EffectToTarget