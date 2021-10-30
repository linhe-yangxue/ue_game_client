local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local CSConst = require("CSCommon.CSConst")
local UIFuncs = require("UI.UIFuncs")
local SlideSelectCmp = require("UI.UICmp.SlideSelectCmp")
local CheckLineUpUI = class("UI.CheckLineUpUI",UIBase)

--  查看阵容
function CheckLineUpUI:DoInit()
    CheckLineUpUI.super.DoInit(self)
    self.prefab_path = "UI/Common/CheckLineUpUI"
end

function CheckLineUpUI:OnGoLoadedOk(res_go)
    CheckLineUpUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function CheckLineUpUI:Show(uuid)
    self.uuid = uuid
    if self.is_res_ok then
        self:InitUI()
    end
    CheckLineUpUI.super.Show(self)
end

function CheckLineUpUI:InitRes()
    self.close_btn = self.main_panel:FindChild("Bg/CloseBtn")
    self:AddClick(self.close_btn, function()
        SpecMgrs.ui_mgr:HideUI(self)
    end)
    self.confirm_btn = self.main_panel:FindChild("Bg/ConfirmBtn")
    self:AddClick(self.confirm_btn, function()
        SpecMgrs.ui_mgr:HideUI(self)
    end)
    self.title = self.main_panel:FindChild("Bg/Title"):GetComponent("Text")
    self.hero_name_text = self.main_panel:FindChild("Bg/HeroNameText"):GetComponent("Text")
    self.quality_image = self.main_panel:FindChild("Bg/QualityImage"):GetComponent("Image")
    self.hero_item = self.main_panel:FindChild("Bg/HeroList/HeroListContent/Item")
    self.hero_list_content = self.main_panel:FindChild("Bg/HeroList/HeroListContent")
    self.hero_list_content_rect = self.hero_list_content:GetComponent("RectTransform")
    self.equip_list = self.main_panel:FindChild("Bg/EquipList")
    self.star_list_obj = self.main_panel:FindChild("Bg/StarList")
    self.top_content = self.main_panel:FindChild("Bg/Top/Hero/Scroll View/Viewport/Content")
    self.top_content_rect = self.top_content:GetComponent("RectTransform")
    self.head_item = self.main_panel:FindChild("Bg/Top/Hero/Scroll View/Viewport/Content/Item")

    self.head_item:SetActive(false)
    self.hero_item:SetActive(false)

    self.star_list = {}
    for i = 1, self.star_list_obj.childCount do
        local star = self.star_list_obj:GetChild(i - 1)
        table.insert(self.star_list, star)
    end
    self.equip_obj_list = {}
    for i = 1, self.equip_list.childCount do
        local obj = self.equip_list:GetChild(i - 1)
        table.insert(self.equip_obj_list, obj)
    end
end

function CheckLineUpUI:InitUI()
    self:SetTextVal()
    self:UpdateData()
    SpecMgrs.msg_mgr:SendGetLineUp({uuid = self.uuid}, function(resp)
        if not self.is_res_ok then return end
        if resp.errcode == 1 then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.GET_LINEUP_FAIL_TIP)
            SpecMgrs.ui_mgr:HideUI(self)
            return
        end
        for k, v in pairs(resp.lineup_dict) do
            self.lineup_dict_info[v.pos_id] = v
        end
        self:UpdateUIInfo()
        self.hero_list_slider = SlideSelectCmp.New()
        self.hero_list_slider:DoInit(self, self.hero_list_content)
        self.hero_list_slider:SetParam(self.hero_item:GetComponent("RectTransform").sizeDelta.x, #self.hero_info_list)
        self.hero_list_slider:ListenSelectUpdate(function(index)
            self:UpdateSelectIndex(index + 1)
        end)
        self.hero_list_slider:SetToIndex(0)
        self:UpdateSelectIndex(1)
    end)
end

function CheckLineUpUI:UpdateSelectIndex(index)
    self.cur_select_index = index
    self:UpdateSelectHeroInfo(self.cur_select_index)
    self.top_selector:SelectObj(self.cur_select_index)
end

function CheckLineUpUI:UpdateData()
    self.lineup_dict_info = {}
    self.hero_info_list = {}
    self.head_item_list = {}
end

function CheckLineUpUI:UpdateUIInfo()
    self.top_content_rect.anchoredPosition = Vector2.New(0, self.top_content_rect.anchoredPosition.y)
    for i = 1, CSConst.LineupMaxCount do
        if self.lineup_dict_info[i] then
            local item = self:GetUIObject(self.head_item, self.top_content)
            table.insert(self.head_item_list, item)
            UIFuncs.InitHeroGo({go = item, hero_id = self.lineup_dict_info[i].hero_info.hero_id})
            table.insert(self.hero_info_list, self.lineup_dict_info[i])
            local item = self:GetUIObject(self.hero_item, self.hero_list_content)
            local hero_data = SpecMgrs.data_mgr:GetHeroData(self.lineup_dict_info[i].hero_info.hero_id)
            self:AddFullUnit(hero_data.unit_id, item:FindChild("UnitRect"))
        end
    end
    self.top_selector = UIFuncs.CreateSelector(self, self.head_item_list, function(index)
        if math.abs(self.cur_select_index - index) > 1 then
            self.hero_list_slider:SetToIndex(index - 1)
            self:UpdateSelectIndex(index)
        else
           self.hero_list_slider:SlideToIndex(index - 1)
        end
    end)
end

function CheckLineUpUI:UpdateSelectHeroInfo(index)
    self.cur_select_info = self.hero_info_list[index].hero_info
    local hero_data = SpecMgrs.data_mgr:GetHeroData(self.cur_select_info.hero_id)
    local quality_data = SpecMgrs.data_mgr:GetQualityData(hero_data.quality)
    local str = hero_data.name
    if self.cur_select_info.break_lv > 0 then
        str = string.format(UIConst.Text.HERO_NAME_FORMAT, hero_data.name, self.cur_select_info.break_lv)
    end
    self.hero_name_text.text = str
    UIFuncs.AssignSpriteByIconID(quality_data.grade, self.quality_image)
    for i = 1, self.cur_select_info.star_lv do
        self.star_list[i]:SetActive(true)
    end
    for i = self.cur_select_info.star_lv + 1, #self.star_list do
        self.star_list[i]:SetActive(false)
    end
    self:UpdateEquipInfo(self.hero_info_list[index].equip_dict)
end

function CheckLineUpUI:UpdateEquipInfo(equip_dict)
    for i = 1, #self.equip_obj_list do
        local obj = self.equip_obj_list[i]
        local equip_obj = obj:FindChild("EquipParent")
        local equip_data = equip_dict[i]
        if equip_data then
            equip_obj:SetActive(true)
            UIFuncs.InitEquipGo({go = equip_obj, role_item = equip_data})
        else
            equip_obj:SetActive(false)
        end
    end
end

function CheckLineUpUI:SetTextVal()
    self.title.text = UIConst.Text.PLAYER_MES_TEXT
    self.confirm_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CONFIRM
end

function CheckLineUpUI:Hide()
    self.hero_list_slider:DoDestroy()
    self:DelAllCreateUIObj()
    CheckLineUpUI.super.Hide(self)
end

return CheckLineUpUI
