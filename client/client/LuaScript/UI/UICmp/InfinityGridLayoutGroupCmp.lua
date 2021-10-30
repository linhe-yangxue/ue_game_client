local UIBase = require("UI.UIBase")
local InfinityGridLayoutGroupCmp = class("UI.UICmp.InfinityGridLayoutGroupCmp", UIBase)

--Example param_tb = {go = , content_go = , min_amount = , amount = , init_item_cb = }

--  滚动列表
-- 默认 开始在最顶端 或最左端 向下 向右延展加长 支持动态添加长度 缩短看需求重写
-- 使用前 先生成自己想要的显示的固定数量的子物体
function InfinityGridLayoutGroupCmp:DoInit(ui, param_tb)
    InfinityGridLayoutGroupCmp.super.DoInit(self)
    self.go = param_tb.go
    self.min_amount = param_tb.min_amount or 2 -- 最少显示多少个
    self.content_go = param_tb.content_go
    self.init_item_cb = param_tb.init_item_cb
    self.amount = param_tb.amount or 1
    self.owner = ui
    self.tag = "InfinityGridLayoutGroupCmp" .. self.go:GetInstanceID()
    local ret = self.owner:IsRegisterUIDestroyEvent(self.tag)
    if ret then
        PrintError("InfinityGridLayoutGroupCmp: tag is register", self.tag)
    end
    self.owner:RegisterUIDestroyEvent(self.tag, self.DoDestroy, self)
    self.scroll_rect = self.go:GetComponent("ScrollRect")
    self.view_rect_transform = self.go:FindChild("Viewport"):GetComponent("RectTransform")
    self.view_rect_transform.pivot = Vector2.New(0, 1)
    self.content_rect_transform = self.content_go:GetComponent("RectTransform")
    self.content_rect_transform.pivot = Vector2.New(0, 1)
    self.content_rect_transform.anchorMin = Vector2.New(0, 1)
    self.content_rect_transform.anchorMax = Vector2.New(0, 1)
    self.content_rect_transform.anchoredPosition = Vector2.New(0, 0)
    self.is_vertical = self.scroll_rect.vertical
    self.grid_layout_group = self.content_go:GetComponent("GridLayoutGroup")
    self.content_size_fitter = self.content_go:GetComponent("ContentSizeFitter")
    self.start_pos = Vector2.New()
    self.grid_layout_size = Vector2.New()
    self.grid_layout_pos = Vector2.New()
    self.real_index = 0
    self.child_trans_to_pos = {}
    self.child_trans_to_index = {}
    self.child_rect_transform_list = {}
end

function InfinityGridLayoutGroupCmp:Reset()
    local rect_transform = self.content_rect_transform
    rect_transform.anchoredPosition = self.grid_layout_pos
    rect_transform.sizeDelta = self.grid_layout_size
end

function InfinityGridLayoutGroupCmp:InitOriginChild()
    local rect_transform = self.content_rect_transform
    self.grid_layout_group.enabled = false
    self.content_size_fitter.enabled = false
    self.grid_layout_pos = rect_transform.anchoredPosition
    self.grid_layout_size = rect_transform.sizeDelta
    self.origin_child_num = rect_transform.childCount

    self:AddScrollValueChanged(self.go, function()
        self:UpdateChildren()
    end)
    self.has_init = true
end

function InfinityGridLayoutGroupCmp:Start(amount)
    if not self.has_init then
        self:InitOriginChild()
    else
        self:Reset()
    end
    self:SetAmount(amount)
    local rect_transform = self.content_rect_transform
    self.child_rect_transform_list = {}
    for index = 1, self.origin_child_num do
        local c_index = index - 1
        local transform = rect_transform:GetChild(c_index)
        transform.gameObject:SetActive(true)
        transform.pivot = Vector2.New(0.5, 0.5)
        table.insert(self.child_rect_transform_list, transform)
        self:UpdateChildrenCallback(index, transform)
    end
    self.start_pos = rect_transform.anchoredPosition
    self.real_index = #self.child_rect_transform_list
    for i = 1, self.origin_child_num do
        self.child_rect_transform_list[i].gameObject:SetActive(i <= self.min_amount)
    end
    if self.is_vertical then
        local row = (self.min_amount - self.amount) / self.grid_layout_group.constraintCount
        if row > 0 then
            rect_transform.sizeDelta = rect_transform.sizeDelta - Vector2.New(0, (self.grid_layout_group.cellSize.y + self.grid_layout_group.spacing.y) * row)
        end
    else
        local column = (self.min_amount - self.amount) / self.grid_layout_group.constraintCount
        if column > 0 then
            rect_transform.sizeDelta = rect_transform.sizeDelta - Vector2.New((self.grid_layout_group.cellSize.x + self.grid_layout_group.spacing.x) * column, 0)
        end
    end
end

function InfinityGridLayoutGroupCmp:UpdateChildren()
    local view_rect_transform = self.view_rect_transform
    local rect_transform = self.content_rect_transform
    if rect_transform.childCount < self.min_amount then
        PrintError("rect_transform.childCount >= self.min_amount")
        return
    end
    local current_pos = rect_transform.anchoredPosition
    local child_rect_transform_list = self.child_rect_transform_list
    local child_num = #self.child_rect_transform_list
    if self.is_vertical then
        local offset_y = current_pos.y - self.start_pos.y
        if offset_y > 0 then
            -- 向下滑
            if self.real_index >= self.amount then
                self.start_pos = current_pos
                return
            end
            local scroll_rect_up = view_rect_transform:TransformPoint(Vector3.zero).y
            local first_child_pos = child_rect_transform_list[1].anchoredPosition
            local child_bottom_left = Vector3.New(first_child_pos.x - self.grid_layout_group.cellSize.x / 2, first_child_pos.y - self.grid_layout_group.cellSize.y / 2, 0)
            local child_bottom = rect_transform:TransformPoint(child_bottom_left).y
            if child_bottom > scroll_rect_up then
                --移动到底部
                for index = 1 , self.grid_layout_group.constraintCount do
                    local change_trans = self.child_rect_transform_list[index]
                    local bottom_trans = self.child_rect_transform_list[child_num]
                    change_trans:SetAsLastSibling()
                    local pos = Vector2.New(change_trans.anchoredPosition.x, bottom_trans.anchoredPosition.y - self.grid_layout_group.cellSize.y - self.grid_layout_group.spacing.y)
                    change_trans.anchoredPosition = pos
                    self.real_index = self.real_index + 1
                    if self.real_index > self.amount then
                        change_trans.gameObject:SetActive(false)
                    else
                        self:UpdateChildrenCallback(self.real_index, change_trans)
                    end
                end
                --GridLayoutGroup 底部加长
                rect_transform.sizeDelta = rect_transform.sizeDelta + Vector2.New(0, self.grid_layout_group.cellSize.y + self.grid_layout_group.spacing.y)
                --更新child
                self:_ResetChildren()
            end
        elseif offset_y < 0 then
            -- 向上滑
            local last_child_trans = self.child_rect_transform_list[child_num]
            if self.real_index <= child_num then
                self.start_pos = current_pos
                return
            end
            local scroll_rect_anchor_bottom = Vector3.New(0, -view_rect_transform.rect.height - self.grid_layout_group.spacing.y, 0)
            local scroll_rect_bottom = view_rect_transform:TransformPoint(scroll_rect_anchor_bottom).y
            local child_up_left = Vector3.New(last_child_trans.anchoredPosition.x - self.grid_layout_group.cellSize.x / 2, last_child_trans.anchoredPosition.y + self.grid_layout_group.cellSize.y / 2, 0)
            local child_up = rect_transform:TransformPoint(child_up_left).y
            if child_up < scroll_rect_bottom then
                --把底部的一行 移动到顶部
                for index = 1, self.grid_layout_group.constraintCount do
                    local change_trans = self.child_rect_transform_list[child_num - index + 1]
                    local top_trans = self.child_rect_transform_list[1]
                    change_trans:SetAsFirstSibling()
                    local pos = Vector2.New(change_trans.anchoredPosition.x, top_trans.anchoredPosition.y + self.grid_layout_group.cellSize.y + self.grid_layout_group.spacing.y)
                    self.real_index = self.real_index - 1
                    change_trans.anchoredPosition = pos
                    change_trans.gameObject:SetActive(true)
                    self:UpdateChildrenCallback(self.real_index - child_num + index, change_trans)
                end
                --GridLayoutGroup 底部缩短
                rect_transform.sizeDelta = rect_transform.sizeDelta - Vector2.New(0, self.grid_layout_group.cellSize.y + self.grid_layout_group.spacing.y)
                --更新child
                self:_ResetChildren()
            end
        end
    else -- 左右
        local offsetX = current_pos.x - self.start_pos.x
        if offsetX < 0 then
            --向左拉，向右扩展
            if self.real_index >= self.amount then
                self.start_pos = current_pos
                return
            end
            local scroll_rect_left = view_rect_transform:TransformPoint(Vector3.zero).x
            local child_bottom_right = Vector3.New(self.child_rect_transform_list[1].anchoredPosition.x - self.grid_layout_group.cellSize.x / 2 + self.grid_layout_group.cellSize.x, self.child_rect_transform_list[1].anchoredPosition.y - self.grid_layout_group.cellSize.y /2, 0)
            local child_right = transform:TransformPoint(child_bottom_right).x
            if child_right < scroll_rect_left then
                --移动到右边
                for index = 1, self.grid_layout_group.constraintCount do
                    local change_trans = self.child_rect_transform_list[index]
                    local right_last_trans = self.child_rect_transform_list[child_num]
                    change_trans:SetAsLastSibling()
                    local pos = Vector2.New(right_last_trans.anchoredPosition.x + self.grid_layout_group.cellSize.x + self.grid_layout_group.spacing.x, change_trans.anchoredPosition.y)
                    change_trans.anchoredPosition = pos
                    self.real_index = self.real_index + 1
                    if self.real_index > self.amount then
                        change_trans.gameObject:SetActive(false)
                    else
                        self:UpdateChildrenCallback(self.real_index, change_trans)
                    end
                end
                --GridLayoutGroup 右侧加长
                rect_transform.sizeDelta = rect_transform.sizeDelta + Vector2.New(self.grid_layout_group.cellSize.x + self.grid_layout_group.spacing.x, 0)
                --更新child
                self:_ResetChildren()
            end
        else
            --向右拉，右边收缩
            if self.real_index <= child_num then
                self.start_pos = current_pos
                return
            end
            local scroll_rect_anchor_right = Vector3.New(view_rect_transform.rect.width + self.grid_layout_group.spacing.x, 0, 0)
            local scroll_rect_right = view_rect_transform:TransformPoint(scroll_rect_anchor_right).x
            local child_up_left = Vector3.New(self.child_rect_transform_list[child_num].anchoredPosition.x - self.grid_layout_group.cellSize.x / 2, self.child_rect_transform_list[child_num].anchoredPosition.y + self.grid_layout_group.cellSize.y / 2, 0)
            local child_left = transform:TransformPoint(child_up_left).x
            if child_left > scroll_rect_right then
                --把右边的一行 移动到左边
                for index = 1, self.grid_layout_group.constraintCount do
                    local change_trans = self.child_rect_transform_list[child_num - index + 1]
                    local first_trans = self.child_rect_transform_list[1]
                    change_trans:SetAsFirstSibling()
                    change_trans.anchoredPosition = Vector2.New(first_trans.anchoredPosition.x - self.grid_layout_group.cellSize.x - self.grid_layout_group.spacing.x, change_trans.anchoredPosition.y)
                    change_trans.gameObject:SetActive(true)
                    self.real_index = self.real_index - 1
                    self:UpdateChildrenCallback(self.real_index - child_num + index, change_trans)
                end
                --GridLayoutGroup 右侧缩短
                rect_transform.sizeDelta = rect_transform.sizeDelta - Vector2.New(self.grid_layout_group.cellSize.x + self.grid_layout_group.spacing.x, 0)
                --更新child
                self:_ResetChildren()
            end
        end
    end
    self.start_pos = current_pos
end

function InfinityGridLayoutGroupCmp:UpdateChildrenCallback(index, trans)
    -- 发送事件
    if self.init_item_cb then
        self.init_item_cb(index, trans)
    end
end

function InfinityGridLayoutGroupCmp:_ResetChildren()
    self.child_rect_transform_list = self:GetCurChildRectTransList()
end

function InfinityGridLayoutGroupCmp:GetCurChildRectTransList()
    local ret = {}
    for index = 1 , self.origin_child_num do
        local c_index = index - 1
        ret[index] = self.content_rect_transform:GetChild(c_index):GetComponent("RectTransform")
    end
    return ret
end

function InfinityGridLayoutGroupCmp:SetAmount(amount, is_new_item_on_top)
    if self.amount and self.amount >= amount then return end -- 暂时不需要动态缩短长度
    if self.amount and is_new_item_on_top then -- 添加长度
        self.real_index = self.real_index + amount - self.amount
    end
    self.amount = amount
end

function InfinityGridLayoutGroupCmp:DoDestroy()
    self.owner:UnregisterUIDestroyEvent(self.tag)
    InfinityGridLayoutGroupCmp.super.DoDestroy(self)
end

return InfinityGridLayoutGroupCmp