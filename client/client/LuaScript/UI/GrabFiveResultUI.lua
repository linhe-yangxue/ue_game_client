local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local CSConst = require("CSCommon.CSConst")
local GrabFiveResultUI = class("UI.GrabFiveResultUI", UIBase)

function GrabFiveResultUI:DoInit()
    GrabFiveResultUI.super.DoInit(self)
    self.prefab_path = "UI/Common/GrabFiveResultUI"
    self.sweep_interval_time = SpecMgrs.data_mgr:GetParamData("sweep_interval_time").f_value
    self.sweep_scroll_speed = SpecMgrs.data_mgr:GetParamData("sweep_scroll_speed").f_value
    self.cur_index = 0 -- 当前弹出第几个了
    self.item_list = {}
end

function GrabFiveResultUI:OnGoLoadedOk(res_go)
    GrabFiveResultUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function GrabFiveResultUI:Hide()
    if self.is_sweep then return end
    self:ClearGoDict("item_list")
    self.cur_index = nil
    self.fragment_data = nil
    self.result = nil
    GrabFiveResultUI.super.Hide(self)
end

function GrabFiveResultUI:Show(param_tb)
    self.result = param_tb.result
    self.fragment_id = param_tb.fragment_id
    if self.is_res_ok then
        self:InitUI()
    end
    GrabFiveResultUI.super.Show(self)
end


function GrabFiveResultUI:Update(delta_time)
    if self.sweep_timer and self.is_sweep then
        self.sweep_timer = self.sweep_timer + delta_time
        if self.sweep_timer >= self.sweep_interval_time then
            self.sweep_timer = nil
            self:Sweep()
        end
    end
    self:ScrollSweepPanel(delta_time)
end

function GrabFiveResultUI:ScrollSweepPanel(delta_time)
    if self.is_sweep or self.scroll_after_sweep then
        local nor_pos = self.sweep_scroll_rect.verticalNormalizedPosition
        local content_height = self.sweep_scroll_rect.content.rect.height
        local view_height = self.sweep_scroll_rect.viewport.rect.height
        nor_pos = nor_pos - delta_time * self.sweep_scroll_speed / (content_height - view_height)

        self.sweep_scroll_rect.verticalNormalizedPosition = nor_pos
        if self.scroll_after_sweep then
            if not self.timer then self.timer = 0 end
            self.timer = self.timer + delta_time
            if self.timer >= 0.1 and nor_pos <= 0 then -- scroll_rect 的位置下一帧才会计算新的verticalNormalizedPosition
                self.scroll_after_sweep = nil
                self.timer = nil
            end
        end
    end
end

function GrabFiveResultUI:InitRes()
    self.main_panel:FindChild("Panel/Top/Image/Image/Text"):GetComponent("Text").text = UIConst.Text.GRAB_DETIAL
    self.main_panel:FindChild("Panel/Top/Up/Text"):GetComponent("Text").text = UIConst.Text.GRAB_TREASURE_REPORT
    self.main_panel:FindChild("Panel/Top/Image/Image/Text"):GetComponent("Text").text = string.format(UIConst.Text.SWEEP_PANEL_TIP, UIConst.Text.GRAB_TREASURE_REPORT)
    self.sweep_scroll_rect = self.main_panel:FindChild("Panel/Scroll View"):GetComponent("ScrollRect")
    self.item_parent = self.main_panel:FindChild("Panel/Scroll View/Viewport/Content")
    self.item_temp = self.item_parent:FindChild("Item")
    self.item_temp:SetActive(false)
    UIFuncs.GetIconGo(self, self.item_temp:FindChild("ItemParent"), nil, UIConst.PrefabResPath.ItemWithName).name = "Icon"
    self:AddClick(self.main_panel:FindChild("BlackBg"), function ()
        self:Hide()
    end)
end

function GrabFiveResultUI:InitUI()
    self:BeginSweep()
end

function GrabFiveResultUI:BeginSweep()
    self:ClearGoDict("item_list")
    self.cur_index = 1
    self.fragment_data = SpecMgrs.data_mgr:GetItemData(self.fragment_id)
    self.is_sweep = true
    self:Sweep()
end

function GrabFiveResultUI:SweepEnd()
    self.scroll_after_sweep = true
    self.is_sweep = nil
end

function GrabFiveResultUI:Sweep()
    local result_data = self.result[self.cur_index]
    local go = self:GetUIObject(self.item_temp, self.item_parent)
    table.insert(self.item_list, go)
    go:FindChild("Title/Text"):GetComponent("Text").text = string.format(UIConst.Text.RUSH_NUM, self.cur_index)
    go:FindChild("Money/Image/Text"):GetComponent("Text").text = result_data.reward_dict[CSConst.Virtual.Money]
    go:FindChild("Exp/Image/Text"):GetComponent("Text").text = result_data.reward_dict[CSConst.Virtual.Exp]
    local item_go = go:FindChild("ItemParent/Icon")
    for k, v in pairs(result_data.random_reward) do -- 这里默认服务器传过来只是一个道具的dict
        UIFuncs.InitItemGo({go = item_go, item_id = k, count = v})
    end
    local str
    if result_data.is_success then
        str = UIFuncs.GetItemName({item_data = self.fragment_data})
        str = string.format(UIConst.Text.GRAB_SUCCESS, str)
    else
        str = UIConst.Text.GRAB_FAIL
    end
    go:FindChild("Desc"):GetComponent("Text").text = str
    self.cur_index = self.cur_index + 1
    if not self.result[self.cur_index] then
        self:SweepEnd()
        self.cur_index = nil
    else
        self.sweep_timer = 0
    end
end

return GrabFiveResultUI