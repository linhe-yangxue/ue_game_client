local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local MailboxUI = class("UI.MailboxUI",UIBase)

--  邮箱
function MailboxUI:DoInit()
    MailboxUI.super.DoInit(self)
    self.prefab_path = "UI/Common/MailboxUI"
end

function MailboxUI:OnGoLoadedOk(res_go)
    MailboxUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function MailboxUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    MailboxUI.super.Show(self)
end

function MailboxUI:InitRes()
    self:InitTopBar()
    self.all_mail_option = self.main_panel:FindChild("MiddleMesFrame/AllMailOption")
    self.all_mail_option_text = self.main_panel:FindChild("MiddleMesFrame/AllMailOption/Text"):GetComponent("Text")

    self.mail_temp = self.main_panel:FindChild("MiddleMesFrame/MailScroll/ViewPort/Content/MailItem")

    self.mail_scroll = self.main_panel:FindChild("MiddleMesFrame/MailScroll")
    self.mail_list_content = self.main_panel:FindChild("MiddleMesFrame/MailScroll/ViewPort/Content")

    self.option_list = self.main_panel:FindChild("MiddleMesFrame/OptionList")
    self.all_delete_btn = self.main_panel:FindChild("DownMesFrame/AllDeleteBtn")
    self:AddClick(self.all_delete_btn, function()
        local cb = function(resp)
            self.dy_mail_data:DeleteMail(resp.mail_guid_list)
            self.mail_type_selector:ReselectSelectObj()
        end
        if self.cur_select_mail_type == 0 then
            SpecMgrs.msg_mgr:SendDeleteMail(nil, cb)
        else
           SpecMgrs.msg_mgr:SendDeleteMail({mail_type = self.cur_select_mail_type}, cb)
        end
    end)
    self.all_delete_btn_text = self.main_panel:FindChild("DownMesFrame/AllDeleteBtn/AllDeleteBtnText"):GetComponent("Text")
    self.all_receive_btn = self.main_panel:FindChild("DownMesFrame/AllReceiveBtn")
    self:AddClick(self.all_receive_btn, function()
        local cb = function(resp)
            self.dy_mail_data:GetMailListItem(resp.mail_guid_list)
            self.mail_type_selector:ReselectSelectObj()
        end
        if self.cur_select_mail_type == 0 then
            SpecMgrs.msg_mgr:SendGetMailItem(nil, cb)
        else
           SpecMgrs.msg_mgr:SendGetMailItem({mail_type = self.cur_select_mail_type}, cb)
        end
    end)
    self.all_receive_btn_text = self.main_panel:FindChild("DownMesFrame/AllReceiveBtn/AllReceiveBtnText"):GetComponent("Text")
    self.mail_frame = self.main_panel:FindChild("MailFrame")
    self.mail_close_button = self.main_panel:FindChild("MailFrame/MailCloseButton")
    self:AddClick(self.mail_close_button, function()
        self:HideMailFrame()
    end)
    self.mail_title_text = self.main_panel:FindChild("MailFrame/MailTitleText"):GetComponent("Text")
    self.mail_time_text = self.main_panel:FindChild("MailFrame/MailTimeText"):GetComponent("Text")
    self.jump_mail = self.main_panel:FindChild("MailFrame/JumpMail")
    self.normal_mail = self.main_panel:FindChild("MailFrame/NormalMail")
    self.item_mail = self.main_panel:FindChild("MailFrame/ItemMail")

    self.mail_item_content = self.main_panel:FindChild("MailFrame/ItemMail/ItemScrollView/Content/MailItemContent")

    self.mail_item = self.main_panel:FindChild("MailFrame/MailItem")

    self:AddClick(self.item_mail:FindChild("ReceiveBtn"), function()
        self:ReciveMailItem()
    end)
    self.item_mail_text = self.item_mail:FindChild("ReceiveBtn/ReceiveBtnText"):GetComponent("Text")

    self.jump_mail_text = self.jump_mail:FindChild("JumpBtn/JumpBtnText"):GetComponent("Text")

    self:AddClick(self.jump_mail:FindChild("JumpBtn"), function()
        self:ClickJumpBtn()
    end)
end

function MailboxUI:InitUI()
    self.mail_temp:SetActive(false)
    self.mail_frame:SetActive(false)
    self.item_mail:SetActive(false)
    self.jump_mail:SetActive(false)
    self.normal_mail:SetActive(false)

    self:SetTextVal()

    local cb = function(resp)
        ComMgrs.dy_data_mgr.mail_data:NotifyUpdateMailList(resp.all_mail)
        self:UpdateData()
        self:UpdateUIInfo()
        self.mail_type_selector:SelectObj(1)
    end
    SpecMgrs.msg_mgr:SendGetAllMail(nil, cb)

end

function MailboxUI:UpdateData()
    self.dy_mail_data = ComMgrs.dy_data_mgr.mail_data
    self.mail_list = self.dy_mail_data:GetMailList()
    self.mail_type_data_list = SpecMgrs.data_mgr:GetAllMailTypeData()
end

function MailboxUI:UpdateUIInfo()
    self.mail_reward_item_list = {}
    self.select_option_list = {}
    table.insert(self.select_option_list, self.all_mail_option)
    for i, mail_type in ipairs(self.mail_type_data_list) do
        local option = self:GetUIObject(self.all_mail_option, self.option_list)
        option:FindChild("Text"):GetComponent("Text").text = mail_type.name
        table.insert(self.select_option_list, option)
    end

    self.mail_type_selector = UIFuncs.CreateSelector(self, self.select_option_list, function(i)
        self.mail_list = ComMgrs.dy_data_mgr.mail_data:GetMailList()
        local mail_list = self:GetMailListByType(i - 1)
        self.cur_select_mail_type = i - 1
        self:UpdateMailList(mail_list)
    end)
end

function MailboxUI:UpdateMailList(mail_list)
    if self.mail_item_list then self:DelObjDict(self.mail_item_list) end
    self.mail_item_list = {}
    for i, mail_info in ipairs(mail_list) do
        local item = self:GetUIObject(self.mail_temp, self.mail_list_content)
        self:SetMailItem(item, mail_info)
        item:FindChild("NotReadBg"):SetActive(not mail_info.is_read)
        item:FindChild("NotReadImage"):SetActive(not mail_info.is_read)
        item:FindChild("ReadBg"):SetActive(mail_info.is_read)
        item:FindChild("ReadImage"):SetActive(mail_info.is_read)
        if mail_info.item_list then
            item:FindChild("OpenImage"):SetActive(mail_info.is_get_item)
            item:FindChild("NotOpenImage"):SetActive(not mail_info.is_get_item)
        else
            item:FindChild("OpenImage"):SetActive(false)
            item:FindChild("NotOpenImage"):SetActive(false)
        end

        self:AddClick(item, function()
            self:ShowMailFrame(mail_info)
            local cb = function(resp)
                self.dy_mail_data:ReadMail(mail_info.mail_guid)
            end
            SpecMgrs.msg_mgr:SendReadMail({mail_guid = mail_info.mail_guid}, cb)
        end)
        table.insert(self.mail_item_list, item)
    end
    self.mail_list_content:GetComponent("RectTransform").anchoredPosition = Vector2.New(0, 0)
    self.mail_scroll:GetComponent("ScrollRect").elasticity = 0
    SpecMgrs.timer_mgr:AddTimer(function()
        self.mail_scroll:GetComponent("ScrollRect").elasticity = 0.1
    end, 0.01, 1)
end

function MailboxUI:SetMailItem(mail_item, mail_info)
    local mail_data = SpecMgrs.data_mgr:GetMailData(mail_info.mail_id)
    local title_text = mail_item:FindChild("TitleText"):GetComponent("Text")
    local time_text = mail_item:FindChild("TimeText"):GetComponent("Text")
    local source_text = mail_item:FindChild("SourceText"):GetComponent("Text")
    local mail_begin_text = mail_item:FindChild("MailBeginText"):GetComponent("Text")

    title_text.text = string.format(UIConst.Text.MAIL_COLOR_FORMAT, mail_info.title)
    time_text.text = string.format(UIConst.Text.MAIL_TIME_FORMAT, os.date(UIConst.MinuteHappenTimeFormat, mail_info.send_ts))
    local type_name = SpecMgrs.data_mgr:GetMailTypeData(mail_data.mail_type).name
    source_text.text = string.format(UIConst.Text.MAIL_TYPE_FORMAT, type_name)
    mail_begin_text.text = string.format(UIConst.Text.MAIL_COLOR_FORMAT, string.sub(mail_info.content, 1, 80))

    if mail_info.is_read then
        title_text.text = string.format(UIConst.Text.MAIL_GRAY_COLOR_FORMAT, mail_info.title)
        time_text.text = string.format(UIConst.Text.MAIL_GRAY_TIME_FORMAT, os.date(UIConst.MinuteHappenTimeFormat, mail_info.send_ts))
        local type_name = SpecMgrs.data_mgr:GetMailTypeData(mail_data.mail_type).name
        source_text.text = string.format(UIConst.Text.MAIL_GRAY_TYPE_FORMAT, type_name)
        mail_begin_text.text = string.format(UIConst.Text.MAIL_GRAY_COLOR_FORMAT, string.sub(mail_info.content, 1, 80))
    end
end

function MailboxUI:SetTextVal()
    self.all_delete_btn_text.text = UIConst.Text.ONEKEY_DELETE_TEXT
    self.all_receive_btn_text.text = UIConst.Text.ONEKEY_RECEIVE_TEXT
    self.all_mail_option_text.text = UIConst.Text.ALL
    self.jump_mail_text.text = UIConst.Text.JUMP_TEXT
end

function MailboxUI:GetMailListByType(mail_type)
    if mail_type == 0 then
        return self.mail_list
    end
    local ret = {}
    for i, mail_info in ipairs(self.mail_list) do
        local mail_data = SpecMgrs.data_mgr:GetMailData(mail_info.mail_id)
        if mail_data.mail_type == mail_type then
            table.insert(ret, mail_info)
        end
    end
    return ret
end

function MailboxUI:ShowMailFrame(mail_info)
    local mail_data = SpecMgrs.data_mgr:GetMailData(mail_info.mail_id)
    self.cur_mail_info = mail_info
    self.mail_frame:SetActive(true)
    self.mail_title_text.text = mail_data.name
    self.mail_time_text.text = os.date(UIConst.DayHappenTimeFormat, mail_info.send_ts)

    if mail_info.item_list and next(mail_info.item_list) then
        self.item_mail:SetActive(true)
        self:SetMailContentText(self.item_mail, mail_info)
        self.mail_reward_item_list = UIFuncs.SetItemList(self, mail_info.item_list, self.mail_item_content)
        if mail_info.is_get_item then
            self.item_mail_text.text = UIConst.Text.MAIL_ITEM_RECEIVE_TEXT
        else
            self.item_mail_text.text = UIConst.Text.RECEIVE_TEXT
        end
    elseif mail_data.skip_ui then
        self.jump_mail:SetActive(true)
        self:SetMailContentText(self.jump_mail, mail_info)
    else
        self.normal_mail:SetActive(true)
        self:SetMailContentText(self.normal_mail, mail_info)
    end
end

function MailboxUI:ReciveMailItem()
    self.item_mail:FindChild("ReceiveBtn/ReceiveBtnText"):GetComponent("Text").text = UIConst.Text.MAIL_ITEM_RECEIVE_TEXT
    if self.cur_mail_info then
        self.dy_mail_data:GetMailItem(self.cur_mail_info.mail_guid)
        local cb = function()

        end
        SpecMgrs.msg_mgr:SendGetMailItem({mail_guid = self.cur_mail_info.mail_guid}, cb)
    end
end

function MailboxUI:ClickJumpBtn()
    if self.cur_mail_info then
        local mail_data = SpecMgrs.data_mgr:GetMailData(self.cur_mail_info.mail_id)
        self:HideMailFrame()
        SpecMgrs.ui_mgr:ShowUI(mail_data.skip_ui)
    end
end

function MailboxUI:SetMailContentText(mail_obj, mail_info)
    local mail_content = FilterBadWord(mail_info.content)
    mail_obj:FindChild("MailContentScrollView/Content/MailContentText"):GetComponent("Text").text = mail_content
end

function MailboxUI:HideMailFrame()
    self.mail_frame:SetActive(false)
    self.item_mail:SetActive(false)
    self.jump_mail:SetActive(false)
    self.normal_mail:SetActive(false)
    self:DelObjDict(self.mail_reward_item_list)
    self.mail_type_selector:ReselectSelectObj()
end

function MailboxUI:Hide()
    self:DelObjDict(self.select_option_list)
    self:DelObjDict(self.mail_item_list)
    MailboxUI.super.Hide(self)
end

return MailboxUI
