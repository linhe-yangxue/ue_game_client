local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local CSConst = require("CSCommon.CSConst")
local BattleUI = class("UI.BattleUI",UIBase)


function BattleUI:DoInit()
    BattleUI.super.DoInit(self)
    self.prefab_path = "UI/Common/BattleUI"
end

function BattleUI:OnGoLoadedOk(res_go)
    BattleUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function BattleUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    BattleUI.super.Show(self)
end

function BattleUI:InitRes()
    self:AddClick(self.main_panel:FindChild("UpMsgFrame/CloseBtn"), function()
        self:Hide()
    end)
    self.my_mes = self.main_panel:FindChild("MiddleFrame/MyMes")
    self.enemy_mes = self.main_panel:FindChild("MiddleFrame/EnemyMes")

    self.m_hp_slider = self.my_mes:FindChild("HpSlider/Slider"):GetComponent("Image")
    self.enemy_hp_slider = self.enemy_mes:FindChild("HpSlider/Slider"):GetComponent("Image")
    self.m_hp_text = self.my_mes:FindChild("HpSlider/Text"):GetComponent("Text")
    self.enemt_hp_text = self.enemy_mes:FindChild("HpSlider/Text"):GetComponent("Text")

    self:AddClick(self.main_panel:FindChild("DownFrame/StartBattleButton"), function()
        local resp_cb = function(resp)
            SpecMgrs.soldier_battle_mgr:StartBattle(resp)
        end
        SpecMgrs.msg_mgr:SendStageFight(nil, resp_cb)
    end)
end

function BattleUI:InitUI()
    self:UpdateData()
    self:UpdateUIInfo()
    SpecMgrs.soldier_battle_mgr:InitBattle()

    SpecMgrs.soldier_battle_mgr:RegisterUpdateBothSoldier("BattleUI", function(_, _, m_soldier_num, enemy_soldier_num)
        self:UpdateBothSoldierNum(m_soldier_num, enemy_soldier_num)
    end, self)
    SpecMgrs.soldier_battle_mgr:RegisterBattleEnd("BattleUI", function()

    end, self)
end

function BattleUI:UpdateData()
    self.cur_stage_info = ComMgrs.dy_data_mgr:ExGetStageData()
    self.cur_stage_data = SpecMgrs.data_mgr:GetStageData(self.cur_stage_info.curr_stage)

    local cur_part = self.cur_stage_info.curr_part
    self.enemy_soldier_num = self.cur_stage_data.enemy_num[cur_part]
    self.m_soldier_num = ComMgrs.dy_data_mgr:GetCurrencyData()[CSConst.Virtual.Soldier]
end

function BattleUI:UpdateUIInfo()
    local enemy_cur_soldier_num = self.cur_stage_info.remain_enemy
    self:UpdateBothSoldierNum(self.m_soldier_num, enemy_cur_soldier_num)
end

function BattleUI:UpdateBothSoldierNum(m_cur_soldier_num, enemy_cur_soldier_num)
    self.m_hp_slider.fillAmount = m_cur_soldier_num / self.m_soldier_num
    self.enemy_hp_slider.fillAmount = enemy_cur_soldier_num / self.enemy_soldier_num

    self.m_hp_text.text = m_cur_soldier_num
    self.enemt_hp_text.text = enemy_cur_soldier_num
end

function BattleUI:UnRegisterEvent()
    SpecMgrs.soldier_battle_mgr:UnregisterUpdateBothSoldier("BattleUI")
    SpecMgrs.soldier_battle_mgr:UnregisterBattleEnd("BattleUI")
end

function BattleUI:Hide()
    SpecMgrs.soldier_battle_mgr:EndBattle()
    self:UnRegisterEvent()
    BattleUI.super.Hide(self)
end

return BattleUI
