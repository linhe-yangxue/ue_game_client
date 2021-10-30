local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local CSConst = require("CSCommon.CSConst")
local ClothAddAttrUI = class("UI.ClothAddAttrUI",UIBase)

--  衣服属性加成ui
function ClothAddAttrUI:DoInit()
    ClothAddAttrUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ClothAddAttrUI"
    self.lover_data = ComMgrs.dy_data_mgr.lover_data
    self.data_mgr = SpecMgrs.data_mgr
    self.woman_sibling_index = 1
    self.man_sibling_index = 3
end

function ClothAddAttrUI:OnGoLoadedOk(res_go)
    ClothAddAttrUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function ClothAddAttrUI:Show(lover_id)
    self.lover_id = lover_id
    if self.is_res_ok then
        self:InitUI()
    end
    ClothAddAttrUI.super.Show(self)
end

function ClothAddAttrUI:InitRes()
    self:AddClick(self.main_panel:FindChild("CloseButton"), function()
        self:Hide()
    end)
    self.title = self.main_panel:FindChild("Title"):GetComponent("Text")
    self.cloth_all_add_text = self.main_panel:FindChild("ClothAllAddText"):GetComponent("Text")

    self.cloth_list_content = self.main_panel:FindChild("ClothList/Viewport/Content")
    self.cloth_grid = self.main_panel:FindChild("Temp/ClothGrid")
    self.no_cloth_tip_text = self.main_panel:FindChild("Temp/NoClothTipText")
    self.cloth_mes = self.main_panel:FindChild("Temp/ClothMes")
    self.explain_text = self.main_panel:FindChild("ExplainText"):GetComponent("Text")
    self.ceremony_attr_text = self.main_panel:FindChild("CeremonyAttrMes/CeremonyAttrText"):GetComponent("Text")
    self.culture_attr_text = self.main_panel:FindChild("CultureAttrMes/CultureAttrText"):GetComponent("Text")
    self.charm_attr_text = self.main_panel:FindChild("CharmAttrMes/CharmAttrText"):GetComponent("Text")
    self.plan_attr_text = self.main_panel:FindChild("PlanAttrMes/PlanAttrText"):GetComponent("Text")

    self.attr_add_text1 = self.main_panel:FindChild("ClothList/Viewport/Content/Image1/AttAddText1"):GetComponent("Text")
    self.attr_add_text2 = self.main_panel:FindChild("ClothList/Viewport/Content/Image2/AttAddText2"):GetComponent("Text")
end

function ClothAddAttrUI:InitUI()
    self:UpdateLoverInfo()
    self:UpdateClothList()
    self:SetTextVal()
end

function ClothAddAttrUI:SetTextVal()
    self.explain_text.text = UIConst.Text.CLOTH_ADD_ATTR_TEXT
    self.title.text = UIConst.Text.CLOTH_ATTR_ADD_TEXT
    self.cloth_all_add_text.text = UIConst.Text.CLOTH_ALL_ADD_TEXT
    self.attr_add_text1.text = UIConst.Text.CLOTH_ATTR_ADD_TEXT
    self.attr_add_text2.text = UIConst.Text.CLOTH_ATTR_ADD_TEXT
end

function ClothAddAttrUI:UpdateLoverInfo()
    self.nowlife_data = self.lover_data:GetNowlifeData(self.lover_id)
    self.prelife_data = self.lover_data:GetPrelifeData(self.lover_id)
    self.nowlife_cloth_List = self.lover_data:GetClothData(self.lover_id, true)
    self.prelife_cloth_List = self.lover_data:GetClothData(self.lover_id, false)
end

function ClothAddAttrUI:UpdateClothList()
    --  衣服列表
    self:CreateClothList(self.nowlife_cloth_List, self.woman_sibling_index)
    self:CreateClothList(self.prelife_cloth_List, self.man_sibling_index)

    local attr_list = self.lover_data:GetLoverClothAttrAdd(self.lover_id)
    local attr = CSConst.ClothAttrIndexTb
    self.ceremony_attr_text.text = string.format(UIConst.Text.CEREMONY_ADD_FORMAL, attr_list[attr.Ceremony])
    self.culture_attr_text.text = string.format(UIConst.Text.CULTURE_ADD_FORMAL, attr_list[attr.Culture])
    self.charm_attr_text.text = string.format(UIConst.Text.CHARM_ADD_FORMAL, attr_list[attr.Charm])
    self.plan_attr_text.text = string.format(UIConst.Text.PLAN_ADD_FORMAL, attr_list[attr.Plan])
end

function ClothAddAttrUI:CreateClothList(cloth_list, sibling_index)
    if next(cloth_list) ~= nil then
        local init_cloth_grid = self:GetUIObject(self.cloth_grid, self.cloth_list_content, false)
        init_cloth_grid:SetSiblingIndex(sibling_index)
        for k, v in pairs(cloth_list) do
            local cloth_mes = self:GetUIObject(self.cloth_mes, init_cloth_grid, false)
            cloth_mes:FindChild("LoverNameText"):GetComponent("Text").text = v.name
        end
    else
        local obj = self:GetUIObject(self.no_cloth_tip_text, self.cloth_list_content, false)
        obj:SetSiblingIndex(sibling_index)
    end
end

function ClothAddAttrUI:Hide()
    self:DestroyRes()
    ClothAddAttrUI.super.Hide(self)
end

return ClothAddAttrUI
