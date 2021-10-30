local MsgConst = require("Msg.MsgConst")
local mh_friend = DECLARE_MODULE("Msg.MsgHandle_Friend")

function mh_friend.s_update_receive_gift_count(msg)
    ComMgrs.dy_data_mgr.friend_data:NotifyUpdateReciveGiftCount(msg)
end

function mh_friend.s_update_friend_info(msg)
    ComMgrs.dy_data_mgr.friend_data:NotifyUpdateFriendDict(msg)
end

function mh_friend.s_update_operation_info(msg)
    ComMgrs.dy_data_mgr.friend_data:SetFriendSendGift(msg.apply_bool)
    ComMgrs.dy_data_mgr.friend_data:SetHaveAddFriendApply(msg.gift_bool)
end

function mh_friend.s_friend_send_gift(msg)
    ComMgrs.dy_data_mgr.friend_data:SetFriendSendGift(true)
end

function mh_friend.s_user_add_friend_apply(msg)
    ComMgrs.dy_data_mgr.friend_data:SetHaveAddFriendApply(true)
end

return mh_friend