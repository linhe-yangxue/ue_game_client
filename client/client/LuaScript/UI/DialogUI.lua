local UIBase = require("UI.UIBase")
local UIFuncs = require("UI.UIFuncs")
local UIConst = require("UI.UIConst")

local DialogUI = class("UI.DialogUI", UIBase)

local kTalkerPos = {
    left = 0,
    right = 1,
}
local kTypeInterval = 0.05
local kTargetAnchoredPosX = 0
local kTalkerAnimDuration = 0.3

function DialogUI:DoInit()
    DialogUI.super.DoInit(self)
    self.prefab_path = "UI/Common/DialogUI"
    self.cur_index = 0
    self.timer = 0
    self.result_str = ""
    self.is_typing = false
end

function DialogUI:OnGoLoadedOk(res_go)
    DialogUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
end

function DialogUI:Hide()
    if self.unit then
        ComMgrs.unit_mgr:DestroyUnit(self.unit)
        self.unit = nil
    end
    self:ResetTalkerPosition()
    self.dialog_data = nil
    if self.finish_cb then
        PrintWarn("finish_cb is not nil when self:Hide()")
        self:TriggerFinishCb()
    end
    DialogUI.super.Hide(self)
end

function DialogUI:InitRes()
    self:AddClick(self.main_panel:FindChild("Mask"), function ()
        if self.is_typing then
            self:FinishDialog()
        else
            self:NextDialog()
        end
    end)
    self.left_talker_img = self.main_panel:FindChild("ModelPanel/LeftTalkerImg")
    self.left_talker_init_pos = self.left_talker_img:GetComponent("RectTransform").anchoredPosition
    self.right_talker_img = self.main_panel:FindChild("ModelPanel/RightTalkerImg")
    self.right_talker_init_pos = self.right_talker_img:GetComponent("RectTransform").anchoredPosition
    local dialog_content_panel = self.main_panel:FindChild("DialogContentPanel")
    self.name_panel = dialog_content_panel:FindChild("NamePanel")
    self.talker_name = self.name_panel:FindChild("Name"):GetComponent("Text")
    self.dialog_text = dialog_content_panel:FindChild("ContentPanel/TextPanel/DialogText")
end

function DialogUI:ShowDialog(dialog_group_id, finish_cb)
    if self.dialog_data then
        PrintWarn("Show Dialog Twice dialog_group_id :", dialog_group_id)
        self:TriggerFinishCb()
    end
    self.dialog_data = SpecMgrs.data_mgr:GetDialogGroupData(dialog_group_id)
    self.cur_index = 0
    self.finish_cb = finish_cb
    self:NextDialog()
end

function DialogUI:TriggerFinishCb()
    if self.finish_cb then
        local finish_cb = self.finish_cb
        self.finish_cb = nil
        finish_cb()
    end
end

function DialogUI:NextDialog()
    self:RemoveDynamicUI(self.dialog_text)
    if not self.dialog_data or not self.dialog_data[self.cur_index + 1] then
        self:TriggerFinishCb()
        self:Hide()
    else
        self.cur_index = self.cur_index + 1
        self:SetContent()
        self.is_typing = true
    end
end

function DialogUI:FinishDialog()
    if not self.is_typing then return end
    self:RemoveDynamicUI(self.dialog_text)
    self.dialog_text:GetComponent("Text").text = UIFuncs.TextIndent(self.result_str, 2)
    self.result_str = ""
    self.is_typing = false
end

function DialogUI:SetContent()
    local cur_dialog_data = self.dialog_data[self.cur_index]
    self:ResetTalkerPosition()
    self.name_panel:SetActive(cur_dialog_data.is_player == true or cur_dialog_data.talker_id ~= nil)
    if cur_dialog_data.is_player or cur_dialog_data.talker_id then
        local talker_unit_id = cur_dialog_data.is_player and SpecMgrs.data_mgr:GetRoleLookData(ComMgrs.dy_data_mgr:ExGetRoleId()).unit_id or cur_dialog_data.talker_id
        local talker_unit_data = SpecMgrs.data_mgr:GetUnitData(talker_unit_id)
        self.cur_talker_pos = cur_dialog_data.talker_pos
        local img = self.cur_talker_pos == kTalkerPos.left and self.left_talker_img or self.right_talker_img
        if not talker_unit_data.res_path then
            PrintError("talker haven't model")
        else
            self.unit = ComMgrs.unit_mgr:CreateUnitAutoGuid({
                unit_id = talker_unit_data.id,
                parent = img,
                is_flip_x = talker_unit_data.oriented == self.cur_talker_pos,
                -- position = Vector3.NewByTable(self.cur_talker_pos == kTalkerPos.left and talker_unit_data.dialog_left_pos or talker_unit_data.dialog_right_pos)
            })
            self.unit:SetPositionByRectName({parent = img, name = "full"})
        end
        self.talker_name.text = cur_dialog_data.is_player and ComMgrs.dy_data_mgr:ExGetRoleName() or talker_unit_data.name
    end
    self.result_str = string.gsub(cur_dialog_data.content, UIConst.ReplacePlayerStr, ComMgrs.dy_data_mgr:ExGetRoleName())
    UIFuncs.AddTypeEffectText(self, self.dialog_text, UIFuncs.TextIndent(self.result_str, 2), kTypeInterval, function ()
        self.is_typing = false
        self.result_str = ""
    end)
    if cur_dialog_data.sound_id then
        SpecMgrs.sound_mgr:PlayTalkSound(cur_dialog_data.sound_id)
    end
end

function DialogUI:ResetTalkerPosition()
    self.cur_talker_pos = nil
    self.timer = 0
    self.left_talker_img:GetComponent("RectTransform").anchoredPosition = self.left_talker_init_pos
    self.right_talker_img:GetComponent("RectTransform").anchoredPosition = self.right_talker_init_pos
    if self.unit then
        ComMgrs.unit_mgr:DestroyUnit(self.unit)
        self.unit = nil
    end
end

function DialogUI:Update(delta_time)
    if not self.cur_talker_pos then return end
    local finish_flag
    if self.cur_talker_pos == kTalkerPos.left then
        local cur_pos_x = math.lerp(self.left_talker_init_pos.x, kTargetAnchoredPosX, self.timer / kTalkerAnimDuration)
        if math.abs(cur_pos_x - kTargetAnchoredPosX) < 0.1 then finish_flag = true end
        self.left_talker_img:GetComponent("RectTransform").anchoredPosition = Vector3.New(cur_pos_x, self.left_talker_init_pos.y, self.left_talker_init_pos.z)
    elseif self.cur_talker_pos == kTalkerPos.right then
        local cur_pos_x = math.lerp(self.right_talker_init_pos.x, kTargetAnchoredPosX, self.timer / kTalkerAnimDuration)
        if math.abs(cur_pos_x - kTargetAnchoredPosX) < 0.1 then finish_flag = true end
        self.right_talker_img:GetComponent("RectTransform").anchoredPosition = Vector3.New(cur_pos_x, self.right_talker_init_pos.y, self.right_talker_init_pos.z)
    end
    self.timer = self.timer + delta_time
    if finish_flag then
        self.cur_talker_pos = nil
        self.timer = 0
    end
end

return DialogUI