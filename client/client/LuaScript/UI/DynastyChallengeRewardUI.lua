local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local SlideSelectCmp = require("UI.UICmp.SlideSelectCmp")

local DynastyChallengeRewardUI = class("UI.DynastyChallengeRewardUI", UIBase)

function DynastyChallengeRewardUI:DoInit()
    DynastyChallengeRewardUI.super.DoInit(self)
    self.prefab_path = "UI/Common/DynastyChallengeRewardUI"
    self.reward_box_max_count = SpecMgrs.data_mgr:GetParamData("dynasty_challenge_box_max_count").f_value
    self.dy_dynasty_data = ComMgrs.dy_data_mgr.dynasty_data
    self.chapter_boss_item_dict = {}
    self.reward_item_list = {}
    self.preview_tab_list = {}
    self.chapter_reward_content_list = {}
    self.chapter_reward_item_list = {}
    self.can_pick_reward_dict = {}
end

function DynastyChallengeRewardUI:OnGoLoadedOk(res_go)
    DynastyChallengeRewardUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function DynastyChallengeRewardUI:Hide()
    self.chapter_id = nil
    self.challenge_info = nil
    self.cur_janitor_index = nil
    self.cur_janitor_id = nil
    self:RemoveDynamicUI(self.reward_count_down)
    self:RemoveDynamicUI(self.chapter_preview_count_down)
    self:RemoveKickOutChallengeTimer()
    self.can_pick_reward_dict = {}
    self:ClearBossTabItem()
    self:ClearAllPreviewItem()
    DynastyChallengeRewardUI.super.Hide(self)
end

function DynastyChallengeRewardUI:Show(chapter_id, challenge_info)
    self.chapter_id = chapter_id
    self.challenge_info = challenge_info
    if self.is_res_ok then
        self:InitUI()
    end
    DynastyChallengeRewardUI.super.Show(self)
end

function DynastyChallengeRewardUI:InitRes()
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "DynastyChallengeRewardUI")

    self.tab_panel = self.main_panel:FindChild("TabPanel")
    self.chapter_boss_item = self.tab_panel:FindChild("BossItem")

    local reward_panel = self.main_panel:FindChild("RewardPanel")
    local reward_state = reward_panel:FindChild("RewardState")
    self.reward_count_down = reward_state:FindChild("Text")
    self.reward_count_down_text = self.reward_count_down:GetComponent("Text")
    local preview_btn = reward_state:FindChild("PreviewBtn")
    preview_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.PREVIEW_TEXT
    self:AddClick(preview_btn, function ()
        self:InitRewardPreviewPanel()
    end)
    local reward_list = reward_panel:FindChild("RewardList/View/Content")
    self.reward_list_rect_cmp = reward_list:GetComponent("RectTransform")
    self.reward_list_scroll_cmp = reward_panel:FindChild("RewardList"):GetComponent("ScrollRect")
    local reward_item = reward_list:FindChild("RewardItem")
    for i = 1, self.reward_box_max_count do
        local reward_go = self:GetUIObject(reward_item, reward_list)
        local close_state = reward_go:FindChild("Close")
        self:AddClick(close_state, function ()
            self:SendGetBoxReward(i)
        end)
        close_state:FindChild("RewardIndex"):GetComponent("Text").text = i
        local opened_state = reward_go:FindChild("Opened")
        local data = {}
        data.close_state = close_state
        data.opened_state = opened_state
        data.self = opened_state:FindChild("Self")
        data.icon_bg = opened_state:FindChild("IconBg"):GetComponent("Image")
        data.icon = opened_state:FindChild("IconBg/Icon"):GetComponent("Image")
        data.frame = opened_state:FindChild("IconBg/Frame"):GetComponent("Image")
        data.count = opened_state:FindChild("Count/Text"):GetComponent("Text")
        data.name = opened_state:FindChild("NameBg/Name"):GetComponent("Text")
        self.reward_item_list[i] = data
    end

    self.reward_preview_panel = self.main_panel:FindChild("RewardPreviewPanel")
    local reward_preview_content = self.reward_preview_panel:FindChild("Content")
    self:AddClick(reward_preview_content:FindChild("CloseBtn"), function ()
        self.reward_preview_panel:SetActive(false)
        self:ClearAllPreviewItem()
    end)
    reward_preview_content:FindChild("Title"):GetComponent("Text").text = UIConst.Text.DYNASTY_REWARD_PREVIEW_TEXT
    self.chapter_boss_tab_panel = reward_preview_content:FindChild("TabPanel")
    self.chapter_preview_count_down = reward_preview_content:FindChild("Tip")
    self.chapter_preview_count_down_text = self.chapter_preview_count_down:GetComponent("Text")
    self.list_width = reward_preview_content:FindChild("RewardList"):GetComponent("RectTransform").rect.width
    self.reward_list_content = reward_preview_content:FindChild("RewardList/Content")
    self.reward_list_slide_cmp = SlideSelectCmp.New()
    self.reward_list_slide_cmp:DoInit(self, self.reward_list_content)
    local submit_btn = reward_preview_content:FindChild("Bottom/SubmitBtn")
    submit_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CONFIRM
    self:AddClick(submit_btn, function ()
        self.reward_preview_panel:SetActive(false)
        self:ClearAllPreviewItem()
    end)
    local prefab_list = reward_preview_content:FindChild("PrefabList")
    self.chapter_boss_tab_item = prefab_list:FindChild("Boss")
    self.chapter_boss_box_list_item = prefab_list:FindChild("BossBoxList")
    self.chapter_preview_reward_item = prefab_list:FindChild("RewardItem")
end

function DynastyChallengeRewardUI:InitUI()
    self.chapter_data = SpecMgrs.data_mgr:GetDynastyChallengeData(self.chapter_id)
    if not self.chapter_data then
        self:Hide()
        return
    end
    self:InitKickOutTimer()
    self:InitTabPanel()
end

function DynastyChallengeRewardUI:InitKickOutTimer()
    self:RemoveKickOutChallengeTimer()
    self.kick_out_challenge_timer = SpecMgrs.timer_mgr:AddTimer(function ()
        self.kick_out_challenge_timer = nil
        self:Hide()
    end, Time:GetServerTime() - Time:GetCurDayPassTime() + CSConst.Time.Day, 1)
end

function DynastyChallengeRewardUI:InitTabPanel()
    self:ClearBossTabItem()
    for i, janitor_id in ipairs(self.chapter_data.janitor_list) do
        local janitor_data = SpecMgrs.data_mgr:GetChallengeJanitorData(janitor_id)
        local unit_data = SpecMgrs.data_mgr:GetUnitData(janitor_data.unit_id)
        local chapter_boss_item = self:GetUIObject(self.chapter_boss_item, self.tab_panel)
        UIFuncs.AssignSpriteByIconID(unit_data.icon, chapter_boss_item:FindChild("Icon"):GetComponent("Image"))
        chapter_boss_item:FindChild("Name"):GetComponent("Text").text = janitor_data.name
        chapter_boss_item:FindChild("RedPoint")
        self:AddClick(chapter_boss_item, function ()
            self:ChangeCurChapterBoss(i)
        end)
        local data = {}
        data.select = chapter_boss_item:FindChild("Select")
        data.red_point = chapter_boss_item:FindChild("RedPoint")
        data.item = chapter_boss_item
        self.chapter_boss_item_dict[i] = data
    end
    self:ChangeCurChapterBoss(1)
end

function DynastyChallengeRewardUI:InitRewardPanel(have_get_reward)
    self:RemoveDynamicUI(self.reward_count_down)
    if have_get_reward then
        self.reward_count_down_text.text = UIConst.Text.HAVE_GET_JANITOR_REWARD
    else
        local day_end_time = Time:GetServerTime() - Time:GetCurDayPassTime() + CSConst.Time.Day
        self:AddDynamicUI(self.reward_count_down, function ()
            self.reward_count_down_text.text = string.format(UIConst.Text.REWARD_COUNT_DOWN, UIFuncs.TimeDelta2Str(day_end_time - Time:GetServerTime(), 3, UIConst.Text.COUNT_DOWN_FORMAT))
        end, 1, 0)
    end
end

function DynastyChallengeRewardUI:ChangeCurChapterBoss(janitor_index)
    if self.cur_janitor_index then
        self.chapter_boss_item_dict[self.cur_janitor_index].select:SetActive(false)
    end
    self.cur_janitor_index = janitor_index
    self.cur_janitor_id = self.chapter_data.janitor_list[janitor_index]
    self.chapter_boss_item_dict[self.cur_janitor_index].select:SetActive(true)
    self:InitRewardBoxList()
    self.reward_list_scroll_cmp:StopMovement()
    self.reward_list_rect_cmp.anchoredPosition = Vector2.zero
end

function DynastyChallengeRewardUI:InitRewardBoxList()
    SpecMgrs.msg_mgr:SendGetDynastyChallengeInfo({}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_DYNASTY_CHALLENGE_INFO_FAILED)
        else
            self.challenge_info = resp.challenge_info
            local role_name = ComMgrs.dy_data_mgr:ExGetRoleName()
            local janitor_data = SpecMgrs.data_mgr:GetChallengeJanitorData(self.cur_janitor_id)
            local reward_data = SpecMgrs.data_mgr:GetItemData(janitor_data.box_reward)
            local quality_data = SpecMgrs.data_mgr:GetQualityData(reward_data.quality)
            local chapter_box_dict = self.challenge_info.box_dict[self.chapter_id]
            for index, janitor_id in ipairs(self.chapter_data.janitor_list) do
                local janitor_info = self.challenge_info.stage_dict[self.chapter_id].janitor_dict[janitor_id]
                local hp = self.dy_dynasty_data:CalcJanitorHp(janitor_info.hp_dict)
                local can_pick_flag = hp == 0 and chapter_box_dict ~= nil and chapter_box_dict.box_dict[janitor_id] ~= true
                self.can_pick_reward_dict[index] = can_pick_flag
                self.chapter_boss_item_dict[index].red_point:SetActive(can_pick_flag)
            end
            local have_get_reward = not chapter_box_dict or chapter_box_dict.box_dict[self.cur_janitor_id] == true
            self:InitRewardPanel(have_get_reward)
            for i, reward_box in ipairs(self.challenge_info.stage_dict[self.chapter_id].janitor_dict[janitor_data.id].reward_list) do
                local reward_box_item = self.reward_item_list[i]
                reward_box_item.self:SetActive(reward_box.role_name == role_name)
                reward_box_item.close_state:SetActive(reward_box.role_name == nil)
                reward_box_item.close_state:GetComponent("Button").interactable = self.can_pick_reward_dict[self.cur_janitor_index] == true
                reward_box_item.opened_state:SetActive(reward_box.role_name ~= nil)
                if reward_box.role_name then
                    UIFuncs.AssignSpriteByIconID(quality_data.bg, reward_box_item.icon_bg)
                    UIFuncs.AssignSpriteByIconID(reward_data.icon, reward_box_item.icon)
                    UIFuncs.AssignSpriteByIconID(quality_data.frame, reward_box_item.frame)
                    reward_box_item.count.text = reward_box.value
                    reward_box_item.name.text = reward_box.role_name
                end
            end
        end
    end)
end

function DynastyChallengeRewardUI:InitRewardPreviewPanel()
    self:RemoveDynamicUI(self.chapter_preview_count_down)
    local day_end_time = Time:GetServerTime() - Time:GetCurDayPassTime() + CSConst.Time.Day
    self:AddDynamicUI(self.chapter_preview_count_down, function ()
        self.chapter_preview_count_down_text.text = string.format(UIConst.Text.REWARD_PREVIEW_TIP, UIFuncs.TimeDelta2Str(day_end_time - Time:GetServerTime()))
    end, 1, 0)
    for i, janitor_id in ipairs(self.chapter_data.janitor_list) do
        local janitor_data = SpecMgrs.data_mgr:GetChallengeJanitorData(janitor_id)
        local reward_data = SpecMgrs.data_mgr:GetItemData(janitor_data.box_reward)
        local quality_data = SpecMgrs.data_mgr:GetQualityData(reward_data.quality)
        local chapter_boss_tab_item = self:GetUIObject(self.chapter_boss_tab_item, self.chapter_boss_tab_panel)
        chapter_boss_tab_item:FindChild("Name"):GetComponent("Text").text = janitor_data.name
        self:AddClick(chapter_boss_tab_item, function ()
            if self.cur_preview_index == i then return end
            self.reward_list_slide_cmp:SlideToIndex(i - 1)
        end)
        self.preview_tab_list[i] = {}
        local boss_select = chapter_boss_tab_item:FindChild("Select")
        if i == 1 then
            boss_select:SetActive(true)
            self.cur_preview_index = i
        end
        self.preview_tab_list[i].select = boss_select
        self.preview_tab_list[i].item = chapter_boss_tab_item
        local chapter_reward_list = self:GetUIObject(self.chapter_boss_box_list_item, self.reward_list_content)
        table.insert(self.chapter_reward_content_list, chapter_reward_list)
        for j, reward_count in ipairs(janitor_data.box_reward_value) do
            local chapter_preview_reward_item = self:GetUIObject(self.chapter_preview_reward_item, chapter_reward_list)
            table.insert(self.chapter_reward_item_list, chapter_preview_reward_item)
            local icon_bg = chapter_preview_reward_item:FindChild("IconBg")
            UIFuncs.AssignSpriteByIconID(quality_data.bg, icon_bg:GetComponent("Image"))
            UIFuncs.AssignSpriteByIconID(reward_data.icon, icon_bg:FindChild("Icon"):GetComponent("Image"))
            UIFuncs.AssignSpriteByIconID(quality_data.frame, icon_bg:FindChild("Frame"):GetComponent("Image"))
            icon_bg:FindChild("Count"):GetComponent("Text").text = string.format(UIConst.Text.COUNT, reward_count)
            local res_count = janitor_data.box_reward_num[j]
            for _, reward_data in ipairs(self.challenge_info.stage_dict[self.chapter_id].janitor_dict[janitor_id].reward_list) do
                if reward_count == reward_data.value and reward_data.role_name then res_count = res_count - 1 end
            end
            chapter_preview_reward_item:FindChild("TotalCount"):GetComponent("Text").text = string.format(UIConst.Text.PER_VALUE, res_count, janitor_data.box_reward_num[j])
        end
    end
    self.reward_list_slide_cmp:SetParam(self.list_width, #self.chapter_data.janitor_list)
    self.reward_list_slide_cmp:SetDraggable(true)
    self.reward_list_slide_cmp:ListenSelectUpdate(function (index)
        if self.cur_preview_index == index + 1 then return end
        if self.cur_preview_index then self.preview_tab_list[self.cur_preview_index].select:SetActive(false) end
        self.cur_preview_index = index + 1
        self.preview_tab_list[self.cur_preview_index].select:SetActive(true)
    end)
    self.reward_list_slide_cmp:SetToIndex(0)

    self.reward_preview_panel:SetActive(true)
end

function DynastyChallengeRewardUI:SendGetBoxReward(box_index)
    SpecMgrs.msg_mgr:SendGetJanitorBoxReward({stage_id = self.chapter_id, janitor_index = self.cur_janitor_index, box_index = box_index}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_BOX_REWARD_FAILED)
        end
        if not resp.box_reward then SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.BOX_REWARD_DISABLE) end
        self:InitRewardBoxList()
        self.dy_dynasty_data:NotifyRefreshDynastyChallenge()
    end)
end

function DynastyChallengeRewardUI:RemoveKickOutChallengeTimer()
    if self.kick_out_challenge_timer then
        SpecMgrs.timer_mgr:RemoveTimer(self.kick_out_challenge_timer)
        self.kick_out_challenge_timer = nil
    end
end

function DynastyChallengeRewardUI:ClearBossTabItem()
    for _, data in pairs(self.chapter_boss_item_dict) do
        data.select:SetActive(false)
        self:DelUIObject(data.item)
    end
    self.chapter_boss_item_dict = {}
end

function DynastyChallengeRewardUI:ClearAllPreviewItem()
    for _, reward_item in ipairs(self.chapter_reward_item_list) do
        self:DelUIObject(reward_item)
    end
    self.chapter_reward_item_list = {}

    for _, reward_content in ipairs(self.chapter_reward_content_list) do
        self:DelUIObject(reward_content)
    end
    self.chapter_reward_content_list = {}

    for _, tab_data in ipairs(self.preview_tab_list) do
        tab_data.select:SetActive(false)
        self:DelUIObject(tab_data.item)
    end
    self.preview_tab_list = {}
end

return DynastyChallengeRewardUI