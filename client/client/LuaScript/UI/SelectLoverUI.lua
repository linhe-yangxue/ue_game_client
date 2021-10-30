local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local SelectLoverUI = class("UI.SelectLoverUI", UIBase)

function SelectLoverUI:DoInit()
    SelectLoverUI.super.DoInit(self)
    self.prefab_path = "UI/Common/SelectLoverUI"
    self.lover_go_dict = {}
end

function SelectLoverUI:OnGoLoadedOk(res_go)
    SelectLoverUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function SelectLoverUI:Hide()
    self:ClearLoverItem()
    SelectLoverUI.super.Hide(self)
end

function SelectLoverUI:Show(lover_list, confirm_cb)
    self.lover_list = lover_list
    self.confirm_cb = confirm_cb
    if self.is_res_ok then
        self:InitUI()
    end
    SelectLoverUI.super.Show(self)
end

function SelectLoverUI:InitRes()
    local title_panel = self.main_panel:FindChild("Bg/Top")
    self:AddClick(title_panel:FindChild("CloseBtn"), function ()
        SpecMgrs.ui_mgr:HideUI(self)
    end)
    title_panel:FindChild("Title"):GetComponent("Text").text = UIConst.Text.SELECT_LOVER
    self.lover_select_content = self.main_panel:FindChild("Bg/LoverSelectPanel/Viewport/Content")
    self.lover_select_rect_cmp = self.lover_select_content:GetComponent("RectTransform")
    self.lover_pref = self.lover_select_content:FindChild("LoverPref")
    self.lover_pref:FindChild("InfoPanel/SendBtn/Text"):GetComponent("Text").text = UIConst.Text.JOB_SELECT
    self.empty_panel = self.main_panel:FindChild("Bg/Empty")
    self.empty_panel:FindChild("Dialog/Text"):GetComponent("Text").text = UIConst.Text.NO_IDLE_LOVER
end

function SelectLoverUI:InitUI()
    local is_have_lover = self.lover_list and #self.lover_list > 0
    self.empty_panel:SetActive(not is_have_lover)
    if is_have_lover then
        for _, lover_info in ipairs(self.lover_list) do
            local lover_go = self:GetUIObject(self.lover_pref, self.lover_select_content)
            self.lover_go_dict[lover_info.lover_id] = lover_go
            local lover_data = SpecMgrs.data_mgr:GetLoverData(lover_info.lover_id)
            UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetUnitData(lover_data.unit_id).icon, lover_go:FindChild("LoverBg/LoverImg"):GetComponent("Image"))
            local info_panel = lover_go:FindChild("InfoPanel")
            info_panel:FindChild("LoverName"):GetComponent("Text").text = lover_data.name
            info_panel:FindChild("Intimate"):GetComponent("Text").text = string.format(UIConst.Text.INTIMATE, lover_info.level)
            local attr_dict = lover_info.attr_dict
            info_panel:FindChild("TotalAttr"):GetComponent("Text").text = string.format(UIConst.Text.TRAIN_TOTAL_ATTR, attr_dict.etiquette + attr_dict.culture + attr_dict.charm + attr_dict.planning)
            info_panel:FindChild("EtiquettePanel/Etiquette"):GetComponent("Text").text = string.format(UIConst.Text.ADD, UIConst.Text.CEREMONY_TEXT, attr_dict.etiquette)
            info_panel:FindChild("CulturePanel/Culture"):GetComponent("Text").text = string.format(UIConst.Text.ADD, UIConst.Text.CULTURE_TEXT, attr_dict.culture)
            info_panel:FindChild("CharmPanel/Charm"):GetComponent("Text").text = string.format(UIConst.Text.ADD, UIConst.Text.CHARM_TEXT, attr_dict.charm)
            info_panel:FindChild("PlanningPanel/Planning"):GetComponent("Text").text = string.format(UIConst.Text.ADD, UIConst.Text.PLAN_TEXT, attr_dict.planning)
            self:AddClick(info_panel:FindChild("SendBtn"), function ()
                self.confirm_cb(lover_info.lover_id)
                SpecMgrs.ui_mgr:HideUI(self)
            end)
        end
        self.lover_select_rect_cmp.anchoredPosition = Vector2.zero
    end
end

function SelectLoverUI:ClearLoverItem()
    for _, go in pairs(self.lover_go_dict) do
        self:DelUIObject(go)
    end
    self.lover_go_dict = {}
end

return SelectLoverUI