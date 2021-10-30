 local AIConst = require("AI.AIConst")

local ConComparison = DECLARE_MODULE("AI.NodeHandles.ConComparison")

function ConComparison:InitByNodeData(node_data)
end

function ConComparison:Start()
    local v1 = ConComparison.GetValueByType(self, self.node_data.value1_type, self.node_data.value1)
    local v2 = ConComparison.GetValueByType(self, self.node_data.value2_type, self.node_data.value2)
    local c_type = self.node_data.compare_type

    local compare_fun = AIConst.CompareFun[c_type]
    if compare_fun(v1, v2) then
        return AIConst.Status_Success
    else
        return AIConst.Status_Failed
    end
end

function ConComparison:GetValueByType(v_type, value)
    if v_type == AIConst.ValueType.VT_Value then
        return value
    elseif v_type == AIConst.ValueType.VT_Variable then
        return self.ai_tree.variables[value]
    end
end

return ConComparison