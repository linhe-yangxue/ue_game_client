local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local LuxuryHouseUI = require("UI.LuxuryHouseUI")
local MarryTipUI = class("UI.MarryTipUI",UIBase)

--  喜结连理ui
function MarryTipUI:DoInit()
    MarryTipUI.super.DoInit(self)
    self.prefab_path = "UI/Common/MarryTipUI"
end

function MarryTipUI:OnGoLoadedOk(res_go)
    MarryTipUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function MarryTipUI:Show(child_info)
    self.child_info = child_info
    if self.is_res_ok then
        self:InitUI()
    end
    MarryTipUI.super.Show(self)
end

function MarryTipUI:InitRes()
    self:AddClick(self.main_panel:FindChild("Mask"), function()
        local resp_cb = function(resp)
            if (resp.errcode ~= 1) then
                if not LuxuryHouseUI.ShowMarryTip() then
                    self:Hide()
                end
            else
                self:Hide()
            end
        end
        SpecMgrs.msg_mgr:SendConfirmMarry({child_id = self.child_info.child_id}, resp_cb)
    end)

    self.panel = self.main_panel:FindChild("ConfirmPanel")
    self.spouse_image = self.panel:FindChild("SpouseImage")
    self.left_unit_point = self.panel:FindChild("LeftUnitPoint")
    self.right_unit_point = self.panel:FindChild("RightIUnitPoint")
    self.left_child_msg = self.panel:FindChild("LeftChildMsg")
    self.right_child_msg = self.panel:FindChild("RightChildMsg")

    self.left_name_text = self.main_panel:FindChild("ConfirmPanel/LeftChildMsg/LeftNameText"):GetComponent("Text")
    self.left_child_grade_text = self.main_panel:FindChild("ConfirmPanel/LeftChildMsg/LeftChildGradeText"):GetComponent("Text")
    self.left_total_talent_text = self.main_panel:FindChild("ConfirmPanel/LeftChildMsg/LeftTotalTalentText"):GetComponent("Text")
    self.left_total_attr_text = self.main_panel:FindChild("ConfirmPanel/LeftChildMsg/LeftTotalAttrText"):GetComponent("Text")
    self.right_name_text = self.main_panel:FindChild("ConfirmPanel/RightChildMsg/RightNameText"):GetComponent("Text")
    self.right_child_grade_text = self.main_panel:FindChild("ConfirmPanel/RightChildMsg/RightChildGradeText"):GetComponent("Text")
    self.right_total_talent_text = self.main_panel:FindChild("ConfirmPanel/RightChildMsg/RightTotalTalentText"):GetComponent("Text")
    self.right_total_attr_text = self.main_panel:FindChild("ConfirmPanel/RightChildMsg/RightTotalAttrText"):GetComponent("Text")
    self.time_text = self.main_panel:FindChild("ConfirmPanel/TimeText"):GetComponent("Text")
    self.target_family_text = self.main_panel:FindChild("ConfirmPanel/TargetFamilyText"):GetComponent("Text")

    self.left_full_unit_point = self.panel:FindChild("LeftFullUnitPoint")
    self.right_full_unit_point = self.panel:FindChild("RightFullUnitPoint")
end

function MarryTipUI:InitUI()
    self:UpdateUIInfo()
    SpecMgrs.ui_mgr:ShowShareUI()
end

function MarryTipUI:UpdateUIInfo()
    local child_data = SpecMgrs.data_mgr:GetChildQualityData(self.child_info.grade)

    self.left_name_text.text = self.child_info.name
    self.left_child_grade_text.text = string.format(UIConst.Text.CHILD_GRADE, child_data.quality_text[self.child_info.sex])
    self.left_total_talent_text.text = string.format(UIConst.Text.CHILD_ALL_TALENT_VAL, table.sum(self.child_info.aptitude_dict))
    self.left_total_attr_text.text = string.format(UIConst.Text.CHILD_ALL_ATTR_VAL, table.sum(self.child_info.attr_dict))

    child_data = SpecMgrs.data_mgr:GetChildQualityData(self.child_info.marry.grade)
    self.right_name_text.text = self.child_info.marry.role_name
    self.right_child_grade_text.text = string.format(UIConst.Text.CHILD_GRADE, child_data.quality_text[self.child_info.marry.sex])
    self.right_total_talent_text.text = string.format(UIConst.Text.CHILD_ALL_TALENT_VAL, table.sum(self.child_info.marry.aptitude_dict))
    self.right_total_attr_text.text = string.format(UIConst.Text.CHILD_ALL_ATTR_VAL, table.sum(self.child_info.marry.attr_dict))
    self.time_text.text = os.date("%Y-%m-%d",self.child_info.marry.marry_time)
    self.target_family_text.text = string.format(UIConst.Text.TARGET_FAMILY, self.child_info.marry.role_name)

    local _, couple_unit = ComMgrs.dy_data_mgr.child_center_data:GetChildUnitId(self.child_info)
    self:AddHeadUnit(couple_unit[1], self.left_unit_point):StopAllAnimationToCurPos()
    self:AddHeadUnit(couple_unit[2], self.right_unit_point):StopAllAnimationToCurPos()

    self:AddHalfUnit(couple_unit[1], self.left_full_unit_point)
    self:AddHalfUnit(couple_unit[2], self.right_full_unit_point)
end

function MarryTipUI:Hide()
    self:DelAllCreateUIObj()
    MarryTipUI.super.Hide(self)
end

return MarryTipUI
