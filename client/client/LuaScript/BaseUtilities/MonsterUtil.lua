local CSConst = require("CSCommon.CSConst")
local MonsterUtil = DECLARE_MODULE("BaseUtilities.MonsterUtil")
local CSFunction = require("CSCommon.CSFunction")

-- 获取怪物组主要怪物的data
function MonsterUtil.GetMainMonsterData(monster_group_id)
    local monster_group_data = SpecMgrs.data_mgr:GetMonsterGroupData(monster_group_id)
    local index = monster_group_data.main_monster_index or 1
    local boss_id = monster_group_data.monster_list[index] or monster_group_data.monster_list[1]
    local monster_data = SpecMgrs.data_mgr:GetMonsterData(boss_id)
    local hero_data = SpecMgrs.data_mgr:GetHeroData(monster_data.hero_id)
    local unit_data = SpecMgrs.data_mgr:GetUnitData(hero_data.unit_id)
    return monster_data, hero_data, unit_data
end

function MonsterUtil.GetMonsterGroupScore(monster_group_id)
    return CSFunction.get_monster_group_score(monster_group_id)
end
return MonsterUtil