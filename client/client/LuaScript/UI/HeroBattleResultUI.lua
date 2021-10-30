local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local CSConst = require("CSCommon.CSConst")
local HeroBattleResultUI = class("UI.HeroBattleResultUI",UIBase)

function HeroBattleResultUI:DoInit()
    HeroBattleResultUI.super.DoInit(self)
    self.prefab_path = "UI/Common/HeroBattleResultUI"
end

function HeroBattleResultUI:OnGoLoadedOk(res_go)
    HeroBattleResultUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

--CSConst.BattleResultType
function HeroBattleResultUI:Show(param)
    self.result_type = param.result_type
    self.is_win = param.is_win
    self.reward_dict = param.reward_dict
    self.snatch_item = param.snatch_item
    self.arena_param = param.arena_param
    if self.is_res_ok then
        self:InitUI()
    end
    HeroBattleResultUI.super.Show(self)
end

function HeroBattleResultUI:InitRes()
    self.level_val_text = self.main_panel:FindChild("Frame/LevelValText"):GetComponent("Text")
    self.reward_text = self.main_panel:FindChild("Frame/RewardText"):GetComponent("Text")
    self.exp_slider_image = self.main_panel:FindChild("Frame/ExpSlider/ExpSliderImage"):GetComponent("Image")
    self.level_text = self.main_panel:FindChild("Frame/LevelText"):GetComponent("Text")
    self.content = self.main_panel:FindChild("Frame/Content")
    self.reward_item = self.main_panel:FindChild("Frame/Temp/RewardItem")
    self.close_tip = self.main_panel:FindChild("Frame/CloseTip"):GetComponent("Text")
    self.arena_panel = self.main_panel:FindChild("Frame/ArenaPanel")
    self.win_text = self.main_panel:FindChild("Frame/ArenaPanel/WinText"):GetComponent("Text")
    self.cur_rank_text = self.main_panel:FindChild("Frame/ArenaPanel/CurRankText"):GetComponent("Text")
    self.target_rank = self.main_panel:FindChild("Frame/ArenaPanel/TargetRank"):GetComponent("Text")
    self.get_treasure_panel = self.main_panel:FindChild("Frame/GetTreasurePanel")
    self.snatch_text = self.main_panel:FindChild("Frame/GetTreasurePanel/SnatchText"):GetComponent("Text")
    self.snatch_icon = self.main_panel:FindChild("Frame/GetTreasurePanel/SnatchIcon"):GetComponent("Image")
    self.not_snatch_text = self.main_panel:FindChild("Frame/GetTreasurePanel/NotSnatchText"):GetComponent("Text")
    self.fail_panel = self.main_panel:FindChild("Frame/FailPanel")
    self.recruit_hero_text = self.main_panel:FindChild("Frame/FailPanel/RecruitHeroText"):GetComponent("Text")
    self.train_equip_text = self.main_panel:FindChild("Frame/FailPanel/TrainEquipText"):GetComponent("Text")
    self.train_hero_text = self.main_panel:FindChild("Frame/FailPanel/TrainHeroText"):GetComponent("Text")
    self.fail_text = self.main_panel:FindChild("Frame/FailPanel/FailText"):GetComponent("Text")
    self.win_effect = self.main_panel:FindChild("WinEffect")
    self.lost_effect = self.main_panel:FindChild("LostEffect")

    self.win_title = self.main_panel:FindChild("WinTitle")
    self.lost_title = self.main_panel:FindChild("LostTitle")
    self.reward_item:SetActive(false)
    self:AddClick(self.main_panel:FindChild("Mask"), function()
        self:Hide()
    end)
end

function HeroBattleResultUI:InitUI()
    self:SetTextVal()
    self:UpdateData()
    self:UpdateUIInfo()
end

function HeroBattleResultUI:UpdateData()
    self.role_exp_percentage = ComMgrs.dy_data_mgr:ExGetRoleExpPercentage()
    self.role_level = ComMgrs.dy_data_mgr:ExGetRoleLevel()
end

function HeroBattleResultUI:UpdateUIInfo()
    self.fail_panel:SetActive(false)
    self.get_treasure_panel:SetActive(false)
    self.arena_panel:SetActive(false)
    self.win_effect:SetActive(false)
    self.lost_effect:SetActive(false)
    self.win_title:SetActive(false)
    self.lost_title:SetActive(false)

    self:SetRewardPanel()
    if self.is_win then
        self.win_effect:SetActive(true)
        self.win_title:SetActive(true)
        if self.result_type == CSConst.BattleResultType.Arena then
            self.arena_panel:SetActive(true)
            self:SetArenaPanel()
        elseif self.result_type == CSConst.BattleResultType.SnatchTreasure then
            self.get_treasure_panel:SetActive(true)
            self:SetGetTreasurePanel()
        end
    else
        self.lost_title:SetActive(true)
        self.lost_effect:SetActive(true)
        self.fail_panel:SetActive(true)
    end
    self.level_val_text.text = string.format(UIConst.Text.LEVEL, self.role_level)
    self.exp_slider_image.fillAmount = self.role_exp_percentage
end

function HeroBattleResultUI:SetRewardPanel()
    if not self.reward_dict then return end
    local item_list = {}
    for item_id, num in pairs(self.reward_dict) do
        table.insert(item_list, {item_id = item_id, num = num})
    end
    table.sort(item_list, function(item1, item2)
        return item1.item_id > item2.item_id  -- 待修改
    end)
    for i, item in ipairs(item_list) do
        local reward_obj = self:GetUIObject(self.reward_item, self.content)
        UIFuncs.AssignItemMes(reward_obj, item.item_id, item.num)
    end
end

function HeroBattleResultUI:SetArenaPanel()
    self.cur_rank_text.gameObject:SetActive(false)
    self.target_rank.gameObject:SetActive(false)
    self.win_text.text = string.format(UIConst.Text.ARENA_WIN_FORMAT, self.arena_param.target_name)
    if self.arena_param.new_rank then
        self.cur_rank_text.text = string.format(UIConst.Text.ADD_RANK_FORMAT, self.arena_param.start_rank)
        self.target_rank.text = self.arena_param.new_rank
        self.cur_rank_text.gameObject:SetActive(true)
        self.target_rank.gameObject:SetActive(true)
    end
end

function HeroBattleResultUI:SetGetTreasurePanel()
    self.snatch_text.gameObject:SetActive(false)
    self.not_snatch_text.gameObject:SetActive(false)
    self.snatch_icon.gameObject:SetActive(false)
    if self.snatch_item then
        local item_data = SpecMgrs.data_mgr:GetItemData(self.snatch_item)
        self.snatch_text.text = string.format(UIConst.Text.SNATCH_SUCCESS_FOAMAT, item_data.name)
        UIFuncs.AssignSpriteByIconID(item_data.icon, self.snatch_icon)
        self.snatch_text.gameObject:SetActive(true)
        self.snatch_icon.gameObject:SetActive(true)
    else
        self.not_snatch_text.text = UIConst.Text.SNATCH_FAIL_TEXT
        self.not_snatch_text.gameObject:SetActive(true)
    end
end

function HeroBattleResultUI:SetTextVal()
    self.reward_text.text = UIConst.Text.REWARD_TEXT
    self.level_text.text = UIConst.Text.LEVEL_TEXT
    self.close_tip.text = UIConst.Text.CLOSE_TIP_TEXT

    self.recruit_hero_text.text = UIConst.Text.RECRUIT_HERO_TEXT
    self.train_equip_text.text = UIConst.Text.TRAIN_EQUIP_TEXT
    self.train_hero_text.text = UIConst.Text.TRAIN_HERO_TEXT
    self.fail_text.text = UIConst.Text.BATTLE_FAIL_TIP_TEXT
end

function HeroBattleResultUI:Hide()
    self:DestroyRes()
    HeroBattleResultUI.super.Hide(self)
end

return HeroBattleResultUI
