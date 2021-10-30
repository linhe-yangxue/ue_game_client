local AIConst = require("AI.AIConst")

local DecReturnSuccess = DECLARE_MODULE("AI.NodeHandles.DecReturnSuccess")

function DecReturnSuccess:InitByNodeData(node_data)
    self:InitChildren(node_data)
end

function DecReturnSuccess:Start()
	if not self.children[1] then
        return AIConst.Status_Success
    else
        self.children[1]:Start()
        return AIConst.StartReturnIgnore
    end
end

function DecReturnSuccess:OnChildEnd(status)
    self:End(AIConst.Status_Success)
end

function DecReturnSuccess:DoDestroy()
    self:DestroyChildren()
end

return DecReturnSuccess
