local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local DirectedTravelUI = class("UI.DirectedTravelUI", UIBase)

function DirectedTravelUI:DoInit()
    DirectedTravelUI.super.DoInit(self)
    self.prefab_path = "UI/Common/DirectedTravelUI"
    self.dy_travel_data = ComMgrs.dy_data_mgr.travel_data
    self.dy_bag_data = ComMgrs.dy_data_mgr.bag_data
    self.dy_lover_data = ComMgrs.dy_data_mgr.lover_data
    self.event_go_list = {}
    self.item_count_dict = {}
    self.travel_cost_item = CSConst.CostValueItem.PhysicalPower
    self.recover_item_id = SpecMgrs.data_mgr:GetParamData("travel_strength_num_restore_item").item_id
    self.max_luck = SpecMgrs.data_mgr:GetParamData("travel_luck_limit").f_value
    self.max_directed_travel_count = SpecMgrs.data_mgr:GetParamData("assign_travel_max_count").f_value
    self.strengthen_recover_cd = SpecMgrs.data_mgr:GetParamData("travel_strength_num_restore_cd").f_value
    self.travel_luck_cost = SpecMgrs.data_mgr:GetParamData("travel_luck_consume").f_value
end

function DirectedTravelUI:OnGoLoadedOk(res_go)
    DirectedTravelUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function DirectedTravelUI:Show(city_id)
    self.cur_city = city_id
    if self.is_res_ok then
        self:InitUI()
    end
    DirectedTravelUI.super.Show(self)
end

function DirectedTravelUI:Hide()
    self:RemoveDynamicUI(self.rest_time)
    ComMgrs.dy_data_mgr:UnregisterUpdateCurrencyEvent("DirectedTravelUI")
    self.dy_travel_data:UnregisterUpdateTravelInfoEvent("DirectedTravelUI")
    DirectedTravelUI.super.Hide(self)
end

function DirectedTravelUI:InitRes()
    local top_menu_panel = self.main_panel:FindChild("TopBar")
    self:AddClick(top_menu_panel:FindChild("HelpBtn"), function ()
        UIFuncs.ShowPanelHelp("DirectedTravelUI")
    end)
    local content_data = SpecMgrs.data_mgr:GetUIContentData("DirectedTravelUI")
    top_menu_panel:FindChild("CloseBtn/Title"):GetComponent("Text").text = content_data.title
    local item_list = top_menu_panel:FindChild("ItemPanel/Itemlist")
    local item_pref = item_list:FindChild("Item")
    for _, item_id in ipairs(content_data.top_bar_item_list) do
        local item_go = self:GetUIObject(item_pref, item_list)
        local item_data = SpecMgrs.data_mgr:GetItemData(item_id)
        UIFuncs.AssignSpriteByIconID(item_data.icon, item_go:FindChild("Frame/Icon"):GetComponent("Image"))
        self.item_count_dict[item_id] = item_go:FindChild("Frame/Text"):GetComponent("Text")
    end
    self.directed_travel_count = top_menu_panel:FindChild("ItemPanel/DirectedTravelCount"):GetComponent("Text")
    self:AddClick(top_menu_panel:FindChild("CloseBtn"), function ()
        self:Hide()
    end)

    local content_panel = self.main_panel:FindChild("ContentPanel")
    local city_panel = content_panel:FindChild("CityPanel")
    self.city_img = city_panel:FindChild("CityImg")
    self.city_img_cmp = self.city_img:GetComponent("Image")
    self.city_name = city_panel:FindChild("TopBg/CityName"):GetComponent("Text")
    local cost_panel = city_panel:FindChild("TopBg/CostPanel")
    cost_panel:FindChild("DescText"):GetComponent("Text").text = UIConst.Text.COST_COUNT
    self.cost_count = cost_panel:FindChild("Count"):GetComponent("Text")

    local event_panel = content_panel:FindChild("EventPanel")
    event_panel:FindChild("Image/Text"):GetComponent("Text").text = UIConst.Text.RANDOM_EVENT
    self.event_content = event_panel:FindChild("View/Content")
    self.event_item = self.event_content:FindChild("EventItem")
    self.event_item:FindChild("LoverExtraDesc/MeetText"):GetComponent("Text").text = UIConst.Text.MEET_TEXT

    local bottom_panel = self.main_panel:FindChild("BottomPanel")
    local luck_panel = bottom_panel:FindChild("LuckPanel")
    luck_panel:FindChild("LuckDesc"):GetComponent("Text").text = UIConst.Text.LUCK_TEXT
    local luck_count_panel = luck_panel:FindChild("LuckBar")
    self.luck_value = luck_count_panel:FindChild("LuckValue"):GetComponent("Image")
    self.luck_count = luck_count_panel:FindChild("LuckText"):GetComponent("Text")
    self:AddClick(luck_count_panel:FindChild("AddBtn"), function ()
        SpecMgrs.ui_mgr:ShowUI("CharityUI")
    end)
    self.city_distance = bottom_panel:FindChild("DistanceText"):GetComponent("Text")
    self.luck_cost = bottom_panel:FindChild("LuckCost"):GetComponent("Text")

    self.rest_panel = bottom_panel:FindChild("RestPanel")
    self.rest_time = self.rest_panel:FindChild("RestTime"):GetComponent("Text")
    local recover_btn = self.rest_panel:FindChild("RecoverBtn")
    recover_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.RECOVER_STRENGHTEN
    self:AddClick(recover_btn, function ()
        self.dy_travel_data:SendUseTravelItem()
    end)
    self.travel_panel = bottom_panel:FindChild("TravelPanel")
    self.strengthen_count = self.travel_panel:FindChild("StrengthenCount"):GetComponent("Text")
    local travel_btn = self.travel_panel:FindChild("TravelBtn")
    travel_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DIRECTED_TRAVEL
    self:AddClick(travel_btn, function ()
        self:SendDirectTravel()
    end)
end

function DirectedTravelUI:InitUI()
    if not self.cur_city then
        self:Hide()
        return
    end
    self:UpdateCurrencyPanel()
    self:UpdateTravelInfo()
    self:InitCityInfo()
    self:InitBottomPanel()
    ComMgrs.dy_data_mgr:RegisterUpdateCurrencyEvent("DirectedTravelUI", self.UpdateCurrencyPanel, self)
    self.dy_travel_data:RegisterUpdateTravelInfoEvent("DirectedTravelUI", self.UpdateTravelInfo, self)
end

function DirectedTravelUI:UpdateCurrencyPanel()
    local currency_data = ComMgrs.dy_data_mgr:GetCurrencyData()
    for item_id, count in pairs(self.item_count_dict) do
        count.text = UIFuncs.AddCountUnit(currency_data[item_id] or 0)
    end
end

function DirectedTravelUI:UpdateTravelInfo()
    self.directed_travel_count.text = string.format(UIConst.Text.DIRECTED_TRAVEL_COUNT, self.dy_travel_data:GetDirectedTravelCount(), self.max_directed_travel_count)
    local cur_luck = self.dy_travel_data:GetCurLuckValue()
    self.luck_count.text = string.format(UIConst.Text.PER_VALUE, cur_luck, self.max_luck)
    self.luck_value.fillAmount = cur_luck / self.max_luck
    local cur_strengthen_num = self.dy_travel_data:GetCurStrengthNum()
    self.rest_panel:SetActive(cur_strengthen_num == 0)
    self.travel_panel:SetActive(cur_strengthen_num > 0)
    if cur_strengthen_num > 0 then
        local max_travel_strength = ComMgrs.dy_data_mgr:ExGetMaxCostValue(self.travel_cost_item)
        self.strengthen_count.text = string.format(UIConst.Text.STRENGTHEN_COUNT, cur_strengthen_num .. "/" .. max_travel_strength)
    else
        local recover_last_time = self.dy_travel_data:GetStrengthenRecoverLastTime()
        self:AddDynamicUI(self.rest_time, function ()
            if (self.strengthen_recover_cd + recover_last_time - Time:GetServerTime()) < 0 then
                self:RemoveDynamicUI(self.rest_time)
            end
            self.rest_time.text = UIFuncs.TimeDelta2Str(self.strengthen_recover_cd + recover_last_time - Time:GetServerTime())
        end, 1, 0)
    end
end

function DirectedTravelUI:InitCityInfo()
    self:ClearEventGo()
    local city_data = SpecMgrs.data_mgr:GetTravelAreaData(self.cur_city)
    UIFuncs.AssignUISpriteSync(city_data.img_res_path, city_data.img_res_name, self.city_img_cmp)
    self.city_name.text = city_data.name
    for _, event_id in ipairs(city_data.event_list) do
        local event = SpecMgrs.data_mgr:GetTravelEventData(event_id)
        local event_go = self:GetUIObject(self.event_item, self.event_content)
        UIFuncs.AssignSpriteByIconID(event.event_icon, event_go:FindChild("EventBg/EventIcon"):GetComponent("Image"))
        event_go:FindChild("EventName"):GetComponent("Text").text = event.event_name
        event_go:FindChild("EventDesc"):GetComponent("Text").text = event.event_content
        local lover_extra_desc = event_go:FindChild("LoverExtraDesc")
        lover_extra_desc:SetActive(event.lover_id ~= nil)
        event_go:GetComponent("Button").interactable = false
        if event.lover_id then
            local unlock_by_meet = SpecMgrs.data_mgr:GetLoverMeetEventList(event.lover_id) ~= nil
            event_go:GetComponent("Button").interactable = unlock_by_meet
            self:AddClick(event_go, function ()
                SpecMgrs.ui_mgr:ShowDateRecord(event.lover_id, self.cur_city)
            end)
            lover_extra_desc:FindChild("MeetText"):SetActive(unlock_by_meet)
            local lover = self.dy_lover_data:GetServLoverDataById(event.lover_id)
            if lover then
                lover_extra_desc:FindChild("Desc"):GetComponent("Text").text = UIConst.Text.ADD_LOVER_EXP
            else
                lover_extra_desc:FindChild("Desc"):GetComponent("Text").text = unlock_by_meet and UIConst.Text.GET_LOVER or "解锁条件"
            end
        end
        table.insert(self.event_go_list, event_go)
    end
end

function DirectedTravelUI:InitBottomPanel()
    local city_data = SpecMgrs.data_mgr:GetTravelAreaData(self.cur_city)
    self.city_distance.text = string.format(UIConst.Text.DISTANCE, city_data.distance)
    self.luck_cost.text = string.format(UIConst.Text.LUCK_COST, self.travel_luck_cost)
    UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetItemData(city_data.assign_consume_item).icon, self.cost_icon)
    self.cost_count.text = city_data.assign_consume_item_count
end

function DirectedTravelUI:SendDirectTravel()
    if self.dy_travel_data:GetDirectedTravelCount() == 0 then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.ASSIGN_TRAVEL_FAILED)
        return
    end
    if self.dy_travel_data:GetCurLuckValue() < self.travel_luck_cost then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.WITHOUT_LUCK)
        return
    end
    local city_data = SpecMgrs.data_mgr:GetTravelAreaData(self.cur_city)
    local cost_item_data = SpecMgrs.data_mgr:GetItemData(city_data.assign_consume_item)
    SpecMgrs.ui_mgr:ShowItemUseRemindByTb({
        item_id = city_data.assign_consume_item,
        need_count = city_data.assign_consume_item_count,
        confirm_cb = function ()
            SpecMgrs.msg_mgr:SendAssignTravel({area_id = self.cur_city}, function (resp)
                if resp.errcode ~= 0 then
                    SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.ASSIGN_TRAVEL_FAILED)
                else
                    SpecMgrs.ui_mgr:ShowTravelEvent(resp)
                end
            end)
        end,
        desc = string.format(UIConst.Text.ASSIGN_TRAVEL_REMIND_TIP, cost_item_data.name, city_data.assign_consume_item_count, city_data.name),
        remind_tag = "DirectTravel",
        is_show_tip = true,
    })
end

function DirectedTravelUI:ClearEventGo()
    for _, event_go in ipairs(self.event_go_list) do
        self:DelUIObject(event_go)
    end
    self.event_go_list = {}
end

return DirectedTravelUI