local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local RankActivityUI = class("UI.RankActivityUI", UIBase)

local kDisableColor = Color.New(0.4, 0.4, 0.4)
local kActicitySpacing = 30

function RankActivityUI:DoInit()
    RankActivityUI.super.DoInit(self)
    self.prefab_path = "UI/Common/RankActivityUI"
    self.dy_activity_data = ComMgrs.dy_data_mgr.activity_data
    self.reward_item_list = {}
    self.rank_activity_item_dict = {}
end

function RankActivityUI:OnGoLoadedOk(res_go)
    RankActivityUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function RankActivityUI:Hide()
    self.rank_activity_id = nil
    self.dy_activity_data:UnregisterUpdateRankActivityRankingEvent("RankActivityUI")
    self.dy_activity_data:UnregisterUpdateRankActivityStateEvent("RankActivityUI")
    self:RemoveDynamicUI(self.activity_count_down)
    self:ClearCurPanel()
    self:ClearRankRewardItem()
    self:ClearRankActivityItem()
    RankActivityUI.super.Hide(self)
end

function RankActivityUI:Show(rank_activity_id)
    self.rank_activity_id = rank_activity_id
    if self.is_res_ok then
        self:InitUI()
    end
    RankActivityUI.super.Show(self)
end

function RankActivityUI:InitRes()
    local poster_panel = self.main_panel:FindChild("PosterPanel")
    self.poster_img = poster_panel:GetComponent("Image")
    self:AddClick(poster_panel:FindChild("CloseBtn"), function ()
        self:Hide()
    end)
    self.rank_name = poster_panel:FindChild("RankName"):GetComponent("Image")
    self.activity_time = poster_panel:FindChild("ActivityTime"):GetComponent("Text")
    self.activity_count_down = poster_panel:FindChild("CountDown")
    self.activity_count_down_text = self.activity_count_down:GetComponent("Text")
    self:AddClick(poster_panel:FindChild("SelfRank"), function ()
        SpecMgrs.ui_mgr:ShowUI("RankActivityInfoUI", self.cur_rank_activity_id)
    end)
    self.self_rank = poster_panel:FindChild("SelfRank/Text"):GetComponent("Text")
    self.advertising = poster_panel:FindChild("Advertising"):GetComponent("Text")
    self.first_grade_text = poster_panel:FindChild("FirstGrade"):GetComponent("Text")

    self.designation = poster_panel:FindChild("Designation")
    self.designation_img = self.designation:GetComponent("Image")
    self.reward_list = poster_panel:FindChild("RewardList")
    self.reward_item = self.reward_list:FindChild("Item")
    self.tip = poster_panel:FindChild("Tip"):GetComponent("Text")
    self.detail_btn = poster_panel:FindChild("DetailBtn")
    self.detail_btn:GetComponent("Text").text = UIConst.Text.RANK_ACTIVITY_DETAIL_TIP
    self:AddClick(self.detail_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("RankActivityInfoUI", self.cur_rank_activity_id)
    end)

    local activity_list_view = self.main_panel:FindChild("ActivityList/View")
    self.activity_list_view_width = activity_list_view:GetComponent("RectTransform").rect.width
    self.activity_list = activity_list_view:FindChild("Content")
    self.activity_list_rect = self.activity_list:GetComponent("RectTransform")
    self.activity_item = self.activity_list:FindChild("Activity")
    self.activity_item_width = self.activity_item:GetComponent("RectTransform").sizeDelta.x
end

function RankActivityUI:InitUI()
    self.dy_activity_data:RefreshRankActivity()
    self:InitRankActivityList()
    self:UpdateRankActivity(self.rank_activity_id)
    self.dy_activity_data:RegisterUpdateRankActivityRankingEvent("RankActivityUI", self.UpdateActivityRank, self)
    self.dy_activity_data:RegisterUpdateRankActivityStateEvent("RankActivityUI", self.UpdateActivityState, self)
end

function RankActivityUI:InitRankActivityPosterPanel()
    local rank_activity_data = SpecMgrs.data_mgr:GetRushActivityData(self.cur_rank_activity_id)
    local rank_reward_data = SpecMgrs.data_mgr:GetRushRewardData(rank_activity_data.reward)
    local rank_activity_info = self.dy_activity_data:GetRankActivityInfo(self.cur_rank_activity_id)
    UIFuncs.AssignSpriteByIconID(rank_activity_data.poster, self.poster_img)
    UIFuncs.AssignSpriteByIconID(rank_activity_data.rank_title_icon, self.rank_name)
    self.rank_name:SetNativeSize()
    local start_date_str = UIFuncs.TimeToFormatStr(rank_activity_info.start_ts, UIConst.DateTimeFormat)
    local end_date_str = UIFuncs.TimeToFormatStr(rank_activity_info.stop_ts, UIConst.DateTimeFormat)
    self.activity_time.text = string.format(UIConst.Text.RANK_ACTIVITY_TIME_FORMAT, start_date_str, end_date_str)
    self:RemoveDynamicUI(self.activity_count_down)
    if rank_activity_info.state == CSConst.ActivityState.stopped then
        self.activity_count_down_text.text = string.format(UIConst.Text.RANK_ACTIVITY_CLOSE, 50)
    else
        self:AddDynamicUI(self.activity_count_down, function ()
            self.activity_count_down_text.text = string.format(UIConst.Text.RANK_ACTIVITY_COUNT_DOWN, UIFuncs.TimeDelta2Str(rank_activity_info.stop_ts - Time:GetServerTime(), 4, UIConst.LongCDRemainFormat))
        end, 1, 0)
    end
    if rank_activity_info.self_rank then
        self.self_rank.text = string.format(UIConst.Text.DYNASTY_RANK_FROMAT, rank_activity_info.self_rank)
    else
        self.self_rank.text = UIConst.Text.WITHOUT_RANK
    end
    self.advertising.text = rank_activity_data.text
    self.first_grade_text.text = rank_reward_data.title and UIConst.Text.TITLE_REWARD_TEXT or  UIConst.Text.RANK_FIRST_GRADE_TEXT
    self.designation:SetActive(rank_reward_data.title ~= nil)
    self.reward_list:SetActive(not rank_reward_data.title)
    if rank_reward_data.title then
        local rank_title_item = SpecMgrs.data_mgr:GetItemData(rank_reward_data.title)
        UIFuncs.AssignSpriteByIconID(rank_title_item.icon, self.designation_img)
    else
        self:ClearRankRewardItem()
        local reward_data = SpecMgrs.data_mgr:GetRushItemData(rank_reward_data.rank_reward[1])
        for i, item_id in ipairs(reward_data.reward_item) do
            local reward_item = self:GetUIObject(self.reward_item, self.reward_list)
            table.insert(self.reward_item_list, reward_item)
            UIFuncs.InitItemGo({
                go = reward_item,
                item_id = item_id,
                ui = self,
                count = reward_data.reward_num[i],
            })
        end
    end
    self.tip.text = rank_activity_data.tips
end

function RankActivityUI:InitRankActivityList()
    self:ClearRankActivityItem()
    local rank_activity_list = self.dy_activity_data:GetRankActivityList()
    for _, rank_activity_id in ipairs(rank_activity_list) do
        local rank_activity_data = SpecMgrs.data_mgr:GetRushActivityData(rank_activity_id)
        local rank_activity_info = self.dy_activity_data:GetRankActivityInfo(rank_activity_id)
        local rank_activity_item = self:GetUIObject(self.activity_item, self.activity_list)
        self.rank_activity_item_dict[rank_activity_id] = rank_activity_item
        rank_activity_item:FindChild("Active"):SetActive(rank_activity_info.state == CSConst.ActivityState.started)
        rank_activity_item:FindChild("Disable"):SetActive(rank_activity_info.state == CSConst.ActivityState.stopped)
        local icon_image = rank_activity_item:FindChild("Icon"):GetComponent("Image")
        icon_image.color = rank_activity_info.state == CSConst.ActivityState.started and Color.white or kDisableColor
        UIFuncs.AssignSpriteByIconID(rank_activity_data.unit_icon, icon_image)
        rank_activity_item:FindChild("Title"):GetComponent("Text").text = rank_activity_data.name
        local rank_text = rank_activity_info.self_rank and string.format(UIConst.Text.DYNASTY_RANK_FROMAT, rank_activity_info.self_rank) or UIConst.Text.WITHOUT_RANK
        rank_activity_item:FindChild("Info/CurRank"):GetComponent("Text").text = rank_text
        local count_down = rank_activity_item:FindChild("Info/CountDown")
        local count_down_text = count_down:GetComponent("Text")
        if rank_activity_info.state == CSConst.ActivityState.started then
            self:AddDynamicUI(count_down, function ()
                count_down_text.text = UIFuncs.TimeDelta2Str(rank_activity_info.stop_ts - Time:GetServerTime(), 4, UIConst.LongCDRemainFormat)
            end, 1, 0)
        else
            count_down_text.text = UIConst.Text.ALREADY_FINISH_TEXT
        end
        self:AddClick(rank_activity_item, function ()
            self:UpdateRankActivity(rank_activity_id)
        end)
    end
    local activity_count = #rank_activity_list
    local content_width = activity_count * (self.activity_item_width + kActicitySpacing) - kActicitySpacing
    local offset_x = (content_width - self.activity_list_view_width) / 2
    self.activity_list_rect.anchoredPosition = Vector2.New(-offset_x, 0)
end

function RankActivityUI:UpdateRankActivity(rank_activity_id)
    self:ClearCurPanel()
    self.cur_rank_activity_id = rank_activity_id
    local cur_rank_activity_item = self.rank_activity_item_dict[self.cur_rank_activity_id]
    cur_rank_activity_item:FindChild("Select"):SetActive(true)
    self:InitRankActivityPosterPanel()
end

function RankActivityUI:UpdateActivityRank(_, activity_id, rank)
    local rank_text = rank and string.format(UIConst.Text.DYNASTY_RANK_FROMAT, rank) or UIConst.Text.WITHOUT_RANK
    if self.cur_rank_activity_id == activity_id then
        self.self_rank.text = rank_text
    end
    local rank_activity_item = self.rank_activity_item_dict[activity_id]
    if rank_activity_item then
        rank_activity_item:FindChild("Info/CurRank"):GetComponent("Text").text = rank_text
    end
end

function RankActivityUI:UpdateActivityState(_, activity_id, state)
    local rank_activity_item = self.rank_activity_item_dict[activity_id]
    if not rank_activity_item then return end
    if state == CSConst.ActivityState.invalid then
        if self.cur_rank_activity_id == activity_id then
            local new_activity_id = self.dy_activity_data:GetNewestRankActivity()
            if new_activity_id then
                self:UpdateRankActivity(new_activity_id)
            else
                self:Hide()
                return
            end
        end
        self:RemoveDynamicUI(rank_activity_item:FindChild("Info/CountDown"))
        self:DelUIObject(rank_activity_item)
        self.rank_activity_item_dict[activity_id] = nil
    else
        local count_down = rank_activity_item:FindChild("Info/CountDown")
        self:RemoveDynamicUI(count_down)
        count_down:GetComponent("Text").text = UIConst.Text.ALREADY_FINISH_TEXT
    end
end

function RankActivityUI:ClearCurPanel()
    if not self.cur_rank_activity_id then return end
    local last_rank_activity_item = self.rank_activity_item_dict[self.cur_rank_activity_id]
    if last_rank_activity_item then last_rank_activity_item:FindChild("Select"):SetActive(false) end
    self.cur_rank_activity_id = nil
end

function RankActivityUI:ClearRankRewardItem()
    for _, item in ipairs(self.reward_item_list) do
        self:DelUIObject(item)
    end
    self.reward_item_list = {}
end

function RankActivityUI:ClearRankActivityItem()
    for _, item in pairs(self.rank_activity_item_dict) do
        self:RemoveDynamicUI(item:FindChild("Info/CountDown"))
        self:DelUIObject(item)
    end
    self.rank_activity_item_dict = {}
end

return RankActivityUI