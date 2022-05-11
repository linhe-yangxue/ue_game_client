local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local ItemUtil = require("BaseUtilities.ItemUtil")
local SlideSelectCmp = require("UI.UICmp.SlideSelectCmp")

local TraitorPreviewUI = class("UI.TraitorPreviewUI", UIBase)

local kTriatorCountPerPage = 3
local kRecommandFriendPanel = 3

function TraitorPreviewUI:DoInit()
    TraitorPreviewUI.super.DoInit(self)
    self.prefab_path = "UI/Common/TraitorPreviewUI"
    self.dy_traitor_data = ComMgrs.dy_data_mgr.traitor_data
    self.traitor_page_item_list = {}
    self.traitor_item_list = {}
    self.traitor_unit_list = {}
    self.reward_item_list = {}
    self.feats_reward_item_list = {}
    self.quality_setting_item_dict = {}
end

function TraitorPreviewUI:OnGoLoadedOk(res_go)
    TraitorPreviewUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function TraitorPreviewUI:Hide()
    self:ClearSelfTraitorUnit()
    self:ClearFriendTraitorItem()
    self:ClearGoDict("quality_setting_item_dict")
    TraitorPreviewUI.super.Hide(self)
end

function TraitorPreviewUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    TraitorPreviewUI.super.Show(self)
end

function TraitorPreviewUI:InitRes()
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "TraitorPreviewUI")

    local info_frame = self.main_panel:FindChild("InfoFrame")
    self.total_feats = info_frame:FindChild("TotalFeats/Text"):GetComponent("Text")
    self.max_damage = info_frame:FindChild("MaxDamage/Text"):GetComponent("Text")
    local now_feats_panel = info_frame:FindChild("NowFeats")
    now_feats_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.TOTAL_TEXT
    local traitor_coin_data = SpecMgrs.data_mgr:GetItemData(CSConst.Virtual.TraitorCoin)
    UIFuncs.AssignSpriteByIconID(traitor_coin_data.icon, now_feats_panel:FindChild("Icon"):GetComponent("Image"))
    self.now_feats_value = now_feats_panel:FindChild("NowFeatsValue"):GetComponent("Text")
    local shop_btn = info_frame:FindChild("ShopBtn")
    shop_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.FEATS_SHOP
    self:AddClick(shop_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("ShoppingUI", UIConst.ShopList.FeatsShop)
    end)
    local reward_btn = info_frame:FindChild("RewardBtn")
    reward_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.FEATS_REWARD
    self:AddClick(reward_btn, function ()
        self:InitFeatsRewardPanel()
        self.feats_award_panel:SetActive(true)
    end)
    local auto_fight_btn = info_frame:FindChild("AutoFightBtn")
    auto_fight_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.TRAITOR_AUTO_FIGHT
    self:AddClick(auto_fight_btn, function ()
        self:InitSettingPanel()
        self.auto_setting_panel:SetActive(true)
    end)

    local traitor_panel = self.main_panel:FindChild("TraitorPanel")
    self.traitor_slide_list_cmp = SlideSelectCmp.New()
    self.friend_traitor_panel = traitor_panel:FindChild("FriendTraitorList")
    self.friend_traitor_list = self.friend_traitor_panel:FindChild("View/Content")
    self.traitor_page_item = self.friend_traitor_list:FindChild("TraitorPage")
    self.traitor_item = self.traitor_page_item:FindChild("TraitorItem")
    self.traitor_slide_list_cmp:DoInit(self, self.friend_traitor_list)
    self.traitor_slide_list_cmp:ListenSelectUpdate(function (index)
        self.cur_page_index = index
    end)
    self.friend_traitor_list_width = self.friend_traitor_panel:GetComponent("RectTransform").rect.width
    self.self_traitor = traitor_panel:FindChild("SelfTraitor")
    self.self_traitor_name = self.self_traitor:FindChild("Name/Text"):GetComponent("Text")
    self.self_traitor_model = self.self_traitor:FindChild("TraitorModel")
    self:AddClick(self.self_traitor_model, function ()
        self:ShowTraitorInfo(self.dy_traitor_data:GetTraitorInfo())
    end)
    self.self_traitor_hp = self.self_traitor:FindChild("HpBar/Hp"):GetComponent("Image")
    self.self_traitor:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SELF_TRAITOR_TEXT
    self.empty_panel = traitor_panel:FindChild("EmptyPanel")
    self.empty_panel:FindChild("Dialog/Text"):GetComponent("Text").text = UIConst.Text.TRAITOR_EMPTY_TIP
    self.empty_jump_btn = self.empty_panel:FindChild("Dialog/GotoBtn")
    self.empty_jump_btn:GetComponent("Text").text = UIConst.Text.CLICK_FOR_JUMP
    self:AddClick(self.empty_jump_btn, function ()
        SpecMgrs.ui_mgr:JumpUI(CSConst.JumpUIId.StrategyMap)
    end)

    local bottom_frame = self.main_panel:FindChild("DownFrame")
    local boss_btn = bottom_frame:FindChild("BossBtn")
    boss_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.traitor_boss_text
    self:AddClick(boss_btn, function ()
        SpecMgrs.ui_mgr:ShowUI("TraitorBossUI")
    end)
    self:AddClick(bottom_frame:FindChild("RankingBtn"), function ()
        SpecMgrs.ui_mgr:ShowRankUI(CSConst.RankGroupId.Traitor)
    end)
    self:AddClick(bottom_frame:FindChild("RecommendFriendBtn"), function ()
        SpecMgrs.ui_mgr:ShowUI("FriendUI", kRecommandFriendPanel)
    end)

    -- 功勋奖励
    self.feats_award_panel = self.main_panel:FindChild("FeatsAwardPanel")
    local feats_reward_content = self.feats_award_panel:FindChild("Content")
    self:AddClick(feats_reward_content:FindChild("Top/CloseBtn"), function ()
        self.feats_award_panel:SetActive(false)
    end)
    feats_reward_content:FindChild("Top/Text"):GetComponent("Text").text = UIConst.Text.FEATS_REWARD
    self.feats_reward_list = feats_reward_content:FindChild("FeatsRewardList/View/Content")
    self.feats_reward_rect_cmp = self.feats_reward_list:GetComponent("RectTransform")
    self.feats_reward_item = self.feats_reward_list:FindChild("Item")
    local feats_reward_state = self.feats_reward_item:FindChild("Bottom/Status")
    feats_reward_state:FindChild("GetBtn/Text"):GetComponent("Text").text = UIConst.Text.RECEIVE_TEXT
    feats_reward_state:FindChild("AlreadyGet/Text"):GetComponent("Text").text = UIConst.Text.ALREADY_RECEIVE_TEXT
    self.reward_item = self.feats_reward_item:FindChild("Bottom/AwardItemList/View/Content/Item")
    local btn_panel = feats_reward_content:FindChild("BtnPanel")
    local close_btn = btn_panel:FindChild("CloseBtn")
    close_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CLOSE
    self:AddClick(close_btn, function ()
        self.feats_award_panel:SetActive(false)
    end)
    local get_all_btn = btn_panel:FindChild("GetAllBtn")
    get_all_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.EASY_FINISH
    self:AddClick(get_all_btn, function ()
        self:SendGetFeatsReward()
    end)

    -- 自动击杀设置
    self.auto_setting_panel = self.main_panel:FindChild("AutoSettingPanel")
    local auto_setting_content = self.auto_setting_panel:FindChild("Content")
    auto_setting_content:FindChild("Title"):GetComponent("Text").text = UIConst.Text.AUTO_CHALLENGE_TRAITOR
    self:AddClick(auto_setting_content:FindChild("CloseBtn"), function ()
        self.auto_setting_panel:SetActive(false)
    end)
    self.quality_setting_list = auto_setting_content:FindChild("QualitySetting/View/Content")
    self.quality_setting_item = self.quality_setting_list:FindChild("QualityItem")
    self.quality_setting_item:FindChild("OneToggle/Label"):GetComponent("Text").text = UIConst.Text.TRAITOR_NORMAL_CHALLENGE
    self.quality_setting_item:FindChild("TwoToggle/Label"):GetComponent("Text").text = UIConst.Text.TRAITOR_FULL_BLOW_CHALLENGE
    local normal_setting_content = auto_setting_content:FindChild("NormalSetting")
    local auto_share_toggle = normal_setting_content:FindChild("ShareToggle")
    self:AddToggle(auto_share_toggle, function (is_on)
        self.cur_setting_info.is_share = is_on
    end)
    self.auto_share_toggle_cmp = auto_share_toggle:GetComponent("Toggle")
    local auto_recover_toggle = normal_setting_content:FindChild("RecoverToggle")
    self:AddToggle(auto_recover_toggle, function (is_on)
        self.cur_setting_info.is_cost = is_on
    end)
    self.auto_recover_toggle_cmp = auto_recover_toggle:GetComponent("Toggle")
    local setting_submit_btn = auto_setting_content:FindChild("BtnPanel/SubmitBtn")
    setting_submit_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CONFIRM
    self:AddClick(setting_submit_btn, function ()
        SpecMgrs.msg_mgr:SendSetTraitorAutoKill(self.cur_setting_info, function (resp)
            if resp.errcode ~= 0 then
                SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.SET_AUTO_CHALLENGE_TRAITOR_FAILED)
            else
                SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.SET_AUTO_CHALLENGE_TRAITOR_SUCCESS)
                self.auto_setting_panel:SetActive(false)
            end
        end)
    end)
end

function TraitorPreviewUI:InitUI()
    self:UpdateAllTraitorInfo()
    self:RegisterEvent(ComMgrs.dy_data_mgr, "UpdateCurrencyEvent", function ()
        self.now_feats_value.text = string.format(UIConst.Text.TRAITOR_COIN_COUNT_FORMAT, ComMgrs.dy_data_mgr:ExGetCurrencyCount(CSConst.Virtual.TraitorCoin))
    end)
end

function TraitorPreviewUI:UpdateAllTraitorInfo()
    self:InitInfoPanel()
    self:InitSelfTraitor()
    self:InitFriendTraitorList()
end

function TraitorPreviewUI:InitInfoPanel()
    local feat_item_data = SpecMgrs.data_mgr:GetItemData(CSConst.Virtual.Feats)
    self.now_feats_value.text = string.format(UIConst.Text.TRAITOR_COIN_COUNT_FORMAT, ComMgrs.dy_data_mgr:ExGetCurrencyCount(CSConst.Virtual.TraitorCoin))
    SpecMgrs.msg_mgr:SendGetMaxHurtRank({}, function (resp)
        local rank_text = resp.self_rank and string.format(UIConst.Text.RANK_FORMAT, resp.self_rank) or UIConst.Text.WITHOUT_RANK
        self.max_damage.text = string.format(UIConst.Text.MAX_HURT_FORMAT, resp.max_hurt or 0, rank_text)
    end)
    SpecMgrs.msg_mgr:SendGetRankList({rank_id = CSConst.RankId.TraitorFeats}, function (resp)
        local rank_text = resp.self_rank and string.format(UIConst.Text.RANK_FORMAT, resp.self_rank) or UIConst.Text.WITHOUT_RANK
        self.total_feats.text = string.format(UIConst.Text.TOTAL_ITEM_COUNT_FORMAT, feat_item_data.name, resp.self_rank_score or 0, rank_text)
    end)
end

function TraitorPreviewUI:InitSelfTraitor()
    local traitor_info = self.dy_traitor_data:GetTraitorInfo()
    self.self_traitor:SetActive(traitor_info ~= nil)
    if traitor_info then
        local traitor_data = SpecMgrs.data_mgr:GetTraitorData(traitor_info.traitor_id)
        self.self_traitor_name.text = self.dy_traitor_data:GetTraitorName(traitor_info.traitor_id, traitor_info.quality)
        self:ClearSelfTraitorUnit()
        self.self_traitor_unit = self:AddFullUnit(traitor_data.unit_id, self.self_traitor_model)
        self.self_traitor_hp.fillAmount = self.dy_traitor_data:CalcTraitorHp(traitor_info) / traitor_info.max_hp
    end
end

function TraitorPreviewUI:InitFriendTraitorList()
    SpecMgrs.msg_mgr:SendFriendTraitorList({}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_FRIEND_TRAITOR_LIST_FAILED)
        else
            local traitor_count = resp.traitor_list and #resp.traitor_list or 0
            self.empty_panel:SetActive(self.dy_traitor_data:GetTraitorInfo() == nil and traitor_count == 0)
            self.friend_traitor_panel:SetActive(traitor_count > 0)
            if traitor_count > 0 then
                self:InitFriendTraitorItem(resp.traitor_list)
            end
        end
    end)
end

function TraitorPreviewUI:InitFriendTraitorItem(traitor_list)
    self:ClearFriendTraitorItem()
    local traitor_page_count = math.ceil(#traitor_list / kTriatorCountPerPage)
    local half_page_count = math.ceil(traitor_page_count / 2)
    local cur_index = 0
    for i = 1, traitor_page_count do
        local traitor_page_item = self:GetUIObject(self.traitor_page_item, self.friend_traitor_list)
        self.traitor_page_item_list[i] = traitor_page_item
        for j = cur_index + 1, cur_index + kTriatorCountPerPage do
            local traitor_info = traitor_list[j]
            if not traitor_info then break end
            cur_index = cur_index + 1
            local traitor_data = SpecMgrs.data_mgr:GetTraitorData(traitor_info.traitor_id)
            local traitor_item = self:GetUIObject(self.traitor_item, traitor_page_item)
            table.insert(self.traitor_item_list, traitor_item)
            local traitor_unit = self:AddFullUnit(traitor_data.unit_id, traitor_item:FindChild("TraitorModel"))
            table.insert(self.traitor_unit_list, traitor_unit)
            traitor_item:FindChild("Name/Text"):GetComponent("Text").text = self.dy_traitor_data:GetTraitorName(traitor_info.traitor_id, traitor_info.quality)
            traitor_item:FindChild("HpBar/Hp"):GetComponent("Image").fillAmount = self.dy_traitor_data:CalcTraitorHp(traitor_info) / traitor_info.max_hp
            traitor_item:FindChild("Discover"):GetComponent("Text").text = string.format(UIConst.Text.TRAITOR_DICOVER_FORMAT, traitor_info.role_name)
            self:AddClick(traitor_item, function ()
                self:ShowTraitorInfo(traitor_info)
            end)
        end
    end
    self.traitor_slide_list_cmp:SetParam(self.friend_traitor_list_width, traitor_page_count)
    self.traitor_slide_list_cmp:SetToIndex(self.cur_page_index or 0)
end

function TraitorPreviewUI:ClearFriendTraitorItem()
    for _, unit in ipairs(self.traitor_unit_list) do
        self:RemoveUnit(unit)
    end
    self.traitor_unit_list = {}
    for _, item in ipairs(self.traitor_item_list) do
        self:DelUIObject(item)
    end
    self.traitor_item_list = {}
    for _, item in ipairs(self.traitor_page_item_list) do
        self:DelUIObject(item)
    end
    self.traitor_page_item_list = {}
end

function TraitorPreviewUI:ShowTraitorInfo(traitor_info)
    local traitor_data = SpecMgrs.data_mgr:GetTraitorData(traitor_info.traitor_id)
    -- 叛军已逃跑
    if Time:GetServerTime() >= traitor_info.appear_ts + traitor_data.run_time * CSConst.Time.Minute then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.TRAITOR_ESCAPE_TEXT)
        self:UpdateAllTraitorInfo()
        return
    end
    SpecMgrs.msg_mgr:SendGetTraitorInfo({traitor_guid = traitor_info.traitor_guid}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_FRIEND_TRAITOR_INFO_FAILED)
        else
            -- 叛军已被击杀
            if not resp.traitor_info then
                SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.TRAITOR_DIE_TEXT)
                self:UpdateAllTraitorInfo()
                return
            end
            local traitor_info_ui = SpecMgrs.ui_mgr:ShowUI("TraitorInfoUI", resp.traitor_info)
            SpecMgrs.ui_mgr:RegisterHideUIEvent("TraitorPreviewUI", function (_, ui)
                if ui.class_name == traitor_info_ui.class_name then
                    SpecMgrs.ui_mgr:UnregisterHideUIEvent("TraitorPreviewUI")
                    self:UpdateAllTraitorInfo()
                end
            end)
        end
    end)
end

function TraitorPreviewUI:InitFeatsRewardPanel()
    self:ClearFeatsRewardItem()
    for i, reward_data in ipairs(self.dy_traitor_data:GetFeatsRewardList()) do
        local feats_reward_item = self:GetUIObject(self.feats_reward_item, self.feats_reward_list)
        table.insert(self.feats_reward_item_list, {item = feats_reward_item})
        feats_reward_item:FindChild("Title/Text"):GetComponent("Text").text = string.format(UIConst.Text.FEATS_REWARD_CONDITION_FORMAT, reward_data.require_feats)
        local status = feats_reward_item:FindChild("Bottom/Status")
        local get_btn = status:FindChild("GetBtn")
        get_btn:SetActive(reward_data.state ~= CSConst.RewardState.picked)
        get_btn:FindChild("Disable"):SetActive(reward_data.state == CSConst.RewardState.unpick)
        if reward_data.state == CSConst.RewardState.pick then
            self.feats_reward_item_list.effect = UIFuncs.AddCompleteEffect(self, get_btn)
            self:AddClick(get_btn, function ()
                self:SendGetFeatsReward(reward_data.data.id)
            end)
        end
        status:FindChild("AlreadyGet"):SetActive(reward_data.state == CSConst.RewardState.picked)
        local reward_item_list = feats_reward_item:FindChild("Bottom/AwardItemList/View/Content")
        local reward_item = self:GetUIObject(self.reward_item, reward_item_list)
        table.insert(self.reward_item_list, reward_item)
        UIFuncs.InitItemGo({
            go = reward_item,
            item_id = reward_data.item_id,
            ui = self,
            count = reward_data.item_count,
        })
    end
    self.feats_reward_rect_cmp.anchoredPosition = Vector2.zero
end

function TraitorPreviewUI:SendGetFeatsReward(reward_id)
    SpecMgrs.msg_mgr:SendGetFeatsReward({reward_id = reward_id}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_FEATS_REWARD_FAILED)
        else
            if not reward_id and not next(resp.reward_dict) then
                SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.NO_TRAITOR_AWARD)
                return
            end
            self:InitFeatsRewardPanel()
            if not reward_id and next(resp.reward_dict) then
                local item_list = {}
                for item_id, count in pairs(resp.reward_dict) do
                    table.insert(item_list, {item_id = item_id, count = count})
                end
                item_list = ItemUtil.SortRoleItemList(item_list)
                SpecMgrs.ui_mgr:ShowGetItemUI(item_list)
            end
        end
    end)
end

function TraitorPreviewUI:ClearFeatsRewardItem()
    self:ClearGoDict("reward_item_list")
    for _, data in ipairs(self.feats_reward_item_list) do
        if data.effect then
            self:RemoveUIEffect(data.item:FindChild("Bottom/Status/GetBtn"), data.effect)
        end
        self:DelUIObject(data.item)
    end
    self.feats_reward_item_list = {}
end

-- 设置
function TraitorPreviewUI:InitSettingPanel()
    self:ClearGoDict("quality_setting_item_dict")
    self.cur_setting_info = self.dy_traitor_data:GetTraitorSetting()
    for _, quality_data in ipairs(self.dy_traitor_data:GetTraitorQualityList()) do
        local quality_setting_item = self:GetUIObject(self.quality_setting_item, self.quality_setting_list)
        self.quality_setting_item_dict[quality_data.id] = quality_setting_item
        quality_setting_item:FindChild("Name"):GetComponent("Text").text = quality_data.traitor_quality_name
        local one_toggle = quality_setting_item:FindChild("OneToggle")
        one_toggle:GetComponent("Toggle").isOn = self.cur_setting_info.quality_dict[quality_data.id] == CSConst.TraitorAttackType.One
        self:AddToggle(one_toggle, function (is_on)
            self.cur_setting_info.quality_dict[quality_data.id] = is_on and CSConst.TraitorAttackType.One or nil
        end)
        local two_toggle = quality_setting_item:FindChild("TwoToggle")
        two_toggle:GetComponent("Toggle").isOn = self.cur_setting_info.quality_dict[quality_data.id] == CSConst.TraitorAttackType.Two
        self:AddToggle(two_toggle, function (is_on)
            self.cur_setting_info.quality_dict[quality_data.id] = is_on and CSConst.TraitorAttackType.Two or nil
        end)
    end
    self.auto_share_toggle_cmp.isOn = self.cur_setting_info.is_share == true
    self.auto_recover_toggle_cmp.isOn = self.cur_setting_info.is_cost == true
end

function TraitorPreviewUI:ClearSelfTraitorUnit()
    if self.self_traitor_unit then
        self:RemoveUnit(self.self_traitor_unit)
        self.self_traitor_unit = nil
    end
end

return TraitorPreviewUI