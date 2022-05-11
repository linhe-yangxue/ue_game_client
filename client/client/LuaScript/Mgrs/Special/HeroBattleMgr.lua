local FConst = require("CSCommon.Fight.FConst")
local Game = require("CSCommon.Fight.Game")
local UnitConst = require("Unit.UnitConst")
local CSConst = require("CSCommon.CSConst")
local HeroBattleActionHandler = require("HeroFight.HeroBattleActionHandler")
local Spell = require("HeroFight.Spell")
local EventUtil = require("BaseUtilities.EventUtil")

local HeroBattleMgr = class("Mgrs.Special.HeroBattleMgr")

EventUtil.GeneratorEventFuncs(HeroBattleMgr, "UpdateRound")
EventUtil.GeneratorEventFuncs(HeroBattleMgr, "BattleEnd")

local speed_list = {
    1,
    1.5,
    3,
}

local BattleArrayLuaName = "Data.SpellData.BattleParam"
local dir_dis = 3
local default_resolution_x = 1080
local default_resolution_y = 1920
local default_camera_view_size = 50

local hud_offset = Vector3.New(0, 50, 0)
local unit_normal_color = Color.New(1, 1, 1, 1)
local unit_disappear_color = Color.New(1, 1, 1, 0)

--  增加buff只会在技能过程中发生
function HeroBattleMgr:DoInit()
    self.hero_max_num = 6
    self.unit_hp = 2000
    self.pos_z = 10
    self.is_start_battle = false
    self.spell_interval = 0.25
    self.death_spell_id = SpecMgrs.data_mgr:GetParamData("death_skill").spell_id
end

function HeroBattleMgr:InitBattle(battle_data)
    if not battle_data then
        return
    end
    self.fight_data = battle_data
    SpecMgrs.ui_mgr:ShowUI("SpecialUI")

    self.effect_ui = SpecMgrs.ui_mgr:GetUI("EffectUI")
    if not self.effect_ui then
        self.effect_ui = SpecMgrs.ui_mgr:ShowUI("EffectUI")
    end
    self.effect_attach_go = self.effect_ui.main_panel
    self.battle_bg = SpecMgrs.ui_mgr:GetUI("HeroBattleUI").go:FindChild("Bg"):GetComponent("Image")
    self.battle_bg.color = Color.white

    self.battle_mask = SpecMgrs.ui_mgr:GetUI("HeroBattleUI").go:FindChild("Mask"):GetComponent("Image")
    self.battle_mask.color = Color.New(0, 0, 0, 0)

    self.all_sort_obj_list = {}
    self.battle_action_list = {}
    self.own_unit_list = {}
    self.enemy_unit_list = {}
    self.own_pos_list = {}
    self.enemy_pos_list = {}
    self.delay_func_list = {}
    self.unit_buff_effect_tb = {}
    self.delay_kill_list = {}
    self.own_forward_dir = Vector3.zero
    self.enemy_forward_dir = Vector3.zero
    self.timer_mgr = SpecMgrs.timer_mgr
    self.unit_move_action_list = {}
    self.is_start_spell = false
    self.cur_cast_spell = 0
    self.all_unit_list = {}
    self.is_start_battle = true
    self.cur_action_index = 1
    self.cur_speed_num = ComMgrs.dy_data_mgr:EXGetHeroBattleSpeed()
    if self.is_editor_play then
        self.cur_speed = speed_list[1]
    else
        --self.cur_speed = speed_list[2]
        --速度与显示相匹配
        self.cur_speed = speed_list[self.cur_speed_num]
    end
    self.action_timer = 0

    self.action_handler = HeroBattleActionHandler:New()
    self.action_handler:DoInit(self)

    self.cur_spell = nil

    self.fight_game = Game.New(self.fight_data, function(event_type, ...)
        local parm_tb = {...}
        parm_tb.event_type = event_type
        parm_tb.happen_time = 0
        table.insert(self.battle_action_list, parm_tb)
    end)

    self.is_win = self.fight_game:GoToFight()
    self.hurt_info = self.fight_game:GetFightHurtInfo()
    self:CreateHero(self.fight_data.own_fight_data , false)
    self:CreateHero(self.fight_data.enemy_fight_data , true)
    self:StartBattle()
    self.own_forward_dir = (self.own_pos_list[2] - self.own_pos_list[5]):Normalize() * dir_dis
    self.enemy_forward_dir = (self.enemy_pos_list[2] - self.enemy_pos_list[5]):Normalize() * dir_dis

    self.own_left_dir =  (self.own_pos_list[1] - self.own_pos_list[2]):Normalize() * dir_dis
    self.own_right_dir = -self.own_left_dir
    UnityEngine.Time.timeScale = self.cur_speed

    self.x_dir = Vector3.New(self.own_right_dir.y, -self.own_right_dir.x, 0):Normalize()
    self:AdaptResolution()
end

function HeroBattleMgr:AdaptResolution() -- 自适应
    self.main_camera = GameObject.Find("Main Camera"):GetComponent("Camera")
    local aspect_ratio = default_resolution_y / default_resolution_x

    local cur_aspect_ratio = Screen.height / Screen.width

    if cur_aspect_ratio > aspect_ratio then
        self.main_camera.orthographicSize = default_camera_view_size * cur_aspect_ratio / aspect_ratio
    else
        self.main_camera.orthographicSize = default_camera_view_size
    end
end

function HeroBattleMgr:StartBattle()
    local action = self:GetCurAction()
    action.happen_time = self.action_timer + 1
end

function HeroBattleMgr:Update(delta_time)
    if not self.is_start_battle then return end
    self.action_timer = self.action_timer + delta_time
    local action = self:GetCurAction()
    if self.action_timer > action.happen_time then
        local happen_time = 0

        while self.action_timer > happen_time do
            action = self:GetCurAction()
            if action.event_type == "SpellEnd" and self.cur_spell then
                break
            end
            local not_finish_action = self.action_handler:HandleAction(action)
            if not_finish_action then
                happen_time = action.happen_time
            else
                self:FinishCurAction()
                action = self:GetCurAction()
                if not action then
                    break
                end
                happen_time = action.happen_time
            end
        end
    end
    local index = 1
    while index <= #self.delay_func_list do
        if self.action_timer >= self.delay_func_list[index].happen_time then
            self.delay_func_list[index].func()
            table.remove(self.delay_func_list, index)
        else
            index = index + 1
        end
    end

    if self.cur_spell then --  这里需要先执行action 所以技能初始化后下一帧在播放
        if self.cur_spell.is_init then
            self.cur_spell.is_init = false
        else
            if self.cur_spell:Update(delta_time) then
                self:ClearCurSpell()
            end
        end
    end
    self:UpdateObjSort()

    for i = #self.delay_kill_list, 1, -1 do
        local data = self.delay_kill_list[i]
        if data.death_spell:Update(delta_time) then
            data.death_spell:SpellEnd()
            self:KillUnit(data.unit)
            table.remove(self.delay_kill_list, i)
        end
    end
end

function HeroBattleMgr:ClearCurSpell()
    SpecMgrs.ui_mgr:GetUI("HudUI"):DelComboItem(self.spell_hit_id)
    self.cur_spell:SpellEnd()
    self.cur_spell = nil
end

function HeroBattleMgr:AddDelayFunc(func, happen_time)
    if self.action_timer >= happen_time then
        func()
        return
    end
    local param = {
        func = func,
        happen_time = happen_time,
    }
    table.insert(self.delay_func_list, param)
end

function HeroBattleMgr:SetPlaySpeed(speed)
    self.cur_speed = speed_list[speed]
    UnityEngine.Time.timeScale = self.cur_speed
end

function HeroBattleMgr:ClearAll()
    if self.cur_spell and self.spell_hit_id then
        if SpecMgrs.ui_mgr:GetUI("HudUI") then
            SpecMgrs.ui_mgr:GetUI("HudUI"):DelComboItem(self.spell_hit_id)
        end
    end
    if not self.all_unit_list then
        return
    end
    for i, unit in ipairs(self.all_unit_list) do
        if next(unit) then
            ComMgrs.unit_mgr:DestroyUnit(unit)
            unit = {}
        end
    end
end

function HeroBattleMgr:SkipBattle()
    local own_result_info = self.fight_game:GetFightResultUnitInfo(FConst.Side.Own)
    local enemy_result_info = self.fight_game:GetFightResultUnitInfo(FConst.Side.Enemy)
    if self.cur_spell then
        self:ClearCurSpell()
    end
    self:ClearAll()
    self:SetFightData(self.fight_data.own_fight_data, own_result_info)
    self:SetFightData(self.fight_data.enemy_fight_data, enemy_result_info)
    self:CreateHero(self.fight_data.own_fight_data, false)
    self:CreateHero(self.fight_data.enemy_fight_data , true)
    self:DispatchUpdateRound(self.fight_game.curr_round_num)
    self:GameEnd(self.is_win)
end

function HeroBattleMgr:SetFightData(fight_data, enemy_result_info)
    for i, unit_info in ipairs(enemy_result_info) do
        fight_data[i].cur_anger = math.floor(unit_info.cur_anger)
        fight_data[i].fight_attr_dict.hp = math.floor(unit_info.hp)
        fight_data[i].fight_attr_dict.max_hp = math.floor(unit_info.max_hp)
    end
end

function HeroBattleMgr:UpdateObjSort()
    local length = #self.all_sort_obj_list
    for i = length, 1, -1 do
        local obj = self.all_sort_obj_list[i]
        if next(obj) and not IsNil(obj.go) then
            local pos = obj.go.position
            local x0 = pos.x
            local y0 = pos.y
            local x1 = self.x_dir.x
            local y1 = self.x_dir.y
            --  转换坐标系
            local x = (x0 * x1 + y0 * y1) / (x1 * x1 + y1 * y1)
            pos = Vector3.New(pos.x, pos.y, -x)
            obj.go.position = pos
        else
            table.remove(self.all_sort_obj_list, i)
        end
    end
end

function HeroBattleMgr:AddToSortObjList(obj)
    table.insert(self.all_sort_obj_list, obj)
end

function HeroBattleMgr:DoDestroy()
    self:ClearAll()
end
-------------------------事件播放-------------------------

function HeroBattleMgr:SetNextActionHappenTime(happen_time)
    if not self.battle_action_list[self.cur_action_index + 1] then return end
    self.battle_action_list[self.cur_action_index + 1].happen_time = self.action_timer + happen_time
end

function HeroBattleMgr:GetNextAction(index)
    index = index or self.cur_action_index + 1
    return self.battle_action_list[index]
end

function HeroBattleMgr:FinishCurAction()
    self.cur_action_index = self.cur_action_index + 1
end

function HeroBattleMgr:GetCurAction()
    return self.battle_action_list[self.cur_action_index]
end

function HeroBattleMgr:GetLastAction()
    return self.battle_action_list[self.cur_action_index - 1]
end

function HeroBattleMgr:CastSpell(unit_side, unit_pos, spell_id, anger_diff)
    self.is_start_spell = true
    self.cur_cast_spell_time = self.action_timer
    self.cur_cast_unit = self:GetUnit(unit_side, unit_pos)
    self.cur_cast_unit:ShowOrHideInfo(false)
    self.cur_cast_spell = spell_id
    self.cur_anger_diff = anger_diff
    self.cur_hit = nil
    self.spell_hit_id = spell_id .. self.action_timer -- 连击唯一标志
    self.cur_spell = self:CreateSpell(spell_id, self.cur_cast_unit, self:GetSpellTargetList(), anger_diff)
end

function HeroBattleMgr:TriggerHit(target_unit)
    local param = self.action_handler:GetTargetHit(target_unit)
    if param then
        self:SpellHit(table.unpack(param, 2, #param))
        return true
    end
end

function HeroBattleMgr:ShowInvalidBuff(side, pos)
    local unit = self:GetUnit(side, pos)
    if not next(unit) then return end
    SpecMgrs.ui_mgr:ShowHud(
    {
        hud_type = UnitConst.UNITHUD_TYPE.InvalidBuff,
        point_go = unit.go:FindChild("UnitInfo"),
        offset = hud_offset,
        is_in_battle = true,
    })
end

function HeroBattleMgr:SpellHit(side, pos, is_crit, hp_diff, is_miss, is_second_kill)
    local attacked_unit = self:GetUnit(side, pos)
    if not attacked_unit or attacked_unit:GetHp() <= 0 or not hp_diff then return end
    if hp_diff < 0 and not is_miss then
        local param_tb = {
            guid = self.spell_hit_id,
            value = math.abs(hp_diff),
            hud_type = UnitConst.UNITHUD_TYPE.Combo,
            is_in_battle = true,
        }
        if is_second_kill then
            param_tb.value = 0
        end
        SpecMgrs.ui_mgr:ShowHud(param_tb)
    end
    if hp_diff >= 0 then
        SpecMgrs.ui_mgr:ShowHud(
            {
                guid = self.spell_hit_id,
                value = math.abs(hp_diff),
                hud_type = UnitConst.UNITHUD_TYPE.TotalCure,
                is_in_battle = true,
            }
        )
    end
    self:HandleUnitHpDiff(attacked_unit, is_crit, hp_diff, is_miss, is_second_kill)
end

function HeroBattleMgr:TriggerBuff(side, pos, hp_diff)
    local target_unit = self:GetUnit(side, pos)
    if not next(target_unit) or target_unit:GetHp() <= 0 or not hp_diff then return end
    if hp_diff ~= nil then
        self:HandleUnitHpDiff(target_unit, false, hp_diff)
        self:CaculateDeath()
    end
end

function HeroBattleMgr:RemoveBuff(side, pos, buff_id)
    local unit = self:GetUnit(side, pos)
    local effect_id = SpecMgrs.data_mgr:GetBuffData(buff_id).effect_id
    local effect = self.unit_buff_effect_tb[unit][effect_id]
    if effect then
        SpecMgrs.effect_mgr:DestroyEffect(effect)
        self.unit_buff_effect_tb[unit][effect_id] = nil
    end
end

function HeroBattleMgr:AddBuff(side, pos, buff_id)
    local unit = self:GetUnit(side, pos)
    local effect_id = SpecMgrs.data_mgr:GetBuffData(buff_id).effect_id
    if self.unit_buff_effect_tb[unit][effect_id] then return end
    local parm = {
        effect_id = effect_id,
        unit = unit,
        pos = unit:GetPosition(),
        target_go = unit.go,
        pos_z = Spell.buff_index,
    }
    local effect = self:CreateNormalEffect(parm)
    self.unit_buff_effect_tb[unit][effect_id] = effect
end

function HeroBattleMgr:GetSpellTargetList()
    local ret = {}
    local index = self.cur_action_index
    local action = self:GetNextAction(index)
    while action.event_type ~= FConst.EventType.SpellEnd do
        if action.event_type == FConst.EventType.SpellHit then
            local hit_segment = action[3]
            if not ret[hit_segment] then
                ret[hit_segment] = {}
            end
            local unit = self:GetUnit(action[1], action[2])
            if not table.contains(ret[hit_segment], unit) then
                table.insert(ret[hit_segment], unit)
            end
        end
        index = index + 1
        action = self:GetNextAction(index)
    end
    return ret
end

function HeroBattleMgr:RoundEnd(round_num)

end

function HeroBattleMgr:RoundStart(round_num)
    self:DispatchUpdateRound(round_num)
end

function HeroBattleMgr:GameEnd(is_win)
    self.is_start_battle = false
    UnityEngine.Time.timeScale = 1
    if not self.is_editor_play then
        self:DispatchBattleEnd(is_win)
    end
end

function HeroBattleMgr:CaculateDeath()
    for i, unit in ipairs(self.all_unit_list) do
        if next(unit) and not unit.is_destroy and unit:GetHp() <= 0 then
            local spell_id = self.death_spell_id
            local spell = self:CreateSpell(spell_id, unit, {[1] = {[1] = unit}})
            table.insert(self.delay_kill_list, {unit = unit, timer = 0, death_spell = spell})
        end
    end
end

function HeroBattleMgr:CreateSpell(spell_id, cast_unit, target_unit_tb, anger_diff)
    local spell = Spell:New()
    local spell_lua_name = "Data.SpellData.SpellData_" .. spell_id
    local spell_data
    if self.is_editor_play then
        spell_data = dofile(spell_lua_name).groups
    else
        spell_data = require(spell_lua_name).groups
    end
    spell:DoInit(self, spell_data, spell_id, cast_unit, anger_diff or 0, target_unit_tb)
    return spell
end

-------------------------事件播放-------------------------
function HeroBattleMgr:CreateHero(hero_list, is_enemy)
    for i = 1, self.hero_max_num do
        local hero_data = hero_list[i]
        local unit = {}
        local pos
        if not self.battle_param then
            self.battle_param = require(BattleArrayLuaName)
        end
        if not self.pos_tb then
            self:CaculateHeroPos()
        end

        --  布阵位置
        if self.battle_param then
            local both_side_dis = self.battle_param.both_side_dis
            local hero_dis_forward_behind = self.battle_param.hero_dis_forward_behind
            if is_enemy then
                pos = self.pos_tb[i]
            else
                if i > 3 then
                    local dir = (self.pos_tb[i - 3] - self.pos_tb[i]):Normalize() * (both_side_dis + hero_dis_forward_behind)
                    pos = self.pos_tb[i - 3] + dir
                else
                    local dir = (self.pos_tb[i] - self.pos_tb[i + 3]):Normalize() * both_side_dis
                    pos = self.pos_tb[i] + dir
                end
            end
        else
            PrintError("无布阵位置")
        end
        if next(hero_data) then
            local hp = hero_data.fight_attr_dict.hp == nil and hero_data.fight_attr_dict.max_hp or hero_data.fight_attr_dict.hp
            if hp > 0 then
                local anger
                if hero_data.cur_anger then
                    anger = hero_data.cur_anger
                elseif hero_data.add_anger then
                    anger = hero_data.add_anger + FConst.InitAnger
                else
                    anger = FConst.InitAnger
                end
                unit = self:AddUnit(pos, hero_data.unit_id, hero_data.fight_attr_dict, anger, is_enemy, hero_data.monster_id)
            end
        end
        self.unit_buff_effect_tb[unit] = {}
        table.insert(self.all_unit_list, unit)
        table.insert(self.all_sort_obj_list, unit)
        if is_enemy then
            table.insert(self.enemy_unit_list, unit)
            table.insert(self.enemy_pos_list, pos)
        else
            table.insert(self.own_unit_list, unit)
            table.insert(self.own_pos_list, pos)
        end
    end
end

function HeroBattleMgr:CaculateHeroPos()
    if self.battle_param then
        local angle = self.battle_param.first_column_angle
        local angle1 = self.battle_param.second_column_angle
        local dis_x = self.battle_param.dis_x
        local dis_y = self.battle_param.dis_y
        local hero_dis_left_right = self.battle_param.hero_dis_left_right
        local hero_dis_forward_behind = self.battle_param.hero_dis_forward_behind

        angle = math.rad(angle)
        angle1 = math.rad(angle1)
        local dis_tb =
        {
            [1] = Vector3(0, 0, 0),
            [2] = Vector3(1 * math.cos(angle), -1 * math.sin(angle), 0),
            [3] = Vector3(2 * math.cos(angle), -2 * math.sin(angle), 0),
            [4] = Vector3(0, 0, 0),
            [5] = Vector3(0, 0, 0),
            [6] = Vector3(0, 0, 0),
        }

        self.pos_tb = {}
        for i, v in ipairs(dis_tb) do
            self.pos_tb[i] = Vector3.New(dis_x, dis_y, 0) + v * hero_dis_left_right
            if i > 3 then
                self.pos_tb[i] = self.pos_tb[i - 3] + Vector3.New(math.sin(angle1), math.cos(angle1), 0) * hero_dis_forward_behind
            end
        end
    end
end

-------------------------Unit-------------------------

function HeroBattleMgr:AddUnit(pos, model_id, hero_data, anger, is_flip_x, monster_id)
    local param_tb = {}
    param_tb.unit_id = model_id
    param_tb.position = pos or Vector3(0, 0, self.pos_z)
    param_tb.scale = self.battle_param and self.battle_param.unit_size or 1
    param_tb.show_info = true
    param_tb.anger = anger
    param_tb.max_hp = hero_data.max_hp
    param_tb.hp = hero_data.hp == nil and hero_data.max_hp or hero_data.hp
    param_tb.is_flip_x = is_flip_x
    param_tb.is_show_shadow = true
    param_tb.need_sync_load = true
    param_tb.is_3D_model = true
    param_tb.monster_id = monster_id
    local unit = ComMgrs.unit_mgr:CreateUnitAutoGuid(param_tb)
    return unit
end

function HeroBattleMgr:GetUnit(side, pos)
    local ret
    if side == FConst.Side.Own then
        ret = self.own_unit_list[pos]
    else
        ret = self.enemy_unit_list[pos]
    end
    return ret
end

function HeroBattleMgr:GetUnitSidePos(unit)
    if table.contains(self.own_unit_list, unit) then
        return FConst.Side.Own, table.index(self.own_unit_list, unit)
    else
        return FConst.Side.Enemy, table.index(self.enemy_unit_list, unit)
    end
end

function HeroBattleMgr:GetUnitList(is_own)
    if is_own then
        return self.own_unit_list
    else
        return self.enemy_unit_list
    end
end

function HeroBattleMgr:GetUnitPosList(is_own)
    if is_own then
        return self.own_pos_list
    else
        return self.enemy_pos_list
    end
end

function HeroBattleMgr:GetUnitByAction(action)
    return self:GetUnit(action.side, action.pos)
end

function HeroBattleMgr:GetUnitForwardPos(unit)
    local pos
    if self:IsOwnUnit(unit)  then
        pos = self.own_forward_dir
    else
        pos = self.enemy_forward_dir
    end
    return unit:GetPosition() + pos
end

function HeroBattleMgr:GetForwardDir(is_own)
    if is_own then
        return self.own_forward_dir
    else
        return self.enemy_forward_dir
    end
end

function HeroBattleMgr:GetLeftRightDir(unit, is_left)
    if self:IsOwnUnit(unit)  then
        if is_left then
            return self.own_left_dir
        else
            return self.own_right_dir
        end
    else
        if is_left then
            return -self.own_left_dir
        else
            return -self.own_right_dir
        end
    end
end

function HeroBattleMgr:GetUnitListMiddlePos(is_own, is_forward)
    local unit
    if is_own then
        if is_forward then
            return self.own_pos_list[2], self.own_unit_list[2]
        else
            return self.own_pos_list[5], self.own_unit_list[5]
        end
    else
        if is_forward then
            return self.enemy_pos_list[2], self.enemy_unit_list[2]
        else
            return self.enemy_pos_list[5], self.enemy_unit_list[5]
        end
    end
end

function HeroBattleMgr:GetUnitStartPos(unit)
    if self:IsOwnUnit(unit) then
        return self.own_pos_list[table.index(self.own_unit_list, unit)]
    else
        return self.enemy_pos_list[table.index(self.enemy_unit_list, unit)]
    end
end

function HeroBattleMgr:GetUnitStancePos(unit)
    if self:IsOwnUnit(unit)  then
        return table.index(self.own_unit_list, unit)
    else
        return table.index(self.enemy_unit_list, unit)
    end
end

function HeroBattleMgr:GetTargetColumnBackRow(target)
    local index
    local is_own = self:IsOwnUnit(target)
    if self:IsOwnUnit(target) then
        index = table.index(self.own_unit_list, target)
        if index < 3 then
            index = index + 3
        end
    else
        index = table.index(self.enemy_unit_list, target)
        if index < 3 then
            index = index + 3
        end
    end
    local unit = self:GetUnitList(is_own)[index]
    if not next(unit) then
        unit = target
    end
    return self:GetPosListByUnit(target)[index], unit
end

function HeroBattleMgr:GetUnitChargeTarget(unit_target_list)
    local sort_list = {2, 1, 3, 5, 4, 6} -- 优先冲到中间角色前
    for i, unit in ipairs(unit_target_list) do
        local index = table.index(sort_list, self:GetUnitStancePos(unit))
        sort_list[index] = unit
    end
    for i, v in ipairs(sort_list) do
        if type(v) ~=  "number" then
            return v
        end
    end
end

--  合击对象
function HeroBattleMgr:GetTogetherAttackUnit(unit, spell_id)
    local unit_id = SpecMgrs.data_mgr:GetSpellData(spell_id).spell_unit_list[1]
    local unit_list = self:GetUnitList(self:IsOwnUnit(unit))
    for i, unit in ipairs(unit_list) do
        if unit.unit_id == unit_id then
            return unit
        end
    end
end

function HeroBattleMgr:GetAllAttackTargetPos(cast_unit)
    local pos_list = self:GetUnitPosList(not self:IsOwnUnit(cast_unit)) --敌人
    return {self:GetMiddlePos(pos_list, 1, 4), self:GetMiddlePos(pos_list, 2, 5), self:GetMiddlePos(pos_list, 3, 6)}
end

function HeroBattleMgr:GetMiddlePos(pos_list, val1, val2)
    return (pos_list[val1] + pos_list[val2]) / 2
end

--  前排
function HeroBattleMgr:GetUnitFrontPos(unit)
    if self:IsOwnUnit(unit) then
        local index = table.index(self.own_unit_list, unit)
        if index > 3 then
            return self.own_pos_list[index -3]
        else
            return self.own_pos_list[index]
        end
    else
        local index = table.index(self.enemy_unit_list, unit)
        if index > 3 then
            return self.enemy_pos_list[index -3]
        else
            return self.enemy_pos_list[index]
        end
    end
end

function HeroBattleMgr:GetTargetSameColumnFront(cast_unit, target)  -- 可能删除
    local index
    if self:IsOwnUnit(target) then
        index = table.index(self.own_unit_list, target)
        if index > 3 then
            index = index - 3
        end
    else
        index = table.index(self.enemy_unit_list, target)
        if index > 3 then
            index = index -3
        end
    end
    return self:GetPosListByUnit(cast_unit)[index]
end

function HeroBattleMgr:GetPosListByUnit(target)
    if self:IsOwnUnit(target) then
        return self.own_pos_list
    else
        return self.enemy_pos_list
    end
end

function HeroBattleMgr:GetUnitPos(target_unit)
    if self:IsOwnUnit(target_unit) then
        return table.index(self.own_unit_list, target_unit)
    else
        return table.index(self.enemy_unit_list, target_unit)
    end
end

function HeroBattleMgr:GetEnemyMiddlePos(unit, enemy_list)
    local is_forward = self:IsUnitListHaveFrontrow(enemy_list)
    local dir = self:GetForwardDir(not self:IsOwnUnit(unit))
    local pos = self:GetUnitListMiddlePos(not self:IsOwnUnit(unit), is_forward)
    return pos
end

function HeroBattleMgr:IsUnitListHaveFrontrow(unit_list)
    for i, unit in ipairs(unit_list) do
        local list = self:GetUnitList(self:IsOwnUnit(unit))
        local index = table.index(list, unit)
        if index <= 3 then
            return true
        end
    end
    return false
end

function HeroBattleMgr:GetUnitListColumn(unit)-- 目标同列 仅用于单体和同列攻击
    local list = self:GetUnitList(self:IsOwnUnit(unit))
    local index = table.index(list, unit)
    if index > 3 then
        index = index - 3
    end
    return index
end

function HeroBattleMgr:GetAllExistUnitList()
    local ret = {}
    for i, unit in ipairs(self.all_unit_list) do
        if next(unit) then
            table.insert(ret, unit)
        end
    end
    return ret
end

function HeroBattleMgr:KillUnit(unit)
    if self:IsOwnUnit(unit) then
        local index = table.index(self.own_unit_list, unit)
        self.own_unit_list[index] = {}
    end
    if table.contains(self.enemy_unit_list, unit) then
        local index = table.index(self.enemy_unit_list, unit)
        self.enemy_unit_list[index] = {}
    end
    for effect_id, effect in pairs(self.unit_buff_effect_tb[unit]) do
        SpecMgrs.effect_mgr:DestroyEffect(effect)
    end
    ComMgrs.unit_mgr:DestroyUnit(unit)
end

function HeroBattleMgr:IsOwnUnit(unit)
    if self.cur_spell and self.cur_spell.create_ghost_tb[unit] then
        return table.contains(self.own_unit_list, self.cur_spell.cur_cast_unit)
    end
    return table.contains(self.own_unit_list, unit)
end
-------------------------Unit-------------------------

function HeroBattleMgr:CreateNormalEffect(parm)
    local scale = parm.unit and 1 / parm.unit.go.localScale.x or 1
    scale = scale * (parm.scale or 1)
    local param_tb = {
        effect_id = parm.effect_id,
        pos = Vector3.New(parm.pos.x, parm.pos.y, parm.pos_z or 0),
        effect_type = CSConst.EffectType.ET_3D,
        target_go = parm.target_go,
        scale = scale,
        life_time = parm.life_time,
        keep_world_pos = true,
        euler = parm.euler,
        need_sync_load = true,
    }
    local effect = SpecMgrs.effect_mgr:CreateEffectAutoGuid(param_tb)
    if not parm.pos_z then
        table.insert(self.all_sort_obj_list, effect)
    end
    return effect
end

function HeroBattleMgr:HandleUnitHpDiff(unit, is_critical, val, is_miss, is_second_kill)
    local cur_hp = math.clamp(unit:GetHp() + val, 0, unit:GetMaxHp())
    unit:SetHp(cur_hp)
    if is_miss then
        self:ShowMiss(unit)
    else
        if val > 0 then
            self:ShowCureTarget(unit, val)
        else
            self:ShowHurtTarget(unit, is_critical, val, is_miss, is_second_kill)
        end
    end
end

function HeroBattleMgr:ShowMiss(unit)
    SpecMgrs.ui_mgr:ShowHud(
    {
        hud_type = UnitConst.UNITHUD_TYPE.Miss,
        point_go = unit.go:FindChild("UnitInfo"),
        offset = hud_offset,
        is_in_battle = true,
    })
end

function HeroBattleMgr:ShowCureTarget(unit, val)
    SpecMgrs.ui_mgr:ShowHud(
    {
        hud_type = UnitConst.UNITHUD_TYPE.Cure,
        value = val,
        point_go = unit.go:FindChild("UnitInfo"),
        offset = hud_offset,
        is_in_battle = true,
    })
end

function HeroBattleMgr:ShowHurtTarget(unit, is_critical, val, is_miss, is_second_kill)
    local hurt_type
    if is_second_kill then
        hurt_type = UnitConst.UNITHUD_TYPE.ImmediatelyKill
    else
        if is_critical then
            hurt_type = UnitConst.UNITHUD_TYPE.HurtCritical
        else
            hurt_type = UnitConst.UNITHUD_TYPE.Hurt
        end
    end
    SpecMgrs.ui_mgr:ShowHud(
    {
        hud_type = hurt_type,
        value = val,
        point_go = unit.go:FindChild("UnitInfo"),
        offset = hud_offset,
        is_in_battle = true,
    })
end

function HeroBattleMgr:GetFightData()
    return self.fight_data
end

function HeroBattleMgr:GetHurtInfo()
    return self.hurt_info
end

---------------------------------Editor-------------------------------

function HeroBattleMgr:EditorStartBattle(param_tb, battle_param, is_trunback)
    self.is_editor_play = true
    SpecMgrs.effect_mgr:ClearAll()
    ComMgrs.unit_mgr:ClearAll()
    local hero_data = {
        score = 101,
        unit_id = 1000,
        spell_dict = {[10001]=1},
        add_anger = 0,
        fight_attr_dict = {
            hp = 3000,
            max_hp = 3000,
            att = 150,
            def = 100,
            crit = 50,
            crit_def = 50,
            hit = 100,  -- 命中
            miss = 0,
            add_hurt = 10,
            hurt_def = 10,
            add_final_hurt = 10,
            final_hurt_def = 10,
                             --   max_hp_pct = 0.1,
            att_pct = 10,
            def_pct = 10,
        }
    }
    self.fight_data = {
        own_fight_data = {
            [1] = {},
            [2] = {},
            [3] = {},
            [4] = {},
            [5] = {},
            [6] = {},

        },
        enemy_fight_data = {
            [1] = {},
            [2] = {},
            [3] = {},
            [4] = {},
            [5] = {},
            [6] = {},
        },
        seed = math.random(0, 100000)
    }
    print("随机种子  " .. self.fight_data.seed)-- 便于重现

    for i, hero_info in ipairs(param_tb.own_hero_tb) do
        if hero_info.unit_id ~= "" and hero_info.unit_id ~= "0" then
            self.fight_data.own_fight_data[i] = table.deepcopy(hero_data)
            self.fight_data.own_fight_data[i].unit_id = tonumber(hero_info.unit_id)
            self.fight_data.own_fight_data[i].spell_dict = {}

            self.fight_data.own_fight_data[i].fight_attr_dict["hp"] = hero_info.hp
            self.fight_data.own_fight_data[i].fight_attr_dict["max_hp"] = hero_info.hp
            self.fight_data.own_fight_data[i]["add_anger"] = hero_info.add_anger

            local list = string.split(hero_info.skill, " ")
            for j, v in ipairs(list) do
                v = tonumber(v)
                self.fight_data.own_fight_data[i].spell_dict[v] = 1
            end
        end
    end
    for i, hero_info in ipairs(param_tb.enemy_hero_tb) do
        if hero_info.unit_id ~= "" and hero_info.unit_id ~= "0" then
            self.fight_data.enemy_fight_data[i] = table.deepcopy(hero_data)
            self.fight_data.enemy_fight_data[i].unit_id = tonumber(hero_info.unit_id)
            self.fight_data.enemy_fight_data[i].spell_dict = {}

            self.fight_data.enemy_fight_data[i].fight_attr_dict["hp"] = hero_info.hp
            self.fight_data.enemy_fight_data[i].fight_attr_dict["max_hp"] = hero_info.hp
            self.fight_data.enemy_fight_data[i]["add_anger"] = hero_info.add_anger

            local list = string.split(hero_info.skill, " ")
            for j,v in ipairs(list) do
                v = tonumber(v)
                self.fight_data.enemy_fight_data[i].spell_dict[v] = 1
            end
        end
    end

    if is_trunback == 1 then  -- 反转
        local temp = table.deepcopy(self.fight_data.own_fight_data)
        self.fight_data.own_fight_data = self.fight_data.enemy_fight_data
        self.fight_data.enemy_fight_data = temp
    end
    self.battle_param = battle_param
    self:InitBattle(self.fight_data)
end

function HeroBattleMgr:StopPlay()
    UnityEngine.Time.timeScale = 0
end

function HeroBattleMgr:StartPlay()
    UnityEngine.Time.timeScale = self.cur_speed
end
---------------------------------Editor-------------------------------

return HeroBattleMgr