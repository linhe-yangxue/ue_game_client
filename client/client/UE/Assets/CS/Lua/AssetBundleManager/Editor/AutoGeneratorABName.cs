using UnityEngine;
using UnityEditor;
using System.Collections;
using System.IO;

namespace AssetBundles {
    public class AutoGeneratorABName {
        static string[] ignores_folders_ = { "*.fbm", "editor" };
        static string base_folder_ = "assets/res/";
        static string map_folder_ = "assets/maps/";// GameSceneMgrEditor.async_map_path;
        const string kmap_ext = ".unity";
        [MenuItem("AssetBundles/AutoGenNames")]
        public static void AutoGenABNames() {
            string[] all_path = AssetDatabase.GetAllAssetPaths();
            foreach (var path in all_path) {
                __GenABNames(path);
            }
        }

        public class AutoGeneratorABNamePostprocessor : AssetPostprocessor {
            static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets, string[] movedFromAssetPaths) {
                System.Collections.Generic.HashSet<string> names = new System.Collections.Generic.HashSet<string>();
                for (int i = 0; i < importedAssets.Length; ++i) {
                    names.Add(importedAssets[i]);
                }
                for (int i = 0; i < movedAssets.Length; ++i) {
                    names.Add(movedAssets[i]);
                }
                foreach (string name in names) {
                    __GenABNames(name);
                }
                __AutoReimportShader(names);
            }
        }

        public static string __GetABName(string path,ref string ab_variant) {
            var low_path = path.ToLower();
            if (Directory.Exists(low_path)) return "";
            var ignore_case = System.StringComparison.OrdinalIgnoreCase;
            bool in_map_folder = low_path.StartsWith(map_folder_, ignore_case) && low_path.EndsWith(kmap_ext, ignore_case);
            bool in_base_folder = low_path.StartsWith(base_folder_, ignore_case);
            if (!in_base_folder && !in_map_folder) return "";

            string pre_folder_name = in_base_folder ? base_folder_ : map_folder_;
            int idx = low_path.LastIndexOf(pre_folder_name);
            low_path = low_path.Substring(idx + pre_folder_name.Length);
            bool is_ignore = false;
            int last_index = low_path.LastIndexOf("/");
            var dir_path = last_index != -1 ? low_path.Substring(0, last_index) : "";
            var file_name = low_path.Substring(last_index + 1);
            var file_name_without_ext = file_name;
            //var file_name_ext = "";
            last_index = file_name.LastIndexOf(".");
            if (last_index != -1) {
                file_name_without_ext = file_name.Substring(0, last_index);
                //file_name_ext = file_name.Substring(last_index + 1).Trim();
            }
            string variant_name = "";
            string[] dir_names = dir_path.Split(new char[] { '/', });
            foreach (var ig_folder_ele in ignores_folders_) {
                string ig_folder = ig_folder_ele;
                bool has_wild_char = false;
                int wild_char_index = ig_folder.LastIndexOf("*");
                if (wild_char_index != -1) {
                    ig_folder = ig_folder.Substring(wild_char_index + 1);
                    has_wild_char = true;
                }
                foreach (var dir_name in dir_names) {
                    if (dir_name == ig_folder) {
                        is_ignore = true;
                        break;
                    } else if (has_wild_char) {
                        if (dir_name.LastIndexOf(ig_folder) != -1) {
                            is_ignore = true;
                            break;
                        }
                    }else {
                        foreach (var folder_name in AssetBundleConst.lang_abname)
                        {
                            string f_name = folder_name + "-";
                            int index = dir_name.LastIndexOf(f_name);
                            if(index != -1)
                            {
                                dir_path = dir_path.Replace(dir_name, folder_name);
                                variant_name = dir_name.Substring(index + f_name.Length);
                            }
                        }
                    }
                }
                if (is_ignore) {
                    break;
                }
            }

            if (is_ignore) {
                return "";
            } else {
                string ab_name = dir_path.Trim();
                if (in_map_folder || ab_name == "") {
                    ab_name = file_name_without_ext;
                }
                ab_name = ab_name.Replace("/", ".");
                ab_name += ".abd";
                ab_variant = variant_name;
                return ab_name;
            }
        }

        public static void __GenABNames(string path) {
            string ab_variant = "";
            var ab_name = __GetABName(path, ref ab_variant);
            AssetImporter asset_import = AssetImporter.GetAtPath(path);
            if (asset_import != null) {
                if(asset_import.assetBundleName != ab_name) {
                    asset_import.assetBundleName = ab_name;
                }
                if(asset_import.assetBundleVariant != ab_variant) {
                    asset_import.assetBundleVariant = ab_variant;
                }
            }
        }
        public static void __AutoReimportShader(System.Collections.Generic.HashSet<string> names) {
            bool has_shader_include = false;
            foreach (string name in names) {
                if (name.EndsWith(".cginc")) {
                    has_shader_include = true;
                    break;
                }
            }
            if (has_shader_include) {
                foreach (string name in AssetDatabase.GetAllAssetPaths()) {
                    if (name.EndsWith(".shader")) {
                        AssetDatabase.ImportAsset(name);
                    }
                }
            }
        }

    }
}
