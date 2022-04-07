local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local LoverGiftUI = class("UI.LoverGiftUI", UIBase)

function LoverGiftUI:DoInit()
    LoverGiftUI.super.DoInit(self)
    self.dy_vip_data = ComMgrs.dy_data_mgr.vip_data
    self.prefab_path = "UI/Common/LoverGiftUI"

    self.lover_unit_dict = {}
end

function LoverGiftUI:OnGoLoadedOk(res_go)
    LoverGiftUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function LoverGiftUI:Hide()
    LoverGiftUI.super.Hide(self)
    self:ClearRes()
end

function LoverGiftUI:Show(param_tb)
    self.data = param_tb
    self.activity_list = self.data.activity_list
    self.activity_list_length = #self.activity_list
    if self.is_res_ok then
        self:InitUI()
    end
    LoverGiftUI.super.Show(self)
end

function LoverGiftUI:Update(delta_time)
    self:UpdateRefreshTime()
end

function LoverGiftUI:UpdateRefreshTime()
    for i = 1, self.activity_list_length do
        local lover_info = self.activity_list[self.index]
        local next_refresh_time = lover_info.end_ts
        local remian_time = next_refresh_time - Time:GetServerTime()
        self.refresh_text.text = UIFuncs.TimeDelta2Str(remian_time, 4, UIConst.Text.VIP_SHOP_REFRESH_TIME)
    end
end

function LoverGiftUI:InitRes()
    local content = self.main_panel:FindChild("Content")
    self.title = content:FindChild("Title"):GetComponent("Text")
    self:AddClick(content:FindChild("CloseBtn"), function ()
        self:Hide()
    end)
    self.BuyBtn = content:FindChild("BuyBtn")
    self.buyText = content:FindChild("BuyBtn/Image/Text"):GetComponent("Text")
    self.buyTip = content:FindChild("BuyTip"):GetComponent("Text")

    --添加美女
    self.unit_rect = content:FindChild("UnitRect")
    self.check_item_list = content:FindChild("ItemCheckList/ViewPort/CheckItemList")
    self.reward_item = content:FindChild("ItemCheckList/ViewPort/CheckItemList/RewardItem")
    self.cur_frame_obj_list = {}

    self.left_btn = content:FindChild("ButtonLeft")
    self:AddClick(self.left_btn, function ()
        self:LeftButton()
    end)

    self.right_btn = content:FindChild("ButtonRight")
    self:AddClick(self.right_btn, function ()
        self:RightButton()
    end)



    self.check_item_list = content:FindChild("ItemCheckList/ViewPort/CheckItemList")
    self.reward_item = content:FindChild("ItemCheckList/ViewPort/CheckItemList/RewardItem")
    print("当前页面信息111---",self.index)

    self.refresh_text = content:FindChild("RefreshObj/RefreshText"):GetComponent("Text")

end

function LoverGiftUI:UpdateLoverInfo(index)

    for i = 1, self.activity_list_length do
        if index == i then
            local lover_info = self.activity_list[i]
            --情人Model
            local lover_unit_id = lover_info.lover_id
            self.unit = self:AddFullUnit(lover_unit_id, self.unit_rect)
            --获得道具
            local item_list = lover_info.item_list
            self:InitLoverItemNew(item_list)
            --礼包价格
            local price = lover_info.price
            self.buyText.text = "US$" .. price
            --限购次数（当前/总数）
            --local cur_purchase_count = lover_info.cur_purchase_count
            local purchase_count = lover_info.purchase_count
            self.buyTip.text = UIConst.Text.LIMIT_BUY .. purchase_count .. "/" .. purchase_count
            --礼包名字
            local activity_name = lover_info.activity_name
            self.title.text = activity_name
            --购买Button
            self:AddClick(self.BuyBtn, function ()
                print("情人礼包购买")
                print(self.index)
                print(self.activity_list[self.index])
                self:SendCreateLoverOrder(self.activity_list[self.index])
            end)

        end
    end
end

function LoverGiftUI:SendCreateLoverOrder(data)
    local cb = function(resp)
        print("create order callback", resp)
        if resp.errcode == 0 then        
            SpecMgrs.sdk_mgr:JGGPay({
                call_back_url = resp.call_back_url,
                itemId = data.lover_id,
                itemName = data.activity_name,
                desc = data.activity_name,
                unitPrice = data.price,
                quantity = 1,
                type = 3,
            })    
        end    
    end
    SpecMgrs.msg_mgr:SendCreateOrder({package_id = data.lover_id}, cb)
end

function LoverGiftUI:RechargeSuccess()
    print("RechargeSuccess>>>>>>>>>>>>>>>>>>>>>", self.data)
end

function LoverGiftUI:InitLoverItemNew(item_list)
    print("LoverGiftUI:InitLoverItemNew(item_list)-------------",item_list)
    for i in ipairs(item_list) do
        local item = self:GetUIObject(self.reward_item, self.check_item_list)
        table.insert(self.cur_frame_obj_list, item)
        print("道具信息---",item_list[i].item_id,item_list[i].count)
        UIFuncs.AssignItem(item, item_list[i].item_id, item_list[i].count)
    end
end

function LoverGiftUI:InitUI()
    self:InitTaskInfo()
    self:UpdateData()
    --self:InitLoverItem()
    if self.activity_list_length ~= nil then
        self:UpdateLoverInfo(1)
    end
end

function LoverGiftUI:LeftButton()
    self.index = self.index - 1
    print("当前页面数量111--",self.index)
    self:ClearInfo()
    self:UpdateMiddle(self.index)
    self:UpdateLoverInfo(self.index)
    print("点击left按钮")
end

function LoverGiftUI:RightButton()
    self.index = self.index + 1
    print("当前页面数量222--",self.index)
    self:ClearInfo()
    self:UpdateMiddle(self.index)
    self:UpdateLoverInfo(self.index)
    print("点击right按钮")
end

function LoverGiftUI:UpdateMiddle(index)
    self:ClearUnit("unit")
    print("总数量长度----",self.activity_list_length)
    if self.activity_list_length == 1 then
        self.left_btn:SetActive(false)
        self.right_btn:SetActive(false)
    else
        if index == 1 then
            self.left_btn:SetActive(false)
            self.right_btn:SetActive(true)
        elseif index == self.activity_list_length then
            self.left_btn:SetActive(true)
            self.right_btn:SetActive(false)
        else
            self.left_btn:SetActive(true)
            self.right_btn:SetActive(true)
        end
    end
end

function LoverGiftUI:UpdateData()
    self.check_data = ComMgrs.dy_data_mgr.check_data
    print("情人111---",self.check_data)
    self.dy_activity_data = ComMgrs.dy_data_mgr.activity_data
    print("情人222---",self.dy_activity_data)
    self.month_check_info = self.check_data.month_check_info
    print("情人333---",self.month_check_info)
    self.month = Time:GetServerDate().month
    self.day = Time:GetServerDate().day
    self.check_month_data = SpecMgrs.data_mgr:GetCheckInMonthlyData(self.month)
    print("情人444---",self.check_month_data)
end

function LoverGiftUI:InitLoverItem()
    print("道具1111--------",self.month_check_info.check_in_date_reward)
    for i, state in ipairs(self.month_check_info.check_in_date_reward) do
        if not self.check_month_data.reward_id[i] then return end
        local item = self:GetUIObject(self.reward_item, self.check_item_list)
        table.insert(self.cur_frame_obj_list, item)
        print("道具信息---",self.check_month_data.reward_id[i],self.check_month_data.reward_count[i])
        UIFuncs.AssignItem(item, self.check_month_data.reward_id[i], self.check_month_data.reward_count[i])
--
--        local can_check_image = item:FindChild("CanCheckImage")
--        local vip = item:FindChild("Vip")
--        local have_check_image = item:FindChild("HaveCheckImage")
--        local make_up = item:FindChild("MakeUp")
--
--        if table.contains(self.check_month_data.vip_day, i) then
--            vip:SetActive(true)
--            local index = table.index(self.check_month_data.vip_day, i)
--            vip:FindChild("VipText"):GetComponent("Text").text = string.format(UIConst.Text.VIP_DOUBLE_FORMAT, self.check_month_data.vip_level_request[index])
--        else
--            vip:SetActive(false)
--        end
--
--        item:FindChild("DayText"):GetComponent("Text").text = string.format(UIConst.Text.CHECK_DAY_FORMAT, i)
--
--        can_check_image:SetActive(false)
--        have_check_image:SetActive(false)
--        make_up:SetActive(false)
--
--        if state == CSConst.RewardState.unpick then
--            self:AddClick(item, function()
--                SpecMgrs.ui_mgr:ShowItemPreviewUI(self.check_month_data.reward_id[i])
--            end)
--        elseif state == CSConst.RewardState.pick then
--            if self.day == i then
--                can_check_image:SetActive(true)
--                local gold_effect_parent = item
--                local glod_circle_effect = UIFuncs.AddGlodCircleEffect(self, item)
--                self.cur_frame_effect_dict[glod_circle_effect] = gold_effect_parent
--            else
--                make_up:SetActive(true)
--            end
--            self:AddClick(item, function()
--                self:ClickMonthCheck(item, i)
--            end)
--        elseif state == CSConst.RewardState.picked then
--            have_check_image:SetActive(true)
--            self:AddClick(item, function()
--                SpecMgrs.ui_mgr:ShowItemPreviewUI(self.check_month_data.reward_id[i])
--            end)
--        end
    end
--    local rect = self.check_item_list:GetComponent("RectTransform")
--    rect.anchoredPosition = Vector2.New(rect.anchoredPosition.x, 0)
end

function LoverGiftUI:InitTaskInfo()

    self.left_btn:SetActive(false)
    self.right_btn:SetActive(false)

    self.index = 1
    self:UpdateMiddle(1)

end

function LoverGiftUI:ClearInfo()
    for _, item in pairs(self.cur_frame_obj_list) do
        self:DelUIObject(item)
    end
    self.cur_frame_obj_list = {}
end

function LoverGiftUI:ClearRes()
    self:ClearInfo()
    self:ClearUnit("unit")
    self.index = 1

end


return LoverGiftUI