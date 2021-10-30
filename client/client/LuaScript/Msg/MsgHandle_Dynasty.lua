local MsgConst = require("Msg.MsgConst")
local mh_dynasty = DECLARE_MODULE("Msg.MsgHandle_Dynasty")

function mh_dynasty.s_update_dynasty_info(msg)
    ComMgrs.dy_data_mgr.dynasty_data:NotifyUpdateDynastyInfo(msg)
end

function mh_dynasty.s_update_dynasty_quit_ts(msg)
    ComMgrs.dy_data_mgr.dynasty_data:NotifyUpdateDynastyQuitTs(msg)
end

function mh_dynasty.s_join_dynasty(msg)
    ComMgrs.dy_data_mgr.dynasty_data:NotifyJoinDynasty(msg)
end

function mh_dynasty.s_kicked_out_dynasty(msg)
    ComMgrs.dy_data_mgr.dynasty_data:NotifyKickedOutDynasty(msg)
end

function mh_dynasty.s_update_dynasty_spell_dict(msg)
    ComMgrs.dy_data_mgr.dynasty_data:NotifyUpdateDynastySpellInfo(msg)
end

function mh_dynasty.s_update_dynasty_shop_info(msg)
    ComMgrs.dy_data_mgr:ExUpdateDynastyShopBuyTime(msg)
end

function mh_dynasty.s_update_dynasty_member_apply_dict(msg)
    ComMgrs.dy_data_mgr.dynasty_data:NotifyUpdateMemberApplyDict(msg)
end

function mh_dynasty.s_update_dynasty_member_job_info(msg)
    ComMgrs.dy_data_mgr.dynasty_data:NotifyUpdateMemberJob(msg)
end

function mh_dynasty.s_dynasty_challenge_refresh()
    ComMgrs.dy_data_mgr.dynasty_data:NotifyRefreshDynastyChallenge()
end

function mh_dynasty.s_dynasty_compete_refresh()
    ComMgrs.dy_data_mgr.dynasty_data:NotifyRefreshDynastyBattle()
end

return mh_dynasty