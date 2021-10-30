local EventUtil = require("BaseUtilities.EventUtil")
local DyDataConst = require("DynamicData.DyDataConst")
local ItemUtil = require("BaseUtilities.ItemUtil")
local CSFunction = require("CSCommon.CSFunction")
local BagData = class("DynamicData.BagData")

EventUtil.GeneratorEventFuncs(BagData, "InitAllBagItemEvent")
EventUtil.GeneratorEventFuncs(BagData, "UpdateBagItemEvent")

local kIgnoreItemHudTypeList = {
    CSConst.ItemSubType.Hero,
}

function BagData:DoInit()
    self.strengthen_cost_money = SpecMgrs.data_mgr:GetParamData("strengthen_equip_cost_coin").item_id
    self.equip_refine_item_list = SpecMgrs.data_mgr:GetParamData("equip_refine_item_list").item_list
    self.equip_refine_limit = #SpecMgrs.data_mgr:GetEquipmentRefineLvList() + 1
    self.equip_smelt_limit = #SpecMgrs.data_mgr:GetAllEquipSmeltData()
    self.treasure_strength_limit = #SpecMgrs.data_mgr:GetAllStrengthenLvData()
    self.treasure_refine_limit = #SpecMgrs.data_mgr:GetTreasureRefineLvList()
    self.gold_quality = SpecMgrs.data_mgr:GetParamData("gold_quality").quality_id
    self.red_treasure_item_list = SpecMgrs.data_mgr:GetParamData("grab_init_red_treasure_list").item_list
    self.easy_strengthen_remind_quality_purple = SpecMgrs.data_mgr:GetParamData("remind_easy_strengthen_quality_purple").quality_id
    self.easy_strengthen_remind_quality_orange = SpecMgrs.data_mgr:GetParamData("remind_easy_strengthen_quality_orange").quality_id
    self.auto_select_max_quality = SpecMgrs.data_mgr:GetParamData("auto_select_strengthen_material_max_quality").quality_id
    self.lianhua_open_cost_diamond_level = SpecMgrs.data_mgr:GetParamData("open_smelt_cost_diamond_level").f_value
    self.lianhua_open_cost_fragment_level = SpecMgrs.data_mgr:GetParamData("open_smelt_cost_fragment_level").f_value
    self.bag_item_list_with_type = {}
    self.guid2bag_item_dict = {}
    self.item_id2bag_item_dict = {}
    self.equipment_dict = {}
    self.treasure_dict = {}
    self.treasure_list = {}
    self.part_index_to_item_list = {} -- 单一装备部位
    self.hero_fragment_dict = {} -- 头目碎片
    self.exp_equip_count_dict = {} -- 经验宝物数量
    self.battle_reward_list = {}
    self.lover_fragment_dict = {} -- 情人碎片
    self.present_dict = {}

    self.is_show_add_bag_item = true  -- 用于延迟增加物品
    self.wait_to_show_add_item_list = {}
    local all_equip_data = SpecMgrs.data_mgr:GetAllEquipPartData()
    for i,_ in ipairs(all_equip_data) do
        self.part_index_to_item_list[i] = {}
    end
end

function BagData:NotifyAllBagItem(msg)
    for _, item in ipairs(msg.item_list) do
        self:AddItemToBag(item)
    end
    for bag_type, item_list in pairs(self.bag_item_list_with_type) do
        ItemUtil.SortItem(item_list)
    end
    for _, item_list in pairs(self.part_index_to_item_list) do
        ItemUtil.SortItem(item_list)
    end
    self:_UpdateEquipmentRedPoint()
    self:_UpdateHeroFragmentRedPoint()
    self:_UpdateLoverFragmentRedPoint()
    self:DispatchInitAllBagItemEvent()
end

function BagData:NotifyAddBagItem(msg)
    local item = self:AddItemToBag(msg.add_item)
    local sub_type_data = SpecMgrs.data_mgr:GetItemTypeData(item.item_data.sub_type)
    ItemUtil.SortItem(self.bag_item_list_with_type[sub_type_data.bag_type])
    local part_index = item.item_data.part_index
    if part_index then
        ItemUtil.SortItem(self.part_index_to_item_list[part_index])
        self:_UpdateEquipmentRedPoint()
    end
    if item.item_data.sub_type == CSConst.ItemSubType.HeroFragment then
        self:_UpdateHeroFragmentRedPoint()
    elseif item.item_data.sub_type == CSConst.ItemSubType.LoverFragment then
        self:_UpdateLoverFragmentRedPoint()
    end
    self:DispatchUpdateBagItemEvent(DyDataConst.BagItemOpType.Add, item)
    ComMgrs.dy_data_mgr:ExDispatchUpdateItemDict({[item.item_id] = item.count})
end

function BagData:NotifyRemoveBagItem(msg)
    local item = self.guid2bag_item_dict[msg.item_guid]
    if not item then return end
    local item_data = item.item_data
    local sub_type_data = SpecMgrs.data_mgr:GetItemTypeData(item.item_data.sub_type)
    for index, temp_item in ipairs(self.bag_item_list_with_type[sub_type_data.bag_type]) do
        if item.guid == temp_item.guid then
            table.remove(self.bag_item_list_with_type[sub_type_data.bag_type], index)
            self.guid2bag_item_dict[msg.item_guid] = nil
            if item_data.sub_type ~= CSConst.ItemSubType.Equipment then
                self.item_id2bag_item_dict[temp_item.item_id] = nil
            elseif item_data.is_treasure then
                if not item_data.part_index and self.exp_equip_count_dict[item.item_id] then
                    self.exp_equip_count_dict[item.item_id] = self.exp_equip_count_dict[item.item_id] - 1
                end
                self.treasure_dict[msg.item_guid] = nil
            else
                self.equipment_dict[msg.item_guid] = nil
            end
            break
        end
    end
    if item_data.sub_type == CSConst.ItemSubType.HeroFragment then
        self.hero_fragment_dict[item.guid] = nil
        self:_UpdateHeroFragmentRedPoint()
    elseif item_data.sub_type == CSConst.ItemSubType.LoverFragment then
        self.lover_fragment_dict[item.guid] = nil
        self:_UpdateLoverFragmentRedPoint()
    end
    if item_data.sub_type == CSConst.ItemSubType.Present or item_data.sub_type == CSConst.ItemSubType.SelectPresent then
        self.present_dict[item.guid] = nil
    end
    if item_data.part_index then
        for index, temp_item in ipairs(self.part_index_to_item_list[item_data.part_index]) do
            if item.guid == temp_item.guid then
                table.remove(self.part_index_to_item_list[item_data.part_index], index)
                break
            end
        end
        self:_UpdateEquipmentRedPoint()
    end
    item.count = 0 -- 手动清除count
    self:DispatchUpdateBagItemEvent(DyDataConst.BagItemOpType.Remove, item)
    ComMgrs.dy_data_mgr:ExDispatchUpdateItemDict({[item.item_id] = item.count})
end

function BagData:NotifyUpdateBagItem(msg)
    local item_data = SpecMgrs.data_mgr:GetItemData(msg.update_item.item_id)
    msg.update_item.item_data = item_data
    self.guid2bag_item_dict[msg.update_item.guid] = msg.update_item
    if item_data.sub_type ~= CSConst.ItemSubType.Equipment then
        self.item_id2bag_item_dict[msg.update_item.item_id] = msg.update_item
        if item_data.sub_type == CSConst.ItemSubType.HeroFragment then
            self.hero_fragment_dict[msg.update_item.guid] = msg.update_item
        elseif item_data.sub_type == CSConst.ItemSubType.LoverFragment then
            self.lover_fragment_dict[msg.update_item.guid] = msg.update_item
        end
    else
        if item_data.is_treasure then
            self.treasure_dict[msg.update_item.guid] = msg.update_item
        else
            self.equipment_dict[msg.update_item.guid] = msg.update_item
        end
        if item_data.part_index then
            local item_list = self.part_index_to_item_list[item_data.part_index]
            for i, v in ipairs(item_list) do
                if v.guid == msg.update_item.guid then
                    item_list[i] = msg.update_item
                    break
                end
            end
            self:_UpdateEquipmentRedPoint()
        end
    end
    self:DispatchUpdateBagItemEvent(DyDataConst.BagItemOpType.Update, msg.update_item)
    ComMgrs.dy_data_mgr:ExDispatchUpdateItemDict({[msg.update_item.item_id] = msg.update_item.count})
end

function BagData:NotifyGetItem(msg)
    local item_data = SpecMgrs.data_mgr:GetItemData(msg.item_id)
    for _, sub_type in ipairs(kIgnoreItemHudTypeList) do
        if item_data.sub_type == sub_type then return end
    end
    if not self.is_show_add_bag_item then
        table.insert(self.wait_to_show_add_item_list, {item_id = msg.item_id, count = msg.count})
        return
    end

    if ComMgrs.dy_data_mgr:ExGetBattleState() then
        local battle_end_cb = function ()
            for _, reward_data in ipairs(self.battle_reward_list) do
                SpecMgrs.ui_mgr:ShowItemTipMsg(reward_data)
            end
            self.battle_reward_list = {}
            SpecMgrs.soldier_battle_mgr:UnregisterBattleEnd("BagData")
            SpecMgrs.hero_battle_mgr:UnregisterBattleEnd("BagData")
        end
        table.insert(self.battle_reward_list, {item_id = msg.item_id, count = msg.count})
        if not SpecMgrs.soldier_battle_mgr:IsRegisterBattleEnd("BagData") then
            SpecMgrs.soldier_battle_mgr:RegisterBattleEnd("BagData", battle_end_cb, self)
        end
        if not SpecMgrs.hero_battle_mgr:IsRegisterBattleEnd("BagData") then
            SpecMgrs.hero_battle_mgr:RegisterBattleEnd("BagData", battle_end_cb, self)
        end
    else
        SpecMgrs.ui_mgr:ShowItemTipMsg({item_id = msg.item_id, count = msg.count})
    end
end

function BagData:NotifyShowGetItemUI(msg)
    local item_list = ItemUtil.ItemDictToItemDataList(msg.item_dict)
    SpecMgrs.ui_mgr:ShowUI("GetItemUI", item_list)
end

function BagData:SetShowAddBagItem(is_show)
    self.is_show_add_bag_item = is_show
    if is_show and self.wait_to_show_add_item_list then
        for i,v in ipairs(self.wait_to_show_add_item_list) do
            SpecMgrs.ui_mgr:ShowItemTipMsg(v)
        end
        self.wait_to_show_add_item_list = {}
    end
end

function BagData:NotifyClearEquipLuckyValue()
    for _, equip_info in pairs(self.equipment_dict) do
        equip_info.lucky_value = 0
    end
end

function BagData:AddItemToBag(item)
    local item_data = SpecMgrs.data_mgr:GetItemData(item.item_id)
    item.item_data = item_data
    local sub_type_data = SpecMgrs.data_mgr:GetItemTypeData(item.item_data.sub_type)
    if not self.bag_item_list_with_type[sub_type_data.bag_type] then
        self.bag_item_list_with_type[sub_type_data.bag_type] = {}
    end
    table.insert(self.bag_item_list_with_type[sub_type_data.bag_type], item)
    self.guid2bag_item_dict[item.guid] = item
    if item_data.sub_type ~= CSConst.ItemSubType.Equipment then
        self.item_id2bag_item_dict[item.item_id] = item
    elseif item_data.is_treasure then
        self.treasure_dict[item.guid] = item
        if not item_data.part_index then
            self.exp_equip_count_dict[item.item_id] = (self.exp_equip_count_dict[item.item_id] or 0) + 1
        end
    else
        self.equipment_dict[item.guid] = item
    end
    -- 所有头目碎片
    if item_data.sub_type == CSConst.ItemSubType.HeroFragment then
        self.hero_fragment_dict[item.guid] = item
    end
    if item_data.lover then
        self.lover_fragment_dict[item.guid] = item
    end
    if item_data.sub_type == CSConst.ItemSubType.Equipment then
        if item_data.part_index then
            table.insert(self.part_index_to_item_list[item_data.part_index], item)
        end
    end
    if item_data.sub_type == CSConst.ItemSubType.Present or item_data.sub_type == CSConst.ItemSubType.SelectPresent then
        self.present_dict[item.guid] = item
    end
    return item
end

function BagData:GetBagItemListByBagType(bag_type)
    return self.bag_item_list_with_type[bag_type] or {}
end

function BagData:GetBagItemListByPartIndex(part_index, is_need_filt_weared)
    local all_equip_item_list = self.part_index_to_item_list[part_index] or {}
    if not is_need_filt_weared then return all_equip_item_list end
    local item_list = {}
    for _, item_info in ipairs(all_equip_item_list) do
        if not item_info.lineup_id then
            table.insert(item_list, item_info)
        end
    end
    return item_list
end

function BagData:GetAllUnusedEquip()
    local all_unused_equip_dict = {}
    for part_index, equip_list in ipairs(self.part_index_to_item_list) do
        all_unused_equip_dict[part_index] = {}
        for _, item_info in ipairs(equip_list) do
            if not item_info.lineup_id then
                table.insert(all_unused_equip_dict[part_index], item_info)
            end
        end
    end
    return all_unused_equip_dict
end

function BagData:GetBagItemDataByGuid(guid)
    return self.guid2bag_item_dict[guid]
end

function BagData:GetBagItemByItemId(item_id)
    return self.item_id2bag_item_dict[item_id]
end

function BagData:GetBagItemCount(item_id)
    local item_data = SpecMgrs.data_mgr:GetItemData(item_id)
    if item_data.sub_type == CSConst.ItemSubType.Currency then
        return ComMgrs.dy_data_mgr:ExGetCurrencyCount(item_id) or 0
    else
        if item_data.sub_type == CSConst.ItemSubType.Equipment then -- 经验宝物
            return self.exp_equip_count_dict[item_id] or 0
        end
        return self.item_id2bag_item_dict[item_id] and self.item_id2bag_item_dict[item_id].count or 0
    end
end

function BagData:CheckItemCount(guid, count)
    return math.clamp(count, 1, self:GetBagItemDataByGuid(guid).count)
end

-- 获取没有培养过的指定宝物数量
function BagData:GetTreasureItemCountWithoutCultivate(item_id)
    local result_count = 0
    for _, treasure_data in pairs(self.treasure_dict) do
        if treasure_data.item_id == item_id and not treasure_data.lineup_id then
            if treasure_data.strengthen_lv == 1 and treasure_data.refine_lv == 0 then
                result_count = result_count + 1
            end
        end
    end
    return result_count
end

function BagData:GetTreasureListByQuality(quality)
    local temp_list = {}
    for _, treasure in pairs(self.treasure_dict) do
        if treasure.item_data.quality == quality then
            table.insert(temp_list, treasure)
        end
    end
    return temp_list
end

function BagData:GetAllTreasure()
    return self.treasure_dict
end

function BagData:GetTreasureListWithLimitQuality(quality)
    if not quality then return self.treasure_list end
    local temp_list = {}
    for i, treasure_info in pairs(self.treasure_dict) do
        if treasure_info.item_data.quality < quality then
            table.insert(temp_list, treasure_info)
        end
    end
    return temp_list
end

function BagData:GetAllHeroFragmentData()
    return self.hero_fragment_dict
end

function BagData:GetAllEquipInfo()
    return self.equipment_dict
end

function BagData:GetAllLoverFragmentData()
    return self.lover_fragment_dict
end

function BagData:GetAllPresentData()
    return self.present_dict
end

function BagData:CheckEquipIsWear(equip, lineup_id)
    local equip_dict = ComMgrs.dy_data_mgr.night_club_data:GetLineupEquipDict(lineup_id)
    local equip_data = SpecMgrs.data_mgr:GetItemData(equip)
    local equip_guid = equip_dict[equip_data.part_index]
    if not equip_guid then return false end
    local bag_item = self.guid2bag_item_dict[equip_guid]
    return bag_item.item_id == equip
end

function BagData:CheckItemDictCostEnough(item_dict)
    for item_id, count in pairs(item_dict) do
        if not self:CheckItemCostEnough(item_id, count) then
            return false
        end
    end
    return true
end

function BagData:CheckItemCostEnough(item_id, num)
    return self:GetBagItemCount(item_id) >= num
end

function BagData:CheckEquipStrength(equip_guid)
    local equip_info = self:GetBagItemDataByGuid(equip_guid)
    if not equip_info then return end
    if equip_info.item_data.is_treasure then return self:CheckTreasureStrength(equip_guid) end
    if equip_info.strengthen_lv >= CSConst.StrengthenLimitRate * ComMgrs.dy_data_mgr:ExGetRoleLevel() then return false end
    return self:CheckItemCostEnough(self.strengthen_cost_money, CSFunction.get_equip_strengthen_cost(equip_info.item_id, equip_info.strengthen_lv + 1))
end

function BagData:CalcEquipRefineExp(equip_guid)
    local equip_info = self:GetBagItemDataByGuid(equip_guid)
    local equip_data = equip_info.item_data
    if not equip_info then return end
    local total_exp = 0
    local result_refine_lv_list = {}
    for _, item_id in ipairs(self.equip_refine_item_list) do
        local item_info = self:GetBagItemByItemId(item_id)
        total_exp = total_exp + (item_info and (item_info.item_data.add_exp * item_info.count) or 0)
    end
    local refine_lv_list = SpecMgrs.data_mgr:GetEquipmentRefineLvList()
    for i = equip_info.refine_lv + 1, #refine_lv_list do
        local need_exp = refine_lv_list[i]["total_exp_q" .. equip_data.quality] - equip_info.refine_exp
        if need_exp > total_exp then
            break
        end
        local result_refine_lv_data = {}
        result_refine_lv_data.level = i
        result_refine_lv_data.item_dict = {}
        for _, item_id in ipairs(self.equip_refine_item_list) do
            local item_info = self:GetBagItemByItemId(item_id)
            if item_info then
                if item_info.count * item_info.item_data.add_exp > need_exp then
                    result_refine_lv_data.item_dict[item_id] = math.ceil(need_exp / item_info.item_data.add_exp)
                    break
                else
                    result_refine_lv_data.item_dict[item_id] = item_info.count
                    need_exp = need_exp - item_info.count * item_info.item_data.add_exp
                end
            end
        end
        table.insert(result_refine_lv_list, result_refine_lv_data)
    end
    return result_refine_lv_list
end

function BagData:CheckEquipRefine(equip_guid)
    if not ComMgrs.dy_data_mgr.func_unlock_data:CheckFuncUnlock("EquipRefine") then return end
    local equip_info = self:GetBagItemDataByGuid(equip_guid)
    if not equip_info then return end
    if equip_info.item_data.is_treasure then return self:CheckTreasureRefine(equip_guid) end
    if equip_info.refine_lv >= self.equip_refine_limit then return false end
    local refine_lv_list = self:CalcEquipRefineExp(equip_guid)
    return #refine_lv_list > 0
end

function BagData:CheckEquipAddStar(equip_guid)
    if not ComMgrs.dy_data_mgr.func_unlock_data:CheckFuncUnlock("EquipAddStar") then return end
    local equip_info = self:GetBagItemDataByGuid(equip_guid)
    if not equip_info then return end
    if equip_info.item_data.is_treasure then return false end
    local quality_data = SpecMgrs.data_mgr:GetQualityData(equip_info.item_data.quality)
    if equip_info.star_lv >= quality_data.equip_star_lv_limit then return false end
    return self:CheckItemDictCostEnough(CSFunction.get_equip_star_cost(equip_info.item_id, equip_info.star_lv + 1))
end

function BagData:CheckEquipSmelt(equip_guid)
    if not ComMgrs.dy_data_mgr.func_unlock_data:CheckFuncUnlock("EquipSmelt") then return end
    local equip_info = self:GetBagItemDataByGuid(equip_guid)
    if not equip_info then return end
    if equip_info.item_data.is_treasure then return false end
    local quality_data = SpecMgrs.data_mgr:GetQualityData(equip_info.item_data.quality)
    if not quality_data.can_smelt then return false end
    if equip_info.smelt_lv >= self.equip_smelt_limit then return false end
    local smelt_cost_dict = CSFunction.get_equip_smelt_cost(equip_info.item_id, equip_info.smelt_lv + 1)
    if self:CheckItemCostEnough(CSConst.Virtual.Money, smelt_cost_dict[CSConst.Virtual.Money]) then return true end
    if equip_info.smelt_lv >= self.lianhua_open_cost_diamond_level then
        if self:CheckItemCostEnough(CSConst.Virtual.Diamond, smelt_cost_dict[CSConst.Virtual.Diamond]) then return true end
    end
    if equip_info.smelt_lv >= self.lianhua_open_cost_fragment_level then
        if self:CheckItemCostEnough(equip_info.item_data.fragment, smelt_cost_dict[equip_info.item_data.fragment]) then return true end
    end
    return false
end

function BagData:GetTreasureStrengthMaterialList()
    local treasure_list = {}
    for i, treasure_data in pairs(self:GetAllTreasure()) do
        if treasure_data.item_data.quality < self.auto_select_max_quality then
            local treasure_info = self:GetBagItemDataByGuid(treasure_data.guid)
            if not treasure_info.lineup_id then
                table.insert(treasure_list, treasure_info)
            end
        end
    end
    table.sort(treasure_list, function (treasure1, treasure2)
        local treasure1_exp = treasure1.strengthen_exp + treasure1.item_data.add_exp
        local treasure2_exp = treasure2.strengthen_exp + treasure2.item_data.add_exp
        if treasure1_exp ~= treasure2_exp then
            return treasure1_exp < treasure2_exp
        end
        return treasure1.item_data.quality < treasure2.item_data.quality
    end)
    return treasure_list
end

function BagData:CalcTreasureStrengthenLv(treasure_guid, use_purple_treasure, use_orange_treasure)
    local treasure_info = self:GetBagItemDataByGuid(treasure_guid)
    if not treasure_info then return end
    local total_exp = 0
    local easy_material_list = {}
    local strengthen_lv_list = SpecMgrs.data_mgr:GetAllStrengthenLvData()
    local cur_level_exp = strengthen_lv_list[treasure_info.strengthen_lv + 1]["total_exp_q" .. treasure_info.item_data.quality] - treasure_info.strengthen_exp
    local money_count = ComMgrs.dy_data_mgr:ExGetCurrencyCount(CSConst.Virtual.Money)
    local total_cost_money = 0
    local next_level = treasure_info.strengthen_lv + 1
    for _, treasure_data in ipairs(self:GetTreasureStrengthMaterialList()) do
        if treasure_data.guid ~= treasure_guid then
            -- 判断宝物是否已经强化或精炼
            if treasure_data.strengthen_lv == 1 and treasure_data.strengthen_exp == 0 and treasure_data.refine_lv == 0 then
                total_cost_money = total_cost_money + treasure_data.item_data.cost_coin
                -- 判断宝物强化所需金钱是否足够
                if total_cost_money > money_count then
                    if next_level == treasure_info.strengthen_lv + 1 then
                        return false
                    else
                        break
                    end
                end
                -- 判断是否忽略选择的宝物品质(经验宝物除外)
                if not treasure_data.item_data.part_index or use_purple_treasure or treasure_data.item_data.quality ~= self.easy_strengthen_remind_quality_purple then
                    if not treasure_data.item_data.part_index or use_orange_treasure or treasure_data.item_data.quality ~= self.easy_strengthen_remind_quality_orange then
                        total_exp = total_exp + treasure_data.strengthen_exp + treasure_data.item_data.add_exp
                        easy_material_list[next_level] = easy_material_list[next_level] or {}
                        table.insert(easy_material_list[next_level], treasure_data.guid)
                        -- 单件宝物提供经验过多判断下一等级
                        while(total_exp >= cur_level_exp) do
                            next_level = next_level + 1
                            if next_level > #strengthen_lv_list then
                                return easy_material_list
                            end
                            cur_level_exp = strengthen_lv_list[next_level]["total_exp_q" .. treasure_info.item_data.quality] - treasure_info.strengthen_exp
                        end
                    end
                end
            end
        end
    end
    if total_exp > cur_level_exp then
        table.remove(easy_material_list, #easy_material_list)
    end
    if next_level > treasure_info.strengthen_lv + 1 then return easy_material_list end
end

function BagData:CheckTreasureStrength(treasure_guid)
    local treasure_info = self:GetBagItemDataByGuid(treasure_guid)
    if not treasure_info then return end
    if treasure_info.strengthen_lv >= self.treasure_strength_limit then return false end
    return self:CalcTreasureStrengthenLv(treasure_guid)
end

function BagData:CheckTreasureRefine(treasure_guid)
    if not ComMgrs.dy_data_mgr.func_unlock_data:CheckFuncUnlock("TreasureRefine") then return end
    local treasure_info = self:GetBagItemDataByGuid(treasure_guid)
    if not treasure_info then return end
    if treasure_info.refine_lv >= self.treasure_refine_limit then return false end
    local cost_num = SpecMgrs.data_mgr:GetTreasureRefineLvList()[treasure_info.refine_lv].treasure_num
    if treasure_info.item_data.quality >= self.gold_quality then
        for _, item_id in ipairs(self.red_treasure_item_list) do
            if self:GetTreasureItemCountWithoutCultivate(item_id) > cost_num then
                return true
            end
        end
    else
        if self:GetTreasureItemCountWithoutCultivate(treasure_info.item_id) > cost_num then
            return true
        end
    end
    return false
end

--更新装备分解红点
function BagData:_UpdateEquipmentRedPoint()
    local param = nil
    for _, item in pairs(self.equipment_dict) do
        if not item.lineup_id then
            param = 1
            break
        end
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Decompose.Equipment, {param})
end

--更新头目碎片分解红点
function BagData:_UpdateHeroFragmentRedPoint()
    local param = nil
    if next(self.hero_fragment_dict) then
        param = 1
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Decompose.HeroFragment, {param})
end

--更新情人碎片分解红点
function BagData:_UpdateLoverFragmentRedPoint()
    local param = nil
    if next(self.lover_fragment_dict) then
        param = 1
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Decompose.LoverFragment, {param})
end

return BagData