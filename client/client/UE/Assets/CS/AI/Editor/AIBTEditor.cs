using System;
using System.Collections.Generic;
using SLua;
using PI;
using UnityEditor;
using UnityEngine;

namespace AI
{
    public class AIBTEditor : EditorWindow
    {
        public static void Edit(AIBTData tree_data, AIBTRecord record)
        {
            AIBTEditor window = GetWindow(typeof(AIBTEditor), true) as AIBTEditor;
            window.titleContent = new GUIContent("AI编辑器 - " + tree_data.ai_name_);
            window.cur_behavior_tree_ = new AIBehaviorTree(tree_data);
            window.is_show_comment_ = tree_data.is_show_comment_;
            window.cur_bt_name_ = tree_data.ai_name_;
            window.tree_data = tree_data;
            foreach (AIBehaviorTreeNode node in window.cur_behavior_tree_.node_list_)
            {
                node.SortChildren();
            }
            window.data_record_ = record;
            window.minSize = new Vector2(860, 640);
            window.maxSize = new Vector2(10000, 10000);
            window.ShowWindow();
        }

        private AIBehaviorTree cur_behavior_tree_;
        private string cur_bt_name_;
        private AIBTRecord data_record_;
        private AIBTData tree_data;

        private bool is_watch_playing_;
        private List<string> unit_list_;
        private List<LuaTable> ai_list_;
        private int unit_index_;

        private Vector2 graph_size_;
        private float graph_zoom_;
        private Vector2 scroll_pos_;
        private Vector2 first_scroll_pos_;
        private float screen_height_;
        private float screen_width_;

        private Vector2 cur_mouse_pos_;
        private Vector2 delta_mouse_pos_;

        private bool prepare_drag_node_;
        private bool draged_flag_;
        private bool select_node_is_selected_;

        private bool set_parent_flag_;
        private AIBehaviorTreeNode node_for_set_parent_;

        private GenericMenu generic_menu_;
        private Vector2 generic_menu_pos_;
        private bool prepare_show_generic_menu_;
        private bool is_right_mouse_click_;
        
        private bool is_mouse_on_properties_panel_;
        private bool is_mouse_on_variable_panel_;
        private bool is_mouse_on_save_btn_;
        private bool is_show_comment_;
        private bool is_show_properties_panel_;
        private bool is_focus_properties_panel_;
        private bool is_show_variable_panel_;
        private bool is_focus_variable_panel_;
        private int cur_variable_type_index_;
        private List<bool> variable_type_is_show_;
        private Vector2 variable_scroll_pos_;
        private AIVarible temp_variable_;

        private GUIStyle node_name_style_;
        private GUIStyle node_children_count_style_;
        private GUIStyle node_comment_style_;
        private GUIStyle variable_btn_style_;

        private Texture node_texture_;
        private Texture node_high_light_texture_;
        private Texture node_selected_texture_;

        private Rect variable_btn_rect_;
        private Rect variable_panel_rect_;
        private Rect properties_rect_;
        private Rect save_btn_rect_;

        public void ShowWindow()
        {
            graph_size_ = maxSize;
            graph_zoom_ = 1f;
            scroll_pos_ = new Vector2(-1, -1);

            select_node_is_selected_ = false;

            node_name_style_ = new GUIStyle();
            node_name_style_.alignment = TextAnchor.MiddleCenter;
            node_name_style_.fontSize = 13;
            node_name_style_.normal.textColor = Color.grey;

            node_children_count_style_ = new GUIStyle();
            node_children_count_style_.alignment = TextAnchor.MiddleCenter;
            node_children_count_style_.fontStyle = FontStyle.Bold;
            node_children_count_style_.fontSize = 12;
            node_children_count_style_.normal.textColor = new Color(0.75f, 0.75f, 0.75f);

            node_comment_style_ = new GUIStyle();
            node_comment_style_.alignment = TextAnchor.UpperLeft;
            node_comment_style_.fontSize = 12;
            node_comment_style_.normal.textColor = new Color(0.5f, 0.5f, 0.5f, 0.75f);

            variable_btn_style_ = new GUIStyle();
            variable_btn_style_.alignment = TextAnchor.MiddleCenter;
            variable_btn_style_.normal.textColor = Color.gray;
            variable_btn_style_.fontSize = 34;

            node_texture_ = AssetDatabase.LoadAssetAtPath(AIConst.NODE_TEXTURE_PATH, typeof(Texture)) as Texture; ;
            node_high_light_texture_ = AssetDatabase.LoadAssetAtPath(AIConst.NODE_LIGHT_TEXTURE_PATH, typeof(Texture)) as Texture;
            node_selected_texture_ = AssetDatabase.LoadAssetAtPath(AIConst.NODE_SELECT_TEXTURE_PATH, typeof(Texture)) as Texture;

            variable_type_is_show_ = new List<bool>();
            for (int i = 0; i < 6; ++i) variable_type_is_show_.Add(true);

            Show();
        }

        public void OnEnable()
        {
            wantsMouseMove = true;
            if (cur_behavior_tree_ == null && data_record_ != null && !string.IsNullOrEmpty(cur_bt_name_))
            {
                cur_behavior_tree_ = new AIBehaviorTree(data_record_.LoadTree(cur_bt_name_));
            }
        }

        public void OnDisable()
        {
            wantsMouseMove = false;
            // 关闭时对子结点排一下前后顺序
            if (cur_behavior_tree_ != null)
            {
                foreach (AIBehaviorTreeNode node in cur_behavior_tree_.node_list_)
                {
                    node.SortChildren();
                }
            }
            SaveNExport(false);
        }

        public void OnGUI()
        {
            if (cur_behavior_tree_ == null) return;

            if (screen_height_ != position.height || screen_width_ != position.width)
            {
                screen_height_ = position.height;
                screen_width_ = position.width;
            }
            if (scroll_pos_.x == -1 && scroll_pos_.y == -1)
            {
                scroll_pos_.Set((graph_size_.x - screen_width_) / 2, (graph_size_.y - screen_height_) / 2);
                first_scroll_pos_ = scroll_pos_;
            }

            if (Event.current.type == EventType.ScrollWheel)
            {
                //Debug.LogError("ScrollWheel");
                if (Event.current.modifiers == EventModifiers.Alt)
                {
                    CheckMouseZoom();
                    Event.current.Use();
                }
                else
                {
                    CheckMousePan();
                }
            }
            
            scroll_pos_ = GUI.BeginScrollView(new Rect(0, 0, screen_width_, screen_height_), scroll_pos_, new Rect(Vector2.zero, graph_size_ * graph_zoom_));
            UpdateGrid();
            UpdateTree();

            GUI.EndScrollView();
            UpdateToolBar();
            UpdatePropertiesPanel();
            UpdateVariablePanel();

            HandleEvents();

            base.Repaint();
        }

        private void HandleEvents()
        {
            Vector2 vector = cur_mouse_pos_ = Event.current.mousePosition;
            delta_mouse_pos_ = Event.current.delta;
            switch (Event.current.type)
            {
                case EventType.MouseDown:
                    //Debug.LogError("MouseDown");
                    if (set_parent_flag_)
                    {
                        Event.current.Use();
                        return;
                    }
                    if (!GetMousePositionInGraph(ref vector))
                    {
                        is_focus_properties_panel_ = is_mouse_on_properties_panel_;
                        is_focus_variable_panel_ = is_mouse_on_variable_panel_;
                        return;
                    }
                    is_focus_properties_panel_ = false;
                    is_focus_variable_panel_ = false;
                    GUIUtility.keyboardControl = 0;
                    if (Event.current.button == 0 && CheckLeftMouseDown(Event.current.clickCount, vector, Event.current.modifiers == EventModifiers.Control))
                    {
                        Event.current.Use();
                    }
                    else if (Event.current.button == 1 && CheckRightMouseDown(vector))
                    {
                        Event.current.Use();
                    }
                    return;
                case EventType.MouseUp:
                    //Debug.LogError("MouseUp");
                    if (!GetMousePositionInGraph(ref vector))
                    {
                        if (is_mouse_on_save_btn_)
                        {
                            SaveDataFromMenu();
                        }
                        if (is_mouse_on_variable_panel_ && !is_show_variable_panel_)
                        {
                            is_show_variable_panel_ = true;
                        }
                        return;
                    }
                    if (Event.current.button == 0 && CheckLeftMouseRelease(vector, Event.current.modifiers == EventModifiers.Control))
                    {
                        Event.current.Use();
                    }
                    else if (Event.current.button == 1 && CheckRightMouseRelease())
                    {
                        Event.current.Use();
                    }
                    return;
                case EventType.MouseMove:
                    //Debug.LogError("MouseMove");
                    if (GetMousePositionInGraph(ref vector) && CheckMouseMove(vector))
                    {
                        Event.current.Use();
                    }
                    return;
                case EventType.MouseDrag:
                    //Debug.LogError("MouseDrag");
                    GetMousePositionInGraph(ref vector);
                    if (Event.current.button == 0 && (CheckLeftMouseDrag(vector) || (Event.current.modifiers == EventModifiers.Alt && CheckMousePan())))
                    {
                        Event.current.Use();
                    }
                    else if (Event.current.button == 2 && CheckMousePan())
                    {
                        Event.current.Use();
                    }
                    return;
                case EventType.KeyDown:
                    //Debug.LogError("KeyDown: " + Event.current.keyCode);
                    if (!is_focus_properties_panel_ && !is_focus_variable_panel_)
                    {
                        if ((Event.current.keyCode == KeyCode.Delete || Event.current.commandName.Equals("Delete")) && CheckRemoveNode())
                        {
                            Event.current.Use();
                        }
                    }
                    return;
                case EventType.ValidateCommand:
                    //Debug.LogError("ValidateCommand: " + Event.current.commandName);
                    if (!is_focus_properties_panel_ && !is_focus_variable_panel_)
                    {
                        if (Event.current.commandName.Equals("Copy") || Event.current.commandName.Equals("Paste") || Event.current.commandName.Equals("SelectAll"))
                        {
                            Event.current.Use();
                        }
                    }
                    return;
                case EventType.ExecuteCommand:
                    //Debug.LogError("ExecuteCommand: " + Event.current.commandName);
                    if (!is_focus_properties_panel_ && !is_focus_variable_panel_)
                    {
                        if (Event.current.commandName.Equals("Copy"))
                        {
                            CheckCopyNodes();
                            Event.current.Use();
                        }
                        else if (Event.current.commandName.Equals("Paste"))
                        {
                            CheckPasteNodes();
                            Event.current.Use();
                        }
                        else if (Event.current.commandName.Equals("SelectAll"))
                        {
                            CheckSelectAll();
                            Event.current.Use();
                        }
                    }
                    return;

                case EventType.KeyUp:
                case EventType.Repaint:
                case EventType.Layout:
                case EventType.DragUpdated:
                case EventType.DragPerform:
                case EventType.Ignore:
                case EventType.Used:
                    return;
            }
        }

        public void Update()
        {
            if(is_watch_playing_ && GameEntry.CheckExist())
            {
                var lua_state = GameEntry.Instance.game_lua_entry_.lua_svr_.luaState;
                if (lua_state != null && cur_behavior_tree_ != null)
                {
                    LuaTable lua_unit_mgr = (LuaTable)lua_state["ComMgrs.unit_mgr"];
                    if (lua_unit_mgr != null)
                    {
                        if (unit_list_ == null) unit_list_ = new List<string>();
                        else unit_list_.Clear();
                        if (ai_list_ == null) ai_list_ = new List<LuaTable>();
                        else ai_list_.Clear();
                        object[] ret = (object[])lua_unit_mgr.invoke("GetAIList", lua_unit_mgr, cur_behavior_tree_.name_);
                        double len = (double)ret[0];
                        if (len > 0)
                        {
                            LuaTable unit_list = (LuaTable)ret[1];
                            LuaTable ai_list = (LuaTable)ret[2];
                            for (int i = 1; i <= len; ++i)
                            {
                                unit_list_.Add(((double)unit_list[i]).ToString());
                                ai_list_.Add((LuaTable)ai_list[i]);
                            }
                            Repaint();
                        }
                        if (unit_index_ >= len) unit_index_ = 0;
                    }
                    else
                    {
                        is_watch_playing_ = false;
                    }
                }
            }
        }

        #region 消息处理
        private bool GetMousePositionInGraph(ref Vector2 mousePosition)
        {
            if (is_show_properties_panel_ && properties_rect_.Contains(cur_mouse_pos_))
            {
                // 位于属性栏内
                is_mouse_on_variable_panel_ = false;
                is_mouse_on_save_btn_ = false;
                is_mouse_on_properties_panel_ = true;
                return false;
            }
            else if ((!is_show_variable_panel_ && variable_btn_rect_.Contains(cur_mouse_pos_)) || (is_show_variable_panel_ && variable_panel_rect_.Contains(cur_mouse_pos_)))
            {
                // 位于全局变量栏内
                is_mouse_on_properties_panel_ = false;
                is_mouse_on_save_btn_ = false;
                is_mouse_on_variable_panel_ = true;
                return false;
            }
            else if (save_btn_rect_.Contains(cur_mouse_pos_))
            {
                // 位于保存按钮上
                is_mouse_on_properties_panel_ = false;
                is_mouse_on_variable_panel_ = false;
                is_mouse_on_save_btn_ = true;
                return false;
            }
            else
            {
                is_mouse_on_properties_panel_ = false;
                is_mouse_on_variable_panel_ = false;
                is_mouse_on_save_btn_ = false;
                mousePosition = (cur_mouse_pos_ + scroll_pos_) / graph_zoom_;
                return true;
            }
        }

        private bool CheckLeftMouseDown(int click_count, Vector2 mouse_pos, bool allow_multi_choose)
        {
            cur_behavior_tree_.CheckHover(mouse_pos - graph_size_ / 2);
            return prepare_drag_node_ = cur_behavior_tree_.CheckSelect(mouse_pos - graph_size_ / 2, ref select_node_is_selected_, false, allow_multi_choose);
        }

        private bool CheckLeftMouseRelease(Vector2 mouse_pos, bool allow_multi_choose)
        {
            bool flag;
            if (set_parent_flag_)
            {
                set_parent_flag_ = draged_flag_ = prepare_drag_node_ = false;
                if (cur_behavior_tree_.CheckSelect(mouse_pos - graph_size_ / 2, ref select_node_is_selected_, false, false)
                    && cur_behavior_tree_.GetSelectedNodes().Count == 1
                    && !cur_behavior_tree_.GetSelectedNodes()[0].no_child_limit_
                    && node_for_set_parent_ != cur_behavior_tree_.GetSelectedNodes()[0]
                    && !node_for_set_parent_.GetAllChildrenList().Contains(cur_behavior_tree_.GetSelectedNodes()[0].uuid_))
                {
                    node_for_set_parent_.AddConn(cur_behavior_tree_.GetSelectedNodes()[0]);
                    return true;
                }
                else
                {
                    return false;
                }
            }
            else
            {
                flag = cur_behavior_tree_.CheckSelect(mouse_pos - graph_size_ / 2, ref select_node_is_selected_, !draged_flag_ && select_node_is_selected_, allow_multi_choose, !draged_flag_);
                draged_flag_ = prepare_drag_node_ = false;
                return flag;
            }
        }

        private bool CheckRightMouseDown(Vector2 mouse_pos)
        {
            cur_behavior_tree_.CheckHover(mouse_pos - graph_size_ / 2);
            cur_behavior_tree_.CheckSelect(mouse_pos - graph_size_ / 2, ref select_node_is_selected_, false, false);
            BuildRightClickMenu();
            is_right_mouse_click_ = prepare_show_generic_menu_ = true;
            return true;
        }

        private bool CheckRightMouseRelease()
        {
            if (prepare_show_generic_menu_)
            {
                prepare_show_generic_menu_ = false;
                generic_menu_pos_ = (cur_mouse_pos_ + scroll_pos_) / graph_zoom_;
                generic_menu_.ShowAsContext();
                return true;
            }
            else
            {
                return false;
            }
        }

        private void BuildRightClickMenu()
        {
            generic_menu_ = new GenericMenu();
            generic_menu_.AddItem(new GUIContent("保存"), false, new GenericMenu.MenuFunction(SaveDataFromMenu));

            if (cur_behavior_tree_.GetSelectedNodes().Count == 1 ? !cur_behavior_tree_.GetSelectedNodes()[0].no_child_limit_ : cur_behavior_tree_.GetSelectedNodes().Count == 0 ? true : false)
            {
                foreach (var item in AIConst.kCategorys)
                {
                    foreach (AIBTNodeType type in item.Value)
                    {
                        generic_menu_.AddItem(new GUIContent(string.Format("添加结点/{0}/{1}", new object[] { AIConst.Categorys2ShowCategorysName[item.Key], AIConst.TypeName2ShowName[AIConst.kNodeType2TypeName[type]] })), false, new GenericMenu.MenuFunction2(AddNodeFromMenu), type);
                    }
                }
            }
            else
            {
                generic_menu_.AddDisabledItem(new GUIContent("添加结点"));
            }

            if (cur_behavior_tree_.GetSelectedNodes().Count > 0) generic_menu_.AddItem(new GUIContent("删除结点"), false, new GenericMenu.MenuFunction(RemoveNodeFromMenu));
            else generic_menu_.AddDisabledItem(new GUIContent("删除结点"));

            if (cur_behavior_tree_.GetSelectedNodes().Count == 1 && cur_behavior_tree_.GetSelectedNodes()[0].type_ != AIBTNodeType.Entry) generic_menu_.AddItem(new GUIContent("复制结点"), false, new GenericMenu.MenuFunction(CheckCopyNodes));
            else generic_menu_.AddDisabledItem(new GUIContent("复制结点"));

            if (cur_behavior_tree_.is_prepare_for_copy_ && cur_behavior_tree_.GetSelectedNodes().Count == 1 && !cur_behavior_tree_.GetSelectedNodes()[0].no_child_limit_) generic_menu_.AddItem(new GUIContent("粘贴结点"), false, new GenericMenu.MenuFunction(CheckPasteNodes));
            else generic_menu_.AddDisabledItem(new GUIContent("粘贴结点"));
        }

        private void AddNodeFromMenu(object type)
        {
            CheckAddNode((AIBTNodeType)type);
        }

        private bool CheckMouseMove(Vector2 mousePosition)  // check hover
        {
            return cur_behavior_tree_.CheckHover(mousePosition - graph_size_ / 2);
        }

        private bool CheckMousePan()
        {
            scroll_pos_ -= delta_mouse_pos_;
            return true;
        }

        private bool CheckMouseZoom()
        {
            float newZoom = Mathf.Clamp(graph_zoom_ - delta_mouse_pos_.y / 150f, 0.4f, 1f);
            float tmpX = cur_mouse_pos_.x - screen_width_ / 2;
            float tmpY = cur_mouse_pos_.y - screen_height_ / 2;
            scroll_pos_.x += (newZoom - graph_zoom_) * maxSize.x / 2 + tmpX / graph_zoom_ * newZoom - tmpX;
            scroll_pos_.y += (newZoom - graph_zoom_) * maxSize.y / 2 + tmpY / graph_zoom_ * newZoom - tmpY;
            graph_zoom_ = newZoom;
            return true;
        }

        private bool CheckLeftMouseDrag(Vector2 mouse_pos)
        {
            select_node_is_selected_ = false;
            if (set_parent_flag_)
            {
                cur_behavior_tree_.CheckHover(mouse_pos - graph_size_ / 2);
                return draged_flag_ = true;
            }
            if (prepare_drag_node_)
            {
                return draged_flag_ = cur_behavior_tree_.CheckDragSelectedNode(delta_mouse_pos_ / graph_zoom_);
            }
            else
            {
                return false;
            }
        }

        private bool CheckAddNode(AIBTNodeType type)
        {
            if (is_right_mouse_click_)
            {
                if (cur_behavior_tree_.CheckAddNode(type, generic_menu_pos_ - graph_size_ / 2))
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
            else
            {
                if (cur_behavior_tree_.CheckAddNode(type))
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
        }

        private void RemoveNodeFromMenu()
        {
            CheckRemoveNode();
        }

        private bool CheckRemoveNode()
        {
            return cur_behavior_tree_.CheckRemoveSelected();
        }

        private void CheckCopyNodes()
        {
            cur_behavior_tree_.CheckCopyNodes();
        }

        private void CheckPasteNodes()
        {
            cur_behavior_tree_.CheckPasteNodes();
        }

        private void CheckSelectAll()
        {
            cur_behavior_tree_.CheckSelectAll();
        }

        private void BackToFirstScrollPos()
        {
            scroll_pos_ = first_scroll_pos_;
        }

        private void SetShowCommentFlag(bool is_show)
        {
            is_show_comment_ = cur_behavior_tree_.is_show_comment_ = is_show;
        }

        private void SaveDataFromMenu()
        {
            SaveNExport(true);
        }

        private void SaveNExport(bool is_export)
        {
            if (cur_behavior_tree_ != null)
            {
                // 保存前对子结点排一下前后顺序
                foreach (AIBehaviorTreeNode node in cur_behavior_tree_.node_list_)
                {
                    node.SortChildren();
                }
                cur_behavior_tree_.SaveData(data_record_, tree_data);
                if (is_export)
                {
                    if (cur_behavior_tree_.Export(data_record_))
                    {
                        AssetDatabase.SaveAssets();
                        EditorUtility.DisplayDialog("保存当前编辑的AI", "AI - " + cur_behavior_tree_.name_ + " 保存成功", "好的");
                    }
                    else
                    {
                        EditorUtility.DisplayDialog("保存当前编辑的AI", "AI - " + cur_behavior_tree_.name_ + " 保存失败", "返回");
                        Debug.LogError(cur_behavior_tree_.name_ + " 保存失败");
                    }
                }
            }
        }
        #endregion

        #region 绘制界面
        private void UpdateGrid()
        {
            Handles.color = new Color(0.27f, 0.27f, 0.27f);
            float   i, margin = 50 * graph_zoom_,
                    h_end = screen_height_ + scroll_pos_.y,
                    w_end = screen_width_ + scroll_pos_.x;
            for (i = 7; i <= graph_size_.y; i += margin)
            {
                if (i > scroll_pos_.y && i <= h_end)
                    Handles.DrawLine(new Vector2(scroll_pos_.x, i), new Vector2(w_end, i));
            }
            for (i = 7; i <= graph_size_.x; i += margin)
            {
                if (i > scroll_pos_.x && i <= w_end)
                    Handles.DrawLine(new Vector2(i, scroll_pos_.y), new Vector2(i, h_end));
            }
        }

        private void UpdateTree()
        {
            if (cur_behavior_tree_ == null) return;

            // 画结点 鼠标悬停 选中 子结点数 名字
            List<AIBehaviorTreeNode> select_nodes = new List<AIBehaviorTreeNode>();
            List<AIBehaviorTreeNode> node_list = cur_behavior_tree_.node_list_;
            foreach (AIBehaviorTreeNode node in node_list)
            {
                if (node.is_show_self_)
                {
                    if (node.is_selected_)
                    {
                        select_nodes.Add(node);
                    }
                    else
                    {
                        GUI.DrawTexture(new Rect((node.pos_ + graph_size_ / 2) * graph_zoom_, AIConst.NODE_SIZE * graph_zoom_), node_texture_);
                        if (node.is_hovering_) GUI.DrawTexture(new Rect((node.pos_ + graph_size_ / 2) * graph_zoom_, AIConst.NODE_SIZE * graph_zoom_), node_high_light_texture_);

                        if (!node.no_child_limit_) GUI.Label(new Rect((node.pos_show_children_area_ + graph_size_ / 2) * graph_zoom_, AIConst.SHOW_CHILDREN_AREA_SIZE * graph_zoom_), node.children_.Count.ToString(), node_children_count_style_);
                        GUI.Label(new Rect((node.pos_show_name_area_ + graph_size_ / 2) * graph_zoom_, AIConst.SHOW_NAME_AREA_SIZE * graph_zoom_), node.name_, node_name_style_);

                        if (node.parent_ == null && !set_parent_flag_)
                        {
                            if (node.type_ != AIBTNodeType.Entry && GUI.RepeatButton(new Rect((node.pos_ + graph_size_ / 2 + new Vector2(26, -10)) * graph_zoom_, new Vector2(12, 10) * graph_zoom_), ""))
                            {
                                node_for_set_parent_ = node;
                                set_parent_flag_ = true;
                            }
                        }

                        if (is_show_comment_ && !string.IsNullOrEmpty(node.comment_))
                        {
                            GUI.Label(new Rect((node.pos_show_comment_ + graph_size_ / 2) * graph_zoom_, Vector2.one), node.comment_, node_comment_style_);
                        }
                    }
                }
            }
            foreach (AIBehaviorTreeNode node in select_nodes)
            {
                GUI.DrawTexture(new Rect((node.pos_ + graph_size_ / 2) * graph_zoom_, AIConst.NODE_SIZE * graph_zoom_), node_texture_);
                GUI.DrawTexture(new Rect((node.pos_ - new Vector2(2, 2) + graph_size_ / 2) * graph_zoom_, (AIConst.NODE_SIZE + new Vector2(4, 4)) * graph_zoom_), node_selected_texture_);
                if (node.is_hovering_) GUI.DrawTexture(new Rect((node.pos_ + graph_size_ / 2) * graph_zoom_, AIConst.NODE_SIZE * graph_zoom_), node_high_light_texture_);

                if (!node.no_child_limit_) GUI.Label(new Rect((node.pos_show_children_area_ + graph_size_ / 2) * graph_zoom_, AIConst.SHOW_CHILDREN_AREA_SIZE * graph_zoom_), node.children_.Count.ToString(), node_children_count_style_);
                GUI.Label(new Rect((node.pos_show_name_area_ + graph_size_ / 2) * graph_zoom_, AIConst.SHOW_NAME_AREA_SIZE * graph_zoom_), node.name_, node_name_style_);

                if (node.type_ != AIBTNodeType.Entry && node.parent_ == null && !set_parent_flag_)
                {
                    if (GUI.RepeatButton(new Rect((node.pos_ + graph_size_ / 2 + new Vector2(26, -10)) * graph_zoom_, new Vector2(12, 10) * graph_zoom_), ""))
                    {
                        node_for_set_parent_ = node;
                        set_parent_flag_ = true;
                    }
                }

                if (is_show_comment_ && !string.IsNullOrEmpty(node.comment_))
                {
                    GUI.Label(new Rect((node.pos_show_comment_ + graph_size_ / 2) * graph_zoom_, Vector2.one), node.comment_, node_comment_style_);
                }
            }

            // 画连线
            List<Rect> selected_rects = new List<Rect>();
            foreach (var conn in cur_behavior_tree_.connection_)
            {
                if (conn.Key.is_show_self_)
                {
                    if (conn.Key.is_conn_selected_)
                    {
                        selected_rects.AddRange(conn.Value.GetShowRects(graph_size_ / 2, graph_zoom_));
                    }
                    else if (conn.Key.is_conn_hovering_)
                    {
                        foreach (Rect rect in conn.Value.GetShowRects(graph_size_ / 2, graph_zoom_))
                            EditorGUI.DrawRect(rect, Color.cyan);
                    }
                    else
                    {
                        foreach (Rect rect in conn.Value.GetShowRects(graph_size_ / 2, graph_zoom_))
                            EditorGUI.DrawRect(rect, Color.white);
                    }
                }
            }
            foreach (Rect rect in selected_rects)
                EditorGUI.DrawRect(rect, Color.blue);

            // 画拖线
            if (set_parent_flag_)
            {
                Vector2 node_pos = (node_for_set_parent_.pos_link_to_parent_ + graph_size_ / 2) * graph_zoom_;
                Vector2 des_pos = (cur_mouse_pos_ + scroll_pos_) / graph_zoom_;
                float balancePos = node_pos.y - (node_pos.y - des_pos.y) / 2;
                EditorGUI.DrawRect(new Rect(Math.Min(des_pos.x, node_pos.x), balancePos, Math.Abs(des_pos.x - node_pos.x) + 2, 2), Color.white);    // balance
                EditorGUI.DrawRect(new Rect(des_pos.x, Math.Min(des_pos.y, balancePos), 2, Math.Abs(des_pos.y - balancePos)), Color.white);        // mouse
                EditorGUI.DrawRect(new Rect(node_pos.x, Math.Min(node_pos.y, balancePos), 2, Math.Abs(node_pos.y - balancePos)), Color.white);     // node
            }

            // 画实时信息
            if (is_watch_playing_ && !EditorApplication.isPlaying)
            {
                is_watch_playing_ = false;
                unit_list_ = null;
                ai_list_ = null;
            }
            if (is_watch_playing_ && unit_list_.Count > 0)
            {
                Color tmpColor = GUI.color;
                GUI.color = Color.green;
                GUI.DrawTexture(new Rect((cur_behavior_tree_.root_.pos_ + graph_size_ / 2) * graph_zoom_, AIConst.NODE_SIZE * graph_zoom_), node_high_light_texture_);
                GUI.color = tmpColor;
                UpdatePlayingNode(cur_behavior_tree_.GetNodeByUuid(cur_behavior_tree_.root_.children_[0]), ai_list_[unit_index_]);
            }
        }

        private void UpdatePlayingNode(AIBehaviorTreeNode node, LuaTable data)
        {
            if (data == null) return;

            if (!node.is_show_self_) return;
            int status = (int)(double)data["status"];
            Color tmpColor = GUI.color;
            switch (status)
            {
                case 1:
                    // 成功
                    GUI.color = Color.black;
                    GUI.DrawTexture(new Rect((node.pos_ + graph_size_ / 2) * graph_zoom_, AIConst.NODE_SIZE * graph_zoom_), node_high_light_texture_);
                    GUI.color = tmpColor;
                    break;
                case 2:
                    // 失败
                    GUI.color = Color.red;
                    GUI.DrawTexture(new Rect((node.pos_ + graph_size_ / 2) * graph_zoom_, AIConst.NODE_SIZE * graph_zoom_), node_high_light_texture_);
                    GUI.color = tmpColor;
                    break;
                case 3:
                    // 运行中
                    GUI.color = Color.green;
                    GUI.DrawTexture(new Rect((node.pos_ + graph_size_ / 2) * graph_zoom_, AIConst.NODE_SIZE * graph_zoom_), node_high_light_texture_);
                    GUI.color = tmpColor;
                    // 画运行线
                    foreach (Rect rect in cur_behavior_tree_.connection_[node].GetShowRects(graph_size_ / 2, graph_zoom_))
                        EditorGUI.DrawRect(rect, Color.green);
                    break;
            }
            GUI.Label(new Rect((node.pos_ + graph_size_ / 2) * graph_zoom_, AIConst.NODE_SIZE * graph_zoom_), AIConst.GetNodeStatusName(status));

            if (node.is_show_children_)
            {
                for (int i = 0; i < node.children_.Count; ++i)
                {
                    UpdatePlayingNode(cur_behavior_tree_.GetNodeByUuid(node.children_[i]), (LuaTable)((LuaTable)data["children"])[i + 1]);
                }
            }
        }

        private void UpdateToolBar()
        {
            float x = screen_width_ - 114;
            EditorGUI.DrawRect(new Rect(x, 14, 84, 21), new Color(0.3f, 0.3f, 0.3f, 0.75f));
            bool new_is_show_comment = EditorGUI.Toggle(new Rect(x + 4, 15, 76, 20), is_show_comment_);
            if (new_is_show_comment != is_show_comment_) SetShowCommentFlag(new_is_show_comment);
            GUI.Label(new Rect(x + 18, 16, 62, 16), "显示说明");
            x -= 94;

            save_btn_rect_ = new Rect(x, 14, 84, 21);
            EditorGUI.DrawRect(save_btn_rect_, new Color(0.3f, 0.3f, 0.3f, 0.75f));
            GUI.Label(new Rect(x + 24, 16, 40, 16), "保存");
            x -= 94;

            if (EditorApplication.isPlaying)
            {
                EditorGUI.DrawRect(new Rect(x, 14, 84, 21), new Color(0.3f, 0.3f, 0.3f, 0.75f));
                is_watch_playing_ = EditorGUI.Toggle(new Rect(x + 17, 15, 76, 20), is_watch_playing_);
                GUI.Label(new Rect(x + 31, 16, 62, 16), "PLAY");
                if (is_watch_playing_)
                {
                    if (unit_list_ != null && unit_list_.Count > 0)
                    {
                        unit_index_ = EditorGUI.Popup(new Rect(x, 38, 84, 21), unit_index_, unit_list_.ToArray());
                    }
                    else
                    {
                        GUI.Label(new Rect(x + 12, 38, 62, 16), "No Match!");
                        unit_index_ = 0;
                    }
                }
                x -= 94;
            }
            else
            {
                is_watch_playing_ = false;
            }
        }

        #region 属性栏
        private void UpdatePropertiesPanel()
        {
            if (cur_behavior_tree_.GetSelectedNodes().Count != 1 || (draged_flag_ && new Rect(10, 10, 400, 400).Contains(cur_mouse_pos_)))
            {
                is_show_properties_panel_ = false;
                return;
            }
            is_show_properties_panel_ = true;
            EditorGUI.DrawRect(properties_rect_, new Color(0.3f, 0.3f, 0.3f, 0.75f));
            float x = 40,y = 40;
            AIBehaviorTreeNode cur_node = cur_behavior_tree_.GetSelectedNodes()[0];
            EditorGUI.LabelField(new Rect(x, y, 320, 16), AIConst.GetNodeTypeName(cur_node.type_));
            y += 26;

            EditorGUI.LabelField(new Rect(x, y, 100, 16), "名字:");
            string new_name = EditorGUI.TextField(new Rect(x + 100, y, 220, 16), cur_node.name_);
            if (new_name != cur_node.name_) cur_node.name_ = new_name;
            y += 26;

            EditorGUI.LabelField(new Rect(x, y, 100, 32), "说明:");
            string new_comment = EditorGUI.TextArea(new Rect(x + 100, y, 220, 32), cur_node.comment_);
            if (new_comment != cur_node.comment_) cur_node.comment_ = new_comment;
            y += 42;

            if (cur_node.type_ != AIBTNodeType.Entry)
            {
                ParamItem[] paramList = AIConst.kType2Param[AIConst.kNodeType2TypeName[cur_node.type_]];
                for (int i = 0; i < paramList.Length; ++i)
                {
                    ShowParam(paramList[i].name, paramList[i].type, cur_node.params_, ref x, ref y);
                }
            }
            properties_rect_ = new Rect(10, 10, 400, y);
        }
        //画面板属性
        private void ShowParam(string name, string type, AIBTNodePI pi, ref float x, ref float y)
        {
            EditorGUI.LabelField(new Rect(x, y, 100, 16), name + ":");
            switch (type)
            {
                case "string":
                    string string_value = pi.GetStringParam(name);
                    string new_string_name;
                    new_string_name = EditorGUI.TextField(new Rect(x + 100, y, 220, 16), string_value);
                    if (string_value != new_string_name) pi.SetParam(name, new_string_name);
                    y += 26;
                    break;

                case "multiline_string":
                    string multiline_string_value = pi.GetStringParam(name);
                    string new_multiline_string_value;
                    new_multiline_string_value = EditorGUI.TextArea(new Rect(x + 100, y, 220, 128), multiline_string_value);
                    if (multiline_string_value != new_multiline_string_value) pi.SetParam(name, new_multiline_string_value);
                    y += 138;
                    break;

                case "int":
                    int int_value = pi.GetIntParam(name);
                    int new_int_value = EditorGUI.IntField(new Rect(x + 100, y, 220, 16), int_value);
                    if (int_value != new_int_value) pi.SetParam(name, new_int_value);
                    y += 26;
                    break;

                case "float":
                    float float_value = pi.GetFloatParam(name);
                    float new_float_value = EditorGUI.FloatField(new Rect(x + 100, y, 220, 16), float_value);
                    if (float_value != new_float_value) pi.SetParam(name, new_float_value);
                    y += 26;
                    break;

                case "bool":
                    bool bool_value = pi.GetBoolParam(name);
                    bool new_bool_value = EditorGUI.Toggle(new Rect(x + 100, y, 220, 16), bool_value);
                    if (bool_value != new_bool_value) pi.SetParam(name, new_bool_value);
                    y += 26;
                    break;

                case "Vector2":
                    Vector2 vector2_value = pi.GetVector2Param(name);
                    Vector2 new_vector2_value = EditorGUI.Vector2Field(new Rect(x + 100, y, 220, 16), "", vector2_value);
                    if (vector2_value != new_vector2_value) pi.SetParam(name, new_vector2_value);
                    y += 26;
                    break;

                case "Vector3":
                    Vector3 vector3_value = pi.GetVector3Param(name);
                    Vector3 new_vector3_value = EditorGUI.Vector3Field(new Rect(x + 100, y, 220, 16), "", vector3_value);
                    if (vector3_value != new_vector3_value) pi.SetParam(name, new_vector3_value);
                    y += 26;
                    break;

                case "shared_string":
                    SharedString s_string_value = pi.GetObjectParam(name) as SharedString;
                    if (s_string_value == null) pi.SetParam(name, (s_string_value = new SharedString()));
                    if (s_string_value.value_type_ == ValueType.VT_Value)
                    {
                        s_string_value.value_ = EditorGUI.TextField(new Rect(x + 100, y, 180, 16), s_string_value.value_);
                    }
                    else
                    {
                        List<string> string_variables = cur_behavior_tree_.GetVariableNameList("string");
                        if (string_variables.Count == 0)
                        {
                            EditorGUI.LabelField(new Rect(x + 100, y, 180, 16), "Not Found");
                        }
                        else
                        {
                            int index;
                            if (!string_variables.Contains(s_string_value.variable_name_)) index = 0;
                            else index = string_variables.IndexOf(s_string_value.variable_name_);
                            s_string_value.variable_name_ = string_variables[EditorGUI.Popup(new Rect(x + 100, y, 180, 16), index, string_variables.ToArray())];
                        }
                    }
                    if (GUI.Button(new Rect(x + 286, y - 3, 40, 20), "<~>"))
                    {
                        if (s_string_value.value_type_ == ValueType.VT_Value) s_string_value.value_type_ = ValueType.VT_Variable;
                        else s_string_value.value_type_ = ValueType.VT_Value;
                    }
                    y += 26;
                    break;

                case "shared_int":
                    SharedInt s_int_value = pi.GetObjectParam(name) as SharedInt;
                    if (s_int_value == null) pi.SetParam(name, (s_int_value = new SharedInt()));
                    if (s_int_value.value_type == ValueType.VT_Value)
                    {
                        s_int_value.value = EditorGUI.IntField(new Rect(x + 100, y, 180, 16), s_int_value.value);
                    }
                    else
                    {
                        List<string> int_variables = cur_behavior_tree_.GetVariableNameList("int");
                        if (int_variables.Count == 0)
                        {
                            EditorGUI.LabelField(new Rect(x + 100, y, 180, 16), "Not Found");
                        }
                        else
                        {
                            int index;
                            if (!int_variables.Contains(s_int_value.variable_name)) index = 0;
                            else index = int_variables.IndexOf(s_int_value.variable_name);
                            s_int_value.variable_name = int_variables[EditorGUI.Popup(new Rect(x + 100, y, 180, 16), index, int_variables.ToArray())];
                        }
                    }
                    if (GUI.Button(new Rect(x + 286, y - 3, 40, 20), "<~>"))
                    {
                        if (s_int_value.value_type == ValueType.VT_Value) s_int_value.value_type = ValueType.VT_Variable;
                        else s_int_value.value_type = ValueType.VT_Value;
                    }
                    y += 26;
                    break;

                case "shared_float":
                    SharedFloat s_float_value = pi.GetObjectParam(name) as SharedFloat;
                    if (s_float_value == null) pi.SetParam(name, (s_float_value = new SharedFloat()));
                    if (s_float_value.value_type_ == ValueType.VT_Value)
                    {
                        s_float_value.value_ = EditorGUI.FloatField(new Rect(x + 100, y, 180, 16), s_float_value.value_);
                    }
                    else
                    {
                        List<string> float_variables = cur_behavior_tree_.GetVariableNameList("float");
                        if (float_variables.Count == 0)
                        {
                            EditorGUI.LabelField(new Rect(x + 100, y, 180, 16), "Not Found");
                        }
                        else
                        {
                            int index;
                            if (!float_variables.Contains(s_float_value.variable_name_)) index = 0;
                            else index = float_variables.IndexOf(s_float_value.variable_name_);
                            s_float_value.variable_name_ = float_variables[EditorGUI.Popup(new Rect(x + 100, y, 180, 16), index, float_variables.ToArray())];
                        }
                    }
                    if (GUI.Button(new Rect(x + 286, y - 3, 40, 20), "<~>"))
                    {
                        if (s_float_value.value_type_ == ValueType.VT_Value) s_float_value.value_type_ = ValueType.VT_Variable;
                        else s_float_value.value_type_ = ValueType.VT_Value;
                    }
                    y += 26;
                    break;

                case "shared_bool":
                    SharedBool s_bool_value = pi.GetObjectParam(name) as SharedBool;
                    if (s_bool_value == null) pi.SetParam(name, (s_bool_value = new SharedBool()));
                    if (s_bool_value.value_type_ == ValueType.VT_Value)
                    {
                        s_bool_value.value_ = EditorGUI.Toggle(new Rect(x + 100, y, 180, 16), s_bool_value.value_);
                    }
                    else
                    {
                        List<string> bool_variables = cur_behavior_tree_.GetVariableNameList("bool");
                        if (bool_variables.Count == 0)
                        {
                            EditorGUI.LabelField(new Rect(x + 100, y, 180, 16), "Not Found");
                        }
                        else
                        {
                            int index;
                            if (!bool_variables.Contains(s_bool_value.variable_name_)) index = 0;
                            else index = bool_variables.IndexOf(s_bool_value.variable_name_);
                            s_bool_value.variable_name_ = bool_variables[EditorGUI.Popup(new Rect(x + 100, y, 180, 16), index, bool_variables.ToArray())];
                        }
                    }
                    if (GUI.Button(new Rect(x + 286, y - 3, 40, 20), "<~>"))
                    {
                        if (s_bool_value.value_type_ == ValueType.VT_Value) s_bool_value.value_type_ = ValueType.VT_Variable;
                        else s_bool_value.value_type_ = ValueType.VT_Value;
                    }
                    y += 26;
                    break;

                case "shared_vector2":
                    SharedVector2 s_vector2_value = pi.GetObjectParam(name) as SharedVector2;
                    if (s_vector2_value == null) pi.SetParam(name, (s_vector2_value = new SharedVector2()));
                    if (s_vector2_value.value_type_ == ValueType.VT_Value)
                    {
                        s_vector2_value.value_ = EditorGUI.Vector2Field(new Rect(x + 100, y, 180, 16), "", s_vector2_value.value_);
                    }
                    else
                    {
                        List<string> vector2_variables = cur_behavior_tree_.GetVariableNameList("Vector2");
                        if (vector2_variables.Count == 0)
                        {
                            EditorGUI.LabelField(new Rect(x + 100, y, 180, 16), "Not Found");
                        }
                        else
                        {
                            int index;
                            if (!vector2_variables.Contains(s_vector2_value.variable_name_)) index = 0;
                            else index = vector2_variables.IndexOf(s_vector2_value.variable_name_);
                            s_vector2_value.variable_name_ = vector2_variables[EditorGUI.Popup(new Rect(x + 100, y, 180, 16), index, vector2_variables.ToArray())];
                        }
                    }
                    if (GUI.Button(new Rect(x + 286, y - 3, 40, 20), "<~>"))
                    {
                        if (s_vector2_value.value_type_ == ValueType.VT_Value) s_vector2_value.value_type_ = ValueType.VT_Variable;
                        else s_vector2_value.value_type_ = ValueType.VT_Value;
                    }
                    y += 26;
                    break;

                case "shared_vector3":
                    SharedVector3 s_vector3_value = pi.GetObjectParam(name) as SharedVector3;
                    if (s_vector3_value == null) pi.SetParam(name, (s_vector3_value = new SharedVector3()));
                    if (s_vector3_value.value_type_ == ValueType.VT_Value)
                    {
                        s_vector3_value.value_ = EditorGUI.Vector3Field(new Rect(x + 100, y, 180, 16), "", s_vector3_value.value_);
                    }
                    else
                    {
                        List<string> vector3_variables = cur_behavior_tree_.GetVariableNameList("Vector3");
                        if (vector3_variables.Count == 0)
                        {
                            EditorGUI.LabelField(new Rect(x + 100, y, 180, 16), "Not Found");
                        }
                        else
                        {
                            int index;
                            if (!vector3_variables.Contains(s_vector3_value.variable_name_)) index = 0;
                            else index = vector3_variables.IndexOf(s_vector3_value.variable_name_);
                            s_vector3_value.variable_name_ = vector3_variables[EditorGUI.Popup(new Rect(x + 100, y, 180, 16), index, vector3_variables.ToArray())];
                        }
                    }
                    if (GUI.Button(new Rect(x + 286, y - 3, 40, 20), "<~>"))
                    {
                        if (s_vector3_value.value_type_ == ValueType.VT_Value) s_vector3_value.value_type_ = ValueType.VT_Variable;
                        else s_vector3_value.value_type_ = ValueType.VT_Value;
                    }
                    y += 26;
                    break;

                case "variable_int":
                    string int_name = pi.GetStringParam(name);
                    {
                        List<string> variables = cur_behavior_tree_.GetVariableNameList("int");
                        if (variables.Count == 0)
                        {
                            EditorGUI.LabelField(new Rect(x + 100, y, 180, 16), "Not Found");
                        }
                        else
                        {
                            int index;
                            if (string.IsNullOrEmpty(int_name) || !variables.Contains(int_name)) index = 0;
                            else index = variables.IndexOf(int_name);
                            string newVariableIntName = variables[EditorGUI.Popup(new Rect(x + 100, y, 180, 16), index, variables.ToArray())];
                            if (int_name != newVariableIntName) pi.SetParam(name, newVariableIntName);
                        }
                    }
                    y += 26;
                    break;

                case "variable_bool":
                    string bool_name = pi.GetStringParam(name);
                    {
                        List<string> variables = cur_behavior_tree_.GetVariableNameList("bool");
                        if (variables.Count == 0)
                        {
                            EditorGUI.LabelField(new Rect(x + 100, y, 180, 16), "Not Found");
                        }
                        else
                        {
                            int index;
                            if (string.IsNullOrEmpty(bool_name) || !variables.Contains(bool_name)) index = 0;
                            else index = variables.IndexOf(bool_name);
                            string newVariableBoolName = variables[EditorGUI.Popup(new Rect(x + 100, y, 180, 16), index, variables.ToArray())];
                            if (bool_name != newVariableBoolName) pi.SetParam(name, newVariableBoolName);
                        }
                    }
                    y += 26;
                    break;

                case "variable_string":
                    string string_name = pi.GetStringParam(name);
                    {
                        List<string> variables = cur_behavior_tree_.GetVariableNameList("string");
                        if (variables.Count == 0)
                        {
                            EditorGUI.LabelField(new Rect(x + 100, y, 180, 16), "Not Found");
                        }
                        else
                        {
                            int index;
                            if (string.IsNullOrEmpty(string_name) || !variables.Contains(string_name)) index = 0;
                            else index = variables.IndexOf(string_name);
                            string newVariableBoolName = variables[EditorGUI.Popup(new Rect(x + 100, y, 180, 16), index, variables.ToArray())];
                            if (string_name != newVariableBoolName) pi.SetParam(name, newVariableBoolName);
                        }
                    }
                    y += 26;
                    break;

                case "Weights":
                    Weights value = pi.GetObjectParam(name) as Weights;
                    if (value == null) pi.SetParam(name, (value = new Weights()));
                    ShowWeightsProperty(value, ref x, ref y);
                    break;

                case "Comparator":
                    Comparator cpmparator_value = pi.GetObjectParam(name) as Comparator;
                    if (cpmparator_value == null) pi.SetParam(name, (cpmparator_value = new Comparator()));
                    ShowComparatorProperty(cpmparator_value, ref x, ref y);
                    break;
                    
                case "select_CompareType":
                    int select_CompareTypeIndex = pi.GetIntParam(name) > 0 ? pi.GetIntParam(name) - 1 : 0;
                    int newSelect_CompareTypeIndex = EditorGUI.Popup(new Rect(x + 100, y, 220, 16), select_CompareTypeIndex, AIConst.kCompareTypeName);
                    if (select_CompareTypeIndex != newSelect_CompareTypeIndex) pi.SetParam(name, newSelect_CompareTypeIndex + 1);
                    y += 26;
                    break;
            }
        }

        private void ShowWeightsProperty(Weights weights_value, ref float x, ref float y)
        {
            if (weights_value.weights_.Count == 0)
            {
                weights_value.weights_.Add(new SharedFloat(0));
            }
            int add_index = -1;
            int remove_index = -1;
            SharedFloat s_float_value;
            for (int j = 0; j < weights_value.weights_.Count; ++j)
            {
                s_float_value = weights_value.weights_[j];
                if (s_float_value.value_type_ == ValueType.VT_Value)
                {
                    s_float_value.value_ = EditorGUI.FloatField(new Rect(x + 60, y, 180, 16), s_float_value.value_);
                }
                else
                {
                    List<string> floatVariables = cur_behavior_tree_.GetVariableNameList("float");
                    if (floatVariables.Count == 0)
                    {
                        EditorGUI.LabelField(new Rect(x + 60, y, 180, 16), "Not Found");
                    }
                    else
                    {
                        int floatVariablesIndex;
                        if (!floatVariables.Contains(s_float_value.variable_name_)) floatVariablesIndex = 0;
                        else floatVariablesIndex = floatVariables.IndexOf(s_float_value.variable_name_);
                        s_float_value.variable_name_ = floatVariables[EditorGUI.Popup(new Rect(x + 60, y, 180, 16), floatVariablesIndex, floatVariables.ToArray())];
                    }
                }
                if (GUI.Button(new Rect(x + 246, y - 3, 40, 20), "<~>"))
                {
                    if (s_float_value.value_type_ == ValueType.VT_Value) s_float_value.value_type_ = ValueType.VT_Variable;
                    else s_float_value.value_type_ = ValueType.VT_Value;
                }
                if (GUI.Button(new Rect(x + 286, y - 3, 20, 20), "+"))
                {
                    add_index = j;
                }
                if (GUI.Button(new Rect(x + 312, y - 3, 20, 20), "-"))
                {
                    remove_index = j;
                }
                y += 26;
            }
            if (remove_index != -1)
            {
                weights_value.weights_.RemoveAt(remove_index);
            }
            if (add_index != -1)
            {
                weights_value.weights_.Insert(add_index, new SharedFloat(0));
            }
        }  //画权重

        private void ShowComparatorProperty(Comparator comparator_value, ref float x, ref float y)
        {
            int old_index = AIConst.kVariableTypeName.IndexOf(comparator_value.value_type_);
            int new_index = EditorGUI.Popup(new Rect(x + 100, y, 180, 16), old_index, AIConst.kVariableTypeName.ToArray());
            if (old_index != new_index)
            {
                comparator_value.value_type_ = AIConst.kVariableTypeName[new_index];
                comparator_value.ClearValues();
            }
            y += 26;

            if (ShowComparatorValue(comparator_value.value_type_, ref comparator_value.value1_type_, ref comparator_value.value1_, ref comparator_value.variable1_name_, ref x, ref y))
            {
                if (comparator_value.value1_type_ == ValueType.VT_Value)
                {
                    comparator_value.value1_type_ = ValueType.VT_Variable;
                    comparator_value.ClearValues(2, 2);
                }
                else
                {
                    comparator_value.value1_type_ = ValueType.VT_Value;
                    comparator_value.ClearValues(3, 2);
                }
            }

            int new_type = EditorGUI.Popup(new Rect(x + 100, y, 180, 16), (int)comparator_value.compare_type_ - 1, AIConst.kCompareTypeName);
            if (new_type + 1 != (int)comparator_value.compare_type_) comparator_value.compare_type_ = (CompareType)(new_type + 1);
            y += 26;

            if (ShowComparatorValue(comparator_value.value_type_, ref comparator_value.value2_type_, ref comparator_value.value2_, ref comparator_value.variable2_name_, ref x, ref y))
            {
                if (comparator_value.value2_type_ == ValueType.VT_Value)
                {
                    comparator_value.value2_type_ = ValueType.VT_Variable;
                    comparator_value.ClearValues(2, 3);
                }
                else
                {
                    comparator_value.value2_type_ = ValueType.VT_Value;
                    comparator_value.ClearValues(3, 3);
                }
            }
        }  //画对比

        private bool ShowComparatorValue(string type, ref ValueType value_type, ref object value, ref string variable_name, ref float x, ref float y)
        {
            int variable_index;
            switch (type)
            {
                case "string":
                    if (value_type == ValueType.VT_Value)
                    {
                        value = EditorGUI.TextField(new Rect(x + 100, y, 180, 16), (string)value);
                    }
                    else
                    {
                        List<string> variables = cur_behavior_tree_.GetVariableNameList("string");
                        if (variables.Count == 0)
                        {
                            EditorGUI.LabelField(new Rect(x + 100, y, 180, 16), "Not Found");
                            break;
                        }
                        if (!variables.Contains(variable_name)) variable_index = 0;
                        else variable_index = variables.IndexOf(variable_name);
                        variable_name = variables[EditorGUI.Popup(new Rect(x + 100, y, 180, 16), variable_index, variables.ToArray())];
                    }
                    break;
                case "int":
                    if (value_type == ValueType.VT_Value)
                    {
                        value = EditorGUI.IntField(new Rect(x + 100, y, 180, 16), (int)value);
                    }
                    else
                    {
                        List<string> variables = cur_behavior_tree_.GetVariableNameList("int");
                        if (variables.Count == 0)
                        {
                            EditorGUI.LabelField(new Rect(x + 100, y, 180, 16), "Not Found");
                            break;
                        }
                        if (!variables.Contains(variable_name)) variable_index = 0;
                        else variable_index = variables.IndexOf(variable_name);
                        variable_name = variables[EditorGUI.Popup(new Rect(x + 100, y, 180, 16), variable_index, variables.ToArray())];
                    }
                    break;
                case "float":
                    if (value_type == ValueType.VT_Value)
                    {
                        value = EditorGUI.FloatField(new Rect(x + 100, y, 180, 16), float.Parse(value.ToString()));
                    }
                    else
                    {
                        List<string> variables = cur_behavior_tree_.GetVariableNameList("float");
                        if (variables.Count == 0)
                        {
                            EditorGUI.LabelField(new Rect(x + 100, y, 180, 16), "Not Found");
                            break;
                        }
                        if (!variables.Contains(variable_name)) variable_index = 0;
                        else variable_index = variables.IndexOf(variable_name);
                        variable_name = variables[EditorGUI.Popup(new Rect(x + 100, y, 180, 16), variable_index, variables.ToArray())];
                    }
                    break;
                case "bool":
                    if (value_type == ValueType.VT_Value)
                    {
                        value = EditorGUI.Toggle(new Rect(x + 100, y, 180, 16), (bool)value);
                    }
                    else
                    {
                        List<string> variables = cur_behavior_tree_.GetVariableNameList("bool");
                        if (variables.Count == 0)
                        {
                            EditorGUI.LabelField(new Rect(x + 100, y, 180, 16), "Not Found");
                            break;
                        }
                        if (!variables.Contains(variable_name)) variable_index = 0;
                        else variable_index = variables.IndexOf(variable_name);
                        variable_name = variables[EditorGUI.Popup(new Rect(x + 100, y, 180, 16), variable_index, variables.ToArray())];
                    }
                    break;
                case "Vector2":
                    if (value_type == ValueType.VT_Value)
                    {
                        value = EditorGUI.Vector2Field(new Rect(x + 100, y, 180, 16), "", (Vector2)value);
                    }
                    else
                    {
                        List<string> variables = cur_behavior_tree_.GetVariableNameList("Vector2");
                        if (variables.Count == 0)
                        {
                            EditorGUI.LabelField(new Rect(x + 100, y, 180, 16), "Not Found");
                            break;
                        }
                        if (!variables.Contains(variable_name)) variable_index = 0;
                        else variable_index = variables.IndexOf(variable_name);
                        variable_name = variables[EditorGUI.Popup(new Rect(x + 100, y, 180, 16), variable_index, variables.ToArray())];
                    }
                    break;
                case "Vector3":
                    if (value_type == ValueType.VT_Value)
                    {
                        value = EditorGUI.Vector3Field(new Rect(x + 100, y, 180, 16), "", (Vector3)value);
                    }
                    else
                    {
                        List<string> variables = cur_behavior_tree_.GetVariableNameList("Vector3");
                        if (variables.Count == 0)
                        {
                            EditorGUI.LabelField(new Rect(x + 100, y, 180, 16), "Not Found");
                            break;
                        }
                        if (!variables.Contains(variable_name)) variable_index = 0;
                        else variable_index = variables.IndexOf(variable_name);
                        variable_name = variables[EditorGUI.Popup(new Rect(x + 100, y, 180, 16), variable_index, variables.ToArray())];
                    }
                    break;
            }
            bool onSwitchButton = GUI.Button(new Rect(x + 286, y - 3, 40, 20), "<~>");
            y += 26;
            return onSwitchButton;
        }
        #endregion

        #region 全局变量栏
        private void UpdateVariablePanel()
        {
            if (!is_show_variable_panel_)
            {
                variable_btn_rect_ = new Rect(20, screen_height_ - 82, 50, 50);
                EditorGUI.DrawRect(variable_btn_rect_, new Color(0.3f, 0.3f, 0.3f, 0.75f));
                GUI.Label(variable_btn_rect_, "G", variable_btn_style_);
            }
            else
            {
                variable_panel_rect_ = new Rect(10, screen_height_ - 320, 600, 300);
                EditorGUI.DrawRect(variable_panel_rect_, new Color(0.3f, 0.3f, 0.3f, 0.75f));
                GUILayout.BeginArea(new Rect(variable_panel_rect_.x + 10, variable_panel_rect_.y + 10, variable_panel_rect_.width - 10, variable_panel_rect_.height-20));
                variable_scroll_pos_ = GUILayout.BeginScrollView(variable_scroll_pos_);
                if (GUI.Button(new Rect(variable_panel_rect_.width - 50, 0, 20, 20), "×"))
                {
                    is_show_variable_panel_ = false;
                }
                GUILayout.Space(20);
                EditorGUILayout.LabelField("Global Variables:");
                EditorGUILayout.BeginHorizontal();
                if (temp_variable_ == null && cur_variable_type_index_ != -1)
                {
                    temp_variable_ = new AIVarible(AIConst.kVariableTypeName[cur_variable_type_index_]);
                }
                EditorGUI.BeginChangeCheck();
                cur_variable_type_index_ = EditorGUILayout.Popup(cur_variable_type_index_, AIConst.kVariableTypeName.ToArray(),GUILayout.Width(100));
                if (EditorGUI.EndChangeCheck() && cur_variable_type_index_ != -1)
                {
                    temp_variable_ = new AIVarible(AIConst.kVariableTypeName[cur_variable_type_index_]);
                }
                if (temp_variable_ != null)
                {
                    ShowVarible(temp_variable_, true);
                    if (GUILayout.Button(EditorGUIUtility.IconContent("Toolbar Plus"), "RL FooterButton"))
                    {
                        if (string.IsNullOrEmpty(temp_variable_.name))
                        {
                            Debug.LogError("名字不能为空");
                        }
                        else
                        {
                            cur_behavior_tree_.AddVariable(temp_variable_);
                        }
                    }
                }
                EditorGUILayout.EndHorizontal();
                for (int i = 0; i < AIConst.kVariableTypeName.Count; ++i)
                {
                    EditorGUILayout.Space();
                    string type = AIConst.kVariableTypeName[i];
                    variable_type_is_show_[i] = EditorGUILayout.Foldout(variable_type_is_show_[i], type + ":");
                    if (variable_type_is_show_[i])
                    {
                        var list = cur_behavior_tree_.GetVariableList(type);
                        foreach(AIVarible variable in list)
                        {
                            EditorGUILayout.BeginHorizontal();
                            ShowVarible(variable);
                            if (GUILayout.Button(EditorGUIUtility.IconContent("Toolbar Minus"), "RL FooterButton"))
                            {
                                cur_behavior_tree_.DelVariable(variable);
                                EditorGUILayout.EndHorizontal();
                                GUILayout.EndArea();
                                return;
                            }
                            EditorGUILayout.EndHorizontal();
                            GUILayout.Space(5);
                        }
                    }
                }
                GUILayout.EndScrollView();
                GUILayout.EndArea();
            }
        }

        private void ShowVarible(AIVarible varible, bool is_temp = false)
        {
            GUILayout.Space(40);
            if (is_temp)
            {
                GUILayout.Space(30);
                varible.name = EditorGUILayout.TextField(varible.name, GUILayout.Width(130));
                GUILayout.Space(50);
            }
            else
            {
                EditorGUILayout.LabelField(varible.name, GUILayout.Width(100));
            }
            switch (varible.value.key)
            {
                case "string":
                    varible.value.v_string = EditorGUILayout.TextField(varible.value.v_string, GUILayout.Width(130));
                    break;
                case "int":
                    varible.value.v_int = EditorGUILayout.IntField(varible.value.v_int, GUILayout.Width(130));
                    break;
                case "float":
                    varible.value.v_float = EditorGUILayout.FloatField(varible.value.v_float, GUILayout.Width(130));
                    break;
                case "bool":
                    varible.value.v_bool = EditorGUILayout.Toggle(varible.value.v_bool, GUILayout.Width(130));
                    break;
                case "Vector2":
                    varible.value.v_vector2 = EditorGUILayout.Vector2Field("", varible.value.v_vector2, GUILayout.Width(130));
                    break;
                case "Vector3":
                    varible.value.v_vector3 = EditorGUILayout.Vector3Field("", varible.value.v_vector3, GUILayout.Width(130));
                    break;
            }
            if (!is_temp)
            {
                GUILayout.Space(20);
                EditorGUILayout.LabelField("remark:", GUILayout.Width(60));
                varible.remark = EditorGUILayout.TextField(varible.remark, GUILayout.Width(130));
            }
        }
        #endregion
        #endregion
    }
}
