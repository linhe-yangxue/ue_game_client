local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local SelectPartyGameUI = class("UI.SelectPartyGameUI",UIBase)

function SelectPartyGameUI:DoInit()
    SelectPartyGameUI.super.DoInit(self)
    self.prefab_path = "UI/Common/SelectPartyGameUI"
    self.party_game_data_list = SpecMgrs.data_mgr:GetAllPartyGameData()
    self.dy_party_data = ComMgrs.dy_data_mgr.party_data
end

function SelectPartyGameUI:OnGoLoadedOk(res_go)
    SelectPartyGameUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function SelectPartyGameUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    SelectPartyGameUI.super.Show(self)
end

function SelectPartyGameUI:InitRes()
    UIFuncs.GetInitTopBar(self, self.main_panel, "SelectPartyGameUI")
    self.game_go_parent = self.main_panel:FindChild("Scroll View/Viewport/Content")
    self.game_go_temp = self.game_go_parent:FindChild("Item")
    self.game_go_temp:SetActive(false)
    for i, game_data in ipairs(self.party_game_data_list) do
        local go = self:GetUIObject(self.game_go_temp, self.game_go_parent)
        self:AssignSpriteByIconID(game_data.icon, go:FindChild("Icon"):GetComponent("Image"))
        go:FindChild("PartyInfo/Introduce"):GetComponent("Text").text = game_data.introduce_str
        go:FindChild("Right/JoinBtn/Text"):GetComponent("Text").text = UIConst.Text.JOIN
        self:AddClick(go:FindChild("Right/JoinBtn"), function ()
            if not self.dy_party_data:CanStartGame(true) then
                return
            end
            if game_data.ui then
                SpecMgrs.ui_mgr:ShowUI(game_data.ui)
            end
        end)
        go:FindChild("PartyInfo/Title"):GetComponent("Text").text = game_data.name
    end
end

function SelectPartyGameUI:InitUI()
end

function SelectPartyGameUI:Hide()
    SelectPartyGameUI.super.Hide(self)
end

return SelectPartyGameUI
