local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local ShareTraitorUI = class("UI.ShareTraitorUI", UIBase)

function ShareTraitorUI:DoInit()
    ShareTraitorUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ShareTraitorUI"
    self.share_traitor_unit = SpecMgrs.data_mgr:GetParamData("share_traitor_unit").unit_id
end

function ShareTraitorUI:OnGoLoadedOk(res_go)
    ShareTraitorUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function ShareTraitorUI:Hide()
    self:RemoveUnit(self.friend_unit)
    ShareTraitorUI.super.Hide(self)
end

function ShareTraitorUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    ShareTraitorUI.super.Show(self)
end

function ShareTraitorUI:InitRes()
    local content = self.main_panel:FindChild("Content")
    self.friend_model = content:FindChild("FriendModel")
    content:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SHARE_TRAITOR_TEXT
    local submit_btn = content:FindChild("SubmitBtn")
    submit_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CONFIRM
    self:AddClick(submit_btn, function ()
        self:SendShareTraitor()
    end)
    local cancel_btn = content:FindChild("CancelBtn")
    cancel_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CANCEL
    self:AddClick(cancel_btn, function ()
        self:Hide()
    end)
end

function ShareTraitorUI:InitUI()
    self.friend_unit = self:AddHalfUnit(self.share_traitor_unit, self.friend_model)
end

function ShareTraitorUI:SendShareTraitor()
    SpecMgrs.msg_mgr:SendShareTraitor({}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.SHARE_TRAITOR_FAILED)
        else
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.SHARE_TRAITOR_SUCCESS)
            self:Hide()
        end
    end)
end

return ShareTraitorUI