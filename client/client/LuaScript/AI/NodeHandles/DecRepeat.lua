local AIConst = require("AI.AIConst")

local DecRepeat = DECLARE_MODULE("AI.NodeHandles.DecRepeat")

function DecRepeat:InitByNodeData(node_data)
    self.is_forever = node_data.is_forever
    self.end_on_failed = node_data.end_on_failed
    self.end_on_success = node_data.end_on_success
    self.cur_count = self.count
    self:InitChildren(node_data)
end

function DecRepeat:Start()
    if not self.children[1] then
        return AIConst.Status_Failed
    else
        self.count = self.ai_tree.variables[self.node_data.count] or self.node_data.count
        self.cur_count = self.count
        if not self.is_forever and self.cur_count <= 0 then
            return AIConst.Status_Failed
        else
            self.cur_count = self.count - 1
            self.children[1]:Start()
            return AIConst.StartReturnIgnore
        end
    end
end

function DecRepeat:DoDestroy()
    self:DestroyChildren()
end

function DecRepeat:OnChildEnd(status)
    if status == AIConst.Status_Failed and self.end_on_failed then
        self:End(AIConst.Status_Failed)
    elseif status == AIConst.Status_Success and self.end_on_success then
        self:End(AIConst.Status_Success)
    elseif not self.is_forever and self.cur_count <= 0 then
        self:End(status)
    else
        self.next_children_start = true
        self:Running()
    end
end

function DecRepeat:Update(delta_time)
    assert(self.next_children_start)
    self.cur_count = self.cur_count - 1
    self.next_children_start = false
    self.status = AIConst.Status_Wait
    self.children[1]:Start()
    return false
end

return DecRepeat