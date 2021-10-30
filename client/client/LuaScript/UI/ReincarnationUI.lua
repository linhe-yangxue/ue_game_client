local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local ReincarnationUI = class("UI.ReincarnationUI",UIBase)

--  转世界面
function ReincarnationUI:DoInit()
    ReincarnationUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ReincarnationUI"

    self.lover_data = ComMgrs.dy_data_mgr.lover_data
    self.data_mgr = SpecMgrs.data_mgr
end

function ReincarnationUI:OnGoLoadedOk(res_go)
    ReincarnationUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function ReincarnationUI:Show(lover_id)
    self.lover_id = lover_id
    if self.is_res_ok then
        self:InitUI()
    end
    ReincarnationUI.super.Show(self)
end

function ReincarnationUI:InitRes()
    self.describe_text = self.main_panel:FindChild("DescribeText"):GetComponent("Text")
    self.lover_point = self.main_panel:FindChild("LoverPoint")
    self.lover_name_text = self.main_panel:FindChild("NameText"):GetComponent("Text")
    self.meet_record_btn = self.main_panel:FindChild("MeetRecordBtn")

    self.now_life_btn = self.main_panel:FindChild("NowLifeButton")
    self.pre_life_btn = self.main_panel:FindChild("PreLifeButton")

    self.lover_level = self.main_panel:FindChild("LoverLevel"):GetComponent("Image")
    self.reincarnation_button_text = self.main_panel:FindChild("ReincarnationButton/ReincarnationButtonText"):GetComponent("Text")
    self.meet_record_btn_text = self.main_panel:FindChild("MeetRecordBtn/MeetRecordBtnText"):GetComponent("Text")
    self:AddClick(self.main_panel:FindChild("CloseButton"), function()
        self:Hide()
    end)
    self:AddClick(self.meet_record_btn, function()
        local param_tb = {
            lover_name = self.cur_select_lover_data.name,
            mes = "",
        }
        SpecMgrs.ui_mgr:ShowUI("MeetMsgUI", param_tb)
    end)
    self:AddClick(self.main_panel:FindChild("ReincarnationButton"), function()
        --  转世
        local resp_cb = function(resp)
            if resp.errcode == 1 then
                print("ReincarnationError")
            else
                self.lover_data:ChangeLoverSexData(self.lover_id, resp.new_lover)
                SpecMgrs.ui_mgr:ShowUI("EntertainmentUI")
            end
        end
        SpecMgrs.msg_mgr:SendChangeLoverSex({lover_id = self.lover_id}, resp_cb)
    end)
    self:AddClick(self.now_life_btn, function()
        self:ClickNowlifeButton()
        self:UpdateLoverUIInfo()
    end)
    self:AddClick(self.pre_life_btn, function()
        self:ClickPrelifeButton()
        self:UpdateLoverUIInfo()
    end)
end

function ReincarnationUI:InitUI()
    self:UpdateData()
    self:SetTextVal()
    self:UpdateLoverInfo()
    if self.lover_id == self.nowlife_lover_data.id then
        self:ClickNowlifeButton()
    else
        self:ClickPrelifeButton()
    end
    self:UpdateLoverUIInfo()
end

function ReincarnationUI:UpdateData()
    self.prelife_lover_data = {}
    self.nowlife_lover_data = {}

    self.cur_select_lover_data = {}
    self.cur_unit = nil
end

function ReincarnationUI:SetTextVal()
    self.reincarnation_button_text.text = UIConst.Text.REINCARNATION_TEXT
    self.meet_record_btn_text.text = UIConst.Text.MEET_RECORD_TEXT
end

function ReincarnationUI:UpdateLoverInfo()
    self.lover_info = self.lover_data[self.lover_id]
    self.prelife_lover_data = self.lover_data:GetPrelifeData(self.lover_id)
    self.nowlife_lover_data = self.lover_data:GetNowlifeData(self.lover_id)
end

function ReincarnationUI:ClickNowlifeButton()
    self.cur_select_lover_data = self.nowlife_lover_data
    self.now_life_btn:FindChild("SelectImage"):SetActive(true)
    self.pre_life_btn:FindChild("SelectImage"):SetActive(false)
    self:UpdateUnit()
end

function ReincarnationUI:ClickPrelifeButton()
    self.cur_select_lover_data = self.prelife_lover_data
    self.now_life_btn:FindChild("SelectImage"):SetActive(false)
    self.pre_life_btn:FindChild("SelectImage"):SetActive(true)
    self:UpdateUnit()
end

function ReincarnationUI:UpdateUnit()
    if self.cur_unit then
        self:RemoveUnit(self.cur_unit)
    end
    self.cur_unit = self:AddUnit(self.cur_select_lover_data.unit_id, self.lover_point, nil, nil, nil, true)
end

function ReincarnationUI:UpdateLoverUIInfo()
    self.lover_name_text.text = self.cur_select_lover_data.name
end

function ReincarnationUI:Hide()
    self.cur_unit = nil
    self:DestroyRes()
    ReincarnationUI.super.Hide(self)
end

return ReincarnationUI
