local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local RankUI = class("UI.RankUI", UIBase)
local ItemUtil = require("BaseUtilities.ItemUtil")
local max_help_type = 2

function RankUI:DoInit()
    RankUI.super.DoInit(self)
    self.prefab_path = "UI/Common/RankUI"
    self.rank_info_list = {} -- {rank_list, self_rank, self_rank_score, rank_gist_name}
    self.tag_list = {}
    self.panel_list = {}
    self.rank_go_list = {}
    self.reward_go_list = {}
    self.reward_item_go_list = {}
    self.spec_rank_icon_list = SpecMgrs.data_mgr:GetParamData("rank_icon_list").icon_list
end

function RankUI:OnGoLoadedOk(res_go)
    RankUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function RankUI:Show(param_tb)
    if param_tb.rank_id_list then -- 自己发送消息给服务器
        for i,v in ipairs(param_tb.rank_id_list) do
            self:SendGetRankList(param_tb.rank_id)
        end
    elseif param_tb.group_id then
        local rank_id_list = SpecMgrs.data_mgr:GetTotalRankData("group_list")[param_tb.group_id]
        for i, v in ipairs(rank_id_list) do
            self:SendGetRankList(v)
        end
    else -- 直接展示
        table.insert(self.rank_info_list, param_tb)
    end
    if self.is_res_ok then
        self:InitUI()
    end
    RankUI.super.Show(self)
end

function RankUI:InitRes()
    local top_bar = self.main_panel:FindChild("TopBar")
    UIFuncs.InitTopBar(self, top_bar, "RankUI")
    self.title_text = top_bar:FindChild("CloseBtn/Title"):GetComponent("Text")
    self.tag_go = self.main_panel:FindChild("TagList")
    self.tag_parent = self.tag_go:FindChild("Viewport/Content")
    self.tag_temp = self.tag_parent:FindChild("Temp")
    self.tag_temp:SetActive(false)
    self.panel_parent = self.main_panel:FindChild("PanelList")
    self.rank_panel_temp = self.panel_parent:FindChild("RankPanelTemp")
    self.rank_panel_temp:FindChild("Title/Rank/Text"):GetComponent("Text").text = UIConst.Text.RANK
    self.rank_panel_temp:FindChild("Title/Player/Text"):GetComponent("Text").text = UIConst.Text.PLAYER_TEXT
    self.rank_panel_temp:FindChild("BottonBar/MyRank"):GetComponent("Text").text = UIConst.Text.MY_RANK
    self.rank_panel_temp:FindChild("NoOneOnRank"):GetComponent("Text").text = UIConst.Text.NO_ONE_ON_RANK
    self.rank_panel_temp:SetActive(false)
    self.rank_temp = self.rank_panel_temp:FindChild("Scroll View/Viewport/Content/Item")
    self.rank_temp:SetActive(false)
    self.reward_panel_temp = self.panel_parent:FindChild("RewardPanelTemp")
    self.reward_panel_temp:SetActive(false)
    self.reward_temp = self.reward_panel_temp:FindChild("Scroll View/Viewport/Content/Temp")
    self.reward_temp:SetActive(false)
    self.reward_item_temp = self.reward_temp:FindChild("Scroll View/Viewport/Content/Temp")
    self.reward_item_temp:SetActive(false)
    UIFuncs.GetIconGo(self, self.reward_item_temp)
end

function RankUI:GetRewardPanel(rank_data, self_rank)
    local reward_panel = self:GetUIObject(self.reward_panel_temp, self.panel_parent)
    local reward_tier = rank_data.reward_tier
    local reward_list = rank_data.reward_list
    local join_reward = rank_data.join_reward
    local reward_parent = reward_panel:FindChild("Scroll View/Viewport/Content")

    local self_rank_index
    if self_rank then
        for i, end_rank in ipairs(reward_tier) do
            if self_rank <= end_rank then
                self_rank_index = i
                break
            end
        end
    end
    for i, end_rank in ipairs(reward_tier) do
        local begin_rank = (reward_tier[i - 1] or 0) + 1
        local rank_str = begin_rank == end_rank and begin_rank or begin_rank .. "~" .. end_rank
        rank_str = string.format(UIConst.Text.RANK_FORMAT, rank_str)
        self:GetReward(reward_parent, rank_str, reward_list[i], self_rank_index and self_rank_index == i or false)
    end
    if rank_data.join_reward then
        local rank_str = string.format(UIConst.Text.RANK_ABOVE, reward_tier[#reward_tier] + 1)
        self:GetReward(reward_parent, rank_str, rank_data.join_reward,not self_rank_index)
    end
    reward_panel:FindChild("BottonBar/Text"):GetComponent("Text").text = rank_data.reward_desc
    table.insert(self.panel_list, reward_panel)
end

function RankUI:GetReward(praent, rank_str, reward_id, is_self_rank)
    local go = self:GetUIObject(self.reward_temp, praent)
    table.insert(self.reward_go_list, go)
    local reward_item_parent = go:FindChild("Scroll View/Viewport/Content")
    local item_data_list = ItemUtil.GetSortedRewardItemList(reward_id)
    for i, item_data in ipairs(item_data_list) do
        self:GetRewardItem(reward_item_parent, item_data)
    end
    go:FindChild("Rank/Text"):GetComponent("Text").text = rank_str
    go:GetComponent("Image").enabled = not is_self_rank
    go:FindChild("MyRank"):SetActive(is_self_rank)
    return go
end

function RankUI:GetRewardItem(parent, item_data)
    local item_go = self:GetUIObject(self.reward_item_temp, parent)
    UIFuncs.InitItemGo({ui = self, go = item_go:FindChild("Item"), item_data = item_data.item_data, count = item_data.count})
    table.insert(self.reward_item_go_list, item_go)
    return item_go
end

function RankUI:GetRankPanel(rank_list, self_rank, self_rank_score, rank_gist_name)
    local rank_panel = self:GetUIObject(self.rank_panel_temp, self.panel_parent)
    local rank_count = rank_list and #rank_list or 0
    if rank_count > 0 then
        local go_parent = rank_panel:FindChild("Scroll View/Viewport/Content")
        for rank, rank_info in ipairs(rank_list)do
            self:GetRankItem(go_parent, rank_info, rank, self_rank == rank)
        end
    end
    rank_panel:FindChild("NoOneOnRank"):SetActive(rank_count <= 0)
    rank_panel:FindChild("Title/Score/Text"):GetComponent("Text").text = rank_gist_name
    rank_panel:FindChild("BottonBar/MyPoint"):GetComponent("Text").text = string.format(UIConst.Text.COLON, rank_gist_name)
    rank_panel:FindChild("BottonBar/MyPoint/Text"):GetComponent("Text").text = self_rank_score
    rank_panel:FindChild("BottonBar/MyRank/Text"):GetComponent("Text").text = self_rank or UIConst.Text.NOT_ON_RANKING
    table.insert(self.panel_list, rank_panel)
end

function RankUI:GetRankItem(parent, rank_info, rank, is_self)
    local go = self:GetUIObject(self.rank_temp, parent)
    local spec_rank_go = go:FindChild("Rank/SpecRank")
    local rank_text = go:FindChild("Rank/Text")
    local rank_icon = self.spec_rank_icon_list[rank]
    local is_show_rank_icon = rank_icon and true or false
    if rank_icon then
        self:AssignSpriteByIconID(rank_icon, spec_rank_go:GetComponent("Image"))
    else
        rank_text:GetComponent("Text").text = rank
    end
    spec_rank_go:SetActive(is_show_rank_icon)
    rank_text:SetActive(not is_show_rank_icon)

    local role_go = go:FindChild("Player/HeadIcon")
    local param_tb = {
        go = role_go,
        name = rank_info.name,
        dynasty_name = rank_info.dynasty_name,
        vip = rank_info.vip,
        server_id = rank_info.server_id,
        role_id = rank_info.role_id,
    }
    UIFuncs.InitRoleGo(param_tb)
    go:FindChild("Score/Text"):GetComponent("Text").text = rank_info.rank_score
    go:GetComponent("Image").enabled = not is_self
    go:FindChild("MyRank"):SetActive(is_self)
    table.insert(self.rank_go_list, go)
end

function RankUI:InitUI()
    self:ClearAllGo()
    self:UpdateAllPanel()
end

function RankUI:UpdateAllPanel()
    if not next(self.rank_info_list) then return end
    for _, v in ipairs(self.rank_info_list) do
        self:GetNewRankPanel(v)
    end
    self.tag_go:SetActive(#self.tag_list > 1)
    self:TagOnClick(1)
end

function RankUI:GetNewRankPanel(rank_info)
    local rank_data = rank_info.rank_data
    local rank_list = rank_info.rank_list
    local self_rank = rank_info.self_rank
    local self_rank_score = rank_info.self_rank_score
    local rank_gist_name = rank_info.rank_gist_name
    local tag_name = rank_data and rank_data.rank_tag or UIConst.Text.Rank
    self:GetTag(tag_name)
    self:GetRankPanel(rank_list, self_rank, self_rank_score, rank_gist_name)
    if rank_data and rank_data.has_reward then
        tag_name = rank_data.reward_tag
        self:GetTag(tag_name)
        self:GetRewardPanel(rank_data, self_rank)
    end
end

function RankUI:GetTag(tag_name)
    local tag = self:GetUIObject(self.tag_temp, self.tag_parent)
    tag:FindChild("Text"):GetComponent("Text").text = tag_name
    tag:FindChild("Select/Text"):GetComponent("Text").text = tag_name
    table.insert(self.tag_list, tag)
    local cur_tag_index = #self.tag_list
    self:AddClick(tag, function ()
        self:TagOnClick(cur_tag_index)
    end)
    return tag
end


function RankUI:TagOnClick(index)
    for i, tag in ipairs(self.tag_list) do
        tag:FindChild("Select"):SetActive(index == i)
    end
    for i, panel in ipairs(self.panel_list) do
        panel:SetActive(index == i)
    end
end

function RankUI:Hide()
    self:ClearAllGo()
    self.rank_info_list = {}
    RankUI.super.Hide(self)
end

function RankUI:ClearAllGo()
    self:ClearGoDict("reward_item_go_list")
    self:ClearGoDict("reward_go_list")
    self:ClearGoDict("rank_go_list")
    self:ClearGoDict("panel_list")
    self:ClearGoDict("tag_list")
end

function RankUI:SendGetRankList(rank_id)
    SpecMgrs.msg_mgr:SendMsg("SendGetRankList", {rank_id = rank_id}, function (resp)
        if not self.is_showing then return end
        local rank_data = SpecMgrs.data_mgr:GetTotalRankData(rank_id)
        local rank_gist_name = rank_data.rank_gist_name
        resp.rank_data = rank_data
        resp.rank_gist_name = rank_gist_name
        table.insert(self.rank_info_list, resp)
        self:GetNewRankPanel(resp)
        self.tag_go:SetActive(#self.tag_list > 1)
        self.title_text.text = rank_data.name
        self:TagOnClick(1)
    end)
end

return RankUI