local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local CharityUI = class("UI.CharityUI", UIBase)

function CharityUI:DoInit()
    CharityUI.super.DoInit(self)
    self.last_luck_icon = nil
    self.prefab_path = "UI/Common/CharityUI"
    self.dy_travel_data = ComMgrs.dy_data_mgr.travel_data
    self.max_luck = SpecMgrs.data_mgr:GetParamData("travel_luck_limit").f_value
    self.max_set_luck = SpecMgrs.data_mgr:GetParamData("set_luck_recover_max_value").f_value
end

function CharityUI:OnGoLoadedOk(res_go)
    CharityUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function CharityUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    CharityUI.super.Show(self)
end

function CharityUI:Hide()
    self.cur_set_luck = nil
    self.cur_cost_item = nil
    ComMgrs.dy_data_mgr:UnregisterUpdateCurrencyEvent("CharityUI")
    self.dy_travel_data:UnregisterUpdateTravelInfoEvent("CharityUI")
    CharityUI.super.Hide(self)
end

function CharityUI:InitRes()
    local content = self.main_panel:FindChild("Content")
    local item_panel = content:FindChild("ItemPanel")
    self.food_count = item_panel:FindChild("Food/Count"):GetComponent("Text")
    self.money_count = item_panel:FindChild("Money/Count"):GetComponent("Text")
    self.diamond_count = item_panel:FindChild("Diamond/Count"):GetComponent("Text")
    local top_menu_panel = content:FindChild("Top")
    self:AddClick(top_menu_panel:FindChild("CloseBtn"), function ()
        SpecMgrs.msg_mgr:SendSetLuckRecoverValue({set_value = self.cur_set_luck, set_item_id = self.cur_cost_item}, function (resp)
            if resp.errcode ~= 0 then
                SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.SET_RECOVER_VALUE_FAILED)
            end
        end)
        self:Hide()
    end)
    top_menu_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CHARITY_TEXT

    local cur_luck_panel = content:FindChild("CurLuck")
    self.cur_luck_desc = cur_luck_panel:FindChild("CurLuckDesc"):GetComponent("Text")
    local cur_luck_bar = cur_luck_panel:FindChild("LuckBar")
    self.cur_luck_value = cur_luck_bar:FindChild("LuckValue"):GetComponent("Image")
    self.cur_luck_value_text = cur_luck_bar:FindChild("LuckText"):GetComponent("Text")
    cur_luck_panel:FindChild("TipsText"):GetComponent("Text").text = UIConst.Text.CHARITY_TIPS

    local auto_charity_panel = content:FindChild("AutoCharity")
    auto_charity_panel:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.AUTO_CHARITY
    local set_charity_panel = auto_charity_panel:FindChild("SetCharityPanel")
    set_charity_panel:FindChild("SetValue"):GetComponent("Text").text = UIConst.Text.LUCK_SETTING_TEXT
    set_charity_panel:FindChild("Tip"):GetComponent("Text").text = UIConst.Text.MANUAL_CHARITY_TIPS
    self.cur_set_value_text = set_charity_panel:FindChild("ValueBg/Text"):GetComponent("Text")
    self:AddClick(set_charity_panel:FindChild("Reduce"), function ()
        self.cur_set_luck = math.clamp(self.cur_set_luck - 2, 0, self.max_set_luck)
        self:UpdateAutoCharity()
    end)
    self:AddClick(set_charity_panel:FindChild("Add"), function ()
        self.cur_set_luck = math.clamp(self.cur_set_luck + 2, 0, self.max_set_luck)
        self:UpdateAutoCharity()
    end)
    local select_material_panel = auto_charity_panel:FindChild("SelectMaterial")
    self.cost_money_toggle = select_material_panel:FindChild("CostMoney")
    self.cost_money_toggle:FindChild("Label"):GetComponent("Text").text = UIConst.Text.AUTO_COST_MONEY
    self:AddToggle(self.cost_money_toggle, function (is_on)
        if is_on then
            self.cur_cost_item = CSConst.Virtual.Money
        else
            if self.cur_cost_item == CSConst.Virtual.Money then
                self.cur_cost_item = nil
            end
        end
    end)
    self.cost_food_toggle = select_material_panel:FindChild("CostFood")
    self.cost_food_toggle:FindChild("Label"):GetComponent("Text").text = UIConst.Text.AUTO_COST_FOOD
    self:AddToggle(self.cost_food_toggle, function (is_on)
        if is_on then
            self.cur_cost_item = CSConst.Virtual.Food
        else
            if self.cur_cost_item == CSConst.Virtual.Food then
                self.cur_cost_item = nil
            end
        end
    end)

    local manual_charity_panel = content:FindChild("ManualCharity")
    manual_charity_panel:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.MANUAL_CHARITY
    local money_panel = manual_charity_panel:FindChild("MoneyPanel")
    money_panel:FindChild("Desc"):GetComponent("Text").text = UIConst.Text.MONEY_CHARITY
    self.money_cost_text = money_panel:FindChild("Cost"):GetComponent("Text")
    self.money_result_text = money_panel:FindChild("Result"):GetComponent("Text")
    local money_charity_btn = money_panel:FindChild("CharityBtn")
    money_charity_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.MONEY_CHARITY
    self:AddClick(money_charity_btn, function ()
        self:SendRecoverLuck(CSConst.Virtual.Money)
    end)
    local food_panel = manual_charity_panel:FindChild("FoodPanel")
    food_panel:FindChild("Desc"):GetComponent("Text").text = UIConst.Text.FOOD_CHARITY
    self.food_cost_text = food_panel:FindChild("Cost"):GetComponent("Text")
    self.food_result_text = food_panel:FindChild("Result"):GetComponent("Text")
    local food_charity_bth = food_panel:FindChild("CharityBtn")
    food_charity_bth:FindChild("Text"):GetComponent("Text").text = UIConst.Text.FOOD_CHARITY
    self:AddClick(food_charity_bth, function ()
        self:SendRecoverLuck(CSConst.Virtual.Food)
    end)
    local diamond_panel = manual_charity_panel:FindChild("DiamondPanel")
    diamond_panel:FindChild("Desc"):GetComponent("Text").text = UIConst.Text.DIAMOND_CHARITY
    self.diamond_cost_text = diamond_panel:FindChild("Cost"):GetComponent("Text")
    self.diamond_result_text = diamond_panel:FindChild("Result"):GetComponent("Text")
    local diamond_charity_btn = diamond_panel:FindChild("CharityBtn")
    diamond_charity_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DIAMOND_CHARITY
    self:AddClick(diamond_charity_btn, function ()
        self:SendRecoverLuck(CSConst.Virtual.Diamond)
    end)
end

function CharityUI:InitUI()
    self:UpdateTopPanel()
    self:UpdateTravelInfo()
    self.cur_cost_item = self.dy_travel_data:GetCurRecoverLuckCostItem()
    self:UpdateAutoCharity()
    ComMgrs.dy_data_mgr:RegisterUpdateCurrencyEvent("CharityUI", self.UpdateTopPanel, self)
    self.dy_travel_data:RegisterUpdateTravelInfoEvent("CharityUI", self.UpdateTravelInfo, self)
end

function CharityUI:UpdateTravelInfo()
    self:UpdateLuck()
    self:UpdateManualCharity()
end

function CharityUI:UpdateTopPanel()
    local currency_data = ComMgrs.dy_data_mgr:GetCurrencyData()
    self.money_count.text = UIFuncs.AddCountUnit(currency_data[CSConst.Virtual.Money] or 0)
    self.food_count.text = UIFuncs.AddCountUnit(currency_data[CSConst.Virtual.Food] or 0)
    self.diamond_count.text = UIFuncs.AddCountUnit(currency_data[CSConst.Virtual.Diamond] or 0)
end

function CharityUI:UpdateLuck()
    self.cur_luck_desc.text = string.format(UIConst.Text.CUR_LUCK, self.dy_travel_data:GetCurLuckDesc())
    local cur_luck = self.dy_travel_data:GetCurLuckValue()
    self.cur_luck_value_text.text = string.format(UIConst.Text.PER_VALUE, cur_luck, self.max_luck)
    local now_luck_icon_id = nil

    local icon_data = SpecMgrs.data_mgr:GetAllLuckValueIconData()
    for id, data in ipairs(icon_data) do
        local min_value = math.min(data.value_range[1], data.value_range[2])
        local max_value = math.max(data.value_range[1], data.value_range[2])
        if cur_luck >= min_value and cur_luck <= max_value then
            now_luck_icon_id = id
            break
        end
    end
    if not self.last_luck_icon or now_luck_icon_id ~= self.last_luck_icon then
        self.last_luck_icon = now_luck_icon_id
        local res_path = icon_data[now_luck_icon_id].img_path
        local res_name = icon_data[now_luck_icon_id].img_name
        UIFuncs.AssignUISpriteSync(res_path, res_name, self.cur_luck_value)
    end
    self.cur_luck_value.fillAmount = cur_luck / self.max_luck
end


function CharityUI:UpdateAutoCharity()
    self.cur_set_luck = self.cur_set_luck or self.dy_travel_data:GetCurSetLuck()
    if not self.cur_set_luck then self.cur_set_luck = self.max_set_luck end
    self.cur_set_value_text.text = self.cur_set_luck
    self.cost_money_toggle:GetComponent("Toggle").isOn = (self.cur_cost_item == CSConst.Virtual.Money)
    self.cost_food_toggle:GetComponent("Toggle").isOn = (self.cur_cost_item == CSConst.Virtual.Food)
end

function CharityUI:UpdateManualCharity()
    self.money_cost_text.text, self.money_result_text.text = self.dy_travel_data:GetRecoverCostAndEffect(CSConst.Virtual.Money)
    self.food_cost_text.text, self.food_result_text.text = self.dy_travel_data:GetRecoverCostAndEffect(CSConst.Virtual.Food)
    self.diamond_cost_text.text, self.diamond_result_text.text = self.dy_travel_data:GetRecoverCostAndEffect(CSConst.Virtual.Diamond)
end

function CharityUI:SendRecoverLuck(item_id)
    if self.dy_travel_data:GetCurLuckValue() < self.max_luck then
        local item_data = SpecMgrs.data_mgr:GetItemData(item_id)
        SpecMgrs.msg_mgr:SendRecoverLuck({item_id = item_id}, function (resp)
            if resp.errcode ~= 0 then
                SpecMgrs.ui_mgr:ShowMsgBox(string.format(UIConst.Text.RECOVER_FAILED, item_data.name))
            end
        end)
    else
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.REACH_MAX_LUCK)
    end
end

return CharityUI