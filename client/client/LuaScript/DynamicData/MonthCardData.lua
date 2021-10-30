local EventUtil = require("BaseUtilities.EventUtil")
local MonthCardData = class("DynamicData.MonthCardData")
local UIFuncs = require("UI.UIFuncs")
local CSFunction = require("CSCommon.CSFunction")

local month_card_id = 1
local forever_card_id = 2

EventUtil.GeneratorEventFuncs(MonthCardData, "UpdateMonthCardInfo")
EventUtil.GeneratorEventFuncs(MonthCardData, "UpdateForeverCardInfo")
EventUtil.GeneratorEventFuncs(MonthCardData, "UpdateCardInfo")

function MonthCardData:DoInit()
    self.month_card_info = {}
    self.forever_card_info = {}
end

function MonthCardData:NotifyMonthCardExpired(msg)
    if month_card_id == msg.card_id then
        self.month_card_info = {}
        self:DispatchUpdateMonthCardInfo()
    elseif forever_card_id == msg.card_id then
        self.forever_card_info = {}
        self:DispatchUpdateForeverCardInfo()
    end
    self:DispatchUpdateCardInfo()
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Welfare.MonthCard, {self:CanReciveCard() and 1 or 0})
end

function MonthCardData:NotifyUpdateMonthCardInfo(msg)
    if msg.card_dict[month_card_id] then
        for k,v in pairs(msg.card_dict[month_card_id]) do
            self.month_card_info[k] = v
        end
        self:DispatchUpdateMonthCardInfo()
    end
    if msg.card_dict[forever_card_id] then
        for k,v in pairs(msg.card_dict[forever_card_id]) do
            self.forever_card_info[k] = v
        end
        self:DispatchUpdateForeverCardInfo()
    end
    self:DispatchUpdateCardInfo()
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Welfare.MonthCard, {self:CanReciveCard() and 1 or 0})
end

function MonthCardData:GetMonthCardData()
    return SpecMgrs.data_mgr:GetMonthlyCardData(month_card_id)
end

function MonthCardData:GetForeverCardData()
    return SpecMgrs.data_mgr:GetMonthlyCardData(forever_card_id)
end

function MonthCardData:GetMonthCardInfo()
    return self.month_card_info
end

function MonthCardData:GetForeverCardInfo()
    return self.forever_card_info
end

function MonthCardData:CanReciveCard()
    return self.month_card_info.is_received == false or self.forever_card_info.is_received == false
end

function MonthCardData:ClearAll()

end

return MonthCardData