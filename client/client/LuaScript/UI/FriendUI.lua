local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local FriendUI = class("UI.FriendUI",UIBase)

local anchor_v2 = Vector2.New(1, 1)
local apply_redpoint_control_id = {CSConst.RedPointControlIdDict.Friend.Apply}
local present_redpoint_control_id = {CSConst.RedPointControlIdDict.Friend.Present}

--  好友界面
function FriendUI:DoInit()
    FriendUI.super.DoInit(self)
    self.prefab_path = "UI/Common/FriendUI"
end

function FriendUI:OnGoLoadedOk(res_go)
    FriendUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function FriendUI:Show(default_panel)
    self.default_panel = default_panel
    if self.is_res_ok then
        self:InitUI()
    end
    FriendUI.super.Show(self)
end

function FriendUI:InitRes()
    self:InitTopBar()
    self.option_list = self.main_panel:FindChild("OptionList/OptionList")
    self.option = self.main_panel:FindChild("OptionList/OptionList/Option")

    --  好友列表
    self.friend_list_frame = self.main_panel:FindChild("FriendListFrame")
    self.friend_count_text = self.main_panel:FindChild("FriendListFrame/FriendCountText"):GetComponent("Text")
    self.friend_list = self.main_panel:FindChild("FriendListFrame/FriendListScrollRect/ViewPort/FriendList")
    self.friend_list_friend_item = self.main_panel:FindChild("FriendListFrame/FriendListScrollRect/ViewPort/FriendList/FriendItem")
    self.friend_list_down_frame = self.main_panel:FindChild("FriendListFrame/FriendListDownFrame")
    self.apply_list_btn = self.main_panel:FindChild("FriendListFrame/FriendListDownFrame/ApplyListBtn")
    self:AddClick(self.apply_list_btn, function()
        self:ShowFriendAppliyListFrame()
    end)

    self.one_key_give_btn = self.main_panel:FindChild("FriendListFrame/FriendListDownFrame/OneKeyGiveBtn")
    self:AddClick(self.one_key_give_btn, function()
        self:SendOnekeyGive()
    end)

    --  好友礼物
    self.friend_gift_list_frame = self.main_panel:FindChild("FriendGiftListFrame")
    self.friend_gift_list = self.main_panel:FindChild("FriendGiftListFrame/FriendGiftListScrollRect/ViewPort/FriendList")
    self.friend_gift_list_friend_item = self.main_panel:FindChild("FriendGiftListFrame/FriendGiftListScrollRect/ViewPort/FriendList/FriendItem")
    self.receive_down_frame = self.main_panel:FindChild("FriendGiftListFrame/ReceiveDownFrame")
    self.one_receive_btn = self.main_panel:FindChild("FriendGiftListFrame/ReceiveDownFrame/OneReceiveBtn")
    self:AddClick(self.one_receive_btn, function()
        self:SendOnekeyRecive()
    end)
    self.receive_time_text = self.main_panel:FindChild("FriendGiftListFrame/ReceiveDownFrame/ReceiveTimeText"):GetComponent("Text")
    self.friend_list_frame_mask = self.main_panel:FindChild("FriendListFrameMask")

    --  好友申请
    self.apply_list_frame = self.main_panel:FindChild("ApplyListFrame")
    self.close_btn = self.main_panel:FindChild("ApplyListFrame/CloseBtn")
    self:AddClick(self.close_btn, function()
        self:CloseFriendAppliyListFrame()
    end)
    self.apply_list_frame_title = self.main_panel:FindChild("ApplyListFrame/ApplyListFrameTitle"):GetComponent("Text")
    self.apply_list_friend_list = self.main_panel:FindChild("ApplyListFrame/FriendListScrollRect/ViewPort/FriendList")
    self.apply_list_friend_item = self.main_panel:FindChild("ApplyListFrame/FriendListScrollRect/ViewPort/FriendList/FriendItem")
    self.down_frame = self.main_panel:FindChild("ApplyListFrame/DownFrame")
    self.one_key_apply_list_btn = self.main_panel:FindChild("ApplyListFrame/DownFrame/OneKeyApplyListBtn")
    self:AddClick(self.one_key_apply_list_btn, function()
        self:SendOnekeyApply()
    end)

    self.one_key_refuse_btn = self.main_panel:FindChild("ApplyListFrame/DownFrame/OneKeyRefuseBtn")
    self:AddClick(self.one_key_refuse_btn, function()
        self:SendOnekeyRefuse()
    end)

    --  好友推荐
    self.add_friend_frame = self.main_panel:FindChild("AddFriendFrame")
    self.add_friend_frame_tip_text = self.main_panel:FindChild("AddFriendFrame/AddFriendFrameTipText"):GetComponent("Text")
    self.add_friend_frame_scroll_rect = self.main_panel:FindChild("AddFriendFrame/FriendListScrollRect/ViewPort/FriendList"):GetComponent("RectTransform")
    self.add_friend_friend_list = self.main_panel:FindChild("AddFriendFrame/FriendListScrollRect/ViewPort/FriendList")
    self.add_friend_friend_item = self.main_panel:FindChild("AddFriendFrame/FriendListScrollRect/ViewPort/FriendList/FriendItem")
    self.refresh_btn = self.main_panel:FindChild("AddFriendFrame/RefleshBtn")
    self:AddClick(self.refresh_btn, function()
        self:ClickRefleshBtn()
    end)
    self.refresh_btn_text = self.main_panel:FindChild("AddFriendFrame/RefleshBtn/Text"):GetComponent("Text")

    self.search_input_field = self.main_panel:FindChild("AddFriendFrame/SearchInputField"):GetComponent("InputField")
    self.placeholder = self.main_panel:FindChild("AddFriendFrame/SearchInputField/Placeholder"):GetComponent("Text")
    self.search_input_field_text = self.main_panel:FindChild("AddFriendFrame/SearchInputField/SearchInputFieldText"):GetComponent("Text")
    self.search_btn = self.main_panel:FindChild("AddFriendFrame/SearchBtn")
    self:AddClick(self.search_btn, function()
        self:SearchResult()
    end)
    self.add_friend_frame_mask = self.main_panel:FindChild("AddFriendFrameMask")

    --  搜索指定名字
    self.search_result_frame = self.main_panel:FindChild("SearchResultFrame")
    self.search_result_frame_close_btn = self.main_panel:FindChild("SearchResultFrame/CloseBtn")
    self:AddClick(self.search_result_frame_close_btn, function()
        self:HideSearchResultFrame()
    end)
    self.search_result_frame_title = self.main_panel:FindChild("SearchResultFrame/Title"):GetComponent("Text")
    self.add_friend_btn = self.main_panel:FindChild("SearchResultFrame/AddFriendBtn")
    self:AddClick(self.add_friend_btn, function()
        self:SearchResultAddFriend()
    end)

    --  黑名单
    self.black_list_frame = self.main_panel:FindChild("BlackListFrame")
    self.black_list = self.main_panel:FindChild("BlackListFrame/FriendListScrollRect/ViewPort/FriendList")
    self.black_list_friend_item = self.main_panel:FindChild("BlackListFrame/FriendListScrollRect/ViewPort/FriendList/FriendItem")

    self.one_key_del_btn = self.main_panel:FindChild("BlackListFrame/BlackListDownFrame/OneKeyDelBtn")
    self:AddClick(self.one_key_del_btn, function()
        self:OneKeyDeleteBlackList()
    end)

    self.one_key_relieve_btn = self.main_panel:FindChild("BlackListFrame/BlackListDownFrame/OneKeyRelieveBtn")
    self:AddClick(self.one_key_relieve_btn, function()
        self:OneKeyRemoveBlackList()
    end)
    self.black_list_friend_item:SetActive(false)
    self.friend_list_friend_item:SetActive(false)
    self.apply_list_friend_item:SetActive(false)
    self.add_friend_friend_item:SetActive(false)
    self.friend_gift_list_friend_item:SetActive(false)
    self:SetTextVal()
end

function FriendUI:InitUI()
    self:UpdateData()
    self:UpdateUIInfo()
end

function FriendUI:SetTextVal()
    self.add_friend_frame_tip_text.text = UIConst.Text.RECOMMEND_TIP_TEXT
    self.search_result_frame_title.text = UIConst.Text.SEARCH_RESULT_TEXT
    self.apply_list_frame_title.text = UIConst.Text.APPLY_LIST_TEXT

    self.friend_list_friend_item:FindChild("GiveButton/GiveButtonText"):GetComponent("Text").text = UIConst.Text.GIVE_GIFT_TEXT
    self.friend_list_friend_item:FindChild("AlreadyGiveButton/AlreadyGiveButtonText"):GetComponent("Text").text = UIConst.Text.ALREADY_GIVE_TEXT

    self.black_list_friend_item:FindChild("ReliveBtn/Text"):GetComponent("Text").text = UIConst.Text.RELIVE_TEXT
    self.black_list_friend_item:FindChild("DelBtn/Text"):GetComponent("Text").text = UIConst.Text.DELETE_TEXT
    self.apply_list_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.APPLY_LIST_TEXT
    self.one_key_give_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ONEKEY_GIVE_TEXT

    self.friend_gift_list_friend_item:FindChild("GiveButton/GiveButtonText"):GetComponent("Text").text = UIConst.Text.RECIVE_GIFT_TEXT

    self.one_key_del_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ONEKEY_DEL_TEXT
    self.one_key_relieve_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ONEKEY_RELIEVE_TEXT
    self.refresh_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.REFLESH_TEXT

    self.one_key_apply_list_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ONEKEY_AGREE_TEXT
    self.one_key_refuse_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ONEKEY_REFUSE_TEXT

    self.apply_list_friend_item:FindChild("ApplyBtn/Text"):GetComponent("Text").text = UIConst.Text.AGREE_TEXT
    self.apply_list_friend_item:FindChild("RefuseBtn/Text"):GetComponent("Text").text = UIConst.Text.REFUSE_TEXT

    self.add_friend_friend_item:FindChild("AddFriendBtn/Text"):GetComponent("Text").text = UIConst.Text.ADD_FRIEND_TEXT
    self.search_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SEARCH_TEXT
    self.add_friend_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ADD_FRIEND_TEXT
    self.one_receive_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ONEKEY_RECEIVE_TEXT
end

function FriendUI:Update()
    if not self.is_res_ok then return end
    self:UpdateRefleshCD()
end

function FriendUI:UpdateData()
    self.friend_refresh_time_cd = SpecMgrs.data_mgr:GetParamData("friend_refresh_time_cd").f_value
    self.max_friend_count = SpecMgrs.data_mgr:GetParamData("max_friend_count").f_value
    self.dy_friend_data = ComMgrs.dy_data_mgr.friend_data
end

function FriendUI:UpdateUIInfo()
    self.cur_frame_obj_list = {}
    self.cur_frame = nil
    self.option:SetActive(false)
    --self.send_mail_frame:SetActive(false)
    self.friend_list_frame:SetActive(false)
    self.friend_list_frame_mask:SetActive(false)
    self.friend_gift_list_frame:SetActive(false)
    self.apply_list_frame:SetActive(false)
    --self.player_mes_frame:SetActive(false)
    self.add_friend_frame:SetActive(false)
    self.add_friend_frame_mask:SetActive(false)
    self.search_result_frame:SetActive(false)
    self.black_list_frame:SetActive(false)
    self:InitOptionList()

    self:UpdateReciveCount()
    self.dy_friend_data:RegisterUpdateReciveCountEvent("FriendUI", function(_, this_time_receive)
        local val = this_time_receive * SpecMgrs.data_mgr:GetParamData("gift_value").f_value
        SpecMgrs.ui_mgr:ShowTipMsg(string.format(UIConst.Text.RECIVE_VITALITY_TIP_FORMAT, val))
        self:UpdateReciveCount()
    end)

    self.option_selector = UIFuncs.CreateSelector(self, self.option_obj_list, function(i)
        if i == 1 then
            self:SelectShowFriendListFrame()
        elseif i == 2 then
            self:SelectShowFriendReciveFrame()
        elseif i == 3 then
            if self.dy_friend_data.next_refresh_time == nil then
                self:ClickRefleshBtn()
            else
                self:SelectShowRecommenFriendFrame()
            end
        elseif i == 4 then
            self:SelectShowBlackListFrame()
        end
    end)
    self.option_selector:SelectObj(self.default_panel or 1)
end

function FriendUI:SelectShowFriendListFrame()
    local cb = function(resp)
        if resp.errcode == 1 then
            return
        end
        if not self.is_res_ok then return end
        self:CloseCurFrame()
        self.dy_friend_data:SetFriendDict(resp.friend_info_dict)
        local friend_list = self.dy_friend_data:GetFriendInfoSortList()
        self:ShowFriendListFrame(friend_list)
    end
    SpecMgrs.msg_mgr:SendGetAllFriendInfo(nil, cb)
end

function FriendUI:SelectShowFriendReciveFrame()
    local cb = function(resp)
        if resp.errcode == 1 then
            return
        end
        if not self.is_res_ok then return end
        self:CloseCurFrame()
        local friend_list = self.dy_friend_data:SortFriendDict(resp.receive_gift_dict)
        self:ShowFriendReciveFrame(friend_list)
    end
    SpecMgrs.msg_mgr:SendGetReciveGiftInfo(nil, cb)
end

function FriendUI:SelectShowRecommenFriendFrame(is_refresh)
    local recommend_friend_list = self.dy_friend_data.recommend_friend_list
    if not is_refresh and recommend_friend_list then
        self:CloseCurFrame()
        self:ShowRecommenFriendFrame(recommend_friend_list)
    else
        local cb = function(resp)
            if resp.errcode == 1 then
                return
            end
            if not self.is_res_ok then return end
            self:CloseCurFrame()
            local player_list = self.dy_friend_data:SortFriendDict(resp.friend_info_dict)
            self.dy_friend_data:SetRecommenFriendList(player_list)
            self:ShowRecommenFriendFrame(player_list)
        end
        SpecMgrs.msg_mgr:SendGetRecommendFriend(nil, cb)
    end
end

function FriendUI:SelectShowBlackListFrame()
    local cb = function(resp)
        if resp.errcode == 1 then
            return
        end
        if not self.is_res_ok then return end
        self:CloseCurFrame()
        local black_list = self.dy_friend_data:SortFriendDict(resp.blacklist_friend_dict)
        self:ShowBlackListFrame(black_list)
    end
    SpecMgrs.msg_mgr:SendGetAllBlackListFriend(nil, cb)
end

function FriendUI:CloseCurFrame()
    if self.cur_frame then
        self.cur_frame:SetActive(false)
    end
    self:DelObjDict(self.cur_frame_obj_list)
    self.cur_frame_obj_list = {}
end

function FriendUI:UpdateReciveCount()
    local count = SpecMgrs.data_mgr:GetParamData("max_gift_count").f_value - self.dy_friend_data.receive_gift_count
    self.receive_time_text.text = string.format(UIConst.Text.TODAY_CAN_GET_ENERGY_FORMAT, count)
end

function FriendUI:InitOptionList()
    self.option_text_list = {
        UIConst.Text.FRIEND_LIST_TEXT,
        UIConst.Text.FRIEND_RECIVE_TEXT,
        UIConst.Text.FRIEND_RECOMMEND_TEXT,
        UIConst.Text.BLACK_LIST,
    }
    self.option_obj_list = {}
    self.redpoint_list = {}
    for i, text in ipairs(self.option_text_list) do
        local option = self:GetUIObject(self.option, self.option_list)
        option:FindChild("Text"):GetComponent("Text").text = text
        table.insert(self.option_obj_list, option)
        if i == 1 then
            local redpoint = SpecMgrs.redpoint_mgr:AddRedPoint(self, option, CSConst.RedPointType.Normal, apply_redpoint_control_id, nil, anchor_v2, anchor_v2)
            table.insert(self.redpoint_list, redpoint)
        elseif i == 2 then
            self.send_gift_option = option
            local redpoint = SpecMgrs.redpoint_mgr:AddRedPoint(self, option, CSConst.RedPointType.Normal, present_redpoint_control_id, nil, anchor_v2, anchor_v2)
            table.insert(self.redpoint_list, redpoint)
        end
    end
end

--  好友列表
function FriendUI:ShowFriendListFrame(player_list)
    self.friend_info_obj_dict = {}
    self.cur_frame = self.friend_list_frame
    self.cur_frame:SetActive(true)
    self.add_friend_frame_scroll_rect.anchoredPosition = Vector3.zero
    self.friend_count = #player_list
    self.can_give_count = 0
    self.friend_count_text.text = string.format(UIConst.Text.FRIEND_NUM_FORMAT, self.friend_count, self.max_friend_count)
    for i, player_info in ipairs(player_list) do
        local item = self:GetUIObject(self.friend_list_friend_item, self.friend_list)
        table.insert(self.cur_frame_obj_list, item)
        self.friend_info_obj_dict[player_info] = item
        FriendUI.SetPlayerItemMes(item, player_info)

        local give_btn = item:FindChild("GiveButton")
        local already_give_btn = item:FindChild("AlreadyGiveButton")
        if not player_info.send_gift then
            self.can_give_count = self.can_give_count + 1
            give_btn:SetActive(true)
            already_give_btn:SetActive(false)
            self:AddClick(give_btn, function()
                local cb = function()
                    give_btn:SetActive(false)
                    already_give_btn:SetActive(true)
                    self.can_give_count = self.can_give_count - 1
                    SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.GIVE_SUCCESS_TIP)
                end
                SpecMgrs.msg_mgr:SendFriendGift({uuid = player_info.uuid}, cb)
            end)
        else
            give_btn:SetActive(false)
            already_give_btn:SetActive(true)
        end

        self:AddClick(item:FindChild("HeroIcon"), function()
            self:ShowPlayerMes(player_info)
        end)
    end
end

function FriendUI:SendOnekeyGive()
    if self.can_give_count <= 0 then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.CANNOT_GIVE_TIP)
        return
    end
    local cb = function(resp)
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.GIVE_SUCCESS_TIP)
        self:SelectShowFriendListFrame()
    end
    SpecMgrs.msg_mgr:SendAllFriendGift(nil, cb)
end

--  好友领取礼物
function FriendUI:ShowFriendReciveFrame(player_list)
    self.friend_info_obj_dict = {}
    self.cur_frame = self.friend_gift_list_frame
    self.cur_frame:SetActive(true)
    self.cur_can_recive_count = #player_list
    for i, player_info in ipairs(player_list) do
        local item = self:GetUIObject(self.friend_gift_list_friend_item, self.friend_gift_list)
        table.insert(self.cur_frame_obj_list, item)
        self.friend_info_obj_dict[player_info] = item
        FriendUI.SetPlayerItemMes(item, player_info)

        self:AddClick(item:FindChild("HeroIcon"), function()
            self:ShowPlayerMes(player_info)
        end)
        self:AddClick(item:FindChild("GiveButton"), function()
            local count = SpecMgrs.data_mgr:GetParamData("max_gift_count").f_value - self.dy_friend_data.receive_gift_count
            if count == 0 then
                SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.RECIVE_TIME_IS_MAX_TIP)
                return
            end
            local max_num = SpecMgrs.data_mgr:GetParamData("vitality_limit").f_value
            local add_val = SpecMgrs.data_mgr:GetParamData("gift_value").f_value
            if ComMgrs.dy_data_mgr:ExGetVitality() + add_val > max_num then
                SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.VITALITY_IS_MAX_TIP)
                return
            end
            local cb = function()
                self.cur_can_recive_count = self.cur_can_recive_count - 1
                self.dy_friend_data:SetFriendSendGift(self.cur_can_recive_count > 0)
                if not self.is_res_ok then return end
                self:DelUIObject(item)
            end
            SpecMgrs.msg_mgr:SendReciveFriendGift({uuid = player_info.uuid}, cb)
        end)
    end
end

function FriendUI:SendOnekeyRecive()
    local count = SpecMgrs.data_mgr:GetParamData("max_gift_count").f_value - self.dy_friend_data.receive_gift_count
    if count == 0 then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.RECIVE_TIME_IS_MAX_TIP)
        return
    end
    if self.cur_can_recive_count == 0 then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.CANNOT_RECIVE_TIP)
        return
    end
    local cb = function()
        self:SelectShowFriendReciveFrame()
        if self.cur_can_recive_count > 0 then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.CANNOT_RECIVE_TIP)
        end
        self.dy_friend_data:SetFriendSendGift(self.cur_can_recive_count > 0)
    end
    SpecMgrs.msg_mgr:SendReciveAllFriendGift(nil, cb)
end

--  玩家信息
function FriendUI:ShowPlayerMes(player_info)
    local option_list = {
        UIConst.OtherPlayerMsgOption.PullBlackFriend,
        UIConst.OtherPlayerMsgOption.DelFriend,
        UIConst.OtherPlayerMsgOption.PrivateChat,
        UIConst.OtherPlayerMsgOption.SendMail,
        UIConst.OtherPlayerMsgOption.CheckLineUp,
        UIConst.OtherPlayerMsgOption.BattleWithFriend,
    }
    local cb_dict = {
        [UIConst.OtherPlayerMsgOption.PullBlackFriend] = function(friend_info)
            if not self.is_res_ok then return end
            self:DelUIObject(self.friend_info_obj_dict[friend_info])
            self.friend_count = self.friend_count - 1
            self.friend_count_text.text = string.format(UIConst.Text.FRIEND_NUM_FORMAT, self.friend_count, self.max_friend_count)
        end,
        [UIConst.OtherPlayerMsgOption.DelFriend] = function(friend_info)
            if not self.is_res_ok then return end
            self.friend_count = self.friend_count - 1
            self.friend_count_text.text = string.format(UIConst.Text.FRIEND_NUM_FORMAT, self.friend_count, self.max_friend_count)
            self:DelUIObject(self.friend_info_obj_dict[friend_info])
        end,
    }
    SpecMgrs.ui_mgr:ShowUI("OtherPlayerMsgUI", player_info, option_list, cb_dict)
end

--  好友申请列表
function FriendUI:ShowFriendAppliyListFrame(is_ignore)
    local cb = function(resp)
        if resp.errcode == 1 then
            return
        end
        local list = self.dy_friend_data:SortFriendDict(resp.friend_apply_dict)
        self.apply_friend_count = #list
        if not is_ignore and #list <= 0 then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.NOT_APPLY_FRIEND_TIP)
            return
        end
        self:DelObjDict(self.friend_apply_item_list)
        self.friend_apply_item_list = {}
        self.friend_list_frame_mask:SetActive(true)
        self.apply_list_frame:SetActive(true)
        for i, friend_info in ipairs(list) do
            local item = self:GetUIObject(self.apply_list_friend_item, self.apply_list_friend_list)
            FriendUI.SetPlayerItemMes(item, friend_info)
            table.insert(self.friend_apply_item_list, item)
            self:AddClick(item:FindChild("ApplyBtn"), function()
                self:ApplyFriend(friend_info, item)
                self:SelectShowFriendListFrame()
            end)

            self:AddClick(item:FindChild("RefuseBtn"), function()
                self:RefuseFriend(friend_info)
                self:DelUIObject(item)
                self.apply_friend_count = self.apply_friend_count - 1
                self.dy_friend_data:SetHaveAddFriendApply(self.apply_friend_count > 0)
            end)
        end
    end
    SpecMgrs.msg_mgr:SendGetFriendApplyList(nil, cb)
end

function FriendUI:ApplyFriend(friend_info, item)
    local cb = function(resp)
        if not self:CheckTip(resp.tips) then
            self.apply_friend_count = self.apply_friend_count - 1
            self.dy_friend_data:SetHaveAddFriendApply(self.apply_friend_count > 0)
            if not self.is_res_ok then return end
            self:DelUIObject(item)
        end
    end
    SpecMgrs.msg_mgr:SendConfirmFriendApply({uuid = friend_info.uuid}, cb)
end

function FriendUI:RefuseFriend(friend_info)
    local cb = function(resp)

    end
    SpecMgrs.msg_mgr:SendRefuseFriendApply({uuid = friend_info.uuid}, cb)
end

function FriendUI:SendOnekeyApply()
    local cb = function(resp)
        self:CheckTip(resp.tips)
        self:ShowFriendAppliyListFrame(true)
        self:SelectShowFriendListFrame()
    end
    SpecMgrs.msg_mgr:SendConfirmAllFriendApply(nil, cb)
end

function FriendUI:SendOnekeyRefuse()
    local cb = function(resp)
        if not self.is_res_ok then return end
        self:DelObjDict(self.friend_apply_item_list)
    end
    SpecMgrs.msg_mgr:SendRefuseAllFriendApply(nil, cb)
end

function FriendUI:CloseFriendAppliyListFrame()
    self.friend_list_frame_mask:SetActive(false)
    self.apply_list_frame:SetActive(false)
    if self.apply_friend_count then
        self.dy_friend_data:SetHaveAddFriendApply(self.apply_friend_count > 0)
    end
end

--  好友推荐
function FriendUI:ShowRecommenFriendFrame(player_list)
    self.search_input_field.text = ""
    self.placeholder.text = UIConst.Text.SEARCH_FRIEND_TIP_TEXT
    self.cur_frame = self.add_friend_frame
    self.cur_frame:SetActive(true)
    for i, info in ipairs(player_list) do
        local item = self:GetUIObject(self.add_friend_friend_item, self.add_friend_friend_list)
        table.insert(self.cur_frame_obj_list, item)
        FriendUI.SetPlayerItemMes(item, info)
        self:AddClick(item:FindChild("AddFriendBtn"), function()
            local cb = function(resp)
                self:CheckTip(resp.tips)
                if not self.is_res_ok then return end
                self:DelUIObject(item)
            end
            SpecMgrs.msg_mgr:SendApplyFriend({uuid = info.uuid}, cb)
        end)
    end
end

function FriendUI:UpdateRefleshCD()
    if not self.dy_friend_data.next_refresh_time then return end
    local next_refresh_time = self.dy_friend_data.next_refresh_time
    local remain_time = next_refresh_time - Time:GetServerTime()
    if remain_time <= 0 then
        self.refresh_btn_text.text = UIConst.Text.REFLESH_TEXT
        self.dy_friend_data:SetNextRefreshTime(nil)
        self.refresh_btn:GetComponent("Button").interactable = true
    else
        self.refresh_btn_text.text = UIFuncs.TimeDelta2Str(remain_time, 3)
    end
end

function FriendUI:ClickRefleshBtn()
    self:SelectShowRecommenFriendFrame(true)
    self.dy_friend_data:SetNextRefreshTime(Time:GetServerTime() + self.friend_refresh_time_cd)
    self.refresh_btn:GetComponent("Button").interactable = false
end

function FriendUI:SearchResult()
    local search_uuid = self.search_input_field.text
    local cb = function(resp)
        if resp.errcode == 1 then
            return
        end
        if resp.friend_info then
             if not self.is_res_ok then return end
            self:ShowSearchResultFrame(resp.friend_info)
        else
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.NOT_SEARCH_FRIEND_RESULT)
        end
    end
    SpecMgrs.msg_mgr:SendSearchFriend({uuid = search_uuid}, cb)
end

function FriendUI:ShowSearchResultFrame(friend_info)
    self.search_friend_info = friend_info
    self.add_friend_frame_mask:SetActive(true)
    self.search_result_frame:SetActive(true)
    FriendUI.SetPlayerItemMes(self.search_result_frame, friend_info)
end

function FriendUI:HideSearchResultFrame()
    self.add_friend_frame_mask:SetActive(false)
    self.search_result_frame:SetActive(false)
end

function FriendUI:SearchResultAddFriend()
    if not self.search_friend_info then return end
    local cb = function(resp)
        if resp.tips then
            self:CheckTip(resp.tips)
        else
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.APPLY_FRIEND_SUCCESS_TIP)
        end
        if not self.is_res_ok then return end
        self:HideSearchResultFrame()
    end
    SpecMgrs.msg_mgr:SendApplyFriend({uuid = self.search_friend_info.uuid}, cb)
end

--  黑名单
function FriendUI:ShowBlackListFrame(player_list)
    self.cur_frame = self.black_list_frame
    self.cur_frame:SetActive(true)
    self.black_list_count = #player_list
    for i, player_info in ipairs(player_list) do
        local item = self:GetUIObject(self.black_list_friend_item, self.black_list)
        FriendUI.SetPlayerItemMes(item, player_info)
        table.insert(self.cur_frame_obj_list, item)
        self:AddClick(item:FindChild("ReliveBtn"), function()
            local cb = function(resp)
                if self:CheckTip(resp.tips) then
                    return
                end
                self.black_list_count = self.black_list_count - 1
                if not self.is_res_ok then return end
                self:DelUIObject(item)
            end
            SpecMgrs.msg_mgr:SendRemoveFriendInBlackList({uuid = player_info.uuid}, cb)
        end)
        self:AddClick(item:FindChild("DelBtn"), function()
            local cb = function(resp)
                self.black_list_count = self.black_list_count - 1
                if not self.is_res_ok then return end
                self:DelUIObject(item)
            end
            SpecMgrs.msg_mgr:SendDeleteFriendInBlackList({uuid = player_info.uuid}, cb)
        end)
    end
end

function FriendUI:OneKeyRemoveBlackList()
    if self.black_list_count == 0 then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.NOT_BLACKLIST_TIP)
        return
    end
    local cb = function()
        self:SelectShowBlackListFrame()
    end
    SpecMgrs.msg_mgr:SendRemoveAllFriendInBlackList(nil, cb)
end

function FriendUI:OneKeyDeleteBlackList()
    if self.black_list_count == 0 then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.NOT_BLACKLIST_TIP)
        return
    end
    local cb = function()
        self:SelectShowBlackListFrame()
    end
    SpecMgrs.msg_mgr:SendDeleteAllFriendInBlackList(nil, cb)
end

function FriendUI.SetPlayerItemMes(item, mes)
    local icon_id = SpecMgrs.data_mgr:GetRoleLookData(mes.role_id).head_icon_id
    UIFuncs.AssignSpriteByIconID(icon_id, item:FindChild("HeroIcon/Icon"):GetComponent("Image"))
    item:FindChild("FriendNameText"):GetComponent("Text").text = mes.name
    item:FindChild("LevelText"):GetComponent("Text").text = string.format(UIConst.Text.LEVEL_FORMAT_TEXT, mes.level)
    item:FindChild("ScoreText"):GetComponent("Text").text = string.format(UIConst.Text.SCORE_FORMAT_TEXT, mes.fight_score)
    local str
    if mes.dynasty then
        str = string.format(UIConst.Text.DYNASTY_FORMAT, mes.dynasty)
    else
        str = UIConst.Text.NO_DYNASTY_TEXT
    end
    item:FindChild("UnionName"):GetComponent("Text").text = str

    if ComMgrs.dy_data_mgr:ExGetServerId() == mes.server_id then
        str = string.format(UIConst.Text.LOCAL_SERVER_FORMAT_TEXT, mes.server_id)
    else
        str = string.format(UIConst.Text.CROSS_SERVER_FORMAT_TEXT, mes.server_id)
    end
    item:FindChild("ServerText"):GetComponent("Text").text = str
    if item:FindChild("OnlineMes") then
        item:FindChild("OnlineMes"):GetComponent("Text").text = FriendUI.GetOnlineMes(mes.offline_time)
    end
end

function FriendUI.GetOnlineMes(time)
    if time == 0 then
        return UIConst.Text.ONLINE_TEXT
    end
    local offline_duration = Time:GetServerTime() - time
    local duration_tb = UIFuncs.TimeDelta2Table(offline_duration, 6)
    local offline_text = UIConst.Text.OFFLINE_RECENTLY
    for i = 6, 3, -1 do
        if duration_tb[i] > 0 then
            offline_text = string.format(UIConst.Text.OFFLINE_DURATION_FORMAT, duration_tb[i], UIConst.Text.TIME_TEXT[i])
            break
        end
    end
    return offline_text
end

function FriendUI:CheckTip(tip)
    if tip == CSConst.FriendError.RepeatedFriend then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.REPEATED_FRIEND_TIP)
        return true
    elseif tip == CSConst.FriendError.MaxFriendCount then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.MAX_FRIEND_COUNT_TIP)
        return true
    elseif tip == CSConst.FriendError.MaxOtherFriendCount then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.MAX_OTHER_FRIEND_COUNT_TIP)
        return true
    end
end

function FriendUI:Hide()
    self.default_panel = nil
    self.dy_friend_data:UnregisterUpdateReciveCountEvent("FriendUI")
    self:RemoveRedPointList(self.redpoint_list)
    self.redpoint_list = nil
    self:DelObjDict(self.cur_frame_obj_list)
    self:DelObjDict(self.option_obj_list)
    FriendUI.super.Hide(self)
end

return FriendUI
