using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;

public class ObjectAssistWindow : EditorWindow {
    [MenuItem("GameObject/辅助功能窗口", false, 11)]
    public static void OpenInHierarchyView()
    {
        ObjectAssistWindow.OpenAssistWindow();
    }
    [MenuItem("Assets/辅助功能窗口")]
    public static void OpenInProjectView()
    {
        ObjectAssistWindow.OpenAssistWindow();
    }
    System.Action onSelectChange = null;
    static string[] s_all_asset_path;
    static string s_lua_data_path;
    const string k_lua_asset_path = "Assets/Res/";
    int asset_search_rate = 50;
    enum ActionType { 无, 批量对象改名, 资源引用查找};
    ActionType cur_ac_type = ActionType.无;
    static void OpenAssistWindow()
    {
        EditorWindow.GetWindow<ObjectAssistWindow>("ObjectsAssistWindow", false);
    }
    void OnEnable()
    {
        onSelectChange = () => {
            this.UpdateSelectObjects();
            base.Repaint();
        };
        s_all_asset_path = AssetDatabase.GetAllAssetPaths();
        s_lua_data_path = Application.dataPath + "/../../../sharedata/exceldata/data/client";
        this.UpdateSelectObjects();
        Selection.selectionChanged += this.onSelectChange;
    }
    void OnDisable()
    {
        Selection.selectionChanged -= this.onSelectChange;
    }
    void OnGUI()
    {
        cur_ac_type = (ActionType)EditorGUILayout.EnumPopup("功能类型选择",cur_ac_type);
        switch (cur_ac_type)
        {
            case ActionType.批量对象改名:  {this.UpdateNamesOnGUI(); break; };
            case ActionType.资源引用查找:  {this.UpdateSearchRefOnGUI(); break; };
        }
    }
    void Update()
    {
        UpdateRefSearchProcess();
    }
    void UpdateSelectObjects()
    {
        UnityEngine.Object[] select_objects = Selection.GetFiltered<UnityEngine.Object>(SelectionMode.Unfiltered);
        if (select_objects.Length > 0)
        {
            all_name_info = new NameInfo[select_objects.Length];
            List<NameInfo> name_list = new List<NameInfo>(select_objects.Length);
            for (int i = 0; i < select_objects.Length; ++i)
            {
                UnityEngine.Object obj = select_objects[i];
                name_list.Add(new NameInfo(obj, obj.name));
            }
            name_list.Sort((info_a, info_b) =>
            {
                GameObject obj_a = info_a.obj as GameObject;
                GameObject obj_b = info_b.obj as GameObject;
                if (obj_a != null && obj_b != null)
                {
                    int a_index = obj_a.transform.GetSiblingIndex();
                    int b_index = obj_b.transform.GetSiblingIndex();
                    return a_index.CompareTo(b_index);
                }
                string a_name = info_a.origin_name;
                string b_name = info_b.origin_name;
                if (!string.IsNullOrEmpty(a_name) && !string.IsNullOrEmpty(b_name))
                {
                    return a_name.CompareTo(b_name);
                }
                return -1;
            });
            name_list.CopyTo(all_name_info);
        }
        else all_name_info = null;
    }
    void GetAllFileFromDirectory(string target_path, ref List<string> ret_obj_list)
    {
        if (Directory.Exists(target_path))
        {
            foreach (var p in Directory.GetFileSystemEntries(target_path))
            {
                if (Directory.Exists(p))
                {
                    GetAllFileFromDirectory(p, ref ret_obj_list);
                }
                else if (Path.GetExtension(p) != ".meta")
                {
                    ret_obj_list.Add(p.Replace("\\", "/"));
                }
            }
        }
        else if (File.Exists(target_path) && Path.GetExtension(target_path) != ".meta")
        {
            ret_obj_list.Add(target_path.Replace("\\", "/"));
        }
    }
    #region 对象或资源批量重命名
    const int kNameWidth = 150;
    readonly string[] kOperationStringList = new string[4] { "+", "-", "*", "%" };
    class NameInfo
    {
        public UnityEngine.Object obj;
        public string origin_name;
        public string new_name;
        public NameInfo(UnityEngine.Object obj, string origin_name)
        {
            this.obj = obj; this.origin_name = origin_name; new_name = string.Copy(origin_name);
        }
    }
    class CustomVertexInfo
    {
        public string convert_char = string.Empty;
        public int init_value = 0;
        public int operation_char = 0;
        public int rate_value = 1;
    }
    NameInfo[] all_name_info = null;
    string target_name = null;
    bool is_quick_up = false;
    bool is_quick_down = false;
    CustomVertexInfo custom_vertex_info = new CustomVertexInfo();
    void UpdateNamesOnGUI()
    {
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("**************对象，资源或文件夹批量改名*************");
        EditorGUILayout.EndHorizontal();
        if(all_name_info == null||all_name_info.Length == 0)
        {
            EditorGUILayout.LabelField("选中要改名的对象，资源或文件夹");
            return;
        }
        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("快速命名（递增）"))
        {
            is_quick_up = true;
            is_quick_down = false;
        }
        if (GUILayout.Button("快速命名（递减）"))
        {
            is_quick_down = true;
            is_quick_up = false;
        }
        if (GUILayout.Button("重置"))
        {
            is_quick_down = false;
            is_quick_up = false;
            target_name = null;
            custom_vertex_info = new CustomVertexInfo();
            for(int k =0;k< all_name_info.Length; ++k)
            {
                NameInfo info = all_name_info[k];
                info.new_name = info.origin_name;
            }
        }
        EditorGUILayout.EndHorizontal();
        this.UpdateCustomNamesOnGUI();
        this.ChangeSelectObjectNames();
        EditorGUILayout.LabelField("----------------------------预览----------------------------");
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("原名字", GUILayout.Width(kNameWidth));
        EditorGUILayout.LabelField(string.Empty, GUILayout.Width(kNameWidth));
        EditorGUILayout.LabelField("改后名字", GUILayout.Width(kNameWidth));
        EditorGUILayout.EndHorizontal();
        for (int i = 0; i < all_name_info.Length; ++i)
        {
            NameInfo name_info = all_name_info[i];
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField(name_info.origin_name, GUILayout.Width(kNameWidth));
            EditorGUILayout.LabelField("-->", GUILayout.Width(kNameWidth));
            EditorGUILayout.LabelField(name_info.new_name, GUILayout.Width(kNameWidth));
            EditorGUILayout.EndHorizontal();
        }
        if (GUILayout.Button("确定改名"))
        {
            for (int k = 0; k < all_name_info.Length; ++k)
            {
                NameInfo cur_name_info = all_name_info[k];
                if (string.IsNullOrEmpty(cur_name_info.new_name)) continue;
                ObjectNames.SetNameSmart(cur_name_info.obj, cur_name_info.new_name); //同步改变：对象名，meta文件名，资源文件名
            }
            AssetDatabase.SaveAssets();
            this.UpdateSelectObjects();
        }
    }
    void UpdateCustomNamesOnGUI()
    {
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("自定义命名-->", GUILayout.Width(100));
        EditorGUILayout.LabelField("目标名字：", GUILayout.Width(70));
        target_name = EditorGUILayout.TextField(target_name, GUILayout.Width(150));
        EditorGUILayout.LabelField("转换字符：", GUILayout.Width(70));
        custom_vertex_info.convert_char = EditorGUILayout.TextField(custom_vertex_info.convert_char, GUILayout.Width(100));
        EditorGUILayout.LabelField("初始值：", GUILayout.Width(50));
        custom_vertex_info.init_value = EditorGUILayout.IntField(custom_vertex_info.init_value, GUILayout.Width(100));
        custom_vertex_info.operation_char = EditorGUILayout.Popup(custom_vertex_info.operation_char, kOperationStringList, GUILayout.Width(50));
        EditorGUILayout.LabelField("运算值：", GUILayout.Width(50));
        custom_vertex_info.rate_value = EditorGUILayout.IntField(custom_vertex_info.rate_value, GUILayout.Width(100));
        EditorGUILayout.EndHorizontal();
    }
    void ChangeSelectObjectNames()
    {
        if (is_quick_up)
        {
            for (int i = 0; i < all_name_info.Length; ++i) all_name_info[i].new_name = (i + 1).ToString();
        }
        else if (is_quick_down)
        {
            for (int i = 0; i < all_name_info.Length; ++i) all_name_info[i].new_name = (0 - i - 1).ToString();
        }
        if (string.IsNullOrEmpty(target_name)) return;
        string cur_operation = kOperationStringList[custom_vertex_info.operation_char];
        int new_value = custom_vertex_info.init_value;
        for (int i = 0; i < all_name_info.Length; ++i)
        {
            string new_name_str = string.Copy(target_name);
            if (!string.IsNullOrEmpty(custom_vertex_info.convert_char))
            {
                switch (cur_operation)
                {
                    case "+":
                        {
                            new_value += custom_vertex_info.rate_value;
                            break;
                        }
                    case "-":
                        {
                            new_value -= custom_vertex_info.rate_value;
                            break;
                        }
                    case "*":
                        {
                            new_value *= custom_vertex_info.rate_value;
                            break;
                        }
                    case "%":
                        {
                            new_value = custom_vertex_info.rate_value == 0 ? new_value: (new_value / custom_vertex_info.rate_value);
                            break;
                        }
                }
                new_name_str = new_name_str.Replace(custom_vertex_info.convert_char, new_value.ToString());
            }
            all_name_info[i].new_name = new_name_str;
        }
    }
    #endregion
    #region 引用资源统计查找定位
    string search_directory_path = null;
    float search_process = 0;
    float ver_scroll_index = 0;
    class SearchObjInfo
    {
        public string obj_path;
        public string lua_path;
        public bool is_select = false;
        public List<string> ref_path_list = new List<string>();
    }
    List<SearchObjInfo> search_obj_list = new List<SearchObjInfo>();
    IEnumerator search_func = null;
    IEnumerator dependencies_func = null;
    void UpdateSearchRefOnGUI()
    {
        EditorGUILayout.BeginVertical();
        EditorGUILayout.LabelField("********************资源引用查找定位，包括在Excel表中查找*******************");
        EditorGUILayout.LabelField("查找路径填写规范（快捷方式-->在Unity里选中文件夹或资源，然后点击鼠标右键，选择弹框里的CopyPath，然后粘贴到下面）");
        EditorGUILayout.LabelField("1.单个资源类型模板-->Assets/Res/UIRes/Icon/EquipPart/cloth.png");
        EditorGUILayout.LabelField("2.文件夹类型模板--> Assets/Res/UIRes/Icon/EquipPart");
        search_directory_path = EditorGUILayout.TextField("查找路径", search_directory_path);
        asset_search_rate = EditorGUILayout.IntField("查找速度", asset_search_rate);
        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("查找被谁引用") && !string.IsNullOrEmpty(search_directory_path))
        {
            search_func = RunningRefSearchFunc();
            search_func.MoveNext();
        }
        if (GUILayout.Button("查找引用了谁") && !string.IsNullOrEmpty(search_directory_path))
        {
            dependencies_func = RunningDependenciesSearchFunc();
            dependencies_func.MoveNext();
        }
        if (GUILayout.Button("删除选中资源")) ClickSearchDelAssetBtn();
        if (GUILayout.Button("按引用增加排序")) ClickSearchSortAssetBtn(true);
        if (GUILayout.Button("按引用减少排序")) ClickSearchSortAssetBtn(false);
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.EndVertical();
        if (search_obj_list.Count > 0 && search_process < 1)
        {
            EditorGUILayout.LabelField(string.Format("********查找总进度--> {0}%", search_process * 100));
        }
        if (search_obj_list.Count == 0 || search_process < 1) return;
        using (new EditorGUILayout.HorizontalScope())
        {
            const int k_view_item_count = 25;
            const float k_item_height = 20;
            int cur_item_index = 0;
            Event cur_evt = Event.current;
            using (var scroll_view = new EditorGUILayout.VerticalScope())
            {
                for (int i = 0; i < search_obj_list.Count; ++i)
                {
                    var u_obj_info = search_obj_list[i];
                    if (cur_item_index >= this.ver_scroll_index && cur_item_index <= this.ver_scroll_index + k_view_item_count)
                    {
                        using (var hor_scope = new EditorGUILayout.HorizontalScope()) {
                            Color gui_color = GUI.contentColor;
                            GUI.contentColor = u_obj_info.is_select ? Color.red : Color.green;
                            u_obj_info.is_select = EditorGUILayout.Toggle(u_obj_info.is_select, GUILayout.Width(20), GUILayout.Height(k_item_height));
                            EditorGUILayout.LabelField("目标资源-->" + u_obj_info.obj_path, GUILayout.Height(k_item_height));
                            if (GUILayout.Button(string.Format("定位资源({0}个引用)", u_obj_info.ref_path_list.Count), GUILayout.Height(k_item_height)))
                            {
                                Selection.activeObject = AssetDatabase.LoadAssetAtPath(u_obj_info.obj_path, typeof(UnityEngine.Object));
                            }
                            if (cur_evt != null && cur_evt.rawType == EventType.MouseDown && cur_evt.button == 0 &&
                                hor_scope.rect.Contains(cur_evt.mousePosition))
                            {
                                u_obj_info.is_select = !u_obj_info.is_select;
                                if(cur_evt.shift)
                                {
                                    for(int j = i - 1;j >= 0; --j)
                                    {
                                        var last_obj_info = search_obj_list[j];
                                        if (last_obj_info.is_select != u_obj_info.is_select) last_obj_info.is_select = u_obj_info.is_select;
                                        else break;
                                    }
                                }
                                cur_evt.Use();
                            }
                            GUI.contentColor = gui_color;
                        }
                    }
                    ++cur_item_index;
                    for (int k = 0; k < u_obj_info.ref_path_list.Count; ++k)
                    {
                        if (cur_item_index >= this.ver_scroll_index && cur_item_index <= this.ver_scroll_index + k_view_item_count)
                        {
                            EditorGUILayout.BeginHorizontal();
                            var ref_path = u_obj_info.ref_path_list[k];
                            EditorGUILayout.LabelField(string.Format("\t{0}.{1}", k + 1, ref_path), GUILayout.Height(k_item_height));
                            if (GUILayout.Button("定位资源", GUILayout.Height(k_item_height), GUILayout.Width(200)))
                            {
                                Selection.activeObject = AssetDatabase.LoadAssetAtPath(ref_path, typeof(UnityEngine.Object));
                            }
                            EditorGUILayout.EndHorizontal();
                        }
                        ++cur_item_index;
                    }
                }
                if (cur_evt != null &&cur_evt.isScrollWheel && scroll_view.rect.Contains(cur_evt.mousePosition))
                {
                    float scroll_dist = cur_evt.delta.y;
                    ver_scroll_index = Mathf.Clamp(ver_scroll_index + scroll_dist, 0, cur_item_index);
                    if (Mathf.Abs(scroll_dist) > 1e-3) cur_evt.Use();
                }
            }
            ver_scroll_index = GUILayout.VerticalScrollbar(ver_scroll_index, 1f, 0f, cur_item_index - k_view_item_count,
                GUILayout.Height((k_item_height + EditorGUIUtility.standardVerticalSpacing) * k_view_item_count));
        }
    }
    void UpdateRefSearchProcess()
    {
        for (int i = 0; i < asset_search_rate; ++i)
        {
            if (search_func != null) { search_func.MoveNext();}
            else if (dependencies_func != null) dependencies_func.MoveNext();
        }
    }
    void ClickSearchDelAssetBtn()
    {
        string hint_str = "";
        foreach(var obj_info in search_obj_list)
        {
            if (obj_info.is_select) { hint_str += "\n"+ obj_info.obj_path; }
        }
        if (string.IsNullOrEmpty(hint_str)) return;
        if(EditorUtility.DisplayDialog("删除资源", hint_str, "确定（资源删除后不能恢复）", "取消"))
        {
            for (int i = search_obj_list.Count - 1; i >= 0; --i)
            {
                var obj_info = search_obj_list[i];
                if (obj_info.is_select)
                {
                    AssetDatabase.DeleteAsset(obj_info.obj_path);
                    search_obj_list.RemoveAt(i);
                }
            }
            AssetDatabase.RemoveUnusedAssetBundleNames();
            AssetDatabase.Refresh();
        }
    }
    void ClickSearchSortAssetBtn(bool is_positive)
    {
        if (search_obj_list == null || search_obj_list.Count <= 1) return;
        search_obj_list.Sort((info_a, info_b) =>
        {
            int compare_v = 0;
            if (is_positive) compare_v = info_a.ref_path_list.Count.CompareTo(info_b.ref_path_list.Count);
            else compare_v = info_b.ref_path_list.Count.CompareTo(info_a.ref_path_list.Count);
            compare_v = compare_v == 0 ? info_a.obj_path.CompareTo(info_b.obj_path) : compare_v;
            return compare_v;
        });
    }
    IEnumerator RunningRefSearchFunc()
    {
        search_obj_list.Clear();
        dependencies_func = null;
        Dictionary<string, SearchObjInfo> search_info_dic = new Dictionary<string, SearchObjInfo>();
        //find all file asset path
        List<string> all_obj_path_list = new List<string>();
        GetAllFileFromDirectory(search_directory_path, ref all_obj_path_list);
        search_process = all_obj_path_list.Count > 0 ? 0 : 1;
        if (all_obj_path_list.Count == 0) search_func = null;
        yield return null;
        for (int i = 0; i < all_obj_path_list.Count; ++i)
        {
            var u_info = new SearchObjInfo();
            u_info.obj_path = all_obj_path_list[i];
            string lua_obj_path = Path.GetDirectoryName(u_info.obj_path) + "/" + Path.GetFileNameWithoutExtension(u_info.obj_path);
            lua_obj_path = lua_obj_path.Replace(k_lua_asset_path, "");
            u_info.lua_path = lua_obj_path;
            search_info_dic.Add(u_info.obj_path, u_info);
        }
        search_obj_list.AddRange(search_info_dic.Values);
        //
        float total_process_index = 0;
        //find ref from Lua Data
        var all_lua = LuaScriptReader.GetAllLua();
        yield return null;
        foreach (var kv in all_lua)
        {
            string lua_data_str = kv.Value;
            foreach (var u_info in search_info_dic.Values)
            {
                if (lua_data_str.Contains(u_info.lua_path))
                {
                    u_info.ref_path_list.Add(kv.Key);
                }
            }
            ++total_process_index;
            search_process = Mathf.Clamp01(total_process_index / (s_all_asset_path.Length + all_lua.Count));
            base.Repaint();
            yield return null;
        }
        //find ref from unity asset
        for (int i = 0; i < s_all_asset_path.Length; ++i) {
            string cur_asset_path = s_all_asset_path[i];
            foreach (var path in AssetDatabase.GetDependencies(cur_asset_path, true)) {
                SearchObjInfo obj_info;
                if (cur_asset_path != path && search_info_dic.TryGetValue(path, out obj_info)) {
                    obj_info.ref_path_list.Add(cur_asset_path);
                }
            }
            ++total_process_index;
            search_process = Mathf.Clamp01(total_process_index / (s_all_asset_path.Length + all_lua.Count));
            base.Repaint();
            yield return null;
        }
        search_process = 1;
        search_func = null;
        base.Repaint();
    }
    IEnumerator RunningDependenciesSearchFunc()
    {
        search_func = null;
        search_obj_list.Clear();
        List<string> all_obj_path_list = new List<string>();
        GetAllFileFromDirectory(search_directory_path, ref all_obj_path_list);
        search_process = all_obj_path_list.Count > 0 ? 0 : 1;
        yield return null;
        for(int i = 0; i < all_obj_path_list.Count; ++i)
        {
            var obj_path = all_obj_path_list[i];
            SearchObjInfo obj_info = new SearchObjInfo();
            search_obj_list.Add(obj_info);
            obj_info.obj_path = obj_path;
            foreach (var path in AssetDatabase.GetDependencies(obj_path, true))
            {
                if(path != obj_path) obj_info.ref_path_list.Add(path);
            }
            search_process = (i + 1f) / all_obj_path_list.Count;
            base.Repaint();
            yield return null;
        }
        dependencies_func = null;
        base.Repaint();
    }
    #endregion
}
