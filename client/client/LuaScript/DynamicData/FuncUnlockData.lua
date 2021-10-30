local UIConst = require("UI.UIConst")
local CSConst = require("CSCommon.CSConst")
local FuncUnlockData = class("DynamicData.FuncUnlockData")
local EventUtil = require("BaseUtilities.EventUtil")
local EffectConst = require("Effect.EffectConst")
local UIFuncs = require("UI.UIFuncs")

EventUtil.GeneratorEventFuncs(FuncUnlockData, "GuideGroupEnd")
EventUtil.GeneratorEventFuncs(FuncUnlockData, "InitLockedDictEvent")

function FuncUnlockData:DoInit()
    self.func_unlock_data_list = SpecMgrs.data_mgr:GetAllFuncUnlockData()
    self.ui_to_id_list = self.func_unlock_data_list.ui_to_id_list
    self.ui_to_active_unlock_data_list = {} -- 当前激活的锁定内容
    self.id_to_ui_to_effect_list = {}
    SpecMgrs.ui_mgr:RegisterUIShowOkEvent("FuncUnlockData", function(_, ui)
        self:OnUIShowOk(ui.class_name)
    end)
    SpecMgrs.ui_mgr:RegisterHideUIEvent("FuncUnlockData", function(_, ui)
        self:OnUIHide(ui.class_name)
    end)
end

function FuncUnlockData:NotifyLevelEventTrigger(msg)
    if msg.locked_dict then
        self.locked_dict = msg.locked_dict
        self:CheckActiveUnlockData()
        self:UpdateLockUI()
        self:RemoveUnlockId(self.ui_to_id_list)
        self:DispatchInitLockedDictEvent()
    end
end

function FuncUnlockData:UpdateLockUI()
    local ui_mgr = SpecMgrs.ui_mgr
    for i, func_unlock_data in ipairs(self.func_unlock_data_list) do
        local lock_ui = func_unlock_data.lock_ui
        if lock_ui then
            if self.locked_dict[i] then
                local str = UIFuncs.GetFuncLockTipStr(i)
                ui_mgr:LockUI(lock_ui, str)
            else
                ui_mgr:UnLockUI(lock_ui)
            end
        end
    end
end

function FuncUnlockData:CheckActiveUnlockData()
    for ui, unlock_data_list in pairs(self.ui_to_active_unlock_data_list) do
        local remove_list = {}
        for index, unlock_data in ipairs(unlock_data_list) do
            if not self:CheckFuncIslock(unlock_data.id) then
                table.insert(remove_list, index)
            end
        end
        if next(remove_list) then
            for i = #remove_list, 1, -1 do
                local remove_data = table.remove(unlock_data_list, remove_list[i])
                self:RemoveLockEffect(remove_data.id, ui)
            end
        end
    end
end

function FuncUnlockData:RemoveUnlockId(ui_to_id_list)
    local ret = {}
    for ui, id_list in pairs(ui_to_id_list) do
        for i, id in ipairs(id_list) do
            if self:CheckFuncIslock(id) then
                if not ret[ui] then ret[ui] = {} end
                table.insert(ret[ui], id)
            end
        end
    end
    self.ui_to_id_list = ret
end

--UI是否加载成功
function FuncUnlockData:OnUIShowOk(ui_name)
    local id_list = self.ui_to_id_list[ui_name]
    if not id_list or not next(id_list) then return end
    local ui = SpecMgrs.ui_mgr:GetUI(ui_name)
    local func_unlock_data
    for _, id in ipairs(id_list) do
        func_unlock_data = self.func_unlock_data_list[id]
        if self:CheckFuncIslock(func_unlock_data.id) then
            self:SetDataActive(func_unlock_data, ui_name)
        end
    end
end

function FuncUnlockData:SetDataActive(func_unlock_data, ui_name)
    if not self.ui_to_active_unlock_data_list[ui_name] then self.ui_to_active_unlock_data_list[ui_name] = {} end
    local ui = SpecMgrs.ui_mgr:GetUI(ui_name)
    if not ui.is_res_ok then return end
    table.insert(self.ui_to_active_unlock_data_list[ui_name], func_unlock_data)
    local btn_data_list = func_unlock_data.ui_to_btn_data_list[ui_name]
    local btn_go
    local effect_id
    for _, btn_data in ipairs(btn_data_list) do
        btn_go = ui.go:FindChild(btn_data.btn_path)
        if not btn_go then PrintError("Can not Find Btn, ui_name:", ui_name, "btn_data:", btn_data, "func_unlock_data:", func_unlock_data) end
        ui:RegBtnClickEvent(btn_go, function()
            return not self:CheckFuncIslock(func_unlock_data.id, true)
        end)
        local effect_go = btn_data.effect_path and ui.go:FindChild(btn_data.effect_path) or btn_go
        if not effect_go then PrintError("Can not Find EffectGo, ui_name:", ui_name, "btn_data:", btn_data, "func_unlock_data:", func_unlock_data) end
        effect_id = btn_data.effect_id
        if effect_id then
            self:AddLockEffect(ui, effect_go, func_unlock_data.id, effect_id, ui_name)
        end
    end
end

function FuncUnlockData:AddLockEffect(ui, btn, id, effect_id, ui_name)
    local param = {
        attach_ui_go = btn,
        effect_id = effect_id,
        offset_tb = {0, 0, 0, 0},
        need_sync_load = true,
    }
    local lock_effect = ui:AddUIEffect(btn, param)
    if not self.id_to_ui_to_effect_list[id] then self.id_to_ui_to_effect_list[id] = {} end
    if not self.id_to_ui_to_effect_list[id][ui_name] then self.id_to_ui_to_effect_list[id][ui_name] = {} end
    table.insert(self.id_to_ui_to_effect_list[id][ui_name], lock_effect)
end

function FuncUnlockData:RemoveLockEffect(id, ui_name)
    if not self.id_to_ui_to_effect_list[id] then return end
    local effect_list = self.id_to_ui_to_effect_list[id][ui_name]
    if effect_list then
        for _, effect in ipairs(effect_list) do
            effect:EffectEnd()
        end
    end
    self.id_to_ui_to_effect_list[id][ui_name] = nil
    if not next(self.id_to_ui_to_effect_list[id]) then
        self.id_to_ui_to_effect_list[id] = nil
    end
end

function FuncUnlockData:CheckFuncIslock(id, is_show_tip)
    if not self.locked_dict then return false end
    local is_lock = self.locked_dict[id] or false
    if is_lock and is_show_tip then
        local str = UIFuncs.GetFuncLockTipStr(id)
        SpecMgrs.ui_mgr:ShowTipMsg(str)
    end
    return is_lock
end

function FuncUnlockData:IsFuncUnlock(id)
    if not self.locked_dict then return false end
    return not self.locked_dict[id]
end

function FuncUnlockData:CheckFuncUnlock(func_name)
    local id = CSConst.FuncUnlockId[func_name]
    return self:IsFuncUnlock(id)
end

function FuncUnlockData:OnUIHide(ui_name)
    if self.ui_to_active_unlock_data_list[ui_name] then
        for _, unlock_data in ipairs(self.ui_to_active_unlock_data_list[ui_name]) do
            self:RemoveLockEffect(unlock_data.id, ui_name)
        end
        self.ui_to_active_unlock_data_list[ui_name] = nil 
    end
end

function FuncUnlockData:ClearAll()
    self.ui_to_active_unlock_data_list = {}
    for _, ui_to_effect_list in pairs(self.id_to_ui_to_effect_list) do
        for _, effect_list in ipairs(ui_to_effect_list) do
            for _, effect in ipairs(effect_list) do
                effect:EffectEnd()
            end
        end
    end
    self.id_to_ui_to_effect_list = {}
end

return FuncUnlockData