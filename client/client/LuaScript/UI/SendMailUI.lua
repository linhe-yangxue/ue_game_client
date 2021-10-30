local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local SendMailUI = class("UI.SendMailUI",UIBase)

--  发送邮件
function SendMailUI:DoInit()
    SendMailUI.super.DoInit(self)
    self.prefab_path = "UI/Common/SendMailUI"
end

function SendMailUI:OnGoLoadedOk(res_go)
    SendMailUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function SendMailUI:Show(player_info)
    self.player_info = player_info
    if self.is_res_ok then
        self:InitUI()
    end
    SendMailUI.super.Show(self)
end

function SendMailUI:InitRes()
    self.send_mail_frame = self.main_panel:FindChild("SendMailFrame")
    self.send_mail_frame_close_btn = self.main_panel:FindChild("SendMailFrame/SendMailFrameCloseBtn")
    self:AddClick(self.send_mail_frame_close_btn, function()
        SpecMgrs.ui_mgr:HideUI(self)
    end)
    self.send_mail_frame_title = self.main_panel:FindChild("SendMailFrame/SendMailFrameTitle"):GetComponent("Text")
    self.send_mail_confirm_btn = self.main_panel:FindChild("SendMailFrame/SendMailConfirmBtn")
    self:AddClick(self.send_mail_confirm_btn, function()
        self:SendMail()
    end)
    self.send_mail_cancel_btn = self.main_panel:FindChild("SendMailFrame/SendMailCancelBtn")
    self:AddClick(self.send_mail_cancel_btn, function()
        SpecMgrs.ui_mgr:HideUI(self)
    end)
    self.send_mail_tip = self.send_mail_frame:FindChild("Tip"):GetComponent("Text")
    self.mail_input_field = self.main_panel:FindChild("SendMailFrame/MailInputField"):GetComponent("InputField")
    self.mail_placeholder = self.main_panel:FindChild("SendMailFrame/MailInputField/MailPlaceholder"):GetComponent("Text")
end

function SendMailUI:InitUI()
    self:SetTextVal()
    self:UpdateData()
    self:UpdateUIInfo()
end

function SendMailUI:UpdateData()

end

function SendMailUI:UpdateUIInfo()

end

function SendMailUI:SendMail()
    if self.mail_input_field.text == "" then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.SEND_MES_IS_NULL_TEXT)
        return
    end
    local cb = function()
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.SEND_MAIL_SUCCESS_TEXT)
        self:Hide()
    end
    SpecMgrs.msg_mgr:SendSendMailToFriend({uuid = self.player_info.uuid, msg = self.mail_input_field.text}, cb)
end

function SendMailUI:SetTextVal()
    self.mail_input_field.text = ""
    self.send_mail_frame_title.text = string.format(UIConst.Text.SEND_MAIL_TITLE_FORMAT, self.player_info.name)
    self.send_mail_tip.text = UIConst.Text.MAIL_TIP
    self.mail_placeholder.text = UIConst.Text.SEND_MAIL_TEXT_NUM_TIP
    self.send_mail_confirm_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SEND_TEXT
    self.send_mail_cancel_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CANCEL
end

function SendMailUI:Hide()
    self:DelAllCreateUIObj()
    SendMailUI.super.Hide(self)
end

return SendMailUI
