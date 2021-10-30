local EventUtil = require("BaseUtilities.EventUtil")

local StageMgr = class("Mgrs.Special.StageMgr")

EventUtil.GeneratorEventFuncs(StageMgr, "StageSceneLoadOkEvent")
EventUtil.GeneratorEventFuncs(StageMgr, "StageChangeEvent")

function StageMgr:DoInit()
    self._cur_stage = nil
    self._cur_scene_name = nil
    self._cur_load_co = nil
    self._cur_new_load_request = nil
end

function StageMgr:GotoStage(stage_name, scene_name, ...)
    self._is_enter_same_scene = scene_name and scene_name == self._cur_scene_name
    if self._cur_stage then
        self._cur_stage:DoDestroy()
    end
    local stage_cls = require("Stage." .. stage_name)
    self._cur_stage = stage_cls.New()
    self._cur_stage:DoInit()
    self._cur_stage:RegisterSceneLoadOkEvent("StageMgr", self.DispatchStageSceneLoadOkEvent, self)
    self._cur_stage:StageStart(scene_name, ...)
    self:DispatchStageChangeEvent()
end

function StageMgr:LoadScene(scene_name, need_sync_load)
    if self._cur_load_co then
        -- Note(weiwei) 等待旧的场景加载完才进入新的加载
        self._cur_new_load_request = function() self:_LoadScene(scene_name, need_sync_load) end
    else
        self:_LoadScene(scene_name, need_sync_load)
    end
end

function StageMgr:_LoadScene(scene_name, need_sync_load)
    self._cur_new_load_request = nil
    if need_sync_load then
        self:_SyncLoadScene(scene_name)
    else
        self:_AsyncLoadScene(scene_name)
    end
end

function StageMgr:_AsyncLoadScene(scene_name)
    if not self._is_enter_same_scene then
        self._loading_ui = SpecMgrs.ui_mgr:ShowUI("LoadingUI")
    end
    self._cur_load_co = coroutine.start(self._CoLoadScene, self, scene_name)
end

function StageMgr:_CoLoadScene(scene_name)
    self._cur_scene_name = scene_name
    if not self._is_enter_same_scene then
        SpecMgrs.res_mgr:CoLoadScene(scene_name, self._LoadSceneProgress, self)
    end
    self:_LoadSceneOk()
end

function StageMgr:_LoadSceneProgress(progress)
    if self._loading_ui then
        self._loading_ui:SetProgress(progress)
    end
    if self._cur_new_load_request then
        return
    end
    self._cur_stage:LoadSceneProgress(progress)
end

function StageMgr:_SyncLoadScene(scene_name)
    self._cur_scene_name = scene_name
    if not self._is_enter_same_scene then
        SpecMgrs.res_mgr:LoadSceneSync(scene_name)
    end
    -- Note(weiwei)此处为了和co异步加载统一，这样可以使LoadSceneOk都是统一由Coroutine运行，不需要区别对待
    self._cur_load_co = coroutine.start(self._LoadSceneOk, self)
end

function StageMgr:_LoadSceneOk()
    self._cur_load_co = nil
    if self._cur_new_load_request then
        return
    end
    self._cur_stage:CoLoadSceneOk()
    self:DestroyLoadingUI()
end

function StageMgr:DestroyLoadingUI()
    if self._loading_ui then
        SpecMgrs.ui_mgr:DestroyUI(self._loading_ui)
        self._loading_ui = nil
    end
end

function StageMgr:Update(delta_time)
    if self.__UpdateEventCbRemove then
        self:__UpdateEventCbRemove()
    end
    if self._cur_stage then
        self._cur_stage:Update(delta_time)
    end
    if self._cur_new_load_request and not self._cur_load_co then
        self._cur_new_load_request()
    end
end

function StageMgr:DoDestroy()
    if self._cur_stage then
        self._cur_stage:DoDestroy()
        self._cur_stage = nil
    end
    if self.__ClearAllEventCb then
        self:__ClearAllEventCb()
    end
end

function StageMgr:GetCurStage()
    return self._cur_stage
end

return StageMgr
