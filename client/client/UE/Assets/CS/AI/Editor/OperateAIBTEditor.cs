using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace AI
{
    public class OperateAIBTEditor : EditorWindow
    {
        public AIBTRecord record_;
        public int group_id_;
        public int new_group_id_;
        public int ai_bt_index_;
        public int op_type_;
        public List<string> group_name_list = new List<string>();
        private string ai_bt_name = "";

        public static void OperateAIBT(AIBTRecord record, int group_id, int ai_bt_index, int op_type)
        {
            string title = "";
            if (op_type == AIConst.OPERATE_TYPE_PASTE)
            {
                title = "粘贴副本";
            }
            else if (op_type == AIConst.OPERATE_TYPE_UPDATE_DATA)
            {
                title = "修改副本";
            }
            OperateAIBTEditor window = EditorWindow.GetWindow(typeof(OperateAIBTEditor), true, title) as OperateAIBTEditor;
            window.record_ = record;
            window.group_id_ = group_id;
            window.ai_bt_index_ = ai_bt_index;
            window.new_group_id_ = group_id;
            window.op_type_ = op_type;
            window.Init();
        }

        public void Init()
        {
            group_name_list.Clear();
            record_.ai_bt_group_list.ForEach(x =>
            {
                group_name_list.Add(x.ai_bt_group_name);
            });
        }

        private void OnGUI()
        {
            EditorGUILayout.BeginVertical();
            new_group_id_ = EditorGUILayout.Popup("分组类型：", new_group_id_, group_name_list.ToArray());
           
            if (op_type_ == AIConst.OPERATE_TYPE_PASTE)
            {
                EditorGUILayout.LabelField("复制目标：" + record_.ai_bt_group_list[group_id_].member_name_list_[ai_bt_index_]);
                ai_bt_name = EditorGUILayout.TextField(ai_bt_name);
            }
            else if (op_type_ == AIConst.OPERATE_TYPE_UPDATE_DATA)
            {
                EditorGUILayout.LabelField("修改目标：" + record_.ai_bt_group_list[group_id_].member_name_list_[ai_bt_index_]);
            }
            if (GUILayout.Button("保存"))
            {
                if (op_type_ == AIConst.OPERATE_TYPE_PASTE)
                {
                    PasteAIBT();
                }
                else
                {
                    UpdateAIBTData();
                }
                Close();
            }
            EditorGUILayout.EndVertical();

        }

        public void PasteAIBT()
        {
            if (record_.ai_bt_group_list[group_id_] == null)
            {
                ShowNotification(new GUIContent(string.Format("组名错误{0}", ai_bt_name)));
                return;
            }
            string refer_name = record_.ai_bt_group_list[group_id_].member_name_list_[ai_bt_index_];
            string group_name = record_.ai_bt_group_list[new_group_id_].ai_bt_group_name;
            record_.CopyTree(refer_name, ai_bt_name, group_name);
        }

        public void UpdateAIBTData()
        {
            string member_name_ = record_.ai_bt_group_list[group_id_].member_name_list_[ai_bt_index_];
            if (group_id_ != new_group_id_)
            {
                record_.ai_bt_group_list[group_id_].member_name_list_.Remove(member_name_);
                record_.ai_bt_group_list[new_group_id_].member_name_list_.Add(member_name_);
            }
        }
    }
}
