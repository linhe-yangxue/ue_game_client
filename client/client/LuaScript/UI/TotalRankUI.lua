local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local TotalRankUI = class("UI.TotalRankUI", UIBase)

function TotalRankUI:DoInit()
    TotalRankUI.super.DoInit(self)
    self.prefab_path = "UI/Common/TotalRankUI"
    self.item_list = {} -- 带标题的item
end

function TotalRankUI:OnGoLoadedOk(res_go)
    TotalRankUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function TotalRankUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    TotalRankUI.super.Show(self)
end

function TotalRankUI:InitRes()
    local top_bar = self.main_panel:FindChild("TopBar")
    UIFuncs.InitTopBar(self, top_bar, "TotalRankUI")
    local title_name = SpecMgrs.data_mgr:GetUIContentData("TotalRankUI").title
    self.item_parent = self.main_panel:FindChild("Scroll View/Viewport/Content")
    self.item_temp = self.item_parent:FindChild("Temp")
    self.item_temp:SetActive(false)
end

function TotalRankUI:InitUI()
    self:ClearGoDict("item_list")
    local total_rank_data_list = SpecMgrs.data_mgr:GetAllTotalRankData()
    local sort_group_id_list = SpecMgrs.data_mgr:GetTotalRankData("sort_group_id_list")
    local rank_group_list = SpecMgrs.data_mgr:GetTotalRankData("group_list")
    for i, group_id in ipairs (sort_group_id_list) do
        local rank_id_list = rank_group_list[group_id]
        local go = self:GetUIObject(self.item_temp, self.item_parent)
        table.insert(self.item_list, go)
        go:FindChild("Text"):GetComponent("Text").text = total_rank_data_list[rank_id_list[1]].name
        self:AddClick(go, function ()
            SpecMgrs.ui_mgr:ShowRankUI(group_id)
        end)
    end
end

function TotalRankUI:Hide()
    self:ClearGoDict("item_list")
    TotalRankUI.super.Hide(self)
end

return TotalRankUI