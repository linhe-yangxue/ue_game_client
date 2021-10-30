local FConst = require("CSCommon.Fight.FConst")
local UnitConst = require("Unit.UnitConst")
local AnimationCurve = require("CommonTypes.AnimationCurve")
local SpellActionFunc = class("HeroFight.SpellActionFunc")

local SPELL_ENTER_FUNCS = {
    ["PlayAnim"] = "EnterPlayAnim",
    ["SetAnimSpeed"] = "EnterSetAnimSpeed",
    ["SetAnimSpeedCurve"] = "EnterSetAnimSpeedCurve",
    ["PlayEffect"] = "EnterPlayEffect",
    ["PlayLineEffect"] = "EnterPlayLineEffect",
    ["LauchBullet"] = "EnterLauchBullet",
    ["CaculateDeath"] = "EnterCaculateDeath",
    ["SpellEnd"] = "EnterEnd",
    ["ShowSpellName"] = "EnterShowSpellName",
    ["ShowGhost"] = "EnterShowGhost",
    ["SetHitHappenTime"] = "EnterSetHitHappenTime",
    ["ShakeScreen"] = "EnterShakeScreen",

    ["UnitMove"] = "EnterUnitMove",
    ["EffectMove"] = "EnterEffectMove",
    ["UnitColorAnim"] = "EnterUnitColorAnim",
    ["GameBackgroundColorAnim"] = "EnterGameBackgroundColorAnim",
    ["UnitScaleAnim"] = "EnterUnitScaleAnim",
    ["EffectScaleAnim"] = "EnterEffectScaleAnim",
    ["UnitRotateAnim"] = "EnterUnitRotateAnim",
    ["UnitCircleMove"] = "EnterUnitCircleMove",
    ["EffectCircleMove"] = "EnterEffectCircleMove",

    ["ShowOrHideShadow"] = "EnterShowOrHideShadow",
    ["ShowOrHideHud"] = "EnterShowOrHideHud",

    ["MaskColorAnim"] = "EnterMaskColorAnim",

    ["EffectRotateAnim"] = "EnterEffectRotateAnim",
    ["CreateGhost"] = "EnterCreateGhost",
    ["ShowBuff"] = "EnterShowBuff",
    ["TriggerAction"] = "EnterTriggerAction",
    ["ShowTogherAttackEffect"] = "EnterShowTogherAttackEffect",
    ["PlaySound"] = "EnterPlaySound",
    ["SetUnitLayer"] = "EnterSetUnitLayer",
}

local ANIM_UPDATE_FUNCS = {
    ["UnitMove"] = "UpdateMove",
    ["EffectMove"] = "UpdateMove",

    ["UnitColorAnim"] = "UpdateColor",
    ["GameBackgroundColorAnim"] = "UpdateColor",
    ["MaskColorAnim"] = "UpdateColor",

    ["UnitScaleAnim"] = "UpdateScale",
    ["EffectScaleAnim"] = "UpdateScale",

    ["UnitRotateAnim"] = "UpdateRotate",
    ["EffectRotateAnim"] = "UpdateRotate",

    ["UnitCircleMove"] = "UpdateCircleAnim",
    ["EffectCircleMove"] = "UpdateCircleAnim",

    ["SetAnimSpeedCurve"] = "UpdateSetAnimSpeedCurve",
}

SpellActionFunc.shadow_follow_type =
{
    normal_follow = "NormalFollow",
    beeline_follow = "BeelineFollow",
    not_follow_y = "NotFollowY",
    not_move = "NotMove",
}

SpellActionFunc.order_type =
{
    sort_by_pos = "SortByPos",
    min_level = "MinLevel",
    max_level = "MaxLevel",
}

SpellActionFunc.change_color_type =
{
    sprite_renderer = 1,
    ui_image = 2,
    unit = 3,
}

local together_attack_effect_id = "1200000010"
local super_together_attack_effect_id = "1200000001"

function SpellActionFunc:DoInit(spell)
    self.spell_update_list = {}
    self.create_effect_list = {}
    self.spell = spell
    self.one_frame_length = self.spell.one_frame_length
    self.camera = GameObject.Find("Main Camera")

    self.battle_bg = SpecMgrs.ui_mgr:GetUI("HeroBattleUI").battle_bg
    self.battle_mask = SpecMgrs.ui_mgr:GetUI("HeroBattleUI").go:FindChild("Mask"):GetComponent("Image")
    self.battle_bottom_point = SpecMgrs.ui_mgr:GetUI("HeroBattleUI").go:FindChild("Panel/EffectPoint")

    local rect = SpecMgrs.ui_mgr:GetUI("HeroBattleUI").main_panel:GetComponent("RectTransform").rect
    self.edge_left = -rect.width / 50
    self.edge_right = rect.width / 50
end

function SpellActionFunc:RunEnterFunc(spell_action_type, spell_action)
    local func_name = SPELL_ENTER_FUNCS[spell_action_type]
    local func = self[func_name]
    if not func then
        PrintError(spell_action_type .. "无对应方法")
    end
    func(self, spell_action)
end

function SpellActionFunc:RunAnimUpdateFunc(spell_action_type, anim_data, lerp)
    local func_name = ANIM_UPDATE_FUNCS[spell_action_type]
    local func = self[func_name]
    if not func then
        PrintError(spell_action_type .. "无对应方法")
    end
    func(self, anim_data, lerp)
end

----------------------------Move
function SpellActionFunc:EnterEffectMove(param_tb)
    local pos_data = self.spell:GetPosByCondition(param_tb.pos_data, param_tb)
    local effect_list = self.spell:GetEffectByID(param_tb.effect_index)
    local to_pos_list = self.spell:GetPosByPosType(param_tb.cast_unit, pos_data, param_tb)
    if #to_pos_list == 0 then return end
    local to_pos = to_pos_list[1]
    for i, effect in ipairs(effect_list) do
        self:AddToMoveActionList(param_tb, effect, effect:GetPosition(), to_pos, param_tb.change_time, param_tb.move_curve, param_tb.speed_curve)
    end
end

function SpellActionFunc:EnterUnitMove(param_tb)
    local pos_data = self.spell:GetPosByCondition(param_tb.pos_data, param_tb)
    local index = 1
    self.spell:HandleUnitByTargetType(param_tb, function(move_obj)
        local to_pos_list = self.spell:GetPosByPosType(move_obj, pos_data, param_tb)
        local to_pos = to_pos_list[index]
        if #to_pos_list > index then
            index = index + 1
        end
        self:AddToMoveActionList(param_tb, move_obj, move_obj:GetPosition(), to_pos, param_tb.change_time, param_tb.move_curve, param_tb.speed_curve, true, param_tb.shadow_fllow_type)
    end)
end

function SpellActionFunc:UpdateMove(anim_data, lerp)
    if anim_data.target_obj.is_destroy then return end  -- 敌方死亡销毁
    lerp = AnimationCurve.EvaluateCurve(anim_data.speed_curve, math.clamp(lerp, 0, 1))
    local target_pos = Vector3.Lerp(anim_data.start_pos, anim_data.end_pos, lerp) + anim_data.vertical_vector * AnimationCurve.EvaluateCurve(anim_data.move_curve, lerp)

    if anim_data.is_limit_edge then
        target_pos.x = math.clamp(target_pos.x, self.edge_left + (anim_data.limit_edge_offset_left or 0), self.edge_right + (anim_data.limit_edge_offset_right or 0))
    end
    local pos_z = anim_data.target_obj:GetPosition().z
    target_pos.z = pos_z
    anim_data.target_obj:SetPosition(target_pos)
    --  影子与人物分开，可作为跳跃效果
    if anim_data.is_unit and not anim_data.shadow_follow then
        if anim_data.shadow_fllow_type == SpellActionFunc.shadow_follow_type.beeline_follow then
            local shadow_pos = -anim_data.vertical_vector * AnimationCurve.EvaluateCurve(anim_data.move_curve, lerp)
            shadow_pos = shadow_pos / anim_data.target_obj.go.localScale.x
            anim_data.target_obj:GetShadowGo().localPosition = Vector3.New(shadow_pos.x, shadow_pos.y, 0)
        elseif anim_data.shadow_fllow_type == SpellActionFunc.shadow_follow_type.not_follow_y then
            local pos = anim_data.target_obj:GetShadowGo().position
            pos.y = anim_data.shadow_start_pos.y
            anim_data.target_obj:GetShadowGo().position = pos
        elseif anim_data.shadow_fllow_type == SpellActionFunc.shadow_follow_type.not_move then
            anim_data.target_obj:GetShadowGo().position = anim_data.shadow_start_pos
        end
    end
end

function SpellActionFunc:AddToMoveActionList(action, obj, start_pos, end_pos, move_time, move_curve, speed_curve, is_unit, shadow_fllow_type)
    if action.relative_dis and action.relative_dis ~= 0 then
        local dir = start_pos - end_pos
        end_pos = end_pos + dir:Normalize() * action.relative_dis
    end
    if action.move_speed and action.move_speed ~= 0 then
        local pos1 = Vector3.New(end_pos.x, end_pos.y, 0)
        local pos2 = Vector3.New(start_pos.x, start_pos.y, 0)
        move_time = Vector3.Distance(pos1, pos2) / action.move_speed
    end
    local move_dir = end_pos - start_pos
    local vertical_vector
    local shadow_start_pos
    if end_pos.x < start_pos.x then
        vertical_vector = Vector3.New(move_dir.y, -move_dir.x, 0) -- 垂直于位移方向
    else
        vertical_vector = Vector3.New(-move_dir.y, move_dir.x, 0)
    end

    local is_unit = is_unit or false
    if is_unit and not obj.is_destroy then
        shadow_start_pos = obj:GetShadowGo().position
    end
    local param_tb = {
        start_pos = start_pos,
        end_pos = end_pos,
        change_frame = move_time,
        target_obj = obj,
        start_time = action.happen_frame * self.one_frame_length,
        move_curve = move_curve,
        speed_curve = speed_curve,
        vertical_vector = vertical_vector,
        spell_action_type = action.spell_action_type,
        is_unit = is_unit,
        shadow_fllow_type = shadow_fllow_type,
        shadow_start_pos = shadow_start_pos,
        is_limit_edge = action.is_limit_edge,
        replace_action = action.replace_action,
        limit_edge_offset_left = action.limit_edge_offset_left,
        limit_edge_offset_right = action.limit_edge_offset_right,
    }
    self.spell:AddToUpdateList(param_tb)
end
----------------------------Move

----------------------------Scale
function SpellActionFunc:EnterUnitScaleAnim(param_tb)
    self.spell:HandleUnitByTargetType(param_tb, function(obj)
        local scale = param_tb.end_scale * (Vector3.NewByTable(param_tb.end_vector_scale) or 1)
        self:AddToScaleActionList(param_tb, obj, scale , param_tb.change_time, param_tb.change_curve)
    end)
end

function SpellActionFunc:EnterEffectScaleAnim(param_tb)
    local effect_list = self.spell:GetEffectByID(param_tb.effect_index)
    local vector_scale
    if self.spell.battle_mgr:IsOwnUnit(param_tb.cast_unit) then
        vector_scale = param_tb.end_vector_scale
    else
        vector_scale = param_tb.enemy_end_vector_scale
    end
    local scale = param_tb.end_scale * (Vector3.NewByTable(vector_scale) or 1)
    for i, effect in ipairs(effect_list) do
        self:AddToScaleActionList(param_tb, effect, scale , param_tb.change_time, param_tb.change_curve)
    end
end

function SpellActionFunc:UpdateScale(anim_data, lerp)
    if anim_data.target_obj.is_destroy then return end
    lerp = AnimationCurve.EvaluateCurve(anim_data.change_curve, math.clamp(lerp, 0, 1))
    local scale = Vector3.Lerp(anim_data.start_scale, anim_data.end_scale, lerp)
    anim_data.target_obj:SetScale(scale, "Spell")
end

function SpellActionFunc:AddToScaleActionList(action, obj, end_scale, change_time, change_curve)
    local start_scale = obj:GetScaleByTag("Spell")
    local param_tb = {
        start_scale = start_scale,
        end_scale = end_scale,
        change_frame = change_time,
        change_curve = change_curve,
        start_time = action.happen_frame * self.one_frame_length,
        spell_action_type = action.spell_action_type,
        target_obj = obj,
        replace_action = action.replace_action,
    }
    self.spell:AddToUpdateList(param_tb)
end

----------------------------Scale

----------------------------Rotate
function SpellActionFunc:EnterUnitRotateAnim(param_tb)
    self.spell:HandleUnitByTargetType(param_tb, function(unit)
        local end_euler = param_tb.end_euler
        if not self.spell.battle_mgr:IsOwnUnit(unit) then
            end_euler = param_tb.enemy_end_euler
        end
        self:AddToRotateActionList(param_tb, unit, end_euler, param_tb.change_time, param_tb.change_curve)
    end)
end

function SpellActionFunc:EnterEffectRotateAnim(param_tb)
    local end_euler = param_tb.end_euler
    if not self.spell.battle_mgr:IsOwnUnit(param_tb.cast_unit) then
        end_euler = param_tb.enemy_end_euler
    end

    local effect_list = self.spell:GetEffectByID(param_tb.effect_index)
    for i, effect in ipairs(effect_list) do
        self:AddToRotateActionList(param_tb, effect, end_euler, param_tb.change_time, param_tb.change_curve)
    end
end

function SpellActionFunc:UpdateRotate(anim_data, lerp)
    if anim_data.target_obj.is_destroy then return end
    lerp = AnimationCurve.EvaluateCurve(anim_data.change_curve, math.clamp(lerp, 0, 1))
    local euler = Vector3.Lerp(anim_data.start_euler, anim_data.end_euler, lerp)
    if anim_data.rotate_model then
        anim_data.target_obj:RotateModelGo(euler)
    else
        anim_data.target_obj:SetEuler(euler)
    end
end

function SpellActionFunc:AddToRotateActionList(action, obj, end_euler, change_time, change_curve)
    local start_euler = obj:GetEuler()
    end_euler = Vector3.NewByTable(end_euler)
    local param_tb = {
        start_euler = start_euler,
        end_euler = end_euler,
        change_frame = change_time,
        change_curve = change_curve,
        start_time = action.happen_frame * self.one_frame_length,
        spell_action_type = action.spell_action_type,
        target_obj = obj,
        replace_action = action.replace_action,
        rotate_model = action.rotate_model,
    }
    self.spell:AddToUpdateList(param_tb)
end

----------------------------Rotate

----------------------------Color
function SpellActionFunc:EnterUnitColorAnim(param_tb)
    self.spell:HandleUnitByTargetType(param_tb, function(unit)
        local start_color = unit:GetColor(param_tb.is_add)
        self:AddToChangeColorActionList(param_tb, unit, start_color, param_tb.end_color, param_tb.change_time, param_tb.change_curve, param_tb.is_change_hud, 3)
    end)
end

function SpellActionFunc:EnterMaskColorAnim(param_tb)
    self:AddToChangeColorActionList(param_tb, self.battle_mask, self.battle_mask.color, param_tb.end_color, param_tb.change_time, param_tb.change_curve, param_tb.is_change_hud, 2)
end

function SpellActionFunc:EnterGameBackgroundColorAnim(param_tb)
    local sprite_renderer = self.battle_bg:GetComponent("SpriteRenderer")
    local start_color = sprite_renderer.color
    self:AddToChangeColorActionList(param_tb, sprite_renderer, start_color, param_tb.end_color, param_tb.change_time, param_tb.change_curve, param_tb.is_change_hud, 1)
end

function SpellActionFunc:UpdateColor(anim_data, lerp)
    lerp = AnimationCurve.EvaluateCurve(anim_data.change_curve, math.clamp(lerp, 0, 1))
    local color = Color.Lerp(anim_data.start_color, anim_data.end_color, lerp)
    if anim_data.obj_type == SpellActionFunc.change_color_type.ui_image then
        anim_data.target_obj.color = color
    elseif anim_data.obj_type == SpellActionFunc.change_color_type.sprite_renderer then
        anim_data.target_obj.color = color
    else
        if anim_data.target_obj.is_destroy then return end

        anim_data.target_obj:SetColor(color, anim_data.is_add)
        if anim_data.is_change_hud then
            anim_data.target_obj:SetInfoCmpColor(color)
        end
    end
end

function SpellActionFunc:AddToChangeColorActionList(action, obj, start_color, end_color, change_time, change_curve, is_change_hud, obj_type)
    end_color = Color.NewByTable(end_color)
    local param_tb = {
        start_color = start_color,
        end_color = end_color,
        change_frame = change_time,
        change_curve = change_curve,
        start_time = action.happen_frame * self.one_frame_length,
        spell_action_type = action.spell_action_type,
        target_obj = obj,
        is_change_hud = is_change_hud,
        obj_type = obj_type,
        replace_action = action.replace_action,
        is_add = action.is_add,
    }
    self.spell:AddToUpdateList(param_tb)
end
----------------------------Color


----------------------------Circle  圆形运动
function SpellActionFunc:EnterUnitCircleMove(param_tb)
    local pos_data = self.spell:GetPosByCondition(param_tb.pos_data, param_tb)
    local index = 1
    self.spell:HandleUnitByTargetType(param_tb, function(unit)
        local to_pos_list = self.spell:GetPosByPosType(unit, pos_data, param_tb)
        local to_pos = to_pos_list[index]
        if #to_pos_list > index then
            index = index + 1
        end
        self:AddToCircleMoveActionList(param_tb, unit, to_pos)
    end)
end

function SpellActionFunc:EnterEffectCircleMove(param_tb)
    local pos_data = self.spell:GetPosByCondition(param_tb.pos_data, param_tb)
    local effect_list = self.spell:GetEffectByID(param_tb.effect_index)
    local to_pos_list = self.spell:GetPosByPosType(param_tb.cast_unit, pos_data, param_tb)
    if #to_pos_list == 0 then return end
    local to_pos = to_pos_list[1]
    for i, effect in ipairs(effect_list) do
        self:AddToCircleMoveActionList(param_tb, effect, to_pos)
    end
end

function SpellActionFunc:AddToCircleMoveActionList(action, obj, circle_point)
    local cur_angle = self:GetCircleAngle(circle_point, obj:GetPosition())
    local param_tb = {
        change_frame = action.move_time,
        start_time = action.happen_frame * self.one_frame_length,
        spell_action_type = action.spell_action_type,
        target_obj = obj,
        replace_action = action.replace_action,
        angle_speed = action.angle_speed,
        is_right = action.is_right,
        circle_point = circle_point,
        radius = action.radius,
        start_angle = cur_angle,
    }
    self.spell:AddToUpdateList(param_tb)
end

function SpellActionFunc:UpdateCircleAnim(anim_data)
    if anim_data.target_obj.is_destroy then return end
    if anim_data.is_right then
        anim_data.start_angle = anim_data.start_angle + anim_data.angle_speed
    else
        anim_data.start_angle = anim_data.start_angle - anim_data.angle_speed
    end
    if anim_data.start_angle > 360 then anim_data.start_angle = 0 end
    if anim_data.start_angle < 0 then anim_data.start_angle = 360 end
    local pos = self:GetCirclePoint(anim_data.circle_point, anim_data.radius, anim_data.start_angle)
    pos.z = anim_data.target_obj:GetPosition().z
    anim_data.target_obj:SetPosition(pos)
end

function SpellActionFunc:GetCircleAngle(circle_point, point)
    if point.x == circle_point.x then
        if point.y > circle_point.y then
            return 90
        else
            return 270
        end
    end
    local radian = math.atan(math.abs(point.y - circle_point.y) / math.abs(point.x - circle_point.x))
    if point.x > circle_point.x and point.y >= circle_point.y then
        return math.deg(radian)
    end
    if point.x < circle_point.x and point.y >= circle_point.y then
        return 180 - math.deg(radian)
    end
    if point.x < circle_point.x and point.y <= circle_point.y then
        return math.deg(radian) + 180
    end
    if point.x > circle_point.x and point.y <= circle_point.y then
        return 360 - math.deg(radian)
    end
end

function SpellActionFunc:GetCirclePoint(circle_point, radius, angle)
    local x = circle_point.x + radius * math.cos(math.rad(angle))
    local y = circle_point.y + radius * math.sin(math.rad(angle))
    return Vector3.New(x, y, 0)
end
----------------------------Circle

----------------------------AnimSpeed

function SpellActionFunc:EnterSetAnimSpeedCurve(param_tb)
    self.spell:HandleUnitByTargetType(param_tb, function(target_unit)
        local anim_name = param_tb.anim_name == "" and param_tb.anim_data.anim_name or param_tb.anim_name
        local anim_data = {
            change_frame = param_tb.last_time,
            speed_curve = param_tb.speed_curve,
            start_time = param_tb.happen_frame * self.one_frame_length,
            spell_action_type = param_tb.spell_action_type,
            target_obj = target_unit,
            anim_name = anim_name,
            according_anim_name = param_tb.according_anim_name
        }
        self.spell:AddToUpdateList(anim_data)
    end)
end

function SpellActionFunc:UpdateSetAnimSpeedCurve(anim_data, lerp)
    if anim_data.target_obj.is_destroy then return end
    local speed = AnimationCurve.EvaluateCurve(anim_data.speed_curve, math.clamp(lerp, 0, 1))
    if anim_data.according_anim_name and anim_data.anim_name ~= anim_data.target_obj:GetAnimName() then
        return
    end
    anim_data.target_obj:SetTimeScale(speed)
end

----------------------------AnimSpeed

function SpellActionFunc:EnterSetAnimSpeed(param_tb)
    self.spell:HandleUnitByTargetType(param_tb, function(target_unit)
        target_unit:SetTimeScale(param_tb.anim_speed)
    end)
end

function SpellActionFunc:EnterPlayAnim(param_tb)
    self.spell:HandleUnitByTargetType(param_tb, function(target_unit)
        local anim_name = param_tb.anim_name == "" and param_tb.anim_data.anim_name or param_tb.anim_name
        target_unit:PlayAnim(anim_name, false, nil, nil, param_tb.anim_data.anim_speed)
    end)
end

function SpellActionFunc:EnterPlayEffect(param_tb)
    local euler
    local vector_scale
    if self.spell.battle_mgr:IsOwnUnit(param_tb.cast_unit) then
        euler = param_tb.start_euler
        vector_scale = param_tb.vector_scale
    else
        euler = param_tb.enemy_start_euler
        vector_scale = param_tb.enemy_vector_scale
    end
    local parm = {
        effect_id = param_tb.effect_id,
        offset = Vector3.zero,
        life_time = param_tb.life_time * self.spell.one_frame_length,
        scale = param_tb.effect_scale * (Vector3.NewByTable(vector_scale) or 1),
        euler = Vector3.NewByTable(euler),
    }

    if param_tb.level_type == SpellActionFunc.order_type.min_level then
        parm.pos_z = self.spell.min_order + (param_tb.level_offset or 0)
    elseif param_tb.level_type == SpellActionFunc.order_type.max_level then
        parm.pos_z = self.spell.max_order + (param_tb.level_offset or 0)
    end

    local pos_data = self.spell:GetPosByCondition(param_tb.pos_data, param_tb)
    local target_unit_list = self.spell:GetTargetByTargetType(param_tb.target_type, param_tb)
    local pos = self.spell:GetPosByPosType(param_tb.cast_unit, pos_data, param_tb)
    if #pos == 0 then return end
    local target_unit
    if #pos > 1 then
        for i, _pos in ipairs(pos) do
            parm.pos = _pos
            if next(target_unit_list) then target_unit = target_unit_list[i] end
            self:PlayEffect(param_tb, parm, target_unit)
        end
    else
        parm.pos = pos[1]
        if next(target_unit_list) then target_unit = target_unit_list[1] end
        self:PlayEffect(param_tb, parm, target_unit)
    end
end

function SpellActionFunc:PlayEffect(action_param, effect_param, target_unit)
    if target_unit then
        local temp_pos = effect_param.pos
        local pos = self.spell.battle_mgr:GetUnitPos(target_unit)
        local delay_time = 0
        local delay_list = action_param.target_type.delay_list
        if delay_list then
            if action_param.target_type.use_opposite and not self.spell.battle_mgr:IsOwnUnit(action_param.cast_unit) then
                delay_list = action_param.target_type.enemy_delay_list
            end
            delay_time = delay_list[pos]
        end
        self.spell:AddToDelayActionList(function()
            if action_param.is_attach_target then
                effect_param.target_go = target_unit.go
            end
            effect_param.pos = temp_pos
            local effect = self.spell.battle_mgr:CreateNormalEffect(effect_param)
            self.spell:AddToEffectTable(effect, action_param.effect_index)
            table.insert(self.create_effect_list, effect)
        end, action_param.happen_frame, delay_time)
    else
        local effect = self.spell.battle_mgr:CreateNormalEffect(effect_param)
        self.spell:AddToEffectTable(effect, action_param.effect_index)
        table.insert(self.create_effect_list, effect)
    end
end

function SpellActionFunc:EnterLauchBullet(param_tb)
    local offset = param_tb.offset or Vector3.zero
    local fly_time = param_tb.fly_data.fly_time
    local parm = {
        effect_type = CSConst.EffectType.ET_Bullet,
        cast_unit = param_tb.cast_unit,
        effect_id = param_tb.effect_id,
        offset = offset,
        fly_time = fly_time,
        scale = param_tb.effect_scale * (Vector3.NewByTable(param_tb.effect_vector_scale) or 1),
        fly_speed = param_tb.fly_data.fly_speed,
        speed_curve = param_tb.speed_curve,
        move_curve = param_tb.move_curve,
        scale_curve = param_tb.scale_curve,
        end_scale = param_tb.end_scale * (Vector3.NewByTable(param_tb.end_vector_scale) or 1),
    }

    local from_pos = self.spell:GetPosByPosType(param_tb.cast_unit, self.spell:GetPosByCondition(param_tb.from_pos_data, param_tb), param_tb)
    local to_pos = self.spell:GetPosByPosType(param_tb.cast_unit, self.spell:GetPosByCondition(param_tb.to_pos_data, param_tb), param_tb)
    if #from_pos == 0 or #to_pos == 0 then return end
    local target_unit_list = self.spell:GetTargetByTargetType(param_tb.target_type, param_tb)
    local delay_list = param_tb.target_type.delay_list
    if param_tb.target_type.use_opposite and not self.spell.battle_mgr:IsOwnUnit(param_tb.cast_unit) then
        delay_list = param_tb.target_type.enemy_delay_list
    end
    local target_unit
    local delay_time
    if #from_pos > 1 then
        for i, pos in ipairs(from_pos) do
            parm.pos = pos
            if #to_pos > 1 then
                parm.t_pos = to_pos[i]  --
                delay_time, target_unit = self:GetTargetAndDelay(target_unit_list, i, delay_list)
                self:LauchBullet(parm, target_unit, param_tb, delay_time)
            else
                parm.t_pos = to_pos[1]
                delay_time, target_unit = self:GetTargetAndDelay(target_unit_list, 1, delay_list)
                self:LauchBullet(parm, target_unit, param_tb, delay_time)
            end
        end
    else
        parm.pos = from_pos[1]
        if #to_pos > 1 then
            for i, pos in ipairs(to_pos) do
                parm.t_pos = to_pos[i]
                delay_time, target_unit = self:GetTargetAndDelay(target_unit_list, i, delay_list)
                self:LauchBullet(parm, target_unit, param_tb, delay_time)
            end
        else
            parm.t_pos = to_pos[1]
            delay_time, target_unit = self:GetTargetAndDelay(target_unit_list, 1, delay_list)
            self:LauchBullet(parm, target_unit, param_tb, delay_time)
        end
    end
end

function SpellActionFunc:GetTargetAndDelay(target_unit_list, index, delay_list)
    local target_unit
    local delay_time
    if target_unit_list then
        target_unit = target_unit_list[index]
    end
    if delay_list and target_unit then
        delay_time = delay_list[self.spell.battle_mgr:GetUnitPos(target_unit)]
    end
    return delay_time, target_unit
end

function SpellActionFunc:LauchBullet(parm, target_unit, param_tb, delay_lauch_time)
    delay_lauch_time = delay_lauch_time or 0
    local cause_event_id = param_tb.cause_event_id
    local happen_frame = param_tb.happen_frame
    local effect_index = param_tb.effect_index

    local event_happen_frame = happen_frame + math.ceil(delay_lauch_time / self.one_frame_length)
    local t_pos = parm.t_pos
    self.spell:AddToDelayActionList(function()
        parm.t_pos = t_pos
        parm.pos = Vector3.New(parm.pos.x, parm.pos.y, self.spell.max_order)
        parm.t_pos = Vector3.New(parm.t_pos.x, parm.t_pos.y, self.spell.max_order)
        local bullet = SpecMgrs.effect_mgr:CreateEffectAutoGuid(parm)
        self.spell:AddToEffectTable(bullet, effect_index)

        if cause_event_id ~= 0 then
            local delay_time = bullet.fly_time
            self.spell:AddToDelayActionList(function()
                self.spell:TriggerHit(target_unit, cause_event_id, event_happen_frame + math.ceil(delay_time / self.one_frame_length))
            end, event_happen_frame, delay_time)
        end
    end, happen_frame, delay_lauch_time)
end

function SpellActionFunc:EnterPlayLineEffect(param_tb)
    local parm = {
        effect_type = CSConst.EffectType.ET_Line,
        cast_unit = param_tb.cast_unit,
        effect_id = param_tb.effect_id,
        life_time = param_tb.life_time * self.spell.one_frame_length,
    }
    local from_pos_list = self.spell:GetPosByPosType(param_tb.cast_unit, self.spell:GetPosByCondition(param_tb.from_pos_data, param_tb), param_tb)
    local to_pos_list = self.spell:GetPosByPosType(param_tb.cast_unit, self.spell:GetPosByCondition(param_tb.to_pos_data, param_tb), param_tb)
    if #from_pos_list == 0 or #to_pos_list == 0 then return end
    local start_target_unit_list = self.spell:GetTargetByTargetType(param_tb.start_target_type, param_tb)
    local to_target_unit_list = self.spell:GetTargetByTargetType(param_tb.end_target_type, param_tb)
    for i, from_pos in ipairs(from_pos_list) do
        for j, to_pos in ipairs(to_pos_list) do
            parm.pos = Vector3.New(from_pos.x, from_pos.y, self.spell.max_order + (param_tb.level_offset or 0))
            parm.line_pos = Vector3.New(to_pos.x, to_pos.y, self.spell.max_order + (param_tb.level_offset or 0))
            if param_tb.is_attach_from_target and next(start_target_unit_list) then
                parm.target_go = start_target_unit_list[i].go
            end
            if param_tb.is_attach_to_target and next(to_target_unit_list) then
                parm.line_target_go = to_target_unit_list[j].go
            end
            local delay_list = {}
            local delay_time
            if param_tb.start_target_type.target_type == self.spell.target_type.SpellTarget then
                delay_list = self:GetDelayList(param_tb, param_tb.start_target_type)
                delay_time = self:GetTargetAndDelay(start_target_unit_list, i, delay_list)
            elseif param_tb.end_target_type.target_type == self.spell.target_type.SpellTarget then
                delay_list = self:GetDelayList(param_tb, param_tb.end_target_type)
                delay_time = self:GetTargetAndDelay(to_target_unit_list, j, delay_list)
            end
            delay_time = delay_time or 0
            if delay_time == 0 then
                local effect = SpecMgrs.effect_mgr:CreateEffectAutoGuid(parm)
                self.spell:AddToEffectTable(effect, param_tb.effect_index)
            else
                local copy_param = self:CopyParam(parm)
                self.spell:AddToDelayActionList(function()
                    local effect = SpecMgrs.effect_mgr:CreateEffectAutoGuid(copy_param)
                    self.spell:AddToEffectTable(effect, param_tb.effect_index)
                end, param_tb.happen_frame, delay_time)
            end
        end
    end
end

function SpellActionFunc:CopyParam(param_tb)
    local ret = {}
    if not param_tb then return ret end
    for k,v in pairs(param_tb) do
        ret[k] = v
    end
    return ret
end

function SpellActionFunc:GetDelayList(param_tb, target_data)
    local delay_list = target_data.delay_list
    if target_data.use_opposite and not self.spell.battle_mgr:IsOwnUnit(param_tb.cast_unit) then
        delay_list = target_data.enemy_delay_list
    end
    return delay_list
end

function SpellActionFunc:EnterShowSpellName(param_tb)
    self.spell:HandleUnitByTargetType(param_tb, function(unit)
        SpecMgrs.ui_mgr:ShowHud(
        {
            hud_type = UnitConst.UNITHUD_TYPE.Spell,
            spell_id = param_tb.spell_id,
            point_go = unit.go:FindChild("UnitInfo"),
            is_in_battle = true,
        })
    end)
end

function SpellActionFunc:EnterCaculateDeath(param_tb)
    self.spell.battle_mgr:CaculateDeath()
end

function SpellActionFunc:EnterEnd(param_tb)
    local cast_unit = param_tb.cast_unit
    if cast_unit.is_destroy then return end
    cast_unit:ShowOrHideInfo(true)
    cast_unit:SetAnger(cast_unit:GetAnger() + param_tb.anger_diff)
end

function SpellActionFunc:EnterShowGhost(param_tb)
    local time = param_tb.show_time * self.spell.one_frame_length / param_tb.ghost_interval
    local start_color = Color.NewByTable(param_tb.start_color)
    local end_color = Color.NewByTable(param_tb.end_color)
    local delay_time = 0
    self.spell:HandleUnitByTargetType(param_tb, function(unit)
        for i = 1, time do
            delay_time = delay_time + param_tb.ghost_interval
            self.spell:AddToDelayActionList(function()
                if unit.go and unit.go.activeSelf then
                    local go = unit:CreateGhost(param_tb.ghost_lifetime, start_color, end_color)
                    local pos = go.transform.position
                    go.transform.position = Vector3.New(pos.x, pos.y, self.spell.min_order)
                end
            end, param_tb.happen_frame, delay_time)
        end
    end)
end

function SpellActionFunc:EnterSetHitHappenTime(param_tb)

end

function SpellActionFunc:EnterShakeScreen(param_tb)
    local cur_shake_screen = {
        shake_time = param_tb.shake_time,
        shake_range = param_tb.shake_range,
        shake_obj_list = {self.camera}
    }
    SpecMgrs.ui_mgr:ShakeScreen(cur_shake_screen)
end

function SpellActionFunc:EnterShowOrHideShadow(param_tb)
    self.spell:HandleUnitByTargetType(param_tb, function(unit)
        unit:ShowOrHideShadow(param_tb.is_show)
    end)
end

function SpellActionFunc:EnterShowOrHideHud(param_tb)
    self.spell:HandleUnitByTargetType(param_tb, function(unit)
        unit:ShowOrHideInfo(param_tb.is_show)
    end)
end

function SpellActionFunc:EnterCreateGhost(param_tb)
    local pos_data = self.spell:GetPosByCondition(param_tb.pos_data, param_tb)
    local to_pos_list = self.spell:GetPosByPosType(param_tb.cast_unit, pos_data, param_tb)
    if #to_pos_list == 0 then return end
    for i, pos in ipairs(to_pos_list) do
        local unit_param = {}
        unit_param.unit_id = param_tb.unit_id == 0 and param_tb.cast_unit.unit_id or param_tb.unit_id
        unit_param.position = pos
        unit_param.is_show_shadow = true
        unit_param.need_sync_load = true
        unit_param.is_3D_model = true
        unit_param.is_flip_x = not self.spell.battle_mgr:IsOwnUnit(param_tb.cast_unit)
        local unit = ComMgrs.unit_mgr:CreateUnitAutoGuid(unit_param)
        unit:SetScale(Vector3.NewByTable(param_tb.start_size) or Vector3.one, "Spell")
        self.spell:AddCreatGhost(unit, param_tb.ghost_id, param_tb.happen_frame, param_tb.last_time * self.one_frame_length)
        self.spell.battle_mgr:AddToSortObjList(unit)
        unit:SetColor(Color.NewByTable(param_tb.start_color))
        if param_tb.stop_anim then
            unit:StopAllAnimation()
        end
    end
end

--  技能过程中提前显示buff
function SpellActionFunc:EnterShowBuff(param_tb)
    self.spell:HandleUnitByTargetType(param_tb, function(unit)
        local side, pos = self.spell.battle_mgr:GetUnitSidePos(unit)
        for i, data in ipairs(self.spell.battle_mgr.action_handler.wait_to_add_buff_list) do
            if side == data[1] and pos == data[2] then
                self.spell.battle_mgr:AddBuff(data[1], data[2], data[3])
                return
            end
        end
    end)
end

function SpellActionFunc:EnterTriggerAction(param_tb)
    self.spell:HandleUnitByTargetType(param_tb, function(unit)
        self.spell:TriggerEvent(unit, param_tb.cause_event_id, param_tb.happen_frame)
    end)
end

function SpellActionFunc:EnterShowTogherAttackEffect(param_tb)
    local spell_data = SpecMgrs.data_mgr:GetSpellData(param_tb.spell_id)
    if spell_data.spell_type ~= FConst.SpellType.TogetherSpell and spell_data.spell_type ~= FConst.SpellType.SuperTogetherSpell then
        PrintError(param_tb.spell_id .. "不是合击技能")
        return
    end
    if not spell_data.spell_unit_list then
        PrintError(param_tb.spell_id .. "没有合击对象")
        return
    end
    local together_unit_id = spell_data.spell_unit_list[1]
    local cast_unit_id = param_tb.cast_unit.unit_id

    local effect_id
    if spell_data.spell_type == FConst.SpellType.TogetherSpell then
        effect_id = together_attack_effect_id
    else
        effect_id = super_together_attack_effect_id
    end

    local effect_param_tb = {
        effect_id = effect_id,
        pos = Vector3.zero,
        effect_type = CSConst.EffectType.ET_UI,
        need_sync_load = true,
    }
    local scale = self.spell.battle_mgr.battle_param.together_effect_unit_scale
    local effect = SpecMgrs.effect_mgr:CreateEffectAutoGuid(effect_param_tb)
    local unit_param_tb = {}
    unit_param_tb.scale = scale
    unit_param_tb.unit_id = cast_unit_id
    unit_param_tb.layer_name = "UI"
    unit_param_tb.parent = effect.go:FindChild("juese1/mask/Point")
    unit_param_tb.need_sync_load = true
    unit_param_tb.position = Vector3.NewByTable(param_tb.left_pos) or Vector3.Zero
    local left_unit = ComMgrs.unit_mgr:CreateUnitAutoGuid(unit_param_tb)

    unit_param_tb = {}
    unit_param_tb.scale = scale
    unit_param_tb.unit_id = together_unit_id
    unit_param_tb.layer_name = "UI"
    unit_param_tb.parent = effect.go:FindChild("juese2/mask/Point")
    unit_param_tb.need_sync_load = true
    unit_param_tb.position = Vector3.NewByTable(param_tb.right_pos) or Vector3.Zero
    local right_unit = ComMgrs.unit_mgr:CreateUnitAutoGuid(unit_param_tb)

    local tag = tostring(param_tb.spell_id)
    effect:RegisterEffectEndEvent(tag, function()
        ComMgrs.unit_mgr:DestroyUnit(left_unit)
        ComMgrs.unit_mgr:DestroyUnit(right_unit)
        effect:UnregisterEffectEndEvent(tag)
    end)
end

function SpellActionFunc:EnterPlaySound(param_tb)
    local sound = SpecMgrs.sound_mgr:PlaySpellSound(param_tb.sound_id)
    sound:UpdateVolume(param_tb.sound_size)
end

function SpellActionFunc:EnterSetUnitLayer(param_tb)
    self.spell:HandleUnitByTargetType(param_tb, function(unit)
        self.spell:SetUnitLayer(unit, param_tb.layer)
    end)
end

return SpellActionFunc