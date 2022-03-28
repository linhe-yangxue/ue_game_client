local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local CSConst = require("CSCommon.CSConst")
local UIFuncs = require("UI.UIFuncs")
local RechargeUI = class("UI.RechargeUI",UIBase)

--  充值ui
function RechargeUI:DoInit()
    RechargeUI.super.DoInit(self)
    self.prefab_path = "UI/Common/RechargeUI"
end

function RechargeUI:OnGoLoadedOk(res_go)
    RechargeUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function RechargeUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    RechargeUI.super.Show(self)
end

function RechargeUI:InitRes()
    self:InitTopBar()
    self.recharge_tip_text = self.main_panel:FindChild("RechargeTipText"):GetComponent("Text")
    self.unit_point = self.main_panel:FindChild("UnitPoint")
    self.right_vip_image = self.main_panel:FindChild("RightVipImage")
    self.vip_turn_btn = self.main_panel:FindChild("VipTurnBtn")
    self:AddClick(self.vip_turn_btn, function()
        SpecMgrs.ui_mgr:ShowUI("VipUI")
    end)
    self.left_vip_image = self.main_panel:FindChild("LeftVipImage")
    self.vip_exp_tip_text = self.main_panel:FindChild("VipExpTip"):GetComponent("Text")
    self.vip_slider = self.main_panel:FindChild("VipSlider/VipSlider"):GetComponent("Image")
    self.vip_exp_text = self.main_panel:FindChild("VipExpText"):GetComponent("Text")
    self.content = self.main_panel:FindChild("ScrollView/ViewPort/Content")
    self.recharge = self.main_panel:FindChild("ScrollView/ViewPort/Content/Recharge")
    self.first_recharge_text = self.main_panel:FindChild("ScrollView/ViewPort/Content/Recharge/FirstRecharge/FirstRechargeText"):GetComponent("Text")

    self.recharge:SetActive(false)
end

function RechargeUI:InitUI()
    self:DestroyAllUnit()
    self:DelObjDict(self.create_obj_list)
    self.create_obj_list = {}
    self.item_obj_list_dict = {}
    self:SetTextVal()
    self:UpdateData()
    self:UpdateUIInfo()
    self:AddCardUnit(self.show_unit_id, self.unit_point)
    self.content:GetComponent("RectTransform").anchoredPosition = Vector3.zero
end

function RechargeUI:UpdateData()
    self.recharge_list = SpecMgrs.data_mgr:GetAllRechargeData()
    self.first_recharge_state = ComMgrs.dy_data_mgr.recharge_data.first_recharge_state
    self.show_unit_id = SpecMgrs.data_mgr:GetParamData("recharge_ui_unit").unit_id
    self.recharge_diamond_effect_id = SpecMgrs.data_mgr:GetParamData("recharge_item_effect").effect_id
end

function RechargeUI:UpdateUIInfo()
    self:UpdateVipInfo()
    for i, recharge_data in ipairs(self.recharge_list) do
        local item = self:GetUIObject(self.recharge, self.content)
        table.insert(self.create_obj_list, item)
        self:SetItemMes(item, recharge_data)
    end
end

function RechargeUI:UpdateVipInfo()
    local cur_vip_level = ComMgrs.dy_data_mgr.vip_data:GetVipLevel()
    local next_vip_level = cur_vip_level + 1
    local max_vip_level = SpecMgrs.data_mgr:GetVipData("max_vip_level")
    --next_vip_level = math.clamp(next_vip_level, 0, max_vip_level)
    local next_vip_data = SpecMgrs.data_mgr:GetVipData(next_vip_level)
    local cur_total_exp = ComMgrs.dy_data_mgr.vip_data:GetVipExp()
    local next_vip_total_exp = next_vip_data and next_vip_data.total_exp

    self.vip_slider.fillAmount = next_vip_total_exp and cur_total_exp / next_vip_total_exp or 1
    self.vip_exp_text.text = next_vip_total_exp and string.format(UIConst.Text.VIP_EXP_SLIDER_FORMAT, cur_total_exp, next_vip_total_exp) or UIConst.Text.MAX_TEXT

    local need_exp = next_vip_total_exp and next_vip_total_exp - cur_total_exp
    self.vip_exp_tip_text.text = need_exp and string.format(UIConst.Text.VIP_EXP_TIP_FORMAT, need_exp, next_vip_level)

    local vip_exp_ratio = SpecMgrs.data_mgr:GetParamData("vip_exp_ratio").f_value
    self.recharge_tip_text.text = string.format(UIConst.Text.VIP_TIP_TEXT, vip_exp_ratio)

    UIFuncs.SetVipImage(self.left_vip_image, cur_vip_level)

    if max_vip_level == cur_vip_level then
        self.vip_exp_tip_text.gameObject:SetActive(false)
        self.right_vip_image:SetActive(false)
    else
        self.vip_exp_tip_text.gameObject:SetActive(true)
        self.right_vip_image:SetActive(true)
        UIFuncs.SetVipImage(self.right_vip_image, next_vip_level)
    end
end

function RechargeUI:SetItemMes(item, data)
    item:FindChild("RechargeBtn/RechargeBtnText"):GetComponent("Text").text = string.format(UIConst.Text.MONEY_FORMAT, data.recharge_count)
    self:AddClick(item:FindChild("RechargeBtn"), function()
        self:SendRecharge(item, data)
    end)
    local item_list_parent = item:FindChild("ItemList")
    local diamond_text = item:FindChild("DiamondText")
    local recharge_tip = item:FindChild("RechargeTipText")
    local recharge_tip_text = recharge_tip:GetComponent("Text")
    recharge_tip:SetActive(data.gold_count > 0)
    local first_recharge = item:FindChild("FirstRecharge")

    local item_list = {}
    if self.first_recharge_state[data.recharge_id] then
        local diamond = {item_id = CSConst.Virtual.Diamond, count = data.first_diamond_count}
        local gift = {item_id = data.first_gift, count = 1}
        table.insert(item_list, gift)
        table.insert(item_list, diamond)
        self:SetTextPic(diamond_text, string.format(UIConst.Text.DIAMOND_FORMAT, data.first_diamond_count))
        recharge_tip_text.text = string.format(UIConst.Text.FIRST_RECHARGE_ADDITIONAL_REWARD_FORMAT, data.gold_count)
        first_recharge:SetActive(true)
    else
        local diamond = {item_id = CSConst.Virtual.Diamond, count = data.diamond_count}
        table.insert(item_list, diamond)
        self:SetTextPic(diamond_text, string.format(UIConst.Text.DIAMOND_FORMAT, data.diamond_count))
        recharge_tip_text.text = string.format(UIConst.Text.RECHARGE_ADDITIONAL_REWARD_FORMAT, data.gold_count)
        first_recharge:SetActive(false)
    end
    local ret = UIFuncs.SetItemList(self, item_list, item_list_parent, true)
    table.mergeList(self.create_obj_list, ret)
    self.item_obj_list_dict[item] = ret
    local param_tb = {
        effect_id = self.recharge_diamond_effect_id,
        offset_tb = {0, 0, 0, 0},
    }
    self:AddUIEffect(ret[1], param_tb)
end

function RechargeUI:SendCreateOrder(item, data)
    local cb = function(resp)
        print("create order callback", resp)
        print("create order errcode", resp.errcode)
        print("itemId" , data.recharge_id)
        if resp.errcode == 0 then        
            print("create order call_back_url", resp.call_back_url)
            print("create order order_id", resp.order_id)
            SpecMgrs.sdk_mgr:JGGPay({
                call_back_url = resp.call_back_url,
                itemId = data.recharge_id,
                itemName = data.ch_key,
                desc = data.ch_key,
                unitPrice = data.recharge_count,
                quantity = 1,
                type = 1,
            })    
        end    
    end
    SpecMgrs.msg_mgr:SendCreateOrder({recharge_id = data.recharge_id}, cb)
end

function RechargeUI:SendRecharge(item, data)
    print("SendRecharge item", item)
    print("SendRecharge data", data)
    self.need_reset_item = self.first_recharge_state[data.recharge_id]
    self.item = item;
    self.data = data;
    -- local cb = function(resp)
    --     if not self.is_res_ok then return end
    --     self:UpdateData()
    --     self:UpdateVipInfo()
    --     if need_reset_item then
    --         for i, obj in ipairs(self.item_obj_list_dict[item]) do
    --             self:RemoveUIEffect(obj)
    --         end
    --         self:DelObjDict(self.item_obj_list_dict[item])
    --         self.item_obj_list_dict[item] = {}
    --         self:SetItemMes(item, data)
    --     end
    -- end
    -- SpecMgrs.msg_mgr:SendRecharge({recharge_id = data.recharge_id}, cb)

    -- jggPay
    self:SendCreateOrder(item, data);
end

function RechargeUI:RechargeSuccess()
    -- if not self.is_res_ok then return end
    print("RechargeSuccess>>>>>>>>>>>>>>>>>>>>>", self.item)
    print("RechargeSuccess>>>>>>>>>>>>>>>>>>>>>", self.data)
    print("RechargeSuccess>>>>>>>>>>>>>>>>>>>>>", self.need_reset_item)
    
    self:UpdateData()
    self:UpdateVipInfo()
    if self.need_reset_item then
        for i, obj in ipairs(self.item_obj_list_dict[self.item]) do
            self:RemoveUIEffect(obj)
        end
        self:DelObjDict(self.item_obj_list_dict[self.item])
        self.item_obj_list_dict[self.item] = {}
        self:SetItemMes(self.item, self.data)
    end
end

function RechargeUI:SetTextVal()
    self.recharge:FindChild("FirstRecharge/FirstRechargeText"):GetComponent("Text").text = UIConst.Text.FIRST_RECHARGE
end

function RechargeUI:Hide()
    self:RemoveAllUIEffect()
    self:DelObjDict(self.create_obj_list)
    RechargeUI.super.Hide(self)
end

return RechargeUI
