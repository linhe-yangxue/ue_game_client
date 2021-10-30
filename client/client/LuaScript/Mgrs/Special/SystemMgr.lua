local SystemInfo = UnityEngine.SystemInfo
local QualitySettings = UnityEngine.QualitySettings
local GConst = require("GlobalConst")
local SoundConst = require("Sound.SoundConst")
local SystemMgr = class("Mgrs.Special.SystemMgr")

local kAudioDefaultState = true
local kSoundDefaultState = true
local kVolumeDefaultValue = 1
local liu_hai_device = {
    "iPhone10,3",
    "iPhone10,6",
    "iPhone11,2",
    "iPhone11,4",
    "iPhone11,6",
    "iPhone11,8",
}

SystemMgr.RuntimePlatform = {
    OSXEditor = 0,
    OSXPlayer = 1,
    WindowsPlayer = 2,
    OSXWebPlayer = 3,
    OSXDashboardPlayer = 4,
    WindowsWebPlayer = 5,
    WindowsEditor = 7,
    IPhonePlayer = 8,
    PS3 = 9,
    XBOX360 = 10,
    Android = 11,
    NaCl = 12,
    LinuxPlayer = 13,
    FlashPlayer = 15,
    LinuxEditor = 16,
    WebGLPlayer = 17,
    WSAPlayerX86 = 18,
    MetroPlayerX86 = 18,
    MetroPlayerX64 = 19,
    WSAPlayerX64 = 19,
    WSAPlayerARM = 20,
    MetroPlayerARM = 20,
    WP8Player = 21,
    BB10Player = 22,
    BlackBerryPlayer = 22,
    TizenPlayer = 23,
    PSP2 = 24,
    PS4 = 25,
    PSM = 26,
    XboxOne = 27,
    SamsungTVPlayer = 28,
    WiiU = 30,
    tvOS = 31,
    Switch = 32,
}

function SystemMgr:DoInit()
    self.platform = Application.platform
    self.is_editor = Application.isEditor
    self.is_mobile = self:IsAndroid() or self:IsIOS()
    self.has_key_input = not self.is_mobile
    self:_InitSystemInfo()
    self:_InitSystemLang()
    self:_CompatLiuHai()
end

function SystemMgr:DoDestroy()
end

function SystemMgr:IsAndroid()
    return self.platform == self.RuntimePlatform.Android
end

function SystemMgr:IsIOS()
    return self.platform == self.RuntimePlatform.IPhonePlayer
end

function SystemMgr:IsWindowsEditor()
    return self.platform == self.RuntimePlatform.WindowsEditor
end

function SystemMgr:_InitSystemInfo()
  self.system_info = {
    deviceModel = tostring(SystemInfo.deviceModel),
    deviceName = tostring(SystemInfo.deviceName),
    deviceType = tostring(SystemInfo.deviceType),
    deviceUniqueIdentifier = tostring(SystemInfo.deviceUniqueIdentifier),
    graphicsDeviceID = tostring(SystemInfo.graphicsDeviceID),
    graphicsDeviceName = tostring(SystemInfo.graphicsDeviceName),
    graphicsDeviceType = tostring(SystemInfo.graphicsDeviceType),
    graphicsDeviceVersion = tostring(SystemInfo.graphicsDeviceVersion),
    graphicsMemorySize = tostring(SystemInfo.graphicsMemorySize),
    operatingSystem = tostring(SystemInfo.operatingSystem),
    processorCount = tostring(SystemInfo.processorCount),
    processorType = tostring(SystemInfo.processorType),
    systemMemorySize = tostring(SystemInfo.systemMemorySize),
    internetReachability = tostring(Application.internetReachability),
  }
  print("=================== SystemInfo ===================")
  for k ,v in pairs(self.system_info) do
    print(k, ":", v)
  end
  print("------------------- SystemInfo -------------------")
end

function SystemMgr:_InitSystemLang()
    self.system_lang = "chs"
    SetLanguage(self.system_lang)
    GameResourceMgr.SetLangVariant(self.system_lang)
end

-- 刘海屏适配
function SystemMgr:_CompatLiuHai()
    if table.index(liu_hai_device, self.system_info.deviceModel) then
        self.has_liu_hai = true
    end
end

-- 音效相关
--音乐的状态，true为打开
function SystemMgr:SetAudioState(state)
    SpecMgrs.config_mgr:SetValue(GConst.Config.AUDIO_STATE, state)
    SpecMgrs.sound_mgr:ToggleBGMVolume(state)
end
function SystemMgr:GetAudioState()
    local cur_state = SpecMgrs.config_mgr:GetValue(GConst.Config.AUDIO_STATE)
    cur_state = cur_state == nil and kAudioDefaultState or cur_state
    return cur_state
end
--音效的状态，true为打开
function SystemMgr:SetSoundState(state)
    SpecMgrs.config_mgr:SetValue(GConst.Config.SOUND_STATE, state)
    SpecMgrs.sound_mgr:ToggleSFXVolume(state)
end

function SystemMgr:GetSoundState()
    local cur_state = SpecMgrs.config_mgr:GetValue(GConst.Config.SOUND_STATE)
    cur_state = cur_state == nil and kSoundDefaultState or cur_state
    return cur_state
end
--音乐和音效的音量，0 ~ 1
function SystemMgr:SetVolume(value, sound_type)
    if sound_type then
        SpecMgrs.config_mgr:SetValue(SoundConst.Config[sound_type], value)
        SpecMgrs.sound_mgr:SetVolume(sound_type, value)
    else
        SpecMgrs.config_mgr:SetValue(GConst.Config.VOLUME_VALUE, value)
        SpecMgrs.sound_mgr:SetGlobalVolume(value)
    end
end

function SystemMgr:GetVolume(sound_type)
    local cur_value = SpecMgrs.config_mgr:GetValue(sound_type and SoundConst.Config[sound_type] or GConst.Config.VOLUME_VALUE)
    cur_value = cur_value or kVolumeDefaultValue
    return cur_value
end
-- 音效相关 end

function SystemMgr:GetLanguage()
    return self.system_lang
end

return SystemMgr
