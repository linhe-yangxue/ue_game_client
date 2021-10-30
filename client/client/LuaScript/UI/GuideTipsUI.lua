local UIBase = require("UI.UIBase")
local GuideTipsUI = class("UI.GuideTipsUI", UIBase)
local UIConst = require("UI.UIConst")

local kDefaultWaitTime = 2
function GuideTipsUI:DoInit()
    GuideTipsUI.super.DoInit(self)
    self.default_pos = Vector2.NewByTable({0, 0})
    self.prefab_path = "UI/Common/GuideTipsUI"
end

function GuideTipsUI:OnGoLoadedOk(res_go)
    GuideTipsUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function GuideTipsUI:Update(delta_time)
    if not self.wait_timer then return end
    self.wait_timer = self.wait_timer - delta_time
    if self.wait_timer < 0 then
        self:NextStr()
    end
end

function GuideTipsUI:Hide()
    self.str_list = nil
    self.finish_cb = nil
    self.mask_alpha = nil
    self.pos = nil
    self.wait_time = nil
    self.wait_timer = nil
    GuideTipsUI.super.Hide(self)
end

function GuideTipsUI:InitRes()
    self:AddClick(self.main_panel:FindChild("Mask"), function ()
        self:NextStr()
    end)
    self.guide_text = self.main_panel:FindChild("Tips/Text"):GetComponent("Text")
    self.tip_rect = self.main_panel:FindChild("Tips"):GetComponent("RectTransform")
    self.mask_go = self.main_panel:FindChild("Mask")
end

function GuideTipsUI:Show(param_tb, finish_cb)
    self.str_list = param_tb.str_list
    self.mask_alpha = param_tb.mask_alpha or UIConst.Alpha.Zero
    self.mask_alpha = math.clamp(self.mask_alpha, 0, 1)
    local pos_tb = param_tb.pos_tb
    self.pos = pos_tb and Vector2.NewByTable(pos_tb) or param_tb.pos or self.default_pos
    self.wait_time = param_tb.wait_time or kDefaultWaitTime
    self.wait_timer = self.wait_time
    self.finish_cb = finish_cb
    self.cur_index = 0
    if self.is_res_ok then
        self:InitUI()
    end
    GuideTipsUI.super.Show(self)
end

function GuideTipsUI:InitUI()
    self:NextStr()
    local mask_image = self.mask_go:GetComponent("Image")
    local color = Color.New(mask_image.color.r, mask_image.color.g, mask_image.color.b, self.mask_alpha)
    mask_image.color = color
    if self.pos then
        self.tip_rect.anchoredPosition = self.pos
    end
end


function GuideTipsUI:NextStr()
    if not self.str_list[self.cur_index + 1] then
        local finish_cb = self.finish_cb
        self:Hide()
        if finish_cb then finish_cb() end
    else
        self.cur_index = self.cur_index + 1
        local str = self.str_list[self.cur_index]
        self.guide_text.text = str
        self.wait_timer = self.wait_time
    end
end

return GuideTipsUI