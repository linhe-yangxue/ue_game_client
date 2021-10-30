local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local SoundConst = require("Sound.SoundConst")
local EffectConst = require("Effect.EffectConst")
local SpoilUI = class("UI.SpoilUI",UIBase)

local default_resolution_x = 1080
local default_resolution_y = 1920

--  宠爱ui
function SpoilUI:DoInit()
    SpoilUI.super.DoInit(self)
    self.prefab_path = "UI/Common/SpoilUI"
    self.sex_sound = SpecMgrs.data_mgr:GetParamData("sex_sound").sound_id
    self.tou_anim = "tou"
    self.xiong_anim = "xiong"
    self.tui_anim = "tui"
    self.anim_transition_time = 0.3
    self.show_curtains_anim_time = 2
    self.show_lover_time = 7
end

function SpoilUI:OnGoLoadedOk(res_go)
    SpoilUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function SpoilUI:Show(lover_id, child_data, show_tip_list)
    self.lover_id = lover_id
    self.child_data = child_data
    self.show_tip_list = show_tip_list
    if self.is_res_ok then
        self:InitUI()
    end
    SpoilUI.super.Show(self)
end

function SpoilUI:InitRes()
    self.panel_canvans = self.main_panel:GetComponent("Canvas")
    self.bg_renderer = self.go:FindChild("Bg"):GetComponent("MeshRenderer")

    self.return_btn = self.main_panel:FindChild("ReturnButton")
    self.dialog_box = self.main_panel:FindChild("DialogBox")
    self.dialog_box_text = self.main_panel:FindChild("DialogBox/DialogBoxText"):GetComponent("Text")
    self.lover_pos = self.main_panel:FindChild("Lover")
    self.mask = self.main_panel:FindChild("Mask")
    self.mask_left = self.main_panel:FindChild("MaskLeft")
    self.mask_right = self.main_panel:FindChild("MaskRight")
    self.stand_lover = self.main_panel:FindChild("StandLover")
    self.fondle_time_tip_panel = self.main_panel:FindChild("Image")
    self.fondle_time_tip_text = self.main_panel:FindChild("Image/FondleTimeTipText"):GetComponent("Text")

    self.curtains_anim = self.main_panel:FindChild("CurtainsAnim")
    self.curtains_anim_rect = self.main_panel:FindChild("CurtainsAnim"):GetComponent("RectTransform")
    self:AddClick(self.return_btn, function()
        if self.cur_fondle_time > 0 then
            local param_tb = {
                content = UIConst.Text.NOT_FONDLE_TIP,
                confirm_cb = function()
                    self:ClickReturnBtn()
                end,
            }
            SpecMgrs.ui_mgr:ShowMsgSelectBox(param_tb)
            return
        end
        self:ClickReturnBtn()
    end)
    self.click_mask = self.main_panel:FindChild("ClickMask") -- 指引
end

function SpoilUI:ClickReturnBtn()
    if self.child_data then
        SpecMgrs.ui_mgr:ShowUI("BabyBornUI", self.child_data)
        SpecMgrs.ui_mgr:GetUI("BabyBornUI"):RegisterCloseBabyBornUI("SpoilUI", function()
            self:Hide()
        end)
        self.child_data = nil
    else
        self:Hide()
    end
end

function SpoilUI:InitUI()
    self:ClearRes()
    self:UpdateData()
    self:UpdateUIInfo()
    self.fondle_time_tip_panel:SetActive(false)
    self:UpdateBgSorting()
    SpecMgrs.ui_mgr:RegisterUIShowOkEvent("SpoilUI", function()  -- 有ui弹出时自身order会改变
        self:UpdateBgSorting()
    end, self)
end

function SpoilUI:UpdateBgSorting()
    self.panel_canvans.sortingOrder = self.canvas.sortingOrder + 1 -- 设置背景动画层级
    self.bg_renderer.sortingOrder = self.canvas.sortingOrder
end

function SpoilUI:UpdateData()
    self.can_send_fondle = true
    self.can_interaction = true
    self.max_fondle_time = SpecMgrs.data_mgr:GetParamData("lover_fondle_num_limit").f_value
    self.cur_fondle_time = self.max_fondle_time
    self.interaction_cd_time = SpecMgrs.data_mgr:GetParamData("spoil_interval").f_value
    self.lover_size = SpecMgrs.data_mgr:GetParamData("spoil_lover_size").f_value
    self.lover_data = SpecMgrs.data_mgr:GetLoverData(self.lover_id)
    self.dialog_list = self.lover_data.dialog
end

function SpoilUI:UpdateUIInfo()
    self.fondle_time_tip_text.text = string.format(UIConst.Text.FONDLE_TIME_TIP_FORMAT, self.cur_fondle_time, self.max_fondle_time)
    local default_aspect_ratio = default_resolution_y / default_resolution_x
    local cur_aspect_ratio = Screen.height / Screen.width
    if cur_aspect_ratio > default_aspect_ratio then
        self.curtains_anim_rect.localScale = Vector2.New(1, cur_aspect_ratio / default_aspect_ratio)
    else
        self.curtains_anim_rect.localScale = Vector2.New(default_aspect_ratio / cur_aspect_ratio, 1)
    end
    self.return_btn:SetActive(false)
    self.mask:SetActive(false)
    self.mask_left:SetActive(false)
    self.mask_right:SetActive(false)

    self.mask_left:SetActive(true)
    self.mask_right:SetActive(true)

    self.dialog_box:SetActive(false)

    self:AddFullUnit(self.lover_data.unit_id, self.stand_lover)

    local lover_unit_id = self.lover_data.spoil_model_id
    local pos_y = SpecMgrs.data_mgr:GetUnitData(lover_unit_id).spoil_pos_y
    local param_tb = {}
    param_tb.unit_id = lover_unit_id
    param_tb.position = Vector3(0, pos_y, self.pos_z)
    param_tb.layer_name = "UI"
    param_tb.scale = self.lover_size
    param_tb.parent = self.main_panel:FindChild("Lover")
    param_tb.need_sync_load = true

    self.lover_unit = ComMgrs.unit_mgr:CreateUnitAutoGuid(param_tb)
    self:AddTimer(function()
        self.curtains_anim:SetActive(true)
        self:PlayUISound(self.sex_sound)
    end, self.show_curtains_anim_time, 1)

    self:AddTimer(function()
        local param_tb = {
            effect_id = EffectConst.EF_ID_Lover_lover_particle,
        }
        self:AddUIEffect(self.main_panel, param_tb, false, true)
    end, 3, 1)
    self:AddTimer(function()
        self:AddClick(self.lover_unit.go:FindChild("tou"), function()
            self:ClickLover(self.tou_anim)
        end, SoundConst.SoundID.SID_NotPlaySound)
        self:AddClick(self.lover_unit.go:FindChild("tui"), function()
            self:ClickLover(self.tui_anim)
        end, SoundConst.SoundID.SID_NotPlaySound)
        self:AddClick(self.lover_unit.go:FindChild("xiong"), function()
            self:ClickLover(self.xiong_anim)
        end, SoundConst.SoundID.SID_NotPlaySound)
        self.return_btn:SetActive(true)

        self.dialog_box:SetActive(true)
        self:ClickDialog()
        if self.get_btn_cb then
            local val
            if self.btn_patch == UIConst.GuideButtonList.LoverFace then
                val = self.lover_unit.go:FindChild("tou")
            elseif self.btn_patch == UIConst.GuideButtonList.LoverBreast then
                val = self.lover_unit.go:FindChild("xiong")
            elseif self.btn_patch == UIConst.GuideButtonList.LoverBuns then
                val = self.lover_unit.go:FindChild("tui")
            end
            self.get_btn_cb(val)
        end
        self.is_model_load_ok = true  -- 新手指引需要
        if self.show_tip_list then
            for i, tip in ipairs(self.show_tip_list) do
                SpecMgrs.ui_mgr:ShowTipMsg(tip)
            end
        end
        self.fondle_time_tip_panel:SetActive(true)
    end, self.show_lover_time, 1)

    local param_tb = {
        effect_id = EffectConst.EF_ID_Lover_button,
    }
    self:AddUIEffect(self.return_btn, param_tb, false, true)
end

function SpoilUI:ClickLover(anim_name)
    if not self.can_interaction then return end
    if not self.can_send_fondle then return end
    if self.cur_fondle_time == 0 then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.NOT_FONDLE_TIME_TIP)
        return
    end
    self.can_interaction = false
    self:AddTimer(function()
        self.click_mask:SetActive(false)
        self.can_interaction = true
    end, self.interaction_cd_time, 1)
    self.lover_unit:PlayAnim(anim_name, false, self.anim_transition_time)
    self:ClickDialog()
    self:SendFondle()
    self.click_mask:SetActive(true)
end

function SpoilUI:SendFondle()
    self.can_send_fondle = false
    local cb = function(resp)
        self.cur_fondle_time = resp.fondle_num
        local str = string.format(UIConst.Text.ADD_POWER_POINT, resp.power_value)
        SpecMgrs.ui_mgr:ShowTipMsg(str)
        self.can_send_fondle = true
        self.fondle_time_tip_text.text = string.format(UIConst.Text.FONDLE_TIME_TIP_FORMAT, self.cur_fondle_time, self.max_fondle_time)
    end
    SpecMgrs.msg_mgr:SendFondleLover(nil, cb)
end

function SpoilUI:ClickDialog()
    self.dialog_box_text.text = self.dialog_list[math.random(1, #self.dialog_list)]
end

function SpoilUI:GetGuideBtn(button_type, cb)
    self.get_btn_cb = cb
    self.btn_patch = button_type
    if not self.is_model_load_ok then return end
    if self.get_btn_cb then
        local val
        if self.btn_patch == UIConst.GuideButtonList.LoverFace then
            val = self.lover_unit.go:FindChild("tou")
        elseif self.btn_patch == UIConst.GuideButtonList.LoverBreast then
            val = self.lover_unit.go:FindChild("xiong")
        elseif self.btn_patch == UIConst.GuideButtonList.LoverBuns then
            val = self.lover_unit.go:FindChild("tui")
        else
            val = self.go:FindChild(self.btn_patch) -- 直接获取
        end
        self.get_btn_cb(val)
    end
end

function SpoilUI:ClearRes()
    self.click_mask:SetActive(false)
    SpecMgrs.ui_mgr:UnregisterUIShowOkEvent("SpoilUI")
    if SpecMgrs.ui_mgr:GetUI("BabyBornUI") then
        SpecMgrs.ui_mgr:GetUI("BabyBornUI"):UnregisterCloseBabyBornUI("SpoilUI")
    end
    self.get_btn_cb = nil
    self.btn_patch = nil
    self.is_model_load_ok = nil
    self:RemoveUIEffect(self.return_btn)
    self:RemoveUIEffect(self.main_panel)
    if not IsNil(self.curtains_anim) then
        self.curtains_anim:SetActive(false)
    end
    if self.lover_unit then
        self:RemoveClick(self.lover_unit.go:FindChild("tou"))
        self:RemoveClick(self.lover_unit.go:FindChild("xiong"))
        self:RemoveClick(self.lover_unit.go:FindChild("tui"))
        ComMgrs.unit_mgr:DestroyUnit(self.lover_unit)
        self.lover_unit = nil
    end
    self:DelAllCreateUIObj()
    self:DestroyAllUnit()
end

function SpoilUI:Hide()
    self:ClearRes()
    ComMgrs.dy_data_mgr.lover_data:DispatchUpdateLoverSpoilStateEvent(false)
    SpoilUI.super.Hide(self)
end
return SpoilUI
