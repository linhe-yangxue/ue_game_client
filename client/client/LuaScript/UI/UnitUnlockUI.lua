local UIBase = require("UI.UIBase")
local UIFuncs = require("UI.UIFuncs")
local UIConst = require("UI.UIConst")

local UnitUnlockUI = class("UI.UnitUnlockUI", UIBase)

local show_share_wait_time = 2

function UnitUnlockUI:DoInit()
    UnitUnlockUI.super.DoInit(self)
    self.prefab_path = "UI/Common/UnitUnlockUI"
    self.hero_unlock_sound = SpecMgrs.data_mgr:GetParamData("get_hero_sound").sound_id
    self.lover_unlock_sound = SpecMgrs.data_mgr:GetParamData("get_lover_sound").sound_id
    self.unlock_unit_queue = Queue.New()
end

function UnitUnlockUI:OnGoLoadedOk(res_go)
    UnitUnlockUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
end

function UnitUnlockUI:Hide()
    self.cur_unlock_data = nil
    UnitUnlockUI.super.Hide(self)
end

function UnitUnlockUI:InitRes()
    self.hero_unlock_anim = self.main_panel:FindChild("hero_jiesuo")
    local unlock_content = self.hero_unlock_anim:FindChild("hero_jiesuo")
    self.hero_model = unlock_content:FindChild("HeroImg")
    self.hero_name = unlock_content:FindChild("HeroName/Name"):GetComponent("Text")
    self.hero_grade1 = unlock_content:FindChild("HeroName/HeroGrade"):GetComponent("Image")
    self.hero_grade2 = unlock_content:FindChild("HeroName/HeroGrade2"):GetComponent("Image")
    self.hero_card_bg_img = unlock_content:FindChild("HeroCardBg"):GetComponent("Image")
    self:AddClick(unlock_content:FindChild("Mask"), function ()
        self:PlayNextUnlockAnim(true)
    end)
    self.card_hero_unit_parent = self.main_panel:FindChild("hero_jiesuo/hero_jiesuo/HeroCardBg/UnitParent")
    self.lover_unlock_anim = self.main_panel:FindChild("lover_jiesuo")
    unlock_content = self.lover_unlock_anim:FindChild("lover_jiesuo_1")
    self.lover_model = unlock_content:FindChild("LoverImg")
    self.lover_name = unlock_content:FindChild("LoverName/Name"):GetComponent("Text")
    self.lover_grade1 = unlock_content:FindChild("LoverName/LoverGrade"):GetComponent("Image")
    self.lover_grade2 = unlock_content:FindChild("LoverName/LoverGrade2"):GetComponent("Image")
    self:AddClick(unlock_content:FindChild("Mask"), function ()
        self:PlayNextUnlockAnim(true)
    end)
end

function UnitUnlockUI:PlayUnitUnlockAnim(data)
    if self.cur_unlock_data then
        self.unlock_unit_queue:Enqueue(data)
        return
    end
    self.cur_unlock_data = data
    if self.cur_unlock_data.hero_id then
        self:PlayHeroUnlockAnim(self.cur_unlock_data.hero_id)
    elseif self.cur_unlock_data.lover_id then
        self:PlayLoverUnlockAnim(self.cur_unlock_data.lover_id)
    end
    self:AddTimer(function()
        SpecMgrs.ui_mgr:ShowShareUI()
    end, show_share_wait_time, 1)
end

function UnitUnlockUI:PlayHeroUnlockAnim(hero_id)
    local hero_data = SpecMgrs.data_mgr:GetHeroData(hero_id)
    if not hero_data then self:PlayNextUnlockAnim() end
    local unit_data = SpecMgrs.data_mgr:GetUnitData(hero_data.unit_id)
    self.hero_unit = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = hero_data.unit_id, parent = self.hero_model})
    self.hero_unit:SetPositionByRectName({parent = self.hero_model, name = "full"})
    self.card_hero_unit = self:AddCardUnit(hero_data.unit_id, self.card_hero_unit_parent)
    self.card_hero_unit:StopAllAnimationToCurPos()
    local quality_data = SpecMgrs.data_mgr:GetQualityData(hero_data.quality)
    self.hero_name.text = hero_data.name
    UIFuncs.AssignSpriteByIconID(quality_data.hero_card_bg, self.hero_card_bg_img)
    UIFuncs.AssignSpriteByIconID(quality_data.grade, self.hero_grade1)
    UIFuncs.AssignSpriteByIconID(quality_data.grade, self.hero_grade2)
    self.hero_unlock_anim:SetActive(true)
    self:PlayUISound(self.hero_unlock_sound)
end

function UnitUnlockUI:PlayLoverUnlockAnim(lover_id)
    local lover_data = SpecMgrs.data_mgr:GetLoverData(lover_id)
    if not lover_data then self:PlayNextUnlockAnim() end
    self.lover_unit = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = lover_data.unit_id, parent = self.lover_model})
    self.lover_unit:SetPositionByRectName({parent = self.lover_model, name = "full"})
    self.lover_name.text = lover_data.name
    local quality_data = SpecMgrs.data_mgr:GetQualityData(lover_data.quality)
    UIFuncs.AssignSpriteByIconID(quality_data.grade, self.lover_grade1)
    UIFuncs.AssignSpriteByIconID(quality_data.grade, self.lover_grade2)
    self.lover_unlock_anim:SetActive(true)
    self:PlayUISound(self.lover_unlock_sound)
end

function UnitUnlockUI:PlayNextUnlockAnim(is_success)
    if is_success then
        if self.cur_unlock_data.finish_cb then self.cur_unlock_data.finish_cb() end
        if self.lover_unit then
            ComMgrs.unit_mgr:DestroyUnit(self.lover_unit)
            self.lover_unit = nil
            self.lover_unlock_anim:SetActive(false)
        end
        if self.hero_unit then
            self:RemoveUnit(self.card_hero_unit)
            ComMgrs.unit_mgr:DestroyUnit(self.hero_unit)
            self.hero_unit = nil
            self.hero_unlock_anim:SetActive(false)
        end
    end
    self.cur_unlock_data = nil
    if self.unlock_unit_queue:Count() > 0 then
        self:PlayUnitUnlockAnim(self.unlock_unit_queue:Dequeue())
    else
        SpecMgrs.ui_mgr:HideUI(self)
    end
end

return UnitUnlockUI