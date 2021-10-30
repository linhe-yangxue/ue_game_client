Rect = {
	__typename = "Rect",  -- 注意__typename是C#中识别类型的凭证
}
local fields = {}

setmetatable(Rect, Rect)

Rect.__index = function(t,k)
	if k == "size" then
		return Vector2(t.width, t.height)
	else
		local var = rawget(Rect, k)
		if var == nil then
			var = rawget(fields, k)
			if var ~= nil then
				return var(t)
			end
		end
		return var
	end
end


Rect.__call = function(t,x,y,width, height)
	return Rect.New(x,y,width, height)
end

function Rect.NewByTable(t)
	return Rect.New(t[1] or 0, t[2] or 0, t[3] or 0, t[4] or 0)
end

function Rect.NewByRect(t)
	return Rect.New(t.x or 0, t.y or 0, t.width or 0, t.height or 0)
end

function Rect.New(x, y, width, height)
    local rect = {x = x, y = y, width = width, height = height}
	setmetatable(rect, Rect)
	return rect
end

function Rect:Equals(other)
	return self.x == other.x and self.y == other.y and self.width == other.width and self.height == other.height
end

function Rect:Position()
    return Vector2.New(self.x, self.y)
end

function Rect:Size()
    return Vector2.New(self.width, self.height)
end

function Rect:Center()
    return Vector2.New(self.x + self.width / 2, self.y + self.height / 2)
end


Rect.__tostring = function(self)
	return string.format("[%.2f,%.2f,%.2f,%.2f]", self.x, self.y, self.width, self.height)
end

Rect.__eq = function(a, b)
	return a.x == b.x and
        a.y == b.y and
        a.width == b.width and
        a.height == b.height 
end

fields.position    = Rect.Position
fields.size   = Rect.Size
fields.center   = Rect.Center

