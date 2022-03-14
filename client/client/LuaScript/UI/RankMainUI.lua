local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local RankMainUI = class("UI.RankMainUI", UIBase)

local kOpIndex = {
    PowerRankTab = 1,     -- 总战力跨服排行
    LevelsRankTab = 2,    -- 关卡星数跨服排行
    GangRankTab = 3,      --帮派战力跨服排行
    DynastyRankTab = 4,      --王朝跨服排行
}

function RankMainUI:DoInit()
    RankMainUI.super.DoInit(self)
    --self.dy_vip_data = ComMgrs.dy_data_mgr.vip_data
    --self.power_unit_id = SpecMgrs.data_mgr:GetParamData("fund_welfare_unit").unit_id
    --self.levels_unit_id = SpecMgrs.data_mgr:GetParamData("server_fund_unit").unit_id
    --self.gang_unit_id = 24031
    self.prefab_path = "UI/Common/RankMainUI"
    self.tab_op_data = {}
    --self.main_rank_item_list = {}
    self.power_task_list = {}
    self.levels_task_list = {}
    self.gang_task_list = {}
end

function RankMainUI:OnGoLoadedOk(res_go)
    print("排行榜排行榜排行榜----OnGoLoadedOk-----",res_go)
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
    print("排行榜排行榜排行榜----Show-----")
    --print("排行榜页面111---",self.is_res_ok)
    if self.is_res_ok then
        self:InitUI()
    end
    RankMainUI.super.Show(self)
    --print("排行榜页面----",resp)
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
    print("排行榜排行榜排行榜----InitRes-----")
    local rank_main_panel = self.main_panel:FindChild("RankMainFrame")

    self.title = self.main_panel:FindChild("Title")
    self.rank = self.title:FindChild("Rank/Text")
    self.player = self.title:FindChild("Player/Text")
    self.score = self.title:FindChild("Score/Text")
    self.server = self.title:FindChild("Server/Text")
    --总战力排行榜
    self.power_panel = rank_main_panel:FindChild("PowerPanel")
    self.power_info_panel = self.power_panel:FindChild("InfoPanel")
    self.power_lover_model = self.power_info_panel:FindChild("LoverModel")
    self.power_name = self.power_info_panel:FindChild("Content/Name")
    self.power_score = self.power_info_panel:FindChild("Score/Text")
    self.my_rank = self.power_panel:FindChild("MyRank")
    --排行榜点赞
    self.tags = self.power_info_panel:FindChild("Tags")

    self.power_task_list = self.power_panel:FindChild("TaskList/View/Content")
    self.power_item = self.power_task_list:FindChild("TaskItem")
    --self.role_icon = basic_info_panel:FindChild("IconBg/Icon"):GetComponent("Image")
    --self.power_item_rank_id = self.power_item:FindChild("Reward/Text"):GetComponent("Text")
    --self.power_item_rank_name = self.power_item:FindChild("Reward/Name"):GetComponent("Text")
    --self.power_item_rank_score = self.power_item:FindChild("Reward/Score"):GetComponent("Text")

    --关卡排行榜
    self.levels_panel = rank_main_panel:FindChild("LevelsPanel")
    self.levels_info_panel = self.levels_panel:FindChild("InfoPanel")
    self.levels_lover_model = self.levels_info_panel:FindChild("LoverModel")
    self.levels_name = self.levels_info_panel:FindChild("Content/Name")
    self.levels_score = self.levels_info_panel:FindChild("Score/Text")

    self.levels_task_list = self.levels_panel:FindChild("TaskList/View/Content")
    self.levels_item = self.levels_task_list:FindChild("TaskItem")
    --self.levels_item_rank_id = self.levels_item:FindChild("Reward/Text"):GetComponent("Text")
    --self.levels_item_rank_name = self.levels_item:FindChild("Reward/Name"):GetComponent("Text")
    --self.levels_item_rank_score = self.levels_item:FindChild("Reward/Score"):GetComponent("Text")

    --帮派战力排行榜
    self.gang_panel = rank_main_panel:FindChild("GangPanel")
    self.gang_info_panel = self.gang_panel:FindChild("InfoPanel")
    self.gang_lover_model = self.gang_info_panel:FindChild("LoverModel")
    self.gang_name = self.gang_info_panel:FindChild("Content/Name")
    self.gang_score = self.gang_info_panel:FindChild("Score/Text")

    self.gang_task_list = self.gang_panel:FindChild("TaskList/View/Content")
    self.gang_item = self.gang_task_list:FindChild("TaskItem")
    --self.gang_item_rank_id = self.gang_item:FindChild("Reward/Text"):GetComponent("Text")
    --self.gang_item_rank_name = self.gang_item:FindChild("Reward/Name"):GetComponent("Text")
    --self.gang_item_rank_score = self.gang_item:FindChild("Reward/Score"):GetComponent("Text")

    --王朝跨服排行
    self.dynasty_panel = rank_main_panel:FindChild("DynastyPanel")
    self.dynasty_info_panel = self.dynasty_panel:FindChild("InfoPanel")
    self.dynasty_lover_model = self.dynasty_info_panel:FindChild("LoverModel")
    self.dynasty_name = self.dynasty_info_panel:FindChild("Content/Name")
    self.dynasty_score = self.dynasty_info_panel:FindChild("Score/Text")

    self.dynasty_task_list = self.dynasty_panel:FindChild("TaskList/View/Content")
    self.dynasty_item = self.dynasty_task_list:FindChild("TaskItem")

    --动画效果
    --self.tween = rank_main_panel:FindChild("Tween")
    --self.info_panel_tween = rank_main_panel:FindChild("InfoPanelTween")
    --self.info_name = self.info_panel_tween:FindChild("Content/Name")
    --self.info_score = self.info_panel_tween:FindChild("Score/Text")

    local rank_btn_list = self.main_panel:FindChild("RankBtnList")

    local power_rank_btn_tab_data = {}
    local power_rank_btn = rank_btn_list:FindChild("PowerRank")
    power_rank_btn:FindChild("Text"):GetComponent("Text").text = "总战力"
    local power_select = power_rank_btn:FindChild("Select")
    power_rank_btn_tab_data.select = power_select
    power_select:FindChild("Text"):GetComponent("Text").text = "总战力"
    self:AddClick(power_rank_btn, function ()
        SpecMgrs.msg_mgr:SendGetPowerRank({}, function (resp)
            self:InitPowerRankList(resp)
        end)
        self:UpdateTabPanel(kOpIndex.PowerRankTab)
    end)
    power_rank_btn_tab_data.panel = self.power_panel
    self.tab_op_data[kOpIndex.PowerRankTab] = power_rank_btn_tab_data

    local levels_rank_btn_tab_data = {}
    local levels_rank_btn = rank_btn_list:FindChild("LevelsRank")
    levels_rank_btn:FindChild("Text"):GetComponent("Text").text = "星数"
    local levels_select = levels_rank_btn:FindChild("Select")
    levels_rank_btn_tab_data.select = levels_select
    levels_select:FindChild("Text"):GetComponent("Text").text = "星数"
    self:AddClick(levels_rank_btn, function ()
        SpecMgrs.msg_mgr:SendGetLevelsRank({}, function (resp)
            if resp.errcode == 1 then
                print("关卡星数排行数据---",resp)
                SpecMgrs.ui_mgr:ShowMsgBox("页面刷新失败！")
            else
                print("关卡星数排行数据111---",resp)
            end
            self:InitLevelsRankList(resp)
        end)
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
        SpecMgrs.msg_mgr:SendGetGangRank({}, function (resp)
            print("帮派战力---",resp)
            self:InitGangRankList(resp)
        end)
        self:UpdateTabPanel(kOpIndex.GangRankTab)
    end)
    gang_rank_btn_tab_data.panel = self.gang_panel
    self.tab_op_data[kOpIndex.GangRankTab] = gang_rank_btn_tab_data

    local dynasty_rank_btn_tab_data = {}
    local dynasty_rank_btn = rank_btn_list:FindChild("DynastyRank")
    dynasty_rank_btn:FindChild("Text"):GetComponent("Text").text = "王朝"
    local dynasty_select = dynasty_rank_btn:FindChild("Select")
    dynasty_rank_btn_tab_data.select = dynasty_select
    dynasty_select:FindChild("Text"):GetComponent("Text").text = "王朝"
    self:AddClick(dynasty_rank_btn, function ()
        SpecMgrs.msg_mgr:SendGetDynastyCrossRank({}, function (resp)
            print("王朝返回---",resp)
            --self:InitDynastyRankList(resp)
        end)
        self:UpdateTabPanel(kOpIndex.DynastyRankTab)
    end)
    dynasty_rank_btn_tab_data.panel = self.dynasty_panel
    self.tab_op_data[kOpIndex.DynastyRankTab] = dynasty_rank_btn_tab_data
end

function RankMainUI:InitUI()
    print("排行榜排行榜排行榜----InitUI-----")
    self:InitTopBar()
    --self.tween:SetActive(true)
    --self.power_unit = self:AddHalfUnit(self.power_unit_id, self.power_lover_model)
    --self.levels_unit = self:AddHalfUnit(self.levels_unit_id, self.levels_lover_model)
    --self.gang_unit = self:AddHalfUnit(self.gang_unit_id, self.gang_lover_model)
    --self.power_item_rank_id.text = "1st"
    --self.power_item_rank_name.text = "会飞的猪"
    --self.power_item_rank_score.text = "99999999999999"

    --self.levels_item_rank_id.text = "2st"
    --self.levels_item_rank_name.text = "会走的鱼"
    --self.levels_item_rank_score.text = "888888888888"

    --self.gang_item_rank_id.text = "3st"
    --self.gang_item_rank_name.text =  "会游的猴"
    --self.gang_item_rank_score.text = "777777777777777"
end

function RankMainUI:InitPowerRankList(resp)
    print("排行榜排行榜排行榜----InitPowerRankList-----")
    --print("谁先走1111-----")
    self:ClearRes()
    self:ClearUnit("power_unit")

    for rank, rank_info in ipairs(resp.rank_list) do
        local unit_id = SpecMgrs.data_mgr:GetRoleLookData(rank_info.role_id).unit_id
        if rank == 1 then
            --print("英雄Id --",unit_id)
            self.power_unit = self:AddFullUnit(unit_id, self.power_lover_model)
            self.power_name:GetComponent("Text").text = rank_info.name
            self.power_score:GetComponent("Text").text = rank_info.rank_score
            --self.info_name:GetComponent("Text").text = rank_info.name
            --self.info_score:GetComponent("Text").text = rank_info.rank_score
        else
            local rank_item = self:GetUIObject(self.power_item , self.power_task_list)
            --table.insert(self.main_rank_item_list, rank_item)
            local role_icon = rank_item:FindChild("Reward/IconBg/Icon"):GetComponent("Image")
            rank_item:FindChild("Reward/Text"):GetComponent("Text").text = rank
            rank_item:FindChild("Reward/Server"):GetComponent("Text").text = rank_info.server_id .. "服"
            rank_item:FindChild("Reward/Name"):GetComponent("Text").text = rank_info.name
            rank_item:FindChild("Reward/Score"):GetComponent("Text").text = rank_info.rank_score
            UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetUnitData(unit_id).icon, role_icon)
            --print("232323---",rank)
            --print("345353---",rank_info)
            --if rank< 9 then
            --    local tween_rank = self.tween:FindChild("RankItemList"..rank)
            --    tween_rank:SetActive(true)
            --    local role_icon = tween_rank:FindChild("ItemList/IconBg/Icon"):GetComponent("Image")
            --    tween_rank:FindChild("ItemList/Text"):GetComponent("Text").text = rank
            --    tween_rank:FindChild("ItemList/Server"):GetComponent("Text").text = rank_info.server_id .. "服"
            --    tween_rank:FindChild("ItemList/Name"):GetComponent("Text").text = rank_info.name
            --    tween_rank:FindChild("ItemList/Score"):GetComponent("Text").text = rank_info.rank_score
            --    UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetUnitData(unit_id).icon, role_icon)
            --end
        end
    end

    self.rank:GetComponent("Text").text = "排名"
    self.player:GetComponent("Text").text = "玩家"
    self.score:GetComponent("Text").text = "战力"
    self.server:GetComponent("Text").text = "服务器"

    --个人排行榜，暂无需求，先注掉
    --local my_rank = resp.self_rank
    --for rank, rank_info in ipairs(resp.rank_list) do
    --    if my_rank == rank then
    --        local unit_id = SpecMgrs.data_mgr:GetRoleLookData(rank_info.role_id).unit_id
    --        local role_icon = self.my_rank:FindChild("IconBg/Icon"):GetComponent("Image")
    --        self.my_rank:FindChild("Text"):GetComponent("Text").text = my_rank
    --        self.my_rank:FindChild("Server"):GetComponent("Text").text = rank_info.server_id
    --        self.my_rank:FindChild("Name"):GetComponent("Text").text = rank_info.name
    --        self.my_rank:FindChild("Score"):GetComponent("Text").text = rank_info.rank_score
    --        UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetUnitData(unit_id).icon, role_icon)
    --    end
    --end
    --print("我的排名--",my_rank)

    self.power_task_list:SetActive(true)
    self.power_info_panel:SetActive(true)
    --self.tween:SetActive(true)
    --self.info_panel_tween:SetActive(true)

    --coroutine.start(function ()
    --    coroutine.wait(1)
    --    self.tween:SetActive(false)
    --    self.info_panel_tween:SetActive(false)
    --    for rank, rank_info in ipairs(resp.rank_list) do
    --        local tween_rank = self.tween:FindChild("RankItemList"..rank)
    --        tween_rank:SetActive(false)
    --    end
    --    self.power_task_list:SetActive(true)
    --    self.power_info_panel:SetActive(true)
    --end)

end

function RankMainUI:InitLevelsRankList(resp)
    self:ClearRes()
    self:ClearUnit("levels_unit")
    for rank, rank_info in ipairs(resp.rank_list) do
        local unit_id = SpecMgrs.data_mgr:GetRoleLookData(rank_info.role_id).unit_id
        if rank == 1 then
            print("英雄Id22 --",unit_id)
            self.levels_unit = self:AddFullUnit(unit_id, self.levels_lover_model)
            self.levels_name:GetComponent("Text").text = rank_info.name
            self.levels_score:GetComponent("Text").text = rank_info.rank_score
            --self.info_name:GetComponent("Text").text = rank_info.name
            --self.info_score:GetComponent("Text").text = rank_info.rank_score
        else
            local rank_item = self:GetUIObject(self.levels_item , self.levels_task_list)
            --table.insert(self.main_rank_item_list, rank_item)
            local role_icon = rank_item:FindChild("Reward/IconBg/Icon"):GetComponent("Image")
            rank_item:FindChild("Reward/Text"):GetComponent("Text").text = rank
            rank_item:FindChild("Reward/Server"):GetComponent("Text").text = rank_info.server_id .. "服"
            rank_item:FindChild("Reward/Name"):GetComponent("Text").text = rank_info.name
            rank_item:FindChild("Reward/Score"):GetComponent("Text").text = rank_info.rank_score
            UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetUnitData(unit_id).icon, role_icon)
            --print("232323---",rank)
            --print("345353---",rank_info)
            --if rank< 9 then
            --    local tween_rank = self.tween:FindChild("RankItemList"..rank)
            --    tween_rank:SetActive(true)
            --    local role_icon = tween_rank:FindChild("ItemList/IconBg/Icon"):GetComponent("Image")
            --    tween_rank:FindChild("ItemList/Text"):GetComponent("Text").text = rank
            --    tween_rank:FindChild("ItemList/Server"):GetComponent("Text").text = rank_info.server_id .. "服"
            --    tween_rank:FindChild("ItemList/Name"):GetComponent("Text").text = rank_info.name
            --    tween_rank:FindChild("ItemList/Score"):GetComponent("Text").text = rank_info.rank_score
            --    UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetUnitData(unit_id).icon, role_icon)
            --end
        end
    end

    self.rank:GetComponent("Text").text = "排名"
    self.player:GetComponent("Text").text = "玩家"
    self.score:GetComponent("Text").text = "星数"
    self.server:GetComponent("Text").text = "服务器"

    self.levels_task_list:SetActive(true)
    self.levels_info_panel:SetActive(true)
    --self.tween:SetActive(true)
    --self.info_panel_tween:SetActive(true)

    --coroutine.start(function ()
    --    coroutine.wait(1)
    --    self.tween:SetActive(false)
    --    --self.info_panel_tween:SetActive(false)
    --    for rank, rank_info in ipairs(resp.rank_list) do
    --        local tween_rank = self.tween:FindChild("RankItemList"..rank)
    --        tween_rank:SetActive(false)
    --    end
    --    self.levels_task_list:SetActive(true)
    --    self.levels_info_panel:SetActive(true)
    --end)

end

function RankMainUI:InitGangRankList(resp)
    print("排行榜排行榜排行榜----InitGangRankList-----")
    self:ClearRes()
    self:ClearUnit("gang_unit")

    for rank, rank_info in ipairs(resp.rank_list) do
        local unit_id = SpecMgrs.data_mgr:GetRoleLookData(rank_info.role_id).unit_id
        if rank == 1 then
            self.gang_unit = self:AddFullUnit(unit_id, self.gang_lover_model)
            self.gang_name:GetComponent("Text").text = rank_info.name
            self.gang_score:GetComponent("Text").text = rank_info.rank_score
            --self.info_name:GetComponent("Text").text = rank_info.name
            --self.info_score:GetComponent("Text").text = rank_info.rank_score
        else
            local rank_item = self:GetUIObject(self.gang_item , self.gang_task_list)
            --table.insert(self.main_rank_item_list, rank_item)
            local role_icon = rank_item:FindChild("Reward/IconBg/Icon"):GetComponent("Image")
            rank_item:FindChild("Reward/Text"):GetComponent("Text").text = rank
            rank_item:FindChild("Reward/Server"):GetComponent("Text").text = rank_info.server_id .. "服"
            rank_item:FindChild("Reward/Name"):GetComponent("Text").text = rank_info.name
            rank_item:FindChild("Reward/Score"):GetComponent("Text").text = rank_info.rank_score
            UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetUnitData(unit_id).icon, role_icon)
            --print("232323---",rank)
            --print("345353---",rank_info)
            --if rank< 9 then
            --    local tween_rank = self.tween:FindChild("RankItemList"..rank)
            --    tween_rank:SetActive(true)
            --    local role_icon = tween_rank:FindChild("ItemList/IconBg/Icon"):GetComponent("Image")
            --    tween_rank:FindChild("ItemList/Text"):GetComponent("Text").text = rank
            --    tween_rank:FindChild("ItemList/Server"):GetComponent("Text").text = rank_info.server_id .. "服"
            --    tween_rank:FindChild("ItemList/Name"):GetComponent("Text").text = rank_info.name
            --    tween_rank:FindChild("ItemList/Score"):GetComponent("Text").text = rank_info.rank_score
            --    UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetUnitData(unit_id).icon, role_icon)
            --end
        end
    end

    self.rank:GetComponent("Text").text = "排名"
    self.player:GetComponent("Text").text = "玩家"
    self.score:GetComponent("Text").text = "战力"
    self.server:GetComponent("Text").text = "服务器"

    self.gang_task_list:SetActive(true)
    self.gang_info_panel:SetActive(true)
    --self.tween:SetActive(true)
    --self.info_panel_tween:SetActive(true)

    --coroutine.start(function ()
    --    coroutine.wait(1)
    --    self.tween:SetActive(false)
    --    for rank, rank_info in ipairs(resp.rank_list) do
    --        local tween_rank = self.tween:FindChild("RankItemList"..rank)
    --        tween_rank:SetActive(false)
    --    end
    --    --self.info_panel_tween:SetActive(false)
    --    self.gang_task_list:SetActive(true)
    --    self.gang_info_panel:SetActive(true)
    --end)

end

function RankMainUI:InitDynastyRankList(resp)
    print("排行榜排行榜排行榜----InitGangRankList-----")
    self:ClearRes()
    self:ClearUnit("dynasty_unit")

    for rank, rank_info in ipairs(resp.rank_list) do
        local unit_id = SpecMgrs.data_mgr:GetRoleLookData(rank_info.role_id).unit_id
        if rank == 1 then
            self.dynasty_unit = self:AddFullUnit(unit_id, self.dynasty_lover_model)
            self.dynasty_name:GetComponent("Text").text = rank_info.name
            self.dynasty_score:GetComponent("Text").text = rank_info.rank_score
            --self.info_name:GetComponent("Text").text = rank_info.name
            --self.info_score:GetComponent("Text").text = rank_info.rank_score
        else
            local rank_item = self:GetUIObject(self.dynasty_item , self.dynasty_task_list)
            --table.insert(self.main_rank_item_list, rank_item)
            local role_icon = rank_item:FindChild("Reward/IconBg/Icon"):GetComponent("Image")
            rank_item:FindChild("Reward/Text"):GetComponent("Text").text = rank
            rank_item:FindChild("Reward/Server"):GetComponent("Text").text = rank_info.server_id .. "服"
            rank_item:FindChild("Reward/Name"):GetComponent("Text").text = rank_info.name
            rank_item:FindChild("Reward/Score"):GetComponent("Text").text = rank_info.rank_score
            UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetUnitData(unit_id).icon, role_icon)
            --print("232323---",rank)
            --print("345353---",rank_info)
            --if rank< 9 then
            --    local tween_rank = self.tween:FindChild("RankItemList"..rank)
            --    tween_rank:SetActive(true)
            --    local role_icon = tween_rank:FindChild("ItemList/IconBg/Icon"):GetComponent("Image")
            --    tween_rank:FindChild("ItemList/Text"):GetComponent("Text").text = rank
            --    tween_rank:FindChild("ItemList/Server"):GetComponent("Text").text = rank_info.server_id .. "服"
            --    tween_rank:FindChild("ItemList/Name"):GetComponent("Text").text = rank_info.name
            --    tween_rank:FindChild("ItemList/Score"):GetComponent("Text").text = rank_info.rank_score
            --    UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetUnitData(unit_id).icon, role_icon)
            --end
        end
    end

    self.rank:GetComponent("Text").text = "排名"
    self.player:GetComponent("Text").text = "王朝"
    self.score:GetComponent("Text").text = "战力"
    self.server:GetComponent("Text").text = "服务器"

    self.dynasty_task_list:SetActive(true)
    self.dynasty_info_panel:SetActive(true)
    --self.tween:SetActive(true)
    --self.info_panel_tween:SetActive(true)

    --coroutine.start(function ()
    --    coroutine.wait(1)
    --    self.tween:SetActive(false)
    --    for rank, rank_info in ipairs(resp.rank_list) do
    --        local tween_rank = self.tween:FindChild("RankItemList"..rank)
    --        tween_rank:SetActive(false)
    --    end
    --    --self.info_panel_tween:SetActive(false)
    --    self.dynasty_task_list:SetActive(true)
    --    self.dynasty_info_panel:SetActive(true)
    --end)

end

function RankMainUI:UpdateTabPanel(op_index)
    if self.cur_op_index == op_index then return end
    self:CloseCurTabPanel()
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
    if self.dynasty_unit then
        self:RemoveUnit(self.dynasty_unit)
        self.dynasty_unit = nil
    end
end

function RankMainUI:ClearRes()
    self:DelAllCreateUIObj()
end

function RankMainUI:ClearRankItem()
    --for i = 0 , #self.main_rank_item_list do
    --    self:DelUIObject(table.remove(self.main_rank_item_list,i + 1))
    --end
end

return RankMainUI