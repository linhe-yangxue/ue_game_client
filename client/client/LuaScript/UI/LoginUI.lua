local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UnitConst = require("Unit.UnitConst")
local GConst = require("GlobalConst")
local LoginUI = class("UI.LoginUI", UIBase)

LoginUI.need_sync_load = true
local kRecommendServer = 55 -- 推荐服务器

function LoginUI:DoInit()
    LoginUI.super.DoInit(self)
    self.prefab_path = "UI/Common/LoginUI"
    self.http = nil

    self.role_server_list = {}
    self.area_go_dict = {}
    self.partition_go_dict = {}
    self.server_go_dict = {}
    self.dy_server_data = ComMgrs.dy_data_mgr.server_data
end

function LoginUI:OnGoLoadedOk(res_go)
    LoginUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function LoginUI:Hide()
    self.is_sdk_login = nil
    LoginUI.super.Hide(self)
end

function LoginUI:Show(is_sdk_login)
    self.is_sdk_login = is_sdk_login
    if self.is_res_ok then
        self:InitUI()
    end
    LoginUI.super.Show(self)
end

function LoginUI:InitRes()
    self.content_panel = self.main_panel:FindChild("Content")
    -- 进入面板
    local enter_panel = self.content_panel:FindChild("EnterPanel")
    self.logo = enter_panel:FindChild("Logo")
    self:AddClick(enter_panel:FindChild("HelpBtn"), function ()
        -- TODO 帮助
    end)
    self:AddClick(enter_panel:FindChild("AccountBtn"), function ()
        self.login_btn:GetComponent("Button").interactable = true
        self.input_account.text = self.cur_account
        self.account_panel:SetActive(true)
    end)

    self.cur_server_panel = enter_panel:FindChild("CurServerPanel/Bg")
    self.server_state_text = self.cur_server_panel:FindChild("ServerStateText"):GetComponent("Text")
    self.server_name = self.cur_server_panel:FindChild("ServerName"):GetComponent("Text")
    local change_server_btn = self.cur_server_panel:FindChild("ChangeServerBtn")
    change_server_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CHANGE_SERVER
    self:AddClick(change_server_btn, function ()
        self:InitServerPanel()
        --self.select_server_panel:SetActive(true)
        self.notice_panel:SetActive(true)
    end)
    self.game_start_btn = enter_panel:FindChild("GameStartBtn")
    self.game_start_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.START_GAME
    self:AddClick(self.game_start_btn, function ()
        PlayerPrefs.SetInt("SELECT_SERVER_ID", self.select_server_id)
        self:ConnectServer()
    end)

    self.notice_panel = self.content_panel:FindChild("NoticePanel")
    local notice_content = self.notice_panel:FindChild("Content")
    notice_content:FindChild("Top/Text"):GetComponent("Text").text = "公告"
    --self:AddClick(select_server_content:FindChild("Top/CloseBtn"), function ()
    --    self.notice_panel:SetActive(false)
    --end)
    -- 公告内容
    local all_notice_panel = notice_content:FindChild("AllServerPanel")
    self.area_content = all_notice_panel:FindChild("SelectArea/View/Content")
    self.area_pref1 = self.area_content:FindChild("AreaPref")
    self.area_pref2 = self.area_pref1:FindChild("AreaName")
    self.area_pref2:GetComponent("Text").text = "抵制不良游戏, 拒绝盗版游戏。 注意自我保护, 谨防受骗上当。 适度游戏益脑, 沉迷游戏伤身。 合理安排时间, 享受健康生活。"

    --self.partition_list_content = all_notice_panel:FindChild("PartitionList/View/Content")
    --self.partition_pref = self.partition_list_content:FindChild("PartitionPref")
    --self.server_list_content = all_notice_panel:FindChild("ServerList/View/Content")
    --self.server_pref = self.server_list_content:FindChild("ServerPref")

    self.confirm_btn = notice_content:FindChild("ConfirmBtn")
    self.confirm_btn:FindChild("Text"):GetComponent("Text").text = "确认"
    self:AddClick(self.confirm_btn, function ()
        print("确认游戏-----")
        self.notice_panel:SetActive(false)
    end)

    -- 服务器选择面板
    self.select_server_panel = self.content_panel:FindChild("ServerPanel")
    local select_server_content = self.select_server_panel:FindChild("Content")
    select_server_content:FindChild("Top/Text"):GetComponent("Text").text = UIConst.Text.SELECT_SERVER
    self:AddClick(select_server_content:FindChild("Top/CloseBtn"), function ()
        self.select_server_panel:SetActive(false)
    end)
    -- 已有角色服务器
    self.role_server_content = select_server_content:FindChild("RoleServerList/View/Content")
    self.role_server_pref = self.role_server_content:FindChild("ServerPref")
    -- 所有服务器
    local all_server_panel = select_server_content:FindChild("AllServerPanel")
    self.area_content = all_server_panel:FindChild("SelectArea/View/Content")
    self.area_pref = self.area_content:FindChild("AreaPref")
    self.partition_list_content = all_server_panel:FindChild("PartitionList/View/Content")
    self.partition_pref = self.partition_list_content:FindChild("PartitionPref")
    self.server_list_content = all_server_panel:FindChild("ServerList/View/Content")
    self.server_pref = self.server_list_content:FindChild("ServerPref")
    -- 账号面板
    self.account_panel = self.content_panel:FindChild("AccountPanel")
    local account_content = self.account_panel:FindChild("Content")
    account_content:FindChild("Title"):GetComponent("Text").text = UIConst.Text.SWITCH_ACCOUNT_TEXT
    account_content:FindChild("Account"):GetComponent("Text").text = UIConst.Text.ACCOUNT
    self.input_account = account_content:FindChild("AccountInput"):GetComponent("InputField")
    self.login_btn = account_content:FindChild("LoginBtn")
    self.login_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.LOGIN
    self:AddClick(account_content:FindChild("CloseBtn"), function ()
        self.account_panel:SetActive(false)
    end)
    self:AddClick(self.login_btn, function ()
        self.cur_account = self.input_account.text
        PlayerPrefs.SetString("LOGIN_ACCOUNT", self.cur_account)
        if not self.cur_account or self.cur_account == "" then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.AccountNull)
        else
            self.login_btn:GetComponent("Button").interactable = false
            self:HttpRequire()
            self.account_panel:SetActive(false)
        end
    end)

    self.black_bg = self.main_panel:FindChild("BlackBg")
end

function LoginUI:InitUI()
    print("account_info---------",self)
    local account_info = self.is_sdk_login and self.dy_data_mgr:ExGetAccountInfo()
    self.black_bg:SetActive(self.is_sdk_login and not account_info)
    print("account_info",PlayerPrefs.GetString("LOGIN_ACCOUNT", ""))
    local account = account_info and account_info.username or PlayerPrefs.GetString("LOGIN_ACCOUNT", "")
    print("account",account)
    if account == "" then
        print("self.cur_account",self.cur_account)
        self.cur_account = math.random(1, 99999999)   --self.cur_account ..  
    end
    self.cur_account = account
    self.select_server_id = PlayerPrefs.GetInt("SELECT_SERVER_ID", 0)
    if self.select_server_id == 0 then
        -- 选择推荐服务器
        self.select_server_id = kRecommendServer
        PlayerPrefs.SetInt("SELECT_SERVER_ID", self.select_server_id)
    end
    self:ReFreshCurServerUI()
    if ComMgrs.dy_data_mgr.is_kick and ComMgrs.dy_data_mgr.is_relogin then
        ComMgrs.dy_data_mgr:ExSetKickOutStatus(false)
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.LoginKickText)
    end
    self:HttpRequire()
    --self.black_bg:SetActive(self.is_sdk_login)
end

function LoginUI:HttpRequire()
    SpecMgrs.http_mgr:Request(UIConst.LoginServerPath..self.cur_account, function(http)
        if http.isDone then
            self.server_role_info_list = {}
            if http.error then
                PrintError("---- http is error ----")
            else
                local role_info_list = json.decode(http.data)
                if role_info_list then
                    self.server_role_info_list = role_info_list
                end
            end
            self.http = nil
        end
    end)
end

function LoginUI:ConnectServer()
    print("点击登陆")
    self.game_start_btn:GetComponent("Button").interactable = false
    local confirm_cb = function ()
        SpecMgrs.msg_mgr:SendLogin({urs = self.cur_account, relogin = true}, function (resp)
            if resp.errcode ~= 0 then
                SpecMgrs.ui_mgr:ShowMsgBox(resp.errcode)
            else
                SpecMgrs.stage_mgr:GotoStage("MainStage")
            end
        end)
    end
    local cancel_cb = function ()
        self.input_account.text = self.cur_account
        self.account_panel:SetActive(true)
        self.game_start_btn:GetComponent("Button").interactable = true
    end
    local server_info = self.dy_server_data:GetServerById(self.select_server_id)
    PlayerPrefs.SetString("LOGIN_ACCOUNT", self.cur_account)
    SpecMgrs.msg_mgr:ConnectServer(server_info.ip, server_info.port, function (conn_flag)
        if not conn_flag then
            self.game_start_btn:GetComponent("Button").interactable = true
            return
        end
        SpecMgrs.msg_mgr:SendLogin({urs = self.cur_account}, function (resp)
            --PrintError("SendLogin resp", resp)
            if resp.errcode ~= 0 and not resp.replace then
                SpecMgrs.ui_mgr:ShowMsgBox(UIConst.LoginFailed)
                self.game_start_btn:GetComponent("Button").interactable = true
            end
            if resp.replace then
                local param_tb = {content = UIConst.LoginReplaceText, confirm_cb = confirm_cb, cancel_cb = cancel_cb, delay_time = 30}
                SpecMgrs.ui_mgr:ShowMsgSelectBox(param_tb)
            end
            ComMgrs.dy_data_mgr.urs = resp.urs
            ComMgrs.dy_data_mgr.token = resp.token
            if resp.errcode == 0 then
                ComMgrs.dy_data_mgr:ExSetServerId(self.select_server_id)
                if resp.no_role then
                    SpecMgrs.stage_mgr:GotoStage("CreateRoleStage")
                elseif resp.is_not_flag then
                    SpecMgrs.ui_mgr:ShowUI("SelectFlagUI", false)
                elseif resp.is_guide_not_end then
                    SpecMgrs.stage_mgr:GotoStage("GuideStage")
                else
                    SpecMgrs.stage_mgr:GotoStage("MainStage")
                end
            end
        end)
    end)
end

function LoginUI:ReFreshCurServerUI()
    self.server_name.text = self.dy_server_data:GetServerById(self.select_server_id).name
    -- TODO 服务器状态文字 self.server_state_text
end

function LoginUI:InitServerPanel()
    self:InitRoleServerPanel()
    self:UpdateArea()
end

-- 初始化已拥有角色的服务器列表
function LoginUI:InitRoleServerPanel()
    self:ClearRoleServerGo()
    if not self.server_role_info_list or #self.server_role_info_list == 0 then return end
    for _, role_server in ipairs(self.server_role_info_list) do
        local go = self:GetUIObject(self.role_server_pref, self.role_server_content)
        local server = self.dy_server_data:GetServerById(role_server.server_id)
        go:FindChild("ServerName"):GetComponent("Text").text = server.name
        go:FindChild("RoleInfo"):GetComponent("Text").text = string.format(UIConst.Text.ROLE_INFO, role_server.name, role_server.level)
        self:AddClick(go, function ()
            self:SubmitSelectServer(server.id)
        end)
        table.insert(self.role_server_list, go)
    end
end

function LoginUI:UpdateArea()
    self:ClearAreaGo()
    self.last_select_area = self.dy_server_data:GetServerAreaById(self.select_server_id)
    for _, area in ipairs(self.dy_server_data:GetAreaList()) do
        local area_go = self:GetUIObject(self.area_pref, self.area_content)
        area_go:FindChild("AreaName"):GetComponent("Text").text = area
        area_go:FindChild("Select/Name"):GetComponent("Text").text = area
        self:AddClick(area_go, function ()
            if self.last_select_area == area then return end
            self.area_go_dict[self.last_select_area]:FindChild("Select"):SetActive(false)
            self.last_select_area = area
            self.last_select_partition = self.dy_server_data:GetLatestPartition(area).id
            area_go:FindChild("Select"):SetActive(true)
            self:UpdatePartition()
        end)

        if area == self.last_select_area then
            area_go:FindChild("Select"):SetActive(true)
            self:UpdatePartition()
        end
        self.area_go_dict[area] = area_go
    end
end

function LoginUI:UpdatePartition()
    self:ClearPartitionGo()
    -- 切换洲默认选择最新的分区
    self.last_select_partition = self.last_select_partition or self.dy_server_data:GetServerById(self.select_server_id).partition
    for _, partition_data in ipairs(self.dy_server_data:GetPartitionList(self.last_select_area)) do
        local partition_go = self:GetUIObject(self.partition_pref, self.partition_list_content)
        partition_go:FindChild("PartitionName"):GetComponent("Text").text = partition_data.partition
        partition_go:FindChild("Select/Name"):GetComponent("Text").text = partition_data.partition
        self:AddClick(partition_go, function ()
            if self.last_select_partition == partition_data.id then return end
            self.partition_go_dict[self.last_select_partition]:FindChild("Select"):SetActive(false)
            self.last_select_partition = partition_data.id
            partition_go:FindChild("Select"):SetActive(true)
            self:UpdateServerItem()
        end)

        if self.last_select_partition == partition_data.id then
            partition_go:FindChild("Select"):SetActive(true)
            self:UpdateServerItem()
        end
        self.partition_go_dict[partition_data.id] = partition_go
    end
end

function LoginUI:UpdateServerItem()
    self:ClearServerGo()
    for _, server in ipairs(self.dy_server_data:GetServerList(self.last_select_partition)) do
        local server_go = self:GetUIObject(self.server_pref, self.server_list_content)
        -- TODO 判断服务器状态显示对应的图标文字和改变名字的颜色
        -- server_go:FindChild("ServerState/Empty"):SetActive(server.state == CSConst.SeverState.Empty)
        -- server_go:FindChild("ServerState/Normal"):SetActive(server.state == CSConst.SeverState.Normal)
        -- server_go:FindChild("ServerState/Full"):SetActive(server.state == CSConst.SeverState.Full)
        server_go:FindChild("ServerName"):GetComponent("Text").text = string.format(UIConst.Text.EMPTY_STATE, server.name)
        server_go:FindChild("ServerStateText"):GetComponent("Text").text = string.format(UIConst.Text.EMPTY_STATE, UIConst.Text.EMPTY_STATE_TEXT)
        self:AddClick(server_go, function ()
            self:SubmitSelectServer(server.id)
        end)
        if server.id == self.select_server_id then server_go:FindChild("Select"):SetActive(true) end
        self.server_go_dict[server.id] = server_go
    end
end

function LoginUI:SubmitSelectServer(server_id)
    self.select_server_id = server_id
    self:ReFreshCurServerUI()
    self.last_select_area = nil
    self.last_select_partition = nil
    self.select_server_panel:SetActive(false)
end

function LoginUI:ClearRoleServerGo()
    for _, go in ipairs(self.role_server_list) do
        self:DelUIObject(go)
    end
    self.role_server_list = {}
end

function LoginUI:ClearAreaGo()
    for _, go in pairs(self.area_go_dict) do
        go:FindChild("Select"):SetActive(false)
        self:DelUIObject(go)
    end
    self.area_go_dict = {}
end

function LoginUI:ClearPartitionGo()
    for _, go in pairs(self.partition_go_dict) do
        go:FindChild("Select"):SetActive(false)
        self:DelUIObject(go)
    end
    self.partition_go_dict = {}
end

function LoginUI:ClearServerGo()
    for _, go in pairs(self.server_go_dict) do
        go:FindChild("Select"):SetActive(false)
        self:DelUIObject(go)
    end
    self.server_go_dict = {}
end

return LoginUI