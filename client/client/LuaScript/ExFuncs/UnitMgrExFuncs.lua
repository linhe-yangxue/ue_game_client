local UnitMgr = DECLARE_MODULE("ExFuncs.UnitMgrExFuncs")

function UnitMgr:ExDoInit()
    self.go = GameObject("UnitMgr")
    GameObject.DontDestroyOnLoad(self.go)
end

function UnitMgr:ExClearAll()
end

function UnitMgr:ExCreatUnit(unit)
end

return UnitMgr
