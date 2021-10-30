local EventUtil = require("BaseUtilities.EventUtil")
local UIFuncs = require("UI.UIFuncs")
local CSConst = require("CSCommon.CSConst")
local HuntingData = class("DynamicData.HuntingData")
local UIConst = require("UI.UIConst")

EventUtil.GeneratorEventFuncs(HuntingData, "UpdateHuntingGroundData")
EventUtil.GeneratorEventFuncs(HuntingData, "UpdateCurrentHuntingGroundData")
EventUtil.GeneratorEventFuncs(HuntingData, "ShowHuntingGroundKillAward")
EventUtil.GeneratorEventFuncs(HuntingData, "ShowRareAnimalKillAward")
EventUtil.GeneratorEventFuncs(HuntingData, "UpdateHuntingRareAnimalNum")
EventUtil.GeneratorEventFuncs(HuntingData, "UpdateHuntingShopData")
EventUtil.GeneratorEventFuncs(HuntingData, "UpdateRareAnimalData")
EventUtil.GeneratorEventFuncs(HuntingData, "UpdateHuntingRareAnimalData")
EventUtil.GeneratorEventFuncs(HuntingData, "UpdateHuntingRareAnimalRankingPanel")

local not_show_notice_rare_animal_ui_list = {
    "HuntingRareAnimalUI",
    "HuntingGroundUI",
    "HeroBattleUI",
    "SoldierBattleUI",
}

function HuntingData:DoInit()
    self.max_hunt_rare_animal_num = SpecMgrs.data_mgr:GetParamData("hunt_rare_animal_num").f_value
    self.max_challenge_cool_time = SpecMgrs.data_mgr:GetParamData("hunt_rare_animal_time").f_value * 60 -- 转换成秒
    self.add_rare_animal_data_list = SpecMgrs.data_mgr:GetAllAddRareAnimalData()
    self.hunt_ground = {}
    self.hunt_shop = {}
    self.hunting_rare_animal_data = {}
end

function HuntingData:UpdateHuntingData(msg)
    if msg.hunt_ground then
        for groud_id, ground_data in pairs (msg.hunt_ground) do
            self.hunt_ground[groud_id] = ground_data
            self:DispatchUpdateHuntingGroundData(groud_id)
            self:_UpdateRewardRedPoint()
        end
    end
    if msg.hunt_point then
        self.hunt_point = msg.hunt_point
        -- todo添加数值改变时间，等到背包做出来更改
    end
    if msg.hunt_num then
        self.hunting_rare_animal_num = msg.hunt_num
        self.last_challenge_cool_start_time = msg.hunt_ts
        self:DispatchUpdateHuntingRareAnimalNum()
        self:_UpdateRareAnimalRedPoint()
    end
    if msg.listen_animal then
        self.listen_animal = msg.listen_animal
    end
    if msg.hero_dict then
        self.hero_resting_dict = msg.hero_dict
    end
    if msg.add_hunt_num then
        self.add_hunt_num = msg.add_hunt_num
    end
end

function HuntingData:NotifyUpdateCurrGround(msg)
    local change_ground_btn_id = self.curr_ground or msg.curr_ground
    self.curr_ground = msg.curr_ground
    self:DispatchUpdateCurrentHuntingGroundData(change_ground_btn_id)
end

function HuntingData:NotifyRareAnimalAppear(msg)
    for _, ui_name in ipairs(not_show_notice_rare_animal_ui_list) do
        local ui = SpecMgrs.ui_mgr:GetUI(ui_name)
        if ui and ui.is_showing then
            return
        end
    end
    SpecMgrs.ui_mgr:ShowUI("NoticeRareAnimalUI", msg.animal_id)
end

function HuntingData:NotifyHuntGroundKillReward(msg)
    self:DispatchShowHuntingGroundKillAward(msg)
end

function HuntingData:NotifyHuntRareAnimalKillReward(msg)
    self:DispatchShowRareAnimalKillAward(msg)
end

function HuntingData:UpdateAllRareAnimalData()
    SpecMgrs.msg_mgr:SendGetAllRareAnimalData({}, function (resp)
        if resp.rare_animal then
            self.rare_animal_data_list = resp.rare_animal
            self:DispatchUpdateRareAnimalData(resp.rare_animal)
        end
    end)
end

function HuntingData:GetRareAnimalData(animal_id)
    return self.rare_animal_data_list[animal_id]
end

function HuntingData:UpdateHuntingRareAnimalData(animal_id)
    SpecMgrs.msg_mgr:SendGetRareAnimalData({animal_id = animal_id}, function (resp)
        if resp.errcode == 0 then
            self.hunting_rare_animal_data[resp.rare_animal.animal_id] = resp.rare_animal
            self:DispatchUpdateHuntingRareAnimalData(resp.rare_animal)
        end
    end)
end

function HuntingData:GetHuntingGroundDataList()
    return self.hunt_ground
end

function HuntingData:GetHuntingGroundData(ground_id)
    if not ground_id then return end
    return self.hunt_ground[ground_id]
end

function HuntingData:GetUnLockHuntingGroundCount()
    return #self.hunt_ground
end

function HuntingData:CheckGroundUnlock(ground_id, is_show_tip)
    local is_unlock = self.hunt_ground[ground_id] and true or false
    if not is_unlock and is_show_tip then
        local ground_data = SpecMgrs.data_mgr:GetHuntGroundData(ground_id)
        SpecMgrs.ui_mgr:ShowTipMsg(string.format(UIConst.Text.HUNTING_UNLOCK_LEVEL, ground_data.open_level))
    end
    return is_unlock
end

function HuntingData:GetHuntingPoint()
    return self.hunt_point
end

function HuntingData:GetListenAnimal()
    return self.listen_animal
end

function HuntingData:GetCurrentHutingGroundId()
    return self.curr_ground
end

function HuntingData:GetHuntRareAnimalNum()
    return self.hunting_rare_animal_num
end

function HuntingData:CheckCanHuntRareAnimal()
    return self.hunting_rare_animal_num and self.hunting_rare_animal_num > 0
end

function HuntingData:GetMaxHuntRareAnimalNum()
    return self.max_hunt_rare_animal_num
end

function HuntingData:GetAddHuntNum()
    return self.add_hunt_num or 0
end

function HuntingData:CheckAddHuntNum()
    return self:GetAddHuntNum() < self:GetMaxAddHuntNum()
end

function HuntingData:GetMaxAddHuntNum()
    return SpecMgrs.data_mgr:GetParamData("buy_rare_animal_num").f_value + ComMgrs.dy_data_mgr.vip_data:GetVipDataVal("buy_rare_animal_num")
end

function HuntingData:GetCurAddHuntData()
    if not self:CheckAddHuntNum() then return end
    local add_time = self:GetAddHuntNum() + 1
    return self.add_rare_animal_data_list[add_time] or self.add_rare_animal_data_list[#self.add_rare_animal_data_list]
end


function HuntingData:GetMyHuntRank(animal_id)
    return self.hunting_rare_animal_data[animal_id] and self.hunting_rare_animal_data[animal_id].self_rank
end

function HuntingData:GetChallengeCoolDownTime()
    local last_challenge_cool_start_time = self.last_challenge_cool_start_time
    if not last_challenge_cool_start_time then return end
    local max_cool_time = self.max_challenge_cool_time
    local next_cooldown_time = last_challenge_cool_start_time + max_cool_time
    local remain_time = next_cooldown_time - Time:GetServerTime()
    if remain_time < 0 then return end
    return remain_time
end

function HuntingData:GetRestingHeroDict()
    return self.hero_resting_dict
end

function HuntingData:RecoverHero(hero_id)
    self.hero_resting_dict[hero_id] = nil
end

function HuntingData:GiveUpHuntGround()
    self.curr_ground = nil
end

function HuntingData:ClearAll()

end

--狩猎首通奖励
function HuntingData:_UpdateRewardRedPoint()
    if not ComMgrs.dy_data_mgr.func_unlock_data:CheckFuncUnlock("Hunting") then return end
    local param_dict = {}
    for _, data in pairs(self.hunt_ground) do
        if data.first_reward then
            param_dict[data.ground_id] = 1
        end
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Hunting.Reward, param_dict)
end

--猎杀猛兽
function HuntingData:_UpdateRareAnimalRedPoint()
    if not ComMgrs.dy_data_mgr.func_unlock_data:CheckFuncUnlock("Hunting") then return end
    local param_dict = {self.hunting_rare_animal_num}
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Hunting.Rare, param_dict)
end

return HuntingData