local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local ExperimentSelectAttrUI = class("UI.ExperimentSelectAttrUI",UIBase)

local select_attr_count = 3

--  试炼选择属性加成
function ExperimentSelectAttrUI:DoInit()
    ExperimentSelectAttrUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ExperimentSelectAttrUI"
end

function ExperimentSelectAttrUI:OnGoLoadedOk(res_go)
    ExperimentSelectAttrUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function ExperimentSelectAttrUI:Show(select_attr_id_list, can_use_star, add_attr_dict)
    self.select_attr_id_list = select_attr_id_list
    self.can_use_star = can_use_star
    if self.is_res_ok then
        self:InitUI()
    end
    ExperimentSelectAttrUI.super.Show(self)
end

function ExperimentSelectAttrUI:InitRes()
    self.title = self.main_panel:FindChild("Frame/Title"):GetComponent("Text")

    self.select_attr_tip_text = self.main_panel:FindChild("Frame/SelectAttrTipText"):GetComponent("Text")
    self.cur_can_spend_star_text = self.main_panel:FindChild("Frame/CurCanSpendStarText")
    self.attr_add_text = self.main_panel:FindChild("Frame/AttrAddText"):GetComponent("Text")
    self.continue_challenge_btn = self.main_panel:FindChild("Frame/ContinueChallengeBtn")
    self.attr_add_list = self.main_panel:FindChild("Frame/AttrList/Viewport/AttrAddList")

    self.attr_add_text_temp = self.main_panel:FindChild("Frame/AttrList/Viewport/AttrAddList/AttrAddFrameText")
    self:AddClick(self.continue_challenge_btn, function()
        if not self.cur_select_index then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.NO_SELECT_ATTR_TIP)
            return
        end
        local resp = function()
            self:Hide()
        end
        SpecMgrs.msg_mgr:SendTrainSelectAddAttr({index = self.cur_select_index}, resp)
    end)
    self.continue_challenge_btn_text = self.main_panel:FindChild("Frame/ContinueChallengeBtn/ContinueChallengeBtnText"):GetComponent("Text")
    self.no_attr_tip_text = self.main_panel:FindChild("Frame/NoAttrTipText")

    self.attr_mes_list = {}
    for i = 1, select_attr_count do
        local obj = self.main_panel:FindChild("Frame/AttrGrid/AttrMes" .. i)
        table.insert(self.attr_mes_list, obj)
        obj:FindChild("SelectImage"):SetActive(false)
    end
end

function ExperimentSelectAttrUI:InitUI()
    self:SetTextVal()
    self:UpdateData()
    self:UpdateUIInfo()
end

function ExperimentSelectAttrUI:UpdateData()
    self.cur_select_index = nil
    self.can_select_list = {}
    self.can_not_select_list = {}
    for i = 1, select_attr_count do
        local attr_data = SpecMgrs.data_mgr:GetTrainAttrData(self.select_attr_id_list[i])
        if self.can_use_star >= attr_data.cost_star then
            table.insert(self.can_select_list, self.attr_mes_list[i])
        else
            table.insert(self.can_not_select_list, self.attr_mes_list[i])
        end
    end
    self.attr_list = ComMgrs.dy_data_mgr.experiment_data:GetAttrList()
end

function ExperimentSelectAttrUI:UpdateUIInfo()
    for i, mes_obj in ipairs(self.attr_mes_list) do
        mes_obj:FindChild("SelectImage"):SetActive(false)
        local attr_data = SpecMgrs.data_mgr:GetTrainAttrData(self.select_attr_id_list[i])
        local icon_id = SpecMgrs.data_mgr:GetAttributeData(attr_data.attr_name).icon
        local attr_name = SpecMgrs.data_mgr:GetAttributeData(attr_data.attr_name).name
        mes_obj:FindChild("AttrAddText"):GetComponent("Text").text = string.format(UIConst.Text.ATTR_TWO_ROW_FORMAT, attr_name, attr_data.attr_value)
        self:SetTextPic(mes_obj:FindChild("ConsumeStarText"), string.format(UIConst.Text.SPEND_STAR_FORMAT, attr_data.cost_star))
    end
    UIFuncs.CreateSelector(self, self.can_select_list, function(i)
        self.cur_select_index = i
    end)
    for i, obj in ipairs(self.can_not_select_list) do
        self:AddClick(obj, function()
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.NO_ENOUGH_STAR_TIP)
        end)
    end
    if #self.attr_list > 0 then
        self.no_attr_tip_text:SetActive(false)
        for i, attr_data in ipairs(self.attr_list) do
            local item = self:GetUIObject(self.attr_add_text_temp, self.attr_add_list)
            local name = SpecMgrs.data_mgr:GetAttributeData(attr_data.id).name
            local str = string.format(UIConst.Text.EXPERIMENT_ATTR_FORMAT, name, attr_data.val)
            item:GetComponent("Text").text = str
        end
    else
        self.no_attr_tip_text:SetActive(true)
    end
end

function ExperimentSelectAttrUI:SetTextVal()
    self.title.text = UIConst.Text.SELECT_ATTR_TITLE
    self.select_attr_tip_text.text = UIConst.Text.SELECT_ATTR_TIP
    self.attr_add_text.text = UIConst.Text.ADD_ATTR_TIP
    self.continue_challenge_btn_text.text = UIConst.Text.CONTINUE_CHALLENGE_TEXT
    self.no_attr_tip_text:GetComponent("Text").text = UIConst.Text.NO_ATTR_ADD_TIP

    self:SetTextPic(self.cur_can_spend_star_text, string.format(UIConst.Text.CUR_CAN_SPEED_STAR_FORMAT, self.can_use_star))
end

function ExperimentSelectAttrUI:Hide()
    self:DelAllCreateUIObj()
    ExperimentSelectAttrUI.super.Hide(self)
end

return ExperimentSelectAttrUI
