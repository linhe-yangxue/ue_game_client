local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local RankActivityInfoUI = class("UI.RankActivityInfoUI", UIBase)

local kOperationTabIndex = {
    RankList = 1,
    RankRewarList = 2,
}

function RankActivityInfoUI:DoInit()
    RankActivityInfoUI.super.DoInit(self)
    self.prefab_path = "UI/Common/RankActivityInfoUI"
    self.dy_activity_data = ComMgrs.dy_data_mgr.activity_data
    self.rank_reward_op_data = {}
    self.rank_reward_item_list = {}
    self.reward_item_list = {}
    self.rank_item_list = {}
end

function RankActivityInfoUI:OnGoLoadedOk(res_go)
    RankActivityInfoUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function RankActivityInfoUI:Hide()
    self:RemoveDynamicUI(self.count_down)
    self:ClearCurRankActivityPanel()
    self:ClearRankListItem()
    self:ClearRankRewardItem()
    RankActivityInfoUI.super.Hide(self)
end

function RankActivityInfoUI:Show(rank_activity_id)
    self.rank_activity_id = rank_activity_id
    self.rank_activity_data = SpecMgrs.data_mgr:GetRushActivityData(self.rank_activity_id)
    SpecMgrs.msg_mgr:SendGetRankActivityList({rank_name = self.rank_activity_data.rank}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowTipMsg(string.format(UIConst.Text.GET_RANK_ACTIVITY_RANK_LIST_NOTDATE, self.rank_activity_data.name))
        else
            self.rank_list_info = resp
            self:_Show()
        end
    end)
end

function RankActivityInfoUI:_Show()
    if self.is_res_ok then
        self:InitUI()
    end
    RankActivityInfoUI.super.Show(self)
end

function RankActivityInfoUI:InitRes()
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "RankActivityInfoUI")

    self.poster = self.main_panel:FindChild("Poster")
    self.poster_img = self.poster:GetComponent("Image")
    self.rank_name = self.poster:FindChild("RankName"):GetComponent("Image")
    self.rank_activity_time = self.poster:FindChild("Time"):GetComponent("Text")
    self.count_down = self.poster:FindChild("CountDown")
    self.count_down_text = self.count_down:GetComponent("Text")

    local content = self.main_panel:FindChild("Content")
    self.rank_list_panel = content:FindChild("RankListPanel")
    local rank_list_head_panel = self.rank_list_panel:FindChild("RankListHead")
    rank_list_head_panel:FindChild("Rank"):GetComponent("Text").text = UIConst.Text.RANK_TEXT
    rank_list_head_panel:FindChild("Name"):GetComponent("Text").text = UIConst.Text.PLAYER_NAME_TEXT
    rank_list_head_panel:FindChild("Level"):GetComponent("Text").text = UIConst.Text.LEVEL_TEXT
    self.rank_head_text = rank_list_head_panel:FindChild("Score"):GetComponent("Text")
    self.rank_list_content = self.rank_list_panel:FindChild("View/Content")
    self.rank_list_content_rect = self.rank_list_content:GetComponent("RectTransform")
    self.rank_item = self.rank_list_content:FindChild("RankItem")
    self.empty_panel = self.rank_list_panel:FindChild("View/EmptyPanel")
    self.empty_panel:FindChild("Dialog/Text"):GetComponent("Text").text = UIConst.Text.NO_ONE_ON_RANK

    self.rank_reward_panel = content:FindChild("RankRewardPanel")
    self.rank_reward_content = self.rank_reward_panel:FindChild("View/Content")
    self.rank_reward_content_rect = self.rank_reward_content:GetComponent("RectTransform")
    self.rank_reward_item = self.rank_reward_content:FindChild("RankRewardItem")
    self.reward_item = self.rank_reward_item:FindChild("ItemList/Item")
    local tab_panel = content:FindChild("TabPanel")

    local rank_reward_data = {}
    local rank_reward_btn = tab_panel:FindChild("RankReward")
    rank_reward_data.btn = rank_reward_btn
    rank_reward_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.RANKING_REWARD_TEXT
    local rank_reward_select = rank_reward_btn:FindChild("Select")
    rank_reward_data.select = rank_reward_select
    rank_reward_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.RANKING_REWARD_TEXT
    rank_reward_data.panel = self.rank_reward_panel
    self:AddClick(rank_reward_btn, function ()
        self:UpdateRankActivityPanel(kOperationTabIndex.RankRewarList)
    end)
    self.rank_reward_op_data[kOperationTabIndex.RankRewarList] = rank_reward_data

    local rank_list_data = {}
    local rank_list_btn = tab_panel:FindChild("RankList")
    rank_list_data.btn = rank_list_btn
    rank_list_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.RANK_LIST_TAB_TEXT
    local rank_list_btn_select = rank_list_btn:FindChild("Select")
    rank_list_data.select = rank_list_btn_select
    rank_list_btn_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.RANK_LIST_TAB_TEXT
    rank_list_data.panel = self.rank_list_panel
    self:AddClick(rank_list_btn, function ()
        self:UpdateRankActivityPanel(kOperationTabIndex.RankList)
    end)
    self.rank_reward_op_data[kOperationTabIndex.RankList] = rank_list_data

    local bottom_panel = self.main_panel:FindChild("Bottom")
    self.self_rank = bottom_panel:FindChild("SelfRank"):GetComponent("Text")
    self.rank_up = bottom_panel:FindChild("RankUp"):GetComponent("Text")
end

function RankActivityInfoUI:InitUI()
    self.rank_reward_data = SpecMgrs.data_mgr:GetRushRewardData(self.rank_activity_data.reward)
    self.rank_activity_info = self.dy_activity_data:GetRankActivityInfo(self.rank_activity_id)
    self.rank_head_text.text = self.rank_activity_data.desc
    self:InitPosterPanel()
    self:InitRankRewardPanel()
    self:InitRankListPanel()
    self:UpdateRankActivityPanel(kOperationTabIndex.RankRewarList)
end

function RankActivityInfoUI:InitPosterPanel()
    UIFuncs.AssignSpriteByIconID(self.rank_activity_data.mini_poster, self.poster_img)
    UIFuncs.AssignSpriteByIconID(self.rank_activity_data.rank_title_icon, self.rank_name)
    self.rank_name:SetNativeSize()
    local start_date_str = UIFuncs.TimeToFormatStr(self.rank_activity_info.start_ts, UIConst.DateTimeFormat)
    local end_date_str = UIFuncs.TimeToFormatStr(self.rank_activity_info.stop_ts, UIConst.DateTimeFormat)
    self.rank_activity_time.text = string.format(UIConst.Text.RANK_ACTIVITY_TIME_FORMAT, start_date_str, end_date_str)
    if self.rank_activity_info.state == CSConst.ActivityState.stopped then
        self.count_down_text.text = string.format(UIConst.Text.RANK_ACTIVITY_CLOSE, 42)
    else
        self:AddDynamicUI(self.count_down, function ()
            self.count_down_text.text = string.format(UIConst.Text.RANK_ACTIVITY_COUNT_DOWN, UIFuncs.TimeDelta2Str(self.rank_activity_info.stop_ts - Time:GetServerTime(), 4, UIConst.LongCDRemainFormat))
        end, 1, 0)
    end
end

function RankActivityInfoUI:InitRankRewardPanel()
    self:ClearRankRewardItem()
    for i, range_data in ipairs(self.rank_reward_data.reward_range_list) do
        local rank_reward_data = SpecMgrs.data_mgr:GetRushItemData(range_data.rank_reward)
        local rank_reward_item = self:GetUIObject(self.rank_reward_item, self.rank_reward_content)
        table.insert(self.rank_reward_item_list, rank_reward_item)
        local rank_range_text = rank_reward_item:FindChild("RankRange/Text"):GetComponent("Text")
        local player_info = rank_reward_item:FindChild("PlayerInfo")
        player_info:SetActive(range_data.start_rank == range_data.end_rank)
        if range_data.start_rank == range_data.end_rank then
            rank_range_text.text = string.format(UIConst.Text.RANK_ACTIVITY_FORMAT, range_data.start_rank)
            -- 当前排名上榜玩家信息
            local role_info = self.rank_list_info.rank_list[range_data.start_rank]
            player_info:SetActive(role_info ~= nil)
            if role_info then
                local role_look_data = SpecMgrs.data_mgr:GetRoleLookData(role_info.role_id)
                local unit_data = SpecMgrs.data_mgr:GetUnitData(role_look_data.unit_id)
                UIFuncs.AssignSpriteByIconID(unit_data.icon, player_info:FindChild("IconBg/Icon"):GetComponent("Image"))
                local vip_img = player_info:FindChild("Info/Name/Vip")
                vip_img:SetActive(role_info.vip and role_info.vip > 0)
                if role_info.vip and role_info.vip > 0 then
                    local vip_data = SpecMgrs.data_mgr:GetVipData(role_info.vip)
                    UIFuncs.AssignSpriteByIconID(vip_data.icon, vip_img:GetComponent("Image"))
                end
                player_info:FindChild("Info/Name/Text"):GetComponent("Text").text = role_info.name
                player_info:FindChild("Info/Level"):GetComponent("Text").text = string.format(UIConst.Text.LEVEL, role_info.level)
            end
        else
            rank_range_text.text = string.format(UIConst.Text.RANK_ACTIVITY_FORMAT2, range_data.start_rank, range_data.end_rank)
        end
        -- 当前排名称号
        local designation = rank_reward_item:FindChild("Designation")
        designation:SetActive(range_data.start_rank == 1 and self.rank_reward_data.title ~= nil)
        if range_data.start_rank == 1 and self.rank_reward_data.title ~= nil then
            designation:FindChild("Text"):GetComponent("Text").text = UIConst.Text.RANK_UNIQ_TITLE_TEXT
            local rank_title_item = SpecMgrs.data_mgr:GetItemData(self.rank_reward_data.title)
            UIFuncs.AssignSpriteByIconID(rank_title_item.icon, designation:FindChild("Img"):GetComponent("Image"))
        end
        -- 排名奖励
        local item_list = rank_reward_item:FindChild("ItemList")
        for i, item_id in ipairs(rank_reward_data.reward_item) do
            local reward_item = self:GetUIObject(self.reward_item, item_list)
            table.insert(self.reward_item_list, reward_item)
            UIFuncs.InitItemGo({
                go = reward_item,
                ui = self,
                count = rank_reward_data.reward_num[i],
                item_id = item_id,
            })
        end
    end
    self.rank_reward_content_rect.anchoredPosition = Vector2.zero
end

function RankActivityInfoUI:InitRankListPanel()
    self:ClearRankListItem()
    local have_rank = self.rank_list_info.rank_list and #self.rank_list_info.rank_list > 0
    self.empty_panel:SetActive(not have_rank)
    if have_rank then
        for rank, rank_info in ipairs(self.rank_list_info.rank_list) do
            local rank_item = self:GetUIObject(self.rank_item, self.rank_list_content)
            table.insert(self.rank_item_list, rank_item)
            local rank_icon_id = UIConst.Icon.RankActivityRankIconList[rank]
            local rank_img = rank_item:FindChild("RankImg")
            local rank_text = rank_item:FindChild("RankText")
            rank_img:SetActive(rank_icon_id ~= nil)
            rank_text:SetActive(rank_icon_id == nil)
            if rank_icon_id then
                UIFuncs.AssignSpriteByIconID(rank_icon_id, rank_img:GetComponent("Image"))
            else
                rank_text:GetComponent("Text").text = rank
            end
            rank_item:FindChild("NamePanel/Name"):GetComponent("Text").text = rank_info.name
            local vip = rank_item:FindChild("NamePanel/Vip")
            vip:SetActive(rank_info.vip and rank_info.vip > 0)
            if rank_info.vip and rank_info.vip > 0 then
                local vip_data = SpecMgrs.data_mgr:GetVipData(rank_info.vip)
                UIFuncs.AssignSpriteByIconID(vip_data.icon, vip:GetComponent("Image"))
            end
            rank_item:FindChild("Level"):GetComponent("Text").text = string.format(UIConst.Text.LEVEL, rank_info.level)
            rank_item:FindChild("Score"):GetComponent("Text").text = UIFuncs.AddCountUnit(rank_info.rank_score)
        end
    end
    self.rank_list_content_rect.anchoredPosition = Vector2.zero
    local rank_text = self.rank_list_info.self_rank or UIConst.Text.TEMPLY_NOT
    self.self_rank.text = string.format(UIConst.Text.SELF_RANKING, rank_text)
    self.rank_up.text = string.format(UIConst.Text.KEY_VALUE, self.rank_activity_data.desc, math.floor(self.rank_list_info.self_rank_score or 0))
end

function RankActivityInfoUI:UpdateRankActivityPanel(op_index)
    self:ClearCurRankActivityPanel()
    self.cur_op_index = op_index
    local cur_op_data = self.rank_reward_op_data[self.cur_op_index]
    cur_op_data.select:SetActive(true)
    cur_op_data.panel:SetActive(true)
end

function RankActivityInfoUI:ClearCurRankActivityPanel()
    if not self.cur_op_index then return end
    local last_op_data = self.rank_reward_op_data[self.cur_op_index]
    last_op_data.select:SetActive(false)
    last_op_data.panel:SetActive(false)
    self.cur_op_index = nil
end

function RankActivityInfoUI:ClearRankRewardItem()
    for _, item in ipairs(self.reward_item_list) do
        self:DelUIObject(item)
    end
    self.reward_item_list = {}
    for _, item in ipairs(self.rank_reward_item_list) do
        self:DelUIObject(item)
    end
    self.rank_reward_item_list = {}
end

function RankActivityInfoUI:ClearRankListItem()
    for _, item in ipairs(self.rank_item_list) do
        self:DelUIObject(item)
    end
    self.rank_item_list = {}
end

return RankActivityInfoUI