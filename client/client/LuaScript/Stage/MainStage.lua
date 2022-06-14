local StageBase = require("Stage.StageBase")
local StageConst = require("Stage.StageConst")
local SoundConst = require("Sound.SoundConst")

local MainStage = class("Stage.MainStage", StageBase)

MainStage.need_sync_load = true

function MainStage:DoInit()
    MainStage.super.DoInit(self)
    ComMgrs.dy_data_mgr:ExSetCurStageType(StageConst.STAGE_UnderworldHeadquarters)
    SpecMgrs.ui_mgr:ShowUI("MainSceneUI")
    SpecMgrs.sound_mgr:PlayBGM(SoundConst.SOUND_ID_MainScene)
    --切换场景暂停后在主场景打开
    SpecMgrs.sound_mgr:UnPauseBGMSound()
end

function MainStage:DoDestroy()
    MainStage.super.DoDestroy(self)
end

return MainStage