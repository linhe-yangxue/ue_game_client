local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local MsgSelectBoxUI = class("UI.MsgSelectBoxUI", UIBase)

function MsgSelectBoxUI:DoInit()
    MsgSelectBoxUI.super.DoInit(self)
    self.prefab_path = "UI/Common/MsgSelectBoxUI"
end

function MsgSelectBoxUI:Show(param_tb)
    self.content = param_tb.content or ""
    self.confirm_cb = param_tb.confirm_cb
    self.cancel_cb = param_tb.cancel_cb
    self.delay_time = param_tb.delay_time
    self.default_confirm = param_tb.default_confirm
    self.is_show_cancel_btn = param_tb.is_show_cancel_btn == nil or param_tb.is_show_cancel_btn
    if self.is_res_ok then
        self:InitUI()
    end
    MsgSelectBoxUI.super.Show(self)
end

function MsgSelectBoxUI:OnGoLoadedOk(res_go)
    MsgSelectBoxUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function MsgSelectBoxUI:ConfirmBtnOnClick()
    if self.confirm_cb then self.confirm_cb() end
    self:Hide()
end
function MsgSelectBoxUI:CancelBtnOnClick()
    if self.cancel_cb then self.cancel_cb() end
    self:Hide()
end
function MsgSelectBoxUI:InitRes()
    local msg_box = self.main_panel:FindChild("Box")
    self.content_text = msg_box:FindChild("Content"):GetComponent("Text")
    self.confirm_btn = msg_box:FindChild("BtnList/ConfirmBtn")
    self.confirm_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CONFIRM
    self:AddClick(self.confirm_btn, function ()
        self:ConfirmBtnOnClick()
    end)
    self.cancel_btn = msg_box:FindChild("BtnList/CancelBtn")
    self.cancel_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CANCEL
    self:AddClick(self.cancel_btn, function ()
        self:CancelBtnOnClick()
    end)
end

function MsgSelectBoxUI:InitUI()
    self.content_text.text = self.content
    self.cancel_btn:SetActive(self.is_show_cancel_btn)
end

function MsgSelectBoxUI:Update(delta_time)
    if not self.is_res_ok or not self.delay_time then return end
    self.delay_time = self.delay_time - delta_time
    if self.delay_time < 0 then
        self.delay_time = nil
        if self.default_confirm then
            self:ConfirmBtnOnClick()
        else
            self:CancelBtnOnClick()
        end
    end
end

return MsgSelectBoxUI