local AIConst = DECLARE_MODULE("AI.AIConst")

AIConst.StartReturnIgnore = -1
AIConst.Status_Init = 0
AIConst.Status_Success = 1
AIConst.Status_Failed = 2
AIConst.Status_Running = 3
AIConst.Status_Wait = 4

AIConst.NodeType = {
    -- Decorator id 1 - 100
    Decorator_Repeat = 1,
    Decorator_Inverter = 2,
    Decorator_ReturnSuccess = 3,
    Decorator_ReturnFail = 4,

    -- Composite id 101 - 200
    Composite_Parallel = 101,
    Composite_ParallelSelector = 102,
    Composite_Sequence = 103,
    Composite_Selector = 104,
    Composite_RandomSelector = 105,
    Composite_RandomSequence = 106,
    Composite_WeightSelector = 107,

    -- Condition id 201 - 300,
    Condition_Comparison = 201,

    -- Action id 301 - 10000
    Action_Wait = 301,
    Action_Log = 302,
    Action_Script = 303,
    Action_RunSubTree = 304,
}

AIConst.NodeType2Name = {
    -- Decorator
    [AIConst.NodeType.Decorator_Repeat] = "DecRepeat",
    [AIConst.NodeType.Decorator_Inverter] = "DecInverter",
    [AIConst.NodeType.Decorator_ReturnSuccess] = "DecReturnSuccess",
    [AIConst.NodeType.Decorator_ReturnFail] = "DecReturnFail",
    -- Composite
    [AIConst.NodeType.Composite_Parallel] = "ComParallel",
    [AIConst.NodeType.Composite_ParallelSelector] = "ComParallelSelector",
    [AIConst.NodeType.Composite_Sequence] = "ComSequence",
    [AIConst.NodeType.Composite_Selector] = "ComSelector",
    [AIConst.NodeType.Composite_RandomSelector] = "ComRandomSelector",
    [AIConst.NodeType.Composite_RandomSequence] = "ComRandomSequence",
    [AIConst.NodeType.Composite_WeightSelector] = "ComWeightSelector",
    -- Condition
    [AIConst.NodeType.Condition_Comparison] = "ConComparison",
    -- Action
    [AIConst.NodeType.Action_Wait] = "ActWait",
    [AIConst.NodeType.Action_Log] = "ActLog",
    [AIConst.NodeType.Action_Script] = "ActScript",
    [AIConst.NodeType.Action_RunSubTree] = "ActRunSubTree",
}

AIConst.ValueType = {
    VT_Value = 1,
    VT_Variable = 2,
}

AIConst.CompareType = {
    CT_Equal = 1,
    CT_Less = 2,
    CT_LessEqual = 3,
    CT_Great = 4,
    CT_GreatEqual = 5,
    CT_NoEqual = 6,
}

AIConst.CompareFun = {
    [AIConst.CompareType.CT_Equal] = function (a, b) return a == b end,
    [AIConst.CompareType.CT_Less] = function (a, b) return a < b end,
    [AIConst.CompareType.CT_LessEqual] = function (a, b) return a <= b end,
    [AIConst.CompareType.CT_Great] = function (a, b) return a > b end,
    [AIConst.CompareType.CT_GreatEqual] = function (a, b) return a >= b end,
    [AIConst.CompareType.CT_NoEqual] = function (a, b) return a~= b end,
}

function AIConst.CreateNode(node_data, ai_tree, parent_node)
    local cls = require("AI.AINodeBase")
    local node = cls.New()
    node:DoInit(ai_tree, parent_node)
    node:InitByNodeData(node_data)
    return node
end

return AIConst