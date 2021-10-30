using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEditor;
using System.IO;
public class LuaReload {
    [MenuItem("Lua/ReloadAll %#H")]
    public static void ReloadAll() {
        string excel_bat_path = Application.dataPath + "/../../";
        System.Diagnostics.Process proc = null;
        try
        {
            proc = new System.Diagnostics.Process();
            proc.StartInfo.FileName = excel_bat_path + "makeexceldatapause.bat";
            Debug.Log(proc.StartInfo.FileName);
            proc.StartInfo.Arguments = excel_bat_path;
            proc.StartInfo.CreateNoWindow = false;
            // proc.StartInfo.UseShellExecute = false;
            proc.Start();
            proc.WaitForExit();
        }
        catch (System.Exception ex)
        {
            Debug.Log(string.Format("Exception Occurred :{0},{1}", ex.Message, ex.StackTrace.ToString()));
        }
        ReloadScripts();
    }
    [MenuItem("Lua/ReloadScripts")]
    public static void ReloadScripts()
    {
        if (EditorApplication.isPlaying)
        {
            var go = GameObject.Find("GameEntry");
            var game_entry = GameEntry.Instance;
            if (go != null && game_entry != null && game_entry.game_lua_entry_ != null)
            {
                game_entry.game_lua_entry_.Check2Reload();
            }
        }
    }
    [MenuItem("Lua/ReportUIString(1)", false, 12)]
    public static void ExportUIString()
    {
        if (EditorApplication.isPlaying)
        {
            return;
        }
        string UI_PREFAB_PATH = Application.dataPath + "/Res/UI";
        string UI_EXPORT_PATH = Application.dataPath + "/../../../sharedata/exceldata/tools/tranlation/";
        string CSV_FILE_NAME = "ui_string.csv";
        string FORMAT_STRING = "{0},{1},{2}"; //uiname, comp_id, text
        string file_path = UI_EXPORT_PATH + CSV_FILE_NAME;
        if (Directory.Exists(UI_EXPORT_PATH))
        {
            if (File.Exists(file_path))
            {
                File.Delete(file_path);
            }
            DirectoryInfo directiory = new DirectoryInfo(UI_PREFAB_PATH);
            FileInfo[] infos = directiory.GetFiles("*.prefab", SearchOption.AllDirectories);
            List<FileInfo> infos_list = new List<FileInfo>(infos);
            infos_list.Sort((a, b) => {
                return a.Name.CompareTo(b.Name);
            });
            StreamWriter writer = new StreamWriter(file_path, true, System.Text.Encoding.UTF8);
            float length = infos_list.Count;
            for (int i = 0; i < infos_list.Count; i++)
            {
                FileInfo file = infos_list[i];
                GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(file.FullName.Substring(file.FullName.IndexOf("Assets")));
                Text[] text_comps = prefab.GetComponentsInChildren<Text>(true);
                if (text_comps.Length > 0)
                {
                    EditorUtility.DisplayProgressBar("生成UI字符串", prefab.name, (i + 1) / length);
                    foreach (Text text_comp in text_comps)
                    {
                        string text = text_comp.text;
                        if (!string.IsNullOrEmpty(text))
                        {
                            writer.WriteLine(string.Format(FORMAT_STRING, prefab.name, text_comp.GetInstanceID(), '\"' + text + '\"'));
                        }
                    }
                }
            }
            writer.Close();
            EditorUtility.ClearProgressBar();
            Debug.LogFormat("export ui text success, file path{0}", file_path);
        }
        else
        {
            Debug.LogErrorFormat("not found export path {0}", UI_EXPORT_PATH);
        }
    }


    [MenuItem("Lua/GenerateTranlation(2)", false, 13)]
    public static void GenerateTranlation()
    {
        string excel_bat_path = Application.dataPath + "/../../../sharedata/exceldata/tools/tranlation/";
        System.Diagnostics.Process proc = null;
        try
        {
            proc = new System.Diagnostics.Process();
            proc.StartInfo.FileName = excel_bat_path + "maketranlation.bat";
            Debug.Log(proc.StartInfo.FileName);
            proc.StartInfo.Arguments = excel_bat_path;
            proc.StartInfo.CreateNoWindow = false;
            // proc.StartInfo.UseShellExecute = false;
            proc.Start();
            proc.WaitForExit();
        }
        catch (System.Exception ex)
        {
            Debug.Log(string.Format("Exception Occurred :{0},{1}", ex.Message, ex.StackTrace.ToString()));
        }
        ReloadScripts();
    }
}
