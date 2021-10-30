local EventUtil = require("BaseUtilities.EventUtil")
local UIConst = require("UI.UIConst")
local CSConst = require("CSCommon.CSConst")
local UIFuncs = require("UI.UIFuncs")
local FestivalActivityData = class("DynamicData.FestivalActivityData")

EventUtil.GeneratorEventFuncs(FestivalActivityData, "UpdateFestivalActivityData")

function FestivalActivityData:DoInit()
    self.festival_data = nil
    self.festival_data_dict = {}
    self.tag_key = {
        "welfare",
        "celebration",
        "activity",
    }
    self.all_recharge_activity_list = SpecMgrs.data_mgr:GetAllTLActivityData()
    for i, v in ipairs(self.all_recharge_activity_list) do
        if v.type == CSConst.LimitActivityType.FestivalActivity then
            self.festival_system_name = v.system_name
            self.festival_activity_id = v.festival_activity
            self.cur_festival_group_id = v.id
        end
        if v.type == CSConst.LimitActivityType.FestivalExchange then
            self.festival_exchange_system_name = v.system_name
        end
    end

    if self.festival_activity_id then
        local festival_group_data = SpecMgrs.data_mgr:GetFestivalGroupData(self.festival_activity_id)
        ComMgrs.dy_data_mgr.bag_data:RegisterUpdateBagItemEvent("FestivalActivityData", function(_, op, bag_item)
            if bag_item.item_id == festival_group_data.welfare_stuff or bag_item.item_id == festival_group_data.luxury_stuff then
                self:UpdateExchangeRedPoint()
            end
        end)
    end
end

function FestivalActivityData:UpdateFestivalActivityData(msg)
    for activity_id, group_data in pairs(msg.activity_dict) do
        if not self.festival_data_dict[activity_id] then
            self.festival_data_dict[activity_id] = {}
        end

        for k, v in pairs(group_data) do
            if type(v) == "table" then
                if not self.festival_data_dict[activity_id][k] then
                    self.festival_data_dict[activity_id][k] = {}
                end
                for key, data in pairs(v) do
                    self.festival_data_dict[activity_id][k][key] = data
                end
            else
                self.festival_data_dict[activity_id][k] = v
            end
            --self.festival_data_dict[activity_id].state = CSConst.ActivityState.reserve
        end
    end
    local have_red_point = false
    local activity_data = self:GetCurFestivalActivity(self.festival_activity_id)
    if activity_data then
        for i, key in ipairs(self.tag_key) do
            local content_list = activity_data[key]
            if self:CheckTagCanReward(activity_data.id, content_list) then
                have_red_point = true
            end
        end
        SpecMgrs.redpoint_mgr:SetControlIdActive(self.festival_system_name, {have_red_point and 1 or 0})
    end
    self.exchange_info_list = {}
    for i,info in pairs(self.festival_data_dict) do
        for k,v in pairs(info.exchange_dict) do
            self.exchange_info_list[k] = v
        end
    end
    self:UpdateExchangeRedPoint()
    self:DispatchUpdateFestivalActivityData()
end

function FestivalActivityData:GetPastFestivalActivityList(festival_group_id)
    local festival_group_data = SpecMgrs.data_mgr:GetFestivalGroupData(festival_group_id)
    local ret = {}
    for i, v in ipairs(festival_group_data.activity_list) do
        local start_time = self:GetActivityLastTime(festival_group_id, i)
        local cur_time = Time:GetServerTime()
        if cur_time >= start_time then
            table.insert(ret, SpecMgrs.data_mgr:GetFestivalActivityData(v))
        end
    end
    return ret
end

function FestivalActivityData:GetCurFestivalActivity(festival_group_id)
    local festival_group_data = SpecMgrs.data_mgr:GetFestivalGroupData(festival_group_id)
    for i, v in ipairs(festival_group_data.activity_list) do
        local start_time, end_time = self:GetActivityLastTime(festival_group_id, i)
        local cur_time = Time:GetServerTime()
        if cur_time >= start_time and cur_time <= end_time then
            return SpecMgrs.data_mgr:GetFestivalActivityData(v)
        end
    end
    return nil
end

function FestivalActivityData:IsFestivalActivityOpen(festival_activity_id)
    return self:GetCurFestivalActivity(festival_activity_id) ~= nil
end

function FestivalActivityData:CheckTagCanReward(activity_id, content_list)
    for i,v in ipairs(content_list) do
        local content_data = SpecMgrs.data_mgr:GetFestivalContentData(v)
        for i = 1, #content_data.reward_list do
            local state = self.festival_data_dict[activity_id].reward_dict[content_data.reward_list[i]]
            if state == CSConst.RewardState.pick then
                return true
            end
        end

    end
    return false
end

-- 活动兑换
function FestivalActivityData:UpdateExchangeRedPoint()
    local exchange_data_list = self:GetExchangeList(self.festival_activity_id)
    local can_exchange = self:CheckCanExchangeItem(exchange_data_list)
    SpecMgrs.redpoint_mgr:SetControlIdActive(self.festival_exchange_system_name, {can_exchange and 1 or 0})
end

function FestivalActivityData:CheckCanExchangeItem(exchange_list)
    local festival_group_data = SpecMgrs.data_mgr:GetFestivalGroupData(self.festival_activity_id)
    local can_exchange = false
    for i, v in ipairs(exchange_list) do
        if self.exchange_info_list[v.id] > 0 then
            local cost_item_id
            if v.cost_item_type == CSConst.FestivalStuffType.welfare then
                cost_item_id = festival_group_data.welfare_stuff
            else
                cost_item_id = festival_group_data.luxury_stuff
            end
            if UIFuncs.CheckItemCount(cost_item_id, v.cost_item_num) then
                can_exchange = true
            end
        end
    end
    return can_exchange
end

function FestivalActivityData:GetExchangeList(festival_group_id)
    local festival_group_data = SpecMgrs.data_mgr:GetFestivalGroupData(festival_group_id)
    local exchange_end_time = self:GetExchangeEndTime(festival_group_id)
    local cur_time = Time:GetServerTime()
    local result_list = {}
    if cur_time > exchange_end_time then
        return nil
    end
    for i = #festival_group_data.activity_list, 1, -1 do
        local start_time = self:GetActivityLastTime(festival_group_id, i)
        if cur_time >= start_time then
            local data = SpecMgrs.data_mgr:GetFestivalActivityData(festival_group_data.activity_list[i])
            for j, id in ipairs(data.exchange) do
                local exchange_data = SpecMgrs.data_mgr:GetFestivalExchangeData(id)
                table.insert(result_list, exchange_data)
            end
        end
    end
    return result_list
end

function FestivalActivityData:IsActivityExchangeOpen(festival_activity_id)
    return self:GetExchangeList(festival_activity_id) ~= nil
end

function FestivalActivityData:GetExchangeEndTime(festival_group_id)
    local festival_group_data = SpecMgrs.data_mgr:GetFestivalGroupData(festival_group_id)
    local exchange_end_time = festival_group_data.open_timestamp + (festival_group_data.activity_duration * #festival_group_data.activity_list + festival_group_data.exchange_day) * CSConst.Time.Day
    return exchange_end_time
end

function FestivalActivityData:GetActivityLastTime(festival_group_id, activity_index)
    local festival_group_data = SpecMgrs.data_mgr:GetFestivalGroupData(festival_group_id)
    local activity_duration = festival_group_data.activity_duration * CSConst.Time.Day
    local start_time = festival_group_data.open_timestamp
    return start_time + (activity_index - 1) * activity_duration, start_time + activity_index * activity_duration
end

function FestivalActivityData:ClearAll()
    ComMgrs.dy_data_mgr.bag_data:UnregisterUpdateBagItemEvent("FestivalActivityData")
end

return FestivalActivityData