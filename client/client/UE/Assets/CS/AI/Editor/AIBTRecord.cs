using System.Collections.Generic;
using System.IO;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Formatters.Binary;
using UnityEditor;
using UnityEngine;

namespace AI
{
    public class AIBTRecord : ScriptableObject
    {
        private List<string> _tree_list_;
        public List<AIBTGroup> ai_bt_group_list;

        public List<string> TreeList
        {
            get
            {
                if (_tree_list_ == null)
                {
                    string[] files = Directory.GetFiles(AIConst.SAVE_AI_TREE_RECORD, "*.asset");
                    _tree_list_ = new List<string>();
                    foreach (string file in files)
                    {
                        _tree_list_.Add(Path.GetFileNameWithoutExtension(file));
                    }
                    _tree_list_.Sort();
                }
                return _tree_list_;
            }
        }

        public void SaveTree(AIBTData tree_data)
        {
            EditorUtility.SetDirty(tree_data);
            AssetDatabase.SaveAssets();
        }

        public AIBTData LoadTree(string name)
        {
            string path = Path.Combine(AIConst.LOGICDATA_PATH, name + ".asset");
            if (!File.Exists(path))
            {
                Debug.LogError("找不到树: " + name + " " + path + " 已忽略！");
                return null;
            }
            AIBTData data = AssetDatabase.LoadAssetAtPath(GetFilePath(name), typeof(AIBTData)) as AIBTData;
            return data;
        }

        public void UpdateTrees()
        {
            string file_path = AIConst.LOGICDATA_PATH;
            if (_tree_list_ != null) _tree_list_.Clear();
            else _tree_list_ = new List<string>();

            string[] paths = Directory.GetFiles(file_path, "*.asset", SearchOption.AllDirectories);
            foreach (string file in paths)
            {
                _tree_list_.Add(Path.GetFileNameWithoutExtension(file));
            }
            _tree_list_.Sort();
        }

        public bool AddTree(string name)
        {
            if (_tree_list_ == null) return false;
            string lower = name.ToLower();      // windows文件系统不区分大小写
            foreach (string n in _tree_list_)
            {
                if (lower == n.ToLower()) return false;
            }
            string path = GetFilePath(name);
            AIBTData ai_tree = ScriptableObject.CreateInstance<AIBTData>();
            ai_tree.ai_name_ = name;
            AssetDatabase.CreateAsset(ai_tree, path);
            AssetDatabase.Refresh();
            EditorUtility.SetDirty(this);
            _tree_list_.Add(name);
            _tree_list_.Sort();
            return true;
        }

        public string GetFilePath(string id)
        {
            return AIConst.SAVE_AI_TREE_RECORD + id + ".asset";
        }

        public void CopyTree(string refer_name, string name, string group_name)
        {
            if (_tree_list_ == null) return;
            string lower = name.ToLower();
            foreach (string n in _tree_list_)
            {
                if (lower == n.ToLower())
                {
                    Debug.LogError(string.Format("复制失败！名字{0}已存在", refer_name));
                    return;
                }
            }
            AIBTData tree = LoadTree(refer_name);
            if (tree == null)
            {
                Debug.LogError(string.Format("复制失败！该AI数据{0}不存在", refer_name));
                return;
            }
            AIBTData new_tree = ScriptableObject.CreateInstance<AIBTData>();
            new_tree.ai_name_ = name;
            tree.Copy(new_tree);
            string new_path = GetFilePath(name);
            AssetDatabase.CreateAsset(new_tree, new_path);
            _tree_list_.Add(name);
            _tree_list_.Sort();
            for (int i = 0; i < ai_bt_group_list.Count; i++)
            {
                AIBTGroup group = ai_bt_group_list[i];
                if (group.ai_bt_group_name == group_name)
                {
                    group.member_name_list_.Add(name);
                    break;
                };
            }
            EditorUtility.SetDirty(this);
            AssetDatabase.SaveAssets();
            Debug.LogError("复制成功！");
            return;
        }

        public void RemoveTree(string name, int group_index)
        {
            if (_tree_list_ == null) return;
            ai_bt_group_list[group_index].member_name_list_.ForEach(x =>
            {
                if (x == name)
                {
                    ai_bt_group_list[group_index].member_name_list_.Remove(name);
                }
            });
            AssetDatabase.DeleteAsset(GetFilePath(name));
            AssetDatabase.SaveAssets();
            _tree_list_.Remove(name);
        }

        public bool Export()
        {
            EditorUtility.SetDirty(this);
            AssetDatabase.SaveAssets();
            if (Directory.Exists(AIConst.EXPORT_PATH)) Directory.Delete(AIConst.EXPORT_PATH, true);

            Directory.CreateDirectory(AIConst.EXPORT_PATH);
            string file_path;
            AIBTData tree;
            foreach (string name in TreeList)
            {
                tree = LoadTree(name);
                if (tree == null) continue;

                file_path = Path.Combine(AIConst.EXPORT_PATH, "ai_" + name + ".lua");
                File.WriteAllText(file_path, "return " + tree.GenLtable(false).encode());
            }
            return true;
        }

        public bool Export(AIBTData tree)
        {
            if (!TreeList.Contains(tree.ai_name_)) return false;

            if (tree == null) return false;

            AssetDatabase.SaveAssets();
            if (!Directory.Exists(AIConst.EXPORT_PATH)) Directory.CreateDirectory(AIConst.EXPORT_PATH);

            string file_path = Path.Combine(AIConst.EXPORT_PATH, "ai_" + tree.ai_name_ + ".lua");
            File.WriteAllText(file_path, "return " + tree.GenLtable(false).encode());
            return true;
        }
    }

    [System.Serializable]
    public class AIBTGroup
    {
        public string ai_bt_group_name;
        public List<string> member_name_list_ = new List<string>();
        public bool is_show = false;
    }
}
