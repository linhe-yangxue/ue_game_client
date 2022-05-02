local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local CommonRewardUI = class("UI.CommonRewardUI", UIBase)

function CommonRewardUI:DoInit()
    CommonRewardUI.super.DoInit(self)
    self.prefab_path = "UI/Common/CommonRewardUI"

    self.cur_frame_obj_list = {}
end

function CommonRewardUI:OnGoLoadedOk(res_go)
    CommonRewardUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function CommonRewardUI:Hide()
    CommonRewardUI.super.Hide(self)
    self:ClearRes()
end

function CommonRewardUI:Show(param_tb)
    print("通用道具奖励----",param_tb)
    self.item_list = param_tb
    if self.is_res_ok then
        self:InitUI()
    end
    CommonRewardUI.super.Show(self)
end

function CommonRewardUI:InitRes()
    self.content = self.main_panel:FindChild("Content")
    self.title = self.content:FindChild("Title"):GetComponent("Text")
    --self:AddClick(self.content:FindChild("CloseBtn"), function ()
    --    self:Hide()
    --end)

    --  点外面的位置关闭
    self:AddClick(self.content:FindChild("ClickMask"), function()
        self:Hide()
    end)

    self.check_item_list = self.content:FindChild("ItemCheckList/ViewPort/CheckItemList")

    --self.reward_item = self.content:FindChild("ItemCheckList/ViewPort/CheckItemList/RewardItem")

    --self.refresh_text = self.content:FindChild("RefreshObj/RefreshText"):GetComponent("Text")

end

function CommonRewardUI:InitUI()
    self:ShowItemList()
end

function CommonRewardUI:ShowItemList()
    print("通用道具奖励1111----",self.item_list)
    local ret = UIFuncs.SetItemList(self, self.item_list, self.check_item_list)
    table.mergeList(self.cur_frame_obj_list, ret)
end


function CommonRewardUI:ClearInfo()
    --for _, go in pairs(self.lover_gift_list) do
    --    self:DelUIObject(go)
    --end
    --self.lover_gift_list = {}
end

function CommonRewardUI:ClearRes()
    self:DelObjDict(self.cur_frame_obj_list)
    --self:ClearInfo()
end

return CommonRewardUI