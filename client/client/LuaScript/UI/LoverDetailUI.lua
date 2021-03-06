local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local EffectConst = require("Effect.EffectConst")
local UIFuncs = require("UI.UIFuncs")
local ItemUtil = require("BaseUtilities.ItemUtil")
local UISliderTween = require("UI.UISliderTween")
local LoverDetailUI = class("UI.LoverDetailUI",UIBase)

local anim_duration = 0.3
local redpoint_v2 = Vector2.New(1, 1)
local create_effect_interval = 0.5
local power_control_id_list = {CSConst.RedPointControlIdDict.LoverSkill}
local star_control_id_list = {CSConst.RedPointControlIdDict.LoverStar}

--  情人属性面板
function LoverDetailUI:DoInit()
    LoverDetailUI.super.DoInit(self)
    self.prefab_path = "UI/Common/LoverDetailUI"

    self.lover_data = ComMgrs.dy_data_mgr.lover_data
    self.data_mgr = SpecMgrs.data_mgr
    self.star_limit = SpecMgrs.data_mgr:GetParamData("lover_star_lv_limit").f_value
    self.lover_active_star_list = {}
    self.index_Attribute = {
        "lover_exp",
        "etiquette",
        "culture",
        "charm",
        "planning",
    }
    self.award_ui_num = 3
    self.award_type_btn_num = 5
    self.max_level = SpecMgrs.data_mgr:GetLoverLevelData("max_level")
end

function LoverDetailUI:OnGoLoadedOk(res_go)
    LoverDetailUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function LoverDetailUI:Show(param_tb)
    self:ClearCreateRes()
    self.lover_id = param_tb.lover_id
    self.is_show_award = param_tb.is_show_award
    if self.is_res_ok then
        self:InitUI()
    end
    LoverDetailUI.super.Show(self)
end

function LoverDetailUI:InitRes()
    self:InitTopBar()
    --  上方属性面板
    self.up_mes_frame = self.main_panel:FindChild("UpMesFrame")
    self.up_lover_property_frame = self.main_panel:FindChild("UPLoverPropertyFrame")
    self.lover_name_text = self.up_lover_property_frame:FindChild("NamePanel/Text"):GetComponent("Text")
    self.lover_grade = self.up_lover_property_frame:FindChild("NamePanel/Grade"):GetComponent("Image")
    local star_panel = self.up_lover_property_frame:FindChild("StarPanel")
    for i = 1, self.star_limit do
        self.lover_active_star_list[i] = star_panel:FindChild("Star" .. i .. "/Active")
    end
    self.describe_text = self.up_lover_property_frame:FindChild("DescribeText"):GetComponent("Text")

    --  中间ui
    self.middle_frame = self.main_panel:FindChild("MiddleFrame")
    local attr_panel = self.middle_frame:FindChild("LoverAttrPanel")

    self.lover_model = self.main_panel:FindChild("MiddleFrame/LoverModel")
    self.intimacy_exp_text = self.main_panel:FindChild("MiddleFrame/LoverAttrPanel/IntimacyExpText"):GetComponent("Text")
    self.power_name_text = self.main_panel:FindChild("MiddleFrame/LoverAttrPanel/PowerText"):GetComponent("Text")
    self.intimacy_slider_image = self.main_panel:FindChild("MiddleFrame/LoverAttrPanel/IntimacySliderMes/IntimacyImage"):GetComponent("Image")
    self.intimacy_slider_text = self.main_panel:FindChild("MiddleFrame/LoverAttrPanel/IntimacySliderMes/IntimacyText"):GetComponent("Text")
    self.intimacy_text = self.main_panel:FindChild("MiddleFrame/LoverAttrPanel/IntimacyMes/IntimacyText"):GetComponent("Text")
    self.intimacy_level_text = self.main_panel:FindChild("MiddleFrame/LoverAttrPanel/IntimacyMes/IntimacyLevelText"):GetComponent("Text")
    self.power_text = self.main_panel:FindChild("MiddleFrame/LoverAttrPanel/PowerMes/PowerText"):GetComponent("Text")
    self.power_point_text = self.main_panel:FindChild("MiddleFrame/LoverAttrPanel/PowerMes/PowerValText"):GetComponent("Text")
    self.all_attr_text = self.main_panel:FindChild("MiddleFrame/LoverAttrPanel/AllAttrMes/AllAttrText"):GetComponent("Text")
    self.total_attribute_text = self.main_panel:FindChild("MiddleFrame/LoverAttrPanel/AllAttrMes/AllAttrValText"):GetComponent("Text")
    self.son_text = self.main_panel:FindChild("MiddleFrame/LoverAttrPanel/SonMes/SonText"):GetComponent("Text")
    self.child_num_text = self.main_panel:FindChild("MiddleFrame/LoverAttrPanel/SonMes/SonNumText"):GetComponent("Text")
    self.unit_rect = self.main_panel:FindChild("UnitRect")
    self.effect_point = self.main_panel:FindChild("EffectPoint")
    self.lover_attr = self.middle_frame:FindChild("LoverAttr")
    self.ceremony_num_text = self.middle_frame:FindChild("LoverAttr/CeremonyAttr/ValText"):GetComponent("Text")
    self.culture_num_text = self.middle_frame:FindChild("LoverAttr/CultureAttr/ValText"):GetComponent("Text")
    self.charm_num_text = self.middle_frame:FindChild("LoverAttr/CharmAttr/ValText"):GetComponent("Text")
    self.plan_attr_text = self.middle_frame:FindChild("LoverAttr/PlanAttr/ValText"):GetComponent("Text")
    self.gift_anim = self.main_panel:FindChild("GiftAnim")

    self.dressing_button = self.middle_frame:FindChild("DressingButton")
    self:AddClick(self.dressing_button, function()
        SpecMgrs.ui_mgr:ShowUI("DressingUI", self.lover_id)
    end)

    self.reincarnation_btn = self.middle_frame:FindChild("ReincarnationBtn")
    self:AddClick(self.middle_frame:FindChild("ReincarnationBtn"), function()
        SpecMgrs.ui_mgr:ShowUI("ReincarnationUI", self.lover_id)
    end)

    self.star_btn = self.middle_frame:FindChild("StarBtn")
    self.star_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ADD_STAR
    self:AddClick(self.star_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("LoverAddStarUI", self.lover_id)
    end)

    --  下方按钮
    self.down_frame = self.main_panel:FindChild("DownFrame")

    self.intimacy_button_text = self.main_panel:FindChild("DownFrame/AwardButtonList/IntimacyButton/IntimacyButtonText"):GetComponent("Text")
    self.ceremomy_button_text = self.main_panel:FindChild("DownFrame/AwardButtonList/CeremomyButton/CeremomyButtonText"):GetComponent("Text")
    self.culture_button_text = self.main_panel:FindChild("DownFrame/AwardButtonList/CultureButton/CultureButtonText"):GetComponent("Text")
    self.charm_button_text = self.main_panel:FindChild("DownFrame/AwardButtonList/CharmButton/CharmButtonText"):GetComponent("Text")
    self.plan_button_text = self.main_panel:FindChild("DownFrame/AwardButtonList/PlanButton/PlanButtonText"):GetComponent("Text")
    self.power_button_text = self.main_panel:FindChild("DownFrame/PowerButton/PowerButtonText"):GetComponent("Text")
    self.award_button_text = self.main_panel:FindChild("DownFrame/AwardButton/AwardButtonText"):GetComponent("Text")
    self.spoil_button_text = self.main_panel:FindChild("DownFrame/SpoilButton/SpoilButtonText"):GetComponent("Text")

    self.power_button = self.down_frame:FindChild("PowerButton")
    self.award_button = self.down_frame:FindChild("AwardButton")
    self.spoil_button = self.down_frame:FindChild("SpoilButton")
    self:AddClick(self.power_button, function()--  势力
        SpecMgrs.ui_mgr:ShowUI("PowerDistributionUI", self.lover_id)
    end)
    self:AddClick(self.award_button, function()--  奖赏
        self:ShowOrHideAwardUI(true)
    end)
    self:AddClick(self.spoil_button, function()--  宠爱
        SpecMgrs.ui_mgr:ShowUI("SpoilConfirmUI", self.lover_info.lover_id, self.lover_info.level)
        SpecMgrs.ui_mgr:GetUI("SpoilConfirmUI"):RegisterCloseUI("LoverDetailUI", function()
            self:ShowUIEffect()
            self:UpdateLoverInfo()
        end, self)
        local param_tb = {
            effect_id = EffectConst.EF_ID_Lover_button_click,
        }
        self:RemoveUIEffect(self.spoil_button, nil, true)
        self:AddUIEffect(self.spoil_button, param_tb, false, true)
    end)

    --  奖赏面板

    self.award_frame = self.main_panel:FindChild("AwardFrame")

    self.award_list = self.award_frame:FindChild("AwardList")
    self.award_ten_time_toggle = self.award_frame:FindChild("AwardTenTimeToggle"):GetComponent("Toggle")
    self.award_ten_time_text = self.award_frame:FindChild("AwardTenTimeToggle/AwardTenTimeText"):GetComponent("Text")

    self.award_frame_ceremony_num_text = self.award_frame:FindChild("LoverAttr/CeremonyAttr/ValText"):GetComponent("Text")
    self.award_frame_culture_num_text = self.award_frame:FindChild("LoverAttr/CultureAttr/ValText"):GetComponent("Text")
    self.award_frame_charm_num_text = self.award_frame:FindChild("LoverAttr/CharmAttr/ValText"):GetComponent("Text")
    self.award_frame_plan_attr_text = self.award_frame:FindChild("LoverAttr/PlanAttr/ValText"):GetComponent("Text")

    self.award_item_list = {}
    for i = 1, self.award_ui_num do
        table.insert(self.award_item_list, self.award_list:FindChild("AwardObjMes" .. i))
    end

    self.award_button_parent = self.down_frame:FindChild("AwardButtonList")
    local btn_list = self.down_frame:FindChild("AwardButtonList"):GetComponentsInChildren(UnityEngine.UI.Button)
    self.btn_tb = {}
    for i = 0, self.award_type_btn_num - 1 do
        table.insert(self.btn_tb, btn_list[i])
    end

    for i, v in ipairs(self.btn_tb) do
        local go = v.gameObject
        self:AddClick(go, function()
            self:SelectAwardButton(go, i)
        end)
    end
    --  点外面的位置关闭
    self:AddClick(self.award_frame:FindChild("ClickMask"), function()
        self:ShowOrHideAwardUI(false)
    end)

    self.gift_anim:SetActive(false)
end

function LoverDetailUI:InitUI()
    self.can_create_send_gift_effect = true
    self.send_gift_effect_id = SpecMgrs.data_mgr:GetParamData("give_lover_gift").effect_id
    self.cur_select_item_list = nil
    self.slider_anim = UISliderTween.New()
    self.slider_anim:DoInit(self.intimacy_slider_image, anim_duration)
    self:SelectAwardButton(self.btn_tb[1].gameObject, 1)
    if self.is_show_award ~= nil then
        self:ShowOrHideAwardUI(self.is_show_award)
    else
        self:ShowOrHideAwardUI(false)
    end
    self:SetTextVal()
    self:UpdateLoverData()
    self:UpdateUpPropertyFrame()
    self:UpdateMiddlePropertyFrame()
    self:UpdateLoverInfo()

    self.lover_data:RegisterUpdateLoverInfoEvent("LoverDetailUI", function(_, _, lover_id)
        if self.lover_id == lover_id then
            self:UpdateLoverData()
            self:UpdateUpPropertyFrame()
            if not self.is_give_gift then
                self:UpdateLoverInfo()
            end
        end
    end, self)

    self:ShowUIEffect()

    local lover_unit_id = self.cur_lover_data.unit_id
    self:AddFullUnit(lover_unit_id, self.unit_rect)
    self.power_redpoint = SpecMgrs.redpoint_mgr:AddRedPoint(self, self.power_button, CSConst.RedPointType.Normal, power_control_id_list, self.lover_id)
    self.star_redpoint = SpecMgrs.redpoint_mgr:AddRedPoint(self, self.star_btn, CSConst.RedPointType.Normal, star_control_id_list, self.lover_id, redpoint_v2, redpoint_v2)
end

function LoverDetailUI:Update(delta_time)
    if not self.is_res_ok or not self.is_visible then return end
    if self.slider_anim.is_run then
        self.slider_anim:Update(delta_time)
    end
end

function LoverDetailUI:ShowUIEffect()
    local param_tb = {
        effect_id = EffectConst.EF_ID_Lover_button_effect,
    }
    self:AddUIEffect(self.spoil_button, param_tb, false, true)
end

function LoverDetailUI:SetTextVal()
    self.intimacy_exp_text.text = UIConst.Text.LOVER_DETAIL_INTIMACY_EXP_TEXT
    self.power_text.text = UIConst.Text.LOVER_POWER_TEXT
    self.all_attr_text.text = UIConst.Text.ALLATTR_TEXT
    self.son_text.text = UIConst.Text.SON_TEXT

    self.intimacy_button_text.text = UIConst.Text.INTIMACY_TEXT
    self.ceremomy_button_text.text = UIConst.Text.CEREMONY_TEXT
    self.culture_button_text.text = UIConst.Text.CULTURE_TEXT
    self.charm_button_text.text = UIConst.Text.CHARM_TEXT
    self.plan_button_text.text = UIConst.Text.PLAN_TEXT
    self.power_button_text.text = UIConst.Text.POWER_TEXT
    self.award_button_text.text = UIConst.Text.GIVE_TEXT
    self.spoil_button_text.text = UIConst.Text.APPOINTMENT
    self.award_ten_time_text.text = UIConst.Text.AWARD_TEN_TEXT
end

function LoverDetailUI:UpdateLoverData()
    self.lover_info = self.lover_data:GetLoverInfo(self.lover_id)
    self.cur_lover_data = self.data_mgr:GetLoverData(self.lover_id)
    self.lover_quality_data = self.data_mgr:GetQualityData(self.cur_lover_data.quality)
end

--  更新上方面板
function LoverDetailUI:UpdateUpPropertyFrame()
    local attr_dict = self.lover_info.attr_dict
    self.lover_name_text.text = self.cur_lover_data.name
    UIFuncs.AssignSpriteByIconID(self.lover_quality_data.grade, self.lover_grade)
    for i = 1, self.star_limit do
        self.lover_active_star_list[i]:SetActive(i <= self.lover_info.star_lv)
    end
    self.describe_text.text = self.cur_lover_data.introduce_text
    self.ceremony_num_text.text = string.format(UIConst.Text.CEREMONY_FORMAL, attr_dict.etiquette)
    self.culture_num_text.text = string.format(UIConst.Text.CULTURE_FORMAL, attr_dict.culture)
    self.charm_num_text.text = string.format(UIConst.Text.CHARM_FORMAL, attr_dict.charm)
    self.plan_attr_text.text = string.format(UIConst.Text.PLAN_FORMAL, attr_dict.planning)

    self.award_frame_ceremony_num_text.text = string.format(UIConst.Text.CEREMONY_FORMAL, attr_dict.etiquette)
    self.award_frame_culture_num_text.text = string.format(UIConst.Text.CULTURE_FORMAL, attr_dict.culture)
    self.award_frame_charm_num_text.text = string.format(UIConst.Text.CHARM_FORMAL, attr_dict.charm)
    self.award_frame_plan_attr_text.text = string.format(UIConst.Text.PLAN_FORMAL, attr_dict.planning)
end

--  更新中间面板
function LoverDetailUI:UpdateMiddlePropertyFrame()
    local power_name = self.data_mgr:GetPowerData(self.cur_lover_data.power).name
    self.power_name_text.text = power_name
    self.child_num_text.text = self.lover_info.children
end

function LoverDetailUI:UpdateLoverInfo(need_anim)
    local attr_dict = self.lover_info.attr_dict
    local total_attribute = self.lover_data:GetLoverAllAttr(self.lover_id)
    local cur_level_need_exp = self.data_mgr:GetLoverLevelData(self.lover_info.level).exp
    local grade = self.lover_info.grade
    local real_exp = self.lover_info.exp - cur_level_need_exp

    local fill_amount = 0
    local slider_text
    if self.lover_info.level < self.max_level then
        local upgrade_need_exp = self.data_mgr:GetLoverLevelData(self.lover_info.level + 1).exp - self.data_mgr:GetLoverLevelData(self.lover_info.level).exp
        fill_amount = real_exp / upgrade_need_exp
        slider_text = string.format(UIConst.Text.SPRIT, real_exp, upgrade_need_exp)
    else
        fill_amount = 1
        slider_text = UIConst.Text.MAX_TEXT
    end
    if need_anim then
        local old_level = tonumber(self.intimacy_level_text.text)
        local fill_time = self.lover_info.level - old_level
        fill_time = math.clamp(fill_time, 0, 1)
        self.slider_anim:SetTargetVal(fill_amount, fill_time)
        if self.can_create_send_gift_effect then
            local param_tb = {
                effect_id = self.send_gift_effect_id,
                life_time = 1,
            }
            self:AddUIEffect(self.effect_point, param_tb)
            self.can_create_send_gift_effect = false
            self:AddTimer(function()
                self.can_create_send_gift_effect = true
            end, create_effect_interval, 1)
        end
    end
    self.intimacy_slider_image.fillAmount = fill_amount
    self.intimacy_slider_text.text = slider_text
    self.power_point_text.text = self.lover_info.power_value
    self.total_attribute_text.text = total_attribute
    self.intimacy_level_text.text = self.lover_info.level
end

function LoverDetailUI:ShowOrHideAwardUI(is_show)
    self.award_frame:SetActive(is_show)
    self.award_button_parent:SetActive(is_show)

    -- self.dressing_button:SetActive(not is_show)
    -- self.reincarnation_btn:SetActive(not is_show)
    self.lover_attr:SetActive(not is_show)
    self.power_button:SetActive(not is_show)
    self.award_button:SetActive(not is_show)
    self.spoil_button:SetActive(not is_show)
end

function LoverDetailUI:SelectAwardButton(btn, index)
    if not IsNil(self.award_select_btn) then
        self.award_select_btn:FindChild("SelectImage"):SetActive(true)
    end
    self.award_select_btn = btn
    self.award_select_btn:FindChild("SelectImage"):SetActive(false)

    local attr = self.index_Attribute[index]
    local item_list = self.data_mgr:GetAttributeItemData(attr).item_list
    self.cur_select_item_list = item_list
    for i, v in ipairs(self.award_item_list) do
        local item_id = item_list[i]
        local award_obj = v
        local attr_value = 0
        local item = self.data_mgr:GetItemData(item_id)
        award_obj:FindChild("AwardObjName"):GetComponent("Text").text = item.name
        local str
        if attr == self.index_Attribute[1] then
            attr_value = item.add_exp
            str = string.format(UIConst.Text.ATTR_ADD_FORMAT, UIConst.Text.LOVER_DETAIL_INTIMACY_EXP_TEXT, attr_value or 0)
        else
            local name = self.data_mgr:GetAttributeData(item.add_attr).name
            attr_value = item.attr_value
            str = string.format(UIConst.Text.ATTR_ADD_FORMAT, name, attr_value or 0)
        end
        UIFuncs.AssignSpriteByIconID(item.icon, award_obj:FindChild("IconImage"):GetComponent("Image"))
        award_obj:FindChild("AwardObjAttr"):GetComponent("Text").text = str
        UIFuncs.RegisterUpdateItemNum(self, "LoverDetailUIAward" .. i, award_obj:FindChild("ObjNumText"):GetComponent("Text"), item_id)
        local btn = award_obj:FindChild("TriggerButton")
        self:RemoveClick(btn)

        local resp_cb = function(resp)
            local pos = UIFuncs.GetGoPositionV2(self, award_obj:FindChild("IconImage"))
            local attr_add_val = attr_value or 0
            if self.is_give_ten then
                local num = math.abs(self.last_item_num - ItemUtil.GetItemNum(item_id))
                attr_add_val = attr_add_val * num
            end
            self:ShowGiveGiftAnim(item_id, pos, attr, attr_add_val)
        end
        self:AddClick(btn, function()
            if attr == self.index_Attribute[1] then
                if self.lover_info.level >= #self.data_mgr:GetAllLoverLevelData() then
                    SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.CAN_NOT_ADD_LOVER_EXP_TEXT)
                    return
                end
            end
            if UIFuncs.CheckItemCount(item.id, 1, true) then
                self.last_item_num = ItemUtil.GetItemNum(item.id)
                self.is_give_ten = self.award_ten_time_toggle.isOn
                self.is_give_gift = true
                SpecMgrs.msg_mgr:SendGiveLoverItem({lover_id = self.lover_id, item_id = item.id, is_ten = self.is_give_ten}, resp_cb)
            end
        end)
    end
end

function LoverDetailUI:ShowGiveGiftAnim(item_id, pos, attr, attr_add_val)
    local item = self:GetUIObject(self.gift_anim, self.main_panel)
    UIFuncs.AssignSpriteByItemID(item_id, item:GetComponent("Image"))
    item:GetComponent("RectTransform").anchoredPosition = pos

    local pos_anim = item:GetComponent("UITweenPosition")
    pos_anim.from_ = pos
    pos_anim:Play()
    local alpha_anim = item:GetComponent("UITweenAlpha")
    local delay_time = alpha_anim.duration_ + alpha_anim.delay_time_
    self:AddTimer(function()
        self:DelUIObject(item)
        local str
        if attr == self.index_Attribute[1] then
            str = string.format(UIConst.Text.ATTR_ADD_FORMAT, UIConst.Text.LOVER_DETAIL_INTIMACY_EXP_TEXT, attr_add_val)
        else
            local name = self.data_mgr:GetAttributeData(attr).name
            str = string.format(UIConst.Text.ATTR_ADD_FORMAT, name, attr_add_val)
        end
        SpecMgrs.ui_mgr:ShowTipMsg(str)
        self:UpdateLoverInfo(true)
        self.is_give_gift = false
    end, delay_time, 1)
end

function LoverDetailUI:ClearCreateRes()
    self:RemoveUIEffect(self.spoil_button, nil, true)
    self:RemoveUIEffect(self.effect_point, nil, true)
    self:DestroyAllUnit()
    local spoil_confirm_ui = SpecMgrs.ui_mgr:GetUI("SpoilConfirmUI")
    if spoil_confirm_ui then
        spoil_confirm_ui:UnregisterCloseUI("LoverDetailUI")
    end
    self.lover_data:UnregisterUpdateLoverInfoEvent("LoverDetailUI")
    if self.cur_select_item_list then
        for i = 1, self.award_ui_num do
            UIFuncs.UnregisterUpdateItemNum(self, "LoverDetailUIAward" .. i, self.cur_select_item_list[i])
        end
    end
end

function LoverDetailUI:Hide()
    self:ClearCreateRes()
    SpecMgrs.redpoint_mgr:RemoveRedPoint(self.power_redpoint)
    SpecMgrs.redpoint_mgr:RemoveRedPoint(self.star_redpoint)
    LoverDetailUI.super.Hide(self)
end

return LoverDetailUI
