local UIListSelector = class("UI.UIListSelector")

-- 通用选择列表
function UIListSelector:DoInit(ui, obj_list, select_func)
    self.ui = ui
    self.select_func = select_func
    self.obj_list = obj_list
    self.cur_select_index = nil
    self.cur_select_obj = nil
    for i, obj in ipairs(obj_list) do
        self:AddObj(obj, i)
    end
end

function UIListSelector:AddObj(obj, index)
    self:_SetSelectImageActive(obj, false)
    self.ui:AddClick(obj, function()
        self:_SelectObj(index)
    end)
end

function UIListSelector:SelectObj(index, is_ignore_same)
    self:_SelectObj(index, is_ignore_same)
end

function UIListSelector:ResetSelectObj()
    self.cur_select_index = nil
    self.cur_select_obj = nil
end

function UIListSelector:ReselectSelectObj()
    if self.cur_select_index then
        self:_SelectObj(self.cur_select_index, true)
    end
end

function UIListSelector:GetCurSelectIndex()
    return self.cur_select_index
end

function UIListSelector:_SelectObj(index, is_ignore_same)
    if not next(self.obj_list) then return end
    if not is_ignore_same and self.cur_select_index == index then return end
    if not self.cur_select_obj then
        self.cur_select_obj = self.obj_list[index]
    else
        self:_SetSelectImageActive(self.cur_select_obj, false)
        self.cur_select_obj = self.obj_list[index]
    end
    self.cur_select_index = index
    self:_SetSelectImageActive(self.cur_select_obj, true)
    if self.select_func then
        self.select_func(index)
    end
end

function UIListSelector:_SetSelectImageActive(obj, is_active)
    local image = obj:FindChild("SelectImage")
    if image then
        image:SetActive(is_active)
    end
end

return UIListSelector
