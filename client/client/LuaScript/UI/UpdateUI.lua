local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local AppUtils = require("BaseUtilities.AppUtils")
local DownloadMgr = require("Mgrs.Special.DownloadMgr")
local AssetBundleConst = AssetBundles.AssetBundleConst
local AssetBundleSet = AssetBundles.AssetBundleSet

local RectTransformUtility = UnityEngine.RectTransformUtility

local UpdateUI = class("UI.UpdateUI", UIBase)

UpdateUI.download_url_base = SpecMgrs.sdk_mgr:GetSDKInfo("patch_server_url")
UpdateUI.download_path = Application.persistentDataPath .. "/download/"
UpdateUI.download_list_filename = "_DownloadList.txt"

function UpdateUI:DoInit()
    print("UpdateUI:DoInit()============")
    UpdateUI.super.DoInit(self)
    self.prefab_path = "UI/Common/UpdateUI"
end

function UpdateUI:OnGoLoadedOk(res_go)
    print("22222")
    UpdateUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    coroutine.start(self.StartUpdate, self)
end

function UpdateUI:Hide()
    print("UpdateUI:Hide()===========")
    UpdateUI.super.Hide(self)
end

function UpdateUI:InitRes()
    print("UpdateUI:InitRes()============")
    self.progress_bar = self.main_panel:FindChild("ProgressBar")
    self.progress_slider = self.progress_bar:FindChild("Slider"):GetComponent("Slider")
    self.progress_text = self.progress_bar:FindChild("Text"):GetComponent("Text")
    self.tips_content = self.main_panel:FindChild("TipsContent")
    self.tips_content:FindChild("Box/Top/Text"):GetComponent("Text").text = UIConst.Text.TIP
    self.tips_content:FindChild("Box/ConfirmBtn/Text"):GetComponent("Text").text = UIConst.Text.CONFIRM
    self.tips_content_text = self.tips_content:FindChild("Box/Content"):GetComponent("Text")
    self.error_content = self.main_panel:FindChild("ErrorContent")
    self.error_content:FindChild("Box/Top/Text"):GetComponent("Text").text = UIConst.Text.TIP
    self.error_content:FindChild("Box/ConfirmBtn/Text"):GetComponent("Text").text = UIConst.Text.CONFIRM
    self.error_content_text_comp = self.error_content:FindChild("Box/Content"):GetComponent("Text")

    self:AddClick(self.tips_content:FindChild("Box/ConfirmBtn"), function()
        self.tips_content:SetActive(false)
        self.progress_bar:SetActive(true)
        coroutine.start(self._StartDownload, self)
    end)

    self:AddClick(self.error_content:FindChild("Box/ConfirmBtn"), function()
        self.error_content:SetActive(false)
        coroutine.start(self._RestartGame, self)
        self.error_tips = nil
    end)
end

function UpdateUI:StartUpdate()
    print("UpdateUI:StartUpdate")
    self.tips_content:SetActive(false)
    self.progress_bar:SetActive(false)
    self.error_content:SetActive(false)
    self.simulate_mode = GameResourceMgr.IsSimulateMode()
    print("热更路径---",self.simulate_mode)
    print("热更路径---",UpdateUI.download_url_base)
    if self.simulate_mode or UpdateUI.download_url_base == "" then
        print("555555")
        --SpecMgrs.sdk_mgr:QuickLogin()
        self:UnityStartLogin()
        return
    end
    --SpecMgrs.sdk_mgr:QuickLogin()
    print("登陆登陆登陆1111111=========")
    self.inner_set = GameResourceMgr.GetInnerSet()
    print("登陆登陆登陆22222=========")
    self.external_set = GameResourceMgr.GetExternalSet()
    print("登陆登陆登陆33333=========")
    self.platform_name = AssetBundleConst.GetPlatformName()
    print("登陆登陆登陆44444=========")
    self.download_mgr = SpecMgrs.download_mgr
    print("登陆登陆登陆55555=========")
    if AppUtils.GetNetWorkState() == "none" then -- 一开始断网
        self:OnError(nil, nil, UIConst.Text.UPDATE_GAME_ERROR)
        return
    end
    print("登陆登陆登陆6666666=========")
    self.download_url = self.download_url_base .. self.platform_name .. "/"
    if not IsDirectoryExists(self.download_path) then
        CreateDirectory(self.download_path)
    end
    print("登陆走到这里=========")
    self.new_set = self:_DownloadVersion()
    print("self:_DownloadVersion()登陆走到这里=========",self.new_set)
    if not self.new_set then
        print("登陆走到这里1111111=========")
        --SpecMgrs.sdk_mgr:QuickLogin()
        return
    end
    if not self:_CheckNeedUpdate() then
        --print("登陆走到这里22222222=========",CSConst.CilentProcessType.STARTTRAN_INIT_SUCCEED)
        SpecMgrs.sdk_mgr:QuickLogin()
        self:StartLogin()
        --SpecMgrs.sdk_mgr:QuickLogin()
        ComMgrs.dy_data_mgr.log_data:SendStartUpTranLog(CSConst.CilentProcessType.STARTTRAN_INIT_SUCCEED)
        return
    end
    self.download_url = self.download_url --.. self.new_set.svn_version_ .. "/"
    self:_DownloadNewSet()
    self.file_diff = self:_GenFileDiff()
    self:DownLoadMsg()
end

function UpdateUI:StartLogin()
    print("UpdateUI:StartLogin()====================")
    --SpecMgrs.sdk_mgr:Login()
    --SpecMgrs.sdk_mgr:QuickLogin()
    self:Hide()
end

function UpdateUI:UnityStartLogin()
    print("UpdateUI:UnityStartLogin()====================")
    SpecMgrs.sdk_mgr:Login()
    --SpecMgrs.sdk_mgr:QuickLogin()
    self:Hide()
end

function UpdateUI:DownLoadMsg()
    local total_size = 0
    for k, v in pairs(self.file_diff.download) do
        if not v.finish then
            total_size = total_size + v.size
        end
    end
    print("UpdateUI:DownLoadMsg  ",total_size)
    local size = string.format("%.2f", total_size / 1000000)
    self.tips_content_text.text = string.render(UIConst.Text.UPDATE_GAME_TIPS, {value = size})
    self.tips_content:SetActive(true)
end

function UpdateUI:_StartDownload()
    print("UpdateUI:_StartDownload()====================")
    ComMgrs.dy_data_mgr.log_data:SendStartUpTranLog(CSConst.CilentProcessType.STARTTRAN_START_HOT_UPDATE)
    self:_DownloadDiff()
    local ret = self:_MoveToExternal()
    if ret then
        print("UpdateUI:_MoveToExternal Finish")
        self._RestartGame()
    end
end

function UpdateUI:_DownloadVersion()
    print("UpdateUI:_DownloadVersion")
    local new_set
    SpecMgrs.download_mgr:DownloadToFile(
        self.download_url .. AssetBundleConst.set_version_filename,
        self.download_path .. AssetBundleConst.set_version_filename,
        function(content, error)
            if content then
                new_set = AssetBundleSet(self.download_path)
                new_set:ReadVersion();
                ComMgrs.dy_data_mgr.log_data:SendStartUpTranLog(CSConst.CilentProcessType.STARTTRAN_REQUEST_VERSION_CONTROL_SUCCEED)
            else
                print("UpdateUI:_DownloadVersion error:", error)
                ComMgrs.dy_data_mgr.log_data:SendStartUpTranLog(CSConst.CilentProcessType.STARTTRAN_REQUEST_VERSION_CONTROL_FAIL)
                self:OnError(self.download_url .. AssetBundleConst.set_version_filename, error, UIConst.Text.UPDATE_GAME_ERROR4)
                --return true
            end
        end
    )
    self:WaitForDownload()
    return new_set
end

function UpdateUI:_CheckNeedUpdate()
    local old_version = self.external_set and self.external_set.svn_version_ or self.inner_set.svn_version_
    local new_version = self.new_set.svn_version_
    print("UpdateUI:_CheckNeedUpdate", old_version, new_version)
    if (old_version==new_version) then
        print("=================================================")
        --SpecMgrs.sdk_mgr:QuickLogin()
    end
    return new_version > old_version
end

function UpdateUI:_DownloadNewSet()
    print("UpdateUI:_DownloadNewSet", self.download_url .. AssetBundleConst.set_filename)
    SpecMgrs.download_mgr:DownloadToFile(
        self.download_url .. AssetBundleConst.set_filename,
        self.download_path .. AssetBundleConst.set_filename,
        function(content, error)
            if content then
                self.new_set:ReadSet()
            else
                self:OnError(self.download_url .. AssetBundleConst.set_filename, error, UIConst.Text.UPDATE_GAME_ERROR)
                -- return true
            end
        end
    )
    self:WaitForDownload()
end

function UpdateUI:_GenFileDiff()
    print("UpdateUI:_GenFileDiff")
    local new_list = self.new_set:GetList()
    local old_list = self.external_set and self.external_set:GetList() or self.inner_set:GetList()
    local download = {}
    local lang_ab_name = AssetBundleConst.GetLangABName()
    local system_lang = SpecMgrs.system_mgr:GetLanguage()
    for k, v in pairs(new_list) do
        if self:CheckDownload(old_list[k], v, lang_ab_name, system_lang) then
            download[k] = v
        end
    end
    local delete = {}
    for k, v in pairs(old_list) do
        if not new_list[k] then
            delete[k] = v
        end
    end
    if IsFileExists(self.download_path .. self.download_list_filename) then
        local old_file_diff = json.decode(ReadFile(self.download_path .. self.download_list_filename))
        for k, v in pairs(old_file_diff.download) do
            if download[k] and download[k].md5 == v.md5 and v.finish then
                if IsFileExists(self.download_path .. v.name) then
                    download[k].finish = true
                else
                    print("_GenFileDiff  error not finish  ",self.download_path .. v.name)
                    download[k].finish = false
                end
            end
        end
    end
    return {download = download, delete = delete}
end

function UpdateUI:CheckDownload(old_item, new_item, lang_ab_name, system_lang)
    --print(" UpdateUI:CheckDownload()==================")
    local ab_name = new_item.name
    local is_lang = false
    for _, name in ipairs(lang_ab_name) do
        if string.match(ab_name, name) then
            is_lang = true
            break
        end
    end
    if is_lang and string.sub(ab_name, -#system_lang) ~= system_lang then
        return false
    end
    if old_item and old_item.md5 == new_item.md5 then
        return false
    end
    return true
end

function UpdateUI:_DownloadDiff()
    print("UpdateUI:_DownloadDiff")
    local download_mgr = SpecMgrs.download_mgr
    local download_handles = {}
    for k, v in pairs(self.file_diff.download) do
        if not v.finish then
            print("UpdateUI:DownloadToFile", self.download_url .. k)
            download_handles[k] = download_mgr:DownloadToFile(
                self.download_url .. k,
                self.download_path .. k,
                function(content, error)
                    if content then
                        v.finish = true
                        self:SaveFileDiff()
                    else
                        self:OnError(self.download_url .. k, error, UIConst.Text.UPDATE_GAME_ERROR, true)
                        return true
                    end
                end
            )
        end
    end
    self:SaveFileDiff()
    self.progress_bar:SetActive(true)
    while true do
        local total_count = 0
        local total_size = 0
        local finish_count = 0
        local finish_size = 0
        for k, v in pairs(self.file_diff.download) do
            total_count = total_count + 1
            total_size = total_size + v.size
            if v.finish then
                finish_count = finish_count + 1
                finish_size = finish_size + v.size
            else
                finish_size = finish_size + download_mgr:GetDownloadProgress(download_handles[k])
            end
        end
        self:ShowDownloadState(total_count, total_size, finish_count, finish_size)
        if finish_count == total_count then
            break
        end
        coroutine.wait(1)
    end
end

function UpdateUI:_MoveToExternal()
    print("UpdateUI:_MoveToExternal",self.file_diff.download)
    local external_path = AssetBundleConst.external_path
    if not IsDirectoryExists(external_path) then
        CreateDirectory(external_path)
    end
    for k, v in pairs(self.file_diff.download) do
        local ret = IsFileExists(self.download_path .. v.name)
        print("Check _MoveToExternal   ",v.name, ret)
        if not ret then
            self:OnError(self.download_path .. v.name, nil, UIConst.Text.UPDATE_GAME_ERROR3)
            return false
        end
    end
    for k, v in pairs(self.file_diff.download) do
        MoveFile(self.download_path .. v.name, external_path .. v.name)
    end
    for k, v in pairs(self.file_diff.delete) do
        DeleteFile(external_path .. v.name)
    end
    MoveFile(self.download_path .. AssetBundleConst.set_filename, external_path .. AssetBundleConst.set_filename)
    MoveFile(self.download_path .. AssetBundleConst.set_version_filename, external_path .. AssetBundleConst.set_version_filename)
    DeleteFile(self.download_path .. self.download_list_filename)
    return true
end

function UpdateUI:_RestartGame()
    print("UpdateUI:_RestartGame======================")
    --SpecMgrs.sdk_mgr:QuickLogin()
    coroutine.wait(0)
    LuaGC()
    coroutine.wait(0)
    GameResourceMgr.GC()
    coroutine.wait(0)
    GameEntry:Restart()
    ComMgrs.dy_data_mgr.log_data:SendStartUpTranLog(CSConst.CilentProcessType.STARTTRAN_UPDATE_SUCCEED_RESTART)
end

function UpdateUI:SaveFileDiff()
    local content = json.encode(self.file_diff, {indent = true})
    WriteFile(self.download_path .. self.download_list_filename, content)
end

function UpdateUI:OnError(url, error, error_text, is_download_diff)
    print(" 下载错误  ", url, error)
    if is_download_diff and AppUtils.GetNetWorkState() ~= "none" then  -- 下包时，联网
        return
    end
    if self.error_tips then return end
    self.error_tips = true
    self.error_content:SetActive(true)
    self.error_content_text_comp.text = error_text
end

function UpdateUI:ShowDownloadState(total_count, total_size, finish_count, finish_size)
    local text = string.format(
        "下载中%.2f%%，速度%.fKB/s，剩余%.2fMB，%d个文件",
        finish_size / total_size * 100,
        SpecMgrs.http_mgr.speed / 1000,
        (total_size - finish_size) / 1000000,
        total_count - finish_count)
    self.progress_text.text = text
    self.progress_slider.value = finish_size / total_size
end

function UpdateUI:WaitForDownload()
    local download_mgr = SpecMgrs.download_mgr
    while download_mgr:GetDownloadingCount() > 0 do
        coroutine.wait(0)
    end
end

return UpdateUI