local DyDataConst = require("DynamicData.DyDataConst")
local InputHandle_Keyboard = class("Input.InputHandle_Keyboard")

local data_mgr = require("CSCommon.data_mgr")

local GetData = function(data_name, key)
    local func = "Get" .. data_name
    return data_mgr[func] and data_mgr[func](data_mgr, key)
end

function InputHandle_Keyboard:DoInit()
end

function TestStarProperty(hero_id, curr_star_lv)
    local hero_data = GetData("HeroData", hero_id)

    local base_role_define = GetData("GrowConstData", "base_role_define")
    local quality_data = GetData("QualityData", hero_data.quality)

    local cur_star_pct = GetData("GrowConstData", "r_prop_pct_star" .. curr_star_lv).f_value

    local role_q2p = quality_data.role_q2p
    local star_prop_pct = quality_data.r_star_prop_pct

    cur_star_pct = cur_star_pct * star_prop_pct

    local attr_dict = {
        business = math.floor(base_role_define.star_business * cur_star_pct * hero_data.business_prefer_pct * role_q2p),
        management = math.floor(base_role_define.star_management * cur_star_pct * hero_data.management_prefer_pct * role_q2p),
        renown = math.floor(base_role_define.star_renown * cur_star_pct * hero_data.renown_prefer_pct * role_q2p),
        fight = math.floor(base_role_define.star_fight * cur_star_pct * hero_data.fight_prefer_pct * role_q2p),
        att = math.floor(base_role_define.star_att * cur_star_pct * hero_data.atk_prefer_pct * role_q2p),
        def = math.floor(base_role_define.star_def * cur_star_pct * hero_data.defence_prefer_pct * role_q2p),
        max_hp = math.floor(base_role_define.star_max_hp * cur_star_pct * hero_data.hp_prefer_pct * role_q2p)
    }
    return attr_dict
end

function TestBreakLevel(hero_id, curr_level, curr_break_lv)
    local hero_data = GetData("HeroData", hero_id)

    local base_role_define = GetData("GrowConstData", "base_role_define")
    local quality_data = GetData("QualityData", hero_data.quality)

    local base_round_num = GetData("GrowConstData", "base_round_num").i_value
    local base_defence_pct = GetData("GrowConstData", "base_defence_pct").f_value

    local role_q2p = quality_data.role_q2p

    local business = curr_level * base_role_define.b_grow_v
    local management = curr_level * base_role_define.m_grow_v
    local renown = curr_level * base_role_define.r_grow_v
    local fight = curr_level * base_role_define.f_grow_v
    local akt = curr_level * base_role_define.atk_grow_v
    local max_hp = curr_level * base_role_define.hp_grow_v
    local defence = 0

    local break_base_prop = 0
    local break_base_atk = 0
    local break_base_defence = 0
    local break_base_hp = 0

    if curr_break_lv > 0 and curr_level > 0 then
        break_base_prop = base_role_define.brk_prop_base
        break_base_atk = base_role_define.brk_atk_base
        local cur_prop_add_v = 0
        local cur_atk_add_v = 0
        local break_2_lv = GetData("HeroBreakLvData", curr_break_lv).level_limit
        local pre_count_break_lv = break_2_lv <= curr_level and curr_break_lv or (curr_break_lv - 1)
        for b_l = 2, pre_count_break_lv do
            local b_last_lv = GetData("HeroBreakLvData", b_l - 1).level_limit
            local b_curr_lv = GetData("HeroBreakLvData", b_l).level_limit
            cur_prop_add_v = (base_role_define.brk_prop_add_v + base_role_define.brk_prop_add_acc * (b_l - 2))
            cur_atk_add_v = (base_role_define.brk_atk_add_v + base_role_define.brk_atk_add_acc * (b_l - 2))
            break_base_prop = break_base_prop +
                b_l * base_role_define.brk_prop_base_mult * (b_curr_lv - b_last_lv + 1) +
                    cur_prop_add_v * (b_curr_lv - b_last_lv)
            break_base_atk = break_base_atk +
                b_l * base_role_define.brk_atk_base_mult * (b_curr_lv - b_last_lv + 1) +
                    cur_atk_add_v * (b_curr_lv - b_last_lv)
        end
        cur_prop_add_v = base_role_define.brk_prop_add_v + base_role_define.brk_prop_add_acc * (pre_count_break_lv - 1)
        cur_atk_add_v = base_role_define.brk_atk_add_v + base_role_define.brk_atk_add_acc * (pre_count_break_lv - 1)
        local cur_break2lvl = GetData("HeroBreakLvData", pre_count_break_lv).level_limit
        break_base_prop = break_base_prop + cur_prop_add_v * (curr_level - cur_break2lvl) +
            curr_break_lv * base_role_define.brk_prop_base_mult * (curr_break_lv - pre_count_break_lv) * (curr_level - cur_break2lvl + 1)  -- 在查询下一突破等级属性时(当前等级不满足下一突破等级)，只加上Base差值
        break_base_atk = break_base_atk + cur_atk_add_v * (curr_level - cur_break2lvl) +
            curr_break_lv * base_role_define.brk_atk_base_mult * (curr_break_lv - pre_count_break_lv) * (curr_level - cur_break2lvl + 1)
        break_base_defence = break_base_atk * base_defence_pct
        break_base_hp = (break_base_atk - break_base_defence) * base_round_num
    end
    business = business + break_base_prop
    management = management + break_base_prop
    renown = renown + break_base_prop
    fight = fight + break_base_prop
    akt = akt + break_base_atk
    defence = defence + break_base_defence
    max_hp = max_hp + break_base_hp

    local attr_dict = {
        business = math.floor(business * hero_data.business_prefer_pct * role_q2p),
        management = math.floor(management * hero_data.management_prefer_pct * role_q2p),
        renown = math.floor(renown * hero_data.renown_prefer_pct * role_q2p),
        fight = math.floor(fight * hero_data.fight_prefer_pct * role_q2p),
        att = math.floor(akt * hero_data.atk_prefer_pct * role_q2p),
        def = math.floor(defence * hero_data.defence_prefer_pct * role_q2p),
        max_hp = math.floor(max_hp * hero_data.hp_prefer_pct * role_q2p),
    }
    return attr_dict
end

function TestItemLvlup(item_id, next_strengthen_lv)
    local item_data = GetData("ItemData", item_id)
    local quality_data = GetData("QualityData", item_data.quality)
    local b_consume_c0 = GetData("GrowConstData", "e_lvlup_consume_c0").f_value
    local b_consume_c1 = GetData("GrowConstData", "e_lvlup_consume_c1").f_value
    local b_consume_c2 = GetData("GrowConstData", "e_lvlup_consume_c2").f_value
    local b_consume_c3 = GetData("GrowConstData", "e_lvlup_consume_c3").f_value


    local lvl = next_strengthen_lv
    local q_scale = quality_data.consume_pct

    local cost_num = math.ceil(q_scale * (b_consume_c3 * lvl * lvl * lvl + b_consume_c2 * lvl * lvl + b_consume_c1 * lvl + b_consume_c0))

    return cost_num
end

function TestItemStarUp(item_id, next_star_lv)
    local item_data = GetData("ItemData", item_id)
    local quality_data = GetData("QualityData", item_data.quality)

    local b_consume_c0 = GetData("GrowConstData", "e_star_consume_c0").i_value
    local b_consume_c1 = GetData("GrowConstData", "e_star_consume_c1").i_value
    local b_consume_c2 = GetData("GrowConstData", "e_star_consume_c2").i_value
    local b_consume_c3 = GetData("GrowConstData", "e_star_consume_c3").i_value

    local lvl = next_star_lv
    local q_scale = quality_data.consume_pct

    local cost_num = math.ceil(q_scale * (b_consume_c3 * lvl * lvl * lvl + b_consume_c2 * lvl * lvl + b_consume_c1 * lvl + b_consume_c0))
    local fragment_num = quality_data["e_star_frag_num" .. lvl]

    return cost_num, fragment_num
end

function TestItemSmeltConsume(item_id, next_smelt_lv)
    local item_data = GetData("ItemData", item_id)
    local quality_data = GetData("QualityData", item_data.quality)
    local base_equip_define = GetData("GrowConstData", "base_equip_define")

    local q_scale = quality_data.consume_pct

    local coin_num = base_equip_define["smelt_money_lvl" .. next_smelt_lv] --and math.ceil(q_scale * base_equip_define["smelt_money_lvl" .. next_smelt_lv]) or nil
    local diamond_num = base_equip_define["smelt_diamond_lvl" .. next_smelt_lv] --and math.ceil(q_scale * base_equip_define["smelt_diamond_lvl" .. next_smelt_lv]) or nil
    local fragment_num = base_equip_define["smelt_frag_lvl" .. next_smelt_lv] --and math.ceil(q_scale * base_equip_define["smelt_frag_lvl" .. next_smelt_lv]) or nil

    -- 消耗三选一
    return coin_num, diamond_num, fragment_num
end

function TestEquipStarLvl(item_id, curr_star_lv)
    local item_data = GetData("ItemData", item_id)
    local quality_data = GetData("QualityData", item_data.quality)
    local red_quality_data = GetData("QualityData", 5)
    local base_equip_define = GetData("GrowConstData", "base_equip_define")

    local q_scale = quality_data.equip_q2p
    local star_base_pct = quality_data.e_star_base_pct
    local max_star_lvl = quality_data.e_max_star_lvl
    local max_star_pct = red_quality_data["e_star_pct" .. max_star_lvl]

    local part_tb = {
        [1] = {name = "base_lvl_att", prop_name = "att", pct = 1},                  -- weapon
        [2] = {name = "base_lvl_max_hp", prop_name = "max_hp", pct =0.5},           -- hat
        [3] = {name = "base_lvl_max_hp", prop_name = "max_hp", pct = 0.5},          -- belt
        [4] = {name = "base_lvl_def", prop_name = "def", pct = 1},                  -- cloth
    }

    local prop_pct = q_scale * star_base_pct * max_star_pct * quality_data["e_star_pct" .. curr_star_lv] * part_tb[item_data.part_index].pct


    local attr_dict = {
        [part_tb[item_data.part_index].prop_name] = math.floor(prop_pct * base_equip_define[part_tb[item_data.part_index].name])
    }

    return attr_dict
end

local lvl_count = 0
local break_count = 0

function InputHandle_Keyboard:ProcessInput(input_type, param1)
    if not ComMgrs.dy_data_mgr.urs then return end
    if input_type == SpecMgrs.event_mgr.InputType_KeyDown then
        if param1 == "f1" then
            SpecMgrs.ui_mgr:ShowUI("DebugUI")
        end
        if param1 == "f2" then
            -- SpecMgrs.msg_mgr:SendCommand("add_item ".. CSConst.Virtual.Exp .. " 100")
            --PrintWarn("fffff1", lvl_count, TestStarProperty(11011, lvl_count))
            --PrintWarn("fffff2", lvl_count, TestStarProperty(11012, lvl_count))
            lvl_count =  lvl_count + 1
            if lvl_count == 1 then
                break_count = 1
            end
            local UIFuncs = require("UI.UIFuncs")
            PrintWarn("fkegekgejgke", lvl_count, UIFuncs.GetStageNameById(lvl_count))
            -- PrintWarn("Yellow Role Break And Levelup:", lvl_count, "break Lvl", break_count, TestBreakLevel(11041, lvl_count, break_count))
            -- PrintWarn("Item lvlup yellow weapon:", TestEquipStarLvl(601010, lvl_count))
            -- PrintWarn("Item lvlup yellow hat:", TestEquipStarLvl(601012, lvl_count))
            -- PrintWarn("Item lvlup yellow belt:", TestEquipStarLvl(601013, lvl_count))
            -- PrintWarn("Item lvlup yellow cloth:", TestEquipStarLvl(601011, lvl_count))
            -- PrintWarn("Item lvlup Red weapon:", TestEquipStarLvl(601050, lvl_count))
            -- PrintWarn("Item lvlup Red hat:", TestEquipStarLvl(601051, lvl_count))
            -- PrintWarn("Item lvlup Red belt:", TestEquipStarLvl(601052, lvl_count))
            -- PrintWarn("Item lvlup Red cloth:", TestEquipStarLvl(601053, lvl_count))
            -- PrintWarn("Item lvlup Purple weapon:", TestEquipStarLvl(601030, lvl_count))
            -- PrintWarn("Item lvlup Purple hat:", TestEquipStarLvl(601031, lvl_count))
            -- PrintWarn("Item lvlup Purple belt:", TestEquipStarLvl(601032, lvl_count))
            -- PrintWarn("Item lvlup Purple cloth:", TestEquipStarLvl(601033, lvl_count))
            -- PrintWarn("Item lvlup blue:", TestEquipStarLvl(601018, lvl_count))
            -- PrintWarn("Item lvlup green:", TestEquipStarLvl(601014, lvl_count))
            -- local UIFuncs = require("UI.UIFuncs")
            -- PrintWarn("item lvl up green:", UIFuncs.GetDropItemInfoList(30011))
        end
        if param1 == "f3" then
            SpecMgrs.msg_mgr:SendCommand("add_item ".. CSConst.Virtual.Money .. " 100")
        end
        if param1 == "f4" then
            SpecMgrs.msg_mgr:SendCommand("add_item ".. CSConst.Virtual.Food .. " 100")
        end
        if param1 == "f5" then
            SpecMgrs.msg_mgr:SendCommand("add_item ".. CSConst.Virtual.Soldier .. " 100")
        end
        if param1 == "f6" then
            SpecMgrs.msg_mgr:SendCommand("add_item ".. CSConst.Virtual.Diamond .. " 100")
        end
        if param1 == "f7" then
            ComMgrs.dy_data_mgr:ExSetDayOrNight(DyDataConst.DayType.Day)
        end
        if param1 == "f8" then
            ComMgrs.dy_data_mgr:ExSetDayOrNight(DyDataConst.DayType.Night)
        end
        if param1 == "f9" then

        end
        if param1 == "f10" then

        end
        if param1 == "f11" then

        end
        if param1 == "escape" then
            local create_role_ui = SpecMgrs.ui_mgr:GetUI("CreateRoleUI")
            if create_role_ui then create_role_ui:SkipCutScene() end
            SpecMgrs.guide_mgr:PassGuide()
        end
        if param1 == "1" then
            UnityEngine.Time.timeScale = 1
        end
        if param1 == "2" then
            UnityEngine.Time.timeScale = 5
        end
        if param1 == "3" then
            UnityEngine.Time.timeScale = 10
        end
    end
    if input_type == SpecMgrs.event_mgr.InputType_KeyDown or input_type == SpecMgrs.event_mgr.InputType_KeyRepeat then

    elseif input_type == SpecMgrs.event_mgr.InputType_KeyUp then
    end
end

function InputHandle_Keyboard:DoDestroy()
end

return InputHandle_Keyboard