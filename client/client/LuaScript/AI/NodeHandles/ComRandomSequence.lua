local AIConst = require("AI.AIConst")

local ComRandomSequence = DECLARE_MODULE("AI.NodeHandles.ComRandomSequence")

function ComRandomSequence:InitByNodeData(node_data)
    self:InitChildren(node_data)
    self.child_num = #self.children
end

function ComRandomSequence:DoDestroy()
    self:DestroyChildren()
end

function ComRandomSequence:GetRandomChild()
    self.cur_idx = self.cur_idx + 1
    if self.cur_idx > self.child_num then return end
    local idx = math.random(self.cur_idx, self.child_num)
    local child = self.r_children[idx]
    self.r_children[idx] = self.r_children[self.cur_idx]
    self.r_children[self.cur_idx] = child
    return child
end

function ComRandomSequence:Start()
    if not next(self.children) then
        return AIConst.Status_Failed
    else
        self.r_children = {}
        for i, child in ipairs(self.children) do
            self.r_children[i] = child
        end
        self.cur_idx = 0
        local child = ComRandomSequence.GetRandomChild(self)
        child:Start()
        return AIConst.StartReturnIgnore
    end
end

function ComRandomSequence:OnChildEnd(status)  -- 不断随机，有一个失败就结束
    if status == AIConst.Status_Failed then
        self:End(status)
    else
        local child = ComRandomSequence.GetRandomChild(self)
        if child then
            child:Start()
        else
            self:End(status)
        end
    end
end

return ComRandomSequence
