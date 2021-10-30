local UIBase = require("UI.UIBase")
local UIFuncs = require("UI.UIFuncs")
local TabViewCmp = class("UI.UICmp.TabViewCmp", UIBase)

function TabViewCmp:DoInit(ui, param_tb)
    TabViewCmp.super.DoInit(self)
    self.owner = ui
    self.tag = "TabViewCmp".. param_tb.tag_list[1]:GetInstanceID()
    local ret = self.owner:IsRegisterUIDestroyEvent(self.tag)
    if ret then
        PrintError("TabViewCmp:tag is register",self.tag)
    end
    self.owner:RegisterUIDestroyEvent(self.tag,self.DoDestroy,self)
    self.tag_list = param_tb.tag_list
    self.panel_list = param_tb.panel_list
    self.cur_index = param_tb.select_index or 1
    self.select_cb = param_tb.select_cb
    self.click_cb = param_tb.click_cb
    self.select_colors = param_tb.select_colors
    self.select_name = param_tb.select_name or "Selected"
    self.text_name = param_tb.text_name or "Text"
    self.init_select = param_tb.init_select == nil and true or param_tb.init_select
    self:_Init()
end

function TabViewCmp:_Init()
    for index, btn in ipairs(self.tag_list) do
        self.owner:AddClick(btn,function()
            self:Select(index, true)
        end)
    end
    for index, btn in ipairs(self.tag_list) do
        self:ChangeBtnTextColorBySelectedOrNot(index, false)
    end
    for _, panel in ipairs(self.panel_list) do
        panel:SetActive(false)
    end
    if self.init_select then
        self:Select(self.cur_index)
    end
end

function TabViewCmp:Select(index, is_click)
    if is_click then
        if self.click_cb then
            local ret = self.click_cb(self.owner,index)
            if not ret then
                return
            end
        end
        if self.cur_index == index then
            return
        end
    end
    local old_index = self.cur_index
    self:ChangeBtnTextColorBySelectedOrNot(old_index, false)
    self.panel_list[old_index]:SetActive(false)
    self.cur_index = index
    self.panel_list[index]:SetActive(true)
    self:ChangeBtnTextColorBySelectedOrNot(index, true)
    if self.select_cb then
        self.select_cb(self.owner,index)
    end
end

function TabViewCmp:GetSelectTabItem()
    return self.tag_list[self.cur_index]
end

function TabViewCmp:GetSelectPanelItem(select_index)
    local index = select_index or self.cur_index
    return self.panel_list[index]
end

function TabViewCmp:GetSelectTagItem(select_index)
    local index = select_index or self.cur_index
    return self.tag_list[index]
end

function TabViewCmp:DoDestroy()
    if self.tag_list then
        for index, btn in ipairs(self.tag_list) do
            self.owner:RemoveClick(btn)
        end
    end
    self.owner:UnregisterUIDestroyEvent(self.tag)
    TabViewCmp.super.DoDestroy(self)
end

function TabViewCmp:ChangeBtnTextColorBySelectedOrNot(btn_index, is_select)
    if not self.select_colors then return end
    local color = is_select and self.select_colors[2] or self.select_colors[1]
    local tab_btn = self.tag_list[btn_index]
    tab_btn:FindChild(self.select_name):SetActive(is_select)
    tab_btn:FindChild(self.text_name):GetComponent("Text").color = UIFuncs.HexToRGBColor(color)
end

return TabViewCmp