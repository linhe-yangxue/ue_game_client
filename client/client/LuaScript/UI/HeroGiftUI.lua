local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local HeroGiftUI = class("UI.HeroGiftUI", UIBase)

function HeroGiftUI:DoInit()
    HeroGiftUI.super.DoInit(self)
    self.dy_vip_data = ComMgrs.dy_data_mgr.vip_data
    self.prefab_path = "UI/Common/HeroGiftUI"
    self.index = 1
end

function HeroGiftUI:OnGoLoadedOk(res_go)
    HeroGiftUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function HeroGiftUI:Hide()
    HeroGiftUI.super.Hide(self)
    self:ClearRes()
end

function HeroGiftUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    HeroGiftUI.super.Show(self)
end

function HeroGiftUI:Update(delta_time)
    self:UpdateRefreshTime()
end

function HeroGiftUI:UpdateRefreshTime()
    local next_refresh_time = self.dy_vip_data:GetVipShopRefreshTime()
    local remian_time = next_refresh_time - Time:GetServerTime()
    self.refresh_text.text = UIFuncs.TimeDelta2Str(remian_time, 4, UIConst.Text.VIP_SHOP_REFRESH_TIME)
end

function HeroGiftUI:InitRes()
    local content = self.main_panel:FindChild("Content")
    self.title = content:FindChild("Title"):GetComponent("Text")
    self:AddClick(content:FindChild("CloseBtn"), function ()
        self:Hide()
    end)
    self.buyText = content:FindChild("BuyBtn/Image/Text"):GetComponent("Text")
    self.buyTip = content:FindChild("BuyTip"):GetComponent("Text")

    --添加美女
    self.unit_rect = content:FindChild("UnitRect")
    self.check_item_list = content:FindChild("ItemCheckList/ViewPort/CheckItemList")
    self.reward_item = content:FindChild("ItemCheckList/ViewPort/CheckItemList/RewardItem")
    self.cur_frame_obj_list = {}
    self:UpdateData()
    self:InitLoverItem()

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

function HeroGiftUI:InitUI()
    self:InitTaskInfo()
end

function HeroGiftUI:LeftButton()
    self.index = self.index - 1
    print("当前页面数量111--",self.index)
    self:UpdateMiddle(self.index)
    print("点击left按钮")
end

function HeroGiftUI:RightButton()
    self.index = self.index + 1
    print("当前页面数量222--",self.index)
    self:UpdateMiddle(self.index)
    print("点击right按钮")
end

function HeroGiftUI:UpdateMiddle(index)
    self:ClearUnit("unit")
    local lover_unit_id
    if index == 1 then
        self.left_btn:SetActive(false)
        self.right_btn:SetActive(true)
        self.buyText.text = "US$9.99"
        lover_unit_id = 13031
        self.unit = self:AddFullUnit(lover_unit_id, self.unit_rect)
    elseif index == 2 then
        self.left_btn:SetActive(true)
        self.right_btn:SetActive(true)
        self.buyText.text = "US$19.99"
        lover_unit_id = 14032
        self.unit = self:AddFullUnit(lover_unit_id, self.unit_rect)
    elseif index == 3 then
        self.left_btn:SetActive(true)
        self.right_btn:SetActive(true)
        self.buyText.text = "US$49.99"
        lover_unit_id = 13012
        self.unit = self:AddFullUnit(lover_unit_id, self.unit_rect)
    elseif index == 4 then
        self.left_btn:SetActive(true)
        self.right_btn:SetActive(false)
        self.buyText.text = "US$99.99"
        lover_unit_id = 11051
        self.unit = self:AddFullUnit(lover_unit_id, self.unit_rect)
    end
end

function HeroGiftUI:UpdateData()
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

function HeroGiftUI:InitLoverItem()
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

function HeroGiftUI:InitTaskInfo()
    self.left_btn:SetActive(false)
    self.right_btn:SetActive(true)
    print("当前页面信息222---",self.index)
    local lover_unit_id = 13031
    self.unit = self:AddFullUnit(lover_unit_id, self.unit_rect)
    self.buyText.text = "US$9.99"
    self.buyTip.text = "限购：1/1"
    self.title.text = "英雄礼包"      --self.group_data.desc
end

function HeroGiftUI:ClearRes()
    self.index = 1

end


return HeroGiftUI