local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local DateRecordUI = class("UI.DateRecordUI", UIBase)

local kLineWidth = 4
local kContentPadding = 106
local kDotImgHeight = 30


function DateRecordUI:DoInit()
    DateRecordUI.super.DoInit(self)
    self.prefab_path = "UI/Common/DateRecordUI"
    self.record_item_list = {}
    self.dy_lover_data = ComMgrs.dy_data_mgr.lover_data
    self.dy_travel_data = ComMgrs.dy_data_mgr.travel_data
end

function DateRecordUI:OnGoLoadedOk(res_go)
    DateRecordUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function DateRecordUI:Show(lover_id, city_id)
    self.lover_id = lover_id
    self.city_id = city_id
    if self.is_res_ok then
        self:InitUI()
    end
    DateRecordUI.super.Show(self)
end

function DateRecordUI:Hide()
    DateRecordUI.super.Hide(self)
end

function DateRecordUI:InitRes()
    local content = self.main_panel:FindChild("Content")
    self:AddClick(content:FindChild("Top/CloseBtn"), function ()
        self:Hide()
    end)
    content:FindChild("Top/Text"):GetComponent("Text").text = UIConst.Text.DATE_RECORD_TEXT
    self.empty_panel = content:FindChild("EmptyPanel")
    self.dialog_text = self.empty_panel:FindChild("Dialog/Text"):GetComponent("Text")
    self.lover_name = content:FindChild("LoverPanel/LoverName"):GetComponent("Text")
    self.city_name = content:FindChild("LoverPanel/City"):GetComponent("Text")
    self.record_content = content:FindChild("DateRecordList/View/Content")
    self.record_list = self.record_content:FindChild("DateRecordList")
    self.record_item = self.record_list:FindChild("DateRecordItem")
    self.unlock_content = self.record_content:FindChild("UnlockContent")
    self.unlock_text = self.unlock_content:FindChild("UnlockText"):GetComponent("Text")
    self.meet_rate = content:FindChild("BottomPanel/MeetRate"):GetComponent("Text")
end

function DateRecordUI:InitUI()
    if not self.lover_id or not self.city_id then
        self:Hide()
        return
    end
    self:ClearRecordItem()
    local lover_data = SpecMgrs.data_mgr:GetLoverData(self.lover_id)
    self.lover_name.text = lover_data.name
    self.city_name.text = SpecMgrs.data_mgr:GetTravelAreaData(self.city_id).name
    local lover_event_list = SpecMgrs.data_mgr:GetLoverMeetEventList(self.lover_id)
    if not lover_event_list then return end
    local lover_event_count = #lover_event_list
    self.unlock_content:SetActive(false)
    local cur_meet_id, meet_count = self.dy_travel_data:GetLoverDateRecord(self.lover_id)
    self.empty_panel:SetActive(cur_meet_id == nil)
    if not cur_meet_id then
        self.dialog_text.text = string.format(UIConst.Text.DATE_RECORD_NIL, lover_data.name)
        self.meet_rate.text = string.format(UIConst.Text.MEET_LOVER_RATE_FORMAT, lover_event_list[1].rate_desc)
        return
    end
    local cur_meet_data = SpecMgrs.data_mgr:GetLoverMeetData(cur_meet_id)
    -- 约定有且只有一个随机邂逅事件，可多次触发，且位于事件组的倒数第二个
    -- 随机事件之前为邂逅剧情事件，只触发一次，之后为获得情人事件，只触发一次
    if cur_meet_data.meet_index == meet_count then
        for i = 1, meet_count do
            self:SetRecordContent(i, lover_event_list[i].event_content, i == meet_count)
        end
    else
        -- 全部邂逅剧情
        for i = 1, lover_event_count - 2 do
            self:SetRecordContent(i, lover_event_list[i].event_content)
        end
        -- 随机邂逅事件
        local random_meet_count = meet_count - (lover_event_count - 2) - (cur_meet_data.meet_index == lover_event_count and 1 or 0)
        for i = 1, random_meet_count do
            self:SetRecordContent(i + lover_event_count - 2, lover_event_list[lover_event_count - 1].event_content, 1 == random_meet_count)
        end
        -- 获得事件
        self.unlock_content:SetActive(cur_meet_data.meet_index == lover_event_count)
        if cur_meet_data.meet_index == lover_event_count then
            self:SetRecordContent(meet_count, cur_meet_data.event_content, true)
            self.unlock_text.text = cur_meet_data.txt
        end
    end
    self.record_content:GetComponent("RectTransform").anchoredPosition = Vector2.zero
    if self.dy_lover_data:GetLoverInfo(self.lover_id) then
        self.meet_rate.text = UIConst.Text.HAVE_MEET_LOVER
    else
        self.meet_rate.text = string.format(UIConst.Text.MEET_LOVER_RATE_FORMAT, cur_meet_data.rate_desc)
    end
end

function DateRecordUI:SetRecordContent(meet_index, event_content, is_end)
    local record_item = self:GetUIObject(self.record_item, self.record_list)
    local line_img = record_item:FindChild("Line")
    record_item:FindChild("DateCount"):GetComponent("Text").text = string.format(UIConst.Text.DATE_COUNT, meet_index)
    local record_text = record_item:FindChild("RecordText"):GetComponent("Text")
    record_text.text = event_content
    local record_text_height = record_text.preferredHeight
    local record_item_rect = record_item:GetComponent("RectTransform")
    local record_item_height = record_text_height + kContentPadding
    record_item:GetComponent("LayoutElement").preferredHeight = record_item_height
    -- record_item_rect.sizeDelta = Vector2.New(record_item_rect.sizeDelta.x, record_item_height)
    line_img:SetActive(is_end ~= true)
    line_img:GetComponent("RectTransform").sizeDelta = Vector2.New(kLineWidth, record_item_height - kDotImgHeight)
    table.insert(self.record_item_list, record_item)
end

function DateRecordUI:ClearRecordItem()
    for _, record_item in ipairs(self.record_item_list) do
        self:DelUIObject(record_item)
    end
    self.record_item_list = {}
end

return DateRecordUI