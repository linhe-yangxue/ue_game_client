local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local TabViewCmp = require("UI.UICmp.TabViewCmp")
local UIFuncs = require("UI.UIFuncs")
local PartyInviteUI = class("UI.PartyInviteUI", UIBase)

local InviteTarget = CSConst.Party.InviteTarget
local InviteStatus = CSConst.Party.InviteStatus
local kSelectFunc = {
    [1] = "InitInvietFriendPanel",
    [2] = "InitInvietAllyPanel",
}

function PartyInviteUI:DoInit()
    PartyInviteUI.super.DoInit(self)
    self.prefab_path = "UI/Common/PartyInviteUI"
    self.dy_party_data = ComMgrs.dy_data_mgr.party_data
    self.ifp_uuid_to_go = {}
    self.iap_uuid_to_go = {}
end

function PartyInviteUI:OnGoLoadedOk(res_go)
    PartyInviteUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function PartyInviteUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    PartyInviteUI.super.Show(self)
end

function PartyInviteUI:InitRes()
    UIFuncs.GetInitTopBar(self, self.main_panel, "PartyInvitePanel")

    local content = self.main_panel:FindChild("Content")
    self.invite_friend_panel = content:FindChild("InviteFriendPanel")
    self.invite_friend_panel_btn = self.main_panel:FindChild("SelectBtnList/InviteFriendBtn")
    self.invite_friend_panel_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.INVITE_FRIEND
    self.invite_friend_panel_btn:FindChild("Selected/Text"):GetComponent("Text").text = UIConst.Text.INVITE_FRIEND
    self.ifp_item_parent = self.invite_friend_panel:FindChild("Viewport/ItemList")
    self.item_temp = self.ifp_item_parent:FindChild("Item")
    UIFuncs.GetIconGo(self, self.item_temp:FindChild("RoleIcon"), nil, UIConst.PrefabResPath.RoleIcon)
    self.item_temp:FindChild("Right/InviteBtn/Text"):GetComponent("Text").text = UIConst.Text.INVITE
    self.item_temp:FindChild("Right/AlreadyInvited/Text"):GetComponent("Text").text = UIConst.Text.ALREADY_INVITE
    self.item_temp:SetActive(false)
    self.invite_ally_panel = content:FindChild("InviteAllyPanel")
    self.invite_ally_panel_btn = self.main_panel:FindChild("SelectBtnList/InviteAllyBtn")
    self.invite_ally_panel_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.INVITE_ALLY
    self.invite_ally_panel_btn:FindChild("Selected/Text"):GetComponent("Text").text = UIConst.Text.INVITE_ALLY
    self.iap_item_parent = self.invite_ally_panel:FindChild("Viewport/ItemList")

    local param_tb = {
        tag_list = {self.invite_friend_panel_btn, self.invite_ally_panel_btn},
        panel_list = {self.invite_friend_panel, self.invite_ally_panel},
        select_cb = self.TabViewSelectCb,
        init_select = true,
        select_colors = UIConst.Color.SelectTextColorList
    }
    self.tag_expand_view = TabViewCmp.New()
    self.tag_expand_view:DoInit(self, param_tb)
end

function PartyInviteUI:InitUI()
    self.tag_expand_view:Select(1)
    self:RegisterEvent(self.dy_party_data, "UpdateInviteDict", function ()
        self:TabViewSelectCb(self.cur_select_index)
    end)
end

function PartyInviteUI:TabViewSelectCb(index)
    local func_name = kSelectFunc[index]
    self.cur_select_index = index
    self[func_name](self)
end

function PartyInviteUI:Hide()
    PartyInviteUI.super.Hide(self)
end

function PartyInviteUI:ClearGoDict(go_dict_name)
    for _, go in pairs(self[go_dict_name]) do
        self:DelUIObject(go)
    end
    self[go_dict_name] = {}
end

function PartyInviteUI:InitInviteItem(go, role_info, invite_target, invited_status)
    local role_info_go = go:FindChild("RoleInfo")
    role_info_go:FindChild("Name"):GetComponent("Text").text = role_info.name
    role_info_go:FindChild("Level"):GetComponent("Text").text = string.format(UIConst.Text.LEVEL_FORMAT_TEXT, role_info.level)
    role_info_go:FindChild("Score"):GetComponent("Text").text = string.format(UIConst.Text.PARTY_SCORE_FORMAT, role_info.score)
    UIFuncs.InitRoleIcon({go = go:FindChild("RoleIcon/Item"), role_id = role_info.role_id})
    local show_invite_btn = invited_status == nil or invited_status == CSConst.Party.InviteStatus.RefuseNoNotice or false
    self:SetRoleItemCanInvite(go, show_invite_btn)
    self:AddClick(go:FindChild("Right/InviteBtn"), function()
        self:InviteBtnOnClick(role_info)
    end)
end

function PartyInviteUI:SetRoleItemCanInvite(go, show_invite_btn)
    go:FindChild("Right/InviteBtn"):SetActive(show_invite_btn)
    go:FindChild("Right/AlreadyInvited"):SetActive(not show_invite_btn)
end

function PartyInviteUI:InitInvietFriendPanel()
    self:ClearGoDict("ifp_uuid_to_go")
    self.friend_info_list = ComMgrs.dy_data_mgr.friend_data:GetFriendInfoSortList()
    local uuid_to_invite_dict = self.dy_party_data:GetInviteDict()
    for i, role_info in ipairs(self.friend_info_list) do
        local go = self:GetUIObject(self.item_temp, self.ifp_item_parent)
        local uuid = role_info.uuid
        local invite_status = uuid_to_invite_dict[uuid]
        self.ifp_uuid_to_go[uuid] = go
        self:InitInviteItem(go, role_info, InviteTarget.Friend, invite_status)
    end
end

function PartyInviteUI:InitInvietAllyPanel()
    ComMgrs.dy_data_mgr.dynasty_data:UpdateDynastyMemberInfo(function (member_dict)
        self:GetAllyDictCb(member_dict)
    end)
end

function PartyInviteUI:GetAllyDictCb(member_dict)
    if not self.is_res_ok then return end
    self.ally_info_list = ComMgrs.dy_data_mgr.dynasty_data:GetMemberList(member_dict)
    self:ClearGoDict("iap_uuid_to_go")
    local uuid_to_invite_dict = self.dy_party_data:GetInviteDict()
    for i, role_info in ipairs(self.ally_info_list) do
        local go = self:GetUIObject(self.item_temp, self.iap_item_parent)
        local uuid = role_info.uuid
        local invite_status = uuid_to_invite_dict[uuid]
        self.iap_uuid_to_go[uuid] = go
        self:InitInviteItem(go, role_info, InviteTarget.Ally, invite_status)
    end
end

function PartyInviteUI:InviteBtnOnClick(role_info)
    if not self.dy_party_data:CheckFriendCanInvite(role_info, true) then
        return
    end
    local param_tb = {role_dict = {[role_info.uuid] = true}}
    SpecMgrs.msg_mgr:SendMsg("SendPartyInviteRole", param_tb)
end

function PartyInviteUI:OneKeyInviteBtnOnClick()
    local invite_data_list
    if self.cur_select_index == 1 then
        invite_data_list = self.friedn_info_list
    elseif self.cur_select_index == 2 then
        invite_data_list = self.ally_info_list
    end
    local role_dict = {}
    for i, role_info in  ipairs(invite_data_list) do
       if self.dy_party_data:CheckFriendCanInvite(role_info, true) then
           role_dict[role_info.uuid] = true
        end
    end
    SpecMgrs.msg_mgr:SendMsg("SendPartyInviteRole", role_dict)
end

return PartyInviteUI