using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.IO;
using System.Collections;
using System.IO.Compression;
using System.Text.RegularExpressions;

public class PackScripts {
    public static string luac_win_path = "E:/lua/lua-5.3.0/src/luac.exe";   ///../../Build/tools/luac.exe
    public static string luac_mac_path = "/Users/a123/Desktop/lua-5.3.0/src/luac";    ///../../Build/tools/luac

    [MenuItem("Lua/Pack/PackScripts")]
    public static void PackAll() {
        Debug.Log("AssetBundle顺序--4--");
        var root_path = Path.GetFullPath(LuaScriptReader.lua_raw_path_);
        Debug.Log("AssetBundle顺序--5--" + root_path);
        if (!Directory.Exists(root_path)) {
            Debug.Log("文件目录不存在：" + root_path);
        }
        var file_infos = new DirectoryInfo(root_path).GetFiles("*.lua", SearchOption.AllDirectories);
        Debug.Log("AssetBundle顺序--6--" + file_infos);
        var file_paths = System.Array.ConvertAll<FileInfo, string>(file_infos, (info) => {
            return info.FullName.Replace(root_path, "").Replace("\\", "/");
        });
        System.Array.Sort(file_paths);
        var total_count = file_paths.Length;
        float done_count = 0;
        EditorUtility.DisplayProgressBar("PackScripts", "", 0);
        var pack_file_list = new Dictionary<string, List<string>> ();
        foreach(var pack_name in LuaScriptReader.pack_list) {
            Debug.Log("Lua脚本----1----" + pack_name);
            var filter = LuaScriptReader.pack_filter[pack_name];
            Debug.Log("Lua脚本---2----" + filter);
            var pack_path = Application.dataPath + "/Res/" + pack_name + ".bytes";
            Debug.Log("Lua脚本---3----" + pack_path);
            FileStream stream = File.Create(pack_path);
            var writer = new BinaryWriter(stream);
            for (int i = 0; i < file_paths.Length; ++i) {
                var path = file_paths[i];
                Debug.Log("Lua脚本---99----" + path);
                if (path != null && Regex.IsMatch(path, filter, RegexOptions.IgnoreCase)) {
                    writer.Write(path.Length);
                    writer.Write(path.ToCharArray());
                    byte[] file_content = CompileLua(Path.Combine(root_path, path));
                    if (file_content != null) {
                        byte[] pack_content;
                        var ret = SLua.LuaDLLWrapper.PackLua(file_content, file_content.Length, out pack_content);
                        writer.Write(pack_content.Length);
                        writer.Write(pack_content);
                    } else {
                        writer.Write(0);
                    }
                    ++done_count;
                    file_paths[i] = null;
                    EditorUtility.DisplayProgressBar("PackScripts", pack_name + " " + path, done_count / total_count);
                }
            }
            writer.Close();
            stream.Close();
        }
        AssetDatabase.Refresh();
        EditorUtility.ClearProgressBar();
        Debug.Log("=============== PackScripts Finished ===============");
    }
    
    static byte[] CompileLua(string lua_path) {
        string luac_path;
        if (Application.platform == RuntimePlatform.OSXEditor) {
            luac_path = luac_mac_path;
        } else {
            luac_path = luac_win_path;
        }
        var output_path = lua_path + "c";
        var processInfo = new System.Diagnostics.ProcessStartInfo(
            luac_path,
            string.Format("-o {0} {1}", output_path, lua_path)); //Application.dataPath +
        processInfo.CreateNoWindow = true;
        processInfo.UseShellExecute = false;
        processInfo.RedirectStandardError = true;

        var process = System.Diagnostics.Process.Start(processInfo);

        process.WaitForExit();
        byte[] bytes = null;
        if (process.ExitCode == 0) {
            bytes = File.ReadAllBytes(output_path);
            File.Delete(output_path);
        } else {
            Debug.LogErrorFormat("Lua Compile Error: {0} {1}", lua_path, process.StandardError.ReadToEnd());
        }
        process.Close();
        return bytes;
    }
}
