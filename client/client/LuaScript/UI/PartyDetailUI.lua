local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local PartyDetailUI = class("UI.PartyDetailUI", UIBase)
local UIFuncs = require("UI.UIFuncs")

PartyDetailUI.need_sync_load = true

function PartyDetailUI:DoInit()
    PartyDetailUI.super.DoInit(self)
    self.prefab_path = "UI/Common/PartyDetailUI"
    self.party_gift_data_list = SpecMgrs.data_mgr:GetAllPartyGiftData()
    self.dy_party_data = ComMgrs.dy_data_mgr.party_data
    self.item_list = {}
end

function PartyDetailUI:OnGoLoadedOk(res_go)
    PartyDetailUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function PartyDetailUI:Show(party_info)
    self.party_info = party_info
    if self.is_res_ok then
        self:InitUI()
    end
    PartyDetailUI.super.Show(self)
end

function PartyDetailUI:InitRes()
    UIFuncs.GetInitTopBar(self, self.main_panel, "PartyDetailUI")
    local title_go = self.main_panel:FindChild("GustList/Title")
    title_go:FindChild("Player/Text"):GetComponent("Text").text = UIConst.Text.PLAYER_TEXT
    title_go:FindChild("Server/Text"):GetComponent("Text").text = UIConst.Text.PLAYER_SERVER_TEXT
    title_go:FindChild("Level/Text"):GetComponent("Text").text = UIConst.Text.LEVEL_TEXT
    title_go:FindChild("Gift/Text"):GetComponent("Text").text = UIConst.Text.PARTY_GIFT
    self.item_parent = self.main_panel:FindChild("GustList/Viewport/Content")
    self.item_temp = self.item_parent:FindChild("Temp")
    self.item_temp:SetActive(false)
    self.lover_add_ratio_text = self.main_panel:FindChild("BottomBar/LoverAddRatio"):GetComponent("Text")
    self.score_text = self.main_panel:FindChild("BottomBar/Score"):GetComponent("Text")
end

function PartyDetailUI:InitUI()
    self:ClearGoDict("item_list")
    local guests_list = self.party_info.guests_list
    for i, guest_info in ipairs(guests_list) do
        local go = self:GetUIObject(self.item_temp, self.item_parent)
        table.insert(self.item_list, go)
        go:FindChild("Player/Text"):GetComponent("Text").text = guest_info.role_info.name
        go:FindChild("Server/Text"):GetComponent("Text").text = UIFuncs.GetServerName(guest_info.role_info.server_id)
        go:FindChild("Level/Text"):GetComponent("Text").text = guest_info.role_info.level
        local party_type_data = self.party_gift_data_list[guest_info.gift_id]
        go:FindChild("Gift/Text"):GetComponent("Text").text = party_type_data.cost_item_count_list[1]
    end
    self.lover_add_ratio_text.text = UIFuncs.GetPercentStr(self.party_info.add_ratio, UIConst.Text.POINT_ADD_RATIO)
    self.score_text.text = string.format(UIConst.Text.PARTY_POINT_ALREADY_GET, self.party_info.integral_count)
end

function PartyDetailUI:Hide()
    self:ClearGoDict("item_list")
    PartyDetailUI.super.Hide(self)
end

return PartyDetailUI