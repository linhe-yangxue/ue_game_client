local CSConst = require("CSCommon.CSConst")
local UIConst = require("UI.UIConst")
local EventUtil = require("BaseUtilities.EventUtil")
local FConst = require("CSCommon.Fight.FConst")
local GuideMgr = class("Mgrs.Special.GuideMgr")
local CSFunction = require("CSCommon.CSFunction")
local StageConst = require("Stage.StageConst")

EventUtil.GeneratorEventFuncs(GuideMgr, "StartGuideEvent")

local func_name_list = {
    "ShowDialog",
    "StartFuncGuide",
    "ShowSolidrBattle",
    "ShowHeroBattle",
    "GotoStage",
}

local func_guide_type_map = {
    before_guide = 1,
    guide = 2,
    after_guide = 3,
}

local func_guide_type_to_key = {
    "before_guide_id_list",
    "func_guide_id_list",
    "after_guide_id_list",
}


local guide_active_stage_list = { -- 指引的激活stage不填时 则以下所有stage都会激活该指引
    StageConst.STAGE_UnderworldHeadquarters,
    StageConst.STAGE_EntertainmentCompany,
    StageConst.STAGE_BigMap,
    StageConst.STAGE_Guide,
}

function GuideMgr:DoInit()
    self.serv_guide_dict = {} -- 服务器指引数据
    self.force_guide_data_list = {} -- 当前所有guidegroup 的guide_id 列表
    self.cur_force_guide_group_id = nil -- 当前指引id  唯一
    self.cur_force_guide_index = nil -- 当前指引组 索引
    self.cur_force_guide_data = nil -- 当前激活强制指引
    self.cur_func_guide_type = nil
    self.is_first_set_func_guide = true
    self.before_guide_hide_ui_data_list = SpecMgrs.data_mgr:GetAllBeforeGuideHideUIData()
end

function GuideMgr:CheckBeforeGuideHideUI()
    self.cur_hide_ui_guide_index =  0 -- 当前检测ui索引
    self.hide_ui_and_id_list = {} -- 当前存在需要关闭的ui列表
    for id, hide_ui_data in ipairs(self.before_guide_hide_ui_data_list) do
        local hide_ui = SpecMgrs.ui_mgr:GetUI(hide_ui_data.ui)
        if hide_ui and hide_ui.is_showing then -- 暂时用is_showing
            table.insert(self.hide_ui_and_id_list, {id = id, ui = hide_ui})
        end
    end
    table.sort(self.hide_ui_and_id_list, function(data1, data2)
        return data1.ui:GetSortOrder() > data2.ui:GetSortOrder()
    end)
    self:_NextCheckBeforeGuideHideUI()
end

function GuideMgr:_NextCheckBeforeGuideHideUI()
    self.cur_hide_ui_guide_index = self.cur_hide_ui_guide_index + 1
    local hide_ui_and_id = self.hide_ui_and_id_list[self.cur_hide_ui_guide_index]
    if hide_ui_and_id then
        local ui = hide_ui_and_id.ui
        if ui and ui.is_showing then
            local hide_ui_data = self.before_guide_hide_ui_data_list[hide_ui_and_id.id]
            local func_guide_id = hide_ui_data.func_guide_id
            self:SetFuncGuideId(func_guide_id, false)
        else
            return self:_NextCheckBeforeGuideHideUI()
        end
    else
        self.cur_hide_ui_guide_index = nil
        self.hide_ui_and_id_list = nil
        self:SetForceGuideGroup(self.force_guide_group_id_list[1])
    end
end


function GuideMgr:UpdateNewbieGuideInfo(msg)
    --PrintError("UpdateNewbieGuideInfo msg", msg)
    if msg.guide_dict then
        for guide_group_id, guide_index in pairs(msg.guide_dict) do
            self.serv_guide_dict[guide_group_id] = guide_index
        end
        self:GetActiveForceGuide()
    end
end

function GuideMgr:FinishForceGuide()
    self.serv_guide_dict[self.cur_force_guide_group_id] = nil
    self.cur_force_guide_group_id = nil
    self.cur_force_guide_index = nil
    self.cur_force_guide_data = nil
    self:GetActiveForceGuide()
end

function GuideMgr:IsInGuideState()
    return (self.cur_force_guide_group_id or self.cur_hide_ui_guide_index) and true or false
end

function GuideMgr:GetActiveForceGuide()
    if self:IsInGuideState() then return end -- 当前正在指引
    self.force_guide_group_id_list = {}
    for guide_group_id, _ in pairs(self.serv_guide_dict) do
        table.insert(self.force_guide_group_id_list, guide_group_id)
    end
    if next(self.force_guide_group_id_list) then
        local guide_group_type = SpecMgrs.data_mgr:GetForceGuideData("guide_group_type")
        table.sort(self.force_guide_group_id_list, function (id1, id2)
            if guide_group_type[id1] ~= guide_group_type[id2] then
                return guide_group_type[id1] < guide_group_type[id2]
            end
            return id1 < id2
        end)
        self:CheckBeforeGuideHideUI() -- 先检测需要影藏的ui
    end
end

function GuideMgr:SetForceGuideGroup(force_guide_group_id) -- 指引入口
    self.cur_force_guide_group_id = force_guide_group_id
    self.force_guide_data_list = {}
    local guide_group_list = SpecMgrs.data_mgr:GetForceGuideData("guide_group_list")
    for i, guide_id in ipairs(guide_group_list[force_guide_group_id]) do
        local guide_data = SpecMgrs.data_mgr:GetForceGuideData(guide_id)
        table.insert(self.force_guide_data_list, guide_data)
    end
    self.cur_force_guide_index = self.serv_guide_dict[force_guide_group_id]
    self:_NextGuide()
    self:DispatchStartGuideEvent()
end

-- FirstInGame
function GuideMgr:NextGuide()
    self:SendCompleteGuide(self.cur_force_guide_group_id)
    self:_NextGuide()
end

function GuideMgr:_NextGuide()
    if not self:IsInGuideState() then return end
    self.cur_force_guide_data = nil
    self.cur_force_guide_index = self.cur_force_guide_index + 1
    local force_guide_data = self.force_guide_data_list[self.cur_force_guide_index]
    if force_guide_data then
        self:_SetGuide(force_guide_data)
    else
        self:FinishForceGuide()
    end
end

function GuideMgr:StartFuncGuide(force_guide_data)
    self.force_guide_data = force_guide_data
    self:_NextFuncGuideType()
end

function GuideMgr:_NextFuncGuideType()
    local func_guide_id_list
    local func_guide_type
    local before_guide_id_list = self:GetFuncGuideIdList(self.cur_force_guide_data, func_guide_type_map.before_guide)
    local guide_id_list = self:GetFuncGuideIdList(self.cur_force_guide_data, func_guide_type_map.guide)
    local after_guide_id_list = self:GetFuncGuideIdList(self.cur_force_guide_data, func_guide_type_map.after_guide)
    local is_need_before_guide = self:IsNeedBeforeGuide()
    if not self.cur_func_guide_type then -- 第一次
        if is_need_before_guide and before_guide_id_list then -- 查询前置指引
            func_guide_id_list = before_guide_id_list
            func_guide_type = func_guide_type_map.before_guide
        elseif guide_id_list then
            func_guide_id_list = guide_id_list
            func_guide_type = func_guide_type_map.guide
        elseif after_guide_id_list then
            self:SendCompleteGuide(self.cur_force_guide_group_id) -- 直接设置后置指引则发消息给服务器
            func_guide_id_list = after_guide_id_list
            func_guide_type = func_guide_type_map.after_guide
        else
            PrintError("force_guide_data don't have guide_id_list", self.cur_force_guide_data)
        end
        self:_SetFuncGuideType(func_guide_id_list, func_guide_type)
        self:_NextFuncGuide()
    elseif self.cur_func_guide_type == func_guide_type_map.before_guide then -- 目前是前置指引后就直接 后置指引的情况
        func_guide_id_list = guide_id_list
        self:_SetFuncGuideType(func_guide_id_list, func_guide_type_map.guide)
        self:_NextFuncGuide()
    elseif self.cur_func_guide_type == func_guide_type_map.guide then
        self:SendCompleteGuide(self.cur_force_guide_group_id) -- 完成中间指引就发送服务器 后置指引在下次开启时不再指引
        if after_guide_id_list then
            self:_SetFuncGuideType(after_guide_id_list, func_guide_type_map.after_guide)
            self:_NextFuncGuide()
        else
            self:_SetFuncGuideType(nil)
            self:_NextGuide()
        end
    else -- 后置指引
        self:_SetFuncGuideType(nil)
        self:_NextGuide()
    end
end

function GuideMgr:_SetFuncGuideType(func_guide_id_list, func_guide_type)
    if func_guide_id_list then
        self.func_guide_id_list = func_guide_id_list
        self.func_guide_index = 0
        self.cur_func_guide_type = func_guide_type
    else
        self.func_guide_id_list = nil
        self.func_guide_index = nil
        self.cur_func_guide_type = nil
    end
end

function GuideMgr:_NextFuncGuide()
    self.func_guide_index = self.func_guide_index + 1
    local func_guide_id = self.func_guide_id_list[self.func_guide_index]
    if not func_guide_id then
        return self:_NextFuncGuideType()
    else
        self:SetFuncGuideId(func_guide_id)
    end
end

function GuideMgr:SetFuncGuideId(func_guide_id, is_not_next_func_guide)
    local func_guide_data = SpecMgrs.data_mgr:GetFuncGuideData(func_guide_id)
    self.func_guide_group_id = func_guide_data.group_id
    local guide_data = ComMgrs.dy_data_mgr.guide_data
    guide_data:RegisterGuideGroupEnd("GuideMgr", function (_, guide_group_id)
        guide_data:UnregisterGuideGroupEnd("GuideMgr")
        if self.cur_hide_ui_guide_index then
            self:_NextCheckBeforeGuideHideUI() -- 先进行ui检测
            return
        end
        if self.func_guide_group_id == guide_group_id then
            self.func_guide_group_id = nil
            if is_not_next_func_guide then return end
            self:_NextFuncGuide()
        end
    end)
    guide_data:SetGuideGroup(self.func_guide_group_id)
end

function GuideMgr:GetFuncGuideIdList(force_guide_data, func_guide_type)
    return force_guide_data[func_guide_type_to_key[func_guide_type]]
end

function GuideMgr:SendCompleteGuide(force_guide_group_id)
    SpecMgrs.msg_mgr:SendCompleteGuide({guide_group_id = self.cur_force_guide_group_id}, function (resp)
        if resp.errcode ~= 0 then
            PrintError("Get wrong errcode in SendCompleteGuide", self.cur_force_guide_group_id, self.cur_force_guide_index)
        end
    end)
end

function GuideMgr:_SetGuide(force_guide_data)
    if self.cur_force_guide_data then PrintError("Set force_guide_data twice") return end
    self.cur_force_guide_data = force_guide_data
    local active_stage_type = self:GetGuideActiveStage(force_guide_data)
    local active_stage_type_list = active_stage_type and {active_stage_type} or guide_active_stage_list
    local is_guide_active = self:CheckGuideDataActive(active_stage_type_list)
    if is_guide_active then -- 没有激活stage或者当前stage已经对上了
        self:_StartForceGuide()
    else
        self:ListenStageChange(active_stage_type_list)
    end
end

function GuideMgr:GetGuideActiveStage(force_guide_data)
    if self:IsNeedBeforeGuide() and force_guide_data.before_guide_id_list then
        return force_guide_data.before_guide_stage
    else
        return force_guide_data.guide_stage
    end
end

function GuideMgr:CheckGuideDataActive(stage_list)
    for _, stage_type in ipairs(stage_list) do
        if ComMgrs.dy_data_mgr:IsCurStage(stage_type) then
            return true
        end
    end
    return false
end

-- 指引组第一个 或者重启之后第一次开启指引组
function GuideMgr:IsNeedBeforeGuide()
    return self.is_first_set_func_guide or self.cur_force_guide_index == 1
end

function GuideMgr:_StartForceGuide()
    if not self.cur_force_guide_data then return end
    local func_index = self.cur_force_guide_data.func_index
    local func_name = func_name_list[func_index]
    self[func_name](self, self.cur_force_guide_data)
    self.is_first_set_func_guide = nil
end

function GuideMgr:ListenStageChange(active_stage_type_list)
    SpecMgrs.stage_mgr:RegisterStageChangeEvent("GuideMgr", function ()
        if self:CheckGuideDataActive(active_stage_type_list) then
            SpecMgrs.stage_mgr:UnregisterStageChangeEvent("GuideMgr")
            self:_StartForceGuide()
        end
    end)
end

function GuideMgr:ShowDialog(force_guide_data)
    local dialog_data = SpecMgrs.data_mgr:GetDialogData(force_guide_data.dialog_id)
    SpecMgrs.ui_mgr:ShowDialog(dialog_data.group_id, function ()
        self:NextGuide()
    end)
end

function GuideMgr:ShowSolidrBattle(force_guide_data)
    self:RegisterBattleResuleUIHideEvent(force_guide_data)
    local soldier_battle_data = {
        enemy_soldier_num = 1000,
        m_soldier_num = 3000,
        m_military_val = 1000,
        enemy_military_val = 1000,
        enemy_model_id = 1000010,
        enemy_model_num = 10,
    }
    --local reward_data = SpecMgrs.data_mgr:GetRewardData(force_guide_data.complete_reward_id).reward_item_dict
    SpecMgrs.ui_mgr:ShowUI("SoldierBattleUI", soldier_battle_data)
    self:SetFuncGuideId(force_guide_data.func_guide_id_list[1], true)
end

function GuideMgr:RegisterBattleResuleUIHideEvent(force_guide_data)
    local register_name = "GuideMgr"
    local register_func = function (battle_result_ui)
        battle_result_ui:RegisterBattleResultUICloseEvent(register_name, function ()
            battle_result_ui:UnregisterBattleResultUICloseEvent(register_name)
            self:NextGuide()
        end)
    end
    local battle_result_ui = SpecMgrs.ui_mgr:GetUI("BattleResultUI")
    if battle_result_ui then
        register_func(battle_result_ui)
    else
        SpecMgrs.ui_mgr:RegisterUIShowOkEvent(register_name, function (_, ui)
            if ui.class_name == "BattleResultUI" then
                SpecMgrs.ui_mgr:UnregisterUIShowOkEvent(register_name)
                register_func(ui)
            end
        end)
    end
end

function GuideMgr:ShowHeroBattle(force_guide_data)
    self:RegisterBattleResuleUIHideEvent(force_guide_data)
    local self_hero_group = force_guide_data.self_hero_group
    local ememy_hero_group = force_guide_data.ememy_hero_group
    local hero_battle_data = CSFunction.get_native_hero_battle_data(self_hero_group, ememy_hero_group)
    hero_battle_data.seed = 1
    SpecMgrs.ui_mgr:EnterHeroBattle(hero_battle_data, UIConst.BattleScence.GuideUI)
    SpecMgrs.ui_mgr:RegiseHeroBattleEnd("GuideMgr", function()
        local is_win = true
        local param_tb = {
            is_win = is_win,
            show_level = true,
            --reward_data = SpecMgrs.data_mgr:GetRewardData(force_guide_data.front_reward_id).reward_item_dict,
        }
        SpecMgrs.ui_mgr:AddCloseBattlePopUpList("BattleResultUI", param_tb)
    end)
end

function GuideMgr:GotoStage(stage_name)
    if not ComMgrs.dy_data_mgr:IsCurStage(stage_name) then
        SpecMgrs.stage_mgr:GotoStage(stage_name)
    end
end

function GuideMgr:DoDestroy()
    self:ClearAll()
end

-- 测试期间跳过所有指引方法
function GuideMgr:PassGuide()
    if not self.cur_force_guide_group_id then return end
    local pass_dict = {}
    for k, v in pairs(self.serv_guide_dict) do
        pass_dict[k] = v
    end
    local guide_group_list = SpecMgrs.data_mgr:GetForceGuideData("guide_group_list")

    for guide_group_id , guide_index in pairs(pass_dict) do
        local first_guide_index = guide_index + 1
        for i = first_guide_index, #(guide_group_list[guide_group_id]) do
            print("跳过指引才走这里========================")
           SpecMgrs.msg_mgr:SendCompleteGuide({guide_group_id = guide_group_id}, function (resp)
            end)
        end
    end
    ComMgrs.dy_data_mgr.guide_data:ClearAll()
    self:ClearAll()
    SpecMgrs.stage_mgr:GotoStage("MainStage")
end

function GuideMgr:UnregisterAllEvent()
    SpecMgrs.ui_mgr:UnregisterUIShowOkEvent("GuideMgr")
    SpecMgrs.ui_mgr:UnregisterHideUIEvent("GuideMgr")
    ComMgrs.dy_data_mgr.guide_data:UnregisterGuideGroupEnd("GuideMgr")
end

function GuideMgr:ClearAll()
    self.serv_guide_dict = {}
    self.force_guide_data_list = {}
    self.cur_force_guide_group_id = nil -- 当前指引id
    self.cur_force_guide_index = nil -- 当前指引 索引
    self.cur_force_guide_data = nil
    self.func_guide_group_id = nil
    self.is_first_set_func_guide = true
    self.cur_func_guide_type = nil --不为nil会影响新手账号卡死
    self:UnregisterAllEvent()
end

return GuideMgr