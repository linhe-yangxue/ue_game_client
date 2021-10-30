local EventUtil = require("BaseUtilities.EventUtil")
local UIConst = require("UI.UIConst")

local SalonData = class("DynamicData.SalonData")

EventUtil.GeneratorEventFuncs(SalonData, "UpdateSalonAreaEvent")

function SalonData:DoInit()
    self.salon_dict = {}
    self.salon_list = {}
    self.old_salon_dict = {}
    self.old_salon_list = {}
    self.dy_lover_data = ComMgrs.dy_data_mgr.lover_data
    self.attr_point_cost_item = SpecMgrs.data_mgr:GetParamData("salon_buy_attr_point_item").item_id
    self.attr_point_cost = SpecMgrs.data_mgr:GetParamData("salon_buy_attr_point_item").count
    self.attr_point_buy_limit = SpecMgrs.data_mgr:GetParamData("salon_buy_attr_point_num_limit").f_value
    self.salon_delay_time = SpecMgrs.data_mgr:GetParamData("salon_pvp_run_time").f_value * CSConst.Time.Minute
    self.buy_attr_point_count = SpecMgrs.data_mgr:GetParamData("salon_buy_attr_point_count").f_value
end

function SalonData:NotifyUpdateSalonInfo(msg)
    if msg.attr_point_count then
        self.cur_attr_point = msg.attr_point_count
    end
    if msg.attr_point_buy_num then
        self.attr_point_buy_num = msg.attr_point_buy_num
    end
    if msg.salon_dict then
        for salon_id, area_data in pairs(msg.salon_dict) do
            self.salon_dict[salon_id] = area_data
        end
        self:_UpdateSalonRedPoint()
    end
    if msg.old_salon_dict then
        self.old_salon_list = {}
        for area_id, area_data in pairs(msg.old_salon_dict) do
            self.old_salon_dict[area_id] = area_data
            if area_data.rank and area_data.pvp_id then
                area_data.salon_id = area_id
                table.insert(self.old_salon_list, area_data)
            end
        end
        table.sort(self.old_salon_list, function (salon1, salon2)
            return salon1.salon_id < salon2.salon_id
        end)
    end
    if msg.salon_integral then
        self.salon_integral = msg.salon_integral
    end
    if msg.pvp_record then
        self.pvp_record = msg.pvp_record
    end
    self:DispatchUpdateSalonAreaEvent()
end

function SalonData:GetCurAttrPoint()
    return self.cur_attr_point
end

function SalonData:GetCanBuyAttrPoint()
    return self.attr_point_buy_num
end

function SalonData:GetSalonRecordList()
    self.salon_list = {}
    for salon_id, salon_data in pairs(self.salon_dict) do
        if salon_data.rank and salon_data.pvp_id then
            salon_data.salon_id = salon_id
            table.insert(self.salon_list, salon_data)
        end
    end
    table.sort(self.salon_list, function (salon1, salon2)
        return salon1.salon_id < salon2.salon_id
    end)
    return self.salon_list
end

function SalonData:GetYesterdaySalonRecordList()
    return self.old_salon_list
end

function SalonData:GetSalonData(area_id)
    return self.salon_dict[area_id]
end

function SalonData:GetSalonIntegral()
    return self.salon_integral
end

function SalonData:CheckSalonStartTime(area_id)
    local area_data = SpecMgrs.data_mgr:GetSalonAreaData(area_id)
    local time_offset = Time:GetCurDayPassTime() - area_data.start_time * CSConst.Time.Hour
    if time_offset < 0 then
        return CSConst.SalonAreaState.Idle
    else
        time_offset = time_offset - self.salon_delay_time
        return time_offset > 0 and CSConst.SalonAreaState.End or CSConst.SalonAreaState.Start
    end
end

function SalonData:GetIdleLoverList()
    local idle_lover_list = {}
    local own_lover_list = self.dy_lover_data:GetAllLoverInfo()
    for _, lover in ipairs(own_lover_list) do
        local flag = true
        for _, salon_area_data in pairs(self.salon_dict) do
            if salon_area_data.lover_id == lover.lover_id then
                flag = false
                break
            end
        end
        if flag and lover.grade >= CSConst.SalonActiveLoverGrade then table.insert(idle_lover_list, lover) end
    end
    table.sort(idle_lover_list, function(lover1, lover2)
        local total_attr1 = lover1.attr_dict.etiquette + lover1.attr_dict.culture + lover1.attr_dict.charm + lover1.attr_dict.planning
        local total_attr2 = lover2.attr_dict.etiquette + lover2.attr_dict.culture + lover2.attr_dict.charm + lover2.attr_dict.planning
        return total_attr1 > total_attr2
    end)
    return idle_lover_list
end

-- 获取沙龙记录的时间 nil表示沙龙记录已过期
function SalonData:GetSalonRecordDayAndPvpId(salon_id)
    local today_salon_data = self.salon_dict[salon_id]
    if today_salon_data and today_salon_data.pvp_id then
        return CSConst.Salon.Today, today_salon_data.pvp_id
    end
    local yesterday_salon_data = self.old_salon_dict[salon_id]
    if yesterday_salon_data and yesterday_salon_data.pvp_id then
        return CSConst.Salon.Yesterday, yesterday_salon_data.pvp_id
    end
    return nil, nil
end

-- 购买妃位点
function SalonData:SendBuyAttrPoint()
    if self.attr_point_buy_num >= self.attr_point_buy_limit then
        SpecMgrs.ui_mgr:ShowMsgBox(string.format(UIConst.Text.ATTR_POINT_BUY_LIMIT))
        return
    end
    local item_data = SpecMgrs.data_mgr:GetItemData(self.attr_point_cost_item)
    local data = {
        item_id = self.attr_point_cost_item,
        need_count = self.attr_point_cost,
        is_show_tip = true,
        remind_tag = "BuyAttrPoint",
        desc = string.format(UIConst.Text.BUY_ATTR_POINT, item_data.name, self.attr_point_cost, self.attr_point_buy_num, self.attr_point_buy_limit),
        confirm_cb = function ()
            SpecMgrs.msg_mgr:SendBuyAttrPoint({}, function (resp)
                if resp.errcode ~= 0 then
                    SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.BUY_ATTR_POINT_FAILED)
                end
            end)
        end,
    }
    SpecMgrs.ui_mgr:ShowItemUseRemindByTb(data)
end

function SalonData:ReceiveSalonReward(salon_id)
    SpecMgrs.msg_mgr:SendRecieveIntegral({salon_id = salon_id}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_SALON_REWARD_FAILED)
        end
    end)
end

--更新沙龙红点
function SalonData:_UpdateSalonRedPoint()
    local param_dict = {}
    for salon_id, salon_info in pairs(self.salon_dict) do
        if salon_info.integral then
            param_dict[salon_id] = 1
        end
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Salon, param_dict)
end

return SalonData