using System;
using System.Collections.Generic;
using LT;
using UnityEngine;

namespace AI
{
    public class AIBehaviorTreeNode//用于描述ai编辑器中的节点数据
    {
        [System.Serializable]
        public class AIBTNodeData
        {
            public int uuid_;

            public AIBTNodeType type_;

            public int parent_;

            public List<int> children_;

            public AIBTNodePI params_;

            public string name_;

            public string comment_;

            public Vector2 pos_;

            public bool is_show_self_;

            public bool is_show_children_;

            private AIBTNodeData() { }

            public AIBTNodeData(int uuid, AIBTNodeType type, string name)
            {
                this.uuid_ = uuid;
                this.type_ = type;
                this.name_ = name;
                comment_ = "";
                parent_ = -1;
                children_ = new List<int>();
                params_ = new AIBTNodePI(AIConst.kNodeType2TypeName[this.type_]);
            }

            public AIBTNodeData(AIBehaviorTreeNode node, int uuid)
            {
                this.uuid_ = uuid;
                type_ = node._bt_node_data_.type_;
                params_ = node._bt_node_data_.params_.Copy();
                name_ = node._bt_node_data_.name_;
                comment_ = node._bt_node_data_.comment_;
                parent_ = -1;
                children_ = new List<int>();
                is_show_self_ = node._bt_node_data_.is_show_self_;
                is_show_children_ = node._bt_node_data_.is_show_children_;
            }

            public AIBTNodeData Copy()
            {
                AIBTNodeData copy = new AIBTNodeData();
                copy.uuid_ = uuid_;
                copy.type_ = type_;
                copy.parent_ = parent_;
                copy.children_ = new List<int>(children_);
                copy.params_ = params_.Copy();
                copy.name_ = name_;
                copy.comment_ = comment_;
                copy.pos_ = new Vector2(pos_.x, pos_.y);
                copy.is_show_self_ = is_show_self_;
                copy.is_show_children_ = is_show_children_;
                return copy;
            }

            public LValue GenLtable(bool is_one_line, List<int> childrenIds)
            {
                int t = (int)type_;
                LTable re = new LTable(is_one_line);
                re["node_type"] = new LNum(t);
                re["children"] = GenLTable.gen(childrenIds, childrenIds.GetType(), true);
                params_.gen_ltable(false, re);
                return re;
            }
        }

        private AIBTNodeData _bt_node_data_;

        public int uuid_ { get { return _bt_node_data_.uuid_; } }

        public AIBTNodeType type_ { get { return _bt_node_data_.type_; } }

        public List<int> children_ { get { return _bt_node_data_.children_; } }

        public void SortChildren()
        {
            if (_bt_node_data_.children_.Count > 0) _bt_node_data_.children_.Sort(ChildrenComparison);
        }

        public int ChildrenComparison(int left, int right)
        {
            float leftPos = _tree_.GetNodeByUuid(left)._bt_node_data_.pos_.x;
            float rightPos = _tree_.GetNodeByUuid(right)._bt_node_data_.pos_.x;
            if (leftPos < rightPos)
            {
                return -1;
            }
            else if (leftPos > rightPos)
            {
                return 1;
            }
            else
            {
                return 0;
            }
        }

        public AIBTNodePI params_ { get { return _bt_node_data_.params_; } }

        public string name_ { set { _bt_node_data_.name_ = value; } get { return _bt_node_data_.name_; } }

        public string comment_ { set { _bt_node_data_.comment_ = value; } get { return _bt_node_data_.comment_; } }

        public Vector2 pos_ { get { return _bt_node_data_.pos_; } }

        public Vector2 pos_show_name_area_ { get { return _bt_node_data_.pos_ + new Vector2(9, 14); } }

        public Vector2 pos_show_children_area_ { get { return _bt_node_data_.pos_ + new Vector2(14, 48); } }

        public Vector2 pos_show_comment_ { get { return _bt_node_data_.pos_ + new Vector2(64, 0); } }

        public Vector2 pos_link_to_parent_ { get { return _bt_node_data_.pos_ + new Vector2(31, 0); } }  // -1 为连线宽度一半

        public Vector2 pos_link_to_children_ { get { return _bt_node_data_.pos_ + new Vector2(31, 64); } }  // -1 为连线宽度一半

        public float GetBalancePos()    // 画连线用
        {
            if (_bt_node_data_.children_.Count == 0) return _bt_node_data_.pos_.y + 70;
            float pos = _tree_.GetNodeByUuid(_bt_node_data_.children_[0])._bt_node_data_.pos_.y;
            for (int i = 1; i < _bt_node_data_.children_.Count; ++i)
            {
                pos = Math.Min(_tree_.GetNodeByUuid(_bt_node_data_.children_[i])._bt_node_data_.pos_.y, pos);
            }
            pos = Math.Max(_bt_node_data_.pos_.y + 70, pos - Math.Abs(_bt_node_data_.pos_.y - pos + 64) * 0.3f);
            return pos;
        }

        public bool is_show_self_ { get { return _bt_node_data_.is_show_self_; } }

        public bool is_show_children_ { get { return _bt_node_data_.is_show_children_; } }

        public bool is_selected_;

        public bool is_hovering_;

        public bool is_conn_selected_;

        public bool is_conn_hovering_;

        private AIBehaviorTreeNode _parent_;

        public AIBehaviorTreeNode parent_ { set { _parent_ = value; _bt_node_data_.parent_ = _parent_ != null ? _parent_.uuid_ : -1; } get { return _parent_; } }

        private AIBehaviorTree _tree_;

        private AIBTNodeConnectionCollect _connections_;

        private bool _no_child_limit_;

        public bool no_child_limit_ { get { return _no_child_limit_; } }

        private bool _single_child_limit_;

        public AIBehaviorTreeNode(int uuid, AIBTNodeType type, string name, AIBehaviorTree tree, AIBTNodeConnectionCollect connections)
        {
            _bt_node_data_ = new AIBTNodeData(uuid, type, name);
            _tree_ = tree;
            _connections_ = connections;

            AIBTNodeCategory cate = AIConst.GetCategory(_bt_node_data_.type_);
            if (cate == AIBTNodeCategory.Action || cate == AIBTNodeCategory.Condition || cate == AIBTNodeCategory.Unknown) _no_child_limit_ = true;
            else if (cate == AIBTNodeCategory.Entry || cate == AIBTNodeCategory.Decorator) _single_child_limit_ = true;

            _bt_node_data_.is_show_self_ = true;
        }

        public AIBehaviorTreeNode(AIBTNodeData data, AIBehaviorTree tree, AIBTNodeConnectionCollect connections)
        {
            _bt_node_data_ = data;
            _tree_ = tree;
            _connections_ = connections;

            AIBTNodeCategory cate = AIConst.GetCategory(_bt_node_data_.type_);
            if (cate == AIBTNodeCategory.Action || cate == AIBTNodeCategory.Condition || cate == AIBTNodeCategory.Unknown) _no_child_limit_ = true;
            else if (cate == AIBTNodeCategory.Entry || cate == AIBTNodeCategory.Decorator) _single_child_limit_ = true;

            _bt_node_data_.is_show_self_ = true;
        }

        public void UpdateParent()  // 因为树的uuid对应结点表可能没初始化完 所以不在构造函数里进行
        {
            _parent_ = _tree_.GetNodeByUuid(_bt_node_data_.parent_);
        }

        private void AddChild(int child_uuid)
        {
            if (_no_child_limit_) return;
            if (_single_child_limit_ && _bt_node_data_.children_.Count > 0)
            {
                AIBehaviorTreeNode n;
                List<int> children = new List<int>(_bt_node_data_.children_);
                foreach (int uuid in children)
                {
                    if ((n = _tree_.GetNodeByUuid(uuid)) != null)
                    {
                        _connections_.Remove(n);
                        n.parent_ = null;
                        _bt_node_data_.children_.Remove(uuid);
                    }
                }
            }
            _bt_node_data_.children_.Add(child_uuid);
            if (!_bt_node_data_.is_show_children_) ShowChildren(false);
            UpdateChildrenConnRects();
        }

        private AIBehaviorTreeNode RemoveChild(AIBehaviorTreeNode node)
        {
            _bt_node_data_.children_.Remove(node._bt_node_data_.uuid_);
            _connections_.Remove(node);
            UpdateChildrenConnRects();
            if (_bt_node_data_.children_.Count == 0) _bt_node_data_.is_show_children_ = false;
            return node;
        }

        public void AddConn(AIBehaviorTreeNode parent)
        {
            if (_parent_ == parent) return;
            if (parent != null)
            {
                if (_parent_ != null)
                {
                    _parent_.RemoveChild(this);
                }
                parent.AddChild(_bt_node_data_.uuid_);
                parent_ = parent;
            }
        }

        public void RemoveConn()
        {
            if (_parent_ != null)
            {
                _parent_.RemoveChild(this);
                parent_ = null;
                is_conn_selected_ = is_conn_hovering_ = false;
            }
        }

        // 展开子结点
        public void ShowChildren(bool show_at_order = true)
        {
            if (_bt_node_data_.is_show_children_) return;

            if (show_at_order && _bt_node_data_.children_.TrueForAll(i => _tree_.GetNodeByUuid(i)._bt_node_data_.children_.Count == 0))
            {
                SortChildren();
                int total = _bt_node_data_.children_.Count;
                for (int i = 0; i < total; ++i)
                {
                    _tree_.GetNodeByUuid(_bt_node_data_.children_[i]).AdjustPos(_bt_node_data_.pos_, i, total);
                }
                UpdateChildrenConnRects();
            }
            children_.ForEach(i => _tree_.GetNodeByUuid(i).ShowSelfAndIfShowChildren());
            _bt_node_data_.is_show_children_ = true;
        }

        // 作为子结点展开时，递归判断是否展开以下的其它结点
        private void ShowSelfAndIfShowChildren()
        {
            _bt_node_data_.is_show_self_ = true;
            if (_bt_node_data_.is_show_children_)
                _bt_node_data_.children_.ForEach(i => _tree_.GetNodeByUuid(i).ShowSelfAndIfShowChildren());
        }

        // 隐藏子结点
        public void HideChildren()
        {
            if (!_bt_node_data_.is_show_children_) return;

            _bt_node_data_.is_show_children_ = false;
            _bt_node_data_.children_.ForEach(i => _tree_.GetNodeByUuid(i).HideSelfAndHideChildrenButTag());
        }

        // 作为子结点被隐藏时，递归隐藏其下子结点
        private void HideSelfAndHideChildrenButTag()
        {
            _bt_node_data_.is_show_self_ = is_hovering_ = is_selected_ = is_conn_selected_ = is_conn_hovering_ = false;
            children_.ForEach(i => _tree_.GetNodeByUuid(i).HideSelfAndHideChildrenButTag());
        }

        // 作为子结点（叶结点），被自动调整位置
        private void AdjustPos(Vector2 parentPos, int index, int total)
        {
            // 长宽64 左右间距32 上下间距50 parent坐标为结点左上角
            // x: (parent.x + 64 / 2 - (64 + 24) * total / 2 + 24 / 2)(原点) + ((64 + 24) * index)(偏移)
            // y: parent.y + 64 + 50
            _bt_node_data_.pos_ = new Vector2(parentPos.x - 44 * (total - 1) + 88 * index, parentPos.y + 114);
        }

        public void SetPos(Vector2 pos)
        {
            _bt_node_data_.pos_ = pos;
        }

        public Vector2 GetNewChildPos()
        {
            if (children_.Count == 0)
            {
                return pos_ + new Vector2(0, 114);
            }
            Vector2 newPos = _tree_.GetNodeByUuid(children_[0]).pos_;// + new Vector2(96, 0);\
            Vector2 tmpPos;
            for (int i = 1; i < children_.Count; ++i)
            {
                tmpPos = _tree_.GetNodeByUuid(children_[i]).pos_;
                if (tmpPos.x > newPos.x) newPos.x = tmpPos.x;
                if (tmpPos.y > newPos.y) newPos.y = tmpPos.y;
            }
            return newPos + new Vector2(96, 0);
        }

        // 更新与其下子结点的连线
        public void UpdateChildrenConnRects()
        {
            AIBehaviorTreeNode node;
            foreach (int uuid in children_)
            {
                node = _tree_.GetNodeByUuid(uuid);
                if (_connections_.ContainsKey(node)) _connections_[node].UpdateRects(pos_link_to_children_, node.pos_link_to_parent_, GetBalancePos());
                else _connections_.Add(node, new AIBTNodeConnection(pos_link_to_children_, node.pos_link_to_parent_, GetBalancePos()));
            }
        }

        public List<int> GetAllChildrenList()
        {
            List<int> list = new List<int>();
            foreach (int uuid in children_)
            {
                list.Add(uuid);
                list.AddRange(_tree_.GetNodeByUuid(uuid).GetAllChildrenList());
            }
            return list;
        }
    }
}
