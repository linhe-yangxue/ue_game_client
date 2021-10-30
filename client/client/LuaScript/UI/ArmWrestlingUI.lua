local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local ArmWrestlingUI = class("UI.ArmWrestlingUI", UIBase)

local kFailedAngle = -60
local kWinAngle = 120
local kHand1RotateAngle = 30
local kInitRotation = Quaternion.Euler(0, 0, 0)

function ArmWrestlingUI:DoInit()
    ArmWrestlingUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ArmWrestlingUI"
    self.dy_bar_data = ComMgrs.dy_data_mgr.bar_data
    self.total_game_time = SpecMgrs.data_mgr:GetParamData("arm_wrestling_game_time").f_value
    self.play_arm_rotate_angle = SpecMgrs.data_mgr:GetParamData("player_arm_rotate_angle").f_value
    self.leave_remind_time = SpecMgrs.data_mgr:GetParamData("leave_remind_time").f_value
    self.leave_remind_sec = self.leave_remind_time * CSConst.Time.Minute
end

function ArmWrestlingUI:OnGoLoadedOk(res_go)
    ArmWrestlingUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function ArmWrestlingUI:Hide()
    self:GameEnd()
    if self.hero_unit then
        self:RemoveUnit(self.hero_unit)
        self.hero_unit = nil
    end
    ArmWrestlingUI.super.Hide(self)
end

function ArmWrestlingUI:Show(hero_id)
    local challenge_count = self.dy_bar_data:GetHeroChallengeCount(hero_id)
    if challenge_count and challenge_count <= 0 then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.BAR_UNIT_CHALLENGE_COUNT_LIMIT)
        return
    end
    if not challenge_count then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.BAR_UNIT_HAVE_REFRESH)
        local new_hero_list = self.dy_bar_data:GetBarHeroList()
        self.hero_id = new_hero_list[1].hero_id
    else
        self.hero_id = hero_id
    end
    if self.is_res_ok then
        self:InitUI()
    end
    ArmWrestlingUI.super.Show(self)
end

function ArmWrestlingUI:InitRes()
    UIFuncs.GetInitTopBar(self, self.main_panel, "ArmWrestlingUI", function ()
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

    local hero_info = self.main_panel:FindChild("HeroInfo")
    self.hero_model = hero_info:FindChild("HeroModel")
    self.hero_name = hero_info:FindChild("Name/Text"):GetComponent("Text")
    self.challenge_count = hero_info:FindChild("Count/Text"):GetComponent("Text")
    self.hero_grade = hero_info:FindChild("Grade"):GetComponent("Image")
    self.game_start_btn = self.main_panel:FindChild("GameStartBtn")
    self:AddClick(self.game_start_btn, function ()
        if not self.dy_bar_data:CheckGameCount(CSConst.BarType.Hero) then return end
        local next_refresh_sec = self.dy_bar_data:GetNextRefreshTime()
        if next_refresh_sec - Time:GetServerTime() < self.leave_remind_sec then
            local hero_data = SpecMgrs.data_mgr:GetHeroData(self.hero_id)
            SpecMgrs.ui_mgr:ShowTipMsg(string.format(UIConst.Text.BAR_UNIT_LEAVE_SOON, hero_data.name, self.leave_remind_time))
        end
        self:StartGame()
        self.game_start_btn:SetActive(false)
        self.press_btn:SetActive(true)
    end)

    local game_panel = self.main_panel:FindChild("GamePanel")
    self.hand1_rect_cmp = game_panel:FindChild("Hand1"):GetComponent("RectTransform")
    self.hand2_rect_cmp = game_panel:FindChild("Hand2"):GetComponent("RectTransform")
    self.score_value = game_panel:FindChild("ScoreBar/Value"):GetComponent("Image")
    self.press_btn = game_panel:FindChild("PressBtn")
    self.press_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.PRESS_TEXT
    self:AddClick(self.press_btn, function ()
        self.player_wrestle_angle = self.player_wrestle_angle + self.play_arm_rotate_angle
    end)

    self.result_panel = game_panel:FindChild("Result")
    self.win_tip = self.result_panel:FindChild("Content/Win")
    self.win_tip:GetComponent("Text").text = UIConst.Text.WIN_TIP
    self.lose_tip = self.result_panel:FindChild("Content/Lose")
    self.lose_tip:GetComponent("Text").text = UIConst.Text.LOSE_TIP
    self:AddClick(self.result_panel:FindChild("Reset"), function ()
        self:InitGamePanel()
        if self.dy_bar_data:GetHeroChallengeCount(self.hero_id) == 0 then
            self:Hide()
        end
    end)
    self.result_panel:SetActive(false)

    local game_count = self.main_panel:FindChild("GameCount")
    self.rest_game_count = game_count:FindChild("Count"):GetComponent("Text")
    local add_btn = game_count:FindChild("AddBtn")
    self.add_btn_cmp = add_btn:GetComponent("Button")
    self:AddClick(add_btn, function ()
        if self.game_time then return end
        self.dy_bar_data:SendBuyGameCount(CSConst.BarType.Hero)
    end)

    self.count_down_img = self.main_panel:FindChild("Time/CountDown"):GetComponent("Image")
    self.count_down_text = self.main_panel:FindChild("Time/Text"):GetComponent("Text")
end

function ArmWrestlingUI:InitUI()
    self:InitHeroInfo()
    self:InitGamePanel()
    self:RegisterEvent(self.dy_bar_data, "UpdateBarUnitEvent", function ()
        self:UpdateChallengeCount()
    end)
    self:RegisterEvent(self.dy_bar_data, "UpdateBarGameCountEvent", function ()
        self:UpdateGameCount()
    end)
end

function ArmWrestlingUI:InitHeroInfo()
    local hero_data = SpecMgrs.data_mgr:GetHeroData(self.hero_id)
    self.hero_unit = self:AddFullUnit(hero_data.unit_id, self.hero_model)
    self.hero_name.text = hero_data.name
    local challenge_count = self.dy_bar_data:GetHeroChallengeCount(self.hero_id)
    self.challenge_count.text = string.format(UIConst.Text.BAR_CHALLENGE_COUNT_FORMAT, challenge_count)
    local quality_data = SpecMgrs.data_mgr:GetQualityData(hero_data.quality)
    UIFuncs.AssignSpriteByIconID(quality_data.grade, self.hero_grade)
    self:UpdateGameCount()
    self.game_data = SpecMgrs.data_mgr:GetBarHeroData(self.hero_id)
end

function ArmWrestlingUI:UpdateChallengeCount()
    local challenge_count = self.dy_bar_data:GetHeroChallengeCount(self.hero_id)
    if not challenge_count then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.BAR_UNIT_HAVE_REFRESH)
        local new_hero_list = self.dy_bar_data:GetBarHeroList()
        self.hero_id = new_hero_list[1].hero_id
        if self.game_time then self:GameEnd() end
        self:InitHeroInfo()
        self:InitGamePanel()
    else
        self.challenge_count.text = string.format(UIConst.Text.BAR_CHALLENGE_COUNT_FORMAT, challenge_count)
    end
end

function ArmWrestlingUI:UpdateGameCount()
    local game_count = self.dy_bar_data:GetGameCountByBarType(CSConst.BarType.Hero)
    self.rest_game_count.text = string.format(UIConst.Text.BAR_GAME_COUNT_FORMAT, game_count)
end

function ArmWrestlingUI:InitGamePanel()
    self.hand1_rect_cmp.rotation = kInitRotation
    self.hand2_rect_cmp.rotation = kInitRotation
    self.score_value.fillAmount = 1
    self.count_down_img.fillAmount = 1
    self.count_down_text.text = self.total_game_time
    self.game_start_btn:SetActive(true)
    self.press_btn:SetActive(false)
    self.result_panel:SetActive(false)
end

function ArmWrestlingUI:StartGame()
    self.player_wrestle_angle = 0
    self.npc_wrestle_angle = 0
    self.score_value.fillAmount = 0
    self.game_time = self.total_game_time
    self.npc_wrestle_timer = 0
    self.npc_wrestle_count = 0
end

function ArmWrestlingUI:Update(delta_time)
    if self.game_time then
        if self.game_time > 0 then
            self.game_time = self.game_time - delta_time
            self:UpdateCountDown(self.game_time)
            self:UpdateNpcWrestleAngle(delta_time)
            self:UpdateGame()
        else
            self:GameEnd()
        end
    end
end

function ArmWrestlingUI:UpdateCountDown(time)
    local int_time, float_time = math.modf(time)
    self.count_down_img.fillAmount = float_time
    self.count_down_text.text = int_time
end

function ArmWrestlingUI:UpdateNpcWrestleAngle(delta_time)
    self.npc_wrestle_timer = self.npc_wrestle_timer + delta_time
    local wrestle_count = math.floor(self.npc_wrestle_timer / self.game_data.wrestle_interval)
    for i = 1, wrestle_count - self.npc_wrestle_count do
        local random_angle = math.random(self.game_data.wrestle_angle[1], self.game_data.wrestle_angle[2])
        self.npc_wrestle_angle = self.npc_wrestle_angle + random_angle
    end
    self.npc_wrestle_count = wrestle_count
end

function ArmWrestlingUI:UpdateGame()
    local angle_offset = self.player_wrestle_angle - self.npc_wrestle_angle
    self.hand2_rect_cmp.rotation = Quaternion.Euler(0, 0, angle_offset)
    if math.abs(angle_offset) > kHand1RotateAngle then
        local hand1_rot = math.abs(angle_offset) - kHand1RotateAngle
        hand1_rot = angle_offset > 0 and hand1_rot or -hand1_rot
        self.hand1_rect_cmp.rotation = Quaternion.Euler(0, 0, hand1_rot)
    end
    self.score_value.fillAmount = math.clamp(angle_offset / kWinAngle, 0, 1)
    if angle_offset >= kWinAngle or angle_offset < kFailedAngle then
        self:GameEnd()
    end
end

function ArmWrestlingUI:GameEnd()
    if not self.game_time then return end
    self:CalcResult()
    self.game_time = nil
end

function ArmWrestlingUI:CalcResult()
    local angle_offset = self.player_wrestle_angle - self.npc_wrestle_angle
    local result = angle_offset >= kWinAngle
    self.win_tip:SetActive(result)
    self.lose_tip:SetActive(not result)
    self:SendBarGeneralChallenge(result)
end

function ArmWrestlingUI:SendBarGeneralChallenge(result)
    if not self.dy_bar_data:GetHeroChallengeCount(self.hero_id) then return end
    SpecMgrs.msg_mgr:SendBarGeneralChallenge({hero_id = self.hero_id, result = result}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.SEND_BAR_GAME_RESULT_FAILED)
        else
            if self.is_res_ok then
                self.result_panel:SetActive(true)
            end
        end
    end)
end

return ArmWrestlingUI