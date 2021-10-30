local StageBase = require("Stage.StageBase")
local StageConst = require("Stage.StageConst")
local SoundConst = require("Sound.SoundConst")
local GuideStage = class("Stage.GuideStage", StageBase)

GuideStage.need_sync_load = true

function GuideStage:DoInit()
    GuideStage.super.DoInit(self)
    ComMgrs.dy_data_mgr.guide_data:DoInit()
    ComMgrs.dy_data_mgr:ExSetCurStageType(StageConst.STAGE_Guide)
    SpecMgrs.ui_mgr:ShowUI("GuideBgUI")
    SpecMgrs.sound_mgr:PlayBGM(SoundConst.SOUND_ID_Guide)
end

function GuideStage:DoDestroy()
    GuideStage.super.DoDestroy(self)
end

return GuideStage