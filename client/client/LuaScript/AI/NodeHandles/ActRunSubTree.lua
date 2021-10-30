local AIConst = require("AI.AIConst")
local AITree = require("AI.AITree")

local ActRunSubTree = DECLARE_MODULE("AI.NodeHandles.ActRunSubTree")

function ActRunSubTree:InitByNodeData(node_data)
    if self.ai_tree.variables[node_data.table_name] then
        PrintError("ActRunSubTree: table found:", node_data.table_name)
    end
    self.ai_tree.variables[node_data.table_name] = {}
    if node_data.ai_name and node_data.ai_name ~= "" then
        local ai_data = SpecMgrs.data_mgr:GetAIData(node_data.ai_name)
        if not ai_data then
            PrintError("ActRunSubTree: ai not found:", node_data.ai_name)
            return
        end
        self.sub_tree = AITree.New()
        self.sub_tree:DoInit(self.ai_tree.owner, self, self.ai_tree.variables[node_data.table_name])
        self.sub_tree:InitByAIData(ai_data)
        self.ai_tree:AddSubTree(self.sub_tree)
    else
        PrintError("ActRunSubTree: ai name is empty")
    end
end

function ActRunSubTree:Start()
    if self.sub_tree then
        self.sub_tree:Start()
        if not self.sub_tree:IsRunning() then
            return self.sub_tree:GetStatus()
        else
            return AIConst.Status_Running
        end
    else
        return AIConst.Status_Failed
    end
end

function ActRunSubTree:Update(delta_time)
    if self.sub_tree then
        self.sub_tree:Update(delta_time)
        if not self.sub_tree:IsRunning() then
            self:End(self.sub_tree:GetStatus())
        end
    else
        self:End(AIConst.Status_Failed)
    end
end

function ActRunSubTree:DoDestroy()
    if self.sub_tree then
        self.sub_tree:DoDestroy()
    end
end

return ActRunSubTree
