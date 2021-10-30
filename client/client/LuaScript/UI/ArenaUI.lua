local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local FConst = require("CSCommon.Fight.FConst")
local CSConst = require("CSCommon.CSConst")
local ItemUtil = require("BaseUtilities.ItemUtil")
local SoundConst = require("Sound.SoundConst")
local ArenaUI = class("UI.ArenaUI",UIBase)

local unit_interval = 400

--  竞技场
function ArenaUI:DoInit()
    ArenaUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ArenaUI"
end

function ArenaUI:OnGoLoadedOk(res_go)
    ArenaUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function ArenaUI:Show()
    self:DelObjDict(self.create_obj_list)
    self:DestroyAllUnit()
    self:RemoveAllUIEffect()
    local cb = function(resp)
        self.role_list = resp.role_list
        self.own_rank = resp.self_rank
        if self.is_res_ok then
            self:InitUI()
        end
        ArenaUI.super.Show(self)
    end
    SpecMgrs.msg_mgr:SendGetArenaInfo(nil, cb)
end

function ArenaUI:InitRes()
    self:InitTopBar()
    self.content = self.main_panel:FindChild("MiddleFrame/PlayerList/Viewport/Content")
    self.own_ranking_text = self.main_panel:FindChild("MiddleFrame/Bg/OwnRankingText"):GetComponent("Text")
    self.own_ranking_val_text = self.main_panel:FindChild("MiddleFrame/Bg/OwnRankingValText"):GetComponent("Text")
    self.award_item_text = self.main_panel:FindChild("MiddleFrame/Bg/AwardItemText"):GetComponent("Text")
    self.send_reward_time_text = self.main_panel:FindChild("MiddleFrame/Bg/SendRewardTimeText"):GetComponent("Text")
    self.challenge_spend_text = self.main_panel:FindChild("MiddleFrame/Bg/ChallengeSpendText"):GetComponent("Text")

    self.show_small_lineup_btn = self.main_panel:FindChild("MiddleFrame/ShowSmallLineupBtn")
    self:AddClick(self.show_small_lineup_btn, function()
        SpecMgrs.ui_mgr:ShowUI("SmallLineupUI")
    end)
    self.show_small_lineup_btn_text = self.main_panel:FindChild("MiddleFrame/ShowSmallLineupBtn/ShowSmallLineupBtnText"):GetComponent("Text")

    self.ranking_list_button = self.main_panel:FindChild("MiddleFrame/RankingListButton")
    self:AddClick(self.ranking_list_button, function()
        SpecMgrs.ui_mgr:ShowRankUI(UIConst.Rank.Arena)
    end)
    self.ranking_list_button_text = self.main_panel:FindChild("MiddleFrame/RankingListButton/RankingListButtonText"):GetComponent("Text")

    self.shopping_button = self.main_panel:FindChild("MiddleFrame/ShoppingButton")
    self:AddClick(self.shopping_button, function()
        SpecMgrs.ui_mgr:ShowUI("ShoppingUI", UIConst.ShopList.ArenaShop)
    end)
    self.shopping_button_text = self.main_panel:FindChild("MiddleFrame/ShoppingButton/ShoppingButtonText"):GetComponent("Text")


    self.player = self.main_panel:FindChild("Temp/Player")
    self.player:SetActive(false)

    self.map_list = {}
    for i = 1, self.content.childCount do
        table.insert(self.map_list, self.content:FindChild("Map" .. i))
    end

    self.map_prefab = self.main_panel:FindChild("Temp/Map")

    self.contetn_rect = self.content:GetComponent("RectTransform")
    self.map_point_num = self.map_prefab.childCount

    self.map_width = self.map_prefab:GetComponent("RectTransform").rect.width
    self.map_height = self.map_prefab:GetComponent("RectTransform").rect.height
    self.map_point_interval = self.map_prefab:GetComponent("RectTransform").rect.height / self.map_point_num

    self.reward_list = self.main_panel:FindChild("MiddleFrame/Bg/RewardList")
    self.reward_text_list = {}
    for i = 1, self.reward_list.childCount do
        table.insert(self.reward_text_list, self.reward_list:GetChild(i - 1))
        self.reward_list:GetChild(i - 1):SetActive(false)
    end
end

function ArenaUI:InitUI()
    self:PlayBGM(SoundConst.SOUND_ID_Arena)
    self:SetTextVal()
    self:UpdateData()
    self:UpdateUIInfo()
end

function ArenaUI:Update(delta_time)
    if not self.is_res_ok or not self.is_visible or not self.role_list then return end
    local is_old_minus_zero = self.timer < 0
    self.timer = self.timer + delta_time
    if is_old_minus_zero and self.timer >= 0 then
    -- if self.timer > self.talk_interval then
        local pos_y = math.abs(self.contetn_rect.anchoredPosition.y)
        local index = #self.player_obj_list - math.floor(pos_y / self.player_obj_height)
        index = math.clamp(index, 1, #self.player_obj_list)
        local random_result_list = {}
        for i = index - 3, index do
            local can_add = true
            if self.my_index and self.my_index == i then
                can_add = false
            end
            if self.last_talk_time_index and self.last_talk_time_index == i then
                can_add = false
            end
            if can_add then
                table.insert(random_result_list, i)
            end
        end
        if not next(random_result_list) then return end
        index = random_result_list[math.random(1, #random_result_list)]
        self.last_talk_time_index = index
        local player_obj = self.player_obj_list[index]
        local length = #SpecMgrs.data_mgr:GetAllArenaTalkData()
        local talk_str = SpecMgrs.data_mgr:GetArenaTalkData(math.random(1, length)).talk
        local is_left = self.player_dir_list[index]
        local talk_parent
        if is_left then
            talk_parent = player_obj:FindChild("RightTalkParent")
        else
            talk_parent = player_obj:FindChild("LeftTalkParent")
        end
        self:ClearTalk()
        self.talk_cmp = self:GetTalkCmp(talk_parent, 1, is_left, function ()
            return talk_str
        end)
        player_obj.parent:SetAsLastSibling()
    end
    if self.timer > self.talk_interval then
        self.timer = -2
        self:ClearTalk()
    end
end

function ArenaUI:ClearTalk()
    if self.talk_cmp then
        self.talk_cmp:DoDestroy()
        self.talk_cmp = nil
    end
end

function ArenaUI:UpdateData()
    self.talk_interval = SpecMgrs.data_mgr:GetParamData("arena_talk_interval").f_value
    self.timer = self.talk_interval * 0.5
    self.dy_data = ComMgrs.dy_data_mgr
    self.challenge_spend_num = SpecMgrs.data_mgr:GetParamData("arena_cost_vitality").f_value
    if self.own_rank then
        self.own_ranking_val_text.text = self.own_rank
    else
        self.own_ranking_val_text.text = UIConst.Text.NOT_IN_RANK_TEXT
    end

    local reward_data = ArenaUI.GetRankAward(self.own_rank)

    local rank_data = SpecMgrs.data_mgr:GetTotalRankData(UIConst.Rank.Arena)
    local reward_id = nil
    local my_rank = self.own_rank or 10000

    local item_list = {}
    local num_list = {}
    for i, rank in ipairs(rank_data.reward_tier) do
        if my_rank <= rank then
            reward_id = rank_data.reward_list[i]
            break
        end
    end
    if reward_id then
        item_list = SpecMgrs.data_mgr:GetRewardData(reward_id).reward_item_list
        num_list = SpecMgrs.data_mgr:GetRewardData(reward_id).reward_num_list
    else
        item_list = SpecMgrs.data_mgr:GetRewardData(rank_data.reward_list[1]).reward_item_list

        for i, v in ipairs(item_list) do
            num_list[i] = 0
        end
    end
    for i, item_id in ipairs(item_list) do
        self.reward_text_list[i]:SetActive(true)
        UIFuncs.SetItemNumTextPic(self, self.reward_text_list[i], item_id, num_list[i], UIConst.Text.SMALL_ITEM_ICON_NUM_FORMAT)
    end
end

function ArenaUI:SetTextVal()
    self.own_ranking_text.text = UIConst.Text.OWN_RANK_TEXT
    self.award_item_text.text = UIConst.Text.RANK_AWARD_TEXT
    self.show_small_lineup_btn_text.text = UIConst.Text.LINE_UP_TEXT
    self.ranking_list_button_text.text = UIConst.Text.RANK_LIST_TEXT
    self.shopping_button_text.text = UIFuncs.GetShopNameByShopType(UIConst.ShopList.ArenaShop)

    local challenge_spend_num = SpecMgrs.data_mgr:GetParamData("arena_cost_vitality").f_value
    local send_time = SpecMgrs.data_mgr:GetParamData("arena_reward_time").f_value
    self.send_reward_time_text.text = string.format(UIConst.Text.SEND_REWARD_TIME_FORMAT, send_time)
    self.challenge_spend_text.text = string.format(UIConst.Text.SPEND_VITALITY_FORMAT, challenge_spend_num)
end

function ArenaUI:UpdateUIInfo()
    self.player_obj_list = {}
    self.player_dir_list = {}
    self.create_obj_list = {}
    self:CreatePlayer()
end

function ArenaUI:CreatePlayer()
    local create_map_num = math.ceil(#self.role_list / (self.map_point_num - 1))
    local index = 1
    local is_left = false
    for i = 1, create_map_num do
        local map_obj = self.map_list[i]
        map_obj:SetActive(true)
        map_obj:GetComponent("RectTransform").anchoredPosition = Vector2.New(0, -((i - 1) * self.map_height + self.map_height / 2 + 200))
        for j = self.map_point_num, 1, -1 do
            if index > #self.role_list then
                break
            end
            if not (i == 1 and j == self.map_point_num) then
                local player_obj = self:GetUIObject(self.player, map_obj:FindChild("Point" .. tostring(j - 1)))
                local is_self = self:SetPlayerMes(player_obj, self.role_list[index], is_left)
                if is_self then
                    self.my_index = index
                end
                table.insert(self.player_obj_list, player_obj)
                table.insert(self.create_obj_list, player_obj)
                table.insert(self.player_dir_list, is_left)
                is_left = not is_left
                index = index + 1
            end
        end
    end
    for i = create_map_num + 1, #self.map_list do
        local map_obj = self.map_list[i]
        map_obj:SetActive(false)
    end
    local height = (create_map_num - 1) * self.map_height + (#self.role_list - (create_map_num - 1) * self.map_point_num) * self.map_point_interval

    self.contetn_rect.sizeDelta = Vector2.New(self.map_width, height + 400)
    self.contetn_rect.anchoredPosition = Vector3.zero
    if self.my_index < 8 then
        self.contetn_rect.anchoredPosition = Vector2.New(0, -(8 - self.my_index) * unit_interval)
    end
    self.content_height = self.contetn_rect.sizeDelta.y
    self.player_obj_height = self.content_height / #self.player_obj_list
    local top_map_obj = self:GetUIObject(self.map_prefab, self.content)
    top_map_obj:GetComponent("RectTransform").anchoredPosition = Vector2.New(0, self.map_height / 2 - 200)
    table.insert(self.create_obj_list, top_map_obj)
    top_map_obj:SetAsFirstSibling()
end

function ArenaUI:SetPlayerMes(obj, player_mes, is_left)
    local is_self = false
    local player_mes_panel
    if is_left then
        player_mes_panel = obj:FindChild("PlayerMesLeftPanel")
        obj:FindChild("PlayerMesLeftPanel"):SetActive(true)
        obj:FindChild("PlayerMesRightPanel"):SetActive(false)
    else
        player_mes_panel = obj:FindChild("PlayerMesRightPanel")
        obj:FindChild("PlayerMesLeftPanel"):SetActive(false)
        obj:FindChild("PlayerMesRightPanel"):SetActive(true)
    end
    local callenge_btn = obj:FindChild("ChallengeBtn")
    local rank_text = player_mes_panel:FindChild("RankText"):GetComponent("Text")
    local rank_val_text = player_mes_panel:FindChild("RankValText"):GetComponent("Text")
    local player_name_text = player_mes_panel:FindChild("PlayerNameText"):GetComponent("Text")
    local combat_val_text = player_mes_panel:FindChild("CombatValText"):GetComponent("Text")
    local player_point = obj:FindChild("PlayerPoint")
    local quick_challenge_btn = player_mes_panel:FindChild("GameObject/QuickChallengeButton")
    local quick_challenge_btn_text = player_mes_panel:FindChild("GameObject/QuickChallengeButton/QuickChallengeButtonText"):GetComponent("Text")
    local glod_bg = player_mes_panel:FindChild("GlodImage")
    local green_bg = player_mes_panel:FindChild("GreenImage")
    local title = player_mes_panel:FindChild("GameObject/Title")

    if player_mes.title then
        title:SetActive(true)
        UIFuncs.AssignSpriteByItemID(player_mes.title, title:GetComponent("Image"))
    else
        title:SetActive(false)
    end
    rank_text.text = UIConst.Text.RANK_TEXT
    player_name_text.text = player_mes.name
    combat_val_text.text = player_mes.fight_score

    if player_mes.rank then
        rank_val_text.text = player_mes.rank
    else
        rank_val_text.text = UIConst.Text.NOT_IN_RANK_TEXT
    end

    if self:CheckRankIsMy(player_mes.rank) then
        is_self = true
        quick_challenge_btn:SetActive(false)
        glod_bg:SetActive(false)
        green_bg:SetActive(true)
    else
        if player_mes.rank <= 10 then
            glod_bg:SetActive(true)
            green_bg:SetActive(false)
        else
            glod_bg:SetActive(false)
            green_bg:SetActive(false)
        end
        local rank = self.own_rank or 10000
        if rank < player_mes.rank then
            quick_challenge_btn:SetActive(true)
            quick_challenge_btn_text.text = UIConst.Text.QUICK_CHALLENGE_TEXT
            self:AddClick(quick_challenge_btn, function()
                self:QuickChallengeTarget(player_mes.uuid)
            end)
        else
            quick_challenge_btn:SetActive(false)
        end
    end

    if not is_self then
        self:AddClick(player_mes_panel, function()
            self:ChallengeTarget(player_mes.uuid, player_mes.name, player_mes.rank)
        end)
        self:AddClick(callenge_btn, function()
            self:ChallengeTarget(player_mes.uuid, player_mes.name, player_mes.rank)
        end)
    end
    local unit_id = SpecMgrs.data_mgr:GetRoleLookData(player_mes.role_id).unit_id
    self:AddUnit(unit_id, player_point, Vector3.zero, 0.3, is_left)
    return is_self
end

function ArenaUI:CheckRankIsMy(rank)
    if not self.own_rank then
        if not rank then
            return true
        end
    else
        if self.own_rank == rank then
            return true
        end
    end
    return false
end

function ArenaUI:ChallengeTarget(uuid, target_name, rank)
    if ComMgrs.dy_data_mgr:ExGetVitality() < self.challenge_spend_num then
        UIFuncs.UseBagItem(CSConst.UseItem.Vitality)
        return
    end
    local cb = function(resp)
        if resp.rank_change then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.TARGET_RANK_CHANGE_TEXT)
            if not self.is_res_ok then return end
            self:RefleshUI()
            return
        else
            if not resp.fight_data then
                SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.CHALLENGE_REQUEST_FAILED)
                return
            end
            SpecMgrs.ui_mgr:EnterHeroBattle(resp.fight_data, UIConst.BattleScence.ArenaUI)
            SpecMgrs.ui_mgr:RegiseHeroBattleEnd("ArenaUI", function()
                self:BattleEnd(resp, target_name)
                if not self.is_res_ok then return end
                self:RefleshUI()
            end)
        end
    end
    local my_rank = self.own_rank or CSConst.ArenaRobotNum
    if rank < my_rank and rank <= CSConst.ArenaTenRank and my_rank > CSConst.ArenaChallengeLimit then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.CHALLENGE_ERROR_TEXT)
        return
    end
    --SpecMgrs.msg_mgr:SendArenaChallenge({uuid = uuid}, cb)
    SpecMgrs.msg_mgr:SendMsg("SendArenaChallenge", {uuid = uuid}, cb)
end

function ArenaUI:RefleshUI()
    local cb = function(resp)
        self.role_list = resp.role_list
        self.own_rank = resp.self_rank
        self:DestroyAllUnit()
        self:DelObjDict(self.create_obj_list)
        self:InitUI()
    end
    SpecMgrs.msg_mgr:SendGetArenaInfo(nil, cb)
end

function ArenaUI:BattleEnd(resp, target_name)
    local start_rank = self.own_rank and self.own_rank or CSConst.ArenaRobotNum
    local str
    if resp.new_rank then
        str = string.format(UIConst.Text.ARENA_WIN_ADD_RANK_FORMAT, target_name, start_rank, SpecMgrs.data_mgr:GetParamData("rank_upgrade").icon, resp.new_rank)
    else
        str = string.format(UIConst.Text.ARENA_WIN_FORMAT, target_name)
    end

    local param_tb = {
        is_win = resp.is_win,
        show_level = true,
        reward = resp.reward_dict,
        win_tip = resp.is_win and str,
        target_player_name = target_name,
    }
    if resp.is_win then
        SpecMgrs.ui_mgr:AddCloseBattlePopUpList("SelectCardUI", {send_func_name = "SendArenaSelectReward"})
        SpecMgrs.ui_mgr:AddToPopUpList("BattleResultUI", param_tb)
    else
        SpecMgrs.ui_mgr:AddCloseBattlePopUpList("BattleResultUI", param_tb)
    end
    if resp.is_win and resp.new_rank then
        local reward_num
        for k, num in pairs(resp.rank_reward) do
            reward_num = num
        end
        local add_rank
        if self.own_rank then
            add_rank = self.own_rank - resp.new_rank
        else
            add_rank = CSConst.ArenaRobotNum - resp.new_rank
        end
        SpecMgrs.ui_mgr:AddToPopUpList("ArenaRankUpUI", resp.new_rank, add_rank, reward_num)
    end
end

function ArenaUI:QuickChallengeTarget(uuid)
    SpecMgrs.ui_mgr:ShowUI("ArenaUseVitalityUI", uuid)
end

function ArenaUI:Hide()
    self:DelObjDict(self.create_obj_list)
    self:DestroyAllUnit()
    self:RemoveAllUIEffect()
    SpecMgrs.msg_mgr:SendClearArenaInfo(nil, nil)
    ArenaUI.super.Hide(self)
end

function ArenaUI.GetRankAward(rank)
    local arena_data_list = SpecMgrs.data_mgr:GetAllArenaData()
    for i, arena_data in ipairs(arena_data_list) do
        if rank and rank <= arena_data.rank_range[2] and rank >= arena_data.rank_range[1] then
            return SpecMgrs.data_mgr:GetRewardData(arena_data.rank_reward)
        end
    end
    return nil
end

function ArenaUI.GetRankAwardID(rank)
    local arena_data_list = SpecMgrs.data_mgr:GetAllArenaData()
    for i, arena_data in ipairs(arena_data_list) do
        if rank and rank <= arena_data.rank_range[2] and rank >= arena_data.rank_range[1] then
            return arena_data.id
        end
    end
    return nil
end

function ArenaUI.GetArenaData(rank)
    local arena_data_list = SpecMgrs.data_mgr:GetAllArenaData()
    for i, arena_data in ipairs(arena_data_list) do
        if rank and rank <= arena_data.rank_range[2] and rank >= arena_data.rank_range[1] then
            return arena_data
        end
    end
    return nil
end

return ArenaUI
