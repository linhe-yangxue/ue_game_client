using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace AssetBundles {
    public class AssetBundleMenuItems {
        const string kSimulateModeMenuStr = "AssetBundles/Simulate Mode";
        [MenuItem(kSimulateModeMenuStr)]
        public static void ToggleSimulateMode() {
            AssetBundleConst.simulate_mode = !AssetBundleConst.simulate_mode;
        }
        [MenuItem(kSimulateModeMenuStr, true)]
        public static bool ToggleSimulateModeValidate() {
            Menu.SetChecked(kSimulateModeMenuStr, AssetBundleConst.simulate_mode);
            return true;
        }
        [MenuItem("AssetBundles/step 2: Build AssetBundles", false, 2)]
        public static void BuildAssetBundles() {
            AssetBundleBuilder.BuildAssetBundles();
        }
    }
}
