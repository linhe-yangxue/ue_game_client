local DynamicDataMgrExFuncs = require("ExFuncs.DynamicDataMgrExFuncs")
local EventUtil = require("BaseUtilities.EventUtil")
local DynamicDataMgr = class("Mgrs.Common.DynamicDataMgr")

ADD_MODULE_FUNCS(DynamicDataMgr,DynamicDataMgrExFuncs)

-- 创建__UpdateEventCbRemove和__ClearAllEventCb 添加新事件时删除
EventUtil.GeneratorEventFuncs(DynamicDataMgr, "TestEvent")

function DynamicDataMgr:DoInit()
    self:ExDoInit()
end

function DynamicDataMgr:Update(delta_time)
    if self.__UpdateEventCbRemove then
        self:__UpdateEventCbRemove()
    end
    self:ExUpdate(delta_time)
end

function DynamicDataMgr:NewGuid()
    return self:ExNewGuid()
end

function DynamicDataMgr:ClearAll()
    self:ExClearAll()
end

function DynamicDataMgr:DoDestroy()
    self:ClearAll()
    if self.__ClearAllEventCb then
        self:__ClearAllEventCb()
    end
end

return DynamicDataMgr