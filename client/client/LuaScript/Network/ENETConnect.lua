local Enet = require("enet")
local GConst = require "GlobalConst"

local ENETConnect = class("BaseUtilities.ENETConnect")

function ENETConnect:DoInit(error_cb)
    self._status = GConst.ConnectStatus.STATUS_Init
    self.error_cb = error_cb
    self.connect_cb = nil
    return self
end

function ENETConnect:DoDestroy()
    self:Disconnect()
    self._status = GConst.ConnectStatus.STATUS_Closed
    self.conn = nil
    self.host = nil
end

function ENETConnect:Connect(ip, port, cb, timeout)
    print("ENETConnect:Connect", ip, port, cb, timeout)
    self:Disconnect()

    self.connect_time_out = timeout or GConst.CONNECT_TimeOutSecond
    self._status = GConst.ConnectStatus.STATUS_BeginConnect
    self.connect_cb = cb

    self.host = assert(Enet.host_create())
    local host_address = string.format("%s:%s", ip, port)
    self.conn = self.host:connect(host_address, 1)
    self.conn:timeout(512, 300000, 300000)
end

function ENETConnect:Disconnect()
    if self:IsConnected() and self.conn then
        print("ENETConnect:Disconnect")
        self.conn:disconnect_now()
        self.conn = nil
        self._status = GConst.ConnectStatus.STATUS_Disconnected
        if self.host then
            self.host:destroy()
            self.host = nil
        end
    end
end

function ENETConnect:IsConnected()
    return self._status == GConst.ConnectStatus.STATUS_Connected
end

function ENETConnect:Update(delta_time)
    if self._status == GConst.ConnectStatus.STATUS_BeginConnect then
        self.connect_time_out = self.connect_time_out - delta_time
        if self.connect_time_out <= 0 then
            self:_OnConnectFailed(GConst.NetFailed.ENET_Connect_Timeout, "Enet ConnectToServer time out!")
            return
        end
        local ret, event = pcall(self.host.service, self.host)
        if not ret then
            print("ENETConnect error msg:", ret, event)
            return
        end
        if event and event.type == 'connect' then
            self:_OnConnect()
        end
    end
end

function ENETConnect:TryReceive()
    if not self:IsConnected() then
        return nil
    end
    local ret, event = pcall(self.host.service, self.host)
    if not ret then
        print("ENETConnect error msg:", ret, event)
        return
    end
    if event then
        if event.type == 'receive' then
            return event.data
        elseif event.type == 'disconnect' then
            self:_OnConnectFailed(GConst.NetFailed.ENET_Receive_Disconnect, "Enet ConnectToServer receive disconneced!")
        end
    end
end

function ENETConnect:Send(msg_bytes)
    if not self:IsConnected() then
        return
    end
    self.conn:send(msg_bytes, 0)
    self.host:flush()
end

function ENETConnect:_OnConnect()
    print("ENETConnect:_OnConnect")
    -- self:send({ty=const.TEAM_BTL_SUB_TYPE.hello_world})
    self._status = GConst.ConnectStatus.STATUS_Connected
    if self.connect_cb then
        self.connect_cb()
        self.connect_cb = nil
    end
end

function ENETConnect:_OnDisconnect(err)
    PrintWarn("ENETConnect:_OnDisconnect", err)
    self._status = GConst.ConnectStatus.STATUS_Disconnected
    if self.error_cb then
        self.error_cb(GConst.NetFailed.TCP_Receive_Disconnect, err)
    end
end

function ENETConnect:_OnConnectFailed(faild_type, err)
    PrintWarn("ENETConnect:_OnConnectFailed", err)
    self._status = GConst.ConnectStatus.STATUS_Failed
    if self.error_cb then
        self.error_cb(faild_type, err)
    end
end


return ENETConnect