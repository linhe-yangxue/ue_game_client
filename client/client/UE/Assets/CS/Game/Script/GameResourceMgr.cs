using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using AssetBundles;
using SLua;
using System.Reflection;

[UnityEngine.Scripting.Preserve]
public static class GameResourceMgr {
    private static void _GetAssetBundleByPath(string file_path, out string bundle_name, out string asset_name) {
        int index = file_path.LastIndexOf("/");
        if (index == -1) {
            bundle_name = file_path.ToLower();
            asset_name = file_path;
        } else {
            bundle_name = file_path.Substring(0, index).ToLower().Replace("/", ".");
            asset_name = file_path.Substring(index + 1);
        }
        bundle_name += ".abd";
    }
    private static System.Type _GetTypeByName(string type_name) {
        System.Type tp = LuaObject.FindType(type_name);
        if (tp == null) {
            tp = LuaObject.FindType("UnityEngine." + type_name);
        }
        if (tp == null) {
            Debug.LogErrorFormat("Can't Find Type for Type name:{0} or UnityEngine.{1}", type_name, type_name);
        }
        return tp;
    }
    [DoNotToLua]
    public static ABLoadOptBase LoadAssetAsync(string asset_path, System.Type asset_type, ABLoadOptBase.Callback callback = null) {
        string ab_name = null;
        string asset_name = null;
        _GetAssetBundleByPath(asset_path, out ab_name, out asset_name);
        return AssetBundleManager.LoadAssetAsync(ab_name, asset_name, asset_type, callback);
    }
    [DoNotToLua]
    public static ABLoadOptBase LoadSubAssetAsync(string asset_path, string sub_asset_name, System.Type asset_type, ABLoadOptBase.Callback callback = null) {
        string ab_name = null;
        string asset_name = null;
        _GetAssetBundleByPath(asset_path, out ab_name, out asset_name);
        return AssetBundleManager.LoadSubAssetAsync(ab_name, asset_name, sub_asset_name, asset_type, callback);
    }
    [DoNotToLua]
    public static Object LoadAssetSync(string asset_path, System.Type asset_type) {
        string ab_name = null;
        string asset_name = null;
        _GetAssetBundleByPath(asset_path, out ab_name, out asset_name);
        return AssetBundleManager.LoadAssetSync(ab_name, asset_name, asset_type);
    }
    [DoNotToLua]
    public static Object LoadSubAssetSync(string asset_path, string sub_asset_name, System.Type asset_type) {
        string ab_name = null;
        string asset_name = null;
        _GetAssetBundleByPath(asset_path, out ab_name, out asset_name);
        return AssetBundleManager.LoadSubAssetSync(ab_name, asset_name, sub_asset_name, asset_type);
    }
    [DoNotToLua]
    public static ABLoadOptBase LoadSceneAsync(string scene_name, bool is_additive = false, ABLoadOptBase.Callback callback = null) {
        ABLoadOptBase opt = null;
        string ab_name = null;
        string asset_name = null;
        _GetAssetBundleByPath(scene_name, out ab_name, out asset_name);
        opt = AssetBundleManager.LoadSceneAsync(ab_name, asset_name, is_additive, callback);
        return opt;
    }

    public static ABLoadOptBase LoadSceneAsync(string scene_name, bool is_additive = false) {
        return LoadSceneAsync(scene_name, is_additive, null);
    }

    public static void LoadSceneSync(string scene_name, bool is_additive = false) {
        string ab_name = null;
        string asset_name = null;
        _GetAssetBundleByPath(scene_name, out ab_name, out asset_name);
        AssetBundleManager.LoadSceneSync(ab_name, asset_name, is_additive);
    }
    public static ABLoadOptBase LoadAssetAsync(string asset_path, string asset_type_name) {
        var asset_type = _GetTypeByName(asset_type_name);
        if (asset_type == null) {
            return null;
        }
        return LoadAssetAsync(asset_path, asset_type);
    }
    public static ABLoadOptBase LoadSubAssetAsync(string asset_path, string sub_asset_name, string asset_type_name) {
        var asset_type = _GetTypeByName(asset_type_name);
        if (asset_type == null) {
            return null;
        }
        return LoadSubAssetAsync(asset_path, sub_asset_name, asset_type);
    }
    public static Object LoadAssetSync(string asset_path, string asset_type_name) {
        var asset_type = _GetTypeByName(asset_type_name);
        if (asset_type == null) {
            return null;
        }
        return LoadAssetSync(asset_path, asset_type);
    }
    public static Object LoadSubAssetSync(string asset_path, string sub_asset_name, string asset_type_name) {
        var asset_type = _GetTypeByName(asset_type_name);
        if (asset_type == null) {
            return null;
        } 
        return LoadSubAssetSync(asset_path, sub_asset_name, asset_type);
    }
    public static void ClearUnusedRes() {
        AssetBundleManager.ClearUnusedRes();
    }
    public static void GC() {
        System.GC.Collect();
    }
    public static void DumpAssetBundleInfo(string asset_path = null) {
        if (string.IsNullOrEmpty(asset_path)) {
            AssetBundleManager.DumpAssetBundleInfo();
        } else {
            string ab_name = null;
            string asset_name = null;
            _GetAssetBundleByPath(asset_path, out ab_name, out asset_name);
            AssetBundleManager.DumpAssetBundleInfoByName(ab_name);
        }
    }
    public static AssetBundleSet GetInnerSet() {
        return AssetBundleManager.sInnerSet;
    }
    public static AssetBundleSet GetExternalSet() {
        return AssetBundleManager.sExternalSet;
    }
    public static bool IsSimulateMode() {
        #if UNITY_EDITOR
            return AssetBundleConst.simulate_mode;
        #else
            return false;
        #endif
    }

    public static void SetLangVariant(string lang_variant)
    {
        AssetBundleManager.lang_variant = lang_variant;
    }

}
