local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local HeroGiftUI = class("UI.HeroGiftUI", UIBase)

local hero_data_dict = {
    ["Hero"] = "ExGeHeroGiftBuy",
}

function HeroGiftUI:DoInit()
    HeroGiftUI.super.DoInit(self)
    self.dy_vip_data = ComMgrs.dy_data_mgr.vip_data
    self.prefab_path = "UI/Common/HeroGiftUI"
    self.hero_gift_list = {}
    self.hero_gift_buy_list = {}
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

function HeroGiftUI:Show(param_tb)
    self.date = param_tb
    self.activity_list = self.date.activity_list
    self.activity_list_length = #self.activity_list
    if self.is_res_ok then
        self:InitUI()
    end
    HeroGiftUI.super.Show(self)
end

function HeroGiftUI:Update(delta_time)
    self:UpdateRefreshTime()
end

function HeroGiftUI:UpdateRefreshTime()
    for i = 1, self.activity_list_length do
        local hero_info = self.activity_list[self.index]
        local next_refresh_time = hero_info.end_ts
        local remian_time = next_refresh_time - Time:GetServerTime()
        if remian_time > 0  then
            self.refresh_text.text = UIFuncs.TimeDelta2Str(remian_time ,4, UIConst.Text.HERO_GIFT)
            self.hero_gift_buy_list[self.index] = false
        else
            self.hero_gift_buy_list[self.index] = true
            self.refresh_text.text = UIConst.Text.ALREADY_FINISH_TEXT
        end
    end
end

function HeroGiftUI:InitRes()
    self.content = self.main_panel:FindChild("Content")
    self.title = self.content:FindChild("Title"):GetComponent("Text")
    self:AddClick(self.content:FindChild("CloseBtn"), function ()
        self:Hide()
    end)
    self.BuyBtn = self.content:FindChild("BuyBtn")
    self.buyText = self.content:FindChild("BuyBtn/Image/Text"):GetComponent("Text")
    self.buyTip = self.content:FindChild("BuyTip"):GetComponent("Text")

    --添加英雄
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

function HeroGiftUI:UpdateHeroInfo(index)
    for i = 1, self.activity_list_length do
        if index == i then
            local hero_info = self.activity_list[i]
            --英雄Model
            local hero_unit_id = hero_info.hero_id
            self.unit = self:AddFullUnit(hero_unit_id, self.unit_rect)
            --获得道具
            local item_list = hero_info.item_list
            self.cur_frame_obj_list = UIFuncs.SetItemList(self, item_list, self.check_item_list)
            --限购次数（当前/总数）
            local cur_purchase_count = hero_info.purchase_have
            local purchase_count = hero_info.purchase_count
            self.buyTip.text = UIConst.Text.LIMIT_BUY .. cur_purchase_count .. "/" .. purchase_count
            --礼包价格
            local hero_gift_buy = self:GetUIObject(self.BuyBtn, self.content)
            hero_gift_buy:GetComponent("RectTransform").anchoredPosition = Vector2.New(-15, 120)
            self.hero_gift_list[i] = hero_gift_buy
            local buyText = hero_gift_buy:FindChild("Image/Text"):GetComponent("Text")
            if cur_purchase_count < purchase_count then
                local price = hero_info.price
                buyText.text = price .. "JG"
            else
                buyText.text = "已购买"
            end
            --购买Button
            self:AddClick(hero_gift_buy, function ()
                if cur_purchase_count < purchase_count and self.hero_gift_buy_list[self.index] == false then
                    SpecMgrs.msg_mgr:SendHeroPurchase({package_id = hero_info.id}, function (resp)
                        if resp.errcode == 0 then
                            self:UpdateHero(index,ComMgrs.dy_data_mgr[hero_data_dict["Hero"]](ComMgrs.dy_data_mgr))
                        end
                    end)
                elseif cur_purchase_count == purchase_count and self.hero_gift_buy_list[self.index] == false then
                    SpecMgrs.ui_mgr:ShowMsgBox("本次活动已购买完毕，请等时间刷新！")
                else
                    SpecMgrs.ui_mgr:ShowMsgBox("活动已结束，请重新进入！")
                end
            end)
            --礼包名字
            local activity_name = hero_info.activity_name
            self.title.text = activity_name

        end
    end
end

function HeroGiftUI:UpdateHero(index,msg)
    self.activity_list[index].purchase_have = msg.times
    self:ClearInfo()
    self:UpdateMiddle(index)
    self:UpdateHeroInfo(index)
end

function HeroGiftUI:InitUI()
    self:InitTaskInfo()
    if self.activity_list_length ~= nil then
        self:UpdateHeroInfo(1)
    end
end

function HeroGiftUI:LeftButton()
    self.index = self.index - 1
    self:ClearInfo()
    self:UpdateMiddle(self.index)
    self:UpdateHeroInfo(self.index)
end

function HeroGiftUI:RightButton()
    self.index = self.index + 1
    self:ClearInfo()
    self:UpdateMiddle(self.index)
end

function HeroGiftUI:UpdateMiddle(index)
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

function HeroGiftUI:InitTaskInfo()
    self.left_btn:SetActive(false)
    self.right_btn:SetActive(false)

    self.index = 1
    self:UpdateMiddle(1)
end

function HeroGiftUI:ClearInfo()
    self:DelObjDict(self.cur_frame_obj_list)
    for _, go in pairs(self.hero_gift_list) do
        self:DelUIObject(go)
    end
    self.hero_gift_list = {}
end

function HeroGiftUI:ClearRes()
    self:ClearInfo()
    self:ClearUnit("unit")
    self.index = 1

end


return HeroGiftUI