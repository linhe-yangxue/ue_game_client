local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local FConst = require("CSCommon.Fight.FConst")
local ItemUtil = require("BaseUtilities.ItemUtil")
local EventUtil = require("BaseUtilities.EventUtil")
local VipLevelUpUI = class("UI.VipLevelUpUI",UIBase)

EventUtil.GeneratorEventFuncs(VipLevelUpUI, "VipLevelUpUICloseEvent")

local star_num = 3
local interval = 50
local min_height = 400

function VipLevelUpUI:DoInit()
    VipLevelUpUI.super.DoInit(self)
    self.prefab_path = "UI/Common/VipLevelUpUI"
end

function VipLevelUpUI:OnGoLoadedOk(res_go)
    VipLevelUpUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function VipLevelUpUI:Show(old_vip_level, vip_level)
    self.old_vip_level = old_vip_level
    self.vip_level = vip_level
    self.vip_data = SpecMgrs.data_mgr:GetVipData(self.vip_level)
    if self.is_res_ok then
        self:InitUI()
    end
    VipLevelUpUI.super.Show(self)
end

function VipLevelUpUI:InitRes()
    self.up_win_frame = self.main_panel:FindChild("UpWinFrame")
    self.middle_frame = self.main_panel:FindChild("MiddleFrame")
    self.middle_frame_content = self.main_panel:FindChild("MiddleFrame/Frame")
    self.level_part = self.main_panel:FindChild("LevelPart")
    self.reward_item_part = self.main_panel:FindChild("RewardItemPart")
    self.close_tip_text = self.main_panel:FindChild("CloseTipText")

    self:AddClick(self.main_panel:FindChild("Mask"), function()
        SpecMgrs.ui_mgr:HideUI(self)
    end)
    local up_win_frame_rect = self.up_win_frame:GetComponent("RectTransform")
    self.middle_frame_start_y = up_win_frame_rect.anchoredPosition.y - up_win_frame_rect.sizeDelta.y / 2
    self.vip_level_text_list = {}
    table.insert(self.vip_level_text_list, self.up_win_frame:FindChild("Image2"):GetComponent("Text"))
    table.insert(self.vip_level_text_list, self.up_win_frame:FindChild("Image3"):GetComponent("Text"))
end

function VipLevelUpUI:InitUI()
    self.close_tip_text:SetActive(false)
    self:DelAllCreateUIObj()
    self:SetTextVal()
    self:UpdateUIInfo()
end

function VipLevelUpUI:SetTextVal()
    self.close_tip_text:GetComponent("Text").text = UIConst.Text.CLOSE_TIP_TEXT
    for k,text in ipairs(self.vip_level_text_list) do
        text.text = self.vip_data.name
    end
end

function VipLevelUpUI:UpdateUIInfo()
    self.middle_frame:SetActive(true)
    local create_obj = self:GetUIObject(self.level_part, self.middle_frame_content)
    self:ShowLevelPart(create_obj)

    local item_list = self:GetRewardListByParam()
    if #item_list > 0 then
        local create_obj = self:GetUIObject(self.reward_item_part, self.middle_frame_content)
        self:ShowRewardItemPart(create_obj, item_list)
    end

    local frame_rect = self.middle_frame_content:GetComponent("RectTransform")
    frame_rect.anchoredPosition = Vector2.New(0, -10000)
    local ui_tween = self.middle_frame_content:GetComponent("UITweenPosition")
    ui_tween.enabled = false

    --  下一帧执行
    self:AddTimer(function()
        if not self.is_res_ok then return end
        local middle_frame_rect = self.middle_frame:GetComponent("RectTransform")
        local height = 0
        for i = 0, self.middle_frame_content.childCount - 1 do
            height = height + self.middle_frame_content:GetChild(i):GetComponent("RectTransform").sizeDelta.y
        end
        height = math.clamp(height, min_height, height)

        frame_rect.sizeDelta = Vector2.New(frame_rect.sizeDelta.x, height)
        frame_rect.anchoredPosition = Vector3.New(0, frame_rect.rect.height / 2 + 200)
        middle_frame_rect.sizeDelta = Vector3.New(middle_frame_rect.sizeDelta.x, frame_rect.sizeDelta.y)
        middle_frame_rect.anchoredPosition = Vector3.New(0, self.middle_frame_start_y -(frame_rect.rect.height / 2))

        ui_tween.from_ = Vector3.New(0, frame_rect.rect.height / 2 + 200)
        ui_tween.to_ = Vector3.New(0, -frame_rect.rect.height / 2)
        ui_tween.enabled = true

        self.close_tip_text:GetComponent("RectTransform").anchoredPosition = Vector3.New(0, middle_frame_rect.anchoredPosition.y - middle_frame_rect.sizeDelta.y / 2 - interval)
        self.close_tip_text:SetActive(true)
    end, 0.01, 1)
end

function VipLevelUpUI:ShowLevelPart(ui_obj)
    ui_obj:FindChild("Text"):GetComponent("Text").text = string.render(UIConst.Text.VIP_LEVEL_UP_DESC, {s1 = self.vip_data.name})
end

function VipLevelUpUI:ShowRewardItemPart(ui_obj, reward_item_list)
    UIFuncs.SetItemList(self, reward_item_list, ui_obj:FindChild("List/ViewPort/Content"))
end

function VipLevelUpUI:GetRewardListByParam(reward)
    local reward_list = {}
    local vip_data
    for i = self.old_vip_level + 1, self.vip_level do
        vip_data = SpecMgrs.data_mgr:GetVipData(i)
        table.insert(reward_list, vip_data.gift)
    end
    return ItemUtil.MergeRewardList(reward_list)
end

function VipLevelUpUI:Hide()
    SpecMgrs.msg_mgr:SendMsg("SendGetVipGift")
    self.vip_level = nil
    self.vip_data = nil
    self:DelAllCreateUIObj()
    VipLevelUpUI.super.Hide(self)
end

return VipLevelUpUI