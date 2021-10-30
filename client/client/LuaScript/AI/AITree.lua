local AIConst = require("AI.AIConst")
local AITree = class("AI.AITree")

function AITree:DoInit(unit, parent_tree_node, parent_tb)
    self.owner = unit
    self.parent_tb = parent_tb
    self.root_node = nil
    self.ai_data = nil
    self.target = nil
	self.variables = {}
    self.sub_tree = {}

    self.status = nil
    self.return_status = false

    self.parent_tree = nil
    self.parent_tree_node = parent_tree_node

    -- running的节点列表
    self.running_node_list = {}
    self.updating_node_list = {}
end

function AITree:InitByAIData(ai_data)
    self.ai_data = ai_data
    self.root_node = AIConst.CreateNode(ai_data.nodes[1], self)
    for key, value in pairs(ai_data.variables) do
        if type(value) ~= "table" then
            self.variables[key] = value
        else
            local tmp = {}
            for k, v in pairs(value) do
                tmp[k] = v
            end
            self.variables[key] = tmp
        end
    end
end

function AITree:GetStatus()
    return self.status
end

function AITree:Start()
    if self.root_node then
        self.running_node_list = {}
        self.updating_node_list = {}
        self.root_node:Start()
    end
end

function AITree:IsRunning()
    return next(self.running_node_list) and true or false
end

function AITree:Update(delta_time)
    if self.root_node then
        if next(self.running_node_list) then
            self.updating_node_list, self.running_node_list = self.running_node_list, self.updating_node_list
            while true do
                local node = table.remove(self.updating_node_list, 1)
                if not node then break end
                if node:IsRunning() then
                    if node:Update(delta_time) ~= false and node:IsRunning() then
                        self:PushRunningNode(node)
                    end
                end
            end
        end
    end
    if self.destroy_self then
        self.destroy_self = nil
        ComMgrs.unit_mgr:DestroyUnit(self.owner)
    end
end

function AITree:End(status)
    self.status = status
end

function AITree:PushRunningNode(node)
    for _, _node in ipairs(self.running_node_list) do
        if node == _node then
            error('repeat push running node:' .. node.type_name .. "," .. self.owner.guid)
        end
    end
    table.insert(self.running_node_list, node)
end

function AITree:PopRunningNode(node)
    for i, _node in ipairs(self.running_node_list) do
        if node == _node then
            table.remove(self.running_node_list, i)
            return
        end
    end
end

function AITree:PopAllRunningChild(node)
    for _, list in ipairs {self.running_node_list, self.updating_node_list} do
        local i = 1
        while i <= #list do
            if node:HasChild(list[i]) then 
                table.remove(list, i)
            else
                i = i + 1
            end
        end
    end
end

function AITree:AddSubTree(tree)
    if tree then
        table.insert(self.sub_tree, tree)
        tree.parent_tree = self
    end
end

function AITree:SetDestroySelfFlag()
    self.destroy_self = true
end

function AITree:DoDestroy()
    if self.root_node then
        self.root_node:DoDestroy()
        self.root_node = nil
    end
    self.sub_tree = {}
    self.running_node_list = {}
    self.updating_node_list = {}
end

return AITree
