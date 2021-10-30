using System.Collections.Generic;
using UnityEngine;
using PI;

namespace AI
{
    public enum AIBTNodeType
    {
        Entry = 0,

        // Decorator id 1 - 100
        Decorator_Repeat = 1,
        Decorator_Inverter = 2,
        Decorator_ReturnSuccess = 3,
        Decorator_ReturnFail = 4,

        // Composite id 101 - 200
        Composite_Parallel = 101,
        Composite_ParallelSelector = 102,
        Composite_Sequence = 103,
        Composite_Selector = 104,
        Composite_RandomSelector = 105,
        Composite_RandomSequence = 106,
        Composite_WeightSelector = 107,

        // Condition id 201 - 300,
        Condition_Comparison = 201,

        // Action id 301 - 10000
        Action_Wait = 301,
        Action_Log = 302,
        Action_Script = 303,
        Action_RunSubTree = 304,
    }

    public enum AIBTNodeCategory
    {
        Entry,
        Decorator,
        Composite,
        Condition,
        Action,
        Unknown,
    }

    public enum ValueType
    {
        VT_Value = 1,
        VT_Variable = 2,
    }

    public enum CompareType
    {
        CT_Equal = 1,
        CT_Less = 2,
        CT_LessEqual = 3,
        CT_Great = 4,
        CT_GreatEqual = 5,
        CT_NoEqual = 6,
    }

    public class AIConst
    {
        public static readonly string SAVE_AI_TREE_RECORD = "Assets/EditorData/AI/LogicData/";
        public static readonly string NODE_TEXTURE_PATH = "Assets/CS/AI/Editor/AIBTNode.png";
        public static readonly string NODE_LIGHT_TEXTURE_PATH = "Assets/CS/AI/Editor/AIBTNodeHighLight.png";
        public static readonly string NODE_SELECT_TEXTURE_PATH = "Assets/CS/AI/Editor/AIBTNodeSelected.png";
        public static readonly Vector2 ROOT_NODE_DEFAULT_POS = new Vector2(-32, -332);
        public static readonly Vector2 NODE_DEFAULT_POS = new Vector2(332, -332);
        public static readonly Vector2 NODE_SIZE = new Vector2(64, 64);
        public static readonly Vector2 SHOW_NAME_AREA_SIZE = new Vector2(46, 25);
        public static readonly Vector2 SHOW_CHILDREN_AREA_SIZE = new Vector2(36, 16);

        public static string LOGICDATA_PATH { get { return Application.dataPath + "/EditorData/AI/LogicData/"; } }
        public static string EXPORT_PATH { get { return Application.dataPath + "/../../LuaScript/Data/AI/"; } }

        public static int OPERATE_TYPE_PASTE = 0;
        public static int OPERATE_TYPE_UPDATE_DATA = 1;

        public static readonly Dictionary<int, string> kNodeStatus2StatusName = new Dictionary<int, string>() {
            { 0, "Init" },
            { 1, "Success" },
            { 2, "Failure" },
            { 3, "Running" },
            { 4, "Wait"},
        };

        public static string GetNodeStatusName(int status)
        {
            if (!kNodeStatus2StatusName.ContainsKey(status)) return "";
            else return kNodeStatus2StatusName[status];
        }

        public static readonly Dictionary<AIBTNodeType, string> kNodeType2TypeName = new Dictionary<AIBTNodeType, string>() {
            { AIBTNodeType.Entry,                       "Entry" },

            { AIBTNodeType.Decorator_Repeat,            "Repeat" },
            { AIBTNodeType.Decorator_Inverter,          "Inverter" },
            { AIBTNodeType.Decorator_ReturnSuccess,     "ReturnSuccess" },
            { AIBTNodeType.Decorator_ReturnFail,        "ReturnFail" },

            { AIBTNodeType.Composite_Parallel,          "Parallel" },
            { AIBTNodeType.Composite_ParallelSelector,  "ParallelSelector" },
            { AIBTNodeType.Composite_Sequence,          "Sequence" },
            { AIBTNodeType.Composite_Selector,          "Selector" },
            { AIBTNodeType.Composite_RandomSelector,    "RandomSelector" },
            { AIBTNodeType.Composite_RandomSequence,    "RandomSequence" },
            { AIBTNodeType.Composite_WeightSelector,    "WeightSelector" },

            { AIBTNodeType.Condition_Comparison,        "Comparison"},

            { AIBTNodeType.Action_Wait,                 "Wait"},
            { AIBTNodeType.Action_Log,                  "Log" },
            { AIBTNodeType.Action_Script,               "Script"},
            { AIBTNodeType.Action_RunSubTree,           "RunSubTree" },
        };

        public static readonly Dictionary<string, string> TypeName2ShowName = new Dictionary<string, string>{
            {"Entry",                                   "根节点" },

            {"Repeat",                                  "重复" },
            {"Inverter",                                "取反" },
            {"ReturnSuccess",                           "返回成功" },
            {"ReturnFail",                              "返回失败" },

            {"Parallel",                                "并行" },
            {"ParallelSelector",                        "并行选择" },
            {"Sequence",                                "顺序执行" },
            {"Selector",                                "选择执行" },
            {"RandomSelector",                          "随机选择" },
            {"RandomSequence",                          "随机顺序" },
            {"WeightSelector",                          "加权选择" },

            {"Comparison",                              "比较" },

            {"Wait",                                    "等待" },
            {"Log",                                     "打印" },
            {"Script",                                  "脚本" },
            {"RunSubTree",                              "运行子树"},
        };

        public static string GetNodeTypeName(AIBTNodeType type)
        {
            if (!kNodeType2TypeName.ContainsKey(type)) return "";
            else return kNodeType2TypeName[type];
        }

        public static AIBTNodeCategory GetCategory(AIBTNodeType type)
        {
            int t = (int)type;
            if (t == 0)
            {
                return AIBTNodeCategory.Entry;
            }
            else if (t > 0 && t < 101)
            {
                return AIBTNodeCategory.Decorator;
            }
            else if (t > 100 && t < 201)
            {
                return AIBTNodeCategory.Composite;
            }
            else if (t > 200 && t < 301)
            {
                return AIBTNodeCategory.Condition;
            }
            else if (t > 300 && t < 10001)
            {
                return AIBTNodeCategory.Action;
            }
            else
            {
                return AIBTNodeCategory.Unknown;
            }
        }

        public static readonly Dictionary<string, AIBTNodeType[]> kCategorys = new Dictionary<string, AIBTNodeType[]>() {
            { "Decorator", new AIBTNodeType[] {
                AIBTNodeType.Decorator_Repeat,
                AIBTNodeType.Decorator_Inverter,
                AIBTNodeType.Decorator_ReturnSuccess,
                AIBTNodeType.Decorator_ReturnFail,
            } },

            { "Composite", new AIBTNodeType[] {
                AIBTNodeType.Composite_Parallel,
                AIBTNodeType.Composite_ParallelSelector,
                AIBTNodeType.Composite_Sequence,
                AIBTNodeType.Composite_Selector,
                AIBTNodeType.Composite_RandomSequence,
                AIBTNodeType.Composite_RandomSelector,
                AIBTNodeType.Composite_WeightSelector,
            } },


            { "Condition", new AIBTNodeType[] {
                AIBTNodeType.Condition_Comparison,
            } },

            { "Action", new AIBTNodeType[] {
                AIBTNodeType.Action_Log,
                AIBTNodeType.Action_Wait,
                AIBTNodeType.Action_Script,
                AIBTNodeType.Action_RunSubTree,
            } },
        };

        public static readonly Dictionary<string, string> Categorys2ShowCategorysName = new Dictionary<string, string>{
            { "Decorator", "修饰节点"},
            { "Composite", "复合节点"},
            { "Condition", "条件节点"},
            { "Action",    "动作节点"},
        };

        public static readonly Dictionary<string, ParamItem[]> kType2Param = new Dictionary<string, ParamItem[]>() {

            // Decorator
            { "Repeat", new ParamItem[] {
                new ParamItem("count", "shared_int"),
                new ParamItem("is_forever", "bool"),
                new ParamItem("end_on_failed", "bool"),
                new ParamItem("end_on_success", "bool"),
            } },
            { "Inverter", new ParamItem[] { } },
            { "ReturnSuccess", new ParamItem[] { } },
            { "ReturnFail", new ParamItem[] { } },

            // Composite
            { "Parallel", new ParamItem[] { } },
            { "ParallelSelector", new ParamItem[] { } },
            { "Sequence", new ParamItem[] { } },
            { "Selector", new ParamItem[] { } },
            { "RandomSelector", new ParamItem[] { } },
            { "RandomSequence", new ParamItem[] { } },
            { "WeightSelector", new ParamItem[] { new ParamItem("weights", "Weights"), } },

            // Condition
            { "Comparison", new ParamItem[] { new ParamItem("comparator", "Comparator"), } },

            // Action
            { "Wait", new ParamItem[] {
                new ParamItem("wait_time", "shared_float"),
                new ParamItem("is_combat", "bool"),
            } },
            { "Log", new ParamItem[] { new ParamItem("text", "multiline_string") } },
            { "Script", new ParamItem[] { new ParamItem("script", "multiline_string") } },
            { "RunSubTree", new ParamItem[] {
                new ParamItem("ai_name", "string"),
                new ParamItem("table_name", "string"),
            } },
        };

        public static readonly Dictionary<string, ParamData> kDefaultParamValue = new Dictionary<string, ParamData>()
        {
            { "end_on_failed", new ParamData("end_on_failed", true) },
            { "text", new ParamData("text", "") },
        };

        public static readonly List<string> kVariableTypeName = new List<string>() { "string", "int", "float", "bool", "Vector2", "Vector3" };

        public static readonly string[] kCompareTypeName = new string[] { "等于", "小于", "小于等于", "大于", "大于等于", "不等于" };
    }
}
