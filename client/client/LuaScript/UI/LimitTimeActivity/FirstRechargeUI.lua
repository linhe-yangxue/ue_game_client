local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local ItemUtil = require("BaseUtilities.ItemUtil")
local FirstRechargeUI = class("UI.LimitTimeActivity.FirstRechargeUI")

--  首冲
function FirstRechargeUI:InitRes(owner)
    self.owner = owner
    self.first_recharge_frame = self.owner.main_panel:FindChild("FirstRechargeFrame")
    self.recharge_btn = self.owner.main_panel:FindChild("FirstRechargeFrame/RechargeBtn")
    self.owner:AddClick(self.recharge_btn, function()
        self:ClickRechargeBtn()
    end)
    self.first_recharge_tip = self.owner.main_panel:FindChild("FirstRechargeFrame/FirstRechargeTip"):GetComponent("Text")
    self.content = self.owner.main_panel:FindChild("FirstRechargeFrame/ScrollRect/ViewPort/Content")
    self.give_diamond_text = self.owner.main_panel:FindChild("FirstRechargeFrame/GiveDiamondText"):GetComponent("Text")
    self:SetTextVal()
end

function FirstRechargeUI:Show()
    self.owner:DelObjDict(self.create_obj_list)
    self.create_obj_list = {}
    self.owner:RemoveUIEffect(self.recharge_btn)
    self.first_recharge_frame:SetActive(true)
    self:UpdateData()
    self:UpdateUIInfo()
    ComMgrs.dy_data_mgr.recharge_data:RegisterUpdateFirstRechargeEvent("FirstRechargeUI", function()
        self.owner:DelObjDict(self.create_obj_list)
        self.create_obj_list = {}
        self.owner:RemoveUIEffect(self.recharge_btn)
        self:UpdateData()
        self:UpdateUIInfo()
    end, self)
end

function FirstRechargeUI:SetTextVal()
    local num = SpecMgrs.data_mgr:GetParamData("first_recharge_give").f_value
    self.give_diamond_text.text = string.format(UIConst.Text.FIRST_RECHARGE_GIVE_TIP, num)

    self.first_recharge_tip.text = UIConst.Text.FIRST_RECHARGE_GIVE_DIAMOND_TIP
end

function FirstRechargeUI:UpdateData()
    self.is_first_recharge = ComMgrs.dy_data_mgr.recharge_data.is_first_recharge
    self.first_recharge_reward_data = SpecMgrs.data_mgr:GetParamData("first_rechage_reward")
    self.first_rechage_show_effect_id_list = SpecMgrs.data_mgr:GetParamData("first_rechage_show_effect_id").item_list

    self.reward_item_list = {}
    for i, v in ipairs(self.first_recharge_reward_data.item_list) do
        table.insert(self.reward_item_list, {item_id = v, count = self.first_recharge_reward_data.count_list[i]})
    end
end

function FirstRechargeUI:UpdateUIInfo()
    self.reward_item_list = ItemUtil.SortRoleItemList(self.reward_item_list)
    for i = #self.reward_item_list, 1, -1 do
        local data = self.reward_item_list[i]
        local item = UIFuncs.SetItem(self.owner, data.item_id, data.count, self.content)
        if table.index(self.first_rechage_show_effect_id_list, data.item_id) then
            UIFuncs.AddGlodCircleEffect(self.owner, item)
        end
        table.insert(self.create_obj_list, item)
    end
    self.recharge_btn:FindChild("GrayImage"):SetActive(false)
    if self.is_first_recharge == nil then
        self.recharge_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.RECEIVE_TEXT
        self.recharge_btn:FindChild("GrayImage"):SetActive(true)
    else
        if self.is_first_recharge then
            self.recharge_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.RECEIVE_TEXT
             UIFuncs.AddCompleteEffect(self.owner, self.recharge_btn)
        else
            self.recharge_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.IMMEDIATELY_RECHARGE_TEXT
        end
    end
end

function FirstRechargeUI:ClickRechargeBtn()
    if self.is_first_recharge then
        local cb = function(resp)
            ComMgrs.dy_data_mgr.recharge_data:UpdateFirstRechargeInfo()
            UIFuncs.ShowGetRewardItemByItemList(self.reward_item_list)
            if not self.owner.is_res_ok then return end
            self.recharge_btn:FindChild("GrayImage"):SetActive(true)
            self.recharge_btn:GetComponent("Button").interactable = false
        end
        SpecMgrs.msg_mgr:SendReciveFirstRechargeReward(nil, cb)
    else
        SpecMgrs.ui_mgr:ShowUI("RechargeUI")
    end
end

function FirstRechargeUI:Hide()
    if self.create_obj_list then
        for i,v in ipairs(self.create_obj_list) do
            self.owner:RemoveUIEffect(v)
        end
    end
    self.owner:DelObjDict(self.create_obj_list)
    self.owner:RemoveUIEffect(self.recharge_btn)
    ComMgrs.dy_data_mgr.recharge_data:UnregisterUpdateFirstRechargeEvent("FirstRechargeUI")
    self.first_recharge_frame:SetActive(false)
end

return FirstRechargeUI
