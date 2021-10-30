
Object          = UnityEngine.Object
GameObject 		= UnityEngine.GameObject
Transform 		= UnityEngine.Transform
Application		= UnityEngine.Application
Screen			= UnityEngine.Screen
Camera			= UnityEngine.Camera
Material 		= UnityEngine.Material
Renderer 		= UnityEngine.Renderer
AsyncOperation	= UnityEngine.AsyncOperation

Animation		= UnityEngine.Animation
AnimationClip	= UnityEngine.AnimationClip
AnimationEvent	= UnityEngine.AnimationEvent
AnimationState	= UnityEngine.AnimationState
Input			= UnityEngine.Input
KeyCode			= UnityEngine.KeyCode
AudioClip		= UnityEngine.AudioClip
AudioSource		= UnityEngine.AudioSource
Physics			= UnityEngine.Physics
Space			= UnityEngine.Space
CameraClearFlags= UnityEngine.CameraClearFlags
RenderSettings  = UnityEngine.RenderSettings
WrapMode		= UnityEngine.WrapMode
QueueMode		= UnityEngine.QueueMode
PlayMode		= UnityEngine.PlayMode
TouchPhase 		= UnityEngine.TouchPhase
AnimationBlendMode = UnityEngine.AnimationBlendMode
Profiler		= UnityEngine.Profiling.Profiler
PlayerPrefs		= UnityEngine.PlayerPrefs
Canvas   = UnityEngine.Canvas

require "CommonTypes.class"
require "CommonTypes.Math"
require "CommonTypes.Layer"
require "CommonTypes.Time"

require "CommonTypes.Vector3"
require "CommonTypes.Vector2"
require "CommonTypes.Quaternion"
require "CommonTypes.Vector4"
require "CommonTypes.Rect"
require "CommonTypes.Color"
require "CommonTypes.Plane"
require "CommonTypes.Bounds"
require "CommonTypes.UTF8"
require "CommonTypes.Queue"

require "CommonTypes.Coroutine"
require "CommonTypes.BlendAnim"

json = require "CommonTypes.dkjson"
tween = require "CommonTypes.tween"

-- 用途类似c的struct，主要用于传参数，
-- key_list是合法的key列表
function STRUCT(container, name, key_list)
    local st = container["__STRUCT__" .. name]
    if not st then
        st = {key_dict={}, meta={}}
        container["__STRUCT__" .. name] = st
    end
    local key_dict = st.key_dict
    local meta = st.meta
    for i, v in ipairs(key_list) do
        key_dict[v] = true
    end
    meta.__index = function(t, key)
        if not key_dict[key] then
            error("read struct key error:" .. key .. " from " .. name)
        end
    end
    meta.__newindex = function(t, key, value)
        if not key_dict[key] then
            error("write struct key error:" .. key .. " from " .. name)
        end
        rawset(t, key, value)
    end
    return function(init_kvs)
        if getmetatable(init_kvs) == meta then
            return init_kvs
        end
        local self = {}
        setmetatable(self, meta)
        if init_kvs then
            for k,v in pairs(init_kvs) do
                self[k] = v
            end
        end
        return self
    end
end

CSConst = require("CSCommon.CSConst")
local data_mgr = require("CSCommon.data_mgr")
data_mgr.IS_CLIENT = true

local function _tb2str(root)
    local cache = {[root] = "."}
    local function _dump(t, space, name)
        local temp = {}
        for k, v in pairs(t) do
            local key = tostring(k)
            if cache[v] then
                table.insert(temp,"+" .. key .. " {" .. cache[v].."}")
            elseif type(v) == "table" then
                local new_key = name .. "." .. key
                cache[v] = new_key
                table.insert(temp,"+" .. key .. ":\n" .. _dump(v, space .. (next(t,k) and "|" or " " ).. string.rep(" ",#key), new_key))
            else
                table.insert(temp,"+" .. key .. " [" .. tostring(v).."]")
            end
        end
        return space .. table.concat(temp,"\n"..space)
    end
    return (_dump(root, "",""))
end

local function _param2str(...)
    local n = select("#", ...)
    local out = {}
    local v_str
    for i=1, n do
        local v = select(i,...)
        if type(v) == "table" then
            if getmetatable(v) and getmetatable(v).__tostring then
                v_str = tostring(v)
            else
                v_str = "table:\n" .. _tb2str(v)
            end
        else
            v_str = tostring(v)
        end

        table.insert(out, v_str)
    end
    return table.concat(out, " ")
end

local log_cache = {}  -- 所有log延迟输出到unity，防止crash

function print(...)
    table.insert(log_cache, {"log", _param2str(...)})
end

function printf(format, ...)
    table.insert(log_cache, {"log", string.format(format, ...)})
end

function PrintError(...)
    table.insert(log_cache, {"error", _param2str(...) .. "\n" .. debug.traceback()})
end

function PrintWarn(...)
    table.insert(log_cache, {"warn", _param2str(...)})
end

function FlushLog()
    if #log_cache > 0 then
        for _, log in ipairs(log_cache) do
            if log[1] == "log" then
                Debugger.Log(log[2])
            elseif log[1] == "warn" then
                Debugger.LogWarning(log[2])
            else
                Debugger.LogError(log[2])
            end
        end
        log_cache = {}
    end
end

function ServerError(...)
end

function ServerWarn(...)
end

loadstring = load

function LoadLua(lua_str, env_tb)
  local ret, msg = load(lua_str, nil, nil, env_tb)
  return ret, msg
end

function traceback(msg)
	msg = debug.traceback(msg, 2)
	return msg
end

function LuaGC()
  local c = collectgarbage("count")
  Debugger.Log("Begin gc count = {0} kb", c)
  collectgarbage("collect")
  c = collectgarbage("count")
  Debugger.Log("End gc count = {0} kb", c)
end

function RemoveTableItem(list, item, removeAll)
    local rmCount = 0

    for i = 1, #list do
        if list[i - rmCount] == item then
            table.remove(list, i - rmCount)

            if removeAll then
                rmCount = rmCount + 1
            else
                break
            end
        end
    end
end

function IsTableEmpty(tb)
    local key = next(tb)
    return key == nil or key == "__parent"
end

--unity 对象判断为空, 如果你有些对象是在c#删掉了，lua 不知道
--判断这种对象为空时可以用下面这个函数。
function IsNil(uobj)
	return uobj == nil or uobj:Equals(nil)
end

-- isnan
function IsNan(number)
	return not (number == number)
end

function string:split(sep)
	local sep, fields = sep or ",", {}
	local pattern = string.format("([^%s]+)", sep)
	self:gsub(pattern, function(c) table.insert(fields, c) end)
	return fields
end

function string:hex()
    local str = self
    str = string.gsub(str,"(.)",function (x) return string.format("%02X ",string.byte(x)) end)
    return str
end

-- 示例:string.render('some words:{cde}, some value:{abc}', {abc=123, cde='hello'})
function string.render(s, args)
    local pos = 1
    local ret = {}
    while true do
        local idx_start, idx_end = string.find(s, '%b{}', pos)
        if idx_start then
            table.insert(ret, string.sub(s, pos, idx_start-1))
            local name = string.sub(s, idx_start+1, idx_end-1)
            if args[name] == nil then
                error("string.render error, no args:" .. name)
            end
            table.insert(ret, string.format('%s', args[name]))
            pos = idx_end + 1
        else
            table.insert(ret, string.sub(s, pos))
            break
        end
    end
    return table.concat(ret, "")
end

function GetDir(path)
	return string.match(fullpath, ".*/")
end

function GetFileName(path)
	return string.match(fullpath, ".*/(.*)")
end

-- 文件操作 ---------------------------------------------

function IsFileExists(file_name)
    return NativeAppUtils.IsFileExists(file_name)
end

function ReadFile(file_name)
    return NativeAppUtils.ReadFile(file_name)
end

function ReadBinaryFile(file_name)
    return NativeAppUtils.ReadFile(file_name)
end

function WriteFile(file_name, content)
    return NativeAppUtils.WriteFile(file_name, content)
end

function WriteBinaryFile(file_name, content)
    return NativeAppUtils.WriteBinaryFile(file_name, content)
end

function DeleteFile(file_name)
    return NativeAppUtils.DeleteFile(file_name)
end

function MoveFile(file_name, new_file_name)
    return NativeAppUtils.MoveFile(file_name, new_file_name)
end

function CopyFile(file_name, new_file_name)
    return NativeAppUtils.CopyFile(file_name, new_file_name)
end

-- 目录操作 ---------------------------------------------
function IsDirectoryExists(path)
    return NativeAppUtils.IsDirectoryExists(path)
end

function CreateDirectory(path)
    return NativeAppUtils.CreateDirectory(path)
end

function DeleteDirectory(path)
    return NativeAppUtils.DeleteDirectory(path)
end

function GetFiles(path)
    return NativeAppUtils.GetFiles(path)
end

function GetDirectories(path)
    return NativeAppUtils.GetDirectories(path)
end


-- 加密相关 ---------------------------------------------
function MD5(str)
    return NativeAppUtils.MD5(str)
end

function BinaryMD5(str)
    return NativeAppUtils.BinaryMD5(str)
end

function MD5File(path)
    return NativeAppUtils.MD5File(path)
end

function BinaryMD5File(path)
    return NativeAppUtils.BinaryMD5File(path)
end

function Base64Encode(str)
    return NativeAppUtils.Base64Encode(str)
end

function Base64Decode(str)
    return NativeAppUtils.Base64Decode(str)
end

-- 时间戳 浮点数，精度比较高---------------------------------------
function GetTimeStamp()
    return NativeAppUtils.GetTimeStamp()
end

-- table ---------------------------------------------

if table.pack == nil then
  function table.pack(...)
    local ret = {...}
    ret.n = select("#", ...)
    return ret
  end

  function table.unpack(tb, i, j)
    return unpack(tb, i, j)
  end
end

if table.maxn == nil then
  function table.maxn(t)
    local max = 0
    for k, v in pairs(t) do
        if k > max then max = k end
    end
    return max
  end
end

function table.contains(table, element)
  if table == nil then
        return false
  end

  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function table.getCount(self)
	local count = 0
	
	for k, v in pairs(self) do
		count = count + 1	
	end
	
	return count
end

function table.keys(self)
    local ret = {}
    for k, v in pairs(self) do
        table.insert(ret, k)
    end
    return ret
end

function table.values(self)
    local ret = {}
    for k, v in pairs(self) do
        table.insert(ret, v)
    end
    return ret
end

function table.index(a, value)
    for k,v in ipairs(a) do
        if v==value then return k end
    end
end

function table.delete(list, element)
  if list == nil then
      return nil
  end

  for i, value in ipairs(list) do
    if value == element then
      table.remove(list, i)
      return element
    end
  end
  return nil
end

-- 冒泡排序，稳定
-- 执行方法func后返回 false 时进行交换
--  如：table.bubblesort(table, function(a, b)
--      return a.count <= b.count
--      end)
-- 则是将count由小到大排序，注意比较大小时不要漏掉等于号，否则相等时也进行排序，则排序不稳定
function table.bubblesort(table, func)
  local count = #table
  if func then
    for i = 1, count - 1 do
      for j = 1, count - i do
        if not func(table[j], table[j + 1]) then
          table[j], table[j + 1] = table[j + 1], table[j]
        end
      end
    end
  else
    for i = 1, count - 1 do
      for j = 1, count - i do
        if table[j] > table[j + 1] then
          table[j], table[j + 1] = table[j + 1], table[j]
        end
      end
    end
  end
end

--  求和
function table.sum(table)
    local ret = 0
    for k,v in pairs(table) do
        ret = ret + v
    end
    return ret
end

--  合并list
function table.mergeList(list1, list2)
    for i,v in ipairs(list2) do
        table.insert(list1, v)
    end
end

-- 合并值为num的dict
function table.mergeNumDict(dict1, dict2)
    for k, v in pairs(dict2) do
        dict1[k] = (dict1[k] or 0) + v
    end
end

function table.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[table.deepcopy(orig_key)] = table.deepcopy(orig_value)
        end
        setmetatable(copy, table.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function table.shallowcopy(source)
    local ret = {}
    if type(source) == 'table' then
        for k, v in pairs(source) do
            ret[k] = v
        end
    else
        ret = source
    end
    return ret
end

function DumpTable(t)
	for k,v in pairs(t) do
		if v ~= nil then
			Debugger.Log("Key: {0}, Value: {1}", tostring(k), tostring(v))
		else
			Debugger.Log("Key: {0}, Value nil", tostring(k))
		end
	end
end

 function PrintTable(tab)
    local str = {}

    local function internal(tab, str, indent)
        for k,v in pairs(tab) do
            if type(v) == "table" then
                table.insert(str, indent..tostring(k)..":\n")
                internal(v, str, indent..' ')
            else
                table.insert(str, indent..tostring(k)..": "..tostring(v).."\n")
            end
        end
    end

    internal(tab, str, '')
    return table.concat(str, '')
end

function PrintLua(name, lib)
	local m
	lib = lib or _G

	for w in string.gmatch(name, "%w+") do
       lib = lib[w]
     end

	 m = lib

	if (m == nil) then
		Debugger.Log("Lua Module {0} not exists", name)
		return
	end

	Debugger.Log("-----------------Dump Table {0}-----------------",name)
	if (type(m) == "table") then
		for k,v in pairs(m) do
			Debugger.Log("Key: {0}, Value: {1}", k, tostring(v))
		end
	end

	local meta = getmetatable(m)
	Debugger.Log("-----------------Dump meta {0}-----------------",name)

	while meta ~= nil and meta ~= m do
		for k,v in pairs(meta) do
			if k ~= nil then
			Debugger.Log("Key: {0}, Value: {1}", tostring(k), tostring(v))
			end

		end

		meta = getmetatable(meta)
	end

	Debugger.Log("-----------------Dump meta Over-----------------")
	Debugger.Log("-----------------Dump Table Over-----------------")
end


---- translation begin ----
langlua = {}
langui = {}
langexcel = {}
setmetatable(langlua, {__index = function(_, key) return key end})
setmetatable(langui, {__index = function(_, key) return key end})
setmetatable(langexcel, {__index = function(_, key) return key end})

function SetLanguage(language)
    language = language or "chs"
    local all_data = data_mgr:GetAllTranslationData()
    for k,v in pairs(all_data.lua) do
        local trans = v[language]
        if trans and trans ~= "" then
            langlua[k] = trans
        else
            langlua[k] = k
        end
    end
    for k,v in pairs(all_data.ui) do
        local trans = v[language]
        if trans and trans ~= "" then
            langui[k] = trans
        else
            langui[k] = k
        end
    end
    for k,v in pairs(all_data.excel) do
        local trans = v[language]
        if trans and trans ~= "" then
            langexcel[k] = trans
        else
            langexcel[k] = k
        end
    end
end
---- translation end ----

--检查是否有敏感词
function CheckHasBadWord(str)
    return data_mgr:CheckHasBadWord(str)
end

--过滤敏感词
function FilterBadWord(str)
    return data_mgr:FilterBadWord(str)
end