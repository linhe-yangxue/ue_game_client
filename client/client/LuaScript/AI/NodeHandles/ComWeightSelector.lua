local AIConst = require("AI.AIConst")

local ComWeightSelector = DECLARE_MODULE("AI.NodeHandles.ComWeightSelector")

function ComWeightSelector:InitByNodeData(node_data)
    self:InitChildren(node_data)
    self.child_num = #self.children
end

function ComWeightSelector:DoDestroy()
    self:DestroyChildren()
end

local function swap(tb, i, j)
    tb[i], tb[j] = tb[j], tb[i]
end

function ComWeightSelector:GetRandomChild()
    self.cur_idx = self.cur_idx + 1
    if self.cur_idx > self.child_num then return end

    local total_weight = 0
    for i=self.cur_idx, self.child_num do
        total_weight = total_weight + self.select_weight[i]
    end
    local wt = math.random() * total_weight
    local idx = self.cur_idx
    while idx < self.child_num do
        wt = wt - self.select_weight[idx]
        if wt <= 0 then
            break
        end
        idx = idx + 1
    end
    swap(self.r_children, idx, self.cur_idx)
    swap(self.select_weight, idx, self.cur_idx)
    return self.r_children[self.cur_idx]
end

function ComWeightSelector:Start()  -- 
    if not next(self.children) then
        return AIConst.Status_Failed
    else
        self.r_children = {}
        for i, child in ipairs(self.children) do
            self.r_children[i] = child
        end
        self.select_weight = {}
        for i, wt in ipairs(self.node_data.weights) do
            self.select_weight[i] = self.ai_tree.variables[wt] or wt
        end
        self.cur_idx = 0
        local child = ComWeightSelector.GetRandomChild(self)
        child:Start()
        return AIConst.StartReturnIgnore
    end
end

function ComWeightSelector:OnChildEnd(status)  -- 根据权重，有一个成功就结束
    if status == AIConst.Status_Success then
        self:End(status)
    else
        local child = ComWeightSelector.GetRandomChild(self)
        if child then
            child:Start()
        else
            self:End(status)
        end
    end
end

return ComWeightSelector