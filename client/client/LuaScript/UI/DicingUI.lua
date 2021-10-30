local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local DicingUI = class("UI.DicingUI", UIBase)
local UnitConst = require("Unit.UnitConst")
local UIFuncs = require("UI.UIFuncs")
local FloatMsgCmp = require("UI.UICmp.FloatMsgCmp")
local kGameIndex = 2
local kPlayerNum = 2

function DicingUI:DoInit()
    DicingUI.super.DoInit(self)
    self.prefab_path = "UI/Common/DicingUI"
    self.game_data = SpecMgrs.data_mgr:GetPartyGameData(kGameIndex)
    self.score_list = self.game_data.score_list -- 得分档次 从高到低
    self.max_round = self.game_data.time
    self.score_index_to_radius_list = {} -- 得分档次
    self.is_game_start = false -- 游戏是否开始
    self.party_game_score_limit = SpecMgrs.data_mgr:GetParamData("party_game_score_limit").f_value
    self.round_item_list = {}
    self.round_to_point_list = {}
    self.score_to_icon_list = self.game_data.dice_icon_list
    self.max_point = self.game_data.max_point
    self.dicing_time = self.game_data.dicing_time
end

function DicingUI:OnGoLoadedOk(res_go)
    DicingUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function DicingUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    DicingUI.super.Show(self)
end

function DicingUI:Update(delta_time)
    if not self.is_res_ok then return end
    self.my_msg_cmp:Update(delta_time)
    self.other_msg_cmp:Update(delta_time)
end

function DicingUI:InitRes()
    UIFuncs.GetInitTopBar(self, self.main_panel, "DicingUI")
    self.close_btn = self.top_bar:FindChild("CloseBtn"):GetComponent("Button")
    self.main_panel:FindChild("Rule/Text"):GetComponent("Text").text = self.game_data.rule_text
    self.start_game_btn = self.main_panel:FindChild("StartGameBtn")
    self:AddClick(self.start_game_btn, function ()
        self.start_game_btn:SetActive(false)
    end)
    self.start_game_btn:SetActive(true)
    self.main_panel:FindChild("TopBar/CloseBtn"):GetComponent("Button")

    self.round_text = self.main_panel:FindChild("BottomBar/Round"):GetComponent("Text")
    self.score_text = self.main_panel:FindChild("BottomBar/Score"):GetComponent("Text")
    self.my_lover_go = self.main_panel:FindChild("MyLover")
    self.my_lover_unit_parent = self.my_lover_go:FindChild("UnitParent")
    self.my_dice_go = self.main_panel:FindChild("MyDice")
    self.my_dice_go:FindChild("Text"):GetComponent("Text").text = UIConst.Text.PLEASE_THROW_DICE

    self.other_lover_go = self.main_panel:FindChild("OtherLover")
    self.other_lover_unit_parent = self.other_lover_go:FindChild("UnitParent")
    self.other_lover_name_text = self.other_lover_go:FindChild("LoverName/Text"):GetComponent("Text")
    self.other_dice_go = self.main_panel:FindChild("OtherDice")
    self:AddClick(self.my_dice_go, function()
        self:DicingBtnOnClick()
    end)

    self.my_msg_cmp = FloatMsgCmp.New()
    local my_float_mes_box = self.my_dice_go:FindChild("MsgBox")
    local my_float_mes_box_temp = my_float_mes_box:FindChild("Item")
    self.my_msg_cmp:DoInit(self, my_float_mes_box, my_float_mes_box_temp)
    self.other_msg_cmp = FloatMsgCmp.New()
    local other_float_mes_box = self.other_dice_go:FindChild("MsgBox")
    local other_float_mes_box_temp = other_float_mes_box:FindChild("Item")
    self.other_msg_cmp:DoInit(self, other_float_mes_box, other_float_mes_box_temp)

    self.round_item_parent = self.main_panel:FindChild("RoundInfo/Content")
    self.round_item_temp = self.round_item_parent:FindChild("Temp")
    self.round_item_temp:SetActive(false)
    self:GetRoundItem({UIConst.Text.ROUND_TITLE, UIConst.Text.SELF_TEXT, UIConst.Text.OPPONENT}, false)
end

function DicingUI:InitUI()
    self.join_party_info = ComMgrs.dy_data_mgr.party_data:GetJoinPartyInfo()
    self.my_guest_info = ComMgrs.dy_data_mgr.party_data:GetMyGuestInfo()
    self.my_lover_unit_id = SpecMgrs.data_mgr:GetLoverData(self.my_guest_info.lover_id).unit_id
    self.other_lover_unit_id = SpecMgrs.data_mgr:GetLoverData(self.join_party_info.lover_id).unit_id
    self.close_btn.interactable = true
    self:UpdateUnit()
    self.other_lover_name_text.text = string.format(UIConst.Text.LOVER_OF_SOMEONE, self.join_party_info.host_info.name)
    self:SetScore(0)
    self:SetRound(0)
    self:StopDicingAnim(self.my_dice_go)
    self:StopDicingAnim(self.other_dice_go)
    self.start_game_btn:SetActive(true)
end

function DicingUI:StartGame()
    self.is_game_start = true
    self.close_btn.interactable = false
    self:SetRound(1)
end

function DicingUI:EndGame()
    self.is_game_start = false
    self.close_btn.interactable = true
    if ComMgrs.dy_data_mgr.party_data:CanStartGame() then
        SpecMgrs.msg_mgr:SendMsg("SendPartyGames", {score = self.score}, function(resp)
            if resp.integral then
                local ui_name = "PartyGameEndUI"
                local tag = self.class_name
                SpecMgrs.ui_mgr:ShowUI(ui_name, resp.integral)
                SpecMgrs.ui_mgr:RegisterHideUIEvent(tag, function(_, ui)
                    if ui.class_name == ui_name then
                        SpecMgrs.ui_mgr:HideUI(self)
                        SpecMgrs.ui_mgr:UnregisterHideUIEvent(tag)
                    end
                end)
            end
        end)
    end
end

function DicingUI:PlayDicingAnim(go, score)
    local anim_go = go:FindChild("Fx_paidui_touzi")
    anim_go:SetActive(false)
    anim_go:SetActive(true)
    local icon = self.score_to_icon_list[score]
    self:AssignSpriteByIconID(icon, go:FindChild("Dice"):GetComponent("Image"))
end

function DicingUI:StopDicingAnim(go)
    local anim_go = go:FindChild("Fx_paidui_touzi")
    anim_go:SetActive(false)
end

function DicingUI:DicingBtnOnClick()
    if not self.is_game_start then
        self:StartGame()
    end
    if self.is_anim then return end
    if not self:CheckRemainTime() then return end
    self:StartAnim()
end

function DicingUI:StartAnim()
    self.is_anim = true
    for i = 1, kPlayerNum do
        if not self.round_to_point_list[self.round] then self.round_to_point_list[self.round] = {} end
        self.round_to_point_list[self.round][i] = math.random(1, self.max_point)
    end
    self:PlayDicingAnim(self.my_dice_go, self.round_to_point_list[self.round][1])
    self:PlayDicingAnim(self.other_dice_go, self.round_to_point_list[self.round][2])
    self:AddTimer(function()
        self:EndAnim()
    end, self.dicing_time, 1)
end

function DicingUI:EndAnim()
    local cur_round_point = self.round_to_point_list[self.round]
    local my_point = cur_round_point[1]
    local other_point = cur_round_point[2]
    local score_index = self:GetScoreIndex(my_point, other_point)
    if self.score_list[score_index] then
        local score = self.score + self.score_list[score_index]
        self:InsertRoundInfo(self.round, cur_round_point)
        self:SetScore(score)
    end
    self.my_msg_cmp:ShowMsg(self:GetFloatMsg(my_point))
    self.other_msg_cmp:ShowMsg(self:GetFloatMsg(other_point))
    self.round = self.round + 1
    if self:CheckGameEnd() then -- 检查游戏是否结束
        self:EndGame()
    else
        self:SetRound(self.round)
    end
    self.is_anim = false
end

function DicingUI:CheckGameEnd()
    if not self:CheckRemainTime() then return true end
    if not self:CheckScoreLimit() then return true end
end

function DicingUI:CheckScoreLimit()
    return self.score < self.party_game_score_limit
end

function DicingUI:GetFloatMsg(point)
    return string.format(UIConst.Text.ADD_WITH_SPACE, point)
end

function DicingUI:InsertRoundInfo(round, point_list)
    local str_list = {}
    local str = string.format(UIConst.Text.ROUND_NUM_FORMAT1, round)
    table.insert(str_list, str)
    table.insert(str_list, self:GetPointStr(point_list[1], point_list[2]))
    table.insert(str_list, self:GetPointStr(point_list[2], point_list[1]))
    self:GetRoundItem(str_list, true)
end

function DicingUI:GetPointStr(num, compare_num)
    local color
    if num > compare_num then
        color = "Green1"
    else
        color = "Default"
    end
    local str = string.format(UIConst.Text.POINT_NUM, num)
    return UIFuncs.ChangeStrColor(str, color)
end

function DicingUI:GetRoundItem(str_list, is_clear_by_ui_hide)
    local go = self:GetUIObject(self.round_item_temp, self.round_item_parent)
    if is_clear_by_ui_hide then
        table.insert(self.round_item_list, go)
    end
    self:_UpdateRoundText(go, str_list)
end

function DicingUI:_UpdateRoundText(go, str_list)
    for i, str in ipairs(str_list) do
        go:FindChild(i .. "/Text"):GetComponent("Text").text = str
    end
end

function DicingUI:CheckRemainTime()
    return self.round <= self.max_round
end

function DicingUI:SetScore(score)
    local score = math.clamp(score, 0, self.party_game_score_limit)
    self.score = score
    self.score_text.text = string.format(UIConst.Text.PARTY_POINT_ALREADY_GET, self.score)
end

function DicingUI:SetRound(round)
    self.round = round
    self.round_text.text = string.format(UIConst.Text.GAME_ROUND_NUM, self.round, self.max_round)
end

function DicingUI:GetScoreIndex(my_point, other_point)
    if my_point > other_point then
        return 1
    elseif self.my_point == self.other_point then
        return 2
    else
        return 3
    end
end

function DicingUI:UpdateUnit()
    if not self.my_lover_unit_id then return end
    self:ClearUnitByName("my_lover_unit")
    self:ClearUnitByName("other_lover_unit")
    self.my_lover_unit = self:AddFullUnit(self.my_lover_unit_id, self.my_lover_unit_parent, nil, nil)
    self.other_lover_unit = self:AddFullUnit(self.other_lover_unit_id, self.other_lover_unit_parent, nil, nil)
end

function DicingUI:ClearUnitByName(unit_name)
    if self[unit_name] then
        self[unit_name]:DoDestroy()
        self[unit_name] = nil
    end
end

function DicingUI:Hide()
    self:ClearGoDict("round_item_list")
    self:ClearUnitByName("my_lover_unit")
    self:ClearUnitByName("other_lover_unit")
    self.round_to_point_list = {}
    self.my_msg_cmp:ClearRes()
    self.other_msg_cmp:ClearRes()
    DicingUI.super.Hide(self)
end

return DicingUI