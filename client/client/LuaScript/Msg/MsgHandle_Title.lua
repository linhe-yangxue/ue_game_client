local MsgConst = require("Msg.MsgConst")
local mh_title = DECLARE_MODULE("Msg.MsgHandle_Title")

function mh_title.s_update_worship_data(msg)
    ComMgrs.dy_data_mgr.church_data:NotifyUpdateWorshipData(msg)
end

function mh_title.s_update_title_data(msg)
    ComMgrs.dy_data_mgr.title_data:NotifyTitleInfo(msg)
end

function mh_title.s_update_wearing_id(msg)
    ComMgrs.dy_data_mgr.title_data:NotifyWearTitle(msg)
end

function mh_title.s_notify_add_title(msg)
    ComMgrs.dy_data_mgr.title_data:NotifyAddTitle(msg)
end

function mh_title.s_notify_del_title(msg)
    ComMgrs.dy_data_mgr.title_data:NotifyDeleteTitle(msg)
end

return mh_title