local CSConst = require("CSCommon.CSConst")
local ItemUtil = DECLARE_MODULE("BaseUtilities.ItemUtil")
local CSFunction = require("CSCommon.CSFunction")
local UIConst = require("UI.UIConst")

function ItemUtil.SortItem(item_list)
    table.sort(item_list, function (item1, item2)
        local item_data1 = item1.item_data or item1
        local item_data2 = item2.item_data or item2
        local item1_quality = item_data1.quality or 0
        local item2_quality = item_data2.quality or 0
        if item1_quality ~= item2_quality then
            return item1_quality > item2_quality
        end
        if item_data1.id ~= item_data2.id then
            return item_data1.id < item_data2.id
        end
        return false
    end)
end

function ItemUtil._GetDropGroupItemInfoList(drop_group_id, ret)
    local drop_g_data = SpecMgrs.data_mgr:GetDropGroupData(drop_group_id)
    for _, drop_d in pairs(drop_g_data) do
        if drop_d.drop_item then
            if ret[drop_d.drop_item] == nil then
                ret[drop_d.drop_item] = {}
            end
            ret[drop_d.drop_item][1] = drop_d.min_count
            ret[drop_d.drop_item][2] = drop_d.max_count
        end
        if drop_d.drop_group then
            ItemUtil._GetDropGroupItemInfoList(drop_d.drop_group, ret)
        end
    end
end

function ItemUtil.GetDropItemInfoList(drop_group_id)
    local drop_g_data = SpecMgrs.data_mgr:GetDropData(drop_group_id)
    local ret = {}
    for _, drop_d in pairs(drop_g_data) do
        if drop_d.drop_item then
            if ret[drop_d.drop_item] == nil then
                ret[drop_d.drop_item] = {}
            end
            ret[drop_d.drop_item][1] = drop_d.min_count
            ret[drop_d.drop_item][2] = drop_d.max_count
        end
        if drop_d.drop_group then
            ItemUtil._GetDropGroupItemInfoList(drop_d.drop_group, ret)
        end
    end
    return ret
end

-- 获取排列好的掉落物品数据列表
function ItemUtil.GetSortedDropItemDataList(drop_id)
    local drop_info_list = ItemUtil.GetDropItemInfoList(drop_id)
    local item_data_list = {}
    for item_id, count_list in pairs(drop_info_list) do
        local item_data = SpecMgrs.data_mgr:GetItemData(item_id)
        local count_str = count_list[1] == count_list[2] and count_list[1] or count_list[1] .."~" .. count_list[2]
        table.insert(item_data_list, {item_id = item_id, item_data = item_data, count = count_str}) -- 注意这里count 可能为 1-3
    end
    ItemUtil.SortItem(item_data_list)
    return item_data_list
end

function ItemUtil.ItemDictToItemDataList(item_dict, is_sort, sort_func)
    local item_data_list = {}
    for item_id , count in pairs(item_dict) do
        local item_data = SpecMgrs.data_mgr:GetItemData(item_id)
        table.insert(item_data_list, {item_id = item_id, item_data = item_data, count = count})
    end
    local is_sort = is_sort == nil and is_sort
    local sort_func = sort_func or ItemUtil.SortItem
    if is_sort then
        sort_func(item_data_list)
    end
    return item_data_list
end

function ItemUtil.GetItemNum(item_id)  -- 当前物品数量
   if ItemUtil.IsVirtualItem(item_id) then  -- 虚拟物品
        return ComMgrs.dy_data_mgr:ExGetCurrencyCount(item_id) or 0
    else
        return ComMgrs.dy_data_mgr.bag_data:GetBagItemCount(item_id) or 0
    end
end

function ItemUtil.SortEuqipItemList(equip_data_list)
    local ret
    table.sort(equip_data_list, function (item_data1, item_data2)
        ret = ItemUtil.CompareNumField(item_data1, item_data2, "lineup_id")
        if ret ~= nil then return ret end

        ret = ItemUtil.CompareNumField(item_data1, item_data2, "quality", true, true)
        if ret ~= nil then return ret end

        ret = ItemUtil.CompareNumField(item_data1, item_data2, "refine_lv")
        if ret ~= nil then return ret end

        ret = ItemUtil.CompareNumField(item_data1, item_data2, "strengthen_lv")
        if ret ~= nil then return ret end

        ret = ItemUtil.CompareNumField(item_data1, item_data2, "item_id")
        if ret ~= nil then return ret end

        return false
    end)
end

function ItemUtil.CompareBoolField(item_data1, item_data2, field, is_descending_sort, is_native_data)
    local is_descending_sort = is_descending_sort == nil or is_descending_sort
    local is_native_data = is_native_data ~= nil and is_native_data or false
    local v1 = is_native_data and item_data1.item_data[field] or item_data1[field]
    local v2 = is_native_data and item_data2.item_data[field] or item_data2[field]
    if v1 and not v2 then
        return is_descending_sort
    elseif v2 and not v1 then
        return not is_descending_sort
    else
        return nil
    end
end

function ItemUtil.CompareNumField(item_data1, item_data2, field, is_descending_sort, is_native_data)
    local is_descending_sort = is_descending_sort == nil or is_descending_sort
    local is_native_data = is_native_data ~= nil and is_native_data or false
    local v1 = is_native_data and item_data1.item_data[field] or item_data1[field]
    local v2 = is_native_data and item_data2.item_data[field] or item_data2[field]
    if v1 and not v2 then
        return is_descending_sort
    elseif v2 and not v1 then
        return not is_descending_sort
    elseif not v1 and not v2 then
        return nil
    else
        if v1 == v2 then
            return nil
        else
            if is_descending_sort then
                return v1 > v2
            else
                return v1 < v2
            end
        end
    end
end

--  合并相同物品的数量
function ItemUtil.MergeRoleItemList(role_item_list)
    local ret = {}
    local record_dict = {}
    for i, role_item in ipairs(role_item_list) do
        local index = record_dict[role_item.item_id]
        if index then
            ret[index].count = ret[index].count + role_item.count
        else
            record_dict[role_item.item_id] = #ret + 1
            table.insert(ret, role_item)
        end
    end
    return ret
end

function ItemUtil.MergeRewardList(reward_id_list)
    local item_dict = {}
    local reward_data
    for _, reward_id in ipairs(reward_id_list) do
        reward_data = SpecMgrs.data_mgr:GetRewardData(reward_id)
        for index, item_id in ipairs(reward_data.reward_item_list) do
            item_dict[item_id] = (item_dict[item_id] or 0) + reward_data.reward_num_list[index]
        end
    end
    return ItemUtil.ItemDictToItemDataList(item_dict)
end

function ItemUtil.RoleItemListToItemDict(role_item_list)
    return CSFunction.item_list_to_dict(role_item_list)
end

-- 排序服务器端的发回来的回调奖励列表
function ItemUtil.SortRoleItemList(role_item_list, is_merge)
    local is_merge = is_merge == nil or is_merge
    if is_merge then
        role_item_list = ItemUtil.MergeRoleItemList(role_item_list)
    end
    for _, role_item_data in ipairs(role_item_list) do
        role_item_data.item_data = SpecMgrs.data_mgr:GetItemData(role_item_data.item_id)
    end
    ItemUtil.SortItem(role_item_list)
    return role_item_list
end

function ItemUtil.GatherRewardItemList(reward_id, is_merge)
    local reward_data = SpecMgrs.data_mgr:GetRewardData(reward_id)
    local reward_item_list = {}
    for i,v in ipairs(reward_data.reward_item_list) do
        local item_data = SpecMgrs.data_mgr:GetItemData(v)
        local tb = {item_id = v, item_data = item_data, count = reward_data.reward_num_list[i]}
        table.insert(reward_item_list, tb)
    end
    if is_merge then
        return ItemUtil.MergeRoleItemList(reward_item_list)
    end
    return reward_item_list
end

function ItemUtil.GetSortedRewardItemList(reward_id)
    local reward_item_list = ItemUtil.GatherRewardItemList(reward_id)
    ItemUtil.SortItem(reward_item_list)
    return reward_item_list
end

function ItemUtil.GetRewardAllItemName(reward_id, sep, start_index, end_index)
    local sorted_item_list = ItemUtil.GetSortedRewardItemList(reward_id)
    local str_list = {}
    for i, v in ipairs(sorted_item_list) do
        table.insert(str_list, string.format(UIConst.Text.ITEM_X_COUNT, v.item_data.name, v.count))
    end
    sep = sep or "\n"
    return table.concat(str_list, sep, start_index, end_index)
end

function ItemUtil.IsBelongCoin(item_id)
    if table.contains(CSConst.Virtual, item_id) then
        return true
    else
        return false
    end
end

function ItemUtil.IsVirtualItem(item_id)
    local item_data = SpecMgrs.data_mgr:GetItemData(item_id)
    return item_data.item_type == CSConst.ItemType.Virtual
end

function ItemUtil.GetGiftPackageItemList(present_item_id)
    local ret = {}
    local present_item_data = SpecMgrs.data_mgr:GetItemData(present_item_id)
    if present_item_data.sub_type == CSConst.ItemSubType.Present or
        present_item_data.sub_type == CSConst.ItemSubType.SelectPresent then
        local item_id_list = present_item_data.item_list
        local item_count_list = present_item_data.item_count_list
        for i, item_id in ipairs(item_id_list) do
            local item_data = SpecMgrs.data_mgr:GetItemData(item_id)
            table.insert(ret, {item_id = item_id, item_data = item_data, count = item_count_list[i]})
        end
        ItemUtil.SortItem(ret)
    elseif present_item_data.sub_type == CSConst.ItemSubType.RandomPresent then
        ret = ItemUtil.GetSortedDropItemDataList(present_item_data.drop_id)
    end
    return ret
end

return ItemUtil