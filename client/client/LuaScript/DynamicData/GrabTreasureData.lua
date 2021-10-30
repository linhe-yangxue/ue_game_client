local EventUtil = require("BaseUtilities.EventUtil")
local CSConst = require("CSCommon.CSConst")
local GrabTreasureData = class("DynamicData.GrabTreasureData")
local ItemUtil = require("BaseUtilities.ItemUtil")

EventUtil.GeneratorEventFuncs(GrabTreasureData, "UpdateGrabTreasure")

function GrabTreasureData:DoInit()
    self.treasure_id_to_synthesize_num = {}
    self.can_smelt_treasure_list = {}
    self.is_guid_select = {}
    self.select_smelt_num = 0
end

function GrabTreasureData:NotifyOnLineGrabTreasure(msg)
    self.treasure_dict = {}
    for treasure_id, v in pairs(msg.treasure_dict) do -- 包括默认的可以合成的4个蓝色宝物
        self.treasure_dict[treasure_id] = v.fragment_dict
    end
    self:_UpdateAllTreasureSynthesizeNum()
end

function GrabTreasureData:NotifyUpdateGrabTreasure(msg)
    self.treasure_dict[msg.treasure_id] = msg.fragment_dict
    self:_UpdateAllTreasureSynthesizeNum()
    self:DispatchUpdateGrabTreasure()
end

function GrabTreasureData:GetTreasureDict()
    return self.treasure_dict
end

function GrabTreasureData:GetTreasurePieceDict(treasure_id)
    return self.treasure_dict[treasure_id]
end

function GrabTreasureData:GetTreasuerSynthesizeNum(treasure_id)
    return self.treasure_id_to_synthesize_num[treasure_id] or 0
end

function GrabTreasureData:GetFragMentNum(treasure_id, fragment_id)
    return self.treasure_dict[treasure_id] and self.treasure_dict[treasure_id][fragment_id] or 0
end

function GrabTreasureData:_UpdateAllTreasureSynthesizeNum()
    self.treasure_id_to_synthesize_num = {}
    for treasure_id, _ in pairs(self.treasure_dict) do
        self:_UpdateTreasureSynthesizeNum(treasure_id)
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Playment.GrabTreasure, self.treasure_id_to_synthesize_num)
end

function GrabTreasureData:_UpdateTreasureSynthesizeNum(treasure_id)
    local treasure_data = SpecMgrs.data_mgr:GetItemData(treasure_id)
    local all_fragment_list = treasure_data.fragment_list
    local cur_fragment_dict = self.treasure_dict[treasure_id]
    local num
    for k, fragment_id in ipairs(all_fragment_list) do
        if not cur_fragment_dict[fragment_id] then
            return
        end
        if num == nil then
            num = cur_fragment_dict[fragment_id]
        else
            num = math.min(num, cur_fragment_dict[fragment_id])
        end
    end
    self.treasure_id_to_synthesize_num[treasure_id] = num
end

function GrabTreasureData:SetSelectSmeltTreasure(is_guid_select)
    self.is_guid_select = is_guid_select
end

function GrabTreasureData:CheckVitalityIsEnough()
    local grab_treasure_cost_vitality = SpecMgrs.data_mgr:GetParamData("grab_treasure_cost_vitality").f_value
    local vitality_num = ComMgrs.dy_data_mgr:ExGetVitality()
    return vitality_num >= grab_treasure_cost_vitality
end

return GrabTreasureData