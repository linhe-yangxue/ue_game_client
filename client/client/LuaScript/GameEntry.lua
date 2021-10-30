require "GlobalTypesAndFuncs"

function ErrorHandle(err_msg)
    PrintError(err_msg)
end

--UnityEngine.Application.targetFrameRate = 60
--UnityEngine.QualitySettings.masterTextureLimit = 0
--UnityEngine.QualitySettings.blendWeights = UnityEngine.BlendWeights.TwoBones

require("CommonMgrs")
require("SpecialMgrs")

CoTimer = SpecMgrs.timer_mgr

require "CommonTypes.strict"

function GameInit()
    math.randomseed(os.time())
    Time:Init()
    ComMgrs:DoInit()
    SpecMgrs:DoInit()
    SpecMgrs.stage_mgr:GotoStage("LoginStage")
end

local function _Update()
    local delta_time = Time.deltaTime
    SpecMgrs.msg_mgr:PreUpdate(delta_time)
    ComMgrs:Update(delta_time)
    SpecMgrs:Update(delta_time)
end

local function _LateUpdate()
    local delta_time = Time.deltaTime
    SpecMgrs:LateUpdate(delta_time)
end

function GameUpdate(delta_time, unscaledDeltaTime)
    Time:SetDeltaTime(delta_time, unscaledDeltaTime)
    xpcall(_Update, ErrorHandle)
end

function GameFixedUpdate(fixedTime)
    Time:SetFixedDelta(fixedTime)
    -- FixedUpdateBeat()
end

function GameLateUpdate(delta_time)
    xpcall(_LateUpdate, ErrorHandle)
    FlushLog()
end


function GameDestroy()
    -- ComMgrs.map_mgr:EndLogic()
    SpecMgrs:DoDestroy()
    ComMgrs:DoDestroy()
    FlushLog()
end