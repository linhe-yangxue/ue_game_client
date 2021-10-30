local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local NoticeRareAnimalUI = class("UI.NoticeRareAnimalUI", UIBase)

local kWaitTime = 10

function NoticeRareAnimalUI:DoInit()
    NoticeRareAnimalUI.super.DoInit(self)
    self.prefab_path = "UI/Common/NoticeRareAnimalUI"
    self.cancel_timer = 0
end

function NoticeRareAnimalUI:OnGoLoadedOk(res_go)
    NoticeRareAnimalUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function NoticeRareAnimalUI:InitRes()
    self.animal_image = self.main_panel:FindChild("Content/Animal"):GetComponent("Image")
    self.animal_name_text = self.main_panel:FindChild("Content/Animal/Name"):GetComponent("Text")
    self.animal_level_text = self.main_panel:FindChild("Content/Animal/Name/Level"):GetComponent("Text")
    self.main_panel:FindChild("Content/Animal/Text"):GetComponent("Text").text = UIConst.Text.RARE_ANIMAL_APPEAR_TEXT1
    self.main_panel:FindChild("Content/Animal/Text2"):GetComponent("Text").text = UIConst.Text.RARE_ANIMAL_APPEAR_TEXT2

    self.cancel_btn = self.main_panel:FindChild("Content/CancelBtn")
    self:AddClick(self.cancel_btn, function()
        self:Hide()
    end)
    self.cancel_btn_text = self.cancel_btn:FindChild("Text"):GetComponent("Text")
    self.main_panel:FindChild("Content/JoinBtn/Text"):GetComponent("Text").text = UIConst.Text.GOTO_TEXT
    self:AddClick(self.main_panel:FindChild("Content/JoinBtn"), function()
        self:Hide()
        SpecMgrs.ui_mgr:ShowUI("HuntingRareAnimalUI")
    end)
end

function NoticeRareAnimalUI:InitUI()
    self.cancel_timer = kWaitTime
    self.cancel_btn_text.text = string.format(UIConst.Text.CANCEL_COUNT_DOWN, math.ceil(self.cancel_timer))
    local animal_data = SpecMgrs.data_mgr:GetRareAnimalData(self.animal_id)
    local unit_data = SpecMgrs.data_mgr:GetUnitData(animal_data.unit_id)
    self:AssignSpriteByIconID(unit_data.icon, self.animal_image)
    self.animal_name_text.text = animal_data.name
    self.animal_level_text.text = string.format(UIConst.Text.LEVEL, animal_data.open_level)
end

function NoticeRareAnimalUI:Update(delta_time)
    if not self.cancel_timer then return end
    self.cancel_timer = self.cancel_timer - delta_time
    if self.cancel_timer <= 0 then
        self:Hide()
    else
        self.cancel_btn_text.text = string.format(UIConst.Text.CANCEL_COUNT_DOWN, math.ceil(self.cancel_timer))
    end
end

function NoticeRareAnimalUI:Show(animal_id)
    if not animal_id then return end
    self.animal_id = animal_id
    if self.is_res_ok then
        self:InitUI()
    end
    NoticeRareAnimalUI.super.Show(self)
end

function NoticeRareAnimalUI:Hide()
    self.animal_id = nil
    NoticeRareAnimalUI.super.Hide(self)
end

return NoticeRareAnimalUI