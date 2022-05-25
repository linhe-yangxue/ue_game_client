local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local LoverPlayUI = class("UI.LoverPlayUI", UIBase)

--local lover_data_dict = {
--    ["Lover"] = "ExGeLoverGiftBuy",
--    ["LoverInfo"] = "ExGeLoverGiftInfo",
--}
function LoverPlayUI:DoInit()
    LoverPlayUI.super.DoInit(self)
    self.dy_vip_data = ComMgrs.dy_data_mgr.vip_data
    self.prefab_path = "UI/Common/LoverPlayUI"
    self.lover_gift_list = {}
    self.lover_gift_buy_list = {}
    self.xiong_anim = "idle"
    self.anim_transition_time = 0.3
end

function LoverPlayUI:OnGoLoadedOk(res_go)
    LoverPlayUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function LoverPlayUI:Hide()
    LoverPlayUI.super.Hide(self)
    self:ClearRes()
end

function LoverPlayUI:Show(loverId)
    self.loverId = loverId
    if self.is_res_ok then
        self:InitUI()
    end
    LoverPlayUI.super.Show(self)
end

function LoverPlayUI:InitRes()
    self.content = self.main_panel:FindChild("Content")
    self.title = self.content:FindChild("Title"):GetComponent("Text")
    self:AddClick(self.content:FindChild("CloseBtn"), function ()
        self:Hide()
    end)
    --self.BuyBtn = self.content:FindChild("BuyBtn")
    --self.buyText = self.content:FindChild("BuyBtn/Image/Text"):GetComponent("Text")
    --self.buyTip = self.content:FindChild("BuyTip"):GetComponent("Text")

    --添加美女
    --self.unit_rect = self.content:FindChild("UnitRect")
    --local lover_unit_id = self.loverId
    --self.unit = self:AddFullUnit(lover_unit_id, self.unit_rect)
    --self.cur_frame_obj_list = {}
    --
    --self.play_btn = self.content:FindChild("ButtonPlay")
    --self:AddClick(self.play_btn, function ()
    --    self:ClickLover(self.xiong_anim)
    --    print("播放视频---")
    --end)
    --self.xiong = self.unit_rect:FindChild("Unit/Lover/lover_suofeiyazuozi/suofeiyazuozi_pb/xiong")

    --self:AddClick(self.lover_unit.go:FindChild("xiong"), function()
    --    self:ClickLover(self.xiong_anim)
    --end, SoundConst.SoundID.SID_NotPlaySound)

    --self.left_btn = self.content:FindChild("ButtonLeft")
    --self:AddClick(self.left_btn, function ()
    --    self:LeftButton()
    --end)
    --
    --self.right_btn = self.content:FindChild("ButtonRight")
    --self:AddClick(self.right_btn, function ()
    --    self:RightButton()
    --end)
    --
    --self.check_item_list = self.content:FindChild("ItemCheckList/ViewPort/CheckItemList")
    --self.reward_item = self.content:FindChild("ItemCheckList/ViewPort/CheckItemList/RewardItem")
    --
    --self.refresh_text = self.content:FindChild("RefreshObj/RefreshText"):GetComponent("Text")

end

function LoverPlayUI:InitUI()
    self.unit_rect = self.content:FindChild("UnitRect")
    local lover_unit_id = self.loverId
    self.unit = self:AddFullUnit(lover_unit_id, self.unit_rect)
    self:ClickLover(self.xiong_anim)
end

function LoverPlayUI:ClickLover(anim_name)
    print("动作名字---",anim_name)
    --if not self.can_interaction then return end
    --if not self.can_send_fondle then return end
    --if self.cur_fondle_time == 0 then
    --    SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.NOT_FONDLE_TIME_TIP)
    --    return
    --end
    --self.can_interaction = false
    --self:AddTimer(function()
    --    self.click_mask:SetActive(false)
    --    self.can_interaction = true
    --end, self.interaction_cd_time, 1)
    print("点击动画-----")
    self.unit:PlayAnim(anim_name, true)--, self.anim_transition_time
    --self:ClickDialog()
    --self:SendFondle()
    --self.click_mask:SetActive(true)
end


function LoverPlayUI:ClearInfo()
    self:DelObjDict(self.cur_frame_obj_list)
    for _, go in pairs(self.lover_gift_list) do
        self:DelUIObject(go)
    end
    self.lover_gift_list = {}
    self.unit = nil
end

function LoverPlayUI:ClearRes()
    self:ClearInfo()
    self:ClearUnit("unit")
    self.index = 1
end

return LoverPlayUI