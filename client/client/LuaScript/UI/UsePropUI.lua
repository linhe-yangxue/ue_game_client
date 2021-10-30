local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UsePropUI = class("UI.UsePropUI",UIBase)

--  道具使用ui, 等背包做好在写
function UsePropUI:DoInit()
    UsePropUI.super.DoInit(self)
    self.prefab_path = "UI/Common/UsePropUI"
end

function UsePropUI:OnGoLoadedOk(res_go)
    UsePropUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function UsePropUI:Show(param_tb)
    if self.is_res_ok then
        self:InitUI()
    end
    --  TODO:输入参数
    UsePropUI.super.Show(self)
end

function UsePropUI:InitRes()
    local mes_panel = self.main_panel:FindChild("MesPanel")
    self:AddClick(mes_panel:FindChild("CloseButton"), function()
        self:Hide()
    end)
    self:AddClick(mes_panel:FindChild("CanelButton"), function()
        self:Hide()
    end)
    self:AddClick(mes_panel:FindChild("ConfirmButton"), function()

    end)
    self:AddClick(mes_panel:FindChild("ReduceOneButton"), function()
        self:ChangeUseNum(-1)
    end)
    self:AddClick(mes_panel:FindChild("RetuceTenButton"), function()
        self:ChangeUseNum(-10)
    end)
    self:AddClick(mes_panel:FindChild("AddOneButton"), function()
        self:ChangeUseNum(1)
    end)
    self:AddClick(mes_panel:FindChild("AddTenButton"), function()
        self:ChangeUseNum(10)
    end)
end

function UsePropUI:InitUI()
    self.use_num = 0
end

function UsePropUI:ChangeUseNum(change_val)

end

return UsePropUI
