local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local CSConst = require("CSCommon.CSConst")
local OneKeyGrabUI = class("UI.OneKeyGrabUI", UIBase)

function OneKeyGrabUI:DoInit()
    OneKeyGrabUI.super.DoInit(self)
    self.prefab_path = "UI/Common/OneKeyGrabUI"
    self.item_list = {}
end

function OneKeyGrabUI:OnGoLoadedOk(res_go)
    OneKeyGrabUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function OneKeyGrabUI:Hide()
    self:ClearAllItem()
    OneKeyGrabUI.super.Hide(self)
end

function OneKeyGrabUI:Show(param_tb)
    self.param_tb = param_tb
    if self.is_res_ok then
        self:InitUI()
    end
    OneKeyGrabUI.super.Show(self)
end

function OneKeyGrabUI:InitRes()
    self.main_panel:FindChild("Panel/Top/Image/Image/Text"):GetComponent("Text").text = UIConst.Text.GRAB_DETIAL
    self.main_panel:FindChild("Panel/TotalCost/Title/Text"):GetComponent("Text").text = UIConst.Text.TOTAL_COST
    self.main_panel:FindChild("Panel/TotalGet/Title/Text"):GetComponent("Text").text = UIConst.Text.TOTAL_GET
    self.main_panel:FindChild("Panel/CloseBtn/Text"):GetComponent("Text").text = UIConst.Text.SWEEP_END
    self.main_panel:FindChild("Panel/Top/Title/Text"):GetComponent("Text").text = UIConst.Text.GRAB_TREASURE_REPORT
    local str = string.format(UIConst.Text.SWEEP_PANEL_TIP, UIConst.Text.GRAB_TREASURE_REPORT)
    self.main_panel:FindChild("Panel/Top/Image/Image/Text"):GetComponent("Text").text = str
    self.item_parent = self.main_panel:FindChild("Panel/TotalGet/Scroll View/Viewport/Content")
    self.item_temp = self.item_parent:FindChild("Item")
    UIFuncs.GetIconGo(self, self.item_temp)
    self.item_temp:SetActive(false)
    self:AddClick(self.main_panel:FindChild("Panel/CloseBtn"), function ()
        self:Hide()
    end)
    self:AddClick(self.main_panel:FindChild("BlackBg"), function ()
        self:Hide()
    end)
    self.grab_time_text = self.main_panel:FindChild("Panel/TotalCost/GrabTime"):GetComponent("Text")
    self.use_item = self.main_panel:FindChild("Panel/TotalCost/UseItem")
    self.money_item = self.main_panel:FindChild("Panel/TotalGet/Money")
    self.exp_item = self.main_panel:FindChild("Panel/TotalGet/Exp")
end

function OneKeyGrabUI:InitUI()
    local param_tb = self.param_tb
    self:ClearAllItem()
    self.grab_time_text.text = string.format(UIConst.Text.GRAB_TIME, param_tb.grab_count)

    local item_id = SpecMgrs.data_mgr:GetParamData("vitality_item_id").item_id
    local tb = {go = self.use_item, item_id = item_id, count = param_tb.cost_item_count}
    UIFuncs.InitGetItemGo(tb)

    item_id = CSConst.Virtual.Money
    tb = {go = self.money_item, item_id = item_id, count = param_tb.reward_dict[item_id]}
    UIFuncs.InitGetItemGo(tb)

    item_id = CSConst.Virtual.Exp
    tb = {go = self.exp_item, item_id = item_id, count = param_tb.reward_dict[item_id]}
    UIFuncs.InitGetItemGo(tb)
    for item_id, count in pairs(param_tb.random_reward) do
        local go = self:GetUIObject(self.item_temp, self.item_parent)
        table.insert(self.item_list, go)
        local tb = {go = go:FindChild("Item"), item_id = item_id, count = count, ui = self}
        UIFuncs.InitItemGo(tb)
    end
end

function OneKeyGrabUI:ChangeGrabRoleListBtnOnClick()
    if self.change_grab_list_timer then return end
    SpecMgrs.msg_mgr:SendGetGrabRoleList({treasure_id = self.treasure_id, fragment_id = fragment_id},function (resp)
        if resp.errcode ~= 0 then
            PrintError("Get wrong errcode in SendGetGrabRoleList", treasure_id, fragment_id)
            return
        end
        self.role_list = msg.role_list
        self:_UpdateGrabPlayer()
    end)
end

function OneKeyGrabUI:ClearAllItem()
    for _, go in ipairs(self.item_list) do
        self:DelUIObject(go)
    end
    self.item_list = {}
end


return OneKeyGrabUI