local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local JoinPartyUI = class("UI.JoinPartyUI", UIBase)
local UnitConst = require("Unit.UnitConst")
local UIFuncs = require("UI.UIFuncs")

JoinPartyUI.need_sync_load = true
local kFreeGiftType = 1

function JoinPartyUI:DoInit()
    JoinPartyUI.super.DoInit(self)
    self.prefab_path = "UI/Common/JoinPartyUI"
    self.dy_party_data = ComMgrs.dy_data_mgr.party_data
    self.party_gift_data_list = SpecMgrs.data_mgr:GetAllPartyGiftData()
    self.lover_id_to_go = {}
end

function JoinPartyUI:OnGoLoadedOk(res_go)
    JoinPartyUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function JoinPartyUI:Show(party_info)
    self.party_info = party_info
    if self.is_res_ok then
        self:InitUI()
    end
    JoinPartyUI.super.Show(self)
end

function JoinPartyUI:InitRes()
    UIFuncs.GetInitTopBar(self, self.main_panel, "JoinPartyPanel")

    local top_part = self.main_panel:FindChild("TopPart")
    self.lover_unit_parent = top_part:FindChild("Lover/UnitParent")
    top_part:FindChild("Tip/Text"):GetComponent("Text").text = UIConst.Text.SELECT_WHICH_LOVER_TO_JOIN_PARTY
    local right_go = top_part:FindChild("Right")
    local party_type_parent = right_go:FindChild("GiftTypeList")
    local party_type_temp = party_type_parent:FindChild("Temp")
    party_type_temp:SetActive(false)
    self.gift_type_to_go = {}
    for i, v in ipairs(self.party_gift_data_list) do
        local go = self:GetUIObject(party_type_temp, party_type_parent)
        self.gift_type_to_go[i] = go
        go:FindChild("Btn/Selected"):SetActive(false)
        self:AddClick(go:FindChild("Btn"), function ()
            self:PartyGiftTypeOnClick(i)
        end)
        go:FindChild("Btn/Cast/Text"):GetComponent("Text").text = self:GetBtnText(i)
    end
    right_go:FindChild("Title"):GetComponent("Text").text = UIConst.Text.JOIN_PARTY

    local bottme1_go = right_go:FindChild("Bottom1")
    bottme1_go:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.REWARD_TEXT
    local reward_go = bottme1_go:FindChild("Reward")
    self.reward_item_image = reward_go:FindChild("Image"):GetComponent("Image")
    self.reward_item_text = reward_go:FindChild("Text"):GetComponent("Text")

    local init_point_go = bottme1_go:FindChild("InitPoint")
    init_point_go:FindChild("Text"):GetComponent("Text").text = UIConst.Text.BASE_PARTY_POINT
    self.init_point_text = init_point_go:FindChild("Num"):GetComponent("Text")

    local game_num_go = bottme1_go:FindChild("GameNum")
    game_num_go:FindChild("Text"):GetComponent("Text").text = UIConst.Text.JOIN_PARTY_GAME_NUM
    self.game_num_text = game_num_go:FindChild("Num"):GetComponent("Text")

    self.start_party_btn = right_go:FindChild("Bottom2/StartPartyBtn")
    self.start_party_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.JOIN_PARTY
    self:AddClick(self.start_party_btn, function()
        self:StartPartyBtnOnClick()
    end)
    local title = self.main_panel:FindChild("LoverList/Title")
    title:FindChild("Lover/Text"):GetComponent("Text").text = UIConst.Text.LOVER
    title:FindChild("Level/Text"):GetComponent("Text").text = UIConst.Text.LOVER_LEVEL
    title:FindChild("Score/Text"):GetComponent("Text").text = UIConst.Text.POINT_EARN
    self.lover_go_parent = self.main_panel:FindChild("LoverList/Viewport/Content")
    self.lover_go_temp = self.lover_go_parent:FindChild("Temp")
    self.lover_go_temp:SetActive(false)
    self.lover_go_temp:FindChild("Level/Item/Level"):GetComponent("Text").text = UIConst.Text.LOVER_LEVEL

    local bottom_bar = self.main_panel:FindChild("BottomBar")
    bottom_bar:FindChild("Text1"):GetComponent("Text").text = UIConst.Text.BREAK_PARTY_TEXT1
    bottom_bar:FindChild("Text2"):GetComponent("Text").text = UIConst.Text.BREAK_PARTY_TEXT2
    local party_buster_get_point_ratio = SpecMgrs.data_mgr:GetParamData("party_buster_get_point_ratio").f_value
    local get_point_ratio_str = UIFuncs.GetPercentStr(party_buster_get_point_ratio)
    bottom_bar:FindChild("Text3"):GetComponent("Text").text = string.format(UIConst.Text.BREAK_PARTY_TEXT3, get_point_ratio_str)

    bottom_bar:FindChild("CastItem/Cast"):GetComponent("Text").text = string.format(UIConst.Text.COLON, UIConst.Text.CAST)
    self.break_party_cast_text = bottom_bar:FindChild("CastItem/Num"):GetComponent("Text")
    self.break_party_cast_image = bottom_bar:FindChild("CastItem/Image"):GetComponent("Image")
    local break_party_btn = bottom_bar:FindChild("BreakBtn")
    break_party_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.BREAK_PARTY
    self:AddClick(break_party_btn, function ()
        self:BreakPartyBtnOnClick()
    end)

    self.free_gift_cool_text = right_go:FindChild("CoolText"):GetComponent("Text")
end

function JoinPartyUI:BreakPartyBtnOnClick()
    local party_type_data = SpecMgrs.data_mgr:GetPartyData(self.party_info.party_type_id)
    local item_id = party_type_data.break_cost_item
    local need_count = party_type_data.break_cost_num
    local item_dict = {[item_id] = need_count}
    local desc = UIFuncs.GetCastItemStr(item_dict, UIConst.Text.BREAK_PARTY)
    local param_tb = {
        item_id = item_id,
        need_count = need_count,
        desc = desc,
        title = UIConst.Text.BREAK_PARTY,
        confirm_cb = function()
            self:SendBreakParty(self.party_info.party_id)
        end,
    }
    SpecMgrs.ui_mgr:ShowItemUseRemindByTb(param_tb)
end

function JoinPartyUI:SendBreakParty(party_id)
    SpecMgrs.msg_mgr:SendMsg("SendPartyInterrupt", {party_id = party_id}, function (resp)
        if resp.end_type then
            SpecMgrs.ui_mgr:ShowMsgSelectBox({content = UIConst.Text.CUR_PARTY_ALREADY_END, is_show_cancel_btn = false, confirm_cb = function ()
                SpecMgrs.ui_mgr:HideUI(self)
                SpecMgrs.ui_mgr:HideUI("PartyInfoUI")
            end})
        else
            SpecMgrs.ui_mgr:HideUI(self)
            SpecMgrs.ui_mgr:ShowUI("PartyInfoUI", self.party_info)
        end
    end)
end

function JoinPartyUI:InitUI()
    self:PartyGiftTypeOnClick(kFreeGiftType)
    self:UpdateLoverListCache()
    self:UpdateCoolTime(true)
    self:UpdateBtnText()
end

function JoinPartyUI:Update(delta_time)
    self:UpdateCoolTime()
end

function JoinPartyUI:UpdateBtnText()
    self.is_free_gift_ok = self.dy_party_data:IsFreeGiftOk()
    local free_gift_data = SpecMgrs.data_mgr:GetPartyGiftData(kFreeGiftType)
    local btn_str = self.is_free_gift_ok and UIConst.Text.FREE_FOR_THIS_TIME or self:GetBtnText(kFreeGiftType)
    self.gift_type_to_go[kFreeGiftType]:FindChild("Btn/Cast/Text"):GetComponent("Text").text = btn_str
    local party_type_data = SpecMgrs.data_mgr:GetPartyData(self.party_info.party_type_id)
    UIFuncs.AssignSpriteByItemID(party_type_data.break_cost_item, self.break_party_cast_image)
    self.break_party_cast_text.text = party_type_data.break_cost_num
end

function JoinPartyUI:GetBtnText(gift_id)
    local gift_data = SpecMgrs.data_mgr:GetPartyGiftData(gift_id)
    local item_data = SpecMgrs.data_mgr:GetItemData(gift_data.cost_item_list[1])
    return string.format(UIConst.Text.ITEM_COUNT_FORMAT, gift_data.cost_item_count_list[1], item_data.name)
end

function JoinPartyUI:UpdateCoolTime(is_first_set)
    if is_first_set then
        self.next_free_gift_time = self.dy_party_data:GetNextFreeGiftCoolTime()
    end
    if not self.next_free_gift_time then
        self.free_gift_cool_text.text = nil
        return
    end
    local remian_time = self.next_free_gift_time - Time:GetServerTime()
    if remian_time <= 0 then
        self.next_free_gift_time = nil
        self.free_gift_cool_text.text = nil
        self:UpdateBtnText()
    else
        self.free_gift_cool_text.text = UIFuncs.TimeDelta2Str(remian_time, 3, UIConst.Text.FREE_TIME_RECOVER_TIME)
    end
end

function JoinPartyUI:_UpdateLoverUnit(unit_id)
    if self.lover_unit_id and self.lover_unit_id == unit_id then return end
    self:CleanLoverUnit()
    self.lover_unit_id = unit_id
    self.lover_unit = self:AddFullUnit(unit_id, self.lover_unit_parent)
end

function JoinPartyUI:CleanLoverUnit()
    if self.lover_unit then
        ComMgrs.unit_mgr:DestroyUnit(self.lover_unit)
        self.lover_unit = nil
        self.lover_unit_id = nil
    end
end

function JoinPartyUI:Hide()
    self:ClearAllLoverGo()
    self:CleanLoverUnit()
    JoinPartyUI.super.Hide(self)
end

function JoinPartyUI:PartyGiftTypeOnClick(party_gift_id)
    local party_gift_data = SpecMgrs.data_mgr:GetPartyGiftData(party_gift_id)
    if self.cur_party_gift_id and self.cur_party_gift_id == party_gift_id then return end
    if self.cur_party_gift_id then self:SetGiftTypeSelect(self.cur_party_gift_id, false) end
    self.cur_party_gift_id = party_gift_id
    self:SetGiftTypeSelect(party_gift_id, true)
    local item_id = party_gift_data.reward_item_list[1]
    local item_data = SpecMgrs.data_mgr:GetItemData(item_id)
    local count = party_gift_data.reward_item_count_list[1]
    UIFuncs.AssignSpriteByItemID(item_id, self.reward_item_image)
    self.reward_item_text.text = string.format(UIConst.Text.ITEM_X_COUNT, item_data.name, count)

    self.game_num_text.text = party_gift_data.games_num
    self.init_point_text.text = party_gift_data.init_party_point
end

function JoinPartyUI:SetGiftTypeSelect(party_gift_id, is_on)
    local go = self.gift_type_to_go[party_gift_id]:FindChild("Btn/Selected")
    go:SetActive(is_on)
end

function JoinPartyUI:StartPartyBtnOnClick()
    local lover_id = self.cur_lover_id
    local party_id = self.party_info.party_id
    local gift_id = self.cur_party_gift_id
    if not self.dy_party_data:CheckLoverCanJoinParty(lover_id, true) then return end
    if self.is_free_gift_ok and gift_id == kFreeGiftType then
        self:SendPartyJoin(lover_id, party_id, gift_id)
        return
    end
    local party_gift_data = SpecMgrs.data_mgr:GetPartyGiftData(self.cur_party_gift_id)
    local item_dict = {}
    for i, item_id in pairs(party_gift_data.cost_item_list) do
        item_dict[item_id] = party_gift_data.cost_item_count_list[i]
    end
    local desc = UIFuncs.GetCastItemStr(item_dict, UIConst.Text.JOIN_PARTY)
    local param_tb = {
        item_dict = item_dict,
        desc = desc,
        title = UIConst.Text.JOIN_PARTY,
        confirm_cb = function()
            self:SendPartyJoin(lover_id, party_id, gift_id)
        end,
    }
    SpecMgrs.ui_mgr:ShowItemUseRemindByTb(param_tb)
end

function JoinPartyUI:SendPartyJoin(lover_id, party_id, gift_id)
    if not self.dy_party_data:CheckLoverCanJoinParty(lover_id, true) then return end
    local param_tb = {lover_id = lover_id, gift_id = gift_id, party_id = party_id}
    SpecMgrs.msg_mgr:SendMsg("SendPartyJoin", param_tb, function(resp)
        if resp.end_type then
            SpecMgrs.ui_mgr:ShowMsgSelectBox({content = UIConst.Text.CUR_PARTY_ALREADY_END, is_show_cancel_btn = false, confirm_cb = function ()
                SpecMgrs.ui_mgr:HideUI(self)
                SpecMgrs.ui_mgr:HideUI("PartyInfoUI")
            end})
        else
            SpecMgrs.ui_mgr:HideUI(self)
            local select_ui = SpecMgrs.ui_mgr:GetUI("SelectPartyUI")
            if select_ui then
                select_ui:Hide()
            end
            SpecMgrs.ui_mgr:HideUI("SelectPartyUI")
            local party_info = self.dy_party_data:GetJoinPartyInfo()
            SpecMgrs.ui_mgr:ShowUI("PartyInfoUI", party_info)
            local lover_level = ComMgrs.dy_data_mgr.lover_data:GetServLoverDataById(lover_id).level
            SpecMgrs.ui_mgr:ShowUI("JoinPartySuccessUI", self.cur_party_gift_id, lover_level)
        end
    end)
end

function JoinPartyUI:UpdateLoverListCache()
    self.lover_data_list = self.dy_party_data:GetPartyLoverList(false)
    self:ClearAllLoverGo()
    for i, serv_lover_data in ipairs(self.lover_data_list) do
        local go = self:GetUIObject(self.lover_go_temp, self.lover_go_parent)
        self.lover_id_to_go[serv_lover_data.lover_id] = go
        local native_lover_data = SpecMgrs.data_mgr:GetLoverData(serv_lover_data.lover_id)
        go:FindChild("Lover/Text"):GetComponent("Text").text = native_lover_data.name
        go:FindChild("Selected"):SetActive(false)
        go:FindChild("Level/Item/Num"):GetComponent("Text").text = serv_lover_data.level
        local point_add_ratio = math.floor(self.dy_party_data:GetLoverPartyPointAddRatio(serv_lover_data.level) * 100)
        go:FindChild("Score/Text"):GetComponent("Text").text = string.format(UIConst.Text.EXTRA_POINT_ADD_RATIO, point_add_ratio)
        self:AddClick(go, function ()
            self:LoverGoOnClick(serv_lover_data, native_lover_data)
        end)
        local is_show_resting = not self.dy_party_data:CheckLoverCanJoinParty(serv_lover_data.lover_id)
        go:FindChild("Resting"):SetActive(is_show_resting)
    end
    self:LoverGoOnClick(self.lover_data_list[1])
end

function JoinPartyUI:ClearAllLoverGo()
    for _, go in pairs(self.lover_id_to_go) do
        self:DelUIObject(go)
    end
    self.lover_id_to_go = {}
    self.cur_lover_id = nil
end

function JoinPartyUI:LoverGoOnClick(serv_lover_data, native_lover_data)
    local lover_id = serv_lover_data.lover_id
    local native_lover_data = native_lover_data or SpecMgrs.data_mgr:GetLoverData(lover_id)
    if self.cur_lover_id and self.cur_lover_id == lover_id then return end
    if self.cur_lover_id then
        self.lover_id_to_go[self.cur_lover_id]:FindChild("Selected"):SetActive(false)
    end
    self.cur_lover_id = lover_id
    local go = self.lover_id_to_go[lover_id]
    go:FindChild("Selected"):SetActive(true)
    self:_UpdateLoverUnit(native_lover_data.unit_id)
end

return JoinPartyUI