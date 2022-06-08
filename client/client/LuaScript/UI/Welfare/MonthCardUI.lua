local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local CSConst = require("CSCommon.CSConst")
local MonthCardUI = class("UI.Welfare.MonthCardUI")

--  月卡
function MonthCardUI:InitRes(owner)
    self.owner = owner
    self.month_card = self.owner.main_panel:FindChild("MonthCardFrame/MonthCard")
    self.forever_card = self.owner.main_panel:FindChild("MonthCardFrame/ForeverCard")
    self:SetTextVal()
end

function MonthCardUI:Show()
    self:ClearRes()
    ComMgrs.dy_data_mgr.month_card_data:RegisterUpdateMonthCardInfo("MonthCardUI", function()
        self:UpdateData()
        self:UpdateCardMes(self.month_card, self.month_card_info)
    end)
    ComMgrs.dy_data_mgr.month_card_data:RegisterUpdateForeverCardInfo("MonthCardUI", function()
        self:UpdateData()
        self:UpdateCardMes(self.forever_card, self.forever_card_info)
    end)
    self:UpdateData()
    self:UpdateUIInfo()
end

function MonthCardUI:SetTextVal()

end

function MonthCardUI:UpdateData()
    self.month_card_data = ComMgrs.dy_data_mgr.month_card_data:GetMonthCardData()
    self.forever_card_data = ComMgrs.dy_data_mgr.month_card_data:GetForeverCardData()

    self.month_card_info = ComMgrs.dy_data_mgr.month_card_data:GetMonthCardInfo()
    self.forever_card_info = ComMgrs.dy_data_mgr.month_card_data:GetForeverCardInfo()
end

function MonthCardUI:UpdateUIInfo()
    self:SetCardMes(self.month_card, self.month_card_data)
    self:SetCardMes(self.forever_card, self.forever_card_data)
    self:UpdateCardMes(self.month_card, self.month_card_info)
    self:UpdateCardMes(self.forever_card, self.forever_card_info)
end

function MonthCardUI:SetCardMes(item, data)
    item:FindChild("RightNowText"):GetComponent("Text").text = UIConst.Text.RUGHT_NOW_GET_TEXT
    item:FindChild("NameText"):GetComponent("Text").text = data.name
    item:FindChild("DescText"):GetComponent("Text").text = data.desc
    item:FindChild("VipExpText"):GetComponent("Text").text = string.format(UIConst.Text.ADD_VIP_EXP_FORMAT, data.add_vip_exp)
    item:FindChild("BuyBtn/Text"):GetComponent("Text").text = string.format(UIConst.Text.MONEY_FORMAT, data.price)
    item:FindChild("RightNowGetDiamondNum"):GetComponent("Text").text = data.add_item_num
    item:FindChild("LastDayGetDiamondNum"):GetComponent("Text").text = data.daily_item_num

    UIFuncs.AssignSpriteByItemID(data.item_id, item:FindChild("UpDiamondImage"):GetComponent("Image"))
    UIFuncs.AssignSpriteByItemID(data.item_id, item:FindChild("DownDiamondImage"):GetComponent("Image"))

    if data.validity_period_day then
        item:FindChild("LastDayText"):GetComponent("Text").text = string.format(UIConst.Text.LAST_DAY_FORMAT, data.validity_period_day)
    else
        item:FindChild("LastDayText"):GetComponent("Text").text = UIConst.Text.FORVER_GET_TEXT
    end

    self.owner:AddClick(item:FindChild("BuyBtn"), function()
        --  todo 充值
        -- local cb = function()
        --     local item_list = {{item_id = CSConst.Virtual.VIPExp, count = data.add_vip_exp}, {item_id = data.item_id, count = data.add_item_num}}
        --     UIFuncs.ShowGetRewardItemByItemList(item_list)
        -- end
        -- SpecMgrs.msg_mgr:SendMsg("SendBuyMonthlyCard", {card_id = data.id}, cb)

        self.data = data;
        --jgg pay
        local cb = function(resp)
            print("create order callback", resp)
            print("create order errcode", resp.errcode)
            print("itemId" , data.id)
            if resp.errcode == 0 then        
                print("create order call_back_url", resp.call_back_url)
                print("create order order_id", resp.order_id)
                SpecMgrs.sdk_mgr:JGGPay({
                    call_back_url = resp.call_back_url,
                    itemId = data.id,
                    itemName = data.name,
                    desc = data.desc,
                    unitPrice = data.price,
                    quantity = 1,
                    type = 2,
                })    
            end    
        end
        SpecMgrs.msg_mgr:SendMsg("SendCreateMonthlyCardOrder", {card_id = data.id}, cb)
    end)
    self.owner:AddClick(item:FindChild("ReceiveBtn"), function()
        SpecMgrs.msg_mgr:SendMsg("SendReceivingMonthlyCardReward", {card_id = data.id})
    end)
end

function MonthCardUI:RechargeSuccess()
    local item_list = {{item_id = CSConst.Virtual.VIPExp, count = self.data.add_vip_exp}, {item_id = self.data.item_id, count = self.data.add_item_num}}
    UIFuncs.ShowGetRewardItemByItemList(item_list)
end

function MonthCardUI:UpdateCardMes(item, info)
    local buy_btn = item:FindChild("BuyBtn")
    local remain_day = item:FindChild("RemainDay")
    if not next(info) then
        UIFuncs.HideItemRecive(item)
        buy_btn:SetActive(true)
        remain_day:SetActive(false)
    else
        UIFuncs.SetItemCanRecive(self.owner, item, info.is_received)
        buy_btn:SetActive(false)
        remain_day:SetActive(info.remaining_days ~= nil)
        if info.remaining_days then
            remain_day:FindChild("RemainDayText"):GetComponent("Text").text = string.format(UIConst.Text.REMAIN_DAY_FORMAT, info.remaining_days)
        end
    end
end

function MonthCardUI:ClearRes()
    self.owner:RemoveUIEffect(self.month_card:FindChild("ReceiveBtn"))
    self.owner:RemoveUIEffect(self.forever_card:FindChild("ReceiveBtn"))
    ComMgrs.dy_data_mgr.month_card_data:UnregisterUpdateMonthCardInfo("MonthCardUI")
    ComMgrs.dy_data_mgr.month_card_data:UnregisterUpdateForeverCardInfo("MonthCardUI")
    self.owner:DelObjDict(self.create_obj_list)
end

function MonthCardUI:Hide()
    self:ClearRes()
end

return MonthCardUI
