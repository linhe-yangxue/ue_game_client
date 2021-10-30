local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local CSFunction = require("CSCommon.CSFunction")

local DynastyInstituteUI = class("UI.DynastyInstituteUI", UIBase)

kTabEnum = {
    Learn = 1,
    Research = 2,
}

function DynastyInstituteUI:DoInit()
    DynastyInstituteUI.super.DoInit(self)
    self.prefab_path = "UI/Common/DynastyInstituteUI"
    self.dy_dynasty_data = ComMgrs.dy_data_mgr.dynasty_data
    self.dy_bag_data = ComMgrs.dy_data_mgr.bag_data
    self.tab_data_dict = {}
    self.learn_spell_data_dict = {}
    self.research_spell_data_dict = {}
end

function DynastyInstituteUI:OnGoLoadedOk(res_go)
    DynastyInstituteUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function DynastyInstituteUI:Hide()
    self:UpdateTabPanel()
    self.dy_dynasty_data:UnregisterKickedOutDynastyEvent("DynastyInstituteUI")
    self.dy_dynasty_data:UnregisterUpdateDynastyJobEvent("DynastyInstituteUI")
    DynastyInstituteUI.super.Hide(self)
end

function DynastyInstituteUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    DynastyInstituteUI.super.Show(self)
end

function DynastyInstituteUI:InitRes()
    local tab_panel = self.main_panel:FindChild("TabPanel")
    local learn_btn = tab_panel:FindChild("LearnBtn")
    learn_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.LEARN_TEXT
    local learn_select = learn_btn:FindChild("Select")
    self.tab_data_dict[kTabEnum.Learn] = {}
    self.tab_data_dict[kTabEnum.Learn].select = learn_select
    learn_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.LEARN_TEXT
    self:AddClick(learn_btn, function ()
        self:UpdateTabPanel(kTabEnum.Learn)
    end)
    self.research_btn = tab_panel:FindChild("ResearchBtn")
    self.research_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.RESEARCH_TEXT
    local research_select = self.research_btn:FindChild("Select")
    self.tab_data_dict[kTabEnum.Research] = {}
    self.tab_data_dict[kTabEnum.Research].select = research_select
    research_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.RESEARCH_TEXT
    self:AddClick(self.research_btn, function ()
        self:UpdateTabPanel(kTabEnum.Research)
    end)

    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "DynastyInstituteUI")

    local learn_panel = self.main_panel:FindChild("LearnPanel")
    self.tab_data_dict[kTabEnum.Learn].panel = learn_panel
    self.tab_data_dict[kTabEnum.Learn].init_func = self.InitLearnPanel
    local dedicate_panel = learn_panel:FindChild("DedicatePanel/Dedicate")
    dedicate_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DYANSTY_DEDICATE
    self.dedicate_count = dedicate_panel:FindChild("Count"):GetComponent("Text")
    local learn_spell_list = learn_panel:FindChild("SpellList/View/Content")
    self.tab_data_dict[kTabEnum.Learn].list_rect = learn_spell_list:GetComponent("RectTransform")
    local learn_spell_item = learn_spell_list:FindChild("SpellItem")
    for i, spell_data in ipairs(SpecMgrs.data_mgr:GetAllDynastySpellData()) do
        local spell_item = self:GetUIObject(learn_spell_item, learn_spell_list)
        local info_panel = spell_item:FindChild("Info")
        UIFuncs.AssignSpriteByIconID(spell_data.icon, info_panel:FindChild("SpellIcon"):GetComponent("Image"))
        info_panel:FindChild("Name"):GetComponent("Text").text = spell_data.name
        local data = {}
        local cur_lv_panel = info_panel:FindChild("CurLvPanel")
        cur_lv_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CUR_LEVEL
        data.lv = cur_lv_panel:FindChild("Value"):GetComponent("Text")
        local cur_attr_panel = info_panel:FindChild("CurAttrPanel")
        cur_attr_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CUR_ATTR
        data.cur_attr = cur_attr_panel:FindChild("Value"):GetComponent("Text")
        local next_attr_panel = info_panel:FindChild("NextAttrPanel")
        data.next_attr_panel = next_attr_panel
        next_attr_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.NEXT_ATTR
        data.next_attr = next_attr_panel:FindChild("Value"):GetComponent("Text")
        local material_panel = spell_item:FindChild("MaterialPanel")
        data.dedicate_cost = material_panel
        data.cost_count = material_panel:FindChild("Text"):GetComponent("Text")
        local learn_btn = spell_item:FindChild("LearnBtn")
        data.learn_btn_cmp = learn_btn:GetComponent("Button")
        learn_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.LEARN_TEXT
        local learn_disable = learn_btn:FindChild("Disable")
        data.learn_disable = learn_disable
        self.learn_spell_data_dict[spell_data.id] = data
        self:AddClick(learn_btn, function ()
            self:SendLearnSpell(spell_data.id)
        end)
    end

    local research_panel = self.main_panel:FindChild("ResearchPanel")
    self.tab_data_dict[kTabEnum.Research].panel = research_panel
    self.tab_data_dict[kTabEnum.Research].init_func = self.InitResearchPanel
    local exp_panel = research_panel:FindChild("ExpPanel")
    self.dynasty_lv = exp_panel:FindChild("Level"):GetComponent("Text")
    local dynasty_exp_panel = exp_panel:FindChild("DynastyExp")
    dynasty_exp_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_EXP
    self.dynasty_exp_count = dynasty_exp_panel:FindChild("Count"):GetComponent("Text")
    local research_spell_list = research_panel:FindChild("SpellList/View/Content")
    self.tab_data_dict[kTabEnum.Research].list_rect = research_spell_list:GetComponent("RectTransform")
    local research_spell_item = research_spell_list:FindChild("SpellItem")
    for i, spell_data in ipairs(SpecMgrs.data_mgr:GetAllDynastySpellData()) do
        local spell_item = self:GetUIObject(research_spell_item, research_spell_list)
        local info_panel = spell_item:FindChild("Info")
        UIFuncs.AssignSpriteByIconID(spell_data.icon, info_panel:FindChild("SpellIcon"):GetComponent("Image"))
        local data = {}
        data.name = info_panel:FindChild("Name"):GetComponent("Text")
        local cur_attr_panel = info_panel:FindChild("CurAttrPanel")
        cur_attr_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CUR_ATTR
        data.cur_attr = cur_attr_panel:FindChild("Value"):GetComponent("Text")
        local next_attr_panel = info_panel:FindChild("NextAttrPanel")
        data.next_attr_panel = next_attr_panel
        next_attr_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.NEXT_ATTR
        data.next_attr = next_attr_panel:FindChild("Value"):GetComponent("Text")
        data.condition = info_panel:FindChild("Condition")
        local material_panel = spell_item:FindChild("MaterialPanel")
        data.exp_cost_panel = material_panel
        data.cost_count = material_panel:FindChild("Text"):GetComponent("Text")
        local research_btn = spell_item:FindChild("ResearchBtn")
        data.research_btn_cmp = research_btn:GetComponent("Button")
        research_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.UPGRADE
        local learn_disable = research_btn:FindChild("Disable")
        data.learn_disable = learn_disable
        self.research_spell_data_dict[spell_data.id] = data
        self:AddClick(research_btn, function ()
            self:SendUpgradeDynastySpell(spell_data.id)
        end)
    end
end

function DynastyInstituteUI:InitUI()
    self.dy_dynasty_data:UpdateDynastyMemberInfo(function ()
        if not self.is_res_ok then return end
        self:InitManageState()
    end)
    self.dy_dynasty_data:RegisterKickedOutDynastyEvent("DynastyInstituteUI", self.Hide, self)
    self.dy_dynasty_data:RegisterUpdateDynastyJobEvent("DynastyInstituteUI", self.InitManageState, self)
end

function DynastyInstituteUI:InitManageState()
    local self_job = self.dy_dynasty_data:GetSelfInfo().job
    local job_data = SpecMgrs.data_mgr:GetDynastyJobData(self_job)
    self.research_btn:SetActive(job_data.is_manager)
    self:UpdateTabPanel(job_data.is_manager and self.cur_tab or kTabEnum.Learn)
end

function DynastyInstituteUI:UpdateTabPanel(tab)
    if self.cur_tab == tab then return end
    if self.cur_tab then
        local cur_tab_data = self.tab_data_dict[self.cur_tab]
        cur_tab_data.select:SetActive(false)
        cur_tab_data.panel:SetActive(false)
    end
    self.cur_tab = tab
    if not self.cur_tab then return end
    local cur_tab_data = self.tab_data_dict[self.cur_tab]
    cur_tab_data.select:SetActive(true)
    cur_tab_data.init_func(self)
    cur_tab_data.panel:SetActive(true)
    cur_tab_data.list_rect.anchoredPosition = Vector2.zero
end

function DynastyInstituteUI:InitLearnPanel()
    self.dedicate_count.text = ComMgrs.dy_data_mgr:ExGetCurrencyCount(CSConst.Virtual.Dedicate) or 0
    for i, spell_data in ipairs(SpecMgrs.data_mgr:GetAllDynastySpellData()) do
        local learn_spell_data = self.learn_spell_data_dict[spell_data.id]
        local dynasty_spell_level = self.dy_dynasty_data:GetDynastySpellLevel(spell_data.id)
        local spell_level = math.min(self.dy_dynasty_data:GetSelfSpellLevel(spell_data.id), dynasty_spell_level)
        learn_spell_data.lv.text = string.format(UIConst.Text.PER_VALUE, spell_level, dynasty_spell_level)
        local cur_spell_attr = CSFunction.get_dynasty_spell_attr_value(spell_data.id, spell_level)
        local attr_format = spell_data.attribute and UIConst.Text.DYNASTY_SPELL_ATTR_FORMAT or UIConst.Text.ADD
        learn_spell_data.cur_attr.text = string.format(attr_format, spell_data.name, math.floor(cur_spell_attr or 0))
        learn_spell_data.next_attr_panel:SetActive(spell_level < dynasty_spell_level)
        learn_spell_data.dedicate_cost:SetActive(spell_level < dynasty_spell_level)
        if spell_level < dynasty_spell_level then
            local next_spell_attr = CSFunction.get_dynasty_spell_attr_value(spell_data.id, spell_level + 1)
            learn_spell_data.next_attr.text = string.format(attr_format, spell_data.name, math.floor(next_spell_attr or 0))
            learn_spell_data.cost_count.text = CSFunction.get_dynasty_spell_cost(spell_data.id, spell_level + 1).player_cost
        end
        learn_spell_data.learn_btn_cmp.interactable = spell_level < dynasty_spell_level
        learn_spell_data.learn_disable:SetActive(spell_level >= dynasty_spell_level)
    end
end

function DynastyInstituteUI:InitResearchPanel()
    SpecMgrs.msg_mgr:SendGetDynastyBasicInfo({}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_DYNASTY_BASIC_INFO_FAILED)
        else
            if not self.is_res_ok then return end
            self.dynasty_base_info = resp.dynasty_base_info
            self.dynasty_lv.text = string.format(UIConst.Text.DYNASTY_LV_FORMAT, self.dynasty_base_info.dynasty_level)
            local dynasty_level_data = SpecMgrs.data_mgr:GetDynastyData(self.dynasty_base_info.dynasty_level)
            self.dynasty_exp_count.text = self.dynasty_base_info.dynasty_exp - dynasty_level_data.total_exp
            self:InitDynastySpellItem()
        end
    end)
end

function DynastyInstituteUI:InitDynastySpellItem()
    for i, spell_data in ipairs(SpecMgrs.data_mgr:GetAllDynastySpellData()) do
        local research_spell_data = self.research_spell_data_dict[spell_data.id]
        local cur_spell_lv = self.dy_dynasty_data:GetDynastySpellLevel(spell_data.id)
        research_spell_data.name.text = string.format(UIConst.Text.SPELL_NAME_WITH_LEVEL, spell_data.name, cur_spell_lv)
        local cur_spell_attr = CSFunction.get_dynasty_spell_attr_value(spell_data.id, cur_spell_lv)
        local attr_format = spell_data.attribute and UIConst.Text.DYNASTY_SPELL_ATTR_FORMAT or UIConst.Text.ADD
        research_spell_data.cur_attr.text = string.format(attr_format, spell_data.name, math.floor(cur_spell_attr or 0))
        local max_level = spell_data.spell_level_list[#spell_data.spell_level_list]
        research_spell_data.next_attr_panel:SetActive(cur_spell_lv < max_level)
        research_spell_data.condition:SetActive(cur_spell_lv < max_level)
        research_spell_data.exp_cost_panel:SetActive(cur_spell_lv < max_level)
        local research_flag = cur_spell_lv < max_level
        if cur_spell_lv < max_level then
            local next_spell_attr = CSFunction.get_dynasty_spell_attr_value(spell_data.id, cur_spell_lv + 1)
            research_spell_data.next_attr.text = string.format(attr_format, spell_data.name, next_spell_attr)
            research_spell_data.cost_count.text = CSFunction.get_dynasty_spell_cost(spell_data.id, cur_spell_lv + 1).dynasty_cost
            if self.dynasty_base_info.dynasty_level < spell_data.dynasty_level then
                research_spell_data.condition:GetComponent("Text").text = string.format(UIConst.Text.RESEARCH_SPELL_UNLOCK_LEVEL, spell_data.dynasty_level)
                research_flag = false
            else
                local cur_spell_limit = 0
                for i, level in ipairs(spell_data.dynasty_level_list) do
                    if self.dynasty_base_info.dynasty_level < level then break end
                    cur_spell_limit = spell_data.spell_level_list[i]
                end
                research_flag = cur_spell_lv < cur_spell_limit
                research_spell_data.condition:GetComponent("Text").text = string.format(UIConst.Text.RESEARCH_SPELL_LEVEL_LIMIT, cur_spell_limit)
            end
        end
        research_spell_data.research_btn_cmp.interactable = research_flag
        research_spell_data.learn_disable:SetActive(not research_flag)
    end
end

function DynastyInstituteUI:SendLearnSpell(spell_id)
    local spell_level = self.dy_dynasty_data:GetSelfSpellLevel(spell_id)
    local dedicate_count = self.dy_bag_data:GetBagItemCount(CSConst.Virtual.Dedicate) or 0
    local cost_count = CSFunction.get_dynasty_spell_cost(spell_id, spell_level + 1).player_cost
    if dedicate_count < cost_count then
        local dedicate_data = SpecMgrs.data_mgr:GetItemData(CSConst.Virtual.Dedicate)
        SpecMgrs.ui_mgr:ShowMsgBox(string.format(UIConst.Text.ITEM_NOT_ENOUGH, dedicate_data.name))
        return
    end
    SpecMgrs.msg_mgr:SendStudyDynastySpell({spell_id = spell_id}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.LEARN_SPELL_FAILED)
        else
            self:InitLearnPanel()
        end
    end)
end

function DynastyInstituteUI:SendUpgradeDynastySpell(spell_id)
    local spell_level = self.dy_dynasty_data:GetDynastySpellLevel(spell_id)
    local cost_count = CSFunction.get_dynasty_spell_cost(spell_id, spell_level + 1).dynasty_cost
    local dynasty_level_data = SpecMgrs.data_mgr:GetDynastyData(self.dynasty_base_info.dynasty_level)
    local dynasty_exp = self.dynasty_base_info.dynasty_exp - dynasty_level_data.total_exp
    if dynasty_exp < cost_count then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.DYNASTY_EXP_NOT_ENOUGH)
        return
    end
    SpecMgrs.msg_mgr:SendUpgradeDynastySpell({spell_id = spell_id}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.UPGRADE_SPELL_FAILED)
        else
            self:InitResearchPanel()
        end
    end)
end

return DynastyInstituteUI