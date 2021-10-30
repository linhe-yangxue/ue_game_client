local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local RankingListUI = class("UI.RankingListUI", UIBase)

local kFixedRankItemCount = 3

function RankingListUI:DoInit()
    RankingListUI.super.DoInit(self)
    self.prefab_path = "UI/Common/RankingListUI"
    self.rank_item_list = {}
end

function RankingListUI:OnGoLoadedOk(res_go)
    RankingListUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function RankingListUI:Hide()
    self:ClearRankItem()
    RankingListUI.super.Hide(self)
end

function RankingListUI:Show(rank_list, self_rank, self_score)
    self.rank_list = rank_list
    self.self_rank = self_rank
    self.self_score = self_score
    if self.is_res_ok then
        self:InitUI()
    end
    RankingListUI.super.Show(self)
end

function RankingListUI:InitRes()
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "RankingListUI")

    local content = self.main_panel:FindChild("Content")
    self.rank_list_content = content:FindChild("RankList/View/Content")
    local first_place = self.rank_list_content:FindChild("First")
    table.insert(self.rank_item_list, first_place)
    local second_place = self.rank_list_content:FindChild("Second")
    table.insert(self.rank_item_list, second_place)
    local third_place = self.rank_list_content:FindChild("Third")
    table.insert(self.rank_item_list, third_place)
    self.rank_item = self.rank_list_content:FindChild("RankItem")
    local head = content:FindChild("Head")
    head:FindChild("Rank"):GetComponent("Text").text = UIConst.Text.RANK_TEXT
    head:FindChild("Name"):GetComponent("Text").text = UIConst.Text.PLAYER_TEXT
    head:FindChild("Level"):GetComponent("Text").text = UIConst.Text.LEVEL_TEXT
    head:FindChild("Score"):GetComponent("Text").text = UIConst.Text.INTEGRAL_TEXT

    local bottom_panel = self.main_panel:FindChild("BottomPanel")
    self.self_ranking_text = bottom_panel:FindChild("Ranking"):GetComponent("Text")
    self.self_score_text = bottom_panel:FindChild("Score"):GetComponent("Text")
end

function RankingListUI:InitUI()
    if not self.rank_list or #self.rank_list == 0 then self:Hide() end
    self:InitRankList()
end

function RankingListUI:InitRankList()
    local count = #self.rank_list
    if count < kFixedRankItemCount then
        for i = count + 1, kFixedRankItemCount do
            self.rank_item_list[i]:SetActive(false)
        end
    end
    for i, rank_data in ipairs(self.rank_list) do
        local rank_item
        if i <= kFixedRankItemCount then
            rank_item = self.rank_item_list[i]
        else
            rank_item = self:GetUIObject(self.rank_item, self.rank_list_content)
            rank_item:FindChild("Ranking/Text"):GetComponent("Text").text = i
            table.insert(self.rank_item_list, rank_item)
        end
        local role_info = rank_data.role_info
        local role_unit_id = SpecMgrs.data_mgr:GetRoleLookData(role_info.role_id).unit_id
        UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetUnitData(role_unit_id).icon, rank_item:FindChild("IconBg/Icon"):GetComponent("Image"))
        -- local vip = player_panel:FindChild("Frame/Vip")
        -- vip:SetActive(role_info.vip ~= nil and role_info.vip > 0)
        -- if role_info.vip and role_info.vip > 0 then
        --     vip:FindChild("Title"):GetComponent("Text").text = string.format(UIConst.Text.VIP, role_info.vip)
        -- end
        rank_item:FindChild("Name"):GetComponent("Text").text = role_info.name
        rank_item:FindChild("Level"):GetComponent("Text").text = role_info.level
        rank_item:FindChild("Score"):GetComponent("Text").text = rank_data.integral
    end
    local rank_text = self.self_rank and string.format(UIConst.Text.SELF_RANKING, self.self_rank) or UIConst.Text.WITHOUT_RANK
    self.self_ranking_text.text = rank_text
    self.self_score_text.text = string.format(UIConst.Text.SELF_INTEGRAL, self.self_score or 0)
end

function RankingListUI:ClearRankItem()
    for i = kFixedRankItemCount + 1, #self.rank_item_list do
        local rank_item = table.remove(self.rank_item_list, kFixedRankItemCount + 1)
        self:DelUIObject(rank_item)
    end
end

return RankingListUI