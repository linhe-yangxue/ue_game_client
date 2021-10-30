local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local AttrUtil = require("BaseUtilities.AttrUtil")

local SelectMultiEquipUI = class("UI.SelectMultiEquipUI", UIBase)

function SelectMultiEquipUI:DoInit()
    SelectMultiEquipUI.super.DoInit(self)
    self.prefab_path = "UI/Common/SelectMultiEquipUI"
    self.selection_item_list = {}
    self.star_item_list = {}
end

function SelectMultiEquipUI:OnGoLoadedOk(res_go)
    SelectMultiEquipUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function SelectMultiEquipUI:Hide()
    self:ClearSelectionItem()
    self.temp_select_dict = {}
    SelectMultiEquipUI.super.Hide(self)
end

-- item_list:物品列表(动态数据), cur_select_dict:初始选择的物品 guid => count
-- select_limit:选择数量上限, confirm_cb(select_dict) guid => {guid, count, item_data}
-- title
function SelectMultiEquipUI:Show(data)
    self.data = data
    if self.is_res_ok then
        self:InitUI()
    end
    SelectMultiEquipUI.super.Show(self)
end

function SelectMultiEquipUI:InitRes()
    local top_bar = self.main_panel:FindChild("TopBar")
    UIFuncs.InitTopBar(self, top_bar, "SelectMultiEquipUI", function ()
        if self.data.cancel_cb then self.data.cancel_cb() end
        self:Hide()
    end)
    self.title = top_bar:FindChild("CloseBtn/Title"):GetComponent("Text")
    self.equip_list = self.main_panel:FindChild("Content/View/Content")
    self.equip_item = self.equip_list:FindChild("EquipItem")
    self.star_item = self.equip_item:FindChild("StarList/Star")
    self.fragment_item = self.equip_list:FindChild("FragmentItem")
    self.empty_panel = self.main_panel:FindChild("Content/Empty")
    self.empty_dialog_text = self.empty_panel:FindChild("Dialog/Text"):GetComponent("Text")
    local bottom_panel = self.main_panel:FindChild("BottomPanel")
    self.select_count = bottom_panel:FindChild("SelectCount"):GetComponent("Text")
    local submit_btn = bottom_panel:FindChild("SubmitBtn")
    submit_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CONFIRM
    self:AddClick(submit_btn, function ()
        if self.data.confirm_cb then self.data.confirm_cb(self.temp_select_dict) end
        self:Hide()
    end)
end

function SelectMultiEquipUI:InitUI()
    if not self.data then
        self:Hide()
        return
    end
    self.temp_select_dict = {}
    self.cur_select_count = 0
    if self.data.cur_select_dict then
        for guid, count in pairs(self.data.cur_select_dict) do
            self.temp_select_dict[guid] = count
            self.cur_select_count = self.cur_select_count + 1
        end
    end
    self.title.text = self.data.title or UIConst.Text.SELECT_EQUIPMENT
    self.select_count.text = string.format(UIConst.Text.SELECT_COUNT_FORMAT, self.cur_select_count, self.data.select_limit or UIConst.Text.MAX_VALUE)
    if not self.data.item_list then return end
    self.empty_panel:SetActive(#self.data.item_list == 0)
    if #self.data.item_list == 0 then
        self.empty_dialog_text.text = self.data.empty_tip or UIConst.Text.NO_SELECTABLE_EQUIP_OR_FRAG
        return
    end
    if self.data.item_list[1].item_data.item_type == CSConst.ItemType.Equip then
        self:InitEquipList()
    else
        self:InitFragmentList()
    end
    self.equip_list:GetComponent("RectTransform").anchoredPosition = Vector2.zero
end

function SelectMultiEquipUI:InitEquipList()
    for i, equip_info in ipairs(self.data.item_list) do
        local quality_data = SpecMgrs.data_mgr:GetQualityData(equip_info.item_data.quality)
        local item_go = self:GetUIObject(self.equip_item, self.equip_list)
        table.insert(self.selection_item_list, item_go)

        UIFuncs.InitItemGo({
            ui = self,
            go = item_go:FindChild("Item"),
            item_data = equip_info.item_data,
            name_go = item_go:FindChild("NamePanel/Name"),
            change_name_color = true,
        })
        item_go:FindChild("NamePanel/StrengthenLv"):GetComponent("Text").text = string.format(UIConst.Text.LEVEL, equip_info.strengthen_lv)

        local item_panel = item_go:FindChild("ItemPanel")
        local attr_dict = AttrUtil.GetEquipAttrDict(equip_info.guid)
        local attr_item = item_panel:FindChild("Attr")
        local attr = equip_info.item_data.refine_attr_list[1]
        local show_attr_flag = attr ~= nil and attr_dict[attr] ~= nil and attr_dict[attr] > 0
        attr_item:SetActive(show_attr_flag)
        if show_attr_flag then
            attr_item:GetComponent("Text").text = UIFuncs.GetAttrStr(attr, math.floor(attr_dict[attr]))
        end
        local extra_attr_item = item_panel:FindChild("ExtraAttr")
        local extra_attr = equip_info.item_data.refine_attr_list[2]
        local show_extra_attr_flag = extra_attr ~= nil and attr_dict[extra_attr] ~= nil and attr_dict[extra_attr] > 0
        extra_attr_item:SetActive(show_extra_attr_flag)
        if show_extra_attr_flag then
            extra_attr_item:GetComponent("Text").text = UIFuncs.GetAttrStr(attr, math.floor(attr_dict[extra_attr]))
        end
        item_panel:FindChild("RefineLv/Text"):GetComponent("Text").text = string.format(UIConst.Text.REFINE_LEVEL, equip_info.refine_lv)
        local star_list = item_go:FindChild("StarList")
        star_list:SetActive(equip_info.star_lv and equip_info.star_lv > 0)
        if quality_data.equip_star_lv_limit and equip_info.star_lv > 0 then
            for i = 1, quality_data.equip_star_lv_limit do
                local star_item = self:GetUIObject(self.star_item, star_list)
                star_item:FindChild("Active"):SetActive(i <= equip_info.star_lv)
                table.insert(self.star_item_list, star_item)
            end
        end

        local select_toggle = item_go:FindChild("SelectToggle")
        select_toggle:GetComponent("Toggle").isOn = self.temp_select_dict[equip_info.guid] ~= nil
        self:AddToggle(select_toggle, function (is_on)
            if is_on then
                if self.cur_select_count >= self.data.select_limit then
                    select_toggle:GetComponent("Toggle").isOn = false
                else
                    local select_data = {}
                    select_data.guid = equip_info.guid
                    select_data.count = 1
                    select_data.item_data = equip_info.item_data
                    self.cur_select_count = self.cur_select_count + 1
                    self.temp_select_dict[equip_info.guid] = select_data
                end
            else
                if self.temp_select_dict[equip_info.guid] then
                    self.temp_select_dict[equip_info.guid] = nil
                    self.cur_select_count = self.cur_select_count - 1
                end
            end
            self.select_count.text = string.format(UIConst.Text.SELECT_COUNT_FORMAT, self.cur_select_count, self.data.select_limit)
        end)
    end
end

function SelectMultiEquipUI:InitFragmentList()
    for _, item_info in ipairs(self.data.item_list) do
        local item_go = self:GetUIObject(self.fragment_item, self.equip_list)
        local quality_data = SpecMgrs.data_mgr:GetQualityData(item_info.item_data.quality)
        UIFuncs.InitItemGo({
            ui = self,
            go = item_go:FindChild("Item"),
            item_data = item_info.item_data,
        })
        local item_name = UIFuncs.GetItemName({item_data = item_info.item_data, change_name_color = true})
        item_go:FindChild("Name"):GetComponent("Text").text = item_name .. string.format(UIConst.Text.COUNT, item_info.count)
        local count_panel = item_go:FindChild("CountPanel")
        local count_input = count_panel:FindChild("CountInput")
        local count_input_cmp = count_input:GetComponent("InputField")
        self:AddInputFieldValueChange(count_input, function (text)
            if not self.temp_select_dict[item_info.guid] then return end
            local count = tonumber(text)
            if text == "" then count = 0 end
            if count then
                self.temp_select_dict[item_info.guid].count = math.clamp(count, 1, item_info.count)
            end
            count_input_cmp.text = self.temp_select_dict[item_info.guid].count
        end)
        count_input_cmp.interactable = self.temp_select_dict[item_info.guid] ~= nil
        count_input_cmp.text = self.temp_select_dict[item_info.guid] and self.temp_select_dict[item_info.guid].count or 0

        local select_toggle = item_go:FindChild("SelectToggle")
        select_toggle:GetComponent("Toggle").isOn = self.temp_select_dict[item_info.guid] ~= nil
        self:AddClick(count_panel:FindChild("ReduceBtn"), function ()
            local select_data = self.temp_select_dict[item_info.guid]
            if select_data then
                select_data.count = math.max(1, select_data.count - 1)
                count_input_cmp.text = select_data.count
            end
        end)
        self:AddClick(count_panel:FindChild("AddBtn"), function ()
            select_toggle:GetComponent("Toggle").isOn = true
            local select_data = self.temp_select_dict[item_info.guid]
            if select_data then
                select_data.count = math.min(select_data.count + 1, item_info.count)
                count_input_cmp.text = select_data.count
            end
        end)

        self:AddToggle(select_toggle, function (is_on)
            if is_on then
                self.cur_select_count = self.cur_select_count + 1
                if self.cur_select_count >= self.data.select_limit then
                    select_toggle:GetComponent("Toggle").isOn = false
                else
                    local select_data = {}
                    select_data.guid = item_info.guid
                    select_data.count = item_info.count
                    select_data.item_data = item_info.item_data
                    count_input_cmp.text = item_info.count
                    self.temp_select_dict[item_info.guid] = select_data
                    count_input_cmp.interactable = true
                end
            else
                if self.temp_select_dict[item_info.guid] then
                    self.temp_select_dict[item_info.guid] = nil
                    count_input_cmp.text = 0
                    self.cur_select_count = self.cur_select_count - 1
                    count_input_cmp.interactable = false
                end
            end
            self.select_count.text = string.format(UIConst.Text.SELECT_COUNT_FORMAT, self.cur_select_count, self.data.select_limit)
        end)
        table.insert(self.selection_item_list, item_go)
    end
end

function SelectMultiEquipUI:ClearSelectionItem()
    for _, star_go in ipairs(self.star_item_list) do
        self:DelUIObject(item_go)
    end
    self.star_item_list = {}
    for _, item_go in ipairs(self.selection_item_list) do
        self:DelUIObject(item_go)
    end
    self.selection_item_list = {}
end

return SelectMultiEquipUI