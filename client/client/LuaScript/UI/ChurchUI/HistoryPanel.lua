local UIFuncs = require("UI.UIFuncs")
local UIConst = require("UI.UIConst")

local TitleScrollViewPanel = require("UI.ChurchUI.TitleScrollViewPanel")

local HistoryPanel = class("UI.ChurchUI.HistoryPanel")

function HistoryPanel:InitRes(go, root_ui)
    self.go = go
    self.root_ui = root_ui
    local content = go:FindChild("Content")
    self.close_btn = content:FindChild("CloseBtn")
    self.titleScrollViewPanel = content:FindChild("TitleScrollViewPanel")
    self.no_list = content:FindChild("GodfathersPanel/NoList")
    self.info_group = content:FindChild("GodfathersPanel/Viewport/InfoGroup")
    self.info_grid_template = content:FindChild("GodfathersPanel/Viewport/InfoGroup/InfoGridTemplate")
    content:FindChild("Title"):GetComponent("Text").text = UIConst.Text.HistoryPanelTitle
    content:FindChild("MiddlePanel/NameTitle"):GetComponent("Text").text = UIConst.Text.HistoryPanelNameTitle
    content:FindChild("MiddlePanel/TimeTitle"):GetComponent("Text").text = UIConst.Text.HistoryPanelTimeTitle
    self.root_ui:AddClick(self.close_btn, function()
        self:Hide()
    end)
    self.title_scrollveiw_panel = TitleScrollViewPanel.New()
    self.title_scrollveiw_panel:InitRes(self.titleScrollViewPanel, self.root_ui, self)
    self.grid_list = {}
end

function HistoryPanel:Show(index)
    self.title_scrollveiw_panel:Init(index)
    self.go:SetActive(true)
end

function HistoryPanel:Hide()
    self.go:SetActive(false)
    self.title_scrollveiw_panel:ResetAnimation()
end

function HistoryPanel:ShowTitleInfo(_, title_id)
    local history_list = ComMgrs.dy_data_mgr.church_data:GetTitleDataById(title_id).history_list
    local list_count = #history_list
    if list_count > 0 then
        for i = 1, list_count do
            local history_list_index = list_count + 1 - i
            local grid
            if self.grid_list[i] then
                grid = self.grid_list[i]
                grid.go:SetActive(true)
            else
                grid = {}
                grid.go = self.root_ui:GetUIObject(self.info_grid_template, self.info_group)
                grid.role_name = grid.go:FindChild("RoleName"):GetComponent("Text")
                grid.date = grid.go:FindChild("Date"):GetComponent("Text")
            end
            grid.role_name.text = history_list[history_list_index].name
            grid.date.text = UIFuncs.DateToFormatStr(history_list[history_list_index].ts)
            self.grid_list[i] = grid
        end
        self.no_list:SetActive(false)
    else
        self.no_list:SetActive(true)
    end
    if list_count < #self.grid_list then
        for i = list_count + 1, #self.grid_list do
            self.grid_list[i].go:SetActive(false)
        end
    end
end

return HistoryPanel