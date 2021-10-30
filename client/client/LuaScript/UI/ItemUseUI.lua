local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local ItemUtil = require("BaseUtilities.ItemUtil")
local ItemUseUI = class("UI.ItemUseUI", UIBase)

function ItemUseUI:DoInit()
    ItemUseUI.super:DoInit(self)
    self.prefab_path = "UI/Common/ItemUseUI"
    self.dy_bag_data = ComMgrs.dy_data_mgr.bag_data
    self.item_list = {}
end

function ItemUseUI:OnGoLoadedOk(res_go)
    ItemUseUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function ItemUseUI:Show(param_tb)
    self.need_count = param_tb.need_count or 1
    if param_tb.item_id then
        self.item_id = param_tb.item_id
    else
        self.item_dict = param_tb.item_dict
    end
    self.confirm_cb = param_tb.confirm_cb
    self.cancel_cb = param_tb.cancel_cb
    self.title = param_tb.title or UIConst.Text.ITEM_USE
    self.desc = param_tb.desc or self:GetDescriptionStr()
    self.desc1 = param_tb.desc1 -- 没有就隐藏
    self.count_format = param_tb.count_format or UIConst.Text.REMAIN_COUNT
    self.remind_tag = param_tb.remind_tag -- 没有就隐藏
    if self.is_res_ok then
        self:InitUI()
    end
    ItemUseUI.super.Show(self)
end

function ItemUseUI:Hide()
    self.need_count = nil
    self.item_id = nil
    self:ClearGoDict("item_list")
    self.confirm_cb = nil
    ItemUseUI.super.Hide(self)
end

function ItemUseUI:InitRes()
    local top_part = self.main_panel:FindChild("Content/Top")
    self.title_text = top_part:FindChild("Title"):GetComponent("Text")
    self:AddClick(top_part:FindChild("CloseBtn"), function ()
        self:Hide()
    end)
    local content_panel = self.main_panel
    self.item_parent = content_panel:FindChild("Content/Scroll View/Viewport/Content")
    self.item_size = self.item_parent:FindChild("Item"):GetComponent("RectTransform").sizeDelta
    self.desc_text = content_panel:FindChild("Content/Description"):GetComponent("Text")
    self.desc1_text = content_panel:FindChild("Content/Bottom/Description1"):GetComponent("Text")
    local remind_toggle = content_panel:FindChild("Content/Bottom/RemindToggle")
    self.remind_toggle_cmp = remind_toggle:GetComponent("Toggle")
    remind_toggle:FindChild("Label"):GetComponent("Text").text = UIConst.Text.NO_LONGER_REMIND
    local cancel_btn = content_panel:FindChild("Content/BottonBar/CancelBtn")
    cancel_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CANCEL
    self:AddClick(cancel_btn, function ()
        if self.cancel_cb then self.cancel_cb() end
        self:Hide()
    end)
    self.confirm_btn = content_panel:FindChild("Content/BottonBar/ConfirmBtn")
    self.confirm_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CONFIRM
    self:AddClick(self.confirm_btn, function ()
        -- TODO 使用物品
        if self.confirm_cb then self.confirm_cb() end
        if self.remind_toggle_cmp.isOn == true and self.remind_tag then
            ComMgrs.dy_data_mgr:ExSetItemUseNoLongerRemind(self.remind_tag)
        end
        self:Hide()
    end)
end

function ItemUseUI:InitUI()
    self:ClearGoDict("item_list")
    if self.item_id then
        self:GetItemGo(self.item_id, self.need_count)
    else
        local item_data_list = ItemUtil.ItemDictToItemDataList(self.item_dict, true)
        for _, data in ipairs(item_data_list) do
            self:GetItemGo(data.item_id, data.count)
        end
    end
    self.desc_text.text = self.desc
    if not self.desc1 then
        self.desc1_text.gameObject:SetActive(false)
    else
        self.desc1_text.gameObject:SetActive(true)
        self.desc1_text.text = self.desc1
    end
    self.title_text.text = self.title
    self.remind_toggle_cmp.gameObject:SetActive(self.remind_tag and true or false)
    self.remind_toggle_cmp.isOn = false
end

function ItemUseUI:GetDescriptionStr()
    return UIFuncs.GetUseItemStr(self.item_id, self.need_count,"")
end

function ItemUseUI:GetItemGo(item_id, item_count)
    local param_tb = {
        parent = self.item_parent,
        item_id = item_id,
        count = item_count,
        ui = self,
        size = self.item_size,
    }
    local go = UIFuncs.GetInitItemGoByTb(param_tb)
    table.insert(self.item_list, go)
end

return ItemUseUI