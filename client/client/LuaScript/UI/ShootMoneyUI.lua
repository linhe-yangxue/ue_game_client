local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local ShootMoneyUI = class("UI.ShootMoneyUI", UIBase)
local UnitConst = require("Unit.UnitConst")
local FloatMsgCmp = require("UI.UICmp.FloatMsgCmp")
local SoundConst = require("Sound.SoundConst")
local UIFuncs = require("UI.UIFuncs")
local kGameIndex = 3
local kSpawnCoolTime = 0.5
local kEffectTime = 0.5

function ShootMoneyUI:DoInit()
    ShootMoneyUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ShootMoneyUI"
    self.game_data = SpecMgrs.data_mgr:GetPartyGameData(kGameIndex)
    self.score_list = self.game_data.score_list -- 得分档次 从高到低
    self.party_game_score_limit = SpecMgrs.data_mgr:GetParamData("party_game_score_limit").f_value

    local spawn_weight_list = self.game_data.spawn_weight_list
    self.random_num_list = {}
    for i, v in ipairs(spawn_weight_list) do
        if i == 1 then
            self.random_num_list[i] = v
        else
            self.random_num_list[i] = self.random_num_list[i - 1] + v
        end
    end
    self.max_random_num = self.random_num_list[#self.random_num_list]
    self.score_index_to_move_speed = {} -- 移动速度
    self.is_game_start = false -- 游戏是否开始
    self.spawn_timer = 0
    self.spawn_cool_time = self.game_data.spawn_cool_time

    self.score_index_to_go_dict = {}
    for i = 1, #self.score_list do
        self.score_index_to_go_dict[i] = {}
    end
    self.spawn_index = 0
    self.spawn_index_to_go = {}
    self.spawn_index_to_delaly_remove_go = {}
    self.spawn_index_to_delaly_timer = {}

end

function ShootMoneyUI:OnGoLoadedOk(res_go)
    ShootMoneyUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function ShootMoneyUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    ShootMoneyUI.super.Show(self)
end

function ShootMoneyUI:Update(delta_time)
    if not self.is_game_start then return end
    self.msg_cmp:Update(delta_time)
    local count_down_time = self.count_down_time - delta_time
    if count_down_time < 0 then
        self:EndGame()
        return
    else
        self:SetCountDownTime(count_down_time)
    end

    self.spawn_timer = self.spawn_timer + delta_time
    if self.spawn_timer >= self.spawn_cool_time then
        self.spawn_timer = 0
        self:SpawnRandomItem()
    end
    self:_UpdateActiveGo(delta_time)
    self:_UpdateRemoveGo(delta_time)
end

function ShootMoneyUI:_UpdateActiveGo(delta_time)
    for score_index, go_dict in ipairs(self.score_index_to_go_dict) do
        local add_offset = self.score_index_to_move_speed[score_index] * delta_time
        for spawn_index, go in pairs(go_dict) do
            local rect_transform = go:GetComponent("RectTransform")
            rect_transform.anchoredPosition = rect_transform.anchoredPosition + add_offset
            if self:_CheckBorder(rect_transform) then
                self.score_index_to_go_dict[score_index][spawn_index] = nil
                self.spawn_index_to_go[spawn_index] = nil
                self:DelUIObject(go)
            end
        end
    end
end

function ShootMoneyUI:_CheckBorder(rect_transform)
    return rect_transform.anchoredPosition.y < self.pos_border.y[1]
end

function ShootMoneyUI:_UpdateRemoveGo(delta_time)
    local remove_list = {}
    for spawn_index, timer in pairs(self.spawn_index_to_delaly_timer) do
        timer = timer - delta_time
        if timer <= 0 then
            table.insert(remove_list, spawn_index)
            local go = self.spawn_index_to_delaly_remove_go[spawn_index]
            self.spawn_index_to_delaly_remove_go[spawn_index] = nil
            self:DelUIObject(go)
        else
            self.spawn_index_to_delaly_timer[spawn_index] = timer
        end
    end
    for _, spawn_index in ipairs(remove_list) do
        self.spawn_index_to_delaly_timer[spawn_index] = nil
    end
end

function ShootMoneyUI:InitRes()
    UIFuncs.GetInitTopBar(self, self.main_panel, "ShootMoneyUI")
    self.close_btn = self.top_bar:FindChild("CloseBtn"):GetComponent("Button")
    self.start_game_btn = self.main_panel:FindChild("StartGameBtn")
    self:AddClick(self.start_game_btn, function ()
        self:StartGame()
    end)

    self.count_down_time_text = self.main_panel:FindChild("CoolDown/Text"):GetComponent("Text")
    self.count_down_time_image = self.main_panel:FindChild("CoolDown"):GetComponent("Image")
    self.rule_text = self.main_panel:FindChild("Rule/Text"):GetComponent("Text")
    self.rule_text.text = self.game_data.rule_text
    self.shoot_num_text = self.main_panel:FindChild("BottomBar/ShootNum"):GetComponent("Text")
    self.score_text = self.main_panel:FindChild("BottomBar/Score"):GetComponent("Text")
    self.spawn_item_parent = self.main_panel:FindChild("ItemParent")
    local spawn_item_parent_rect = self.spawn_item_parent:GetComponent("RectTransform")
    self.pos_border = {}
    self.pos_border.x = {}
    self.pos_border.y = {}
    self.pos_border.x[1] = - spawn_item_parent_rect.rect.width / 2
    self.pos_border.x[2] = spawn_item_parent_rect.rect.width / 2
    self.pos_border.y[1] = - spawn_item_parent_rect.rect.height / 2
    self.pos_border.y[2] = spawn_item_parent_rect.rect.height / 2

    self.spawn_item_temp_list = {}
    self.spawn_item_parent_list = {}
    for i, _ in ipairs(self.score_list) do
        local go = self.spawn_item_parent:FindChild(i)
        self.spawn_item_temp_list[i] = go
        local parent = self.spawn_item_parent:FindChild("Layer" .. i)
        self.spawn_item_parent_list[i] = parent
        local x = 0
        local y = - spawn_item_parent_rect.rect.height * self.game_data.move_speed_list[i]
        self.score_index_to_move_speed[i] = Vector2.New(x, y)
        go:SetActive(false)
    end
    local msg_parent = self.main_panel:FindChild("MsgBox")
    local msg_temp = msg_parent:FindChild("Item")
    self.msg_cmp = FloatMsgCmp.New()
    self.msg_cmp:DoInit(self, msg_parent, msg_temp)
end

function ShootMoneyUI:InitUI()
    self.close_btn.interactable = true
    self:CleanSpawnItem()
    self:SetScore(0)
    self:SetShootNum(0)
    self.count_down_time_text.text = math.floor(self.game_data.time)
    self.start_game_btn:SetActive(true)
end


function ShootMoneyUI:Hide()
    self:CleanSpawnItem()
    self.msg_cmp:ClearRes()
    ShootMoneyUI.super.Hide(self)
end

function ShootMoneyUI:StartGame()
    self.is_game_start = true
    self.close_btn.interactable = false
    self:SetCountDownTime(self.game_data.time)
    self:SetShootNum(0)
    self.start_game_btn:SetActive(false)
end

function ShootMoneyUI:SetCountDownTime(time)
    self.count_down_time = time
    self.count_down_time_text.text = math.floor(time)
    self.count_down_time_image.fillAmount = time / self.game_data.time
end

function ShootMoneyUI:EndGame()
    self.is_game_start = false
    self.close_btn.interactable = true
    if ComMgrs.dy_data_mgr.party_data:CanStartGame() then
        SpecMgrs.msg_mgr:SendMsg("SendPartyGames", {score = self.score}, function(resp)
            if resp.integral then
                local ui_name = "PartyGameEndUI"
                local tag = self.class_name
                SpecMgrs.ui_mgr:ShowUI(ui_name, resp.integral)
                SpecMgrs.ui_mgr:RegisterHideUIEvent(tag, function(_, ui)
                    if ui.class_name == ui_name then
                        SpecMgrs.ui_mgr:HideUI(self)
                        SpecMgrs.ui_mgr:UnregisterHideUIEvent(tag)
                    end
                end)
            end
        end)
    end
end

function ShootMoneyUI:CheckScoreLimit()
    return self.score < self.party_game_score_limit
end

function ShootMoneyUI:SetScore(score)
    local score = math.clamp(score, 0, self.party_game_score_limit)
    self.score = score
    self.score_text.text = string.format(UIConst.Text.PARTY_POINT_ALREADY_GET, self.score)
end

function ShootMoneyUI:SetShootNum(shoot_num)
    self.shoot_num = shoot_num
    self.shoot_num_text.text = string.format(UIConst.Text.SHOOT_NUM, shoot_num)
end

function ShootMoneyUI:SpawnRandomItem()
    local score_index = self:GetRandomScoreIndex()
    self:SpawnItem(score_index)
end

function ShootMoneyUI:GetRandomScoreIndex()
    local random_num = math.random(1, self.max_random_num)
    for index, compare_random_num in ipairs(self.random_num_list) do
        if compare_random_num >= random_num then
            return index
        end
    end
end

function ShootMoneyUI:SpawnItem(score_index)
    local item_temp = self.spawn_item_temp_list[score_index]
    local parent = self.spawn_item_parent_list[score_index]
    self.spawn_index = self.spawn_index + 1
    local index = self.spawn_index
    local go = self:GetUIObject(item_temp, parent)
    go.name = score_index .. "_" .. index
    self.spawn_index_to_go[index] = go
    self.score_index_to_go_dict[score_index][index] = go
    self:ResetSpawnGo(go, score_index)
    self:AddClick(go, function ()
        self:SpawnItemOnClick(go, score_index, index)
    end, SoundConst.SoundID.SID_NotPlaySound)
end

function ShootMoneyUI:GetRandomStartPos()
    local x = math.random(self.pos_border.x[1], self.pos_border.x[2])
    local y = self.pos_border.y[2]
    return Vector2.New(x, y)
end

function ShootMoneyUI:CleanSpawnItem()
    for _, go in pairs(self.spawn_index_to_go) do
        self:DelUIObject(go)
    end
    for _, go in pairs(self.spawn_index_to_delaly_remove_go) do
        self:DelUIObject(go)
    end
    self.spawn_index = 0
    self.spawn_index_to_go = {}
    self.spawn_index_to_delaly_remove_go = {}
    self.spawn_index_to_delaly_timer = {}
    for i = 1, #self.score_list do
        self.score_index_to_go_dict[i] = {}
    end
    self.spawn_timer = 0
end

function ShootMoneyUI:ResetSpawnGo(go)
    go:FindChild("Effect"):SetActive(false)
    go:GetComponent("RectTransform").anchoredPosition = self:GetRandomStartPos()
end

function ShootMoneyUI:SpawnItemOnClick(go, score_index, spawn_index)
    if self.spawn_index_to_delaly_remove_go[spawn_index] then return end
    self.spawn_index_to_go[spawn_index] = nil
    self.spawn_index_to_delaly_remove_go[spawn_index] = go
    if score_index == 3 then
        -- 播放爆炸特效
        self:PlayBoomAnim(go, spawn_index)
    else
        self:PalyShootAnim(go, score_index, spawn_index)
        self:AddMsg(score_index)
        self:SetShootNum(self.shoot_num + 1)
    end
    local add_score = self.score_list[score_index]
    local score = self.score + add_score
    self:SetScore(score)
    if not self:CheckScoreLimit() then
        self:EndGame()
    end
end

function ShootMoneyUI:PalyShootAnim(go, score_index, spawn_index)
    self:_PlayGoClickEffect(go)
    self:RemoveSpawnGo(spawn_index, score_index)
end

function ShootMoneyUI:AddMsg(score_index)
    local str_format = self.game_data.shoot_tip_list[score_index]
    if not str_format then return end
    local score = self.score_list[score_index]
    local str = string.format(str_format, score)
    self.msg_cmp:ShowMsg(str)
end

function ShootMoneyUI:_PlayGoClickEffect(go)
    go:FindChild("Effect"):SetActive(true)
end

function ShootMoneyUI:PlayBoomAnim(go, boom_spawn_index)
    self:_PlayGoClickEffect(go)
    for score_index, go_dict in pairs(self.score_index_to_go_dict) do
        for spawn_index, go in pairs(go_dict) do
            self:RemoveSpawnGo(spawn_index, score_index, false, spawn_index ~= boom_spawn_index and kEffectTime / 2 or kEffectTime)
        end
    end
    self.spawn_timer = self.spawn_timer + kEffectTime
end


function ShootMoneyUI:RemoveSpawnGo(spawn_index, score_index, is_immediately, delay_remove_time)
    local go = self.score_index_to_go_dict[score_index][spawn_index]
    self.score_index_to_go_dict[score_index][spawn_index] = nil
    self.spawn_index_to_go[spawn_index] = nil
    if is_immediately then
        self:DelUIObject(go)
    else
        self.spawn_index_to_delaly_timer[spawn_index] = delay_remove_time or kEffectTime
        self.spawn_index_to_delaly_remove_go[spawn_index] = go
    end
end

return ShootMoneyUI
