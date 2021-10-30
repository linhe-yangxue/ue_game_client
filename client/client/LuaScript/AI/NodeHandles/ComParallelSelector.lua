local AIConst = require("AI.AIConst")

local ComParallelSelector = DECLARE_MODULE("AI.NodeHandles.ComParallelSelector")

function ComParallelSelector:InitByNodeData(node_data)
    self:InitChildren(node_data)
end

function ComParallelSelector:Start()
    self.no_pass = #self.children
    for i, child in ipairs(self.children) do
        child:Start()
        if self:IsEnd() then break end
    end
    return AIConst.StartReturnIgnore
end

function ComParallelSelector:DoDestroy()
    self:DestroyChildren()
end

function ComParallelSelector:OnChildEnd(status)  -- 并行执行，有一个成功就结束
    if status == AIConst.Status_Success then
        self.ai_tree:PopAllRunningChild(self)
        self:End(status)
    else
        self.no_pass = self.no_pass - 1
        if self.no_pass == 0 then
            self:End(AIConst.Status_Failed)
        end
    end
end

return ComParallelSelector
