local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local VipUI = class("UI.VipUI",UIBase)
local UIFuncs = require("UI.UIFuncs")

VipUI.need_sync_load = true

local kBeginVip = 1 -- 默认从vip1 开始显示
local kAddNum = 1
local kFuncUnlock = 2
local kSliderTime = 0.2
local kMoveDelta = 200

function VipUI:DoInit()
    VipUI.super.DoInit(self)
    self.prefab_path = "UI/Common/VipUI"
    self.dy_vip_data = ComMgrs.dy_data_mgr.vip_data
    self.max_vip_level = SpecMgrs.data_mgr:GetVipData("max_vip_level")
    self.vip_data_list = SpecMgrs.data_mgr:GetAllVipData()
    self.vip_privilege_item_list = {}
    self.vip_to_go = {}
    self.gift_item_list = {}
end

function VipUI:OnGoLoadedOk(res_go)
    VipUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function VipUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    VipUI.super.Show(self)
end

function VipUI:InitRes()
    UIFuncs.GetInitTopBar(self, self.main_panel:FindChild("TopBarParent"), "VipUI")
    self:InitTop()
    self:InitTabPanel()
    self:InitMiddle()
    self:InitBottom()
end

function VipUI:InitTop()
    local top = self.main_panel:FindChild("Top")
    local black_bg = top:FindChild("BlackBg")
    black_bg:FindChild("CurVip"):GetComponent("Text").text = UIConst.Text.CURRENT
    self.cur_vip_image = black_bg:FindChild("CurVip/Image"):GetComponent("Image")
    self.exp_slider = black_bg:FindChild("Slider"):GetComponent("Slider")
    self.exp_text = black_bg:FindChild("Slider/Exp"):GetComponent("Text")
    self.exp_desc_text = black_bg:FindChild("Slider/Desc"):GetComponent("Text")
    self:AddClick(top:FindChild("VipShopBtn"), function()
        SpecMgrs.ui_mgr:ShowUI("VipShopUI")
    end)
    top:FindChild("VipShopBtn/Text"):GetComponent("Text").text = UIConst.Text.VIP_SHOP
    self.vip1_go = top:FindChild("Vip1")
    self.vip1_go:FindChild("Text"):GetComponent("Text").text = UIConst.Text.FIRST_RECHARGE_CAN_GET
    self.vip1_go:FindChild("Image/Text"):GetComponent("Text").text = UIConst.Text.S_LEVEL_HERO_TEXT
    self.vip1_go:FindChild("Scroll View/Text"):GetComponent("Text").text = UIConst.Text.GET_REWARD_FROM_EMAIL
    self.vip1_gift_item_parent = self.vip1_go:FindChild("Scroll View/Viewport/Content")

    self.vip_gift_item_temp = self.vip1_gift_item_parent:FindChild("Item")
    self.vip_gift_item_temp:SetActive(false)
    UIFuncs.GetIconGo(self, self.vip_gift_item_temp, nil, UIConst.PrefabResPath.Item)

    self.other_vip_go = top:FindChild("OtherVip")
    self.other_vip_unit_parent = self.other_vip_go:FindChild("UnitParent")
    self.other_vip_unit_name_text = self.other_vip_go:FindChild("Name/Text"):GetComponent("Text")
    self.other_vip_unit_grade_image = self.other_vip_go:FindChild("Name/Grade"):GetComponent("Image")
    self.other_vip_gift_item_parent = self.other_vip_go:FindChild("Scroll View/Viewport/Content")
    self.other_vip_go:FindChild("Scroll View/Text"):GetComponent("Text").text = UIConst.Text.GET_REWARD_FROM_EMAIL
    self.other_vip_desc_text = self.other_vip_go:FindChild("Text"):GetComponent("Text")
end

function VipUI:InitTabPanel()
    local tab_panel = self.main_panel:FindChild("TabPanel")
    self.vip_item_parent = tab_panel:FindChild("View/Content")
    self.vip_item_temp = self.vip_item_parent:FindChild("Item")
    self.vip_item_temp:SetActive(false)
    self.tab_panel_horizontal_layout = self.vip_item_parent:GetComponent("HorizontalLayoutGroup")

    self:ClearGoDict("vip_to_go")
    for vip_level = kBeginVip, self.max_vip_level do
        local go = self:GetUIObject(self.vip_item_temp, self.vip_item_parent)
        local vip_data = self.vip_data_list[vip_level]
        self.vip_to_go[vip_level] = go
        self:AddClick(go:FindChild("Bg"), function ()
            self:ChangeCurShowVipLevel(vip_level)
        end)
        local image = go:FindChild("Icon"):GetComponent("Image")
        self:AssignSpriteByIconID(vip_data.vip_ui_icon, image)
        go:FindChild("TextBg/Text"):GetComponent("Text").text = vip_data.name
    end
    self.tab_panel_horizontal_layout:SetLayoutHorizontal()
    self.scroll_item_width = self.vip_item_temp:GetComponent("RectTransform").rect.width
end

function VipUI:UpdateVipExp()
    self:AssignSpriteByIconID(self.vip_data.icon, self.cur_vip_image)
    local next_vip_level = self.cur_vip_level + 1
    local next_vip_data = SpecMgrs.data_mgr:GetVipData(next_vip_level)
    local cur_total_exp = self.dy_vip_data:GetVipExp()
    local next_vip_total_exp = next_vip_data and next_vip_data.total_exp
    self.exp_slider.value = next_vip_total_exp and cur_total_exp / next_vip_total_exp or 1
    self.exp_text.text = next_vip_total_exp and string.format(UIConst.Text.PER_VALUE, cur_total_exp, next_vip_total_exp) or UIConst.Text.MAX_TEXT
    local need_exp = next_vip_total_exp and next_vip_total_exp - cur_total_exp
    self.exp_desc_text.text = need_exp and string.format(UIConst.Text.RECHARGE_TO_UP_VIP, need_exp, next_vip_level)
end

function VipUI:InitMiddle()
    local middle = self.main_panel:FindChild("Middle")
    middle:FindChild("Bar/Title/Text"):GetComponent("Text").text = UIConst.Text.VIP_ADDITION
    self.m_cur_vip_text = middle:FindChild("Bar/CurVip/Text"):GetComponent("Text")
    self.m_next_vip_text = middle:FindChild("Bar/NextVip/Text"):GetComponent("Text")

    self.vip_privilege_item_parent = middle:FindChild("View/Content")
    self.vip_privilege_item_temp = self.vip_privilege_item_parent:FindChild("Item")
    self.vip_privilege_item_temp:SetActive(false)
    self.vip_privilege_item_temp:FindChild("Title/Text/New"):GetComponent("Text").text = UIConst.Text.NEW
end

function VipUI:InitBottom()
    local bottom = self.main_panel:FindChild("BottonBar")
    self:AddClick(bottom:FindChild("RechargeBtn"), function()
        SpecMgrs.ui_mgr:ShowUI("RechargeUI")
    end)
    bottom:FindChild("RechargeBtn/Text"):GetComponent("Text").text = UIConst.Text.RECHARGE
end

function VipUI:UpdatePrivilege(vip_level)
    self:ClearGoDict("vip_privilege_item_list")
    self.m_cur_vip_text.text = self.vip_data_list[vip_level].name
    self.m_next_vip_text.text = self.vip_data_list[vip_level + 1] and self.vip_data_list[vip_level + 1].name or nil
    local vip_privilege_list = self.dy_vip_data:GatherSortedVipPrivilegeList(vip_level)
    for i, data in ipairs(vip_privilege_list) do
        local go = self:GetUIObject(self.vip_privilege_item_temp, self.vip_privilege_item_parent)
        table.insert(self.vip_privilege_item_list, go)
        self:UpdatePrivilegeItem(go, data, vip_level)
    end
end

function VipUI:ChangeCurShowVipLevel(level, is_slide_to_cur_level)
    level = math.clamp(level, kBeginVip, self.max_vip_level)
    if self.cur_show_vip_level and self.cur_show_vip_level == level then return end
    if self.cur_show_vip_level then
        self:ChangeSelectStatus(self.cur_show_vip_level, false)
    end
    if is_slide_to_cur_level then
        local targe_pos = self:GetTargetIndexPos(level, self.scroll_item_width)
        self.vip_item_parent:GetComponent("RectTransform").anchoredPosition = targe_pos
    end
    self.cur_show_vip_level = level
    self:ChangeSelectStatus(self.cur_show_vip_level, true)
    self:UpdatePrivilege(self.cur_show_vip_level)
    self:UpdateMiddle(self.cur_show_vip_level)
end

function VipUI:ChangeSelectStatus(level, is_on)
    self.vip_to_go[level]:FindChild("Select"):SetActive(is_on)
end

function VipUI:GetTargetIndexPos(index, each_node_width)
    return Vector2.New(-(index - 1) * each_node_width, 0)
end

function VipUI:UpdatePrivilegeItem(go, data, vip_level)
    go:FindChild("Title/Text/New"):SetActive(data.is_new_func)
    go:FindChild("Title/Text/Image"):SetActive(not data.is_new_func)
    go:FindChild("Title/Text"):GetComponent("Text").text = data.privilege_data.name
    local is_cur_vip_func_open = data[1] > 0
    local cur_vip_text_go = go:FindChild("CurVip/Text")
    cur_vip_text_go:SetActive(is_cur_vip_func_open)
    go:FindChild("CurVip/NoChange"):SetActive(not is_cur_vip_func_open)
    if is_cur_vip_func_open then
        cur_vip_text_go:GetComponent("Text").text = self:GetPrivilegeStr(data.privilege_data, data[1])
    end
    local is_next_vip_func_open = data[2] > 0
    local is_next_vip_bigger_max_vip = vip_level + 1 > self.max_vip_level
    local is_up = data.is_up
    go:FindChild("NextVip/Image"):SetActive(is_up)
    local next_vip_text_go = go:FindChild("NextVip/Text")
    local next_vip_no_change_text_go = go:FindChild("NextVip/NoChange")
    next_vip_text_go:SetActive(is_up)
    next_vip_no_change_text_go:SetActive(not is_next_vip_bigger_max_vip and not is_up)
    local change_go = is_up and next_vip_text_go or next_vip_no_change_text_go
    change_go:GetComponent("Text").text = vip_level < self.max_vip_level and self:GetPrivilegeStr(data.privilege_data, data[2]) or nil
end

function VipUI:UpdateMiddle(vip_level)
    local is_vip1 = vip_level == 1
    self.vip1_go:SetActive(is_vip1)
    self.other_vip_go:SetActive(not is_vip1)
    local vip_data = self.vip_data_list[vip_level]
    local gift_item_data = SpecMgrs.data_mgr:GetRewardData(vip_data.gift)
    local item_list = gift_item_data.reward_item_list
    local item_count_list = gift_item_data.reward_num_list
    if is_vip1 then
        self:UpdateGiftItem(self.vip1_gift_item_parent, item_list, item_count_list)
    else
        self:UpdateGiftItem(self.other_vip_gift_item_parent, item_list, item_count_list)
        self:UpdateUnit(item_list, vip_data.name)
    end
end

function VipUI:UpdateUnit(item_list, vip_name)
    self:ClearUnit("unit")
    local name
    local unit_id
    local quality_data
    local desc_str
    for i, item_id in ipairs(item_list) do
        local item_data = SpecMgrs.data_mgr:GetItemData(item_id)
        if item_data.sub_type == CSConst.ItemSubType.Hero then
            local hero_data = SpecMgrs.data_mgr:GetHeroData(item_data.hero_id)
            unit_id = hero_data.unit_id
            name = hero_data.name
            quality_data = SpecMgrs.data_mgr:GetQualityData(hero_data.quality)
            desc_str = string.render(UIConst.Text.VIP_GIVE_HERO, {s1 = vip_name, s2 = quality_data.grade_text, s3 = hero_data.name})
            break
        elseif item_data.sub_type == CSConst.ItemSubType.Lover then
            local lover_data = SpecMgrs.data_mgr:GetLoverData(item_data.lover_id)
            unit_id = lover_data.unit_id
            name = lover_data.name
            quality_data = SpecMgrs.data_mgr:GetQualityData(lover_data.quality)
            desc_str = string.render(UIConst.Text.VIP_GIVE_LOVER, {s1 = vip_name, s2 = quality_data.grade_text, s3 = lover_data.name})
            break
        end
    end
    self.unit = self:AddHalfUnit(unit_id, self.other_vip_unit_parent)
    self.other_vip_unit_name_text.text = name
    UIFuncs.AssignSpriteByIconID(quality_data.grade, self.other_vip_unit_grade_image)
    self.other_vip_desc_text.text = desc_str
end

function VipUI:UpdateGiftItem(parent, item_list, item_count_list)
    self:ClearGoDict("gift_item_list")
    for i, item_id in ipairs(item_list) do
        local item_data = SpecMgrs.data_mgr:GetItemData(item_id)
        if item_data.sub_type ~= CSConst.ItemSubType.Hero and item_data.sub_type ~= CSConst.ItemSubType.Lover then
            local go = self:GetUIObject(self.vip_gift_item_temp, parent)
            table.insert(self.gift_item_list, go)
            local tb = {ui = self, go = go:FindChild("Item"), item_data = item_data, count = item_count_list[i]}
            UIFuncs.InitItemGo(tb)
        end
    end
end

function VipUI:GetPrivilegeStr(privilege_data, num)
    if not num or num <= 0 then return UIConst.Text.NO_VIP_FUNC end
    if privilege_data.type == kAddNum then
        if privilege_data.is_perc then
            return UIFuncs.GetAddPercentStr(num)
        else
            return UIFuncs.GetAddStr(num)
        end
    elseif privilege_data.type == kFuncUnlock then
        return UIConst.Text.OPEN
    end
end

function VipUI:InitUI()
    self:UpdatePanal()
    self:RegisterEvent(self.dy_vip_data, "UpdateVipInfo", function ()
        self:UpdatePanal()
    end)
end

function VipUI:UpdatePanal()
    self.cur_vip_level = self.dy_vip_data:GetVipLevel()
    self.vip_data = SpecMgrs.data_mgr:GetVipData(self.cur_vip_level)
    self:UpdateVipExp()
    self:ChangeCurShowVipLevel(self.cur_vip_level, true)
end

function VipUI:Hide()
    self:ClearGoDict("vip_privilege_item_list")
    self:ClearGoDict("gift_item_list")
    self:ClearUnit("unit")
    self:ChangeSelectStatus(self.cur_show_vip_level, false)
    self.cur_show_vip_level = nil
    self.cur_vip_level = nil
    self.vip_data = nil
    VipUI.super.Hide(self)
end

return VipUI