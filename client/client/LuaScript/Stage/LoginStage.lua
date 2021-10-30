local StageBase = require("Stage.StageBase")
local StageConst = require("Stage.StageConst")
local SoundConst = require("Sound.SoundConst")

local LoginStage = class("Stage.LoginStage", StageBase)

LoginStage.need_sync_load = true

function LoginStage:DoInit()
    LoginStage.super.DoInit(self)
    ComMgrs.dy_data_mgr:DoDestroy()
    ComMgrs.dy_data_mgr:DoInit()
    SpecMgrs.guide_mgr:ClearAll()
    ComMgrs.dy_data_mgr:ExSetCurStageType(StageConst.STAGE_Login)
    SpecMgrs.ui_mgr:ShowUI("UpdateUI")
    SpecMgrs.sound_mgr:PlayBGM(SoundConst.SOUND_ID_Login)
end

function LoginStage:DoDestroy()
    LoginStage.super.DoDestroy(self)
end

return LoginStage