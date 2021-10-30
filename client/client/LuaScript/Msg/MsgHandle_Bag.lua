local MsgConst = require("Msg.MsgConst")
local mh_bag = DECLARE_MODULE("Msg.MsgHandle_Bag")

function mh_bag.s_online_bag_item(msg)
    ComMgrs.dy_data_mgr.bag_data:NotifyAllBagItem(msg)
end

function mh_bag.s_bag_item_add(msg)
    ComMgrs.dy_data_mgr.bag_data:NotifyAddBagItem(msg)
end

function mh_bag.s_bag_item_remove(msg)
    ComMgrs.dy_data_mgr.bag_data:NotifyRemoveBagItem(msg)
end

function mh_bag.s_bag_item_update(msg)
    ComMgrs.dy_data_mgr.bag_data:NotifyUpdateBagItem(msg)
end

function mh_bag.s_notify_add_item(msg)
    ComMgrs.dy_data_mgr.bag_data:NotifyGetItem(msg)
end

function mh_bag.s_notify_add_item_congrats(msg)
    ComMgrs.dy_data_mgr.bag_data:NotifyShowGetItemUI(msg)
end

return mh_bag