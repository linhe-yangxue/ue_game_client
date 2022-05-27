local EventUtil = require("BaseUtilities.EventUtil")
local CSConst = require("CSCommon.CSConst")
local PartyData = class("DynamicData.PartyData")
local CSFunction = require("CSCommon.CSFunction")
local UIConst = require("UI.UIConst")

EventUtil.GeneratorEventFuncs(PartyData, "UpdatePartyInfo")
EventUtil.GeneratorEventFuncs(PartyData, "UpdatePartyRandom")
EventUtil.GeneratorEventFuncs(PartyData, "UpdateInviteDict")
EventUtil.GeneratorEventFuncs(PartyData, "UpdateReceiveInviteDict")


local kFreeGiftIsOkTS = 0 -- 时间戳为0 则表示免费礼物cd好了

function PartyData:DoInit()
    self.notify_party_end_ui = {
        "PartyUI",
        "PartyInfoUI",
        "SelectPartyGameUI",
        "ThrowDartUI",
        "DicingUI",
        "ShootMoneyUI",
    }
    self.on_party_end_hide_ui = {
        "SelectPartyGameUI",
        "ThrowDartUI",
        "DicingUI",
        "ShootMoneyUI",
    }
end

function PartyData:NotifyUpdatePartyInfo(msg)
    print("派对信息服务器主动推送=======",msg)
    if msg.party_info then -- 自己派对信息
        self.party_info = msg.party_info
        self:DispatchUpdatePartyInfo(self.party_info)
    end
    if msg.not_receive_invite then -- 不接受邀请
        self.not_receive_invite = self.not_receive_invite
    end
    if msg.join_party_info then -- 参加派对信息
        if self.join_party_info and not self.join_party_info.end_type and msg.join_party_info.end_type then
            self:ShowPartyEnd(msg.join_party_info)
        end
        self.join_party_info = msg.join_party_info
        self:UpdateMyGuestInfo()
        self:DispatchUpdatePartyInfo(self.join_party_info)
    end
    if msg.open_dict then -- {lover_id = bool}-- 当天开过派对的情人
        self.open_dict = msg.open_dict
    end
    if msg.join_dict then -- {lover_id = party_id}-- 当天参加派对的情人
        self.join_dict = msg.join_dict
    end
    if msg.record_list then -- 派对记录
        self.my_party_record_list = msg.record_list
    end
    if msg.enemy_list then -- 仇人列表
        self.enemy_list = msg.enemy_list
    end
    if msg.invite_dict then -- 我可以邀请的好友和盟友
        self.invite_dict = msg.invite_dict
        self:DispatchUpdateInviteDict(msg.invite_dict)
    end
    if msg.receive_invite_dict then -- 接受到的邀请请求
        self.receive_invite_dict = msg.receive_invite_dict
        self:DispatchUpdateReceiveInviteDict(msg.receive_invite_dict)
    end
    if msg.free_ts then
        self.free_ts = msg.free_ts
    end
end

function PartyData:GetInviteDict()
    return self.invite_dict or {}
end

function PartyData:GetReceiveInviteDict()
    return self.receive_invite_dict or {}
end

function PartyData:GetReceiveInviteList()
    print("9999--",self.join_party_info)
    --return table.values(self.receive_invite_dict)
    return table.values(self.join_party_info)
end

function PartyData:ShowPartyEnd(party_info)
    if not self:_CheckShowPartyEndUIShow() then return end
    local end_type_dict = CSConst.Party.EndType
    local end_type = party_info.end_type
    local str
    if end_type == end_type_dict.EnemyEnd then
        local enemy_name = party_info.enemy_info.role_info.name
        str = string.format(UIConst.Text.PARTY_ALREADY_END_BY_ENEMY, enemy_name)
    elseif end_type == end_type_dict.HostEnd then
        str = UIConst.Text.PARTY_ALREADY_END_BY_HOST
    else
        str = UIConst.Text.PARTY_ALREADY_END
    end

    SpecMgrs.ui_mgr:ShowMsgSelectBox({content = str, is_show_cancel_btn = false, confirm_cb = function ()
        self:HideAllPartyUI()
    end})
end

function PartyData:_CheckShowPartyEndUIShow()
    for i, ui_name in ipairs(self.notify_party_end_ui) do
        local ui = SpecMgrs.ui_mgr:GetUI(ui_name)
        if ui and ui.is_showing then
            return true
        end
    end
    return false
end

function PartyData:HideAllPartyUI()
    for i, ui_name in ipairs(self.on_party_end_hide_ui) do
        local ui = SpecMgrs.ui_mgr:GetUI(ui_name)
        if ui and ui.is_showing then
            SpecMgrs.ui_mgr:HideUI(ui)
        end
    end
end

function PartyData:CheckFriendCanInvite(role_info, is_show_tip)
    local is_can_invite = false
    local invite_status = self.invite_dict[role_info.uuid]
    local str
    local status_dict = CSConst.Party.InviteStatus
    if invite_status == nil then
        is_can_invite = true
    elseif invite_status == status_dict.RefuseNoNotice then
        str = string.format(UIConst.Text.PLAYER_REFUSE_YOUR_INVITE, role_info.name)
    end
    if str and is_show_tip then
        SpecMgrs.ui_mgr:ShowTipMsg(str)
    end
    return is_can_invite
end

function PartyData:CheckLoverCanHoldParty(lover_id, is_show_tip)
    if not self.open_dict[lover_id] then
        return true
    end
    if is_show_tip then
        local lover_data = SpecMgrs.data_mgr:GetLoverData(lover_id)
        local str = string.format(UIConst.Text.LOVER_IS_RESTING, lover_data.name, UIConst.Text.HOLD_PARTY)
        SpecMgrs.ui_mgr:ShowTipMsg(str)
    end
end

function PartyData:CheckLoverCanJoinParty(lover_id, is_show_tip)
    if not self.join_dict[lover_id] then
        return true
    end
    if is_show_tip then
        local lover_data = SpecMgrs.data_mgr:GetLoverData(lover_id)
        local str = string.format(UIConst.Text.LOVER_IS_RESTING, lover_data.name, UIConst.Text.JOIN_PARTY)
        SpecMgrs.ui_mgr:ShowTipMsg(str)
    end
end

function PartyData:GetMyPartyInfo()
    if self.party_info and next(self.party_info) then
        return self.party_info
    end
end

function PartyData:GetJoinPartyInfo()
    if self.join_party_info and next(self.join_party_info) then
        return self.join_party_info
    end
end

function PartyData:GetEnemyList()
    return self.enemy_list or {}
end

function PartyData:GetMyPartyInfoRecordList()
    return self.my_party_record_list
end

function PartyData:IsMyParty(party_info)
    local party_host_uuid = party_info.host_info.uuid
    local my_uuid = ComMgrs.dy_data_mgr:ExGetRoleUuid()
    return party_host_uuid == my_uuid
end

function PartyData:GetMyGuestIndex(party_info)
    local my_uuid = ComMgrs.dy_data_mgr:ExGetRoleUuid()
    for i, guest_info in ipairs(party_info.guests_list) do
        if guest_info.role_info.uuid == my_uuid then
            return i
        end
    end
end

function PartyData:GetMyGuestInfo()
    return self.my_guest_info
end

function PartyData:GetMyGuestInfoByPartyInfo(party_info)
    local index = self:GetMyGuestIndex(party_info)
    return party_info.guests_list[index]
end

function PartyData:UpdateMyGuestInfo()
    local party_info = self.join_party_info
    if party_info and next(party_info) then
        local index = self:GetMyGuestIndex(party_info)
        if index then
            self.my_guest_info = party_info.guests_list[index]
        else
            PrintError("My join_party_info must be wrong", party_info)
            self.my_guest_info = nil
        end
    else
        self.my_guest_info = nil
    end
end

function PartyData:IsPartyEnd(party_info)
    return party_info.end_type and true or false
end

function PartyData:GetReaminGameTime()
    local ret
    if self.join_party_info and not self.join_party_info.end_type then
        ret = self.my_guest_info and self.my_guest_info.games_num
    end
    return ret or 0
end

function PartyData:CanStartGame(is_show_tip)
    if self:GetReaminGameTime() > 0 then
        return true
    end
    if is_show_tip then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.PARTY_GMAE_NUM_NOT_ENOUGH)
    end
    return false
end

function PartyData:IsPartyFull(party_info)
    local party_type_data = SpecMgrs.data_mgr:GetPartyData(party_info.party_type_id)
    local cur_guest_num = party_type_data.guests_list and #party_type_data.guests_list or 0
    return party_type_data.guests_max_num <= cur_guest_num
end

function PartyData:CanJoinParty(party_info, is_show_fail_reason)
    local end_type = party_info.end_type
    local is_party_full = self:IsPartyFull(party_info)
    if not end_type or not is_party_full then return true end
    if not is_show_fail_reason then return end
    local tip_str
    local end_type_dict = CSConst.Party.EndType
    if end_type then
        if end_type == end_type_dict.EnemyEnd then
            local enemy_name = party_info.enemy_info.name
            tip_str = string.format(UIConst.Text.PARTY_ALREADY_END_BY_ENEMY, enemy_name)
        elseif end_type == end_type_dict.HostEnd then
            tip_str = UIConst.Text.PARTY_ALREADY_END_BY_HOST
        else
            tip_str = UIConst.Text.PARTY_ALREADY_END
        end
    else
        tip_str = UIConst.Text.PARTY_ALREADY_FULL
    end
    SpecMgrs.ui_mgr:ShowTipMsg(tip_str)
end

function PartyData:GetLoverPartyPointAddRatio(level)
    return CSFunction.get_add_ratio(level)
end

function PartyData:GetPartyPoint(party_info)
    local point_sum, base_point, add_point = CSFunction.get_party_point(party_info)
    if party_info.enemy_info then
        local reamin_point_ratio = 1 - SpecMgrs.data_mgr:GetParamData("party_buster_get_point_ratio").f_value
        point_sum = math.floor(point_sum * reamin_point_ratio)
        base_point = math.floor(base_point * reamin_point_ratio)
        add_point = math.floor(add_point * reamin_point_ratio)
    end
    return point_sum, base_point, add_point
end

function PartyData:IsPartyBorken(party_info)
    return party_info.enemy_info and next(party_info.enemy_info) and true or false
end

function PartyData:GetJoinPartyPoint(base_point, lover_level)
    local ratio = self:GetLoverPartyPointAddRatio(lover_level)
    return math.floor(base_point + base_point * ratio)
end

function PartyData:GetPartyLoverList(is_hold_party)
    local lover_data_list = ComMgrs.dy_data_mgr.lover_data:GetAllLoverDataList()
    local lover_dict = is_hold_party and self.open_dict or self.join_dict
    self:SortLoverList(lover_data_list, lover_dict)
    return lover_data_list
end

function PartyData:SortLoverList(lover_data_list, lover_dict)
    table.sort(lover_data_list, function (lover_data1, lover_data2)
        if lover_dict[lover_data1.lover_id] and not lover_dict[lover_data2.lover_id] then
            return false
        elseif not lover_dict[lover_data1.lover_id] and lover_dict[lover_data2.lover_id] then
            return true
        end
        if lover_data1.level ~= lover_data2.level then
            return lover_data1.level > lover_data2.level
        end
        return lover_data1.lover_id < lover_data2.lover_id
    end)
end

function PartyData:SendGetPartyRandom()
    SpecMgrs.msg_mgr:SendMsg("SendPartyRandom",{}, function (resp)
        self:DispatchUpdatePartyRandom(resp.party_list)
    end)
end

function PartyData:SendGetPartyInfo(party_id)
    SpecMgrs.msg_mgr:SendMsg("SendGetPartyInfo", {party_id = party_id}, function (resp)
        self:DispatchUpdatePartyInfo(resp.party_info)
    end)
end

function PartyData:SendGetJoinPartyInfo()
    local party_id = self.join_party_info.party_id or self.old_join_party_info.party_id
    if not party_id then return end
    SpecMgrs.msg_mgr:SendMsg("SendGetPartyInfo",{party_id = party_id}, function (resp)
        self:DispatchUpdatePartyInfo(resp.party_info)
    end)
end

function PartyData:IsFreeGiftOk()
    return self.free_ts and self.free_ts == kFreeGiftIsOkTS
end

function PartyData:GetNextFreeGiftRemainTime()
    if self.free_ts ~= kFreeGiftIsOkTS then return self.free_ts end
end

function PartyData:GetNextFreeGiftCoolTime()
    return self.free_ts
end

function PartyData:GetNotReceiveInvite()
    return self.not_receive_invite or false
end

return PartyData