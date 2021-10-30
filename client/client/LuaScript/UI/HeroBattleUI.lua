local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local EventUtil = require("BaseUtilities.EventUtil")
local HeroBattleUI = class("UI.HeroBattleUI",UIBase)
local SoundConst = require("Sound.SoundConst")
EventUtil.GeneratorEventFuncs(HeroBattleUI, "BattleEnd")

local battle_bg_path = "UI/Common/BattleBg"

function HeroBattleUI:DoInit()
    HeroBattleUI.super.DoInit(self)
    self.prefab_path = "UI/Common/HeroBattleUI"
    self.hero_battle_victory_sound = SpecMgrs.data_mgr:GetParamData("battle_win").sound_id
    self.hero_battle_failed_sound = SpecMgrs.data_mgr:GetParamData("battle_lost").sound_id

    self.hero_battle_three_speed_id = SpecMgrs.data_mgr:GetParamData("hero_battle_three_speed").unlock_id
    self.skip_hero_battle_id = SpecMgrs.data_mgr:GetParamData("skip_hero_battle").unlock_id
end

function HeroBattleUI:OnGoLoadedOk(res_go)
    HeroBattleUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function HeroBattleUI:Show(is_editor_play, battle_data, scence_id, battle_bg_id)
    if scence_id then
        self.scence_data = SpecMgrs.data_mgr:GetBattleScenceData(scence_id)
    end
    if battle_bg_id then
        self.battle_bg_image_id = battle_bg_id
    elseif self.scence_data then
        self.battle_bg_image_id = self:GetBattleBg(self.scence_data)
    end
    self.is_editor_play = is_editor_play
    SpecMgrs.sound_mgr:PlayBGM(SoundConst.SOUND_ID_Fight)
    self.battle_data = battle_data
    if self.is_res_ok then
        self:InitUI()
    end
    HeroBattleUI.super.Show(self)
    self:StartBattle()
end

function HeroBattleUI:GetBattleBg(scence_data)
    local ret
    if scence_data.is_random_bg then
        local bg_list = SpecMgrs.data_mgr:GetAllBattleBgData()
        ret = bg_list[math.random(#bg_list)].image
    else
        ret = SpecMgrs.data_mgr:GetBattleBgData(self.scence_data.battle_bg).image
    end
    return ret
end

function HeroBattleUI:InitRes()
    self.speed_obj = self.main_panel:FindChild("Speed")
    self.speed_text = self.main_panel:FindChild("Speed/SpeedText"):GetComponent("Text")
    self.cur_round_text = self.main_panel:FindChild("CurRoundText"):GetComponent("Text")
    self.skip_count_down_text = self.main_panel:FindChild("SkipCountDownText"):GetComponent("Text")
    self:AddClick(self.main_panel:FindChild("Speed/SpeedText"), function()
        if self.lock_three_speed then
            self.cur_speed = self.cur_speed + 1
            if self.cur_speed == self.lock_max_speed + 1 then
                local str = UIFuncs.GetFuncLockTipStr(self.hero_battle_three_speed_id)
                SpecMgrs.ui_mgr:ShowTipMsg(str)
                self.cur_speed = 1
            end
        else
            self.cur_speed = self.cur_speed + 1
            if self.cur_speed == self.cur_max_speed + 1 then
                self.cur_speed = 1
            end
        end
        ComMgrs.dy_data_mgr:EXSetHeroBattleSpeed(self.cur_speed)
        SpecMgrs.hero_battle_mgr:SetPlaySpeed(self.cur_speed)
        self.speed_text.text = string.format(UIConst.Text.BATTLE_SPEED_FORMAT, self.cur_speed)
    end)
    self.skip_btn = self.main_panel:FindChild("Skip")
    self:AddClick(self.skip_btn, function()
        self:SkipBattle()
    end)
end

function HeroBattleUI:Update(delta_time)
    if not self.is_res_ok or not self.is_visible then return end
    if not self.scence_data or not self.scence_data.can_skip or self.is_lock_skip then return end
    --  战斗会加速
    self.cur_count_down_time = self.cur_count_down_time - delta_time / UnityEngine.Time.timeScale
    if self.cur_count_down_time <= 0 then
        self.count_down_finish = true
        self.skip_count_down_text.text = ""
    else
        self.skip_count_down_text.text = UIFuncs.TimeDelta2Str(math.ceil(self.cur_count_down_time), 3)
    end
end

function HeroBattleUI:InitUI()
    self:SetTextVal()
    self:UpdateData()
    self:UpdateUIInfo()
    SpecMgrs.hero_battle_mgr:RegisterUpdateRound("HeroBattleUI", function(_, _, round)
        self.cur_round = round
        self.cur_round_text.text = string.format(UIConst.Text.ROUND_NUM_FORMAT, self.cur_round)
    end, self)
    SpecMgrs.hero_battle_mgr:RegisterBattleEnd("HeroBattleUI", function(_, _, is_win)
        self:PlayUISound(is_win and self.hero_battle_victory_sound or self.hero_battle_failed_sound)
        self:DispatchBattleEnd()
        ComMgrs.dy_data_mgr:ExSetBattleState(false)
    end, self)

    if self.battle_bg then
        self.battle_bg:SetActive(true)
    else
        local battle_bg = SpecMgrs.res_mgr:GetPrefabSync(battle_bg_path)
        self.battle_bg = GameObject.Instantiate(battle_bg)
    end
    if self.battle_bg_image_id then
        UIFuncs.AssignSpriteByIconID(self.battle_bg_image_id, self.battle_bg:GetComponent("SpriteRenderer"))
    end
end

function HeroBattleUI:UpdateData()
    self.lock_three_speed = self:CheckLock(self.hero_battle_three_speed_id)
    self.is_lock_skip = self:CheckLock(self.skip_hero_battle_id)
    self.cur_round = 1
    self.cur_speed = ComMgrs.dy_data_mgr:EXGetHeroBattleSpeed()
    self.cur_max_speed = 3
    self.lock_max_speed = 2
    self.count_down_finish = true
    self.cur_count_down_time = 0
end

function HeroBattleUI:UpdateUIInfo()
    self.speed_text.text = string.format(UIConst.Text.BATTLE_SPEED_FORMAT, self.cur_speed)
    if self.scence_data and self.scence_data.can_skip and not self.is_lock_skip then
        if self.scence_data.have_count_down then
            self.cur_count_down_time = SpecMgrs.data_mgr:GetParamData("battle_skip_count_down_time").f_value
            self.count_down_finish = false
        end
    end
    self.skip_btn:SetActive(self.scence_data ~= nil and self.scence_data.can_skip)
    self.speed_obj:SetActive(self.scence_data ~= nil and self.scence_data.can_change_speed)
end

function HeroBattleUI:SetTextVal()
    self.skip_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SKIP
end

function HeroBattleUI:StartBattle()
    ComMgrs.dy_data_mgr:ExSetBattleState(true)
    SpecMgrs.hero_battle_mgr:InitBattle(self.battle_data)
    SpecMgrs.ui_mgr:ShowUI("SpecialUI")
    SpecMgrs.ui_mgr:ShowUI("EffectUI")
    SpecMgrs.ui_mgr:ShowUI("HudUI")

    if not self.is_editor_play then  -- 编辑器模式下不发送
        SpecMgrs.msg_mgr:SendStageFightEnd(nil, nil)
    end
end

function HeroBattleUI:SkipBattle()
    if self.is_editor_play then
        SpecMgrs.hero_battle_mgr:SkipBattle()
        return
    end
    if not self.count_down_finish then return end
    if ComMgrs.dy_data_mgr.func_unlock_data:CheckFuncIslock(self.skip_hero_battle_id, true) then return end
    if self.scence_data and self.scence_data.skip_lock_id then
        if ComMgrs.dy_data_mgr.func_unlock_data:CheckFuncIslock(self.scence_data.skip_lock_id, true) then
            return
        end
    end
    SpecMgrs.hero_battle_mgr:SkipBattle()
end

-- 编辑器调用
function HeroBattleUI:SetPlaySpeed(speed)
    self.cur_speed = speed
    SpecMgrs.hero_battle_mgr:SetPlaySpeed(self.cur_speed)
    self.speed_text.text = string.format(UIConst.Text.BATTLE_SPEED_FORMAT, self.cur_speed)
end

function HeroBattleUI:PlayBGM()
    SpecMgrs.sound_mgr:UnPauseBGMSound()
end

function HeroBattleUI:CloseBgmSound()
    SpecMgrs.sound_mgr:PauseBGMSound()
end
-- 编辑器调用 end

function HeroBattleUI:CheckLock(id)
    if self.is_editor_play then
        return false
    else
        return ComMgrs.dy_data_mgr.func_unlock_data:CheckFuncIslock(id)
    end
end

function HeroBattleUI:Hide()
    SpecMgrs.ui_mgr:HideUI("SpecialUI")
    SpecMgrs.ui_mgr:HideUI("EffectUI")
    SpecMgrs.ui_mgr:HideUI("HudUI")
    SpecMgrs.sound_mgr:RemoveBGM(SoundConst.SOUND_ID_Fight)
    if self.battle_bg then
        self.battle_bg:SetActive(false)
    end
    SpecMgrs.hero_battle_mgr:ClearAll()
    SpecMgrs.hero_battle_mgr:UnregisterUpdateRound("HeroBattleUI")
    SpecMgrs.hero_battle_mgr:UnregisterBattleEnd("HeroBattleUI")
    HeroBattleUI.super.Hide(self)
end

return HeroBattleUI
