local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local ItemUtil = require("BaseUtilities.ItemUtil")
local TabViewCmp = require("UI.UICmp.TabViewCmp")
local ScrollListViewCmp = require("UI.UICmp.ScrollListViewCmp")
local CityManagerUI = class("UI.CityManagerUI", UIBase)

CityManagerUI.need_sync_load = true
local kManagerShowCount = 7
local panel_name_list = {
    "hero_panel",
    "child_panel",
}

local kSelectFunc = {
    "InitHeroPanel",
    "InitChildPanel",
}

local btn_text_list = {
    UIConst.Text.HERO_TEXT,
    UIConst.Text.MARRIED_CHILD,
}

local icon_path_list = {
    UIConst.PrefabResPath.HeroItem,
    UIConst.PrefabResPath.MarriedChildIcon,
}

function CityManagerUI:DoInit()
    CityManagerUI.super.DoInit(self)
    self.prefab_path = "UI/Common/CityManagerUI"
    self.dy_strategy_data = ComMgrs.dy_data_mgr.strategy_map_data
    self.income_attr_list = SpecMgrs.data_mgr:GetCityIncomeAttrList()
    self.manager_type_dict = CSConst.CityManager

    --  需要清理的
    self.manager_data_dict = {}
    self.manager_to_go = {}
    self.manager_go_to_go_list = {}
    for i, v in pairs(self.manager_type_dict) do
        self.manager_to_go[v] = {}
        self.manager_data_dict[v] = {}
    end
    self.compare_income_go_list = {}
end

function CityManagerUI:OnGoLoadedOk(res_go)
    CityManagerUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function CityManagerUI:Show(city_id)
    self.city_id = city_id
    self.city_income_data = self.dy_strategy_data:GetCityIncomeData(city_id)
    if self.is_res_ok then
        self:InitUI()
    end
    CityManagerUI.super.Show(self)
end

function CityManagerUI:InitRes()
    -- top
    local content = self.main_panel:FindChild("Content")
    local ui_content_data = SpecMgrs.data_mgr:GetUIContentData("CityManagerPanel")
    local top = content:FindChild("Top")
    top:FindChild("Title"):GetComponent("Text").text = ui_content_data.title
    self:AddClick(top:FindChild("HelpBtn"), function()
        UIFuncs.ShowPanelHelp("CityManagerPanel")
    end)
    content:FindChild("Top/HelpBtn/Text"):GetComponent("Text").text = UIConst.Text.HELP
    self:AddClick(content:FindChild("Top/CloseBtn"), function()
        SpecMgrs.ui_mgr:HideUI(self)
    end)
    -- middle
    local middle = content:FindChild("Middle")
    local btn_parent = middle:FindChild("TagList")
    local panel_go_parent = middle:FindChild("PanelList")

    self.tag_list = {}
    self.panel_list = {}
    self.item_parent_list = {}
    self.item_temp_list = {}
    self.scroll_cmp_list = {}

    for i, panel_name in ipairs(panel_name_list) do
        local panel_go = panel_go_parent:FindChild(i)
        self[panel_name] = panel_go
        table.insert(self.panel_list, panel_go)
        local panel_btn = btn_parent:FindChild(i)
        panel_btn:FindChild("Text"):GetComponent("Text").text = btn_text_list[i]
        self[panel_name .. "_btn"] = panel_btn
        table.insert(self.tag_list, panel_btn)
        local item_parent = panel_go:FindChild("Viewport/Content")
        table.insert(self.item_parent_list, item_parent)
        local item_temp = item_parent:FindChild("Item")
        item_temp:SetActive(false)
        table.insert(self.item_temp_list, item_temp)
        local icon_path = icon_path_list[i]
        UIFuncs.GetIconGo(self, item_temp:FindChild("Icon"), nil, icon_path)
        local view = panel_go:FindChild("Viewport")
        local scroll_cmp = ScrollListViewCmp.New()
        self.scroll_cmp_list[i] = scroll_cmp
        scroll_cmp:DoInit(self, view)
        scroll_cmp:ListenerViewChange(function (go, index, is_add)
            self:ViewChangeCb(i, go, index, is_add)
        end)
    end

    local param_tb = {
        tag_list = self.tag_list,
        panel_list = self.panel_list,
        select_cb = self.TabViewSelectCb,
        init_select = false,
        select_colors = UIConst.Color.SelectTextColorList
    }
    self.tag_view_cmp = TabViewCmp.New()
    self.tag_view_cmp:DoInit(self, param_tb)

    self.compare_item_parent = middle:FindChild("Compare")
    self.compare_item_temp = self.compare_item_parent:FindChild("Item")
    self.compare_item_temp:SetActive(false)

    local temp_parent = self.main_panel:FindChild("Temp")
    self.attr_temp = temp_parent:FindChild("AttrText")
    self.income_temp = temp_parent:FindChild("IncomeItem")
    temp_parent:SetActive(false)

    local btn_list = content:FindChild("Bottom/BtnList")
    self.cancel_btn = btn_list:FindChild("CancelBtn")
    self.cancel_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CANCEL
    self:AddClick(self.cancel_btn, function()
        SpecMgrs.ui_mgr:HideUI(self)
    end)
    self.confirm_btn = btn_list:FindChild("ConfirmBtn")
    self.confirm_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CONFIRM
    self:AddClick(self.confirm_btn, function()
        self:SendManageCity()
    end)
end

function CityManagerUI:InitUI()
    self.tag_view_cmp:Select(1)
    self:ChangeCompareManagerData()
end

function CityManagerUI:TabViewSelectCb(index)
    if self.select_manager_type and self.select_manager_type == index then return end
    local func_name = kSelectFunc[index]
    self.select_manager_type = index
    self.select_manager_index = nil
    self:ChangeCompareManagerData()
    self[func_name](self)
end

function CityManagerUI:Hide()
    self.city_id = nil
    self.city_income_data = nil
    self.select_manager_type = nil
    self.select_manager_index = nil
    for k,v in pairs(self.manager_data_dict) do
        self.manager_data_dict[k] = {}
    end
    self:ClearAllManagerGo()
    self:ClearGoDict("compare_income_go_list")
    CityManagerUI.super.Hide(self)
end

function CityManagerUI:ClearAllManagerGo()
    for manager_type, go_dict in pairs(self.manager_to_go) do
        for k, go in pairs(go_dict) do
            local go_list = self.manager_go_to_go_list[go]
            self:DelObjDict(go_list)
        end
        self.manager_to_go[manager_type] = {}
    end
    self.manager_go_to_go_list = {}
end

function CityManagerUI:ViewChangeCb(manager_type, go, index, is_add)
    if is_add then
        self:AddItem(manager_type, go, index)
    else
        self:RemoveItem(manager_type, go, index)
    end
end

function CityManagerUI:AddItem(manager_type, go, c_index)
    local index = c_index + 1
    self.manager_to_go[manager_type][index] = go
    self:ClearManagerGo(go)
    self.manager_go_to_go_list[go] = {}
    local manager_go_list = self.manager_go_to_go_list[go]
    local manager_data = self:GetManagerData(manager_type, index)
    local icon_go = go:FindChild("Icon/Item")
    local name_text = go:FindChild("Icon/Text"):GetComponent("Text")
    local tb = {go = icon_go}
    local name
    if manager_type == self.manager_type_dict.Hero then
        tb.hero_id = manager_data.manager_id
        UIFuncs.InitHeroGo(tb)
        name = SpecMgrs.data_mgr:GetHeroData(manager_data.manager_id).name
    elseif manager_type == self.manager_type_dict.Child then
        tb.child_id = manager_data.manager_id
        UIFuncs.InitMarriedChildGo(tb)
        name = ComMgrs.dy_data_mgr.child_center_data:GetChildData(manager_data.manager_id).name
    end
    name_text.text = name
    self:_UpdateManagerAttr(go, manager_data, manager_go_list)
    self:_UpdateManager(go, manager_data, manager_go_list)
    self:_UpdateSelect(manager_type, go, index)
    local btn = go:FindChild("Btn")
    self:RemoveClick(btn)
    self:AddClick(btn, function ()
        self:ManagerItemOnClick(manager_type, index, go)
    end)
end

function CityManagerUI:GetManagerData(manager_type, index)
    return self.manager_data_dict[manager_type][index]
end

function CityManagerUI:_UpdateManagerAttr(go, manager_data, manager_go_list)
    local attr_dict = manager_data.manager_info.attr_dict
    local attr_parent = go:FindChild("Attr")
    for i, attr_key in ipairs(self.income_attr_list) do
        local attr_go = self:GetUIObject(self.attr_temp, attr_parent)
        table.insert(manager_go_list, attr_go)
        local attr_data = SpecMgrs.data_mgr:GetAttributeData(attr_key)
        local num = attr_dict[attr_key] or 0
        local str = string.format(UIConst.Text.KEY_VALUE, attr_data.name, UIFuncs.AddCountUnit(num))
        attr_go:GetComponent("Text").text = str
    end
end

function CityManagerUI:_UpdateManager(go, manager_data, manager_go_list)
    local is_manager_has_city = manager_data.manager_city and true or false
    go:FindChild("NoManageCity"):SetActive(not is_manager_has_city)
    go:FindChild("ManageCity"):SetActive(is_manager_has_city)
    if is_manager_has_city then
        local city_data = SpecMgrs.data_mgr:GetCityData(manager_data.manager_city)
        go:FindChild("ManageCity/Text"):GetComponent("Text").text = city_data.name
        local income_go_parent = go:FindChild("ManageCity/Income")
        local item_data_list = ItemUtil.ItemDictToItemDataList(manager_data.manager_city_income_data)
        for i, v in ipairs(item_data_list) do
            local income_go = self:GetUIObject(self.income_temp, income_go_parent)
            table.insert(manager_go_list, income_go)
            UIFuncs.AssignSpriteByItemID(v.item_id, income_go:FindChild("Icon"):GetComponent("Image"))
            income_go:FindChild("Count"):GetComponent("Text").text = UIFuncs.AddCountUnit(v.count)
        end
    end
end

function CityManagerUI:_UpdateSelect(manager_type, go, index)
    local is_on = manager_type == self.select_manager_type and index == self.select_manager_index
    self:ChangeGoSelect(go, is_on)
end

function CityManagerUI:ClearManagerGo(go)
    local go_tb = self.manager_go_to_go_list[go]
    self:DelObjDict(go_tb)
    self.manager_go_to_go_list[go] = nil
end

function CityManagerUI:RemoveItem(manager_type, go, c_index)
    local index = c_index + 1
    self:ClearManagerGo(go)
    self.manager_to_go[manager_type][index] = nil
    self:ChangeGoSelect(go, false)
    self:RemoveClick(go:FindChild("Btn"))
end

function CityManagerUI:ManagerItemOnClick(manager_type, index, go)
    if manager_type ~= self.select_manager_type then return end
    if index == self.select_manager_index then return end
    if self.select_manager_index then
        local go = self.manager_to_go[self.select_manager_type][self.select_manager_index]
        if go then
            self:ChangeGoSelect(go, false)
        end
    end
    self.select_manager_index = index
    local manager_data = self:GetManagerData(manager_type, index)
    self:ChangeCompareManagerData(manager_data)
    self:ChangeGoSelect(go, true)
end

function CityManagerUI:ChangeCompareManagerData(manager_data)
    self:ClearGoDict("compare_income_go_list")
    local cur_income_data = self.city_income_data
    if manager_data then
        local compare_data = self:GetCompareData(cur_income_data, manager_data.self_income_data)
        local item_data_list = ItemUtil.ItemDictToItemDataList(compare_data)
        for i, item_info in ipairs(item_data_list) do
            local itme_id = item_info.item_id
            local go = self:GetUIObject(self.compare_item_temp, self.compare_item_parent)
            table.insert(self.compare_income_go_list, go)
            self:_UpdateCompareItem(go, itme_id, item_info.count.num1, item_info.count.num2)
        end
    else
        local item_data_list = ItemUtil.ItemDictToItemDataList(cur_income_data)
        for i, item_info in ipairs(item_data_list) do
            local itme_id = item_info.item_id
            local go = self:GetUIObject(self.compare_item_temp, self.compare_item_parent)
            table.insert(self.compare_income_go_list, go)
            self:_UpdateCompareItem(go, itme_id, cur_income_data[itme_id], cur_income_data[itme_id])
        end
    end
end

function CityManagerUI:GetCompareData(dict1, dict2)
    local ret = {}
    for k, v in pairs(dict1) do
        if not ret[k] then
            ret[k] = {num1 = v, num2 = dict2[k] or 0}
        end
    end
    for k, v in pairs(dict2) do
        if not ret[k] then
            ret[k] = {num1 = dict1[k] or 0, num2 = v}
        end
    end
    return ret
end

function CityManagerUI:_UpdateCompareItem(go, item_id, cur_num, compare_num)
    UIFuncs.AssignSpriteByItemID(item_id, go:FindChild("Item/Icon"):GetComponent("Image"))
    local color = UIConst.Color.Default
    local is_up = false
    local is_down = false
    if compare_num > cur_num then
        is_up = true
        color = UIConst.Color.Green1
    elseif compare_num < cur_num then
        is_down = true
        color = UIConst.Color.Red1
    end
    go:FindChild("Item/Up"):SetActive(is_up)
    go:FindChild("Item/Down"):SetActive(is_down)
    local str = string.format(UIConst.Text.SIMPLE_COLOR, color, UIFuncs.AddCountUnit(compare_num))
    go:FindChild("Item/Count"):GetComponent("Text").text = str
end

function CityManagerUI:ChangeGoSelect(go, is_on)
    go:FindChild("Selected"):SetActive(is_on)
end

function CityManagerUI:InitHeroPanel()
    local manager_type = self.manager_type_dict.Hero
    local data_list = self.dy_strategy_data:GatherManagerList(self.city_id, manager_type)
    self.manager_data_dict[manager_type] = data_list
    local count = #data_list
    self.scroll_cmp_list[manager_type]:Start(count, math.min(count, kManagerShowCount))
end

function CityManagerUI:InitChildPanel()
    local manager_type = self.manager_type_dict.Child
    local data_list = self.dy_strategy_data:GatherManagerList(self.city_id, manager_type)
    self.manager_data_dict[manager_type] = data_list
    local count = #data_list
    self.scroll_cmp_list[manager_type]:Start(count, math.min(count, kManagerShowCount))
end

function CityManagerUI:UpdateCurDynastyItem()
    local end_flag_index = self.dynasty_list_cmp:GetEndFlagIndex() + 1
    local start_flag_index = self.dynasty_list_cmp:GetStartFlagIndex() + 1
    for i = start_flag_index, end_flag_index do
        self:SetDynastyContent(self.dynasty_item_list[i], i)
    end
end

function CityManagerUI:SendManageCity()
    if not self.select_manager_index or not self.select_manager_type then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.NO_SELECT_MANAGER)
        return
    end
    local manager_data = self:GetManagerData(self.select_manager_type, self.select_manager_index)
    SpecMgrs.msg_mgr:SendMsg("SendManageCity", {city_id = self.city_id, manager_type = manager_data.manager_type, manager_id = manager_data.manager_id}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.MANAGE_SUCCESS)
        end
    end)
    SpecMgrs.ui_mgr:HideUI(self)
end

return CityManagerUI