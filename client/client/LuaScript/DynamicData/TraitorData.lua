local EventUtil = require("BaseUtilities.EventUtil")
local UIConst = require("UI.UIConst")
local TraitorData = class("DynamicData.TraitorData")

EventUtil.GeneratorEventFuncs(TraitorData, "TraitorDisappearEvent")
EventUtil.GeneratorEventFuncs(TraitorData, "UpdateWantedCountEvent")

function TraitorData:DoInit()
    self.traitor_challenge_cost = SpecMgrs.data_mgr:GetParamData("traitor_challenge_cost").f_value
    self.traitor_challenge_double_cost = SpecMgrs.data_mgr:GetParamData("traitor_challenge_double_cost").f_value
    self.traitor_halve_cost_time = SpecMgrs.data_mgr:GetParamData("traitor_challenge_halve_cost").tb_int
    self.traitor_halve_cost_start_time = self.traitor_halve_cost_time[1] * CSConst.Time.Hour
    self.traitor_halve_cost_end_time = self.traitor_halve_cost_time[2] * CSConst.Time.Hour
    self.traitor_info_data = {}
end

function TraitorData:NotifyUpdateTraitorInfo(msg)
    for k,v in pairs(msg) do
        self.traitor_info_data[k] = v
    end
    if msg.challenge_ticket then self:DispatchUpdateWantedCountEvent() end
    if msg.traitor_info then
        self:_UpdateTraitorRedPoint()
    end
    if msg.feats or msg.feats_reward then
        self:_UpdateTraitorRewardRedPoint()
    end
end

function TraitorData:NotifyAddTraitor(traitor_info)
    self.traitor_info_data.traitor_info = traitor_info
    self:_UpdateTraitorRedPoint()
end

function TraitorData:NotifyDeleteTraitor(msg)
    self.traitor_is_kill = msg.is_kill
    self.traitor_info_data.traitor_info = nil
    self:DispatchTraitorDisappearEvent()
    self:_UpdateTraitorRedPoint()
end

function TraitorData:GetTraitorInfo()
    return self.traitor_info_data.traitor_info
end

function TraitorData:GetWantedCount()
    return self.traitor_info_data.challenge_ticket or 0
end

function TraitorData:GetTraitorFeats()
    return self.traitor_info_data.feats or 0
end

function TraitorData:GetTraitorHurt()
    return self.traitor_info_data.total_hurt or 0
end

function TraitorData:GetTraitorSetting()
    local traitor_setting = {}
    for k, v in pairs(self.traitor_info_data.auto_kill) do
        traitor_setting[k] = v
    end
    return traitor_setting
end

function TraitorData:GetTraitorName(traitor_id, traitor_quality, change_color)
    local traitor_data = SpecMgrs.data_mgr:GetTraitorData(traitor_id)
    for i, quality in pairs(traitor_data.quality_list) do
        if quality == traitor_quality then
            local traitor_name = traitor_data.name[i]
            if change_color then
                local quality_data = SpecMgrs.data_mgr:GetQualityData(quality)
                traitor_name = string.format(UIConst.Text.SIMPLE_COLOR, quality_data.color1, traitor_name)
            end
            return traitor_name
        end
    end
end

function TraitorData:CheckTraitorShareState(traitor_info)
    if self.traitor_info_data.traitor_info then
        if traitor_info.traitor_guid == self.traitor_info_data.traitor_info.traitor_guid then
            return not traitor_info.is_share
        end
    end
    return false
end

function TraitorData:CalcTraitorHp(traitor_info)
    local cur_hp = 0
    if traitor_info and traitor_info.hp_dict then
        for _, hp in pairs(traitor_info.hp_dict) do
            cur_hp = cur_hp + hp
        end
    end
    return cur_hp
end

function TraitorData:CheckIsHalveCostTime()
    local cur_time = Time:GetServerTime()
    local day_start_time = cur_time - Time:GetCurDayPassTime()
    local start_time = self.traitor_halve_cost_start_time + day_start_time
    local end_time = self.traitor_halve_cost_end_time + day_start_time
    return cur_time > start_time and cur_time < end_time
end

function TraitorData:CheckWantedCountEnough(wanted_cost)
    local cost = self:CheckIsHalveCostTime() and math.ceil(wanted_cost / 2) or wanted_cost
    return self.traitor_info_data.challenge_ticket >= cost
end

function TraitorData:GetFeatsRewardList()
    local reward_list = {}
    for id, reward_data in pairs(SpecMgrs.data_mgr:GetAllTraitorRewardData()) do
        if self.traitor_info_data.feats_reward[id] then
            reward_data.state = CSConst.RewardState.picked
        elseif self.traitor_info_data.feats >= reward_data.require_feats then
            reward_data.state = CSConst.RewardState.pick
        else
            reward_data.state = CSConst.RewardState.unpick
        end
        table.insert(reward_list, reward_data)
    end
    table.sort(reward_list, function (reward1, reward2)
        if reward1.state ~= reward2.state then
            if reward1.state == CSConst.RewardState.picked or reward2.state == CSConst.RewardState.picked then
                return reward2.state == CSConst.RewardState.picked
            end
        end
        return reward2.require_feats > reward1.require_feats
    end)
    return reward_list
end

function TraitorData:GetTraitorQualityList()
    local quality_list = {}
    for _, quality_data in pairs(SpecMgrs.data_mgr:GetAllQualityData()) do
        if quality_data.traitor_quality_name then
            table.insert(quality_list, quality_data)
        end
    end
    table.sort(quality_list, function (quality1, quality2)
        return quality2.id > quality1.id
    end)
    return quality_list
end

--更新特工红点
function TraitorData:_UpdateTraitorRedPoint()
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Playment.Traitor, {self.traitor_info_data.traitor_info and 1 or 0})
end

--更新特工奖励红点
function TraitorData:_UpdateTraitorRewardRedPoint()
    local param_dict = {}
    local reward_list = self:GetFeatsRewardList()
    for _, reward_data in ipairs(reward_list) do
        if reward_data.state == CSConst.RewardState.pick then
            param_dict[reward_data.id] = 1
        end
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Playment.TraitorReward, param_dict)
end

return TraitorData