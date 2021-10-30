local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local UnitConst = require("Unit.UnitConst")

local ChildCenterUI = class("UI.ChildCenterUI", UIBase)

local kDialogVerticalPadding = 60
local kDialogHorizontalPadding = 60
local kChildDialogTextMaxWidth = 380
local kBabyDialogTextMaxWidth = 300
local kDialogArrowOffset = 8
local kCultivateEffectTime = 1
local anchor_v2 = Vector2.New(1, 1)
local raising_redpoint_control_id = {CSConst.RedPointControlIdDict.Child.Raising}

function ChildCenterUI:DoInit()
    ChildCenterUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ChildCenterUI"
    self.dy_bag_data = ComMgrs.dy_data_mgr.bag_data
    self.dy_child_center_data = ComMgrs.dy_data_mgr.child_center_data
    self.dy_lover_data = ComMgrs.dy_data_mgr.lover_data
    self.cur_select_child_id = 0
    self.child_go_dict = {}
    self.empty_child_dict = {}
    self.unlock_easy_teach_grid_count = SpecMgrs.data_mgr:GetParamData("child_unlock_easyteach_grid_count").f_value
    self.max_aptitude_count = SpecMgrs.data_mgr:GetParamData("hero_max_aptitude_count").f_value
    self.child_vitality_item_id = SpecMgrs.data_mgr:GetParamData("child_vitality_restore").item_id
    self.baby_vitality_item_id = SpecMgrs.data_mgr:GetParamData("child_baby_vitality_restore").item_id
    self.child_rename_cost_count = SpecMgrs.data_mgr:GetParamData("child_rename_count").f_value
    self.child_grow_up_level = SpecMgrs.data_mgr:GetParamData("child_grow_up_level").f_value
    self.new_baby_list = {}
    self.cultivate_effect_delegate_tb = {}
    self.redpoint_list = {}
end

function ChildCenterUI:OnGoLoadedOk(res_go)
    ChildCenterUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function ChildCenterUI:Show(child_data)
    self.child_data = child_data
    if self.is_res_ok then
        self:InitUI()
    end
    ChildCenterUI.super.Show(self)
end

function ChildCenterUI:Hide()
    self.cur_select_child_id = 0
    self.is_wait_for_effect = false
    self.new_baby_list = {}
    self:ClearChildGo()
    self:ClearChildUnit()
    self.dy_child_center_data:UnregisterUpdateChildInfoEvent("ChildCenterUI")
    self.dy_child_center_data:UnregisterChildGrowUpEvent("ChildCenterUI")
    self.dy_child_center_data:UnregisterChildSubmitAptitudeEvent("ChildCenterUI")
    ChildCenterUI.super.Hide(self)
end

function ChildCenterUI:InitRes()
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "ChildCenterUI")
    -- 婴儿命名面板
    self.name_baby_panel = self.main_panel:FindChild("NameBabyPanel")
    local nanny_img = self.name_baby_panel:FindChild("NannyImage")
    nanny_img:FindChild("NannyDialog/Text"):GetComponent("Text").text = UIConst.Text.NAME_TEXT
    self.nanny_anim_cmp = nanny_img:FindChild("Nanny"):GetComponent("SkeletonGraphic").AnimationState
    local name_baby_info_panel = self.name_baby_panel:FindChild("BabyInfoPanel")
    self.name_baby_icon = name_baby_info_panel:FindChild("BabyIcon"):GetComponent("Image")
    name_baby_info_panel:FindChild("MotherInfo/Text"):GetComponent("Text").text = UIConst.Text.MOTHER_TEXT
    self.name_mother_name = name_baby_info_panel:FindChild("MotherInfo/MotherName"):GetComponent("Text")
    name_baby_info_panel:FindChild("IntimatePanel/Text"):GetComponent("Text").text = UIConst.Text.INTIMACY_VAL_TEXT
    self.name_intimate_count = name_baby_info_panel:FindChild("IntimatePanel/Intimate/Count"):GetComponent("Text")
    name_baby_info_panel:FindChild("TalentTitlePanel/Text"):GetComponent("Text").text = UIConst.Text.TALENT_TEXT
    self.name_talent_title = name_baby_info_panel:FindChild("TalentTitlePanel/TalentTitle"):GetComponent("Text")
    self.name_baby_panel:FindChild("NameInput/Placeholder"):GetComponent("Text").text = UIConst.Text.BABY_NAME_INPUT
    self.name_input = self.name_baby_panel:FindChild("NameInput"):GetComponent("InputField")
    self.random_name_btn = self.name_baby_panel:FindChild("NameInput/RandomNameBtn")
    self.random_name_btn_cmp = self.random_name_btn:GetComponent("Button")
    self:AddClick(self.random_name_btn, function ()
        local child_data = self.dy_child_center_data:GetChildDataById(self.cur_select_child_id)
        local name_list = SpecMgrs.data_mgr:GetChildNameListBySex(child_data.sex)
        self.name_input.text = name_list[math.round(math.Random(1, #name_list))]
    end)
    local submit_name_btn = self.name_baby_panel:FindChild("SubmitNameBtn")
    self.submit_name_btn_cmp = submit_name_btn:GetComponent("Button")
    submit_name_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CONFIRM
    self:AddClick(submit_name_btn, function ()
        local name = self.name_input.text
        if not self.dy_child_center_data:CheckChildNamelegality(name) then return end
        self.random_name_btn_cmp.interactable = false
        self.submit_name_btn_cmp.interactable = false
        SpecMgrs.msg_mgr:SendChildGiveName({child_id = self.cur_select_child_id, name = name}, function (resp)
            if resp.errcode ~= 0 then
                SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.NAME_FAILED)
                self.random_name_btn_cmp.interactable = true
                self.submit_name_btn_cmp.interactable = true
            else
                table.remove(self.new_baby_list, 1)
                self:InitNameBaby()
            end
        end)
    end)
    self.name_baby_panel:SetActive(false)
    -- 培育的主界面
    self.cultivate_panel = self.main_panel:FindChild("CultivatePanel")
    self.effect_mask = self.cultivate_panel:FindChild("EffectMask")
    self.idle_panel = self.cultivate_panel:FindChild("IdlePanel")
    self.idle_panel:FindChild("IdleDialog/Text"):GetComponent("Text").text = UIConst.Text.CHILD_IDLE_TEXT
    self:AddClick(self.idle_panel:FindChild("GoToBtn"), function ()
        local celebrity_hotel_ui = SpecMgrs.ui_mgr:GetUI("CelebrityHotelUI")
        if celebrity_hotel_ui then celebrity_hotel_ui:Hide() end
        SpecMgrs.ui_mgr:ShowUI("CelebrityHotelUI")
    end)
    self.child_panel = self.cultivate_panel:FindChild("ChildPanel")
    self.child_model_panel = self.child_panel:FindChild("ChildModel")
    self.child_model = self.child_model_panel:FindChild("ChildImg")
    self.child_cultivate_effect = self.child_model_panel:FindChild("kids_sj")
    self.child_dialog_rect = self.child_model_panel:FindChild("ChildDialog"):GetComponent("RectTransform")
    self.child_dialog_arrow_rect = self.child_model_panel:FindChild("ChildDialog/Image"):GetComponent("RectTransform")
    self.child_dialog = self.child_model_panel:FindChild("ChildDialog/DialogText"):GetComponent("Text")
    self.baby_img = self.child_panel:FindChild("BabyImg")
    self.baby_cultivate_effect = self.baby_img:FindChild("kids_sj")
    self.baby_dialog_rect = self.baby_img:FindChild("ChildDialog"):GetComponent("RectTransform")
    self.baby_dialog_arrow_rect = self.baby_img:FindChild("ChildDialog/Image"):GetComponent("RectTransform")
    self.baby_dialog = self.baby_img:FindChild("ChildDialog/DialogText"):GetComponent("Text")
        --孩子信息面板
    self.child_info_panel = self.child_panel:FindChild("ChildInfoPanel")
    local name_panel = self.child_info_panel:FindChild("NamePanel")
    self:AddClick(name_panel:FindChild("DetailInfoBtn"), function ()
        self.child_detail_info_panel:SetActive(true)
        self:InitChildDetailInfo()
    end)
    self.child_info_name = name_panel:FindChild("Name"):GetComponent("Text")
    self:AddClick(name_panel:FindChild("RenameBtn"), function ()
        self.rename_input.text = ""
        self.rename_panel:SetActive(true)
    end)
    local info_panel = self.child_info_panel:FindChild("InfoPanel")
    info_panel:FindChild("MotherPanel/Text"):GetComponent("Text").text = UIConst.Text.MOTHER_TEXT
    self.child_mother_name = info_panel:FindChild("MotherPanel/MotherName"):GetComponent("Text")
    info_panel:FindChild("IntimatePanel/Text"):GetComponent("Text").text = UIConst.Text.INTIMACY_TEXT
    self.child_intimate_count = info_panel:FindChild("IntimatePanel/Intimate/Count"):GetComponent("Text")
    info_panel:FindChild("TalentTitlePanel/Text"):GetComponent("Text").text = UIConst.Text.TALENT_TEXT
    self.child_talent_title = info_panel:FindChild("TalentTitlePanel/TalentTitle"):GetComponent("Text")
    info_panel:FindChild("TotalAptitudePanel/Text"):GetComponent("Text").text = UIConst.Text.TOTAL_APTITUDE
    self.child_total_aptitude = info_panel:FindChild("TotalAptitudePanel/TotalAptitude"):GetComponent("Text")
    info_panel:FindChild("TotalAttrPanel/Text"):GetComponent("Text").text = UIConst.Text.TOTAL_ATTR
    self.child_total_attr = info_panel:FindChild("TotalAttrPanel/TotalAttr"):GetComponent("Text")
    local child_level_panel = info_panel:FindChild("LevelPanel")
    child_level_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.LEVEL_TEXT
    self.child_level = child_level_panel:FindChild("Level"):GetComponent("Text")
    self.child_exp_bar = child_level_panel:FindChild("ExpBar")
    self.child_exp_value = self.child_exp_bar:FindChild("Image"):GetComponent("Image")
    self.child_exp_text = self.child_exp_bar:FindChild("ExpValue"):GetComponent("Text")
    local vitality_panel = self.child_info_panel:FindChild("VitalityPanel")
        -- 没有活力显示的面板
    self.no_vitality_panel = vitality_panel:FindChild("NoVitalityPanel")
    self.restore_rest_time = self.no_vitality_panel:FindChild("RestoreRestTime"):GetComponent("Text")
    local restore_btn = self.no_vitality_panel:FindChild("RestoreBtn")
    restore_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.RECOVER
    self:AddClick(restore_btn, function ()
        self:SendUseChildItem()
    end)
        -- 有活力的面板
    self.have_vitality_panel = vitality_panel:FindChild("HaveVitalityPanel")
    self.vitality_count = self.have_vitality_panel:FindChild("VitalityCount/Text"):GetComponent("Text")
    local teach_btn = self.have_vitality_panel:FindChild("TeachBtn")
    teach_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.TEACH_TEXT
    self:AddClick(teach_btn, function ()
        self:ChildLevelUp(self.cur_select_child_id)
    end)
        -- 满级等待封爵面板
    self.child_full_level_panel = vitality_panel:FindChild("FullLevelPanel")
    self.child_full_level_panel:FindChild("Image/Text"):GetComponent("Text").text = UIConst.Text.WAIT_FOR_SEAL
    local seal_btn = self.child_full_level_panel:FindChild("SealBtn")
    seal_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SEAL_TEXT
    self:AddClick(seal_btn, function ()
        self:ChildCanonized(self.cur_select_child_id)
    end)
        --婴儿信息面板
    self.baby_info_panel = self.child_panel:FindChild("BabyInfoPanel")
    name_panel = self.baby_info_panel:FindChild("NamePanel")
    self.baby_name = name_panel:FindChild("Name"):GetComponent("Text")
    self:AddClick(name_panel:FindChild("RenameBtn"), function ()
        self.rename_input.text = ""
        self.rename_panel:SetActive(true)
    end)
    info_panel = self.baby_info_panel:FindChild("InfoPanel")
    info_panel:FindChild("MotherPanel/Text"):GetComponent("Text").text = UIConst.Text.MOTHER_TEXT
    self.baby_mother_name = info_panel:FindChild("MotherPanel/MotherName"):GetComponent("Text")
    info_panel:FindChild("IntimatePanel/Text"):GetComponent("Text").text = UIConst.Text.INTIMACY_TEXT
    self.baby_intimate_count = info_panel:FindChild("IntimatePanel/Intimate/Count"):GetComponent("Text")
    info_panel:FindChild("Image/Text"):GetComponent("Text").text = UIConst.Text.BABY_DESC
    info_panel:FindChild("TalentTitlePanel/Text"):GetComponent("Text").text = UIConst.Text.TALENT_TEXT
    self.baby_talent_title = info_panel:FindChild("TalentTitlePanel/TalentTitle"):GetComponent("Text")
    local grow_panel = self.baby_info_panel:FindChild("GrowPanel")
    self.accelerate_panel = grow_panel:FindChild("AcceleratePanel")
    self.grow_rest_time = self.accelerate_panel:FindChild("GrowRestTime"):GetComponent("Text")
    self.accelerate_btn = self.accelerate_panel:FindChild("AccelerateBtn")
    self.accelerate_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ACCELERATE
    self:AddClick(self.accelerate_btn, function ()
        SpecMgrs.ui_mgr:ShowItemUseRemindByTb({
            item_id = self.baby_vitality_item_id,
            need_count = 1,
            confirm_cb = function ()
                SpecMgrs.msg_mgr:SendChildUseItem({child_id = self.cur_select_child_id}, function (resp)
                    if resp.errcode ~= 0 then
                        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.ITEM_USE_FAILED)
                    end
                end)
            end,
            remind_tag = "AccelerateBaby",
            is_show_tip = true,
        })
    end)
    self.baby_full_level_panel = grow_panel:FindChild("FullLevelPanel")
    self.baby_full_level_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.WAIT_FOR_SUBMIT_APTITUDE
    local submit_aptitude_btn = self.baby_full_level_panel:FindChild("SubmitAptitudeBtn")
    submit_aptitude_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SUBMIT_APTITUDE
    self:AddClick(submit_aptitude_btn, function ()
        self:ChildLevelUp(self.cur_select_child_id)
    end)
    -- 孩子列表
    local child_list_panel = self.cultivate_panel:FindChild("ChildListPanel")
    child_list_panel:FindChild("Image/Text"):GetComponent("Text").text = UIConst.Text.CHILD_LIST
    self.child_list_content = child_list_panel:FindChild("ChildList/Viewport/Content")
    self.child_content_rect = self.child_list_content:GetComponent("RectTransform")
    self.child_btn_list = self.child_list_content:FindChild("ChildBtnList")
    self.child_btn_pref = self.child_btn_list:FindChild("ChildBtnPref")
    self.child_btn_pref:FindChild("ChildBtn/StatePanel/BabyText"):GetComponent("Text").text = UIConst.Text.BABY_DESC
    self.child_btn_pref:FindChild("ChildBtn/StatePanel/Zhuazhou"):GetComponent("Text").text = UIConst.Text.SUBMIT_APTITUDE
    self.child_btn_pref:FindChild("ChildBtn/StatePanel/FengJue"):GetComponent("Text").text = UIConst.Text.SEAL_TEXT
    self.child_btn_pref:FindChild("EmptyBtn/Image/Text"):GetComponent("Text").text = UIConst.Text.EMPTY_GRID
    self.expand_btn = self.child_list_content:FindChild("ExpandChildBtn")
    self.expand_btn:FindChild("Image/Text"):GetComponent("Text").text = UIConst.Text.CLICK_FOR_EXPAND
    self:AddClick(self.expand_btn, function ()
        self:ExpandChildGrid()
    end)
    self.bottom_panel = self.cultivate_panel:FindChild("BottomPanel")
    local shed_info_panel = self.bottom_panel:FindChild("ShedInfoPanel")
    self.shed_count = shed_info_panel:FindChild("ShedCount"):GetComponent("Text")
    self:AddClick(shed_info_panel:FindChild("ExpandShedBtn"), function ()
        self:ExpandChildGrid()
    end)
    local easy_teach_panel = self.bottom_panel:FindChild("EasyTeachPanel")
    self.easy_teach_tip = easy_teach_panel:FindChild("TipText")
    self.easy_teach_tip:GetComponent("Text").text = UIConst.Text.EASY_TEACH_TIPS
    self.easy_teach_btn = easy_teach_panel:FindChild("EasyTeachBtn")
    self.easy_teach_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.EASY_TEACH_TEXT
    self:AddClick(self.easy_teach_btn, function ()
        for _, data in ipairs(self.dy_child_center_data:GetChildList()) do
            local child_data = self.dy_child_center_data:GetChildDataById(data.child_id)
            local level_limit = SpecMgrs.data_mgr:GetChildQualityData(child_data.grade).level_limit
            for i = 1, math.min(child_data.vitality_num, level_limit - child_data.exp) do
                self:ChildLevelUp(child_data.child_id)
            end
        end
    end)
    -- 孩子详细信息面板
    self.child_detail_info_panel = self.main_panel:FindChild("ChildDetailInfo")
    local detail_info_content = self.child_detail_info_panel:FindChild("Content")
    self:AddClick(detail_info_content:FindChild("Top/CloseBtn"), function ()
        self.child_detail_info_panel:SetActive(false)
    end)
    detail_info_content:FindChild("Top/Text"):GetComponent("Text").text = UIConst.Text.DETAIL_INFO_TITLE
    local basic_info_panel = detail_info_content:FindChild("BasicInfoPanel")
    self.detail_name = basic_info_panel:FindChild("NamePanel/Name"):GetComponent("Text")
    self.detail_per_level = basic_info_panel:FindChild("NamePanel/Lv"):GetComponent("Text")
    self.detail_talent_title = basic_info_panel:FindChild("TalentTitle"):GetComponent("Text")
    local mother_info_panel = basic_info_panel:FindChild("MotherInfo")
    self.detail_mother_name = mother_info_panel:FindChild("MotherName"):GetComponent("Text")
    self.detail_intimate = mother_info_panel:FindChild("Intimate"):GetComponent("Text")
    self.detail_specialty = basic_info_panel:FindChild("Specialty"):GetComponent("Text")
    local aptitude_panel = detail_info_content:FindChild("AptitudePanel")
    self.total_aptitude = aptitude_panel:FindChild("TotalAptitudePanel/TotalAptitude"):GetComponent("Text")
    self.business_aptitude = aptitude_panel:FindChild("BusinessAptitude"):GetComponent("Text")
    self.management_aptitude = aptitude_panel:FindChild("TechnologyAptitude"):GetComponent("Text")
    self.renown_aptitude = aptitude_panel:FindChild("RenownAptitude"):GetComponent("Text")
    self.fight_aptitude = aptitude_panel:FindChild("FightAptitude"):GetComponent("Text")

    local attr_panel = detail_info_content:FindChild("AttrPanel")
    self.total_attr = attr_panel:FindChild("TotalAttrPanel/TotalAttr"):GetComponent("Text")
    self.business_attr = attr_panel:FindChild("BusinessAttr"):GetComponent("Text")
    self.management_attr = attr_panel:FindChild("TechnologyAttr"):GetComponent("Text")
    self.renown_attr = attr_panel:FindChild("RenownAttr"):GetComponent("Text")
    self.fight_attr = attr_panel:FindChild("FightAttr"):GetComponent("Text")
    detail_info_content:FindChild("Tips"):GetComponent("Text").text = UIConst.Text.DETAIL_TIPS
    --抓周面板
    self.detemine_aptitude = self.main_panel:FindChild("DetemineAptitude")
    self.detemine_baby_model = self.detemine_aptitude:FindChild("ChildModel")
    info_panel = self.detemine_aptitude:FindChild("InfoPanel")
    mother_info_panel = info_panel:FindChild("MotherInfo")
    self.detemine_mother_name = mother_info_panel:FindChild("MotherName"):GetComponent("Text")
    self.detemine_intimate = mother_info_panel:FindChild("Intimate"):GetComponent("Text")
    self.detemine_specialty = info_panel:FindChild("Specialty"):GetComponent("Text")
    aptitude_panel = info_panel:FindChild("AptitudePanel")
    self.detemine_total_aptitude = aptitude_panel:FindChild("TotalAptitude"):GetComponent("Text")
    self.detemine_business_aptitude = aptitude_panel:FindChild("BusinessAptitude"):GetComponent("Text")
    self.detemine_management_aptitude = aptitude_panel:FindChild("TechnologyAptitude"):GetComponent("Text")
    self.detemine_renown_aptitude = aptitude_panel:FindChild("RenownAptitude"):GetComponent("Text")
    self.detemine_fight_aptitude = aptitude_panel:FindChild("FightAptitude"):GetComponent("Text")
    local detemine_submit_btn = self.detemine_aptitude:FindChild("SubmitBtn")
    detemine_submit_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CONFIRM
    self:AddClick(detemine_submit_btn, function ()
        self.detemine_aptitude:SetActive(false)
    end)
    --封爵面板
    self.grow_up = self.main_panel:FindChild("GrowUp")
    self.grow_up:FindChild("Image/Logo"):GetComponent("Text").text = UIConst.Text.SEAL_LOGO_TEXT
    self.grow_up_name = self.grow_up:FindChild("Image/Name"):GetComponent("Text")
    self.grow_up_text = self.grow_up:FindChild("Image/Text"):GetComponent("Text")
    self:AddClick(self.grow_up, function ()
        self:ShowScoreUpUI()
        SpecMgrs.ui_mgr:ShowUI("GrowUpUI",self.grow_up_child)
        self.cur_select_child_id = 0
        self.grow_up_child = nil
        self.grow_up:SetActive(false)
        self:InitCultivatePanel()
    end)
    --改名面板
    self.rename_panel = self.main_panel:FindChild("RenamePanel")
    local rename_content = self.rename_panel:FindChild("Content")
    rename_content:FindChild("Title"):GetComponent("Text").text = UIConst.Text.CHILD_RENAME_TITLE
    self:AddClick(rename_content:FindChild("CloseBtn"), function ()
        self.rename_panel:SetActive(false)
    end)
    rename_content:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CHILD_RENAME_TIP
    self.rename_input = rename_content:FindChild("RenameInput"):GetComponent("InputField")
    local consumption_panel = rename_content:FindChild("Consumption")
    consumption_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.RENAME_COST_TIP
    consumption_panel:FindChild("Count"):GetComponent("Text").text = self.child_rename_cost_count
    local rename_submit_btn = rename_content:FindChild("BtnPanel/RenameSubmit")
    rename_submit_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CONFIRM
    self:AddClick(rename_submit_btn, function ()
        self:ChildRename()
    end)
    local rename_cancel_btn = rename_content:FindChild("BtnPanel/RenameCancel")
    rename_cancel_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CANCEL
    self:AddClick(rename_cancel_btn, function ()
        self.rename_panel:SetActive(false)
    end)
end

function ChildCenterUI:InitUI()
    self:InitNameBaby()
    self.child_content_rect.anchoredPosition = Vector2.zero
    self.last_score = ComMgrs.dy_data_mgr:ExGetRoleScore()
    self.last_fight_score = ComMgrs.dy_data_mgr:ExGetFightScore()
    self:RegisterEvent( ComMgrs.dy_data_mgr, "UpdateCurrencyEvent", function (_, currency)
        UIFuncs.UpdateCurrencyItemNum(self._item_to_text_list, currency)
    end)
    self:RegisterEvent(ComMgrs.dy_data_mgr.bag_data, "UpdateBagItemEvent", function (_, op, item_data)
        UIFuncs.UpdateBagItemNum(self._item_to_text_list, item_data)
    end)
    self.dy_child_center_data:RegisterUpdateChildInfoEvent("ChildCenterUI", self.InitNameBaby, self)
    self.dy_child_center_data:RegisterChildGrowUpEvent("ChildCenterUI", self.ChildGrowUp, self)
    self.dy_child_center_data:RegisterChildSubmitAptitudeEvent("ChildCenterUI", self.ChildSubmitAptitude, self)
end

function ChildCenterUI:InitNameBaby()
    self.new_baby_list = {}
    local child_list = self.dy_child_center_data:GetChildList()
    for i = #child_list, 1, -1 do
        local child_data = self.dy_child_center_data:GetChildDataById(child_list[i].child_id)
        if child_data.child_status == CSConst.ChildStatus.New then
            table.insert(self.new_baby_list, child_data)
        end
    end
    if #self.new_baby_list > 0  then
        self.cur_select_child_id = self.child_data and self.child_data.child_id or self.new_baby_list[1].child_id
        self:InitNamePanel()
        self.name_baby_panel:SetActive(true)
        self.cultivate_panel:SetActive(false)
    else
        self:InitCultivatePanel()
    end
end

function ChildCenterUI:InitCultivatePanel()
    if #self.new_baby_list > 0 then return end
    if self.is_wait_for_effect == true then return end
    self.name_baby_panel:SetActive(false)
    self.cultivate_panel:SetActive(true)
    self:InitChildList()
    self:InitBottomPanel()
end

function ChildCenterUI:UpdateChildPanel()
    local cur_select_child = self.dy_child_center_data:GetChildDataById(self.cur_select_child_id)
    self.baby_info_panel:SetActive(cur_select_child.child_status == CSConst.ChildStatus.Baby)
    self.child_info_panel:SetActive(cur_select_child.level > 0)
    local grade_data = SpecMgrs.data_mgr:GetChildQualityData(cur_select_child.grade)
    local mother_data = SpecMgrs.data_mgr:GetLoverData(cur_select_child.mother_id)
    local mother_info = self.dy_lover_data:GetLoverInfo(cur_select_child.mother_id)
    local exp_data = SpecMgrs.data_mgr:GetChildExpData(cur_select_child.level)
    local dialog_data = SpecMgrs.data_mgr:GetChildDialogData(cur_select_child.sex == CSConst.Sex.Man and exp_data.boy_dialog or exp_data.girl_dialog)
    local child_display_data = SpecMgrs.data_mgr:GetChildDisplayData(cur_select_child.display_id)

    if cur_select_child.child_status == CSConst.ChildStatus.Baby then
        self.baby_dialog.text = dialog_data.dialog_list[math.random(#dialog_data.dialog_list)]
        local text_width_in_line = self.baby_dialog.preferredWidth
        local dialog_width = text_width_in_line > kBabyDialogTextMaxWidth and kBabyDialogTextMaxWidth or text_width_in_line
        local dialog_height = self.baby_dialog.preferredHeight + kDialogVerticalPadding
        self.baby_dialog_rect.sizeDelta = Vector2.New(dialog_width + kDialogHorizontalPadding, dialog_height)
    elseif cur_select_child.level > 0 then
        self.child_dialog.text = dialog_data.dialog_list[math.random(#dialog_data.dialog_list)]
        local text_width_in_line = self.child_dialog.preferredWidth
        local dialog_width = text_width_in_line > kChildDialogTextMaxWidth and kChildDialogTextMaxWidth or text_width_in_line
        local dialog_height = self.child_dialog.preferredHeight + kDialogVerticalPadding
        self.child_dialog_rect.sizeDelta = Vector2.New(dialog_width + kDialogHorizontalPadding, dialog_height)
    end

    self.baby_img:SetActive(cur_select_child.child_status == CSConst.ChildStatus.Baby)
    self.child_model_panel:SetActive(cur_select_child.child_status ~= CSConst.ChildStatus.Baby)
    if cur_select_child.child_status == CSConst.ChildStatus.Baby then -- 襁褓期
        UIFuncs.AssignSpriteByIconID(child_display_data.baby_img, self.baby_img:GetComponent("Image"))
        self.baby_name.text = cur_select_child.name
        self.baby_mother_name.text = mother_data.name
        self.baby_intimate_count.text = mother_info.level
        self.baby_talent_title.text = grade_data.text
        self.accelerate_panel:SetActive(cur_select_child.vitality_num == 0)
        self.baby_full_level_panel:SetActive(cur_select_child.child_status == CSConst.ChildStatus.Baby and cur_select_child.vitality_num > 0)
        if cur_select_child.vitality_num == 0 then
            self:AddDynamicUI(self.grow_rest_time, function ()
                if (exp_data.cooldown + cur_select_child.last_time - Time:GetServerTime()) < 0 then
                    self:RemoveDynamicUI(self.grow_rest_time)
                    self:UpdateChildPanel()
                end
                self.grow_rest_time.text = UIFuncs.TimeDelta2Str(exp_data.cooldown + cur_select_child.last_time-Time:GetServerTime())
            end, 1, 0)
        end
    else
        local unit_id = self.dy_child_center_data:GetChildUnitId(cur_select_child)
        if not self.child_unit or unit_id ~= self.last_unit_id then
            if self.child_unit then ComMgrs.unit_mgr:DestroyUnit(self.child_unit) end
            local unit_data = SpecMgrs.data_mgr:GetUnitData(unit_id)
            self.child_dialog_rect.anchoredPosition = Vector2.NewByTable(unit_data.dialog_pos)
            self.child_unit = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = unit_id, parent = self.child_model})
            self.child_unit:SetPositionByRectName({parent = self.child_model, name = UnitConst.UnitRect.Full})
            self.last_unit_id = unit_id
        end

        self.child_info_name.text = cur_select_child.name
        self.child_mother_name.text = mother_data.name
        self.child_intimate_count.text = mother_info.level
        self.child_talent_title.text = grade_data.text
        local aptitude_data = cur_select_child.aptitude_dict
        self.child_total_aptitude.text = aptitude_data.business + aptitude_data.management + aptitude_data.renown + aptitude_data.fight
        local attr_data = cur_select_child.attr_dict
        self.child_total_attr.text = attr_data.business + attr_data.management + attr_data.renown + attr_data.fight
        self.child_level.text = string.format(UIConst.Text.PER_VALUE, cur_select_child.level, grade_data.level_limit)
        self.child_exp_bar:SetActive(cur_select_child.level < grade_data.level_limit)
        if cur_select_child.level < grade_data.level_limit then
            self.child_exp_value.fillAmount = cur_select_child.exp / exp_data.exp
            self.child_exp_text.text = string.format(UIConst.Text.PER_VALUE, cur_select_child.exp, exp_data.exp)
        end
        self.child_full_level_panel:SetActive(cur_select_child.child_status == CSConst.ChildStatus.Growing and cur_select_child.level == grade_data.level_limit)
        self.no_vitality_panel:SetActive(cur_select_child.level < grade_data.level_limit and cur_select_child.vitality_num == 0)
        self.have_vitality_panel:SetActive(cur_select_child.level < grade_data.level_limit and cur_select_child.vitality_num > 0)
        if cur_select_child.vitality_num == 0 then
            self:AddDynamicUI(self.restore_rest_time, function ()
                if (exp_data.cooldown + cur_select_child.last_time-Time:GetServerTime()) < 0 then
                    self:RemoveDynamicUI(self.restore_rest_time)
                    self:UpdateChildPanel()
                end
                self.restore_rest_time.text = UIFuncs.TimeDelta2Str(exp_data.cooldown + cur_select_child.last_time-Time:GetServerTime())
            end, 1, 0)
        else
            local vatality_limit = self.dy_child_center_data:GetChildVitalityLimit(cur_select_child.level)
            self.vitality_count.text = string.format(UIConst.Text.VITALITY_FORMAT, cur_select_child.vitality_num, vatality_limit)
        end
    end
end

function ChildCenterUI:InitChildList()
    self:ClearChildGo()
    local child_list = self.dy_child_center_data:GetChildList()
    local grid_data = SpecMgrs.data_mgr:GetChildGridData(self.dy_child_center_data:GetChildGridCount() + 1)
    self.expand_btn:SetActive(#child_list < #SpecMgrs.data_mgr:GetAllChildGridData() and grid_data ~= nil)
    for index, data in ipairs(child_list) do
        local child_data = self.dy_child_center_data:GetChildDataById(data.child_id)
        local child_go = self:GetUIObject(self.child_btn_pref, self.child_btn_list)
        self:SetChildGoContent(child_go, child_data)
        local child_btn = child_go:FindChild("ChildBtn")
        child_btn:SetActive(true)
        child_go:FindChild("EmptyBtn"):SetActive(false)
        self:AddClick(child_btn, function ()
            if self.cur_select_child_id and self.cur_select_child_id ~= 0 then
                self.child_go_dict[self.cur_select_child_id]:FindChild("Select"):SetActive(false)
            elseif self.cur_empty_index then
                self.empty_child_dict[self.cur_empty_index]:FindChild("Select"):SetActive(false)
            end
            child_go:FindChild("Select"):SetActive(true)
            self.child_panel:SetActive(true)
            self.idle_panel:SetActive(false)
            self.cur_empty_index = nil
            self.cur_select_child_id = child_data.child_id
            self:UpdateChildPanel()
        end)
        if self.cur_select_child_id == data.child_id or (self.cur_select_child_id == 0 and index == 1) then
            child_go:FindChild("Select"):SetActive(true)
            self.child_panel:SetActive(true)
            self.idle_panel:SetActive(false)
            self.cur_empty_index = nil
            self.cur_select_child_id = child_data.child_id
            self:UpdateChildPanel()
        end
        self.child_go_dict[child_data.child_id] = child_go
        local redpoint = SpecMgrs.redpoint_mgr:AddRedPoint(self, child_go, CSConst.RedPointType.Normal, raising_redpoint_control_id, child_data.child_id, anchor_v2, anchor_v2)
        table.insert(self.redpoint_list, redpoint)
    end
    for i = (#child_list + 1), self.dy_child_center_data:GetChildGridCount() do
        local child_go = self:GetUIObject(self.child_btn_pref, self.child_btn_list)
        child_go:FindChild("ChildBtn"):SetActive(false)
        local empty_btn = child_go:FindChild("EmptyBtn")
        empty_btn:SetActive(true)
        self:AddClick(empty_btn, function ()
            if self.cur_select_child_id then
                self.child_go_dict[self.cur_select_child_id]:FindChild("Select"):SetActive(false)
            elseif self.cur_empty_index then
                self.empty_child_dict[self.cur_empty_index]:FindChild("Select"):SetActive(false)
            end
            child_go:FindChild("Select"):SetActive(true)
            self.child_panel:SetActive(false)
            self.idle_panel:SetActive(true)
            self.cur_select_child_id = nil
            self.cur_empty_index = i
        end)
        if i == 1 then
            child_go:FindChild("Select"):SetActive(true)
            self.child_panel:SetActive(false)
            self.idle_panel:SetActive(true)
            self.cur_select_child_id = nil
            self.cur_empty_index = i
        end
        self.empty_child_dict[i] = child_go
    end
end

function ChildCenterUI:SetChildGoContent(go, child_data)
    if not go then return end
    local child_btn = go:FindChild("ChildBtn")
    child_btn:FindChild("Name"):GetComponent("Text").text = child_data.name
    local grade_data = SpecMgrs.data_mgr:GetChildQualityData(child_data.grade)
    child_btn:FindChild("Level"):GetComponent("Text").text = string.format(UIConst.Text.PER_VALUE, child_data.level, grade_data.level_limit)
    local state_panel = child_btn:FindChild("StatePanel")
    local vitality_text = state_panel:FindChild("Vitality")
    vitality_text:SetActive(child_data.level > 0 and child_data.level < grade_data.level_limit)
    state_panel:FindChild("BabyText"):SetActive(child_data.child_status == CSConst.ChildStatus.Baby and child_data.vitality_num == 0)
    state_panel:FindChild("FengJue"):SetActive(child_data.child_status == CSConst.ChildStatus.Growing and child_data.level == grade_data.level_limit)
    state_panel:FindChild("Zhuazhou"):SetActive(child_data.child_status == CSConst.ChildStatus.Baby and child_data.vitality_num > 0)
    if child_data.child_status == CSConst.ChildStatus.Growing then
        local vatality_limit = self.dy_child_center_data:GetChildVitalityLimit(child_data.level)
        vitality_text:GetComponent("Text").text = string.format(UIConst.Text.PER_VALUE, child_data.vitality_num, vatality_limit)
    end
end

function ChildCenterUI:InitBottomPanel()
    local grid_count = self.dy_child_center_data:GetChildGridCount()
    self.shed_count.text = string.format(UIConst.Text.CUR_CHILD_SLOT, self.dy_child_center_data:GetChildCount(), grid_count)
    self.easy_teach_tip:SetActive(grid_count < self.unlock_easy_teach_grid_count)
    self.easy_teach_btn:SetActive(grid_count >= self.unlock_easy_teach_grid_count)
end

function ChildCenterUI:InitNamePanel(data)
    local child_data = self.new_baby_list[1]
    local display_data = SpecMgrs.data_mgr:GetChildDisplayData(child_data.display_id)
    self.nanny_anim_cmp:PlayAnimation(0, display_data.nanny_anim, true, 0)
    UIFuncs.AssignSpriteByIconID(display_data.baby_icon, self.name_baby_icon)
    self.cur_select_child_id = child_data.child_id
    self.name_input.text = ""
    self.random_name_btn_cmp.interactable = true
    self.submit_name_btn_cmp.interactable = true
    self.name_mother_name.text = SpecMgrs.data_mgr:GetLoverData(child_data.mother_id).name
    self.name_intimate_count.text = self.dy_lover_data:GetLoverInfo(child_data.mother_id).level
    self.name_talent_title.text = SpecMgrs.data_mgr:GetChildQualityData(child_data.grade).text
end

function ChildCenterUI:InitChildDetailInfo()
    local child_data = self.dy_child_center_data:GetChildDataById(self.cur_select_child_id)
    local grade_data = SpecMgrs.data_mgr:GetChildQualityData(child_data.grade)
    local exp_data = SpecMgrs.data_mgr:GetChildExpData(child_data.level)
    self.detail_name.text = child_data.name
    self.detail_per_level.text = string.format(UIConst.Text.PER_VALUE, child_data.level, grade_data.level_limit)
    self.detail_talent_title.text = string.format(UIConst.Text.TALENT_FORMAT, grade_data.text)
    self.detail_mother_name.text = string.format(UIConst.Text.MOTHER_FORMAT_INLINE, SpecMgrs.data_mgr:GetLoverData(child_data.mother_id).name)
    self.detail_intimate.text = self.dy_lover_data:GetLoverInfo(child_data.mother_id).level
    local aptitude_data = child_data.aptitude_dict
    self.detail_specialty.text = string.format(UIConst.Text.SPECIALTY_FORMAT, self:CalcChildSpecialty(aptitude_data))
    local total_aptitude = aptitude_data.business + aptitude_data.management + aptitude_data.renown + aptitude_data.fight
    self.total_aptitude.text = string.format(UIConst.Text.TOTAL_APTITUDE_FORMAT, total_aptitude)
    self.business_aptitude.text = string.format(UIConst.Text.BUSINESS_APTITUDE_FORMAT, aptitude_data.business)
    self.management_aptitude.text = string.format(UIConst.Text.MANAGEMENT_APTITUDE_FORMAT, aptitude_data.management)
    self.renown_aptitude.text = string.format(UIConst.Text.RENOWN_APTITUDE_FORMAT, aptitude_data.renown)
    self.fight_aptitude.text = string.format(UIConst.Text.BATTLE_APTITUDE_FORMAT, aptitude_data.fight)
    local attr_data = child_data.attr_dict
    local total_attr = attr_data.business + attr_data.management + attr_data.renown + attr_data.fight
    self.total_attr.text = string.format(UIConst.Text.TOTAL_ATTR_FORMAT, total_attr)
    self.business_attr.text = string.format(UIConst.Text.BUSINESS_FORMAT, attr_data.business)
    self.management_attr.text = string.format(UIConst.Text.MANAGEMENT_FORMAT, attr_data.management)
    self.renown_attr.text = string.format(UIConst.Text.RENOWN_FORMAT, attr_data.renown)
    self.fight_attr.text = string.format(UIConst.Text.BATTLE_FORMAT, attr_data.fight)
end

function ChildCenterUI:CalcChildSpecialty(aptitude_data)
    local ret_str
    local max_aptitude_list = {}
    for key, value in pairs(aptitude_data) do
        local tb = {key = key, value = value}
        if #max_aptitude_list == 0 then
            table.insert(max_aptitude_list, tb)
        else
            if value > max_aptitude_list[1].value then
                max_aptitude_list = {}
                table.insert(max_aptitude_list, tb)
            elseif value == max_aptitude_list[1].value then
                table.insert(max_aptitude_list, tb)
            end
        end
    end
    local count = #max_aptitude_list
    if count > self.max_aptitude_count then
        ret_str = UIConst.Text.NO_SPECIALTY
    elseif count == self.max_aptitude_count then
        ret_str = string.format(UIConst.Text.AND_VALUE, SpecMgrs.data_mgr:GetAttributeData(max_aptitude_list[1].key).specialty_name, SpecMgrs.data_mgr:GetAttributeData(max_aptitude_list[2].key).specialty_name)
    else
        ret_str = SpecMgrs.data_mgr:GetAttributeData(max_aptitude_list[1].key).specialty_name
    end
    return ret_str
end

function ChildCenterUI:ChildGrowUp(_, child_data)
    self.is_wait_for_effect = true
    table.insert(self.cultivate_effect_delegate_tb, function ()
        local seal_text = SpecMgrs.data_mgr:GetChildQualityData(child_data.grade).quality_text[child_data.sex]
        self.grow_up_name.text = string.format(UIConst.Text.GROW_UP_NAME_FORMAT, child_data.name)
        self.grow_up_text.text = UIFuncs.AddFirstLineIndentation(string.format(UIConst.Text.GROW_UP_TEXT_FORMAT, seal_text))
        self.grow_up:SetActive(true)
        self.grow_up_child = child_data
        self:InitCultivatePanel()
    end)
end

function ChildCenterUI:ChildSubmitAptitude(_, child_data)
    self.is_wait_for_effect = true
    table.insert(self.cultivate_effect_delegate_tb, function ()
        self.detemine_mother_name.text = string.format(UIConst.Text.MOTHER_FORMAT_INLINE, SpecMgrs.data_mgr:GetLoverData(child_data.mother_id).name)
        self.detemine_intimate.text = self.dy_lover_data:GetLoverInfo(child_data.mother_id).level
        if self.detemine_baby_unit then self:RemoveUnit(self.detemine_baby_unit) end
        local unit_id = self.dy_child_center_data:GetChildUnitId(child_data)
        self.detemine_baby_unit = self:AddFullUnit(unit_id, self.detemine_baby_model)
        local aptitude_data = child_data.aptitude_dict
        self.detemine_specialty.text = string.format(UIConst.Text.SPECIALTY_FORMAT, self:CalcChildSpecialty(aptitude_data))
        local total_aptitude = aptitude_data.business + aptitude_data.management + aptitude_data.renown + aptitude_data.fight
        self.detemine_total_aptitude.text = string.format(UIConst.Text.TOTAL_APTITUDE_FORMAT, total_aptitude)
        self.detemine_business_aptitude.text = string.format(UIConst.Text.BUSINESS_APTITUDE_FORMAT, aptitude_data.business)
        self.detemine_management_aptitude.text = string.format(UIConst.Text.MANAGEMENT_APTITUDE_FORMAT, aptitude_data.management)
        self.detemine_renown_aptitude.text = string.format(UIConst.Text.RENOWN_APTITUDE_FORMAT, aptitude_data.renown)
        self.detemine_fight_aptitude.text = string.format(UIConst.Text.BATTLE_APTITUDE_FORMAT, aptitude_data.fight)
        self.detemine_aptitude:SetActive(true)
        self:InitCultivatePanel()
    end)
end

function ChildCenterUI:AddCultivateEffectCb(delegate)
    if self.cultivate_effect_timer then
        table.insert(self.cultivate_effect_delegate_tb, delegate)
    else
        delegate()
    end
end

-- msg  -----------------------------------------
function ChildCenterUI:ChildRename()
    local rename_text = self.rename_input.text
    if not self.dy_child_center_data:CheckChildNamelegality(rename_text) then return end
    SpecMgrs.msg_mgr:SendChildRename({child_id = self.cur_select_child_id, name = rename_text}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.RENAME_FAILED)
        else
            self.rename_panel:SetActive(false)
        end
    end)
end

function ChildCenterUI:ShowCultivateEffect(last_child_data)
    local cultivate_effect = last_child_data.child_status == CSConst.ChildStatus.Baby and self.baby_cultivate_effect or self.child_cultivate_effect
    self.effect_mask:SetActive(true)
    cultivate_effect:SetActive(true)
    self.cultivate_effect_timer = self:AddTimer(function ()
        cultivate_effect:SetActive(false)
        self.effect_mask:SetActive(false)
        self.is_wait_for_effect = false
        for _, delegate in ipairs(self.cultivate_effect_delegate_tb) do
            delegate()
        end
        self.cultivate_effect_delegate_tb = {}
        self.cultivate_effect_timer = nil
    end, kCultivateEffectTime)
end

function ChildCenterUI:ShowScoreUpUI()
    SpecMgrs.ui_mgr:ShowScoreUpUI(self.last_score, self.last_fight_score)
    self.last_score = ComMgrs.dy_data_mgr:ExGetRoleScore()
    self.last_fight_score = ComMgrs.dy_data_mgr:ExGetFightScore()
end

-- 抓周 教导和封爵
function ChildCenterUI:ChildLevelUp(child_id)
    local child_info = self.dy_child_center_data:GetChildDataById(child_id)
    ComMgrs.dy_data_mgr:ExSetIgnoreScoreUpFlag(false)
    SpecMgrs.msg_mgr:SendChildLevelUp({child_id = child_id}, function (resp)
        ComMgrs.dy_data_mgr:ExSetIgnoreScoreUpFlag(true)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.TEACH_FAILED)
        else
            self:ShowCultivateEffect(child_info)
        end
    end)
end

function ChildCenterUI:ChildCanonized(child_id)
    local child_info = self.dy_child_center_data:GetChildDataById(child_id)
    SpecMgrs.msg_mgr:SendChildCanonized({child_id = child_id}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.CANONIZED_FAILED)
        else
            self:ShowCultivateEffect(child_info)
        end
    end)
end

function ChildCenterUI:ExpandChildGrid()
    local grid_data = SpecMgrs.data_mgr:GetChildGridData(self.dy_child_center_data:GetChildGridCount() + 1)
    if not grid_data then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.EXPAND_CHILD_GRID_LIMIT)
        return
    end
    local item_data = SpecMgrs.data_mgr:GetItemData(CSConst.Virtual.Diamond)
    local cost_data = {
        item_id = CSConst.Virtual.Diamond,
        need_count = grid_data.cost_value,
        confirm_cb = function ()
            SpecMgrs.msg_mgr:SendExpandChildGrid({}, function (resp)
                if resp.errcode ~= 0 then
                    SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.EXPAND_FAILED)
                end
            end)
        end,
        remind_tag = "ExpandChildGrid",
        title = UIConst.Text.EXPAND_TEXT,
        desc = string.format(UIConst.Text.EXPAND_CHILD_GRID_FORMAT, item_data.name, grid_data.cost_value),
    }
    SpecMgrs.ui_mgr:ShowItemUseRemindByTb(cost_data)
end

function ChildCenterUI:SendUseChildItem()
    SpecMgrs.ui_mgr:ShowItemUseRemindByTb({
        item_id = self.child_vitality_item_id,
        need_count = 1,
        confirm_cb = function ()
            SpecMgrs.msg_mgr:SendChildUseItem({child_id = self.cur_select_child_id}, function (resp)
                if resp.errcode ~= 0 then
                    SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.ITEM_USE_FAILED)
                end
            end)
        end,
        remind_tag = "AccelerateChild",
        is_show_tip = true,
    })
end
--------------------------------------------------------

function ChildCenterUI:ClearChildGo()
    self:RemoveRedPointList(self.redpoint_list)
    self.redpoint_list = {}
    for _, go in pairs(self.child_go_dict) do
        go:FindChild("Select"):SetActive(false)
        self:DelUIObject(go)
    end
    for _, go in pairs(self.empty_child_dict) do
        go:FindChild("Select"):SetActive(false)
        self:DelUIObject(go)
    end
    self.child_go_dict = {}
    self.empty_child_dict = {}
end

function ChildCenterUI:ClearChildUnit()
    if self.child_unit then
        ComMgrs.unit_mgr:DestroyUnit(self.child_unit)
        self.child_unit = nil
    end
    if self.detemine_baby_unit then
        self:RemoveUnit(self.detemine_baby_unit)
        self.detemine_baby_unit = nil
    end
end

return ChildCenterUI