local MsgConst = require("Msg.MsgConst")
local mh_hunting = DECLARE_MODULE("Msg.MsgHandle_Hunting")

function mh_hunting.s_update_hunt_data(msg)
    ComMgrs.dy_data_mgr.hunting_data:UpdateHuntingData(msg)
    ComMgrs.dy_data_mgr:ExUpdateHuntShopData(msg)
end

function mh_hunting.s_rare_animal_appear(msg)
    ComMgrs.dy_data_mgr.hunting_data:NotifyRareAnimalAppear(msg)
end

function mh_hunting.s_update_curr_ground(msg)
    ComMgrs.dy_data_mgr.hunting_data:NotifyUpdateCurrGround(msg)
end

function mh_hunting.s_hunt_ground_kill_reward(msg)
    ComMgrs.dy_data_mgr.hunting_data:NotifyHuntGroundKillReward(msg)
end

function mh_hunting.s_hunt_rare_animal_kill_reward(msg)
    ComMgrs.dy_data_mgr.hunting_data:NotifyHuntRareAnimalKillReward(msg)
end

return mh_hunting