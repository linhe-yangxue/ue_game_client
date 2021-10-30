local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local SelectCountUI = class("UI.SelectCountUI", UIBase)

function SelectCountUI:DoInit()
    SelectCountUI.super.DoInit(self)
    self.prefab_path = "UI/Common/SelectCountUI"
end

function SelectCountUI:OnGoLoadedOk(res_go)
    SelectCountUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function SelectCountUI:Hide()
    self.data = nil
    SelectCountUI.super.Hide(self)
end

-- item_id, max_count, confirm_cb, cancel_cb
function SelectCountUI:Show(data)
    self.data = data
    if self.is_res_ok then
        self:InitUI()
    end
    SelectCountUI.super.Show(self)
end

function SelectCountUI:InitRes()
    local content = self.main_panel:FindChild("Content")
    self.title = content:FindChild("Title/Text"):GetComponent("Text")
    self:AddClick(content:FindChild("Title/CloseBtn"), function ()
        if self.data.cancel_cb then self.data.cancel_cb() end
        self:Hide()
    end)
    local count_content = content:FindChild("Content")
    local item_panel = count_content:FindChild("Item")
    self.item_bg = item_panel:GetComponent("Image")
    self.item_icon = item_panel:FindChild("Icon"):GetComponent("Image")
    self.item_frame = item_panel:FindChild("Frame"):GetComponent("Image")
    self.item_name = item_panel:FindChild("Name"):GetComponent("Text")
    self.max_count = item_panel:FindChild("MaxCount"):GetComponent("Text")
    self:AddClick(count_content:FindChild("ReduceTen"), function ()
        self:UpdateSelectCount(self.cur_select_count - 10)
    end)
    self:AddClick(count_content:FindChild("Reduce"), function ()
        self:UpdateSelectCount(self.cur_select_count - 1)
    end)
    self.cur_count = count_content:FindChild("Count/Text"):GetComponent("Text")
    self:AddClick(count_content:FindChild("Add"), function ()
        self:UpdateSelectCount(self.cur_select_count + 1)
    end)
    self:AddClick(count_content:FindChild("Max"), function ()
        self:UpdateSelectCount(self.data.max_count)
    end)
    local cancel_btn = count_content:FindChild("CancelBtn")
    cancel_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CANCEL
    self:AddClick(cancel_btn, function ()
        if self.data.cancel_cb then self.data.cancel_cb() end
        self:Hide()
    end)
    local submit_btn = count_content:FindChild("SubmitBtn")
    submit_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CONFIRM
    self:AddClick(submit_btn, function ()
        if self.data.confirm_cb then self.data.confirm_cb(self.cur_select_count) end
        self:Hide()
    end)
end

function SelectCountUI:InitUI()
    local item_data = SpecMgrs.data_mgr:GetItemData(self.data.item_id)
    if not item_data or not self.data.max_count then
        self:Hide()
        return
    end
    self.title.text = self.data.title or UIConst.Text.SELECT_COUNT
    local quality_data = SpecMgrs.data_mgr:GetQualityData(item_data.quality)
    UIFuncs.AssignSpriteByIconID(quality_data.bg, self.item_bg)
    UIFuncs.AssignSpriteByIconID(item_data.icon, self.item_icon)
    UIFuncs.AssignSpriteByIconID(quality_data.frame, self.item_frame)
    self.item_name.text = string.format(UIConst.Text.SIMPLE_COLOR, quality_data.color, item_data.name)
    self.max_count.text = string.format(UIConst.Text.MAX_COUNT, self.data.max_count)
    self:UpdateSelectCount(self.data.max_count)
end

function SelectCountUI:UpdateSelectCount(count)
    self.cur_select_count = math.clamp(count, 1, self.data.max_count)
    self.cur_count.text = self.cur_select_count
end

return SelectCountUI