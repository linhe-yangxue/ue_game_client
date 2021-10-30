local UnitConst = require("Unit.UnitConst")
local UnitCls = require("Unit.Unit")
local EventUtil = require("BaseUtilities.EventUtil")
local UnitMgrExFuncs = require("ExFuncs.UnitMgrExFuncs")

local UnitMgr = class("Mgrs.Common.UnitMgr")

ADD_MODULE_FUNCS(UnitMgr, UnitMgrExFuncs)

EventUtil.GeneratorEventFuncs(UnitMgr, "CreateUnitEvent")
EventUtil.GeneratorEventFuncs(UnitMgr, "DestroyUnitEvent")

function UnitMgr:DoInit()
    self._unit_guid_tb = {}
    self._unit_delay_del_tb = {}
    self._unit_uuid_tb = {}
    self:ExDoInit()
end

function UnitMgr:CreateUnit(param_tb)
    param_tb = CSConst.StCreateUnit(param_tb)
    local guid = param_tb.guid
    local uuid = param_tb.uuid
    self._unit_delay_del_tb[guid] = nil
    if self._unit_guid_tb[guid] then
        self._unit_guid_tb[guid]:DoDestroy()
    end
    local unit = UnitCls.New()
    self._unit_guid_tb[guid] = unit
    if uuid and uuid ~= "" then
        self._unit_uuid_tb[uuid] = unit
    end
    unit.need_sync_load = param_tb.need_sync_load
    unit:DoInit()
    unit:BuildUnit(param_tb)
    -- unit:RegisterUnitDeathEndEvent("UnitMgr", self.OnUnitDeathEnd, self)
    self:DispatchCreateUnitEvent(unit)
    self:ExCreatUnit(unit)
    return unit
end

function UnitMgr:Update(delta_time)
    for guid, _ in pairs(self._unit_delay_del_tb) do
        self._unit_guid_tb[guid] = nil
    end
    self._unit_delay_del_tb = {}
    for guid, unit in pairs(self._unit_guid_tb) do
        if not self._unit_delay_del_tb[guid] then
            unit:Update(delta_time)
        end
    end
    if self.__UpdateEventCbRemove then
        self:__UpdateEventCbRemove()
    end
end

function UnitMgr:ClearAll()
    for _, unit in pairs(self._unit_guid_tb) do
        self:DestroyUnit(unit)
    end
    self:ExClearAll()
    self._unit_guid_tb = {}
    self._unit_delay_del_tb = {}
    self._unit_uuid_tb = {}
end

function UnitMgr:DoDestroy()
    self:ClearAll()
    if self.__ClearAllEventCb then
        self:__ClearAllEventCb()
    end
end

function UnitMgr:OnUnitDeathEnd(unit)
    if not unit:IsHero() then
        self:DestroyUnit(unit)
    end
end

function UnitMgr:CreateUnitAutoGuid(param_tb)
    param_tb.guid = ComMgrs.dy_data_mgr:NewGuid()
    return self:CreateUnit(param_tb)
end

function UnitMgr:GetUnitByGuid(guid)
    if self._unit_delay_del_tb[guid] then
        return nil
    end
    return self._unit_guid_tb[guid]
end

function UnitMgr:GetUnitByUuid(uuid)
    local unit = self._unit_uuid_tb[uuid]
    if unit and self._unit_delay_del_tb[unit.guid] then
        return nil
    end
    return unit
end

function UnitMgr:DestroyUnit(unit)
    if unit then
        if unit.uuid then
            self._unit_uuid_tb[unit.uuid] = nil
        end
        if not self._unit_delay_del_tb[unit.guid] then
            self._unit_delay_del_tb[unit.guid] = true
            unit:DoDestroy()
            self:DispatchDestroyUnitEvent(unit)
        end
    end
end

function UnitMgr:DestroyUnitByGuid(guid)
    local unit = self._unit_guid_tb[guid]
    self:DestroyUnit(unit)
end

--AI编辑器调用
function UnitMgr:GetAIList(ai_name)
    local name_list = {}
    local ai_list = {}
    local ret = 0
    for guid, unit in pairs(self._unit_guid_tb) do
        if unit._ai_cmp and unit._ai_cmp.ai_tree and unit._ai_cmp.ai_tree.ai_data.id == ai_name then
            table.insert(name_list, guid)
            table.insert(ai_list, unit._ai_cmp.ai_tree.root_node)
            ret = ret + 1
        end
    end
    return ret, name_list, ai_list
end

return UnitMgr
