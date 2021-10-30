local RedPointMgr = class("Mgrs.Special.RedPointMgr")

local redpoint_type_class = {
    [1] = require("UI.RedPointTypeClass.RedPointNormal"),
    [2] = require("UI.RedPointTypeClass.RedPointWithNumber"),
    [3] = require("UI.RedPointTypeClass.RedPointBubble"),
    [4] = require("UI.RedPointTypeClass.RedPointHighLight")
}

function RedPointMgr:DoInit()
    self.controler_dict = {} --保存所有控制ID以及注册了该控制ID的红点  key: control_id, value: {[redpoint_go] = true, ...}
    self.controler_state_dict = {} --保存所有控制ID的状态参数表  key: control_id, value: param_dict{[sub_id] = (int)value, ...}

    self.redpoint_dict = {} --保存所有红点  key: redpoint_go, value: {redpoint_class = redpoint_class, control_id_list = control_id_list, sub_id = sub_id}

    self.static_redpoint_datas = {} --保存excel表中UI的各个红点所对应的UI路径和control_id
    self:_ReadExcelData(self.static_redpoint_datas)
    self.ui_redpoint_class_list = {}--保存各个UI中新增出来的红点  key: ui_name, value: redpoint_class_list
end

function RedPointMgr:DoDestroy()
    self.controler_dict = nil
    self.controler_state_dict = nil

    self.redpoint_dict = nil

    self.static_redpoint_datas = nil
    self.ui_redpoint_class_list = nil
end

--------- interface defines begin --------
--根据填表内容，为该UI新增表中的所有红点
function RedPointMgr:AddRedPointByData(ui_name, ui)
    local redpoint_datas = self.static_redpoint_datas[ui_name]
    if not redpoint_datas then
        return
    end
    local redpoint_class_list = {}
    for redpoint_id, data in pairs(redpoint_datas) do
        local parent = ui:_GetWidgetByPath(data.path)
        if not parent then
            PrintError(string.format("AddRedPointByData: Can't FindChild '%s' In %s!", data.path, ui_name))
        end
        local redpoint_data = SpecMgrs.data_mgr:GetRedPointData(redpoint_id)
        local anchor_v2 = nil
        if redpoint_data.anchor_x and redpoint_data.anchor_y then
            anchor_v2 = Vector2.New(redpoint_data.anchor_x, redpoint_data.anchor_y)
        end
        local pivot_v2 = nil
        if redpoint_data.pivot_x and redpoint_data.pivot_y then
            pivot_v2 = Vector2.New(redpoint_data.pivot_x, redpoint_data.pivot_y)
        end
        local redpoint_class = self:AddRedPoint(ui, parent, redpoint_data.type, data.control_id_list, nil, anchor_v2, pivot_v2)
        table.insert(redpoint_class_list, redpoint_class)
    end
    self.ui_redpoint_class_list[ui_name] = redpoint_class_list
end

--移除该UI中所有根据填表内容新增的红点
function RedPointMgr:RemoveRedPointByData(ui_name)
    local redpoint_class_list = self.ui_redpoint_class_list[ui_name]
    if not redpoint_class_list then
        return
    end
    for _, redpoint_class in ipairs(redpoint_class_list) do
        self:RemoveRedPoint(redpoint_class)
    end
end

--设置红点控制ID的状态
--control_id：控制ID（唯一）
--param_dict：若该控制ID拥有次级ID，此参数应为table{[sub_id_1] = int参数1, [sub_id_2] = int参数2, ...}；若无次级ID，则此参数应为table{ int参数 }。
--int参数：等于 0 时红点隐藏，大于 0 时红点显示（数值型红点同时还会显示int参数的值）
function RedPointMgr:SetControlIdActive(control_id, param_dict)
    if not control_id then
        PrintError("SetControlIdActive: Parameter 'control_id' Can't Be Nil!")
        return
    end
    self:_UpdateControlId(control_id, param_dict)
end

--新增一个红点，并为该红点监听 control_id_list 中所有的控制ID的状态
--必要参数
--ui: 红点所在UI的引用。--parent：红点的父节点。--type：红点的类型。--control_id_list：决定该红点显示状态的所有控制ID。
--可选参数
--sub_id:次级ID，用以匹配control_id激活时的参数表param_dict，若param_dict[sub_id] > 0，则红点显示; param_dict[sub_id] == 0,则红点隐藏。
--(注意！)没有次级ID的红点可以同时监听任意控制ID，无论其有无次级ID；而有次级ID的红点只能监听有次级ID的控制ID！！！
--anchor_v2, pivot_v2：Vector2类型，红点相对父节点的位置参数。
function RedPointMgr:AddRedPoint(ui, parent, type, control_id_list, sub_id, anchor_v2, pivot_v2)
    if IsNil(parent) then
        PrintError("AddRedPoint: Parameter 'parent' Must Be Valid Unity GameObject!")
        return
    end
    if not control_id_list or #control_id_list == 0 then
        PrintError("AddRedPoint: Parameter 'control_id_list' Can't Be Empty!")
        return
    end
    local new_redpoint = self:_CreateRedPoint(ui, parent, type, anchor_v2, pivot_v2)
    self:_RegisterRedPoint(new_redpoint, control_id_list, sub_id)
    return new_redpoint
end

--移除一个红点，取消所有监听并销毁该红点
function RedPointMgr:RemoveRedPoint(redpoint_class)
    if not redpoint_class then
        PrintError("RemoveRedPoint: Parameter 'redpoint_class' Is Nil!")
        return
    end
    self:_UnregisterRedPoint(redpoint_class)
    self:_DestroyRedPoint(redpoint_class)
end
--------- interface defines end ----------

--------- private function begin --------
--控制ID更新状态
function RedPointMgr:_UpdateControlId(control_id, param_dict)
    self.controler_state_dict[control_id] = param_dict
    if not self.controler_dict[control_id] then
        return
    end
    for redpoint_go, _ in pairs(self.controler_dict[control_id]) do
        self:_UpdateRedPoint(redpoint_go)
    end
end

--创建红点
function RedPointMgr:_CreateRedPoint(ui, parent, type, anchor_v2, pivot_v2)
    if not type or not redpoint_type_class[type] then
        PrintError("_CreateRedPoint: Parameter 'type' Is Wrong!")
        return
    end
    local prefab_path = SpecMgrs.data_mgr:GetRedPointTypeData(type).prefab_path
    local redpoint_go = SpecMgrs.res_mgr:GetGameObjectSync(prefab_path)
    redpoint_go:SetParent(parent, false)
    local redpoint_class = redpoint_type_class[type].New()
    local param_tb = { ui = ui, go = redpoint_go, anchor_v2 = anchor_v2, pivot_v2 = pivot_v2 }
    if not redpoint_class:DoInit(param_tb) then
        self:_DestroyRedPoint(redpoint_class)
        PrintError("_CreateRedPoint: Failed In RedPointBase.DoInit(), Parameter 'ui' Is Invalid!")
        return
    end
    return redpoint_class
end

--销毁红点
function RedPointMgr:_DestroyRedPoint(redpoint_class)
    redpoint_class:DoDestroy()
end

--注册红点
function RedPointMgr:_RegisterRedPoint(redpoint_class, control_id_list, sub_id)
    local redpoint_go = redpoint_class.go
    self.redpoint_dict[redpoint_go] = {redpoint_class = redpoint_class, control_id_list = control_id_list, sub_id = sub_id}
    for _, control_id in ipairs(control_id_list) do
        self.controler_dict[control_id] = self.controler_dict[control_id] or {}
        self.controler_dict[control_id][redpoint_go] = true
    end
    self:_UpdateRedPoint(redpoint_go)
end

--取消注册红点
function RedPointMgr:_UnregisterRedPoint(redpoint_class)
    local redpoint_go = redpoint_class.go
    local redpoint_data = self.redpoint_dict[redpoint_go]
    for _, control_id in ipairs(redpoint_data.control_id_list) do
        self.controler_dict[control_id][redpoint_go] = nil
    end
    self.redpoint_dict[redpoint_go] = nil
end

--更新红点表现
function RedPointMgr:_UpdateRedPoint(redpoint_go)
    local redpoint_data = self.redpoint_dict[redpoint_go]
    local sub_id = redpoint_data.sub_id
    local control_param_dicts = {}
    for _, control_id in ipairs(redpoint_data.control_id_list) do
        if self.controler_state_dict[control_id] then
            control_param_dicts[control_id] = self.controler_state_dict[control_id]
        end
    end
    local current_param_dict = {}
    if not sub_id then
        for control_id, param_dict in pairs(control_param_dicts) do
            local sum = 0
            for sub_id, param in pairs(param_dict) do
                sum = sum + param
            end
            if sum > 0 then
                current_param_dict[control_id] = sum
            end
        end
    else
        for control_id, param_dict in pairs(control_param_dicts) do
            local param = param_dict[sub_id]
            if param and param > 0 then
                current_param_dict[control_id] = param
            end
        end
    end
    if next(current_param_dict) then
        redpoint_data.redpoint_class:Show(current_param_dict)
    else
        redpoint_data.redpoint_class:Hide()
    end
end

--读表
function RedPointMgr:_ReadExcelData(static_redpoint_datas)
    local redpoint_control_datas = SpecMgrs.data_mgr:GetAllRedPointControlData()
    for control_id, data in ipairs(redpoint_control_datas) do
        for _, redpoint_id in ipairs(data.redpoint_list) do
            local redpoint_data = SpecMgrs.data_mgr:GetRedPointData(redpoint_id)
            local ui_gameobject_path_data = SpecMgrs.data_mgr:GetUIGameObjectPathData(redpoint_data.redpoint_path)
            local ui_name = ui_gameobject_path_data.ui_name
            if not static_redpoint_datas[ui_name] then
                static_redpoint_datas[ui_name] = {}
            end
            if not static_redpoint_datas[ui_name][redpoint_id] then
                static_redpoint_datas[ui_name][redpoint_id] = {control_id_list = {}, path = ui_gameobject_path_data.path}
            end
            table.insert(static_redpoint_datas[ui_name][redpoint_id].control_id_list, control_id)
        end
    end
end
--------- private function end --------
return RedPointMgr