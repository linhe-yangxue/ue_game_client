local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local TraitorInfoUI = class("UI.TraitorInfoUI", UIBase)

function TraitorInfoUI:DoInit()
    TraitorInfoUI.super.DoInit(self)
    self.prefab_path = "UI/Common/TraitorInfoUI"
    self.traitor_challenge_recover_item = SpecMgrs.data_mgr:GetParamData("traitor_challenge_recover_item").item_id
    self.traitor_challenge_recover_item_data = SpecMgrs.data_mgr:GetItemData(self.traitor_challenge_recover_item)
    self.traitor_halve_cost_time = SpecMgrs.data_mgr:GetParamData("traitor_challenge_halve_cost").tb_int
    self.traitor_double_reward_time = SpecMgrs.data_mgr:GetParamData("traitor_challenge_double_reward").tb_int
    self.traitor_challenge_cost = SpecMgrs.data_mgr:GetParamData("traitor_challenge_cost").f_value
    self.traitor_challenge_double_cost = SpecMgrs.data_mgr:GetParamData("traitor_challenge_double_cost").f_value
    self.traitor_challenge_ticket_limit = SpecMgrs.data_mgr:GetParamData("traitor_challenge_ticket_limit").f_value
    self.dy_traitor_data = ComMgrs.dy_data_mgr.traitor_data
end

function TraitorInfoUI:OnGoLoadedOk(res_go)
    TraitorInfoUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function TraitorInfoUI:Hide()
    self.dy_traitor_data:UnregisterUpdateWantedCountEvent("TraitorInfoUI")
    self:RemoveUnit(self.traitor_unit)
    self:RemoveDynamicUI(self.traitor_disapear_time)
    self.mask:SetActive(false)
    TraitorInfoUI.super.Hide(self)
end

function TraitorInfoUI:Show(traitor_info)
    if not traitor_info then return end
    self.traitor_info = traitor_info
    if self.is_res_ok then
        self:InitUI()
    end
    TraitorInfoUI.super.Show(self)
end

function TraitorInfoUI:InitRes()
    local top_panel = self.main_panel:FindChild("Content/Top")
    self:AddClick(top_panel:FindChild("CloseBtn"), function ()
        self:Hide()
    end)
    self.traitor_name = top_panel:FindChild("TraitorName"):GetComponent("Text")

    local info_panel = self.main_panel:FindChild("Content/InfoPanel")
    self.traitor_model = info_panel:FindChild("TraitorModel")
    self.traitor_dead = info_panel:FindChild("Dead")
    self.traitor_dead:FindChild("Text"):GetComponent("Text").text = UIConst.Text.TRAITOR_DEAD_TEXT
    self.traitor_level = info_panel:FindChild("TraitorLevel"):GetComponent("Text")
    self.traitor_disapear_time = info_panel:FindChild("DisapearTime")
    self.traitor_disapear_time_text = self.traitor_disapear_time:GetComponent("Text")

    local middle_panel = self.main_panel:FindChild("Content/Middle")
    local lineup_btn = middle_panel:FindChild("LineupBtn")
    lineup_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.LINEUP
    self:AddClick(lineup_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("SmallLineupUI")
    end)
    middle_panel:FindChild("Tip"):GetComponent("Text").text = UIConst.Text.ATTACK_TRAITOR_TIP

    local bottom_panel = self.main_panel:FindChild("Content/Bottom")
    local wanted_count_panel = bottom_panel:FindChild("WantedCount")
    -- wanted_count_panel:FindChild("Name"):GetComponent("Text").text = self.traitor_challenge_recover_item_data.name
    wanted_count_panel:FindChild("Name"):GetComponent("Text").text = UIConst.Text.TRAITOR_WANTED_COUNT
    -- UIFuncs.AssignSpriteByIconID(self.traitor_challenge_recover_item_data.icon, wanted_count_panel:FindChild("Icon"):GetComponent("Image"))
    self.wanted_count = wanted_count_panel:FindChild("Count"):GetComponent("Text")
    self:AddClick(wanted_count_panel:FindChild("AddBtn"), function ()
        self:ShowChallengeItemUsePanel()
    end)
    local traitor_hp_bar = bottom_panel:FindChild("HpBar")
    self.traitor_hp_value = traitor_hp_bar:FindChild("Value"):GetComponent("Image")
    self.traitor_hp_text = traitor_hp_bar:FindChild("Text"):GetComponent("Text")
    local effect1 = bottom_panel:FindChild("Effect1")
    effect1:FindChild("Time"):GetComponent("Text").text = string.format(UIConst.Text.INTEGER_TIME_DURATION_FORMAT, self.traitor_halve_cost_time[1], self.traitor_halve_cost_time[2])
    effect1:FindChild("EffectDesc"):GetComponent("Text").text = UIConst.Text.TRAITOR_HALVE_COST_TIME_TEXT
    local effect2 = bottom_panel:FindChild("Effect2")
    effect2:FindChild("Time"):GetComponent("Text").text = string.format(UIConst.Text.INTEGER_TIME_DURATION_FORMAT, self.traitor_double_reward_time[1], self.traitor_double_reward_time[2])
    effect2:FindChild("EffectDesc"):GetComponent("Text").text = UIConst.Text.TRAITOR_DOUBLE_REWARD_TIME_TEXT

    local btn_list = self.main_panel:FindChild("Content/BtnList")
    local normal_btn = btn_list:FindChild("NormalBtn")
    normal_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.TRAITOR_NORMAL_CHALLENGE
    self:AddClick(normal_btn, function ()
        self:SendChallengeTraitor(CSConst.TraitorAttackType.One, self.traitor_challenge_cost)
    end)
    local normal_cost_panel = normal_btn:FindChild("Cost")
    normal_cost_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.COST_TEXT
    UIFuncs.AssignSpriteByIconID(self.traitor_challenge_recover_item_data.icon, normal_cost_panel:FindChild("Icon"):GetComponent("Image"))
    normal_cost_panel:FindChild("Count"):GetComponent("Text").text = self.traitor_challenge_cost

    local full_blow_btn = btn_list:FindChild("FullBlowBtn")
    full_blow_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.TRAITOR_FULL_BLOW_CHALLENGE
    self:AddClick(full_blow_btn, function ()
        self:SendChallengeTraitor(CSConst.TraitorAttackType.Two, self.traitor_challenge_double_cost)
    end)
    local full_blow_cost_panel = full_blow_btn:FindChild("Cost")
    full_blow_cost_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.COST_TEXT
    UIFuncs.AssignSpriteByIconID(self.traitor_challenge_recover_item_data.icon, full_blow_cost_panel:FindChild("Icon"):GetComponent("Image"))
    full_blow_cost_panel:FindChild("Count"):GetComponent("Text").text = self.traitor_challenge_double_cost

    self.mask = self.main_panel:FindChild("Mask")
end

function TraitorInfoUI:InitUI()
    local traitor_data = SpecMgrs.data_mgr:GetTraitorData(self.traitor_info.traitor_id)
    self.traitor_max_hp = self.traitor_info.max_hp
    self.traitor_name.text = self.dy_traitor_data:GetTraitorName(self.traitor_info.traitor_id, self.traitor_info.quality)
    self.traitor_unit = self:AddHalfUnit(traitor_data.unit_id, self.traitor_model)
    self.traitor_level.text = string.format(UIConst.Text.TRAITOR_LEVEL_FORMAT, self.traitor_info.traitor_level)
    local escape_time = self.traitor_info.appear_ts + traitor_data.run_time * CSConst.Time.Hour
    self:AddDynamicUI(self.traitor_disapear_time, function ()
        local left_sec = escape_time - Time:GetServerTime()
        if left_sec <= 0 then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.TRAITOR_ESCAPE_TEXT)
            self:Hide()
        end
        self.traitor_disapear_time_text.text = string.format(UIConst.Text.TRAITOR_ESCAPE_TIME_FORMAT, UIFuncs.TimeDelta2Str(left_sec))
    end, 1, 0)
    self:UpdateWantedCount()
    self:UpdateTraitorInfo(self.traitor_info)
    self.dy_traitor_data:RegisterUpdateWantedCountEvent("TraitorInfoUI", self.UpdateWantedCount, self)
end

function TraitorInfoUI:UpdateTraitorInfo(traitor_info)
    local cur_hp = self.dy_traitor_data:CalcTraitorHp(traitor_info)
    self.traitor_hp_value.fillAmount = cur_hp / self.traitor_max_hp
    -- self.traitor_hp_text.text = string.format(UIConst.Text.TRAITOR_HP_FORMAT, UIFuncs.AddCountUnit(cur_hp), UIFuncs.AddCountUnit(traitor_info.max_hp))
    self.traitor_hp_text.text = string.format(UIConst.Text.TRAITOR_HP_FORMAT, cur_hp, self.traitor_max_hp)
    self.traitor_dead:SetActive(cur_hp <= 0)
    self.traitor_disapear_time:SetActive(cur_hp > 0)
    if cur_hp <= 0 then
        self.traitor_unit:ChangeToGray()
        self.traitor_unit:StopAllAnimationToCurPos()
        self:RemoveDynamicUI(self.traitor_disapear_time)
    end
end

function TraitorInfoUI:UpdateWantedCount()
    self.wanted_count.text = string.format(UIConst.Text.PER_VALUE, self.dy_traitor_data:GetWantedCount(), self.traitor_challenge_ticket_limit)
end

function TraitorInfoUI:ShowChallengeItemUsePanel()
    local max_select_num = self.traitor_challenge_ticket_limit - self.dy_traitor_data:GetWantedCount()
    if max_select_num <= 0 then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.RECOVER_TRAITOR_CHALLENGE_COUNT_LIMIT)
        return
    end
    SpecMgrs.ui_mgr:ShowSelectItemUseByTb({
        get_content_func = function (count)
            local content_tb = {
                item_dict = {
                    [self.traitor_challenge_recover_item] = count,
                },
                desc_str = string.format(UIConst.Text.CONFIRM_USE_ITEM, count, self.traitor_challenge_recover_item_data.name, UIConst.Text.RECOVER_TRAITOR_CHALLENGE_COUNT),
            }
            return content_tb
        end,
        max_select_num = max_select_num,
        confirm_cb = function (count)
            self:SendRecoverTraitorChallengeCount(count)
        end,
    })
end

function TraitorInfoUI:SendRecoverTraitorChallengeCount(count)
    SpecMgrs.msg_mgr:SendAddTraitorChallengeTicket({item_count = count}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.RECOVER_TRAITOR_CHALLENGE_COUNT_FAILED)
        end
    end)
end

function TraitorInfoUI:SendChallengeTraitor(attack_type, cost)
    if not self.dy_traitor_data:CheckWantedCountEnough(cost) then
        self:ShowChallengeItemUsePanel()
        return
    end
    self.mask:SetActive(true)
    SpecMgrs.msg_mgr:SendChallengeTraitor({traitor_guid = self.traitor_info.traitor_guid, attack_type = attack_type}, function (resp)
        self.mask:SetActive(false)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.TRAITOR_CHALLENGE_REQUEST_FAILED)
        else
            if resp.tips == CSConst.TraitorTips.HasDeath then
                SpecMgrs.data_mgr:ShowMsgBox(UIConst.Text.CHALLENGE_TRAITOR_DEAD)
                self:UpdateTraitorInfo()
                return
            end
            if not resp.fight_data then return end
            self.main_panel:SetActive(false)
            SpecMgrs.ui_mgr:EnterHeroBattle(resp.fight_data, UIConst.BattleScence.TraitorInfoUI)
            SpecMgrs.ui_mgr:RegiseHeroBattleEnd("DynastyChallengeUI", function()
                self:BattleEnd(resp)
            end)
        end
    end)
end

function TraitorInfoUI:BattleEnd(msg)
    local reward_dict = {}
    reward_dict[CSConst.Virtual.Feats] = msg.feats
    reward_dict[CSConst.Virtual.TraitorCoin] = msg.traitor_coin
    local hurt_text = UIFuncs.AddCountUnit(msg.hurt)
    local hurt_rank_text = self:GetRankChangeText(msg.old_hurt_rank, msg.new_hurt_rank, UIConst.Text.TRAITOR_TRAITOR_COIN_FORMAT)
    local feat_rank_text = self:GetRankChangeText(msg.old_feats_rank, msg.new_feats_rank, UIConst.Text.TRAITOR_COIN_RANK_FORMAT)
    local win_tip = string.format(UIConst.Text.TRAITOR_CHALLENGE_RESULT_FORMAT, hurt_text, hurt_rank_text, feat_rank_text)
    local param_tb = {
        is_win = msg.is_win,
        reward = reward_dict,
        win_tip = win_tip,
        func = function ()
            if not self.is_res_ok then return end
            self.main_panel:SetActive(true)
            if not msg.is_win and self.dy_traitor_data:CheckTraitorShareState(msg.traitor_info) then
                SpecMgrs.ui_mgr:ShowUI("ShareTraitorUI")
            end
            self:UpdateTraitorInfo(msg.traitor_info)
        end
    }
    SpecMgrs.ui_mgr:AddCloseBattlePopUpList("BattleResultUI", param_tb)
end

function TraitorInfoUI:GetRankChangeText(last_rank, cur_rank, rank_format)
    local rank_text = ""
    if not cur_rank then return "" end
    if last_rank and cur_rank >= last_rank then return "" end
    local lask_rank_text = last_rank or UIConst.Text.NOT_ON_RANKING
    return string.format(rank_format, lask_rank_text, cur_rank)
end

return TraitorInfoUI