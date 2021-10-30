local EventUtil = require("BaseUtilities.EventUtil")
local UIConst = require("UI.UIConst")
local MailData = class("DynamicData.MailData")

EventUtil.GeneratorEventFuncs(MailData, "AddMailEvent")
EventUtil.GeneratorEventFuncs(MailData, "UpdateMailEvent")

local mail_red_point_id = 4

function MailData:DoInit()
    self.mail_list = {}
end

function MailData:NotifyUpdateMailUnRead(have_unread)
    SpecMgrs.redpoint_mgr:SetControlIdActive(mail_red_point_id, {have_unread and 1 or 0})
end

function MailData:NotifyUpdateMailList(mail_list)
    self.mail_list = mail_list
    self.mail_list = self:SortMailList(mail_list)
end

function MailData:SortMailList(mail_list)
    local read_list = {}
    local not_read_list = {}
    for _, mail_info in pairs(mail_list) do
        if mail_info.is_read then
            table.insert(read_list, mail_info)
        else
            table.insert(not_read_list, mail_info)
        end
    end
    table.sort(read_list, function(a, b)
        if a.send_ts == b.send_ts then
            return false
        end
        return a.send_ts > b.send_ts
    end)
    table.sort(not_read_list, function(a, b)
        if a.send_ts == b.send_ts then
            return false
        end
        return a.send_ts > b.send_ts
    end)
    mail_list = {}
    for i,v in ipairs(not_read_list) do
        table.insert(mail_list, v)
    end
    for i,v in ipairs(read_list) do
        table.insert(mail_list, v)
    end
    return mail_list
end

function MailData:GetMailList()
    return self.mail_list
end

function MailData:NotifyAddMailInfo(msg)
    SpecMgrs.redpoint_mgr:SetControlIdActive(mail_red_point_id, {1})
end

function MailData:DeleteMail(mail_guid_list)
    for i = #self.mail_list, 1, -1 do
        if table.contains(mail_guid_list, self.mail_list[i].mail_guid) then
            table.remove(self.mail_list, i)
        end
    end
    self:SortMailList(self.mail_list)
end

function MailData:ReadMail(guid)
    for i,v in ipairs(self.mail_list) do
        if v.mail_guid == guid then
            v.is_read = true
        end
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(mail_red_point_id, {self:CheckHaveRedPoint() and 1 or 0})
end

function MailData:GetMailItem(guid)
    for i,v in ipairs(self.mail_list) do
        if v.mail_guid == guid then
            v.is_get_item = true
            v.is_read = true
            self:DispatchUpdateMailEvent()
        end
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(mail_red_point_id, {self:CheckHaveRedPoint() and 1 or 0})
end

function MailData:GetMailListItem(mail_guid_list)
    for i = #self.mail_list, 1, -1 do
        if table.contains(mail_guid_list, self.mail_list[i].mail_guid) then
            self.mail_list[i].is_get_item = true
            self.mail_list[i].is_read = true
            self:DispatchUpdateMailEvent()
        end
    end
    SpecMgrs.redpoint_mgr:SetControlIdActive(mail_red_point_id, {self:CheckHaveRedPoint() and 1 or 0})
end

function MailData:CheckHaveRedPoint()
    return self:CheckHaveAttachmentMail() or self:CheckHaveNotReadMail()
end

-- 查看是否有未领取附件的邮件 用于主界面左上角邮件按钮
function MailData:CheckHaveAttachmentMail()
    for _, mail in ipairs(self.mail_list) do
        if mail.item_list and not mail.is_get_item then
            return true
        end
    end
    return false
end

function MailData:CheckHaveNotReadMail()
    for _, mail in ipairs(self.mail_list) do
        if not mail.is_read then
            return true
        end
    end
    return false
end

return MailData