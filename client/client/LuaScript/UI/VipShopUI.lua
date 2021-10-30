local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local VipShopUI = class("UI.VipShopUI",UIBase)
local UIFuncs = require("UI.UIFuncs")
local ItemUtil = require("BaseUtilities.ItemUtil")

local kPanelNum = 2
local kDailyGiftPanelIndex = 1
local kGiftPanelIndex = 2

local btn_str_list = {
    UIConst.Text.VIP_DAILY_GIFT,
    UIConst.Text.VIP_GIFT,
}

function VipShopUI:DoInit()
    VipShopUI.super.DoInit(self)
    self.prefab_path = "UI/Common/VipShopUI"
    self.dy_vip_data = ComMgrs.dy_data_mgr.vip_data
    self.tag_btn_list = {}
    self.panel_list = {}

    self.shop_id_to_go = {}
    self.item_go_list = {}
end

function VipShopUI:OnGoLoadedOk(res_go)
    VipShopUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function VipShopUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    VipShopUI.super.Show(self)
end

function VipShopUI:Update(delta_time)
    self:UpdateRefreshTime()
end

function VipShopUI:UpdateRefreshTime()
    local next_refresh_time = self.dy_vip_data:GetVipShopRefreshTime()
    local remian_time = next_refresh_time - Time:GetServerTime()
    self.refresh_text.text = UIFuncs.TimeDelta2Str(remian_time, 4, UIConst.Text.VIP_SHOP_REFRESH_TIME)
end

function VipShopUI:InitRes()
    UIFuncs.GetInitTopBar(self, self.main_panel, "VipShopUI")
    self:InitTop()
    self:InitMiddle()
end

function VipShopUI:InitTop()
    local top = self.main_panel:FindChild("Top")
    self.refresh_text = top:FindChild("RefreshObj/RefreshText"):GetComponent("Text")
    self.title_image = top:FindChild("TitleImage"):GetComponent("Image") -- TODO多语言
    self.unit_parent = top:FindChild("UnitRect")
end

function VipShopUI:InitMiddle()
    local middle = self.main_panel:FindChild("Middle")
    local tag_list_go = middle:FindChild("TagList")
    local panel_list_go = middle:FindChild("PanelList")
    for i  = 1, kPanelNum do
        local btn_go = tag_list_go:FindChild(i)
        self:AddClick(btn_go, function ()
            self:TagOnClick(i)
        end)
        table.insert(self.tag_btn_list, btn_go)
        self:ChangeTabBtnSelect(btn_go, false)
        btn_go:FindChild("Text"):GetComponent("Text").text = btn_str_list[i]
        local panel_go = panel_list_go:FindChild(i)
        table.insert(self.panel_list, panel_go)
    end
    -- 礼包界面
    local panel_go = self.panel_list[kGiftPanelIndex]
    self.shop_item_parent = panel_go:FindChild("Viewport/Content")
    self.shop_item_temp = self.shop_item_parent:FindChild("Item")
    self.shop_item_temp:SetActive(false)
    self.item_temp = UIFuncs.GetIconGo(self, self.shop_item_temp:FindChild("Scroll View/Viewport/Content"))
    self.item_temp:SetActive(false)
    self.shop_item_temp:FindChild("Right/Finished/Text"):GetComponent("Text").text = UIConst.Text.ALREADY_BUY_TEXT
    self.shop_item_temp:FindChild("Right/BuyBtn/Text"):GetComponent("Text").text = UIConst.Text.BUY_TEXT

    -- 每日礼包界面
    local panel_go = self.panel_list[kDailyGiftPanelIndex]
    self.daily_gift_text = panel_go:FindChild("Text"):GetComponent("Text")
    self:AddClick(panel_go:FindChild("Treasure"), function ()
        self:GiftPreviewOnClick()
    end)
    self.daily_gift_btn = panel_go:FindChild("BuyBtn")
    self.buybtn_effect = self.daily_gift_btn:FindChild("Effect")
    self:AddClick(self.daily_gift_btn, function ()
        self:GiftBtnOnClick()
    end)
end

function VipShopUI:ChangeTabBtnSelect(btn_go, is_on)
    local color_hex = is_on and UIConst.Color.Default or UIConst.Color.Gray
    btn_go:FindChild("Text"):GetComponent("Text").color = UIFuncs.HexToRGBColor(color_hex)
    btn_go:FindChild("Select"):SetActive(is_on)
end

function VipShopUI:GetShopItem(vip_shop_id)
    local vip_shop_data = SpecMgrs.data_mgr:GetVIPShopData(vip_shop_id)
    local vip_level = self.dy_vip_data:GetVipLevel()
    local index = vip_level + 1
    local buy_limit = vip_shop_data.buy_num[index]
    if buy_limit <= 0 then return end -- 不能购买
    local go = self:GetUIObject(self.shop_item_temp, self.shop_item_parent)
    self.shop_id_to_go[vip_shop_id] = go
    local cost_item_id = vip_shop_data.cost_item_list[1]
    local cost_item_data = SpecMgrs.data_mgr:GetItemData(cost_item_id)
    local buy_num = self.dy_vip_data:GetVipShopBuyNum(vip_shop_id)
    local discount = self.dy_vip_data:GetDiscount(vip_shop_id)
    local discount_go = go:FindChild("Top/Discount")
    local is_show_discount = discount < 1
    discount_go:SetActive(is_show_discount)
    if is_show_discount then
        discount_go:FindChild("Text"):GetComponent("Text").text = UIFuncs.GetDiscountStr(discount)
    end
    local is_show_buy_btn = buy_num < buy_limit
    local buy_btn_go = go:FindChild("Right/BuyBtn")
    local buy_limit_go = go:FindChild("Right/BuyLimit")
    local consum_item_go = go:FindChild("Right/ConsumItem")
    if is_show_buy_btn then
        buy_limit_go:GetComponent("Text").text = string.format(UIConst.Text.CAN_BUY_NUM, buy_num, buy_limit)
        self:AssignSpriteByIconID(cost_item_data.icon, consum_item_go:GetComponent("Image"))
        consum_item_go:FindChild("Text"):GetComponent("Text").text = math.ceil(vip_shop_data.cost_item_value[1] * discount)
    end
    consum_item_go:SetActive(is_show_buy_btn)
    buy_limit_go:SetActive(is_show_buy_btn)
    buy_btn_go:SetActive(is_show_buy_btn)
    go:FindChild("Right/Finished"):SetActive(not is_show_buy_btn)

    local present_item_id = vip_shop_data.item_id
    local present_item_data = SpecMgrs.data_mgr:GetItemData(present_item_id)
    local temp_param_tb = {
        quality = present_item_data.quality,
        is_on_dark_bg = true,
    }
    local color = UIFuncs.GetQualityColorStr(temp_param_tb)
    go:FindChild("Top/Name/Text"):GetComponent("Text").text = string.format(UIConst.Text.SIMPLE_COLOR, color, present_item_data.name)
    local item_data_list = ItemUtil.GetGiftPackageItemList(present_item_id)
    local item_parent = go:FindChild("Scroll View/Viewport/Content")
    for i, item_info in ipairs(item_data_list) do
        self:GetInitItem(item_parent, item_info)
    end
    self:AddClick(go:FindChild("Right/BuyBtn"),function ()
        local buy_one_item_dict = self.dy_vip_data:GatherCastItemDict(vip_shop_id, 1)
        if not UIFuncs.CheckItemCountByDict(buy_one_item_dict, true) then return end
        local param_tb = {
            title = UIConst.Text.BUY_GIFT,
            max_select_num = buy_limit - buy_num,
            confirm_cb = function (select_num)
                self:SendBuyVipShopItem(vip_shop_id, select_num)
            end,
            get_content_func = function(select_num)
                return self:GetSelectItemUseUIContent(vip_shop_id, select_num)
            end,
        }
        SpecMgrs.ui_mgr:ShowSelectItemUseByTb(param_tb)
    end)
end

function VipShopUI:TagOnClick(index)
    if self.cur_panel_index and self.cur_panel_index == index then return end
    if self.cur_panel_index then
        self:HidePanel(self.cur_panel_index)
    end
    self.cur_panel_index = index
    self:ShowPanel(index)
end

function VipShopUI:ShowPanel(index)
    self.panel_list[index]:SetActive(true)
    self:ChangeTabBtnSelect(self.tag_btn_list[index], true)
    self:UpdatePanel(index)
end

function VipShopUI:UpdatePanel(index)
    if index == kGiftPanelIndex then
        self:ClearGiftPanelGo()
        local all_shop_data_list = SpecMgrs.data_mgr:GetAllVIPShopData()
        for shop_id, shop_data in ipairs(all_shop_data_list) do
            self:GetShopItem(shop_id)
        end
    elseif index == kDailyGiftPanelIndex then
        local vip_level = self.dy_vip_data:GetVipLevel()
        local vip_data = SpecMgrs.data_mgr:GetVipData(vip_level)
        self.daily_gift_text.text = UIFuncs.GetItemName({item_id = vip_data.free_gift})
        local is_daily_gift_can_get = self.dy_vip_data:CheckDailyGift()
        self.daily_gift_btn:GetComponent("Button").interactable = is_daily_gift_can_get
        local btn_str = is_daily_gift_can_get and UIConst.Text.RECEIVE_TEXT or UIConst.Text.ALREADY_RECEIVE_TEXT
        self.daily_gift_btn:FindChild("Text"):GetComponent("Text").text = btn_str
        self.buybtn_effect:SetActive(is_daily_gift_can_get)
        local worth_item_name = UIFuncs.GetItemName({item_id = vip_data.worth_item})
        local worth_num = vip_data.free_gift_worth
        self.daily_gift_btn:FindChild("Worth"):GetComponent("Text").text = string.format(UIConst.Text.WORTH_NUM_ITME, worth_num, worth_item_name)
    end
end

function VipShopUI:HidePanel(index)
    self.panel_list[index]:SetActive(false)
    self:ChangeTabBtnSelect(self.tag_btn_list[index], false)
    self:ClearPanel(index)
end

function VipShopUI:ClearPanel(index)
    if index == kGiftPanelIndex then
        self:ClearGiftPanelGo()
    elseif index == kDailyGiftPanelIndex then
    end
end

function VipShopUI:SendBuyVipShopItem(shop_id, shop_num)
    SpecMgrs.msg_mgr:SendMsg("SendBuyVipShopItem", {shop_id = shop_id, shop_num = shop_num})
end

function VipShopUI:GetSelectItemUseUIContent(vip_shop_id, select_num)
    local content_tb = {}
    local vip_shop_data = SpecMgrs.data_mgr:GetVIPShopData(vip_shop_id)
    content_tb.item_dict = self.dy_vip_data:GatherCastItemDict(vip_shop_id, select_num)
    local item_name = SpecMgrs.data_mgr:GetItemData(vip_shop_data.item_id).name
    content_tb.desc_str = string.format(UIConst.Text.BUY_GIFT_TIP, select_num, item_name)
    return content_tb
end

function VipShopUI:GetInitItem(parent, param_tb)
    local go = self:GetUIObject(self.item_temp, parent)
    table.insert(self.item_go_list, go)
    param_tb.go = go
    param_tb.ui = self
    UIFuncs.InitItemGo(param_tb)
    return go
end

function VipShopUI:InitUI()
    self:UpdateDefaultUnit()
    self:UpdateRefreshTime()
    self:TagOnClick(kDailyGiftPanelIndex)
    self:RegisterEvent(self.dy_vip_data, "UpdateVipShopInfo", function ()
        self:UpdatePanel(self.cur_panel_index)
    end)
    self:RegisterEvent(self.dy_vip_data, "UpdateVipInfo", function ()
        self:UpdatePanel(self.cur_panel_index)
    end)
end

function VipShopUI:UpdateDefaultUnit()
    local unit_id = SpecMgrs.data_mgr:GetParamData("vip_shop_default_unit").unit_id
    self:ClearUnit("unit")
    self.unit = self:AddFullUnit(unit_id, self.unit_parent)
end

function VipShopUI:Hide()
    self:HidePanel(self.cur_panel_index)
    self.cur_panel_index = nil
    self:ClearUnit("unit")
    VipShopUI.super.Hide(self)
end

function VipShopUI:ClearGiftPanelGo()
    self:ClearGoDict("item_go_list")
    self:ClearGoDict("shop_id_to_go")
end

function VipShopUI:GiftPreviewOnClick()
    local vip_level = self.dy_vip_data:GetVipLevel()
    local vip_data = SpecMgrs.data_mgr:GetVipData(vip_level)
    local item_id = vip_data.free_gift
    SpecMgrs.ui_mgr:ShowItemPreviewUI(item_id)
end

function VipShopUI:GiftBtnOnClick()
    if self.dy_vip_data:CheckDailyGift() then
        SpecMgrs.msg_mgr:SendMsg("SendReceiveVipDailyGift")
        self.daily_gift_btn:GetComponent("Button").interactable = false
    end
end

return VipShopUI