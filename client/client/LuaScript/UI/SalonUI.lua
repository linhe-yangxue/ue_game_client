local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local SalonUI = class("UI.SalonUI", UIBase)

local salon_redpoint_control_id = {CSConst.RedPointControlIdDict.Salon}
local anchor_v2 = Vector2.New(1, 1)

function SalonUI:DoInit()
    SalonUI.super.DoInit(self)
    self.prefab_path = "UI/Common/SalonUI"
    self.dy_salon_data = ComMgrs.dy_data_mgr.salon_data
    self.salon_area_dict = {}
    self.salon_delay_time = SpecMgrs.data_mgr:GetParamData("salon_pvp_run_time").f_value * CSConst.Time.Minute
    self.record_go_list = {}
    self.redpoint_list = {}
end

function SalonUI:OnGoLoadedOk(res_go)
    SalonUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function SalonUI:Hide()
    self.dy_salon_data:UnregisterUpdateSalonAreaEvent("SalonUI")
    SalonUI.super.Hide(self)
end

function SalonUI:DoDestroy()
    self:RemoveRedPointList(self.redpoint_list)
    self.redpoint_list = {}
    SalonUI.super.DoDestroy(self)
end

function SalonUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    SalonUI.super.Show(self)
end

function SalonUI:InitRes()
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "SalonUI")

    local content = self.main_panel:FindChild("Content")
    for _, area_data in pairs(SpecMgrs.data_mgr:GetAllSalonAreaData()) do
        local area_content = content:FindChild(area_data.area_name)
        local salon_area_data = {}
        local join_btn = area_content:FindChild("JoinBtn")
        salon_area_data.join_btn = join_btn
        salon_area_data.lover_icon = join_btn:FindChild("LoverIcon")
        salon_area_data.red_point = join_btn:FindChild("NamePanel/RedPoint")
        salon_area_data.join_img = join_btn:FindChild("JoinImg")
        area_content:FindChild("NamePanel/Name"):GetComponent("Text").text = area_data.name
        local info_text = join_btn:FindChild("Info/Text")
        salon_area_data.info_text = info_text
        salon_area_data.info_text_cmp = info_text:GetComponent("Text")
        local disable = area_content:FindChild("Disable")
        salon_area_data.disable = disable
        disable:FindChild("Info/Text"):GetComponent("Text").text = UIConst.Text.SALON_FINISH
        self.salon_area_dict[area_data.id] = salon_area_data
        local redpoint = SpecMgrs.redpoint_mgr:AddRedPoint(self, join_btn, CSConst.RedPointType.Normal, salon_redpoint_control_id, area_data.id, anchor_v2, anchor_v2)
        table.insert(self.redpoint_list, redpoint)
    end

    local op_btn_panel = content:FindChild("OpBtnPanel")
    local rank_btn = op_btn_panel:FindChild("RankBtn")
    rank_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.RANK_LIST_TEXT
    self:AddClick(rank_btn, function ()

        SpecMgrs.ui_mgr:ShowRankUI(UIConst.Rank.SalonPoint)
    end)
    local shop_btn = op_btn_panel:FindChild("ShopBtn")
    shop_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SALON_SHOP_TEXT
    self:AddClick(shop_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("ShoppingUI", UIConst.ShopList.SalonShop)
    end)
    local salon_record_btn = op_btn_panel:FindChild("SalonRecord")
    salon_record_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SALON_RECORD
    self:AddClick(salon_record_btn, function ()
        self.record_panel:SetActive(true)
    end)

    local bottom_panel = self.main_panel:FindChild("BottomPanel/SalonPointPanel")
    self.attr_point = bottom_panel:FindChild("SalonPoint"):GetComponent("Text")
    self:AddClick(bottom_panel:FindChild("AddPointBtn"), function ()
        self.dy_salon_data:SendBuyAttrPoint()
    end)

    self.record_panel = self.main_panel:FindChild("RecordPanel")
    local top_panel = self.record_panel:FindChild("Content/Top")
    self:AddClick(top_panel:FindChild("CloseBtn"), function ()
        self.record_panel:SetActive(false)
    end)
    top_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SALON_RECORD
    local record_content = self.record_panel:FindChild("Content/Record/Viewport/Content")
    self.record_item = record_content:FindChild("RecordItem")
    self.record_item:FindChild("RecordBtn/Text"):GetComponent("Text").text = UIConst.Text.SALON_REVIEW
    local today_record_content = record_content:FindChild("Today")
    self.today_record_list = today_record_content:FindChild("RecordList")
    today_record_content:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.TODAY
    self.no_today_record = today_record_content:FindChild("NoRecord")
    self.no_today_record:GetComponent("Text").text = UIConst.Text.NO_TODAY_RECORD
    local yesterday_record_content = record_content:FindChild("Yesterday")
    yesterday_record_content:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.YESTERDAY
    self.yesterday_record_list = yesterday_record_content:FindChild("RecordList")
    self.no_yesterday_record = yesterday_record_content:FindChild("NoRecord")
    self.no_yesterday_record:GetComponent("Text").text = UIConst.Text.NO_YERTERDAY_RECORD
end

function SalonUI:InitUI()
    self:UpdateSalonArea()
    self.dy_salon_data:RegisterUpdateSalonAreaEvent("SalonUI", self.UpdateSalonArea, self)
    self:RegisterEvent( ComMgrs.dy_data_mgr, "UpdateCurrencyEvent", function (_, currency)
        UIFuncs.UpdateCurrencyItemNum(self._item_to_text_list, currency)
    end)
end

function SalonUI:UpdateSalonArea()
    self.attr_point.text = string.format(UIConst.Text.SALON_USABLE_POINT, self.dy_salon_data:GetCurAttrPoint())
    for area_id, area in pairs(self.salon_area_dict) do
        local salon_area_data = SpecMgrs.data_mgr:GetSalonAreaData(area_id)
        local salon_data = self.dy_salon_data:GetSalonData(area_id)
        area.join_btn:SetActive(salon_data ~= nil)
        if salon_data then
            self:AddClick(area.join_btn, function ()
                local record_day, pvp_id = self.dy_salon_data:GetSalonRecordDayAndPvpId(area_id)
                if salon_data.rank and not pvp_id then
                    self.dy_salon_data:ReceiveSalonReward(area_id)
                    return
                end
                SpecMgrs.ui_mgr:ShowUI("SalonAreaUI", area_id)
            end)
            area.join_img:SetActive(salon_data.lover_id == nil)
            area.lover_icon:SetActive(salon_data.lover_id ~= nil)
            local state = self.dy_salon_data:CheckSalonStartTime(area_id)
            area.join_btn:SetActive(salon_data.lover_id ~= nil or state == CSConst.SalonAreaState.Idle)
            area.disable:SetActive(not salon_data.lover_id and state ~= CSConst.SalonAreaState.Idle)
            self:RemoveDynamicUI(area.info_text)
            if salon_data.lover_id then
                local lover_unit_id = SpecMgrs.data_mgr:GetLoverData(salon_data.lover_id).unit_id
                UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetUnitData(lover_unit_id).icon, area.lover_icon:GetComponent("Image"))
                if salon_data.rank then
                    area.info_text_cmp.text = string.format(UIConst.Text.SALON_RANK, UIConst.Text.NUMBER_TEXT[salon_data.rank])
                elseif state == CSConst.SalonAreaState.Idle then
                    local start_time = salon_area_data.start_time * CSConst.Time.Hour + Time:GetServerTime() - Time:GetCurDayPassTime()
                    self:AddDynamicUI(area.info_text, function ()
                        area.info_text_cmp.text = string.format(UIConst.Text.WAITING, UIFuncs.TimeDelta2Str(start_time - Time:GetServerTime(), 3))
                    end, 1, 0)
                elseif state == CSConst.SalonAreaState.Start then
                    local finish_time = salon_area_data.start_time * CSConst.Time.Hour - self.salon_delay_time + Time:GetServerTime() - Time:GetCurDayPassTime()
                    self:AddDynamicUI(area.info_text, function ()
                        area.info_text_cmp.text = string.format(UIConst.Text.SALONING, UIFuncs.TimeDelta2Str(finish_time - Time:GetServerTime(), 3))
                    end, 1, 0)
                end
            else
                if state == CSConst.SalonAreaState.Idle then
                    area.info_text_cmp.text = string.format(UIConst.Text.AREA_START_TIME, salon_area_data.start_time)
                end
            end
        end
    end
    self:UpdateSalonRecordPanel()
end

function SalonUI:UpdateSalonRecordPanel()
    self:ClearRecordItem()
    local today_salon_list = self.dy_salon_data:GetSalonRecordList()
    local today_record_count = #today_salon_list
    self.no_today_record:SetActive(today_record_count == 0)
    self.today_record_list:SetActive(today_record_count > 0)
    for salon_id, record_data in pairs(today_salon_list) do
        local lover_data = SpecMgrs.data_mgr:GetLoverData(record_data.lover_id)
        local area_data = SpecMgrs.data_mgr:GetSalonAreaData(record_data.salon_id)
        local record_go = self:GetUIObject(self.record_item, self.today_record_list)
        record_go:FindChild("Text"):GetComponent("Text").text = string.format(UIConst.Text.SALON_RANK_TEXT, lover_data.name, area_data.name, UIConst.Text.NUMBER_TEXT[record_data.rank])
        self:AddClick(record_go:FindChild("RecordBtn"), function ()
            SpecMgrs.ui_mgr:ShowUI("SalonRecordUI", record_data.salon_id, CSConst.Salon.Today, record_data.pvp_id)
        end)
        table.insert(self.record_go_list, record_go)
    end

    local yesterday_salon_list = self.dy_salon_data:GetYesterdaySalonRecordList()
    local yesterday_record_count = #yesterday_salon_list
    self.no_yesterday_record:SetActive(yesterday_record_count == 0)
    self.yesterday_record_list:SetActive(yesterday_record_count > 0)
    for salon_id, record_data in ipairs(yesterday_salon_list) do
        local lover_data = SpecMgrs.data_mgr:GetLoverData(record_data.lover_id)
        local area_data = SpecMgrs.data_mgr:GetSalonAreaData(record_data.salon_id)
        local record_go = self:GetUIObject(self.record_item, self.yesterday_record_list)
        record_go:FindChild("Text"):GetComponent("Text").text = string.format(UIConst.Text.SALON_RANK_TEXT, lover_data.name, area_data.name, UIConst.Text.NUMBER_TEXT[record_data.rank])
        self:AddClick(record_go:FindChild("RecordBtn"), function ()
            SpecMgrs.ui_mgr:ShowUI("SalonRecordUI", record_data.salon_id, CSConst.Salon.Yesterday, record_data.pvp_id)
        end)
        table.insert(self.record_go_list, record_go)
    end
end

function SalonUI:ClearRecordItem()
    for _, record_go in ipairs(self.record_go_list) do
        self:DelUIObject(record_go)
    end
    self.record_go_list = {}
end

return SalonUI