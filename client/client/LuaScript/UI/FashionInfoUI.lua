local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local FashionInfoUI = class("UI.FashionInfoUI", UIBase)

function FashionInfoUI:DoInit()
    FashionInfoUI.super.DoInit(self)
    self.prefab_path = "UI/Common/FashionInfoUI"
    self.dy_bag_data = ComMgrs.dy_data_mgr.bag_data
    self.dy_lover_data = ComMgrs.dy_data_mgr.lover_data
end

function FashionInfoUI:OnGoLoadedOk(res_go)
    FashionInfoUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function FashionInfoUI:Hide()
    FashionInfoUI.super.Hide(self)
    self:ClearRes()
end

function FashionInfoUI:Show(param_tb)
    print("时装信息========",param_tb)
    --self.loverId = param_tb.lover_id
    self.fashion_id = param_tb.lover_fashion
    self.lover_piece = param_tb.lover_piece
    --self.loverId = 303017
    if self.is_res_ok then
        self:InitUI()
    end
    FashionInfoUI.super.Show(self)
end

function FashionInfoUI:InitRes()
    self.normal_item_panel = self.main_panel:FindChild("NormalItemPanel")
    self:AddClick(self.normal_item_panel, function ()
        self:Hide()
    end)
    self.content = self.main_panel:FindChild("NormalItemPanel/Content")
    self.title = self.content:FindChild("Title"):GetComponent("Text")
    self:AddClick(self.content:FindChild("CloseBtn"), function ()
        self:Hide()
    end)
    self.item = self.content:FindChild("Item")
    self.item_count = self.content:FindChild("Count"):GetComponent("Text")
    self.item_name = self.content:FindChild("ItemName"):GetComponent("Text")
    self.item_desc = self.content:FindChild("ItemDesc"):GetComponent("Text")
    self.frame = self.item:FindChild("Frame")
end

function FashionInfoUI:InitUI()
    --self.unit_rect = self.content:FindChild("UnitRect")
    self.title.text = "时装详情"
    local lover_unit_id = self.fashion_id
    local item_data = SpecMgrs.data_mgr:GetItemData(lover_unit_id)
    print("道具详情---------",item_data)
    --local bag_item_list = self.dy_bag_data:GetBagItemListByBagType(item_data.sub_type)
    local bag_item = self.dy_bag_data:GetBagItemByItemId(self.lover_piece)


    print("道具详情1111111--------",bag_item)

    print("道具详情2222222--------",bag_item.item_data)
    print("道具详情3333333--------",bag_item.item_data.synthesize_count)
    self.item_name.text = item_data.name
    self.item_count.text = bag_item.count .. "/" .. bag_item.item_data.synthesize_count
    self.item_desc.text = string.format(item_data.desc,item_data.attr_list_value[1],item_data.attr_list_value[2],item_data.attr_list_value[3])
    UIFuncs.AssignSpriteByIconID(bag_item.item_data.icon, self.item:FindChild("Icon"):GetComponent("Image"))
    UIFuncs.ChangeItemBgAndFarme(bag_item.item_data.quality, self.frame:GetComponent("Image"),self.frame:GetComponent("Image"))
    --self.unit = self:AddFullUnit(lover_unit_id, self.unit_rect)
    --self:ClickLover(self.xiong_anim)
end

function FashionInfoUI:ClickLover(anim_name)
    print("动作名字---",anim_name)
end


function FashionInfoUI:ClearInfo()
    --self:DelObjDict(self.cur_frame_obj_list)
    --for _, go in pairs(self.lover_gift_list) do
    --    self:DelUIObject(go)
    --end
    --self.lover_gift_list = {}
    --self.unit = nil
end

function FashionInfoUI:ClearRes()
    --self:ClearInfo()
    --self:ClearUnit("unit")
    --self.index = 1
end

return FashionInfoUI