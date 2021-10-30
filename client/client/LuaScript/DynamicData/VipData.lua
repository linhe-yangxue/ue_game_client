
local EventUtil = require("BaseUtilities.EventUtil")
local VipData = class("DynamicData.VipData")
local UIFuncs = require("UI.UIFuncs")
local CSFunction = require("CSCommon.CSFunction")

EventUtil.GeneratorEventFuncs(VipData, "UpdateVipInfo")
EventUtil.GeneratorEventFuncs(VipData, "UpdateVipShopInfo")

function VipData:DoInit()
end

function VipData:NotifyUpdateVipInfo(msg)
    if msg.vip_level then
        if self.vip_level and self.vip_level < msg.vip_level then
            SpecMgrs.ui_mgr:ShowUI("VipLevelUpUI", self.vip_level, msg.vip_level)
        end
        self.vip_level = msg.vip_level
    end
    if msg.vip_exp then
        self.vip_exp = msg.vip_exp
    end
    if msg.sell_gift then
        self.sell_gift = msg.sell_gift
    end
    if msg.daily_gift ~= nil then
        self.daily_gift = msg.daily_gift
        SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.VIPGift, {self.daily_gift and 1 or 0})
    end
    self:DispatchUpdateVipInfo(msg)
end

function VipData:NotifyUpdateVipShopInfo(msg)
    --PrintError("NotifyUpdateVipShopInfo Msg", msg)
    if msg.shop_info then
        self.shop_info = msg.shop_info
    end
    if msg.diff_time then
        self.diff_time = msg.diff_time
    end
    self:DispatchUpdateVipShopInfo(msg)
end

function VipData:GetVipLevel()
    return self.vip_level or 0
end

function VipData:GetVipExp()
    return self.vip_exp or 0
end

function VipData:GetVipShopRefreshTime()
    return self.diff_time
end

function VipData:GetVipShopBuyNum(vip_shop_id)
    return self.shop_info and self.shop_info[vip_shop_id] or 0
end

function VipData:CheckDailyGift()
    return self.daily_gift and true or false
end

function VipData:GatherCastItemDict(vip_shop_id, select_num)
    local item_dict = {}
    local vip_shop_data = SpecMgrs.data_mgr:GetVIPShopData(vip_shop_id)
    local discount = vip_shop_data.discount[self.vip_level + 1]
    for i, item_id in ipairs(vip_shop_data.cost_item_list) do
        item_dict[item_id] = select_num * vip_shop_data.cost_item_value[i] * discount
    end
    return item_dict
end

function VipData:GetDiscount(vip_shop_id)
    local vip_shop_data = SpecMgrs.data_mgr:GetVIPShopData(vip_shop_id)
    local index = self:GetVipLevel() + 1
    return vip_shop_data and vip_shop_data.discount[index] or 1
end

function VipData:GatherSortedVipPrivilegeList(vip_level)
    local next_vip_level = vip_level + 1
    local cur_vip_data = SpecMgrs.data_mgr:GetVipData(vip_level)
    local next_vip_data = SpecMgrs.data_mgr:GetVipData(next_vip_level)
    local privilege_list = {}
    for id, data in ipairs(SpecMgrs.data_mgr:GetAllVIPPrivilegeData()) do
        local compare_data = {}
        compare_data.privilege_data = data
        if data.type == 1 then -- 数值类
            local compare_field_name = data.vip_data_name
            compare_data[1] = cur_vip_data[compare_field_name] or 0
            compare_data[2] = next_vip_data and next_vip_data[compare_field_name] or 0
        elseif data.type == 2 then -- 功能开启
            local require_vip = SpecMgrs.data_mgr:GetFuncUnlockVipLevel(data.unlock_func)
            compare_data[1] = vip_level >= require_vip and 1 or 0
            compare_data[2] = next_vip_level >= require_vip and 1 or 0
        else
            PrintWarn("VipPrivilegeData type must be wrong", data)
        end
        compare_data.is_new_func = compare_data[2] > 0 and compare_data[1] <= 0 or false
        compare_data.is_up = compare_data[2] > compare_data[1]
        if compare_data.is_new_func or compare_data[1] > 0 then
            table.insert(privilege_list, compare_data)
        end
    end
    table.sort(privilege_list, function (data1, data2)
        if data1.is_new_func ~= data2.is_new_func then
            return data1.is_new_func
        elseif data1.is_up ~= data2.is_up then
            return data1.is_up and not data2.is_up
        elseif data1.privilege_data.type ~= data1.privilege_data.type then
            return data1.privilege_data.type < data1.privilege_data.type
        else
            return data1.privilege_data.id < data2.privilege_data.id
        end
        return false
    end)
    return privilege_list
end

-- 获取当前vip 对应的加成属性
function VipData:GetVipDataVal(key)
    local vip_level = self:GetVipLevel()
    return SpecMgrs.data_mgr:GetVipData(vip_level)[key] or 0
end

function VipData:ClearAll()
end

return VipData