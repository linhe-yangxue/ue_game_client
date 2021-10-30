local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local ScrollListViewCmp = require("UI.UICmp.ScrollListViewCmp")

local JoinDynastyUI = class("UI.JoinDynastyUI", UIBase)

local kDynastyShowCount = 10
local kDynastyCountEachPage = 10

function JoinDynastyUI:DoInit()
    JoinDynastyUI.super.DoInit(self)
    self.prefab_path = "UI/Common/JoinDynastyUI"
    self.dy_dynasty_data = ComMgrs.dy_data_mgr.dynasty_data
    self.max_apply_count = SpecMgrs.data_mgr:GetParamData("dynasty_apply_num_limit").f_value
    self.dynasty_create_cost = SpecMgrs.data_mgr:GetParamData("dynasty_create_cost")
    self.dynasty_create_cost_data = SpecMgrs.data_mgr:GetItemData(self.dynasty_create_cost.item_id)
    self.dynasty_name_min_len = SpecMgrs.data_mgr:GetParamData("dynasty_name_min_len").f_value
    self.dynasty_name_max_len = SpecMgrs.data_mgr:GetParamData("dynasty_name_max_len").f_value
    self.create_dynasty_vip_limit = SpecMgrs.data_mgr:GetParamData("dynasty_create_vip").f_value
    self.dy_bag_data = ComMgrs.dy_data_mgr.bag_data
    self.dynasty_list = {}
    self.dynasty_dict = {}
    self.dynasty_item_list = {}
end

function JoinDynastyUI:OnGoLoadedOk(res_go)
    JoinDynastyUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
    self.dynasty_item_list = {}
end

function JoinDynastyUI:Hide()
    self.dynasty_item_list = {}
    self:RemoveDynamicUI(self.quit_ts)
    self:ClearDynastyItem()
    -- ComMgrs.dy_data_mgr:UnregisterUpdateCurrencyEvent("JoinDynastyUI")
    self.dy_dynasty_data:UnregisterUpdateQuitTsEvent("JoinDynastyUI")
    self.dy_dynasty_data:UnregisterJoinDynastyEvent("JoinDynastyUI")
    self.dy_dynasty_data:UnregisterUpdateApplyEvent("JoinDynastyUI")
    JoinDynastyUI.super.Hide(self)
end

function JoinDynastyUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    JoinDynastyUI.super.Show(self)
end

function JoinDynastyUI:InitRes()
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "JoinDynastyUI")

    local search_panel = self.main_panel:FindChild("SearchPanel")
    self.search_name_input = search_panel:FindChild("SearchInput"):GetComponent("InputField")
    local search_btn = search_panel:FindChild("SearchBtn")
    search_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SEARCH_TEXT
    self:AddClick(search_btn, function ()
        self:SendSeekDynasty()
    end)

    local dynasty_list_view = self.main_panel:FindChild("DynastyList/View")
    self.dynasty_list_content = dynasty_list_view:FindChild("Content")
    self.dynasty_list_cmp = ScrollListViewCmp.New()
    self.dynasty_list_cmp:DoInit(JoinDynastyUI, dynasty_list_view)
    self.dynasty_list_cmp:ListenerViewChange(function (go, index, is_add)
        if not is_add then return end
        if not self.is_in_search then
            local end_flag_index = self.dynasty_list_cmp:GetEndFlagIndex() + 1
            local start_flag_index = self.dynasty_list_cmp:GetStartFlagIndex() + 1
            if end_flag_index <= self.first_index or start_flag_index >= self.end_index then
                self.cur_page = self.cur_page + (end_flag_index < self.first_index and -1 or 1)
                self:SendGetDynastyList(self.cur_page - 1)
                self:SendGetDynastyList(self.cur_page)
                self:SendGetDynastyList(self.cur_page + 1)
            end
        end
        self:SetDynastyContent(go, index + 1)
    end)

    self.dynasty_item = self.dynasty_list_content:FindChild("DynastyItem")
    self.dynasty_item:FindChild("ApplyBtn/Text"):GetComponent("Text").text = UIConst.Text.APPLY_REQUEST_TEXT
    self.dynasty_item:FindChild("CancelApplyBtn/Text"):GetComponent("Text").text = UIConst.Text.CANCEL_APPLY_REQUEST_TEXT

    local bottom_panel = self.main_panel:FindChild("BottomPanel")
    self.quit_ts = bottom_panel:FindChild("QuitTs")
    self.quit_ts_text = self.quit_ts:GetComponent("Text")
    local create_btn = bottom_panel:FindChild("CreateBtn")
    create_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CREATE_DYNASTY_TEXT
    self:AddClick(create_btn, function ()
        self.create_name_input.text = "",
        self.create_dynasty_panel:SetActive(true)
    end)

    self.create_dynasty_panel = self.main_panel:FindChild("CreateDynastyPanel")
    local content = self.create_dynasty_panel:FindChild("Content")
    content:FindChild("Title"):GetComponent("Text").text = UIConst.Text.CREATE_DYNASTY_TEXT
    self:AddClick(content:FindChild("CloseBtn"), function ()
        self.create_dynasty_panel:SetActive(false)
    end)
    local create_name_panel = content:FindChild("NamePanel")
    create_name_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CREATE_DYNASTY_NAME_TEXT
    self.create_name_input = create_name_panel:FindChild("NameInput"):GetComponent("InputField")
    create_name_panel:FindChild("Tip"):GetComponent("Text").text = string.format(UIConst.Text.CREATE_DYNASTY_NAME_TIP, self.dynasty_name_min_len, self.dynasty_name_max_len)
    local create_condition_panel = content:FindChild("ConditionPanel")
    create_condition_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CREATE_DYNASTY_CONDITION_TEXT
    local vip_data = SpecMgrs.data_mgr:GetVipData(self.create_dynasty_vip_limit)
    UIFuncs.AssignSpriteByIconID(vip_data.icon, create_condition_panel:FindChild("Vip"):GetComponent("Image"))
    local material_condition_panel = create_condition_panel:FindChild("MaterialCondition")
    UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetItemData(self.dynasty_create_cost.item_id).icon, material_condition_panel:FindChild("Icon"):GetComponent("Image"))
    material_condition_panel:FindChild("Count"):GetComponent("Text").text = self.dynasty_create_cost.count
    local btn_panel = content:FindChild("BtnPanel")
    local create_submit_btn = btn_panel:FindChild("SubmitBtn")
    create_submit_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CREATE_TEXT
    self:AddClick(create_submit_btn, function ()
        self:SendCreateDynasty()
    end)
    local create_cancel_btn = btn_panel:FindChild("CancelBtn")
    create_cancel_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CANCEL
    self:AddClick(create_cancel_btn, function ()
        self.create_dynasty_panel:SetActive(false)
    end)
end

function JoinDynastyUI:InitUI()
    self.create_dynasty_panel:SetActive(false)
    self.search_name_input.text = ""
    local quit_ts = self.dy_dynasty_data:GetQuitTs()
    self.quit_ts:SetActive(quit_ts ~= nil)
    if quit_ts then
        self:AddDynamicUI(self.quit_ts, function ()
            self.quit_ts_text.text = string.format(UIConst.Text.JOIN_DYNASTY_COOL_DOWN, UIFuncs.TimeDelta2Str(quit_ts - Time:GetServerTime(), 3))
        end, 1, 0)
    end
    self:InitDynastyList()
    self.dy_dynasty_data:RegisterUpdateQuitTsEvent("JoinDynastyUI", self.UpdateQuitTs, self)
    self.dy_dynasty_data:RegisterJoinDynastyEvent("JoinDynastyUI", self.JoinDynasty, self)
    self.dy_dynasty_data:RegisterUpdateApplyEvent("JoinDynastyUI", self.UpdateCurDynastyItem, self)
end

function JoinDynastyUI:InitDynastyList()
    self.is_in_search = false
    self.cur_page = 1
    self.dynasty_item_list = {}
    self:SendGetDynastyList(self.cur_page, true)
    self:SendGetDynastyList(self.cur_page + 1)
end

function JoinDynastyUI:UpdateQuitTs()
    local quit_ts = self.dy_dynasty_data:GetQuitTs()
    if quit_ts then
        self:RemoveDynamicUI(self.quit_ts)
        self:AddDynamicUI(self.quit_ts, function ()
            self.quit_ts_text.text = string.format(UIConst.Text.JOIN_DYNASTY_COOL_DOWN, UIFuncs.TimeDelta2Str(quit_ts - Time:GetServerTime(), 3))
        end, 1, 0)
    else
        self:RemoveDynamicUI(self.quit_ts)
    end
end

function JoinDynastyUI:JoinDynasty()
    self:Hide()
    SpecMgrs.ui_mgr:ShowUI("DynastyUI")
end

function JoinDynastyUI:SetDynastyContent(go, index)
    if not go then return end
    local dynasty_data = self.dynasty_list[index]
    UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetDynastyBadgeData(dynasty_data.dynasty_badge).icon, go:FindChild("Icon"):GetComponent("Image"))
    go:FindChild("Name"):GetComponent("Text").text = dynasty_data.dynasty_name
    go:FindChild("ScorePanel/Text"):GetComponent("Text").text = UIFuncs.AddCountUnit(dynasty_data.dynasty_score)
    local dynasty_lv_data = SpecMgrs.data_mgr:GetDynastyData(dynasty_data.dynasty_level)
    go:FindChild("CountPanel/Text"):GetComponent("Text").text = string.format(UIConst.Text.PER_VALUE, dynasty_data.member_count, dynasty_lv_data.max_num)
    go:FindChild("CreaterName"):GetComponent("Text").text = string.format(UIConst.Text.DYNASTY_CREATER_FORMAT, dynasty_data.godfather_name)
    go:FindChild("Announcement"):GetComponent("Text").text = dynasty_data.dynasty_declaration
    local apply_data = self.dy_dynasty_data:GetApplyDataByDynastyId(dynasty_data.dynasty_id)
    local apply_btn = go:FindChild("ApplyBtn")
    apply_btn:SetActive(apply_data == nil)
    self:AddClick(apply_btn, function ()
        self:SendJoinDynastyRequest(dynasty_data.dynasty_id, go)
    end)
    local cancel_apply_btn = go:FindChild("CancelApplyBtn")
    cancel_apply_btn:SetActive(apply_data ~= nil)
    self:AddClick(cancel_apply_btn, function ()
        self:SendCancelApplyDynasty(dynasty_data.dynasty_id, go)
    end)
    self.dynasty_item_list[index] = go
end

-- msg

function JoinDynastyUI:SendSeekDynasty()
    local name = self.search_name_input.text
    if name == "" then
        self:InitDynastyList()
    elseif UTF8.Len(name) < self.dynasty_name_min_len then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.SEARCH_NAME_ILLEGAL)
    else
        SpecMgrs.msg_mgr:SendSeekDynasty({dynasty_name = name}, function (resp)
            self.is_in_search = true
            self.dynasty_list = resp.dynasty_list or {}
            self.total_count = #self.dynasty_list
            self.dynasty_list_cmp:Start(self.total_count, kDynastyShowCount > self.total_count and self.total_count or kDynastyShowCount)
        end)
    end
end

function JoinDynastyUI:SendGetDynastyList(page, is_init)
    SpecMgrs.msg_mgr:SendGetDynastyList({page = page}, function (resp)
        if #resp.dynasty_list == 0 then return end
        for i, dynasty_data in ipairs(resp.dynasty_list) do
            local index = (page - 1) * kDynastyShowCount + i
            self.dynasty_list[index] = dynasty_data
        end
        if page == self.cur_page then
            self.first_index = (page - 1) * kDynastyShowCount + 1
            self.end_index = (page - 1) * kDynastyShowCount + #resp.dynasty_list
            if is_init then
                self.total_count = #resp.dynasty_list
                self.dynasty_list_cmp:Start(self.total_count, kDynastyShowCount > self.total_count and self.total_count or kDynastyShowCount)
            end
        elseif page > self.cur_page then
            self.total_count = (page - 1) * kDynastyShowCount + #resp.dynasty_list
            self.dynasty_list_cmp:ChangeTotalCount(self.total_count)

            -- 更新一遍列表 防止获取新数据时顺序发生变化
            self:UpdateCurDynastyItem()
        end
    end)
end

function JoinDynastyUI:UpdateCurDynastyItem()
    local end_flag_index = self.dynasty_list_cmp:GetEndFlagIndex() + 1
    local start_flag_index = self.dynasty_list_cmp:GetStartFlagIndex() + 1
    for i = start_flag_index, end_flag_index do
        self:SetDynastyContent(self.dynasty_item_list[i], i)
    end
end

function JoinDynastyUI:SendJoinDynastyRequest(dynasty_id, go)
    if self.dy_dynasty_data:GetApplyCount() >= self.max_apply_count then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.APPLY_COUNT_LIMIT)
        return
    end
    if self.dy_dynasty_data:GetQuitTs() then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.APPLY_QUIT_DELAY)
        return
    end
    SpecMgrs.msg_mgr:SendApplyDynasty({dynasty_id = dynasty_id}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.APPLY_FAILED)
        else
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.APPLY_SUCCESS)
            go:FindChild("ApplyBtn"):SetActive(false)
            go:FindChild("CancelApplyBtn"):SetActive(true)
        end
    end)
end

function JoinDynastyUI:SendCancelApplyDynasty(dynasty_id, go)
    SpecMgrs.msg_mgr:SendCancelApplyDynasty({dynasty_id = dynasty_id}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.CANCEL_APPLY_FAILED)
        else
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.CANCEL_APPLY_SUCCESS)
            go:FindChild("ApplyBtn"):SetActive(true)
            go:FindChild("CancelApplyBtn"):SetActive(false)
        end
    end)
end

function JoinDynastyUI:SendCreateDynasty()
    if ComMgrs.dy_data_mgr:ExGetRoleVip() < self.create_dynasty_vip_limit then
        SpecMgrs.ui_mgr:ShowMsgBox(string.format(UIConst.Text.CREATE_DYNASTY_VIP_LIMIT, self.create_dynasty_vip_limit))
        return
    end
    if self.dy_bag_data:GetBagItemCount(self.dynasty_create_cost.item_id) < self.dynasty_create_cost.count then
        SpecMgrs.ui_mgr:ShowMsgBox(string.format(UIConst.Text.ITEM_NOT_ENOUGH, self.dynasty_create_cost_data.name))
        return
    end
    local name = self.create_name_input.text
    local name_len = string.len(name)
    if name_len > self.dynasty_name_max_len or name_len < self.dynasty_name_min_len then
        SpecMgrs.ui_mgr:ShowMsgBox(string.format(UIConst.Text.DYNASTY_NAME_LEN_ILLEGAL, self.dynasty_name_min_len, self.dynasty_name_max_len))
        return
    end
    if string.sub(name, 1, 1) == " " or string.sub(name, -1, -1) == " " then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.DYNASTY_NAME_SPACE_IN_BOTH_END)
        return
    end
    if string.find(name, "  ") then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.DYNASTY_NAME_SPACE_IN_ROW)
        return
    end
    if CheckHasBadWord(name) then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.DYNASTY_NAME_HAS_BAD_WORD)
        return
    end
    SpecMgrs.msg_mgr:SendCreateDynasty({dynasty_name = name}, function (resp)
        if resp.errcode ~= 0 then
            if resp.name_repeat then
                SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.DYNASTY_NAME_EXIST
            else
                SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.CREATE_DYNASTY_FAILED
            end
        else
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.CREATE_DYNASTY_SUCCESS)
            self.create_dynasty_panel:SetActive(false)
            self.dy_dynasty_data:SetDynastyId(resp.dynasty_base_info.dynasty_id)
            self:Hide()
            SpecMgrs.ui_mgr:ShowUI("DynastyUI")
        end
    end)
end

function JoinDynastyUI:ClearDynastyItem()
    for _, dynasty_item in ipairs(self.dynasty_item_list) do
        self:DelUIObject(dynasty_item)
    end
    self.dynasty_item_list = {}
end

return JoinDynastyUI