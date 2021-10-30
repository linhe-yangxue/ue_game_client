local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local UnitConst = require("Unit.UnitConst")
local CelebrityHotelUI = class("UI.CelebrityHotelUI",UIBase)

local sync_num = 9
local redpoint_control_id_list = {
    CSConst.RedPointControlIdDict.LoverSkill,
    CSConst.RedPointControlIdDict.LoverStar
}

-- 后宫列表ui
function CelebrityHotelUI:DoInit()
    CelebrityHotelUI.super.DoInit(self)
    self.prefab_path = "UI/Common/CelebrityHotelUI"
    self.star_limit = SpecMgrs.data_mgr:GetParamData("lover_star_lv_limit").f_value
    self.lover_data = ComMgrs.dy_data_mgr.lover_data
    self.lover_id2lover_card = {}
    self.grid_column_count = 3
    self.lover_card_list_top = 30
    self.lover_card_list_y_spacing = 28
    self.can_skip_card_anim = true
    self.lover_redpoint_list = {}
end

function CelebrityHotelUI:OnGoLoadedOk(res_go)
    CelebrityHotelUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function CelebrityHotelUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    CelebrityHotelUI.super.Show(self)
end

function CelebrityHotelUI:InitRes()
    self:InitTopBar()
    --  下方信息
    local show_lover_panel = self.main_panel:FindChild("ShowLoverPanel")
    local down_mes_frame = show_lover_panel:FindChild("DownMesFrame")

    self.turn_card_count_down_text = down_mes_frame:FindChild("TurnCardMes/TurnCardCountDownText"):GetComponent("Text")
    self.turn_card_time_text = down_mes_frame:FindChild("TurnCardMes/TurnCardTimeText"):GetComponent("Text")
    self.turn_card_button = down_mes_frame:FindChild("TurnCardButton")
    self.recover_energy_button = down_mes_frame:FindChild("RecoverEnergyButton")
    self.turn_card_button_text = self.main_panel:FindChild("ShowLoverPanel/DownMesFrame/TurnCardButton/TurnCardButtonText"):GetComponent("Text")
    self.turn_card_button_tip = self.main_panel:FindChild("ShowLoverPanel/DownMesFrame/TurnCardButton/TurnCardButtonTip")
    self.recover_energy_button_text = self.main_panel:FindChild("ShowLoverPanel/DownMesFrame/RecoverEnergyButton/RecoverEnergyButtonText"):GetComponent("Text")
    self.tip_text = self.main_panel:FindChild("ShowLoverPanel/DownMesFrame/VipImage/TipText"):GetComponent("Text")
    self.vip_image = self.main_panel:FindChild("ShowLoverPanel/DownMesFrame/VipImage")
    self.quick_trun_card_toggle = self.main_panel:FindChild("ShowLoverPanel/DownMesFrame/QuickTurnCardToggle")
    self:AddToggle(self.quick_trun_card_toggle, function(is_on)
        self.lover_data.is_one_key_discuss = is_on
    end)

    self:AddClick(self.turn_card_button, function()
        self:ClickTurnCardBtn()
    end)

    local recover_energy_cb = function (resp)

    end
    self:AddClick(self.recover_energy_button, function()
        UIFuncs.UseBagItem(self.lover_discuss_recover_item)
    end)

    --  妃子列表
    local lover_frame = show_lover_panel:FindChild("LoverFrame")
    self.lover_card = lover_frame:FindChild("Temp/LoverCard")
    self.possess_title = lover_frame:FindChild("Temp/PossessTitle")
    self.not_possess_title = lover_frame:FindChild("Temp/NotPossessTitle")
    self.row_grid = lover_frame:FindChild("Temp/RowGrid")
    self.lover_card_rect = self.lover_card:GetComponent("RectTransform")

    self.lover_content = lover_frame:FindChild("LoverList/Viewport/Content")
    self.lover_content_rect = lover_frame:FindChild("LoverList/Viewport/Content"):GetComponent("RectTransform")

    self.flop_anim_first = show_lover_panel:FindChild("ui_lover_chouka_1")
    self.flop_anim_second = self.main_panel:FindChild("ui_lover_chouka_2")
    self.anim_mask = self.main_panel:FindChild("AnimMask")
    self:AddClick(self.anim_mask, function()
        if not self.can_skip_card_anim then return end
        self:RemoveTimer(self.second_anim_timer)
        self.can_skip_card_anim = false
        self:ShowSecondAnim(self.cur_drop_card_lover_id)
    end)

    self.lover_card:SetActive(false)
end

function CelebrityHotelUI:InitUI()
    self.not_possess_lover_tb = {}
    self.process_tb = {}
    self.create_obj_list = {}
    self.load_num = 0

    self.flop_anim_first:SetActive(false)
    self.flop_anim_second:SetActive(false)

    self:SetTextVal()
    self:UpdateUIInfo()
    self:UpdateDiscussNum()

    --  注册事件
    self.lover_data:RegisterUpdateDiscussEvent("CelebrityHotelUI", function()
        local can_tutn_card = self.lover_data:CanTurnCard()
        self:UpdateDiscussNum()
    end, self)
    self.lover_data:RegisterUpdateLoverInfoEvent("CelebrityHotelUI", function(_, _, lover_id)
        self:SetLoverCardMsg(self.lover_id2lover_card[lover_id], lover_id)
    end, self)
    self.lover_data:RegisterLoverChangeSexEvent("CelebrityHotelUI", function(_, _, old_lover_id, new_lover_id)
        self:SetLoverCardMsg(self.lover_id2lover_card[old_lover_id], new_lover_id)
        local obj = self.lover_id2lover_card[old_lover_id]
        self.lover_id2lover_card[old_lover_id] = nil
        self.lover_id2lover_card[new_lover_id] = obj
    end, self)
    ComMgrs.dy_data_mgr.vip_data:RegisterUpdateVipInfo("CelebrityHotelUI", function()
        self:UpdateQuickTurnCard()
    end, self)
end

function CelebrityHotelUI:UpdateUIInfo()
    self.lover_discuss_recover_item = SpecMgrs.data_mgr:GetParamData("lover_discuss_recover_item").item_id
    self.lover_info_tb = self.lover_data:GetAllLoverInfo()
    self.not_possess_lover_tb = self.lover_data:GetNotPossessLover()
    local not_possess_num = #self.not_possess_lover_tb
    local possess_num = #self.lover_info_tb
    --  妃子列表布局
    self.lover_card_y = self.lover_card_rect.sizeDelta.y
    local possess_title = self:GetUIObject(self.possess_title, self.lover_content, false)
    possess_title:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ALREADY_OWNED
    self:CreateRow(self.row_grid, self.lover_card, possess_num, true)
    local not_possess_title = self:GetUIObject(self.not_possess_title, self.lover_content, false)
    not_possess_title:FindChild("Text"):GetComponent("Text").text = UIConst.Text.NOT_OWNED
    self:CreateRow(self.row_grid, self.lover_card, not_possess_num, false)
    table.insert(self.create_obj_list, possess_title)
    table.insert(self.create_obj_list, not_possess_title)

    self:UpdateQuickTurnCard()
    self.quick_trun_card_toggle:GetComponent("Toggle").isOn = self.lover_data.is_one_key_discuss
end

function CelebrityHotelUI:UpdateQuickTurnCard()
    if ComMgrs.dy_data_mgr.func_unlock_data:CheckFuncIslock(CSConst.FuncUnlockId.OneKeyTurnCard) then
        self.vip_image:SetActive(true)
        self.quick_trun_card_toggle:SetActive(false)
    else
        self.vip_image:SetActive(false)
        self.quick_trun_card_toggle:SetActive(true)
    end
end

function CelebrityHotelUI:SetTextVal()
    self.turn_card_button_text.text = UIConst.Text.TURNCARD_BUTTON_TEXT
    self.recover_energy_button_text.text = UIConst.Text.RECOVER_ENERGY_TEXT
    self.tip_text.text = UIConst.Text.TURNCARD_TIP_TEXT
    local need_vip = UIFuncs.GetUnlockIdVipLevel(CSConst.FuncUnlockId.OneKeyTurnCard)
    UIFuncs.SetVipImage(self.vip_image, need_vip)
    self.quick_trun_card_toggle:FindChild("Label"):GetComponent("Text").text = UIConst.Text.QUICK_TURN_CARD
end

function CelebrityHotelUI:Update()
    if not self.is_res_ok or not self.is_visible then return end
    self:UpdateDiscussCoolDown()
end

function CelebrityHotelUI:ClickTurnCardBtn()
    if self.quick_trun_card_toggle.activeSelf and self.quick_trun_card_toggle:GetComponent("Toggle").isOn then
        self:SendTotalLoverDiscuss()
    else
        self:SendTurnCard()
    end
end

function CelebrityHotelUI:SendTotalLoverDiscuss()
    local cb = function(resp)
        local child_list = {}
        for i, id in ipairs(resp.lover_list) do
            local lover_name = SpecMgrs.data_mgr:GetLoverData(id).name
            local level = ComMgrs.dy_data_mgr.lover_data:GetLoverInfo(id).level
            local discuss_power_value = SpecMgrs.data_mgr:GetLoverLevelData(level).discuss_power_value
            SpecMgrs.ui_mgr:ShowTipMsg(string.format(UIConst.Text.LOVER_ADD_POWER_POINT_FORMAT, lover_name, discuss_power_value))
            if resp.child_dict[id] then
                table.insert(child_list, resp.child_dict[id])
            end
        end
        self:ShowBabyBornUI(child_list, 1)
    end
    SpecMgrs.msg_mgr:SendTotalLoverDiscuss(nil, cb)
end

--  弹出生孩子ui
function CelebrityHotelUI:ShowBabyBornUI(child_list, index)
    if child_list[index] then
        SpecMgrs.ui_mgr:ShowUI("BabyBornUI", child_list[index])
        SpecMgrs.ui_mgr:GetUI("BabyBornUI"):RegisterCancelBabyBornUI("CelebrityHotelUI" .. index, function()
            self:ShowBabyBornUI(child_list, index + 1)
            SpecMgrs.ui_mgr:GetUI("BabyBornUI"):UnregisterCancelBabyBornUI("CelebrityHotelUI" .. index)
        end, self)
        SpecMgrs.ui_mgr:GetUI("BabyBornUI"):RegisterGotoChildCenterUI("CelebrityHotelUI" .. index, function()
            SpecMgrs.ui_mgr:GetUI("BabyBornUI"):UnregisterCancelBabyBornUI("CelebrityHotelUI" .. index)
            SpecMgrs.ui_mgr:GetUI("BabyBornUI"):UnregisterGotoChildCenterUI("CelebrityHotelUI" .. index)
        end, self)
    end
end

function CelebrityHotelUI:SendTurnCard()
    local turn_card_cb = function (resp)
        if resp.lover_id ~= nil then
            -- 翻牌
            self.lover_data:DispatchUpdateLoverSpoilStateEvent(true)
            self.cur_drop_card_lover_id = resp.lover_id
            self.child_info = resp.child_info
            self.flop_anim_first:SetActive(true)
            self.anim_mask:SetActive(true)
            self.second_anim_timer = self:AddTimer(function()
                self:ShowSecondAnim(self.cur_drop_card_lover_id)
            end, 2.2, 1)
        end
    end
    SpecMgrs.msg_mgr:SendLoverDiscuss(nil, turn_card_cb)
end

function CelebrityHotelUI:ShowSecondAnim(lover_id)
    if not self.flop_anim_first.activeSelf then return end
    self.can_skip_card_anim = false
    local lover_data = SpecMgrs.data_mgr:GetLoverData(lover_id)
    local image = self.flop_anim_second:FindChild("GameObject/LoverImage")
    self:RemoveUnit(self.anim_unit)
    self.anim_unit = self:AddCardUnit(lover_data.unit_id, image)
    self.anim_unit:StopAllAnimationToCurPos()

    self.flop_anim_first:SetActive(false)
    self.flop_anim_second:SetActive(true)
    self:AddTimer(function()
        self.anim_mask:SetActive(false)
        self.can_skip_card_anim = true
        self.flop_anim_second:SetActive(false)

        local lover_info = ComMgrs.dy_data_mgr.lover_data:GetLoverInfo(lover_id)
        local lover_level_data = SpecMgrs.data_mgr:GetLoverLevelData(lover_info.level)
        local show_tip_list = {}
        table.insert(show_tip_list, string.format(UIConst.Text.ADD_POWER_POINT, lover_level_data.discuss_power_value))
        SpecMgrs.ui_mgr:ShowUI("SpoilUI", lover_id, self.child_info, show_tip_list)
    end, 0.6, 1)
end

function CelebrityHotelUI:CreateRow(row_grid_temp, lover_temp, lover_num, is_possess)
    local row_grid_obj = self:GetUIObject(row_grid_temp, self.lover_content, false)
    table.insert(self.create_obj_list, row_grid_obj)
    for i = 1, lover_num do
        local lover_id = is_possess and self.lover_info_tb[i].lover_id
        local obj = self:GetUIObject(lover_temp, row_grid_obj , false)
        table.insert(self.create_obj_list, obj)
        self:AddClick(obj:FindChild("TriggerBtn"), function()
            if is_possess then
                local param_tb = {
                    lover_id = lover_id
                }
                SpecMgrs.ui_mgr:ShowUI("LoverDetailUI", param_tb)
            else
                local lover_data = SpecMgrs.data_mgr:GetLoverData(self.not_possess_lover_tb[i].id)
                local fragment_data = SpecMgrs.data_mgr:GetItemData(lover_data.fragment_id)
                SpecMgrs.ui_mgr:ShowItemPreviewUI(fragment_data.lover)
            end
        end)
        if is_possess then
            self:SetLoverCardMsg(obj, lover_id)
            self:SetLoverCardUnit(obj, lover_id)
            self.lover_id2lover_card[lover_id] = obj
            obj:FindChild("Mask"):SetActive(false)
            local lover_redpoint = SpecMgrs.redpoint_mgr:AddRedPoint(self, obj, CSConst.RedPointType.HighLight, redpoint_control_id_list, lover_id)
            table.insert(self.lover_redpoint_list, lover_redpoint)
        else
            self:SetNotPorcessCard(obj, self.not_possess_lover_tb[i].id)
            obj:FindChild("Mask"):SetActive(true)
        end
    end
    local column_num = math.ceil(lover_num / self.grid_column_count)
    local grid_rect = row_grid_obj:GetComponent("RectTransform")
    local y_length = column_num * (self.lover_card_y + self.lover_card_list_y_spacing) + self.lover_card_list_top
    grid_rect.sizeDelta = Vector2.New(grid_rect.sizeDelta.x, y_length)
end

function CelebrityHotelUI:UpdateDiscussCoolDown()
    local num = self.lover_data:GetDiscussNum()
    local max_num = self.lover_data:GetMaxDiscussNum()
    if num == 0 then
        local cool_down = self.lover_data:GetDiscussCoolDown()
        if cool_down == nil then
            return
        end
        self.turn_card_count_down_text.text = UIFuncs.TimeDelta2Str(cool_down,3)
    else
        self.turn_card_time_text.text = string.format(UIConst.Text.SPRIT, num, max_num)
    end
end

function CelebrityHotelUI:UpdateDiscussNum()
    local num = self.lover_data:GetDiscussNum()
    local max_num = self.lover_data:GetMaxDiscussNum()

    if num == 0 then
        local cool_down = self.lover_data:GetDiscussCoolDown()
        if cool_down == nil then
            PrintError("DiscussCoolDownError")
            return
        end
        self.turn_card_button:SetActive(false)
        self.recover_energy_button:SetActive(true)
        self.turn_card_time_text.gameObject:SetActive(false)
        self.turn_card_count_down_text.gameObject:SetActive(true)
        self.turn_card_count_down_text.text =  UIFuncs.TimeDelta2Str(cool_down,3)
    else
        self.turn_card_button:SetActive(true)
        self.recover_energy_button:SetActive(false)
        self.turn_card_time_text.gameObject:SetActive(true)
        self.turn_card_count_down_text.gameObject:SetActive(false)
        self.turn_card_time_text.text = string.format(UIConst.Text.SPRIT, num, max_num)
    end
end

function CelebrityHotelUI:SetNotPorcessCard(lover_card, lover_id)
    local lover_data = SpecMgrs.data_mgr:GetLoverData(lover_id)
    local quality_data = SpecMgrs.data_mgr:GetQualityData(lover_data.quality)
    local name = lover_data.name
    local power_name = SpecMgrs.data_mgr:GetPowerData(lover_data.power).name
    local condition = lover_data.get_condition

    lover_card:FindChild("PowerText"):SetActive(false)
    lover_card:FindChild("PowerValText"):SetActive(false)
    lover_card:FindChild("Intimacy"):SetActive(false)
    lover_card:FindChild("Mask"):SetActive(true)
    lover_card:FindChild("LockImage"):SetActive(true)
    lover_card:FindChild("LockText"):SetActive(true)

    lover_card:FindChild("LockText"):GetComponent("Text").text = lover_data.lock_text
    lover_card:FindChild("NameText"):GetComponent("Text").text = name
    local lover_grade_img = lover_card:FindChild("Grade"):GetComponent("Image")
    UIFuncs.AssignSpriteByIconID(quality_data.grade, lover_grade_img)
    lover_grade_img.material = SpecMgrs.res_mgr:GetMaterialSync(UIConst.MaterialResPath.UIGray)
    local star_list = lover_card:FindChild("StarList")
    for i = 1, self.star_limit do
        star_list:FindChild("Star" .. i .. "/Active"):SetActive(false)
    end
    self:CreateUnit(lover_data.unit_id, lover_card:FindChild("LoverImage"))
end

function CelebrityHotelUI:GetGuideBtn(button_patch, cb)
    if button_patch == "Lover" then
        cb(self.lover_id2lover_card[self.lover_info_tb[1].lover_id]:FindChild("TriggerBtn"))
    else
        cb(self.go:FindChild(button_patch))
    end
end

function CelebrityHotelUI:SetLoverCardMsg(lover_card, lover_id)
    --  设置情人卡片属性
    local lover_info = ComMgrs.dy_data_mgr.lover_data:GetLoverInfo(lover_id)
    local lover_data = SpecMgrs.data_mgr:GetLoverData(lover_id)
    local quality_data = SpecMgrs.data_mgr:GetQualityData(lover_data.quality)

    local name = lover_data.name

    lover_card:FindChild("PowerText"):SetActive(true)
    lover_card:FindChild("PowerValText"):SetActive(true)
    lover_card:FindChild("Intimacy"):SetActive(true)
    lover_card:FindChild("Mask"):SetActive(false)
    lover_card:FindChild("LockImage"):SetActive(false)
    lover_card:FindChild("LockText"):SetActive(false)

    UIFuncs.AssignSpriteByIconID(quality_data.lover_card_bg, lover_card:FindChild("LoverImage"):GetComponent("Image"))
    lover_card:FindChild("Intimacy/IntimacyValText"):GetComponent("Text").text = lover_info.level
    lover_card:FindChild("NameText"):GetComponent("Text").text = name
    lover_card:FindChild("PowerText"):GetComponent("Text").text = UIConst.Text.LOVER_POWER_TEXT
    lover_card:FindChild("PowerValText"):GetComponent("Text").text = lover_info.power_value
    local lover_grade_img = lover_card:FindChild("Grade"):GetComponent("Image")
    UIFuncs.AssignSpriteByIconID(quality_data.grade, lover_grade_img)
    lover_grade_img.material = nil
    local star_list = lover_card:FindChild("StarList")
    for i = 1, self.star_limit do
        star_list:FindChild("Star" .. i .. "/Active"):SetActive(i <= lover_info.star_lv)
    end
end

function CelebrityHotelUI:SetLoverCardUnit(lover_card, lover_id)
    local lover_image = lover_card:FindChild("LoverImage")
    local lover_data = SpecMgrs.data_mgr:GetLoverData(lover_id)

    self:CreateUnit(lover_data.unit_id, lover_image)
end

function CelebrityHotelUI:CreateUnit(unit_id, lover_image)
    self.load_num = self.load_num + 1
    local unit
    if self.load_num > sync_num then
        unit = self:AddCardUnit(unit_id, lover_image, nil, nil, nil, true)
    else
        unit = self:AddCardUnit(unit_id, lover_image)
    end
    unit:StopAllAnimationToCurPos()
end

function CelebrityHotelUI:Hide()
    for _, redpoint in ipairs(self.lover_redpoint_list) do
        SpecMgrs.redpoint_mgr:RemoveRedPoint(redpoint)
        self.lover_redpoint_list = {}
    end
    self:DelObjDict(self.create_obj_list)
    ComMgrs.dy_data_mgr.vip_data:UnregisterUpdateVipInfo("CelebrityHotelUI")
    self.lover_data:UnregisterUpdateDiscussEvent("CelebrityHotelUI")
    self.lover_data:UnregisterUpdateLoverInfoEvent("CelebrityHotelUI")
    self.lover_data:UnregisterLoverChangeSexEvent("CelebrityHotelUI")
    CelebrityHotelUI.super.Hide(self)
end

return CelebrityHotelUI
