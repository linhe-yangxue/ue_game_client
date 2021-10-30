ComMgrs = DECLARE_MODULE("CommonMgrs")

if not ComMgrs.__RELOADING then 
    ComMgrs.dy_data_mgr = require("Mgrs.Common.DynamicDataMgr").New()
    ComMgrs.unit_mgr = require("Mgrs.Common.UnitMgr").New()
    -- ComMgrs.spell_mgr = require("Mgrs.Common.SpellMgr").New()
    -- ComMgrs.map_mgr = require("Mgrs.Common.MapMgr").New()
end

function ComMgrs:DoInit()
    self.dy_data_mgr:DoInit()
    self.unit_mgr:DoInit()
    -- self.spell_mgr:DoInit()
    -- self.map_mgr:DoInit()
end

function ComMgrs:Update(delta_time)
    self.dy_data_mgr:Update(delta_time)
    self.unit_mgr:Update(delta_time)
    -- self.spell_mgr:Update(delta_time)
    -- self.map_mgr:Update(delta_time)
end

function ComMgrs:DoDestroy()
    self.dy_data_mgr:DoDestroy()
    -- self.spell_mgr:DoDestroy()
    self.unit_mgr:DoDestroy()
    -- self.map_mgr:DoDestroy()
end
