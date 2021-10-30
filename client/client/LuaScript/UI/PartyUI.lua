local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local PartyUI = class("UI.PartyUI", UIBase)
local UnitConst = require("Unit.UnitConst")
local UIFuncs = require("UI.UIFuncs")

PartyUI.need_sync_load = true

function PartyUI:DoInit()
    PartyUI.super.DoInit(self)
    self.prefab_path = "UI/Common/PartyUI"
    self.dy_party_data = ComMgrs.dy_data_mgr.party_data
end

function PartyUI:OnGoLoadedOk(res_go)
    PartyUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function PartyUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    PartyUI.super.Show(self)
    local join_party_info = self.dy_party_data:GetJoinPartyInfo()
    if join_party_info then
        self:ShowTipPanel(UIConst.Text.CONTINUE_GAME, UIConst.Text.CONTINUE_GAME_CONTENT, function () self:ContinueGame() end)
    end
end

function PartyUI:InitRes()
    UIFuncs.GetInitTopBar(self, self.main_panel, "PartyPanel")
    self.unit_parent = self.main_panel:FindChild("UnitParent")
    self.hold_party_btn = self.main_panel:FindChild("MiddleBtnList/HoldPartyBtn")
    self.hold_party_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.HOLD_PARTY
    self:AddClick(self.hold_party_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("HoldPartyUI")
    end)
    self.join_party_btn = self.main_panel:FindChild("MiddleBtnList/JoinPartyBtn")
    self:AddClick(self.join_party_btn, function ()
        self:JoinPartyBtnOnClick()
    end)
    self.join_party_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.JOIN_PARTY

    self.unit_name_text = self.main_panel:FindChild("MiddleBtnList/Name/Text"):GetComponent("Text")
    self.talk_parent = self.main_panel:FindChild("Talk")

    self.main_panel:FindChild("MiddleBtnList/Desc"):GetComponent("Text").text = UIConst.Text.PLEASE_SELECT_YOUR_ACTION
    self.check_my_party_btn = self.main_panel:FindChild("MiddleBtnList/CheckMyPartyBtn")
    self.check_my_party_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CHECK_MAY_PARTY
    self.check_my_party_btn_red_point = self.check_my_party_btn:FindChild("RedPoint")
    self:AddClick(self.check_my_party_btn, function ()
        local my_party_info = self.dy_party_data:GetMyPartyInfo()
        SpecMgrs.ui_mgr:ShowUI("PartyInfoUI", my_party_info)
    end)

    self.show_point_exchange_btn = self.main_panel:FindChild("ShowPointExchangeBtn")
    self.show_point_exchange_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.POINT_EXCHANGE
    self:AddClick(self.show_point_exchange_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("ShoppingUI", UIConst.ShopList.PartyShop)
    end)
    self.show_rank_btn = self.main_panel:FindChild("ShowRankBtn")
    self.show_rank_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.POINT_RANK
    self:AddClick(self.show_rank_btn, function ()
        SpecMgrs.ui_mgr:ShowRankUI(UIConst.Rank.PartyPoint)
    end)
    self.show_party_record_btn = self.main_panel:FindChild("BottonBar/ShowPartyRecordBtn")
    self.show_party_record_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.PARTY_RECORD
    self:AddClick(self.show_party_record_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("PartyRecordUI")
    end)
end

function PartyUI:InitUI()
    self:RegisterEvent(self.dy_party_data ,"UpdatePartyInfo", function (_, party_info)
        self:UpdatePanel()
    end)
    self:RegisterEvent(ComMgrs.dy_data_mgr, "UpdateCurrencyEvent", function (_, currency)
        UIFuncs.UpdateCurrencyItemNum(self._item_to_text_list, currency)
    end)
    self.my_party_info = self.dy_party_data:GetMyPartyInfo()
    self:UpdatePanel()
    self:_UpdateDefaultUnit()
end

function PartyUI:UpdateTalk()
    if not self.talk_cmp then
        self.talk_cmp = self:GetTalkCmp(self.talk_parent, 2, true, self.GetTalkCb)
    else
        self.talk_cmp:UpdateTalkContent()
    end
end

function PartyUI:GetTalkCb()
    if not self.is_res_ok then return end
    local str
    local party_info =  self.dy_party_data:GetMyPartyInfo()
    if party_info then
        local is_end = party_info.is_end or false
        self.check_my_party_btn_red_point:SetActive(is_end)
        str = is_end and UIConst.Text.MY_PARTY_END or UIConst.Text.MY_PARTY_IN_PROGRESS
    else
        str = UIConst.Text.PARTY_DEFAULT_TEXT
    end
    return str
end

function PartyUI:UpdatePanel()
    self.my_party_info = self.dy_party_data:GetMyPartyInfo()
    local my_party_info = self.my_party_info
    local is_show_check_my_party_btn = my_party_info and true or false
    self.check_my_party_btn:SetActive(is_show_check_my_party_btn)
    self.hold_party_btn:SetActive(not is_show_check_my_party_btn)
    self:UpdateTalk()
end

function PartyUI:ContinueGame()
    local join_party_info = self.dy_party_data:GetJoinPartyInfo()
    if join_party_info then
        SpecMgrs.ui_mgr:ShowUI("PartyInfoUI", join_party_info)
    else
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.PARTY_ALREADY_END)
    end
end

function PartyUI:ShowTipPanel(title_str, content_str, confirm_cb, cancel_cb)
    local param_tb = {title = title_str, content = content_str, confirm_cb = confirm_cb, cancel_cb = cancel_cb}
    SpecMgrs.ui_mgr:ShowMsgSelectBox(param_tb)
end

function PartyUI:_UpdateDefaultUnit()
    local unit_id = SpecMgrs.data_mgr:GetParamData("party_default_unit").unit_id
    self:CleanDefaultUnit()
    self.unit_id = unit_id
    self.unit_name_text.text = SpecMgrs.data_mgr:GetUnitData(unit_id).name
    self.unit = self:AddFullUnit(unit_id, self.unit_parent)
end

function PartyUI:CleanDefaultUnit()
    if self.unit then
        ComMgrs.unit_mgr:DestroyUnit(self.unit)
        self.unit = nil
        self.unit_id = nil
    end
end

function PartyUI:Hide()
    self.dy_party_data:UnregisterUpdatePartyInfo("PartyUI")
    self:CleanDefaultUnit()
    PartyUI.super.Hide(self)
end

function PartyUI:JoinPartyBtnOnClick()
    local my_guest_info = self.dy_party_data:GetMyGuestInfo()
    local join_party_info = self.dy_party_data:GetJoinPartyInfo()
    if join_party_info and not join_party_info.end_type and my_guest_info and my_guest_info.games_num and my_guest_info.games_num > 0 then
        self:ShowTipPanel(UIConst.Text.GIVE_UP_GAME,
            UIConst.Text.GIVE_UP_GAME_CONTENT,
            function () self:ShowSelectPartyUI() end,
            function () self:ShowJoinParty() end)
    else
        self:ShowSelectPartyUI()
    end
end

function PartyUI:ShowSelectPartyUI()
    SpecMgrs.ui_mgr:ShowUI("SelectPartyUI")
end

function PartyUI:ShowJoinParty()
    local join_party_info = self.dy_party_data:GetJoinPartyInfo()
    SpecMgrs.ui_mgr:ShowUI("PartyInfoUI", join_party_info)
end

return PartyUI