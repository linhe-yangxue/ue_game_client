local sproto_env = require("Sproto.SprotoMsgEnv")
local TCPConnect = require("Network.TCPConnect")
local GConst = require("GlobalConst")
local ui_const = require("UI.UIConst")

local MsgChannel = class("Msg.MsgChannel")

function MsgChannel:DoInit()
    self.conn = TCPConnect.New()
    self.conn:DoInit(function(...) self:_OnConnectError(...) end)
    self._session = 1
    self.cur_msg_data = ""
    self.ip = nil
    self.port = nil

    self.heartbeat_time = 0
end

function MsgChannel:DoDestroy()
    self:_ClearAll()
    if self.conn then
        self.conn:DoDestroy()
        self.conn = nil
    end
end

function MsgChannel:SetSprotoUtils(sproto_utils)
    self.sproto_utils = sproto_utils
end

function MsgChannel:Connect(ip, port, cb)
    self:_ClearAll()
    self.ip = ip
    self.port = port
    self.cb = cb
    self.conn = TCPConnect.New()
    self.conn:DoInit(function(...) self:_OnConnectError(...) end)
    self.conn:Connect(ip, port, function()
        self.fail_count = 0
        if self.cb then
            self.cb(true)
            self.cb = nil
        end
    end)
end

function MsgChannel:_Reconnect()
    print("开始重新连接服务器")
    self.fail_count = (self.fail_count or -1) + 1
    self.is_reconnect = true
    -- SpecMgrs.ui_mgr:ShowTipMsg(ui_const.TCP_Reconnect)
    self:Disconnect()
    self.conn = TCPConnect.New()
    self.conn:DoInit(function(...) self:_OnConnectError(...) end)
    local cur_fail_count = self.fail_count
    self.conn:Connect(self.ip, self.port, function()
        if not cur_fail_count == self.fail_count then return end -- 多次发送重连只接受最后一次回调
        if ComMgrs.dy_data_mgr.token then
            SpecMgrs.msg_mgr:SendReconnect({uuid = ComMgrs.dy_data_mgr:ExGetRoleUuid(), token = ComMgrs.dy_data_mgr.token}, function(resp)
                if resp.errcode ~= 0 then
                    -- 重连失败， 退出
                    self:ShowReconnectFail()
                else
                    -- SpecMgrs.ui_mgr:ShowTipMsg(ui_const.TCP_ReconnectToServerOk)
                    SpecMgrs.ui_mgr:HideUI("LoadingUI")
                    self:HideReconnectFail()
                    self.is_reconnect = nil
                    self.fail_count = nil
                end
            end)
        else
            SpecMgrs.stage_mgr:GotoStage("LoginStage")
        end
    end)
end

function MsgChannel:ShowReconnectFail()
    if self.select_ui then return end
    local param_tb = {
        content = ui_const.Reconnect_Tip,
        confirm_cb = function ()
            self:_Reconnect()
            self.select_ui = nil
        end,
        cancel_cb = function ()
            SpecMgrs.ui_mgr:HideUI("LoadingUI")
            if not ComMgrs.dy_data_mgr:ExIsInLoginStage() then
                SpecMgrs.stage_mgr:GotoStage("LoginStage")
            end
            self.select_ui = nil
        end
    }
    self.select_ui = SpecMgrs.ui_mgr:ShowMsgSelectBox(param_tb)
end

function MsgChannel:HideReconnectFail()
    if self.select_ui then
        SpecMgrs.ui_mgr:HideUI(self.select_ui)
    end
    self.select_ui = nil
end

function MsgChannel:Disconnect()
    if self.conn then
        self.conn:Disconnect()
    end
end

function MsgChannel:IsConnected()
    return self.conn:IsConnected()
end

function MsgChannel:GetCurrentlyDelayTime()
    return self.cur_delay_time
end

function MsgChannel:Update(delta_time)
    if not self.conn then
        return
    end
    if self.reconnect_cd then
        self.reconnect_cd = self.reconnect_cd - delta_time
        if self.reconnect_cd < 0 then
            self.reconnect_cd = nil
            self:_Reconnect()
        end
    end
    self.conn:Update(delta_time)
    if self.conn:IsConnected() then
        self:_ReceiveAndDispatchMsg()
        self:_UpdateHeartBeat(delta_time)
    end
end

function MsgChannel:PreUpdate(delta_time)
    if self.conn then
        self.conn:PreUpdate(delta_time)
    end
end

-------------------------------------------
-- 网络相关实现
------------------------------------------
function MsgChannel:_OnConnectError(faild_type, err_msg)
    PrintWarn("MsgChannel:_OnConnectError", faild_type, err_msg)
    if faild_type == GConst.NetFailed.TCP_Receive_Disconnect then
    elseif faild_type == GConst.NetFailed.TCP_Connect_Timeout then
        self:ShowReconnectFail()
    end
    -- SpecMgrs.ui_mgr:ShowTipMsg(ui_const.TCP_Disconnected)
    if self.cb then
        self.cb(false)
        self.cb = nil
    end
    if not self.is_reconnect then
        self.reconnect_cd = 1
        print(string.format("==============连接错误，%s秒后重连", self.reconnect_cd))
        SpecMgrs.ui_mgr:ShowLoadingUI()
    end
end

function MsgChannel:_GetNewSession()
    local ret = self._session
    self._session = ret + 1
    return ret
end

function MsgChannel:_UpdateHeartBeat(delta_time)
    if self.heartbeat_time <= 0 then
        self.heartbeat_time = GConst.HeartBreakTime
        local send_ping_time  = GetTimeStamp()

        self:_SendMsgByProto('c_heartbeat', {}, function (resp)
            local old_delay_time = self.cur_delay_time
            self.cur_delay_time = GetTimeStamp() - send_ping_time
            if not old_delay_time or self.cur_delay_time < 0.2 then
                if resp.server_time > 1559132417 * 10 then
                    -- 百分之一秒
                    resp.server_time = resp.server_time * 0.01
                end
                if math.abs(resp.server_time - Time:GetServerTimeFloat()) > 0.2 then
                    Time:SetServerTime(resp.server_time)
                end
            end
        end)
    end
    self.heartbeat_time = self.heartbeat_time - delta_time
end

function MsgChannel:_ClearAll()
    self._session = 1
end

-------------------------------------------
-- 消息相关实现
------------------------------------------
-------- Msg recive from Server and dispatch to handles
function MsgChannel:_ReceiveAndDispatchMsg()
    while true do
        local data = self.conn:TryReceive()
        if not data or data == "" then break end
        self.cur_msg_data = self.cur_msg_data .. data
        local dpt_rets = {}
        while true do
            local ret_str, msg_str = self.sproto_utils:swallow_msg_data(self.cur_msg_data)
            if not ret_str then break end
            --print("MsgChannel:_ReceiveAndDispatchMsg", string.byte(msg_str, 1, -1))
            local status, dpt_ret = xpcall(
                function() self.sproto_utils:dispatch_msg(msg_str) end,
                ErrorHandle)
            if status then
                table.insert(dpt_rets, dpt_ret)
            end
            self.cur_msg_data = ret_str
        end
        for _, msg_bytes in ipairs(dpt_rets) do
            self.conn:Send(msg_bytes)
        end
    end
end

-------- Msg Send to Server and may be use callback to process response
function MsgChannel:_SendMsgByProto(sproto_name, msg, cb)
    print("MsgChannel:_SendMsgByProto", sproto_name, msg, cb)
    local session = nil
    if cb then
        session = self:_GetNewSession()
        self.sproto_utils:register_session_cb(sproto_name, session, cb)
    end
    local msg_bytes = self.sproto_utils:pack_c2s_msg(sproto_name, msg, session)
    self.conn:Send(msg_bytes)
end

function MsgChannel:_SendMsgByProtoAndDefaultRespHandle(proto_name, data, cb)
    cb = cb or self.DefaultRespFunc
    self:_SendMsgByProto(proto_name, data, cb)
end

function MsgChannel.DefaultRespFunc(resp)
    if resp.errcode ~= 0 then
        -- SpecMgrs.ui_mgr:ShowMsgBox(resp.errcode)
    end
end

-------------------------------------------
-- 消息定义
------------------------------------------
------ the send msgs define begin
function MsgChannel:SendMsg(sproto_name, msg, cb)
    self:_SendMsgByProto(sproto_name, msg, cb)
end
------ login msgs define begin
function MsgChannel:SendLogin(data, cb)
    self:_SendMsgByProto('c_login', data, cb)
end

function MsgChannel:SendSwitchAccount(data, cb)
    self:_SendMsgByProto('c_client_quit', data, cb)
end

function MsgChannel:SendReconnect(data, cb)
    self:_SendMsgByProto('c_reconnect', data, cb)
end
------ login msgs define end


------ GreatHall msgs define begin
function MsgChannel:SendHandleInfo(data, cb)
    self:_SendMsgByProto('c_handle_info', data, cb)
end

function MsgChannel:SendPublichCmd(data, cb)
    self:_SendMsgByProto('c_publish_cmd', data, cb)
end

function MsgChannel:SendPublichAllCmd(data, cb)
    self:_SendMsgByProto('c_publish_all_cmd', data, cb)
end

function MsgChannel:SendUseHallItem(data, cb)
    self:_SendMsgByProto('c_use_hall_item', data, cb)
end

------ GreatHall msgs define begin

function MsgChannel:SendCreateRole(data, cb)
    self:_SendMsgByProto("c_new_role", data, cb)
end

function MsgChannel:SendQueryRandomName(data, cb)
    self:_SendMsgByProto("c_query_random_name", data, cb)
end

function MsgChannel:SendChangeLoverGrade(data, cb)
    self:_SendMsgByProto('c_change_lover_grade', data, cb)
end

--  情人
function MsgChannel:SendLoverDiscuss(data, cb)
    self:_SendMsgByProto("c_lover_discuss", data, cb)
end

function MsgChannel:SendRecoverEnergy(data, cb)
    self:_SendMsgByProto("c_recover_energy", data, cb)
end

function MsgChannel:SendUpgradeLoverSpell(data, cb)
    self:_SendMsgByProto("c_upgrade_lover_spell", data, cb)
end

function MsgChannel:SendGiveLoverItem(data, cb)
    self:_SendMsgByProto("c_give_lover_item", data, cb)
end

function MsgChannel:SendDoteLover(data, cb)
    self:_SendMsgByProto("c_dote_lover", data, cb)
end

function MsgChannel:SendChangeLoverFashion(data, cb)
    self:_SendMsgByProto("c_change_lover_fashion", data, cb)
end

function MsgChannel:SendFashionBtn(data, cb)
    self:_SendMsgByProto("c_query_lover_info", data, cb)
end

function MsgChannel:SendChangeLoverSex(data, cb)
    self:_SendMsgByProto("c_change_lover_sex", data, cb)
end

function MsgChannel:SendFondleLover(data, cb)
    self:_SendMsgByProto("c_fondle_lover", data, cb)
end

function MsgChannel:SendTotalLoverDiscuss(data, cb)
    self:_SendMsgByProto("c_total_lover_discuss", data, cb)
end

--  情人end

------- nightclub msgs define begin

function MsgChannel:SendAddHero(data)
    self:_SendMsgByProto("c_add_hero", data)
end

------- childcenter msgs define begin
function MsgChannel:SendChildGiveName(data, cb)
    self:_SendMsgByProto("c_child_give_name", data, cb)
end

function MsgChannel:SendChildLevelUp(data, cb)
    self:_SendMsgByProto("c_child_education", data, cb)
end

function MsgChannel:SendExpandChildGrid(data, cb)
    self:_SendMsgByProto("c_child_grid", data, cb)
end

function MsgChannel:SendChildRename(data, cb)
    self:_SendMsgByProto("c_child_rename", data, cb)
end

function MsgChannel:SendChildUseItem(data, cb)
    self:_SendMsgByProto("c_child_use_item", data, cb)
end

function MsgChannel:SendChildCanonized(data, cb)
    self:_SendMsgByProto("c_child_canonized", data, cb)
end
------- trainingcentre msg define begin
function MsgChannel:SendLoverTrain(data, cb)
    self:_SendMsgByProto("c_lover_train", data, cb)
end

function MsgChannel:SendLoverTrainQuicken(data, cb)
    self:_SendMsgByProto("c_lover_train_quicken", data, cb)
end

function MsgChannel:SendGetLoverTrainReward(data, cb)
    self:_SendMsgByProto("c_get_lover_train_reward", data, cb)
end

function MsgChannel:SendLoverUnlockEventGrid(data, cb)
    self:_SendMsgByProto("c_lover_unlock_event_grid", data, cb)
end
-------- debug ui
function MsgChannel:SendCommand(cmd)
    self:_SendMsgByProto('c_gm', {cmd = cmd})
end
-------- Hunting msgs define begin
function MsgChannel:SendGetHuntNotice(data, cb)
    self:_SendMsgByProto('c_get_hunt_notice', data, cb)
end

function MsgChannel:SendGetHuntRank(data, cb)
    self:_SendMsgByProto('c_get_hunt_rank', data, cb)
end

function MsgChannel:SendSetHuntHero(data, cb)
    self:_SendMsgByProto('c_set_hunt_hero', data, cb)
end

function MsgChannel:SendHuntGroundAnimal(data, cb)
    self:_SendMsgByProto('c_hunt_ground_animal', data, cb)
end

function MsgChannel:SendHuntHeroRecover(data, cb)
    self:_SendMsgByProto('c_hunt_hero_recover', data, cb)
end

function MsgChannel:SendGetFirstReward(data, cb)
    self:_SendMsgByProto('c_get_first_reward', data, cb)
end

function MsgChannel:SendAddHuntNum(data, cb)
    self:_SendMsgByProto('c_add_hunt_num', data, cb)
end

function MsgChannel:SendGetAllRareAnimalData(data, cb)
    self:_SendMsgByProto('c_get_all_rare_animal_data', data, cb)
end

function MsgChannel:SendStartHuntRareAnimal(data, cb)
    self:_SendMsgByProto('c_start_hunt_rare_animal', data, cb)
end

function MsgChannel:SendGetRareAnimalData(data, cb)
    self:_SendMsgByProto('c_get_rare_animal_data', data, cb)
end

function MsgChannel:SendHuntRareAnimal(data, cb)
    self:_SendMsgByProto('c_hunt_rare_animal', data, cb)
end

function MsgChannel:SendHuntInspire(data, cb)
    self:_SendMsgByProto('c_hunt_inspire', data, cb)
end

function MsgChannel:SendListenRareAnimal(data, cb)
    self:_SendMsgByProto('c_listen_rare_animal', data, cb)
end

function MsgChannel:SendGiveUpHuntGround(data, cb)
    self:_SendMsgByProto('c_give_up_hunt_ground', data, cb)
end

function MsgChannel:SendStartHuntGround(data, cb)
    self:_SendMsgByProto('c_start_hunt_ground', data, cb)
end

function MsgChannel:SendEndHuntGround(data, cb)
    self:_SendMsgByProto('c_end_hunt_ground', data, cb)
end
-------- Hunting msgs define end

------- Marriage

function MsgChannel:SendProposeMarry(data, cb)
    self:_SendMsgByProto("c_child_send_request", data, cb)
end

function MsgChannel:SendCancalProposeMarry(data, cb)
    self:_SendMsgByProto("c_child_cancel_request", data, cb)
end

-- 拒绝提亲
function MsgChannel:SendRefuseRequestMarry(data, cb)
    self:_SendMsgByProto("c_child_refuse_request", data, cb)
end

function MsgChannel:SendOpenJointMarry(data, cb)
    self:_SendMsgByProto("c_open_joint_marriage", data, cb)
end

--  接受提亲
function MsgChannel:SendAcceptMarry(data, cb)
    self:_SendMsgByProto("c_child_marriage", data, cb)
end

--  拒绝所有
function MsgChannel:SendRefuseAllMarry(data, cb)
    self:_SendMsgByProto("c_child_refuse_all_request", data, cb)
end

--  看过marry消息
function MsgChannel:SendConfirmMarry(data, cb)
    self:_SendMsgByProto("c_child_marriage_confirm", data, cb)
end

------- Marriage
------- Prison msgs define begin
function MsgChannel:SendPrisonTorture(data, cb)
    self:_SendMsgByProto("c_prison_torture", data, cb)
end
------- Prison msgs define end

------- Lineup msgs define begin
function MsgChannel:SendLineupChangeHero(data, cb)
    self:_SendMsgByProto("c_lineup_change_hero", data, cb)
end

function MsgChannel:SendHeroAdjustPosLineup(data, cb)
    self:_SendMsgByProto("c_hero_adjust_pos_lineup", data, cb)
end

function MsgChannel:SendLineupWearEquip(data, cb)
    self:_SendMsgByProto("c_lineup_wear_equip", data, cb)
end

function MsgChannel:SendLineupUnwearEquip(data, cb)
    self:_SendMsgByProto("c_lineup_unwear_equip", data, cb)
end

function MsgChannel:SendReinforcementsChange(data, cb)
    self:_SendMsgByProto("c_reinforcements_change", data, cb)
end
------- Lineup msgs define end

------- soldierbattle
function MsgChannel:SendStageFight(data, cb)
    self:_SendMsgByProto("c_stage_fight", data, cb)
end

function MsgChannel:SendBossStageFight(data, cb)
    self:_SendMsgByProto("c_boss_stage_fight", data, cb)
end

function MsgChannel:SendStageFightEnd(data, cb)
    self:_SendMsgByProto("c_stage_fight_end", data, cb)
end

function MsgChannel:SendEnterStage(data, cb)
    self:_SendMsgByProto("c_enter_stage", data, cb)
end
------- soldierbattle

-- bag ui define begin ---------
function MsgChannel:SendUseBagItem(data, cb)
    self:_SendMsgByProto("c_use_bag_item", data, cb)
end

function MsgChannel:SendComposeItem(data, cb)
    self:_SendMsgByProto("c_item_compose", data, cb)
end
-- bag ui define end -----------

------- StrategyMap msgs define begin
function MsgChannel:SendSweepBossStage(data, cb)
    self:_SendMsgByProto("c_sweep_boss_stage", data, cb)
end

function MsgChannel:SendResetBossStage(data, cb)
    self:_SendMsgByProto("c_reset_boss_stage", data, cb)
end

function MsgChannel:SendGetStageFirstReward(data, cb)
    self:_SendMsgByProto("c_get_stage_first_reward", data, cb)
end

function MsgChannel:SendAddActionPoint(data, cb)
    self:_SendMsgByProto("c_add_action_point", data, cb)
end

function MsgChannel:SendGetCityStarReward(data, cb)
    self:_SendMsgByProto("c_get_city_star_reward", data, cb)
end

function MsgChannel:SendGetCountryOccupyReward(data, cb)
    self:_SendMsgByProto("c_get_country_occupy_reward", data, cb)
end

function MsgChannel:SendGetCityResource(data, cb)
    self:_SendMsgByProto("c_get_city_resource", data, cb)
end

function MsgChannel:SendManageCity(data, cb)
    self:_SendMsgByProto("c_manage_city", data, cb)
end

function MsgChannel:SendGetCityAllReward(data, cb)
    self:_SendMsgByProto("c_get_city_all_reward", data, cb)
end
------- StrategyMap msgs define end

function MsgChannel:SendCompleteGuide(data, cb)
    self:_SendMsgByProto("c_complete_guide", data, cb)
end

-- chat msg define begin
function MsgChannel:SendChatMsg(data, cb)
    self:_SendMsgByProto("c_send_chat_msg", data, cb)
end
-- chat msg define end

-- travel msg define begin
function MsgChannel:SendUnlockTravelArea(data, cb)
    self:_SendMsgByProto("c_travel_area_unlock", data, cb)
end

function MsgChannel:SendRandomTravel(data, cb)
    self:_SendMsgByProto("c_random_travel", data, cb)
end

function MsgChannel:SendAssignTravel(data, cb)
    self:_SendMsgByProto("c_assign_travel", data, cb)
end

function MsgChannel:SendUseTravelItem(data, cb)
    self:_SendMsgByProto("c_travel_use_item", data, cb)
end

function MsgChannel:SendSetLuckRecoverValue(data, cb)
    self:_SendMsgByProto("c_travel_luck_restore_set", data, cb)
end

function MsgChannel:SendRecoverLuck(data, cb)
    self:_SendMsgByProto("c_travel_luck_restore", data, cb)
end
-- travel msg define end

-- train hero define begin
function MsgChannel:SendUpgradeHeroLevel(data, cb)
    self:_SendMsgByProto("c_upgrade_hero_level", data, cb)
end

function MsgChannel:SendHeroBreakThrough(data, cb)
    self:_SendMsgByProto("c_hero_breakthrough", data, cb)
end

function MsgChannel:SendUpgradeHeroStarLevel(data, cb)
    self:_SendMsgByProto("c_upgrade_hero_star_lv", data, cb)
end

function MsgChannel:SendUpgradeHeroDestinyLevel(data, cb)
    self:_SendMsgByProto("c_upgrade_hero_destiny_lv", data, cb)
end

function MsgChannel:SendCultivateHero(data, cb)
    self:_SendMsgByProto("c_give_hero_item", data, cb)
end
-- train hero define end

-- daily fight
function MsgChannel:SendDailyDarefight(data, cb)
    self:_SendMsgByProto("c_daily_dare_fight", data, cb)
end

-- GrabTreasure define begin
function MsgChannel:SendGetGrabRoleList(data, cb)
    self:_SendMsgByProto("c_get_grab_role_list", data, cb)
end

function MsgChannel:SendClearGrabRoleList(data, cb)
    self:_SendMsgByProto("c_clear_grab_role_list", data, cb)
end

function MsgChannel:SendGrabTreasure(data, cb)
    self:_SendMsgByProto("c_grab_treasure", data, cb)
end

function MsgChannel:SendGrabTreasureSelectReward(data, cb)
    self:_SendMsgByProto("c_grab_treasure_select_reward", data, cb)
end

function MsgChannel:SendGrabTreasureFiveTimes(data, cb)
    self:_SendMsgByProto("c_grab_treasure_five_times", data, cb)
end

function MsgChannel:SendQuickGrabTreasure(data, cb)
    self:_SendMsgByProto("c_quick_grab_treasure", data, cb)
end

function MsgChannel:SendTreasureCompose(data, cb)
    self:_SendMsgByProto("c_treasure_compose", data, cb)
end

function MsgChannel:SendTreasureSmelt(data, cb)
    self:_SendMsgByProto("c_treasure_smelt", data, cb)
end
-- GrabTreasure define end

-- salon define begin
function MsgChannel:SendSalonDispatchLover(data, cb)
    self:_SendMsgByProto("c_salon_dispatch_lover", data, cb)
end

function MsgChannel:SendBuyAttrPoint(data, cb)
    self:_SendMsgByProto("c_salon_buy_attr_point", data, cb)
end

function MsgChannel:SendRecieveIntegral(data, cb)
    self:_SendMsgByProto("c_salon_receive_integral", data, cb)
end

function MsgChannel:SendGetSalonRecord(data, cb)
    self:_SendMsgByProto("c_salon_get_pvp", data, cb)
end

function MsgChannel:SendExchangeSalonItem(data, cb)
    self:_SendMsgByProto("c_salon_item_swap", data, cb)
end

function MsgChannel:SendGetSalonRankList(data, cb)
    self:_SendMsgByProto("c_salon_get_rank", data, cb)
end

-- salon define end
-- equip define begin

function MsgChannel:SendStrengthenEquipment(data, cb)
    self:_SendMsgByProto("c_lineup_strengthen_equip", data, cb)
end

function MsgChannel:SendStrengthenEquipmentFive(data, cb)
    self:_SendMsgByProto("c_strengthen_equip_five_times", data, cb)
end

function MsgChannel:SendQuickStrengthenEquipment(data, cb)
    self:_SendMsgByProto("c_quick_strengthen_equip", data, cb)
end

function MsgChannel:SendRefineEquipment(data, cb)
    self:_SendMsgByProto("c_lineup_refine_equip", data, cb)
end

function MsgChannel:SendQuickRefineEquipment(data, cb)
    self:_SendMsgByProto("c_quick_refine_equip", data, cb)
end

function MsgChannel:SendAddEquipmentStar(data, cb)
    self:_SendMsgByProto("c_upgrade_equip_star_lv", data, cb)
end

function MsgChannel:SendSmeltEquipment(data, cb)
    self:_SendMsgByProto("c_equip_smelt", data, cb)
end
-- equip define end

-- 竞技场
function MsgChannel:SendGetArenaInfo(data, cb)
    self:_SendMsgByProto("c_get_arena_info", data, cb)
end

function MsgChannel:SendArenaChallenge(data, cb)
    self:_SendMsgByProto("c_arena_challenge", data, cb)
end

function MsgChannel:SendArenaSelectReward(data, cb)
    self:_SendMsgByProto("c_arena_select_reward", data, cb)
end

function MsgChannel:SendArenaQuickChallenge(data, cb)
    self:_SendMsgByProto("c_arena_quick_challenge", data, cb)
end

function MsgChannel:SendGetArenaRankList(data, cb)
    self:_SendMsgByProto("c_get_arena_rank_list", data, cb)
end

function MsgChannel:SendClearArenaInfo(data, cb)
    self:_SendMsgByProto("c_clear_arena_info", data, cb)
end

-- 挑战塔
function MsgChannel:SendDareTowerTreasureReward(data, cb)
    self:_SendMsgByProto("c_dare_tower_treasure_reward", data, cb)
end

function MsgChannel:SendDareTowerFight(data, cb)
    self:_SendMsgByProto("c_dare_tower_fight", data, cb)
end

-- dynasty define begin
-- 王朝创建和加入
function MsgChannel:SendCreateDynasty(data, cb)
    self:_SendMsgByProto("c_create_dynasty", data, cb)
end

function MsgChannel:SendGetDynastyList(data, cb)
    self:_SendMsgByProto("c_get_dynasty_list", data, cb)
end

function MsgChannel:SendSeekDynasty(data, cb)
    self:_SendMsgByProto("c_seek_dynasty", data, cb)
end

function MsgChannel:SendApplyDynasty(data, cb)
    self:_SendMsgByProto("c_apply_dynasty", data, cb)
end

function MsgChannel:SendCancelApplyDynasty(data, cb)
    self:_SendMsgByProto("c_cancel_apply_dynasty", data, cb)
end

-- 王朝总部
function MsgChannel:SendGetDynastyBasicInfo(data, cb)
    self:_SendMsgByProto("c_get_dynasty_base_info", data, cb)
end

function MsgChannel:SendGetDynastyRank(data, cb)
    self:_SendMsgByProto("c_get_dynasty_rank", data, cb)
end

function MsgChannel:SendQuitDynasty(data, cb)
    self:_SendMsgByProto("c_quit_dynasty", data, cb)
end

-- 王朝管理
function MsgChannel:SendGetDynastyMemberInfo(data, cb)
    self:_SendMsgByProto("c_get_dynasty_member_info", data, cb)
end

function MsgChannel:SendModifyDynastyBadge(data, cb)
    self:_SendMsgByProto("c_modify_dynasty_badge", data, cb)
end

function MsgChannel:SendModifyDynastyName(data, cb)
    self:_SendMsgByProto("c_modify_dynasty_name", data, cb)
end

function MsgChannel:SendModifyDynastyNotice(data, cb)
    self:_SendMsgByProto("c_modify_dynasty_notice", data, cb)
end

function MsgChannel:SendModifyDynastyDeclaration(data, cb)
    self:_SendMsgByProto("c_modify_dynasty_declaration", data, cb)
end

function MsgChannel:SendAgreeApplyDynasty(data, cb)
    self:_SendMsgByProto("c_agree_apply_dynasty", data, cb)
end

function MsgChannel:SendIgnoreApplyDynasty(data, cb)
    self:_SendMsgByProto("c_ignore_apply_dynasty", data, cb)
end

function MsgChannel:SendKickMember(data, cb)
    self:_SendMsgByProto("c_kick_out_dynasty", data, cb)
end

function MsgChannel:SendAppointMember(data, cb)
    self:_SendMsgByProto("c_appoint_dynasty_member", data, cb)
end

function MsgChannel:SendDissolveDynasty(data, cb)
    self:_SendMsgByProto("c_dissolve_dynasty", data, cb)
end

    -- 王朝事务所
function MsgChannel:SendGetDynastyBuildInfo(data, cb)
    self:_SendMsgByProto("c_get_dynasty_build_info", data, cb)
end

function MsgChannel:SendBuildDynasty(data, cb)
    self:_SendMsgByProto("c_dynasty_build", data, cb)
end

function MsgChannel:SendGetDynastyBuildReward(data, cb)
    self:_SendMsgByProto("c_get_dynasty_build_reward", data, cb)
end

function MsgChannel:SendGetDynastyActiveReward(data, cb)
    self:_SendMsgByProto("c_get_dynasty_active_reward", data, cb)
end

function MsgChannel:SendGetDynastyTaskReward(data, cb)
    self:_SendMsgByProto("c_get_dynasty_task_reward", data, cb)
end

-- 王朝科研所
function MsgChannel:SendStudyDynastySpell(data, cb)
    self:_SendMsgByProto("c_study_dynasty_spell", data, cb)
end

function MsgChannel:SendUpgradeDynastySpell(data, cb)
    self:_SendMsgByProto("c_upgrade_dynasty_spell", data, cb)
end

-- 王朝挑战
function MsgChannel:SendGetDynastyChallengeInfo(data, cb)
    self:_SendMsgByProto("c_get_dynasty_challenge_info", data, cb)
end

function MsgChannel:SendGetDynastyChallengeRank(data, cb)
    self:_SendMsgByProto("c_get_dynasty_challenge_rank", data, cb)
end

function MsgChannel:SendGetChallengeAllReward(data, cb)
    self:_SendMsgByProto("c_get_challenge_all_reward", data, cb)
end

function MsgChannel:SendBuyChallengeCount(data, cb)
    self:_SendMsgByProto("c_buy_dynasty_challenge_num", data, cb)
end

function MsgChannel:SendChangeChallengeSetting(data, cb)
    self:_SendMsgByProto("c_dynasty_challenge_setting", data, cb)
end

function MsgChannel:SendChallengeJanitor(data, cb)
    self:_SendMsgByProto("c_dynasty_challenge_janitor", data, cb)
end

function MsgChannel:SendGetChallengeStageReward(data, cb)
    self:_SendMsgByProto("c_get_challenge_stage_reward", data, cb)
end

function MsgChannel:SendGetJanitorBoxReward(data, cb)
    self:_SendMsgByProto("c_get_challenge_janitor_box", data, cb)
end

--王朝争霸
function MsgChannel:SendGetDynastyCompeteInfo(data, cb)
    self:_SendMsgByProto("c_get_dynasty_compete_info", data, cb)
end

function MsgChannel:SendApplyDynastyCompete(data, cb)
    self:_SendMsgByProto("c_dynasty_compete_apply", data, cb)
end

function MsgChannel:SendDefendDynastyBuilding(data, cb)
    self:_SendMsgByProto("c_dynasty_building_defend", data, cb)
end

function MsgChannel:SendDynastyCompeteFight(data, cb)
    self:_SendMsgByProto("c_dynasty_compete_fight", data, cb)
end

function MsgChannel:SendBuyCompeteAttackNum(data, cb)
    self:_SendMsgByProto("c_buy_compete_attack_num", data, cb)
end

function MsgChannel:SendGetCompeteDefendInfo(data, cb)
    self:_SendMsgByProto("c_get_compete_defend_info", data, cb)
end

function MsgChannel:SendGetCompeteMemberMarkInfo(data, cb)
    self:_SendMsgByProto("c_get_compete_member_mark_info", data, cb)
end

function MsgChannel:SendGetCompeteRewardInfo(data, cb)
    self:_SendMsgByProto("c_get_compete_reward_info", data, cb)
end

function MsgChannel:SendGetCompeteReward(data, cb)
    self:_SendMsgByProto("c_get_compete_reward", data, cb)
end

function MsgChannel:SendGetCompeteDynastyRank(data, cb)
    self:_SendMsgByProto("c_get_compete_dynasty_rank", data, cb)
end

function MsgChannel:SendGetCompeteRoleRank(data, cb)
    self:_SendMsgByProto("c_get_compete_role_rank", data, cb)
end
-- dynasty define end

--  试炼

function MsgChannel:SendTrainChallengeStage(data, cb)
    self:_SendMsgByProto("c_train_challenge_stage", data, cb)
end

function MsgChannel:SendTrainQuickChallenge(data, cb)
    self:_SendMsgByProto("c_train_quick_challenge", data, cb)
end

function MsgChannel:SendTrainSelectAddAttr(data, cb)
    self:_SendMsgByProto("c_train_select_add_attr", data, cb)
end

function MsgChannel:SendTrainResetStage(data, cb)
    self:_SendMsgByProto("c_train_reset_stage", data, cb)
end

function MsgChannel:SendTrainSweepStage(data, cb)
    self:_SendMsgByProto("c_train_sweep_stage", data, cb)
end

function MsgChannel:SendTrainBuyTreasure(data, cb)
    self:_SendMsgByProto("c_train_buy_treasure", data, cb)
end

function MsgChannel:SendTrainGetRank(data, cb)
    self:_SendMsgByProto("c_train_get_rank", data, cb)
end

function MsgChannel:SendTrainWarChallenge(data, cb)
    self:_SendMsgByProto("c_train_war_challenge", data, cb)
end

function MsgChannel:SendTrainWarBuyFightNum(data, cb)
    self:_SendMsgByProto("c_train_war_buy_fight_num", data, cb)
end

-- 派对
function MsgChannel:SendPartyStart(data, cb)
    self:_SendMsgByProto("c_party_start", data, cb)
end

function MsgChannel:SendPartyInviteRole(data, cb)
    self:_SendMsgByProto("c_party_invite_role", data, cb)
end

function MsgChannel:SendPartyRefuseInvite(data, cb)
    self:_SendMsgByProto("c_party_refuse_invite", data, cb)
end

function MsgChannel:SendPartyEnd(data, cb)
    self:_SendMsgByProto("c_party_end", data, cb)
end

function MsgChannel:SendPartyRandom(data, cb)
    self:_SendMsgByProto("c_party_random", data, cb)
end

function MsgChannel:SendPartyJoin(data, cb)
    self:_SendMsgByProto("c_party_join", data, cb)
end

function MsgChannel:SendPartyInterrupt(data, cb)
    self:_SendMsgByProto("c_party_interrupt", data, cb)
end

function MsgChannel:SendPartyGames(data, cb)
    self:_SendMsgByProto("c_party_games", data, cb)
end

function MsgChannel:SendPartyReceiveIntegral(data, cb)
    self:_SendMsgByProto("c_party_receive_integral", data, cb)
end

function MsgChannel:SendGetPartyInfo(data, cb)
    self:_SendMsgByProto("c_get_party_info", data, cb)
end

function MsgChannel:SendPartyGetEnemyList(data, cb)
    self:_SendMsgByProto("c_party_get_enemy_list", data, cb)
end

function MsgChannel:SendPartyGetRecordList(data, cb)
    self:_SendMsgByProto("c_party_get_record_list", data, cb)
end

function MsgChannel:SendPartyGetRank(data, cb)
    self:_SendMsgByProto("c_party_get_rank", data, cb)
end

function MsgChannel:SendFindParty(data, cb)
    self:_SendMsgByProto("c_find_party", data, cb)
end

function MsgChannel:SendPartySetReceiveInvite(data, cb)
    self:_SendMsgByProto("c_party_set_receive_invite", data, cb)
end

function MsgChannel:SendPartyGetInviteList(data, cb)
    self:_SendMsgByProto("c_party_get_invite_list", data, cb)
end

-- decompose define begin
function MsgChannel:SendDecomposeItem(data, cb)
    self:_SendMsgByProto("c_decompose_item", data, cb)
end

function MsgChannel:SendRecoverEquip(data, cb)
    self:_SendMsgByProto("c_equip_recover", data, cb)
end

function MsgChannel:SendRecoverHero(data, cb)
    self:_SendMsgByProto("c_hero_recover", data, cb)
end
-- decompose define end

--  邮件
function MsgChannel:SendDeleteMail(data, cb)
    self:_SendMsgByProto("c_delete_mail", data, cb)
end

function MsgChannel:SendReadMail(data, cb)
    self:_SendMsgByProto("c_read_mail", data, cb)
end

function MsgChannel:SendGetMailItem(data, cb)
    self:_SendMsgByProto("c_get_mail_item", data, cb)
end

function MsgChannel:SendGetAllMail(data, cb)
    self:_SendMsgByProto("c_get_all_mail", data, cb)
end

-- 主线任务
function MsgChannel:SendGetTaskGroupReward(data, cb)
    self:_SendMsgByProto("c_get_task_group_reward", data, cb)
end

function MsgChannel:SendGetTaskReward(data, cb)
    self:_SendMsgByProto("c_get_task_reward", data, cb)
end

--  商店
function MsgChannel:SendBuyTrainShopItem(data, cb)
    self:_SendMsgByProto("c_train_buy_shop_item", data, cb)
end

function MsgChannel:SendBuyArenaShopItem(data, cb)
    self:_SendMsgByProto("c_arena_buy_shop_item", data, cb)
end

function MsgChannel:SendBuySalonShopItem(data, cb)
    self:_SendMsgByProto("c_buy_salon_shop_item", data, cb)
end

function MsgChannel:SendBuyHuntShopItem(data, cb)
    self:_SendMsgByProto('c_hunt_point_exchange', data, cb)
end

function MsgChannel:SendBuyPartyShopItem(data, cb)
    self:_SendMsgByProto("c_buy_party_shop_item", data, cb)
end

function MsgChannel:SendBuyNormalShopItem(data, cb)
    self:_SendMsgByProto("c_buy_normal_shop_item", data, cb)
end

function MsgChannel:SendRefreshSalonShop(data, cb)
    self:_SendMsgByProto("c_refresh_salon_shop", data, cb)
end

function MsgChannel:SendRefreshPartyShop(data, cb)
    self:_SendMsgByProto("c_refresh_party_shop", data, cb)
end

function MsgChannel:SendRefreshHuntShop(data, cb)
    self:_SendMsgByProto("c_refresh_hunt_shop", data, cb)
end

function MsgChannel:SendBuyCrystalShopItem(data, cb)
    self:_SendMsgByProto("c_buy_crystal_shop_item", data, cb)
end

function MsgChannel:SendBuyHeroShopItem(data, cb)
    self:_SendMsgByProto("c_buy_hero_shop_item", data, cb)
end

function MsgChannel:SendRefreshHeroShopItem(data, cb)
    self:_SendMsgByProto("c_refresh_hero_shop", data, cb)
end

function MsgChannel:SendBuyLoverShopItem(data, cb)
    self:_SendMsgByProto("c_buy_lover_shop_item", data, cb)
end

function MsgChannel:SendRefreshLoverShopItem(data, cb)
    self:_SendMsgByProto("c_refresh_lover_shop", data, cb)
end

function MsgChannel:SendBuyRechargeDrawIntegralShop(data, cb)
    self:_SendMsgByProto("c_buy_recharge_draw_integral_shop", data, cb)
end

function MsgChannel:SendBuyFeatsShopItem(data, cb)
    self:_SendMsgByProto("c_buy_traitor_shop_item", data, cb)
end

function MsgChannel:SendBuyDynastyShopItem(data, cb)
    self:_SendMsgByProto("c_buy_dynasty_shop_item", data, cb)
end

--  福利
function MsgChannel:SendCheckInWeekly(data, cb)
    self:_SendMsgByProto("c_check_in_weekly", data, cb)
end

function MsgChannel:SendCkeckInMonthly(data, cb)
    self:_SendMsgByProto("c_check_in_monthly", data, cb)
end

function MsgChannel:SendCheckInMonthlyChest(data, cb)
    self:_SendMsgByProto("c_check_in_monthly_chest", data, cb)
end

function MsgChannel:SendFirstWeekReciveReward(data, cb)
    self:_SendMsgByProto("c_first_week_recive_reward", data, cb)
end

function MsgChannel:SendFirstWeekBuyHalfSell(data, cb)
    self:_SendMsgByProto("c_first_week_buy_half_sell", data, cb)
end

function MsgChannel:SendFirstWeekBuySellItem(data, cb)
    self:_SendMsgByProto("c_first_week_buy_sell_item", data, cb)
end

function MsgChannel:SendGetRankList(data, cb)
    self:_SendMsgByProto("c_get_rank_list", data, cb)
end

-- 日常活跃
function MsgChannel:SendReceiveActiveTaskReward(data, cb)
    self:_SendMsgByProto("c_receive_active_task_reward", data, cb)
end

function MsgChannel:SendReceiveActiveChestReward(data, cb)
    self:_SendMsgByProto("c_receive_active_chest_reward", data, cb)
end
--日常活跃 end

-- 成就
function MsgChannel:SendGetAchievementReward(data, cb)
    self:_SendMsgByProto("c_get_achievement_reward", data, cb)
end
-- 成就 end

--  好友
function MsgChannel:SendFriendGift(data, cb)
    self:_SendMsgByProto("c_send_friend_gift", data, cb)
end

function MsgChannel:SendAllFriendGift(data, cb)
    self:_SendMsgByProto("c_send_all_friend_gift", data, cb)
end

function MsgChannel:SendGetAllFriendInfo(data, cb)
    self:_SendMsgByProto("c_get_all_friend_info", data, cb)
end

function MsgChannel:SendReciveFriendGift(data, cb)
    self:_SendMsgByProto("c_receive_friend_gift", data, cb)
end

function MsgChannel:SendReciveAllFriendGift(data, cb)
    self:_SendMsgByProto("c_receive_all_friend_gift", data, cb)
end

function MsgChannel:SendGetReciveGiftInfo(data, cb)
    self:_SendMsgByProto("c_get_receive_gift_info", data, cb)
end

function MsgChannel:SendConfirmFriendApply(data, cb)
    self:_SendMsgByProto("c_confirm_friend_apply", data, cb)
end

function MsgChannel:SendConfirmAllFriendApply(data, cb)
    self:_SendMsgByProto("c_confirm_all_friend_apply", data, cb)
end

function MsgChannel:SendConfuseFriendApply(data, cb)
    self:_SendMsgByProto("c_confuse_friend_apply", data, cb)
end

function MsgChannel:SendConfuseAllFriendApply(data, cb)
    self:_SendMsgByProto("c_confuse_all_friend_apply", data, cb)
end

function MsgChannel:SendApplyFriend(data, cb)
    self:_SendMsgByProto("c_apply_friend", data, cb)
end

function MsgChannel:SendGetFriendApplyList(data, cb)
    self:_SendMsgByProto("c_get_friend_apply_list", data, cb)
end

function MsgChannel:SendDeleteFriend(data, cb)
    self:_SendMsgByProto("c_delete_friend", data, cb)
end

function MsgChannel:SendAddFriendToBlackList(data, cb)
    self:_SendMsgByProto("c_add_friend_to_blacklist", data, cb)
end

function MsgChannel:SendRemoveFriendInBlackList(data, cb)
    self:_SendMsgByProto("c_remove_friend_in_blacklist", data, cb)
end

function MsgChannel:SendRemoveAllFriendInBlackList(data, cb)
    self:_SendMsgByProto("c_remove_all_friend_in_blacklist", data, cb)
end

function MsgChannel:SendDeleteFriendInBlackList(data, cb)
    self:_SendMsgByProto("c_delete_friend_in_blacklist", data, cb)
end

function MsgChannel:SendDeleteAllFriendInBlackList(data, cb)
    self:_SendMsgByProto("c_delete_all_friend_in_blacklist", data, cb)
end

function MsgChannel:SendGetAllBlackListFriend(data, cb)
    self:_SendMsgByProto("c_get_all_blacklist_friend", data, cb)
end

function MsgChannel:SendRefuseFriendApply(data, cb)
    self:_SendMsgByProto("c_refuse_friend_apply", data, cb)
end

function MsgChannel:SendRefuseAllFriendApply(data, cb)
    self:_SendMsgByProto("c_refuse_all_friend_apply", data, cb)
end

function MsgChannel:SendGetRecommendFriend(data, cb)
    self:_SendMsgByProto("c_get_recommend_friend", data, cb)
end

function MsgChannel:SendFightWithFriend(data, cb)
    self:_SendMsgByProto("c_fight_with_friend", data, cb)
end

function MsgChannel:SendSendMailToFriend(data, cb)
    self:_SendMsgByProto("c_send_mail_to_friend", data, cb)
end

function MsgChannel:SendSearchFriend(data, cb)
    self:_SendMsgByProto("c_search_friend", data, cb)
end

-- 玩家信息
function MsgChannel:SendModifyRoleName(data, cb)
    self:_SendMsgByProto("c_modify_role_name", data, cb)
end

function MsgChannel:SendModifyRoleImage(data, cb)
    self:_SendMsgByProto("c_modify_role_image", data, cb)
end

function MsgChannel:SendModifyRoleFlag(data, cb)
    self:_SendMsgByProto("c_modify_role_flag", data, cb)
end

-- 限时活动
function MsgChannel:SendGetActivityReward(data, cb)
    self:_SendMsgByProto("c_activity_get_reward", data, cb)
end

function MsgChannel:SendGetActivityRank(data, cb)
    self:_SendMsgByProto("c_activity_get_rank", data, cb)
end

function MsgChannel:SendPickFestivalActivity(data, cb)
    self:_SendMsgByProto("c_pick_festival_activity_reward", data, cb)
end

function MsgChannel:SendBuyFestivalActivityDiscount(data, cb)
    self:_SendMsgByProto("c_buy_festival_activity_discount", data, cb)
end

function MsgChannel:SendGetFestivalActivityExchange(data, cb)
    self:_SendMsgByProto("c_get_festival_activity_exchange", data, cb)
end

-- 情人升星
function MsgChannel:SendLoverAddStar(data, cb)
    self:_SendMsgByProto("c_upgrade_lover_star_lv", data, cb)
end

--  充值创建订单
function MsgChannel:SendCreateOrder(data, cb)
    self:_SendMsgByProto("c_create_order", data, cb)
end

--  充值
function MsgChannel:SendRecharge(data, cb)
    self:_SendMsgByProto("c_recharge", data, cb)
end

function MsgChannel:SendReciveFirstRechargeReward(data, cb)
    self:_SendMsgByProto("c_receive_first_recharge_reward", data, cb)
end

function MsgChannel:SendReciveSingleRechargeReward(data, cb)
    self:_SendMsgByProto("c_receive_single_recharge_reward", data, cb)
end

function MsgChannel:SendDoRechargeDraw(data, cb)
    self:_SendMsgByProto("c_do_recharge_draw", data, cb)
end

function MsgChannel:SendGetRechargeDrawAwardInfo(data, cb)
    self:_SendMsgByProto("c_get_recharge_draw_award_info", data, cb)
end

function MsgChannel:SendReciveLuxuryRechargeReward(data, cb)
    self:_SendMsgByProto("c_receiving_luxurycheckin_reward", data, cb)
end

function MsgChannel:SendReceiveAccumRechargeReward(data, cb)
    self:_SendMsgByProto("c_receiving_accum_recharge_reward", data, cb)
end

--  冲榜活动
function MsgChannel:SendGetRankActivityList(data, cb)
    self:_SendMsgByProto("c_rush_activity_get_rank", data, cb)
end

function MsgChannel:SendRefreshRankActivity(data, cb)
    self:_SendMsgByProto("c_rush_activity_get_self_rank", data, cb)
end

--  定点体力
function MsgChannel:SendGetStrengthRecoverReward(data, cb)
    self:_SendMsgByProto("c_get_fixed_action_point_reward", data, cb)
end

--  开服基金
function MsgChannel:SendBuyServerFund(data, cb)
    self:_SendMsgByProto("c_buy_openservice_fund", data, cb)
end

function MsgChannel:SendGetServerFundReward(data, cb)
    self:_SendMsgByProto("c_get_openservice_fund_reward", data, cb)
end

function MsgChannel:SendGetFundWelfareReward(data, cb)
    self:_SendMsgByProto("c_get_openservice_welfare_reward", data, cb)
end

--vip
function MsgChannel:SendReceiveVipDailyGift(data, cb)
    self:_SendMsgByProto("c_receive_vip_daily_gift", data, cb)
end

function MsgChannel:SendGetVipGift(data, cb)
    self:_SendMsgByProto("c_get_vip_gift", data, cb)
end

function MsgChannel:SendBuyVipShopItem(data, cb)
    self:_SendMsgByProto("c_buy_vip_shop_item", data, cb)
end

--称号
function MsgChannel:SendWorshipGodfather(data, cb)
    self:_SendMsgByProto("c_worship_godfather", data, cb)
end

function MsgChannel:SendGetChurchData(data, cb)
    self:_SendMsgByProto("c_get_godfather_hall_data", data, cb)
end

--  叛军boss
function MsgChannel:SendEnterTraitorBoss(data, cb)
    self:_SendMsgByProto("c_enter_traitor_boss", data, cb)
end

function MsgChannel:SendQuitTraitorBoss(data, cb)
    self:_SendMsgByProto("c_quit_traitor_boss", data, cb)
end

function MsgChannel:SendGetTraitorBossData(data, cb)
    self:_SendMsgByProto("c_get_traitor_boss_data", data, cb)
end

function MsgChannel:SendChallengeTraitorBoss(data, cb)
    self:_SendMsgByProto("c_challenge_traitor_boss", data, cb)
end

function MsgChannel:SendGetTraitorBossDynastyRank(data, cb)
    self:_SendMsgByProto("c_get_traitor_boss_dynasty_rank", data, cb)
end

function MsgChannel:SendGetTraitorBossReward(data, cb)
    self:_SendMsgByProto("c_get_traitor_boss_reward", data, cb)
end

function MsgChannel:SendBuyTraitorBossChallengeNum(data, cb)
    self:_SendMsgByProto("c_buy_traitor_boss_challenge_num", data, cb)
end

function MsgChannel:SendGetTraitorBossRecord(data, cb)
    self:_SendMsgByProto("c_get_traitor_boss_record", data, cb)
end

function MsgChannel:SendEnterCrossTraitorBoss(data, cb)
    self:_SendMsgByProto("c_enter_cross_traitor_boss", data, cb)
end

function MsgChannel:SendQuitCrossTraitorBoss(data, cb)
    self:_SendMsgByProto("c_quit_cross_traitor_boss", data, cb)
end

function MsgChannel:SendGetCrossTraitorBossData(data, cb)
    self:_SendMsgByProto("c_get_cross_traitor_boss_data", data, cb)
end

function MsgChannel:SendCrossTraitorBossOccupyPos(data, cb)
    self:_SendMsgByProto("c_cross_traitor_boss_occupy_pos", data, cb)
end
-- 普通叛军
function MsgChannel:SendChallengeTraitor(data, cb)
    self:_SendMsgByProto("c_challenge_traitor", data, cb)
end

function MsgChannel:SendShareTraitor(data, cb)
    self:_SendMsgByProto("c_share_traitor", data, cb)
end

function MsgChannel:SendAddTraitorChallengeTicket(data, cb)
    self:_SendMsgByProto("c_add_traitor_challenge_ticket", data, cb)
end

function MsgChannel:SendFriendTraitorList(data, cb)
    self:_SendMsgByProto("c_get_traitor_list", data, cb)
end

function MsgChannel:SendGetFeatsReward(data, cb)
    self:_SendMsgByProto("c_get_feats_reward", data, cb)
end

function MsgChannel:SendBuyTraitorShopItem(data, cb)
    self:_SendMsgByProto("c_buy_traitor_shop_item", data, cb)
end

function MsgChannel:SendSetTraitorAutoKill(data, cb)
    self:_SendMsgByProto("c_traitor_set_auto_kill", data, cb)
end

function MsgChannel:SendGetTraitorInfo(data, cb)
    self:_SendMsgByProto("c_get_traitor_info", data, cb)
end

--------------- title start
function MsgChannel:SendWearingTitle(data, cb)
    self:_SendMsgByProto("c_wearing_title", data, cb)
end

function MsgChannel:SendUnwearingTitle(data, cb)
    self:_SendMsgByProto("c_unwearing_title", data, cb)
end
--------------- title end

function MsgChannel:SendGetMaxHurtRank(data, cb)
    self:_SendMsgByProto("c_get_traitor_max_hurt_rank", data, cb)
end

function MsgChannel:SendGetPlayerInfo(data, cb)
    self:_SendMsgByProto("c_get_role_base_info", data, cb)
end

--  月卡订单
function MsgChannel:SendCreateMonthlyCardOrder(data, cb)
    self:_SendMsgByProto("c_create_yueka_order", data, cb)
end

--  月卡
function MsgChannel:SendBuyMonthlyCard(data, cb)
    self:_SendMsgByProto("c_buy_monthly_card", data, cb)
end

function MsgChannel:SendReceivingMonthlyCardReward(data, cb)
    self:_SendMsgByProto("c_receiving_monthly_card_reward", data, cb)
end

-- 酒吧
function MsgChannel:SendCheckCanJoinBarGame(data, cb)
    self:_SendMsgByProto("c_can_play_bar_game", data, cb)
end

function MsgChannel:SendBarGeneralChallenge(data, cb)
    self:_SendMsgByProto("c_bar_general_challenge", data, cb)
end

function MsgChannel:SendBarQuickChallenge(data, cb)
    self:_SendMsgByProto("c_bar_quick_challenge", data, cb)
end

function MsgChannel:SendBuyBarChallengeCount(data, cb)
    self:_SendMsgByProto("c_buy_bar_challenge_count", data, cb)
end

function MsgChannel:SendRefreshBarUnit(data, cb)
    self:_SendMsgByProto("c_refresh_bar_unit", data, cb)
end

--  评论
function MsgChannel:SendCommentSetting(data, cb)
    self:_SendMsgByProto("c_comment_setting", data, cb)
end

function MsgChannel:SendSaveComment(data, cb)
    self:_SendMsgByProto("c_save_comment", data, cb)
end

--  获取上阵信息
function MsgChannel:SendGetLineUp(data, cb)
    self:_SendMsgByProto("c_get_lineup", data, cb)
end

--主页面排行榜
function MsgChannel:SendGetPowerRank(data, cb)
    self:_SendMsgByProto("c_get_cross_fight_score_rank_list", data, cb)
end

function MsgChannel:SendGetLevelsRank(data, cb)
    self:_SendMsgByProto("c_get_cross_stage_start_rank_list", data, cb)
end

function MsgChannel:SendGetGangRank(data, cb)
    self:_SendMsgByProto("c_get_cross_score_rank_list", data, cb)
end

function MsgChannel:SendGetDynastyCrossRank(data, cb)
    --self:_SendMsgByProto("c_get_cross_score_rank_list", data, cb)
end

return MsgChannel