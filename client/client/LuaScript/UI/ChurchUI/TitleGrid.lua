local UIFuncs = require("UI.UIFuncs")

local TitleGrid = class("UI.ChurchUI.TitleGrid")

function TitleGrid:InitRes(go, root_ui, parent_ui, title_id, index)
    self.go = go
    self.root_ui = root_ui
    self.parent_ui = parent_ui
    self.title_id = title_id
    self.index = index
    self.grid_rectTransform = go:GetComponent("RectTransform")
    self.pos_x = self.grid_rectTransform.anchoredPosition.x
    self.background_img = go:FindChild("Background"):GetComponent("Image")
    local item_data = SpecMgrs.data_mgr:GetItemData(title_id)
    UIFuncs.AssignSpriteByIconID(item_data.btn_icon, self.background_img)

    self.grid_toggle = go:GetComponent("Toggle")
    self.root_ui:AddToggle(self.go, function(is_on)
        self:GridToggleListener(is_on)
    end)
    self.original_size = self.grid_rectTransform.sizeDelta
    self.bigger_size = Vector2.New(62, 62) + self.original_size
end

function TitleGrid:GridToggleListener(is_on)
    if is_on then
        self.grid_rectTransform.sizeDelta = self.bigger_size
        self.parent_ui:OnGridSelected(self)
    else
        self.grid_rectTransform.sizeDelta = self.original_size
    end
end

function TitleGrid:Select(is_on)
    if self.grid_toggle.isOn ~= is_on then
        self.grid_toggle.isOn = is_on
    else
        self:GridToggleListener(is_on)
    end
end

return TitleGrid