local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local ChangeCountryUI = class("UI.ChangeCountryUI", UIBase)
local UIFuncs = require("UI.UIFuncs")

function ChangeCountryUI:DoInit()
    ChangeCountryUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ChangeCountryUI"
    self.dy_strategy_data = ComMgrs.dy_data_mgr.strategy_map_data
    self.country_data_list = SpecMgrs.data_mgr:GetAllCountryData()
    self.country_to_go = {}
end

function ChangeCountryUI:OnGoLoadedOk(res_go)
    ChangeCountryUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function ChangeCountryUI:Show(cb)
    self.cb = cb
    if self.is_res_ok then
        self:InitUI()
    end
    ChangeCountryUI.super.Show(self)
end

function ChangeCountryUI:InitRes()
    local panel = self.main_panel:FindChild("Panel")
    local top_bar = panel:FindChild("TopBar")
    top_bar:FindChild("Title"):GetComponent("Text").text = UIConst.Text.CHANGE_COUNTRY_TITLE
    self.close_btn = top_bar:FindChild("CloseBtn")
    self:AddClick(self.close_btn, function()
        SpecMgrs.ui_mgr:HideUI(self)
    end)
    self.item_parent = panel:FindChild("Scroll View/Viewport/Content")
    self.item_temp = self.item_parent:FindChild("Item")
    self.item_temp:SetActive(false)
    local btn_list = panel:FindChild("BtnList")
    self.confirm_btn = btn_list:FindChild("ConfirmBtn")
    self.confirm_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CONFIRM
    self:AddClick(self.confirm_btn, function()
        if self.cur_country_id then
            local cur_country_id = self.cur_country_id
            SpecMgrs.ui_mgr:HideUI(self)
            if self.cb then
                self.cb(cur_country_id)
            end
        else
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.PLEASE_SELECT_COUNTRY)
        end
    end)
    self.cancel_btn = btn_list:FindChild("CancelBtn")
    self.cancel_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CANCEL
    self:AddClick(self.cancel_btn, function()
         SpecMgrs.ui_mgr:HideUI(self)
    end)
    for i,v in ipairs(self.country_data_list) do
        local go = self:GetUIObject(self.item_temp, self.item_parent)
        self.country_to_go[i] = go
        self:AssignSpriteByIconID(v.icon, go:GetComponent("Image"))
        self:AddClick(go, function ()
            self:CountryOnClick(i)
        end)
        go:FindChild("Text"):GetComponent("Text").text = v.name
    end
    self.cur_country_iamge = panel:FindChild("CurCountry"):GetComponent("Image")
    self.cur_country_text = panel:FindChild("CurCountry/Text"):GetComponent("Text")
end

function ChangeCountryUI:InitUI()
    self:UpdatePanel()
end

function ChangeCountryUI:UpdatePanel()
    for i, go in ipairs(self.country_to_go) do
        local is_unlock = self.dy_strategy_data:CheckCountryIsUnlock(i)
        go:FindChild("Lock"):SetActive(not is_unlock)
    end
end

function ChangeCountryUI:Hide()
    if self.select_effect then
        self.select_effect:EffectEnd()
        self.select_effect = nil
    end
    self.cur_country_id = nil
    ChangeCountryUI.super.Hide(self)
end

function ChangeCountryUI:CountryOnClick(country_id)
    if self.cur_country_id and self.cur_country == country_id then return end
    if not self.dy_strategy_data:CheckCountryIsUnlock(country_id) then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.CURRENT_COUNTRY_LOCK)
        return
    end
    self:AddSelectEffect(country_id)
    self.cur_country_id = country_id
    local country_data = SpecMgrs.data_mgr:GetCountryData(country_id)
    self:AssignSpriteByIconID(country_data.icon, self.cur_country_iamge)
    self.cur_country_text.text = country_data.name
end

function ChangeCountryUI:AddSelectEffect(country_id)
    local go = self.country_to_go[country_id]
    if not self.select_effect then
        self.select_effect = UIFuncs.AddSelectEffect(self, go)
    else
        self.select_effect:SetNewAttachGo(go)
    end
end

return ChangeCountryUI
