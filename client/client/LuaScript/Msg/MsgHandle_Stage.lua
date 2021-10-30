local MsgConst = require("Msg.MsgConst")
local mh_stage = DECLARE_MODULE("Msg.MsgHandle_Stage")

function mh_stage.s_update_stage_info(msg)
    ComMgrs.dy_data_mgr.strategy_map_data:NotifyUpdateStageInfo(msg)
end

function mh_stage.s_update_city_info(msg)
    ComMgrs.dy_data_mgr.strategy_map_data:NotifyUpdateCityInfo(msg)
end

function mh_stage.s_update_country_info(msg)
    ComMgrs.dy_data_mgr.strategy_map_data:NotifyUpdateCountryInfo(msg)
end


return mh_stage