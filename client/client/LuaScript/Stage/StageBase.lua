local EventUtil = require ("BaseUtilities.EventUtil")
local StageBase = class("Stage.StageBase")

StageBase.need_sync_load = true

EventUtil.GeneratorEventFuncs(StageBase, "SceneLoadOkEvent")

function StageBase:DoInit()
    self.is_load_ok = false
    self.is_destroy = false
end

function StageBase:Update(delta_time)
    if self.__UpdateEventCbRemove then
        self:__UpdateEventCbRemove()
    end
end

function StageBase:StageStart(scene_name)
    -- if SpecMgrs.config_mgr.is_debug then
    --     self.debug_ui = SpecMgrs.ui_mgr:ShowUI("DebugUI")
    -- end
    -- SpecMgrs.ui_mgr:ShowUI("DebugUI")
    SpecMgrs.ui_mgr:ShowUI("MaskUI")
    if not scene_name then
        return
    end
    self.scene_name = scene_name
    SpecMgrs.stage_mgr:LoadScene(scene_name, self.need_sync_load)
end

function StageBase:LoadSceneProgress(progress)
end

function StageBase:CoLoadSceneOk()
    if self.is_destroy then
        return
    end
    self.is_load_ok = true
    self:LoadSceneOk()
    self:DispatchSceneLoadOkEvent()
    SpecMgrs.res_mgr:ClearUnusedRes()
end

function StageBase:LoadSceneOk()
end

function StageBase:ClearAll()
    if self.__ClearAllEventCb then
        self:__ClearAllEventCb()
    end
    SpecMgrs.ui_mgr:ClearAll()
    ComMgrs.unit_mgr:ClearAll()
    SpecMgrs.sound_mgr:ClearAll()
    SpecMgrs.effect_mgr:ClearAll()
    SpecMgrs.res_mgr:ClearAll()
end

function StageBase:DoDestroy()
    self:ClearAll()
    self.is_destroy = true
end

return StageBase
