local AIConst = require("AI.AIConst")

local ActWait = DECLARE_MODULE("AI.NodeHandles.ActWait")

function ActWait:InitByNodeData(node_data)

end

function ActWait:Start()
    self.cur_time = self.ai_tree.variables[self.node_data.wait_time] or tonumber(self.node_data.wait_time)
    if not self.cur_time then
        PrintError("ActWait: wait_time is nil")
        self.cur_time = 0
        return AIConst.Status_Failed
    else
        return AIConst.Status_Running
    end
end

function ActWait:DoDestroy()
end

function ActWait:Update(delta_time)
    self.cur_time = self.cur_time - delta_time
    if self.cur_time <= 0 then
        self:EndRunning(AIConst.Status_Success)
    end
end

return ActWait