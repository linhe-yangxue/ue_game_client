local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local LoverGiftUI = class("UI.LoverGiftUI", UIBase)

local lover_data_dict = {
    ["Lover"] = "ExGeLoverGiftBuy",
}
function LoverGiftUI:DoInit()
    LoverGiftUI.super.DoInit(self)
    self.dy_vip_data = ComMgrs.dy_data_mgr.vip_data
    self.prefab_path = "UI/Common/LoverGiftUI"
    self.lover_gift_list = {}
    self.lover_gift_buy_list = {}
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
        if remian_time > 0  then
            self.refresh_text.text = UIFuncs.TimeDelta2Str(remian_time ,4, UIConst.Text.LOVER_GIFT)
            self.lover_gift_buy_list[self.index] = false
        else
            self.lover_gift_buy_list[self.index] = true
            self.refresh_text.text = UIConst.Text.ALREADY_FINISH_TEXT
        end
    end
end

function LoverGiftUI:InitRes()
    self.content = self.main_panel:FindChild("Content")
    self.title = self.content:FindChild("Title"):GetComponent("Text")
    self:AddClick(self.content:FindChild("CloseBtn"), function ()
        self:Hide()
    end)
    self.BuyBtn = self.content:FindChild("BuyBtn")
    self.buyText = self.content:FindChild("BuyBtn/Image/Text"):GetComponent("Text")
    self.buyTip = self.content:FindChild("BuyTip"):GetComponent("Text")

    --添加美女
    self.unit_rect = self.content:FindChild("UnitRect")
    self.cur_frame_obj_list = {}

    self.left_btn = self.content:FindChild("ButtonLeft")
    self:AddClick(self.left_btn, function ()
        self:LeftButton()
    end)

    self.right_btn = self.content:FindChild("ButtonRight")
    self:AddClick(self.right_btn, function ()
        self:RightButton()
    end)

    self.check_item_list = self.content:FindChild("ItemCheckList/ViewPort/CheckItemList")
    self.reward_item = self.content:FindChild("ItemCheckList/ViewPort/CheckItemList/RewardItem")

    self.refresh_text = self.content:FindChild("RefreshObj/RefreshText"):GetComponent("Text")

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
            self.cur_frame_obj_list = UIFuncs.SetItemList(self, item_list, self.check_item_list)
            --限购次数（当前/总数）
            local cur_purchase_count = lover_info.purchase_have
            local purchase_count = lover_info.purchase_count
            self.buyTip.text = UIConst.Text.LIMIT_BUY .. cur_purchase_count .. "/" .. purchase_count
            --礼包价格
            local lover_gift_buy = self:GetUIObject(self.BuyBtn, self.content)
            lover_gift_buy:GetComponent("RectTransform").anchoredPosition = Vector2.New(-15, 120)
            self.lover_gift_list[i] = lover_gift_buy
            local buyText = lover_gift_buy:FindChild("Image/Text"):GetComponent("Text")
            if cur_purchase_count < purchase_count then
                local price = lover_info.price
                buyText.text = price .. "JG"
            else
                buyText.text = "已购买"
            end
            --购买Button
            self:AddClick(lover_gift_buy, function ()
                if cur_purchase_count < purchase_count and self.lover_gift_buy_list[self.index] == false then
                    --self:SendCreateLoverOrder(self.activity_list[self.index])
                    SpecMgrs.msg_mgr:SendLoverPurchase({package_id = lover_info.id}, function (resp)
                        if resp.errcode == 0 then
                            self:UpdateLover(index,ComMgrs.dy_data_mgr[lover_data_dict["Lover"]](ComMgrs.dy_data_mgr))
                        end
                    end)
                elseif cur_purchase_count == purchase_count and self.lover_gift_buy_list[self.index] == false then
                    SpecMgrs.ui_mgr:ShowMsgBox("本次活动已购买完毕，请等时间刷新！")
                else
                    SpecMgrs.ui_mgr:ShowMsgBox("活动已结束，请重新进入！")
                end
            end)

            --礼包名字
            local activity_name = lover_info.activity_name
            self.title.text = activity_name
        end
    end
end

--function LoverGiftUI:SendCreateLoverOrder(data)
--    local cb = function(resp)
--        print("create order callback", resp)
--        if resp.errcode == 0 then
--            SpecMgrs.sdk_mgr:JGGPay({
--                call_back_url = resp.call_back_url,
--                itemId = data.lover_id,
--                itemName = data.activity_name,
--                desc = data.activity_name,
--                unitPrice = data.price,
--                quantity = 1,
--                type = 3,
--            })
--        end
--    end
--    SpecMgrs.msg_mgr:SendCreateOrder({package_id = data.lover_id}, cb)
--end
--
--function LoverGiftUI:RechargeSuccess()
--    print("RechargeSuccess>>>>>>>>>>>>>>>>>>>>>", self.data)
--end

function LoverGiftUI:UpdateLover(index,msg)
    self.activity_list[index].purchase_have = msg.times
    self:ClearInfo()
    self:UpdateMiddle(index)
    self:UpdateLoverInfo(index)
end

function LoverGiftUI:InitUI()
    self:InitTaskInfo()
    if self.activity_list_length ~= nil then
        self:UpdateLoverInfo(1)
    end
end

function LoverGiftUI:LeftButton()
    self.index = self.index - 1
    self:ClearInfo()
    self:UpdateMiddle(self.index)
    self:UpdateLoverInfo(self.index)
end

function LoverGiftUI:RightButton()
    self.index = self.index + 1
    self:ClearInfo()
    self:UpdateMiddle(self.index)
    self:UpdateLoverInfo(self.index)
end

function LoverGiftUI:UpdateMiddle(index)
    self:ClearUnit("unit")
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
    for _, go in pairs(self.lover_gift_list) do
        self:DelUIObject(go)
    end
    self.lover_gift_list = {}
end

function LoverGiftUI:ClearRes()
    self:ClearInfo()
    self:ClearUnit("unit")
    self.index = 1
end

return LoverGiftUI