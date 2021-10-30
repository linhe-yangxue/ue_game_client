local UIBase = require("UI.UIBase")
local UIFuncs = require("UI.UIFuncs")
local UIConst = require("UI.UIConst")
local UnitConst = require("Unit.UnitConst")
local HonorTitlePanel = require("UI.ChurchUI.HonorTitlePanel")
local TitleScrollViewPanel = require("UI.ChurchUI.TitleScrollViewPanel")
local HistoryPanel = require("UI.ChurchUI.HistoryPanel")

local role_model_distance = 750

local ChurchUI = class("UI.ChurchUI.ChurchUI", UIBase)

function ChurchUI:DoInit()
    ChurchUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ChurchUI"
    self.is_left_btn_active = true
    self.is_right_btn_active = true
    self.current_index = nil
    self._ticker_list = {}
end

function ChurchUI:OnGoLoadedOk(res_go)
    ChurchUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function ChurchUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    ChurchUI.super.Show(self)
end

function ChurchUI:Hide()
    if self.ticker then
        self:RemoveTicker(self.ticker)
    end
    self:ResetAnimation()
    self.honor_title_panel:ResetAnimation()
    self.title_scrollveiw_panel:ResetAnimation()
    self.history_panel:Hide()
    self._ticker_list = {}
    ChurchUI.super.Hide(self)
end

function ChurchUI:InitRes()
    ----FindChild begin----
    self.topbar_parent = self.main_panel:FindChild("TopBarParent")
    self.honorInfo_txt = self.main_panel:FindChild("MiddlePanel/HonorInfoText"):GetComponent("Text")
    self.role_model_1 = self.main_panel:FindChild("MiddlePanel/RolePanel/RoleModel1")
    self.role_model_1_rect = self.role_model_1:GetComponent("RectTransform")
    self.default_img_1 = self.role_model_1:FindChild("DefaultImg1")
    self.shadow_img_1 = self.role_model_1:FindChild("Shadow")
    self.role_model_2 = self.main_panel:FindChild("MiddlePanel/RolePanel/RoleModel2")
    self.role_model_2_rect = self.role_model_2:GetComponent("RectTransform")
    self.default_img_2 = self.role_model_2:FindChild("DefaultImg2")
    self.shadow_img_2 = self.role_model_2:FindChild("Shadow")
    self.history_btn = self.main_panel:FindChild("MiddlePanel/HistoryBtn")
    self.left_btn = self.main_panel:FindChild("MiddlePanel/LeftBtn")
    self.right_btn = self.main_panel:FindChild("MiddlePanel/RightBtn")
    self.honorTitlePanel = self.main_panel:FindChild("MiddlePanel/HonorTitlePanel")
    self.titleScrollViewPanel = self.main_panel:FindChild("MiddlePanel/TitleScrollViewPanel")
    self.historyPanel = self.main_panel:FindChild("HistoryPanel")
    self.level_txt = self.main_panel:FindChild("BottomPanel/TextPanel/DynamicText/LevelText"):GetComponent("Text")
    self.reward_item_icon = self.main_panel:FindChild("BottomPanel/TextPanel/DynamicText/RewardItemIcon"):GetComponent("Image")
    self.reward_count_txt = self.main_panel:FindChild("BottomPanel/TextPanel/DynamicText/RewardCountText"):GetComponent("Text")
    self.worship_btn = self.main_panel:FindChild("BottomPanel/WorshipBtn")
    self.isDone_img = self.main_panel:FindChild("BottomPanel/IsDoneImg")
    self.history_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ChurchUIHistoryBtn
    self.main_panel:FindChild("BottomPanel/TextPanel/StaticText"):GetComponent("Text").text = UIConst.Text.ChurchUIStaticText
    self.main_panel:FindChild("BottomPanel/TextPanel/DynamicText/LevelTitle"):GetComponent("Text").text = UIConst.Text.ChurchUILevelTitle
    self.main_panel:FindChild("BottomPanel/TextPanel/DynamicText/RewardTitle"):GetComponent("Text").text = UIConst.Text.ChurchUIRewardTitle
    self.worship_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ChurchUIWorshipBtn
    ----FindChild end----
    ----AddListener begin----
    self:AddClick(self.history_btn, function()
        self:_HistoryBtnListener()
    end)
    self:AddClick(self.left_btn, function ()
        self:_LeftBtnListener()
    end)
    self:AddClick(self.right_btn, function ()
        self:_RightBtnListener()
    end)
    self:AddClick(self.worship_btn, function ()
        self:_WorshipBtnListener()
    end)
    ----AddListener end----
    UIFuncs.GetInitTopBar(self, self.topbar_parent, "ChurchUI")

    self.honor_title_panel = HonorTitlePanel.New()
    self.honor_title_panel:InitRes(self.honorTitlePanel, self)
    
    self.title_scrollveiw_panel = TitleScrollViewPanel.New()
    self.title_scrollveiw_panel:InitRes(self.titleScrollViewPanel, self, self)

    self.history_panel = HistoryPanel.New()
    self.history_panel:InitRes(self.historyPanel, self)

    self.role_tb_1 = {rect = self.role_model_1_rect, role = self.role_model_1, default = self.default_img_1, shadow = self.shadow_img_1}
    self.role_tb_2 = {rect = self.role_model_2_rect, role = self.role_model_2, default = self.default_img_2, shadow = self.shadow_img_2}
end

function ChurchUI:InitUI()
    ComMgrs.dy_data_mgr.church_data:GetChurchData(function()
        local current_level = ComMgrs.dy_data_mgr:ExGetMainRoleInfoData().level
        local reward_id = SpecMgrs.data_mgr:GetLevelData(current_level).worship_godfather_reward
        local reward_data = SpecMgrs.data_mgr:GetRewardData(reward_id)
        local reward_item_icon_id = SpecMgrs.data_mgr:GetItemData(reward_data.reward_item_list[1]).icon
        self.level_txt.text = current_level
        self.reward_count_txt.text = reward_data.reward_num_list[1]
        UIFuncs.AssignSpriteByIconID(reward_item_icon_id, self.reward_item_icon)
        local is_worshiped = ComMgrs.dy_data_mgr.church_data:GetIsWorshiped()
        self.isDone_img:SetActive(is_worshiped)
        self.worship_btn:SetActive(not is_worshiped)
        self.title_scrollveiw_panel:Init()
    end)
end

----ButtonListener begin----
function ChurchUI:_HistoryBtnListener()
    self.history_panel:Show(self.current_index)
end

function ChurchUI:_LeftBtnListener()
    self.title_scrollveiw_panel:Switch(-1)
end

function ChurchUI:_RightBtnListener()
    self.title_scrollveiw_panel:Switch(1)
end

function ChurchUI:_WorshipBtnListener()
    local cb = function(response)
        if response.errcode ~= 0 then
            return
        end
        self.isDone_img:SetActive(true)
        self.worship_btn:SetActive(false)
    end
    ComMgrs.dy_data_mgr.church_data:WorshipGodfather(cb)
end
----ButtonListener end----

function ChurchUI:ShowTitleInfo(index, title_id, direction)
    if direction == 0 then
        return
    end
    if direction > 0 then
        direction = -1
    else
        direction = 1
    end
    self.current_index = index
    self.honor_title_panel:UpdateTitleId(title_id, direction)
    self:_SwitchRoleModelAnimation(title_id, direction)
    local item_data = SpecMgrs.data_mgr:GetItemData(title_id)
    self.honorInfo_txt.text = item_data.desc or ""
end

function ChurchUI:UpdateLeftRightBtn(left, right)
    if self.is_left_btn_active ~= left then
        self.left_btn:SetActive(left)
        self.is_left_btn_active = left
    end
    if self.is_right_btn_active ~= right then
        self.right_btn:SetActive(right)
        self.is_right_btn_active = right
    end
end

function ChurchUI:_SwitchRoleModelAnimation(title_id, direction)
    local func = function(delta)
        if IsNil(self.go) then
            return false
        end
        self.role_tb_1.rect.anchoredPosition = Vector2.New(-direction * delta * role_model_distance, 0)
        self.role_tb_2.rect.anchoredPosition = Vector2.New(direction * (1 - delta) * role_model_distance, 0)
        return true
    end
    local title_data = ComMgrs.dy_data_mgr.church_data:GetTitleDataById(title_id)
    local current_roleid = title_data.current_roleid
    if self.ticker then
        self:RemoveTicker(self.ticker)
        self:ResetAnimation()
    end
    if current_roleid then
        local unit_id = SpecMgrs.data_mgr:GetRoleLookData(current_roleid).unit_id
        self.role_tb_2.role_unit = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = unit_id, parent = self.role_tb_2.role})
        self.role_tb_2.role_unit:SetPositionByRectName({parent = self.role_tb_2.role, name = UnitConst.UnitRect.Full})
        self.role_tb_2.default:SetActive(false)
        self.role_tb_2.shadow:SetActive(true)
    else
        self.role_tb_2.default:SetActive(true)
        self.role_tb_2.shadow:SetActive(false)
    end
    self.ticker = self:AddTicker(0.2, func, function()
        self:ResetAnimation()
    end)
end

function ChurchUI:ResetAnimation()
    self.role_tb_1.rect.anchoredPosition = Vector2.New(role_model_distance, 0)
    self.role_tb_2.rect.anchoredPosition = Vector2.New(0, 0)
    if self.role_tb_1.role_unit then
        ComMgrs.unit_mgr:DestroyUnit(self.role_tb_1.role_unit)
        self.role_tb_1.role_unit = nil
    end
    self.role_tb_1, self.role_tb_2 = self.role_tb_2, self.role_tb_1
    self.ticker = nil
end

function ChurchUI:Update()
    local alive_tickers = {}
    local now = SpecMgrs.timer_mgr:Now()
    for _, ticker in ipairs(self._ticker_list) do
        if not ticker.is_delete then
            if ticker.begin_time + ticker.duration >= now then
                local param = (now - ticker.begin_time) / ticker.duration
                if ticker.func(param) then
                    table.insert(alive_tickers, ticker)
                end
            else
                ticker.func(1)
                if ticker.finish_func then
                    ticker.finish_func()
                end
            end
        end
    end
    self._ticker_list = alive_tickers
end

--在sec_time秒内每帧调用一次func(),参数为(当前时间-开始时间)/持续时间,若func返回false或nil则立刻移除该Ticker,否则在Ticker正常结束后会调用一次finish_func
--sec_time:持续时间，不能为空！ func:持续时间内反复调用的方法，不能为空！ finish_func:结束后调用的方法，可以为空
function ChurchUI:AddTicker(sec_time, func, finish_func)
    if not func then
        return
    end
    local msec_time = math.max(0, math.ceil(sec_time * 1000))
    local new_ticker = {duration = msec_time, begin_time = SpecMgrs.timer_mgr:Now(), func = func, finish_func = finish_func}
    table.insert(self._ticker_list, new_ticker)
    return new_ticker
end

function ChurchUI:RemoveTicker(ticker)
    ticker.is_delete = true
end

return ChurchUI
