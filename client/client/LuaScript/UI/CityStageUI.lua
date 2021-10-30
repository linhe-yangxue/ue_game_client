local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local UnitConst = require("Unit.UnitConst")
local CityStageUI = class("UI.CityStageUI", UIBase)
local ItemUtil = require("BaseUtilities.ItemUtil")
local MonsterUtil = require("BaseUtilities.MonsterUtil")
local SoundConst = require("Sound.SoundConst")
CityStageUI.need_sync_load = true

local kMaxStarNum = 3
local kDefaultBgNum = UIConst.CityDefaultBgNum
local kDownLimitOffset = 800
local kUpLimitOffset = 800
function CityStageUI:DoInit()
    CityStageUI.super.DoInit(self)
    self.prefab_path = "UI/Common/CityStageUI"

    self.dy_strategy_map_data = ComMgrs.dy_data_mgr.strategy_map_data
    self.dy_traitor_data = ComMgrs.dy_data_mgr.traitor_data
    self.stage_data_list = SpecMgrs.data_mgr:GetAllStageData()
    self.sweep_limit = SpecMgrs.data_mgr:GetParamData("stage_sweep_once_time_limit").f_value
    self.action_point_limit = SpecMgrs.data_mgr:GetParamData("stage_action_point_limit").f_value
    self.treasure_slider_precision  = SpecMgrs.data_mgr:GetParamData("treasure_slider_precision").f_value
    self.sweep_interval_time = SpecMgrs.data_mgr:GetParamData("sweep_interval_time").f_value
    self.sweep_scroll_speed = SpecMgrs.data_mgr:GetParamData("sweep_scroll_speed").f_value
    self.change_talk_time = SpecMgrs.data_mgr:GetParamData("change_talk_time").f_value

    self.stage_id_to_go_parent = {}
    -- 背景
    self.stage_id_to_ui_go = {}
    self.star_progress_list = {}
    self.city_treasure_list = {}
    self.stage_to_treasure = {}
    self.sp_reward_go_list = {}
    self.sp_reward_item_go_list = {}
    self.sp_sweep_total_go_list = {}
    self.spp_award_go_list = {}
    self.stage_id_to_talk_cmp = {}
    -- 数据
    self.cur_stage = nil
    self.cur_city = nil
    self.stage_id_list = {}
    self.stage_id_to_name = {}
end

function CityStageUI:OnGoLoadedOk(res_go)
    CityStageUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function CityStageUI:Show(city_id)
    if not city_id then return end
    self:SetCityId(city_id)
    if self.is_res_ok then
        self:InitUI()
    end
    CityStageUI.super.Show(self)
    self:UpdateAllTreasureBox()
end

function CityStageUI:UpdateScrollRectLimit()
    local first_stage_go_parent = self.stage_id_to_go_parent[self.stage_id_list[1]]
    local last_stage_go_parent = self.stage_id_to_go_parent[self.stage_id_list[#self.stage_id_list]]
    if not first_stage_go_parent then return end
    local content_rect = self.content_rect
    local view_rect = self.view_rect
    local can_move_dis = content_rect.rect.height - view_rect.rect.height
    local down_limit_pos = content_rect:InverseTransformPoint(first_stage_go_parent.position)
    local down_offset = down_limit_pos.y - kDownLimitOffset
    local limit_down_pos =  math.clamp(down_offset / can_move_dis, 0, 1)

    local up_limit_pos = content_rect:InverseTransformPoint(last_stage_go_parent.position)
    local up_offset = (up_limit_pos.y + kUpLimitOffset - view_rect.rect.height)
    local limit_up_pos = math.clamp(up_offset / can_move_dis, 0, 1)
    if limit_up_pos < limit_down_pos then -- 防止建筑过于密集导致屏幕闪烁
        limit_up_pos = limit_down_pos + 0.0001
    end
    self.limit_pos_list = {limit_down_pos, limit_up_pos}
end

function CityStageUI:SliderToCurStage()
    local cur_stage = self.dy_strategy_map_data:GetCurStage()
    local go_parent = self.stage_id_to_go_parent[cur_stage]
    local nor_pos
    if go_parent then
        local content_rect = self.content_rect
        local view_rect = self.view_rect
        local can_move_dis = content_rect.rect.height - view_rect.rect.height
        local down_limit_pos = content_rect:InverseTransformPoint(go_parent.position)
        local down_offset = down_limit_pos.y - kDownLimitOffset
        nor_pos =  math.clamp(down_offset / can_move_dis, 0, 1)
    else
        nor_pos = self.limit_pos_list[1]
    end
    self.target_pos = nor_pos
end

function CityStageUI:Update(delta_time)
    if not self.is_res_ok then return end
    if self.target_pos then
        self.scroll_rect.verticalNormalizedPosition = self.target_pos
        self.target_pos = nil
    end
    local cur_pos = self.scroll_rect.verticalNormalizedPosition
    cur_pos = math.clamp(cur_pos, self.limit_pos_list[1], self.limit_pos_list[2])
    self.scroll_rect.verticalNormalizedPosition = cur_pos

    if self.sweep_timer then
        self.sweep_timer = self.sweep_timer + delta_time
        if self.sweep_timer >= self.sweep_interval_time then
            self.sweep_timer = nil
            SpecMgrs.msg_mgr:SendSweepBossStage({stage_id = self.sp_sweep_stage}, function(resp)
                self:SendSweepBossStageCb(resp)
            end)
        end
    end
    self:ScrollSweepPanel(delta_time)
end

function CityStageUI:SetCityId(city_id)
    self.cur_city = city_id
    self.city_data = SpecMgrs.data_mgr:GetCityData(city_id)
    self.stage_id_list = SpecMgrs.data_mgr:GetStageListByCityId(city_id)
    self.map_type_data = SpecMgrs.data_mgr:GetCityMapTypeData(self.city_data.city_map_type)
end

function CityStageUI:InitRes()
    local top_bar = self.main_panel:FindChild("PanelList/CityStagePanel/Panel/Top1")
    UIFuncs.InitTopBar(self, top_bar, "CityStagePanel")
    self.city_stage_panel = self.main_panel:FindChild("PanelList/CityStagePanel")
    self.city_name_text = self.city_stage_panel:FindChild("Panel/Top1/CloseBtn/Title"):GetComponent("Text")
    self.main_role_icon_image = self.city_stage_panel:FindChild("Panel/Top2/Icon/Image"):GetComponent("Image")
    self.main_role_level_text = self.city_stage_panel:FindChild("Panel/Top2/Icon/Text"):GetComponent("Text")
    self.score_text = self.city_stage_panel:FindChild("Panel/Top2/Right/Attr/Score/Text"):GetComponent("Text")
    self.exp_slider = self.city_stage_panel:FindChild("Panel/Top2/Right/Exp"):GetComponent("Slider")
    self.map_scroll_rect = self.city_stage_panel:FindChild("Panel/Middle/Scroll View"):GetComponent("ScrollRect")
    self.map_image = self.city_stage_panel:FindChild("Panel/Middle/Scroll View/Viewport/Content"):GetComponent("Image")

    -- 玩家叛军信息
    self.traitor_info_panel = self.city_stage_panel:FindChild("Panel/TraitorInfo")
    self:AddClick(self.traitor_info_panel, function ()
        SpecMgrs.ui_mgr:ShowUI("TraitorInfoUI", self.dy_traitor_data:GetTraitorInfo())
    end)
    local traitor_item = self.traitor_info_panel:FindChild("TraitorItem")
    self.traitor_bg = traitor_item:GetComponent("Image")
    self.traitor_icon = traitor_item:FindChild("Icon"):GetComponent("Image")
    self.traitor_name = traitor_item:FindChild("Name"):GetComponent("Text")

    self.boss_stage_go_temp = self.main_panel:FindChild("Temp/BossStage")
    self.soldier_stage_go_temp = self.main_panel:FindChild("Temp/SoldierStage")

    self.treasure_slider = self.city_stage_panel:FindChild("Panel/BottonBar/Slider"):GetComponent("Slider")
    self.treasure_item_parent = self.city_stage_panel:FindChild("Panel/BottonBar/Slider/Fill Area/AwardList")
    self.treasure_item_temp = self.treasure_item_parent:FindChild("Item")
    self.treasure_item_temp:SetActive(false)
    self.rank_btn = self.city_stage_panel:FindChild("Panel/BottonBar/RankBtn")
    self:AddClick(self.rank_btn, function ()
        SpecMgrs.ui_mgr:ShowRankUI(UIConst.Rank.StageStar)
    end)
    self.star_num_text = self.city_stage_panel:FindChild("Panel/BottonBar/Text"):GetComponent("Text")
    self.rank_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.STAR_RANK

    self.bg_list = {}
    self.bg_pos_list = {}
    self.bg_to_build_num = {}
    self.bg_to_build_list = {}
    self.all_bg_build_num = 0
    self.scroll_rect = self.city_stage_panel:FindChild("Panel/Middle/Scroll View"):GetComponent("ScrollRect")
    self.view_rect = self.city_stage_panel:FindChild("Panel/Middle/Scroll View/Viewport"):GetComponent("RectTransform")
    self.content_rect = self.view_rect.gameObject:FindChild("Content"):GetComponent("RectTransform")
    self.grid_layout_group = self.content_rect.gameObject:GetComponent("GridLayoutGroup")
    self.content_size_fitter = self.content_rect.gameObject:GetComponent("ContentSizeFitter")
    self.grid_layout_group.enabled = false
    self.content_size_fitter.enabled = false
    for bg_index = 1, kDefaultBgNum do
        local bg_go = self.content_rect.gameObject:FindChild("Bg_" .. bg_index)
        table.insert(self.bg_list, bg_go)
        local pos = bg_go:GetComponent("RectTransform").anchoredPosition
        table.insert(self.bg_pos_list, pos)
        local build_parent_rect = bg_go:FindChild("BuildList"):GetComponent("RectTransform")
        local child_num = build_parent_rect.childCount
        self.bg_to_build_list[bg_index] = {}
        for i = 1, child_num do
            table.insert(self.bg_to_build_list[bg_index], build_parent_rect.gameObject:FindChild(i))
        end
        self.bg_to_build_num[bg_index] = child_num
        self.all_bg_build_num = self.all_bg_build_num + child_num
    end

    -- StagePreviewPanel 以下简称ssp
    self.stage_preview_panel = self.main_panel:FindChild("PanelList/StagePreviewPanel")
    self.spp_boss_unit_parent = self.stage_preview_panel:FindChild("Panel/Top/BossIcon/UnitParent")
    self.spp_stage_name_text = self.stage_preview_panel:FindChild("Panel/Top/Middle/StageName"):GetComponent("Text")
    self.stage_preview_panel:FindChild("Panel/Top/Middle/ActionPointCost"):GetComponent("Text").text = UIConst.Text.CONSUME_ACTION
    self.spp_action_cost_text = self.stage_preview_panel:FindChild("Panel/Top/Middle/ActionPointCost/Text"):GetComponent("Text")
    self.spp_star_go_list = {}
    local star_parent = self.stage_preview_panel:FindChild("Panel/Top/Middle/Stars")
    for i = 1, kMaxStarNum do
        self.spp_star_go_list[i] = star_parent:FindChild(i .. "/Star")
    end
    self.spp_pass_time_text = self.stage_preview_panel:FindChild("Panel/Top/PassNum"):GetComponent("Text")
    self.spp_boss_name_text = self.stage_preview_panel:FindChild("Panel/Top/BossIcon/Image/Text"):GetComponent("Text")
    self.spp_suggest_score_text = self.stage_preview_panel:FindChild("Panel/Middle/SuggestScore"):GetComponent("Text")
    self.spp_award_go_parent = self.stage_preview_panel:FindChild("Panel/BottonBar/Award/Viewport/Content")
    self.spp_reset_text = self.stage_preview_panel:FindChild("Panel/BtnList/ResetNum"):GetComponent("Text")
    self:AddClick(self.stage_preview_panel:FindChild("Panel/Top/CloseBtn"), function()
        self:HideStagePreviewPanel()
    end)
    self.stage_preview_panel:FindChild("Panel/Middle/ShowSmallLineupBtn/Text"):GetComponent("Text").text = UIConst.Text.LINEUP
    self:AddClick(self.stage_preview_panel:FindChild("Panel/Middle/ShowSmallLineupBtn"), function()
        SpecMgrs.ui_mgr:ShowUI("SmallLineupUI")
    end)
    self.spp_reset_btn = self.stage_preview_panel:FindChild("Panel/BtnList/RestBtn")
    self.spp_reset_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.RESET_BTN_TEXT
    self:AddClick(self.spp_reset_btn,function()
        self:ResetBtnOnClick()
    end)
    self.stage_preview_panel:FindChild("Panel/BottonBar/Top/Text"):GetComponent("Text").text = UIConst.Text.DROP_REWARD_TEXT
    self.spp_sweep_btn = self.stage_preview_panel:FindChild("Panel/BtnList/SweepBtn")
    self.spp_sweep_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SWEEP
    self:AddClick(self.spp_sweep_btn, function()
        self:SweepBtnOnClick(function ()
            self:ShowSweepPanel()
        end)
    end)
    self.spp_boss_talk_parent = self.stage_preview_panel:FindChild("Panel/Top/TalkParent")
    self.spp_sweep_btn_text = self.spp_sweep_btn:FindChild("Text"):GetComponent("Text")
    self.spp_fight_btn = self.stage_preview_panel:FindChild("Panel/BtnList/FightBtn")
    self.spp_fight_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.FIGHT
    self:AddClick(self.spp_fight_btn, function ()
        self:FightBtnOnClick()
    end)

    -- sweep panel  以下简称sp
    self.sweep_panel = self.main_panel:FindChild("PanelList/SweepPanel")
    self.sweep_panel:FindChild("Panel/Title/Text"):GetComponent("Text").text = UIConst.Text.SWEEP_REPORT
    self.sweep_panel:FindChild("Panel/Top/Image/Image/Text"):GetComponent("Text").text = string.format(UIConst.Text.SWEEP_PANEL_TIP, UIConst.Text.SWEEP_REPORT)
    self.sweep_scroll_rect = self.sweep_panel:FindChild("Panel/Middle/Scroll View"):GetComponent("ScrollRect")
    self.sp_reward_go_parent = self.sweep_panel:FindChild("Panel/Middle/Scroll View/Viewport/Content")
    self.sp_reward_go_temp = self.sp_reward_go_parent:FindChild("Temp")
    self.sp_reward_go_temp:SetActive(false)
    self.sp_stop_touch_bg = self.sweep_panel:FindChild("StopTouchBg")
    self.sp_stop_touch_bg:SetActive(false)
    self.sp_reward_item_go_temp = self.sp_reward_go_temp:FindChild("Scroll View/Viewport/Content/Item")
    self.sp_reward_item_go_temp:SetActive(false)
    self.sp_item_size = self.sp_reward_item_go_temp:GetComponent("RectTransform").sizeDelta
    self.sp_sweep_btn = self.sweep_panel:FindChild("Panel/Bottom/SweepBtn")
    self.sp_sweep_btn_text = self.sp_sweep_btn:FindChild("Text"):GetComponent("Text")

    self.sp_reset_btn = self.sweep_panel:FindChild("Panel/Bottom/ResetBtn")
    self.sp_reset_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.RESET_BTN_TEXT
    self:AddClick(self.sp_reset_btn, function()
        self:ResetBtnOnClick()
    end)
    self.sp_sweep_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SWEEP
    self:AddClick(self.sp_sweep_btn, function()
        self:SweepBtnOnClick(function ()
            self:BeginSweep()
        end)
    end)
    self.sweep_panel:FindChild("Panel/Bottom/SweepEndBtn/Text"):GetComponent("Text").text = UIConst.Text.SWEEP_END_BTN_TEXT
    self:AddClick(self.sweep_panel:FindChild("Panel/Bottom/SweepEndBtn"), function()
        self:HideSweepPanel()
    end)
end

function CityStageUI:InitUI()
    self:PlayBGM(SoundConst.SOUND_ID_CityStage)
    self:_InitMainPanel()
    self.content_rect.localScale = UIFuncs.GetPerfectMapScale(true)
    self:RegisterEvent(self.dy_strategy_map_data, "UnlockNewStage", function ()
        local cur_stage = self.dy_strategy_map_data:GetCurStage()
        self:_PlayStageUnlockEffect(cur_stage)
    end)
    self:RegisterEvent(ComMgrs.dy_data_mgr, "UpdateActionPoint", function ()
        self:_UpdateSweepBtn()
    end)
    self:RegisterEvent(self.dy_strategy_map_data, "UpdateStageData", function (_, stage_id)
        self:_UpdateStageGo(stage_id)
        self:_UpdateStagePreviewPanel(stage_id)
        self:_UpdateSweepBtn()
        self:UpdateAllTreasureBox()
        self:_UpdateTreasureSlider()
    end)
    self:RegisterEvent(ComMgrs.dy_data_mgr, "UpdateCurrencyEvent", function (_, currency)
        UIFuncs.UpdateCurrencyItemNum(self._item_to_text_list, currency)
    end)
    self:RegisterEvent(ComMgrs.dy_data_mgr, "UpdateRoleInfoEvent", function ()
        self:UpdateRoleInfo()
    end)
    self:InitTraitorState()
    self:RegisterEvent(self.dy_traitor_data, "TraitorDisappearEvent", function ()
        self.traitor_info_panel:SetActive(false)
    end)
    self:RegisterEvent(SpecMgrs.ui_mgr, "HideUIEvent", function (_, ui)
        if ui.class_name == "SoldierBattleUI" or ui.class_name == "HeroBattleUI" then
            self:AfterBattle()
        end
    end)
end

function CityStageUI:InitTraitorState()
    local traitor_info = self.dy_traitor_data:GetTraitorInfo()
    self.traitor_info_panel:SetActive(traitor_info ~= nil)
    self:InitTraitorInfo(traitor_info)
end

function CityStageUI:InitTraitorInfo(traitor_info)
    if not traitor_info then return end
    local traitor_data = SpecMgrs.data_mgr:GetTraitorData(traitor_info.traitor_id)
    local quality_data = SpecMgrs.data_mgr:GetQualityData(traitor_info.quality)
    UIFuncs.AssignSpriteByIconID(quality_data.hero_bg, self.traitor_bg)
    local unit_data = SpecMgrs.data_mgr:GetUnitData(traitor_data.unit_id)
    UIFuncs.AssignSpriteByIconID(unit_data.icon, self.traitor_icon)
    self.traitor_name.text = self.dy_traitor_data:GetTraitorName(traitor_info.traitor_id, traitor_info.quality, true)
end

function CityStageUI:ChangeChildSibling()
    for index, go in ipairs(self.bg_list) do
        go:SetSiblingIndex(index)
    end
    local start_bg_index = self.map_type_data.bg_index
    local bg_build_num = self.bg_to_build_num[start_bg_index]
    local start_build_index = self.map_type_data.build_index
    start_build_index = math.clamp(start_build_index, 1, bg_build_num)
    local stage_num = #self.stage_id_list
    self.start_index = kDefaultBgNum + 1 - start_bg_index
    if stage_num > self.all_bg_build_num then
        PrintError("The num of stage is biger than all_bg_build_num")
        return
    end
    for i = 1, kDefaultBgNum do
        local index = self.start_index + i - 1
        local bg_index = self:GetBgIndex(index)
        local build_num = self.bg_to_build_num[bg_index]
        if i == 1 then
            stage_num = stage_num - (build_num - start_build_index + 1)
        else
            stage_num = stage_num - build_num
        end
        if stage_num <= 0 then
            self.end_index = index
            break
        end
    end
    local need_bg_num = self.end_index - self.start_index + 1 + 2 -- 上下各多加载一张可以看到边界
    for i = 1, kDefaultBgNum do
        local change_index = i + self.start_index - 2
        local bg_index = self:GetBgIndex(change_index)
        if i <= need_bg_num then
            self.bg_list[bg_index]:SetActive(true)
            self.bg_list[bg_index]:SetAsFirstSibling()
            self.bg_list[bg_index]:GetComponent("RectTransform").anchoredPosition = self.bg_pos_list[need_bg_num - i + 1]
        else
            self.bg_list[bg_index]:SetActive(false)
        end
    end
    local size = Vector2.New(self.grid_layout_group.cellSize.x, self.grid_layout_group.cellSize.y * (need_bg_num))
    self.content_rect.sizeDelta = size
end

function CityStageUI:GetStageBgIndexAndIndex(stage_index)
    for index = self.start_index, self.end_index do
        local bg_index = self:GetBgIndex(index)
        local build_num = self.bg_to_build_num[bg_index]
        if index == self.start_index then
            local start_build_index = self.map_type_data.build_index
            local remain_build_num = build_num - start_build_index + 1
            if stage_index > remain_build_num then
                stage_index = stage_index - remain_build_num
            else
                return bg_index, start_build_index + stage_index - 1
            end
        else
            if stage_index > build_num then
                stage_index = stage_index - build_num
            else
                return bg_index, stage_index
            end
        end
    end
end

function CityStageUI:GetBuildGo(bg_index, build_index)
    return self.bg_to_build_list[bg_index][build_index]
end

function CityStageUI:GetBgBuildNum(index)
    local bg_index = self:GetBgIndex(index)
    return self.bg_to_build_num[bg_index]
end

function CityStageUI:GetBgIndex(index)
    local remainder = index % kDefaultBgNum
    remainder = remainder == 0 and kDefaultBgNum or remainder
    local bg_index = kDefaultBgNum + 1 - remainder
    return bg_index
end

function CityStageUI:_PlayStageUnlockEffect(cur_stage)
    local old_stage = self.cur_stage
    self.cur_stage = cur_stage -- todo 播放完动画之后解锁
    self:_UpdateStageGo(old_stage)
    self:_UpdateStageGo(self.cur_stage)
end

function CityStageUI:Hide()
    self:ClearGoDict("city_treasure_list")
    self:ClearGoDict("star_progress_list")
    self:ClearGoDict("stage_to_treasure")
    self:ClearGoDict("stage_id_to_ui_go")
    for _, talk_cmp in pairs(self.stage_id_to_talk_cmp) do
        talk_cmp:DoDestroy()
    end
    self.stage_id_to_talk_cmp = {}
    self:ClearStagePreviewTalk()
    self.stage_id_to_go_parent = {}
    self.city_treasure_list = {}
    self:CleanSweepPanelGo()
    self.cur_city = nil
    self.city_data = nil
    self.stage_id_list = {}
    self.stage_id_to_name = {}
    self.map_type_data = nil
    self.show_preview_stage_id = nil
    CityStageUI.super.Hide(self)
end

function CityStageUI:_GetNatAndServBossStageData(stage_id)
    local serv_stage_data = self.dy_strategy_map_data:GetStageData(stage_id)
    return self.stage_data_list[stage_id], serv_stage_data
end

function CityStageUI:UpdateRoleInfo()
    local dy_data_mgr = ComMgrs.dy_data_mgr
    self.score_text.text = UIFuncs.AddCountUnit(dy_data_mgr:ExGetBattleScore())
    self.main_role_level_text.text = string.format(UIConst.Text.LEVEL, dy_data_mgr:ExGetRoleLevel())
    local exp_percent = dy_data_mgr:ExGetRoleExpPercentage()
    self.exp_slider.value = exp_percent
end

function CityStageUI:RemoveAllBuildClick()
    for i, go_list in ipairs(self.bg_to_build_list) do
        for i, go in ipairs(go_list) do
            self:RemoveClick(go:FindChild("Build"))
        end
    end
end

function CityStageUI:_InitMainPanel()
    local dy_data_mgr = ComMgrs.dy_data_mgr
    local role_id = dy_data_mgr:ExGetRoleId()
    local role_data = SpecMgrs.data_mgr:GetRoleLookData(role_id)
    self.city_name_text.text = self.city_data.name
    self:AssignSpriteByIconID(role_data.head_icon_id, self.main_role_icon_image)
    self:UpdateRoleInfo()
    self.cur_stage = self.dy_strategy_map_data:GetCurStage()
    local stage_data
    self:ChangeChildSibling() -- 更换地图顺序
    self:RemoveAllBuildClick()
    for i, stage_id in ipairs(self.stage_id_list) do
        local bg_index, build_index = self:GetStageBgIndexAndIndex(i)
        local go_parent = self:GetBuildGo(bg_index, build_index)
        stage_data = self.stage_data_list[stage_id]
        local stage_go_temp = stage_data.is_boss and self.boss_stage_go_temp or self.soldier_stage_go_temp
        local stage_go = self:GetUIObject(stage_go_temp, go_parent:FindChild("UIParent"))
        stage_go.name = stage_id
        local build_model_go = go_parent:FindChild("Build")
        if stage_data.treasure_dict then
            local treasure_box_id = stage_data.treasure_box_id
            local treasure_box = UIFuncs.GetTreasureBox(self, stage_go:FindChild("StageName/TreasureBoxParent"), treasure_box_id)
            self.stage_to_treasure[stage_id] = treasure_box
            self:AddClick(treasure_box, function()
                self:BossStageTreasureBoxOnClick(stage_id)
            end)
        end
        stage_go:FindChild("StageName/Text"):GetComponent("Text").text = self:GetStageName(bg_index, build_index, stage_id)
        self:AddClick(build_model_go, function()
            self:StageOnClick(stage_id)
        end)
        self:AddClick(stage_go:FindChild("Icon"), function()
            self:StageOnClick(stage_id)
        end)
        self.stage_id_to_go_parent[stage_id] = go_parent
        self.stage_id_to_ui_go[stage_id] = stage_go
    end
    for i, stage_id in ipairs(self.stage_id_list) do
        self:_UpdateStageGo(stage_id)
    end
    self:UpdateScrollRectLimit()
    self:SliderToCurStage()
    self:_InitTreasureBox()
end

function CityStageUI:StageOnClick(stage_id)
    if self.is_wait_for_cb then return end
    if self.cur_stage < stage_id then
        local str = string.format(UIConst.Text.UNLOCK_STAGE, self.stage_id_to_name[stage_id - 1])
        SpecMgrs.ui_mgr:ShowTipMsg(str)
        return
    end
    local is_boss_stage = self.stage_data_list[stage_id].is_boss
    if is_boss_stage then
        self:ShowStagePreviewPanel(stage_id)
    else
        self:BeforeShowSoliderBattle(stage_id)
    end
end

function CityStageUI:BeforeShowSoliderBattle(stage_id)
    if self.cur_stage == stage_id then
        local active_point = self.dy_strategy_map_data:GetActionPoint()
        local cast_active_point = self.stage_data_list[stage_id].cost_action_point
        if not UIFuncs.CheckItemCount(CSConst.CostValueItem.ActionPoint, cast_active_point, true) then
            return
        end
        if not self.dy_strategy_map_data:CheckSoldierNum() then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.NO_SOLDIER)
            return
        end
        self:CheckBeforeFight(stage_id, function ()
            SpecMgrs.ui_mgr:ShowUI("SoldierBattleUI")
        end)
    else
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.ALREADY_PASS_THIS_STAGE)
    end
end

function CityStageUI:SetFightStageCache(stage_id)
    self.fight_stage_cache = {}
    self.fight_stage_cache.fight_stage = stage_id
    self.fight_stage_cache.before_stage_state = self.dy_strategy_map_data:GetStageState(stage_id)
end

function CityStageUI:FightBtnOnClick(stage_id)
    if self.is_wait_for_cb then return end
    local stage_id  = self.show_preview_stage_id
    if not stage_id then return end
    if not ComMgrs.dy_data_mgr.night_club_data:CheckHeroLineup(true) then return end
    if not self:CheckStageCastAction(self.show_preview_stage_id) then
        return
    end
    if self:_GetRemainTime(self.show_preview_stage_id) <= 0 then
        self:ResetBtnOnClick()
        return
    end
    local stage_id = self.show_preview_stage_id
    self:HideStagePreviewPanel()
    self:CheckBeforeFight(stage_id, function ()
        self:SendBossStageFight(stage_id)
    end)
end

function CityStageUI:SendBossStageFight(stage_id)
    if self.is_wait_for_cb then return end
    self.is_wait_for_cb = true
    SpecMgrs.msg_mgr:SendMsg("SendBossStageFight", {stage_id = stage_id}, function (resp)
        self.is_wait_for_cb = nil
        if not self.is_res_ok then return end
        local item_dict = resp.is_win and ItemUtil.RoleItemListToItemDict(resp.item_list) or {}
        local stage_data = self.stage_data_list[stage_id]
        SpecMgrs.ui_mgr:EnterHeroBattle(resp.fight_data, UIConst.BattleScence.CityStageUI, stage_data.battle_bg)
        if resp.traitor_info then
            self.fight_stage_cache.traitor_info = resp.traitor_info
        end
        SpecMgrs.ui_mgr:RegiseHeroBattleEnd("CityStageUI", function()
            local is_win = resp.is_win
            local param_tb = {
                is_win = resp.is_win,
                show_level = true,
                reward = item_dict,
                --func = traitor_cb,
                star_level = self.dy_strategy_map_data:GetStageData(stage_id).star_num,
            }
            SpecMgrs.ui_mgr:AddCloseBattlePopUpList("BattleResultUI", param_tb)
        end)
    end)
end

function CityStageUI:AfterBattle()
    if not self.fight_stage_cache then return end
    local traitor_info = self.fight_stage_cache.traitor_info
    if traitor_info then
        self.dy_traitor_data:NotifyAddTraitor(traitor_info)
        SpecMgrs.ui_mgr:ShowUI("TraitorAppearUI", traitor_info)
        self:InitTraitorInfo(traitor_info)
        self.traitor_info_panel:SetActive(true)
        self.traitor_info = nil
    end
    local before_stage_state = self.fight_stage_cache.before_stage_state
    local fight_stage = self.fight_stage_cache.fight_stage
    local state_dict = CSConst.Stage.State
    local cur_state = self.dy_strategy_map_data:GetStageState(fight_stage)
    local is_show_dialog = (before_stage_state == state_dict.New or before_stage_state == state_dict.Unpass) and cur_state == state_dict.FirstPass
    if is_show_dialog then
        local after_dialog_id = self.stage_data_list[fight_stage].after_dialog_id
        if after_dialog_id then
            local dialog_data = SpecMgrs.data_mgr:GetDialogData(after_dialog_id)
            SpecMgrs.ui_mgr:ShowDialog(dialog_data.group_id)
        end
    end
    self.fight_stage_cache = nil
end
function CityStageUI:CheckBeforeFight(stage_id, cb)
    self:SetFightStageCache(stage_id)
    if self.dy_strategy_map_data:IsFirstFight(stage_id) then
        local dialog_id = self.stage_data_list[stage_id].dialog_id
        if dialog_id then
            local dialog_data = SpecMgrs.data_mgr:GetDialogData(dialog_id)
            SpecMgrs.ui_mgr:ShowDialog(dialog_data.group_id, cb)
            SpecMgrs.msg_mgr:SendMsg("SendEnterStage", {stage_id = stage_id})
        else
            cb()
        end
    else
        cb()
    end
end

function CityStageUI:_UpdateStageGo(stage_id)
    local build_go = self.stage_id_to_ui_go[stage_id]
    if not build_go then return end -- 新关卡不在该地图上
    local nat_stage_data, boss_stage_data = self:_GetNatAndServBossStageData(stage_id)
    local cur_stage = self.dy_strategy_map_data:GetCurStage()
    local is_stage_unlock = cur_stage >= stage_id
    local is_cur_stage = cur_stage == stage_id
    local is_complete = cur_stage > stage_id
    if nat_stage_data.is_boss then
        build_go:FindChild("Icon/Lock"):SetActive(not is_stage_unlock)
        build_go:FindChild("Icon/Stars"):SetActive(is_stage_unlock and not is_cur_stage)
        build_go:FindChild("Icon/AtWar"):SetActive(is_cur_stage)
        build_go:FindChild("Icon/Normal"):SetActive(is_stage_unlock and not is_cur_stage)
        if is_stage_unlock then
            local cur_star_num = boss_stage_data and boss_stage_data.star_num or 0
            for i = 1, kMaxStarNum do
                build_go:FindChild("Icon/Stars/".. i .. "/Star"):SetActive(i <= cur_star_num)
            end
        end
        local _, hero_data, unit_data = MonsterUtil.GetMainMonsterData(nat_stage_data.monster_group_id)
        self:AssignSpriteByIconID(unit_data.icon, build_go:FindChild("Icon/Normal/Image"):GetComponent("Image"))
        self:AssignSpriteByIconID(unit_data.icon, build_go:FindChild("Icon/Lock/Image"):GetComponent("Image"))
        self:AssignSpriteByIconID(unit_data.icon, build_go:FindChild("Icon/AtWar/Image"):GetComponent("Image"))
        local talk_parent = build_go:FindChild("Icon/TalkParent")
        talk_parent:SetActive(is_cur_stage)
        if is_cur_stage then
            local go_parent = self.stage_id_to_go_parent[stage_id]
            local is_right = go_parent:GetComponent("RectTransform").anchoredPosition.x < 0 and true or false
            local rect = talk_parent:GetComponent("RectTransform")
            local pos = rect.anchoredPosition
            local x = is_right and math.abs(pos.x) or -math.abs(pos.x)
            rect.anchoredPosition = Vector2.New(x, pos.y)
            if not self.stage_id_to_talk_cmp[stage_id] then
                self.stage_id_to_talk_cmp[stage_id] = self:GetTalkCmp(talk_parent, 1, not is_right, function ()
                    return UIFuncs.GetHeroTalk(hero_data.id)
                end, self.change_talk_time)
            end
        elseif self.stage_id_to_talk_cmp[stage_id] then
            self.stage_id_to_talk_cmp[stage_id]:DoDestroy()
            self.stage_id_to_talk_cmp[stage_id] = nil
        end
    else
        build_go:FindChild("Icon/AtWar"):SetActive(is_cur_stage)
        build_go:FindChild("Icon/Lock"):SetActive(not is_stage_unlock)
        build_go:FindChild("Icon/Complete"):SetActive(is_complete)
    end
end

function CityStageUI:Recover()
    self:UpdateAllTreasureBox()
end

function CityStageUI:UpdateAllTreasureBox()
    if not self.go.activeSelf then return end -- ui被隐藏不更新
    local star_num_list = self.city_data.star_num_list
    local serv_city_data = self.dy_strategy_map_data:GetCityDataByCityId(self.cur_city)
    local reward_dict = serv_city_data and serv_city_data.reward_dict
    for i, _ in ipairs(star_num_list) do
        local treasure_box = self.city_treasure_list[i]
        if reward_dict then
            UIFuncs.UpdateTreasureBoxStatus(treasure_box, reward_dict[i])
        else
            UIFuncs.UpdateTreasureBoxStatus(treasure_box, false)
        end
    end
    for stage_id, treasure_go in pairs(self.stage_to_treasure) do
        local nat_stage_data, boss_stage_data = self:_GetNatAndServBossStageData(stage_id)
        if nat_stage_data.treasure_dict then
            treasure_go:SetActive(true)
            if boss_stage_data then
                UIFuncs.UpdateTreasureBoxStatus(treasure_go, boss_stage_data.first_reward)
            else
                UIFuncs.UpdateTreasureBoxStatus(treasure_go, false)
            end
        end
    end
end

function CityStageUI:_InitTreasureBox()
    local star_num_list = self.city_data.star_num_list
    local max_star_count = #star_num_list
    self:ClearGoDict("city_treasure_list")
    self:ClearGoDict("star_progress_list")
    for i, star_num in ipairs(star_num_list) do
        local star_progress_go = self:GetUIObject(self.treasure_item_temp, self.treasure_item_parent)
        table.insert(self.star_progress_list, star_progress_go)
        local treasure_box_id = self.city_data.treasure_box_id_list and self.city_data.treasure_box_id_list[i]
        local treasure_box = UIFuncs.GetTreasureBox(self, star_progress_go:FindChild("Image/TreasureBoxParent"), treasure_box_id)
        table.insert(self.city_treasure_list, treasure_box)
        star_progress_go:FindChild("Image/Text"):GetComponent("Text").text = star_num
        self:AddClick(treasure_box, function()
            self:TreasureBoxOnClick(i)
        end)
        --self:ChangeTreasureBox(i, i == max_star_count)
    end
    self:_UpdateTreasureSlider()
end

function CityStageUI:_UpdateTreasureSlider()
    local star_num_list = self.city_data.star_num_list
    local serv_city_data = self.dy_strategy_map_data:GetCityDataByCityId(self.cur_city)
    local cur_star_num = serv_city_data and serv_city_data.star_num or 0
    self.treasure_slider.value = UIFuncs.CalculateTreasureSliderValue(cur_star_num, star_num_list)
    local max_star_num = SpecMgrs.data_mgr:GetStageData("city_max_star_num")[self.cur_city]
    self.star_num_text.text = string.format(UIConst.Text.SPRIT, cur_star_num, max_star_num)
end

function CityStageUI:_CalculateTreasureSliderValue(cur_star_num, star_num_list)
    if cur_star_num <= 0 then return 0 end
    local ret_value
    local max_count = #star_num_list
    for i, star_num in ipairs(star_num_list) do
        if cur_star_num < star_num then
            local prev_index = i - 1
            local prev_star_num = star_num_list[prev_index] or 0
            if prev_index == 0 then
                ret_value = cur_star_num / star_num / max_count
            else
                ret_value = prev_index / max_count + (cur_star_num - prev_star_num)/ (star_num - prev_star_num) / max_count
            end
            break
        end
    end
    ret_value = ret_value or 1
    ret_value = math.floor(ret_value / self.treasure_slider_precision) * self.treasure_slider_precision
    return ret_value
end

function CityStageUI:ShowStagePreviewPanel(stage_id)
    self.stage_preview_panel:SetActive(true)
    self.show_preview_stage_id = stage_id
    local nat_stage_data = self:_GetNatAndServBossStageData(stage_id)
    self.spp_stage_name_text.text = self.stage_id_to_name[stage_id]
    self.spp_action_cost_text.text = nat_stage_data.cost_action_point
    local monster_data, hero_data = MonsterUtil.GetMainMonsterData(nat_stage_data.monster_group_id)
    self.spp_boss_unit = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = hero_data.unit_id, parent = self.spp_boss_unit_parent})
    self.spp_boss_unit:SetPositionByRectName({parent = self.spp_boss_unit_parent, name = UnitConst.UnitRect.Half})
    self.spp_suggest_score_text.text = UIFuncs.GetMonsterGroupScoreSuggestStr(nat_stage_data.monster_group_id, nat_stage_data.monster_level)
    self.spp_boss_name_text.text = monster_data.name
    self.stage_preview_talk = self:GetTalkCmp(self.spp_boss_talk_parent, 1, false, function ()
        return UIFuncs.GetHeroTalk(hero_data.id)
    end, self.change_talk_time)

    local sort_item_data_list = ItemUtil.GetSortedDropItemDataList(nat_stage_data.stage_drop)
    local award_go
    for _, item_data_dict in ipairs(sort_item_data_list) do
        local param_tb = {
            parent = self.spp_award_go_parent,
            item_data = item_data_dict.item_data,
            count = item_data_dict.count,
            ui = self,
        }
        award_go = UIFuncs.GetInitItemGoByTb(param_tb)
        table.insert(self.spp_award_go_list, award_go)
    end
    self:_UpdateStagePreviewPanel()
end

function CityStageUI:GetStageName(bg_index, build_index, stage_id)
    local first_name = self.stage_data_list[stage_id].name
    local build_name_list = SpecMgrs.data_mgr:GetInfiMapBuildNameData(bg_index).name_list
    local second_name = build_name_list[build_index] or build_name_list[1]
    local name = UIFuncs.GetStageNameById(stage_id) -- first_name .. second_name
    self.stage_id_to_name[stage_id] = name
    return name
end

function CityStageUI:_UpdateStagePreviewPanel(stage_id)
    if not self.show_preview_stage_id then return end
    if stage_id and stage_id ~= self.show_preview_stage_id then return end
    local nat_stage_data, boss_stage_data = self:_GetNatAndServBossStageData(self.show_preview_stage_id)
    local cur_star_num = boss_stage_data and boss_stage_data.star_num or 0
    local cur_victory_num = boss_stage_data and boss_stage_data.victory_num or 0
    local cur_reset_num = boss_stage_data and boss_stage_data.reset_num or 0
    for i = 1, kMaxStarNum do
        self.spp_star_go_list[i]:SetActive(i <= cur_star_num)
    end
    local reset_limit = self.dy_strategy_map_data:GetStageResetNum(self.show_preview_stage_id)
    self.spp_pass_time_text.text = string.format(UIConst.Text.PASS_TIME,nat_stage_data.victory_num - cur_victory_num, nat_stage_data.victory_num)
    self.is_sweep_unlcok = cur_star_num >= kMaxStarNum
    self.spp_reset_text.text = string.format(UIConst.Text.RESET_TIME, reset_limit - cur_reset_num, reset_limit)
    self:_UpdateSweepBtn()
end

function CityStageUI:_GetSweepBtnStatus(stage_id)
    local nat_stage_data, boss_stage_data = self:_GetNatAndServBossStageData(stage_id)
    local can_fight_time = math.floor(self.dy_strategy_map_data:GetActionPoint() / nat_stage_data.cost_action_point)
    local cur_victory_num = boss_stage_data and boss_stage_data.victory_num or 0
    local remain_time = nat_stage_data.victory_num - cur_victory_num
    local limit = math.min(remain_time, self.sweep_limit)
    local can_sweep_time = math.clamp(can_fight_time, 0, limit)
    return can_sweep_time, remain_time > 0
end

function CityStageUI:CheckStageCastAction(stage_id)
    local cast_active_point = self.stage_data_list[stage_id].cost_action_point
    if not UIFuncs.CheckItemCount(CSConst.CostValueItem.ActionPoint, cast_active_point, true) then
        return
    end
    return true
end

function CityStageUI:_GetRemainTime(stage_id)
    local nat_stage_data, boss_stage_data = self:_GetNatAndServBossStageData(stage_id)
    local cur_victory_num = boss_stage_data and boss_stage_data.victory_num or 0
    local remain_time = nat_stage_data.victory_num - cur_victory_num
    return remain_time
end

function CityStageUI:HideStagePreviewPanel()
    self.show_preview_stage_id = nil
    self.is_sweep_unlcok = nil
    self:ClearGoDict("spp_award_go_list")
    self:ClearUnit("spp_boss_unit")
    self:ClearStagePreviewTalk()
    self.stage_preview_panel:SetActive(false)
end

function CityStageUI:ClearStagePreviewTalk()
    if self.stage_preview_talk then
        self.stage_preview_talk:DoDestroy()
        self.stage_preview_talk = nil
    end
end

-- sweep
function CityStageUI:ShowSweepPanel()
    self.sweep_panel:SetActive(true)
    self:BeginSweep()
end

function CityStageUI:HideSweepPanel()
    self:CleanSweepPanelGo()
    self.sweep_panel:SetActive(false)
end

function CityStageUI:CleanSweepPanelGo()
    self:ClearGoDict("sp_reward_item_go_list")
    self:ClearGoDict("sp_reward_go_list")
    self:ClearGoDict("sp_sweep_total_go_list")
end

-- sweep_panel end
function CityStageUI:ResetBtnOnClick()
    local stage_id = self.show_preview_stage_id
    if not stage_id then return end
    local nat_stage_data, serv_stage_data = self:_GetNatAndServBossStageData(stage_id)
    if nat_stage_data.is_boss then
        local cur_reset_num = serv_stage_data and serv_stage_data.reset_num or 0
        local reset_limit = self.dy_strategy_map_data:GetStageResetNum(stage_id)
        if cur_reset_num >= reset_limit then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.CANNOT_RESET_TIP)
            return
        end
        local all_reet_data = SpecMgrs.data_mgr:GetAllStageResetData(cur_reset_num + 1)
        local reset_data = all_reet_data[cur_reset_num + 1] or all_reet_data[#all_reet_data]
        if not UIFuncs.CheckItemCount(reset_data.cost_item, reset_data.cost_num, true) then
            return
        end
        local item_name = SpecMgrs.data_mgr:GetItemData(reset_data.cost_item).name
        local content_str = string.format(UIConst.Text.RESET_TEXT, reset_data.cost_num, item_name)
        local remain_time = reset_limit - cur_reset_num
        local desc1 = string.format(UIConst.Text.REMAIN_RESET_TIME_OF_TODAY, remain_time)
        local param_tb = {
            item_id = reset_data.cost_item,
            need_count = reset_data.cost_num,
            desc = content_str,
            desc1 = desc1,
            title = UIConst.Text.RESET_STAGE_TITLE,
            confirm_cb = function()
                self:SendResetBossStage(stage_id)
            end,
        }
        SpecMgrs.ui_mgr:ShowItemUseRemindByTb(param_tb)
    end
end

function CityStageUI:SendResetBossStage(stage_id)
    SpecMgrs.msg_mgr:SendMsg("SendResetBossStage",{stage_id = stage_id})
end

function CityStageUI:SweepBtnOnClick(cb)
    local stage_id = self.show_preview_stage_id
    if not stage_id then return end
    if not self.is_sweep_unlcok then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.SWEEP_UNLOCK)
        return
    end
    if not self:CheckStageCastAction(self.show_preview_stage_id) then
        return
    end
    cb()
end

function CityStageUI:BeginSweep(stage_id)
    self.scroll_after_sweep = nil
    local stage_id = self.show_preview_stage_id
    if not stage_id then return end
    if not self.stage_data_list[stage_id].is_boss then return end
    local sweep_time = self:_GetSweepBtnStatus(stage_id)
    if sweep_time <= 0 then return end
    self:CleanSweepPanelGo()
    self.sp_stop_touch_bg:SetActive(true) -- 扫荡期间暂时禁止点击
    self.sp_sweep_stage = stage_id
    self.sp_sweep_time = sweep_time
    self.cur_sweep_time = 1
    self.total_sweep_reward_dict = {}
    self.total_item_data_list = {}
    local sp_reward_go = self:GetUIObject(self.sp_reward_go_temp, self.sp_reward_go_parent)
    table.insert(self.sp_reward_go_list, sp_reward_go)
    sp_reward_go:SetActive(false)
    sp_reward_go:FindChild("Titile/Text"):GetComponent("Text").text = UIConst.Text.TOTAL_GET
    SpecMgrs.msg_mgr:SendSweepBossStage({stage_id = stage_id}, function(resp)
        self:SendSweepBossStageCb(resp)
    end)
end

function CityStageUI:SendSweepBossStageCb(resp)
    if resp.errcode ~= 0 then
        PrintError("Get wrong errcode in SendSweepBossStageCb", self.sp_sweep_stage)
        self:SweepEnd()
    else
        local item_dict = ItemUtil.RoleItemListToItemDict(resp.item_list)
        local item_data_list = {}
        for item_id, _ in pairs(item_dict) do
            local item_data = SpecMgrs.data_mgr:GetItemData(item_id)
            table.insert(item_data_list, item_data)
        end
        ItemUtil.SortItem(item_data_list)
        local sp_reward_go = self:GetUIObject(self.sp_reward_go_temp, self.sp_reward_go_parent)
        table.insert(self.sp_reward_go_list, sp_reward_go)
        local title_str = string.format(UIConst.Text.SWEEP_TITLE, #self.sp_reward_go_list - 1)
        sp_reward_go:FindChild("Titile/Text"):GetComponent("Text").text = title_str
        self:_UpdateTotalSweepReward(item_dict)
        self:_UpdateSweepRewardGo(sp_reward_go, item_dict, item_data_list, false)
        self.cur_sweep_time = self.cur_sweep_time + 1
        if resp.traitor_info then
            self:SweepEnd()
            self:EndScrollSweepPanel()
            self.dy_traitor_data:NotifyAddTraitor(resp.traitor_info)
            SpecMgrs.ui_mgr:ShowUI("TraitorAppearUI", resp.traitor_info)
            self:InitTraitorInfo(resp.traitor_info)
            self.traitor_info_panel:SetActive(true)
            return
        end
        if not self.is_level_up and self.cur_sweep_time <= self.sp_sweep_time then
            self.sweep_timer = 0 -- 继续扫荡
        else
            self:SweepEnd()
        end
    end
end

function CityStageUI:_UpdateTotalSweepReward(item_dict)
    local is_need_sort = false
    for item_id, num in pairs(item_dict) do
        if not self.total_sweep_reward_dict[item_id] then
            is_need_sort = true
            self.total_sweep_reward_dict[item_id] = num
            local item_data = SpecMgrs.data_mgr:GetItemData(item_id)
            table.insert(self.total_item_data_list, item_data)
        else
            self.total_sweep_reward_dict[item_id] = self.total_sweep_reward_dict[item_id] + num
        end
    end
    if is_need_sort then
        ItemUtil.SortItem(self.total_item_data_list)
    end
end

function CityStageUI:_UpdateSweepRewardGo(go, item_dict, item_data_list, is_total)
    go:FindChild("Exp/Image/Text"):GetComponent("Text").text = item_dict[CSConst.Virtual.Exp] or 0
    go:FindChild("Money/Image/Text"):GetComponent("Text").text = item_dict[CSConst.Virtual.Money] or 0
    local reward_item_go_parent = go:FindChild("Scroll View/Viewport/Content")
    for i, item_data in ipairs(item_data_list) do
        if item_data.id ~= CSConst.Virtual.Exp and item_data.id ~= CSConst.Virtual.Money then
            local param_tb = {parent = reward_item_go_parent,
                item_data = item_data,
                count = item_dict[item_data.id],
                ui = self,
                size = self.sp_item_size,
            }
            local item_go = UIFuncs.GetInitItemGoByTb(param_tb)
            if is_total then
                table.insert(self.sp_sweep_total_go_list, item_go)
            else
                table.insert(self.sp_reward_item_go_list, item_go)
            end
        end
    end
end

function CityStageUI:SweepEnd()
    -- 最后显示总计
    self.sp_reward_go_list[1]:SetAsLastSibling()
    self:_UpdateSweepRewardGo(self.sp_reward_go_list[1], self.total_sweep_reward_dict, self.total_item_data_list, true)
    self.sp_reward_go_list[1]:SetActive(true)
    self.sp_sweep_stage = nil
    self.sp_sweep_time = nil
    self.cur_sweep_time = nil
    self.is_level_up = nil
    self.scroll_after_sweep = true
    self.total_sweep_reward_dict = nil
    self.total_item_data_list = nil
    self:_UpdateSweepBtn()
end

function CityStageUI:EndScrollSweepPanel()
    self.scroll_after_sweep = nil
    self.sp_stop_touch_bg:SetActive(false)
end

function CityStageUI:ScrollSweepPanel(delta_time)
    if self.sp_sweep_stage or self.scroll_after_sweep then
        local nor_pos = self.sweep_scroll_rect.verticalNormalizedPosition
        local content_height = self.sweep_scroll_rect.content.rect.height
        local view_height = self.sweep_scroll_rect.viewport.rect.height
        nor_pos = nor_pos - delta_time * self.sweep_scroll_speed / (content_height - view_height)

        self.sweep_scroll_rect.verticalNormalizedPosition = nor_pos
        if self.scroll_after_sweep then
            if not self.timer then self.timer = 0 end
            self.timer = self.timer + delta_time
            if self.timer >= 0.1 and nor_pos <= 0 then -- scroll_rect 的位置下一帧才会计算新的verticalNormalizedPosition
                self:EndScrollSweepPanel()
                self.timer = nil
            end
        end
    end
end

function CityStageUI:_UpdateSweepBtn()
    if not self.show_preview_stage_id then return end
    local sweep_time, is_show_sweep_btn = self:_GetSweepBtnStatus(self.show_preview_stage_id)
    local btn_str = self.is_sweep_unlcok and sweep_time > 0 and string.format(UIConst.Text.SWEEP_TIME, sweep_time) or UIConst.Text.SWEEP
    self.sp_sweep_btn_text.text = btn_str
    self.spp_sweep_btn_text.text = btn_str
    self.spp_sweep_btn:SetActive(is_show_sweep_btn)
    self.sp_sweep_btn:SetActive(is_show_sweep_btn)
    self.sp_reset_btn:SetActive(not is_show_sweep_btn)
    self.spp_reset_btn:SetActive(not is_show_sweep_btn)
end

function CityStageUI:_CheckHeroLineup()
    local lineup_dict = ComMgrs.dy_data_mgr.night_club_data:GetAllLineupData()
    if lineup_dict then
        for k, v in pairs(lineup_dict) do
            if v.hero_id and v.pos_id then
                return true
            end
        end
    end
    return false
end

function CityStageUI:TreasureBoxOnClick(index)
    -- todo 添加预览
    local city_id = self.cur_city
    local serv_city_data = self.dy_strategy_map_data:GetCityDataByCityId(city_id)
    local reward_state
    if not serv_city_data or serv_city_data.reward_dict[index] == false then
        reward_state = CSConst.RewardState.unpick
    elseif serv_city_data and serv_city_data.reward_dict[index] == true then
        reward_state = CSConst.RewardState.pick
    else
        reward_state = CSConst.RewardState.picked
    end
    local reward_id = self.city_data.reward_list[index]
    UIFuncs.ShowTreasurePreview(reward_id, reward_state, function ()
        self:SendGetCityStarReward(city_id, index)
    end)
end

function CityStageUI:SendGetCityStarReward(city_id, index)
    SpecMgrs.msg_mgr:SendMsg("SendGetCityStarReward", {city_id = city_id, reward_index = index}, function(resp)
        UIFuncs.PlayOpenBoxAnim(self.city_treasure_list[index])
        local reward_id = self.city_data.reward_list[index]
        UIFuncs.ShowGetRewardItem(reward_id, true)
    end)
end

function CityStageUI:BossStageTreasureBoxOnClick(stage_id)
    local _, serv_stage_data = self:_GetNatAndServBossStageData(stage_id)
    local reward_state
    if not serv_stage_data or serv_stage_data.first_reward == false then
        reward_state = CSConst.RewardState.unpick
    elseif serv_stage_data and serv_stage_data.first_reward == true then
        reward_state = CSConst.RewardState.pick
    else
        reward_state = CSConst.RewardState.picked
    end
    local item_dict = self.stage_data_list[stage_id].treasure_dict
    local item_list = {}
    for item_id, count in pairs(item_dict) do
        local reward_data = {item_id = item_id, count = count, item_data = SpecMgrs.data_mgr:GetItemData(item_id)}
        table.insert(item_list, reward_data)
    end
    ItemUtil.SortItem(item_list)
    UIFuncs.ShowTreasurePreview(item_list, reward_state, function ()
        self:SendGetStageFirstReward(stage_id)
    end)
end

function CityStageUI:SendGetStageFirstReward(stage_id)
    SpecMgrs.msg_mgr:SendMsg("SendGetStageFirstReward", {stage_id = stage_id}, function(resp)
        local tresaure_go = self.stage_to_treasure[stage_id]
        UIFuncs.PlayOpenBoxAnim(tresaure_go)
        local item_dict = self.stage_data_list[stage_id].treasure_dict
        UIFuncs.ShowGetRewardItemByItemDict(item_dict, true)
    end)
end

return CityStageUI