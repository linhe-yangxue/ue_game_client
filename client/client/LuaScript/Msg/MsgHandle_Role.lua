local MsgConst = require("Msg.MsgConst")
local UIConst = require("UI.UIConst")
local mh_role = DECLARE_MODULE("Msg.MsgHandle_Role")

function mh_role.s_update_base_info(msg)
    ComMgrs.dy_data_mgr:ExUpdateRoleBaseInfo(msg)
end

function mh_role.s_update_total_hall_info(msg)
    ComMgrs.dy_data_mgr.great_hall_data:NotifyUpdateData(msg)
end

function mh_role.s_update_prison_info(msg)
    ComMgrs.dy_data_mgr.prison_data:UpdatePrisonData(msg)
end

function mh_role.s_update_newbie_guide_info(msg)
    SpecMgrs.guide_mgr:UpdateNewbieGuideInfo(msg)
end

function mh_role.s_chat(msg)
    ComMgrs.dy_data_mgr.chat_data:NotifyNewChat(msg)
end

function mh_role.s_update_travel_info(msg)
    ComMgrs.dy_data_mgr.travel_data:NotifyUpdateTravelInfo(msg)
    ComMgrs.dy_data_mgr:ExUpdatePhysicalPower(msg)
end

function mh_role.s_update_daily_dare_info(msg)
    ComMgrs.dy_data_mgr.daily_dare_data:NotifyUpdateDailyDareData(msg)
end

function mh_role.s_update_dare_tower_info(msg)
    ComMgrs.dy_data_mgr.dare_tower_data:NotifyUpdateDareTowerInfo(msg)
end

function mh_role.s_update_salon_info(msg)
    ComMgrs.dy_data_mgr.salon_data:NotifyUpdateSalonInfo(msg)
end

function mh_role.s_update_vitality(msg)
    ComMgrs.dy_data_mgr:ExUpdateVitality(msg)
end

function mh_role.s_update_action_point(msg)
    ComMgrs.dy_data_mgr:ExUpdateActionPoint(msg)
end

function mh_role.s_update_party_info(msg)
    ComMgrs.dy_data_mgr.party_data:NotifyUpdatePartyInfo(msg)
end

function mh_role.s_update_arena_info(msg)
    ComMgrs.dy_data_mgr:ExUpdateArenaData(msg)
end

function mh_role.s_update_task_info(msg)
    ComMgrs.dy_data_mgr.task_data:NotifyUpdateTaskInfo(msg)
end

function mh_role.s_level_event_trigger(msg)
	ComMgrs.dy_data_mgr.func_unlock_data:NotifyLevelEventTrigger(msg)
end

function mh_role.s_update_salon_shop(msg)
    ComMgrs.dy_data_mgr:ExUpdateSalonData(msg)
end

function mh_role.s_update_party_shop(msg)
    ComMgrs.dy_data_mgr:ExUpdatePartyData(msg)
end

function mh_role.s_update_normal_shop_info(msg)
    ComMgrs.dy_data_mgr:ExUpdateNormalShopData(msg)
end

function mh_role.s_update_crystal_shop_info(msg)
    ComMgrs.dy_data_mgr:ExUpdateCrystalShopBuyTime(msg)
end

function mh_role.s_update_daily_active_info(msg)
    ComMgrs.dy_data_mgr.daily_active_data:NotifyUpdateDailyActiveInfo(msg)
end

function mh_role.s_update_achievement_info(msg)
    ComMgrs.dy_data_mgr.achievement_data:NotifyUpdateAchievementInfo(msg)
end

function mh_role.s_update_hero_shop(msg)
    ComMgrs.dy_data_mgr:ExUpdateHeroShopBuyTime(msg)
end

function mh_role.s_update_vip_info(msg)
    ComMgrs.dy_data_mgr.vip_data:NotifyUpdateVipInfo(msg)
end

function mh_role.s_update_vip_shop_info(msg)
    ComMgrs.dy_data_mgr.vip_data:NotifyUpdateVipShopInfo(msg)
end

return mh_role