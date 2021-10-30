local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local CSConst = require("CSCommon.CSConst")
local LuxuryHouseUI = require("UI.LuxuryHouseUI")
local UIFuncs = require("UI.UIFuncs")
local ScrollListViewCmp = require("UI.UICmp.ScrollListViewCmp")
local SelectMarryTargetUI = class("UI.SelectMarryTargetUI",UIBase)

--  选择被提亲的皇子
function SelectMarryTargetUI:DoInit()
    SelectMarryTargetUI.super.DoInit(self)
    self.prefab_path = "UI/Common/SelectMarryTargetUI"

    self.dy_child_data = ComMgrs.dy_data_mgr.child_center_data

    self.scroll_show_count = 8
end

function SelectMarryTargetUI:OnGoLoadedOk(res_go)
    SelectMarryTargetUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function SelectMarryTargetUI:Show(target_child, marry_type)
    self.target_child = target_child
    self.marry_type = marry_type
    if self.is_res_ok then
        self:InitUI()
    end
    SelectMarryTargetUI.super.Show(self)
end

function SelectMarryTargetUI:InitRes()
    self.title = self.main_panel:FindChild("Title"):GetComponent("Text")
    self.diamond_toggle = self.main_panel:FindChild("ToggleGroup/DiamondToggle"):GetComponent("Toggle")
    self.marriage_stone_toggle = self.main_panel:FindChild("ToggleGroup/MarriageStoneToggle"):GetComponent("Toggle")
    self.confirm_btn = self.main_panel:FindChild("ConfirmBtn")
    self:AddClick(self.confirm_btn, function()
        self:SendAcceptMarry()
    end)
    self.confirm_btn_text = self.main_panel:FindChild("ConfirmBtn/ConfirmBtnText"):GetComponent("Text")
    self.cancel_button = self.main_panel:FindChild("CancelButton")
    self:AddClick(self.cancel_button, function()
        self:Hide()
    end)
    self.cancel_button_text = self.main_panel:FindChild("CancelButton/CancelButtonText"):GetComponent("Text")
    self.diamond_text = self.main_panel:FindChild("Diamond/DiamondText"):GetComponent("Text")
    self.diamond_num_text = self.main_panel:FindChild("Diamond/DiamondNumText"):GetComponent("Text")
    self.marriage_stone_text = self.main_panel:FindChild("MarriageStone/MarriageStoneText"):GetComponent("Text")
    self.marriage_stone_num_text = self.main_panel:FindChild("MarriageStone/MarriageStoneNumText"):GetComponent("Text")

    self.tip_text = self.main_panel:FindChild("TipText")
    self:AddClick(self.main_panel:FindChild("CloseButton"), function()
        self:Hide()
    end)

    self.marry_target_list_view_comp = ScrollListViewCmp.New()
    self.marry_target_list_view_comp:DoInit(self, self.main_panel:FindChild("List"))
end

function SelectMarryTargetUI:SendAcceptMarry()
    if self.cur_select_id == -1 then self:Hide() return end
    local param_tb = {
        apply_type = self.marry_type,
        child_id = self.cur_select_id,
        object_uuid = self.target_child.uuid,
        object_child_id = self.target_child.child_id,
        item_id = SpecMgrs.data_mgr:GetParamData("request_marry_diamond_item").item_id
    }
    local stone_id = SpecMgrs.data_mgr:GetMarryExpendData(self.target_child.grade).expend_item
    local diamond_id = SpecMgrs.data_mgr:GetMarryExpendData(self.target_child.grade).diamond
    if self.diamond_toggle.isOn then
        param_tb.item_id = diamond_id
    else
        param_tb.item_id = stone_id
    end
    --print(param_tb)
    local resp_cb = function(resp)
        print(resp.errcode)
        self:Hide()
    end
    SpecMgrs.msg_mgr:SendAcceptMarry(param_tb, resp_cb)
end

function SelectMarryTargetUI:InitUI()
    self:UpdateData()
    self:UpdateUIInfo()
    self:SetTextVal()
end

function SelectMarryTargetUI:SetTextVal()
    self.diamond_text.text = SpecMgrs.data_mgr:GetItemData(CSConst.Virtual.Diamond).name
    local stone_id = SpecMgrs.data_mgr:GetMarryExpendData(self.target_child.grade).expend_item
    self.marriage_stone_text.text = SpecMgrs.data_mgr:GetItemData(stone_id).name

    self.cancel_button_text.text = UIConst.Text.CANCEL
    self.confirm_btn_text.text = UIConst.Text.ACCEPT_MARRY_TEXT
    if self.target_child.sex == CSConst.Sex.Man then
        self.title.text = UIConst.Text.SELECT_DAUGHTER_TEXT
    else
        self.title.text = UIConst.Text.SELECT_SON_TEXT
    end
end

function SelectMarryTargetUI:UpdateData()
    self.cur_select_id = -1
    self.cur_select_obj = {}
    self.select_child_list = self.dy_child_data:GetMarryTargetChild(self.target_child)

    local diamond_expend
    local stone_expend
    if self.target_child.server_type == CSConst.ChildSendRequest.Cross then
        diamond_expend = SpecMgrs.data_mgr:GetMarryExpendData(self.target_child.grade).cross_diamond_num
        stone_expend = SpecMgrs.data_mgr:GetMarryExpendData(self.target_child.grade).cross_expend_item_num
    else
        diamond_expend = SpecMgrs.data_mgr:GetMarryExpendData(self.target_child.grade).diamond_num
        stone_expend = SpecMgrs.data_mgr:GetMarryExpendData(self.target_child.grade).expend_item_num
    end

    local stone_id = SpecMgrs.data_mgr:GetMarryExpendData(self.target_child.grade).expend_item
    local cur_diamond_num = ComMgrs.dy_data_mgr:ExGetCurrencyCount(CSConst.Virtual.Diamond)
    local cur_stone_num = ComMgrs.dy_data_mgr.bag_data:GetBagItemCount(stone_id)

    self.diamond_num_text.text = string.format(UIConst.Text.MARRY_EXPAND_FORMAT, UIFuncs.AddCountUnit(cur_diamond_num), UIFuncs.AddCountUnit(diamond_expend))
    self.marriage_stone_num_text.text =  string.format(UIConst.Text.MARRY_EXPAND_FORMAT, cur_stone_num, stone_expend)
end

function SelectMarryTargetUI:UpdateUIInfo()
    if (not next(self.select_child_list)) then
        self.tip_text:SetActive(true)
        self.tip_text:GetComponent("Text").text = UIConst.Text.NO_RECIURT_MARRY_TIP
        return
    end
    self.tip_text:SetActive(false)

    self:DelObjDict(self.cur_select_obj)
    self.cur_select_obj = {}
    self.child_selector = UIFuncs.CreateSelector(self, self.cur_select_obj, function(i)
        self.cur_select_id = self.select_child_list[i].child_id
    end)
    self.marry_target_list_view_comp:ListenerViewChange(function(go, index)
        index = index + 1
        local child_info = self.select_child_list[index]
        LuxuryHouseUI.SetChildAttrPanel(go, child_info.child_id)

        if not self.cur_select_obj[index] then
            table.insert(self.cur_select_obj, go)
            self.child_selector:AddObj(go, index)
        end
    end)
    local show_count = #self.select_child_list > self.scroll_show_count and self.scroll_show_count or #self.select_child_list
    self.marry_target_list_view_comp:Start(#self.select_child_list, show_count)
end

function SelectMarryTargetUI:Hide()
    self:DestroyRes()
    SelectMarryTargetUI.super.Hide(self)
end

return SelectMarryTargetUI
