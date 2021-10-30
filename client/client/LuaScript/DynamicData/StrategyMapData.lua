local EventUtil = require("BaseUtilities.EventUtil")
local ItemUtil = require("BaseUtilities.ItemUtil")
local StrategyMapData = class("DynamicData.StrategyMapData")

EventUtil.GeneratorEventFuncs(StrategyMapData, "UpdateResource")
EventUtil.GeneratorEventFuncs(StrategyMapData, "UpdateCityData")
EventUtil.GeneratorEventFuncs(StrategyMapData, "UpdateStageData")
EventUtil.GeneratorEventFuncs(StrategyMapData, "UnlockNewStage")
EventUtil.GeneratorEventFuncs(StrategyMapData, "UnlockNewCity")
EventUtil.GeneratorEventFuncs(StrategyMapData, "UnlockNewCountry")

function StrategyMapData:DoInit()
    --本地数据
    self.max_city_num = SpecMgrs.data_mgr:GetAllCityNum()
    -- 服务器数据
    self.stage_info = {}
    self.stage_info.stage_dict = {}
    self.city_dict = {}
    self.country_dict = {}
    self.resource_dict = {}

    --结合本地数据产生的缓存
    self.income_data = {}
    self.hero_to_managed_city = {}
    self.child_to_managed_city = {}
    self.managed_city_list = {}
    self.occupied_city_list = {}
    self.cur_city_id = nil
    self.cur_country_id = nil
    self.stage_data_list = SpecMgrs.data_mgr:GetAllStageData()
    self.max_stage = #self.stage_data_list
end

function StrategyMapData:NotifyUpdateStageInfo(msg)
    for k, v in pairs(msg) do
        if k == "stage_dict" then
            for stage_id, stage_data in pairs(v) do
                self.stage_info.stage_dict[stage_id] = stage_data
                self:DispatchUpdateStageData(stage_id)
            end
        elseif k == "curr_stage" then
            local curr_stage = self.stage_info.curr_stage
            if not curr_stage then
                self.stage_info.curr_stage = v
                self:_UpdateCurCityAndCurCountry()
            elseif curr_stage and curr_stage < v then
                self.stage_info.curr_stage = v
                self:_UpdateCurCityAndCurCountry()
                self:DispatchUnlockNewStage()
            end
        else
            self.stage_info[k] = v
        end
    end
end

function StrategyMapData:NotifyUpdateCityInfo(msg)
    if msg.city_dict then
        for city_id, data in pairs(msg.city_dict) do
            self.city_dict[city_id] = data
        end
        self:_UpdateOccupyManageCityNum()
        self:_UpdateIncomeData()
        self:DispatchUpdateCityData(msg.city_dict)
    end
    if msg.resource_dict then
        self.resource_dict = msg.resource_dict
        self:DispatchUpdateResource()
    end
end

function StrategyMapData:NotifyUpdateCountryInfo(msg)
    if msg.country_dict then
        for country_id, data in pairs(msg.country_dict) do
            self.country_dict[country_id] = data
        end
    end
end

function StrategyMapData:_UpdateCurCityAndCurCountry()
    local stage_data = SpecMgrs.data_mgr:GetStageData(self:GetCurStage())
    local city_id
    if not stage_data then
        city_id = #SpecMgrs.data_mgr:GetAllCityData() + 1
    else
        city_id = stage_data.city_id
    end
    if not self.cur_city_id then
        self.cur_city_id = city_id
    elseif self.cur_city_id and self.cur_city_id < city_id then
        local old_city_id = self.cur_city_id
        self.cur_city_id = city_id
        self:DispatchUnlockNewCity(old_city_id, city_id)
    else
        return
    end
    local city_data = SpecMgrs.data_mgr:GetCityData(city_id)
    local country_id
    if not city_data then
        country_id = #SpecMgrs.data_mgr:GetAllCountryData() + 1
    else
        country_id = city_data.country_id
    end
    if not self.cur_country_id then
        self.cur_country_id = country_id
    elseif self.cur_country_id and self.cur_country_id < country_id then
        local old_country = self.cur_country_id
        self.cur_country_id = country_id
        self:DispatchUnlockNewCountry(old_country, country_id)
    else
        return
    end
end

function StrategyMapData:GetUnlockCityNum()
    local cur_city = self:GetCurCity()
    return math.min(cur_city, self.max_city_num)
end

function StrategyMapData:_UpdateOccupyManageCityNum()
    self.occupied_city_list = {}
    self.managed_city_list = {}
    self.hero_to_managed_city = {}
    self.child_to_managed_city = {}
    for city_id, city_data in pairs(self.city_dict) do
        if city_data.is_occupied then
            table.insert(self.occupied_city_list, city_id)
            if city_data.manager_type and city_data.manager_id then
                if city_data.manager_type == CSConst.CityManager.Hero then
                    self.hero_to_managed_city[city_data.manager_id] = city_id
                elseif city_data.manager_type == CSConst.CityManager.Child then
                    self.child_to_managed_city[city_data.manager_id] = city_id
                end
                table.insert(self.managed_city_list, city_id)
            end
        end
    end
    local sort_func = function (id1, id2)
        return id1 < id2 -- 排序规则待定 在这里直接排序成ui需要的列表
    end
    table.sort(self.occupied_city_list, sort_func)
    table.sort(self.managed_city_list, sort_func)
end

function StrategyMapData:_UpdateIncomeData()
    self.city_to_income_data = {} -- {[city_id] = {[item_id] = 1,}
    self.all_income_data = {} -- {item_id = 1}
    local city_to_income_data = self.city_to_income_data
    local all_income_data = self.all_income_data
    local nat_city_data
    local city_item_data
    local manager_income_data
    local manager_type
    local manager_id
    for city_id, serv_city_data in pairs(self.city_dict) do
        if serv_city_data.is_occupied then
            city_to_income_data[city_id] = self:GetCityIncomeData(city_id)
            city_item_data = city_to_income_data[city_id]
            manager_type = serv_city_data.manager_type
            manager_id = serv_city_data.manager_id
            if manager_type and manager_id then -- 计算管理者加成
                manager_income_data = self:GetManagerIncomeDataInCity(manager_type, manager_id, city_id) -- 需要计算势力匹配加成
                table.mergeNumDict(city_item_data, manager_income_data)
            end
        end
    end
    local cur_num
    for _, city_item_data in pairs(city_to_income_data) do -- 计算所有收益总和
        table.mergeNumDict(all_income_data, city_item_data)
    end
end

-- 返回城市和管理者产出总和
function StrategyMapData:GetManagerIncomeDataInCity(manager_type, manager_id, city_id)
    local add_income_data = self:GetCityOriIncomeData(city_id)
    if manager_type == CSConst.CityManager.Hero then
        local hero_data = ComMgrs.dy_data_mgr.night_club_data:GetHeroDataById(manager_id)
        self:_ChangeAddIncomeByAttrDict(add_income_data, hero_data.attr_dict)
    elseif manager_type == CSConst.CityManager.Child then
        local child_data = ComMgrs.dy_data_mgr.child_center_data:GetAdultChildDataById(manager_id)
        self:_ChangeAddIncomeByAttrDict(add_income_data, child_data.attr_dict) -- 计算结婚后属性总和
        self:_ChangeAddIncomeByAttrDict(add_income_data, child_data.marry.attr_dict) -- 合并结婚对象的属性
    end
    return add_income_data
end

function StrategyMapData:GetCityOriIncomeData(city_id)
    local ret = {}
    local nat_city_data = SpecMgrs.data_mgr:GetCityData(city_id)
    for i, item_id in ipairs(nat_city_data.item_list) do -- 这里默认城市产出item条目是不重复的
        ret[item_id] = nat_city_data.item_value_list[i]
    end
    return ret
end

-- 计算属性加成
function StrategyMapData:_ChangeAddIncomeByAttrDict(add_income_data, attr_dict)
    local item_dict = self:_GetAddIncomeByAttrDict(attr_dict)
    return table.mergeNumDict(add_income_data, item_dict)
end

function StrategyMapData:_GetAddIncomeByAttrDict(attr_dict)
    local attr_data
    local ret = {}
    local income_attr_list = SpecMgrs.data_mgr:GetCityIncomeAttrList()
    for _, attr_id in ipairs(income_attr_list) do
        attr_data = SpecMgrs.data_mgr:GetAttributeData(attr_id)
        if attr_dict[attr_id] then
            ret[attr_data.city_income_item] = math.floor(attr_dict[attr_id] * attr_data.city_income_item_rate)
        end
    end
    return ret
end

-- 获取城市产出所有道具数量转化后的总和
function StrategyMapData:CalculateManagerOverallNum(income_data)
    local overall_num = 0
    local trans_rate
    for item_id, item_num in pairs(income_data) do
        trans_rate = SpecMgrs.data_mgr:GetItemData(item_id).trans_rate or 0 -- 没有转换比率暂时默认为0
        overall_num = overall_num + item_num * trans_rate
    end
    return overall_num
end

function StrategyMapData:GetAllIncomeData()
    return self.all_income_data
end

function StrategyMapData:GetCityIncomeData(city_id)
    if self.city_to_income_data[city_id] then
        return self.city_to_income_data[city_id]
    else -- 城市未开未解锁
        return self:GetCityOriIncomeData(city_id)
    end
end

function StrategyMapData:GetIncomeLimitRate()
    local default_value = SpecMgrs.data_mgr:GetParamData("default_city_income_limit_rate").f_value
    local vip_add_value = ComMgrs.dy_data_mgr.vip_data:GetVipDataVal("city_income_limit")
    return default_value + vip_add_value
end

function StrategyMapData:GetOccupiedCityNum()
    return #self.occupied_city_list
end

function StrategyMapData:CheckOccupiedCityNum()
    return #self.occupied_city_list > 0
end

function StrategyMapData:GetManagedCityNum()
    return #self.managed_city_list
end

function StrategyMapData:GetNoManagerCityNum()
    return self:GetOccupiedCityNum() - self:GetManagedCityNum()
end

function StrategyMapData:GetOccupiedCityList()
    return self.occupied_city_list
end

function StrategyMapData:GetManagedCityList()
    return self.managed_city_list
end

function StrategyMapData:GetResourceDict()
    return self.resource_dict
end

function StrategyMapData:CheckResourceFull()
    if not self:CheckOccupiedCityNum() then return false end
    local rate = self:GetIncomeLimitRate()
    for k,v in pairs(self:GetAllIncomeData()) do
        if not self.resource_dict[k] or self.resource_dict[k] < math.floor(v * rate) then -- 一个条目不满就没满
            return false
        end
    end
    return true
end

function StrategyMapData:GetCityDict()
    return self.city_dict
end

function StrategyMapData:GetCityDataByCityId(city_id)
    return self.city_dict[city_id]
end

function StrategyMapData:GetCountryDataByCountryId(country_id)
    return self.country_dict[country_id]
end

function StrategyMapData:GetCityStarNumByCityId(city_id)
    return self.city_dict[city_id].star_num
end

function StrategyMapData:GetStageInfo()
    return self.stage_info
end

function StrategyMapData:GetCurStage()
    return self.stage_info.curr_stage
end

function StrategyMapData:GetStageState(satge_id)
    return self:GetStageData(satge_id).state
end

-- 带有检测最后一关
function StrategyMapData:GetLastStage()
    local cur_stage = self:GetCurStage()
    return self.stage_data_list[cur_stage] and cur_stage or cur_stage - 1
end

function StrategyMapData:GetActionPoint()
    return ComMgrs.dy_data_mgr:ExGetActionPoint()
end

function StrategyMapData:GetStageData(stage_id)
    return self.stage_info.stage_dict[stage_id]
end

function StrategyMapData:CheckCityIsOccupied(city_id)
    return self.city_dict[city_id] and self.city_dict[city_id].is_occupied
end

function StrategyMapData:CheckCityIsUnlock(city_id)
    return self.cur_city_id >= city_id
end

function StrategyMapData:CheckCountryIsUnlock(country_id)
    return self.cur_country_id >= country_id
end

function StrategyMapData:GetCurCity()
    return self.cur_city_id
end

function StrategyMapData:GetCurCountry()
    return self.cur_country_id
end

function StrategyMapData:CheckSoldierNum()
    return ComMgrs.dy_data_mgr:ExGetItemCount(CSConst.Virtual.Soldier) > 0
end

function StrategyMapData:GetCityManagerTypeAndId(city_id)
    local serv_city_data = self.city_dict[city_id]
    if serv_city_data then
        return serv_city_data.manager_type, serv_city_data.manager_id
    end
end

function StrategyMapData:GetManagerManagedCity(manager_type, manager_id)
    if manager_type == CSConst.CityManager.Hero then
        return self.hero_to_managed_city[manager_id]
    elseif manager_type == CSConst.CityManager.Child then
        return self.child_to_managed_city[manager_id]
    end
end

function StrategyMapData:_CheckCityTreasure(city_id)
    local serv_city_data = self.city_dict[city_id]
    if not serv_city_data then return false end -- 没打过的城市没有数据
    for _, v in pairs(serv_city_data.reward_dict) do
        if v then return true end
    end
    return false
end

function StrategyMapData:_CheckStageFirstRewardInCity(city_id)
    local stage_list = SpecMgrs.data_mgr:GetCityBossStageListByCityId(city_id)
    local stage_data
    for _, stage_id in pairs(stage_list) do
        stage_data = self.stage_info.stage_dict[stage_id]
        if stage_data and stage_data.first_reward then
            return true
        end
    end
    return false
end

function StrategyMapData:ClearAll()
    self.stage_info = {}
    self.stage_info.stage_dict = {}
    self.city_dict = {}
    self.country_dict = {}
    self.resource_dict = {}
    self.income_data = {}
    self.city_to_manager_data = {}
    self.managed_city_list = {}
    self.occupied_city_list = {}
end

function StrategyMapData:IsFirstFight(stage_id)
    local stage_data = self:GetStageData(stage_id)
    return stage_data and stage_data.state == CSConst.Stage.State.New or false
end

function StrategyMapData:GetCountryOccupiedCityList(country_id)
    local city_list = SpecMgrs.data_mgr:GetCityListByCountryId(country_id)
    local occupied_city_list = {}
    for _, city_id in ipairs(city_list) do
        if self:CheckCityIsOccupied(city_id) then
            table.insert(occupied_city_list, city_id)
        end
    end
    return occupied_city_list
end

function StrategyMapData:GetManagerUnitId(manager_type, manager_id)
    if not manager_type or not manager_id then return end
    local unit_id
    if manager_type == CSConst.CityManager.Hero then
        local hero_data = SpecMgrs.data_mgr:GetHeroData(manager_id)
        return hero_data.unit_id
    elseif manager_type == CSConst.CityManager.Child then
        local child_data = ComMgrs.dy_data_mgr.child_center_data:GetChildData(manager_id)
        unit_id = ComMgrs.dy_data_mgr.child_center_data:GetChildUnitId(child_data)
    end
    return unit_id
end

function StrategyMapData:GetManagerUnitIdByCity(city_id)
    local manager_type, manager_id = self:GetCityManagerTypeAndId(city_id)
    return self:GetManagerUnitId(manager_type, manager_id)
end

function StrategyMapData:GetManagerNameByCity(city_id)
    local manager_type, manager_id = self:GetCityManagerTypeAndId(city_id)
    return self:GetManagerName(manager_type, manager_id)
end

function StrategyMapData:GetManagerName(manager_type, manager_id)
    if not manager_type or not manager_id then return end
    local name
    if manager_type == CSConst.CityManager.Hero then
        local hero_data = SpecMgrs.data_mgr:GetHeroData(manager_id)
        name = hero_data.name
    elseif manager_type == CSConst.CityManager.Child then
        local serv_child_data = ComMgrs.dy_data_mgr.child_center_data:GetChildDataById(manager_id)
        name = serv_child_data.name
    end
    return name
end

function StrategyMapData:GetStageResetNum(stage_id)
    local add_reset_num_by_vip = ComMgrs.dy_data_mgr.vip_data:GetVipDataVal("stage_reset_num")
    local reset_num = SpecMgrs.data_mgr:GetStageData(stage_id).reset_num
    return reset_num + add_reset_num_by_vip
end

function StrategyMapData:GatherManagerList(city_id, manager_type)
    if manager_type == CSConst.CityManager.Hero then
        return self:GatherManagerHeroList(city_id)
    elseif manager_type == CSConst.CityManager.Child then
        return self:GatherManagerChildList(city_id)
    end
end

function StrategyMapData:GatherManagerHeroList(city_id)
    local hero_dict = ComMgrs.dy_data_mgr.night_club_data:GetAllHeroData()
    local manager_type = CSConst.CityManager.Hero
    local city_manager_type, city_manager_id = self:GetCityManagerTypeAndId(city_id)
    local filt_manager_id = city_manager_type == manager_type and city_manager_id or nil
    local data_list = {}
    for hero_id, v in pairs(hero_dict) do
        if hero_id ~= filt_manager_id then
            local data = self:GatherManagerData(v, manager_type, city_id)
            table.insert(data_list, data)
        end
    end
    self:SortMangerList(data_list)
    return data_list
end

function StrategyMapData:GatherManagerChildList(city_id)
    local child_list = ComMgrs.dy_data_mgr.child_center_data:GetAdultChildList(true) -- 获取已婚列表
    local manager_type = CSConst.CityManager.Child
    local city_manager_type, city_manager_id = self:GetCityManagerTypeAndId(city_id)
    local filt_manager_id = city_manager_type == manager_type and city_manager_id or nil
    local data_list = {}
    for _, v in ipairs(child_list) do
        if v.child_id ~= filt_manager_id then
            local data = self:GatherManagerData(v, manager_type, city_id)
            table.insert(data_list, data)
        end
    end
    self:SortMangerList(data_list)
    return data_list
end

function StrategyMapData:GatherManagerData(manager_info, manager_type, city_id)
    local data = {}
    local manager_id = self:_GetManagerId(manager_info, manager_type)
    data.manager_id = manager_id
    data.manager_info = manager_info
    data.manager_type = manager_type
    data.self_income_data = self:GetManagerIncomeDataInCity(manager_type, manager_id, city_id)
    data.overall_num = self:CalculateManagerOverallNum(data.self_income_data)
    local manager_city = self:GetManagerManagedCity(manager_type, manager_id)
    if manager_city then
        data.manager_city = manager_city
        data.manager_city_income_data = self:GetCityIncomeData(manager_city)
    end
    return data
end

function StrategyMapData:_GetManagerId(manager_info, manager_type)
    local manager_id
    if manager_type == CSConst.CityManager.Hero then
        manager_id = manager_info.hero_id
    elseif manager_type == CSConst.CityManager.Child then
        manager_id = manager_info.child_id
    end
    return manager_id
end

function StrategyMapData:SortMangerList(manager_data_list)
    table.sort(manager_data_list, function (data1, data2)
        if data1.manager_city and not data2.manager_city then
            return false
        elseif data2.manager_city and not data1.manager_city then
            return true
        end
        return data1.overall_num > data2.overall_num
    end)
end

return StrategyMapData