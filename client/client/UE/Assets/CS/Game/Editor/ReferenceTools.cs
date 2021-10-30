using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class ReferenceTools {

    [MenuItem("Assets/引用相关/查找谁在引用（直接）")]
    static void FindReferenceDirect() {
        _FindReference(false);
    }

    [MenuItem("Assets/引用相关/查找谁在引用（间接）")]
    static void FindReferenceIndirect() {
        _FindReference(true);
    }

    static void _FindReference(bool recursive) {
        string result = "";
        int count = 0;
        string[] all_paths = AssetDatabase.GetAllAssetPaths();
        foreach (Object obj in Selection.objects) {
            string obj_path = AssetDatabase.GetAssetPath(obj);
            result += obj_path + " 被以下资源引用:\n";
            int total = all_paths.Length;
            for (int i = 0; i < all_paths.Length; ++i) {
                string path = all_paths[i];
                if (i % 100 == 0 && EditorUtility.DisplayCancelableProgressBar("引用资源", path, (float)i / total)) {
                    EditorUtility.ClearProgressBar();
                    return;
                }
                string[] depends = AssetDatabase.GetDependencies(path, recursive);
                foreach (string depend in depends) {
                    if (depend == obj_path) {
                        result += "    " + path + "\n";
                        ++count;
                        break;
                    }
                }
            }
        }
        EditorUtility.ClearProgressBar();
        EditorGUIUtility.systemCopyBuffer = result;
        string title = string.Format("找到引用资源{0}个(已复制到剪切板)", count);
        EditorUtility.DisplayDialog(title, result, "关闭");
        Debug.Log(title + "\n" + result);
    }

    [MenuItem("Assets/引用相关/查找引用了谁")]
    static void FindReferenceOther() {
        string result = "";
        int count = 0;
        foreach (Object obj in Selection.objects) {
            string obj_path = AssetDatabase.GetAssetPath(obj);
            result += obj_path + " 引用了以下资源:\n";
            string[] depends = AssetDatabase.GetDependencies(obj_path, true);
            foreach (string depend in depends) {
                result += "    " + depend + "\n";
                ++count;
            }
        }
        EditorGUIUtility.systemCopyBuffer = result;
        string title = string.Format("找到被引用资源{0}个(已复制到剪切板)", count);
        EditorUtility.DisplayDialog(title, result, "关闭");
        Debug.Log(title + "\n" + result);
    }

    public class ReferenceReplaceTool : EditorWindow {
        public List<Object> sources = new List<Object>();
        public Object target;
        [MenuItem("Assets/引用相关/替换引用")]
        public static void OpenWindow() {
            ReferenceReplaceTool window = EditorWindow.GetWindow<ReferenceReplaceTool>();
            window.sources = new List<Object>(Selection.GetFiltered<Object>(SelectionMode.Assets));
            window.Show();
        }
        void OnGUI() {
            SerializedObject s_obj = new SerializedObject(this);
            EditorGUILayout.PropertyField(s_obj.FindProperty("sources"), true);
            EditorGUILayout.PropertyField(s_obj.FindProperty("target"));
            s_obj.ApplyModifiedProperties();
            if (GUILayout.Button("替换引用")) {
                Process();
            }
        }
        void Process() {
            string result = "";
            int count = 0;
            string[] all_paths = AssetDatabase.GetAllAssetPaths();
            var source_map = new Dictionary<string, Object>();
            foreach(var obj in sources) {
                source_map[AssetDatabase.GetAssetPath(obj)] = obj;
            }
            int total = all_paths.Length;
            for (int i = 0; i < all_paths.Length; ++i) {
                string path = all_paths[i];
                if (i % 100 == 0 && EditorUtility.DisplayCancelableProgressBar("替换引用", path, (float)i / total)) {
                    EditorUtility.ClearProgressBar();
                    return;
                }
                string[] depends = AssetDatabase.GetDependencies(path, false);
                foreach (string depend in depends) {
                    Object source;
                    if (!source_map.TryGetValue(depend, out source)) continue;
                    foreach(var obj in AssetDatabase.LoadAllAssetsAtPath(path)){
                        var s_obj = new SerializedObject(obj);
                        var s_prop = s_obj.GetIterator();
                        while (s_prop.Next(true)) {
                            if (s_prop.propertyType == SerializedPropertyType.ObjectReference &&
                                s_prop.objectReferenceValue == source) {
                                s_prop.objectReferenceValue = target;
                                result += "替换 " + depend + " 在 " + path + ":" + s_prop.propertyPath + "\n";
                                ++count;
                            }
                        }
                        s_obj.ApplyModifiedProperties();
                    }
                }
            }
            EditorUtility.ClearProgressBar();
            EditorGUIUtility.systemCopyBuffer = result;
            string title = string.Format("替换引用{0}个(已复制到剪切板)", count);
            EditorUtility.DisplayDialog(title, result, "关闭");
            Debug.Log(title + "\n" + result);
        }
    }

}
