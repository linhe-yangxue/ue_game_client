local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local FriendUI = require("UI.FriendUI")
local OtherPlayerMsgUI = class("UI.OtherPlayerMsgUI",UIBase)

local option_str_dict = {
    [UIConst.OtherPlayerMsgOption.PullBlackFriend] = UIConst.Text.PULLBACK_FRIEND_TEXT,
    [UIConst.OtherPlayerMsgOption.DelFriend] = UIConst.Text.DELETE_FRIEND_TEXT,
    [UIConst.OtherPlayerMsgOption.PrivateChat] = UIConst.Text.PRIVATE_CHAT_TEXT,
    [UIConst.OtherPlayerMsgOption.SendMail] = UIConst.Text.SEND_MAIL_TEXT,
    [UIConst.OtherPlayerMsgOption.CheckLineUp] = UIConst.Text.CHECK_LINEUP_TEXT,
    [UIConst.OtherPlayerMsgOption.BattleWithFriend] = UIConst.Text.BATTLE_WITH_PLAYER,
    [UIConst.OtherPlayerMsgOption.AddFriend] = UIConst.Text.ADD_FRIEND_TEXT,
}

function OtherPlayerMsgUI:DoInit()
    OtherPlayerMsgUI.super.DoInit(self)
    self.prefab_path = "UI/Common/OtherPlayerMsgUI"
end

function OtherPlayerMsgUI:OnGoLoadedOk(res_go)
    OtherPlayerMsgUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function OtherPlayerMsgUI:Show(player_info, option_list, cb_dict)
    self.option_list = option_list
    self.cb_dict = cb_dict
    self.player_info = player_info
    if self.is_res_ok then
        self:InitUI()
    end
    OtherPlayerMsgUI.super.Show(self)
end

function OtherPlayerMsgUI:InitRes()
    self.player_mes_frame = self.main_panel:FindChild("PlayerMesFrame")
    self.player_mes_frame_title = self.main_panel:FindChild("PlayerMesFrame/PlayerMesFrameTitle"):GetComponent("Text")
    self.close_btn = self.main_panel:FindChild("PlayerMesFrame/CloseBtn")
    self:AddClick(self.close_btn, function()
        self:Hide()
    end)
    self.btn_list_frame = self.main_panel:FindChild("PlayerMesFrame/BtnList")
    self.temp_btn = self.main_panel:FindChild("PlayerMesFrame/BtnList/TempBtn")

    self.temp_btn:SetActive(false)
end

function OtherPlayerMsgUI:InitUI()
    self:SetTextVal()
    self:UpdateData()
    self:UpdateUIInfo()
end

function OtherPlayerMsgUI:UpdateData()

end

function OtherPlayerMsgUI:UpdateUIInfo()
    FriendUI.SetPlayerItemMes(self.player_mes_frame, self.player_info)
    for i, option in ipairs(self.option_list) do
        local btn = self:GetUIObject(self.temp_btn, self.btn_list_frame)
        btn:FindChild("Text"):GetComponent("Text").text = option_str_dict[option]
        self:AddClick(btn, function()
            local func = self[option]
            func(self)
        end)
    end
end

function OtherPlayerMsgUI:SetTextVal()
    self.player_mes_frame_title.text = UIConst.Text.PLAYER_MES_TEXT
end

function OtherPlayerMsgUI:PullBlackFriend()
    local cb = function()
        self:Hide()
        local cb = self.cb_dict[UIConst.OtherPlayerMsgOption.PullBlackFriend]
        if cb then
            cb(self.player_info)
        end
    end
    SpecMgrs.msg_mgr:SendAddFriendToBlackList({uuid = self.player_info.uuid}, cb)
end

function OtherPlayerMsgUI:DelFriend()
    local cb = function()
        self:Hide()
        local cb = self.cb_dict[UIConst.OtherPlayerMsgOption.DelFriend]
        if cb then
            cb(self.player_info)
        end
    end
    SpecMgrs.msg_mgr:SendDeleteFriend({uuid = self.player_info.uuid}, cb)
end

function OtherPlayerMsgUI:PrivateChat()
    SpecMgrs.ui_mgr:ShowPrivateChat(self.player_info)
    local cb = self.cb_dict and self.cb_dict[UIConst.OtherPlayerMsgOption.DelFriend]
    if cb then cb(self.player_info) end
end

function OtherPlayerMsgUI:SendMail()
    SpecMgrs.ui_mgr:ShowUI("SendMailUI", self.player_info)
end

function OtherPlayerMsgUI:CheckLineUp()
    SpecMgrs.ui_mgr:ShowUI("CheckLineUpUI", self.player_info.uuid)
end

function OtherPlayerMsgUI:AddFriend()
    SpecMgrs.msg_mgr:SendApplyFriend({uuid = self.player_info.uuid}, function (resp)
        if resp.errcode ~= 0 then
            if resp.tips and UIConst.FriendErrorTips[resp.tips] then
                SpecMgrs.ui_mgr:ShowTipMsg(UIConst.FriendErrorTips[resp.tips])
            else
                SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.APPLY_FRIEND_FAILED_TIP)
            end
        else
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.APPLY_FRIEND_SUCCESS_TIP)
        end
    end)
end

function OtherPlayerMsgUI:BattleWithFriend()
    local cb = function(resp)
        if resp.errcode == 1 then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.BATTLE_WITH_PLAYER_FAIL)
            return
        end
        SpecMgrs.ui_mgr:EnterHeroBattle(resp.fight_data)
        SpecMgrs.ui_mgr:RegiseHeroBattleEnd("OtherPlayerMsgUI", function()
            local param_tb = {
                is_win = resp.is_win,
                win_tip = resp.is_win and UIConst.Text.BATTLE_WIN_TIP and UIConst.Text.BATTLE_LOST_TIP,
            }
            SpecMgrs.ui_mgr:AddCloseBattlePopUpList("BattleResultUI", param_tb)
        end)
    end
    SpecMgrs.msg_mgr:SendMsg("SendFightWithFriend", {uuid = self.player_info.uuid}, cb)
end

function OtherPlayerMsgUI:Hide()
    self:DelAllCreateUIObj()
    OtherPlayerMsgUI.super.Hide(self)
end

return OtherPlayerMsgUI
