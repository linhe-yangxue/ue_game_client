local mh_train = DECLARE_MODULE("Msg.MsgHandle_Train")

--  试炼
function mh_train.s_update_train_info(msg)
    ComMgrs.dy_data_mgr.experiment_data:NotifyUpdateExperimentData(msg)
end

function mh_train.s_update_train_war_info(msg)
    ComMgrs.dy_data_mgr.experiment_data:NotifyUpdateTrainWarInfo(msg)
end

function mh_train.s_update_train_shop(msg)
    ComMgrs.dy_data_mgr:ExUpdateTrainShopData(msg)
end

return mh_train