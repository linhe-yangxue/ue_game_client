local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local HeroGiftUI = class("UI.HeroGiftUI", UIBase)

function HeroGiftUI:DoInit()
    HeroGiftUI.super.DoInit(self)
    self.dy_vip_data = ComMgrs.dy_data_mgr.vip_data
    self.prefab_path = "UI/Common/HeroGiftUI"
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
    self.data = param_tb
    self.activity_list = self.data.activity_list
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
        self.refresh_text.text = UIFuncs.TimeDelta2Str(remian_time, 4, UIConst.Text.VIP_SHOP_REFRESH_TIME)
    end
end

function HeroGiftUI:InitRes()
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

function HeroGiftUI:UpdateHeroInfo(index)
    for i = 1, self.activity_list_length do
        if index == i then
            local hero_info = self.activity_list[i]
            --英雄Model
            local hero_unit_id = hero_info.hero_id
            self.unit = self:AddFullUnit(hero_unit_id, self.unit_rect)
            --获得道具
            local item_list = hero_info.item_list
            print("英雄礼包道具信息----",item_list)
            self.cur_frame_obj_list = UIFuncs.SetItemList(self, item_list, self.check_item_list)
            --礼包价格
            local price = hero_info.price
            self.buyText.text = price .. "JG"
            --限购次数（当前/总数）
            --local cur_purchase_count = lover_info.cur_purchase_count
            local purchase_count = hero_info.purchase_count
            self.buyTip.text = UIConst.Text.LIMIT_BUY .. purchase_count .. "/" .. purchase_count
            --礼包名字
            local activity_name = hero_info.activity_name
            self.title.text = activity_name
            --购买Button
            self:AddClick(self.BuyBtn, function ()
                print("英雄礼包购买")
                self:SendCreateHeroOrder(self.activity_list[i]);
            end)
        end
    end
end

function HeroGiftUI:SendCreateHeroOrder(data)
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
                type = 4,
            })    
        end    
    end
    SpecMgrs.msg_mgr:SendCreateHeroOrder({package_id  = data.lover_id}, cb)
end

function HeroGiftUI:RechargeSuccess()
    print("RechargeSuccess>>>>>>>>>>>>>>>>>>>>>", self.data)
end

function HeroGiftUI:InitLoverItemNew(item_list)
    print("HeroGiftUI:InitLoverItemNew(item_list)-------------",item_list)
    for i in ipairs(item_list) do
        local item = self:GetUIObject(self.reward_item, self.check_item_list)
        table.insert(self.cur_frame_obj_list, item)
        print("道具信息---",item_list[i].item_id,item_list[i].count)
        UIFuncs.AssignItem(item, item_list[i].item_id, item_list[i].count)
    end
end

function HeroGiftUI:InitUI()
    self:InitTaskInfo()
    if self.activity_list_length ~= nil then
        self:UpdateHeroInfo(1)
    end
end

function HeroGiftUI:LeftButton()
    self.index = self.index - 1
    print("当前页面数量111--",self.index)
    self:ClearInfo()
    self:UpdateMiddle(self.index)
    self:UpdateHeroInfo(self.index)
    print("点击left按钮")
end

function HeroGiftUI:RightButton()
    self.index = self.index + 1
    print("当前页面数量222--",self.index)
    self:ClearInfo()
    self:UpdateMiddle(self.index)
    self:UpdateHeroInfo(self.index)
    print("点击right按钮")
end

function HeroGiftUI:UpdateMiddle(index)
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

function HeroGiftUI:InitTaskInfo()
    self.left_btn:SetActive(false)
    self.right_btn:SetActive(false)

    self.index = 1
    self:UpdateMiddle(1)
end

function HeroGiftUI:ClearInfo()
    self:DelObjDict(self.cur_frame_obj_list)
end

function HeroGiftUI:ClearRes()
    self:ClearInfo()
    self:ClearUnit("unit")
    self.index = 1

end


return HeroGiftUI