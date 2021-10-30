local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local ItemUtil = require("BaseUtilities.ItemUtil")
local DyDataConst = require("DynamicData.DyDataConst")

local BagUI = class("UI.BagUI", UIBase)

function BagUI:DoInit()
    BagUI.super.DoInit(self)
    self.prefab_path = "UI/Common/BagUI"
    self.dy_bag_data = ComMgrs.dy_data_mgr.bag_data
    self.dy_hero_data = ComMgrs.dy_data_mgr.night_club_data
    self.dy_lover_data = ComMgrs.dy_data_mgr.lover_data
    self.item_max_use_count = SpecMgrs.data_mgr:GetParamData("recover_item_use_max_num").f_value
    self.parent_type_go_dict = {}
    self.sub_type_go_dict = {}
    self.item_go_dict = {}
    self.get_item_go_dict = {}
end

function BagUI:OnGoLoadedOk(res_go)
    BagUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function BagUI:Show(item_sub_type, priority_item_list)
    self.priority_item_list = priority_item_list
    if item_sub_type then
        local item_type_data = SpecMgrs.data_mgr:GetItemTypeData(item_sub_type)
        local bag_sort_data = SpecMgrs.data_mgr:GetBagSortTypeData(item_type_data.bag_type)

    end
    if self.is_res_ok then
        self:InitUI()
    end
    BagUI.super.Show(self)
end

function BagUI:Hide()
    self.cur_parent_type = nil
    self.cur_sub_type = nil
    self.priority_item_list = nil
    self.dy_bag_data:UnregisterUpdateBagItemEvent("BagUI")
    BagUI.super.Hide(self)
end

function BagUI:InitRes()
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "BagUI", function ()
        SpecMgrs.ui_mgr:HideUI(self)
    end)

    local catalog_panel = self.main_panel:FindChild("CatalogPanel")
    self.primary_catalog_content = catalog_panel:FindChild("PrimaryCatalog/Viewport/Content")
    self.primary_catalog_item = self.primary_catalog_content:FindChild("PrimaryCatalogItem")
    self.sub_catalog_content = catalog_panel:FindChild("SubCatalog/Viewport/Content")
    self.sub_catalog_item = self.sub_catalog_content:FindChild("SubCatalogItem")
    self.bag_item_content = self.main_panel:FindChild("BagItemPanel/Viewport/Content")
    self.bag_item_content_rect = self.bag_item_content:GetComponent("RectTransform")
    self.bag_item_pref = self.bag_item_content:FindChild("BagItemPref")
    self.bag_item_pref:FindChild("BtnPanel/UseBtn/Text"):GetComponent("Text").text = UIConst.Text.USE_TEXT
    self.bag_item_pref:FindChild("BtnPanel/SynthesizeBtn/Text"):GetComponent("Text").text = UIConst.Text.SYNTHESIZE_TEXT
    self.bag_item_pref:FindChild("BtnPanel/GotoBtn/Text"):GetComponent("Text").text = UIConst.Text.GOTO_TEXT
    self.empty_panel = self.main_panel:FindChild("EmptyPanel")
    self.empty_text = self.empty_panel:FindChild("Dialog/Text"):GetComponent("Text")
    -- normal item use panel
    self.normal_item_use_panel = self.main_panel:FindChild("NormalItemUsePanel")
    self:AddClick(self.normal_item_use_panel:FindChild("Mask"), function ()
        self.normal_item_use_panel:SetActive(false)
    end)
    self:AddClick(self.normal_item_use_panel:FindChild("TitlePanel/CloseBtn"), function ()
        self.normal_item_use_panel:SetActive(false)
    end)
    local normal_info_panel = self.normal_item_use_panel:FindChild("InfoPanel")
    self.normal_item_icon = normal_info_panel:FindChild("ItemIcon"):GetComponent("Image")
    self.normal_item_name = normal_info_panel:FindChild("ItemName"):GetComponent("Text")
    self.normal_item_count = normal_info_panel:FindChild("ItemCount"):GetComponent("Text")
    local normal_count_panel = normal_info_panel:FindChild("CountPanel")
    self.normal_cur_count = normal_count_panel:FindChild("CurCount/Text"):GetComponent("Text")
    self:AddClick(normal_count_panel:FindChild("Reduce"), function ()
        self:UpdateNormalUseCount(self.cur_use_count - 1)
    end)
    self:AddClick(normal_count_panel:FindChild("Add"), function ()
        self:UpdateNormalUseCount(self.cur_use_count + 1)
    end)
    self:AddClick(normal_count_panel:FindChild("ReduceTen"), function ()
        self:UpdateNormalUseCount(self.cur_use_count - 10)
    end)
    self:AddClick(normal_count_panel:FindChild("AddTen"), function ()
        self:UpdateNormalUseCount(self.cur_use_count + 10)
    end)
    self:AddClick(self.normal_item_use_panel:FindChild("CancelBtn"), function ()
        self.normal_item_use_panel:SetActive(true)
    end)
    self:AddClick(self.normal_item_use_panel:FindChild("SubmitBtn"), function ()
        self.normal_item_use_panel:SetActive(false)
        self:SendUseItem({item_guid = self.cur_use_item_guid, item_count = self.cur_use_count})
    end)
    -- item use result panel
    self.use_result_panel = self.main_panel:FindChild("UseResultPanel")
    self:AddClick(self.use_result_panel:FindChild("TitlePanel/CloseBtn"), function ()
        self.use_result_panel:SetActive(false)
    end)
    self:AddClick(self.use_result_panel:FindChild("SubmitBtn"), function ()
        self.use_result_panel:SetActive(false)
    end)
    self.item_panel = self.use_result_panel:FindChild("ItemPanel/Viewport/Content")
    self.item_pref = self.item_panel:FindChild("ItemPref")
end

function BagUI:InitUI()
    self:InitParentTypeCatalog()
    self.dy_bag_data:RegisterUpdateBagItemEvent("BagUI", self.RefreshBagItem, self)
end

function BagUI:InitParentTypeCatalog()
    self:ClearParentTypeGo()
    for index, parent_type in ipairs(SpecMgrs.data_mgr:GetParentTypeListInBag()) do
        local go = self:GetUIObject(self.primary_catalog_item, self.primary_catalog_content)
        go:FindChild("CatalogName"):GetComponent("Text").text = parent_type.name
        go:FindChild("Select/Text"):GetComponent("Text").text = parent_type.name
        self:AddClick(go, function ()
            self.parent_type_go_dict[self.cur_parent_type]:FindChild("Select"):SetActive(false)
            self.cur_parent_type = parent_type.id
            go:FindChild("Select"):SetActive(true)
            self.priority_item_list = nil
            self.cur_sub_type = nil
            self:InitSubTypeCatalog(parent_type.sub_type_list)
        end)
        if not self.cur_parent_type or self.cur_parent_type == parent_type.id then
            self.cur_parent_type = parent_type.id
            go:FindChild("Select"):SetActive(true)
            self:InitSubTypeCatalog(parent_type.sub_type_list)
        end
        self.parent_type_go_dict[parent_type.id] = go
    end
end

function BagUI:InitSubTypeCatalog(sub_type_list)
    self:ClearSubTypeGo()
    for index, sub_type in ipairs(sub_type_list) do
        local go = self:GetUIObject(self.sub_catalog_item, self.sub_catalog_content)
        local sort_type_data = SpecMgrs.data_mgr:GetBagSortTypeData(sub_type)
        go:FindChild("CatalogName"):GetComponent("Text").text = sort_type_data.name
        go:FindChild("Select/Text"):GetComponent("Text").text = sort_type_data.name
        self:AddClick(go, function ()
            self.sub_type_go_dict[self.cur_sub_type]:FindChild("Select"):SetActive(false)
            self.cur_sub_type = sub_type
            self.priority_item_list = nil
            go:FindChild("Select"):SetActive(true)
            self:UpdateBagItem()
        end)
        if not self.cur_sub_type or self.cur_sub_type == sub_type then
            self.cur_sub_type = sub_type
            go:FindChild("Select"):SetActive(true)
            self:UpdateBagItem()
        end
        self.sub_type_go_dict[sub_type] = go
    end
end

function BagUI:UpdateBagItem()
    self:ClearItemGo()
    local bag_item_list = self.dy_bag_data:GetBagItemListByBagType(self.cur_sub_type)
    local bag_item_count = #bag_item_list
    self.empty_panel:SetActive(bag_item_count == 0)
    if bag_item_count == 0 then
        self.empty_text.text = string.format(UIConst.Text.NO_TYPE_ITEM, SpecMgrs.data_mgr:GetBagSortTypeData(self.cur_sub_type).name)
    end
    for _, temp_bag_item in ipairs(bag_item_list) do
        local bag_item = self.dy_bag_data:GetBagItemDataByGuid(temp_bag_item.guid)
        local go = self:GetUIObject(self.bag_item_pref, self.bag_item_content)
        self.item_go_dict[bag_item.guid] = go
        UIFuncs.InitItemGo({
            ui = self,
            go = go:FindChild("Item"),
            item_data = bag_item.item_data,
            change_name_color = true,
        })
        local item_count = self.dy_bag_data:GetBagItemDataByGuid(bag_item.guid).count
        go:FindChild("Item/Count"):SetActive(item_count > 1)
        if item_count > 1 then
            go:FindChild("Item/Count/Text"):GetComponent("Text").text = item_count
        end
        go:FindChild("ItemDesc"):GetComponent("Text").text = UIFuncs.GetItemDesc(bag_item.item_id)

        local btn_panel = go:FindChild("BtnPanel")
        local show_btn_panel_flag = false
        local use_btn = btn_panel:FindChild("UseBtn")
        local item_type = bag_item.item_data.sub_type
        use_btn:SetActive(bag_item.item_data.item_type == CSConst.ItemType.Prop)
        if bag_item.item_data.item_type == CSConst.ItemType.Prop then
            self:AddClick(use_btn, function ()
                self.cur_use_item_guid = bag_item.guid
                local new_item = self.dy_bag_data:GetBagItemDataByGuid(self.cur_use_item_guid)
                if new_item.item_data.sub_type == CSConst.ItemSubType.SelectPresent then
                    SpecMgrs.ui_mgr:ShowChooseItemUseUI({
                        item_list = new_item.item_data.item_list,
                        item_count_list = new_item.item_data.item_count_list,
                        count = new_item.count,
                        confirm_cb = function (selection, count)
                            self:SendUseItem({item_guid = self.cur_use_item_guid, item_count = count, index = selection})
                        end,
                    })
                else
                    self:ShowNormalItemUsePanel(new_item)
                end
            end)
            show_btn_panel_flag = true
        end

        local go_to_btn = btn_panel:FindChild("GotoBtn")
        local item_type_data = SpecMgrs.data_mgr:GetItemTypeData(bag_item.item_data.sub_type)
        go_to_btn:SetActive(item_type_data.go_to_ui ~= nil)
        if item_type_data.go_to_ui then
            self:AddClick(go_to_btn, function ()
                SpecMgrs.ui_mgr:ShowUI(item_type_data.go_to_ui)
            end)
            show_btn_panel_flag = true
        end

        local is_fragment = bag_item.item_data.sub_type == CSConst.ItemSubType.EquipmentFragment
        is_fragment = is_fragment or bag_item.item_data.sub_type == CSConst.ItemSubType.HeroFragment
        is_fragment = is_fragment or bag_item.item_data.sub_type == CSConst.ItemSubType.LoverFragment
        local synthesize_btn = btn_panel:FindChild("SynthesizeBtn")
        synthesize_btn:SetActive(is_fragment and bag_item.count >= bag_item.item_data.synthesize_count)
        if is_fragment and bag_item.count >= bag_item.item_data.synthesize_count then
            self:AddClick(synthesize_btn, function ()
                local max_count = math.floor(bag_item.count/bag_item.item_data.synthesize_count)
                local confirm_cb = function (count)
                    self:SendComposeItem(bag_item.item_id, count)
                end
                local item_name = UIFuncs.GetItemName({item_id = bag_item.item_id})
                if bag_item.item_data.sub_type == CSConst.ItemSubType.EquipmentFragment then
                    local equip_data = SpecMgrs.data_mgr:GetItemData(bag_item.item_data.equipment)
                    if max_count == 1 then
                        SpecMgrs.ui_mgr:ShowItemUseRemindByTb({
                            item_id = bag_item.item_id,
                            need_count = bag_item.item_data.synthesize_count,
                            remind_tag = "SynthesizeEquip",
                            title = UIConst.Text.SYNTHESIZE_FRAGMENT,
                            desc = string.format(UIConst.Text.COMPOSE_DESC_FORMAT, item_name, bag_item.item_data.synthesize_count, max_count, equip_data.name),
                            confirm_cb = function ()
                                confirm_cb(1)
                            end,
                        })
                    else
                        local data = {
                            title = UIConst.Text.SYNTHESIZE_FRAGMENT,
                            get_content_func = function (select_count)
                                local cost_count = select_count * bag_item.item_data.synthesize_count
                                local desc_str = string.format(UIConst.Text.COMPOSE_DESC_FORMAT, item_name, cost_count, select_count, equip_data.name)
                                local item_dict = {}
                                item_dict[bag_item.item_id] = cost_count
                                return {desc_str = desc_str, item_dict = item_dict}
                            end,
                            max_select_num = max_count,
                            confirm_cb = confirm_cb,
                        }
                        SpecMgrs.ui_mgr:ShowSelectItemUseByTb(data)
                    end
                elseif bag_item.item_data.sub_type == CSConst.ItemSubType.HeroFragment then
                    local hero_id = SpecMgrs.data_mgr:GetItemData(bag_item.item_data.hero).hero_id
                    if self.dy_hero_data:GetHeroDataById(hero_id) then
                        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.HERO_REPEAT)
                    else
                        local hero_data = SpecMgrs.data_mgr:GetHeroData(hero_id)
                        SpecMgrs.ui_mgr:ShowItemUseRemindByTb({
                            item_id = bag_item.item_id,
                            need_count = bag_item.item_data.synthesize_count,
                            remind_tag = "SynthesizeHero",
                            title = UIConst.Text.SYNTHESIZE_FRAGMENT,
                            desc = string.format(UIConst.Text.COMPOSE_DESC_FORMAT, item_name, bag_item.item_data.synthesize_count, 1, hero_data.name),
                            confirm_cb = function ()
                                confirm_cb(1)
                            end,
                        })
                    end
                elseif bag_item.item_data.sub_type == CSConst.ItemSubType.LoverFragment then
                    local lover_id = SpecMgrs.data_mgr:GetItemData(bag_item.item_data.lover).lover_id
                    if self.dy_lover_data:GetLoverInfo(lover_id) then
                        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.LOVER_REPEAT)
                    else
                        local lover_data = SpecMgrs.data_mgr:GetLoverData(lover_id)
                        SpecMgrs.ui_mgr:ShowItemUseRemindByTb({
                            item_id = bag_item.item_id,
                            need_count = bag_item.item_data.synthesize_count,
                            remind_tag = "SynthesizeLover",
                            title = UIConst.Text.SYNTHESIZE_FRAGMENT,
                            desc = string.format(UIConst.Text.COMPOSE_DESC_FORMAT, item_name, bag_item.item_data.synthesize_count, 1, lover_data.name),
                            confirm_cb = function ()
                                confirm_cb(1)
                            end,
                        })
                    end
                end
            end)
            show_btn_panel_flag = true
        end
        btn_panel:SetActive(show_btn_panel_flag)
    end
    if self.priority_item_list then
        table.sort(self.priority_item_list, function (item1, item2)
            if item1.item_data.quality == item2.item_data.quality then
                return item2.item_id < item1.item_id
            end
            return item2.item_data.quality > item1.item_data.quality
        end)
        for _, priority_item in ipairs(self.priority_item_list) do
            local bag_go = self.item_go_dict[priority_item.guid]
            if bag_go then
                bag_go:SetSiblingIndex(0)
            end
        end
    end
    self.bag_item_content_rect.anchoredPosition = Vector2.zero
end

function BagUI:ShowNormalItemUsePanel(bag_item)
    if not bag_item then return end
    local recover_limit_count = self.item_max_use_count
    if bag_item.item_data.recover_item then
        local recover_item = SpecMgrs.data_mgr:GetItemData(bag_item.item_data.recover_item)
        local over_limit = ComMgrs.dy_data_mgr:ExGetCostItemOverLimit(recover_item.id)
        if over_limit then
            local loss_value = over_limit - ComMgrs.dy_data_mgr:ExGetCostValue(recover_item.id)
            recover_limit_count = math.min(recover_limit_count, math.floor(loss_value / bag_item.item_data.recover_count))
            if recover_limit_count <= 0 then
                SpecMgrs.ui_mgr:ShowTipMsg(string.format(UIConst.Text.COST_VALUE_RECOVER_OVER, recover_item.name))
                return
            end
        end
    end
    local data = {
        get_content_func = function (select_count)
            local ret_str = string.format(UIConst.Text.USE_ITEM_REMIND, select_count, bag_item.item_data.name)
            local item_dict = {}
            item_dict[bag_item.item_id] = select_count
            return {desc_str = ret_str, item_dict = item_dict}
        end,
        max_select_num = math.min(bag_item.count, recover_limit_count),
        default_select_num = 1,
        confirm_cb = function (select_count)
            self:SendUseItem({item_guid = bag_item.guid, item_count = select_count}, bag_item.item_data.recover_item and bag_item.item_data)
        end,
        title = UIConst.Text.ITEM_USE_TEXT,
    }
    SpecMgrs.ui_mgr:ShowSelectItemUseByTb(data)
end

function BagUI:ShowUseResultPanel(item_dict)
    if not item_dict then return end
    self:ClearGetItemGo()
    for item_id, count in pairs(item_dict) do
        local go = self:GetUIObject(self.item_pref, self.item_panel)
        local item_data = SpecMgrs.data_mgr:GetItemData(item_id)
        UIFuncs.AssignSpriteByIconID(item_data.icon, go:FindChild("Icon"):GetComponent("Image"))
        go:FindChild("Count"):GetComponent("Text").text = string.format(UIConst.Text.COUNT, count)
        go:FindChild("Name"):GetComponent("Text").text = item_data.name
        self.get_item_go_dict[item_id] = go
    end
    self.use_result_panel:SetActive(true)
end

function BagUI:UpdateNormalUseCount(count)
    self.cur_use_count = self.dy_bag_data:CheckItemCount(self.cur_use_item_guid, count)
    self.normal_cur_count.text = self.cur_use_count
end

function BagUI:RefreshBagItem(_, op, bag_item)
    local sub_type_data = SpecMgrs.data_mgr:GetItemTypeData(bag_item.item_data.sub_type)
    if sub_type_data.bag_type ~= self.cur_sub_type then return end
    if op == DyDataConst.BagItemOpType.Add then
        self:UpdateBagItem()
    elseif op == DyDataConst.BagItemOpType.Update then
        local bag_item_go = self.item_go_dict[bag_item.guid]
        bag_item_go:FindChild("Item/Count/Text"):GetComponent("Text").text = bag_item.count
        local is_fragment = bag_item.item_data.sub_type == CSConst.ItemSubType.EquipmentFragment
        is_fragment = is_fragment or bag_item.item_data.sub_type == CSConst.ItemSubType.HeroFragment
        is_fragment = is_fragment or bag_item.item_data.sub_type == CSConst.ItemSubType.LoverFragment
        if not is_fragment then return end
        local show_synthesize_flag = bag_item.count >= bag_item.item_data.synthesize_count
        bag_item_go:FindChild("BtnPanel"):SetActive(show_synthesize_flag)
        bag_item_go:FindChild("BtnPanel/SynthesizeBtn"):SetActive(show_synthesize_flag)
    elseif op == DyDataConst.BagItemOpType.Remove then
        self:DelUIObject(self.item_go_dict[bag_item.guid])
        self.item_go_dict[bag_item.guid] = nil
    end
end

--msg
function BagUI:SendUseItem(data, recover_item)
    SpecMgrs.msg_mgr:SendUseBagItem(data, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.ITEM_USE_FAILED)
        else
            if recover_item then
                local item_list = {}
                table.insert(item_list, {item_id = recover_item.recover_item, count = data.item_count * recover_item.recover_count})
                SpecMgrs.ui_mgr:ShowCostItemRecoverUI(item_list)
            end
            if resp.item_dict then
                local item_list = {}
                for item_id, count in pairs(resp.item_dict) do
                    table.insert(item_list, {item_id = item_id, item_data = SpecMgrs.data_mgr:GetItemData(item_id), count = count})
                end
                ItemUtil.SortItem(item_list)
                SpecMgrs.ui_mgr:ShowUI("GetItemUI", item_list)
            end
        end
    end)
end

function BagUI:SendComposeItem(item_id, count)
    SpecMgrs.msg_mgr:SendComposeItem({item_id = item_id, compose_count = count}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.COMPOSE_FAILED)
        else
            local item_data = SpecMgrs.data_mgr:GetItemData(item_id)
            SpecMgrs.ui_mgr:ShowItemPreviewUI(item_data.equipment or item_data.hero or item_data.lover)
            self:UpdateBagItem()
        end
    end)
end

-- clear
function BagUI:ClearParentTypeGo()
    for _, go in pairs(self.parent_type_go_dict) do
        go:FindChild("Select"):SetActive(false)
        self:DelUIObject(go)
    end
    self.parent_type_go_dict = {}
end

function BagUI:ClearSubTypeGo()
    for _, go in pairs(self.sub_type_go_dict) do
        go:FindChild("Select"):SetActive(false)
        self:DelUIObject(go)
    end
    self.sub_type_go_dict = {}
end

function BagUI:ClearItemGo()
    for _, go in pairs(self.item_go_dict) do
        self:DelUIObject(go)
    end
    self.item_go_dict = {}
end

function BagUI:ClearGetItemGo()
    for _, go in pairs(self.get_item_go_dict) do
        self:DelUIObject(go)
    end
    self.get_item_go_dict = {}
end

return BagUI