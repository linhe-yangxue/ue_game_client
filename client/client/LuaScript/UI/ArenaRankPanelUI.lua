local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local ArenaUI = require("UI.ArenaUI")
local UIFuncs = require("UI.UIFuncs")
local ArenaRankPanelUI = class("UI.ArenaRankPanelUI",UIBase)

local spec_rank_icon_list = UIConst.Icon.RankIconList

--  竞技场排行榜
function ArenaRankPanelUI:DoInit()
    ArenaRankPanelUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ArenaRankPanelUI"
end

function ArenaRankPanelUI:OnGoLoadedOk(res_go)
    ArenaRankPanelUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function ArenaRankPanelUI:Show(own_rank, arena_role_list)
    self.arena_role_list = arena_role_list
    self.own_rank = own_rank
    if self.is_res_ok then
        self:InitUI()
    end
    ArenaRankPanelUI.super.Show(self)
end

function ArenaRankPanelUI:InitRes()
    self.close_btn = self.main_panel:FindChild("UpMesFrame/CloseBtn")
    self:AddClick(self.close_btn, function()
        SpecMgrs.ui_mgr:HideUI(self)
    end)
    self.tip_btn = self.main_panel:FindChild("UpMesFrame/TipBtn")
    self:AddClick(self.tip_btn, function()

    end)

    self.content = self.main_panel:FindChild("MiddlePart/Scroll View/Viewport/Content")
    self.item = self.main_panel:FindChild("MiddlePart/Scroll View/Viewport/Content/Item")
    self.rank_text = self.main_panel:FindChild("MiddlePart/Tiele/RankText"):GetComponent("Text")
    self.player_text = self.main_panel:FindChild("MiddlePart/Tiele/PlayerText"):GetComponent("Text")

    self.no_rank_tip = self.main_panel:FindChild("MiddlePart/NoOneOnRank")

    self.my_rank_text = self.main_panel:FindChild("BottonBar/MyRankText"):GetComponent("Text")
    self.my_rank_val_text = self.main_panel:FindChild("BottonBar/MyRankText/MyRankValText"):GetComponent("Text")
    self.target_rank_text = self.main_panel:FindChild("BottonBar/TargetRankText"):GetComponent("Text")
    self.target_rank_val_text = self.main_panel:FindChild("BottonBar/TargetRankText/TargetRankValText"):GetComponent("Text")
    self.rank_award_text = self.main_panel:FindChild("BottonBar/RankAwardText"):GetComponent("Text")
    self.target_award_text = self.main_panel:FindChild("BottonBar/TargetAwardText"):GetComponent("Text")

    self.self_award_panel = self.main_panel:FindChild("BottonBar/SelfAward")
    self.target_award_panel = self.main_panel:FindChild("BottonBar/TargetAward")
    self.item:SetActive(false)
end

function ArenaRankPanelUI:InitUI()
    self:SetTextVal()
    self:UpdateData()
    self:UpdateUIInfo()
end

function ArenaRankPanelUI:UpdateData()

end

function ArenaRankPanelUI:UpdateUIInfo()
    if not self.arena_role_list then self.no_rank_tip:SetActive(true) return end
    self.no_rank_tip:SetActive(false)
    for i, role_info in ipairs(self.arena_role_list) do
        local item = self:GetUIObject(self.item, self.content)
        self:SetItemMes(item, role_info)
    end
    self.my_rank_val_text.text = self.own_rank
    self:SetAwardList(self.self_award_panel, ArenaUI.GetRankAward(self.own_rank))

    local reward_data, target_rank = self:GetNextRankAwardData(self.own_rank)
    self.target_rank_val_text.text = target_rank
    self:SetAwardList(self.target_award_panel, reward_data)
end

function ArenaRankPanelUI:SetTextVal()
    self.my_rank_text.text = UIConst.Text.OWN_RANK_TEXT
    self.target_rank_text.text = UIConst.Text.TARGET_RANK_TEXT
    self.target_award_text.text = UIConst.Text.TARGET_RANK_AWARD_TEXT
    self.rank_award_text.text = UIConst.Text.RANK_AWARD_TEXT
    self.rank_text.text = UIConst.Text.RANK_TEXT
    self.player_text.text = UIConst.Text.PLAYER_TEXT
end

function ArenaRankPanelUI:SetItemMes(obj, mes)
    local spec_rank = obj:FindChild("SpecRank")
    local rank_text = obj:FindChild("RankText")
    local player_name_text = obj:FindChild("PlayerNameText"):GetComponent("Text")
    local player_icon = obj:FindChild("HeadIcon/PlayerIcon"):GetComponent("Image")
    local award_text = obj:FindChild("AwardText"):GetComponent("Text")

    if mes.rank <= 3 then
        self:AssignSpriteByIconID(spec_rank_icon_list[mes.rank], spec_rank:GetComponent("Image"))
        spec_rank:SetActive(true)
        rank_text:SetActive(false)
    else
        spec_rank:SetActive(false)
        rank_text:SetActive(true)
    end
    rank_text:GetComponent("Text").text = mes.rank
    player_name_text.text = mes.name
    award_text.text = UIConst.Text.AWARD_TEXT
    self:AssignSpriteByIconID(SpecMgrs.data_mgr:GetRoleLookData(mes.role_id).head_icon_id, player_icon)
    self:SetAwardList(obj, ArenaUI.GetRankAward(mes.rank))
end

function ArenaRankPanelUI:SetAwardList(panel, reward_data)
    local item_icon1 = panel:FindChild("AwardItem1"):GetComponent("Image")
    local item_icon2 = panel:FindChild("AwardItem2"):GetComponent("Image")
    local item_icon3 = panel:FindChild("AwardItem3"):GetComponent("Image")

    local item_num_text1 = panel:FindChild("AwardItem1/AwardItemText1"):GetComponent("Text")
    local item_num_text2 = panel:FindChild("AwardItem2/AwardItemText2"):GetComponent("Text")
    local item_num_text3 = panel:FindChild("AwardItem3/AwardItemText3"):GetComponent("Text")

    local id = SpecMgrs.data_mgr:GetArenaData(1).rank_reward
    local data = SpecMgrs.data_mgr:GetRewardData(id)
    UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetItemData(data.reward_item_list[1]).icon, item_icon1)
    UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetItemData(data.reward_item_list[2]).icon, item_icon2)
    UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetItemData(data.reward_item_list[3]).icon, item_icon3)
    if reward_data then
        item_num_text1.text = reward_data.reward_num_list[1]
        item_num_text2.text = reward_data.reward_num_list[2]
        item_num_text3.text = reward_data.reward_num_list[3]
    else
        item_num_text1.text = 0
        item_num_text2.text = 0
        item_num_text3.text = 0
    end
end

function ArenaRankPanelUI:GetNextRankAwardData(rank)
    local reward_data = ArenaUI.GetRankAward(rank)
    if reward_data then
        local next_arena_data_id = ArenaUI.GetArenaData(rank).id - 1
        next_arena_data_id = math.max(next_arena_data_id, 1)
        local reward_data = SpecMgrs.data_mgr:GetRewardData(next_arena_data_id)
        return reward_data, SpecMgrs.data_mgr:GetArenaData(next_arena_data_id).rank_range[2]
    else
        local arena_data_list = SpecMgrs.data_mgr:GetAllArenaData()
        local id = arena_data_list[#arena_data_list].rank_reward
        return SpecMgrs.data_mgr:GetRewardData(id), arena_data_list[#arena_data_list].rank_range[2]
    end
end

function ArenaRankPanelUI:Hide()
    self:DestroyRes()
    ArenaRankPanelUI.super.Hide(self)
end

return ArenaRankPanelUI
