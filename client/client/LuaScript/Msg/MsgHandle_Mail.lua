local MsgConst = require("Msg.MsgConst")
local mh_mail = DECLARE_MODULE("Msg.MsgHandle_Mail")

function mh_mail.s_online_mail(msg)
    ComMgrs.dy_data_mgr.mail_data:NotifyUpdateMailUnRead(msg.has_unread)
end

function mh_mail.s_add_mail(msg)
    ComMgrs.dy_data_mgr.mail_data:NotifyUpdateMailUnRead(true)
end

return mh_mail