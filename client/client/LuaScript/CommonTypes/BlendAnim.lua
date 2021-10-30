local lerp = math.lerp

BlendAnim = {}

BlendAnim.__index = BlendAnim

BlendAnim.__call = function(...)
	return BlendAnim.New(...)
end

function BlendAnim.New(time, in_time, out_time)
	local anim = {
        time = time,
        in_time = in_time,
        out_time = out_time,
        weight = 0,
        state = 1,
    }
	setmetatable(anim, BlendAnim)
	return anim
end

function BlendAnim:Update(delta_time)
    local is_anim = false
    if self.state == 1 then
        is_anim = true
        if delta_time > self.in_time then
            delta_time = delta_time - self.in_time
            self.weight = 1
            self.in_time = 0
            self.state = 0
        else
            self.weight = lerp(self.weight, 1, delta_time / self.in_time)
            self.in_time = self.in_time - delta_time
            return is_anim
        end
    end
    if self.state == 0 and self.time and self.time >= 0 then
        if delta_time > self.time then
            delta_time = delta_time - self.time
            self.time = 0
            self.state = -1
        else
            self.time = self.time - delta_time
            return is_anim
        end
    end
    if self.state == -1 then
        is_anim = true
        if delta_time > self.out_time then
            delta_time = delta_time - self.out_time
            self.weight = 0
            self.out_time = 0
            self.state = -2
            self.is_finish = true
        else
            self.weight = math.lerp(self.weight, 0, delta_time / self.out_time)
            self.out_time = self.out_time - delta_time
        end
    end
    return is_anim
end

function BlendAnim:Stop(force_end)
    self.state = -1
    if force_end then
        self:Update(self.out_time)
    end
end

