local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local ItemUtil = require("BaseUtilities.ItemUtil")
local SelectItemUseUI = class("UI.SelectItemUseUI", UIBase)

function SelectItemUseUI:DoInit()
    SelectItemUseUI.super:DoInit(self)
    self.prefab_path = "UI/Common/SelectItemUseUI"
    self.dy_bag_data = ComMgrs.dy_data_mgr.bag_data
    self.item_id_to_go = {}
end

function SelectItemUseUI:OnGoLoadedOk(res_go)
    SelectItemUseUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function SelectItemUseUI:Show(param_tb)
    self.get_content_func = param_tb.get_content_func
    self.max_select_num = param_tb.max_select_num
    if not self.max_select_num then return end
    self.is_max = param_tb.is_max and param_tb.is_max or false
    self.confirm_cb = param_tb.confirm_cb
    self.title = param_tb.title or UIConst.Text.ITEM_USE
    if not self:TrySetSelectNum(1) then
        return
    end
    if self.is_res_ok then
        self:InitUI()
    end
    SelectItemUseUI.super.Show(self)
end

function SelectItemUseUI:Hide()
    self:CleanItemGo()
    self.get_content_func = nil
    self.max_select_num = nil
    self.default_select_num = nil
    self.confirm_cb = nil
    self.title = nil
    SelectItemUseUI.super.Hide(self)
end

function SelectItemUseUI:CleanItemGo()
    for _, go in pairs(self.item_id_to_go) do
        self:DelUIObject(go)
    end
    self.item_id_to_go = {}
end

function SelectItemUseUI:InitRes()
    local top_part = self.main_panel:FindChild("Content/Top")
    top_part:FindChild("Title"):GetComponent("Text").text = self.title
    self:AddClick(top_part:FindChild("CloseBtn"), function ()
        self:Hide()
    end)
    local content_panel = self.main_panel
    self.item_parent = self.main_panel:FindChild("Content/Scroll View/Viewport/Content")
    self.item_temp = self.item_parent:FindChild("Item")
    UIFuncs.GetIconGo(self, self.item_temp)
    self.item_temp:SetActive(false)
    self.desc_text = content_panel:FindChild("Content/Description"):GetComponent("Text")
    self.own_text = content_panel:FindChild("Content/OwnCount"):GetComponent("Text")
    local cancel_btn = content_panel:FindChild("Content/BottonBar/CancelBtn")
    cancel_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CANCEL
    self:AddClick(cancel_btn, function ()
        self:Hide()
    end)
    self.confirm_btn = content_panel:FindChild("Content/BottonBar/ConfirmBtn")
    self.confirm_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CONFIRM
    self:AddClick(self.confirm_btn, function ()
        if self.confirm_cb then self.confirm_cb(self.cur_select_num) end
        self:Hide()
    end)
    self.input_field = self.main_panel:FindChild("Content/CountPanel/InputField"):GetComponent("InputField")
    self:AddInputFieldValueChange(self.main_panel:FindChild("Content/CountPanel/InputField"), function (text)
        if self.is_set_by_script then -- 避免脚本设置重复循环调用
            self.is_set_by_script = nil
            return
        end
        self:TrySetSelectNum(self.input_field.text)
    end)
    local count_panel = self.main_panel:FindChild("Content/CountPanel")
    self:AddClick(count_panel:FindChild("Reduce"), function()
        self:ChangeSelectNum(-1)
    end)
    self:AddClick(count_panel:FindChild("Add"), function()
        self:ChangeSelectNum(1)
    end)
    self:AddClick(count_panel:FindChild("ReduceTen"), function()
        self:ChangeSelectNum(-10)
    end)
    self:AddClick(count_panel:FindChild("AddTen"), function()
        self:ChangeSelectNum(10)
    end)
end

function SelectItemUseUI:InitUI()
    self:TrySetSelectNum(self.is_max and self.max_select_num or 1)
    self:SetOwnCount()
end

function SelectItemUseUI:ChangeSelectNum(change_num)
    local num = self.cur_select_num + change_num
    self:TrySetSelectNum(num)
end

function SelectItemUseUI:SetSelectNum(num, content_tb)
    self.cur_select_num = num
    self.is_set_by_script = true
    self.input_field.text = self.cur_select_num
    self.desc_text.text = content_tb.desc_str
    local item_list = ItemUtil.ItemDictToItemDataList(content_tb.item_dict)
    self:CleanItemGo()
    for _, role_item in ipairs(item_list) do
        local go = self:GetUIObject(self.item_temp, self.item_parent)
        local param_tb = {
            item_data = role_item.item_data,
            count = role_item.count,
            go = go:FindChild("Item"),
            ui = self,
        }
        UIFuncs.InitItemGo(param_tb)
        self.item_id_to_go[role_item.item_id] = go
    end
end

function SelectItemUseUI:SetOwnCount()
    local content = self.get_content_func(1)
    local item_list = table.keys(content.item_dict)
    if #item_list ~= 1 then return end -- 多个消耗道具暂时就不显示了
    local item_id = item_list[1]
    local item_count = ComMgrs.dy_data_mgr:ExGetItemCount(item_id)
    self.own_text.text = string.format(UIConst.Text.OWN_TEXT, item_count)
end

function SelectItemUseUI:TrySetSelectNum(num)
    if type(num) ~= "number" then
        num = tonumber(num)
        if not num then
            self.is_set_by_script = true
            self.input_field.text = self.cur_select_num
            return
        end
    end

    local num = math.clamp(num, 1, self.max_select_num)
    local content_tb = self.get_content_func(num)
    local item_dict = content_tb and content_tb.item_dict
    if not item_dict or not self:CheckItemDict(item_dict) then
        num, content_tb = self:GetSelectNum(self.cur_select_num or 1, num - 1)
    end
    if not num or not content_tb then
        local content_tb = self.get_content_func(1)
        UIFuncs.CheckItemCountByDict(content_tb.item_dict, true)
    else
        if self.is_res_ok then
            self:SetSelectNum(num, content_tb)
        end
        return true
    end
end

function SelectItemUseUI:GetSelectNum(begin_num, end_num, success_num, success_content_tb)
    if begin_num > end_num then return end
    local check_num = math.floor((begin_num + end_num) / 2)
    local content_tb = self.get_content_func(check_num)
    local item_dict = content_tb and content_tb.item_dict
    if not self:CheckItemDict(item_dict) then
        if begin_num == check_num then return success_num, content_tb end
        return self:GetSelectNum(begin_num, check_num - 1, success_num, success_content_tb)
    else
        if end_num == check_num then return check_num, content_tb end
        return self:GetSelectNum(check_num + 1, end_num, check_num, content_tb)
    end
end

function SelectItemUseUI:CheckItemDict(item_dict)
    if not item_dict then return end
    for item_id, cost_item_count in pairs(item_dict) do
        if not ComMgrs.dy_data_mgr:ExCheckItemCount(item_id, cost_item_count) then
            return false
        end
    end
    return true
end

return SelectItemUseUI