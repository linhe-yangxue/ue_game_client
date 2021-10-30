 local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local CSConst = require("CSCommon.CSConst")
local UIFuncs = require("UI.UIFuncs")
local BattleResultUI = require("UI.BattleResultUI")
local FConst = require("CSCommon.Fight.FConst")
local ItemUtil = require("BaseUtilities.ItemUtil")
local SoundConst = require("Sound.SoundConst")
local EventUtil = require("BaseUtilities.EventUtil")
local SoldierBattleUI = class("UI.SoldierBattleUI",UIBase)

EventUtil.GeneratorEventFuncs(SoldierBattleUI, "BattleEnd")

local stage_interval = 0.5

function SoldierBattleUI:DoInit()
    SoldierBattleUI.super.DoInit(self)
    self.prefab_path = "UI/Common/SoldierBattleUI"
    self.soldier_battle_victory_sound = SpecMgrs.data_mgr:GetParamData("soldier_battle_victory_sound").sound_id
    self.soldier_battle_failed_sound = SpecMgrs.data_mgr:GetParamData("soldier_battle_failed_sound").sound_id
    self.quick_battle_unlock_id = SpecMgrs.data_mgr:GetParamData("soldier_battle_quick_battle").unlock_id
end

function SoldierBattleUI:OnGoLoadedOk(res_go)
    SoldierBattleUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function SoldierBattleUI:Show(battle_data, reward_data)
    if battle_data then
        self.is_guide_battle = true
    else
        self.is_guide_battle = false
    end
    self.battle_data = battle_data
    self.reward_data = reward_data
    self:PlayBGM(SoundConst.SOUND_ID_Fight)
    ComMgrs.dy_data_mgr:ExSetBattleState(true)
    if self.is_res_ok then
        self:InitUI()
    end
    SoldierBattleUI.super.Show(self)
end

function SoldierBattleUI:InitRes()
    self:InitTopBar(function()
        if self.battle_data or self.is_click_battle then
            return
        end
        self:Hide()
    end)
    self.battle_bg = self.main_panel:FindChild("Bg"):GetComponent("Image")
    self.m_military_val_text = self.main_panel:FindChild("MiddleFrame/MyMes/MMilitaryValText"):GetComponent("Text")
    self.battle_lost_level_text = self.main_panel:FindChild("MiddleFrame/MyMes/BattleLostLevelText"):GetComponent("Text")
    self.m_hp_slider = self.main_panel:FindChild("MiddleFrame/MyMes/Hp/MHpSlider"):GetComponent("Image")
    self.m_hp_slider_text = self.main_panel:FindChild("MiddleFrame/MyMes/Hp/MHpSliderText"):GetComponent("Text")
    self.enemy_military_val_text = self.main_panel:FindChild("MiddleFrame/EnemyMes/EnemyMilitaryValText"):GetComponent("Text")
    self.enemy_hp_slider = self.main_panel:FindChild("MiddleFrame/EnemyMes/Hp/EnemyHpSlider"):GetComponent("Image")
    self.enemy_hp_slider_text = self.main_panel:FindChild("MiddleFrame/EnemyMes/Hp/EnemyHpSliderText"):GetComponent("Text")
    self.cur_stage_text = self.main_panel:FindChild("MiddleFrame/CurStageText"):GetComponent("Text")

    self.role_image = self.main_panel:FindChild("MiddleFrame/MyMes/Bg/role"):GetComponent("Image")
    self.enemy_role_image = self.main_panel:FindChild("MiddleFrame/EnemyMes/Bg/role"):GetComponent("Image")

    self.down_frame = self.main_panel:FindChild("DownFrame")
    self.stage_progress_slider = self.main_panel:FindChild("DownFrame/StageProgressSlider"):GetComponent("Image")
    self.fast_battle_text = self.main_panel:FindChild("DownFrame/FastBattleToggle/FastBattleText"):GetComponent("Text")
    self.state_progress = self.main_panel:FindChild("DownFrame/StateProgress")

    self.fast_battle_toggle = self.main_panel:FindChild("DownFrame/FastBattleToggle"):GetComponent("Toggle")

    self:AddToggle(self.fast_battle_toggle.gameObject, function(is_on)
        self:ClickFastBattleToggle(is_on)
    end)

    self.fast_battle_toggle_mask = self.main_panel:FindChild("DownFrame/FastBattleToggle/ToggleMask")
    self:AddClick(self.fast_battle_toggle_mask, function()
        self:ClickToggleMask()
    end)

    self.start_battle_button = self.main_panel:FindChild("DownFrame/StartBattleButton")
    self:AddClick(self.start_battle_button, function()
        self:ClickStartBattleBtn()
    end)

    self.start_battle_button_image = self.start_battle_button:GetComponent("Image")
    self.quick_fight_frame = self.main_panel:FindChild("QuickFightFrame")
    self.stage_silder = self.main_panel:FindChild("QuickFightFrame/StageSlider")
    self.soldier_slider = self.main_panel:FindChild("QuickFightFrame/SoldierSlider"):GetComponent("Image")

    self.soldier_num_text = self.main_panel:FindChild("QuickFightFrame/SoldierNumText"):GetComponent("Text")
    self.my_soldier_text = self.main_panel:FindChild("QuickFightFrame/MySoldierText"):GetComponent("Text")

    self.quick_fight_stage_progress_slider = self.main_panel:FindChild("QuickFightFrame/StageSlider/StageProgressSlider"):GetComponent("Image")
    self.quick_fight_state_progress = self.main_panel:FindChild("QuickFightFrame/StageSlider/StateProgress")
    self.quick_battle_stage_slider = self.stage_silder:FindChild("StageProgressSlider"):GetComponent("Image")
    self.clost_tip_text = self.main_panel:FindChild("QuickFightFrame/CloseTipText"):GetComponent("Text")
    self.gun_image_rect = self.main_panel:FindChild("QuickFightFrame/StageSlider/StateProgress/GunImage"):GetComponent("RectTransform")

    self.quick_fight_title = self.main_panel:FindChild("QuickFightFrame/Content/Titile/Text"):GetComponent("Text")
    self.quick_fight_money = self.main_panel:FindChild("QuickFightFrame/Content/Money")
    self.quick_fight_Exp = self.main_panel:FindChild("QuickFightFrame/Content/Exp")
    self.quick_reward_item_list_content = self.main_panel:FindChild("QuickFightFrame/Content/Scroll View/Viewport/Content")
    self.fail_tip_part = self.main_panel:FindChild("QuickFightFrame/Content/FailTipPart")

    self:AddClick(self.quick_fight_frame, function()
        self:HideQuickFightFrame()
    end)
    self.default_battle_btn_image = self.start_battle_button_image.sprite
end

function SoldierBattleUI:InitUI()
    self:DelObjDict(self.create_obj_list)
    self.create_obj_list = {}
    self.quick_fight_frame:SetActive(false)
    self.fast_battle_toggle.isOn = ComMgrs.dy_data_mgr:EXGetQuickSoldierBattle()
    self:SetTextVal()
    self:UpdateData()
    self:UpdateUIInfo()
    SpecMgrs.soldier_battle_mgr:RegisterUpdateBothSoldier("SoldierBattleUI", function(_, _, m_soldier_num, enemy_soldier_num)
        self:UpdateBothSoldierNum(m_soldier_num, enemy_soldier_num)
    end, self)
    SpecMgrs.soldier_battle_mgr:RegisterBattleEnd("SoldierBattleUI", function(_, _, is_win)
        self:PlayUISound(is_win and self.soldier_battle_victory_sound or self.soldier_battle_failed_sound)
        local param_tb = {}
        if self.battle_data then
            param_tb = {
                is_win = is_win,
                show_level = true,
                is_soldier_battle = true,
                first_reward = self.reward_data,
                win_tip = is_win and UIConst.Text.BATTLE_WIN_TIP_TEXT,
            }
        else
            param_tb = {
                is_win = is_win,
                win_tip = is_win and UIConst.Text.BATTLE_WIN_TIP_TEXT,
                show_level = true,
                is_soldier_battle = true,
                first_reward = (is_win and self.cur_part == #self.cur_stage_data.enemy_num) and ItemUtil.RoleItemListToItemDict(self.item_list),
            }
        end
        SpecMgrs.ui_mgr:AddToPopUpList("BattleResultUI", param_tb)
        self:HandleBattleResultClose(is_win)
    end, self)
end

function SoldierBattleUI:Update(delta_time)
    if not self.is_res_ok then return end
    self:UpdateSoldierBattle(delta_time)
end

function SoldierBattleUI:HandleBattleResultClose(is_win)
    SpecMgrs.ui_mgr:RegisterHideUIEvent("SoldierBattleUI", function(_, ui)
        if ui.class_name ~= "BattleResultUI" then
            return
        else
            SpecMgrs.ui_mgr:UnregisterHideUIEvent("SoldierBattleUI")
        end
        if self.battle_data or not is_win then
            self:Hide()
            return
        end
        if self.cur_part == #self.cur_stage_data.enemy_num then
            self:Hide()
        else
            SpecMgrs.soldier_battle_mgr:EndBattle()
            self:UnRegisterEvent()
            self:InitUI()
        end
    end)
end

function SoldierBattleUI:SetTextVal()
    self.fast_battle_text.text = UIConst.Text.FAST_BATTLE
    self.my_soldier_text.text = UIConst.Text.MY_SOLDIER_TEXT
    self.clost_tip_text.text = UIConst.Text.CLOSE_TIP_TEXT
    self.quick_fight_title.text = UIConst.Text.WIN_REWARD_TEXT
    self.quick_fight_money:GetComponent("Text").text = UIConst.Text.MONEY_TEXT
    self.quick_fight_Exp:GetComponent("Text").text = UIConst.Text.EXP_TEXT
end

function SoldierBattleUI:UpdateData()
    self.lost_level_data = SpecMgrs.data_mgr:GetAllSoldierLostLevelData()
    if self.battle_data then
        self.enemy_soldier_num = self.battle_data.enemy_soldier_num
        self.m_soldier_num = self.battle_data.m_soldier_num
        self.m_military = self.battle_data.m_military_val
        self.enemy_military = self.battle_data.enemy_military_val
        self.enemy_model_id = self.battle_data.enemy_model_id
        self.enemy_model_num = self.battle_data.enemy_model_num

        self.enemy_cur_soldier_num = self.enemy_soldier_num
        self.max_part = 1
        self.cur_part = 1
        SpecMgrs.soldier_battle_mgr:InitBattle(self.battle_data)
    else
        self.cur_stage_info = ComMgrs.dy_data_mgr.strategy_map_data:GetStageInfo()
        self.cur_stage_data = SpecMgrs.data_mgr:GetStageData(self.cur_stage_info.curr_stage)

        self.cur_part = self.cur_stage_info.curr_part
        self.enemy_soldier_num = self.cur_stage_data.enemy_num[self.cur_part]
        self.role_data = ComMgrs.dy_data_mgr:GetCurrencyData()
        self.m_soldier_num = ComMgrs.dy_data_mgr:GetCurrencyData()[CSConst.Virtual.Soldier]
        self.m_military = ComMgrs.dy_data_mgr:ExGetAtributeValue("fight")
        self.enemy_military = self.cur_stage_data.enemy_military[self.cur_part]

        self.enemy_cur_soldier_num = self.cur_stage_info.remain_enemy

        local cur_part = self.cur_stage_info.curr_part
        self.enemy_model_id = self.cur_stage_data.enemy_model[cur_part]
        self.enemy_model_num = self.cur_stage_data.enemy_model_num[cur_part]

        local battle_data = {
            enemy_soldier_num = self.enemy_cur_soldier_num,
            m_soldier_num = self.m_soldier_num,
            m_military_val = self.m_military,
            enemy_military_val = self.enemy_military,
            enemy_model_id = self.enemy_model_id,
            enemy_model_num = self.enemy_model_num,
        }
        SpecMgrs.soldier_battle_mgr:InitBattle(battle_data)
    end
    self.is_click_battle = false

    local is_lock = ComMgrs.dy_data_mgr.func_unlock_data:CheckFuncIslock(self.quick_battle_unlock_id)
    self.fast_battle_toggle_mask:SetActive(is_lock)
    self.guide_bg_id = SpecMgrs.data_mgr:GetParamData("soldier_battle_guide_bg").icon
end

function SoldierBattleUI:UpdateUIInfo()
    local icon_id = SpecMgrs.data_mgr:GetRoleLookData(ComMgrs.dy_data_mgr:ExGetRoleId()).head_icon_id
    if self.cur_stage_data and self.cur_stage_data.enemy_icon then
        local enemy_icon_id = self.cur_stage_data.enemy_icon[self.cur_part]
        if enemy_icon_id then
            UIFuncs.AssignSpriteByIconID(enemy_icon_id, self.enemy_role_image, true)
        end
    end
    UIFuncs.AssignSpriteByIconID(icon_id, self.role_image, true)

    if self.cur_stage_data and self.cur_stage_data.battle_start_icon then
        UIFuncs.AssignSpriteByIconID(self.cur_stage_data.battle_start_icon, self.start_battle_button_image)
    else
        self.start_battle_button_image.sprite = self.default_battle_btn_image
    end

    if self.is_guide_battle then -- 指引
        UIFuncs.AssignSpriteByIconID(self.guide_bg_id, self.battle_bg)
    else
        UIFuncs.AssignSpriteByIconID(self.cur_stage_data.battle_bg, self.battle_bg)
    end
    self:UpdateBothSoldierNum(self.m_soldier_num, self.enemy_cur_soldier_num)
    self:UpdateBattleMes()
    self:UpdateStageSlider(self.down_frame)
end

function SoldierBattleUI:UpdateStageSlider(parent)
    local slider_end_image = parent:FindChild("StateProgress/SliderEndImage")
    local state_progress = parent:FindChild("StateProgress")
    local stage_progress_slider = parent:FindChild("StageProgressSlider"):GetComponent("Image")
    local temp = state_progress:FindChild("Temp")
    temp:GetComponent("Image").enabled = true
    if self.max_part == 0 then
        slider_end_image:SetActive(false)
        state_progress:SetActive(false)
    else
        slider_end_image:SetActive(true)
        state_progress:SetActive(true)
        for i = 1, self.max_part - 1 do
            local point = self:GetUIObject(temp, state_progress, false)
            table.insert(self.create_obj_list, point)
            local rect = point:GetComponent("RectTransform")
            local anchor_x = i / self.max_part
            self:SetRectAnchorX(rect, anchor_x)
            rect.anchoredPosition = Vector3.zero
        end
        stage_progress_slider.fillAmount = (self.cur_part - 1) / self.max_part
    end
    slider_end_image:SetAsLastSibling()
    temp:GetComponent("Image").enabled = false
end

function SoldierBattleUI:UpdateBattleMes()
    if not self.battle_data then
        self.max_part = #self.cur_stage_data.enemy_num
        self.cur_stage_text.text = string.format(UIConst.Text.SOLDIER_STAGE_FORMAT, self.cur_stage_info.curr_stage, self.cur_stage_info.curr_part, self.max_part)
    end

    self.m_military_val_text.text = string.format(UIConst.Text.MILITARY_VAL_FROMAL, self.m_military)
    self.enemy_military_val_text.text = string.format(UIConst.Text.MILITARY_VAL_FROMAL, self.enemy_military)

    self.lost_level = 1
    local military_coefficient = self.m_military / self.enemy_military
    for i, data in ipairs(self.lost_level_data) do
        if i == 1 then
            if military_coefficient > data.proportion[1] then
                self.lost_level = i
                break
            end
        elseif i == #self.lost_level_data then
            if military_coefficient < data.proportion[1] then
                self.lost_level = i
                break
            end
        else
            if military_coefficient >= data.proportion[1] and military_coefficient <= data.proportion[2] then
                self.lost_level = i
                break
            end
        end
    end
    self.battle_lost_level_text.text = string.format(UIConst.Text.BATTLE_LOST_FORMAT, UIConst.Text.BATTLE_LOST_LEVEL[self.lost_level])
end

function SoldierBattleUI:UpdateBothSoldierNum(m_cur_soldier_num, enemy_cur_soldier_num)
    self.m_hp_slider.fillAmount = m_cur_soldier_num / self.m_soldier_num
    self.enemy_hp_slider.fillAmount = enemy_cur_soldier_num / self.enemy_soldier_num

    self.m_hp_slider_text.text = m_cur_soldier_num
    self.enemy_hp_slider_text.text = enemy_cur_soldier_num
end

function SoldierBattleUI:ClickToggleMask()
    local str = UIFuncs.GetFuncLockTipStr(self.quick_battle_unlock_id)
    SpecMgrs.ui_mgr:ShowTipMsg(str)
end

function SoldierBattleUI:ClickFastBattleToggle(is_on)
    ComMgrs.dy_data_mgr:EXSetQuickSoldierBattle(self.fast_battle_toggle.isOn)
end

function SoldierBattleUI:ClickStartBattleBtn()
    if self.is_click_battle then return end
    if self.lost_level == #self.lost_level_data then
        local param_tb = {
            content = string.format(UIConst.Text.LOST_LEVEL_TIP, UIConst.Text.BATTLE_LOST_LEVEL[self.lost_level]),
            confirm_cb = function()
                self:StartBattle()
            end,
        }
        SpecMgrs.ui_mgr:ShowMsgSelectBox(param_tb)
        return
    end
    self:StartBattle()
end

function SoldierBattleUI:StartBattle()
    if self.battle_data then
        SpecMgrs.soldier_battle_mgr:StartBattle()
        SpecMgrs.msg_mgr:SendStageFightEnd(nil, nil)
        self.is_click_battle = true
    else
        if self.fast_battle_toggle.isOn then
            self:ShowQuickFigtFrame()
        else
            self.is_click_battle = true
            local resp_cb = function(resp)
                self.item_list = resp.item_list or {}
                SpecMgrs.soldier_battle_mgr:StartBattle(resp)
            end
            SpecMgrs.msg_mgr:SendStageFight(nil, resp_cb)
            ComMgrs.dy_data_mgr:ExSetBattleState(true)
            SpecMgrs.msg_mgr:SendStageFightEnd(nil, nil)
        end
    end
end

--  快速战斗
function SoldierBattleUI:ShowQuickFigtFrame()
    self:UpdateStageSlider(self.stage_silder)
    self.quick_fight_frame:SetActive(true)
    self.quick_fight_money:SetActive(false)
    self.quick_fight_Exp:SetActive(false)
    self.fail_tip_part:SetActive(false)
    self.quick_reward_item_list_content:SetActive(false)
    self.soldier_num_text.text = string.format(UIConst.Text.PER_VALUE, self.m_soldier_num, self.m_soldier_num)
    self.soldier_slider.fillAmount = 1
    self.frame_max_soldier_num = self.m_soldier_num
    self.last_stage_soldier_num = 0
    self.start_stage = self.cur_stage_info.curr_stage
    self.cur_stage = self.cur_stage_info.curr_stage

    self.fail_tip_part:FindChild("FailTipPartText"):GetComponent("Text").text = UIConst.Text.BATTLE_FAIL_TIP_TEXT
    self.fail_tip_part:FindChild("TipText/Text"):GetComponent("Text").text = UIConst.Text.RECRUIT_SOLDIER_TEXT
    self:AddClick(self.fail_tip_part:FindChild("RecruitSoldierBtn"), function()
        SpecMgrs.stage_mgr:GotoStage("MainStage")
        SpecMgrs.ui_mgr:HideUI(self)
        SpecMgrs.ui_mgr:ShowUI("GreatHallUI")
    end)

    self.quick_battle_stage_slider.fillAmount = (self.cur_part - 1) / self.max_part
    self.start_quick_fight = true
    self.is_wait_to_recive_msg = true
    local resp_cb = function(resp)
        self.cur_item_list = resp.item_list
        self.stage_fight_timer = 0
        self.last_stage_soldier_num = self.m_soldier_num
        self.m_soldier_num = self.m_soldier_num - resp.self_cost
        self.cur_stage = self.cur_stage_info.curr_stage
        self.is_wait_to_recive_msg = false
    end
    SpecMgrs.msg_mgr:SendStageFight(nil, resp_cb)
    SpecMgrs.msg_mgr:SendStageFightEnd(nil, nil)
    self:UpdateSliderGunImage(self.cur_part, 0)
end

function SoldierBattleUI:UpdateSoldierBattle(delta_time)
    if not self.start_quick_fight or self.is_wait_to_recive_msg then return end
    self.stage_fight_timer = self.stage_fight_timer + delta_time
    if self.stage_fight_timer >= stage_interval and not self.is_wait_to_recive_msg then
        local slider_val = self.cur_part / self.max_part
        self.quick_battle_stage_slider.fillAmount = slider_val
        self:UpdateSoldierSlider(self.m_soldier_num, self.frame_max_soldier_num)
        self:UpdateSliderGunImage(self.cur_part, 1)
        self.last_stage_soldier_num = self.m_soldier_num
        if self.last_stage_soldier_num == 0 then
            self.fail_tip_part:SetActive(true)
            self.start_quick_fight = false
            return
        end
        if self.cur_stage > self.start_stage then
            self:ShowQuickReward(self.cur_item_list)
            self.start_quick_fight = false
            return
        end
        self.cur_part = self.cur_stage_info.curr_part
        self.is_wait_to_recive_msg = true
        local resp_cb = function(resp)
            self.cur_item_list = resp.item_list
            self.stage_fight_timer = 0
            self.is_wait_to_recive_msg = false
            self.m_soldier_num = self.m_soldier_num - resp.self_cost
            self.cur_stage = self.cur_stage_info.curr_stage
        end
        SpecMgrs.msg_mgr:SendStageFight(nil, resp_cb)
        SpecMgrs.msg_mgr:SendStageFightEnd(nil, nil)
    end
    if self.stage_fight_timer < stage_interval then
        local lerp = self.stage_fight_timer / stage_interval
        local num = math.lerp(self.last_stage_soldier_num, self.m_soldier_num, lerp)
        self:UpdateSoldierSlider(math.ceil(num), self.frame_max_soldier_num)
        local slider_val = (self.cur_part - 1) / self.max_part + math.lerp(0, 1 / self.max_part, lerp)
        self.quick_battle_stage_slider.fillAmount = slider_val
        self:UpdateSliderGunImage(self.cur_part, lerp)
    end
end

function SoldierBattleUI:UpdateSoldierSlider(cur_num, max_num)
    self.soldier_num_text.text = string.format(UIConst.Text.PER_VALUE, UIFuncs.AddCountUnit(cur_num), UIFuncs.AddCountUnit(max_num))
    self.soldier_slider.fillAmount = cur_num / max_num
end

function SoldierBattleUI:UpdateSliderGunImage(index, lerp)
    local last_part_anchor_x = (index - 1) / self.max_part
    local cur_part_anchor_x = index / self.max_part
    local anchor_x = last_part_anchor_x + math.lerp(0, cur_part_anchor_x - last_part_anchor_x, lerp)
    self:SetRectAnchorX(self.gun_image_rect, anchor_x)
end

function SoldierBattleUI:SetRectAnchorX(rect, val)
    rect.anchorMax = Vector2.New(val, 0.5)
    rect.anchorMin = Vector2.New(val, 0.5)
end

function SoldierBattleUI:ShowQuickReward(role_item_list)
    self.quick_fight_money:SetActive(true)
    self.quick_fight_Exp:SetActive(true)
    self.quick_reward_item_list_content:SetActive(true)

    local money_val
    local exp_val
    for i = #role_item_list, 1, -1 do
        if role_item_list[i].item_id == CSConst.Virtual.Money then
            money_val = role_item_list[i].count
            table.remove(role_item_list, i)
        elseif role_item_list[i].item_id == CSConst.Virtual.Exp then
            exp_val = role_item_list[i].count
            table.remove(role_item_list, i)
        end
    end
    self.quick_fight_money:FindChild("Image/Text"):GetComponent("Text").text = money_val or 0
    self.quick_fight_Exp:FindChild("Image/Text"):GetComponent("Text").text = exp_val or 0
    local item_list = self:SetItemList(role_item_list, self.quick_reward_item_list_content)
    table.mergeList(self.create_obj_list, item_list)
end

function SoldierBattleUI:HideQuickFightFrame()
    if self.start_quick_fight then return end
    self:Hide()
    self.is_wait_to_recive_msg = false
    self.quick_fight_frame:SetActive(false)
end
-- end

function SoldierBattleUI:UnRegisterEvent()
    SpecMgrs.soldier_battle_mgr:UnregisterUpdateBothSoldier("SoldierBattleUI")
    SpecMgrs.soldier_battle_mgr:UnregisterBattleEnd("SoldierBattleUI")
    local battle_result_ui = SpecMgrs.ui_mgr:GetUI("BattleResultUI")
    if battle_result_ui then
        battle_result_ui:UnregisterBattleResultUICloseEvent("SoldierBattleUI")
    end
end

function SoldierBattleUI:Hide()
    self:RemoveBGM()
    SpecMgrs.soldier_battle_mgr:EndBattle()
    ComMgrs.dy_data_mgr:ExSetBattleState(false)
    self:DispatchBattleEnd()
    self.battle_data = nil
    self:UnRegisterEvent()
    self:DelObjDict(self.create_obj_list)
    SoldierBattleUI.super.Hide(self)
end

return SoldierBattleUI
