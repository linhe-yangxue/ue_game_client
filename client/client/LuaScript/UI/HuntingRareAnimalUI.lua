local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local UnitConst = require("Unit.UnitConst")
local EffectConst = require("Effect.EffectConst")
local ItemUtil = require("BaseUtilities.ItemUtil")
local SoundConst = require("Sound.SoundConst")
local HuntingRareAnimalUI = class("UI.HuntingRareAnimalUI",UIBase)
HuntingRareAnimalUI.need_sync_load = true

local kDefaultBgNum = 2

local panel_key_map = {
    initial_panel = "HuntingRareAnimalInitialPanel",
    award_panel = "RareAnimalAwardPanel",
    hunting_panel = "HuntingRareAnimalPanel",
    ranking_panel = "HuntingRareAnimalRankingPanel",
    hunting_success_panel = "HuntingRareAnimalSuccessPanel",
}

local panel_hide_func_map ={
    HuntingRareAnimalInitialPanel = "Hide",
    RareAnimalAwardPanel = "HideRareAnimalAwardPanel",
    HuntingRareAnimalPanel = "HideHuntingRareAnimalPanel",
    HuntingRareAnimalRankingPanel = "HideHuntingRareAnimalRankingPanel",
    HuntingRareAnimalSuccessPanel = "HideHuntingRareAnimalSuccessPanel",
}

local kRankSpecialShow = 3 -- 排行榜排名<3显示不同排名背景
local kCoolDownUpdateTime = 1
local kAwardRankPlies = 4 -- 排名奖励有4档
local kPercent = 100
local kShootAnimTime = 0.8
local kShootSoundTime = 0.4
local kLoadBulletTime = 1.8
local kPanelAutoCloseTime = 3
local kRandomEffectRange = 100

function HuntingRareAnimalUI:DoInit()
    HuntingRareAnimalUI.super.DoInit(self)
    self.prefab_path = "UI/Common/HuntingRareAnimalUI"
    self.spec_rank_icon_list = SpecMgrs.data_mgr:GetParamData("rank_icon_list").icon_list
    self.bgm_sound = SpecMgrs.data_mgr:GetSoundId("hunt_bgm")
    self.dy_hunting_data = ComMgrs.dy_data_mgr.hunting_data
    self.dy_hero_data  = ComMgrs.dy_data_mgr.night_club_data
    self.rare_animal_data_list = SpecMgrs.data_mgr:GetAllRareAnimalData()
    self.max_hunt_rare_animal_num = self.dy_hunting_data:GetMaxHuntRareAnimalNum()
    self.max_shoot_cool_time = CSConst.Hunt.Cooldown
    self.update_cool_timer = 0
    self.loading_bullet_cool_timer = 0
    self.max_loading_bullet_cool_time = CSConst.Hunt.Cooldown
    self.gray_material = SpecMgrs.res_mgr:GetMaterialSync(UIConst.MaterialResPath.UIGray)
    self.inspire_add_rate = SpecMgrs.data_mgr:GetParamData("rare_animal_inspire_add_rate").f_value
    self.hunting_rare_animal_effect_time = SpecMgrs.data_mgr:GetParamData("hunting_rare_animal_effect_time").f_value
    self.active_panel_cache = {}
    self.update_func_dict = {
        [panel_key_map.initial_panel] = function () self:_UpdateInitialPanel() end,
        [panel_key_map.hunting_panel] = function () self:_UpdateHuntingPanel() end,
        [panel_key_map.ranking_panel] = function () self:_UpdateRankingPanel() end,
    }
    self.update_time_dict = { -- 刷新时间
        [panel_key_map.initial_panel] = 1,
        [panel_key_map.hunting_panel] = 1,
        [panel_key_map.ranking_panel] = 5,
    }
    self.inspire_num = 0
end

function HuntingRareAnimalUI:OnGoLoadedOk(res_go)
    HuntingRareAnimalUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function HuntingRareAnimalUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    HuntingRareAnimalUI.super.Show(self)
end

function HuntingRareAnimalUI:InitRes()
    local panel_list = self.main_panel:FindChild("PanelList")
    for k, panel_name in pairs(panel_key_map) do
        local panel = panel_list:FindChild(panel_name)
        self[k] = panel
        self:_InitCloseClickFunc(panel, panel_name)
        local top_bar = panel:FindChild("TopBar")
        if top_bar then
            UIFuncs.InitTopBar(self, top_bar, panel_name, function ()
                self:GetHidePanelFunc(panel_name)(self)
            end)
        end
    end
    --initial_panel 以下 ip
    self:AddClick(self.initial_panel:FindChild("TopBar1/ChallengeCount/Button"), function ()
        self:AddHuntingRareAnimalNumBtnOnClick()
    end)
    self.ip_vip_btn = self.initial_panel:FindChild("TopBar1/VipBtn")
    self.ip_vip_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.VIP_PRIVILEGE
    self:AddClick(self.ip_vip_btn, function ()
        --todo 显示vip特权面板
    end)
    self.ip_challenge_count_text = self.initial_panel:FindChild("TopBar1/ChallengeCount/Text"):GetComponent("Text")
    self.ip_challenge_cool_down_text = self.initial_panel:FindChild("TopBar1/ChallengeCount/CoolDown"):GetComponent("Text")

    local ip_item_parent = self.initial_panel:FindChild("Scroll View/Viewport/Content")
    local ip_item_temp = ip_item_parent:FindChild("Item")
    ip_item_temp:FindChild("ShowTime/Text"):GetComponent("Text").text = UIConst.Text.RARE_ANIMAL_SHOW
    ip_item_temp:FindChild("Animal/ParticipantCount"):GetComponent("Text").text = UIConst.Text.JOIN_NUM
    ip_item_temp:FindChild("Animal/Level"):GetComponent("Text").text = UIConst.Text.LEVEL_WITH_COLON
    ip_item_temp:FindChild("Animal/Toggle/Label"):GetComponent("Text").text = UIConst.Text.MONITOR
    ip_item_temp:FindChild("AwardBtn/Text"):GetComponent("Text").text = UIConst.Text.KILL_AWARD
    ip_item_temp:FindChild("StartHuntBtn/Text"):GetComponent("Text").text = UIConst.Text.START_HUNT
    ip_item_temp:FindChild("ContinueHuntBtn/Text"):GetComponent("Text").text = UIConst.Text.CONTINUE_HUNT
    ip_item_temp:SetActive(false)
    local toggle_group = ip_item_parent:GetComponent("ToggleGroup")
    self.ip_item_comp_list = {}
    for i = 1, #self.rare_animal_data_list do
        table.insert(self.ip_item_comp_list,{})
    end
    for i = 1, #self.rare_animal_data_list do
        local rare_animal_data = self.rare_animal_data_list[i]
        local item = self:GetUIObject(ip_item_temp, ip_item_parent)
        item:FindChild("Animal/Name"):GetComponent("Text").text = rare_animal_data.name
        item:FindChild("Animal/Level/Text"):GetComponent("Text").text = rare_animal_data.open_level--string.format(UIConst.Text.LEVEL, rare_animal_data.open_level)
        local unlock_description_text = item:FindChild("BlackBg/UnlockLevel"):GetComponent("Text")
        unlock_description_text.text = string.format(UIConst.Text.HUNTING_UNLOCK_LEVEL, rare_animal_data.open_level)
        self.ip_item_comp_list[i].unlock_description_text = unlock_description_text
        local animal_image = item:FindChild("Animal"):GetComponent("Image")
        self.ip_item_comp_list[i].animal_image = animal_image
        local icon_id = SpecMgrs.data_mgr:GetUnitData(rare_animal_data.unit_id).icon
        self:AssignSpriteByIconID(icon_id, animal_image)
        self.ip_item_comp_list[i].hp_slider = item:FindChild("Animal/Hp"):GetComponent("Slider")
        self.ip_item_comp_list[i].hp_text = item:FindChild("Animal/Hp/Fill Area/HpPercent"):GetComponent("Text")
        self.ip_item_comp_list[i].hp_image = item:FindChild("Animal/Hp/Fill Area/Fill"):GetComponent("Image")
        self.ip_item_comp_list[i].animal_image = item:FindChild("Animal"):GetComponent("Image")
        self.ip_item_comp_list[i].player_num_text = item:FindChild("Animal/ParticipantCount/Text"):GetComponent("Text")
        self.ip_item_comp_list[i].cool_down_text = item:FindChild("ShowTime"):GetComponent("Text")
        self.ip_item_comp_list[i].black_bg = item:FindChild("BlackBg")
        local toggle = item:FindChild("Animal/Toggle"):GetComponent("Toggle")
        toggle.isOn = false
        toggle.group = toggle_group
        self.ip_item_comp_list[i].listen_toggle = toggle
        self:AddClick(item:FindChild("AwardBtn"), function ()
            self:ShowRareAnimalAwardPanel(i)
        end)
        local start_hunt_btn = item:FindChild("StartHuntBtn")
        self.ip_item_comp_list[i].start_hunt_btn = start_hunt_btn
        self:AddClick(start_hunt_btn, function ()
            self:StartHuntBtnOnClick(i)
        end)
        local continue_hunt_btn = item:FindChild("ContinueHuntBtn")
        self.ip_item_comp_list[i].continue_hunt_btn = continue_hunt_btn
        self:AddClick(continue_hunt_btn, function ()
            self:StartHuntBtnOnClick(i)
        end)
    end

    local listen_animal_id = self.dy_hunting_data:GetListenAnimal()
    if listen_animal_id then
        self.ip_item_comp_list[listen_animal_id].listen_toggle.isOn = true
    end
    for i = 1, #self.rare_animal_data_list do
        self:AddToggle(self.ip_item_comp_list[i].listen_toggle.gameObject, function ()
            local animal_id = self.ip_item_comp_list[i].listen_toggle.isOn and i or nil
            SpecMgrs.msg_mgr:SendMsg("SendListenRareAnimal",{animal_id = animal_id}, function (resp)
            end)
        end)
    end

    --award_panel 以下简称ap
    self.ap_name_text = self.award_panel:FindChild("Content/Content/TopBar2/Name"):GetComponent("Text")
    self.ap_ground_text = self.award_panel:FindChild("Content/Content/TopBar2/Ground"):GetComponent("Text")
    self.award_panel:FindChild("Content/Top/Text"):GetComponent("Text").text = UIConst.Text.KILL_AWARD
    self.award_panel:FindChild("Content/Content/TopBar1/Text"):GetComponent("Text").text = UIConst.Text.KILL_WILL_GET_MORE_AWARD
    self.ap_award_item_list = {}
    self.ap_award_item_parent_list = {}
    self.ap_award_item_temp_list = {}
    local ap_award_parent = self.award_panel:FindChild("Content/Content/Scroll View/Viewport/Content")
    for i = 1, kAwardRankPlies do
        local go = ap_award_parent:FindChild(i)
        go:FindChild("Top/Text"):GetComponent("Text").text = UIConst.Text.AWARD_TITLE_LIST[i]
        go:FindChild("GetRate/Text"):GetComponent("Text").text = UIConst.Text.GET_RANDOM_AWARD_RATE_LIST[i]
        local item_parent = go:FindChild("AwardItemList")
        local item_temp = item_parent:FindChild("Item")
        UIFuncs.GetIconGo(self, item_temp)
        item_temp:SetActive(false)
        self.ap_award_item_parent_list[i] = item_parent
        self.ap_award_item_temp_list[i] = item_temp
    end

    --hunting_panel 一下简称hp
    self.hp_animal_unit_parent = self.hunting_panel:FindChild("MiddlePart/Animal/UnitParent")
    self.hp_animal_hit_effect_parent = self.hunting_panel:FindChild("MiddlePart/Animal/HitEffectParent")
    self.hp_aim_point_cs = self.hunting_panel:FindChild("MiddlePart/Animal/AimPoint"):GetComponent("AimPoint")
    local bottom_part = self.hunting_panel:FindChild("MiddlePart/Bottom")
    self.hp_load_bullet_hint = bottom_part:FindChild("Loading")
    self.hp_auto_shot_toogle = bottom_part:FindChild("AutoShot/Toggle"):GetComponent("Toggle")

    self.is_auto_shoot = false
    self.hp_auto_shot_toogle.isOn = self.is_auto_shoot
    self.hp_aim_point_cs.is_auto_shoot = self.is_auto_shoot
    self.hp_aim_point_cs.max_shoot_cool_time = self.max_shoot_cool_time

    self:AddToggle(self.hp_auto_shot_toogle.gameObject,function ()
        self.is_auto_shoot = self.hp_auto_shot_toogle.isOn
        self.hp_aim_point_cs.is_auto_shoot = self.is_auto_shoot
    end)
     self:AddClick(bottom_part:FindChild("ShootBtn"), function ()
        self:ShootBtnOnClick()
    end, SoundConst.SoundID.SID_NotPlaySound)
    self.hp_animal_hp_slider = self.hunting_panel:FindChild("MiddlePart/Animal/Hp"):GetComponent("Slider")
    self.hp_animal_hp_text = self.hunting_panel:FindChild("MiddlePart/Animal/Hp/Fill Area/Text"):GetComponent("Text")
    self.hp_animal_name_text = self.hunting_panel:FindChild("MiddlePart/Animal/Name"):GetComponent("Text")
    self.hp_hud_parent = self.hunting_panel:FindChild("MiddlePart/Animal/HudParent")
    self.hp_hero_score_sum_text = self.hunting_panel:FindChild("MiddlePart/FightScore/Text"):GetComponent("Text")
    self.hp_inspire_text = self.hunting_panel:FindChild("MiddlePart/CheerBtn/AddPercent"):GetComponent("Text")
    self.hp_cheer_btn =  self.hunting_panel:FindChild("MiddlePart/CheerBtn")
    self.hp_cheer_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.INSPIRE
    self:AddClick(self.hp_cheer_btn, function ()
        self:CheerBtnOnClick()
    end)

    self.hp_rank_name_text_list = {}
    self.hp_rank_text_list = {}
    local rank_parent = self.hunting_panel:FindChild("RankBtn/Middle")
    for i = 1, kRankSpecialShow do
        self.hp_rank_name_text_list[i] = rank_parent:FindChild(i):GetComponent("Text")
        self.hp_rank_text_list[i] = rank_parent:FindChild(i .. "/Rank"):GetComponent("Text")
    end
    self.hunting_panel:FindChild("RankBtn/MyRank"):GetComponent("Text").text = ComMgrs.dy_data_mgr:ExGetMainRoleInfoData().name
    self.hp_my_rank_text = self.hunting_panel:FindChild("RankBtn/MyRank/Rank"):GetComponent("Text")
    self:AddClick(self.hunting_panel:FindChild("RankBtn"), function ()
        self:ShowHuntingRareAnimalRankingPanel()
    end)
    self.hunting_panel:FindChild("MiddlePart/FightScore/Title"):GetComponent("Text").text = UIConst.Text.ACCOMPANY_HERO_SCORE
    self.hunting_panel:FindChild("MiddlePart/Bottom/Loading"):GetComponent("Text").text = UIConst.Text.LOADING_BULLET_TEXT
    self.hunting_panel:FindChild("MiddlePart/Bottom/AutoShot/Toggle/Label"):GetComponent("Text").text = UIConst.Text.AUTO_SHOOT
    self.hunting_panel:FindChild("MiddlePart/Bottom/AutoShot/Toggle/Text"):GetComponent("Text").text = UIConst.Text.AUTO_SHOOT_MUST_HIT_TARGET

    self.far_hunt_bg_image_list = {}
    self.close_hunt_bg_image_list = {}
    local far_bg_parent = self.hunting_panel:FindChild("MiddlePart/ScrollFarBg")
    local close_bg_parent = self.hunting_panel:FindChild("MiddlePart/ScrollCloseBg")
    local bg_name
    for i = 1, kDefaultBgNum do
        bg_name = "Bg" .. i
        table.insert(self.far_hunt_bg_image_list, far_bg_parent:FindChild(bg_name):GetComponent("Image"))
        table.insert(self.close_hunt_bg_image_list, close_bg_parent:FindChild(bg_name):GetComponent("Image"))
    end
    --ranking_panel 以下简称rp
    self.rp_item_list = {}

    self.ranking_panel:FindChild("PanelList/RankPanelTemp/Title/Rank/Text"):GetComponent("Text").text = UIConst.Text.PLAYER_TEXT
    self.ranking_panel:FindChild("PanelList/RankPanelTemp/Title/Player/Text"):GetComponent("Text").text = UIConst.Text.RANK
    self.ranking_panel:FindChild("PanelList/RankPanelTemp/BottonBar/MyRank"):GetComponent("Text").text = UIConst.Text.MY_RANK
    self.ranking_panel:FindChild("PanelList/RankPanelTemp/NoOneOnRank"):GetComponent("Text").text = UIConst.Text.NO_ONE_ON_RANK
    self.ranking_panel:FindChild("PanelList/RankPanelTemp/BottonBar/MyPoint"):GetComponent("Text").text = string.format(UIConst.Text.COLON, UIConst.Text.HURT_TEXT)
    self.ranking_panel:FindChild("PanelList/RankPanelTemp/Title/Score/Text"):GetComponent("Text").text = UIConst.Text.HURT_TEXT
    self.rp_my_rank_text = self.ranking_panel:FindChild("PanelList/RankPanelTemp/BottonBar/MyRank/Text"):GetComponent("Text")
    self.rp_my_hurt_text = self.ranking_panel:FindChild("PanelList/RankPanelTemp/BottonBar/MyPoint/Text"):GetComponent("Text")
    self.rp_item_parent = self.ranking_panel:FindChild("PanelList/RankPanelTemp/Scroll View/Viewport/Content")
    self.rp_item_temp = self.rp_item_parent:FindChild("Item")
    self.rp_item_temp:SetActive(false)
    self.rp_no_one_on_rank = self.ranking_panel:FindChild("PanelList/RankPanelTemp/NoOneOnRank")

    --hunting_success_panel 以下简称hsp
    self.hsp_item_list = {}
    self.hsp_item_parent = self.hunting_success_panel:FindChild("Award")
    self.hsp_item_temp = self.hsp_item_parent:FindChild("Item")
    UIFuncs.GetIconGo(self, self.hsp_item_temp)
    self.hsp_item_temp:SetActive(false)
    self.hsp_rank_text = self.hunting_success_panel:FindChild("Award/Top"):GetComponent("Text")
end

function HuntingRareAnimalUI:_InitCloseClickFunc(panel, panel_name)
    local close_bg = panel:FindChild("CloseBg")
    local close_btn = panel:FindChild("Content/Top/CloseBtn")
    local close_go = close_bg or close_btn
    if not close_go then return end
    self:AddClick(close_go, function ()
        self:GetHidePanelFunc(panel_name)(self)
    end)
end

function HuntingRareAnimalUI:InitUI()
    self:RegisterEvent(self.dy_hunting_data, "UpdateHuntingRareAnimalNum", function ()
        self:UpdateChallengeCount()
    end)
    self:RegisterEvent(self.dy_hunting_data, "UpdateRareAnimalData", function (_, serv_rare_animal_data_list)
        for animal_id = 1 , #self.rare_animal_data_list do
            self:_UpdateRareAnimalItem(animal_id, serv_rare_animal_data_list[animal_id])
        end
    end)
    self:RegisterEvent(ComMgrs.dy_data_mgr, "UpdateCurrencyEvent", function (_, currency)
        UIFuncs.UpdateCurrencyItemNum(self._item_to_text_list, currency)
    end)
    self:RegisterEvent(ComMgrs.dy_data_mgr.bag_data, "UpdateBagItemEvent", function (_, op, item_data)
        UIFuncs.UpdateBagItemNum(self._item_to_text_list, item_data)
    end)
    self:UpdateChallengeCount()
    self:_InsertActivePanel(panel_key_map.initial_panel)
end

function HuntingRareAnimalUI:Hide()
    self:_RemoveActivePanel()
    self.is_animal_hunt_start = {}
    self.is_animal_unlock = {}
    self.is_animal_living = {}
    HuntingRareAnimalUI.super.Hide(self)
end

function HuntingRareAnimalUI:Update(delta_time)
    if not self.update_func or not self.update_time then return end
    self.update_cool_timer = self.update_cool_timer + delta_time
    if self.update_cool_timer >= kCoolDownUpdateTime then
        self.update_func()
        self.update_cool_timer = self.update_cool_timer - kCoolDownUpdateTime
    end
end

function HuntingRareAnimalUI:_InsertActivePanel(panel_name)
    table.insert(self.active_panel_cache, panel_name)
    self:_ChangeUpdateFunc(panel_name)
end

function HuntingRareAnimalUI:_RemoveActivePanel()
    table.remove(self.active_panel_cache)
    local active_panel_name = self:_GetActivePanelName()
    self:_ChangeUpdateFunc(active_panel_name)
end

function HuntingRareAnimalUI:_ChangeUpdateFunc(panel_name)
    if panel_name then
        self.update_func = self.update_func_dict[panel_name]
        self.update_cool_timer = 0
        if self.update_func then
            self.update_func()
        end
        self.update_time = self.update_time_dict[panel_name]
    else
        self.update_func = nil
        self.update_time = nil
    end
end

function HuntingRareAnimalUI:_GetActivePanelName()
    return self.active_panel_cache[#self.active_panel_cache]
end

----Initial_panel
function HuntingRareAnimalUI:_UpdateInitialPanel()
    self.dy_hunting_data:UpdateAllRareAnimalData()
    if self.is_show_challenge_count_down then
        self:_UpdateChallengeCoolText()
    end
end

function HuntingRareAnimalUI:_UpdateRareAnimalItem(animal_id, serv_animal_data)
    local is_unlock = serv_animal_data ~= nil
    local is_animal_living = serv_animal_data and not serv_animal_data.revive_ts
    local is_animal_hunt_start = serv_animal_data and serv_animal_data.is_start or false -- 自己是否开始狩猎过该野兽
    local item_comp_list = self.ip_item_comp_list[animal_id]

    item_comp_list.black_bg:SetActive(not is_unlock)
    item_comp_list.unlock_description_text.gameObject:SetActive(not is_unlock)
    item_comp_list.listen_toggle.gameObject:SetActive(is_unlock)
    item_comp_list.start_hunt_btn:SetActive(is_unlock and is_animal_living and not is_animal_hunt_start)
    item_comp_list.continue_hunt_btn:SetActive(is_unlock and is_animal_living and is_animal_hunt_start)
    item_comp_list.hp_slider.gameObject:SetActive(is_unlock and is_animal_living)
    item_comp_list.cool_down_text.gameObject:SetActive(is_unlock and not is_animal_living)
    item_comp_list.player_num_text.gameObject:SetActive(is_unlock)
    if is_unlock then
        item_comp_list.player_num_text.text = serv_animal_data.join_num or 0
        item_comp_list.hp_text.text = string.format(UIConst.Text.PERCENT, math.ceil(serv_animal_data.animal_hp * kPercent))
        item_comp_list.hp_slider.value = serv_animal_data.animal_hp
        if not is_animal_living then
            local reamin_time = serv_animal_data.revive_ts - Time:GetServerTime()
            item_comp_list.cool_down_text.text = UIFuncs.GetCountDownDayStr(reamin_time)
            item_comp_list.animal_image.material = self.gray_material
        else
            item_comp_list.animal_image.material = nil
        end
    end
end

function HuntingRareAnimalUI:UpdateChallengeCount()
    local hunt_rare_animal_num = self.dy_hunting_data:GetHuntRareAnimalNum()
    self.ip_challenge_count_text.text = string.format(UIConst.Text.HUNTING_RARE_ANIMAL_NUM, hunt_rare_animal_num, self.max_hunt_rare_animal_num)
    if hunt_rare_animal_num < self.max_hunt_rare_animal_num then
        self.is_show_challenge_count_down = true
        self:_UpdateChallengeCoolText()
    else
        self.is_show_challenge_count_down = false
    end
    self.ip_challenge_cool_down_text.gameObject:SetActive(self.is_show_challenge_count_down)
end

function HuntingRareAnimalUI:_UpdateChallengeCoolText()
    local challenge_cool_time = self.dy_hunting_data:GetChallengeCoolDownTime()
    if challenge_cool_time then
        self.ip_challenge_cool_down_text.text = string.format(UIConst.Text.RECOVER_HUTING_RARE_ANIMAL_NUM, UIFuncs.TimeDelta2Str(challenge_cool_time))
    else
        self.is_show_challenge_count_down = false
        self.ip_challenge_cool_down_text.gameObject:SetActive(false)
    end
end

----Initial_panel end

function HuntingRareAnimalUI:GetHidePanelFunc(panel_name)
    return self[panel_hide_func_map[panel_name]]
end

----RareAnimalAwardPanel
function HuntingRareAnimalUI:ShowRareAnimalAwardPanel(animal_id)
    local animal_data = self.rare_animal_data_list[animal_id]
    for i = 1 ,kAwardRankPlies do
        local must_item_data = SpecMgrs.data_mgr:GetRewardData(animal_data.must_item[i])
        for k, item_id in ipairs(must_item_data.reward_item_list) do
            local must_get_item = self:GetUIObject(self.ap_award_item_temp_list[i], self.ap_award_item_parent_list[i])
            local param_tb = {go = must_get_item:FindChild("Item"), item_id = item_id, count = must_item_data.reward_num_list[k], ui = self}
            UIFuncs.InitItemGo(param_tb)
            must_get_item:FindChild("SurelyGet"):SetActive(true)
            table.insert(self.ap_award_item_list, must_get_item)
        end
        local drop_item_data_list = ItemUtil.GetSortedDropItemDataList(animal_data.drop_id[i])
        for _, item_data_dict in ipairs(drop_item_data_list) do
            local item = self:GetUIObject(self.ap_award_item_temp_list[i], self.ap_award_item_parent_list[i])
            local param_tb = {go = item:FindChild("Item"), item_data = item_data_dict.item_data, count = item_data_dict.count, ui = self}
            UIFuncs.InitItemGo(param_tb)
            item:FindChild("SurelyGet"):SetActive(false)
            table.insert(self.ap_award_item_list, item)
        end
    end
    self.ap_name_text.text = string.format(UIConst.Text.RARE_ANIMAL_NAME, animal_data.name)
    local ground_data = SpecMgrs.data_mgr:GetHuntGroundData(animal_data.ground_id)
    self.ap_ground_text.text = string.format(UIConst.Text.RARE_ANIMAL_GROUND, ground_data.name)
    self.award_panel:SetActive(true)
end

function HuntingRareAnimalUI:HideRareAnimalAwardPanel()
    for _, v in ipairs(self.ap_award_item_list) do
        self:DelUIObject(v)
    end
    self.ap_award_item_list = {}
    self.award_panel:SetActive(false)
end

----RareAnimalAwardPanel end

----HuntingRareAnimalPanel
function HuntingRareAnimalUI:ShowHuntingRareAnimalPanel(animal_id)
    self:PlayBGM(self.bgm_sound)
    self.animal_id = animal_id
    self:SwitchAutoShoot(false)
    local rare_aniam_data = self.rare_animal_data_list[animal_id]
    self:ChangeHuntingBg(rare_aniam_data)
    self.hp_hero_score_sum_text.text = self:GetScoreSum()
    local unit_id = rare_aniam_data.unit_id
    local unit_data = SpecMgrs.data_mgr:GetUnitData(unit_id)
    self:UpdateAnimalUnit(unit_id)
    self.hp_animal_name_text.text = unit_data.name
    self.dy_hunting_data:RegisterUpdateHuntingRareAnimalData("HuntingRareAnimalPanel", function (_, serv_animal_data)
        if self.inspire_num ~= serv_animal_data.inspire_num then
            self.inspire_num = serv_animal_data.inspire_num
            self.hp_inspire_text.text = string.format(UIConst.Text.CURRENT_INSPIRE, math.floor(self.inspire_num * self.inspire_add_rate * kPercent))
        end
        for i = 1, kRankSpecialShow do
            if serv_animal_data.hurt_rank and serv_animal_data.hurt_rank[i] then
                self.hp_rank_name_text_list[i].text = serv_animal_data.hurt_rank[i].role_name
                self.hp_rank_text_list[i].text = UIFuncs.AddCountUnit(serv_animal_data.hurt_rank[i].hurt)
            else
                self.hp_rank_name_text_list[i].text = nil
                self.hp_rank_text_list[i].text = nil
            end
        end
        if serv_animal_data.self_rank and serv_animal_data.hurt_rank[serv_animal_data.self_rank] then
            self.self_rank = serv_animal_data.self_rank
            self.hp_my_rank_text.text = UIFuncs.AddCountUnit(serv_animal_data.hurt_rank[serv_animal_data.self_rank].hurt)
        else
            self.hp_my_rank_text.text = UIConst.Text.NOT_ON_RANKING
        end
        self.hp_animal_hp_slider.value = serv_animal_data.animal_hp
        self.hp_animal_hp_text.text = string.format(UIConst.Text.PERCENT, math.ceil(serv_animal_data.animal_hp * 100))
    end)
    self.dy_hunting_data:RegisterShowRareAnimalKillAward("HuntingRareAnimalUI", function (_, msg)
        self:HideHuntingRareAnimalRankingPanel()
        self:ShowHuntingRareAnimalSuccessPanel(msg)
    end)
    self:AddSmallHitEffectTimer()
    self:ResetHunt()
    self:_InsertActivePanel(panel_key_map.hunting_panel)
    self.hunting_panel:SetActive(true)
end

function HuntingRareAnimalUI:ChangeHuntingBg(rare_aniam_data)
    local groud_data = SpecMgrs.data_mgr:GetHuntGroundData(rare_aniam_data.ground_id)
    for i = 1, kDefaultBgNum do
        self:AssignUISpriteSync(groud_data.close_bg_res_path, groud_data.close_bg_res_name, self.close_hunt_bg_image_list[i])
        self:AssignUISpriteSync(groud_data.far_bg_res_path, groud_data.far_bg_res_name, self.far_hunt_bg_image_list[i])
    end
end

function HuntingRareAnimalUI:UpdateAnimalUnit(unit_id)
    self:CleanAnimalUnit()
    self.hp_animal_unit = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = unit_id, parent = self.hp_animal_unit_parent, need_sync_load = true})
end

function HuntingRareAnimalUI:CleanAnimalUnit()
    if self.hp_animal_unit then
        ComMgrs.unit_mgr:DestroyUnit(self.hp_animal_unit)
        self.hp_animal_unit = nil
    end
end

function HuntingRareAnimalUI:HideHuntingRareAnimalPanel()
    self:RemoveBGM()
    self.animal_id = nil
    self.inspire_num = nil
    self.self_rank = nil
    self.dy_hunting_data:UnregisterUpdateHuntingRareAnimalData("HuntingRareAnimalPanel")
    self.dy_hunting_data:UnregisterShowRareAnimalKillAward("HuntingRareAnimalUI")
    self:RemoveSmallHitEffectTimer()
    self:RemoveShowHuntResultTimer()
    self:CleanAnimalUnit()
    self:_RemoveActivePanel()
    self.hunting_panel:SetActive(false)
end

function HuntingRareAnimalUI:ResetHunt()
    self.hp_aim_point_cs:Reset()
    self.hp_animal_unit:PlayAnim("run", true)
end

function HuntingRareAnimalUI:GetScoreSum()
    return self.dy_hero_data:GetHeroScoreSum() --todo 策划说可能要改
end

function HuntingRareAnimalUI:_UpdateHuntingPanel()
    if self.animal_id then
        self.dy_hunting_data:UpdateHuntingRareAnimalData(self.animal_id)
    end
end

function HuntingRareAnimalUI:ShootBtnOnClick()
    local animal_id = self.animal_id
    if not animal_id then return end
    local shoot_ret = self.hp_aim_point_cs:Shoot()
    if shoot_ret == CSConst.ShootResult.Reload then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.LOADING_BULLET)
    else
        SpecMgrs.msg_mgr:SendMsg("SendHuntRareAnimal", {animal_id = animal_id, shoot_result = shoot_ret}, function (resp)
            local hurt_type
            local is_show_hit_effect
            if shoot_ret == CSConst.ShootResult.Miss then
                hurt_type = UnitConst.UNITHUD_TYPE.Miss
            elseif shoot_ret == CSConst.ShootResult.Hit then
                hurt_type = UnitConst.UNITHUD_TYPE.Hurt
                is_show_hit_effect = true
            elseif shoot_ret == CSConst.ShootResult.Crit then
                hurt_type = UnitConst.UNITHUD_TYPE.HurtCritical
                is_show_hit_effect = true
            end
            self:AddTimer(function ()
                if not self.is_res_ok then return end
                self:PlayUISoundByName("shoot_sound")
            end, kShootSoundTime, 1)
            self:AddTimer(function ()
                if not self.is_res_ok then return end
                self:PlayUISoundByName("load_bullet_sound")
            end, kLoadBulletTime)
            self:DelayShowHuntResult(hurt_type, resp.hurt, is_show_hit_effect)
        end)
    end
end

 -- 等待开枪动画结束
function HuntingRareAnimalUI:DelayShowHuntResult(hurt_type, hurt, is_show_hit_effect)
    if self.animal_hit_effect_timer then return end
    self.animal_hit_effect_timer = self:AddTimer(function()
        if not self.is_res_ok then return end
        self.animal_hit_effect_timer = nil
        if is_show_hit_effect then
            local param = {
                effect_id = EffectConst.HuntintEffectId.AnimalHit,
                need_sync_load = true,
            }
            self:AddUIEffect(self.hp_animal_hit_effect_parent, param)
            local time = self.hp_animal_unit:PlayAnim("hat", false)
            self.hp_aim_point_cs.stop_bg_time = time
            self:PlayUISoundByName("shoot_target_sound")
        end
        self:ShowHud(hurt_type, hurt)
    end, kShootAnimTime, 1)
end

function HuntingRareAnimalUI:RemoveShowHuntResultTimer()
    if not self.animal_hit_effect_timer then return end
    self:RemoveTimer(self.animal_hit_effect_timer)
    self.animal_hit_effect_timer = nil
end

function HuntingRareAnimalUI:AddSmallHitEffectTimer()
    if self.small_hit_effect_timer then return end
    self.small_hit_effect_timer = self:AddTimer(function()
        local param = {
            effect_id = EffectConst.HuntintEffectId.SmallAnimalHit,
            pos_tb = {math.random(-kRandomEffectRange, kRandomEffectRange), math.random(-kRandomEffectRange, kRandomEffectRange)},
            need_sync_load = true,
        }
        self:AddUIEffect(self.hp_animal_hit_effect_parent, param)
    end, self.hunting_rare_animal_effect_time, 0)
end

function HuntingRareAnimalUI:RemoveSmallHitEffectTimer()
    if not self.small_hit_effect_timer then return end
    self:RemoveTimer(self.small_hit_effect_timer)
    self.small_hit_effect_timer = nil
end

function HuntingRareAnimalUI:ShowHud(hurt_type, hurt)
    if hurt_type then
        local value = hurt or 0
        if hurt_type == UnitConst.UNITHUD_TYPE.Miss then
            value = nil
        end
        SpecMgrs.ui_mgr:ShowHud(
        {
            hud_type = hurt_type,
            value = value,
            point_go = self.hp_hud_parent,
        })
    end
end
----HuntingRareAnimalPanel end

----HuntingRareAnimalRankingPanel
function HuntingRareAnimalUI:ShowHuntingRareAnimalRankingPanel()
    if not self.animal_id then return end
    self.is_rank_panel_show = true
    self.dy_hunting_data:RegisterUpdateHuntingRareAnimalData("HuntingRareAnimalRankingPanel", function (_, serv_animal_data)
        self:UpdateHuntingRareAnimalDataCb(serv_animal_data)
    end)
    self.hp_aim_point_cs.is_auto_shoot = false
    self:_InsertActivePanel(panel_key_map.ranking_panel)
    self.ranking_panel:SetActive(true)
end

function HuntingRareAnimalUI:HideHuntingRareAnimalRankingPanel()
    if not self.is_rank_panel_show then return end
    self:ClearGoDict("rp_item_list")
    self.dy_hunting_data:UnregisterUpdateHuntingRareAnimalData("HuntingRareAnimalRankingPanel")
    self.hp_aim_point_cs.is_auto_shoot = self.hp_auto_shot_toogle.isOn
    self:_RemoveActivePanel()
    self.ranking_panel:SetActive(false)
    self.is_rank_panel_show = nil
end

function HuntingRareAnimalUI:SwitchAutoShoot(is_true)
    self.hp_aim_point_cs.is_auto_shoot = is_true
    self.hp_auto_shot_toogle.isOn = is_true
end

function HuntingRareAnimalUI:_UpdateRankingPanel()
    if self.animal_id then
        self.dy_hunting_data:UpdateHuntingRareAnimalData(self.animal_id)
    end
end

function HuntingRareAnimalUI:UpdateHuntingRareAnimalDataCb(serv_animal_data)
    local rank_data_list = serv_animal_data.hurt_rank
    if not next(rank_data_list) then
        self.rp_no_one_on_rank:SetActive(true)
    else
        self.rp_no_one_on_rank:SetActive(false)
        for i, rank_info in ipairs(rank_data_list) do
            if not self.rp_item_list[i] then
                self.rp_item_list[i] = self:GetUIObject(self.rp_item_temp, self.rp_item_parent)
            end
            local go = self.rp_item_list[i]
            local spec_rank_go = go:FindChild("Rank/SpecRank")
            local rank_text = go:FindChild("Rank/Text")
            local rank_icon = self.spec_rank_icon_list[i]
            local is_show_rank_icon = rank_icon and true or false
            if rank_icon then
                self:AssignSpriteByIconID(rank_icon, spec_rank_go:GetComponent("Image"))
            else
                rank_text:GetComponent("Text").text = i
            end
            spec_rank_go:SetActive(is_show_rank_icon)
            rank_text:SetActive(not is_show_rank_icon)
            local role_go = go:FindChild("Player/HeadIcon")
            local param_tb = {
                go = role_go,
                name = rank_info.role_name,
                dynasty_name = rank_info.dynasty_name,
                vip = rank_info.vip,
                server_id = rank_info.server_id,
                role_id = rank_info.role_id,
            }
            UIFuncs.InitRoleGo(param_tb)
            go:FindChild("Score/Text"):GetComponent("Text").text = UIFuncs.AddCountUnit(rank_info.hurt)
            local is_self = i == serv_animal_data.self_rank
            go:GetComponent("Image").enabled = not is_self
            go:FindChild("MyRank"):SetActive(is_self)
        end
    end
    self.rp_my_rank_text.text = serv_animal_data.self_rank
    self.rp_my_hurt_text.text = UIFuncs.AddCountUnit(serv_animal_data.self_hurt)
end
----HuntingRareAnimalRankingPanel end

----HuntingRareAnimalSuccessPanel
function HuntingRareAnimalUI:ShowHuntingRareAnimalSuccessPanel(msg)
    local ui = SpecMgrs.ui_mgr:GetUI("ItemUseUI") -- 狩猎珍兽结束 鼓舞确认使用钻石界面自动隐藏
    if ui and ui.is_showing then
        ui:Hide()
    end
    local award_role_item_list = ItemUtil.MergeRoleItemList(msg.item_list)
    for _, role_item in ipairs(award_role_item_list) do
        local award_item_go = self:GetUIObject(self.hsp_item_temp, self.hsp_item_parent)
        local param_tb = {go = award_item_go:FindChild("Item"), ui = self, count = role_item.count, item_id = role_item.item_id}
        UIFuncs.InitItemGo(param_tb)
        table.insert(self.hsp_item_list, award_item_go)
    end
    self.close_hunting_success_panel_timer = self:AddTimer(function ()
        self.close_hunting_success_panel_timer = nil
        self:HideHuntingRareAnimalSuccessPanel()
    end, kPanelAutoCloseTime)
    local description_str
    if not self.self_rank then
        description_str = UIConst.Text.HTUNTING_RARE_ANIMAL_NO_HURT
    else
        description_str = string.format(UIConst.Text.HUNTING_RARE_ANIMAL_SUCCESS, self.self_rank)
    end
    self.hsp_rank_text.text = description_str
    self.hp_animal_unit_parent:SetActive(false)
    self.hunting_success_panel:SetActive(true)
end

function HuntingRareAnimalUI:HideHuntingRareAnimalSuccessPanel()
    self:ClearGoDict("hsp_item_list")
    if self.close_hunting_success_panel_timer then
        self:RemoveTimer(self.close_hunting_success_panel_timer)
        self.close_hunting_success_panel_timer = nil
    end
    self.hp_animal_unit_parent:SetActive(true)
    self.hp_animal_unit:PlayAnim("run", true)
    self.hunting_success_panel:SetActive(false)
    self:HideHuntingRareAnimalPanel()
end
----HuntingRareAnimalSuccessPanel end

function HuntingRareAnimalUI:AddHuntingRareAnimalNumBtnOnClick()
    local add_hunt_data = self.dy_hunting_data:GetCurAddHuntData()
    if not add_hunt_data then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.ADD_HUTING_RARE_ANIMAL_NUM_ALREADY_TOP)
        return
    end
    local add_hunt_num = self.dy_hunting_data:GetAddHuntNum()
    local max_add_hunt_num = self.dy_hunting_data:GetMaxAddHuntNum()
    local item_data = SpecMgrs.data_mgr:GetItemData(add_hunt_data.cost_item)
    local data = {
        title = UIConst.Text.TIP,
        desc = string.format(UIConst.Text.ADD_HUTING_RARE_ANIMAL_NUM, add_hunt_data.cost_num, item_data.name),
        desc1 = string.format(UIConst.Text.HUTING_RARE_ANIMAL_NUM, add_hunt_num, max_add_hunt_num),
        item_id = add_hunt_data.cost_item,
        need_count = add_hunt_data.cost_num,
        remind_tag = "AddRareAnimal",
        confirm_cb = function ()
            SpecMgrs.msg_mgr:SendAddHuntNum({}, function (resp)
                if resp.errcode ~= 0 then
                    PrintError("SendAddHuntNum Get Wrong resp")
                end
            end)
        end
    }
    SpecMgrs.ui_mgr:ShowItemUseRemindByTb(data)
end

function HuntingRareAnimalUI:StartHuntBtnOnClick(animal_id)
    local rare_animal_data = self.dy_hunting_data:GetRareAnimalData(animal_id)
    if not rare_animal_data then return end
    if not rare_animal_data.is_start then
        if not self.dy_hunting_data:CheckCanHuntRareAnimal() then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.HUTING_RARE_ANIMAL_NUM_NOT_ENOUGH)
            return
        end
        SpecMgrs.msg_mgr:SendStartHuntRareAnimal({animal_id = animal_id}, function (resp)
            if resp.errcode ~= 0 then
                PrintError("Get wrong errcode in SendStartHuntRareAnimal", animal_id)
                return
            end
            self:ShowHuntingRareAnimalPanel(animal_id)
        end)
    else
        self:ShowHuntingRareAnimalPanel(animal_id)
    end
end

function HuntingRareAnimalUI:CheerBtnOnClick()
    if not self.animal_id then return end
    local inspire_num = self.inspire_num  + 1
    local inspire_data = SpecMgrs.data_mgr:GetHuntInspireData(inspire_num)
    if not inspire_data then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.INSPIRE_ALREADY_TOP)
        return
    end
    local desc = self:GetDescStr(inspire_num, inspire_data)
    local data = {
        title = UIConst.Text.INSPIRE,
        desc = desc,
        item_id = inspire_data.cost_item,
        need_count = inspire_data.cost_num,
        remind_tag = "HuntingRareAnimalInspire",
        confirm_cb = function ()
            if not self.animal_id then -- 玩家一直停留在该界面一直到狩猎自动结束
                SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.HUNTING_ALREADY_END)
                return
            end
            SpecMgrs.msg_mgr:SendHuntInspire({animal_id = self.animal_id}, function(resp)
                if resp.errcode ~= 0 then
                    PrintError("Get wrong errcode in SendHuntInspire", self.animal_id)
                end
                self:_UpdateHuntingPanel(self.animal_id)
            end)
        end

    }
    SpecMgrs.ui_mgr:ShowItemUseRemindByTb(data)
end

function HuntingRareAnimalUI:GetDescStr(inspire_num, inspire_data)
    local item_id = inspire_data.cost_item
    local item_name = SpecMgrs.data_mgr:GetItemData(item_id).name
    return string.format(UIConst.Text.USE_ITEM_ADD_INSPIRE, inspire_data.cost_num, item_name, (inspire_num) * self.inspire_add_rate * kPercent)
end

return HuntingRareAnimalUI