using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace AI
{
    public class CreateAIEditor : EditorWindow
    {
        public int select_tab_;
        public string create_name_ = "";
        private AIBTRecord record_;
        GUILayoutOption[] text_field_options_;
        GUIStyle text_field_type_;
        public int change_group_id_;
        public string new_group_name_ = "";
        public string change_group_name_ = "";
        public int change_group_index_;
        public bool is_change_group_name_;
        public int select_type_ = 0;
        public List<string> group_list_ = new List<string>();
        public Rect windowRect = new Rect(0, 200, 400, 400);


        public static void OpenAIWindow(AIBTRecord record_)
        {
            CreateAIEditor window = (CreateAIEditor)EditorWindow.GetWindow(typeof(CreateAIEditor), false, "创建AI");
            window.Show(true);
            window.record_ = record_;
            window.Init();
        }

        public void Init()
        {
            text_field_type_ = new GUIStyle(EditorStyles.textField);
            text_field_options_ = new GUILayoutOption[] {
                GUILayout.Height(25),
            };
            record_.ai_bt_group_list.ForEach(x =>
            {
                group_list_.Add(x.ai_bt_group_name);
            });
            is_change_group_name_ = false;
            change_group_id_ = -1;
        }

        private void OnGUI()
        {
            if (is_change_group_name_)
            {
                ChangeGroupName();
            }
            else
            {
                select_tab_ = GUILayout.Toolbar(select_tab_, new string[] { "创建", "类型" });
                if (select_tab_ == 0)
                {
                    UpdateCreateAI();
                }
                else
                {
                    UpdateAIType();
                }
            }
        }
        public void UpdateCreateAI()
        {
            EditorGUILayout.BeginVertical();
            EditorGUILayout.Space();
            select_type_ = EditorGUILayout.Popup("分组类型：", select_type_, group_list_.ToArray());
            create_name_ = EditorGUILayout.TextField("AI树名字：", create_name_, text_field_type_, text_field_options_);
            if (GUILayout.Button("创建"))
            {
                if (create_name_.Length <= 0)
                {
                    ShowNotification(new GUIContent("名字不能为空"));
                }
                else
                {
                    if (!record_.AddTree(create_name_))
                    {
                        ShowNotification(new GUIContent(string.Format("名字{0}已存在", create_name_)));
                    }
                    else
                    {
                        record_.ai_bt_group_list[select_type_].member_name_list_.Add(create_name_);
                        AssetDatabase.SaveAssets();
                        EditorUtility.SetDirty(record_);
                        Close();
                    }
                }

            }
            EditorGUILayout.EndVertical();
        }

        public void UpdateAIType()
        {
            EditorGUILayout.BeginVertical();
            if (change_group_id_ == -1)
            {
                new_group_name_ = EditorGUILayout.TextField("分组名字：", new_group_name_);
                if (GUILayout.Button("创建分组"))
                {
                    AIBTGroup group = new AIBTGroup();
                    group.ai_bt_group_name = new_group_name_;
                    record_.ai_bt_group_list.Add(group);
                    group_list_.Clear();
                    foreach (AIBTGroup group_value in record_.ai_bt_group_list)
                    {
                        group_list_.Add(group_value.ai_bt_group_name);
                    }
                    Close();
                }
            }
            else
            {
                string change_name = group_list_[change_group_id_];
                change_name = EditorGUILayout.TextField(change_name);
                if (GUILayout.Button("确定"))
                {
                    record_.ai_bt_group_list[change_group_id_].ai_bt_group_name = change_name;
                    group_list_[change_group_id_] = change_name;
                }
            }

            EditorGUILayout.EndVertical();
            EditorGUILayout.BeginVertical();
            EditorGUILayout.LabelField("------------------------------");
            for (int i = 0; i < group_list_.Count; i++)
            {
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.LabelField(group_list_[i]);
                if (GUILayout.Button("改名"))
                {
                    is_change_group_name_ = true;
                    change_group_index_ = i;
                }
                EditorGUILayout.EndHorizontal();
            }
            EditorGUILayout.EndVertical();
        }

        public void ChangeGroupName()
        {
            change_group_name_ = EditorGUILayout.TextField("更换名字： ", change_group_name_);
            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("确定"))
            {
                group_list_.ForEach(x =>
                {
                    if (x == change_group_name_)
                    {
                        ShowNotification(new GUIContent(string.Format("名字{0}已存在", change_group_name_)));
                        return;
                    }
                });
                if (change_group_name_ == "")
                {
                    Debug.LogError("更改名字不能为空");
                    return;
                }
                group_list_[change_group_index_] = change_group_name_;
                record_.ai_bt_group_list[change_group_index_].ai_bt_group_name = change_group_name_;
                Close();
            }
            if (GUILayout.Button("取消"))
            {
                Close();
            }
            EditorGUILayout.EndHorizontal();
        }
    }
}

