local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local ChangeHeroUI = class("UI.ChangeHeroUI", UIBase)

local tag_list = {
    CSConst.HeroTag.All,
    CSConst.HeroTag.Business,
    CSConst.HeroTag.Management,
    CSConst.HeroTag.Fame,
    CSConst.HeroTag.Fighting,
}

local tag_str_list = {
    UIConst.Text.HERO_TAG_ALL,
    UIConst.Text.HERO_TAG_BUSINESS,
    UIConst.Text.HERO_TAG_MANAGEMENT,
    UIConst.Text.HERO_TAG_FAME,
    UIConst.Text.HERO_TAG_FIGHTING,
}

function ChangeHeroUI:DoInit()
    ChangeHeroUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ChangeHeroUI"
    self.nat_hero_data_dict = SpecMgrs.data_mgr:GetAllHeroData()
    self.dy_hero_data = ComMgrs.dy_data_mgr.night_club_data
    self.hero_tag_map = CSConst.HeroTag
    self.chp_hero_cache = {}
    self.chp_hero_comp_dict = {}
    self.chp_hero_item_dict = {}
    self.hero_filt_btn_comp_list = {} -- {filt_tag = {text = , selected_go= }}
    self.max_lineup = #(SpecMgrs.data_mgr:GetAllLineupUnlockData())
end

function ChangeHeroUI:OnGoLoadedOk(res_go)
    ChangeHeroUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function ChangeHeroUI:Show(param_tb)
    if param_tb.lineup_id then
        self.lineup_id = param_tb.lineup_id
        self.is_lineup = true
    elseif param_tb.aid_index then
        self.aid_index = param_tb.aid_index
        self.is_lineup = false
    end
    if self.is_res_ok then
        self:InitUI()
    end
    ChangeHeroUI.super.Show(self)
end

function ChangeHeroUI:InitRes()
    UIFuncs.GetInitTopBar(self, self.main_panel, "ChangeHeroUI")
    self:AddClick(self.main_panel:FindChild("TopBar/CloseBtn"), function ()
        SpecMgrs.ui_mgr:HideUI(self)
    end)

    local filt_btn_parent = self.main_panel:FindChild("FiltHeroBtnList")
    local filt_btn_temp = filt_btn_parent:FindChild("Item")
    filt_btn_temp:SetActive(false)
    local item
    for i, hero_tag in ipairs(tag_list) do
        item = self:GetUIObject(filt_btn_temp, filt_btn_parent)
        self:AddClick(item, function ()
            self:_ChangeFiltTag(hero_tag)
        end)
        self.hero_filt_btn_comp_list[hero_tag] = {}
        local select_go = item:FindChild("Selected")
        select_go:SetActive(false)
        self.hero_filt_btn_comp_list[hero_tag].selected_go = select_go
        select_go:FindChild("Text"):GetComponent("Text").text = tag_str_list[i]
        local btn_text = item:FindChild("Text"):GetComponent("Text")
        self.hero_filt_btn_comp_list[hero_tag].text = btn_text
        btn_text.text = tag_str_list[i]
    end
    self.chp_hero_item_parent = self.main_panel:FindChild("Scroll View/Viewport/Content")
    self.chp_hero_item_temp = self.chp_hero_item_parent:FindChild("Item")
    self.chp_hero_item_temp:SetActive(false)
    self.chp_hero_item_temp:FindChild("ChangeBtn/Text"):GetComponent("Text").text = UIConst.Text.PUT_ON_LINEUP
    self.chp_hero_item_temp:FindChild("RemoveBtn/Text"):GetComponent("Text").text = UIConst.Text.REMOVE_AID_HERO
    self.main_panel:FindChild("TopBar/CloseBtn/Title"):GetComponent("Text").text = UIConst.Text.LINEUP
end

function ChangeHeroUI:InitUI()
    self:_InitChangeHeroPanel()
    self:_UpdateChangeHeroPanelHeroChache()
    self:_ChangeFiltTag(self.hero_tag_map.All) -- 默认打开是全选
    self:_SortHeroList(self.hero_id_sort_list)
    self:_UpdateAllHeroItem()
end

function ChangeHeroUI:_UpdateChangeHeroPanelHeroChache()
    self.chp_hero_cache.active_combo_tb = {}
    for _, hero_id in ipairs(self.hero_id_sort_list) do
        self.chp_hero_cache.active_combo_tb[hero_id] = self:_GetActiveComboSpell(hero_id, self.lineup_id)
    end
    self.chp_hero_cache.active_fate = {}
    for _, hero_id in ipairs(self.hero_id_sort_list) do
        self.chp_hero_cache.active_fate[hero_id] = self:_GetActiveFateDict(hero_id)
    end
end

function ChangeHeroUI:Hide()
    self.lineup_id = nil
    self.is_lineup = nil
    self.aid_index = nil
    self.chp_hero_cache = {}
    ChangeHeroUI.super.Hide(self)
end

function ChangeHeroUI:_InitChangeHeroPanel()
    self:ClearGoDict("chp_hero_item_dict")
    self.hero_id_sort_list = {}
    local hero_data_list = self.dy_hero_data:GetHeroListSortedByScore()
    for i, serv_hero_data in ipairs(hero_data_list) do
        local hero_id = serv_hero_data.hero_id
        local nat_hero_data = self.nat_hero_data_dict[hero_id]
        local item = self:GetUIObject(self.chp_hero_item_temp, self.chp_hero_item_parent)
        item.name = "hero_" .. i
        self.chp_hero_comp_dict[hero_id] = {}
        local icon = item:FindChild("Left/Icon")
        UIFuncs.InitHeroGo({go = icon, hero_data = nat_hero_data})
        self.chp_hero_comp_dict[hero_id].name = item:FindChild("Left/Description/Name"):GetComponent("Text")
        self.chp_hero_comp_dict[hero_id].level = item:FindChild("Left/Description/Level"):GetComponent("Text")
        self.chp_hero_comp_dict[hero_id].combo = item:FindChild("Left/Description/Combo"):GetComponent("Text")
        self.chp_hero_comp_dict[hero_id].break_level = item:FindChild("Left/Icon/Break"):GetComponent("Text")
        self.chp_hero_comp_dict[hero_id].fade = item:FindChild("Left/Description/Fate"):GetComponent("Text")
        self.chp_hero_comp_dict[hero_id].remove = item:FindChild("RemoveBtn")
        self:AddClick(item:FindChild("ChangeBtn"), function ()
            self:_ChangeBtnCallBack(hero_id)
        end)
        self:AddClick(item:FindChild("RemoveBtn"), function ()
            SpecMgrs.msg_mgr:SendReinforcementsChange({pos_id = self.aid_index}, function (resp)
               if resp.errcode ~= 0 then
                   PrintError("Get wrong errcode from serv", self.aid_index)
               else
                   SpecMgrs.ui_mgr:HideUI(self)
               end
            end)
        end)
        self.chp_hero_item_dict[hero_id] = item
        table.insert(self.hero_id_sort_list, hero_id)
    end
end

function ChangeHeroUI:_ChangeBtnCallBack(hero_id)
    if self.is_lineup then
        SpecMgrs.msg_mgr:SendLineupChangeHero({hero_id = hero_id, lineup_id = self.lineup_id}, function (resp)
           if resp.errcode ~= 0 then
               PrintError("Get wrong errcode from serv", hero_id, self.lineup_id)
           else
               SpecMgrs.ui_mgr:HideUI(self)
           end
        end)
    else
        SpecMgrs.msg_mgr:SendReinforcementsChange({pos_id = self.aid_index, hero_id = hero_id}, function (resp)
           if resp.errcode ~= 0 then
               PrintError("Get wrong errcode from serv", hero_id, self.aid_index)
           else
               SpecMgrs.ui_mgr:HideUI(self)
           end
        end)
    end
end

function ChangeHeroUI:_UpdateHeroItem(hero_id)
    local hero_data = SpecMgrs.data_mgr:GetHeroData(hero_id)
    local serv_hero_data = self.dy_hero_data:GetHeroDataById(hero_id)
    local comp_list = self.chp_hero_comp_dict[hero_id]
    comp_list.remove:SetActive(self.dy_hero_data:CheckInAid(hero_id) ~= nil)

    comp_list.name.text = hero_data.name -- todo 有可能根据品阶加名字前缀
    comp_list.level.text = string.format(UIConst.Text.LEVEL, serv_hero_data.level)

    local combo_str = self:_GetHeroComboStr(hero_id)
    if combo_str then
        comp_list.combo.text = combo_str
        comp_list.combo.gameObject:SetActive(true)
    else
        comp_list.combo.gameObject:SetActive(false)
    end

    if serv_hero_data.break_lv and serv_hero_data.break_lv > 0 then -- 品阶
        comp_list.break_level.text = string.format(UIConst.Text.ADD_VALUE_FORMAL, serv_hero_data.break_lv)
        comp_list.break_level.gameObject:SetActive(true)
    else
        comp_list.break_level.gameObject:SetActive(false)
    end

    local fade_num = self:_GetHeroFadeNum(hero_id)
    if fade_num and fade_num > 0 then
        comp_list.fade.text = string.format(UIConst.Text.HERO_GROUP_COUNT, fade_num)
        comp_list.fade.gameObject:SetActive(true)
    else
        comp_list.fade.gameObject:SetActive(false)
    end
end

function ChangeHeroUI:_UpdateAllHeroItem()
    for hero_id, _ in pairs(self.chp_hero_item_dict) do
        self:_UpdateHeroItem(hero_id)
    end
end

function ChangeHeroUI:_GetHeroComboStr(hero_id)
    local combo_spell_tb = self.chp_hero_cache.active_combo_tb[hero_id] and self.chp_hero_cache.active_combo_tb[hero_id][1] -- 暂时认定只有一个合击技
    if combo_spell_tb then
        local combo_spell_data = SpecMgrs.data_mgr:GetSpellData(combo_spell_tb.combo_spell)
        local hero_data = SpecMgrs.data_mgr:GetHeroData(combo_spell_tb.combo_hero)
        return string.format(UIConst.Text.COMBO_WITH_HERO, hero_data.name)
    end
end
function ChangeHeroUI:_GetHeroFadeNum(hero_id)
    local active_fate_list = self.chp_hero_cache.active_fate[hero_id] -- 缘分
    if active_fate_list then
        return table.getCount(active_fate_list)
    end
end

function ChangeHeroUI:_GetActiveComboSpell(hero_id, except_lineup_index)
    if not self.is_lineup then return {} end -- 援军不激活合击技
    local hero_id_list = {}
    local lineup_to_hero = self.dy_hero_data:GetLineupToHero()

    for i = 1, self.max_lineup do
        if lineup_to_hero[i] and except_lineup_index and except_lineup_index ~= i then
            table.insert(hero_id_list, lineup_to_hero[i])
        end
    end
    return self.dy_hero_data:GetActiveComboSpell(hero_id, hero_id_list)
end

function ChangeHeroUI:_GetActiveFateDict(hero_id)
    local ret = nil
    if self.is_lineup then
        ret = self.dy_hero_data:GetHeroPreviewFate(hero_id, self.lineup_id)
    else
        ret = self.dy_hero_data:GetHeroAidFate(hero_id)
    end
    return ret
end

function ChangeHeroUI:_SortHeroList(hero_id_sort_list)
    local serv_data = self.dy_hero_data:GetAllHeroData()
    local nat_data = self.nat_hero_data_dict
    table.sort(hero_id_sort_list, function (hero_id1, hero_id2)
        local ret = self:_CompareComboSkill(hero_id1, hero_id2) -- 激活组合技
        if ret ~= nil then return ret end -- nil 即为相等 true 为交换 false 为不交换

        ret = self:_CompareFate(hero_id1,hero_id2) -- 激活缘分数量
        if ret ~= nil then return ret end

        local serv_data1 = serv_data[hero_id1]
        local serv_data2 = serv_data[hero_id2]
        ret = self:_CompareFields(serv_data1, serv_data2, "grade") -- 品阶
        if ret ~= nil then return ret end

        local nat_data1 = nat_data[hero_id1]
        local nat_data2 = nat_data[hero_id2]
        ret = self:_CompareFields(nat_data1, nat_data2, "quality") -- 品质
        if ret ~= nil then return ret end

        ret = self:_CompareFields(serv_data1, serv_data2, "level") -- 等级
        if ret ~= nil then return ret end

        ret = self:_CompareFields(nat_data1, nat_data2, "id")
        if ret ~= nil then return ret end

        return false -- 如果都相等就不交换了
    end)
    for index, hero_id in ipairs(self.hero_id_sort_list) do
        self.chp_hero_item_dict[hero_id]:SetSiblingIndex(index)
    end
    local aid_id = self.dy_hero_data:GetAidIndex(self.aid_index)
    if aid_id then self.chp_hero_item_dict[aid_id]:SetSiblingIndex(1) end
end

function ChangeHeroUI:_CompareComboSkill(hero_id1, hero_id2)
    local combo_spell1 = self.chp_hero_cache.active_combo_tb[hero_id1][1]
    local combo_spell2 = self.chp_hero_cache.active_combo_tb[hero_id2][1]
    if combo_spell1 and not combo_spell2 then
        return true
    elseif combo_spell2 and not combo_spell1 then
        return false
    else
        return nil
    end
end

function ChangeHeroUI:_CompareFate(hero_id1, hero_id2)
    local active_fate_list1 = self.chp_hero_cache.active_fate[hero_id1]
    local active_fate_list2 = self.chp_hero_cache.active_fate[hero_id2]
    local active_fate_count1 = active_fate_list1 and table.getCount(active_fate_list1) or 0
    local active_fate_count2 = active_fate_list2 and table.getCount(active_fate_list2) or 0
    if active_fate_count1 == active_fate_count2 then
        return nil
    else
        return active_fate_count1 > active_fate_count2
    end
end

function ChangeHeroUI:_CompareFields(hero_data1, hero_data2, fields)
    local val1 = hero_data1[fields]
    local val2 = hero_data2[fields]
    if val1 and val2 and type(val1) == "number" and type(val2) == "number" then -- 只有字段变量为数值才进行比较
        return val1 > val2
    elseif val1 and not val2 then -- 目前逻辑是字段为有优先于没有 true优先于false 比如英雄是否是黑金英雄
        return false
    elseif val2 and not val1 then
        return true
    else
        return nil
    end
end

function ChangeHeroUI:_ChangeFiltTag(filt_tag)
    if self.cur_selected_hero_tag then
        self.hero_filt_btn_comp_list[self.cur_selected_hero_tag].selected_go:SetActive(false)
    end
    self.cur_selected_hero_tag = filt_tag
    self.hero_filt_btn_comp_list[self.cur_selected_hero_tag].selected_go:SetActive(true)
    for hero_id, item in pairs(self.chp_hero_item_dict) do
        local is_show = self:_CheckHeroItemShow(hero_id, filt_tag)
        item:SetActive(is_show)
    end
end

function ChangeHeroUI:_CheckHeroItemShow(hero_id, filt_tag)
    if self.dy_hero_data:CheckHeroIsLineUp(SpecMgrs.data_mgr:GetHeroData(hero_id).unit_id) then return false end -- 默认隐藏已上阵英雄
    if filt_tag ~= self.hero_tag_map.All then
        local hero_data = self.nat_hero_data_dict[hero_id]
        for _, hero_tag in ipairs(hero_data.tag) do
            if hero_tag == filt_tag then
                if not self.is_lineup then
                    if hero_id == self.dy_hero_data:GetAidIndex(self.aid_index) then return true end -- 显示当前选中可能卸下援军
                end
                if self.dy_hero_data:CheckInAid(hero_id) then return false end -- 在隐藏已上阵援助英雄
                return true
            end
        end
    end
    if not self.is_lineup then
        if hero_id == self.dy_hero_data:GetAidIndex(self.aid_index) then return true end -- 显示当前选中可能卸下援军
    end
    if self.dy_hero_data:CheckInAid(hero_id) then return false end -- 在隐藏已上阵援助英雄
    if filt_tag == self.hero_tag_map.All then return true end
    return false
end

return ChangeHeroUI