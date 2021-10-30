local EffectMgr = class("Mgrs.Special.EffectMgr")
local EffectConst = require "Effect.EffectConst"

function EffectMgr:DoInit()
    self._effect_guid_tb = {}
    self._effect_delay_del_tb = {}
end

function EffectMgr:CreateEffect(param_tb)
    local guid = param_tb.guid

    self._effect_delay_del_tb[guid] = nil
    if self._effect_guid_tb[guid] then
        self._effect_guid_tb[guid]:DoDestroy()
    end

    local effect_type = EffectConst.Type2Class[param_tb.effect_type] or "Effect"
    local effect = require("Effect." .. effect_type).New()
    self._effect_guid_tb[guid] = effect
    effect:DoInit()
    effect:BuildEffect(param_tb)
    return effect
end

function EffectMgr:CreateEffectAutoGuid(param_tb)
    param_tb.guid = ComMgrs.dy_data_mgr:NewGuid()
    return self:CreateEffect(param_tb), param_tb.guid
end

function EffectMgr:DestroyEffect(effect)
    if not self._effect_delay_del_tb[effect.guid] then
        effect:DoDestroy()
    end
    self._effect_delay_del_tb[effect.guid] = true
end

function EffectMgr:DestroyEffectByGuid(guid)
    local effect = self._effect_guid_tb[guid]
    self:DestroyEffect(effect)
end

function EffectMgr:EndEffectByGuid(guid)
    local effect = self._effect_guid_tb[guid]
    if effect then
        effect:EffectEnd()
    end
end

function EffectMgr:Update(delta_time)
    for guid, _ in pairs(self._effect_delay_del_tb) do
        self._effect_guid_tb[guid] = nil
    end
    self._effect_delay_del_tb = {}
    for guid, effect in pairs(self._effect_guid_tb) do
        if not self._effect_delay_del_tb[guid] then
            effect:Update(delta_time)
        end
    end
    if self.__UpdateEventCbRemove then
        self:__UpdateEventCbRemove()
    end
end

function EffectMgr:ClearAll()
    for _, effect in pairs(self._effect_guid_tb) do
        self:DestroyEffect(effect)
    end
    self._effect_guid_tb = {}
    self._effect_delay_del_tb = {}
end

function EffectMgr:DoDestroy()
    self:ClearAll()
    if self.__ClearAllEventCb then
        self:__ClearAllEventCb()
    end
end

return EffectMgr
