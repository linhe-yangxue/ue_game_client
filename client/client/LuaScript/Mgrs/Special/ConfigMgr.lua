local GConst = require("GlobalConst")
local ConfigMgr = class("Mgrs.Special.ConfigMgr")

local kNoConfigValue = "nil"

function ConfigMgr:DoInit()
    self.config_param_tb = {}
    for _, val in pairs(GConst.Config) do
        local param_type = self:_GetParamType(val)
        self.config_param_tb[val] = self:_GetValue(val, param_type)
    end
end

function ConfigMgr:GetValue(param)
    local param_type = self:_GetParamType(param)
    if param_type then
        local value = self.config_param_tb[param]
        if value == nil then
            value = self:_GetValue(param, param_type)
            self.config_param_tb[param] = value
        end
        return value
    end
    return nil
end

function ConfigMgr:SetValue(param, value)
    local param_type = self:_GetParamType(param)
    if param_type then
        if param_type == GConst.ConfigParamType.t_bool then
            value = value == true
        end
        self:_SetValue(param, value)
        self.config_param_tb[param] = value
    end
end

function ConfigMgr:_GetParamType(param)
    local param_type = tonumber(string.split(param, "_")[1])
    return param_type
end

function ConfigMgr:_GetValue(param, param_type)
    local value_str = PlayerPrefs.GetString(param, kNoConfigValue)
    if value_str == kNoConfigValue then
        return
    end
    if param_type == GConst.ConfigParamType.t_bool then
        return tonumber(value_str) == 1
    elseif param_type == GConst.ConfigParamType.t_int then
        local num = tonumber(value_str)
        return math.floor(num)
    elseif param_type == GConst.ConfigParamType.t_float then
        return tonumber(value_str)
    elseif param_type == GConst.ConfigParamType.t_string then
        return value_str
    end
end

function ConfigMgr:_SetValue(param, value)
    local value_str = value
    if value == kNoConfigValue then
        PrintError("config value can't be -->", kNoConfigValue, debug.traceback())
    end
    if type(value) == "boolean" then
        value_str = value and 1 or 0
    end
    value_str = tostring(value_str)
    PlayerPrefs.SetString(param, value_str)
end


function ConfigMgr:DoDestroy()
    for k, v in pairs(self.config_param_tb) do
        self:_SetValue(k, v)
    end
end

return ConfigMgr