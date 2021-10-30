local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local TipMsgUI = class("UI.TipMsgUI", UIBase)

local kMoveSpeed = 280
local kShowDeltaTime = 0.25

function TipMsgUI:DoInit()
    TipMsgUI.super.DoInit(self)
    self.prefab_path = "UI/Common/TipMsgUI"
    self.tip_msg_tb = {}
    self.tip_msg_cache_tb = {}
    self.cur_delta_time = 0
end

function TipMsgUI:OnGoLoadedOk(res_go)
    TipMsgUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
end

function TipMsgUI:InitRes()
    self.tip_msg_frame = self.main_panel:FindChild("TipMsgBox")
    self.tip_msg_item_temp = self.main_panel:FindChild("TipMsgItem")
    self.tip_get_item_temp = self.main_panel:FindChild("TipGetItem")
    self.tip_msg_item_temp:SetActive(false)
    self.tip_msg_height = self.tip_msg_item_temp:GetComponent("RectTransform").sizeDelta.y
end

function TipMsgUI:Show(param)
    local str = nil
    if type(param) == "string" then
        str = param
    elseif type(param) == "number" then
        if param <= 1 then
            return
        else
            --str = SpecMgrs.data_mgr:GetErrcode(param) or UIConst.Text.ERROR_KNOWN
            str = UIConst.Text.ERROR_KNOWN
        end
    elseif param.item_id and param.count then
        if param.count > 0 then table.insert(self.tip_msg_cache_tb, param) end
    end
    if str then
        table.insert(self.tip_msg_cache_tb, str)
    end
    TipMsgUI.super.Show(self)
end

function TipMsgUI:Update(delta_time)
    if not self.is_res_ok then return end
    if #self.tip_msg_cache_tb > 0 then
        self.cur_delta_time = self.cur_delta_time - delta_time
        if self.cur_delta_time <= 0 then
            self.cur_delta_time = kShowDeltaTime
            local msg_data = table.remove(self.tip_msg_cache_tb, 1)
            if type(msg_data) == "string" then
                self:SetTipMsgContent(msg_data)
            elseif msg_data.item_id and msg_data.count then
                self:SetTipItemContent(msg_data.item_id, msg_data.count)
            end
        end
    end
end

function TipMsgUI:SetTipMsgContent(str)
    local item = self:GetUIObject(self.tip_msg_item_temp)
    item:SetParent(self.tip_msg_frame, false)
    item:SetAsFirstSibling()
    item:FindChild("Content").localPosition = Vector3.one
    item:FindChild("Content/Text"):GetComponent("Text").text = str
    self:_ShowTipMsg(item)
end

function TipMsgUI:SetTipItemContent(item_id, count)
    local item = self:GetUIObject(self.tip_get_item_temp)
    item:SetParent(self.tip_msg_frame, false)
    item:SetAsFirstSibling()
    item:FindChild("Content").localPosition = Vector3.one
    UIFuncs.InitItemGo({
        go = item:FindChild("Content/Item"),
        item_id = item_id,
        ignore_bg_and_frame = true,
    })
    local item_name = UIFuncs.GetItemName({item_id = item_id})
    item:FindChild("Content/Text"):GetComponent("Text").text = string.format(UIConst.Text.ATTR_VALUE_FORMAT, item_name, count)
    self:_ShowTipMsg(item)
end

function TipMsgUI:_ShowTipMsg(item)
    self:AddListener(item, function (go)
        local index = 1
        if self.tip_msg_tb[1] ~= item then
            for i = 2, #self.tip_msg_tb do
                if self.tip_msg_tb == item then
                    index = i
                    break
                end
            end
        end
        self:DelUIObject(item)
        table.remove(self.tip_msg_tb, index)
    end)
    item:GetComponent("TipMsgItem"):Show(kMoveSpeed)
    table.insert(self.tip_msg_tb, item)
    if #self.tip_msg_tb > 0 then
        for _, item in ipairs(self.tip_msg_tb) do
            item:GetComponent("TipMsgItem"):SetTargetOffset(self.tip_msg_height)
        end
    end
end

return TipMsgUI