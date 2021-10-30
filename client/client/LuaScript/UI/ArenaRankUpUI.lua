local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local ArenaRankUpUI = class("UI.ArenaRankUpUI",UIBase)

--  升级界面
function ArenaRankUpUI:DoInit()
    ArenaRankUpUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ArenaRankUpUI"
    self.share_arena_rank = SpecMgrs.data_mgr:GetParamData("share_arena_rank").f_value
end

function ArenaRankUpUI:OnGoLoadedOk(res_go)
    ArenaRankUpUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function ArenaRankUpUI:Show(cur_rank, add_rank, reward_num)
    self.cur_rank = cur_rank
    self.add_rank = add_rank
    self.reward_num = reward_num
    if self.is_res_ok then
        self:InitUI()
    end
    ArenaRankUpUI.super.Show(self)
end

function ArenaRankUpUI:InitRes()
    self.rank_break_text = self.main_panel:FindChild("Frame/RankBreakText"):GetComponent("Text")
    self.rank_rise_text = self.main_panel:FindChild("Frame/RankRiseText"):GetComponent("Text")
    self.rank_rise_val_text = self.main_panel:FindChild("Frame/RankRiseValText"):GetComponent("Text")
    self.rank_reward_text = self.main_panel:FindChild("Frame/RankRewardText"):GetComponent("Text")
    self.rank_reward_val_text = self.main_panel:FindChild("Frame/RankRewardValText"):GetComponent("Text")

    self:AddClick(self.main_panel:FindChild("Mask"), function()
        self:Hide()
    end)
end

function ArenaRankUpUI:InitUI()
    self:SetTextVal()
    self:UpdateData()
    self:UpdateUIInfo()
    if self.cur_rank <= self.share_arena_rank then
        SpecMgrs.ui_mgr:ShowShareUI()
    end
end

function ArenaRankUpUI:UpdateData()

end

function ArenaRankUpUI:UpdateUIInfo()
    self.rank_rise_val_text.text = string.format(UIConst.Text.RANK_FROMAT, self.add_rank)
    self.rank_reward_val_text.text = self.reward_num
    self.rank_break_text.text = string.format(UIConst.Text.RANK_BREAK_FORMAT, self.cur_rank)
end

function ArenaRankUpUI:SetTextVal()
    self.rank_break_text.text = UIConst.Text.RANK_BREAK_FORMAT
    self.rank_rise_text.text = UIConst.Text.RANK_RISE_TEXT
    self.rank_reward_text.text = UIConst.Text.RANK_REWARD_TEXT
end

function ArenaRankUpUI:Hide()
    self:DelAllCreateUIObj()
    ArenaRankUpUI.super.Hide(self)
end

return ArenaRankUpUI
