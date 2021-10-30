local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local UnitConst = require("Unit.UnitConst")
local CSFunction = require("CSCommon.CSFunction")

local PlayerInfoUI = class("UI.PlayerInfoUI", UIBase)

local kFadeOutDuration = 5

function PlayerInfoUI:DoInit()
    PlayerInfoUI.super.DoInit(self)
    self.prefab_path = "UI/Common/PlayerInfoUI"
    self.rename_cost_data = SpecMgrs.data_mgr:GetParamData("modify_role_name_cost")
    self.dy_dynasty_data = ComMgrs.dy_data_mgr.dynasty_data
    self.cost_value_data_dict = {}
    self.cost_value_timer_dict = {}
    self.is_expand_setting = false
end

function PlayerInfoUI:OnGoLoadedOk(res_go)
    PlayerInfoUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function PlayerInfoUI:Hide()
    self:UpdateSettingContent(false)
    self:RemovePlayerUnit()
    PlayerInfoUI.super.Hide(self)
end

function PlayerInfoUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    PlayerInfoUI.super.Show(self)
end

function PlayerInfoUI:InitRes()
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "PlayerInfoUI")
    local info_panel = self.main_panel:FindChild("InfoPanel")
    self.role_model = info_panel:FindChild("PlayerModel")
    self.score = info_panel:FindChild("Score/Value"):GetComponent("Text")
    self.fight_score = info_panel:FindChild("CE/Value"):GetComponent("Text")
    local info_content = info_panel:FindChild("Info")
    local setting_btn = info_panel:FindChild("SettingBtn")
    self.flag_image = self.main_panel:FindChild("InfoPanel/Flag/FlagIcon"):GetComponent("Image")
    setting_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ROLE_SETTING_TEXT
    self:AddClick(setting_btn, function ()
        self:UpdateSettingContent(not self.is_expand_setting)
    end)
    self.setting_content = info_panel:FindChild("SettingContent")
    self.close_setting_mask = info_panel:FindChild("CloseSettingMask")
    self:AddClick(self.close_setting_mask, function ()
        self:UpdateSettingContent(false)
    end)
    local change_flag_btn = self.setting_content:FindChild("ChangeFlag")
    change_flag_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CHANGE_FLAG_TEXT
    self:AddClick(change_flag_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("ChangeFlagUI")
        self:UpdateSettingContent(false)
    end)

    local change_role_btn = self.setting_content:FindChild("ChangeRole")
    change_role_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CHANGE_ROLE_TEXT
    self:AddClick(change_role_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("ChangeRoleUI")
        self:UpdateSettingContent(false)
    end)
    local change_name_btn = self.setting_content:FindChild("ChangeName")
    change_name_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CHANGE_NAME_TEXT
    self:AddClick(change_name_btn, function ()
        self.rename_input.text = ""
        self.rename_panel:SetActive(true)
        self:UpdateSettingContent(false)
    end)
    local change_title_btn = self.setting_content:FindChild("ChangeTitle")
    change_title_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CHANGE_TITLE_TEXT
    self:AddClick(change_title_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("TitleUI")
        self:UpdateSettingContent(false)
    end)
    self.name = info_content:FindChild("Name/Text"):GetComponent("Text")
    self.vip = info_content:FindChild("Name/Vip")
    info_content:FindChild("ID/Text"):GetComponent("Text").text = string.format(UIConst.Text.ROLE_UUID_TEXT, ComMgrs.dy_data_mgr:ExGetRoleUuid())
    self.title = info_content:FindChild("Title")

    self.vip_img = self.vip:GetComponent("Image")
    self.dynasty = info_content:FindChild("Dynasty"):GetComponent("Text")
    self.level = info_content:FindChild("Level"):GetComponent("Text")
    local exp_panel = info_content:FindChild("ExpPanel")
    exp_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.EXP_TEXT
    self.role_exp_value = exp_panel:FindChild("ExpBar/Exp"):GetComponent("Image")
    self.role_exp_text = exp_panel:FindChild("ExpBar/Text"):GetComponent("Text")

    local action_point_data = {}
    local action_point_panel = info_content:FindChild("ActionPoint")
    action_point_panel:FindChild("Text"):GetComponent("Text").text = SpecMgrs.data_mgr:GetItemData(CSConst.CostValueItem.ActionPoint).name
    local action_point_count = action_point_panel:FindChild("Count")
    action_point_data.count = action_point_count
    action_point_data.count_text = action_point_count:GetComponent("Text")
    action_point_data.count_text = action_point_count:GetComponent("Text")
    action_point_data.count_anim_cmp = action_point_count:GetComponent("UITweenAlpha")
    local action_point_count_down = action_point_panel:FindChild("CountDown")
    action_point_data.count_down = action_point_count_down
    action_point_data.count_down_text = action_point_count_down:GetComponent("Text")
    self.cost_value_data_dict[CSConst.CostValueItem.ActionPoint] = action_point_data

    local energy_data = {}
    local energy_panel = info_content:FindChild("Energy")
    energy_panel:FindChild("Text"):GetComponent("Text").text = SpecMgrs.data_mgr:GetItemData(CSConst.CostValueItem.Vigor).name
    local energy_count = energy_panel:FindChild("Count")
    energy_data.count = energy_count
    energy_data.count_text = energy_count:GetComponent("Text")
    energy_data.count_text = energy_count:GetComponent("Text")
    energy_data.count_anim_cmp = energy_count:GetComponent("UITweenAlpha")
    local energy_count_down = energy_panel:FindChild("CountDown")
    energy_data.count_down = energy_count_down
    energy_data.count_down_text = energy_count_down:GetComponent("Text")
    self.cost_value_data_dict[CSConst.CostValueItem.Vigor] = energy_data

    local excitement_data = {}
    local excitement_panel = info_content:FindChild("Excitement")
    excitement_panel:FindChild("Text"):GetComponent("Text").text = SpecMgrs.data_mgr:GetItemData(CSConst.CostValueItem.Vitality).name
    local excitement_count = excitement_panel:FindChild("Count")
    excitement_data.count = excitement_count
    excitement_data.count_text = excitement_count:GetComponent("Text")
    excitement_data.count_text = excitement_count:GetComponent("Text")
    excitement_data.count_anim_cmp = excitement_count:GetComponent("UITweenAlpha")
    local excitement_count_down = excitement_panel:FindChild("CountDown")
    excitement_data.count_down = excitement_count_down
    excitement_data.count_down_text = excitement_count_down:GetComponent("Text")
    self.cost_value_data_dict[CSConst.CostValueItem.Vitality] = excitement_data

    local strength_data = {}
    local strength_panel = info_content:FindChild("Strength")
    strength_panel:FindChild("Text"):GetComponent("Text").text = SpecMgrs.data_mgr:GetItemData(CSConst.CostValueItem.PhysicalPower).name
    local strength_count = strength_panel:FindChild("Count")
    strength_data.count = strength_count
    strength_data.count_text = strength_count:GetComponent("Text")
    strength_data.count_text = strength_count:GetComponent("Text")
    strength_data.count_anim_cmp = strength_count:GetComponent("UITweenAlpha")
    local strength_count_down = strength_panel:FindChild("CountDown")
    strength_data.count_down = strength_count_down
    strength_data.count_down_text = strength_count_down:GetComponent("Text")
    self.cost_value_data_dict[CSConst.CostValueItem.PhysicalPower] = strength_data

    local bottom_panel = self.main_panel:FindChild("BottomPanel")
    self:AddClick(bottom_panel, function ()
        SpecMgrs.ui_mgr:ShowUI("PlayerDetailInfoUI")
        self:UpdateSettingContent(false)
    end)

    self.rename_panel = self.main_panel:FindChild("RenamePanel")
    local rename_content = self.rename_panel:FindChild("Content")
    rename_content:FindChild("Title"):GetComponent("Text").text = UIConst.Text.CHANGE_NAME_TEXT
    self:AddClick(rename_content:FindChild("CloseBtn"), function ()
        self.rename_panel:SetActive(false)
    end)
    rename_content:FindChild("Consumption/Text"):GetComponent("Text").text = UIConst.Text.RENAME_COST_TIP
    self.rename_cost_count = rename_content:FindChild("Consumption/Count"):GetComponent("Text")
    self.rename_input = rename_content:FindChild("RenameInput"):GetComponent("InputField")
    local btn_panel = rename_content:FindChild("BtnPanel")
    local cancel_btn = btn_panel:FindChild("RenameCancel")
    cancel_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CANCEL
    self:AddClick(cancel_btn, function ()
        self.rename_panel:SetActive(false)
    end)
    local submit_btn = btn_panel:FindChild("RenameSubmit")
    submit_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CONFIRM
    self:AddClick(submit_btn, function ()
        self:SendModifyRoleName()
    end)
end

function PlayerInfoUI:InitUI()
    self:InitRoleInfo()
    self:RegisterEvent(ComMgrs.dy_data_mgr, "UpdateCurrencyEvent", function (_, currency)
        if self._item_to_text_list then
            UIFuncs.UpdateCurrencyItemNum(self._item_to_text_list, currency)
        end
        self:UpdateCostValueInfo(currency)
    end)
    self:RegisterEvent(ComMgrs.dy_data_mgr, "UpdateRoleInfoEvent", function (_, role_info)
        self:UpdateRoleInfo(role_info)
    end)
    self:RegisterEvent(ComMgrs.dy_data_mgr.title_data, "UpdateWearTitleEvent", function ()
        self:UpdateTitle()
    end)
end

function PlayerInfoUI:InitRoleInfo()
    local role_info = ComMgrs.dy_data_mgr:ExGetMainRoleInfoData()
    self:UpdateRoleInfo(role_info)
    self:UpdateTitle()
    self.score.text = role_info.score
    self.fight_score.text = role_info.fight_score
    local vip_level = ComMgrs.dy_data_mgr:ExGetRoleVip()
    self.vip:SetActive(vip_level > 0)
    if vip_level > 0 then
        UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetVipData(vip_level).icon, self.vip_img)
    end
    if self.dy_dynasty_data:GetDynastyId() then
        self.dy_dynasty_data:UpdateDynastyBasicInfo(function (dynasty_info)
            self.dynasty.text = string.format(UIConst.Text.ROLE_DYNASTY_FORMAT, dynasty_info.dynasty_name)
        end)
    else
        self.dynasty.text = string.format(UIConst.Text.ROLE_DYNASTY_FORMAT, UIConst.Text.NONE)
    end
    self.level.text = string.format(UIConst.Text.ROLE_LEVEL_FORMAT, role_info.level)
    local level_data = SpecMgrs.data_mgr:GetLevelData(role_info.level)
    self.role_exp_value.fillAmount = (role_info.exp - level_data.total_exp) / level_data.exp
    self.role_exp_text.text = string.format(UIConst.Text.PER_VALUE, role_info.exp - level_data.total_exp, level_data.exp)
    for item_id, data in pairs(self.cost_value_data_dict) do
        data.count_text.text = string.format(UIConst.Text.GREEN_PRE_VALUE, ComMgrs.dy_data_mgr:ExGetCostValue(item_id), ComMgrs.dy_data_mgr:ExGetMaxCostValue(item_id))
        local recover_time = ComMgrs.dy_data_mgr:ExCalcRecoverTime(item_id)
        data.count_down:SetActive(false)
        if recover_time > 0 then
            local recover_second = recover_time + Time:GetServerTime()
            self:AddDynamicUI(data.count_down, function ()
                data.count_down_text.text = string.format(UIConst.Text.RECOVER_COUNT_DOWN_FORMAT, UIFuncs.TimeDelta2Str(recover_second - Time:GetServerTime()))
            end, 1, 0)
            data.count:SetActive(true)
            data.count_anim_cmp:Play()
            local count_flag = false
            self.cost_value_timer_dict[item_id] = self:AddTimer(function ()
                local active_text = count_flag and data.count or data.count_down
                local unactive_text = count_flag and data.count_down or data.count
                unactive_text:SetActive(false)
                active_text:SetActive(true)
                if count_flag then data.count_anim_cmp:Play() end
                count_flag = not count_flag
            end, kFadeOutDuration, 0)
        end
    end
end

function PlayerInfoUI:UpdateRoleInfo(role_info)
    if role_info.flag_id then
        UIFuncs.AssignSpriteByIconID(ComMgrs.dy_data_mgr:ExGetRoleFlagIcon(), self.flag_image)
    end
    if role_info.role_id then
        self:RemovePlayerUnit()
        local unit_id = SpecMgrs.data_mgr:GetRoleLookData(role_info.role_id).unit_id
        self.role_unit = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = unit_id, parent = self.role_model})
        self.role_unit:SetPositionByRectName({parent = self.role_model, name = UnitConst.UnitRect.Full})
    end
    if role_info.name then self.name.text = role_info.name end
end

function PlayerInfoUI:UpdateTitle()
    local title_id = ComMgrs.dy_data_mgr.title_data:GetWearingTitle()
    if title_id then
        self.title:SetActive(true)
        UIFuncs.AssignSpriteByItemID(title_id, self.title:GetComponent("Image"))
    else
        self.title:SetActive(false)
    end
end

function PlayerInfoUI:UpdateCostValueInfo(cost_value_data)
    if not next(cost_value_data) then return end
    for item_id, num in pairs(cost_value_data) do
        local data = self.cost_value_data_dict[item_id]
        if data then
            data.count_text.text = string.format(UIConst.Text.GREEN_PRE_VALUE, num, ComMgrs.dy_data_mgr:ExGetMaxCostValue(item_id))
            local recover_time = ComMgrs.dy_data_mgr:ExCalcRecoverTime(item_id)
            if recover_time > 0 then
                self:RemoveDynamicUI(data.count_down)
                local recover_second = recover_time + Time:GetServerTime()
                self:AddDynamicUI(data.count_down, function ()
                    data.count_down_text.text = string.format(UIConst.Text.RECOVER_COUNT_DOWN_FORMAT, UIFuncs.TimeDelta2Str(recover_second - Time:GetServerTime()))
                end)
            elseif self.cost_value_timer_dict[item_id] then
                data.count:SetActive(false)
                data.count_down:SetActive(false)
                self:RemoveTimer(self.cost_value_timer_dict[item_id])
                self.cost_value_timer_dict[item_id] = nil
                data.count:SetActive(true)
                data.count:GetComponent("CanvasGroup").alpha = 1
            end
        end
    end
end

function PlayerInfoUI:UpdateSettingContent(expand)
    if self.is_expand_setting == expand then return end
    self.is_expand_setting = expand
    self.setting_content:SetActive(self.is_expand_setting == true)
    self.close_setting_mask:SetActive(self.is_expand_setting == true)
end

function PlayerInfoUI:SendModifyRoleName()
    local name = self.rename_input.text
    if name == ComMgrs.dy_data_mgr:ExGetRoleName() then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.CHANGE_ROLE_NAME_SAME)
        return
    end
    local ret, err = CSFunction.check_player_name_legality(name)
    if not ret then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.NAME_ERROR_STR[err])
        return
    end
    SpecMgrs.msg_mgr:SendModifyRoleName({name = self.rename_input.text}, function (resp)
        if resp.errcode == 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.MODIFY_NAME_SUCCESS)
            self.rename_panel:SetActive(false)
        elseif resp.name_repeat then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.MODIFY_NAME_REPEAT)
        end
    end)
end

function PlayerInfoUI:RemovePlayerUnit()
    if self.role_unit then
        ComMgrs.unit_mgr:DestroyUnit(self.role_unit)
        self.role_unit = nil
    end
end

return PlayerInfoUI