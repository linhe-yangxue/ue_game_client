local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local CSConst = require("CSCommon.CSConst")
local FestivalExchangeUI = class("UI.LimitTimeActivity.FestivalExchangeUI")

--  节日兑换
function FestivalExchangeUI:InitRes(owner)
    self.owner = owner
    self.activity_sell_frame = self.owner.main_panel:FindChild("ActivitySellFrame")
    self.bg = self.owner.main_panel:FindChild("ActivitySellFrame/Bg"):GetComponent("Image")
    self.unit_rect = self.owner.main_panel:FindChild("ActivitySellFrame/UnitRect")
    self.count_down_text = self.owner.main_panel:FindChild("ActivitySellFrame/CountDownText"):GetComponent("Text")
    self.option = self.owner.main_panel:FindChild("ActivitySellFrame/OptionList/Option")
    self.option_list = self.owner.main_panel:FindChild("ActivitySellFrame/OptionList")
    self.sell_list = self.owner.main_panel:FindChild("ActivitySellFrame/SellList/ViewPort/SellMesList")

    self.sell_item = self.owner.main_panel:FindChild("ActivitySellFrame/SellList/ViewPort/SellMesList/SellMes")

    self.desc_text = self.owner.main_panel:FindChild("ActivitySellFrame/Text"):GetComponent("Text")
    self:SetTextVal()

    self.option:SetActive(false)
    self.activity_sell_frame:SetActive(false)
    self.sell_item:SetActive(false)
end

function FestivalExchangeUI:Show(festival_group_id)
    self.festival_group_id = festival_group_id
    self.tag_create_list = {}
    self:ClearRes()
    self.activity_sell_frame:SetActive(true)
    self:UpdateData()
    self:UpdateUIInfo()
    self.owner:AddHalfUnit(self.show_unit_id, self.unit_rect)
    ComMgrs.dy_data_mgr.bag_data:RegisterUpdateBagItemEvent("FestivalExchangeUI", function(_, op, bag_item)
        if bag_item.item_id == self.festival_group_data.welfare_stuff or bag_item.item_id == self.festival_group_data.luxury_stuff then
            self:UpdateOptionRedPoint()
        end
    end)
end

function FestivalExchangeUI:Update()
    local ts = self.exchange_end_time - Time:GetServerTime()
    local str
    if ts < 0 then
        str = UIConst.Text.ALREADY_FINISH_TEXT
    else
        str = UIFuncs.GetCountDownDayStr(ts)
        str = string.format(UIConst.Text.DAILY_SELL_COUNT_DOWN, str)
    end
    self.count_down_text.text = str
end

function FestivalExchangeUI:SetTextVal()
    self.sell_item:FindChild("BuyBtn/Text"):GetComponent("Text").text = UIConst.Text.EXCHANGE
    self.sell_item:FindChild("AlreadyBuy/Text"):GetComponent("Text").text = UIConst.Text.ALREADY_EXCHANGE
end

function FestivalExchangeUI:UpdateData()
    self.festival_group_data = SpecMgrs.data_mgr:GetFestivalGroupData(self.festival_group_id)
    self.festival_data = ComMgrs.dy_data_mgr.festival_activity_data:GetCurFestivalActivity(self.festival_group_id)
    self.festival_info = ComMgrs.dy_data_mgr.festival_activity_data.festival_data_dict
    self.exchange_data_list = ComMgrs.dy_data_mgr.festival_activity_data:GetExchangeList(self.festival_group_id)
    self.show_unit_id = self.festival_group_data.exchange_show_unit
    self.exchange_end_time = ComMgrs.dy_data_mgr.festival_activity_data:GetExchangeEndTime(self.festival_group_id)
    self.exchange_info_list = {}
    for i,info in pairs(self.festival_info) do
        for k,v in pairs(info.exchange_dict) do
            self.exchange_info_list[k] = v
        end
    end
    self.desc_text.text = UIFuncs.MergeStrList(self.festival_group_data.activity_sell_desc)
end

function FestivalExchangeUI:UpdateUIInfo()
    self.option_obj_list = {}
    for i, tag in ipairs(self.festival_group_data.exchange_tag_list) do
        local option = self.owner:GetUIObject(self.option, self.option_list)
        option:FindChild("Text"):GetComponent("Text").text = tag
        table.insert(self.option_obj_list, option)
        table.insert(self.create_obj_list, option)
    end
    self:UpdateOptionRedPoint()
    self.option_selector = UIFuncs.CreateSelector(self.owner, self.option_obj_list, function(index)
        self:SelectTag(index)
    end)
    self.option_selector:SelectObj(1)
    UIFuncs.AssignSpriteByIconID(self.festival_group_data.exchange_bg, self.bg)
end

function FestivalExchangeUI:UpdateOptionRedPoint()
    for i, option in ipairs(self.option_obj_list) do
        local show_exchange_list = {}
        local tag = self.festival_group_data.exchange_tag_list[i]
        for i, data in ipairs(self.exchange_data_list) do
            if data.tag == tag then
                table.insert(show_exchange_list, data)
            end
        end
        option:FindChild("Tip"):SetActive(ComMgrs.dy_data_mgr.festival_activity_data:CheckCanExchangeItem(show_exchange_list))
    end
end

function FestivalExchangeUI:SelectTag(index)
    self.owner:DelObjDict(self.tag_create_list)
    self.tag_create_list = {}
    local tag = self.festival_group_data.exchange_tag_list[index]
    local show_exchange_list = {}
    for i, data in ipairs(self.exchange_data_list) do
        if data.tag == tag then
            table.insert(show_exchange_list, data)
        end
    end

    local can_not_exchange_list = {}
    local can_exchange_list = {}
    for i, data in ipairs(show_exchange_list) do
        local can_exchange_time = self.exchange_info_list[data.id]
        if can_exchange_time == 0 then
            table.insert(can_not_exchange_list, data)
        else
            table.insert(can_exchange_list, data)
        end
    end
    self:CreateExchangeList(can_exchange_list)
    self:CreateExchangeList(can_not_exchange_list)
    self:UpdateOptionRedPoint()
end

function FestivalExchangeUI:CreateExchangeList(exchange_list)
    for i, data in ipairs(exchange_list) do
        local item = self.owner:GetUIObject(self.sell_item, self.sell_list)
        self:SetItemMes(item, data)
        self:SetItemObj(item, data)
        table.insert(self.create_obj_list, item)
        table.insert(self.tag_create_list, item)
    end
end

function FestivalExchangeUI:SetItemObj(item, data)
    local sell_item = UIFuncs.SetItem(self.owner, data.sell_item_id, data.sell_item_num, item:FindChild("ShopItem"))
    local cost_item_id = self:GetCostItem(data)
    local cost_item = UIFuncs.SetItem(self.owner, cost_item_id, data.cost_item_num, item:FindChild("CostItemList/CostItem"))

    table.insert(self.create_obj_list, sell_item)
    table.insert(self.create_obj_list, cost_item)
    table.insert(self.tag_create_list, sell_item)
    table.insert(self.tag_create_list, cost_item)
end

function FestivalExchangeUI:SetItemMes(item, data)
    local can_exchange_time = self.exchange_info_list[data.id]
    local buy_time_text = item:FindChild("BuyTimeText")
    local buy_btn = item:FindChild("BuyBtn")
    local already_buy = item:FindChild("AlreadyBuy")
    if can_exchange_time == 0 then
        buy_time_text:SetActive(false)
        buy_btn:SetActive(false)
        already_buy:SetActive(true)
    else
        buy_time_text:SetActive(true)
        buy_btn:SetActive(true)
        already_buy:SetActive(false)
        buy_time_text:GetComponent("Text").text = string.format(UIConst.Text.OVERPLUS_BUY_TIMR_FORMAT, can_exchange_time, data.limit_buy_time)
        self.owner:AddClick(buy_btn, function()
            local price_list = {{item_id = self:GetCostItem(data), count = data.cost_item_num}}
            local cb = function(buy_num)
                self:ExchangeItem(item, data, buy_num)
            end
            UIFuncs.ShowBuyShopItemUI(data.sell_item_id, data.sell_item_num, can_exchange_time, price_list, cb)
        end)
    end
end

function FestivalExchangeUI:ExchangeItem(item, data, buy_num)
    local cb = function(resp)
        self:UpdateData()
        if not self.owner.is_res_ok then return end
        self.option_selector:ReselectSelectObj()
    end
    SpecMgrs.msg_mgr:SendGetFestivalActivityExchange({exchange_id = data.id, exchange_cnt = buy_num}, cb)
end

function FestivalExchangeUI:GetCostItem(data)
    local cost_item_id
    if data.cost_item_type == CSConst.FestivalStuffType.welfare then
        cost_item_id = self.festival_group_data.welfare_stuff
    else
        cost_item_id = self.festival_group_data.luxury_stuff
    end
    return cost_item_id
end

function FestivalExchangeUI:ClearRes()
    ComMgrs.dy_data_mgr.bag_data:UnregisterUpdateBagItemEvent("FestivalExchangeUI")
    self.owner:DelObjDict(self.create_obj_list)
    self.create_obj_list = {}
    self.owner:DestroyAllUnit()
end

function FestivalExchangeUI:Hide()
    self:ClearRes()
    self.activity_sell_frame:SetActive(false)
end

return FestivalExchangeUI
