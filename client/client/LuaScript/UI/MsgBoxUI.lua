local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local MsgBoxUI = class("UI.MsgBoxUI", UIBase)

MsgBoxUI.need_sync_load = true

function MsgBoxUI:DoInit()
    MsgBoxUI.super.DoInit(self)
    self.prefab_path = "UI/Common/MsgBoxUI"
end

function MsgBoxUI:Show(str)
    self.show_str = str
    self:UpdateContent()
    MsgBoxUI.super.Show(self)
end

function MsgBoxUI:OnGoLoadedOk(res_go)
    MsgBoxUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:UpdateContent()
end

function MsgBoxUI:InitRes()
    self.content_text = self.main_panel:FindChild("Content"):GetComponent("Text")
    self:AddClick(self.main_panel, function ()
        self:Hide()
    end)
end

function MsgBoxUI:UpdateContent()
    if self.is_res_ok then
        self.content_text.text = self.show_str
    end
end

return MsgBoxUI