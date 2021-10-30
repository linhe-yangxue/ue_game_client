local MsgConst = require("Msg.MsgConst")
local mh_treasure = DECLARE_MODULE("Msg.MsgHandle_Treasure")

function mh_treasure.s_online_grab_treasure(msg)
	ComMgrs.dy_data_mgr.grab_treasure_data:NotifyOnLineGrabTreasure(msg)
end

function mh_treasure.s_update_grab_treasure(msg)
	ComMgrs.dy_data_mgr.grab_treasure_data:NotifyUpdateGrabTreasure(msg)
end

return mh_treasure