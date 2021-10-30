local AIConst = require("AI.AIConst")

local ComParallel = DECLARE_MODULE("AI.NodeHandles.ComParallel")

function ComParallel:InitByNodeData(node_data)
    self:InitChildren(node_data)
end

function ComParallel:Start()
    self.no_pass = #self.children
    for i, child in ipairs(self.children) do
        child:Start()
        if self:IsEnd() then break end
    end
    return AIConst.StartReturnIgnore
end

function ComParallel:DoDestroy()
    self:DestroyChildren()
end

function ComParallel:OnChildEnd(status)  -- 并行执行，有一个失败就结束
    if status == AIConst.Status_Failed then
        self.ai_tree:PopAllRunningChild(self)
        self:End(status)
    else
        self.no_pass = self.no_pass - 1
        if self.no_pass == 0 then
            self:End(AIConst.Status_Success)
        end
    end
end

return ComParallel