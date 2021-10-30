local SoundConst = require("Sound.SoundConst")
local Sound = require("Sound.Sound")
local SoundMgr = class("Mgrs.Special.SoundMgr")

function SoundMgr:DoInit()
    self.sound_root = GameObject("SoundMgr")
    GameObject.DontDestroyOnLoad(self.sound_root)
    self.global_volume = 1
    self.bgm_sound_toggle = true
    self.sfx_sound_toggle = true
    self.sound_guid_tb = {}
    self.singleton_sound_dict = {}
    self.sound_type_guid_tb = {}
    self.sound_tag_guid_tb = {}
    self.bgm_sound = nil
    self.sfx_sound = nil
    self.sound_volume_tb = {}

    self.cur_bgm_sound_id = nil
    self.bgm_sound_stack = {}
    self._cur_playing_bgm_sound_id = nil

    local is_audio_open = SpecMgrs.system_mgr:GetAudioState()
    local is_sound_open = SpecMgrs.system_mgr:GetSoundState()
    local g_volume = SpecMgrs.system_mgr:GetVolume()
    self:ToggleBGMVolume(is_audio_open)
    self:ToggleSFXVolume(is_sound_open)
    self:SetGlobalVolume(g_volume)
    for _, sound_type in pairs(SoundConst.SoundType) do
        self.sound_volume_tb[sound_type] = SpecMgrs.system_mgr:GetVolume(sound_type)
    end
end

function SoundMgr:DoDestroy()
    for sound_guid, _ in pairs(self.sound_guid_tb) do
        self:_DestroySoundByGuid(sound_guid)
    end
    self.sound_guid_tb = {}
    self.sound_type_guid_tb = {}
    self.sound_tag_guid_tb = {}
    self.singleton_sound_dict = {}
    self.bgm_sound = nil

    if self.sound_root then
        GameObject.Destroy(self.sound_root)
        self.sound_root = nil
    end
    if self.__ClearAllEventCb then
        self:__ClearAllEventCb()
    end
end

function SoundMgr:Update(delta_time)
    for _, sound in pairs(self.sound_guid_tb) do
        sound:Update(delta_time)
    end
    if self.__UpdateEventCbRemove then
        self:__UpdateEventCbRemove()
    end
end

-- 接口
function SoundMgr:PlayBGM(sound_id)
    if self.cur_bgm_sound_id ~= nil then
        table.insert(self.bgm_sound_stack, self.cur_bgm_sound_id)
    end
    if self.cur_bgm_sound_id == sound_id then return end -- 如果两个场景音乐相同将不重播，但是必须在场景切换时删除
    self.cur_bgm_sound_id = sound_id
    self:_PlayBGM(sound_id)
end

function SoundMgr:RemoveBGM(sound_id)
    if self.cur_bgm_sound_id ~= sound_id then return end
    local last_bgm_sound_id = table.remove(self.bgm_sound_stack, #self.bgm_sound_stack)
    if last_bgm_sound_id == nil then return end
    if self.cur_bgm_sound_id == last_bgm_sound_id then return end
    self.cur_bgm_sound_id = last_bgm_sound_id
    self:_PlayBGM(last_bgm_sound_id)
end

function SoundMgr:PlayTalkSound(sound_id, sound_name, tag)
    return self:PlaySingletonSound(sound_id, sound_name, false, false, SoundConst.SoundType.SFX, tag)
end

--技能
function SoundMgr:PlaySpellSound(sound_id, pitch)
    pitch = pitch or UnityEngine.Time.timeScale
    return self:PlaySFXSound(sound_id, false, true, SoundConst.SoundTag.Spell, pitch)
end

function SoundMgr:ClearAllSpellSound()
    self:ClearSoundByTag(SoundConst.SoundTag.Spell)
end

function SoundMgr:PlayUISound(sound_id, loop, ui, is_one_shot)
    loop = loop or false
    local auto_destroy = loop == false and true or false
    if is_one_shot then
        self:_PlaySFX(sound_id)
    else
        return self:PlaySFXSound(sound_id, loop, auto_destroy, ui)
    end
end

function SoundMgr:DestroySound(sound)
    self:_DestroySoundByGuid(sound.guid)
end

function SoundMgr:ClearSoundByTag(sound_tag)
    local sound_tb = self.sound_tag_guid_tb[sound_tag]
    if not sound_tb then return end
    for guid, _ in pairs(sound_tb) do
        self:_DestroySoundByGuid(guid)
    end
    self.sound_tag_guid_tb[sound_tag] = nil
end

-- 接口 end

function SoundMgr:GetVolumeBySoundType(sound_type)
    return self.sound_volume_tb[sound_type]
end

function SoundMgr:GetVolume(sound_type)
    if sound_type == SoundConst.SoundType.BGM then
        if not self.bgm_sound_toggle then
            return 0
        end
    else
        if not self.sfx_sound_toggle then
            return 0
        end
    end
    return self.global_volume * self:GetVolumeBySoundType(sound_type)
end

function SoundMgr:SetGlobalVolume(volume)
    self.global_volume = math.clamp(volume, 0, 1)
    for _, sound_type in pairs(SoundConst.SoundType) do
        self:UpdateVolume(sound_type)
    end
end

function SoundMgr:ToggleBGMVolume(is_open)
    self.bgm_sound_toggle = is_open
    self:UpdateVolume(SoundConst.SoundType.BGM)
end

function SoundMgr:ToggleSFXVolume(is_open)
    self.sfx_sound_toggle = is_open
    for _, sound_type in pairs(SoundConst.SoundType) do
        if sound_type ~= SoundConst.SoundType.BGM then
            self:UpdateVolume(sound_type)
        end
    end
end

function SoundMgr:SetVolume(sound_type, volume)
    if self.sound_volume_tb[sound_type] == volume then return end
    self.sound_volume_tb[sound_type] = volume
    self:UpdateVolume(sound_type)
end

function SoundMgr:UpdateVolume(sound_type)
    local sound_tb = self.sound_type_guid_tb[sound_type]
    if sound_tb then
        for guid, _ in pairs(sound_tb) do
            local sound = self.sound_guid_tb[guid]
            sound:UpdateVolume()
        end
    end
end

function SoundMgr:_PlayBGM(sound_id)
    if not self.bgm_sound then
        self.bgm_sound = self:GetSingletonSound("bgm_sound", true, false, SoundConst.SoundType.BGM)
    end
    if self._cur_playing_bgm_sound_id ~= sound_id then
        self._cur_playing_bgm_sound_id = sound_id
        self.bgm_sound:PlayAudioClip(sound_id)
    end
end

function SoundMgr:_PlaySFX(sound_id)
    if not self.sfx_sound then
        self.sfx_sound = self:GetSingletonSound("sfx_sound", false, false, SoundConst.SoundType.SFX)
    end
    self.sfx_sound:PlayAudioClipOneShot(sound_id)
end

function SoundMgr:ClearBGMSoundStack()
    self.bgm_sound_stack = {}
    self.cur_bgm_sound_id = nil
end

function SoundMgr:PauseBGMSound()
    if self.bgm_sound then
        self.bgm_sound:Pause()
    end
end

function SoundMgr:UnPauseBGMSound()
    if self.bgm_sound then
        self.bgm_sound:Play()
    end
end

-- 播放一次，随stage切换清除
function SoundMgr:PlaySFXSound(sound_id, loop, auto_destroy, tag, pitch, is_one_shot)
    auto_destroy = auto_destroy == nil or auto_destroy --默认自动销毁
    loop = loop or false -- 默认不循环
    local sound = self:GetSFXSound(loop, auto_destroy, tag, pitch)
    self:_PlaySound(sound, sound_id, is_one_shot)
    return sound
end

function SoundMgr:GetSFXSound(loop, auto_destroy, tag, pitch)
    local param_tb = {
        sound_type = SoundConst.SoundType.SFX,
        auto_destroy = auto_destroy,
        is_loop = loop,
        tag = tag,
        pitch = pitch,
    }
    return self:CreatSoundAutoGuid(param_tb)
end

function SoundMgr:CreatSoundAutoGuid(param_tb)
    param_tb.guid = ComMgrs.dy_data_mgr:NewGuid()
    return self:CreatSound(param_tb)
end

function SoundMgr:CreatSound(param_tb)
    local guid = param_tb.guid
    local sound_id = param_tb.sound_id
    param_tb.sound_type = param_tb.sound_type or SoundConst.SoundType.SFX
    local sound_type = param_tb.sound_type
    local sound = Sound.New()
    self.sound_guid_tb[guid] = sound
    if not self.sound_type_guid_tb[sound_type] then
        self.sound_type_guid_tb[sound_type] = {}
    end
    self.sound_type_guid_tb[sound_type][guid] = true

    local tag = param_tb.tag
    if tag then
        if not self.sound_tag_guid_tb[tag] then
            self.sound_tag_guid_tb[tag] = {}
        end
        self.sound_tag_guid_tb[tag][guid] = true
    end

    sound:DoInit()
    sound:BuildSound(param_tb)
    return sound
end

function SoundMgr:PlaySingletonSound(sound_id, sound_name, is_loop, auto_destroy, sound_type, sound_tag, pitch, is_one_shot)
    local sound = self:GetSingletonSound(sound_name, is_loop, auto_destroy, sound_type, sound_tag, pitch)
    self:_PlaySound(sound, sound_id, is_one_shot)
    return sound
end

function SoundMgr:_PlaySound(sound, sound_id, is_one_shot)
    is_one_shot = is_one_shot or false
    if is_one_shot then
        sound:PlayAudioClip(sound_id)
    else
        sound:PlayAudioClipOneShot(sound_id)
    end
end

function SoundMgr:GetSingletonSound(sound_name, is_loop, auto_destroy, sound_type, sound_tag, pitch)
    if not self.singleton_sound_dict[sound_name] then
        local param_tb = {
            name = sound_name,
            sound_type = sound_type,
            auto_destroy = auto_destroy,
            is_loop = is_loop,
            tag = sound_tag,
            pitch = pitch,
        }
        self.singleton_sound_dict[sound_name] = self:CreatSoundAutoGuid(param_tb)
    end
    return self.singleton_sound_dict[sound_name]
end

function SoundMgr:GetSoundRoot()
    return self.sound_root
end

function SoundMgr:_DestroySoundByGuid(guid)
    local sound = self.sound_guid_tb[guid]
    if sound then
        self.sound_guid_tb[guid] = nil
        local sound_type = sound.sound_type
        if sound_type and self.sound_type_guid_tb[sound_type] then
            self.sound_type_guid_tb[sound_type][guid] = nil
        end
        self:_RemoveSoundFromTag(sound.sound_tag, guid)
        self:_RemoveSoundFromSingletonDict(sound.name)
        if sound == self.bgm_sound then
            self.bgm_sound = nil
        end
        sound:DoDestroy()
    end
end

function SoundMgr:_RemoveSoundFromTag(sound_tag, guid)
    if not sound_tag or not guid then return end
    local tb = self.sound_tag_guid_tb[sound_tag]
    if tb then
        tb[guid] = nil
        if not next(tb) then self.sound_tag_guid_tb[sound_tag] = nil end
    end
end

function SoundMgr:_RemoveSoundFromSingletonDict(name)
    if not name then return end
    self.singleton_sound_dict[name] = nil
end

function SoundMgr:ClearAll()
    --local other_sound_tb = self.sound_type_guid_tb[SoundConst.SoundType.SFX]
    --if other_sound_tb then
    --    for sound_guid, _ in pairs(other_sound_tb) do
    --        self:_DestroySoundByGuid(sound_guid)
    --    end
    --end
    self:ClearBGMSoundStack()
end

return SoundMgr