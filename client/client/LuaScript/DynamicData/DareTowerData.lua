local EventUtil = require("BaseUtilities.EventUtil")
local DareTowerData = class("DynamicData.DareTowerData")
local UIConst = require("UI.UIConst")
EventUtil.GeneratorEventFuncs(DareTowerData, "UpdateDareTowerInfo")

function DareTowerData:DoInit()
    self.dare_dict = {}
    self.treasure_dict = {}
    self.max_tower = 0
end

function DareTowerData:NotifyUpdateDareTowerInfo(msg)
    if msg.dare_dict then
        self.dare_dict = msg.dare_dict
    end
    if msg.max_tower then
        self.max_tower = msg.max_tower
    end
    if msg.treasure_dict then
        self.treasure_dict = msg.treasure_dict
    end
    if msg.pass_num then
        self.pass_num = msg.pass_num
        self:_UpdateDareTowerRedPoint()
    end
    self:DispatchUpdateDareTowerInfo(msg)
end

function DareTowerData:GetMaxTower()
    return self.max_tower
end

function DareTowerData:IsTowerUnlcok(tower_id)
    return tower_id <= self.max_tower
end

function DareTowerData:IsCurTower(tower_id)
    return tower_id == self.max_tower
end

function DareTowerData:IsTowerFighted(tower_id)
    return self.dare_dict[tower_id] and true or false
end

function DareTowerData:CheckTowerTreasureCanGet(tower_id)
    if self.max_tower <= tower_id then return false end
    if self.treasure_dict[tower_id] then return true end
    return nil
end

function DareTowerData:GetActionPoint()
    return ComMgrs.dy_data_mgr:ExGetActionPoint()
end
function DareTowerData:GetRemainFightTime()
    return self.pass_num or 0
end

function DareTowerData:CheckRemainFightTime(is_show_tips)
    local can_fight = self.pass_num and self.pass_num > 0
    if not can_fight and is_show_tips then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.FIGHT_TIME_NOT_ENOUGH)
    end
    return can_fight
end

function DareTowerData:_UpdateDareTowerRedPoint()
    if not ComMgrs.dy_data_mgr.func_unlock_data:CheckFuncUnlock("DareTower") then return end
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Playment.DareTower, {self.pass_num})
end

return DareTowerData