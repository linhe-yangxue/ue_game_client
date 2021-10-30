local mh_recharge = DECLARE_MODULE("Msg.MsgHandle_Recharge")

function mh_recharge.s_update_recharge_info(msg)
    ComMgrs.dy_data_mgr.recharge_data:UpdateFirstRechargeState(msg)
end

return mh_recharge