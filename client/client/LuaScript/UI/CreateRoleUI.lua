local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local CSConst = require("CSCommon.CSConst")
local LoopListCmp = require("UI.UICmp.LoopListCmp")
local CSFunction = require("CSCommon.CSFunction")
local SoundConst = require("Sound.SoundConst")
local CreateRoleUI = class("UI.CreateRoleUI",UIBase)

local kCutSceneBgmChangeTime = 25
local kSkipAnimTime = 21
local kCaptionState = {
    Disable = 0,
    Show = 1,
}
local kCutSceneSoundEffectTime = {
    ["226"] = 0.5,        -- 香烟
    ["227"] = 4.9,       -- 打枪
    ["228"] = 5,        -- 碎玻璃
    ["229"] = 8.5,      -- 子弹飞
    ["230"] = 12.3,        -- 子弹击中
    ["231"] = 14.8,        -- 玻璃杯落地
    ["232"] = 16.9,        -- 打雷
    ["233"] = 19,        -- 鸟叫
}

function CreateRoleUI:DoInit()
    CreateRoleUI.super.DoInit(self)
    self.prefab_path = "UI/Common/CreateRoleUI"

    self.drag_min_dis = 30
    self.man_head_obj_list = {}
    self.woman_head_obj_list = {}
    self.is_drag_head = false
    self.cur_select_index = 0

    self.sound_timer_dict = {}
end

function CreateRoleUI:OnGoLoadedOk(res_go)
    CreateRoleUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function CreateRoleUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    CreateRoleUI.super.Show(self)
end

function CreateRoleUI:InitRes()
    self.cut_scene_anim = self.go:FindChild("Bg/guochangdonghua"):GetComponent("SkeletonAnimation").AnimationState

    self.caption_item = self.main_panel:FindChild("Caption")
    self.caption_anim_cmp = self.caption_item:GetComponent("UITweenAlpha")
    self.caption_fade_time = self.caption_anim_cmp:GetDurationTime()
    self.caption_disable_alpha = self.caption_anim_cmp.from_
    self.caption_active_alpha = self.caption_anim_cmp.to_
    self.caption_text = self.caption_item:GetComponent("Text")
    self.role_image = self.main_panel:FindChild("RoleImage")
    self.content = self.main_panel:FindChild("Content")
    -- 跳过
    self.content_tween_cmp = self.content:GetComponent("UITweenBase")
    self.role_tween_cmp = self.role_image:GetComponent("UITweenBase")
    -- self.skip_btn = self.main_panel:FindChild("Skip")
    -- self:AddClick(self.skip_btn, function ()
    --     self:RemoveTimer()
    --     self.cut_scene_anim:PlayAnimation(0, "bofang1", true, 3.467)
    --     self.content_tween_cmp:SetDelayTime(2.7)
    --     self.content_tween_cmp:Play()
    --     self.role_tween_cmp:SetDelayTime(0)
    --     self.role_tween_cmp:Play()
    --     self.skip_btn:SetActive(false)
    --     self.mask_timer = self:AddTimer(function ()
    --         self.mask:SetActive(false)
    --     end, self.role_tween_cmp:GetDurationTime(), 1)
    -- end)

    self.mask = self.main_panel:FindChild("Mask")
    self.name_input_field = self.content:FindChild("SelectRolePanel/NameInputField"):GetComponent("InputField")
    self.name_input_field_text = self.content:FindChild("SelectRolePanel/NameInputField/NameInputFieldText"):GetComponent("Text")
    self.random_button = self.content:FindChild("SelectRolePanel/RandomButton")
    self:AddClick(self.random_button, function()
        SpecMgrs.msg_mgr:SendQueryRandomName({sex = self.is_man and 1 or 2}, function (resp)
            self.name_input_field.text = resp.role_name
        end)
    end)
    self.man_role_head_list = self.content:FindChild("SelectRolePanel/ManRoleHeadList")
    self.woman_role_head_list = self.content:FindChild("SelectRolePanel/WomanRoleHeadList")
    self.same_tip_text = self.content:FindChild("SameTipText"):GetComponent("Text")
    self.start_game_button = self.content:FindChild("Image/StartGameButton")
    self:AddCooldownClick(self.start_game_button, function()
        local name = self.name_input_field.text
        if name == "" then return end
        local ret, err = CSFunction.check_player_name_legality(name)
        if not ret then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.NAME_ERROR_STR[err])
            return
        end
         SpecMgrs.msg_mgr:SendCreateRole({urs = ComMgrs.dy_data_mgr.urs, role_name = self.name_input_field.text, role_id = self.cur_role_id}, function (resp)
            if resp.errcode ~= 0 then
                if resp.name_repeat then
                    SpecMgrs.ui_mgr:ShowMsgBox(UIConst.RoleNameRepeat)
                else
                    SpecMgrs.ui_mgr:ShowMsgBox(UIConst.FailedToCreateRole)
                end
            else
                SpecMgrs.ui_mgr:ShowUI("SelectFlagUI")
            end
        end)
    end)
    self.start_game_button_text = self.content:FindChild("Image/StartGameButton/StartGameButtonText"):GetComponent("Text")
    self.man_button = self.content:FindChild("ManButton")
    self:AddClick(self.man_button, function()
        self:ShowManRoleList()
    end)
    self.woman_button = self.content:FindChild("WomanButton")
    self:AddClick(self.woman_button, function()
        self:ShowWomanRoleList()
    end)
    self.man_role_list = self.content:FindChild("SelectRolePanel/ManRoleHeadList")
    self.woman_role_list = self.content:FindChild("SelectRolePanel/WomanRoleHeadList")
    self.head_obj = self.content:FindChild("Temp/HeadImage")
end

function CreateRoleUI:InitUI()
    self:PlayCutscene()
    self:SetTextVal()
    self:UpdateData()
    self:UpdateUIInfo()
    self:ShowManRoleList()
end

function CreateRoleUI:PlayCutscene()
    self.cut_scene_anim:PlayAnimation(0, "bofang", false, 0)
    self:PlayBGM(SoundConst.SOUND_ID_Cutscene)
    self:PlayCutsceneSound()
    self.anim_time = 0
    self.cut_scene_anim:AddAnim(0, "bofang1", true, 0, 1)
    self.skip_timer = self:AddTimer(function ()
        self:RemoveCutSceneSound()
        self:PlayBGM(SoundConst.SOUND_ID_CreateRole)
    end, kCutSceneBgmChangeTime, 1)
    self.mask_timer = self:AddTimer(function ()
        self.mask:SetActive(false)
    end, self.content_tween_cmp:GetDelayTime() + self.content_tween_cmp:GetDurationTime(), 1)
end

function CreateRoleUI:PlayCutsceneSound()
    for sound_id, delay in pairs(kCutSceneSoundEffectTime) do
        local sound_timer = self:AddTimer(function ()
            self.anim_sound = SpecMgrs.sound_mgr:PlaySFXSound(sound_id, false, false, "cutscene")
            self.sound_timer_dict[sound_id] = nil
        end, delay)
        self.sound_timer_dict[sound_id] = sound_timer
    end
end

function CreateRoleUI:RemoveCutSceneSound()
    for _, timer in pairs(self.sound_timer_dict) do
        self:RemoveTimer(timer)
    end
    self.sound_timer_dict = {}
    if self.anim_sound then
        SpecMgrs.sound_mgr:DestroySound(self.anim_sound)
        self.anim_sound = nil
    end
end

function CreateRoleUI:PlayCaptionFadeAnim(is_fade_in)
    if is_fade_in then
        self:RemoveCaptionFadeTimer()
        self.caption_item:SetActive(true)
    else
        self.capiton_fade_timer = self:AddTimer(function ()
            self.caption_item:SetActive(false)
            self.capiton_fade_timer = nil
        end, self.caption_fade_time)
    end
    self.caption_anim_cmp.from_ = is_fade_in and self.caption_disable_alpha or self.caption_active_alpha
    self.caption_anim_cmp.to_ = is_fade_in and self.caption_active_alpha or self.caption_disable_alpha
    self.caption_anim_cmp:Play()
end

function CreateRoleUI:RemoveCaptionFadeTimer()
    if self.capiton_fade_timer then
        self:RemoveTimer(self.capiton_fade_timer)
        self.capiton_fade_timer = nil
    end
end

function CreateRoleUI:SkipCutScene()
    if not self.skip_timer then return end
    self:ClearTimer()
    self:RemoveCutSceneSound()
    self.cut_scene_anim:PlayAnimation(0, "bofang1", true, 3.467)
    self:PlayBGM(SoundConst.SOUND_ID_CreateRole)
    self.anim_time = kSkipAnimTime
    self.content_tween_cmp:SetDelayTime(2.7)
    self.content_tween_cmp:Play()
    self.role_tween_cmp:SetDelayTime(0)
    self.role_tween_cmp:Play()
    self.mask_timer = self:AddTimer(function ()
        self.mask:SetActive(false)
    end, self.role_tween_cmp:GetDurationTime(), 1)
end

function CreateRoleUI:SetTextVal()
    self.name_input_field_text.text = UIConst.Text.NAME_INPUT_FIELD_TEXT
    self.start_game_button_text.text = UIConst.Text.NEXT_STEP
    self.same_tip_text.text = UIConst.Text.ROLE_NAME_REPEAT
end

function CreateRoleUI:UpdateData()
    self.role_id = self.role_id or 1
    self.role_data = SpecMgrs.data_mgr:GetRoleLookData(self.role_id)

    self.man_role_look_list = SpecMgrs.data_mgr:GetMaleRoleList()
    self.woman_role_look_list = SpecMgrs.data_mgr:GetFemaleRoleList()
end

function CreateRoleUI:UpdateUIInfo()
    -- self:AddDrag(self.role_image, function(delta_pos)
    --     self:DragList(self.is_man, delta_pos)
    -- end)
    self.man_loop_list_cmp = nil
    self.woman_loop_list_cmp = nil

    self:DelObjDict(self.man_head_obj_list)
    self:DelObjDict(self.woman_head_obj_list)
    self.man_head_obj_list = {}
    self.woman_head_obj_list = {}
    self:CreateSelectRoleList(true)
    self:CreateSelectRoleList(false)
end

function CreateRoleUI:CreateSelectRoleList(is_man)
    local role_data = is_man and self.man_role_look_list or self.woman_role_look_list
    local role_list_content = is_man and self.man_role_list or self.woman_role_list
    local obj_list = is_man and self.man_head_obj_list or self.woman_head_obj_list
    for i, data in ipairs(role_data) do
        local item = self:GetUIObject(self.head_obj, role_list_content, false)
        local image_comp = item:FindChild("HeadImage"):GetComponent("Image")
        local unit_data = SpecMgrs.data_mgr:GetUnitData(data.unit_id)
        UIFuncs.AssignSpriteByIconID(data.unlocked == true and data.head_icon_id or data.unlock_icon, image_comp)
        table.insert(obj_list, item)
        --  item优先判断拖拽
        -- self:AddDrag(item, function(delta_pos)
        --     self:DragList(is_man, delta_pos)
        -- end)
        -- self:AddRelease(item, function()
        --     self.is_drag_head = false
        -- end)
        if data.unlocked then
            self:AddClick(item, function()
                if self.is_drag_head then return end
                if self.cur_role_id == data.role_look_id then return end
                if is_man then
                    self.man_loop_list_cmp:SelectIndex(i)
                else
                    self.woman_loop_list_cmp:SelectIndex(i)
                end
                self.cur_role_id = data.role_look_id
                self:RemoveCurUnit()
                self.cur_unit = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = data.unit_id, parent = self.role_image})
                self.cur_unit:SetPositionByRectName({parent = self.role_image, name = "full"})
                if self.cur_select_item then
                    self:RemoveUIEffect(item)
                end
                self:AddSelectEffect(item)
            end)
        end
    end
    -- self:AddDrag(role_list_content, function(delta_pos)
    --     self:DragList(is_man, delta_pos)
    -- end)

    self:AddRelease(self.main_panel, function()
        self.is_drag_head = false
    end)
    self.cur_select_index = 1
    --obj_list[1]:FindChild("SelectImage"):SetActive(true)
    local select_item_func = function(loop_comp, item_list)
        -- if item_list[self.cur_select_index] then
        --     item_list[self.cur_select_index]:FindChild("SelectImage"):SetActive(false)
        -- end
        local select_index = loop_comp:GetCurIndex()
        --item_list[select_index]:FindChild("SelectImage"):SetActive(true)
        self.cur_select_index = select_index
    end

    if is_man then
        self.man_loop_list_cmp = LoopListCmp.New()
        self.man_loop_list_cmp:DoInit(self, role_list_content)
        self.man_loop_list_cmp:Refresh(false)
        self.man_loop_list_cmp:ListenItemSelect(function()
            select_item_func(self.man_loop_list_cmp, obj_list)
        end)
    else
        self.woman_loop_list_cmp = LoopListCmp.New()
        self.woman_loop_list_cmp:DoInit(self, role_list_content)
        self.woman_loop_list_cmp:Refresh(false)
        self.woman_loop_list_cmp:ListenItemSelect(function()
            select_item_func(self.woman_loop_list_cmp, obj_list)
        end)
    end
end

function CreateRoleUI:DragList(is_man, delta_pos)
    if self.is_drag_head then return end
    local loop_list_cmp = is_man and self.man_loop_list_cmp or self.woman_loop_list_cmp
    if delta_pos.x > self.drag_min_dis then -- 右拉
        loop_list_cmp:SelectLast()
        self.is_drag_head = true
    elseif delta_pos.x < -self.drag_min_dis then
        loop_list_cmp:SelectNext()
    end
end

function CreateRoleUI:ShowManRoleList()
    if self.is_man then return end
    self.man_button:FindChild("SelectImage"):SetActive(true)
    self.woman_button:FindChild("SelectImage"):SetActive(false)
    self.man_role_list:SetActive(true)
    self.woman_role_list:SetActive(false)
    -- self.woman_head_obj_list[self.cur_select_index]:FindChild("SelectImage"):SetActive(false)
    -- self.man_head_obj_list[1]:FindChild("SelectImage"):SetActive(true)
    self.cur_select_index = 1
    self:RemoveCurUnit()
    self.cur_role_id = self.man_role_look_list[1].role_look_id
    self.cur_unit = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = self.man_role_look_list[1].unit_id, parent = self.role_image})
    self.cur_unit:SetPositionByRectName({parent = self.role_image, name = "full"})
    self.man_loop_list_cmp:SelectIndex(1, false)
    self.is_man = true
    self:AddSelectEffect(self.man_head_obj_list[1])
end

function CreateRoleUI:ShowWomanRoleList()
    if not self.is_man then return end
    self.man_button:FindChild("SelectImage"):SetActive(false)
    self.woman_button:FindChild("SelectImage"):SetActive(true)
    self.man_role_list:SetActive(false)
    self.woman_role_list:SetActive(true)
    -- self.man_head_obj_list[self.cur_select_index]:FindChild("SelectImage"):SetActive(false)
    -- self.woman_head_obj_list[1]:FindChild("SelectImage"):SetActive(true)
    self.cur_select_index = 1
    self:RemoveCurUnit()
    self.cur_role_id = self.woman_role_look_list[1].role_look_id
    self.cur_unit = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = self.woman_role_look_list[1].unit_id, parent = self.role_image})
    self.cur_unit:SetPositionByRectName({parent = self.role_image, name = "full"})
    self.woman_loop_list_cmp:SelectIndex(1, false)
    self.is_man = false
    self:AddSelectEffect(self.woman_head_obj_list[1])
end

function CreateRoleUI:GetCaptionDataByTime(anim_time)
    for _, caption_data in ipairs(SpecMgrs.data_mgr:GetCutSceneCaptionList()) do
        if anim_time < caption_data.end_time then
            return caption_data
        end
    end
end

function CreateRoleUI:Update(delta_time)
    if self.anim_time then
        self.anim_time = self.anim_time + delta_time
        local caption_data = self:GetCaptionDataByTime(self.anim_time)
        if self.cur_caption_data and self.anim_time > self.cur_caption_data.deadline then
            self:RemoveCaptionFadeTimer()
            self.caption_item:SetActive(false)
        elseif self.cur_caption_data and self.anim_time > self.cur_caption_data.end_time then
            self:PlayCaptionFadeAnim(false)
        end
        -- 字幕结束
        if not caption_data then
            self.cur_caption_data = nil
            self.anim_time = nil
            return
        end
        if not self.cur_caption_data or self.cur_caption_data.id ~= caption_data.id then
            self.cur_caption_data = caption_data
            self.cur_caption_state = kCaptionState.Disable
        end
        if self.anim_time > self.cur_caption_data.start_time then
            if self.cur_caption_state == kCaptionState.Disable then
                self.caption_text.text = self.cur_caption_data.content
                self:PlayCaptionFadeAnim(true)
                self.cur_caption_state = kCaptionState.Show
            end
        end
    end
end

function CreateRoleUI:AddSelectEffect(item)
    if self.cur_select_item then
        self:RemoveUIEffect(self.cur_select_item)
    end
    UIFuncs.AddSelectEffect(self, item)
    self.cur_select_item = item
end

function CreateRoleUI:RemoveCurUnit()
    if self.cur_unit then
        ComMgrs.unit_mgr:DestroyUnit(self.cur_unit)
        self.cur_unit = nil
    end
end

function CreateRoleUI:ClearTimer()
    if self.mask_timer then
        self:RemoveTimer(self.mask_timer)
    end
    self.mask_timer = nil
    if self.skip_timer then
        self:RemoveTimer(self.skip_timer)
    end
    self.skip_timer = nil
end

function CreateRoleUI:Hide()
    self:RemoveCutSceneSound()
    self:RemoveCaptionFadeTimer()
    self:DestroyRes()
    CreateRoleUI.super.Hide(self)
end

return CreateRoleUI