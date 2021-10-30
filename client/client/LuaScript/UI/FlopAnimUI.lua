local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local CelebrityHotelUI = require("UI.CelebrityHotelUI")
local FlopAnimUI = class("UI.FlopAnimUI",UIBase)

--  翻牌子ui
function FlopAnimUI:DoInit()
    FlopAnimUI.super.DoInit(self)
    self.prefab_path = "UI/Common/FlopAnimUI"
    self.start_rotate = false
end

function FlopAnimUI:OnGoLoadedOk(res_go)
    FlopAnimUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function FlopAnimUI:Show(lover_id)
    self.lover_id = lover_id
    if self.is_res_ok then
        self:InitUI()
    end
    FlopAnimUI.super.Show(self)
end

function FlopAnimUI:InitRes()

end

function FlopAnimUI:InitUI()
    SpecMgrs.timer_mgr:AddTimer(function()
        SpecMgrs.ui_mgr:ShowUI("SpoilUI")
        self:Hide()
    end, 2.5, 1)
    CelebrityHotelUI.SetLoverCardMsg(self.main_panel:FindChild("LoverCard"), self.lover_id)
end

return FlopAnimUI
