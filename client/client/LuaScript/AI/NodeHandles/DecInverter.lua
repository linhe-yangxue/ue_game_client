local AIConst = require("AI.AIConst")

local DecInverter = DECLARE_MODULE("AI.NodeHandles.DecInverter")

function DecInverter:InitByNodeData(node_data)
    self:InitChildren(node_data)
end

function DecInverter:Start()
    if not self.children[1] then
        return AIConst.Status_Failed
    else
        self.children[1]:Start()
        return AIConst.StartReturnIgnore
    end
end

function DecInverter:DoDestroy()
    self:DestroyChildren()
end

function DecInverter:OnChildEnd(status)
    if status == AIConst.Status_Failed then
        self:End(AIConst.Status_Success)
    else
        self:End(AIConst.Status_Failed)
    end
end

return DecInverter