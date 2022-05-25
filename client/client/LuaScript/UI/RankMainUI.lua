local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local RankMainUI = class("UI.RankMainUI", UIBase)

function RankMainUI:DoInit()
    RankMainUI.super.DoInit(self)
    self.prefab_path = "UI/Common/RankMainUI"

    self.dy_friend_data = ComMgrs.dy_data_mgr.friend_data
    self.rank_item_info_list = {}
    self.rank_tab_data_dict = {}
    self.rank_item_list = {}
    self.rank_btn_dict = {}
end

function RankMainUI:OnGoLoadedOk(res_go)
    print("排行榜排行榜排行榜----OnGoLoadedOk-----",res_go)
    RankMainUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function RankMainUI:Hide()
    RankMainUI.super.Hide(self)
    self.cur_Rank_type = nil
    self:ClearRes()
    self:ClearUnitModel()
end

function RankMainUI:Show()
    print("排行榜排行榜排行榜----Show-----")
    if self.is_res_ok then
        self:InitUI()
    end
    RankMainUI.super.Show(self)
end

function RankMainUI:Update(delta_time)

end


function RankMainUI:InitRes()
    print("排行榜排行榜排行榜----InitRes-----")
    self.tab_btn_list = self.main_panel:FindChild("TabPanel/View/Content")
    self.tab_item = self.tab_btn_list:FindChild("RankItemList")
    self.rank_main_panel = self.main_panel:FindChild("RankMainFrame")

    --通用排行榜
    self.rank_common_panel = self.rank_main_panel:FindChild("RankCommonPanel")
    self.rank_common_info_panel = self.rank_common_panel:FindChild("InfoPanel")
    self.rank_common_lover_model = self.rank_common_info_panel:FindChild("LoverModel")
    self.rank_common_name = self.rank_common_info_panel:FindChild("Content/Name")
    self.rank_common_score = self.rank_common_info_panel:FindChild("Score/Text")
    self.rank_common_sever_name = self.rank_common_info_panel:FindChild("SeverName/Text")
    self.rank_common_fir_play_info = self.rank_common_info_panel:FindChild("FirPlayInfo")

    self.rank_common_task_list = self.rank_common_panel:FindChild("TaskList/View/Content")
    self.rank_common_item = self.rank_common_task_list:FindChild("TaskItem")

    self.my_rank = self.rank_common_panel:FindChild("MyRank")
    self.my_rank_name = self.my_rank:FindChild("MyRankName"):GetComponent("Text")
    self.my_rank_score = self.my_rank:FindChild("MyRankScore"):GetComponent("Text")
    self.my_rank_name.text = UIConst.Text.MY_RANK


    self.title = self.main_panel:FindChild("Title")
    self.rank = self.title:FindChild("Rank/Text")
    self.player = self.title:FindChild("Player/Text")
    self.score = self.title:FindChild("Score/Text")
    self.server = self.title:FindChild("Server/Text")

    self.no_rank = self.main_panel:FindChild("NoRank")
    self.no_rank_text = self.no_rank:FindChild("Text"):GetComponent("Text")
    self.no_rank_text.text = UIConst.Text.NO_ONE_ON_RANK
    --总战力排行榜
    self.power_panel = self.rank_main_panel:FindChild("PowerPanel")
    self.power_info_panel = self.power_panel:FindChild("InfoPanel")
    self.power_lover_model = self.power_info_panel:FindChild("LoverModel")
    self.power_name = self.power_info_panel:FindChild("Content/Name")
    self.power_score = self.power_info_panel:FindChild("Score/Text")
    --self.my_rank = self.power_panel:FindChild("MyRank")
    --排行榜点赞
    self.tags = self.power_info_panel:FindChild("Tags")

    --动画效果
    --self.tween = self.rank_main_panel:FindChild("Tween")
    --self.info_panel_tween = self.rank_main_panel:FindChild("InfoPanelTween")
    --self.info_name = self.info_panel_tween:FindChild("Content/Name")
    --self.info_score = self.info_panel_tween:FindChild("Score/Text")

end

function RankMainUI:InitUI()
    print("排行榜排行榜排行榜----InitUI-----")
    self:InitTopBar()
    self:InitTabBtn()
end

--  生成顶部条按钮列表
function RankMainUI:InitTabBtn()
    --self.red_point_list = {}
    --self:ClearRankTabBtn()
    local total_rank_data_list = SpecMgrs.data_mgr:GetAllTotalRankData()
    for i, group_id in ipairs (total_rank_data_list) do
        if group_id.all_show == true then
            table.insert(self.rank_item_info_list, group_id)
        end
    end
    print("展示排行榜数据--------------",self.rank_item_info_list)
    for i, rank_info in ipairs (self.rank_item_info_list) do
        local rank_tab_btn = self:GetUIObject(self.tab_item, self.tab_btn_list)
        self.rank_tab_data_dict[i] = {
                btn = rank_tab_btn,
                --init_func = self[self.show_frame_func[activity_data.type]],
                --hide_func = self[self.hide_frame_func[activity_data.type]],
                --update_func = self[self.update_frame_func[activity_data.type]],
                data = rank_info,
        }
        self.rank_btn_dict[i] = rank_tab_btn
        rank_tab_btn:FindChild("Text"):GetComponent("Text").text = rank_info.name
        rank_tab_btn:FindChild("Select/Text"):GetComponent("Text").text = rank_info.name
        rank_tab_btn:FindChild("Select"):SetActive(false)
        if self.cur_Rank_type then

        end
        self:AddClick(rank_tab_btn, function ()
            print("点击排行榜事件===========",rank_info.id)
            --self:UpdateActivity(rank_info.id)
            self.rank_tab_data_dict[self.cur_Rank_type].btn:FindChild("Select"):SetActive(false)
            rank_tab_btn:FindChild("Select"):SetActive(true)

            if self.cur_Rank_type ~= i then
                print("相同button点击事件不进行触发排行榜==================",i)
                self.cur_Rank_type = i
                self:InitBtnClickMsg(rank_info)
            end

        end)
        if i == 1 then
            print("点击排行榜事件111111===========",rank_info)
            self.cur_Rank_type = i
            rank_tab_btn:FindChild("Select"):SetActive(true)
            self:InitBtnClickMsg(rank_info)
        end
    end
end

--点击页签走的协议，因为服务器分开写了，没办法了以后增加就在这个基础上加吧
function RankMainUI:InitBtnClickMsg(rank_info)
    SpecMgrs.ui_mgr:ShowLoadingUI();
    if rank_info.id == 15 then
        SpecMgrs.msg_mgr:SendGetPowerRank({}, function (resp)
            SpecMgrs.ui_mgr:HideUI("LoadingUI")
            if resp.errcode == 1 then
                SpecMgrs.ui_mgr:ShowMsgBox("页面刷新失败！")
            else
                print("id == 15排行数据---",resp)
                self:UpdateRankList(resp,rank_info)
            end
        end)
    elseif rank_info.id == 16 then
        SpecMgrs.msg_mgr:SendGetGangRank({}, function (resp)
            SpecMgrs.ui_mgr:HideUI("LoadingUI")
            if resp.errcode == 1 then
                SpecMgrs.ui_mgr:ShowMsgBox("页面刷新失败！")
            else
                print("id == 16排行数据---",resp)
                self:UpdateRankList(resp,rank_info)
            end
        end)
    elseif rank_info.id == 17 then
        SpecMgrs.msg_mgr:SendGetLevelsRank({}, function (resp)
            SpecMgrs.ui_mgr:HideUI("LoadingUI")
            if resp.errcode == 1 then
                SpecMgrs.ui_mgr:ShowMsgBox("页面刷新失败！")
            else
                print("id == 17排行数据---",resp)
                self:UpdateRankList(resp,rank_info)
            end
        end)
    elseif rank_info.id == 18 then
        SpecMgrs.msg_mgr:SendGetCrossFeatsRank({}, function (resp)
            SpecMgrs.ui_mgr:HideUI("LoadingUI")
            if resp.errcode == 1 then
                SpecMgrs.ui_mgr:ShowMsgBox("页面刷新失败！")
            else
                print("id == 18排行数据---",resp)
                self:UpdateRankList(resp,rank_info)
            end
        end)
    elseif rank_info.id == 19 then
        SpecMgrs.msg_mgr:SendGetCrossMaxHurtRank({}, function (resp)
            SpecMgrs.ui_mgr:HideUI("LoadingUI")
            if resp.errcode == 1 then
                SpecMgrs.ui_mgr:ShowMsgBox("页面刷新失败！")
            else
                print("id == 19排行数据---",resp)
                self:UpdateRankList(resp,rank_info)
            end
        end)
    elseif rank_info.id == 20 then
        SpecMgrs.msg_mgr:SendGetCrossHuntPointRank({}, function (resp)
            SpecMgrs.ui_mgr:HideUI("LoadingUI")
            if resp.errcode == 1 then
                SpecMgrs.ui_mgr:ShowMsgBox("页面刷新失败！")
            else
                print("id == 20排行数据---",resp)
                self:UpdateRankList(resp,rank_info)
            end
        end)
    elseif rank_info.id == 21 then
        SpecMgrs.msg_mgr:SendGetTrialCrossRank({}, function (resp)
            SpecMgrs.ui_mgr:HideUI("LoadingUI")
            if resp.errcode == 1 then
                SpecMgrs.ui_mgr:ShowMsgBox("页面刷新失败！")
            else
                print("id == 21排行数据---",resp)
                self:UpdateRankList(resp,rank_info)
            end
        end)
    end
end

--更新排行榜信息列表
function RankMainUI:UpdateRankList(resp,rank_item_info)
    self:ClearUnit("rank_common_unit")
    self:ClearRankItem()
    if #resp.rank_list ~= 0 then
        self.rank_main_panel:SetActive(true)
        self.title:SetActive(true)
        self.no_rank:SetActive(false)
        for rank, rank_info in ipairs(resp.rank_list) do
            local unit_id = SpecMgrs.data_mgr:GetRoleLookData(rank_info.role_id).unit_id
            local self_uuid
            print("发放及阿里放假啊六块腹肌啊立刻就发了--",resp)
            if resp.self_rank == rank then
                self_uuid = rank_info.uuid
            end
            if rank == 1 then
                print("英雄Id22 --",unit_id)
                self.rank_common_unit = self:AddFullUnit(unit_id, self.rank_common_lover_model)
                self.rank_common_name:GetComponent("Text").text = rank_info.name
                self.rank_common_score:GetComponent("Text").text = rank_info.rank_score
                self.rank_common_sever_name:GetComponent("Text").text = UIFuncs.GetServerName(rank_info.server_id)
                self:AddClick(self.rank_common_fir_play_info, function ()
                    print("第一名玩家信息",self_uuid)
                    if rank_info.uuid == self_uuid then return end
                    self.dy_friend_data:ShowPlayerInfo(rank_info.uuid)
                end)
            else
                local rank_item = self:GetUIObject(self.rank_common_item , self.rank_common_task_list)
                table.insert(self.rank_item_list, rank_item)
                print("数据信息哈哈哈哈哈哈=====",rank_info.uuid)
                local role_icon_btn = rank_item:FindChild("Reward/IconBg")
                local role_icon = rank_item:FindChild("Reward/IconBg/Icon"):GetComponent("Image")
                local rank_text_icon = rank_item:FindChild("Reward/RankText")
                rank_text_icon:SetActive(false)

                self:AddClick(role_icon_btn, function ()
                    print("当前角色ID=======",rank_info.uuid)
                    if rank_info.uuid == self_uuid then return end
                    self.dy_friend_data:ShowPlayerInfo(rank_info.uuid)
                end)
                if rank == 2 then
                    rank_text_icon:SetActive(true)
                    rank_item:FindChild("Reward/Text"):SetActive(false)
                    UIFuncs.AssignUISpriteSync("UIRes/Hunting/sl_phb02", "sl_phb02", rank_text_icon:GetComponent("Image"))
                elseif rank == 3 then
                    rank_text_icon:SetActive(true)
                    rank_item:FindChild("Reward/Text"):SetActive(false)
                    UIFuncs.AssignUISpriteSync("UIRes/Hunting/sl_phb03", "sl_phb03", rank_text_icon:GetComponent("Image"))
                else
                    rank_item:FindChild("Reward/Text"):SetActive(true)
                    rank_item:FindChild("Reward/Text"):GetComponent("Text").text = rank
                end

                rank_item:FindChild("Reward/Server"):GetComponent("Text").text = UIFuncs.GetServerName(rank_info.server_id)
                rank_item:FindChild("Reward/Name"):GetComponent("Text").text = rank_info.name
                rank_item:FindChild("Reward/Score"):GetComponent("Text").text = rank_info.rank_score
                UIFuncs.AssignSpriteByIconID(SpecMgrs.data_mgr:GetUnitData(unit_id).icon, role_icon)
            end
        end
        self.rank:GetComponent("Text").text = UIConst.Text.RANK_TEXT
        self.player:GetComponent("Text").text = UIConst.Text.PLAYER_TEXT
        self.score:GetComponent("Text").text = rank_item_info.rank_gist_name
        self.server:GetComponent("Text").text = UIConst.Text.PLAYER_SERVER_TEXT

        self.rank_common_task_list:SetActive(true)
        self.rank_common_info_panel:SetActive(true)
        --个人排行榜，暂无需求，先注掉
        print("个人排行榜=====",resp.self_rank)
        if resp.self_rank ~= nil then
            self.my_rank_score.text  = resp.self_rank
        else
            self.my_rank_score.text  = UIConst.Text.NOT_ON_RANKING
        end
    else
        self.rank_main_panel:SetActive(false)
        self.title:SetActive(false)
        self.no_rank:SetActive(true)
    end

end

function RankMainUI:ClearUnitModel()
    if self.rank_common_unit then
        self:RemoveUnit(self.rank_common_unit)
        self.rank_common_unit = nil
    end
end

function RankMainUI:ClearRes()
    self:DelAllCreateUIObj()
    self:ClearRankTabBtn()
end

function RankMainUI:ClearRankItem()
    for _, item in ipairs(self.rank_item_list) do
        self:DelUIObject(item)
    end
    self.rank_item_list = {}
end

function RankMainUI:ClearRankTabBtn()
    for _, item in pairs(self.rank_btn_dict) do
        self:DelUIObject(item)
    end
    self.rank_btn_dict = {}

    for _, item in pairs(self.rank_tab_data_dict) do
        self:DelUIObject(item)
    end
    self.rank_tab_data_dict = {}

    for _, item in pairs(self.rank_item_info_list) do
        self:DelUIObject(item)
    end
    self.rank_item_info_list = {}
end

return RankMainUI