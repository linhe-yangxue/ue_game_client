local DataMgr = DECLARE_MODULE("Mgrs.Special.DataMgr")

function DataMgr.New()
    local d_m = require("CSCommon.data_mgr")
    d_m.IS_CLIENT = true
    return d_m
end

return DataMgr
