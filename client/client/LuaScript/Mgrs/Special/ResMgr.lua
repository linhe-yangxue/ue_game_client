local ResMgr = class("Mgrs.Special.ResMgr")

local kPoolMaxSize = 100
local kPoolListMaxLength = 10
local kPoolTimeOutCount = 30   -- 30s TimeOut

function ResMgr:DoInit()
    self.go_pool = {} --[[name:{time:time_value, list:{go}}]]
    self.res_pool = setmetatable({}, {__mode = "v"})  -- 使用弱表引用，自动gc
    self.loading_res = {}  -- key:{key = key, opt = opt, cb = {}}
    self.loading_opt_index = {}  -- opt:key

    SpecMgrs.event_mgr:AddResourceListener(function(...) return self:_OnLoadingOK(...) end)
    self.gc_timer = SpecMgrs.timer_mgr:AddTimer(function() collectgarbage("step") end, 5, 0)
    self.unload_timer = SpecMgrs.timer_mgr:AddTimer(function() GameResourceMgr.ClearUnusedRes() end, 30, 0)
    self:PreloadRes()
end

function ResMgr:DoDestroy()
    self:ClearAll()
    SpecMgrs.timer_mgr:RemoveTimer(self.gc_timer);
    SpecMgrs.timer_mgr:RemoveTimer(self.unload_timer);
    self.gc_timer = nil
    self.unload_timer = nil
    SpecMgrs.event_mgr:RemoveResourceListener()
end

function ResMgr:PreloadRes()
end

-- GO Pool ---------------------------------------------------

function ResMgr:_GetGameObjectFromPool(go_path)
    local go = nil
    if self.go_pool[go_path] then
        local go_list = self.go_pool[go_path].list
        if go_list then
            local i = #go_list
            if i > 0 then
                go = go_list[i]
                go_list[i] = nil
            end
        end
    end
    return go
end

function ResMgr:_ReturnGameObjectToPool(go)
    local is_new_obj_pool = false
    if not self.go_pool[go.name] then
        self.go_pool[go.name] = {list = {}}
        is_new_obj_pool = true
    end
    local go_pool = self.go_pool[go.name]
    go_pool.time = Time.time
    if #go_pool.list > kPoolListMaxLength then
        GameObject.Destroy(go)
        return
    end
    go:SetParent()
    go:SetActive(false)
    table.insert(go_pool.list, go)
    if is_new_obj_pool then
        local obj_pool_count = 0
        for _, pool in pairs(self.go_pool) do
            obj_pool_count  = obj_pool_count + 1
        end
        if obj_pool_count > kPoolMaxSize then
            self:_ScanToClearGoPool()
        end
    end
end

function ResMgr:_ScanToClearGoPool()
    local del_key_list = {}
    for key, go_pool in pairs(self.go_pool) do
        if Time.time - go_pool.time > kPoolTimeOutCount or #go_pool.list == 0 then
            table.insert(del_key_list, key)
        end
    end
    for _, key in ipairs(del_key_list) do
        local go_pool = self.go_pool[key]
        for _, go in ipairs(go_pool.list) do
            GameObject.Destroy(go)
        end
        self.go_pool[key] = nil
    end
end

-- Res Pool ---------------------------------------------------

function ResMgr:_GetResKey(asset_path, sub_asset_name, asset_type)
    local key = asset_path
    if sub_asset_name and sub_asset_name ~= "" then
        key = key .. ":" .. sub_asset_name
    end
    key = key .. "." .. asset_type
    return key
end

function ResMgr:_GetResFromPool(key)
    return self.res_pool[key]
end

function ResMgr:_AddResToPool(key, res)
    self.res_pool[key] = res
end

function ResMgr:_RemoveResFromPool(res_path)
    -- Note(weiwei) 因为目前发现Assetbundle包头本身占用资源很少，所以此处就先不卸载Assetbundle包了
    self.res_pool[res_path] = nil
end

function ResMgr:_ClearResPool()
    self.res_pool = setmetatable({}, {__mode = "v"})
end

-- Loading list ---------------------------------------------------

function ResMgr:_GetLoadingByKey(key)
    return self.loading_res[key]
end

function ResMgr:_GetLoadingByOpt(opt)
    local key = self.loading_opt_index[opt]
    return key and self:_GetLoadingByKey(key)
end

function ResMgr:_AddLoadingOpt(key, opt)
    local loading = {
        key = key,
        opt = opt,
        cb = {},
    }
    self.loading_res[key] = loading
    self.loading_opt_index[opt] = key
    return loading
end

function ResMgr:_OnLoadingOK(opt, asset)
    local loading = self:_GetLoadingByOpt(opt)
    if not loading then return end
    local key = loading.key
    self:_AddResToPool(key, asset)
    self.loading_res[key] = nil
    self.loading_opt_index[opt] = nil
    for _, cb in ipairs(loading.cb) do
        xpcall(cb, ErrorHandle, asset)
    end
end

-- inner Loading interface ---------------------------------------------------

function ResMgr:_LoadAssetAsync(asset_path, asset_type_name, callback, cb_owner)
    local key = self:_GetResKey(asset_path, nil, asset_type_name)
    local asset = self:_GetResFromPool(key)
    if asset then
        if callback then callback(cb_owner, asset) end
        return
    end
    local loading = self:_GetLoadingByKey(key)
    if not loading then
        loading = self:_AddLoadingOpt(key, GameResourceMgr.LoadAssetAsync(asset_path, asset_type_name))
    end
    if callback then
        table.insert(loading.cb, function(asset)
            callback(cb_owner, asset)
        end)
    end
end

function ResMgr:_LoadSubAssetAsync(asset_path, sub_asset_name, asset_type_name, callback, cb_owner)
    local key = self:_GetResKey(asset_path, sub_asset_name, asset_type_name)
    local asset = self:_GetResFromPool(key)
    if asset then
        if callback then callback(cb_owner, asset) end
        return
    end
    local loading = self:_GetLoadingByKey(key)
    if not loading then
        loading = self:_AddLoadingOpt(key, GameResourceMgr.LoadSubAssetAsync(asset_path, asset_type_name, asset_type_name))
    end
    if callback then
        table.insert(loading.cb, function(asset)
            callback(cb_owner, asset)
        end)
    end
end

function ResMgr:_LoadAssetSync(asset_path, asset_type_name)
    local key = self:_GetResKey(asset_path, nil, asset_type_name)
    local asset = self:_GetResFromPool(key)
    if asset then
        return asset
    end
    asset = GameResourceMgr.LoadAssetSync(asset_path, asset_type_name)
    if asset then
        self:_AddResToPool(key, asset)
    end
    return asset
end

function ResMgr:_LoadSubAssetSync(asset_path, sub_asset_name, asset_type_name)
    local key = self:_GetResKey(asset_path, sub_asset_name, asset_type_name)
    local asset = self:_GetResFromPool(key)
    if asset then
        return asset
    end
    asset = GameResourceMgr.LoadSubAssetSync(asset_path, sub_asset_name, asset_type_name)
    if asset then
        self:_AddResToPool(key, asset)
    end
    return asset
end

function ResMgr:_CoLoadAsset(asset_path, asset_type_name)
    local key = self:_GetResKey(asset_path, nil, asset_type_name)
    local asset = self:_GetResFromPool(key)
    if asset then
        return asset
    end
    local co = coroutine.running()
    local asset
    self:_LoadAssetAsync(asset_path, asset_type_name, function(_, cb_asset)
        asset = cb_asset
        coroutine.continue(co)
    end)
    coroutine.pause()
    return asset
end

function ResMgr:_CoLoadSubAsset(asset_path, sub_asset_name, asset_type_name)
    local key = self:_GetResKey(asset_path, sub_asset_name, asset_type_name)
    local asset = self:_GetResFromPool(key)
    if asset then
        return asset
    end
    local co = coroutine.running()
    local asset
    self:_LoadSubAssetAsync(asset_path, sub_asset_name, asset_type_name, function(_, cb_asset)
        asset = cb_asset
        coroutine.continue(co)
    end)
    coroutine.pause()
    return asset
end

--------- interface defines begin --------
function ResMgr:GetGameObjectAsync(go_path, callback, cb_owner)
    local go = self:_GetGameObjectFromPool(go_path)
    if go then
        callback(cb_owner, go)
    else
        self:_LoadAssetAsync(go_path, "GameObject", function(_, asset)
                go = GameObject.Instantiate(asset)
                GameObject.DontDestroyOnLoad(go)
                go.name = go_path
                callback(cb_owner, go)
            end)
    end
end

function ResMgr:GetPrefabAsync(prefab_path, callback, cb_owner)
    self:_LoadAssetAsync(prefab_path, "GameObject", callback, cb_owner)
end

function ResMgr:GetAudioClipAsync(audio_path, callback, cb_owner)
    self:_LoadAssetAsync(audio_path, "AudioClip", callback, cb_owner)
end

function ResMgr:GetSpriteAsync(sp_path, sp_name, callback, cb_owner)
    self:_LoadSubAssetAsync(sp_path, sp_name, "Sprite", callback, cb_owner)
end

function ResMgr:GetTextAssetAsync(ta_path, callback, cb_owner)
    local new_cb = function(cb_owner, asset) return callback(cb_owner, asset.bytes) end
    self:_LoadAssetAsync(ta_path, "TextAsset", new_cb, cb_owner)
end

function ResMgr:GetShaderAsync(sd_path, callback, cb_owner)
    self:_LoadAssetAsync(sd_path, "Shader", callback, cb_owner)
end

function ResMgr:GetMaterialAsync(sd_path, callback, cb_owner)
    self:_LoadAssetAsync(sd_path, "Material", callback, cb_owner)
end

-- 加载资源集，全部加载完才会回调
-- path_set = {path=type, ...}， callback({path=asset, ...})
function ResMgr:GetAssetSetAsync(path_set, callback, cb_owner)
    local loading_count = 0
    local assets = {}
    for path, type in pairs(path_set) do
        loading_count = loading_count + 1
    end
    for path, type in pairs(path_set) do
        self:_LoadAssetAsync(path, type, function(_, asset)
            assets[path] = asset
            loading_count = loading_count - 1
            if loading_count == 0 then
                callback(cb_owner, assets)
            end
        end)
    end
end

function ResMgr:GetGameObjectSync(go_path)
    local go = self:_GetGameObjectFromPool(go_path)
    if go then
        return go
    end
    local asset = self:_LoadAssetSync(go_path, "GameObject")
    go = GameObject.Instantiate(asset)
    GameObject.DontDestroyOnLoad(go)
    go.name = go_path
    return go
end

function ResMgr:GetPrefabSync(prefab_path)
    return self:_LoadAssetSync(prefab_path, "GameObject")
end

function ResMgr:GetAudioClipSync(audio_path)
    return self:_LoadAssetSync(audio_path, "AudioClip")
end

function ResMgr:GetSpriteSync(sp_path, sp_name)
    return self:_LoadSubAssetSync(sp_path, sp_name, "Sprite")
end

function ResMgr:GetAnimatorController(ac_path)
    return self:_LoadAssetSync(ac_path, "RuntimeAnimatorController")
end

function ResMgr:GetTextAssetSync(ta_path)
    return self:_LoadAssetSync(ta_path, "TextAsset").bytes
end

function ResMgr:GetShaderSync(sd_path)
    return self:_LoadAssetSync(sd_path, "Shader")
end

function ResMgr:GetMaterialSync(sd_path)
    return self:_LoadAssetSync(sd_path, "Material")
end

-- 加载资源集，全部加载完才会回调
-- path_set = {path=type, ...}， return {path=asset, ...}
function ResMgr:GetAssetSetSync(path_set)
    local loading_count = 0
    local assets = {}
    for path, type in pairs(path_set) do
        assets[path] = self:_LoadAssetSync(path, type)
    end
    return assets
end

function ResMgr:CoGetGameObject(go_path)
    local go = self:_GetGameObjectFromPool(go_path)
    if go then
        return go
    end
    local asset = self:_CoLoadAsset(go_path, "GameObject")
    go = GameObject.Instantiate(asset)
    GameObject.DontDestroyOnLoad(go)
    go.name = go_path
    return go
end

function ResMgr:CoGetPrefab(prefab_path)
    return self:_CoLoadAsset(prefab_path, "GameObject")
end

function ResMgr:CoGetAudioClip(audio_path)
    return self:_CoLoadAsset(audio_path, "AudioClip")
end

function ResMgr:CoGetSprite(sp_path, sp_name)
    return self:_CoLoadSubAsset(sp_path, sp_name, "Sprite")
end

function ResMgr:CoGetTextAsset(ta_path)
    return self:_CoLoadAsset(ta_path, "TextAsset").bytes
end

function ResMgr:CoGetShader(sd_path)
    return self:_CoLoadAsset(sd_path, "Shader")
end

function ResMgr:CoGetMaterial(sd_path)
    return self:_CoLoadAsset(sd_path, "Material")
end

-- 加载资源集，全部加载完才会回调
-- path_set = {path=type, ...}， return {path=asset, ...}
function ResMgr:CoGetAssetSet(path_set)
    local co = coroutine.running()
    local assets
    self:LoadAssetSetAsync(path_set, function(_, cb_assets)
        assets = cb_assets
        coroutine.continue(co)
    end)
    coroutine.pause()
    return assets
end

function ResMgr:LoadSceneAsync(scene_name, progress_call_back, load_ok_call_back, cb_owner, is_addivite)
    local load_check_func = function()
        self:CoLoadScene(scene_name, progress_call_back, cb_owner, is_addivite)
            if load_ok_call_back then
                load_ok_call_back(cb_owner)
            end
        end
    return coroutine.start(load_check_func)
end

function ResMgr:LoadSceneSync(scene_name, is_addivite)
    is_addivite = is_addivite or false
    GameResourceMgr.LoadSceneSync(scene_name, is_addivite)
end

function ResMgr:CoLoadScene(scene_name, progress_call_back, cb_owner, is_addivite)
    is_addivite = is_addivite or false
    local async_op = GameResourceMgr.LoadSceneAsync(scene_name, is_addivite)
    while not async_op.isDone do
        if progress_call_back then
            progress_call_back(cb_owner, async_op.progress)
        end
        coroutine.step()
    end
    progress_call_back(cb_owner, 1)
    coroutine.step()
end

function ResMgr:ReturnGameObject(go, no_need_to_pool)
    if no_need_to_pool then
        -- Note(weiwei) 对于直接消耗的go(一般用于ui),直接把其prefab_res也从res_pool中删除
        self:_RemoveResFromPool(go.name)
        GameObject.Destroy(go)
    else
        self:_ReturnGameObjectToPool(go)
    end
end

function ResMgr:ClearUnusedRes()
    LuaGC()
    GameResourceMgr.GC()
    GameResourceMgr.ClearUnusedRes()
--    SpecMgrs.timer_mgr:AddTimer(function ()
--        return GameResourceMgr.GC()
--    end, 0, 1)
end

function ResMgr:ClearAll()
    for key, go_pool in pairs(self.go_pool) do
        for _, go in ipairs(go_pool.list) do
            GameObject.Destroy(go)
        end
    end
    self.go_pool = {}
    self:_ClearResPool()
    self:ClearUnusedRes()
end
--------- interface defines end --------
return ResMgr