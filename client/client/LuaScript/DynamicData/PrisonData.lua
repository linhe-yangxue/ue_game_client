local EventUtil = require("BaseUtilities.EventUtil")
local PrisonData = class("DynamicData.PrisonData")
local UIFuncs = require("UI.UIFuncs")
local CSFunction = require("CSCommon.CSFunction")

EventUtil.GeneratorEventFuncs(PrisonData, "UpdatePrisonData")

function PrisonData:DoInit()
    self.prison_data = {}
end

function PrisonData:UpdatePrisonData(msg)
    for k, v in pairs(msg) do
        if k == "criminal_num" then
            if self.prison_data.criminal_num and self.prison_data.criminal_num <= v then
                self:RegisterShowGetCriminal(v)
            end
        end
        self.prison_data[k] = v
    end
    self:DispatchUpdatePrisonData(msg)
    local torture_num = self:GetTortureNum(SpecMgrs.data_mgr:GetTortureData(1))
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Prison, {torture_num})
end

function PrisonData:RegisterShowGetCriminal(prison_id)
    if not SpecMgrs.data_mgr:GetPrisonData(prison_id) then return end
    SpecMgrs.ui_mgr:RegisterHideUIEvent("PrisonData",function (_, ui)
        if ui.class_name == "BattleResultUI" then
            SpecMgrs.ui_mgr:ShowUI("NotifyPrisonUI", prison_id)
            SpecMgrs.ui_mgr:UnregisterHideUIEvent("PrisonData")
        end
    end)
end

function PrisonData:GetPrisonData()
    return self.prison_data
end

function PrisonData:GetTortureNum(torture_data)
    if not self.prison_data or not self.prison_data.criminal_id then return end
    local prestige_item_id = CSConst.Virtual.Prestige
    local remain_torture_num = self.prison_data.torture_remain_num
    local prestige_cost = SpecMgrs.data_mgr:GetPrisonData(self.prison_data.criminal_id).prestige_cost
    local prestige_num = ComMgrs.dy_data_mgr:ExGetItemCount(prestige_item_id)
    local max_cost_prestige_num = prestige_num ~= 0 and math.floor(prestige_num / prestige_cost) or 0
    local final_torture_num = math.min(remain_torture_num, max_cost_prestige_num)
    if final_torture_num <= 0 then return final_torture_num , prestige_item_id end
    if not torture_data.cost_item_id_list then
        return final_torture_num
    end
    for k, item_id in ipairs(torture_data.cost_item_id_list) do
        local item_count = ComMgrs.dy_data_mgr:ExGetItemCount(item_id)
        local max_cost_num = math.floor(item_count / torture_data.cost_num_list[k])
        if max_cost_num <= 0 then
            return max_cost_num, item_id
        end
        final_torture_num = math.min(final_torture_num, max_cost_num)
    end
    return final_torture_num
end

return PrisonData