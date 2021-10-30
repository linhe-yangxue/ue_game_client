local AIConst = require("AI.AIConst")
local AIExFuncs = require("ExFuncs.AIExFuncs")

local ActLog = DECLARE_MODULE("AI.NodeHandles.ActLog")

function ActLog:InitByNodeData(node_data)
end

function ActLog:Start()
    AIExFuncs.PrintLog(self.node_data.text)
    return AIConst.Status_Success
end

return ActLog