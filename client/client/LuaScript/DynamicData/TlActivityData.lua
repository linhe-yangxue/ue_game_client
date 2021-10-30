local EventUtil = require("BaseUtilities.EventUtil")
local UIConst = require("UI.UIConst")
local CSConst = require("CSCommon.CSConst")
local TlActivityData = class("DynamicData.TlActivityData")

EventUtil.GeneratorEventFuncs(TlActivityData, "UpdateRechargeActivitySwitch")

function TlActivityData:DoInit()
    self.check_open_func = {
        [CSConst.LimitActivityType.Activity] = "CheckActivityOpen",
        [CSConst.LimitActivityType.FirstRecharge] = "CheckFirstRechargeOpen",
        [CSConst.LimitActivityType.DailyRecharge] = "CheckDailyRechargeOpen",
        [CSConst.LimitActivityType.FestivalActivity] = "CheckFestivalActivityOpen",
        [CSConst.LimitActivityType.FestivalExchange] = "CheckActivityExchangeOpen",
        [CSConst.LimitActivityType.RechargeDraw] = "CheckRechargeDrawOpen",
    }
end

function TlActivityData:GetOpenActivityList()
    local activity_list = SpecMgrs.data_mgr:GetAllTLActivityData()
    local ret = {}
    for i, activity_data in ipairs(activity_list) do
        local check_open_func = self.check_open_func[activity_data.type]
        if check_open_func then
            local func = self[check_open_func]
            if func(self, activity_data) then
                table.insert(ret, activity_data)
            end
        else
            table.insert(ret, activity_data)
        end
    end
    print("hhhhh--",ret)
    return ret
end

function TlActivityData:CheckActivityOpen(data)
    local state = ComMgrs.dy_data_mgr.activity_data:GetActivityState(data.activity)
    return state ~= CSConst.ActivityState.invalid
end

function TlActivityData:CheckFirstRechargeOpen()
    return ComMgrs.dy_data_mgr.recharge_data.is_first_recharge ~= nil
end

function TlActivityData:CheckDailyRechargeOpen(data)
    return ComMgrs.dy_data_mgr.recharge_data:CheckDailyRechargeOpen(data.recharge_activity)
end

function TlActivityData:CheckFestivalActivityOpen(data)
    return ComMgrs.dy_data_mgr.festival_activity_data:IsFestivalActivityOpen(data.festival_activity)
end

function TlActivityData:CheckActivityExchangeOpen(data)
    return ComMgrs.dy_data_mgr.festival_activity_data:IsActivityExchangeOpen(data.festival_activity)
end

function TlActivityData:CheckRechargeDrawOpen(data)
    return ComMgrs.dy_data_mgr.recharge_data:CheckRechargeDrawOpen(data.recharge_activity)
end

function TlActivityData:UpdateRechargeActivitySwitch()
    self:DispatchUpdateRechargeActivitySwitch()
end

return TlActivityData