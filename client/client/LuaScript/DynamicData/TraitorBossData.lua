local EventUtil = require("BaseUtilities.EventUtil")
local UIConst = require("UI.UIConst")
local CSConst = require("CSCommon.CSConst")
local TraitorBossData = class("DynamicData.TraitorBossData")

EventUtil.GeneratorEventFuncs(TraitorBossData, "UpdateTraitorBossInfo")
EventUtil.GeneratorEventFuncs(TraitorBossData, "TraitorBossInfoRevive")
EventUtil.GeneratorEventFuncs(TraitorBossData, "UpdateCrossTraitorFight")
EventUtil.GeneratorEventFuncs(TraitorBossData, "UpdateCrossTraitorInfo")
EventUtil.GeneratorEventFuncs(TraitorBossData, "UpdateTraitorChallengeNum")

function TraitorBossData:DoInit()
    self.is_open = false
    self.challenge_time = 0
    self.challenge_num_ts = 0
    self.traitor_boss_info = {}
    self.cross_traitor_fight_info = {}
    self.cross_traitor_info = {}
    self.next_challenge_time = nil
    self.challenge_boss_cd = 3
end

function TraitorBossData:SetTraitorOpen(is_open)
    self.is_open = is_open
end

function TraitorBossData:UpdateTraitorChallengeNum(msg)
    self.challenge_time = msg.challenge_num
    self.challenge_num_ts = msg.challenge_num_ts
    self:DispatchUpdateTraitorChallengeNum()
end

function TraitorBossData:UpdateTraitorBossInfo(msg)
    self.traitor_boss_info = msg
    self.traitor_boss_info.cur_hp = table.sum(msg.hp_dict)
    self:DispatchUpdateTraitorBossInfo()
end

function TraitorBossData:UpdateTraitorBossRevive(msg)
    self.traitor_boss_info = msg
    self.traitor_boss_info.cur_hp = table.sum(msg.hp_dict)
    self:DispatchTraitorBossInfoRevive()
end

function TraitorBossData:UpdateCrossCoolingTs(msg)
    self.challenge_cooling_ts = msg.cooling_ts
end

function TraitorBossData:UpdateCrossTraitorInfo(msg)
    self.cross_traitor_info = msg
    self:DispatchUpdateCrossTraitorInfo()
end

function TraitorBossData:UpdateCrossTraitorBossFight(msg)
    self.cross_traitor_fight_info = msg
    self:DispatchUpdateCrossTraitorFight()
end

function TraitorBossData:SetNextChallengeTime()
    self.next_challenge_time = Time:GetServerTime() + self.challenge_boss_cd
end

function TraitorBossData:CanChallengeBoss()
    if self.next_challenge_time then
        return self.next_challenge_time <= Time:GetServerTime()
    end
    return true
end
return TraitorBossData