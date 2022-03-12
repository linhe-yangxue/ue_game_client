local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local RankMainUI = class("UI.RankMainUI", UIBase)

local kOpIndex = {
    PowerRankTab = 1,     -- 总战力
    LevelsRankTab = 2,    -- 关卡
    GangRankTab = 3,      --帮派战力
}

function RankMainUI:DoInit()
    RankMainUI.super.DoInit(self)
    --self.dy_vip_data = ComMgrs.dy_data_mgr.vip_data
    self.power_unit_id = SpecMgrs.data_mgr:GetParamData("fund_welfare_unit").unit_id
    self.levels_unit_id = SpecMgrs.data_mgr:GetParamData("server_fund_unit").unit_id
    self.gang_unit_id = 24031
    self.prefab_path = "UI/Common/RankMainUI"
    self.tab_op_data = {}
    self.main_rank_item_list = {}
    self.power_task_list = {}
end

function RankMainUI:OnGoLoadedOk(res_go)
    RankMainUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function RankMainUI:Hide()
    RankMainUI.super.Hide(self)
    self:ClearRes()
    self:CloseCurTabPanel()
    self:ClearUnitModel()
end

function RankMainUI:Show(resp)
    print("排行榜页面111---",self.is_res_ok)
    if self.is_res_ok then
        self:InitUI()
    end
    RankMainUI.super.Show(self)
    print("排行榜页面----",resp)
    self:InitPowerRankList(resp)
    self:UpdateTabPanel(kOpIndex.PowerRankTab)

end

function RankMainUI:Update(delta_time)
    --self:UpdateRefreshTime()
end

function RankMainUI:UpdateRefreshTime()
    local next_refresh_time = self.dy_vip_data:GetVipShopRefreshTime()
    local remian_time = next_refresh_time - Time:GetServerTime()
    self.refresh_text.text = UIFuncs.TimeDelta2Str(remian_time, 4, UIConst.Text.VIP_SHOP_REFRESH_TIME)
end

function RankMainUI:InitRes()
    print("谁先走-----")
    local rank_main_panel = self.main_panel:FindChild("RankMainFrame")
    --总战力排行榜
    self.power_panel = rank_main_panel:FindChild("PowerPanel")
    local power_info_panel = self.power_panel:FindChild("InfoPanel")
    self.power_lover_model = power_info_panel:FindChild("LoverModel")

    self.power_task_list = self.power_panel:FindChild("TaskList/View/Content")
    self.power_item = self.power_task_list:FindChild("TaskItem")
    --self.power_item_rank_id = self.power_item:FindChild("Reward/Text"):GetComponent("Text")
    --self.power_item_rank_name = self.power_item:FindChild("Reward/Name"):GetComponent("Text")
    --self.power_item_rank_score = self.power_item:FindChild("Reward/Score"):GetComponent("Text")

    --关卡排行榜
    self.levels_panel = rank_main_panel:FindChild("LevelsPanel")
    local levels_info_panel = self.levels_panel:FindChild("InfoPanel")
    self.levels_lover_model = levels_info_panel:FindChild("LoverModel")

    self.levels_task_list = self.levels_panel:FindChild("TaskList/View/Content")
    self.levels_item = self.levels_task_list:FindChild("TaskItem")
    self.levels_item_rank_id = self.levels_item:FindChild("Reward/Text"):GetComponent("Text")
    self.levels_item_rank_name = self.levels_item:FindChild("Reward/Name"):GetComponent("Text")
    self.levels_item_rank_score = self.levels_item:FindChild("Reward/Score"):GetComponent("Text")

    --帮派战力排行榜
    self.gang_panel = rank_main_panel:FindChild("GangPanel")
    local gang_info_panel = self.gang_panel:FindChild("InfoPanel")
    self.gang_lover_model = gang_info_panel:FindChild("LoverModel")

    self.gang_task_list = self.gang_panel:FindChild("TaskList/View/Content")
    self.gang_item = self.gang_task_list:FindChild("TaskItem")
    self.gang_item_rank_id = self.gang_item:FindChild("Reward/Text"):GetComponent("Text")
    self.gang_item_rank_name = self.gang_item:FindChild("Reward/Name"):GetComponent("Text")
    self.gang_item_rank_score = self.gang_item:FindChild("Reward/Score"):GetComponent("Text")

    --动画效果
    self.tween = rank_main_panel:FindChild("Tween")

    local rank_btn_list = self.main_panel:FindChild("RankBtnList")

    local power_rank_btn_tab_data = {}
    local power_rank_btn = rank_btn_list:FindChild("PowerRank")
    power_rank_btn:FindChild("Text"):GetComponent("Text").text = "总战力"
    local power_select = power_rank_btn:FindChild("Select")
    power_rank_btn_tab_data.select = power_select
    power_select:FindChild("Text"):GetComponent("Text").text = "总战力"
    self:AddClick(power_rank_btn, function ()
        --self.tween:SetActive(false)

        self:UpdateTabPanel(kOpIndex.PowerRankTab)
    end)
    power_rank_btn_tab_data.panel = self.power_panel
    self.tab_op_data[kOpIndex.PowerRankTab] = power_rank_btn_tab_data

    local levels_rank_btn_tab_data = {}
    local levels_rank_btn = rank_btn_list:FindChild("LevelsRank")
    levels_rank_btn:FindChild("Text"):GetComponent("Text").text = "关卡"
    local levels_select = levels_rank_btn:FindChild("Select")
    levels_rank_btn_tab_data.select = levels_select
    levels_select:FindChild("Text"):GetComponent("Text").text = "关卡"
    self:AddClick(levels_rank_btn, function ()
        self.tween:SetActive(false)
        self:UpdateTabPanel(kOpIndex.LevelsRankTab)
    end)
    levels_rank_btn_tab_data.panel = self.levels_panel
    self.tab_op_data[kOpIndex.LevelsRankTab] = levels_rank_btn_tab_data

    local gang_rank_btn_tab_data = {}
    local gang_rank_btn = rank_btn_list:FindChild("GangRank")
    gang_rank_btn:FindChild("Text"):GetComponent("Text").text = "帮派战力"
    local gang_select = gang_rank_btn:FindChild("Select")
    gang_rank_btn_tab_data.select = gang_select
    gang_select:FindChild("Text"):GetComponent("Text").text = "帮派战力"
    self:AddClick(gang_rank_btn, function ()
        self.tween:SetActive(false)
        self:UpdateTabPanel(kOpIndex.GangRankTab)
    end)
    gang_rank_btn_tab_data.panel = self.gang_panel
    self.tab_op_data[kOpIndex.GangRankTab] = gang_rank_btn_tab_data
end

function RankMainUI:InitUI()
    self:InitTopBar()
    --self.tween:SetActive(true)
    self.power_unit = self:AddHalfUnit(self.power_unit_id, self.power_lover_model)
    self.levels_unit = self:AddHalfUnit(self.levels_unit_id, self.levels_lover_model)
    self.gang_unit = self:AddHalfUnit(self.gang_unit_id, self.gang_lover_model)
    --self.power_item_rank_id.text = "1st"
    --self.power_item_rank_name.text = "会飞的猪"
    --self.power_item_rank_score.text = "99999999999999"

    self.levels_item_rank_id.text = "2st"
    self.levels_item_rank_name.text = "会走的鱼"
    self.levels_item_rank_score.text = "888888888888"

    self.gang_item_rank_id.text = "3st"
    self.gang_item_rank_name.text =  "会游的猴"
    self.gang_item_rank_score.text = "777777777777777"
end

function RankMainUI:InitPowerRankList(resp)
    print("谁先走1111-----")

    for rank, rank_info in ipairs(resp.rank_list) do
        local rank_item = self:GetUIObject(self.power_item , self.power_task_list)
        table.insert(self.main_rank_item_list, rank_item)
        rank_item:FindChild("Reward/Text"):GetComponent("Text").text = rank
        rank_item:FindChild("Reward/Name"):GetComponent("Text").text = rank_info.name
        rank_item:FindChild("Reward/Score"):GetComponent("Text").text = rank_info.rank_score
        print("232323---",rank)
        print("345353---",rank_info)
        if rank< 8 then
            local tween_rank = self.tween:FindChild("RankItemList"..rank)
            tween_rank:SetActive(true)
            tween_rank:FindChild("ItemList/Text"):GetComponent("Text").text = rank
            tween_rank:FindChild("ItemList/Name"):GetComponent("Text").text = rank_info.name
            tween_rank:FindChild("ItemList/Score"):GetComponent("Text").text = rank_info.rank_score
        end
    end
    self.tween:SetActive(true)
    self.power_task_list:SetActive(false)
    coroutine.start(function ()
        coroutine.wait(1)
        print("test---------")
        self.tween:SetActive(false)
        self.power_task_list:SetActive(true)
    end)
    --unity.StartCoroutine(function()
    --    coroutine.yield(UnityEngine.WaitForSeconds(1))
    --    print("test---------")
    --    self.tween:SetActive(false)
    --end);
end

function RankMainUI:UpdateTabPanel(op_index)
    if self.cur_op_index == op_index then return end
    self:CloseCurTabPanel()
    --self.tween:SetActive(false)
    self.cur_op_index = op_index
    local cur_tab_data = self.tab_op_data[self.cur_op_index]
    cur_tab_data.select:SetActive(true)
    if cur_tab_data.init_func then cur_tab_data.init_func(self) end
    cur_tab_data.panel:SetActive(true)
end

function RankMainUI:CloseCurTabPanel()
    if self.cur_op_index then
        local cur_tab_data = self.tab_op_data[self.cur_op_index]
        cur_tab_data.select:SetActive(false)
        cur_tab_data.panel:SetActive(false)
        self.cur_op_index = nil
    end
end

function RankMainUI:ClearUnitModel()
    if self.power_unit then
        self:RemoveUnit(self.power_unit)
        self.power_unit = nil
    end
    if self.levels_unit then
        self:RemoveUnit(self.levels_unit)
        self.levels_unit = nil
    end
    if self.gang_unit then
        self:RemoveUnit(self.gang_unit)
        self.gang_unit = nil
    end
end

function RankMainUI:ClearRes()
    self:DelAllCreateUIObj()
end

function RankMainUI:ClearRankItem()
    for i = 0 , #self.main_rank_item_list do
        self:DelUIObject(table.remove(self.main_rank_item_list,i + 1))
    end
end

return RankMainUI