local UIConst = require("UI.UIConst")
local EventUtil = require("BaseUtilities.EventUtil")
local UIMgr = class("Mgrs.Special.UIMgr")
local UIFuncs = require("UI.UIFuncs")
local ItemUtil = require("BaseUtilities.ItemUtil")
EventUtil.GeneratorEventFuncs(UIMgr, "UILoadOkEvent")
EventUtil.GeneratorEventFuncs(UIMgr, "HideUIEvent")
EventUtil.GeneratorEventFuncs(UIMgr, "UIShowOkEvent")
EventUtil.GeneratorEventFuncs(UIMgr, "DestroyUIEvent")
EventUtil.GeneratorEventFuncs(UIMgr, "UISpecialEvent")
EventUtil.GeneratorEventFuncs(UIMgr, "TopUIChangeEvent")
function UIMgr:DoInit()
    self._cur_ui_inst_tb = {}
    self._ui_cls2inst_tb = {}
    self._normal_ui_sort_tb = {}
    self._lock_ui_to_unlock_str = {}
    --Note(weiwei) 为防止special的层级和normal在一个区间，Special的值设置大一点
    self._special_ui_sort_order_tb = {
        DebugUI = 9999,
        MsgSelectBoxUI = 9400,
        LoadingUI = 9300,
        MaskUI = 9000,
        ScoreUpUI = 9200,
        ForceGuideUI = 8000,
        DialogUI = 8200,
        GuideTipsUI = 8500,
        UnitUnlockUI = 8600,
        RoleUpgradeUI = 8700,
        TipMsgUI = 8900,
        MsgBoxUI = 8950,
        HudUI = 7900,
        MiniTaskUI = 7800,
        ShareUI = 8800,
    }

    --  弹出ui优先级
    self._popup_priority_list = {
        "HeroBattleResultUI",
        "BattleResultUI",
        "ArenReportUI",
        "SelectCardUI",
        "RoleUpgradeUI",
        "ArenaRankUpUI",
    }

    -- 覆盖下方ui列表
    self.cover_ui_list = {
        "LoginUI",
        "MainSceneUI",
        "EntertainmentUI",
        "CelebrityHotelUI",
        "ChildCenterUI",
        "BigMapUI",
        "StrategyMapUI",
        "CityStageUI",
        "SoldierBattleUI",
        "HeroBattleUI",

        "LoverDetailUI",
        "SpoilUI",
        "GuideBgUI",
        "GreatHallUI",
        "LineupUI",
        "BagUI",
        "ArenaUI",
        "ExperimentUI",
        "DaliyBattleUI",
        "DressingUI",
        "ChildCenterUI",

        "UniteMarriageUI",
        "LuxuryHouseUI",
        "MarryRequestUI",
        "DareTowerUI",
        "SelectGrabPlayerUI",
        "GrabTreasureUI",
        "ShoppingUI",
        "WelfareUI",
        "DynastyUI",
        "DynastyChallengeUI",
        "DynastyOfficeUI",
        "DynastyStationUI",
        "DynastyBattleUI",
        "DynastyBuildingUI",

        "NightClubUI",
        "HeroDetailInfoUI",
        "TrainHeroUI",
        "FriendUI",
        "PlaymentEntryUI",
        "TLActivityUI",
        "TraitorBossUI",
        "RankUI",
        "RechargeUI",
        "TraitorPreviewUI",
        "DailyActiveUI",
        "AchievementUI",
        "PartyUI",
        "BarUI",
    }

    self.ui_depend_list = {
        ["MainSceneUI"] = "GameMenuUI",
        ["EntertainmentUI"] = "GameMenuUI",
        ["BigMapUI"] = "GameMenuUI",
    }

    self.not_insert_to_cover_list ={
        "HeroBattleUI",
        "SoldierBattleUI",
    }

    self.battle_no_hide_ui_dict = {
        ["MaskUI"] = 1,
    }

    self.need_cover_ui = {
        "AchievementUI",
        "ArenaUI",
        "BagUI",
        "BigMapUI",
        "CelebrityHotelUI",
        "ChildCenterUI",
        "ChurchUI",
        "CityStageUI",
        "DailyActiveUI",
        "DaliyBattleUI",
        "DareTowerUI",
        "DecomposeUI",
        "DirectedTravelUI",
        "DynastyUI",
        "DynastyInstituteUI",
        "DynastyManageUI",
        "DynastyOfficeUI",
        "EntertainmentUI",
        "EquipmentCultivateUI",
        "EquipmentDetailInfoUI",
        "ExperimentUI",
        "FriendUI",
        "GrabTreasureUI",
        "GreatHallUI",
        "HuntingGroundUI",
        "HuntingRareAnimalUI",
        "JoinDynastyUI",
        "LineupUI",
        "LoverDetailUI",
        "LuxuryHouseUI",
        "MailboxUI",
        "MainSceneUI",
        "ManagementCenterUI",
        "MarryRequestUI",
        "NightClubUI",
        "PartyUI",
        "PlayerInfoUI",
        "PlaymentEntryUI",
        "PrisonUI",
        "RankUI",
        "RechargeUI",
        "SalonAreaUI",
        "SalonUI",
        "SecretTravelUI",
        "SelectEquipUI",
        "SelectGrabPlayerUI",
        "SelectMultiEquipUI",
        "ShoppingUI",
        "StrategyMapUI",
        "TLActivityUI",
        "TitleUI",
        "TrainHeroUI",
        "TrainingCentreUI",
        "TraitorPreviewUI",
        "TreasureCultivateUI",
        "TreasureDetailInfoUI",
        "WelfareUI",
        "VipUI",
        "BarUI",
    }

    self._ignore_top_ui = self:GatherIgnoreTopUI()

    -- 断线重连时不清理的ui
    self.keep_on_reconnect = {
    }

    self._normal_ui_root = GameObject.Find("UIRoot_Normal")
    if not self._normal_ui_root then
        self._normal_ui_root = GameObject("UIRoot_Normal")
        GameObject.DontDestroyOnLoad(self._normal_ui_root)
    end
    -- Note(weiwei) 剧情中使用的UIRoot
    self._plot_ui_root = GameObject.Find("UIRoot_Plot")
    if not self._plot_ui_root then
        self._plot_ui_root = GameObject("UIRoot_Plot")
        GameObject.DontDestroyOnLoad(self._plot_ui_root)
    end
    -- 可以在剧情模式下显示的UI
    self._can_show_in_plot_ui_tb = {
    }
    self._show_in_plot_ui_tb = {}

    self._pop_up_ui_list = {}
    self.cur_pop_up_ui = nil

    self.battle_hide_ui_list = {}

    self:RegisterHideUIEvent("UIMgr", function(_, ui)
        self:_CheckPopUpUI(ui.class_name)
    end)

    self.cur_show_ui_list = {}
end

function UIMgr:GatherIgnoreTopUI()
    local ret = {}
    for k, ui in pairs(self.ui_depend_list) do
        ret[ui] = true
    end
    for k, ui in pairs(self._special_ui_sort_order_tb) do
        ret[ui] = true
    end
    ret["EffectUI"] = true
    ret["SpecialUI"] = true
    ret["HudUI"] = true
    return ret
end

function UIMgr:GetNormalUIRoot()
    return self._normal_ui_root
end

function UIMgr:GetSpecialUIOrder(ui_name)
    return self._special_ui_sort_order_tb[ui_name]
end

function UIMgr:GetPlotUIRoot()
    return self._plot_ui_root
end

function UIMgr:OnUILoadOk(ui)
    self:DispatchUILoadOkEvent(ui)
end

function UIMgr:CheckShowInPlot(ui)
    if self:IsInPlot() and self._can_show_in_plot_ui_tb[ui.class_name] then
        if not self._show_in_plot_ui_tb[ui.class_name] then
            self._show_in_plot_ui_tb[ui.class_name] = true
            ui:SetInPlot(true)
        end
    end
end

function UIMgr:CheckShowUI(ui_cls_name)
    if self._lock_ui_to_unlock_str[ui_cls_name] then
        SpecMgrs.ui_mgr:ShowTipMsg(self._lock_ui_to_unlock_str[ui_cls_name])
        return
    end
    return true
end

function UIMgr:LockUI(ui_cls_name, unlock_str)
    self._lock_ui_to_unlock_str[ui_cls_name] = unlock_str
end

function UIMgr:UnLockUI(ui_cls_name)
    self._lock_ui_to_unlock_str[ui_cls_name] = nil
end

function UIMgr:IsInPlot()
    return self._is_in_plot
end

-- Note(weiwei) 设置进入剧情模式，隐藏普通UI只显示剧情触发的UI
function UIMgr:SetInPlot(is_plot)
    self._is_in_plot = is_plot
    if is_plot then
        self._plot_ui_root:SetActive(true)
        self._normal_ui_root:SetActive(false)
    else
        self._normal_ui_root:SetActive(true)
        for class_name, _ in pairs(self._show_in_plot_ui_tb) do
            local ui = self:GetUI(class_name)
            if ui then
                ui:SetInPlot(false)
            end
        end
        self._show_in_plot_ui_tb = {}
        self._plot_ui_root:SetActive(false)
    end
end

function UIMgr:_GetUIClsPath(ui_cls_name)
    return "UI." .. ui_cls_name
end

function UIMgr:ShowCoverUI(cb)
    if self.static_cover_ui then
        self.static_cover_ui:Show(cb)
    else
        local ui_name = "CoverUI"
        local cls_path = self:_GetUIClsPath(ui_name)
        local ui_cls = require(cls_path)
        local ui = ui_cls.New()
        ui.class_name = ui_name
        ui.class_path = cls_path
        ui:DoInit()
        ui:SetSortOrder(8999)
        ui:Show(cb)
        self.static_cover_ui = ui
    end
end

function UIMgr:HideCoverUI()
    if self.static_cover_ui then
        self.static_cover_ui:Hide()
    end
end

function UIMgr:ShowUI(ui_cls_name, ...)
    if not self:CheckShowUI(ui_cls_name) then
        return
    end
    local cls_path = self:_GetUIClsPath(ui_cls_name)
    local ui_cls = require(cls_path)
    local ui = self._ui_cls2inst_tb[cls_path]
    if ui and not ui_cls.can_multi_open then
        if not self._special_ui_sort_order_tb[ui_cls_name] then
            local idx = self._normal_ui_sort_tb[ui]
            if idx then
                local tb_len = self._normal_ui_sort_tb.count
                for i = idx + 1, tb_len, 1 do
                    local p_ui = self._normal_ui_sort_tb[i]
                    self._normal_ui_sort_tb[i - 1] = p_ui
                    self._normal_ui_sort_tb[p_ui] = i - 1
                    if p_ui:IsVisible() then
                        p_ui:SetSortOrder((i - 1) * 3)
                    end
                end
                self._normal_ui_sort_tb[ui] = tb_len
                self._normal_ui_sort_tb[tb_len] = ui
                ui:SetSortOrder(tb_len * 3)
            end
        end
    else
        ui = ui_cls.New()
        ui.class_name = ui_cls_name
        ui.class_path = cls_path
        ui:DoInit()
        if self._special_ui_sort_order_tb[ui_cls_name] then
            local s_order = self._special_ui_sort_order_tb[ui_cls_name]
            if ui_cls.can_multi_open then
                for c_ui, _ in pairs(self._cur_ui_inst_tb) do
                    if c_ui.class_path == cls_path then
                        s_order = s_order + 1
                    end
                end
            end
            ui:SetSortOrder(s_order)
        else
            self._normal_ui_sort_tb.count = (self._normal_ui_sort_tb.count or 0) + 1
            ui:SetSortOrder(self._normal_ui_sort_tb.count * 3)
            self._normal_ui_sort_tb[ui] = self._normal_ui_sort_tb.count
            self._normal_ui_sort_tb[self._normal_ui_sort_tb.count] = ui
        end
        self._cur_ui_inst_tb[ui] = true
        if not ui_cls.can_multi_open then
            self._ui_cls2inst_tb[cls_path] = ui
        end
    end
    self:CheckShowInPlot(ui)
    if table.contains(self.need_cover_ui, ui_cls_name) then
        local pack = table.pack(...)
        self:ShowCoverUI(function()
            ui:Show(table.unpack(pack))
        end)
    else
        ui:Show(...)
    end
    return ui
end

function UIMgr:GetUI(ui_cls_name)
    return self._ui_cls2inst_tb[self:_GetUIClsPath(ui_cls_name)]
end

function UIMgr:HideUI(ui, ...)
    if not ui then
        return
    end
    if type(ui) == "string" then
        ui = self._ui_cls2inst_tb[self:_GetUIClsPath(ui)]
    end
    if ui then
        if table.contains(self.need_cover_ui, ui.class_name) then
            local pack = table.pack(...)
            self:ShowCoverUI(function()
                ui:Hide(table.unpack(pack))
            end)
        else
            ui:Hide(...)
        end
    end
end

function UIMgr:NotifyHideUI(ui)
    self:DispatchHideUIEvent(ui)
    local ui_name = self:GetCurShowTopUIName()
    local is_cover = table.contains(self.cover_ui_list, ui.class_name)
    local is_show_last_ui = ui_name and ui_name == ui.class_name
    if table.contains(self.not_insert_to_cover_list, ui.class_name) then
        is_show_last_ui = true
    end

    if is_show_last_ui and is_cover then
        local cur_ui_name
        if table.contains(self.not_insert_to_cover_list, ui.class_name) then
            cur_ui_name = self:GetCurShowTopUIName()
        else
            table.remove(self.cur_show_ui_list, #self.cur_show_ui_list)
            cur_ui_name = self:GetCurShowTopUIName()
        end
        if cur_ui_name then
            self:RecoverUI(cur_ui_name)
            if self.ui_depend_list[cur_ui_name] then
                self:RecoverUI(self.ui_depend_list[cur_ui_name])
            end
        end
    end
    if table.contains(self.need_cover_ui, ui.class_name) then
        self:HideCoverUI()
    end
    self:DispatchTopUIChangeEvent(ui)
end

function UIMgr:RecoverUI(ui_name)
    local ui = self:GetUI(ui_name)
    if not ui then return end
    ui:SetCover(false)
    if ui.Recover then -- 动画机更新 在隐藏时无法更新
        ui:Recover()
    end
end

-- 获取当前显示的最上层UI名字
function UIMgr:GetCurShowTopUIName()
    return self.cur_show_ui_list[#self.cur_show_ui_list]
end

function UIMgr:NotifyShowUI(ui)
    self:DispatchUIShowOkEvent(ui)
    local ui_cls_name = ui.class_name
    local last_ui = self:GetCurShowTopUIName()
    if not last_ui or last_ui ~= ui_cls_name then
        local is_cover = table.contains(self.cover_ui_list, ui_cls_name)
        if is_cover then
            local index = table.index(self.cur_show_ui_list, ui_cls_name)
            if index then
                table.remove(self.cur_show_ui_list, index)
            end
            if not table.contains(self.not_insert_to_cover_list, ui_cls_name) then
                table.insert(self.cur_show_ui_list, ui_cls_name)
            end
        end
        if last_ui and is_cover then
            if self:GetUI(last_ui) then
                self:GetUI(last_ui):SetVisible(false)
                if self.ui_depend_list[last_ui] then
                    local ui_name = self.ui_depend_list[last_ui]
                    if self:GetUI(ui_name) then self:GetUI(ui_name):SetVisible(false) end
                end
            else
                local index = table.index(self.cur_show_ui_list, last_ui)
                table.remove(self.cur_show_ui_list, index)
            end
        end
    end
    if table.contains(self.need_cover_ui, ui_cls_name) then
        self:HideCoverUI()
    end
    self:DispatchTopUIChangeEvent(ui)
end

function UIMgr:GetNormalTopUINameDict()
    local top_ui
    local top_order
    local top_ui_dict = {}

    for order, ui in pairs(self._normal_ui_sort_tb) do
        if type(order) == "number" then
            if not self._ignore_top_ui[ui.class_name] then -- 绑定ui不算
                if ui.is_showing then
                    if not top_ui then
                        top_ui = ui
                        top_order = order
                    else
                        top_ui = top_order < order and ui or top_ui
                        top_order = top_order < order and order or top_order
                    end
                end
            end
        end
    end
    if top_ui then
        top_ui_dict[top_ui.class_name] = true
        local depend_ui = self.ui_depend_list[top_ui.class_name]
        if depend_ui then
            top_ui_dict[depend_ui] = true
        end
    end
    return top_ui_dict
end

function UIMgr:DestroyUI(ui)
    self._cur_ui_inst_tb[ui] = nil
    if ui.class_path then
        self._ui_cls2inst_tb[ui.class_path] = nil
    end
    local idx = self._normal_ui_sort_tb[ui]
    self._normal_ui_sort_tb[ui] = nil
    if idx then
        local tb_len = self._normal_ui_sort_tb.count
        self._normal_ui_sort_tb[idx] = nil
        for i = idx + 1, tb_len, 1 do
            local p_ui = self._normal_ui_sort_tb[i]
            self._normal_ui_sort_tb[i - 1] = p_ui
            self._normal_ui_sort_tb[p_ui] = i - 1
            -- Note(weiwei) 因为会在show的时候会重新SetOrder，所以此处没必要在SetOrder了
        end
        self._normal_ui_sort_tb.count = self._normal_ui_sort_tb.count - 1
    end
    ui:DoDestroy()
    self:DispatchDestroyUIEvent(ui)
end

function UIMgr:Update(delta_time)
    if self.__UpdateEventCbRemove then
        self:__UpdateEventCbRemove()
    end
    if self.static_cover_ui then
        self.static_cover_ui:Update(delta_time)
    end
    for ui, _ in pairs(self._cur_ui_inst_tb) do
        if ui.Update then
            ui:Update(delta_time)
        end
    end
    self:_UpdateShakeScreen(delta_time)

    if not self.cur_pop_up_ui and #self._pop_up_ui_list > 0 then
        self:_ShowPopupUI()
    end
end

function UIMgr:ClearAll(is_reconnect)
    for _, ui in ipairs(table.keys(self._cur_ui_inst_tb)) do
        if is_reconnect and self.keep_on_reconnect[ui.class_name] then
            -- keep
        else
            local index = table.index(self.cur_show_ui_list, ui.class_name)
            if index then
                ui:SetCover(false) --  销毁前需回复原状态
                table.remove(self.cur_show_ui_list, index)
            end
            self:DestroyUI(ui)
        end
    end
end

function UIMgr:DoDestroy()
    if self.static_cover_ui then
        self.static_cover_ui:DoDestroy()
        self.static_cover_ui = nil
    end
    self:ClearAll()
    if self.__ClearAllEventCb then
        self:__ClearAllEventCb()
    end
end

---- ui mgr interface begin
function UIMgr:ShowMsgBox(str)
    self:ShowUI("MsgBoxUI", str)
end

function UIMgr:ShowMsgSelectBox(...)
    self:ShowUI("MsgSelectBoxUI", ...)
end

--  跳转ui -- 成功就返回ui 用于判定目标ui是否show成功
function UIMgr:JumpUI(go_to_ui_id, is_show_lock_tip)
    local data = SpecMgrs.data_mgr:GetGotoUIData(go_to_ui_id)
    if data.lock_id then
        if ComMgrs.dy_data_mgr.func_unlock_data:CheckFuncIslock(data.lock_id, is_show_lock_tip) then
            return
        end
    end
    if data.shop_type then
        return SpecMgrs.ui_mgr:ShowUI(data.ui, data.shop_type)
    else
        return SpecMgrs.ui_mgr:ShowUI(data.ui)
    end
end

-- 默认检测道具数量是否足够，cb 带有使用道具的cb
function UIMgr:ShowItemUseRemind(item_id, need_count, confirm_cb, remind_tag, is_show_tip, desc, title, count_format)
    local param_tb = {
        item_id = item_id,
        need_count = need_count,
        confirm_cb = confirm_cb,
        desc = desc,
        count_format = count_format,
        title = title,
        is_show_tip = is_show_tip,
        remind_tag = remind_tag,
    }
    self:ShowItemUseRemindByTb(param_tb)
end

function UIMgr:ShowItemUseRemindByTb(param_tb)
    local is_show_tip = param_tb.is_show_tip == nil or param_tb.is_show_tip
    if param_tb.item_dict then
        if not UIFuncs.CheckItemCountByDict(param_tb.item_dict, true) then return end
    else
        if not UIFuncs.CheckItemCount(param_tb.item_id, param_tb.need_count, true) then return end
    end
    local remind_tag = param_tb.remind_tag
    if ComMgrs.dy_data_mgr:ExGetItemRemindState(remind_tag) then
        if param_tb.confirm_cb then
            param_tb.confirm_cb()
        end
        -- todo使用道具
        return
    end
    self:ShowUI("ItemUseUI", param_tb)
end

function UIMgr:ShowSelectItemUseByTb(param_tb)
    self:ShowUI("SelectItemUseUI", param_tb)
end

-- 显示金钱消耗确认提示面板
-- 参数 currency_id,count,confirm_cb(确认消耗金钱的回调),remind_tag(不再提醒的标签),title(标题)
--local data = {title = ,currency_id = ,count = ,result_str = ,remind_tag = ,confirm_cb = } SpecMgrs.ui_mgr:ShowMoneyCostRemind(data)
function UIMgr:ShowMoneyCostRemind(data)
    if ComMgrs.dy_data_mgr:ExGetItemRemindState(data.remind_tag) then
        data.confirm_cb()
    else
        return self:ShowUI("MoneyCostUI", data)
    end
end

-- 战斗飘字
function UIMgr:ShowHud(...)
    local ui = self:GetUI("HudUI")
    if not ui then
        ui = self:ShowUI("HudUI")
    end
    ui:ShowHud(...)
end

function UIMgr:ShowRankUI(group_id)
    self:ShowUI("RankUI", {group_id = group_id})
end

function UIMgr:ShowDialog(dialog_group_id, finish_cb)
    self:ShowUI("DialogUI"):ShowDialog(dialog_group_id, finish_cb)
end

function UIMgr:ShowAllUI()
    self._normal_ui_root:SetActive(true)
end

function UIMgr:HideAllUI()
    self._normal_ui_root:SetActive(false)
end

--  布阵
function UIMgr:ShowSmallLineupUI()
    self:ShowUI("SmallLineupUI")
end

function UIMgr:ShowTipMsg(...)
    self:ShowUI("TipMsgUI", ...)
end

function UIMgr:ShowItemTipMsg(...)
    self:ShowUI("TipMsgUI", ...)
end

function UIMgr:ShowGameMsgBoxUI(...)
    self:ShowUI("GameMsgBoxUI", ...)
end

function UIMgr:ShowLoadingUI(...)
    self:ShowUI("LoadingUI", ...)
end

function UIMgr:ShowItemPreviewUI(item_id)
    self:ShowUI("ItemInfoUI", item_id)
end

function UIMgr:ShowHeroDetailInfo( ... )
    self:ShowUI("HeroDetailInfoUI", ...)
end

function UIMgr:PlayUnitUnlockAnim( ... )
    self:ShowUI("UnitUnlockUI"):PlayUnitUnlockAnim(...)
end

function UIMgr:ShowDateRecord(lover_id, city_id)
    self:ShowUI("DateRecordUI", lover_id, city_id)
end

function UIMgr:ShowTravelEvent(event_data)
    self:ShowUI("TravelEventUI", event_data)
end

-- hero_list, index, op, cb
function UIMgr:ShowTrainHeroUI( ... )
    self:ShowUI("TrainHeroUI", ...)
end

function UIMgr:ShowScoreUpUI(last_score, last_fight_score)
    self:ShowUI("ScoreUpUI", last_score, last_fight_score)
end

function UIMgr:ShowEquipmentDetailInfoUI(guid)
    self:ShowUI("EquipmentDetailInfoUI", guid)
end

function UIMgr:ShowTreasureDetailInfoUI(guid)
    self:ShowUI("TreasureDetailInfoUI", guid)
end

function UIMgr:ShowGetItemUI(role_item_list, title, auto_colse_time, close_cb)
    self:ShowUI("GetItemUI", role_item_list, title, auto_colse_time, close_cb)
end

--  充值
function UIMgr:ShowRechargeUI()
    self:ShowUI("RechargeUI")
end

function UIMgr:ShowGetItemUIByParam(param_tb)
    local item_list = param_tb.item_list or ItemUtil.ItemDictToItemDataList(param_tb.item_dict)
    local title = param_tb.title or CONGRATULATE_GET
    self:ShowUI("GetItemUI", item_list, title, param_tb.auto_colse_time, param_tb.close_cb)
end

function UIMgr:ShowShareUI()
    SpecMgrs.ui_mgr:ShowUI("ShareUI")
end

-- item_list, item_count_list, confirm_cb, count
function UIMgr:ShowChooseItemUseUI(param_tb)
    if param_tb.role_item_list then
        local item_list = {}
        local item_count_list = {}
        for i, v in ipairs(param_tb.role_item_list) do
            table.insert(item_list, v.item_id)
            table.insert(item_count_list, v.count)
        end
        param_tb.item_list = item_list
        param_tb.item_count_list = item_count_list
    end
    self:ShowUI("ChooseItemUseUI", param_tb)
end

function UIMgr:ShowCostItemRecoverUI(item_list, unit_id)
    self:ShowUI("CostItemRecoverUI", item_list, unit_id)
end

function UIMgr:ShowPrivateChat(role_info)
    if not role_info then return end
    local chat_ui = self:GetUI("ChatUI")
    if chat_ui and chat_ui.is_showing then
        chat_ui:ChangePrivateChat(role_info)
    else
        self:ShowUI("ChatUI", CSConst.ChatType.Private, role_info)
    end
end

function UIMgr:ShowCommentUI(comment_index)
    if ComMgrs.dy_data_mgr:ExCheckNotComment() then
        return
    end
    SpecMgrs.ui_mgr:ShowUI("CommentUI", comment_index)
end

-- 限时活动
function UIMgr:ShowTLAvtivity(activity_id)
    self:ShowUI("TLActivityUI", activity_id)
end

--  头目战斗
function UIMgr:IsInBattleScence()
    local ui = self:GetUI("HeroBattleUI")
    if ui then
        return ui.is_visible
    else
        return false
    end
end

--  进入战斗时 隐藏下面ui
function UIMgr:EnterHeroBattle(fight_data, scence_id, scence_bg)
    self.battle_hide_ui_list = {}
    for ui, v in pairs(self._cur_ui_inst_tb) do
        if not table.contains(self.cover_ui_list, ui.class_name) and not self.battle_no_hide_ui_dict[ui] then
            if ui.is_res_ok and ui.go.activeSelf then
                ui:SetVisible(false)
                table.insert(self.battle_hide_ui_list, ui)
            end
        end
    end
    self:RegisterHeroBattleUIClose("AfterBattleShow", function()
        for i, ui in ipairs(self.battle_hide_ui_list) do
            if ui.is_res_ok then
                ui:SetVisible(true)
            end
        end
        self.battle_hide_ui_list = {}
    end)
    self:ShowUI("HeroBattleUI", false, fight_data, scence_id, scence_bg)
end

function UIMgr:RegiseHeroBattleEnd(tag, func)
    self:GetUI("HeroBattleUI"):RegisterBattleEnd(tag, function()
        func()
        if self:GetUI("HeroBattleUI") then
            self:GetUI("HeroBattleUI"):UnregisterBattleEnd(tag)
        end
    end)
end

function UIMgr:RegisterHeroBattleUIClose(tag, func)
    self:RegisterHideUIEvent(tag, function(_, ui)
        if "HeroBattleUI" == ui.class_name then
            func()
            self:UnregisterHideUIEvent(tag)
        end
    end)
end

--  头目战斗 end
function UIMgr:_CheckPopUpUI(cls_name)
    if self.cur_pop_up_ui and self.cur_pop_up_ui.ui_cls_name == cls_name then
        if self.cur_pop_up_ui.is_close_battle then
            if SpecMgrs.ui_mgr:GetUI("HeroBattleUI") then
                SpecMgrs.ui_mgr:HideUI("HeroBattleUI")
            end
        end
        if #self._pop_up_ui_list ~= 0 then
            self:_ShowPopupUI()
        else
            self.cur_pop_up_ui = nil
        end
    end
end

function UIMgr:_ShowPopupUI()
    local param = self._pop_up_ui_list[1].param
    self:ShowUI(self._pop_up_ui_list[1].ui_cls_name, table.unpack(param, 1, #param))
    self.cur_pop_up_ui = self._pop_up_ui_list[1]
    table.remove(self._pop_up_ui_list, 1)
end

function UIMgr:AddToPopUpList(ui_cls_name, ...)-- 弹出ui列表
    local param_tb = {
        ui_cls_name = ui_cls_name,
        param = {...},
    }
    local is_insert = false
    local show_index = table.index(self._popup_priority_list, ui_cls_name)
    if show_index then
        for i, param in ipairs(self._pop_up_ui_list) do
            local index = table.index(self._popup_priority_list, param.ui_cls_name)
            if index then
                if show_index < index then
                    table.insert(self._pop_up_ui_list, i, param_tb)
                    is_insert = true
                    break
                end
            end
        end
    end
    if not is_insert then
        table.insert(self._pop_up_ui_list, param_tb)
    end
    return param_tb
end

function UIMgr:AddCloseBattlePopUpList(ui_cls_name, ...)
    local pop_ui = self:AddToPopUpList(ui_cls_name, ...)
    pop_ui.is_close_battle = true
end

---- ui mgr interface end

---- special ui interface begin
--  延迟显示背包增加物品
function UIMgr:SetShowAddItemList(is_show)
    ComMgrs.dy_data_mgr.bag_data:SetShowAddBagItem(is_show)
end

function UIMgr:AddUnitInfoRoot(unit)
    local ui = self:GetUI("SpecialUI")
    return ui:AddUnitInfoRoot(unit)
end

function UIMgr:GetInfoItem(info_type)
    local ui = self:GetUI("SpecialUI")
    return ui:GetInfoItem(info_type)
end

function UIMgr:DelInfoItem(item)
    local ui = self:GetUI("SpecialUI")
    if not ui then return end
    ui:DelInfoItem(item)
end

function UIMgr:ShakeScreen(shake_screen_action)
    if self.cur_shake_screen then  --只存在一个震屏行为
        self:EndShakeScreen()
    end
    self.cur_shake_screen = shake_screen_action
    self.cur_shake_screen.timer = 0
    self.start_pos_list = {}
    for i, obj in ipairs(self.cur_shake_screen.shake_obj_list) do
        self.cur_shake_screen.shake_obj_list[i] = obj
        self.start_pos_list[i] = obj.transform.position
    end
end

function UIMgr:EndShakeScreen()
    if not self.cur_shake_screen then return end
    for i, obj in ipairs(self.cur_shake_screen.shake_obj_list) do
        if self.start_pos_list[i] then
            obj.transform.position = self.start_pos_list[i]
        end
    end
    self.cur_shake_screen = nil
end

function UIMgr:_UpdateShakeScreen(delta_time)
    if self.cur_shake_screen ~= nil and UnityEngine.Time.timeScale ~= 0 then
        self.cur_shake_screen.timer = self.cur_shake_screen.timer + delta_time
        if self.cur_shake_screen.timer > self.cur_shake_screen.shake_time then
            self:EndShakeScreen()
        else
            local range = math.floor(self.cur_shake_screen.shake_range * 10)
            local offset = Vector3.New(math.random(-range, range)/10, math.random(-range, range)/10, 0)
            for i, obj in ipairs(self.cur_shake_screen.shake_obj_list) do
                obj.transform.position = Vector3.New(offset.x, offset.y, obj.transform.position.z)
            end
        end
    end
end
---- special ui interface end

return UIMgr
