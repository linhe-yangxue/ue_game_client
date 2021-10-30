local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local SoundConst = require("Sound.SoundConst")

local SettingUI = class("UI.SettingUI", UIBase)

function SettingUI:DoInit()
    SettingUI.super.DoInit(self)
    self.prefab_path = "UI/Common/SettingUI"
end

function SettingUI:OnGoLoadedOk(res_go)
    SettingUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function SettingUI:Hide()
    SettingUI.super.Hide(self)
end

function SettingUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    SettingUI.super.Show(self)
end

function SettingUI:InitRes()
    local content = self.main_panel:FindChild("Content")
    content:FindChild("Title"):GetComponent("Text").text = UIConst.Text.SETTING_TITLE
    self:AddClick(content:FindChild("CloseBtn"), function ()
        self:Hide()
    end)
    local setting_content = content:FindChild("Setting/View/Content")
    local sound_effect_panel = setting_content:FindChild("EffectSound")
    self.close_effect_sound_btn = sound_effect_panel:FindChild("CloseSoundBtn")
    self:AddClick(self.close_effect_sound_btn, function ()
        SpecMgrs.system_mgr:SetSoundState(false)
        self.sound_effect_slider_cmp.value = 0
    end)
    self.open_effect_sound_btn = sound_effect_panel:FindChild("OpenSoundBtn")
    self:AddClick(self.open_effect_sound_btn, function ()
        local volume = SpecMgrs.system_mgr:GetVolume(SoundConst.SOUND_TEMP_ID_SFX)
        if volume == 0 then return end
        SpecMgrs.system_mgr:SetSoundState(true)
        self.sound_effect_slider_cmp.value = volume
    end)
    sound_effect_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SOUND_EFFECT_SETTING
    local sound_effect_volume_slider = sound_effect_panel:FindChild("Slider")
    self.sound_effect_slider_cmp = sound_effect_volume_slider:GetComponent("Slider")
    self:AddSliderValueChange(sound_effect_volume_slider, function (value)
        if value > 0 then
            if not SpecMgrs.system_mgr:GetSoundState() then
                SpecMgrs.system_mgr:SetSoundState(true)
            end
            SpecMgrs.system_mgr:SetVolume(value, SoundConst.SOUND_TEMP_ID_SFX)
        elseif SpecMgrs.system_mgr:GetSoundState() then
            SpecMgrs.system_mgr:SetSoundState(false)
        end
        self.close_effect_sound_btn:SetActive(value > 0)
        self.open_effect_sound_btn:SetActive(value <= 0)
    end)

    local sound_bgm_panel = setting_content:FindChild("BgSound")
    self.close_bgm_sound_btn = sound_bgm_panel:FindChild("CloseSoundBtn")
    self:AddClick(self.close_bgm_sound_btn, function ()
        SpecMgrs.system_mgr:SetAudioState(false)
        self.sound_bgm_slider_cmp.value = 0
    end)
    self.open_bgm_sound_btn = sound_bgm_panel:FindChild("OpenSoundBtn")
    self:AddClick(self.open_bgm_sound_btn, function ()
        local volume = SpecMgrs.system_mgr:GetVolume(SoundConst.SOUND_TEMP_ID_BGM)
        if volume == 0 then return end
        SpecMgrs.system_mgr:SetAudioState(true)
        self.sound_bgm_slider_cmp.value = volume
    end)
    sound_bgm_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SOUND_BGM_SETTING
    local sound_bgm_volume_slider = sound_bgm_panel:FindChild("Slider")
    self.sound_bgm_slider_cmp = sound_bgm_volume_slider:GetComponent("Slider")
    self:AddSliderValueChange(sound_bgm_volume_slider, function (value)
        if value > 0 then
            if not SpecMgrs.system_mgr:GetAudioState() then
                SpecMgrs.system_mgr:SetAudioState(true)
            end
            SpecMgrs.system_mgr:SetVolume(value, SoundConst.SOUND_TEMP_ID_BGM)
        elseif SpecMgrs.system_mgr:GetAudioState() then
            SpecMgrs.system_mgr:SetAudioState(false)
        end
        self.close_bgm_sound_btn:SetActive(value > 0)
        self.open_bgm_sound_btn:SetActive(value <= 0)
    end)

    local btn_panel = content:FindChild("BtnPanel")
    local change_account_btn = btn_panel:FindChild("ChangeAccount")
    change_account_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SWITCH_ACCOUNT_TEXT
    self:AddClick(change_account_btn, function ()
        SpecMgrs.msg_mgr:SendSwitchAccount({uuid = ComMgrs.dy_data_mgr:ExGetRoleUuid()}, function (resp)
            if resp.errcode == 0 then
                SpecMgrs.stage_mgr:GotoStage("LoginStage")
            end
        end)
    end)
    local customer_service_btn = btn_panel:FindChild("CustomerService")
    customer_service_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CUSTOMER_SERVICE_TEXT
    self:AddClick(customer_service_btn, function ()
        -- TODO 游戏客服
    end)
end

function SettingUI:InitUI()
    self.sound_effect_slider_cmp.value = SpecMgrs.system_mgr:GetSoundState() and SpecMgrs.system_mgr:GetVolume(SoundConst.SOUND_TEMP_ID_SFX) or 0
    self.sound_bgm_slider_cmp.value = SpecMgrs.system_mgr:GetAudioState() and SpecMgrs.system_mgr:GetVolume(SoundConst.SOUND_TEMP_ID_BGM) or 0
end

return SettingUI