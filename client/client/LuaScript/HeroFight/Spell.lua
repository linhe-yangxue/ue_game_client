local FConst = require("CSCommon.Fight.FConst")
local UnitConst = require("Unit.UnitConst")
local AnimationCurve = require("CommonTypes.AnimationCurve")
local SpellActionFunc = require("HeroFight.SpellActionFunc")
local Spell = class("HeroFight.Spell")

local own_unit_chest = "own_point_chest"
local enemy_unit_chest = "enemy_point_chest"
local unit_foot = "point_foot"

local unit_waist_hieght = Vector3.New(0, 10, 0)
local overhead_offset = 60

local enemy_overhead = Vector3.New(25, 60, 0)
local own_overhead = Vector3.New(-25, 60, 0)

local x_dir = Vector3.New(5, 0, 0)
local y_dir = Vector3.New(0, 5, 0)

Spell.pos_type = {
    StartPos = 1,
    EnemyMiddlePos = 2, -- 前排中间位置，如果没有前排，则为后排中间位置
    Zero = 3,
    EnemyOverhead = 4,
    AttackAllPos = 5,
    TargetSameColumn = 6,
    TargetColumnBackRow = 7,
    OwnOverHead = 8,
    FixPos = 9, -- 输入Vector3
    SpellTargetPos = 10,
    OwnPos = 11,
    TogetherAttackTargetPos = 12,
    TriggerTargetPos = 13,
    GhostPos = 14,
}

Spell.target_type = {
    None = 1,
    Own = 2,
    SpellTarget = 3,
    TogetherAttackTarget = 4,
    TriggerTarget = 5,
    BesidesSkillTarget = 6,  -- 施法者 合击者，技能目标以外的单位
    Ghost = 7,
}

Spell.unit_body_type = {
    Foot = 1,
    Chest = 2,
    Forward = 3,
    Overhead = 4,  -- 天上
    Behind = 5,
    X = 6,
    SameY = 7,
    Left = 8,
    Right = 9,
    OppositeY = 10,
}

-- 选择位置的条件
Spell.pos_check_condition = {
    not_condition = 1,
    spell_target_hvae_front_row = 2, --技能目标是否有前排
    spell_target_column = 3,-- 技能目标列
}

Spell.buff_order = -90

Spell.max_order = -100
Spell.min_order = 190

local bullet_fly_time = 0.3
local default_move_time = 0.3
local default_move_near_time = 0.2
local move_near_dis = 100
local fps = 30
local normal_sort_order = 0
local battle_mask_start_color = Color.New(0, 0, 0, 0)

function Spell:DoInit(battle_mgr, spell_data, spell_id, cur_cast_unit, cur_anger_diff, spell_target_list_tb)
    self.battle_bg = SpecMgrs.ui_mgr:GetUI("HeroBattleUI").go:FindChild("Bg"):GetComponent("Image")
    self.effect_attach_go = SpecMgrs.ui_mgr:GetUI("EffectUI").main_panel
    self.battle_mgr = battle_mgr
    self.spell_timer = 0
    self.spell_action_list = {}
    self.spell_trigger_list = {}
    self.hit_table = {}
    self.effect_tb = {}
    self.create_ghost_tb = {}
    self.spell_update_list = {}
    self.change_layer_unit_dict = {}

    self.cur_frame = 0
    self.one_frame_length = 1 / fps
    self.action_handler = SpellActionFunc:New()
    self.action_handler:DoInit(self)
    self.cur_cast_unit = cur_cast_unit
    self.delay_handle_func_list = {}
    self.is_init = true

    local spell_info = SpecMgrs.data_mgr:GetSpellData(spell_id)
    local hit_time = #spell_info.hit_tb
    local hit_happen_time = 0
    local spell = table.deepcopy(spell_data)
    for i, action_parm in ipairs(spell) do
        if next(action_parm) then
            if action_parm.spell_action_type == "SetHitHappenTime" then
                if not self.hit_table then
                    self.hit_table = {}
                end
                if not self.hit_table[action_parm.hit_segment] then
                    self.hit_table[action_parm.hit_segment] = {}
                end
                local opposite_tb = {3, 2, 1, 6, 5, 4}
                for i = 1 , 6 do
                    local key_name = "delay" .. i
                    if action_parm.use_opposite and not self.battle_mgr:IsOwnUnit(cur_cast_unit) then
                        key_name = "delay" .. opposite_tb[i]
                    end
                    local happen_time = action_parm.happen_frame * self.one_frame_length + action_parm[key_name]
                    table.insert(self.hit_table[action_parm.hit_segment], happen_time)
                end
                hit_happen_time = hit_happen_time + 1
            end
            if action_parm.spell_action_type == "LauchBullet" then
                if action_parm.cause_event_id ~= 0 then
                    hit_happen_time = hit_happen_time + 1
                end
            end
            action_parm.spell_id = spell_id
            action_parm.cast_unit = cur_cast_unit
            action_parm.anger_diff = cur_anger_diff
            action_parm.spell_target_list = spell_target_list_tb[1]
            -- if action_parm.target_type then
            --     local spell_target_segment = action_parm.target_type.segment
            --     spell_target_segment = spell_target_segment == 0 and 1 or spell_target_segment
            --     if spell_target_segment > #spell_target_list_tb then
            --         PrintError(spell_id .. "   攻击段数错误")
            --         action_parm.spell_target_list = spell_target_list_tb[1]
            --     else
            --         action_parm.spell_target_list = spell_target_list_tb[spell_target_segment]
            --     end
            -- else
            --     action_parm.spell_target_list = spell_target_list_tb[1]
            -- end
            if spell_info.spell_type == FConst.SpellType.TogetherSpell or spell_info.spell_type == FConst.SpellType.SuperTogetherSpell then -- 合体
                action_parm.togher_unit = self.battle_mgr:GetTogetherAttackUnit(cur_cast_unit, spell_id)
            end
            if action_parm.trigger_event_id and action_parm.trigger_event_id ~= 0 then --触发事件
                self.spell_trigger_list[action_parm] = action_parm.trigger_event_id
            else
               table.insert(self.spell_action_list, action_parm)
            end
        end
    end
    local end_action = self.spell_action_list[#self.spell_action_list]
    if end_action.spell_action_type ~= "SpellEnd" then
        PrintError(spell_id .. "无技能结束时间")
    else
        self.end_time = end_action.happen_frame * self.one_frame_length
        self.end_frame = end_action.happen_frame
    end
    if hit_time ~= hit_happen_time then
        PrintError(spell_id .. "技能伤害段数错误")
    end
end

function Spell:Update(delta_time)
    self.spell_timer = self.spell_timer + delta_time
    self.cur_frame = math.floor(self.spell_timer * fps)

    self:CheckEffectDestroy()

    if next(self.spell_action_list) then
        local spell_action = self.spell_action_list[1]
        while self.cur_frame >= spell_action.happen_frame do
            table.remove(self.spell_action_list, 1)
            self.action_handler:RunEnterFunc(spell_action.spell_action_type, spell_action)
            spell_action = self.spell_action_list[1]
            if not spell_action then
                break
            end
        end
    else
        return true
    end

    local remove_list = {}
    local length = #self.spell_update_list
    for i = 1, length do
        local move_action = self.spell_update_list[i]
        local lerp
        if move_action.change_frame == 0 then
            lerp = 1
        else
            lerp = (self.spell_timer - move_action.start_time) / (move_action.change_frame * self.one_frame_length)
        end
        self.action_handler:RunAnimUpdateFunc(move_action.spell_action_type, move_action, lerp)
        if lerp >= 1 then
            table.insert(remove_list, move_action)
        end
    end

    for i, action in ipairs(remove_list) do
        local index = table.index(self.spell_update_list, action)
        if index then
            table.remove(self.spell_update_list, index)
        end
    end

    --  延迟处理列表会在遍历过程中增加，所以使用while
    local index = 1
    while index <= #self.delay_handle_func_list do
        local parm = self.delay_handle_func_list[index]
        if self.cur_frame >= parm.happen_frame then
            parm.func()
            table.remove(self.delay_handle_func_list, index)
        else
            index = index + 1
        end
    end
end

function Spell:SpellEnd()
    for unit, v in pairs(self.change_layer_unit_dict) do
        if not unit.is_destroy then
            unit:SetSortOrder(normal_sort_order)
        end
    end
    for i, effect in ipairs(self.action_handler.create_effect_list) do
        if not effect:IsDestroy() then
            SpecMgrs.effect_mgr:DestroyEffect(effect)
        end
    end
    for unit, ghost_id in pairs(self.create_ghost_tb) do
        if not unit.is_destroy then
            ComMgrs.unit_mgr:DestroyUnit(unit)
        end
    end
    self.action_handler.battle_bg:GetComponent("SpriteRenderer").color = Color.white
    self.action_handler.battle_mask.color = battle_mask_start_color
    SpecMgrs.ui_mgr:EndShakeScreen()
end

function Spell:SetUnitLayer(unit, layer)
    self.change_layer_unit_dict[unit] = layer
    unit:SetSortOrder(layer)
end

function Spell:CheckEffectDestroy()
    local length = #self.effect_tb
    for i = length, 1, -1 do
        local effect = self.effect_tb[i]
        if not effect or effect.is_destroy then
            table.remove(self.effect_tb, i)
        end
    end
end

function Spell:AddToUpdateList(spell_action)
    if spell_action.replace_action then
        for i, action in ipairs(self.spell_update_list) do
            if action.target_obj == spell_action.target_obj and spell_action.spell_action_type == action.spell_action_type then
                self.spell_update_list[i] = spell_action
                return
            end
        end
        table.insert(self.spell_update_list, spell_action)
    else
        table.insert(self.spell_update_list, spell_action)
    end
end

--动画行为根据序号寻找特效
function Spell:AddToEffectTable(target_effect, index)
    target_effect.spell_index = index
    table.insert(self.effect_tb, target_effect)
end

function Spell:GetEffectByID(index)
    local ret = {}
    for i, effect in ipairs(self.effect_tb) do
        if effect.spell_index == index then
            table.insert(ret, effect)
        end
    end
    return ret
end

function Spell:AddToDelayActionList(func, happen_frame, delay_time)
    local param = {
        func = func,
        happen_frame = happen_frame + math.ceil(delay_time / self.one_frame_length),
    }
    if self.cur_frame >= param.happen_frame then
        func()
    else
        if param.happen_frame >= self.end_frame then
            param.happen_frame = self.end_frame - 1
        end
        table.insert(self.delay_handle_func_list, param)
    end
end

function Spell:TriggerHit(target_unit, trigger_event_id, happen_frame)
    if trigger_event_id == 0 then
        return
    end
    if self.battle_mgr:TriggerHit(target_unit) then
        self:TriggerEvent(target_unit, trigger_event_id, happen_frame)
    end
end

function Spell:TriggerEvent(target_unit, trigger_event_id, happen_frame)
    if trigger_event_id == 0 then return end
    local delay_happen_list = {}
    local happen_list = {}
    for spell_action, event_id in pairs(self.spell_trigger_list) do
        if event_id == trigger_event_id then
            if spell_action.trigger_event_delay then
                table.insert(delay_happen_list, spell_action)
            else
                table.insert(happen_list, spell_action)
            end
        end
    end
    table.sort(delay_happen_list, function(action1, action2)
        if action1.trigger_event_delay == action2.trigger_event_delay then
            return false
        end
        return action1.trigger_event_delay < action2.trigger_event_delay
    end)

    for i, spell_action in ipairs(happen_list) do
        spell_action.happen_frame = happen_frame
        spell_action.trigger_target = target_unit
        self.action_handler:RunEnterFunc(spell_action.spell_action_type, spell_action)
    end
    for i, spell_action in ipairs(delay_happen_list) do
        self:AddToDelayActionList(function()
            spell_action.happen_frame = happen_frame + math.ceil(spell_action.trigger_event_delay / self.one_frame_length)
            spell_action.trigger_target = target_unit
            self.action_handler:RunEnterFunc(spell_action.spell_action_type, spell_action)
        end, happen_frame, spell_action.trigger_event_delay)
    end
end

function Spell:GetUnitBodyPosByType(unit, pos_data, pos)
    local pos_type = pos_data.unit_body_type
    local unit_body_type_first = pos_data.unit_body_type_first
    local unit_body_type_second = pos_data.unit_body_type_second

    local offset_coefficient_first = pos_data.offset_coefficient_first
    local offset_coefficient_second = pos_data.offset_coefficient_second

    if unit_body_type_first == Spell.unit_body_type.Overhead then
        if unit_body_type_second == Spell.unit_body_type.Overhead then
            return Vector3.New(pos.x, overhead_offset * offset_coefficient_first, pos.z)
        else
            return Vector3.New(pos.x, overhead_offset * offset_coefficient_first, pos.z) + self:GetOffsetByType(unit, unit_body_type_second, offset_coefficient_second)
        end
    end
    if unit_body_type_second == Spell.unit_body_type.Overhead then
        return Vector3.New(pos.x, overhead_offset * offset_coefficient_second, pos.z) + self:GetOffsetByType(unit, unit_body_type_first, offset_coefficient_first)
    end
    local pos_offset_first = self:GetOffsetByType(unit, unit_body_type_first, offset_coefficient_first)
    local pos_offset_second = self:GetOffsetByType(unit, unit_body_type_second, offset_coefficient_second)
    return pos_offset_first + pos_offset_second + (pos or Vector3.zero)
end

function Spell:GetOffsetByType(unit, unit_body_type, offset_coefficient)
    if unit_body_type == Spell.unit_body_type.X then  --x轴 y轴
        if self.battle_mgr:IsOwnUnit(self.cur_cast_unit) then
            return x_dir * offset_coefficient
        else
            return -x_dir * offset_coefficient
        end
    elseif unit_body_type == Spell.unit_body_type.SameY then
        return y_dir * offset_coefficient
    elseif unit_body_type == Spell.unit_body_type.OppositeY then
        if self.battle_mgr:IsOwnUnit(self.cur_cast_unit) then
            return y_dir * offset_coefficient
        else
            return -y_dir * offset_coefficient
        end
    end

    if not next(unit) then
        if unit_body_type == Spell.unit_body_type.Chest then
            return unit_waist_hieght * offset_coefficient
        end
        return Vector3.zero
    end

    if unit_body_type == Spell.unit_body_type.Chest then  -- 腰部位置 敌我位置不一样
        if self.battle_mgr:IsOwnUnit(unit) then
            return unit:GetUnitPointPos(own_unit_chest, true) * offset_coefficient
        else
            return unit:GetUnitPointPos(enemy_unit_chest, true) * offset_coefficient
        end
    elseif unit_body_type == Spell.unit_body_type.Foot then
        return unit:GetUnitPointPos(unit_foot, true) * offset_coefficient
    elseif unit_body_type == Spell.unit_body_type.Forward then
        return self.battle_mgr:GetForwardDir(self.battle_mgr:IsOwnUnit(unit)) * offset_coefficient
    elseif unit_body_type == Spell.unit_body_type.Behind then
        return -self.battle_mgr:GetForwardDir(self.battle_mgr:IsOwnUnit(unit)) * offset_coefficient
    elseif unit_body_type == Spell.unit_body_type.Left then
        return self.battle_mgr:GetLeftRightDir(unit, true) * offset_coefficient
    elseif unit_body_type == Spell.unit_body_type.Right then
        return self.battle_mgr:GetLeftRightDir(unit, false) * offset_coefficient
    end
    return Vector3.zero
end

function Spell:GetPosByCondition(pos_data, param_tb)
    if pos_data.condition then
        if pos_data.condition == Spell.pos_check_condition.not_condition then
            return pos_data.pos
        elseif pos_data.condition == Spell.pos_check_condition.spell_target_hvae_front_row then
            if self.battle_mgr:IsUnitListHaveFrontrow(param_tb.spell_target_list) then
                return pos_data.pos
            else
                return pos_data.second_pos
            end
        elseif pos_data.condition == Spell.pos_check_condition.spell_target_column then
            local index = self.battle_mgr:GetUnitListColumn(param_tb.spell_target_list[1])
            if index == 1 then return pos_data.pos end
            if index == 2 then return pos_data.second_pos end
            if index == 3 then return pos_data.third_pos end
        end
    end
    PrintError("无选择条件")
end

function Spell:GetPosByPosType(unit, pos_data, param_tb)
    local pos_type = pos_data.pos_type
    local to_pos
    local pos_is_list = false
    local to_pos_list = {}
    local target_unit = {}
    local target_list = {}
    if pos_type == Spell.pos_type.StartPos then
        if self.create_ghost_tb[unit] then
            to_pos = self.battle_mgr:GetUnitStartPos(self.cur_cast_unit)
        else
            to_pos = self.battle_mgr:GetUnitStartPos(unit)
        end
        target_unit = unit
    elseif pos_type == Spell.pos_type.EnemyMiddlePos then
        to_pos = self.battle_mgr:GetEnemyMiddlePos(unit, param_tb.spell_target_list)
        target_unit = param_tb.spell_target_list[1]
    elseif pos_type == Spell.pos_type.Zero then
        to_pos = Vector3.zero
    elseif pos_type == Spell.pos_type.EnemyOverhead then
        to_pos = enemy_overhead
    elseif pos_type == Spell.pos_type.OwnOverhead then
        to_pos = own_overhead
    elseif pos_type == Spell.pos_type.TargetSameColumn then
        to_pos = self.battle_mgr:GetTargetSameColumnFront(unit, param_tb.spell_target_list[1])
        target_unit = unit
    elseif pos_type == Spell.pos_type.TargetColumnBackRow then
        to_pos, target_unit = self.battle_mgr:GetTargetColumnBackRow(param_tb.spell_target_list[1])
    elseif pos_type == Spell.pos_type.AttackAllPos then
        to_pos_list = self.battle_mgr:GetAllAttackTargetPos(unit)
        pos_is_list = true
    elseif pos_type == Spell.pos_type.FixPos then
        if self.battle_mgr:IsOwnUnit(param_tb.cast_unit) then
            to_pos = Vector3.NewByTable(pos_data.fix_pos)
        else
            to_pos = Vector3.NewByTable(pos_data.enemy_fix_pos)
        end
        target_unit = self.cur_cast_unit
    elseif pos_type == Spell.pos_type.SpellTargetPos then
        local list = param_tb.spell_target_list
        if param_tb.target_type and param_tb.target_type.target_type == Spell.target_type.SpellTarget then
            list = self:GetTargetByTargetType(param_tb.target_type, param_tb)
        end
        for i, target in ipairs(list) do
            table.insert(to_pos_list, target:GetPosition())
            table.insert(target_list, target)
        end
        pos_is_list = true
    elseif pos_type == Spell.pos_type.OwnPos then
        to_pos = param_tb.cast_unit:GetPosition()
        target_unit = param_tb.cast_unit
    elseif pos_type == Spell.pos_type.TogetherAttackTargetPos then
        to_pos = param_tb.togher_unit:GetPosition()
        target_unit = param_tb.togher_unit
    elseif pos_type == Spell.pos_type.TriggerTargetPos then
        to_pos = param_tb.trigger_target:GetPosition()
        target_unit = param_tb.trigger_target
    elseif pos_type == Spell.pos_type.GhostPos then
        local unit_list = self:_GetGhost(pos_data.ghost_id)
        for i, unit in ipairs(unit_list) do
            table.insert(to_pos_list, unit:GetPosition())
            table.insert(target_list, unit)
        end
        pos_is_list = true
    end
    if param_tb then
        if pos_is_list then
            for i, pos in ipairs(to_pos_list) do
                if(target_list) then
                    pos = self:GetUnitBodyPosByType(target_list[i], pos_data, pos)
                else
                    pos = self:GetUnitBodyPosByType(target_unit, pos_data, pos)
                end
                to_pos_list[i] = pos
            end
        else
            to_pos = self:GetUnitBodyPosByType(target_unit, pos_data, to_pos)
        end
    end
    if to_pos then
        table.insert(to_pos_list, to_pos)
    end
    return to_pos_list
end

function Spell:GetTargetByTargetType(target_data, action_parm)
    local ret = {}
    local target_type = target_data.target_type
    if target_type == Spell.target_type.TogetherAttackTarget then
        table.insert(ret, action_parm.togher_unit)
    elseif target_type == Spell.target_type.Own then
        table.insert(ret, action_parm.cast_unit)
    elseif target_type == Spell.target_type.SpellTarget then
        for i, unit in ipairs(action_parm.spell_target_list) do
            if target_data.spell_target_filter then
                local pos = self.battle_mgr:GetUnitPos(unit)
                if target_data.spell_target_filter[pos] then
                    table.insert(ret, unit)
                end
            else
                table.insert(ret, unit)
            end
        end
    elseif target_type == Spell.target_type.TriggerTarget then
        table.insert(ret, action_parm.trigger_target)
    elseif target_type == Spell.target_type.BesidesSkillTarget then
        for i, unit in ipairs(self:_GetBesidesSkillTarget(action_parm)) do
            table.insert(ret, action_parm.trigger_target)
        end
    end
    return ret
end

function Spell:HandleUnitByTargetType(action_parm, func)
    local target_type = action_parm.target_type.target_type
    if target_type == Spell.target_type.TogetherAttackTarget then
        func(action_parm.togher_unit)
    elseif target_type == Spell.target_type.Own then
        func(action_parm.cast_unit)
    elseif target_type == Spell.target_type.SpellTarget then
        --  多个目标时有延迟功能
        local delay_list = action_parm.target_type.delay_list
        if action_parm.target_type.use_opposite and not self.battle_mgr:IsOwnUnit(action_parm.cast_unit) then
            delay_list = action_parm.target_type.enemy_delay_list
        end
        local target_list = self:GetTargetByTargetType(action_parm.target_type, action_parm)
        if action_parm.target_type.use_delay then
            local happen_frame = action_parm.happen_frame
            for i, unit in ipairs(target_list) do
                local pos = self.battle_mgr:GetUnitPos(unit)
                self:AddToDelayActionList(function()
                    action_parm.happen_frame = happen_frame + math.ceil(delay_list[pos] / self.one_frame_length)
                    func(unit)
                end, action_parm.happen_frame, delay_list[pos])
            end
        else
            for i, unit in ipairs(target_list) do
                func(unit)
            end
        end
    elseif target_type == Spell.target_type.TriggerTarget then
        func(action_parm.trigger_target)
    elseif target_type == Spell.target_type.BesidesSkillTarget then
        for i, unit in ipairs(self:_GetBesidesSkillTarget(action_parm)) do
            func(unit)
        end
    elseif target_type == Spell.target_type.Ghost then
        for i, unit in ipairs(self:_GetGhost(action_parm.target_type.ghost_id)) do
            func(unit)
        end
    end
end

-- 施法者 合击者，技能目标以外的单位
function Spell:_GetBesidesSkillTarget(action_parm)
    local ret = {}
    local skill_relation_tb = {}
    --  加血技能时 施法者，合计者也可以是技能目标
    for i, unit in ipairs(action_parm.spell_target_list) do
        skill_relation_tb[unit] = 1
    end
    skill_relation_tb[action_parm.cast_unit] = 1
    if action_parm.togher_unit then
        skill_relation_tb[action_parm.togher_unit] = 1
    end
    local exist_list = self.battle_mgr:GetAllExistUnitList()
    for i, unit in ipairs(exist_list) do
        if not skill_relation_tb[unit] then
            table.insert(ret, unit)
        end
    end
    return ret
end

function Spell:_GetGhost(ghost_id)
    local ret = {}
    for unit, id in pairs(self.create_ghost_tb) do
        if id == ghost_id then
            table.insert(ret, unit)
        end
    end
    return ret
end

function Spell:AddCreatGhost(unit, ghost_id, happen_frame, last_time)
    self.create_ghost_tb[unit] = ghost_id
    self:AddToDelayActionList(function()
        self.create_ghost_tb[unit] = nil
        if not unit.is_destroy then
            ComMgrs.unit_mgr:DestroyUnit(unit)
        end
    end, happen_frame, last_time)
end

function Spell:GetEndTime()
    return self.end_time
end

return Spell