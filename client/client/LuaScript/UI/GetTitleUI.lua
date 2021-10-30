local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local GetTitleUI = class("UI.GetTitleUI",UIBase)
local UIFuncs = require("UI.UIFuncs")

-- GetTitleUI.can_multi_open = true

function GetTitleUI:DoInit()
    GetTitleUI.super.DoInit(self)
    self.prefab_path = "UI/Common/GetTitleUI"
    self.dy_title_data = ComMgrs.dy_data_mgr.title_data
    self.title_go_dict = {}
    self.temp_id = nil
end

function GetTitleUI:OnGoLoadedOk(res_go)
    GetTitleUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function GetTitleUI:Hide()
    self.title_list = nil
    self:ClearGoDict("title_go_dict")
    self.title_go_dict = {}
    GetTitleUI.super.Hide(self)
end

function GetTitleUI:Show(title_list)
    self.title_list = title_list
    if self.is_res_ok then
        self:InitUI()
    end
    GetTitleUI.super.Show(self)
end

function GetTitleUI:InitRes()
    self.content = self.main_panel:FindChild("Content")
    self.content:FindChild("Title"):GetComponent("Text").text = UIConst.Text.GET_TITLE_TITLE

    self.content:FindChild("WearBtn/Text"):GetComponent("Text").text = UIConst.Text.WEAR_TIP_TEXT
    self.content:FindChild("ConfirmBtn/Text"):GetComponent("Text").text = UIConst.Text.CONFIRM
    self.content:FindChild("EffectTip"):GetComponent("Text").text = UIConst.Text.EFFEXT_TIP
    local effect_parent = self.content:FindChild("Effect")
    local effect_text_temp = effect_parent:FindChild("Text")
    effect_text_temp:SetActive(false)
    self.content:SetActive(false)
end

function GetTitleUI:InitUI()
    if self.title_list then
        for _, title_id in ipairs(self.title_list) do
            self:_InitTitleContent(title_id)
        end
    end
    self:RegisterEvent(self.dy_title_data, "UpdateAddTitleEvent", function (_, title_id)
        self:_InitTitleContent(title_id)
    end)
end

function GetTitleUI:_InitTitleContent(title_id)
    if self.title_go_dict[title_id] then return end
    local item = self:GetUIObject(self.content, self.main_panel)
    local close_btn = item:FindChild("CloseBtn")
    local wear_btn = item:FindChild("WearBtn")
    local confirm_btn = item:FindChild("ConfirmBtn")
    local title_image = item:FindChild("TitleImage")
    local effect_parent = item:FindChild("Effect")
    local effect_text_temp = effect_parent:FindChild("Text")
    UIFuncs.AssignSpriteByItemID(title_id, title_image:GetComponent("Image"))
    self.title_go_dict[title_id] = item
    self:InitEffectText(effect_parent, effect_text_temp, title_id)
    self:AddClick(close_btn, function ()
        self:CheckTitleHide(title_id)
    end)
    self:AddClick(confirm_btn, function ()
        self:CheckTitleHide(title_id)
    end)
    self:AddClick(wear_btn, function()
        SpecMgrs.msg_mgr:SendWearingTitle({title_id = title_id}, function (resp)
            if resp.errcode == 0 then
                SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.WEAR_SUCCESS)
                self:CheckTitleHide(title_id)
            end
        end)
    end)
    local title_data = SpecMgrs.data_mgr:GetItemData(title_id)
    if title_data.sub_type == CSConst.ItemSubType.RushActivityTitle then
        SpecMgrs.ui_mgr:ShowShareUI()
    end
end

function GetTitleUI:InitEffectText(go, temp, title_id)
    local title_data = SpecMgrs.data_mgr:GetItemData(title_id)
    if title_data.add_role_attr_name_list then
        for k, attr in ipairs(title_data.add_role_attr_name_list) do
            local item = self:GetUIObject(temp, go)
            local name = SpecMgrs.data_mgr:GetAttributeData(attr).name
            local value = title_data.add_role_attr_value_list[k]
            item:GetComponent("Text").text = string.format(UIConst.Text.EFFECT_COLOR_TEXT, name, value)
        end
    end
    if title_data.add_hero_attr_name_list then
        for k, attr in ipairs(title_data.add_hero_attr_name_list) do
            local item = self:GetUIObject(temp, go)
            local name = SpecMgrs.data_mgr:GetAttributeData(attr).name
            local value = title_data.add_hero_attr_value_list[k]
            item:GetComponent("Text").text = string.format(UIConst.Text.EFFECT_COLOR_TEXT, name, value)
        end
    end
end

function GetTitleUI:CheckTitleHide(title_id)
    self:DelUIObject(self.title_go_dict[title_id], true)
    self.title_go_dict[title_id] = nil
    if table.getCount(self.title_go_dict) <= 0 then
        SpecMgrs.ui_mgr:HideUI(self)
    end
end

return GetTitleUI