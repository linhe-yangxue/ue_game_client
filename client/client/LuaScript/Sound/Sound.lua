local SoundConst = require("Sound.SoundConst")
local Sound = class("Sound.Sound")

function Sound:DoInit()
    self.cur_clip_info = nil
    self.is_pause = nil
end

function Sound:BuildSound(param_tb)
    self.guid = param_tb.guid
    self.sound_type = param_tb.sound_type
    self.sound_tag = param_tb.sound_tag
    self.name = param_tb.name
    --audio go
    self.auto_destroy = param_tb.auto_destroy
    self.audio_go = self:GetAudioGo()
    self.audio_comp = self.audio_go:GetComponent("AudioSource")
    --clip param
    self.is_async_load = param_tb.is_async_load
    self.begin_time = param_tb.begin_time or 0
    --loop
    self.is_loop = param_tb.is_loop
    self.audio_comp.loop = self.is_loop and true or false
    --pitch
    self.pitch = param_tb.pitch or 1
    self.audio_comp.pitch = self.pitch

    self:UpdateVolume()

    self.sound_id = param_tb.sound_id
    if self.sound_id then
        self:PlayAudioClip(self.sound_id)
    end
    self.is_destroy = false
end

function Sound:GetAudioGo()
    if not self.sound_temp_id then
        if self.sound_type == SoundConst.SoundType.BGM then
            self.sound_temp_id = SoundConst.SOUND_TEMP_ID_BGM
        elseif self.sound_type == SoundConst.SoundType.SFX then
            self.sound_temp_id = SoundConst.SOUND_TEMP_ID_SFX
        else
            self.sound_temp_id = SoundConst.SOUND_TEMP_ID_SFX
        end
    end
    local sound_temp_data = SpecMgrs.data_mgr:GetSoundTempData(self.sound_temp_id)
    if not sound_temp_data then
        PrintError("Sound: None Found SoundTempData:", self.sound_temp_id)
        return nil
    end
    local audio_go = SpecMgrs.res_mgr:GetGameObjectSync(sound_temp_data.res_path)
    audio_go:SetParent(SpecMgrs.sound_mgr:GetSoundRoot())
    audio_go:SetActive(true)
    return audio_go
end


function Sound:UpdateVolume(scale)
    scale = scale or 1
    if self.audio_comp then
        self.audio_comp.volume = SpecMgrs.sound_mgr:GetVolume(self.sound_type) * scale
    end
end

function Sound:PlayAudioClipOneShot(sound_id)
    local sound_data = SpecMgrs.data_mgr:GetSoundData(sound_id)
    local sound_data = self:_GetSoundData(sound_id)
    if not sound_data then return end
    self.sound_id = sound_id
    self:_PlayAudioClipSync(sound_data, true)
end

function Sound:PlayAudioClip(sound_id)
    if self._audio_clip_co then
        coroutine.clear(self._audio_clip_co)
        self._audio_clip_co = nil
    end
    local sound_data = self:_GetSoundData(sound_id)
    if not sound_data then return end
    self.sound_id = sound_id
    if self.is_async_load then
        self:_PlayAudioClipAsync(sound_data)
    else
        self:_PlayAudioClipSync(sound_data)
    end
end

function Sound:_GetSoundData(sound_id)
    local sound_data = SpecMgrs.data_mgr:GetSoundData(sound_id)
    if not sound_data then
        PrintError("Sound: None Found SoundData:", sound_id)
        self:PlayAudioClipFinish()
        return
    end
    return sound_data
end

function Sound:Play()
    self.is_pause = nil
    if self.audio_comp then
        self.audio_comp:Play()
    end
end

function Sound:Pause()
    self.is_pause = true
    if self.audio_comp then
        self.audio_comp:Pause()
    end
end

function Sound:_PlayAudioClipAsync(sound_data)
    self._audio_clip_co = coroutine.start(self._CoPlayBGSound, self, sound_data)
end

function Sound:_CoPlayBGSound(sound_data)
    local audio_clip = SpecMgrs.res_mgr:CoGetAudioClip(sound_data.res_path)
    if audio_clip then
        self:_Play(audio_clip)
    else
        PrintError("Sound: None Found AudioClip:", sound_data.id, sound_data.res_path)
    end
    self._audio_clip_co = nil
end

function Sound:_PlayAudioClipSync(sound_data, is_one_shot)
    local audio_clip = SpecMgrs.res_mgr:GetAudioClipSync(sound_data.res_path)
    if audio_clip == nil then
        PrintError("Sound: None Found AudioClip:", sound_data.id, sound_data.res_path)
        return
    end
    if is_one_shot then
        self:_PlayOneShot(audio_clip)
    else
        self:_Play(audio_clip)
    end
end

function Sound:_Play(audio_clip)
    local clip_time = audio_clip.length
    local clip_info = {
        audio_clip = audio_clip,
        clip_time = clip_time,
        pitch = self.pitch,
    }
    if self.is_loop then
        clip_info.begin_time = self.begin_time % clip_time
    else
        clip_info.begin_time = math.min(self.begin_time, clip_time - 0.01)
        clip_info.cur_clip_time = clip_info.begin_time
    end
    self.cur_clip_info = clip_info
    self:_SetAudioComp(clip_info)
end

function Sound:_SetAudioComp(clip_info)
    if clip_info then
        self.audio_comp.clip = clip_info.audio_clip
        self.audio_comp.time = clip_info.begin_time
        if not self.is_pause then
            self.audio_comp:Play()
        end
    end
end

function Sound:_PlayOneShot(audio_clip)
    if self.auto_destroy then
        local clip_time = audio_clip.length
        local clip_info = {
            audio_clip = audio_clip,
            clip_time = clip_time,
            pitch = self.pitch,
        }
        clip_info.begin_time = self.begin_time
        clip_info.cur_clip_time = clip_info.begin_time
        self.cur_clip_info = clip_info
    end
    self.audio_comp:PlayOneShot(audio_clip)
end

function Sound:PlayAudioClipFinish()
    self.cur_clip_info = nil
    if self.auto_destroy then
        SpecMgrs.sound_mgr:_DestroySoundByGuid(self.guid)
    end
end

function Sound:Update(delta_time)
    if not self.is_pause and self.cur_clip_info then
        local clip_info = self.cur_clip_info
        if clip_info.cur_clip_time then
            clip_info.cur_clip_time = clip_info.cur_clip_time + delta_time
            if clip_info.cur_clip_time >= clip_info.clip_time then
                self:PlayAudioClipFinish()
                return
            end
        end
    end
end

function Sound:DoDestroy()
    self.is_destroy = true
    self.cur_clip_info = nil
    if not IsNil(self.audio_go) then
        SpecMgrs.res_mgr:ReturnGameObject(self.audio_go)
        self.audio_go = nil
    end
end

return Sound