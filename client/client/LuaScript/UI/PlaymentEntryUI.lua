local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local PlaymentEntryUI = class("UI.PlaymentEntryUI", UIBase)
local anchor_v2 = Vector2.New(1, 0)
local control_id_dict = {
    GrabTreasure = {CSConst.RedPointControlIdDict.Playment.GrabTreasure},  --黑市夺宝
    DareTower = {CSConst.RedPointControlIdDict.Playment.DareTower},     --挑战塔
    DaliyBattle = {CSConst.RedPointControlIdDict.Playment.DaliyBattle},   --混乱区域
    Traitor = {       --对抗特工
        CSConst.RedPointControlIdDict.Playment.Traitor,
        CSConst.RedPointControlIdDict.Playment.TraitorReward,
        CSConst.RedPointControlIdDict.Playment.TraitorBoss,
        CSConst.RedPointControlIdDict.Playment.BossReward,
        },
}

function PlaymentEntryUI:DoInit()
    PlaymentEntryUI.super.DoInit(self)
    self.prefab_path = "UI/Common/PlaymentEntryUI"
    self.dy_func_unlock_data = ComMgrs.dy_data_mgr.func_unlock_data
    self.playment_item_list = {}
    self.redpoint_list = {}
end

function PlaymentEntryUI:OnGoLoadedOk(res_go)
    PlaymentEntryUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function PlaymentEntryUI:Hide()
    self:ClearPlaymentItem()
    PlaymentEntryUI.super.Hide(self)
end

function PlaymentEntryUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    PlaymentEntryUI.super.Show(self)
end

function PlaymentEntryUI:InitRes()
    UIFuncs.InitTopBar(self, self.main_panel:FindChild("TopBar"), "PlaymentEntryUI")
    self.playment_list = self.main_panel:FindChild("PlaymentList/View/Content")
    self.playment_list_rect = self.playment_list:GetComponent("RectTransform")
    self.playment_item = self.playment_list:FindChild("Playment")
    self.playment_item:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CLICK_TO_ENTER
end

function PlaymentEntryUI:InitUI()
    self:ClearPlaymentItem()
    for _, playment_data in ipairs(SpecMgrs.data_mgr:GetPlaymentList()) do
        local item = self:GetUIObject(self.playment_item, self.playment_list)
        table.insert(self.playment_item_list, item)
        item.name = playment_data.playment_name
        item:FindChild("Desc"):GetComponent("Text").text = playment_data.desc
        item:FindChild("Name"):GetComponent("Text").text = playment_data.name
        UIFuncs.AssignSpriteByIconID(playment_data.poster, item:GetComponent("Image"))
        if playment_data.goto_ui then
            self:AddClick(item, function ()
                SpecMgrs.ui_mgr:ShowUI(playment_data.goto_ui)
            end)
        end
        if control_id_dict[playment_data.playment_name] then
            local redpoint = SpecMgrs.redpoint_mgr:AddRedPoint(self, item, CSConst.RedPointType.Normal, control_id_dict[playment_data.playment_name], nil, anchor_v2, anchor_v2)
            table.insert(self.redpoint_list, redpoint)
        end
    end
    self.playment_list_rect.anchoredPosition = Vector2.zero
end

function PlaymentEntryUI:ClearPlaymentItem()
    self:RemoveRedPointList(self.redpoint_list)
    self.redpoint_list = {}
    for _, item in ipairs(self.playment_item_list) do
        self:DelUIObject(item)
    end
    self.playment_item_list = {}
end

return PlaymentEntryUI