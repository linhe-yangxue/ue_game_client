local EventUtil = require("BaseUtilities.EventUtil")
local UIFuncs = require("UI.UIFuncs")
local CSConst = require("CSCommon.CSConst")
local LoverData = class("DynamicData.LoverData")
local CSFunction = require("CSCommon.CSFunction")
local UIConst = require("UI.UIConst")

EventUtil.GeneratorEventFuncs(LoverData, "UpdateDiscussEvent")
EventUtil.GeneratorEventFuncs(LoverData, "UpdateLoverInfoEvent")
EventUtil.GeneratorEventFuncs(LoverData, "LoverChangeSexEvent")
EventUtil.GeneratorEventFuncs(LoverData, "UpdateRedPointEvent")
EventUtil.GeneratorEventFuncs(LoverData, "UpdateLoverGradeEvent")
EventUtil.GeneratorEventFuncs(LoverData, "UpdateLoverAttrEvent")
EventUtil.GeneratorEventFuncs(LoverData, "UpdateLoverSpoilStateEvent")

local grade_limit_map = {
    level = "level_limit",
    attr_sum = "attr_sum_limit"
}
local lover_date_control_id = CSConst.RedPointControlIdDict.LoverRandomDate
local lover_skill_control_id = CSConst.RedPointControlIdDict.LoverSkill
local lover_star_control_id = CSConst.RedPointControlIdDict.LoverStar

function LoverData:DoInit()
    self.info_serv_data = {} -- 原始服务器数据
    self.lover_info_list = {}-- 根据lover_id排序的lover_data列表
    self.is_one_key_discuss = false
    self.all_lover_data = SpecMgrs.data_mgr:GetAllLoverData()
    self.star_limit = SpecMgrs.data_mgr:GetParamData("lover_star_lv_limit").f_value

    self.grade_data_list = SpecMgrs.data_mgr:GetAllGradeData()
    self.max_grade = #self.grade_data_list
    self.lowest_grade = 1
    self.serv_lover_data = {}
    self.grade_lover_id_list = {}
    for i = 1, self.max_grade do
        self.grade_lover_id_list[i] = {}
    end
    self.top_lover_grade = nil
    self.lover_id_list_sorted_by_attr = {}
    ComMgrs.dy_data_mgr.bag_data:RegisterInitAllBagItemEvent("LoverData", self._UpdateAddStarRedPoint, self)
    ComMgrs.dy_data_mgr.bag_data:RegisterUpdateBagItemEvent("LoverData", self.ItemChangeListener, self)
    ComMgrs.dy_data_mgr:RegisterUpdateCurrencyEvent("CharityUI", self.MoneyChangeListener, self)
end

function LoverData:UpdateOnlineData(msg)
    self:UpdateAllLoverData(msg)
    self:UpdateDiscussData(msg)
    self:_UpdateSkillRedPoint()
    self:_UpdateManagementRedPoint()
end

function LoverData:UpdateAllLoverData(msg)
    if msg.all_lover then
        self.serv_lover_data = msg.all_lover
        self:UpdateLoverData(self.serv_lover_data)
        for _, v in pairs(self.serv_lover_data) do
            self:_InsertLoverIdByAttr(self.lover_id_list_sorted_by_attr, v)
        end
        self:SortLoverList(self.lover_id_list_sorted_by_attr)
        for _, lover_id in ipairs(self.lover_id_list_sorted_by_attr) do
            local grade_id = self.serv_lover_data[lover_id].grade
            table.insert(self.grade_lover_id_list[grade_id], lover_id)
        end
        for _, lover_id_list in ipairs(self.grade_lover_id_list) do
            self:SortLoverList(lover_id_list)
        end
        self:_UpdateTopLoverGrade()
    end
end

function LoverData:UpdateDiscussData(msg)
    if msg then
        for k,v in pairs(msg) do
            self.info_serv_data[k] = v
        end
        if msg.discuss_num then
            SpecMgrs.redpoint_mgr:SetControlIdActive(lover_date_control_id, {msg.discuss_num})
        end
        self:DispatchUpdateDiscussEvent()
    end
end

function LoverData:UpdateLoverInfo(msg)
    for i, v in ipairs(self.lover_info_list) do
        if v.lover_id == msg.lover_id then
            for k, v1 in pairs(msg) do
                self.lover_info_list[i][k] = v1
            end
            self:DispatchUpdateLoverInfoEvent(msg.lover_id)
            break
        end
    end
    local lover_id = msg.lover_id
    local native_lover_data = self.serv_lover_data[lover_id]
    if msg.grade then
        for k, compare_lover_id in ipairs(self.grade_lover_id_list[msg.old_grade]) do
            if compare_lover_id == lover_id then
                table.remove(self.grade_lover_id_list[msg.old_grade], k)
                break
            end
        end
        self:_InsertLoverIdByAttr(self.grade_lover_id_list[msg.grade], native_lover_data)
        self:SortLoverList(self.grade_lover_id_list[msg.grade])
        self:DispatchUpdateLoverGradeEvent(msg)
        self:_UpdateTopLoverGrade()
    end
    if msg.attr_dict then
        native_lover_data.attr_sum = self:_GetAttrSumByLoverData(native_lover_data)
        self:SortLoverList(self.lover_id_list_sorted_by_attr)
        self:SortLoverList(self.grade_lover_id_list[native_lover_data.grade])
        self:DispatchUpdateLoverAttrEvent(native_lover_data)
    end
    self:_UpdateSkillRedPoint()
    self:_UpdateAddStarRedPoint()
    self:_UpdateManagementRedPoint()
end

function LoverData:SortLoverList(lover_id_list)
    table.sort(lover_id_list, function (lover_id1, lover_id2)
        local attr_sum1 = self.serv_lover_data[lover_id1].attr_sum
        local attr_sum2 = self.serv_lover_data[lover_id2].attr_sum
        if attr_sum1 ~= attr_sum2 then
            return attr_sum1 > attr_sum2
        end
        local level1 = self.serv_lover_data[lover_id1].level
        local level2 = self.serv_lover_data[lover_id2].level
        if level1 ~= level2 then
            return level1 > level2
        end
        return lover_id1 > lover_id2
    end)
end

function LoverData:SortLoverListByLevel(lover_data_list)
    table.sort(lover_data_list, function (lover_data1, lover_data2)
        return lover_data1.level > lover_data2.level
    end)
end

function LoverData:GetLoverDataListSortedByLevel()
    local lover_data_list = self:GetLoverDataList()
    self:SortLoverListByLevel(lover_data_list)
    return lover_data_list
end

function LoverData:GetAllLoverDataList()
    local lover_data_list = {}
    for k, v in pairs(self.serv_lover_data) do
        table.insert(lover_data_list, v)
    end
    return lover_data_list
end

--  更新情人信息并排序
function LoverData:UpdateLoverData(lover_tb)
    self.lover_info_list = {}
    for key, value in pairs(lover_tb) do
        table.insert(self.lover_info_list, value)
    end
    table.sort(self.lover_info_list, function(info1, info2)
        if info1.level ~= info2.level then
            return info1.level > info2.level
        end
        if info1.star_lv ~= info2.star_lv then
            return info1.star_lv > info2.star_lv
        end
        local info1_quality = SpecMgrs.data_mgr:GetLoverData(info1.lover_id).quality
        local info2_quality = SpecMgrs.data_mgr:GetLoverData(info2.lover_id).quality
        if info1_quality ~= info2_quality then
            return info1_quality > info2_quality
        end
        return info1.lover_id < info2.lover_id
    end)
end

function LoverData:ChangeLoverSexData(old_lover_id, new_lover_info)
    local lover_info, index = self:GetLoverInfo(old_lover_id)
    self.lover_info_list[index] = new_lover_info
    self:DispatchLoverChangeSexEvent(old_lover_id, new_lover_info.lover_id)

    self.serv_lover_data[old_lover_id] = nil
    self.serv_lover_data[new_lover_info.lover_id] = new_lover_info
    for k,v in ipairs(self.lover_id_list_sorted_by_attr) do
        if v.lover_id == old_lover_id then
            self.lover_id_list_sorted_by_attr[k] = new_lover_info.lover_id
            break
        end
    end

    for k,v in ipairs(self.grade_lover_id_list[new_lover_info.grade]) do
        if v.lover_id == old_lover_id then
            self.grade_lover_id_list[k] = new_lover_info.lover_id
            break
        end
    end
end

function LoverData:AddLoverData(msg)
    local lover_data = msg.lover_info
    if lover_data then
        self.serv_lover_data[lover_data.lover_id] = lover_data
        self:_InsertLoverIdByAttr(self.lover_id_list_sorted_by_attr, lover_data)
        self:_InsertLoverIdByAttr(self.grade_lover_id_list[lover_data.grade], lover_data)
        table.insert(self.lover_info_list, lover_data)
        table.sort(self.lover_info_list, function(info1, info2)
            return info1.lover_id < info2.lover_id
        end)
        -- 出行邂逅所得情人等出行事件结束在播解锁动画
        if not self.is_hand_unlock_anim then
            SpecMgrs.ui_mgr:PlayUnitUnlockAnim({lover_id = lover_data.lover_id})
        end
        self:_UpdateAddStarRedPoint()
        self:_UpdateManagementRedPoint()
    end
end

function LoverData:HangLoverUnlockAnim(state)
    self.is_hand_unlock_anim = state
end

------------Get

function LoverData:GetLoverInfo(lover_id)
    for i, v in ipairs(self.lover_info_list) do
        if v.lover_id == lover_id then
            return v, i
        end
    end
end

function LoverData:GetLoverInfoByIndex(lover_index)
    return self.lover_info_list[lover_index]
end

function LoverData:GetDiscussNum()
    return self.info_serv_data.discuss_num
end

function LoverData:GetMaxDiscussNum()
    return CSFunction.get_date_lover_num(ComMgrs.dy_data_mgr.vip_data:GetVipLevel(), ComMgrs.dy_data_mgr:ExGetRoleLevel())
end

function LoverData:GetDiscussCoolDown()
    local last_time = self.info_serv_data.discuss_ts
    local max_cool_time = self:_GetLevelData().energy_cooldown
    if not last_time then return end
    local next_cooldown_time = last_time + max_cool_time
    local remain_time = next_cooldown_time - Time:GetServerTime()
    if remain_time < 0 then return end
    return remain_time
end

function LoverData:_GetLevelData()
    local level = ComMgrs.dy_data_mgr:ExGetRoleLevel()
    return SpecMgrs.data_mgr:GetLevelData(level)
end

--  未拥有的情人, 只是女性
function LoverData:GetNotPossessLover()
    local ret = {}
    for k, v in pairs(self.all_lover_data) do
        if not self:IsProcessLover(v.id) and v.sex == CSConst.Sex.Woman then
            table.insert(ret, v)
        end
    end
    ret = self:SortLoverDataList(ret)
    return ret
end

function LoverData:SortLoverDataList(lover_data_list)
    table.sort(lover_data_list, function(a, b)
        local a_quality = SpecMgrs.data_mgr:GetLoverData(a.id).quality
        local b_quality = SpecMgrs.data_mgr:GetLoverData(b.id).quality
        if a_quality ~= b_quality then
            return a_quality > b_quality
        end
        return a.id < b.id
    end)
    return lover_data_list
end

function LoverData:IsProcessLover(lover_id)
    for i, v in ipairs(self.lover_info_list) do
        local lover_data = self.all_lover_data[v.lover_id]
        if v.lover_id == lover_id or lover_data.change_sex == lover_id then
            return true
        end
    end
    return false
end

function LoverData:GetLoverAllAttr(lover_id)
    local lover_info_attr = self:GetLoverInfo(lover_id).attr_dict
    return lover_info_attr.etiquette + lover_info_attr.culture + lover_info_attr.charm + lover_info_attr.planning
end

function LoverData:GetPrelifeData(lover_id)
    local lover_data = SpecMgrs.data_mgr:GetLoverData(lover_id)
    local other_lover_data = SpecMgrs.data_mgr:GetLoverData(lover_data.change_sex)
    if lover_data.sex == CSConst.Sex.Man then
        return lover_data
    else
        return other_lover_data
    end
end

function LoverData:GetNowlifeData(lover_id)
    local lover_data = SpecMgrs.data_mgr:GetLoverData(lover_id)
    local other_lover_data = SpecMgrs.data_mgr:GetLoverData(lover_data.change_sex)
    if lover_data.sex == CSConst.Sex.Man then
        return other_lover_data
    else
        return lover_data
    end
end

function LoverData:GetLoverClothAttrAdd(lover_id)
    local attr_list = {}
    local lover_info = self:GetLoverInfo(lover_id)
    local all_cloth = {}
    for k, v in pairs(lover_info.fashion_dict) do
        table.insert(all_cloth, k)
    end
    for k, v in pairs(lover_info.other_fashion_dict) do
        table.insert(all_cloth, k)
    end
    for k, v in pairs(all_cloth) do
        local cloth_data = SpecMgrs.data_mgr:GetItemData(v)
        for i = 1, CSConst.ClothAttrListCount do
            attr_list[i] = attr_list[i] or 0
            attr_list[i] = attr_list[i] + cloth_data.attr_list_value[i]
        end
    end
    return attr_list
end

function LoverData:GetClothData(lover_id, is_nowlife)
    local cloth_list = {}
    local cloth_data_list = {}
    local lover_data = self:GetNowlifeData(lover_id)
    local lover_info = self:GetLoverInfo(lover_id)
    if lover_data.id == lover_id then
        if is_nowlife then
            cloth_list = lover_info.fashion_dict
        else
            cloth_list =  lover_info.other_fashion_dict
        end
    else
        if is_nowlife then
            cloth_list = lover_info.other_fashion_dict
        else
            cloth_list =  lover_info.fashion_dict
        end
    end
    for k, v in pairs(cloth_list) do
        table.insert(cloth_data_list, SpecMgrs.data_mgr:GetItemData(k))
    end
    table.sort(cloth_data_list, function(info1, info2)
        return info1.id <= info2.id
    end)
    return cloth_data_list
end

function LoverData:GetAllLoverInfo()
    return self.lover_info_list
end

------------Get

------------红点
--红点系统整合 begin
--更新情人势力技能升级红点的状态
function LoverData:_UpdateSkillRedPoint()
    local skill_param_dict = {}
    for _, lover_info in ipairs(self.lover_info_list) do
        skill_param_dict[lover_info.lover_id] = self:_CheckLoverSkillUpgrade(lover_info)
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(lover_skill_control_id, skill_param_dict)
end

--检查该情人是否有可以升级的势力技能
function LoverData:_CheckLoverSkillUpgrade(lover_info)
    local sum = 0
    for skill_id, level in pairs(lover_info.spell_dict) do
        local skill_data = SpecMgrs.data_mgr:GetLoverSpellData(skill_id)
        if skill_data.cost_num[level] <= lover_info.power_value and level < skill_data.level_limit then
            sum = sum + 1
        end
    end
    return sum
end

--监听情人碎片的数量变化
function LoverData:ItemChangeListener(_, op, item)
    local item_data = item.item_data
    if item_data.sub_type == CSConst.ItemSubType.LoverFragment then
        self:_UpdateAddStarRedPoint()
    end
end

--监听金钱的数量变化
function LoverData:MoneyChangeListener(_, currency)
    if currency[CSConst.Virtual.Money] then
        self:_UpdateAddStarRedPoint()
    end

end

--更新情人升星红点的状态
function LoverData:_UpdateAddStarRedPoint()
    local param_dict = {}
    for _, lover_info in ipairs(self.lover_info_list) do
        if lover_info.star_lv < self.star_limit then
            local cost_dict = CSFunction.get_lover_star_cost(lover_info.lover_id, lover_info.star_lv + 1)
            if ComMgrs.dy_data_mgr.bag_data:CheckItemDictCostEnough(cost_dict) then
                param_dict[lover_info.lover_id] = 1
            end
        end
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(lover_star_control_id, param_dict)
end

-- 更新管理中心红点
function LoverData:_UpdateManagementRedPoint()
    local param_dict = {}
    for grade_index = self.lowest_grade + 1 , self.max_grade do
        local param = self:CheckLoverGradeUpByGradeId(grade_index)
        self:DispatchUpdateRedPointEvent(grade_index, param)
        param_dict[grade_index] = param and 1 or nil
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.ManagementCenter, param_dict)
end

--检查是否有情人满足该册封等级的册封条件
function LoverData:CheckLoverGradeUpByGradeId(grade_id)
    --如果已经满员则返回false
    if self:_CheckGradeIsFull(grade_id) then
        return false
    end
    local lover_list = self.grade_lover_id_list[grade_id - 1]
    if #lover_list == 0 then
        return false
    end
    local attr_sum_limit = self.grade_data_list[grade_id].attr_sum_limit
    local level_limit = self.grade_data_list[grade_id].level_limit
    for _, lover_id in ipairs(lover_list) do
        local lover_data = self.serv_lover_data[lover_id]
        if lover_data.attr_sum >= attr_sum_limit and lover_data.level >= level_limit then
            return true
        end
    end
    return false
end
--红点系统整合 end

function LoverData:CanTurnCard()
    return self.info_serv_data.discuss_num > 0
end

function LoverData:CanUpgradeLoverTargetSkill(lover_id, skill_id)
    local lover_info = self:GetLoverInfo(lover_id)
    local level = lover_info.spell_dict[skill_id]
    local skill_data = SpecMgrs.data_mgr:GetLoverSpellData(skill_id)
    if skill_data.cost_num[level] <= lover_info.power_value and level < skill_data.level_limit then
        return true
    end
    return false
end

function LoverData:_UpdateTopLoverGrade()
    for i = self.max_grade, 1 ,-1 do
        if next(self.grade_lover_id_list[i]) then
            self.top_lover_grade = i
            break
        end
    end
end

function LoverData:GetTopLoverGrade()
    return self.top_lover_grade
end

-- 按属性总和从最大到最小排序
function LoverData:_InsertLoverIdByAttr(lover_id_list, lover_data)
    if not lover_data.attr_sum then
        lover_data.attr_sum = self:_GetAttrSumByLoverData(lover_data)
    end
    table.insert(lover_id_list, lover_data.lover_id)
end

function LoverData:_CheckGradeIsFull(grade_index)
    local max_count = self.grade_data_list[grade_index].max_count
    if max_count < 0 then return false end
    local lover_list = self.grade_lover_id_list[grade_index]
    local lover_count = lover_list and #lover_list or 0
    return lover_count >= self.grade_data_list[grade_index].max_count
end

function LoverData:_GetAttrSumByLoverData(lover_data)
    local lover_attr_list = lover_data.attr_dict
    local count = 0
    for _,v in pairs(lover_attr_list) do
        count = count + v
    end
    return count
end

function LoverData:GetLoverInfoBySeat(grade_id, seat_index)
    local lover_id = self.grade_lover_id_list[grade_id] and self.grade_lover_id_list[grade_id][seat_index]
    return self.serv_lover_data[lover_id]
end

function LoverData:GetLoverCountByGrade(grade)
    return self.grade_lover_id_list[grade] and #self.grade_lover_id_list[grade] or 0
end

function LoverData:GetServLoverDataById(lover_id)
    return self.serv_lover_data[lover_id]
end

function LoverData:GetLoverListByGrade(grade_id)
    return self.grade_lover_id_list[grade_id]
end

function LoverData:GetAllGradeData()
    return self.grade_data_list
end

function LoverData:GetAllLoverData()
    return self.all_lover_data
end

function LoverData:GetLoverAttrContrastStr(lover_id, grade_id, attr_name)
    local cur_attr = self.serv_lover_data[lover_id][attr_name]
    if grade_id <= self.max_grade then
        local attr_limit = self.grade_data_list[grade_id][grade_limit_map[attr_name]]
        local right_str
        if grade_id > self.top_lover_grade + 1 then
            right_str = UIConst.Text.SECRET
        else
            right_str = attr_limit
        end
        local color
        if cur_attr > attr_limit then
            color = "Green"
        else
            color = "Red"
        end
        local level_str = string.format(UIConst.Text.SPRIT, cur_attr, right_str)
        return UIFuncs.ChangeStrColor(level_str, color)
    else
        return UIFuncs.ChangeStrColor(cur_attr, "Green") -- 皇后没有下一级
    end
end

function LoverData:CheckLoverCanPromote(lover_id, grade_id)
    local lover_data = self.serv_lover_data[lover_id]
    local attr_sum_limit = self.grade_data_list[grade_id].attr_sum_limit
    local level_limit = self.grade_data_list[grade_id].level_limit
    if lover_data.level and lover_data.level > level_limit then
        return true
    else
        return false, UIConst.Text.LEVEL_NOT_ENOUGH
    end
    if lover_data.attr_sum and lover_data.attr_sum > attr_sum_limit then
        return true
    else
        return false, UIConst.Text.ATTR_SUM_NOT_ENOUGH
    end
    return true
end

function LoverData:GetSelectLoverDataList(grade_id)
    local ret_lover_list = {}
    for i = grade_id - 1, 1, -1 do
        for _, v in ipairs(self.grade_lover_id_list[i]) do
            table.insert(ret_lover_list,v)
        end
    end
    return ret_lover_list
end

function LoverData:FindGradeDownTarget(grade_id)
    for i = grade_id - 1, 1, -1 do
        if not self:_CheckGradeIsFull(i) then
            return i
        end
    end
end

function LoverData:CheckPromoteItemEnough(grade_id)
    local grade_data = self.grade_data_list[grade_id]
    local item_id = grade_data.promote_item_id
    local item_count = ComMgrs.dy_data_mgr:ExGetItemCount(item_id)
    if item_count and item_count >= grade_data.promote_item_count then
        return true
    else
        return false
    end
end

function LoverData:GetRedPointSeat(grade)
    return #self.grade_lover_id_list[grade] + 1
end

function LoverData:GetSalonActiveState()
    for _, lover_info in pairs(self.serv_lover_data) do
        if lover_info.grade >= CSConst.SalonActiveLoverGrade then return true end
    end
    return false
end

function LoverData:CheckLoverAddStarRedPoint(lover_id)
    local lover_info = self.serv_lover_data[lover_id]
    if lover_info.star_lv >= self.star_limit then return false end
    local cost_dict = CSFunction.get_lover_star_cost(lover_id, lover_info.star_lv + 1)
    for item_id, count in pairs(cost_dict) do
        if not UIFuncs.CheckItemCount(item_id, count) then return false end
    end
    return true
end

function LoverData:GetRandomLoverId()
    local lover_count = #self.lover_info_list
    local random_index = math.random(lover_count)
    return self.lover_info_list[random_index].lover_id
end

function LoverData:ClearAll()
    self.info_serv_data = {}
    self.grade_data_list = {}
    self.max_grade = nil
    self.serv_lover_data = {}
    self.grade_lover_id_list = {}
    self.top_lover_grade = nil
end

return LoverData