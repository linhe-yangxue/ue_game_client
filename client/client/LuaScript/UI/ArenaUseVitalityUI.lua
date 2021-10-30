local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local ArenaUseVitalityUI = class("UI.ArenaUseVitalityUI",UIBase)

local item_id = 201002  --活力丹
local max_challenge_time = 99

--  竞技场物品使用
function ArenaUseVitalityUI:DoInit()
    ArenaUseVitalityUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ArenaUseVitalityUI"
end

function ArenaUseVitalityUI:OnGoLoadedOk(res_go)
    ArenaUseVitalityUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function ArenaUseVitalityUI:Show(target_uuid)
    self.target_uuid = target_uuid
    if self.is_res_ok then
        self:InitUI()
    end
    ArenaUseVitalityUI.super.Show(self)
end

function ArenaUseVitalityUI:InitRes()
    self.close_btn = self.main_panel:FindChild("Content/TopPanel/CloseBtn")
    self:AddClick(self.close_btn, function()
        self:Hide()
    end)
    self.set_challenge_time_text = self.main_panel:FindChild("Content/ContentPanel/SetChallengeTimeText"):GetComponent("Text")
    self.consume_vitality_text = self.main_panel:FindChild("Content/ContentPanel/ConsumeVitalityText"):GetComponent("Text")
    self.remind_toggle_label = self.main_panel:FindChild("Content/ContentPanel/RemindToggle/RemindToggleLabel"):GetComponent("Text")
    self.confirm_btn = self.main_panel:FindChild("Content/ContentPanel/ConfirmBtn")
    self:AddClick(self.confirm_btn, function()
        self:SendMes()
        self:Hide()
    end)
    self.confirm_btn_text = self.main_panel:FindChild("Content/ContentPanel/ConfirmBtn/ConfirmBtnText"):GetComponent("Text")
    self.cancel_btn = self.main_panel:FindChild("Content/ContentPanel/CancelBtn")
    self:AddClick(self.cancel_btn, function()
        self:Hide()
    end)
    self.cancel_btn_text = self.main_panel:FindChild("Content/ContentPanel/CancelBtn/CancelBtnText"):GetComponent("Text")
    self.add_one_button = self.main_panel:FindChild("Content/ContentPanel/AddOneButton")
    self:AddClick(self.add_one_button, function()
        self:AddVal(1)
    end)
    self.reduce_one_button = self.main_panel:FindChild("Content/ContentPanel/ReduceOneButton")
    self:AddClick(self.reduce_one_button, function()
        self:AddVal(-1)
    end)
    self.add_ten_button = self.main_panel:FindChild("Content/ContentPanel/AddTenButton")
    self:AddClick(self.add_ten_button, function()
       self:AddVal(10)
    end)
    self.reduce_ten_button = self.main_panel:FindChild("Content/ContentPanel/ReduceTenButton")
    self:AddClick(self.reduce_ten_button, function()
        self:AddVal(-10)
    end)
    self.num_text = self.main_panel:FindChild("Content/ContentPanel/Num/NumText"):GetComponent("Text")

    self.remind_toggle = self.main_panel:FindChild("Content/ContentPanel/RemindToggle"):GetComponent("Toggle")
end

function ArenaUseVitalityUI:InitUI()
    self.challenge_num = ComMgrs.dy_data_mgr:EXGetArenaChallengeTime() or 1
    self:SetTextVal()
    self:UpdateNumText()
end

function ArenaUseVitalityUI:UpdateNumText()
    self.num_text.text = self.challenge_num
    local val = self.challenge_num * SpecMgrs.data_mgr:GetParamData("arena_cost_vitality").f_value
    self.consume_vitality_text.text = string.format(UIConst.Text.CONSUME_VITALITY_TEXT, val)
end

function ArenaUseVitalityUI:SetTextVal()
    self.set_challenge_time_text.text = UIConst.Text.SET_CHALLENGE_TIME_TEXT
    self.remind_toggle_label.text = UIConst.Text.REMIND_VITALITY_ITEM_TEXT
    self.confirm_btn_text.text = UIConst.Text.CONFIRM
    self.cancel_btn_text.text = UIConst.Text.CANCEL
end

function ArenaUseVitalityUI:AddVal(val)
    self.challenge_num = math.clamp(self.challenge_num + val, 1, max_challenge_time)
    self:UpdateNumText()
end

function ArenaUseVitalityUI:SendMes()
    ComMgrs.dy_data_mgr:EXSetArenaChallengeTime(self.challenge_num)
    local param_tb = {
        uuid = self.target_uuid,
        challenge_count = self.challenge_num,
        auto_use_item = self.remind_toggle.isOn,
    }
    local cb = function(resp)
        if resp.real_challenge_count == 0 then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.NO_VITALITY_TIP_TEXT)
        else
            SpecMgrs.ui_mgr:AddToPopUpList("ArenReportUI", resp.real_challenge_count, resp.reward_dict, resp.random_reward)
        end
    end
    SpecMgrs.msg_mgr:SendArenaQuickChallenge(param_tb, cb)
end

return ArenaUseVitalityUI
