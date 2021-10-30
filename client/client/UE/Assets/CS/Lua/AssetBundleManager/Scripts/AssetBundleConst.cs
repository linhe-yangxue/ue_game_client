using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine.SceneManagement;

namespace AssetBundles {
    public static partial class AssetBundleConst {
        public const string build_path = "AssetBundles";
        public const string set_filename = "_AssetBundleSet.txt";
        public const string set_version_filename = "_AssetBundleSetVersion.txt";
        public static string[] lang_abname = { "uireslanguage", "soundlanguage" };

        static int _simulate_mode = -1;
        const string _simulate_mode_name = "NGameSimulateAssetBundles";

        public static string inner_path {
            get {
#if (UNITY_ANDROID && !UNITY_EDITOR)
                string stream_path = "jar:file://" + Application.dataPath + "!/assets";
#else
                string stream_path = Application.streamingAssetsPath;
#endif
                return stream_path + "/" + GetPlatformName() + "/";
            }
        }

        public static string external_path {
            get {
                return Application.persistentDataPath + "/" + GetPlatformName() + "/";
            }
        }

        // 用于标记是否在Simulate模式下
#if UNITY_EDITOR
        [SLua.DoNotToLua]
        public static bool simulate_mode {
            get {
                if (_simulate_mode == -1) {
                    _simulate_mode = EditorPrefs.GetBool(_simulate_mode_name, true) ? 1 : 0;
                }
                return _simulate_mode != 0;
            }
            set {
                int newValue = value ? 1 : 0;
                if (newValue != _simulate_mode) {
                    _simulate_mode = newValue;
                    EditorPrefs.SetBool(_simulate_mode_name, value);
                }
            }
        }
#endif

        public static string GetPlatformName() {
#if UNITY_EDITOR
            return _GetPlatformForAssetBundles(EditorUserBuildSettings.activeBuildTarget);
#else
            return _GetPlatformForAssetBundles(Application.platform);
#endif
        }

#if UNITY_EDITOR
        [SLua.DoNotToLua]
        public static string GetPlatformName(BuildTarget build_target) {
            return _GetPlatformForAssetBundles(build_target);
        }
        private static string _GetPlatformForAssetBundles(BuildTarget target) {
            switch (target) {
                case BuildTarget.Android:
                    return "Android";
                case BuildTarget.iOS:
                    return "iOS";
                case BuildTarget.WebGL:
                    return "WebGL";
                case BuildTarget.StandaloneWindows:
                case BuildTarget.StandaloneWindows64:
                    return "Windows";
                case BuildTarget.StandaloneOSX:
                    return "OSX";
                default:
                    return null;
            }
        }
#endif

        private static string _GetPlatformForAssetBundles(RuntimePlatform platform) {
            switch (platform) {
                case RuntimePlatform.Android:
                    return "Android";
                case RuntimePlatform.IPhonePlayer:
                    return "iOS";
                case RuntimePlatform.WebGLPlayer:
                    return "WebGL";
                case RuntimePlatform.WindowsPlayer:
                    return "Windows";
                case RuntimePlatform.OSXPlayer:
                    return "OSX";
                default:
                    return null;
            }
        }
    }
}
