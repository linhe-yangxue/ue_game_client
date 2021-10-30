local GConst = require "GlobalConst"

local TCPConnect = class("Network.TCPConnect")

local mock_net_delay = 0

function TCPConnect:DoInit(error_cb)
    self._status = GConst.ConnectStatus.STATUS_Init
    self.error_cb = error_cb
    self.connect_cb = nil

    self.total_recv_size = 0
    self.total_send_size = 0
    self.raw_recv_size = 0
    self.raw_send_size = 0
    self.send_msg_count = 0
    self.recv_msg_count = 0
    self.print_ts = Time:GetTime()

    -- 模拟网络波动
    self.delay_send_list = {}
    self.delay_recv_list = {}
    return self
end

function TCPConnect:DoDestroy()
    if self:IsConnected() and self.conn then
        self.conn:close()
    end
    if self.ssl then
        self.ssl:Destroy()
        self.ssl = nil
    end
    self._status = GConst.ConnectStatus.STATUS_Closed
    self.conn = nil
end

function TCPConnect:AddRecvMsgCount(count)
    self.recv_msg_count = self.recv_msg_count + count
end

function TCPConnect:Connect(ip, port, cb, timeout)
    print("TCPConnect:Connect", ip, port, cb, timeout)
    print("TCPConnect:Connect", cb)
    self:Disconnect()

    self.connect_cb = cb
    self.connect_time_out = timeout or GConst.CONNECT_TimeOutSecond
    self._status = GConst.ConnectStatus.STATUS_BeginConnect

    if false then
        self.ssl = MockSsl()
        self.ssl:Init("targetName")
    end

    self.socket = require("Network.socket")
    self.conn = self.socket.tcp()
    self.conn:setoption('tcp-nodelay', true)
    self.conn:settimeout(0)
    local ret, msg = self.conn:connect(ip, port)
    print("TCPConnect:Connect", ip, port)
    print("获取点击次数333", ret,msg)
    if ret == 1 then
        self._status = GConst.ConnectStatus.STATUS_Connected
        print("获取点击次数", self._status)
        self:_OnConnect()
    elseif msg ~= "timeout" then
        print("获取点击次数111", self._status)
        self:_OnConnectFailed(GConst.NetFailed.TCP_Connect_Failed, "Connect2Server Failed:" .. msg)
    end
end

function TCPConnect:Disconnect()
    self._status = GConst.ConnectStatus.STATUS_Disconnected
    if self.conn then
        print("TCPConnect:Disconnect")
        self.conn:close()
    end
    if self.ssl then
        self.ssl:Destroy()
        self.ssl = nil
    end
end

function TCPConnect:IsConnected()
    return self._status == GConst.ConnectStatus.STATUS_Connected
end

function TCPConnect:PreUpdate(delta_time)
    if self.ssl then
        if self:IsConnected() then
            self:__recv()
            -- 可能失败导致close
        end
    end

    if self.ssl then
        self.ssl:Update()

        if self:IsConnected() then
            local data = self.ssl:MockServerRecv()
            if data and data ~= "" then
                self:__send(data)
            end
        end
    end
end

function TCPConnect:Update(delta_time)
    if self._status == GConst.ConnectStatus.STATUS_BeginConnect then
        self.connect_time_out = self.connect_time_out - delta_time
        if self.connect_time_out <= 0 then
            self:_OnConnectFailed(GConst.NetFailed.TCP_Connect_Timeout, "Connect time out!")
        end
        local r_fds, w_fds, err = self.socket.select(nil, {self.conn}, 0)
        if not err then
            self._status = GConst.ConnectStatus.STATUS_Connected
            self:_OnConnect()
        elseif err ~= "timeout" then
            self:_OnConnectFailed(GConst.NetFailed.TCP_Connect_Failed, "Connect2Server Failed:" .. err)
        end
    end
    if mock_net_delay > 0 then
        while true do
            local info = self.delay_send_list[1]
            if not info or info.ts + mock_net_delay > Time:GetTime() then
                break
            end
            table.remove(self.delay_send_list, 1)
            self:_send(info.msg_bytes)
        end
    end
    if Time:GetTime() >= 60 + self.print_ts then
        self.print_ts = Time:GetTime()
        print(string.format('ssl_recv:%d, raw_recv:%d, recv_msg_count:%d, ssl_send:%d, raw_send:%d, send_msg_count:%d', 
            math.floor(self.total_recv_size / 60), 
            math.floor(self.raw_recv_size / 60), 
            math.floor(self.recv_msg_count / 60), 
            math.floor(self.total_send_size / 60), 
            math.floor(self.raw_send_size / 60), 
            math.floor(self.send_msg_count / 60)
            ))
        self.total_recv_size = 0
        self.total_send_size = 0
        self.raw_recv_size = 0
        self.raw_send_size = 0
        self.recv_msg_count = 0
        self.send_msg_count = 0
    end
end

function TCPConnect:__recv()
    local ret, err, partial = self.conn:receive("*a")
    local data = ret or partial
    if data == "" then
        data = nil
    end
    if data and self.ssl then
        self.ssl:MockServerSend(data)
    end
    if data then
        self.total_recv_size = self.total_recv_size + string.len(data)
    end
    
    if not ret and err ~= "timeout" then
        self:_OnDisconnect("TryReceive:" .. err)
    end
    return data
end

function TCPConnect:TryReceive()
    if not self:IsConnected() then
        return nil
    end
    local data = self:__recv()
    if self.ssl then
        data = self.ssl:Recv()
    end
    if data then
        self.raw_recv_size = self.raw_recv_size + string.len(data)
    end

    if mock_net_delay > 0 then
        if data then
            table.insert(self.delay_recv_list, {data=data, ts=Time:GetTime()})
        end
        local info = self.delay_recv_list[1]
        if not info or info.ts + mock_net_delay > Time:GetTime() then
            return
        end
        table.remove(self.delay_recv_list, 1)
        return info.data
    else
        return data
    end
end

function TCPConnect:__send(msg_bytes)
    if not self:IsConnected() or not msg_bytes then
        return
    end
    if not msg_bytes or msg_bytes == "" then return end
    local sended = 0
    local length = string.len(msg_bytes)
    self.total_send_size = self.total_send_size + length
    local a, b
    while sended < length do
        sended, a, b = self.conn:send(msg_bytes, sended + 1, length)
        if not sended then
            if a ~= 'timeout' then
                self:_OnDisconnect("Send Data failed:" .. a)
                break
            else
                sended = b
            end
        end
    end
end

function TCPConnect:_send(msg_bytes)
    self.raw_send_size = self.raw_send_size + string.len(msg_bytes)
    self.send_msg_count = self.send_msg_count + 1
    if self.ssl then
        self.ssl:Send(msg_bytes)
        local data = self.ssl:MockServerRecv()
        if data and data ~= "" then
            self:__send(data)
        end
    else
        self:__send(msg_bytes)
    end
end

function TCPConnect:Send(msg_bytes)
    if not msg_bytes or msg_bytes == "" then return end
    if mock_net_delay > 0 then
        table.insert(self.delay_send_list, {msg_bytes=msg_bytes, ts=Time:GetTime()})
    else
        self:_send(msg_bytes)
    end
end

function TCPConnect:_OnConnect()
    print("TCPConnect:_OnConnect")
    if self.connect_cb then
        self.connect_cb()
        self.connect_cb = nil
    end
    self.conn:setoption("linger", {on = true, timeout = 1})
end

function TCPConnect:_OnDisconnect(err)
    PrintWarn("TCPConnect:_OnDisconnect", err)
    self._status = GConst.ConnectStatus.STATUS_Disconnected
    if self.ssl then
        self.ssl:Destroy()
        self.ssl = nil
    end
    if self.error_cb then
        self.error_cb(GConst.NetFailed.TCP_Receive_Disconnect, err)
    end
end

function TCPConnect:_OnConnectFailed(failed_type, err)
    PrintWarn("TCPConnect:_OnConnectFailed", err)
    self._status = GConst.ConnectStatus.STATUS_Failed
    if self.ssl then
        self.ssl:Destroy()
        self.ssl = nil
    end
    if self.error_cb then
        self.error_cb(failed_type, err)
    end
end

return TCPConnect