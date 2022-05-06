local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local UnitConst = require("Unit.UnitConst")
local DyDataConst = require("DynamicData.DyDataConst")
local GConst = require("GlobalConst")

local MainSceneUI = class("UI.MainSceneUI",UIBase)

local kExpMaxWidth = 132.5
local kMiddleIndex = 5
local kBottomIndex = 7
local kFoldTime = 0.2
local kFoldPos = 500
local kExpandPos = -9
local kFoldRot = Quaternion.Euler(0, 0, 0)
local kExpandRot = Quaternion.Euler(0, 0, 45)

local kStaticGuardCount = 2
local kActiveGuardCount = 2
local kSelfSoldierCountInCar = 4
local kEnemyCount = 3

local kActiveGuardShootDelay = 2.3
local kAnimEndDelay = 15.5
local kEnemyInitDelay = 2.5
local kGuardInitDelay = 2.5
local kEnemyDieDelay = 11
local kEnemyDieEnd = 13
local kGuardDieDelay = 9
local kGuardDieEnd = 12
local kSelfCarDestroyTime = 11.7
local kEnemyCarDestroyTime = 10.2
local kStaticShootInterval = 3
local kBattleInterval = 30

local kWalkingDogAnimTime = 20

local kDoorCloseRotate = Quaternion.Euler(0, 0, 0)
local kLeftDoorOpenRotate = Quaternion.Euler(0, 82.6, 5.1)
local kRightDoorOpenRotate = Quaternion.Euler(0, 72, -15)
local kDoorAnimTime = 1

function MainSceneUI:DoInit()
    MainSceneUI.super.DoInit(self)
    self.prefab_path = "UI/Common/MainSceneUI"
    self.pop_btn_tb = {}
    self.activity_go_dict = {}
    self.pop_timer = {}
    self.fold_timer = 0
    self.is_folded = true

    self.static_guard_anim_list = {}
    self.active_guard_list = {}
    self.guard_in_car_list = {}
    self.guard_list = {}
    self.guard_die_timer_dict = {}
    self.enemy_in_car_list = {}
    self.enemy_list = {}
    self.enemy_die_timer_dict = {}

    self.tl_activity_btn_list = {}
    self.cur_red_point_list = {}

    self.dy_dynasty_data = ComMgrs.dy_data_mgr.dynasty_data
    self.dy_task_data = ComMgrs.dy_data_mgr.task_data
    self.dy_mail_data = ComMgrs.dy_data_mgr.mail_data
    self.dy_activity_data = ComMgrs.dy_data_mgr.activity_data
    self.dy_recharge_data = ComMgrs.dy_data_mgr.recharge_data
    self.dy_tl_activity_data = ComMgrs.dy_data_mgr.tl_activity_data
    self.dy_vip_data = ComMgrs.dy_data_mgr.vip_data

    self.rank_activity_refresh_interval = SpecMgrs.data_mgr:GetParamData("rush_list_activity_rank_refresh_sec").f_value
end

function MainSceneUI:OnGoLoadedOk(res_go)
    MainSceneUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function MainSceneUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    MainSceneUI.super.Show(self)
end

function MainSceneUI:Hide()
    if self.static_shoot_timer then
        self:RemoveTimer(self.static_shoot_timer)
        self.static_shoot_timer = nil
    end
    if self.battle_anim_timer then
        self:RemoveTimer(self.battle_anim_timer)
        self.battle_anim_timer = nil
    end
    self:ClearRedPointList()
    self:MoveUnitToCar()
    self:ClearAnimTimer()
    self:ClearWalkingDogTimer()
    self:ClearTimeLimitActivityBtn()
    self:ClearRankActivityRefreshTimer()
    self:RemoveDynamicUI(self.rank_activity_left_time)
    ComMgrs.dy_data_mgr:UnregisterUpdateRoleInfoEvent("MainSceneUI")
    ComMgrs.dy_data_mgr:UnregisterUpdateLoverGiftInfoEvent("MainSceneUI")
    self.dy_task_data:UnregisterUpdateTaskInfoEvent("MainSceneUI")
    self.dy_activity_data:UnregisterUpdateActivityStateEvent("MainSceneUI")
    self.dy_activity_data:UnregisterUpdateRankActivityStateEvent("MainSceneUI")
    self.dy_activity_data:UnregisterUpdateRankActivityRankingEvent("MainSceneUI")
    self.dy_tl_activity_data:UnregisterUpdateRechargeActivitySwitch("MainSceneUI")
    MainSceneUI.super.Hide(self)
end

function MainSceneUI:InitRes()
    local bg = self.go:FindChild("Bg")
    -- 脑抽2人组
    local static_guard_list = bg:FindChild("StaticGuardList")
    for i = 1, kStaticGuardCount do
        table.insert(self.static_guard_anim_list, static_guard_list:FindChild("Guard" .. i):GetComponent("SkeletonGraphic").AnimationState)
    end
    -- 参与打枪的门卫
    local active_guard_list = bg:FindChild("ActiveGuardList")
    for i = 1, kActiveGuardCount do
        local guard_unit = active_guard_list:FindChild("Guard" .. i)
        table.insert(self.active_guard_list, guard_unit:GetComponent("SkeletonGraphic").AnimationState)
    end
    self.anim_content = self.go:FindChild("Bg/Anim")
    -- 己方车上的人
    local guard_in_car = self.anim_content:FindChild("GuardInCar")
    for i = 1, kSelfSoldierCountInCar do
        local guard_data = {}
        local guard_go = self.anim_content:FindChild("Guard" .. i)
        guard_data.go = guard_go
        guard_data.anim_cmp = guard_go:GetComponent("SkeletonGraphic").AnimationState
        table.insert(self.guard_in_car_list, guard_data)
        guard_go:SetActive(false)
    end
    -- 敌方车上的人
    local enemy_list = self.anim_content:FindChild("EnemyList")
    for i = 1, kEnemyCount do
        local enemy_data = {}
        local enemy_go = self.anim_content:FindChild("Enemy" .. i)
        enemy_data.go = enemy_go
        enemy_data.anim_cmp = enemy_go:GetComponent("SkeletonGraphic").AnimationState
        table.insert(self.enemy_in_car_list, enemy_data)
        enemy_go:SetActive(false)
    end
    self.left_dog = bg:FindChild("LeftLiugou")
    self.left_walking_dog_anim = self.left_dog:GetComponent("SkeletonGraphic").AnimationState
    self.right_dog = bg:FindChild("RightLiugou")
    self.right_walking_dog_anim = self.right_dog:GetComponent("SkeletonGraphic").AnimationState
    self.self_car_anim = self.anim_content:FindChild("SelfCar"):GetComponent("SkeletonGraphic").AnimationState
    self.enemy_car_anim = self.anim_content:FindChild("EnemyCar"):GetComponent("SkeletonGraphic").AnimationState
    self.left_door_cmp = bg:FindChild("LeftDoor"):GetComponent("Transform")
    self.right_door_cmp = bg:FindChild("RightDoor"):GetComponent("Transform")

    -- 玩家信息
    self.player_info_panel = self.main_panel:FindChild("PlayerInfoPanel")
    self.avator = self.player_info_panel:FindChild("Avator/Image"):GetComponent("Image")
    self:AddClick(self.player_info_panel:FindChild("Avator/Image"), function ()
        SpecMgrs.ui_mgr:ShowUI("PlayerInfoUI")
    end)
    self.vip = self.player_info_panel:FindChild("Vip")
    self.vip_img = self.vip:GetComponent("Image")
    self.lv = self.player_info_panel:FindChild("Lv"):GetComponent("Text")
    self.name = self.player_info_panel:FindChild("Name"):GetComponent("Text")
    self.ce = self.player_info_panel:FindChild("CE/Value"):GetComponent("Text")
    self.score = self.player_info_panel:FindChild("Score/Value"):GetComponent("Text")
    self.cur_exp = self.player_info_panel:FindChild("EXP_Bar/CurExp"):GetComponent("RectTransform")
    self.exp_height = self.cur_exp.sizeDelta.y
    self.money = self.player_info_panel:FindChild("Money/Count"):GetComponent("Text")
    self.food = self.player_info_panel:FindChild("Food/Count"):GetComponent("Text")
    self.numerous = self.player_info_panel:FindChild("Numerous/Count"):GetComponent("Text")
    self.diamond = self.player_info_panel:FindChild("Diamond/Count/Text"):GetComponent("Text")
    self:AddClick(self.player_info_panel:FindChild("Diamond"), function ()
        SpecMgrs.ui_mgr:ShowRechargeUI()
    end)

    -- 游戏场景功能UI
    local game_scene_panel = self.main_panel:FindChild("GameScenePanel")
    self.entertainment_btn = game_scene_panel:FindChild("Entertainment")
    self.entertainment_btn:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.ENTERTAINMENT_TEXT
    self:AddClick(self.entertainment_btn,function ()
        SpecMgrs.stage_mgr:GotoStage("EntertainmentStage")
    end)

    self.church_btn = game_scene_panel:FindChild("Church")
    self.church_btn:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.CHURCH_TEXT
    self:AddClick(self.church_btn,function ()
        SpecMgrs.ui_mgr:ShowUI("ChurchUI")
    end)

    self.bar_btn = game_scene_panel:FindChild("Bar")
    self.bar_btn:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.BAR_TEXT
    self:AddClick(self.bar_btn,function ()
        SpecMgrs.ui_mgr:ShowUI("BarUI")
    end)

    self.dynasty_btn = game_scene_panel:FindChild("Dynasty")
    self.dynasty_btn:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_TEXT
    self:AddClick(self.dynasty_btn,function ()
        -- SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.FUNC_LOCK_TIP)
        local dy_dynasty_id = self.dy_dynasty_data:GetDynastyId()
        if dy_dynasty_id then
            SpecMgrs.ui_mgr:ShowUI("DynastyUI")
        else
            SpecMgrs.ui_mgr:ShowUI("JoinDynastyUI")
        end
    end)

    self.night_club_btn = game_scene_panel:FindChild("NightClub")
    self.night_club_btn:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.NIGHTCLUB_TEXT
    self:AddClick(self.night_club_btn,function ()
        SpecMgrs.ui_mgr:ShowUI("NightClubUI")
    end)

    self.headquarters_btn = game_scene_panel:FindChild("Headquarters")
    self.headquarters_btn:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.HEADQUARTERS_TEXT
    self:AddClick(self.headquarters_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("GreatHallUI")
    end)

    self.big_map_btn = game_scene_panel:FindChild("BigMap")
    self.big_map_btn:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.BIG_MAP_TEXT
    self:AddClick(self.big_map_btn,function ()
        SpecMgrs.stage_mgr:GotoStage("BigMapStage")
    end)

    -- 固定活动
    local scene_menu_panel = self.main_panel:FindChild("SceneMenuPanel")
    local fixed_activity_panel = scene_menu_panel:FindChild("FixedActivityPanel")
    self.time_limit_activity_btn = fixed_activity_panel:FindChild("TLActivity")
    self.time_limit_activity_btn:FindChild("TextBg/Text"):GetComponent("Text").text = UIConst.Text.TIME_LIMIT_ACTIVITY
    self:AddClick(self.time_limit_activity_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("TLActivityUI")
    end)

    local server_open_activity_btn = fixed_activity_panel:FindChild("SOActivity")
    server_open_activity_btn:FindChild("TextBg/Text"):GetComponent("Text").text = UIConst.Text.SERVER_OPEN_ACTIVITY
    self:AddClick(server_open_activity_btn, function ()
        -- TODO 打开开服活动中心
    end)
    -- 当前活动
    self.cur_activity_panel = scene_menu_panel:FindChild("CurActivityPanel")
    -- 首周签到
    self.first_week_check_btn = self.cur_activity_panel:FindChild("FirstWeekCheck")
    -- 限时活动
    self.tl_activity_btn = self.cur_activity_panel:FindChild("TLActivity")
    local first_pay_activity_btn = self.cur_activity_panel:FindChild("FirstPayActivity")
    first_pay_activity_btn:FindChild("TextBg/Text"):GetComponent("Text").text = UIConst.Text.FIRST_PAY_ACTIVITY
    self:AddClick(first_pay_activity_btn, function ()
        -- TODO 首冲活动入口
    end)
    self:AddClick(scene_menu_panel:FindChild("Recharge"), function ()
        SpecMgrs.ui_mgr:ShowRechargeUI()
    end)

    self:AddClick(scene_menu_panel:FindChild("VipBtn"), function ()
        SpecMgrs.ui_mgr:ShowUI("VipUI")
    end)

    self.tl_activity_btn:SetActive(false)
    self.first_week_check_btn:SetActive(false)

    self.lover_gift_btn = scene_menu_panel:FindChild("LoverGift")
    self:AddClick(self.lover_gift_btn, function ()
        SpecMgrs.ui_mgr:ShowLoadingUI();
        SpecMgrs.msg_mgr:SendLoverGift({}, function (resp)
            print("情人礼包返回值----",resp)
            SpecMgrs.ui_mgr:HideUI("LoadingUI")
            if #resp.activity_list == 0 then
                SpecMgrs.ui_mgr:ShowMsgBox("礼包已购买完毕，敬请期待！")
            else
                SpecMgrs.ui_mgr:ShowUI("LoverGiftUI",resp)
            end
        end)
    end)

    --英雄礼包
    self.hero_gift_btn = scene_menu_panel:FindChild("HeroGift")
    self:AddClick(self.hero_gift_btn, function ()
        SpecMgrs.ui_mgr:ShowLoadingUI();
        SpecMgrs.msg_mgr:SendHeroGift({}, function (resp)
            print("英雄礼包返回值----",resp)
            SpecMgrs.ui_mgr:HideUI("LoadingUI")
            if #resp.activity_list == 0 then
                SpecMgrs.ui_mgr:ShowMsgBox("礼包已购买完毕，敬请期待！")
            else
                SpecMgrs.ui_mgr:ShowUI("HeroGiftUI",resp)
            end
        end)
        --SpecMgrs.ui_mgr:ShowUI("HeroGiftUI")
    end)

    --测试视频
    self.lover_test_btn = scene_menu_panel:FindChild("LoverGiftTest")
    self:AddClick(self.lover_test_btn, function ()
        print("测试视频-----")
        SpecMgrs.msg_mgr:SendPurchasedLoverVideos({}, function (resp)
            print("激情视频返回值----",resp)
            SpecMgrs.ui_mgr:ShowUI("LoverVideosUI",resp)
        end)
        --SpecMgrs.ui_mgr:ShowUI("LoverGiftTestUI")
    end)

    --总排行榜
    self.rank_main_btn = scene_menu_panel:FindChild("Ranking")
    self:AddClick(self.rank_main_btn, function ()
        SpecMgrs.msg_mgr:SendGetPowerRank({}, function (resp)
            print("总排行榜数据内容----",resp)
            SpecMgrs.ui_mgr:ShowUI("RankMainUI",resp)
        end)
    end)

    -- 主线任务
    self.mail_tip_btn = scene_menu_panel:FindChild("MailTip")
    self.mail_tip_btn:FindChild("TextBg/Text"):GetComponent("Text").text = UIConst.Text.MAIL_TIP_TEXT
    self:AddClick(self.mail_tip_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("MailboxUI")
    end)
    self.agency_mission_btn = scene_menu_panel:FindChild("AgencyMission")
    self:AddClick(self.agency_mission_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("TaskUI")
    end)
    local mission_info = self.agency_mission_btn:FindChild("MissionInfo/Mission")
    self.mission_info_width_limit = mission_info:GetComponent("RectTransform").rect.width
    local mission_desc = mission_info:FindChild("Desc")
    self.mission_desc_text = mission_desc:GetComponent("TextPic")
    self.mission_desc_rect_cmp = mission_desc:GetComponent("RectTransform")
    self.mission_desc_height = self.mission_desc_rect_cmp.rect.height
    self.mission_progress = mission_info:FindChild("Progress"):GetComponent("Text")
    self.mission_pop = self.agency_mission_btn:FindChild("MissionInfo/Pop")
    self.mission_pop_tween = self.mission_pop:GetComponent("UITweenAlpha")
    self.mission_pop_text = self.mission_pop:FindChild("BubbleDialog/Text"):GetComponent("Text")
    self.mission_guide_arrow = self.agency_mission_btn:FindChild("MissionInfo/GuideArrowEffect")
    self.mission_guide_arrow_tween = self.mission_guide_arrow:GetComponent("UITweenAlpha")
    self.mission_finish = self.agency_mission_btn:FindChild("Finish")
    self.cur_mission = self.agency_mission_btn:FindChild("CurMission")
    self.mission_item = self.agency_mission_btn:FindChild("MissionIcon/Image/Item")
    -- 限时冲榜
    self.rank_activity_btn = scene_menu_panel:FindChild("RankActivity")
    self.rank_activity_icon = self.rank_activity_btn:FindChild("Icon/Img"):GetComponent("Image")
    self.rank_activity_title = self.rank_activity_btn:FindChild("Title"):GetComponent("Text")
    self.self_ranking = self.rank_activity_btn:FindChild("RankText/Ranking"):GetComponent("Text")
    self.rank_activity_left_time = self.rank_activity_btn:FindChild("RankText/LeftTime")
    self.rank_activity_left_time_text = self.rank_activity_left_time:GetComponent("Text")
    self:AddClick(self.rank_activity_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("RankActivityUI", self.cur_rank_activity_id)
    end)

    self.fold_btn = scene_menu_panel:FindChild("FoldBtn")
    self:AddClick(self.fold_btn, function ()
        if self.is_folding then return end
        self.from_pos_x = self.is_folded and kFoldPos or kExpandPos
        self.target_pos_x = self.is_folded and kExpandPos or kFoldPos
        self.from_rot = self.is_folded and kFoldRot or kExpandRot
        self.target_rot = self.is_folded and kExpandRot or kFoldRot
        self.is_folding = true
    end)
    self.fold_panel = scene_menu_panel:FindChild("FoldPanel")
    local btn_list = self.fold_panel:FindChild("BtnList")
    self.btn_list_rect = btn_list:GetComponent("RectTransform")
    self:AddClick(btn_list:FindChild("SettingBtn"), function ()
        SpecMgrs.ui_mgr:ShowUI("SettingUI")
    end)

    local friend_btn = btn_list:FindChild("FriendBtn")
    self:AddClick(friend_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("FriendUI")
    end)

    self:AddClick(btn_list:FindChild("DecomposeBtn"), function ()
        SpecMgrs.ui_mgr:ShowUI("DecomposeUI")
    end)
    self:AddClick(btn_list:FindChild("MailBtn"), function ()
        SpecMgrs.ui_mgr:ShowUI("MailboxUI")
    end)
    self:AddClick(btn_list:FindChild("Title"), function ()
        SpecMgrs.ui_mgr:ShowUI("TitleUI")
    end)

    --  商店入口
    self.shop_panel = self.main_panel:FindChild("SceneMenuPanel/ShopPanel")
    self.shop_panel_tween = self.shop_panel:GetComponent("UITweenPosition")

    self:AddClick(self.shop_panel:FindChild("AppearBtn"), function()
        self:MoveShopPanel()
    end)

    self.shop_panel_title = self.shop_panel:FindChild("ShopTitle"):GetComponent("Text")
    self.shop_text = self.shop_panel:FindChild("AppearBtn/ShopText"):GetComponent("Text")
    self.appear_tip = self.shop_panel:FindChild("AppearBtn/AppearTip")

    self.shop_item = self.shop_panel:FindChild("ScrollView/ViewPort/Content/ShopItem")
    self.shop_content = self.shop_panel:FindChild("ScrollView/ViewPort/Content")
    self.shop_item:SetActive(false)

    self.shop_panel_start_pos = self.shop_panel:GetComponent("RectTransform").anchoredPosition
end

function MainSceneUI:InitUI()
    SpecMgrs.ui_mgr:ShowUI("GameMenuUI")
    self.anim_content:SetActive(false)
    ComMgrs.dy_data_mgr:RegisterUpdateRoleInfoEvent("MainSceneUI", self.UpdateRoleImformation, self)
    self.dy_task_data:RegisterUpdateTaskInfoEvent("MainSceneUI", self.UpdateTaskInfo, self)
    self.dy_activity_data:RegisterUpdateActivityStateEvent("MainSceneUI", self.UpdateActivityState, self)
    self.dy_activity_data:RegisterUpdateRankActivityStateEvent("MainSceneUI", self.UpdateRankActivityState, self)
    self.dy_activity_data:RegisterUpdateRankActivityRankingEvent("MainSceneUI", self.UpdateRankActivityRank, self)
    self.dy_tl_activity_data:RegisterUpdateRechargeActivitySwitch("MainSceneUI", self.UpdateRechargeActivityState, self)
    ComMgrs.dy_data_mgr:RegisterUpdateLoverGiftInfoEvent("MainSceneUI", self.UpdateLoverGiftBtnStatus, self)
    ComMgrs.dy_data_mgr:RegisterUpdateHeroGiftInfoEvent("MainSceneUI", self.UpdateHeroGiftBtnStatus, self)

    self:RegisterEvent(self.dy_mail_data, "AddMailEvent", function ()
        self.mail_tip_btn:SetActive(self.dy_mail_data:CheckHaveAttachmentMail())
    end)
    self:RegisterEvent(self.dy_mail_data, "UpdateMailEvent", function ()
        self.mail_tip_btn:SetActive(self.dy_mail_data:CheckHaveAttachmentMail())
    end)
    self:RegisterEvent(self.dy_vip_data, "UpdateVipInfo", function (_, vip_info)
        if vip_info.vip_level then
            local vip_data = SpecMgrs.data_mgr:GetVipData(vip_info.vip_level)
            self.vip:SetActive(vip_data ~= nil)
            if vip_data then UIFuncs.AssignSpriteByIconID(vip_data.icon, self.vip_img) end
        end
    end)
    self:PlayLeftWalkingDogAnim()
    self:PlayRightWalkingDogAnim()
    self:InitStaticGuardAnim()
    self:InitBattleAnim()
    self:InitPlayerInfo()
    self:InitFoldState()
    self:InitActivityState()
    self.dy_activity_data:RefreshRankActivity()
    self.rank_activity_refresh_timer = self:AddTimer(function ()
        local rank_activity_list = self.dy_activity_data:GetRankActivityList()
        self.dy_activity_data:RefreshRankActivity(rank_activity_list[#rank_activity_list])
    end, self.rank_activity_refresh_interval, 0)
    self:InitRankActivityState()
    -- TODO 初始化限时冲榜
    self:UpdateTaskInfo()
    self.mail_tip_btn:SetActive(self.dy_mail_data:CheckHaveAttachmentMail())
    self:InitShopPanel()

    self.lover_gift_info = ComMgrs.dy_data_mgr:ExGeLoverGiftInfo()
    if #self.lover_gift_info.activity_list ~= 0 then
        print("情人礼包显示出来-----")
        self.lover_gift_btn_status = true
        self.lover_gift_btn:SetActive(true)
    else
        print("情人礼包不显示-----")
        self.lover_gift_btn_status = false
        self.lover_gift_btn:SetActive(false)
    end

    self.hero_gift_info = ComMgrs.dy_data_mgr:ExGeHeroGiftInfo()
    if #self.hero_gift_info.activity_list ~= 0 then
        print("英雄礼包显示出来-----")
        self.hero_gift_btn_status = true
        self.hero_gift_btn:SetActive(true)
    else
        print("英雄礼包不显示-----")
        self.hero_gift_btn_status = false
        self.hero_gift_btn:SetActive(false)
    end


end

--  商店
function MainSceneUI:InitShopPanel()
    self.shop_panel:GetComponent("RectTransform").anchoredPosition = self.shop_panel_start_pos
    self.is_move_shop_panel = false
    self.shop_panel_is_move_out = false
    self.shop_text.text = UIConst.Text.SHOP_TEXT
    self.shop_panel_title.text = UIConst.Text.SHOP_TEXT
    local shop_list = SpecMgrs.data_mgr:GetAllMainScenceShopData()
    for i, data in ipairs(shop_list) do
        local item = self:GetUIObject(self.shop_item, self.shop_content)
        local shop_data = SpecMgrs.data_mgr:GetShopData(data.shop_data)
        item:FindChild("ShopName"):GetComponent("Text").text = shop_data.shop_name
        item:FindChild("TurnBtn/Text"):GetComponent("Text").text = UIConst.Text.GOTO_TEXT
        local image_cmp = item:FindChild("ShopIcon"):GetComponent("Image")
        self:AssignSpriteByIconID(data.icon, image_cmp)
        image_cmp:SetNativeSize()
        self:AddClick(item:FindChild("TurnBtn"), function()
            SpecMgrs.ui_mgr:ShowUI("ShoppingUI", shop_data.id)
        end)
    end
end

function MainSceneUI:MoveShopPanel()
    if self.is_move_shop_panel then
        return
    end
    if self.shop_panel_is_move_out then
        self.shop_panel_tween.from_ = Vector3.New(0, self.shop_panel_start_pos.y, 0)
        self.shop_panel_tween.to_ = self.shop_panel_start_pos
        self.appear_tip.localScale = Vector3.New(1, 1, 1)
    else
        self.shop_panel_tween.from_ = self.shop_panel_start_pos
        self.shop_panel_tween.to_ = Vector3.New(0, self.shop_panel_start_pos.y, 0)
        self.appear_tip.localScale = Vector3.New(1, -1, 1)
    end

    self.shop_panel_tween:Play()
    self.is_move_shop_panel = true
    self:AddTimer(function()
        self.is_move_shop_panel = false
        self.shop_panel_is_move_out = not self.shop_panel_is_move_out
    end, self.shop_panel_tween.duration_, 1)
end
--  商店

function MainSceneUI:InitActivityState()
    self:ClearRedPointList()
    self:ClearTimeLimitActivityBtn()
    local activity_system_name_list = {}
    --主界面上的精良装备、神秘宝箱、性感佳人、精锐头目、充值抽奖，在这里被实例化
    for _, activity_data in ipairs(self.dy_tl_activity_data:GetOpenActivityList()) do
        if activity_data.is_show_in_mainscence and activity_data.system_name then
            local tl_activity_btn = self:GetUIObject(self.tl_activity_btn, self.cur_activity_panel)
            local activity_btn_data = {item = tl_activity_btn}
            UIFuncs.AssignSpriteByIconID(activity_data.icon, tl_activity_btn:FindChild("Icon"):GetComponent("Image"))
            tl_activity_btn:FindChild("TextBg/Text"):GetComponent("Text").text = activity_data.activity_name
            if activity_data.effect then
                activity_btn_data.effect = self:AddUIEffect(tl_activity_btn:FindChild("Effect"), {
                    effect_id = activity_data.effect,
                    offset_tb = {0, 0, 0, 0},
                    need_sync_load = true,
                })
            end
            table.insert(self.tl_activity_btn_list, activity_btn_data)
            self:AddClick(tl_activity_btn, function ()
                SpecMgrs.ui_mgr:ShowTLAvtivity(activity_data.id)
            end)
            local redpoint = SpecMgrs.redpoint_mgr:AddRedPoint(self, tl_activity_btn, 1, {activity_data.system_name})
            table.insert(self.cur_red_point_list, redpoint)
        end
        if activity_data.system_name then
            table.insert(activity_system_name_list, activity_data.system_name)
        end
    end
    local redpoint = SpecMgrs.redpoint_mgr:AddRedPoint(self, self.time_limit_activity_btn, 1, activity_system_name_list)
    table.insert(self.cur_red_point_list, redpoint)
    local is_open = ComMgrs.dy_data_mgr.check_data:CheckFirstWeekCheckOpen()
    self.first_week_check_btn:SetActive(is_open)
    if is_open then
        local data
        local welfare_list = SpecMgrs.data_mgr:GetAllWelfareData()
        for i,v in ipairs(welfare_list) do
            if v.type == CSConst.kWelfareIndexDict.FirstWeekReward then
                data = v
            end
        end
        if data then
            UIFuncs.AssignSpriteByIconID(data.icon, self.first_week_check_btn:FindChild("Icon"):GetComponent("Image"))
            self.first_week_check_btn:FindChild("TextBg/Text"):GetComponent("Text").text = data.name
        end
        self:AddClick(self.first_week_check_btn, function()
            SpecMgrs.ui_mgr:ShowUI("WelfareUI", CSConst.kWelfareIndexDict.FirstWeekReward)
        end)
    end
end

function MainSceneUI:UpdateRechargeActivityState()
    self:InitActivityState()
end

function MainSceneUI:UpdateActivityState(_, activity_id, state)
    if state == CSConst.ActivityState.started or state == CSConst.ActivityState.invalid then
        self:InitActivityState()
    end
end

function MainSceneUI:InitRankActivityState()
    -- 冲榜活动
    local rank_activity_list = self.dy_activity_data:GetRankActivityList()
    local rank_activity_count = #rank_activity_list
    self.rank_activity_btn:SetActive(rank_activity_count > 0)
    if rank_activity_count > 0 then
        self.cur_rank_activity_id = rank_activity_list[rank_activity_count]
        local rank_activity_data = SpecMgrs.data_mgr:GetRushActivityData(self.cur_rank_activity_id)
        local rank_activity_info = self.dy_activity_data:GetRankActivityInfo(self.cur_rank_activity_id)
        UIFuncs.AssignSpriteByIconID(rank_activity_data.unit_icon, self.rank_activity_icon)
        self.rank_activity_title.text = rank_activity_data.name
        if rank_activity_info.self_rank then
            self.self_ranking.text = string.format(UIConst.Text.DYNASTY_RANK_FROMAT, rank_activity_info.self_rank)
        else
            self.self_ranking.text = UIConst.Text.WITHOUT_RANK
        end
        if rank_activity_info.state == CSConst.ActivityState.started then
            self:AddDynamicUI(self.rank_activity_left_time, function ()
                self.rank_activity_left_time_text.text = UIFuncs.TimeDelta2Str(rank_activity_info.stop_ts - Time:GetServerTime(), 4, UIConst.LongCDRemainFormat)
            end, 1, 0)
        else
            self.rank_activity_left_time_text.text = UIConst.Text.ALREADY_FINISH_TEXT
        end
    end
end

function MainSceneUI:UpdateRankActivityRank(_, activity_id, rank)
    if activity_id == self.cur_rank_activity_id then
        self.self_ranking.text = rank and string.format(UIConst.Text.DYNASTY_RANK_FROMAT, rank) or UIConst.Text.WITHOUT_RANK
    end
end

function MainSceneUI:UpdateRankActivityState(_, activity_id)
    if self.dy_activity_data:GetNewestRankActivity() ~= self.cur_rank_activity_id then
        self:InitRankActivityState()
        return
    end
    if activity_id == self.cur_rank_activity_id then
        self:InitRankActivityState()
    end
end

function MainSceneUI:InitPlayerInfo()
    local role_info = ComMgrs.dy_data_mgr.main_role_info
    local unit_id = SpecMgrs.data_mgr:GetRoleLookData(role_info.role_id).unit_id
    UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetUnitData(unit_id).icon, self.avator)
    self.lv.text = string.format(UIConst.Text.LV, role_info.level)
    self.name.text = role_info.name
    self.ce.text = UIFuncs.AddCountUnit(role_info.fight_score or 0)
    self.score.text = UIFuncs.AddCountUnit(role_info.score or 0)
    local vip_data = SpecMgrs.data_mgr:GetVipData(ComMgrs.dy_data_mgr:ExGetRoleVip())
    self.vip:SetActive(vip_data ~= nil)
    if vip_data then UIFuncs.AssignSpriteByIconID(vip_data.icon, self.vip_img) end
    local level_data = SpecMgrs.data_mgr:GetLevelData(role_info.level)
    self.cur_exp.sizeDelta = Vector2.New((role_info.exp - level_data.total_exp) / level_data.exp * kExpMaxWidth, self.exp_height)
    self:UpdateCurrencyCount(role_info.currency)
end

function MainSceneUI:UpdateTaskInfo()
    local task_group_data = self.dy_task_data:GetCurTaskGroup()
    if task_group_data then
        local cur_task_info = self.dy_task_data:GetCurTaskInfo()
        if cur_task_info then
            local task_data = SpecMgrs.data_mgr:GetTaskData(cur_task_info.task_id)
            local cur_group_data = self.dy_task_data:GetCurTaskGroup()
            local task_desc = self.dy_task_data:GetTaskDesc(task_data)
            local mission_progress = task_data.task_param[#task_data.task_param]
            self.mission_finish:SetActive(cur_task_info.is_finish == true)
            self.cur_mission:SetActive(cur_task_info.is_finish ~= true)
            local mission_state_text = cur_task_info.is_finish and UIConst.Text.MISSION_COMPLETE_TEXT or string.format(UIConst.Text.MISSION_PROGRESS_FORMAT, cur_task_info.progress, mission_progress)
            self.mission_progress.text = mission_state_text
            local mission_desc_width_limit = self.mission_info_width_limit - self.mission_progress.preferredWidth
            self.mission_desc_rect_cmp.sizeDelta = Vector2.New(mission_desc_width_limit, self.mission_desc_height)
            self.mission_desc_text:SetTextWithEllipsis(task_desc)
            self.mission_desc_rect_cmp.sizeDelta = Vector2.New(self.mission_desc_text.preferredWidth, self.mission_desc_height)
            local reward_data = SpecMgrs.data_mgr:GetRewardData(cur_group_data.reward_id)
            UIFuncs.InitItemGo({
                go = self.mission_item,
                item_id = reward_data.reward_item_list[1],
                ignore_bg_and_frame = true,
            })
            if not cur_task_info.is_finish then
                self:_UpdateMissionPop(task_data.pop_content)
            else
                self:_UpdateMissionPop(nil)
            end
        else
            self.cur_mission:SetActive(false)
            self.mission_finish:SetActive(true)
            self.mission_desc_text.text = task_group_data.desc
            self.mission_desc_rect_cmp.sizeDelta = Vector2.New(self.mission_desc_text.preferredWidth, self.mission_desc_height)
            self.mission_progress.text = UIConst.Text.MISSION_COMPLETE_TEXT
        end
    end
    self.agency_mission_btn:SetActive(task_group_data ~= nil)
end

--播放任务引导动画
function MainSceneUI:_UpdateMissionPop(pop_content)
    if self.mission_pop_timer then
        self:RemoveTimer(self.mission_pop_timer)
        self.mission_pop_timer = nil
    end
    if self.mission_guide_arrow_timer then
        self:RemoveTimer(self.mission_guide_arrow_timer)
        self.mission_guide_arrow_timer = nil
    end
    self.mission_pop:SetActive(false)
    self.mission_guide_arrow:SetActive(false)
    if not pop_content then
        return
    end
    local func_loop = function(timer, tween)
        if IsNil(self.go) then
            self:RemoveTimer(timer)
            return
        end
        tween:Play()
    end
    self.mission_pop_text.text = pop_content
    self.mission_pop:SetActive(true)
    self.mission_pop_tween:Play()
    self.mission_pop_timer = self:AddTimer(function(timer)
        func_loop(timer, self.mission_pop_tween)
    end, 12, 0)
    local func_before_loop = function()
        if IsNil(self.go) then
            self:RemoveTimer(self.mission_guide_arrow_timer)
            self.mission_guide_arrow_timer = nil
            return
        end
        self.mission_guide_arrow:SetActive(true)
        self.mission_guide_arrow_tween:Play()
        self.mission_guide_arrow_timer = self:AddTimer(function(timer)
            func_loop(timer, self.mission_guide_arrow_tween)
        end, 12, 0)
    end
    self.mission_guide_arrow_timer = self:AddTimer(func_before_loop, 6, 1)
end

function MainSceneUI:UpdateLoverGiftBtnStatus(_, data)
    self.lover_gift_info = data
    if #self.lover_gift_info.activity_list ~= 0 then
        self.lover_gift_btn_status = true
        self.lover_gift_btn:SetActive(true)
    else
        self.lover_gift_btn_status = false
        self.lover_gift_btn:SetActive(false)
    end

end

function MainSceneUI:UpdateHeroGiftBtnStatus(_, data)
    self.hero_gift_info = data
    if #self.hero_gift_info.activity_list ~= 0 then
        self.hero_gift_btn_status = true
        self.hero_gift_btn:SetActive(true)
    else
        self.hero_gift_btn_status = false
        self.hero_gift_btn:SetActive(false)
    end

end

function MainSceneUI:UpdateRoleImformation(_, data)
    if data.role_id then
        local unit_id = SpecMgrs.data_mgr:GetRoleLookData(data.role_id).unit_id
        UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetUnitData(unit_id).icon, self.avator)
    end
    if data.level then
        self.lv.text = string.format(UIConst.Text.LV, data.level)
    end
    self.name.text = data.name or self.name.text
    if data.score then self.score.text = UIFuncs.AddCountUnit(data.score) end
    if data.fight_score then self.ce.text = UIFuncs.AddCountUnit(data.fight_score) end
    if data.exp then
        local level_data = SpecMgrs.data_mgr:GetLevelData(ComMgrs.dy_data_mgr.main_role_info.level)
        self.cur_exp.sizeDelta = Vector2.New((data.exp - level_data.total_exp) / level_data.exp * kExpMaxWidth, self.exp_height)
    end
    if data.currency then self:UpdateCurrencyCount() end
end

function MainSceneUI:UpdateCurrencyCount()
    local currency_data = ComMgrs.dy_data_mgr:GetCurrencyData()
    self.money.text = UIFuncs.AddCountUnit(currency_data[CSConst.Virtual.Money] or 0)
    self.food.text = UIFuncs.AddCountUnit(currency_data[CSConst.Virtual.Food] or 0)
    self.numerous.text = UIFuncs.AddCountUnit(currency_data[CSConst.Virtual.Soldier] or 0)
    self.diamond.text = UIFuncs.AddCountUnit(currency_data[CSConst.Virtual.Diamond] or 0)
end

-- function MainSceneUI:InitDayOrNight()
--     self.zongbu_anim:PlayAnimation(0, "bai", true, 0)
--     self.anim_timer = SpecMgrs.timer_mgr:AddTimer(function ()
--         self.zongbu_anim:PlayAnimation(0, "baizhuanhei", false, 0)
--         self.zongbu_anim:AddAnim(0, "hei", true, 0 , 1)
--         self.day_type = DyDataConst.DayType.Night
--         SpecMgrs.timer_mgr:RemoveTimer(self.anim_timer)
--         self.anim_timer = nil
--     end, 2, 1)
--     self.day_timer = SpecMgrs.timer_mgr:AddTimer(function ()
--         self:UpdateDayOrNight()
--     end, 60, 0)
--     -- if ComMgrs.dy_data_mgr:ExGetDayOrNight() == DyDataConst.DayType.Day then
--     --     self.zongbu_anim:PlayAnimation(0, "bai", true, 0)
--     -- else
--     --     self.zongbu_anim:PlayAnimation(0, "hei", true, 0)
--     -- end
-- end

-- function MainSceneUI:UpdateDayOrNight()
--     -- if self.day_timer then
--     --     SpecMgrs.timer_mgr:RemoveTimer(self.day_timer)
--     --     self.day_timer = nil
--     -- end
--     if self.day_type == DyDataConst.DayType.Night then
--         self.zongbu_anim:AddAnim(0, "heizhuangbai", false, 0, 1)
--         self.zongbu_anim:AddAnim(0, "bai", true, 0 , 1)
--         self.day_type = DyDataConst.DayType.Day
--     else
--         self.zongbu_anim:PlayAnimation(0, "baizhuanhei", false, 0)
--         self.zongbu_anim:AddAnim(0, "hei", true, 0 , 1)
--         self.day_type = DyDataConst.DayType.Night
--     end
-- end

function MainSceneUI:Update(delta_time)
    if self.is_folding then
        self.fold_timer = self.fold_timer + delta_time
        local cur_pos = self.btn_list_rect.anchoredPosition
        cur_pos.x = math.lerp(self.from_pos_x, self.target_pos_x, self.fold_timer / kFoldTime)
        self.btn_list_rect.anchoredPosition = cur_pos
        self.fold_btn:GetComponent("RectTransform").rotation = Quaternion.Slerp(self.from_rot, self.target_rot, self.fold_timer / kFoldTime)
        if math.abs(cur_pos.x - self.target_pos_x) < 0.01 then
            self.is_folding = nil
            self.fold_timer = 0
            self.is_folded = not self.is_folded
        end
    end
    if self.door_timer then
        self.left_door_cmp.rotation = Quaternion.Slerp(self.left_from_rot, self.left_target_rot, self.door_timer / kDoorAnimTime)
        self.right_door_cmp.rotation = Quaternion.Slerp(self.right_from_rot, self.right_target_rot, self.door_timer / kDoorAnimTime)
        self.door_timer = self.door_timer + delta_time
        if self.door_timer > kDoorAnimTime then
            self.left_door_cmp.rotation = self.left_target_rot
            self.right_door_cmp.rotation = self.right_target_rot
            self.door_timer = nil
        end
    end
    
end

function MainSceneUI:InitFoldState()
    self.fold_btn:GetComponent("RectTransform").rotation = kFoldRot
    self.btn_list_rect.anchoredPosition = Vector2.New(kFoldPos, self.btn_list_rect.anchoredPosition.y)
end

function MainSceneUI:InitBattleAnim()
    self.battle_anim_timer = self:AddTimer(function ()
        self:PlayBattleAnim()
    end, kBattleInterval, 0)
end

function MainSceneUI:InitStaticGuardAnim()
    self.static_shoot_timer = self:AddTimer(function ()
        for i = 1, kStaticGuardCount do
            self.static_guard_anim_list[i]:PlayAnimation(0, "animation", false, 0.2)
            self.static_guard_anim_list[i]:AddAnim(0, "idle", true, 0, 0.2)
        end
    end, kStaticShootInterval, 0)
end

function MainSceneUI:PlayLeftWalkingDogAnim()
    if self.left_dog_timer or self.destroy_left_dog_timer then return end
    self.left_dog:SetActive(false)
    local random_time = math.random(0, kWalkingDogAnimTime)
    self.left_dog_timer = self:AddTimer(function ()
        self.left_walking_dog_anim:PlayAnimation(0, "animation", false, 0)
        self.left_dog:SetActive(true)
        self.destroy_left_dog_timer = self:AddTimer(function ()
            self.left_walking_dog_anim:SetEmptyAnimations(0)
            self.left_dog:SetActive(false)
            self.destroy_left_dog_timer = nil
            self:PlayLeftWalkingDogAnim()
        end, kWalkingDogAnimTime, 1)
        self.left_dog_timer = nil
    end, random_time)
end

function MainSceneUI:PlayRightWalkingDogAnim()
    if self.right_dog_timer or self.destroy_right_dog_timer then return end
    self.right_dog:SetActive(false)
    local random_time = math.random(0, kWalkingDogAnimTime)
    self.right_dog_timer = self:AddTimer(function ()
        self.right_walking_dog_anim:PlayAnimation(0, "animation", false, 0)
        self.right_dog:SetActive(true)
        self.destroy_right_dog_timer = self:AddTimer(function ()
            self.right_walking_dog_anim:SetEmptyAnimations(0)
            self.right_dog:SetActive(false)
            self.destroy_right_dog_timer = nil
            self:PlayRightWalkingDogAnim()
        end, kWalkingDogAnimTime, 1)
        self.right_dog_timer = nil
    end, random_time)
end

function MainSceneUI:PlayBattleAnim()
    self.anim_content:SetActive(true)
    self:PlayDoorAnim(true)
    self.enemy_car_anim.TimeScale = 0
    self.enemy_car_anim:PlayAnimation(0, "che", false, 0)
    self.self_car_anim.TimeScale = 0
    self.self_car_anim:PlayAnimation(0, "che", false, 0)
    
    self.active_guard_shoot_timer = self:AddTimer(function ()
        for _, guard_anim_cmp in ipairs(self.active_guard_list) do
            guard_anim_cmp:PlayAnimation(0, "animation", true, 0.2)
        end
        self.enemy_car_anim.TimeScale = 1
        self.self_car_anim.TimeScale = 1
        
        self.active_guard_shoot_timer = nil
    end, kActiveGuardShootDelay, 1)

    self.init_enemy_timer = self:AddTimer(function ()
        self.init_enemy_go_timer = self:AddTimer(function ()
            local random_index = math.random(#self.enemy_in_car_list)
            local enemy_data = table.remove(self.enemy_in_car_list, random_index)
            enemy_data.go:SetActive(true)
            enemy_data.anim_cmp:PlayAnimation(0, "animation", true, 0.2)
            table.insert(self.enemy_list, enemy_data)
            if #self.enemy_in_car_list == 0 then
                self.self_car_anim:PlayAnimation(0, "hit", true, 0)
                self.enemy_car_anim:PlayAnimation(0, "hit", true, 0)
                self.init_enemy_go_timer = nil
            end
            -- if #self.enemy_list == kEnemyCount then self.init_enemy_go_timer = nil end
        end, 0.1, kEnemyCount)
        self.init_enemy_timer = nil
    end, kEnemyInitDelay, 1)

    self.init_guard_timer = self:AddTimer(function ()
        self.init_guard_go_timer = self:AddTimer(function ()
            local random_index = math.random(#self.guard_in_car_list)
            local guard_data = table.remove(self.guard_in_car_list, random_index)
            guard_data.go:SetActive(true)
            guard_data.anim_cmp:PlayAnimation(0, "animation", true, 0.2)
            table.insert(self.guard_list, guard_data)
            if #self.guard_list == kSelfSoldierCountInCar then self.init_guard_go_timer = nil end
        end, 0.2, kSelfSoldierCountInCar)
        self.init_guard_timer = nil
    end, kGuardInitDelay, 1)

    for i = 1, kEnemyCount do
        local random_die_delay = math.Random(kEnemyDieDelay, kEnemyDieEnd)
        local timer = self:AddTimer(function ()
            local enemy_data = table.remove(self.enemy_list, 1)
            enemy_data.anim_cmp:SetEmptyAnimations(0)
            enemy_data.go:SetActive(false)
            table.insert(self.enemy_in_car_list, enemy_data)
            if #self.enemy_list == 0 then
                for _, guard_anim_cmp in ipairs(self.active_guard_list) do
                    guard_anim_cmp:PlayAnimation(0, "idle", true, 0.2)
                end
                self.self_car_anim:SetEmptyAnimations(0)
            end
            self.enemy_die_timer_dict[i] = nil
        end, random_die_delay, 1)
        self.enemy_die_timer_dict[i] = timer
    end

    for i = 1, kSelfSoldierCountInCar do
        local random_die_delay = math.Random(kGuardDieDelay, kGuardDieEnd)
        local timer = self:AddTimer(function ()
            local guard_data = table.remove(self.guard_list, 1)
            guard_data.anim_cmp:SetEmptyAnimations(0)
            guard_data.go:SetActive(false)
            table.insert(self.guard_in_car_list, guard_data)
            self.guard_die_timer_dict[i] = nil
        end, random_die_delay, 1)
        self.guard_die_timer_dict[i] = timer
    end

    self.enemy_car_destroy_timer = self:AddTimer(function ()
        self.enemy_car_anim:SetEmptyAnimations(0)
        self.enemy_car_destroy_timer = nil
    end, kEnemyCarDestroyTime, 1)

    self.self_car_destroy_timer = self:AddTimer(function ()
        self.self_car_anim:SetEmptyAnimations(0)
        self.self_car_destroy_timer = nil
    end, kSelfCarDestroyTime, 1)

    self.anim_end_timer = self:AddTimer(function ()
        self.anim_content:SetActive(false)
        self:PlayDoorAnim(false)
        self:ClearAnimTimer()
        self.anim_end_timer = nil
    end, kAnimEndDelay, 1)
end

function MainSceneUI:ClearAnimTimer()
    if self.active_guard_shoot_timer then
        self:RemoveTimer(self.active_guard_shoot_timer)
        self.active_guard_shoot_timer = nil
    end
    if self.init_enemy_timer then
        self:RemoveTimer(self.init_enemy_timer)
        self.init_enemy_timer = nil
    end
    if self.init_enemy_go_timer then
        self:RemoveTimer(self.init_enemy_go_timer)
        self.init_enemy_go_timer = nil
    end
    if self.init_guard_timer then
        self:RemoveTimer(self.init_guard_timer)
        self.init_guard_timer = nil
    end
    if self.init_guard_go_timer then
        self:RemoveTimer(self.init_guard_go_timer)
        self.init_guard_go_timer = nil
    end
    if self.enemy_car_destroy_timer then
        self:RemoveTimer(self.enemy_car_destroy_timer)
        self.enemy_car_destroy_timer = nil
    end
    if self.self_car_destroy_timer then
        self:RemoveTimer(self.self_car_destroy_timer)
        self.self_car_destroy_timer = nil
    end
    if self.anim_end_timer then
        self:RemoveTimer(self.anim_end_timer)
        self.anim_end_timer = nil
    end

    for _, timer in pairs(self.guard_die_timer_dict) do
        self:RemoveTimer(timer)
    end
    self.guard_die_timer_dict = {}

    for _, timer in pairs(self.enemy_die_timer_dict) do
        self:RemoveTimer(timer)
    end
    self.enemy_die_timer_dict = {}
end

function MainSceneUI:ClearWalkingDogTimer()
    if self.left_dog_timer then
        self:RemoveTimer(self.left_dog_timer)
        self.left_dog_timer = nil
    end
    if self.destroy_left_dog_timer then
        self:RemoveTimer(self.destroy_left_dog_timer)
        self.destroy_left_dog_timer = nil
    end
    if self.right_dog_timer then
        self:RemoveTimer(self.right_dog_timer)
        self.right_dog_timer = nil
    end
    if self.destroy_right_dog_timer then
        self:RemoveTimer(self.destroy_right_dog_timer)
        self.destroy_right_dog_timer = nil
    end
end

function MainSceneUI:ClearTimeLimitActivityBtn()
    for _, btn_data in ipairs(self.tl_activity_btn_list) do
        if btn_data.effect then
            self:RemoveUIEffect(btn_data.item:FindChild("Effect"), btn_data.effect)
        end
        self:DelUIObject(btn_data.item)
    end
    self.tl_activity_btn_list = {}
end

function MainSceneUI:ClearRedPointList()
    self:RemoveRedPointList(self.cur_red_point_list)
    self.cur_red_point_list = {}
end


function MainSceneUI:ClearRankActivityRefreshTimer()
    if self.rank_activity_refresh_timer then
        self:RemoveTimer(self.rank_activity_refresh_timer)
        self.rank_activity_refresh_timer = nil
    end
end

function MainSceneUI:MoveUnitToCar()
    for _, enemy_data in ipairs(self.enemy_list) do
        table.insert(self.enemy_in_car_list, enemy_data)
    end
    self.enemy_list = nil
    for _, guard_data in ipairs(self.guard_list) do
        table.insert(self.guard_in_car_list, guard_data)
    end
    self.guard_list = nil
end

function MainSceneUI:PlayDoorAnim(state)
    if self.door_state == state and self.door_timer then return end
    self.door_state = state
    self.left_from_rot = self.door_state and kDoorCloseRotate or kLeftDoorOpenRotate
    self.left_target_rot = self.door_state and kLeftDoorOpenRotate or kDoorCloseRotate
    self.right_from_rot = self.door_state and kDoorCloseRotate or kRightDoorOpenRotate
    self.right_target_rot = self.door_state and kRightDoorOpenRotate or kDoorCloseRotate
    self.door_timer = 0
end

return MainSceneUI