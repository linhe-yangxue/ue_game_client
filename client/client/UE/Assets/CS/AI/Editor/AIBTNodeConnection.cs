using System;
using System.Collections.Generic;
using UnityEngine;

namespace AI
{
    [System.Serializable]
    public class AIBTNodeConnection
    {
        public Vector2[] balance_rect_;

        public Vector2[] parent_link_rect_;

        public Vector2[] child_link_rect_;

        public AIBTNodeConnection(Vector2 parent_link_pos, Vector2 child_link_pos, float balance_pos)
        {
            balance_rect_ = new Vector2[2];
            parent_link_rect_ = new Vector2[2];
            child_link_rect_ = new Vector2[2];
            UpdateRects(parent_link_pos, child_link_pos, balance_pos);
        }

        public void UpdateRects(Vector2 parent_link_pos, Vector2 child_link_pos, float balance_pos)
        {
            balance_rect_[0].Set(Math.Min(parent_link_pos.x, child_link_pos.x), balance_pos);
            balance_rect_[1].Set(Math.Abs(parent_link_pos.x - child_link_pos.x) + 2, 2);

            parent_link_rect_[0].Set(parent_link_pos.x, parent_link_pos.y);
            parent_link_rect_[1].Set(2, Math.Abs(parent_link_pos.y - balance_pos));

            child_link_rect_[0].Set(child_link_pos.x, Math.Min(child_link_pos.y, balance_pos));
            child_link_rect_[1].Set(2, Math.Abs(child_link_pos.y - balance_pos));
        }

        public List<Rect> GetShowRects(Vector2 offset, float zoom)
        {
            List<Rect> list = new List<Rect>();
            if (balance_rect_[1].x != 0) list.Add(new Rect((balance_rect_[0] + offset) * zoom, balance_rect_[1] * zoom));
            if (parent_link_rect_[1].y != 0) list.Add(new Rect((parent_link_rect_[0] + offset) * zoom, parent_link_rect_[1] * zoom));
            if (child_link_rect_[1].y != 0) list.Add(new Rect((child_link_rect_[0] + offset) * zoom, child_link_rect_[1] * zoom));
            return list;
        }

        public List<Rect> GetCheckRects()
        {
            List<Rect> list = new List<Rect>();
            if (balance_rect_[1].x != 0) list.Add(new Rect(balance_rect_[0] + new Vector2(0, -2), balance_rect_[1] + new Vector2(0, 4)));
            if (parent_link_rect_[1].y != 0) list.Add(new Rect(parent_link_rect_[0] + new Vector2(-2, 0), parent_link_rect_[1] + new Vector2(4, 0)));
            if (child_link_rect_[1].y != 0) list.Add(new Rect(child_link_rect_[0] + new Vector2(-2, 0), child_link_rect_[1] + new Vector2(4, 0)));
            return list;
        }
    }

    [System.Serializable]
    public class AIBTNodeConnectionCollect
    {
        public List<AIBehaviorTreeNode> node_list_;

        public List<AIBTNodeConnection> conn_list_;

        public AIBTNodeConnectionCollect()
        {
            node_list_ = new List<AIBehaviorTreeNode>();
            conn_list_ = new List<AIBTNodeConnection>();
        }

        public Dictionary<AIBehaviorTreeNode, AIBTNodeConnection>.Enumerator GetEnumerator()
        {
            Dictionary<AIBehaviorTreeNode, AIBTNodeConnection> dict = new Dictionary<AIBehaviorTreeNode, AIBTNodeConnection>();
            for (int i = 0; i < node_list_.Count; ++i)
            {
                dict.Add(node_list_[i], conn_list_[i]);
            }
            return dict.GetEnumerator();
        }

        public void Add(AIBehaviorTreeNode node, AIBTNodeConnection conn)
        {
            node_list_.Add(node);
            conn_list_.Add(conn);
        }

        public void Remove(AIBehaviorTreeNode node)
        {
            if (!node_list_.Contains(node)) return;
            conn_list_.RemoveAt(node_list_.IndexOf(node));
            node_list_.Remove(node);
        }

        public bool ContainsKey(AIBehaviorTreeNode node)
        {
            return node_list_.Contains(node);
        }

        public AIBTNodeConnection this[AIBehaviorTreeNode node]
        {
            get
            {
                if (!node_list_.Contains(node)) return null;
                return conn_list_[node_list_.IndexOf(node)];
            }
        }
    }
}
