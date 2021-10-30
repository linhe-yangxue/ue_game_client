local EventUtil = require("BaseUtilities.EventUtil")
local AchievementData = class("DynamicData.AchievementData")

EventUtil.GeneratorEventFuncs(AchievementData, "UpdateAchievementInfo")

function AchievementData:DoInit()
    self.achievement_dict = {}
end

function AchievementData:NotifyUpdateAchievementInfo(msg)
    if msg.achievement_dict then
        for k, v in pairs(msg.achievement_dict) do
            self.achievement_dict[k] = v
        end
        self:_UpdateRedPoint()
        self:DispatchUpdateAchievementInfo(msg)
    end
end

function AchievementData:_UpdateRedPoint()
    local param_dict = {}
    for achievement_id, data in pairs(self.achievement_dict) do
        if data.is_reach then
            param_dict[achievement_id] = 1
        end
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Achievement, param_dict)
end

function AchievementData:GetAchievementDict()
    return self.achievement_dict
end

function AchievementData:GetAchievementData(achievement_id)
    return self.achievement_dict and self.achievement_dict[achievement_id]
end

function AchievementData:GetSortedAchievementList()
    local sorted_achievement_type_list = {}
    local achievement_type_data_list = SpecMgrs.data_mgr:GetAllAchievementTypeData()
    local func_unlock_data = ComMgrs.dy_data_mgr.func_unlock_data
    for k, achievement_type_data in pairs(achievement_type_data_list) do
        if self:CheckAchievementShow(achievement_type_data) then
            table.insert(sorted_achievement_type_list, k)
        end
    end
    local status1
    local status2
    table.sort(sorted_achievement_type_list, function (id1, id2)
        status1 = self:GetAchievementStatus(self.achievement_dict[id1])
        status2 = self:GetAchievementStatus(self.achievement_dict[id2])
        if status1 ~= status2 then
            return status1 < status2
        end
        return id1 < id2
    end)
    return sorted_achievement_type_list
end

function AchievementData:CheckAchievementShow(achievement_type_data)
    if not achievement_type_data.func_unlock_id then return true end
    if ComMgrs.dy_data_mgr.func_unlock_data:IsFuncUnlock(achievement_type_data.func_unlock_id) then
        return true
    else
        return false
    end
end

function AchievementData:GetAchievementStatus(serv_achievement_data)
    if not serv_achievement_data then return 2 end -- 策划填完表 服务器没更新未完成
    local achievement_id = serv_achievement_data.achievement_id
    local is_reach = serv_achievement_data.is_reach
    if achievement_id and is_reach then -- 完成当前档次成就
        return 1
    elseif achievement_id and not is_reach then -- 未完成当前档次成就
        return 2
    else
        return 3 -- 完成所有成就
    end
end

return AchievementData