local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local FConst = require("CSCommon.Fight.FConst")
local ItemUtil = require("BaseUtilities.ItemUtil")
local EventUtil = require("BaseUtilities.EventUtil")
local BattleResultUI = class("UI.BattleResultUI",UIBase)

EventUtil.GeneratorEventFuncs(BattleResultUI, "BattleResultUICloseEvent")

local star_num = 3
local interval = 50
local min_height = 400

local star_delay_list = {
    0.3,
    0.6,
    0.9,
}

-- local param_tb = {
--     is_win = true,

--     star_level,
--     star_level_tip,

--     show_level,

--     reward,
--     reward_tip,

--     win_tip,

--     first_reward,

--     is_soldier_battle,
--     func,

--     target_player_name,
-- }

--  LineupUI

--  通用战斗结算界面
function BattleResultUI:DoInit()
    BattleResultUI.super.DoInit(self)
    self.prefab_path = "UI/Common/BattleResultUI"
    self.star_effect_list = {}
end

function BattleResultUI:OnGoLoadedOk(res_go)
    BattleResultUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function BattleResultUI:Show(param_tb)
    self.param_tb = param_tb
    if self.is_res_ok then
        self:InitUI()
    end
    BattleResultUI.super.Show(self)
end

function BattleResultUI:InitRes()
    self.up_lost_frame = self.main_panel:FindChild("UpLostFrame")
    self.up_win_frame = self.main_panel:FindChild("UpWinFrame")
    self.middle_frame = self.main_panel:FindChild("MiddleFrame")
    self.middle_frame_content = self.main_panel:FindChild("MiddleFrame/Frame")
    self.start_level_part = self.main_panel:FindChild("UpWinFrame/StartLevelPart")
    self.level_part = self.main_panel:FindChild("LevelPart")
    self.first_reward_part = self.main_panel:FindChild("FirstRewardPart")
    self.coin_reward_part = self.main_panel:FindChild("CoinRewardPart")
    self.win_tip_part = self.main_panel:FindChild("WinTipPart")
    self.reward_item_part = self.main_panel:FindChild("RewardItemPart")
    self.reward_item = self.main_panel:FindChild("Temp/RewardItem")
    self.close_tip_text = self.main_panel:FindChild("CloseTipText")
    self.fail_part = self.main_panel:FindChild("FailTipPart")
    self.soldier_fail_tip_part = self.main_panel:FindChild("SoldierFailTipPart")

    self.evaluate_text = self.main_panel:FindChild("UpWinFrame/StartLevelPart/EvaluateText"):GetComponent("Text")
    for i = 1, star_num do
        local key_word = "StartEffect" .. i
        table.insert(self.star_effect_list, self.start_level_part:FindChild(key_word))
    end

    self:AddClick(self.main_panel:FindChild("Mask"), function()
        SpecMgrs.ui_mgr:HideUI(self)
    end)

    self.battle_detail_btn = self.main_panel:FindChild("BattleDetailBtn")
    self:AddClick(self.main_panel:FindChild("BattleDetailBtn"), function()
        SpecMgrs.ui_mgr:ShowUI("BattleDetailUI", self.param_tb.is_win, self.param_tb.target_player_name)
    end)

    local up_win_frame_rect = self.up_win_frame:GetComponent("RectTransform")
    self.middle_frame_start_y = up_win_frame_rect.anchoredPosition.y - up_win_frame_rect.sizeDelta.y / 2
    self.battle_detail_text = self.main_panel:FindChild("BattleDetailBtn/Text"):GetComponent("Text")

    self.battle_detail_btn_rect = self.main_panel:FindChild("BattleDetailBtn"):GetComponent("RectTransform")
end

function BattleResultUI:InitUI()
    self:DelAllCreateUIObj()
    self.start_level_part:SetActive(false)
    self:SetTextVal()
    self:UpdateData()
    self:UpdateUIInfo()
end

function BattleResultUI:SetTextVal()
    self.close_tip_text:GetComponent("Text").text = UIConst.Text.CLOSE_TIP_TEXT
    self.battle_detail_text.text = UIConst.Text.BATTLE_DETAIL_TEXT
end

function BattleResultUI:UpdateData()

end

function BattleResultUI:UpdateUIInfo()
    self.battle_detail_btn:SetActive(false)
    self.close_tip_text:SetActive(false)
    local is_win = self.param_tb.is_win
    if self.param_tb.is_win then
        self.up_win_frame:SetActive(true)
        self.up_lost_frame:SetActive(false)
    else
        self.up_win_frame:SetActive(false)
        self.up_lost_frame:SetActive(true)
    end
    self.middle_frame:SetActive(true)
    if self.param_tb.star_level then
        local tip
        if self.param_tb.star_level_tip then
            tip = string.format(UIConst.Text.TEXT_WITH_BRACKET, self.param_tb.star_level_tip)
        else
            tip = ""
        end
        self:ShowStartLevelPart(self.param_tb.star_level, tip)
    end

    if self.param_tb.show_level then
        local create_obj = self:GetUIObject(self.level_part, self.middle_frame_content)
        self:ShowLevelPart(create_obj)
    end

    if self.param_tb.first_reward then
        local create_obj = self:GetUIObject(self.first_reward_part, self.middle_frame_content)
        self:ShowFirstRewardPart(create_obj, self.param_tb.first_reward)
    end

    local coin_list = {}
    local item_list = {}
    if self.param_tb.reward then
        local reward_list = self:GetRewardListByParam(self.param_tb.reward)
        for i, reward_data in ipairs(reward_list) do
            if ItemUtil.IsBelongCoin(reward_data.item_id) then
                table.insert(coin_list, reward_data)
            else
                table.insert(item_list, reward_data)
            end
        end
    end

    if #coin_list > 0 then
        local create_obj = self:GetUIObject(self.coin_reward_part, self.middle_frame_content)
        self:ShowCoinRewardPart(create_obj, coin_list)
    end

    if self.param_tb.win_tip then
        local create_obj = self:GetUIObject(self.win_tip_part, self.middle_frame_content)
        self:ShowWinTipPart(create_obj, self.param_tb.win_tip)
    end

    if #item_list > 0 then
        local create_obj = self:GetUIObject(self.reward_item_part, self.middle_frame_content)
        self:ShowRewardItemPart(create_obj, item_list, self.param_tb.reward_tip)
    end

    if not self.param_tb.is_soldier_battle and not self.param_tb.is_win then
        local create_obj = self:GetUIObject(self.fail_part, self.middle_frame_content)
        BattleResultUI.ShowFailTipPart(self, create_obj)
    end
    if self.param_tb.is_soldier_battle and not self.param_tb.is_win then
        local create_obj = self:GetUIObject(self.soldier_fail_tip_part, self.middle_frame_content)
        self:ShowSoldierFailPart(create_obj)
    end

    local frame_rect = self.middle_frame_content:GetComponent("RectTransform")
    frame_rect.anchoredPosition = Vector2.New(0, -10000)
    local ui_tween = self.middle_frame_content:GetComponent("UITweenPosition")
    ui_tween.enabled = false

    --  下一帧执行
    self:AddTimer(function()
        if not self.is_res_ok then return end
        local middle_frame_rect = self.middle_frame:GetComponent("RectTransform")
        local height = 0
        for i = 0, self.middle_frame_content.childCount - 1 do
            height = height + self.middle_frame_content:GetChild(i):GetComponent("RectTransform").sizeDelta.y
        end
        height = math.clamp(height, min_height, height)

        frame_rect.sizeDelta = Vector2.New(frame_rect.sizeDelta.x, height)
        frame_rect.anchoredPosition = Vector3.New(0, frame_rect.rect.height / 2 + 200)
        middle_frame_rect.sizeDelta = Vector3.New(middle_frame_rect.sizeDelta.x, frame_rect.sizeDelta.y)
        middle_frame_rect.anchoredPosition = Vector3.New(0, self.middle_frame_start_y -(frame_rect.rect.height / 2))

        if not self.param_tb.is_soldier_battle then
            self.battle_detail_btn_rect.anchoredPosition =  Vector3.New(self.battle_detail_btn_rect.anchoredPosition.x, middle_frame_rect.anchoredPosition.y - middle_frame_rect.sizeDelta.y / 2 - interval - 70)
            self.battle_detail_btn:SetActive(true)
        end
        ui_tween.from_ = Vector3.New(0, frame_rect.rect.height / 2 + 200)
        ui_tween.to_ = Vector3.New(0, -frame_rect.rect.height / 2)
        ui_tween.enabled = true

        self.close_tip_text:GetComponent("RectTransform").anchoredPosition = Vector3.New(0, middle_frame_rect.anchoredPosition.y - middle_frame_rect.sizeDelta.y / 2 - interval)
        self.close_tip_text:SetActive(true)
    end, 0.01, 1)
end

function BattleResultUI:ShowStartLevelPart(show_star_num, condition_str)
    self.start_level_part:SetActive(true)
    for i = 1, star_num do
        self.star_effect_list[i]:SetActive(false)
    end
    for i = 1, show_star_num do
        self:AddTimer(function()
            self.star_effect_list[i]:SetActive(true)
        end, star_delay_list[i], 1)
    end
    local num_str = UIConst.Text.NUMBER_TEXT[show_star_num]
    self.evaluate_text.text = string.format(UIConst.Text.STAR_EVALUATE_FORMAT, num_str, condition_str)
end

function BattleResultUI:ShowLevelPart(ui_obj)
    ui_obj:FindChild("Level/LevelSlider"):GetComponent("Image").fillAmount = ComMgrs.dy_data_mgr:ExGetRoleExpPercentage()
    ui_obj:FindChild("LevelValText"):GetComponent("Text").text = string.format(UIConst.Text.LEVEL, ComMgrs.dy_data_mgr:ExGetRoleLevel())
    ui_obj:FindChild("LevelText"):GetComponent("Text").text = UIConst.Text.LEVEL_TEXT
end

function BattleResultUI:ShowFirstRewardPart(ui_obj, reward)
    local reward_list = self:GetRewardListByParam(reward)
    local reward_str_list = ui_obj:FindChild("FirstRewardList")
    local temp_text = ui_obj:FindChild("TempText")
    ui_obj:FindChild("FirstAdoptCoinRewardText"):GetComponent("Text").text = UIConst.Text.FIRST_REWARD_TEXT

    for i, reward_data in ipairs(reward_list) do
        local text = self:GetUIObject(temp_text, reward_str_list)
        self:SetTextPic(text, string.format(UIConst.Text.COIN_REWARD_FORMAT, reward_data.item_data.icon, reward_data.count))
    end
end

function BattleResultUI:ShowCoinRewardPart(ui_obj, reward_list)
    local reward_str_list = ui_obj:FindChild("AdoptCoinRewardList")
    local temp_text = ui_obj:FindChild("TempText")
    ui_obj:FindChild("RewardText"):GetComponent("Text").text = UIConst.Text.REWARD_TEXT

    for i, reward_data in ipairs(reward_list) do
        local text = self:GetUIObject(temp_text, reward_str_list)
        local coin_text = string.format(UIConst.Text.COIN_REWARD_FORMAT, reward_data.item_data.icon, reward_data.count)
        if reward_data.tip then
            coin_text = coin_text .. reward_data.tip
        end
        self:SetTextPic(text, coin_text)
    end
end

function BattleResultUI:ShowWinTipPart(ui_obj, tip)
    self:SetTextPic(ui_obj:FindChild("WinTipText"), tip)
end

function BattleResultUI:ShowRewardItemPart(ui_obj, reward_item_list, tip)
    ui_obj:FindChild("RewardItemTip"):GetComponent("Text").text = tip or UIConst.Text.GET_ITEM_TEXT
    UIFuncs.SetItemList(self, reward_item_list, ui_obj:FindChild("List/ViewPort/Content"))
end

function BattleResultUI:ShowSoldierFailPart(ui_obj)
    ui_obj:FindChild("FailTipPartText"):GetComponent("Text").text = UIConst.Text.BATTLE_FAIL_TIP_TEXT
    ui_obj:FindChild("TipText/Text"):GetComponent("Text").text = UIConst.Text.RECRUIT_SOLDIER_TEXT
    self:AddClick(ui_obj:FindChild("RecruitSoldierBtn"), function()
        SpecMgrs.stage_mgr:GotoStage("MainStage")
        SpecMgrs.ui_mgr:HideUI(self)
        SpecMgrs.ui_mgr:ShowUI("GreatHallUI")
    end)
end

function BattleResultUI:GetRewardListByParam(reward)
    local reward_list = {}
    if type(reward) == "table" then
        for item_id, v in pairs(reward) do
            if type(v) == "table" then
                reward_list[item_id] = v.count
            else
                reward_list[item_id] = v
            end
        end
        reward_list = ItemUtil.ItemDictToItemDataList(reward_list, true)
        for i, item_data in ipairs(reward_list) do
            if type(reward[item_data.item_id]) == "table" and reward[item_data.item_id].tip then
                item_data.tip = reward[item_data.item_id].tip
            end
        end
    else
        reward_list = ItemUtil.GetSortedRewardItemList(reward)
    end
    return reward_list
end

function BattleResultUI:Hide()
    if self.param_tb and self.param_tb.func then
        self.param_tb.func()
    end
    self.param_tb = nil
    self:DispatchBattleResultUICloseEvent()
    self:DelAllCreateUIObj()
    BattleResultUI.super.Hide(self)
end

function BattleResultUI.ShowFailTipPart(ui, ui_obj)
    ui_obj:FindChild("FailTipPartText"):GetComponent("Text").text = UIConst.Text.BATTLE_FAIL_TIP_TEXT

    ui:AddClick(ui_obj:FindChild("RecruitHero"), function()
        SpecMgrs.stage_mgr:GotoStage("MainStage")
        SpecMgrs.ui_mgr:ShowUI("ShoppingUI", UIConst.ShopList.HeroShop)
    end)
    ui:AddClick(ui_obj:FindChild("PromoteHero"), function()
        SpecMgrs.stage_mgr:GotoStage("MainStage")
        SpecMgrs.ui_mgr:ShowUI("LineupUI")
    end)
    ui:AddClick(ui_obj:FindChild("PromoteEquip"), function()
        if not ComMgrs.dy_data_mgr.func_unlock_data:CheckFuncIslock(CSConst.FuncUnlockId.EquipIntensify, true) then
            SpecMgrs.stage_mgr:GotoStage("MainStage")
            SpecMgrs.ui_mgr:ShowUI("LineupUI")
        end
    end)
    ui_obj:FindChild("Text1"):GetComponent("Text").text = UIConst.Text.RECRUIT_HERO_TEXT
    ui_obj:FindChild("Text2"):GetComponent("Text").text = UIConst.Text.TRAIN_HERO_TEXT
    ui_obj:FindChild("Text3"):GetComponent("Text").text = UIConst.Text.TRAIN_EQUIP_TEXT
end

return BattleResultUI
