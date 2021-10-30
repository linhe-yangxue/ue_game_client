local TimerMgr = class("CommonTypes.TimerMgr")

local kSlotSize = 256
local kFrameMsec = 33
local kFrameSec = kFrameMsec * 0.001

-- ====================  Timer Defines Begin ============================
local Timer = DECLARE_CLASS(TimerMgr, "Timer")

function Timer:DoInit(guid, func, loop, duration, timeline)
    self.guid = guid
    self.func = func
    self.loop = loop
    self.duration = duration
    self.timeline = timeline
    self.is_delete = false
    self.container = nil
end
-- ====================  Timer Defines End ============================

-- ====================  TimerWheel Defines Begin ============================
local TimerWheel = DECLARE_CLASS(TimerMgr, "TimerWheel")

-- 除了第一个Wheel之外，每个Wheel的都是从slot_time开始到time_range,第一个wheel从0开始到time_range，所以在Add的时候要delay-self.slot_time+kFrameMsec
function TimerWheel:DoInit(slot_time)
    self.head = 0
    self.time_range = slot_time * kSlotSize
    self.slot_time = slot_time
    self.wheel_slot_tb = {}
    self.next_wheel = nil
end

function TimerWheel:NextSlot()
    local idx = self.head
    self.head = self.head + 1
    local tb = self.wheel_slot_tb[idx]
    self.wheel_slot_tb[idx] = nil
    return tb
end

function TimerWheel:Add(delay, tm)
    local slot = (self.head + math.floor(math.max(0, (delay - self.slot_time + kFrameMsec)) / self.slot_time)) % kSlotSize
    local w_tb = self.wheel_slot_tb[slot] or {}
    table.insert(w_tb, tm)
    tm.container = w_tb
    self.wheel_slot_tb[slot] = w_tb
end
-- ====================  TimerWheel Defines End ============================

-- ====================  TimerMgr Defines Begin ============================
function TimerMgr:DoInit()
    self._guid_base = 0
    self._timer_wheels = {}
    self._accumlate_time = 0
    self._update_next_frame = {}
    for i = 1, 4 do
        local n_w = TimerWheel.New()
        n_w:DoInit(kFrameMsec * math.intpow(kSlotSize, i - 1))
        self._timer_wheels[i] = n_w
        if i > 1 then
            self._timer_wheels[i - 1].next_wheel = n_w
        end
    end
end

function TimerMgr:NewTimerGuid()
    self._guid_base = self._guid_base + 1
    return self._guid_base
end

-- loop为0时则无限循环,  1表示只调用1次, 2表示2次。。。等等
function TimerMgr:AddTimer(func, sec_time, loop)
    loop = loop or 1
    local msec_time = math.max(0, math.ceil(sec_time * 1000))
    local tm = Timer.New()
    tm:DoInit(self:NewTimerGuid(), func, loop, msec_time, msec_time + self:Now())
    self:_InnerAdd(tm)
    return tm
end

function TimerMgr:RemoveTimer(timer)
    timer.is_delete = true
    if timer.timeline - self:Now() > 20000 and timer.container then
        local idx = nil
        for i, tm in ipairs(timer.container) do
            if tm == timer then
                idx = i
                break
            end
        end
        if idx then
            table.remove(timer.container, idx)
        end
    end
end

function TimerMgr:_InnerAdd(tm)
    local delay = tm.timeline - self:Now()
    if delay <= 0 then
        table.insert(self._update_next_frame, tm)
    else
        local s_wheel = self._timer_wheels[#self._timer_wheels]
        for _, wheel in ipairs(self._timer_wheels) do
            if delay < wheel.time_range then
                s_wheel = wheel
                break
            end
        end
        s_wheel:Add(delay, tm)
    end
end

function TimerMgr:Now()
    return Time.msec_time
end

function TimerMgr:Update(delta_time)
    local execute_timers = {}
    if #self._update_next_frame > 0 then
        for _, tm in ipairs(self._update_next_frame) do
            table.insert(execute_timers, tm)
        end
        self._update_next_frame = {}
    end
    self._accumlate_time = self._accumlate_time + delta_time
    local cycle = 0
    while self._accumlate_time >= kFrameSec do
        self._accumlate_time = self._accumlate_time - kFrameSec
        cycle = cycle + 1
    end
    while cycle > 0 do
        cycle = cycle - 1
        local timer_list = self._timer_wheels[1]:NextSlot()
        if timer_list then
            for _, timer in ipairs(timer_list) do
                timer.container = nil
                table.insert(execute_timers, timer)
            end
        end
        for _, wheel in ipairs(self._timer_wheels) do
            if wheel.head == kSlotSize then
                wheel.head = 0
                if wheel.next_wheel then
                    local tms = wheel.next_wheel:NextSlot()
                    if tms then
                        for _, tm in ipairs(tms) do
                            tm.container = nil
                            if not tm.is_delete then
                                self:_InnerAdd(tm)
                            end
                        end
                    end
                end
            else
                break
            end
        end
    end
    for _, tm in ipairs(execute_timers) do
        if not tm.is_delete then
            local re_add = tm.loop == 0
            if tm.loop > 0 then
                tm.loop = tm.loop - 1
                if tm.loop > 0 then
                    re_add = true
                end
            end
            if re_add then
                -- 注意不要累计误差
                tm.timeline = tm.timeline + tm.duration
                self:_InnerAdd(tm)
            else
                tm.is_delete = true
            end
            tm.func(tm)
        end
    end
end

return TimerMgr
-- ====================  TimerMgr Defines End ============================
