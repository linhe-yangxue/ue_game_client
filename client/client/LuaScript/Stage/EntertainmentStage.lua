local StageBase = require("Stage.StageBase")
local StageConst = require("Stage.StageConst")
local SoundConst = require("Sound.SoundConst")

local EntertainmentStage = class("Stage.EntertainmentStage", StageBase)

EntertainmentStage.need_sync_load = true

function EntertainmentStage:DoInit()
    EntertainmentStage.super.DoInit(self)
    ComMgrs.dy_data_mgr:ExSetCurStageType(StageConst.STAGE_EntertainmentCompany)
    SpecMgrs.ui_mgr:ShowUI("EntertainmentUI")
    SpecMgrs.ui_mgr:ShowUI("GameMenuUI")
    --切换到娱乐中心后暂停BGM
    SpecMgrs.sound_mgr:PauseBGMSound()
end

function EntertainmentStage:DoDestroy()
    EntertainmentStage.super.DoDestroy(self)
end

return EntertainmentStage