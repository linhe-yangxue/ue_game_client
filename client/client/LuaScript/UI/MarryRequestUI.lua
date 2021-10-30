local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local LuxuryHouseUI = require("UI.LuxuryHouseUI")
local ScrollListViewCmp = require("UI.UICmp.ScrollListViewCmp")
local MarryRequestUI = class("UI.MarryRequestUI",UIBase)

--  提亲请求ui
function MarryRequestUI:DoInit()
    MarryRequestUI.super.DoInit(self)
    self.prefab_path = "UI/Common/MarryRequestUI"

    self.dy_child_data = ComMgrs.dy_data_mgr.child_center_data

    self.scroll_show_count = 8
end

function MarryRequestUI:OnGoLoadedOk(res_go)
    MarryRequestUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function MarryRequestUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    MarryRequestUI.super.Show(self)
end

function MarryRequestUI:InitRes()
    self:InitTopBar()
    self:AddClick(self.main_panel:FindChild("DownFrame/RefuseButton"), function()
        local resp_cb = function(resp)
            if resp.errcode ~= 1 then
                self:Hide()
            end
        end
        SpecMgrs.msg_mgr:SendRefuseAllMarry(nil, resp_cb)
    end)
    self.refuse_button_text = self.main_panel:FindChild("DownFrame/RefuseButton/PowerButtonText"):GetComponent("Text")

    self.marry_equest_list_view_comp = ScrollListViewCmp.New()
    self.marry_equest_list_view_comp:DoInit(self, self.main_panel:FindChild("List/Viewport"))
end

function MarryRequestUI:InitUI()
    self.obj_tb = {}
    self:UpdateData()
    self:UpdateUIInfo()
    self:SetTextVal()

    self.dy_child_data:RegisterUpdateMarryRequestEvent("MarryRequestUI", function()
        self:DelObjDict(self.obj_tb)
        self.obj_tb = {}
        self:UpdateData()
        self:UpdateUIInfo()
    end, self)
end

function MarryRequestUI:UpdateData()
    self.child_object_list = self.dy_child_data:GetAssignRequestMarryList()
end

function MarryRequestUI:UpdateUIInfo()
    self.marry_equest_list_view_comp:ListenerViewChange(function(go, index)
        index = index + 1
        local marry_info = self.child_object_list[index]
        LuxuryHouseUI.SetMarryTargetPanel(go, marry_info)
        local grade_text = SpecMgrs.data_mgr:GetChildQualityData(marry_info.grade).quality_text[marry_info.sex]
        go:FindChild("ChildGrade/ChildGradeText"):GetComponent("Text").text = grade_text
        go:FindChild("ChooseButton/ChooseButtonText"):GetComponent("Text").text = UIConst.Text.ACCEPT_MARRY_TEXT
        go:FindChild("RefuseButton/RefuseButtonText"):GetComponent("Text").text = UIConst.Text.REFUCE_MARRY_TEXT
        self:AddClick(go:FindChild("RefuseButton"), function()
            local resp_cb = function(resp)

            end
            SpecMgrs.msg_mgr:SendRefuseRequestMarry({uuid = marry_info.uuid, child_id = marry_info.child_id}, resp_cb)
        end)

        self:AddClick(go:FindChild("ChooseButton"), function()
            SpecMgrs.ui_mgr:ShowUI("SelectMarryTargetUI", marry_info, CSConst.ChildSendRequest.Assign)
        end)
        table.insert(self.obj_tb, go)
    end)
    local show_count = #self.child_object_list > self.scroll_show_count and self.scroll_show_count or #self.child_object_list
    self.marry_equest_list_view_comp:Start(#self.child_object_list, show_count)
end

function MarryRequestUI:SetTextVal()
    self.refuse_button_text.text = UIConst.Text.REFUCE_ALL_MARRY_TEXT
end

function MarryRequestUI:Hide()
    self:DestroyRes()
    self.dy_child_data:UnregisterUpdateMarryRequestEvent("MarryRequestUI")
    MarryRequestUI.super.Hide(self)
end

return MarryRequestUI
