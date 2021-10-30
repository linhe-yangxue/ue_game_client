local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local PouringWineUI = class("UI.PouringWineUI", UIBase)

local kDestinationPos = Vector2.zero
local kBottleInitRotation = Quaternion.Euler(0, 0, 0)
local kDropMinAlpha = 0.2
local kDropOffset = 1
local kInitDropInterval = 0.2
local kChangeAlphaInterval = 1

function PouringWineUI:DoInit()
    PouringWineUI.super.DoInit(self)
    self.prefab_path = "UI/Common/PouringWineUI"
    self.wine_glass_count = SpecMgrs.data_mgr:GetParamData("bar_wine_glass_type_count").f_value
    self.wine_glass_max_capacity = SpecMgrs.data_mgr:GetParamData("bar_wine_glass_max_capacity").tb_float
    -- 游戏参数
    self.total_game_time = SpecMgrs.data_mgr:GetParamData("pour_wine_game_time").f_value
    self.init_drop_start_angle = SpecMgrs.data_mgr:GetParamData("init_drop_start_angle").f_value
    self.bottle_rotate_max_angle = SpecMgrs.data_mgr:GetParamData("bottle_rotate_max_angle").f_value
    self.bottle_rotate_angle = SpecMgrs.data_mgr:GetParamData("bottle_rotate_angle").f_value
    self.wine_drop_volume = SpecMgrs.data_mgr:GetParamData("wine_drop_volume").f_value
    self.leave_remind_time = SpecMgrs.data_mgr:GetParamData("leave_remind_time").f_value
    self.leave_remind_sec = self.leave_remind_time * CSConst.Time.Minute

    self.dy_bar_data = ComMgrs.dy_data_mgr.bar_data
    self.wine_glass_data_list = {}
    self.drop_item_dict = {}
end

function PouringWineUI:OnGoLoadedOk(res_go)
    PouringWineUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function PouringWineUI:Hide()
    self:GameEnd()
    if self.lover_unit then
        self:RemoveUnit(self.lover_unit)
        self.lover_unit = nil
    end
    PouringWineUI.super.Hide(self)
end

function PouringWineUI:Show()
    self.lover_id, self.challenge_count = self.dy_bar_data:GetBarLoverInfo()
    if not self.lover_id or self.challenge_count <= 0 then return end
    if self.is_res_ok then
        self:InitUI()
    end
    PouringWineUI.super.Show(self)
end

function PouringWineUI:InitRes()
    UIFuncs.GetInitTopBar(self, self.main_panel, "PouringWineUI", function ()
        if self.game_time then
            SpecMgrs.ui_mgr:ShowMsgSelectBox({
                content = UIConst.Text.QUIT_GAME_TEXT,
                confirm_cb = function ()
                    SpecMgrs.ui_mgr:HideUI(self)
                end,
            })
        else
            SpecMgrs.ui_mgr:HideUI(self)
        end
    end)

    local lover_info = self.main_panel:FindChild("LoverInfo")
    self.lover_model = lover_info:FindChild("LoverModel")
    self.lover_name = lover_info:FindChild("Name/Text"):GetComponent("Text")
    self.challenge_count_text = lover_info:FindChild("Count/Text"):GetComponent("Text")
    self.lover_grade = lover_info:FindChild("Grade"):GetComponent("Image")
    self.preview_panel = self.main_panel:FindChild("PreviewPanel")
    self:AddClick(self.preview_panel:FindChild("GameStartBtn"), function ()
        if not self.dy_bar_data:CheckGameCount(CSConst.BarType.Lover) then return end
        local next_refresh_sec = self.dy_bar_data:GetNextRefreshTime()
        if next_refresh_sec - Time:GetServerTime() < self.leave_remind_sec then
            local lover_data = SpecMgrs.data_mgr:GetLoverData(self.lover_id)
            SpecMgrs.ui_mgr:ShowTipMsg(string.format(UIConst.Text.BAR_UNIT_LEAVE_SOON, lover_data.name, self.leave_remind_time))
        end
        self.preview_panel:SetActive(false)
        self.game_panel:SetActive(true)
        self:StartGame()
    end)
    self.preview_panel:SetActive(false)


    self.game_panel = self.main_panel:FindChild("GamePanel")
    local game_panel_width = self.game_panel:GetComponent("RectTransform").rect.width
    self.tick_mark = self.game_panel:FindChild("TickMark")
    self.tick_mark_rect = self.tick_mark:GetComponent("RectTransform")
    self.tick_mark_text = self.tick_mark:FindChild("Text"):GetComponent("Text")
    for i = 1, self.wine_glass_count do
        local glass_data = {}
        local glass_item = self.game_panel:FindChild(i)
        glass_item:SetActive(false)
        glass_data.item = glass_item
        glass_data.capacity = glass_item:GetComponent("Image")
        local glass_rect_cmp = glass_item:GetComponent("RectTransform")
        glass_data.rect_cmp = glass_rect_cmp
        glass_data.tween_pos_cmp = glass_item:GetComponent("UITweenPosition")
        local init_pos = glass_rect_cmp.anchoredPosition
        local glass_size = glass_rect_cmp.sizeDelta
        glass_data.size = glass_size
        glass_data.start_pos = Vector2.New(-(glass_size.x + game_panel_width) / 2, init_pos.y)
        glass_data.end_pos = Vector2.New(0, init_pos.y)
        self.wine_glass_data_list[i] = glass_data
    end
    self.drop_list = self.game_panel:FindChild("DropList")
    self.drop_item = self.drop_list:FindChild("Drop")
    local wine_drop_duration = SpecMgrs.data_mgr:GetParamData("wine_drop_duration").f_value
    self.drop_item:GetComponent("UITweenPosition"):SetDurationTime(wine_drop_duration)
    local tween_alpha_cmp = self.drop_item:GetComponent("UITweenAlpha")
    tween_alpha_cmp:SetDurationTime(wine_drop_duration * 0.2)
    tween_alpha_cmp:SetDelayTime(wine_drop_duration * 0.8)
    local wine_bottle = self.game_panel:FindChild("Bottle")
    self.wine_bottle_rect = wine_bottle:GetComponent("RectTransform")
    self.drop_parent = wine_bottle:FindChild("DropParent")
    local pour_btn = self.game_panel:FindChild("PourBtn")
    pour_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.POUR_WINE_TEXT
    self:AddPress(pour_btn, function ()
        if self.game_time and self.game_time > 0 then
            self.pouring = true
        end
    end)
    self:AddRelease(pour_btn, function ()
        if self.game_time and self.game_time > 0 then
            self.pouring = false
        end
    end)
    self.result_panel = self.game_panel:FindChild("Result")
    self.win_tip = self.result_panel:FindChild("Content/Win")
    self.win_tip:GetComponent("Text").text = UIConst.Text.WIN_TIP
    self.lose_tip = self.result_panel:FindChild("Content/Lose")
    self.lose_tip:GetComponent("Text").text = UIConst.Text.LOSE_TIP
    self:AddClick(self.result_panel:FindChild("Reset"), function ()
        self.tick_mark:SetActive(false)
        self.wine_glass_data_list[self.random_index].item:SetActive(false)
        self:InitGamePreviewPanel()
        local lover_id, challenge_count = self.dy_bar_data:GetBarLoverInfo()
        if challenge_count == 0 then self:Hide() end
    end)
    self.result_panel:SetActive(false)
    self.game_panel:SetActive(false)

    local game_count = self.main_panel:FindChild("GameCount")
    self.rest_game_count = game_count:FindChild("Count"):GetComponent("Text")
    local add_btn = game_count:FindChild("AddBtn")
    self.add_btn_cmp = add_btn:GetComponent("Button")
    self:AddClick(add_btn, function ()
        if self.game_time then return end
        self.dy_bar_data:SendBuyGameCount(CSConst.BarType.Lover)
    end)

    self.count_down_img = self.main_panel:FindChild("Time/CountDown"):GetComponent("Image")
    self.count_down_text = self.main_panel:FindChild("Time/Text"):GetComponent("Text")
end

function PouringWineUI:InitUI()
    self:InitLoverInfo()
    self:InitGamePreviewPanel()
    self:RegisterEvent(self.dy_bar_data, "UpdateBarUnitEvent", function ()
        self:UpdateChallengeCount()
    end)
    self:RegisterEvent(self.dy_bar_data, "UpdateBarGameCountEvent", function ()
        self:UpdateGameCount()
    end)
end

function PouringWineUI:InitLoverInfo()
    local lover_data = SpecMgrs.data_mgr:GetLoverData(self.lover_id)
    self.lover_unit = self:AddFullUnit(lover_data.unit_id, self.lover_model)
    self.lover_name.text = lover_data.name
    self.challenge_count_text.text = string.format(UIConst.Text.BAR_CHALLENGE_COUNT_FORMAT, self.challenge_count)
    local quality_data = SpecMgrs.data_mgr:GetQualityData(lover_data.quality)
    UIFuncs.AssignSpriteByIconID(quality_data.grade, self.lover_grade)
    self:UpdateGameCount()
    self.game_data = SpecMgrs.data_mgr:GetBarLoverData(self.lover_id)
end

function PouringWineUI:InitGamePreviewPanel()
    self.game_time = nil
    self.pouring = false
    self.count_down_img.fillAmount = 1
    self.count_down_text.text = self.total_game_time
    self.preview_panel:SetActive(true)
    self.game_panel:SetActive(false)
    self.result_panel:SetActive(false)
end

function PouringWineUI:UpdateChallengeCount()
    local lover_id, challenge_count = self.dy_bar_data:GetBarLoverInfo()
    if lover_id == self.lover_id and challenge_count > 0 then
        self.challenge_count_text.text = string.format(UIConst.Text.BAR_CHALLENGE_COUNT_FORMAT, challenge_count)
    else
        local lover_data = SpecMgrs.data_mgr:GetLoverData(self.lover_id)
        if lover_id ~= self.lover_id then
            SpecMgrs.ui_mgr:ShowTipMsg(string.format(UIConst.Text.BAR_LOVER_LEAVE, lover_data.name))
            if self.game_time then self:GameEnd() end
            self.lover_id = lover_id
            self:InitLoverInfo()
            self:InitGamePreviewPanel()
        end
    end
end

function PouringWineUI:UpdateGameCount()
    local game_count = self.dy_bar_data:GetGameCountByBarType(CSConst.BarType.Lover)
    self.rest_game_count.text = string.format(UIConst.Text.BAR_GAME_COUNT_FORMAT, game_count)
end

function PouringWineUI:StartGame()
    self.random_index = math.random(self.wine_glass_count)
    for _, glass_data in ipairs(self.wine_glass_data_list) do
        glass_data.item:SetActive(false)
    end
    local random_glass = self.wine_glass_data_list[self.random_index]
    random_glass.capacity.fillAmount = 0
    random_glass.rect_cmp.anchoredPosition = random_glass.start_pos
    random_glass.tween_pos_cmp.from_ = random_glass.start_pos
    random_glass.tween_pos_cmp.to_ = random_glass.end_pos
    local tick_mark_pos = self.tick_mark_rect.anchoredPosition
    local max_capacity = self.wine_glass_max_capacity[self.random_index]
    local standard = self.game_data.capacity[self.random_index]
    tick_mark_pos.y = random_glass.end_pos.y + standard / max_capacity * random_glass.size.y
    self.tick_mark_rect.anchoredPosition = tick_mark_pos
    self.tick_mark_text.text = string.format(UIConst.Text.BAR_WINE_CAPACITY_FORMAT, standard)
    local show_tick_mark_delay = random_glass.tween_pos_cmp:GetDelayTime() + random_glass.tween_pos_cmp:GetDurationTime()
    self.wine_bottle_rect.rotation = kBottleInitRotation
    random_glass.item:SetActive(true)
    random_glass.tween_pos_cmp:Play()
    self:AddTimer(function ()
        self.tick_mark:SetActive(true)
        self.game_start = true
        self.game_time = self.total_game_time
    end, show_tick_mark_delay)
end

function PouringWineUI:Update(delta_time)
    if self.game_time then
        if self.game_time > 0 then
            local glass_data = self.wine_glass_data_list[self.random_index]
            self.game_time = self.game_time - delta_time
            self:UpdateCountDown(self.game_time)
            if glass_data.capacity.fillAmount == 1 then
                self.game_time = 0
                self:GameEnd()
            else
                local bottle_angle = self.wine_bottle_rect.rotation.eulerAngles.z
                local angle = self.pouring and self.bottle_rotate_angle or -self.bottle_rotate_angle
                local next_angle = bottle_angle + angle
                if next_angle < self.bottle_rotate_max_angle and next_angle > 0 then
                    self.wine_bottle_rect:Rotate(Vector3.forward, angle)
                end
                if bottle_angle >= self.init_drop_start_angle then
                    if not self.init_alpha_time or self.game_time <= self.init_alpha_time then
                        self.init_alpha_time = self.game_time - kChangeAlphaInterval
                    end
                    self.init_drop_time = self.init_drop_time - delta_time
                    if self.init_drop_time <= 0 then
                        local count = math.random(math.ceil((bottle_angle - self.init_drop_start_angle) * 0.5))
                        for i = 1, count do
                            local alpha = math.lerp(kDropMinAlpha, 1, (self.game_time - self.init_alpha_time) / kChangeAlphaInterval)
                            local offset = Vector2.New(0, kDropOffset * (i - 1))
                            self:InstantiateDropItem(alpha, offset)
                        end
                        self.init_drop_time = kInitDropInterval
                    end
                else
                    self.init_alpha_time = nil
                    self.init_drop_time = 0
                end
            end
        elseif not next(self.drop_item_dict) then
            self:CalcGameResult()
        end
    end
end

function PouringWineUI:UpdateCountDown(time)
    local int_time, float_time = math.modf(time)
    self.count_down_img.fillAmount = float_time
    self.count_down_text.text = int_time
end

function PouringWineUI:InstantiateDropItem(alpha, offset)
    local drop_item = self:GetUIObject(self.drop_item, self.drop_parent)
    drop_item:SetParent(self.drop_list)
    local rect_cmp = drop_item:GetComponent("RectTransform")
    local init_pos = rect_cmp.anchoredPosition + offset
    rect_cmp.anchoredPosition = init_pos
    rect_cmp.rotation = kBottleInitRotation
    local glass_data = self.wine_glass_data_list[self.random_index]
    local tween_pos_cmp = drop_item:GetComponent("UITweenPosition")
    tween_pos_cmp.from_ = init_pos
    tween_pos_cmp.to_ = Vector2.New(init_pos.x, glass_data.end_pos.y + 10)
    tween_pos_cmp:Play()
    local tween_alpha_cmp = drop_item:GetComponent("UITweenAlpha")
    tween_alpha_cmp.from_ = alpha
    tween_alpha_cmp:Play()
    drop_item:GetComponent("CanvasGroup").alpha = alpha
    local instance_id = drop_item:GetInstanceID()
    local timer = self:AddTimer(function ()
        local drop_item_data = self.drop_item_dict[instance_id]
        self:DelUIObject(drop_item_data.item)
        self.drop_item_dict[instance_id] = nil
        if glass_data.capacity.fillAmount < 1 then
            local glass_max_capacity = self.wine_glass_max_capacity[self.random_index]
            local cur_volume = glass_data.capacity.fillAmount * glass_max_capacity
            glass_data.capacity.fillAmount = (cur_volume + self.wine_drop_volume) / glass_max_capacity
        end
    end, tween_pos_cmp:GetDurationTime())
    self.drop_item_dict[instance_id] = {item = drop_item, timer = timer}
end

function PouringWineUI:GameEnd()
    if not self.game_time then return end
    if self.game_time > 0 then
        self:SendBarGeneralChallenge(false)
        for _, drop_data in pairs(self.drop_item_dict) do
            self:RemoveTimer(drop_data.timer)
            self:DelUIObject(drop_data.item)
        end
        self.drop_item_dict = {}
    end
    self.pouring = false
    self.wine_bottle_rect.rotation = kBottleInitRotation
end

function PouringWineUI:CalcGameResult()
    local glass_data = self.wine_glass_data_list[self.random_index]
    local glass_max_capacity = self.wine_glass_max_capacity[self.random_index]
    local standard = self.game_data.capacity[self.random_index]
    local final_capacity = glass_data.capacity.fillAmount * glass_max_capacity
    local result = math.abs(final_capacity - standard) < self.game_data.float_mark[self.random_index]
    self.win_tip:SetActive(result)
    self.lose_tip:SetActive(not result)
    self:SendBarGeneralChallenge(result)
end

function PouringWineUI:SendBarGeneralChallenge(result)
    self.game_time = nil
    if self.lover_id ~= (self.dy_bar_data:GetBarLoverInfo()) then return end
    SpecMgrs.msg_mgr:SendBarGeneralChallenge({lover_id = self.lover_id, result = result}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.SEND_BAR_GAME_RESULT_FAILED)
        else
            if self.is_res_ok then
                self.result_panel:SetActive(true)
            end
        end
    end)
end

return PouringWineUI