local EventUtil = require("BaseUtilities.EventUtil")
local UIConst = require("UI.UIConst")

local FriendData = class("DynamicData.FriendData")
EventUtil.GeneratorEventFuncs(FriendData, "UpdateReciveCountEvent")

-- 好友
function FriendData:DoInit()
    self.receive_gift_count = 0
    self.friend_info_dict = {}
    self.have_apply_friend = false
    self.have_send_gift = false
    self.next_refresh_time = nil
    self.recommend_friend_list = nil
end

function FriendData:NotifyUpdateReciveGiftCount(msg)
    self.receive_gift_count = msg.receive_gift_count
    if msg.this_time_receive then
        self:DispatchUpdateReciveCountEvent(msg.this_time_receive)
    end
end

--  上线更新
function FriendData:NotifyUpdateFriendDict(msg)
    self.friend_info_dict = msg.friend_info_dict
end

function FriendData:SetFriendDict(friend_dict)
    self.friend_info_dict = friend_dict
end

function FriendData:SetFriendSendGift(is_have_send_gift)
    self.have_send_gift = is_have_send_gift
    self:_UpdatePresentRedPoint()
end

function FriendData:IsHaveSendGift()
    return self.have_send_gift
end

function FriendData:SetHaveAddFriendApply(is_have_apply_friend)
    self.have_apply_friend = is_have_apply_friend
    self:_UpdateApplyRedPoint()
end

function FriendData:IsHaveAddFriendApply()
    return self.have_apply_friend
end

function FriendData:GetFriendInfoByUuid(uuid)
    return self.friend_info_dict[uuid]
end

function FriendData:GetFriendInfoDict()
    return self.friend_info_dict
end

function FriendData:GetFriendInfoSortList()
    return self:SortFriendDict(self.friend_info_dict)
end

function FriendData:SortFriendDict(friend_dict)
    local ret = {}
    for uuid, info in pairs(friend_dict) do
        table.insert(ret, info)
    end
    table.sort(ret, function(a, b)
        if a.send_gift ~= b.send_gift then
            return a.send_gift == false and true or false
        end
        if a.offline_time ~= b.offline_time then
            if a.offline_time == 0 then return true end
            if b.offline_time == 0 then return false end
            return a.offline_time > b.offline_time
        end
        if a.level ~= b.level then
            return a.level > b.level
        end
        if a.fight_score ~= b.fight_score then
            return a.fight_score > b.fight_score
        end
        return false
    end)
    return ret
end

function FriendData:SetNextRefreshTime(next_time)
    self.next_refresh_time = next_time
end

function FriendData:SetRecommenFriendList(player_list)
    self.recommend_friend_list = player_list
end

function FriendData:ShowPlayerInfo(player_uuid, cb_dict)
    if player_uuid == ComMgrs.dy_data_mgr:ExGetRoleUuid() then return end
    local option_list = self.friend_info_dict[player_uuid] and UIConst.FriendInfoOptionList or UIConst.StrangerInfoOptionList
    SpecMgrs.msg_mgr:SendGetPlayerInfo({uuid = player_uuid}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_PLAYER_INFO_FAILED)
        else
            resp.uuid = player_uuid
            SpecMgrs.ui_mgr:ShowUI("OtherPlayerMsgUI", resp, option_list, cb_dict or {})
        end
    end)
end

--更新好友申请红点
function FriendData:_UpdateApplyRedPoint()
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Friend.Apply, {self.have_apply_friend and 1 or 0})
end

--更新好友礼物红点
function FriendData:_UpdatePresentRedPoint()
    SpecMgrs.redpoint_mgr:SetControlIdActive(CSConst.RedPointControlIdDict.Friend.Present, {self.have_send_gift and 1 or 0})
end

return FriendData