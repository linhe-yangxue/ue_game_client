local EventUtil = require("BaseUtilities.EventUtil")
local ExperimentData = class("DynamicData.ExperimentData")

function ExperimentData:DoInit()
    self.experiment_msg = {}
    self.experiment_war_msg = {}
    self.attr_list = {}
    self.last_layer_star = 0
    self.cur_layer_reward = nil
    self.is_show_war_frame = false
end

function ExperimentData:NotifyUpdateExperimentData(msg)
    for key, val in pairs(msg) do
        self.experiment_msg[key] = val
    end
    self:SortAttrList()
    local layer_all_star = 0
    for i, num in ipairs(msg.layer_star_num_list) do
        layer_all_star = layer_all_star + num
    end
    self.experiment_msg.layer_all_star = layer_all_star
end

function ExperimentData:NotifyUpdateTrainWarInfo(msg)
    for key, val in pairs(msg) do
        self.experiment_war_msg[key] = val
    end
end

function ExperimentData:SetLastLayerStar(val)
	self.last_layer_star = val
end

function ExperimentData:GetCurTreasureData()
    local treasure_data_list = SpecMgrs.data_mgr:GetAllTrainItemData()
    local cur_star = self.experiment_msg.curr_star_num
    for i, treasure_data in ipairs(treasure_data_list) do
        if i == #treasure_data_list then
            return treasure_data
        end
        local min_star
        local max_star
        if i == 1 then
            min_star = 0
        else
            min_star = treasure_data_list[i - 1].star_num
        end
        max_star = treasure_data.star_num
        if cur_star >= min_star and cur_star <= max_star then
            return treasure_data
        end
    end
    PrintError("no TrainItemData")
    return nil
end

function ExperimentData:SortAttrList()
    self.attr_list = {}
    local attr_dict = self.experiment_msg.add_attr_dict
    for k, v in pairs(attr_dict) do
        table.insert(self.attr_list, {id = k, val = v})
    end

    table.sort(self.attr_list, function(a, b)
        local sort_order1 = SpecMgrs.data_mgr:GetAttributeData(a.id).order
        local sort_order2 = SpecMgrs.data_mgr:GetAttributeData(b.id).order
        return sort_order1 > sort_order2
    end)
end

function ExperimentData:GetAttrList()
    return self.attr_list
end

function ExperimentData:GetCurLayerReward()
    return self.cur_layer_reward
end

function ExperimentData:SetCurLayerReward(val)
    self.cur_layer_reward = val
end

return ExperimentData