local GConst = require("GlobalConst")
local SDK = SDK
local SDKMgr = class("Mgrs.Special.SDKMgr")


function SDKMgr:DoInit()
    print("SDKMgr:DoInit")
    self.platform = SpecMgrs.system_mgr.platform
    self.is_editor = SpecMgrs.system_mgr.is_editor
    SpecMgrs.event_mgr:AddSDKListener(function(type, json_str)
        if type == "CallLua" then
            self:RecvFromSDK(json_str)
        else
            self:CatchSDKError(json_str)
        end
    end)
    self.sdk_info = self:_ReadSDKInfo()
    self.sdk = self.sdk_info.sdk
    -- 临时hardcode， 编辑器不开sdk
    if self.is_editor then
        self.sdk = {}
    end

    self:InitSDK()
    -- test
    --self:Test()
end

function SDKMgr:DoDestroy()
    SpecMgrs.event_mgr:RemoveSDKListener()
end

function SDKMgr:Update(delta_time)
end

--------------------------------------------------------------------------------------
-- interface
--------------------------------------------------------------------------------------
function SDKMgr:InitSDK()
    print("SDKMgr:InitSDK")
    if self.sdk.Gaea then self:GaeaInit() end
    if self.sdk.Gata then self:GataInit() end
end

-- 登录相关 -------------------------

function SDKMgr:Login()
    print("SDKMgr:Login")
    local is_automator = self:IsAutomator()
    if not is_automator and self.sdk.Gaea then
        SpecMgrs.ui_mgr:ShowUI("LoginUI", true)
        self:GaeaLogin()
    else
        SpecMgrs.ui_mgr:ShowUI("LoginUI", false)
    end
end

function SDKMgr:LoginResult(type, username, param)
    print("SDKMgr:LoginResult", type, username, param)
    PlayerPrefs.SetString("LOGIN_ACCOUNT", type .. ":" .. username)
    local gaea_param = {}
    for k,v in pairs(param) do
        if k ~= "code" and k ~= "message" then
            gaea_param[k] = v
        end
    end
    local gata_param = self:GetDeviceInfo()
    local account_info = {
        type = type,
        username = username,
        param = gaea_param,
        gata_param = gata_param,
    }
    ComMgrs.dy_data_mgr:ExSetAccountInfo(account_info)
    print("SDKMgr:LoginResult", account_info)
    if not ComMgrs.dy_data_mgr:ExIsInLoginStage() then
        SpecMgrs.stage_mgr:GotoStage("LoginStage")
    else
        SpecMgrs.ui_mgr:ShowUI("LoginUI", true)
    end
    --local ui = SpecMgrs.ui_mgr:GetUI("SelectServerUI")
    --if ui then
    --    ui:RequireServerList()
    --end
    self:OnUserLogin(username)
end

function SDKMgr:LogoutResult(type, param)
    print("SDKMgr:LogoutResult", type, param)
    SpecMgrs.stage_mgr:GotoStage("LoginStage", nil, nil, nil, true, nil, true)
    self:OnUserLogout()
end


function SDKMgr:SwitchAccount()
    print("SDKMgr:SwitchAccount")
    if self.sdk.Gaea then
        self:GaeaSwitchAccount()
    end
end

-- 支付相关 -------------------------
function SDKMgr:Pay(productId)
    print("SDKMgr:Pay", productId)
    if self.sdk.Gaea then
        self:GaeaPay({
            -- todo
            moneyAmount = "6",
            productId = self:IsIOS() and "com.gaea.cn.shanhaim.t1g60" or "com.gaea.cn.shanhaim.g60",
            productName = "60仙玉",
            appName = "appName",
            cpInfo = "cpInfo",
            appUserId = "aaa",
            appUserName = "aaa",
            appUserLevel = "10",
            serverId = "aaa",
            --currency = "aaa",
            payExt = "payExt",
        })
    end
end

function SDKMgr:PayResult(success, param)
    print("SDKMgr:PayResult", success, param)
    -- todo
end


-- 信息相关 -------------------------
function SDKMgr:IsReviewVersion()
    return self.sdk_info.review and true or false
end

function SDKMgr:IsAutomator()
    return self.sdk_info.automator and true or false
end

function SDKMgr:GetSDKInfo(value)
    if value then
        return self.sdk_info[value]
    end
    return self.sdk_info
end

function SDKMgr:GetVersion()
    if self.sdk.Gata then
        return self:GataGetVersion()
    end
    return self:GetSDKInfo("version")
end

function SDKMgr:GetChannel()
    if self.sdk.Gata then
        return self:GataGetChannel()
    end
    return self:GetSDKInfo("channel")
end

function SDKMgr:GetAppId()
    if self.sdk.Gata then
        return self:GataGetAppId()
    end
    return self:GetSDKInfo("app_id")
end

function SDKMgr:GetDeviceInfo()
    if self.sdk.Gata then
        return self:GataGetDeviceInfo()
    end
    return {}
end

local UIDeviceBatteryState = {
    UIDeviceBatteryStateUnknown = 0,
    UIDeviceBatteryStateUnplugged = 1,
    UIDeviceBatteryStateCharging = 2,
    UIDeviceBatteryStateFull = 3,
}

local BatteryManager = {
    BATTERY_HEALTH_COLD = 7,
    BATTERY_HEALTH_DEAD = 4,
    BATTERY_HEALTH_GOOD = 2,
    BATTERY_HEALTH_OVERHEAT = 3,
    BATTERY_HEALTH_OVER_VOLTAGE = 5,
    BATTERY_HEALTH_UNKNOWN = 1,
    BATTERY_HEALTH_UNSPECIFIED_FAILURE = 6,
    BATTERY_PLUGGED_AC = 1,
    BATTERY_PLUGGED_USB = 2,
    BATTERY_PLUGGED_WIRELESS = 4,
    BATTERY_PROPERTY_CAPACITY = 4,
    BATTERY_PROPERTY_CHARGE_COUNTER = 1,
    BATTERY_PROPERTY_CURRENT_AVERAGE = 3,
    BATTERY_PROPERTY_CURRENT_NOW = 2,
    BATTERY_PROPERTY_ENERGY_COUNTER = 5,
    BATTERY_PROPERTY_STATUS = 6,
    BATTERY_STATUS_CHARGING = 2,
    BATTERY_STATUS_DISCHARGING = 3,
    BATTERY_STATUS_FULL = 5,
    BATTERY_STATUS_NOT_CHARGING = 4,
    BATTERY_STATUS_UNKNOWN = 1,
}

-- return {level=, is_charging=, scale=, status=, health=, batteryV=, temperature=}
function SDKMgr:GetBatteryState()
    local result
    if self:IsAndroid() then
        result = self:CallSDKWithReturn("GetBatteryState")
        result.is_charging = result.status == BatteryManager.BATTERY_STATUS_CHARGING
    elseif self:IsIOS() then
        result = self:CallSDKWithReturn("GetBatteryState")
        result.is_charging = result.status == UIDeviceBatteryState.UIDeviceBatteryStateCharging
    else
        result = {level = 100, is_charging = false}
    end
    return result
end

-- 服务相关 -------------------------

function SDKMgr:IsShowUserCenter()
    if self.sdk.Gaea then
        return self:GaeaIsShowUserCenter()
    else
        return false
    end
end

function SDKMgr:UserCenter()
    local serverId = tostring(PlayerPrefs.GetInt("SELECT_SERVER_ID", 1))
    local roleId = tostring(ComMgrs.dy_data_mgr.main_role_info.uuid)
    if self.sdk.Gaea then
        self:GaeaUserCenter(serverId, roleId)
    end
end

-- 分享相关 -------------------------
function SDKMgr:ShareImage()

end

-- 保存图片到相册 -------------------------
function SDKMgr:SaveImage()

end

--  ios评价
function SDKMgr:ShowIosComment()

end

--  googleplay评价页面
function SDKMgr:ShowGooglePlayComment()

end

--

-- 事件相关 -------------------------

function SDKMgr:OnUserLogin(username)
    if self.sdk.Gata then
        self:GataUserLogin(username)
    end
end

function SDKMgr:OnUserLogout()
    if self.sdk.Gata then
        self:GataRoleLogout()
    end
end

function SDKMgr:OnCreateRole(role_info)
    print("SDKMgr:OnCreateRole", role_info)
    self:OnSubmitExtendData("createRole", role_info)
    if self.sdk.Gata then
        local roleId = role_info.uuid
        local serverId = ComMgrs.dy_data_mgr:ExGetServerId()
        self:GataRoleCreate(roleId, serverId)
    end
end

function SDKMgr:OnSelectRole(role_info)
    print("SDKMgr:OnSelectRole", role_info)
    self:OnSubmitExtendData("loginRole", role_info)
    if self.sdk.Gata then
        local roleId = role_info.uuid
        local serverId = ComMgrs.dy_data_mgr:ExGetServerId()
        local level = role_info.level
        self:GataRoleLogin(roleId, serverId, level)
    end
end

function SDKMgr:OnRoleLevelUp(role_info)
    print("SDKMgr:OnRoleLevelUp")
    self:OnSubmitExtendData("upgradeRole", role_info)
    if self.sdk.Gata then
        self:GataSetLevel(role_info.level)
    end
end

function SDKMgr:OnSubmitExtendData(type, role_info)
    if self.sdk.Gaea then
        local role_info = ComMgrs.dy_data_mgr:ExGetRoleInfo()
        local param = {
            roleId = role_info.uuid,              --角色ID,必传
            roleName = role_info.name,            --角色名称,必传
            roleLevel = role_info.level,          --角色等级,必传
            zoneId = role_info.server_id,       --区服ID,必传
            zoneName = role_info.server_name,   --区服名称,必传
            --roleCTime = "",                     --角色创建时间,选传
            --roleLevelMTime = "",                --角色等级变化时间,选传
            --roleExt = "",                       --扩展参数,选传
        }
        self:GaeaSubmitExtendData(type, param)
    end
end

function SDKMgr:LogEvent(eventName, content)
    print("SDKMgr:LogEvent", eventName, content)
    if self.sdk.Gata then
        self:GataLogEvent(eventName, content)
    end
end

function SDKMgr:BeginEvent(eventName)
    print("SDKMgr:BeginEvent", eventName)
    if self.sdk.Gata then
        self:GataBeginEvent(eventName)
    end
end

function SDKMgr:EndEvent(eventName, content)
    print("SDKMgr:GataEndEvent", eventName, content)
    if self.sdk.Gata then
        self:GataEndEvent(eventName, content)
    end
end

function SDKMgr:LogError(str)
    print("SDKMgr:LogError", str)
    if self.sdk.Gata then
        self:GataLogError(str)
    end
end

-- 功能开关相关 -------------------------
function SDKMgr:SetCollectDeviceInfo(enable)
    print("SDKMgr:SetCollectDeviceInfo", enable)
    if self.sdk.Gata then
        self:GataSetCollectDeviceInfo(enable)
    end
end

function SDKMgr:SetCollectAndroidID(enable)
    print("SDKMgr:SetCollectAndroidID", enable)
    if self.sdk.Gata then
        self:GataSetCollectAndroidID(enable)
    end
end

function SDKMgr:SetCanLocation(enable)
    print("SDKMgr:SetCanLocation", enable)
    if self.sdk.Gata then
        self:GataSetCanLocation(enable)
    end
end

function SDKMgr:RegistDeviceToken(deviceToken)
    print("SDKMgr:RegistDeviceToken", deviceToken)
    if self.sdk.Gata then
        self:GataRegistDeviceToken(deviceToken)
    end
end

-- 工具相关 -------------------------

function SDKMgr:EchoTest(data)
    local result = self:CallSDKWithReturn("EchoTest", data)
    return result
end

function SDKMgr:SetClipboard(str)
    self:CallSDK("SetClipboard", {str = str})
end

function SDKMgr:GetClipboard()
    return self:CallSDKWithReturn("GetClipboard").str
end

--------------------------------------------------------------------------------------
-- base
--------------------------------------------------------------------------------------
function SDKMgr:RecvFromSDK(json_str)
    print("SDKMgr:RecvFromSDK", json_str)
    local info = json.decode(json_str)
    local func_name = info.func_name
    self[func_name](self, info.param)
end

function SDKMgr:CatchSDKError(json_str)
    print("SDKMgr:CatchSDKError", json_str)
    local info = json.decode(json_str)
    PrintError(info)
end

function SDKMgr:CallSDK(func_name, param)
    print("SDKMgr:CallSDK", func_name, param)
    param = json.encode(param or {})
    if self:IsIOS() then
        SDK[func_name](param)
    else
        SDK.CallMainActicity(func_name, param)
    end
end

function SDKMgr:CallSDKWithReturn(func_name, param)
    print("SDKMgr:CallSDKWithReturn", func_name, param)
    param = json.encode(param or {})
    local result
    if self:IsIOS() then
        result = SDK[func_name](param)
    else
        --print("SDKMgr:CallSDKWithReturn33", func_name, param)
        result = SDK.CallMainActicityWithReturn(func_name, param)
        --print("SDKMgr:CallSDKWithReturn334", result)
    end
    --print("SDKMgr:CallSDKWithReturn2", result)
    return json.decode(result)
end

function SDKMgr:IOSLog(info)
    print("SDKMgr:IOSLog", info)
end

function SDKMgr:IsAndroid()
    return SpecMgrs.system_mgr.platform == SpecMgrs.system_mgr.RuntimePlatform.Android
end

function SDKMgr:IsIOS()
    return SpecMgrs.system_mgr.platform == SpecMgrs.system_mgr.RuntimePlatform.IPhonePlayer
end


--------------------------------------------------------------------------------------
-- test
--------------------------------------------------------------------------------------
function SDKMgr:Test()
    if self.sdk.Gata then
        coroutine.start(function ()
            coroutine.wait(5)
            self:SetClipboard("asdasdasd")
            print("SDKMgr:GetClipboard", self:GetClipboard())
            print("SDKMgr:GetBatteryState", self:GetBatteryState())

            coroutine.wait(2)
            print("SDKMgr:GataIsInitialized", self:GataIsInitialized())
            print("SDKMgr:GetVersion", self:GetVersion())
            print("SDKMgr:GetChannel", self:GetChannel())
            print("SDKMgr:GetAppId", self:GetAppId())
            print("SDKMgr:GetDeviceInfo", self:GetDeviceInfo())

            coroutine.wait(2)
            print("SDKMgr:IsShowUserCenter", self:IsShowUserCenter())
            print("SDKMgr:OnCreateRole", self:OnCreateRole("4", "2"))
            print("SDKMgr:OnSelectRole", self:OnSelectRole("4", "2", 29))

            coroutine.wait(2)
            print("SDKMgr:LogEvent", self:LogEvent("aaa"))
            print("SDKMgr:LogEvent", self:LogEvent("aaa", "ssss"))
            print("SDKMgr:LogEvent", self:LogEvent("aaa", {sadf="sss"}))
            print("SDKMgr:BeginEvent", self:BeginEvent("333"))
            print("SDKMgr:EndEvent", self:IsShowUserCenter("333", {a="b"}))
            print("SDKMgr:LogError", self:LogError("333"))

            coroutine.wait(2)
            print("SDKMgr:SetCollectDeviceInfo", self:SetCollectDeviceInfo(true))
            print("SDKMgr:SetCollectAndroidID", self:SetCollectAndroidID(true))
            print("SDKMgr:SetCanLocation", self:SetCanLocation(true))
            print("SDKMgr:RegistDeviceToken", self:RegistDeviceToken("asdfawef"))
        end)
    end
end

----------------------------------------------------------------------------------------------------------------
-- Gaea sdk
----------------------------------------------------------------------------------------------------------------
local HJConstant = {
    INIT_FAILED = -1,
    INIT_SUCCESS = 0,
    LOGIN_SUCCESS = 1,
    LOGIN_FAILED = 2,
    LOGIN_CANCEL = 3,
    LOGOUT_SUCCESS = 4,
    LOGOUT_FAILED = 5,
    LOGOUT_CANCEL = 6,
    EXIT_SUCCESS = 7,
    EXIT_FAILED = 8,
    EXIT_CANCEL = 9,
    PAY_SUCCESS = 10,
    PAY_FAILED = 11,
    PAY_CANCEL = 12,
    SHARE_SUCCESS = 13,
    SHARE_FAILED = 14,
    FCM_NODATA = 15,
    FCM_YCN = 16,
    FCM_WCN = 17,
    SWITCHLOGIN_SUCCESS = 18,
    SWITCHLOGIN_FAILED = 19,
    SWITCHLOGIN_CANCEL = 20,
    NOTINSTALL_WX = 21,
    EXIT_USERCENTER_SUCCESS = 22,
    FAILED = -1,
    SUCCESS = 0,
    ERROR = -2,
}

function SDKMgr:GaeaInit()
    self:CallSDK("GaeaInit")
end

function SDKMgr:GaeaResult(param)
    if param.code == HJConstant.INIT_SUCCESS then
        self:GaeaInitResult(param)
    elseif param.code == HJConstant.LOGIN_SUCCESS then
        self:LoginResult("hj", param.userId, param)
    elseif param.code == HJConstant.SWITCHLOGIN_SUCCESS then
        self:LoginResult("hj", param.userId, param)
    elseif param.code == HJConstant.LOGOUT_SUCCESS then
        self:LogoutResult("hj", param)
    end
end

function SDKMgr:GaeaInitResult(param)
    ComMgrs.dy_data_mgr.log_data:SendStartUpTranLog(CSConst.CilentProcessType.STARTTRAN_SDKINIT_SUCCEED)
end

function SDKMgr:GaeaLogin()
    self:CallSDK("GaeaLogin")
end

function SDKMgr:GaeaSwitchAccount()
    self:CallSDK("GaeaSwitchAccount")
end

function SDKMgr:GaeaLoginResult(param)
    -- guid = param.guid,
    -- loginToken = param.loginToken,
    -- loginAccount = param.loginAccount,
    self:LoginResult("gaea", param.guid, param)
end

-- ios param:
--   productId    --ios 标识
--   serverId
--   payExt
-- android param:
--   moneyAmount
--   productId
--   productName
--   appName
--   cpInfo
--   appUserId
--   appUserName
--   appUserLevel
--   serverId
--   currency
--   payExt
function SDKMgr:GaeaPay(param)
    self:CallSDK("GaeaPay", param)
end

function SDKMgr:GaeaPayResult(param)
    if self:IsAndroid() then
        return self:PayResult(param.code == HJConstant.PAY_SUCCESS, param)
    else
        return self:PayResult(param.success, param)
    end
end

function SDKMgr:GaeaIsShowUserCenter()
    if self:IsAndroid() then
        return self:CallSDKWithReturn("GaeaIsShowUserCenter").is_show
    else
        return true
    end
end

function SDKMgr:GaeaUserCenter(serverId, roleId)
    self:CallSDK("GaeaUserCenter", {
        serverId = serverId,
        roleId = roleId,
    })
end

function SDKMgr:GaeaForum(param)
    if self:IsIOS() then
        self:CallSDK("GaeaForum", param)
    end
end

function SDKMgr:GaeaService(param)
    if self:IsIOS() then
        self:CallSDK("GaeaService", param)
    end
end

function SDKMgr:GaeaSubmitExtendData(type, data)
    if self:IsAndroid() then
        self:CallSDK("GaeaSubmitExtendData", {type = type, data = data})
    end
end

----------------------------------------------------------------------------------------------------------------
-- Gata sdk
----------------------------------------------------------------------------------------------------------------
local GATACountry = {
    GATA_CS = "GATA_CS",
    GATA_CHINA = "GATA_CHINA",
    GATA_JAPAN = "GATA_JAPAN",
    GATA_KOREA = "GATA_KOREA",
    GATA_EUROPE = "GATA_EUROPE",
}

function SDKMgr:GataInit(appId, channel, country)
    local param = {
        country = self.sdk.Gata.country,
        appId = self.sdk.Gata.appId,
        channel = self.sdk.Gata.channel,
    }
    if self:IsAndroid() then
        self:CallSDK("GataInitGATA", param)
    else
        self:CallSDK("GataInit", param)
    end
end

-- 日志相关 -------------------------
function SDKMgr:GataLogEvent(eventName, content)
    if self:IsAndroid() then
        if content == nil then
            self:CallSDK("GataSetEvent1", {eventName = eventName})
        elseif type(content) == "table" then
            content.eventName = eventName
            self:CallSDK("GataSetEvent3", content)
        else
            self:CallSDK("GataSetEvent2", {eventName = eventName, value = tostring(content)})
        end
    else
        if content == nil then
            self:CallSDK("GataLogEvent1", {eventName = eventName})
        elseif type(content) == "table" then
            content.eventName = eventName
            self:CallSDK("GataLogEvent3", content)
        else
            self:CallSDK("GataLogEvent2", {eventName = eventName, content = tostring(content)})
        end
    end
end

function SDKMgr:GataBeginEvent(eventName)
    if self:IsAndroid() then
        self:CallSDK("GataBeginEvent", {eventName = eventName})
    end
end

function SDKMgr:GataEndEvent(eventName, content)
    if self:IsAndroid() then
        content.eventName = eventName
        self:CallSDK("GataEndEvent", content)
    end
end

function SDKMgr:GataLogError(error)
    if self:IsAndroid() then
        self:CallSDK("GataSetError", {errorLog = error})
    else
        self:CallSDK("GataLogError", {error = error})
    end
end

-- 角色相关 -------------------------
function SDKMgr:GataUserLogin(userId)
    if self:IsAndroid() then
        self:CallSDK("GataGaeaLogin", {userId = userId})
    else
        self:CallSDK("GataUserLogin", {userId = userId})
    end
end

function SDKMgr:GataRoleCreate(roleId, serverId)
    self:CallSDK("GataRoleCreate", {roleId = roleId, serverId = serverId})
end

function SDKMgr:GataRoleLogin(roleId, serverId, level)
    self:CallSDK("GataRoleLogin", {roleId = roleId, serverId = serverId, level = level})
end

function SDKMgr:GataRoleLogout()
    self:CallSDK("GataRoleLogout")
end

function SDKMgr:GataSetLevel(level)
    self:CallSDK("GataSetLevel", {level = level})
end

-- 信息相关 -------------------------
function SDKMgr:GataGetVersion()
    if self:IsAndroid() then
        return self:CallSDKWithReturn("GataGetVersionName").result
    else
        return self.sdk.Gata.appVersion
    end
end

function SDKMgr:GataGetChannel()
    if self:IsAndroid() then
        return self:CallSDKWithReturn("GataGetChannel").result
    else
        return self.sdk.Gata.channel
    end
end

function SDKMgr:GataGetAppId()
    if self:IsAndroid() then
        return self:CallSDKWithReturn("GataGetAppId").result
    else
        return self.sdk.Gata.appId
    end
end

function SDKMgr:GataIsInitialized()
    if self:IsAndroid() then
        return self:CallSDKWithReturn("GataIsInitialized").result
    end
end

function SDKMgr:GataGetDeviceInfo()
    local info
    if self:IsAndroid() then
        info = self:CallSDKWithReturn("GataGetDeviceInfo", {country = self.sdk.Gata.country})
        info.platform = "android"
    elseif self:IsIOS() then
        info = self:CallSDKWithReturn("GataGetDeviceInfo")
        info.platform = "iOS"
    else
        info = {}
        info.platform = "unitypc"
    end
    info.appId = self:GataGetAppId()
    info.appVersion = self:GataGetVersion()
    info.channel = self:GataGetChannel()
    return info
end

-- 功能开关相关 -------------------------
function SDKMgr:GataSetCollectDeviceInfo(enable)
    if self:IsAndroid() then
        self:CallSDK("GataSetCollectDeviceInfo", {isGet = enable})
    end
end

function SDKMgr:GataSetCollectAndroidID(enable)
    if self:IsAndroid() then
        self:CallSDK("GataSetCollectAndroidID", {isGet = enable})
    end
end

function SDKMgr:GataSetCanLocation(enable)
    if self:IsAndroid() then
        self:CallSDK("GataSetCanLocation", {canLocation = enable})
    end
end

function SDKMgr:GataRegistDeviceToken(deviceToken)
    if self:IsAndroid() then
        self:CallSDK("GataRegistDeviceToken", {deviceToken = deviceToken})
    end
end

-- qita


function SDKMgr:GataSetCrashReportingEnabled(enabled)
    self:CallSDK("GataSetCrashReportingEnabled", {enabled = enabled})
end

function SDKMgr:GataLogLocation(latitude, longitude)
    self:CallSDK("GataLogLocation", {latitude = latitude, longitude = longitude})
end


----------------------------------------------------------------------------------------------------------------
-- private
----------------------------------------------------------------------------------------------------------------
function SDKMgr:_ReadSDKInfo()
    local file_name = Application.streamingAssetsPath .. "/sdk_info"
    local file_content = ReadFile(file_name)
    print("SDKMgr:_ReadSDKInfo", file_name, file_content)
    return json.decode(file_content)
end



return SDKMgr
