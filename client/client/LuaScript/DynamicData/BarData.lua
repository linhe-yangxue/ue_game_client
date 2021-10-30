local EventUtil = require("BaseUtilities.EventUtil")
local CSConst = require("CSCommon.CSConst")
local CSFunction = require("CSCommon.CSFunction")
local UIConst = require("UI.UIConst")
local BarData = class("DynamicData.BarData")

EventUtil.GeneratorEventFuncs(BarData, "UpdateBarUnitEvent")
EventUtil.GeneratorEventFuncs(BarData, "UpdateBarGameCountEvent")

function BarData:DoInit()
    self.bar_game_cost_item = SpecMgrs.data_mgr:GetParamData("bar_game_count_cost_item").item_id
    self.bar_hero_dict = {}
    self.bar_hero_list = {}
    self.bar_count_data_dict = {}
end

function BarData:NotifyUpdateBarUnitData(msg)
    if msg.hero_dict then
        self.bar_hero_dict = msg.hero_dict
        self:UpdateBarHeroList()
    end
    if msg.lover_id then self.bar_lover_id = msg.lover_id end
    if msg.lover_cnt then self.lover_cnt = msg.lover_cnt end
    self:DispatchUpdateBarUnitEvent()
end

function BarData:UpdateBarHeroList()
    self.bar_hero_list = {}
    for hero_id, count in pairs(self.bar_hero_dict) do
        if count > 0 then
            table.insert(self.bar_hero_list, {hero_id = hero_id, count = count})
        end
    end
    table.sort(self.bar_hero_list, function (hero1, hero2)
        return hero2.hero_id > hero1.hero_id
    end)
end

function BarData:NotifyUpdateBarGameCount(msg)
    for k,v in pairs(msg) do
        self.bar_count_data_dict[k] = v
    end
    self:DispatchUpdateBarGameCountEvent()
end

function BarData:GetBarHeroList()
    return self.bar_hero_list
end

function BarData:GetHeroChallengeCount(hero_id)
    return self.bar_hero_dict[hero_id]
end

function BarData:GetBarLoverInfo()
    return self.bar_lover_id, self.lover_cnt
end

function BarData:GetGameCountByBarType(bar_type)
    if bar_type == CSConst.BarType.Hero then
        return self.bar_count_data_dict.hero_remaining_challenge_cnt
    else
        return self.bar_count_data_dict.lover_remaining_challenge_cnt
    end
end

function BarData:GetCurBuyCountByBarType(bar_type)
    if bar_type == CSConst.BarType.Hero then
        return self.bar_count_data_dict.hero_already_challenge_cnt
    else
        return self.bar_count_data_dict.lover_already_challenge_cnt
    end
end

function BarData:GetCurRefreshCountByBarType(bar_type)
    if bar_type == CSConst.BarType.Hero then
        return self.bar_count_data_dict.hero_already_refresh_cnt
    else
        return self.bar_count_data_dict.lover_already_refresh_cnt
    end
end

function BarData:CheckGameCount(bar_type)
    local game_count = self:GetGameCountByBarType(bar_type)
    if game_count <= 0 then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.CUR_BAR_GAME_COUNT_EMPTY)
        return false
    end
    return true
end

-- 返回下次刷新时间
function BarData:GetNextRefreshTime()
    local cur_time = Time:GetServerTime()
    local cur_sec = Time:GetCurDayPassTime()
    local cur_day_start_time = cur_time - cur_sec
    local bar_refresh_time_list = SpecMgrs.data_mgr:GetParamData("bar_refresh_time_list").tb_int
    for _, time in ipairs(bar_refresh_time_list) do
        if cur_sec < time * CSConst.Time.Hour then
            return cur_day_start_time + time * CSConst.Time.Hour
        end
    end
    return cur_day_start_time + CSConst.Time.Day + bar_refresh_time_list[1] * CSConst.Time.Hour
end

function BarData:CalcRefreshCost(bar_type)
    local hero_refresh_cost_list = SpecMgrs.data_mgr:GetParamData("bar_hero_refresh_price_list").tb_int
    local lover_refresh_cost_list = SpecMgrs.data_mgr:GetParamData("bar_lover_refresh_price_list").tb_int
    local cost_list = bar_type == CSConst.BarType.Hero and hero_refresh_cost_list or lover_refresh_cost_list
    local refresh_limit = CSFunction.get_bar_game_refresh_limit(ComMgrs.dy_data_mgr:ExGetRoleVip(), bar_type)
    local cur_refresh_count = self:GetCurRefreshCountByBarType(bar_type)
    return cur_refresh_count < refresh_limit and cost_list[cur_refresh_count + 1] or nil
end

function BarData:CalcBuyChallengeCountCost(bar_type, count)
    local hero_challenge_price_list = SpecMgrs.data_mgr:GetParamData("bar_hero_challenge_price_list").tb_int
    local lover_challenge_price_list = SpecMgrs.data_mgr:GetParamData("bar_lover_challenge_price_list").tb_int
    local price_list = bar_type == CSConst.BarType.Hero and hero_challenge_price_list or lover_challenge_price_list
    local price_list_length = #price_list
    local cur_buy_count = self:GetCurBuyCountByBarType(bar_type)
    local total_cost = 0
    for i = 1, count do
        local price_index = math.min(cur_buy_count + i, price_list_length)
        total_cost = total_cost + price_list[price_index]
    end
    return total_cost
end

function BarData:GetRestRefreshCount(bar_type)
    local cur_refresh_count = self:GetCurRefreshCountByBarType(bar_type)
    local refresh_limit = CSFunction.get_bar_game_refresh_limit(ComMgrs.dy_data_mgr:ExGetRoleVip(), bar_type)
    return refresh_limit - cur_refresh_count
end

function BarData:SendBuyGameCount(bar_type)
    local get_content_func = function (select_num)
        local cost_item_dict = {}
        local count = self:CalcBuyChallengeCountCost(bar_type, select_num)
        cost_item_dict[self.bar_game_cost_item] = count
        local cost_item_data = SpecMgrs.data_mgr:GetItemData(self.bar_game_cost_item)
        local desc = string.format(UIConst.Text.BAR_GAME_COST_FORMAT, cost_item_data.name, count, select_num)
        return {item_dict = cost_item_dict, desc_str = desc}
    end
    local confirm_cb = function (select_num)
        SpecMgrs.msg_mgr:SendBuyBarChallengeCount({bar_type = bar_type, count = select_num}, function (resp)
            if resp.errcode ~= 0 then
                SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.BUY_BAR_CHALLENGE_COUNT_FAILED)
            end
        end)
    end
    SpecMgrs.ui_mgr:ShowSelectItemUseByTb({
        get_content_func = get_content_func,
        max_select_num = SpecMgrs.data_mgr:GetParamData("buy_item_max_time").f_value,
        title = UIConst.Text.BUY_BAR_CHALLENGE_COUNT,
        confirm_cb = confirm_cb,
    })
end

function BarData:SendBarGeneralChallenge(msg_data)
    SpecMgrs.msg_mgr:SendBarGeneralChallenge(msg_data, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.SEND_BAR_GAME_RESULT_FAILED)
        else
            self.result_panel:SetActive(true)
        end
    end)
end

return BarData