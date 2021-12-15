local WWW = UnityEngine.WWW
local AppUtils = require("BaseUtilities.AppUtils")
local DownloadMgr = class("Mgrs.Special.DownloadMgr")

function DownloadMgr:DoInit()
  print("DownloadMgr:DoInit")
  self.max_www = 5
  self.sequence = {}
  self.downloading = {}
end

function DownloadMgr:Update()
  local time = os.time()
  if AppUtils.GetNetWorkState() == "none" then  -- 热更断网，清除序列,中断下载
    self.sequence = {}
  end
  while #self.downloading < self.max_www do
    local info = self.sequence[1]
    if not info then break end
    table.remove(self.sequence, 1)
    info.start_time = time
    if string.sub(info.url, 1, 4) == "http" then
      info.type = "http"
      info.www = SpecMgrs.http_mgr:Request(info.url)
      print("DownloadMgr: info.www--",info.www,info.url)
    else
      if platform == "Android" then
        info.type = "www"
        info.www = WWW.New(info.url)
      else
        info.type = "file"
        if IsFileExists(info.url) then
          local bytes = ReadFile(info.url)
          info.www = {
            url = info.url,
            bytes = bytes,
            text = bytes,
            isDone = true,
          }
        else
          info.www = {
            url = info.url,
            isDone = true,
            error = "Can not find file!",
          }
        end
      end
    end
    table.insert(self.downloading, info)
  end
  for i = #self.downloading, 1, -1 do
    local info = self.downloading[i]
    if info.www.isDone then
      table.remove(self.downloading, i)
      if info.www.error then
        PrintWarn(string.format("下载%s失败 %s", info.url, info.www.error))
        if info.callback_func(nil, info.www.error) then  -- 重试
            self:Download(info.url, info.callback_func)
        end
      else
        print("Download finish:", info.url)
        local content = info.www.bytes
        if info.save_path then
            WriteBinaryFile(info.save_path, content)
        end
        info.callback_func(content)
      end
      if info.www.Dispose then info.www:Dispose() end
      info.www = nil
    end
  end
end

function DownloadMgr:Download(url, callback_func)
  print("Download start:", url)
  local info = {
    url = url,
    callback_func = callback_func,
  }
  table.insert(self.sequence, info)
  return info
end

function DownloadMgr:DownloadToFile(url, save_path, callback_func)
  print("DownloadToFile start:", url, save_path)
  local info = {
    url = url,
    callback_func = callback_func,
    save_path = save_path,
  }
  table.insert(self.sequence, info)
  return info
end

function DownloadMgr:GetDownloadingCount()
  return #self.sequence + #self.downloading
end

function DownloadMgr:GetDownloadProgress(info)
  if not info or not info.www or info.type ~= "http" then
    return 0
  end
  return info.www.data_len or 0
end

function DownloadMgr:DoDestroy()

end

return DownloadMgr
