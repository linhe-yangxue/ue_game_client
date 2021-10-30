local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local CostItemRecoverUI = class("UI.CostItemRecoverUI", UIBase)

function CostItemRecoverUI:DoInit()
    CostItemRecoverUI.super.DoInit(self)
    self.prefab_path = "UI/Common/CostItemRecoverUI"
    self.dy_lover_data = ComMgrs.dy_data_mgr.lover_data
    self.get_item_list = {}
end

function CostItemRecoverUI:OnGoLoadedOk(res_go)
    CostItemRecoverUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function CostItemRecoverUI:Hide()
    self:ClearGetItem()
    if self.unit_model then
        ComMgrs.unit_mgr:DestroyUnit(self.unit_model)
        self.unit_model = nil
    end
    self.item_list = nil
    self.unit_id = nil
    CostItemRecoverUI.super.Hide(self)
end

function CostItemRecoverUI:Show(item_list, unit_id)
    self.item_list = item_list
    self.unit_id = unit_id
    if not self.item_list or not next(self.item_list) then
        return
    end
    if self.is_res_ok then
        self:InitUI()
    end
    CostItemRecoverUI.super.Show(self)
end

function CostItemRecoverUI:InitRes()
    local content = self.main_panel:FindChild("Content")
    self.lover_model = content:FindChild("LoverModel")
    self.item_content = content:FindChild("ItemList")
    self.get_item = self.item_content:FindChild("GetItem")
    local submit_btn = content:FindChild("SubmitBtn")
    submit_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CONFIRM
    self:AddClick(submit_btn, function ()
        self:Hide()
    end)
end

function CostItemRecoverUI:InitUI()
    self:ClearGetItem()
    for i, data in ipairs(self.item_list) do
        local get_item = self:GetUIObject(self.get_item, self.item_content)
        table.insert(self.get_item_list, get_item)
        local item_data = data.item_data or SpecMgrs.data_mgr:GetItemData(data.item_id)
        get_item:GetComponent("Text").text = string.format(UIConst.Text.GET_ITEM_FORMAT, item_data.name, data.count)
    end
    if not self.unit_id then
        local random_lover = self.dy_lover_data:GetRandomLoverId()
        self.unit_id = SpecMgrs.data_mgr:GetLoverData(random_lover).unit_id
    end
    self.unit_model = self:AddHalfUnit(self.unit_id, self.lover_model)
end

function CostItemRecoverUI:ClearGetItem()
    for _, item in ipairs(self.get_item_list) do
        self:DelUIObject(item)
    end
    self.get_item_list = {}
end

return CostItemRecoverUI