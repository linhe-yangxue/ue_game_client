local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local SalonAreaUI = class("UI.SalonAreaUI", UIBase)
local kSalonPointAttrDict = {
    ["etiquette"] = "Etiquette",
    ["culture"] = "Culture",
    ["charm"] = "Charm",
}

function SalonAreaUI:DoInit()
    SalonAreaUI.super.DoInit(self)
    self.prefab_path = "UI/Common/SalonAreaUI"
    self.dy_salon_data = ComMgrs.dy_data_mgr.salon_data
    self.dy_lover_data = ComMgrs.dy_data_mgr.lover_data
    self.attr_addition_ratio = SpecMgrs.data_mgr:GetParamData("salon_attr_point_ratio").f_value
    self.max_player = SpecMgrs.data_mgr:GetParamData("salon_pvp_term_player_num").f_value
    self.lover_go_dict = {}
    self.rank_item_list = {}
    self.attr_point_dict = {}
    self.lover_model_dict = {}
    self.lover_attr_data_dict = {}
end

function SalonAreaUI:OnGoLoadedOk(res_go)
    SalonAreaUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function SalonAreaUI:Hide()
    if self.lover_model then
        ComMgrs.unit_mgr:DestroyUnit(self.lover_model)
        self.lover_model = nil
    end
    self:ClearLoverGo()
    self.dy_salon_data:UnregisterUpdateSalonAreaEvent("SalonAreaUI")
    SalonAreaUI.super.Hide(self)
end

function SalonAreaUI:Show(area_id)
    self.area_id = area_id
    if self.is_res_ok then
        self:InitUI()
    end
    SalonAreaUI.super.Show(self)
end

function SalonAreaUI:InitRes()
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "SalonAreaUI", function ()
        self.select_lover = nil
        SpecMgrs.ui_mgr:HideUI(self)
    end)
    self.title = self.main_panel:FindChild("TopBar/CloseBtn/Title"):GetComponent("Text")

    local content = self.main_panel:FindChild("Content")
    self.top_tips = content:FindChild("TopTips")
    self.start_time = self.top_tips:FindChild("StartTime"):GetComponent("Text")
    self.join_state = self.top_tips:FindChild("JoinState")
    self.join_state:GetComponent("Text").text = UIConst.Text.NOT_INVOLVED
    local select_panel = content:FindChild("SelectPanel")
    local attr_point_panel = select_panel:FindChild("AttrPointPanel")
    self.attr_point = attr_point_panel:FindChild("AttrPoint"):GetComponent("Text")
    self:AddClick(attr_point_panel:FindChild("AddPointBtn"), function ()
        self.dy_salon_data:SendBuyAttrPoint()
    end)
    select_panel:FindChild("TipsPanel/Tips"):GetComponent("Text").text = UIConst.Text.SALON_TIP
    local select_content = select_panel:FindChild("Content")
    local model_panel = select_content:FindChild("ModelPanel")
    self.lover_img = model_panel:FindChild("LoverImg")
    self:AddClick(self.lover_img, function ()
        self:SelectLover()
    end)
    self.idle_img = self.lover_img:FindChild("Image")
    self.lover_name = model_panel:FindChild("NameBg/Name"):GetComponent("Text")
    local info_panel = select_content:FindChild("InfoPanel")
    self.idle_panel = info_panel:FindChild("NoLover")
    self.idle_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.IDLE_TIP
    local send_btn = self.idle_panel:FindChild("SendBtn")
    send_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CLICK_FOR_SEND
    self:AddClick(send_btn, function ()
        self:SelectLover()
    end)

    self.attr_panel = info_panel:FindChild("AttrPanel")
    for lover_attr, ui_name in pairs(kSalonPointAttrDict) do
        local panel = self.attr_panel:FindChild(ui_name .. "Panel")
        local data = {}
        data.attr_value = panel:FindChild(ui_name):GetComponent("Text")
        data.attr_addition = panel:FindChild(ui_name .. "Addition"):GetComponent("Text")
        local add_btn = panel:FindChild("Add")
        data.attr_add_btn = add_btn
        data.attr_add_btn_cmp = add_btn:GetComponent("Button")
        self:AddClick(add_btn, function ()
            if self.used_attr_point < self.dy_salon_data:GetCurAttrPoint() then
                self.attr_point_dict[lover_attr] = (self.attr_point_dict[lover_attr] or 0) + 1
                self.used_attr_point = self.used_attr_point + 1
                self:UpdateLoverAttr()
            end
        end)
        local reduce_btn = panel:FindChild("Reduce")
        data.attr_reduce_btn = reduce_btn
        data.attr_reduce_btn_cmp = reduce_btn:GetComponent("Button")
        self:AddClick(reduce_btn, function ()
            if not self.attr_point_dict[lover_attr] or self.attr_point_dict[lover_attr] == 0 then return end
            self.attr_point_dict[lover_attr] = self.attr_point_dict[lover_attr] - 1
            self.used_attr_point = self.used_attr_point - 1
            self:UpdateLoverAttr()
        end)
        data.cur_attr_point = panel:FindChild("CurSalonPoint/Text"):GetComponent("Text")
        self.lover_attr_data_dict[lover_attr] = data
    end

    local planning_panel = self.attr_panel:FindChild("PlanningPanel")
    self.planning = planning_panel:FindChild("Planning"):GetComponent("Text")
    planning_panel:FindChild("PlanningTips"):GetComponent("Text").text = UIConst.Text.PLANNING_TIPS
    self.join_btn = self.attr_panel:FindChild("JoinBtn")
    self.join_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.JOIN_SALON
    self:AddClick(self.join_btn, function ()
        self:SendJoinSalon()
    end)
    self.joined = self.attr_panel:FindChild("Joined")

    self.rank_panel = content:FindChild("RankPanel")
    local icon_panel = self.rank_panel:FindChild("IconPanel")
    self.lover_icon = icon_panel:FindChild("LoverIcon"):GetComponent("Image")
    self.rank_text = icon_panel:FindChild("RankingBg/Text"):GetComponent("Text")
    self.rank_content = self.rank_panel:FindChild("RankBg/View/Content")
    self.first_place = self.rank_content:FindChild("First")
    table.insert(self.rank_item_list, self.first_place)
    self.second_place = self.rank_content:FindChild("Second")
    table.insert(self.rank_item_list, self.second_place)
    self.third_place = self.rank_content:FindChild("Third")
    table.insert(self.rank_item_list, self.third_place)
    self.ranking_item = self.rank_content:FindChild("RankingItem")
    for i = 4, self.max_player do
        local go = self:GetUIObject(self.ranking_item, self.rank_content)
        table.insert(self.rank_item_list, go)
    end
    self.reward_panel = self.rank_panel:FindChild("RewardPanel")
    self.reward_count = self.reward_panel:FindChild("RewardBg/Count"):GetComponent("Text")
    self.reward_btn = self.reward_panel:FindChild("RewardBtn")
    self.reward_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.GET_REWARD
    self:AddClick(self.reward_btn, function ()
        self.dy_salon_data:ReceiveSalonReward(self.area_id)
    end)
    self.review_btn = self.rank_panel:FindChild("ReviewBtn")
    self.review_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SALON_REVIEW
    self:AddClick(self.review_btn, function ()
        local salon_data = self.dy_salon_data:GetSalonData(self.area_id)
        SpecMgrs.ui_mgr:ShowUI("SalonRecordUI", self.area_id, CSConst.Salon.Today, salon_data.pvp_id)
    end)
end

function SalonAreaUI:InitUI()
    if not self.area_id then SpecMgrs.ui_mgr:HideUI(self) end
    self:UpdateSalonState()
    self:UpdateLoverInfoPanel()
    self:RegisterEvent( ComMgrs.dy_data_mgr, "UpdateCurrencyEvent", function (_, currency)
        UIFuncs.UpdateCurrencyItemNum(self._item_to_text_list, currency)
    end)
    self.dy_salon_data:RegisterUpdateSalonAreaEvent("SalonAreaUI", function ()
        self.used_attr_point = 0
        self:UpdateSalonState()
        self:UpdateLoverInfoPanel()
    end, self)
end

function SalonAreaUI:UpdateSalonState()
    local area_data = SpecMgrs.data_mgr:GetSalonAreaData(self.area_id)
    local salon_data = self.dy_salon_data:GetSalonData(self.area_id)
    if not area_data or not salon_data then
        SpecMgrs.ui_mgr:HideUI(self)
        return
    end
    self.title.text = area_data.name
    local state = self.dy_salon_data:CheckSalonStartTime(self.area_id)
    self.lover_img:GetComponent("Button").interactable = salon_data.lover_id == nil
    self.top_tips:SetActive(state == CSConst.SalonAreaState.Idle)
    self.join_state:SetActive(salon_data.lover_id == nil)
    self.join_btn:SetActive(salon_data.lover_id == nil)
    self.joined:SetActive(salon_data.lover_id ~= nil)
    self.rank_panel:SetActive(salon_data.lover_id ~= nil and salon_data.rank ~= nil)
    self:RemoveDynamicUI(self.start_time)
    if salon_data.lover_id then
        if salon_data.rank then
            self.top_tips:SetActive(false)
            self:InitRankList()
        elseif state == CSConst.SalonAreaState.Idle then
            local start_time = area_data.start_time * CSConst.Time.Hour + Time:GetServerTime() - Time:GetCurDayPassTime()
            self:AddDynamicUI(self.start_time, function ()
                self.start_time.text = string.format(UIConst.Text.WAITING, UIFuncs.TimeDelta2Str(start_time - Time:GetServerTime(), 3))
            end, 1, 0)
        elseif state == CSConst.SalonAreaState.Start then
            local finish_time = area_data.start_time * CSConst.Time.Hour - self.salon_delay_time + Time:GetServerTime() - Time:GetCurDayPassTime()
            self:AddDynamicUI(self.start_time, function ()
                self.start_time.text = string.format(UIConst.Text.SALONING, UIFuncs.TimeDelta2Str(finish_time - Time:GetServerTime(), 3))
            end, 1, 0)
        end
    else
        if state == CSConst.SalonAreaState.Idle then
            self.start_time.text = string.format(UIConst.Text.AREA_START_TIME, area_data.start_time)
        else
            self.start_time.text = UIConst.Text.SALON_FINISH
        end
    end
end

function SalonAreaUI:UpdateLoverInfoPanel()
    local salon_data = self.dy_salon_data:GetSalonData(self.area_id)
    local cur_lover = salon_data.lover_id or self.select_lover
    self.idle_img:SetActive(cur_lover == nil)
    self.idle_panel:SetActive(cur_lover == nil)
    self.attr_panel:SetActive(cur_lover ~= nil)
    self.attr_point.text = string.format(UIConst.Text.SALON_USABLE_POINT, self.dy_salon_data:GetCurAttrPoint())
    if cur_lover then
        local lover_data = SpecMgrs.data_mgr:GetLoverData(cur_lover)
        if salon_data.lover_id ~= self.select_lover then
            if self.lover_model then ComMgrs.unit_mgr:DestroyUnit(self.lover_model) end
            self.lover_model = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = lover_data.unit_id, parent = self.lover_img})
            self.lover_model:SetPositionByRectName({parent = self.lover_img, name = "full"})
            self.attr_point_dict = salon_data.attr_point_dict or {}
            self.used_attr_point = 0
        end
        self.lover_name.text = lover_data.name
        self:UpdateLoverAttr(cur_lover)
    else
        if self.lover_model then ComMgrs.unit_mgr:DestroyUnit(self.lover_model) end
        self.lover_name.text = UIConst.Text.WITHOUT_LOVER
    end
end

function SalonAreaUI:UpdateLoverAttr()
    local salon_data = self.dy_salon_data:GetSalonData(self.area_id)
    local lover_info = self.dy_lover_data:GetLoverInfo(salon_data.lover_id or self.select_lover)
    local lover_attr_dict = lover_info.attr_dict
    local usable_attr_point = self.dy_salon_data:GetCurAttrPoint() - self.used_attr_point
    self.attr_point.text = string.format(UIConst.Text.SALON_USABLE_POINT, usable_attr_point)

    for lover_attr, _ in pairs(kSalonPointAttrDict) do
        local attr_data = SpecMgrs.data_mgr:GetAttributeData(lover_attr)
        local attr_item = self.lover_attr_data_dict[lover_attr]
        local cur_attr_point = self.attr_point_dict[lover_attr] or 0
        local add_pct = cur_attr_point * self.attr_addition_ratio
        attr_item.attr_value.text = string.format(UIConst.Text.SALON_ATTR_FORMAT, attr_data.name, lover_attr_dict[lover_attr], math.ceil(lover_attr_dict[lover_attr] * add_pct))
        attr_item.attr_addition.text = string.format(UIConst.Text.SALON_ATTR_ADDITION_FORMAT, attr_data.name, math.floor(add_pct * 100))
        attr_item.attr_add_btn_cmp.interactable = salon_data.lover_id == nil and usable_attr_point > 0
        attr_item.attr_reduce_btn_cmp.interactable = salon_data.lover_id == nil and cur_attr_point > 0
        attr_item.cur_attr_point.text = cur_attr_point
    end
    self.planning.text = string.format(UIConst.Text.PLAN_FORMAL, lover_attr_dict.planning)
end

function SalonAreaUI:InitRankList()
    local salon_data = self.dy_salon_data:GetSalonData(self.area_id)
    local record_day, pvp_id = self.dy_salon_data:GetSalonRecordDayAndPvpId(self.area_id)
    if not pvp_id or not record_day then return end
    local lover_data = SpecMgrs.data_mgr:GetLoverData(salon_data.lover_id)
    self.review_btn:SetActive(not salon_data.integral)
    self.reward_btn:SetActive(salon_data.integral ~= nil)
    UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetUnitData(lover_data.unit_id).icon, self.lover_icon)
    self.rank_text.text = string.format(UIConst.Text.RANK_FORMAT, UIConst.Text.NUMBER_TEXT[salon_data.rank])
    self.reward_panel:SetActive(salon_data.integral ~= nil)
    if salon_data.integral then self.reward_count.text = string.format(UIConst.Text.ADD_VALUE_FORMAL, salon_data.integral) end

    SpecMgrs.msg_mgr:SendGetSalonRecord({salon_id = self.area_id, day = record_day, pvp_id = pvp_id}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_RECORD_FAILED)
        else
            local role_dict = resp.pvp_info.role_dict
            for i, rank_info in ipairs(resp.pvp_info.total_rank) do
                local rank_item = self.rank_item_list[i]
                if i > 3 then
                    rank_item:FindChild("Ranking"):GetComponent("Text").text = i
                end
                rank_item:FindChild("Name"):GetComponent("Text").text = role_dict[rank_info.uuid].name
                rank_item:FindChild("Score"):GetComponent("Text").text = rank_info.score
            end
            self.rank_content:GetComponent("RectTransform").anchoredPosition = Vector2.zero
        end
    end)
end

function SalonAreaUI:SelectLover()
    local salon_data = self.dy_salon_data:GetSalonData(self.area_id)
    local state = self.dy_salon_data:CheckSalonStartTime(self.area_id)
    if not salon_data.lover_id and state ~= CSConst.SalonAreaState.Idle then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.CUR_SALON_CLOSE)
        return
    end
    SpecMgrs.ui_mgr:ShowUI("SelectLoverUI", self.dy_salon_data:GetIdleLoverList(), function (lover_id)
        self.select_lover = lover_id
        self:UpdateLoverInfoPanel()
    end)
end

-- msg

-- 参加游园
function SalonAreaUI:SendJoinSalon()
    SpecMgrs.msg_mgr:SendSalonDispatchLover({salon_id = self.area_id, lover_id = self.select_lover, attr_point_dict = self.attr_point_dict}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.JOIN_SALON_FAILED)
        end
    end)
end

function SalonAreaUI:ClearLoverGo()
    for _, go in pairs(self.lover_go_dict) do
        self:DelUIObject(go)
    end
    self.lover_go_dict = {}
    for _, model in pairs(self.lover_model_dict) do
        ComMgrs.unit_mgr:DestroyUnit(model)
    end
    self.lover_model_dict = {}
end

return SalonAreaUI