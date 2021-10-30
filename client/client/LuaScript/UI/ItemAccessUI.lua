local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local UnitConst = require("Unit.UnitConst")

local ItemAccessUI = class("UI.ItemAccessUI", UIBase)

function ItemAccessUI:DoInit()
    ItemAccessUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ItemAccessUI"
    self.access_go_list = {}
end

function ItemAccessUI:OnGoLoadedOk(res_go)
    ItemAccessUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function ItemAccessUI:Show(item_id)
    self.present_list = {}
    self.item_id = item_id
    if self.is_res_ok then
        self:InitUI()
    end
    ItemAccessUI.super.Show(self)
end

function ItemAccessUI:Hide()
    self.item_id = nil
    for _, go in ipairs(self.access_go_list) do
        self:DelUIObject(go)
    end
    self.access_go_list = {}
    ItemAccessUI.super.Hide(self)
end

function ItemAccessUI:InitRes()
    local content = self.main_panel:FindChild("Content")
    local item_info_panel = content:FindChild("ItemInfoPanel")
    self.item_go = item_info_panel:FindChild("Item")
    self.item_name = item_info_panel:FindChild("ItemName")
    self.item_desc = item_info_panel:FindChild("ItemDesc"):GetComponent("Text")
    self.item_count = item_info_panel:FindChild("Count"):GetComponent("Text")
    self.access_grid_parent = content:FindChild("AccessPanel/AccessList/View/Content")
    self.access_grid_template = self.access_grid_parent:FindChild("AccessGrid")
    self.red_point = content:FindChild("Bottom/JumpToBagBtn/RedPoint")
    self:AddClick(content:FindChild("Top/CloseBtn"), function()
        self:Hide()
    end)
    self:AddClick(content:FindChild("Bottom/JumpToBagBtn"), function()
        self:_Click_JumpToBagBtn()
    end)
end

function ItemAccessUI:InitUI()
    local item_data = SpecMgrs.data_mgr:GetItemData(self.item_id)
    self:InitItemInfoPanel(item_data)
    self:InitAccessPanel(item_data)
    self:InitBottomPanel()
    self:RegisterEvent(ComMgrs.dy_data_mgr.bag_data, "UpdateBagItemEvent", function (_, _, item)
        if item.item_id == self.item_id then
            self.item_count.text = item.count
        end
    end)
end

function ItemAccessUI:InitItemInfoPanel(item_data)
    UIFuncs.InitItemGo({
        go = self.item_go,
        item_data = item_data,
        name_go = self.item_name,
    })
    local item_num = ComMgrs.dy_data_mgr:ExGetItemCount(self.item_id)
    self.item_count.text = item_num
    self.item_desc.text = UIFuncs.GetItemDesc(self.item_id)
end

function ItemAccessUI:InitAccessPanel(item_data)
    local access_list = item_data.access
    if not access_list then return end
    for _, access_id in ipairs(access_list) do
        local access_data = SpecMgrs.data_mgr:GetItemAccessData(access_id)
        if self:CheckAccessShow(access_data) then
            local access_go = self:GetUIObject(self.access_grid_template, self.access_grid_parent)
            access_go:FindChild("Name"):GetComponent("Text").text = access_data.name
            access_go:FindChild("Desc"):GetComponent("Text").text = access_data.desc
            UIFuncs.AssignSpriteByIconID(access_data.icon, access_go:FindChild("Image/Icon"):GetComponent("Image"))
            local jump_btn = access_go:FindChild("JumpBtn")
            jump_btn:SetActive(access_data.access_target ~= nil)
            if access_data.access_target ~= nil then
                self:AddClick(jump_btn, function()
                    SpecMgrs.ui_mgr:JumpUI(access_data.access_target)
                end)
            end
            table.insert(self.access_go_list, access_go)
        end
    end
end

function ItemAccessUI:CheckAccessShow(access_data)
    if not access_data.func_unlock_id then return true end
    if ComMgrs.dy_data_mgr.func_unlock_data:IsFuncUnlock(access_data.func_unlock_id) then
        return true
    else
        return false
    end
end

local function _ListContainItem(item_id_list, item_id)
    if not item_id_list then
        PrintError("item_data.item_list is nill")
        return
    end
    for _, id in ipairs(item_id_list) do
        if id == item_id then return true end
        local item_data = SpecMgrs.data_mgr:GetItemData(id)
        if item_data.sub_type == CSConst.ItemSubType.Present or item_data.sub_type == CSConst.ItemSubType.SelectPresent then
            if _ListContainItem(item_data.item_list, item_id) then
                return true
            end
        end
    end
end

function ItemAccessUI:InitBottomPanel()
    local present_dict = ComMgrs.dy_data_mgr.bag_data:GetAllPresentData() or {}
    for _, present in pairs(present_dict) do
        local item_id_list = present.item_data.item_list
        if _ListContainItem(item_id_list, self.item_id) then
            table.insert(self.present_list, present)
        end
    end
    self.red_point:SetActive(#self.present_list > 0)
end

function ItemAccessUI:_Click_JumpToBagBtn()
    if #self.present_list > 0 then
        local item_sub_type = self.present_list[1].item_data.item_sub_type
        SpecMgrs.ui_mgr:HideUI(self)
        SpecMgrs.ui_mgr:ShowUI("BagUI", item_sub_type, self.present_list)
    else
        SpecMgrs.ui_mgr:ShowUI("TipMsgUI", UIConst.Text.NO_GIFT_PACK_STR)
    end
end

return ItemAccessUI