local UIConst = require("UI.UIConst")
local CSConst = require("CSCommon.CSConst")
local EffectConst = require("Effect.EffectConst")
local GConst = require("GlobalConst")
local GuideData = class("DynamicData.GuideData")
local EventUtil = require("BaseUtilities.EventUtil")

EventUtil.GeneratorEventFuncs(GuideData, "GuideGroupEnd")

function GuideData:DoInit()
    self.func_guide_data_dict = SpecMgrs.data_mgr:GetAllFuncGuideData()
    self.show_guide_type = {
        ShowBtnGuide = 1, -- 按钮提示
        ShowDialog = 2, -- 立绘对话
        ListenHideUI = 3, -- 等待ui隐藏
        GotoStage = 4,
    }
    self.guide_group_id_to_guide_list = {}
    self.guide_group_id_to_index = {}
    self.ui_name_to_data_dict = {}

    self.guide_id_to_effect_list = {}-- 临时存储的特效
    self.guide_id_to_btn_list = {} -- 临时存储的按钮集合
end

function GuideData:SetGuideGroup(guide_group_id, index) -- 设置强制指引接口
    local index = index or 1
    local guide_id_list = SpecMgrs.data_mgr:GetFuncGuideIdListByGuideGroupId(guide_group_id)
    if not guide_id_list then PrintError("No guide group", guide_group_id) return end
    self.guide_group_id_to_guide_list[guide_group_id] = guide_id_list
    local first_guide_id = self.guide_group_id_to_guide_list[guide_group_id][index]
    self.guide_group_id_to_index[guide_group_id] = index
    local guide_data = self.func_guide_data_dict[first_guide_id]
    self:_TrySetGuideData(guide_data)
end

function GuideData:_TrySetGuideData(guide_data)
    local ui_name = guide_data.ui
    if ui_name then
        if self:CheckUI(ui_name) then
            self:_ActiveGuideData(guide_data)
        else
            self:_RegisterTopUIChangeEvent(guide_data)
        end
    else
        self:_ActiveGuideData(guide_data)
    end
end

function GuideData:CheckUI(ui_name)
    if SpecMgrs.ui_mgr:GetSpecialUIOrder(ui_name) then
        local ui = SpecMgrs.ui_mgr:GetUI(ui_name)
        return ui and ui.is_showing and true or false
    else
        local top_ui_name_dict = SpecMgrs.ui_mgr:GetNormalTopUINameDict()
        return top_ui_name_dict[ui_name] and true or false
    end
end

function GuideData:_ActiveGuideData(guide_data)
    if guide_data.delay_time then
        self:_AddDelayTimer(guide_data)
    else
        self:_StartUIGuide(guide_data)
    end
end

function GuideData:_RegisterTopUIChangeEvent(guide_data)
    if self.wait_guide_data then PrintWarn("Set wait_guide_data Twice") end
    self.wait_guide_data = guide_data
    SpecMgrs.ui_mgr:RegisterTopUIChangeEvent("GuideData", function(_, ui)
        if self.wait_guide_data then
            if self:CheckUI(self.wait_guide_data.ui) then
                SpecMgrs.ui_mgr:UnregisterTopUIChangeEvent("GuideData")
                self:_ActiveGuideData(self.wait_guide_data)
                self.wait_guide_data = nil
            end
        end
    end)
end

function GuideData:_AddDelayTimer(guide_data)
    if self.delay_guide_timer then
        PrintError("Add delay_guide_timer twice")
    else
        SpecMgrs.ui_mgr:ShowUI("ForceGuideUI", nil, UIConst.GuideEventType.Click, UIConst.Alpha.Zero)
        self.delay_guide_timer = SpecMgrs.timer_mgr:AddTimer(function ()
            self:HideForceGuideUI()
            self:_StartUIGuide(guide_data)
            self.delay_guide_timer = nil
        end, guide_data.delay_time, 1)
    end
end
function GuideData:HideForceGuideUI()
    local ui = SpecMgrs.ui_mgr:GetUI("ForceGuideUI")
    if ui then
        ui:Hide()
    end
end

function GuideData:_NextGuide(guide_data)
    local guide_group_id = guide_data.group_id
    local guide_id_list = self.guide_group_id_to_guide_list[guide_group_id]
    if not guide_id_list then return end
    local guide_group_index = self.guide_group_id_to_index[guide_group_id]
    guide_group_index = guide_group_index + 1

    self.guide_group_id_to_index[guide_group_id] = guide_group_index
    local guide_id = self.guide_group_id_to_guide_list[guide_group_id][guide_group_index]
    local guide_data = guide_id and self.func_guide_data_dict[guide_id]
    if guide_data then
        self:_TrySetGuideData(guide_data)
    else
        self.guide_group_id_to_index[guide_group_id] = nil
        self.guide_group_id_to_guide_list[guide_group_id] = nil
        self:HideForceGuideUI()
        self:DispatchGuideGroupEnd(guide_group_id)
    end
end

function GuideData:_StartUIGuide(guide_data)
    --强制指引去掉（不显示箭头指引）（新手引导）
    if guide_data.guide_type == self.show_guide_type.ShowBtnGuide then
        local ui = SpecMgrs.ui_mgr:GetUI(guide_data.ui)
        self:ShowBtnGuide(ui, guide_data)
    elseif
        guide_data.guide_type == self.show_guide_type.ShowDialog then
        self:ShowDialog(guide_data)
    elseif guide_data.guide_type == self.show_guide_type.ListenHideUI then
        self:ListenHideUI(guide_data)
    elseif guide_data.guide_type == self.show_guide_type.GotoStage then
        self:GotoStage(guide_data)
    end
end

function GuideData:GotoStage(guide_data)
    SpecMgrs.stage_mgr:GotoStage(guide_data.stage_name)
    self:_NextGuide(guide_data)
end

function GuideData:ListenHideUI(guide_data)
    local ui_name = guide_data.listen_hide_ui
    if self.listen_hide_ui_name == ui_name then return end
    self.listen_hide_ui_name = ui_name
    SpecMgrs.ui_mgr:RegisterHideUIEvent("GuideData", function(_, ui)
        if self.listen_hide_ui_name == ui.class_name then
            SpecMgrs.ui_mgr:UnregisterHideUIEvent("GuideData")
            self.listen_hide_ui_name = nil
            self:_NextGuide(guide_data)
        end
    end)
end

function GuideData:ShowDialog(guide_data)
    local dialog_data = SpecMgrs.data_mgr:GetDialogData(guide_data.dialog_id)
    SpecMgrs.ui_mgr:ShowDialog(dialog_data.group_id, function ()
        self:_NextGuide(guide_data)
    end)
end

function GuideData:ShowBtnGuide(ui, force_guide_data)

    if not self.guide_id_to_btn_list[force_guide_data.id] then self.guide_id_to_btn_list[force_guide_data.id] = {} end
    local btn_path_to_btn = self.guide_id_to_btn_list[force_guide_data.id]
    local get_btn_cb = function (btn, btn_path)
        if btn then
            btn_path_to_btn[btn_path] = btn
        else
            PrintError("Can not Find Btn", btn_path, force_guide_data)
        end
        local is_return_btn_list = true
        for _, btn_path in pairs(force_guide_data.btn_path_list) do
            if not btn_path_to_btn[btn_path] then
                is_return_btn_list = false
                break
            end
        end
        if is_return_btn_list then
            local btn_list = {}
            for _, btn_path in ipairs(force_guide_data.btn_path_list) do
                table.insert(btn_list ,btn_path_to_btn[btn_path])
            end
            self.guide_id_to_btn_list[force_guide_data.id] = nil
            self:GetAllUIBtnCallBack(ui, btn_list, force_guide_data)
        end
    end

    for _, btn_path in ipairs(force_guide_data.btn_path_list) do
        if ui.GetGuideBtn then -- ui自己来找动态寻找路径
            ui:GetGuideBtn(btn_path, function (btn)
                get_btn_cb(btn, btn_path)
            end)
        else
            local btn = ui.go:FindChild(btn_path)
            get_btn_cb(btn, btn_path)
        end
    end
end

function GuideData:GetAllUIBtnCallBack(ui, btn_list, guide_data)
    if ui and next(btn_list) then
        for _, btn in ipairs(btn_list) do
            ui:RegBtnClickEvent(btn, function()
                self:RemoveGuideUIEffect(guide_data.id)
                for _, btn in ipairs(btn_list) do
                    if ui and not IsNil(btn) then
                        ui:UnregBtnClickEvent(btn)
                    end
                end
                self:_NextGuide(guide_data) -- 点击完设置下一步
                return true
            end)
        end
        local main_btn = btn_list[1]
        local effect_go = guide_data.effect_path and ui.go:FindChild(guide_data.effect_path) or main_btn
        if not effect_go then PrintError("Can not EffectPath guide_data: ", guide_data) end
        self:AddArrowGuideEffect(ui, effect_go, guide_data)
        local alpha = guide_data.is_show_black_mask and UIConst.Alpha.Seven or UIConst.Alpha.Zero
        local force_guide_ui = SpecMgrs.ui_mgr:ShowUI("ForceGuideUI", effect_go, UIConst.GuideEventType.Click, alpha)
        local sort_order = SpecMgrs.ui_mgr:GetSpecialUIOrder(guide_data.ui)
        if sort_order then
            force_guide_ui:SetSortOrder(sort_order + 1)
        end
    else
        PrintError("Can not Find ui and Btn guide_data: ", guide_data)
    end
end


function GuideData:AddArrowGuideEffect(ui, btn, guide_data)
    if not btn then return end
    local local_scale = guide_data.arrow_local_scale and Vector3.NewByTable(guide_data.arrow_local_scale) or Vector3.One
    local param = {
        attach_ui_go = btn,
        effect_id = EffectConst.GuideEffectId.GuideArrowEffect,
        local_scale = local_scale,
        anchors_tb = {0.5, 0.5, 0.5, 0.5},
        pos_tb = guide_data.arrow_local_pos,
        need_sync_load = true,
    }
    local arrow_effect = ui:AddUIEffect(btn, param)
    arrow_effect.go:GetComponent("Canvas").sortingOrder = ui.sort_order + 1
    if not self.guide_id_to_effect_list[guide_data.id] then self.guide_id_to_effect_list[guide_data.id] = {} end
    table.insert(self.guide_id_to_effect_list[guide_data.id], arrow_effect)
end

function GuideData:RemoveGuideUIEffect(guide_id)
    local effect_list = self.guide_id_to_effect_list[guide_id]
    if effect_list then
        for _, effect in ipairs(effect_list) do
            effect:EffectEnd()
        end
    end
    self.guide_id_to_effect_list[guide_id] = nil
end

function GuideData:ClearAll()
    self.guide_group_id_to_guide_list = {}
    self.guide_group_id_to_index = {}
    self.ui_name_to_data_dict = {}
    for guide_id, _ in pairs(self.guide_id_to_effect_list) do
        self:RemoveGuideUIEffect(guide_id)
    end
    self.guide_id_to_effect_list = {}

    self.guide_id_to_btn_list = {}
    if self.delay_guide_timer then
        SpecMgrs.timer_mgr:RemoveTimer(self.delay_guide_timer)
        self.delay_guide_timer = nil
    end
end

return GuideData