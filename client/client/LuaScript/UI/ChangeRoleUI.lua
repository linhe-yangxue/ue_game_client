local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local LoopListCmp = require("UI.UICmp.LoopListCmp")
local UnitConst = require("Unit.UnitConst")

local ChangeRoleUI = class("UI.ChangeRoleUI", UIBase)

function ChangeRoleUI:DoInit()
    ChangeRoleUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ChangeRoleUI"
    self.change_img_cost_data = SpecMgrs.data_mgr:GetParamData("modify_role_image_cost")
    self.dy_bag_data = ComMgrs.dy_data_mgr.bag_data
    self.male_role_item_list = {}
    self.female_role_item_list = {}
end

function ChangeRoleUI:OnGoLoadedOk(res_go)
    ChangeRoleUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function ChangeRoleUI:Hide()
    self:RemoveSelectEffect()
    self:ClearRoleItem()
    self.is_male = nil
    self.cur_select_index = nil
    self.init_index = nil
    ChangeRoleUI.super.Hide(self)
end

function ChangeRoleUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    ChangeRoleUI.super.Show(self)
end

function ChangeRoleUI:InitRes()
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "ChangeRoleUI")

    self.role_model = self.main_panel:FindChild("RoleModel")
    local male_btn = self.main_panel:FindChild("MaleBtn")
    self.male_btn_cmp = male_btn:GetComponent("Button")
    self.male_btn_select = male_btn:FindChild("Select")
    self:AddClick(male_btn, function ()
        self:UpdateRoleList(true)
    end)
    local female_btn = self.main_panel:FindChild("FemaleBtn")
    self.female_btn_cmp = female_btn:GetComponent("Button")
    self.female_btn_select = female_btn:FindChild("Select")
    self:AddClick(female_btn, function ()
        self:UpdateRoleList(false)
    end)
    local info_content = self.main_panel:FindChild("RoleInfo")
    info_content:FindChild("Tip/Text"):GetComponent("Text").text = UIConst.Text.CHANGE_ROLE_TIP
    self.male_role_list = info_content:FindChild("MaleRoleList")
    self.male_role_list_cmp = LoopListCmp.New()
    self.male_role_list_cmp:DoInit(self, self.male_role_list)
    self.female_role_list = info_content:FindChild("FemaleRoleList")
    self.female_role_list_cmp = LoopListCmp.New()
    self.female_role_list_cmp:DoInit(self, self.female_role_list)

    local material_panel = info_content:FindChild("Material")
    material_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.COST_TEXT
    self.material_count = material_panel:FindChild("Count"):GetComponent("Text")
    local change_btn = self.main_panel:FindChild("BottomPanel/ChangeBtn")
    change_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CHANGE_ROLE_BTN_TEXT
    self:AddClick(change_btn, function ()
        self:SubmitChangeRole()
    end)
    local prefab_list = self.main_panel:FindChild("PrefabList")
    self.role_item = prefab_list:FindChild("RoleItem")
    self.role_item:FindChild("CurRole/Text"):GetComponent("Text").text = UIConst.Text.USING_TEXT
end

function ChangeRoleUI:InitUI()
    self.role_id = ComMgrs.dy_data_mgr:ExGetRoleId()
    self.role_data = SpecMgrs.data_mgr:GetRoleLookData(self.role_id)
    self.male_role_data_list = SpecMgrs.data_mgr:GetMaleRoleList()
    self.female_role_data_list = SpecMgrs.data_mgr:GetFemaleRoleList()
    self:InitMaleRoleList()
    self:InitFemaleRoleList()
    self:UpdateRoleList(self.role_data.sex == CSConst.Sex.Man)
    self.material_count.text = self.change_img_cost_data.count
    self:RegisterEvent(ComMgrs.dy_data_mgr, "UpdateCurrencyEvent", function (_, currency)
        if self._item_to_text_list then
            UIFuncs.UpdateCurrencyItemNum(self._item_to_text_list, currency)
        end
    end)
end

function ChangeRoleUI:InitMaleRoleList()
    for index, role_data in ipairs(self.male_role_data_list) do
        local role_item = self:GetUIObject(self.role_item, self.male_role_list)
        self.male_role_item_list[index] = role_item
        local role_icon = SpecMgrs.data_mgr:GetUnitData(role_data.unit_id).icon
        UIFuncs.AssignSpriteByIconID(role_icon, role_item:FindChild("Icon"):GetComponent("Image"))
        local lock_img = role_item:FindChild("Lock")
        lock_img:SetActive(not role_data.unlocked)
        role_item:GetComponent("Button").interactable = role_data.unlocked
        if not role_data.unlocked then
            UIFuncs.AssignSpriteByIconID(role_icon, lock_img:GetComponent("Image"))
        end
        role_item:FindChild("CurRole"):SetActive(role_data.role_look_id == self.role_id)
        self:AddClick(role_item, function ()
            if self.cur_select_index == index then return end
            self.male_role_list_cmp:SelectIndex(index, true)
        end)
        if role_data.role_look_id == self.role_id then self.init_index = index end
    end
    self.male_role_list_cmp:Refresh(false)
    self.male_role_list_cmp:ListenItemSelect(function ()
        self:ChangeSelectRole(self.male_role_list_cmp:GetCurIndex())
    end)
end

function ChangeRoleUI:InitFemaleRoleList()
    for index, role_data in ipairs(self.female_role_data_list) do
        local role_item = self:GetUIObject(self.role_item, self.female_role_list)
        self.female_role_item_list[index] = role_item
        local role_icon = SpecMgrs.data_mgr:GetUnitData(role_data.unit_id).icon
        UIFuncs.AssignSpriteByIconID(role_icon, role_item:FindChild("Icon"):GetComponent("Image"))
        local lock_img = role_item:FindChild("Lock")
        lock_img:SetActive(not role_data.unlocked)
        role_item:GetComponent("Button").interactable = role_data.unlocked
        if not role_data.unlocked then
            UIFuncs.AssignSpriteByIconID(role_icon, lock_img:GetComponent("Image"))
        end
        role_item:FindChild("CurRole"):SetActive(role_data.role_look_id == self.role_id)
        self:AddClick(role_item, function ()
            if self.cur_select_index == index then return end
            self.female_role_list_cmp:SelectIndex(index, true)
        end)
        if role_data.role_look_id == self.role_id then self.init_index = index end
    end
    self.female_role_list_cmp:Refresh(false)
    self.female_role_list_cmp:ListenItemSelect(function ()
        local index = self.female_role_list_cmp:GetCurIndex()
        local role_list = self.is_male and self.male_role_data_list or self.female_role_data_list
        if not role_list[index].unlocked then
            local list_cmp = self.is_male and self.male or self.male_role_list_cmp or self.female_role_list_cmp
            list_cmp:SelectNext()
            return
        end
        self:ChangeSelectRole(index)
    end)
end

function ChangeRoleUI:UpdateRoleList(is_male)
    self:RemoveSelectEffect()
    self.male_role_list:SetActive(is_male)
    self.male_btn_cmp.interactable = not is_male
    self.male_btn_select:SetActive(is_male)
    self.female_role_list:SetActive(not is_male)
    self.female_btn_cmp.interactable = is_male
    self.female_btn_select:SetActive(not is_male)
    self.is_male = is_male
    local list_cmp = is_male and self.male_role_list_cmp or self.female_role_list_cmp
    local index = self.role_data.sex == (is_male and CSConst.Sex.Man or CSConst.Sex.Woman) and self.init_index or 1
    list_cmp:SelectIndex(index, false)
    self:ChangeSelectRole(index)
end

function ChangeRoleUI:ChangeSelectRole(index)
    local role_list = self.is_male and self.male_role_data_list or self.female_role_data_list
    local role_item_list = self.is_male and self.male_role_item_list or self.female_role_item_list
    if self.role_unit then ComMgrs.unit_mgr:DestroyUnit(self.role_unit) end
    self.role_unit = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = role_list[index].unit_id, parent = self.role_model})
    self.role_unit:SetPositionByRectName({parent = self.role_model, name = UnitConst.UnitRect.Full})
    self:RemoveSelectEffect()
    self.select_effect = UIFuncs.AddSelectEffect(self, role_item_list[index])
    self.cur_select_index = index
end

function ChangeRoleUI:SubmitChangeRole()
    local role_list = self.is_male and self.male_role_data_list or self.female_role_data_list
    local role_data = role_list[self.cur_select_index]
    if role_data.role_look_id == self.role_id then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.ROLE_IMG_SAME)
        return
    end
    local cost_item_data = SpecMgrs.data_mgr:GetItemData(self.change_img_cost_data.item_id)
    SpecMgrs.ui_mgr:ShowItemUseRemindByTb({
        item_id = self.change_img_cost_data.item_id,
        need_count = self.change_img_cost_data.count,
        confirm_cb = function ()
            SpecMgrs.msg_mgr:SendModifyRoleImage({role_id = role_data.role_look_id}, function (resp)
                if resp.errcode ~= 0 then
                    SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.CHANGE_ROLE_IMG_FAILED)
                else
                    local last_role_item_list = self.role_data.sex == CSConst.Sex.Man and self.male_role_item_list or self.female_role_item_list
                    last_role_item_list[self.init_index]:FindChild("CurRole"):SetActive(false)
                    self.role_id = ComMgrs.dy_data_mgr:ExGetRoleId()
                    self.role_data = SpecMgrs.data_mgr:GetRoleLookData(self.role_id)
                    local role_item_list = self.role_data.sex == CSConst.Sex.Man and self.male_role_item_list or self.female_role_item_list
                    self.init_index = self.cur_select_index
                    role_item_list[self.init_index]:FindChild("CurRole"):SetActive(true)
                    self:UpdateRoleList(self.is_male)
                end
            end)
        end,
        desc = string.format(UIConst.Text.CHANGE_ROLE_IMG_REMIND_TIP, cost_item_data.name, self.change_img_cost_data.count),
        remind_tag = "ChangeRoleImg",
        is_show_tip = true,
    })
end

function ChangeRoleUI:RemoveSelectEffect()
    if self.cur_select_index and self.select_effect then
        local role_item_list = self.is_male and self.male_role_item_list or self.female_role_item_list
        self:RemoveUIEffect(role_item_list[self.cur_select_index], self.select_effect)
        self.select_effect = nil
    end
end

function ChangeRoleUI:ClearRoleItem()
    for _, item in ipairs(self.male_role_item_list) do
        self:DelUIObject(item)
    end
    self.male_role_item_list = {}
    for _, item in ipairs(self.female_role_item_list) do
        self:DelUIObject(item)
    end
    self.female_role_item_list = {}
end

return ChangeRoleUI