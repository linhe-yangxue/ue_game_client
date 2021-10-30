local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local EntertainmentUI = class("UI.EntertainmentUI", UIBase)

function EntertainmentUI:DoInit()
    EntertainmentUI.super.DoInit(self)
    self.dy_lover_data = ComMgrs.dy_data_mgr.lover_data
    self.prefab_path = "UI/Common/EntertainmentUI"
    self.salon_active_grade_data = SpecMgrs.data_mgr:GetGradeData(CSConst.SalonActiveLoverGrade)
end

function EntertainmentUI:OnGoLoadedOk(res_go)
    EntertainmentUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function EntertainmentUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    EntertainmentUI.super.Show(self)
end

function EntertainmentUI:Hide()
    EntertainmentUI.super.Hide(self)
end

function EntertainmentUI:InitRes()
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "EntertainmentUI", function ()
        SpecMgrs.stage_mgr:GotoStage("MainStage")
    end)
    local game_scene_panel = self.main_panel:FindChild("GameScenePanel")
    self.celebrity_hotel_btn = game_scene_panel:FindChild("CelebrityHotel")
    self.celebrity_hotel_btn:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.CELEBRITY_HOTEL
    self:AddClick(self.celebrity_hotel_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("CelebrityHotelUI")
    end)

    self.control_center_btn = game_scene_panel:FindChild("ControlCenter")
    self.control_center_btn:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.CONTROL_CENTER
    self:AddClick(self.control_center_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("ManagementCenterUI")
    end)

    self.child_playground_btn = game_scene_panel:FindChild("ChildPlayground")
    self.child_playground_btn:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.CHILD_PLAYGROUND
    self:AddClick(self.child_playground_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("ChildCenterUI")
    end)

    self.marriage_office_btn = game_scene_panel:FindChild("MarriageOffice")
    self.marriage_office_btn:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.MARRIAGE_OFFICE
    self:AddClick(self.marriage_office_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("LuxuryHouseUI")
    end)

    self.banquet_btn = game_scene_panel:FindChild("Banquet")
    self.banquet_btn:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.BANQUET
    self:AddClick(self.banquet_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("PartyUI")
    end)

    self.recreation_btn = game_scene_panel:FindChild("Recreation")
    self.recreation_btn:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.RECREATION
    self:AddClick(self.recreation_btn, function ()
        if self.dy_lover_data:GetSalonActiveState() then
            SpecMgrs.ui_mgr:ShowUI("SalonUI")
        else
            SpecMgrs.ui_mgr:ShowMsgBox(string.format(UIConst.Text.SALON_ACTIVE_LIMIT, self.salon_active_grade_data.name))
        end
    end)

    self.trainning_centre_btn = game_scene_panel:FindChild("TrainningCentre")
    self.trainning_centre_btn:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.TRAINNING_CENTRE
    self:AddClick(self.trainning_centre_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("TrainingCentreUI")
    end)

    self:AddClick(game_scene_panel:FindChild("Back"), function ()
        SpecMgrs.stage_mgr:GotoStage("MainStage")
    end)
end

function EntertainmentUI:InitUI()
    self:RegisterEvent(ComMgrs.dy_data_mgr, "UpdateCurrencyEvent", function (_, currency)
        UIFuncs.UpdateCurrencyItemNum(self._item_to_text_list, currency)
    end)
end

return EntertainmentUI