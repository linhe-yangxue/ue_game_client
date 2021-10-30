local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local GameMsgBoxUI = class("UI.GameMsgBoxUI",UIBase)

--  帮助信息ui
function GameMsgBoxUI:DoInit()
    GameMsgBoxUI.super.DoInit(self)
    self.prefab_path = "UI/Common/GameMsgBoxUI"
end

function GameMsgBoxUI:OnGoLoadedOk(res_go)
    GameMsgBoxUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function GameMsgBoxUI:Show(title_str, mes_str)
    self.title_str = title_str
    self.mes_str = mes_str
    if self.is_res_ok then
        self:InitUI()
    end
    GameMsgBoxUI.super.Show(self)
end

function GameMsgBoxUI:InitRes()
    self.title_text = self.main_panel:FindChild("MesPanel/TitleText"):GetComponent("Text")
    self.mes_text = self.main_panel:FindChild("MesPanel/Scroll View/Viewport/MesText"):GetComponent("Text")
    self:AddClick(self.main_panel:FindChild("MesPanel/CloseButton"), function()
        SpecMgrs.ui_mgr:HideUI("GameMsgBoxUI")
    end)
end

function GameMsgBoxUI:InitUI()
    if self.title_str then
        self.title_text.text = self.title_str
    end
    if self.mes_str then
        self.mes_text.text = self.mes_str
    end
end

return GameMsgBoxUI
