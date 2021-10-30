using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;

public class LuaScriptReader {
    static Dictionary<string, byte[]> lua_dict_ = new Dictionary<string, byte[]>();
    public static List<string> pack_list = new List<string> { "sctexture_d", "sctexture_m" };

#if UNITY_EDITOR
    // 注意必须以sctexture开头，打包脚本提svn有hardcode
    public static Dictionary<string, string> pack_filter = new Dictionary<string, string> {
        {"sctexture_d", "^Data/"},
        {"sctexture_m", ""},
    };
    public static string lua_raw_path_ = Application.dataPath + "/../../LuaScript/";

    Dictionary<string, System.DateTime> _readed_lua_filed_ = new Dictionary<string, System.DateTime>();

    public static Dictionary<string, string> GetAllLua() {
        InitReader();
        var result = new Dictionary<string, string>();
        byte[] byte_buf = null;
        foreach (var kv in lua_dict_) {
            if (kv.Value.Length <= 4) continue;
            SLua.LuaDLLWrapper.UnpackLua(kv.Value, kv.Value.Length, out byte_buf);
            result[kv.Key] = System.Text.Encoding.UTF8.GetString(byte_buf);
        }
        return result;
    }
#endif

    public static void InitReader() {
        foreach (var pack_name in pack_list) {
            TextAsset pack = GameResourceMgr.LoadAssetSync(pack_name, typeof(TextAsset)) as TextAsset;
            if (pack == null) {
                Debug.Log("Init Script Bytes Read failed!");
            } else {
                ReadDictInner(pack.bytes);
            }
        }
    }

    static void ReadDictInner(byte[] org_file_content) {
        var mem_stream = new MemoryStream(org_file_content);
        var b_reader = new BinaryReader(mem_stream);
        try {
            while (true) {
                int name_length = b_reader.ReadInt32();
                char[] file_name = b_reader.ReadChars(name_length);
                string f_n = new string(file_name);
                int content_length = b_reader.ReadInt32();
                byte[] file_content = b_reader.ReadBytes(content_length);
                lua_dict_[f_n] = file_content;
                // Debug.Log(name_length + ":" + content_length + ":" + f_n); 
            }
        } catch (EndOfStreamException) {
            // Debug.Log("eoffffegegegegeg======");
        } finally {
            b_reader.Close();
            mem_stream.Close();
        }
    }
    public static bool HasFile(string file_name) {
        return lua_dict_.ContainsKey(file_name);
    }
    public static byte[] GetData(string file_name) {
        return lua_dict_[file_name];
    }
    static string _CheckFileName(string file_name) {
        string low_name = file_name.ToLower();
        if (low_name.EndsWith(".lua")) {
            return file_name;
        } else {
            return file_name + ".lua";
        }
    }

    public void DoInit() {
        SLua.LuaState.loaderDelegate = LuaLoader;
        InitReader();
    }

    public byte[] LuaLoader(string file_name) {
        file_name = file_name.Replace(".", "/");
        byte[] ret = null;
        file_name = _CheckFileName(file_name);
#if UNITY_EDITOR
        System.DateTime dt = new System.DateTime();
        string path = lua_raw_path_ + file_name;
        if (File.Exists(path)) {
            byte[] file_content = File.ReadAllBytes(path);
            SLua.LuaDLLWrapper.PackLua(file_content, file_content.Length, out ret);
            if (ret != null) {
                dt = File.GetLastWriteTime(path);
                _readed_lua_filed_[file_name] = dt;
            } else {
                if (HasFile(file_name)) {
                    ret = GetData(file_name);
                }
            }
        } else {
            if (HasFile(file_name)) {
                ret = GetData(file_name);
            }
        }
#else
        if (HasFile(file_name)) {
            ret = GetData(file_name);
        }
#endif
        return ret;
    }
    public void Check2Reload() {
#if UNITY_EDITOR
        foreach (var item in _readed_lua_filed_) {
            string name = item.Key;
            System.DateTime dt = item.Value;
            string path = lua_raw_path_ + name;
            if (File.Exists(path)) {
                if (dt != File.GetLastWriteTime(path)) {
                    string lua_name = name.Replace("/", ".");
                    lua_name = lua_name.Replace("\\", ".");
                    if (lua_name.EndsWith(".lua")) {
                        lua_name = lua_name.Replace(".lua", "");
                    }
                    GameEventMgr.GetInstance().GenerateEvent(GameEventMgr.ET_LuaReload, null, lua_name);
                }
            }
        }
#endif
    }
}
