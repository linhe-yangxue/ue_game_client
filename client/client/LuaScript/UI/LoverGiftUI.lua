local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local LoverGiftUI = class("UI.LoverGiftUI", UIBase)

local lover_data_dict = {
    ["Lover"] = "ExGeLoverGiftBuy",
    ["LoverInfo"] = "ExGeLoverGiftInfo",
}

local kSliderToNextFactor = 0.1 -- 滑动英雄超过屏幕的0.1就滑向下一个英雄
local kDefaultSelectSeatIndex = 1
local kOffset = 10
local kDefaultBgID = 160012 -- 英雄默认灰底图片
local default_vector2 = Vector2.New(1, 1)
local kTopHeroAnimTime = 0.2

local kHero = 1
--local kAid = 2
local lineup_type_map = {
    hero = kHero,
    --aid = kAid,
}
local func_map = {
    mid_update = {
        [kHero] = "_UpdateMidHeroItem",
    },
}
function LoverGiftUI:DoInit()
    LoverGiftUI.super.DoInit(self)
    self.dy_vip_data = ComMgrs.dy_data_mgr.vip_data
    self.prefab_path = "UI/Common/LoverGiftUI"
    self.lover_gift_list = {}
    self.lover_gift_buy_list = {}

    self.slider_x_offset = 0
    self.seat_to_model = {} -- 模型
    self.mid_go_list = {}
end

function LoverGiftUI:OnGoLoadedOk(res_go)
    LoverGiftUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function LoverGiftUI:Hide()
    LoverGiftUI.super.Hide(self)
    self:ClearRes()

    self:ClearUnitDict("seat_to_model")
    self:ClearGoDict("mid_go_list")
    self:ClearAnim("mid_anim")
    self.cur_seat_index = nil
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
            print("情人礼包页面数据刷新----",self.index)
            print("情人礼包页面数据刷新11111----",ComMgrs.dy_data_mgr[lover_data_dict["LoverInfo"]](ComMgrs.dy_data_mgr))
            self:UpdateLoverTest(self.index,ComMgrs.dy_data_mgr[lover_data_dict["LoverInfo"]](ComMgrs.dy_data_mgr))
        end
    end
end

function LoverGiftUI:InitRes()
    self.content = self.main_panel:FindChild("Content")
    self.title = self.content:FindChild("Title"):GetComponent("Text")
    self.item_title = self.content:FindChild("ItemTitle/Image/Text"):GetComponent("Text")
    self:AddClick(self.content:FindChild("CloseBtn"), function ()
        self:Hide()
    end)
    self.BuyBtn = self.content:FindChild("BuyBtn")
    self.buyText = self.content:FindChild("BuyBtn/Image/Text"):GetComponent("Text")
    self.buyTip = self.content:FindChild("BuyTip"):GetComponent("Text")

    --添加美女
    self.unit_rect = self.content:FindChild("UnitRect")
    self.cur_frame_obj_list = {}

    self.lover_movie_frame = self.content:FindChild("LoverMovieFrame")
    self.lover_bg = self.content:FindChild("LoverBg")


    self:_InitMiddleHeroPartRes()

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

function LoverGiftUI:_InitInitialPanel()
    --self.init_lineup_list, self.unlock_lineup_list= self:_GetInitLineupIdList()
    --self:_InitTopHreoPart()
    self:_InitMiddleHeroPart()
    self:SliderToIndex(kDefaultSelectSeatIndex, true)
end

function LoverGiftUI:_InitMiddleHeroPartRes()
    self.middle_hero_scroll_rect = self.content:FindChild("Middle/Scroll View"):GetComponent("ScrollRect")
    self.middle_hero_item_parent = self.content:FindChild("Middle/Scroll View/Viewport/Content")
    self.mid_view_rect = self.content:FindChild("Middle/Scroll View/Viewport"):GetComponent("RectTransform")
    self.mid_content_rect = self.middle_hero_item_parent:GetComponent("RectTransform")
    local rect = self.mid_view_rect.rect
    self.middle_lineup_type_to_temp = {}
    for k,v in pairs(lineup_type_map) do
        local go = self.middle_hero_item_parent:FindChild(k)
        go:SetActive(false)
        self.middle_lineup_type_to_temp[v] = go
        go:GetComponent("RectTransform").sizeDelta = Vector2.New(rect.width, rect.height)
    end
    --self:_InitAidTemp(self.middle_lineup_type_to_temp[kAid])
end

function LoverGiftUI:_InitMiddleHeroPart()
    print("LoverGiftUI------_InitMiddleHeroPart()------")
    --local serv_lineup_data = self.dy_hero_data:GetAllLineupData()
    self:ClearUnitDict("seat_to_model")
    self:ClearGoDict("mid_go_list")
    print("LoverGiftUI------_InitMiddleHeroPart()11111------",self.activity_list)
    for i = 1, self.activity_list_length do
        local item = self:GetUIObject(self.middle_lineup_type_to_temp[1], self.middle_hero_item_parent)
        self.mid_go_list[i] = item
        self:_InitMidItem(item, i, 1)
    end
    --for i, id in ipairs(self.activity_list_length) do
    --    local lineup_type = self:_GetLineupUnlockData(i).type
    --    print("LoverGiftUI------_InitMiddleHeroPart()2222222------",lineup_type)
    --    local item = self:GetUIObject(self.middle_lineup_type_to_temp[lineup_type], self.middle_hero_item_parent)
    --    self.mid_go_list[i] = item
    --    self:_InitMidItem(item, id, lineup_type)
    --end
    self.middle_hero_width = self.middle_lineup_type_to_temp[kHero].transform.sizeDelta.x
    print("LoverGiftUI------_InitMiddleHeroPart()22222------",self.middle_hero_width)
    self.max_hero_scroll_pos = (self.activity_list_length - 1) * self.middle_hero_width -- 默认情况 每个英雄之间间隙为0 不用计算
    print("LoverGiftUI------_InitMiddleHeroPart()33333-----",self.max_hero_scroll_pos)
end

function LoverGiftUI:_InitMidItem(item, id, type)
    print("LineupUI------_InitMidItem()------",item,id,type)
    local button = item:FindChild("Button")
    self:AddDrag(button, function (delta, position)
        self:OnDrag(delta, position)
    end)
    self:AddRelease(button, function ()
        self:OnRelease()
    end)
    --self:AddClick(button, function ()
    --    self:OnMidClick(id)
    --end)
    --local func_name = func_map.mid_init[type]
    --if not func_name then return end
    --self[func_name](self, item, id, type)
end

function LoverGiftUI:OnDrag(delta, position)
    print("LoverGiftUI------OnDrag()------",delta,position)
    if not self.is_drag then
        self.is_drag = true
    end
    self.slider_x_offset = self.slider_x_offset + delta.x
    local _, pos = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(self.middle_hero_item_parent:GetComponent("RectTransform"), position, self.canvas.worldCamera)
    local norimalize_pos = self.middle_hero_scroll_rect.horizontalNormalizedPosition - delta.x / self.max_hero_scroll_pos
    self.middle_hero_scroll_rect.horizontalNormalizedPosition = math.clamp(norimalize_pos, 0, 1)
end

function LoverGiftUI:OnRelease()
    print("LoverGiftUI------OnRelease()------",self.middle_hero_width,kSliderToNextFactor)
    if math.abs(self.slider_x_offset) >= self.middle_hero_width * kSliderToNextFactor then
        print("LoverGiftUI------OnRelease()111111------",self.slider_x_offset,self.cur_seat_index)
        local index = self.slider_x_offset > 0 and self.cur_seat_index - 1 or self.cur_seat_index + 1
        self:SliderToIndex(index, false)
    else
        print("LoverGiftUI------OnRelease()222------",self.slider_x_offset,self.cur_seat_index)
        self:SliderToIndex(self.cur_seat_index, false)
    end
    self.slider_x_offset = 0
end

function LoverGiftUI:OnMidClick(id)
    print("滑动button---",id,self.is_drag)
    if not self.is_drag then
        --local data = self.unlock_seat_data[id]
        --if data.type == kHero then
        --    if self.dy_hero_data:GetLineupHeroId(id) then
        --        self:ShowHeroDetailInfo()
        --    else
        --        SpecMgrs.ui_mgr:ShowUI("ChangeHeroUI", {lineup_id = id})
        --    end
        --end
    end
end

function LoverGiftUI:_UpdateInitialPanel()
    --for i, v in ipairs(self.init_lineup_list) do
    --    self:_UpdateTopItem(i)
    --end
    for i, v in ipairs(self.activity_list) do
        self:_UpdateMidItem(i)
    end
end

function LoverGiftUI:_UpdateMidItem(index)
    print("LoverGiftUI------_UpdateMidItem()------",index)
    --local data = self:_GetLineupUnlockData(index)
    local func_name = func_map.mid_update[1]
    local item = self.mid_go_list[index]
    self[func_name](self, item, index)
end

function LoverGiftUI:_UpdateMidHeroItem(go, index)
    print("LoverGiftUI------_UpdateMidHeroItem()------",index,go)
    for i = 1, self.activity_list_length do
        if index == i then
            local lover_info = self.activity_list[i]
            --情人Model
            local lover_unit_id = lover_info.lover_id
            self:_AddHeroUnit(index, lover_unit_id)
        end
    end
    --local lineup_id = self.unlock_lineup_list[index]
    --local go = self.mid_go_list[lineup_id]
    --local hero_id = self.dy_hero_data:GetLineupHeroId(lineup_id)
    --self:_AddHeroUnit(index, hero_id)
end

function LoverGiftUI:_ClearHeroUnit(index)
    if self.seat_to_model[index] then
        self:RemoveUnit(self.seat_to_model[index])
        self.seat_to_model[index] = nil
    end
end

function LoverGiftUI:_AddHeroUnit(index, hero_id)
    print("LoverGiftUI------_AddHeroUnit()------",index,hero_id)
    local go = self.mid_go_list[index]
    self:_ClearHeroUnit(index)
    if hero_id then
        --local unit_id  = SpecMgrs.data_mgr:GetHeroData(hero_id).unit_id
        self.seat_to_model[index] = self:AddFullUnit(hero_id, go:FindChild("UnitParent"))
    end
    go:FindChild("NoHero"):SetActive(not hero_id and true or false)
end

function LoverGiftUI:UpdateLoverInfo(index)
    --self.show_effect_id_list = {}
    --self.create_obj_list = {}
    self.lover_movie_frame:SetActive(false)
    self.lover_bg:SetActive(false)
    for i = 1, self.activity_list_length do
        if index == i then
            local lover_info = self.activity_list[i]
            --情人Model
            --local lover_unit_id = lover_info.lover_id
            --self.unit = self:AddFullUnit(lover_unit_id, self.unit_rect)
            --获得道具
            local item_list = lover_info.item_list
            print("道具----", item_list)
            --for i = #item_list, 1, -1 do
            --    local data = item_list[i]
            --    local item = UIFuncs.SetItem(self, data.item_id, data.count, self.check_item_list)
            --    if table.index(self.show_effect_id_list, data.item_id) then
            --        UIFuncs.AddGlodCircleEffect(self, item)
            --    end
            --    table.insert(self.create_obj_list, item)
            --end
            if i == 3 then
                self.lover_bg:SetActive(true)
            else
                self.lover_movie_frame:SetActive(true)
            end

            self.cur_frame_obj_list = UIFuncs.SetItemList(self, item_list, self.check_item_list)
            --限购次数（当前/总数）
            local cur_purchase_count = lover_info.purchase_have
            local purchase_count = lover_info.purchase_count
            self.buyTip.text = UIConst.Text.LIMIT_BUY .. cur_purchase_count .. "/" .. purchase_count
            --礼包价格
            local lover_gift_buy = self:GetUIObject(self.BuyBtn, self.content)
            lover_gift_buy:GetComponent("RectTransform").anchoredPosition = Vector2.New(29, 194)
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
            self.item_title.text = activity_name

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

function LoverGiftUI:ChangeLoverInfo(index)
    self:ClearInfo()
    self:UpdateMiddle(index)
    self:UpdateLoverInfo(index)
end

function LoverGiftUI:UpdateLoverTest(index,msg)
    self.date = msg
    self.activity_list = self.date.activity_list
    self.activity_list_length = #self.activity_list
    self:ChangeLoverInfo(index)
end

function LoverGiftUI:UpdateLover(index,msg)
    self.activity_list[index].purchase_have = msg.times
    self:ChangeLoverInfo(index)
end

function LoverGiftUI:InitUI()
    self:_InitInitialPanel()
    self:_UpdateInitialPanel()

    self:InitTaskInfo()
    if self.activity_list_length ~= nil then
        self:UpdateLoverInfo(1)
    end
end

function LoverGiftUI:LeftButton()
    self.index = self.index - 1
    self:SliderToIndex(self.index, false)
    --self:ChangeLoverInfo(self.index)
end

function LoverGiftUI:RightButton()
    self.index = self.index + 1
    self:SliderToIndex(self.index, false)
    --self:ChangeLoverInfo(self.index)
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

function LoverGiftUI:SliderToIndex(target_seat_index, is_immediately)
    print("LoverGiftUI------SliderToIndex()------",target_seat_index, is_immediately)
    target_seat_index = math.clamp(target_seat_index, 1, self.activity_list_length)
    if not self.cur_seat_index or self.cur_seat_index ~= target_seat_index then
        self.cur_seat_index = target_seat_index
    end
    --self:_UpdateSelectedHero()
    --self.ip_hero_part:SetActive(self:IsShowHeroPart())

    --self:AddSelectEffect(target_seat_index)
    print("LoverGiftUI------SliderToIndex()11111111------",target_seat_index, self.activity_list_length)
    local slider_target_pos = target_seat_index == 1 and 0 or (target_seat_index - 1) / (self.activity_list_length - 1)
    print("LoverGiftUI------SliderToIndex()222222222------",slider_target_pos)
    if is_immediately then
        print("LoverGiftUI------SliderToIndex()33333333------")
        self.middle_hero_scroll_rect.horizontalNormalizedPosition = slider_target_pos
    else
        print("LoverGiftUI------SliderToIndex()4444444444------")
        self:PlayScrollAnim(slider_target_pos, self.middle_hero_scroll_rect, "mid_anim")
        self:ChangeLoverInfo(target_seat_index)
        self.index = target_seat_index
    end
    --local view_width = self.initial_panel:FindChild("Top/Hero"):GetComponent("RectTransform").rect.width
    --local max_content_width = self.top_hero_item_parent:GetComponent("RectTransform").rect.width
    --local move_width = max_content_width - view_width
    --local top_hero_pos
    --if move_width < 0 then -- content fit 还没调整
    --    top_hero_pos = 0
    --else
    --    local icon_rect = self.seat_to_top_icon[target_seat_index]:GetComponent("RectTransform")
    --    local left_offset = icon_rect.anchoredPosition.x - kOffset
    --    local right_offset = icon_rect.anchoredPosition.x + icon_rect.rect.width + kOffset
    --    local left_pos = left_offset / move_width
    --    local right_pos = (right_offset - view_width) / move_width
    --    local cur_pos = self.top_hero_scroll_rect.horizontalNormalizedPosition
    --    if cur_pos > left_pos then
    --        top_hero_pos = left_pos
    --    end
    --    if cur_pos < right_pos then
    --        top_hero_pos = right_pos
    --    end
    --end
    --if not top_hero_pos then return end
    --if is_immediately then
    --    self.top_hero_scroll_rect.horizontalNormalizedPosition = top_hero_pos
    --else
    --    self:PlayScrollAnim(top_hero_pos, self.top_hero_scroll_rect, "top_anim")
    --end
end

function LoverGiftUI:PlayScrollAnim(target_pos, scroll_rect, anim_name)
    print("LoverGiftUI------PlayScrollAnim()------",target_pos, scroll_rect, anim_name)
    local cur_pos = scroll_rect.horizontalNormalizedPosition
    if math.abs(cur_pos - target_pos) < 0.01 then return end
    print("LoverGiftUI------PlayScrollAnim()111111------",cur_pos, target_pos)
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
    print("LoverGiftUI------IsShowHeroPart()------",self.cur_seat_index,self.activity_list_length)
    return self.cur_seat_index <= self.activity_list_length
end

--function LoverGiftUI:_UpdateSelectedHero()
--    if not self:IsShowHeroPart() then return end
--    local lineup_id = self.unlock_lineup_list[self.cur_seat_index]
--    local seat_data = self.dy_hero_data:GetLineupData(lineup_id)
--    local hero_id = seat_data and seat_data.hero_id
--    self:_UpdateHeroNameAndStar(hero_id)
--    self:_UpdateEquipPart(seat_data)
--    self:_UpdateAttrPart(self.cur_seat_index)
--end

function LoverGiftUI:ClearAnim(anim_name)
    if self[anim_name] then
        SpecMgrs.uianim_mgr:StopAnim(self[anim_name])
    end
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