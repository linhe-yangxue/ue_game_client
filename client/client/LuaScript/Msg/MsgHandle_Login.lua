local MsgConst = require("Msg.MsgConst")
local mh_login = DECLARE_MODULE("Msg.MsgHandle_Login")

function mh_login.s_notify_msg(msg)
    if not msg.notify_type or msg.notify_type == CSConst.NotifyType.FloatWord then
        SpecMgrs.ui_mgr:ShowTipMsg(msg.errstr)
    elseif msg.notify_type == CSConst.NotifyType.DialogBox then
        SpecMgrs.ui_mgr:ShowMsgBox(msg.errstr)
    elseif msg.notify_type == CSConst.NotifyType.AddItem then
        SpecMgrs.ui_mgr:ShowItemTipMsg(msg.errstr)
    end
end

function mh_login.s_kick_out(msg)
    ComMgrs.dy_data_mgr:ExSetKickOutStatus(true, msg.relogin)
    SpecMgrs.stage_mgr:GotoStage("LoginStage")
end

function mh_login.s_notify_no_role(msg)
    SpecMgrs.stage_mgr:GotoStage("CreateRoleStage")
end

function mh_login.s_online_server_time(msg)
    Time:SetServerTime(msg.server_time)
end

return mh_login
