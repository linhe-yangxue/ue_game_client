local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local ItemUtil = require("BaseUtilities.ItemUtil")
local DailyRechargeUI = class("UI.LimitTimeActivity.DailyRechargeUI", UIBase)

function DailyRechargeUI:DoInit()
    DailyRechargeUI.super.DoInit(self)
end

--  每日单冲
function DailyRechargeUI:InitRes(owner)
    self.owner = owner
    self.daily_recharge_frame = self.owner.main_panel:FindChild("DailyRechargeFrame")
    self.up_frame_title_text = self.owner.main_panel:FindChild("DailyRechargeFrame/Frame/UpFrame/TitleText"):GetComponent("Text")
    self.up_bg = self.owner.main_panel:FindChild("DailyRechargeFrame/Frame/UpFrame/Bg"):GetComponent("Image")
    self.unit_point = self.owner.main_panel:FindChild("DailyRechargeFrame/Frame/UpFrame/UnitPoint")
    self.recharge_tip_text = self.owner.main_panel:FindChild("DailyRechargeFrame/Frame/UpFrame/RechargeTipText"):GetComponent("Text")
    self.activity_end_time = self.owner.main_panel:FindChild("DailyRechargeFrame/Frame/UpFrame/ActivityEndTime"):GetComponent("Text")
    self.reward_receive_end_time = self.owner.main_panel:FindChild("DailyRechargeFrame/Frame/UpFrame/RewardReceiveEndTime"):GetComponent("Text")

    self.luxury_frame = self.owner.main_panel:FindChild("DailyRechargeFrame/Frame/LuxuryFrame")
    self.luxury_frame_title_text = self.owner.main_panel:FindChild("DailyRechargeFrame/Frame/LuxuryFrame/TitleText"):GetComponent("Text")
    self.luxury_frame_tip_text = self.owner.main_panel:FindChild("DailyRechargeFrame/Frame/LuxuryFrame/BottomPanel/DetailTxt"):GetComponent("Text")
    self.luxury_frame_shop_text = self.owner.main_panel:FindChild("DailyRechargeFrame/Frame/LuxuryFrame/ShopBtn/ShopTxt"):GetComponent("Text")
    self.luxury_frame_shop_btn = self.owner.main_panel:FindChild("DailyRechargeFrame/Frame/LuxuryFrame/ShopBtn")
    self.owner:AddClick(self.luxury_frame_shop_btn, function()
        SpecMgrs.ui_mgr:ShowUI("ShoppingUI", UIConst.ShopList.CrystalShop)
    end)

    self.up_frame = self.owner.main_panel:FindChild("DailyRechargeFrame/Frame/UpFrame")

    self.down_frame = self.owner.main_panel:FindChild("DailyRechargeFrame/Frame/DownFrame")
    self.daily_recharge_text = self.owner.main_panel:FindChild("DailyRechargeFrame/Frame/DownFrame/DailyRechargeText"):GetComponent("Text")
    self.daily_recharge_list = self.owner.main_panel:FindChild("DailyRechargeFrame/Frame/DownFrame/DailyRechargeList/ViewPort/DailyRechargeList")
    self.daily_recharge_mes = self.owner.main_panel:FindChild("DailyRechargeFrame/Frame/DownFrame/DailyRechargeList/ViewPort/DailyRechargeList/DailyRechargeMes")
    self.daily_recharge_mes:SetActive(false)
    self.daily_recharge_frame:SetActive(false)
end

function DailyRechargeUI:Show(recharge_activity_id)
    self:ClearRes()
    self.effect_list = {}
    self.is_end = false
    self.is_close = false
    self.recharge_activity_id = recharge_activity_id
    self.daily_recharge_data = SpecMgrs.data_mgr:GetRechargeActivityData(recharge_activity_id)
    self.daily_recharge_frame:SetActive(true)
    self:UpdateData()
    self:SetTextVal()
    self:UpdateUIInfo()
    if self.recharge_type == CSConst.RechargeActivity.SingleRecharge then
        ComMgrs.dy_data_mgr.recharge_data:RegisterUpdateSingleRechargeInfo("DailyRechargeUI", function()
            self:RefleshUI()
        end, self)
        ComMgrs.dy_data_mgr.recharge_data:RegisterEndSingleRechargeInfo("DailyRechargeUI", function()
            self.is_end = true
            self:RefleshUI()
        end, self)
        ComMgrs.dy_data_mgr.recharge_data:RegisterCloseSingleRechargeInfo("DailyRechargeUI", function()
            self.is_close = true
            self:RefleshUI()
        end, self)
        self.owner:AddHalfUnit(self.daily_recharge_data.unit, self.unit_point)
    end
    if self.recharge_type == CSConst.RechargeActivity.AccumeRecharge then
        ComMgrs.dy_data_mgr.recharge_data:RegisterUpdateAccumRecharge("DailyRechargeUI", function()
            self:RefleshUI()
        end, self)
        self.owner:AddHalfUnit(self.daily_recharge_data.unit, self.unit_point)
    end
    if self.recharge_type == CSConst.RechargeActivity.LuxuryCheckin then
        ComMgrs.dy_data_mgr.recharge_data:RegisterUpdateLuxuryCheckin("DailyRechargeUI", function()
            self:RefleshUI()
        end, self)
    end
    self.daily_recharge_list:GetComponent("RectTransform").anchoredPosition = Vector3.zero
end

function DailyRechargeUI:SetTextVal()
    self.recharge_tip_text.text = self.daily_recharge_data.activity_desc
    self.daily_recharge_text.text = self.daily_recharge_data.title
    if self.recharge_type == CSConst.RechargeActivity.SingleRecharge then
        self.activity_end_time.text = string.format(UIConst.Text.ACTIVITY_END_TIME_FORMAT, self.daily_recharge_data.activity_end_time)
        self.reward_receive_end_time.text = string.format(UIConst.Text.ACTIVITY_REWARD_END_TIME_FORMAT, self.daily_recharge_data.activity_close_time)
        self.up_frame_title_text.text = self.daily_recharge_data.activity_name
    elseif self.recharge_type == CSConst.RechargeActivity.AccumeRecharge then
        self.activity_end_time.text = string.format(UIConst.Text.ACTIVITY_END_TIME_FORMAT, os.date(UIConst.MinuteHappenTimeFormat, self.recharge_data:GetAccumRechargeStopTs()))
        self.reward_receive_end_time.text = string.format(UIConst.Text.ACTIVITY_REWARD_END_TIME_FORMAT, os.date(UIConst.MinuteHappenTimeFormat, self.recharge_data:GetAccumRechargeEndTs()))
        self.up_frame_title_text.text = self.daily_recharge_data.activity_name
    elseif self.recharge_type == CSConst.RechargeActivity.LuxuryCheckin then
        self.luxury_frame_tip_text.text = self.daily_recharge_data.activity_desc
        self.luxury_frame_shop_text.text = UIFuncs.GetShopNameByShopType(UIConst.ShopList.CrystalShop)
        self.luxury_frame_title_text.text = self.daily_recharge_data.activity_name
    end
    self.daily_recharge_mes:FindChild("AlreadyReceived/AlreadyReceivedText"):GetComponent("Text").text = UIConst.Text.ALREADY_RECEIVE_TEXT
    self.daily_recharge_mes:FindChild("RechargeBtn/Text"):GetComponent("Text").text = UIConst.Text.GO_TO_RECHARGE
    self.daily_recharge_mes:FindChild("ReciveBtn/Text"):GetComponent("Text").text = UIConst.Text.RECEIVE_TEXT
end

function DailyRechargeUI:UpdateData()
    self.recharge_data = ComMgrs.dy_data_mgr.recharge_data
    self.single_recharge_data_list = {}

    self.recharge_activity_data = SpecMgrs.data_mgr:GetRechargeActivityData(self.recharge_activity_id)
    self.recharge_type = self.recharge_activity_data.activity_type

    if self.recharge_type == CSConst.RechargeActivity.SingleRecharge then
        local list = SpecMgrs.data_mgr:GetAllSingleRechargeData()
        for i, data in ipairs(list) do
            if data.activity_id == self.daily_recharge_data.id then
                table.insert(self.single_recharge_data_list, data)
            end
        end
    elseif self.recharge_type == CSConst.RechargeActivity.LuxuryCheckin then
        self.single_recharge_data_list = self.recharge_data:GetLuxuryCheckList()
    elseif self.recharge_type == CSConst.RechargeActivity.AccumeRecharge then
        self.is_end = ComMgrs.dy_data_mgr.recharge_data:CheckAccumRechargeIsEnd()
        self.single_recharge_data_list = self.recharge_data:GetAccumRechargeList()
    end
    --self.is_end = true
end

function DailyRechargeUI:UpdateUIInfo()
    if self.recharge_type == CSConst.RechargeActivity.LuxuryCheckin then
        self.up_frame:SetActive(false)
        self.luxury_frame:SetActive(true)
    else
        self.up_frame:SetActive(true)
        self.luxury_frame:SetActive(false)
    end
    if self.recharge_activity_data.bg then
        UIFuncs.AssignSpriteByIconID(self.recharge_activity_data.bg, self.up_bg)
    end
    for i, data in ipairs(self.single_recharge_data_list) do
        local item = self.owner:GetUIObject(self.daily_recharge_mes, self.daily_recharge_list)
        self:SetItemMes(item, data)
        table.insert(self.create_obj_list, item)
    end
end

function DailyRechargeUI:SetItemMes(item, data)
    local state
    local recharge_tip_str
    local limit_time_tip_str
    local reward_id
    if self.recharge_type == CSConst.RechargeActivity.SingleRecharge then
        state = self.recharge_data:GetDailyRechargeState(data.activity_id, data.id)
        recharge_tip_str = string.format(UIConst.Text.RECHARGE_FORMAT, SpecMgrs.data_mgr:GetRechargeData(data.recharge_rank).recharge_count)
        reward_id = data.reward_id
        limit_time_tip_str = string.format(UIConst.Text.SURPLUS_TIME_FORMAT, state.remain_time, data.limit_num)
    elseif self.recharge_type == CSConst.RechargeActivity.LuxuryCheckin then
        state = self.recharge_data:GetLuxuryRechargeState(data.id)
        recharge_tip_str = string.format(UIConst.Text.RECHARGE_FORMAT, SpecMgrs.data_mgr:GetRechargeData(data.recharge_rank).recharge_count)
        reward_id = self.recharge_data:GetLuxuryCheckRewardID(data.id)
        if data.month_limit_time then
            limit_time_tip_str = string.format(UIConst.Text.WEEK_SURPLUS_TIME_FORMAT, state.remain_time, data.month_limit_time)
        elseif data.daily_limit_time then
            limit_time_tip_str = string.format(UIConst.Text.DAILY_SURPLUS_TIME_FORMAT, state.remain_time, data.daily_limit_time)
        end
    elseif self.recharge_type == CSConst.RechargeActivity.AccumeRecharge then
        state = self.recharge_data:GetAccumRechargeState(data.id)
        recharge_tip_str = string.format(UIConst.Text.ACCUME_RECARGE_FORMAT, data.recharge_amount)
        reward_id = self.recharge_data:GetAccumRechargeRewardID(data.id)
        local recharge_amount = self.recharge_data:GetAccumRechargeAmount()
        limit_time_tip_str = string.format(UIConst.Text.ACCUME_RECHARGE_PROGRESS, UIFuncs.GetPerStr(recharge_amount, data.recharge_amount))
    end
    local reward_data = SpecMgrs.data_mgr:GetRewardData(reward_id)
    if reward_data.is_select then
        local select_str = string.format(UIConst.Text.SELECT_FORMAT, UIConst.Text.NUMBER_TEXT[#reward_data.reward_num_list], UIConst.Text.NUMBER_TEXT[1])
        recharge_tip_str = recharge_tip_str .. select_str
    end

    item:FindChild("DailyRechargeTip"):GetComponent("Text").text = recharge_tip_str
    item:FindChild("LimitTimeTipText"):GetComponent("Text").text = limit_time_tip_str

    local item_list = ItemUtil.GatherRewardItemList(reward_id)
    local ret = UIFuncs.SetItemList(self.owner, item_list, item:FindChild("RewardItemList"))
    table.mergeList(self.create_obj_list, ret)

    item:FindChild("AlreadyReceived"):SetActive(false)
    item:FindChild("ReciveBtn"):SetActive(false)
    item:FindChild("RechargeBtn"):SetActive(false)
    if self.is_close then
        item:FindChild("AlreadyReceived"):SetActive(true)
        item:FindChild("AlreadyReceived/AlreadyReceivedText"):GetComponent("Text").text = UIConst.Text.FINISH_ACTIVITY_TEXT
        return
    end
    if state.remain_time == 0 then
        item:FindChild("AlreadyReceived"):SetActive(true)
        item:FindChild("AlreadyReceived/AlreadyReceivedText"):GetComponent("Text").text = UIConst.Text.ALREADY_RECEIVE_TEXT
    else
        if state.can_recive then
            item:FindChild("ReciveBtn"):SetActive(true)
            self.owner:AddClick(item:FindChild("ReciveBtn"), function()
                self:ClickReciveReward(item, data, item_list, reward_id)
            end)
            table.insert(self.effect_list, UIFuncs.AddCompleteEffect(self.owner, item:FindChild("ReciveBtn")))
        else
            local is_end_activity = false
            if self.daily_recharge_data.activity_end_timestamp then
                is_end_activity = Time:GetServerTime() >= self.daily_recharge_data.activity_end_timestamp
            end
            if is_end_activity or self.is_end then
                item:FindChild("AlreadyReceived"):SetActive(true)
                item:FindChild("AlreadyReceived/AlreadyReceivedText"):GetComponent("Text").text = UIConst.Text.FINISH_ACTIVITY_TEXT
            else
                item:FindChild("RechargeBtn"):SetActive(true)
                self.owner:AddClick(item:FindChild("RechargeBtn"), function()
                    SpecMgrs.ui_mgr:ShowRechargeUI()
                end)
            end
        end
    end
end

function DailyRechargeUI:ClickReciveReward(item, data, item_list, reward_id)
    local reward_data = SpecMgrs.data_mgr:GetRewardData(reward_id)
    if not reward_data.is_select or #item_list == 1 then
        self:SendReciveReward(item, data, 1)
    else
        local start_list = table.shallowcopy(item_list)
        item_list = ItemUtil.SortRoleItemList(item_list, true)
        local cb = function(index)
            for i, v in ipairs(start_list) do
                if v.item_id == item_list[index].item_id then
                    self:SendReciveReward(item, data, i)
                    return
                end
            end
        end
        local param_tb = {
            role_item_list = item_list,
            confirm_cb = cb,
            count = nil,
        }
        SpecMgrs.ui_mgr:ShowChooseItemUseUI(param_tb)
    end
end

function DailyRechargeUI:SendReciveReward(item, data, index)
    local cb = function(resp)
        if not self.owner.is_res_ok then return end
        self:RefleshUI()
    end
    if self.recharge_type == CSConst.RechargeActivity.SingleRecharge then
        SpecMgrs.msg_mgr:SendReciveSingleRechargeReward({recharge_id = data.id, select_list = {index}}, cb)
    elseif self.recharge_type == CSConst.RechargeActivity.LuxuryCheckin then
        SpecMgrs.msg_mgr:SendReciveLuxuryRechargeReward({id = data.id}, cb)
    elseif self.recharge_type == CSConst.RechargeActivity.AccumeRecharge then
        SpecMgrs.msg_mgr:SendReceiveAccumRechargeReward({activity_id = data.id, select_index = index}, cb)
    end
end

function DailyRechargeUI:RefleshUI()
    self.owner:DelObjDict(self.create_obj_list)
    self.create_obj_list = {}
    self.owner:RemoveEffectList(self.effect_list)
    self:UpdateData()
    self:UpdateUIInfo()
end

function DailyRechargeUI:ClearRes()
    self.owner:DelObjDict(self.create_obj_list)
    self.owner:DestroyAllUnit()
    self.create_obj_list = {}
    self.owner:RemoveEffectList(self.effect_list)
    self.effect_list = {}
    ComMgrs.dy_data_mgr.recharge_data:UnregisterUpdateSingleRechargeInfo("DailyRechargeUI")
    ComMgrs.dy_data_mgr.recharge_data:UnregisterEndSingleRechargeInfo("DailyRechargeUI")
    ComMgrs.dy_data_mgr.recharge_data:UnregisterCloseSingleRechargeInfo("DailyRechargeUI")

    ComMgrs.dy_data_mgr.recharge_data:UnregisterUpdateAccumRecharge("DailyRechargeUI")
    ComMgrs.dy_data_mgr.recharge_data:UnregisterUpdateLuxuryCheckin("DailyRechargeUI")
end

function DailyRechargeUI:Hide()
    self:ClearRes()
    self.daily_recharge_frame:SetActive(false)
end

return DailyRechargeUI
