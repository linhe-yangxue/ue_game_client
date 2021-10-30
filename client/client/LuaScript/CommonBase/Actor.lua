local EventUtil = require("BaseUtilities.EventUtil")
local Object = require("CommonBase.Object")
local GConst = require("GlobalConst")

local kInitScaleTag = "init"
local Actor = class("CommonBase.Actor", Object)

function Actor:DoInit()
    Actor.super.DoInit(self)
    self._position = Vector3.zero
    self._scale = Vector3.one
    self._layer_name = GConst.DefaultLayer
    self._sorting_layer_name = GConst.SortingLayer.Default
    self.attach_tb = {}
    self.attach_base_info = {}
    self.attach_update_pos_dict = {}
    self._scale_tb = {}
    self._sort_order = nil
end

function Actor:AttachChild(child_actor, attach_name, local_pos, local_rot, local_scale, success_visible)
    if child_actor.attach_base_info then
        child_actor.attach_base_info.base:DetachChild(child_actor)
    end

    -- 检测循环attach
    local base_info = self.attach_base_info
    while base_info do
        if base_info.base == child_actor then
            PrintError("AttachChild error")
            return
        end
        base_info = base_info.base.attach_base_info
    end

    self.attach_tb[child_actor] = {
        guid = self.guid,
        child_guid = child_actor.guid,
        attach_name = attach_name, 
        local_pos = local_pos, 
        local_rot = local_rot, 
        local_scale = local_scale, 
        success_visible = success_visible}
    child_actor.attach_base_info = {
        guid = self.guid,
        child_guid = child_actor.guid,
        base = self, 
        attach_name = attach_name, 
        local_pos = local_pos, 
        local_rot = local_rot, 
        local_scale = local_scale, 
        success_visible = success_visible}
    if child_actor.AfterPosChange then
        self.attach_update_pos_dict[child_actor] = true
    end
    self:_DoAttach(child_actor, attach_name, local_pos, local_rot, local_scale, success_visible)
end

function Actor:_DoAttach(child_actor, attach_name, local_pos, local_rot, local_scale, success_visible)
    if self.go and child_actor.go then
        local go = nil
        if attach_name then
            go = self:FindChild(attach_name)
            if not go and not success_visible then
                PrintError("can't find attach_name:", attach_name)
            end
            if go and success_visible then
                child_actor:SetVisible(true)
            end
        elseif success_visible then
            child_actor:SetVisible(true)
        end
        go = go or self.go
        child_actor.go:SetParent(go, false)
        if local_pos then
            child_actor.go.localPosition = local_pos
        end
        if local_rot then
            child_actor.go.localRotation = local_rot
        end
        if local_scale then
            child_actor:SetScaleByVector3(local_scale, kAttachScaleTag)
        end
        if self.attach_update_pos_dict[child_actor] then
            child_actor:_SetPosition(child_actor.go.position)
            child_actor:UpdateAttachChildPosition(false)
        end
        self:DispatchAttachChildOkEvent(child_actor)
        child_actor:DispatchBeAttachedToEvent(self)
    end
end

function Actor:DetachChild(child_actor)
    child_actor.attach_base_info = nil
    self:_DoDetach(child_actor)
    self.attach_tb[child_actor] = nil
    self.attach_update_pos_dict[child_actor] = nil
end

function Actor:_DoDetach(child_actor)
    local attach_info = self.attach_tb[child_actor]
    if not attach_info then return end
    if child_actor.go then
        child_actor.go:SetParent()
        if self.go then
            child_actor._position = self.go.position
            child_actor._rotation = self.go.rotation
        else
            child_actor._position = self._position
            child_actor._rotation = self._rotation
        end
        self:DispatchDetachChildOkEvent(child_actor)
        child_actor:DispatchBeDetachedFromEvent(self)
    end
    if attach_info.local_scale then
        child_actor:SetScaleByVector3(nil, kAttachScaleTag)
    end
    child_actor:AfterDetach()
end

function Actor:AfterDetach()
end

function Actor:UpdateAttachChildPosition(is_by_move)
    if self.AfterPosChange then
        self:AfterPosChange(is_by_move)
    end
    for child, _ in pairs(self.attach_update_pos_dict) do
        if child.go then
            child._position = child.go.position
            child:UpdateAttachChildPosition(is_by_move)
        end
    end
end

function Actor:SetPosition(pos)
    self._position = pos or self._position
    if self.go then self.go.localPosition = self._position end
end

function Actor:GetPosition()
    return self._position
end

function Actor:SetScaleByVector3(scale, scale_tag)
    scale_tag = scale_tag or kInitScaleTag
    if not scale or scale == Vector3.one then
        self._scale_tb[scale_tag] = nil
    else
        self._scale_tb[scale_tag] = scale
    end
    local ret = Vector3.one
    for _, sc in pairs(self._scale_tb) do
        ret:SetScale(sc)
    end
    self._scale = ret
    if self.go ~= nil then
        self.go.localScale = self._scale
    end
end

function Actor:SetScale(scale, scale_tag)
    if type(scale) == "number" then
        self:SetScaleByVector3(scale and Vector3.one * scale or nil, scale_tag)
    else
        self:SetScaleByVector3(scale or nil, scale_tag)
    end
end

function Actor:GetScaleByTag(scale_tag)
    if not self._scale_tb[scale_tag] then
        return Vector3.one
    else
        return self._scale_tb[scale_tag]
    end
end

function Actor:SetEuler(euler)
    self._euler = euler or self._euler
    if not self.go then return end
    self.go.localEulerAngles = self._euler
end

function Actor:GetEuler()
    return self._euler
end

function Actor:SetLayerRecursive(layer_name)
    self._layer_name = layer_name or self._layer_name
    if self.go then
        self.go:SetLayerRecursive(LayerMask.NameToLayer(self._layer_name))
    end
end

function Actor:SetSortingLayer(layer)
    self._sorting_layer_name = layer or self._sorting_layer_name
    if self.go then self.go:SetSortingLayer(self._sorting_layer_name) end
end

function Actor:SetSortOrder(sort_order)
    self._sort_order = sort_order or self._sort_order
    if self.go and self._sort_order then
        self.go:SetSortOrder(self._sort_order)
    end
end

function Actor:SetParent(parent)
    self._parent = parent or self._parent
    if not self.go or not self._parent then return end
    self.go:SetParent(self._parent)
end

function Actor:OnGoLoadedOk(res_go)
    self.go = res_go
    Actor.super.OnGoLoadedOk(self, res_go)
    self:SetParent()
    self:SetPosition()
    self:SetLayerRecursive()
    self:SetSortingLayer()
    self:SetSortOrder()
    self:SetEuler()
    if self.go ~= nil then
        self.go.localScale = self._scale
    end
end

return Actor