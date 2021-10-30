using System;
using UnityEditor;
using UnityEngine;

namespace AI
{
    [CustomEditor(typeof(AIBTRecord))]
    public class AIBTInspector : Editor
    {
        private int copy_group_index;
        private string copy_tree_ = "";
        private AIBTRecord record_;
        GUIStyle box_style_;

        public void OnEnable()
        {
            record_ = (target as AIBTRecord);
            record_.UpdateTrees();
        }

        public override void OnInspectorGUI()
        {
            box_style_ = new GUIStyle(EditorStyles.helpBox)
            {
                padding = new RectOffset(10, 10, 10, 10),
            };

            EditorGUILayout.BeginVertical();
            GUILayoutOption[] btn_options;
            btn_options = new GUILayoutOption[]
            {
                GUILayout.Width(EditorGUIUtility.currentViewWidth / 2),
                GUILayout.Height(30),
            };
            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("创建", btn_options))
            {
                CreateAIEditor.OpenAIWindow(record_);
            }
            if (GUILayout.Button("导出", btn_options))
            {
                if (record_.Export())
                {
                    AssetDatabase.SaveAssets();
                    EditorUtility.DisplayDialog("导出所有AI", "导出成功", "好的");
                }
                else
                {
                    EditorUtility.DisplayDialog("导出所有AI", "导出失败", "返回");
                    Debug.LogError("导出失败");
                }
            }
            EditorGUILayout.EndHorizontal();
            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("粘贴", btn_options))
            {
                if (!string.IsNullOrEmpty(copy_tree_))
                {
                    int ai_bt_index = record_.ai_bt_group_list[copy_group_index].member_name_list_.IndexOf(copy_tree_);
                    if (ai_bt_index == -1)
                    {
                        Debug.LogError(string.Format("列表中没有{0}数据", copy_tree_));
                        return;
                    }
                    OperateAIBTEditor.OperateAIBT(record_, copy_group_index, ai_bt_index, AIConst.OPERATE_TYPE_PASTE);
                    copy_tree_ = "";
                }
                else
                {
                    Debug.LogError("没有复制的树");
                }
            }
            EditorGUILayout.EndHorizontal();
            for(int group_index = 0; group_index < record_.ai_bt_group_list.Count; group_index++)
            {
                AIBTGroup group = record_.ai_bt_group_list[group_index];
                EditorGUILayout.BeginHorizontal();
                string text = string.Format("{0}({1})", group.ai_bt_group_name, group.member_name_list_.Count);
                group.is_show = EditorGUILayout.Foldout(group.is_show, text);
                EditorGUILayout.EndHorizontal();
                {
                    if (group.is_show)
                    {
                        ShowAIBTGroup(group, group_index);
                    }  
                }
            }
            EditorGUILayout.EndVertical();

        }

        public void ShowAIBTGroup(AIBTGroup group, int group_index)
        {
            for(int i = 0; i < group.member_name_list_.Count; i++)
            {
                string name = group.member_name_list_[i];
                EditorGUILayout.BeginVertical(box_style_);
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.LabelField(name);
                if (GUILayout.Button("复制"))
                {
                    copy_tree_ = name;
                    copy_group_index = group_index;
                }
                if (GUILayout.Button("编辑"))
                {
                    AIBTEditor.Edit(record_.LoadTree(name), record_);
                    EditorUtility.SetDirty(target);
                }
                if (GUILayout.Button("修改"))
                {
                    OperateAIBTEditor.OperateAIBT(record_, group_index, i, AIConst.OPERATE_TYPE_UPDATE_DATA);
                }
                if (GUILayout.Button("删除"))
                {
                    if (EditorUtility.DisplayDialog("删除AI - " + name, "确认删除", "确认", "取消"))
                    {
                        record_.RemoveTree(name, group_index);
                        Debug.Log("Remove AI: " + name);
                        EditorUtility.SetDirty(target);
                    }
                }
                EditorGUILayout.EndHorizontal();
                EditorGUILayout.EndVertical();
            }
        }

    }
}
