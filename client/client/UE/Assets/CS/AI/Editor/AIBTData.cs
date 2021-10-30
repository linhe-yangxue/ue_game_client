using LT;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace AI
{
    [System.Serializable]
    public class AIBTData : ScriptableObject//行为树的asset数据结构
    {
        public string ai_name_;

        public int root_;

        public List<int> node_uuid_list_;

        public List<AIBehaviorTreeNode.AIBTNodeData> node_list_;

        public bool is_show_comment_;

        public List<AIVarible> variable_list_;

        public AIBTData()
        {
            node_uuid_list_ = new List<int>();
            node_list_ = new List<AIBehaviorTreeNode.AIBTNodeData>();

            variable_list_ = new List<AIVarible>();

            AddNode(AIBTNodeType.Entry, out root_).pos_ = AIConst.ROOT_NODE_DEFAULT_POS;
        }

        public AIBTData Copy(AIBTData copy_aibt_data)
        {
            copy_aibt_data.root_ = root_;
            copy_aibt_data.node_uuid_list_ = new List<int>(node_uuid_list_);
            copy_aibt_data.node_list_ = new List<AIBehaviorTreeNode.AIBTNodeData>();
            foreach (AIBehaviorTreeNode.AIBTNodeData node in node_list_) copy_aibt_data.node_list_.Add(node.Copy());
            copy_aibt_data.is_show_comment_ = is_show_comment_;

            copy_aibt_data.variable_list_ = new List<AIVarible>();
            foreach (AIVarible ai_variable in variable_list_) copy_aibt_data.variable_list_.Add(ai_variable.Copy());

            return copy_aibt_data;
        }

        public AIBehaviorTreeNode.AIBTNodeData AddNode(AIBTNodeType type, out int uuid)
        {
            uuid = 0;
            while (node_uuid_list_.Contains(uuid)) ++uuid;
            AIBehaviorTreeNode.AIBTNodeData nodeData = new AIBehaviorTreeNode.AIBTNodeData(uuid, type, AIConst.GetNodeTypeName(type));
            node_uuid_list_.Add(uuid);
            node_list_.Add(nodeData);
            return nodeData;
        }

        public AIBehaviorTreeNode.AIBTNodeData AddNode(AIBehaviorTreeNode node, out int uuid)
        {
            uuid = 0;
            while (node_uuid_list_.Contains(uuid)) ++uuid;
            AIBehaviorTreeNode.AIBTNodeData nodeData = new AIBehaviorTreeNode.AIBTNodeData(node, uuid);
            node_uuid_list_.Add(uuid);
            node_list_.Add(nodeData);
            return nodeData;
        }

        public void RemoveNode(int uuid)
        {
            if (uuid == root_) return;
            if (!node_uuid_list_.Contains(uuid)) return;
            node_list_.RemoveAt(node_uuid_list_.IndexOf(uuid));
            node_uuid_list_.Remove(uuid);
        }

        public AIBehaviorTreeNode.AIBTNodeData GetNodeDataByUuid(int uuid)
        {
            if (!node_uuid_list_.Contains(uuid)) return null;
            else return node_list_[node_uuid_list_.IndexOf(uuid)];
        }

        public int GetUuidByNodeData(AIBehaviorTreeNode.AIBTNodeData data)
        {
            if (!node_list_.Contains(data)) return -1;
            else return node_uuid_list_[node_list_.IndexOf(data)];
        }

        private int GenIDForTable(AIBehaviorTreeNode.AIBTNodeData cur_node, ref int cur_index, ref Dictionary<int, AIBehaviorTreeNode.AIBTNodeData> id_collect, ref Dictionary<AIBehaviorTreeNode.AIBTNodeData, List<int>> children_id_list)
        {
            int index = cur_index;
            id_collect.Add(index, cur_node);
            ++cur_index;
            children_id_list[cur_node] = new List<int>();
            foreach (int i in cur_node.children_)
            {
                children_id_list[cur_node].Add(GenIDForTable(GetNodeDataByUuid(i), ref cur_index, ref id_collect, ref children_id_list));
            }
            return index;
        }

        public LValue GenLtable(bool is_one_line)
        {
            int curIndex = 0;
            Dictionary<int, AIBehaviorTreeNode.AIBTNodeData> id_collect = new Dictionary<int, AIBehaviorTreeNode.AIBTNodeData>();
            Dictionary<AIBehaviorTreeNode.AIBTNodeData, List<int>> children_id_list = new Dictionary<AIBehaviorTreeNode.AIBTNodeData, List<int>>();
            GenIDForTable(GetNodeDataByUuid(root_), ref curIndex, ref id_collect, ref children_id_list);
            LTable ret = new LTable(false);
            ret["id"] = new LString(ai_name_);
            LTable nodes = new LTable(false);
            foreach (var c in id_collect)
            {
                if (c.Key == 0) continue;
                nodes[c.Key] = c.Value.GenLtable(false, children_id_list[c.Value]);
            }
            ret["nodes"] = nodes;
            LTable variables = new LTable(false);
            foreach (var ai_variable in variable_list_)
            {
                variables[ai_variable.name] = ai_variable.value.gen_ltable(true);
            }
            ret["variables"] = variables;
            return ret;
        }
    }

}
