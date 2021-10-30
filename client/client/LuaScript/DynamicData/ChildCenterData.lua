local EventUtil = require("BaseUtilities.EventUtil")
local CSConst = require("CSCommon.CSConst")
local CSFunction = require("CSCommon.CSFunction")
local UIConst = require("UI.UIConst")
local ChildCenterData = class("DynamicData.ChildCenterData")

EventUtil.GeneratorEventFuncs(ChildCenterData, "UpdateChildInfoEvent")
EventUtil.GeneratorEventFuncs(ChildCenterData, "ChildSubmitAptitudeEvent")
EventUtil.GeneratorEventFuncs(ChildCenterData, "ChildGrowUpEvent")
EventUtil.GeneratorEventFuncs(ChildCenterData, "UpdateMarryRequestEvent")
EventUtil.GeneratorEventFuncs(ChildCenterData, "UpdateAdultChildInfo")

function ChildCenterData:DoInit()
    self.child_data_dict = {}
    self.child_list = {}
    self.child_grid_count = 0
    self.adult_data = {}
    self.assign_request_marry_list = {}
    self.server_request_list = {}
    self.world_request_list = {}
end

function ChildCenterData:NotifyUpdateChildInfo(msg)
    self.child_grid_count = msg.grid_num or self.child_grid_count
    if msg.propose_object_list then -- 提亲请求
        self:UpdateRequestMarry(msg.propose_object_list, CSConst.ChildSendRequest.Assign)
    end

    if msg.child then
        for id, child_data in pairs(msg.child) do
            if child_data.child_status == CSConst.ChildStatus.Adult or child_data.child_status == CSConst.ChildStatus.Married then
                self:AddToAdultList(child_data)
                if self.child_data_dict[child_data.child_id] then
                    for index, child in ipairs(self.child_list) do
                        if child.child_id == child_data.child_id then
                            table.remove(self.child_list, index)
                            break
                        end
                    end
                    self.child_data_dict[child_data.child_id] = nil
                    self:DispatchChildGrowUpEvent(child_data)
                    return
                end
            else
                if child_data.level == 1 and child_data.exp == 0 then
                    self:DispatchChildSubmitAptitudeEvent(child_data)
                end
                if not self.child_data_dict[id] then
                    table.insert(self.child_list, child_data)
                end
                self.child_data_dict[id] = child_data
            end
        end
    end
    table.sort(self.child_list, function (child1, child2)
        return child1.birth_time < child2.birth_time
    end)
    self:_UpdateRaisingRedPoint()
    self:DispatchUpdateChildInfoEvent()
end

--  提亲消息
function ChildCenterData:UpdateRequestMarry(child_dict, server_type, page_id)
    for i, marry_info in ipairs(child_dict) do
        marry_info.server_type = server_type
    end
    if server_type == CSConst.ChildSendRequest.Assign then
        self.assign_request_marry_list = child_dict
        self:_UpdateMarryRedPoint()
        self:DispatchUpdateMarryRequestEvent()
    elseif server_type == CSConst.ChildSendRequest.Service then
        for i = 10 * (page_id - 1) + 1, 10 * page_id do
            self.server_request_list[i] = child_dict[i - 10 * (page_id - 1)]
        end
    elseif server_type == CSConst.ChildSendRequest.Cross then
        for i = 10 * (page_id - 1) + 1, 10 * page_id do
             self.world_request_list[i] = child_dict[i - 10 * (page_id - 1)]
        end
    end
end

function ChildCenterData:AddToAdultList(child_data)
    local need_update = false
    self.adult_data[child_data.child_id] = child_data
    if not (child_data.marry and child_data.child_status == CSConst.ChildStatus.Married) then
        need_update = true
    end
    if need_update then
        self:DispatchUpdateAdultChildInfo()
    end
end

function ChildCenterData:GetChildList()
    return self.child_list
end

-- 包括成人和小孩
function ChildCenterData:GetChildData(child_id)
    return self:GetChildDataById(child_id) or self:GetAdultChildDataById(child_id)
end

-- 只有小孩
function ChildCenterData:GetChildDataById(id)
    return self.child_data_dict[id]
end

function ChildCenterData:GetChildDataByIndex(index)
    return self.child_data_dict[self.child_list[index].child_id]
end

function ChildCenterData:GetChildGridCount()
    return self.child_grid_count
end

function ChildCenterData:GetChildCount()
    return #self.child_list
end

function ChildCenterData:GetAllChildCount()
    local child_count = #self.child_list
    for k, v in pairs(self.adult_data) do
        child_count = child_count + 1
    end
    return child_count
end

-- 只有成人
function ChildCenterData:GetAdultChildDataById(id)
    return self.adult_data[id]
end

function ChildCenterData:GetAdultChildList(is_marry)
    local ret = {}
    for _, child in pairs(self.adult_data) do
        if is_marry == self:_IsChildMarry(child) then
            table.insert(ret, child)
            child.total_attr = self:GetChildTotalAttr(child.child_id)
        end
    end
    table.sort(ret, function(v1, v2)
        return v1.total_attr > v2.total_attr
    end)
    return ret
end

function ChildCenterData:GetMarriedChildList()
    return self:GetAdultChildList(true)
end

function ChildCenterData:GetChildTotalAttr(child_id)
    local attr_tb = self.adult_data[child_id].attr_dict
    return table.sum(attr_tb)
end

function ChildCenterData:GetChildTotalTalent(child_id)
    local talent_tb = self.adult_data[child_id].aptitude_dict
    return table.sum(talent_tb)
end

function ChildCenterData:GetAllChildAttrAdd()
    local ret = 0
    for i,v in pairs(self.adult_data) do
        local val = self:GetChildTotalAttr(v.child_id)
        ret = ret + val
    end
    return ret
end

function ChildCenterData:GetAllChildMarryAttrAdd()
    local marry_tb = self:GetAdultChildList(true)
    local ret = 0
    for i,v in ipairs(marry_tb) do
        ret = ret + table.sum(v.marry.attr_dict)
    end
    return ret
end

function ChildCenterData:GerServerRequestList()
    return self.server_request_list
end

function ChildCenterData:GerWorldRequestList()
    return self.world_request_list
end

--  定向提亲
function ChildCenterData:GetAssignRequestMarryList()
    local ret = {}
    self:_GetRequestMarryFromList(self.assign_request_marry_list, ret, CSConst.ChildSendRequest.Assign)
    return ret
end

function ChildCenterData:_GetRequestMarryFromList(list, ret, server_type)
    if not list then return end
    for _, v in pairs(list) do
        v.server_type = server_type
        table.insert(ret, v)
    end
end

function ChildCenterData:GetMarryTargetChild(target_child)
    local ret = {}
    for i,v in pairs(self:GetAdultChildList(false)) do
        if v.grade == target_child.grade and v.sex ~= target_child.sex then
            table.insert(ret, v)
        end
    end
    return ret
end

function ChildCenterData:GetUnConfirmMarryChild()
    for k,v in pairs(self.adult_data) do
        if v.marry then
            if v.child_status == CSConst.ChildStatus.Adult then
                return v
            end
        end
    end
    return nil
end

--  正在提亲中
function ChildCenterData:IsRequestMarry(child_info)
    if child_info.apply_time and not self:_IsChildMarry(child_info) then
        return true
    end
    return false
end

function ChildCenterData:_IsChildMarry(child_info)
    if child_info.marry then
        return true
    end
    return false
end

function ChildCenterData:CheckChildNamelegality(name)
    local ret, err = CSFunction.check_player_name_legality(name)
    if not ret then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.NAME_ERROR_STR[err])
        return false
    end
    if self:CheckChildNameRepeat(name) then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.CHILD_NAME_REPEAT)
        return false
    end
    return true
end

function ChildCenterData:CheckChildNameRepeat(name)
    for _, child_data in pairs(self.child_data_dict) do
        if name == child_data.name then return true end
    end
    for _, child_data in pairs(self.adult_data) do
        if name == child_data.name then return true end
    end
    return false
end

function ChildCenterData:GetChildVitalityLimit(child_level)
    local exp_data = SpecMgrs.data_mgr:GetChildExpData(child_level)
    local vip_level = ComMgrs.dy_data_mgr:ExGetRoleVip()
    local vip_data = SpecMgrs.data_mgr:GetVipData(vip_level)
    if not vip_data then return exp_data.vitality_limit end
    return exp_data.vitality_limit + vip_data.child_max_vitality_num
end

function ChildCenterData:GetChildUnitId(child_data, status)
    if child_data.marry then
        if child_data.sex == CSConst.Sex.Man then
            local boy_unit = self:_GetChildUnitId(child_data, status)
            local girl_unit = self:_GetChildUnitId(child_data.marry, CSConst.ChildStatus.Married)
            return boy_unit, {boy_unit, girl_unit}
        elseif child_data.sex == CSConst.Sex.Woman then
            local boy_unit = self:_GetChildUnitId(child_data.marry, CSConst.ChildStatus.Married)
            local girl_unit = self:_GetChildUnitId(child_data, status)
            return girl_unit, {boy_unit, girl_unit}
        end
    else
        return self:_GetChildUnitId(child_data, status)
    end
end

function ChildCenterData:_GetChildUnitId(child_data, status)
    local status = child_data.child_status or status
    local child_grow_up_level = SpecMgrs.data_mgr:GetParamData("child_grow_up_level").f_value
    if child_data.child_status == CSConst.ChildStatus.Growing and child_data.level >= child_grow_up_level then
        status = CSConst.ChildStatus.Child
    end
    local display_data = SpecMgrs.data_mgr:GetChildDisplayData(child_data.display_id)
    return display_data[child_data.sex][status]
end

--更新抚养孩子的红点
function ChildCenterData:_UpdateRaisingRedPoint()
    local param_dict = {}
    for child_id, child_data in pairs(self.child_data_dict) do
        param_dict[child_id] = self:_CheckRaisingChild(child_data)
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Child.Raising, param_dict)
end

--检查该孩子当前是否可操作
function ChildCenterData:_CheckRaisingChild(child_data)
    if not child_data.name then
        return 1
    end
    if child_data.vitality_num and child_data.vitality_num > 0 then
        return 1
    end
    local grade_data = SpecMgrs.data_mgr:GetChildQualityData(child_data.grade)
    if child_data.level == grade_data.level_limit then
        return 1
    end
    return
end

--更新提亲请求的红点
function ChildCenterData:_UpdateMarryRedPoint()
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Child.Marry, {next(self.assign_request_marry_list) and 1 or 0})
end

return ChildCenterData