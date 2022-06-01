local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local CSConst = require("CSCommon.CSConst")
local UIFuncs = require("UI.UIFuncs")
local ScrollListViewCmp = require("UI.UICmp.ScrollListViewCmp")
local LuxuryHouseUI = class("UI.LuxuryHouseUI",UIBase)

--  豪宅ui
function LuxuryHouseUI:DoInit()
    LuxuryHouseUI.super.DoInit(self)
    self.prefab_path = "UI/Common/LuxuryHouseUI"

    self.dy_lover_data = ComMgrs.dy_data_mgr.lover_data
    self.data_mgr = SpecMgrs.data_mgr
    self.dy_child_data = ComMgrs.dy_data_mgr.child_center_data
    self.scroll_show_count = 8
end

function LuxuryHouseUI:OnGoLoadedOk(res_go)
    LuxuryHouseUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function LuxuryHouseUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    LuxuryHouseUI.super.Show(self)
end

function LuxuryHouseUI:InitRes()
    self:InitTopBar()
    --  中间ui
    local middle_frame = self.main_panel:FindChild("MiddleFrame")

    self.child_attr_add_text = middle_frame:FindChild("ChildAttrAddText"):GetComponent("Text")
    self.marry_attr_text = middle_frame:FindChild("MarryAttrText"):GetComponent("Text")
    self.child_grade_text = middle_frame:FindChild("ChildGrade/ChildGradeText"):GetComponent("Text")

    self.child_grade =  middle_frame:FindChild("ChildGrade")
    self.attr_panel = middle_frame:FindChild("ChildAttrPanel")
    self.child_name_text = self.attr_panel:FindChild("ChildNameText"):GetComponent("Text")

    self.marry_btn = self.attr_panel:FindChild("MarryButton")

    self.count_down_panel = middle_frame:FindChild("CountDownPanel")
    self.count_down_panel_tip_text = self.count_down_panel:FindChild("TipText"):GetComponent("Text")
    self.count_down_panel_time_text = self.count_down_panel:FindChild("CountDownText"):GetComponent("Text")

    self.child_point = self.main_panel:FindChild("MiddleFrame/ChildPoint")
    self.mother_name_text = self.main_panel:FindChild("MiddleFrame/ChildAttrPanel/AttrGrid/MotherNameText"):GetComponent("Text")
    self.intimacy_text = self.main_panel:FindChild("MiddleFrame/ChildAttrPanel/AttrGrid/IntimacyText"):GetComponent("Text")
    self.total_talent_text = self.main_panel:FindChild("MiddleFrame/ChildAttrPanel/AttrGrid/TotalTalentText"):GetComponent("Text")
    self.total_attr_text = self.main_panel:FindChild("MiddleFrame/ChildAttrPanel/AttrGrid/TotalAttrText"):GetComponent("Text")
    self.mother_name_val_text = self.main_panel:FindChild("MiddleFrame/ChildAttrPanel/AttrValGrid/MotherNameValText"):GetComponent("Text")
    self.intimacy_val_text = self.main_panel:FindChild("MiddleFrame/ChildAttrPanel/AttrValGrid/IntimacyValText"):GetComponent("Text")
    self.total_talent_val_text = self.main_panel:FindChild("MiddleFrame/ChildAttrPanel/AttrValGrid/TotalTalentValText"):GetComponent("Text")
    self.total_attr_val_text = self.main_panel:FindChild("MiddleFrame/ChildAttrPanel/AttrValGrid/TotalAttrValText"):GetComponent("Text")

    self.left_spouse_point = self.main_panel:FindChild("MiddleFrame/LeftSpousePoint")
    self.right_spouse_point = self.main_panel:FindChild("MiddleFrame/RightSpousePoint")
    self:AddClick(self.marry_btn, function()
        if not self.cur_select_child then return end
        if self.dy_child_data:IsRequestMarry(self.cur_select_child) then
            local resp_cb = function(resp)

            end
            SpecMgrs.msg_mgr:SendCancalProposeMarry({child_id = self.cur_select_child.child_id}, resp_cb)
        else
            SpecMgrs.ui_mgr:ShowUI("UniteMarriageUI", self.cur_select_child.child_id)
        end
    end)

    -- self:AddClick(self.attr_panel:FindChild("ChildDetailButton"), function()
    --     if not self.cur_select_child then return end
    --     SpecMgrs.ui_mgr:ShowUI("GrowUpUI", self.cur_select_child.child_id)
    -- end)

    --  下方ui
    local down_frame = self.main_panel:FindChild("DownFrame")

    self.unmarried_list = down_frame:FindChild("UnmarriedList")
    self.married_list = down_frame:FindChild("MarriedList")

    self.unmarried_list_content = self.unmarried_list:FindChild("Viewport/Content")
    self.married_list_content = self.married_list:FindChild("Viewport/Content")

    self.married_list_button = down_frame:FindChild("MarriedButton")
    self.unmarried_list_button = down_frame:FindChild("UnmarriedButton")

    self.no_child_tip_text = down_frame:FindChild("UnmarriedList/NoChildTipText")
    self.no_marry_tip_text = down_frame:FindChild("MarriedList/NoMarryTipText")

    self:AddClick(self.unmarried_list_button, function()
        self:ClickMarriedButton(false)
    end)
    self:AddClick(self.married_list_button, function()
        self:ClickMarriedButton(true)
    end)

    self:AddClick(down_frame:FindChild("MarryRequestButton"), function()
        SpecMgrs.ui_mgr:ShowUI("MarryRequestUI")
    end)
    self.marry_request_btn_text = down_frame:FindChild("MarryRequestButton/MarryRequestButtonText"):GetComponent("Text")

    --  Temp
    self.child_mes = self.main_panel:FindChild("Temp/ChildMes")
    self.spouse_mes = self.main_panel:FindChild("Temp/SpouseMes")

    self.child_mes:SetActive(false)
    self.spouse_mes:SetActive(false)
end

function LuxuryHouseUI:InitUI()
    self.dy_child_data:RegisterUpdateAdultChildInfo("LuxuryHouseUI", function()
        self.marry_list_view_comp:DoDestroy()
        self.unmarry_list_view_comp:DoDestroy()
        self:DestroyAllUnit()
        self:InitUI()
    end, self)
    self.un_marry_unit_dict = {}
    self.marry_unit_dict = {}
    self.is_marry_panel = nil
    self:UpdateData()
    self:UpdateUIInfo()
    self:SetTextVal()
    self:ClickMarriedButton(false)
    LuxuryHouseUI.ShowMarryTip()
end

function LuxuryHouseUI:SetTextVal()
    self.mother_name_text.text = UIConst.Text.MOTHER_NAME_TEXT
    self.intimacy_text.text = UIConst.Text.INTIMACY_VAL_TEXT
    self.total_talent_text.text = UIConst.Text.CHILD_ALL_TALENT_VAL_TEXT
    self.total_attr_text.text = UIConst.Text.CHILD_ALL_ATTR_VAL_TEXT
    self.marry_request_btn_text.text = UIConst.Text.PROPOSE_MARRY_REQUEST_TEXT
end

function LuxuryHouseUI:UpdateData()
    self.spouse_obj_list = {}
    self.unmarry_obj_list = {}
    self.unmarry_child_list = self.dy_child_data:GetAdultChildList(false)
    self.marry_child_list = self.dy_child_data:GetAdultChildList(true)
end

function LuxuryHouseUI:UpdateUIInfo(reselect_index)
    if self.unmarry_list_view_comp then
        self.unmarry_list_view_comp:DoDestroy()
    end
    if self.marry_list_view_comp then
        self.marry_list_view_comp:DoDestroy()
    end
    self.unmarry_list_view_comp = ScrollListViewCmp.New()
    self.unmarry_list_view_comp:DoInit(self, self.unmarried_list:FindChild("Viewport"))

    self.marry_list_view_comp = ScrollListViewCmp.New()
    self.marry_list_view_comp:DoInit(self, self.married_list:FindChild("Viewport"))

    local child_attr = string.format(UIConst.Text.CHILD_ALL_ATTR_ADD, self.dy_child_data:GetAllChildAttrAdd())
    self.child_attr_add_text.text = child_attr
    local marry_attr = string.format(UIConst.Text.MATTY_ALL_ATTR_ADD, self.dy_child_data:GetAllChildMarryAttrAdd())
    self.marry_attr_text.text = marry_attr
    self.no_child_tip_text:GetComponent("Text").text = UIConst.Text.NO_CHILD_TIP
    self.no_marry_tip_text:GetComponent("Text").text = UIConst.Text.NO_MARRY_TIP
    self.no_child_tip_text:SetActive(false)
    self.no_marry_tip_text:SetActive(false)

    self:CreateMarryChildMes()
    self:CreateUnMarryChildMes(reselect_index)
end

--  已婚
function LuxuryHouseUI:CreateMarryChildMes()
    self:DelObjDict(self.spouse_obj_list)
    self.spouse_obj_list = {}
    self.spouse_selector = UIFuncs.CreateSelector(self, self.spouse_obj_list, function(i)
        if not self.is_marry_panel then return end
        if self.left_spouse_unit then
            self:RemoveUnit(self.left_spouse_unit)
            self:RemoveUnit(self.right_spouse_unit)
        end
        local child_info = self.marry_child_list[i]
        local _, unit_list = self.dy_child_data:GetChildUnitId(child_info)
        self.left_spouse_unit = self:AddUnit(unit_list[1], self.left_spouse_point)
        self.right_spouse_unit = self:AddUnit(unit_list[2], self.right_spouse_point)
    end)
    self.marry_list_view_comp:ListenerViewChange(function(go, index, is_add)
        if not is_add then return end
        index = index + 1
        local child_info = self.marry_child_list[index]
        self:SetMarryArrtPanel(go, child_info.child_id)

        local need_create = true
        local _, unit_list = self.dy_child_data:GetChildUnitId(child_info)
        if self.marry_unit_dict[go] then
            if unit_list[1] == self.marry_unit_dict[go].unit_left.unit_id and unit_list[1] == self.marry_unit_dict[go].unit_right.unit_id then
                need_create = false
            else
                self:RemoveUnit(self.marry_unit_dict[go].unit_left)
                self:RemoveUnit(self.marry_unit_dict[go].unit_right)
            end
        end
        if need_create then
            local unit_left = self:AddHeadUnit(unit_list[1], go:FindChild("LeftUnitPoint"))
            local unit_right = self:AddHeadUnit(unit_list[2], go:FindChild("RightUnitPoint"))
            unit_left:StopAllAnimationToCurPos()
            unit_right:StopAllAnimationToCurPos()
            self.marry_unit_dict[go] = {unit_left = unit_left, unit_right = unit_right}
        end

        if not self.spouse_obj_list[index] then
            table.insert(self.spouse_obj_list, go)
            self.spouse_selector:AddObj(go, index)
        end
        if not self.spouse_selector:GetCurSelectIndex() then
            self.spouse_selector:SelectObj(1, true)
        end
    end)
    --local show_count = #self.marry_child_list > self.scroll_show_count and self.scroll_show_count or #self.marry_child_list
    local show_count = #self.marry_child_list
    self.marry_list_view_comp:Start(#self.marry_child_list, show_count)
end

--  未婚
function LuxuryHouseUI:CreateUnMarryChildMes(reselect_index)
    self:DelObjDict(self.unmarry_obj_list)
    self.unmarry_obj_list = {}
    self.unmarry_selector = UIFuncs.CreateSelector(self, self.unmarry_obj_list, function(i)
        self:SelectUnMarryChild(i)
    end)
    self.unmarry_list_view_comp:ListenerViewChange(function(go, index, is_add)
        if not is_add then return end
        index = index + 1
        local child_info = self.unmarry_child_list[index]
        LuxuryHouseUI.SetChildAttrPanel(go, child_info.child_id)
        local is_request_marry = self.dy_child_data:IsRequestMarry(child_info)
        go:FindChild("RequestMarryImage"):SetActive(is_request_marry)

        local need_create = true
        local unit_id = self.dy_child_data:GetChildUnitId(child_info)
        if self.un_marry_unit_dict[go] then
            if unit_id == self.un_marry_unit_dict[go].unit_id then
                need_create = false
            else
                self:RemoveUnit(self.un_marry_unit_dict[go])
            end
        end
        if need_create then
            local unit = self:AddHeadUnit(unit_id, go:FindChild("ChildPoint"), nil, nil, nil, true)
            unit:StopAllAnimationToCurPos()
            self.un_marry_unit_dict[go] = unit
        end
        if not self.unmarry_obj_list[index] then
            table.insert(self.unmarry_obj_list, go)
            self.unmarry_selector:AddObj(go, index)
        end
        if not self.unmarry_selector:GetCurSelectIndex() then
            if reselect_index then
                if index == reselect_index then
                    self.unmarry_selector:SelectObj(index, true)
                end
            else
                self.unmarry_selector:SelectObj(1, true)
            end
        end
    end)

    --local show_count = #self.unmarry_child_list > self.scroll_show_count and self.scroll_show_count or #self.unmarry_child_list
    local show_count = #self.unmarry_child_list
    self.unmarry_list_view_comp:Start(#self.unmarry_child_list, show_count)
end

function LuxuryHouseUI:SelectUnMarryChild(index)
    self.cur_select_child = self.unmarry_child_list[index]
    self:UpdateMiddleFrame()
end

function LuxuryHouseUI:UpdateMiddleFrame()
    if self.cur_select_child then
        self.child_name_text.text = self.cur_select_child.name

        local child_id = self.cur_select_child.child_id
        local child_info = ComMgrs.dy_data_mgr.child_center_data:GetAdultChildDataById(child_id)
        local lover_data = SpecMgrs.data_mgr:GetLoverData(child_info.mother_id)
        local lover_info = ComMgrs.dy_data_mgr.lover_data:GetLoverInfo(child_info.mother_id)
        local child_data = SpecMgrs.data_mgr:GetChildQualityData(child_info.grade)

        self.mother_name_val_text.text = lover_data.name
        self.intimacy_val_text.text = lover_info.level
        self.total_talent_val_text.text = ComMgrs.dy_data_mgr.child_center_data:GetChildTotalTalent(child_id)
        self.total_attr_val_text.text = ComMgrs.dy_data_mgr.child_center_data:GetChildTotalAttr(child_id)
        --LuxuryHouseUI.SetChildGrade(self.child_grade_text, child_id)
        if self.dy_child_data:IsRequestMarry(self.cur_select_child) then
            self.marry_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CANCEL_MARRY
            local text = UIConst.Text.SERVER_REQUEST_NOW_TIP[self.cur_select_child.apply_type]
            if self.cur_select_child.apply_type == CSConst.ChildSendRequest.Assign then
                self.count_down_panel_tip_text.text = string.format(text, self.cur_select_child.apply_role_name)
            else
                self.count_down_panel_tip_text.text = text
            end
            self.count_down_panel:SetActive(true)
        else
            self.count_down_panel:SetActive(false)
            self.marry_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ACCEPT_MARRY_TEXT
        end

        local grade_data = SpecMgrs.data_mgr:GetChildQualityData(self.cur_select_child.grade)
        -- 爵位
        local res_path = self.cur_select_child.sex == CSConst.Sex.Man and grade_data.man_res_path or grade_data.woman_res_path
        local res_name = self.cur_select_child.sex == CSConst.Sex.Man and grade_data.man_res_name or grade_data.woman_res_name

        if self.cur_show_unit then
            self:RemoveUnit(self.cur_show_unit)
        end
        local unit_id = self.dy_child_data:GetChildUnitId(self.cur_select_child)
        self.cur_show_unit = self:AddUnit(unit_id, self.child_point)
    end
end

function LuxuryHouseUI:UpdateCountDown()
    if not self.cur_select_child then return end
    if self.dy_child_data:IsRequestMarry(self.cur_select_child) then
        local count_down_time = UIFuncs.GetCoolDownTimeDelta(self.cur_select_child.apply_time, SpecMgrs.data_mgr:GetParamData("child_request_timer").f_value)
        local str = UIFuncs.GetCountDownDayStr(count_down_time)
        self.count_down_panel_time_text.text = str
    end
end

function LuxuryHouseUI:ClickMarriedButton(is_marry)
    if self.is_marry_panel == is_marry then return end
    self.is_marry_panel = is_marry
    self.attr_panel:SetActive(not is_marry)
    --self.child_grade:SetActive(not is_marry)
    self.count_down_panel:SetActive(not is_marry)
    self.married_list_button:FindChild("SelectImage"):SetActive(is_marry)
    self.unmarried_list_button:FindChild("SelectImage"):SetActive(not is_marry)
    self.unmarried_list:SetActive(not is_marry)
    self.married_list:SetActive(is_marry)
    if is_marry and #self.marry_child_list == 0 then
        self.no_marry_tip_text:SetActive(true)
    end
    if not is_marry and #self.unmarry_child_list == 0 then
        --self.child_grade:SetActive(false)
        self.attr_panel:SetActive(false)
        self.count_down_panel:SetActive(false)
        self.no_child_tip_text:SetActive(true)
    end
    if is_marry then
        if self.cur_show_unit then
            self:RemoveUnit(self.cur_show_unit)
        end
        self.spouse_selector:SelectObj(1, true)
        self.married_list_button:FindChild("Text"):GetComponent("Text").text = UIConst.Text.MARRY_SELECT_BTN_TEXT
        self.unmarried_list_button:FindChild("Text"):GetComponent("Text").text = UIConst.Text.UNMARRY_BTN_TEXT
    else
        if self.left_spouse_unit then
            self:RemoveUnit(self.left_spouse_unit)
            self:RemoveUnit(self.right_spouse_unit)
        end
        self.unmarry_selector:SelectObj(1, true)
        self.married_list_button:FindChild("Text"):GetComponent("Text").text = UIConst.Text.MARRY_BTN_TEXT
        self.unmarried_list_button:FindChild("Text"):GetComponent("Text").text = UIConst.Text.UNMARRY_SELECT_BTN_TEXT
    end
end

--  结婚对象属性panel
function LuxuryHouseUI:SetMarryArrtPanel(panel, child_id)
    local child_info = ComMgrs.dy_data_mgr.child_center_data:GetAdultChildDataById(child_id)
    local marry_info = child_info.marry
    if not marry_info then
        PrintError("ChildNotMarry")
        return
    end

    if child_info.apply_type == CSConst.ChildSendRequest.Cross then
        panel:FindChild("ServerText"):GetComponent("Text").text = UIConst.Text.ACROSS_SERVER
    else
        panel:FindChild("ServerText"):GetComponent("Text").text = ""
    end
    LuxuryHouseUI.SetChildAttrPanel(panel:FindChild("LeftChildMsg"), child_info.child_id)
    LuxuryHouseUI.SetMarryTargetPanel(panel:FindChild("RightChildMsg"), marry_info)
    LuxuryHouseUI.SetMarryTargetPanel(panel, marry_info)
end

function LuxuryHouseUI:Update(delta_time)
    if not self.is_res_ok or not self.is_visible then return end
    self:UpdateCountDown()
end

function LuxuryHouseUI:Hide()
    self.unmarry_selector:ResetSelectObj()
    self.spouse_selector:ResetSelectObj()
    self.marry_list_view_comp:DoDestroy()
    self.unmarry_list_view_comp:DoDestroy()
    self.dy_child_data:UnregisterUpdateAdultChildInfo("LuxuryHouseUI")
    LuxuryHouseUI.super.Hide(self)
end

--  通用 设置孩子属性面板
function LuxuryHouseUI.SetChildAttrPanel(panel, child_id)
    local child_info = ComMgrs.dy_data_mgr.child_center_data:GetAdultChildDataById(child_id)
    local lover_data = SpecMgrs.data_mgr:GetLoverData(child_info.mother_id)
    local lover_info = ComMgrs.dy_data_mgr.lover_data:GetLoverInfo(child_info.mother_id)
    local child_data = SpecMgrs.data_mgr:GetChildQualityData(child_info.grade)

    LuxuryHouseUI.SetTextFormatVal(panel, "MotherNameText", UIConst.Text.MOTHER_NAME, lover_data.name)
    LuxuryHouseUI.SetTextFormatVal(panel, "IntimacyText", UIConst.Text.INTIMACY_VAL, lover_info.level)

    local talent_val = ComMgrs.dy_data_mgr.child_center_data:GetChildTotalTalent(child_id)
    LuxuryHouseUI.SetTextFormatVal(panel, "TotalTalentText", UIConst.Text.CHILD_ALL_TALENT_VAL, talent_val)
    local arrt_val = ComMgrs.dy_data_mgr.child_center_data:GetChildTotalAttr(child_id)
    LuxuryHouseUI.SetTextFormatVal(panel, "TotalAttrText", UIConst.Text.CHILD_ALL_ATTR_VAL, arrt_val)
    local talent_level = child_data.text
    LuxuryHouseUI.SetTextFormatVal(panel, "TalentText", UIConst.Text.CHILD_TALENT_LEVEL, talent_level)

    LuxuryHouseUI.SetTextFormatVal(panel, "ChildGradeText", UIConst.Text.CHILD_GRADE, child_data.quality_text[child_info.sex])
    LuxuryHouseUI.SetTextFormatVal(panel, "ChildNameText", nil, child_info.name)
end

--  通用 设置结婚对象属性面板
function LuxuryHouseUI.SetMarryTargetPanel(panel, marry_target)
    local child_data = SpecMgrs.data_mgr:GetChildQualityData(marry_target.grade)
    LuxuryHouseUI.SetTextFormatVal(panel, "ChildNameText", nil, marry_target.child_name)
    LuxuryHouseUI.SetTextFormatVal(panel, "ChildGradeText", UIConst.Text.CHILD_GRADE, child_data.quality_text[marry_target.sex])
    LuxuryHouseUI.SetTextFormatVal(panel, "ChildFatherText", UIConst.Text.FATHER_NAME, marry_target.role_name)
    LuxuryHouseUI.SetTextFormatVal(panel, "TotalTalentText", UIConst.Text.CHILD_ALL_TALENT_VAL, table.sum(marry_target.aptitude_dict))
    LuxuryHouseUI.SetTextFormatVal(panel, "TotalAttrText",  UIConst.Text.CHILD_ALL_ATTR_VAL, table.sum(marry_target.attr_dict))
    local server_text
    if marry_target.server_type == CSConst.ChildSendRequest.Cross then
        server_text = UIConst.Text.ACROSS_SERVER
    else
        server_text = UIConst.Text.MY_SERVER
    end
    LuxuryHouseUI.SetTextFormatVal(panel, "ServerText", nil, server_text)
    LuxuryHouseUI.SetTextFormatVal(panel, "MarryTimeText", nil, os.date("%Y-%m-%d",marry_target.marry_time))
    LuxuryHouseUI.SetTextFormatVal(panel, "TargetFamilyText", UIConst.Text.TARGET_FAMILY, marry_target.role_name)
end

function LuxuryHouseUI.SetTextFormatVal(panel, text_name, const_text, text_val)
    local text_obj = panel:FindChild(text_name)
    if text_obj then
        local text_cmp = text_obj:GetComponent("Text")
        if const_text then
            text_cmp.text = string.format(const_text, text_val)
        else
            text_cmp.text = text_val
        end
    end
end

function LuxuryHouseUI.SetChildGrade(text_obj, child_id)
    -- local child_info = ComMgrs.dy_data_mgr.child_center_data:GetAdultChildDataById(child_id)
    -- text_obj.text = SpecMgrs.data_mgr:GetChildQualityData(child_info.grade).quality_text[child_info.sex]
end

function LuxuryHouseUI.ShowMarryTip()
    local child_data = ComMgrs.dy_data_mgr.child_center_data:GetUnConfirmMarryChild()
    if child_data then
        SpecMgrs.ui_mgr:HideUI("MarryTipUI")
        SpecMgrs.ui_mgr:ShowUI("MarryTipUI", child_data)
        return true
    end
    return false
end

return LuxuryHouseUI
