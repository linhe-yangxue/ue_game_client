using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine.SceneManagement;
using UnityEngine.U2D;

namespace AssetBundles {
    // AssetBundleManager Utils Partial
    [UnityEngine.Scripting.Preserve]
    public static partial class AssetBundleManager {
        public delegate void AssetLoadOkFuncType(ABLoadOptBase opt, object asset);
        static public AssetLoadOkFuncType OnAssetLoadOk;
        public enum LogType { Debug, Info, Warning, Error };
        const LogType _cur_log_type_ = LogType.Info;
        static List<ABLoadOptBase> _sLoadOKList = new List<ABLoadOptBase>();
        const float kAccumUpdateLimit = 50;
        static float _sAccumUpdateTime = kAccumUpdateLimit;

        public static AssetBundleSet sInnerSet = null;
        public static AssetBundleSet sExternalSet = null;

        static Dictionary<string, AssetBundle> _sABDict = new Dictionary<string, AssetBundle>();
        static LinkedList<ABLoadOptBase> _sLoadingOpts = new LinkedList<ABLoadOptBase>();

        static bool _need_unload = false;
        static AsyncOperation _unload_handle = null;


        public static int atlas_variant = 0;
        public static string lang_variant;

        private static void _Log(string ctx, LogType log_type = LogType.Debug) {
            if (log_type < _cur_log_type_) {
                return;
            }
            if (log_type == LogType.Error) {
                Debug.LogError(ctx);
            } else if (log_type == LogType.Warning) {
                Debug.LogWarning(ctx);
            } else {
                Debug.Log(ctx);
            }
        }
        private static void _LogError(string ctx) {
            _Log(ctx, LogType.Error);
        }
        private static void _LogWarning(string ctx) {
            _Log(ctx, LogType.Warning);
        }
        private static void _LogInfo(string ctx) {
            _Log(ctx, LogType.Info);
        }
        // Dump info
        static public void DumpAssetBundleInfo() {
            _LogInfo(string.Format("============= DumpAssetBundleInfo, info count {0} =============", _sABDict.Count));
            foreach(var KeyValue in _sABDict) {
                _LogInfo(string.Format("info: {0},{1},{2}", KeyValue.Key, KeyValue.Value));
            }
            _LogInfo(string.Format("============= _sCurABProcessingOpts, count {0} ===========", _sLoadingOpts.Count));
        }

        static public void DumpAssetBundleInfoByName(string ab_name) {
            _LogInfo(string.Format("============= DumpAssetBundleInfo:{0} Begin =============", ab_name));
            if (_sABDict.ContainsKey(ab_name)) {
                var value = _sABDict[ab_name];
                _LogInfo(string.Format("Info: {0}, {1}, {2}", ab_name, value));
            } else {
                _LogInfo(string.Format("======== Not Contail Assetbundle:{0} in Load Infos", ab_name));
            }
            _LogInfo(string.Format("============= DumpAssetBundleInfo:{0} End =============", ab_name));
        }

        public static void Initialize() {
            // atlas
            SpriteAtlasManager.atlasRequested -= RequestAtlas;
            SpriteAtlasManager.atlasRequested += RequestAtlas;
#if UNITY_EDITOR
            _LogInfo("Simulation Mode: " + (AssetBundleConst.simulate_mode ? "Enabled" : "Disabled"));
            // If we're in Editor simulation mode, we don't need the manifest assetBundle.
            if (AssetBundleConst.simulate_mode) return;
#endif
            // Inner
            sInnerSet = new AssetBundleSet(AssetBundleConst.inner_path);
            Debug.LogWarning("Initialize:" + AssetBundleConst.inner_path);
            if (sInnerSet.ReadVersion()) {
                sInnerSet.ReadSet();
                sInnerSet.ReadManifest();
            } else {
                sInnerSet = null;
            }
            // External
            sExternalSet = new AssetBundleSet(AssetBundleConst.external_path);
            if (sExternalSet.ReadVersion() && sExternalSet.svn_version_ > sInnerSet.svn_version_) {
                sExternalSet.ReadSet();
                sExternalSet.ReadManifest();
            } else {
                sExternalSet = null;
            }
        }

        static void RequestAtlas(string tag, System.Action<SpriteAtlas> callback) {
            string ab_name = tag.Replace("_pack--", "").Replace("--", ".").ToLower() + ".abd";
            string asset_name = tag;
            if (atlas_variant > 0) {
                asset_name = asset_name.Replace("_pack", "_pack_low");
            }
            var atlas = LoadAssetSync(ab_name, asset_name, typeof(SpriteAtlas)) as SpriteAtlas;
            callback(atlas);
        }

        public static void Update() {
            for (var node = _sLoadingOpts.First; node != null; ) {
                var cur_node = node;
                node = node.Next;
                if (cur_node.Value.IsDone()) {
                    _sLoadingOpts.Remove(cur_node);
                    _sLoadOKList.Add(cur_node.Value);
                }
            }
            if (_sLoadOKList.Count > 0) {
                GameEntry game = GameEntry.Instance;
                foreach (var opt in _sLoadOKList) {
                    if (opt.callback != null) opt.callback(opt.asset);
                    if (OnAssetLoadOk != null) OnAssetLoadOk(opt, opt.asset);
                    if (game != null && game.is_inited) {
                        GameEventMgr.GetInstance().GenerateEvent(GameEventMgr.ET_Resource, null, opt, opt.asset);
                    }
                }
                _sLoadOKList.Clear();
            }
			#if UNITY_EDITOR
            if (!AssetBundleConst.simulate_mode) {
            #endif
                _sAccumUpdateTime -= Time.deltaTime;
                if (_sAccumUpdateTime <= 0) {
                    _sAccumUpdateTime = kAccumUpdateLimit;
                    // DumpAssetBundleInfo();
                }
			#if UNITY_EDITOR
            }
            #endif
            _TryClearUnusedRes();
        }

        public static string GetABMD5(string ab_name) {
            if (sExternalSet != null) {
                return sExternalSet.GetMD5(ab_name);
            }
            return sInnerSet.GetMD5(ab_name);
        }

        // Asset Bundle Inteface Defines Begin -----------------------------
        public static AssetBundle LoadAssetBundle(string ab_name) {
#if UNITY_EDITOR
            if (AssetBundleConst.simulate_mode) return null;
#endif
            if (sInnerSet == null && sExternalSet == null) {
                _LogError("Please Initialize MD5Set By calling AssetbundleManage.Initialize!!");
                return null;
            }
            return _LoadAssetBundleInner(ab_name);
        }

        static AssetBundle _LoadAssetBundleInner(string ab_name) {
            AssetBundle ab = null;
            if (_sABDict.TryGetValue(ab_name, out ab)) {
                return ab;
            }
            var path = _GetABPath(ab_name);
            ab = AssetBundle.LoadFromFile(path);
            _sABDict.Add(ab_name, ab);
            if (ab == null) {
                _LogError("Load asset bundle failed: " + path);
            }
            var use_set = sExternalSet != null ? sExternalSet : sInnerSet;
            string[] deps = use_set.manifest_.GetAllDependencies(ab_name);
            for (int i = 0; i < deps.Length; ++i) {
                deps[i] = _RemapVariantName(deps[i]);
                _LoadAssetBundleInner(deps[i]);
            }
            return ab;
        }
        static string _RemapVariantName(string ab_name) {
            foreach (var name in AssetBundleConst.lang_abname)
            {
                if(ab_name.Contains(name) && !ab_name.EndsWith(lang_variant))
                {
                    return ab_name + "." + lang_variant;
                }
            }
            return ab_name;
        }
        static string _GetABPath(string ab_name) {
            if (sExternalSet != null && sExternalSet.GetMD5(ab_name) != sInnerSet.GetMD5(ab_name)) {
                return AssetBundleConst.external_path + ab_name;
            } else {
                return AssetBundleConst.inner_path + ab_name;
            }
        } 
        // Asset Bundle Inteface Defines End -----------------------------

        // Asset Load Async Inteface Defines Begin -----------------------------
        public static ABLoadOptBase LoadAssetAsync(string ab_name, string asset_name, System.Type asset_type, ABLoadOptBase.Callback callback = null) {
            ABLoadOptBase load_opt = null;
            ab_name = _RemapVariantName(ab_name);
            #if UNITY_EDITOR
            if (AssetBundleConst.simulate_mode) {
                string[] asset_paths = AssetDatabase.GetAssetPathsFromAssetBundleAndAssetName(ab_name, asset_name);
                if (asset_paths.Length == 0) {
                    _LogError(string.Format("There is no Asset name:{0} type:{1} in Assetbundle:{2}", asset_name, asset_type, ab_name));
                    return null;
                }
                Object asset = AssetDatabase.LoadMainAssetAtPath(asset_paths[0]);
                load_opt = new ABLoadSimulationOpt(asset);
            } else
            #endif
            {
                var ab = LoadAssetBundle(ab_name);
                load_opt = new ABLoadOptBase(ab.LoadAssetAsync(asset_name, asset_type));
            }
            load_opt.callback = callback;
            _sLoadingOpts.AddLast(load_opt);
            return load_opt;
        }

        public static ABLoadOptBase LoadSubAssetAsync(string ab_name, string asset_name, string sub_asset_name, System.Type asset_type, ABLoadOptBase.Callback callback = null) {
            ABLoadOptBase load_opt = null;
            ab_name = _RemapVariantName(ab_name);
            sub_asset_name = sub_asset_name.ToLower();
            #if UNITY_EDITOR
            if (AssetBundleConst.simulate_mode) {
                string[] asset_paths = AssetDatabase.GetAssetPathsFromAssetBundleAndAssetName(ab_name, asset_name);
                if (asset_paths.Length == 0) {
                    _LogError(string.Format("There is no Asset name:{0} in Assetbundle:{1}", asset_name, ab_name));
                    return null;
                }
                Object[] assets = AssetDatabase.LoadAllAssetsAtPath(asset_paths[0]);
                Object asset = null;
                foreach(var at in assets) {
                    if (at.GetType() == asset_type && at.name.ToLower() == sub_asset_name) {
                        asset = at;
                        break;
                    }
                }
                load_opt = new ABLoadSimulationOpt(asset);
            } else
            #endif
            {
                var ab = LoadAssetBundle(ab_name);
                load_opt = new ABLoadSubAssetOpt(ab.LoadAssetAsync(asset_name, asset_type), sub_asset_name, asset_type);
            }
            load_opt.callback = callback;
            _sLoadingOpts.AddLast(load_opt);
            return load_opt;
        }
        public static ABLoadOptBase LoadSceneAsync(string ab_name, string scene_name, bool is_additive, ABLoadOptBase.Callback callback = null) {
            ABLoadOptBase opt = null;
            ab_name = _RemapVariantName(ab_name);
            #if UNITY_EDITOR
            if (AssetBundleConst.simulate_mode) {
                opt = new ABLoadOptBase(SceneManager.LoadSceneAsync(scene_name, is_additive ? LoadSceneMode.Additive : LoadSceneMode.Single));
            } else
            #endif
            {
                LoadAssetBundle(ab_name);
                opt = new ABLoadOptBase(SceneManager.LoadSceneAsync(scene_name, is_additive ? LoadSceneMode.Additive : LoadSceneMode.Single));
            }
            opt.callback = callback;
            _sLoadingOpts.AddLast(opt);
            return opt;
        }

        // Asset Load Async Inteface Defines End -----------------------------

        // Asset Load Sync Inteface Defines Begin -------------


        public static Object LoadAssetSync(string ab_name, string asset_name, System.Type asset_type) {
            Object asset = null;
            ab_name = _RemapVariantName(ab_name);
            #if UNITY_EDITOR
            if (AssetBundleConst.simulate_mode) {
                string[] asset_paths = AssetDatabase.GetAssetPathsFromAssetBundleAndAssetName(ab_name, asset_name);
                if (asset_paths.Length == 0) {
                    _LogError(string.Format("There is no Asset name:{0} in Assetbundle:{1}", asset_name, ab_name));
                    return null;
                }
                asset = AssetDatabase.LoadMainAssetAtPath(asset_paths[0]);
            } else
            #endif
            {
                try {
                    var ab = LoadAssetBundle(ab_name);
                    asset = ab.LoadAsset(asset_name, asset_type);
                } catch (System.Exception e) {
                    _LogError(string.Format("Can't Load {0} for AssetBundle {1} In LoadAssetSync, Error:{2}", asset_name, ab_name, e));
                }
            }
            return asset;
        }
        public static Object LoadSubAssetSync(string ab_name, string asset_name, string sub_asset_name, System.Type asset_type) {
            Object asset = null;
            ab_name = _RemapVariantName(ab_name);
            sub_asset_name = sub_asset_name.ToLower();
            #if UNITY_EDITOR
            if (AssetBundleConst.simulate_mode) {
                string[] asset_paths = AssetDatabase.GetAssetPathsFromAssetBundleAndAssetName(ab_name, asset_name);
                if (asset_paths.Length == 0) {
                    _LogError(string.Format("There is no Asset name:{0} in Assetbundle:{1}", asset_name, ab_name));
                    return null;
                }
                Object[] assets = AssetDatabase.LoadAllAssetsAtPath(asset_paths[0]);
                foreach(var at in assets) {
                    if (at.GetType() == asset_type && at.name.ToLower() == sub_asset_name) {
                        asset = at;
                        break;
                    }
                }
            } else
            #endif
            {
                try {
                    AssetBundle ab = LoadAssetBundle(ab_name);
                    Object[] assets = ab.LoadAssetWithSubAssets(asset_name, asset_type);
                    foreach(var at in assets) {
                        if (at.name.ToLower() == sub_asset_name) {
                            asset = at;
                            break;
                        }
                    }
                } catch (System.Exception e) {
                    _LogError(string.Format("Can't Load {0} for AssetBundle {1} In LoadSubAssetSync, Error:{2}", asset_name, ab_name, e));
                }
            }
            return asset;
        }
        public static void LoadSceneSync(string ab_name, string scene_name, bool is_additive = false) {
            ab_name = _RemapVariantName(ab_name);
            #if UNITY_EDITOR
            if (AssetBundleConst.simulate_mode) {
                SceneManager.LoadScene(scene_name, is_additive ? LoadSceneMode.Additive : LoadSceneMode.Single);
            } else
            #endif
            {
                LoadAssetBundle(ab_name);
                SceneManager.LoadScene(scene_name, is_additive ? LoadSceneMode.Additive : LoadSceneMode.Single);
            }
        }
        // Asset Load Sync Inteface Defines End -------------

    // AssetBundleManager Unload funcs Partial
        public static void ClearUnusedRes() {
            _need_unload = true;
            _unload_handle = null;
        }

        public static bool IsClearUnusedResOK() {
            if (_need_unload == false && _unload_handle == null) {
                return true;
            }
            return false;
        }

        static void _TryClearUnusedRes() {
            if (_need_unload && _sLoadingOpts.Count == 0) {
                _need_unload = false;
                _unload_handle = Resources.UnloadUnusedAssets();
            }
            if (_unload_handle != null && _unload_handle.isDone) {
                _unload_handle = null;
            }
        }
        public static void ClearAll() {
            foreach (var kv in _sABDict) {
                kv.Value.Unload(true);
            }
            sInnerSet = null;
            sExternalSet = null;
            _sABDict.Clear();
            _sLoadingOpts.Clear();
            ClearUnusedRes();
        }
    }
}
