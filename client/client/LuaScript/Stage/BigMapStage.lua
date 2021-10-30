local StageBase = require("Stage.StageBase")
local StageConst = require("Stage.StageConst")
local SoundConst = require("Sound.SoundConst")

local BigMapStage = class("Stage.BigMapStage", StageBase)

BigMapStage.need_sync_load = true

function BigMapStage:DoInit()
    BigMapStage.super.DoInit(self)
    ComMgrs.dy_data_mgr:ExSetCurStageType(StageConst.STAGE_BigMap)
    SpecMgrs.ui_mgr:ShowUI("BigMapUI")
    SpecMgrs.ui_mgr:ShowUI("GameMenuUI")
    SpecMgrs.sound_mgr:PlayBGM(SoundConst.SOUND_ID_BigMap)
end

function BigMapStage:DoDestroy()
    BigMapStage.super.DoDestroy(self)
end

return BigMapStage