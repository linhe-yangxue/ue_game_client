local UIBase = require("UI.UIBase")

local DebugUI = class("UI.DebugUI",UIBase)

function DebugUI:DoInit()
    DebugUI.super.DoInit(self)
    self.prefab_path = "UI/Common/DebugUI"
    self.is_showed_debug = false
    self.cache_command = {}
    self.cur_index = 0
end

function DebugUI:OnGoLoadedOk(res_go)
    DebugUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function DebugUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    DebugUI.super.Show(self)
end

function DebugUI:Hide()
    DebugUI.super.Hide(self)
end

function DebugUI:InitRes()
    self.debug_panel = self.main_panel:FindChild("DebugPanel")
    self.cmd_input = self.debug_panel:FindChild("CmdInput"):GetComponent("InputField")
    self:AddClick(self.debug_panel:FindChild("SendCmdBtn"),function ()
        local cmd_str = self.cmd_input.text
        if not cmd_str or cmd_str == "" then return end
        SpecMgrs.msg_mgr:SendCommand(cmd_str)
        table.insert(self.cache_command,cmd_str)
        self.cur_index = #self.cache_command + 1
        --self.cmd_input.text = ""
    end)
    self:AddClick(self.main_panel:FindChild("DebugBtn"),function ()
        self.is_showed_debug = not self.is_showed_debug
        self.debug_panel:SetActive(self.is_showed_debug)
        if self.is_showed_debug then self.cmd_input.text = "" end
    end)
end

function DebugUI:InitUI()
    self.cur_index = #self.cache_command + 1
end

function DebugUI:GetCacheCommand(index_offset)
    self.cur_index = math.clamp(self.cur_index + index_offset,1,#self.cache_command)
    self.cmd_input.text = self.cache_command[self.cur_index]
end


return DebugUI