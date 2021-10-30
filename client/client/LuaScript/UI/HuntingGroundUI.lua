local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local CSConst = require("CSCommon.CSConst")
local UnitConst = require("Unit.UnitConst")
local SoundConst = require("Sound.SoundConst")
local ItemUtil = require("BaseUtilities.ItemUtil")
local EffectConst = require("Effect.EffectConst")
local SoundConst = require("Sound.SoundConst")
local HuntingGroundUI = class("UI.HuntingGroundUI",UIBase)
HuntingGroundUI.need_sync_load = true

local kDefaultBgNum = 2

local panel_key_map = {
    select_ground_panel = "SelectGroundPanel",
    first_pass_award_panel = "FirstPassAwardPanel",
    hunting_select_hero_panel = "HuntingSelectHeroPanel",
    hunting_panel = "HuntingPanel",
    hunting_success_panel = "HuntingSuccessPanel",
    hunting_fail_panel = "HuntingFailPanel",
}

local panel_hide_func_map ={
    SelectGroundPanel = "Hide",
    FirstPassAwardPanel = "HideFirstPassAwardPanel",
    HuntingSelectHeroPanel = "HideHuntingSelectHeroPanel",
    HuntingPanel = "HideHuntingPanel",
    HuntingSuccessPanel = "HideHuntingSuccessPanel",
    HuntingFailPanel = "HideHuntingFailPanel",
}

local kRankSpecialShow = 3 -- 排行榜排名<3显示不同排名背景
local kCoolDownUpdateTime = 1
local kShootAnimTime = 0.8
local kShootSoundTime = 0.4
local kLoadBulletTime = 1.8
local spec_rank_icon_list = UIConst.Icon.RankIconList

local hero_status_map = {
    normal = 1,
    selected = 2,
    resting = 3,
}

local kPanelAutoCloseTime = 3

function HuntingGroundUI:DoInit()
    HuntingGroundUI.super.DoInit(self)
    self.prefab_path = "UI/Common/HuntingGroundUI"
    self.bgm_sound = SpecMgrs.data_mgr:GetSoundId("hunt_bgm")
    self.dy_hunting_data = ComMgrs.dy_data_mgr.hunting_data
    self.dy_hero_data = ComMgrs.dy_data_mgr.night_club_data
    self.hunting_ground_data_list = SpecMgrs.data_mgr:GetAllHuntGroundData()
    self.hunting_ground_count = #self.hunting_ground_data_list
    self.hunting_shop_data_list = SpecMgrs.data_mgr:GetAllHuntShopData()
    self.max_hunt_rare_animal_num = self.dy_hunting_data:GetMaxHuntRareAnimalNum()
    self.max_shoot_cool_time = CSConst.Hunt.Cooldown
    --数据
    self.hero_status_dict = {} -- {[hero_id] = 1 or 2 or 3 }
    self.update_cool_timer = 0
    --引用
    self.ground_to_btn = {}
    self.ground_to_red_point = {}
    self.ground_to_recommend = {}
    self.ground_to_text = {}
    self.ground_to_text_go = {}
    self.ground_to_lock = {}
    self.rp_item_list = {}
    self.fpap_item_list = {}
    self.fpap_get_btn_list = {}
    self.fpap_not_pass_list = {}
    self.fpap_already_get_list = {}
    self.hshp_award_item_list = {}
    self.hpep_item_to_exchange_text = {}
    self.hpep_item_to_point_text = {}
    self.hpep_btn_text_list = {}
    -- go
    self.hshp_hero_to_go = {}
    self.hsp_award_item_list = {}
    self.hpep_item_list = {}
    self.animal_hit_effect_list = {}
end

function HuntingGroundUI:OnGoLoadedOk(res_go)
    HuntingGroundUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function HuntingGroundUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    HuntingGroundUI.super.Show(self)
end

function HuntingGroundUI:InitRes()
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

    self:AddClick(self.select_ground_panel:FindChild("ShowRankBtn"), function ()
        SpecMgrs.ui_mgr:ShowRankUI(UIConst.Rank.HuntPoint)
    end)

    self:AddClick(self.select_ground_panel:FindChild("ShowPointExchangeBtn"), function ()
        SpecMgrs.ui_mgr:ShowUI("ShoppingUI", UIConst.ShopList.HuntShop)
    end)

    --select_ground_panel 以下简称sgp
    self.ground_ui_temp = self.main_panel:FindChild("Temp/UIGo")
    local ground_btn_parent = self.select_ground_panel:FindChild("Scroll View/Viewport/Content/GroundList")
    for ground_id, data in ipairs(self.hunting_ground_data_list) do
        local ground_btn = ground_btn_parent:FindChild(ground_id)
        local ui_go = self:GetUIObject(self.ground_ui_temp, ground_btn)
        ui_go:FindChild("Text"):GetComponent("Text").text = data.name
        self.ground_to_btn[ground_id] = ui_go
        self.ground_to_red_point[ground_id] = ui_go:FindChild("RedPoint")
        self.ground_to_red_point[ground_id]:SetActive(false)
        self.ground_to_recommend[ground_id] = ui_go:FindChild("Recommend") -- 推荐规则待定可能删除
        self.ground_to_recommend[ground_id]:SetActive(false)
        self.ground_to_text_go[ground_id] = ui_go:FindChild("Description")
        self.ground_to_text[ground_id] = ui_go:FindChild("Description/Text"):GetComponent("Text")
        self.ground_to_lock[ground_id] = ui_go:FindChild("Description/Lock")
        self:AddClick(ui_go, function ()
            self:_GroundBtnClick(ground_id)
        end)
    end
    self.select_ground_panel:FindChild("TopBar/Tip/Text"):GetComponent("Text").text = UIConst.Text.HUNT_GROUND_TIPS
    self.first_pass_award_btn = self.select_ground_panel:FindChild("BottonBar/FirstPassAwardBtn")
    self.first_pass_award_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.FIRST_PASS_AWARD_TEXT
    self:AddClick(self.first_pass_award_btn, function ()
        self:ShowFirstPassAwardPanel()
    end)
    self.challenge_rare_animal_btn = self.select_ground_panel:FindChild("BottonBar/ChallengeRareAnimalBtn")
    self.challenge_rare_animal_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CHALLENGE_RARE_ANIMAL
    self:AddClick(self.challenge_rare_animal_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("HuntingRareAnimalUI")
    end)
    self:AddClick(self.select_ground_panel:FindChild("BottonBar/ChallengeCount/Button"), function ()
        self:AddHuntingRareAnimalNumBtnOnClick()
    end)
    self.sgp_challenge_count_text = self.select_ground_panel:FindChild("BottonBar/ChallengeCount/Text"):GetComponent("Text")
    self.sgp_challenge_recover_text = self.select_ground_panel:FindChild("BottonBar/ChallengeCoolDown"):GetComponent("Text")

    --first_pass_award_panel 以下简称fpap
    local fpap_item_parent = self.first_pass_award_panel:FindChild("Content/Scroll View/Viewport/Content")
    local fpap_item_temp = fpap_item_parent:FindChild("Item")
    fpap_item_temp:FindChild("Bottom/Status/GetBtn/Text"):GetComponent("Text").text = UIConst.Text.RECEIVE_TEXT
    self.first_pass_award_panel:FindChild("Content/Top/Text"):GetComponent("Text").text = UIConst.Text.FIRST_PASS_AWARD_TEXT
    local award_item_temp = fpap_item_temp:FindChild("Bottom/Scroll View/Viewport/Content/Item")
    UIFuncs.GetIconGo(self, award_item_temp)
    award_item_temp:SetActive(false)
    fpap_item_temp:SetActive(false)

    local go
    local award_go
    local item_data
    local get_btn
    local award_item_parent
    local title_text
    for id, data in ipairs(self.hunting_ground_data_list) do
        go = self:GetUIObject(fpap_item_temp, fpap_item_parent)
        go:FindChild("Title/Text"):GetComponent("Text").text = data.name
        award_item_parent = go:FindChild("Bottom/Scroll View/Viewport/Content")
        for i, item_id in ipairs(data.first_pass_award_list) do
            award_go = self:GetUIObject(award_item_temp, award_item_parent)
            item_data = SpecMgrs.data_mgr:GetItemData(item_id)
            local param_tb = {go = award_go:FindChild("Item"), item_data = item_data, count = data.first_pass_award_num_list[i], ui = self}
            UIFuncs.InitItemGo(param_tb)
        end
        self.fpap_item_list[id] = go
        get_btn = go:FindChild("Bottom/Status/GetBtn")
        self:AddClick(get_btn, function ()
            SpecMgrs.msg_mgr:SendGetFirstReward({ground_id = id}, function (resp)
                if resp.errcode ~= 0 then
                    PrintError("Get wrong errcode from serv in SendGetHuntNotice")
                end
                self.fpap_get_btn_list[id]:SetActive(false)
                self.fpap_already_get_list[id]:SetActive(true)
                self.fpap_item_list[id]:SetAsLastSibling()
            end)
        end)
        self.fpap_get_btn_list[id] = get_btn
        self.fpap_not_pass_list[id] = go:FindChild("Bottom/Status/NotPass")
        self.fpap_already_get_list[id] = go:FindChild("Bottom/Status/AlreadyGet")
    end

    --hunting_select_hero_panel 以下简称hshp
    self.hshp_top_bar_title_image = self.hunting_select_hero_panel:FindChild("TopBar/CloseBtn/Title"):GetComponent("Text")
    self.hunting_select_hero_panel:FindChild("GroundPart/Award/Text"):GetComponent("Text").text = UIConst.Text.RANDOM_AWARD
    self.hshp_ground_bg_image = self.hunting_select_hero_panel:FindChild("GroundPart/Icon"):GetComponent("Image")
    self.hshp_animal_name_text = self.hunting_select_hero_panel:FindChild("GroundPart/Prey/Name"):GetComponent("Text")
    self.hshp_animal_hp_text = self.hunting_select_hero_panel:FindChild("GroundPart/Prey/Hp"):GetComponent("Text")

    self.hshp_award_item_parent = self.hunting_select_hero_panel:FindChild("GroundPart/Award/Scroll View/Viewport/Content")
    self.hshp_award_item_temp = self.hshp_award_item_parent:FindChild("Item")
    UIFuncs.GetIconGo(self, self.hshp_award_item_temp)
    self.hshp_award_item_temp:SetActive(false)
    self.hunting_select_hero_panel:FindChild("GroundPart/FightingPart/Bottom/Text"):GetComponent("Text").text = UIConst.Text.SELECT_HERO_TEXT
    local fight_part = self.hunting_select_hero_panel:FindChild("GroundPart/FightingPart")
    self.hshp_kill_all_animal_score_text = fight_part:FindChild("Top/RecommendFight"):GetComponent("Text")
    self.hshp_hero_score_sum_text = fight_part:FindChild("Top/CurrentFight"):GetComponent("Text")
    self.hshp_suggest_text = fight_part:FindChild("Bottom/Suggest/Image/Text"):GetComponent("Text")
    self.onekey_accompany_btn = self.hunting_select_hero_panel:FindChild("GroundPart/OneKeyAccompanyBtn")
    self.onekey_accompany_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ONEKEY_ACCOMPANY
    self:AddClick(self.onekey_accompany_btn, function()
        self:OneKeyAccompanyBtnOnClick()
    end)
    self.hshp_hero_item_parent = self.hunting_select_hero_panel:FindChild("SelectHeroPart/Viewport/Content")
    self.hshp_hero_item_temp = self.hshp_hero_item_parent:FindChild("Item")
    self.hshp_hero_item_temp:FindChild("RecoverBtn/Text"):GetComponent("Text").text = UIConst.Text.RECOVER
    self.hshp_hero_item_temp:FindChild("CancelSelectBtn/Text"):GetComponent("Text").text = UIConst.Text.CANCEL_ACCOMPANY
    self.hshp_hero_item_temp:FindChild("SelectBtn/Text"):GetComponent("Text").text = UIConst.Text.ACCOMPANY
    self.hshp_hero_item_temp:SetActive(false)
    self.start_hunting_btn = self.hunting_select_hero_panel:FindChild("BottonBar/StartHuntingBtn")
    self.start_hunting_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.START_HUNT
    self:AddClick(self.start_hunting_btn, function ()
        self:StartHuntingBtnOnClik()
    end)
    --hunting_panel 以下简称hp
    self.hp_remain_prey_count_text = self.hunting_panel:FindChild("MiddlePart/RemainPrey/Text"):GetComponent("Text")
    self.hp_remain_bullet_count_text = self.hunting_panel:FindChild("MiddlePart/RemainBullet/Text"):GetComponent("Text")
    self.hp_animal_unit_parent = self.hunting_panel:FindChild("MiddlePart/Animal/UnitParent")
    self.hp_animal_hit_effect_parent = self.hunting_panel:FindChild("MiddlePart/Animal/HitEffectParent")
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

    --todo 跟换滚动bg
    self.hp_aim_point_cs = self.hunting_panel:FindChild("MiddlePart/Animal/AimPoint"):GetComponent("AimPoint")
    local bottom_part = self.hunting_panel:FindChild("MiddlePart/Bottom")
    self.hp_cool_down_image = bottom_part:FindChild("CoolDown"):GetComponent("Image")
    self.hp_load_bullet_hint = bottom_part:FindChild("Loading")
    self.hp_auto_shot_toogle = bottom_part:FindChild("AutoShot/Toggle"):GetComponent("Toggle")

    self.is_auto_shoot = false
    self.hp_auto_shot_toogle.isOn = self.is_auto_shoot
    self.hp_aim_point_cs.is_auto_shoot = self.is_auto_shoot
    self.hp_aim_point_cs.max_shoot_cool_time = self.max_shoot_cool_time

    self:AddToggle(self.hp_auto_shot_toogle.gameObject, function ()
        -- todo添加 vip验证
        self.is_auto_shoot = self.hp_auto_shot_toogle.isOn
        self.hp_aim_point_cs.is_auto_shoot = self.is_auto_shoot
    end)

    self.hp_shoot_btn = bottom_part:FindChild("ShootBtn")
    self:AddClick(self.hp_shoot_btn, function ()
        self:ShootBtnOnClick()
    end, SoundConst.SoundID.SID_NotPlaySound)
    self.hp_animal_hp_slider = self.hunting_panel:FindChild("MiddlePart/Animal/Hp"):GetComponent("Slider")
    self.hp_animal_hp_text = self.hunting_panel:FindChild("MiddlePart/Animal/Hp/Fill Area/Text"):GetComponent("Text")
    self.hp_animal_name_text = self.hunting_panel:FindChild("MiddlePart/Animal/Name"):GetComponent("Text")
    self.hp_hero_score_sum_text = self.hunting_panel:FindChild("MiddlePart/FightScore/Text"):GetComponent("Text")
    self.hp_hud_parent = self.hunting_panel:FindChild("MiddlePart/Animal/HudParent")
    --hunting_success_panel 以下简称hsp
    self.hsp_award_item_parent = self.hunting_success_panel:FindChild("Award")
    self.hsp_award_item_temp = self.hsp_award_item_parent:FindChild("Item")
    self.hunting_success_panel:FindChild("Award/Text"):GetComponent("Text").text = UIConst.Text.CLOSE_TIP_TEXT
    UIFuncs.GetIconGo(self, self.hsp_award_item_temp)
    self.hsp_award_item_temp:SetActive(false)
end

function HuntingGroundUI:_InitCloseClickFunc(panel, panel_name)
    local close_bg = panel:FindChild("CloseBg")
    local close_btn = panel:FindChild("Content/Top/CloseBtn")
    local close_go = close_bg or close_btn
    if not close_go then return end
    self:AddClick(close_go, function ()
        self:GetHidePanelFunc(panel_name)(self)
    end)
end

function HuntingGroundUI:_GroundBtnClick(ground_id)
    if not self.dy_hunting_data:CheckGroundUnlock(ground_id, true) then
        return
    end
    local serv_ground_data = self.dy_hunting_data:GetHuntingGroundData(ground_id)
    local ground_data = self.hunting_ground_data_list[ground_id]
    local remain_animal_num = ground_data.animal_num - serv_ground_data.animal_num
    if remain_animal_num <= 0 then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.GROUND_ALREADY_HUNTED)
        return
    end
    local cur_ground_id = self.dy_hunting_data:GetCurrentHutingGroundId()
    if cur_ground_id then
        if cur_ground_id == ground_id then
            self:ShowHuntingPanel(ground_id)
        else
            local content = string.format(UIConst.Text.GIVE_UP_HUNTING_GROUND, self.hunting_ground_data_list[ground_id].name)
            local param_tb = {content = content, confirm_cb = function ()
                self:SendGiveUpHuntGround(ground_id)
            end}
            SpecMgrs.ui_mgr:ShowMsgSelectBox(param_tb)
        end
    else
        self:ShowHuntingSelectHeroPanel(ground_id)
    end
end

function HuntingGroundUI:SendGiveUpHuntGround(ground_id)
    SpecMgrs.msg_mgr:SendGiveUpHuntGround({},function (resp)
        if resp.errcode ~= 0 then
            PrintError("Get wrong errcode from serv in SendGiveUpHuntGround")
            return
        end
        self.dy_hunting_data:GiveUpHuntGround()
        self:ShowHuntingSelectHeroPanel(ground_id)
    end)
end

function HuntingGroundUI:AddHuntingRareAnimalNumBtnOnClick()
    local add_hunt_data = self.dy_hunting_data:GetCurAddHuntData()
    if not add_hunt_data then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.ADD_HUTING_RARE_ANIMAL_NUM_ALREADY_TOP)
        return
    end
    local add_hunt_num = self.dy_hunting_data:GetAddHuntNum()
    local max_add_hunt_num = self.dy_hunting_data:GetMaxHuntRareAnimalNum()
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

function HuntingGroundUI:InitUI()
    self:PlayBGM(SoundConst.SOUND_ID_Hunting)
    for ground_id, data in ipairs(self.hunting_ground_data_list) do
        local ui_go = self.ground_to_btn[ground_id]
        self:AddFullUnit(data.unit_id, ui_go:FindChild("AnimalParent")):StopAllAnimationToCurPos()
    end
    self:RegisterEvent(self.dy_hunting_data, "UpdateCurrentHuntingGroundData", function (_, ground_id)
        self:UpdateGround(ground_id)
    end)
    self:RegisterEvent(self.dy_hunting_data, "UpdateHuntingRareAnimalNum", function ()
        self:UpdateChallengeCount()
    end)
    self:RegisterEvent( ComMgrs.dy_data_mgr, "UpdateCurrencyEvent", function (_, currency)
        UIFuncs.UpdateCurrencyItemNum(self._item_to_text_list, currency)
    end)
    self:RegisterEvent(ComMgrs.dy_data_mgr.bag_data, "UpdateBagItemEvent", function (_, op, item_data)
        UIFuncs.UpdateBagItemNum(self._item_to_text_list, item_data)
    end)
    self:UpdateChallengeCount()
    self:UpdateGround()
end

function HuntingGroundUI:_InitFirstPassAwardPanel()
    local serv_ground_data
    local is_pass
    local is_already_get
    for ground_id, ground_data in ipairs(self.hunting_ground_data_list) do
        serv_ground_data = self.dy_hunting_data:GetHuntingGroundData(ground_id)
        is_pass = serv_ground_data and serv_ground_data.first_reward ~= false or false
        is_already_get = serv_ground_data and serv_ground_data.first_reward == nil
        self.fpap_get_btn_list[ground_id]:SetActive(is_pass and not is_already_get)
        self.fpap_already_get_list[ground_id]:SetActive(is_pass and is_already_get)
         self.fpap_not_pass_list[ground_id]:SetActive(not is_pass)
        if is_already_get then
            self.fpap_item_list[ground_id]:SetAsLastSibling()
        end
    end
end

function HuntingGroundUI:Hide()
    self.dy_hunting_data:UnregisterUpdateCurrentHuntingGroundData("HuntingGroundUI")
    self.dy_hunting_data:UnregisterUpdateHuntingRareAnimalNum("HuntingGroundUI")
    self.hero_status_dict = {}
    self.update_cool_timer = 0
    HuntingGroundUI.super.Hide(self)
end

function HuntingGroundUI:Update(delta_time)
    if self.is_show_challenge_count_down then
        self.update_cool_timer = self.update_cool_timer + delta_time
        if self.update_cool_timer >= kCoolDownUpdateTime then
            self:_UpdateChallengeCoolText()
            self.update_cool_timer = self.update_cool_timer - kCoolDownUpdateTime
        end
    end
end

function HuntingGroundUI:_UpdateChallengeCoolText()
    local challenge_cool_time = self.dy_hunting_data:GetChallengeCoolDownTime()
    if challenge_cool_time then
        local str = UIFuncs.GetCountDownDayStr(challenge_cool_time)
        self.sgp_challenge_recover_text.text = string.format(UIConst.Text.CHALLENGE_RECOVER, str)
    else
        self.is_show_challenge_count_down = false
        self.sgp_challenge_recover_text.gameObject:SetActive(false)
    end
end

function HuntingGroundUI:GetHidePanelFunc(panel_name)
    return self[panel_hide_func_map[panel_name]]
end

function HuntingGroundUI:UpdateGround(ground_id)
    if not ground_id then
        for i = 1, self.hunting_ground_count do
            self:_UpdateGroundBtnByGroundId(i)
        end
    else
        self:_UpdateGroundBtnByGroundId(ground_id)
    end
end

function HuntingGroundUI:_UpdateGroundBtnByGroundId(ground_id)
    local serv_ground_data = self.dy_hunting_data:GetHuntingGroundData(ground_id)
    local ground_data = self.hunting_ground_data_list[ground_id]
    local hunting_description_str
    local is_show_red_point = false
    local is_show_ground_btn = true
    local is_show_lock = false
    if serv_ground_data then
        local cur_ground_id = self.dy_hunting_data:GetCurrentHutingGroundId()
        local remain_animal_num = ground_data.animal_num - serv_ground_data.animal_num
        if remain_animal_num <= 0 then
            hunting_description_str = UIConst.Text.ALREADYHUNTED
        elseif cur_ground_id == ground_id then -- 当前正在打
            hunting_description_str = string.format(UIConst.Text.ISHUNTING,serv_ground_data.animal_num, ground_data.animal_num)
            if serv_ground_data.arrow_num >= 0 then
                is_show_red_point = true
            end
        elseif serv_ground_data.animal_hp ~= ground_data.animal_hp[1] then -- 打了一部分没打完 就去打别的猎场
            hunting_description_str = string.format(UIConst.Text.SPRIT, serv_ground_data.animal_num, ground_data.animal_num)
        end
    elseif ground_id > self.dy_hunting_data:GetUnLockHuntingGroundCount()then  -- 显示已解锁的下一个未解锁的猎场
        is_show_lock = true
        --is_show_ground_btn = true
    end

    if is_show_ground_btn then
        if hunting_description_str ~= nil then
            self.ground_to_text[ground_id].text = hunting_description_str
            self.ground_to_text[ground_id].gameObject:SetActive(true)
            self.ground_to_text_go[ground_id]:SetActive(true)
        else
            self.ground_to_text[ground_id].gameObject:SetActive(false)
            self.ground_to_text_go[ground_id]:SetActive(is_show_lock)
        end
    end

    self.ground_to_lock[ground_id]:SetActive(is_show_lock)
    if is_show_lock then
        self.ground_to_lock[ground_id]:FindChild("Text"):GetComponent("Text").text = string.format(UIConst.Text.LEVEL, ground_data.open_level)
    end
    local color_hex = is_show_lock and UIConst.Color.Gray or UIConst.Color.Default
    local color = UIFuncs.HexToRGBColor(color_hex)
    self.ground_to_btn[ground_id]:FindChild("Text"):GetComponent("Text").color = color
    self.ground_to_btn[ground_id]:FindChild("Bar/Lock"):SetActive(is_show_lock)
    self.ground_to_red_point[ground_id]:SetActive(is_show_red_point)
    self.ground_to_btn[ground_id]:SetActive(is_show_ground_btn)
end

function HuntingGroundUI:UpdateChallengeCount()
    local hunt_rare_animal_num = self.dy_hunting_data:GetHuntRareAnimalNum()
    self.sgp_challenge_count_text.text = string.format(UIConst.Text.HUNTING_RARE_ANIMAL_NUM, hunt_rare_animal_num, self.max_hunt_rare_animal_num)
    if hunt_rare_animal_num < self.max_hunt_rare_animal_num then
        self.is_show_challenge_count_down = true
        self:_UpdateChallengeCoolText()
    else
        self.is_show_challenge_count_down = false
    end
    self.sgp_challenge_recover_text.gameObject:SetActive(self.is_show_challenge_count_down)
end

----FirstPassAwardPanel
function HuntingGroundUI:ShowFirstPassAwardPanel()
    self:_InitFirstPassAwardPanel()
    self.first_pass_award_panel:SetActive(true)
end

function HuntingGroundUI:HideFirstPassAwardPanel()
    self.first_pass_award_panel:SetActive(false)
end
----FirstPassAwardPanel end

----HuntingSelectHeroPanel
function HuntingGroundUI:ShowHuntingSelectHeroPanel(ground_id)
    self.show_hshp_ground_id = ground_id
    local ground_data = self.hunting_ground_data_list[ground_id]
    local unit_data = SpecMgrs.data_mgr:GetUnitData(ground_data.unit_id)
    self:AssignSpriteByIconID(unit_data.icon, self.hshp_ground_bg_image)
    self.hshp_animal_name_text.text = string.format(UIConst.Text.HUTNING_ANIMAL_NAME, unit_data.name)
    local first_animal_hp_str = UIFuncs.AddCountUnit(ground_data.animal_hp[1])
    local last_animal_hp_str = UIFuncs.AddCountUnit(ground_data.animal_hp[ground_data.animal_num])
    self.hshp_animal_hp_text.text = string.format(UIConst.Text.HUNTING_ANIMAL_HP, first_animal_hp_str, last_animal_hp_str)
    local drop_item_data_list = ItemUtil.GetSortedDropItemDataList(ground_data.drop_id)
    for _, item_data_dict in ipairs(drop_item_data_list) do
        local award_item = self:GetUIObject(self.hshp_award_item_temp, self.hshp_award_item_parent)
        UIFuncs.InitItemGo({ui = self, go = award_item:FindChild("Item"), item_data = item_data_dict.item_data, count = item_data_dict.count})
        table.insert(self.hshp_award_item_list, award_item)
    end
    self.hshp_kill_one_animal_score, self.hshp_kill_all_animal_score = self:_GetGroundRecommendScore(ground_id)
    local score = UIFuncs.AddCountUnit(self.hshp_kill_all_animal_score)
    self.hshp_kill_all_animal_score_text.text = string.format(UIConst.Text.HUNTING_SUGGEST_SCORE, score)
    self:_ChangeHeroScoreSum(0)
    self:_InitAllHeroItem()
    self.hunting_select_hero_panel:SetActive(true)
end

function HuntingGroundUI:HideHuntingSelectHeroPanel()
    self:ClearGoDict("hshp_award_item_list")
    self:ClearGoDict("hshp_hero_to_go")
    self.hshp_hero_score_sum = nil
    self.hshp_kill_one_animal_score = nil
    self.hshp_kill_all_animal_score = nil
    self.hshp_hero_btn_dict = nil
    self.hshp_hero_status_go = nil
    self.show_hshp_ground_id = nil
    self.hunting_select_hero_panel:SetActive(false)
end

function HuntingGroundUI:_UpdateAllHeroStatus()
    local resting_hero_dict = self.dy_hunting_data:GetRestingHeroDict()
    for hero_id, _ in pairs(self.hshp_hero_to_go) do
        if resting_hero_dict[hero_id] then
            self.hero_status_dict[hero_id] = hero_status_map.resting
        else
            self.hero_status_dict[hero_id] = hero_status_map.normal
        end
    end
end

function HuntingGroundUI:_GetGroundRecommendScore(ground_id)
    local ground_data = self.hunting_ground_data_list[ground_id]
    local serv_ground_data = self.dy_hunting_data:GetHuntingGroundData(ground_id)
    local hp_sum = 0
    hp_sum = hp_sum + serv_ground_data.animal_hp
    for i = serv_ground_data.animal_num + 1, ground_data.animal_num do
        hp_sum = hp_sum + ground_data.animal_hp[i]
    end
    local kill_one_animal_score = math.ceil(serv_ground_data.animal_hp * ground_data.recommend_rate / ground_data.arrow_num)
    local kill_all_animal_score = math.ceil(hp_sum * ground_data.recommend_rate / ground_data.arrow_num)
    return kill_one_animal_score, kill_all_animal_score
end

function HuntingGroundUI:_InitAllHeroItem()
    local hero_list_sorted_by_score = self.dy_hero_data:GetHeroListSortedByScore()
    self.hshp_hero_btn_dict = {}
    self.hshp_hero_status_go = {}
    self:ClearGoDict("hshp_hero_to_go")
    local hero_data
    local item
    local recover_btn
    local cancel_select_btn
    local select_btn
    for _, serv_hero_data in ipairs(hero_list_sorted_by_score) do
        local hero_id = serv_hero_data.hero_id
        hero_data = SpecMgrs.data_mgr:GetHeroData(hero_id)
        item = self:GetUIObject(self.hshp_hero_item_temp, self.hshp_hero_item_parent)
        UIFuncs.InitHeroGo({go = item:FindChild("Hero"), hero_data = hero_data})
        item:FindChild("Hero/Name"):GetComponent("Text").text = hero_data.name
        item:FindChild("Hero/Name/Level"):GetComponent("Text").text = string.format(UIConst.Text.LEVEL, serv_hero_data.level)
        item:FindChild("Hero/Score"):GetComponent("Text").text = string.format(UIConst.Text.MILITARY_VAL_FROMAL, serv_hero_data.score)
        self.hshp_hero_btn_dict[hero_id] = {}
        select_btn = item:FindChild("SelectBtn")
        self.hshp_hero_btn_dict[hero_id].select_btn = select_btn
        self:AddClick(select_btn, function()
            self:SelectBtnOnClick(hero_id)
        end)
        cancel_select_btn = item:FindChild("CancelSelectBtn")
        self.hshp_hero_btn_dict[hero_id].cancel_select_btn = cancel_select_btn
        self:AddClick(cancel_select_btn, function()
            self:CancelSelectBtnOnClick(hero_id)
        end)
        recover_btn = item:FindChild("RecoverBtn")
        self.hshp_hero_btn_dict[hero_id].recover_btn = recover_btn
        self:AddClick(recover_btn, function()
            self:RecoverBtnOnClick(hero_id)
        end)
        self.hshp_hero_status_go[hero_id] = {}
        self.hshp_hero_status_go[hero_id].selected = item:FindChild("Hero/Selected")
        self.hshp_hero_status_go[hero_id].resting = item:FindChild("Hero/Resting")
        self.hshp_hero_to_go[hero_id] = item
    end
    self:_UpdateAllHeroStatus()
    self:_UpdateAllHeroItem()
    self:_UpdateRestingHeroItemSibling()
end

function HuntingGroundUI:SelectBtnOnClick(hero_id)
    if self.hero_status_dict[hero_id] == hero_status_map.normal then
        self.hero_status_dict[hero_id] = hero_status_map.selected
        local hero_score = self.dy_hero_data:GetHeroDataById(hero_id).score
        self:_ChangeHeroScoreSum(hero_score)
        self:_UpdateHeroStatus(hero_id)
    end
end

function HuntingGroundUI:RecoverBtnOnClick(hero_id)
    if self.hero_status_dict[hero_id] == hero_status_map.resting then
        local hero_hunt_recover_item = SpecMgrs.data_mgr:GetParamData("hero_hunt_recover_item")
        if not UIFuncs.CheckItemCount(hero_hunt_recover_item.item_id, hero_hunt_recover_item.count, true) then
            return
        end
        SpecMgrs.msg_mgr:SendHuntHeroRecover({hero_id = hero_id}, function (resp)
            if resp.errcode ~= 0 then
                PrintError("Get wrong errcode from serv in SendHuntHeroRecover", hero_id)
                return
            end
            self:RecoverHero(hero_id)
        end)
    end
end

function HuntingGroundUI:CancelSelectBtnOnClick(hero_id)
    if self.hero_status_dict[hero_id] == hero_status_map.selected then
        self.hero_status_dict[hero_id] = hero_status_map.normal
        local hero_score = self.dy_hero_data:GetHeroDataById(hero_id).score
        self:_ChangeHeroScoreSum(-hero_score)
        self:_UpdateHeroStatus(hero_id)
    end
end
function HuntingGroundUI:_UpdateRestingHeroItemSibling()
    for hero_id, _ in pairs(self.hshp_hero_to_go) do
        if self.hero_status_dict[hero_id] == hero_status_map.resting then
            self.hshp_hero_to_go[hero_id]:SetAsLastSibling()
        end
    end
end

function HuntingGroundUI:RecoverHero(hero_id)
    self.dy_hunting_data:RecoverHero(hero_id)
    self.hero_status_dict[hero_id] = hero_status_map.normal
    self:_UpdateHeroStatus(hero_id)
    local hero_list_sorted_by_score = self.dy_hero_data:GetHeroListSortedByScore()
    local index = 0
    for k, hero_data in ipairs(hero_list_sorted_by_score) do
        if self.hero_status_dict[hero_data.hero_id] == hero_status_map.normal then
            index = index + 1
        end
        if hero_id == hero_data.hero_id then
            break
        end
    end
    self.hshp_hero_to_go[hero_id]:SetSiblingIndex(index)
end

function HuntingGroundUI:_ChangeHeroScoreSum(change_value)
    if not self.hshp_hero_score_sum then self.hshp_hero_score_sum = 0 end
    self.hshp_hero_score_sum = self.hshp_hero_score_sum + change_value
    local score = UIFuncs.AddCountUnit(self.hshp_hero_score_sum)
    local color = self.hshp_hero_score_sum > self.hshp_kill_all_animal_score and UIConst.Color.Green1 or UIConst.Color.Red1
    self.hshp_hero_score_sum_text.text = string.format(UIConst.Text.CUR_SCORE, color, score)
    if self.hshp_hero_score_sum > self.hshp_kill_all_animal_score then
        self.hshp_suggest_text.text  = UIConst.Text.SELECT_HERO_SCORE_ENOUGH
    elseif self.hshp_hero_score_sum > self.hshp_kill_one_animal_score then
        self.hshp_suggest_text.text  = UIConst.Text.SELECT_HERO_SCORE_NOT_ENOUGH_TO_KILL_ALL
    else
        self.hshp_suggest_text.text  = UIConst.Text.SELECT_HERO_SCORE_NOT_ENOUGH_TO_KILL_ONE
    end
end

function HuntingGroundUI:_UpdateAllHeroItem()
    for hero_id, _ in pairs(self.hshp_hero_to_go) do
        self:_UpdateHeroStatus(hero_id)
    end
end

function HuntingGroundUI:_UpdateHeroStatus(hero_id)
    local hero_status = self.hero_status_dict[hero_id]
    local is_selected = hero_status == hero_status_map.selected
    local is_resting = hero_status == hero_status_map.resting
    self.hshp_hero_btn_dict[hero_id].select_btn:SetActive(hero_status == hero_status_map.normal)
    self.hshp_hero_btn_dict[hero_id].recover_btn:SetActive(is_resting)
    self.hshp_hero_btn_dict[hero_id].cancel_select_btn:SetActive(is_selected)
    self.hshp_hero_status_go[hero_id].selected:SetActive(is_selected)
    self.hshp_hero_status_go[hero_id].resting:SetActive(is_resting)
end

function HuntingGroundUI:OneKeyAccompanyBtnOnClick()
    if self.hshp_hero_score_sum > self.hshp_kill_all_animal_score then return end
    local hero_list_sorted_by_score = self.dy_hero_data:GetHeroListSortedByScore()
    for _, hero_data in ipairs(hero_list_sorted_by_score) do
        if self.hero_status_dict[hero_data.hero_id] == hero_status_map.normal then
            self:SelectBtnOnClick(hero_data.hero_id)
            if self.hshp_hero_score_sum > self.hshp_kill_all_animal_score then
                break
            end
        end
    end
end

function HuntingGroundUI:GetHeroSelectedList()
    if self.hero_status_dict then
        local hero_selected_list = {}
        for hero_id ,hero_status in pairs(self.hero_status_dict) do
            if hero_status == hero_status_map.selected then
                table.insert(hero_selected_list,hero_id)
            end
        end
        return hero_selected_list
    end
end

function HuntingGroundUI:StartHuntingBtnOnClik()
    local ground_id = self.show_hshp_ground_id
    if ground_id then
        local hero_selected_list = self:GetHeroSelectedList()
        if not next(hero_selected_list) then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.HUNTING_WITH_NO_HERO)
        else
            SpecMgrs.msg_mgr:SendSetHuntHero({ground_id = ground_id, hero_list = hero_selected_list}, function ()
                self:ShowHuntingPanel(ground_id)
                self:HideHuntingSelectHeroPanel()
            end)
        end
    end
end

----HuntingSelectHeroPanel end

----HuntingPanel
function HuntingGroundUI:ShowHuntingPanel(ground_id)
    self:PlayBGM(self.bgm_sound)
    SpecMgrs.msg_mgr:SendStartHuntGround()
    self:SwitchAutoShoot(false)
    self.show_hunting_panel_ground_id = ground_id
    self.dy_hunting_data:RegisterShowHuntingGroundKillAward("HuntingGroundUI", function (_, msg)
        self.show_success_panle_msg = msg
    end)
    self:_UpdateHuntingPanel(ground_id)
    self:UpdateAnimalUnit(ground_id)
    self:_UpdateAnimalHp()
    self:ResetHunt()
    self.hunting_panel:SetActive(true)
end

function HuntingGroundUI:ChangeHuntingBg(ground_data)
    for i = 1, kDefaultBgNum do
        self:AssignUISpriteSync(ground_data.close_bg_res_path, ground_data.close_bg_res_name, self.close_hunt_bg_image_list[i])
        self:AssignUISpriteSync(ground_data.far_bg_res_path, ground_data.far_bg_res_name, self.far_hunt_bg_image_list[i])
    end
end

function HuntingGroundUI:_UpdateHuntingPanel(ground_id)
    local serv_ground_data = self.dy_hunting_data:GetHuntingGroundData(ground_id)
    local ground_data = self.hunting_ground_data_list[ground_id]
    local unit_data = SpecMgrs.data_mgr:GetUnitData(ground_data.unit_id)
    self.hp_animal_name_text.text = unit_data.name
    local remain_animal_num = ground_data.animal_num - serv_ground_data.animal_num
    self.hp_remain_prey_count_text.text =  string.format(UIConst.Text.REAMIN_ANIMAL_NUM, remain_animal_num)
    self.hp_remain_bullet_count_text.text = string.format(UIConst.Text.REAMIN_BULLET_NUM, serv_ground_data.arrow_num)
    self.hp_hero_score_sum_text.text = self:GetHeroScoreSum(serv_ground_data.hero_list)
    self:ChangeHuntingBg(ground_data)
end

function HuntingGroundUI:SwitchAutoShoot(is_true)
    self.hp_aim_point_cs.is_auto_shoot = is_true
    self.hp_auto_shot_toogle.isOn = is_true
end

function HuntingGroundUI:_UpdateAnimalHp(hp)
    local ground_id = self.show_hunting_panel_ground_id
    local serv_ground_data = self.dy_hunting_data:GetHuntingGroundData(ground_id)
    local ground_data = self.hunting_ground_data_list[ground_id]
    local cur_animal_id = serv_ground_data.animal_num + 1
    cur_animal_id = math.clamp(cur_animal_id, 1, #ground_data.animal_hp)
    local animal_max_hp = ground_data.animal_hp[cur_animal_id]
    hp = hp or serv_ground_data.animal_hp
    self.hp_animal_hp_slider.value = hp / animal_max_hp
    self.hp_animal_hp_text.text = string.format(UIConst.Text.SPRIT, hp, animal_max_hp)
end

function HuntingGroundUI:_CheckHuntingFail(serv_ground_data)
    return serv_ground_data.arrow_num <= 0 and serv_ground_data.animal_hp > 0
end

function HuntingGroundUI:HideHuntingPanel()
    self:RemoveBGM()
    self:CleanHuntTimer()
    self.show_success_panle_msg = nil
    SpecMgrs.msg_mgr:SendEndHuntGround()
    self.dy_hunting_data:UnregisterShowHuntingGroundKillAward("HuntingGroundUI")
    self:UpdateGround(self.show_hunting_panel_ground_id)
    self:CleanAnimalUnit()
    self.show_hunting_panel_ground_id = nil
    self.hunting_panel:SetActive(false)
end

function HuntingGroundUI:CleanHuntTimer()
    self:RemoveTimerByName("animal_hit_effect_timer")
    self:RemoveTimerByName("delay_check_over_timer")
end

function HuntingGroundUI:RemoveTimerByName(timer_name)
    if self[timer_name] then
        self:RemoveTimer(self[timer_name])
        self[timer_name] = nil
    end
end

function HuntingGroundUI:GetHeroScoreSum(hero_list)
    if not hero_list then return end
    local score_sum = 0
    for _, hero_id in pairs(hero_list) do
        score_sum = score_sum + self.dy_hero_data:GetHeroDataById(hero_id).score
    end
    return score_sum
end

function HuntingGroundUI:CleanAnimalUnit()
    if self.hp_animal_unit then
        ComMgrs.unit_mgr:DestroyUnit(self.hp_animal_unit)
        self.hp_animal_unit = nil
    end
end

function HuntingGroundUI:UpdateAnimalUnit(ground_id)
    local unit_id = self.hunting_ground_data_list[ground_id].unit_id
    self:CleanAnimalUnit()
    self.hp_animal_unit = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = unit_id, parent = self.hp_animal_unit_parent})
end

function HuntingGroundUI:ShootBtnOnClick()
    local ground_id = self.show_hunting_panel_ground_id
    if not ground_id then return end
    local shoot_ret = self.hp_aim_point_cs:Shoot()
    if shoot_ret == CSConst.ShootResult.Reload then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.LOADING_BULLET)
    else
        SpecMgrs.msg_mgr:SendHuntGroundAnimal({ground_id = ground_id, shoot_result = shoot_ret},function (resp)
            if resp.errcode == 0 then
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
                    if self.play_load_bullet_sound then
                        self:PlayUISoundByName("load_bullet_sound")
                        self.play_load_bullet_sound = nil
                    end
                end, kLoadBulletTime)
                self:DelayShowHuntResult(hurt_type, resp.hurt, is_show_hit_effect)
            end
        end)
    end
end

-- 等待开枪动画结束
function HuntingGroundUI:DelayShowHuntResult(hurt_type, hurt, is_show_hit_effect)
    if self.animal_hit_effect_timer then return end
    self.animal_hit_effect_timer = self:AddTimer(function()
        self.animal_hit_effect_timer = nil
        if is_show_hit_effect then
            local param = {
                effect_id = EffectConst.HuntintEffectId.AnimalHit,
                need_sync_load = true,
            }
            self:AddUIEffect(self.hp_animal_hit_effect_parent, param)
            local time = self.hp_animal_unit:PlayAnim("hat", false)
            self:PlayUISoundByName("shoot_target_sound")
            self.hp_aim_point_cs.stop_bg_time = time
            self:DelayCheckHuntOver(time)
        else
            self:CheckHuntOver()
        end
        self:ShowHud(hurt_type, hurt)
        if self.show_success_panle_msg then
            self:_UpdateAnimalHp(0)
        else
            self:_UpdateAnimalHp()
        end
        self:_UpdateArrowNum()
    end, kShootAnimTime, 1)
end

function HuntingGroundUI:_UpdateArrowNum()
    local serv_ground_data = self.dy_hunting_data:GetHuntingGroundData(self.show_hunting_panel_ground_id)
    self.hp_remain_bullet_count_text.text = string.format(UIConst.Text.REAMIN_BULLET_NUM, serv_ground_data.arrow_num)
end

function HuntingGroundUI:DelayCheckHuntOver(time)
    if self.delay_check_over_timer then return end
    self.delay_check_over_timer = self:AddTimer(function()
        self.delay_check_over_timer = nil
        self:CheckHuntOver()
    end, time, 1)
end

function HuntingGroundUI:CheckHuntOver()
    local serv_ground_data = self.dy_hunting_data:GetHuntingGroundData(self.show_hunting_panel_ground_id)
    if self:_CheckHuntingFail(serv_ground_data) then
        self:ShowHuntingFailPanel()
    elseif self.show_success_panle_msg then
        self:ShowHuntingSuccessPanel(self.show_success_panle_msg)
        self.show_success_panle_msg = nil
        self:UpdateAnimalUnit(self.show_hunting_panel_ground_id)
    else
        self.play_load_bullet_sound = true
    end
    self:_UpdateHuntingPanel(self.show_hunting_panel_ground_id)
end

function HuntingGroundUI:ShowHud(hurt_type, hurt)
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

----HuntingPanel end

----HuntingSuccessPanel
function HuntingGroundUI:ShowHuntingSuccessPanel(msg)
    self.hp_aim_point_cs.Is_scroll_bg_runing = false
    self.hp_aim_point_cs.is_auto_shoot = false
    local award_role_item_list = ItemUtil.MergeRoleItemList(msg.item_list)
    for _, role_item in ipairs(award_role_item_list) do
        local award_item_go = self:GetUIObject(self.hsp_award_item_temp, self.hsp_award_item_parent)
        local item_data = SpecMgrs.data_mgr:GetItemData(role_item.item_id)
        local param_tb = {ui = self, go = award_item_go:FindChild("Item"), item_data = item_data, count = role_item.count}
        UIFuncs.InitItemGo(param_tb)
        table.insert(self.hsp_award_item_list, award_item_go)
    end
    self.close_hunting_success_panel_timer = self:AddTimer(function ()
        self.close_hunting_success_panel_timer = nil
        self:HideHuntingSuccessPanel()
    end, kPanelAutoCloseTime)
    self.hp_animal_unit_parent:SetActive(false)
    self.hunting_success_panel:SetActive(true)
end

function HuntingGroundUI:HideHuntingSuccessPanel()
    self.hp_aim_point_cs.is_auto_shoot = self.hp_auto_shot_toogle.isOn
    if self.close_hunting_success_panel_timer then
        self:RemoveTimer(self.close_hunting_success_panel_timer)
        self.close_hunting_success_panel_timer = nil
    end
    for _, v in ipairs(self.hsp_award_item_list) do
        self:DelUIObject(v)
    end
    self.hsp_award_item_list = {}
    self.hp_animal_unit_parent:SetActive(true)
    self.hunting_success_panel:SetActive(false)
    if self.show_hunting_panel_ground_id then
        local serv_ground_data = self.dy_hunting_data:GetHuntingGroundData(self.show_hunting_panel_ground_id)
        local ground_data = self.hunting_ground_data_list[self.show_hunting_panel_ground_id]
        local remain_animal_num = ground_data.animal_num - serv_ground_data.animal_num
        if remain_animal_num <= 0 then
            self:HideHuntingPanel()
        else
            self:ResetHunt()
            self:_UpdateAnimalHp()
        end
    end
end

function HuntingGroundUI:ResetHunt()
    self.hp_aim_point_cs:Reset()
    if self.hp_animal_unit.is_res_ok then
        self.hp_animal_unit:PlayAnim("run", true)
    end
end
----HuntingSuccessPanel end

----HuntingFailPanel
function HuntingGroundUI:ShowHuntingFailPanel()
    self.hp_aim_point_cs.Is_scroll_bg_runing = false
    self.hp_aim_point_cs.is_auto_shoot = false
    self.close_hunting_fail_panel_timer = self:AddTimer(function ()
        self.close_hunting_fail_panel_timer = nil
        self:HideHuntingFailPanel()
    end, kPanelAutoCloseTime)
    self.hunting_fail_panel:SetActive(true)
    self.hp_animal_unit_parent:SetActive(false)
end

function HuntingGroundUI:HideHuntingFailPanel()
    if self.close_hunting_fail_panel_timer then
        self:RemoveTimer(self.close_hunting_fail_panel_timer)
        self.close_hunting_fail_panel_timer = nil
    end
    self.hp_animal_unit_parent:SetActive(true)
    self.hp_aim_point_cs:Reset()
    self.hunting_fail_panel:SetActive(false)
    self:HideHuntingPanel()
end
----HuntingFailPanel end

return HuntingGroundUI
