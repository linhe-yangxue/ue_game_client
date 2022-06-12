local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local SlideSelectCmp = require("UI.UICmp.SlideSelectCmp")
local CSFunction = require("CSCommon.CSFunction")
local AttrUtil = require("BaseUtilities.AttrUtil")

local LoverAddStarUI = class("UI.LoverAddStarUI", UIBase)

local kAnimTriggerName = {
    AddStar = "star",
    Reset = "reset",
}

local kLoverIndex = {
    Pre = 0,
    Cur = 1,
    Next = 2,
}
local kResetAnimTime = 0.1

function LoverAddStarUI:DoInit()
    LoverAddStarUI.super.DoInit(self)
    self.prefab_path = "UI/Common/LoverAddStarUI"
    self.star_limit = SpecMgrs.data_mgr:GetParamData("lover_star_lv_limit").f_value
    self.dy_lover_data = ComMgrs.dy_data_mgr.lover_data
    self.dy_bag_data = ComMgrs.dy_data_mgr.bag_data
    self.lover_star_list = {}
    self.lover_model_dict = {}
    self.lover_unit_dict = {}
    self.power_hero_item_dict = {}
    self.attr_item_list = {}
    self.result_attr_item_list = {}
    -- self.left_attr_dict = {}
    -- self.right_attr_dict = {}
    -- self.result_attr_dict = {}
end

function LoverAddStarUI:OnGoLoadedOk(res_go)
    LoverAddStarUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function LoverAddStarUI:Hide()
    if self.reset_timer then
        self:RemoveTimer(self.reset_timer)
        self.reset_timer = nil
    end
    self:ClearAttrItem()
    self:RemoveUnitModel()
    self.cur_lover_id = nil
    self.cur_lover_index = nil
    self.lover_list = nil
    LoverAddStarUI.super.Hide(self)
end

function LoverAddStarUI:Show(param_tb)
    self.cur_lover_id = param_tb.lover_id
    self.fashion_id = param_tb.fashion_id
    if self.is_res_ok then
        self:InitUI()
    end
    LoverAddStarUI.super.Show(self)
end

function LoverAddStarUI:InitRes()
    local content = self.main_panel:FindChild("Content")
    self.animator_cmp = content:GetComponent("Animator")
    UIFuncs.InitTopBar(self, content:FindChild("TopBar"), "LoverAddStarUI")
    self:AddClick(content:FindChild("ResetBtn"), function ()
        self.animator_cmp:SetTrigger(kAnimTriggerName.Reset)
        self.reset_timer = self:AddTimer(function ()
            self:UpdateLoverInfo()
            self.slide_lover_cmp:SetDraggable(#self.lover_list > 1)
            self:RemoveTimer(self.reset_timer)
            self.reset_timer = nil
        end, kResetAnimTime)
    end)
    content:FindChild("ResetBtn/Text"):GetComponent("Text").text = UIConst.Text.CLICK_FOR_CONTINUE

    local lover_info_panel = content:FindChild("LoverInfo")
    local lover_img = lover_info_panel:FindChild("LoverImg")
    self.left_arrow = lover_img:FindChild("LeftArrow")
    self.right_arrow = lover_img:FindChild("RightArrow")
    self.lover_model_dict[kLoverIndex.Pre] = lover_img:FindChild("Lover1")
    self.lover_model_dict[kLoverIndex.Cur] = lover_img:FindChild("Lover2")
    self.lover_model_dict[kLoverIndex.Next] = lover_img:FindChild("Lover3")
    self.slide_lover_cmp = SlideSelectCmp.New()
    self.slide_lover_cmp:DoInit(self, lover_img)
    self.slide_lover_cmp:ListenSlideEnd(function (move_dir)
        self.move_dir = move_dir
        if move_dir ~= 0 then
            self:ReFreshInfoPanel(move_dir)
        end
    end)
    self.slide_lover_cmp:ListenSelectUpdate(function (index)
        self:RefreshModel(index)
    end)

    self.lover_name = lover_info_panel:FindChild("NamePanel/Text"):GetComponent("Text")
    self.lover_grade = lover_info_panel:FindChild("NamePanel/Grade"):GetComponent("Image")
    self.lover_star_panel = lover_info_panel:FindChild("StarPanel")
    for i = 1, self.star_limit do
        self.lover_star_list[i] = self.lover_star_panel:FindChild("Star" .. i)
    end
    self.power_hero_panel = lover_info_panel:FindChild("PowerHero")
    self.power_hero_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.FAMILY_HERO_TEXT
    self.power_hero_item = self.power_hero_panel:FindChild("HeroItem")

    local attr_info_panel = content:FindChild("StarPanel")
    self.left_attr_panel = attr_info_panel:FindChild("LeftAttrPanel")
    self.left_star_desc = self.left_attr_panel:FindChild("StarDesc"):GetComponent("Text")
    self.left_star_panel = self.left_attr_panel:FindChild("StarPanel")
    self.left_attr_item = self.left_attr_panel:FindChild("AttrItem")
    self.right_attr_panel = attr_info_panel:FindChild("RightAttrPanel")
    self.right_star_desc = self.right_attr_panel:FindChild("StarDesc"):GetComponent("Text")
    self.right_star_panel = self.right_attr_panel:FindChild("StarPanel")
    self.right_attr_item = self.right_attr_panel:FindChild("AttrItem")
    self.change_img = attr_info_panel:FindChild("Image")

    local bottom_panel = attr_info_panel:FindChild("BottomPanel")
    local material_panel = bottom_panel:FindChild("MaterialPanel")
    self.material_item = material_panel:FindChild("Item")
    self.material_name = material_panel:FindChild("Name")
    self.material_item_count = material_panel:FindChild("Count"):GetComponent("Text")
    local star_btn = bottom_panel:FindChild("StarBtn")
    star_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ADD_STAR
    self.cost_panel = star_btn:FindChild("CostPanel")
    self.star_cost_count = self.cost_panel:FindChild("Count"):GetComponent("Text")
    self:AddClick(star_btn, function ()
        self:SendLoverAddStar()
    end)

    local result_info_panel = attr_info_panel:FindChild("InfoPanel/Info")
    self.left_star_lv = result_info_panel:FindChild("BeforeLevel"):GetComponent("Text")
    self.right_star_lv = result_info_panel:FindChild("AfterLevel"):GetComponent("Text")
    self.result_info_content = result_info_panel:FindChild("InfoScroll/View/Content")
    self.result_info_content_rect = self.result_info_content:GetComponent("RectTransform")
    self.result_attr_item = self.result_info_content:FindChild("ResultAttrItem")
end

function LoverAddStarUI:InitUI()
    self.lover_list = self.dy_lover_data:GetAllLoverInfo()
    self.left_arrow:SetActive(#self.lover_list > 1)
    self.right_arrow:SetActive(#self.lover_list > 1)
    local lover_info
    lover_info, self.cur_lover_index = self.dy_lover_data:GetLoverInfo(self.cur_lover_id)
    self.cur_lover_id = lover_info.lover_id
    self:UpdateLoverInfo()
    self:InitLoverModel()
    self:RegisterEvent(ComMgrs.dy_data_mgr, "UpdateCurrencyEvent", function (_, currency)
        if self._item_to_text_list then
            UIFuncs.UpdateCurrencyItemNum(self._item_to_text_list, currency)
        end
        self:UpdateAddStarCost()
    end)
    self:RegisterEvent(self.dy_bag_data, "UpdateBagItemEvent", self.UpdateAddStarCost)
end

function LoverAddStarUI:UpdateLoverInfo()
    local lover_info = self.dy_lover_data:GetLoverInfoByIndex(self.cur_lover_index)
    local lover_data = SpecMgrs.data_mgr:GetLoverData(lover_info.lover_id)
    local quality_data = SpecMgrs.data_mgr:GetQualityData(lover_data.quality)
    local next_star_lv = math.min(lover_info.star_lv + 1, self.star_limit)
    self.lover_name.text = lover_data.name
    UIFuncs.AssignSpriteByIconID(quality_data.grade, self.lover_grade)
    for i = 1, self.star_limit do
        local lover_star = self.lover_star_list[i]
        lover_star:FindChild("Active"):SetActive(i <= lover_info.star_lv)
        lover_star:FindChild("Effect"):SetActive(false)
        self.left_star_panel:FindChild("Star" .. i .. "/Active"):SetActive(i <= lover_info.star_lv)
        self.right_star_panel:FindChild("Star" .. i .. "/Active"):SetActive(i <= next_star_lv)
    end
    self:ClearAttrItem()
    for _, hero_id in ipairs(lover_data.hero) do
        local hero_item = self:GetUIObject(self.power_hero_item, self.power_hero_panel)
        self.power_hero_item_dict[hero_id] = hero_item
        UIFuncs.InitHeroGo({go = hero_item, hero_id = hero_id})
    end

    self.left_star_desc.text = string.format(UIConst.Text.LOVER_STAR_ATTR_FORMAT, lover_info.star_lv)
    local cur_star_attr_dict = CSFunction.get_lover_star_attr(lover_info.lover_id, lover_info.star_lv)
    for _, attr in ipairs(AttrUtil.ConvertAttrDictToList(cur_star_attr_dict)) do
        local attr_data = SpecMgrs.data_mgr:GetAttributeData(attr.attr)
        local attr_item = self:GetUIObject(self.left_attr_item, self.left_attr_panel)
        table.insert(self.attr_item_list, attr_item)
        local attr_add_num = attr_data.is_pct and string.format(UIConst.Text.PERCENT, attr.value) or math.floor(attr.value)
        attr_item:GetComponent("Text").text = string.format(UIConst.Text.KEY_VALUE, attr_data.name, attr_add_num)
    end

    UIFuncs.InitItemGo({
        go = self.material_item,
        item_id = lover_data.fragment_id,
        ui = self,
        name_go = self.material_name,
        change_name_color = true,
    })
    local own_material_count = self.dy_bag_data:GetBagItemCount(lover_data.fragment_id)
    self.cost_panel:SetActive(lover_info.star_lv < self.star_limit)
    self.change_img:SetActive(lover_info.star_lv < self.star_limit)
    self.right_attr_panel:SetActive(lover_info.star_lv < self.star_limit)
    self.cost_dict = nil
    if lover_info.star_lv >= self.star_limit then
        self.material_item_count.text = string.format(UIConst.Text.PER_VALUE, own_material_count, 0)
        return
    end

    self.right_star_desc.text = string.format(UIConst.Text.LOVER_STAR_ATTR_FORMAT, next_star_lv)
    local next_star_attr_dict = CSFunction.get_lover_star_attr(lover_info.lover_id, next_star_lv)
    for _, attr in ipairs(AttrUtil.ConvertAttrDictToList(next_star_attr_dict)) do
        local attr_data = SpecMgrs.data_mgr:GetAttributeData(attr.attr)
        local attr_item = self:GetUIObject(self.right_attr_item, self.right_attr_panel)
        table.insert(self.attr_item_list, attr_item)
        local attr_add_num = attr_data.is_pct and string.format(UIConst.Text.PERCENT, attr.value) or math.floor(attr.value)
        attr_item:GetComponent("Text").text = string.format(UIConst.Text.KEY_VALUE_WITH_COLOR, attr_data.name, attr_add_num)
    end

    self.cost_dict = CSFunction.get_lover_star_cost(lover_info.lover_id, next_star_lv)
    self:UpdateAddStarCost()

    self.left_star_lv.text = string.format(UIConst.Text.LOVER_NAME_WITH_STAR_LV, lover_info.star_lv, lover_data.name)
    self.right_star_lv.text = string.format(UIConst.Text.LOVER_NAME_WITH_STAR_LV, next_star_lv, lover_data.name)

    for _, attr in pairs(AttrUtil.ConvertAttrDictToList(cur_star_attr_dict)) do
        local attr_data = SpecMgrs.data_mgr:GetAttributeData(attr.attr)
        local result_attr_item = self:GetUIObject(self.result_attr_item, self.result_info_content)
        table.insert(self.result_attr_item_list, result_attr_item)
        result_attr_item:FindChild("Text"):GetComponent("Text").text = attr_data.name
        local before_value = attr_data.is_pct and string.format(UIConst.Text.PERCENT, cur_star_attr_dict[attr.attr]) or math.floor(cur_star_attr_dict[attr.attr])
        result_attr_item:FindChild("BeforeAttr"):GetComponent("Text").text = before_value
        local after_value = attr_data.is_pct and string.format(UIConst.Text.PERCENT, next_star_attr_dict[attr.attr]) or math.floor(next_star_attr_dict[attr.attr])
        result_attr_item:FindChild("AfterAttr"):GetComponent("Text").text = after_value
    end
    self.result_info_content_rect.anchoredPosition = Vector2.zero
end

function LoverAddStarUI:UpdateAddStarCost()
    if not self.cost_dict then return end
    local lover_info = self.dy_lover_data:GetLoverInfoByIndex(self.cur_lover_index)
    local lover_data = SpecMgrs.data_mgr:GetLoverData(lover_info.lover_id)
    local own_material_count = self.dy_bag_data:GetBagItemCount(lover_data.fragment_id)
    self.material_item_count.text = UIFuncs.GetPerStr(own_material_count, self.cost_dict[lover_data.fragment_id])
    local own_star_cost_coin = self.dy_bag_data:GetBagItemCount(CSConst.Virtual.Money)
    local cost_color = own_star_cost_coin < self.cost_dict[CSConst.Virtual.Money] and UIConst.Color.Red1 or UIConst.Color.Default
    self.star_cost_count.text = string.format(UIConst.Text.SIMPLE_COLOR, cost_color, UIFuncs.AddCountUnit(self.cost_dict[CSConst.Virtual.Money] or 0))
end

function LoverAddStarUI:ReFreshInfoPanel(move_dir)
    self.cur_lover_index = math.Repeat(self.cur_lover_index + move_dir - 1, #self.lover_list) + 1
    self.cur_lover_id = self.lover_list[self.cur_lover_index].lover_id
    self:UpdateLoverInfo()
end

function LoverAddStarUI:InitLoverModel()
    self:RemoveUnitModel()
    self.slide_lover_cmp:ResetLoopOffset()
    local cur_fashion_id = ComMgrs.dy_data_mgr.lover_data:GetLoverInfo(self.cur_lover_id).fashion_id
    if cur_fashion_id ==303025 then
        self.cur_lover_unit_id = SpecMgrs.data_mgr:GetLoverData(self.cur_lover_id).unit_id
    else
        self.cur_lover_unit_id = SpecMgrs.data_mgr:GetItemData(cur_fashion_id).model_id
    end
    --local cur_lover_unit_id = SpecMgrs.data_mgr:GetLoverData(self.cur_lover_id).unit_id
    local cur_lover_unit = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = self.cur_lover_unit_id, parent = self.lover_model_dict[kLoverIndex.Cur]})
    cur_lover_unit:SetPositionByRectName({parent = self.lover_model_dict[kLoverIndex.Cur], name = "full"})
    self.lover_unit_dict[kLoverIndex.Cur] = cur_lover_unit

    self.slide_lover_cmp:SetDraggable(#self.lover_list > 1)
    local pre_lover_info = self.lover_list[math.Repeat(self.cur_lover_index - 2, #self.lover_list) + 1]
    local pre_fashion_id = ComMgrs.dy_data_mgr.lover_data:GetLoverInfo(pre_lover_info.lover_id).fashion_id
    if pre_fashion_id ==303025 then
        self.pre_lover_unit_id = SpecMgrs.data_mgr:GetLoverData(pre_lover_info.lover_id).unit_id
    else
        self.pre_lover_unit_id = SpecMgrs.data_mgr:GetItemData(pre_fashion_id).model_id
    end
    --local pre_lover_unit_id = SpecMgrs.data_mgr:GetLoverData(pre_lover_info.lover_id).unit_id
    local pre_lover_unit = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = self.pre_lover_unit_id, parent = self.lover_model_dict[kLoverIndex.Pre]})
    pre_lover_unit:SetPositionByRectName({parent = self.lover_model_dict[kLoverIndex.Pre], name = "full"})
    self.lover_unit_dict[kLoverIndex.Pre] = pre_lover_unit

    local next_lover_info = self.lover_list[math.Repeat(self.cur_lover_index, #self.lover_list) + 1]
    local next_fashion_id = ComMgrs.dy_data_mgr.lover_data:GetLoverInfo(next_lover_info.lover_id).fashion_id
    if next_fashion_id ==303025 then
        self.next_lover_unit_id = SpecMgrs.data_mgr:GetLoverData(next_lover_info.lover_id).unit_id
    else
        self.next_lover_unit_id = SpecMgrs.data_mgr:GetItemData(next_fashion_id).model_id
    end
    --local next_lover_unit_id = SpecMgrs.data_mgr:GetLoverData(next_lover_info.lover_id).unit_id
    local next_lover_unit = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = self.next_lover_unit_id, parent = self.lover_model_dict[kLoverIndex.Next]})
    next_lover_unit:SetPositionByRectName({parent = self.lover_model_dict[kLoverIndex.Next], name = "full"})
    self.lover_unit_dict[kLoverIndex.Next] = next_lover_unit
end

function LoverAddStarUI:RefreshModel(index)
    ComMgrs.unit_mgr:DestroyUnit(self.lover_unit_dict[index])
    local new_lover_id = self.lover_list[math.Repeat(self.cur_lover_index + self.move_dir - 1, #self.lover_list) + 1].lover_id
    local new_unit_id = SpecMgrs.data_mgr:GetLoverData(new_lover_id).unit_id
    local new_model = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = new_unit_id, parent = self.lover_model_dict[index]})
    new_model:SetPositionByRectName({parent = self.lover_model_dict[index], name = "full"})
    self.lover_unit_dict[index] = new_model
end

-- msg
function LoverAddStarUI:SendLoverAddStar()
    local lover_info = self.dy_lover_data:GetLoverInfoByIndex(self.cur_lover_index)
    if lover_info.star_lv >= self.star_limit then
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.LOVER_ADD_STAR_LIMIT)
        return
    end
    if not UIFuncs.CheckItemCount(CSConst.Virtual.Money, self.cost_dict[CSConst.Virtual.Money], true) then return end
    local lover_data = SpecMgrs.data_mgr:GetLoverData(self.cur_lover_id)
    if not UIFuncs.CheckItemCount(lover_data.fragment_id, self.cost_dict[lover_data.fragment_id], true) then return end
    SpecMgrs.msg_mgr:SendLoverAddStar({lover_id = self.cur_lover_id}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.LOVER_ADD_STAR_FAILED)
        else
            self.lover_star_list[lover_info.star_lv]:FindChild("Effect"):SetActive(true)
            self.animator_cmp:SetTrigger(kAnimTriggerName.AddStar)
            self.slide_lover_cmp:SetDraggable(false)
        end
    end)
end

function LoverAddStarUI:RemoveUnitModel()
    for _, model in pairs(self.lover_unit_dict) do
        ComMgrs.unit_mgr:DestroyUnit(model)
    end
    self.lover_unit_dict = {}
end

function LoverAddStarUI:ClearAttrItem()
    for _, item in pairs(self.power_hero_item_dict) do
        self:DelUIObject(item)
    end
    self.power_hero_item_dict = {}
    for _, item in ipairs(self.attr_item_list) do
        self:DelUIObject(item)
    end
    self.attr_item_list = {}
    for _, item in ipairs(self.result_attr_item_list) do
        self:DelUIObject(item)
    end
    self.result_attr_item_list = {}
end

return LoverAddStarUI