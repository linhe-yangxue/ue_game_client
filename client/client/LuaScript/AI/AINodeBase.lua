local AIConst = require("AI.AIConst")

local AINodeBase = class("AI.AINodeBase")

function AINodeBase:DoInit(ai_tree, parent_node)
    self.ai_tree = ai_tree
    self.parent_node = parent_node
    self.node_type = nil
    self.node_data = nil
    self.status = AIConst.Status_Init
    self.running_result = nil
end

function AINodeBase:InitByNodeData(node_data)
    self.node_data = node_data
    self.node_type = node_data.node_type
    self.type_name = AIConst.NodeType2Name[self.node_type]
    self.type_handle = require("AI.NodeHandles." .. self.type_name)
    self.type_handle.InitByNodeData(self, node_data)
end

function AINodeBase:Start()
    self.status = AIConst.Status_Wait
    local ret = self.type_handle.Start(self)
    if ret == AIConst.Status_Success or ret == AIConst.Status_Failed then
        self:End(ret)
    elseif ret == AIConst.Status_Running then
        self:Running()
    elseif ret == AIConst.StartReturnIgnore then
        -- nothing
    else
        error('unknown start func return')
    end
end

function AINodeBase:DoDestroy()
    if self.type_handle.DoDestroy then
        self.type_handle.DoDestroy(self)
    end
end

function AINodeBase:Update(delta_time)
    if self.running_result then
        self:End(self.running_result)
    elseif self.type_handle.Update then
        return self.type_handle.Update(self, delta_time)
    end
end

function AINodeBase:Running()
    self.status = AIConst.Status_Running
    self.running_result = nil
    self.ai_tree:PushRunningNode(self)
end

function AINodeBase:EndRunning(status)
    if self.status ~= AIConst.Status_Running or self.running_result then
        return
    end
    assert(status == AIConst.Status_Success or status == AIConst.Status_Failed)
    self.running_result = status
end

function AINodeBase:End(status)
    if self:IsEnd() then return end
    self.status = status
    self.running_result = nil
    self.ai_tree:PopRunningNode(self)
    if self.parent_node then
        self.parent_node.type_handle.OnChildEnd(self.parent_node, status)
    else
        self.ai_tree:End(status)
    end
end

function AINodeBase:IsRunning()
    return self.status == AIConst.Status_Running
end

function AINodeBase:IsEnd()
    return self.status == AIConst.Status_Success or self.status == AIConst.Status_Failed
end

function AINodeBase:HasChild(child)
    while child do
        if child == self then return true end
        child = child.parent_node 
    end
end

function AINodeBase:InitChildren(node_data)
    self.children = {}
    for i, idx in ipairs(node_data.children) do
        self.children[i] = AIConst.CreateNode(self.ai_tree.ai_data.nodes[idx], self.ai_tree, self)
    end
end
function AINodeBase:DestroyChildren()
    for _, child in ipairs(self.children) do
        child:DoDestroy()
    end
    self.children = {}
end


return AINodeBase