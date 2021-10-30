AnimationCurve = class('AnimationCurve')
--['curves'] = {
--	['x'] = {
--		['preWrapMode'] = 8,
--		['postWrapMode'] = 8,
--		['keys'] = {
--			[1] = {['value'] = 3.3127223186824E-09, ['time'] = 0, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0},
--			[2] = {['value'] = 3.3127223186824E-09, ['time'] = 0.899999976158142, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0},
--		}
--	},
--	['y'] = {...

AnimationCurve.WrapMode = {
    Default = 0,
    Once = 1,
    Clamp = 1,
    Loop = 2,
    PingPong = 4,
    ClampForever = 8,
}

function AnimationCurve.EvaluateVector3Curves(curves, time)
    return Vector3.New(
        AnimationCurve.EvaluateCurve(curves.x, time),
        AnimationCurve.EvaluateCurve(curves.y, time),
        AnimationCurve.EvaluateCurve(curves.z, time))
end

function AnimationCurve.EvaluateQuaternionCurves(curves, time)
    return Quaternion.New(
        AnimationCurve.EvaluateCurve(curves.x, time),
        AnimationCurve.EvaluateCurve(curves.y, time),
        AnimationCurve.EvaluateCurve(curves.z, time),
        AnimationCurve.EvaluateCurve(curves.w, time))
end

function AnimationCurve.EvaluateRotationCurves(curves, time)
    if curves.w then
        return AnimationCurve.EvaluateQuaternionCurves(curves, time)
    else
        return Quaternion.Euler(AnimationCurve.EvaluateVector3Curves(curves, time))
    end
end

function AnimationCurve.EvaluateCurve(curve, time)
    local keys = curve.keys
    local length = #keys
    if length == 0 then
        return 0
    elseif length == 1 then
        return keys[1].value
    end
    local begin_time = keys[1].time
    local end_time = keys[length].time
    if time < begin_time then
        if curve.preWrapMode == AnimationCurve.WrapMode.Loop then
            time = (time - begin_time) % (end_time - begin_time) + begin_time
        elseif curve.preWrapMode == AnimationCurve.WrapMode.PingPong then
            local relative_time = time - begin_time;
            local total_time = end_time - begin_time;
            if math.floor(relative_time / total_time) % 2 == 0 then
                time = relative_time % total_time + begin_time
            else
                time = total_time - relative_time % total_time + begin_time
            end
        else
            time = begin_time
        end
    elseif time > end_time then
        if curve.postWrapMode == AnimationCurve.WrapMode.Loop then
            time = (time - begin_time) % (end_time - begin_time) + begin_time
        elseif curve.postWrapMode == AnimationCurve.WrapMode.PingPong then
            local relative_time = time - begin_time;
            local total_time = end_time - begin_time;
            if math.floor(relative_time / total_time) % 2 == 0 then
                time = relative_time % total_time + begin_time
            else
                time = total_time - relative_time % total_time + begin_time
            end
        else
            time = end_time
        end
    end
    if time == begin_time then
        return keys[1].value
    elseif time == end_time then
        return keys[length].value
    else
        local i = 1
        while keys[i].time < time do
            i = i + 1
        end
        return AnimationCurve.EvaluateKey(keys[i - 1], keys[i], time)
    end
end

function AnimationCurve.EvaluateKey(k0, k1, time)
    local dt = k1.time - k0.time

    local m0 = k0.outTangent * dt
    local m1 = k1.inTangent * dt

    local t = (time - k0.time) / dt
    local t2 = t * t
    local t3 = t2 * t

    local a = 2 * t3 - 3 * t2 + 1
    local b = t3 - 2 * t2 + t
    local c = t3 - t2
    local d = -2 * t3 + 3 * t2

    return a * k0.value + b * m0 + c * m1 + d * k1.value
end

return AnimationCurve