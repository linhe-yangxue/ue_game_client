local MsgConst = require("Msg.MsgConst")
local UIConst = require("UI.UIConst")
local mh_activity = DECLARE_MODULE("Msg.MsgHandle_Activity")

function mh_activity.s_activity_data_update(msg)
    ComMgrs.dy_data_mgr.activity_data:NotifyUpdateActivityData(msg)
end

function mh_activity.s_rush_activity_data_update(msg)
    ComMgrs.dy_data_mgr.activity_data:NotifyUpdateRankActivityData(msg)
end

function mh_activity.s_update_festival_activity_info(msg)
    ComMgrs.dy_data_mgr.festival_activity_data:UpdateFestivalActivityData(msg)
end

function mh_activity.s_update_fixed_action_point_info(msg)
    ComMgrs.dy_data_mgr.activity_data:NotifyUpdateStrengthRecoverActivity(msg)
end

function mh_activity.s_update_openservice_fund_data(msg)
    ComMgrs.dy_data_mgr.activity_data:NotifyUpdateServerFundInfo(msg)
end

function mh_activity.s_update_daily_recharge_data(msg)
    --ComMgrs.dy_data_mgr.activity_data:NotifyUpdateServerFundInfo(msg)
end

function mh_activity.s_update_monthly_card_data(msg)
    ComMgrs.dy_data_mgr.month_card_data:NotifyUpdateMonthCardInfo(msg)
end

function mh_activity.s_notify_monthly_card_expired(msg)
    ComMgrs.dy_data_mgr.month_card_data:NotifyMonthCardExpired(msg)
end



function mh_activity.s_update_first_recharge_info(msg)
    ComMgrs.dy_data_mgr.recharge_data:UpdateFirstRechargeInfo(msg.first_recharge)
end

function mh_activity.s_update_single_recharge_info(msg)
    ComMgrs.dy_data_mgr.recharge_data:UpdateSingleRechargeInfo(msg)
end

function mh_activity.s_end_recharge_activity(msg)
    ComMgrs.dy_data_mgr.recharge_data:UpdateSingleRechargeInfo(msg)
end

function mh_activity.s_close_recharge_activity(msg)
    ComMgrs.dy_data_mgr.recharge_data:UpdateSingleRechargeInfo(msg)
end

function mh_activity.s_update_recharge_draw_info(msg)
    ComMgrs.dy_data_mgr:ExUpdateDrawShopBuyTime(msg)
    ComMgrs.dy_data_mgr.recharge_data:UpdateRechargeDrawInfo(msg)
end

function mh_activity.s_update_accum_recharge_data(msg)
    ComMgrs.dy_data_mgr.recharge_data:NotifyUpdateAccumRecharge(msg)
end

function mh_activity.s_update_luxurycheckin_data(msg)
    ComMgrs.dy_data_mgr.recharge_data:NotifyUpdateLuxuryCheckin(msg)
end

function mh_activity.s_update_bar_unit_data(msg)
    ComMgrs.dy_data_mgr.bar_data:NotifyUpdateBarUnitData(msg)
end

function mh_activity.s_update_bar_count_data(msg)
    ComMgrs.dy_data_mgr.bar_data:NotifyUpdateBarGameCount(msg)
end

function mh_activity.s_update_ongoing_lover_activities(msg)
    print("情人礼包主动定时刷新推送-----" ,msg)
    ComMgrs.dy_data_mgr:ExUpdateLoverGiftInfo(msg)
end

return mh_activity