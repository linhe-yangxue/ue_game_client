using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using System.Text.RegularExpressions;

namespace AssetBundles {
    public class AssetBundleBuilder {
        public static void BuildAssetBundles() {
            BuildAssetBundles(EditorUserBuildSettings.activeBuildTarget);
        }
        public static void BuildAssetBundlesAndroid() {
            BuildAssetBundles(BuildTarget.Android);
        }
        public static void BUildAssetBundlesiOS() {
            BuildAssetBundles(BuildTarget.iOS);
        }

        public static void BuildAssetBundles(BuildTarget build_target)
        {
            // ------ other reference defines begin -------
            PackScripts.PackAll();
            AutoGeneratorABName.AutoGenABNames();
            // ------ other reference defines end -------
            // Choose the output path according to the build target.
            string platform_name = AssetBundleConst.GetPlatformName(build_target);
            string outputPath = Path.Combine(AssetBundleConst.build_path, platform_name);
            if (!Directory.Exists(outputPath)) {
                Directory.CreateDirectory(outputPath);
            }
            ClearShader(outputPath);
            var manifest = BuildPipeline.BuildAssetBundles(outputPath, BuildAssetBundleOptions.ChunkBasedCompression, build_target);
            DeleteUnused(outputPath, manifest);
            BuildAssetbundleSet(outputPath, manifest, platform_name);
            BuildAssetbundleSetVersion(outputPath);
            CopyABToStreamingAssets(outputPath);
        }

        public static void ClearShader(string path) {
            foreach (var file_name in Directory.GetFiles(path)) {
                if (Path.GetFileName(file_name).StartsWith("shader.")) {
                    File.Delete(file_name);
                }
            }
        }

        public static void CopyABToStreamingAssets(string path) {
            if (!Directory.Exists(Application.streamingAssetsPath)) {
                Directory.CreateDirectory(Application.streamingAssetsPath);
            }
            var platform_name = Path.GetFileName(path);
            string copy_path = Application.streamingAssetsPath + "/" + platform_name;
            if (Directory.Exists(copy_path)) {
                Directory.Delete(copy_path, true);
            }
            FileUtil.CopyFileOrDirectory(path, copy_path);
            foreach (string full_name in Directory.GetFiles(copy_path)) {
                if (full_name.EndsWith(".manifest")) {
                    File.Delete(full_name);
                }
            }
        }

        public static void DeleteUnused(string path, AssetBundleManifest manifest) {
            HashSet<string> bundle_name_set = new HashSet<string>();
            foreach (string bundle_name in manifest.GetAllAssetBundles())
            {
                bundle_name_set.Add(bundle_name);
            }
            bundle_name_set.Add(Path.GetFileName(path));
            foreach (string full_name in Directory.GetFiles(path))
            {
                string file_name = Path.GetFileName(full_name);
                string bundle_name = file_name.Replace(".manifest", "");
                if (!bundle_name_set.Contains(bundle_name))
                {
                    File.Delete(full_name);
                    Debug.LogFormat("Delete {0}", full_name);
                }
            }
        }

        public static void BuildAssetbundleSet(string ab_path, AssetBundleManifest manifest, string platform_name) {
            var list = new AssetBundleSet(ab_path);
            {
                var file_content = File.ReadAllBytes(Path.Combine(ab_path, platform_name));
                string md5 = MD5(file_content);
                list.Add(platform_name, md5, file_content.Length);
            }
            foreach(var ab_name in manifest.GetAllAssetBundles()) {
                var file_content = File.ReadAllBytes(Path.Combine(ab_path, ab_name));
                string md5 = MD5(file_content);
                list.Add(ab_name, md5, file_content.Length);
            }
            list.WriteSet();
        }

        public static void BuildAssetbundleSetVersion(string ab_path) {
            var list = new AssetBundleSet(ab_path);
            string list_path = Path.Combine(ab_path, AssetBundleConst.set_filename);
            list.md5_ = MD5(File.ReadAllBytes(list_path));
            list.svn_version_ = GetSVNVersion(Path.Combine(Application.dataPath, ".."));
            list.time_ = System.DateTime.Now.ToString();
            list.WriteVersion();
        }

        public static string MD5(byte[] content) {
            System.Security.Cryptography.MD5 md5_calcer = System.Security.Cryptography.MD5.Create();
            byte[] b_md5 = md5_calcer.ComputeHash(content, 0, content.Length);
            string str_md5 = System.BitConverter.ToString(b_md5).Replace("-", "");
            return str_md5;
        }


        public static int GetSVNVersion(string path) {
            System.Diagnostics.Process proc = null;
            try {
                proc = new System.Diagnostics.Process();
                proc.StartInfo.FileName = "svn";
                proc.StartInfo.Arguments = "info " + path;
                proc.StartInfo.CreateNoWindow = false;
                proc.StartInfo.UseShellExecute = false;
                proc.StartInfo.RedirectStandardOutput = true;
                proc.Start();
                proc.WaitForExit();
                string result = proc.StandardOutput.ReadToEnd();
                var match = Regex.Match(result, "Last Changed Rev: (\\d*)");
                if (match.Groups.Count != 2) return -2;
                return int.Parse(match.Groups[1].Captures[0].Value);
            } catch (System.Exception ex) {
                Debug.LogError(string.Format("Exception Occurred :{0},{1}", ex.Message, ex.StackTrace.ToString()));
                return -1;
            }
        }
    }
}
