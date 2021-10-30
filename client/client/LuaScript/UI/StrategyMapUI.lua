local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local ItemUtil = require("BaseUtilities.ItemUtil")
local MonsterUtil = require("BaseUtilities.MonsterUtil")
local UnitConst = require("Unit.UnitConst")
local UIFuncs = require("UI.UIFuncs")
local StrategyMapUI = class("UI.StrategyMapUI", UIBase)

local kAnimTime = 1.467

StrategyMapUI.need_sync_load = true

local panel_name_map = {
    InitialPanel = "StrategyMapUIInitialPanel",
    AllIncomePanel = "AllIncomePanel",
    CityPreviewPanel = "CityPreviewPanel",
}

local kNoFiltKey = "All"
local kSliderTime = 0.2
local kHundred = 100
local kCityStarEachLine = 5
local kPlayerFlagIcon = 110010
function StrategyMapUI:DoInit()
    StrategyMapUI.super.DoInit(self)
    self.prefab_path = "UI/Common/StrategyMapUI"
    self.dy_strategy_data = ComMgrs.dy_data_mgr.strategy_map_data
    self.city_data_list = SpecMgrs.data_mgr:GetAllCityData()
    self.country_data_list = SpecMgrs.data_mgr:GetAllCountryData()

    -- go 引用
    self.city_to_flag_unit = {}
    self.city_comp_dict = {} -- {[city_id] = {}}
    self.city_to_go = {}

    self.iop_country_to_filt_btn = {}
    self.country_treasure_progress_list = {}
    self.country_treasure_go_list = {}
    self.country_to_pos = {} -- 每个城市相对于scroll的位置

    self.cpp_item_list = {}
    self.cpp_star_row_list = {}
    self.cpp_star_list = {}
    self.cpp_hero_income_go_list = {}
    self.cpp_unit_list = {}

    -- 清理的数据
    self.cur_stage = nil
    self.cur_country = nil -- 当前最新解锁国家
    self.cur_city = nil -- 当前最新解锁城市
    self.cur_city_pos = nil
    self.slider_timer = 0
end

function StrategyMapUI:OnGoLoadedOk(res_go)
    StrategyMapUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
    self:UpdateAllTreasureBox()
end

function StrategyMapUI:Show(init_country_id)
    self.init_country_id = init_country_id
    if self.is_res_ok then
        self:InitUI()
    end
    StrategyMapUI.super.Show(self)
    self:UpdateAllTreasureBox()
    self:PlayCloudDisappearEffect()
end

function StrategyMapUI:InitRes()
    self:_InitInitialPanel()
    self:_InitAllIncomePanel()
    self:_InitCityPreviewPanel()
end

function StrategyMapUI:ShowPanelHelp(panel_name)
    UIFuncs.ShowPanelHelp(panel_name)
end

function StrategyMapUI:Recover()
    self:PlayCloudDisappearEffect()
    self:_UpdateCountryTreasure(true)
end

function StrategyMapUI:UpdateAllTreasureBox()
    if not self.go.activeSelf then return end -- ui被隐藏不更新
    if not self.cur_show_country_treasure_id then return end
    local country_data = self.country_data_list[self.cur_show_country_treasure_id]
    local need_treasure_num = #country_data.occupy_pct_list
    local serv_country_data = self.dy_strategy_data:GetCountryDataByCountryId(self.cur_show_country_treasure_id)
    if serv_country_data then
        local reward_dict = serv_country_data.reward_dict
        for i = 1, need_treasure_num do
            UIFuncs.UpdateTreasureBoxStatus(self.country_treasure_go_list[i], reward_dict[i])
        end
    else
        for i = 1, need_treasure_num do
            UIFuncs.UpdateTreasureBoxStatus(self.country_treasure_go_list[i], false)
        end
    end
end

function StrategyMapUI:_InitInitialPanel()
    self.initial_panel = self.main_panel:FindChild("PanelList/StrategyMapUIInitialPanel")
    self:AddClick(self.initial_panel:FindChild("TopBar/CloseBtn"), function()
        SpecMgrs.ui_mgr:HideUI(self)
    end)
    self:AddClick(self.initial_panel:FindChild("TopBar/HelpBtn"), function()
        UIFuncs.ShowPanelHelp("StrategyMapPanel")
    end)
    local scroll_view_go = self.initial_panel:FindChild("MiddlePart/Scroll View")
    self.ip_scroll_rect = scroll_view_go:GetComponent("ScrollRect")
    self.ip_scroll_content_rect = scroll_view_go:FindChild("Viewport/Content"):GetComponent("RectTransform")
    local country_go_parent = self.initial_panel:FindChild("MiddlePart/Scroll View/Viewport/Content/BigMap")
    self.map_bg_image = country_go_parent:GetComponent("Image")
    self.big_map_rect = country_go_parent:GetComponent("RectTransform")
    self.ip_view_port_rect = self.initial_panel:FindChild("MiddlePart"):GetComponent("RectTransform")
    local temp_parent = self.main_panel:FindChild("Temp")
    temp_parent:SetActive(false)
    self.city_go_temp = temp_parent:FindChild("CityTemp")
    self.city_go_parent = country_go_parent:FindChild("CityList")

    local navigation_btn = self.initial_panel:FindChild("NavigationBtn")
    self:AddClick(navigation_btn, function()
        self:NavToCurCity()
    end)
    local one_key_get_btn = self.initial_panel:FindChild("BottomBar/OneKeyGetBtn")
    self:AddCooldownClick(one_key_get_btn, function()
        self:GetCityAllReward()
    end)

    self.ip_treasure_slider = self.initial_panel:FindChild("BottomBar/Slider"):GetComponent("Slider")
    self.ip_treasure_parent = self.initial_panel:FindChild("BottomBar/Slider/Fill Area/AwardList")
    self.ip_treasure_temp = self.ip_treasure_parent:FindChild("Item")
    self.ip_treasure_temp:SetActive(false)

    self.rank_btn = self.initial_panel:FindChild("BottomBar/RankBtn")
    self:AddClick(self.rank_btn, function ()
        SpecMgrs.ui_mgr:ShowRankUI(UIConst.Rank.StageStar)
    end)

    local btn_list = self.initial_panel:FindChild("BtnList")
    self.show_all_income_btn = btn_list:FindChild("ShowAllIncomeBtn")
    self.show_all_income_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ALL_INCOME_TITLE
    self.ip_red_point = self.show_all_income_btn:FindChild("Text/RedPoint")
    self:AddClick(self.show_all_income_btn, function()
        if not self.dy_strategy_data:CheckOccupiedCityNum() then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.UNLOCK_INCOME_TIP)
            return
        end
        self:ShowAllIncomePanel()
    end)

    self.show_lineup_btn = btn_list:FindChild("ShowLineupBtn")
    self.show_lineup_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.LINEUP
    self:AddClick(self.show_lineup_btn, function()
        SpecMgrs.ui_mgr:ShowUI("LineupUI")
    end)

    self.change_country_btn = btn_list:FindChild("ChangeCountryBtn")
    self.change_country_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CHANGE_COUNTRY_TITLE
    self:AddClick(self.change_country_btn, function()
        SpecMgrs.ui_mgr:ShowUI("ChangeCountryUI", function (country_id)
            if not self.cur_show_country_id or self.cur_show_country_id ~= country_id then
                self:PlayCloudAppearEffect(function ()
                    self:ChangeCountry(country_id)
                end)
            end
        end)
    end)
    self.country_icon_image = self.initial_panel:FindChild("CountyIcon"):GetComponent("Image")
    self.country_name_text = self.initial_panel:FindChild("CountyIcon/Text"):GetComponent("Text")
    self.cloud_effect_go = self.initial_panel:FindChild("CloudEffect")
    self.cloud_animator = self.cloud_effect_go:GetComponent("Animator")
end

function StrategyMapUI:GetCityFragUnit(city_data)
    local flag_id
    if self.dy_strategy_data:CheckCityIsOccupied(city_data.id) then
        flag_id = ComMgrs.dy_data_mgr:ExGetRoleFlag()
    else
        flag_id = SpecMgrs.data_mgr:GetPowerData(city_data.power_id).flag_id
    end
    return SpecMgrs.data_mgr:GetFlagData(flag_id).flag_unit
end

function StrategyMapUI:CityBtnOnClick(city_id)
    if self.dy_strategy_data:CheckCityIsUnlock(city_id) then
        self:ShowCityPreviewPanel(city_id)
    else
        local last_city_data = SpecMgrs.data_mgr:GetCityData(city_id - 1)
        local str = string.format(UIConst.Text.UNLOCK_CITY, last_city_data.name)
        SpecMgrs.ui_mgr:ShowTipMsg(str)
    end
end

function StrategyMapUI:_InitAllIncomePanel()
    self.all_income_panel = self.main_panel:FindChild("PanelList/AllIncomePanel")
    -- 以下简称aip
    self:AddClick(self.all_income_panel:FindChild("Panel/Top/CloseBtn"), function()
        self:HideAllIncomePanel()
    end)
    self.all_income_panel:FindChild("Panel/Top/Title"):GetComponent("Text").text = UIConst.Text.ALL_INCOME_TITLE
    self.all_income_panel:FindChild("Panel/Middle/Top/Text"):GetComponent("Text").text = UIConst.Text.RESOURCE
    self.all_income_panel:FindChild("Panel/Middle/Top/Text (1)"):GetComponent("Text").text = UIConst.Text.CUR_RESOURCE_RESOURCE_LIMIT
    self.all_income_panel:FindChild("Panel/Middle/Top/Text (2)"):GetComponent("Text").text = UIConst.Text.RESOURCE_INCOME_EACH_HOUR
    self.aip_item_parent = self.all_income_panel:FindChild("Panel/Middle/Scroll View/Viewport/Content")
    self.aip_item_temp = self.aip_item_parent:FindChild("Item")
    self.aip_item_temp:SetActive(false)
    local desc_go = self.all_income_panel:FindChild("Panel/Middle/Discription")
    self.aip_all_city_num_text = desc_go:FindChild("1"):GetComponent("Text")
    self.aip_unlock_city_num_text = desc_go:FindChild("2"):GetComponent("Text")
    self.aip_manager_city_num_text = desc_go:FindChild("3"):GetComponent("Text")
    self.aip_no_manager_city_num_text = desc_go:FindChild("4"):GetComponent("Text")
    local get_btn = self.all_income_panel:FindChild("Panel/Bottom/BtnList/GetBtn")
    get_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.OBTAIN_TEXT

    self:AddClick(get_btn, function()
        local resource_dict = self.dy_strategy_data:GetResourceDict()
        if next(resource_dict) then
            SpecMgrs.msg_mgr:SendMsg("SendGetCityResource")
        else
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.NO_RESOURCE_CAN_GET)
        end
    end)
    self.aip_red_point = get_btn:FindChild("RedPoint")
end

function StrategyMapUI:_InitCityPreviewPanel()
    self.city_preview_panel = self.main_panel:FindChild("PanelList/CityPreviewPanel")
    self:AddClick(self.city_preview_panel:FindChild("Panel/TopBar/CloseBtn"), function()
        self:HideCityPreviewPanel()
    end)
    local panel = self.city_preview_panel:FindChild("Panel")
    panel:FindChild("City/Right/Scroll View/Title/Text"):GetComponent("Text").text = UIConst.Text.RESOURCE
    panel:FindChild("City/Right/Scroll View/Title/Text (1)"):GetComponent("Text").text = UIConst.Text.RESOURCE_INCOME_EACH_HOUR
    panel:FindChild("City/Right/Scroll View/Title/Text (2)"):GetComponent("Text").text = UIConst.Text.RESOURCE_LIMIT

    self.cpp_city_name_text = panel:FindChild("TopBar/Title"):GetComponent("Text")
    self.cpp_city_power_name_go = panel:FindChild("City/Left/Bg/PowerName")
    self.cpp_city_power_name_text = self.cpp_city_power_name_go:FindChild("Text"):GetComponent("Text")
    self.cpp_city_power_image = panel:FindChild("City/Left/Bg/Power/Icon"):GetComponent("Image")
    self.cpp_city_bg_image = panel:FindChild("City/Left/Bg"):GetComponent("Image")

    self.cpp_item_parent = panel:FindChild("City/Right/Scroll View/Viewport/Content")
    self.cpp_item_temp = self.cpp_item_parent:FindChild("Item")
    self.cpp_item_temp:SetActive(false)

    self.cpp_boss_part = panel:FindChild("Middle/Boss")
    self.cpp_suggest_sore_text = self.cpp_boss_part:FindChild("SuggestScore"):GetComponent("Text")
    self.cpp_boss_unit_parent = self.cpp_boss_part:FindChild("Icon/UnitParent")
    self.cpp_boss_story_text = self.cpp_boss_part:FindChild("Story/Scroll View/Viewport/Content"):GetComponent("Text")
    self.cpp_boss_name_text = self.cpp_boss_part:FindChild("Icon/Name/Text"):GetComponent("Text")

    self.cpp_manager_part = panel:FindChild("Middle/Manager")
    self.cpp_manager_name_text = self.cpp_manager_part:FindChild("Name/Text"):GetComponent("Text")
    self.cpp_hero_unit_parent = self.cpp_manager_part:FindChild("Icon/Mask/HeroUnitParent")
    self.cpp_boy_unit_parent = self.cpp_manager_part:FindChild("Icon/Mask/BoyUnitParent")
    self.cpp_girl_unit_parent = self.cpp_manager_part:FindChild("Icon/Mask/GirlUnitParent")
    self.cpp_manager_story_text = self.cpp_manager_part:FindChild("Story/Scroll View/Viewport/Content"):GetComponent("Text")

    self.cpp_no_manager_part = panel:FindChild("Middle/NoManager")
    self.cpp_no_manager_part:FindChild("Name"):GetComponent("Text").text = UIConst.Text.NO_MANAGER
    self.cpp_no_manager_part:FindChild("Story"):GetComponent("Text").text = UIConst.Text.SUGGEST_SEND_MANAGER

    self.cpp_join_btn = panel:FindChild("BtnList/JoinBtn")
    self.cpp_join_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ENTER
    self:AddClick(self.cpp_join_btn, function()
        local city_id = self.show_cpp_city_id
        if city_id then
            self:HideCityPreviewPanel()
            SpecMgrs.ui_mgr:ShowUI("CityStageUI", city_id)
        end
    end)
    self.show_manager_ui_btn = panel:FindChild("BtnList/ShowManagerPanelBtn")
    self.show_manager_ui_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.MANAGE
    self:AddClick(self.show_manager_ui_btn, function()
        local city_id = self.show_cpp_city_id
        if city_id and self.dy_strategy_data:CheckCityIsOccupied(self.show_cpp_city_id) then
            SpecMgrs.ui_mgr:ShowUI("CityManagerUI", city_id)
        end
    end)
end

function StrategyMapUI:InitUI()
    self:RegisterEvent(self.dy_strategy_data, "UpdateResource", function()
        self:_UpdateIncomeRedPoint()
        self:_UpdateAllIncomePanel()
    end)
    self:RegisterEvent(self.dy_strategy_data, "UnlockNewStage", function()
        self:_UpdateCurStage()
        self:_UpdateCountryTreasure(true)
    end)
    self:RegisterEvent(self.dy_strategy_data,"UpdateCityData", function(_, city_dict)
        for city_id, _ in pairs(city_dict) do
            self:_UpdateCity(city_id)
            if self.show_cpp_city_id and self.show_cpp_city_id == city_id then
                self:_UpdateCityPreviewPanel()
            end
        end
    end)

    self.init_country_id = self.init_country_id or self.dy_strategy_data:GetCurCountry()
    self:ChangeCountry(self.init_country_id)
    self.init_country_id = nil
    self.ip_scroll_content_rect.localScale = UIFuncs.GetPerfectMapScale(false)
    self:_UpdateIncomeRedPoint()
    self:_UpdateCountryTreasure(true)
end

function StrategyMapUI:ChangeCountry(country_id)
    if self.cur_show_country_id and self.cur_show_country_id == country_id then return end
    local country_data = self.country_data_list[country_id]
    if country_data then
        self.cur_show_country_id = country_id
    else -- 通过所有国家就显示最后一个国家
        self.cur_show_country_id = #self.country_data_list
        country_data = self.country_data_list[#self.country_data_list]
    end
    self:ClearAllCityGo()
    self.big_map_rect.sizeDelta = Vector2.NewByTable(country_data.size)
    local city_list = SpecMgrs.data_mgr:GetCityListByCountryId(self.cur_show_country_id)
    for i, city_id in ipairs(city_list) do
        local city_go = self:GetUIObject(self.city_go_temp, self.city_go_parent)
        self.city_to_go[city_id] = city_go
        self:_InitCityGo(city_go, city_id)
    end
    self:_SetCountryTreasure(self.cur_show_country_id)
    self:_UpdateInitialPanel()
    self:_UpdateCurCityPos()
    self:NavToCurCity()
    self:AssignSpriteByIconID(country_data.icon, self.country_icon_image)
    self:AssignSpriteByIconID(country_data.bg, self.map_bg_image)
    self.country_name_text.text = country_data.name
end

function StrategyMapUI:ClearAllCityGo()
    self:ClearUnitDict("city_to_flag_unit")
    self:ClearGoDict("city_to_go")
    self.city_comp_dict = {}
end

function StrategyMapUI:_InitCityGo(city_go, city_id)
    local city_data = self.city_data_list[city_id]
    local city_build_type_data = SpecMgrs.data_mgr:GetCityBuildTypeData(city_data.city_build_type)
    city_go:GetComponent("RectTransform").anchoredPosition = Vector2.NewByTable(city_data.pos)
    city_go.name = "city_" .. city_id
    self.city_comp_dict[city_id] = {}
    local city_comp_dict = self.city_comp_dict[city_id]
    local city_model = city_go:FindChild("Model")
    city_comp_dict.model_image = city_model:GetComponent("Image")
    self:AssignSpriteByIconID(city_build_type_data.icon, city_comp_dict.model_image)
    city_comp_dict.model_image:SetNativeSize()
    city_comp_dict.unlock_show_go = city_model:FindChild("Icon")
    city_comp_dict.no_manager = city_model:FindChild("Icon/NoManager")
    city_comp_dict.manager = city_model:FindChild("Icon/Manager")
    city_comp_dict.in_war = city_model:FindChild("Icon/InWar")
    city_comp_dict.progress = city_model:FindChild("Progress")
    city_comp_dict.progress_slider = city_comp_dict.progress:GetComponent("Slider")
    city_comp_dict.progress_text = city_comp_dict.progress:FindChild("Text"):GetComponent("Text")
    city_comp_dict.name_text = city_model:FindChild("Name/Text"):GetComponent("Text")
    city_comp_dict.name_text.text = city_data.name
    city_comp_dict.flag = city_model:FindChild("Flag")
    city_comp_dict.flag:GetComponent("RectTransform").anchoredPosition = Vector2.NewByTable(city_build_type_data.flag_pos)
    self:AddClick(city_model, function ()
        self:CityBtnOnClick(city_id)
    end)
    self:AddClick(city_comp_dict.unlock_show_go, function ()
        self:CityBtnOnClick(city_id)
    end)
end

function StrategyMapUI:Hide()
    self:HideCityPreviewPanel()
    self:HideAllIncomePanel()
    self:ClearAllCityGo()
    self.cur_show_country_id = nil
    self.cur_stage = nil
    self.cur_city = nil
    self.cur_country = nil
    self.cur_city_pos = nil
    self.slider_timer = 0
    self.cur_show_country_treasure_id = nil
    StrategyMapUI.super.Hide(self)
end

function StrategyMapUI:Update(delta_time)
    -- 导航到对应城市，动画曲线暂时为线性
    if self.slider_target_pos then
        self.slider_timer = self.slider_timer + delta_time
        local cur_pos
        if self.slider_timer >= kSliderTime then
            self.slider_timer = 0
            cur_pos = self.slider_target_pos
            self.slider_target_pos = nil
            self.slider_original_pos = nil
        else
            cur_pos = math.lerp(self.slider_original_pos, self.slider_target_pos, self.slider_timer / kSliderTime)
        end
        self.ip_scroll_rect.horizontalNormalizedPosition = cur_pos
    end
end

function StrategyMapUI:GetCityAllReward(city_id)
    SpecMgrs.msg_mgr:SendMsg("SendGetCityAllReward", {city_id = city_id}, function (resp)
        local item_list = resp.item_list
        if not next(item_list) then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.NO_REWARD)
            return
        end
        item_list = ItemUtil.MergeRoleItemList(item_list)
        item_list = ItemUtil.SortRoleItemList(item_list)
        SpecMgrs.ui_mgr:ShowUI("GetItemUI", item_list)
    end)
end

function StrategyMapUI:_UpdateInitialPanel()
    self:_UpdateCurStage()
    for city_id, go in pairs(self.city_to_go) do
        self:_UpdateCity(city_id)
    end
end

function StrategyMapUI:_UpdateCity(city_id)
    if not self.city_comp_dict[city_id] then return end -- 当前地图没有该城市 或者 是最后一个城市
    local city_comp_dict = self.city_comp_dict[city_id]
    local city_data = self.city_data_list[city_id]
    local serv_city_data = self.dy_strategy_data:GetCityDataByCityId(city_id)
    local is_unlock = self.cur_city >= city_id
    local is_cur_city = self.cur_city == city_id and true or false
    local is_occupied = serv_city_data and serv_city_data.is_occupied or false
    local is_managed = serv_city_data and serv_city_data.manager_type and serv_city_data.manager_id and true or false
    local city_color = is_unlock and UIConst.Color.Default or UIConst.Color.CityBuildLockColor
    city_comp_dict.model_image.color = UIFuncs.HexToRGBColor(city_color)
    city_comp_dict.unlock_show_go:SetActive(is_unlock)
    city_comp_dict.in_war:SetActive(is_cur_city)
    -- 旗帜

    local city_frag_unit = self:GetCityFragUnit(city_data)
    if self.city_to_flag_unit[city_id] then
        self:RemoveUnit(self.city_to_flag_unit[city_id])
    end
    self.city_to_flag_unit[city_id] = self:AddUnit(city_frag_unit, city_comp_dict.flag)
    -- 进度
    local is_show_progress = is_unlock and not is_cur_city and not is_occupied
    city_comp_dict.progress:SetActive(is_show_progress)
    if is_show_progress then
        local max_star_num = SpecMgrs.data_mgr:GetCityMaxStarNumByCityId(city_id)
        local star_num = serv_city_data and serv_city_data.star_num or 0
        local progress = star_num / max_star_num
        city_comp_dict.progress_slider.value = progress
        city_comp_dict.progress_text.text = string.format(UIConst.Text.PERCENT, math.ceil(progress * 100))
    end
    -- 管理者
    city_comp_dict.manager:SetActive(is_occupied and is_managed)
    city_comp_dict.no_manager:SetActive(is_occupied and not is_managed)
    if is_occupied and is_managed then
        local unit_id = self.dy_strategy_data:GetManagerUnitIdByCity(city_id)
        local icon_id = SpecMgrs.data_mgr:GetUnitData(unit_id).icon
        local image = city_comp_dict.manager:FindChild("Fram/Icon"):GetComponent("Image")
        self:AssignSpriteByIconID(icon_id, image)
    end
end

function StrategyMapUI:_UpdateCurCityPos()
    local city_id = math.min(self.cur_city, #self.city_data_list)
    self.cur_city_pos = self:GetGoNormalizePosInScrollRect(self.city_to_go[city_id])
end

-- 适用于锚点居中的scroll_rect
function StrategyMapUI:GetGoNormalizePosInScrollRect(go)
    if not go then return 0 end
    local scroll_rect = self.big_map_rect
    local view_rect = self.ip_view_port_rect
    local _, pos = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(scroll_rect, go.position)
    local x_offset = scroll_rect.rect.width / 2 + pos.x - view_rect.rect.width / 2
    if x_offset < 0 then
       return 0
    else
        return math.clamp(x_offset / (scroll_rect.rect.width - view_rect.rect.width), 0, 1)
    end
end

function StrategyMapUI:_UpdateCurStage()
    local cur_stage = self.dy_strategy_data:GetCurStage()
    local stage_data = SpecMgrs.data_mgr:GetStageData(cur_stage)
    local city_data
    local cur_city
    local cur_country
    if stage_data then
        cur_city = stage_data.city_id
        cur_country = SpecMgrs.data_mgr:GetCityData(cur_city).country_id
    else -- 已通关
        cur_city = #self.city_data_list + 1
        cur_country = #self.country_data_list + 1
    end
    if not self.cur_stage then -- 初始化
        self.cur_stage = cur_stage
        self.cur_city = cur_city
        self.cur_country = cur_country
        self:_UpdateCurCityPos()
        self.ip_scroll_rect.horizontalNormalizedPosition = self.cur_city_pos -- 第一次初始化直接跳到对应城市位置
        return
    end
    if self.cur_stage and not (cur_stage > self.cur_stage) then return end
    self.cur_stage = cur_stage
    if cur_country > self.cur_country then
        self:DelayPlayCountryUnlockEffect(cur_country, cur_city)
    elseif cur_city > self.cur_city then
        self:DelayPlayCityUnlockEffect(cur_city)
    end
end

function StrategyMapUI:DelayPlayCityUnlockEffect(cur_city)
    -- todo 缓存解锁动画等待关卡界面关闭进入大地图播放
    local old_city_id = self.cur_city
    self.cur_city = cur_city
    self:_UpdateCity(old_city_id)
    self:_UpdateCity(self.cur_city)
    self:_UpdateCurCityPos()
end

function StrategyMapUI:DelayPlayCountryUnlockEffect(cur_country,cur_city)
    -- todo 缓存解锁动画等待关卡界面关闭进入大地图播放
    self.cur_country = cur_country
    self:ChangeCountry(self.cur_country)
    self:DelayPlayCityUnlockEffect(cur_city)
end

function StrategyMapUI:_UpdateCountryTreasure(is_update)
    self:_SetCountryTreasure(self.cur_show_country_id, is_update)
end

function StrategyMapUI:_SetCountryTreasure(show_country_treasure_id, is_update)
    if not self.country_data_list[show_country_treasure_id] then return end
    if self.cur_show_country_treasure_id and self.cur_show_country_treasure_id == show_country_treasure_id and not is_update then return end
    self.cur_show_country_treasure_id = show_country_treasure_id
    local country_data = self.country_data_list[show_country_treasure_id]
    local need_treasure_num = #country_data.occupy_pct_list
    local cur_treasure_num = #self.country_treasure_progress_list
    -- 设置宝箱数量
    local item
    if need_treasure_num > cur_treasure_num then
        for i = cur_treasure_num + 1, need_treasure_num do
            item = self:GetUIObject(self.ip_treasure_temp, self.ip_treasure_parent)
            table.insert(self.country_treasure_progress_list, item)
        end
    else
        for i, item in ipairs(self.country_treasure_progress_list) do
            if i <= need_treasure_num then
                item:SetActive(true)
            else
                item:SetActive(false)
            end
        end
    end

    self:ClearGoDict("country_treasure_go_list")
    local treasure_box_id
    local treasure_box
    local occupy_pct_list = country_data.occupy_pct_list
    local pct_str
    for i, progress_go in ipairs(self.country_treasure_progress_list) do
        pct_str = string.format(UIConst.Text.PERCENT, math.floor(occupy_pct_list[i] * kHundred))
        self.country_treasure_progress_list[i]:FindChild("Image/Text"):GetComponent("Text").text = pct_str
        treasure_box_id = country_data.treasure_box_id_list and country_data.treasure_box_id_list[i]
        treasure_box = UIFuncs.GetTreasureBox(self, progress_go:FindChild("Image/TreasureBoxParent"), treasure_box_id)
        self:AddClick(treasure_box, function ()
            self:ConuntryTresureOnClick(i)
        end)
        table.insert(self.country_treasure_go_list, treasure_box)
    end

    -- 设置进度条
    local serv_country_data = self.dy_strategy_data:GetCountryDataByCountryId(show_country_treasure_id)
    if serv_country_data then
        self.ip_treasure_slider.value = self:_CalculateTreasureSliderValue(show_country_treasure_id, occupy_pct_list, serv_country_data)
    else
        self.ip_treasure_slider.value = 0
    end
    -- 设置宝箱状态
    self:UpdateAllTreasureBox()
end

function StrategyMapUI:_CalculateTreasureSliderValue(country_id, occupy_pct_list, serv_country_data)
    local occupy_city_num = serv_country_data and serv_country_data.occupy_city_num or 0
    if occupy_city_num <= 0 then return 0 end
    local city_list = SpecMgrs.data_mgr:GetCityListByCountryId(country_id)
    local city_num = #city_list
    local cur_occupy_pct = occupy_city_num / city_num
    return UIFuncs.CalculateTreasureSliderValue(cur_occupy_pct, occupy_pct_list)
end

function StrategyMapUI:GetCountryTreasure(country_id, reward_index)
    local country_data = self.dy_strategy_data:GetCountryDataByCountryId(country_id)
    if country_data and country_data.reward_dict[reward_index] then
        SpecMgrs.msg_mgr:SendGetCountryOccupyReward({country_id = country_id, reward_index = reward_index},function(resp)
            if resp.errcode ~= 0 then
                PrintError("Get wrong errcode in SendSendGetCountryOccupyReward", country_id, reward_index)
            else
                UIFuncs.PlayOpenBoxAnim(self.country_treasure_go_list[reward_index])
                local reward_id = self.country_data_list[country_id].reward_list[reward_index]
                UIFuncs.ShowGetRewardItem(reward_id, true)
            end
        end)
    end
end

function StrategyMapUI:ConuntryTresureOnClick(reward_index)
    local country_id = self.cur_show_country_treasure_id
    local country_data = self.dy_strategy_data:GetCountryDataByCountryId(country_id)
    local reward_state = country_data and country_data.reward_dict and country_data.reward_dict[reward_index] or false
    reward_state = UIFuncs.TransRewardState(reward_state)
    local reward_id = self.country_data_list[country_id].reward_list[reward_index]
    UIFuncs.ShowTreasurePreview(reward_id, reward_state, function ()
        self:GetCountryTreasure(country_id, reward_index)
    end)
end

function StrategyMapUI:_UpdateIncomeRedPoint()
    local is_show_red_point = self.dy_strategy_data:CheckResourceFull()
    self.ip_red_point:SetActive(is_show_red_point)
    self.aip_red_point:SetActive(is_show_red_point)
end

function StrategyMapUI:NavToCurCity()
    if self.slider_target_pos or not self.cur_city_pos then return end
    self.slider_target_pos = self.cur_city_pos
    self.slider_original_pos = self.ip_scroll_rect.horizontalNormalizedPosition
end

-- AllIncomePanel

function StrategyMapUI:ShowAllIncomePanel()
    self.is_all_incom_panel_show = true
    self:_UpdateAllIncomePanel()
    self.all_income_panel:SetActive(true)
end

function StrategyMapUI:HideAllIncomePanel()
    self:ClearGoDict("aip_item_to_go")
    self.all_income_panel:SetActive(false)
    self.is_all_incom_panel_show = nil
end

function StrategyMapUI:_UpdateAllIncomePanel()
    if not self.is_all_incom_panel_show then return end
    local income_limit_rate = self.dy_strategy_data:GetIncomeLimitRate()
    local all_income_data = self.dy_strategy_data:GetAllIncomeData()
    local all_income_list = ItemUtil.ItemDictToItemDataList(all_income_data)
    local resource_dict = self.dy_strategy_data:GetResourceDict()
    local str_format = UIConst.Text.PER_VALUE
    local resource_num
    local resource_limit
    local cur_res_str
    local item_id
    local go
    self:ClearGoDict("aip_item_to_go")
    for _, item_info in ipairs(all_income_list) do
        item_id = item_info.item_id
        go = self:GetUIObject(self.aip_item_temp, self.aip_item_parent)
        self.aip_item_to_go[item_id] = go
        self:AssignSpriteByIconID(item_info.item_data.icon, go:FindChild("Icon/Image/Image"):GetComponent("Image"))
        resource_num = UIFuncs.AddCountUnit(resource_dict[item_id] or 0)
        resource_limit = UIFuncs.AddCountUnit(all_income_data[item_id] * income_limit_rate)
        cur_res_str = string.format(str_format, resource_num, resource_limit)
        go:FindChild("CurRes"):GetComponent("Text").text = cur_res_str
        go:FindChild("ResEachHour"):GetComponent("Text").text = UIFuncs.AddCountUnit(all_income_data[item_id])
    end
    local num = SpecMgrs.data_mgr:GetAllCityNum()
    self.aip_all_city_num_text.text = string.render(UIConst.Text.ALL_CITY_NUM, {s1 = num})
    num = self.dy_strategy_data:GetUnlockCityNum()
    self.aip_unlock_city_num_text.text = string.render(UIConst.Text.UNLOCK_CITY_NUM, {s1 = num})
    num = self.dy_strategy_data:GetManagedCityNum()
    self.aip_manager_city_num_text.text = string.render(UIConst.Text.MANAGED_CITY_NUM, {s1 = num})
    num = self.dy_strategy_data:GetNoManagerCityNum()
    self.aip_no_manager_city_num_text.text = string.render(UIConst.Text.NO_MANAGED_CITY_NUM, {s1 = num})
end

-- AllIncomePanel end

-- CityPreviewPanel
function StrategyMapUI:ShowCityPreviewPanel(city_id)
    if not city_id then return end
    self.show_cpp_city_id = city_id
    self:_UpdateCityPreviewPanel()
    self.city_preview_panel:SetActive(true)
end

function StrategyMapUI:HideCityPreviewPanel()
    self.show_cpp_city_id = nil
    self:ClearGoDict("cpp_item_list")
    self:ClearGoDict("cpp_star_list")
    self:ClearGoDict("cpp_star_row_list")
    self:ClearGoDict("cpp_hero_income_go_list")
    self:ClearUnitDict("cpp_unit_list")
    self:ClearUnit("cpp_boss_unit")
    self.city_preview_panel:SetActive(false)
end

function StrategyMapUI:_UpdateCityPreviewPanel()
    if not self.show_cpp_city_id then return end
    local city_id = self.show_cpp_city_id
    local city_data = self.city_data_list[city_id]
    local serv_city_data = self.dy_strategy_data:GetCityDataByCityId(city_id)
    local is_unlock = self.cur_city >= self.show_cpp_city_id
    local is_occupied = serv_city_data and serv_city_data.is_occupied and true or false
    local is_managed = serv_city_data and serv_city_data.manager_type and serv_city_data.manager_id and true or false
    local city_build_type_data = SpecMgrs.data_mgr:GetCityBuildTypeData(city_data.city_build_type)
    self:AssignSpriteByIconID(city_build_type_data.bg, self.cpp_city_bg_image)
    self.cpp_city_name_text.text = city_data.name

    local power_data = SpecMgrs.data_mgr:GetPowerData(city_data.power_id)
    local flag_id = self:GetCityFlagId(is_occupied, city_data, power_data)
    local flag_data = SpecMgrs.data_mgr:GetFlagData(flag_id)
    self.cpp_city_power_name_go:SetActive(not is_occupied)
    self:AssignSpriteByIconID(flag_data.icon, self.cpp_city_power_image)

    self.cpp_boss_part:SetActive(not is_occupied)
    self.cpp_manager_part:SetActive(is_occupied and is_managed)
    self.cpp_no_manager_part:SetActive(is_occupied and not is_managed)
    self.show_manager_ui_btn:SetActive(is_occupied)
    if not is_occupied then -- 未占领
        self.cpp_city_power_name_text.text = power_data.name
        self:_UpdateBoss()
    elseif is_managed then -- 占领管辖
        self:_UpdateManger(serv_city_data.manager_type, serv_city_data.manager_id, city_data)
    end
    local income_data = self.dy_strategy_data:GetCityIncomeData(city_id)
    local item_info_list = ItemUtil.ItemDictToItemDataList(income_data)
    local limit_rate = self.dy_strategy_data:GetIncomeLimitRate()
    for i, item_info in ipairs(item_info_list) do
        local item_id = item_info.item_id
        local go = self:GetUIObject(self.cpp_item_temp, self.cpp_item_parent)
        table.insert(self.cpp_item_list, go)
        local item_data = item_info.item_data
        self:AssignSpriteByIconID(item_data.icon, go:FindChild("Icon/Image"):GetComponent("Image"))
        local item_value = item_info.count
        go:FindChild("IncomeEachHour"):GetComponent("Text").text = item_value
        go:FindChild("MaxIncomeNum"):GetComponent("Text").text = item_value * limit_rate
    end
end

function StrategyMapUI:GetCityFlagId(is_occupied, city_data, power_data)
    local flag_id
    if is_occupied then
        flag_id = ComMgrs.dy_data_mgr:ExGetRoleFlag()
    else
        local power_data = power_data or SpecMgrs.data_mgr:GetPowerData(city_data.power_id)
        flag_id = power_data.flag_id
    end
    return flag_id
end

function StrategyMapUI:_UpdateManger(manager_type, manager_id, city_data)
    local manager_name
    self:ClearUnitDict("cpp_unit_list")
    if manager_type == CSConst.CityManager.Hero then
        local hero_data = SpecMgrs.data_mgr:GetHeroData(manager_id)
        manager_name = hero_data.name
        table.insert(self.cpp_unit_list, self:AddHalfUnit(hero_data.unit_id, self.cpp_hero_unit_parent))
    elseif manager_type == CSConst.CityManager.Child then
        local child_data = ComMgrs.dy_data_mgr.child_center_data:GetChildData(manager_id)
        local _, unit_list = ComMgrs.dy_data_mgr.child_center_data:GetChildUnitId(child_data)
        table.insert(self.cpp_unit_list, self:AddHalfUnit(unit_list[1], self.cpp_boy_unit_parent))
        table.insert(self.cpp_unit_list, self:AddHalfUnit(unit_list[2], self.cpp_girl_unit_parent))
        manager_name = child_data.name
    end
    self.cpp_manager_name_text.text = manager_name
    self.cpp_manager_story_text.text = city_data.desc
end

function StrategyMapUI:_UpdateBoss()
    if not self.show_cpp_city_id then return end
    local city_id = self.show_cpp_city_id
    local city_data = self.city_data_list[city_id]
    local boss_stage_list = SpecMgrs.data_mgr:GetCityBossStageListByCityId(city_id)
    local stage_data = SpecMgrs.data_mgr:GetStageData(boss_stage_list[#boss_stage_list])
    local monster_data, hero_data = MonsterUtil.GetMainMonsterData(stage_data.monster_group_id, stage_data.main_monster_index)
    self.cpp_boss_unit = self:AddHalfUnit(hero_data.unit_id, self.cpp_boss_unit_parent)
    self.cpp_suggest_sore_text.text = UIFuncs.GetMonsterGroupScoreSuggestStr(stage_data.monster_group_id, stage_data.monster_level)
    self.cpp_boss_story_text.text = city_data.desc
    self.cpp_boss_name_text.text = monster_data.name
end
-- CityPreviewPanel end

function StrategyMapUI:PlayCloudDisappearEffect()
    self.cloud_effect_go:SetActive(true)
    self.cloud_animator:Play("CloudDisappear")
    self:AddTimer(function ()
        if not IsNil(self.cloud_effect_go) then
            self.cloud_effect_go:SetActive(false)
        end
    end, kAnimTime)
end

function StrategyMapUI:PlayCloudAppearEffect(cb)
    self.cloud_effect_go:SetActive(true)
    self.cloud_animator:Play("CloudAppear")
    self:AddTimer(function ()
        if not self.is_res_ok then return end
        if cb then
            cb()
        end
        self:PlayCloudDisappearEffect()
    end, kAnimTime)
end

return StrategyMapUI
