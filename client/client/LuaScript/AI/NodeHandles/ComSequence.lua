local AIConst = require("AI.AIConst")

local ComSequence = DECLARE_MODULE("AI.NodeHandles.ComSequence")

function ComSequence:InitByNodeData(node_data)
    self:InitChildren(node_data)
end

function ComSequence:Start()
    if not next(self.children) then
        return AIConst.Status_Failed
    else
        self.cur_idx = 1
        self.children[self.cur_idx]:Start()
        return AIConst.StartReturnIgnore
    end
end

function ComSequence:OnChildEnd(status)  -- 有一个失败就结束
    if status == AIConst.Status_Failed then
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

function ComSequence:DoDestroy()
    self:DestroyChildren()
end

return ComSequence