local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local EventUtil = require("BaseUtilities.EventUtil")
local BabyBornUI = class("UI.BabyBornUI",UIBase)

EventUtil.GeneratorEventFuncs(BabyBornUI, "CloseBabyBornUI")
EventUtil.GeneratorEventFuncs(BabyBornUI, "CancelBabyBornUI")
EventUtil.GeneratorEventFuncs(BabyBornUI, "GotoChildCenterUI")

--  生孩子提示ui
function BabyBornUI:DoInit()
    BabyBornUI.super.DoInit(self)
    self.prefab_path = "UI/Common/BabyBornUI"

    self.dy_lover_data = ComMgrs.dy_data_mgr.lover_data
end

function BabyBornUI:OnGoLoadedOk(res_go)
    BabyBornUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function BabyBornUI:Show(child_data)
    self.child_data = child_data
    if self.is_res_ok then
        self:InitUI()
    end
    BabyBornUI.super.Show(self)
end

function BabyBornUI:InitRes()
    self.baby_img = self.main_panel:FindChild("BabyImage"):GetComponent("Image")
    self.mother_describe_text = self.main_panel:FindChild("MotherDescribeText"):GetComponent("Text")
    self.child_talent_text = self.main_panel:FindChild("ChildTalentText"):GetComponent("Text")
    self.confirm_button_text = self.main_panel:FindChild("ConfirmButton/Text"):GetComponent("Text")
    self.cancel_button_text = self.main_panel:FindChild("CancelButton/Text"):GetComponent("Text")

    self:AddClick(self.main_panel:FindChild("CancelButton"), function()
        SpecMgrs.ui_mgr:HideUI(self)
        self:DispatchCloseBabyBornUI(self)
        self:DispatchCancelBabyBornUI(self)
    end)
    self:AddClick(self.main_panel:FindChild("ConfirmButton"), function()
        --  上书房 抚养
        SpecMgrs.ui_mgr:ShowUI("ChildCenterUI")
        SpecMgrs.ui_mgr:HideUI(self)
        self:DispatchCloseBabyBornUI(self)
        self:DispatchGotoChildCenterUI(self)
    end)
end

function BabyBornUI:InitUI()
    self:SetTextVal()
    self:UpdateUIInfo()
    if self.child_data.child_id ~= 1 then  -- 第二次生孩子才显示分享ui
        SpecMgrs.ui_mgr:ShowShareUI()
    end
end

function BabyBornUI:UpdateUIInfo()
    local display_data = SpecMgrs.data_mgr:GetChildDisplayData(self.child_data.display_id)
    UIFuncs.AssignSpriteByIconID(display_data.baby_img, self.baby_img)
    local mother_name = SpecMgrs.data_mgr:GetLoverData(self.child_data.mother_id).name
    local mother_level = self.dy_lover_data:GetLoverInfo(self.child_data.mother_id).level
    local talent_text = SpecMgrs.data_mgr:GetChildQualityData(self.child_data.grade).text
    self.mother_describe_text.text = string.format(UIConst.Text.MOTHER_DESCRIBE_FORMAL, mother_name, mother_level)
    self.child_talent_text.text = string.format(UIConst.Text.CHILD_TALENT_FORMAL, talent_text)
end

function BabyBornUI:SetTextVal()
    self.confirm_button_text.text = UIConst.Text.GO_TO_NAMING
    self.cancel_button_text.text = UIConst.Text.WAIT_TO_NAMING
end

function BabyBornUI:Hide()
    BabyBornUI.super.Hide(self)
end

return BabyBornUI
