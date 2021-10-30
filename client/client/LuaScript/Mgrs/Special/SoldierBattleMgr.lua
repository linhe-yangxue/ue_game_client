local CSConst = require("CSCommon.CSConst")
local EventUtil = require("BaseUtilities.EventUtil")
local SoldierBattleMgr = class("Mgrs.Special.SoldierBattleMgr")

EventUtil.GeneratorEventFuncs(SoldierBattleMgr, "UpdateBothSoldier")
EventUtil.GeneratorEventFuncs(SoldierBattleMgr, "BattleEnd")

local enemy_attack = "zhengmian_attack"
local enemy_idle = "zhengmian_idle"
local enemy_run = "zhengmian_run"
local m_attack = "beimian_attack"
local m_idle = "beimian_idle"
local m_run = "beimian_run"

function SoldierBattleMgr:DoInit()
    self.soldier_state = {
        idle = 1,
        run = 2,
        attack = 3,
        die = 4,
    }
    self.attack_range = 250
    self.stop_move_soldier_num = 2
    self.judge_near_dis = 50
    self.attack_range_y_range = 200
    self.attack_range = self.attack_range * self.attack_range
    self.wait_to_end_time = 0.5
    self.gun_chance = 20
    self.create_effect_list = {}
end

function SoldierBattleMgr:InitBattle(battle_data)
    self:GetData()
    self.reduce_hp_countr = 0
    self.soldier_attack_anim_time = 0.3
    self.battle_anim_time = 0
    self.is_win = true
    self.is_start_battle = false
    self.is_start_kill = false
    self.die_anim_time = 0.2
    self.soldier_run_speed = 0
    self.timer = 0
    self.soldier_model_max_num = self.column_num * self.line_num
    self.own_soldier_list = {}
    self.own_soldier_state_tb = {}
    self.enemy_soldier_list = {}
    self.enemy_soldier_state_tb = {}
    self.soldier_list = {}
    self.wait_to_handle_list = {}

    self.attach_go = SpecMgrs.ui_mgr:GetUI("SoldierBattleUI").main_panel:FindChild("UnitParent")
    self.gun_sound = SpecMgrs.data_mgr:GetParamData("soldier_battle_gun").sound_id
    self.enemy_model_id = battle_data.enemy_model_id
    self.enemy_model_num = battle_data.enemy_model_num
    self.enemy_military_val = battle_data.enemy_military_val
    self.m_military_val = battle_data.m_military_val
    self.enemy_soldier_num = battle_data.enemy_soldier_num
    self.soldier_num = battle_data.m_soldier_num

    self.init_soldier_model_num = self:GetInitModelCount(self.soldier_num)
    self.low_level_model_uuid = nil
    self.high_level_model_uuid = nil
    self.low_level_model_num = 0
    self.high_level_model_num = 0
    self:GetSoldierModelLevelNum()
    local m_soldier_count = self:CreateSoldier(self.m_start_pos, self.m_end_pos, self.m_back_start_pos, self.m_back_end_pos, 1000, false)
    local enemy_soldier_count = self:CreateSoldier(self.enemy_start_pos, self.enemy_end_pos, self.enemy_back_start_pos, self.enemy_back_end_pos, self.enemy_model_id, true, self.enemy_model_num)
    self.max_soldier_modle_count = m_soldier_count + enemy_soldier_count
    self.cur_create_soldier_modle_count = 0
    self:UpdateSoldierSort()
    self:CaculateRunSpeed()
end

function SoldierBattleMgr:GetData()
    self.soldier_model_min_num = SpecMgrs.data_mgr:GetParamData("soldier_model_min_num").f_value
    self.soldier_min_num = SpecMgrs.data_mgr:GetParamData("soldier_min_num").f_value
    self.soldier_model_data = SpecMgrs.data_mgr:GetAllSoldierModelData()
    self.reduce_hp_time = SpecMgrs.data_mgr:GetParamData("soldier_finght_reduce_hp_time").f_value
    self.battle_min_time = SpecMgrs.data_mgr:GetParamData("soldier_finght_min_time").f_value
    self.battle_max_time = SpecMgrs.data_mgr:GetParamData("soldier_finght_max_time").f_value
    self.win_death_coefficient = SpecMgrs.data_mgr:GetParamData("soldier_finght_death_coefficient").f_value
    self.soldier_model_scale = SpecMgrs.data_mgr:GetParamData("soldier_model_scale").f_value

    self.line_num = SpecMgrs.data_mgr:GetParamData("soldier_line_num").f_value
    self.column_num = SpecMgrs.data_mgr:GetParamData("soldier_column_num").f_value
    self.run_time = SpecMgrs.data_mgr:GetParamData("soldier_walk_time").f_value

    self.m_start_pos = self:GetPosition("m_start_pos")
    self.m_end_pos = self:GetPosition("m_end_pos")
    self.m_back_start_pos = self:GetPosition("m_back_start_pos")
    self.m_back_end_pos = self:GetPosition("m_back_end_pos")

    self.enemy_start_pos = self:GetPosition("enemy_start_pos")
    self.enemy_end_pos = self:GetPosition("enemy_end_pos")
    self.enemy_back_start_pos = self:GetPosition("enemy_back_start_pos")
    self.enemy_back_end_pos = self:GetPosition("enemy_back_end_pos")
end

function SoldierBattleMgr:GetPosition(key)
    local pos_list = SpecMgrs.data_mgr:GetMapPosData(key).pos
    return Vector3(pos_list[1], pos_list[2], pos_list[3])
end

function SoldierBattleMgr:CaculateRunSpeed()
    local m_soldier = self.own_soldier_list[1]
    local hostile_list = self:GetHostileSoldierList(m_soldier)
    local target_pos, dis = self:GetNearestsoldierPos(m_soldier, hostile_list)
    self.soldier_run_speed = (math.sqrt(dis) / 2) / self.run_time
end

function SoldierBattleMgr:StartBattle(param_tb)
    if not param_tb then
        self.is_win = self.soldier_num / self.enemy_military_val > self.enemy_soldier_num / self.m_military_val
        if self.is_win then
            self.self_cost = self.enemy_soldier_num / self.m_military_val * self.enemy_military_val
            self.enemy_cost = self.enemy_soldier_num
        else
            self.enemy_cost = self.soldier_num / self.enemy_military_val * self.m_military_val
            self.self_cost = self.soldier_num
        end
    else
        self.is_win = param_tb.is_win
        self.self_cost = param_tb.self_cost
        self.enemy_cost = param_tb.enemy_cost
    end
    if self.is_win then
        self.battle_anim_time = self.enemy_soldier_num / self.m_military_val *
                                (self.enemy_model_num / self.init_soldier_model_num)
    else
        self.battle_anim_time = self.soldier_num / self.enemy_military_val *
                                (self.init_soldier_model_num / self.enemy_model_num)
    end
    self.battle_anim_time = math.clamp(self.battle_anim_time, self.battle_min_time, self.battle_max_time)
    self.is_start_battle = true
    self.start_reduce_time = self.run_time + self.soldier_attack_anim_time + self.timer
    self.reduce_hp_interval = self.battle_anim_time / self.reduce_hp_time
    self:CaculateKillsoldier()
end

function SoldierBattleMgr:Update(delta_time)
    if not self.timer then return end
    self.timer = self.timer + delta_time
    if self.wait_to_handle_list and #self.wait_to_handle_list > 0 then
        for i = #self.wait_to_handle_list, 1, -1 do
            local param = self.wait_to_handle_list[i]
            if not self.timer or self.timer > param.happen_time then
                param.handle_func()
                table.remove(self.wait_to_handle_list, i)
            end
        end
    end
    if not self.is_start_battle then return end
    if self.cur_create_soldier_modle_count < self.max_soldier_modle_count then return end
    self:UpdatesoldierAction(delta_time)
    self:UpdateSoldierSort()
    self:UpdateReduceBothSoldier(self.timer - self.start_reduce_time)
    self:UpdateKillSoldier(self.timer - self.start_reduce_time)
end

function SoldierBattleMgr:AddToWaitToHandleList(param, wait_time)
    param.happen_time = self.timer + wait_time
    table.insert(self.wait_to_handle_list, param)
end

function SoldierBattleMgr:CreateSoldier(start_pos, end_pos, back_start_pos, back_end_pos, model_id, is_enemy, create_count)
    local count = 0
    for i = 1, self.line_num do
        local line_start_pos = Vector3.Lerp(start_pos, back_start_pos, (i - 1)/(self.line_num - 1))
        local line_end_pos = Vector3.Lerp(end_pos, back_end_pos, (i - 1)/(self.line_num - 1))
        for i = 1, self.column_num do
            local pos = Vector3.Lerp(line_start_pos, line_end_pos, (i - 1) / (self.column_num - 1))
            local m_model_id = model_id
            if not is_enemy then
                if count >= self.high_level_model_num + self.low_level_model_num then
                    return count
                end
                if count < self.high_level_model_num then
                    m_model_id = self.high_level_model_uuid
                else
                    m_model_id = self.low_level_model_uuid
                end
            else
                if count >= create_count then
                    return count
                end
            end
            local unit = self:AddUnit(pos, m_model_id)
            if is_enemy then
                self.enemy_soldier_state_tb[unit] = self.soldier_state.idle
                table.insert(self.enemy_soldier_list, unit)
            else
                self.own_soldier_state_tb[unit] = self.soldier_state.idle
                table.insert(self.own_soldier_list, unit)
            end
            table.insert(self.soldier_list, unit)
            count = count + 1
        end
    end
    return count
end

function SoldierBattleMgr:AddUnit(pos, model_id)
    local param_tb = {}
    param_tb.unit_id = model_id
    param_tb.position = pos or Vector3(0, 0, 0)
    param_tb.layer_name = "UI"
    param_tb.scale = self.soldier_model_scale
    param_tb.parent = self.attach_go
    param_tb.position.z = 10
    local unit = ComMgrs.unit_mgr:CreateUnitAutoGuid(param_tb)
    unit:RegisterGoLoadedOkEvent("SoldierBattleMgr", function()
        self.cur_create_soldier_modle_count = self.cur_create_soldier_modle_count + 1
        unit:UnregisterGoLoadedOkEvent("SoldierBattleMgr")
    end)
    return unit
end

--  根据数量生成不同模型的小兵
function SoldierBattleMgr:GetSoldierModelLevelNum()
    local max_level = #self.soldier_model_data
    local level_num_tb = {}
    table.insert(level_num_tb, 0)
    for i = 1, max_level do
        local soldier_num = self.soldier_model_data[i].soldier_num
        local level_num = self.soldier_min_num + (self.soldier_model_max_num - self.soldier_model_min_num) * soldier_num
        table.insert(level_num_tb, level_num)
    end
    for i = 1, max_level do
        if self.soldier_num > level_num_tb[i] and self.soldier_num < level_num_tb[i + 1] then
            if i == 1 then
                self.low_level_model_uuid = self.soldier_model_data[i].model
                self.low_level_model_num = self:GetInitModelCount(self.soldier_num)
            else
                self.low_level_model_uuid = self.soldier_model_data[i - 1].model
                self.high_level_model_uuid = self.soldier_model_data[i].model
                self.high_level_model_num = (self.soldier_num - level_num_tb[i]) / self.soldier_model_data[i].soldier_num
                self.high_level_model_num = math.ceil(self.high_level_model_num)
                self.low_level_model_num = self.soldier_model_max_num - self.high_level_model_num
            end
            break
        end
        if i == max_level and self.soldier_num > level_num_tb[i + 1] then
            self.low_level_model_uuid = self.soldier_model_data[max_level].model
            self.low_level_model_num = self.soldier_model_max_num
        end
    end
end

function SoldierBattleMgr:GetInitModelCount(soldier_num)
    if soldier_num <= self.soldier_min_num then
        return self.soldier_model_min_num
    end
    local min_level_data = self.soldier_model_data[1]
    local ret
    ret = (soldier_num - self.soldier_min_num) / min_level_data.soldier_num + self.soldier_model_min_num
    ret = math.ceil(ret)
    return math.clamp(ret, self.soldier_model_min_num, self.soldier_model_max_num)
end

function SoldierBattleMgr:UpdatesoldierAction(delta_time)
    for i, unit in ipairs(self.soldier_list) do
        local m_pos = unit:GetPosition()
        local hostile_list = self:GetHostileSoldierList(unit)
        local friendly_list = self:GetOwnSoldierList(unit)
        local own_state_tb = self:GetOwnSoldierStateTb(unit)
        if own_state_tb[unit] ~= self.soldier_state.die then
            if not (own_state_tb[unit] == self.soldier_state.attack) then
                local last_state = own_state_tb[unit]
                local target_pos, dist, y_dis = self:GetNearestsoldierPos(unit, hostile_list)
                local friend_count = self:GetForwardFriendSoldier(unit, friendly_list)
                -- 前方有小兵，则停下
                if not target_pos or friend_count > self.stop_move_soldier_num then
                    -- idle
                    own_state_tb[unit] = self.soldier_state.idle
                elseif dist < self.attack_range and math.abs(y_dis) < self.attack_range_y_range then
                    -- attack 攻击完才动
                    local param = {}
                    param.handle_func = function()
                        self:FinishSoldierAttack(unit, friendly_list, own_state_tb)
                    end
                    self:AddToWaitToHandleList(param, self.soldier_attack_anim_time)
                    own_state_tb[unit] = self.soldier_state.attack
                    if not self.cur_gun_sound or self.cur_gun_sound.is_destroy then
                        self.cur_gun_sound = SpecMgrs.sound_mgr:PlaySpellSound(self.gun_sound)
                    end
                else
                    -- 走过去
                    own_state_tb[unit] = self.soldier_state.run
                    local dir = (target_pos - self:GetVector2Pos(m_pos)):Normalize()
                    m_pos = m_pos + dir * delta_time * self.soldier_run_speed
                    unit:SetPosition(m_pos)
                end
                if own_state_tb[unit] ~= last_state then
                    self:PlayUnitAnim(unit, own_state_tb[unit])
                end
            end
	    end
    end
end

function SoldierBattleMgr:FinishSoldierAttack(unit, friendly_list, own_state_tb)
    if self:IsSoldierActive(unit) then
        if self.is_start_battle then
            local index = table.index(friendly_list, unit)
            local all_num = #friendly_list
            local base_chance = 20
            local chance = base_chance + math.pow(((all_num - index + 1) / all_num), 2) * 50
            if math.random(0, 100) < chance then
                self:ShowHitEffect(unit)
            end
        end
        own_state_tb[unit] = self.soldier_state.idle
        self:PlayUnitAnim(unit, own_state_tb[unit])
    end
end

function SoldierBattleMgr:GetForwardFriendSoldier(unit, target_list)
    local is_enemy = self:IsEnemy(unit)
    local m_pos = self:GetVector2Pos(unit:GetPosition())
    local count = 0
    for i,unit in ipairs(target_list) do
        local pos = self:GetVector2Pos(unit:GetPosition())
        if not is_enemy then
            if pos.x > m_pos.x and Vector3.SqrDistance(m_pos, pos) < self.judge_near_dis then
                count = count + 1
            end
        else
            if pos.x < m_pos.x and Vector3.SqrDistance(m_pos, pos) < self.judge_near_dis then
                count = count + 1
            end
        end
    end
    return count
end

function SoldierBattleMgr:GetNearestsoldierPos(unit, target_list)
    if not next(target_list) then
        return nil, nil
    end
    local m_pos = self:GetVector2Pos(unit:GetPosition())
    local target_pos
    local min_distance = 1000000000
    local cur_index = 0
    for i , target_soldier in ipairs(target_list) do
        local pos = self:GetVector2Pos(target_soldier:GetPosition())
        if self:IsEnemy(unit) then
            pos = pos + Vector3(self.judge_near_dis, 0, 0) -- 走到敌人前方
        else
            pos = pos + Vector3(-self.judge_near_dis, 0, 0)
        end
        local distance = Vector3.SqrDistance(m_pos, pos)
        if distance < min_distance then
            min_distance = distance
            cur_index = i
            target_pos = pos
        end
    end
    local y_dis = target_list[cur_index]:GetPosition().y - m_pos.y
    return target_pos, min_distance, y_dis
end

function SoldierBattleMgr:GetHostileSoldierList(unit)
    if self.enemy_soldier_state_tb[unit] then
        return self.own_soldier_list
    else
        return self.enemy_soldier_list
    end
end

function SoldierBattleMgr:GetOwnSoldierList(unit)
    if self.enemy_soldier_state_tb[unit] then
        return self.enemy_soldier_list
    else
        return self.own_soldier_list
    end
end

function SoldierBattleMgr:GetOwnSoldierStateTb(unit)
    if self.enemy_soldier_state_tb[unit] then
        return self.enemy_soldier_state_tb
    else
        return self.own_soldier_state_tb
    end
end

function SoldierBattleMgr:GetVector2Pos(pos)
    return Vector3.New(pos.x, pos.y, 0)
end

function SoldierBattleMgr:IsEnemy(unit)
    return self.enemy_soldier_state_tb[unit]
end

function SoldierBattleMgr:IsSoldierActive(unit)
    if not unit then return false end
    return not unit.is_destroy and self:GetOwnSoldierStateTb(unit)[unit] ~= self.soldier_state.die
end

function SoldierBattleMgr:UpdateSoldierSort()
    table.sort(self.enemy_soldier_list, function(u1, u2)
        return u1:GetPosition().y < u2:GetPosition().y
    end)
    table.sort(self.own_soldier_list, function(u1, u2)
        return u1:GetPosition().y < u2:GetPosition().y
    end)
end

function SoldierBattleMgr:PlayUnitAnim(unit, state)
    local anim_name
    if state == self.soldier_state.idle then
        if self:IsEnemy(unit) then
            anim_name = enemy_idle
        else
            anim_name = m_idle
        end
    elseif state == self.soldier_state.attack then
        if self:IsEnemy(unit) then
            anim_name = enemy_attack
        else
            anim_name = m_attack
        end
    elseif state == self.soldier_state.run then
        if self:IsEnemy(unit) then
            anim_name = enemy_run
        else
            anim_name = m_run
        end
    elseif state == self.soldier_state.die then
        if self:IsEnemy(unit) then
            anim_name = enemy_idle
        else
            anim_name = m_idle
        end
    end
    unit:PlayAnim(anim_name, true)
end

function SoldierBattleMgr:ShowHitEffect(unit)
    if not self:IsSoldierActive(unit) then return end
    local scale = 1 / unit.go.localScale.x
    local target_go = unit.go
    local param_tb = {
        effect_id = 10001,
        pos = unit:GetUnitPointPos("hit_effect_pos", true),
        effect_type = CSConst.EffectType.ET_UI,
        attach_ui_go = target_go,
        scale = scale,
        --life_time = parm.life_time,
    }
    local effect = SpecMgrs.effect_mgr:CreateEffectAutoGuid(param_tb)
    table.insert(self.create_effect_list, effect)
    return effect
end

function SoldierBattleMgr:UpdateReduceBothSoldier(timer)
    if timer > self.reduce_hp_countr * self.reduce_hp_interval then
        self:ReduceBothSoldier()
    end
end

function SoldierBattleMgr:ReduceBothSoldier()
    if self.reduce_hp_countr > self.reduce_hp_time then return end
    local m_cur_soldier_num = self.soldier_num
    local enemy_cur_soldier_num = self.enemy_soldier_num
    self.reduce_hp_countr = self.reduce_hp_countr + 1
    m_cur_soldier_num = m_cur_soldier_num - self.reduce_hp_countr * (self.self_cost / self.reduce_hp_time)
    enemy_cur_soldier_num = enemy_cur_soldier_num - self.reduce_hp_countr * (self.enemy_cost / self.reduce_hp_time)

    m_cur_soldier_num = math.ceil(m_cur_soldier_num)
    enemy_cur_soldier_num = math.ceil(enemy_cur_soldier_num)

    self:DispatchUpdateBothSoldier(m_cur_soldier_num, enemy_cur_soldier_num)
    if self.reduce_hp_countr == self.reduce_hp_time then
        self:KillAllLostSoldier()
        self.is_start_battle = false
        for i, unit in ipairs(self.soldier_list) do
            if self:IsSoldierActive(unit) then
                self:PlayUnitAnim(unit, self.soldier_state.idle)
            end
        end
        local param = {}
        param.handle_func = function()
            self:DispatchBattleEnd(self.is_win)
            self.timer = nil
        end
        self:AddToWaitToHandleList(param, self.wait_to_end_time)
    end
end

function SoldierBattleMgr:UpdateKillSoldier(timer)
    if self.cur_lost_kill_soldier_num < self.kill_lost_soldier_num and timer > self.cur_lost_kill_soldier_num * self.kill_lost_soldier_interval then
        self:Killsoldier(true, self.lost_soldier_list)
        self.cur_lost_kill_soldier_num = self.cur_lost_kill_soldier_num + 1
    end
    if self.cur_win_kill_soldier_num < self.kill_win_soldier_num and timer > self.kill_win_soldier_interval * self.cur_win_kill_soldier_num then
        self:Killsoldier(false, self.win_soldier_list)
        self.cur_win_kill_soldier_num = self.cur_win_kill_soldier_num + 1
    end
end

function SoldierBattleMgr:CaculateKillsoldier()
    if self.is_win then
        self.win_soldier_list = self.own_soldier_list
        self.lost_soldier_list = self.enemy_soldier_list
    else
        self.win_soldier_list = self.enemy_soldier_list
        self.lost_soldier_list = self.own_soldier_list
    end
    local dead_num = math.floor(self.battle_anim_time / self.win_death_coefficient * #self.win_soldier_list)

    self.kill_lost_soldier_interval = self.battle_anim_time / #self.lost_soldier_list
    self.kill_lost_soldier_num = #self.lost_soldier_list
    self.cur_lost_kill_soldier_num = 0

    self.kill_win_soldier_interval = self.battle_anim_time / dead_num
    self.kill_win_soldier_num = dead_num
    self.cur_win_kill_soldier_num = 0
end

--  敌人从上到下销毁，己方从下到上销毁
function SoldierBattleMgr:Killsoldier(is_enemy, target_list)
    if not next(target_list) then
        return
    end
    -- if is_enemy then
    --     table.sort(target_list, function(u1, u2)
    --         return u1:GetPosition().y > u2:GetPosition().y
    --     end)
    -- else
    --     table.sort(target_list, function(u1, u2)
    --         return u1:GetPosition().y < u2:GetPosition().y
    --     end)
    -- end
    local kill_unit
    for i , unit in ipairs(target_list) do
        local own_state_tb = self:GetOwnSoldierStateTb(unit)
        if own_state_tb[unit] == self.soldier_state.attack then
            kill_unit = unit
            own_state_tb[unit] = self.soldier_state.die
            self:ShowHitEffect(kill_unit)
            break
        end
    end
    self:DestroySoldier(kill_unit)
end

function SoldierBattleMgr:EndBattle()
    if self.cur_gun_sound then
        SpecMgrs.sound_mgr:DestroySound(self.cur_gun_sound)
        self.cur_gun_sound = nil
    end
    if self.soldier_list then
        for i , unit in ipairs(self.soldier_list) do
            ComMgrs.unit_mgr:DestroyUnit(unit)
        end
    end
    self.soldier_list = {}
    if self.create_effect_list then
        for i, effect in ipairs(self.create_effect_list) do
            SpecMgrs.effect_mgr:DestroyEffect(effect)
        end
    end
    self.create_effect_list = {}
end

function SoldierBattleMgr:KillAllLostSoldier()
    local target_list
    if self.is_win then
        target_list = self.enemy_soldier_list
    else
        target_list = self.own_soldier_list
    end
    for i, unit in ipairs(target_list) do
        self:DestroySoldier(unit)
    end
end

function SoldierBattleMgr:DestroySoldier(kill_unit)
    if kill_unit then
        local param = {}
        param.handle_func = function()
            self:_DestroySoldier(kill_unit)
        end
        self:AddToWaitToHandleList(param, self.die_anim_time)
    end
end

function SoldierBattleMgr:_DestroySoldier(kill_unit)
    if kill_unit.is_destroy then
        return
    end
    local target_list = self:GetOwnSoldierList(kill_unit)
    if self.enemy_soldier_state_tb[kill_unit] then
        self.enemy_soldier_state_tb[kill_unit] = nil
    else
        self.own_soldier_state_tb[kill_unit] = nil
    end
    local index = table.index(self.soldier_list, kill_unit)
    table.remove(self.soldier_list, index)
    local index = table.index(target_list, kill_unit)
    table.remove(target_list, index)
    ComMgrs.unit_mgr:DestroyUnit(kill_unit)
end

function SoldierBattleMgr:DoDestroy()
end

return SoldierBattleMgr