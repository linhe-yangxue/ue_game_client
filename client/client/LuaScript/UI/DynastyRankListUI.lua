local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local SlideSelectCmp = require("UI.UICmp.SlideSelectCmp")

local DynastyRankListUI = class("UI.DynastyRankListUI", UIBase)

local kFixedRankItemCount = 3

function DynastyRankListUI:DoInit()
    DynastyRankListUI.super.DoInit(self)
    self.prefab_path = "UI/Common/DynastyRankListUI"
    self.dy_dynasty_data = ComMgrs.dy_data_mgr.dynasty_data
    self.tab_data_dict = {}
    self.dynasty_rank_item_list = {}
    self.personal_rank_item_list = {}
    self.dynasty_rank_reward_list = {}
    self.personal_rank_reward_list = {}
    self.reward_item_list = {}
end

function DynastyRankListUI:OnGoLoadedOk(res_go)
    DynastyRankListUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function DynastyRankListUI:Hide()
    if self.cur_op_index then
        self.tab_data_dict[self.cur_op_index].select:SetActive(false)
        self.cur_op_index = nil
    end
    self:ClearAllItem()
    DynastyRankListUI.super.Hide(self)
end

function DynastyRankListUI:Show(op_code)
    self.cur_op_index = op_code
    if self.is_res_ok then
        self:InitUI()
    end
    DynastyRankListUI.super.Show(self)
end

function DynastyRankListUI:InitRes()
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "DynastyRankListUI")

    local tab_panel = self.main_panel:FindChild("TabPanel")
    local dynasty_rank_btn = tab_panel:FindChild("DynastyRank")
    self.tab_data_dict[CSConst.DynastyBattleRankListCode.DynastyRank] = {}
    dynasty_rank_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_RANK_TEXT
    local dynasty_rank_select = dynasty_rank_btn:FindChild("Select")
    self.tab_data_dict[CSConst.DynastyBattleRankListCode.DynastyRank].select = dynasty_rank_select
    dynasty_rank_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_RANK_TEXT
    self.tab_data_dict[CSConst.DynastyBattleRankListCode.DynastyRank].tip = UIConst.Text.DYNASTY_RANK_TIP
    self:AddClick(dynasty_rank_btn, function ()
        if self.cur_op_index == CSConst.DynastyBattleRankListCode.DynastyRank then return end
        self.list_slide_cmp:SlideToIndex(CSConst.DynastyBattleRankListCode.DynastyRank - 1)
    end)
    local personal_rank_btn = tab_panel:FindChild("PersonalRank")
    self.tab_data_dict[CSConst.DynastyBattleRankListCode.PersonalRank] = {}
    personal_rank_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.PERSONAL_RANK_TEXT
    local personal_rank_select = personal_rank_btn:FindChild("Select")
    self.tab_data_dict[CSConst.DynastyBattleRankListCode.PersonalRank].select = personal_rank_select
    personal_rank_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.PERSONAL_RANK_TEXT
    self.tab_data_dict[CSConst.DynastyBattleRankListCode.PersonalRank].tip = UIConst.Text.PERSONAL_RANK_TIP
    self:AddClick(personal_rank_btn, function ()
        if self.cur_op_index == CSConst.DynastyBattleRankListCode.PersonalRank then return end
        self.list_slide_cmp:SlideToIndex(CSConst.DynastyBattleRankListCode.PersonalRank - 1)
    end)
    local dynasty_reward_btn = tab_panel:FindChild("DynastyReward")
    self.tab_data_dict[CSConst.DynastyBattleRankListCode.DynastyReward] = {}
    dynasty_reward_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_REWARD_TEXT
    local dynasty_reward_select = dynasty_reward_btn:FindChild("Select")
    self.tab_data_dict[CSConst.DynastyBattleRankListCode.DynastyReward].select = dynasty_reward_select
    dynasty_reward_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_REWARD_TEXT
    self.tab_data_dict[CSConst.DynastyBattleRankListCode.DynastyReward].tip = UIConst.Text.DYNASTY_REWARD_TIP
    self:AddClick(dynasty_reward_btn, function ()
        if self.cur_op_index == CSConst.DynastyBattleRankListCode.DynastyReward then return end
        self.list_slide_cmp:SlideToIndex(CSConst.DynastyBattleRankListCode.DynastyReward - 1)
    end)
    local personal_reward_btn = tab_panel:FindChild("PersonalReward")
    self.tab_data_dict[CSConst.DynastyBattleRankListCode.PersonalReward] = {}
    personal_reward_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.PERSONAL_REWARD_TEXT
    local personal_reward_select = personal_reward_btn:FindChild("Select")
    self.tab_data_dict[CSConst.DynastyBattleRankListCode.PersonalReward].select = personal_reward_select
    personal_reward_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.PERSONAL_REWARD_TEXT
    self.tab_data_dict[CSConst.DynastyBattleRankListCode.PersonalReward].tip = UIConst.Text.PERSONAL_REWARD_TIP
    self:AddClick(personal_reward_btn, function ()
        if self.cur_op_index == CSConst.DynastyBattleRankListCode.PersonalReward then return end
        self.list_slide_cmp:SlideToIndex(CSConst.DynastyBattleRankListCode.PersonalReward - 1)
    end)

    local list = self.main_panel:FindChild("ContentList")
    local content_size = list:GetComponent("RectTransform").rect.size
    local content_list = list:FindChild("Content")
    for content_name, code in pairs(CSConst.DynastyBattleRankListCode) do
        local content_item = content_list:FindChild(content_name)
        local content = content_item:FindChild("View/Content")
        self.tab_data_dict[code].content = content
        self.tab_data_dict[code].item = content:FindChild("Item")
        local self_rank_panel = content_item:FindChild("SelfRank")
        self.tab_data_dict[code].rank = self_rank_panel:FindChild("Rank"):GetComponent("Text")
        self.tab_data_dict[code].score = self_rank_panel:FindChild("Score"):GetComponent("Text")
        content_item:GetComponent("RectTransform").sizeDelta = content_size
    end
    self.list_slide_cmp = SlideSelectCmp.New()
    self.list_slide_cmp:DoInit(self, content_list)
    self.list_slide_cmp:SetParam(content_size.x, 4)
    self.list_slide_cmp:ListenSelectUpdate(function (index)
        if self.cur_op_index == index + 1 then return end
        if self.cur_op_index then self.tab_data_dict[self.cur_op_index].select:SetActive(false) end
        self.cur_op_index = index + 1
        self.tab_data_dict[self.cur_op_index].select:SetActive(true)
        self.tip.text = self.tab_data_dict[self.cur_op_index].tip
    end)
    self.tip = self.main_panel:FindChild("BottomPanel/Tip"):GetComponent("Text")

    self.item_pref = self.main_panel:FindChild("PrefabList/Item")
end

function DynastyRankListUI:InitUI()
    self:InitDynastyRankList()
    self:InitPersonalRankList()
    self.cur_op_index = self.cur_op_index or CSConst.DynastyBattleRankListCode.DynastyRank
    self.tab_data_dict[self.cur_op_index].select:SetActive(true)
    self.tip.text = self.tab_data_dict[self.cur_op_index].tip
    self.list_slide_cmp:SetToIndex(self.cur_op_index - 1)
end

function DynastyRankListUI:InitDynastyRankList()
    SpecMgrs.msg_mgr:SendGetCompeteDynastyRank({}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_DYNASTY_BATTLE_RANK_LIST_FAILED)
        else
            self.dynasty_rank = resp.self_rank
            local op_data = self.tab_data_dict[CSConst.DynastyBattleRankListCode.DynastyRank]
            for rank, dynasty_info in ipairs(resp.rank_list) do
                local rank_item = self:GetUIObject(op_data.item, op_data.content)
                table.insert(self.dynasty_rank_item_list, rank_item)
                local rank_img = rank_item:FindChild("RankImg")
                rank_img:SetActive(rank <= kFixedRankItemCount)
                local rank_text = rank_item:FindChild("Ranking")
                rank_text:SetActive(rank > kFixedRankItemCount)
                if rank <= kFixedRankItemCount then
                    UIFuncs.AssignSpriteByIconID(UIConst.Icon.RankIconList[rank], rank_img:GetComponent("Image"))
                else
                    rank_text:GetComponent("Text").text = rank
                end
                local badge_data = SpecMgrs.data_mgr:GetDynastyBadgeData(dynasty_info.dynasty_badge)
                UIFuncs.AssignSpriteByIconID(badge_data.icon, rank_item:FindChild("Icon"):GetComponent("Image"))
                rank_item:FindChild("Name"):GetComponent("Text").text = dynasty_info.dynasty_name
                rank_item:FindChild("Score"):GetComponent("Text").text = string.format(UIConst.Text.DYNASTY_RANK_SCORE_FORMAT, dynasty_info.mark)
                local server_data = SpecMgrs.data_mgr:GetServerData(dynasty_info.server_id)
                local partition_data = SpecMgrs.data_mgr:GetPartitionData(server_data.partition)
                rank_item:FindChild("Server"):GetComponent("Text").text = string.format(UIConst.Text.SERVER_FORMAT, partition_data.area, dynasty_info.server_id)
            end
            op_data.rank:GetComponent("Text").text = string.format(UIConst.Text.DYNASTY_BATTLE_RANK_FROMAT, resp.self_rank or UIConst.Text.NOT_ON_RANKING)
            op_data.score:GetComponent("Text").text = string.format(UIConst.Text.DYNASTY_RANK_SCORE_FORMAT, self.dy_dynasty_data:GetDynastyBattleScore().dynasty_total_score)
            op_data.content:GetComponent("RectTransform").anchoredPosition = Vector2.zero
            self:InitDynastyRewardPanel()
        end
    end)
end

function DynastyRankListUI:InitPersonalRankList()
    SpecMgrs.msg_mgr:SendGetCompeteRoleRank({}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_DYNASTY_BATTLE_RANK_LIST_FAILED)
        else
            self.personal_rank = resp.self_rank
            local op_data = self.tab_data_dict[CSConst.DynastyBattleRankListCode.PersonalRank]
            for rank, role_info in ipairs(resp.rank_list) do
                local rank_item = self:GetUIObject(op_data.item, op_data.content)
                table.insert(self.personal_rank_item_list, rank_item)
                local rank_img = rank_item:FindChild("RankImg")
                rank_img:SetActive(rank <= kFixedRankItemCount)
                local rank_text = rank_item:FindChild("Ranking")
                rank_text:SetActive(rank > kFixedRankItemCount)
                if rank <= kFixedRankItemCount then
                    UIFuncs.AssignSpriteByIconID(UIConst.Icon.RankIconList[rank], rank_img:GetComponent("Image"))
                else
                    rank_text:GetComponent("Text").text = rank
                end
                local role_data = SpecMgrs.data_mgr:GetRoleLookData(role_info.role_id)
                UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetUnitData(role_data.unit_id).icon, rank_item:FindChild("IconBg/Icon"):GetComponent("Image"))
                rank_item:FindChild("Name"):GetComponent("Text").text = role_info.name
                rank_item:FindChild("Score"):GetComponent("Text").text = string.format(UIConst.Text.PERSONAL_RANK_SCORE_FORMAT, role_info.mark)
                rank_item:FindChild("Dynasty"):GetComponent("Text").text = string.format(UIConst.Text.OWN_DYNASTY_FORMAT, role_info.dynasty_name)
                local server_data = SpecMgrs.data_mgr:GetServerData(role_info.server_id)
                local partition_data = SpecMgrs.data_mgr:GetPartitionData(server_data.partition)
                rank_item:FindChild("Server"):GetComponent("Text").text = string.format(UIConst.Text.SERVER_FORMAT, partition_data.area, role_info.server_id)
            end
            op_data.rank:GetComponent("Text").text = string.format(UIConst.Text.PERSONAL_BATTLE_RANK_FROMAT, resp.self_rank or UIConst.Text.NOT_ON_RANKING)
            op_data.score:GetComponent("Text").text = string.format(UIConst.Text.PERSONAL_RANK_SCORE_FORMAT, self.dy_dynasty_data:GetDynastyBattleScore().personal_total_score)
            op_data.content:GetComponent("RectTransform").anchoredPosition = Vector2.zero
            self:InitPersonalRewardPanel()
        end
    end)
end

function DynastyRankListUI:InitDynastyRewardPanel()
    local op_data = self.tab_data_dict[CSConst.DynastyBattleRankListCode.DynastyReward]
    for _, reward_data in ipairs(SpecMgrs.data_mgr:GetAllCompeteRankData()) do
        if not reward_data.dynasty_reward_list then break end
        local item = self:GetUIObject(op_data.item, op_data.content)
        table.insert(self.dynasty_rank_reward_list, item)
        if reward_data.rank_range[1] == reward_data.rank_range[2] then
            item:FindChild("Range"):GetComponent("Text").text = string.format(UIConst.Text.RANK_FORMAT, reward_data.rank_range[1])
        else
            item:FindChild("Range"):GetComponent("Text").text = string.format(UIConst.Text.RANK_RANGE, reward_data.rank_range[1], reward_data.rank_range[2])
        end
        for i, item_id in ipairs(reward_data.dynasty_reward_list) do
            local reward_item = self:GetUIObject(self.item_pref, item:FindChild("RewardList/View/Content"))
            table.insert(self.reward_item_list, reward_item)
            local data = {
                ui = self,
                go = reward_item,
                item_id = item_id,
                count = reward_data.dynasty_reward_value_list[i],
                click_cb = function ()
                    SpecMgrs.ui_mgr:ShowItemPreviewUI(item_id)
                end,
            }
            UIFuncs.InitItemGo(data)
        end
    end
    op_data.rank:GetComponent("Text").text = string.format(UIConst.Text.DYNASTY_BATTLE_RANK_FROMAT, self.dynasty_rank or UIConst.Text.NOT_ON_RANKING)
    op_data.score:GetComponent("Text").text = string.format(UIConst.Text.DYNASTY_RANK_SCORE_FORMAT, self.dy_dynasty_data:GetDynastyBattleScore().personal_total_score)
    op_data.content:GetComponent("RectTransform").anchoredPosition = Vector2.zero
end

function DynastyRankListUI:InitPersonalRewardPanel()
    local op_data = self.tab_data_dict[CSConst.DynastyBattleRankListCode.PersonalReward]
    for _, reward_data in ipairs(SpecMgrs.data_mgr:GetAllCompeteRankData()) do
        if not reward_data.role_reward_list then break end
        local item = self:GetUIObject(op_data.item, op_data.content)
        table.insert(self.personal_rank_reward_list, item)
        if reward_data.rank_range[1] == reward_data.rank_range[2] then
            item:FindChild("Range"):GetComponent("Text").text = string.format(UIConst.Text.RANK_FORMAT, reward_data.rank_range[1])
        else
            item:FindChild("Range"):GetComponent("Text").text = string.format(UIConst.Text.RANK_RANGE, reward_data.rank_range[1], reward_data.rank_range[2])
        end
        for i, item_id in ipairs(reward_data.role_reward_list) do
            local reward_item = self:GetUIObject(self.item_pref, item:FindChild("RewardList/View/Content"))
            table.insert(self.reward_item_list, reward_item)
            local data = {
                ui = self,
                go = reward_item,
                item_id = item_id,
                count = reward_data.role_reward_value_list[i],
                click_cb = function ()
                    SpecMgrs.ui_mgr:ShowItemPreviewUI(item_id)
                end,
            }
            UIFuncs.InitItemGo(data)
        end
    end
    op_data.rank:GetComponent("Text").text = string.format(UIConst.Text.PERSONAL_BATTLE_RANK_FROMAT, self.personal_rank or UIConst.Text.NOT_ON_RANKING)
    op_data.score:GetComponent("Text").text = string.format(UIConst.Text.PERSONAL_RANK_SCORE_FORMAT, self.dy_dynasty_data:GetDynastyBattleScore().personal_total_score)
    op_data.content:GetComponent("RectTransform").anchoredPosition = Vector2.zero
end

function DynastyRankListUI:ClearAllItem()
    for _, item in ipairs(self.reward_item_list) do
        self:DelUIObject(item)
    end
    self.reward_item_list = {}
    for _, item in ipairs(self.dynasty_rank_item_list) do
        self:DelUIObject(item)
    end
    self.dynasty_rank_item_list = {}
    for _, item in ipairs(self.personal_rank_item_list) do
        self:DelUIObject(item)
    end
    self.personal_rank_item_list = {}
    for _, item in ipairs(self.dynasty_rank_reward_list) do
        self:DelUIObject(item)
    end
    self.dynasty_rank_reward_list = {}
    for _, item in ipairs(self.personal_rank_reward_list) do
        self:DelUIObject(item)
    end
    self.personal_rank_reward_list = {}
end

return DynastyRankListUI