local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local ScoreUpUI = class("UI.ScoreUpUI", UIBase)

local kCountAnimDelay = 0.25
local kCountAnimInterval = 0.05
local kCountAnimDuration = 0.8
local kAutoHideTime = 2

function ScoreUpUI:DoInit()
    ScoreUpUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ScoreUpUI"
    self.number_up_sound = SpecMgrs.data_mgr:GetParamData("number_up_sound").sound_id
    self.attr_item_dict = {}
end

function ScoreUpUI:OnGoLoadedOk(res_go)
    ScoreUpUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function ScoreUpUI:Hide()
    for _, attr_item in pairs(self.attr_item_dict) do
        self:DelUIObject(attr_item)
    end
    self.attr_item_dict = {}
    self:RemoveDynamicUI(self.score)
    self:RemoveDynamicUI(self.fight_score)
    self.content:SetActive(false)
    self.add_score = nil
    self.attr_dict = nil
    self.auto_hide_timer = nil
    ScoreUpUI.super.Hide(self)
end

function ScoreUpUI:Show(last_score, last_fight_score)
    self.last_score = last_score
    self.last_fight_score = last_fight_score
    if self.is_res_ok then
        self:InitUI()
    end
    ScoreUpUI.super.Show(self)
end

function ScoreUpUI:InitRes()
    self:AddClick(self.main_panel, function ()
        self.content:SetActive(false)
        self:Hide()
    end)
    self.content = self.main_panel:FindChild("Content")
    local attr_content = self.content:FindChild("AttrContent")
    self.score = attr_content:FindChild("Score")
    self.score_value = self.score:FindChild("Value"):GetComponent("Text")
    self.score_up_img = self.score:FindChild("UpImg")
    self.score_down_img = self.score:FindChild("DownImg")
    self.fight_score = attr_content:FindChild("FightScore")
    self.fight_score_value = self.fight_score:FindChild("Value"):GetComponent("Text")
    self.fight_score_up_img = self.fight_score:FindChild("UpImg")
    self.fight_score_down_img = self.fight_score:FindChild("DownImg")
end

function ScoreUpUI:InitUI()
    if not self.last_score or not self.last_fight_score then
        self:Hide()
        return
    end
    local score_diff = math.floor(ComMgrs.dy_data_mgr:ExGetRoleScore() - self.last_score)
    local fight_score_diff = math.floor(ComMgrs.dy_data_mgr:ExGetFightScore() - self.last_fight_score)
    if score_diff == 0 and fight_score_diff == 0 then
        self:Hide()
        return
    end
    self.score:SetActive(score_diff ~= 0)
    self.fight_score:SetActive(fight_score_diff ~= 0)
    self.content:SetActive(true)
    self:PlayUISound(self.number_up_sound)
    self.count_anim_timer = self:AddTimer(function ()
        if score_diff ~= 0 then
            self.score_up_img:SetActive(score_diff > 0)
            self.score_down_img:SetActive(score_diff < 0)
            self:AddCountEffect(self.score, self.score_value, score_diff, UIConst.Text.SCORE_UP_FORMAT)
        end
        if fight_score_diff ~= 0 then
            self.fight_score_up_img:SetActive(fight_score_diff > 0)
            self.fight_score_down_img:SetActive(fight_score_diff < 0)
            self:AddCountEffect(self.fight_score, self.fight_score_value, fight_score_diff, UIConst.Text.FIGHT_SCORE_UP_FORMAT)
        end
    end, kCountAnimDelay)
    self.auto_hide_timer = 0
end

function ScoreUpUI:AddCountEffect(text_go, text_cmp, diff, format)
    local count = kCountAnimDuration / kCountAnimInterval
    local cur_score = 0
    local add_pct_value = diff / count
    local color = diff > 0 and UIConst.Color.Green1 or UIConst.Color.Red1
    self:AddDynamicUI(text_go, function ()
        if diff > 0 then
            cur_score = math.min(cur_score + add_pct_value, diff)
        else
            cur_score = math.max(cur_score + add_pct_value, diff)
        end
        local temp_score = math.floor(cur_score)
        text_cmp.text = string.format(format, color, cur_score < 0 and temp_score or ("+" .. temp_score))
    end, kCountAnimInterval, count)
end

function ScoreUpUI:Update(delta_time)
    if self.auto_hide_timer then
        self.auto_hide_timer = self.auto_hide_timer + delta_time
        if self.auto_hide_timer > kAutoHideTime then
            self:Hide()
        end
    end
end

return ScoreUpUI