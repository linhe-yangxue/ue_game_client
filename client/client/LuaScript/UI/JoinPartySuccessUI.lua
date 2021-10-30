local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local JoinPartySuccessUI = class("UI.JoinPartySuccessUI", UIBase)
local UnitConst = require("Unit.UnitConst")
local UIFuncs = require("UI.UIFuncs")

JoinPartySuccessUI.need_sync_load = true

function JoinPartySuccessUI:DoInit()
    JoinPartySuccessUI.super.DoInit(self)
    self.prefab_path = "UI/Common/JoinPartySuccessUI"
end

function JoinPartySuccessUI:OnGoLoadedOk(res_go)
    JoinPartySuccessUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function JoinPartySuccessUI:Show(party_gift_id, lover_level)
    self.party_gift_data = SpecMgrs.data_mgr:GetPartyGiftData(party_gift_id)
    self.lover_level = lover_level
    if self.is_res_ok then
        self:InitUI()
    end
    JoinPartySuccessUI.super.Show(self)
end

function JoinPartySuccessUI:InitRes()
    self:AddClick(self.main_panel:FindChild("CloseBg"), function()
        SpecMgrs.ui_mgr:HideUI(self)
    end)
    self.main_panel:FindChild("Frame/Up/Text"):GetComponent("Text").text = UIConst.Text.SUCCESS_JOIN_PARTY
    self.main_panel:FindChild("Frame/Text"):GetComponent("Text").text = UIConst.Text.CLOSE_TIP_TEXT
    local content_go = self.main_panel:FindChild("Frame/Content")

    self.party_point_text = content_go:FindChild("Desc1"):GetComponent("Text")
    self.reward_item_go = UIFuncs.GetIconGo(self, content_go:FindChild("Item"), nil, UIConst.PrefabResPath.Item)
    self.reward_item_count_text = content_go:FindChild("Desc2"):GetComponent("Text")
    self.game_num_text = content_go:FindChild("Desc3"):GetComponent("Text")
end

function JoinPartySuccessUI:InitUI()
    local param_tb = {go = self.reward_item_go, item_id = self.party_gift_data.reward_item_list[1]}
    UIFuncs.InitItemGo(param_tb)
    self.reward_item_count_text.text = string.format(UIConst.Text.ITEM_NAME_COUNT, param_tb.item_data.name, self.party_gift_data.reward_item_count_list[1])
    self.game_num_text.text = string.format(UIConst.Text.CAN_PLAY_GAME_TO_GET_MORE_POINT, self.party_gift_data.games_num)
    local party_point = ComMgrs.dy_data_mgr.party_data:GetJoinPartyPoint(self.party_gift_data.init_party_point, self.lover_level)
    self.party_point_text.text = string.format(UIConst.Text.POINT, party_point)
end

function JoinPartySuccessUI:Hide()
    self.party_gift_data = nil
    self.lover_level = nil
    JoinPartySuccessUI.super.Hide(self)
end

return JoinPartySuccessUI