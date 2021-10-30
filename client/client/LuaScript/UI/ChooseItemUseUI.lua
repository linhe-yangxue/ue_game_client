local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local ChooseItemUseUI = class("UI.ChooseItemUseUI", UIBase)

function ChooseItemUseUI:DoInit()
    ChooseItemUseUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ChooseItemUseUI"
    self.selection_go_dict = {}
end

function ChooseItemUseUI:OnGoLoadedOk(res_go)
    ChooseItemUseUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function ChooseItemUseUI:Hide()
    self.cur_use_count = 0
    self.cur_selection = nil
    self.item_list = {}
    self.item_count_list = {}
    self.confirm_cb = nil
    self.count = nil
    self:ClearSelectionGo()
    ChooseItemUseUI.super.Hide(self)
end

-- item_list, item_count_list, confirm_cb, count
function ChooseItemUseUI:Show(param_tb)
    self.item_list = param_tb.item_list
    self.item_count_list = param_tb.item_count_list
    if not self.item_list or not self.item_count_list then
        return
    end
    self.confirm_cb = param_tb.confirm_cb
    self.count = param_tb.count
    if self.is_res_ok then
        self:InitUI()
    end
    ChooseItemUseUI.super.Show(self)
    self.cur_selection = nil
end

function ChooseItemUseUI:InitRes()
    -- selection item use panel
    local select_item_use_content = self.main_panel:FindChild("Content")
    select_item_use_content:FindChild("Title"):GetComponent("Text").text = UIConst.Text.CHOOSE_REWARD_TEXT
    self:AddClick(select_item_use_content:FindChild("CloseBtn"), function ()
        self:Hide()
    end)
    self.selection_content = select_item_use_content:FindChild("ItemContent/ItemList")
    self.selection_pref = self.selection_content:FindChild("SelectItem")
    self.select_count_panel = select_item_use_content:FindChild("ItemContent/SelectPanel")
    self.select_count_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.BATCH_USE
    self.select_count_panel:FindChild("Count/CountTip"):GetComponent("Text").text = UIConst.Text.INPUT_NUMBER
    self.select_cur_count = self.select_count_panel:FindChild("Count/Text"):GetComponent("Text")
    self:AddClick(self.select_count_panel:FindChild("Reduce"), function ()
        self:UpdateSelectUseCount(self.cur_use_count - 1)
    end)
    self:AddClick(self.select_count_panel:FindChild("Add"), function ()
        self:UpdateSelectUseCount(self.cur_use_count + 1)
    end)
    self:AddClick(self.select_count_panel:FindChild("ReduceTen"), function ()
        self:UpdateSelectUseCount(self.cur_use_count - 10)
    end)
    self:AddClick(self.select_count_panel:FindChild("AddTen"), function ()
        self:UpdateSelectUseCount(self.cur_use_count + 10)
    end)
    local submit_btn = select_item_use_content:FindChild("BtnPanel/SubmitBtn")
    submit_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CONFIRM
    self:AddClick(submit_btn, function ()
        if not self.cur_selection then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.SELECTION_NULL)
        else
            if self.confirm_cb then
                self.confirm_cb(self.cur_selection, self.cur_use_count)
            end
            self:Hide()
        end
    end)
    self.select_own_count = select_item_use_content:FindChild("Count")
    self.select_own_count_text = self.select_own_count:GetComponent("Text")
end

function ChooseItemUseUI:InitUI()
    self:ShowSelectItemUsePanel()
end

function ChooseItemUseUI:ShowSelectItemUsePanel()
    self:ClearSelectionGo()
    self.select_count_panel:SetActive(self.count ~= nil)
    for index, selection in ipairs(self.item_list) do
        local go = self:GetUIObject(self.selection_pref, self.selection_content)
        self.selection_go_dict[index] = go
        UIFuncs.InitItemGo({
            ui = self,
            go = go:FindChild("Item"),
            item_id = selection,
            name_go = go:FindChild("Name"),
            change_name_color = true,
            count = tostring(self.item_count_list[index]),
        })
        self:AddToggle(go, function (is_on)
            self.cur_selection = is_on and index or nil
        end)
    end
    self.select_own_count:SetActive(self.count ~= nil)
    if self.count then
        self.select_own_count_text.text = string.format(UIConst.Text.ITEM_COUNT, self.count)
        self:UpdateSelectUseCount(1)
    end
end

function ChooseItemUseUI:UpdateSelectUseCount(count)
    self.cur_use_count = math.clamp(count, 1, self.count)
    self.select_cur_count.text = self.cur_use_count
end

function ChooseItemUseUI:ClearSelectionGo()
    for _, go in pairs(self.selection_go_dict) do
        go:GetComponent("Toggle").isOn = false
        self:DelUIObject(go)
    end
    self.selection_go_dict = {}
end

return ChooseItemUseUI