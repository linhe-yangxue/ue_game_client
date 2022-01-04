local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local StageConst = require("Stage.StageConst")

local RoleUpgradeUI = class("UI.RoleUpgradeUI", UIBase)

local kUpgrateEffectDelay = 0.1

function RoleUpgradeUI:DoInit()
    RoleUpgradeUI.super.DoInit(self)
    self.prefab_path = "UI/Common/RoleUpgradeUI"
    self.dy_strategy_map_data = ComMgrs.dy_data_mgr.strategy_map_data
    self.role_upgrade_sound = SpecMgrs.data_mgr:GetParamData("hero_level_up_sound").sound_id
    self.feature_go_list = {}
end

function RoleUpgradeUI:OnGoLoadedOk(res_go)
    RoleUpgradeUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function RoleUpgradeUI:Show(last_level, cur_level)
    self.last_level = last_level
    self.cur_level = cur_level
    if self.is_res_ok then
        self:InitUI()
    end
    RoleUpgradeUI.super.Show(self)
end

function RoleUpgradeUI:Hide()
    self.last_level = nil
    self.cur_level = nil
    if self.upgrate_effect_timer then
        self:RemoveTimer(self.upgrate_effect_timer)
    end
    self.upgrate_effect_timer = nil
    if self.show_content_timer then
        self:RemoveTimer(self.show_content_timer)
    end
    self.show_content_timer = nil
    RoleUpgradeUI.super.Hide(self)
end

function RoleUpgradeUI:InitRes()
    self.upgrate_effect = self.main_panel:FindChild("player_lv_up")
    --self.qizhi_anim_cmp = self.main_panel:FindChild("qizhi"):GetComponent("SkeletonGraphic").AnimationState
    self.content = self.main_panel:FindChild("Content")
    --self.role_icon = self.main_panel:FindChild("qizhi/RoleIcon"):GetComponent("Image")
    self.unit_parent = self.main_panel:FindChild("Content/UnitParent")
    local info_panel = self.content:FindChild("Info")
    local level_panel = info_panel:FindChild("LevelPanel")
    level_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ROLE_LEVEL
    self.last_level_text = level_panel:FindChild("LastLevel"):GetComponent("Text")
    self.cur_level_text = level_panel:FindChild("CurLevel"):GetComponent("Text")
    local strength_panel = info_panel:FindChild("StrengthPanel")
    strength_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.STRENGTHEN_FORMAT
    self.last_strength = strength_panel:FindChild("LastStrength"):GetComponent("Text")
    self.cur_strength = strength_panel:FindChild("CurStrength"):GetComponent("Text")
    local energy_panel = info_panel:FindChild("EnergyPanel")
    energy_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ENERGY_FORMAT
    self.last_energy = energy_panel:FindChild("LastEnergy"):GetComponent("Text")
    self.cur_energy = energy_panel:FindChild("CurEnergy"):GetComponent("Text")
    self.cmd_panel = info_panel:FindChild("CmdPanel")
    self.cmd_text = self.cmd_panel:FindChild("Text"):GetComponent("Text")
    self.last_cmd = self.cmd_panel:FindChild("LastCmd"):GetComponent("Text")
    self.cur_cmd = self.cmd_panel:FindChild("CurCmd"):GetComponent("Text")

    self.unlock_content = self.content:FindChild("UnlockPanel/View/Content")
    self.unlock_item = self.unlock_content:FindChild("UnlockItem")
    self.unlock_item:FindChild("GotoBtn/Text"):GetComponent("Text").text = UIConst.Text.GOTO_TEXT
    self.locked_item = self.unlock_content:FindChild("LockedItem")
    self.content:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CLICK_FOR_CONTINUE

    self:AddClick(self.main_panel, function ()
        self.content:SetActive(false)
        self.upgrate_effect:SetActive(false)
        self:Hide()
    end)
end

function RoleUpgradeUI:InitUI()
    if not self.last_level or not self.cur_level then return end
    self:RegisterEvent(SpecMgrs.guide_mgr, "StartGuideEvent", function ()
        self:OnStartGuide()
    end)
    self:InitInfoPanel()
    self:InitUnlockPanel()
    self:PlayUpgrateAnim()
end

function RoleUpgradeUI:InitInfoPanel()
    local role_unit_id = SpecMgrs.data_mgr:GetRoleLookData(ComMgrs.dy_data_mgr:ExGetRoleId()).unit_id
    --UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetUnitData(role_unit_id).circle_icon, self.role_icon)
    self:AddFullUnit(role_unit_id, self.unit_parent)
    self.last_level_text.text = self.last_level
    self.cur_level_text.text = self.cur_level
    local account_info = ComMgrs.dy_data_mgr:ExGetAccountInfo()
    print("角色升级=====",account_info,self.last_level,self.cur_level)
    local last_level_data = SpecMgrs.data_mgr:GetLevelData(self.last_level)
    local cur_level_data = SpecMgrs.data_mgr:GetLevelData(self.cur_level)
    print("角色升级后数据",cur_level_data)
    SpecMgrs.sdk_mgr:UpdateRoleInfo(self.cur_level)
    local cur_action_point = self.dy_strategy_map_data:GetActionPoint()
    self.last_strength.text = cur_action_point - cur_level_data.add_vitality_point
    self.cur_strength.text = cur_action_point
    -- TODO 兴奋度

    local extra_flag = false
    if cur_level_data.info_max_count > last_level_data.info_max_count then
        self.cmd_text.text = UIConst.Text.INFORMATION_LIMIT
        self.last_cmd.text = last_level_data.info_max_count
        self.cur_cmd.text = cur_level_data.info_max_count
        extra_flag = true
    else
        for index, cmd_count in ipairs(last_level_data.cmd_max_count) do
            if cur_level_data.cmd_max_count[index] > cmd_count then
                self.cmd_text.text = string.format(UIConst.Text.ATTR_FORMAT, SpecMgrs.data_mgr:GetLevyData(index).name)
                self.last_cmd.text = cmd_count
                self.cur_cmd.text = cur_level_data.cmd_max_count[index]
                extra_flag = true
                break
            end
        end
    end
    self.cmd_panel:SetActive(extra_flag)
end

function RoleUpgradeUI:InitUnlockPanel()
    self:ClearFeatureGo()
    local cur_sys_unlock_list
    local next_sys_unlock_list
    for index, feature_list in ipairs(SpecMgrs.data_mgr:GetUnlockFeatureList()) do
        if self.cur_level < feature_list.level then
            next_sys_unlock_list = feature_list
            break
        else
            cur_sys_unlock_list = feature_list
        end
    end
    -- 已解锁功能
    if cur_sys_unlock_list then
        for i, feature_data in ipairs(cur_sys_unlock_list.data) do
            if self.cur_level ~= cur_sys_unlock_list.level and not feature_data.is_show then
            else
                local go = self:GetUIObject(self.unlock_item, self.unlock_content)
                go.name = i
                -- TODO 加载功能图标
                -- UIFuncs.AssignSpriteByIconID(feature_data.icon, go:FindChild("Icon"):GetComponent("Image"))
                go:FindChild("Name"):GetComponent("Text").text = feature_data.name
                go:FindChild("Desc"):GetComponent("Text").text = feature_data.desc
                local goto_btn_go = go:FindChild("GotoBtn")
                if SpecMgrs.guide_mgr:IsInGuideState() then
                    goto_btn_go:SetActive(false)
                else
                    goto_btn_go:SetActive(true)
                    self:AddClick(goto_btn_go, function ()
                        --if feature_data.guide_type == 1 then
                            -- 由功能指引表内容操作
                        --elseif feature_data.guide_type == 2 then
                            SpecMgrs.ui_mgr:ShowUI(feature_data.goto_ui)
                        --end
                        self:Hide()
                    end)
                end
                table.insert(self.feature_go_list, go)
            end
        end
    end
    -- 下级解锁功能
    if next_sys_unlock_list then
        for _, feature_data in ipairs(next_sys_unlock_list.data) do
            local go = self:GetUIObject(self.locked_item, self.unlock_content)
            -- TODO 加载功能图标
            -- UIFuncs.AssignSpriteByIconID(feature_data.icon, go:FindChild("Icon"):GetComponent("Image"))
            go:FindChild("Name"):GetComponent("Text").text = feature_data.name
            go:FindChild("Desc"):GetComponent("Text").text = feature_data.desc
            go:FindChild("UnlockLevel"):GetComponent("Text").text = string.format(UIConst.Text.UNLOCK_FEATURE_TEXT, next_sys_unlock_list.level)
            table.insert(self.feature_go_list, go)
        end
    end
end

function RoleUpgradeUI:OnStartGuide()
    for _, go in ipairs(self.feature_go_list) do
        local btn_go = go:FindChild("GotoBtn")
        if btn_go then
            btn_go:SetActive(false)
        end
    end
end

function RoleUpgradeUI:PlayUpgrateAnim()
    --local anim_time = self.qizhi_anim_cmp:PlayAnimation(0, "animation", false, 0)
    --self.qizhi_anim_cmp:AddAnim(0, "idle", true, 0, 1)
    local anim_time = 0.53 -- todo 等新特效
    self.upgrate_effect_timer = self:AddTimer(function ()
        self:PlayUISound(self.role_upgrade_sound)
        self.upgrate_effect:SetActive(true)
        self.upgrate_effect_timer = nil
    end, kUpgrateEffectDelay, 1)
    self.show_content_timer = self:AddTimer(function ()
        self.content:SetActive(true)
        self.show_content_timer = nil
    end, anim_time - 0.2, 1)
end

function RoleUpgradeUI:ClearFeatureGo()
    for _, go in ipairs(self.feature_go_list) do
        self:DelUIObject(go)
    end
    self.feature_go_list = {}
end

return RoleUpgradeUI