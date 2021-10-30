using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using System.IO;

public class ImporterTools : AssetPostprocessor {

    void OnPreprocessTexture() {
        var importer = assetImporter as TextureImporter;
        TextureTools.OnPreprocessTexture(importer);
    }

    void OnPreprocessModel() {
        var importer = assetImporter as ModelImporter;
        if (GetUserData(importer, "inited") != "true") {
            _InitModelImporter(importer);
        }
    }

	void OnPreprocessAnimation()
    {
        var importer = assetImporter as ModelImporter;
        if (GetUserData(importer, "inited") != "true") {
            _InitModelImporter(importer);
        }
    }

    void OnPostprocessModel(GameObject model) {
        /*
            if (!assetPath.Contains("@")) {
                Renderer[] renderers = model.transform.GetComponentsInChildren<Renderer>();
                for (int i = 0; i < renderers.Length; i++) {
                    if (renderers[i].sharedMaterial.name != model.name) {
                        Debug.LogError("材质名和模型名不匹配！");
                        //FileUtil.DeleteFileOrDirectory(Application.dataPath+assetPath.Replace("Assets",""));
                        AssetDatabase.Refresh();
                        break;
                    }
                }
            }
            */
    }

    static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets, string[] movedFromAssetPaths) {
        foreach (string path in importedAssets) {
            OnAssetImported(path);
        }
        foreach (string path in deletedAssets) {
            OnAssetDeleted(path);
        }

        for (int i = 0; i < movedAssets.Length; i++) {
            OnAssetMoved(movedAssets[i], movedFromAssetPaths[i]);
        }
    }

    static void OnAssetImported(string path) {
    }

    static void OnAssetDeleted(string path) {
    }

    static void OnAssetMoved(string from_path, string to_path) {
    }

    public static string GetUserData(AssetImporter importer, string key) {
        key = key + "=";
        var data = importer.userData;
        foreach (var kv in data.Split(';')) {
            if (kv.StartsWith(key)) {
                return kv.Substring(key.Length);
            }
        }
        return "";
    }
    public static void SetUserData(AssetImporter importer, string key, string value) {
        key = key + "=";
        var data = importer.userData;
        var list = new List<string>(data.Split(';'));
        int i = list.FindIndex((x) => x.StartsWith(key));
        if (i < 0) {
            list.Add(key + value);
        } else {
            list[i] = key + value;
        }
        importer.userData = string.Join(";", list.ToArray());
    }
    public static Dictionary<string, string> GetAllUserData(AssetImporter importer) {
        var data = importer.userData;
        Dictionary<string, string> dict = new Dictionary<string, string>();
        foreach (var kv in data.Split(';')) {
            int i = kv.IndexOf("=");
            if (i >= 0) {
                dict[kv.Substring(0, i - 1)] = kv.Substring(i + 1);
            }
        }
        return dict;
    }
    public static void SetAllUserData(AssetImporter importer, Dictionary<string, string> dict) {
        var data = importer.userData;
        StringWriter writer = new StringWriter();
        foreach (var kv in dict) {
            writer.Write(kv.Key);
            writer.Write("=");
            writer.Write(kv.Value);
            writer.Write(";");
        }
        importer.userData = writer.ToString();
    }

    [MenuItem("Assets/恢复设置/恢复模型设置")]
    static void InitModelImporter() {
        var assets = Selection.GetFiltered<GameObject>(SelectionMode.Assets);
        foreach (var asset in assets) {
            var path = AssetDatabase.GetAssetPath(asset);
            var importer = ModelImporter.GetAtPath(path) as ModelImporter;
            if (importer == null) continue;
            _InitModelImporter(importer);
            importer.SaveAndReimport();
        }
    }
    // 设置压缩格式，关闭导入材质
    static void _InitModelImporter(ModelImporter importer) {
        SetUserData(importer, "inited", "true");
        importer.importMaterials = false;
        //importer.meshCompression = ModelImporterMeshCompression.High;
        importer.animationCompression = ModelImporterAnimationCompression.Optimal;
    }

}

