local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local LoverGiftUI = class("UI.LoverGiftUI", UIBase)

function LoverGiftUI:DoInit()
    LoverGiftUI.super.DoInit(self)
    self.dy_vip_data = ComMgrs.dy_data_mgr.vip_data
    self.prefab_path = "UI/Common/LoverGiftUI"
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
    self.date = param_tb
    self.activity_list = self.date.activity_list
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
            print("情人礼包道具信息----",item_list)
            self.cur_frame_obj_list = UIFuncs.SetItemList(self, item_list, self.check_item_list)
            --礼包价格
            local price = lover_info.price
            self.buyText.text = price .. "JG"
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
            end)

        end
    end
end

function LoverGiftUI:InitUI()
    self:InitTaskInfo()
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

function LoverGiftUI:InitTaskInfo()

    self.left_btn:SetActive(false)
    self.right_btn:SetActive(false)

    self.index = 1
    self:UpdateMiddle(1)
end

function LoverGiftUI:ClearInfo()
    self:DelObjDict(self.cur_frame_obj_list)
end

function LoverGiftUI:ClearRes()
    self:ClearInfo()
    self:ClearUnit("unit")
    self.index = 1
end

return LoverGiftUI