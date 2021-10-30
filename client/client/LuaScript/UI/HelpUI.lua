local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local HelpUI = class("UI.HelpUI", UIBase)

local max_help_type = 2
function HelpUI:DoInit()
    HelpUI.super.DoInit(self)
    self.prefab_path = "UI/Common/HelpUI"
    self.text_item_list = {}
    self.item_list = {} -- 带标题的item
    self.type_to_panel = {}
    self.type_to_parent = {}
    self.type_to_init_func = {}
    for i = 1, max_help_type do
        self.type_to_init_func[i] = "InitFunc" .. i
    end
end

function HelpUI:OnGoLoadedOk(res_go)
    HelpUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function HelpUI:Show(ui_content_data)
    self.ui_content_data = ui_content_data
    if self.is_res_ok then
        self:InitUI()
    end
    HelpUI.super.Show(self)
end

function HelpUI:InitRes()
    local panel_list = self.main_panel:FindChild("PanelList")
    self.text_temp = self.main_panel:FindChild("Temp/HelpStr")
    self:AddClick(self.main_panel:FindChild("BlackBg"), function ()
        self:Hide()
    end)
    for i = 1, max_help_type do
        local panel = panel_list:FindChild(i)
        self:AddClick(panel:FindChild("Top/CloseBtn"), function ()
            self:Hide()
        end)
        panel:FindChild("Top/Text"):GetComponent("Text").text = UIConst.Text.HELP
        self.type_to_panel[i] = panel
    end
end

function HelpUI:InitUI()
    self:ClearGoDict("text_item_list")
    self:ClearGoDict("item_list")
    local help_type = self.ui_content_data.help_type or 1
    local func_name = self.type_to_init_func[help_type]
    self[func_name](self, self.type_to_panel[help_type])
    for i, panel in ipairs(self.type_to_panel) do
        panel:SetActive(i == help_type)
    end
end

-- 小面板
function HelpUI:InitFunc1(panel)
    local help_str_list = self.ui_content_data.param1
    local parent = panel:FindChild("Scroll View/Viewport/Content")
    panel:FindChild("Scroll View"):GetComponent("ScrollRect").verticalNormalizedPosition = 1
    self:InitText(help_str_list, parent)
end

-- 大面板 带标题的
function HelpUI:InitFunc2(panel)
    local parent = panel:FindChild("Scroll View/Viewport/Content")
    panel:FindChild("Scroll View"):GetComponent("ScrollRect").verticalNormalizedPosition = 1
    local temp = parent:FindChild("Item")
    temp:SetActive(false)
    local help_data_list = self.ui_content_data.param2
    for _, help_data in ipairs(help_data_list) do
        local go = self:GetUIObject(temp, parent)
        table.insert(self.item_list, go)
        go:FindChild("Title/Text"):GetComponent("Text").text = help_data.title
        self:InitText(help_data, go)
    end
end

function HelpUI:InitText(help_str_list, parent)
    for _, help_str in ipairs(help_str_list) do
        local go = self:GetUIObject(self.text_temp, parent)
        go:FindChild("Text"):GetComponent("Text").text = help_str
        table.insert(self.text_item_list, go)
    end
end

function HelpUI:Hide()
    self:ClearGoDict("text_item_list")
    self:ClearGoDict("item_list")
    HelpUI.super.Hide(self)
end

return HelpUI