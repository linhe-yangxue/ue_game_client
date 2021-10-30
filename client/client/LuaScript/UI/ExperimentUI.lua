local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local CSConst = require("CSCommon.CSConst")
local CSFunction = require("CSCommon.CSFunction")
local ItemUtil = require("BaseUtilities.ItemUtil")
local ExperimentUI = class("UI.ExperimentUI",UIBase)

local stage_count = 3
local unit_scale = 0.3
local lock_show_count = 3
local war_stage_width = 200

--  试炼
function ExperimentUI:DoInit()
    ExperimentUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ExperimentUI"
end

function ExperimentUI:OnGoLoadedOk(res_go)
    ExperimentUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function ExperimentUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    ExperimentUI.super.Show(self)
end

function ExperimentUI:InitRes()
    self:InitTopBar()
    --  主界面
    self.buy_treasure_item = self.main_panel:FindChild("MiddleFrame/BuyTreasureItem")
    self:AddClick(self.buy_treasure_item:FindChild("ClickArea"), function()
        self:ShowBuyTreasureFrame()
    end)
    self.housekeeper_point = self.main_panel:FindChild("MiddleFrame/HousekeeperPoint")
    self.dialog_box = self.main_panel:FindChild("MiddleFrame/DialogBox")
    self.clearance_condition_text = self.main_panel:FindChild("MiddleFrame/ClearanceConditionText"):GetComponent("Text")
    self.clearance_condition_val_text = self.main_panel:FindChild("MiddleFrame/ClearanceConditionValText"):GetComponent("Text")
    self.clearance_condition_val_bg = self.main_panel:FindChild("MiddleFrame/ClearanceConditionValBg")
    self.reward_btn = self.main_panel:FindChild("MiddleFrame/RewardBtn")

    self:AddClick(self.reward_btn, function()
        SpecMgrs.ui_mgr:ShowUI("ExperimentRewardPreviewUI", self.cur_info.curr_stage, self.cur_info.curr_star_num)
    end)

    self.reward_btn_text = self.main_panel:FindChild("MiddleFrame/RewardBtn/RewardBtnText"):GetComponent("Text")
    self.shopping_btn_text = self.main_panel:FindChild("DownFrame/ShoppingBtn/ShoppingBtnText"):GetComponent("Text")
    self.ranking_list_btn_text = self.main_panel:FindChild("DownFrame/RankingListBtn/RankingListBtnText"):GetComponent("Text")
    self.elite_challenge_btn_text = self.main_panel:FindChild("DownFrame/EliteChallengeBtn/EliteChallengeBtnText"):GetComponent("Text")
    self.sweep_away_btn_text = self.main_panel:FindChild("DownFrame/SweepAwayBtn/SweepAwayBtnText"):GetComponent("Text")

    self.quick_experiment_button = self.main_panel:FindChild("DownFrame/QuickExperimentButton")
    self:AddClick(self.quick_experiment_button, function()
        local layer = self.cur_layer
        local layer_max_stage = SpecMgrs.data_mgr:GetTrainLayerData(layer).stage_list[stage_count]
        local score_list = SpecMgrs.data_mgr:GetTrainData(layer_max_stage).score_list
        if ComMgrs.dy_data_mgr:ExGetBattleScore() < score_list[#score_list] then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.CANNOT_QUICK_CHALLENGE_TIP)
            return
        end
        local last_star = self.cur_info.curr_star_num
        local cb = function(resp)
            if resp.errcode == 1 then
                SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.CANNOT_QUICK_CHALLENGE_TIP)
            else
                SpecMgrs.ui_mgr:ShowUI("ExperimentReportUI", resp.result, resp.layer_reward, layer, self.cur_info.curr_star_num - last_star)
                SpecMgrs.ui_mgr:RegisterHideUIEvent("ExperimentUIReport", function(_, ui)
                    if ui.class_name == "ExperimentReportUI" then
                        SpecMgrs.ui_mgr:UnregisterHideUIEvent("ExperimentUIReport")
                        self.dy_data:SetCurLayerReward(resp.layer_reward)
                        self.dy_data:SetLastLayerStar(self.cur_info.curr_star_num - last_star)
                        self:ClearRes()
                        self:InitUI()
                    end
                end)
            end
        end
        SpecMgrs.msg_mgr:SendTrainQuickChallenge(nil, cb)
    end)

    self.reset_btn = self.main_panel:FindChild("DownFrame/ResetBtn")
    self:AddClick(self.reset_btn, function()
        self:ClickResetBtn()
    end)
    self.reset_btn_text = self.main_panel:FindChild("DownFrame/ResetBtn/ResetBtnText"):GetComponent("Text")

    self.quick_experiment_button_text = self.main_panel:FindChild("DownFrame/QuickExperimentButton/QuickExperimentButtonText"):GetComponent("Text")
    self.quick_experiment_tip_text = self.main_panel:FindChild("DownFrame/QuickExperimentTipText")
    self.add_attr_tip_text = self.main_panel:FindChild("DownFrame/AddAttrTipText")
    self.attr_text = self.main_panel:FindChild("DownFrame/AttrText"):GetComponent("Text")
    self.more_attr_btn_text = self.main_panel:FindChild("DownFrame/MoreAttrBtn"):GetComponent("Text")
    self.more_attr_btn = self.main_panel:FindChild("DownFrame/MoreAttrBtn")
    self:AddClick(self.more_attr_btn, function()
        self:ShowAttrAddFrame()
    end)
    self.cur_star_text = self.main_panel:FindChild("DownFrame/CurStarText")
    self.history_highest_star_text = self.main_panel:FindChild("DownFrame/HistoryHighestStarText")

    self.shopping_btn = self.main_panel:FindChild("DownFrame/ShoppingBtn")
    self:AddClick(self.shopping_btn, function()
        SpecMgrs.ui_mgr:ShowUI("ShoppingUI", UIConst.ShopList.TrainShop)
    end)
    self.ranking_list_btn = self.main_panel:FindChild("DownFrame/RankingListBtn")
    self:AddClick(self.ranking_list_btn, function()
        SpecMgrs.ui_mgr:ShowRankUI(UIConst.Rank.Experiment)
    end)
    self.elite_challenge_btn = self.main_panel:FindChild("DownFrame/EliteChallengeBtn")
    self:AddClick(self.elite_challenge_btn, function()
        self:ShowExperimentWarFrame()
    end)
    self.sweep_away_btn = self.main_panel:FindChild("DownFrame/SweepAwayBtn")
    self:AddClick(self.sweep_away_btn, function()
        self:ClickSweepAwayBtn()
    end)
    self.experiment_coin_text = self.main_panel:FindChild("DownFrame/ExperimentCoinText"):GetComponent("Text")

    self.stage_unit_item = self.main_panel:FindChild("Temp/StageUnitItem")

    self.stage_point_list = {}
    for i = 1, stage_count do
        local key = "StagePoint" .. i
        table.insert(self.stage_point_list, self.main_panel:FindChild("MiddleFrame/" .. key))
    end
    self.mask = self.main_panel:FindChild("Mask")

    --  重新挑战窗口
    self.reset_frame = self.main_panel:FindChild("ResetFrame")
    self.reset_frame_title = self.main_panel:FindChild("ResetFrame/ResetFrameTitle"):GetComponent("Text")
    self.reset_frame_text = self.main_panel:FindChild("ResetFrame/ResetFrameText")
    self.reset_frame_close_button = self.main_panel:FindChild("ResetFrame/ResetFrameCloseButton")
    self:AddClick(self.reset_frame_close_button, function()
        self:HideResetFrame()
    end)
    self.reset_frame_cancel_btn = self.main_panel:FindChild("ResetFrame/ResetFrameCancelBtn")
    self:AddClick(self.reset_frame_cancel_btn, function()
        self:HideResetFrame()
    end)
    self.reset_frame_cancel_btn_text = self.main_panel:FindChild("ResetFrame/ResetFrameCancelBtn/ResetFrameCancelBtnText"):GetComponent("Text")
    self.reset_frame_confirm_btn = self.main_panel:FindChild("ResetFrame/ResetFrameConfirmBtn")
    self:AddClick(self.reset_frame_confirm_btn, function()
        self:ResetBtnOnClick()
    end)
    self.reset_frame_confirm_btn_text = self.main_panel:FindChild("ResetFrame/ResetFrameConfirmBtn/ResetFrameConfirmBtnText"):GetComponent("Text")

    --  关卡宝箱窗口
    self.stage_chest_frame = self.main_panel:FindChild("StageChestFrame")
    self.stage_chest_title = self.main_panel:FindChild("StageChestFrame/StageChestTitle"):GetComponent("Text")
    self.stage_chest_tip_text = self.main_panel:FindChild("StageChestFrame/StageChestTipText")
    self.stage_chest_close_button = self.main_panel:FindChild("StageChestFrame/StageChestCloseButton")
    self:AddClick(self.stage_chest_close_button, function()
        self:HideStageChestFrame()
    end)
    self.stage_chest_confirm_btn = self.main_panel:FindChild("StageChestFrame/StageChestConfirmBtn")
    self:AddClick(self.stage_chest_confirm_btn, function()
        self:HideStageChestFrame()
    end)
    self.stage_chest_confirm_btn_text = self.main_panel:FindChild("StageChestFrame/StageChestConfirmBtn/StageChestConfirmBtnText"):GetComponent("Text")
    self.chest_list = self.main_panel:FindChild("StageChestFrame/ChestList")
    self.stage_chest_reward_item = self.main_panel:FindChild("StageChestFrame/StageChestRewardItem")

    --  试炼副本窗口
    self.experiment_war_frame = self.main_panel:FindChild("ExperimentWarFrame")
    self.experiment_war_frame_scroll_rect = self.main_panel:FindChild("ExperimentWarFrame/Middle/Scroll View"):GetComponent("RectTransform")
    self.war_close_btn = self.main_panel:FindChild("ExperimentWarFrame/Top/WarCloseBtn")
    self:AddClick(self.war_close_btn, function()
        self:HideExperimentWarFrame()
    end)
    self.experiment_war_frame_title = self.main_panel:FindChild("ExperimentWarFrame/Top/ExperimentWarFrameTitle"):GetComponent("Text")
    self.show_small_lineup_btn = self.main_panel:FindChild("ExperimentWarFrame/Middle/ShowSmallLineupBtn")
    self:AddClick(self.show_small_lineup_btn, function()
        SpecMgrs.ui_mgr:ShowUI("SmallLineupUI")
    end)
    self.show_small_lineup_btn_text = self.main_panel:FindChild("ExperimentWarFrame/Middle/ShowSmallLineupBtn/ShowSmallLineupBtnText"):GetComponent("Text")
    self.first_win_reward_text = self.main_panel:FindChild("ExperimentWarFrame/Middle/FirstWinRewardText")
    self.win_reward_text = self.main_panel:FindChild("ExperimentWarFrame/Middle/WinRewardText"):GetComponent("Text")
    self.receive_reward_image = self.main_panel:FindChild("ExperimentWarFrame/Middle/ReceiveRewardImage")
    self.receive_text = self.main_panel:FindChild("ExperimentWarFrame/Middle/ReceiveRewardImage/ReceiveText"):GetComponent("Text")
    self.war_challenge_time_add_button = self.main_panel:FindChild("ExperimentWarFrame/Middle/WarChallengeTimeAddButton")
    self:AddClick(self.war_challenge_time_add_button, function()
        self:ClickWarChallengeButTimeBtn()
    end)
    self.today_challenge_time_text = self.main_panel:FindChild("ExperimentWarFrame/Middle/TodayChallengeTimeText"):GetComponent("Text")
    self.war_stage_list = self.main_panel:FindChild("ExperimentWarFrame/Middle/Scroll View/Viewport/WarStageList")
    self.war_challenge_btn = self.main_panel:FindChild("ExperimentWarFrame/WarChallengeBtn")
    self:AddClick(self.war_challenge_btn, function()
        self:ClickWarChallengeBtn()
    end)
    self.war_challenge_text = self.main_panel:FindChild("ExperimentWarFrame/WarChallengeBtn/WarChallengeBtnText"):GetComponent("Text")
    self.war_reward_item = self.main_panel:FindChild("ExperimentWarFrame/WarRewardItem")
    self.stage_item = self.main_panel:FindChild("ExperimentWarFrame/Temp/StageItem")
    self.select_war_text = self.main_panel:FindChild("ExperimentWarFrame/Middle/SelectWarText"):GetComponent("Text")

    --  快速扫荡
    self.quick_adopt_reward_frame = self.main_panel:FindChild("QuickAdoptRewardFrame")
    self.quick_adopt_reward_title = self.main_panel:FindChild("QuickAdoptRewardFrame/QuickAdoptRewardTitle"):GetComponent("Text")
    self.quick_adopt_reward_tip_text = self.main_panel:FindChild("QuickAdoptRewardFrame/QuickAdoptRewardTipText"):GetComponent("Text")
    self.quick_adopt_reward_close_button = self.main_panel:FindChild("QuickAdoptRewardFrame/QuickAdoptRewardCloseButton")
    self:AddClick(self.quick_adopt_reward_close_button, function()
        self:HideSweepAwayFrame()
    end)
    self.quick_adopt_reward_confirm_btn = self.main_panel:FindChild("QuickAdoptRewardFrame/QuickAdoptRewardConfirmBtn")
    self:AddClick(self.quick_adopt_reward_confirm_btn, function()
        self:HideSweepAwayFrame()
    end)
    self.confirm_btn_text = self.main_panel:FindChild("QuickAdoptRewardFrame/QuickAdoptRewardConfirmBtn/ConfirmBtnText"):GetComponent("Text")
    self.quick_adopt_reward_list_content = self.main_panel:FindChild("QuickAdoptRewardFrame/QuickAdoptRewardList/Viewport/Content")
    self.quick_adopt_reward_item = self.main_panel:FindChild("QuickAdoptRewardFrame/QuickAdoptRewardItem")

    --  买密藏
    self.buy_treasure_frame = self.main_panel:FindChild("BuyTreasureFrame")
    self.but_treasure_title = self.main_panel:FindChild("BuyTreasureFrame/ButTreasureTitle"):GetComponent("Text")
    self.buy_treasure_tip_text = self.main_panel:FindChild("BuyTreasureFrame/BuyTreasureTipText")
    self.buy_treasure_close_button = self.main_panel:FindChild("BuyTreasureFrame/BuyTreasureCloseButton")
    self:AddClick(self.buy_treasure_close_button, function()
        self:HideBuyTreasureFrame()
    end)
    self.buy_treasure_buy_btn = self.main_panel:FindChild("BuyTreasureFrame/BuyTreasureBuyBtn")
    self:AddClick(self.buy_treasure_buy_btn, function()
        self:BuyTreasure()
    end)
    self.buy_treasure_buy_btn_text = self.main_panel:FindChild("BuyTreasureFrame/BuyTreasureBuyBtn/BuyTreasureBuyBtnText"):GetComponent("Text")
    self.discount_val_text = self.main_panel:FindChild("BuyTreasureFrame/BuyTreasureItem/DiscountValText"):GetComponent("Text")
    self.treasure_original_price = self.main_panel:FindChild("BuyTreasureFrame/OriginPrice/OriginPrice")
    self.treasure_cur_price = self.main_panel:FindChild("BuyTreasureFrame/CurPrice")

    --  属性加成面板
    self.attr_add_frame = self.main_panel:FindChild("AttrAddFrame")
    self.attr_add_title = self.main_panel:FindChild("AttrAddFrame/AttrAddTitle"):GetComponent("Text")
    self.attr_add_frame_tip_text = self.main_panel:FindChild("AttrAddFrame/AttrAddFrameTipText"):GetComponent("Text")
    self.attr_add_frame_close_button = self.main_panel:FindChild("AttrAddFrame/AttrAddFrameCloseButton")
    self:AddClick(self.attr_add_frame_close_button, function()
        self:HideAttrAddFrame()
    end)
    self.attr_add_frame_confirm_btn = self.main_panel:FindChild("AttrAddFrame/AttrAddFrameConfirmBtn")
    self:AddClick(self.attr_add_frame_confirm_btn, function()
        self:HideAttrAddFrame()
    end)
    self.attr_add_frame_confirm_btn_text = self.main_panel:FindChild("AttrAddFrame/AttrAddFrameConfirmBtn/AttrAddFrameConfirmBtnText"):GetComponent("Text")
    self.attr_add_frame_text = self.main_panel:FindChild("AttrAddFrame/AttrAddFrameText")
    self.attr_add_list = self.main_panel:FindChild("AttrAddFrame/AttrAddList")

    --  扫荡确认界面
    self.sweep_away_confirm_frame = self.main_panel:FindChild("SweepAwayConfirmFrame")

    self.sweep_away_confirm_frame_title = self.main_panel:FindChild("SweepAwayConfirmFrame/SweepAwayConfirmFrameTitle"):GetComponent("Text")
    self.sweep_away_confirm_text = self.main_panel:FindChild("SweepAwayConfirmFrame/SweepAwayConfirmText"):GetComponent("Text")
    self.sweep_away_confirm_close_btn = self.main_panel:FindChild("SweepAwayConfirmFrame/SweepAwayConfirmFrameCloseBtn")
    self:AddClick(self.sweep_away_confirm_close_btn, function()
        self:HideSweepAwayFrame()
    end)
    self.sweep_away_confirm_cancel_btn = self.main_panel:FindChild("SweepAwayConfirmFrame/SweepAwayConfirmCancelBtn")
    self:AddClick(self.sweep_away_confirm_cancel_btn, function()
        self:HideSweepAwayFrame()
    end)
    self.sweep_away_confirm_cancel_btn_text = self.main_panel:FindChild("SweepAwayConfirmFrame/SweepAwayConfirmCancelBtn/SweepAwayConfirmCancelBtnText"):GetComponent("Text")
    self.sweep_away_confirm_confirm_btn = self.main_panel:FindChild("SweepAwayConfirmFrame/SweepAwayConfirmConfirmBtn")
    self:AddClick(self.sweep_away_confirm_confirm_btn, function()
        self:ClickSweepAwayConfirmConfirmBtn()
    end)

    self.sweep_away_confirm_confirm_btn_text = self.main_panel:FindChild("SweepAwayConfirmFrame/SweepAwayConfirmConfirmBtn/SweepAwayConfirmConfirmBtnText"):GetComponent("Text")

    UIFuncs.RegisterUpdateItemNumFunc(self, "ExperimentUICoin", function(num)
        local coin_name = SpecMgrs.data_mgr:GetItemData(CSConst.Virtual.ExperimentCoin).name
        self.experiment_coin_text.text = string.format(UIConst.Text.EXPERIMENT_COIN_FORMAT, coin_name, UIFuncs.AddCountUnit(num))
    end, CSConst.Virtual.ExperimentCoin)
end

function ExperimentUI:InitUI()
    self.stage_unit_item:SetActive(false)
    self.mask:SetActive(false)
    self.reset_frame:SetActive(false)
    self.stage_chest_frame:SetActive(false)
    self.experiment_war_frame:SetActive(false)
    self.quick_adopt_reward_frame:SetActive(false)
    self.buy_treasure_frame:SetActive(false)
    self.attr_add_frame:SetActive(false)

    self:SetTextVal()
    self:UpdateData()
    self:UpdateUIInfo()
    self.dy_data = ComMgrs.dy_data_mgr.experiment_data

    if self.dy_data.is_show_war_frame then
        self:ShowExperimentWarFrame()
        self.dy_data.is_show_war_frame = false
    end
    self:CheckShowSelectAttr()
end

function ExperimentUI:CheckShowSelectAttr()
    if self.cur_info.add_attr_id_list and #self.cur_info.add_attr_id_list > 0 then
        SpecMgrs.ui_mgr:ShowUI("ExperimentSelectAttrUI", self.cur_info.add_attr_id_list, self.cur_info.can_use_star_num, self.cur_info.add_attr_dict)
        SpecMgrs.ui_mgr:RegisterHideUIEvent("ExperimentUISelectAttr", function(_, ui)
            if ui.class_name == "ExperimentSelectAttrUI" then
                SpecMgrs.ui_mgr:UnregisterHideUIEvent("ExperimentUISelectAttr")
                self:ClearRes()
                self:InitUI()
                if self.dy_data:GetCurLayerReward() then
                    self:ShowStageChestFrame(self.dy_data:GetCurLayerReward(), ComMgrs.dy_data_mgr.experiment_data.last_layer_star)
                    self.dy_data:SetCurLayerReward(nil)
                end
            end
        end)
    end
end

function ExperimentUI:UpdateData()
    self.create_obj_list = {}
    self.war_show_count = math.floor(self.experiment_war_frame_scroll_rect.rect.width / war_stage_width)
    self.cur_info = ComMgrs.dy_data_mgr.experiment_data.experiment_msg
    self.war_info = ComMgrs.dy_data_mgr.experiment_data.experiment_war_msg
    self.attr_list = ComMgrs.dy_data_mgr.experiment_data:GetAttrList()

    local stage_list = SpecMgrs.data_mgr:GetAllTrainData()
    self.cur_stage = self.cur_info.curr_stage
    if self.cur_stage > #stage_list or self.cur_info.is_fail then
        self.is_finish_challange = true
    else
        self.cur_layer = SpecMgrs.data_mgr:GetTrainData(self.cur_stage).layer
        self.cur_stage_list = SpecMgrs.data_mgr:GetTrainLayerData(self.cur_layer).stage_list
        self.is_finish_challange = false
    end
    self.attr_count = SpecMgrs.data_mgr:GetTrainAttrData("attr_count")
end

function ExperimentUI:UpdateUIInfo()
    self:UpdateStarInfo()
    if self.is_finish_challange then
        self.quick_experiment_button:SetActive(false)
        self.reset_btn:SetActive(true)
        self.sweep_away_btn:SetActive(false)
        self.clearance_condition_val_text.gameObject:SetActive(false)
        self.clearance_condition_val_bg:SetActive(false)
        self.reward_btn:SetActive(false)
        self:AddUnit(UIConst.Unit.Housekeeper, self.housekeeper_point, nil, unit_scale)
        self.dialog_box:SetActive(true)
        self.dialog_box:FindChild("DialogBoxText"):GetComponent("Text").text = string.format(UIConst.Text.HOUSEKEEPER_DIALOG_FORMAT, self.cur_info.curr_stage - 1)
        if self.cur_info.has_buy_treasure then
            self.buy_treasure_item:SetActive(false)
        else
            local treasure_data = ComMgrs.dy_data_mgr.experiment_data:GetCurTreasureData()
            self.buy_treasure_item:SetActive(true)
            self:SetTreasure(treasure_data, self.buy_treasure_item)
            self:CreatePriceObj(treasure_data)
        end
    else
        self.reward_btn:SetActive(true)
        self.quick_experiment_button:SetActive(true)
        self.reset_btn:SetActive(false)
        self.dialog_box:SetActive(false)
        self.sweep_away_btn:SetActive(true)
        self.clearance_condition_val_text.gameObject:SetActive(true)
        self.clearance_condition_val_bg:SetActive(true)
        self.buy_treasure_item:SetActive(false)
        local stage_data = SpecMgrs.data_mgr:GetTrainData(self.cur_info.curr_stage)
        self.clearance_condition_val_text.text = SpecMgrs.data_mgr:GetVictoryData(stage_data.victory_id).str_list[1]
        self:InitStageUnit()
    end

    -- reset
    local reset_num = self.cur_info.reset_num + 1
    self.reset_max_time = #SpecMgrs.data_mgr:GetAllTrainResetData()

    local reset_data = SpecMgrs.data_mgr:GetTrainResetData(reset_num)
    if not reset_data then
        reset_data = SpecMgrs.data_mgr:GetTrainResetData(1)
    end
    if self.cur_info.reset_num == self.reset_max_time then
        UIFuncs.SetTextPic(self, self.quick_experiment_tip_text, UIConst.Text.CANNOT_RESET_TIP)
    else
        if reset_data.cost_num == 0 then
            UIFuncs.SetTextPic(self, self.quick_experiment_tip_text, UIConst.Text.FREE_RESET_TIP)
        else
            UIFuncs.SetTextPic(self, self.quick_experiment_tip_text, string.format(UIConst.Text.DIAMOND_RESET_TIP, reset_data.cost_num))
        end
    end
    -- attr
    self:UpdateAttrInfo()
end

function ExperimentUI:UpdateAttrInfo()
    local attr_num = table.getCount(self.cur_info.add_attr_dict)
    if attr_num == 0 then
        self.attr_text.text = UIConst.Text.NO_ATTR_ADD_TIP
    else
        local first_attr_str = self:GetAttrAddStr(self.attr_list[1].id, self.attr_list[1].val)
        local second_attr_str
        if attr_num > 1 then
            second_attr_str = self:GetAttrAddStr(self.attr_list[2].id, self.attr_list[2].val)
            self.attr_text.text = string.format(UIConst.Text.SPACE_FORMAT, first_attr_str, second_attr_str)
        else
            self.attr_text.text = first_attr_str
        end
    end
    if attr_num > 2 then
        self.more_attr_btn:SetActive(true)
    else
        self.more_attr_btn:SetActive(false)
    end
end

function ExperimentUI:InitStageUnit()
    if self.cur_talk then
        self.cur_talk:DoDestroy()
    end
    local cur_stage_item
    for i = 1, stage_count do
        local stage_id = self.cur_stage_list[i]
        local stage_data = SpecMgrs.data_mgr:GetTrainData(stage_id)
        local unit_name = SpecMgrs.data_mgr:GetUnitData(stage_data.show_role).name
        local item = self:GetUIObject(self.stage_unit_item, self.stage_point_list[i])
        table.insert(self.create_obj_list, item)
        local unit = self:AddUnit(stage_data.show_role, item:FindChild("PlayerPoint"), nil, unit_scale)

        local adopt_mes = item:FindChild("AdoptMes")
        local star_list = item:FindChild("AdoptMes/StarList")

        adopt_mes:SetActive(false)
        self:AddClick(item:FindChild("ChallengeBtn"),function()
            local select_diff_ui = SpecMgrs.ui_mgr:ShowUI("ExperimentSelectDiffUI", stage_id, self.cur_info.curr_stage == stage_id)
            select_diff_ui:RegisterBattleEnd("ExperimentUI", function()
                self:ClearRes()
                self:InitUI()
                select_diff_ui:UnregisterBattleEnd("ExperimentUI")
            end)
        end)
        if self.cur_info.curr_stage ~= stage_id then
            if self.cur_info.curr_stage > stage_id then
                adopt_mes:SetActive(true)
                local star_num = self.cur_info.layer_star_num_list[i]
                for j = 1, stage_count do
                    star_list:GetChild(j - 1):SetActive(false)
                end
                for j = 1, star_num do
                    star_list:GetChild(j - 1):SetActive(true)
                end
            end
            item:FindChild("PlayerBase"):SetActive(false)
            item:FindChild("PlayerBaseGray"):SetActive(true)
            item:FindChild("StageMes"):SetActive(false)
            unit:ChangeToGray()
            unit:StopAllAnimationToCurPos()
        else
            item:FindChild("PlayerBase"):SetActive(true)
            item:FindChild("PlayerBaseGray"):SetActive(false)
            item:FindChild("StageMes"):SetActive(true)
            item:FindChild("StageMes/ChallengeImage"):SetActive(true)
            unit:ChangeToNormalMaterial()
            local talk_parent = item:FindChild("TalkParent")
            local is_right = true
            if stage_count == i then
                is_right = false
                talk_parent = item:FindChild("LeftTalkParent")
            end
            local length = #SpecMgrs.data_mgr:GetAllTrainTalkData()
            local talk_str = SpecMgrs.data_mgr:GetTrainTalkData(math.random(1, length)).talk
            self.cur_talk = self:GetTalkCmp(talk_parent, 1, not is_right, function ()
                return talk_str
            end)
            cur_stage_item = self.stage_point_list[i]
        end
        item:FindChild("StageMes/MonsterNameText"):GetComponent("Text").text = unit_name
        item:FindChild("StageMes/StageNameText"):GetComponent("Text").text = string.format(stage_data.name, stage_data.id)
    end
    cur_stage_item:SetAsLastSibling()
end

function ExperimentUI:SetTextVal()
    self.clearance_condition_text.text = UIConst.Text.CLEARANCE_CONDITION_TEXT
    self.quick_experiment_button_text.text = UIConst.Text.QUICK_EXPERIMENT_BTN_TEXT
    self.more_attr_btn_text.text = UIConst.Text.MORE_ATTR_BTN_TEXT
    self.reset_btn_text.text = UIConst.Text.RESET_BTN_TEXT
    self.select_war_text.text = UIConst.Text.SELECT_WAR_TEXT

    self.reward_btn_text.text = UIConst.Text.REWARD_TEXT
    self.shopping_btn_text.text = UIFuncs.GetShopNameByShopType(UIConst.ShopList.TrainShop)
    self.ranking_list_btn_text.text = UIConst.Text.RANK_LIST_TEXT
    self.elite_challenge_btn_text.text = UIConst.Text.ELITE_CHALLENGE_TEXT
    self.sweep_away_btn_text.text = UIConst.Text.SWEEP_AWAY_TEXT

    self.reset_frame_title.text = UIConst.Text.RESET_FRAME_TITLE_TEXT
    self.reset_frame_cancel_btn_text.text = UIConst.Text.CANCEL
    self.reset_frame_confirm_btn_text.text = UIConst.Text.CONFIRM

    self.stage_chest_title.text = UIConst.Text.STAGE_TREASURE_TEXT
    self.confirm_btn_text.text = UIConst.Text.CONFIRM
    self.experiment_war_frame_title.text = UIConst.Text.ELITE_CHALLENGE_TEXT

    self.win_reward_text.text = UIConst.Text.WIN_REWARD_TEXT
    self.war_challenge_text.text = UIConst.Text.CHALLENGE_TEXT

    self.receive_text.text = UIConst.Text.ALREADY_RECEIVE_TEXT

    self.sweep_away_confirm_frame_title.text = UIConst.Text.AUTO_CHALLENGE_TITLE
    self.quick_adopt_reward_title.text = UIConst.Text.QUICK_ADOPT_REWARD_TITLE
    self.quick_adopt_reward_tip_text.text = UIConst.Text.QUICK_ADOPT_REWARD_TIP_TEXT
    self.stage_chest_confirm_btn_text.text = UIConst.Text.CONFIRM
    self.but_treasure_title.text = UIConst.Text.BUY_TREASURE_TEXT
    self.buy_treasure_buy_btn_text.text = UIConst.Text.BUY_TEXT

    self.attr_add_title.text = UIConst.Text.ATTR_ADD_TITLE
    self.attr_add_frame_tip_text.text = UIConst.Text.ATTR_ADD_FRAME_TIP_TEXT
    self.attr_add_frame_confirm_btn_text.text = UIConst.Text.CLOSE

    self.sweep_away_confirm_cancel_btn_text.text = UIConst.Text.CANCEL
    self.sweep_away_confirm_confirm_btn_text.text = UIConst.Text.CONFIRM

    self.stage_unit_item:FindChild("AdoptMes/Adopt/Text"):GetComponent("Text").text = UIConst.Text.ALREADY_ADOPT_TEXT
end

function ExperimentUI:UpdateStarInfo()
    local cur_star_str = string.format(UIConst.Text.CUR_STAR_FORMAT, self.cur_info.curr_star_num)
    UIFuncs.SetTextPic(self, self.cur_star_text, cur_star_str)

    local histroy_star_str = string.format(UIConst.Text.HISTORY_HIGHEST_STAR_FORMAT, self.cur_info.history_star_num)
    UIFuncs.SetTextPic(self, self.history_highest_star_text, histroy_star_str)

    local can_use_star_str = string.format(UIConst.Text.CUR_CAN_USE_STAR_FORMAT, self.cur_info.can_use_star_num)
    UIFuncs.SetTextPic(self, self.add_attr_tip_text, can_use_star_str)
end

function ExperimentUI:GetAttrAddStr(attr_id, val)
    local name = SpecMgrs.data_mgr:GetAttributeData(attr_id).name
    return string.format(UIConst.Text.EXPERIMENT_ATTR_FORMAT, name, val)
end

-----------------ResetFrame
function ExperimentUI:ClickResetBtn()
    if self.cur_info.reset_num >= self.reset_max_time then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.CANNOT_RESET_TIP)
        return
    end
    self:ShowResetFrame()
end

function ExperimentUI:ShowResetFrame()
    self.reset_data = SpecMgrs.data_mgr:GetTrainResetData(self.cur_info.reset_num + 1)
    local remain_time = self.reset_max_time - self.cur_info.reset_num
    if not self.reset_data or remain_time <= 0 then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.CANNOT_RESET_TIP)
        return
    end
    self.mask:SetActive(true)
    self.reset_frame:SetActive(true)
    local str = string.format(UIConst.Text.SPEND_DIAMOND_RESET_FRAME_FORMAT, self.reset_data.cost_num, remain_time)
    UIFuncs.SetTextPic(self, self.reset_frame_text, str)
end

function ExperimentUI:ResetBtnOnClick()
    if not self.reset_data then return end
    if not UIFuncs.CheckItemCount(self.reset_data.cost_item, self.reset_data.cost_num, true) then return end
    SpecMgrs.msg_mgr:SendTrainResetStage(nil, function ()
        self:ClearRes()
        self:InitUI()
    end)
end

function ExperimentUI:HideResetFrame()
    self.reset_data = nil
    self.mask:SetActive(false)
    self.reset_frame:SetActive(false)
end

-----------------AttrAddFrame
function ExperimentUI:ShowAttrAddFrame()
    self.mask:SetActive(true)
    self.attr_add_frame:SetActive(true)
    self.init_obj_list = {}
    for i, attr_data in ipairs(self.attr_list) do
        local item = self:GetUIObject(self.attr_add_frame_text, self.attr_add_list)
        table.insert(self.init_obj_list, item)
        item:GetComponent("Text").text = self:GetAttrAddStr(attr_data.id, attr_data.val)
    end
end

function ExperimentUI:HideAttrAddFrame()
    self.mask:SetActive(false)
    self.attr_add_frame:SetActive(false)
    self:DelObjDict(self.init_obj_list)
end

-----------------StageChestFrame
function ExperimentUI:ShowStageChestFrame(layer_reward_id, layer_star)
    self.mask:SetActive(true)
    self.stage_chest_frame:SetActive(true)
    self.stage_chest_frame_obj_list = {}

    local tip = string.format(UIConst.Text.STAGE_CHEST_TIP_TEXT, layer_star)
    self:SetTextPic(self.stage_chest_tip_text, tip)

    local reward_data_list = ItemUtil.GetSortedRewardItemList(layer_reward_id)
    local list = UIFuncs.SetItemList(self, reward_data_list, self.chest_list)
    table.mergeList(self.stage_chest_frame_obj_list, list)
end

function ExperimentUI:HideStageChestFrame()
    self.mask:SetActive(false)
    self.stage_chest_frame:SetActive(false)
    self:DelObjDict(self.stage_chest_frame_obj_list)
end

-----------------ExperimentWarFrame
function ExperimentUI:ShowExperimentWarFrame()
    self.mask:SetActive(true)
    self.experiment_war_frame:SetActive(true)
    self.experiment_war_obj_list = {}
    self.cur_war_select_index = math.min(self.war_info.curr_war + 1, self.war_info.max_war)
    local war_data_list = SpecMgrs.data_mgr:GetAllTrainWarData()
    local select_list = {}
    for i, data in ipairs(war_data_list) do
        if math.min(self.war_info.curr_war + 1, self.war_info.max_war) >= i then
            local item = self:GetUIObject(self.stage_item, self.war_stage_list)
            self:SetCanChallengeItem(item, data)
            table.insert(select_list, item)
            table.insert(self.experiment_war_obj_list, item)
        end
    end
    local selector = UIFuncs.CreateSelector(self, select_list, function(i)
        self.cur_war_select_index = i
        self:UpdateWarMes()
    end)
    local lock_item_count
    local select_list_count = #select_list
    if select_list_count < self.war_show_count then
        lock_item_count = self.war_show_count - select_list_count
        if lock_item_count < lock_show_count then lock_item_count = lock_show_count end
    else
        lock_item_count = lock_show_count
    end
    local start_index = select_list_count + 1
    for i = start_index ,start_index + lock_item_count do
        if i > #war_data_list then break end
        local data = war_data_list[i]
        local item = self:GetUIObject(self.stage_item, self.war_stage_list)
        self:SetLockWarItem(item, data)
        table.insert(self.experiment_war_obj_list, item)
    end
    if self.cur_war_select_index > #war_data_list then
        self.cur_war_select_index = #war_data_list
    end
    selector:SelectObj(self.cur_war_select_index)
    self.today_challenge_time_text.text = string.format(UIConst.Text.TODDY_CALLENGE_TIME_FORMAT, self.war_info.fight_num)
    self.experiment_war_frame:FindChild("Middle/Scroll View"):GetComponent("ScrollRect").elasticity = 0
    self.war_stage_list:GetComponent("RectTransform").anchoredPosition = Vector3.New(-war_stage_width * (self.cur_war_select_index - 1), 0, 0)

    SpecMgrs.timer_mgr:AddTimer(function()
        self.experiment_war_frame:FindChild("Middle/Scroll View"):GetComponent("ScrollRect").elasticity = 0.1
    end, 0.01, 1)
end

function ExperimentUI:UpdateWarMes()
    if self.war_image_list then
        self:DelObjDict(self.war_image_list)
    end
    local war_data = SpecMgrs.data_mgr:GetTrainWarData(self.cur_war_select_index)
    self:SetTextPic(self.first_win_reward_text, string.format(UIConst.Text.FIRST_WIN_REWARD_FORMAT, war_data.first_reward_count))
    self.today_challenge_time_text.text = string.format(UIConst.Text.TODDY_CALLENGE_TIME_FORMAT, self.war_info.fight_num)
    if self.war_reward_create_item then
        self:DelUIObject(self.war_reward_create_item)
    end
    self.war_reward_create_item = UIFuncs.SetItem(self, war_data.reward_id, war_data.reward_count, self.war_reward_item)
    table.insert(self.experiment_war_obj_list, self.war_reward_create_item)
    if self.cur_war_select_index <= self.war_info.curr_war then
        self.receive_reward_image:SetActive(true)
    else
        self.receive_reward_image:SetActive(false)
    end
end

function ExperimentUI:SetCanChallengeItem(item, data)
    item:FindChild("Head"):SetActive(true)
    item:FindChild("Text"):SetActive(true)
    item:FindChild("Lock"):SetActive(false)
    UIFuncs.AssignSpriteByIconID(data.show_icon, item:FindChild("Head"):GetComponent("Image"))
    item:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ALREADY_OPEN_STAGE_TEXT
end

function ExperimentUI:SetLockWarItem(item, data)
    item:FindChild("Head"):SetActive(false)
    item:FindChild("Text"):SetActive(true)
    item:FindChild("Lock"):SetActive(true)
    item:FindChild("SelectImage"):SetActive(false)
    if self.war_info.max_war >= data.id then
        item:FindChild("Text"):GetComponent("Text").text = UIConst.Text.PASS_PREVIOUS_STAGE_TEXT
    else
        item:FindChild("Text"):GetComponent("Text").text = string.format(UIConst.Text.OPEN_STAGE_FORMAT, data.open_stage)
    end
end

function ExperimentUI:HideExperimentWarFrame()
    self.mask:SetActive(false)
    self.experiment_war_frame:SetActive(false)
    self:DelObjDict(self.experiment_war_obj_list)
end

function ExperimentUI:ClickWarChallengeBtn()
    if not self.cur_war_select_index or self.cur_war_select_index <= 0 then return end
    if self.war_info.fight_num == 0 then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.CANNOT_CHALLENGE_WAR_TIP)
        return
    end
    local last_war_index = self.war_info.curr_war
    local cb = function(resp)
        if not ComMgrs.dy_data_mgr.night_club_data:CheckHeroLineup(true) then return end
        local war_data = SpecMgrs.data_mgr:GetTrainWarData(self.cur_war_select_index)
        SpecMgrs.ui_mgr:EnterHeroBattle(resp.fight_data, UIConst.BattleScence.ExperimentUI)
        SpecMgrs.ui_mgr:RegiseHeroBattleEnd("ExperimentUI", function()
            local is_win = resp.is_win
            local is_first_win = self.cur_war_select_index > last_war_index
            local param_tb = {
                is_win = is_win,
                show_level = true,
                reward = is_win and {[war_data.reward_id] = war_data.reward_count},
                first_reward = (is_win and is_first_win) and {[war_data.first_reward_id] = war_data.first_reward_count},
            }
            SpecMgrs.ui_mgr:AddCloseBattlePopUpList("BattleResultUI", param_tb)
        end)
        SpecMgrs.ui_mgr:RegisterHeroBattleUIClose("ExperimentUI", function()
            if not self.is_res_ok then return end
            self:ClearRes()
            self:InitUI()
        end)
        self.dy_data.is_show_war_frame = true
    end
    SpecMgrs.msg_mgr:SendMsg("SendTrainWarChallenge", {war_id = self.cur_war_select_index}, cb)
end

function ExperimentUI:ClickWarChallengeButTimeBtn()
    self.train_war_num_data_list = SpecMgrs.data_mgr:GetAllTrainWarNumData()
    local max_time = CSFunction.get_train_challenge_buy_time(ComMgrs.dy_data_mgr.vip_data:GetVipLevel())
    local buy_max_time = max_time - self.war_info.buy_fight_num
    if buy_max_time == 0 then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.CANNOT_BUY_CHALLENGE_WAR_TIME_TIP)
        return
    end
    local tip_text = string.format(UIConst.Text.EXPERIMENT_BUY_WAR_TIME_FORMAT, self.war_info.fight_num,  buy_max_time)
    local param_tb = {
        title_str = UIConst.Text.BUY_TIME_TEXT,
        up_tip_str = tip_text,
        cost_item = CSConst.Virtual.Diamond,
        unit_price_func = function(buy_index) return self:GetPrice(buy_index) end,
        buy_max_num = buy_max_time,
        callback = function(buy_num, total_price) self:BuyWarChallengeTime(buy_num, total_price) end,
    }
    SpecMgrs.ui_mgr:ShowUI("BuyItemUI", param_tb)
end

function ExperimentUI:GetPrice(index)
    local price_index = self.war_info.buy_fight_num + index
    if price_index > #self.train_war_num_data_list then
        price_index = #self.train_war_num_data_list
    end
    return self.train_war_num_data_list[price_index].cost_num
end

function ExperimentUI:BuyWarChallengeTime(buy_num, total_price)
    local cb = function(resp)
        if resp.errcode == 1 then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.DIAMOND_BUY_FAIL)
        end
        self.today_challenge_time_text.text = string.format(UIConst.Text.TODDY_CALLENGE_TIME_FORMAT, self.war_info.fight_num)
    end
    SpecMgrs.msg_mgr:SendTrainWarBuyFightNum({num = buy_num}, cb)
end

-------------------------SweepAwayFrame

function ExperimentUI:ShowSweepAwayFrame(reward_list)
    self.mask:SetActive(true)
    self.quick_adopt_reward_frame:SetActive(true)
    self.sweep_away_obj_list = {}
    reward_list = ItemUtil.MergeRoleItemList(reward_list)
    reward_list = ItemUtil.SortRoleItemList(reward_list)
    for i, data in ipairs(reward_list) do
        local item = self:GetUIObject(self.quick_adopt_reward_item, self.quick_adopt_reward_list_content)
        table.insert(self.sweep_away_obj_list, item)
        UIFuncs.AssignItem(item, data.item_id, data.count)
    end
end

function ExperimentUI:HideSweepAwayFrame()
    self.mask:SetActive(false)
    self.quick_adopt_reward_frame:SetActive(false)
    self:ClearRes()
    self:InitUI()
end

function ExperimentUI:ClickSweepAwayBtn()
    if self.cur_info.curr_stage >= self.cur_info.max_stage then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.CANNOT_SWEEPAWAY_TIP)
        return
    end
    self:ShowSweepAwayConfirmFrame()
end

-- SweepAwayConfirmFrame

function ExperimentUI:ShowSweepAwayConfirmFrame()
    self.mask:SetActive(true)
    self.sweep_away_confirm_frame:SetActive(true)
    self.sweep_away_confirm_text.text = string.format(UIConst.Text.SWEEP_AWAY_TIP_FORMAT, self.cur_info.max_stage)
end

function ExperimentUI:HideSweepAwayConfirmFrame()
    self.mask:SetActive(false)
    self.sweep_away_confirm_frame:SetActive(false)
end

function ExperimentUI:ClickSweepAwayConfirmConfirmBtn()
    local cb = function(resp)
        self:HideSweepAwayConfirmFrame()
        self:ShowSweepAwayFrame(resp.reward_list)
    end
    SpecMgrs.msg_mgr:SendTrainSweepStage(nil, cb)
end

----------------------------BuyTreasure
function ExperimentUI:CreatePriceObj(treasure_data)
    self.treasure_original_price:FindChild("OriginalPrice"):GetComponent("Text").text = UIConst.Text.TREASURE_ORIGINAL_PRICE_FORMAT
    UIFuncs.AssignSpriteByItemID(treasure_data.cost_item, self.treasure_original_price:FindChild("OriginalPriceImage"):GetComponent("Image"))
    self.treasure_original_price:FindChild("OriginalPriceText"):GetComponent("Text").text = treasure_data.original_price

    self.treasure_cur_price:FindChild("CurPrice"):GetComponent("Text").text = UIConst.Text.CUR_PRICE_FORMAT
    UIFuncs.AssignSpriteByItemID(treasure_data.cost_item, self.treasure_cur_price:FindChild("CurPriceImage"):GetComponent("Image"))
    self.treasure_cur_price:FindChild("CurPriceText"):GetComponent("Text").text = treasure_data.current_price

    self.treasure_original_price:GetComponent("ContentSizeFitter"):SetLayoutHorizontal() 
    self.treasure_cur_price:GetComponent("ContentSizeFitter"):SetLayoutHorizontal()
end

function ExperimentUI:ShowBuyTreasureFrame()
    self.mask:SetActive(true)
    self.buy_treasure_frame:SetActive(true)
    local treasure_data = ComMgrs.dy_data_mgr.experiment_data:GetCurTreasureData()
    local cost_icon = SpecMgrs.data_mgr:GetItemData(treasure_data.cost_item).icon
    self:SetTextPic(self.buy_treasure_tip_text, string.format(UIConst.Text.BUY_TREASURE_TIP_TEXT, self.cur_info.curr_star_num))

    local item = self.buy_treasure_frame:FindChild("BuyTreasureItem")
    self:SetTreasure(treasure_data, item)
end

function ExperimentUI:HideBuyTreasureFrame()
    self:DelUIObject(self.treasure_item)
    self.mask:SetActive(false)
    self.buy_treasure_frame:SetActive(false)
end

function ExperimentUI:SetTreasure(treasure_data, item)
    self.treasure_item = self:SetItem(treasure_data.item_id, treasure_data.item_count, item:FindChild("Item"))
    local discount = math.ceil((treasure_data.current_price / treasure_data.original_price) * 100)

    item:FindChild("DiscountValText"):GetComponent("Text").text = string.format(UIConst.Text.PERCENT, discount)
    local treasure_tip_text = item:FindChild("TreasureTipText")
    if treasure_tip_text then
        treasure_tip_text:GetComponent("Text").text = UIConst.Text.TREASURE_FRAME_TITLE
    end
    local item_name_text = item:FindChild("ItemText")
    if item_name_text then
        item_name_text:GetComponent("Text").text = UIFuncs.GetItemName({item_id = treasure_data.item_id})
    end
    table.insert(self.create_obj_list, self.treasure_item)
end

function ExperimentUI:BuyTreasure()
    local cb = function(resp)
        self:HideBuyTreasureFrame()
        self.buy_treasure_item:SetActive(false)
    end
    SpecMgrs.msg_mgr:SendTrainBuyTreasure(nil, cb)
end

function ExperimentUI:ClearRes()
    self:DelObjDict(self.experiment_war_obj_list)
    self:DelObjDict(self.create_obj_list)
    self:DestroyAllUnit()
end

function ExperimentUI:Hide()
    self:ClearRes()
    ExperimentUI.super.Hide(self)
end

return ExperimentUI
