--region NewFile_1.lua
--Author : LiMengbin
--Date   : 2016/6/5
--此文件由[BabeLua]插件自动生成

local HttpMgr = class("Mgrs.Special.HttpMgr")
local socket = require("Network.socket")

local function Log(...)
  print(...)
end

-------------------------------------------------------------------------
-- Http管理器 -------------------------------------------------------
-------------------------------------------------------------------------
function HttpMgr:DoInit()
  Log("HttpMgr:Start")
  self.timeout = 15
  self.http_list = {}
  self.http_index = {}
  self.socket_list = {}
  self.speed = 0
  self.speed_cache = 0
  self.speed_time = os.time()
  self.speed_time_interval = 0.5
end

function HttpMgr:Update()
  -- 收包
  local recv_list, send_list, err = socket.select(self.socket_list, self.socket_list, 0)
  --Log("ConnMgr:Update:", table.dump(self.socket_list), err, table.dump(self.socket_recv_list), table.dump(self.socket_send_list))
  if err ~= "timeout" then
    if send_list and next(send_list) then
      for i, send_socket in ipairs(send_list) do
        self:__OnSendAvailable(self.http_index[send_socket])
      end
    end
    if recv_list and next(recv_list) then
      for i, recv_socket in ipairs(recv_list) do
        self:__OnRecvAvailable(self.http_index[recv_socket])
      end
    end
  end
  -- 更新下载速度
  local time = os.time()
  local speed_time = time - self.speed_time
  if speed_time > self.speed_time_interval then
    self.speed = self.speed_cache / speed_time
    self.speed_cache = 0
    self.speed_time = time
  end
  -- 超时检查
  for i = #self.http_list, 1, -1 do
    if time - self.http_list[i].last_update_time > self.timeout then
      self:__OnFinish(self.http_list[i], "timeout")
    end
  end
end

function HttpMgr:Request(url, finish_cb, ...)
  local url_info, err = self:__ParseURL(url)
  Log("HttpMgr:Request", url, url_info)
  if not url_info then
    error("Http URL Error:" .. err)
  end
  --Log(table.dump(url_info))
  local socket = socket.tcp()
  socket:settimeout(0)
  socket:connect(url_info.host, url_info.port or 80)
  local http = {
    url = url,
    url_info = url_info,
    socket = socket,
    state = "connecting",
    last_update_time = os.time(),
    isDone = false,
    finish_cb = finish_cb,
    params = table.pack(...)
  }
  table.insert(self.http_list, http)
  table.insert(self.socket_list, socket)
  self.http_index[socket] = http
  return http
end

function HttpMgr:DoDestroy()
  while next(self.http_list) do
    self:__OnFinish(self.http_list[1], "destroy")
  end
end

function HttpMgr:__OnSendAvailable(http)
  if http.state == "connecting" then
    if http.url_info.query then
      http.socket:send("GET " .. http.url_info.path .. "?" .. http.url_info.query .. " HTTP/1.0\r\n\r\n")
      --Log("GET " .. http.url_info.path .. "?" .. http.url_info.query .. " HTTP/1.0\r\n\r\n")
    else
      http.socket:send("GET " .. http.url_info.path .. " HTTP/1.0\r\n\r\n")
    end
    http.head_data = ""
    http.state = "gethead"
  end
end

function HttpMgr:__OnRecvAvailable(http)
  --Log("HttpMgr:__OnRecvAvailable")
 local result, err, part = http.socket:receive("*a")
  --Log("ConnBase:OnRecvAvailable", result, err, part)
  if not err then
    self:__OnReceiveData(http, result)
  elseif err == "timeout" then
    self:__OnReceiveData(http, part)
  elseif err == "closed" then
    self:__OnDisconnect(http)
  else
    self:__OnFinish(http, err)
  end
end

function HttpMgr:__OnReceiveData(http, data)
  self.speed_cache = self.speed_cache + string.len(data)
  if http.state == "gethead" then
    http.head_data = http.head_data .. data
    if string.find(http.head_data, "\r\n\r\n") then
      local head_data = http.head_data
      local i = string.find(head_data, "\r\n\r\n")
      local err = nil
      http.head, err = self:__ParseHead(string.sub(head_data, 1, i + 3))
      if http.head then
        --Log("head:", table.dump(http.head))
        http.head_data = nil
        http.data_total_len = tonumber(http.head["content-length"])
        http.data_table = {}
        http.data_len = 0
        http.state = "getcontent"
        if string.len(data) >= i + 4 then
          data = string.sub(head_data, i + 4)
        else
          return
        end
      else
        self:__OnFinish(http, "head error:"..err)
      end
    end
  end
  
  if http.state == "getcontent" then
    table.insert(http.data_table, data)
    http.data_len = http.data_len + string.len(data)
    http.last_update_time = os.time()
    if http.data_len == http.data_total_len then
      http.data = table.concat(http.data_table)
      http.bytes = http.data
      http.text = http.data
      http.data_table = nil
      self:__OnFinish(http)
    end
  end
end

function HttpMgr:__OnFinish(http, err)
  if http.state == "finish" then return end
  Log("HttpMgr:__OnFinish", http, err)
  http.state = "finish"
  http.isDone = true
  http.error = err
  self.http_index[http.socket] = nil
  for k, v in ipairs(self.http_list) do
    if v == http then
      table.remove(self.http_list, k)
      break
    end
  end
  for k, v in ipairs(self.socket_list) do
    if v == http.socket then
      table.remove(self.socket_list, k)
      break
    end
  end
  http.socket:shutdown()
  http.socket:close()
  http.socket = nil
  if http.finish_cb then
      http.finish_cb(http, table.unpack(http.params))
  end
end

function HttpMgr:__OnDisconnect(http)
  self:__OnFinish(http, "Disconnect")
end

-- copy from luasocket, change to async
function HttpMgr:__ParseHead(head_data)
    local function Split(self, sep)
      local sep, fields = sep or ",", {}
      local pattern = string.format("([^%s]+)", sep)
      self:gsub(pattern, function(c) table.insert(fields, c) end)
      return fields
    end
    head_data = string.gsub(head_data, "\r", "")
    local lines = Split(head_data, "\n")
    local i = 1
    local line = lines[i]
    -- code
    local code = string.match(line, "HTTP/%d*%.%d* (%d%d%d)")
    if not code or code ~= "200" then return nil, code end
    i, line = next(lines, i)
    if not line then return nil, "not line" end
    -- head
    local headers = {}
    local name, value
    while line do
        -- get field-name and value
        name, value = string.match(line, "^(.-):%s*(.*)")
        if not (name and value) then return nil, "malformed reponse headers" end
        name = string.lower(name)
        -- get next line (value might be folded)
        i, line = next(lines, i)
        -- unfold any folded values
        while line and string.find(line, "^%s") do
            value = value .. line
            i, line = next(lines, i)
        end
        -- save pair in table
        if headers[name] then headers[name] = headers[name] .. ", " .. value
        else headers[name] = value end
    end
    return headers
end

-- copy from luasocket
function HttpMgr:__ParseURL(url, default)
    -- initialize default parameters
    local parsed = {}
    for i,v in pairs(default or parsed) do parsed[i] = v end
    -- empty url is parsed to nil
    if not url or url == "" then return nil, "invalid url" end
    -- remove whitespace
    -- url = string.gsub(url, "%s", "")
    -- get fragment
    url = string.gsub(url, "#(.*)$", function(f)
        parsed.fragment = f
        return ""
    end)
    -- get scheme
    url = string.gsub(url, "^([%w][%w%+%-%.]*)%:",
        function(s) parsed.scheme = s; return "" end)
    -- get authority
    url = string.gsub(url, "^//([^/]*)", function(n)
        parsed.authority = n
        return ""
    end)
    -- get query stringing
    url = string.gsub(url, "%?(.*)", function(q)
        parsed.query = q
        return ""
    end)
    -- get params
    url = string.gsub(url, "%;(.*)", function(p)
        parsed.params = p
        return ""
    end)
    -- path is whatever was left
    if url ~= "" then parsed.path = url end
    local authority = parsed.authority
    if not authority then return parsed end
    authority = string.gsub(authority,"^([^@]*)@",
        function(u) parsed.userinfo = u; return "" end)
    authority = string.gsub(authority, ":([^:]*)$",
        function(p) parsed.port = p; return "" end)
    if authority ~= "" then parsed.host = authority end
    local userinfo = parsed.userinfo
    if not userinfo then return parsed end
    userinfo = string.gsub(userinfo, ":([^:]*)$",
        function(p) parsed.password = p; return "" end)
    parsed.user = userinfo
    return parsed
end

return HttpMgr

--endregion
