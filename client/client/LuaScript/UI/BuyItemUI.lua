local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local ItemUtil = require("BaseUtilities.ItemUtil")
local BuyItemUI = class("UI.BuyItemUI",UIBase)

-- 通用购买界面
function BuyItemUI:DoInit()
    BuyItemUI.super.DoInit(self)
    self.prefab_path = "UI/Common/BuyItemUI"
end

function BuyItemUI:OnGoLoadedOk(res_go)
    BuyItemUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function BuyItemUI:Show(param_tb)
    self.title_str = param_tb.title_str
    self.up_tip_str = param_tb.up_tip_str
    self.cost_item = param_tb.cost_item
    self.unit_price = param_tb.unit_price
    self.unit_price_func = param_tb.unit_price_func
    self.buy_max_num = param_tb.buy_max_num or 99
    self.callback = param_tb.callback

    self.cost_item_icon = SpecMgrs.data_mgr:GetItemData(self.cost_item).icon
    self.buy_num = 1
    if self.is_res_ok then
        self:InitUI()
    end
    BuyItemUI.super.Show(self)
end

function BuyItemUI:InitRes()
    self.title = self.main_panel:FindChild("Content/TopPanel/Title"):GetComponent("Text")
    self.close_btn = self.main_panel:FindChild("Content/TopPanel/CloseBtn")
    self:AddClick(self.close_btn, function()
        SpecMgrs.ui_mgr:HideUI(self)
    end)
    self.up_tip_text = self.main_panel:FindChild("Content/ContentPanel/UpTipText"):GetComponent("Text")
    self.down_tip_text = self.main_panel:FindChild("Content/ContentPanel/DownTipText")
    self.confirm_btn = self.main_panel:FindChild("Content/ContentPanel/ConfirmBtn")
    self:AddClick(self.confirm_btn, function()
        self.callback(self.buy_num, self.price)
        SpecMgrs.ui_mgr:HideUI(self)
    end)
    self.confirm_btn_text = self.main_panel:FindChild("Content/ContentPanel/ConfirmBtn/ConfirmBtnText"):GetComponent("Text")
    self.cancel_btn = self.main_panel:FindChild("Content/ContentPanel/CancelBtn")
    self:AddClick(self.cancel_btn, function()
        SpecMgrs.ui_mgr:HideUI(self)
    end)
    self.cancel_btn_text = self.main_panel:FindChild("Content/ContentPanel/CancelBtn/CancelBtnText"):GetComponent("Text")
    self.add_one_button = self.main_panel:FindChild("Content/ContentPanel/AddOneButton")
    self:AddClick(self.add_one_button, function()
        self:AddVal(1)
    end)
    self.reduce_one_button = self.main_panel:FindChild("Content/ContentPanel/ReduceOneButton")
    self:AddClick(self.reduce_one_button, function()
        self:AddVal(-1)
    end)
    self.add_ten_button = self.main_panel:FindChild("Content/ContentPanel/AddTenButton")
    self:AddClick(self.add_ten_button, function()
       self:AddVal(10)
    end)
    self.reduce_ten_button = self.main_panel:FindChild("Content/ContentPanel/ReduceTenButton")
    self:AddClick(self.reduce_ten_button, function()
        self:AddVal(-10)
    end)
    self.num_text = self.main_panel:FindChild("Content/ContentPanel/Num/NumText"):GetComponent("Text")
end

function BuyItemUI:InitUI()
    self:SetTextVal()
    self:UpdateNumText()
end

function BuyItemUI:UpdateNumText()
    self.price = 0
    if self.unit_price then
        self.price = self.buy_num * self.unit_price
    elseif self.unit_price_func then
        for i = 1, self.buy_num do
            self.price = self.price + self.unit_price_func(i)
        end
    else
        return
    end
    local str
    if self.price <= ItemUtil.GetItemNum(self.cost_item) then
        str = string.format(UIConst.Text.PRICE_FORMAT, self.cost_item_icon, self.price)
    else
        str = string.format(UIConst.Text.PRICE_FORMAT, self.cost_item_icon, self.price)
    end
    self.image_list = self:SetTextPic(self.down_tip_text, str)
    self.num_text.text = self.buy_num
end

function BuyItemUI:SetTextVal()
    self.title.text = self.title_str
    self.up_tip_text.text = self.up_tip_str
    self.confirm_btn_text.text = UIConst.Text.CONFIRM
    self.cancel_btn_text.text = UIConst.Text.CANCEL
end

function BuyItemUI:AddVal(val)
    local last_buy_num = self.buy_num
    self.buy_num = math.clamp(self.buy_num + val, 1, self.buy_max_num)
    if last_buy_num == self.buy_num then return end
    self:UpdateNumText()
end

return BuyItemUI
