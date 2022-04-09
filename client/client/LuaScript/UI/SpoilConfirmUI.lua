local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local EffectConst = require("Effect.EffectConst")
local EventUtil = require("BaseUtilities.EventUtil")
local SpoilConfirmUI = class("UI.SpoilConfirmUI",UIBase)

EventUtil.GeneratorEventFuncs(SpoilConfirmUI, "CloseUI")

--  宠爱确认界面
function SpoilConfirmUI:DoInit()
    SpoilConfirmUI.super.DoInit(self)
    self.prefab_path = "UI/Common/SpoilConfirmUI"

    self.data_mgr = SpecMgrs.data_mgr
    self.is_click_spoil = false
    self.wait_to_enter_spoil = 0.5
    self.wait_to_show_time = 0.3
end

function SpoilConfirmUI:OnGoLoadedOk(res_go)
    SpoilConfirmUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function SpoilConfirmUI:Show(lover_id, lover_level,fashion_id)
    self.lover_id = lover_id
    self.lover_level = lover_level
    self.fashion_id = fashion_id
    if self.is_res_ok then
        self:InitUI()
    end
    SpoilConfirmUI.super.Show(self)
end

function SpoilConfirmUI:InitRes()
    local confirm_panel = self.main_panel:FindChild("ConfirmPanel")

    self.need_diamond_text = self.main_panel:FindChild("ConfirmPanel/MesPanel/NeedDiamondText"):GetComponent("Text")
    self.intimacy_text = self.main_panel:FindChild("ConfirmPanel/MesPanel/IntimacyText"):GetComponent("Text")
    self.intimacy_exp_text = self.main_panel:FindChild("ConfirmPanel/MesPanel/IntimacyExpText"):GetComponent("Text")
    self.power_text = self.main_panel:FindChild("ConfirmPanel/MesPanel/PowerText"):GetComponent("Text")
    self.power_point_text = self.main_panel:FindChild("ConfirmPanel/MesPanel/PowerPointText"):GetComponent("Text")
    self.spoil_btn_text = self.main_panel:FindChild("ConfirmPanel/SpoilBtn/Text"):GetComponent("Text")
    self.cancel_spoil_btn_text = self.main_panel:FindChild("ConfirmPanel/CancelSpoilBtn/Text"):GetComponent("Text")

    self.spoil_btn = confirm_panel:FindChild("SpoilBtn")
    self:AddClick(self.spoil_btn, function()
        if self.is_click_spoil then return end
        if not UIFuncs.CheckItemCount(self.level_data.cost_item, self.level_data.cost_num, true) then return end
        self.is_click_spoil = true
        self:AddTimer(function()
            self:SendDoteLover()
        end, self.wait_to_enter_spoil, 1)

        local param_tb = {
            effect_id = EffectConst.EF_ID_Lover_button_click,
        }
        self:RemoveUIEffect(self.spoil_btn, nil, true)
        self:AddUIEffect(self.spoil_btn, param_tb, false, true)
    end)
    self:AddClick(confirm_panel:FindChild("CancelSpoilBtn"), function()
        if self.is_click_spoil then return end
        self:Hide()
    end)
end

function SpoilConfirmUI:InitUI()
    self.is_click_spoil = false
    self:SetTextVal()
    self.level_data = self.data_mgr:GetLoverLevelData(self.lover_level)
    self.need_diamond_text.text = self.level_data.cost_num
    self.intimacy_exp_text.text = string.format(UIConst.Text.ADD_VALUE_FORMAL, self.level_data.dote_exp)
    self.power_point_text.text = string.format(UIConst.Text.ADD_VALUE_FORMAL, self.level_data.dote_power_value)
    self:ShowUIEffect()
end

function SpoilConfirmUI:SetTextVal()
    self.intimacy_text.text = UIConst.Text.SPOIL_INTIMACY_EXP_TEXT
    self.power_text.text = UIConst.Text.LOVER_POWER_TEXT
    self.cancel_spoil_btn_text.text = UIConst.Text.CANCEL
    self.spoil_btn_text.text = UIConst.Text.APPOINTMENT
end

function SpoilConfirmUI:SendDoteLover()
    local resp_cb = function (resp)
        if resp.errcode ~= 1 then
            ComMgrs.dy_data_mgr.lover_data:DispatchUpdateLoverSpoilStateEvent(true)
            local lover_info = ComMgrs.dy_data_mgr.lover_data:GetLoverInfo(self.lover_id)
            local lover_level_data = SpecMgrs.data_mgr:GetLoverLevelData(lover_info.level)
            local show_tip_list = {}
            table.insert(show_tip_list, string.format(UIConst.Text.ADD_POWER_POINT, lover_level_data.dote_power_value))
            table.insert(show_tip_list, string.format(UIConst.Text.ADD_EXP, lover_level_data.dote_exp))
            SpecMgrs.ui_mgr:ShowUI("SpoilUI", self.lover_id, resp.child_info, nil, self.fashion_id)
        end
        self:Hide()
    end
    SpecMgrs.msg_mgr:SendDoteLover({lover_id = self.lover_id}, resp_cb)
end

function SpoilConfirmUI:ShowUIEffect()
    self:AddTimer(function()
        local param_tb = {
            effect_id = EffectConst.EF_ID_Lover_button_effect,
        }
        self:AddUIEffect(self.spoil_btn, param_tb, false, true)
    end, self.wait_to_enter_spoil, 1)
end

function SpoilConfirmUI:Hide()
    self:DispatchCloseUI()
    self:RemoveUIEffect(self.spoil_btn)
    self:DelAllCreateUIObj()
    SpoilConfirmUI.super.Hide(self)
end

return SpoilConfirmUI
