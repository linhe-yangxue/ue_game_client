local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local LineupUI = class("UI.LineupUI",UIBase)
local UIFuncs = require("UI.UIFuncs")
local UnitConst = require("Unit.UnitConst")
local CSFunction = require("CSCommon.CSFunction")
LineupUI.need_sync_load = true

local attr_map = {
    max_hp = "max_hp",
    level = "level",
    def = "def",
    att = "att",
    score = "score",
}

local kSliderToNextFactor = 0.1 -- 滑动英雄超过屏幕的0.1就滑向下一个英雄
local kDefaultSelectSeatIndex = 1
local kFateNum = 6 -- 显示缘分数
local kAidItemIndex = 7 -- 援军的索引值
local kSliderTime = 0.2

local kEquipLimit = 4 -- 强化大师限制必须穿戴4件基础装备
local kOffset = 10
local kDefaultBgID = 160012 -- 英雄默认灰底图片
local default_vector2 = Vector2.New(1, 1)
local kTopHeroAnimTime = 0.2

local kHero = 1
local kAid = 2
local lineup_type_map = {
    hero = kHero,
    aid = kAid,
}
local func_map = {
    top_init = {
        [kHero] = "_InitTopHeroItem",
        [kAid] = "_InitTopAidItem",
    },
    top_update = {
        [kHero] = "_UpdateTopHeroItem",
        [kAid] = "_UpdateTopAidItem",
    },
    mid_update = {
        [kHero] = "_UpdateMidHeroItem",
        [kAid] = "_UpdateMidAidItem",
    },
    mid_init = {
        [kAid] = "_InitMidAidItem",
    }
}

function LineupUI:DoInit()
    LineupUI.super.DoInit(self)
    self.prefab_path = "UI/Common/LineupUI"
    self.dy_hero_data = ComMgrs.dy_data_mgr.night_club_data
    self.unlock_seat_data = SpecMgrs.data_mgr:GetAllLineupUnlockData()
    self.max_hero_lineup_num = #self.unlock_seat_data.type_to_id_list[kHero]
    self.nat_hero_data_dict = SpecMgrs.data_mgr:GetAllHeroData()
    self.equip_go_dict = {} -- {["head"] = go }
    self.attr_text_dict = {} --{["hp"] = textComp}
    self.fate_go_list = {} -- 缘分
    self.star_go_list = {}
    self.slider_x_offset = 0
    -- 需要清理的 go
    self.seat_to_model = {} -- 模型
    self.seat_to_top_icon = {}
    self.mid_go_list = {}
    self.hero_redpoint_dict = {} --存放头目红点引用
    self.replace_equip_redpoint_dict = {} --存放替换装备的红点引用
    self.redpoint_control_id_list = {} --头目红点所监听的多个红点控制ID
    for _, control_id in pairs(CSConst.RedPointControlIdDict.NightClub) do
        table.insert(self.redpoint_control_id_list, control_id)
    end
end

function LineupUI:OnGoLoadedOk(res_go)
    LineupUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function LineupUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    LineupUI.super.Show(self)
end

function LineupUI:InitRes()
    local panel_list = self.main_panel:FindChild("PanelList")
    self.initial_panel = panel_list:FindChild("InitialPanel")
    local top_bar = self.initial_panel:FindChild("TopBar")
    UIFuncs.InitTopBar(self, top_bar, "LineupUI")
    self.ip_hero_part = self.initial_panel:FindChild("HeroPart")
    self:_InitTopHreoPartRes()
    self:_InitMiddleHeroPartRes()
    self:_InitEquipPartRes(self.ip_hero_part:FindChild("EquipList"))
    self:_InitHeroNameRes(self.ip_hero_part:FindChild("Description/HeroName"))
    self:_InitAttrRes()

    self.tip_go = self.ip_hero_part:FindChild("Tips")
    self.tip_go:FindChild("Text"):GetComponent("Text").text = UIConst.Text.PLEASE_PUT_ON_HERO_TEXT
    self.intensify_btn = self.ip_hero_part:FindChild("Description/RightBtnList/IntensifyBtn")
    self.intensify_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.STRENGTHEN_MASTER
    self:AddClick(self.intensify_btn, function ()
        self:ShowIntensifyPanel()
    end)
    self.ip_hero_part:FindChild("Description/RightBtnList/ChangeHeroBtn/Text"):GetComponent("Text").text = UIConst.Text.REPLACE_TEXT
    self:AddClick(self.ip_hero_part:FindChild("Description/RightBtnList/ChangeHeroBtn"), function ()
        SpecMgrs.ui_mgr:ShowUI("ChangeHeroUI", {lineup_id = self.cur_seat_index})
    end)

    self.bottom_panel = self.ip_hero_part:FindChild("Bottom")
    self.bottom_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DETAIL
    self:AddClick(self.bottom_panel, function ()
        local seat_data = self.dy_hero_data:GetLineupData(self.cur_seat_index)
        if not seat_data or not seat_data.hero_id then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.PLEASE_PUT_ON_HERO_TEXT)
            return
        end
        self:ShowHeroDetailInfo()
    end)

    self.destiny_info_panel = panel_list:FindChild("DestinyInfoPanel")
    local close_btn = self.destiny_info_panel:FindChild("Content/Top/CloseBtn")
    self:AddClick(close_btn, function ()
        self:HideDestinyInfo()
    end)
end

function LineupUI:_InitTopHreoPartRes()
    -- 顶部条
    self.top_hero_scroll_rect = self.initial_panel:FindChild("Top/Hero/Scroll View"):GetComponent("ScrollRect")
    self:AddClick(self.initial_panel:FindChild("Top/LeftBtn"), function ()
        self:SliderToIndex(kDefaultSelectSeatIndex, false) -- 移动到最左边
        self.top_hero_scroll_rect.horizontalNormalizedPosition = 0
    end)
    self:AddClick(self.initial_panel:FindChild("Top/RightBtn"), function ()
        self:SliderToIndex(#self.unlock_lineup_list, false)-- todo 如果这一排不止英雄就要改一下 移动到最右边
        self.top_hero_scroll_rect.horizontalNormalizedPosition = 1
    end)
    self.initial_panel:FindChild("Top/SmallLineupBtn/Text"):GetComponent("Text").text = UIConst.Text.LINE_UP_TEXT
    self:AddClick(self.initial_panel:FindChild("Top/SmallLineupBtn"), function ()
        SpecMgrs.ui_mgr:ShowUI("SmallLineupUI")
    end)
    self.top_hero_item_parent = self.initial_panel:FindChild("Top/Hero/Scroll View/Viewport/Content")
    self.top_lineup_type_to_temp = {}
    for k,v in pairs(lineup_type_map) do
        local go = self.top_hero_item_parent:FindChild(k)
        go:SetActive(false)
        go:FindChild("Unlock/Text/Text"):GetComponent("Text").text = UIConst.Text.LEVEL_UNLOCK
        self.top_lineup_type_to_temp[v] = go
    end
end

function LineupUI:_InitMiddleHeroPartRes()
    self.middle_hero_scroll_rect = self.initial_panel:FindChild("Middle/Scroll View"):GetComponent("ScrollRect")
    self.middle_hero_item_parent = self.initial_panel:FindChild("Middle/Scroll View/Viewport/Content")
    self.mid_view_rect = self.initial_panel:FindChild("Middle/Scroll View/Viewport"):GetComponent("RectTransform")
    self.mid_content_rect = self.middle_hero_item_parent:GetComponent("RectTransform")
    local rect = self.mid_view_rect.rect
    self.middle_lineup_type_to_temp = {}
    for k,v in pairs(lineup_type_map) do
        local go = self.middle_hero_item_parent:FindChild(k)
        go:SetActive(false)
        self.middle_lineup_type_to_temp[v] = go
        go:GetComponent("RectTransform").sizeDelta = Vector2.New(rect.width, rect.height)
    end
    self:_InitAidTemp(self.middle_lineup_type_to_temp[kAid])
end

function LineupUI:_InitAidTemp(aid_temp)
    local lineup_info_panel = aid_temp:FindChild("LineupInfo")
    lineup_info_panel:FindChild("Title"):GetComponent("Text").text = UIConst.Text.AID_TITLE
    local lineup_part = lineup_info_panel:FindChild("LineupPart")
    local seat_temp = lineup_part:FindChild("Item")
    seat_temp:SetActive(false)
    for seat_index = 1, self.max_hero_lineup_num do
        local go = self:GetUIObject(seat_temp, lineup_part)
        go.name = seat_index
    end
    local aid_part = lineup_info_panel:FindChild("AidPart")
    local hero_temp = aid_part:FindChild("Item")
    hero_temp:SetActive(false)
    for i, v in ipairs(SpecMgrs.data_mgr:GetAllDeinforcementsData()) do
        local go = self:GetUIObject(hero_temp, aid_part)
        go.name = i
        self:AddClick(go, function ()
            self:AidItenOnClick(i)
        end)
    end
end

function LineupUI:_InitEquipPartRes(equip_parent)
    local equip_data_list = SpecMgrs.data_mgr:GetAllEquipPartData()
    for i, equip_data in ipairs(equip_data_list) do
        local go = equip_parent:FindChild(i)
        self.equip_go_dict[i] = go
        go:FindChild("Default/Unlock"):GetComponent("Text").text = equip_data.unlock_level
        self:AddClick(go:FindChild("Btn"), function ()
            self:EquipOnClick(i)
        end)
    end
end

function LineupUI:_InitHeroNameRes(go)
    self.cur_hero_name_go = go
    self.cur_hero_name_text = self.cur_hero_name_go:FindChild("Text"):GetComponent("Text")
    self.cur_hero_name_go:SetActive(false)
    self.cur_hero_grade_img = self.cur_hero_name_go:FindChild("Grade"):GetComponent("Image")
    local star_num = SpecMgrs.data_mgr:GetParamData("hero_star_lv_limit").f_value
    local star_parent = go:FindChild("Stars")
    local star_temp = star_parent:FindChild("Temp")
    star_temp:SetActive(false)
    for i = 1, star_num do
        local go = self:GetUIObject(star_temp, star_parent)
        table.insert(self.star_go_list, go)
    end
end

function LineupUI:_InitAttrRes()
    local attr_go = self.ip_hero_part:FindChild("Description/Bg/BlackBg/Attr")
    self.ip_hero_part:FindChild("Description/Top/Detial"):GetComponent("Text").text = UIConst.Text.ATTR_TEXT
    self.attr_content_go = attr_go:FindChild("Content")
    for k, v in pairs(attr_map) do
        self.attr_text_dict[k] = self.attr_content_go:FindChild(v):GetComponent("Text")
    end
    local fate_go = self.ip_hero_part:FindChild("Description/Bg/BlackBg/Fate")
    self.ip_hero_part:FindChild("Description/Top/Fade"):GetComponent("Text").text = UIConst.Text.FATE_TEXT
    self.fate_content_go = fate_go:FindChild("Content")
    for i = 1, kFateNum do
        table.insert(self.fate_go_list, self.fate_content_go:FindChild(i))
    end
end

function LineupUI:InitUI()
    self:_InitInitialPanel()
    self:_UpdateInitialPanel()
    self:UpdateBtn()
    self:RegisterEvent(self.dy_hero_data, "UpdateLineupEquipInfoEvent", function ()
        self:_UpdateEquipPart()
        self:_UpdateAttrPart(self.cur_seat_index)
    end)
    self:RegisterEvent(self.dy_hero_data, "UpdateLineupEvent", function (_, msg)
        self:_UpdateInitialPanel()
        self:_UpdateSelectedHero()
    end)
    self:RegisterEvent(self.dy_hero_data, "UpdateHeroEvent", function ()
        self:_UpdateInitialPanel()
        self:_UpdateSelectedHero()
    end)
    self:RegisterEvent(ComMgrs.dy_data_mgr.bag_data, "UpdateBagItemEvent", function ()
        self:_UpdateSelectedHero()
    end)
    self:RegisterEvent(self.dy_hero_data, "UpdateAidEvent", function ()
        self:_UpdateInitialPanel()
    end)
    self.middle_hero_scroll_rect.horizontalNormalizedPosition = 0
end

function LineupUI:UpdateBtn()
    local open_level = SpecMgrs.data_mgr:GetParamData("open_strenghthen_master_level").f_value
    local role_level = ComMgrs.dy_data_mgr:ExGetRoleLevel()
    self.intensify_btn:SetActive(role_level >= open_level)
end

function LineupUI:_UpdateInitialPanel()
    for i, v in ipairs(self.init_lineup_list) do
        self:_UpdateTopItem(i)
    end
    for i, v in ipairs(self.unlock_lineup_list) do
        self:_UpdateMidItem(i)
    end
end

function LineupUI:_UpdateTopItem(index)
    local data = self:_GetLineupUnlockData(index)
    local func_name = func_map.top_update[data.type]
    local item = self.seat_to_top_icon[index]
    self[func_name](self, item, index)
end

function LineupUI:_UpdateMidItem(index)
    local data = self:_GetLineupUnlockData(index)
    local func_name = func_map.mid_update[data.type]
    local item = self.mid_go_list[index]
    self[func_name](self, item, index)
end

function LineupUI:_UpdateMidHeroItem(go, index)
    local lineup_id = self.unlock_lineup_list[index]
    local go = self.mid_go_list[lineup_id]
    local hero_id = self.dy_hero_data:GetLineupHeroId(lineup_id)
    self:_AddHeroUnit(index, hero_id)
end

function LineupUI:_ClearHeroUnit(index)
    if self.seat_to_model[index] then
        self:RemoveUnit(self.seat_to_model[index])
        self.seat_to_model[index] = nil
    end
end

function LineupUI:_AddHeroUnit(index, hero_id)
    local go = self.mid_go_list[index]
    self:_ClearHeroUnit(index)
    if hero_id then
        local unit_id  = SpecMgrs.data_mgr:GetHeroData(hero_id).unit_id
        self.seat_to_model[index] = self:AddFullUnit(unit_id, go:FindChild("UnitParent"))
    end
    go:FindChild("NoHero"):SetActive(not hero_id and true or false)
end

function LineupUI:_UpdateMidAidItem(go)
    self:_UpdateMidAidItemAidPart(go:FindChild("LineupInfo/AidPart"))
    self:_UpdateMidAidItemLineupPart(go:FindChild("LineupInfo"))
end

function LineupUI:_UpdateMidAidItemAidPart(go)
    local aid_unlock_num = self.dy_hero_data:GetAidUnlockNum()
    local aid_dict = self.dy_hero_data:GetAidDict()
    local aid_lock_data = SpecMgrs.data_mgr:GetAllDeinforcementsData()
    for i, v in ipairs(aid_lock_data) do
        local hero_id = aid_dict[i]
        local is_show_hero = hero_id and true or false
        local is_unlock = aid_unlock_num >= i
        local item = go:FindChild(i)
        item:FindChild("Icon"):SetActive(is_show_hero)
        item:FindChild("Unlock"):SetActive(not is_unlock)
        item:FindChild("AddHero"):SetActive(false) -- 重置动画时间
        item:FindChild("AddHero"):SetActive(is_unlock and not is_show_hero)
        item:FindChild("Grade"):SetActive(is_show_hero)
        item:FindChild("Name"):SetActive(is_show_hero)
        if is_show_hero then
            UIFuncs.InitHeroGo({go = item, hero_id = aid_dict[i]})
        else
            UIFuncs.AssignSpriteByIconID(kDefaultBgID, item:GetComponent("Image"))
        end
        self:RemoveClick(item)
        if not is_unlock then
            item:FindChild("Unlock/Text"):GetComponent("Text").text = aid_lock_data[i].unlock_level
        else
            self:AddClick(item, function ()
                self:AidItemOnClick(i)
            end)
        end
    end
end

function LineupUI:AidItemOnClick(index)
    if self.dy_hero_data:CheckAidUnlock(index) then
        if self.dy_hero_data:IsAllLineup() then
            SpecMgrs.ui_mgr:ShowUI("ChangeHeroUI", {aid_index = index})
        else
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.NOT_ALL_LINEUP)
        end
    end
end

function LineupUI:_UpdateMidAidItemLineupPart(go)
    local lineup_data = self.dy_hero_data:GetAllLineupData()
    local total_fate = 0
    local lineup_part = go:FindChild("LineupPart")
    local pos_to_hero = {}
    for k,v in pairs(lineup_data) do
        if v.pos_id and v.hero_id then
            pos_to_hero[v.pos_id] = v.hero_id
        end
    end
    for i = 1, self.max_hero_lineup_num  do
        local item = lineup_part:FindChild(i .. "/Seat/Item")
        local hero_id = pos_to_hero[i]
        item:SetActive(hero_id and true or false)
        if hero_id then
            UIFuncs.InitHeroGo({go = item, hero_id = hero_id})
            local lineup_id = self.dy_hero_data:GetHeroLineupId(hero_id)
            local sort_fate_list, active_fate_dict, active_fate_num = self.dy_hero_data:GetSortedFateList(lineup_id)
            item:FindChild("Destiny"):GetComponent("Text").text = string.format(UIConst.Text.DESTINY_NUM_TEXT, active_fate_num)
            total_fate = total_fate + active_fate_num
        end
    end
    go:FindChild("DestinyNum/Text"):GetComponent("Text").text = string.format(UIConst.Text.TOTAL_DESTINY_NUM_TEXT, total_fate)
end

function LineupUI:Hide()
    self:HideDestinyInfo()
    if self.select_effect then
        self.select_effect:EffectEnd()
        self.select_effect = nil
    end
    if self.aid_select_effect then
        self.aid_select_effect:EffectEnd()
        self.aid_select_effect = nil
    end
    self:ClearUnitDict("seat_to_model")
    self:ClearGoDict("seat_to_top_icon")
    self:ClearGoDict("mid_go_list")
    self:ClearAnim("top_anim")
    self:ClearAnim("mid_anim")
    self.cur_seat_index = nil
    for _, redpoint in pairs(self.hero_redpoint_dict) do
        SpecMgrs.redpoint_mgr:RemoveRedPoint(redpoint)
    end
    self.hero_redpoint_dict = {}
    for _, redpoint in pairs(self.replace_equip_redpoint_dict) do
        SpecMgrs.redpoint_mgr:RemoveRedPoint(redpoint)
    end
    self.replace_equip_redpoint_dict = {}
    LineupUI.super.Hide(self)
end

function LineupUI:_InitInitialPanel()
    self.init_lineup_list, self.unlock_lineup_list= self:_GetInitLineupIdList()
    self:_InitTopHreoPart()
    self:_InitMiddleHeroPart()
    self:SliderToIndex(kDefaultSelectSeatIndex, true)
end

function LineupUI:_InitTopHreoPart()
    self:ClearGoDict("seat_to_top_icon")
    for i, lineup_id in ipairs(self.init_lineup_list) do
        local data = self.unlock_seat_data[lineup_id]
        local temp = self.top_lineup_type_to_temp[data.type]
        local item = self:GetUIObject(self.top_lineup_type_to_temp[data.type], self.top_hero_item_parent)
        self.seat_to_top_icon[lineup_id] = item
        self:_InitTopItem(item, lineup_id)
    end
end

function LineupUI:_InitTopItem(item, lineup_id)
    local lineup_type = self.unlock_seat_data[lineup_id].type
    item.name = "seat_" .. lineup_id
    local func_name = func_map.top_init[lineup_type]
    self[func_name](self, item, lineup_id)
end

function LineupUI:_InitTopHeroItem(item, lineup_id)
    self:AssignSpriteByIconID(UIConst.Icon.DefaultHeroIconBg, item:GetComponent("Image"))
    item:FindChild("Grade"):SetActive(false)
    self:AddClick(item, function()
        if self:_CheckLineupUnlock(lineup_id) then
            self:SliderToIndex(lineup_id, false)
            if not self.dy_hero_data:GetLineupHeroId(lineup_id) then
                SpecMgrs.ui_mgr:ShowUI("ChangeHeroUI", {lineup_id = lineup_id})
            end
        end
    end)
end

function LineupUI:_InitTopAidItem(item, lineup_id)
    self:AddClick(item, function ()
        if self:_CheckLineupUnlock(lineup_id) then
            self:SliderToIndex(lineup_id, false)
        end
    end)
end

function LineupUI:_GetLineupUnlockData(index)
    local lineup_id = self.init_lineup_list[index]
    return self.unlock_seat_data[lineup_id]
end

function LineupUI:_CheckLineupUnlock(id)
    return ComMgrs.dy_data_mgr:ExGetRoleLevel() >= self:_GetLineupUnlockLevel(id)
end

function LineupUI:_GetLineupUnlockLevel(id)
    local data = self.unlock_seat_data[id]
    if data.type == kAid then
        return SpecMgrs.data_mgr:GetDeinforcementsData(1).unlock_level
    else
        return data.unlock_level
    end
end

function LineupUI:_UpdateTopHeroItem(go, seat_index)
    local id = self.init_lineup_list[seat_index]
    local is_unlock = self:_CheckLineupUnlock(id)
    local hero_id = self.dy_hero_data:GetLineupHeroId(id)
    local is_show_add_hero = is_unlock and not hero_id and true or false
    local is_show_hero_icon = hero_id and true or false
    if is_show_hero_icon then
        local hero_data = SpecMgrs.data_mgr:GetHeroData(hero_id)
        UIFuncs.InitHeroGo({go = go, hero_data = hero_data})
    end
    if not is_unlock then
        local unlock_level = self:_GetLineupUnlockLevel(id)
        go:FindChild("Unlock/Text"):GetComponent("Text").text = unlock_level
    end
    go:FindChild("Icon"):SetActive(is_show_hero_icon)
    go:FindChild("Unlock"):SetActive(not is_unlock)
    go:FindChild("AddHero"):SetActive(is_show_add_hero)
    self:_UpdateHeroRedPoint(seat_index)
end

function LineupUI:_UpdateTopAidItem(go)
    local id = kAidItemIndex
    local is_unlock = self:_CheckLineupUnlock(id)
    if not is_unlock then
        local unlock_level = self:_GetLineupUnlockLevel(id)
        go:FindChild("Unlock/Text"):GetComponent("Text").text = unlock_level
    end
    go:FindChild("Unlock"):SetActive(not is_unlock)
    go:FindChild("Text"):SetActive(is_unlock)
end

function LineupUI:ShowHeroDetailInfo()
    self.param_hero_list = {}
    local cur_select_hero_id = self.dy_hero_data:GetLineupHeroId(self.cur_seat_index)
    for i, id in ipairs(self.unlock_lineup_list) do
        local lineup_data = self.unlock_seat_data[id]
        if lineup_data.type == kHero then
            local hero_id = self.dy_hero_data:GetLineupHeroId(id)
            if hero_id then
                local hero_data = SpecMgrs.data_mgr:GetHeroData(hero_id)
                table.insert(self.param_hero_list, hero_data)
            end
        end
    end
    local param_index
    for index, hero_data in ipairs (self.param_hero_list) do
        if hero_data.id == cur_select_hero_id then
            param_index = index
            break
        end
    end

    if not next (self.param_hero_list) then return end
    SpecMgrs.ui_mgr:ShowHeroDetailInfo(self.param_hero_list, param_index, function (hero_id)
        local lineup_id = self.dy_hero_data:GetHeroLineupId(hero_id)
        self:SliderToIndex(lineup_id, true)
        self.param_hero_list = nil
    end)
end

function LineupUI:_InitMiddleHeroPart()
    local serv_lineup_data = self.dy_hero_data:GetAllLineupData()
    self:ClearUnitDict("seat_to_model")
    self:ClearGoDict("mid_go_list")
    for i, id in ipairs(self.unlock_lineup_list) do
        local lineup_type = self:_GetLineupUnlockData(i).type
        local item = self:GetUIObject(self.middle_lineup_type_to_temp[lineup_type], self.middle_hero_item_parent)
        self.mid_go_list[i] = item
        self:_InitMidItem(item, id, lineup_type)
    end
    self.middle_hero_width = self.middle_lineup_type_to_temp[kHero].transform.sizeDelta.x
    self.max_hero_scroll_pos = (#self.unlock_lineup_list - 1) * self.middle_hero_width -- 默认情况 每个英雄之间间隙为0 不用计算
end

function LineupUI:_InitMidItem(item, id, type)
    local button = item:FindChild("Button")
    self:AddDrag(button, function (delta, position)
        self:OnDrag(delta, position)
    end)
    self:AddRelease(button, function ()
        self:OnRelease()
    end)
    self:AddClick(button, function ()
        self:OnMidClick(id)
    end)
    local func_name = func_map.mid_init[type]
    if not func_name then return end
    self[func_name](self, item, id, type)
end

function LineupUI:_InitMidAidItem(item)
    local lineup_part = item:FindChild("LineupInfo/LineupPart")
    for seat_index = 1, self.max_hero_lineup_num do
        local go = lineup_part:FindChild(seat_index .. "/Seat/Item")
        self:AddClick(go, function ()
            self:ShowDestinyInfo(seat_index)
        end)
    end
end

function LineupUI:OnMidClick(id)
    if not self.is_drag then
        local data = self.unlock_seat_data[id]
        if data.type == kHero then
            if self.dy_hero_data:GetLineupHeroId(id) then
                self:ShowHeroDetailInfo()
            else
                SpecMgrs.ui_mgr:ShowUI("ChangeHeroUI", {lineup_id = id})
            end
        end
    end
end

function LineupUI:_GetInitLineupIdList()
    local role_level = ComMgrs.dy_data_mgr:ExGetRoleLevel()
    local init_lineup_list = {}
    local unlock_lineup_list = {}
    local unlock_hero_seat_num = 0
    for type, id_list in ipairs(self.unlock_seat_data.type_to_id_list) do
        for i, id in ipairs(id_list) do
            if role_level >= self.unlock_seat_data[id].show_level then
                table.insert(init_lineup_list, id)
                if self:_CheckLineupUnlock(id) then
                    table.insert(unlock_lineup_list, id)
                end
            end
        end
    end
    return init_lineup_list, unlock_lineup_list
end

function LineupUI:OnDrag(delta, position)
    if not self.is_drag then
        self.tip_go:SetActive(false)
        self.is_drag = true
    end
    self.slider_x_offset = self.slider_x_offset + delta.x
    local _, pos = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(self.middle_hero_item_parent:GetComponent("RectTransform"), position, self.canvas.worldCamera)
    local norimalize_pos = self.middle_hero_scroll_rect.horizontalNormalizedPosition - delta.x / self.max_hero_scroll_pos
    self.middle_hero_scroll_rect.horizontalNormalizedPosition = math.clamp(norimalize_pos, 0, 1)
end

function LineupUI:OnRelease()
    if math.abs(self.slider_x_offset) >= self.middle_hero_width * kSliderToNextFactor then
        local index = self.slider_x_offset > 0 and self.cur_seat_index - 1 or self.cur_seat_index + 1
        self:SliderToIndex(index, false)
    else
        self:SliderToIndex(self.cur_seat_index, false)
    end
    self.slider_x_offset = 0
end

function LineupUI:IsShowHeroPart()
    return self.cur_seat_index <= self.max_hero_lineup_num
end

function LineupUI:SliderToIndex(target_seat_index, is_immediately)
    target_seat_index = math.clamp(target_seat_index, 1, #self.unlock_lineup_list)
    if not self.cur_seat_index or self.cur_seat_index ~= target_seat_index then
        self.cur_seat_index = target_seat_index
    end
    self:_UpdateSelectedHero()
    self.ip_hero_part:SetActive(self:IsShowHeroPart())

    self:AddSelectEffect(target_seat_index)
    local slider_target_pos = target_seat_index == 1 and 0 or (target_seat_index - 1) / (#self.unlock_lineup_list - 1)
    if is_immediately then
        self.middle_hero_scroll_rect.horizontalNormalizedPosition = slider_target_pos
    else
        self:PlayScrollAnim(slider_target_pos, self.middle_hero_scroll_rect, "mid_anim")
    end
    local view_width = self.initial_panel:FindChild("Top/Hero"):GetComponent("RectTransform").rect.width
    local max_content_width = self.top_hero_item_parent:GetComponent("RectTransform").rect.width
    local move_width = max_content_width - view_width
    local top_hero_pos
    if move_width < 0 then -- content fit 还没调整
        top_hero_pos = 0
    else
        local icon_rect = self.seat_to_top_icon[target_seat_index]:GetComponent("RectTransform")
        local left_offset = icon_rect.anchoredPosition.x - kOffset
        local right_offset = icon_rect.anchoredPosition.x + icon_rect.rect.width + kOffset
        local left_pos = left_offset / move_width
        local right_pos = (right_offset - view_width) / move_width
        local cur_pos = self.top_hero_scroll_rect.horizontalNormalizedPosition
        if cur_pos > left_pos then
            top_hero_pos = left_pos
        end
        if cur_pos < right_pos then
            top_hero_pos = right_pos
        end
    end
    if not top_hero_pos then return end
    if is_immediately then
        self.top_hero_scroll_rect.horizontalNormalizedPosition = top_hero_pos
    else
        self:PlayScrollAnim(top_hero_pos, self.top_hero_scroll_rect, "top_anim")
    end
end

function LineupUI:PlayScrollAnim(target_pos, scroll_rect, anim_name)
    local cur_pos = scroll_rect.horizontalNormalizedPosition
    if math.abs(cur_pos - target_pos) < 0.01 then return end
    self:ClearAnim(anim_name)
    self[anim_name] = SpecMgrs.uianim_mgr:PlayScrollAnim(
        kTopHeroAnimTime,
        scroll_rect.gameObject,
        "horizontalNormalizedPosition",
        cur_pos,
        target_pos,
        tween.easing.linear,
        function ()
            self.is_drag = nil
        end
    )
end

function LineupUI:ClearAnim(anim_name)
    if self[anim_name] then
        SpecMgrs.uianim_mgr:StopAnim(self[anim_name])
    end
end

function LineupUI:_UpdateSelectedHero()
    if not self:IsShowHeroPart() then return end
    local lineup_id = self.unlock_lineup_list[self.cur_seat_index]
    local seat_data = self.dy_hero_data:GetLineupData(lineup_id)
    local hero_id = seat_data and seat_data.hero_id
    self:_UpdateHeroNameAndStar(hero_id)
    self:_UpdateEquipPart(seat_data)
    self:_UpdateAttrPart(self.cur_seat_index)
end

function LineupUI:_UpdateHeroNameAndStar(hero_id)
    if hero_id then
        local hero_data = SpecMgrs.data_mgr:GetHeroData(hero_id)
        local quality_data = SpecMgrs.data_mgr:GetQualityData(hero_data.quality)
        local serv_hero_data = self.dy_hero_data:GetHeroDataById(hero_id)
        local star_num = serv_hero_data.star_lv
        for i, go in ipairs(self.star_go_list) do
            go:FindChild("star"):SetActive(star_num >= i)
        end
        self.cur_hero_name_text.text = hero_data.name
        UIFuncs.AssignSpriteByIconID(quality_data.grade, self.cur_hero_grade_img)
        self.cur_hero_name_go:SetActive(true)
        self.tip_go:SetActive(false)
    else
        self.cur_hero_name_go:SetActive(false)
        self.tip_go:SetActive(true)
    end
end

function LineupUI:_UpdateEquipPart(seat_data)
    local seat_data = seat_data or self.dy_hero_data:GetLineupData(self.cur_seat_index)
    for i, go in ipairs(self.equip_go_dict) do
        self:_UpdateEquipByIndex(i, seat_data)
    end
end

function LineupUI:_UpdateEquipByIndex(equip_index, seat_data)
    local is_unlock, is_show, equip_part_data = self:CheckEquipUnlock(equip_index)
    local go = self.equip_go_dict[equip_index]
    go:SetActive(is_show)
    if not is_show then return end
    go:FindChild("Default/Unlock"):SetActive(not is_unlock)
    local equip_list = ComMgrs.dy_data_mgr.bag_data:GetBagItemListByPartIndex(equip_index, true)
    local is_show_add = next(equip_list) and true or false
    go:FindChild("Default/Image"):SetActive(is_show_add)
    go:FindChild("Default/Unlock"):GetComponent("Text").text = equip_part_data.unlock_level
    local seat_data = seat_data or self.dy_hero_data:GetLineupData(self.cur_seat_index)
    local equip_guid = seat_data and seat_data.equip_dict and seat_data.equip_dict[equip_index]
    local is_equip_wear = equip_guid and true or false
    go:FindChild("Default"):SetActive(not is_equip_wear)
    local item_go = go:FindChild("EquipParent")
    item_go:SetActive(is_equip_wear)
    self:_UpdateReplaceEquipRedPoint(equip_index, equip_guid)
    if not is_equip_wear then return end
    self:_UpdateEquipPartStrengthen(equip_index)
    local equip_data = ComMgrs.dy_data_mgr.bag_data:GetBagItemDataByGuid(equip_guid)
    UIFuncs.InitItemGo({go = item_go, item_id = equip_data.item_id})
end

function LineupUI:CheckEquipUnlock(equip_index, is_need_tip)
    local level = ComMgrs.dy_data_mgr:ExGetRoleLevel()
    local equip_part_data = SpecMgrs.data_mgr:GetEquipPartData(equip_index)
    local is_unlock = level >= equip_part_data.unlock_level
    local is_show = level >= equip_part_data.show_level
    if not is_unlock and is_need_tip then
        local tip_str = string.format(UIConst.Text.FUNC_UNLOCK_LEVEL, equip_part_data.unlock_level)
        SpecMgrs.ui_mgr:ShowTipMsg(tip_str)
    end
    return is_unlock, is_show, equip_part_data
end

-- 绿色箭头显示可强化
function LineupUI:_UpdateEquipPartStrengthen(equip_index)
    local is_show_green_up_arrow = self.dy_hero_data:CheckEquipUp(self.cur_seat_index, equip_index)
    self.equip_go_dict[equip_index]:FindChild("EquipParent/Add"):SetActive(is_show_green_up_arrow)
end

function LineupUI:GetEquipDataByEquipIndex(index)
    local seat_data = self.dy_hero_data:GetLineupData(self.cur_seat_index)
    local equip_guid = seat_data.equip_dict[index]
    if equip_guid then
        return ComMgrs.dy_data_mgr.bag_data:GetBagItemDataByGuid(equip_guid)
    end
end

function LineupUI:EquipOnClick(index)
    local hero_id  = self.dy_hero_data:GetLineupHeroId(self.cur_seat_index)
    if not hero_id then
        return
    end
    if not self:CheckEquipUnlock(index, true) then
        return
    end
    local equip_data = self:GetEquipDataByEquipIndex(index)
    if equip_data then
        if equip_data.item_data.is_treasure then
            SpecMgrs.ui_mgr:ShowUI("TreasureDetailInfoUI", equip_data.guid)
        else
            SpecMgrs.ui_mgr:ShowUI("EquipmentDetailInfoUI", equip_data.guid)
        end
    else
        SpecMgrs.ui_mgr:ShowUI("SelectEquipUI", {lineup_id = self.cur_seat_index, part_index = index})
    end
end

function LineupUI:_UpdateAttrPart(lineup_id)
    local hero_id = self.dy_hero_data:GetLineupHeroId(lineup_id)
    if hero_id then
        local serv_hero_data = self.dy_hero_data:GetHeroDataById(hero_id)
        local attr_dict = serv_hero_data.attr_dict
        for attr_key, text_comp in pairs(self.attr_text_dict) do
            local str
            if attr_key == attr_map.level then
                str = string.format(UIConst.Text.LEVEL_FORMAT_TEXT, serv_hero_data.level)
            elseif attr_key == attr_map.score then
                local score_str = UIFuncs.AddCountUnit(serv_hero_data.score)
                str = string.format(UIConst.Text.SCORE_FORMAT, score_str)
            elseif attr_key == attr_map.def then
                local def_str = UIFuncs.AddCountUnit(attr_dict.def)
                str = string.format(UIConst.Text.DEF_ATTR_FORMAT, def_str)
            elseif attr_key == attr_map.att then
                local att_str = UIFuncs.AddCountUnit(attr_dict.att)
                str = string.format(UIConst.Text.ATK_ATTR_FORMAT, att_str)
            elseif attr_key == attr_map.max_hp then
                local hp_str = UIFuncs.AddCountUnit(attr_dict.max_hp)
                str = string.format(UIConst.Text.HP_ATTR_FORMAT, hp_str)
            end
            text_comp.text = str
        end
        local sorted_fate_list, is_fate_active = self.dy_hero_data:GetSortedFateList(lineup_id)
        for i, text in ipairs(self.fate_go_list) do
            local is_show = sorted_fate_list[i] and true or false
            local go = self.fate_go_list[i]
            if is_show then
                local fate_data = SpecMgrs.data_mgr:GetFateData(sorted_fate_list[i])
                local is_active = is_fate_active[sorted_fate_list[i]]
                local color_hex = is_active and UIConst.Color.Default or UIConst.Color.Gray
                local color = UIFuncs.HexToRGBColor(color_hex)
                local text = go:FindChild("Text"):GetComponent("Text")
                text.color = color
                text.text = fate_data.name
                go:FindChild("Image"):GetComponent("Image").color = color
            end
            go:SetActive(is_show)
        end
    end
    self.fate_content_go:SetActive(hero_id and true or false)
    self.attr_content_go:SetActive(hero_id and true or false)
end

----Initial_panel end

function LineupUI:ShowIntensifyPanel()
    if self:CanShowStrenghthenMasterUI() then
        SpecMgrs.ui_mgr:ShowUI("StrenghthenMasterUI", self.cur_seat_index)
    else
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.PLEASE_PUT_ON_BASE_EQUIP)
    end
end

function LineupUI:CanShowStrenghthenMasterUI()
    for i = 1, kEquipLimit do
        if not self:GetEquipDataByEquipIndex(i) then
            return false
        end
    end
    return true
end

function LineupUI:AddSelectEffect(seat_index)
    local go = self.seat_to_top_icon[seat_index]:FindChild("Selected")
    if not self.select_effect then
        self.select_effect = UIFuncs.AddSelectEffect(self, go)
    else
        self.select_effect:SetNewAttachGo(go)
    end
end

function LineupUI:AddAidSelectEffect(go)
    if not self.aid_select_effect then
        self.aid_select_effect = UIFuncs.AddSelectEffect(self, go)
    else
        self.aid_select_effect:SetNewAttachGo(go)
    end
end

function LineupUI:_UpdateHeroRedPoint(seat_index)
    if self.hero_redpoint_dict[seat_index] then
        SpecMgrs.redpoint_mgr:RemoveRedPoint(self.hero_redpoint_dict[seat_index])
        self.hero_redpoint_dict[seat_index] = nil
    end
    local hero_id = self.dy_hero_data:GetLineupHeroId(seat_index)
    if hero_id then
        self.hero_redpoint_dict[seat_index] = SpecMgrs.redpoint_mgr:AddRedPoint(self, self.seat_to_top_icon[seat_index], CSConst.RedPointType.Normal, self.redpoint_control_id_list, hero_id)
    end
end

function LineupUI:_UpdateReplaceEquipRedPoint(equip_index, equip_guid)
    if self.replace_equip_redpoint_dict[equip_index] then
        SpecMgrs.redpoint_mgr:RemoveRedPoint(self.replace_equip_redpoint_dict[equip_index])
        self.replace_equip_redpoint_dict[equip_index] = nil
    end
    if equip_guid then
        local parent = self.equip_go_dict[equip_index]
        local control_id_list = {CSConst.RedPointControlIdDict.ReplaceEquip}
        local redpoint = SpecMgrs.redpoint_mgr:AddRedPoint(self, parent, CSConst.RedPointType.Normal, control_id_list, equip_guid, default_vector2, default_vector2)
        self.replace_equip_redpoint_dict[equip_index] = redpoint
    end
end

-- 子面板
function LineupUI:ShowDestinyInfo(seat_index)
    local hero_id = self.dy_hero_data:GetLineupHeroId(seat_index)
    if hero_id then
        self.destiny_info_panel:SetActive(true)
        self:_UpdateDestinyInfo(seat_index)
    end
end

function LineupUI:HideDestinyInfo()
    self.destiny_info_panel:SetActive(false)
end

function LineupUI:_UpdateDestinyInfo(seat_index)
    local destiny_text = ""
    local hero_id = self.dy_hero_data:GetLineupHeroId(seat_index)
    local sort_fate_list, active_fate_dict = self.dy_hero_data:GetSortedFateList(seat_index)
    for i, fate_id in ipairs(sort_fate_list) do
        local fate_data = SpecMgrs.data_mgr:GetFateData(fate_id)
        local is_avtive_fate = active_fate_dict[fate_id] and true or false
        local fate_desc = UIFuncs.GetFateDescStr(fate_id, is_avtive_fate)
        destiny_text = destiny_text .. fate_desc .. "\n"
    end
    self.destiny_info_panel:FindChild("Content/Text"):GetComponent("Text").text = destiny_text
end

return LineupUI