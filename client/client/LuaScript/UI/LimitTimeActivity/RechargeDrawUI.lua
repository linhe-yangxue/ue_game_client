local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local ItemUtil = require("BaseUtilities.ItemUtil")
local EffectConst = require("Effect.EffectConst")
local CSConst = require("CSCommon.CSConst")
local RechargeDrawUI = class("UI.LimitTimeActivity.RechargeDrawUI")

local speed_up_max_interval = 0.4
local speed_up_min_interval = 0.04

local slow_max_interval = 0.4
local slow_min_interval = 0.1

local turn_speed_time = 2
local turn_circle = 3
local slow_dis = 5
local slow_time = 1

local stay_time = 1

local ten_draw_index_list = {1, 3, 5, 7, 9, 11}

local refresh_award_info_time = 2
local max_show_reward_count = 8
local draw_time = 10

--  充值抽奖
function RechargeDrawUI:InitRes(owner)
    self.owner = owner
    self.luck_draw_frame = self.owner.main_panel:FindChild("LuckDrawFrame")
    self.activity_time_text = self.owner.main_panel:FindChild("LuckDrawFrame/ActivityTimeText"):GetComponent("Text")
    self.recharge_tip_text = self.owner.main_panel:FindChild("LuckDrawFrame/RechargeTipText"):GetComponent("Text")
    self.slider = self.owner.main_panel:FindChild("LuckDrawFrame/RechargeSlider/Slider"):GetComponent("Image")
    self.recharge_draw_time_tip = self.owner.main_panel:FindChild("LuckDrawFrame/RechargeDrawTimeTip"):GetComponent("Text")
    self.prize_list = self.owner.main_panel:FindChild("LuckDrawFrame/Turntable/PrizeList")
    self.luck_draw_text = self.owner.main_panel:FindChild("LuckDrawFrame/Turntable/LuckDrawText"):GetComponent("Text")
    self.last_time_text = self.owner.main_panel:FindChild("LuckDrawFrame/Turntable/LastTimeText"):GetComponent("Text")
    self.toggle = self.owner.main_panel:FindChild("LuckDrawFrame/Turntable/TenDraw/Toggle"):GetComponent("Toggle")
    self.ten_draw_text = self.owner.main_panel:FindChild("LuckDrawFrame/Turntable/TenDraw/Toggle/TenDrawText"):GetComponent("Text")
    self.cur_integral_text = self.owner.main_panel:FindChild("LuckDrawFrame/CurIntegralText"):GetComponent("Text")
    self.exchange_tip_text = self.owner.main_panel:FindChild("LuckDrawFrame/ExchangeTipText"):GetComponent("Text")
    self.draw_btn = self.owner.main_panel:FindChild("LuckDrawFrame/Turntable/DrawBtn")

    self.draw_prize_list = self.owner.main_panel:FindChild("LuckDrawFrame/DrawPrizeList/ViewPort/Content")
    self.temp_text = self.owner.main_panel:FindChild("LuckDrawFrame/DrawPrizeList/ViewPort/Content/Text")

    self.mask = self.owner.main_panel:FindChild("Mask")
    self.owner:AddClick(self.draw_btn, function()
        if self:CheckEnd() then return end
        self:ClickDrawBtn()
    end)
    self.shop_btn = self.owner.main_panel:FindChild("LuckDrawFrame/ShopBtn")
    self.owner:AddClick(self.shop_btn, function()
        if self:CheckEnd() then return end
        SpecMgrs.ui_mgr:ShowUI("ShoppingUI", UIConst.ShopList.DrawShop)
    end)
    self.prize_record = self.owner.main_panel:FindChild("LuckDrawFrame/PrizeRecord")
    self.owner:AddClick(self.prize_record, function()
        if self:CheckEnd() then return end
        self:ShowRewardRecordFrame()
    end)
    self.recharge_btn = self.owner.main_panel:FindChild("LuckDrawFrame/RechargeBtn")
    self.owner:AddClick(self.recharge_btn, function()
        if self:CheckEnd() then return end
        SpecMgrs.ui_mgr:ShowUI("RechargeUI")
    end)

    self.reward_record_frame = self.owner.main_panel:FindChild("RewardRecordFrame")
    self.reward_record_frame_title = self.owner.main_panel:FindChild("RewardRecordFrame/Frame/TitleText"):GetComponent("Text")
    self.reward_record_frame_content = self.owner.main_panel:FindChild("RewardRecordFrame/Frame/Content")
    self.reward_record_frame_mes = self.owner.main_panel:FindChild("RewardRecordFrame/Frame/Content/Mes")
    self.reward_record_frame_close_btn =  self.owner.main_panel:FindChild("RewardRecordFrame/Frame/CloseBtn")
    self.owner:AddClick(self.reward_record_frame_close_btn, function()
        self:HideRewardRecordFrame()
    end)

    self.desc_text = self.owner.main_panel:FindChild("LuckDrawFrame/Text"):GetComponent("Text")

    self.prize_obj_list = {}
    self.luck_draw_frame:SetActive(false)
    self.temp_text:SetActive(false)
    self.mask:SetActive(false)
    self.reward_record_frame:SetActive(false)
    self.reward_record_frame_mes:SetActive(false)
    for i = 1, self.prize_list.childCount do
        table.insert(self.prize_obj_list, self.prize_list:GetChild(i - 1))
    end
    self:SetTextVal()
end

function RechargeDrawUI:Show(data)
    self.owner:DelObjDict(self.create_obj_list)
    self.owner:RemoveAllUIEffect()
    self.lottery_sound = SpecMgrs.data_mgr:GetParamData("lottery_sound").sound_id
    self.create_obj_list = {}
    self.reward_item_list = {}
    self.create_effect_list = {}
    self.create_str_list = {}
    self.reward_record_obj_list = {}
    self.reward_item_list = {}
    self.refresh_reward_timer = refresh_award_info_time
    self.luck_draw_frame:SetActive(true)
    self.recharge_activity_id = data.recharge_activity
    self.activity_name = data.activity_name
    self:UpdateData()
    self:UpdateUIInfo()
    ComMgrs.dy_data_mgr.recharge_data:RegisterUpdateRechargeDrawInfo("RechargeDrawUI", function()
        if self.is_draw then return end
        self:RefleshUI()
    end, self)
    self.draw_prize_list:GetComponent("RectTransform").anchoredPosition = Vector2.zero
end

function RechargeDrawUI:Update(delta_time)
    self:UpdateRefleshRechargeDrawInfo(delta_time)
    self:UpdateCountDownText()
    if not self.max_turn_count then return end
    self.timer = self.timer + delta_time
    self.turn_timer = self.turn_timer + delta_time

    local interval
    if (self.max_turn_count - self.cur_turn_count) <= slow_dis then
        self.slow_timer = self.slow_timer + delta_time
        interval = tween.easing.linear(self.slow_timer, slow_min_interval, slow_max_interval - slow_min_interval, slow_time)
    else
        if self.timer > turn_speed_time then
            interval = speed_up_min_interval
        else
            interval = tween.easing.linear(self.timer, speed_up_max_interval, speed_up_min_interval - speed_up_max_interval, turn_speed_time)
        end
    end
    if self.turn_timer > interval then
        self.turn_timer = 0
        for i,v in ipairs(self.start_turn_index_list) do
            local cur_trun_index = self.start_turn_index_list[i] + 1
            if cur_trun_index > #self.prize_data_list then
                cur_trun_index = 1
            end
            self.start_turn_index_list[i] = cur_trun_index
            self:CreateTurnEffect(self.reward_item_list[cur_trun_index], i)
        end
        self.cur_turn_count = self.cur_turn_count + 1
        if self.cur_turn_count == self.max_turn_count then
            SpecMgrs.ui_mgr:SetShowAddItemList(true)
            self:ResetAnim()
            self.owner:AddTimer(function()
                self.is_draw = false
                self:RefleshUI()
                SpecMgrs.ui_mgr:ShowGetItemUI(self.draw_reward_list)
            end, stay_time, 1)
        end
    end
end

function RechargeDrawUI:UpdateCountDownText()
    local start_date = UIFuncs.GetMonthDate(self.activity_data.activity_start_timestamp)
    local end_date = UIFuncs.GetMonthDate(self.activity_data.activity_end_timestamp)

    local ts = self.activity_data.activity_end_timestamp - Time:GetServerTime()
    if ts <= 0 then
        self.activity_time_text.text = UIConst.Text.ACTIVETY_FINISH_FORMAT
    else
        if ts >= CSConst.Time.Day then
            local day = math.floor(ts / CSConst.Time.Day)
            self.activity_time_text.text = string.format(UIConst.Text.ACTIVETY_LASTTIME_FORMAT, start_date, end_date, day)
        else
            local count_down = TimeDelta2Table(ts, 3)
            self.activity_time_text.text = string.format(UIConst.Text.ACTIVETY_LASTTIME_COUNTDOWN_FORMAT, start_date, end_date, count_down)
        end
    end
end

function RechargeDrawUI:RefleshUI()
    self.owner:RemoveAllUIEffect()
    self.mask:SetActive(false)
    self:UpdateData()
    self:UpdateUIInfo()
    --self:UpdateRechargeDrawInfo()
end

function RechargeDrawUI:SetTextVal()
    self.exchange_tip_text.text = UIConst.Text.RECHARGE_DRAW_EXCHANGE_TIP
    self.shop_btn:FindChild("Text"):GetComponent("Text").text = UIFuncs.GetShopNameByShopType(UIConst.ShopList.DrawShop)
    self.recharge_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.RECHARGE
    self.prize_record:FindChild("Text"):GetComponent("Text").text = UIConst.Text.RECHARGE_PRIZE_TEXT
    self.ten_draw_text.text = UIConst.Text.RECHARGE_TEN_DRAW_TIP
    self.luck_draw_text.text = UIConst.Text.RECHARGE_DRAW_TEXT
    self.reward_record_frame_title.text = UIConst.Text.RECHARGE_PRIZE_TEXT
end

function RechargeDrawUI:UpdateData()
    self:ResetAnim()
    self.activity_data = SpecMgrs.data_mgr:GetRechargeActivityData(self.recharge_activity_id)
    self.draw_info = ComMgrs.dy_data_mgr.recharge_data.recharge_draw_info
    self.prize_data_list = self.draw_info.award_list
    self.desc_text.text = UIFuncs.MergeStrList(self.activity_data.desc)
end

function RechargeDrawUI:ResetAnim()
    self.max_turn_count = nil
    self.cur_turn_count = 0
    self.timer = 0
    self.slow_timer = 0
    self.turn_timer = 0
    self.turn_count = nil

    self.start_turn_index_list = {}
end

function RechargeDrawUI:UpdateUIInfo()
    self.owner:DelObjDict(self.reward_item_list)
    self.reward_item_list = {}
    for i, v in ipairs(self.prize_data_list) do
        local data = SpecMgrs.data_mgr:GetRechargeDrawData(v)
        local item = UIFuncs.SetItem(self.owner, data.item_id, data.item_count, self.prize_obj_list[i])
        table.insert(self.create_obj_list, item)
        table.insert(self.reward_item_list, item)
    end

    self.recharge_tip_text.text = string.format(UIConst.Text.RECHARGE_DRAW_TIP, self.draw_info.draw_need_count)
    self.recharge_draw_time_tip.text = string.format(UIConst.Text.RECHARGE_NEXT_DRAW_TIP, self.draw_info.next_draw_need_count)

    local score = ItemUtil.GetItemNum(CSConst.Virtual.RechargeDrawIntegral)
    self.cur_integral_text.text = string.format(UIConst.Text.RECHARGE_DRAW_SCORE_FORMAT, score)
    self.last_time_text.text = string.format(UIConst.Text.RECHARGE_DRAW_LAST_TIME_FORMAT, self.draw_info.draw_count)
    self.slider.fillAmount = (self.draw_info.draw_need_count - self.draw_info.next_draw_need_count)/self.draw_info.draw_need_count
    self.shop_btn:FindChild("Tip"):SetActive(ComMgrs.dy_data_mgr.recharge_data:CheckCanBuyRechargeDraw())
end

function RechargeDrawUI:ClickDrawBtn()
    if self.draw_info.draw_count == 0 then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.CANNOT_DRAW_TIP)
        return
    end
    if self.is_draw then return end
    local is_ten_draw = self.toggle.isOn
    if self.draw_info.draw_count == 1 then
        is_ten_draw = false
    end
    self.mask:SetActive(true)
    self.is_draw = true
    SpecMgrs.ui_mgr:SetShowAddItemList(false)
    local count
    if self.toggle.isOn then
        count = self.draw_info.draw_count - draw_time
    else
        count = self.draw_info.draw_count - 1
    end
    if count < 0 then count = 0 end
    self.last_time_text.text = string.format(UIConst.Text.RECHARGE_DRAW_LAST_TIME_FORMAT, count)
    local cb = function(resp)
        if not self.owner.is_res_ok then return end
        self.create_effect_list = {}
        if is_ten_draw then
            self.max_turn_count = turn_circle * #self.prize_data_list
            self.start_turn_index_list = table.shallowcopy(ten_draw_index_list)
            self.cur_turn_count = 1
            for i,v in ipairs(self.start_turn_index_list) do
                self:CreateTurnEffect(self.reward_item_list[v], i)
            end
        else
            self.target_index = table.index(self.prize_data_list, resp.award_list[1])
            self.max_turn_count = turn_circle * #self.prize_data_list + self.target_index
            table.insert(self.start_turn_index_list, 1)
            self.cur_turn_count = 1
            self:CreateTurnEffect(self.reward_item_list[1], 1)
        end
        self.owner:PlayUISound(self.lottery_sound)
        self.draw_reward_list = {}
        for i,v in ipairs(resp.award_list) do
            local data = SpecMgrs.data_mgr:GetRechargeDrawData(v)
            table.insert(self.draw_reward_list, {item_id = data.item_id, count = data.item_count})
        end
    end
    SpecMgrs.msg_mgr:SendDoRechargeDraw({activity_id = self.recharge_activity_id, is_ten_draw = is_ten_draw}, cb)
end

function RechargeDrawUI:CreateTurnEffect(item, index)
    if self.create_effect_list[index] then
        self.owner:RemoveUIEffect(self.create_effect_list[index])
    end
    local glod_circle_effect = UIFuncs.AddGlodCircleEffect(self.owner, item)
    self.create_effect_list[index] = item
end

function RechargeDrawUI:UpdateRefleshRechargeDrawInfo(delta_time)
    if not self.refresh_reward_timer then return end
    self.refresh_reward_timer = self.refresh_reward_timer + delta_time
    if self.refresh_reward_timer > refresh_award_info_time then
        self.refresh_reward_timer = nil
        self:UpdateRechargeDrawInfo()
    end
end

function RechargeDrawUI:UpdateRechargeDrawInfo()
    local cb = function(resp)
        if not self.owner.is_res_ok then return end
        self.owner:DelObjDict(self.create_str_list)
        self.create_str_list = {}
        for i, award_info in ipairs(resp.award_list) do
            local text = self.owner:GetUIObject(self.temp_text, self.draw_prize_list)
            local str = self:GetRewardStr(award_info.award_id)
            table.insert(self.create_str_list, text)
            table.insert(self.create_obj_list, text)
            text:GetComponent("Text").text = string.format(UIConst.Text.RECHARGE_AWARD_TIP, award_info.user_name, self.activity_name, str)
        end
        self.refresh_reward_timer = 0
    end
    SpecMgrs.msg_mgr:SendGetRechargeDrawAwardInfo({activity_id = self.recharge_activity_id}, cb)
end

function RechargeDrawUI:GetRewardStr(recharge_draw_id)
    local draw_data = SpecMgrs.data_mgr:GetRechargeDrawData(recharge_draw_id)
    local item_data = SpecMgrs.data_mgr:GetItemData(draw_data.item_id)
    return string.format(UIConst.Text.ITEM_NUM_FORMAT, item_data.name, draw_data.item_count)
end

function RechargeDrawUI:ShowRewardRecordFrame()
    self.reward_record_frame:SetActive(true)
    self.owner:DelObjDict(self.reward_record_obj_list)
    self.reward_record_obj_list = {}
    for i, award_info in ipairs(self.draw_info.self_award_list) do
        if i > max_show_reward_count then
            return
        end
        local item = self.owner:GetUIObject(self.reward_record_frame_mes, self.reward_record_frame_content)
        item:FindChild("NameText"):GetComponent("Text").text = UIConst.Text.CONGRATULATION_TEXT
        item:FindChild("GetRewardText"):GetComponent("Text").text = string.format(UIConst.Text.GET_ACTIVETY_REWARD_FORMAT, self.activity_name, self:GetRewardStr(award_info.award_id))
        local date = os.date(UIConst.Text.DRAW_REWARD_DATE_FORMAT, award_info.time)
        item:FindChild("TimeText"):GetComponent("Text").text = date
        table.insert(self.reward_record_obj_list, item)
    end
end

function RechargeDrawUI:CheckEnd()
    if Time:GetServerTime() > self.activity_data.activity_end_timestamp then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.ACTIVETY_FINISH_FORMAT)
        return true
    end
    return false
end

function RechargeDrawUI:HideRewardRecordFrame()
    self.reward_record_frame:SetActive(false)
    self.owner:DelObjDict(self.reward_record_obj_list)
    self.reward_record_obj_list = {}
end

function RechargeDrawUI:Hide()
    ComMgrs.dy_data_mgr.recharge_data:UnregisterUpdateRechargeDrawInfo("RechargeDrawUI")
    self.owner:DelObjDict(self.create_obj_list)
    self.owner:RemoveAllUIEffect()
    self.mask:SetActive(false)
    self.luck_draw_frame:SetActive(false)
end

return RechargeDrawUI
