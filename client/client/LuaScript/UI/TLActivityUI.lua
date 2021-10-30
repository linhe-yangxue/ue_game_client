local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local CSConst = require("CSCommon.CSConst")
local DailyRechargeUI = require("UI.LimitTimeActivity.DailyRechargeUI")
local FirstRechargeUI = require("UI.LimitTimeActivity.FirstRechargeUI")
local FestivalActivityUI = require("UI.LimitTimeActivity.FestivalActivityUI")
local FestivalExchangeUI = require("UI.LimitTimeActivity.FestivalExchangeUI")
local RechargeDrawUI = require("UI.LimitTimeActivity.RechargeDrawUI")
local TLActivityUI = class("UI.TLActivityUI", UIBase)

local btn_width = 240

function TLActivityUI:DoInit()
    TLActivityUI.super.DoInit(self)
    self.prefab_path = "UI/Common/TLActivityUI"
    self.dy_activity_data = ComMgrs.dy_data_mgr.activity_data
    self.dy_tl_activity_data = ComMgrs.dy_data_mgr.tl_activity_data
    self.activity_tab_data_dict = {}
    self.tl_activity_btn_dict = {}
    self.activity_item_dict = {}
    self.progress_item_dict = {}
    self.reward_item_list = {}

    self.daily_recharge_ui = DailyRechargeUI.New()
    self.first_recharge_ui = FirstRechargeUI.New()
    self.festival_activity_ui = FestivalActivityUI.New()
    self.festival_exchange_ui = FestivalExchangeUI.New()
    self.recharge_draw_ui = RechargeDrawUI.New()

    self.show_frame_func = {
        [CSConst.LimitActivityType.Activity] = "ShowActivityFrame",
        [CSConst.LimitActivityType.FirstRecharge] = "ShowFirstRechargeFrame",
        [CSConst.LimitActivityType.DailyRecharge] = "ShowDailyRechargeFrame",
        [CSConst.LimitActivityType.FestivalActivity] = "ShowFestivalActivityFrame",
        [CSConst.LimitActivityType.FestivalExchange] = "ShowFestivalExchangeFrame",
        [CSConst.LimitActivityType.RechargeDraw] = "ShowRechargeDrawFrame",
    }

    self.update_frame_func = {
        [CSConst.LimitActivityType.FestivalActivity] = "UpdateFestivalActivityFrame",
        [CSConst.LimitActivityType.FestivalExchange] = "UpdateFestivalExchangeFrame",
        [CSConst.LimitActivityType.RechargeDraw] = "UpdateRechargeDrawFrame",
    }

    self.hide_frame_func = {
        [CSConst.LimitActivityType.Activity] = "HideActivityFrame",
        [CSConst.LimitActivityType.FirstRecharge] = "HideFirstRechargeFrame",
        [CSConst.LimitActivityType.DailyRecharge] = "HideDailyRechargeFrame",
        [CSConst.LimitActivityType.FestivalActivity] = "HideFestivalActivityFrame",
        [CSConst.LimitActivityType.FestivalExchange] = "HideFestivalExchangeFrame",
        [CSConst.LimitActivityType.RechargeDraw] = "HideRechargeDrawFrame",
    }
end

function TLActivityUI:OnGoLoadedOk(res_go)
    TLActivityUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function TLActivityUI:Hide()
    self:ClearRes()
    TLActivityUI.super.Hide(self)
end

function TLActivityUI:Show(activity_id)
    self:ClearRes()
    self.activity_id = activity_id
    self.open_activity_list = self.dy_tl_activity_data:GetOpenActivityList()
    if not next(self.open_activity_list) and not next(self.tl_activity_btn_dict) then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.NO_TL_ACTIVITY)
        return
    end
    if self.is_res_ok then
        self:InitUI()
    end
    TLActivityUI.super.Show(self)
end

function TLActivityUI:ClearRes()
    self.activity_id = nil
    self:ClearCurActivitySelectState()
    self:ClearTLActivityTabBtn()
    self:ClearActivityItem()
    self:ClearActivityRewardItem()
    self:RemoveRedPointList(self.red_point_list)
    self.red_point_list = {}
end

function TLActivityUI:InitRes()
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "TLActivityUI")

    self.tab_btn_list = self.main_panel:FindChild("TabPanel/View/Content")
    self.tab_item = self.tab_btn_list:FindChild("ActivityItem")
    self.tab_btn_list_content_rect = self.main_panel:FindChild("TabPanel/View/Content"):GetComponent("RectTransform")
    self.tl_activity_panel = self.main_panel:FindChild("TlActivityPanel")
    local title_panel = self.tl_activity_panel:FindChild("Title")
    self.title_img = title_panel:FindChild("Poster"):GetComponent("Image")
    self.activity_desc = title_panel:FindChild("Desc/Text"):GetComponent("Text")
    self.activity_list = self.tl_activity_panel:FindChild("View/Content")
    self.activity_list_rect = self.activity_list:GetComponent("RectTransform")
    self.activity_item = self.activity_list:FindChild("ActivityItem")
    self.activity_item:FindChild("EnterBtn/Text"):GetComponent("Text").text = UIConst.Text.CLICK_TO_ENTER

    self.activity_info_panel = self.main_panel:FindChild("ActivityInfoPanel")
    local info_content = self.activity_info_panel:FindChild("Content")
    self:AddClick(info_content:FindChild("Top/CloseBtn"), function ()
        self.activity_info_panel:SetActive(false)
    end)
    self.activity_info_title = info_content:FindChild("Top/Text"):GetComponent("Text")
    self.progress_list = info_content:FindChild("ProgressList/View/Content")
    self.progress_list_rect = self.progress_list:GetComponent("RectTransform")
    self.progress_item = self.progress_list:FindChild("Item")
    local status_panel = self.progress_item:FindChild("Bottom/Status")
    status_panel:FindChild("GetBtn/Text"):GetComponent("Text").text = UIConst.Text.RECEIVE_TEXT
    status_panel:FindChild("AlreadyGet/Text"):GetComponent("Text").text = UIConst.Text.ALREADY_RECEIVE_TEXT
    self.reward_item = self.progress_item:FindChild("Bottom/AwardItemList/View/Content/Item")
    local progress_btn = info_content:FindChild("BtnPanel/ProgressBtn")
    progress_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.PLAYER_ACTIVITY_PROGRESS
    self:AddClick(progress_btn, function ()
        self:ShowActivityRank()
    end)
    self.daily_recharge_ui:InitRes(self)
    self.first_recharge_ui:InitRes(self)
    self.festival_activity_ui:InitRes(self)
    self.festival_exchange_ui:InitRes(self)
    self.recharge_draw_ui:InitRes(self)
end

function TLActivityUI:InitUI()
    self:InitTabBtn()
    -- 默认选中的活动
    local activity_id = self.activity_id or self.open_activity_list[1].id
    self:UpdateActivity(activity_id)
    self:TurnToMiddleTag(activity_id)
end

function TLActivityUI:TurnToMiddleTag(activity_id)
    local index
    for i,v in ipairs(self.open_activity_list) do
        if activity_id == v.id then
            index = i
        end
    end
    self.tab_btn_list_content_rect.anchoredPosition = Vector2.New(- (index - 1) * btn_width, 0)
end

--  生成顶部条按钮列表
function TLActivityUI:InitTabBtn()
    self.red_point_list = {}
    self:ClearTLActivityTabBtn()
    local activity_list = SpecMgrs.data_mgr:GetAllTLActivityData()
    self.open_activity_list = self.dy_tl_activity_data:GetOpenActivityList()
    for _, activity_data in ipairs(self.open_activity_list) do
        local activity_tab_btn = self:GetUIObject(self.tab_item, self.tab_btn_list)
        self.activity_tab_data_dict[activity_data.id] = {
            btn = activity_tab_btn,
            init_func = self[self.show_frame_func[activity_data.type]],
            hide_func = self[self.hide_frame_func[activity_data.type]],
            update_func = self[self.update_frame_func[activity_data.type]],
            data = activity_data,
        }
        self.tl_activity_btn_dict[activity_data.id] = activity_tab_btn
        UIFuncs.AssignSpriteByIconID(activity_data.icon, activity_tab_btn:FindChild("Icon"):GetComponent("Image"))
        activity_tab_btn:FindChild("TextBg/Text"):GetComponent("Text").text = activity_data.activity_name
        self:AddClick(activity_tab_btn, function ()
            self:UpdateActivity(activity_data.id)
        end)
        local red_point = SpecMgrs.redpoint_mgr:AddRedPoint(self, activity_tab_btn, 1, {activity_data.system_name}, nil, Vector2.New(0.9, 0.9), Vector2.New(0.9, 0.9))
        table.insert(self.red_point_list, red_point)
    end
end

function TLActivityUI:Update(delta_time)
    if not self.is_res_ok or not self.is_visible then return end
    local cur_data = self.activity_tab_data_dict[self.cur_activity_id]
    if cur_data.update_func then
        cur_data.update_func(self, delta_time)
    end
end

--  显示活动
function TLActivityUI:ShowActivityFrame(data)
    self.tl_activity_panel:SetActive(true)
    self:InitActivityList(data)
end

function TLActivityUI:ShowFirstRechargeFrame()
    self.first_recharge_ui:Show()
end

function TLActivityUI:ShowDailyRechargeFrame(data)
    self.daily_recharge_ui:Show(data.recharge_activity)
end

function TLActivityUI:ShowFestivalActivityFrame(data)
    self.festival_activity_ui:Show(data)
end

function TLActivityUI:ShowFestivalExchangeFrame(data)
    self.festival_exchange_ui:Show(data.festival_activity)
end

function TLActivityUI:ShowRechargeDrawFrame(data)
    self.recharge_draw_ui:Show(data)
end

--  显示活动 end

--  update活动

function TLActivityUI:UpdateFestivalActivityFrame(delta_time)
    self.festival_activity_ui:Update(delta_time)
end

function TLActivityUI:UpdateFestivalExchangeFrame(delta_time)
    self.festival_exchange_ui:Update(delta_time)
end

function TLActivityUI:UpdateRechargeDrawFrame(delta_time)
    self.recharge_draw_ui:Update(delta_time)
end

--  update活动end

--  隐藏活动
function TLActivityUI:HideActivityFrame()
    self.tl_activity_panel:SetActive(false)
end

function TLActivityUI:HideFirstRechargeFrame()
    self.first_recharge_ui:Hide()
end

function TLActivityUI:HideDailyRechargeFrame()
    self.daily_recharge_ui:Hide()
end

function TLActivityUI:HideFestivalActivityFrame()
    self.festival_activity_ui:Hide()
end

function TLActivityUI:HideFestivalExchangeFrame()
    self.festival_exchange_ui:Hide()
end

function TLActivityUI:HideRechargeDrawFrame()
    self.recharge_draw_ui:Hide()
end
--  隐藏活动 end

function TLActivityUI:UpdateActivity(activity_id)
    if self.cur_activity_id == activity_id then return end
    if self.cur_activity_id then
        local last_activity_data = self.activity_tab_data_dict[self.cur_activity_id]
        last_activity_data.btn:FindChild("Select"):SetActive(false)
        last_activity_data.hide_func(self)
    end
    self.cur_activity_id = activity_id
    if not self.cur_activity_id then return end
    local cur_activity_data = self.activity_tab_data_dict[self.cur_activity_id]
    cur_activity_data.btn:FindChild("Select"):SetActive(true)
    cur_activity_data.init_func(self, cur_activity_data.data)
end

function TLActivityUI:InitActivityList(data)
    local activity_id = data.activity
    local activity_data = SpecMgrs.data_mgr:GetActivityData(activity_id)
    local state = self.dy_activity_data:GetActivityState(activity_id)
    local format = state == CSConst.ActivityState.started and UIConst.Text.ACTIVITY_COUNT_DOWN or UIConst.Text.ACTIVITY_END_COUNT_DOWN
    local time_line = state == CSConst.ActivityState.started and activity_data.activity_stop_timestamp or activity_data.activity_end_timestamp
    UIFuncs.AssignSpriteByIconID(activity_data.poster, self.title_img)
    self.activity_desc.text = activity_data.activity_desc

    self:ClearActivityItem()
    local activity_list = self.dy_activity_data:GetActivityList(activity_id)
    for i, activity in ipairs(activity_list) do
        local item = self:GetUIObject(self.activity_item, self.activity_list)
        self.activity_item_dict[activity] = {item = item, index = i}
        local activity_data = SpecMgrs.data_mgr:GetActivityDetailData(activity)
        item:FindChild("Title"):GetComponent("Text").text = activity_data.name
        UIFuncs.AssignSpriteByIconID(activity_data.activity_bg, item:FindChild("ActivityPoster"):GetComponent("Image"))
        local progress_info_text = item:FindChild("Info/CurProgress"):GetComponent("Text")
        local cur_progress = self.dy_activity_data:GetActivityProgress(activity_id, activity)
        local next_progress = self.dy_activity_data:GetCurActivityProgressIndex(activity_id, activity)
        progress_info_text.text = string.format(UIConst.Text.KEY_VALUE, activity_data.name, UIFuncs.GetPerStr(cur_progress, activity_data.activity_cond_list[next_progress], cur_progress >= activity_data.activity_cond_list[next_progress]))
        local count_down = item:FindChild("Info/CountDown")
        local count_down_text = count_down:GetComponent("Text")
        if state == CSConst.ActivityState.invalid then
            count_down_text.text = UIConst.Text.ACTIVITY_IS_END
        else
            self:AddDynamicUI(count_down, function ()
                count_down_text.text = string.format(format, UIFuncs.TimeDelta2Str(time_line - Time:GetServerTime(), 4, UIConst.LongCDRemainFormat))
            end, 1, 0)
        end
        local enter_btn = item:FindChild("EnterBtn")
        enter_btn:FindChild("RedPoint"):SetActive(self.dy_activity_data:GetCurActivityState(activity_id, activity) == CSConst.RewardState.pick)
        self:AddClick(enter_btn, function ()
            self:ShowActivityInfoPanel(activity, activity_id)
        end)
    end
    self.activity_list_rect.anchoredPosition = Vector2.zero
    self.tl_activity_panel:SetActive(true)
end

function TLActivityUI:ShowActivityInfoPanel(activity, activity_id)
    self:ClearActivityRewardItem()
    local activity_detail_data = SpecMgrs.data_mgr:GetActivityDetailData(activity)
    local reward_data_list = self.dy_activity_data:GetActivityRewardList(activity_id, activity)
    self.activity_info_title.text = activity_detail_data.name
    if not reward_data_list then return end
    self.cur_activity = activity
    for i, reward_id in ipairs(reward_data_list) do
        local reward_state = self.dy_activity_data:GetActivityRewardState(activity_id, reward_id)
        local progress_item = self:GetUIObject(self.progress_item, self.progress_list)
        local progress_data = {item = progress_item, index = i}
        local cur_progress = self.dy_activity_data:GetActivityProgress(activity_id, activity)
        local progress_index = self.dy_activity_data:GetProgressIndex(activity, reward_id)
        local progress_str = UIFuncs.GetPerStr(cur_progress, activity_detail_data.activity_cond_list[progress_index], cur_progress >= activity_detail_data.activity_cond_list[progress_index])
        progress_item:FindChild("Title/Text"):GetComponent("Text").text = string.format(UIConst.Text.ACTIVITY_PROGRESS_FORMAT, progress_index, activity_detail_data.name, progress_str)
        local status_panel = progress_item:FindChild("Bottom/Status")
        local get_btn = status_panel:FindChild("GetBtn")
        get_btn:SetActive(reward_state ~= CSConst.RewardState.picked)
        get_btn:FindChild("Disable"):SetActive(reward_state == CSConst.RewardState.unpick)
        get_btn:GetComponent("Button").interactable = reward_state == CSConst.RewardState.pick
        status_panel:FindChild("AlreadyGet"):SetActive(reward_state == CSConst.RewardState.picked)
        if reward_state == CSConst.RewardState.pick then
            progress_data.effect = UIFuncs.AddCompleteEffect(self, get_btn)
        end
        self.progress_item_dict[reward_id] = progress_data
        self:AddClick(get_btn, function ()
            self:SendGetActivityReward(reward_id)
        end)
        local reward_list = progress_item:FindChild("Bottom/AwardItemList/View/Content")
        local reward_data = SpecMgrs.data_mgr:GetActivityRewardData(reward_id)
        for i, reward_item in ipairs(reward_data.reward_item_list) do
            local item = self:GetUIObject(self.reward_item, reward_list)
            table.insert(self.reward_item_list, item)
            UIFuncs.InitItemGo({
                go = item,
                item_id = reward_item,
                ui = self,
                count = reward_data.reward_num_list[i],
            })
        end
        reward_list:GetComponent("RectTransform").anchoredPosition = Vector2.zero
    end
    self.progress_list_rect.anchoredPosition = Vector2.zero
    self.activity_info_panel:SetActive(true)
end

function TLActivityUI:UpdateActivityState(_, activity_id, state)
    local cur_activity = SpecMgrs.data_mgr:GetTLActivityData(self.cur_activity_id).activity
    if state == CSConst.ActivityState.started then
        self.open_activity_list = self.dy_tl_activity_data:GetOpenActivityList()
        self:ClearCurActivitySelectState()
        self:InitTabBtn()
        self:UpdateActivity(cur_activity)
    elseif state == CSConst.ActivityState.stopped then
        if activity_id == cur_activity and self.tl_activity_btn_dict[activity_id] then
            for _, data in pairs(self.activity_item_dict) do
                local activity_data = SpecMgrs.data_mgr:GetActivityData(activity_id)
                local tl_count_down = data.item:FindChild("Info/CountDown")
                local tl_count_down_text = tl_count_down:GetComponent("Text")
                self:RemoveDynamicUI(tl_count_down)
                self:AddDynamicUI(tl_count_down, function ()
                    tl_count_down_text.text = string.format(UIConst.Text.ACTIVITY_END_COUNT_DOWN, UIFuncs.TimeDelta2Str(activity_data.activity_stop_timestamp - Time:GetServerTime(), 4, UIConst.LongCDRemainFormat))
                end)
            end
        end
    elseif state == CSConst.ActivityState.invalid then
        self:CloseTLActivity(activity_id)
    end
end

function TLActivityUI:CloseTLActivity(activity_id)
    local cur_activity_data = self.activity_tab_data_dict[activity_id]
    if not cur_activity_data then return end
    if self.cur_activity_id == activity_id then
        cur_activity_data.btn:FindChild("Select"):SetActive(false)
        self.cur_activity_id = nil
        self.activity_info_panel:SetActive(false)
        self.open_activity_list = self.dy_tl_activity_data:GetOpenActivityList()
        -- 默认选中的活动
        self:UpdateActivity(self.open_activity_list[1].id)
    end
    self:DelUIObject(cur_activity_data.btn)
    self.activity_tab_data_dict[activity_id] = nil
    self.tl_activity_btn_dict[activity_id] = nil
end

function TLActivityUI:SendGetActivityReward(reward_id)
    SpecMgrs.msg_mgr:SendGetActivityReward({reward_id = reward_id}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_ACTIVITY_REWARD_FAILED)
        else
            local progress_data = self.progress_item_dict[reward_id]
            local activity_data = SpecMgrs.data_mgr:GetTLActivityData(self.cur_activity_id)
            local cur_reward_index = self.dy_activity_data:GetActivityRewardIndex(activity_data.activity, self.cur_activity, reward_id)
            progress_data.item:SetSiblingIndex(cur_reward_index)
            local get_btn = progress_data.item:FindChild("Bottom/Status/GetBtn")
            if progress_data.effect then self:RemoveUIEffect(get_btn, progress_data.effect) end
            get_btn:SetActive(false)
            progress_data.item:FindChild("Bottom/Status/AlreadyGet"):SetActive(true)
            progress_data.index = cur_reward_index
            local activity_data = self.activity_item_dict[self.cur_activity]
            local cur_activity_index = self.dy_activity_data:GetActivityIndex(activity_data.activity, self.cur_activity)
            activity_data.item:FindChild("EnterBtn/RedPoint"):SetActive(self.dy_activity_data:GetCurActivityState(activity_data.activity, self.cur_activity) == CSConst.RewardState.pick)
            if not cur_activity_index or cur_activity_index == activity_data.index then return end
            activity_data.item:SetSiblingIndex(cur_activity_index)
        end
    end)
end

function TLActivityUI:ShowActivityRank()
    local activity_data = SpecMgrs.data_mgr:GetActivityDetailData(self.cur_activity)
    if not activity_data or not activity_data.rank_name then return end
    SpecMgrs.msg_mgr:SendGetActivityRank({rank_name = activity_data.rank_name}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_ACTIVITY_RANK_FAILED)
        else
            resp.rank_data = SpecMgrs.data_mgr:GetTotalRankData(UIConst.Rank.TLActivity)
            resp.rank_gist_name = SpecMgrs.data_mgr:GetRankData(activity_data.rank_name).tag_name
            SpecMgrs.ui_mgr:ShowUI("RankUI", resp)
        end
    end)
end

function TLActivityUI:ClearCurActivitySelectState()
    if not self.cur_activity_id then return end
    local cur_activity_data = self.activity_tab_data_dict[self.cur_activity_id]
    self.cur_activity_id = nil
    if not cur_activity_data then return end
    cur_activity_data.btn:FindChild("Select"):SetActive(false)
    --cur_activity_data.panel:SetActive(false)
end

function TLActivityUI:ClearTLActivityTabBtn()
    for activity_id, item in pairs(self.tl_activity_btn_dict) do
        self:DelUIObject(item)
        if self.activity_tab_data_dict[activity_id] then
            self.activity_tab_data_dict[activity_id].hide_func(self)
        end
        self.activity_tab_data_dict[activity_id] = {}
    end
    self.tl_activity_btn_dict = {}
end

function TLActivityUI:ClearActivityItem()
    for _, activity_data in pairs(self.activity_item_dict) do
        self:RemoveDynamicUI(activity_data.item:FindChild("Info/CountDown"))
        self:DelUIObject(activity_data.item)
    end
    self.activity_item_dict = {}
end

function TLActivityUI:ClearActivityRewardItem()
    for _, item in ipairs(self.reward_item_list) do
        self:DelUIObject(item)
    end
    self.reward_item_list = {}
    for _, progress_data in pairs(self.progress_item_dict) do
        if progress_data.effect then self:RemoveUIEffect(progress_data.item:FindChild("Bottom/Status/GetBtn"), progress_data.effect) end
        self:DelUIObject(progress_data.item)
    end
    self.progress_item_dict = {}
end

return TLActivityUI