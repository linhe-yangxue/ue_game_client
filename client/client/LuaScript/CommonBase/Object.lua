local EventUtil = require ("BaseUtilities.EventUtil")

local Object = class("CommonBase.Object")

Object.need_sync_load = false  -- 是否资源是同步加载
Object.direct_destroy = false  -- 是否放到缓冲池中，为true时直接销毁, 并把资源也从ResMgr资源池中删掉

EventUtil.GeneratorEventFuncs(Object, "GoLoadedOkEvent")

function Object:DoInit()
    self.is_res_ok = false
    self.is_loading_res = false
    self.is_destroy = false
    self.is_visible = true
end

function Object:DestroyRes()
    self.is_res_ok = false
    self.is_loading_res = false
    if self.go then
        SpecMgrs.res_mgr:ReturnGameObject(self.go, self.direct_destroy)
        self.go = nil
    end
    if self._load_co then
        coroutine.clear(self._load_co)
        self._load_co = nil
    end
end

function Object:DoDestroy()
    self.is_destroy = true
    self:DestroyRes()
    if self.__ClearAllEventCb then
        self:__ClearAllEventCb()
    end
end

function Object:DoLoadGo(res_path)
    if self.need_sync_load then
        self:LoadGoSync(res_path)
    else
        self:LoadGoAsync(res_path)
    end
end

function Object:_CoLoadGoAsync(res_path)
    local go = SpecMgrs.res_mgr:CoGetGameObject(res_path)
    self:_LoadGoOK(go)
end

function Object:LoadGoAsync(res_path)
    self.is_res_ok = false
    self.is_loading_res = true
    -- Note(weiwei) 直接清理co可能导致一定的资源浪费，加载后的资源要在下一次UnloadUnuseRes中销毁
    if self._load_co then
        coroutine.clear(self._load_co)
    end
    self._load_co = coroutine.start(Object._CoLoadGoAsync, self, res_path)
end

function Object:LoadGoSync(res_path)
    self.is_res_ok = false
    self.is_loading_res = true
    if self._load_co then
        coroutine.clear(self._load_co)
    end
    local go = SpecMgrs.res_mgr:GetGameObjectSync(res_path)
    -- self._load_co = coroutine.start(Object._LoadGoOK, self, go)
    self:_LoadGoOK(go)
    return go
end

function Object:_LoadGoOK(res_go)
    self._load_co = nil
    if self.is_destroy then
        SpecMgrs.res_mgr:ReturnGameObject(res_go)
        return
    end
    self.go = res_go
    self.is_res_ok = true
    self.is_loading_res = false
    self:OnGoLoadedOk(res_go)
    self:OnGoLoadedOkEnd()
    self:DispatchGoLoadedOkEvent()
end

-- Note(weiwei) 此函数是给子类重载的，并且因为在Coroutine中调用，因此可以用wait，以及ResMgr的CoLoad系列函数等等
function Object:OnGoLoadedOk(res_go)
    self.go:SetActive(self.is_visible)
end

-- Note(weiwei) 此函数是给子类重载的，并且因为在Coroutine中调用，因此可以用wait，以及ResMgr的CoLoad系列函数等等
function Object:OnGoLoadedOkEnd()
end

function Object:Update(delta_time)
    if self.__UpdateEventCbRemove then
        self:__UpdateEventCbRemove()
    end
end

function Object:SetVisible(is_visible)
    self:_SetVisible(is_visible)
end

function Object:_SetVisible(is_visible)
    self.is_visible = is_visible
    if self.go then
        self.go:SetActive(is_visible)
    end
end

function Object:IsVisible()
    return self.is_visible
end

function Object:IsResOkAndVisible()
    return self.is_res_ok and self.is_visible
end

function Object:IsDestroy()
    return self.is_destroy
end

return Object
