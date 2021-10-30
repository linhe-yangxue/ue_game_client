local AIConst = require("AI.AIConst")

local ComSelector = DECLARE_MODULE("AI.NodeHandles.ComSelector")

function ComSelector:InitByNodeData(node_data)
    self:InitChildren(node_data)
end

function ComSelector:DoDestroy()
    self:DestroyChildren()
end

function ComSelector:Start()
    if not next(self.children) then
        return AIConst.Status_Failed
    else
        self.cur_idx = 1
        self.children[self.cur_idx]:Start()
        return AIConst.StartReturnIgnore
    end
end

function ComSelector:OnChildEnd(status)  -- 有一个成功就结束
    if status == AIConst.Status_Success then
        self:End(status)
    else
        self.cur_idx = self.cur_idx + 1
        local next_child = self.children[self.cur_idx]
        if not next_child then
            self:End(status)
        else
            next_child:Start()
        end
    end
end

return ComSelector
