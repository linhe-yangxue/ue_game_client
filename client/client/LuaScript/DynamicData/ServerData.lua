local UIConst = require("UI.UIConst")
local CSConst = require("CSCommon.CSConst")

local ServerData = class("DynamicData.ServerData")

function ServerData:DoInit()
end

function ServerData:GetAreaList()
    if self.area_list then return self.area_list end
    self.area_list = {}
    for area, _ in pairs(SpecMgrs.data_mgr:GetAreaData()) do
        table.insert(self.area_list, area)
    end
    table.sort(self.area_list, function (area1, area2)
        return CSConst.AreaPriority[area1] > CSConst.AreaPriority[area2]
    end)
    return self.area_list
end

function ServerData:GetPartitionList(area)
    return SpecMgrs.data_mgr:GetPartitionListByArea(area)
end

function ServerData:GetServerList(partition_id)
    return SpecMgrs.data_mgr:GetServerListByPartitionId(partition_id)
end

function ServerData:GetServerById(id)
    return SpecMgrs.data_mgr:GetServerData(id)
end

function ServerData:GetServerAreaById(id)
    local server_data = SpecMgrs.data_mgr:GetServerData(id)
    return SpecMgrs.data_mgr:GetPartitionData(server_data.partition).area
end

-- TODO 返回该洲最新的大区
function ServerData:GetLatestPartition(area)
    return SpecMgrs.data_mgr:GetPartitionListByArea(area)[1]
end

-- TODO 返回该大区最新的服务器
function ServerData:GetLatestServer(partition_id)
    return SpecMgrs.data_mgr:GetServerListByPartitionId(partition_id)[1]
end

return ServerData