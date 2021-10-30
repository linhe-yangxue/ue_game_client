local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local UnitConst = require("Unit.UnitConst")
local ItemUtil = require("BaseUtilities.ItemUtil")
local CSFunction = require("CSCommon.CSFunction")
local SlideSelectCmp = require("UI.UICmp.SlideSelectCmp")

local ItemInfoUI = class("UI.ItemInfoUI", UIBase)

local kPanelIndex = {
    equipment_fragment = 0,
    equipment = 1,

    treasure_fragment = 0,
    treasure = 1,

    hero_fragment = 0,
    hero = 1,
    hero_fate = 2,

    lover_fragment = 0,
    lover = 1,
}

function ItemInfoUI:DoInit()
    ItemInfoUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ItemInfoUI"
    self.dy_bag_data = ComMgrs.dy_data_mgr.bag_data
    self.multi_info_item_id_list = {}
    self.item_info_go_dict = {}
    self.select_item_go_dict = {}
    self.cur_index = 0
    self.equipment_tab_btn_list = {}
    self.hero_tab_btn_list = {}
    self.lover_tab_btn_list = {}
    self.access_go_dict = {}
    self.select_item_stack = {}
    -- equipment
    self.basic_attr_go_dict = {}
    self.strengthen_attr_go_dict = {}
    self.equipment_go_dict = {}
    self.spell_go_dict = {}
    self.suit_attr_go_dict = {}
    self.suit_spell_go_dict = {}
    -- hero
    self.skill_go_dict = {}
    self.fate_go_dict = {}
    self.talent_go_dict = {}
    self.fate_text_go_dict = {}
    self.fate_item_go_dict = {}
    -- lover
    self.lover_power_hero_item_list = {}
end

function ItemInfoUI:OnGoLoadedOk(res_go)
    ItemInfoUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function ItemInfoUI:Show(item_id)
    self.item_id = item_id
    if self.is_res_ok then
        self:InitUI()
    end
    ItemInfoUI.super.Show(self)
end

function ItemInfoUI:Hide()
    self.item_id = nil
    self.cur_index = 0
    ItemInfoUI.super.Hide(self)
end

function ItemInfoUI:InitRes()
    -- select item
    self.select_info_panel = self.main_panel:FindChild("SelectInfoPanel")
    local select_content = self.select_info_panel:FindChild("Content")
    select_content:FindChild("Title"):GetComponent("Text").text = UIConst.Text.REWARD_PREVIEW_TITLE
    self:AddClick(select_content:FindChild("CloseBtn"), function ()
        self:CloseSelectItemInfoPanel()
    end)
    self.select_item_name = select_content:FindChild("Name"):GetComponent("Text")
    select_content:FindChild("Tip"):GetComponent("Text").text = UIConst.Text.CHOOSE_REWARD_TEXT
    self.select_item_list = select_content:FindChild("ItemList")
    local select_item_submit_btn = select_content:FindChild("BtnPanel/SubmitBtn")
    select_item_submit_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CONFIRM
    self:AddClick(select_item_submit_btn, function ()
        self:CloseSelectItemInfoPanel()
    end)
    -- normal item
    self.normal_item_panel = self.main_panel:FindChild("NormalItemPanel")
    self:AddClick(self.normal_item_panel, function ()
        self:CloseNormalItemInfoPanel()
    end)
    local normal_item_content = self.normal_item_panel:FindChild("Content")
    self:AddClick(normal_item_content:FindChild("CloseBtn"), function ()
        self:CloseNormalItemInfoPanel()
    end)
    normal_item_content:FindChild("Title"):GetComponent("Text").text = UIConst.Text.ITEM_INFO_TEXT
    self.normal_item = normal_item_content:FindChild("Item")
    self.item_name = normal_item_content:FindChild("ItemName")
    self.item_count = normal_item_content:FindChild("Count"):GetComponent("Text")
    self.item_desc = normal_item_content:FindChild("ItemDesc"):GetComponent("Text")

    -- equipment item
    self.equipment_panel = self.main_panel:FindChild("EquipmentPanel")
    local equipment_content = self.equipment_panel:FindChild("Content")
    equipment_content:FindChild("Top/Text"):GetComponent("Text").text = UIConst.Text.EQUIPMENT_TEXT
    self:AddClick(equipment_content:FindChild("Top/CloseBtn"), function ()
        self:CloseEquipmentItemInfoPanel()
    end)
    local tab_btn_list = equipment_content:FindChild("TabBtnList")
    self.equipment_fragment_btn = tab_btn_list:FindChild("FragmentBtn")
    self.equipment_fragment_btn:FindChild("Label"):GetComponent("Text").text = UIConst.Text.FRAGMENT
    self.equipment_fragment_btn:FindChild("Select/Text"):GetComponent("Text").text = UIConst.Text.FRAGMENT
    self:AddClick(self.equipment_fragment_btn, function ()
        self.equipment_slide_select_cmp:SlideToIndex(kPanelIndex.equipment_fragment)
    end)
    table.insert(self.equipment_tab_btn_list, self.equipment_fragment_btn)
    self.equipment_btn = tab_btn_list:FindChild("EquipBtn")
    self.equipment_btn:FindChild("Label"):GetComponent("Text").text = UIConst.Text.EQUIPMENT_TEXT
    self.equipment_btn:FindChild("Select/Text"):GetComponent("Text").text = UIConst.Text.EQUIPMENT_TEXT
    self:AddClick(self.equipment_btn, function ()
        self.equipment_slide_select_cmp:SlideToIndex(kPanelIndex.equipment)
    end)
    table.insert(self.equipment_tab_btn_list, self.equipment_btn)
    self.equipment_content = equipment_content:FindChild("InfoPanel/View/Content")
    self.equipment_slide_select_cmp = SlideSelectCmp.New()
    self.equipment_slide_select_cmp:DoInit(self, self.equipment_content)
    self.equipment_slide_select_cmp:SetDraggable(true)
    self.equipment_slide_select_cmp:ListenSelectUpdate(function (index)
        if self.cur_index ~= 0 then
            self.equipment_tab_btn_list[self.cur_index]:FindChild("Select"):SetActive(false)
        end
        self.cur_index = index + 1
        self.equipment_tab_btn_list[self.cur_index]:FindChild("Select"):SetActive(true)
    end)
        -- fragment
    self.equipment_fragment_panel = self.equipment_content:FindChild("FragmentPanel")
    local fragment_info_panel = self.equipment_fragment_panel:FindChild("InfoPanel")
    self.equipment_frag_item = fragment_info_panel:FindChild("Item")
    self.equipment_frag_name = fragment_info_panel:FindChild("ItemName")
    self.equipment_frag_count = fragment_info_panel:FindChild("Count")
    self.equipment_frag_count_text = self.equipment_frag_count:GetComponent("Text")
    self.equipment_frag_desc = fragment_info_panel:FindChild("ItemDesc"):GetComponent("Text")
    local equipment_access_panel = self.equipment_fragment_panel:FindChild("AccessPanel")
    equipment_access_panel:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.ACCESS_TEXT
    self.equipment_access_content = equipment_access_panel:FindChild("AccessList/View/Content")
    self.equip_access_content_rect_cmp = self.equipment_access_content:GetComponent("RectTransform")
        -- product
    self.product_panel = self.equipment_content:FindChild("ProductPanel")
    local img_panel = self.product_panel:FindChild("EquipPanel")
    self.equipment_img = img_panel:FindChild("EquipImg"):GetComponent("Image")
    self.equipment_name = img_panel:FindChild("Name/Text"):GetComponent("Text")
    -- 装备属性面板
    local equipment_info_content = self.product_panel:FindChild("InfoPanel/View/Content")
    self.equipment_content_rect_cmp = equipment_info_content:GetComponent("RectTransform")
    local equipment_base_attr_panel = equipment_info_content:FindChild("BaseAttrPanel")
    equipment_base_attr_panel:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.BASE_ATTR_TEXT
    self.equipment_base_attr_content = equipment_base_attr_panel:FindChild("Content")
    local equipment_strengthen_attr_panel = equipment_info_content:FindChild("StrengthenAttrPanel")
    equipment_strengthen_attr_panel:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.STRENGHTHEN_ATTR_TEXT
    self.equipment_strengthen_attr_content = equipment_strengthen_attr_panel:FindChild("Content")
    self.equipment_spell_panel = equipment_info_content:FindChild("SpellPanel")
    self.equipment_spell_panel:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.DETAIL_SPELL_TEXT
    self.equipment_spell_content = self.equipment_spell_panel:FindChild("SpellList")
    self.equipment_suit_panel = equipment_info_content:FindChild("SuitPanel")
    self.equipment_suit_panel:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.SUIT_TEXT
    local equipment_suit_content = self.equipment_suit_panel:FindChild("Content")
    self.suit_name = equipment_suit_content:FindChild("SuitName/Text"):GetComponent("Text")
    self.suit_equipment_panel = equipment_suit_content:FindChild("SuitEquipmentPanel/Content")
    self.suit_attr_panel = equipment_suit_content:FindChild("SuitAttrPanel")
    self.suit_spell_panel = equipment_suit_content:FindChild("SuitSpellPanel")
    equipment_info_content:FindChild("DescPanel/Title/Text"):GetComponent("Text").text = UIConst.Text.DESC_TEXT
    self.equipment_desc = equipment_info_content:FindChild("DescPanel/Content/Text"):GetComponent("Text")

    -- hero item
    self.hero_panel = self.main_panel:FindChild("HeroPanel")
    local hero_content = self.hero_panel:FindChild("Content")
    self:AddClick(hero_content:FindChild("Top/CloseBtn"), function ()
        self:CloseHeroItemInfoPanel()
    end)
    hero_content:FindChild("Top/Text"):GetComponent("Text").text = UIConst.Text.HERO_TEXT
    tab_btn_list = hero_content:FindChild("TabBtnList")
    self.hero_fragment_btn = tab_btn_list:FindChild("FragmentBtn")
    self.hero_fragment_btn:FindChild("Label"):GetComponent("Text").text = UIConst.Text.FRAGMENT
    self.hero_fragment_btn:FindChild("Select/Text"):GetComponent("Text").text = UIConst.Text.FRAGMENT
    self:AddClick(self.hero_fragment_btn, function ()
        self.hero_slide_select_cmp:SlideToIndex(kPanelIndex.hero_fragment)
    end)
    table.insert(self.hero_tab_btn_list, self.hero_fragment_btn)
    self.hero_btn = tab_btn_list:FindChild("HeroBtn")
    self.hero_btn:FindChild("Label"):GetComponent("Text").text = UIConst.Text.HERO_TEXT
    self.hero_btn:FindChild("Select/Text"):GetComponent("Text").text = UIConst.Text.HERO_TEXT
    self:AddClick(self.hero_btn, function ()
        self.hero_slide_select_cmp:SlideToIndex(kPanelIndex.hero)
    end)
    table.insert(self.hero_tab_btn_list, self.hero_btn)
    self.fate_btn = tab_btn_list:FindChild("FateBtn")
    self.fate_btn:FindChild("Label"):GetComponent("Text").text = UIConst.Text.FATE_TEXT
    self.fate_btn:FindChild("Select/Text"):GetComponent("Text").text = UIConst.Text.FATE_TEXT
    self:AddClick(self.fate_btn, function ()
        self.hero_slide_select_cmp:SlideToIndex(kPanelIndex.hero_fate)
    end)
    table.insert(self.hero_tab_btn_list, self.fate_btn)
    self.hero_content = hero_content:FindChild("InfoPanel/View/Content")
    self.hero_slide_select_cmp = SlideSelectCmp.New()
    self.hero_slide_select_cmp:DoInit(self, self.hero_content)
    self.hero_slide_select_cmp:SetDraggable(true)
    self.hero_slide_select_cmp:ListenSelectUpdate(function (index)
        self.hero_tab_btn_list[self.cur_index]:FindChild("Select"):SetActive(false)
        self.cur_index = index + 1
        self.hero_tab_btn_list[self.cur_index]:FindChild("Select"):SetActive(true)
    end)
        -- fragment
    self.hero_fragment_panel = self.hero_content:FindChild("FragmentPanel")
    fragment_info_panel = self.hero_fragment_panel:FindChild("InfoPanel")
    self.hero_frag_item = fragment_info_panel:FindChild("Item")
    self.hero_frag_name = fragment_info_panel:FindChild("ItemName")
    self.hero_frag_count = fragment_info_panel:FindChild("Count"):GetComponent("Text")
    self.hero_frag_desc = fragment_info_panel:FindChild("ItemDesc"):GetComponent("Text")
    self.hero_fragment_panel:FindChild("AccessPanel/Title/Text"):GetComponent("Text").text = UIConst.Text.ACCESS_TEXT
    self.hero_access_content = self.hero_fragment_panel:FindChild("AccessPanel/AccessList/View/Content")
    self.hero_access_content_rect_cmp = self.hero_access_content:GetComponent("RectTransform")
        -- hero info
    self.hero_info_panel = self.hero_content:FindChild("HeroInfoPanel")
    local hero_panel = self.hero_info_panel:FindChild("HeroPanel")
    self.hero_model = hero_panel:FindChild("HeroModel")
    self.hero_name = hero_panel:FindChild("Name/Text"):GetComponent("Text")
    self.hero_tag1 = hero_panel:FindChild("Tag1")
    self.hero_tag2 = hero_panel:FindChild("Tag2")
    self.hero_grade = hero_panel:FindChild("Grade"):GetComponent("Image")
    local power_panel = hero_panel:FindChild("PowerPanel")
    self.power_icon = power_panel:FindChild("Icon"):GetComponent("Image")
    self.power_text = power_panel:FindChild("Text"):GetComponent("Text")
    local hero_info_content = self.hero_info_panel:FindChild("InfoPanel/View/Content")
    self.hero_content_rect_cmp = hero_info_content:GetComponent("RectTransform")
    -- 基础属性
    hero_info_content:FindChild("BaseAttrPanel/Title/Text"):GetComponent("Text").text = UIConst.Text.BASE_ATTR_TEXT
    local attr_panel = hero_info_content:FindChild("BaseAttrPanel/AttrList")
    local score = attr_panel:FindChild("Score")
    score:FindChild("Text"):GetComponent("Text").text = UIConst.Text.TOTAL_SCORE_TEXT
    self.score = score:FindChild("Value"):GetComponent("Text")
    local atk = attr_panel:FindChild("Atk")
    atk:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ATK_TEXT
    self.atk = atk:FindChild("Value"):GetComponent("Text")
    local hp = attr_panel:FindChild("Hp")
    hp:FindChild("Text"):GetComponent("Text").text = UIConst.Text.HP_TEXT
    self.hp = hp:FindChild("Value"):GetComponent("Text")
    local def = attr_panel:FindChild("Def")
    def:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DEF_TEXT
    self.def = def:FindChild("Value"):GetComponent("Text")
    local business_attr = attr_panel:FindChild("Business")
    business_attr:FindChild("Text"):GetComponent("Text").text = UIConst.Text.BUSINESS_ATTR
    self.business_attr = business_attr:FindChild("Value"):GetComponent("Text")
    local management_attr = attr_panel:FindChild("Management")
    management_attr:FindChild("Text"):GetComponent("Text").text = UIConst.Text.MANAGEMENT_ATTR
    self.management_attr = management_attr:FindChild("Value"):GetComponent("Text")
    local fame_attr = attr_panel:FindChild("Renown")
    fame_attr:FindChild("Text"):GetComponent("Text").text = UIConst.Text.FAME_ATTR
    self.fame_attr = fame_attr:FindChild("Value"):GetComponent("Text")
    local battle_attr = attr_panel:FindChild("Fight")
    battle_attr:FindChild("Text"):GetComponent("Text").text = UIConst.Text.BATTLE_ATTR
    self.battle_attr = battle_attr:FindChild("Value"):GetComponent("Text")

    hero_info_content:FindChild("SpellPanel/Title/Text"):GetComponent("Text").text = UIConst.Text.DETAIL_SPELL_TEXT
    self.hero_skill_panel = hero_info_content:FindChild("SpellPanel/SpellList")
    hero_info_content:FindChild("FatePanel/Title/Text"):GetComponent("Text").text = UIConst.Text.FATE_TEXT
    self.hero_fate_text_panel = hero_info_content:FindChild("FatePanel/FateContent")
    hero_info_content:FindChild("TalentPanel/Title/Text"):GetComponent("Text").text = UIConst.Text.GIFT_TEXT
    self.hero_talent_panel = hero_info_content:FindChild("TalentPanel/TalentList")
    hero_info_content:FindChild("DescPanel/Title/Text"):GetComponent("Text").text = UIConst.Text.DESC_TEXT
    self.hero_desc = hero_info_content:FindChild("DescPanel/Content/Text"):GetComponent("Text")
        -- fate
    self.fate_info_panel = self.hero_content:FindChild("FateInfoPanel")
    local hero_fate_panel = self.fate_info_panel:FindChild("FatePreviewPanel")
    self.hero_fate_icon_bg = hero_fate_panel:FindChild("IconBg"):GetComponent("Image")
    self.hero_fate_icon = hero_fate_panel:FindChild("IconBg/Icon"):GetComponent("Image")
    self.hero_fate_name = hero_fate_panel:FindChild("Name"):GetComponent("Text")
    self.hero_all_fate_content = hero_fate_panel:FindChild("FateList")
    self.fate_info_panel:FindChild("FateDescPanel/Title/Text"):GetComponent("Text").text = UIConst.Text.FATE_TEXT
    self.hero_fate_item_panel = self.fate_info_panel:FindChild("FateDescPanel/View/Content")
    self.hero_fate_rect_cmp = self.hero_fate_item_panel:GetComponent("RectTransform")

    -- lover item
    self.lover_panel = self.main_panel:FindChild("LoverPanel")
    local lover_content = self.lover_panel:FindChild("Content")
    self:AddClick(lover_content:FindChild("Top/CloseBtn"), function ()
        self:CloseLoverItemInfoPanel()
    end)
    lover_content:FindChild("Top/Text"):GetComponent("Text").text = UIConst.Text.LOVER
    tab_btn_list = lover_content:FindChild("TabBtnList")
    self.lover_fragment_btn = tab_btn_list:FindChild("FragmentBtn")
    self.lover_fragment_btn:FindChild("Label"):GetComponent("Text").text = UIConst.Text.FRAGMENT
    self.lover_fragment_btn:FindChild("Select/Text"):GetComponent("Text").text = UIConst.Text.FRAGMENT
    self:AddClick(self.lover_fragment_btn, function ()
        self.lover_slide_select_cmp:SlideToIndex(kPanelIndex.lover_fragment)
    end)
    table.insert(self.lover_tab_btn_list, self.lover_fragment_btn)
    self.lover_btn = tab_btn_list:FindChild("LoverBtn")
    self.lover_btn:FindChild("Label"):GetComponent("Text").text = UIConst.Text.LOVER
    self.lover_btn:FindChild("Select/Text"):GetComponent("Text").text = UIConst.Text.LOVER
    self:AddClick(self.lover_btn, function ()
        self.lover_slide_select_cmp:SlideToIndex(kPanelIndex.lover)
    end)
    table.insert(self.lover_tab_btn_list, self.lover_btn)
    self.lover_content = lover_content:FindChild("InfoPanel/View/Content")
    self.lover_slide_select_cmp = SlideSelectCmp.New()
    self.lover_slide_select_cmp:DoInit(self, self.lover_content)
    self.lover_slide_select_cmp:SetDraggable(true)
    self.lover_slide_select_cmp:ListenSelectUpdate(function (index)
        self.lover_tab_btn_list[self.cur_index]:FindChild("Select"):SetActive(false)
        self.cur_index = index + 1
        self.lover_tab_btn_list[self.cur_index]:FindChild("Select"):SetActive(true)
    end)
    -- lover_fragment
    self.lover_fragment_panel = self.lover_content:FindChild("FragmentPanel")
    fragment_info_panel = self.lover_fragment_panel:FindChild("InfoPanel")
    self.lover_frag_item = fragment_info_panel:FindChild("Item")
    self.lover_frag_name = fragment_info_panel:FindChild("ItemName")
    self.lover_frag_count = fragment_info_panel:FindChild("Count"):GetComponent("Text")
    self.lover_frag_desc = fragment_info_panel:FindChild("ItemDesc"):GetComponent("Text")
    self.lover_fragment_panel:FindChild("AccessPanel/Title/Text"):GetComponent("Text").text = UIConst.Text.ACCESS_TEXT
    self.lover_access_content = self.lover_fragment_panel:FindChild("AccessPanel/AccessList/View/Content")
    self.lover_access_content_rect_cmp = self.lover_access_content:GetComponent("RectTransform")
    -- lover_info
    local lover_info_panel = self.lover_content:FindChild("LoverInfoPanel")
    local lover_panel = lover_info_panel:FindChild("LoverPanel")
    self.lover_model = lover_panel:FindChild("LoverModel")
    self.lover_name = lover_panel:FindChild("Name/Text"):GetComponent("Text")
    self.lover_grade = lover_panel:FindChild("Grade"):GetComponent("Image")
    self.lover_power_icon = lover_panel:FindChild("PowerPanel/Icon"):GetComponent("Image")
    self.lover_power_name = lover_panel:FindChild("PowerPanel/Text"):GetComponent("Text")
    local lover_info_content = lover_info_panel:FindChild("InfoPanel/View/Content")
    self.lover_info_rect_cmp = lover_info_content:GetComponent("RectTransform")
    local lover_power_panel = lover_info_content:FindChild("PowerPanel")
    lover_power_panel:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.FAMILY_HERO_TEXT
    self.lover_power_hero_list = lover_power_panel:FindChild("Content")
    local lover_desc_panel = lover_info_content:FindChild("DescPanel")
    lover_desc_panel:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.DESC_TEXT
    self.lover_desc = lover_desc_panel:FindChild("Content/Text"):GetComponent("Text")

    -- item pref
    local pref_list = self.main_panel:FindChild("PrefList")
    self.select_item = pref_list:FindChild("SelectItem")
    self.access_item = pref_list:FindChild("AccessItem")
    self.access_item:FindChild("AccessBtn/Text"):GetComponent("Text").text = UIConst.Text.ACCESS_BTN_TEXT
    self.fate_item = pref_list:FindChild("FateItem")
    self.fate_text_item = pref_list:FindChild("FateTextItem")
    self.text_item = pref_list:FindChild("TextItem")
    self.item_pref = pref_list:FindChild("ItemPref")
    self.suit_attr_item = pref_list:FindChild("SuitAttr")
    self.power_hero_item = pref_list:FindChild("PowerHeroItem")

    self.gift_preview_panel = self.main_panel:FindChild("GiftPreviewPanel")
    self.gift_preview_title = self.main_panel:FindChild("GiftPreviewPanel/GiftPreview/Title"):GetComponent("Text")
    self.gift_preview_close_btn = self.main_panel:FindChild("GiftPreviewPanel/GiftPreview/CloseBtn")
    self:AddClick(self.gift_preview_close_btn, function()
        self:HideGiftPreviewItemMes()
    end)
    self.gift_preview_content = self.main_panel:FindChild("GiftPreviewPanel/GiftPreview/RewardContent/View/Content")
    self.gift_preview_item = self.main_panel:FindChild("GiftPreviewPanel/GiftPreview/RewardContent/View/Content/Item")
end

function ItemInfoUI:InitUI()
    if not self.item_id then self:Hide() end
    table.insert(self.multi_info_item_id_list, self.item_id)
    self:ShowItemInfo()
end

function ItemInfoUI:ShowItemInfo()
    local item_data = SpecMgrs.data_mgr:GetItemData(self.multi_info_item_id_list[#self.multi_info_item_id_list])
    if item_data.sub_type == CSConst.ItemSubType.SelectPresent then
        self:ShowSelectItemInfoPanel(item_data)
    elseif item_data.sub_type == CSConst.ItemSubType.Equipment or item_data.sub_type == CSConst.ItemSubType.EquipmentFragment then
        if item_data.is_treasure and not item_data.part_index then -- 经验宝物
            self:ShowNormalItemInfoPanel(item_data)
        else
            self:ShowEquipmentItemInfoPanel(item_data)
        end
    elseif item_data.sub_type == CSConst.ItemSubType.HeroFragment or item_data.sub_type == CSConst.ItemSubType.Hero then
        self:ShowHeroItemInfoPanel(item_data)
    elseif item_data.sub_type == CSConst.ItemSubType.LoverFragment or item_data.sub_type == CSConst.ItemSubType.Lover then
        self:ShowLoverItemInfoPanel(item_data)
    elseif item_data.sub_type == CSConst.ItemSubType.Present then
        self:ShowGiftPreviewPanel(item_data)
    else
        self:ShowNormalItemInfoPanel(item_data)
    end
end

--  gift_preview
function ItemInfoUI:ShowGiftPreviewPanel(item_data)
    self:DelObjDict(self.gift_preview_obj_list)
    self.gift_preview_obj_list = {}
    self.gift_preview_panel:SetActive(true)
    local gift_item_list = ItemUtil.GetGiftPackageItemList(item_data.id)
    self.gift_preview_title.text = UIFuncs.GetItemName({item_id = item_data.id})
    for i, gift_item_data in ipairs(gift_item_list) do
        local item_obj = self:GetUIObject(self.gift_preview_item, self.gift_preview_content)
        self:SetGiftPreviewItemMes(item_obj, gift_item_data)
        table.insert(self.gift_preview_obj_list, item_obj)
    end
    --table.insert(self.multi_info_item_id_list, item_data.id)
end

function ItemInfoUI:SetGiftPreviewItemMes(obj, item_mes)
    local item_data = SpecMgrs.data_mgr:GetItemData(item_mes.item_id)
    local click_cb = function ()
        self.gift_preview_panel:SetActive(false)
        self:DelObjDict(self.gift_preview_obj_list)
        table.insert(self.multi_info_item_id_list, item_mes.item_id)
        self:ShowItemInfo()
    end
    local create_obj = self:SetItem(item_mes.item_id, nil, obj:FindChild("Item"), click_cb)
    obj:FindChild("NameText"):GetComponent("Text").text = item_data.name
    obj:FindChild("NumText"):GetComponent("Text").text = string.format(UIConst.Text.COUNT, item_mes.count)
    table.insert(self.gift_preview_obj_list, create_obj)
end

function ItemInfoUI:HideGiftPreviewItemMes(obj, item_mes)
    table.remove(self.multi_info_item_id_list, #self.multi_info_item_id_list)
    self.gift_preview_panel:SetActive(false)
    self:DelObjDict(self.gift_preview_obj_list)
    self:CheckLastInfo()
end
--  gift_preview

function ItemInfoUI:ShowSelectItemInfoPanel(item_data)
    self:ClearSelectItemGo()
    self.select_item_name.text = item_data.name
    for i, item_id in ipairs(item_data.item_list) do
        local select_item = self:GetUIObject(self.select_item, self.select_item_list)
        table.insert(self.select_item_go_dict, select_item)
        local item = select_item:FindChild("Item")
        UIFuncs.InitItemGo({
            go = item,
            item_id = item_id,
            count = item_data.item_count_list[i],
            change_name_color = true,
        })
        self:AddClick(item, function ()
            self.select_info_panel:SetActive(false)
            table.insert(self.multi_info_item_id_list, item_id)
            self:ShowItemInfo()
        end)
    end
    self.select_info_panel:SetActive(true)
end

function ItemInfoUI:ShowNormalItemInfoPanel(item_data)
    UIFuncs.InitItemGo({
        go = self.normal_item,
        item_data = item_data,
        name_go = self.item_name,
        change_name_color = true,
    })
    self.item_count.text = string.format(UIConst.Text.ITEM_COUNT, self.dy_bag_data:GetBagItemCount(item_data.id) or 0)
    self.item_desc.text = UIFuncs.GetItemDesc(item_data.id)
    self.normal_item_panel:SetActive(true)
end

function ItemInfoUI:ShowEquipmentItemInfoPanel(item_data)
    self:ClearEquipInfoItem()
    local cs_index = item_data.sub_type == CSConst.ItemSubType.Equipment and kPanelIndex.equipment or kPanelIndex.equipment_fragment
    self.equipment_slide_select_cmp:SetToIndex(cs_index)
    self.cur_index = cs_index + 1
    self.equipment_tab_btn_list[self.cur_index]:FindChild("Select"):SetActive(true)

    local fragment_id = item_data.is_treasure and item_data.fragment_list[1] or  item_data.fragment
    local fragment_data = item_data.sub_type == CSConst.ItemSubType.Equipment and SpecMgrs.data_mgr:GetItemData(fragment_id) or item_data
    local equipment_data = item_data.sub_type == CSConst.ItemSubType.Equipment and item_data or SpecMgrs.data_mgr:GetItemData(item_data.equipment)
    -- fragment
    UIFuncs.InitItemGo({
        go = self.equipment_frag_item,
        item_data = fragment_data,
        name_go = self.equipment_frag_name,
        change_name_color = true,
    })
    local bag_item = self.dy_bag_data:GetBagItemByItemId(fragment_data.id)
    self.equipment_frag_count:SetActive(equipment_data.is_treasure ~= true)
    if not equipment_data.is_treasure then
        self.equipment_frag_count_text.text = string.format(UIConst.Text.PER_VALUE, bag_item and bag_item.count or 0, fragment_data.synthesize_count)
    end
    self.equipment_frag_desc.text = UIFuncs.GetItemDesc(fragment_data.id)
    self.equipment_access_content:SetActive(fragment_data.access ~= nil)
    if fragment_data.access then
        for _, access in ipairs(fragment_data.access) do
            local access_data = SpecMgrs.data_mgr:GetItemAccessData(access)
            local access_go = self:GetUIObject(self.access_item, self.equipment_access_content)
            UIFuncs.AssignSpriteByIconID(access_data.icon, access_go:FindChild("Image/Icon"):GetComponent("Image"))
            access_go:FindChild("Name"):GetComponent("Text").text = access_data.name
            access_go:FindChild("Desc"):GetComponent("Text").text = access_data.desc
            local access_btn = access_go:FindChild("AccessBtn")
            access_btn:SetActive(access_data.access_target ~= nil)
            if access_data.access_target ~= nil then
                self:AddClick(access_btn, function ()
                    SpecMgrs.ui_mgr:JumpUI(access_data.access_target)
                end)
            end
            self.access_go_dict[access] = access_go
        end
    end
    self.equip_access_content_rect_cmp.anchoredPosition = Vector2.zero
    -- equipment info
    local equipment_quality_data = SpecMgrs.data_mgr:GetQualityData(equipment_data.quality)
    UIFuncs.AssignSpriteByIconID(equipment_data.icon, self.equipment_img)
    self.equipment_name.text = equipment_data.name
    -- 基础属性
    for index, attr in ipairs(equipment_data.base_attr_list) do
        local attr_data = SpecMgrs.data_mgr:GetAttributeData(attr)
        local go = self:GetUIObject(self.text_item, self.equipment_base_attr_content)
        local attr_value = attr_data.is_pct and string.format(UIConst.Text.PERCENT, equipment_data.base_attr_value[index]) or math.floor(equipment_data.base_attr_value[index])
        go:GetComponent("Text").text = string.format(UIConst.Text.KEY_VALUE, attr_data.name, attr_value)
        self.basic_attr_go_dict[attr] = go
    end
    -- 强化属性
    for index, attr in ipairs(equipment_data.base_attr_list) do
        local attr_data = SpecMgrs.data_mgr:GetAttributeData(attr)
        local go = self:GetUIObject(self.text_item, self.equipment_strengthen_attr_content)
        local attr_value = attr_data.is_pct and string.format(UIConst.Text.PERCENT, equipment_data.strengthen_attr_value[index]) or math.floor(equipment_data.strengthen_attr_value[index])
        go:GetComponent("Text").text = string.format(UIConst.Text.KEY_VALUE, attr_data.name, attr_value)
        self.strengthen_attr_go_dict[attr] = go
    end
    -- 技能
    local equip_spell_list = equipment_data.refine_spell_list
    self.equipment_spell_panel:SetActive(equip_spell_list ~= nil and #equip_spell_list > 0)
    if equip_spell_list and #equip_spell_list > 0 then
        for i, spell in ipairs(equip_spell_list) do
            local spell_data = SpecMgrs.data_mgr:GetRefineSpellData(spell)
            local spell_item = self:GetUIObject(self.text_item, self.equipment_spell_content)
            table.insert(self.spell_go_dict, spell_item)
            spell_item:GetComponent("Text").text = UIFuncs.GetEquipSpellDesc(spell, equipment_data.refine_level_list[i], true)
        end
    end
    -- 套装属性
    self.equipment_suit_panel:SetActive(equipment_data.suit ~= nil)
    if equipment_data.suit then
        local suit_data = SpecMgrs.data_mgr:GetSuitData(equipment_data.suit)
        self.suit_name.text = string.format(UIConst.Text.SIMPLE_COLOR, equipment_quality_data.color1, suit_data.name)
        -- 所有套装装备
        for _, equipment in ipairs(suit_data.suit_equipment) do
            local go = self:GetUIObject(self.item_pref, self.suit_equipment_panel)
            self.equipment_go_dict[equipment] = go
            UIFuncs.InitItemGo({
                item_id = equipment,
                go = go:FindChild("Item"),
                name_go = go:FindChild("Name"),
                change_name_color = true,
            })
        end
        -- 所有套装加成描述
        for i, count in ipairs(suit_data.equip_attr_count) do
            local go = self:GetUIObject(self.suit_attr_item, self.suit_attr_panel)
            go:FindChild("Title/Text"):GetComponent("Text").text = string.format(UIConst.Text.SUIT_EFFECT_FORMAT, equipment_quality_data.color1, count)
            go:FindChild("Effect/Text"):GetComponent("Text").text = suit_data.attr_desc[i]
            table.insert(self.suit_attr_go_dict, go)
        end
        -- 所有套装技能描述
        self.suit_spell_panel:SetActive(suit_data.spell_desc ~= nil and #suit_data.spell_desc > 0)
        if suit_data.spell_desc and #suit_data.spell_desc > 0 then
            for _, desc in ipairs(suit_data.spell_desc) do
                local go = self:GetUIObject(self.text_item, self.suit_spell_panel)
                go:GetComponent("Text").text = desc
                table.insert(self.suit_spell_go_dict, go)
            end
        end
    end
    self.equipment_desc.text = UIFuncs.GetItemDesc(equipment_data.id)
    self.equipment_content_rect_cmp.anchoredPosition = Vector2.zero
    self.equipment_panel:SetActive(true)
end

function ItemInfoUI:ShowHeroItemInfoPanel(item_data)
    self:ClearHeroInfoItem()
    local cs_index = item_data.sub_type == CSConst.ItemSubType.Hero and kPanelIndex.hero or kPanelIndex.hero_fragment
    self.hero_slide_select_cmp:SetToIndex(cs_index)
    self.cur_index = cs_index + 1
    self.hero_tab_btn_list[self.cur_index]:FindChild("Select"):SetActive(true)

    local fragment_data = item_data.sub_type == CSConst.ItemSubType.Hero and SpecMgrs.data_mgr:GetItemData(item_data.fragment) or item_data
    local hero_item_data = item_data.sub_type == CSConst.ItemSubType.Hero and item_data or SpecMgrs.data_mgr:GetItemData(item_data.hero)
    -- fragment
    UIFuncs.InitItemGo({
        item_data = fragment_data,
        go = self.hero_frag_item,
        name_go = self.hero_frag_name,
        change_name_color = true,
    })
    local bag_item = self.dy_bag_data:GetBagItemByItemId(fragment_data.id)
    self.hero_frag_count.text = string.format(UIConst.Text.PER_VALUE, bag_item and bag_item.count or 0, fragment_data.synthesize_count)
    self.hero_frag_desc.text = UIFuncs.GetItemDesc(fragment_data.id)
    for _, access in ipairs(fragment_data.access) do
        local access_data = SpecMgrs.data_mgr:GetItemAccessData(access)
        local access_go = self:GetUIObject(self.access_item, self.hero_access_content)
        UIFuncs.AssignSpriteByIconID(access_data.icon, access_go:FindChild("Image/Icon"):GetComponent("Image"))
        access_go:FindChild("Name"):GetComponent("Text").text = access_data.name
        access_go:FindChild("Desc"):GetComponent("Text").text = access_data.desc
        local access_btn = access_go:FindChild("AccessBtn")
        access_btn:SetActive(access_data.access_target ~= nil)
        if access_data.access_target ~= nil then
            self:AddClick(access_btn, function ()
                SpecMgrs.ui_mgr:JumpUI(access_data.access_target)
            end)
        end
        self.access_go_dict[access] = access_go
    end
    self.hero_access_content_rect_cmp.anchoredPosition = Vector2.zero
    -- hero info
    local hero_data = SpecMgrs.data_mgr:GetHeroData(hero_item_data.hero_id)
    local quality_data = SpecMgrs.data_mgr:GetQualityData(hero_data.quality)
    self.hero_unit = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = hero_data.unit_id, parent = self.hero_model})
    self.hero_unit:SetPositionByRectName({parent = self.hero_model, name = UnitConst.UnitRect.Half})
    self.hero_name.text = hero_data.name
    self.hero_tag1:SetActive(hero_data.tag[2] ~= nil)
    if hero_data.tag[2] then
        local tag_data = SpecMgrs.data_mgr:GetTagData(hero_data.tag[2])
        UIFuncs.AssignSpriteByIconID(tag_data.icon, self.hero_tag1:GetComponent("Image"))
    end
    self.hero_tag2:SetActive(hero_data.tag[3] ~= nil)
    if hero_data.tag[3] then
        local tag_data = SpecMgrs.data_mgr:GetTagData(hero_data.tag[3])
        UIFuncs.AssignSpriteByIconID(tag_data.icon, self.hero_tag2:GetComponent("Image"))
    end
    UIFuncs.AssignSpriteByIconID(quality_data.grade, self.hero_grade)
    local power_data = SpecMgrs.data_mgr:GetPowerData(hero_data.power)
    UIFuncs.AssignSpriteByIconID(power_data.icon, self.power_icon)
    self.power_text.text = power_data.name
    -- 基础属性
    local init_attr_dict = CSFunction.get_hero_init_attr_dict(hero_item_data.hero_id)
    self.score.text = CSFunction.eval_hero_score(init_attr_dict)
    self.atk.text = math.floor(init_attr_dict["att"] or 0)
    self.hp.text = math.floor(init_attr_dict["max_hp"] or 0)
    self.def.text = math.floor(init_attr_dict["def"] or 0)
    self.business_attr.text = math.floor(init_attr_dict["business"] or 0)
    self.management_attr.text = math.floor(init_attr_dict["management"] or 0)
    self.fame_attr.text = math.floor(init_attr_dict["renown"] or 0)
    self.battle_attr.text = math.floor(init_attr_dict["fight"] or 0)
    -- 技能
    for _, spell in ipairs(hero_data.spell) do
        local spell_data = SpecMgrs.data_mgr:GetSpellData(spell)
        if not spell_data.spell_unit then
            local go = self:GetUIObject(self.text_item, self.hero_skill_panel)
            go:GetComponent("Text").text = UIFuncs.GetHeroSpellDesc(hero_data.id, spell_data)
            self.skill_go_dict[spell] = go
        end
    end
    if hero_data.combo_spell then
        for _, spell in ipairs(hero_data.combo_spell) do
            local go = self:GetUIObject(self.text_item, self.hero_skill_panel)
            self.skill_go_dict[spell] = go
            local combo_spell_data = SpecMgrs.data_mgr:GetSpellData(spell)
            go:GetComponent("Text").text = UIFuncs.GetHeroSpellDesc(hero_data.id, combo_spell_data)
        end
    end
    -- 缘分
    if hero_data.fate then
        for _, fate in ipairs(hero_data.fate) do
            local go = self:GetUIObject(self.text_item, self.hero_fate_text_panel)
            go:GetComponent("Text").text = UIFuncs.GetFateDescStr(fate, true)
            self.fate_go_dict[fate] = go
        end
    end
    -- 天赋
    for break_lv, talent in ipairs(hero_data.talent) do
        local talent_data = SpecMgrs.data_mgr:GetTalentData(talent)
        local go = self:GetUIObject(self.text_item, self.hero_talent_panel)
        go:GetComponent("Text").text = UIFuncs.GetHeroTalentDescWithName(talent, break_lv, true)
        self.talent_go_dict[talent] = go
    end
    -- fate
    UIFuncs.AssignSpriteByIconID(quality_data.hero_bg, self.hero_fate_icon_bg)
    UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetUnitData(hero_data.unit_id).icon, self.hero_fate_icon)
    self.hero_fate_name.text = hero_data.name
    if hero_data.fate then
        for _, fate in ipairs(hero_data.fate) do
            local fate_data = SpecMgrs.data_mgr:GetFateData(fate)
            local go = self:GetUIObject(self.fate_text_item, self.hero_all_fate_content)
            go:FindChild("Text"):GetComponent("Text").text = fate_data.name
            self.fate_text_go_dict[fate] = go
            if fate_data.fate_hero then
                local fate_hero = SpecMgrs.data_mgr:GetHeroData(fate_data.fate_hero)
                local unit_data = SpecMgrs.data_mgr:GetUnitData(fate_hero.unit_id)
                local fate_quality_data = SpecMgrs.data_mgr:GetQualityData(fate_hero.quality)
                local fate_go = self:GetUIObject(self.fate_item, self.hero_fate_item_panel)
                self.fate_item_go_dict[fate_data.fate_hero] = fate_go
                UIFuncs.ChangeItemBgAndFarme(fate_hero.quality, fate_go:FindChild("IconBg"):GetComponent("Image"), fate_go:FindChild("IconBg/Frame"):GetComponent("Image"), false)
                UIFuncs.AssignSpriteByIconID(unit_data.icon, fate_go:FindChild("IconBg/Icon"):GetComponent("Image"))
                fate_go:FindChild("Name"):GetComponent("Text").text = fate_hero.name
                fate_go:FindChild("Desc"):GetComponent("Text").text = UIFuncs.GetFateDescStr(fate, true)
            elseif fate_data.fate_item then
                local fate_go = self:GetUIObject(self.fate_item, self.hero_fate_item_panel)
                self.fate_item_go_dict[fate_data.fate_item] = fate_go
                local fate_item_data = SpecMgrs.data_mgr:GetItemData(fate_data.fate_item)
                UIFuncs.ChangeItemBgAndFarme(fate_item_data.quality, fate_go:FindChild("IconBg"):GetComponent("Image"), fate_go:FindChild("IconBg/Frame"):GetComponent("Image"))
                UIFuncs.AssignSpriteByIconID(fate_item_data.icon, fate_go:FindChild("IconBg/Icon"):GetComponent("Image"))
                fate_go:FindChild("Name"):GetComponent("Text").text = fate_item_data.name
                fate_go:FindChild("Desc"):GetComponent("Text").text = UIFuncs.GetFateDescStr(fate, true)
            end
        end
        self.hero_fate_rect_cmp.anchoredPosition = Vector2.zero
    end
    self.hero_desc.text = hero_data.desc
    self.hero_content_rect_cmp.anchoredPosition = Vector2.zero
    self.hero_panel:SetActive(true)
end

function ItemInfoUI:ShowLoverItemInfoPanel(item_data)
    self:ClearLoverInfoItem()
    local cs_index = item_data.sub_type == CSConst.ItemSubType.Lover and kPanelIndex.lover or kPanelIndex.lover_fragment
    self.lover_slide_select_cmp:SetToIndex(cs_index)
    self.cur_index = cs_index + 1
    self.lover_tab_btn_list[self.cur_index]:FindChild("Select"):SetActive(true)

    local fragment_data = item_data.sub_type == CSConst.ItemSubType.Lover and SpecMgrs.data_mgr:GetItemData(item_data.fragment) or item_data
    local lover_item_data = item_data.sub_type == CSConst.ItemSubType.Lover and item_data or SpecMgrs.data_mgr:GetItemData(item_data.lover)
    -- fragment
    UIFuncs.InitItemGo({
        item_data = fragment_data,
        go = self.lover_frag_item,
        name_go = self.lover_frag_name,
        change_name_color = true,
    })
    local bag_item = self.dy_bag_data:GetBagItemByItemId(fragment_data.id)
    self.lover_frag_count.text = string.format(UIConst.Text.PER_VALUE, bag_item and bag_item.count or 0, fragment_data.synthesize_count)
    self.lover_frag_desc.text = UIFuncs.GetItemDesc(fragment_data.id)
    for _, access in ipairs(fragment_data.access) do
        local access_data = SpecMgrs.data_mgr:GetItemAccessData(access)
        local access_go = self:GetUIObject(self.access_item, self.lover_access_content)
        UIFuncs.AssignSpriteByIconID(access_data.icon, access_go:FindChild("Image/Icon"):GetComponent("Image"))
        access_go:FindChild("Name"):GetComponent("Text").text = access_data.name
        access_go:FindChild("Desc"):GetComponent("Text").text = access_data.desc
        local access_btn = access_go:FindChild("AccessBtn")
        access_btn:SetActive(access_data.access_target ~= nil)
        if access_data.access_target ~= nil then
            self:AddClick(access_btn, function ()
                SpecMgrs.ui_mgr:JumpUI(access_data.access_target)
            end)
        end
        self.access_go_dict[access] = access_go
    end
    self.lover_access_content_rect_cmp.anchoredPosition = Vector2.zero
    -- lover info
    local lover_data = SpecMgrs.data_mgr:GetLoverData(lover_item_data.lover_id)
    local quality_data = SpecMgrs.data_mgr:GetQualityData(lover_data.quality)
    self.lover_unit = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = lover_data.unit_id, parent = self.lover_model})
    self.lover_unit:SetPositionByRectName({parent = self.lover_model, name = UnitConst.UnitRect.Half})
    self.lover_name.text = lover_data.name
    UIFuncs.AssignSpriteByIconID(quality_data.grade, self.lover_grade)
    local power_data = SpecMgrs.data_mgr:GetPowerData(lover_data.power)
    UIFuncs.AssignSpriteByIconID(power_data.icon, self.lover_power_icon)
    self.lover_power_name.text = power_data.name

    for _, hero in ipairs(lover_data.hero) do
        local power_hero_item = self:GetUIObject(self.power_hero_item, self.lover_power_hero_list)
        table.insert(self.lover_power_hero_item_list, power_hero_item)
        UIFuncs.InitHeroGo({
            go = power_hero_item:FindChild("Item"),
            hero_id = hero,
        })
    end
    self.lover_desc.text = lover_data.introduce_text
    self.lover_info_rect_cmp.anchoredPosition = Vector2.zero
    self.lover_panel:SetActive(true)
end

function ItemInfoUI:CheckLastInfo()
    if #self.multi_info_item_id_list == 0 then
        self:Hide()
    else
        self:ShowItemInfo()
    end
end

function ItemInfoUI:CloseSelectItemInfoPanel()
    table.remove(self.multi_info_item_id_list, #self.multi_info_item_id_list)
    self:ClearSelectItemGo()
    self.select_info_panel:SetActive(false)
    self:CheckLastInfo()
end

function ItemInfoUI:ClearSelectItemGo()
    for _, go in pairs(self.select_item_go_dict) do
        self:DelUIObject(go)
    end
    self.select_item_go_dict = {}
end

function ItemInfoUI:CloseNormalItemInfoPanel()
    table.remove(self.multi_info_item_id_list, #self.multi_info_item_id_list)
    self.normal_item_panel:SetActive(false)
    self:CheckLastInfo()
end

function ItemInfoUI:CloseEquipmentItemInfoPanel()
    table.remove(self.multi_info_item_id_list, #self.multi_info_item_id_list)
    self.equipment_tab_btn_list[self.cur_index]:FindChild("Select"):SetActive(false)
    self:ClearEquipInfoItem()
    self.equipment_panel:SetActive(false)
    self:CheckLastInfo()
end

function ItemInfoUI:ClearEquipInfoItem()
    for _, go in pairs(self.access_go_dict) do
        self:DelUIObject(go)
    end
    self.access_go_dict = {}
    for _, go in pairs(self.basic_attr_go_dict) do
        self:DelUIObject(go)
    end
    self.basic_attr_go_dict = {}
    for _, go in pairs(self.strengthen_attr_go_dict) do
        self:DelUIObject(go)
    end
    self.strengthen_attr_go_dict = {}
    for _, go in pairs(self.spell_go_dict) do
        self:DelUIObject(go)
    end
    self.spell_go_dict = {}
    for _, go in pairs(self.equipment_go_dict) do
        self:DelUIObject(go)
    end
    self.equipment_go_dict = {}
    for _, go in ipairs(self.suit_attr_go_dict) do
        self:DelUIObject(go)
    end
    self.suit_attr_go_dict = {}
    for _, go in ipairs(self.suit_spell_go_dict) do
        self:DelUIObject(go)
    end
    self.suit_spell_go_dict = {}
end

function ItemInfoUI:CloseHeroItemInfoPanel()
    table.remove(self.multi_info_item_id_list, #self.multi_info_item_id_list)
    self:ClearHeroInfoItem()
    self.hero_tab_btn_list[self.cur_index]:FindChild("Select"):SetActive(false)
    self.hero_panel:SetActive(false)
    self:CheckLastInfo()
end

function ItemInfoUI:ClearHeroInfoItem()
    for _, go in pairs(self.access_go_dict) do
        self:DelUIObject(go)
    end
    self.access_go_dict = {}
    for _, go in pairs(self.skill_go_dict) do
        self:DelUIObject(go)
    end
    self.skill_go_dict = {}
    for _, go in pairs(self.fate_go_dict) do
        self:DelUIObject(go)
    end
    self.fate_go_dict = {}
    for _, go in pairs(self.talent_go_dict) do
        self:DelUIObject(go)
    end
    self.talent_go_dict = {}
    for _, go in pairs(self.fate_text_go_dict) do
        self:DelUIObject(go)
    end
    self.fate_text_go_dict = {}
    for _, go in pairs(self.fate_item_go_dict) do
        self:DelUIObject(go)
    end
    self.fate_item_go_dict = {}
    if self.hero_unit then
        ComMgrs.unit_mgr:DestroyUnit(self.hero_unit)
        self.hero_unit = nil
    end
end

function ItemInfoUI:CloseLoverItemInfoPanel()
    table.remove(self.multi_info_item_id_list, #self.multi_info_item_id_list)
    self:ClearLoverInfoItem()
    self.lover_tab_btn_list[self.cur_index]:FindChild("Select"):SetActive(false)
    self.lover_panel:SetActive(false)
    self:CheckLastInfo()
end

function ItemInfoUI:ClearLoverInfoItem()
    for _, go in pairs(self.access_go_dict) do
        self:DelUIObject(go)
    end
    self.access_go_dict = {}
    for _, go in pairs(self.lover_power_hero_item_list) do
        self:DelUIObject(go)
    end
    self.lover_power_hero_item_list = {}
    if self.lover_unit then
        ComMgrs.unit_mgr:DestroyUnit(self.lover_unit)
        self.lover_unit = nil
    end
end

function ItemInfoUI:CloseAll()
    local count = #self.multi_info_item_id_list
    for i = 1, count, -1 do
        local item_id = self.multi_info_item_id_list[i]
        local item_data = SpecMgrs.data_mgr:GetItemData(item_id)
        if item_data.item_list then
            self:CloseSelectItemInfoPanel()
        elseif item_data.sub_type == CSConst.ItemSubType.Equipment or item_data.sub_type == CSConst.ItemSubType.EquipmentFragment then
            self:CloseEquipmentItemInfoPanel()
        elseif item_data.sub_type == CSConst.ItemSubType.HeroFragment or item_data.sub_tyoe == CSConst.ItemSubType.Hero then
            self:CloseHeroItemInfoPanel()
        elseif item_data.sub_type == CSConst.ItemSubType.LoverFragment or item_data.sub_tyoe == CSConst.ItemSubType.Lover then
            self:CloseLoverItemInfoPanel()
        else
            self:CloseNormalItemInfoPanel()
        end
    end
end

return ItemInfoUI