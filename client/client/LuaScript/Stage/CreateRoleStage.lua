local StageBase = require("Stage.StageBase")
local StageConst = require("Stage.StageConst")
local SoundConst = require("Sound.SoundConst")

local CreateRoleStage = class("Stage.CreateRoleStage", StageBase)

CreateRoleStage.need_sync_load = true

function CreateRoleStage:DoInit()
    CreateRoleStage.super.DoInit(self)
    ComMgrs.dy_data_mgr:ExSetCurStageType(StageConst.STAGE_CreateRole)
    SpecMgrs.ui_mgr:ShowUI("CreateRoleUI")
end

function CreateRoleStage:DoDestroy()
    CreateRoleStage.super.DoDestroy(self)
end

return CreateRoleStage