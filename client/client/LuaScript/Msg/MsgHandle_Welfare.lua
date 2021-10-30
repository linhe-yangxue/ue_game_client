local MsgConst = require("Msg.MsgConst")
local mh_welfare = DECLARE_MODULE("Msg.MsgHandle_Welfare")

function mh_welfare.s_update_check_in_weekly_info(msg)
    ComMgrs.dy_data_mgr.check_data:NotifyUpdateWeekCheckInfo(msg)
end

function mh_welfare.s_update_check_in_monthly_info(msg)
    ComMgrs.dy_data_mgr.check_data:NotifyUpdateMonthCheckInfo(msg)
end

function mh_welfare.s_update_first_week_info(msg)
    ComMgrs.dy_data_mgr.check_data:NotifyUpdateFirstWeekCheckInfo(msg)
end

function mh_welfare.s_update_first_week_task(msg)
	ComMgrs.dy_data_mgr.check_data:NotifyUpdateFirstWeekTaskInfo(msg)
end

return mh_welfare