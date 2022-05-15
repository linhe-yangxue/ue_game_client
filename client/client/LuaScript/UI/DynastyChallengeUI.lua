local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local UnitConst = require("Unit.UnitConst")

local DynastyChallengeUI = class("UI.DynastyChallengeUI", UIBase)

local kMaxBossCount = 4
local kStagePerMap = 6
local kChapterOffsetY = 200
local kFixedRankItemCount = 3

function DynastyChallengeUI:DoInit()
    DynastyChallengeUI.super.DoInit(self)
    self.prefab_path = "UI/Common/DynastyChallengeUI"
    self.dy_hero_data = ComMgrs.dy_data_mgr.night_club_data
    self.dy_dynasty_data = ComMgrs.dy_data_mgr.dynasty_data
    self.challenge_recover_time = SpecMgrs.data_mgr:GetParamData("dynasty_challenge_num_time").f_value * CSConst.Time.Hour
    self.challenge_open_time = SpecMgrs.data_mgr:GetParamData("dynasty_challenge_open_time").f_value
    self.challenge_open_sec = self.challenge_open_time * CSConst.Time.Hour
    self.challenge_close_time = SpecMgrs.data_mgr:GetParamData("dynasty_challenge_close_time").f_value
    self.challenge_close_sec = self.challenge_close_time * CSConst.Time.Hour
    self.dynasty_challenge_reward = SpecMgrs.data_mgr:GetParamData("dynasty_challenge_reward").item_id
    self.dynasty_challenge_box_id = SpecMgrs.data_mgr:GetParamData("dynasty_challenge_box").treasure_box_id
    self.map_item_dict = {}
    self.chapter_item_dict = {}
    self.boss_item_list = {}
    self.rank_item_list = {}
    self.chapter_reward_item_list = {}
    self.chapter_reward_state_list = {}
    self.reward_item_list = {}
    self.boss_unit_list = {}
    self.challenge_setting_select_dict = {}
end

function DynastyChallengeUI:OnGoLoadedOk(res_go)
    DynastyChallengeUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function DynastyChallengeUI:Hide()
    if self.refresh_challenge_count_timer then
        self:RemoveTimer(self.refresh_challenge_count_timer)
        self.refresh_challenge_count_timer = nil
    end
    self:ClearGoDict("chapter_item_dict")
    self:ClearGoDict("map_item_dict")
    self:RemoveDynamicUI(self.reset_count_down)
    self:RemoveDynamicUI(self.recover_count_down)
    self.cur_chapter = nil
    self.cur_janitor_index = nil
    self.mask:SetActive(false)
    self:ClearAllCompleteEffect()
    self:RemoveKickOutChallengeTimer()
    self.dy_dynasty_data:UnregisterUpdateDynastyChallengeInfoEvent("DynastyChallengeUI")
    DynastyChallengeUI.super.Hide(self)
end

function DynastyChallengeUI:Show()
    local cur_time = Time:GetCurDayPassTime()
    if cur_time < self.challenge_open_sec or cur_time > self.challenge_close_sec then
        SpecMgrs.ui_mgr:ShowTipMsg(string.format(UIConst.Text.DYNASTY_CHALLENGE_TIME_FORMAT, self.challenge_open_time, self.challenge_close_time))
        return
    end
    if self.is_res_ok then
        self:InitUI()
    end
    DynastyChallengeUI.super.Show(self)
end

function DynastyChallengeUI:InitRes()
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "DynastyChallengeUI", function ()
        if not self.cur_chapter then
            self:Hide()
        else
            self.cur_chapter = nil
            self:UpdateChallengeInfo(function ()
                self:InitChallengeInfo()
                self:InitMapList()
            end)
            self.city_panel:SetActive(false)
        end
    end)

    local info_panel = self.main_panel:FindChild("InfoPanel")
    self.score = info_panel:FindChild("Score/Value"):GetComponent("Text")
    self.cur_chapter_text = info_panel:FindChild("Chapter/Title"):GetComponent("Text")
    local chapter_schedule = info_panel:FindChild("Schedule")
    self.chapter_schedule_value = chapter_schedule:FindChild("Value"):GetComponent("Image")
    self.chapter_schedule_text = chapter_schedule:FindChild("Text"):GetComponent("Text")
    self.reset_count_down = info_panel:FindChild("ResetCountDown")
    self.reset_count_down_text = self.reset_count_down:GetComponent("Text")
    local bottom_panel = self.main_panel:FindChild("BottomPanel")
    local easy_receive_btn = bottom_panel:FindChild("EasyReceiveBtn")
    easy_receive_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.EASY_FINISH
    self.easy_receive_red_point = easy_receive_btn:FindChild("RedPoint")
    self:AddClick(easy_receive_btn, function ()
        self:SendGetChallengeAllReward()
    end)
    local chapter_reset_btn = bottom_panel:FindChild("ChapterResetBtn")
    chapter_reset_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CHAPTER_RESET_TEXT
    self:AddClick(chapter_reset_btn, function ()
        self:InitChapterResetPanel()
        self.chapter_reset_panel:SetActive(true)
    end)
    local clear_reward_btn = bottom_panel:FindChild("ClearRewardBtn")
    clear_reward_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.WIN_REWARD_TEXT
    self.clear_red_point = clear_reward_btn:FindChild("RedPoint")
    self:AddClick(clear_reward_btn, function ()
        self:InitFirstPassAwardPanel()
        self.chapter_reward_list_rect.anchoredPosition = Vector2.New(0, (self.challenge_info.curr_stage - 1) * self.chapter_reward_item_height)
        self.first_pass_award_panel:SetActive(true)
    end)
    local record_btn = bottom_panel:FindChild("RecordBtn")
    record_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.TODAY_RECORD_TEXT
    self:AddClick(record_btn, function ()
        self:InitHurtRankList()
    end)
    self.cur_challenge_count = bottom_panel:FindChild("ChallengeCount/CurCount"):GetComponent("Text")
    self:AddClick(bottom_panel:FindChild("ChallengeCount/AddBtn"), function ()
        self:SendBuyChallengeCount()
    end)
    self.recover_count_down = bottom_panel:FindChild("RecoverCountDown")
    self.recover_count_down_text = self.recover_count_down:GetComponent("Text")

    self.map_list = self.main_panel:FindChild("MapList")
    local map_view = self.map_list:FindChild("View")
    self.map_view_height = map_view:GetComponent("RectTransform").rect.height
    self.map_content = map_view:FindChild("Content")
    self.map_item = self.map_content:FindChild("MapItem")
    self.chapter_item = self.map_item:FindChild("ChapterItem")
    self.map_item_height = self.map_item:GetComponent("RectTransform").rect.height

    self.city_panel = self.main_panel:FindChild("CityPanel")
    self.max_chapter_count = #SpecMgrs.data_mgr:GetAllDynastyChallengeData()
    local reward_btn = self.city_panel:FindChild("RewardBtn")
    self.reward_box = UIFuncs.GetTreasureBox(self, reward_btn:FindChild("Reward"), self.dynasty_challenge_box_id)
    reward_btn:FindChild("Image/Text"):GetComponent("Text").text = UIConst.Text.CHALLENGE_REWARD_TEXT
    self.reward_red_point = reward_btn:FindChild("RedPoint")
    self:AddClick(self.reward_box, function ()
        SpecMgrs.ui_mgr:ShowUI("DynastyChallengeRewardUI", self.cur_chapter, self.challenge_info.stage_dict[self.cur_chapter])
    end)
    for i = 1, kMaxBossCount do
        local data = {}
        local boss_item = self.city_panel:FindChild("Boss" .. i)
        data.name = boss_item:FindChild("Name"):GetComponent("Text")
        data.blood_bar_value = boss_item:FindChild("BloodBar/Value"):GetComponent("Image")
        local boss_dead = boss_item:FindChild("Dead")
        boss_dead:FindChild("Text"):GetComponent("Text").text = UIConst.Text.BOSS_DEFEAT_TEXT
        data.dead = boss_dead
        data.model = boss_item:FindChild("Model")
        data.boss_item = boss_item
        self.boss_item_list[i] = data
    end

    self.chapter_reset_panel = self.main_panel:FindChild("ChapterResetPanel")
    local chapter_reset_content = self.chapter_reset_panel:FindChild("Content")
    chapter_reset_content:FindChild("Title"):GetComponent("Text").text = UIConst.Text.CHAPTER_RESET_TEXT
    self:AddClick(chapter_reset_content:FindChild("CloseBtn"), function ()
        self.chapter_reset_panel:SetActive(false)
    end)
    chapter_reset_content:FindChild("Tip"):GetComponent("Text").text = UIConst.Text.CHAPTER_RESET_TYPE_TEXT
    -- 普通重置
    local normal_reset_toggle = chapter_reset_content:FindChild("NormalResetToggle")
    self.challenge_setting_select_dict[CSConst.ChallengeSetting.Reset] = normal_reset_toggle:FindChild("Selected")
    self.normal_reset_toggle_cmp = normal_reset_toggle:GetComponent("Toggle")
    self:AddToggle(normal_reset_toggle, function (is_on)
        if self.challenge_info.setting[CSConst.ChallengeSetting.Reset] ~= true and is_on == true then
            self:SendChangeChallengeSetting(CSConst.ChallengeSetting.Reset)
        end
    end)
    local normal_reset_toggle_content = normal_reset_toggle:FindChild("Content")
    normal_reset_toggle_content:FindChild("Title"):GetComponent("Text").text = UIConst.Text.NORMAL_RESET_TEXT
    normal_reset_toggle_content:FindChild("Desc"):GetComponent("Text").text = UIConst.Text.NORMAL_RESET_TIP
    self.normal_reset_chapter = normal_reset_toggle_content:FindChild("ResetChapter"):GetComponent("Text")
    normal_reset_toggle_content:FindChild("Select/Text"):GetComponent("Text").text = UIConst.Text.SELECT_TEXT
    local normal_reset_select = normal_reset_toggle:FindChild("Selected")
    normal_reset_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.JOB_SELECTED
    -- 章节回退
    local chapter_reset_toggle = chapter_reset_content:FindChild("ChapterResetToggle")
    self.challenge_setting_select_dict[CSConst.ChallengeSetting.Back] = chapter_reset_toggle:FindChild("Selected")
    self.chapter_reset_toggle_cmp = chapter_reset_toggle:GetComponent("Toggle")
    self:AddToggle(chapter_reset_toggle, function (is_on)
        if self.challenge_info.setting[CSConst.ChallengeSetting.Back] ~= true and is_on == true then
            self:SendChangeChallengeSetting(CSConst.ChallengeSetting.Back)
        end
    end)
    local chapter_reset_toggle_content = chapter_reset_toggle:FindChild("Content")
    chapter_reset_toggle_content:FindChild("Title"):GetComponent("Text").text = UIConst.Text.CHAPTER_BACK_RESET_TEXT
    chapter_reset_toggle_content:FindChild("Desc"):GetComponent("Text").text = UIConst.Text.CHAPTER_BACK_RESET_TIP
    self.chapter_reset_chapter = chapter_reset_toggle_content:FindChild("ResetChapter"):GetComponent("Text")
    chapter_reset_toggle_content:FindChild("Select/Text"):GetComponent("Text").text = UIConst.Text.SELECT_TEXT
    local chapter_reset_select = chapter_reset_toggle:FindChild("Selected")
    chapter_reset_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.JOB_SELECTED
    self.highest_chapter = chapter_reset_content:FindChild("HighestChapter/Text"):GetComponent("Text")
    -- 副本确认界面
    self.chapter_hero_panel = self.main_panel:FindChild("ChapterHeroPanel")
    local chapter_hero_content = self.chapter_hero_panel:FindChild("Content")
    self.chapter_hero_title = chapter_hero_content:FindChild("Top/Title"):GetComponent("Text")
    self:AddClick(chapter_hero_content:FindChild("Top/CloseBtn"), function ()
        self.cur_janitor_index = nil
        self.chapter_hero_panel:SetActive(false)
    end)
    local chapter_hero_info = chapter_hero_content:FindChild("Info")
    self.chapter_hero_blood = chapter_hero_info:FindChild("BloodBar/Value"):GetComponent("Image")
    local lineup_btn = chapter_hero_info:FindChild("LineUpBtn")
    lineup_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.LINEUP
    self:AddClick(lineup_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("SmallLineupUI")
    end)
    self.beat_reward = chapter_hero_info:FindChild("BeatReward"):GetComponent("Text")
    local chapter_hero_reward = chapter_hero_content:FindChild("Reward")
    chapter_hero_reward:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.CHALLENGE_REWARD
    local dedicate_data = SpecMgrs.data_mgr:GetItemData(CSConst.Virtual.Dedicate)
    local quality_data = SpecMgrs.data_mgr:GetQualityData(dedicate_data.quality)
    UIFuncs.AssignSpriteByIconID(quality_data.bg, chapter_hero_reward:FindChild("Info/IconBg"):GetComponent("Image"))
    UIFuncs.AssignSpriteByIconID(dedicate_data.icon, chapter_hero_reward:FindChild("Info/IconBg/Icon"):GetComponent("Image"))
    UIFuncs.AssignSpriteByIconID(quality_data.frame, chapter_hero_reward:FindChild("Info/IconBg/Image"):GetComponent("Image"))
    chapter_hero_reward:FindChild("Info/RewardName"):GetComponent("Text").text = dedicate_data.name
    self.chapter_reward_count = chapter_hero_reward:FindChild("Info/RewardCount"):GetComponent("Text")
    self.beat_reward_tip = chapter_hero_reward:FindChild("Info/BeatTip"):GetComponent("Text")
    self.chapter_challenge_count = chapter_hero_content:FindChild("Bottom/ChallengeCount/Count"):GetComponent("Text")
    self:AddClick(chapter_hero_content:FindChild("Bottom/ChallengeCount/AddBtn"), function ()
        self:SendBuyChallengeCount()
    end)
    local challenge_btn = chapter_hero_content:FindChild("ChallengeBtn")
    challenge_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CHALLENGE_TEXT
    self:AddClick(challenge_btn, function ()
        self:SendChallengeJanitor()
    end)
    -- 首次通关奖励
    self.first_pass_award_panel = self.main_panel:FindChild("FirstPassAwardPanel")
    local first_pass_award_content = self.first_pass_award_panel:FindChild("Content")
    first_pass_award_content:FindChild("Top/Text"):GetComponent("Text").text = UIConst.Text.CLEAR_CHAPTER_REWARD_TEXT
    self:AddClick(first_pass_award_content:FindChild("Top/CloseBtn"), function ()
        self.first_pass_award_panel:SetActive(false)
    end)
    local chapter_reward_list_content = first_pass_award_content:FindChild("ChapterRewardList/View/Content")
    self.chapter_reward_list_rect = chapter_reward_list_content:GetComponent("RectTransform")
    local chapter_reward_item = chapter_reward_list_content:FindChild("Item")
    self.chapter_reward_item_height = chapter_reward_item:GetComponent("RectTransform").rect.height
    chapter_reward_item:FindChild("Bottom/Status/GetBtn/Text"):GetComponent("Text").text = UIConst.Text.RECEIVE_TEXT
    local reward_item_pref = chapter_reward_item:FindChild("Bottom/AwardItemList/View/Content/Item")
    local chapter_list = SpecMgrs.data_mgr:GetAllDynastyChallengeData()
    for i = 1, #chapter_list do
        local reward_item = self:GetUIObject(chapter_reward_item, chapter_reward_list_content)
        table.insert(self.chapter_reward_item_list, reward_item)
        local name_format = chapter_list[i].name or UIConst.Text.CHAPTER_DEFAULT_NAME_FORMAT
        reward_item:FindChild("Title/Text"):GetComponent("Text").text = string.format(name_format, i)
        local reward_data = SpecMgrs.data_mgr:GetRewardData(chapter_list[i].reward_id)
        local reward_list = reward_item:FindChild("Bottom/AwardItemList/View/Content")
        for j, item_id in ipairs(reward_data.reward_item_list) do
            local item = self:GetUIObject(reward_item_pref, reward_list)
            table.insert(self.reward_item_list, item)
            UIFuncs.InitItemGo({
                go = item,
                item_id = item_id,
                count = reward_data.reward_num_list[j],
                ui = self,
            })
        end
        local state_list = {}
        local state_panel = reward_item:FindChild("Bottom/Status")
        state_list.not_pass = state_panel:FindChild("NotPass")
        local get_btn = state_panel:FindChild("GetBtn")
        self:AddClick(get_btn, function ()
            self:SendGetChallengeStageReward(i)
        end)
        state_list.get_btn = get_btn
        state_list.already_get = state_panel:FindChild("AlreadyGet")
        self.chapter_reward_state_list[i] = state_list
    end

    -- 伤害排名
    self.hurt_rank_list = self.main_panel:FindChild("HurtRankList")
    UIFuncs.InitTopBar(self, self.hurt_rank_list:FindChild("TopBar"), "HurtRankList", function ()
        self.hurt_rank_list:SetActive(false)
    end)
    local content = self.hurt_rank_list:FindChild("Content")
    self.rank_list_content = content:FindChild("RankList/View/Content")
    local first_place = self.rank_list_content:FindChild("First")
    table.insert(self.rank_item_list, first_place)
    local second_place = self.rank_list_content:FindChild("Second")
    table.insert(self.rank_item_list, second_place)
    local third_place = self.rank_list_content:FindChild("Third")
    table.insert(self.rank_item_list, third_place)
    self.rank_item = self.rank_list_content:FindChild("RankItem")
    local head = content:FindChild("Head")
    head:FindChild("Rank"):GetComponent("Text").text = UIConst.Text.RANK_TEXT
    head:FindChild("Name"):GetComponent("Text").text = UIConst.Text.PLAYER_TEXT
    head:FindChild("Count"):GetComponent("Text").text = UIConst.Text.CHALLENGE_COUNT_TEXT
    head:FindChild("Hurt"):GetComponent("Text").text = UIConst.Text.HURT_TEXT

    local bottom_panel = self.hurt_rank_list:FindChild("BottomPanel")
    self.self_ranking_text = bottom_panel:FindChild("Ranking"):GetComponent("Text")
    self.self_count_text = bottom_panel:FindChild("Count"):GetComponent("Text")
    self.self_hurt_text = bottom_panel:FindChild("Hurt"):GetComponent("Text")

    self.mask = self.main_panel:FindChild("Mask")
end

function DynastyChallengeUI:InitUI()
    SpecMgrs.msg_mgr:SendGetDynastyMemberInfo({}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_DYNASTY_MEMBER_INFO_FAILED)
        else
            self.self_info = resp.member_dict[ComMgrs.dy_data_mgr:ExGetRoleUuid()]
            self:InitChallengeStartTime()
            self:UpdateChallengeInfo(function ()
                self:InitChallengeInfo()
                self:InitMapList()
                self:UpdateChallengeCount()
            end)
        end
    end)
    self:RegisterEvent(ComMgrs.dy_data_mgr, "UpdateCurrencyEvent", function (_, currency)
        UIFuncs.UpdateCurrencyItemNum(self._item_to_text_list, currency)
    end)
    self.dy_dynasty_data:RegisterUpdateDynastyChallengeInfoEvent("DynastyChallengeUI", function (_, challenge_info)
        self.challenge_info = challenge_info
        self:InitChapterInfo()
        self:InitFirstPassAwardPanel()
    end)
end

function DynastyChallengeUI:UpdateChallengeInfo(update_func)
    SpecMgrs.msg_mgr:SendGetDynastyChallengeInfo({}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_DYNASTY_CHALLENGE_INFO_FAILED)
        else
            self.challenge_info = resp.challenge_info
            if update_func then update_func(self) end
        end
    end)
end

function DynastyChallengeUI:InitChallengeInfo()
    self.score.text = self.dy_hero_data:GetHeroScoreSum()
    self:RemoveDynamicUI(self.reset_count_down)
    local reset_chapter = math.max(self.challenge_info.curr_stage - (self.challenge_info.setting[CSConst.ChallengeSetting.Reset] and 0 or 1), 1)
    local challenge_end_second = Time:GetServerTime() - Time:GetCurDayPassTime() + CSConst.Time.Day
    self.clear_red_point:SetActive(self.dy_dynasty_data:CheckHaveClearReward(self.challenge_info))
    self:AddDynamicUI(self.reset_count_down, function ()
        self.reset_count_down_text.text = string.format(UIConst.Text.CHAPTER_RESET_FORMAT, UIFuncs.TimeDelta2Str(challenge_end_second - Time:GetServerTime()), reset_chapter)
    end, 1, 0)
end

function DynastyChallengeUI:InitMapList()
    local open_map_count = self.dy_dynasty_data:CalcOpenMapCount(self.challenge_info.curr_stage)
    local map_data_list = SpecMgrs.data_mgr:GetDynastyChallengeMapList()
    local map_count = #map_data_list
    local height = 0
    local stage_index = 0
    for i = 1, open_map_count do
        local map_item = self.map_item_dict[i] or self:GetUIObject(self.map_item, self.map_content)
        local map_data = map_data_list[(i - 1) % map_count + 1]
        if not self.map_item_dict[i] then
            self.map_item_dict[i] = map_item
            UIFuncs.AssignUISpriteSync(map_data.res_path, map_data.res_name, map_item:GetComponent("Image"))
            map_item:GetComponent("RectTransform").anchoredPosition = Vector2.New(0, (i - 1) * self.map_item_height)
            --地图克隆倒序排列，解决层级问题
            map_item:SetSiblingIndex(open_map_count - i)
        end
        for j = 1, map_data.chapter_count do
            stage_index = stage_index + 1
            local chapter_data = SpecMgrs.data_mgr:GetDynastyChallengeData(stage_index)
            local chapter_item = self.chapter_item_dict[stage_index] or self:GetUIObject(self.chapter_item, map_item)
            if not self.chapter_item_dict[stage_index] then
                self.chapter_item_dict[stage_index] = chapter_item
                chapter_item:SetSiblingIndex(0)
                local build_img_cmp = chapter_item:FindChild("Build"):GetComponent("Image")
                UIFuncs.AssignSpriteByIconID(map_data.building_icon[j], build_img_cmp)
                build_img_cmp:SetNativeSize()
                chapter_item:GetComponent("RectTransform").anchoredPosition = Vector2.New(map_data.pos_x[j], map_data.pos_y[j])
            end
            local chapter_info_item = chapter_item:FindChild("Chapter")
            chapter_info_item:SetActive(chapter_data ~= nil)
            chapter_info_item:FindChild("RedPoint"):SetActive(self.dy_dynasty_data:CheckChapterHaveUnpickReward(self.challenge_info, stage_index))
            if chapter_data then
                local chapter_state = chapter_info_item:FindChild("State")
                local active_panel = chapter_state:FindChild("Active")
                local chapter_schedule = chapter_info_item:FindChild("Schedule")
                local total_rest_hp = 0
                local total_max_hp = 0
                if self.challenge_info.stage_dict[stage_index] and stage_index <= self.challenge_info.curr_stage then
                    for janitor_id , janitor_info in pairs(self.challenge_info.stage_dict[stage_index].janitor_dict) do
                        total_max_hp = total_max_hp + janitor_info.max_hp
                        total_rest_hp = total_rest_hp + self.dy_dynasty_data:CalcJanitorHp(janitor_info.hp_dict)
                    end
                end
                local chapter_name_format = chapter_data.name or UIConst.Text.CHAPTER_DEFAULT_NAME_FORMAT
                local chapter_name = string.format(chapter_name_format, chapter_data.id)
                chapter_info_item:FindChild("NamePanel/Name"):GetComponent("Text").text = chapter_name
                if stage_index == self.challenge_info.curr_stage then
                    height = (i - 1) * self.map_item_height + chapter_item:GetComponent("RectTransform").anchoredPosition.y + self.map_view_height - kChapterOffsetY
                    chapter_schedule:FindChild("Value"):GetComponent("Image").fillAmount = total_rest_hp / total_max_hp
                    self.cur_chapter_text.text = chapter_name
                    self.chapter_schedule_value.fillAmount = total_rest_hp / total_max_hp
                    self.chapter_schedule_text.text = string.format(UIConst.Text.PERCENT, math.ceil(total_rest_hp / total_max_hp * 100))
                end
                active_panel:SetActive(stage_index == self.challenge_info.curr_stage and total_rest_hp > 0)
                chapter_schedule:SetActive(stage_index == self.challenge_info.curr_stage and total_rest_hp > 0)
                chapter_state:FindChild("Disable"):SetActive(stage_index > self.challenge_info.curr_stage)
                chapter_state:FindChild("Finish"):SetActive(stage_index <= self.challenge_info.curr_stage and total_rest_hp == 0)
                self:AddClick(chapter_state, function ()
                    if chapter_data.id > self.challenge_info.curr_stage then
                        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.CHALLENGE_CHAPTER_LOCK)
                        return
                    end
                    if not self.challenge_info.stage_dict[chapter_data.id] then
                        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.CHALLENGE_CHAPTER_LIMIT)
                        return
                    end
                    self.cur_chapter = chapter_data.id
                    self:UpdateChallengeInfo(function ()
                        self:InitChapterInfo()
                        self.city_panel:SetActive(true)
                    end)
                end)
            end
        end
    end
    local map_content_rect = self.map_content:GetComponent("RectTransform")
    map_content_rect.sizeDelta = Vector2.New(0, height)
    map_content_rect.anchoredPosition = Vector2.New(0, self.map_view_height - height)
end

function DynastyChallengeUI:InitChallengeStartTime()
    self.challenge_open_second = Time:GetServerTime() - Time:GetCurDayPassTime() + self.challenge_open_sec
    self.challenge_end_second = Time:GetServerTime() - Time:GetCurDayPassTime() + self.challenge_close_sec
    self:RemoveKickOutChallengeTimer()
    self.kick_out_challenge_timer = self:AddTimer(function ()
        self.kick_out_challenge_timer = nil
        self:Hide()
    end, Time:GetServerTime() - Time:GetCurDayPassTime() + CSConst.Time.Day, 1)
end

function DynastyChallengeUI:UpdateChallengeCount()
    self.cur_challenge_count.text = string.format(UIConst.Text.CHALLENGE_COUNT_FORMAT, self.challenge_info.challenge_num)
    self.chapter_challenge_count.text = string.format(UIConst.Text.CHALLENGE_COUNT_FORMAT, self.challenge_info.challenge_num)
    if self.challenge_info.challenge_num_ts then
        self:RemoveDynamicUI(self.recover_count_down)
        local recover_time = self.challenge_info.challenge_num_ts
        self:AddDynamicUI(self.recover_count_down, function ()
            self.recover_count_down_text.text = string.format(UIConst.Text.CHALLENGE_RECOVER_FORMAT, UIFuncs.TimeDelta2Str(recover_time - Time:GetServerTime()))
        end, 1, 0)
        self.refresh_challenge_count_timer = self:AddTimer(function ()
            self:UpdateChallengeInfo(function ()
                self:UpdateChallengeCount()
            end)
        end, recover_time - Time:GetServerTime())
    else
        self.recover_count_down_text.text = UIConst.Text.CHALLENGE_COUNT_RECOVER_LIMIT
    end
end

function DynastyChallengeUI:InitChapterInfo()
    self:ClearBossUnit()
    local chapter_data = SpecMgrs.data_mgr:GetDynastyChallengeData(self.cur_chapter)
    local janitor_dict = self.challenge_info.stage_dict[self.cur_chapter].janitor_dict
    local total_hp = 0
    local total_max_hp = 0
    for i = 1, kMaxBossCount do
        local janitor_data = SpecMgrs.data_mgr:GetChallengeJanitorData(chapter_data.janitor_list[i])
        local boss_data = self.boss_item_list[i]
        boss_data.boss_item:SetActive(janitor_data ~= nil)
        if janitor_data then
            boss_data.name.text = janitor_data.name
            local cur_hp = self.dy_dynasty_data:CalcJanitorHp(janitor_dict[janitor_data.id].hp_dict)
            total_hp = total_hp + cur_hp
            total_max_hp = total_max_hp + janitor_dict[janitor_data.id].max_hp
            local boss_unit = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = janitor_data.unit_id, parent = boss_data.model, need_sync_load = true})
            table.insert(self.boss_unit_list, boss_unit)
            boss_unit:SetPositionByRectName({parent = boss_data.model, name = UnitConst.UnitRect.Full})
            boss_data.blood_bar_value.fillAmount = cur_hp / janitor_dict[janitor_data.id].max_hp
            boss_data.dead:SetActive(cur_hp == 0)
            boss_data.boss_item:GetComponent("Button").interactable = cur_hp > 0
            if cur_hp > 0 then
                self:AddClick(boss_data.boss_item, function ()
                    self.cur_janitor_index = i
                    self:InitChapterHeroPanel()
                    self.chapter_hero_panel:SetActive(true)
                end)
            else
                boss_unit:StopAllAnimationToCurPos()
                boss_unit:ChangeToGray()
            end
        end
    end
    local can_pick = self.dy_dynasty_data:CheckChapterHaveUnpickReward(self.challenge_info, self.cur_chapter)
    UIFuncs.UpdateTreasureBoxStatus(self.reward_box, can_pick)
    self.reward_red_point:SetActive(can_pick)
    self.cur_chapter_text.text = string.format(chapter_data.name, chapter_data.id)
    self.chapter_schedule_value.fillAmount = total_hp / total_max_hp
    self.chapter_schedule_text.text = string.format(UIConst.Text.PERCENT, math.ceil(total_hp / total_max_hp * 100))
end

function DynastyChallengeUI:InitChapterResetPanel()
    self.normal_reset_chapter.text = string.format(UIConst.Text.CHAPTER_RESET_PREVIEW, self.challenge_info.curr_stage)
    self.chapter_reset_chapter.text = string.format(UIConst.Text.CHAPTER_RESET_PREVIEW, math.max(self.challenge_info.curr_stage - 1, 1))
    local is_reset = self.challenge_info.setting[CSConst.ChallengeSetting.Reset]
    self.normal_reset_toggle_cmp.isOn = is_reset
    self.challenge_setting_select_dict[CSConst.ChallengeSetting.Reset]:SetActive(is_reset)
    local is_back = self.challenge_info.setting[CSConst.ChallengeSetting.Back]
    self.chapter_reset_toggle_cmp.isOn = is_back
    self.challenge_setting_select_dict[CSConst.ChallengeSetting.Back]:SetActive(is_back)
    self.highest_chapter.text = string.format(UIConst.Text.HIGHEST_CHAPTER, self.challenge_info.max_victory_stage)
end

function DynastyChallengeUI:InitChapterHeroPanel()
    local chapter_data = SpecMgrs.data_mgr:GetDynastyChallengeData(self.cur_chapter)
    local janitor_data = SpecMgrs.data_mgr:GetChallengeJanitorData(chapter_data.janitor_list[self.cur_janitor_index])
    self.chapter_hero_title.text = janitor_data.name
    local janitor_info = self.challenge_info.stage_dict[self.cur_chapter].janitor_dict[janitor_data.id]
    local janitor_cur_hp = self.dy_dynasty_data:CalcJanitorHp(janitor_info.hp_dict)
    if janitor_cur_hp == 0 then
        self.chapter_hero_panel:SetActive(false) 
        return
    end
    self.chapter_hero_blood.fillAmount = janitor_cur_hp / janitor_info.max_hp
    self.beat_reward.text = string.format(UIConst.Text.BEAT_REWARD, janitor_data.dynasty_kill_reward)
    self.chapter_reward_count.text = string.format(UIConst.Text.REWARD_COUNT, janitor_data.reward_range[1], janitor_data.reward_range[2])
    self.beat_reward_tip.text = string.format(UIConst.Text.BEAT_TIP, janitor_data.player_kill_reward)
    self.chapter_challenge_count.text = string.format(UIConst.Text.CHALLENGE_COUNT_FORMAT, self.challenge_info.challenge_num)
end

function DynastyChallengeUI:InitFirstPassAwardPanel()
    self:ClearAllCompleteEffect()
    for i, chapter_reward_item in ipairs(self.chapter_reward_state_list) do
        chapter_reward_item.not_pass:SetActive(i > self.challenge_info.max_victory_stage)
        chapter_reward_item.get_btn:SetActive(i <= self.challenge_info.max_victory_stage and self.challenge_info.challenge_reward[i] ~= true)
        if i <= self.challenge_info.max_victory_stage and self.challenge_info.challenge_reward[i] ~= true then
            chapter_reward_item.effect = UIFuncs.AddCompleteEffect(self, chapter_reward_item.get_btn)
        end
        chapter_reward_item.already_get:SetActive(self.challenge_info.challenge_reward[i] == true)
    end
end

function DynastyChallengeUI:InitHurtRankList()
    SpecMgrs.msg_mgr:SendGetDynastyChallengeRank({}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_DYNASTY_CHALLENGE_RANK_FAILED)
        else
            local count = #resp.rank_list
            if count < kFixedRankItemCount then
                for i = count + 1, kFixedRankItemCount do
                    self.rank_item_list[i]:SetActive(false)
                end
            end
            for i, rank_data in ipairs(resp.rank_list) do
                local rank_item
                if i <= kFixedRankItemCount then
                    rank_item = self.rank_item_list[i]
                    rank_item:SetActive(true)
                else
                    rank_item = self:GetUIObject(self.rank_item, self.rank_list_content)
                    rank_item:FindChild("Ranking/Text"):GetComponent("Text").text = i
                    table.insert(self.rank_item_list, rank_item)
                end
                local role_unit_id = SpecMgrs.data_mgr:GetRoleLookData(rank_data.role_id).unit_id
                UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetUnitData(role_unit_id).icon, rank_item:FindChild("IconBg/Icon"):GetComponent("Image"))
                rank_item:FindChild("Name"):GetComponent("Text").text = rank_data.name
                rank_item:FindChild("Count"):GetComponent("Text").text = rank_data.challenge_num
                rank_item:FindChild("Hurt"):GetComponent("Text").text = UIFuncs.AddCountUnit(rank_data.max_hurt)
            end
            self.self_ranking_text.text = string.format(UIConst.Text.MAX_HURT_RANK, resp.self_rank.rank or UIConst.Text.TEMPLY_NOT)
            self.self_count_text.text = string.format(UIConst.Text.CUR_CHALLENGE_COUNT, resp.self_rank.challenge_num or 0)
            self.self_hurt_text.text = string.format(UIConst.Text.CUR_CHALLENGE_HURT, UIFuncs.AddCountUnit(resp.self_rank.max_hurt or 0))
            self.hurt_rank_list:SetActive(true)
        end
    end)
end

-- msg
function DynastyChallengeUI:SendGetChallengeAllReward()
    SpecMgrs.msg_mgr:SendGetChallengeAllReward({}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.EASY_GET_REWARD_FAILED)
        else
            local reward_list = {}
            for item_id, count in pairs(resp.reward_dict) do
                local reward_data = {}
                reward_data.item_id = item_id
                reward_data.item_data = SpecMgrs.data_mgr:GetItemData(item_id)
                reward_data.count = count
                table.insert(reward_list, reward_data)
            end
            if #reward_list == 0 then return end
            SpecMgrs.ui_mgr:ShowUI("GetItemUI", reward_list)
            self:UpdateChallengeInfo(function ()
                self:InitFirstPassAwardPanel()
                self:InitChallengeInfo()
                if self.cur_chapter then
                    self:InitChapterInfo()
                else
                    self:InitMapList()
                end
            end)
        end
    end)
end

function DynastyChallengeUI:SendBuyChallengeCount()
    local cur_second = Time:GetServerTime()
    if cur_second < self.challenge_open_second or cur_second > self.challenge_end_second then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.DYNASTY_CHALLENGE_TIME_LIMIT)
        return
    end
    local cur_buy_count = self.challenge_info.buy_challenge_num
    local max_buy_count = #SpecMgrs.data_mgr:GetAllChallengeNumData()
    if cur_buy_count >= max_buy_count then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.BUY_CHALLENGE_COUNT_LIMIT)
        return
    end
    local data = {
        title = UIConst.Text.BUT_CHALLENGE_COUNT,
        get_content_func = function (select_num)
            local cost_dict = {}
            for i = cur_buy_count + 1, cur_buy_count + select_num do
                local cost_data = SpecMgrs.data_mgr:GetChallengeNumData(i)
                cost_dict[cost_data.cost_item] = (cost_dict[cost_data.cost_item] or 0) + cost_data.cost_num
            end
            local cost_str
            for item_id, count in pairs(cost_dict) do
                local item_data = SpecMgrs.data_mgr:GetItemData(item_id)
                local cur_str = string.format(UIConst.Text.COST_ITEM_FORMAT, item_data.name, count)
                if not cost_str then
                    cost_str = cur_str
                else
                    cost_str = string.format(UIConst.Text.AND_VALUE, cost_str, cur_str)
                end
            end
            local ret_str = string.format(UIConst.Text.BUT_CHALLENGE_COUNT_FORMAT, cost_str, select_num)
            return {item_dict = cost_dict, desc_str = ret_str}
        end,
        max_select_num = max_buy_count - cur_buy_count,
        confirm_cb = function (select_num)
            SpecMgrs.msg_mgr:SendBuyChallengeCount({buy_num = select_num}, function (resp)
                if resp.errcode ~= 0 then
                    SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.BUY_CHALLENGE_COUNT_FAILED)
                else
                    self:UpdateChallengeInfo(function ()
                        self:UpdateChallengeCount()
                    end)
                end
            end)
        end,
    }
    SpecMgrs.ui_mgr:ShowSelectItemUseByTb(data)
end

function DynastyChallengeUI:SendChangeChallengeSetting(setting)
    if self.self_info.job == CSConst.DynastyJob.Member then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.CHANGE_RESET_SETTING_LIMIT)
        self:InitChapterResetPanel()
        return
    end
    SpecMgrs.msg_mgr:SendChangeChallengeSetting({setting_type = setting}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.SET_CHAPTER_RESET_TYPE_FAILED)
        else
            self:UpdateChallengeInfo(function ()
                self:InitChallengeInfo()
                self:InitChapterResetPanel()
            end)
        end
    end)
end

function DynastyChallengeUI:SendChallengeJanitor()
    local cur_second = Time:GetServerTime()
    if cur_second < self.challenge_open_second or cur_second > self.challenge_end_second then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.DYNASTY_CHALLENGE_TIME_LIMIT)
        return
    end
    if self.challenge_info.challenge_num <= 0 then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.CHALLENGE_COUNT_LIMIT)
        return
    end
    if not ComMgrs.dy_data_mgr.night_club_data:CheckHeroLineup(true) then return end
    local chapter_data = SpecMgrs.data_mgr:GetDynastyChallengeData(self.cur_chapter)
    local janitor_data = SpecMgrs.data_mgr:GetChallengeJanitorData(chapter_data.janitor_list[self.cur_janitor_index])
    local cur_hp = self.dy_dynasty_data:CalcJanitorHp(self.challenge_info.stage_dict[self.cur_chapter].janitor_dict[janitor_data.id].hp_dict)
    if cur_hp == 0 then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.JANITOR_DISABLE)
        return
    end
    self.mask:SetActive(true)
    SpecMgrs.msg_mgr:SendChallengeJanitor({janitor_index = self.cur_janitor_index}, function (resp)
        self.mask:SetActive(false)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.CHALLENGE_REQUEST_FAILED)
        else
            if not resp.fight_data then
                SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.JANITOR_DISABLE)
                self:UpdateChallengeInfo(function ()
                    self:InitChapterInfo()
                    self:InitChapterHeroPanel()
                end)
                return
            end
            SpecMgrs.ui_mgr:EnterHeroBattle(resp.fight_data, UIConst.BattleScence.DynastyChallengeUI)
            SpecMgrs.ui_mgr:RegiseHeroBattleEnd("DynastyChallengeUI", function()
                self:BattleEnd(resp)
            end)
        end
    end)
end

function DynastyChallengeUI:BattleEnd(resp)
    local reward_dict = {}
    for item_id, count in pairs(resp.challenge_reward) do
        reward_dict[item_id] = {count = count}
    end
    local win_tip = string.format(UIConst.Text.CHALLENGE_HURT_FORMAT, resp.hurt)
    if resp.is_win then
        local chapter_data = SpecMgrs.data_mgr:GetDynastyChallengeData(self.cur_chapter)
        local janitor_data = SpecMgrs.data_mgr:GetChallengeJanitorData(chapter_data.janitor_list[self.cur_janitor_index])
        win_tip = win_tip .. string.format(UIConst.Text.BEAT_REWARD_FORMAT, janitor_data.player_kill_reward)
    end
    local param_tb = {
        is_win = resp.is_win,
        reward = reward_dict,
        win_tip = win_tip,
        func = function ()
            self:UpdateChallengeInfo(function ()
                self:InitChallengeInfo()
                self:InitChapterInfo()
                self:UpdateChallengeCount()
                self:InitChapterHeroPanel()
            end)
        end,
    }
    SpecMgrs.ui_mgr:AddCloseBattlePopUpList("BattleResultUI", param_tb)
end

function DynastyChallengeUI:SendGetChallengeStageReward(stage_id)
    SpecMgrs.msg_mgr:SendGetChallengeStageReward({stage_id = stage_id}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_STAGE_REWARD_FAILED)
        else
            self.dy_dynasty_data:NotifyRefreshDynastyChallenge()
        end
    end)
end

function DynastyChallengeUI:RemoveKickOutChallengeTimer()
    if self.kick_out_challenge_timer then
        self:RemoveTimer(self.kick_out_challenge_timer)
        self.kick_out_challenge_timer = nil
    end
end

function DynastyChallengeUI:ClearAllCompleteEffect()
    for _, reward_item in ipairs(self.chapter_reward_state_list) do
        if reward_item.effect then
            self:RemoveUIEffect(reward_item.effect)
            reward_item.effect = nil
        end
    end
end

function DynastyChallengeUI:ClearBossUnit()
    for _, unit in ipairs(self.boss_unit_list) do
        ComMgrs.unit_mgr:DestroyUnit(unit)
    end
    self.boss_unit_list = {}
end

function DynastyChallengeUI:DoDestroy()
    for _, item in ipairs(self.reward_item_list) do
        self:DelUIObject(item)
    end
    self.reward_item_list = {}
    for _, item in ipairs(self.chapter_reward_item_list) do
        self:DelUIObject(item)
    end
    self.chapter_reward_item_list = {}
    DynastyChallengeUI.super.DoDestroy(self)
end

return DynastyChallengeUI