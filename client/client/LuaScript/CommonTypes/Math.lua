local floor = math.floor
local abs = math.abs

function math.round(num)
	return floor(num + 0.5)
end

function math.sign(num)  
	if num > 0 then
		num = 1
	elseif num < 0 then
		num = -1
	else 
		num = 0
	end

	return num
end

function math.clamp(num, min, max)
	min = min or 0
	max = max or 1
	if num <= min then
		num = min
	elseif num >= max then
		num = max
	end
	
	return num
end

local clamp = math.clamp

function math.lerp(from, to, t)
	return from + (to - from) * clamp(t, 0, 1)
end

-- curve = { {time = 0, value = a}, {time = 2, value = b}, ...}
-- curve必须按time从小到大排序，time和value键名可以自定义。
-- 返回，2个value,1个插值系数,状态，如：time = 0.5 => a, b, 0.25
function math.LerpCurve(curve, time, time_key, value_key)
    time_key = time_key or "time"
    value_key = value_key or "value"
    local len = #curve
    if time <= curve[1][time_key] then return curve[1][value_key], curve[1][value_key], 1, -1 end
    if time >= curve[len][time_key] then return curve[len][value_key], curve[len][value_key], 0, 1 end
    for i = 2, len do
        if time <= curve[i][time_key] then
            local t1 = curve[i - 1][time_key]
            local t2 = curve[i][time_key]
            local t = (time - t1) / (t2 - t1)
            return curve[i - 1][value_key], curve[i][value_key], t, 0
        end
    end
end

function math.Repeat(t, length)    
	return t - (floor(t / length) * length)
end        

function math.LerpAngle(a, b, t)
	local num = math.Repeat(b - a, 360)

	if num > 180 then
		num = num - 360
	end

	return a + num * clamp(t, 0, 1)
end

function math.MoveTowards(current, target, maxDelta)
	if abs(target - current) <= maxDelta then
		return target
	end

	return current + math.sign(target - current) * maxDelta
end

function math.DeltaAngle(current, target)
	local num = math.Repeat(target - current, 360)

	if num > 180 then
		num = num - 360
	end

	return num
end    

function math.MoveTowardsAngle(current, target, maxDelta)
	target = current + math.DeltaAngle(current, target)
	return math.MoveTowards(current, target, maxDelta)
end

function math.Approximately(a, b)
	return abs(b - a) < math.max(1e-6 * math.max(abs(a), abs(b)), 1.121039e-44)
end

function math.InverseLerp(from, to, value)
	if from < to then      
		if value < from then 
			return 0
		end

		if value > to then      
			return 1
		end

		value = value - from
		value = value/(to - from)
		return value
	end

	if from <= to then
		return 0
	end

	if value < to then
		return 1
	end

	if value > from then
        return 0
	end

	return 1.0 - ((value - to) / (from - to))
end

function math.PingPong(t, length)
    t = math.Repeat(t, length * 2)
    return length - abs(t - length)
end
 
math.deg2Rad = math.pi / 180
math.rad2Deg = 180 / math.pi
math.epsilon = 1.401298e-45

function math.Random(n, m)
	local range = m - n	
	return math.random() * range + n
end

function math.RandomWeightArray(weight_array)
	local total_weight = 0
	for _, weight in ipairs(weight_array) do
		total_weight = total_weight + weight
	end
	local wt = math.random(0, total_weight - 1)
	local idx = 0
	local array_len = #weight_array
	while wt >= 0 and idx < array_len do
		idx = idx + 1
		wt = wt - weight_array[idx]
	end
	return idx
end

-- isnan
function math.isnan(number)
	return not (number == number)
end

local PI = math.pi
local TWO_PI = 2 * math.pi
local HALF_PI = math.pi / 2 


function math.sin16(a) 
	local s

	if a < 0 or a >= TWO_PI then
		a = a - floor( a / TWO_PI ) * TWO_PI
	end

	if a < PI then
		if a > HALF_PI then
			a = PI - a
		end
	else 
		if a > PI + HALF_PI then
			a = a - TWO_PI
		else
			a = PI - a
		end
	end

	s = a * a
	return a * ( ( ( ( (-2.39e-8 * s + 2.7526e-6) * s - 1.98409e-4) * s + 8.3333315e-3) * s - 1.666666664e-1 ) * s + 1)
end


function math.atan16(a) 
	local s

	if abs( a ) > 1 then
		a = 1 / a
		s = a * a
		s = - ( ( ( ( ( ( ( ( ( 0.0028662257 * s - 0.0161657367 ) * s + 0.0429096138 ) * s - 0.0752896400 )
				* s + 0.1065626393 ) * s - 0.1420889944 ) * s + 0.1999355085 ) * s - 0.3333314528 ) * s ) + 1.0 ) * a
		if FLOATSIGNBITSET( a ) then
			return s - HALF_PI
		else 
			return s + HALF_PI
		end
	else 
		s = a * a
		return ( ( ( ( ( ( ( ( ( 0.0028662257 * s - 0.0161657367 ) * s + 0.0429096138 ) * s - 0.0752896400 )
			* s + 0.1065626393 ) * s - 0.1420889944 ) * s + 0.1999355085 ) * s - 0.3333314528 ) * s ) + 1 ) * a
	end
end

if not math.pow then
    math.pow = function (x, y)
        return x^y 
    end
end

function math.intpow(n, m)
	local ret = 1
	local i = 0
	while i < m do
		ret = ret * n
		i = i + 1
	end
	return ret
end

function math.shuffle(tb)
    local j
    for i=#tb, 2, -1 do
        j = math.random(1, i)
        tb[i], tb[j] = tb[j], tb[i]
    end
end
