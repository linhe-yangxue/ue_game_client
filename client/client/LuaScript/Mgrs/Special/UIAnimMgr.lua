local UIAnimMgr = class("Mgrs.Special.UIAnimMgr")

-------interface define begin----------
--位移动画
function UIAnimMgr:PlayMoveAnim(time, game_object, from, to, _tween, cb)
    if IsNil(game_object) then
        PrintError("PlayMoveAnim: 'game_object' Is Nil!")
        return
    end
    local rect_transform = game_object:GetComponent("RectTransform")
    local property = "anchoredPosition"
    return self:PlayTweenAnim(time, rect_transform, property, from, to, _tween, cb)
end

--透明度渐变动画
function UIAnimMgr:PlayFadeAnim(time, game_object, from, to, _tween, cb)
    if IsNil(game_object) then
        PrintError("PlayFadeAnim: 'game_object' Is Nil!")
        return
    end
    local canvas_group = game_object:GetComponent("CanvasGroup")
    local property = "alpha"
    return self:PlayTweenAnim(time, canvas_group, property, from, to, _tween, cb)
end

function UIAnimMgr:PlayScrollAnim(time, game_object, property, from, to, _tween, cb)
    if IsNil(game_object) then
        PrintError("PlayFadeAnim: 'game_object' Is Nil!")
        return
    end
    local scroll_rect = game_object:GetComponent("ScrollRect")
    local property = property
    return self:PlayTweenAnim(time, scroll_rect, property, from, to, _tween, cb)
end

--播放插值动画，
--obj: Unity对象的Component，
--property: obj的某项属性值(string)，如"anchoredPosition","alpha","text"....
--from, to: 变化的起始值和结束值，如果两者的数值类型不是number而是table,则该table中必须实现插值函数Lerp
--_tween: 由tween.easing中提供的变化方式，默认为线性
function UIAnimMgr:PlayTweenAnim(time, obj, property, from, to, _tween, cb)
    if IsNil(obj) then
        PrintError("PlayTweenAnim: 'obj' Is Nil!")
        return
    end
    local lerp
    if type(from) == "number" then
        lerp = math.lerp
    elseif type(from) == "table" then
        lerp = from.Lerp
    end
    if not lerp then
        PrintError("PlayTweenAnim: Can't Find A Available Lerp!")
        return
    end
    _tween = _tween or tween.easing.linear
    local anim
    local func = function(process)
        if IsNil(obj) then
            self:StopAnim(anim)
            return
        end
        process = _tween(process, 0, 1, 1)
        obj[property] = lerp(from, to, process)
        if process == 1 then
            if cb then
                cb()
            end
        end
    end
    anim = self:PlayAnim(time, func)
    return anim
end

--在time秒内，每帧调用一次func(process)，传入参数process为:0 ~ 1(动画开始 ~ 动画结束)。
--注意：如果func方法中涉及任何对Unity对象的调用，必须在func方法开始处进行IsNil判断！
function UIAnimMgr:PlayAnim(time, func)
    if not func then
        PrintError("PlayAnim 'func' Is Invalid Argument!")
        return
    end
    if not time or time < 0 then
        PrintError("PlayAnim 'time' Is Invalid Argument!")
        return
    end
    local anim = self:_CreateAnimation(func,time)
    table.insert(self.animation_list, anim)
    return anim
end

function UIAnimMgr:StopAnim(anim, recover)
    if not anim or anim.is_deleted then
        return
    end
    anim.is_deleted = true
    if recover then
        anim.func(0)
    end
end
-------interface define end------------

-------private begin--------------
function UIAnimMgr:DoInit()
    self.animation_list = {}
end

function UIAnimMgr:DoDestroy()
    self.animation_list = nil
end

function UIAnimMgr:Update()
    if #self.animation_list == 0 then
        return
    end
    local now = self:_Now()
    for i = #self.animation_list, 1, -1 do
        local anim = self.animation_list[i]
        if anim.is_deleted then
            table.remove(self.animation_list, i)
        else
            local delta_time = now - anim.begin_time
            if anim.duration > delta_time then
                local process = delta_time / anim.duration
                anim.func(process)
            else
                anim.func(1)
                table.remove(self.animation_list, i)
            end
        end
    end
end

function UIAnimMgr:_CreateAnimation(func, time)
    return {
        func = func,
        begin_time = self:_Now(),
        duration = time,
        is_deleted = false
    }
end

function UIAnimMgr:_Now()
    return  Time.unscaledTime
end

-------private end----------------

return UIAnimMgr