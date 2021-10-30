local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local CSConst = require("CSCommon.CSConst")
local UIFuncs = require("UI.UIFuncs")
local ScrollListViewCmp = require("UI.UICmp.ScrollListViewCmp")
local ItemUtil = require("BaseUtilities.ItemUtil")
local UniteMarriageUI = class("UI.UniteMarriageUI",UIBase)

local page_count = 10
--  联姻ui
function UniteMarriageUI:DoInit()
    UniteMarriageUI.super.DoInit(self)
    self.prefab_path = "UI/Common/UniteMarriageUI"

    self.dy_child_data = ComMgrs.dy_data_mgr.child_center_data
    self.scroll_show_count = 10
end

function UniteMarriageUI:OnGoLoadedOk(res_go)
    UniteMarriageUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function UniteMarriageUI:Show(child_id)
    self.child_id = child_id
    if self.is_res_ok then
        self:InitUI()
    end
    UniteMarriageUI.super.Show(self)
end

function UniteMarriageUI:InitRes()
    self:InitTopBar()
    --  中间ui
    local middle_frame = self.main_panel:FindChild("MiddleFrame")
    self.child_grade_text = middle_frame:FindChild("ChildGrade/ChildGradeText"):GetComponent("Text")

    self.attr_panel = middle_frame:FindChild("ChildAttrPanel")
    self.marriage_stone = self.attr_panel:FindChild("MarriageStone")
    self.child_attr_add_text = middle_frame:FindChild("ChildAttrAddText"):GetComponent("Text")
    self.marry_attr_text = middle_frame:FindChild("MarryAttrText"):GetComponent("Text")
    self:AddClick(self.marriage_stone, function()
        self:SelectMarriageStone()
    end)

    self.diamond = self.attr_panel:FindChild("Diamond")
    self:AddClick(self.diamond, function()
        self:SelectDiamond()
    end)

    self.child_name_text = self.main_panel:FindChild("MiddleFrame/ChildAttrPanel/ChildNameText"):GetComponent("Text")
    self.total_talent_val_text = self.main_panel:FindChild("MiddleFrame/ChildAttrPanel/TotalTalentValText"):GetComponent("Text")
    self.total_attr_val_text = self.main_panel:FindChild("MiddleFrame/ChildAttrPanel/TotalAttrValText"):GetComponent("Text")
    self.total_talent_text = self.main_panel:FindChild("MiddleFrame/ChildAttrPanel/TotalTalentText"):GetComponent("Text")
    self.total_attr_text = self.main_panel:FindChild("MiddleFrame/ChildAttrPanel/TotalAttrText"):GetComponent("Text")
    self.diamond_text = self.main_panel:FindChild("MiddleFrame/ChildAttrPanel/Diamond/DiamondText"):GetComponent("Text")
    self.diamond_num_text = self.main_panel:FindChild("MiddleFrame/ChildAttrPanel/Diamond/DiamondNumText"):GetComponent("Text")
    self.marriage_stone_text = self.main_panel:FindChild("MiddleFrame/ChildAttrPanel/MarriageStone/MarriageStoneText"):GetComponent("Text")
    self.marriage_stone_num_text = self.main_panel:FindChild("MiddleFrame/ChildAttrPanel/MarriageStone/MarriageStoneNumText"):GetComponent("Text")

    self.propose_marry_button_text = self.main_panel:FindChild("MiddleFrame/ChildAttrPanel/ProposeMarryButton/ProposeMarryButtonText"):GetComponent("Text")
    self.unite_marry_button_text = self.main_panel:FindChild("MiddleFrame/ChildAttrPanel/UniteMarryButton/UniteMarryButtonText"):GetComponent("Text")

    self.middle_unite_marry_button = self.attr_panel:FindChild("UniteMarryButton")
    self.middle_propose_marry_button = self.attr_panel:FindChild("ProposeMarryButton")
    self:AddClick(self.middle_unite_marry_button, function()
        self:ClickUniteMarry()
    end)
    self:AddClick(self.middle_propose_marry_button, function()
        --  提亲
        self:ClickProposeMarry()
    end)

    --  下方ui
    local down_frame = self.main_panel:FindChild("DownFrame")
    self.recruit_marry_button = down_frame:FindChild("RecruitMarryButton") -- 招亲
    self.propose_marry_button = down_frame:FindChild("ProposeMarryButton") -- 提亲

    self.recruit_marry_frame = down_frame:FindChild("RecruitMarryFrame") -- 招亲面板
    self.propose_marry_frame = down_frame:FindChild("ProposeMarryFrame") -- 提亲面板

    self.no_recruit_marry_tip = self.recruit_marry_frame:FindChild("NoRecruitMarryTip")

    self.marry_target_grade_text = self.propose_marry_frame:FindChild("MarryTargetGrade/MarryTargetGradeText"):GetComponent("Text")
    self.propose_marry_panel = self.propose_marry_frame:FindChild("ProposeMarriagePanel")

    self.my_server_toggle = self.propose_marry_panel:FindChild("MyServerToggle"):GetComponent("Toggle")
    self.my_server_appoint_toggle = self.propose_marry_panel:FindChild("MyServerAppointToggle"):GetComponent("Toggle")
    self.other_server_toggle = self.propose_marry_panel:FindChild("OtherServerToggle"):GetComponent("Toggle")

    self.appoint_target_input = self.propose_marry_panel:FindChild("AppointTargetInputField"):GetComponent("InputField")

    self.down_frame_propose_marry_button_text = self.main_panel:FindChild("DownFrame/ProposeMarryButton/DownFrameProposeMarryButtonText"):GetComponent("Text")
    self.down_frame_recruit_marry_button_text = self.main_panel:FindChild("DownFrame/RecruitMarryButton/DownFrameRecruitMarryButtonText"):GetComponent("Text")

    self.change_show_server_button = self.main_panel:FindChild("DownFrame/RecruitMarryFrame/ChangeShowServerButton")
    self.change_show_server_button_text = self.main_panel:FindChild("DownFrame/RecruitMarryFrame/ChangeShowServerButton/ChangeShowServerButtonText"):GetComponent("Text")

    self:AddClick(self.recruit_marry_button, function()
        self:ClickMarryButton(true)
        self.recruit_marry_list_content:SetActive(not self.is_not_marry_target)
    end)

    self:AddClick(self.propose_marry_button, function()
        self:ClickMarryButton(false)
        self.recruit_marry_list_content:SetActive(false)
    end)

    self:AddClick(self.change_show_server_button, function()
        self.is_show_server = not self.is_show_server
        self:UpdateMarryTargetList()
    end)

    self:AddToggle(self.my_server_toggle.gameObject, function(is_on)
        self:UpdateExpandText()
    end)

    self:AddToggle(self.my_server_appoint_toggle.gameObject, function(is_on)
        self:UpdateExpandText()
    end)

    self:AddToggle(self.other_server_toggle.gameObject, function(is_on)
        self:UpdateExpandText()
    end)

    -- Temp
    self.recruit_marriage_target = self.main_panel:FindChild("Temp/RecruitMarriageTarget")

    self.recruit_marry_list_content = self.recruit_marry_frame:FindChild("MarriedList")
    self.world_recruit_marry_list_content = self.recruit_marry_frame:FindChild("WorldMarriedList")
    self.recruit_marriage_target:SetActive(false)
end

function UniteMarriageUI:InitUI()
    self.is_show_server = true
    self.cur_select_marry_target = nil
    self.recruit_obj_list = {}
    self:UpdateUIInfo()
    self:SetTextVal()
    self.marry_target_unit_dict = {}
    self:ClickMarryButton(true)
    self:SelectMarriageStone()
    self:ShowRecruitMarryMes(true)

    UIFuncs.RegisterUpdateItemNumFunc(self, "UniteMarriageUIDiamond", function(num)
        self.diamond_num_text.text = UIFuncs.GetPerStr(num, self.diamond_expend)
    end, CSConst.Virtual.Diamond)
    UIFuncs.RegisterUpdateItemNumFunc(self, "UniteMarriageUIStone", function(num)
        self.marriage_stone_num_text.text = UIFuncs.GetPerStr(num, self.stone_expend)
    end, self.stone_id)
end

function UniteMarriageUI:SetTextVal()
    self.total_talent_text.text = UIConst.Text.CHILD_ALL_TALENT_VAL_TEXT
    self.total_attr_text.text = UIConst.Text.CHILD_ALL_ATTR_VAL_TEXT

    self.propose_marry_button_text.text = UIConst.Text.PROPOSE_MARRY_BTN_TEXT
    self.unite_marry_button_text.text = UIConst.Text.RECRUIT_MARRY_BTN_TEXT

    self.diamond_text.text = SpecMgrs.data_mgr:GetItemData(CSConst.Virtual.Diamond).name
    local stone_id = SpecMgrs.data_mgr:GetMarryExpendData(self.child_info.grade).expend_item
    self.marriage_stone_text.text = SpecMgrs.data_mgr:GetItemData(stone_id).name
    self.change_show_server_button_text.text = UIConst.Text.MY_SERVER

    self:UpdateExpandText()
end

function UniteMarriageUI:UpdateUIInfo()
    --LuxuryHouseUI.SetChildGrade(self.child_grade_text, self.child_id)
    self.child_info = ComMgrs.dy_data_mgr.child_center_data:GetAdultChildDataById(self.child_id)
    self.child_name_text.text = self.child_info.name
    local child_attr = string.format(UIConst.Text.CHILD_ALL_ATTR_ADD, ComMgrs.dy_data_mgr.child_center_data:GetAllChildAttrAdd())
    self.child_attr_add_text.text = child_attr
    local marry_attr = string.format(UIConst.Text.MATTY_ALL_ATTR_ADD, ComMgrs.dy_data_mgr.child_center_data:GetAllChildMarryAttrAdd())
    self.marry_attr_text.text = marry_attr

    self.total_talent_val_text.text = ComMgrs.dy_data_mgr.child_center_data:GetChildTotalTalent(self.child_id)
    self.total_attr_val_text.text = ComMgrs.dy_data_mgr.child_center_data:GetChildTotalAttr(self.child_id)

    local sex = self.child_info.sex == CSConst.Sex.Man and CSConst.Sex.Woman or CSConst.Sex.Man
    local grade_text = SpecMgrs.data_mgr:GetChildQualityData(self.child_info.grade).quality_text[sex]

    self.marry_target_grade_text.text = grade_text

    self.no_recruit_marry_tip:GetComponent("Text").text = UIConst.Text.NO_RECIURT_MARRY_TIP
    self.no_recruit_marry_tip:SetActive(false)
    self.recruit_marry_list_content:SetActive(false)
    UIFuncs.AssignSpriteByItemID((SpecMgrs.data_mgr:GetMarryExpendData(self.child_info.grade).expend_item), self.marriage_stone:FindChild("Image"):GetComponent("Image"))
end

function UniteMarriageUI:UpdateExpandText()
    self.stone_id = SpecMgrs.data_mgr:GetMarryExpendData(self.child_info.grade).expend_item

    if self:IsSelectOtherServer() then
        self.diamond_expend = SpecMgrs.data_mgr:GetMarryExpendData(self.child_info.grade).cross_diamond_num
        self.stone_expend = SpecMgrs.data_mgr:GetMarryExpendData(self.child_info.grade).cross_expend_item_num
    else
        self.diamond_expend = SpecMgrs.data_mgr:GetMarryExpendData(self.child_info.grade).diamond_num
        self.stone_expend = SpecMgrs.data_mgr:GetMarryExpendData(self.child_info.grade).expend_item_num
    end

    local cur_diamond_num = ComMgrs.dy_data_mgr:ExGetCurrencyCount(CSConst.Virtual.Diamond)
    local cur_stone_num = ComMgrs.dy_data_mgr.bag_data:GetBagItemCount(self.stone_id)

    self.diamond_num_text.text = UIFuncs.GetPerStr(cur_diamond_num, self.diamond_expend)
    self.marriage_stone_num_text.text = UIFuncs.GetPerStr(cur_stone_num, self.stone_expend)
end

function UniteMarriageUI:UpdateMarryTargetList()
    if self.is_show_server then
        self.change_show_server_button_text.text = UIConst.Text.MY_SERVER
    else
        self.change_show_server_button_text.text = UIConst.Text.ACROSS_SERVER
    end
    self:ShowRecruitMarryMes(self.is_show_server)
end

function UniteMarriageUI:ClickMarryButton(is_recruit)
    self.recruit_marry_button:FindChild("SelectImage"):SetActive(is_recruit)
    self.propose_marry_button:FindChild("SelectImage"):SetActive(not is_recruit)
    self.recruit_marry_frame:SetActive(is_recruit)
    self.propose_marry_frame:SetActive(not is_recruit)
    self.middle_unite_marry_button:SetActive(is_recruit)
    self.middle_propose_marry_button:SetActive(not is_recruit)
    if not is_recruit then
        self.down_frame_propose_marry_button_text.text = UIConst.Text.PROPOSE_MARRY_SELECT_BTN_TEXT
        self.down_frame_recruit_marry_button_text.text = UIConst.Text.RECRUIT_MARRY_BTN_TEXT
        self:SetProposeMarryPanel()
    else
        self.down_frame_propose_marry_button_text.text = UIConst.Text.PROPOSE_MARRY_BTN_TEXT
        self.down_frame_recruit_marry_button_text.text = UIConst.Text.RECRUIT_MARRY_SELECT_BTN_TEXT
    end
end

--  显示正在招亲的人
function UniteMarriageUI:ShowRecruitMarryMes(is_own_server)
    local resp_cb = function(resp)
        if resp.errcode == 1 then
            self.is_not_marry_target = true
            self.no_recruit_marry_tip:SetActive(true)
            self.recruit_marry_list_content:SetActive(false)
            return
        end
        self.dy_child_data:UpdateRequestMarry(resp.service_object_list, CSConst.ChildSendRequest.Service, 1)
        self.dy_child_data:UpdateRequestMarry(resp.cross_object_list, CSConst.ChildSendRequest.Cross, 1)
        local recruit_list
        if is_own_server then
            recruit_list = self.dy_child_data:GerServerRequestList()
        else
            recruit_list = self.dy_child_data:GerWorldRequestList()
        end
        if not next(recruit_list)then
            self.is_not_marry_target = true
            self.no_recruit_marry_tip:SetActive(true)
            self.recruit_marry_list_content:SetActive(false)
            return
        end
        self.is_not_marry_target = false
        self.no_recruit_marry_tip:SetActive(false)
        self.recruit_marry_list_content:SetActive(true)

        self:DelObjDict(self.recruit_obj_list)
        self.recruit_obj_list = {}
        if self.recruit_marry_scorll_list_comp then
            self.recruit_marry_scorll_list_comp:DoDestroy()
        end
        self.recruit_marry_scorll_list_comp = ScrollListViewCmp.New()
        self.recruit_marry_scorll_list_comp:DoInit(self, self.recruit_marry_frame:FindChild("MarriedList"))

        self.marry_target_selector = UIFuncs.CreateSelector(self, self.recruit_obj_list, function(i)
            self.cur_select_marry_target = recruit_list[i]
        end)

        self.recruit_marry_scorll_list_comp:ListenerViewChange(function(go, index)
            index = index + 1
            if index >= (#recruit_list) then
                local page_id = math.ceil(index / page_count) + 1
                local callback = function(resp)
                    self.dy_child_data:UpdateRequestMarry(resp.service_object_list, CSConst.ChildSendRequest.Service, page_id)
                    self.dy_child_data:UpdateRequestMarry(resp.cross_object_list, CSConst.ChildSendRequest.Cross, page_id)
                    if is_own_server then
                        recruit_list = self.dy_child_data:GerServerRequestList()
                    else
                        recruit_list = self.dy_child_data:GerWorldRequestList()
                    end
                    local length = #recruit_list
                    self.recruit_marry_scorll_list_comp:ChangeTotalCount(length)
                    self:AddMarryTargetObj(index, go, recruit_list)
                end
                local param_tb = {
                    sex = self:GetMarrySex(self.dy_child_data:GetAdultChildDataById(self.child_id).sex),
                    page_id = page_id,
                    grade = self.child_info.grade,
                }
                SpecMgrs.msg_mgr:SendOpenJointMarry(param_tb, callback)
            else
                self:AddMarryTargetObj(index, go, recruit_list)
            end
        end)
        local show_count = #recruit_list < self.scroll_show_count and #recruit_list or self.scroll_show_count
        self.recruit_marry_scorll_list_comp:Start(#recruit_list, show_count)
    end

    local param_tb = {
        sex = self:GetMarrySex(self.dy_child_data:GetAdultChildDataById(self.child_id).sex),
        page_id = 1,
        grade = self.child_info.grade,
    }
    SpecMgrs.msg_mgr:SendOpenJointMarry(param_tb, resp_cb)
end

function UniteMarriageUI:AddMarryTargetObj(index, go, recruit_list)
    local marry_info = recruit_list[index]
    self:SetMarryTargetPanel(go, marry_info)
    local is_create = true
    local unit_id = self.dy_child_data:GetChildUnitId(marry_info, CSConst.ChildStatus.Adult)
    if self.marry_target_unit_dict[go] then
        if self.marry_target_unit_dict[go].unit_id ~= unit_id then
            self:RemoveUnit(self.marry_target_unit_dict[go])
        else
            is_create = false
        end
    end

    if is_create then
        local unit = self:AddHeadUnit(unit_id, go:FindChild("ChildImage/ChildPoint"))
        unit:StopAllAnimationToCurPos()
        self.marry_target_unit_dict[go] = unit
    end
    if not self.recruit_obj_list[index] then
        table.insert(self.recruit_obj_list, go)
        self.marry_target_selector:AddObj(go, index)
    end
    if not self.marry_target_selector:GetCurSelectIndex() then
        self.marry_target_selector:SelectObj(1, true)
    end
end

function UniteMarriageUI:SelectMarriageStone()
    self.marriage_stone:FindChild("SelectImage"):SetActive(true)
    self.diamond:FindChild("SelectImage"):SetActive(false)
    self.cur_select_item = SpecMgrs.data_mgr:GetMarryExpendData(self.child_info.grade).expend_item
end

function UniteMarriageUI:SelectDiamond()
    self.marriage_stone:FindChild("SelectImage"):SetActive(false)
    self.diamond:FindChild("SelectImage"):SetActive(true)
    self.cur_select_item = SpecMgrs.data_mgr:GetParamData("child_request_marry_diamond").item_id
end

function UniteMarriageUI:SetMarryTargetPanel(target_panel, marry_info)
    target_panel:FindChild("ChildNameText"):GetComponent("Text").text = marry_info.child_name
    target_panel:FindChild("ChildGradeText"):GetComponent("Text").text = UIConst.Text.CHILD_GRADE_VAL_TEXT
    target_panel:FindChild("TotalTalentText"):GetComponent("Text").text = UIConst.Text.CHILD_ALL_TALENT_VAL_TEXT
    target_panel:FindChild("TotalAttrText"):GetComponent("Text").text = UIConst.Text.CHILD_ALL_ATTR_VAL_TEXT

    local grade_name = SpecMgrs.data_mgr:GetChildQualityData(marry_info.grade).quality_text[marry_info.sex]
    target_panel:FindChild("ChildGradeValText"):GetComponent("Text").text = grade_name
    target_panel:FindChild("TotalTalentValText"):GetComponent("Text").text = table.sum(marry_info.aptitude_dict)
    target_panel:FindChild("TotalAttrValText"):GetComponent("Text").text = table.sum(marry_info.attr_dict)

    target_panel:FindChild("ServerText"):GetComponent("Text").text = UIConst.Text.ACROSS_SERVER
    target_panel:FindChild("ChildFatherText"):GetComponent("Text").text = string.format(UIConst.Text.FATHER_NAME_FORMAT, marry_info.role_name)
    if marry_info.server_type == CSConst.ChildSendRequest.Cross then
        target_panel:FindChild("ServerText"):SetActive(true)
    else
        target_panel:FindChild("ServerText"):SetActive(false)
    end
end

function UniteMarriageUI:SetProposeMarryPanel()
    local my_server_tip = self.propose_marry_panel:FindChild("MyServerTip"):GetComponent("Text")
    local my_server_appoint_tip = self.propose_marry_panel:FindChild("MyServerAppointTip"):GetComponent("Text")
    local other_server_tip = self.propose_marry_panel:FindChild("OtherServerTip"):GetComponent("Text")
    local my_server_toggle_text = self.propose_marry_panel:FindChild("MyServerToggle/Label"):GetComponent("Text")
    local my_server_appoint_toggle_text = self.propose_marry_panel:FindChild("MyServerAppointToggle/Label"):GetComponent("Text")
    local other_server_toggle_text = self.propose_marry_panel:FindChild("OtherServerToggle/Label"):GetComponent("Text")

    my_server_tip.text = UIConst.Text.MY_SERVER_TIP
    my_server_appoint_tip.text = UIConst.Text.MY_SERVER_APPOINT_TIP
    other_server_tip.text = UIConst.Text.OTHER_SERVER_TIP
    my_server_toggle_text.text = UIConst.Text.MY_SERVER_TOGGLE
    my_server_appoint_toggle_text.text = UIConst.Text.MY_SERVER_APPOINT_TOGGLE
    other_server_toggle_text.text = UIConst.Text.OTHER_SERVER_TOGGLE

    self.appoint_target_input.text = ""
end

function UniteMarriageUI:IsSelectOtherServer()
    return self.other_server_toggle.isOn
end

function UniteMarriageUI:ClickUniteMarry()
    if not self.cur_select_marry_target then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.NO_RECIURT_MARRY_TARGET_TIP)
        return
    end
    local cost_num = self:GetCostItem(self.cur_select_marry_target.server_type == CSConst.ChildSendRequest.Cross)
    local param_tb = {
        is_show_tip = true,
        item_id = self.cur_select_item,
        need_count = cost_num,
        remind_tag = "ClickUniteMarry",
        title = UIConst.Text.RECRUIT_MARRY_TEXT,
        desc = string.format(UIConst.Text.EXPAND_RECRUIT_MARRY_FORMAT, SpecMgrs.data_mgr:GetItemData(self.cur_select_item).name, cost_num),
        confirm_cb = function()
            self:SendUniteMarry()
        end
    }
    SpecMgrs.ui_mgr:ShowItemUseRemindByTb(param_tb)
end

function UniteMarriageUI:SendUniteMarry()
    local param_tb = {
        apply_type = self.cur_select_marry_target.server_type,
        child_id = self.child_id,
        object_uuid = self.cur_select_marry_target.uuid,
        object_child_id = self.cur_select_marry_target.child_id,
        item_id = self.cur_select_item,
    }
    local resp_cb = function(resp)
        self:Hide()
    end
    SpecMgrs.msg_mgr:SendAcceptMarry(param_tb, resp_cb)
end

function UniteMarriageUI:ClickProposeMarry()
    local cost_num = self:GetCostItem(self.other_server_toggle.isOn)
    local param_tb = {
        is_show_tip = true,
        item_id = self.cur_select_item,
        need_count = cost_num,
        remind_tag = "ClickProposeMarry",
        title = UIConst.Text.PROPOSE_MARRY_TEXT,
        desc = string.format(UIConst.Text.EXPAND_PROPOSE_MARRY_FORMAT, SpecMgrs.data_mgr:GetItemData(self.cur_select_item).name, cost_num),
        confirm_cb = function()
            self:SendProposeMarry()
        end
    }
    SpecMgrs.ui_mgr:ShowItemUseRemindByTb(param_tb)
end

function UniteMarriageUI:SendProposeMarry()
    local param_tb = {
        child_id = self.child_id,
        apply_type = 1,
        uuid = nil,
        item_id = self.cur_select_item,
    }
    if self.my_server_toggle.isOn then
        param_tb.apply_type = CSConst.ChildSendRequest.Service
    elseif self.my_server_appoint_toggle.isOn then
        param_tb.uuid = self.appoint_target_input.text
        param_tb.apply_type = CSConst.ChildSendRequest.Assign
    elseif self.other_server_toggle.isOn then
        param_tb.apply_type = CSConst.ChildSendRequest.Cross
    else
        PrintError("No Select")
    end
    local resp_cb = function(resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.PROPOSE_MARRY_REQUEST_FAILED)
            return
        end
        self:Hide()
    end
    SpecMgrs.msg_mgr:SendProposeMarry(param_tb, resp_cb)
end

function UniteMarriageUI:GetCostItem(is_cross_server)
    local expend_data = SpecMgrs.data_mgr:GetMarryExpendData(self.child_info.grade)
    local cost_num
    local is_diamond = expend_data.diamond == self.cur_select_item
    if is_cross_server then
        if is_diamond then
            cost_num = expend_data.cross_diamond_num
        else
            cost_num = expend_data.cross_expend_item_num
        end
    else
        if is_diamond then
            cost_num = expend_data.diamond_num
        else
            cost_num = expend_data.expend_item_num
        end
    end
    return cost_num
end

function UniteMarriageUI:GetMarrySex(sex)
    if sex == CSConst.Sex.Man then
        return CSConst.Sex.Woman
    else
        return CSConst.Sex.Man
    end
end

function UniteMarriageUI:Hide()
    UIFuncs.UnregisterUpdateItemNum(self, "UniteMarriageUIDiamond", CSConst.Virtual.Diamond)
    UIFuncs.UnregisterUpdateItemNum(self, "UniteMarriageUIStone", self.stone_id)
    UniteMarriageUI.super.Hide(self)
end

return UniteMarriageUI
