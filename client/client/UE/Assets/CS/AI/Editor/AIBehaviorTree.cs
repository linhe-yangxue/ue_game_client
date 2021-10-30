using System.Collections.Generic;
using LT;
using UnityEngine;
using PI;

namespace AI
{
    public class AIBehaviorTree//用于描述ai编辑器中的树结构
    {
        private AIBTData _ai_bt_data_;

        public string name_ { get { return _ai_bt_data_.ai_name_; } }

        public AIBehaviorTreeNode root_ { get { return _uuid2_node_[_ai_bt_data_.root_]; } }

        private List<AIBehaviorTreeNode> _node_list_;

        public List<AIBehaviorTreeNode> node_list_ { get { return _node_list_; } }

        private Dictionary<int, AIBehaviorTreeNode> _uuid2_node_;

        public AIBehaviorTreeNode GetNodeByUuid(int uuid)
        {
            if (!_uuid2_node_.ContainsKey(uuid)) return null;
            else return _uuid2_node_[uuid];
        }

        public bool is_show_comment_ { set { _ai_bt_data_.is_show_comment_ = value; } }

        private AIBTNodeConnectionCollect _connections_;

        public AIBTNodeConnectionCollect connection_ { get { return _connections_; } }

        private List<AIBehaviorTreeNode> _selected_nodes_;

        public List<AIBehaviorTreeNode> GetSelectedNodes() { return _selected_nodes_; }

        private List<AIBehaviorTreeNode> _selected_conn_nodes_;

        private List<AIBehaviorTreeNode> _node_for_copy_list_;

        public bool is_prepare_for_copy_ { get { return _node_for_copy_list_.Count > 0; } }

        public List<AIVarible> GetVariableList(string type)
        {
            List<AIVarible> list = new List<AIVarible>();
            foreach (var ai_varible in _ai_bt_data_.variable_list_)
            {
                if (ai_varible.value.key == type)
                {
                    list.Add(ai_varible);
                }
            }
            return list;
        }

        public List<string> GetVariableNameList(string type)
        {
            List<string> list = new List<string>();
            foreach (var ai_varible in _ai_bt_data_.variable_list_)
            {
                if (ai_varible.value.key == type)
                {
                    list.Add(ai_varible.name);
                }
            }
            return list;
        }

        public void AddVariable(AIVarible variable)
        {
            var ret = _ai_bt_data_.variable_list_.Find(x => x.name == variable.name);
            if (ret != null)
            {
                Debug.LogError("已有的变量名");
            }
            else
            {
                _ai_bt_data_.variable_list_.Add(variable.Copy());
            }
        }

        public void DelVariable(AIVarible variable)
        {
            if (_ai_bt_data_.variable_list_.Contains(variable))
            {
                _ai_bt_data_.variable_list_.Remove(variable);
            }
        }

        public AIBehaviorTree(AIBTData data)
        {
            _ai_bt_data_ = data;
            _node_list_ = new List<AIBehaviorTreeNode>();
            _uuid2_node_ = new Dictionary<int, AIBehaviorTreeNode>();
            _connections_ = new AIBTNodeConnectionCollect();
            _selected_nodes_ = new List<AIBehaviorTreeNode>();
            _selected_conn_nodes_ = new List<AIBehaviorTreeNode>();
            _node_for_copy_list_ = new List<AIBehaviorTreeNode>();

            AIBehaviorTreeNode node;
            List<AIBehaviorTreeNode> updateConnList = new List<AIBehaviorTreeNode>();
            for (int i = 0; i < _ai_bt_data_.node_list_.Count; ++i)
            {
                // 出现奇怪UUID的BUG且只在NodeUuidList跟Children里，不知道bug出现原因下先做的处理
                if (_ai_bt_data_.node_uuid_list_[i] != _ai_bt_data_.node_list_[i].uuid_)
                {
                    if (_ai_bt_data_.node_uuid_list_.Contains(_ai_bt_data_.node_list_[i].uuid_))
                    {
                        Debug.LogError("UUID顺序出错?: " + _ai_bt_data_.node_list_[i].uuid_);
                    }
                    else
                    {
                        foreach (AIBehaviorTreeNode.AIBTNodeData d in _ai_bt_data_.node_list_)
                        {
                            if (d.children_.Contains(_ai_bt_data_.node_uuid_list_[i])) d.children_[d.children_.IndexOf(_ai_bt_data_.node_uuid_list_[i])] = _ai_bt_data_.node_list_[i].uuid_;
                        }
                        _ai_bt_data_.node_uuid_list_[i] = _ai_bt_data_.node_list_[i].uuid_;
                    }
                }
                node = new AIBehaviorTreeNode(_ai_bt_data_.node_list_[i], this, _connections_);
                _node_list_.Add(node);
                _uuid2_node_.Add(node.uuid_, node);
                if (node.children_.Count > 0) updateConnList.Add(node);
            }
            foreach (AIBehaviorTreeNode n in _node_list_)  // 因为树的uuid对应结点表可能没初始化完 所以在新的一个循环里更新父结点信息
            {
                n.UpdateParent();
            }
            updateConnList.ForEach(n => n.UpdateChildrenConnRects());
        }

        private AIBehaviorTreeNode AddNode(AIBTNodeType type, Vector2 pos, AIBehaviorTreeNode parent = null)
        {
            if (type == AIBTNodeType.Entry) return null;
            if (parent != null && parent.no_child_limit_) return null;

            int Uuid;
            AIBehaviorTreeNode node = new AIBehaviorTreeNode(_ai_bt_data_.AddNode(type, out Uuid), this, _connections_);

            if (_selected_nodes_.Count > 0)
            {
                _selected_nodes_.ForEach(n => n.is_selected_ = false);
                _selected_nodes_.Clear();
            }
            _selected_nodes_.Add(node);
            node.is_selected_ = true;

            _uuid2_node_.Add(Uuid, node);
            _node_list_.Add(node);

            if (parent != null)
            {
                node.SetPos(parent.GetNewChildPos());
                node.AddConn(parent);
            }
            else
            {
                node.SetPos(pos);
            }

            return node;
        }

        private void CopyNodes(Vector2 pos, AIBehaviorTreeNode parent = null)
        {
            AIBehaviorTreeNode node = _node_for_copy_list_[0];
            if (node.type_ == AIBTNodeType.Entry) return;

            int Uuid;
            AIBehaviorTreeNode newNode = new AIBehaviorTreeNode(_ai_bt_data_.AddNode(node, out Uuid), this, _connections_);

            _uuid2_node_.Add(Uuid, newNode);
            _node_list_.Add(newNode);

            if (parent != null)
            {
                newNode.SetPos(parent.GetNewChildPos());
                newNode.AddConn(parent);
            }
            else
            {
                newNode.SetPos(pos);
            }

            foreach (AIBehaviorTreeNode n in _node_for_copy_list_)
            {
                if (n.parent_ == node)
                    CopyNode(n, newNode);
            }
        }

        private void CopyNode(AIBehaviorTreeNode node, AIBehaviorTreeNode parent)
        {
            int Uuid;
            AIBehaviorTreeNode newNode = new AIBehaviorTreeNode(_ai_bt_data_.AddNode(node, out Uuid), this, _connections_);

            _uuid2_node_.Add(Uuid, newNode);
            _node_list_.Add(newNode);

            newNode.SetPos(parent.pos_ + node.pos_ - node.parent_.pos_);
            newNode.AddConn(parent);

            foreach (AIBehaviorTreeNode n in _node_for_copy_list_)
            {
                if (n.parent_ == node)
                    CopyNode(n, newNode);
            }
        }

        private AIBehaviorTreeNode RemoveNode(AIBehaviorTreeNode node)
        {
            if (node.uuid_ == _ai_bt_data_.root_ || !_node_list_.Contains(node)) return null;

            if (!node.is_show_children_ && node.children_.Count > 0) node.ShowChildren();

            List<int> child_list = new List<int>(node.children_);
            child_list.ForEach(n => _uuid2_node_[n].RemoveConn());
            node.RemoveConn();

            _node_list_.Remove(node);
            _uuid2_node_.Remove(node.uuid_);
            _ai_bt_data_.RemoveNode(node.uuid_);

            return node;
        }

        #region 消息处理
        private bool SelectOrCancelSelectNode(AIBehaviorTreeNode node, bool is_at_show_children_area, ref bool is_selected, bool cancel_selected, bool allow_multi_choose)
        {
            is_selected = node.is_selected_;
            if (is_at_show_children_area)
            {
                if (!node.is_show_children_)
                {
                    node.ShowChildren();
                }
                else
                {
                    node.HideChildren();
                }
            }
            else if (cancel_selected)    // 非点击展开子结点区 且允许取消 则取消选中
            {
                node.is_selected_ = false;
                _selected_nodes_.Remove(node);
                return false;
            }

            if (!is_selected)    // 未选中过 则更改状态
            {
                node.is_selected_ = true;
                if (!_selected_nodes_.Contains(node))
                {
                    if (!allow_multi_choose && _selected_nodes_.Count > 0)
                    {
                        _selected_nodes_.ForEach(n => n.is_selected_ = false);
                        _selected_nodes_.Clear();
                    }
                    _selected_nodes_.Add(node);
                }
            }
            _selected_conn_nodes_.ForEach(n => n.is_conn_selected_ = false);
            _selected_conn_nodes_.Clear();
            return true;
        }

        public bool CheckSelect(Vector2 vector, ref bool isSelected, bool cancelSelected, bool allowMultiChoose, bool showOrHideChildren = false)
        {
            foreach (AIBehaviorTreeNode n in _node_list_)
            {
                if (n.is_hovering_)    // 已经悬停于结点上直接选中
                {
                    return SelectOrCancelSelectNode(n, showOrHideChildren ? new Rect(n.pos_show_children_area_, AIConst.SHOW_CHILDREN_AREA_SIZE).Contains(vector) : false, ref isSelected, cancelSelected, allowMultiChoose);
                }
            }
            AIBehaviorTreeNode node;
            for (int i = _node_list_.Count - 1; i >= 0; --i)  // 优先判断新加结点（新加结点会显示在旧结点上，如果重叠的话)
            {
                node = _node_list_[i];
                if (node.is_show_self_ && new Rect(node.pos_, AIConst.NODE_SIZE).Contains(vector)) // 可视且在区域内则选中
                {
                    return SelectOrCancelSelectNode(node, showOrHideChildren ? new Rect(node.pos_show_children_area_, AIConst.SHOW_CHILDREN_AREA_SIZE).Contains(vector) : false, ref isSelected, cancelSelected, allowMultiChoose);
                }
            }
            _node_list_.ForEach(i => i.is_selected_ = false);
            _selected_nodes_.Clear();
            isSelected = false;

            bool connFlag = false;
            bool selectFlag;
            foreach (var conn in _connections_)
            {
                selectFlag = false;
                if (conn.Key.is_conn_hovering_)    // 已经悬停于连线上直接选中
                {
                    selectFlag = true;
                }
                else if (conn.Key.is_show_self_)
                {
                    foreach (Rect rect in conn.Value.GetCheckRects())
                    {
                        if (rect.Contains(vector)) // 可视且在区域内则选中
                        {
                            selectFlag = true;
                            break;
                        }
                    }
                }
                if (selectFlag)
                {
                    conn.Key.is_conn_selected_ = true;
                    if (!_selected_conn_nodes_.Contains(conn.Key)) _selected_conn_nodes_.Add(conn.Key);
                    connFlag = true;
                }
                else
                {
                    conn.Key.is_conn_selected_ = false;
                    if (_selected_conn_nodes_.Contains(conn.Key)) _selected_conn_nodes_.Remove(conn.Key);
                }
            }
            return connFlag;
        }

        public bool CheckHover(Vector2 vector)
        {
            AIBehaviorTreeNode node;
            bool flag = false;
            for (int i = _node_list_.Count - 1; i >= 0; --i)  // 优先判断新加结点（新加结点会显示在旧结点上，如果重叠的话)
            {
                node = _node_list_[i];
                if (!flag && node.is_show_self_ && new Rect(node.pos_, AIConst.NODE_SIZE).Contains(vector))
                {
                    flag = node.is_hovering_ = true;
                }
                else
                {
                    node.is_hovering_ = false;
                }
            }

            bool connFlag = false;
            foreach (var conn in _connections_)
            {
                conn.Key.is_conn_hovering_ = false;
                if (!flag)
                {
                    foreach (Rect rect in conn.Value.GetCheckRects())
                    {
                        if (rect.Contains(vector))
                        {
                            connFlag = conn.Key.is_conn_hovering_ = true;
                            break;
                        }
                    }
                }
            }
            return flag || connFlag;
        }

        private void MoveSelectedNodes(Vector2 delta)
        {
            HashSet<AIBehaviorTreeNode> moveSet = new HashSet<AIBehaviorTreeNode>();
            HashSet<AIBehaviorTreeNode> updateRectSet = new HashSet<AIBehaviorTreeNode>();
            foreach (AIBehaviorTreeNode node in _selected_nodes_)
            {
                FindChildrenForMove(node, ref moveSet, ref updateRectSet);
            }
            foreach (AIBehaviorTreeNode node in moveSet)
            {
                node.SetPos(node.pos_ + delta);
            }
            foreach (AIBehaviorTreeNode node in updateRectSet)
            {
                node.UpdateChildrenConnRects();
            }
        }

        private void FindChildrenForMove(AIBehaviorTreeNode node, ref HashSet<AIBehaviorTreeNode> moveSet, ref HashSet<AIBehaviorTreeNode> updateRectSet)
        {
            moveSet.Add(node);
            updateRectSet.Add(node);
            if (node.parent_ != null) updateRectSet.Add(node.parent_);
            AIBehaviorTreeNode n;
            foreach (int i in node.children_)
            {
                n = _uuid2_node_[i];
                if (!n.is_selected_) FindChildrenForMove(n, ref moveSet, ref updateRectSet);
            }
        }

        public bool CheckDragSelectedNode(Vector2 delta)
        {
            if (_selected_nodes_.Count > 0)
            {
                MoveSelectedNodes(delta);
                return true;
            }
            else
            {
                return false;
            }
        }

        public bool CheckShowOrHideChildren(Vector2 vector)
        {
            bool isSelected = false;
            if (CheckSelect(vector, ref isSelected, false, false))   // 有选中就展开
            {
                foreach (AIBehaviorTreeNode node in _selected_nodes_)
                {
                    if (!node.is_show_children_)
                        node.ShowChildren();
                    else
                        node.HideChildren();
                }
                return true;
            }
            else
            {
                return false;
            }
        }

        public bool CheckAddNode(AIBTNodeType type, Vector2 addPos)
        {
            if (_selected_nodes_.Count > 1)
            {
                Debug.LogError("添加失败：当前选中了多个结点，不确定要将新结点加到哪个结点");
                return false;
            }

            _selected_conn_nodes_.ForEach(n => n.is_conn_selected_ = false);
            _selected_conn_nodes_.Clear();
            if (_selected_nodes_.Count == 0)
            {
                return AddNode(type, addPos, null) != null;
            }
            else
            {
                return AddNode(type, addPos, _selected_nodes_[0]) != null;
            }
        }

        public bool CheckAddNode(AIBTNodeType type)
        {
            return CheckAddNode(type, AIConst.NODE_DEFAULT_POS);
        }

        public bool CheckRemoveSelected()
        {
            bool flag = false;
            if (_selected_nodes_.Count > 0)
            {
                List<AIBehaviorTreeNode> removeList = new List<AIBehaviorTreeNode>();
                foreach (AIBehaviorTreeNode node in _selected_nodes_)
                {
                    if (RemoveNode(node) != null)
                    {
                        flag = true;
                        removeList.Add(node); 
                    }
                }
                foreach (AIBehaviorTreeNode node in removeList)
                {
                    _selected_nodes_.Remove(node);
                }
            }
            if (_selected_conn_nodes_.Count > 0)
            {
                _selected_conn_nodes_.ForEach(n => n.RemoveConn());
                _selected_conn_nodes_.Clear();
                flag = true;
            }
            return flag;
        }

        public void CheckCopyNodes()
        {
            _node_for_copy_list_.Clear();
            if (_selected_nodes_.Count == 0)
            {
                UnityEditor.EditorUtility.DisplayDialog("复制结点", "失败：没有选中的结点", "返回");
            }
            else if (_selected_nodes_.Count > 1)
            {
                UnityEditor.EditorUtility.DisplayDialog("复制结点", "失败：选中了多个结点，不明确复制哪个结点", "返回");
            }
            else if (_selected_nodes_[0].type_ == AIBTNodeType.Entry)
            {
                UnityEditor.EditorUtility.DisplayDialog("复制结点", "失败：不可复制的结点", "返回");
            }
            else
            {
                _node_for_copy_list_.Add(_selected_nodes_[0]);
                foreach (int uuid in _selected_nodes_[0].GetAllChildrenList())
                {
                    _node_for_copy_list_.Add(_uuid2_node_[uuid]);
                }
            }
        }

        public void CheckPasteNodes()
        {
            if (_node_for_copy_list_.Count == 0)
            {
                UnityEditor.EditorUtility.DisplayDialog("粘贴结点", "失败：没有要复制的结点", "返回");
                return;
            }
            else if (_selected_nodes_.Count > 1)
            {
                UnityEditor.EditorUtility.DisplayDialog("粘贴结点", "失败：选中了多个结点，不明确粘贴到哪个结点上", "返回");
                return;
            }
            else if (_selected_nodes_.Count == 1 && _selected_nodes_[0].no_child_limit_)
            {
                UnityEditor.EditorUtility.DisplayDialog("粘贴结点", "失败：所选结点不能有子结点", "返回");
                return;
            }

            if (_selected_nodes_.Count == 0)
            {
                CopyNodes(AIConst.NODE_DEFAULT_POS);
            }
            else
            {
                CopyNodes(AIConst.NODE_DEFAULT_POS, _selected_nodes_[0]);
            }
            _selected_conn_nodes_.ForEach(n => n.is_conn_selected_ = false);
            _selected_conn_nodes_.Clear();
            _selected_nodes_.ForEach(n => n.is_selected_ = false);
            _selected_nodes_.Clear();
        }

        public void CheckSelectAll()
        {
            _selected_nodes_.Clear();
            node_list_.ForEach(n => n.is_selected_ = true);
            _selected_nodes_.AddRange(node_list_);
        }

        public void ClearSelected()
        {
            _selected_nodes_.ForEach(n => n.is_selected_ = false);
            _selected_nodes_.Clear();
            _selected_conn_nodes_.ForEach(n => n.is_conn_selected_ = false);
            _selected_conn_nodes_.Clear();
        }

        public void SaveData(AIBTRecord record, AIBTData tree_data)
        {
            record.SaveTree(tree_data);
        }

        public bool Export(AIBTRecord record)
        {
            return record.Export(_ai_bt_data_);
        }
        #endregion
    }


    [System.Serializable]
    public class AIVarible
    {
        public string name;
        public ParamData value;
        public string remark;

        public AIVarible(){}

        public AIVarible(string type)
        {
            switch (type)
            {
                case "string":
                    value = new ParamData(type, "");
                    break;
                case "int":
                    value = new ParamData(type, 0);
                    break;
                case "float":
                    value = new ParamData(type, 0f);
                    break;
                case "bool":
                    value = new ParamData(type, false);
                    break;
                case "Vector2":
                    value = new ParamData(type, Vector2.zero);
                    break;
                case "Vector3":
                    value = new ParamData(type, Vector3.zero);
                    break;
            }
        }

        public AIVarible Copy()
        {
            var copy = new AIVarible();
            copy.name = name;
            copy.value = value.Copy();
            copy.remark = remark;
            return copy;
        }
    }
}
