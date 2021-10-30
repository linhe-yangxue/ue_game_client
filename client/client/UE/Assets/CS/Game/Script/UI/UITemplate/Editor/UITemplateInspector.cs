using UnityEngine;
using UnityEngine.UI;
using System.Collections;
using UnityEditor;
using UnityEditor.SceneManagement;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;

[CustomEditor(typeof(UITemplate))]
public class UITemplateInspector : Editor
{
    //模板存放的路径
    private static string TEMPLATE_PREFAB_PATH = "Assets/Res/UITemplate";

    //UI Prefab存放的路径
    private static List<string> ui_prefabs_list = new List<string>()
    {
       "Assets/Res/UI"
    };

    [MenuItem("GameObject/UITemplate/Creat To Prefab", false, 11)]
    static void CreatToPrefab()
    {
        GameObject select_go = Selection.activeGameObject;
        if (select_go != null)
        {
            CreatDirectory();
            if (IsTemplatePrefabInHierarchy(select_go))
            {
                CreatPrefab(select_go);
            }
            else
            {
                CreatPrefab(select_go);
                GameObject.DestroyImmediate(select_go);
            }
        }
        else
        {
            EditorUtility.DisplayDialog("错误！", "请选择一个GameObject", "OK");
        }
    }

    private UITemplate ui_template_;
    private static GameObject canvas_go_;

    void OnEnable()
    {
        ui_template_ = (UITemplate)target;
        CreatDirectory();
    }

    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        bool is_project_view = IsTemplatePrefabInInProjectView(ui_template_.gameObject);
        EditorGUILayout.LabelField("GUID:" + ui_template_.guid_);

        GUILayout.BeginHorizontal();

        if (GUILayout.Button("Select"))
        {
            DirectoryInfo directiory = CreatDirectory();

            FileInfo[] infos = directiory.GetFiles("*.prefab", SearchOption.AllDirectories);
            for (int i = 0; i < infos.Length; i++)
            {
                FileInfo file = infos[i];
                GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(file.FullName.Substring(file.FullName.IndexOf("Assets")));
                if (prefab.GetComponent<UITemplate>().guid_ == ui_template_.guid_)
                {
                    EditorGUIUtility.PingObject(prefab);
                    return;
                }
            }
        }

        if (is_project_view)
        {

            if (GUILayout.Button("Search"))
            {
                TrySearchPrefab(ui_template_.guid_, out ui_template_.search_prefabs);
                return;
            }

            if (GUILayout.Button("Apply"))
            {
                if (IsTemplatePrefabInHierarchy(ui_template_.gameObject))
                {

                    ApplyPrefab(ui_template_.gameObject, PrefabUtility.GetCorrespondingObjectFromSource(ui_template_.gameObject), true);
                }
                else
                {

                    ApplyPrefab(ui_template_.gameObject, ui_template_.gameObject, false);
                }
                return;
            }

            if (GUILayout.Button("Delete"))
            {
                if (IsTemplatePrefabInHierarchy(ui_template_.gameObject))
                {
                    DeletePrefab(GetPrefabPath(ui_template_.gameObject));
                }
                else
                {
                    DeletePrefab(AssetDatabase.GetAssetPath(ui_template_.gameObject));
                }
                return;
            }
        }
        GUILayout.EndHorizontal();

        if (is_project_view)
        {
            if (ui_template_ != null && ui_template_.search_prefabs.Count > 0)
            {
                EditorGUILayout.LabelField("Prefab :" + ui_template_.name);

                foreach (GameObject go in ui_template_.search_prefabs)
                {
                    EditorGUILayout.Space();
                    if (GUILayout.Button(AssetDatabase.GetAssetPath(go)))
                    {
                        EditorGUIUtility.PingObject(go);
                    }
                }
            }
        }
    }

    static private bool TrySearchPrefab(string guid, out List<GameObject> search_list)
    {
        List<GameObject> prefabs = new List<GameObject>();
        bool try_search = false;
        foreach (string forder in ui_prefabs_list)
        {
            DirectoryInfo directiory = new DirectoryInfo(Application.dataPath + "/" + forder.Replace("Assets/", ""));
            FileInfo[] infos = directiory.GetFiles("*.prefab", SearchOption.AllDirectories);
            for (int i = 0; i < infos.Length; i++)
            {
                FileInfo file = infos[i];
                GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(file.FullName.Substring(file.FullName.IndexOf("Assets")));
                if (prefab.GetComponentsInChildren<UITemplate>(true).Length > 0)
                {
                    GameObject go = Instantiate<GameObject>(prefab);
                    UITemplate[] templates = go.GetComponentsInChildren<UITemplate>(true);
                    foreach (UITemplate template in templates)
                    {
                        if (template.GetComponentsInChildren<UITemplate>().Length > 1)
                        {
                            Debug.LogError(file.FullName + " 模板 " + template.name + " 进行了嵌套的错误操作~请删除重试");
                            if (!try_search) try_search = true;
                        }
                        else
                        {
                            if (template.guid_ == guid && !prefabs.Contains(prefab))
                            {
                                prefabs.Add(prefab);
                            }
                        }
                    }
                    GameObject.DestroyImmediate(go);
                }
            }
        }
        search_list = prefabs;
        return !try_search;
    }

    static private void ApplyPrefab(GameObject prefab, Object target_prefab, bool replace)
    {
        if (EditorUtility.DisplayDialog("注意！", "是否进行递归查找批量替换模板？", "ok", "cancel"))
        {
            Debug.Log("ApplyPrefab : " + prefab.name);
            GameObject replace_prefab;
            int count = 0;
            if (replace)
            {
                PrefabUtility.ReplacePrefab(prefab, target_prefab, ReplacePrefabOptions.ConnectToPrefab);
                Refresh();
                replace_prefab = target_prefab as GameObject;
                count = prefab.GetComponentsInChildren<UITemplate>(true).Length;
            }
            else
            {
                replace_prefab = AssetDatabase.LoadAssetAtPath<GameObject>(AssetDatabase.GetAssetPath(target_prefab));
                GameObject checkPrefab = PrefabUtility.InstantiatePrefab(replace_prefab) as GameObject;
                count = checkPrefab.GetComponentsInChildren<UITemplate>(true).Length;
                DestroyImmediate(checkPrefab);
            }
            if (count != 1)
            {
                EditorUtility.DisplayDialog("注意！", "无法批量替换，因为模板不支持嵌套。", "ok");
                return;
            }

            UITemplate template = replace_prefab.GetComponent<UITemplate>();

            if (template != null)
            {
                List<GameObject> references;
                if (TrySearchPrefab(template.guid_, out references))
                {
                    for (int i = 0; i < references.Count; i++)
                    {
                        GameObject reference = references[i];
                        GameObject go = PrefabUtility.InstantiatePrefab(reference) as GameObject;
                        UITemplate[] instance_templates = go.GetComponentsInChildren<UITemplate>(true);
                        for (int j = 0; j < instance_templates.Length; j++)
                        {
                            UITemplate instance = instance_templates[j];
                            if (instance.guid_ == template.guid_)
                            {
                                int index = instance.gameObject.transform.GetSiblingIndex();
                                GameObject new_instance = GameObject.Instantiate<GameObject>(replace_prefab);
                                new_instance.name = instance.name;
                                new_instance.transform.SetParent(instance.transform.parent);
                                new_instance.transform.localPosition = instance.transform.localPosition;
                                new_instance.transform.localScale = instance.transform.localScale;
                                new_instance.transform.localRotation = instance.transform.localRotation;
                                new_instance.transform.SetSiblingIndex(index);
                                RectTransform rect_comp = instance.gameObject.GetComponent<RectTransform>();
                                if (rect_comp != null)
                                {
                                    RectTransform new_rect_comp = new_instance.gameObject.GetComponent<RectTransform>();
                                    new_rect_comp.sizeDelta = rect_comp.sizeDelta;
                                    new_rect_comp.pivot = rect_comp.pivot;
                                    new_rect_comp.anchorMin = rect_comp.anchorMin;
                                    new_rect_comp.anchorMax = rect_comp.anchorMax;
                                    new_rect_comp.offsetMin = rect_comp.offsetMin;
                                    new_rect_comp.offsetMax = rect_comp.offsetMax;
                                }
                                DestroyImmediate(instance.gameObject);
                            }
                        }
                        PrefabUtility.ReplacePrefab(go, PrefabUtility.GetCorrespondingObjectFromSource(go), ReplacePrefabOptions.ConnectToPrefab);
                        DestroyImmediate(go);
                    }
                }
            }
            Refresh();
        }
    }



    static private void DeletePrefab(string path)
    {
        if (EditorUtility.DisplayDialog("注意！", "是否进行递归查找批量删除模板？", "ok", "cancel"))
        {
            Debug.Log("DeletePrefab : " + path);
            GameObject deletePrefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);
            UITemplate template = deletePrefab.GetComponent<UITemplate>();
            if (template != null)
            {
                List<GameObject> references;
                if (TrySearchPrefab(template.guid_, out references))
                {

                    foreach (GameObject reference in references)
                    {
                        GameObject go = PrefabUtility.InstantiatePrefab(reference) as GameObject;
                        UITemplate[] instanceTemplates = go.GetComponentsInChildren<UITemplate>(true);
                        for (int i = 0; i < instanceTemplates.Length; i++)
                        {
                            UITemplate instance = instanceTemplates[i];
                            if (instance.guid_ == template.guid_)
                            {
                                DestroyImmediate(instance.gameObject);
                            }
                        }
                        PrefabUtility.ReplacePrefab(go, PrefabUtility.GetCorrespondingObjectFromSource(go), ReplacePrefabOptions.ConnectToPrefab);
                        DestroyImmediate(go);
                    }
                }
            }
            AssetDatabase.DeleteAsset(path);
            Refresh();
        }
    }

    static private void CreatPrefab(GameObject prefab)
    {
        string creat_path = TEMPLATE_PREFAB_PATH + "/" + prefab.name + ".prefab";
        Debug.Log("CreatPrefab : " + creat_path);
        if (AssetDatabase.LoadAssetAtPath<GameObject>(creat_path) == null)
        {
            UITemplate[] temps = prefab.GetComponentsInChildren<UITemplate>(true);
            for (int i = 0; i < temps.Length; i++)
            {
                DestroyImmediate(temps[i]);
            }
            prefab.AddComponent<UITemplate>().InitGUID();
            PrefabUtility.CreatePrefab(TEMPLATE_PREFAB_PATH + "/" + prefab.name + ".prefab", prefab);
            Refresh();
        }
        else
        {
            EditorUtility.DisplayDialog("错误！", "Prefab名字重复，请重命名！", "OK");
        }
    }

    static private void Refresh()
    {
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }

    static private bool IsTemplatePrefabInHierarchy(GameObject go)
    {
        return (PrefabUtility.GetCorrespondingObjectFromSource(go) != null);
    }

    static private bool IsTemplatePrefabInInProjectView(GameObject go)
    {
        string path = AssetDatabase.GetAssetPath(go);
        if (!string.IsNullOrEmpty(path))
            return (path.Contains(TEMPLATE_PREFAB_PATH));
        else
            return false;
    }

    static private DirectoryInfo CreatDirectory()
    {
        DirectoryInfo directiory = new DirectoryInfo(Application.dataPath + "/" + TEMPLATE_PREFAB_PATH.Replace("Assets/", ""));
        if (!directiory.Exists)
        {
            directiory.Create();
            Refresh();
        }
        return directiory;
    }

    static private string GetPrefabPath(GameObject prefab)
    {
        Object prefab_obj = PrefabUtility.GetCorrespondingObjectFromSource(prefab);
        if (prefab_obj != null)
        {
            return AssetDatabase.GetAssetPath(prefab_obj);
        }
        return null;
    }

}
