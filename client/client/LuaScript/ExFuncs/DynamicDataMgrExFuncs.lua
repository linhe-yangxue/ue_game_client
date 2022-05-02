local EventUtil = require("BaseUtilities.EventUtil")
local StageConst = require("Stage.StageConst")
local DyDataConst = require("DynamicData.DyDataConst")
local CSConst = require("CSCommon.CSConst")

local DynamicDataMgr = DECLARE_MODULE("ExFuncs.DynamicDataMgrExFuncs")

EventUtil.GeneratorEventFuncs(DynamicDataMgr, "UpdateRoleInfoEvent")
EventUtil.GeneratorEventFuncs(DynamicDataMgr, "UpdateCurrencyEvent")
EventUtil.GeneratorEventFuncs(DynamicDataMgr, "UpdateAttrEvent")
EventUtil.GeneratorEventFuncs(DynamicDataMgr, "UpdateDayOrNightEvent")
EventUtil.GeneratorEventFuncs(DynamicDataMgr, "UpdateActionPoint")
EventUtil.GeneratorEventFuncs(DynamicDataMgr, "UpdateBattleScoreEvent")
EventUtil.GeneratorEventFuncs(DynamicDataMgr, "UpdateItemDict")
EventUtil.GeneratorEventFuncs(DynamicDataMgr, "LevelUpEvent")
EventUtil.GeneratorEventFuncs(DynamicDataMgr, "UpdateBattleStateEvent")
EventUtil.GeneratorEventFuncs(DynamicDataMgr, "UpdateLoverGiftInfoEvent")

function DynamicDataMgr:ExDoInit()
    self._guid_base = 0
    self.is_select_soldier_quick_battle = false
    self.cur_battle_speed = 2
    self.cur_arena_challege_time = 1
    self.base_info = {} -- 基础信息 账户 服务器
    self.main_role_info = {}
    self.main_role_info.currency = {}
    self.main_role_info.attr_dict = {}
    self.system_in_active = {}
    self.no_longer_remind_item = {}
    self.stage_data = {}
    self.cost_value_dict = {}  -- 行动力，精力等等
    self.lover_gift = {}  --情人礼包
    self.hero_gift = {}   --英雄礼包
    self.lover_gift_info = {}  --情人礼包

    --商店
    self.train_shop_data = {}
    self.arena_shop_data = {}
    self.hunt_shop_data = {}
    self.salon_shop_data = {}
    self.party_shop_data = {}
    self.normal_shop_data = {}
    self.crystal_shop_data = {}
    self.hero_shop_data = {}
    self.lover_shop_data = {}
    self.draw_shop_data = {}
    self.hero_shop_refresh_data = {}
    self.lover_shop_refresh_data = {}
    self.toggle_state_dict = {} -- 单选框设置状态

    local cls = require("DynamicData.BagData")
    self.bag_data = cls.New()
    self.bag_data:DoInit()
    
    cls = require("DynamicData.FuncUnlockData")
    self.func_unlock_data = cls.New()
    self.func_unlock_data:DoInit()

    cls = require("DynamicData.GreatHallData")
    self.great_hall_data = cls.New()
    self.great_hall_data:DoInit()

    cls = require("DynamicData.LoverData")
    self.lover_data = cls.New()
    self.lover_data:DoInit()

    cls = require("DynamicData.NightClubData")
    self.night_club_data = cls.New()
    self.night_club_data:DoInit()

    cls = require("DynamicData.ChildCenterData")
    self.child_center_data = cls.New()
    self.child_center_data:DoInit()

    cls = require("DynamicData.TrainingCentreData")
    self.training_centre_data = cls.New()
    self.training_centre_data:DoInit()

    cls = require("DynamicData.ServerData")
    self.server_data = cls.New()
    self.server_data:DoInit()

    cls = require("DynamicData.HuntingData")
    self.hunting_data = cls.New()
    self.hunting_data:DoInit()

    cls = require("DynamicData.GuideData")
    self.guide_data = cls.New()
    self.guide_data:DoInit()

    cls = require("DynamicData.ChatData")
    self.chat_data = cls.New()
    self.chat_data:DoInit()

    cls = require("DynamicData.StrategyMapData")
    self.strategy_map_data = cls.New()
    self.strategy_map_data:DoInit()

    cls = require("DynamicData.TravelData")
    self.travel_data = cls.New()
    self.travel_data:DoInit()

    cls = require("DynamicData.DailyDareData")
    self.daily_dare_data = cls.New()
    self.daily_dare_data:DoInit()

    cls = require("DynamicData.GrabTreasureData")
    self.grab_treasure_data = cls.New()
    self.grab_treasure_data:DoInit()

    cls = require("DynamicData.SalonData")
    self.salon_data = cls.New()
    self.salon_data:DoInit()

    cls = require("DynamicData.DareTowerData")
    self.dare_tower_data = cls.New()
    self.dare_tower_data:DoInit()

    cls = require("DynamicData.DynastyData")
    self.dynasty_data = cls.New()
    self.dynasty_data:DoInit()

    cls = require("DynamicData.ExperimentData")
    self.experiment_data = cls.New()
    self.experiment_data:DoInit()

    cls = require("DynamicData.PartyData")
    self.party_data = cls.New()
    self.party_data:DoInit()

    cls = require("DynamicData.MailData")
    self.mail_data = cls.New()
    self.mail_data:DoInit()

    cls = require("DynamicData.TaskData")
    self.task_data = cls.New()
    self.task_data:DoInit()

    cls = require("DynamicData.CheckData")
    self.check_data = cls.New()
    self.check_data:DoInit()

    cls = require("DynamicData.FriendData")
    self.friend_data = cls.New()
    self.friend_data:DoInit()

    cls = require("DynamicData.DailyActiveData")
    self.daily_active_data = cls.New()
    self.daily_active_data:DoInit()

    cls = require("DynamicData.AchievementData")
    self.achievement_data = cls.New()
    self.achievement_data:DoInit()

    cls = require("DynamicData.RechargeData")
    self.recharge_data = cls.New()
    self.recharge_data:DoInit()

    cls = require("DynamicData.ActivityData")
    self.activity_data = cls.New()
    self.activity_data:DoInit()

    cls = require("DynamicData.TlActivityData")
    self.tl_activity_data = cls.New()
    self.tl_activity_data:DoInit()

    cls = require("DynamicData.FestivalActivityData")
    self.festival_activity_data = cls.New()
    self.festival_activity_data:DoInit()

    cls = require("DynamicData.VipData")
    self.vip_data = cls.New()
    self.vip_data:DoInit()

    cls = require("DynamicData.PrisonData")
    self.prison_data = cls.New()
    self.prison_data:DoInit()

    cls = require("DynamicData.ChurchData")
    self.church_data = cls.New()
    self.church_data:DoInit()

    cls = require("DynamicData.TraitorBossData")
    self.traitor_boss_data = cls.New()
    self.traitor_boss_data:DoInit()

    cls = require("DynamicData.TitleData")
    self.title_data = cls.New()
    self.title_data:DoInit()

    cls = require("DynamicData.LogData")
    self.log_data = cls.New()
    self.log_data:DoInit()

    cls = require("DynamicData.TraitorData")
    self.traitor_data = cls.New()
    self.traitor_data:DoInit()

    cls = require("DynamicData.MonthCardData")
    self.month_card_data = cls.New()
    self.month_card_data:DoInit()

    cls = require("DynamicData.BarData")
    self.bar_data = cls.New()
    self.bar_data:DoInit()

    self.night_club_data:RegisterUpdateHeroEvent("DynamicDataMgr", function()
        self:DispatchUpdateBattleScoreEvent(self:ExGetBattleScore())
    end, self)


end

-- Note(weiwei) 注意客户端的实现使用负的guid避免如部分由客户端自己生成的情况产生和服务端的guid冲突
function DynamicDataMgr:ExNewGuid()
    self._guid_base = self._guid_base - 1
    return self._guid_base
end

function DynamicDataMgr:ExUpdate(delta_time)
end

function DynamicDataMgr:ExClearAll()
    self.log_data:ClearAll()
    self.title_data:ClearAll()
    self._guid_base = 0
end

--------- 客户端专用函数 defines begin----------------
function DynamicDataMgr:ExUpdateRoleBaseInfo(data)
    if data.uuid then
        self.main_role_info.uuid = data.uuid
        self.main_uuid = data.uuid
    end
    if data.name then
        self.main_role_info.name = data.name
    end
    if data.role_id then
        self.main_role_info.role_id = data.role_id
    end
    if data.level then
        if self.main_role_info.level and data.level > self.main_role_info.level then
            self:_ShowUpgradeUI(self.main_role_info.level, data.level)
            self:DispatchLevelUpEvent()
        end
        self.main_role_info.level = data.level
    end
    if data.exp then
        self.main_role_info.exp = data.exp
    end
    if data.score or data.fight_score then
        local last_score = self.main_role_info.score
        local last_fight_score = self.main_role_info.fight_score
        self.main_role_info.score = data.score or self.main_role_info.score
        self.main_role_info.fight_score = data.fight_score or self.main_role_info.fight_score
        if not self.ignore_score_up then
            SpecMgrs.ui_mgr:ShowScoreUpUI(last_score, last_fight_score)
        end
    end
    if data.currency then
        for item_id, count in pairs(data.currency) do
            self.main_role_info.currency[item_id] = count
        end
        self:DispatchUpdateCurrencyEvent(data.currency)
    end
    if data.attr_dict then
        for attr_id , num in pairs(data.attr_dict) do
            self.main_role_info.attr_dict[attr_id] = num
        end
        self:DispatchUpdateAttrEvent(data.attr_dict)
    end
    if data.flag_id then
        self.main_role_info.flag_id = data.flag_id
    end
    if data.not_comment then
        self.main_role_info.not_comment = data.not_comment
    end
    self:DispatchUpdateRoleInfoEvent(data)
end

function DynamicDataMgr:ExSetIgnoreScoreUpFlag(flag)
    self.ignore_score_up = flag
end

function DynamicDataMgr:GetCurrencyData()
    return self.main_role_info.currency
end

function DynamicDataMgr:ExDispatchUpdateItemDict(item_dict)
    self:DispatchUpdateCurrencyEvent(item_dict)
end

function DynamicDataMgr:ExGetCurrencyCount(currency_id)
    return self.main_role_info.currency[currency_id] or 0
end

function DynamicDataMgr:ExCheckNotComment()
    return self.main_role_info.not_comment
end

function DynamicDataMgr:ExGetRoleVip()
    return self.vip_data:GetVipLevel()
end

function DynamicDataMgr:ExGetCostValue(item_id)
    return self.cost_value_dict[item_id]
end

-- 各类界面通用消耗货币
-- 夺宝 竞技场货币
function DynamicDataMgr:ExUpdateVitality(msg)
    self.cost_value_dict[CSConst.CostValueItem.Vitality] = msg.vitality
    self.vitality_ts = msg.vitality_ts
    self:ExDispatchUpdateItemDict({[CSConst.CostValueItem.Vitality] = msg.vitality})
end

function DynamicDataMgr:ExGetVitality()
    return self.cost_value_dict[CSConst.CostValueItem.Vitality]
end

-- 大地图关卡 挑战塔货币
function DynamicDataMgr:ExUpdateActionPoint(msg)
    self.cost_value_dict[CSConst.CostValueItem.ActionPoint] = msg.action_point
    self.action_point_ts = msg.action_point_ts
    self:ExDispatchUpdateItemDict({[CSConst.CostValueItem.ActionPoint] = msg.action_point})
end

function DynamicDataMgr:ExGetActionPoint()
    return self.cost_value_dict[CSConst.CostValueItem.ActionPoint]
end

--  旗帜
function DynamicDataMgr:ExGetRoleFlag()
    return self.main_role_info.flag_id
end

function DynamicDataMgr:ExGetRoleFlagIcon()
    return SpecMgrs.data_mgr:GetFlagData(self.main_role_info.flag_id).icon
end

function DynamicDataMgr:ExUpdateVigor(msg)
    if msg.discuss_ts then self.vigor_ts = msg.discuss_ts end
    if not msg.discuss_num then return end
    self.cost_value_dict[CSConst.CostValueItem.Vigor] = msg.discuss_num
    self:ExDispatchUpdateItemDict({[CSConst.CostValueItem.Vigor] = msg.discuss_num})
end

function DynamicDataMgr:ExUpdatePhysicalPower(msg)
    if msg.last_time then self.physical_power_ts = msg.last_time end
    if not msg.strength_num then return end
    self.cost_value_dict[CSConst.CostValueItem.PhysicalPower] = msg.strength_num
    self:ExDispatchUpdateItemDict({[CSConst.CostValueItem.PhysicalPower] = msg.strength_num})
end

-- 计算消耗值恢复到满所需的时间
function DynamicDataMgr:ExCalcRecoverTime(item_id)
    local cur_count = self.cost_value_dict[item_id]
    local max_count = self:ExGetMaxCostValue(item_id)
    if cur_count >= max_count then return 0 end
    local recover_time
    local recover_last_time
    if item_id == CSConst.CostValueItem.ActionPoint then
        recover_time = SpecMgrs.data_mgr:GetParamData("stage_action_point_limit").f_value * CSConst.Time.Minute
        recover_last_time = self.action_point_ts
    elseif item_id == CSConst.CostValueItem.Vitality then
        recover_time = SpecMgrs.data_mgr:GetParamData("vitality_recover_time").f_value * CSConst.Time.Minute
        recover_last_time = self.vitality_ts
    elseif item_id == CSConst.CostValueItem.Vigor then
        recover_time = SpecMgrs.data_mgr:GetLevelData(self.main_role_info.level).energy_cooldown
        recover_last_time = self.vigor_ts
    elseif item_id == CSConst.CostValueItem.PhysicalPower then
        recover_time = SpecMgrs.data_mgr:GetParamData("travel_strength_num_restore_cd").f_value
        recover_last_time = self.physical_power_ts
    else
        return 0
    end
    return (max_count - cur_count - 1) * recover_time + recover_time + recover_last_time - Time:GetServerTime()
end

function DynamicDataMgr:ExGetMaxCostValue(item_id)
    local vip_data = SpecMgrs.data_mgr:GetVipData(self.vip_data:GetVipLevel())
    if item_id == CSConst.CostValueItem.ActionPoint then
        return SpecMgrs.data_mgr:GetParamData("stage_action_point_limit").f_value
    elseif item_id == CSConst.CostValueItem.Vitality then
        return SpecMgrs.data_mgr:GetParamData("vitality_limit").f_value
    elseif item_id == CSConst.CostValueItem.Vigor then
        local fixed_count = SpecMgrs.data_mgr:GetLevelData(self.main_role_info.level).discuss_max_count
        return fixed_count + (vip_data and vip_data.date_lover_num or 0)
    elseif item_id == CSConst.CostValueItem.PhysicalPower then
        local fixed_count = SpecMgrs.data_mgr:GetParamData("travel_strength_num_limit").f_value
        return fixed_count + (vip_data and vip_data.travel_num or 0)
    else
        return 0
    end
end

-- 获取溢出上限
function DynamicDataMgr:ExGetCostItemOverLimit(item_id)
    if item_id == CSConst.CostValueItem.ActionPoint then
        return SpecMgrs.data_mgr:GetParamData("stage_action_point_max_num").f_value
    elseif item_id == CSConst.CostValueItem.Vitality then
        return SpecMgrs.data_mgr:GetParamData("vitality_max_num").f_value
    end
end

-- 各类界面通用消耗货币 end
function DynamicDataMgr:ExGetRoleUuid()
    return self.main_role_info.uuid
end

function DynamicDataMgr:ExGetRoleName()
    return self.main_role_info.name
end

function DynamicDataMgr:ExGetRoleId()
    return self.main_role_info.role_id
end

function DynamicDataMgr:ExGetRoleExpPercentage()
    local level_data = SpecMgrs.data_mgr:GetLevelData(self.main_role_info.level)
    return (self.main_role_info.exp - level_data.total_exp) / level_data.exp, self.main_role_info.exp, level_data.exp
end

function DynamicDataMgr:ExGetRoleLevel()
    return self.main_role_info.level
end

function DynamicDataMgr:ExGetStrengthenLimit()
    return self.main_role_info.level * CSConst.StrengthenLimitRate
end

--  国力
function DynamicDataMgr:ExGetRoleScore()
    return self.main_role_info.score
end

function DynamicDataMgr:ExGetFightScore()
    return self.main_role_info.fight_score
end

function DynamicDataMgr:ExSetBattleState(is_in_battle)
    self.is_in_battle = is_in_battle
    self:DispatchUpdateBattleStateEvent(is_in_battle)
end

function DynamicDataMgr:ExGetBattleState()
    return self.is_in_battle
end

--  战力
function DynamicDataMgr:ExGetBattleScore()
    local ret = 0
    local line_up_hero_data_dict = self.night_club_data:GetAllLineupData()
    for k, hero_data in pairs(line_up_hero_data_dict) do
        if hero_data.hero_id then
            ret = ret + self.night_club_data:GetHeroDataById(hero_data.hero_id).score
        end
    end
    return ret
end

--  商店
function DynamicDataMgr:ExUpdateTrainShopData(msg)
    self.train_shop_data = msg.train_shop
end

function DynamicDataMgr:ExGetTrainShopBuyTime()
    return self.train_shop_data
end

function DynamicDataMgr:ExUpdateHuntShopData(msg)
    if msg.hunt_shop then
        self.hunt_shop_data = msg.hunt_shop
    end
end

function DynamicDataMgr:ExGetHuntShopBuyTime()
    return self.hunt_shop_data
end

function DynamicDataMgr:ExUpdateArenaData(msg)
    self.arena_history_rank = msg.arena_history_rank
    if msg.arena_shop then
        self.arena_shop_data = msg.arena_shop
    end
end

function DynamicDataMgr:ExGetArenaShopBuyTime()
    return self.arena_shop_data
end

function DynamicDataMgr:ExGetArenaHistoryRank()
    return self.arena_history_rank
end

function DynamicDataMgr:ExUpdateSalonData(msg)
    self.salon_shop_data = msg.salon_shop
end

function DynamicDataMgr:ExGetSalonShopBuyTime()
    return self.salon_shop_data
end

function DynamicDataMgr:ExUpdatePartyData(msg)
    self.party_shop_data = msg.party_shop
end

function DynamicDataMgr:ExGetPartyShopBuyTime()
    return self.party_shop_data
end

function DynamicDataMgr:ExUpdateNormalShopData(msg)
    self.normal_shop_data = msg.shop_info
end

function DynamicDataMgr:ExGetNormalShopBuyTime()
    return self.normal_shop_data
end

function DynamicDataMgr:ExUpdateCrystalShopBuyTime(msg)
    self.crystal_shop_data = msg.daily_item
    for k,v in pairs(msg.week_item) do
        self.crystal_shop_data[k] = v
    end
end

function DynamicDataMgr:ExGetCrystalShopBuyTime()
    return self.crystal_shop_data
end

function DynamicDataMgr:ExUpdateHeroShopBuyTime(msg)
    self.hero_shop_refresh_data = msg
    if msg.shop_dict then
        self.hero_shop_data = msg.shop_dict
    end
end

function DynamicDataMgr:ExUpdateHeroGiftBuy(msg)
    print("英雄礼包购买返回推送------" ,msg)
    self.hero_gift = msg
    return self.hero_gift
end

function DynamicDataMgr:ExGeHeroGiftBuy()
    print("英雄礼包购买返回推送11111------")
    return self.hero_gift
end

function DynamicDataMgr:ExGetHeroShopBuyTime()
    return self.hero_shop_data
end

function DynamicDataMgr:ExGetHeroShopRefreshMes()
    return self.hero_shop_refresh_data
end

function DynamicDataMgr:ExUpdateLoverShopBuyTime(msg)
    self.lover_shop_refresh_data = msg
    if msg.shop_dict then
        self.lover_shop_data = msg.shop_dict
    end
end

function DynamicDataMgr:ExGetLoverShopBuyTime()
    return self.lover_shop_data
end

function DynamicDataMgr:ExGetLoverShopRefreshMes()
    return self.lover_shop_refresh_data
end

function DynamicDataMgr:ExUpdateDrawShopBuyTime(msg)
    if msg.shop_dict then
        for k,v in pairs(msg.shop_dict) do
            self.draw_shop_data[k] = v
        end
    end
end

function DynamicDataMgr:ExGetDrawShopBuyTime()
    return self.draw_shop_data
end

function DynamicDataMgr:ExUpdateFeatsShopBuyTime(msg)
    if msg.shop_dict then
        self.feats_shop_data = msg.shop_dict
    end
end

function DynamicDataMgr:ExGetFeatsShopBuyTime()
    return self.feats_shop_data
end

function DynamicDataMgr:ExUpdateDynastyShopBuyTime(msg)
    if msg.shop_dict then
        self.dynasty_shop_data = msg.shop_dict
    end
end

function DynamicDataMgr:ExGetDynastyShopBuyTime()
    return self.dynasty_shop_data
end

function DynamicDataMgr:ExUpdateLoverGiftBuy(msg)
    print("情人礼包购买返回推送------" ,msg)
    self.lover_gift = msg
    return self.lover_gift
end

function DynamicDataMgr:ExGeLoverGiftBuy()
    print("情人礼包购买返回推送11111------")
    return self.lover_gift
end

function DynamicDataMgr:ExUpdateLoverGiftInfo(msg)
    print("情人礼包主动定时刷新推送11111-----" ,msg)
    self.lover_gift_info = msg
    self:DispatchUpdateLoverGiftInfoEvent(msg)
    --return self.lover_gift_info
end

function DynamicDataMgr:ExGeLoverGiftInfo()
    print("情人礼包主动定时刷新推送22222----")
    --self:DispatchUpdateBattleStateEvent(is_in_battle)
    return self.lover_gift_info
end
--  商店end

function DynamicDataMgr:EXSetArenaChallengeTime(time)
    self.cur_arena_challege_time = time
end

function DynamicDataMgr:EXGetArenaChallengeTime()
    return self.cur_arena_challege_time
end

function DynamicDataMgr:EXSetQuickSoldierBattle(is_quick_battle)
    self.is_select_soldier_quick_battle = is_quick_battle
end

function DynamicDataMgr:EXGetQuickSoldierBattle()
    return self.is_select_soldier_quick_battle
end

function DynamicDataMgr:EXSetHeroBattleSpeed(speed)
    self.cur_battle_speed = speed
end

function DynamicDataMgr:EXGetHeroBattleSpeed()
    return self.cur_battle_speed
end

function DynamicDataMgr:ExSetCurStageType(stage)
    self.cur_stage = stage
end

function DynamicDataMgr:IsCurStage(stage_type)
    return self.cur_stage == stage_type
end

function DynamicDataMgr:ExIsInLoginStage()
    return self:IsCurStage(StageConst.STAGE_Login)
end

function DynamicDataMgr:ExSetKickOutStatus(is_kick, is_relogin)
    self.token = nil -- 被踢出去不重连
    self.is_kick = is_kick
    self.is_relogin = is_relogin
end

function DynamicDataMgr:ExGetRandomHeroID()
    return self.night_club_data:GetRandomHeroID()
end

function DynamicDataMgr:ExGetMainRoleInfoData()
    return self.main_role_info
end


function DynamicDataMgr:ExGetAtributeValue(attr_id)
    return math.floor(self.main_role_info.attr_dict[attr_id] or 0)
end

-- 获得道具或者货币统一接口
function DynamicDataMgr:ExGetItemCount(item_id)
    local item_data = SpecMgrs.data_mgr:GetItemData(item_id)
    if item_data.sub_type == CSConst.ItemSubType.Currency then
        return self:ExGetCurrencyCount(item_id) or 0
    elseif item_data.sub_type == CSConst.ItemSubType.CostValue then
        return self:ExGetCostValue(item_id) or 0
    else
        return ComMgrs.dy_data_mgr.bag_data:GetBagItemCount(item_id)
    end
end

function DynamicDataMgr:ExCheckItemCount(item_id, cost_item_count)
    local cur_item_count = self:ExGetItemCount(item_id)
    cost_item_count = cost_item_count or 0
    return cur_item_count >= cost_item_count
end

-- 设置使用该物品时不再提示物品使用UI
function DynamicDataMgr:ExSetItemUseNoLongerRemind(item_id)
    self.no_longer_remind_item[item_id] = true
end

function DynamicDataMgr:ExGetItemRemindState(item_id)
    return self.no_longer_remind_item[item_id]
end

function DynamicDataMgr:_ShowUpgradeUI(last_lv, cur_level)
    if self.is_in_battle then
        local soldier_battle_ui = SpecMgrs.ui_mgr:GetUI("SoldierBattleUI")
        local hero_battle_ui = SpecMgrs.ui_mgr:GetUI("HeroBattleUI")
        local upgrade_lv_func = function ()
            SpecMgrs.ui_mgr:AddToPopUpList("RoleUpgradeUI", last_lv, cur_level)
            if soldier_battle_ui then
                soldier_battle_ui:UnregisterBattleEnd("DynamicDataMgr")
            end
            if hero_battle_ui then
                hero_battle_ui:UnregisterBattleEnd("DynamicDataMgr")
            end
        end
        if soldier_battle_ui and soldier_battle_ui.is_showing then
            soldier_battle_ui:RegisterBattleEnd("DynamicDataMgr", upgrade_lv_func, self)
        end
        if hero_battle_ui and hero_battle_ui.is_showing then
            hero_battle_ui:RegisterBattleEnd("DynamicDataMgr", upgrade_lv_func, self)
        end
    else
        SpecMgrs.ui_mgr:AddToPopUpList("RoleUpgradeUI", last_lv, cur_level)
    end
end

-- 重新登录重置的单选设置状态
function DynamicDataMgr:ExSetToggleStateByTag(tag_name, state)
    self.toggle_state_dict[tag_name] = state
end

function DynamicDataMgr:ExGetToggleStateByTag(tag_name)
    return self.toggle_state_dict[tag_name]
end

function DynamicDataMgr:ExSetAccountInfo(account_info)
    self.base_info.account_info = account_info
end

function DynamicDataMgr:ExGetAccountInfo(account_info)
    return self.base_info and self.base_info.account_info
end

function DynamicDataMgr:ExSetServerId(server_id)
    self.base_info.server_id = server_id
end

function DynamicDataMgr:ExGetServerId()
    return self.base_info and self.base_info.server_id
end

function DynamicDataMgr:ExGetRoleInfo()
    local ret = {}
    ret.uuid = self:ExGetRoleUuid()
    ret.name = self:ExGetRoleName()
    ret.level = self:ExGetRoleLevel()
    local server_id = self:ExGetServerId()
    ret.server_id = server_id
    ret.server_name = SpecMgrs.data_mgr:GetServerData(server_id).name
    return ret
end

--------- 客户端专用函数 defines end----------------

return DynamicDataMgr