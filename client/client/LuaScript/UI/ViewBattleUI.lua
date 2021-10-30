local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local SlideSelectCmp = require("UI.UICmp.SlideSelectCmp")

local ViewBattleUI = class("UI.ViewBattleUI", UIBase)

local kOpCode = {
    AttackSituation = 1,
    DefendSituation = 2,
    MemberScore = 3,
}

function ViewBattleUI:DoInit()
    ViewBattleUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ViewBattleUI"
    self.tab_data_dict = {}
    self.dy_dynasty_data = ComMgrs.dy_data_mgr.dynasty_data
    self.attack_item_list = {}
    self.defend_item_list = {}
    self.member_score_item_list = {}
end

function ViewBattleUI:OnGoLoadedOk(res_go)
    ViewBattleUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function ViewBattleUI:Hide()
    self.tab_data_dict[self.cur_op_index].select:SetActive(false)
    self.cur_op_index = nil
    self:ClearMemberItem()
    ViewBattleUI.super.Hide(self)
end

function ViewBattleUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    ViewBattleUI.super.Show(self)
end

function ViewBattleUI:InitRes()
    local content = self.main_panel:FindChild("Content")
    local top = content:FindChild("Top")
    top:FindChild("Text"):GetComponent("Text").text = UIConst.Text.VIEW_BATTLE_TEXT
    self:AddClick(top:FindChild("CloseBtn"), function ()
        SpecMgrs.ui_mgr:HideUI(self)
    end)

    local tab_panel = content:FindChild("TabPanel")
    local attack_situation_btn = tab_panel:FindChild("AttackSituation")
    self.tab_data_dict[kOpCode.AttackSituation] = {}
    attack_situation_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ATTACK_SITUATION_TEXT
    local attack_situation_select = attack_situation_btn:FindChild("Select")
    self.tab_data_dict[kOpCode.AttackSituation].select = attack_situation_select
    attack_situation_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ATTACK_SITUATION_TEXT
    self:AddClick(attack_situation_btn, function ()
        if self.cur_op_index == kOpCode.AttackSituation then return end
        self.content_silde_cmp:SlideToIndex(kOpCode.AttackSituation - 1)
    end)
    local defend_situation_btn = tab_panel:FindChild("DefendSituation")
    self.tab_data_dict[kOpCode.DefendSituation] = {}
    defend_situation_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DEFEND_SITUATION_TEXT
    local defend_situation_select = defend_situation_btn:FindChild("Select")
    self.tab_data_dict[kOpCode.DefendSituation].select = defend_situation_select
    defend_situation_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DEFEND_SITUATION_TEXT
    self:AddClick(defend_situation_btn, function ()
        if self.cur_op_index == kOpCode.DefendSituation then return end
        self.content_silde_cmp:SlideToIndex(kOpCode.DefendSituation - 1)
    end)
    local member_score_btn = tab_panel:FindChild("MemberScore")
    self.tab_data_dict[kOpCode.MemberScore] = {}
    member_score_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.MEMBER_SCORE_TEXT
    local member_score_select = member_score_btn:FindChild("Select")
    self.tab_data_dict[kOpCode.MemberScore].select = member_score_select
    member_score_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.MEMBER_SCORE_TEXT
    self:AddClick(member_score_btn, function ()
        if self.cur_op_index == kOpCode.MemberScore then return end
        self.content_silde_cmp:SlideToIndex(kOpCode.MemberScore - 1)
    end)

    local list_content = content:FindChild("ListContent")
    local content_size = list_content:GetComponent("RectTransform").rect.size
    local content_parent = list_content:FindChild("Content")
    for tab_name, code in pairs(kOpCode) do
        local list = content_parent:FindChild(tab_name)
        list:GetComponent("RectTransform").sizeDelta = content_size
    end
    for i = 1, CSConst.DynastyBattleCompetiorCount do
        table.insert(self.attack_item_list, content_parent:FindChild("AttackSituation/AttackItem" .. i))
    end
    for i = 1, CSConst.DynastyBattleCompetiorCount do
        table.insert(self.defend_item_list, content_parent:FindChild("DefendSituation/DefendItem" .. i))
    end
    self.member_score_content = content_parent:FindChild("MemberScore/View/Content")
    self.member_score_content_rect = self.member_score_content:GetComponent("RectTransform")
    self.member_score_item = self.member_score_content:FindChild("MemberItem")
    local self_rank_panel = content_parent:FindChild("MemberScore/SelfRank")
    self.self_rank = self_rank_panel:FindChild("Rank"):GetComponent("Text")
    self.self_score = self_rank_panel:FindChild("Score"):GetComponent("Text")
    self.content_silde_cmp = SlideSelectCmp.New()
    self.content_silde_cmp:DoInit(self, content_parent)
    self.content_silde_cmp:SetParam(content_size.x, 3)
    self.content_silde_cmp:ListenSelectUpdate(function (index)
        if self.cur_op_index == index + 1 then return end
        if self.cur_op_index then self.tab_data_dict[self.cur_op_index].select:SetActive(false) end
        self.cur_op_index = index + 1
        self.tab_data_dict[self.cur_op_index].select:SetActive(true)
    end)
    self.tip = content:FindChild("Bottom/Tip"):GetComponent("Text")
end

function ViewBattleUI:InitUI()
    self.dy_dynasty_data:UpdateDynastyBattleData(function ()
        self:InitAttackSituation()
        self:InitDefendSituation()
    end)
    self:InitMemberScore()
    self.cur_op_index = kOpCode.AttackSituation
    self.tab_data_dict[self.cur_op_index].select:SetActive(true)
    self.content_silde_cmp:SetToIndex(self.cur_op_index - 1)
end

function ViewBattleUI:InitAttackSituation()
    for i, enemy_info in ipairs(self.dy_dynasty_data:GetDynastyBattleEnemyList()) do
        local attack_item = self.attack_item_list[i]
        attack_item:FindChild("Name/Text"):GetComponent("Text").text = enemy_info.dynasty_name
        local cur_hp = self.dy_dynasty_data:CalcDynastyHp(enemy_info.dynasty_id)
        local max_hp = self.dy_dynasty_data:GetDynastyBattleMaxHp()
        attack_item:FindChild("HP"):GetComponent("Text").text = string.format(UIConst.Text.HP_PCT_FORMAT, cur_hp, max_hp)
        for i, building_data in ipairs(SpecMgrs.data_mgr:GetAllDynastyBuildingData()) do
            local building = attack_item:FindChild("Building" .. i)
            local rest_defender_count = self.dy_dynasty_data:CalcDynastyBuildingRestDefenderCount(enemy_info.dynasty_id, i)
            building:FindChild("Name"):GetComponent("Text").text = string.format(UIConst.Text.BATTLE_REPORT_NAME_FORMAT, building_data.name, rest_defender_count, building_data.defend_member_count)
            local rest_defend_count = self.dy_dynasty_data:CalcDynastyBuildingRestDefendCount(enemy_info.dynasty_id, i)
            building:FindChild("Info"):GetComponent("Text").text = string.format(UIConst.Text.REST_DEFEND_COUNT, rest_defend_count)
        end
    end
end

function ViewBattleUI:InitDefendSituation()
    SpecMgrs.msg_mgr:SendGetCompeteDefendInfo({}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_DEFEND_SITUTAION_FAILED)
        else
            for i, enemy_info in ipairs(self.dy_dynasty_data:GetDynastyBattleEnemyList()) do
                local defend_item = self.defend_item_list[i]
                defend_item:FindChild("Name/Text"):GetComponent("Text").text = enemy_info.dynasty_name
                local defend_info = resp.defend_dict[enemy_info.dynasty_id].building_dict
                for i, building_data in ipairs(SpecMgrs.data_mgr:GetAllDynastyBuildingData()) do
                    local building = defend_item:FindChild("Building" .. i)
                    building:FindChild("Name"):GetComponent("Text").text = string.format(UIConst.Text.BATTLE_REPORT_NAME_FORMAT, building_data.name, defend_info[i].role_num, building_data.defend_member_count)
                    building:FindChild("Info"):GetComponent("Text").text = string.format(UIConst.Text.REST_DEFEND_COUNT, defend_info[i].defend_num)
                end
            end
        end
    end)
end

function ViewBattleUI:InitMemberScore()
    SpecMgrs.msg_mgr:SendGetCompeteMemberMarkInfo({}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_DYNASTY_MEMBER_SCORE_INFO_FAILED)
        else
            local member_list = {}
            for uuid, info in pairs(resp.member_dict) do
                info.uuid = uuid
                table.insert(member_list, info)
            end
            table.sort(member_list, function (member1, member2)
                return member2.daily_mark < member1.daily_mark
            end)
            local self_uuid = ComMgrs.dy_data_mgr:ExGetRoleUuid()
            for i,member_info in ipairs(member_list) do
                local member_item = self:GetUIObject(self.member_score_item, self.member_score_content)
                table.insert(self.member_score_item_list, member_item)
                local role_data = SpecMgrs.data_mgr:GetRoleLookData(member_info.role_id)
                UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetUnitData(role_data.unit_id).icon, member_item:FindChild("IconBg/Icon"):GetComponent("Image"))
                member_item:FindChild("Name"):GetComponent("Text").text = member_info.name
                member_item:FindChild("TodayScore"):GetComponent("Text").text = string.format(UIConst.Text.DAILY_RECORD_FORMAT, member_info.daily_mark)
                member_item:FindChild("TotalScore"):GetComponent("Text").text = string.format(UIConst.Text.TOTAL_RECORD_FORMAT, member_info.total_mark)
                if member_info.uuid == self_uuid then
                    self.self_rank.text = string.format(UIConst.Text.PERSONAL_BATTLE_RANK_FROMAT, i)
                    self.self_score.text = string.format(UIConst.Text.PERSONAL_RANK_SCORE_FORMAT, member_info.daily_mark)
                end
            end
            self.member_score_content_rect.anchoredPosition = Vector2.zero
        end
    end)
end

function ViewBattleUI:ClearMemberItem()
    for _, item in ipairs(self.member_score_item_list) do
        self:DelUIObject(item)
    end
    self.member_score_item_list = {}
end

return ViewBattleUI