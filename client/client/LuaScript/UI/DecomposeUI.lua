local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local AttrUtil = require("BaseUtilities.AttrUtil")
local ItemUtil = require("BaseUtilities.ItemUtil")
local CSFunction = require("CSCommon.CSFunction")
local UnitConst = require("Unit.UnitConst")

local DecomposeUI = class("UI.DecomposeUI", UIBase)

local kMaxDecomposeCount = 10
local kDecomposeEffectInterval = 0.2
local kDecomposeItemEffectDuration = 0.5
local kDecomposeAnimTime = 3
local kHeroRecoverAnimDuration = 1.2
local kEquipRecoverAnimDuration = 1.2

local kOpEnum = {
    Decompose = 1,
    Recover = 2,
}
local kDecomposeItem = {
    HeroFragment = 1,
    Equipment = 2,
    LoverFragment = 3,
}
local kRecoverItem = {
    Hero = 1,
    Equipment = 2,
    Treasure = 3,
}
local kEffectTriggerNameDict = {
    EquipmentRecover = "equip_recover",
    HeroRecover = "hero_recover",
    Reset = "reset",
}
local kNoDecomposeItemTips = {
    [kDecomposeItem.HeroFragment] = string.format(UIConst.Text.NO_DECOMPOSE_TIP, UIConst.Text.HERO_FRAGMENT_TEXT),
    [kDecomposeItem.Equipment] = string.format(UIConst.Text.NO_DECOMPOSE_TIP, UIConst.Text.EQUIPMENT_TEXT),
    [kDecomposeItem.LoverFragment] = string.format(UIConst.Text.NO_DECOMPOSE_TIP, UIConst.Text.LOVER_FRAGMENT_TEXT),
}
local kNoRecoverItemTips = {
    [kRecoverItem.Hero] = string.format(UIConst.Text.NO_RECOVER_TIP, UIConst.Text.HERO_TEXT),
    [kRecoverItem.Equipment] = string.format(UIConst.Text.NO_RECOVER_TIP, UIConst.Text.EQUIPMENT_TEXT),
    [kRecoverItem.Treasure] = string.format(UIConst.Text.NO_RECOVER_TIP, UIConst.Text.TREASURE_TEXT),
}

function DecomposeUI:DoInit()
    DecomposeUI.super.DoInit(self)
    self.prefab_path = "UI/Common/DecomposeUI"
    self.dy_bag_data = ComMgrs.dy_data_mgr.bag_data
    self.dy_hero_data = ComMgrs.dy_data_mgr.night_club_data
    self.star_limit = SpecMgrs.data_mgr:GetParamData("hero_star_lv_limit").f_value
    self.auto_select_max_quality = SpecMgrs.data_mgr:GetParamData("auto_select_decompose_item_max_quality").quality_id
    self.hero_recover_cost_data = SpecMgrs.data_mgr:GetParamData("hero_recover_cost")
    self.equip_recover_cost_data = SpecMgrs.data_mgr:GetParamData("equip_recover_cost")

    self.decompose_sound = SpecMgrs.data_mgr:GetParamData("decompose_sound").sound_id
    self.decompose_finish_sound = SpecMgrs.data_mgr:GetParamData("decompose_finish_sound").sound_id

    self.select_decompose_item_dict = {}
    self.select_decompose_item_list = {}

    self.decompose_material_item_list = {}
    self.hero_active_star_item_list = {}
    self.equip_star_item_list = {}
    self.op_data_dict = {}
    self.selection_item_list = {}
    self.decompose_tab_data_dict = {}
    self.recover_tab_data_dict = {}
    self.effect_item_list = {}
end

function DecomposeUI:OnGoLoadedOk(res_go)
    DecomposeUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function DecomposeUI:Hide()
    self:UpdateOpPanel()
    self:UpdateDecomposeTab()
    self:UpdateRecoverTab()
    self:ClearSelectionItem()
    self:ClearStarItem()
    if self.effect_timer then
        self:RemoveTimer(self.effect_timer)
        self:ClearEffectItem()
        self.effect_mask:SetActive(false)
        self.effect_timer = nil
    end
    if self.decompose_timer then
        self:RemoveTimer(self.decompose_timer)
        self.decompose_timer = nil
    end
    DecomposeUI.super.Hide(self)
end

function DecomposeUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    DecomposeUI.super.Show(self)
end

function DecomposeUI:InitRes()
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "DecomposeUI")

    self.effect_animator = self.main_panel:GetComponent("Animator")
    local op_catalog_content = self.main_panel:FindChild("OpCatalog/Viewport/Content")
    self.op_data_dict[kOpEnum.Decompose] = {}
    local decompose_tab_btn = op_catalog_content:FindChild("DecomposeBtn")
    decompose_tab_btn:FindChild("CatalogName"):GetComponent("Text").text = UIConst.Text.DECOMPOSE_TEXT
    local decompose_tab_select = decompose_tab_btn:FindChild("Select")
    self.op_data_dict[kOpEnum.Decompose].select = decompose_tab_select
    decompose_tab_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DECOMPOSE_TEXT
    self:AddClick(decompose_tab_btn, function ()
        self:UpdateOpPanel(kOpEnum.Decompose)
    end)
    self.op_data_dict[kOpEnum.Recover] = {}
    local recover_tab_btn = op_catalog_content:FindChild("RecoverBtn")
    recover_tab_btn:FindChild("CatalogName"):GetComponent("Text").text = UIConst.Text.RECOVER_TEXT
    local recover_tab_select = recover_tab_btn:FindChild("Select")
    self.op_data_dict[kOpEnum.Recover].select = recover_tab_select
    recover_tab_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.RECOVER_TEXT
    self:AddClick(recover_tab_btn, function ()
        self:UpdateOpPanel(kOpEnum.Recover)
    end)

    -- 分解界面
    self.decompose_panel = self.main_panel:FindChild("DecomposePanel")
    self.op_data_dict[kOpEnum.Decompose].content = self.decompose_panel
    self.op_data_dict[kOpEnum.Decompose].init_func = self.InitDecomposePanel
    local decompose_item_tab_content = self.decompose_panel:FindChild("ItemTabPanel/Viewport/Content")
    local decompose_hero_fragment_btn = decompose_item_tab_content:FindChild("HeroFragment")
    decompose_hero_fragment_btn:FindChild("CatalogName"):GetComponent("Text").text = UIConst.Text.HERO_FRAGMENT_TEXT
    local decompose_hero_fragment_select = decompose_hero_fragment_btn:FindChild("Select")
    self.decompose_tab_data_dict[kDecomposeItem.HeroFragment] = {}
    self.decompose_tab_data_dict[kDecomposeItem.HeroFragment].select = decompose_hero_fragment_select
    self.decompose_tab_data_dict[kDecomposeItem.HeroFragment].init_select_func = function ()
        self:ShowSelectDecomposeItemPanel(self:GetFragmentList(), UIConst.Text.SELECT_FRAGMENT)
    end
    decompose_hero_fragment_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.HERO_FRAGMENT_TEXT
    self:AddClick(decompose_hero_fragment_btn, function ()
        self:UpdateDecomposeTab(kDecomposeItem.HeroFragment)
    end)
    local decompose_equip_btn = decompose_item_tab_content:FindChild("Equipment")
    decompose_equip_btn:FindChild("CatalogName"):GetComponent("Text").text = UIConst.Text.EQUIPMENT_TEXT
    local decompose_equip_select = decompose_equip_btn:FindChild("Select")
    self.decompose_tab_data_dict[kDecomposeItem.Equipment] = {}
    self.decompose_tab_data_dict[kDecomposeItem.Equipment].select = decompose_equip_select
    self.decompose_tab_data_dict[kDecomposeItem.Equipment].init_select_func = function ()
        self:ShowSelectDecomposeItemPanel(self:GetEquipList(), UIConst.Text.SELECT_EQUIPMENT)
    end
    decompose_equip_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.EQUIPMENT_TEXT
    self:AddClick(decompose_equip_btn, function ()
        self:UpdateDecomposeTab(kDecomposeItem.Equipment)
    end)

    local decompose_lover_btn = decompose_item_tab_content:FindChild("LoverFragment")
    decompose_lover_btn:FindChild("CatalogName"):GetComponent("Text").text = UIConst.Text.LOVER_FRAGMENT_TEXT
    local decompose_lover_select = decompose_lover_btn:FindChild("Select")
    self.decompose_tab_data_dict[kDecomposeItem.LoverFragment] = {}
    self.decompose_tab_data_dict[kDecomposeItem.LoverFragment].select = decompose_lover_select
    self.decompose_tab_data_dict[kDecomposeItem.LoverFragment].init_select_func = function ()
        self:ShowSelectDecomposeItemPanel(self:GetLoverFragmentList(), UIConst.Text.SELECT_LOVER_FRAGMENT)
    end
    decompose_lover_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.LOVER_FRAGMENT_TEXT
    self:AddClick(decompose_lover_btn, function ()
        self:UpdateDecomposeTab(kDecomposeItem.LoverFragment)
    end)

    local decompose_content = self.decompose_panel:FindChild("Content")
    self.decompose_material_list = decompose_content:FindChild("MaterialList")
    self.decompose_effect_item = self.decompose_material_list:FindChild("Effect")
    local effect_anchor = self.decompose_effect_item:GetComponent("RectTransform").anchorMin
    local material_list_size = self.decompose_material_list:GetComponent("RectTransform").rect.size
    for i = 1, kMaxDecomposeCount do
        local material_item = self.decompose_material_list:FindChild("Material" .. i)
        local material_item_data = {}
        local anchor_offset = material_item:GetComponent("RectTransform").anchorMin - effect_anchor
        material_item_data.effect_offset = Vector2.New(anchor_offset.x * material_list_size.x, anchor_offset.y * material_list_size.y)
        local add_btn = material_item:FindChild("Add")
        self:AddClick(add_btn, function ()
            self.decompose_tab_data_dict[self.cur_decompose_item_tab].init_select_func(self)
        end)
        material_item_data.add_btn_cmp = add_btn:GetComponent("Button")
        material_item_data.item = material_item:FindChild("Item")
        material_item_data.count = material_item:FindChild("Item/Count")
        local remove_btn = material_item:FindChild("Remove")
        material_item_data.remove_btn = remove_btn
        self:AddClick(remove_btn, function ()
            local selection_data = table.remove(self.select_decompose_item_list, i)
            self.select_decompose_item_dict[selection_data.guid] = nil
            self:UpdateSelectDecomposeItem()
        end)
        self.decompose_material_item_list[i] = material_item_data
    end
    local decompose_machine = decompose_content:FindChild("Mask/DecomposeMachine")
    self.decompose_anim_state = decompose_machine:GetComponent("SkeletonGraphic").AnimationState
    self.decompose_anim_state.TimeScale = 0
    self.decompose_panel:SetActive(false)
    -- TODO 分解特效
    local bottom_panel = self.decompose_panel:FindChild("BottomPanel")
    local auto_select_btn = bottom_panel:FindChild("AutoSelectBtn")
    auto_select_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.AUTO_ADD_TEXT
    self:AddClick(auto_select_btn, function ()
        self:AutoSelectDecomposeItem()
    end)
    local decompose_btn = bottom_panel:FindChild("DecomposeBtn")
    decompose_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DECOMPOSE_TEXT
    self:AddClick(decompose_btn, function ()
        self:CalcDecomposeReward()
    end)
    self.decompose_btn_cmp = decompose_btn:GetComponent("Button")
    self.decompose_disable = decompose_btn:FindChild("Disable")

    -- 重生界面
    self.recover_panel = self.main_panel:FindChild("RecoverPanel")
    self.op_data_dict[kOpEnum.Recover].content = self.recover_panel
    self.op_data_dict[kOpEnum.Recover].init_func = self.InitRecoverPanel
    local recover_item_tab_content = self.recover_panel:FindChild("ItemTabPanel/Viewport/Content")
    local recover_hero_btn = recover_item_tab_content:FindChild("Hero")
    recover_hero_btn:FindChild("CatalogName"):GetComponent("Text").text = UIConst.Text.HERO_TEXT
    local recover_hero_select = recover_hero_btn:FindChild("Select")
    self.recover_tab_data_dict[kRecoverItem.Hero] = {}
    self.recover_tab_data_dict[kRecoverItem.Hero].select = recover_hero_select
    self.recover_tab_data_dict[kRecoverItem.Hero].init_select_func = self.ShowSelectRecoverHeroPanel
    recover_hero_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.HERO_TEXT
    self:AddClick(recover_hero_btn, function ()
        self:UpdateRecoverTab(kRecoverItem.Hero)
        UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetItemData(self.hero_recover_cost_data.item_id).icon, self.recover_material_icon)
        self.recover_material_count.text = self.hero_recover_cost_data.count
    end)
    local recover_equip_btn = recover_item_tab_content:FindChild("Equipment")
    recover_equip_btn:FindChild("CatalogName"):GetComponent("Text").text = UIConst.Text.EQUIPMENT_TEXT
    local recover_equip_select = recover_equip_btn:FindChild("Select")
    self.recover_tab_data_dict[kRecoverItem.Equipment] = {}
    self.recover_tab_data_dict[kRecoverItem.Equipment].select = recover_equip_select
    self.recover_tab_data_dict[kRecoverItem.Equipment].init_select_func = function ()
        self:ShowSelectRecoverEquipPanel(self:GetEquipList())
    end
    recover_equip_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.EQUIPMENT_TEXT
    self:AddClick(recover_equip_btn, function ()
        self:UpdateRecoverTab(kRecoverItem.Equipment)
        UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetItemData(self.equip_recover_cost_data.item_id).icon, self.recover_material_icon)
        self.recover_material_count.text = self.equip_recover_cost_data.count
    end)
    local recover_treasure_btn = recover_item_tab_content:FindChild("Treasure")
    recover_treasure_btn:FindChild("CatalogName"):GetComponent("Text").text = UIConst.Text.TREASURE_TEXT
    local recover_treasure_select = recover_treasure_btn:FindChild("Select")
    self.recover_tab_data_dict[kRecoverItem.Treasure] = {}
    self.recover_tab_data_dict[kRecoverItem.Treasure].select = recover_treasure_select
    self.recover_tab_data_dict[kRecoverItem.Treasure].init_select_func = function ()
        self:ShowSelectRecoverEquipPanel(self:GetTreasureList())
    end
    recover_treasure_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.TREASURE_TEXT
    self:AddClick(recover_treasure_btn, function ()
        self:UpdateRecoverTab(kRecoverItem.Treasure)
        UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetItemData(self.equip_recover_cost_data.item_id).icon, self.recover_material_icon)
        self.recover_material_count.text = self.equip_recover_cost_data.count
    end)
    -- 头目
    local hero_recover_panel = self.recover_panel:FindChild("HeroPanel")
    self.recover_tab_data_dict[kRecoverItem.Hero].panel = hero_recover_panel
    self.hero_empty_panel = hero_recover_panel:FindChild("EmptyPanel")
    self.recover_tab_data_dict[kRecoverItem.Hero].empty = self.hero_empty_panel
    self.hero_empty_panel:FindChild("Tip"):GetComponent("Text").text = UIConst.Text.RECOVER_HERO_TIP_TEXT
    self:AddClick(self.hero_empty_panel:FindChild("Add"), function ()
        self:ShowSelectRecoverHeroPanel()
    end)
    self.hero_recover_content = hero_recover_panel:FindChild("Content")
    self.recover_tab_data_dict[kRecoverItem.Hero].content = self.hero_recover_content
    self.hero_ground = self.hero_recover_content:FindChild("Ground"):GetComponent("Image")
    self.hero_recover_model = self.hero_recover_content:FindChild("HeroModel")
    self:AddClick(self.hero_recover_model, function ()
        self:ShowSelectRecoverHeroPanel()
    end)
    self.hero_recover_content:FindChild("InfoPanel/Tip"):GetComponent("Text").text = UIConst.Text.RECOVER_HERO_TIP_TEXT
    local hero_info_panel = self.hero_recover_content:FindChild("InfoPanel/Info")
    self.hero_level = hero_info_panel:FindChild("Level"):GetComponent("Text")
    self.hero_destiny_lv = hero_info_panel:FindChild("DestinyLv"):GetComponent("Text")
    self.hero_break_lv = hero_info_panel:FindChild("BreakLv"):GetComponent("Text")
    self.hero_destiny_exp = hero_info_panel:FindChild("DestinyExp"):GetComponent("Text")
    local hero_star_panel = hero_info_panel:FindChild("StarPanel")
    for i = 1, self.star_limit do
        self.hero_active_star_item_list[i] = hero_star_panel:FindChild("Star" .. i .. "/Active")
    end
    -- 装备
    self.equip_recover_panel = self.recover_panel:FindChild("EquipPanel")
    self.recover_tab_data_dict[kRecoverItem.Equipment].panel = self.equip_recover_panel
    self.equip_empty_panel = self.equip_recover_panel:FindChild("EmptyPanel")
    self.recover_tab_data_dict[kRecoverItem.Equipment].empty = self.equip_empty_panel
    self.equip_empty_panel:FindChild("Tip"):GetComponent("Text").text = UIConst.Text.RECOVER_EQUIP_TIP_TEXT
    self:AddClick(self.equip_empty_panel:FindChild("Add"), function ()
        self:ShowSelectRecoverEquipPanel(self:GetEquipList())
    end)
    self.equip_recover_content = self.equip_recover_panel:FindChild("Content")
    self.recover_tab_data_dict[kRecoverItem.Equipment].content = self.equip_recover_content
    self.equip_ground = self.equip_recover_content:FindChild("Ground"):GetComponent("Image")
    self.equip_img = self.equip_recover_content:FindChild("EquipImg")
    self.equip_img_cmp = self.equip_img:GetComponent("Image")
    self:AddClick(self.equip_img, function ()
        self:ShowSelectRecoverEquipPanel(self:GetEquipList())
    end)
    self.equip_recover_content:FindChild("InfoPanel/Tip"):GetComponent("Text").text = UIConst.Text.RECOVER_EQUIP_TIP_TEXT
    local equip_info_panel = self.equip_recover_content:FindChild("InfoPanel/Info")
    self.equip_attr = equip_info_panel:FindChild("Attr")
    self.equip_attr_text = self.equip_attr:GetComponent("Text")
    self.equip_extra_attr = equip_info_panel:FindChild("ExtraAttr")
    self.equip_extra_attr_text = self.equip_extra_attr:GetComponent("Text")
    self.equip_strengthen_lv = equip_info_panel:FindChild("StrengthenLv"):GetComponent("Text")
    self.equip_refine_lv = equip_info_panel:FindChild("RefineLv"):GetComponent("Text")
    self.equip_star_panel = equip_info_panel:FindChild("StarPanel")
    self.equip_star_item = self.equip_star_panel:FindChild("Star")
    -- 宝物
    self.treasure_recover_panel = self.recover_panel:FindChild("TreasurePanel")
    self.recover_tab_data_dict[kRecoverItem.Treasure].panel = self.treasure_recover_panel
    self.treasure_empty_panel = self.treasure_recover_panel:FindChild("EmptyPanel")
    self.recover_tab_data_dict[kRecoverItem.Treasure].empty = self.treasure_empty_panel
    self.treasure_empty_panel:FindChild("Tip"):GetComponent("Text").text = UIConst.Text.RECOVER_TREASURE_TIP_TEXT
    self:AddClick(self.treasure_empty_panel:FindChild("Add"), function ()
        self:ShowSelectRecoverEquipPanel(self:GetTreasureList())
    end)
    self.treasure_recover_content = self.treasure_recover_panel:FindChild("Content")
    self.recover_tab_data_dict[kRecoverItem.Treasure].content = self.treasure_recover_content
    self.treasure_ground = self.treasure_recover_content:FindChild("Ground"):GetComponent("Image")
    self.treasure_img = self.treasure_recover_content:FindChild("TreasureImg")
    self.treasure_img_cmp = self.treasure_img:GetComponent("Image")
    self:AddClick(self.treasure_img, function ()
        self:ShowSelectRecoverEquipPanel(self:GetTreasureList())
    end)
    self.treasure_recover_content:FindChild("InfoPanel/Tip"):GetComponent("Text").text = UIConst.Text.RECOVER_TREASURE_TIP_TEXT
    local treasure_info_panel = self.treasure_recover_content:FindChild("InfoPanel/Info")
    self.treasure_attr = treasure_info_panel:FindChild("Attr"):GetComponent("Text")
    self.treasure_extra_attr = treasure_info_panel:FindChild("ExtraAttr"):GetComponent("Text")
    self.treasure_strengthen_lv = treasure_info_panel:FindChild("StrengthenLv"):GetComponent("Text")
    self.treasure_refine_lv = treasure_info_panel:FindChild("RefineLv"):GetComponent("Text")

    bottom_panel = self.recover_panel:FindChild("BottomPanel")
    local recover_btn = bottom_panel:FindChild("RecoverBtn")
    local recover_material_panel = recover_btn:FindChild("MaterialPanel")
    self.recover_material_icon = recover_material_panel:FindChild("MaterialIcon"):GetComponent("Image")
    self.recover_material_count = recover_material_panel:FindChild("Count"):GetComponent("Text")
    recover_material_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.RECOVER_TEXT
    self.recover_btn_cmp = recover_btn:GetComponent("Button")
    self.recover_disable = recover_btn:FindChild("Disable")
    self:AddClick(recover_btn, function ()
        self:CalcRecoverReward()
    end)

    self.effect_mask = self.main_panel:FindChild("EffectMask")
end

function DecomposeUI:InitUI()
    self:UpdateOpPanel(self.cur_op or kOpEnum.Decompose)
    self:RegisterEvent( ComMgrs.dy_data_mgr, "UpdateCurrencyEvent", function (_, currency)
        UIFuncs.UpdateCurrencyItemNum(self._item_to_text_list, currency)
    end)
end

function DecomposeUI:UpdateOpPanel(op)
    if self.cur_op == op then return end
    if self.cur_op then
        local last_op_data = self.op_data_dict[self.cur_op]
        last_op_data.select:SetActive(false)
        last_op_data.content:SetActive(false)
    end
    self.cur_op = op
    if not self.cur_op then return end
    local cur_op_data = self.op_data_dict[self.cur_op]
    cur_op_data.select:SetActive(true)
    self:UpdateDecomposeTab()
    self:UpdateRecoverTab()
    cur_op_data.init_func(self)
    cur_op_data.content:SetActive(true)
end

function DecomposeUI:InitDecomposePanel()
    self:UpdateDecomposeTab(self.cur_decompose_item_tab or kDecomposeItem.HeroFragment)
end

function DecomposeUI:UpdateDecomposeTab(item_tab)
    if self.cur_decompose_item_tab then
        self.decompose_tab_data_dict[self.cur_decompose_item_tab].select:SetActive(false)
    end
    self.cur_decompose_item_tab = item_tab
    if not self.cur_decompose_item_tab then return end
    self.decompose_tab_data_dict[self.cur_decompose_item_tab].select:SetActive(true)
    self:InitSelectDecomposeItem()
end

function DecomposeUI:InitRecoverPanel()
    self:UpdateRecoverTab(self.cur_recover_item_tab or kRecoverItem.Hero)
end

function DecomposeUI:UpdateRecoverTab(item_tab)
    if self.cur_recover_item_tab then
        local last_tab_data = self.recover_tab_data_dict[self.cur_recover_item_tab]
        last_tab_data.select:SetActive(false)
        last_tab_data.panel:SetActive(false)
    end
    self.cur_recover_item_tab = item_tab
    if not self.cur_recover_item_tab then return end
    local cur_tab_data = self.recover_tab_data_dict[self.cur_recover_item_tab]
    cur_tab_data.select:SetActive(true)
    cur_tab_data.panel:SetActive(true)
    cur_tab_data.empty:SetActive(true)
    cur_tab_data.content:SetActive(false)
    self:InitSelectRecoverItem()
end

function DecomposeUI:GetFragmentList()
    local fragment_list = {}
    for _, fragment_data in pairs(self.dy_bag_data:GetAllHeroFragmentData()) do
        table.insert(fragment_list, fragment_data)
    end
    ItemUtil.SortItem(fragment_list)
    return fragment_list
end

function DecomposeUI:GetEquipList()
    local equip_list = {}
    for _, equip_data in pairs(self.dy_bag_data:GetAllEquipInfo()) do
        if not equip_data.lineup_id then table.insert(equip_list, equip_data) end
    end
    ItemUtil.SortEuqipItemList(equip_list)
    return equip_list
end

function DecomposeUI:GetTreasureList()
    local treasure_list = {}
    for _, treasure_data in pairs(self.dy_bag_data:GetAllTreasure()) do
        if not treasure_data.lineup_id and self:CheckEquipIsCultivate(treasure_data) then
            table.insert(treasure_list, treasure_data)
        end
    end
    ItemUtil.SortEuqipItemList(treasure_list)
    return treasure_list
end

function DecomposeUI:GetLoverFragmentList()
    local lover_fragment_list = {}
    for _, fragment_data in pairs(self.dy_bag_data:GetAllLoverFragmentData()) do
        table.insert(lover_fragment_list, fragment_data)
    end
    ItemUtil.SortItem(lover_fragment_list)
    return lover_fragment_list
end

function DecomposeUI:GetHeroList()
    local hero_list = {}
    for _, hero_info in pairs(self.dy_hero_data:GetAllHeroData()) do
        local hero_data = SpecMgrs.data_mgr:GetHeroData(hero_info.hero_id)
        if not self.dy_hero_data:CheckHeroIsLineUp(hero_data.unit_id) then table.insert(hero_list, hero_info) end
    end
    table.sort(hero_list, function (hero1, hero2)
        return hero1.score > hero2.score
    end)
    return hero_list
end

function DecomposeUI:ShowSelectDecomposeItemPanel(item_list, title)
    local data = {
        item_list = item_list,
        title = title,
        cur_select_dict = self.select_decompose_item_dict,
        select_limit = kMaxDecomposeCount,
        empty_tip = kNoDecomposeItemTips[self.cur_decompose_item_tab],
        confirm_cb = function (selection_dict)
            self.select_decompose_item_dict = {}
            self.select_decompose_item_list = {}
            for guid, select_data in pairs(selection_dict) do
                table.insert(self.select_decompose_item_list, select_data)
                self.select_decompose_item_dict[guid] = select_data
            end
            self.temp_select_dict = {}
            self:UpdateSelectDecomposeItem()
        end,
    }
    SpecMgrs.ui_mgr:ShowUI("SelectMultiEquipUI", data)
end

function DecomposeUI:ShowSelectRecoverHeroPanel()
    local data = {
        hero_list = self:GetHeroList(),
        empty_tip = kNoRecoverItemTips[self.cur_recover_item_tab],
        confirm_cb = function (hero_info)
            if self.cur_recover_hero ~= hero_info.hero_id then
                self.cur_recover_hero = hero_info.hero_id
                self:UpdateRecoverHero(hero_info)
            end
        end
    }
    SpecMgrs.ui_mgr:ShowUI("SelectHeroEquipUI", data)
end

function DecomposeUI:ShowSelectRecoverEquipPanel(equip_list)
    local data = {}
    data.empty_tip = kNoRecoverItemTips[self.cur_recover_item_tab]
    data.confirm_cb = function (equip_info)
        if self.cur_recover_equip == equip_info.guid then return end
        self.cur_recover_equip = equip_info.guid
        if self.cur_recover_item_tab == kRecoverItem.Equipment then
            self:UpdateRecoverEquip(equip_info)
        elseif self.cur_recover_item_tab == kRecoverItem.Treasure then
            self:UpdateRecoverTreasure(equip_info)
        end
    end
    if self.cur_recover_item_tab == kRecoverItem.Equipment then
        data.equip_list = equip_list
    elseif self.cur_recover_item_tab == kRecoverItem.Treasure then
        data.treasure_list = equip_list
    end
    SpecMgrs.ui_mgr:ShowUI("SelectHeroEquipUI", data)
end

function DecomposeUI:AddDecomposeItem(guid, count)
    local select_data = {}
    select_data.guid = guid
    select_data.count = count
    select_data.item_data = self.dy_bag_data:GetBagItemDataByGuid(guid).item_data
    self.select_decompose_item_dict[guid] = select_data
    table.insert(self.select_decompose_item_list, select_data)
end

function DecomposeUI:AutoSelectDecomposeItem()
    local is_add = false
    if self.cur_decompose_item_tab == kDecomposeItem.HeroFragment then
        for _, fragment_data in ipairs(self:GetFragmentList()) do
            if #self.select_decompose_item_list >= kMaxDecomposeCount then break end
            if fragment_data.item_data.quality <= self.auto_select_max_quality and not self.select_decompose_item_dict[fragment_data.guid] then
                is_add = true
                self:AddDecomposeItem(fragment_data.guid, fragment_data.count)
            end
        end
    elseif self.cur_decompose_item_tab == kDecomposeItem.Equipment then
        for _, equip_data in ipairs(self:GetEquipList()) do
            if #self.select_decompose_item_list >= kMaxDecomposeCount then break end
            if equip_data.item_data.quality <= self.auto_select_max_quality and not self.select_decompose_item_dict[equip_data.guid] then
                if not self:CheckEquipIsCultivate(equip_data) then
                    is_add = true
                    self:AddDecomposeItem(equip_data.guid, 1)
                end
            end
        end
    elseif self.cur_decompose_item_tab == kDecomposeItem.LoverFragment then
        for _, fragment_data in ipairs(self:GetLoverFragmentList()) do
            if #self.select_decompose_item_list >= kMaxDecomposeCount then break end
            if fragment_data.item_data.quality <= self.auto_select_max_quality and not self.select_decompose_item_dict[fragment_data.guid] then
                is_add = true
                self:AddDecomposeItem(fragment_data.guid, fragment_data.count)
            end
        end
    end
    if not is_add then
        SpecMgrs.ui_mgr:ShowTipMsg(kNoDecomposeItemTips[self.cur_decompose_item_tab])
    end
    self:UpdateSelectDecomposeItem()
end

function DecomposeUI:CheckEquipIsCultivate(equip_data)
    if equip_data.strengthen_lv and equip_data.strengthen_lv > 1 then return true end
    if equip_data.strengthen_exp and equip_data.strengthen_exp > 0 then return true end
    if equip_data.refine_lv and equip_data.refine_lv > 0 then return true end
    if equip_data.refine_exp and equip_data.refine_exp > 0 then return true end
    if equip_data.star_lv and equip_data.star_lv > 0 then return true end
    if equip_data.smelt_lv and equip_data.smelt_lv > 0 or equip_data.smelt_exp > 0 then return true end
    return false
end

function DecomposeUI:UpdateSelectDecomposeItem()
    for i = 1, kMaxDecomposeCount do
        local material_item_data = self.decompose_material_item_list[i]
        local select_data = self.select_decompose_item_list[i]
        material_item_data.add_btn_cmp.interactable = select_data == nil
        material_item_data.item:SetActive(select_data ~= nil)
        material_item_data.remove_btn:SetActive(select_data ~= nil)
        if select_data then
            local item_info = self.dy_bag_data:GetBagItemDataByGuid(select_data.guid)
            UIFuncs.InitItemGo({
                go = material_item_data.item,
                item_data = item_info.item_data,
                can_click = false,
            })
            material_item_data.count:SetActive(select_data.count > 1)
            if select_data.count > 1 then
                material_item_data.count:FindChild("Text"):GetComponent("Text").text = string.format(UIConst.Text.COUNT, select_data.count)
            end
        end
    end
    self.decompose_btn_cmp.interactable = #self.select_decompose_item_list > 0
    self.decompose_disable:SetActive(#self.select_decompose_item_list == 0)
end

function DecomposeUI:UpdateRecoverHero(hero_info)
    local hero_data = SpecMgrs.data_mgr:GetHeroData(hero_info.hero_id)
    local quality_data = SpecMgrs.data_mgr:GetQualityData(hero_data.quality)
    if self.hero_model then ComMgrs.unit_mgr:DestroyUnit(self.hero_model) end
    self.hero_model = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = hero_data.unit_id, parent = self.hero_recover_model})
    self.hero_model:SetPositionByRectName({parent = self.hero_recover_model, name = UnitConst.UnitRect.Full})
    UIFuncs.AssignSpriteByIconID(quality_data.ground, self.hero_ground)
    self.hero_level.text = string.format(UIConst.Text.LEVEL_FORMAT_TEXT, hero_info.level)
    self.hero_destiny_lv.text = string.format(UIConst.Text.DESTINY_DESC, hero_info.destiny_lv)
    self.hero_break_lv.text = string.format(UIConst.Text.BREAK_FORMAT, hero_info.break_lv)
    self.hero_destiny_exp.text = string.format(UIConst.Text.CUR_DESTINY_EXP_FORMAT, hero_info.destiny_exp)
    for i = 1, self.star_limit do
        self.hero_active_star_item_list[i]:SetActive(hero_info.star_lv >= i)
    end
    self.hero_empty_panel:SetActive(false)
    self.hero_recover_content:SetActive(true)
    self.recover_btn_cmp.interactable = true
    self.recover_disable:SetActive(false)
end

function DecomposeUI:UpdateRecoverEquip(equip_info)
    UIFuncs.AssignSpriteByIconID(equip_info.item_data.img, self.equip_img_cmp)
    local quality_data = SpecMgrs.data_mgr:GetQualityData(equip_info.item_data.quality)
    UIFuncs.AssignSpriteByIconID(quality_data.ground, self.equip_ground)
    local attr_dict = AttrUtil.GetEquipAttrDict(equip_info.guid)
    local attr = equip_info.item_data.refine_attr_list[1]
    self.equip_attr_text.text = UIFuncs.GetAttrStr(attr, math.floor(attr_dict[attr] or 0))
    local extra_attr = equip_info.item_data.refine_attr_list[2]
    self.equip_extra_attr_text.text = UIFuncs.GetAttrStr(extra_attr, math.floor(attr_dict[extra_attr] or 0))
    self.equip_strengthen_lv.text = string.format(UIConst.Text.STRENGTHEN_LEVEL_TEXT, equip_info.strengthen_lv)
    self.equip_refine_lv.text = string.format(UIConst.Text.REFINE_LEVEL_FORMAT, equip_info.refine_lv)
    self:ClearStarItem()
    for i = 1, quality_data.e_max_star_lvl do
        local star_item = self:GetUIObject(self.equip_star_item, self.equip_star_panel)
        table.insert(self.equip_star_item_list, star_item)
        star_item:FindChild("Active"):SetActive(equip_info.star_lv >= i)
    end
    self.equip_empty_panel:SetActive(false)
    self.equip_recover_content:SetActive(true)
    self.recover_btn_cmp.interactable = true
    self.recover_disable:SetActive(false)
end

function DecomposeUI:UpdateRecoverTreasure(treasure_info)
    UIFuncs.AssignSpriteByIconID(treasure_info.item_data.icon, self.treasure_img_cmp)
    local quality_data = SpecMgrs.data_mgr:GetQualityData(treasure_info.item_data.quality)
    UIFuncs.AssignSpriteByIconID(quality_data.ground, self.treasure_ground)
    local attr_dict = AttrUtil.GetEquipAttrDict(treasure_info.guid)
    local attr = treasure_info.item_data.base_attr_list[1]
    self.treasure_attr.text = UIFuncs.GetAttrStr(attr, attr_dict[attr])
    local extra_attr = treasure_info.item_data.base_attr_list[2]
    self.treasure_extra_attr.text = UIFuncs.GetAttrStr(extra_attr, attr_dict[extra_attr])
    self.treasure_strengthen_lv.text = string.format(UIConst.Text.STRENGTHEN_LEVEL_TEXT, treasure_info.strengthen_lv)
    self.treasure_refine_lv.text = string.format(UIConst.Text.REFINE_LEVEL_FORMAT, treasure_info.refine_lv)
    self.treasure_empty_panel:SetActive(false)
    self.treasure_recover_content:SetActive(true)
    self.recover_btn_cmp.interactable = true
    self.recover_disable:SetActive(false)
end

function DecomposeUI:InitSelectDecomposeItem()
    self.select_decompose_item_list = {}
    self.select_decompose_item_dict = {}
    self:UpdateSelectDecomposeItem()
end

function DecomposeUI:InitSelectRecoverItem()
    self.cur_recover_equip = nil
    self.cur_recover_hero = nil
    self.recover_btn_cmp.interactable = false
    self.recover_disable:SetActive(true)
    local cur_tab_data = self.recover_tab_data_dict[self.cur_recover_item_tab]
    cur_tab_data.empty:SetActive(true)
    cur_tab_data.content:SetActive(false)
end

-- 计算分解所得
function DecomposeUI:CalcDecomposeReward()
    local item_dict = {}
    if self.cur_decompose_item_tab == kDecomposeItem.Equipment then
        for _, select_data in ipairs(self.select_decompose_item_list) do
            local equip_info = self.dy_bag_data:GetBagItemDataByGuid(select_data.guid)
            local equip_reward_dict = CSFunction.get_equip_recover_item(equip_info)
            for item_id, count in pairs(equip_reward_dict) do
                if not item_dict[item_id] then item_dict[item_id] = 0 end
                item_dict[item_id] = item_dict[item_id] + count
            end
            for i, item_id in ipairs(equip_info.item_data.decompose_list) do
                if not item_dict[item_id] then item_dict[item_id] = 0 end
                item_dict[item_id] = item_dict[item_id] + equip_info.item_data.decompose_value_list[i] * select_data.count
            end
        end
    else
        for _, select_data in ipairs(self.select_decompose_item_list) do
            local item_data = self.dy_bag_data:GetBagItemDataByGuid(select_data.guid).item_data
            for i, item_id in ipairs(item_data.decompose_list) do
                if not item_dict[item_id] then item_dict[item_id] = 0 end
                item_dict[item_id] = item_dict[item_id] + item_data.decompose_value_list[i] * select_data.count
            end
        end
    end
    local item_list = {}
    for item_id, count in pairs(item_dict) do
        local reward_data = {item_id = item_id, count = count, item_data = SpecMgrs.data_mgr:GetItemData(item_id)}
        table.insert(item_list, reward_data)
    end
    ItemUtil.SortItem(item_list)
    local data = {
        item_list = item_list,
        confirm_cb = function ()
            self:SendDecomposeItem(item_list)
        end,
        title = UIConst.Text.DECOMPOSE_RETURN_TITLE,
        desc = UIConst.Text.DECOMPOSE_RETURN_DESC,
    }

    SpecMgrs.ui_mgr:ShowUI("RewardPreviewUI", data)
end

-- 结算重生所得
function DecomposeUI:CalcRecoverReward()
    local cost_data = self.cur_recover_equip and self.equip_recover_cost_data or self.equip_recover_cost_data
    if self.dy_bag_data:GetBagItemCount(cost_data.item_id) < cost_data.count then
        local item_data = SpecMgrs.data_mgr:GetItemData(cost_data.item_id)
        SpecMgrs.ui_mgr:ShowMsgBox(string.format(UIConst.Text.ITEM_NOT_ENOUGH, item_data.name))
        return
    end
    local item_dict = {}
    if self.cur_recover_equip then
        local equip_info = self.dy_bag_data:GetBagItemDataByGuid(self.cur_recover_equip)
        item_dict = CSFunction.get_equip_recover_item(equip_info)
        if not equip_info.item_data.is_treasure then
            local fragment_data = SpecMgrs.data_mgr:GetItemData(equip_info.item_data.fragment)
            item_dict[fragment_data.id] = fragment_data.synthesize_count
        else
            item_dict[equip_info.item_id] = (item_dict[equip_info.item_id] or 0) + 1
        end
    elseif self.cur_recover_hero then
        item_dict = CSFunction.get_hero_recover_item(self.dy_hero_data:GetHeroDataById(self.cur_recover_hero))
        local hero_data = SpecMgrs.data_mgr:GetHeroData(self.cur_recover_hero)
        local fragment_data = SpecMgrs.data_mgr:GetItemData(hero_data.fragment_id)
        item_dict[fragment_data.id] = fragment_data.synthesize_count
    end
    local item_list = {}
    for item_id, count in pairs(item_dict) do
        local reward_data = {item_id = item_id, count = count, item_data = SpecMgrs.data_mgr:GetItemData(item_id)}
        table.insert(item_list, reward_data)
    end
    local data = {}
    data.item_list = item_list
    data.confirm_cb = function ()
        if self.cur_recover_equip then
            self:SendRecoverEquip(item_list)
        elseif self.cur_recover_hero then
            self:SendRecoverHero(item_list)
        end
    end
    ItemUtil.SortItem(data.item_list)
    SpecMgrs.ui_mgr:ShowUI("RewardPreviewUI", data)
end

-- msg
function DecomposeUI:SendDecomposeItem(item_dict)
    SpecMgrs.msg_mgr:SendDecomposeItem({decompose_item_list = self.select_decompose_item_list}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.DECOMPOSE_FAILED_TEXT)
        else
            self.effect_mask:SetActive(true)
            for i, select_data in ipairs(self.select_decompose_item_list) do
                local effect_item = self:GetUIObject(self.decompose_effect_item, self.decompose_material_list)
                local frag_go = effect_item:FindChild("Frag")
                local is_frag = select_data.item_data.sub_type == CSConst.ItemSubType.HeroFragment or select_data.item_data.sub_type == CSConst.ItemSubType.EquipmentFragment
                frag_go:SetActive(is_frag)
                if is_frag then
                    local quality_data = SpecMgrs.data_mgr:GetQualityData(select_data.item_data.quality)
                    UIFuncs.AssignSpriteByIconID(quality_data.frag, effect_item:GetComponent("Image"))
                    if select_data.item_data.sub_type == CSConst.ItemSubType.HeroFragment then
                        local hero_item_data = SpecMgrs.data_mgr:GetItemData(select_data.item_data.hero)
                        local hero_data = SpecMgrs.data_mgr:GetHeroData(hero_item_data.hero_id)
                        local unit_data = SpecMgrs.data_mgr:GetUnitData(hero_data.unit_id)
                        UIFuncs.AssignSpriteByIconID(unit_data.icon, frag_go:GetComponent("Image"))
                    elseif select_data.item_data.sub_type == CSConst.ItemSubType.EquipmentFragment then
                        local item_data = SpecMgrs.data_mgr:GetItemData(select_data.equipment)
                        UIFuncs.AssignSpriteByIconID(item_data.icon, frag_go:GetComponent("Image"))
                    end
                else
                    UIFuncs.AssignSpriteByIconID(select_data.item_data.icon, effect_item:GetComponent("Image"))
                end
                local effect_tween_pos_cmp = effect_item:GetComponent("UITweenPosition")
                local effect_tween_alpha_cmp = effect_item:GetComponent("UITweenAlpha")
                local material_item_data = self.decompose_material_item_list[i]
                material_item_data.item:SetActive(false)
                material_item_data.remove_btn:SetActive(false)
                effect_tween_pos_cmp.from_ = material_item_data.effect_offset
                effect_tween_pos_cmp:SetDelayTime(kDecomposeEffectInterval * (i - 1))
                effect_tween_pos_cmp:Play()
                effect_tween_alpha_cmp:SetDelayTime(kDecomposeEffectInterval * (i - 1))
                effect_tween_alpha_cmp:Play()
                table.insert(self.effect_item_list, effect_item)
            end
            self.effect_timer = self:AddTimer(function ()
                -- TODO 分解特效
                self:ClearEffectItem()
                self.decompose_anim_state.TimeScale = 1
                self.decompose_anim_state:PlayAnimation(0, "animation", true, 0.2)
                self:PlayUISound(self.decompose_sound)
                self.decompose_timer = self:AddTimer(function ()
                    self:PlayUISound(self.decompose_finish_sound)
                    self.decompose_anim_state.TimeScale = 0
                    SpecMgrs.ui_mgr:ShowUI("GetItemUI", item_dict)
                    self.effect_mask:SetActive(false)
                    self:InitSelectDecomposeItem()
                    self:RemoveTimer(self.decompose_timer)
                    self.decompose_timer = nil
                end, kDecomposeAnimTime)
                self:RemoveTimer(self.effect_timer)
                self.effect_timer = nil
            end, kDecomposeItemEffectDuration + (#self.select_decompose_item_list - 1) * kDecomposeEffectInterval)
        end
    end)
end

function DecomposeUI:SendRecoverHero(item_dict)
    SpecMgrs.msg_mgr:SendRecoverHero({hero_id = self.cur_recover_hero}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.RECOVER_FAILED_TEXT)
        else
            self.effect_animator:SetTrigger(kEffectTriggerNameDict.HeroRecover)
            self:AddTimer(function ()
                self.dy_hero_data:RemoveHero(self.cur_recover_hero)
                SpecMgrs.ui_mgr:ShowUI("GetItemUI", item_dict)
                self:InitSelectRecoverItem()
                self.effect_animator:SetTrigger(kEffectTriggerNameDict.Reset)
            end, kHeroRecoverAnimDuration)
        end
    end)
end

function DecomposeUI:SendRecoverEquip(item_dict)
    SpecMgrs.msg_mgr:SendRecoverEquip({item_guid = self.cur_recover_equip}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.RECOVER_FAILED_TEXT)
        else
            self.effect_animator:SetTrigger(kEffectTriggerNameDict.EquipmentRecover)
            self:AddTimer(function ()
                SpecMgrs.ui_mgr:ShowUI("GetItemUI", item_dict)
                self:InitSelectRecoverItem()
                self.effect_animator:SetTrigger(kEffectTriggerNameDict.Reset)
            end, kEquipRecoverAnimDuration)
        end
    end)
end

function DecomposeUI:ClearSelectionItem()
    for _, selection_item in ipairs(self.selection_item_list) do
        self:DelUIObject(selection_item)
    end
    self.selection_item_list = {}
end

function DecomposeUI:ClearEffectItem()
    for _, effect_item in ipairs(self.effect_item_list) do
        self:DelUIObject(effect_item)
    end
    self.effect_item_list = {}
end

function DecomposeUI:ClearStarItem()
    for _, star_item in ipairs(self.equip_star_item_list) do
        self:DelUIObject(star_item)
    end
    self.equip_star_item_list = {}
end

return DecomposeUI