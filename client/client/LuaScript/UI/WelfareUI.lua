local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local ItemUtil = require("BaseUtilities.ItemUtil")
local CSConst = require("CSCommon.CSConst")
local EffectConst = require("Effect.EffectConst")
local ServerFundUI = require("UI.ServerFundUI")
local MonthCardUI = require("UI.Welfare.MonthCardUI")
local WelfareUI = class("UI.WelfareUI",UIBase)

local btn_width = 240
local first_week_sub_id_format = "%sDay%s" --首周签到红点二级ID格式
local anchor_v2 = Vector2.New(1, 1)
local redpoint_control_id_list = {
    [1] = {         -- 定点体力
        CSConst.RedPointControlIdDict.Welfare.Strength
        },
    [2] = {         -- 开服基金
        CSConst.RedPointControlIdDict.Welfare.ServerFund,
        CSConst.RedPointControlIdDict.Welfare.FundWelfare
    },
    [3] = {         -- 首周签到
        CSConst.RedPointControlIdDict.Welfare.FirstWeek
    },
    [4] = {         -- 每日热卖(暂无红点)
        "DailySell"
    },
    [5] = {         -- 每周签到
        CSConst.RedPointControlIdDict.Welfare.WeekCheck
    },
    [6] = {         -- 每月签到
        CSConst.RedPointControlIdDict.Welfare.MonthCheck
    },
    [7] = {         -- 月卡
        CSConst.RedPointControlIdDict.Welfare.MonthCard
    },
}

--  福利界面
function WelfareUI:DoInit()
    WelfareUI.super.DoInit(self)
    ServerFundUI:DoInit(self)
    self.month_card_ui = MonthCardUI.New()
    self.prefab_path = "UI/Common/WelfareUI"
end

function WelfareUI:OnGoLoadedOk(res_go)
    WelfareUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function WelfareUI:Show(welfare_type)
    self.welfare_type = welfare_type
    if self.is_res_ok then
        self:InitUI()
    end
    WelfareUI.super.Show(self)
end

function WelfareUI:InitRes()
    --  每周签到
    self.welfare_btn_list_obj = self.main_panel:FindChild("WelfareBtnList/View/Content")
    self.week_check_frame = self.main_panel:FindChild("WeekCheckFrame")
    self.cur_luck_val_text = self.main_panel:FindChild("WeekCheckFrame/CurLuckValText"):GetComponent("Text")
    self.sign_in_date_text = self.main_panel:FindChild("WeekCheckFrame/SignInDateText"):GetComponent("Text")
    self.sign_in_text = self.main_panel:FindChild("WeekCheckFrame/SignInText"):GetComponent("Text")
    self.week_check_day_list = self.main_panel:FindChild("WeekCheckFrame/WeekCheckMes/ViewPort/WeekCheckDayList")
    self.week_check_mes = self.main_panel:FindChild("WeekCheckFrame/WeekCheckMes/ViewPort/WeekCheckDayList/WeekCheckMes")
    self.week_check_title_text = self.main_panel:FindChild("WeekCheckFrame/WeekCheckTitleText"):GetComponent("Text")
    self.week_tip_text = self.main_panel:FindChild("WeekCheckFrame/WeekTipText"):GetComponent("Text")

    --  每月签到
    self.mouth_check_frame = self.main_panel:FindChild("MouthCheckFrame")
    self.month_check_unit_rect = self.main_panel:FindChild("MouthCheckFrame/UnitRect")
    self.month_check_tip_pic = self.main_panel:FindChild("MouthCheckFrame/TipPic")
    self.treasure_list = self.main_panel:FindChild("MouthCheckFrame/DownFrame/TreasureList")
    self.treasure_item = self.main_panel:FindChild("MouthCheckFrame/DownFrame/TreasureList/TreasureItem")
    self.check_slider = self.main_panel:FindChild("MouthCheckFrame/DownFrame/CheckSliderBg/CheckSlider"):GetComponent("Image")
    self.check_state_text = self.main_panel:FindChild("MouthCheckFrame/DownFrame/CheckStateText"):GetComponent("Text")
    self.cumulative_check_text = self.main_panel:FindChild("MouthCheckFrame/CumulativeCheckText"):GetComponent("Text")
    self.check_item_list = self.main_panel:FindChild("MouthCheckFrame/MonthCheckList/ViewPort/CheckItemList")
    self.reward_item = self.main_panel:FindChild("MouthCheckFrame/MonthCheckList/ViewPort/CheckItemList/RewardItem")
    self.month_check_bg = self.main_panel:FindChild("MouthCheckFrame/MonthCheckBg")
    self.make_up_check_time_text = self.main_panel:FindChild("MouthCheckFrame/MakeUpCheckTimeText"):GetComponent("Text")

    --  首周签到
    self.first_week_reward_frame = self.main_panel:FindChild("FirstWeekRewardFrame")
    self.first_week_show_unit_rect = self.main_panel:FindChild("FirstWeekRewardFrame/UnitRect")
    self.first_week_shop_text = self.main_panel:FindChild("FirstWeekRewardFrame/FirstWeekShopText"):GetComponent("Text")
    self.first_week_day_list = self.main_panel:FindChild("FirstWeekRewardFrame/FirstWeekDayList/ViewPort/DayList")
    self.day_item = self.main_panel:FindChild("FirstWeekRewardFrame/FirstWeekDayList/ViewPort/DayList/DayItem")
    self.first_week_option_list = self.main_panel:FindChild("FirstWeekRewardFrame/FirstWeekOptionList")
    self.option = self.main_panel:FindChild("FirstWeekRewardFrame/FirstWeekOptionList/Option")
    self.count_down_text = self.main_panel:FindChild("FirstWeekRewardFrame/CountDownText"):GetComponent("Text")

    self.first_week_reward_mes_frame = self.main_panel:FindChild("FirstWeekRewardFrame/FirstWeekRewardMes")
    self.first_week_reward_day_list = self.main_panel:FindChild("FirstWeekRewardFrame/FirstWeekRewardMes/ViewPort/FirstWeekRewardDayList")
    self.first_week_reward_mes = self.main_panel:FindChild("FirstWeekRewardFrame/FirstWeekRewardMes/ViewPort/FirstWeekRewardDayList/FirstWeekRewardMes")

    self.first_week_buy_panel = self.main_panel:FindChild("FirstWeekRewardFrame/FirstWeekBuyPanel")
    self.present_price_text = self.main_panel:FindChild("FirstWeekRewardFrame/FirstWeekBuyPanel/PresentPriceText")
    self.original_price = self.main_panel:FindChild("FirstWeekRewardFrame/FirstWeekBuyPanel/OriginPrice")
    self.first_week_buy_shop_name_text = self.main_panel:FindChild("FirstWeekRewardFrame/FirstWeekBuyPanel/ShopName/ShopNameText"):GetComponent("Text")
    self.first_week_buy_btn = self.main_panel:FindChild("FirstWeekRewardFrame/FirstWeekBuyPanel/BuyBtn")
    self.first_week_reward_frame_desc_text = self.main_panel:FindChild("FirstWeekRewardFrame/Text"):GetComponent("Text")

    --  首周签到奖励预览
    self.first_view_reward_frame = self.main_panel:FindChild("FirstViewRewardFrame")
    self.first_view_reward_frame_title = self.main_panel:FindChild("FirstViewRewardFrame/FirstViewRewardFrameTitle"):GetComponent("Text")
    self.first_view_reward_frame_close_btn = self.main_panel:FindChild("FirstViewRewardFrame/FirstViewRewardFrameCloseBtn")
    self:AddClick(self.first_view_reward_frame_close_btn, function()
        self:HideFirstViewRewardFrame()
    end)
    self.view_reward_login_text = self.main_panel:FindChild("FirstViewRewardFrame/ViewRewardLoginText"):GetComponent("Text")
    self.view_reward_task_text = self.main_panel:FindChild("FirstViewRewardFrame/ViewRewardTaskText"):GetComponent("Text")
    self.first_view_login_task_list = self.main_panel:FindChild("FirstViewRewardFrame/LoginScrollRect/ViewPort/FirstViewLoginTaskList")
    self.first_view_reward_task_list = self.main_panel:FindChild("FirstViewRewardFrame/TaskScrollRect/ViewPort/FirstViewRewardTaskList")
    self.first_view_reward_task_list_rect = self.first_view_reward_task_list:GetComponent("RectTransform")
    self.first_view_reward_frame_ok_btn = self.main_panel:FindChild("FirstViewRewardFrame/FirstViewRewardFrameOKBtn")
    self.first_view_reward_frame_ok_btn_text = self.main_panel:FindChild("FirstViewRewardFrame/FirstViewRewardFrameOKBtn/FirstViewRewardFrameOKBtnText"):GetComponent("Text")

    self:AddClick(self.first_view_reward_frame_ok_btn, function()
        self:HideFirstViewRewardFrame()
    end)

    --  每日热卖
    self.daily_sell_frame = self.main_panel:FindChild("DailySellFrame")
    self.daily_sell_count_down_text = self.main_panel:FindChild("DailySellFrame/DailySellCountDownText"):GetComponent("Text")
    self.daily_sell_mes_list = self.main_panel:FindChild("DailySellFrame/DailySellList/ViewPort/DailySellMesList")
    self.daily_sell_mes = self.main_panel:FindChild("DailySellFrame/DailySellList/ViewPort/DailySellMesList/DailySellMes")
    self.daily_sell_frame_unit_rect = self.main_panel:FindChild("DailySellFrame/UnitRect")

    self.daily_sell_frame_desc_text = self.main_panel:FindChild("DailySellFrame/Text"):GetComponent("Text")
    --  定点体力
    self.strength_recover_frame = self.main_panel:FindChild("StrengthRecoverFrame")
    local time_str
    for i, recover_data in ipairs(SpecMgrs.data_mgr:GetAllActionPointData()) do
        local temp_str = string.format(UIConst.Text.DASH, recover_data.start_time, recover_data.stop_time)
        time_str = time_str and string.format(UIConst.Text.AND_VALUE, time_str, temp_str) or temp_str
    end
    self.strength_recover_frame:FindChild("Tip/Text"):GetComponent("Text").text = string.format(UIConst.Text.STRENGTH_RECOVER_DESC, time_str)
    self.strength_recover_model = self.strength_recover_frame:FindChild("LoverModel")
    self.add_strength_btn = self.strength_recover_frame:FindChild("AddBtn")
    self:AddClick(self.add_strength_btn, function ()
        self:SendGetStrengthRecoverReward()
    end)
    self.add_strength_disable = self.strength_recover_frame:FindChild("Disable")

    self.server_fund_frame = self.main_panel:FindChild("ServerFundFrame")

    self.tab_btn_list_content_rect = self.main_panel:FindChild("WelfareBtnList/View/Content"):GetComponent("RectTransform")
    self.welfare_btn_list_temp = self.main_panel:FindChild("WelfareBtnList/View/Content/Temp")
    self.welfare_btn_list_temp:SetActive(false)

    self.month_card_frame = self.main_panel:FindChild("MonthCardFrame")
    ServerFundUI:InitRes()
    self.month_card_ui:InitRes(self)

    self.frame_list = {
        [CSConst.kWelfareIndexDict.StrengthenRecover] = self.strength_recover_frame,
        [CSConst.kWelfareIndexDict.ServerFund] = self.server_fund_frame,
        [CSConst.kWelfareIndexDict.FirstWeekReward] = self.first_week_reward_frame,
        [CSConst.kWelfareIndexDict.DailySell] = self.daily_sell_frame,
        [CSConst.kWelfareIndexDict.MonthCheck] = self.mouth_check_frame,
        [CSConst.kWelfareIndexDict.WeekCheck] = self.week_check_frame,
        [CSConst.kWelfareIndexDict.MonthCard] = self.month_card_frame,
    }

    self.show_frame_func = {
        [CSConst.kWelfareIndexDict.StrengthenRecover]= "ShowStrengthRecoverFrame",
        [CSConst.kWelfareIndexDict.ServerFund] = "ShowServerFundFrame",
        [CSConst.kWelfareIndexDict.FirstWeekReward] = "ShowFirstWeekCheckFrame",
        [CSConst.kWelfareIndexDict.DailySell] = "ShowDailySellFrame",
        [CSConst.kWelfareIndexDict.MonthCheck] = "ShowMouthCheckFrame",
        [CSConst.kWelfareIndexDict.WeekCheck] = "ShowWeekCheckFrame",
        [CSConst.kWelfareIndexDict.MonthCard] = "ShowMonthCardFrame",
    }

    self.Hide_frame_func = {
        [CSConst.kWelfareIndexDict.MonthCard] = "HideMonthCardFrame",
    }

    self.check_show_frame_func = {
        [CSConst.kWelfareIndexDict.FirstWeekReward] = function()
            return self.check_data:CheckFirstWeekCheckOpen()
        end,
        [CSConst.kWelfareIndexDict.DailySell] = function()
            return self.check_data:CheckFirstWeekCheckOpen()
        end,
    }

    self.reward_item:SetActive(false)
    self.treasure_item:SetActive(false)

    self.day_item:SetActive(false)
    self.option:SetActive(false)
    self.first_week_reward_mes:SetActive(false)
    self.first_view_reward_frame:SetActive(false)
    self.daily_sell_mes:SetActive(false)
    self.week_check_mes:SetActive(false)
end

function WelfareUI:InitUI()
    self:ClearRes()
    self.red_point_list = {}
    self.cur_frame_obj_list = {}
    self.cur_frame_effect_dict = {}
    self.cur_frame = nil
    self.cur_type = nil
    self:InitTopBar()
    for i, frame in pairs(self.frame_list) do
        frame:SetActive(false)
    end
    self:SetTextVal()
    self:UpdateData()
    self:UpdateUIInfo()
    ServerFundUI:InitUI()
    if self.welfare_type then
        for i, v in ipairs(self.show_welfare_data_list) do
            if v.type == self.welfare_type then
                self.welfare_selector:SelectObj(i)
                break
            end
        end
    else
        self.welfare_selector:SelectObj(1)
    end
end

function WelfareUI:UpdateData()
    self.check_data = ComMgrs.dy_data_mgr.check_data
    self.dy_activity_data = ComMgrs.dy_data_mgr.activity_data
    self.week_check_info = self.check_data.week_check_info
    self.week_check_reward_data_list = SpecMgrs.data_mgr:GetAllCheckInWeeklyData()
    self.week_check_length = #self.week_check_reward_data_list

    self.month_check_info = self.check_data.month_check_info
    self.month = Time:GetServerDate().month
    self.day = Time:GetServerDate().day
    self.check_month_data = SpecMgrs.data_mgr:GetCheckInMonthlyData(self.month)

    self.first_week_day_data_list = SpecMgrs.data_mgr:GetAllFirstWeekData()
    self.first_week_check_info = self.check_data.first_week_check_info
    self.first_week_today_data = SpecMgrs.data_mgr:GetFirstWeekData(self.first_week_check_info.day_index)

    self.show_welfare_data_list = {}
    local all_welfare_data_list = SpecMgrs.data_mgr:GetAllWelfareData()
    for i, data in ipairs(all_welfare_data_list) do
        if not self.check_show_frame_func[data.type] or self.check_show_frame_func[data.type]() then
            table.insert(self.show_welfare_data_list, data)
        end
    end
end

function WelfareUI:UpdateUIInfo()
    self.welfare_btn_list = {}
    self.welfare_btn_dict = {}
    for i, data in ipairs(self.show_welfare_data_list) do
        local btn = self:GetUIObject(self.welfare_btn_list_temp, self.welfare_btn_list_obj)
        UIFuncs.AssignSpriteByIconID(data.icon, btn:FindChild("Icon"):GetComponent("Image"))
        btn:FindChild("WelfareName"):GetComponent("Text").text = data.name
        table.insert(self.welfare_btn_list, btn)
        self.welfare_btn_dict[data.type] = btn
        local red_point = SpecMgrs.redpoint_mgr:AddRedPoint(self, btn, CSConst.RedPointType.Normal, redpoint_control_id_list[data.type], nil, anchor_v2, anchor_v2)
        table.insert(self.red_point_list, red_point)
    end

    self.welfare_selector = UIFuncs.CreateSelector(self, self.welfare_btn_list, function(i)
        --self.tab_btn_list_content_rect.anchoredPosition = Vector2.New(- (i - 1) * btn_width, 0)
        for effect, go in pairs(self.cur_frame_effect_dict) do
            self:RemoveUIEffect(go)
        end
        self.cur_frame_effect_dict = {}
        self:DelObjDict(self.cur_frame_obj_list)
        local data = self.show_welfare_data_list[i]
        if self.cur_frame then
            self.cur_frame:SetActive(false)
        end
        if self.cur_type then
            local func = self[self.Hide_frame_func[data.type]]
            if func then
                func(self)
            end
        end
        local frame = self.frame_list[data.type]
        self.cur_frame = frame
        self.cur_type = data.type
        local func = self[self.show_frame_func[data.type]]
        frame:SetActive(true)
        func(self)
    end)

    local is_strength_recover_time = self.dy_activity_data:CheckStrengthRecover()
    self.add_strength_btn:SetActive(is_strength_recover_time)
    self.add_strength_disable:SetActive(not is_strength_recover_time)
    self.dy_activity_data:RegisterUpdateStrengthRecoverInfoEvent("WelfareUI", function ()
        self:ShowStrengthRecoverFrame()
    end)
    self.dy_activity_data:RegisterUpdateStrengthRecoverStateEvent("WelfareUI", function ()
        local strength_recover_open = self.dy_activity_data:CheckStrengthRecover()
        self.add_strength_btn:SetActive(strength_recover_open)
        self.add_strength_disable:SetActive(not strength_recover_open)
    end)
    self.first_week_reward_frame_desc_text.text = UIFuncs.MergeStrList(SpecMgrs.data_mgr:GetParamData("first_week_check_text").tb_string)
    self.daily_sell_frame_desc_text.text = UIFuncs.MergeStrList(SpecMgrs.data_mgr:GetParamData("daily_sell_text").tb_string)
end

function WelfareUI:SetTextVal()
    self.week_check_title_text.text = UIConst.Text.WEEK_CHECK_TEXT
    self.sign_in_text.text = UIConst.Text.WEEK_CHECK_TEXT
    self.cumulative_check_text.text = UIConst.Text.CUMULATIVE_CHECK_TEXT

    self.first_week_shop_text.text = UIConst.Text.DAILY_SELL_TEXT
    self.reward_item:FindChild("MakeUp/MakeUpCeckText"):GetComponent("Text").text = UIConst.Text.MAKE_UP_CHECK
    self.first_week_reward_mes:FindChild("CheckBtn/Text"):GetComponent("Text").text = UIConst.Text.RECEIVE_TEXT

    self.view_reward_login_text.text = UIConst.Text.LOGIN_REWARD_VIEW_TEXT
    self.view_reward_task_text.text = UIConst.Text.TASK_REWARD_VIEW_TEXT
    self.first_view_reward_frame_title.text = UIConst.Text.REWARD_VIEW_TITLE
    self.first_view_reward_frame_ok_btn_text.text = UIConst.Text.CONFIRM

    self.daily_sell_mes:FindChild("BuyBtn/Text"):GetComponent("Text").text = UIConst.Text.BUY_TEXT
    self.daily_sell_mes:FindChild("AlreadyBuy/AlreadyReceivedText"):GetComponent("Text").text = UIConst.Text.ALREADY_BUY_TEXT

    -- 导表不支持换行
    local str_list = SpecMgrs.data_mgr:GetParamData("week_check_tip").tb_string
    self.week_tip_text.text = UIFuncs.MergeStrList(str_list)
end

function WelfareUI:Update()
    if not self.is_res_ok or not self.is_visible then return end
    if self.cur_frame == self.first_week_reward_frame or self.cur_frame == self.daily_sell_frame then
        local text_obj = self.count_down_text
        if self.cur_frame == self.daily_sell_frame then
            text_obj = self.daily_sell_count_down_text
        end
        local time_delta = self.check_data:GetFirstWeekCheckRemainTime()
        if time_delta > 0 then
            local time_str = UIFuncs.TimeDelta2Str(time_delta, 4, UIConst.LongCDRemainFormat)
            text_obj.text = string.format(UIConst.Text.DAILY_SELL_COUNT_DOWN, time_str)
        else
            text_obj.text = UIConst.Text.ALREADY_FINISH_TEXT
        end
    end
end

--  每周签到
function WelfareUI:ShowWeekCheckFrame()
    self.cur_luck_val_text.text = string.format(UIConst.Text.CUR_LUCKY_FORMAT, self.week_check_info.luck_value)
    local start_day = self:GetDayStr(self.week_check_info.start_day, 0)
    local end_day = self:GetDayStr(self.week_check_info.start_day, self.week_check_length - 1)
    self.sign_in_date_text.text = string.format(UIConst.Text.WEEK_CHECK_DATE_FORMAT, start_day, end_day)

    for i = 1, self.week_check_length do
        local reward_data = self.week_check_reward_data_list[i]
        local mes_item = self:GetUIObject(self.week_check_mes, self.week_check_day_list)
        table.insert(self.cur_frame_obj_list, mes_item)
        local time_str = self:GetDayStr(self.week_check_info.start_day, i - 1)
        local str = string.format(UIConst.Text.LOGIN_DATE_FORMAT, i, time_str)
        mes_item:FindChild("CheckDayText"):GetComponent("Text").text = str

        local check_state = self.week_check_info.check_in_reward[i]
        local btn = mes_item:FindChild("CheckBtn")
        local already_received = mes_item:FindChild("AlreadyReceived")
        btn:SetActive(false)
        already_received:SetActive(false)
        if check_state == CSConst.RewardState.unpick then
            btn:SetActive(true)
            btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.RECEIVE_TEXT
            btn:FindChild("GrayImage"):SetActive(true)
            btn:FindChild("Tip"):SetActive(false)
            btn:GetComponent("Button").interactable = false
        elseif check_state == CSConst.RewardState.pick then
            btn:SetActive(true)
            if self.week_check_info.day_index == i then
                btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.RECEIVE_TEXT
            else
                btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.MAKE_UP_CHECK
            end
            btn:FindChild("Tip"):SetActive(true)
            btn:FindChild("GrayImage"):SetActive(false)
            btn:GetComponent("Button").interactable = true
            UIFuncs.AddCompleteEffect(self, btn)
            self:AddClick(btn, function()
                if self.week_check_info.day_index == i then
                    self:ClickWeekCheck(mes_item, i)
                else
                    local item_id = SpecMgrs.data_mgr:GetParamData("check_in_weekly_cost").item_id
                    local count = SpecMgrs.data_mgr:GetParamData("check_in_weekly_cost").count
                    if UIFuncs.CheckItemCount(item_id, count, true) then
                        local content = string.format(UIConst.Text.MAKEUP_LOGIN_TIP_FORMAT, count)
                        SpecMgrs.ui_mgr:ShowMsgSelectBox({content = content, confirm_cb = function()
                            self:ClickWeekCheck(mes_item, i)
                        end})
                    end
                end
            end)
        elseif check_state == CSConst.RewardState.picked then
            already_received:SetActive(true)
            already_received:FindChild("AlreadyReceivedText"):GetComponent("Text").text = UIConst.Text.ALREADY_RECEIVE_TEXT
        end

        local item_list = {}
        for i, id in ipairs(reward_data.reward_id) do
            table.insert(item_list, {item_id = id, count = reward_data.reward_count[i]})
        end
        local ret = UIFuncs.SetItemList(self, item_list, mes_item:FindChild("RewardItemList"))
        table.mergeList(self.cur_frame_obj_list, ret)
    end
end

function WelfareUI:ClickWeekCheck(item, index)
    local reward_data = self.week_check_reward_data_list[index]
    local cb = function(resp)
        self:UpdateData()
        self.cur_luck_val_text.text = string.format(UIConst.Text.CUR_LUCKY_FORMAT, self.week_check_info.luck_value)
        local btn = item:FindChild("CheckBtn")
        local already_received = item:FindChild("AlreadyReceived")
        btn:SetActive(false)
        already_received:SetActive(true)
        already_received:FindChild("AlreadyReceivedText"):GetComponent("Text").text = UIConst.Text.ALREADY_RECEIVE_TEXT
        local item_dict = {}
        for i, id in ipairs(reward_data.reward_id) do
            local count = reward_data.reward_count[i]
            if resp.is_luck and reward_data.special_reward[i] then
                count = count * 2
            end
            item_dict[id] = count
        end
        UIFuncs.ShowGetRewardItemByItemDict(item_dict, true)
    end
    SpecMgrs.msg_mgr:SendCheckInWeekly({check_in_date = index}, cb)
end

function WelfareUI:GetDayStr(time, day_count)
    local end_time = os.date("*t", time)
    end_time.day = end_time.day + day_count
    local delta_time = os.time(end_time)
    end_time = os.date("*t", delta_time)
    local str = string.format(UIConst.Text.MONTH_DAY_FORMAT, end_time.month, end_time.day)
    return str
end

--  每月签到
function WelfareUI:ShowMouthCheckFrame()
    if self.month_check_show_unit then
        self:RemoveUnit(self.month_check_show_unit)
    end
    self.month_check_show_unit = self:AddHalfUnit(self.check_month_data.show_unit, self.month_check_unit_rect)
    UIFuncs.AssignSpriteByIconID(self.check_month_data.month_pic, self.month_check_bg:GetComponent("Image"))
    self.make_up_check_time_text.text = string.format(UIConst.Text.MAKE_UP_CHECK_TIME_FORMAT, self.month_check_info.replenish_num)
    self:InitMonthCheckItem()
    self:CreateTreasureList()
    self:UpdateCheckTreasureList(self.cur_treasure_item_list)
end

function WelfareUI:CreateTreasureList()
    self:DelObjDict(self.cur_treasure_item_list)
    self.cur_treasure_item_list = {}
    self:DelObjDict(self.cur_treasure_box_list)
    self.cur_treasure_box_list = {}
    self.item_width = self.treasure_list:GetComponent("RectTransform").rect.width
    self.slider_pos_list = {}
    local slider_val = nil
    local item_count = #self.check_month_data.chest_reward
    local treasure_box_id = SpecMgrs.data_mgr:GetParamData("month_check_reward_box").treasure_box_id
    for i, reward_id in ipairs(self.check_month_data.chest_reward) do
        local item = self:GetUIObject(self.treasure_item, self.treasure_list)
        item:FindChild("DayText"):GetComponent("Text").text = string.format(UIConst.Text.MONTH_CHECK_DAY_FORMAT, self.check_month_data.chest_day_request[i])
        table.insert(self.cur_treasure_item_list, item)
        local treasure_box = UIFuncs.GetTreasureBox(self, item:FindChild("TreasureBox"), treasure_box_id)
        local pos = Vector3.New(self.item_width / item_count * i, 0)
        item:GetComponent("RectTransform").anchoredPosition = pos
        table.insert(self.slider_pos_list, pos)
        self:AddClick(treasure_box, function()
            local data = {
                confirm_cb = function ()
                    self:ReciveTreasureBox(treasure_box, i)
                end,
                desc = UIConst.Text.TREASURE_PREVIEW_DESC,
                reward_state = self.month_check_info.check_in_chest_reward[i],
                reward_id = reward_id,
            }
            SpecMgrs.ui_mgr:ShowUI("RewardPreviewUI", data)
        end)
        table.insert(self.cur_treasure_box_list, treasure_box)
    end
end

function WelfareUI:InitMonthCheckItem()
    for i, state in ipairs(self.month_check_info.check_in_date_reward) do
        if not self.check_month_data.reward_id[i] then return end
        local item = self:GetUIObject(self.reward_item, self.check_item_list)
        table.insert(self.cur_frame_obj_list, item)
        UIFuncs.AssignItem(item, self.check_month_data.reward_id[i], self.check_month_data.reward_count[i])

        local can_check_image = item:FindChild("CanCheckImage")
        local vip = item:FindChild("Vip")
        local have_check_image = item:FindChild("HaveCheckImage")
        local make_up = item:FindChild("MakeUp")

        if table.contains(self.check_month_data.vip_day, i) then
            vip:SetActive(true)
            local index = table.index(self.check_month_data.vip_day, i)
            vip:FindChild("VipText"):GetComponent("Text").text = string.format(UIConst.Text.VIP_DOUBLE_FORMAT, self.check_month_data.vip_level_request[index])
        else
            vip:SetActive(false)
        end

        item:FindChild("DayText"):GetComponent("Text").text = string.format(UIConst.Text.CHECK_DAY_FORMAT, i)

        can_check_image:SetActive(false)
        have_check_image:SetActive(false)
        make_up:SetActive(false)

        if state == CSConst.RewardState.unpick then
            self:AddClick(item, function()
                SpecMgrs.ui_mgr:ShowItemPreviewUI(self.check_month_data.reward_id[i])
            end)
        elseif state == CSConst.RewardState.pick then
            if self.day == i then
                can_check_image:SetActive(true)
                local gold_effect_parent = item
                local glod_circle_effect = UIFuncs.AddGlodCircleEffect(self, item)
                self.cur_frame_effect_dict[glod_circle_effect] = gold_effect_parent
            else
                make_up:SetActive(true)
            end
            self:AddClick(item, function()
                self:ClickMonthCheck(item, i)
            end)
        elseif state == CSConst.RewardState.picked then
            have_check_image:SetActive(true)
            self:AddClick(item, function()
                SpecMgrs.ui_mgr:ShowItemPreviewUI(self.check_month_data.reward_id[i])
            end)
        end
    end
    local rect = self.check_item_list:GetComponent("RectTransform")
    rect.anchoredPosition = Vector2.New(rect.anchoredPosition.x, 0)
end

function WelfareUI:ClickMonthCheck(item, i)
    if self.month_check_info.check_in_date_reward[i] == CSConst.RewardState.picked then
        return
    end
    if self.day ~= i then
        if self.month_check_info.replenish_num == 0 then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.CANNOT_MAKE_UP_CHECK_TIP)
            return
        end
        if self.month_check_info.replenish_remain_today == 0 then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.TODAY_CANNOT_MAKE_UP_CHECK_TIP)
            return
        end
    end
    local cb = function(resp)
        item:FindChild("MakeUp"):SetActive(false)
        item:FindChild("HaveCheckImage"):SetActive(true)
        self:UpdateData()
        self:UpdateCheckTreasureList(self.cur_treasure_item_list)
        self.make_up_check_time_text.text = string.format(UIConst.Text.MAKE_UP_CHECK_TIME_FORMAT, self.month_check_info.replenish_num)
    end
    self:RemoveUIEffect(item)
    SpecMgrs.msg_mgr:SendCkeckInMonthly({check_in_date = i}, cb)
end

function WelfareUI:UpdateCheckTreasureList(cur_treasure_item_list)
    local check_count = self.month_check_info.check_in_count
    local not_check_day_num = self.day - check_count
    if self.month_check_info.check_in_date_reward[self.day] ~= CSConst.RewardState.picked then
        not_check_day_num = not_check_day_num - 1
    end
    self.check_state_text.text = string.format(UIConst.Text.MONTH_CHECK_SITUATION_FORMAT, check_count, not_check_day_num)
    for i, reward_id in ipairs(self.check_month_data.chest_reward) do
        local item = cur_treasure_item_list[i]
        local treasure_box = item:FindChild("TreasureBox/treasure_box")
        if self.month_check_info.check_in_chest_reward[i] == CSConst.RewardState.unpick then
            UIFuncs.UpdateTreasureBoxStatus(treasure_box, false)
        elseif self.month_check_info.check_in_chest_reward[i] == CSConst.RewardState.pick then
            UIFuncs.UpdateTreasureBoxStatus(treasure_box, true)
        elseif self.month_check_info.check_in_chest_reward[i] == CSConst.RewardState.picked then
            UIFuncs.UpdateTreasureBoxStatus(treasure_box)
        end
    end
    local slider_val
    for i, day in ipairs(self.check_month_data.chest_day_request) do
        if self.month_check_info.check_in_count <= day and not slider_val then
            local last_day = self.check_month_data.chest_day_request[i - 1] or 0
            local last_precent
            if (i - 1) == 0 then
                last_precent = 0
            else
                last_precent = self.slider_pos_list[i - 1].x / self.item_width
            end
            local cur_precent = self.slider_pos_list[i].x / self.item_width
            slider_val = last_precent + (cur_precent - last_precent) * (self.month_check_info.check_in_count - last_day) / (day - last_day)
        end
    end
    slider_val = slider_val or 1
    self.check_slider.fillAmount = slider_val
end

function WelfareUI:ReciveTreasureBox(treasure_box, index)
    local cb = function(resp)
        if not self.is_res_ok then return end
        UIFuncs.ShowGetRewardItem(self.check_month_data.chest_reward[index], true)
        self:UpdateData()
        UIFuncs.UpdateTreasureBoxStatus(treasure_box)
    end
    SpecMgrs.msg_mgr:SendCheckInMonthlyChest({reward_pos = index}, cb)
    UIFuncs.PlayOpenBoxAnim(treasure_box)
end

--  首周签到
function WelfareUI:ShowFirstWeekCheckFrame()
    self.first_week_day_item_list = {}
    self.day_option_list = {}
    self.first_week_reward_mes_list = {}
    if self.first_week_check_show_unit then
        self:RemoveUnit(self.first_week_check_show_unit)
        self.first_week_check_show_unit = nil
    end
    for i = 1, self.first_week_check_info.day_index do
        local data = self.first_week_day_data_list[i]
    end
    for i, data in ipairs(self.first_week_day_data_list) do
        local item = self:GetUIObject(self.day_item, self.first_week_day_list)
        item:FindChild("Text"):GetComponent("Text").text = string.format(UIConst.Text.CHECK_DAY_FORMAT, i)
        item:FindChild("SelectImage"):SetActive(false)
        if i <= self.first_week_check_info.day_index then
            table.insert(self.first_week_day_item_list, item)
        else
            self:AddClick(item, function()
                self:ShowFirstViewRewardFrame(data)
            end)
        end
        table.insert(self.cur_frame_obj_list, item)
    end
    self:_UpdateDayRedPoint()
    self.first_week_day_selector = UIFuncs.CreateSelector(self, self.first_week_day_item_list, function(index)
        self:SelectDay(index)
    end)
    self.first_week_day_selector:SelectObj(1)
end

function WelfareUI:SelectDay(index)
    if self.day_option_list then self:DelObjDict(self.day_option_list) end
    self.day_option_list = {}
    self.first_week_day_data = self.first_week_day_data_list[index]

    if self.first_week_check_show_unit then
        if self.first_week_check_show_unit.unit_id ~= self.first_week_day_data.show_unit then
            self:RemoveUnit(self.first_week_check_show_unit)
            self.first_week_check_show_unit = self:AddHalfUnit(self.first_week_day_data.show_unit, self.first_week_show_unit_rect)
        end
    else
        self.first_week_check_show_unit = self:AddHalfUnit(self.first_week_day_data.show_unit, self.first_week_show_unit_rect)
    end

    local buy_item_index = #self.first_week_day_data.label_list + 1
    for i, title in ipairs(self.first_week_day_data.label_list) do
        local item = self:GetUIObject(self.option, self.first_week_option_list)
        item:FindChild("SignInText"):GetComponent("Text").text = title
        table.insert(self.day_option_list, item)
    end

    local item = self:GetUIObject(self.option, self.first_week_option_list)
    item:FindChild("SignInText"):GetComponent("Text").text = UIConst.Text.HALF_BUY_ITEM_TEXT
    table.insert(self.day_option_list, item)
    self.day_option_selector = UIFuncs.CreateSelector(self, self.day_option_list, function(index)
        if index == buy_item_index then
            self.first_week_reward_mes_frame:SetActive(false)
            self.first_week_buy_panel:SetActive(true)
            self:SelectBuyItem()
        else
            self.first_week_reward_mes_frame:SetActive(true)
            self.first_week_buy_panel:SetActive(false)
            self:SelectDayOption(index)
        end
    end)
    self.day_option_selector:SelectObj(1)
    table.mergeList(self.cur_frame_obj_list, self.day_option_list)
    self:_UpdateDayOptionRedPoint(index)
end

function WelfareUI:SelectBuyItem()
    if self.first_week_reward_mes_list then self:DelObjDict(self.first_week_reward_mes_list) end
    self.first_week_reward_mes_list = {}
    local item_data = SpecMgrs.data_mgr:GetItemData(self.first_week_day_data.item_id)
    local consume_item_data = SpecMgrs.data_mgr:GetItemData(self.first_week_day_data.consume_item_id)

    local present_price_str = string.format(UIConst.Text.PRESENT_PRICE_FORMAT, self.first_week_day_data.consume_item_count, consume_item_data.icon)
    self:SetTextPic(self.present_price_text, present_price_str)
    local original_price_str = string.format(UIConst.Text.ORIGINAL_PRICE_FORMAT, self.first_week_day_data.consume_item_count * 2)
    UIFuncs.AssignSpriteByIconID(consume_item_data.icon, self.original_price:FindChild("OriginalPriceImage"):GetComponent("Image"))
    self.original_price:FindChild("OriginalPriceText"):GetComponent("Text").text = original_price_str
    self.original_price:GetComponent("ContentSizeFitter"):SetLayoutHorizontal()

    self.first_week_buy_shop_name_text.text = item_data.name

    self:AddClick(self.first_week_buy_panel:FindChild("Item"), function()
        SpecMgrs.ui_mgr:ShowItemPreviewUI(self.first_week_day_data.item_id)
    end)

    if self.first_week_check_info.half_sell[self.first_week_day_data.id] then
        self.first_week_buy_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ALREADY_BUY_TEXT
        self.first_week_buy_btn:GetComponent("Button").interactable = false
        self.first_week_buy_btn:FindChild("GrayImage"):SetActive(true)
    else
        self.first_week_buy_btn:GetComponent("Button").interactable = true
        self.first_week_buy_btn:FindChild("GrayImage"):SetActive(false)
        self.first_week_buy_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.BUY_TEXT
        self:AddClick(self.first_week_buy_btn, function()
            local buy_cb = function()
                self:SendBuyHalfSellItem()
            end
            local price_list = {{item_id = self.first_week_day_data.consume_item_id, count = self.first_week_day_data.consume_item_count}}
            UIFuncs.ShowBuyShopItemUI(self.first_week_day_data.item_id, self.first_week_day_data.sell_item_count, 1, price_list, buy_cb)
        end)
    end
end

function WelfareUI:SendBuyHalfSellItem()
    if not UIFuncs.CheckItemCount(self.first_week_day_data.consume_item_id, self.first_week_day_data.consume_item_count, true) then
        return
    end
    local cb = function()
        self.first_week_buy_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ALREADY_BUY_TEXT
        self.first_week_buy_btn:GetComponent("Button").interactable = false
        self.first_week_buy_btn:FindChild("GrayImage"):SetActive(true)
    end
    SpecMgrs.msg_mgr:SendFirstWeekBuyHalfSell({day_index = self.first_week_day_data.id}, cb)
end

function WelfareUI:SelectDayOption(index)
    if self.first_week_reward_mes_list then self:DelObjDict(self.first_week_reward_mes_list) end
    self.first_week_reward_mes_list = {}
    local task_list = self.first_week_day_data.task_id_list[index]
    local sort_task_list = self:GetSortTaskList(task_list)
    for i, id in ipairs(task_list) do
        local item = self:GetUIObject(self.first_week_reward_mes, self.first_week_reward_day_list)
        local task_data = SpecMgrs.data_mgr:GetFirstWeekTaskData(id)

        local task_cur_val = self.first_week_check_info.task_dict[task_data.task_type]
        local format
        if task_cur_val < task_data.require_count then
            format = UIConst.Text.RED_PRE_VALUE
        else
            format = UIConst.Text.GREEN_PRE_VALUE
        end
        local process_str = string.format(format, task_cur_val, task_data.require_count)
        local mission_des = string.format(task_data.mission_des, task_data.require_count)
        local str = string.format(UIConst.Text.MISSION_DESC_FORMAT, mission_des, process_str)
        item:FindChild("TaskProgressText"):GetComponent("Text").text = str
        local ret = UIFuncs.SetItemList(self, task_data.reward_list, item:FindChild("RewardItemList"))

        local recive_obj = item:FindChild("AlreadyReceived")
        local check_btn = item:FindChild("CheckBtn")

        recive_obj:SetActive(false)
        check_btn:SetActive(false)
        if self.first_week_check_info.recive_dict[id] then
            recive_obj:SetActive(true)
            recive_obj:FindChild("AlreadyReceivedText"):GetComponent("Text").text = UIConst.Text.ALREADY_RECEIVE_TEXT
        else
            if task_data.require_count <= self.first_week_check_info.task_dict[task_data.task_type] then
                check_btn:SetActive(true)
                check_btn:FindChild("Tip"):SetActive(true)
                UIFuncs.AddCompleteEffect(self, check_btn)
                self:AddClick(check_btn, function()
                    self:ReceiveFirstWeekReward(task_data, item, recive_obj, self.first_week_day_data.id)
                end)
            else
                recive_obj:SetActive(true)
                recive_obj:FindChild("AlreadyReceivedText"):GetComponent("Text").text = UIConst.Text.NOT_FINISH_TEXT
            end
        end
        table.mergeList(self.first_week_reward_mes_list, ret)
        table.insert(self.first_week_reward_mes_list, item)
    end
    table.mergeList(self.cur_frame_obj_list, self.first_week_reward_mes_list)
end

function WelfareUI:GetSortTaskList(task_list)
    table.sort(task_list, function(a, b)
        local a_sort_order = self:GetSortOrder(a)
        local b_sort_order = self:GetSortOrder(b)
        if a_sort_order == b_sort_order then
            return a < b
        else
            return a_sort_order > b_sort_order
        end
    end)
end

function WelfareUI:GetSortOrder(id)
    local task_data = SpecMgrs.data_mgr:GetFirstWeekTaskData(id)
    local is_finish = task_data.require_count <= self.first_week_check_info.task_dict[task_data.task_type]
    if self.first_week_check_info.recive_dict[id] then
        return 1
    end
    if not is_finish then
        return 2
    else
        return 3
    end
end

function WelfareUI:ReceiveFirstWeekReward(task_data, item, recive_obj, day)
    local cb = function(resp)
        if resp.errcode == 1 then return end
        local check_btn = item:FindChild("CheckBtn")
        check_btn:SetActive(false)
        check_btn:FindChild("Tip"):SetActive(false)
        item:SetAsLastSibling()
        recive_obj:SetActive(true)
        recive_obj:FindChild("AlreadyReceivedText"):GetComponent("Text").text = UIConst.Text.ALREADY_RECEIVE_TEXT
    end
    SpecMgrs.msg_mgr:SendFirstWeekReciveReward({task_id = task_data.task_id}, cb)
end

--添加日期选项页签红点
function WelfareUI:_UpdateDayRedPoint()
    if self.day_redpoint_list then
        self:RemoveRedPointList(self.day_redpoint_list)
        self.day_redpoint_list = nil
    end
    self.day_redpoint_list = {}
    for index, parent in ipairs(self.first_week_day_item_list) do
        local redpoint = SpecMgrs.redpoint_mgr:AddRedPoint(self, parent, CSConst.RedPointType.Normal, redpoint_control_id_list[3], index, anchor_v2, anchor_v2)
        table.insert(self.day_redpoint_list, redpoint)
    end
end

--刷新活动选项页签红点监听目标
function WelfareUI:_UpdateDayOptionRedPoint(day)
    if not self.day_option_list then return end
    if self.option_redpoint_list then
        self:RemoveRedPointList(self.option_redpoint_list)
        self.option_redpoint_list = nil
    end
    self.option_redpoint_list = {}
    for i, item in ipairs(self.day_option_list) do
        local sub_id = string.format( first_week_sub_id_format, day, i)
        local redpoint = SpecMgrs.redpoint_mgr:AddRedPoint(self, item, CSConst.RedPointType.Normal, redpoint_control_id_list[3], sub_id, anchor_v2, anchor_v2)
        table.insert(self.option_redpoint_list, redpoint)
    end
end

--  首周签到预览
function WelfareUI:ShowFirstViewRewardFrame(data)
    self.first_week_view_reward_obj_list = {}
    self.first_view_reward_frame:SetActive(true)
    self.first_view_reward_task_list_rect.anchoredPosition = Vector2.zero

    -- local login_item_list = {}
    -- for i, id in ipairs(data.login_preview_item) do
    --     table.insert(login_item_list, {item_id = id})
    -- end

    -- local task_item_list = {}
    -- for i, id in ipairs(data.task_preview_item) do
    --     table.insert(task_item_list, {item_id = id})
    -- end

    local login_item_dict = {}
    local task_item_dict = {}

    for i, task_list in ipairs(data.task_id_list) do
        for i, id in ipairs(task_list) do
            local task = SpecMgrs.data_mgr:GetFirstWeekTaskData(id)
            if task.task_type == CSConst.FirstWeekTaskType.LoginNum then
                for i,v in ipairs(task.reward_id) do
                    login_item_dict[v] = login_item_dict[v] and login_item_dict[v] + task.reward_count[i] or task.reward_count[i]
                end
            else
                for i,v in ipairs(task.reward_id) do
                    task_item_dict[v] = task_item_dict[v] and task_item_dict[v] + task.reward_count[i] or task.reward_count[i]
                end
            end
        end
    end

    local login_item_list = ItemUtil.ItemDictToItemDataList(login_item_dict, true)
    local task_item_list = ItemUtil.ItemDictToItemDataList(task_item_dict, true)

    local ret = UIFuncs.SetItemList(self, login_item_list, self.first_view_login_task_list)
    table.mergeList(self.first_week_view_reward_obj_list, ret)

    ret = UIFuncs.SetItemList(self, task_item_list, self.first_view_reward_task_list)
    table.mergeList(self.first_week_view_reward_obj_list, ret)
end

function WelfareUI:HideFirstViewRewardFrame()
    self:DelObjDict(self.first_week_view_reward_obj_list)
    self.first_view_reward_frame:SetActive(false)
end

--  首周热卖
function WelfareUI:ShowDailySellFrame()
    if self.daily_sell_show_unit then self:RemoveUnit(self.daily_sell_show_unit) end
    local show_unit_id = self.first_week_day_data_list[self.first_week_check_info.day_index].daily_sell_show_unit
    self.daily_sell_show_unit = self:AddHalfUnit(show_unit_id ,self.daily_sell_frame_unit_rect)
    for i = 1, self.first_week_check_info.day_index do
        local data = self.first_week_day_data_list[i]
        for j, sell_id in ipairs(data.sell_item) do
            local shop_item = SpecMgrs.data_mgr:GetFirstWeekSellData(sell_id)
            local sell_mes = self:GetUIObject(self.daily_sell_mes, self.daily_sell_mes_list)
            local spend_text = sell_mes:FindChild("SpendText")
            local speld_item_data = SpecMgrs.data_mgr:GetItemData(shop_item.consume_item_id)
            local can_buy_time = shop_item.sell_limit_num - self.check_data:GetSellNum(sell_id, i)
            self:UpdateDailySellItem(sell_mes, can_buy_time, shop_item)
            if can_buy_time > 0 then
                local buy_btn = sell_mes:FindChild("BuyBtn")
                self:AddClick(buy_btn, function()
                    if not UIFuncs.CheckItemCount(shop_item.consume_item_id, shop_item.consume_item_count, true) then
                        return
                    end
                    local can_buy_time = shop_item.sell_limit_num - self.check_data:GetSellNum(sell_id, i)
                    UIFuncs.ShowBuyShopItemUI(shop_item.sell_item_id, shop_item.sell_item_count, can_buy_time, {{item_id = shop_item.consume_item_id, count = shop_item.consume_item_count}}, function(buy_time)
                        self:SendBuyFirstWeekSellItem(i, sell_id, sell_mes, shop_item, buy_time)
                    end)
                end)
            end
            self:SetTextPic(spend_text, string.format(UIConst.Text.SPEND_FORMAT, speld_item_data.icon, shop_item.consume_item_count, speld_item_data.name))
            local ret = UIFuncs.SetItemList(self, {{item_id = shop_item.sell_item_id, count = shop_item.sell_item_count}}, sell_mes:FindChild("ShopItem"))
            table.insert(self.cur_frame_obj_list, sell_mes)
            table.mergeList(self.cur_frame_obj_list, ret)
        end
    end
end

function WelfareUI:UpdateDailySellItem(sell_mes, can_buy_time, shop_item)
    local buy_time_text = sell_mes:FindChild("BuyTimeText")
    local buy_btn = sell_mes:FindChild("BuyBtn")
    local already_buy = sell_mes:FindChild("AlreadyBuy")
    local discount_text = sell_mes:FindChild("DiscountText")
    if can_buy_time == 0 then
        already_buy:SetActive(true)
        buy_time_text:SetActive(false)
        buy_btn:SetActive(false)
    else
        already_buy:SetActive(false)
        buy_time_text:SetActive(true)
        buy_btn:SetActive(true)
        buy_time_text:GetComponent("Text").text = string.format(UIConst.Text.OVERPLUS_BUY_TIMR_FORMAT, can_buy_time, shop_item.sell_limit_num)
    end
    discount_text:GetComponent("Text").text = string.format(UIConst.Text.DISCOUNT_TEXT, shop_item.discount)
end

function WelfareUI:SendBuyFirstWeekSellItem(day_index, sell_id, sell_mes, shop_item, buy_num)
    local cb = function()
        self:UpdateDailySellItem(sell_mes, shop_item.sell_limit_num - self.check_data:GetSellNum(sell_id, day_index), shop_item)
    end
    SpecMgrs.msg_mgr:SendFirstWeekBuySellItem({day_index = day_index, sell_id = sell_id, buy_num = buy_num}, cb)
end

-- strength recover
function WelfareUI:ShowStrengthRecoverFrame()
    self:RemoveStrengthRecoverLoverUnit()
    local unit_id = self.dy_activity_data:GetStrengthRecoverLover()
    self.strength_recover_unit = self:AddFullUnit(unit_id, self.strength_recover_model)
end

function WelfareUI:RemoveStrengthRecoverLoverUnit()
    if self.strength_recover_unit then
        ComMgrs.unit_mgr:DestroyUnit(self.strength_recover_unit)
        self.strength_recover_unit = nil
    end
end

function WelfareUI:SendGetStrengthRecoverReward()
    SpecMgrs.msg_mgr:SendGetStrengthRecoverReward({}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.STRENGTH_RECOVER_FAILED)
        else
            local strength_recover_data = self.dy_activity_data:GetCurStrengthRecoverData()
            if not strength_recover_data then return end
            local item_list = {}
            table.insert(item_list, {item_id = CSConst.CostValueItem.ActionPoint, count = strength_recover_data.action_point})
            if resp.is_add_exp then
                table.insert(item_list, {item_id = CSConst.Virtual.Intimacy, count = strength_recover_data.lover_exp_value})
            end
            SpecMgrs.ui_mgr:ShowCostItemRecoverUI(item_list, self.dy_activity_data:GetStrengthRecoverLover())
        end
    end)
end

function WelfareUI:ShowMonthCardFrame()
    self.month_card_ui:Show()
end

function WelfareUI:HideMonthCardFrame()
    self.month_card_ui:Hide()
end

-- server fund
function WelfareUI:ShowServerFundFrame()
    ServerFundUI:Show()
end

function WelfareUI:ClearRes()
    ComMgrs.dy_data_mgr.check_data:UnregisterUpdateWeekCheck("WelfareUI")
    ComMgrs.dy_data_mgr.check_data:UnregisterUpdateMonthCheck("WelfareUI")
    ComMgrs.dy_data_mgr.check_data:UnregisterUpdateFirstWeekCheck("WelfareUI")
    ComMgrs.dy_data_mgr.activity_data:UnregisterUpdateStrengthRecoverStateEvent("WelfareUI")
    ComMgrs.dy_data_mgr.activity_data:UnregisterUpdateStrengthRecoverInfoEvent("WelfareUI")
    ComMgrs.dy_data_mgr.activity_data:UnregisterUpdateServerFundRewardEvent("WelfareUI")
    ComMgrs.dy_data_mgr.activity_data:UnregisterUpdateFundWelfareRewardEvent("WelfareUI")
    self:RemoveStrengthRecoverLoverUnit()
    ServerFundUI:Hide()
    self:RemoveRedPointList(self.red_point_list)
    self.red_point_list = {}
    self:DelAllCreateUIObj()
end

function WelfareUI:Hide()
    self:ClearRes()
    WelfareUI.super.Hide(self)
end

return WelfareUI
