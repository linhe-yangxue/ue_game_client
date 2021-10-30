local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local MeetMsgUI = class("UI.MeetMsgUI",UIBase)

--  邂逅记录ui
function MeetMsgUI:DoInit()
    MeetMsgUI.super.DoInit(self)
    self.prefab_path = "UI/Common/MeetMsgUI"
end

function MeetMsgUI:OnGoLoadedOk(res_go)
    MeetMsgUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function MeetMsgUI:Show(param_tb)
    if self.is_res_ok then
        self:InitUI()
    end
    self.lover_name = param_tb.lover_name
    self.mes = param_tb.mes
    MeetMsgUI.super.Show(self)
end

function MeetMsgUI:InitRes()
	local mes_panel = self.main_panel:FindChild("MesPanel")

    self.lover_name_text = mes_panel:FindChild("LoverNameText"):GetComponent("Text")
    self.mes_text = mes_panel:FindChild("Scroll View/Viewport/MesText"):GetComponent("Text")
    self:AddClick(self.main_panel:FindChild("MesPanel/CloseButton"), function()
        self:Hide()
    end)
end

function MeetMsgUI:InitUI()
    self:UpdateContent()
end

function MeetMsgUI:UpdateContent()
    self.lover_name_text.text = self.lover_name
	self.mes_text.text = self.mes
end

return MeetMsgUI
