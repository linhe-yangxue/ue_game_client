local FConst = require("CSCommon.Fight.FConst")
local HeroBattleActionHandler = class("HeroFight.HeroBattleActionHandler")

function HeroBattleActionHandler:DoInit(battle_mgr)
    self.battle_mgr = battle_mgr
    self.compute_buff_time = 0.3
    self.trigger_buff_time = 0.5
    self.is_compute_buff = false
    self.cur_spell_id = nil
    self.start_spell_time = nil
end

function HeroBattleActionHandler:HandleAction(action)
    local func_name = action.event_type
    local func = self[func_name]
    if func then
        return func(self, table.unpack(action, 1, #action))
    end
end

function HeroBattleActionHandler:RoundStart(round_num)
    self.battle_mgr:RoundStart(round_num)
end

function HeroBattleActionHandler:SpellStart(side, pos, spell_id, anger_diff)
    self.cur_hit_segment = nil
    self.cur_hit_times = nil
    self.cur_spell_id = spell_id
    self.wait_to_trigger_buff_list = {}
    self.wait_to_trigger_hit = {} -- 触发的伤害列表
    self.wait_to_remove_buff_list = {}
    self.wait_to_add_buff_list = {}
    self.wait_to_show_invalid_buff_list = {}
    self.start_spell_time = self.battle_mgr.action_timer
    self.battle_mgr:CastSpell(side, pos, spell_id, anger_diff)
    self.is_cast_spell = true
    self.is_add_buff = false
    self.spell_end_time = self.battle_mgr.cur_spell:GetEndTime() + self.start_spell_time
end

function HeroBattleActionHandler:SpellHit(side, pos, hit_times, hp_diff, is_crit, is_miss, is_second_kill)
    local action = self.battle_mgr:GetCurAction()
    local happen_time = 0
    if self.battle_mgr.cur_spell.hit_table then
        if self.battle_mgr.cur_spell.hit_table[hit_times] then
            happen_time = self.battle_mgr.cur_spell.hit_table[hit_times][pos]
        end
    end
    if happen_time == 0 then  -- 发生时间为0时，则为触发hit
        local target_unit = self.battle_mgr:GetUnit(side, pos)
            table.insert(self.wait_to_trigger_hit, {target_unit, side, pos, is_crit, hp_diff, is_miss, is_second_kill})
        return
    end
    happen_time = happen_time + self.start_spell_time
    self.battle_mgr:AddDelayFunc(function()
        self.battle_mgr:SpellHit(side, pos, is_crit, hp_diff, is_miss, is_second_kill)
    end, happen_time)
end

function HeroBattleActionHandler:SpellEnd(side, pos, spell_id)
    local action = self.battle_mgr:GetCurAction()
    if action.happen_time == 0 then
        action.happen_time = self.spell_end_time
        return true
    else
        for i, data in ipairs(self.wait_to_show_invalid_buff_list) do
            self.battle_mgr:ShowInvalidBuff(data[1], data[2])
        end
        --  技能结束后才进行添加buff特效和buff触发
        self.is_cast_spell = false
        --  同时移除增加同一个buff特效时不处理
        for i, remove_data in ipairs(self.wait_to_remove_buff_list) do
            local is_remove = true
            for j, add_buff_data in ipairs(self.wait_to_add_buff_list) do
                if add_buff_data[1] == remove_data[1] and add_buff_data[2] == remove_data[2] then
                    local remove_effect_id = SpecMgrs.data_mgr:GetBuffData(remove_data[3]).effect_id
                    local add_effect_id = SpecMgrs.data_mgr:GetBuffData(add_buff_data[3]).effect_id
                    if remove_effect_id == add_effect_id then
                        is_remove = false
                    end
                end
            end
            if is_remove then
                self.battle_mgr:RemoveBuff(remove_data[1], remove_data[2], remove_data[3])
            end
        end
        for i, data in ipairs(self.wait_to_trigger_buff_list) do
            self.battle_mgr:TriggerBuff(data[1], data[2], data[3])
        end
        for i, data in ipairs(self.wait_to_add_buff_list) do
            self.battle_mgr:AddBuff(data[1], data[2], data[3])
        end
        local spell_wait_time = self.battle_mgr.battle_param.spell_wait_time
        if self.is_add_buff then
            local add_buff_time = self.battle_mgr.battle_param.add_buff_time
            self.battle_mgr:SetNextActionHappenTime(add_buff_time + spell_wait_time)
        else
            self.battle_mgr:SetNextActionHappenTime(spell_wait_time)
        end
    end
end

function HeroBattleActionHandler:AddBuff(side, pos, buff_id)
    if SpecMgrs.data_mgr:GetBuffData(buff_id).effect_id then
        table.insert(self.wait_to_add_buff_list, {side, pos, buff_id})
        self.is_add_buff = true
    end
end

function HeroBattleActionHandler:TriggerBuff(side, pos, buff_id, hp_diff, add_state)
    if self.is_cast_spell then
        table.insert(self.wait_to_trigger_buff_list, {side, pos, hp_diff})
    else
        self.battle_mgr:TriggerBuff(side, pos, hp_diff)
        self.battle_mgr:SetNextActionHappenTime(self.trigger_buff_time)
    end
end

function HeroBattleActionHandler:RemoveBuff(side, pos, buff_id, remove_state)
    if self.is_cast_spell then
        table.insert(self.wait_to_remove_buff_list, {side, pos, buff_id})
    else
        self.battle_mgr:RemoveBuff(side, pos, buff_id)
    end
end

--  免疫buff
function HeroBattleActionHandler:Immune(side, pos, state)
    table.insert(self.wait_to_show_invalid_buff_list, {side, pos})
end

function HeroBattleActionHandler:RoundEnd(round_num)
    self.battle_mgr:RoundEnd(round_num)
end

function HeroBattleActionHandler:GameEnd(is_win)
    self.battle_mgr:GameEnd(is_win)
end

function HeroBattleActionHandler:GetTargetHit(target_unit)
    if not self.wait_to_trigger_hit then return end
    for i, param in ipairs(self.wait_to_trigger_hit) do
        if param[1] == target_unit then
            table.remove(self.wait_to_trigger_hit, i)
            return param
        end
    end
end

return HeroBattleActionHandler