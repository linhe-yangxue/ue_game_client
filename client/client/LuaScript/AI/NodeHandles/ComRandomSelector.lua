local AIConst = require("AI.AIConst")

local ComRandomSelector = DECLARE_MODULE("AI.NodeHandles.ComRandomSelector")

function ComRandomSelector:InitByNodeData(node_data)
    self:InitChildren(node_data)
    self.child_num = #self.children
end

function ComRandomSelector:DoDestroy()
    self:DestroyChildren()
end

function ComRandomSelector:GetRandomChild()
    self.cur_idx = self.cur_idx + 1
    if self.cur_idx > self.child_num then return end
    local idx = math.random(self.cur_idx, self.child_num)
    local child = self.r_children[idx]
    self.r_children[idx] = self.r_children[self.cur_idx]
    self.r_children[self.cur_idx] = child
    return child
end

function ComRandomSelector:Start()
    if not next(self.children) then
        return AIConst.Status_Failed
    else
        self.r_children = {}
        for i, child in ipairs(self.children) do
            self.r_children[i] = child
        end
        self.cur_idx = 0
        local child = ComRandomSelector.GetRandomChild(self)
        child:Start()
        return AIConst.StartReturnIgnore
    end
end

function ComRandomSelector:OnChildEnd(status)  -- 不断随机，有一个成功就结束
    if status == AIConst.Status_Success then
        self:End(status)
    else
        local child = ComRandomSelector.GetRandomChild(self)
        if child then
            child:Start()
        else
            self:End(status)
        end
    end
end

return ComRandomSelector
