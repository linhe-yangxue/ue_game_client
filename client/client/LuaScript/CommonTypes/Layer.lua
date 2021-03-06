
Layer = 
{
	["Default"]			= 0,
	["TransparentFX"] 	= 1,
	["Ignore Raycast"] 	= 2,
	
	["Water"] 			= 4,
	["UI"] 				= 5,
}

for i = 0, 31 do
    local str = UnityEngine.LayerMask.LayerToName(i);
    if str and str ~= "" then
        Layer[str] = i;
    end
end

LayerMask = 
{
	value = 0,
}

setmetatable(LayerMask, LayerMask)

LayerMask.__call = function(t,v)
	return LayerMask.New(v)
end

function LayerMask.New(value)
	local layer = {value = 0}
	layer.value = value and value or 0
	setmetatable(layer, LayerMask)	
	return layer
end

function LayerMask.NameToLayer(name)
	return Layer[name]
end

function LayerMask.MultiLayer(...)
	local arg = {...}
	local value = 0	

	for i = 1, #arg do		
		value = value + (1 << LayerMask.NameToLayer(arg[i]))
	end	
		
	return value
end



