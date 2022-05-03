local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local EventUtil = require("BaseUtilities.EventUtil")

local LoverGiftUI = class("UI.LoverGiftUI", UIBase)

local lover_data_dict = {
    ["Lover"] = "ExGeLoverGiftBuy",
    ["LoverInfo"] = "ExGeLoverGiftInfo",
}

local kSliderToNextFactor = 0.1 -- 滑动英雄超过屏幕的0.1就滑向下一个英雄
local kDefaultSelectSeatIndex = 1
local kTopHeroAnimTime = 0.2

local kHero = 1
local lineup_type_map = {
    hero = kHero,
}
local func_map = {
    mid_update = {
        [kHero] = "_UpdateMidHeroItem",
    },
}
function LoverGiftUI:DoInit()
    LoverGiftUI.super.DoInit(self)
    self.lover_video_data = SpecMgrs.data_mgr:GetAllLoverPortrait()
    self.prefab_path = "UI/Common/LoverGiftUI"
    self.lover_gift_list = {}
    self.lover_gift_buy_list = {}
    self.cur_frame_obj_list = {}

    self.slider_x_offset = 0
    self.seat_to_model = {} -- 模型
    self.mid_go_list = {}
    self.cmd_count_text = {}
end

function LoverGiftUI:OnGoLoadedOk(res_go)
    LoverGiftUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function LoverGiftUI:Hide()
    LoverGiftUI.super.Hide(self)
    ComMgrs.dy_data_mgr:UnregisterUpdateLoverGiftInfoEvent("LoverGiftUI")
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

function LoverGiftUI:Update()
    if self.activity_list_length ~= 0 then
        self:UpdateRefreshTime()
    end
end

--更新礼包倒计时
function LoverGiftUI:UpdateRefreshTime()
    local lover_info = self.activity_list[self.index]
    local next_refresh_time = lover_info.end_ts
    local remian_time = next_refresh_time - Time:GetServerTime()
    if remian_time > 0  then
        self.cmd_count_text[self.index].text = UIFuncs.TimeDelta2Str(remian_time ,4, UIConst.Text.LOVER_GIFT)
        --self.lover_gift_buy_list[self.index] = false
    else
        --self.lover_gift_buy_list[self.index] = true
        self.cmd_count_text[self.index].text = UIConst.Text.ALREADY_FINISH_TEXT
    end
end

function LoverGiftUI:InitRes()
    self.content = self.main_panel:FindChild("Content")
    self.view_content= self.content:FindChild("Middle/Scroll View/Viewport/Content")
    self.lover_content = self.view_content:FindChild("hero")

    self:_InitMiddleHeroPartRes()

    self.left_btn = self.content:FindChild("ButtonLeft")
    self:AddClick(self.left_btn, function ()
        self:LeftButton()
    end)

    self.right_btn = self.content:FindChild("ButtonRight")
    self:AddClick(self.right_btn, function ()
        self:RightButton()
    end)

end

function LoverGiftUI:_InitInitialPanel()
    self:_InitMiddleHeroPart()
    self:SliderToIndex(kDefaultSelectSeatIndex, true)
end

function LoverGiftUI:_InitMiddleHeroPartRes()
    self.middle_hero_scroll_rect = self.content:FindChild("Middle/Scroll View"):GetComponent("ScrollRect")
    self.mid_view_rect = self.content:FindChild("Middle/Scroll View/Viewport"):GetComponent("RectTransform")
    self.mid_content_rect = self.view_content:GetComponent("RectTransform")
    local rect = self.mid_view_rect.rect
    self.middle_lineup_type_to_temp = {}
    for k,v in pairs(lineup_type_map) do
        local go = self.view_content:FindChild(k)
        go:SetActive(false)
        self.middle_lineup_type_to_temp[v] = go
        go:GetComponent("RectTransform").sizeDelta = Vector2.New(rect.width, rect.height)
    end
end

function LoverGiftUI:_InitMiddleHeroPart()
    self:ClearUnitDict("seat_to_model")
    self:ClearGoDict("mid_go_list")
    for i = 1, self.activity_list_length do
        local item = self:GetUIObject(self.middle_lineup_type_to_temp[kHero], self.view_content)
        self.mid_go_list[i] = item
        local activity_list = self.activity_list[i]
        self:_InitMidItem(item, i,activity_list)
    end
    self.middle_hero_width = self.middle_lineup_type_to_temp[kHero].transform.sizeDelta.x
    self.max_hero_scroll_pos = (self.activity_list_length - 1) * self.middle_hero_width -- 默认情况 每个英雄之间间隙为0 不用计算
end

function LoverGiftUI:_InitMidItem(item, id,activity_list)
    local button = item:FindChild("Button")
    self:UpdateLoverInfo(item,id,activity_list)
    self:AddDrag(button, function (delta, position)
        self:OnDrag(delta, position)
    end)
    self:AddRelease(button, function ()
        self:OnRelease()
    end)
end

function LoverGiftUI:OnDrag(delta, position)
    if not self.is_drag then
        self.is_drag = true
    end
    self.slider_x_offset = self.slider_x_offset + delta.x
    local _, pos = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(self.view_content:GetComponent("RectTransform"), position, self.canvas.worldCamera)
    local norimalize_pos = self.middle_hero_scroll_rect.horizontalNormalizedPosition - delta.x / self.max_hero_scroll_pos
    self.middle_hero_scroll_rect.horizontalNormalizedPosition = math.clamp(norimalize_pos, 0, 1)
end

function LoverGiftUI:OnRelease()
    if math.abs(self.slider_x_offset) >= self.middle_hero_width * kSliderToNextFactor then
        local index = self.slider_x_offset > 0 and self.cur_seat_index - 1 or self.cur_seat_index + 1
        self:SliderToIndex(index, false)
    else
        self:SliderToIndex(self.cur_seat_index, false)
    end
    self.slider_x_offset = 0
end

function LoverGiftUI:_UpdateInitialPanel()
    for i, v in ipairs(self.activity_list) do
        self:_UpdateMidItem(i)
    end
end

function LoverGiftUI:_UpdateMidItem(index)
    local func_name = func_map.mid_update[1]
    local item = self.mid_go_list[index]
    self[func_name](self, item, index)
end

function LoverGiftUI:_UpdateMidHeroItem(go, index)
    for i = 1, self.activity_list_length do
        if index == i then
            local lover_info = self.activity_list[i]
            --情人Model
            local lover_unit_id = lover_info.lover_id
            if lover_info.lover_type == 1 then
                self:_AddHeroUnit(index, lover_unit_id)
            end
        end
    end
end

function LoverGiftUI:_ClearHeroUnit(index)
    if self.seat_to_model[index] then
        self:RemoveUnit(self.seat_to_model[index])
        self.seat_to_model[index] = nil
    end
end

function LoverGiftUI:_AddHeroUnit(index, hero_id)
    local go = self.mid_go_list[index]
    self:_ClearHeroUnit(index)
    if hero_id then
        self.seat_to_model[index] = self:AddHalfUnit(hero_id, go:FindChild("UnitParent")) --AddFullUnit
    end
    go:FindChild("NoHero"):SetActive(not hero_id and true or false)
end

function LoverGiftUI:UpdateLoverInfo(item,index,activity_list)
    local lover_info = activity_list
    local lover_movie_frame = item:FindChild("LoverMovieFrame")
    local lover_movie_frame_img = lover_movie_frame:GetComponent("Image")
    local lover_bg = item:FindChild("LoverBg")
    lover_movie_frame:SetActive(false)
    lover_bg:SetActive(false)
    local lover_bg_img = lover_bg:GetComponent("Image")
    local fashion_btn = item:FindChild("FashionBtn")
    local fashion_btn_des = fashion_btn:FindChild("Text"):GetComponent("Text")
    fashion_btn_des.text = "时装详情"
    fashion_btn:SetActive(false)
    self:AddClick(fashion_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("FashionInfoUI",lover_info)
    end)

    local title = item:FindChild("Title")
    local lover_title_fir = lover_info.activity_name_fir
    local title_text = title:GetComponent("Text")
    title_text.text = lover_title_fir
    local lover_movie_title = lover_movie_frame:FindChild("Image/Text"):GetComponent("Text")

    --情人礼包类型：0-视频   1-普通
    local lover_type = lover_info.lover_type
    local lover_gift_Play = item:FindChild("ButtonPlay")
    local lover_video_status = item:FindChild("VideoStatus")
    local lover_video_status_text = lover_video_status:FindChild("Text"):GetComponent("Text")
    local lover_mask_chest = item:FindChild("LoverMaskChest")
    local lover_mask_chest_img = lover_mask_chest:GetComponent("Image")
    lover_mask_chest:SetActive(false)
    local purchase_status = lover_info.purchase_status
    lover_video_status:SetActive(false)

    if lover_type == 0 then
        lover_movie_frame:SetActive(true)
        lover_gift_Play:SetActive(true)
        lover_video_status:SetActive(true)
        lover_movie_title.text = self.lover_video_data[lover_info.lover_id].name
        UIFuncs.AssignSpriteByIconID(tonumber(lover_info.icon), lover_movie_frame_img)
        if purchase_status == 0 then
            lover_video_status_text.text = "未购买"
            self:AddClick(lover_gift_Play, function ()
                SpecMgrs.ui_mgr:ShowMsgBox("购买此礼包后可解锁此视频！")
            end)
        else
            lover_video_status_text.text = "已拥有"
            self:AddClick(lover_gift_Play, function ()
                SpecMgrs.ui_mgr:ShowUI("LoverPlayUI",self.lover_video_data[lover_info.lover_id].unit_id)
            end)
        end
    elseif lover_type == 1 then

        UIFuncs.AssignSpriteByIconID(tonumber(lover_info.icon), lover_bg_img)
        if tonumber(lover_info.face_time) ~= -1 then
            UIFuncs.AssignSpriteByIconID(tonumber(lover_info.face_time), lover_mask_chest_img)
            lover_mask_chest:SetActive(true)
        else
            lover_mask_chest:SetActive(false)
        end
        fashion_btn:SetActive(true)
        lover_bg:SetActive(true)
        lover_gift_Play:SetActive(false)
    end

    --道具列表
    local item_list = lover_info.item_list
    local check_item_list = item:FindChild("ItemCheckList/ViewPort/CheckItemList")
    --这种方式可以直接将道具push完毕，但是不能加特效
    --local ret = UIFuncs.SetItemList(self, item_list, check_item_list)
    --UIFuncs.AddGlodCircleEffect(self, ret)
    --table.mergeList(self.cur_frame_obj_list, ret)

    for i = #item_list, 1, -1 do
        local data = item_list[i]
        local item = UIFuncs.SetItem(self, data.item_id, data.count, check_item_list)
        UIFuncs.AddGlodCircleEffect(self, item)
        table.insert(self.cur_frame_obj_list, item)
    end

    --礼包价格
    local price = lover_info.price
    local lover_discount = lover_info.discount
    local lover_gift_buy = item:FindChild("BuyBtn")
    local buy_btn_image = lover_gift_buy:FindChild("Image")
    local buy_btn_image1 = lover_gift_buy:FindChild("Image1")
    local price_text = buy_btn_image:FindChild("price"):GetComponent("Text")
    local discount_text = buy_btn_image:FindChild("discount"):GetComponent("Text")
    local pricefr_text = buy_btn_image1:FindChild("pricefr"):GetComponent("Text")

    if lover_discount ~= 0 then
        buy_btn_image:SetActive(true)
        price_text.text = price .. "JG"
        discount_text.text = lover_discount .. "JG"
    else
        buy_btn_image1:SetActive(true)
        pricefr_text.text = price .. "JG"
    end

    self:AddClick(item:FindChild("CloseBtn"), function ()
        self:Hide()
    end)
    --购买Button，购买完毕走主动推送进行更新
    self:AddClick(lover_gift_buy, function ()
        SpecMgrs.msg_mgr:SendLoverPurchase({package_id = lover_info.id}, function (resp)
            if resp.errcode == 0 then
                SpecMgrs.ui_mgr:ShowUI("CommonRewardUI",item_list)
            end
        end)
    end)

    --礼包副标题
    local lover_title_sec = lover_info.activity_name_sec
    local item_title = item:FindChild("ItemTitle/Image/Text"):GetComponent("Text")
    item_title.text = lover_title_sec

    local refresh_text = item:FindChild("RefreshObj/RefreshText"):GetComponent("Text")
    self.cmd_count_text[index] = refresh_text

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

--更新左右button信息
function LoverGiftUI:ChangeLoverInfo(index)
    self:UpdateMiddle(index)
end

function LoverGiftUI:InitUI()
    self:ClearRes()
    self:InitLoverUI()
    ComMgrs.dy_data_mgr:RegisterUpdateLoverGiftInfoEvent("LoverGiftUI", self.UpdateLoverGiftInfo, self)
end

function LoverGiftUI:InitLoverUI()
    self:_InitInitialPanel()
    self:_UpdateInitialPanel()
    self:InitTaskInfo()
end

function LoverGiftUI:UpdateLoverGiftInfo(_, data)
    self.activity_list_length = #data.activity_list
    self:ClearRes()
    if #data.activity_list == 0 then
        self:Hide()
    end
    self.date = data
    self.activity_list = self.date.activity_list
    self.activity_list_length = #self.activity_list
    self:InitLoverUI()
end

function LoverGiftUI:LeftButton()
    self.index = self.index - 1
    self:SliderToIndex(self.index, false)
end

function LoverGiftUI:RightButton()
    self.index = self.index + 1
    self:SliderToIndex(self.index, false)
end

function LoverGiftUI:UpdateMiddle(index)
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

function LoverGiftUI:SliderToIndex(target_seat_index, is_immediately)
    target_seat_index = math.clamp(target_seat_index, 1, self.activity_list_length)
    if not self.cur_seat_index or self.cur_seat_index ~= target_seat_index then
        self.cur_seat_index = target_seat_index
    end
    local slider_target_pos = target_seat_index == 1 and 0 or (target_seat_index - 1) / (self.activity_list_length - 1)
    if is_immediately then
        self.middle_hero_scroll_rect.horizontalNormalizedPosition = slider_target_pos
    else
        self:PlayScrollAnim(slider_target_pos, self.middle_hero_scroll_rect, "mid_anim")
        self:ChangeLoverInfo(target_seat_index)
        self.index = target_seat_index
    end
end

function LoverGiftUI:PlayScrollAnim(target_pos, scroll_rect, anim_name)
    local cur_pos = scroll_rect.horizontalNormalizedPosition
    if math.abs(cur_pos - target_pos) < 0.01 then return end
    self:ClearAnim(anim_name)
    self[anim_name] = SpecMgrs.uianim_mgr:PlayScrollAnim(
            kTopHeroAnimTime,
            scroll_rect.gameObject,
            "horizontalNormalizedPosition",
            cur_pos,
            target_pos,
            tween.easing.linear,
            function ()
                self.is_drag = nil
            end
    )
end

function LoverGiftUI:AddSelectEffect(seat_index)
    local go = self.seat_to_top_icon[seat_index]:FindChild("Selected")
    if not self.select_effect then
        self.select_effect = UIFuncs.AddSelectEffect(self, go)
    else
        self.select_effect:SetNewAttachGo(go)
    end
end

function LoverGiftUI:IsShowHeroPart()
    return self.cur_seat_index <= self.activity_list_length
end

function LoverGiftUI:ClearAnim(anim_name)
    if self[anim_name] then
        SpecMgrs.uianim_mgr:StopAnim(self[anim_name])
    end
end

function LoverGiftUI:ClearInfo()
    for _, go in pairs(self.lover_gift_list) do
        self:DelUIObject(go)
    end
    self.lover_gift_list = {}
    for _, go in pairs(self.cur_frame_obj_list) do
        self:DelUIObject(go)
    end
    self.cur_frame_obj_list = {}
end

function LoverGiftUI:ClearRes()
    self:ClearInfo()
    --self:DelObjDict(self.cur_frame_obj_list)
    self:ClearUnitDict("seat_to_model")
    self:ClearGoDict("mid_go_list")
    self:ClearAnim("mid_anim")
    self.cur_seat_index = nil
    --self:ClearUnit("unit")
    self.index = 1
end

return LoverGiftUI