Color = 
{
	r = 0,
	g = 0,
	b = 0,
	a = 0,
	__typename = "Color",  -- 注意__typename是C#中识别类型的凭证
}

setmetatable(Color, Color)

local fields = {}

Color.__index = function(t,k)
	local var = rawget(Color, k)
		
	if var == nil then							
		var = rawget(fields, k)
		
		if var ~= nil then
			return var(t)	
		end
	end
	
	return var
end

function Color.New(r, g, b, a)
	local v = {r = 0, g = 0, b = 0, a = 0}
	v.r = r
	v.g = g
	v.b = b
	v.a = a or 1
	setmetatable(v, Color)
	return v
end

function Color:Set(r, g, b, a)
	self.r = r
	self.g = g
	self.b = b
	self.a = a or 1 
end

function Color.NewByTable(t)
	return Color.New(t[1] or 1, t[2] or 1, t[3] or 1, t[4] or 1)
end

function Color:Get()
	return self.r, self.g, self.b, self.a
end

function Color:Equals(other)
	return self.r == other.r and self.g == other.g and self.b == other.b and self.a == other.a
end

function Color.Lerp(a, b, t)
	t = math.clamp(t, 0, 1)
	return Color.New(a.r + t * (b.r - a.r), a.g + t * (b.g - a.g), a.b + t * (b.b - a.b), a.a + t * (b.a - a.a))
end

function Color.GrayScale(a)
	return 0.299 * a.r + 0.587 * a.g + 0.114 * a.b
end

function Color.NewByColor(c)
	return Color.New(c.r, c.g, c.b, c.a)
end

function Color.HSVToRGB(h, s, v, is_hdr)
	local white = Color.white
	if s == 0 then
		white.r = v
		white.g = v
		white.b = v
	elseif v == 0 then
		white.r = 0;
		white.g = 0;
		white.b = 0;
	else
		white.r = 0;
		white.g = 0;
		white.b = 0;
		local num = h * 6;
		local num2 = math.floor(num)
		local num3 = num - num2
		local num4 = v * (1 - s)
		local num5 = v * (1 - s * num3)
		local num6 = v * (1 - s * (1 - num3))
		local val = num2 + 1
		if val == 0 then
			white.r = v
			white.g = num4
			white.b = num5
		elseif val == 1 then
			white.r = v
			white.g = num6
			white.b = num4
		elseif val == 2 then
			white.r = num5
			white.g = v
			white.b = num4
		elseif val == 3 then
			white.r = num4
			white.g = v
			white.b = num6
		elseif val == 4 then
			white.r = num4
			white.g = num5
			white.b = v
		elseif val == 5 then
			white.r = num6
			white.g = num4
			white.b = v
		elseif val == 6 then
			white.r = v
			white.g = num4
			white.b = num5
		elseif val == 7 then
			white.r = v
			white.g = num6
			white.b = num4
		end
		if not is_hdr then
			white.r = math.clamp(white.r, 0, 1);
			white.g = math.clamp(white.g, 0, 1);
			white.b = math.clamp(white.b, 0, 1);
		end
	end
	return white
end

function Color.RGBToHSV(color)
	local h, s, v
	if color.b > color.g and color.b > color.r then
		h, s, v = Color._RGBToHSV(4, color.b, color.r, color.g);
	elseif color.g > color.r then
		h, s, v = Color._RGBToHSV(2, color.g, color.b, color.r);
	else
		h, s, v = Color._RGBToHSV(0, color.r, color.g, color.b);
	end
	return Color.New(h, s, v, color.a)
end

function Color._RGBToHSV(offset, dominantcolor, colorone, colortwo)
	local h, s, v
	v = dominantcolor
	if v ~= 0 then
		local num
		if colorone > colortwo then
			num = colortwo
		else
			num = colorone
		end
		local num2 = v - num
		if num2 ~= 0 then
			s = num2 / v
			h = offset + (colorone - colortwo) / num2
		else
			s = 0
			h = offset + colorone - colortwo
		end
		h = h / 6
		if h < 0 then
			h = h + 1
		end
	else
		s = 0
		h = 0
	end
	return h, s, v
end

Color.__tostring = function(self)
	return string.format("RGBA(%f,%f,%f,%f)", self.r, self.g, self.b, self.a)
end

Color.__add = function(a, b)
	return Color.New(a.r + b.r, a.g + b.g, a.b + b.b, a.a + b.a)
end

Color.__sub = function(a, b)	
	return Color.New(a.r - b.r, a.g - b.g, a.b - b.b, a.a - b.a)
end

Color.__mul = function(a, b)
	if type(b) == "number" then
		return Color.New(a.r * b, a.g * b, a.b * b, a.a * b)
	elseif b.__typename == Color.__typename then
		return Color.New(a.r * b.r, a.g * b.g, a.b * b.b, a.a * b.a)
	end
end

Color.__div = function(a, d)
	return Color.New(a.r / d, a.g / d, a.b / d, a.a / d)
end

Color.__eq = function(a,b)
	return a.r == b.r and a.g == b.g and a.b == b.b and a.a == b.a
end

fields.red 		= function() return Color.New(1,0,0,1) end
fields.green	= function() return Color.New(0,1,0,1) end
fields.blue		= function() return Color.New(0,0,1,1) end
fields.white	= function() return Color.New(1,1,1,1) end
fields.black	= function() return Color.New(0,0,0,1) end
fields.yellow	= function() return Color.New(1, 0.9215686, 0.01568628, 1) end
fields.cyan		= function() return Color.New(0,1,1,1) end
fields.magenta	= function() return Color.New(1,0,1,1) end
fields.gray		= function() return Color.New(0.5,0.5,0.5,1) end
fields.clear	= function() return Color.New(0,0,0,0) end

fields.grayscale = Color.GrayScale
