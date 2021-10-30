local EventUtil = require("BaseUtilities.EventUtil")
local UIConst = require("UI.UIConst")

local TravelData = class("DynamicData.TravelData")

EventUtil.GeneratorEventFuncs(TravelData, "UpdateTravelInfoEvent")

function TravelData:DoInit()
    self.strengthen_item_id = SpecMgrs.data_mgr:GetParamData("travel_strength_num_restore_item").item_id
    self.travel_info = {}
    self.travel_info.luck = {}
    self.travel_info.lover_meet = {}
    self.travel_info.area_unlock_dict = {}
end

function TravelData:NotifyUpdateTravelInfo(msg)
    if msg.luck then
        self.travel_info.luck = msg.luck
        for k,v in pairs(msg.luck) do
            self.travel_info.luck[k] = v
        end
    end
    if msg.strength_num then
        self.travel_info.strength_num = msg.strength_num
        self:_UpdateTravelRedPoint()
    end
    if msg.last_time then
        self.travel_info.last_time = msg.last_time
    end
    if msg.area_unlock_dict then
        for k,v in pairs(msg.area_unlock_dict) do
            self.travel_info.area_unlock_dict[k] = v
        end
    end
    if msg.assign_travel_num then
        self.travel_info.assign_travel_num = msg.assign_travel_num
    end
    if msg.lover_meet then
        for lover_id, meet_data in pairs(msg.lover_meet) do
            self.travel_info.lover_meet[lover_id] = meet_data
        end
    end
    self:DispatchUpdateTravelInfoEvent()
end

function TravelData:GetCurLuckValue()
    return self.travel_info.luck.value
end

function TravelData:GetCurStrengthNum()
    return self.travel_info.strength_num
end

function TravelData:GetCityStateDict()
    return self.travel_info.area_unlock_dict
end

function TravelData:GetDirectedTravelCount()
    return self.travel_info.assign_travel_num
end

function TravelData:GetLoverDateRecord(lover_id)
    local meet_record_data = self.travel_info.lover_meet[lover_id]
    if not meet_record_data then return end
    return meet_record_data.meet_id, meet_record_data.meet_num
end

function TravelData:GetCurSetLuck()
    return self.travel_info.luck.set_value
end

function TravelData:GetCurRecoverLuckCostItem()
    return self.travel_info.luck.set_item_id
end

function TravelData:GetRecoverCostAndEffect(item_id)
    local item_data = SpecMgrs.data_mgr:GetItemData(item_id)
    local cost_data = SpecMgrs.data_mgr:GetRecoverLuckCostData(item_id)
    local cost_level = math.clamp(self.travel_info.luck.restore_num, 1, #cost_data.consume_item_count_list)
    local cost_text = string.format(UIConst.Text.RECOVER_COST, item_data.name, cost_data.consume_item_count_list[cost_level])
    local effect_text = string.format(UIConst.Text.RECOVER_LUCK, cost_data.add_luck)
    return cost_text, effect_text
end

function TravelData:GetStrengthenRecoverLastTime()
    return self.travel_info.last_time
end

function TravelData:GetCurLuckDesc()
    for _, luck_data in pairs(SpecMgrs.data_mgr:GetAllLuckDescData()) do
        if self.travel_info.luck.value >= luck_data.value_range[1] and self.travel_info.luck.value <= luck_data.value_range[2] then
            return luck_data.desc
        end
    end
end

function TravelData:SendUseTravelItem()
    SpecMgrs.ui_mgr:ShowItemUseRemindByTb({
        item_id = self.strengthen_item_id,
        need_count = 1,
        confirm_cb = function ()
            if self:GetCurStrengthNum() > 0 then return end
            SpecMgrs.msg_mgr:SendUseTravelItem({}, function (resp)
                if resp.errcode ~= 0 then
                    SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.ITEM_RECOVER_FAILED)
                end
            end)
        end,
        remind_tag = "RecoverStrength",
        is_show_tip = true,
    })
end

function TravelData:_UpdateTravelRedPoint()
    if not ComMgrs.dy_data_mgr.func_unlock_data:CheckFuncUnlock("Travel") then return end
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Travel, {self.travel_info.strength_num})
end

return TravelData