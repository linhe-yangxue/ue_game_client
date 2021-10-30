local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local ItemUtil = require("BaseUtilities.ItemUtil")
local BuyShopItemUI = class("UI.BuyShopItemUI",UIBase)

--  购买物品界面
function BuyShopItemUI:DoInit()
    BuyShopItemUI.super.DoInit(self)
    self.prefab_path = "UI/Common/BuyShopItemUI"
end

function BuyShopItemUI:OnGoLoadedOk(res_go)
    BuyShopItemUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function BuyShopItemUI:Show(param_tb)
    self.shop_item_id = param_tb.item_id
    self.item_count = param_tb.item_count
    self.max_buy_time = param_tb.max_buy_time
    self.price_list = param_tb.price_list
    self.confirm_cb = param_tb.confirm_cb
    self.limit_day_buy_time = param_tb.limit_day_buy_time
    self.already_buy_time = param_tb.already_buy_time or 0
    self.discount_num_list = param_tb.discount_num_list
    self.discount_list = param_tb.discount_list
    if self.is_res_ok then
        self:InitUI()
    end
    BuyShopItemUI.super.Show(self)
end

function BuyShopItemUI:InitRes()
    self.title = self.main_panel:FindChild("Content/Title"):GetComponent("Text")

    self.close_btn = self.main_panel:FindChild("Content/CloseBtn")
    self:AddClick(self.close_btn, function()
        self:Hide()
    end)
    self.confirm_btn = self.main_panel:FindChild("Content/ConfirmBtn")
    self:AddClick(self.confirm_btn, function()
        if self.confirm_cb then
            self.confirm_cb(self.buy_num)
        end
        self:Hide()
    end)
    self.confirm_btn_text = self.main_panel:FindChild("Content/ConfirmBtn/ConfirmBtnText"):GetComponent("Text")
    self.cancel_btn = self.main_panel:FindChild("Content/CancelBtn")
    self:AddClick(self.cancel_btn, function()
        self:Hide()
    end)
    self.cancel_btn_text = self.main_panel:FindChild("Content/CancelBtn/CancelBtnText"):GetComponent("Text")
    self.add_one_button = self.main_panel:FindChild("Content/AddOneButton")
    self:AddClick(self.add_one_button, function()
        self:AddVal(1)
    end)
    self.reduce_one_button = self.main_panel:FindChild("Content/ReduceOneButton")
    self:AddClick(self.reduce_one_button, function()
        self:AddVal(-1)
    end)
    self.add_ten_button = self.main_panel:FindChild("Content/AddTenButton")
    self:AddClick(self.add_ten_button, function()
        self:AddVal(10)
    end)
    self.reduce_ten_button = self.main_panel:FindChild("Content/ReduceTenButton")
    self:AddClick(self.reduce_ten_button, function()
        self:AddVal(-10)
    end)
    self.num_text_input = self.main_panel:FindChild("Content/Num"):GetComponent("InputField")
    self:AddInputFieldValueChange(self.main_panel:FindChild("Content/Num"), function ()
        local select_num = tonumber(self.num_text_input.text)
        if self.num_text_input.text == "" then select_num = 0 end
        if self.limit_day_buy_time then
            select_num = math.min(select_num, self.limit_day_buy_time - self.already_buy_time)
            for i, price in ipairs(self.price_list) do
                select_num = math.min(select_num, self:GetMaxBuyTime(i, 1, self.limit_day_buy_time - self.already_buy_time))
            end
        else
            for i, price in ipairs(self.price_list) do
                local can_buy_time = math.floor(ItemUtil.GetItemNum(price.item_id) / price.count)
                select_num = math.min(select_num, can_buy_time)
            end
        end
        if self.max_buy_time then
            select_num = math.min(select_num, self.max_buy_time)
        end
        self.buy_num = math.ceil(select_num)
        self:UpdateNumText()
    end)
    self.show_item = self.main_panel:FindChild("Content/ShowItem")
    self.item_name_text = self.main_panel:FindChild("Content/ItemNameText"):GetComponent("Text")
    self.have_num_text = self.main_panel:FindChild("Content/HaveNumText"):GetComponent("Text")
    self.price_text = self.main_panel:FindChild("Content/PriceText")

    self.limit_buy_time_frame = self.main_panel:FindChild("Content/LimitBuyTimeFrame")
    self.normal_buy_time_frame = self.main_panel:FindChild("Content/NormalBuyTimeFrame")

    self.normal_buy_time_frame_price_text1 = self.normal_buy_time_frame:FindChild("PriceText1"):GetComponent("Text")
    self.normal_buy_time_frame_price_text2 = self.normal_buy_time_frame:FindChild("PriceText2"):GetComponent("Text")
    self.limit_buy_time_frame_price_text = self.limit_buy_time_frame:FindChild("PriceText"):GetComponent("Text")

    self.normal_buy_time_frame_price_list = self.normal_buy_time_frame:FindChild("PriceList")
    self.limit_buy_time_frame_price_list = self.limit_buy_time_frame:FindChild("PriceList")

    self.limit_time_text = self.limit_buy_time_frame:FindChild("LimitTimeText"):GetComponent("Text")
    self.refresh_time_text = self.limit_buy_time_frame:FindChild("RefreshTimeText"):GetComponent("Text")
end

function BuyShopItemUI:InitUI()
    self.buy_item_data = SpecMgrs.data_mgr:GetItemData(self.shop_item_id)
    self.limit_buy_time = self.max_buy_time or SpecMgrs.data_mgr:GetParamData("buy_item_max_time").f_value
    self.buy_num = 1
    local can_buy_time = nil
    if self.discount_num_list then
        for i, price in ipairs(self.price_list) do
            local buy_time = self:GetMaxBuyTime(i, 1, self.limit_buy_time)
            if can_buy_time == nil or can_buy_time > buy_time then
                can_buy_time = buy_time
            end
        end
    else
        for i, price in ipairs(self.price_list) do
            local buy_time = math.floor(ItemUtil.GetItemNum(price.item_id) / price.count)
            if can_buy_time == nil or can_buy_time > buy_time then
                can_buy_time = buy_time
            end
        end
    end
    self.max_buy_time = can_buy_time > self.limit_buy_time and self.limit_buy_time or can_buy_time

    self.price_text_list = {}
    self:UpdateUIInfo()
    self:SetTextVal()
    self:UpdateNumText()
end

function BuyShopItemUI:UpdateNumText()
    if self.discount_num_list then
        self:UpdatePriceList(self.limit_buy_time_frame_price_list)
    else
        self:UpdatePriceList(self.normal_buy_time_frame_price_list)
    end
   self.num_text_input.text = math.ceil(self.buy_num)
end

--  二分
function BuyShopItemUI:GetMaxBuyTime(price_index, begin_num, end_num)
    local cur_price = 0
    local own_item_num = ItemUtil.GetItemNum(self.price_list[price_index].item_id)
    local check_num = math.floor((begin_num + end_num) / 2)
    local price = UIFuncs.GetPrice(self.price_list[price_index].count, check_num, self.already_buy_time, self.discount_num_list, self.discount_list)
    local last_buy_price = UIFuncs.GetPrice(self.price_list[price_index].count, check_num - 1, self.already_buy_time, self.discount_num_list, self.discount_list)
    if price > own_item_num and last_buy_price <= own_item_num then
        return check_num - 1
    end
    if begin_num == end_num then
        return check_num
    end
    if price > own_item_num then
        return self:GetMaxBuyTime(price_index, begin_num, check_num - 1)
    elseif price < own_item_num then
        return self:GetMaxBuyTime(price_index, check_num + 1 , end_num)
    else
        return check_num
    end
end

function BuyShopItemUI:GetIcon(item_id)
    return SpecMgrs.data_mgr:GetItemData(item_id).icon
end

function BuyShopItemUI:UpdateUIInfo()
    self:SetItem(self.shop_item_id, self.item_count, self.show_item)
    if self.limit_day_buy_time then
        self.limit_buy_time_frame:SetActive(true)
        self.normal_buy_time_frame:SetActive(false)
        self.limit_time_text.text = string.format(UIConst.Text.DAY_BUY_LIMIT_FORMAT, self.limit_day_buy_time - self.already_buy_time)
        self:InitPriceList(self.limit_buy_time_frame_price_list)
    else
        self.limit_buy_time_frame:SetActive(false)
        self.normal_buy_time_frame:SetActive(true)
        if #self.price_list == 1 then
            self.normal_buy_time_frame:FindChild("PriceText1"):SetActive(true)
            self.normal_buy_time_frame:FindChild("PriceText2"):SetActive(false)
        elseif #self.price_list == 2 then
            self.normal_buy_time_frame:FindChild("PriceText1"):SetActive(false)
            self.normal_buy_time_frame:FindChild("PriceText2"):SetActive(true)
        end
        self:InitPriceList(self.normal_buy_time_frame_price_list)
    end
end

function BuyShopItemUI:InitPriceList(price_parent)
    for i = 1, #self.price_list do
        table.insert(self.price_text_list, self:GetUIObject(price_parent:FindChild("PriceCostText"), price_parent))
    end
end

function BuyShopItemUI:UpdatePriceList(price_parent)
    for i, text in ipairs(self.price_text_list) do
        local price = UIFuncs.GetPrice(self.price_list[i].count, self.buy_num, self.already_buy_time, self.discount_num_list, self.discount_list)
        self:SetTextPic(text, string.format(UIConst.Text.SMALL_ITEM_ICON_NUM_FORMAT, self:GetIcon(self.price_list[i].item_id), price))
    end
end

function BuyShopItemUI:SetTextVal()
    self.title.text = UIConst.Text.BUY_ITEM_TITLE
    local color = UIFuncs.GetQualityColorStr({quality = SpecMgrs.data_mgr:GetItemData(self.shop_item_id).quality, is_on_dark_bg = true})
    self.item_name_text.text = string.format(UIConst.Text.SIMPLE_COLOR, color, UIFuncs.GetItemName({item_data = self.buy_item_data}))
    self.have_num_text.text = string.format(UIConst.Text.HAVE_FORMAT, ItemUtil.GetItemNum(self.shop_item_id))
    self.confirm_btn_text.text = UIConst.Text.CONFIRM
    self.cancel_btn_text.text = UIConst.Text.CANCEL
    self.refresh_time_text.text = UIConst.Text.BUY_TIME_REFRESH_TEXT
    self.normal_buy_time_frame_price_text1.text = UIConst.Text.TOTAL_PRICE_TEXT
    self.normal_buy_time_frame_price_text2.text = UIConst.Text.TOTAL_PRICE_TEXT
    self.limit_buy_time_frame_price_text.text = UIConst.Text.TOTAL_PRICE_TEXT
end

function BuyShopItemUI:AddVal(val)
    local last_buy_num = self.buy_num
    self.buy_num = math.clamp(self.buy_num + val, 1, self.max_buy_time)
    if last_buy_num == self.buy_num then return end
    self:UpdateNumText()
end

function BuyShopItemUI:Hide()
    self:DelAllCreateUIObj()
    BuyShopItemUI.super.Hide(self)
end

return BuyShopItemUI
