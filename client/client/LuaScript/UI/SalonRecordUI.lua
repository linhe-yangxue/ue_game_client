local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local UnitConst = require("Unit.UnitConst")

local SalonRecordUI = class("UI.SalonRecordUI", UIBase)

local kFailedAlpha = 0.8
local kNormalAlpha = 1

local kMaxShowRank = 5
local kRoundStartDelay = 1
local kAttrCardRotateDelay = kRoundStartDelay + 2
local kCalcAdditionDelay = kAttrCardRotateDelay + 3
local kCalcResultDelay = kCalcAdditionDelay + 1
local kLoverModelDelay = kCalcResultDelay + 2
local kLoverModelDuration = 3
local kNextRoundDelay = kLoverModelDelay + kMaxShowRank * kLoverModelDuration + 3
local kShowResultDelay = kLoverModelDelay + kLoverModelDuration + 3

function SalonRecordUI:DoInit()
    SalonRecordUI.super.DoInit(self)
    self.prefab_path = "UI/Common/SalonRecordUI"
    self.rank_go_list = {}
    self.player_count = SpecMgrs.data_mgr:GetParamData("salon_pvp_term_player_num").f_value
    self.attr_point_ratio = SpecMgrs.data_mgr:GetParamData("salon_attr_point_ratio").f_value
    self.player_go_dict = {}
    self.rank_item_list = {}
    self.role_go_dict = {}
    self.cur_model_index = 0
    self.dy_lover_data = ComMgrs.dy_data_mgr.lover_data
end

function SalonRecordUI:OnGoLoadedOk(res_go)
    SalonRecordUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function SalonRecordUI:Hide()
    self:ClearAllTimer()
    SalonRecordUI.super.Hide(self)
end

function SalonRecordUI:Show(salon_id, day, pvp_id)
    self.salon_id = salon_id
    self.day = day
    self.pvp_id = pvp_id
    if self.is_res_ok then
        self:InitUI()
    end
    SalonRecordUI.super.Show(self)
end

function SalonRecordUI:InitRes()
    local rank_panel = self.main_panel:FindChild("RankPanel")
    local skip_btn = rank_panel:FindChild("SkipBtn")
    self:AddClick(skip_btn, function ()
        self:ClearAllTimer()
        self:ShowResultPanel()
    end)
    rank_panel:FindChild("RankList/Title"):GetComponent("Text").text = UIConst.Text.GARDEN_PARTY
    local rank_list = rank_panel:FindChild("RankList/List")
    local rank_item = rank_list:FindChild("RankItem")
    for i = 1, kMaxShowRank do
        local rank_go = self:GetUIObject(rank_item, rank_list)
        table.insert(self.rank_go_list, rank_go)
    end

    self.game_panel = self.main_panel:FindChild("GamePanel")
    self.lover_img = self.game_panel:FindChild("LoverImg")
    self.player_lover_model = self.lover_img:FindChild("LoverModel")
    self.lover_tween_alpha_cmp = self.lover_img:GetComponent("UITweenAlpha")
    self.dialog = self.lover_img:FindChild("Dialog")
    self.dialog_text = self.dialog:FindChild("Text"):GetComponent("Text")
    self.rank_text = self.lover_img:FindChild("RankBg/Text"):GetComponent("Text")
    self.name_text = self.lover_img:FindChild("NameBg/Text"):GetComponent("Text")
    self.hud = self.lover_img:FindChild("Hud")

    self.round_start_panel = self.main_panel:FindChild("RoundStart")
    self.round_text = self.round_start_panel:FindChild("Content/Image/RoundText"):GetComponent("Text")
    self.round_name = self.round_start_panel:FindChild("Content/RoundName"):GetComponent("Text")
    self.round_attr = self.round_start_panel:FindChild("Content/RoundAttr"):GetComponent("Text")

    local self_panel = self.main_panel:FindChild("Self")
    self.self_lover_img = self_panel:FindChild("LoverImg")
    self.intimacy_text = self_panel:FindChild("IntimacyBg/Text"):GetComponent("Text")
    self.self_name = self_panel:FindChild("NameBg/Name"):GetComponent("Text")
    self.score = self_panel:FindChild("Score")
    self.score_text = self.score:GetComponent("Text")
    self.failed = self_panel:FindChild("Disable")
    local etiquette_panel = self_panel:FindChild("Etiquette")
    self.role_go_dict["etiquette"] = {}
    etiquette_panel:FindChild("Title"):GetComponent("Text").text = UIConst.Text.CEREMONY_TEXT
    self.role_go_dict["etiquette"].active_go = etiquette_panel:FindChild("Active")
    local attr_panel = etiquette_panel:FindChild("AttrPanel")
    self.etiquette_value = attr_panel:FindChild("Bg/Value"):GetComponent("Text")
    self.etiquette_addition = attr_panel:FindChild("Addition"):GetComponent("Text")
    self.role_go_dict["etiquette"].rank_go = self.etiquette_addition

    local culture_panel = self_panel:FindChild("Culture")
    culture_panel:FindChild("Title"):GetComponent("Text").text = UIConst.Text.CULTURE_TEXT
    self.role_go_dict["culture"] = {}
    self.role_go_dict["culture"].active_go = culture_panel:FindChild("Active")
    local attr_panel = culture_panel:FindChild("AttrPanel")
    self.culture_value = attr_panel:FindChild("Bg/Value"):GetComponent("Text")
    self.culture_addition = attr_panel:FindChild("Addition"):GetComponent("Text")
    self.role_go_dict["culture"].rank_go = self.culture_addition

    local charm_panel = self_panel:FindChild("Charm")
    charm_panel:FindChild("Title"):GetComponent("Text").text = UIConst.Text.CHARM_TEXT
    self.role_go_dict["charm"] = {}
    self.role_go_dict["charm"].active_go = charm_panel:FindChild("Active")
    local attr_panel = charm_panel:FindChild("AttrPanel")
    self.charm_value = attr_panel:FindChild("Bg/Value"):GetComponent("Text")
    self.charm_addition = attr_panel:FindChild("Addition"):GetComponent("Text")
    self.role_go_dict["charm"].rank_go = self.charm_addition

    local planning_panel = self_panel:FindChild("Planning")
    planning_panel:FindChild("Title"):GetComponent("Text").text = UIConst.Text.PLAN_TEXT
    self.role_go_dict["planning"] = {}
    self.role_go_dict["planning"].active_go = planning_panel:FindChild("Active")
    local attr_panel = planning_panel:FindChild("AttrPanel")
    self.planning_value = attr_panel:FindChild("Bg/Value"):GetComponent("Text")
    local planning_text = attr_panel:FindChild("Addition"):GetComponent("Text")
    planning_text.text = UIConst.Text.PLANNING_TEXT
    self.role_go_dict["planning"].rank_go = planning_text

    self.result_panel = self.main_panel:FindChild("ResultPanel")
    self:AddClick(self.result_panel, function ()
        self:InitSalonRecordUI()
        self:Hide()
    end)
    local content = self.result_panel:FindChild("Content")
    local top_panel = content:FindChild("Top")
    top_panel:FindChild("Rank"):GetComponent("Text").text = UIConst.Text.RANK_tEXT
    top_panel:FindChild("Name"):GetComponent("Text").text = UIConst.Text.PLAYER_NAME_TEXT
    top_panel:FindChild("Score"):GetComponent("Text").text = UIConst.Text.SALON_SCORE_TEXT
    top_panel:FindChild("Reward"):GetComponent("Text").text = UIConst.Text.RANKING_REWARD_TEXT
    self.rank_list_content = content:FindChild("RankList/View/Content")
    local first_place = self.rank_list_content:FindChild("First")
    table.insert(self.rank_item_list, first_place)
    local second_place = self.rank_list_content:FindChild("Second")
    table.insert(self.rank_item_list, second_place)
    local third_place = self.rank_list_content:FindChild("Third")
    table.insert(self.rank_item_list, third_place)
    local rank_item = self.rank_list_content:FindChild("RankItem")
    for i = 4, self.player_count do
        local go = self:GetUIObject(rank_item, self.rank_list_content)
        go:FindChild("Ranking"):GetComponent("Text").text = i
        table.insert(self.rank_item_list, go)
    end
end

function SalonRecordUI:InitUI()
    self:GetSalonRecord()
end

function SalonRecordUI:InitSalonRecordUI()
    self.rank_list_content:GetComponent("RectTransform").anchoredPosition = Vector2.zero
    self:ResetPlayerState()
    self.result_panel:SetActive(false)
    self.round_start_panel:SetActive(false)
    self.lover_img:SetActive(false)
    for _, role_go in pairs(self.role_go_dict) do
        role_go.active_go:SetActive(false)
    end
    if self.lover_model then
        ComMgrs.unit_mgr:DestroyUnit(self.lover_model)
        self.lover_model = nil
    end
    if self.cur_lover then
        ComMgrs.unit_mgr:DestroyUnit(self.cur_lover)
        self.cur_lover = nil
    end
end

function SalonRecordUI:PlayPvpRecord()
    self:InitPlayerInfo()
    self.cur_round = 0
    self:ShowRoundRecord()
end

function SalonRecordUI:InitPlayerInfo()
    self.self_uuid = ComMgrs.dy_data_mgr:ExGetRoleUuid()
    self.rank_list = {}
    -- 初始化玩家信息
    for uuid, role_info in pairs(self.pvp_info.role_dict) do
        if uuid == self.self_uuid then
            local lover_data = SpecMgrs.data_mgr:GetLoverData(role_info.lover.lover_id)
            local grade_data = SpecMgrs.data_mgr:GetGradeData(role_info.lover.grade)
            self.lover_model = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = lover_data.unit_id, parent = self.self_lover_img})
            self.lover_model:SetPositionByRectName({parent = self.self_lover_img, name = "half"})
            self.lover_model:StopAllAnimationToCurPos()
            self.intimacy_text.text = grade_data.name
            self.self_name.text = lover_data.name
            local attr_dict = role_info.lover.attr_dict
            local attr_point_dict = role_info.attr_point_dict
            local etiquette_addition_value = math.floor(attr_dict.etiquette * self.attr_point_ratio * (attr_point_dict.etiquette or 0))
            self.etiquette_value.text = attr_dict.etiquette + etiquette_addition_value
            self.etiquette_addition.text = string.format(UIConst.Text.ADDITION_FORMAT_TEXT, UIConst.Text.CEREMONY_TEXT, etiquette_addition_value)

            local culture_addition_value = math.floor(attr_dict.culture * self.attr_point_ratio * (attr_point_dict.culture or 0))
            self.culture_value.text = attr_dict.culture + culture_addition_value
            self.culture_addition.text = string.format(UIConst.Text.ADDITION_FORMAT_TEXT, UIConst.Text.CULTURE_TEXT, culture_addition_value)

            local charm_addition_value = math.floor(attr_dict.charm * self.attr_point_ratio * (attr_point_dict.charm or 0))
            self.charm_value.text = attr_dict.charm + charm_addition_value
            self.charm_addition.text = string.format(UIConst.Text.ADDITION_FORMAT_TEXT, UIConst.Text.CHARM_TEXT, charm_addition_value)
            self.planning_value.text = attr_dict.planning
        end
        local rank_data = {uuid = role_info.uuid, index = role_info.index, name = role_info.name, score = 0}
        table.insert(self.rank_list, rank_data)
    end
    table.sort(self.rank_list, function (role1, role2)
        return role1.index < role2.index
    end)
    local offset = 0
    for index, rank_data in ipairs(self.rank_list) do
        if rank_data.uuid == self.self_uuid then
            offset = 1
        else
            local role_info = self.pvp_info.role_dict[rank_data.uuid]
            local go = self.game_panel:FindChild("Player" .. index - offset)
            self.player_go_dict[index] = go
            local lover_data = SpecMgrs.data_mgr:GetLoverData(role_info.lover.lover_id)
            local unit_data = SpecMgrs.data_mgr:GetUnitData(lover_data.unit_id)
            local grade_data = SpecMgrs.data_mgr:GetGradeData(role_info.lover.grade)
            UIFuncs.AssignSpriteByIconID(unit_data.icon, go:FindChild("IconBg/LoverIcon"):GetComponent("Image"))
            go:FindChild("IntimacyBg/Text"):GetComponent("Text").text = grade_data.name
            local attr_card = go:FindChild("Card")
            attr_card:FindChild("AttrCard/Info/Name"):GetComponent("Text").text = role_info.name
            attr_card:SetActive(false)
            go:FindChild("Card/AttrCard/Addition"):SetActive(false)
        end
    end
    -- 初始化排行榜
    for i = 1, kMaxShowRank do
        local go = self.rank_go_list[i]
        go:FindChild("Name"):GetComponent("Text").text = string.format(UIConst.Text.SALON_RANK_NAME_FORMAT, i, self.rank_list[i].name)
        go:FindChild("Score"):GetComponent("Text").text = 0
    end
end

function SalonRecordUI:ShowRoundRecord()
    self:ResetPlayerState()
    -- 切换当前比试的回合
    if self.cur_round > 0 then
        self.last_attr = CSConst.Salon.PvPAttrListCmp[self.cur_round][1]
        self.role_go_dict[self.last_attr].active_go:SetActive(false)
    end
    self.cur_round = self.cur_round + 1
    self.cur_attr = CSConst.Salon.PvPAttrListCmp[self.cur_round][1]
    self.lowest_rank = self.cur_round == #self.pvp_info.round and 1 or kMaxShowRank
    self.role_go_dict[self.cur_attr].active_go:SetActive(true)

    self.round_start_timer = SpecMgrs.timer_mgr:AddTimer(function ()
        -- 播放回合开始动画
        self:PlayRoundStartAnim()
        self.round_start_timer = nil
    end, kRoundStartDelay, 1)

    self.show_attr_timer = SpecMgrs.timer_mgr:AddTimer(function ()
        -- 初始化玩家情人属性
        self:InitPlayerAttrValue()
        self.show_attr_timer = nil
    end, kAttrCardRotateDelay, 1)

    self.calc_addition_timer = SpecMgrs.timer_mgr:AddTimer(function ()
        -- 计算情人属性加成
        self:CalcAddition()
        self.calc_addition_timer = nil
    end, kCalcAdditionDelay, 1)

    self.calc_result_timer = SpecMgrs.timer_mgr:AddTimer(function ()
        -- 计算回合输赢
        self:CalcResult()
        self.show_model_timer = SpecMgrs.timer_mgr:AddTimer(function ()
            self.lover_img:SetActive(true)
            self:ShowLoverModel()
        end, kLoverModelDuration, self.lowest_rank)
        self.calc_result_timer = nil
    end, kCalcResultDelay, 1)

    if self.cur_round == #self.pvp_info.round then
        self.show_result_timer = SpecMgrs.timer_mgr:AddTimer(function ()
            self:ShowResultPanel()
            self.show_result_timer = nil
        end, kShowResultDelay, 1)
        return
    end

    self.next_round_timer = SpecMgrs.timer_mgr:AddTimer(function ()
        self.next_round_timer = nil
        self:ShowRoundRecord()
    end, kNextRoundDelay, 1)
end

function SalonRecordUI:ResetPlayerState()
    for _, go in pairs(self.player_go_dict) do
        go:FindChild("Failed"):SetActive(false)
        go:GetComponent("CanvasGroup").alpha = kNormalAlpha
        go:FindChild("Score"):SetActive(false)
        go:FindChild("Card/AttrCard/Addition"):SetActive(false)
        go:FindChild("Failed/CardFailed"):SetActive(true)
    end
    self.lover_model:ChangeToNormalMaterial()
    self.score:SetActive(false)
    self.failed:SetActive(false)
    self.cur_model_index = 0
    self.round_start_panel:SetActive(false)
end

function SalonRecordUI:InitPlayerAttrValue()
    self.round_start_panel:SetActive(false)
    local attr_data = SpecMgrs.data_mgr:GetAttributeData(self.cur_attr)
    for uuid, role_info in pairs(self.pvp_info.role_dict) do
        if self.self_uuid ~= role_info.uuid then
            local attr_dict = role_info.lover.attr_dict
            local cur_attr_point = role_info.attr_point_dict[self.cur_attr] or 0
            local go = self.player_go_dict[role_info.index]
            local attr_card = go:FindChild("Card")
            local addition = go:FindChild("Card/AttrCard/Addition")

            UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetAttributeData(self.cur_attr).icon, attr_card:FindChild("AttrCard/Info/Bg/Icon"):GetComponent("Image"))
            attr_card:FindChild("AttrCard/Info/Bg/Value"):GetComponent("Text").text = attr_dict[self.cur_attr]
            attr_card:SetActive(true)
            if cur_attr_point > 0 then
                local addition_value = math.floor(attr_dict[self.cur_attr] * (self.attr_point_ratio * cur_attr_point))
                addition:FindChild("Text"):GetComponent("Text").text = string.format(UIConst.Text.ADDITION_FORMAT_TEXT, attr_data.name, addition_value)
                addition:SetActive(true)
            end
        end
    end
end

function SalonRecordUI:PlayRoundStartAnim()
    self.round_text.text = string.format(UIConst.Text.ROUND_TEXT, UIConst.Text.NUMBER_TEXT[self.cur_round])
    local attr_data = SpecMgrs.data_mgr:GetAttributeData(CSConst.Salon.PvPAttrListCmp[self.cur_round][1])
    self.round_name.text = UIConst.Text.SalonRoundName[attr_data.id]
    self.round_attr.text = string.format(UIConst.Text.TEXT_WITH_BRACKET, attr_data.name)
    self.round_start_panel:SetActive(true)
end

function SalonRecordUI:CalcAddition()
    for _, role_info in pairs(self.pvp_info.role_dict) do
        if self.self_uuid ~= role_info.uuid then
            local attr_dict = role_info.lover.attr_dict
            local cur_attr_point = role_info.attr_point_dict[self.cur_attr] or 0
            local go = self.player_go_dict[role_info.index]
            go:FindChild("Card/AttrCard/Addition"):SetActive(false)
            local final_attr = math.floor(attr_dict[self.cur_attr] * (1 + self.attr_point_ratio * cur_attr_point))
            go:FindChild("Card/AttrCard/Info/Bg/Value"):GetComponent("Text").text = final_attr
        end
    end
end

function SalonRecordUI:CalcResult()
    for ranking, rank_info in ipairs(self.pvp_info.round[self.cur_round].rank_list) do
        local score_text = rank_info.score >= 0 and string.format(UIConst.Text.ADD_VALUE_FORMAL, rank_info.score) or rank_info.score
        local role_info = self.pvp_info.role_dict[rank_info.uuid]
        for _, rank_data in ipairs(self.rank_list) do
            if rank_data.uuid == rank_info.uuid then
                rank_data.score = rank_data.score + rank_info.score
                break
            end
        end
        -- self.rank_list[role_info.index].score = self.rank_list[role_info.index].score + rank_info.score
        if rank_info.uuid ~= self.self_uuid then
            local go = self.player_go_dict[role_info.index]
            go:FindChild("Score"):GetComponent("Text").text = score_text
            if ranking > self.lowest_rank then
                go:FindChild("Failed"):SetActive(true)
                go:GetComponent("CanvasGroup").alpha = kFailedAlpha
            end
        else
            self.score_text.text = score_text
            self.role_go_dict[self.cur_attr].rank_go.text = string.format(UIConst.Text.RANK_FORMAT, UIConst.Text.NUMBER_TEXT[ranking])
            if ranking > self.lowest_rank then
                self.lover_model:ChangeToGray()
                self.failed:SetActive(true)
            end
        end
    end
    table.sort(self.rank_list, function (rank_data1, rank_data2)
        return rank_data1.score > rank_data2.score
    end)
end

function SalonRecordUI:ShowLoverModel()
    self.cur_model_index = self.cur_model_index + 1
    if self.cur_model_index == 1 then
        for _, go in pairs(self.player_go_dict) do
            go:FindChild("Card"):SetActive(false)
            go:FindChild("Failed/CardFailed"):SetActive(false)
        end
    end
    local rank_list = self.pvp_info.round[self.cur_round].rank_list
    local role_info = self.pvp_info.role_dict[rank_list[self.cur_model_index].uuid]
    local lover_data = SpecMgrs.data_mgr:GetLoverData(role_info.lover.lover_id)
    self.cur_lover = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = lover_data.unit_id, parent = self.player_lover_model})
    self.cur_lover:SetPositionByRectName({parent = self.player_lover_model, name = "full"})
    local dialog_list = SpecMgrs.data_mgr:GetSalonDialogData(self.cur_round).dialog_list
    self.dialog_text.text = dialog_list[self.cur_model_index]
    self.dialog:SetActive(true)
    self.rank_text.text = string.format(UIConst.Text.RANK_FORMAT, UIConst.Text.NUMBER_TEXT[self.cur_model_index])
    self.name_text.text = role_info.name
    self:LoverImgCrossFade(true)
    self.hud:GetComponent("Text").text = string.format(UIConst.Text.ADD_VALUE_FORMAL, rank_list[self.cur_model_index].score)
    self.hud:SetActive(true)
    if role_info.uuid == self.self_uuid then
        self.score:SetActive(true)
    else
        self.player_go_dict[role_info.index]:FindChild("Score"):SetActive(true)
    end
    if self.cur_round <= #self.pvp_info.round then
        self.lover_fadeout_timer = SpecMgrs.timer_mgr:AddTimer(function ()
            self.hud:SetActive(false)
            self:LoverImgCrossFade(false)
            self.dialog:SetActive(false)
            ComMgrs.unit_mgr:DestroyUnit(self.cur_lover)
            self.cur_lover = nil
            if self.cur_model_index == self.lowest_rank then
                self.lover_img:SetActive(false)
                self:CompleteScore()
                self.show_model_timer = nil
            end
            self.lover_fadeout_timer = nil
        end, kLoverModelDuration - 2 * self.lover_tween_alpha_cmp:GetDurationTime(), 1)
    end
end

function SalonRecordUI:LoverImgCrossFade(is_fade_in)
    self.lover_tween_alpha_cmp.from_ = is_fade_in and 0 or 1
    self.lover_tween_alpha_cmp.to_ = is_fade_in and 1 or 0
    self.lover_tween_alpha_cmp:Play()
    self.lover_img:SetActive(is_fade_in)
end

function SalonRecordUI:CompleteScore()
    for i = self.lowest_rank, self.player_count do
        local role_uuid = self.pvp_info.round[self.cur_round].rank_list[i].uuid
        local role_info = self.pvp_info.role_dict[role_uuid]
        if role_info.uuid == self.self_uuid then
            self.score:SetActive(true)
        else
            self.player_go_dict[role_info.index]:FindChild("Score"):SetActive(true)
        end
    end
    -- 更新排行榜
    for i = 1, kMaxShowRank do
        self.rank_go_list[i]:FindChild("Name"):GetComponent("Text").text = string.format(UIConst.Text.SALON_RANK_NAME_FORMAT, i, self.rank_list[i].name)
        self.rank_go_list[i]:FindChild("Score"):GetComponent("Text").text = self.rank_list[i].score
    end
end

function SalonRecordUI:ClearAllTimer()
    if self.round_start_timer then
        SpecMgrs.timer_mgr:RemoveTimer(self.round_start_timer)
        self.round_start_timer = nil
    end
    if self.show_attr_timer then
        SpecMgrs.timer_mgr:RemoveTimer(self.show_attr_timer)
        self.show_attr_timer = nil
    end
    if self.calc_addition_timer then
        SpecMgrs.timer_mgr:RemoveTimer(self.calc_addition_timer)
        self.calc_addition_timer = nil
    end
    if self.calc_result_timer then
        SpecMgrs.timer_mgr:RemoveTimer(self.calc_result_timer)
        self.calc_result_timer = nil
    end
    if self.show_model_timer then
        SpecMgrs.timer_mgr:RemoveTimer(self.show_model_timer)
        self.show_model_timer = nil
    end
    if self.lover_fadeout_timer then
        SpecMgrs.timer_mgr:RemoveTimer(self.lover_fadeout_timer)
        self.lover_fadeout_timer = nil
    end
    if self.show_result_timer then
        SpecMgrs.timer_mgr:RemoveTimer(self.show_result_timer)
        self.show_result_timer = nil
    end
    if self.next_round_timer then
        SpecMgrs.timer_mgr:RemoveTimer(self.next_round_timer)
        self.next_round_timer = nil
    end
end

function SalonRecordUI:ShowResultPanel()
    for i, rank_data in ipairs(self.pvp_info.total_rank) do
        local role_info = self.pvp_info.role_dict[rank_data.uuid]
        local rank_item = self.rank_item_list[i]
        local lover_data = SpecMgrs.data_mgr:GetLoverData(role_info.lover.lover_id)
        local unit_data = SpecMgrs.data_mgr:GetUnitData(lover_data.unit_id)
        UIFuncs.AssignSpriteByIconID(unit_data.icon, rank_item:FindChild("IconBg/Icon"):GetComponent("Image"))
        rank_item:FindChild("Name"):GetComponent("Text").text = role_info.name
        rank_item:FindChild("Score"):GetComponent("Text").text = rank_data.score
        rank_item:FindChild("Reward/Count"):GetComponent("Text").text = CSConst.Salon.PvPIntegral[i]
    end
    self.result_panel:SetActive(true)
end

function SalonRecordUI:GetSalonRecord()
    SpecMgrs.msg_mgr:SendGetSalonRecord({salon_id = self.salon_id, day = self.day, pvp_id = self.pvp_id}, function (resp)
        if resp.errcode ~= 0 then
            self:Hide()
        else
            self.pvp_info = resp.pvp_info
            self:PlayPvpRecord()
        end
    end)
end

return SalonRecordUI