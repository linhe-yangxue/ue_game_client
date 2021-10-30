local Actor = require("CommonBase.Actor")
local UnitAnimCmp = require("Unit.UnitAnimCmp")
local UnitInfoCmp = require("Unit.UnitInfoCmp")
local GConst = require("GlobalConst")

local Unit = class("Unit.Unit", Actor)

function Unit:DoInit()
    Unit.super.DoInit(self)
end

function Unit:BuildUnit(param_tb)
    self.guid = param_tb.guid
    self.unit_id = param_tb.unit_id
    self.unit_name = param_tb.unit_name
    self.need_sync_load = param_tb.need_sync_load
    self.unit_data = SpecMgrs.data_mgr:GetUnitData(self.unit_id)
    if not self.unit_data then
        PrintError("无单位表数据")
    end
    self.is_flip_x = param_tb.is_flip_x == true or false
    self.is_3D_model = param_tb.is_3D_model == true or false
    self.color = param_tb.color or Color.white
    self.add_color = Color.black
    -- 模型初始化
    self:SetPosition(param_tb.position or (self.unit_data.pos and Vector3.NewByTable(self.unit_data.pos) or nil))
    self:SetScale(param_tb.scale)
    self:SetEuler(Vector3.zero)
    self:SetLayerRecursive(param_tb.layer_name or (self.is_3D_model ~= true and GConst.SortingLayer.UI))
    self:SetSortingLayer(param_tb.sorting_layer_name or (self.is_3D_model ~= true and GConst.UILayer))
    self:SetParent(param_tb.parent or ComMgrs.unit_mgr.go)
    -- info
    self.show_info = param_tb.show_info
    self.max_hp = param_tb.max_hp or 1
    self.hp = param_tb.hp or 1
    self.anger = param_tb.anger or 0
    self.is_show_shadow = param_tb.is_show_shadow == true or false
    self.is_stop_anim = param_tb.is_stop_anim or false
    self.monster_id = param_tb.monster_id
    self.direct_destroy = true
    self:LoadUnitAsset()
end

function Unit:LoadUnitAsset()
    local res_path = self.is_3D_model and self.unit_data.model_path or self.unit_data.res_path
    if self.need_sync_load then
        self:LoadGoSync(res_path)
    else
        self:LoadGoAsync(res_path)
    end
end

function Unit:OnGoLoadedOk(res_go)
    Unit.super.OnGoLoadedOk(self, res_go)
    -- 组件初始化
    self._anim_cmp = UnitAnimCmp.New()
    self._anim_cmp:DoInit(self)
    self._anim_cmp:InitByGo(res_go:FindChild("model"))
    self._anim_cmp:SetUnitFlip(self.is_flip_x)
    self._anim_cmp:SetColor(self.color)
    self:SetTimeScale(self.time_scale)
    self.model_go = res_go:FindChild("model")
    self.model_go.localEulerAngles = Vector3.New(0, 0, 0)
    self:SetSortOrder(0)
    if self.is_change_to_gray then
        self._anim_cmp:ChangeToGray()
    end
    if self.is_change_to_normal then
        self._anim_cmp:ChangeToNormalMaterial()
    end
    if self.show_info then
        self._info_cmp = UnitInfoCmp.New()
        self._info_cmp:DoInit(self)
        self._info_cmp:InitByGo(res_go)
        self._info_cmp:ShowName()
        self._info_cmp:ShowBloodBar()
        self._info_cmp:ShowAnger()
        self._info_cmp:SetInfoCmpColor(Color.white)
        self.go:FindChild("UnitInfo"):SetActive(true)
    else
        if self.go:FindChild("UnitInfo") then
            self.go:FindChild("UnitInfo"):SetActive(false)
        end
    end
    if self.rect_data then self:SetPositionByRectName(self.rect_data) end
    self:SetDefaultAnim(self.unit_data.default_anim)
    if self.is_stop_anim then self:StopAllAnimationToCurPos() end
    self:ShowOrHideShadow(self.is_show_shadow)
end

-- parent:显示框父对象 name:所需模型部分框名字 -- need_mask:是否需要裁剪超出框的虚影
function Unit:SetPositionByRectName(data)
    if not data.parent or not data.name then return end
    if not self.go then
        self.rect_data = data
        return
    end
    self.rect_data = nil
    local target = self.go:FindChild("rect_" .. data.name)
    if not target then
        PrintError("unit have not rect_" .. data.name)
        return
    end
    local target_rect_cmp = target:GetComponent("RectTransform")
    local target_rect = target_rect_cmp.rect
    local parent_rect_cmp = data.parent:GetComponent("RectTransform")
    local parent_rect = parent_rect_cmp.rect
    self:SetPosition(Vector3.zero)
    -- 计算中心点偏移
    local pivot_offset_x = target_rect.width * (target_rect_cmp.pivot.x - parent_rect_cmp.pivot.x)
    local pivot_offset_y = target_rect.height * (target_rect_cmp.pivot.y - parent_rect_cmp.pivot.y)
    local offset = Vector3.New(pivot_offset_x, pivot_offset_y, 0) - target_rect_cmp.localPosition
    -- 计算scale
    local scale_by_width = parent_rect.width / parent_rect.height < target_rect.width / target_rect.height
    local scale = scale_by_width and parent_rect.width / target_rect.width or parent_rect.height / target_rect.height
    self:SetScale(scale)
    -- 计算位置
    self:SetPosition(offset * scale)
    -- 裁剪
    if data.need_mask then self.go:FindChild("model"):AddComponent(UnityEngine.UI.Mask) end
end

function Unit:GetUnitPointPos(name, is_local)
    if not self.is_res_ok then return Vector3.zero end
    local target_point = self.go:FindChild(name)
    if not target_point then
        PrintError("unit have not " .. name)
        return
    end
    if is_local then
        return target_point.localPosition * self.go.localScale.x
    else
        return target_point.localPosition * self.go.localScale.x + self:GetPosition()
    end
end

function Unit:DestroyRes()
    if self._anim_cmp then self._anim_cmp:DestroyRes() end
    if self._info_cmp then self._info_cmp:DestroyRes() end
    Unit.super.DestroyRes(self)
end

function Unit:DoDestroy()
    if self._anim_cmp then self._anim_cmp:DoDestroy() end
    if self._info_cmp then self._info_cmp:DoDestroy() end
    Unit.super.DoDestroy(self)
end

function Unit:RotateModelGo(euler)
    self.model_go.localEulerAngles = euler
end

function Unit:SetUnitFlip(is_flip_x, is_flip_y)
    self._anim_cmp:SetUnitFlip(is_flip_x, is_flip_y)
end

function Unit:PlayAnim( ... )
    if self.is_destroy then return end
    return self._anim_cmp:PlayAnim(...)
end

function Unit:AddAnim( ... )
    self._anim_cmp:AddAnim(...)
end

function Unit:SetDefaultAnim( ... )
    self._anim_cmp:SetDefaultAnim( ... )
end

function Unit:StopAllAnimationToCurPos( ... )
    self.is_stop_anim = true
    if self._anim_cmp then
        self._anim_cmp:StopAllAnimationToCurPos( ... )
    end
end

function Unit:SetTimeScale(time_scale)
    self.time_scale = time_scale or self.time_scale or 1
    if self._anim_cmp then
        self._anim_cmp:SetTimeScale(self.time_scale)
    end
end

function Unit:GetAnimName()
    if self._anim_cmp then
        return self._anim_cmp:GetAnimName()
    end
end

function Unit:SetColor(color, is_add)
    if self.is_destroy then return end
    local set_color
    if is_add then
        self.add_color = color or self.add_color
        set_color = self.add_color
    else
        self.color = color or self.color
        set_color = self.color
    end
    if self._anim_cmp then self._anim_cmp:SetColor(set_color, is_add) end
end

function Unit:GetColor(is_add)
    if is_add then
        return self.add_color
    else
        return self.color
    end
end

function Unit:CrossFadeColor( ... )
    if self.is_destroy then return end
    self._anim_cmp:CrossFadeColor( ... )
end

function Unit:CrossFadeAlpha( ... )
    if self.is_destroy then return end
    self._anim_cmp:CrossFadeAlpha( ... )
end

function Unit:CreateGhost( ... )
    if self.is_destroy then return end
    return self._anim_cmp:CreateGhost( ... )
end

function Unit:SetInfoCmpColor( ... )
    if self.is_destroy then return end
    if self._info_cmp then
        self._info_cmp:SetInfoCmpColor( ... )
    end
end

function Unit:ChangeToGray()
    self.is_change_to_gray = true
    if self.is_destroy then return end
    if self._anim_cmp then
        self._anim_cmp:ChangeToGray()
    end
end

function Unit:ChangeToNormalMaterial()
    self.is_change_to_normal = true
    if self.is_destroy then return end
    if self._anim_cmp then
        self._anim_cmp:ChangeToNormalMaterial()
    end
end

function Unit:GetAnimationDuration(anim_name)
    if self._anim_cmp then
        return self._anim_cmp:GetAnimationDuration(anim_name)
    end
end

function Unit:Update(delta_time)
    Unit.super.Update(self, delta_time)
    if self._anim_cmp then
        self._anim_cmp:Update(delta_time)
    end
end

-- info cmp
function Unit:GetHp()
    return self.hp
end

function Unit:GetMaxHp()
    return self.max_hp
end

function Unit:SetHp(value)
    self.hp = value
    if self._info_cmp then
        self._info_cmp:SetHpValue()
    end
end

function Unit:GetAnger()
    return self.anger
end

function Unit:SetAnger(value)
    self.anger = value
    if self._info_cmp then
        self._info_cmp:SetAngerValue()
    end
end

function Unit:ShowOrHideInfo(is_active)
    if self.is_destroy then return end
    if self._info_cmp then
        if is_active then
            self._info_cmp.info_point:SetActive(true)
        else
            self._info_cmp.info_point:SetActive(false)
        end
    end
end

function Unit:ShowOrHideShadow(is_active)
    if self.is_destroy then return end
    local go = self.go:FindChild("Shadow")
    if not IsNil(go) then
        go:SetActive(is_active)
    end
end

function Unit:GetShadowGo()
    return self.go:FindChild("Shadow")
end

return Unit