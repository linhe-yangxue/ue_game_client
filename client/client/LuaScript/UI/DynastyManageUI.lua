local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local DynastyManageUI = class("UI.DynastyManageUI", UIBase)

local kTabDict = {
    MemberList = 1,
    MemberManage = 2,
}
local kManageOpDict = {
    ModifyInfo = 1,
    HandleApply = 2,
    ManageMember = 3,
}
local kAppointOpDict = {
    GodFather = 1,      --任命为教父
    SecondHandle = 2,   --      二把手
    Member = 3,         --      成员
    Kick = 4,           --踢出
}

function DynastyManageUI:DoInit()
    DynastyManageUI.super.DoInit(self)
    self.prefab_path = "UI/Common/DynastyManageUI"
    self.dy_dynasty_data = ComMgrs.dy_data_mgr.dynasty_data
    self.dy_bag_data = ComMgrs.dy_data_mgr.bag_data
    self.dy_friend_data = ComMgrs.dy_data_mgr.friend_data
    self.declaration_len_limit = SpecMgrs.data_mgr:GetParamData("dynasty_notice_declaration_len").f_value
    self.modify_badge_cost_data = SpecMgrs.data_mgr:GetParamData("modify_dynasty_badge_cost")
    self.modify_name_cost_data = SpecMgrs.data_mgr:GetParamData("modify_dynasty_name_cost")
    self.dynasty_name_min_len = SpecMgrs.data_mgr:GetParamData("dynasty_name_min_len").f_value
    self.dynasty_name_max_len = SpecMgrs.data_mgr:GetParamData("dynasty_name_max_len").f_value
    self.tab_btn_data_dict = {}
    self.manage_op_data_dict = {}
    self.dynasty_member_item_list = {}
    self.dynasty_member_list = {}
    self.dynasty_apply_item_list = {}
    self.manage_member_item_list = {}
    self.badge_item_list = {}
    self.appoint_btn_select_dict = {}
end

function DynastyManageUI:OnGoLoadedOk(res_go)
    DynastyManageUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function DynastyManageUI:Hide()
    self:Close()
    DynastyManageUI.super.Hide(self)
    self.dy_dynasty_data:UnregisterKickedOutDynastyEvent("DynastyManageUI")
    self.dy_dynasty_data:UnregisterUpdateDynastyJobEvent("DynastyManageUI")
end

function DynastyManageUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    DynastyManageUI.super.Show(self)
end

function DynastyManageUI:InitRes()
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "DynastyManageUI")

    local tab_panel = self.main_panel:FindChild("TabPanel")
    local member_btn = tab_panel:FindChild("MemberBtn")
    member_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_MEMBER_TEXT
    self:AddClick(member_btn, function ()
        self:UpdateTabPanel(kTabDict.MemberList)
    end)
    self.tab_btn_data_dict[kTabDict.MemberList] = {}
    self.tab_btn_data_dict[kTabDict.MemberList].btn_cmp = member_btn:GetComponent("Button")
    local member_btn_select = member_btn:FindChild("Select")
    self.tab_btn_data_dict[kTabDict.MemberList].select = member_btn_select
    member_btn_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_MEMBER_TEXT

    self.manage_btn = tab_panel:FindChild("ManageBtn")
    self.manage_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_MANAGE_TITLE
    self:AddClick(self.manage_btn, function ()
        self:UpdateTabPanel(kTabDict.MemberManage)
    end)
    self.tab_btn_data_dict[kTabDict.MemberManage] = {}
    self.tab_btn_data_dict[kTabDict.MemberManage].btn_cmp = self.manage_btn:GetComponent("Button")
    local manage_btn_select = self.manage_btn:FindChild("Select")
    self.tab_btn_data_dict[kTabDict.MemberManage].select = manage_btn_select
    manage_btn_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_MANAGE_TITLE

    local content = self.main_panel:FindChild("Content")
    -- 成员列表
    self.member_panel = content:FindChild("MemberPanel")
    self.tab_btn_data_dict[kTabDict.MemberList].content = self.member_panel
    self.tab_btn_data_dict[kTabDict.MemberList].init_func = self.InitMemberPanel
    local member_mark_panel = self.member_panel:FindChild("MarkPanel")
    member_mark_panel:FindChild("MemberText"):GetComponent("Text").text = UIConst.Text.MEMBER_TEXT
    member_mark_panel:FindChild("ScoreText"):GetComponent("Text").text = UIConst.Text.SCORE_TEXT
    member_mark_panel:FindChild("LevelText"):GetComponent("Text").text = UIConst.Text.LEVEL_TEXT
    member_mark_panel:FindChild("ContributionText"):GetComponent("Text").text = UIConst.Text.CONTRIBUTION_TEXT
    member_mark_panel:FindChild("OnlineStateText"):GetComponent("Text").text = UIConst.Text.ONLINESTATE_TEXT
    self.member_list_content = self.member_panel:FindChild("MemberList/View/Content")
    self.member_item = self.member_list_content:FindChild("MemberItem")
    local bottom_panel = self.member_panel:FindChild("BottomPanel")
    bottom_panel:FindChild("Tip"):GetComponent("Text").text = UIConst.Text.GODFATHER_OUTLINE_TIP
    self.member_count = bottom_panel:FindChild("CountPanel/Text"):GetComponent("Text")
    -- 成员管理
    self.manage_panel = content:FindChild("ManagePanel")
    self.tab_btn_data_dict[kTabDict.MemberManage].content = self.manage_panel
    self.tab_btn_data_dict[kTabDict.MemberManage].init_func = self.InitManagePanel
    local op_panel = self.manage_panel:FindChild("OpPanel")

    local modify_info_btn = op_panel:FindChild("ModifyInfoBtn")
    modify_info_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.MODIFY_INFO_TEXT
    self.manage_op_data_dict[kManageOpDict.ModifyInfo] = {}
    self.manage_op_data_dict[kManageOpDict.ModifyInfo].btn_cmp = modify_info_btn:GetComponent("Button")
    local modify_info_select = modify_info_btn:FindChild("Select")
    self.manage_op_data_dict[kManageOpDict.ModifyInfo].select = modify_info_select
    modify_info_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.MODIFY_INFO_TEXT
    self:AddClick(modify_info_btn, function ()
        self:UpdateManagePanel(kManageOpDict.ModifyInfo)
    end)
    local handle_apply_btn = op_panel:FindChild("HandleApplyBtn")
    handle_apply_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.HANDLE_APPLY_TEXT
    self.manage_op_data_dict[kManageOpDict.HandleApply] = {}
    self.manage_op_data_dict[kManageOpDict.HandleApply].btn_cmp = handle_apply_btn:GetComponent("Button")
    local handle_apply_select = handle_apply_btn:FindChild("Select")
    self.manage_op_data_dict[kManageOpDict.HandleApply].select = handle_apply_select
    handle_apply_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.HANDLE_APPLY_TEXT
    self:AddClick(handle_apply_btn, function ()
        self:UpdateManagePanel(kManageOpDict.HandleApply)
    end)
    local manage_member_btn = op_panel:FindChild("ManageMemberBtn")
    manage_member_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.MANAGE_MEMBER_TEXT
    self.manage_op_data_dict[kManageOpDict.ManageMember] = {}
    self.manage_op_data_dict[kManageOpDict.ManageMember].btn_cmp = manage_member_btn:GetComponent("Button")
    local manage_member_select = manage_member_btn:FindChild("Select")
    self.manage_op_data_dict[kManageOpDict.ManageMember].select = manage_member_select
    manage_member_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.MANAGE_MEMBER_TEXT
    self:AddClick(manage_member_btn, function ()
        self:UpdateManagePanel(kManageOpDict.ManageMember)
    end)
    -- 修改王朝信息面板
    local modify_info_panel = self.manage_panel:FindChild("ModifyInfoPanel")
    self.manage_op_data_dict[kManageOpDict.ModifyInfo].content = modify_info_panel
    self.manage_op_data_dict[kManageOpDict.ModifyInfo].init_func = self.InitModifyInfoPanel
    local basic_info_panel = modify_info_panel:FindChild("BasicInfoPanel")
    self.dynasty_basic_icon = basic_info_panel:FindChild("Info/BadgeIcon"):GetComponent("Image")
    local change_badge_btn = basic_info_panel:FindChild("Info/ChangeBadgeBtn")
    change_badge_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.REPLACE_TEXT
    self:AddClick(change_badge_btn, function ()
        self:InitSelectBadgePanel()
    end)
    local basic_name_panel = basic_info_panel:FindChild("Info/NamePanel")
    self.dynasty_basic_name = basic_name_panel:FindChild("DynastyName"):GetComponent("Text")
    self:AddClick(basic_name_panel:FindChild("RenameBtn"), function ()
        self.rename_input.text = ""
        self.rename_panel:SetActive(true)
    end)
    self.dynasty_basic_level = basic_info_panel:FindChild("Info/DynastyLv"):GetComponent("Text")
    local dynasty_basic_exp_bar = basic_info_panel:FindChild("Info/ExpBar")
    self.dynasty_basic_exp = dynasty_basic_exp_bar:FindChild("Exp"):GetComponent("Image")
    self.dynasty_basic_exp_value = dynasty_basic_exp_bar:FindChild("ExpValue"):GetComponent("Text")
    local dynasty_declaration_panel = modify_info_panel:FindChild("DeclarationPanel")
    dynasty_declaration_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_DECLARATION_TEXT
    self.dynasty_declaration_input = dynasty_declaration_panel:FindChild("Declaration"):GetComponent("InputField")
    local dynasty_announcement_panel = modify_info_panel:FindChild("AnnouncementPanel")
    dynasty_announcement_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_ANNOUNCEMENT_TEXT
    self.dynasty_announcement_input = dynasty_announcement_panel:FindChild("Announcement"):GetComponent("InputField")
    local save_modify_btn = modify_info_panel:FindChild("BottomPanel/SaveBtn")
    save_modify_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SAVE_MODIFY_TEXT
    self:AddClick(save_modify_btn, function ()
        self:SaveModifyDynastyDeclaration()
        self:SaveModifyDynastyAnnouncement()
    end)
    -- 处理王朝申请界面
    local handle_apply_panel = self.manage_panel:FindChild("HandleApplyPanel")
    self.manage_op_data_dict[kManageOpDict.HandleApply].content = handle_apply_panel
    self.manage_op_data_dict[kManageOpDict.HandleApply].init_func = self.InitHandleApplyPanel
    self.handle_apply_member_count = handle_apply_panel:FindChild("MemberPanel/MemberCount"):GetComponent("Text")
    self.empty_apply = handle_apply_panel:FindChild("Empty")
    self.apply_content = handle_apply_panel:FindChild("ApplyContent")
    local handle_apply_mark_panel = self.apply_content:FindChild("MarkPanel")
    handle_apply_mark_panel:FindChild("PlayerText"):GetComponent("Text").text = UIConst.Text.PLAYER_TEXT
    handle_apply_mark_panel:FindChild("ScoreText"):GetComponent("Text").text = UIConst.Text.SCORE_TEXT
    handle_apply_mark_panel:FindChild("LevelText"):GetComponent("Text").text = UIConst.Text.LEVEL_TEXT
    self.apply_list_content = self.apply_content:FindChild("ApplyList/View/Content")
    self.apply_item = self.apply_list_content:FindChild("PlayerItem")
    self.apply_item:FindChild("AgreeBtn/Text"):GetComponent("Text").text = UIConst.Text.AGREE_APPLY
    self.apply_item:FindChild("IgnoreBtn/Text"):GetComponent("Text").text = UIConst.Text.IGNORE_APPLY
    bottom_panel = handle_apply_panel:FindChild("BottomPanel")
    local ignore_all_btn = bottom_panel:FindChild("IgnoreAllBtn")
    ignore_all_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.IGNORE_ALL_APPLY
    self:AddClick(ignore_all_btn, function ()
        self:IgnoreApply()
    end)
    self.apply_count = bottom_panel:FindChild("ApplyCount"):GetComponent("Text")
    -- 管理成员界面
    local member_manage_panel = self.manage_panel:FindChild("MemberManagePanel")
    self.manage_op_data_dict[kManageOpDict.ManageMember].content = member_manage_panel
    self.manage_op_data_dict[kManageOpDict.ManageMember].init_func = self.InitManageMemberPanel
    self.member_manage_count = member_manage_panel:FindChild("MemberPanel/MemberCount"):GetComponent("Text")
    local member_manage_content = member_manage_panel:FindChild("ManageContent")
    local member_manage_mark_panel = member_manage_content:FindChild("MarkPanel")
    member_manage_mark_panel:FindChild("MemberText"):GetComponent("Text").text = UIConst.Text.MEMBER_TEXT
    member_manage_mark_panel:FindChild("ScoreText"):GetComponent("Text").text = UIConst.Text.SCORE_TEXT
    member_manage_mark_panel:FindChild("LevelText"):GetComponent("Text").text = UIConst.Text.LEVEL_TEXT
    member_manage_mark_panel:FindChild("ContributionText"):GetComponent("Text").text = UIConst.Text.CONTRIBUTION_TEXT
    self.manage_member_list_content = member_manage_content:FindChild("MemberList/View/Content")
    self.manage_member_item = self.manage_member_list_content:FindChild("MemberItem")
    self.manage_member_item:FindChild("AppointBtn/Text"):GetComponent("Text").text = UIConst.Text.APPOINT_TEXT
    self.manage_member_item:FindChild("Self/Text"):GetComponent("Text").text = UIConst.Text.SELF_TEXT
    self.manage_member_item:FindChild("Permission"):GetComponent("Text").text = UIConst.Text.PERMISSION_LIMIT
    local dynasty_disband_btn = member_manage_panel:FindChild("BottomPanel/DisbandBtn")
    dynasty_disband_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DISBAND_DYNASTY_TEXT
    self.dynasty_disband_btn_cmp = dynasty_disband_btn:GetComponent("Button")
    self.dynasty_disband_disable = dynasty_disband_btn:FindChild("Disable")
    self:AddClick(dynasty_disband_btn, function ()
        self:DisbandDynasty()
    end)
    -- 改变徽章界面
    self.change_badge_panel = self.main_panel:FindChild("ChangeBadgePanel")
    self.cur_badge = self.change_badge_panel:FindChild("CurBadge"):GetComponent("Image")
    self.badge_selection_content = self.change_badge_panel:FindChild("SelectPanel/View/Content")
    self.badge_item = self.badge_selection_content:FindChild("Badge")
    local cancel_change_btn = self.change_badge_panel:FindChild("CancelBtn")
    cancel_change_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CANCEL
    self:AddClick(cancel_change_btn, function ()
        self.change_badge_panel:SetActive(false)
    end)
    local submit_change_btn = self.change_badge_panel:FindChild("SubmitBtn")
    self.submit_change_text = submit_change_btn:FindChild("Text"):GetComponent("Text")
    self:AddClick(submit_change_btn, function ()
        if self.cur_select_badge == self.dynasty_base_info.dynasty_badge then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.DYNASTY_BADGE_SAME)
        else
            self:ModifyDynastyBadge()
        end
    end)

    -- 成员任命界面
    self.appoint_panel = self.main_panel:FindChild("AppointPanel")
    local appoint_content = self.appoint_panel:FindChild("Content")
    appoint_content:FindChild("Title"):GetComponent("Text").text = UIConst.Text.MEMBER_APPOINT_TEXT
    self:AddClick(appoint_content:FindChild("CloseBtn"), function ()
        self.appoint_panel:SetActive(false)
    end)
    local cur_member_info = appoint_content:FindChild("Info")
    self.cur_member_icon = cur_member_info:FindChild("IconBg/Icon"):GetComponent("Image")
    self.cur_member_name = cur_member_info:FindChild("Name"):GetComponent("Text")
    self.cur_member_vip = cur_member_info:FindChild("Vip"):GetComponent("Text")
    local appoint_selection_panel = appoint_content:FindChild("Selection")
    -- 教父
    self.appoint_godfather_btn = appoint_selection_panel:FindChild("GodFather")
    self.appoint_godfather_btn:FindChild("OpText"):GetComponent("Text").text = UIConst.Text.GODFATHER_TEXT
    self:AddClick(self.appoint_godfather_btn, function ()
        self:UpdateAppointBtnState(kAppointOpDict.GodFather)
    end)
    self.appoint_godfather_btn:FindChild("StatePanel/State"):GetComponent("Text").text = UIConst.Text.JOB_SELECT
    local appoint_godfather_select = self.appoint_godfather_btn:FindChild("Select")
    self.appoint_btn_select_dict[kAppointOpDict.GodFather] = appoint_godfather_select
    appoint_godfather_select:FindChild("State"):GetComponent("Text").text = UIConst.Text.JOB_SELECTED
    -- 二把手
    self.appoint_second_handle_btn = appoint_selection_panel:FindChild("SecondHandle")
    self.appoint_second_handle_btn:FindChild("OpText"):GetComponent("Text").text = UIConst.Text.SECOND_HANDLE_TEXT
    self:AddClick(self.appoint_second_handle_btn, function ()
        self:UpdateAppointBtnState(kAppointOpDict.SecondHandle)
    end)
    self.appoint_second_handle_state = self.appoint_second_handle_btn:FindChild("StatePanel/State"):GetComponent("Text")
    local appoint_second_handle_select = self.appoint_second_handle_btn:FindChild("Select")
    self.appoint_btn_select_dict[kAppointOpDict.SecondHandle] = appoint_second_handle_select
    appoint_second_handle_select:FindChild("State"):GetComponent("Text").text = UIConst.Text.JOB_SELECTED
    -- 成员
    self.appoint_member_btn = appoint_selection_panel:FindChild("Member")
    self.appoint_member_btn:FindChild("OpText"):GetComponent("Text").text = UIConst.Text.MEMBER_TEXT
    self:AddClick(self.appoint_member_btn, function ()
        self:UpdateAppointBtnState(kAppointOpDict.Member)
    end)
    self.appoint_member_state = self.appoint_member_btn:FindChild("StatePanel/State"):GetComponent("Text")
    local appoint_member_select = self.appoint_member_btn:FindChild("Select")
    self.appoint_btn_select_dict[kAppointOpDict.Member] = appoint_member_select
    appoint_member_select:FindChild("State"):GetComponent("Text").text = UIConst.Text.JOB_SELECTED
    -- 踢出
    self.appoint_kick_btn = appoint_selection_panel:FindChild("Kick")
    self.appoint_kick_btn:FindChild("OpText"):GetComponent("Text").text = UIConst.Text.KICK_OUT_TEXT
    self:AddClick(self.appoint_kick_btn, function ()
        self:UpdateAppointBtnState(kAppointOpDict.Kick)
    end)
    self.appoint_kick_btn:FindChild("StatePanel/State"):GetComponent("Text").text = UIConst.Text.JOB_SELECT
    local appoint_kick_select = self.appoint_kick_btn:FindChild("Select")
    self.appoint_btn_select_dict[kAppointOpDict.Kick] = appoint_kick_select
    appoint_kick_select:FindChild("State"):GetComponent("Text").text = UIConst.Text.JOB_SELECTED
    local appoint_cancel_btn = appoint_content:FindChild("BtnPanel/CancelBtn")
    appoint_cancel_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CANCEL
    self:AddClick(appoint_cancel_btn, function ()
        self.appoint_panel:SetActive(false)
    end)
    local appoint_submit_btn = appoint_content:FindChild("BtnPanel/AppointBtn")
    appoint_submit_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CONFIRM
    self:AddClick(appoint_submit_btn, function ()
        self:SendAppointMember()
        self.appoint_panel:SetActive(false)
    end)
    --改名面板
    self.rename_panel = self.main_panel:FindChild("RenamePanel")
    local rename_content = self.rename_panel:FindChild("Content")
    rename_content:FindChild("Title"):GetComponent("Text").text = UIConst.Text.DYNASTY_RENAME_TEXT
    rename_content:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DYNASTY_RENAME_TIP
    self:AddClick(rename_content:FindChild("CloseBtn"), function ()
        self.rename_panel:SetActive(false)
    end)
    self.rename_input = rename_content:FindChild("RenameInput"):GetComponent("InputField")
    UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetItemData(self.modify_name_cost_data.item_id).icon, rename_content:FindChild("Consumption/Image"):GetComponent("Image"))
    rename_content:FindChild("Consumption/Count"):GetComponent("Text").text = string.format(UIConst.Text.COUNT, self.modify_name_cost_data.count)
    local rename_submit_btn = rename_content:FindChild("BtnPanel/RenameSubmit")
    rename_submit_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CONFIRM
    self:AddClick(rename_submit_btn, function ()
        self:ModifyDynastyName()
    end)
    local rename_cancel_btn = rename_content:FindChild("BtnPanel/RenameCancel")
    rename_cancel_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CANCEL
    self:AddClick(rename_cancel_btn, function ()
        self.rename_panel:SetActive(false)
    end)
end

function DynastyManageUI:InitUI()
    self.cur_tab = self.cur_tab or kTabDict.MemberList
    self:UpdateDynastyInfo()
    self:RegisterEvent(ComMgrs.dy_data_mgr, "UpdateCurrencyEvent", function (_, currency)
        if self._item_to_text_list then
            UIFuncs.UpdateCurrencyItemNum(self._item_to_text_list, currency)
        end
    end)
    self.dy_dynasty_data:RegisterKickedOutDynastyEvent("DynastyManageUI", self.Hide, self)
    self.dy_dynasty_data:RegisterUpdateDynastyJobEvent("DynastyManageUI", self.UpdateDynastyInfo, self)
end

function DynastyManageUI:UpdateDynastyInfo()
    SpecMgrs.msg_mgr:SendGetDynastyBasicInfo({}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_dynasty_base_info_FAILED)
        else
            self.dynasty_base_info = resp.dynasty_base_info
        end
    end)
    self.dy_dynasty_data:UpdateDynastyMemberInfo(function (member_dict)
        self.dynasty_member_dict = member_dict
        self.self_member_info = self.dynasty_member_dict[ComMgrs.dy_data_mgr:ExGetRoleUuid()]
        if not self.self_member_info then
            self:Hide()
            return
        end
        self.second_handle_count = 0
        self.dynasty_member_list = self.dy_dynasty_data:GetMemberList(member_dict)
        for _, member_info in pairs(self.dynasty_member_dict) do
            if member_info.job == CSConst.DynastyJob.SecondChief then
                self.second_handle_count = self.second_handle_count + 1
            end
        end
        local job_data = SpecMgrs.data_mgr:GetDynastyJobData(self.self_member_info.job)
        self.manage_btn:SetActive(job_data.is_manager)
        if not job_data.is_manager then
            self.change_badge_panel:SetActive(false)
            self.appoint_panel:SetActive(false)
            self.rename_panel:SetActive(false)
        end
        self:UpdateTabPanel(job_data.is_manager and self.cur_tab or kTabDict.MemberList)
    end)
end

function DynastyManageUI:UpdateTabPanel(tab)
    if self.cur_tab and self.cur_tab ~= tab then
        local last_tab_btn_data = self.tab_btn_data_dict[self.cur_tab]
        last_tab_btn_data.btn_cmp.interactable = true
        last_tab_btn_data.select:SetActive(false)
        last_tab_btn_data.content:SetActive(false)
    end
    self.cur_tab = tab
    local cur_tab_btn_data = self.tab_btn_data_dict[self.cur_tab]
    cur_tab_btn_data.btn_cmp.interactable = false
    cur_tab_btn_data.select:SetActive(true)
    cur_tab_btn_data.init_func(self)
    cur_tab_btn_data.content:SetActive(true)
end

function DynastyManageUI:InitMemberPanel()
    self:ClearDynastyMemberItem()
    local self_uuid = ComMgrs.dy_data_mgr:ExGetRoleUuid()
    for i, member_info in ipairs(self.dynasty_member_list) do
        local job_data = SpecMgrs.data_mgr:GetDynastyJobData(member_info.job)
        local member_item = self:GetUIObject(self.member_item, self.member_list_content)
        local role_unit_id = SpecMgrs.data_mgr:GetRoleLookData(member_info.role_id).unit_id
        local member_icon = member_item:FindChild("IconBg/Icon")
        self:AddClick(member_icon, function ()
            if member_info.uuid == self_uuid then return end
            self.dy_friend_data:ShowPlayerInfo(member_info.uuid)
        end)
        UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetUnitData(role_unit_id).icon, member_icon:GetComponent("Image"))
        member_item:FindChild("IconBg/Job/Text"):GetComponent("Text").text = string.format(UIConst.Text.SIMPLE_COLOR, job_data.job_color, job_data.name)
        member_item:FindChild("Name"):GetComponent("Text").text = member_info.name
        member_item:FindChild("Vip"):GetComponent("Text").text = string.format(UIConst.Text.VIP, member_info.vip)
        member_item:FindChild("Score"):GetComponent("Text").text = UIFuncs.AddCountUnit(member_info.fight_score)
        member_item:FindChild("Level"):GetComponent("Text").text = member_info.level
        member_item:FindChild("Contribution"):GetComponent("Text").text = member_info.history_dedicate
        member_item:FindChild("Self"):SetActive(member_info.uuid == self_uuid)
        local offline_text
        if member_info.offline_ts then
            local offline_duration = Time:GetServerTime() - member_info.offline_ts
            local duration_tb = UIFuncs.TimeDelta2Table(offline_duration, 6)
            offline_text = UIConst.Text.OFFLINE_RECENTLY
            for i = 6, 3, -1 do
                if duration_tb[i] > 0 then
                    offline_text = string.format(UIConst.Text.OFFLINE_DURATION_FORMAT, duration_tb[i], UIConst.Text.TIME_TEXT[i])
                    break
                end
            end
        end
        member_item:FindChild("OnlineState"):GetComponent("Text").text = member_info.offline_ts and offline_text or UIConst.Text.ONLINE_TEXT
        table.insert(self.dynasty_member_item_list, member_item)
    end
    local dynasty_level_data = SpecMgrs.data_mgr:GetDynastyData(self.dynasty_base_info.dynasty_level)
    self.member_count.text = string.format(UIConst.Text.PER_VALUE, self.dynasty_base_info.member_count, dynasty_level_data.max_num)
end

function DynastyManageUI:InitManagePanel()
    self:UpdateManagePanel(self.cur_manage_op or kManageOpDict.ModifyInfo)
end

function DynastyManageUI:UpdateManagePanel(manage_op)
    if self.cur_manage_op and self.cur_manage_op ~= manage_op then
        local last_manage_op_data = self.manage_op_data_dict[self.cur_manage_op]
        last_manage_op_data.btn_cmp.interactable = true
        last_manage_op_data.select:SetActive(false)
        last_manage_op_data.content:SetActive(false)
    end
    self.cur_manage_op = manage_op
    local cur_manage_op_data = self.manage_op_data_dict[self.cur_manage_op]
    cur_manage_op_data.btn_cmp.interactable = false
    cur_manage_op_data.select:SetActive(true)
    cur_manage_op_data.init_func(self)
    cur_manage_op_data.content:SetActive(true)
end

function DynastyManageUI:InitModifyInfoPanel()
    UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetDynastyBadgeData(self.dynasty_base_info.dynasty_badge).icon, self.dynasty_basic_icon)
    self.dynasty_basic_name.text = self.dynasty_base_info.dynasty_name
    self.dynasty_basic_level.text = string.format(UIConst.Text.LEVEL_FORMAT_TEXT, self.dynasty_base_info.dynasty_level)
    local dynasty_level_data = SpecMgrs.data_mgr:GetDynastyData(self.dynasty_base_info.dynasty_level)
    local dynasty_next_level_data = SpecMgrs.data_mgr:GetDynastyData(self.dynasty_base_info.dynasty_level + 1)
    if not dynasty_next_level_data then
        self.dynasty_basic_exp.fillAmount = 1
        self.dynasty_basic_exp_value.text = string.format(UIConst.Text.PER_VALUE, self.dynasty_base_info.dynasty_exp - dynasty_level_data.total_exp, UIConst.Text.MAX_VALUE)
    else
        self.dynasty_basic_exp.fillAmount = (self.dynasty_base_info.dynasty_exp - dynasty_level_data.total_exp) / (dynasty_next_level_data.exp)
        self.dynasty_basic_exp_value.text = string.format(UIConst.Text.PER_VALUE, self.dynasty_base_info.dynasty_exp - dynasty_level_data.total_exp, dynasty_next_level_data.exp)
    end
    self.dynasty_declaration_input.text = self.dynasty_base_info.dynasty_declaration
    self.dynasty_announcement_input.text = self.dynasty_base_info.dynasty_notice
end

function DynastyManageUI:InitHandleApplyPanel()
    local dynasty_level_data = SpecMgrs.data_mgr:GetDynastyData(self.dynasty_base_info.dynasty_level)
    self.handle_apply_member_count.text = string.format(UIConst.Text.PER_VALUE, self.dynasty_base_info.member_count, dynasty_level_data.max_num)
    self:ClearDynastyApplyItem()
    local apply_list = self.dy_dynasty_data:GetDynastyApplyList()
    local apply_count = #apply_list
    self.empty_apply:SetActive(apply_count <= 0)
    self.apply_content:SetActive(apply_count > 0)
    for _, apply_info in ipairs(apply_list) do
        local apply_item = self:GetUIObject(self.apply_item, self.apply_list_content)
        local role_unit_id = SpecMgrs.data_mgr:GetRoleLookData(apply_info.role_id).unit_id
        UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetUnitData(role_unit_id).icon, apply_item:FindChild("IconBg/Icon"):GetComponent("Image"))
        apply_item:FindChild("Name"):GetComponent("Text").text = apply_info.name
        apply_item:FindChild("Vip"):GetComponent("Text").text = string.format(UIConst.Text.VIP, apply_info.vip)
        apply_item:FindChild("Score"):GetComponent("Text").text = UIFuncs.AddCountUnit(apply_info.fight_score)
        apply_item:FindChild("Level"):GetComponent("Text").text = apply_info.level
        self:AddClick(apply_item:FindChild("AgreeBtn"), function ()
            self:AgreeApply(apply_info.uuid)
        end)
        self:AddClick(apply_item:FindChild("IgnoreBtn"), function ()
            self:IgnoreApply(apply_info.uuid)
        end)
        table.insert(self.dynasty_apply_item_list, apply_item)
    end
    self.apply_count.text = string.format(UIConst.Text.APPLY_COUNT_FORMAT, apply_count)
end

function DynastyManageUI:InitManageMemberPanel()
    local dynasty_level_data = SpecMgrs.data_mgr:GetDynastyData(self.dynasty_base_info.dynasty_level)
    self.member_manage_count.text = string.format(UIConst.Text.PER_VALUE, self.dynasty_base_info.member_count, dynasty_level_data.max_num)
    self.dynasty_disband_disable:SetActive(self.self_member_info.job ~= CSConst.DynastyJob.GodFather)
    self.dynasty_disband_btn_cmp.interactable = self.self_member_info.job == CSConst.DynastyJob.GodFather
    local self_uuid = ComMgrs.dy_data_mgr:ExGetRoleUuid()
    self:ClearManageMemberItem()
    for _, member_info in ipairs(self.dynasty_member_list) do
        local job_data = SpecMgrs.data_mgr:GetDynastyJobData(member_info.job)
        local manage_member_item = self:GetUIObject(self.manage_member_item, self.manage_member_list_content)
        local role_unit_id = SpecMgrs.data_mgr:GetRoleLookData(member_info.role_id).unit_id
        UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetUnitData(role_unit_id).icon, manage_member_item:FindChild("IconBg/Icon"):GetComponent("Image"))
        manage_member_item:FindChild("Name"):GetComponent("Text").text = member_info.name
        manage_member_item:FindChild("Vip"):GetComponent("Text").text = string.format(UIConst.Text.VIP, member_info.vip)
        manage_member_item:FindChild("Score"):GetComponent("Text").text = UIFuncs.AddCountUnit(member_info.fight_score)
        manage_member_item:FindChild("Level"):GetComponent("Text").text = member_info.level
        manage_member_item:FindChild("Contribution"):GetComponent("Text").text = member_info.history_dedicate
        manage_member_item:FindChild("Self"):SetActive(member_info.uuid == self_uuid)
        manage_member_item:FindChild("Permission"):SetActive(member_info.uuid ~= self_uuid and member_info.job ~= CSConst.DynastyJob.Member and self.self_member_info.job == CSConst.DynastyJob.SecondChief)
        manage_member_item:FindChild("IconBg/Job/Text"):GetComponent("Text").text = string.format(UIConst.Text.SIMPLE_COLOR, job_data.job_color, job_data.name)
        local appoint_btn = manage_member_item:FindChild("AppointBtn")
        appoint_btn:SetActive(member_info.uuid ~= self_uuid and not(member_info.job ~= CSConst.DynastyJob.Member and self.self_member_info.job == CSConst.DynastyJob.SecondChief))
        self:AddClick(appoint_btn, function ()
            self:InitAppointPanel(member_info)
        end)
        table.insert(self.manage_member_item_list, manage_member_item)
    end
end

function DynastyManageUI:InitSelectBadgePanel()
    self.cur_select_badge = self.dynasty_base_info.dynasty_badge
    UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetDynastyBadgeData(self.cur_select_badge).icon, self.cur_badge)
    self:ClearBadgeItem()
    local badge_list = SpecMgrs.data_mgr:GetAllDynastyBadgeData()
    for _, badge_data in ipairs(badge_list) do
        local badge_item = self:GetUIObject(self.badge_item, self.badge_selection_content)
        UIFuncs.AssignSpriteByIconID(badge_data.icon, badge_item:GetComponent("Image"))
        self:AddClick(badge_item, function ()
            if self.cur_select_badge ~= badge_data.id then
                self.cur_select_badge = badge_data.id
                UIFuncs.AssignSpriteByIconID(badge_data.icon, self.cur_badge)
            end
        end)
        table.insert(self.badge_item_list, badge_item)
    end
    self.submit_change_text.text = self.dynasty_base_info.is_init_badge and UIConst.Text.CHANGE_BADGE_FOR_FREE or UIConst.Text.CONFIRM
    self.change_badge_panel:SetActive(true)
end

function DynastyManageUI:InitAppointPanel(member_info)
    local role_unit_id = SpecMgrs.data_mgr:GetRoleLookData(member_info.role_id).unit_id
    UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetUnitData(role_unit_id).icon, self.cur_member_icon)
    self.cur_member_name.text = member_info.name
    self.cur_member_vip.text = string.format(UIConst.Text.VIP, member_info.vip)
    self.appoint_godfather_btn:SetActive(member_info.job == CSConst.DynastyJob.SecondChief)
    self.appoint_second_handle_btn:SetActive(self.self_member_info.job ~= CSConst.DynastyJob.SecondChief)
    self.appoint_second_handle_btn:GetComponent("Button").interactable = member_info.job ~= CSConst.DynastyJob.SecondChief
    self.appoint_member_btn:SetActive(true)
    self.appoint_member_btn:GetComponent("Button").interactable = member_info.job ~= CSConst.DynastyJob.Member
    self.appoint_kick_btn:SetActive(member_info.job == CSConst.DynastyJob.Member)
    if member_info.job == CSConst.DynastyJob.SecondChief then
        self.appoint_second_handle_state.text = UIConst.Text.CUR_JOB
        self.appoint_member_state.text = UIConst.Text.JOB_SELECT
    elseif member_info.job == CSConst.DynastyJob.Member then
        self.appoint_member_state.text = UIConst.Text.CUR_JOB
        if self.second_handle_count >= SpecMgrs.data_mgr:GetDynastyJobData(CSConst.DynastyJob.SecondChief).max_num then
            self.appoint_second_handle_btn:GetComponent("Button").interactable = false
            self.appoint_second_handle_state.text = UIConst.Text.JOB_FULL
        else
            self.appoint_second_handle_state.text = UIConst.Text.JOB_SELECT
        end
    end
    if self.cur_appoint_selection then
        self.appoint_btn_select_dict[self.cur_appoint_selection]:SetActive(false)
        self.cur_appoint_selection = nil
    end
    self.cur_appoint_member = member_info
    self.appoint_panel:SetActive(true)
end

function DynastyManageUI:UpdateAppointBtnState(appoint_op)
    if self.cur_appoint_selection == appoint_op then return end
    if self.cur_appoint_selection then
        self.appoint_btn_select_dict[self.cur_appoint_selection]:SetActive(false)
    end
    self.cur_appoint_selection = appoint_op
    self.appoint_btn_select_dict[self.cur_appoint_selection]:SetActive(true)
end

-- msg
function DynastyManageUI:ModifyDynastyName()
    if self.dy_bag_data:GetBagItemCount(self.modify_name_cost_data.item_id) < self.modify_name_cost_data.count then
        local item_data = SpecMgrs.data_mgr:GetItemData(self.modify_name_cost_data.item_id)
        SpecMgrs.ui_mgr:ShowMsgBox(string.format(UIConst.Text.ITEM_NOT_ENOUGH, item_data.name))
        return
    end
    local new_name = self.rename_input.text
    if new_name == self.dynasty_base_info.dynasty_name then
        self.rename_panel:SetActive(false)
        return
    end
    local name_len = string.len(new_name)
    if name_len > self.dynasty_name_max_len or name_len < self.dynasty_name_min_len then
        SpecMgrs.ui_mgr:ShowMsgBox(string.format(UIConst.Text.DYNASTY_NAME_LEN_ILLEGAL, self.dynasty_name_min_len, self.dynasty_name_max_len))
        return
    end
    if string.sub(new_name, 1, 1) == " " or string.sub(new_name, -1, -1) == " " then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.DYNASTY_NAME_SPACE_IN_BOTH_END)
        return
    end
    if string.find(new_name, "  ") then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.DYNASTY_NAME_SPACE_IN_ROW)
        return
    end
    SpecMgrs.msg_mgr:SendModifyDynastyName({dynasty_name = new_name}, function (resp)
        if resp.errcode == 0 then
            self.rename_panel:SetActive(false)
            self:UpdateDynastyInfo()
        else
            if resp.name_repeat then SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.DYNASTY_NAME_REPEAT) end
        end
    end)
end

function DynastyManageUI:ModifyDynastyBadge()
    local confirm_cb = function ()
        SpecMgrs.msg_mgr:SendModifyDynastyBadge({dynasty_badge = self.cur_select_badge}, function (resp)
            if resp.errcode ~= 0 then
                SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.MODIFY_BADGE_FAILED)
            else
                self.change_badge_panel:SetActive(false)
                self:UpdateDynastyInfo()
            end
        end)
    end
    if self.dynasty_base_info.is_init_badge then
        confirm_cb()
    else
        local cost_item_data = SpecMgrs.data_mgr:GetItemData(self.modify_badge_cost_data.item_id)
        local data = {
            title = UIConst.Text.MODIFY_DYNASTY_BADGE,
            item_id = self.modify_badge_cost_data.item_id,
            need_count = self.modify_badge_cost_data.count,
            desc = string.format(UIConst.Text.MODIFY_DYNASTY_BADGE_FORMAT, cost_item_data.name, self.modify_badge_cost_data.count),
            remind_tag = "DynastyModifyBadge",
            confirm_cb = confirm_cb,
        }
        SpecMgrs.ui_mgr:ShowItemUseRemindByTb(data)
    end
end

function DynastyManageUI:SaveModifyDynastyDeclaration()
    local declaration_content = self.dynasty_declaration_input.text
    if declaration_content == self.dynasty_base_info.dynasty_declaration then
        return
    end
    if UTF8.Len(declaration_content) > self.declaration_len_limit then
        SpecMgrs.ui_mgr:ShowMsgBox(string.format(UIConst.Text.OVER_LEN_LIMIT, UIConst.Text.DYNASTY_DECLARATION_TEXT))
        return
    end
    SpecMgrs.msg_mgr:SendModifyDynastyDeclaration({dynasty_declaration = FilterBadWord(declaration_content)}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(string.format(UIConst.Text.MODIFY_FAILED_FORMAT, UIConst.Text.DYNASTY_DECLARATION_TEXT))
        else
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.MODIFY_INFO_SUCCESS)
            self:UpdateDynastyInfo()
        end
    end)
end

function DynastyManageUI:SaveModifyDynastyAnnouncement()
    local announcement_content = self.dynasty_announcement_input.text
    if announcement_content == self.dynasty_base_info.dynasty_notice then
        return
    end
    if UTF8.Len(announcement_content) > self.declaration_len_limit then
        SpecMgrs.ui_mgr:ShowMsgBox(string.format(UIConst.Text.OVER_LEN_LIMIT, UIConst.Text.DYNASTY_ANNOUNCEMENT_TEXT))
        return
    end
    SpecMgrs.msg_mgr:SendModifyDynastyNotice({dynasty_notice = FilterBadWord(announcement_content)}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(string.format(UIConst.Text.MODIFY_FAILED_FORMAT, UIConst.Text.DYNASTY_ANNOUNCEMENT_TEXT))
        else
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.MODIFY_INFO_SUCCESS)
            self:UpdateDynastyInfo()
        end
    end)
end

function DynastyManageUI:AgreeApply(apply_uuid)
    SpecMgrs.msg_mgr:SendAgreeApplyDynasty({member_uuid = apply_uuid}, function (resp)
        if resp.errcode and resp.tips_id then
            local err_tip = UIConst.AgreeDynastyApplyErrorTips[resp.tips_id]
            if err_tip then SpecMgrs.ui_mgr:ShowTipMsg(err_tip) end
        end
        self:UpdateDynastyInfo()
    end)
end

function DynastyManageUI:IgnoreApply(apply_uuid)
    SpecMgrs.msg_mgr:SendIgnoreApplyDynasty({member_uuid = apply_uuid}, function (resp)
        self:UpdateDynastyInfo()
    end)
end

function DynastyManageUI:SendAppointMember()
    if not self.cur_appoint_selection then return end
    if self.cur_appoint_selection == kAppointOpDict.Kick then
        SpecMgrs.msg_mgr:SendKickMember({member_uuid = self.cur_appoint_member.uuid}, function (resp)
            self:UpdateDynastyInfo()
        end)
    else
        SpecMgrs.msg_mgr:SendAppointMember({member_uuid = self.cur_appoint_member.uuid, job = self.cur_appoint_selection}, function (resp)
            if resp.errcode ~= 0 then
                SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.APPOINT_FAILED)
            end
            self:UpdateDynastyInfo()
        end)
    end
    self.appoint_btn_select_dict[self.cur_appoint_selection]:SetActive(false)
    self.cur_appoint_selection = nil
end

function DynastyManageUI:DisbandDynasty()
    if #self.dynasty_member_list > 1 then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.DYNASTY_DISBAND_MEMBER_LIMIT)
        return
    end
    local content = string.format(UIConst.Text.DISBAND_DYNASTY_SUBMIT, self.dynasty_base_info.dynasty_name)
    local confirm_cb = function ()
        SpecMgrs.msg_mgr:SendDissolveDynasty({}, function (resp)
            if resp.errcode ~= 0 then
                SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.DISBAND_DYNASTY_FAILED)
            else
                self.dy_dynasty_data:SetDynastyId()
                SpecMgrs.ui_mgr:HideUI("DynastyUI")
                self:Hide()
            end
        end)
    end
    SpecMgrs.ui_mgr:ShowMsgSelectBox({content = content, confirm_cb = confirm_cb})
end

--clear
function DynastyManageUI:ClearDynastyMemberItem()
    for _, member_item in ipairs(self.dynasty_member_item_list) do
        self:DelUIObject(member_item)
    end
    self.dynasty_member_item_list = {}
end

function DynastyManageUI:ClearDynastyApplyItem()
    for _, apply_item in ipairs(self.dynasty_apply_item_list) do
        self:DelUIObject(apply_item)
    end
    self.dynasty_apply_item_list = {}
end

function DynastyManageUI:ClearManageMemberItem()
    for _, member_item in ipairs(self.manage_member_item_list) do
        self:DelUIObject(member_item)
    end
    self.manage_member_item_list = {}
end

function DynastyManageUI:ClearBadgeItem()
    for _, badge_item in ipairs(self.badge_item_list) do
        self:DelUIObject(badge_item)
    end
    self.badge_item_list = {}
end

function DynastyManageUI:Close()
    if self.cur_tab then
        local last_tab_btn_data = self.tab_btn_data_dict[self.cur_tab]
        last_tab_btn_data.btn_cmp.interactable = true
        last_tab_btn_data.select:SetActive(false)
        last_tab_btn_data.content:SetActive(false)
        self.cur_tab = nil
    end
    if self.cur_manage_op then
        local last_manage_op_data = self.manage_op_data_dict[self.cur_manage_op]
        last_manage_op_data.btn_cmp.interactable = true
        last_manage_op_data.select:SetActive(false)
        last_manage_op_data.content:SetActive(false)
        self.cur_manage_op = nil
    end
    self:ClearDynastyMemberItem()
    self:ClearDynastyApplyItem()
    self:ClearManageMemberItem()
    self:ClearBadgeItem()
end

return DynastyManageUI