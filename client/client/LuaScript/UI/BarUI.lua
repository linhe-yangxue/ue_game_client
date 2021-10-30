local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local ItemUtil = require("BaseUtilities.ItemUtil")

local BarUI = class("UI.BarUI", UIBase)

local kEasyBarGameToggleTag = "EasyBarGame" -- 酒吧快速游戏设置

function BarUI:DoInit()
    BarUI.super.DoInit(self)
    self.prefab_path = "UI/Common/BarUI"
    self.dy_bar_data = ComMgrs.dy_data_mgr.bar_data
    self.bar_refresh_cost_item = SpecMgrs.data_mgr:GetParamData("bar_refresh_cost_item").item_id
    self.bar_type_data = {}
    self.hero_item_list = {}
    self.hero_unit_list = {}
end

function BarUI:OnGoLoadedOk(res_go)
    BarUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function BarUI:Hide()
    self:CleanCurBarState()
    self:RemoveLoverUnit()
    self:ClearHeroItemList()
    BarUI.super.Hide(self)
end

function BarUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    BarUI.super.Show(self)
end

function BarUI:InitRes()
    UIFuncs.GetInitTopBar(self, self.main_panel, "BarUI")

    local hero_panel = self.main_panel:FindChild("HeroPanel")
    self.bar_type_data[CSConst.BarType.Hero] = {}
    self.bar_type_data[CSConst.BarType.Hero].panel = hero_panel
    self.bar_type_data[CSConst.BarType.Hero].init_func = self.InitHeroPanel
    self.bar_type_data[CSConst.BarType.Hero].game_ui = "ArmWrestlingUI"
    self.bar_type_data[CSConst.BarType.Hero].name = UIConst.Text.HERO_BTN_NAME
    self.bar_type_data[CSConst.BarType.Hero].remind_tag = "RefreshBarHero"
    self.hero_list = hero_panel:FindChild("HeroList")
    self.hero_item = self.hero_list:FindChild("HeroItem")
    self.hero_item:SetActive(false)
    self.hero_empty_panel = hero_panel:FindChild("EmptyPanel")
    local hero_empty_desc = string.format(UIConst.Text.BAR_UNIT_EMPTY_TEXT, UIConst.Text.HERO_BTN_NAME)
    self.hero_empty_panel:FindChild("Dialog/Text"):GetComponent("Text").text = hero_empty_desc
    hero_panel:SetActive(false)

    local lover_panel = self.main_panel:FindChild("LoverPanel")
    self.bar_type_data[CSConst.BarType.Lover] = {}
    self.bar_type_data[CSConst.BarType.Lover].panel = lover_panel
    self.bar_type_data[CSConst.BarType.Lover].init_func = self.InitLoverPanel
    self.bar_type_data[CSConst.BarType.Lover].game_ui = "PouringWineUI"
    self.bar_type_data[CSConst.BarType.Lover].name = UIConst.Text.LOVER_BTN_NAME
    self.bar_type_data[CSConst.BarType.Lover].remind_tag = "RefreshBarLover"
    self.lover_info = lover_panel:FindChild("LoverInfo")
    self.lover_model = self.lover_info:FindChild("LoverModel")
    self.lover_name = self.lover_info:FindChild("Name/Text"):GetComponent("Text")
    self.lover_count = self.lover_info:FindChild("Count/Text"):GetComponent("Text")
    self.lover_grade = self.lover_info:FindChild("Grade"):GetComponent("Image")
    self.lover_empty_panel = lover_panel:FindChild("EmptyPanel")
    local lover_empty_desc = string.format(UIConst.Text.BAR_UNIT_EMPTY_TEXT, UIConst.Text.LOVER_BTN_NAME)
    self.lover_empty_panel:FindChild("Dialog/Text"):GetComponent("Text").text = lover_empty_desc
    lover_panel:SetActive(false)

    local hero_btn = self.main_panel:FindChild("HeroBtn")
    self.bar_type_data[CSConst.BarType.Hero].btn = hero_btn
    hero_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.HERO_BTN_NAME
    hero_btn:FindChild("Tip"):GetComponent("Text").text = UIConst.Text.CLICK_FOR_GOTO
    self:AddClick(hero_btn, function ()
        self:UpdateBarType(CSConst.BarType.Hero)
    end)
    local hero_disable = self.main_panel:FindChild("HeroDisable")
    self.bar_type_data[CSConst.BarType.Hero].disable = hero_disable
    hero_disable:FindChild("Text"):GetComponent("Text").text = UIConst.Text.HERO_BTN_NAME
    hero_disable:FindChild("Tip"):GetComponent("Text").text = UIConst.Text.CLICK_FOR_GOTO

    local lover_btn = self.main_panel:FindChild("LoverBtn")
    self.bar_type_data[CSConst.BarType.Lover].btn = lover_btn
    lover_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.LOVER_BTN_NAME
    lover_btn:FindChild("Tip"):GetComponent("Text").text = UIConst.Text.CLICK_FOR_GOTO
    self:AddClick(lover_btn, function ()
        self:UpdateBarType(CSConst.BarType.Lover)
    end)
    local lover_disable = self.main_panel:FindChild("LoverDisable")
    self.bar_type_data[CSConst.BarType.Lover].disable = lover_disable
    lover_disable:FindChild("Text"):GetComponent("Text").text = UIConst.Text.LOVER_BTN_NAME
    lover_disable:FindChild("Tip"):GetComponent("Text").text = UIConst.Text.CLICK_FOR_GOTO

    local bottom_panel = self.main_panel:FindChild("BottomPanel")
    self.refresh_count_down = bottom_panel:FindChild("RefreshCountDown")
    self.refresh_count_down_text = self.refresh_count_down:GetComponent("Text")
    self.refresh_time = bottom_panel:FindChild("RefreshTime"):GetComponent("Text")
    self.rest_refresh_count = bottom_panel:FindChild("RestRefreshCount"):GetComponent("Text")
    local refresh_btn = bottom_panel:FindChild("RefreshBtn")
    self:AddClick(refresh_btn, function ()
        self:SendRefreshBarUnit()
    end)
    refresh_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.REFLESH_TEXT
    self.material_panel = refresh_btn:FindChild("Material")
    UIFuncs.AssignSpriteByItemID(self.bar_refresh_cost_item, self.material_panel:FindChild("Icon"):GetComponent("Image"))
    self.refresh_material_count = self.material_panel:FindChild("Count"):GetComponent("Text")
    self.game_toggle = bottom_panel:FindChild("GameToggle")
    self.game_toggle:FindChild("Label"):GetComponent("Text").text = UIConst.Text.EASY_CHALLENGE_TEXT
    self.game_toggle_cmp = self.game_toggle:GetComponent("Toggle")
    self:AddToggle(self.game_toggle, function (is_on)
        ComMgrs.dy_data_mgr:ExSetToggleStateByTag(kEasyBarGameToggleTag, is_on)
    end)
    local game_count_panel = bottom_panel:FindChild("GameCount")
    self.game_count = game_count_panel:FindChild("Count"):GetComponent("Text")
    self:AddClick(game_count_panel:FindChild("AddBtn"), function ()
        self.dy_bar_data:SendBuyGameCount(self.cur_bar_type)
    end)
end

function BarUI:InitUI()
    self:InitBarInfo()
    self:UpdateBarType(CSConst.BarType.Hero)
    self:RegisterEvent(self.dy_bar_data, "UpdateBarUnitEvent", function ()
        self.bar_type_data[self.cur_bar_type].init_func(self)
    end)
    self:RegisterEvent(self.dy_bar_data, "UpdateBarGameCountEvent", function ()
        self:UpdateGameCount()
    end)
    self:RegisterEvent(ComMgrs.dy_data_mgr.vip_data, "UpdateVipInfo", function (_, vip_info)
        if vip_info.vip_level then self:UpdateGameCount() end
    end)
end

function BarUI:InitBarInfo()
    local quick_challenge_unlock = ComMgrs.dy_data_mgr.func_unlock_data:IsFuncUnlock(CSConst.FuncUnlockId.BarQuickChallenge)
    self.game_toggle:SetActive(quick_challenge_unlock == true)
    if quick_challenge_unlock == true then
        self.game_toggle_cmp.isOn = ComMgrs.dy_data_mgr:ExGetToggleStateByTag(kEasyBarGameToggleTag) == true
    end
    local next_refresh_sec = self.dy_bar_data:GetNextRefreshTime()
    self:AddDynamicUI(self.refresh_count_down, function ()
        local count_down_str = UIFuncs.TimeDelta2Str(next_refresh_sec - Time:GetServerTime())
        self.refresh_count_down_text.text = string.format(UIConst.Text.BAR_UNIT_REFRESH_TIME_FORMAT, count_down_str)
    end, 1, 0)
    local time_str = ""
    local bar_refresh_time_list = SpecMgrs.data_mgr:GetParamData("bar_refresh_time_list").tb_int
    local refresh_time_count = #bar_refresh_time_list
    for i, time in ipairs(bar_refresh_time_list) do
        local refresh_time_str = string.format(UIConst.Text.HOUR_TIME_FORMAT, time)
        time_str = time_str .. refresh_time_str
        if i < refresh_time_count then time_str = time_str .. UIConst.Text.COMMA end
    end
    self.refresh_time.text = string.format(UIConst.Text.BAR_UNIT_REFRESH_TIP_FORMAT, time_str)
end

function BarUI:UpdateGameCount()
    local rest_refresh_count = self.dy_bar_data:GetRestRefreshCount(self.cur_bar_type) or 0
    self.rest_refresh_count.text = string.format(UIConst.Text.LAST_REFRESH_TIME_FORMAT, rest_refresh_count)
    self.material_panel:SetActive(rest_refresh_count > 0)
    if rest_refresh_count > 0 then
        self.refresh_material_count.text = self.dy_bar_data:CalcRefreshCost(self.cur_bar_type)
    end
    local game_count = self.dy_bar_data:GetGameCountByBarType(self.cur_bar_type)
    self.game_count.text = string.format(UIConst.Text.BAR_GAME_COUNT_FORMAT, game_count)
end

function BarUI:UpdateBarType(bar_type)
    if self.cur_bar_type == bar_type then return end
    self:CleanCurBarState()
    self.cur_bar_type = bar_type
    local cur_bar_type_data = self.bar_type_data[self.cur_bar_type]
    cur_bar_type_data.disable:SetActive(true)
    cur_bar_type_data.btn:SetActive(false)
    cur_bar_type_data.init_func(self)
    self:UpdateGameCount()
    cur_bar_type_data.panel:SetActive(true)
end

function BarUI:CleanCurBarState()
    if self.cur_bar_type then
        local cur_bar_type_data = self.bar_type_data[self.cur_bar_type]
        cur_bar_type_data.disable:SetActive(false)
        cur_bar_type_data.btn:SetActive(true)
        cur_bar_type_data.panel:SetActive(false)
        self.cur_bar_type = nil
    end
end

function BarUI:InitHeroPanel()
    self:ClearHeroItemList()
    local hero_list = self.dy_bar_data:GetBarHeroList()
    local have_bar_hero = hero_list ~= nil and #hero_list > 0
    if have_bar_hero then
        for _, hero in ipairs(hero_list) do
            local hero_data = SpecMgrs.data_mgr:GetHeroData(hero.hero_id)
            local quality_data = SpecMgrs.data_mgr:GetQualityData(hero_data.quality)
            local hero_item = self:GetUIObject(self.hero_item, self.hero_list)
            table.insert(self.hero_item_list, hero_item)
            local hero_model = hero_item:FindChild("Model")
            local hero_unit = self:AddFullUnit(hero_data.unit_id, hero_model)
            table.insert(self.hero_unit_list, hero_unit)
            hero_item:FindChild("Name/Text"):GetComponent("Text").text = hero_data.name
            hero_item:FindChild("Count/Text"):GetComponent("Text").text = string.format(UIConst.Text.BAR_CHALLENGE_COUNT_FORMAT, hero.count)
            UIFuncs.AssignSpriteByIconID(quality_data.grade, hero_item:FindChild("Grade"):GetComponent("Image"))
            self:AddClick(hero_model, function ()
                self:SendStartBarGame({hero_id = hero.hero_id}, hero.hero_id)
            end)
        end
    end
    self.hero_list:SetActive(have_bar_hero)
    self.hero_empty_panel:SetActive(not have_bar_hero)
end

function BarUI:ClearHeroItemList()
    for _, unit in ipairs(self.hero_unit_list) do
        self:RemoveUnit(unit)
    end
    self.hero_unit_list = {}
    for _, item in ipairs(self.hero_item_list) do
        self:DelUIObject(item)
    end
    self.hero_item_list = {}
end

function BarUI:InitLoverPanel()
    self:RemoveLoverUnit()
    local lover_id, count = self.dy_bar_data:GetBarLoverInfo()
    local have_bar_lover = lover_id ~= nil and count > 0
    if have_bar_lover then
        local lover_data = SpecMgrs.data_mgr:GetLoverData(lover_id)
        local quality_data = SpecMgrs.data_mgr:GetQualityData(lover_data.quality)
        self.lover_unit = self:AddFullUnit(lover_data.unit_id, self.lover_model)
        self.lover_name.text = lover_data.name
        self.lover_count.text = string.format(UIConst.Text.BAR_CHALLENGE_COUNT_FORMAT, count)
        UIFuncs.AssignSpriteByIconID(quality_data.grade, self.lover_grade)
        self:AddClick(self.lover_model, function ()
            self:SendStartBarGame({lover_id = lover_id}, lover_id)
        end)
    end
    self.lover_info:SetActive(have_bar_lover)
    self.lover_empty_panel:SetActive(not have_bar_lover)
end

function BarUI:RemoveLoverUnit()
    if self.lover_unit then
        self:RemoveUnit(self.lover_unit)
        self.lover_unit = nil
    end
end

-- msg
function BarUI:SendStartBarGame(msg_data, id)
    if not self.dy_bar_data:CheckGameCount(self.cur_bar_type) then return end
    if ComMgrs.dy_data_mgr:ExGetToggleStateByTag(kEasyBarGameToggleTag) == true then
        SpecMgrs.msg_mgr:SendBarQuickChallenge(msg_data, function (resp)
            if resp.errcode ~= 0 then
                SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.BAR_QUICK_CHALLENGE_FAILED)
            else
                if resp.item_dict then
                    local item_list = ItemUtil.ItemDictToItemDataList(resp.item_dict, true)
                    SpecMgrs.ui_mgr:ShowGetItemUI(item_list, UIConst.Text.EASY_CHALLENGE_TEXT)
                end
            end
        end)
    else
        SpecMgrs.msg_mgr:SendCheckCanJoinBarGame(msg_data, function (resp)
            if resp.errcode ~= 0 then
                SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.JOIN_BAR_GAME_FAILED)
            else
                SpecMgrs.ui_mgr:ShowUI(self.bar_type_data[self.cur_bar_type].game_ui, id)
            end
        end)
    end
end

function BarUI:SendRefreshBarUnit()
    local bar_type_data = self.bar_type_data[self.cur_bar_type]
    local cost_count = self.dy_bar_data:CalcRefreshCost(self.cur_bar_type)
    if not cost_count or cost_count <= 0 then
        SpecMgrs.ui_mgr:ShowTipMsg(string.format(UIConst.Text.REFRESH_BAR_UNIT_LIMIT, bar_type_data.name))
        return
    end

    local confirm_cb = function ()
        SpecMgrs.msg_mgr:SendRefreshBarUnit({bar_type = self.cur_bar_type}, function (resp)
            if resp.errcode ~= 0 then
                SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.REFRESH_BAR_UNIT_FAILED)
            end
        end)
    end
    local cost_item_name = UIFuncs.GetItemName({item_id = self.bar_refresh_cost_item})
    local desc = string.format(UIConst.Text.REFRESH_BAR_UNIT_SUBMIT, cost_item_name, cost_count, bar_type_data.name)
    SpecMgrs.ui_mgr:ShowItemUseRemindByTb({
        item_id = self.bar_refresh_cost_item,
        need_count = cost_count,
        confirm_cb = confirm_cb,
        desc = desc,
        title = UIConst.Text.REFRESH_BAR_UNIT_TEXT,
        is_show_tip = true,
        remind_tag = bar_type_data.remind_tag,
    })
end

return BarUI