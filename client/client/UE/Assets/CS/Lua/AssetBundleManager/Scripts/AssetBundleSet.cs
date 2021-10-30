using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine.SceneManagement;

namespace AssetBundles {
    public class AssetBundleSet {
        public struct AssetBundleInfo {
            public string md5_;
            public int size_;
            public AssetBundleInfo(string md5, int size) {
                md5_ = md5;
                size_ = size;
            }
        }

        public string path_;
        public int svn_version_;
        public string md5_;
        public string time_;
        public AssetBundleManifest manifest_;
        [SLua.DoNotToLua]
        public Dictionary<string, AssetBundleInfo> list_;

        public AssetBundleSet(string path) {
            path_ = path;
        }

        public void ReadSet() {
            string list_path = Path.Combine(path_, AssetBundleConst.set_filename);
            var content = _ReadFile(list_path);
            if (content == null) {
                Debug.Log("ReadSet error:" + list_path);
                return;
            }
            list_ = new Dictionary<string, AssetBundleInfo>();
            var mem_stream = new MemoryStream(content);
            var b_reader = new BinaryReader(mem_stream);
            try {
                while (true) {
                    int n_len = b_reader.ReadInt32();
                    char[] c_name = b_reader.ReadChars(n_len);
                    string ab_name = new string(c_name);
                    int md5_len = b_reader.ReadInt32();
                    char[] c_md5 = b_reader.ReadChars(md5_len);
                    string md5 = new string(c_md5);
                    int size = b_reader.ReadInt32();
                    list_[ab_name] = new AssetBundleInfo(md5, size);
                }
            } catch (EndOfStreamException) {
                // Debug.Log("eoffffegegegegeg======");
            } finally {
                b_reader.Close();
                mem_stream.Close();
            }
        }

        public void WriteSet() {
            if (list_ == null) return;
            string list_path = Path.Combine(path_, AssetBundleConst.set_filename);
            FileStream tmp_tar_file_stream = File.Create(list_path);
            var b_writer = new BinaryWriter(tmp_tar_file_stream);
            foreach (var keyvalue in list_) {
                b_writer.Write(keyvalue.Key.Length);
                b_writer.Write(keyvalue.Key.ToCharArray());
                b_writer.Write(keyvalue.Value.md5_.Length);
                b_writer.Write(keyvalue.Value.md5_.ToCharArray());
                b_writer.Write(keyvalue.Value.size_);
            }
            tmp_tar_file_stream.Flush();
            b_writer.Close();
            tmp_tar_file_stream.Close();
        }

        public bool ReadVersion() {
            string info_path = Path.Combine(path_, AssetBundleConst.set_version_filename);
            var content = _ReadFile(info_path);
            if (content == null) {
                Debug.Log("ReadVersion error:" + info_path);
                return false;
            }
            var reader = new StreamReader(new MemoryStream(content));
            svn_version_ = int.Parse(reader.ReadLine());
            md5_ = reader.ReadLine();
            time_ = reader.ReadLine();
            return true;
        }

        public void WriteVersion() {
            string info_path = Path.Combine(path_, AssetBundleConst.set_version_filename);
            File.WriteAllText(
                info_path,
                svn_version_ + "\n" +
                md5_ + "\n" +
                time_ + "\n");
        }

        public void ReadManifest() {
            string manifest_path = Path.Combine(path_, AssetBundleConst.GetPlatformName());
            var ab = AssetBundle.LoadFromFile(manifest_path);
            manifest_ = ab.LoadAsset<AssetBundleManifest>("AssetBundleManifest");
            ab.Unload(false);
        }

        public void Add(string ab_name, string md5, int size) {
            if (list_ == null) {
                list_ = new Dictionary<string, AssetBundleInfo>();
            }
            AssetBundleInfo info;
            if (list_.TryGetValue(ab_name, out info)) {
                info.md5_ = md5;
                info.size_ = size;
            } else {
                info = new AssetBundleInfo(md5, size);
                list_[ab_name] = info;
            }
        }

        public string GetMD5(string ab_name) {
            if (list_.ContainsKey(ab_name)) {
                return list_[ab_name].md5_;
            }
            return "";
        }

        public int GetSize(string ab_name) {
            if (list_.ContainsKey(ab_name)) {
                return list_[ab_name].size_;
            }
            return 0;
        }

        byte[] _ReadFile(string path) {
            if (path.Contains("://")) {
                WWW www = new WWW(path);
                while (!www.isDone) ;
                if (www.error != null) {
                    Debug.Log("_ReadFile error:" + www.error + ":" + path);
                    return null;
                }
                return www.bytes;
            } else {
                if (!File.Exists(path)) {
                    Debug.Log("_ReadFile error:file not exist :" + path);
                    return null;
                }
                return File.ReadAllBytes(path);
            }
        }
    }

}
