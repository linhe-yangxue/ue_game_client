local AIConst = require("AI.AIConst")

local DecReturnFail = DECLARE_MODULE("AI.NodeHandles.DecReturnFail")

function DecReturnFail:InitByNodeData(node_data)
    self:InitChildren(node_data)
end

function DecReturnFail:Start()
	if not self.children[1] then
		return AIConst.Status_Failed
	else
        self.children[1]:Start()
        return AIConst.StartReturnIgnore
    end
end

function DecReturnFail:OnChildEnd(status)
    self:End(AIConst.Status_Failed)
end

function DecReturnFail:DoDestroy()
    self:DestroyChildren()
end

return DecReturnFail
