local MsgConst = require("Msg.MsgConst")
local mh_hero = DECLARE_MODULE("Msg.MsgHandle_Hero")

function mh_hero.s_online_hero(msg)
    ComMgrs.dy_data_mgr.night_club_data:NotifyAllHero(msg)
end

function mh_hero.s_update_hero_info(msg)
    ComMgrs.dy_data_mgr.night_club_data:NotifyUpdateHero(msg)
end

function mh_hero.s_add_hero(msg)
    ComMgrs.dy_data_mgr.night_club_data:NotifyAddHero(msg)
end

function mh_hero.s_update_lineup_info(msg)
    ComMgrs.dy_data_mgr.night_club_data:NotifyUpdateLineupInfo(msg)
end

function mh_hero.s_update_lineup_equip_info(msg)
    ComMgrs.dy_data_mgr.night_club_data:NotifyUpdateLineupEquipInfo(msg)
end

function mh_hero.s_update_lineup_master_lv(msg)
    ComMgrs.dy_data_mgr.night_club_data:NotifyUpdateLineupMasterLv(msg)
end

function mh_hero.s_clear_equip_lucky_value(msg)
    ComMgrs.dy_data_mgr.bag_data:NotifyClearEquipLuckyValue(msg)
end

function mh_hero.s_clear_hero_destiny_exp(msg)
    ComMgrs.dy_data_mgr.night_club_data:NotifyClearHeroDestinyExp(msg)
end

function mh_hero.s_update_reinforcements(msg)
    ComMgrs.dy_data_mgr.night_club_data:NotifyUpdateAidInfo(msg)
end

return mh_hero