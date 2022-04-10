local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local LoverGiftUI = class("UI.LoverGiftUI", UIBase)

local lover_data_dict = {
    ["aa"] = "ExGeLoverGiftBuy",
}
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
        if remian_time > 0  then
            self.refresh_text.text = UIFuncs.TimeDelta2Str(remian_time ,4, UIConst.Text.LOVER_GIFT)
        else
            self.refresh_text.text = UIConst.Text.ALREADY_FINISH_TEXT
        end
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

    self.refresh_text = content:FindChild("RefreshObj/RefreshText"):GetComponent("Text")

end

function LoverGiftUI:UpdateLoverInfo(index,msg)
    for i = 1, self.activity_list_length do
        if index == i then
            local lover_info = self.activity_list[i]
            print("更新情人礼包数据-----",self.activity_list[i])
            print("更新情人礼包数据1111-----",self.activity_list[i].purchase_have)
            --self.activity_list[i].purchase_have = 10
            --print("更新情人礼包数据2222-----",self.activity_list[i].purchase_have)
            --情人Model
            local lover_unit_id = lover_info.lover_id
            self.unit = self:AddFullUnit(lover_unit_id, self.unit_rect)
            --获得道具
            local item_list = lover_info.item_list
            self.cur_frame_obj_list = UIFuncs.SetItemList(self, item_list, self.check_item_list)
            --限购次数（当前/总数）
            local cur_purchase_count = lover_info.purchase_have
            local purchase_count = lover_info.purchase_count
            --if msg ~= nil then
            --    cur_purchase_count = msg.times
            --    --self.activity_list[i].purchase_have = msg.times
            --else
            --    cur_purchase_count = lover_info.purchase_have
            --end
            --local cur_purchase_count = lover_info.purchase_have
            self.buyTip.text = UIConst.Text.LIMIT_BUY .. cur_purchase_count .. "/" .. purchase_count
            --礼包价格
            if cur_purchase_count < purchase_count then
                local price = lover_info.price
                self.buyText.text = price .. "JG"
                --购买Button
                self:AddClick(self.BuyBtn, function ()
                    --local param_tb = {
                    --    package_id = lover_info.id,
                    --}
                    print("可以购买--------------",cur_purchase_count,purchase_count)
                    if cur_purchase_count < purchase_count then
                        SpecMgrs.msg_mgr:SendLoverPurchase({package_id = lover_info.id}, function (resp)
                            print("情人礼包uuu----",resp)
                            self:UpdateLover(index,ComMgrs.dy_data_mgr[lover_data_dict["aa"]](ComMgrs.dy_data_mgr))
                        end)
                    end
                end)
            else
                print("已经购买完毕--------------")
                self.buyText.text = "已购买"
            end

            --礼包名字
            local activity_name = lover_info.activity_name
            self.title.text = activity_name
        end
    end
end

function LoverGiftUI:UpdateLover(index,msg)
    --print("更新数据---",msg)
    --print("更新数据111---",msg.lover_activity_id)
    --print("更新数据222---",msg.status)
    --print("更新数据333---",msg.times)
    self.activity_list[index].purchase_have = msg.times
    self:ClearInfo()
    self:UpdateMiddle(index)
    self:UpdateLoverInfo(index,msg)
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