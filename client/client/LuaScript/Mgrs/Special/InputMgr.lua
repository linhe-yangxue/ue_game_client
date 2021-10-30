
local InputMgr = class("Mgrs.Special.InputMgr")

local Input = UnityEngine.Input
local TouchPhase = UnityEngine.TouchPhase
local TouchPhase_Began = TouchPhase.Began
local TouchPhase_Moved = TouchPhase.Moved
local TouchPhase_Stationary = TouchPhase.Stationary
local TouchPhase_Ended = TouchPhase.Ended
local TouchPhase_Canceled = TouchPhase.Canceled
local GameEventInput = GameEventInput
local EventMgr = require("Mgrs.Special.EventMgr")

InputMgr.drag_dist = 10;

function InputMgr:DoInit()
    SpecMgrs.event_mgr:AddInputListener(
            function(...)
                self:InputHandle(...)
            end
        )
    self.input_listener_list = {}
    self.use_touch = Application.isMobilePlatform and not Application.isEditor
    self.touch_id = {}
    self.touch_pos = {}
    self.mode = nil  -- nil,touch,drag,zoom
    self.last_pos = nil  -- for drag
    self.last_dist = nil  -- for zoom

    -- todo wangweining :暂时放这里后面会放到相应的stage_input里面
    local IH_Keyboard = require("Input.InputHandle_Keyboard")
    self.input_handle_keyboard = IH_Keyboard.New()
    self.input_handle_keyboard:DoInit()
    self:AddListenerHandle(self.input_handle_keyboard)
end

function InputMgr:AddListenerHandle(obj)
    table.insert(self.input_listener_list, obj)
end

function InputMgr:RemoveListenerHandle(obj)
    local i = table.index(self.input_listener_list, obj)
    table.remove(self.input_listener_list, i)
end

function InputMgr:InputHandle(...)
    for i = #self.input_listener_list, 1, -1 do
        self.input_listener_list[i]:ProcessInput(...)
    end
end

function InputMgr:DoDestroy()
    SpecMgrs.event_mgr:RemoveInputListener()
    -- todo wangweining:随着上面一起迁移
    if self.input_handle_keyboard then
        self:RemoveListenerHandle(self.input_handle_keyboard)
        self.input_handle_keyboard:DoDestroy()
        self.input_handle_keyboard = nil
    end
end

function InputMgr:Update(delta_time)
    if self.use_touch then
        self:_UpdateInputTouch(delta_time)
    else
        self:_UpdateInputMouse(delta_time)
    end
end

function InputMgr:_UpdateInputMouse(delta_time)
    if Input.GetMouseButtonDown(0) and not GameEventInput.IsPositionOnUI(Input.mousePosition) then
        self:_AddTouch("mouse", Input.mousePosition)
    end
    if Input.GetMouseButtonUp(0) then
        self:_RemoveTouch("mouse", Input.mousePosition)
    end
    if Input.GetMouseButton(0) then
        self:_UpdateTouch("mouse", Input.mousePosition)
    end
    if Input.GetKeyDown("up") then
        local ui = SpecMgrs.ui_mgr:GetUI("DebugUI")
        if ui then
            ui:GetCacheCommand(-1)
        end
    end
    if Input.GetKeyDown("down") then
        local ui = SpecMgrs.ui_mgr:GetUI("DebugUI")
        if ui then
            ui:GetCacheCommand(1)
        end
    end
    local test_key = {"f1","f2","f3","f4","f5","f6","f7","f8","f9","f10","f11", "f12", "escape", "1", "2", "3"}
    for _, key in ipairs(test_key) do
        if Input.GetKeyDown(key) then
            self:InputHandle(EventMgr.InputType_KeyDown, key)
        end
        if Input.GetKeyUp(key) then
            self:InputHandle(EventMgr.InputType_KeyUp, key)
        end
        if Input.GetKey(key) then
            self:InputHandle(EventMgr.InputType_KeyRepeat, key)
        end
    end

    local wheel = Input.GetAxis("Mouse ScrollWheel")
    if wheel ~= 0 then
        self:InputHandle(EventMgr.InputType_ZoomMove, 1, 1 - wheel)
    end

end

function InputMgr:_UpdateInputTouch(delta_time)
    for i = 0, Input.touchCount - 1 do
        local touch = Input.GetTouch(i)
        local touch_id = touch.fingerId
        local touch_pos = touch.position
        local touch_phase = touch.phase
        if touch_phase == TouchPhase_Began and not GameEventInput.IsPositionOnUI(touch_pos) then
            self:_AddTouch(touch_id, touch_pos)
        elseif touch_phase == TouchPhase_Ended or touch_phase == TouchPhase_Canceled then
            self:_RemoveTouch(touch_id, touch_pos)
        elseif touch_phase == TouchPhase_Moved then
            self:_UpdateTouch(touch_id, touch_pos)
        end
    end
end

function InputMgr:_AddTouch(id, pos)
    table.insert(self.touch_id, id)
    table.insert(self.touch_pos, pos)
    local touch_count = #self.touch_id
    if touch_count == 1 then
        self.mode = "touch"
        self.last_pos = pos
    elseif touch_count == 2 then
        self.mode = "zoom"
        self.last_dist = Vector3.Distance(self.touch_pos[1], self.touch_pos[2])
        self:InputHandle(EventMgr.InputType_ZoomStart, self.last_dist)
    end
end

function InputMgr:_RemoveTouch(id, pos)
    local index = table.index(self.touch_id, id)
    if not index then return end
    table.remove(self.touch_id, index)
    table.remove(self.touch_pos, index)
    local touch_count = #self.touch_id
    if touch_count == 0 then
        if self.mode == "touch" then
            self:InputHandle(EventMgr.InputType_Touch, pos)
        else
            self:InputHandle(EventMgr.InputType_DragEnd, pos)
        end
        self.mode = nil
    elseif touch_count == 1 then
        self:InputHandle(EventMgr.InputType_ZoomEnd, self.last_dist)
        self.mode = nil
    end
end

function InputMgr:_UpdateTouch(id, pos)
    if not self.mode then return end
    local index = table.index(self.touch_id, id)
    if not index then return false end
    self.touch_pos[index] = pos
    if self.mode == "touch" then
        if Vector3.Distance(pos, self.last_pos) > self.drag_dist then
            self.mode = "drag"
            self:InputHandle(EventMgr.InputType_DragStart, self.last_pos)
            self:InputHandle(EventMgr.InputType_DragMove, pos, pos - self.last_pos)
        end
    elseif self.mode == "drag" then
        local delta = pos - self.last_pos
        if pos ~= self.last_pos then
            self.last_pos = pos
            self:InputHandle(EventMgr.InputType_DragMove, pos, delta)
        end
    elseif self.mode == "zoom" then
        if index ~= 1 and index ~= 2 then return end
        local new_dist = Vector3.Distance(self.touch_pos[1], self.touch_pos[2])
        if new_dist ~= self.last_dist then
            local zoom = self.last_dist / new_dist
            self.last_dist = new_dist
            self:InputHandle(EventMgr.InputType_ZoomMove, new_dist, zoom)
        end
    else
        error("undefined mode")
    end
end

return InputMgr