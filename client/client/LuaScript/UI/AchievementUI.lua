local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local ItemUtil = require("BaseUtilities.ItemUtil")
local AchievementUI = class("UI.AchievementUI", UIBase)

function AchievementUI:DoInit()
    AchievementUI.super.DoInit(self)
    self.prefab_path = "UI/Common/AchievementUI"
    self.dy_achievement_data = ComMgrs.dy_data_mgr.achievement_data
    self.achievement_type_to_list = SpecMgrs.data_mgr:GetAchievementData("achievement_dict")
    self.achievement_type_to_go = {}
    self.item_go_list = {}
    self.effect_list = {}
end

function AchievementUI:OnGoLoadedOk(res_go)
    AchievementUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function AchievementUI:Hide()
    self:ClearAllCompleteEffect()
    self:ClearGoDict("item_go_list")
    self:ClearGoDict("achievement_type_to_go")
    AchievementUI.super.Hide(self)
end

function AchievementUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    AchievementUI.super.Show(self)
end

function AchievementUI:InitRes()
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "AchievementUI")
    local prefab_list = self.main_panel:FindChild("PrefabList")
    self.item_parent = self.main_panel:FindChild("ActivePanel/TaskPanel/View/Content")
    self.item_temp = self.main_panel:FindChild("PrefabList/TaskItem")
    self.item_temp:FindChild("GotoBtn/Text"):GetComponent("Text").text = UIConst.Text.GOTO_TEXT
    self.item_temp:FindChild("FinishBtn/Text"):GetComponent("Text").text = UIConst.Text.RECEIVE_TEXT
    self.item_temp:FindChild("Finished/Text"):GetComponent("Text").text = UIConst.Text.HAVE_FINISHED
    self.reward_temp = self.item_temp:FindChild("Scroll View/Viewport/Content/Item")
    self.reward_temp:SetActive(false)
    UIFuncs.GetIconGo(self, self.reward_temp)
end

function AchievementUI:InitUI()
    self:RegisterEvent(self.dy_achievement_data, "UpdateAchievementInfo", function ()
        self:UpdatePanel()
    end)
    self:InitPanel()
    self:UpdatePanel()
end

function AchievementUI:InitPanel()
    self:ClearAllCompleteEffect()
    self:ClearGoDict("item_go_list")
    self:ClearGoDict("achievement_type_to_go")
    local achievement_type_list = self.dy_achievement_data:GetSortedAchievementList()
    for i, achievement_type in ipairs(achievement_type_list) do
        local achievement_id_list = self.achievement_type_to_list[achievement_type]
        if achievement_id_list then -- 策划填了成就类型而且填成就内容才显示
            self.achievement_type_to_go[achievement_type] = self:GetUIObject(self.item_temp, self.item_parent)
        end
    end
end

function AchievementUI:UpdatePanel()
    self:ClearAllCompleteEffect()
    self:ClearGoDict("item_go_list")
    local achievement_type_list = self.dy_achievement_data:GetSortedAchievementList()
    local achievement_dict = self.dy_achievement_data:GetAchievementDict()
    for index, achievement_type in ipairs(achievement_type_list) do
        local go = self.achievement_type_to_go[achievement_type]
        if go then
            go:SetAsLastSibling()
            self:UpdateItem(achievement_type)
        end
    end
end

function AchievementUI:GetAchievementDesc(achievement_data)
    local progress_str = UIFuncs.AddCountUnit(achievement_data.progress)
    return string.format(achievement_data.desc, progress_str)
end

function AchievementUI:UpdateItem(achievement_type)
    local go = self.achievement_type_to_go[achievement_type]
    if not go then return end
    local achievement_id_list  = self.achievement_type_to_list[achievement_type]
    local serv_data = self.dy_achievement_data:GetAchievementData(achievement_type)
    local achievement_id
    if serv_data then
        achievement_id = serv_data.achievement_id or achievement_id_list[#achievement_id_list] -- 完成全部取最后一个条目显示
    else
        achievement_id = achievement_id_list[1]
    end
    local achievement_data = SpecMgrs.data_mgr:GetAchievementData(achievement_id)
    UIFuncs.AssignSpriteByIconID(achievement_data.icon, go:FindChild("Icon"):GetComponent("Image"))
    go:FindChild("Desc"):GetComponent("Text").text = self:GetAchievementDesc(achievement_data)
    local reward_item_list = ItemUtil.GetSortedRewardItemList(achievement_data.reward_id)
    local reward_parent = go:FindChild("Scroll View/Viewport/Content")
    for i, item_info in ipairs(reward_item_list) do
        local reward_go = self:GetUIObject(self.reward_temp, reward_parent)
        table.insert(self.item_go_list, reward_go)
        item_info.go = reward_go:FindChild("Item")
        item_info.ui = self
        UIFuncs.InitItemGo(item_info)
    end
    local is_all_done = serv_data and serv_data.achievement_id == nil or false
    local is_can_pick = serv_data and serv_data.is_reach == true or false
    local progress_go = go:FindChild("Progress")
    progress_go:SetActive(not is_all_done)
    if not is_all_done then
        local progress = serv_data and serv_data.progress or 0
        local require_progress = achievement_data.progress
        progress_go:GetComponent("Text").text = UIFuncs.GetPerStr(progress, require_progress, progress >= require_progress)
    end
    local goto_btn = go:FindChild("GotoBtn")
    goto_btn:SetActive(not is_can_pick and not is_all_done)
    self:AddClick(goto_btn, function ()
        SpecMgrs.ui_mgr:JumpUI(achievement_data.jump_ui)
    end)
    local finish_btn = go:FindChild("FinishBtn")
    local effect = UIFuncs.AddCompleteEffect(self, finish_btn)
    table.insert(self.effect_list, effect)
    finish_btn:SetActive(is_can_pick)
    self:AddClick(finish_btn, function ()
        self:SendGetAchievementReward(achievement_type)
    end)
    go:FindChild("Finished"):SetActive(is_all_done)
end

function AchievementUI:SendGetAchievementReward(achievement_type)
    SpecMgrs.msg_mgr:SendMsg("SendGetAchievementReward", {achievement_type = achievement_type})
end

function AchievementUI:ClearAllCompleteEffect()
    for _, effect in ipairs(self.effect_list) do
        effect:EffectEnd()
    end
    self.effect_list = {}
end

return AchievementUI