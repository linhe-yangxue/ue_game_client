local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local FConst = require("CSCommon.Fight.FConst")
local SelectGrabPlayerUI = class("UI.SelectGrabPlayerUI", UIBase)

function SelectGrabPlayerUI:DoInit()
    SelectGrabPlayerUI.super.DoInit(self)
    self.prefab_path = "UI/Common/SelectGrabPlayerUI"
    self.change_grab_list_time = SpecMgrs.data_mgr:GetParamData("change_grab_role_time").f_value
    self.grab_treasure_cost_vitality = SpecMgrs.data_mgr:GetParamData("grab_treasure_cost_vitality").f_value
    self.player_item_list = {}
    self.player_hero_item_list = {}
    self.rate_data_list = SpecMgrs.data_mgr:GetAllRateData()
end

function SelectGrabPlayerUI:OnGoLoadedOk(res_go)
    SelectGrabPlayerUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function SelectGrabPlayerUI:Update(delta_time)
    if not self.change_grab_list_timer then return end
    self.change_grab_list_timer = self.change_grab_list_timer - delta_time
    if self.change_grab_list_timer <= 0 then
        self.change_grab_list_timer = nil
        self.change_btn_text.text = UIConst.Text.CHANGE_GRAB_PLAYER
    else
        self.change_btn_text.text = UIFuncs.TimeDelta2Str(self.change_grab_list_timer, 3)
    end
end

function SelectGrabPlayerUI:Show(param_tb)
    self.role_list = param_tb.role_list
    self.treasure_id = param_tb.treasure_id
    self.fragment_id = param_tb.fragment_id
    if self.is_res_ok then
        self:InitUI()
    end
    SelectGrabPlayerUI.super.Show(self)
end

function SelectGrabPlayerUI:InitRes()
    local top_menu_panel = self.main_panel:FindChild("TopBar")
    top_menu_panel:FindChild("Title"):GetComponent("Text").text = UIConst.Text.SELECT_GRAB_PLAYER
    self:AddClick(top_menu_panel:FindChild("CloseBtn"), function ()
        self:Hide()
    end)
    self.player_item_parent = self.main_panel:FindChild("Scroll View/Viewport/Content")
    self.player_item_temp = self.player_item_parent:FindChild("Item")
    self.player_item_temp:SetActive(false)
    self.player_hero_item_temp = self.player_item_temp:FindChild("Scroll View/Viewport/Content/Item")
    self.player_hero_item_temp:SetActive(false)
    self.player_item_temp:FindChild("BtnList/GrabFive/Text"):GetComponent("Text").text = UIConst.Text.GRAB_FIVE_TIME
    self.player_item_temp:FindChild("BtnList/GrabBtn/Text"):GetComponent("Text").text = UIConst.Text.GRAB
    local bottom_panel = self.main_panel:FindChild("BottomPanel")
    self.cur_vitality_text = bottom_panel:FindChild("CurVitality"):GetComponent("Text")
    self.vitality_cost_text = bottom_panel:FindChild("VitalityCost"):GetComponent("Text")
    local change_btn = bottom_panel:FindChild("ChangeBtn")
    self.change_btn_text = change_btn:FindChild("Text"):GetComponent("Text")
    self.change_btn_text.text = UIConst.Text.CHANGE_GRAB_PLAYER
    self:AddClick(change_btn, function ()
        self:ChangeGrabRoleListBtnOnClick()
    end)
end

function SelectGrabPlayerUI:InitUI()
    self:UpdateGrabPlayer()
    self:UpdateVitality()
    local item_id = CSConst.CostValueItem.Vitality
    local vitality_name = SpecMgrs.data_mgr:GetItemData(item_id).name
    self.vitality_cost_text.text = string.format(UIConst.Text.COST_VALUE, vitality_name, self.grab_treasure_cost_vitality)
    self:RegisterEvent(ComMgrs.dy_data_mgr, "UpdateItemDict", function (_, item_dict)
        local vitality_num = item_dict and item_dict[CSConst.Virtual.Vitality]
        if vitality_num then
            self:UpdateVitality(vitality_num)
        end
    end)
end

function SelectGrabPlayerUI:Hide()
    SelectGrabPlayerUI.super.Hide(self)
end

function SelectGrabPlayerUI:UpdateVitality(vitality_num)
    local item_id = CSConst.CostValueItem.Vitality
    local vitality_name = SpecMgrs.data_mgr:GetItemData(item_id).name
    local vitality_limit = SpecMgrs.data_mgr:GetParamData("vitality_limit").f_value
    local vitality_num = vitality_num or ComMgrs.dy_data_mgr:ExGetVitality()
    self.cur_vitality_text.text = string.format(UIConst.Text.CUR_VALUE_LIMIT, vitality_name, vitality_num, vitality_limit)
end

function SelectGrabPlayerUI:ChangeGrabRoleListBtnOnClick()
    if self.change_grab_list_timer then return end
    self.change_grab_list_timer = self.change_grab_list_time
    SpecMgrs.msg_mgr:SendGetGrabRoleList({treasure_id = self.treasure_id, fragment_id = self.fragment_id},function (resp)
        if resp.errcode ~= 0 then
            PrintError("Get wrong errcode in SendGetGrabRoleList", treasure_id, fragment_id)
            return
        end
        self.role_list = resp.role_list
        self:UpdateGrabPlayer()
        SpecMgrs.ui_mgr:ShowUI("GuideTipsUI", {str_list = {UIConst.Text.MATCH_PLAYER_SUCCEED}, pos = {0, 241}})
    end)
end

function SelectGrabPlayerUI:UpdateGrabPlayer()
    self:ClearGrabPlayer()
    local treasure_data = SpecMgrs.data_mgr:GetItemData(self.treasure_id)
    local quality_data = SpecMgrs.data_mgr:GetQualityData(treasure_data.quality)
    for i, role_data in ipairs(self.role_list) do
        local go = self:GetUIObject(self.player_item_temp, self.player_item_parent)
        go.name = i
        table.insert(self.player_item_list, go)
        go:FindChild("Scroll View/Name"):GetComponent("Text").text = role_data.name
        go:FindChild("Scroll View/Name/Lv"):GetComponent("Text").text = string.format(UIConst.Text.LEVEL, role_data.level)

        local rate_id = role_data.is_robot and quality_data.robot_rate_data or quality_data.player_rate_data
        local rate_data = self.rate_data_list[rate_id]
        go:FindChild("Scroll View/DropRate"):GetComponent("Text").text = string.format(UIConst.Text.SIMPLE_COLOR, rate_data.color, rate_data.name)
        local hero_parent = go:FindChild("Scroll View/Viewport/Content")
        for i, hero_id in ipairs(role_data.hero_list) do
            local hero_go = self:GetUIObject(self.player_hero_item_temp, hero_parent)
            table.insert(self.player_hero_item_list, hero_go)
            UIFuncs.InitHeroGo({go = hero_go, hero_id = hero_id})
        end
        local grab_five_btn = go:FindChild("BtnList/GrabFive")
        local is_show_grab_five_btn = role_data.is_robot and true or false
        grab_five_btn:SetActive(is_show_grab_five_btn)
        if is_show_grab_five_btn then
            self:AddClick(grab_five_btn, function ()
                if ComMgrs.dy_data_mgr:ExGetVitality() < self.grab_treasure_cost_vitality then
                    SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.GRAB_TREASURE_VITALITY_NOT_ENOUGH)
                    return
                end
                self:GrabFiveBtnOnClick(role_data.uuid)
            end)
        end
        self:AddClick(go:FindChild("BtnList/GrabBtn"), function()
            if ComMgrs.dy_data_mgr:ExGetVitality() < self.grab_treasure_cost_vitality then
                SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.GRAB_TREASURE_VITALITY_NOT_ENOUGH)
                return
            end
            self:GrabBtnOnClick(role_data)
        end)
    end
end

function SelectGrabPlayerUI:ClearGrabPlayer()
    for _, go in ipairs(self.player_hero_item_list) do
        self:DelUIObject(go)
    end
    self.player_hero_item_list = {}
    for _, go in ipairs(self.player_item_list) do
        self:DelUIObject(go)
    end
    self.player_item_list = {}
end

function SelectGrabPlayerUI:GrabBtnOnClick(role_data)
    SpecMgrs.msg_mgr:SendMsg("SendGrabTreasure", {uuid = role_data.uuid}, function (resp)
        if resp.is_success then
            self:Hide()
        end
        SpecMgrs.ui_mgr:EnterHeroBattle(resp.fight_data, UIConst.BattleScence.SelectGrabPlayerUI)
        SpecMgrs.ui_mgr:RegiseHeroBattleEnd("SelectGrabPlayerUI", function()
            local is_win = resp.is_win
            local param_tb = {
                is_win = is_win,
                reward = resp.reward_dict,
                target_player_name = role_data.name,
            }
            if is_win then
                SpecMgrs.ui_mgr:AddToPopUpList("BattleResultUI", param_tb)
                SpecMgrs.ui_mgr:AddCloseBattlePopUpList("SelectCardUI", {send_func_name = "SendGrabTreasureSelectReward"})
            else
                SpecMgrs.ui_mgr:AddCloseBattlePopUpList("BattleResultUI", param_tb)
            end
        end)
    end)
end

function SelectGrabPlayerUI:GrabFiveBtnOnClick(uuid)
    SpecMgrs.msg_mgr:SendMsg("SendGrabTreasureFiveTimes", {uuid = uuid}, function (resp)
        SpecMgrs.ui_mgr:ShowUI("GrabFiveResultUI", {result = resp.result, fragment_id = self.fragment_id})
        local is_hide_self = false
        for i ,v in ipairs(resp.result) do
            if v.is_success then
                is_hide_self = true
                break
            end
        end
        if is_hide_self then
            self:Hide()
        end
    end)
end

return SelectGrabPlayerUI