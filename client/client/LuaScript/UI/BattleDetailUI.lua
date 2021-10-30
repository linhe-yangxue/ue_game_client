local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local CSConst = require("CSCommon.CSConst")
local BattleDetailUI = class("UI.BattleDetailUI",UIBase)

--  战斗详情
function BattleDetailUI:DoInit()
    BattleDetailUI.super.DoInit(self)
    self.prefab_path = "UI/Common/BattleDetailUI"
    self.cur_share_time = 0
end

function BattleDetailUI:OnGoLoadedOk(res_go)
    BattleDetailUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function BattleDetailUI:Show(is_win, target_player_name, hurt_info, fight_data)
    self.is_win = is_win
    self.target_player_name = target_player_name
    self.hurt_info = hurt_info
    self.fight_data = fight_data
    if self.is_res_ok then
        self:InitUI()
    end
    BattleDetailUI.super.Show(self)
end

function BattleDetailUI:InitRes()
    self.share_text = self.main_panel:FindChild("Frame/ContentPanel/NotSharePanel/ShareText"):GetComponent("Text")
    self.scroll_rect = self.main_panel:FindChild("Frame/ContentPanel/ScrollRect"):GetComponent("RectTransform")
    self.my_server_chat = self.main_panel:FindChild("Frame/ContentPanel/NotSharePanel/ToggleGroup/MyServerChat"):GetComponent("Toggle")
    self.dynasty_chat = self.main_panel:FindChild("Frame/ContentPanel/NotSharePanel/ToggleGroup/DynastyChat"):GetComponent("Toggle")
    self.player_list = self.main_panel:FindChild("Frame/ContentPanel/ScrollRect/ViewPort/Content/PlayerList")
    self.hero_mes_item = self.main_panel:FindChild("Frame/ContentPanel/ScrollRect/ViewPort/Content/PlayerList/HeroMesItem")
    self.enemy_list = self.main_panel:FindChild("Frame/ContentPanel/ScrollRect/ViewPort/Content/EnemyList")
    self.enemy_mes_item = self.main_panel:FindChild("Frame/ContentPanel/ScrollRect/ViewPort/Content/EnemyList/HeroMesItem")
    self.vs_image = self.main_panel:FindChild("Frame/VsImage")
    self.player_mes = self.main_panel:FindChild("Frame/PlayerMes")
    self.enemy_mes = self.main_panel:FindChild("Frame/EnemyMes")
    self.middle_player_mes = self.main_panel:FindChild("Frame/MiddlePlayerMes")
    self.my_server_chat_text = self.main_panel:FindChild("Frame/ContentPanel/NotSharePanel/ToggleGroup/MyServerChat/Label"):GetComponent("Text")
    self.dynasty_chat_text = self.main_panel:FindChild("Frame/ContentPanel/NotSharePanel/ToggleGroup/DynastyChat/Label"):GetComponent("Text")

    self.close_btn = self.main_panel:FindChild("Frame/ContentPanel/NotSharePanel/CloseBtn")
    self:AddClick(self.close_btn, function()
        self:Hide()
    end)
    self.share_btn = self.main_panel:FindChild("Frame/ContentPanel/NotSharePanel/ShareBtn")
    self:AddClick(self.share_btn, function()
        self:ShareToChat()
    end)

    self.not_share_panel = self.main_panel:FindChild("Frame/ContentPanel/NotSharePanel")

    self.share_panel = self.main_panel:FindChild("Frame/ContentPanel/SharePanel")
    self.share_panel_btn = self.share_panel:FindChild("CloseBtn")
    self:AddClick(self.share_panel_btn, function()
        self:Hide()
    end)

    self.list_content = self.main_panel:FindChild("Frame/ContentPanel/ScrollRect/ViewPort/Content"):GetComponent("ContentSizeFitter")
    self.hero_mes_item:SetActive(false)
    self.enemy_mes_item:SetActive(false)
    self:SetTextVal()

    self.share_channel_dict = {
        [self.my_server_chat] = CSConst.ChatType.World,
        [self.dynasty_chat] = CSConst.ChatType.Dynasty,
    }
    SpecMgrs.ui_mgr:RegisterHeroBattleUIClose("BattleDetailUI", function()
        self.cur_share_time = 0
    end)
end

function BattleDetailUI:InitUI()
    self:UpdateData()
    self:UpdateUIInfo()
end

function BattleDetailUI:UpdateData()
    self.can_share_dict = {
        [self.my_server_chat] = true,
        [self.dynasty_chat] = true,
    }
    self.is_share_panel = false
    if not self.hurt_info then
        self.hurt_info = SpecMgrs.hero_battle_mgr:GetHurtInfo()
        self.is_share_panel = true
    end
    if not self.fight_data then
        self.fight_data = SpecMgrs.hero_battle_mgr:GetFightData()
        self.is_share_panel = true
    end
    self.max_share_time = SpecMgrs.data_mgr:GetParamData("share_limit_time").f_value
end

function BattleDetailUI:UpdateUIInfo()
    self.share_panel:SetActive(not self.is_share_panel)
    self.not_share_panel:SetActive(self.is_share_panel)
    self.my_server_chat.isOn = true
    self.dynasty_chat.isOn = false
    local player_hurt = table.sum(self.hurt_info[1])
    local enemy_hurt = table.sum(self.hurt_info[2])
    if self.target_player_name then
        self.player_mes:SetActive(true)
        self.enemy_mes:SetActive(true)
        self.middle_player_mes:SetActive(false)
        self.vs_image:SetActive(true)
        self:SetPlayerMes(self.player_mes, self.is_win, ComMgrs.dy_data_mgr:ExGetRoleName(), player_hurt)
        self:SetPlayerMes(self.enemy_mes, not self.is_win, self.target_player_name, enemy_hurt)
    else
        self.player_mes:SetActive(false)
        self.enemy_mes:SetActive(false)
        self.vs_image:SetActive(false)
        self.middle_player_mes:SetActive(true)
        self:SetPlayerMes(self.middle_player_mes, self.is_win, ComMgrs.dy_data_mgr:ExGetRoleName(), player_hurt)
    end

    local mvp_index = 0
    if self.is_win then
        mvp_index = self:GetMvpPos(self.hurt_info[1])
    end
    for i, hero_data in ipairs(self.fight_data.own_fight_data) do
        if next(hero_data) then
            local unit_name = SpecMgrs.data_mgr:GetUnitData(hero_data.unit_id).name
            local item = self:GetUIObject(self.hero_mes_item, self.player_list)
            local hurt = self.hurt_info[1][i]
            local precent
            if player_hurt == 0 then
                precent = 0
            else
                precent = hurt / player_hurt
            end
            local is_mvp = mvp_index == i
            self:SetItemMes(item, hero_data.unit_id, unit_name, hurt, is_mvp, precent)
        end
    end

    if not self.is_win then
        mvp_index = self:GetMvpPos(self.hurt_info[2])
    else
        mvp_index = 0
    end
    for i, hero_data in ipairs(self.fight_data.enemy_fight_data) do
        if next(hero_data) then
            local unit_name
            if hero_data.monster_id then
                local monster_data = SpecMgrs.data_mgr:GetMonsterData(hero_data.monster_id)
                unit_name = monster_data.name or SpecMgrs.data_mgr:GetHeroData(monster_data.hero_id).name
            else
                unit_name = SpecMgrs.data_mgr:GetUnitData(hero_data.unit_id).name
            end

            local item = self:GetUIObject(self.enemy_mes_item, self.enemy_list)
            local hurt = self.hurt_info[2][i]
            local precent
            if enemy_hurt == 0 then
                precent = 0
            else
                precent = hurt / enemy_hurt
            end
            local is_mvp = mvp_index == i
            self:SetItemMes(item, hero_data.unit_id, unit_name, hurt, is_mvp, precent)
        end
    end
    self.list_content:SetLayoutVertical()
end

function BattleDetailUI:GetMvpPos(hurt_list)
    local max_val = 0
    local ret = 1
    for i, val in pairs(hurt_list) do
        if val >= max_val then
            max_val = val
            ret = i
        end
    end
    return ret
end

function BattleDetailUI:ShareToChat()
    if self.cur_share_time >= self.max_share_time then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.SHARE_FAIL_TEXT)
        return
    end

    local my_name = ComMgrs.dy_data_mgr:ExGetRoleName()
    local content
    if self.target_player_name then
        content = string.format(UIConst.Text.BATTLE_PVP_CHAT_CONTENT_FORMAT, my_name, self.target_player_name)
    else
        content = string.format(UIConst.Text.BATTLE_PVE_CHAT_CONTENT_FORMAT, my_name)
    end
    local param_tb =
    {
        channel = self.share_channel_dict[self:GetCurToggle()],
        link_type = CSConst.HyperLinkType.BattleReport,
        param_tb = {self.is_win, self.target_player_name, self.hurt_info, self.fight_data},
        content = content,
    }
    if ComMgrs.dy_data_mgr.chat_data:SendChatMsgWithHyperlink(param_tb) then
        self.cur_share_time = self.cur_share_time + 1
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.SHARE_SUCCESS_TEXT)
    end
end

function BattleDetailUI:GetCurToggle()
    if self.my_server_chat.isOn then
        return self.my_server_chat
    elseif self.dynasty_chat.isOn then
        return self.dynasty_chat
    end
end

function BattleDetailUI:SetItemMes(item, unit_id, unit_name, hurt, is_mvp, precent)
    item:FindChild("Mvp"):SetActive(is_mvp)
    item:FindChild("HeroName"):GetComponent("Text").text = unit_name
    item:FindChild("HurtText"):GetComponent("Text").text = string.format(UIConst.Text.HURT_FORMAT, UIFuncs.AddCountUnit(hurt))

    local precent_str = string.format("%.1f", precent * 100)
    item:FindChild("PrecentText"):GetComponent("Text").text = string.format(UIConst.Text.PERCENT, precent_str)
    item:FindChild("HurtPrecent/HurtPrecent"):GetComponent("Image").fillAmount = precent

    local icon_id = SpecMgrs.data_mgr:GetUnitData(unit_id).icon
    UIFuncs.AssignSpriteByIconID(icon_id, item:FindChild("HeroIcon/Icon"):GetComponent("Image"))
end

function BattleDetailUI:SetPlayerMes(item, is_win, player_name, hurt)
    item:FindChild("PlayerWin"):SetActive(is_win)
    item:FindChild("PlayerLost"):SetActive(not is_win)
    item:FindChild("PlayerName"):GetComponent("Text").text = string.format(UIConst.Text.PLAYER_ARMY_NAME_FORMAT, player_name)
    item:FindChild("PlayerHurt"):GetComponent("Text").text = string.format(UIConst.Text.HURT_FORMAT, UIFuncs.AddCountUnit(hurt))
end

function BattleDetailUI:SetTextVal()
    self.share_text.text = UIConst.Text.SHARE_TO_TEXT
    self.my_server_chat_text.text = UIConst.Text.MYSERVER_CHAT
    self.dynasty_chat_text.text = UIConst.Text.DYNASTY_CHAT

    self.close_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CLOSE_TEXT
    self.share_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SHARE_TEXT
    self.share_panel_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CLOSE_TEXT
end

function BattleDetailUI:Hide()
    self:DelAllCreateUIObj()
    BattleDetailUI.super.Hide(self)
end

return BattleDetailUI
