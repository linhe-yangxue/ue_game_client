-- 注意，发送给服务的的数据是以2个字节的长度开头，限制长度以避免不断给服务器发大包，照成服务器拥塞
-- 而服务器发给客户端的数据是以3个字节的长度开头，即允许服务器发送最大16M的包给客户端，便于合包等优化处理

local ProtoType = require 'Sproto.ProtoType'

local SprotoLoader = require "Sproto.sprotoloader"
local SprotoCore = require "sproto.core"
local SprotoEnv = require "Sproto.SprotoMsgEnv"

local s2c_sp = SprotoLoader.load(SprotoEnv.PROTO_ID_S2C)
local s2c_host = s2c_sp:host(SprotoEnv.BASE_PACKAGE)
local c2s_sp = SprotoLoader.load(SprotoEnv.PROTO_ID_C2S)
local c2s_encode_func = s2c_host:attach(c2s_sp)
local msg_utils = class("Sproto.SprotoMsgUtils")

function msg_utils:DoInit()
    self.msg_session_callbacks = {}
    self.s2c_msg_handles = {}
end

-- funcs for send msg

function msg_utils:pack_size_head(str)
    local size = #str
    assert(size <= 65535)
    local a = size % 256
    size = math.floor(size / 256)
    local b = size % 256
    return (string.char(b) .. string.char(a)) .. str
end

function msg_utils:pack_c2s_msg(proto_name, data, session)
    local e_data = c2s_encode_func(proto_name, data, session)
    return self:pack_size_head(e_data)
end

function msg_utils:register_session_cb(proto_name, session, cb)
    if self.msg_session_callbacks[session] then
        print('register_session_cb, has already exist session:', session)
    end
    self.msg_session_callbacks[session] = {name = proto_name, cb = cb}
end


-- funcs for receive msg
function msg_utils:unpack_size_head(str)
    if #str < 3 then
        return
    end
    local b = string.byte(str)
    local a = string.byte(str, 2)
    local c = string.byte(str, 3)
    local size = b * 256 * 256 + a * 256 + c
    if size > #str - 3 then
        return
    end
    return size, string.sub(str, 4)
end

function msg_utils:swallow_msg_data(data_str)
    local size, ret_str = self:unpack_size_head(data_str)
    if not size then
        return
    end
    if size > #ret_str then
        return
    end
    local msg_data = string.sub(ret_str, 1, size)
    local ret_data_str = string.sub(ret_str, size + 1)
    return ret_data_str, msg_data
end

function msg_utils:load_funcs_from_file(file_name)
    local file_path = "Msg." .. file_name
    local chunck_data = require(file_path)
    local ret = {}
    ADD_MODULE_FUNCS(ret, chunck_data, function() self:register_msg_handles_from_file(file_name) end)
    return ret
end

function msg_utils:register_msg_handles_from_file(file_name)
    local handles = self:load_funcs_from_file(file_name)
    self:register_msg_handles(handles)
end

function msg_utils:register_msg_handles(handles)
    for k, v in pairs(handles) do
        self.s2c_msg_handles[k] = v
    end
end

function msg_utils:handle_s2c_msg(proto_name, args, resp_sender)
    local func = self.s2c_msg_handles[proto_name]
    if not func then
        error("proto name:" .. proto_name .. " no handles function")
    end

    print("handle_s2c_msg proto name:>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" .. proto_name,args)
    local ret = func(args)
    local tag, req, resp = SprotoCore.protocol(s2c_sp.__cobj, proto_name)  -- decide msg whether has response
    if resp and resp_sender then
        return resp_sender(ret)
    end
end

function msg_utils:handle_s2c_resp(session, resp)
    print("handle_s2c_resp:>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>",resp)
    local cb_info = self.msg_session_callbacks[session]
    self.msg_session_callbacks[session] = nil
    if cb_info and cb_info.cb then
        cb_info.cb(resp)
    end
end

function msg_utils:handle_msg(msg_type, ...)
    if msg_type == 'REQUEST' then
        return self:handle_s2c_msg(...)
    elseif msg_type == 'RESPONSE' then
        self:handle_s2c_resp(...)
    end
end

function msg_utils:dispatch_msg(msg)
    local size =  #msg
    local ret = self:handle_msg(s2c_host:dispatch(msg, size))
    if ret then
        return self.pack_size_head(ret)
    end
end

return msg_utils
