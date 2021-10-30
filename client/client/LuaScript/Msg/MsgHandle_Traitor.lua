local MsgConst = require("Msg.MsgConst")
local mh_traitor = DECLARE_MODULE("Msg.MsgHandle_Traitor")

function mh_traitor.s_update_traitor_info(msg)
    ComMgrs.dy_data_mgr.traitor_data:NotifyUpdateTraitorInfo(msg)
    ComMgrs.dy_data_mgr:ExUpdateFeatsShopBuyTime(msg)
end

function mh_traitor.s_delete_traitor(msg)
    ComMgrs.dy_data_mgr.traitor_data:NotifyDeleteTraitor(msg)
end

function mh_traitor.s_traitor_boss_open(msg)
    ComMgrs.dy_data_mgr.traitor_boss_data:SetTraitorOpen(true)
end

function mh_traitor.s_traitor_boss_close(msg)
    ComMgrs.dy_data_mgr.traitor_boss_data:SetTraitorOpen(false)
end

function mh_traitor.s_update_traitor_boss_challenge_num(msg)
	ComMgrs.dy_data_mgr.traitor_boss_data:UpdateTraitorChallengeNum(msg)
end

function mh_traitor.s_update_traitor_boss_info(msg)
	ComMgrs.dy_data_mgr.traitor_boss_data:UpdateTraitorBossInfo(msg)
end

function mh_traitor.s_traitor_boss_revive(msg)
	ComMgrs.dy_data_mgr.traitor_boss_data:UpdateTraitorBossRevive(msg)
end

function mh_traitor.s_update_cross_cooling_ts(msg)
	ComMgrs.dy_data_mgr.traitor_boss_data:UpdateCrossCoolingTs(msg)
end

function mh_traitor.s_update_cross_traitor_info(msg)
	ComMgrs.dy_data_mgr.traitor_boss_data:UpdateCrossTraitorInfo(msg)
end

function mh_traitor.s_cross_traitor_boss_fight(msg)
	ComMgrs.dy_data_mgr.traitor_boss_data:UpdateCrossTraitorBossFight(msg)
end

return mh_traitor