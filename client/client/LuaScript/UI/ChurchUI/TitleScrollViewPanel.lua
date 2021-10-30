local TitleGrid = require("UI.ChurchUI.TitleGrid")

local TitleScrollViewPanel = class("UI.ChurchUI.TitleScrollViewPanel")

function TitleScrollViewPanel:InitRes(go, root_ui, parent_ui)
    self.go = go
    self.root_ui = root_ui
    self.parent_ui = parent_ui
    self.rectTransform = go:GetComponent("RectTransform")
    self.title_group = go:FindChild("Viewport/TitleGroup")
    self.title_group_rectTransform = self.title_group:GetComponent("RectTransform")
    self.title_group_layoutGroup = self.title_group:GetComponent("HorizontalLayoutGroup")
    self.grid_template = go:FindChild("Viewport/TitleGroup/GridTemplate")
end

function TitleScrollViewPanel:_InitTitleGridList()
    local title_id_list = ComMgrs.dy_data_mgr.church_data:GetAllTitleId()
    self.title_grid_list = {}
    for index, title_id in ipairs(title_id_list) do
        local grid_go = self.root_ui:GetUIObject(self.grid_template, self.title_group)
        local new_title_grid = TitleGrid.New()
        new_title_grid:InitRes(grid_go, self.root_ui, self, title_id, index)
        self.title_grid_list[index] = new_title_grid
    end
    self.titles_count = #self.title_grid_list
    self.half_width_of_panel = 0.5 * self.rectTransform.sizeDelta.x
    self.padding_left = self.title_group_layoutGroup.padding.left
    self.half_width_of_grid_biggerSize = 0.5 * self.title_grid_list[1].bigger_size.x
    self.grid_width_add_spacing = self.title_grid_list[1].original_size.x + self.title_group_layoutGroup.spacing
end

function TitleScrollViewPanel:Init(index)
    if not self.is_grid_list_ok then
        self:_InitTitleGridList()
        self.is_grid_list_ok = true
    end
    local new_index = index or math.ceil(self.titles_count / 2)
    if self.current_index and new_index ~= self.current_index then
        self.title_grid_list[self.current_index]:Select(false)
    end
    self.title_grid_list[new_index]:Select(true)
end

function TitleScrollViewPanel:Switch(value)
    local new_index = self.current_index + value
    if new_index > self.titles_count or new_index < 1 then
        return false
    end
    self.title_grid_list[self.current_index]:Select(false)
    self.title_grid_list[new_index]:Select(true)
    new_index = new_index + value
    if new_index > self.titles_count or new_index < 1 then
        return false
    else
        return true
    end
end

function TitleScrollViewPanel:OnGridSelected(grid)
    local direction = (self.current_index or 0) - grid.index
    self.current_index = grid.index
    self:MoveGridOnSelectedToCenter()
    self.parent_ui:ShowTitleInfo(self.current_index, grid.title_id, direction)
    if self.parent_ui.UpdateLeftRightBtn then
        self.parent_ui:UpdateLeftRightBtn(self.current_index ~= 1, self.current_index ~= self.titles_count)
    end
end

function TitleScrollViewPanel:MoveGridOnSelectedToCenter()
    self:ResetAnimation()
    self.title_group_layoutGroup:SetLayoutHorizontal()
    self.title_group_layoutGroup:SetLayoutVertical()
    local grid_pos_x = self.padding_left + (self.current_index - 1) * self.grid_width_add_spacing
    local start_pos = self.title_group_rectTransform.anchoredPosition
    local displacement = (self.half_width_of_panel - grid_pos_x - self.half_width_of_grid_biggerSize) - start_pos.x
    self.ticker = self.root_ui:AddTicker(0.2, function(delta)
        if IsNil(self.go) then
            return false
        end
        local new_position = Vector2.New(start_pos.x + delta * displacement, start_pos.y)
        self.title_group_rectTransform.anchoredPosition = new_position
        return true
    end)
end

function TitleScrollViewPanel:ResetAnimation()
    if self.ticker then
        self.root_ui:RemoveTicker(self.ticker)
        self.ticker = nil
    end
end

return TitleScrollViewPanel