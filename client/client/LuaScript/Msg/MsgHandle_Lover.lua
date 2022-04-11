local mh_lover = DECLARE_MODULE("Msg.MsgHandle_Lover")

function mh_lover.s_online_lover(msg)
    ComMgrs.dy_data_mgr.lover_data:UpdateOnlineData(msg)
    ComMgrs.dy_data_mgr:ExUpdateVigor(msg)
end

function mh_lover.s_update_discuss_data(msg)
    ComMgrs.dy_data_mgr.lover_data:UpdateDiscussData(msg)
    ComMgrs.dy_data_mgr:ExUpdateVigor(msg)
end

function mh_lover.s_update_lover_info(msg)
    ComMgrs.dy_data_mgr.lover_data:UpdateLoverInfo(msg)
end

function mh_lover.s_update_child_info(msg)
    ComMgrs.dy_data_mgr.child_center_data:NotifyUpdateChildInfo(msg)
end

function mh_lover.s_add_lover(msg)
    ComMgrs.dy_data_mgr.lover_data:AddLoverData(msg)
end

function mh_lover.s_update_lover_train_info(msg)
    ComMgrs.dy_data_mgr.training_centre_data:NotifyUpdateLoverTrainInfo(msg)
end

function mh_lover.s_lover_train_finish(msg)
    ComMgrs.dy_data_mgr.training_centre_data:NotifyLoverTrainFinish(msg)
end

function mh_lover.s_update_lover_shop(msg)
    ComMgrs.dy_data_mgr:ExUpdateLoverShopBuyTime(msg)
end

function mh_lover.s_update_lover_activity(msg)
    ComMgrs.dy_data_mgr:ExUpdateLoverGiftBuy(msg)
end



return mh_lover