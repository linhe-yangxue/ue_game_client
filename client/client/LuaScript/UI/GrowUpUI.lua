local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local UnitConst = require("Unit.UnitConst")

local GrowUpUI = class("UI.GrowUpUI", UIBase)

function GrowUpUI:DoInit()
    GrowUpUI.super.DoInit(self)
    self.prefab_path = "UI/Common/GrowUpUI"
    self.dy_child_center_data = ComMgrs.dy_data_mgr.child_center_data
    self.dy_lover_data = ComMgrs.dy_data_mgr.lover_data
end

function GrowUpUI:OnGoLoadedOk(res_go)
    GrowUpUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function GrowUpUI:Show(child)
    self.grow_up_child = child
    if self.is_res_ok then
        self:InitUI()
    end
    GrowUpUI.super.Show(self)
end

function GrowUpUI:Hide()
    if self.child_unit then
        ComMgrs.unit_mgr:DestroyUnit(self.child_unit)
        self.child_unit = nil
    end
    GrowUpUI.super.Hide(self)
end

function GrowUpUI:InitRes()
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "GrowUpUI")

    self.grow_up_panel = self.main_panel:FindChild("GrowUpPanel")
    self.grow_up_panel:FindChild("ChildDialog/DialogText"):GetComponent("Text").text = UIConst.Text.GROW_UP_DIALOG
    self.jue_text = self.grow_up_panel:FindChild("Jue/Text"):GetComponent("Text")
    self.adult_model = self.grow_up_panel:FindChild("AdultModel")

    local info_panel = self.grow_up_panel:FindChild("AdultInfoPanel")
    local icon_panel = info_panel:FindChild("IconPanel")
    self.adult_icon = icon_panel:FindChild("AdultIcon"):GetComponent("Image")
    self.adult_name = icon_panel:FindChild("AdultName"):GetComponent("Text")

    local basic_info_panel = info_panel:FindChild("InfoPanel")
    basic_info_panel:FindChild("MotherPanel/Text"):GetComponent("Text").text = UIConst.Text.MOTHER_TEXT
    self.adult_mother_name = basic_info_panel:FindChild("MotherPanel/MotherName"):GetComponent("Text")
    basic_info_panel:FindChild("IntimatePanel/Text"):GetComponent("Text").text = UIConst.Text.INTIMACY_VAL_TEXT
    self.adult_intimate = basic_info_panel:FindChild("IntimatePanel/Intimate/Count"):GetComponent("Text")
    basic_info_panel:FindChild("TalentTitlePanel/Text"):GetComponent("Text").text = UIConst.Text.TALENT_TEXT
    self.adult_talent_title = basic_info_panel:FindChild("TalentTitlePanel/TalentTitle"):GetComponent("Text")

    basic_info_panel:FindChild("TotalAptitudePanel/Text"):GetComponent("Text").text = UIConst.Text.TOTAL_APTITUDE
    self.adult_total_aptitude = basic_info_panel:FindChild("TotalAptitudePanel/TotalAptitude"):GetComponent("Text")
    basic_info_panel:FindChild("TotalAttrPanel/Text"):GetComponent("Text").text = UIConst.Text.TOTAL_ATTR
    self.adult_total_attr = basic_info_panel:FindChild("TotalAttrPanel/TotalAttr"):GetComponent("Text")
    basic_info_panel:FindChild("BusinessPanel/Text"):GetComponent("Text").text = UIConst.Text.BUSINESS_ATTR
    self.adult_business_attr = basic_info_panel:FindChild("BusinessPanel/BusinessAttr"):GetComponent("Text")
    basic_info_panel:FindChild("TechnologyPanel/Text"):GetComponent("Text").text = UIConst.Text.MANAGEMENT_ATTR
    self.adult_management_attr = basic_info_panel:FindChild("TechnologyPanel/TechnologyAttr"):GetComponent("Text")
    basic_info_panel:FindChild("RenownPanel/Text"):GetComponent("Text").text = UIConst.Text.FAME_ATTR
    self.adult_renown_attr = basic_info_panel:FindChild("RenownPanel/RenownAttr"):GetComponent("Text")
    basic_info_panel:FindChild("FightPanel/Text"):GetComponent("Text").text = UIConst.Text.BATTLE_ATTR
    self.adult_fight_attr = basic_info_panel:FindChild("FightPanel/FightAttr"):GetComponent("Text")
    local submit_btn = self.grow_up_panel:FindChild("SubmitBtn")
    submit_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CONFIRM
    self:AddClick(submit_btn, function ()
        self:Hide()
    end)
end

function GrowUpUI:InitUI()
    if not self.grow_up_child then
        self:Hide()
    else
        self:InitGrowUpPanel()
    end
end

function GrowUpUI:InitGrowUpPanel()
    local grow_up_child = self.grow_up_child.child_id and self.grow_up_child or self.dy_child_center_data:GetAdultChildDataById(self.grow_up_child)
    local exp_data = SpecMgrs.data_mgr:GetChildExpData(grow_up_child.level)
    local grade_data = SpecMgrs.data_mgr:GetChildQualityData(grow_up_child.grade)
    -- 爵位 
    self.jue_text.text = SpecMgrs.data_mgr:GetChildQualityData(grow_up_child.grade).quality_text[grow_up_child.sex]
    local unit_id = self.dy_child_center_data:GetChildUnitId(grow_up_child)
    self.child_unit = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = unit_id, parent = self.adult_model})
    self.child_unit:SetPositionByRectName({parent = self.adult_model, name = UnitConst.UnitRect.Full})
    UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetUnitData(unit_id).icon, self.adult_icon)
    self.adult_name.text = grow_up_child.name
    self.adult_mother_name.text = SpecMgrs.data_mgr:GetLoverData(grow_up_child.mother_id).name
    self.adult_intimate.text = self.dy_lover_data:GetLoverInfo(grow_up_child.mother_id).level

    self.adult_talent_title.text = grade_data.text
    local aptitude_data = grow_up_child.aptitude_dict
    self.adult_total_aptitude.text = aptitude_data.business + aptitude_data.management + aptitude_data.renown + aptitude_data.fight
    local attr_data = grow_up_child.attr_dict
    self.adult_total_attr.text = attr_data.business + attr_data.management + attr_data.renown + attr_data.fight
    self.adult_business_attr.text = attr_data.business
    self.adult_management_attr.text = attr_data.management
    self.adult_renown_attr.text = attr_data.renown
    self.adult_fight_attr.text = attr_data.fight
end

return GrowUpUI