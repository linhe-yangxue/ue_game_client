local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local ClothAddAttrUI = require("UI.ClothAddAttrUI")
local CSConst = require("CSCommon.CSConst")
local DressingUI = class("UI.DressingUI",UIBase)

--  换装UI
function DressingUI:DoInit()
    DressingUI.super.DoInit(self)
    self.prefab_path = "UI/Common/DressingUI"

    self.lover_data = ComMgrs.dy_data_mgr.lover_data
    self.data_mgr = SpecMgrs.data_mgr
end

function DressingUI:OnGoLoadedOk(res_go)
    DressingUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function DressingUI:Show(lover_id)
    self.lover_id = lover_id
    if self.is_res_ok then
        self:InitUI()
    end
    DressingUI.super.Show(self)
end

function DressingUI:InitRes()
    --  中间ui
    local middle_frame = self.main_panel:FindChild("MiddleFrame")

    self.cloth_item = middle_frame:FindChild("Temp/ClothItem")
    self.now_life_btn = middle_frame:FindChild("NowlifeButton")
    self.pre_life_btn = middle_frame:FindChild("PrelifeButton")
    self.change_cloth_btn = middle_frame:FindChild("ClothAttrPanel/ChangeClothButton")
    self.obtain_btn = middle_frame:FindChild("ClothAttrPanel/ObtainButton")

    self.lover_point = self.main_panel:FindChild("MiddleFrame/LoverPoint")
    self.lover_name_text = self.main_panel:FindChild("MiddleFrame/NameBg/NameText"):GetComponent("Text")
    self.screen_image = self.main_panel:FindChild("MiddleFrame/ScreenImage")
    self.add_attr_text = self.main_panel:FindChild("MiddleFrame/ClothAttrPanel/AddAttrText"):GetComponent("Text")
    self.no_add_attr_text = self.main_panel:FindChild("MiddleFrame/ClothAttrPanel/NoAddAttrText"):GetComponent("Text")
    self.cloth_name_text = self.main_panel:FindChild("MiddleFrame/ClothAttrPanel/ClothNameText"):GetComponent("Text")
    self.ceremony_attr_text = self.main_panel:FindChild("MiddleFrame/ClothAttrPanel/MesGrid/CeremonyAttrMes/CeremonyAttrText"):GetComponent("Text")
    self.culture_attr_text = self.main_panel:FindChild("MiddleFrame/ClothAttrPanel/MesGrid/CultureAttrMes/CultureAttrText"):GetComponent("Text")
    self.charm_attr_text = self.main_panel:FindChild("MiddleFrame/ClothAttrPanel/MesGrid/CharmAttrMes/CharmAttrText"):GetComponent("Text")
    self.plan_attr_text = self.main_panel:FindChild("MiddleFrame/ClothAttrPanel/MesGrid/PlanAttrMes/PlanAttrText"):GetComponent("Text")
    self.obtain_button_text = self.main_panel:FindChild("MiddleFrame/ClothAttrPanel/ObtainButton/ObtainButtonText"):GetComponent("Text")
    self.change_cloth_button_text = self.main_panel:FindChild("MiddleFrame/ClothAttrPanel/ChangeClothButton/ChangeClothButtonText"):GetComponent("Text")
    self.cloth_attr_add_button_text = self.main_panel:FindChild("DownFrame/ClothAttrAddButton/ClothAttrAddButtonText"):GetComponent("Text")

    self:AddClick(self.change_cloth_btn, function()
        if not self.lover_info.fashion_dict[self.cur_select_fashion_id] then
            --  TODO 转世
            return
        end
        local resp_cb = function(resp)
            if resp.errcode == 1 then
                --  todo 错误
            end
        end
        local param_tb = {
            lover_id = self.lover_id,
            fashion_id = self.cur_select_fashion_id,
        }
        SpecMgrs.msg_mgr:SendChangeLoverFashion(param_tb, resp_cb)
    end)

    self:AddClick(self.obtain_btn, function()
        -- todo 获取
    end)

    self:AddClick(self.now_life_btn, function()
        self:ClickNowlifeButton()
        self:SelectFirstCloth()
        self:UpdateClothInfo()
    end)
    self:AddClick(self.pre_life_btn, function()
        self:ClickPrelifeButton()
        self:SelectFirstCloth()
        self:UpdateClothInfo()
    end)

    --  衣服属性面板
    local cloth_panel = middle_frame:FindChild("ClothAttrPanel")
    self.panel_cloth_name_text = cloth_panel:FindChild("ClothNameText"):GetComponent("Text")
    self.cloth_mes_grid = cloth_panel:FindChild("MesGrid")
    self.cloth_content = middle_frame:FindChild("Scroll View/Viewport/Content")
    --  下方ui
    local down_frame = self.main_panel:FindChild("DownFrame")
    self.cloth_explain_text = down_frame:FindChild("ClothExplainText"):GetComponent("Text")
    self:AddClick(down_frame:FindChild("ClothAttrAddButton"), function()
        SpecMgrs.ui_mgr:ShowUI("ClothAddAttrUI", self.lover_id)
    end)
end

function DressingUI:InitUI()
    self:InitTopBar()
    self:UpdateData()
    self:SetTextVal()
    self:UpdateLoverInfo()
    self:CreateClothItem()

    if self.cur_lover_data.sex == CSConst.Sex.Man then --  男
        self:ClickPrelifeButton()
    else
        self:ClickNowlifeButton()
    end
    self.start_lover_sex = self.cur_select_lover_data.sex
    self:SelectFirstCloth()
    self:UpdateClothInfo()
    self.lover_data:RegisterUpdateLoverInfoEvent("DressingUI", function(_, _, lover_id)
        if self.lover_id == lover_id then
            self:UpdateLoverInfo()
            self:UpdateClothInfo()
        end
    end, self)
end

function DressingUI:UpdateData()
    self.cloth_item_tb = {}
    self.cur_select_fashion_id = 0

    self.have_prelife_fashion_tb = {}
    self.have_nowlife_fashion_tb = {}

    self.all_prelife_fashion_tb = {}
    self.all_nowlife_fashion_tb = {}

    self.cur_have_fashion_tb = {}
    self.cur_all_fashion_tb = {}

    self.prelife_lover_data = {}
    self.nowlife_lover_data = {}
    self.cur_select_lover_data = {}
end

function DressingUI:SetTextVal()
    self.add_attr_text.text = UIConst.Text.ADD_ATTR_TEXT
    self.no_add_attr_text.text = UIConst.Text.NO_ADD_ATTR_TEXT
    self.obtain_button_text.text = UIConst.Text.OBTAIN_TEXT
    self.change_cloth_button_text.text = UIConst.Text.CHANGE_CLOTH_TEXT
    self.cloth_attr_add_button_text.text = UIConst.Text.CLOTH_ATTR_ADD_TEXT
    self.cloth_explain_text.text = UIConst.Text.CLOTH_ADD_ATTR_TEXT
end

function DressingUI:UpdateLoverInfo()
    self.lover_info = self.lover_data:GetLoverInfo(self.lover_id)
    self.cur_lover_data = self.data_mgr:GetLoverData(self.lover_id)
    self.change_sex_lover_data = self.data_mgr:GetLoverData(self.cur_lover_data.change_sex)

    if self.cur_lover_data.sex == CSConst.Sex.Man then -- 男
        self.have_prelife_fashion_tb = self.lover_info.fashion_dict
        self.have_nowlife_fashion_tb = self.lover_info.other_fashion_dict
        self.all_prelife_fashion_tb = self.cur_lover_data.fashion
        self.all_nowlife_fashion_tb = self.change_sex_lover_data.fashion
        self.prelife_lover_data = self.cur_lover_data
        self.nowlife_lover_data = self.change_sex_lover_data
    else
        self.have_prelife_fashion_tb = self.lover_info.other_fashion_dict
        self.have_nowlife_fashion_tb = self.lover_info.fashion_dict
        self.all_prelife_fashion_tb = self.change_sex_lover_data.fashion
        self.all_nowlife_fashion_tb = self.cur_lover_data.fashion
        self.prelife_lover_data = self.change_sex_lover_data
        self.nowlife_lover_data = self.cur_lover_data
    end
    self:AddUnit(self.cur_lover_data.unit_id, self.lover_point)
end

function DressingUI:SelectFirstCloth()
    if self.start_lover_sex ~= self.cur_select_lover_data.sex then
        for i, cloth_id in ipairs(self.cur_all_fashion_tb) do
            if self.cur_have_fashion_tb[cloth_id] then
                local cloth_data = self.data_mgr:GetItemData(cloth_id)
                self:SelectCloth(cloth_data)
            end
        end
    else
        local cloth_id = self.lover_info.fashion_id
        local cloth_data = self.data_mgr:GetItemData(cloth_id)
        self:SelectCloth(cloth_data)
    end
end

function DressingUI:CreateClothItem()
    --  生成衣服item
    for i, v in ipairs(self.cur_lover_data.fashion) do
        local cloth_item = self:GetUIObject(self.cloth_item, self.cloth_content, false)
        table.insert(self.cloth_item_tb, cloth_item)
    end
end

function DressingUI:UpdateClothInfo()
    self.lover_name_text.text = self.cur_select_lover_data.name
    for i, v in ipairs(self.cur_all_fashion_tb) do
        local cloth_id = v
        local cloth_data = self.data_mgr:GetItemData(cloth_id)
        local cloth_item = self.cloth_item_tb[i]
        if self.lover_info.fashion_id == cloth_id then
            -- todo
        end
        if self.cur_have_fashion_tb[cloth_id] then
            cloth_item:FindChild("LockImage"):SetActive(false)
            cloth_item:FindChild("Mask"):SetActive(false)
        else
            cloth_item:FindChild("LockImage"):SetActive(true)
            cloth_item:FindChild("Mask"):SetActive(true)
        end
        cloth_item:FindChild("ClothNameText"):GetComponent("Text").text = cloth_data.name
        self:AddClick(cloth_item:FindChild("TriggerButton"), function()
            self.cur_select_fashion_id = cloth_id
            self:SelectCloth(cloth_data)
        end)
    end
end

function DressingUI:SelectCloth(cloth_data)
    self.cloth_name_text.text = cloth_data.name
    if cloth_data.attr_list_value then
        self.no_add_attr_text.gameObject:SetActive(false)
        self.cloth_mes_grid:SetActive(true)
        local attr_list = cloth_data.attr_list_value
        local attr = CSConst.ClothAttrIndexTb
        self.ceremony_attr_text.text = string.format(UIConst.Text.CEREMONY_ADD_FORMAL, attr_list[attr.Ceremony])
        self.culture_attr_text.text = string.format(UIConst.Text.CULTURE_ADD_FORMAL, attr_list[attr.Culture])
        self.charm_attr_text.text = string.format(UIConst.Text.CHARM_ADD_FORMAL, attr_list[attr.Charm])
        self.plan_attr_text.text = string.format(UIConst.Text.PLAN_ADD_FORMAL, attr_list[attr.Plan])
    else
        self.no_add_attr_text.gameObject:SetActive(true)
        self.cloth_mes_grid:SetActive(false)
    end
    if self.cur_have_fashion_tb[cloth_data.id] then
        self.screen_image:SetActive(false)
        self.obtain_btn:SetActive(false)
    else
        self.obtain_btn:SetActive(true)
        self.screen_image:SetActive(true)
    end
    self.change_cloth_btn:SetActive(false)
    if self.cur_have_fashion_tb[cloth_data.id] or
       self.lover_info.other_fashion_dict[cloth_data.id] then
        if self.lover_info.fashion_id ~= cloth_data.id then
            self.change_cloth_btn:SetActive(true)
        end
    end
end

function DressingUI:ClickNowlifeButton()
    self.cur_have_fashion_tb = self.have_nowlife_fashion_tb
    self.cur_all_fashion_tb = self.all_nowlife_fashion_tb
    self.cur_select_lover_data = self.nowlife_lover_data
    self.now_life_btn:FindChild("SelectImage"):SetActive(true)
    self.pre_life_btn:FindChild("SelectImage"):SetActive(false)
end

function DressingUI:ClickPrelifeButton()
    self.cur_have_fashion_tb = self.have_prelife_fashion_tb
    self.cur_all_fashion_tb = self.all_prelife_fashion_tb
    self.cur_select_lover_data = self.prelife_lover_data
    self.now_life_btn:FindChild("SelectImage"):SetActive(false)
    self.pre_life_btn:FindChild("SelectImage"):SetActive(true)
end

function DressingUI:Hide()
    self:DelAllCreateUIObj()
    self.lover_data:UnregisterUpdateLoverInfoEvent("DressingUI")
    DressingUI.super.Hide(self)
end

return DressingUI
