local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local GetItemUI = class("UI.GetItemUI", UIBase)
local ItemUtil = require("BaseUtilities.ItemUtil")
GetItemUI.need_sync_load = true

function GetItemUI:DoInit()
    GetItemUI.super.DoInit(self)
    self.prefab_path = "UI/Common/GetItemUI"
    self.get_item_sound = SpecMgrs.data_mgr:GetParamData("get_item_sound").sound_id
    -- 需要清理的
    self.item_go_list = {}
end

function GetItemUI:Update(delta_time)
    if self.auto_colse_time then
        self.auto_colse_time = self.auto_colse_time - delta_time
        if self.auto_colse_time <= 0 then
            SpecMgrs.ui_mgr:HideUI(self)
        end
        self.auto_colse_time = nil
    end
end

function GetItemUI:OnGoLoadedOk(res_go)
    GetItemUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end
-- 已经排序好的物品列表
function GetItemUI:Show(role_item_list, title, auto_colse_time, close_cb)
    self.role_item_list = role_item_list
    self.title = title or UIConst.Text.CONGRATULATE_GET
    self.auto_colse_time = auto_colse_time
    self.close_cb = close_cb
    if self.is_res_ok then
        self:InitUI()
    end
    GetItemUI.super.Show(self)
end

function GetItemUI:InitRes()
    self.main_panel:FindChild("Frame/Text"):GetComponent("Text").text = UIConst.Text.CLOSE_TIP_TEXT
    self.title_text = self.main_panel:FindChild("Frame/Up/Text"):GetComponent("Text")
    self.item_go_parent = self.main_panel:FindChild("Frame/Content/Scroll View/Viewport/Content")
    self.item_go_temp = self.item_go_parent:FindChild("Item")
    self.item_go_temp:SetActive(false)
    UIFuncs.GetIconGo(self, self.item_go_temp, nil, UIConst.PrefabResPath.Item)
    self:AddClick(self.main_panel:FindChild("CloseBg"), function()
        SpecMgrs.ui_mgr:HideUI(self)
    end)
end

function GetItemUI:InitUI()
    self:PlayUISound(self.get_item_sound)
    self.title_text.text = self.title
    local item_go
    for _, role_item_data in ipairs(self.role_item_list) do
        local go = self:GetUIObject(self.item_go_temp, self.item_go_parent)
        role_item_data.go = go:FindChild("Item")
        UIFuncs.InitItemGo(role_item_data)
        table.insert(self.item_go_list, go)
    end
end

function GetItemUI:Hide()
    self:ClearGoDict("item_go_list")
    self.role_item_list = nil
    self.title = nil
    self.auto_colse_time = nil
    GetItemUI.super.Hide(self)
    if self.close_cb then
        self.close_cb()
    end
    self.close_cb = nil
end

return GetItemUI