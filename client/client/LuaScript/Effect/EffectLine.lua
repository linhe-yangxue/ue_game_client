local Effect3D = require("Effect.Effect3D")
local EffectLine = class("Effect.EffectLine", Effect3D)

-- 连线特效
function EffectLine:BuildEffect(param_tb)
    EffectLine.super.BuildEffect(self, param_tb)
    self.to_go = param_tb.line_target_go
    self.to_pos = param_tb.line_pos or Vector3.zero
end

function EffectLine:OnGoLoadedOk(res_go)
    EffectLine.super.OnGoLoadedOk(self, res_go)
    self.effect_line_comp = res_go:GetComponent("EffectLine")
    if not self.effect_line_comp then
        res_go:AddComponent("EffectLine")
        self.effect_line_comp = res_go:GetComponent("EffectLine")
    end
    self.from_go = self.target_go
    self.from_pos = self.re_pos or Vector3.zero

    if self.from_go then
        self.from_go_start_pos = self.from_go.position
    end
    if self.to_go then
        self.to_go_start_pos = self.to_go.position
    end
    self.effect_line_comp:SetPosition(self.from_pos, self.to_pos)
end

function EffectLine:_InitEffect()

end

function EffectLine:Update(delta_time)
    EffectLine.super.Update(self, delta_time)
    if self.effect_line_comp then
        local from_offset = self.from_go and (self.from_go.position - self.from_go_start_pos) or Vector3.zero
        local to_offset = self.to_go and (self.to_go.position - self.to_go_start_pos) or Vector3.zero
        local from_pos = self.from_pos + from_offset
        local to_pos = self.to_pos + to_offset
        self.effect_line_comp:SetPosition(from_pos, to_pos)
    end
end

function EffectLine:DoDestroy()
    EffectLine.super.DoDestroy(self)
end

return EffectLine