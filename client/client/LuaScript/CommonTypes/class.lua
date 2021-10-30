
function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

--Create an class.
function class(class_name, super)
    local superType = type(super)
    local cls

    if super and superType ~= "table" then
        PrintError("Can't declare super type:", superType, "class_name", class_name)
        return
    end

    cls = package.loaded[class_name]
    if type(cls) == "userdata" or not cls then
        cls = {}
        if super then
            cls.super = super
            setmetatable(cls, super)
        end
        cls.__cname = class_name
        cls.__ctype = 2 -- lua
        cls.__index = cls
        cls.__RELOAD_FLAG = true
        cls.__RELOAD_RUNNING_ATTR_NAMES = {}
        cls.__RELOADING = nil
        cls.__RELOAD_AFTER = nil
        cls.__RELOAD_MOD_NAME  = class_name
        cls.ClassName = function() return cls.__cname end

        function cls.New()
            local instance = setmetatable({}, cls)
            instance.class = cls
            return instance
        end
    end

    return cls
end

function DECLARE_CLASS(container, name)
    local cls = container[name]
    if not cls then
        cls = {}
        cls.__index = cls
        cls.__RELOAD_RUNNING_ATTR_NAMES = {}
        cls.__RELOAD_FLAG = true
        container[name] = cls

        function cls.New()
            local instance = setmetatable({}, cls)
            instance.class = cls
            return instance
        end
    end
    return cls
end

function ADD_MODULE_FUNCS(mod_parent, mod, reload_after_func)
    mod.__RELOAD_AFTER = nil
    for key, value in pairs(mod) do
        if (type(key) ~= "string" or string.sub(key, 1, 2) ~= "__") then
            if mod_parent[key] and not mod_parent.__RELOADING and not mod.__RELOADING then
                PrintError("Double Add Module Key", key, mod_parent.__RELOAD_MOD_NAME, mod.__RELOAD_MOD_NAME)
            end
            mod_parent[key] = value
        end
    end
    mod.__RELOAD_AFTER = reload_after_func or function()
        ADD_MODULE_FUNCS(mod_parent, mod)
    end
end

function DECLARE_MODULE(mod_name, mod_creator)
    local mod = package.loaded[mod_name]
    if type(mod) == "userdata" or not mod then
        if mod_creator then
            mod = mod_creator()
        else
            mod = {}
        end
        mod.__RELOAD_FLAG = true
        mod.__RELOAD_RUNNING_ATTR_NAMES = {}
        mod.__RELOAD_MOD_NAME = mod_name
        mod.__RELOADING = nil
        mod.__RELOAD_AFTER = nil
        mod.__index = mod
    end
    return mod
end

function DECLARE_RUNNING_ATTR(container, name, init_value)
    if not container.__RELOAD_RUNNING_ATTR_NAMES[name] then
        container.__RELOAD_RUNNING_ATTR_NAMES[name] = 1
        container[name] = init_value
    end
end
