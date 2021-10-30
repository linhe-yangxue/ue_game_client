local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local FloatMsgCmp = class("UI.UICmp.FloatMsgCmp")

local kMoveSpeed = 500
local kShowDeltaTime = 0.25

function FloatMsgCmp:DoInit(owner, msg_box, msg_item)
    self.tip_msg_tb = {}
    self.tip_msg_cache_tb = {}
    self.create_obj_list = {}
    self.cur_delta_time = 0
    self.owner = owner
    self.tip_msg_frame = msg_box
    self.tip_msg_item_temp = msg_item
    self.tip_msg_item_temp:SetActive(false)
    self.tip_msg_height = self.tip_msg_item_temp:GetComponent("RectTransform").sizeDelta.y
end

function FloatMsgCmp:ShowMsg(str)
    table.insert(self.tip_msg_cache_tb, str)
end

function FloatMsgCmp:Update(delta_time)
    if not self.owner.is_res_ok then return end
    if #self.tip_msg_cache_tb > 0 then
        self.cur_delta_time = self.cur_delta_time - delta_time
        if self.cur_delta_time <= 0 then
            self.cur_delta_time = kShowDeltaTime
            local msg_data = table.remove(self.tip_msg_cache_tb, 1)
            self:SetTipMsgContent(msg_data)
        end
    end
end

function FloatMsgCmp:SetTipMsgContent(str)
    local item = self.owner:GetUIObject(self.tip_msg_item_temp)
    item:SetParent(self.tip_msg_frame, false)
    item:SetAsFirstSibling()
    item.localPosition = Vector3.one
    item:FindChild("Content/Text"):GetComponent("Text").text = str
    self:_ShowTipMsg(item)
    table.insert(self.create_obj_list, item)
end

function FloatMsgCmp:_ShowTipMsg(item)
    self.owner:AddListener(item, function (go)
        local index = 1
        if self.tip_msg_tb[1] ~= item then
            for i = 2, #self.tip_msg_tb do
                if self.tip_msg_tb == item then
                    index = i
                    break
                end
            end
        end
        self.owner:DelUIObject(item)
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

function FloatMsgCmp:ClearRes()
    self.owner:DelObjDict(self.create_obj_list)
    self.create_obj_list = {}
end

return FloatMsgCmp