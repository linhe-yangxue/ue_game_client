local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local TitleUI = class("UI.TitleUI",UIBase)
local UIFuncs = require("UI.UIFuncs")

local kTitleType = {
    [CSConst.ItemSubType.RushActivityTitle] = UIConst.Text.RUSH_ACTIVITY_TITLE,
    [CSConst.ItemSubType.TimeLimitedTitle] = UIConst.Text.TIME_LIMITED_TITLE,
    [CSConst.ItemSubType.PermanentTitle] = UIConst.Text.PERMANENT_TITLE,
}
local kExpandStateRotation = Quaternion.Euler(Vector3.New(0, 0, -90))
local kCloseStateRotation = Quaternion.Euler(Vector3.zero)

function TitleUI:DoInit()
    TitleUI.super.DoInit(self)
    self.prefab_path = "UI/Common/TitleUI"
    self.dy_title_data = ComMgrs.dy_data_mgr.title_data
    self.title_type_state = {}
    self.type_title_go = {}
    self.type_to_item_parent = {}
    self.type_to_item = {}
    self.state_go_dict = {}
    self.equip_id = nil
    self.select_id = nil
    self.is_own_state = true
end

function TitleUI:OnGoLoadedOk(res_go)
    TitleUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function TitleUI:Hide()
    if self.select_id then
        local _type = SpecMgrs.data_mgr:GetItemData(self.select_id).sub_type
        self.type_to_item[_type][self.select_id].select_go:SetActive(false)
    end
    self.select_id = nil
    self.is_own_state = true
    TitleUI.super.Hide(self)
end

function TitleUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    TitleUI.super.Show(self)
end

function TitleUI:InitRes()
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "TitleUI")

    self.equipped_title = self.main_panel:FindChild("EquippedTitleInfo/EquippedTitle")
    self.no_equip_tip = self.main_panel:FindChild("EquippedTitleInfo/NoWearTitle")
    self.no_equip_tip:FindChild("Text"):GetComponent("Text").text = UIConst.Text.NO_WEAR_TITLE
    local detail_info_panel = self.main_panel:FindChild("DetailInfoPanel")
    self.own_tip = detail_info_panel:FindChild("OptionList/Own")
    self.own_tip:FindChild("Text"):GetComponent("Text").text = UIConst.Text.OWN_TITLE_TIP
    self.own_select_image = self.own_tip:FindChild("SelectImage")
    self.own_select_image:SetActive(self.is_own_state)
    self.not_own_tip = detail_info_panel:FindChild("OptionList/NotOwn")
    self.not_own_tip:FindChild("Text"):GetComponent("Text").text = UIConst.Text.NOT_OWN_TITLE_TIP
    self.not_own_select_image = self.not_own_tip:FindChild("SelectImage")
    self.not_own_select_image:SetActive(not self.is_own_state)
    self:AddClick(self.own_tip, function ()
        self.is_own_state = true
        self.own_select_image:SetActive(self.is_own_state)
        self.not_own_select_image:SetActive(not self.is_own_state)
        self:_UpdateEmptyPanel()
        self:_ChangeTip()
        self:_UpdateTitleItemState()
        self:_UpdateButtonState()
    end)
    self:AddClick(self.not_own_tip, function ()
        self.is_own_state = false
        self.own_select_image:SetActive(self.is_own_state)
        self.not_own_select_image:SetActive(not self.is_own_state)
        self:_UpdateEmptyPanel()
        self:_ChangeTip()
        self:_UpdateTitleItemState()
        self:_UpdateButtonState()
    end)
    self.empty_panel = detail_info_panel:FindChild("EmptyPanel")
    self.view_panel = detail_info_panel:FindChild("View")
    self.title_parent = detail_info_panel:FindChild("View/Viewport/Content")
    self.title_item_temp = self.title_parent:FindChild("Item")
    self.title_type_temp = self.title_parent:FindChild("GameObject/TitleType")
    self.title_item_list_temp = self.title_parent:FindChild("GameObject/ItemList")
    self.effect_text_temp = self.title_item_temp:FindChild("Effect/Text")
    self.title_item_temp:SetActive(false)
    self.title_type_temp:SetActive(false)
    self.title_item_list_temp:SetActive(false)
    self.effect_text_temp:SetActive(false)

    self.bottom_panel = self.main_panel:FindChild("DetailInfoPanel/View/BottomPanel")
    self.wear_btn = self.bottom_panel:FindChild("WearBtn")
    self.remove_btn = self.bottom_panel:FindChild("RemoveBtn")
    self.wear_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.WEAR_TITLE
    self.remove_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.REMOVE_TITLE
    self:AddClick(self.wear_btn, function ()
        SpecMgrs.msg_mgr:SendWearingTitle({title_id = self.select_id}, function (resp)
            if resp.errcode == 0 then
                local _type = SpecMgrs.data_mgr:GetItemData(self.select_id).sub_type
                self:_UpdateWearingTitle()
                self:_UpdateButtonState()
            end
        end)
    end)
    self:AddClick(self.remove_btn, function ()
        SpecMgrs.msg_mgr:SendUnwearingTitle({title_id = self.select_id}, function (resp)
            if resp.errcode == 0 then
                local title_data = SpecMgrs.data_mgr:GetItemData(self.select_id)
                local _type = title_data.sub_type
                self.type_to_item[_type][self.select_id].limit_time_tip:SetActive(title_data.validity_period and true or false)
                self.type_to_item[_type][self.select_id].equip_tip:SetActive(false)
                self:_UpdateWearingTitle()
                self:_UpdateButtonState()
            end
        end)
    end)

    self:_InitTitleType()
    for _type in pairs(kTitleType) do
        self:_InitTitleItem(_type)
    end
end

function TitleUI:InitUI()
    self:RegisterEvent(self.dy_title_data, "UpdateTitleInfoEvent", function ()
        self:_UpdateEmptyPanel()
        self:_UpdateWearingTitle()
        self:_UpdateTitleItemState()
    end)
    self:RegisterEvent(self.dy_title_data, "UpdateWearTitleEvent", function ()
        self:_UpdateWearingTitle()
    end)
    self:RegisterEvent(self.dy_title_data, "UpdateAddTitleEvent", function ()
        self:_UpdateEmptyPanel()
        self:_UpdateTitleItemState()
    end)
    self:RegisterEvent(self.dy_title_data, "UpdateDeleteTitleEvent", function ()
        self:_UpdateTitleItemState()
    end)
    self:_UpdateEmptyPanel()
    self:_UpdateWearingTitle()
    self:_ChangeTip()
    self:_UpdateTitleItemState()
    self:_UpdateButtonState()
end

function TitleUI:_InitTitleType()
    for title_type, title_text in pairs(kTitleType) do
        local item = self:GetUIObject(self.title_type_temp, self.title_parent)
        local item_list = self:GetUIObject(self.title_item_list_temp, self.title_parent)
        self.type_title_go[title_type] = item
        self.title_type_state[title_type] = false
        self.type_to_item_parent[title_type] = item_list
        self.type_to_item[title_type] = {}
        item_list:SetActive(self.is_own_state)
        item:FindChild("Text"):GetComponent("Text").text = title_text
        local expand = item:FindChild("ExpandState"):GetComponent("RectTransform")
        local own_num, not_own_num = self.dy_title_data:GetOwnTypeTitleNum(title_type)
        self:AddClick(item, function ()
            self.title_type_state[title_type] = not self.title_type_state[title_type]
            self.type_to_item_parent[title_type]:SetActive((self.is_own_state and own_num > 0 or not_own_num > 0) and (self.is_own_state or self.title_type_state[title_type]))
            expand.localRotation = self.title_type_state[title_type] and kExpandStateRotation or kCloseStateRotation
        end)
    end
end

function TitleUI:_InitTitleItem(title_type)
    self.type_to_item[title_type] = {}
    local title_list = self.dy_title_data:GetSortTitleList(title_type)
    for k, title_data in ipairs(title_list) do
        local item = self:GetUIObject(self.title_item_temp, self.type_to_item_parent[title_type])
        local select_go = item:FindChild("Select")
        local limit_time_tip = item:FindChild("LimitTime")
        local equip_tip = item:FindChild("Equip")
        local time = item:FindChild("Time")
        self.type_to_item[title_type][title_data.id] = {
            go = item,
            select_go = select_go,
            limit_time_tip = limit_time_tip,
            equip_tip = equip_tip,
            time = time,
        }
        select_go:SetActive(false)
        limit_time_tip:SetActive(title_data.validity_period and true or false)
        UIFuncs.AssignSpriteByIconID(title_data.icon, item:FindChild("TitleImage"):GetComponent("Image"))
        item:FindChild("Name"):GetComponent("Text").text = title_data.name
        local get_tiem = self.dy_title_data:GetTitleGetTime(title_data.id)
        if not get_tiem then
            time:SetActive(false)
        elseif title_data.validity_period then
            local end_time = title_data.validity_period * CSConst.Time.Day + get_tiem
            local now_time = Time:GetServerTime()
            time:GetComponent("Text").text = string.format(UIConst.Text.TITLE_REMAIN_TIME, math.ceil((end_time - now_time) / CSConst.Time.Day))
            limit_time_tip:SetActive(true)
        else
            time:GetComponent("Text").text = UIConst.Text.PERMANENT_TITLE_TIME
            limit_time_tip:SetActive(true)
        end
        self:_InitTitleEffectText(item:FindChild("Effect"), title_data)
        self:AddClick(item, function ()
            if self.select_id and self.select_id ~= title_data.id then
                local _type = SpecMgrs.data_mgr:GetItemData(self.select_id).sub_type
                self.type_to_item[_type][self.select_id].select_go:SetActive(false)
            end
            select_go:SetActive(true)
            self.select_id = title_data.id
            self:_UpdateButtonState()
        end)
    end
end

function TitleUI:_InitTitleEffectText(go, title_data)
    if title_data.add_role_attr_name_list then
        for k, attr in ipairs(title_data.add_role_attr_name_list) do
            local item = self:GetUIObject(self.effect_text_temp, go)
            local name = SpecMgrs.data_mgr:GetAttributeData(attr).name
            local value = title_data.add_role_attr_value_list[k]
            item:GetComponent("Text").text = string.format(UIConst.Text.EFFECT_TEXT, name, value)
        end
    end
    if title_data.add_hero_attr_name_list then
        for k, attr in ipairs(title_data.add_hero_attr_name_list) do
            local item = self:GetUIObject(self.effect_text_temp, go)
            local name = SpecMgrs.data_mgr:GetAttributeData(attr).name
            local value = title_data.add_hero_attr_value_list[k]
            item:GetComponent("Text").text = string.format(UIConst.Text.EFFECT_TEXT, name, value)
        end
    end
end

function TitleUI:_UpdateEmptyPanel()
    if self.dy_title_data:GetOwnTitleNum() <= 0 and self.is_own_state then
        self.view_panel:SetActive(false)
        self.empty_panel:SetActive(true)
        return
    end
    self.view_panel:SetActive(true)
    self.empty_panel:SetActive(false)
end

function TitleUI:_UpdateWearingTitle()
    local wear_title = self.dy_title_data:GetWearingTitle()
    if not wear_title then
        self.no_equip_tip:SetActive(true)
        self.equipped_title:SetActive(false)
    else
        if self.equip_id then
            local last_equip_data = SpecMgrs.data_mgr:GetItemData(wear_title)
            local _type = last_equip_data.sub_type
            self.type_to_item[_type][self.equip_id].limit_time_tip:SetActive(last_equip_data.validity_period and true or false)
            self.type_to_item[_type][self.equip_id].equip_tip:SetActive(false)
        end
        self.equip_id = wear_title
        local title_data = SpecMgrs.data_mgr:GetItemData(wear_title)
        local _type = title_data.sub_type
        self.no_equip_tip:SetActive(false)
        self.equipped_title:SetActive(true)
        UIFuncs.AssignSpriteByIconID(title_data.icon, self.equipped_title:GetComponent("Image"))
        self.type_to_item[_type][wear_title].limit_time_tip:SetActive(false)
        self.type_to_item[_type][wear_title].equip_tip:SetActive(true)
    end
end

function TitleUI:_ChangeTip()
    self.own_select_image:SetActive(self.is_own_state)
    self.not_own_select_image:SetActive(not self.is_own_state)
    self.wear_btn:SetActive(self.is_own_state)
    self.remove_btn:SetActive(self.is_own_state)
    self.wear_btn:GetComponent("Button").interactable = false
    self.bottom_panel:SetActive(self.is_own_state)
end

function TitleUI:_UpdateTitleItemState()
    for _type, go in pairs(self.type_title_go) do
        go:SetActive(not self.is_own_state)
    end
    for _type, go in pairs(self.type_to_item_parent) do
        local own_num, not_own_num = self.dy_title_data:GetOwnTypeTitleNum(_type)
        go:SetActive((self.is_own_state and own_num > 0 or not_own_num > 0) and (self.is_own_state or self.title_type_state[_type]))
    end
    local all_data = SpecMgrs.data_mgr:GetAllItemData()
    for _type, id_go_dict in pairs(self.type_to_item) do
        for id, go_dict in pairs(id_go_dict) do
            if self.is_own_state then
                go_dict.go:SetActive(self.dy_title_data:GetTitleGetTime(id) ~= nil)
                local get_tiem = self.dy_title_data:GetTitleGetTime(id)
                if not get_tiem then
                    go_dict.time:SetActive(false)
                elseif all_data[id].validity_period then
                    local end_time = all_data[id].validity_period * CSConst.Time.Day + get_tiem
                    local now_time = Time:GetServerTime()
                    go_dict.time:GetComponent("Text").text = string.format(UIConst.Text.TITLE_REMAIN_TIME, math.ceil((end_time - now_time) / CSConst.Time.Day))
                    go_dict.time:SetActive(true)
                else
                    go_dict.time:GetComponent("Text").text = UIConst.Text.PERMANENT_TITLE_TIME
                    go_dict.time:SetActive(true)
                end
            else
                go_dict.go:SetActive(not self.dy_title_data:GetTitleGetTime(id))
            end
        end
    end
end

function TitleUI:_UpdateButtonState()
    if not self.is_own_state then
        self.wear_btn:SetActive(false)
        self.remove_btn:SetActive(false)
        return
    end
    if self.select_id and self.select_id == self.dy_title_data:GetWearingTitle() then
        self.wear_btn:SetActive(false)
        self.remove_btn:SetActive(true)
    elseif self.select_id then
        self.wear_btn:SetActive(true)
        self.remove_btn:SetActive(false)
        local is_get = self.dy_title_data:GetTitleGetTime(self.select_id) ~= nil
        self.wear_btn:GetComponent("Button").interactable = is_get and true
    else
        self.wear_btn:SetActive(true)
        self.remove_btn:SetActive(false)
        self.wear_btn:GetComponent("Button").interactable = false
    end
end

return TitleUI