local EventUtil = require ("BaseUtilities.EventUtil")
local Object = require("CommonBase.Object")
local UIFuncs = require("UI.UIFuncs")
local UIConst = require("UI.UIConst")
local SoundConst = require("Sound.SoundConst")
local GConst = require("GlobalConst")
local UnitConst = require("Unit.UnitConst")
local UIBase = class("UI.UIBase", Object)
local TalkCmp = require("UI.UICmp.TalkCmp")
EventUtil.GeneratorEventFuncs(UIBase, "UIDestroyEvent")

UIBase.can_multi_open = false
UIBase.need_sync_load = true
UIBase.direct_destroy = true

local kPoolListMaxLength = 20
local kClickCooldown = 3

------ UI Event Defines Begin------
local kETK_OnClick = 1
local kETK_Toggle = 2
local kETK_OnPress = 3
local kETK_OnRelease = 4
local kETK_OnEnter = 5
local kETK_OnExit = 6
local kETK_OnDrag = 7
local kETK_UITreeChange = 8
local kETK_UITreeSelect = 9
local kETK_UISwipeChange = 10
local kETK_UISwipeSelect = 11
local kETK_UITextPicPopulateMesh = 12
local kETK_OnLongPress = 13
local kETK_UIPointerClick = 14
local kETK_UISliderValueChange = 15
local kETK_UIInputFieldValueChange = 16
local kETK_UITextPicOnClickHref = 17
local kETK_UIChatViewUpdate = 18
local kETK_Custom = 20
local kETK_UIDynamicListItemSelect = 21
local kETK_UIDynamicListItemUpdate = 22
local kETK_UIDynamicListItemRequest = 23
local kETK_UISlideSelectChange = 24
local kETK_UIScrollListView = 25
local kETK_UISlideSelectBegin = 26
local kETK_UISlideSelectEnd = 27
local kETK_UIScrollRectOnValueChanged = 28
local kETK_UILoopListItemSelect = 29
local kETK_OnBeginDrag = 30
local kETK_OnEndDrag = 31


-- Note(weiwei) 记录函数名而不是直接记录函数，便于EventMgr的Reload不受到影响
UIBase._evt_key_2_evt_mgr_func = {
    [kETK_OnClick] = {"AddUIOnClick", "RemoveUIOnClick"},
    [kETK_Toggle] = {"AddUIToggle", "RemoveUIToggle"},
    [kETK_OnPress] = {"AddUIOnPress", "RemoveUIOnPress"},
    [kETK_OnRelease] = {"AddUIOnRelease", "RemoveUIOnRelease"},
    [kETK_OnEnter] = {"AddUIOnEnter", "RemoveUIOnEnter"},
    [kETK_OnExit] = {"AddUIOnExit", "RemoveUIOnExit"},
    [kETK_OnDrag] = {"AddUIOnDrag", "RemoveUIOnDrag"},
    [kETK_OnBeginDrag] = {"AddUIOnBeginDrag", "RemoveUIOnBeginDrag"},
    [kETK_OnEndDrag] = {"AddUIOnEndDrag", "RemoveUIOnEndDrag"},
    [kETK_UITreeChange] = {"AddUITreeViewChange", "RemoveUITreeViewChange"},
    [kETK_UITreeSelect] = {"AddUITreeViewSelect", "RemoveUITreeViewSelect"},
    [kETK_UISwipeChange] = {"AddUISwipeViewChange", "RemoveUISwipeViewChange"},
    [kETK_UISwipeSelect] = {"AddUISwipeViewSelect", "RemoveUISwipeViewSelect"},
    [kETK_UITextPicPopulateMesh] = {"AddUITextPicPopulateMesh", "RemoveUITextPicPopulateMesh"},
    [kETK_OnLongPress] = {"AddUIOnLongPress", "RemoveUIOnLongPress"},
    [kETK_UIPointerClick] = {"AddUIPointerClick", "RemoveUIPointerClick"},
    [kETK_UISliderValueChange] = {"AddUISliderValueChange", "RemoveUISliderValueChange"},
    [kETK_UIInputFieldValueChange] = {"AddUIInputFieldValueChange","RemoveUIInputFieldValueChange"},
    [kETK_UITextPicOnClickHref] = {"AddUITextPicOnClickHref", "RemoveUITextPicOnClickHref"},
    [kETK_UIChatViewUpdate] = {"AddUIChatViewUpdate", "RemoveUIChatViewUpdate"},
    [kETK_UILoopListItemSelect] = {"AddUILoopListItemSelect", "RemoveUILoopListItemSelect"},
    [kETK_UIDynamicListItemSelect] = {"AddUIDynamicListItemSelect", "RemoveUIDynamicListItemSelect"},
    [kETK_UIDynamicListItemUpdate] = {"AddUIDynamicListItemUpdate", "RemoveUIDynamicListItemUpdate"},
    [kETK_UIDynamicListItemRequest] = {"AddUIDynamicListItemRequest", "RemoveUIDynamicListItemRequest"},
    [kETK_Custom] = {"AddCustomListener", "RemoveCustomListener"},
    [kETK_UISlideSelectChange] = {"AddUISlideSelectChange","RemoveUISlideSelectChange"},
    [kETK_UIScrollListView] = {"AddUIScrollListView", "RemoveUIScrollListView"},
    [kETK_UISlideSelectBegin] = {"AddUISlideSelectBegin","RemoveUISlideSelectBegin"},
    [kETK_UISlideSelectEnd] = {"AddUISlideSelectEnd","RemoveUISlideSelectEnd"},
    [kETK_UIScrollRectOnValueChanged] = {"AddUIScrollRectOnValueChanged", "RemoveUIScrollRectOnValueChanged"}
}
------ UI  Event Defines End------

function UIBase:DoInit()
    UIBase.super.DoInit(self)
    self.is_visible = false
    self.prefab_path = nil
    self.go_parent = SpecMgrs.ui_mgr:GetNormalUIRoot()
    -- Note(weiwei) 强制所有面板都有个叫做Panel的根
    self.main_panel = nil
    self.canvas = nil
    self.sort_order = 0
    self.is_plot_show = false
    self.is_showing = false
    self.is_cover = false  -- 被覆盖
    self._ui_event_reg_tb = {}
    self._ui_object_pool = {}
    self._ui_object_id_tb = {}
    self._ui_pool_root = nil
    self.bgm_list = {}
    self._ui_effect_tb = {}
    self._timer_dict = {}
    self._dynamic_ui_tb = {}
    self._ext_listen_cbs = {}
    self._unit_dict = {} -- {guid = unit}
end

function UIBase:SetSortOrder(order)
    self.sort_order = order
    if self.is_res_ok and self.canvas then
        self.canvas.sortingOrder = self.sort_order or 0
        self.go:SetSortOrder(self.sort_order or 0)
    end
end

function UIBase:GetSortOrder()
    return self.sort_order or 0
end

function UIBase:OnGoLoadedOk(res_go)
    UIBase.super.OnGoLoadedOk(self, res_go)
    -- Note(weiwei) 强制所有面板都有个叫做Panel的根
    self.main_panel = res_go:FindChild("Panel")
    if self.main_panel then
        if SpecMgrs.system_mgr.has_liu_hai then
            local trans = self.main_panel.transform
            trans.anchorMin = trans.anchorMin + Vector2.New(0, 0.05)
            trans.anchorMax = trans.anchorMax - Vector2.New(0, 0.05)
        end
    end
    self.canvas = res_go:GetComponent("Canvas")
    self.canvas.worldCamera = SpecMgrs.camera_mgr.camera_ui:GetComponent("Camera")
    self.canvas.sortingLayerName = GConst.SortingLayer.UI
    self:SetSortOrder(self.sort_order)
    self:SetVisible(not self.is_cover)
    if self.go_parent then
        res_go:SetParent(self.go_parent)
    end
end

function UIBase:OnGoLoadedOkEnd()
    UIBase.super.OnGoLoadedOkEnd(self)
    SpecMgrs.ui_mgr:OnUILoadOk(self)
    SpecMgrs.redpoint_mgr:AddRedPointByData(self.class_name, self)
end

-- Note(weiwei)在过场中显示的UI需要在Show之后调用SetInPlot这样才能正确显示
function UIBase:SetInPlot(is_plot)
    self.is_plot_show = is_plot
    self.go_parent = is_plot and SpecMgrs.ui_mgr:GetPlotUIRoot() or SpecMgrs.ui_mgr:GetNormalUIRoot()
    if self.is_res_ok then
        self.go:SetParent(self.go_parent)
    end
end

function UIBase:Show()
    self:SetVisible(true)
    self.is_showing = true
    if not self.is_res_ok and not self.is_loading_res then
        if self.prefab_path then
            self:DoLoadGo(self.prefab_path)
        end
    end
    SpecMgrs.ui_mgr:NotifyShowUI(self)
end

function UIBase:Hide()
    self.is_showing = false
    SpecMgrs.ui_mgr:NotifyHideUI(self)
    self:SetVisible(false)
    self:ClearAllSound()
    self:ClearAllTimer()
    self:DestroyAllUnit()
    self._ext_listen_cbs = {}
    self:UnregisterAllEvent()
end

function UIBase:RegBtnClickEvent(go,cb)
    self._ext_listen_cbs[kETK_OnClick] = self._ext_listen_cbs[kETK_OnClick] or {}
    self._ext_listen_cbs[kETK_OnClick][go] = cb
end

function UIBase:IsBtnRegEvent(go)
    return (self._ext_listen_cbs[kETK_OnClick] and self._ext_listen_cbs[kETK_OnClick][go]) and true or false
end

function UIBase:UnregBtnClickEvent(go)
    self._ext_listen_cbs[kETK_OnClick][go] = nil
end

function UIBase:_Reg2EventMgr(key, go, cb, ...)
    local func_tb = UIBase._evt_key_2_evt_mgr_func[key]
    if func_tb == nil or func_tb[1] == nil then
        PrintError("In _Reg2EventMgr do not have evt mgr func key:", key)
        return
    end
    local func = SpecMgrs.event_mgr[func_tb[1]]
    local call_back = function(...)
        if self._ext_listen_cbs[kETK_OnClick] and self._ext_listen_cbs[kETK_OnClick][go] then
            local ret = self._ext_listen_cbs[kETK_OnClick][go]()
            if ret then
                cb(...)
            end
        else
            cb(...)
        end
    end
    func(SpecMgrs.event_mgr, go, call_back, ...)
end

function UIBase:_Unreg2EventMgr(key, go)
    local func_tb = UIBase._evt_key_2_evt_mgr_func[key]
    if func_tb == nil or func_tb[2] == nil then
        PrintError("In _UnregUIEvent do not have evt mgr func key:", key)
        return
    end
    local func = SpecMgrs.event_mgr[func_tb[2]]
    func(SpecMgrs.event_mgr, go)
end

function UIBase:_RegUIEvent(key, go, cb, ...)
    if self._ui_event_reg_tb[key] == nil then
        self._ui_event_reg_tb[key] = {}
    end
    self._ui_event_reg_tb[key][go] = cb
    self:_Reg2EventMgr(key, go, cb, ...)
end

function UIBase:_UnregUIEvent(key, go)
    if self._ui_event_reg_tb[key] and self._ui_event_reg_tb[key][go] then
        self._ui_event_reg_tb[key][go] = nil
        self:_Unreg2EventMgr(key, go)
    end
end

function UIBase:_RegUIEventByPath(key, widget_path, cb, ...)
    local go = self:_GetWidgetByPath(widget_path)
    if not go then
        PrintError("_RegUIEventByPath", widget_path, key, "can't find the gameObject")
        return
    end
    self:_RegUIEvent(key, go, cb, ...)
end

function UIBase:_GetWidgetByPath(widget_path)
    if not self.is_res_ok then
        return
    end
    return self.go:FindChild(widget_path)
end

----- UIEvent Interface Defines Begin ----------------
function UIBase:ClearEvents(go)
    for key, _ in pairs(UIBase._evt_key_2_evt_mgr_func) do
        self:_UnregUIEvent(key, go)
    end
    self:RemoveDynamicUI(go)
    self:ResetUIEffectByDestroyAttachGo(go)
end

function UIBase:ClearEventsRecursive(go)
    self:ClearEvents(go)
    for i = 0, go.childCount - 1, 1 do
        local child_go = go:GetChild(i)
        self:ClearEventsRecursive(child_go)
    end
end

function UIBase:AddClick(go, cb, sound_id)
    sound_id = sound_id or SoundConst.SoundID.SID_SecondBtnClick
    self:_RegUIEvent(kETK_OnClick, go, function()
        if sound_id ~= SoundConst.SoundID.SID_NotPlaySound then
            self:PlayUISound(sound_id, false, false, true)
        end
        cb()
    end)
end

function UIBase:AddCooldownClick(go, cb, cooldown, sound_id)
    cooldown = cooldown or kClickCooldown
    sound_id = sound_id or SoundConst.SoundID.SID_SecondBtnClick
    self:_RegUIEvent(kETK_OnClick, go, function()
        go:GetComponent("Button").interactable = false
        SpecMgrs.timer_mgr:AddTimer(function()
            if not IsNil(go) then
                go:GetComponent("Button").interactable = true
            end
        end, cooldown, 1)
        if sound_id ~= SoundConst.SoundID.SID_NotPlaySound then
            self:PlayUISound(sound_id, false, false, true)
        end
        cb()
    end)
end

function UIBase:AddClickByPath(widget_path, cb)
    self:_RegUIEventByPath(kETK_OnClick, widget_path, cb)
end

function UIBase:RemoveClick(go)
    self:_UnregUIEvent(kETK_OnClick, go)
end

function UIBase:AddToggle(go, cb)
    self:_RegUIEvent(kETK_Toggle, go, cb)
end

function UIBase:RemoveToggle(go)
    self:_UnregUIEvent(kETK_Toggle, go)
end

function UIBase:AddPress(go, cb)
    self:_RegUIEvent(kETK_OnPress, go, cb)
end

function UIBase:RemovePress(go)
    self:_UnregUIEvent(kETK_OnPress, go)
end

function UIBase:AddRelease(go, cb)
    self:_RegUIEvent(kETK_OnRelease, go, cb)
end

function UIBase:RemoveRelease(go)
    self:_UnregUIEvent(kETK_OnRelease, go)
end

function UIBase:AddEnter(go, cb)
    self:_RegUIEvent(kETK_OnEnter, go, cb)
end

function UIBase:RemoveEnter(go)
    self:_UnregUIEvent(kETK_OnEnter, go)
end

function UIBase:AddExit(go, cb)
    self:_RegUIEvent(kETK_OnExit, go, cb)
end

function UIBase:RemoveExit(go)
    self:_UnregUIEvent(kETK_OnExit, go)
end

function UIBase:AddDrag(go, cb)
    self:_RegUIEvent(kETK_OnDrag, go, cb)
end

function UIBase:RemoveDrag(go)
    self:_UnregUIEvent(kETK_OnDrag, go)
end

function UIBase:AddBeginDrag(go, cb)
    self:_RegUIEvent(kETK_OnBeginDrag, go, cb)
end

function UIBase:RemoveBeginDrag(go)
    self:_UnregUIEvent(kETK_OnBeginDrag, go)
end

function UIBase:AddEndDrag(go, cb)
    self:_RegUIEvent(kETK_OnEndDrag, go, cb)
end

function UIBase:RemoveEndDrag(go)
    self:_UnregUIEvent(kETK_OnEndDrag, go)
end

function UIBase:AddListener(go, cb)
    self:_RegUIEvent(kETK_Custom, go, cb)
end

function UIBase:RemoveListener(go)
    self:_UnregUIEvent(kETK_Custom, go)
end

function UIBase:AddUITreeChange(go, cb)
    self:_RegUIEvent(kETK_UITreeChange, go, cb)
end

function UIBase:RemoveUITreeChange(go)
    self:_UnregUIEvent(kETK_UITreeChange, go)
end

function UIBase:AddUITreeSelect(go, cb)
    self:_RegUIEvent(kETK_UITreeSelect, go, cb)
end

function UIBase:RemoveUITreeSelect(go)
    self:_UnregUIEvent(kETK_UITreeSelect, go)
end

function UIBase:AddUISwipeChange(go, cb)
    self:_RegUIEvent(kETK_UISwipeChange, go, cb)
end

function UIBase:RemoveUISwipeChange(go)
    self:_UnregUIEvent(kETK_UISwipeChange, go)
end

function UIBase:AddUISwipeSelect(go, cb)
    self:_RegUIEvent(kETK_UISwipeSelect, go, cb)
end

function UIBase:RemoveUISwipeSelect(go)
    self:_UnregUIEvent(kETK_UISwipeSelect, go)
end

function UIBase:AddUISlideSelectChange(go, cb)
    self:_RegUIEvent(kETK_UISlideSelectChange, go, cb)
end

function UIBase:RemoveUISlideSelectChange(go)
    self:_UnregUIEvent(kETK_UISlideSelectChange, go)
end

function UIBase:AddUISlideSelectBegin(go, cb)
    self:_RegUIEvent(kETK_UISlideSelectBegin, go, cb)
end

function UIBase:RemoveUISlideSelectBegin(go)
    self:_UnregUIEvent(kETK_UISlideSelectBegin, go)
end

function UIBase:AddUISlideSelectEnd(go, cb)
    self:_RegUIEvent(kETK_UISlideSelectEnd, go, cb)
end

function UIBase:RemoveUISlideSelectEnd(go)
    self:_UnregUIEvent(kETK_UISlideSelectEnd, go)
end

function UIBase:AddTextPicPopulateMesh(go, cb)
    self:_RegUIEvent(kETK_UITextPicPopulateMesh, go, cb)
end

function UIBase:RemoveTextPicPopulateMesh(go)
    self:_UnregUIEvent(kETK_UITextPicPopulateMesh, go)
end

function UIBase:AddLongPress(go, cb)
    self:_RegUIEvent(kETK_OnLongPress, go, cb)
end

function UIBase:RemoveLongPress(go)
    self:_UnregUIEvent(kETK_OnLongPress, go)
end
function UIBase:AddPointerClick(go, cb)
    self:_RegUIEvent(kETK_UIPointerClick, go, cb)
end

function UIBase:RemovePointerClick(go)
    self:_UnregUIEvent(kETK_UIPointerClick, go)
end

function UIBase:AddSliderValueChange(go, cb)
    self:_RegUIEvent(kETK_UISliderValueChange, go, cb)
end

function UIBase:RemoveSliderValueChange(go)
    self:_UnregUIEvent(kETK_UISliderValueChange, go)
end

function UIBase:AddInputFieldValueChange(go,cb)
    self:_RegUIEvent(kETK_UIInputFieldValueChange,go,cb)
end

function UIBase:RemoveInputFieldValueChange(go)
    self:_UnregUIEvent(kETK_UIInputFieldValueChange,go)
end

function UIBase:AddTextPicOnClickHref(go, cb)
    self:_RegUIEvent(kETK_UITextPicOnClickHref, go, cb)
end

function UIBase:RemoveTextPicOnClickHref(go)
    self:_UnregUIEvent(kETK_UITextPicOnClickHref, go)
end

function UIBase:AddUIChatViewUpdate(go, cb)
    self:_RegUIEvent(kETK_UIChatViewUpdate, go, cb)
end

function UIBase:RemoveUIChatViewUpdate(go)
    self:_UnregUIEvent(kETK_UIChatViewUpdate, go)
end

function UIBase:AddLoopListItemSelect(go, cb)
    self:_RegUIEvent(kETK_UILoopListItemSelect, go, cb)
end

function UIBase:RemoveLoopListItemSelect(go)
    self:_UnregUIEvent(kETK_UILoopListItemSelect, go)
end

function UIBase:AddDynamicListItemSelect(go, cb)
    self:_RegUIEvent(kETK_UIDynamicListItemSelect, go, cb)
end

function UIBase:RemoveDynamicListItemSelect(go)
    self:_UnregUIEvent(kETK_UIDynamicListItemSelect, go)
end

function UIBase:AddDynamicListItemUpdate(go, cb)
    self:_RegUIEvent(kETK_UIDynamicListItemUpdate, go, cb)
end

function UIBase:RemoveDynamicListItemUpdate(go)
    self:_UnregUIEvent(kETK_UIDynamicListItemUpdate, go)
end

function UIBase:AddDynamicListItemRequest(go, cb)
    self:_RegUIEvent(kETK_UIDynamicListItemRequest, go, cb)
end

function UIBase:RemoveDynamicListItemRequest(go)
    self:_UnregUIEvent(kETK_UIDynamicListItemRequest, go)
end

function UIBase:AddScrollListView(go, cb)
    self:_RegUIEvent(kETK_UIScrollListView, go, cb)
end

function UIBase:RemoveScrollListView(go)
    self:_UnregUIEvent(kETK_UIScrollListView, go)
end

function UIBase:AddScrollValueChanged(go, cb)
    self:_RegUIEvent(kETK_UIScrollRectOnValueChanged, go, cb)
end

function UIBase:RemoveScrollValueChanged(go)
    self:_UnregUIEvent(kETK_UIScrollRectOnValueChanged, go)
end

----- UIEvent Interface Defines End ----------------

--------Note(weiwei) UI中通过template来生成GameObject必须统一调用这里的Get和Del函数，便于统一管理和内存以及事件的释放
function UIBase:GetUIObject(template, parent, is_stay_pos)
    if not template then
        PrintError("UIBase GetUIObject: template is nil")
        return
    end
    local go = nil
    local id = template:GetInstanceID()
    if self._ui_object_pool[id] and #self._ui_object_pool[id] > 0 then
        local len = #self._ui_object_pool[id]
        go = self._ui_object_pool[id][len]
        self._ui_object_pool[id][len] = nil
    else
        go = GameObject.Instantiate(template)
    end
    self._ui_object_id_tb[go] = id
    go:SetActive(true)
    if parent then
        go:SetParent(parent, is_stay_pos == true)
        if not is_stay_pos then
            go.localPosition = Vector3.zero
            go.localScale = Vector3.one
        end
    end
    return go
end

function UIBase:DelUIObject(go, is_directly_destroy)
    local id = self._ui_object_id_tb[go]
    if not id then
        return
    end
    self._ui_object_id_tb[go] = nil
    if not self._ui_object_pool[id] then
        self._ui_object_pool[id] = {}
    end
    self:ClearEventsRecursive(go)
    if is_directly_destroy or #self._ui_object_pool[id] > kPoolListMaxLength then
        GameObject.Destroy(go)
    else
        if not self._ui_pool_root then
            self._ui_pool_root = GameObject.New("UIPoolRoot")
            self._ui_pool_root:SetParent(self.go, false)
        end
        go:SetParent(self._ui_pool_root, false)
        go:SetActive(false)
        table.insert(self._ui_object_pool[id], go)
        local toggle_cmp = go:GetComponent("Toggle")
        if toggle_cmp then
            toggle_cmp.isOn = false
        end
    end
end

function UIBase:DelObjDict(obj_list)
    if not obj_list or not next(obj_list) then return end
    for i,v in pairs(obj_list) do
        self:DelUIObject(v)
    end
end

function UIBase:DelAllCreateUIObj()
    for go, id in pairs(self._ui_object_id_tb) do
        self:DelUIObject(go)
    end
    self._ui_object_id_tb = {}
end

function UIBase:SetItemNumTextPic(textpic_obj, item_id, num, format)
    return UIFuncs.SetItemNumTextPic(self, textpic_obj, item_id, num, format)
end

function UIBase:SetTextPic(textpic_obj, str)
    return UIFuncs.SetTextPic(self, textpic_obj, str)
end

function UIBase:SetItemList(role_item_list, content)
    return UIFuncs.SetItemList(self, role_item_list, content)
end

function UIBase:AddDynamicUI(go, cb, sec_time, loop)
    sec_time = sec_time or 1
    loop = loop or 1
    self:RemoveDynamicUI(go)
    cb(0)
    local timer = nil
    local active_time = 0
    local set_ui_func = function()
        active_time = active_time + sec_time
        cb(active_time)
        if loop ~= 0 and timer.loop <= 0 then
            self:RemoveDynamicUI(go)
        end
    end
    timer = SpecMgrs.timer_mgr:AddTimer(set_ui_func, sec_time, loop)
    self._dynamic_ui_tb[go] = timer
end

function UIBase:RemoveDynamicUI(go)
    if self._dynamic_ui_tb[go] then
        SpecMgrs.timer_mgr:RemoveTimer(self._dynamic_ui_tb[go])
        self._dynamic_ui_tb[go] = nil
    end
end

function UIBase:AddTimer(func, sec_time, loop)
    local timer = SpecMgrs.timer_mgr:AddTimer(func, sec_time, loop)
    self._timer_dict[timer.guid] = timer
    return timer
end

function UIBase:RemoveTimer(timer)
    self._timer_dict[timer.guid] = nil
    SpecMgrs.timer_mgr:RemoveTimer(timer)
end

function UIBase:ClearAllTimer()
    for _, timer in pairs(self._timer_dict) do
        if timer and not timer.is_delete then
            SpecMgrs.timer_mgr:RemoveTimer(timer)
        end
    end
    self._timer_dict = {}
end

function UIBase:IsDynamicUI(go)
    return self._dynamic_ui_tb[go] ~= nil
end

function UIBase:AddUIEffect(ui_go, param_tb, is_keep_when_go_destroy, is_destroy_same)
    if not self._ui_effect_tb[ui_go] then
        self._ui_effect_tb[ui_go] = {}
    end
    if is_destroy_same then
        local go_effect_tb = self._ui_effect_tb[ui_go]
        for cur_effect, _ in pairs(go_effect_tb) do
            if param_tb.effect_id == cur_effect.effect_id or param_tb.res_path == cur_effect.res_path then
                SpecMgrs.effect_mgr:DestroyEffect(cur_effect)
                go_effect_tb[cur_effect] = nil
            end
        end
    end
    local new_param_tb = {}
    new_param_tb.effect_type = CSConst.EffectType.ET_UI
    new_param_tb.attach_ui = self
    new_param_tb.attach_ui_go = ui_go
    for k, v in pairs(param_tb) do new_param_tb[k] = v end
    local ui_effect = SpecMgrs.effect_mgr:CreateEffectAutoGuid(new_param_tb)

    if is_keep_when_go_destroy ~= true then
        is_keep_when_go_destroy = false
    end
    self._ui_effect_tb[ui_go][ui_effect] = is_keep_when_go_destroy

    ui_effect:RegisterEffectDestroyEvent("UIBase", function()
        local eft_tb = self._ui_effect_tb[ui_effect.attach_ui_go]
        if eft_tb then
            eft_tb[ui_effect] = nil
        end
    end)

    return ui_effect
end

function UIBase:RemoveUIEffect(ui_go, effect, is_destroy_immediately)
    local eft_tb = self._ui_effect_tb[ui_go]
    if not eft_tb then return end
    local DestroyUIEffect = function(des_eft)
        if is_destroy_immediately then
            SpecMgrs.effect_mgr:DestroyEffect(des_eft)
        else
            des_eft:EffectEnd()
        end
    end
    if effect then
        DestroyUIEffect(effect)
        eft_tb[effect] = nil
    else
        for eft, _ in pairs(eft_tb) do
            DestroyUIEffect(eft)
        end
        self._ui_effect_tb[ui_go] = nil
    end
end

function UIBase:ResetUIEffectByDestroyAttachGo(ui_go)
    local eft_tb = self._ui_effect_tb[ui_go]
    self._ui_effect_tb[ui_go] = nil
    if eft_tb then
        for effect, is_keep in pairs(eft_tb) do
            if is_keep then
                self:_SetUIEffectAttachGo(effect, self.main_panel, nil, true)
            else
                SpecMgrs.effect_mgr:DestroyEffect(effect)
            end
        end
    end
end

function UIBase:RemoveUIEffectByParamTb(ui_go, param_tb, is_destroy_immediately)
    local eft_dict = self._ui_effect_tb[ui_go]
    if eft_dict then
        for eft, _ in pairs(eft_dict) do
            if param_tb.effect_id == eft.effect_id or param_tb.res_path == eft.res_path then
                if is_destroy_immediately then
                    SpecMgrs.effect_mgr:DestroyEffect(eft)
                else
                    eft:EffectEnd()
                end
                eft_dict[eft] = nil
                return
            end
        end
    end
end

function UIBase:SetUIEffectAttachGo(exist_effect, new_ui_go, param_tb)
    local attach_go = exist_effect.attach_ui_go
    local eft_dict = self._ui_effect_tb[attach_go]
    if eft_dict and eft_dict[exist_effect] ~= nil then
        local is_keep = eft_dict[exist_effect]
        eft_dict[exist_effect] = nil
        self:_SetUIEffectAttachGo(exist_effect, new_ui_go, param_tb, is_keep)
    end
end

function UIBase:_SetUIEffectAttachGo(effect, new_go, param_tb, is_keep)
    if not self._ui_effect_tb[new_go] then
        self._ui_effect_tb[new_go] = {}
    end
    param_tb = param_tb or {}
    local new_param_tb = {}
    new_param_tb.attach_ui_go = new_go
    new_param_tb.keep_world_pos = true
    for k, v in pairs(param_tb) do new_param_tb[k] = v end
    effect:SetUIEffectRectCompInfo(new_param_tb)
    self._ui_effect_tb[new_go][effect] = is_keep
end

function UIBase:RemoveAllUIEffect()
    for _, eft_tb in pairs(self._ui_effect_tb) do
        for effect, _ in pairs(eft_tb) do
            SpecMgrs.effect_mgr:DestroyEffect(effect)
        end
    end
    self._ui_effect_tb = {}
end

function UIBase:RemoveEffectList(effect_list)
    if not effect_list then return end
    for _, effect in ipairs(effect_list) do
        effect:EffectEnd()
    end
    effect_list = {}
end

function UIBase:SetItemList(role_item_list, content)
    return UIFuncs.SetItemList(self, role_item_list, content)
end

function UIBase:SetItem(item_id, count, content, click_cb)
    return UIFuncs.SetItem(self, item_id, count, content, click_cb)
end

function UIBase:AssignUISpriteSync(res_path, res_name, cmp, load_active, field_name, cb)
    UIFuncs.AssignUISpriteSync(res_path, res_name, cmp, load_active, field_name, cb)
end

function UIBase:AssignSpriteByIconID(icon_id, cmp, load_active, field_name, cb, is_sync)
    UIFuncs.AssignSpriteByIconID(icon_id, cmp, load_active, field_name, cb, is_sync)
end

function UIBase:PlayUISoundByName(sound_name)
    local sound_id = SpecMgrs.data_mgr:GetSoundId(sound_name)
    self:PlayUISound(sound_id)
end
-- 随ui hide 清除 多个叠加播放
function UIBase:PlayUISound(sound_id, loop, destroy_by_ui, is_one_shot)
    destroy_by_ui = destroy_by_ui == nil or destroy_by_ui
    loop = loop or false
    if destroy_by_ui then
        return SpecMgrs.sound_mgr:PlayUISound(sound_id, loop, self, is_one_shot)
    else
        return SpecMgrs.sound_mgr:PlayUISound(sound_id, loop, nil, is_one_shot)
    end
end

function UIBase:RemoveBGM()
    local last_bgm = table.remove(self.bgm_list, #self.bgm_list)
    if not last_bgm then return end
    return SpecMgrs.sound_mgr:RemoveBGM(last_bgm)
end

function UIBase:PlayBGM(sound_id)
    SpecMgrs.sound_mgr:PlayBGM(sound_id)
    table.insert(self.bgm_list, sound_id)
end

function UIBase:ClearAllSound()
    SpecMgrs.sound_mgr:ClearSoundByTag(self)
    while next(self.bgm_list) do
        self:RemoveBGM()
    end
end

--  默认同步
function UIBase:AddUnit(unit_id, parent, pos, scale, is_flip_x, need_async_load)
    local param_tb = {}
    param_tb.unit_id = unit_id
    param_tb.position = pos or Vector3.zero
    param_tb.layer_name = "UI"
    param_tb.scale = scale or 1
    param_tb.parent = parent
    param_tb.is_flip_x = is_flip_x or false
    param_tb.need_sync_load = not need_async_load
    local unit = ComMgrs.unit_mgr:CreateUnitAutoGuid(param_tb)
    self._unit_dict[unit.guid] = unit
    return unit
end

function UIBase:AddHeadUnit(unit_id, parent, pos, scale, is_flip_x, need_async_load)
    local unit = self:AddUnit(unit_id, parent, pos, scale, is_flip_x, need_async_load)
    unit:SetPositionByRectName({parent = parent, name = UnitConst.UnitRect.Head})
    return unit
end

function UIBase:AddHalfUnit(unit_id, parent, pos, scale, is_flip_x, need_async_load)
    local unit = self:AddUnit(unit_id, parent, pos, scale, is_flip_x, need_async_load)
    unit:SetPositionByRectName({parent = parent, name = UnitConst.UnitRect.Half})
    return unit
end

function UIBase:AddFullUnit(unit_id, parent, pos, scale, is_flip_x, need_async_load)
    local unit = self:AddUnit(unit_id, parent, pos, scale, is_flip_x, need_async_load)
    unit:SetPositionByRectName({parent = parent, name = UnitConst.UnitRect.Full})
    return unit
end

function UIBase:AddCardUnit(unit_id, parent, pos, scale, is_flip_x, need_async_load)
    local unit = self:AddUnit(unit_id, parent, pos, scale, is_flip_x, need_async_load)
    unit:SetPositionByRectName({parent = parent, name = UnitConst.UnitRect.Card})
    return unit
end

function UIBase:RemoveUnitList(unit_list)
    if unit_list then
        for i, unit in pairs(unit_list) do
            self:RemoveUnit(unit)
        end
    end
end

function UIBase:RemoveUnit(unit)
    if unit then
        self._unit_dict[unit.guid] = nil
        ComMgrs.unit_mgr:DestroyUnit(unit)
    end
end

function UIBase:ClearUnit(unit_name)
    self:RemoveUnit(self[unit_name])
    self[unit_name] = nil
end

function UIBase:DestroyAllUnit()
    for i, unit in pairs(self._unit_dict) do
        if unit then
            ComMgrs.unit_mgr:DestroyUnit(unit)
        end
    end
    self._unit_dict = {}
end

function UIBase:RemoveRedPointList(list)
    if list then
        for i, red_point in ipairs(list) do
            SpecMgrs.redpoint_mgr:RemoveRedPoint(red_point)
        end
    end
end

function UIBase:DestroyAllObj()
    for go, _ in pairs(self._ui_object_id_tb) do
        GameObject.Destroy(go)
    end
    self._ui_object_id_tb = {}
end

function UIBase:InitTopBar(close_cb)
    local top_bar = self.main_panel:FindChild("TopBar")
    if not top_bar then
       -- self:GetUIObject()
    end
    UIFuncs.InitTopBar(self, top_bar, self.class_name, close_cb)
end

function UIBase:DestroyRes()
    self.main_panel = nil
    self.canvas = nil
    for _, timer in pairs(self._dynamic_ui_tb) do
        SpecMgrs.timer_mgr:RemoveTimer(timer)
    end
    self._dynamic_ui_tb = {}
    self:RemoveAllUIEffect()
    for e_key, go_tb in pairs(self._ui_event_reg_tb) do
        for go, cb in pairs(go_tb) do
            self:_Unreg2EventMgr(e_key, go)
        end
    end
    self._ui_event_reg_tb = {}
    self:DestroyAllObj()
    if self._ui_pool_root then
        GameObject.Destroy(self._ui_pool_root)
        self._ui_pool_root = nil
    end
    self._ui_object_pool = {}
    self:DispatchUIDestroyEvent()
    UIBase.super.DestroyRes(self)
end

function UIBase:DoDestroy()
    if self.is_showing then
        self:Hide()
    end
    SpecMgrs.redpoint_mgr:RemoveRedPointByData(self.class_name)
    UIBase.super.DoDestroy(self)
end

-- 该方法注册事件在ui hide时统一解除注册
function UIBase:RegisterEvent(event_dispatcher, event_name, cb, tag)
    if not self._event_data_list then self._event_data_list = {} end
    tag = tag or self.class_name
    local event_data = {event_dispatcher = event_dispatcher, event_name = event_name, cb = cb, tag = tag}
    local register_func_name = "Register" .. event_name
    event_dispatcher[register_func_name](event_dispatcher, tag, cb)
    table.insert(self._event_data_list, event_data)
end

function UIBase:UnregisterAllEvent()
    if not self._event_data_list then return end
    local unregister_func_name
    local event_dispatcher
    for _, event_data in ipairs(self._event_data_list) do
        unregister_func_name = "Unregister" .. event_data.event_name
        event_dispatcher = event_data.event_dispatcher
        event_dispatcher[unregister_func_name](event_dispatcher, event_data.tag)
    end
    self._event_data_list = nil
end

function UIBase:ClearGoDict(go_dict_name)
    local dict = self[go_dict_name]
    self:DelObjDict(dict)
    self[go_dict_name] = {}
end

function UIBase:ClearUnitDict(unit_dict_name)
    local dict = self[unit_dict_name]
    self:RemoveUnitList(dict)
    self[unit_dict_name] = {}
end

function UIBase:SetCover(is_cover)
    self.is_cover = is_cover
    if not self.is_res_ok then return end
    self:SetVisible(not is_cover)
end

--多语言
function UIBase:InitTextComp()
    local text_comps = self.go:GetComponentsInChildren(UnityEngine.UI.Text, true)
    local n = text_comps.Length
    for i = 0, n - 1 do
        local text_comp = text_comps[i]
        text_comp.text = LangUI(text_comp.text)
    end
end

function UIBase:GetTalkCmp(go, prefab_index, is_arrow_right, get_talk_cb, change_time)
    local talk_cmp = TalkCmp.New()
    talk_cmp:DoInit(self, go, prefab_index, is_arrow_right, get_talk_cb, change_time)
    return talk_cmp
end
return UIBase