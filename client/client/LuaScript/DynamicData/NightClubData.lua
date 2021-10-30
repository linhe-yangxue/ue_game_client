local EventUtil = require("BaseUtilities.EventUtil")
local UIConst = require("UI.UIConst")
local CSFunction = require("CSCommon.CSFunction")
local DyDataConst = require("DynamicData.DyDataConst")
local FConst = require("CSCommon.Fight.FConst")
local NightClubData = class("DynamicData.NightClubData")

EventUtil.GeneratorEventFuncs(NightClubData, "UpdateHeroEvent")
EventUtil.GeneratorEventFuncs(NightClubData, "AddHeroEvent")
EventUtil.GeneratorEventFuncs(NightClubData, "UpdateLineupEvent")
EventUtil.GeneratorEventFuncs(NightClubData, "UpdateLineupEquipInfoEvent")
EventUtil.GeneratorEventFuncs(NightClubData, "UpdateAidEvent")

--头目突破，升级，潜能，升星所需的材料
local hero_break_cost_item_id = SpecMgrs.data_mgr:GetParamData("hero_break_cost_item").item_id
local hero_break_cost_coin_id = SpecMgrs.data_mgr:GetParamData("hero_break_cost_coin").item_id
local hero_levelup_cost_coin_id = SpecMgrs.data_mgr:GetParamData("hero_levelup_cost_coin").item_id
local hero_destiny_cost_item_id = SpecMgrs.data_mgr:GetParamData("hero_destiny_cost_item").item_id
local hero_addstar_cost_coin_id = SpecMgrs.data_mgr:GetParamData("hero_star_cost_coin").item_id

function NightClubData:DoInit()
    self.star_limit = SpecMgrs.data_mgr:GetParamData("hero_star_lv_limit").f_value
    self.dy_bag_data = ComMgrs.dy_data_mgr.bag_data
    self.dy_bag_data:RegisterUpdateBagItemEvent("NightClubData", self.UpdateBagItemListener, self)
    ComMgrs.dy_data_mgr.func_unlock_data:RegisterInitLockedDictEvent("NightClubData", self.InitLockedDictListener, self)
    ComMgrs.dy_data_mgr:RegisterUpdateCurrencyEvent("NightClubData", self.UpdateCurrencyListener, self)
    ComMgrs.dy_data_mgr:RegisterLevelUpEvent("NightClubData", self.LevelUpEventListener, self)
    self.hero_dict = {}
    self.hero_list = {}
    self.without_hero_list = {}
    self.power_hero_list = {}
    self.without_power_hero_list = {}
    self.hero_list_sorted_by_score = {}
    self.lineup_dict = {}
    self.aid_dict = {}
    self.redpoint_param_states = {}
end

function NightClubData:NotifyAllHero(hero_data)
    self.hero_dict = hero_data.all_hero
    local temp_hero_dict_with_tag = {}
    local temp_hero_dict_with_power = {}
    for _, player_hero in ipairs(SpecMgrs.data_mgr:GetAllPlayerHeroData()) do
        local hero_data = SpecMgrs.data_mgr:GetHeroData(player_hero.hero_id)
        for _, tag_id in ipairs(hero_data.tag) do
            temp_hero_dict_with_tag[tag_id] = temp_hero_dict_with_tag[tag_id] or {}
            temp_hero_dict_with_tag[tag_id][player_hero.hero_id] = hero_data
        end
        temp_hero_dict_with_power[hero_data.power] = temp_hero_dict_with_power[hero_data.power] or {}
        temp_hero_dict_with_power[hero_data.power][hero_data.id] = hero_data
    end
    for _, data in pairs(hero_data.all_hero) do
        local basic_data = SpecMgrs.data_mgr:GetHeroData(data.hero_id)
        table.insert(self.hero_list_sorted_by_score, data)
        if not self.power_hero_list[basic_data.power] then self.power_hero_list[basic_data.power] = {} end
        table.insert(self.power_hero_list[basic_data.power], basic_data)
        for _, tag in pairs(basic_data.tag) do
            if not self.hero_list[tag] then self.hero_list[tag] = {} end
            table.insert(self.hero_list[tag], basic_data)
            temp_hero_dict_with_tag[tag][data.hero_id] = nil
        end
        temp_hero_dict_with_power[basic_data.power] = temp_hero_dict_with_power[basic_data.power] or {}
        temp_hero_dict_with_power[basic_data.power][basic_data.id] = nil
    end

    for _, tag in pairs(CSConst.HeroTag) do
        self.without_hero_list[tag] = {}
        if temp_hero_dict_with_tag[tag] then
            for _, v in pairs(temp_hero_dict_with_tag[tag]) do
                table.insert(self.without_hero_list[tag], v)
            end
        end
    end
    for _, power in ipairs(SpecMgrs.data_mgr:GetPowerList()) do
        self.without_power_hero_list[power.id] = {}
        if temp_hero_dict_with_power[power.id] then
            for _, data in pairs(temp_hero_dict_with_power[power.id]) do
                table.insert(self.without_power_hero_list[power.id], data)
            end
        end
    end
    self:SortHeroList()
    self:UpdateLevelUpRedPoint()
end

function NightClubData:NotifyUpdateHero(hero_data)
    if hero_data.level then
        self.hero_dict[hero_data.hero_id].level = hero_data.level
    end
    if hero_data.attr_dict then
        self.hero_dict[hero_data.hero_id].attr_dict = hero_data.attr_dict
    end
    if hero_data.star_lv then
        self.hero_dict[hero_data.hero_id].star_lv = hero_data.star_lv
    end
    if hero_data.break_lv then
        self.hero_dict[hero_data.hero_id].break_lv = hero_data.break_lv
    end
    if hero_data.destiny_lv then
        self.hero_dict[hero_data.hero_id].destiny_lv = hero_data.destiny_lv
    end
    if hero_data.destiny_exp then
        self.hero_dict[hero_data.hero_id].destiny_exp = hero_data.destiny_exp
    end
    if hero_data.spell_dict then
        self.hero_dict[hero_data.hero_id].spell_dict = hero_data.spell_dict
    end
    if hero_data.score then
        self.hero_dict[hero_data.hero_id].score = hero_data.score
    end
    self:SortHeroList()
    if hero_data.level or hero_data.break_lv then
        if hero_data.level then
            self:UpdateLevelUpRedPoint()
        end
        self:UpdateBreakRedPoint()
    end
    if hero_data.destiny_lv then
        self:UpdateDestinyRedPoint()
    end
    if hero_data.star_lv then
        self:UpdateAddStarRedPoint()
    end
    self:DispatchUpdateHeroEvent(hero_data)
end

function NightClubData:NotifyAddHero(hero_data)
    table.insert(self.hero_list_sorted_by_score, hero_data.hero_info)
    self.hero_dict[hero_data.hero_info.hero_id] = hero_data.hero_info
    local data = SpecMgrs.data_mgr:GetHeroData(hero_data.hero_info.hero_id)
    if not self.power_hero_list[data.power] then self.power_hero_list[data.power] = {} end
    table.insert(self.power_hero_list[data.power], data)
    for _, tag in ipairs(data.tag) do
        if not self.hero_list[tag] then self.hero_list[tag] = {} end
        table.insert(self.hero_list[tag], data)
        for index, hero in ipairs(self.without_hero_list[tag]) do
            if hero.id == data.id then
                table.remove(self.without_hero_list[tag], index)
                break
            end
        end
    end
    for index, hero in pairs(self.without_power_hero_list[data.power]) do
        if hero.id == data.id then table.remove(self.without_power_hero_list[data.power], index) end
    end
    self:SortHeroList()
    self:UpdateBreakRedPoint()
    self:UpdateLevelUpRedPoint()
    self:UpdateDestinyRedPoint()
    self:UpdateAddStarRedPoint()
    SpecMgrs.ui_mgr:PlayUnitUnlockAnim({hero_id = hero_data.hero_info.hero_id, finish_cb = function ()
        self:DispatchAddHeroEvent(hero_data.hero_info)
    end})
end

function NightClubData:NotifyUpdateLineupInfo(msg)
    for k ,v in pairs(msg.lineup_dict) do
        self.lineup_dict[k] = v
    end
    self:UpdateHeroToLineup(self.lineup_dict)
    self:DispatchUpdateLineupEvent(msg)
    self:UpdateLineUpRedPoint()
    self:UpdateReplaceEquipRedPoint()
end

function NightClubData:UpdateHeroToLineup(lineup_dict)
    self.hero_to_lineup = {}
    self.lineup_to_hero = {}
    for k, v in pairs(lineup_dict) do
        if v.hero_id then
            self.hero_to_lineup[v.hero_id] = k
            self.lineup_to_hero[k] = v.hero_id
        end
    end
end

function NightClubData:NotifyUpdateAidInfo(msg)
    self.aid_dict = {}
    for k ,v in pairs(msg.reinforcements_dict) do
        if v.hero_id then
            self.aid_dict[k] = v.hero_id
        end
    end
    self:DispatchUpdateAidEvent(self.aid_dict)
end

function NightClubData:GetSortedFateList(lineup_id)
    local hero_id = self:GetLineupHeroId(lineup_id)
    if not hero_id then return end
    local fate_list = self:GetHeroFateList(hero_id)
    local sort_fate_list = {}
    for _, fate_id in ipairs(fate_list) do
        table.insert(sort_fate_list, fate_id)
    end
    local is_fate_active = self:GetLineupActiveFateDict(lineup_id)
    local all_fate_data = SpecMgrs.data_mgr:GetAllFateData()
    table.sort(sort_fate_list, function (id1, id2)
        if is_fate_active[id1] ~= is_fate_active[id2] then
            return is_fate_active[id1] and not is_fate_active[id2] or false
        end
        if all_fate_data[id1].type ~= all_fate_data[id2].type then
            return all_fate_data[id1].type < all_fate_data[id2].type
        end
        return id1 < id2
    end)
    local active_fate_num = table.getCount(is_fate_active)
    return sort_fate_list, is_fate_active, active_fate_num
end

function NightClubData:GetLineupActiveFateDict(lineup_id)
    local hero_id = self:GetLineupHeroId(lineup_id)
    if not hero_id then return end
    local hero_id_list = self:GetLineupHeroList()
    table.mergeList(hero_id_list, self:GetAidHeroList())
    local equip_to_item_id = self:GetLineupEquipToItemId(lineup_id)
    return self:GetHeroActiveFateDict(hero_id, hero_id_list, equip_to_item_id)
end

function NightClubData:GetLineupHeroList(except_lineup_index)
    local hero_id_list = {}
    for k, _ in pairs(self.lineup_dict) do
        if except_lineup_index then
            if except_lineup_index ~= k then
                table.insert(hero_id_list, self:GetLineupHeroId(k))
            end
        else
            table.insert(hero_id_list, self:GetLineupHeroId(k))
        end
    end
    return hero_id_list
end

function NightClubData:GetHeroPreviewFate(hero_id, change_lineup_index)
    local hero_id_list = self:GetLineupHeroList(change_lineup_index)
    local equip_dict = self:GetLineupEquipToItemId(change_lineup_index)
    return self:GetHeroActiveFateDict(hero_id, hero_id_list, equip_dict)
end

function NightClubData:GetHeroAidFate(hero_id)
    local hero_id_list = self:GetLineupHeroList()
    return CSFunction.get_aid_active_fate(hero_id, hero_id_list)
end

function NightClubData:GetLineupEquipToItemId(lineup_id)
    local equip_to_item_id = {}
    local equip_to_guid = self:GetLineupEquipDict(lineup_id)
    for k, guid in pairs(equip_to_guid) do
        local item_info = self.dy_bag_data:GetBagItemDataByGuid(guid)
        equip_to_item_id[k] = item_info.item_id
    end
    return equip_to_item_id
end

function NightClubData:GetHeroActiveFateDict(hero_id, hero_id_list, equip_to_item_id)
    return CSFunction.get_hero_active_fate_dict(hero_id, hero_id_list, equip_to_item_id)
end

function NightClubData:GetHeroFateList(hero_id)
    return SpecMgrs.data_mgr:GetHeroData(hero_id).fate
end

function NightClubData:NotifyUpdateLineupEquipInfo(msg)
    self.lineup_dict[msg.lineup_id].equip_dict = msg.equip_dict
    self:DispatchUpdateLineupEquipInfoEvent()
    self:UpdateReplaceEquipRedPoint()
end

function NightClubData:NotifyUpdateLineupMasterLv(msg)
    if msg.strengthen_master_lv then
        self.lineup_dict[msg.lineup_id].strengthen_master_lv = msg.strengthen_master_lv
    end
    if msg.refine_master_lv then
        self.lineup_dict[msg.lineup_id].refine_master_lv = msg.refine_master_lv
    end
end

function NightClubData:NotifyClearHeroDestinyExp(msg)
    for _, hero_info in pairs(self.hero_dict) do
        hero_info.destiny_exp = 0
        self:DispatchUpdateHeroEvent(hero_info)
    end
end

function NightClubData:CheckHeroIsLineUp(unit_id)
    for _,v in pairs(self.lineup_dict) do
        if v.hero_id and SpecMgrs.data_mgr:GetHeroData(v.hero_id).unit_id == unit_id then
            return true
        end
    end
    return false
end

function NightClubData:CheckHeroWearEquip(hero_id, item_id)
    for _,v in pairs(self.lineup_dict) do
        if v.hero_id and v.hero_id == hero_id then
            local item_data = SpecMgrs.data_mgr:GetItemData(item_id)
            local bag_item = self.dy_bag_data:GetBagItemDataByGuid(v.equip_dict[item_data.part_index])
            return bag_item and bag_item.item_id == item_id or false
        end
    end
    return false
end

function NightClubData:GetAllLineupData()
    return self.lineup_dict
end

function NightClubData:GetLineupToHero()
    return self.lineup_to_hero
end

function NightClubData:GetLineupData(lineup_id)
    return self.lineup_dict[lineup_id]
end

function NightClubData:GetLineupHeroId(lineup_id)
    return self.lineup_to_hero and self.lineup_to_hero[lineup_id]
end

function NightClubData:GetHeroLineupId(hero_id)
    return self.hero_to_lineup and self.hero_to_lineup[hero_id]
end

function NightClubData:GetLineupEquipDict(lineup_id)
    return self.lineup_dict[lineup_id] and self.lineup_dict[lineup_id].equip_dict or {}
end

function NightClubData:SortHeroList()
    local owned_sort_func = function (data1, data2)
        local hero1 = self.hero_dict[data1.id]
        local hero2 = self.hero_dict[data2.id]
        if hero1.level == hero2.level then
            return hero1.score > hero2.score
        end
        return hero1.level > hero2.level
    end
    local quality_sort_func = function (hero1, hero2)
        if hero1.quality == hero2.quality then
            return hero1.id > hero2.id
        end
        return hero1.quality > hero2.quality
    end
    for _, list in pairs(self.hero_list) do
        table.sort(list, owned_sort_func)
    end
    for _, list in pairs(self.power_hero_list) do
        table.sort(list, quality_sort_func)
    end
    for _, list in pairs(self.without_power_hero_list) do
        table.sort(list, quality_sort_func)
    end
    for _, list in pairs(self.without_hero_list) do
        table.sort(list, quality_sort_func)
    end
    local score_sort_func = function (hero_data1, hero_data2)
        return hero_data1.score > hero_data2.score
    end
    table.sort(self.hero_list_sorted_by_score, score_sort_func)
end

function NightClubData:GetHeroList(tag)
    return self.hero_list[tag] or {}
end

function NightClubData:GetAllHeroData()
    return self.hero_dict
end

function NightClubData:GetWithoutHeroList(tag)
    return self.without_hero_list[tag] or {}
end

function NightClubData:GetHeroDataById(id)
    return self.hero_dict[id]
end

function NightClubData:GetHeroByIndex(tag, index)
    return self.hero_list[tag][index]
end

function NightClubData:GetHeroIndex(tag, id)
    for index, hero in ipairs(self.hero_list[tag]) do
        if hero.id == id then return index end
    end
end

function NightClubData:GetHeroCountWithTag(tag)
    return #self.hero_list[tag]
end

function NightClubData:GetPowerHeroList(power)
    return self.power_hero_list[power] or {}
end

function NightClubData:GetWithoutPowerHeroList(power)
    return self.without_power_hero_list[power] or {}
end

function NightClubData:GetPowerHeroByIndex(power, index)
    return self.power_hero_list[power][index]
end

function NightClubData:GetPowerHeroIndex(power, id)
    for index, hero in ipairs(self.power_hero_list[power]) do
        if hero.id == id then return index end
    end
end

function NightClubData:GetPowerHeroCount(power)
    return #self.power_hero_list[power]
end

function NightClubData:GetHeroListSortedByScore()
    return self.hero_list_sorted_by_score
end

function NightClubData:GetOwnHeroCount()
    return #self.hero_list_sorted_by_score
end

function NightClubData:GetHeroScoreSum()
    local score_sum = 0
    for _, v in pairs(self.hero_dict) do
        score_sum = score_sum + v.score
    end
    return score_sum
end

function NightClubData:GetRandomHeroID()
    local hero_count = #self.hero_list_sorted_by_score
    if hero_count > 0 then
        local index = math.random(1, hero_count)
        return self.hero_list_sorted_by_score[index].hero_id
    end
end

function NightClubData:CheckHeroLineup(is_show_tips)
    local lineup_dict = ComMgrs.dy_data_mgr.night_club_data:GetAllLineupData()
    if lineup_dict then
        for k, v in pairs(lineup_dict) do
            if v.hero_id and v.pos_id then
                return true
            end
        end
    end
    if is_show_tips then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.PLEASE_PUT_ON_HERO)
    end
    return false
end

function NightClubData:RemoveHero(hero_id)
    local hero_data = SpecMgrs.data_mgr:GetHeroData(hero_id)
    self.hero_dict[hero_id] = nil
    for _, tag in pairs(hero_data.tag) do
        for i, hero in ipairs(self.hero_list[tag]) do
            if hero.id == hero_id then
                table.remove(self.hero_list[tag], i)
                table.insert(self.without_hero_list[tag], hero_data)
                break
            end
        end
    end
    for index, hero in ipairs(self.power_hero_list[hero_data.power]) do
        if hero.id == hero_id then
            table.remove(self.power_hero_list[hero_data.power], index)
            table.insert(self.without_power_hero_list[hero_data.power], hero_data)
            break
        end
    end
    for i, hero_info in ipairs(self.hero_list_sorted_by_score) do
        if hero_info.hero_id == hero_id then
            table.remove(self.hero_list_sorted_by_score, i)
            break
        end
    end
end

-----------------红点功能相关-begin-------------------
--监听功能解锁DATA初始化事件
function NightClubData:InitLockedDictListener()
    self:UpdateBreakRedPoint()
    self:UpdateDestinyRedPoint()
    self:UpdateAddStarRedPoint()
end

--监听角色升级事件
function NightClubData:LevelUpEventListener()
    self:UpdateLevelUpRedPoint()
    self:UpdateAddStarRedPoint()
end

--监听物品变化
function NightClubData:UpdateCurrencyListener(_, currency)
    if currency[hero_break_cost_item_id] or currency[hero_break_cost_coin_id] then
        self:UpdateBreakRedPoint()
    end
    if currency[hero_levelup_cost_coin_id] then
        self:UpdateLevelUpRedPoint()
    end
    if currency[hero_destiny_cost_item_id] then
        self:UpdateDestinyRedPoint()
    end
    if currency[hero_addstar_cost_coin_id] then
        self:UpdateAddStarRedPoint()
    end
end

--监听背包物品变化
function NightClubData:UpdateBagItemListener(_, op, item)
    local item_data = item.item_data
    if item_data.sub_type == CSConst.ItemSubType.HeroFragment then
        self:UpdateAddStarRedPoint()
    elseif item_data.sub_type == CSConst.ItemSubType.Equipment then
        self:UpdateReplaceEquipRedPoint()
    end
end

--刷新突破红点
function NightClubData:UpdateBreakRedPoint()
    if not ComMgrs.dy_data_mgr.func_unlock_data:CheckFuncUnlock("HeroBreak") then return end
    local break_limit = #SpecMgrs.data_mgr:GetHeroBreakLvList()
    local param_dict = {}
    for hero_id, hero_info in pairs(self.hero_dict) do
        if hero_info.break_lv < break_limit and hero_info.level >= SpecMgrs.data_mgr:GetHeroBreakLvData(hero_info.break_lv + 1).level_limit then
            if self.dy_bag_data:CheckItemDictCostEnough(CSFunction.get_hero_break_cost(hero_id, hero_info.break_lv + 1)) then
                param_dict[hero_id] = 1
            end
        end
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.NightClub.Break, param_dict)
    self.redpoint_param_states[CSConst.CultivateOperation.Break] = param_dict
    self:UpdateLineUpRedPoint()
end

--刷新升级红点
function NightClubData:UpdateLevelUpRedPoint()
    local param_dict = {}
    for hero_id, hero_info in pairs(self.hero_dict) do
        local hero_level = hero_info.level
        if hero_level < CSFunction.get_hero_level_limit(ComMgrs.dy_data_mgr:ExGetRoleLevel()) then
            if self.dy_bag_data:CheckItemDictCostEnough(CSFunction.get_hero_level_cost(hero_id, hero_level, hero_level + 1)) then
                param_dict[hero_id] = 1
            end
        end
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.NightClub.LevelUp, param_dict)
    self.redpoint_param_states[CSConst.CultivateOperation.Upgrade] = param_dict
    self:UpdateLineUpRedPoint()
end

--刷新天命红点
function NightClubData:UpdateDestinyRedPoint()
    if not ComMgrs.dy_data_mgr.func_unlock_data:CheckFuncUnlock("HeroDestiny") then return end
    local param_dict = {}
    local destiny_lv_list = SpecMgrs.data_mgr:GetHeroDestinyLvList()
    for hero_id, hero_info in pairs(self.hero_dict) do
        local hero_destiny_lv = hero_info.destiny_lv
        if hero_destiny_lv < #destiny_lv_list then
            local cost_num = destiny_lv_list[hero_destiny_lv].cost_num
            if self.dy_bag_data:CheckItemCostEnough(hero_destiny_cost_item_id, cost_num) then
                param_dict[hero_id] = 1
            end
        end
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.NightClub.Destiny, param_dict)
    self.redpoint_param_states[CSConst.CultivateOperation.Destiny] = param_dict
    self:UpdateLineUpRedPoint()
end

--刷新升星红点
function NightClubData:UpdateAddStarRedPoint()
    if not ComMgrs.dy_data_mgr.func_unlock_data:CheckFuncUnlock("HeroAddStar") then return end
    local param_dict = {}
    for hero_id, hero_info in pairs(self.hero_dict) do
        if hero_info.star_lv < self.star_limit then
            local cost_dict = CSFunction.get_hero_star_cost(hero_id, hero_info.star_lv + 1)
            if self.dy_bag_data:CheckItemDictCostEnough(cost_dict) then
                param_dict[hero_id] = 1
            end
        end
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.NightClub.AddStar, param_dict)
    self.redpoint_param_states[CSConst.CultivateOperation.AddStar] = param_dict
    self:UpdateLineUpRedPoint()
end

--刷新阵容的红点
function NightClubData:UpdateLineUpRedPoint()
    if not self.lineup_to_hero then
        return
    end
    local is_show = false
    for _, param_dict in pairs(self.redpoint_param_states) do
        for _, hero_id in pairs(self.lineup_to_hero) do
            if param_dict[hero_id] then
                is_show = true
                break
            end
        end
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.LineUp, {is_show and 1 or 0})
end

--更新替换装备的红点
function NightClubData:UpdateReplaceEquipRedPoint()
    local unused_equip_dict = self.dy_bag_data:GetAllUnusedEquip()
    local param_dict = {}
    for _, data in pairs(self.lineup_dict) do
        local equip_dict = data.equip_dict
        for part_index, equip_guid in pairs(equip_dict) do
            local current_quality = self.dy_bag_data:GetBagItemDataByGuid(equip_guid).item_data.quality
            for _, equip_data in ipairs(unused_equip_dict[part_index]) do
                if equip_data.item_data.quality > current_quality then
                    param_dict[equip_guid] = 1
                end
            end
        end
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.ReplaceEquip, param_dict)
end

--检查装备是否可以强化
function NightClubData:CheckEquipUp(lineup_id, equip_index)
    local equip_dict = self:GetLineupEquipDict(lineup_id)
    local equip_guid = equip_dict and equip_dict[equip_index]
    if not equip_guid then return false end
    if ComMgrs.dy_data_mgr.bag_data:CheckEquipStrength(equip_guid) then return true end
    if ComMgrs.dy_data_mgr.bag_data:CheckEquipRefine(equip_guid) then return true end
    if ComMgrs.dy_data_mgr.bag_data:CheckEquipAddStar(equip_guid) then return true end
    if ComMgrs.dy_data_mgr.bag_data:CheckEquipSmelt(equip_guid) then return true end
    return false
end

--检查是否有英雄属性书
function NightClubData:CheckHeroCultivate()
    for _, item_list in pairs(SpecMgrs.data_mgr:GetAllAttrItemList()) do
        for _, item_data in ipairs(item_list) do
            if self.dy_bag_data:GetBagItemCount(item_data.id) > 0 then return true end
        end
    end
    return false
end
-----------------红点功能相关-end---------------------

function NightClubData:GetAidDict()
    return self.aid_dict
end

function NightClubData:GetAidHeroList()
    local hero_id_list = {}
    for k, v in pairs(self.aid_dict) do
        table.insert(hero_id_list, v)
    end
    return hero_id_list
end

function NightClubData:GetAidIndex(index)
    if not index then return nil end
    return self.aid_dict[index]
end

function NightClubData:CheckInAid(hero_id)
    for k, v in pairs(self.aid_dict) do
        if v == hero_id then return k end
    end
    return nil
end

function NightClubData:IsAllLineup()
    for k,v in pairs(self.lineup_dict) do
        if not v.hero_id then
            return false
        end
    end
    return true
end

function NightClubData:GetActiveComboSpell(hero_id, hero_id_dict) -- todo 等有了Combo spell 改一下字段名
    local combo_spell_id = self:GetComboSpell(hero_id)
    local ret = {}
    if combo_spell_id then -- 作为主将的组合技
        local combo_spell_data = SpecMgrs.data_mgr:GetSpellData(combo_spell_id)
        local second_spell_hero = combo_spell_data.second_spell_hero
        if table.contains(hero_id_dict, second_spell_hero) then
            table.insert(ret, {combo_spell = combo_spell_id, combo_hero = second_spell_hero})
        end
    end
    for k, compare_hero_id in pairs(hero_id_dict) do -- 作为副将的组合技
        local combo_spell_id = self:GetComboSpell(compare_hero_id)
        if combo_spell_id then
            local combo_spell_data = SpecMgrs.data_mgr:GetSpellData(combo_spell_id)
            if combo_spell_data.second_spell_hero == hero_id then
                table.insert(ret, {combo_spell = combo_spell_id, combo_hero = compare_hero_id})
            end
        end
    end
    return ret
end

function NightClubData:GetComboSpell(hero_id)
    local hero_data = SpecMgrs.data_mgr:GetHeroData(hero_id)
    local spell_id_list = hero_data.spell
    for _, spell_id in ipairs(spell_id_list) do
        local spell_data = SpecMgrs.data_mgr:GetSpellData(spell_id)
        if spell_data.spell_type == FConst.SpellType.TogetherSpell then
            return spell_id
        end
    end
end

function NightClubData:GetAidUnlockNum()
    local role_level = ComMgrs.dy_data_mgr:ExGetRoleLevel()
    local unlock_num = 0
    for k, data in ipairs(SpecMgrs.data_mgr:GetAllDeinforcementsData()) do
        if role_level >= data.unlock_level then
            unlock_num = unlock_num + 1
        else
            break
        end
    end
    return unlock_num
end

function NightClubData:CheckAidUnlock(aid_index)
    return aid_index <= self:GetAidUnlockNum()
end

return NightClubData