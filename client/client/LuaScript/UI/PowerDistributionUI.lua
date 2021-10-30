local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local PowerDistributionUI = class("UI.PowerDistributionUI",UIBase)

--  势力名臣ui
function PowerDistributionUI:DoInit()
    PowerDistributionUI.super.DoInit(self)
    self.prefab_path = "UI/Common/PowerDistributionUI"

    self.lover_data = ComMgrs.dy_data_mgr.lover_data
    self.data_mgr = SpecMgrs.data_mgr
    self.skill_item_dict = {}
end

function PowerDistributionUI:OnGoLoadedOk(res_go)
    PowerDistributionUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function PowerDistributionUI:Show(lover_id)
    self.lover_id = lover_id
    if self.is_res_ok then
        self:InitUI()
    end
    PowerDistributionUI.super.Show(self)
end

function PowerDistributionUI:InitRes()
      --  上方ui
    local form = self.main_panel:FindChild("PowerForm")

    self.title = form:FindChild("UpFrame/Title"):GetComponent("Text")
    self.family_hero_text = form:FindChild("FamilyHeroText"):GetComponent("Text")

    self:AddClick(form:FindChild("UpFrame/CloseButton"), function()
        self:Hide()
    end)

    self.hero_head_portrait = form:FindChild("Temp/HeroHeadPortrait")
    --  名臣列表
    self.hero_list_content = form:FindChild("HeroView/Viewport/Content")

    --  升级面板
    self.power_point_num_text = form:FindChild("PowerPointNumText"):GetComponent("Text")
    local upgrade_msg_content = form:FindChild("UpgradeMes/View/Content")
    self.upgrade_msg_content_rect = upgrade_msg_content:GetComponent("RectTransform")
    self.skill_item = upgrade_msg_content:FindChild("SkillItem")
    self.skill_item:FindChild("UpgradeButton/Text"):GetComponent("Text").text = UIConst.Text.UPGRADE
    self.power_hero_panel = upgrade_msg_content:FindChild("PowerHero")
    self.power_hero_panel:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.POWER_HERO_ADDITION_TEXT
    self.power_hero_skill_list = self.power_hero_panel:FindChild("SkillList")
    self.all_hero_panel = upgrade_msg_content:FindChild("AllHero")
    self.all_hero_panel:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.ALL_HERO_ADDITION_TEXT
    self.all_hero_skill_list = self.all_hero_panel:FindChild("SkillList")

    self.help_btn = self.main_panel:FindChild("HelpBtn")
    self:AddClick(self.help_btn, function()
        UIFuncs.ShowPanelHelp(self.class_name)
    end)

    self.hero_head_portrait:SetActive(false)
end

function PowerDistributionUI:InitUI()
    self:UpdateLoverInfo()
    self:UpdateHeroList()
    self:UpdateLoverSkill()
    self.upgrade_msg_content_rect.anchoredPosition = Vector2.zero
    self:SetTextVal()
    self.lover_data:RegisterUpdateLoverInfoEvent("PowerDistributionUI", function(_, _, lover_id)
        if self.lover_id == lover_id then
            self:UpdateLoverInfo()
            self:UpdateLoverSkill()
        end
    end, self)
end

function PowerDistributionUI:SetTextVal()
    self.family_hero_text.text = UIConst.Text.FAMILY_HERO_TEXT
    self.help_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.HELP
end

function PowerDistributionUI:UpdateLoverInfo()
    self.lover_info = self.lover_data:GetLoverInfo(self.lover_id)
    self.cur_lover_data = self.data_mgr:GetLoverData(self.lover_id)
end

function PowerDistributionUI:UpdateHeroList()
    local heros = self.cur_lover_data.hero
    local hero_list = {}
    for i, v in ipairs(heros) do
        table.insert(hero_list, self.data_mgr:GetHeroData(v))
    end
    --  生成列表
    for i, v in ipairs(hero_list) do
        local hero_data = v
        local obj = self:GetUIObject(self.hero_head_portrait, self.hero_list_content, false)
        obj:FindChild("HeroNameText"):GetComponent("Text").text = hero_data.name
        UIFuncs.CreateHeroItem(self, obj:FindChild("HeroIcon/HeroHead"), hero_data.id)
    end
    local power_name = self.data_mgr:GetPowerData(self.cur_lover_data.power).name
    self.title.text = power_name
end

function PowerDistributionUI:UpdateLoverSkill()
    self.power_point_num_text.text = string.format(UIConst.Text.CAN_USE_POWER_POINT_FORMAT, self.lover_info.power_value)

    self.unlock_spell_list = self.lover_info.spell_dict -- {skill_id-level}
    self.all_spells = self.cur_lover_data.spell_list
    self:ClearSkillItem()
    local have_power_hero_skill = false
    local have_all_hero_skill = false
    for i, skill in ipairs(self.all_spells) do
        local skill_data = self.data_mgr:GetLoverSpellData(skill)
        have_power_hero_skill = not skill_data.is_all or have_power_hero_skill
        have_all_hero_skill = skill_data.is_all or have_all_hero_skill
        local parent = skill_data.is_all and self.all_hero_skill_list or self.power_hero_skill_list
        local skill_item = self:GetUIObject(self.skill_item, parent)
        self.skill_item_dict[skill] = skill_item

        local skill_unlock = self.unlock_spell_list[skill] ~= nil
        local upgrade_btn = skill_item:FindChild("UpgradeButton")
        upgrade_btn:SetActive(skill_unlock)
        local skill_level = self.unlock_spell_list[skill] or 1
        local level_text = skill_unlock and string.format(UIConst.Text.LOVER_SKILL_LEVEL, skill_data.name, skill_level) or skill_data.name
        UIFuncs.AssignSpriteByIconID(skill_data.icon, skill_item:FindChild("SkillImg"):GetComponent("Image"))
        skill_item:FindChild("LevelText"):GetComponent("Text").text = level_text
        skill_item:FindChild("Upgrade"):SetActive(skill_unlock)
        skill_item:FindChild("LockUpgrade"):SetActive(not skill_unlock)
        skill_item:FindChild("SkillAddValText"):GetComponent("Text").text = self:GetSkillData(skill_data, skill_level)
        if skill_unlock then
            skill_item:FindChild("Upgrade/PowerPointNumText"):GetComponent("Text").text = skill_data.cost_num[skill_level]
            local can_upgrade = self.lover_data:CanUpgradeLoverTargetSkill(self.lover_id, skill)
            upgrade_btn:FindChild("Tip"):SetActive(can_upgrade)
            local resp_cb = function (resp)
                if resp.errcode ~= 1 then

                end
            end
            self:AddClick(upgrade_btn, function()
                if not self.lover_data:CanUpgradeLoverTargetSkill(self.lover_id, skill) then
                    SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.POWER_NOT_ENOUGH_TEXT)
                    return
                end
                SpecMgrs.msg_mgr:SendUpgradeLoverSpell({lover_id = self.lover_id, spell_id = skill}, resp_cb)
            end)
        else
            skill_item:FindChild("LockUpgrade/UpgradeLevelText"):GetComponent("Text").text = self.cur_lover_data.spell_unlock_lv[i]
        end
    end
    self.power_hero_panel:SetActive(have_power_hero_skill)
    self.all_hero_panel:SetActive(have_all_hero_skill)
end

function PowerDistributionUI:GetSkillData(skill_data, level)
    local str = ""
    for i,v in ipairs(skill_data.attr_list) do
        local add_val = skill_data.attr_ratio[i] * level
        if skill_data.is_precent then
            add_val = string.format(UIConst.Text.PERCENT, add_val)
        end
        local attr_add_str = string.format(UIConst.Text.POWER_SKILL_ADD_VAL_FORMAT, SpecMgrs.data_mgr:GetAttributeData(v).name, add_val)
        str = str .. " " .. attr_add_str
    end
    return str
end

function PowerDistributionUI:ClearSkillItem()
    for _, item in pairs(self.skill_item_dict) do
        self:DelUIObject(item)
    end
    self.skill_item_dict = {}
end

function PowerDistributionUI:Hide()
    self:DelAllCreateUIObj()
    self.lover_data:UnregisterUpdateLoverInfoEvent("PowerDistributionUI")
    PowerDistributionUI.super.Hide(self)
end

return PowerDistributionUI
