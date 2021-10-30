local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local ItemUtil = require("BaseUtilities.ItemUtil")
local CSConst = require("CSCommon.CSConst")
local ShoppingUI = class("UI.ShoppingUI",UIBase)

local exchange_item_num = 2
local normal_shop_space = 10
local vip_shop_space = 20

local get_buy_time_func_dict = {
    [UIConst.ShopList.ArenaShop] = "ExGetArenaShopBuyTime",
    [UIConst.ShopList.TrainShop] = "ExGetTrainShopBuyTime",
    [UIConst.ShopList.HuntShop] = "ExGetHuntShopBuyTime",
    [UIConst.ShopList.SalonShop] = "ExGetSalonShopBuyTime",
    [UIConst.ShopList.PartyShop] = "ExGetPartyShopBuyTime",
    [UIConst.ShopList.NormalShop] = "ExGetNormalShopBuyTime",
    [UIConst.ShopList.CrystalShop] = "ExGetCrystalShopBuyTime",
    [UIConst.ShopList.HeroShop] = "ExGetHeroShopBuyTime",
    [UIConst.ShopList.LoverShop] = "ExGetLoverShopBuyTime",
    [UIConst.ShopList.DrawShop] = "ExGetDrawShopBuyTime",
    [UIConst.ShopList.FeatsShop] = "ExGetFeatsShopBuyTime",
    [UIConst.ShopList.DynastyShop] = "ExGetDynastyShopBuyTime",
}

local buy_func_dict = {
    [UIConst.ShopList.ArenaShop] = "SendBuyArenaShopItem",
    [UIConst.ShopList.TrainShop] = "SendBuyTrainShopItem",
    [UIConst.ShopList.HuntShop] = "SendBuyHuntShopItem",
    [UIConst.ShopList.SalonShop] = "SendBuySalonShopItem",
    [UIConst.ShopList.PartyShop] = "SendBuyPartyShopItem",
    [UIConst.ShopList.NormalShop] = "SendBuyNormalShopItem",
    [UIConst.ShopList.CrystalShop] = "SendBuyCrystalShopItem",
    [UIConst.ShopList.HeroShop] = "SendBuyHeroShopItem",
    [UIConst.ShopList.LoverShop] = "SendBuyLoverShopItem",
    [UIConst.ShopList.DrawShop] = "SendBuyRechargeDrawIntegralShop",
    [UIConst.ShopList.FeatsShop] = "SendBuyFeatsShopItem",
    [UIConst.ShopList.DynastyShop] = "SendBuyDynastyShopItem",
}

local send_refresh_func_dict = {
    [UIConst.ShopList.HuntShop] = "SendRefreshHuntShop",
    [UIConst.ShopList.SalonShop] = "SendRefreshSalonShop",
    [UIConst.ShopList.PartyShop] = "SendRefreshPartyShop",
    [UIConst.ShopList.HeroShop] = "SendRefreshHeroShopItem",
    [UIConst.ShopList.LoverShop] = "SendRefreshLoverShopItem",
}

local get_shop_refresh_data_dict = {
    [UIConst.ShopList.HeroShop] = "ExGetHeroShopRefreshMes",
    [UIConst.ShopList.LoverShop] = "ExGetLoverShopRefreshMes",
}

local init_shop_up_frame_dict = {
    [UIConst.ShopList.NormalShop] = "InitNormalShopUpFrame",
}

function ShoppingUI.TrainShopCanShowFunc(shop_data)
    local can_show = true
    local tips_text
    if shop_data.star_num and shop_data.star_num > ComMgrs.dy_data_mgr.experiment_data.experiment_msg.history_star_num then
        can_show = false
        tips_text = string.format(UIConst.Text.STAR_LIMIT_TIP, shop_data.star_num)
    end
    return tips_text
end

function ShoppingUI.ArenaShopCanShowFunc(shop_data)
    local can_show = true
    local tips_text
    local histroy_rank = ComMgrs.dy_data_mgr:ExGetArenaHistoryRank() or 100000
    if shop_data.rank_limit and histroy_rank > shop_data.rank_limit then
        can_show = false
        tips_text = string.format(UIConst.Text.RANK_LIMIT_TIP, shop_data.rank_limit)
    end
    return tips_text
end

local can_show_func_dict = {
    [UIConst.ShopList.TrainShop] = ShoppingUI["TrainShopCanShowFunc"],
    [UIConst.ShopList.ArenaShop] = ShoppingUI["ArenaShopCanShowFunc"],
}

--  商店
function ShoppingUI:DoInit()
    ShoppingUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ShoppingUI"
    self.unit = nil
    self.normal_unit = nil
end

function ShoppingUI:OnGoLoadedOk(res_go)
    ShoppingUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function ShoppingUI:Show(shop_name)
    self:DelAllCreateUIObj()
    self:UnregisterEvent()
    self:DelObjDict(self.create_obj_list)
    self.shop_data_name = shop_name

    self.buy_func = SpecMgrs.msg_mgr[buy_func_dict[self.shop_data_name]]
    self.get_buy_time_func = ComMgrs.dy_data_mgr[get_buy_time_func_dict[self.shop_data_name]]
    self.send_refresh_func = SpecMgrs.msg_mgr[send_refresh_func_dict[self.shop_data_name]]

    self.can_show_func = can_show_func_dict[self.shop_data_name]

    self.get_shop_refresh_data_func = ComMgrs.dy_data_mgr[get_shop_refresh_data_dict[self.shop_data_name]]
-- self:InitRes()
    if self.is_res_ok then
        self:InitUI()
    end
    ShoppingUI.super.Show(self)
end

function ShoppingUI:InitRes()
    self.down_bg = self.main_panel:FindChild("DownBg")
    self.tag_btn_content = self.main_panel:FindChild("TagBtnContent")
    self.tag_button = self.main_panel:FindChild("TagBtnContent/TagButton")
    self.exchange_item_list = self.main_panel:FindChild("ExchangeItemList")
    self.exchange_item_list_content = self.main_panel:FindChild("ExchangeItemList/Viewport/Content")
    self.exchange_shopping_item = self.main_panel:FindChild("ExchangeItemList/Viewport/Content/ShoppingItem")
    self.exchange_item_list_scroll_rect = self.main_panel:FindChild("ExchangeItemList"):GetComponent("ScrollRect")

    self.buy_item_list = self.main_panel:FindChild("BuyItemList")
    self.buy_item_list_scroll_rect = self.main_panel:FindChild("BuyItemList"):GetComponent("ScrollRect")
    self.buy_item_list_content = self.main_panel:FindChild("BuyItemList/Viewport/Content")
    self.buy_item_list_content_vertical_group = self.main_panel:FindChild("BuyItemList/Viewport/Content"):GetComponent("VerticalLayoutGroup")

    self.buy_shopping_item = self.main_panel:FindChild("BuyItemList/Viewport/Content/ShoppingItem")
    self.vip_shopping_item = self.main_panel:FindChild("BuyItemList/Viewport/Content/VipShopItem")

    self.normal_shop_up_frame = self.main_panel:FindChild("NormalShopUpFrame")

    self.up_frame = self.main_panel:FindChild("UpFrame")
    self.refresh_obj = self.main_panel:FindChild("RefreshObj")
    self.shop_bg = self.main_panel:FindChild("UpFrame/ShopBg"):GetComponent("Image")
    self.normal_shop_bg = self.main_panel:FindChild("NormalShopUpFrame/ShopBg"):GetComponent("Image")
    self.title_image = self.main_panel:FindChild("UpFrame/TitleImage"):GetComponent("Image")
    self.refresh_text = self.main_panel:FindChild("RefreshObj/RefreshText"):GetComponent("Text")
    self.refresh_hour = self.main_panel:FindChild("RefreshHourText")
    self.tip_text = self.main_panel:FindChild("UpFrame/TipText"):GetComponent("Text")
    self.down_mes_list = self.main_panel:FindChild("DownMesList")
    self.down_mes_temp_text = self.main_panel:FindChild("DownMesList/TempText")
    self.refresh_button = self.main_panel:FindChild("RefreshButton")

    self.refresh_tip = self.main_panel:FindChild("RefreshButton/RefreshTipText")
    self.refresh_tip_text = self.main_panel:FindChild("RefreshButton/RefreshTipText"):GetComponent("Text")
    self:AddClick(self.refresh_button, function()
        self:RefreshShop()
    end)
    self.refresh_button_text = self.main_panel:FindChild("RefreshButton/RefreshButtonText"):GetComponent("Text")
    self.refresh_button_cost_text = self.main_panel:FindChild("RefreshButton/RefreshButtonCostText")

    self.length_down_mes_list = self.main_panel:FindChild("LengthDownMesList")
    self.title = self.main_panel:FindChild("TopBar/CloseBtn/Title"):GetComponent("Text")

    self.jump_text = self.main_panel:FindChild("JumpText")
    self.unit_rect = self.main_panel:FindChild("UpFrame/UnitRect")
    self.tag_button:SetActive(false)
    self.buy_shopping_item:SetActive(false)
    self.exchange_shopping_item:SetActive(false)
    self.down_mes_temp_text:SetActive(false)
    self.vip_shopping_item:SetActive(false)

    local width = self.exchange_item_list_content:GetComponent("RectTransform").rect.width
    local item_width = self.exchange_shopping_item:GetComponent("RectTransform").sizeDelta.x
    local grid_group = self.exchange_item_list_content:GetComponent("GridLayoutGroup")
    local spacing = grid_group.spacing
    spacing.x = (width - item_width * exchange_item_num) / 3
    grid_group.spacing = spacing
    self.start_offset_min = self.buy_item_list:GetComponent("RectTransform").offsetMin:Clone()
end

function ShoppingUI:Update()
    if not self.is_res_ok or not self.is_visible then return end
    if self.shop_data.refresh_time then
        local time_str
        local is_get_next_time = false
        for i, time in ipairs(self.shop_data.refresh_time) do
            if not is_get_next_time and Time:GetServerTime() < (time * CSConst.Time.Hour + self:GetTodayTime()) then
                time_str = UIFuncs.TimeDelta2Str((time * CSConst.Time.Hour + self:GetTodayTime()) - Time:GetServerTime(), 3)
                is_get_next_time = true
            end
        end
        if not is_get_next_time then -- 明天
            time_str = UIFuncs.TimeDelta2Str((self.shop_data.refresh_time[1] * CSConst.Time.Hour + self:GetTodayTime(1)) - Time:GetServerTime(), 3)
        end
        local refresh_str = ""
        for i, time in ipairs(self.shop_data.refresh_time) do
            if i == #self.shop_data.refresh_time then
                refresh_str = refresh_str .. string.format(UIConst.Text.TIME_HOUR_END_FORMAT, time)
            else
                refresh_str = refresh_str .. string.format(UIConst.Text.TIME_HOUR_FORMAT, time)
            end
        end

        self.refresh_text.text = string.format(UIConst.Text.REFLESH_TIME_TIP_FORMAT, time_str)
        local is_show = not self.send_refresh_func
        self.refresh_hour:SetActive(is_show)
        self.refresh_hour:GetComponent("Text").text = string.format(UIConst.Text.REFLESH_HOUR_TIP_FORMAT, refresh_str)
        local refresh_hour = self.refresh_obj:FindChild("RefreshHourText")
        refresh_hour:SetActive(not is_show)
        refresh_hour:GetComponent("Text").text = string.format(UIConst.Text.REFLESH_HOUR_TIP_FORMAT, refresh_str)
    elseif self.shop_data.loop_refresh_time and self.next_refresh_time then
        self.refresh_obj:FindChild("RefreshHourText"):SetActive(false)
        if not self.shop_update_data then return end
        local remain_ts = self.next_refresh_time - Time:GetServerTime()
        if self.shop_update_data.free_refresh_num == self.shop_data.free_refresh_num then
            self.refresh_text.text = string.format(UIConst.Text.FREE_REFRESH_TIME_FORMAT, self.shop_update_data.free_refresh_num, self.shop_data.free_refresh_num, UIConst.Text.IS_FULL_TEXT)
        else
            if remain_ts <= 0 then
                self:UpdateRefreshState()
                remain_ts = 0
            end
            self.refresh_text.text = string.format(UIConst.Text.FREE_REFRESH_TIME_FORMAT, self.shop_update_data.free_refresh_num, self.shop_data.free_refresh_num, UIFuncs.TimeDelta2Str(remain_ts, 3))
        end
    end
end

function ShoppingUI:GetTodayTime(day)
    day = day or 0
    local cDateCurrectTime = os.date("*t", Time:GetServerTime())
    local cDateTodayTime = os.time({year=cDateCurrectTime.year, month=cDateCurrectTime.month, day=cDateCurrectTime.day + day, hour=0,min=0,sec=0})
    return cDateTodayTime
end

function ShoppingUI:InitUI()
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), self.shop_data_name, nil)
    self:UpdateData()
    self:SetTextVal()
    self:UpdateUIInfo()
    self.tag_selector:SelectObj(1)
    if self.shop_data.unit_id then
        if self.unit then self:RemoveUnit(self.unit) end
        self.unit = self:AddHalfUnit(self.shop_data.unit_id, self.unit_rect)
    end
end

function ShoppingUI:UpdateData()
    self.shop_data = SpecMgrs.data_mgr:GetShopData(self.shop_data_name)
    if self.shop_data.refresh_time or self.shop_data.loop_refresh_time then
        local all_shop_data_list = require("Data." .. self.shop_data.shop_data_name)
        self.shop_item_data_list = {}
        local shop_dict = self.get_buy_time_func(ComMgrs.dy_data_mgr)
        for id, v in pairs(shop_dict) do
            table.insert(self.shop_item_data_list, all_shop_data_list[id])
        end
    else
        self.shop_item_data_list = require("Data." .. self.shop_data.shop_data_name)
    end
    table.sort(self.shop_item_data_list, function(a, b)
        return a.id < b.id
    end)
    self.tag_btn_list = {}
    self.shop_item_dic = {}
    self.show_shop_item_list = {}
    self.create_obj_list = {}
    self.item_id_list = {}
    self.obj_price_list_dict = {}
end

function ShoppingUI:UpdateUIInfo()
    if init_shop_up_frame_dict[self.shop_data_name] then
        local func = self[init_shop_up_frame_dict[self.shop_data_name]]
        func(self)
    else
        self:InitTopFrame()
    end
    for i, tag_name in ipairs(self.shop_data.tag_list) do
        local tag_btn = self:GetUIObject(self.tag_button, self.tag_btn_content)
        tag_btn:FindChild("Text"):GetComponent("Text").text = tag_name
        table.insert(self.tag_btn_list, tag_btn)
        table.insert(self.create_obj_list, tag_btn)
    end
    self.tag_selector = UIFuncs.CreateSelector(self, self.tag_btn_list, function(index)
        if self.shop_data.refresh_list then
            if self.shop_data.refresh_list[index] then
                self.exchange_item_list:SetActive(true)
                self.buy_item_list:SetActive(false)
            else
                self.exchange_item_list:SetActive(false)
                self.buy_item_list:SetActive(true)
            end
        end

        self.buy_item_list_scroll_rect.inertia = false
        self.exchange_item_list_scroll_rect.inertia = false

        self.buy_item_list_content:GetComponent("RectTransform").anchoredPosition = Vector3.zero
        self.exchange_item_list_content:GetComponent("RectTransform").anchoredPosition = Vector3.zero

        self:AddTimer(function()
            self.buy_item_list_scroll_rect.inertia = true
            self.exchange_item_list_scroll_rect.inertia = true
        end, 0.01, 1)
        for i, item in ipairs(self.show_shop_item_list) do
            item:SetActive(false)
        end
        self.show_shop_item_list = {}

        for obj, data in pairs(self.shop_item_dic) do
            if data.tag == self.shop_data.tag_list[index] then
                table.insert(self.show_shop_item_list, obj)
            end
        end
        for i, item in ipairs(self.show_shop_item_list) do
            item:SetActive(true)
        end
        for i, item in ipairs(self.show_shop_item_list) do
            self:UpdateBuyTime(item, self.shop_item_dic[item])
        end

        if self.shop_data.tag_vip_gift_list and self.shop_data.tag_vip_gift_list[index] then
            self.buy_item_list_content_vertical_group.spacing = vip_shop_space
        else
            self.buy_item_list_content_vertical_group.spacing = normal_shop_space
        end
    end)

    self.down_mes_list:SetActive(false)
    self.refresh_hour:SetActive(false)
    self.refresh_button:SetActive(false)
    self.refresh_obj:SetActive(false)
    self.down_bg:SetActive(false)
    self.refresh_tip:SetActive(false)
    if self.shop_data.is_show_down then
        self.down_bg:SetActive(true)
        if self.shop_data.refresh_time or self.shop_data.loop_refresh_time then
            self.refresh_obj:SetActive(true)
            if self.send_refresh_func then
                self.refresh_button:SetActive(true)
                self.refresh_hour:SetActive(false)
                self:SetItemNumTextPic(self.refresh_button_cost_text, self.shop_data.refresh_item, self.shop_data.refresh_price)
                self.refresh_button_text.text = UIConst.Text.REFLESH_TEXT
                if self.get_shop_refresh_data_func then
                    self.refresh_tip:SetActive(true)
                    self:UpdateRefreshState()
                else
                    self.refresh_tip:SetActive(false)
                end
            else
                self.refresh_button:SetActive(false)
            end
        end
        self:CreateDownMesList(self.down_mes_list)
        self.buy_item_list:GetComponent("RectTransform").offsetMin = self.start_offset_min
        self.exchange_item_list:GetComponent("RectTransform").offsetMin = self.start_offset_min
    else
        self.buy_item_list:GetComponent("RectTransform").offsetMin = Vector2.New(self.start_offset_min.x, 0)
        self.exchange_item_list:GetComponent("RectTransform").offsetMin = Vector2.New(self.start_offset_min.x, 0)
    end
    UIFuncs.AssignSpriteByIconID(self.shop_data.title_icon, self.title_image)
    UIFuncs.AssignSpriteByIconID(self.shop_data.shop_bg, self.shop_bg)

    if self.shop_data.jump_text then
        self.jump_text:GetComponent("Text").text = self.shop_data.jump_text
        self.jump_text:SetActive(true)

        self:AddClick(self.jump_text, function()
            SpecMgrs.ui_mgr:ShowUI(self.shop_data.jump_ui)
        end)
    else
        self.jump_text:SetActive(false)
    end
end

function ShoppingUI:InitTopFrame()
    self.up_frame:SetActive(true)
    self.normal_shop_up_frame:SetActive(false)

    if self.shop_data.refresh_list then
        local refresh_list = {}
        local not_refresh_list = {}
        for i, shop_data in ipairs(self.shop_item_data_list) do
            local tag_index = table.index(self.shop_data.tag_list, shop_data.tag)
            if self.shop_data.refresh_list[tag_index] then
                table.insert(refresh_list, shop_data)
            else
                table.insert(not_refresh_list, shop_data)
            end
        end
        self.exchange_item_list:SetActive(false)
        self.buy_item_list:SetActive(false)
        self:InitExchangeItemList(refresh_list)
        self:InitBuyItemList(not_refresh_list)
    else
        if self.shop_data.refresh_time or self.shop_data.loop_refresh_time then
            self.exchange_item_list:SetActive(true)
            self.buy_item_list:SetActive(false)
            self:InitExchangeItemList(self.shop_item_data_list)
        else
            self.exchange_item_list:SetActive(false)
            self.buy_item_list:SetActive(true)
            self:InitBuyItemList(self.shop_item_data_list)
        end
    end
end

function ShoppingUI:InitNormalShopUpFrame()
    self.up_frame:SetActive(false)
    self.normal_shop_up_frame:SetActive(true)
    self.normal_shop_up_frame:FindChild("DialogText"):GetComponent("Text").text = string.format(self.shop_data.dialog, self.shop_data.shop_name)
    if self.normal_unit then self:RemoveUnit(self.normal_unit) end
    self.normal_unit = self:AddHalfUnit(self.shop_data.unit_id, self.normal_shop_up_frame:FindChild("UnitRect"))
    self.exchange_item_list:SetActive(false)
    self.buy_item_list:SetActive(true)
    self:InitBuyItemList(self.shop_item_data_list)
    UIFuncs.AssignSpriteByIconID(self.shop_data.shop_bg, self.normal_shop_bg)
end

function ShoppingUI:CreateDownMesList(parent)
    parent:SetActive(true)
    if not self.shop_data.down_show_list then return end
    for i, item_id in ipairs(self.shop_data.down_show_list) do
        local text_obj = self:GetUIObject(self.down_mes_temp_text, parent)
        table.insert(self.create_obj_list, text_obj)
        table.insert(self.item_id_list, item_id)
        UIFuncs.RegisterUpdateItemNumFunc(self, "ShoppingUI" .. item_id, function(num)
            self:SetItemNumTextPic(text_obj, item_id, UIFuncs.AddCountUnit(num), UIConst.Text.BIG_ITEM_ICON_NUM_FORMAT)
        end, item_id)
    end
end

function ShoppingUI:InitBuyItemList(shop_item_data_list)
    for i, data in ipairs(shop_item_data_list) do
        local tips_text
        if self.can_show_func then
            tips_text = self.can_show_func(data)
        end
        local obj
        if data.gift_limit_num then
            if self:GetBuyTime(data) > 0 then
                obj = self:GetUIObject(self.vip_shopping_item, self.buy_item_list_content)
            end
        else
            obj = self:GetUIObject(self.buy_shopping_item, self.buy_item_list_content)
        end
        if obj then
            table.insert(self.create_obj_list, obj)
            self.shop_item_dic[obj] = data

            if data.gift_limit_num then
                self:SetVipBuyItem(obj, data)
            else
                self:SetBuyItem(obj, data, tips_text)
            end
        end
    end
end

function ShoppingUI:SetVipBuyItem(obj, data)
    obj:SetActive(false)
    local item_list = ItemUtil.GetGiftPackageItemList(data.item_id)
    local ret = UIFuncs.SetItemList(self, item_list, obj:FindChild("RewardItemList"))
    table.mergeList(self.create_obj_list, ret)

    obj:FindChild("ItemNameText"):GetComponent("Text").text = UIFuncs.GetItemName({item_id = data.item_id, change_name_color = false})
    obj:FindChild("LimitBuyText"):GetComponent("Text").text = string.format(UIConst.Text.VIP_LIMIT_FORMAT, data.vip_require_level)

    obj:FindChild("BuyButton/OriginalPriceText"):GetComponent("Text").text = data.orig_price_list[1]
    obj:FindChild("BuyButton/CurPriceText"):GetComponent("Text").text = data.cost_item_value[1]

    UIFuncs.AssignSpriteByItemID(data.cost_item_list[1], obj:FindChild("BuyButton/ItemImage"):GetComponent("Image"))

    self:AddClick(obj:FindChild("BuyButton"), function()
        local vip_level = ComMgrs.dy_data_mgr.vip_data:GetVipLevel()
        local require_level = data.vip_require_level or 0
        if vip_level < require_level then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.VIP_LEVEL_NOT_ENOUGH)
            return
        end
        self:BuyShop(data, obj)
    end)
end

function ShoppingUI:SetBuyItem(obj, data, tips_text)
    obj:SetActive(false)
    local create_item = UIFuncs.SetItem(self, data.item_id, self:GetItemCount(data), obj:FindChild("RewardItem"))
    table.insert(self.create_obj_list, create_item)
    obj:FindChild("BuyButton/BuyButtonText"):GetComponent("Text").text = UIConst.Text.BUY_TEXT
    obj:FindChild("ItemNameText"):GetComponent("Text").text = UIFuncs.GetItemName({item_id = data.item_id, change_name_color = false})
    obj:FindChild("UnlockBuyText"):SetActive(tips_text ~= nil)
    obj:FindChild("UnlockBuyText"):GetComponent("Text").text = tips_text or ""
    obj:FindChild("BuyButton"):GetComponent("Button").interactable = tips_text == nil

    local price_list = obj:FindChild("PriceList")
    local temp_text = price_list:FindChild("TempText")
    for i, item_id in ipairs(data.cost_item_list) do
        local text_obj = self:GetUIObject(temp_text, price_list)
        table.insert(self.create_obj_list, text_obj)
        self:SetItemNumTextPic(text_obj, item_id, data.cost_item_value[i])

        if not self.obj_price_list_dict[obj] then
            self.obj_price_list_dict[obj] = {}
        end
        table.insert(self.obj_price_list_dict[obj], text_obj)
    end
    self:AddClick(obj:FindChild("BuyButton"), function()
        self:BuyShop(data, obj)
    end)
    self:UpdateBuyTime(obj, data)
end

function ShoppingUI:InitExchangeItemList(shop_item_data_list)
    self.exchange_item_list_content:GetComponent("RectTransform").anchoredPosition = Vector3.zero
    for i, data in ipairs(shop_item_data_list) do
        if not self.can_show_func or self.can_show_func(data) then
            local obj = self:GetUIObject(self.exchange_shopping_item, self.exchange_item_list_content)
            table.insert(self.create_obj_list, obj)
            self.shop_item_dic[obj] = data
            self:AddClick(obj:FindChild("BuyButton"), function()
                self:BuyShop(data, obj)
            end)
            obj:SetActive(false)
            local item = UIFuncs.SetItem(self, data.item_id, self:GetItemCount(data), obj:FindChild("RewardItem"))
            table.insert(self.create_obj_list, item)
            obj:FindChild("LineUpBg"):SetActive(false)
            obj:FindChild("RecommendBg"):SetActive(false)
            obj:FindChild("ItemNameText"):GetComponent("Text").text = UIFuncs.GetItemName({item_id = data.item_id, change_name_color = false})
            obj:FindChild("BuyButton/Text"):GetComponent("Text").text = UIConst.Text.BUY_TEXT
            local temp = obj:FindChild("PriceList/TempText")
            local price_list = obj:FindChild("PriceList")

            for i,v in ipairs(data.cost_item_list) do
                local text = self:GetUIObject(temp, price_list)
                self:SetItemNumTextPic(text, data.cost_item_list[i], data.cost_item_value[i])
                table.insert(self.create_obj_list, text)
                if not self.obj_price_list_dict[obj] then
                    self.obj_price_list_dict[obj] = {}
                end
                table.insert(self.obj_price_list_dict[obj], text)
            end
            self:UpdateBuyTime(obj, data)
        end
    end
end

function ShoppingUI:UpdateBuyTime(obj, data)
    if data.gift_limit_num then return end
    local limit_buy_text = obj:FindChild("LimitBuyText")
    local buy_btn = obj:FindChild("BuyButton")
    local buy_time = self:GetBuyTime(data)

    local already_buy_time = self.get_buy_time_func(ComMgrs.dy_data_mgr)[data.id] or 0
    local discount = self:GetItemDiscount(data, already_buy_time)
    local tips_text
    if self.can_show_func then
        tips_text = self.can_show_func(data)
    end
    if limit_buy_text then
        if buy_time then
            limit_buy_text:SetActive(tips_text == nil)
            if data.daily_num or data.vip_buy_num then
                limit_buy_text:GetComponent("Text").text = string.format(UIConst.Text.DAILY_LIMIT_FORMAT, buy_time)
            elseif data.week_limit_num then
                limit_buy_text:GetComponent("Text").text = string.format(UIConst.Text.WEEK_LIMIT_FORMAT, buy_time)
            else
                limit_buy_text:GetComponent("Text").text = string.format(UIConst.Text.FOREVER_LIMIT_FORMAT, buy_time)
            end
        else
            limit_buy_text:SetActive(false)
        end
    end
    if buy_btn then
        if (buy_time and buy_time > 0) or buy_time == nil then
            buy_btn:GetComponent("Button").enabled = true
            buy_btn:FindChild("GrayImage"):SetActive(false)
        else
            buy_btn:GetComponent("Button").enabled = false
            buy_btn:FindChild("GrayImage"):SetActive(true)
        end
    end
    if self.shop_data_name == UIConst.ShopList.HeroShop then
        local item_data = SpecMgrs.data_mgr:GetItemData(data.item_id)
        if item_data.hero and ComMgrs.dy_data_mgr.night_club_data:CheckHeroIsLineUp(item_data.hero) then
            obj:FindChild("LineUpBg"):SetActive(true)
        else
            obj:FindChild("LineUpBg"):SetActive(false)
            obj:FindChild("RecommendBg"):SetActive(data.is_recommend == true)
        end
    end
    if discount and discount ~= 1 then
        obj:FindChild("DiscountText"):SetActive(true)
        obj:FindChild("DiscountBg"):SetActive(true)
        obj:FindChild("DiscountText"):GetComponent("Text").text = string.format(UIConst.Text.INTEGER_PERCENT, math.ceil(discount * 100))

    else
        obj:FindChild("DiscountText"):SetActive(false)
        obj:FindChild("DiscountBg"):SetActive(false)
    end
    discount = discount or 1
    if self.obj_price_list_dict[obj] then
        for i,v in ipairs(data.cost_item_list) do
            local price = math.ceil(data.cost_item_value[i] * discount)
            if self.shop_data_name == UIConst.ShopList.CrystalShop then
                price = data.cost_item_value[i]
            end
            self:SetItemNumTextPic(self.obj_price_list_dict[obj][i], v, price)
        end
    end
end

function ShoppingUI:GetBuyTime(data)
    local buy_time = nil
    if self.shop_data.refresh_time or self.shop_data.loop_refresh_time then
        buy_time = 1 - (self.get_buy_time_func(ComMgrs.dy_data_mgr)[data.id] or 0)
    end
    if data.gift_limit_num then
        buy_time = data.gift_limit_num - (self.get_buy_time_func(ComMgrs.dy_data_mgr)[data.id] or 0)
    end
    if data.vip_buy_num then
        buy_time = self:GetVipBuyLimit(data) - (self.get_buy_time_func(ComMgrs.dy_data_mgr)[data.id] or 0)
    end
    if data.forever_num then
        buy_time = data.forever_num - (self.get_buy_time_func(ComMgrs.dy_data_mgr)[data.id] or 0)
    end
    if data.daily_num then
        buy_time = data.daily_num - (self.get_buy_time_func(ComMgrs.dy_data_mgr)[data.id] or 0)
    end
    if data.week_limit_num then
        buy_time = data.week_limit_num - (self.get_buy_time_func(ComMgrs.dy_data_mgr)[data.id] or 0)
    end
    return buy_time
end

function ShoppingUI:BuyShop(data, obj)
    local vip = 0
    if self:GetBuyTime(data) == 0 then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.NOT_BUY_TIME)
        return
    end
    if self.shop_data.refresh_time or self.shop_data.loop_refresh_time then
        for i, item_id in ipairs(data.cost_item_list) do
            local item_count = data.cost_item_value[i]
            if not UIFuncs.CheckItemCount(item_id, item_count, true) then return end
        end
        self:SendBuyShop(data, 1, obj)
    else
        local price_list = {}
        for i, item_id in ipairs(data.cost_item_list) do
            table.insert(price_list, {item_id = item_id, count = data.cost_item_value[i]})
        end
        local already_buy_time = self.get_buy_time_func(ComMgrs.dy_data_mgr)[data.id] or 0
        if data.vip_buy_num then
            UIFuncs.ShowBuyShopItemUI(data.item_id, self:GetItemCount(data), self:GetBuyTime(data), price_list, function(buy_time)
                self:SendBuyShop(data, buy_time, obj)
            end, self:GetVipBuyLimit(data), already_buy_time, data.discount_num, data.discount)
        else
            UIFuncs.ShowBuyShopItemUI(data.item_id, self:GetItemCount(data), self:GetBuyTime(data), price_list, function(buy_time)
                self:SendBuyShop(data, buy_time, obj)
            end, nil, already_buy_time, data.discount_num, data.discount)
        end
    end
end

function ShoppingUI:SendBuyShop(data, buy_time, obj)
    local cb = function(resp)
        if not self.is_res_ok then return end
        if data.gift_limit_num then
            if self:GetBuyTime(data) == 0 then
                table.remove(self.create_obj_list, table.index(self.create_obj_list, obj))
                table.remove(self.show_shop_item_list, table.index(self.show_shop_item_list, obj))
                self.shop_item_dic[obj] = nil
                self:DelUIObject(obj)
            end
        end
        for i, item in ipairs(self.show_shop_item_list) do
            self:UpdateBuyTime(item, self.shop_item_dic[item])
        end
    end

    self.buy_func(SpecMgrs.msg_mgr, {shop_id = data.id, shop_num = buy_time}, cb)
end

function ShoppingUI:RefreshShop()
    if self.shop_update_data and self.shop_update_data.total_refresh_num == 0 then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.REFRESH_TIME_MAX_TEXT)
        return
    end
    local is_free = false
    if self.shop_update_data and self.shop_update_data.free_refresh_num > 0 then
        is_free = true
    end
    if not is_free and not UIFuncs.CheckItemCount(self.shop_data.refresh_item, self.shop_data.refresh_price, true) then
        return
    end
    local cb = function(resp)
        if resp.errcode == 1 then
            return
        end
        self:UnregisterEvent()
        self:DelObjDict(self.create_obj_list)
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.REFLESH_SUCCESS_TEXT)
        self:UpdateData()
        self:UpdateUIInfo()
        self.tag_selector:SelectObj(1, true)
        self:UpdateRefreshState()
    end
    self.send_refresh_func(SpecMgrs.msg_mgr, nil, cb)
end

function ShoppingUI:UpdateRefreshState()
    if self.get_shop_refresh_data_func then
        local data = self.get_shop_refresh_data_func(ComMgrs.dy_data_mgr)
        self.shop_update_data = data
        self.next_refresh_time = self.shop_data.loop_refresh_time * CSConst.Time.Minute + data.refresh_ts
        self.refresh_tip_text.text = string.format(UIConst.Text.LAST_REFRESH_TIME_FORMAT, data.total_refresh_num)
        if data.free_refresh_num > 0 then
            self.refresh_button:FindChild("RefreshButtonText"):SetActive(false)
            self.refresh_button:FindChild("RefreshButtonCostText"):SetActive(false)
            self.refresh_button:FindChild("RefreshText"):SetActive(true)
            self.refresh_button:FindChild("RefreshText"):GetComponent("Text").text = UIConst.Text.REFLESH_TEXT
        else
            self.refresh_button:FindChild("RefreshButtonText"):SetActive(true)
            self.refresh_button:FindChild("RefreshButtonCostText"):SetActive(true)
            self.refresh_button:FindChild("RefreshText"):SetActive(false)
            self:SetItemNumTextPic(self.refresh_button_cost_text, self.shop_data.refresh_item, self.shop_data.refresh_price)
        end
    end
end

function ShoppingUI:GetItemCount(data)
    local vip = ComMgrs.dy_data_mgr:ExGetRoleVip()
    local cur_level = ComMgrs.dy_data_mgr:ExGetRoleLevel()
    if self.shop_data_name == UIConst.ShopList.CrystalShop then
        for i = #data.item_count, 1, -1 do
            if vip >= data.require_vip[i] or cur_level >= data.require_level[i] then
                return data.item_count[i]
            end
        end
    else
        return data.item_count
    end
end

function ShoppingUI:GetVipBuyLimit(data)
    local vip = ComMgrs.dy_data_mgr:ExGetRoleVip()
    return data.vip_buy_num[vip + 1]
end

function ShoppingUI:GetItemDiscount(data, buy_time)
    buy_time = buy_time + 1
    if type(data.discount) == "table" then
        if self.shop_data_name == UIConst.ShopList.CrystalShop then -- 折扣根据出售的数量计算
            local item_count = self:GetItemCount(data)
            return string.format("%.2f", data.item_count[1] / item_count)
        else
            for i = 1, #data.discount_num do
                buy_time = buy_time - data.discount_num[i]
                if buy_time <= 0 then
                    return data.discount[i]
                end
            end
        end
    else
        return data.discount
    end
    return 1
end

function ShoppingUI:SetTextVal()
    self.tip_text.text = string.format(self.shop_data.dialog, self.shop_data.shop_name)
    self.title.text = self.shop_data.shop_name
    self.exchange_shopping_item:FindChild("LineUpBg/LineUpText"):GetComponent("Text").text = UIConst.Text.ALREADY_LINEUP_TEXT
    self.exchange_shopping_item:FindChild("RecommendBg/RecommendText"):GetComponent("Text").text = UIConst.Text.RECOMMEND_TEXT
end

function ShoppingUI:UnregisterEvent()
    if not self.item_id_list then return end
    for i, id in ipairs(self.item_id_list) do
        UIFuncs.UnregisterUpdateItemNum(self, "ShoppingUI" .. id, id)
    end
end

function ShoppingUI:Hide()
    if self.unit then self:RemoveUnit(self.unit) end
    if self.normal_unit then self:RemoveUnit(self.normal_unit) end
    self:UnregisterEvent()
    ShoppingUI.super.Hide(self)
end

return ShoppingUI
