local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local CSConst = require("CSCommon.CSConst")
local FestivalActivityUI = class("UI.LimitTimeActivity.FestivalActivityUI")

local kSliderToNextFactor = 0.1
local kSliderTime = 0.2

--  循环节日活动
function FestivalActivityUI:InitRes(owner)
    self.owner = owner
    self.festival_activity_frame = self.owner.main_panel:FindChild("FestivalActivityFrame")
    self.bg = self.owner.main_panel:FindChild("FestivalActivityFrame/Bg"):GetComponent("Image")
    self.unit_point = self.owner.main_panel:FindChild("FestivalActivityFrame/UnitPoint")
    self.option_list = self.owner.main_panel:FindChild("FestivalActivityFrame/OptionList")
    self.option = self.owner.main_panel:FindChild("FestivalActivityFrame/OptionList/Option")
    self.reward_list = self.owner.main_panel:FindChild("FestivalActivityFrame/RewardMes/ViewPort/RewardList")
    self.reward_list_rect = self.reward_list:GetComponent("RectTransform")
    self.reward_mes = self.owner.main_panel:FindChild("FestivalActivityFrame/RewardMes/ViewPort/RewardList/RewardMes")
    self.shopping_item = self.owner.main_panel:FindChild("FestivalActivityFrame/RewardMes/ViewPort/RewardList/ShoppingItem")
    self.help_btn = self.owner.main_panel:FindChild("FestivalActivityFrame/HelpBtn")
    self.owner:AddClick(self.help_btn, function()
        UIFuncs.ShowPanelHelp("FestivalActivityUI")
    end)
    self.buy_gift_btn = self.owner.main_panel:FindChild("FestivalActivityFrame/BuyGiftBtn")
    self.owner:AddClick(self.buy_gift_btn, function()
        self.owner:Show(self.turn_exchange_id)
    end)
    self.unit_rect = self.owner.main_panel:FindChild("FestivalActivityFrame/UnitRect")
    self.content = self.owner.main_panel:FindChild("FestivalActivityFrame/ScrollRect/ViewPort/Content")
    self.image_temp = self.owner.main_panel:FindChild("FestivalActivityFrame/ScrollRect/ViewPort/Content/Temp")

    self.title_scroll_rect = self.owner.main_panel:FindChild("FestivalActivityFrame/ScrollRect"):GetComponent("ScrollRect")

    self.drag_area = self.owner.main_panel:FindChild("FestivalActivityFrame/DragArea")
    self.select_tip_list = self.owner.main_panel:FindChild("FestivalActivityFrame/SelectTipList")
    self.tip = self.owner.main_panel:FindChild("FestivalActivityFrame/SelectTipList/tip")
    self.last_time_text = self.owner.main_panel:FindChild("FestivalActivityFrame/LastTimeText"):GetComponent("Text")

    self.owner:AddDrag(self.drag_area, function(delta, position)
        self:OnDrag(delta, position)
    end)

    self.owner:AddRelease(self.drag_area, function ()
        self:OnRelease()
    end)

    self:SetTextVal()

    self.option:SetActive(false)
    self.option:FindChild("Tip"):SetActive(false)

    self.tag_key = {
        "welfare",
        "celebration",
        "activity",
    }

    self.festival_activity_frame:SetActive(false)
    self.shopping_item:SetActive(false)
    self.reward_mes:SetActive(false)
    self.image_temp:SetActive(false)
    self.title_width = self.image_temp:GetComponent("RectTransform").sizeDelta.x
    self.title_point_list = self.owner.main_panel:FindChild("FestivalActivityFrame/TitlePointList")
    self.title_point = self.owner.main_panel:FindChild("FestivalActivityFrame/TitlePointList/Select")
    self.title_point:SetActive(false)
end

function FestivalActivityUI:Show(activity_data)
    self.owner:DelObjDict(self.create_obj_list)
    self.create_obj_list = {}
    self.owner:DestroyAllUnit()
    self.cur_tag_create_list = {}
    self.seat_to_pos = {}
    self.create_effect_list = {}
    self.festival_activity_frame:SetActive(true)
    self.festival_group_id = activity_data.festival_activity
    self.turn_exchange_id = activity_data.turn_activity

    self.slider_timer = 0
    self.show_unit = nil
    self.cur_seat_index = self:GetCurActivityIndex()
    self.last_seat_index = self.cur_seat_index
    self:UpdateData()
    self:InitTitleList()
    self:UpdateUIInfo()
    self:ImmediateSliderToIndex(self.cur_seat_index)
    ComMgrs.dy_data_mgr.festival_activity_data:RegisterUpdateFestivalActivityData("FestivalActivityUI", function()
        self.option_selector:ReselectSelectObj()
    end, self)
end

function FestivalActivityUI:InitTitleList()
    local title_point_list = {}

    for i,v in ipairs(self.festival_data_list) do
        local image = self.owner:GetUIObject(self.image_temp, self.content)
        image:FindChild("Text"):GetComponent("Text").text = v.title
        local point = self.owner:GetUIObject(self.title_point, self.title_point_list)
        table.insert(self.create_obj_list, point)
        table.insert(title_point_list, point)
        table.insert(self.create_obj_list, image)
    end
    self.viewport_width = self.content:GetComponent("RectTransform").sizeDelta.x

    for seat_index = 1, #self.festival_data_list do
        if #self.festival_data_list == 1 then
            self.seat_to_pos[seat_index] = 1
        else
            self.seat_to_pos[seat_index] = (seat_index - 1) / (#self.festival_data_list - 1)
        end
    end
    self.title_point_selector = UIFuncs.CreateSelector(self.owner, title_point_list, nil)
    self.title_point_selector:SelectObj(self.cur_seat_index)
    if #self.festival_data_list <= 1 then
        self.title_point_list:SetActive(false)
    else
        self.title_point_list:SetActive(true)
    end
end

function FestivalActivityUI:GetCurActivityIndex()
    local festival_data_list = ComMgrs.dy_data_mgr.festival_activity_data:GetPastFestivalActivityList(self.festival_group_id)
    local select_festival_data = ComMgrs.dy_data_mgr.festival_activity_data:GetCurFestivalActivity(self.festival_group_id)
    if select_festival_data == nil then
        return #festival_data_list
    else
        return table.index(festival_data_list, select_festival_data)
    end
end

function FestivalActivityUI:Update(delta_time)
    if self.slider_target_pos then
        self.slider_timer = self.slider_timer + delta_time
        local cur_pos
        if self.slider_timer >= kSliderTime then
            self.slider_timer = 0
            cur_pos = self.slider_target_pos
            self.slider_target_pos = nil
            self.title_rect_original_pos = nil
            self.is_drag_hero_slider = false
            if self.last_seat_index ~= self.cur_seat_index then
                self:UpdateData()
                self:UpdateUIInfo()
            end
            self.last_seat_index = self.cur_seat_index
            self.title_point_selector:SelectObj(self.cur_seat_index)
        else
            self.is_drag_hero_slider = true
            cur_pos = math.lerp(self.title_rect_original_pos, self.slider_target_pos, self.slider_timer / kSliderTime)
        end
        self.title_scroll_rect.horizontalNormalizedPosition = cur_pos
    end
end

function FestivalActivityUI:OnDrag(delta, position)
    self.slider_x_offset = self.slider_x_offset + delta.x
    local norimalize_pos = self.title_scroll_rect.horizontalNormalizedPosition - delta.x / self.viewport_width
    self.title_scroll_rect.horizontalNormalizedPosition = math.clamp(norimalize_pos, 0, 1)
    self.is_drag_hero_slider = true
end

function FestivalActivityUI:OnRelease()
    if math.abs(self.slider_x_offset) >= self.title_width * kSliderToNextFactor then
        local index = self.slider_x_offset > 0 and self.cur_seat_index - 1 or self.cur_seat_index + 1
        index = math.clamp(index, 1, #self.festival_data_list)
        self:SliderToIndex(index)
    else
        self:SliderToIndex(self.cur_seat_index)
    end
    self.slider_x_offset = 0
end

function FestivalActivityUI:SliderToIndex(index)
    self.cur_seat_index = index
    self.slider_target_pos = self.seat_to_pos[index]
    self.title_rect_original_pos = self.title_scroll_rect.horizontalNormalizedPosition
end

function FestivalActivityUI:ImmediateSliderToIndex(index)
    self.cur_seat_index = index
    self.title_scroll_rect.horizontalNormalizedPosition = self.seat_to_pos[index]
end

function FestivalActivityUI:SetTextVal()
    self.shopping_item:FindChild("BuyButton/BuyButtonText"):GetComponent("Text").text = UIConst.Text.BUY_TEXT
    self.help_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ACTIVITY_HELP_TEXT
    self.buy_gift_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.GIFT_EXCHANGE
end

function FestivalActivityUI:UpdateData()
    self.festival_group_data = SpecMgrs.data_mgr:GetFestivalGroupData(self.festival_group_id)
    self.festival_data_list = ComMgrs.dy_data_mgr.festival_activity_data:GetPastFestivalActivityList(self.festival_group_id)
    self.select_festival_data = self.festival_data_list[self.cur_seat_index]
    self.festival_info = ComMgrs.dy_data_mgr.festival_activity_data.festival_data_dict[self.select_festival_data.id]
    self.cur_festival_data = ComMgrs.dy_data_mgr.festival_activity_data:GetCurFestivalActivity(self.festival_group_id)
    self.slider_x_offset = 0
end

function FestivalActivityUI:UpdateUIInfo()
    self.owner:DelObjDict(self.create_option_list)
    self.create_option_list = {}
    for i,v in ipairs(self.select_festival_data.tag_list) do
        local item = self.owner:GetUIObject(self.option, self.option_list)
        item:FindChild("Text"):GetComponent("Text").text = v
        table.insert(self.create_obj_list, item)
        table.insert(self.create_option_list, item)
    end
    self:UpdateOptionRedPoint()
    self.option_selector = UIFuncs.CreateSelector(self.owner, self.create_option_list, function(index)
        self:SelectTag(index)
    end)
    self.option_selector:SelectObj(1)
    local start_time = self:GetActivityStartEndTime(self.select_festival_data.id)
    local end_date = UIFuncs.GetMonthDate(start_time + (self.festival_group_data.activity_duration - 1) * CSConst.Time.Day)
    self.last_time_text.text = string.format(UIConst.Text.RANK_ACTIVITY_TIME_FORMAT, UIFuncs.GetMonthDate(start_time), end_date)
    UIFuncs.AssignSpriteByIconID(self.select_festival_data.bg, self.bg)
end

function FestivalActivityUI:UpdateOptionRedPoint()
    for i, item in ipairs(self.create_option_list) do
        if i ~= #self.select_festival_data.tag_list then
            local key = self.tag_key[i]
            local content_list = self.select_festival_data[key]
            local have_red_point = ComMgrs.dy_data_mgr.festival_activity_data:CheckTagCanReward(self.select_festival_data.id, content_list)
            item:FindChild("Tip"):SetActive(have_red_point)
        else
            item:FindChild("Tip"):SetActive(false)
        end
    end
end

function FestivalActivityUI:SelectTag(index)
    if not self.show_unit or self.show_unit.unit_id ~= self.select_festival_data.show_unit then
        if self.show_unit then
            self.owner:RemoveUnit(self.show_unit)
        end
        self.show_unit = self.owner:AddHalfUnit(self.select_festival_data.show_unit, self.unit_rect)

    end
    self.owner:RemoveEffectList(self.create_effect_list)
    self.create_effect_list = {}
    self.owner:DelObjDict(self.cur_tag_create_list)
    self.cur_tag_create_list = {}
    if index == #self.select_festival_data.tag_list then
        self:CreateBuyList()
    else
        local key = self.tag_key[index]
        local content_list = self.select_festival_data[key]

        local content_data_list = {}
        for i,v in ipairs(content_list) do
            local content_data = SpecMgrs.data_mgr:GetFestivalContentData(v)
            for i,v in ipairs(content_data.reward_list) do
                table.insert(content_data_list, {data = content_data, index = i})
            end
        end
        self:SortContentDataList(content_data_list)
        for i,v in ipairs(content_data_list) do
            self:CreateContentItem(v.data, v.index)
        end
    end

    if self.cur_tag_index ~= index then
        self.reward_list_rect.anchoredPosition = Vector2.New(0, 0)
    end
    self.cur_tag_index = index
    self:UpdateOptionRedPoint()
end

function FestivalActivityUI:SortContentDataList(content_data_list)
    table.sort(content_data_list, function(a, b)
        local a_reward_state = self.festival_info.reward_dict[a.data.reward_list[a.index]]
        local b_reward_state = self.festival_info.reward_dict[b.data.reward_list[b.index]]

        local a_priority = self:GetPriority(a_reward_state)
        local b_priority = self:GetPriority(b_reward_state)

        if a_priority ~= b_priority then
            return a_priority > b_priority
        end
        if a.data.id ~= b.data.id then
            return a.data.id < b.data.id
        end
        return a.index < b.index
    end)
end

function FestivalActivityUI:GetPriority(reward_state)
    if reward_state == CSConst.RewardState.pick then
        return 3
    elseif reward_state == CSConst.RewardState.unpick then
        return 2
    else
        return 1
    end
end

function FestivalActivityUI:CreateBuyList()
    for i, v in ipairs(self.select_festival_data.discount) do
        local can_buy_time = self.festival_info.discount_dict[v]
        local buy_data = SpecMgrs.data_mgr:GetFestivalDiscountData(v)
        local item = self.owner:GetUIObject(self.shopping_item, self.reward_list)
        local item_data = SpecMgrs.data_mgr:GetItemData(buy_data.sell_item_id)
        local create_item = UIFuncs.SetItem(self.owner, buy_data.sell_item_id, buy_data.sell_item_num, item:FindChild("RewardItem"))

        item:FindChild("ItemNameText"):GetComponent("Text").text = item_data.name
        local icon_id = SpecMgrs.data_mgr:GetItemData(buy_data.cost_item_id).icon
        local str = string.format(UIConst.Text.ITEM_ICON_NUM_FORMAT, icon_id, buy_data.cost_item_num)
        self.owner:SetTextPic(item:FindChild("PriceList/Text"), str)
        UIFuncs.SetButtonCanClick(item:FindChild("BuyButton"), can_buy_time ~= 0)
        item:FindChild("LimitBuyText"):GetComponent("Text").text = string.format(UIConst.Text.CUR_BUY_LIMIT_FORMAT, can_buy_time)
        self.owner:AddClick(item:FindChild("BuyButton"), function()
            local start_time, end_time = self:GetActivityStartEndTime(self.select_festival_data.id)
            if Time:GetServerTime() > end_time or self.festival_info.state ~= CSConst.ActivityState.started then
                SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.ACTIVITY_EXPIRED)
                return
            end
            local cb = function(buy_num)
                self:BuyDiscountItem(item, buy_data, buy_num)
            end
            local price_list = {{item_id = buy_data.cost_item_id, count = buy_data.cost_item_num}}
            UIFuncs.ShowBuyShopItemUI(buy_data.sell_item_id, buy_data.sell_item_num, self.festival_info.discount_dict[v], price_list, cb)
        end)

        table.insert(self.cur_tag_create_list, item)
        table.insert(self.cur_tag_create_list, create_item)
        table.insert(self.create_obj_list, item)
        table.insert(self.create_obj_list, create_item)
    end
end

function FestivalActivityUI:BuyDiscountItem(item, buy_data, buy_time)
    SpecMgrs.msg_mgr:SendBuyFestivalActivityDiscount({discount_id = buy_data.id, discount_cnt = buy_time})
end

function FestivalActivityUI:CreateContentItem(content_data, index)
    local item = self.owner:GetUIObject(self.reward_mes, self.reward_list)
    local last_time_text = item:FindChild("LastTimeText")
    last_time_text:SetActive(false)
    local str
    if content_data.type_id == CSConst.FestivalActivityType.login then
        local start_time = self:GetActivityStartEndTime(self.select_festival_data.id)
        local condition_val = content_data.condition_list[index]
        str = string.format(content_data.desc, UIFuncs.GetMonthDate(start_time + (condition_val - 1) * CSConst.Time.Day))
    elseif content_data.type_id == CSConst.FestivalActivityType.recharge then
        local recharge_id = content_data.recharge_ids[index]
        local recharge_val = SpecMgrs.data_mgr:GetRechargeData(recharge_id).recharge_count
        str = string.format(content_data.desc, recharge_val)
        local max_recharge_time = content_data.recharge_times[index]
        local last_recharge_time = self.festival_info.recharge_dict[recharge_id]
        last_time_text:SetActive(true)
        last_time_text:GetComponent("Text").text = string.format(UIConst.Text.OVERPLUS_BUY_TIMR_FORMAT, last_recharge_time, max_recharge_time)
    else
        local condition_val = content_data.condition_list[index]
        str = string.format(content_data.desc, condition_val)
        if content_data.type_id ~= CSConst.FestivalActivityType.recharge then
            str = str .. string.format(UIConst.Text.SPRITE_WITH_BRACKET, self.festival_info.progress_dict[content_data.type_id], condition_val)
        end
    end
    item:FindChild("TaskProgressText"):GetComponent("Text").text = str
    local check_btn = item:FindChild("CheckBtn")
    local alraedy_receive = item:FindChild("AlreadyReceived")
    local alraedy_receive_text = item:FindChild("AlreadyReceived/AlreadyReceivedText"):GetComponent("Text")
    local check_btn_text = item:FindChild("CheckBtn/Text"):GetComponent("Text")
    check_btn:SetActive(false)
    alraedy_receive:SetActive(false)
    local state = self.festival_info.reward_dict[content_data.reward_list[index]]

    if self.cur_festival_data ~= self.select_festival_data or self.festival_info.state ~= CSConst.ActivityState.started then
        if state == CSConst.RewardState.picked then
            alraedy_receive:SetActive(true)
            alraedy_receive_text.text = UIConst.Text.ALREADY_RECEIVE_TEXT
        else
            alraedy_receive:SetActive(true)
            alraedy_receive_text.text = UIConst.Text.ALREADY_OVERDUE_TEXT
        end
    else
        alraedy_receive_text.text = UIConst.Text.ALREADY_RECEIVE_TEXT
        if state == CSConst.RewardState.pick then
            check_btn:SetActive(true)
            check_btn_text.text = UIConst.Text.RECEIVE_TEXT
            self.owner:AddClick(check_btn, function()
                self:ReciveReward(content_data.reward_list[index])
            end)
            local effect = UIFuncs.AddCompleteEffect(self.owner, check_btn)
            table.insert(self.create_effect_list, effect)
        elseif state == CSConst.RewardState.unpick then
            if content_data.type_id ~= CSConst.FestivalActivityType.login then
                check_btn:SetActive(true)
                check_btn_text.text = UIConst.Text.GOTO_TEXT
                self.owner:AddClick(check_btn, function()
                    SpecMgrs.ui_mgr:JumpUI(content_data.goto_ui)
                end)
            end
        elseif state == CSConst.RewardState.picked then
            alraedy_receive:SetActive(true)
            check_btn_text.text = UIConst.Text.ALREADY_RECEIVE_TEXT
        end
    end

    table.insert(self.cur_tag_create_list, item)
    table.insert(self.create_obj_list, item)

    local reward_data = SpecMgrs.data_mgr:GetFestivalRewardData(content_data.reward_list[index])
    local role_item_list = UIFuncs.GetRoleItemList(reward_data.reward_item_list, reward_data.reward_num_list)
    local item_list = UIFuncs.SetItemList(self.owner, role_item_list, item:FindChild("RewardItemList"))
    table.mergeList(self.cur_tag_create_list, item_list)
    table.mergeList(self.create_obj_list, item_list)
end

function FestivalActivityUI:ReciveReward(reward_id)
    local cb = function(resp)
        self:UpdateData()
        if not self.owner.is_res_ok then return end
        --self:UpdateOptionRedPoint()
    end
    SpecMgrs.msg_mgr:SendPickFestivalActivity({reward_id = reward_id}, cb)
end

function FestivalActivityUI:GetActivityStartEndTime(id)
    local index = table.index(self.festival_group_data.activity_list, id)
    return ComMgrs.dy_data_mgr.festival_activity_data:GetActivityLastTime(self.festival_group_id, index)
end

function FestivalActivityUI:Hide()
    self.owner:DelObjDict(self.create_obj_list)
    self.owner:DestroyAllUnit()
    self.owner:RemoveEffectList(self.create_effect_list)
    ComMgrs.dy_data_mgr.festival_activity_data:UnregisterUpdateFestivalActivityData("FestivalActivityUI")
    self.festival_activity_frame:SetActive(false)
end

return FestivalActivityUI
