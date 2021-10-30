local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local SecretTravelUI = class("UI.SecretTravelUI", UIBase)
local kInitTravelAreaId = 1 --总部所在城市
local kRadius = 0.4

local kStartQuaternion = Quaternion.Euler(0, 0, 30)
local kEndQuaternion = Quaternion.Euler(0, 0, -30)
local kResetQuaternion = Quaternion.Euler(0, 0, 0)
local kUnlockAnimTime = 1
local kUnlockAnimCount = 8
local kUnlockTimePerCount = 0.125
local kUnlockAnimInterval = 10

function SecretTravelUI:DoInit()
    SecretTravelUI.super.DoInit(self)
    self.prefab_path = "UI/Common/SecretTravelUI"
    self.dy_travel_data = ComMgrs.dy_data_mgr.travel_data
    self.dy_bag_data = ComMgrs.dy_data_mgr.bag_data
    self.dy_vip_data = ComMgrs.dy_data_mgr.vip_data
    self.dy_lover_data = ComMgrs.dy_data_mgr.lover_data
    self.travel_cost_item = CSConst.CostValueItem.PhysicalPower
    self.strengthen_item_id = SpecMgrs.data_mgr:GetParamData("travel_strength_num_restore_item").item_id
    self.travel_luck_limit = SpecMgrs.data_mgr:GetParamData("travel_luck_limit").f_value
    self.strengthen_recover_cd = SpecMgrs.data_mgr:GetParamData("travel_strength_num_restore_cd").f_value
    self.travel_luck_cost = SpecMgrs.data_mgr:GetParamData("travel_luck_consume").f_value
    self.easy_travel_unlock_vip_level = SpecMgrs.data_mgr:GetParamData("easy_travel_unlock_vip_level").f_value
    self.last_luck_icon = nil
    self.city_btn_dict = {}
    self.rotate_timer = 0
    self.unlock_anim_dict = {}
    self.unlock_timer = 0
end

function SecretTravelUI:OnGoLoadedOk(res_go)
    SecretTravelUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function SecretTravelUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    SecretTravelUI.super.Show(self)
end

function SecretTravelUI:Hide()
    self.rotate_timer = 0
    self.is_easy_travel = nil
    self.unlock_anim_dict = {}
    self:RemoveDynamicUI(self.rest_time)
    if self.plane_move_timer then
        self:RemoveTimer(self.plane_move_timer)
    end
    if self.lock_anim_timer then
        self:RemoveTimer(self.lock_anim_timer)
        self:ResetLockAnim()
    end
    ComMgrs.dy_data_mgr:UnregisterUpdateCurrencyEvent("SecretTravelUI")
    self.dy_travel_data:UnregisterUpdateTravelInfoEvent("SecretTravelUI")
    SecretTravelUI.super.Hide(self)
end

function SecretTravelUI:InitRes()
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "SecretTravelUI")

    local currency_panel = self.main_panel:FindChild("CurrencyPanel")
    self.money_count = currency_panel:FindChild("Money/Count"):GetComponent("Text")
    self.food_count = currency_panel:FindChild("Food/Count"):GetComponent("Text")
    self.soldier_count = currency_panel:FindChild("Soldier/Count"):GetComponent("Text")

    local city_content = self.main_panel:FindChild("CityContent")
    self.content_rect = city_content:GetComponent("RectTransform").rect
    self.plane = city_content:FindChild("Plane")
    self.plane_tween_pos = self.plane:GetComponent("UITweenPosition")
    self.anim_time = self.plane_tween_pos:GetDurationTime()
    self.plane_rect_cmp = self.plane:GetComponent("RectTransform")
    for city_id, city_data in pairs(SpecMgrs.data_mgr:GetAllTravelAreaData()) do
        local city_btn = city_content:FindChild(city_data.btn_name)
        self.city_btn_dict[city_id] = city_btn
        city_btn:FindChild("Text"):GetComponent("Text").text = city_data.name
        self:AddClick(city_btn:FindChild("CityBtn"), function ()
            SpecMgrs.ui_mgr:ShowUI("DirectedTravelUI", city_id)
        end)
        local unlock_btn = city_btn:FindChild("UnlockBtn")
        unlock_btn:FindChild("Level"):GetComponent("Text").text = string.format(UIConst.Text.LEVEL, city_data.unlock_level)
        self:AddClick(unlock_btn, function ()
            self:UnlockCity(city_data, city_btn)
        end)
        local disable_btn = city_btn:FindChild("Disable")
        self:AddClick(disable_btn, function ()
            SpecMgrs.ui_mgr:ShowMsgBox(string.format(city_data.unlock_desc, city_data.unlock_level))
        end)
        city_btn:FindChild("Disable/Level"):GetComponent("Text").text = string.format(UIConst.Text.LEVEL, city_data.unlock_level)
    end

    local bottom_panel = self.main_panel:FindChild("BottomPanel")
    bottom_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.LUCK_TEXT
    local luck_bar = bottom_panel:FindChild("LuckBar")
    self.luck_value = luck_bar:FindChild("LuckValue"):GetComponent("Image")
    self.luck_count = luck_bar:FindChild("LuckCount"):GetComponent("Text")
    self:AddClick(luck_bar:FindChild("AddLuckBtn"), function ()
        SpecMgrs.ui_mgr:ShowUI("CharityUI")
    end)
    self.strength = bottom_panel:FindChild("StrengthCount")
    self.strength_count = self.strength:GetComponent("Text")
    self.rest_time = bottom_panel:FindChild("RestText")
    self.rest_time_text = self.rest_time:GetComponent("Text")

    self.travel_btn = bottom_panel:FindChild("TravelBtn")
    self.travel_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.RANDOM_TRAVEL
    self:AddClick(self.travel_btn, function ()
        self:RandomTravel()
    end)
    self.recover_btn = bottom_panel:FindChild("RecoverBtn")
    self.recover_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.RECOVER_STRENGHTEN
    self:AddClick(self.recover_btn, function ()
        self.dy_travel_data:SendUseTravelItem()
    end)

    local easy_travel_panel = bottom_panel:FindChild("EasyTravelPanel")
    self.easy_travel_tips = easy_travel_panel:FindChild("Tips")
    self.easy_travel_tips:GetComponent("Text").text = UIConst.Text.UNLOCL_EASY_TRAVEL_TEXT
    self.easy_travel_toggle = easy_travel_panel:FindChild("EasyTravelToggle")
    self.easy_travel_toggle_cmp = self.easy_travel_toggle:GetComponent("Toggle")
    self:AddToggle(self.easy_travel_toggle, function (is_on)
        self.is_easy_travel = is_on
    end)
    self.mask = self.main_panel:FindChild("Mask")

end

function SecretTravelUI:InitUI()
    self:UpdateCurrencyItemCount()
    self:UpdateCityState()
    self:UpdateLuck()
    self:InitPlanePos()
    self:InitUnlockAnimTimer()
    self:InitEasyTravelPanel()
    self:RegisterEvent(ComMgrs.dy_data_mgr, "UpdateCurrencyEvent", function (_, currency)
        UIFuncs.UpdateCurrencyItemNum(self._item_to_text_list, currency)
    end)
    self:RegisterEvent(ComMgrs.dy_data_mgr.bag_data, "UpdateBagItemEvent", function (_, op, item_data)
        UIFuncs.UpdateBagItemNum(self._item_to_text_list, item_data)
    end)
    ComMgrs.dy_data_mgr:RegisterUpdateCurrencyEvent("SecretTravelUI", self.UpdateCurrencyItemCount, self)
    self.dy_travel_data:RegisterUpdateTravelInfoEvent("SecretTravelUI", function ()
        self:UpdateCityState()
        self:UpdateLuck()
    end, self)
    self:RegisterEvent(self.dy_vip_data, "UpdateVipInfo", function ()
        self:InitEasyTravelPanel()
    end)
end

function SecretTravelUI:InitEasyTravelPanel()
    local vip_level = ComMgrs.dy_data_mgr:ExGetRoleVip()
    self.easy_travel_tips:SetActive(vip_level < self.easy_travel_unlock_vip_level)
    self.easy_travel_toggle:SetActive(vip_level >= self.easy_travel_unlock_vip_level)
    self.easy_travel_toggle_cmp.isOn = self.is_easy_travel == true
end

function SecretTravelUI:InitUnlockAnimTimer()
    self.lock_anim_timer = self:AddTimer(function ()
        if next(self.unlock_anim_dict) then
            self.unlock_timer = kUnlockAnimTime
        end
    end, kUnlockAnimInterval, 0)
end

function SecretTravelUI:UpdateCurrencyItemCount()
    local currency_data = ComMgrs.dy_data_mgr:GetCurrencyData()
    self.money_count.text = UIFuncs.AddCountUnit(currency_data[CSConst.Virtual.Money] or 0)
    self.food_count.text = UIFuncs.AddCountUnit(currency_data[CSConst.Virtual.Food] or 0)
    self.soldier_count.text = UIFuncs.AddCountUnit(currency_data[CSConst.Virtual.Soldier] or 0)
end

function SecretTravelUI:UpdateCityState()
    local city_state_dict = self.dy_travel_data:GetCityStateDict()
    for city_id, city_btn in pairs(self.city_btn_dict) do
        city_btn:FindChild("CityBtn"):SetActive(city_state_dict[city_id] == CSConst.CityUnlockStatus.Yes)
        city_btn:FindChild("Disable"):SetActive(city_state_dict[city_id] == nil)
        local unlock_btn = city_btn:FindChild("UnlockBtn")
        unlock_btn:SetActive(city_state_dict[city_id] == CSConst.CityUnlockStatus.No)
        unlock_btn:GetComponent("Button").interactable = city_state_dict[city_id] == CSConst.CityUnlockStatus.No
        if city_state_dict[city_id] == CSConst.CityUnlockStatus.No then
            self.unlock_anim_dict[city_id] = unlock_btn:FindChild("Lock"):GetComponent("RectTransform")
        end
    end
end

function SecretTravelUI:UpdateLuck()
    self:UpdateLuckBar(self.dy_travel_data:GetCurLuckValue())
    local cur_strengthen_num = self.dy_travel_data:GetCurStrengthNum()
    self.travel_btn:SetActive(cur_strengthen_num > 0)
    self.strength:SetActive(cur_strengthen_num > 0)
    self.recover_btn:SetActive(cur_strengthen_num == 0)
    self.rest_time:SetActive(cur_strengthen_num == 0)
    if cur_strengthen_num > 0 then
        local max_travel_strength = ComMgrs.dy_data_mgr:ExGetMaxCostValue(self.travel_cost_item)
        local strength_pct = string.format(UIConst.Text.PER_VALUE, cur_strengthen_num, max_travel_strength)
        self.strength_count.text = string.format(UIConst.Text.STRENGTHEN_COUNT, strength_pct)
    else
        local recover_last_time = self.dy_travel_data:GetStrengthenRecoverLastTime()
        self:AddDynamicUI(self.rest_time, function ()
            if (self.strengthen_recover_cd + recover_last_time - Time:GetServerTime()) < 0 then
                self:RemoveDynamicUI(self.rest_time)
            end
            self.rest_time_text.text = UIFuncs.TimeDelta2Str(self.strengthen_recover_cd + recover_last_time - Time:GetServerTime())
        end, 1, 0)
    end
end

function SecretTravelUI:UpdateLuckBar(cur_luck_value)
    self.luck_count.text = string.format(UIConst.Text.PER_VALUE, cur_luck_value, self.travel_luck_limit)
    local now_luck_icon_id = nil

    local icon_data = SpecMgrs.data_mgr:GetAllLuckValueIconData()
    for id, data in ipairs(icon_data) do
        local min_value = math.min(data.value_range[1], data.value_range[2])
        local max_value = math.max(data.value_range[1], data.value_range[2])
        if cur_luck_value >= min_value and cur_luck_value <= max_value then
            now_luck_icon_id = id
            break
        end
    end
    if not self.last_luck_icon or now_luck_icon_id ~= self.last_luck_icon then
        self.last_luck_icon = now_luck_icon_id
        local res_path = icon_data[now_luck_icon_id].img_path
        local res_name = icon_data[now_luck_icon_id].img_name
        UIFuncs.AssignUISpriteSync(res_path, res_name, self.luck_value)
    end
    self.luck_value.fillAmount = cur_luck_value / self.travel_luck_limit
end

function SecretTravelUI:InitPlanePos()
    self.plane:SetActive(false)
    self.last_travel_area = kInitTravelAreaId
    local city_btn = self.city_btn_dict[kInitTravelAreaId]
    local plane_init_pos = self:CalcPlaneDestination(city_btn)
    self.plane_tween_pos.from_ = plane_init_pos
    self.plane_rect_cmp.anchoredPosition3D = plane_init_pos
end

function SecretTravelUI:ShowTravelEvent(event_data)
    event_data.confirm_cb = function ()
        if self.is_easy_travel and self.dy_travel_data:GetCurStrengthNum() > 0 then
            self:RandomTravel()
        end
    end
    self.mask:SetActive(true)
    if self.last_travel_area == event_data.area_id then
        local cur_euler = self.plane_rect_cmp.localEulerAngles
        local cur_dir = Vector3.New(-math.cos(math.rad(cur_euler.z)), -math.sin(math.rad(cur_euler.z)), 0)
        local circle_dir = Vector3.Cross(cur_dir, Vector3.forward)
        self.circle_point = circle_dir * kRadius + self.plane_rect_cmp.position
        local plane_init_pos = self.plane_rect_cmp.anchoredPosition
        self.plane:SetActive(true)
        self.rotate_timer = self.anim_time

        -- 直接向上绕一圈
        -- self.plane_rect_cmp.localEulerAngles = Vector3.zero
        -- local plane_pos = self.plane_rect_cmp.position
        -- plane_pos.y = plane_pos.y + kRadius
        -- self.circle_point = plane_pos
        -- self.plane:SetActive(true)
        -- self.rotate_timer = self.anim_time
        self.plane_move_timer = self:AddTimer(function ()
            SpecMgrs.ui_mgr:ShowTravelEvent(event_data)
            self.mask:SetActive(false)
            self.plane_move_timer = nil
            self.plane:SetActive(false)
            self.plane_rect_cmp.localEulerAngles = cur_euler
            self.plane_rect_cmp.anchoredPosition = plane_init_pos
            self.dy_bag_data:SetShowAddBagItem(true)
            self.dy_lover_data:HangLoverUnlockAnim(false)
        end, self.anim_time, 1)
        return
    end
    local travel_area = self.city_btn_dict[event_data.area_id]
    local destination = self:CalcPlaneDestination(travel_area)
    local direction = destination - self.plane_tween_pos.from_
    local rot = math.acos(-direction.x / Vector3.Magnitude(direction))
    local rot_dir = Vector3.Cross(direction, Vector3.left).z > 0 and - 1 or 1
    self.plane:SetActive(true)
    self.plane_rect_cmp.localEulerAngles = Vector3.New(0, 0, rot * math.rad2Deg * rot_dir)
    self.plane_tween_pos.to_ = destination
    self.plane_tween_pos:Play()
    self.plane_move_timer = self:AddTimer(function ()
        SpecMgrs.ui_mgr:ShowTravelEvent(event_data)
        self.mask:SetActive(false)
        self.plane_tween_pos.from_ = destination
        self.last_travel_area = event_data.area_id
        self.plane_move_timer = nil
        self.dy_bag_data:SetShowAddBagItem(true)
        self.dy_lover_data:HangLoverUnlockAnim(false)
        self.plane:SetActive(false)
    end, self.anim_time, 1)
end

-- msg --

function SecretTravelUI:RandomTravel()
    if self.dy_travel_data:GetCurLuckValue() < self.travel_luck_cost then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.WITHOUT_LUCK)
    else
        self.dy_bag_data:SetShowAddBagItem(false)
        self.dy_lover_data:HangLoverUnlockAnim(true)
        SpecMgrs.msg_mgr:SendRandomTravel({}, function (resp)
            if resp.errcode ~= 0 then
                SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.TRAVEL_FAILED)
            else
                self:ShowTravelEvent(resp)
            end
        end)
    end
end

function SecretTravelUI:UnlockCity(city_data, city_btn)
    local currency_data = SpecMgrs.data_mgr:GetItemData(city_data.consume_item)
    local data = {
        title = UIConst.Text.UNLOCK_TAG,
        item_id = city_data.consume_item,
        need_count = city_data.consume_item_count,
        desc = string.format(UIConst.Text.UNLOCK_CITY_FORMAT, currency_data.name, city_data.consume_item_count, city_data.name),
        remind_tag = "SecretTravelUI",
        confirm_cb = function ()
            SpecMgrs.msg_mgr:SendUnlockTravelArea({area_id = city_data.id}, function (resp)
                if resp.errcode ~= 0 then
                    SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.UNLOCK_CITY_FAILED)
                else
                    -- 城市解锁动画
                    SpecMgrs.ui_mgr:ShowTipMsg(string.format(UIConst.Text.CITY_UNLOCK, city_data.name))
                    city_btn:FindChild("UnlockBtn"):SetActive(false)
                    city_btn:FindChild("CityBtn"):SetActive(true)
                    self.unlock_anim_dict[city_data.id] = nil
                end
            end)
        end
    }
    SpecMgrs.ui_mgr:ShowItemUseRemindByTb(data)
    self.city_btn_dict[city_data.id] = city_btn
end

function SecretTravelUI:CalcPlaneDestination(city_btn)
    local plane_pos = city_btn:FindChild("PlanePos"):GetComponent("RectTransform").anchoredPosition
    local city_rect = city_btn:GetComponent("RectTransform")
    local city_pos = city_rect.anchoredPosition
    local city_anchor = city_rect.anchorMax

    local destination_x = self.content_rect.width * (city_rect.anchorMax.x - 0.5) + plane_pos.x + city_pos.x
    local destination_y = self.content_rect.height * (city_rect.anchorMax.y - 0.5) + plane_pos.y + city_pos.y
    return Vector3.New(destination_x, destination_y, 0)
end

function SecretTravelUI:Update(delta_time)
    if self.rotate_timer and self.rotate_timer > 0 then
        self.plane_rect_cmp:RotateAround(self.circle_point, Vector3.back, 360 / self.anim_time * delta_time)
        self.rotate_timer = self.rotate_timer - delta_time
    end
    if self.unlock_timer > 0 then
        self.unlock_timer = self.unlock_timer - delta_time
        if self.unlock_timer <= 0 then
            self:ResetLockAnim()
        else
            local cur_anim_count = kUnlockAnimCount - math.floor(self.unlock_timer / kUnlockTimePerCount)
            local is_clock_wise = cur_anim_count % 2 == 1
            local star_quat = is_clock_wise and kStartQuaternion or kEndQuaternion
            local end_quat = is_clock_wise and kEndQuaternion or kStartQuaternion
            local t = (self.unlock_timer - cur_anim_count * kUnlockTimePerCount) / kUnlockTimePerCount
            for _, lock_rect in pairs(self.unlock_anim_dict) do
                lock_rect.localRotation = Quaternion.Slerp(star_quat, end_quat, t)
            end
        end
    end
end

function SecretTravelUI:ResetLockAnim()
    self.unlock_timer = 0
    for _, lock_rect in pairs(self.unlock_anim_dict) do
        lock_rect.localRotation = kResetQuaternion
    end
end

return SecretTravelUI