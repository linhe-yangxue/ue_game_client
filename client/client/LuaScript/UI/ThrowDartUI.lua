local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local ThrowDartUI = class("UI.ThrowDartUI", UIBase)

local kGameIndex = 1
function ThrowDartUI:DoInit()
    ThrowDartUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ThrowDartUI"
    self.game_data = SpecMgrs.data_mgr:GetPartyGameData(kGameIndex)
    self.score_list = self.game_data.score_list -- 得分档次 从高到低
    self.score_index_to_radius_list = {} -- 得分档次对应的距离靶心
    self.max_move_radius = 0 -- 靶心最大位移距离
    self.aim_move_speed = 0 -- 准信移动速度
    self.is_game_start = false -- 游戏是否开始
    self.move_direction = self:GetRandomNormalizedVector2()
    self.shoot_cool_time = self.game_data.throw_cool_time or 1
    self.party_game_score_limit = SpecMgrs.data_mgr:GetParamData("party_game_score_limit").f_value
    self.dart_unit_id = self.game_data.dart_unit
    self.dart_unit_list = {}

end

function ThrowDartUI:OnGoLoadedOk(res_go)
    ThrowDartUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function ThrowDartUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    ThrowDartUI.super.Show(self)
end

function ThrowDartUI:Update(delta_time)
    if self.is_show_aim then
        local move_offset = self.move_direction * self.aim_move_speed * delta_time
        self.aim_point_rect.anchoredPosition = self.aim_point_rect.anchoredPosition + move_offset
        if self.aim_point_rect.anchoredPosition.magnitude > self.max_move_radius then
            self.move_direction = self:GetRandomNormalizedVector2(self.aim_point_rect.anchoredPosition)
        end
    end
    if self.shoot_cool_timer then
        self.shoot_cool_timer = self.shoot_cool_timer - delta_time
        local fill_amount
        if self.shoot_cool_timer <= 0 then
            self.shoot_cool_timer = nil
            fill_amount = 0
            self.load_ok_go:SetActive(true)
        else
            fill_amount = self.shoot_cool_timer / self.shoot_cool_time
        end
        self.shoot_cool_image.fillAmount = fill_amount
    end
end

function ThrowDartUI:InitRes()
    UIFuncs.GetInitTopBar(self, self.main_panel, "HoldPartyPanel")
    self.close_btn = self.top_bar:FindChild("CloseBtn"):GetComponent("Button")
    local middle_part = self.main_panel:FindChild("MiddlePart")
    self.target = middle_part:FindChild("Target")
    local target_circle_parent = self.target:FindChild("CircelParent")

    for i, v in ipairs(self.score_list) do
        local circle = target_circle_parent:FindChild(i)
        if circle then
            local radius = circle:GetComponent("RectTransform").rect.width / 2
            self.score_index_to_radius_list[i] = radius
        end
    end
    local max_move_circle_radius = target_circle_parent:FindChild("MaxMoveCircle"):GetComponent("RectTransform").rect.width / 2
    self.max_move_radius = max_move_circle_radius
    self.aim_move_speed = max_move_circle_radius * self.game_data.aim_move_speed
    target_circle_parent:SetActive(false)

    self.aim_point = middle_part:FindChild("Target/AimPoint")
    self.aim_point_rect = self.aim_point:GetComponent("RectTransform")
    self.rule_text = middle_part:FindChild("Rule/Text"):GetComponent("Text")
    self.rule_text.text = self.game_data.rule_text
    local shoot_btn_go = middle_part:FindChild("ShootBtn")
    shoot_btn_go:FindChild("Tip"):GetComponent("Text").text = UIConst.Text.THROW_DART_TIP
    self:AddClick(shoot_btn_go:FindChild("ShootBtn"), function()
        self:ShootBtnOnClick()
    end)
    self.score_text = self.main_panel:FindChild("BottomBar/Score"):GetComponent("Text")
    self.remain_time_text = self.main_panel:FindChild("BottomBar/RemainTime"):GetComponent("Text")
    self.dart_unit_parent = self.main_panel:FindChild("MiddlePart/Target/UnitParent")
    self.shoot_cool_image = shoot_btn_go:FindChild("CoolDown"):GetComponent("Image")
    self.load_ok_go = shoot_btn_go:FindChild("LoadingOK")
end

function ThrowDartUI:InitUI()
    self.close_btn.interactable = true
    self:SetScore(0)
    self:SetReaminTime(self.game_data.time)
    self:SetAimPointStatus(true)
end

function ThrowDartUI:StartGame()
    self.is_game_start = true
    self.close_btn.interactable = false
end

function ThrowDartUI:EndGame()
    self:SetAimPointStatus(false)
    self.close_btn.interactable = false
    if ComMgrs.dy_data_mgr.party_data:CanStartGame() then
        SpecMgrs.msg_mgr:SendMsg("SendPartyGames", {score = self.score}, function(resp)
            if resp.integral then
                local ui_name = "PartyGameEndUI"
                local tag = self.class_name
                SpecMgrs.ui_mgr:ShowUI(ui_name, resp.integral)
                SpecMgrs.ui_mgr:RegisterHideUIEvent(tag, function(_, ui)
                    if ui.class_name == ui_name then
                        self.is_game_start = nil
                        SpecMgrs.ui_mgr:HideUI(self)
                        SpecMgrs.ui_mgr:UnregisterHideUIEvent(tag)
                    end
                end)
            end
        end)
    end
end

function ThrowDartUI:ShootBtnOnClick()
    if self.shoot_cool_timer then SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.COOLING) return end
    if self.is_shoot_anim then return end
    if not self:CheckRemainTime() then return end
    if not self.is_game_start then self:StartGame() end
    self:StartShootAnim()
end

function ThrowDartUI:StartShootAnim()
    self.is_shoot_anim = true
    self.shoot_cool_timer = self.shoot_cool_time
    self.shoot_cool_image.fillAmount = self.shoot_cool_timer / self.shoot_cool_time
    self.load_ok_go:SetActive(false)
    self:SetAimPointStatus(false)
    local pos = self.aim_point_rect.anchoredPosition
    local unit = self:AddUnit(self.dart_unit_id, self.dart_unit_parent, pos)
    local animation_time = unit:PlayAnim("animation", false)
    table.insert(self.dart_unit_list, unit)

    self.wait_anim_timer = self:AddTimer(function()
        self:EndShootAnim()
        self.wait_anim_timer = nil
    end, animation_time, 1)
end

function ThrowDartUI:EndShootAnim()
    local score_index = self:GetScoreIndexByAimPoint()
    self:SetReaminTime(self.remain_time - 1)
    if score_index then
        local score = self.score + self.score_list[score_index]
        self:SetScore(score)
    end
    if self:CheckGameEnd() then -- 检查游戏是否结束
        self:EndGame()
    else
        self:SetAimPointStatus(true)
    end
    self.is_shoot_anim = nil
end

function ThrowDartUI:CheckGameEnd()
    if not self:CheckRemainTime() then return true end
    if not self:CheckScoreLimit() then return true end
end

function ThrowDartUI:CheckScoreLimit()
    return self.score < self.party_game_score_limit
end

function ThrowDartUI:CheckRemainTime()
    return self.remain_time > 0
end

function ThrowDartUI:SetAimPointStatus(is_show)
    self.is_show_aim = is_show
    self.aim_point:SetActive(is_show)
end

function ThrowDartUI:SetScore(score)
    local score = math.clamp(score, 0, self.party_game_score_limit)
    self.score = score
    self.score_text.text = string.format(UIConst.Text.PARTY_POINT_ALREADY_GET, self.score)
end

function ThrowDartUI:SetReaminTime(remain_time)
    self.remain_time = remain_time
    self.remain_time_text.text = string.format(UIConst.Text.REMAIN_TIME_TEXT, self.remain_time)
end

function ThrowDartUI:GetRandomNormalizedVector2(old_pos)
    local x = math.random(-1000, 1000)
    local y = math.random(-1000, 1000)
    local v2 = Vector2.New(x, y)
    if old_pos then -- 转换方向 防止一直随机到同一方向
        if old_pos.x * v2.x > 0 then
            v2.x = - v2.x
        end
        if old_pos.y * v2.y > 0 then
            v2.y = - v2.y
        end
    end
    return v2:SetNormalize()
end

function ThrowDartUI:GetScoreIndexByAimPoint()
    local cur_aim_offset = self.aim_point_rect.anchoredPosition.magnitude
    for score_index, radius in ipairs(self.score_index_to_radius_list) do
        if cur_aim_offset < radius then
            return score_index
        end
    end
end

function ThrowDartUI:Hide()
    self.is_shoot_anim = nil
    self.shoot_cool_timer = nil
    self.dart_unit_list = {}
    ThrowDartUI.super.Hide(self)
end

return ThrowDartUI
