local EventMgr = class("Mgrs.Special.EventMgr")

EventMgr.ET_ApplicationFocus = GameEventMgr.ET_ApplicationFocus
EventMgr.ET_UIOnClicked = GameEventMgr.ET_UIOnClicked
EventMgr.ET_UIToggle = GameEventMgr.ET_UIToggle
EventMgr.ET_UIPress = GameEventMgr.ET_UIPress
EventMgr.ET_UIRelease = GameEventMgr.ET_UIRelease
EventMgr.ET_UIEnter = GameEventMgr.ET_UIEnter
EventMgr.ET_UIExit = GameEventMgr.ET_UIExit
EventMgr.ET_UIDrag = GameEventMgr.ET_UIDrag
EventMgr.ET_UIBeginDrag = GameEventMgr.ET_UIBeginDrag
EventMgr.ET_UIEndDrag = GameEventMgr.ET_UIEndDrag
EventMgr.ET_UITreeViewChange = GameEventMgr.ET_UITreeViewChange
EventMgr.ET_UITreeViewSelect = GameEventMgr.ET_UITreeViewSelect
EventMgr.ET_UISwipeViewChange = GameEventMgr.ET_UISwipeViewChange
EventMgr.ET_UISwipeViewSelect = GameEventMgr.ET_UISwipeViewSelect
EventMgr.ET_UITextPicPopulateMesh = GameEventMgr.ET_UITextPicPopulateMesh
EventMgr.ET_UILongPress = GameEventMgr.ET_UILongPress
EventMgr.ET_UIPointerClick = GameEventMgr.ET_UIPointerClick
EventMgr.ET_UISliderValueChange = GameEventMgr.ET_UISliderValueChange
EventMgr.ET_UIInputFieldValueChange = GameEventMgr.ET_UIInputFieldValueChange
EventMgr.ET_UITextPicOnClickHref = GameEventMgr.ET_UITextPicOnClickHref
EventMgr.ET_UIActivityEffectFinish = GameEventMgr.ET_UIActivityEffectFinish
EventMgr.ET_UIChatViewUpdate = GameEventMgr.ET_UIChatViewUpdate
EventMgr.ET_UILoopListItemSelect = GameEventMgr.ET_UILoopListItemSelect
EventMgr.ET_UIDynamicListItemSelect = GameEventMgr.ET_UIDynamicListItemSelect
EventMgr.ET_UIDynamicListItemUpdate = GameEventMgr.ET_UIDynamicListItemUpdate
EventMgr.ET_UIDynamicListItemRequest = GameEventMgr.ET_UIDynamicListItemRequest
EventMgr.ET_UISlideSelectChange = GameEventMgr.ET_UISlideSelectChange
EventMgr.ET_UIScrollListViewChange = GameEventMgr.ET_UIScrollListViewChange
EventMgr.ET_UISlideSelectBegin = GameEventMgr.ET_UISlideSelectBegin
EventMgr.ET_UISlideSelectEnd = GameEventMgr.ET_UISlideSelectEnd
EventMgr.ET_UIScrollRectOnValueChanged = GameEventMgr.ET_UIScrollRectOnValueChanged
EventMgr.ET_CustomEvent = GameEventMgr.ET_CustomEvent
EventMgr.ET_AnimEvent = GameEventMgr.ET_AnimEvent
EventMgr.ET_Resource = GameEventMgr.ET_Resource
EventMgr.ET_EffectEvent = GameEventMgr.ET_EffectEvent
EventMgr.ET_Input = GameEventMgr.ET_Input
EventMgr.ET_SDK = GameEventMgr.ET_SDK
EventMgr.ET_Trigger = GameEventMgr.ET_Trigger
EventMgr.ET_LuaReload = GameEventMgr.ET_LuaReload


EventMgr.InputType_Touch = "InputType_Touch"
EventMgr.InputType_DragStart = "InputType_DragStart"
EventMgr.InputType_DragMove = "InputType_DragMove"
EventMgr.InputType_DragEnd = "InputType_DragEnd"
EventMgr.InputType_ZoomStart = "InputType_ZoomStart"
EventMgr.InputType_ZoomMove = "InputType_ZoomMove"
EventMgr.InputType_ZoomEnd = "InputType_ZoomEnd"
EventMgr.InputType_KeyUp = "InputType_KeyUp"
EventMgr.InputType_KeyDown = "InputType_KeyDown"
EventMgr.InputType_KeyRepeat = "InputType_KeyRepeat"

---------------- Interface Define begin -------------
function EventMgr:AddInputListener(cb)
    self:RegisterNativeEventCallback(self.ET_Input, "InputMgr", cb)
end

function EventMgr:RemoveInputListener()
    self:UnRegisterNativeEventCallback(self.ET_Input, "InputMgr")
end

function EventMgr:AddAppFocusListener(tag, cb)
    self:RegisterNativeEventCallback(self.ET_ApplicationFocus, tag, cb)
end

function EventMgr:RemoveAppFocusListener(tag)
    self:UnRegisterNativeEventCallback(self.ET_ApplicationFocus, tag)
end


function EventMgr:AddUIOnClick(go, cb)
    self:RemoveUIOnClick(go)
    self:RegisterNativeEventCallback(self.ET_UIOnClicked, go:GetInstanceID(), cb)
    self.game_event_mgr:RegisterUIEvent(go, self.ET_UIOnClicked)
end

function EventMgr:RemoveUIOnClick(go)
    self.game_event_mgr:UnRegisterUIEvent(go, self.ET_UIOnClicked)
    self:UnRegisterNativeEventCallback(self.ET_UIOnClicked, go:GetInstanceID())
end

function EventMgr:AddUIToggle(go, cb)
    self:RemoveUIToggle(go)
    self:RegisterNativeEventCallback(self.ET_UIToggle, go:GetInstanceID(), cb)
    self.game_event_mgr:RegisterUIEvent(go, self.ET_UIToggle)
end

function EventMgr:RemoveUIToggle(go)
    self.game_event_mgr:UnRegisterUIEvent(go, self.ET_UIToggle)
    self:UnRegisterNativeEventCallback(self.ET_UIToggle, go:GetInstanceID())
end

function EventMgr:AddUIOnPress(go, cb)
    self:RemoveUIOnPress(go)
    self:RegisterNativeEventCallback(self.ET_UIPress, go:GetInstanceID(), cb)
    self.game_event_mgr:RegisterUIEvent(go, self.ET_UIPress)
end

function EventMgr:RemoveUIOnPress(go)
    self.game_event_mgr:UnRegisterUIEvent(go, self.ET_UIPress)
    self:UnRegisterNativeEventCallback(self.ET_UIPress, go:GetInstanceID())
end

function EventMgr:AddUIOnRelease(go, cb)
    self:RemoveUIOnRelease(go)
    self:RegisterNativeEventCallback(self.ET_UIRelease, go:GetInstanceID(), cb)
    self.game_event_mgr:RegisterUIEvent(go, self.ET_UIRelease)
end

function EventMgr:RemoveUIOnRelease(go)
    self.game_event_mgr:UnRegisterUIEvent(go, self.ET_UIRelease)
    self:UnRegisterNativeEventCallback(self.ET_UIRelease, go:GetInstanceID())
end

function EventMgr:AddUIOnEnter(go, cb)
    self:RemoveUIOnEnter(go)
    self:RegisterNativeEventCallback(self.ET_UIEnter, go:GetInstanceID(), cb)
    self.game_event_mgr:RegisterUIEvent(go, self.ET_UIEnter)
end

function EventMgr:RemoveUIOnEnter(go)
    self.game_event_mgr:UnRegisterUIEvent(go, self.ET_UIEnter)
    self:UnRegisterNativeEventCallback(self.ET_UIEnter, go:GetInstanceID())
end

function EventMgr:AddUIOnExit(go, cb)
    self:RemoveUIOnExit(go)
    self:RegisterNativeEventCallback(self.ET_UIExit, go:GetInstanceID(), cb)
    self.game_event_mgr:RegisterUIEvent(go, self.ET_UIExit)
end

function EventMgr:RemoveUIOnExit(go)
    self.game_event_mgr:UnRegisterUIEvent(go, self.ET_UIExit)
    self:UnRegisterNativeEventCallback(self.ET_UIExit, go:GetInstanceID())
end

function EventMgr:AddUIOnDrag(go, cb)
    self:RemoveUIOnDrag(go)
    self:RegisterNativeEventCallback(self.ET_UIDrag, go:GetInstanceID(), cb)
    self.game_event_mgr:RegisterUIEvent(go, self.ET_UIDrag)
end

function EventMgr:RemoveUIOnDrag(go)
    self.game_event_mgr:UnRegisterUIEvent(go, self.ET_UIDrag)
    self:UnRegisterNativeEventCallback(self.ET_UIDrag, go:GetInstanceID())
end

function EventMgr:AddUIOnBeginDrag(go, cb)
    self:RemoveUIOnBeginDrag(go)
    self:RegisterNativeEventCallback(self.ET_UIBeginDrag, go:GetInstanceID(), cb)
    self.game_event_mgr:RegisterUIEvent(go, self.ET_UIBeginDrag)
end

function EventMgr:RemoveUIOnBeginDrag(go)
    self.game_event_mgr:UnRegisterUIEvent(go, self.ET_UIBeginDrag)
    self:UnRegisterNativeEventCallback(self.ET_UIBeginDrag, go:GetInstanceID())
end

function EventMgr:AddUIOnEndDrag(go, cb)
    self:RemoveUIOnEndDrag(go)
    self:RegisterNativeEventCallback(self.ET_UIEndDrag, go:GetInstanceID(), cb)
    self.game_event_mgr:RegisterUIEvent(go, self.ET_UIEndDrag)
end

function EventMgr:RemoveUIOnEndDrag(go)
    self.game_event_mgr:UnRegisterUIEvent(go, self.ET_UIEndDrag)
    self:UnRegisterNativeEventCallback(self.ET_UIEndDrag, go:GetInstanceID())
end

function EventMgr:AddUITreeViewChange(go, cb)
    self:RemoveUITreeViewChange(go)
    self:RegisterNativeEventCallback(self.ET_UITreeViewChange, go:GetInstanceID(), cb)
    self.game_event_mgr:RegisterUIEvent(go, self.ET_UITreeViewChange)
end

function EventMgr:RemoveUITreeViewChange(go)
    self.game_event_mgr:UnRegisterUIEvent(go, self.ET_UITreeViewChange)
    self:UnRegisterNativeEventCallback(self.ET_UITreeViewChange, go:GetInstanceID())
end

function EventMgr:AddUITreeViewSelect(go, cb)
    self:RemoveUITreeViewSelect(go)
    self:RegisterNativeEventCallback(self.ET_UITreeViewSelect, go:GetInstanceID(), cb)
    self.game_event_mgr:RegisterUIEvent(go, self.ET_UITreeViewSelect)
end

function EventMgr:RemoveUITreeViewSelect(go)
    self.game_event_mgr:UnRegisterUIEvent(go, self.ET_UITreeViewSelect)
    self:UnRegisterNativeEventCallback(self.ET_UITreeViewSelect, go:GetInstanceID())
end

function EventMgr:AddUISwipeViewChange(go, cb)
    self:RemoveUISwipeViewChange(go)
    self:RegisterNativeEventCallback(self.ET_UISwipeViewChange, go:GetInstanceID(), cb)
    self.game_event_mgr:RegisterUIEvent(go, self.ET_UISwipeViewChange)
end

function EventMgr:RemoveUISwipeViewChange(go)
    self.game_event_mgr:UnRegisterUIEvent(go, self.ET_UISwipeViewChange)
    self:UnRegisterNativeEventCallback(self.ET_UISwipeViewChange, go:GetInstanceID())
end

function EventMgr:AddUISwipeViewSelect(go, cb)
    self:RemoveUISwipeViewSelect(go)
    self:RegisterNativeEventCallback(self.ET_UISwipeViewSelect, go:GetInstanceID(), cb)
    self.game_event_mgr:RegisterUIEvent(go, self.ET_UISwipeViewSelect)
end

function EventMgr:RemoveUISwipeViewSelect(go)
    self.game_event_mgr:UnRegisterUIEvent(go, self.ET_UISwipeViewSelect)
    self:UnRegisterNativeEventCallback(self.ET_UISwipeViewSelect, go:GetInstanceID())
end

function EventMgr:AddUISlideSelectChange(go, cb)
    self:RemoveUISlideSelectChange(go)
    self:RegisterNativeEventCallback(self.ET_UISlideSelectChange, go:GetInstanceID(), cb)
    self.game_event_mgr:RegisterUIEvent(go, self.ET_UISlideSelectChange)
end

function EventMgr:RemoveUISlideSelectChange(go)
    self.game_event_mgr:UnRegisterUIEvent(go, self.ET_UISlideSelectChange)
    self:UnRegisterNativeEventCallback(self.ET_UISlideSelectChange, go:GetInstanceID())
end

function EventMgr:AddUIScrollListView(go, cb)
    self:RemoveUIScrollListView(go)
    self:RegisterNativeEventCallback(self.ET_UIScrollListViewChange, go:GetInstanceID(), cb)
    self.game_event_mgr:RegisterUIEvent(go, self.ET_UIScrollListViewChange)
end

function EventMgr:RemoveUIScrollListView(go)
    self.game_event_mgr:UnRegisterUIEvent(go, self.ET_UIScrollListViewChange)
    self:UnRegisterNativeEventCallback(self.ET_UIScrollListViewChange, go:GetInstanceID())
end

function EventMgr:AddUISlideSelectBegin(go, cb)
    self:RemoveUISlideSelectChange(go)
    self:RegisterNativeEventCallback(self.ET_UISlideSelectBegin, go:GetInstanceID(), cb)
    self.game_event_mgr:RegisterUIEvent(go, self.ET_UISlideSelectBegin)
end

function EventMgr:RemoveUISlideSelectBegin(go)
    self.game_event_mgr:UnRegisterUIEvent(go, self.ET_UISlideSelectBegin)
    self:UnRegisterNativeEventCallback(self.ET_UISlideSelectBegin, go:GetInstanceID())
end

function EventMgr:AddUISlideSelectEnd(go, cb)
    self:RemoveUISlideSelectChange(go)
    self:RegisterNativeEventCallback(self.ET_UISlideSelectEnd, go:GetInstanceID(), cb)
    self.game_event_mgr:RegisterUIEvent(go, self.ET_UISlideSelectEnd)
end

function EventMgr:RemoveUISlideSelectEnd(go)
    self.game_event_mgr:UnRegisterUIEvent(go, self.ET_UISlideSelectEnd)
    self:UnRegisterNativeEventCallback(self.ET_UISlideSelectEnd, go:GetInstanceID())
end

function EventMgr:AddUIScrollRectOnValueChanged(go, cb)
    self:RemoveUIScrollRectOnValueChanged(go)
    self:RegisterNativeEventCallback(self.ET_UIScrollRectOnValueChanged, go:GetInstanceID(), cb)
    self.game_event_mgr:RegisterUIEvent(go, self.ET_UIScrollRectOnValueChanged)
end

function EventMgr:RemoveUIScrollRectOnValueChanged(go)
    self.game_event_mgr:UnRegisterUIEvent(go, self.ET_UIScrollRectOnValueChanged)
    self:UnRegisterNativeEventCallback(self.ET_UIScrollRectOnValueChanged, go:GetInstanceID())
end

function EventMgr:AddUITextPicPopulateMesh(go, cb)
    self:RemoveUITextPicPopulateMesh(go)
    self:RegisterNativeEventCallback(self.ET_UITextPicPopulateMesh, go:GetInstanceID(), cb)
    self.game_event_mgr:RegisterUIEvent(go, self.ET_UITextPicPopulateMesh)
end

function EventMgr:RemoveUITextPicPopulateMesh(go)
    self.game_event_mgr:UnRegisterUIEvent(go, self.ET_UITextPicPopulateMesh)
    self:UnRegisterNativeEventCallback(self.ET_UITextPicPopulateMesh, go:GetInstanceID())
end

function EventMgr:AddUIOnLongPress(go, cb)
    self:RemoveUIOnLongPress(go)
    self:RegisterNativeEventCallback(self.ET_UILongPress, go:GetInstanceID(), cb)
    self.game_event_mgr:RegisterUIEvent(go, self.ET_UILongPress)
end

function EventMgr:RemoveUIOnLongPress(go)
    self.game_event_mgr:UnRegisterUIEvent(go, self.ET_UILongPress)
    self:UnRegisterNativeEventCallback(self.ET_UILongPress, go:GetInstanceID())
end

function EventMgr:AddUIPointerClick(go, cb)
    self:RemoveUIPointerClick(go)
    self:RegisterNativeEventCallback(self.ET_UIPointerClick, go:GetInstanceID(), cb)
    self.game_event_mgr:RegisterUIEvent(go, self.ET_UIPointerClick)
end

function EventMgr:RemoveUIPointerClick(go)
    self.game_event_mgr:UnRegisterUIEvent(go, self.ET_UIPointerClick)
    self:UnRegisterNativeEventCallback(self.ET_UIPointerClick, go:GetInstanceID())
end

function EventMgr:AddUISliderValueChange(go, cb)
    self:RemoveUISliderValueChange(go)
    self:RegisterNativeEventCallback(self.ET_UISliderValueChange, go:GetInstanceID(), cb)
    self.game_event_mgr:RegisterUIEvent(go, self.ET_UISliderValueChange)
end

function EventMgr:RemoveUISliderValueChange(go)
    self.game_event_mgr:UnRegisterUIEvent(go, self.ET_UISliderValueChange)
    self:UnRegisterNativeEventCallback(self.ET_UISliderValueChange, go:GetInstanceID())
end

function EventMgr:AddUIInputFieldValueChange(go,cb)
    self:RemoveUIInputFieldValueChange(go)
    self:RegisterNativeEventCallback(self.ET_UIInputFieldValueChange,go:GetInstanceID(),cb)
    self.game_event_mgr:RegisterUIEvent(go,self.ET_UIInputFieldValueChange)
end

function EventMgr:RemoveUIInputFieldValueChange(go)
    self.game_event_mgr:UnRegisterUIEvent(go, self.ET_UIInputFieldValueChange)
    self:UnRegisterNativeEventCallback(self.ET_UIInputFieldValueChange, go:GetInstanceID())
end

function EventMgr:AddUITextPicOnClickHref(go, cb)
    self:RemoveUITextPicOnClickHref(go)
    self:RegisterNativeEventCallback(self.ET_UITextPicOnClickHref, go:GetInstanceID(), cb)
    self.game_event_mgr:RegisterUIEvent(go, self.ET_UITextPicOnClickHref)
end

function EventMgr:RemoveUITextPicOnClickHref(go)
    self.game_event_mgr:UnRegisterUIEvent(go, self.ET_UITextPicOnClickHref)
    self:UnRegisterNativeEventCallback(self.ET_UITextPicOnClickHref, go:GetInstanceID())
end

function EventMgr:AddUIActivityEffectFinish(go, cb)
    self:RemoveUIActivityEffectFinish(go)
    self:RegisterNativeEventCallback(self.ET_UIActivityEffectFinish, go:GetInstanceID(), cb)
    self.game_event_mgr:RegisterUIEvent(go, self.ET_UIActivityEffectFinish)
end

function EventMgr:RemoveUIActivityEffectFinish(go)
    self.game_event_mgr:UnRegisterUIEvent(go, self.ET_UIActivityEffectFinish)
    self:UnRegisterNativeEventCallback(self.ET_UIActivityEffectFinish, go:GetInstanceID())
end

function EventMgr:AddUIChatViewUpdate(go, cb)
    self:RemoveUIChatViewUpdate(go)
    self:RegisterNativeEventCallback(self.ET_UIChatViewUpdate, go:GetInstanceID(), cb)
    self.game_event_mgr:RegisterUIEvent(go, self.ET_UIChatViewUpdate)
end

function EventMgr:RemoveUIChatViewUpdate(go)
    self.game_event_mgr:UnRegisterUIEvent(go, self.ET_UIChatViewUpdate)
    self:UnRegisterNativeEventCallback(self.ET_UIChatViewUpdate, go:GetInstanceID())
end

function EventMgr:AddUILoopListItemSelect(go, cb)
    self:RemoveUILoopListItemSelect(go)
    self:RegisterNativeEventCallback(self.ET_UILoopListItemSelect, go:GetInstanceID(), cb)
    self.game_event_mgr:RegisterUIEvent(go, self.ET_UILoopListItemSelect)
end

function EventMgr:RemoveUILoopListItemSelect(go)
    self.game_event_mgr:UnRegisterUIEvent(go, self.ET_UILoopListItemSelect)
    self:UnRegisterNativeEventCallback(self.ET_UILoopListItemSelect, go:GetInstanceID())
end

function EventMgr:AddUIDynamicListItemSelect(go, cb)
    self:RemoveUIDynamicListItemSelect(go)
    self:RegisterNativeEventCallback(self.ET_UIDynamicListItemSelect, go:GetInstanceID(), cb)
    self.game_event_mgr:RegisterUIEvent(go, self.ET_UIDynamicListItemSelect)
end
function EventMgr:RemoveUIDynamicListItemSelect(go)
    self.game_event_mgr:UnRegisterUIEvent(go, self.ET_UIDynamicListItemSelect)
    self:UnRegisterNativeEventCallback(self.ET_UIDynamicListItemSelect, go:GetInstanceID())
end
function EventMgr:AddUIDynamicListItemUpdate(go, cb)
    self:RemoveUIDynamicListItemUpdate(go)
    self:RegisterNativeEventCallback(self.ET_UIDynamicListItemUpdate, go:GetInstanceID(), cb)
    self.game_event_mgr:RegisterUIEvent(go, self.ET_UIDynamicListItemUpdate)
end
function EventMgr:RemoveUIDynamicListItemUpdate(go)
    self.game_event_mgr:UnRegisterUIEvent(go, self.ET_UIDynamicListItemUpdate)
    self:UnRegisterNativeEventCallback(self.ET_UIDynamicListItemUpdate, go:GetInstanceID())
end
function EventMgr:AddUIDynamicListItemRequest(go, cb)
    self:RemoveUIDynamicListItemRequest(go)
    self:RegisterNativeEventCallback(self.ET_UIDynamicListItemRequest, go:GetInstanceID(), cb)
    self.game_event_mgr:RegisterUIEvent(go, self.ET_UIDynamicListItemRequest)
end
function EventMgr:RemoveUIDynamicListItemRequest(go)
    self.game_event_mgr:UnRegisterUIEvent(go, self.ET_UIDynamicListItemRequest)
    self:UnRegisterNativeEventCallback(self.ET_UIDynamicListItemRequest, go:GetInstanceID())
end

function EventMgr:AddResourceListener(cb)
    self:RegisterNativeEventCallback(self.ET_Resource, "resource", cb)
end

function EventMgr:RemoveResourceListener()
    self:UnRegisterNativeEventCallback(self.ET_Resource, "resource")
end

function EventMgr:AddEffectListener(tag, cb)
    self:RegisterNativeEventCallback(self.ET_EffectEvent, tag, cb)
end

function EventMgr:RemoveEffectListener(tag)
    self:UnRegisterNativeEventCallback(self.ET_EffectEvent, tag)
end

function EventMgr:AddCustomListener(go, cb)
    self.game_event_mgr:RegisterCustomEvent(go)
    self:RegisterNativeEventCallback(self.ET_CustomEvent, go:GetInstanceID(), cb)
end

function EventMgr:RemoveCustomListener(go)
    self.game_event_mgr:UnRegisterCustomEvent(go)
    self:UnRegisterNativeEventCallback(self.ET_CustomEvent, go:GetInstanceID())
end

function EventMgr:AddAnimEventListener(unit_guid, cb)
    self:RegisterNativeEventCallback(self.ET_AnimEvent, unit_guid, cb)
end

function EventMgr:RemoveAnimEventListener(unit_guid)
    self:UnRegisterNativeEventCallback(self.ET_AnimEvent, unit_guid)
end

function EventMgr:AddTriggerListener(tag, cb)
    self:RegisterNativeEventCallback(self.ET_Trigger, tag, cb)
end

function EventMgr:RemoveTriggerListener(tag)
    self:UnRegisterNativeEventCallback(self.ET_Trigger, tag)
end

function EventMgr:AddSDKListener(cb)
    self:RegisterNativeEventCallback(self.ET_SDK, "sdk", cb)
    print("AddSDKListener", self.ET_SDK)
end

function EventMgr:RemoveSDKListener()
    self:UnRegisterNativeEventCallback(self.ET_SDK, "sdk")
end
----------------- Interface Define end -------------

function EventMgr:DoInit()
    self.game_event_mgr = GameEventMgr.GetInstance()
    self.native_event_callbacks = {}
    self:RegisterNativeEventCallback(self.ET_LuaReload, "lua_reload", function(lua_name)
            print("reload file:" .. lua_name)
            local old_tb = package.loaded[lua_name]
            if old_tb.__RELOAD_FLAG == false then
                return
            end
            local chunck = loadfile(lua_name)
            old_tb.__RELOADING = true
            local new_tb = chunck()
            if not old_tb.__RELOAD_MOD_NAME then  -- reload table
                for key, value in pairs(new_tb) do
                    local v = rawget(new_tb, key)
                    if v then
                        rawset(old_tb, key, v)
                    end
                end
            end
            if old_tb.__RELOAD_AFTER then
                old_tb.__RELOAD_AFTER()
            end
            old_tb.__RELOADING = nil
            --ComMgrs.spell_mgr:ClearLuaCache()
            SpecMgrs.data_mgr:ClearAll()
        end)
end

-- event_tag 可以是int或者string
function EventMgr:RegisterNativeEventCallback(event_type, event_tag, cb)
    if not self.native_event_callbacks[event_type] then
        self.native_event_callbacks[event_type] = {}
    end
    self.native_event_callbacks[event_type][event_tag] = cb
end

function EventMgr:UnRegisterNativeEventCallback(event_type, event_tag)
    if not self.native_event_callbacks[event_type] then
        return
    end
    self.native_event_callbacks[event_type][event_tag] = nil
end

function EventMgr:Update(delta_time)
    self:_DispatchNativeEvents()
end

function EventMgr:_DispatchNativeEvents()
    local max_count = 3 -- recursive eat max count events in one frame
    while max_count > 0 do
        local events = self.game_event_mgr:GetAllEvents()
        if #events > 0 then 
            for i, evt in ipairs(events) do
                local e_type = evt.event_type
                local e_tag = evt.event_tag
                local n_cbs = self.native_event_callbacks[e_type]
                if n_cbs then
                    if not e_tag then
                        for _, cb in pairs(n_cbs) do
                            xpcall(cb, ErrorHandle, table.unpack(evt, 1, evt.n))
                        end
                    elseif n_cbs[e_tag] then
                        xpcall(n_cbs[e_tag], ErrorHandle, table.unpack(evt, 1, evt.n))
                    end
                end
            end
            max_count = max_count - 1
        else
            break
        end
    end
end

function EventMgr:ClearAll()
end

function EventMgr:DoDestroy()
    self:ClearAll()
end

return EventMgr
