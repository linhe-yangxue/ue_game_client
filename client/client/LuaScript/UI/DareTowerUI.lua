local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local UnitConst = require("Unit.UnitConst")
local DareTowerUI = class("UI.DareTowerUI", UIBase)
local ItemUtil = require("BaseUtilities.ItemUtil")
local MonsterUtil = require("BaseUtilities.MonsterUtil")
local InfinityGridLayoutGroupCmp = require("UI.UICmp.InfinityGridLayoutGroupCmp")
local SoundConst = require("Sound.SoundConst")
DareTowerUI.need_sync_load = true

local kStageNumEachBg = 5
local kDefaultBgNum = 7
local kDefultOffset = 1000 -- 默认可以继续上拉500像素

function DareTowerUI:DoInit()
    DareTowerUI.super.DoInit(self)
    self.prefab_path = "UI/Common/DareTowerUI"
    self.dy_dare_tower_data = ComMgrs.dy_data_mgr.dare_tower_data
    self.action_point_limit = SpecMgrs.data_mgr:GetParamData("stage_action_point_limit").f_value
    self.change_talk_time = SpecMgrs.data_mgr:GetParamData("change_talk_time").f_value
    self.bg_list = {}
    self.bg_pos_list = {}
    self.bg_to_ui_go_list = {}
    self.bg_to_build_list = {}
    self.bg_to_build_num = {}
    -- 需要清理的
    self.go_to_tower_id = {}
    self.tower_id_to_go = {}
    self.tower_id_to_treasure = {}
    self.tower_id_to_talk_cmp = {}
    self.tpp_award_go_list = {}
    self.tower_go_to_ui_go = {}
end

function DareTowerUI:OnGoLoadedOk(res_go)
    DareTowerUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function DareTowerUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    DareTowerUI.super.Show(self)
    self:UpdateAllTreasureBox()
end

function DareTowerUI:Update()
    self:UpdateScrollRectLimitUpPos()
    if self.limit_up_pos then
        if self.tower_scroll_rect.verticalNormalizedPosition > self.limit_up_pos then
            self.tower_scroll_rect.verticalNormalizedPosition = self.limit_up_pos
        end
    end
end

function DareTowerUI:InitRes()
    local top_bar = self.main_panel:FindChild("PanelList/InitPanel/Panel/Top1")
    UIFuncs.InitTopBar(self, top_bar, "DareTowerUI")

    self:InitInfinityGridLayoutGroupCmp()
    self.gray_material = SpecMgrs.res_mgr:GetMaterialSync(UIConst.MaterialResPath.UIGray)
    self.init_panel = self.main_panel:FindChild("PanelList/InitPanel")
    self.main_role_icon_image = self.init_panel:FindChild("Panel/Top2/Icon/Image"):GetComponent("Image")
    self.main_role_level_text = self.init_panel:FindChild("Panel/Top2/Icon/Text"):GetComponent("Text")
    self.score_text = self.init_panel:FindChild("Panel/Top2/Right/Attr/Score/Text"):GetComponent("Text")
    self.exp_slider = self.init_panel:FindChild("Panel/Top2/Right/Exp"):GetComponent("Slider")
    self.fight_time_text = self.init_panel:FindChild("Panel/BottonBar/Text"):GetComponent("Text")
    self.ui_temp = self.main_panel:FindChild("Temp/StageName")
    self:AddClick(self.init_panel:FindChild("Panel/Top1/HelpBtn"), function()
        UIFuncs.ShowPanelHelp("DareTowerUI")
    end)
    self:AddClick(self.init_panel:FindChild("Panel/Top1/CloseBtn"), function()
        SpecMgrs.ui_mgr:HideUI(self)
    end)
    self.tower_content_transform = self.init_panel:FindChild("Panel/Middle/Scroll View/Viewport/Content"):GetComponent("RectTransform")
    self.tower_view_rect_transform = self.init_panel:FindChild("Panel/Middle/Scroll View/Viewport"):GetComponent("RectTransform")
    self.tower_scroll_rect = self.init_panel:FindChild("Panel/Middle/Scroll View"):GetComponent("ScrollRect")
    local ui_temp = self.main_panel:FindChild("Temp/StageName")
    self.all_bg_build_num = 0
    for bg_index = 1, kDefaultBgNum do
        local bg_go = self.tower_content_transform.gameObject:FindChild("Bg_" .. bg_index)
        table.insert(self.bg_list, bg_go)
        local pos = bg_go:GetComponent("RectTransform").anchoredPosition
        table.insert(self.bg_pos_list, pos)
        local build_parent = bg_go:FindChild("BuildList")
        local build_parent_rect = build_parent:GetComponent("RectTransform")
        local child_num = build_parent_rect.childCount
        self.bg_to_build_num[bg_index] = child_num
        self.bg_to_build_list[bg_index] = {}
        for i = 1, child_num do
            self.bg_to_build_list[bg_index][i] = build_parent:FindChild(i)
        end
        self.all_bg_build_num = self.all_bg_build_num + child_num
    end
    -- TowerPreviewPanel 以下简称ssp
    self.tower_preview_panel = self.main_panel:FindChild("PanelList/TowerPreviewPanel")
    self.tpp_boss_unit_parent = self.tower_preview_panel:FindChild("Panel/Top/BossIcon/UnitParent")
    self.tpp_stage_name_text = self.tower_preview_panel:FindChild("Panel/Top/Middle/StageName"):GetComponent("Text")
    self.tpp_action_cost_text = self.tower_preview_panel:FindChild("Panel/Top/Middle/ActionPointCost/Text"):GetComponent("Text")
    self.tower_preview_panel:FindChild("Panel/Top/Middle/ActionPointCost"):GetComponent("Text").text = UIConst.Text.CONSUME_ACTION
    self.tpp_star_go_list = {}
    self.tpp_boss_name_text = self.tower_preview_panel:FindChild("Panel/Top/BossIcon/Image/Text"):GetComponent("Text")
    self.tpp_suggest_score_text = self.tower_preview_panel:FindChild("Panel/Top/Middle/SuggestScore"):GetComponent("Text")
    self.tpp_boss_talk_parent = self.tower_preview_panel:FindChild("Panel/Top/TalkParent")

    self.tpp_award_go_parent = self.tower_preview_panel:FindChild("Panel/BottonBar/Award/Viewport/Content")
    self.tpp_award_go_temp = self.tpp_award_go_parent:FindChild("Item")
    self.tpp_award_go_temp:SetActive(false)

    self:AddClick(self.tower_preview_panel:FindChild("Panel/Top/CloseBtn"), function()
        self:HideTowerPreviewPanel()
    end)
    local lineup_btn = self.tower_preview_panel:FindChild("Panel/Middle/ShowSmallLineupBtn")
    lineup_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.LINEUP
    self:AddClick(self.tower_preview_panel:FindChild("Panel/Middle/ShowSmallLineupBtn"), function()
        SpecMgrs.ui_mgr:ShowUI("SmallLineupUI")
    end)
    self.tpp_fight_btn = self.tower_preview_panel:FindChild("Panel/BtnList/FightBtn")
    self.tpp_fight_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.PLUNDER
    self.tpp_alread_fight_go = self.tower_preview_panel:FindChild("Panel/BtnList/AlreadyFight")
    self.tpp_first_pass_go = self.tower_preview_panel:FindChild("Panel/Middle/FirstPass")
    self.tpp_first_pass_go:GetComponent("Text").text = UIConst.Text.FIRST_PASS_AWARD
    self.tpp_first_pass_award_item_image = self.tpp_first_pass_go:FindChild("Image"):GetComponent("Image")
    self.tpp_first_pass_award_num_text = self.tpp_first_pass_go:FindChild("Image/Text"):GetComponent("Text")

    self:AddClick(self.tpp_fight_btn, function ()
        self:FightBtnOnClick()
    end)
    self.tower_preview_panel:FindChild("Panel/BottonBar/Top/Text"):GetComponent("Text").text = UIConst.Text.WIN_REWARD_TEXT
end

function DareTowerUI:InitUI()
    self:PlayBGM(SoundConst.SOUND_ID_DareTower)
    self:UpdateBgAmountByMaxTower()
    self:ChangeChildSiblingAndPos()
    self.infinity_grid_layout:Start(self.bg_amount)
    self:_InitMainPanel()

    self:RegisterEvent(self.dy_dare_tower_data, "UpdateDareTowerInfo", function (_, msg)
        self:NotifyUpdateDareTowerInfo(msg)
    end)
    self:RegisterEvent(ComMgrs.dy_data_mgr, "UpdateCurrencyEvent", function (_, currency)
        UIFuncs.UpdateCurrencyItemNum(self._item_to_text_list, currency)
    end)
    self:RegisterEvent(ComMgrs.dy_data_mgr, "UpdateRoleInfoEvent", function ()
        self:_InitMainPanel()
    end)
    self.tower_content_transform.localScale = UIFuncs.GetPerfectMapScale(true)
end

function DareTowerUI:Recover()
    self:UpdateAllTreasureBox()
end

function DareTowerUI:NotifyUpdateDareTowerInfo(msg)
    if msg.max_tower then
        self:UpdateBgAmountByMaxTower()
        self:ChangeChildSiblingAndPos()
        self.infinity_grid_layout:Start(self.bg_amount)
        self:UpdateAllTreasureBox()
    elseif msg.dare_dict then
        self:UpdateAllTower()
    end
    if msg.pass_num then
        self.fight_time_text.text = string.format(UIConst.Text.FIGHT_TIME_EACH_DAY, msg.pass_num)
    end
end

function DareTowerUI:UpdateAllTower()
    for tower_id, go in pairs(self.tower_id_to_go) do
        self:UpdateTower(tower_id)
    end
end

function DareTowerUI:UpdateBgAmountByMaxTower()
    local max_tower = self.dy_dare_tower_data:GetMaxTower()
    local count = math.floor(max_tower / self.all_bg_build_num)
    local remainder = max_tower % self.all_bg_build_num
    local count2
    for i = 1, kDefaultBgNum do
        local bg_index = kDefaultBgNum + 1 - i
        remainder = remainder - self.bg_to_build_num[bg_index]
        if remainder < 0 then -- 0 地图最后一个取多一位
            count2 = i
            break
        end
    end
    local new_bg_amount = kDefaultBgNum * count + count2 + 1-- 取多一张地图
    if not self.bg_amount then
        self.bg_amount = new_bg_amount
    elseif self.bg_amount < new_bg_amount then
        self.infinity_grid_layout:SetAmount(new_bg_amount, true)
        self.bg_amount = new_bg_amount
    end
    return self.bg_amount
end

function DareTowerUI:InitInfinityGridLayoutGroupCmp()
    if self.infinity_grid_layout then return end
    self.infinity_grid_layout = InfinityGridLayoutGroupCmp.New()
    local param_tb = {
        go = self.main_panel:FindChild("PanelList/InitPanel/Panel/Middle/Scroll View"),
        content_go = self.main_panel:FindChild("PanelList/InitPanel/Panel/Middle/Scroll View/Viewport/Content"),
        min_amount = kDefaultBgNum,
        init_item_cb = function (real_index, bg_trans)
            self:UpdateBg(real_index, bg_trans)
        end
    }
    self.infinity_grid_layout:DoInit(self, param_tb)
end

function DareTowerUI:Hide()
    self.go_to_tower_id = {}
    self.tower_id_to_go = {}
    for _, cmp in pairs(self.tower_id_to_talk_cmp) do
        cmp:DoDestroy()
    end
    self.tower_id_to_talk_cmp = {}
    for _, go in pairs(self.tower_id_to_treasure) do
        self:DelUIObject(go)
    end
    self.tower_id_to_treasure = {}

    for _, go_list in pairs(self.bg_to_ui_go_list) do
        for _, go in ipairs(go_list) do
            self:DelUIObject(go)
        end
    end
    self.bg_to_ui_go_list = {}
    DareTowerUI.super.Hide(self)
end

function DareTowerUI:_InitMainPanel()
    local dy_data_mgr = ComMgrs.dy_data_mgr
    local role_id = dy_data_mgr:ExGetRoleId()
    local role_data = SpecMgrs.data_mgr:GetRoleLookData(role_id)
    self:AssignSpriteByIconID(role_data.head_icon_id, self.main_role_icon_image)
    self.score_text.text = dy_data_mgr:ExGetBattleScore()
    self.main_role_level_text.text = string.format(UIConst.Text.LEVEL, dy_data_mgr:ExGetRoleLevel())
    local exp_percent = dy_data_mgr:ExGetRoleExpPercentage()
    self.exp_slider.value = exp_percent
    self.fight_time_text.text = string.format(UIConst.Text.FIGHT_TIME_EACH_DAY, self.dy_dare_tower_data:GetRemainFightTime())
end

function DareTowerUI:UpdateAllTreasureBox()
    for tower_id , go in pairs(self.tower_id_to_treasure) do
        UIFuncs.UpdateTreasureBoxStatus(go, self.dy_dare_tower_data:CheckTowerTreasureCanGet(tower_id))
    end
end

function DareTowerUI:ShowTowerPreviewPanel(tower_id)
    self.show_preview_tower_id = tower_id
    local tower_data = SpecMgrs.data_mgr:GetDareTowerData(tower_id)
    self.tpp_stage_name_text.text = tower_data.name
    self.tpp_action_cost_text.text = tower_data.consume_action_point
    local _, hero_data = MonsterUtil.GetMainMonsterData(tower_data.monster_group_id)
    self.tower_preview_talk_cmp = self:GetTalkCmp(self.tpp_boss_talk_parent, 1, false, function ()
        return UIFuncs.GetHeroTalk(hero_data.id)
    end, self.change_talk_time)

    self.tpp_boss_name_text.text = hero_data.name
    self.tpp_boss_unit = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = hero_data.unit_id, parent = self.tpp_boss_unit_parent})
    self.tpp_boss_unit:SetPositionByRectName({parent = self.tpp_boss_unit_parent, name = UnitConst.UnitRect.Half})
    self.tpp_suggest_score_text.text = UIFuncs.GetMonsterGroupScoreSuggestStr(tower_data.monster_group_id)
    local sort_item_data_list = ItemUtil.GetSortedDropItemDataList(tower_data.general_reward)
    local award_go
    for _, item_data_dict in ipairs(sort_item_data_list) do
        local param_tb = {parent = self.tpp_award_go_parent,
            item_data = item_data_dict.item_data,
            count = item_data_dict.count,
            ui = self
        }
        award_go = UIFuncs.GetInitItemGoByTb(param_tb)
        table.insert(self.tpp_award_go_list, award_go)
    end
    local is_tower_fighted = self.dy_dare_tower_data:IsTowerFighted(tower_id)
    self.tpp_fight_btn:SetActive(not is_tower_fighted)
    self.tpp_alread_fight_go:SetActive(is_tower_fighted)
    local first_pass_award_item = tower_data.first_reward_item[1]
    local count = tower_data.first_reward_item_count[1]
    local icon_id = SpecMgrs.data_mgr:GetItemData(first_pass_award_item).icon
    self:AssignSpriteByIconID(icon_id, self.tpp_first_pass_award_item_image)
    self.tpp_first_pass_award_num_text.text = UIFuncs.AddCountUnit(count)
    self.tower_preview_panel:SetActive(true)
end

function DareTowerUI:GetFightTimeByActionPoint(tower_id)
    local tower_data = SpecMgrs.data_mgr:GetDareTowerData(tower_id)
    local can_fight_time = math.floor(self.dy_dare_tower_data:GetActionPoint() / tower_data.consume_action_point)
    return can_fight_time
end

function DareTowerUI:_GetRemainTime(tower_id)
    local tower_data, boss_stage_data = SpecMgrs.data_mgr:GetDareTowerData(tower_id)
    local cur_victory_num = boss_stage_data and boss_stage_data.victory_num or 0
    local remain_time = tower_data.victory_num - cur_victory_num
    return remain_time
end

function DareTowerUI:HideTowerPreviewPanel()
    self.show_preview_tower_id = nil
    for _, go in ipairs(self.tpp_award_go_list) do
        self:DelUIObject(go)
    end
    self.tpp_award_go_list = {}

    if self.tpp_boss_unit then
        ComMgrs.unit_mgr:DestroyUnit(self.tpp_boss_unit)
        self.tpp_boss_unit = nil
    end
    self:RemovePreviewTalk()
    self.tower_preview_panel:SetActive(false)
end

function DareTowerUI:RemovePreviewTalk()
    if self.tower_preview_talk_cmp then
        self.tower_preview_talk_cmp:DoDestroy()
        self.tower_preview_talk_cmp = nil
    end
end
-- sweep_panel end
function DareTowerUI:CheckStageCastAction(tower_id)
    local cast_active_point = SpecMgrs.data_mgr:GetDareTowerData(tower_id).consume_action_point
    if not UIFuncs.CheckItemCount(CSConst.CostValueItem.ActionPoint, cast_active_point, true) then
        return
    end
    return true
end

function DareTowerUI:FightBtnOnClick(tower_id)
    local tower_id  = self.show_preview_tower_id
    if not tower_id then return end
    if not ComMgrs.dy_data_mgr.night_club_data:CheckHeroLineup(true) then return end
    if not self:CheckStageCastAction(tower_id) then
        return
    end
    if not self.dy_dare_tower_data:CheckRemainFightTime(true) then return end
    local tower_id = self.show_preview_tower_id
    self:HideTowerPreviewPanel()
    SpecMgrs.msg_mgr:SendMsg("SendDareTowerFight", {tower_id = tower_id}, function (resp)
        if resp.errcode ~= 0 then
            PrintError("Get wrong errcode from serv in SendDareTowerFight", tower_id)
        else
            local item_dict = ItemUtil.RoleItemListToItemDict(resp.item_list)
            SpecMgrs.ui_mgr:EnterHeroBattle(resp.fight_data, UIConst.BattleScence.DareTowerUI)
            SpecMgrs.ui_mgr:RegiseHeroBattleEnd("DareTowerUI", function()
                local param_tb = {
                    is_win = resp.is_win,
                    show_level = true,
                    reward = item_dict,
                }
                SpecMgrs.ui_mgr:AddCloseBattlePopUpList("BattleResultUI", param_tb)
            end)
        end
    end)
end

function DareTowerUI:TreasureBoxOnClick(tower_id)
    local is_can_pick = self:CheckTowerTreasureCanGet(tower_id)
    local treasure_status = UIFuncs.TransRewardState(is_can_pick)
    local reward_id = SpecMgrs.data_mgr:GetDareTowerData(tower_id).treasure_chest_reward
    UIFuncs.ShowTreasurePreview(reward_id, treasure_status, function ()
        self:SendDareTowerTreasureReward(tower_id, reward_id)
    end)
end

function DareTowerUI:SendDareTowerTreasureReward(tower_id, reward_id)
    SpecMgrs.msg_mgr:SendDareTowerTreasureReward({tower_id = tower_id}, function(resp)
        if resp.errcode ~= 0 then
            PrintError("Get wrong errcode in SendDareTowerTreasureReward tower_id", tower_id)
            return
        end
        UIFuncs.PlayOpenBoxAnim(self.tower_id_to_treasure[tower_id])
        local item_list = ItemUtil.GetSortedRewardItemList(reward_id)
        SpecMgrs.ui_mgr:ShowUI("GetItemUI", item_list)
    end)
end

function DareTowerUI:CheckTowerTreasureCanGet(tower_id)
    return self.dy_dare_tower_data:CheckTowerTreasureCanGet(tower_id)
end

function DareTowerUI:GetFirstStageidByRealIndex(real_index)
    return self:GetSteagIdByIndex(real_index, 1)
end

function DareTowerUI:UpdateBg(real_index, bg_trans)
    local first_tower_id = self:GetFirstStageidByRealIndex(real_index)
    local bg_build_num, bg_index = self:GetBgBuildNumByRealIndex(real_index)
    if first_tower_id <= 0 then return end
    if not self.bg_to_ui_go_list[bg_index] then
        self.bg_to_ui_go_list[bg_index] = {}
        for i = 1, bg_build_num do
            local tower_id = first_tower_id + i - 1
            local tower_go = self.bg_to_build_list[bg_index][i]   --bg_trans.gameObject:FindChild("BuildList/" .. i)
            local go = self:GetUIObject(self.ui_temp, tower_go:FindChild("UIParent"))
            go.name = "StageName"
            table.insert(self.bg_to_ui_go_list[bg_index], go)
            self:ChangeTowerGo(tower_go, tower_id)
        end
    else
        for i = 1, bg_build_num do
            local tower_id = first_tower_id + i - 1
            local tower_go = self.bg_to_build_list[bg_index][i]
            self:ChangeTowerGo(tower_go, tower_id)
        end
    end
end

function DareTowerUI:GetBgBuildNumByRealIndex(real_index)
    local index = self:ChangeRealIndex(real_index)
    local bg_index = index % kDefaultBgNum
    bg_index = bg_index == 0 and kDefaultBgNum or bg_index
    return self.bg_to_build_num[bg_index], bg_index
end

function DareTowerUI:ChangeTowerGo(go, tower_id)
    local old_tower_id = self.go_to_tower_id[go]
    if old_tower_id then
        self:RemoveTalkCmp(old_tower_id)
        self.tower_id_to_go[old_tower_id] = nil
        if self.tower_id_to_treasure[old_tower_id] then
            self:DelUIObject(self.tower_id_to_treasure[old_tower_id])
            self.tower_id_to_treasure[old_tower_id] = nil
        end
    end
    self.go_to_tower_id[go] = tower_id
    self.tower_id_to_go[tower_id] = go
    local tower_data = SpecMgrs.data_mgr:GetDareTowerData(tower_id)
    local build_go = go:FindChild("Build")
    local stage_name_go = go:FindChild("UIParent/StageName")
    local icon_go = stage_name_go:FindChild("Icon")
    local treasure_box_parent = stage_name_go:FindChild("TreasureBoxParent")
    if tower_data then
        local _, monster_data, monster_unit_data = MonsterUtil.GetMainMonsterData(tower_data.monster_group_id, tower_data.main_monster_index)
        self:AssignSpriteByIconID(monster_unit_data.icon, icon_go:FindChild("Image/Boss"):GetComponent("Image"))
        self:AssignSpriteByIconID(monster_unit_data.icon, icon_go:FindChild("Lock/Icon"):GetComponent("Image"))
        icon_go:SetActive(true)
        self:UpdateTower(tower_id)
        if tower_data.treasure_chest_reward then
            local treasure_box_id = tower_data.treasure_box_id
            local treasure_box = UIFuncs.GetTreasureBox(self, treasure_box_parent, treasure_box_id)
            self:AddClick(treasure_box, function()
                self:TreasureBoxOnClick(tower_id)
            end)
            self.tower_id_to_treasure[tower_id] = treasure_box
        end
        self:RemoveClick(icon_go)
        self:AddClick(icon_go, function ()
            self:TowerOnClick(tower_id)
        end)
        self:RemoveClick(build_go)
        self:AddClick(build_go, function ()
            self:TowerOnClick(tower_id)
        end)
    else -- 最上面关卡 没有数据
        icon_go:SetActive(false)
        stage_name_go:FindChild("Text"):GetComponent("Text").text = UIConst.Text.COMMING_SOON
        self:RemoveClick(build_go)
        self:RemoveClick(icon_go)
    end
end

function DareTowerUI:UpdateTower(tower_id)
    local go = self.tower_id_to_go[tower_id]
    if not go then return end
    local dy_data = self.dy_dare_tower_data
    local is_cur_tower = dy_data:IsCurTower(tower_id)
    local is_tower_unlock = dy_data:IsTowerUnlcok(tower_id)
    local is_tower_fighted = dy_data:IsTowerFighted(tower_id)
    go:FindChild("UIParent/StageName/Icon/AtWar"):SetActive(is_cur_tower)
    if is_cur_tower then
        local tower_data = SpecMgrs.data_mgr:GetDareTowerData(tower_id)
        local _, hero_data = MonsterUtil.GetMainMonsterData(tower_data.monster_group_id)
        local is_right = go:GetComponent("RectTransform").anchoredPosition.x < 0 and true or false
        local talk_parent = go:FindChild("UIParent/StageName/Icon/TalkParent")
        local rect = talk_parent:GetComponent("RectTransform")
        local pos = rect.anchoredPosition
        local x = is_right and math.abs(pos.x) or -math.abs(pos.x)
        rect.anchoredPosition = Vector2.New(x, pos.y)
        if not self.tower_id_to_talk_cmp[tower_id] then
            self.tower_id_to_talk_cmp[tower_id] = self:GetTalkCmp(talk_parent, 1, not is_right, function ()
                return UIFuncs.GetHeroTalk(hero_data.id)
            end, self.change_talk_time)
        end
    else
        self:RemoveTalkCmp(tower_id)
    end
    go:FindChild("UIParent/StageName/Icon/Lock"):SetActive(not is_tower_unlock)
    go:FindChild("UIParent/StageName/Icon/AlreadyFighted"):SetActive(is_tower_unlock and is_tower_fighted)
    local tower_data = SpecMgrs.data_mgr:GetDareTowerData(tower_id)
    go:FindChild("UIParent/StageName/Text"):GetComponent("Text").text = is_tower_fighted and UIConst.Text.ALREADY_PLUNDER_GREEN or tower_data.name
end

function DareTowerUI:RemoveTalkCmp(tower_id)
    if self.tower_id_to_talk_cmp[tower_id] then
        self.tower_id_to_talk_cmp[tower_id]:DoDestroy()
        self.tower_id_to_talk_cmp[tower_id] = nil
    end
end

-- 传进来real_index 是从最大关卡bg到最小关卡bg index
function DareTowerUI:GetSteagIdByIndex(real_index, tower_index)
    local index = self:ChangeRealIndex(real_index)
    local the_index_before = index - 1
    local count
    if the_index_before ~= 0 then
        count = math.floor(the_index_before / kDefaultBgNum)
    else
        count = 0
    end
    local ret = count * self.all_bg_build_num
    local remainder = the_index_before % kDefaultBgNum
    local bg_index
    for bg_index = 1, remainder do
        ret = ret + self.bg_to_build_num[bg_index]
    end
    ret = ret + tower_index
    return ret
end

function DareTowerUI:ChangeRealIndex(real_index)
    return self.bg_amount + 1 - real_index
end

function DareTowerUI:GetBgIndexByRealIndex(real_index)
    local index = self:ChangeRealIndex(real_index)
    index = index % kDefaultBgNum
    return kDefaultBgNum + 1 - index
end

function DareTowerUI:TowerOnClick(tower_id)
    if self.dy_dare_tower_data:IsTowerUnlcok(tower_id) then
        self:ShowTowerPreviewPanel(tower_id)
    else
        local last_tower_data = SpecMgrs.data_mgr:GetDareTowerData(tower_id - 1)
        local str = string.format(UIConst.Text.UNLOCK_STAGE, last_tower_data.name)
        SpecMgrs.ui_mgr:ShowTipMsg(str)
    end
end

function DareTowerUI:UpdateScrollRectLimitUpPos()
    local limit_up_pos
    local cur_tower = self.dy_dare_tower_data:GetMaxTower()
    local go = self.tower_id_to_go[cur_tower]
    if not go then
        self.limit_up_pos = nil
        return
    end
    local scroll_rect = self.tower_content_transform
    local view_rect = self.tower_view_rect_transform
    local pos = scroll_rect:InverseTransformPoint(go.position)
    local y_offset = - (pos.y + kDefultOffset)
    local can_move_dis = scroll_rect.rect.height - view_rect.rect.height
    local move_limit = can_move_dis - y_offset
    if move_limit < 0 then
        limit_up_pos  = 0
    else
        limit_up_pos =  math.clamp(move_limit / can_move_dis, 0, 1)
    end
    self.limit_up_pos = limit_up_pos
end

function DareTowerUI:ChangeChildSiblingAndPos()
    for index, go in ipairs(self.bg_list) do
        go:SetSiblingIndex(index)
    end
    local remainder = self.bg_amount % kDefaultBgNum
    for index = 1, kDefaultBgNum do
        local change_index = index + remainder
        if change_index > kDefaultBgNum then
            change_index = change_index % kDefaultBgNum
        end
        self.bg_list[change_index]:SetAsFirstSibling()
        self.bg_list[change_index]:GetComponent("RectTransform").anchoredPosition = self.bg_pos_list[index]
    end
end

return DareTowerUI
