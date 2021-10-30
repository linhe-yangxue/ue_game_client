local SprotoEnv = require("Sproto.SprotoMsgEnv")
local MsgChannel = require("Msg.MsgChannel")
local MsgConst = require("Msg.MsgConst")
local MsgMgr = class("Mgrs.Special.MsgMgr")
local UIConst = require("UI.UIConst")
MsgMgr.__index = function (self, key)
    local result = rawget(MsgMgr, key)
    if result then return result end
    local msg_channel = rawget(self, "msg_channel")
    if msg_channel then
        local func = msg_channel[key]
        if type(func) == "function" then
          return function(self, ...) return func(msg_channel, ...) end
        end
    end
end

function MsgMgr:DoInit()
    SprotoEnv:init(nil, self._SprotoMsgEnvInitOk, self)
    self._evt_to_cooling_time = {}
    self._remove_evt_list = {}
end

function MsgMgr:DoDestroy()
    if self.msg_channel then
        self.msg_channel:DoDestroy()
        self.msg_channel = nil
    end
end

function MsgMgr:Update(delta_time)
    if self.msg_channel then
        self.msg_channel:Update(delta_time)
    end
    if next(self._evt_to_cooling_time) then
        for evt, time in pairs(self._evt_to_cooling_time) do
            time = time - delta_time
            self._evt_to_cooling_time[evt] = time
            if time <= 0 then table.insert(self._remove_evt_list, evt) end
        end
        for _, evt in ipairs(self._remove_evt_list) do
            self._evt_to_cooling_time[evt] = nil
        end
        self._remove_evt_list = {}
    end
end

function MsgMgr:PreUpdate(delta_time)
    if self.msg_channel then
        self.msg_channel:PreUpdate(delta_time)
    end
end

function MsgMgr:_SprotoMsgEnvInitOk()
    local SP_Utils = require('Sproto.SprotoMsgUtils')
    self.sproto_utils = SP_Utils.New()
    self.sproto_utils:DoInit()
    self.sproto_utils:register_msg_handles_from_file("MsgHandle_Login")
    self.sproto_utils:register_msg_handles_from_file("MsgHandle_Role")
    self.sproto_utils:register_msg_handles_from_file("MsgHandle_Hero")
    self.sproto_utils:register_msg_handles_from_file("MsgHandle_Lover")
    self.sproto_utils:register_msg_handles_from_file("MsgHandle_Hunting")
    self.sproto_utils:register_msg_handles_from_file("MsgHandle_Bag")
    self.sproto_utils:register_msg_handles_from_file("MsgHandle_Stage")
    self.sproto_utils:register_msg_handles_from_file("MsgHandle_Arena")
    self.sproto_utils:register_msg_handles_from_file("MsgHandle_Treasure")
    self.sproto_utils:register_msg_handles_from_file("MsgHandle_Dynasty")
    self.sproto_utils:register_msg_handles_from_file("MsgHandle_Train")
    self.sproto_utils:register_msg_handles_from_file("MsgHandle_Mail")
    self.sproto_utils:register_msg_handles_from_file("MsgHandle_Welfare")
    self.sproto_utils:register_msg_handles_from_file("MsgHandle_Friend")
    self.sproto_utils:register_msg_handles_from_file("MsgHandle_Recharge")
    self.sproto_utils:register_msg_handles_from_file("MsgHandle_Traitor")
    self.sproto_utils:register_msg_handles_from_file("MsgHandle_Title")
    self.sproto_utils:register_msg_handles_from_file("MsgHandle_Activity")
    if self.msg_channel then
        self.msg_channel:SetSprotoUtils(self.sproto_utils)
    end
end

function MsgMgr:ConnectServer(ip, port, cb)
    self:DisconnectServer()
    self.msg_channel = MsgChannel.New()
    self.msg_channel:DoInit()
    self.msg_channel:SetSprotoUtils(self.sproto_utils)
    self.msg_channel:Connect(ip, port, cb)
end

function MsgMgr:DisconnectServer()
    if self.msg_channel then
        self.msg_channel:Disconnect()
        self.msg_channel = nil
    end
end

function MsgMgr:IsConnected()
    return self.msg_channel and self.msg_channel:IsConnected()
end

-- 带有冷却时间检测 和 统一报错格式
function MsgMgr:SendMsg(evt_name, data, cb)
    if self._evt_to_cooling_time[evt_name] then return end
    self._evt_to_cooling_time[evt_name] = MsgConst.CoolTimeDict[evt_name] or MsgConst.DefaultCoolTime
    local send_cb = function (resp)
        self._evt_to_cooling_time[evt_name] = nil
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.CONNECT_SERVER_WRONG)
            PrintError("Get wrong errcode from serv in " .. evt_name, data)
        end
        if cb then
            cb(resp)
        end
    end
    self[evt_name](self, data, send_cb)
end

return MsgMgr