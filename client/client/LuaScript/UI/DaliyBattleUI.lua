local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local DaliyBattleUI = class("UI.DaliyBattleUI",UIBase)
local UnitConst = require("Unit.UnitConst")
local UIFuncs = require("UI.UIFuncs")

local kSliderToNextFactor = 0.1 -- 滑动英雄超过屏幕的0.1就滑向下一个英雄
local kSliderTime = 0.2
local StageLength = 22
local StageMinMoveDis = 20

-- 日常挑战
function DaliyBattleUI:DoInit()
    DaliyBattleUI.super.DoInit(self)
    self.prefab_path = "UI/Common/DaliyBattleUI"
end

function DaliyBattleUI:OnGoLoadedOk(res_go)
    DaliyBattleUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function DaliyBattleUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    DaliyBattleUI.super.Show(self)
end

function DaliyBattleUI:InitRes()
    self:InitTopBar()
    self.enter_btn = self.main_panel:FindChild("MiddleMesFrame/EnterBtn")
    self:AddClick(self.enter_btn, function()
        local data = self.stage_data_list[self.cur_select_index]
        if data.is_open then
            SpecMgrs.ui_mgr:ShowUI("DaliyBattleChooseLevelUI", data.dare_data, data.dare_info)
        else
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.NOT_OPEN_TIP)
        end
    end)
    self.enter_btn_text = self.main_panel:FindChild("MiddleMesFrame/EnterBtn/EnterBtnText"):GetComponent("Text")
    self.stage_content = self.main_panel:FindChild("MiddleMesFrame/StageScrollView/Viewport/Content")
    self.stage_viewport = self.main_panel:FindChild("MiddleMesFrame/StageScrollView/Viewport")
    self.stage_scroll_view = self.main_panel:FindChild("MiddleMesFrame/StageScrollView")

    self.stage_content_rect = self.stage_content:GetComponent("RectTransform")

    self.consume_action_text = self.main_panel:FindChild("MiddleMesFrame/ConsumeActionText"):GetComponent("Text")
    self.unit_pos = self.main_panel:FindChild("MiddleMesFrame/UnitPos")
    self.stage_temp = self.main_panel:FindChild("Temp/Stage")
    self.gray_material = SpecMgrs.res_mgr:GetMaterialSync(UIConst.MaterialResPath.UIGray)

    self.finish_dare = self.main_panel:FindChild("MiddleMesFrame/FinishDare")
    self.finish_dare_text = self.main_panel:FindChild("MiddleMesFrame/FinishDare/FinishDareText"):GetComponent("Text")

    self.hero_scroll_rect = self.main_panel:FindChild("MiddleMesFrame/HeroScrollView"):GetComponent("ScrollRect")
    self.hero_viewport = self.main_panel:FindChild("MiddleMesFrame/HeroScrollView/Viewport/Content")
    self.hero_temp = self.main_panel:FindChild("Temp/HeroItem")
    local rect = self.main_panel:FindChild("MiddleMesFrame/HeroScrollView/Viewport"):GetComponent("RectTransform").rect
    self.hero_temp:GetComponent("RectTransform").sizeDelta = Vector2.New(rect.width, rect.height)
    self.hero_temp:SetActive(false)
    self.hero_viewport_width = rect.width

    self.stage_width = self.stage_temp:GetComponent("RectTransform").rect.width + StageLength
    self.stage_content_width = self.stage_viewport:GetComponent("RectTransform").rect.width
end

function DaliyBattleUI:InitUI()
    self.hero_viewport:GetComponent("RectTransform").anchoredPosition = Vector3.zero
    self:SetTextVal()
    self:UpdateData()
    self:UpdateUIInfo()
    self.cur_select_index = 0
    self:ClickStageObj(self.stage_obj_list[1])

    ComMgrs.dy_data_mgr.daily_dare_data:RegisterUpdateDailyDareData("DaliyBattleUI", function()
        self:DestroyAllUnit()
        self:DelObjDict(self.unit_list)
        self:DelObjDict(self.stage_obj_list)
        if self.talk_list then
            for i,v in ipairs(self.talk_list) do
                v:DoDestroy()
            end
        end
        self:InitUI()
    end)
end

function DaliyBattleUI:UpdateData()
    self.open_dare_dict = ComMgrs.dy_data_mgr.daily_dare_data:GetOpenDareList()
    self.not_open_dare_dict = ComMgrs.dy_data_mgr.daily_dare_data:GetNotOpenList()
    self.cur_select_index = 0
    self.can_drag = true
    self.cur_seat_index = 1
    self.slider_x_offset = 0
    self.max_hero_scroll_pos = 0
    self.seat_to_pos = {}
    self.max_hero_index = 0
    self.slider_target_pos = nil
    self.slider_timer = 0

    self.stage_slider_timer = 0
    self.stage_start_pos = nil
    self.stage_target_pos = nil
    self.is_drag_hero_slider = false
end

function DaliyBattleUI:Update(delta_time)
    if not self.is_res_ok or not self.is_visible then return end
    if self.slider_target_pos then
        self.slider_timer = self.slider_timer + delta_time
        local cur_pos
        if self.slider_timer >= kSliderTime then
            self.is_drag_hero_slider = false
            self.slider_timer = 0
            cur_pos = self.slider_target_pos
            self.slider_target_pos = nil
            self.hero_rect_original_pos = nil
            local item = self.unit_list[self.cur_select_index]
            item:FindChild("TalkParent"):SetActive(true)
            if self.last_select_index ~= 0 then
                local item = self.unit_list[self.last_select_index]
                item:FindChild("TalkParent"):SetActive(false)
            end
        else
            self.is_drag_hero_slider = true
            cur_pos = math.lerp(self.hero_rect_original_pos, self.slider_target_pos, self.slider_timer / kSliderTime)
        end
        self.hero_scroll_rect.horizontalNormalizedPosition = cur_pos
    end

    if self.stage_target_pos then
        self.stage_slider_timer = self.stage_slider_timer + delta_time
        local cur_pos
        if self.stage_slider_timer >= kSliderTime then
            self.stage_slider_timer = 0
            cur_pos = self.stage_target_pos
            self.stage_target_pos = nil
            self.stage_start_pos = nil
        else
            cur_pos = math.lerp(self.stage_start_pos, self.stage_target_pos, self.stage_slider_timer / kSliderTime)
        end
        self.stage_content_rect.anchoredPosition = cur_pos
    end
end

function DaliyBattleUI:UpdateUIInfo()
    self.stage_content_rect.anchoredPosition = Vector3.zero
    self.stage_temp:SetActive(false)
    self.stage_obj_list = {}
    self.stage_data_list = {}
    self.unit_list = {}
    self.talk_list = {}

    local all_dare_data = SpecMgrs.data_mgr:GetAllDailyDareData()

    local today_open_list = {}
    local today_not_open_list = {}
    for i, data in ipairs(all_dare_data) do
        if self:IsInOpenDate(data.open_date) then
            table.insert(today_open_list, data)
        else
            table.insert(today_not_open_list, data)
        end
    end

    for i, data in ipairs(today_open_list) do
        if self:IsInOpen(data.dare_id) then
            local stage_obj = self:GetUIObject(self.stage_temp, self.stage_content)
            self:AddToStageObjList(stage_obj, data.dare_id, true, self:GetDareInfo(data.dare_id))
        else
            local stage_obj = self:GetUIObject(self.stage_temp, self.stage_content)
            self:AddToStageObjList(stage_obj, data.dare_id, false, self:GetDareInfo(data.dare_id))
        end
    end

    for i, data in ipairs(today_not_open_list) do
        local stage_obj = self:GetUIObject(self.stage_temp, self.stage_content)
        self:AddToStageObjList(stage_obj, data.dare_id, false, self:GetDareInfo(data.dare_id))
    end

    self.max_hero_index = #self.stage_obj_list
    self.max_hero_scroll_pos = (self.max_hero_index - 1) * self.hero_viewport_width -- 默认情况 每个英雄之间间隙为0 不用计算
    for seat_index = 1, self.max_hero_index do
        self.seat_to_pos[seat_index] = (seat_index - 1) * self.hero_viewport_width / self.max_hero_scroll_pos
    end
end

function DaliyBattleUI:OnDrag(delta, position)
    self.slider_x_offset = self.slider_x_offset + delta.x
    local _, pos = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(self.hero_viewport:GetComponent("RectTransform"), position, self.canvas.worldCamera)
    local norimalize_pos = self.hero_scroll_rect.horizontalNormalizedPosition - delta.x / self.max_hero_scroll_pos
    self.hero_scroll_rect.horizontalNormalizedPosition = math.clamp(norimalize_pos, 0, 1)
    self.is_drag_hero_slider = true
end

function DaliyBattleUI:OnRelease()
    if math.abs(self.slider_x_offset) >= self.hero_viewport_width * kSliderToNextFactor then
        local index = self.slider_x_offset > 0 and self.cur_seat_index - 1 or self.cur_seat_index + 1
        self:SliderToIndex(index)
        index = math.clamp(index, 1, self.max_hero_index)
        self:ClickStageObj(self.stage_obj_list[index])
    else
        self:SliderToIndex(self.cur_seat_index)
    end
    self.slider_x_offset = 0
end

function DaliyBattleUI:SliderToIndex(index)
    self.cur_seat_index = index
    self.slider_target_pos = self.seat_to_pos[index]
    self.hero_rect_original_pos = self.hero_scroll_rect.horizontalNormalizedPosition
end

function DaliyBattleUI:AddToStageObjList(stage_obj, dare_id, is_open, dare_info)
    local data =
    {
        dare_data = SpecMgrs.data_mgr:GetDailyDareData(dare_id),
        is_open = is_open,
        dare_info = dare_info,
    }
    table.insert(self.stage_obj_list, stage_obj)
    table.insert(self.stage_data_list, data)
    self:SetStageUIInfo(stage_obj, dare_id, is_open, dare_info.is_passing)
    local obj = self:GetUIObject(self.hero_temp, self.hero_viewport)

    self:AddDrag(obj, function (delta, position)
        self:OnDrag(delta, position)
    end)

    self:AddRelease(obj, function ()
        self:OnRelease()
    end)
    local size = SpecMgrs.data_mgr:GetParamData("daily_challenge_role_size").f_value
    local unit = self:AddUnit(data.dare_data.show_role, obj:FindChild("HeroPos"), Vector3.zero, size)
    if not is_open then
        unit:ChangeToGray()
    end
    local talk = self:GetTalkCmp(obj:FindChild("TalkParent"), 1, false, function ()
        return data.dare_data.dialog
    end)
    table.insert(self.talk_list, talk)
    table.insert(self.unit_list, obj)
end

function DaliyBattleUI:SetStageUIInfo(stage_obj, dare_id, is_open, is_passing)
    local condition_text = stage_obj:FindChild("OpenConditionText")
    local today_open_text = stage_obj:FindChild("TodayOpenText")
    local dare_data = SpecMgrs.data_mgr:GetDailyDareData(dare_id)
    stage_obj:FindChild("SelectImage"):SetActive(false)
    if is_open then
        today_open_text:SetActive(true)
        today_open_text:GetComponent("Text").text = UIConst.Text.TODAY_OPEN_TEXT
        condition_text:SetActive(false)
        stage_obj:FindChild("Mask"):SetActive(false)
        stage_obj:FindChild("LockImage"):SetActive(false)
    else
        today_open_text:SetActive(false)
        condition_text:SetActive(true)
        stage_obj:FindChild("Mask"):SetActive(true)
        stage_obj:FindChild("LockImage"):SetActive(true)

        if not self:IsInOpenDate(dare_data.open_date) then
            local str = self:GetOpenDateStr(dare_data.open_date)
            condition_text:GetComponent("Text").text = string.format(UIConst.Text.OPEN_TIME_FORMAT, str)
        else
            local open_level = dare_data.open_level[1]
            condition_text:GetComponent("Text").text = string.format(UIConst.Text.LEVEL_LOCK_FORMAT, open_level)
        end
    end
    if is_passing then
        stage_obj:FindChild("FinishImage"):SetActive(true)
    else
        stage_obj:FindChild("FinishImage"):SetActive(false)
    end
    stage_obj:FindChild("AwardText"):GetComponent("Text").text = SpecMgrs.data_mgr:GetItemData(dare_data.drop_item).name
    local unit = self:AddUnit(dare_data.show_role, stage_obj:FindChild("Bg"), Vector3.zero, 0.5)
    unit:SetPositionByRectName({parent = stage_obj:FindChild("Bg"), name = UnitConst.UnitRect.Head})
    unit:StopAllAnimationToCurPos()
    self:AddClick(stage_obj, function()
        self:ClickStageObj(stage_obj)
    end)
end

function DaliyBattleUI:ClickStageObj(stage_obj)
    local old_select_index = self.cur_select_index
    self.last_select_index = self.cur_select_index
    self.cur_select_index = table.index(self.stage_obj_list, stage_obj)
    self:SelectStageObj(stage_obj)
    local data = self.stage_data_list[self.cur_select_index]
    local dare_data = data.dare_data
    local is_open = data.is_open
    local is_passing = data.dare_info.is_passing
    self.consume_action_text.text = string.format(UIConst.Text.CONSUME_ACTION_FORMAT, dare_data.strength_comsume)
    if is_passing then
        self.finish_dare:SetActive(true)
        self.enter_btn:SetActive(false)
    else
        self.enter_btn:SetActive(true)
        self.finish_dare:SetActive(false)
        -- if is_open then
        --     self.enter_btn:GetComponent("Image").material = nil
        --     self.enter_btn_text:GetComponent("Text").material = nil
        --     self.enter_btn:GetComponent("Button").interactable = true
        -- else
        --     self.enter_btn:GetComponent("Image").material = self.gray_material
        --     self.enter_btn_text:GetComponent("Text").material = self.gray_material
        --     self.enter_btn:GetComponent("Button").interactable = false
        -- end
    end
    if old_select_index ~= self.cur_select_index then
        self:MoveStageSlider(self.cur_select_index)
        self:SliderToIndex(self.cur_select_index)
        if math.abs(old_select_index - self.cur_select_index) > 2 then
            self.slider_timer = kSliderTime
        else
            self.slider_timer = 0
        end
    end
end

function DaliyBattleUI:MoveStageSlider(select_index)
    self.stage_start_pos = self.stage_content_rect.anchoredPosition
    local pos_x = -(select_index - 1) * self.stage_width
    local max_pos_x = -(self.max_hero_index) * self.stage_width + self.stage_content_width + StageLength
    pos_x = math.clamp(pos_x, max_pos_x, 0)
    self.stage_target_pos = Vector2.New(pos_x, 0)
    self:SelectStageObj(self.stage_obj_list[select_index])
    if Vector3.Distance(self.stage_start_pos, self.stage_target_pos) < StageMinMoveDis then
        self.stage_start_pos = nil
        self.stage_target_pos = nil
    end
end

function DaliyBattleUI:SelectStageObj(stage_obj)
    if self.cur_select_stage_obj then
        self.cur_select_stage_obj:FindChild("SelectImage"):SetActive(false)
    end
    stage_obj:FindChild("SelectImage"):SetActive(true)
    self.cur_select_stage_obj = stage_obj
end

function DaliyBattleUI:GetOpenDateStr(date_list)
    local ret = ""
    for i, v in ipairs(date_list) do
        ret = ret .. UIConst.Text.WEED_TEXT[v]
    end
    return ret
end

function DaliyBattleUI:IsInOpen(dare_id)
    if not self.open_dare_dict then return end
    for k, dare_data in pairs(self.open_dare_dict) do
        if dare_data.dare_id == dare_id then
            return true
        end
    end
    return false
end

function DaliyBattleUI:GetDareInfo(dare_id)
    for k, dare_info in pairs(self.open_dare_dict) do
        if dare_info.dare_id == dare_id then
            return dare_info
        end
    end
    for k, dare_info in pairs(self.not_open_dare_dict) do
        if dare_info.dare_id == dare_id then
            return dare_info
        end
    end
end

function DaliyBattleUI:IsInOpenDate(date_list)
    local week_day = Time:GetServerWeekDay()
    week_day = week_day == 0 and 7 or week_day
    if table.contains(date_list, week_day) then
        return true
    end
    return false
end

function DaliyBattleUI:SetTextVal()
    self.enter_btn_text.text = UIConst.Text.ENTER_DAILY_BATTLE_TEXT
    self.finish_dare_text.text = UIConst.Text.FINISH_DAILY_BATTLE_TEXT
    self.enter_btn_text.text = UIConst.Text.ENTER_DAILY_BATTLE_TEXT
end

function DaliyBattleUI:Hide()
    if self.talk_list then
        for i,v in ipairs(self.talk_list) do
            v:DoDestroy()
        end
    end
    self:DelObjDict(self.unit_list)
    self:DelObjDict(self.stage_obj_list)
    ComMgrs.dy_data_mgr.daily_dare_data:UnregisterUpdateDailyDareData("DaliyBattleUI")
    DaliyBattleUI.super.Hide(self)
end

return DaliyBattleUI
