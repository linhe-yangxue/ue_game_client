local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local PrisonUI = class("UI.PrisonUI",UIBase)
local UnitConst = require("Unit.UnitConst")
local SoundConst = require("Sound.SoundConst")
local UIFuncs = require("UI.UIFuncs")

PrisonUI.need_sync_load = true

local panel_key_map = {
    initial_panel = "PrisonInitialPanel",
    detial_panel = "CriminalDetilPanel",
    tip_panel = "CriminalTipPanel",
}

local panel_hide_func_map ={
    PrisonInitialPanel = "Hide",
    CriminalDetilPanel = "HideCriminalDetilPanel",
    CriminalTipPanel = "HideCriminalTipPanel",
}

local torture_type_map = {
    fist = 1, -- 普通拳击拷问
}
local anim_type_map = {
    unit = 1,
    animator = 2,
}

local scale_map = {
    normal_scale = 0.8,
    cur_scale = 0.9,
}
local kDefaultUnitAnimName = "animation"
local kPercent = 100

function PrisonUI:DoInit()
    PrisonUI.super.DoInit(self)
    self.prefab_path = "UI/Common/PrisonUI"
    self.dy_prison_data = ComMgrs.dy_data_mgr.prison_data
    self.criminal_data_list = SpecMgrs.data_mgr:GetAllPrisonData()
    self.is_one_key_torture = false
    self.torture_data_list = SpecMgrs.data_mgr:GetAllTortureData()
    self.square_mask_material = SpecMgrs.res_mgr:GetMaterialSync(UIConst.MaterialResPath.UISquareMask)
    self.square_mask_gray_material = SpecMgrs.res_mgr:GetMaterialSync(UIConst.MaterialResPath.UISquareMaskGray)
    self.max_prestige_trans_rate = SpecMgrs.data_mgr:GetParamData("max_prestige_trans_rate").f_value
    self.torture_selected_go_list = {}
end

function PrisonUI:OnGoLoadedOk(res_go)
    PrisonUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function PrisonUI:Show()
    local serv_criminal_data = self.dy_prison_data:GetPrisonData()
    for k, v in pairs(serv_criminal_data) do
        self[k] = v
    end
    local already_res_ok = self.is_res_ok
    PrisonUI.super.Show(self)
    if already_res_ok then
        self:InitUI()
    end
end

function PrisonUI:InitRes()
    local panel_list = self.main_panel:FindChild("PanelList")
    for k, panel_name in pairs(panel_key_map) do
        local panel = panel_list:FindChild(panel_name)
        self[k] = panel
        self:_InitCloseClickFunc(panel, panel_name)
        local top_bar = panel:FindChild("TopBar")
        if top_bar then
            UIFuncs.InitTopBar(self, top_bar, panel_name)
        end
    end
    --initial_panel 以下 ip
    self.ip_criminal_item_parent = self.initial_panel:FindChild("MiddlePart/Scroll View/Viewport/Content")
    self.ip_criminal_item_temp = self.ip_criminal_item_parent:FindChild("Item")
    self.ip_criminal_item_width = self.ip_criminal_item_temp:GetComponent("RectTransform").sizeDelta.x
    self.ip_criminal_item_temp:SetActive(false)
    self.ip_criminal_item_comp_list = {}
    for i, criminal_data in ipairs(self.criminal_data_list) do
        local item = self:GetUIObject(self.ip_criminal_item_temp, self.ip_criminal_item_parent)
        self.ip_criminal_item_comp_list[i] = {}
        self.ip_criminal_item_comp_list[i].item = item
        item:FindChild("Name"):GetComponent("Text").text = criminal_data.name
        self.ip_criminal_item_comp_list[i].icon_image = item:FindChild("Icon"):GetComponent("Image")
        self.ip_criminal_item_comp_list[i].red_cross = item:FindChild("RedCross")
        self.ip_criminal_item_comp_list[i].name_go = item:FindChild("Name")
        self.ip_criminal_item_comp_list[i].check_detial = item:FindChild("CheckDetail")
        self:AddClick(item, function ()
            if i <= self.criminal_num then
                self:ShowCriminalDetailPanel(i)
            end
        end)
    end
    self.hor_layout = self.ip_criminal_item_parent:GetComponent("HorizontalLayoutGroup")
    self.layout = self.ip_criminal_item_parent:GetComponent("ContentSizeFitter")
    self.criminal_scroll_rect = self.initial_panel:FindChild("MiddlePart/Scroll View"):GetComponent("ScrollRect")
    self.content_rect = self.ip_criminal_item_parent:GetComponent("RectTransform")
    self.ori_content_pos = self.content_rect.anchoredPosition
    self.view_rect = self.initial_panel:FindChild("MiddlePart/Scroll View/Viewport"):GetComponent("RectTransform")

    self.initial_panel:FindChild("BottonBar/Tip"):GetComponent("Text").text = UIConst.Text.PRISON_TIP1
    self.talk_go = self.initial_panel:FindChild("MiddlePart/Talk")
    self.talk_text = self.talk_go:FindChild("Text"):GetComponent("Text")
    self.talk_scale_anim = self.initial_panel:FindChild("MiddlePart/Talk"):GetComponent("EffectScaleAnim")
    self.ip_cur_prestige_text = self.initial_panel:FindChild("BottonBar/Prestige"):GetComponent("Text")
    self.ip_prestige_daily_output_text = self.initial_panel:FindChild("BottonBar/PrestigeDailyOutput"):GetComponent("Text")
    self.ip_spirit_text = self.initial_panel:FindChild("BottonBar/SpiritValue/Fill Area/Text"):GetComponent("Text")
    self.ip_spirit_slider = self.initial_panel:FindChild("BottonBar/SpiritValue"):GetComponent("Slider")
    self.ip_one_key_torture_toggle = self.initial_panel:FindChild("MiddlePart/OneKeyBeat"):GetComponent("Toggle")
    self.ip_one_key_torture_toggle.isOn = self.is_one_key_torture
    self:AddToggle(self.ip_one_key_torture_toggle.gameObject, function ()
        self.is_one_key_torture = self.ip_one_key_torture_toggle.isOn
    end)
    self.ip_cur_criminal = self.initial_panel:FindChild("MiddlePart/CriminalModel")
    self:AddClick(self.ip_cur_criminal, function ()
        self:TortureBtnOnClick()
    end, SoundConst.SoundID.SID_NotPlaySound)
    local torture_btn_parent = self.initial_panel:FindChild("MiddlePart/TortureBtnList")
    local torture_btn_temp = torture_btn_parent:FindChild("Item")
    torture_btn_temp:SetActive(false)
    for i, torture_data in ipairs(self.torture_data_list) do
        local item = self:GetUIObject(torture_btn_temp, torture_btn_parent)
        item.name = "torture_" .. i
        self:AssignSpriteByIconID(torture_data.icon, item:FindChild("Image"):GetComponent("Image"))
        self.torture_selected_go_list[i] = item:FindChild("Image/Selected")
        self:AddClick(item, function ()
            self:SwitchTortureData(torture_data)
        end)
    end
    self:SwitchTortureData(self.torture_data_list[1])
    self:AddClick(self.initial_panel:FindChild("TopBar/HelpBtn"), function()
        UIFuncs.ShowPanelHelp("PrisonInitialPanel")
    end)
    self.ip_criminal_unit_parent = self.initial_panel:FindChild("MiddlePart/UnitParent")
    self.ip_torture_anim_unit_parent = self.initial_panel:FindChild("MiddlePart/TortureUnitParent")
    self.next_btn =self.initial_panel:FindChild("MiddlePart/NextBtn")
    self:AddClick(self.next_btn, function ()
        self.next_btn:SetActive(false)
        self:ShowCriminalTipPanel()
    end)
    --detial_panel 以下 dp
    local criminal_detial = self.detial_panel:FindChild("Content/CriminalDetil")
    self.dp_criminal_unit_parent = self.detial_panel:FindChild("Content/CriminalDetil/UnitParent")
    self.detial_panel:FindChild("Content/Top/Title"):GetComponent("Text").text = UIConst.Text.CIRMINAL_DETAIL
    self.dp_criminal_name_text = criminal_detial:FindChild("Name"):GetComponent("Text")
    self.dp_criminal_icon_image = criminal_detial:FindChild("Icon/Image"):GetComponent("Image")
    self.dp_torture_cost_text = criminal_detial:FindChild("Name/TortureCost"):GetComponent("Text")
    self.dp_torture_num_text = criminal_detial:FindChild("Name/TotureNum"):GetComponent("Text")
    self.dp_drop_text = self.detial_panel:FindChild("Content/BottonBar/Drop"):GetComponent("Text")
    --tip_panel 以下 tp
    local content = self.tip_panel:FindChild("Content")
    self.tip_panel:FindChild("Content/Top/Title"):GetComponent("Text").text = UIConst.Text.CIRMINAL_SHOW
    self.tp_criminal_icon_image = content:FindChild("Criminal/Icon/Image"):GetComponent("Image")
    self.tp_criminal_unit_parent = content:FindChild("Criminal/UnitParent")
    self.tp_description_text = content:FindChild("BottonBar/Description"):GetComponent("Text")
end

function PrisonUI:_InitCloseClickFunc(panel, panel_name)
    local hide_func = self:GetHidePanelFunc(panel_name)
    local click_cb  = function ()
        hide_func(self)
    end
    local close_bg = panel:FindChild("CloseBg")
    if close_bg then
        self:AddClick(close_bg, click_cb)
    end
    local close_btn = panel:FindChild("Content/Top/CloseBtn")
    if close_btn then
        self:AddClick(close_btn, click_cb)
    end
end

function PrisonUI:GetHidePanelFunc(panel_name)
    return self[panel_hide_func_map[panel_name]]
end

function PrisonUI:ChangeTalk(is_hurt)
    local criminal_data = self.criminal_data_list[self.criminal_id]
    local talk_list = is_hurt and criminal_data.hurt_talk_list or criminal_data.normal_talk_list
    local index = math.random(1, #talk_list)
    self.talk_text.text = talk_list[index]
    if is_hurt then
        self.talk_scale_anim.enabled = true
        local time = self.talk_scale_anim.time_
        self:AddTimer(function ()
            self.talk_scale_anim.enabled = false
        end, time, 1)
    end
end

function PrisonUI:SetCriminal(is_show)
    self.ip_criminal_unit_parent:SetActive(is_show)
    self.talk_text.gameObject:SetActive(is_show)
end

function PrisonUI:InitUI()
    self:PlayBGM(SoundConst.SOUND_ID_Prison)
    self:RegisterEvent(self.dy_prison_data, "UpdatePrisonData", function(_, msg)
        if msg.criminal_id and self.criminal_id < msg.criminal_id then -- 当前罪犯拷问完了
            local old_criminal_id = self.criminal_id
            self.criminal_id = msg.criminal_id
            self:_UpdateCriminalItem(old_criminal_id)
            self:_UpdateCriminalItem(self.criminal_id)
            self:SetCriminal(false)
            self:_UpdateTortureNum(0) -- 弹出更换下个罪犯时血量置为0
            self.torture_remain_num = msg.torture_remain_num
            self.next_btn:SetActive(true)
            self.talk_go:SetActive(false)
        elseif msg.torture_remain_num then
            self.torture_remain_num = msg.torture_remain_num
            self:_UpdateTortureNum()
        end
    end)
    self:RegisterEvent(ComMgrs.dy_data_mgr, "UpdateCurrencyEvent",function (_, currency)
        if currency[CSConst.Virtual.Prestige] then
            local cur_prestige = currency[CSConst.Virtual.Prestige]
            self:_UpdatePrestige(cur_prestige)
        end
    end)
    self.next_btn:SetActive(false)
    self:_UpdateInitialPanel()
    self:SliderToCriminal(self.criminal_id)
    if not self.is_first_open then
        self:ShowCriminalTipPanel()
        self.is_first_open = true
    end
end

function PrisonUI:SliderToCriminal(criminal_id)
    self:AddTimer(function ()
        if not self.is_res_ok then return end
        local x = (self.hor_layout.spacing + self.ip_criminal_item_width) * (criminal_id - 1)
        local max_x = self.content_rect.rect.width - self.view_rect.rect.width
        x = math.min(x, max_x)
        self.content_rect.anchoredPosition = Vector2.New(self.ori_content_pos.x - x, self.ori_content_pos.y)
    end, 0.01)
end

function PrisonUI:_UpdateInitialPanel()
    self:_UpdateAllCriminalItem()
    self:SetCriminal(true)
    self:_UpdateCriminalUnit()
    self:_UpdateTortureNum()
    self:_UpdateMaxPrestige()
    self:_UpdatePrestige()
    self.ip_one_key_torture_toggle.isOn = self.is_one_key_torture
end

function PrisonUI:_UpdateAllCriminalItem()
    for criminal_id, _ in ipairs(self.criminal_data_list) do
        self:_UpdateCriminalItem(criminal_id)
    end
end

function PrisonUI:_UpdateCriminalUnit()
    if not self.is_res_ok then return end
    local unit_id = self.criminal_data_list[self.criminal_id].unit_id
    self:CleanCriminalUnit()
    self.criminal_unit = self:AddFullUnit(unit_id, self.ip_criminal_unit_parent)
end

function PrisonUI:CleanCriminalUnit()
    self:ClearUnit("criminal_unit")
end

function PrisonUI:_UpdateCriminalItem(criminal_id)
    local item_comp_list = self.ip_criminal_item_comp_list[criminal_id]
    local icon_id = self.criminal_num < criminal_id and UIConst.Icon.SecretHeadCircle
    if self.criminal_num < criminal_id then
        icon_id = UIConst.Icon.SecretHeadCircle
    else
        local unit_id = self.criminal_data_list[criminal_id].hero_unit_id
        icon_id = SpecMgrs.data_mgr:GetUnitData(unit_id).icon
    end
    self:AssignSpriteByIconID(icon_id, item_comp_list.icon_image)
    if (self.criminal_id == criminal_id and self.torture_remain_num <= 0) or self.criminal_id > criminal_id then
        item_comp_list.red_cross:SetActive(true)
        item_comp_list.icon_image.material = self.square_mask_gray_material
    else
        item_comp_list.red_cross:SetActive(false)
        item_comp_list.icon_image.material = self.square_mask_material
    end
    local is_cur_criminal = criminal_id == self.criminal_id
    item_comp_list.check_detial:SetActive(is_cur_criminal)

    item_comp_list.name_go:SetActive(is_cur_criminal)
    item_comp_list.item.localScale = Vector3.one * (is_cur_criminal and scale_map.cur_scale or scale_map.normal_scale)
end

function PrisonUI:_UpdatePrestige(cur_prestige)
    local cur_prestige = cur_prestige or ComMgrs.dy_data_mgr:ExGetCurrencyCount(CSConst.Virtual.Prestige) or 0
    self.ip_cur_prestige_text.text = string.format(UIConst.Text.CUR_PRESTIGE, cur_prestige, self.max_prestige)
end

function PrisonUI:_UpdateMaxPrestige()
    local cur_stage = ComMgrs.dy_data_mgr.strategy_map_data:GetLastStage()
    local stage_data =  SpecMgrs.data_mgr:GetStageData(cur_stage)
    local daily_output_prestige = SpecMgrs.data_mgr:GetStageData(cur_stage).prestige_count
    self.max_prestige = self.max_prestige_trans_rate * daily_output_prestige
    self.ip_prestige_daily_output_text.text = string.format(UIConst.Text.DAILY_OUTPUT, daily_output_prestige)
end

function PrisonUI:_UpdateTortureNum(torture_remain_num)
    if not self.criminal_id then return end
    local torture_remain_num = torture_remain_num or self.torture_remain_num
    local spirit_value = torture_remain_num / self.criminal_data_list[self.criminal_id].max_torture_num
    self.ip_spirit_slider.value = spirit_value
    local spirit_value = spirit_value > 0 and math.max(1, math.floor(spirit_value * kPercent)) or 0
    self.ip_spirit_text.text = string.format(UIConst.Text.SPIRIT_VALUE, spirit_value)
    if torture_remain_num <= 0 then
        self:_UpdateCriminalItem(self.criminal_id)
    end
end

function PrisonUI:Hide()
    SpecMgrs.sound_mgr:RemoveBGM()
    self:ClearUnit("dp_unit")
    self:ClearUnit("tp_unit")
    self:ClearUnit("criminal_unit")
    self:CleanTortureUnit()
    self:DestroyAllTimer()
    self.torture_criminal_id = nil
    PrisonUI.super.Hide(self)
end

----Initial_panel
function PrisonUI:TortureBtnOnClick()
    if self.torture_criminal_id then return end
    if not self.torture_data then return end
    if not self.torture_remain_num or self.torture_remain_num <= 0 then
        SpecMgrs.ui_mgr:ShowTipMsg(string.format(UIConst.Text.TORTURE_ENOUGH))
        return
    end
    local torture_data = self.torture_data
    local torture_num, not_enought_item_id = self.dy_prison_data:GetTortureNum(torture_data)
    torture_num = self.is_one_key_torture and torture_num or 1
    if not_enought_item_id then
        local item_name = SpecMgrs.data_mgr:GetItemData(not_enought_item_id).name
        SpecMgrs.ui_mgr:ShowTipMsg(string.format(UIConst.Text.ITEM_COUNT_NOT_ENOUGH, item_name))
    elseif torture_data.id ~= torture_type_map.fist then
        -- todo 显示消耗道具面版
        self:SendTorture(torture_data.id, torture_num)
    else
        self:SendTorture(torture_data.id, torture_num)
    end
end

function PrisonUI:SwitchTortureData(torture_data)
    if not torture_data then return end
    if self.torture_data then
        self.torture_selected_go_list[self.torture_data.id]:SetActive(false)
    end
    self.torture_data = torture_data
    self.torture_selected_go_list[self.torture_data.id]:SetActive(true)
end

function PrisonUI:SendTorture(torture_type, torture_num)
    if self.torture_criminal_id then return end
    self.torture_criminal_id = self.criminal_id
    SpecMgrs.msg_mgr:SendPrisonTorture({torture_type = torture_type, torture_num = torture_num}, function (resp)
        if resp.errcode == 0 then
            self:StartTorture(torture_type)
        else
            PrintError("request fail in torture criminal", torture_type, torture_num)
            self.torture_criminal_id = nil
        end
    end)
end

function PrisonUI:StartTorture(torture_type)
    self:CleanTortureUnit()
    local torture_data = self.torture_data_list[torture_type]
    local torture_anim_type = torture_data.anim_type or anim_type_map.unit
    if torture_anim_type == anim_type_map.unit then
        local unit_id = torture_data.unit_id
        self.torture_anim_unit = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = unit_id, parent = self.ip_torture_anim_unit_parent, need_sync_load = true})
        local torture_anim_time = self.torture_anim_unit:PlayAnim(kDefaultUnitAnimName)
        self:PlayTortureSound(torture_type)
        self:AddStartPrisonPlayHitAnimTimer(torture_data.delay_paly_hit)
        self:AddDestroyTortureUnitTimer(torture_anim_time)
    else
        -- 待定
    end
end

function PrisonUI:PlayTortureSound(torture_type)
    local sound_id = self.torture_data_list[torture_type].sound_id
    self:PlayUISound(sound_id)
end

function PrisonUI:AddStartPrisonPlayHitAnimTimer(time)
    if self.play_hit_anim_timer then return end
    self.play_hit_anim_timer = self:AddTimer(function ()
        if self.criminal_unit then
            self:PlayCriminalScreechSound(self.torture_criminal_id)
            self.criminal_unit:PlayAnim("hit",false)
            self:ChangeTalk(true)
        end
        self.play_hit_anim_timer = nil
    end, time, 1)
end

function PrisonUI:PlayCriminalScreechSound(prison_id)
    local sound_id = SpecMgrs.data_mgr:GetPrisonData(prison_id).screech_sound_id
    self:PlayUISound(sound_id)
end

function PrisonUI:AddDestroyTortureUnitTimer(time)
    if self.destroy_torture_unit_timer then return end
    self.destroy_torture_unit_timer = self:AddTimer(function ()
        self:CleanTortureUnit()
        self.destroy_torture_unit_timer = nil
        self.torture_criminal_id = nil
    end, time, 1)
end

function PrisonUI:CleanTortureUnit()
    if self.torture_anim_unit then
        ComMgrs.unit_mgr:DestroyUnit(self.torture_anim_unit)
        self.torture_anim_unit = nil
    end
end

function PrisonUI:DestroyAllTimer()
    if self.play_hit_anim_timer then
        SpecMgrs.timer_mgr:RemoveTimer(self.play_hit_anim_timer)
        self.play_hit_anim_timer = nil
    end
    if self.destroy_torture_unit_timer then
        SpecMgrs.timer_mgr:RemoveTimer(self.destroy_torture_unit_timer)
        self.destroy_torture_unit_timer = nil
    end
end

----Initial_panel end

----detil_panel

function PrisonUI:ShowCriminalDetailPanel(criminal_id)
    local criminal_data = self.criminal_data_list[criminal_id]
    self.dp_unit = self:AddHalfUnit(criminal_data.hero_unit_id, self.dp_criminal_unit_parent)
    self.dp_criminal_name_text.text = criminal_data.name
    self.dp_torture_cost_text.text = string.format(UIConst.Text.TORTURE_COST, criminal_data.prestige_cost)
    self.dp_torture_num_text.text = string.format(UIConst.Text.MAX_TORTURE_NUM, criminal_data.max_torture_num)
    self.dp_drop_text.text = criminal_data.drop_str
    self.show_criminal_detail_id = criminal_id
    self.detial_panel:SetActive(true)
end

function PrisonUI:HideCriminalDetilPanel()
    self:ClearUnit("dp_unit")
    self.detial_panel:SetActive(false)
end

----detil_panel end

----tip_panel
function PrisonUI:ShowCriminalTipPanel()
    if not self.torture_remain_num or self.torture_remain_num <= 0 then return end
    local criminal_data = self.criminal_data_list[self.criminal_id]
    self.tp_unit = self:AddHalfUnit(criminal_data.hero_unit_id, self.tp_criminal_unit_parent  )
    self.tp_description_text.text = string.format(UIConst.Text.PRISON_TIP, criminal_data.name)
    self.tip_panel:SetActive(true)
end

function PrisonUI:HideCriminalTipPanel()
    self:ClearUnit("tp_unit")
    self:_UpdateTortureNum()
    self.talk_go:SetActive(true)
    self:SetCriminal(true)
    self:_UpdateCriminalUnit()
    self:ChangeTalk()
    self:SliderToCriminal(self.criminal_id)
    self.tip_panel:SetActive(false)
end
----tip_panel end
return PrisonUI