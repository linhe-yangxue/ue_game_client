local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local UnitConst = require("Unit.UnitConst")

local TravelEventUI = class("UI.TravelEventUI", UIBase)

function TravelEventUI:DoInit()
    TravelEventUI.super.DoInit(self)
    self.prefab_path = "UI/Common/TravelEventUI"
    self.dy_travel_data = ComMgrs.dy_data_mgr.travel_data
end

function TravelEventUI:OnGoLoadedOk(res_go)
    TravelEventUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function TravelEventUI:Show(event_data)
    self.event_data = event_data
    if self.is_res_ok then
        self:InitUI()
    end
    TravelEventUI.super.Show(self)
end

function TravelEventUI:Hide()
    self.unlock_lover_id = nil
    if self.lover_model then
        ComMgrs.unit_mgr:DestroyUnit(self.lover_model)
        self.lover_model = nil
    end
    TravelEventUI.super.Hide(self)
end

function TravelEventUI:InitRes()
    self:AddClick(self.go:FindChild("Bg"), function ()
        self:CloseTravelEvent()
    end)

    local event_content = self.main_panel:FindChild("Content")
    self:AddClick(event_content:FindChild("CloseBtn"), function ()
        self:CloseTravelEvent()
    end)
    self.event_name = event_content:FindChild("EventName"):GetComponent("Text")
    self.event_picture = event_content:FindChild("EventPicture"):GetComponent("Image")
    self.lover_img = event_content:FindChild("LoverModel")
    self.event_desc = event_content:FindChild("DescBg/Desc"):GetComponent("Text")
    self.reward_content = event_content:FindChild("RewardContent")
    self.reward_icon = self.reward_content:FindChild("Icon"):GetComponent("Image")
    self.reward_count = self.reward_content:FindChild("Count"):GetComponent("Text")
end

function TravelEventUI:InitUI()
    self:ShowTravelEvent()
end

function TravelEventUI:ShowTravelEvent()
    if not self.event_data then
        self:Hide()
        return
    end
    local travel_event = SpecMgrs.data_mgr:GetTravelEventData(self.event_data.event_id)
    UIFuncs.AssignUISpriteSync(travel_event.event_img_path, travel_event.event_img_name, self.event_picture)
    if travel_event.lover_id then
        local lover_data = SpecMgrs.data_mgr:GetLoverData(travel_event.lover_id)
        self.lover_model = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = lover_data.unit_id, parent = self.lover_img})
        self.lover_model:SetPositionByRectName({parent = self.lover_img, name = UnitConst.UnitRect.Half, need_sync_load = true})
        self.lover_model:StopAllAnimationToCurPos()
    end
    if self.event_data.meet_id then
        local lover_meet_data = SpecMgrs.data_mgr:GetLoverMeetData(self.event_data.meet_id)
        self.event_name.text = SpecMgrs.data_mgr:GetLoverData(travel_event.lover_id).name
        self.event_desc.text = lover_meet_data.event_content
        if #SpecMgrs.data_mgr:GetLoverMeetEventList(travel_event.lover_id) == lover_meet_data.meet_index then
            self.unlock_lover_id = travel_event.lover_id
        end
    else
        self.event_name.text = travel_event.event_name
        self.event_desc.text = travel_event.event_content
    end
    self.reward_content:SetActive(self.event_data.item_id ~= nil)
    if self.event_data.item_id then
        local item_data = SpecMgrs.data_mgr:GetItemData(self.event_data.item_id)
        if not item_data then self.reward_content:SetActive(false) end
        UIFuncs.AssignSpriteByIconID(item_data.icon, self.reward_icon)
        local format = self.event_data.count > 0 and UIConst.Text.ADD or UIConst.Text.ITEM_COUNT_FORMAT
        self.reward_count.text = string.format(format, item_data.name, self.event_data.count)
    end
end

function TravelEventUI:CloseTravelEvent()
    if self.unlock_lover_id then
        SpecMgrs.ui_mgr:PlayUnitUnlockAnim({lover_id = self.unlock_lover_id, finish_cb = self.event_data.confirm_cb})
    elseif self.event_data.confirm_cb then
        self.event_data.confirm_cb()
    end
    self:Hide()
end

return TravelEventUI