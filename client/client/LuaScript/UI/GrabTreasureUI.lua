local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local ItemUtil = require("BaseUtilities.ItemUtil")
local CSFunction = require("CSCommon.CSFunction")
local GrabTreasureUI = class("UI.GrabTreasureUI", UIBase)

local kNextFragmentTime = 0.3
local kDelaySynthesizeTime = 0.2
local kDelayShowItemInfoTime = 1
local kDelayResetTime = 0.3
function GrabTreasureUI:DoInit()
    GrabTreasureUI.super.DoInit(self)
    self.prefab_path = "UI/Common/GrabTreasureUI"
    self.dy_grab_treasure_data = ComMgrs.dy_data_mgr.grab_treasure_data
    self.gray_material = SpecMgrs.res_mgr:GetMaterialSync(UIConst.MaterialResPath.UIGray)
    self.default_show_treausre_id_list = SpecMgrs.data_mgr:GetParamData("grab_init_red_treasure_list").item_list
    self.treasure_frag_disappear_sound = SpecMgrs.data_mgr:GetSoundId("treasure_frag_disappear_sound")
    self.treasure_synthesize_success_sound = SpecMgrs.data_mgr:GetSoundId("treasure_synthesize_success_sound")
    self.top_bar_item_text_list = {}
    self.top_treasure_item_data_list = {}
    self.top_treasure_id_to_go = {}
    self.fragment_id_to_go = {}
    self.fragment_go_list = {}
    self.smelt_item_id_to_go = {}
    self.selected_smelt_treasure_num = 0
end

function GrabTreasureUI:OnGoLoadedOk(res_go)
    GrabTreasureUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function GrabTreasureUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    GrabTreasureUI.super.Show(self)
end

function GrabTreasureUI:InitRes()
    local top_bar = self.main_panel:FindChild("TopBar")
    UIFuncs.InitTopBar(self, top_bar, "GrabTreasurePanel")
    top_bar:FindChild("CloseBtn/Title"):GetComponent("Text").text = UIConst.Text.GRAB_TREASURE
    self:AddClick(top_bar:FindChild("CloseBtn"), function ()
        SpecMgrs.ui_mgr:HideUI(self)
    end)
    local content = self.main_panel:FindChild("Content")
    local item_panel = content:FindChild("ItemPanel")
    content:FindChild("BottonBar/Text"):GetComponent("Text").text = UIConst.Text.GRAB_BOTTOM_TEXT
    self.top_item_scroll_rect = item_panel:FindChild("ItemList"):GetComponent("ScrollRect")
    self:AddClick(item_panel:FindChild("LeftBtn"), function ()
        self.top_item_scroll_rect.horizontalNormalizedPosition = 0
        self:TopTreasureItemOnClick(self.top_treasure_item_data_list[1])
    end)
    self:AddClick(item_panel:FindChild("RightBtn"), function ()
        self.top_item_scroll_rect.horizontalNormalizedPosition = 1
        self:TopTreasureItemOnClick(self.top_treasure_item_data_list[#self.top_treasure_item_data_list])
    end)
    local smelt_btn = item_panel:FindChild("SmeltBtn")
    smelt_btn:FindChild("Image/Text"):GetComponent("Text").text = UIConst.Text.SMELT_TEXT
    self:AddClick(smelt_btn, function ()
        if self.smelt_item_id then return end -- 已经显示熔炼就不动
        self:ShowSmeltPanel()
    end)
    self.top_treasure_item_parent = item_panel:FindChild("ItemList/View/Content")
    self.top_treasure_item_temp = self.top_treasure_item_parent:FindChild("Item")
    self.top_treasure_item_temp:SetActive(false)
    self.stop_touch_bg = self.main_panel:FindChild("StopTouchBg")
    self.stop_touch_bg:SetActive(false)
    -- 合成
    self.synthesize_panel = content:FindChild("SynthesizePanel")
    local synthesize_content = self.synthesize_panel:FindChild("Middle")
    self.fragment_item_parent = self.synthesize_panel:FindChild("Middle/ItemList")
    self.fragment_item_temp = self.fragment_item_parent:FindChild("Item")
    self.fragment_item_temp:SetActive(false)
    self.synthesize_item_icon = self.synthesize_panel:FindChild("Middle/Middle/Icon"):GetComponent("Image")
    self.synthesize_item_name = self.synthesize_panel:FindChild("Middle/Middle/Icon/Name/Text"):GetComponent("Text")
    self.synthesize_item_effect = self.synthesize_panel:FindChild("Middle/Middle/Effect")

    self.one_key_grab_btn = self.synthesize_panel:FindChild("BtnList/EasyGrabBtn")
    self.one_key_grab_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ONE_KEY_GRAB_TEXT
    self:AddClick(self.one_key_grab_btn, function ()
        self:OneKeyGrabBtnOnClick()
    end)

    self.synthesize_btn = self.synthesize_panel:FindChild("BtnList/SynthesizeBtn")
    self.synthesize_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SYNTHESIZE_TEXT
    self:AddClick(self.synthesize_btn, function ()
        self:SynthesizeBtnOnClick()
    end)

    -- 熔炼
    self.smelt_panel = content:FindChild("SmeltPanel")
    self.smelt_panel:FindChild("FragmentPanel/Title"):GetComponent("Text").text = UIConst.Text.SMELT_FRAGMENT
    self.smelt_item_parent = self.smelt_panel:FindChild("FragmentPanel/Viewport/Content")
    self.smelt_item_temp = self.smelt_item_parent:FindChild("Item")
    self.smelt_item_temp:SetActive(false)
    local select_panel = self.smelt_panel:FindChild("SelectPanel")
    self.smelt_treasure_item = select_panel:FindChild("Item")
    self.smelt_fragment_name = select_panel:FindChild("FragmentName"):GetComponent("Text")
    self.smelt_tip = select_panel:FindChild("SmeltTip"):GetComponent("Text")
    local info_panel = select_panel:FindChild("InfoPanel")
    self.treasure_normal_attr = info_panel:FindChild("NormalAttr"):GetComponent("Text")
    self.treasure_extra_attr = info_panel:FindChild("ExtraAttr"):GetComponent("Text")
    info_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.TREASURE_TIPS
    local exchange_panel = select_panel:FindChild("ExchangePanel")
    self.select_material_item = exchange_panel:FindChild("Material")
    self:AddClick(self.select_material_item, function ()
        self:SelectMaterialBtnOnClick()
    end)
    self.result_item = exchange_panel:FindChild("Result")
    self.smelt_cost_num_text = exchange_panel:FindChild("SmeltBtn/Image/Text"):GetComponent("Text")
    local auto_add_btn = exchange_panel:FindChild("AutoSelectBtn")
    auto_add_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.AUTO_SELECT
    self:AddClick(auto_add_btn, function ()
        self:AutoAddBtnOnClick()
    end)
    local send_smelt_btn = exchange_panel:FindChild("SmeltBtn")
    send_smelt_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SMELT_TEXT
    self:AddClick(send_smelt_btn, function ()
        self:SmeltBtnOnClick()
    end)

    self.select_count_panel = self.main_panel:FindChild("SelectCountPanel")
    local title = self.select_count_panel:FindChild("Panel/Title")
    title:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SYNTHESIZE_FRAGMENT
    self:AddClick(title:FindChild("CloseBtn"), function ()
        self:HideSelectCountPanel()
    end)
    local select_count_content = self.select_count_panel:FindChild("Panel/CountPanel")
    self.select_count_treasure_item = self.select_count_panel:FindChild("Panel/Item")
    self.select_max_count_text = self.select_count_treasure_item:FindChild("MaxCount"):GetComponent("Text")
    self.cur_select_count_input = select_count_content:FindChild("InputField"):GetComponent("InputField")
    self:AddClick(select_count_content:FindChild("ReduceTen"), function ()
        self:ChangeSynthesizeNum(-10)
    end)
    self:AddClick(select_count_content:FindChild("Reduce"), function ()
        self:ChangeSynthesizeNum(1)
    end)
    self:AddClick(select_count_content:FindChild("Add"), function ()
        self:ChangeSynthesizeNum(-1)
    end)
    select_count_content:FindChild("Max/Text"):GetComponent("Text").text = UIConst.Text.MAX
    self:AddClick(select_count_content:FindChild("Max"), function ()
        self:SetSelectNum(nil, true)
    end)
    self:AddInputFieldValueChange(select_count_content:FindChild("InputField"), function (text)
        self:SetSelectNum(text)
    end)
    local cancel_btn = self.select_count_panel:FindChild("Panel/BottonBar/CancelBtn")
    cancel_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CANCEL
    self:AddClick(cancel_btn, function ()
        self:HideSelectCountPanel()
    end)
    local submit_count_btn = self.select_count_panel:FindChild("Panel/BottonBar/SmeltBtn")
    submit_count_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SYNTHESIZE_TEXT
    self:AddClick(submit_count_btn, function ()
        self:SubmitCountBtnOnClick()
    end)

    -- 提示面板
    self.tip_panel = self.main_panel:FindChild("TipPanel")
    self.tip_panel:FindChild("Panel/Content/TopPanel/Title"):GetComponent("Text").text = UIConst.Text.SYSTEM_TIP
    self.tip_text = self.tip_panel:FindChild("Panel/Content/ContentPanel/TipsText"):GetComponent("Text")
    self.tip_toggle = self.tip_panel:FindChild("Panel/Content/ContentPanel/RemindToggle"):GetComponent("Toggle")
    local confirm_btn = self.tip_panel:FindChild("Panel/Content/ContentPanel/ConfirmBtn")
    confirm_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CONFIRM
    self:AddClick(confirm_btn, function ()
        self:TipPanelComfirmBtnOnClick()
    end)
    self:AddClick(self.tip_panel:FindChild("Panel/Content/TopPanel/CloseBtn"), function ()
        self:HideTipPanel()
    end)
    local cancel_btn = self.tip_panel:FindChild("Panel/Content/ContentPanel/CancelBtn")
    cancel_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CANCEL
    self:AddClick(cancel_btn, function ()
        self:HideTipPanel()
    end)
end

function GrabTreasureUI:InitUI()
    self:RegisterEvent(self.dy_grab_treasure_data, "UpdateGrabTreasure", function ()
        self:_UpdateTopTreasureItem()
        self:_UpdateFragmentNum()
    end)
    self:RegisterEvent(ComMgrs.dy_data_mgr.bag_data, "UpdateBagItemEvent", function ()
        self:UpdateSemltTreasuerDataList()
    end)
    self:RegisterEvent(ComMgrs.dy_data_mgr, "UpdateCurrencyEvent", function (_, currency)
        UIFuncs.UpdateCurrencyItemNum(self._item_to_text_list, currency)
    end)
    self:UpdateOnKeyGrabBtn()
    self:_UpdateTopTreasureItem()
    self:UpdateSemltTreasuerDataList()
    self:TopTreasureItemOnClick(self.top_treasure_item_data_list[1])
    self.tip_toggle.isOn = true
end

function GrabTreasureUI:UpdateOnKeyGrabBtn()
    local open_level = SpecMgrs.data_mgr:GetParamData("quick_grab_treasure_open_level").f_value
    local role_level = ComMgrs.dy_data_mgr:ExGetRoleLevel()
    self.one_key_grab_btn:SetActive(role_level >= open_level)
end

function GrabTreasureUI:Hide()
    self:HideSynthesizePanel()
    self:HideSmeltPanel()
    self:ClearGoDict("top_treasure_id_to_go")
    self:ClearTopTreasureItemData()
    SpecMgrs.msg_mgr:SendClearGrabRoleList()
    self.selected_smelt_treasure_num = 0
    GrabTreasureUI.super.Hide(self)
end

function GrabTreasureUI:_UpdateTopTreasureItem()
    self:RemoveSelectEffect("item_panel_select_effect")
    self:ClearGoDict("top_treasure_id_to_go")
    self:ClearTopTreasureItemData()
    local treasure_dict = self.dy_grab_treasure_data:GetTreasureDict()
    for k,v in pairs(treasure_dict) do
        self.is_show_treasure[k] = true
    end
    local treasure_data
    for k, _ in pairs(self.is_show_treasure) do
        treasure_data = SpecMgrs.data_mgr:GetItemData(k)
        table.insert(self.top_treasure_item_data_list, treasure_data)
    end
    ItemUtil.SortItem(self.top_treasure_item_data_list)
    local go
    for _, item_data in ipairs(self.top_treasure_item_data_list) do
        go = self:GetUIObject(self.top_treasure_item_temp, self.top_treasure_item_parent)
        self.top_treasure_id_to_go[item_data.id] = go
        self:AddClick(go, function ()
            self:TopTreasureItemOnClick(item_data)
        end)
        UIFuncs.InitItemGo({go = go, item_data = item_data})
        local synthesize_num = self.dy_grab_treasure_data:GetTreasuerSynthesizeNum(item_data.id)
        local is_show_red_point = synthesize_num > 0 or false
        local is_show_selected = self.cur_select_treasure_id and self.cur_select_treasure_id == item_data.id or false
        go:FindChild("RedPoint"):SetActive(is_show_red_point)
    end
    self:UpdateTopItemSelectEffect()
end

function GrabTreasureUI:_UpdateFragmentNum()
    if self.is_synthesize then return end
    local fragment_dict = self.dy_grab_treasure_data:GetTreasurePieceDict(self.cur_select_treasure_id)
    if not fragment_dict then
        self:TopTreasureItemOnClick(self.top_treasure_item_data_list[1]) -- 当前碎片合成结束 没有碎片自动跳转第一个
        fragment_dict = self.dy_grab_treasure_data:GetTreasurePieceDict(self.cur_select_treasure_id)
    end
    for fragment_id, go in pairs(self.fragment_id_to_go) do
        local num = fragment_dict[fragment_id] or 0
        local image = go:FindChild("Frame/Icon"):GetComponent("Image")
        image.material = num <= 0 and self.gray_material or nil
        go:FindChild("Frame/RedPoint/Count"):GetComponent("Text").text = num
    end
end

function GrabTreasureUI:ClearTopTreasureItemData()
    self.top_treasure_item_data_list = {}
    self.is_show_treasure = {}
end

function GrabTreasureUI:ClearFragmentItem()
    for _, go in ipairs(self.fragment_go_list) do
        self:DelUIObject(go)
    end
    self.fragment_go_list = {}
    self.fragment_id_to_go = {}
end

function GrabTreasureUI:TopTreasureItemOnClick(item_data)
    if self.cur_select_treasure_id and self.cur_select_treasure_id == item_data.id then return end
    self.cur_select_treasure_id = item_data.id
    self:UpdateTopItemSelectEffect()
    self:ShowSynthesizePanel()
end

function GrabTreasureUI:UpdateTopItemSelectEffect()
    if not self.cur_select_treasure_id or not self.top_treasure_id_to_go[self.cur_select_treasure_id] then
        self:RemoveSelectEffect("item_panel_select_effect")
    else
        local select_effect_parent = self.top_treasure_id_to_go[self.cur_select_treasure_id]:FindChild("SelectedParent")
        self:AddSelectEffect(select_effect_parent, "item_panel_select_effect")
    end
end

function GrabTreasureUI:AddSelectEffect(go, effect_name)
    if not self[effect_name] then
        self[effect_name] = UIFuncs.AddSelectEffect(self, go)
    else
        self[effect_name]:SetNewAttachGo(go)
    end
end

function GrabTreasureUI:RemoveSelectEffect(effect_name)
    if self[effect_name] then
        self[effect_name]:EffectEnd()
        self[effect_name] = nil
    end
end

function GrabTreasureUI:ShowSynthesizePanel()
    self:HideSmeltPanel()
    local treasure_id = self.cur_select_treasure_id
    local treasure_data = SpecMgrs.data_mgr:GetItemData(treasure_id)
    local all_fragment_list = treasure_data.fragment_list
    local cur_fragment_dict = self.dy_grab_treasure_data:GetTreasurePieceDict(treasure_id)
    self:ClearFragmentItem()
    for i, fragment_id in ipairs(all_fragment_list) do
        local fragment_data = SpecMgrs.data_mgr:GetItemData(fragment_id)
        local go = self:GetUIObject(self.fragment_item_temp, self.fragment_item_parent)
        self.fragment_id_to_go[fragment_id] = go
        table.insert(self.fragment_go_list, go)
        go:GetComponent("Transform").localRotation = self:GetGoRotation(i, #all_fragment_list)
        go:FindChild("Frame"):GetComponent("Transform").rotation = Quaternion.Euler(0, 0, 0)

        local icon = go:FindChild("Frame/Icon")
        local image = icon:GetComponent("Image")
        self:AssignSpriteByIconID(fragment_data.icon, image)
        self:_SetFragmentEffect(go, false)
        local num = cur_fragment_dict and cur_fragment_dict[fragment_id] or 0
        image.material = num <= 0 and self.gray_material or nil
        go:FindChild("Frame/RedPoint/Count"):GetComponent("Text").text = num
        go:FindChild("Frame/Effect"):SetActive(false)
        self:AddClick(go:FindChild("Frame"), function ()
            self:FragmentItemOnClick(treasure_id, fragment_id)
        end)
    end
    self:AssignSpriteByIconID(treasure_data.icon, self.synthesize_item_icon)
    self.synthesize_item_name.text = UIFuncs.GetItemName({item_data = treasure_data})
    self.synthesize_item_effect:SetActive(false)
    self.synthesize_panel:SetActive(true)
end


function GrabTreasureUI:FragmentItemOnClick(treasure_id, fragment_id)
    local fragment_num = self.dy_grab_treasure_data:GetFragMentNum(treasure_id, fragment_id)
    if fragment_num and fragment_num > 0 then return end
    SpecMgrs.msg_mgr:SendMsg("SendGetGrabRoleList", {treasure_id = treasure_id, fragment_id = fragment_id}, function (resp)
        SpecMgrs.ui_mgr:ShowUI("SelectGrabPlayerUI", {role_list = resp.role_list, treasure_id = treasure_id, fragment_id = fragment_id})
    end)
end

function GrabTreasureUI:GetGoRotation(index, max_count)
    local y_rotation = index - 1 == 0 and 0 or (index - 1) * 360 / max_count
    return Quaternion.Euler(0, 0, y_rotation)
end

function GrabTreasureUI:HideSynthesizePanel()
    self:RemoveSelectEffect("item_panel_select_effect")
    self.cur_select_treasure_id = nil
    self.synthesize_panel:SetActive(false)
end

function GrabTreasureUI:ShowSmeltPanel()
    self:HideSynthesizePanel()
    self:ClearSmeltItem()
    for i, treasure_id in ipairs(self.default_show_treausre_id_list) do
        local go = self:GetUIObject(self.smelt_item_temp, self.smelt_item_parent)
        self.smelt_item_id_to_go[treasure_id] = go
        UIFuncs.InitItemGo({go = go, item_id = treasure_id})
        self:AddClick(go, function ()
            self:SmeltItemOnClick(treasure_id)
        end)
    end
    self:SmeltItemOnClick(self.default_show_treausre_id_list[1])
    self.smelt_panel:SetActive(true)
end

function GrabTreasureUI:HideSmeltPanel()
    self.smelt_item_id = nil
    self:RemoveSelectEffect("smelt_panel_select_effect")
    self:ClearSmeltItem()
    self.smelt_panel:SetActive(false)
end

function GrabTreasureUI:SmeltItemOnClick(treasure_id)
    if self.smelt_item_id and self.smelt_item_id == treasure_id then return end
    self.smelt_item_id = treasure_id
    local select_effect_parent = self.smelt_item_id_to_go[self.smelt_item_id]:FindChild("SelectedParent")
    self:AddSelectEffect(select_effect_parent, "smelt_panel_select_effect")
    local item_data = SpecMgrs.data_mgr:GetItemData(treasure_id)
    UIFuncs.InitItemGo({go = self.smelt_treasure_item, item_data = item_data, ui = self})
    local fragment_data = SpecMgrs.data_mgr:GetItemData(item_data.fragment_list[1])
    self.smelt_fragment_name.text = UIFuncs.GetItemName({item_data = fragment_data})
    self.smelt_tip.text = string.format(UIConst.Text.SYNTHESIZE_ITEM, item_data.name)

    local attr_dict = CSFunction.get_equip_base_attr_dict(self.smelt_item_id)
    local attr_key = item_data.base_attr_list[1]
    self.treasure_normal_attr.text = UIFuncs.GetAttrStr(attr_key, attr_dict[attr_key])
    attr_key = item_data.base_attr_list[2]
    self.treasure_extra_attr.text = UIFuncs.GetAttrStr(attr_key, attr_dict[attr_key])
    self:ChangeSelectMaterial(nil)
    UIFuncs.InitItemGo({go = self.result_item, item_data = fragment_data, ui = self})
    self:ResetSmeltPanel()
end

function GrabTreasureUI:ClearSmeltItem()
    for _, go in pairs(self.smelt_item_id_to_go) do
        self:DelUIObject(go)
    end
    self.smelt_item_id_to_go = {}
end

function GrabTreasureUI:ChangeSelectMaterial(treasure_id)
    if treasure_id then
        UIFuncs.InitItemGo({go = self.select_material_item, item_id = treasure_id})
        self.select_material_item:FindChild("Icon"):SetActive(true)
    else
        local smelt_treasure_quality_list = SpecMgrs.data_mgr:GetParamData("smelt_treasure_quality_list").quality_list
        UIFuncs.ChangeItemBgAndFarme(smelt_treasure_quality_list[1], self.select_material_item:GetComponent("Image"))
        self.select_material_item:FindChild("Icon"):SetActive(false)
    end
end

function GrabTreasureUI:_UpdateSelectMaterial()
    local treasure_id
    for i,v in ipairs(self.smelt_treasure_data_list) do
        if self.is_guid_selected[v.guid] then
            treasure_id = v.item_id
            break
        end
    end
    self:ChangeSelectMaterial(treasure_id)
end

function GrabTreasureUI:ShowSelectCountPanel()
    local tb = {go = self.select_count_treasure_item, item_id = self.cur_select_treasure_id}
    UIFuncs.InitItemGo(tb)
    local synthesize_num = self.dy_grab_treasure_data:GetTreasuerSynthesizeNum(self.cur_select_treasure_id)
    self.select_max_count_text.text = string.format(UIConst.Text.CUR_CAN_SYNTHESIZE_NUM, synthesize_num)
    self.cur_select_count = 1
    self.cur_select_count_input.text = self.cur_select_count
    self.select_count_panel:SetActive(true)
end


function GrabTreasureUI:HideSelectCountPanel()
    self.cur_select_count = nil
    self.select_count_panel:SetActive(false)
end

function GrabTreasureUI:HideTipPanel()
    self.tip_panel:SetActive(false)
end

function GrabTreasureUI:ShowTipPanel()
    local item_name = UIFuncs.GetItemName({item_id = self.cur_select_treasure_id})
    self.tip_text.text = string.format(UIConst.Text.CONFIRM_GRAB_ALL_FRAGMENT, item_name)
    self.tip_panel:SetActive(true)
end

function GrabTreasureUI:OneKeyGrabBtnOnClick()
    local synthesize_num = self.dy_grab_treasure_data:GetTreasuerSynthesizeNum(self.cur_select_treasure_id)
    local cast_item = CSConst.CostValueItem.Vitality
    local cast_item_count = SpecMgrs.data_mgr:GetParamData("grab_treasure_cost_vitality").f_value
    if synthesize_num and synthesize_num > 0 then
        SpecMgrs.ui_mgr:ShowUI("GuideTipsUI",{str_list = {UIConst.Text.CUR_FRAGMENT_IS_ENOUGH}, pos = {0, 241}})
        return
    end
    if not UIFuncs.CheckItemCount(cast_item, cast_item_count, true) then return end
    self:ShowTipPanel()
end

function GrabTreasureUI:SynthesizeBtnOnClick()
    local synthesize_num = self.dy_grab_treasure_data:GetTreasuerSynthesizeNum(self.cur_select_treasure_id)
    if not synthesize_num or synthesize_num <= 0 then
        SpecMgrs.ui_mgr:ShowUI("GuideTipsUI",{str_list = {UIConst.Text.CUR_FRAGMENT_IS_NOT_ENOUGH}})
        return
    end
    if synthesize_num == 1 then
        self:SendSynthesize(1)
    else
        self:ShowSelectCountPanel()
    end
end

function GrabTreasureUI:SendSynthesize(compose_count)
    local treasure_id = self.cur_select_treasure_id
    local compose_count = compose_count or 1
    self.is_synthesize = true
    SpecMgrs.msg_mgr:SendTreasureCompose({treasure_id = treasure_id, compose_count = compose_count}, function (resp)
        if resp.errcode ~= 0 then
            PrintError("Get wrong errcode from serv in SendTreasureCompose", treasure_id, compose_count)
            return
        end
        self:StartSynthesize()
    end)
    self:HideSelectCountPanel()
end

function GrabTreasureUI:StartSynthesize()
    self.stop_touch_bg:SetActive(true)
    self.synthesize_item_effect:SetActive(false)
    self.play_effect_index = 0
    self:AddFragmentEffectTimer()
end

function GrabTreasureUI:AddFragmentEffectTimer()
    if self.fragment_effect_timer then return end
    self.fragment_effect_timer = self:AddTimer(function ()
        self:PlayNextFragmentEffect()
    end, kNextFragmentTime, 0)
end

function GrabTreasureUI:PlayNextFragmentEffect()
    self.play_effect_index = self.play_effect_index + 1
    local go = self.fragment_go_list[self.play_effect_index]
    if not go then
        self:RemoveTimerByName("fragment_effect_timer")
        self:AddDelaySynthesizeEffectTimer()
    else
        self:PlayFragDisappearSound()
        self:_SetFragmentEffect(go, true)
    end
end

function GrabTreasureUI:_SetFragmentEffect(go, is_on)
    go:FindChild("Frame/Effect"):SetActive(is_on)
    local effect_color_anim = go:FindChild("Frame/Icon"):GetComponent("EffectColorAnim")
    effect_color_anim:SetAnim(0, 0)
    effect_color_anim.enabled = is_on
    if not is_on then
        go:FindChild("Frame/Icon"):GetComponent("Image").color = Color.New(1, 1, 1)
    end
end

function GrabTreasureUI:PlayFragDisappearSound()
    self:PlayUISound(self.treasure_frag_disappear_sound)
end

function GrabTreasureUI:PlaySynthesizeSuccessSound()
    self:PlayUISound(self.treasure_synthesize_success_sound)
end

function GrabTreasureUI:RemoveTimerByName(timer_name)
    local timer = self[timer_name]
    if timer then
        self:RemoveTimer(timer)
        self[timer_name] = nil
    end
end

function GrabTreasureUI:AddDelaySynthesizeEffectTimer()
    if self.delay_synthesize_effect_timer then return end
    self.delay_synthesize_effect_timer = self:AddTimer(function ()
        self.synthesize_item_effect:SetActive(true)
        self:PlaySynthesizeSuccessSound()
        self:AddDelayShowItemInfoUI()
        self:RemoveTimerByName("delay_synthesize_effect_timer")
    end, kDelaySynthesizeTime, 1)
end

function GrabTreasureUI:AddDelayShowItemInfoUI()
    if self.delay_show_item_ui_timer then return end
    self.delay_show_item_ui_timer = self:AddTimer(function ()
        self:EndSynthesize()
        self:RemoveTimerByName("delay_show_item_ui_timer")
    end, kDelayShowItemInfoTime, 1)
end

function GrabTreasureUI:EndSynthesize()
    for _, go in ipairs(self.fragment_go_list) do
        self:_SetFragmentEffect(go, false)
    end
    SpecMgrs.ui_mgr:ShowUI("ItemInfoUI", self.cur_select_treasure_id)
    self.stop_touch_bg:SetActive(false)
    self.synthesize_item_effect:SetActive(false)
    self.is_synthesize = nil
    self:_UpdateTopTreasureItem()
    self:_UpdateFragmentNum()
end

function GrabTreasureUI:ChangeSynthesizeNum(num, is_max)
    local cur_select_count = self.cur_select_count + num
    self:SetSelectNum(cur_select_count)
end

function GrabTreasureUI:SetSelectNum(num, is_max)
    if type(num) ~= "number" and is_max ~= true then
        num = tonumber(num)
        if not num then
            self.cur_select_count_input.text = self.cur_select_count
            return
        end
    end
    local synthesize_num = self.dy_grab_treasure_data:GetTreasuerSynthesizeNum(self.cur_select_treasure_id)
    local select_num = is_max and synthesize_num or math.clamp(num, 1, synthesize_num)
    self.cur_select_count = select_num
    self.cur_select_count_input.text = select_num
end

function GrabTreasureUI:SubmitCountBtnOnClick()
    self:SendSynthesize(self.cur_select_count)
end

function GrabTreasureUI:SelectMaterialBtnOnClick()
    if not self:CheckSmeltTreasureDataList() then return end
    local param_tb = {
        treasure_list = self.smelt_treasure_data_list,
        is_guid_selected = self.is_guid_selected,
        select_num = self.selected_smelt_treasure_num,
        comfirm_cb = function (is_guid_selected, select_num)
            self:SelectTreasureUICb(is_guid_selected, select_num)
        end,
    }
    SpecMgrs.ui_mgr:ShowUI("SelectTreasureUI", param_tb)
end

function GrabTreasureUI:SelectTreasureUICb(is_guid_selected, select_num)
    self.is_guid_selected = is_guid_selected
    self:ChangeSelectNum(select_num)
    self:_UpdateSelectMaterial()
end

function GrabTreasureUI:AutoAddBtnOnClick()
    if not self:CheckSmeltTreasureDataList() then return end
    if self.selected_smelt_treasure_num >= #self.smelt_treasure_data_list then return end
    for _, treasure_data in ipairs(self.smelt_treasure_data_list) do
        if not self.is_guid_selected[treasure_data.guid] then
            self.is_guid_selected[treasure_data.guid] = true
            self:ChangeSelectNum(self.selected_smelt_treasure_num + 1)
            break
        end
    end
    self:_UpdateSelectMaterial()
end

function GrabTreasureUI:UpdateSemltTreasuerDataList()
    self.smelt_treasure_data_list = self:GetAllCanSmeltTreasureDataList()
    self:SortTrasuerData(self.smelt_treasure_data_list)
    self.is_guid_selected = {}
end

function GrabTreasureUI:CheckSmeltTreasureDataList()
    if not next (self.smelt_treasure_data_list) then
        SpecMgrs.ui_mgr:ShowUI("GuideTipsUI", {str_list = {UIConst.Text.NO_CAN_SMELT_TREASURE}, pos = {0, 241}})
        return false
    end
    return true
end

function GrabTreasureUI:SortTrasuerData(treasure_data_list)
    table.sort(treasure_data_list, function (data1, data2)
        if data1.strengthen_lv ~= data2.strengthen_lv then
            return data1.strengthen_lv > data2.strengthen_lv
        end
        if data1.refine_lv ~= data2.refine_lv then
            return data1.refine_lv > data2.refine_lv
        end
        if data1.id ~= data2.id then
            return data1.id > data2.id
        end
        return false
    end)
end

function GrabTreasureUI:SmeltBtnOnClick()
    if not next(self.is_guid_selected) then
        SpecMgrs.ui_mgr:ShowUI("GuideTipsUI",{str_list = {UIConst.Text.NO_SELECTED_SMELT_TREASURE}, pos = {0, 241}})
        return
    end
    if not self:CheckSmeltCostItem() then return end
    local guid_list = {}
    for k, v in pairs(self.is_guid_selected) do
        table.insert(guid_list, k)
    end
    local treasure_id = self.smelt_item_id
    SpecMgrs.msg_mgr:SendTreasureSmelt({guid_list = guid_list, treasure_id = treasure_id}, function (resp)
        if resp.errcode ~= 0 then
            PrintError("Get wrong errcode form serv in SendTreasureSmelt", guid_list, treasure_id)
            return
        end
        self:StartSmelt(treasure_id)
    end)
end

function GrabTreasureUI:StartSmelt(treasure_id)
    --显示宝物碎片
    local item_data = SpecMgrs.data_mgr:GetItemData(treasure_id)
    SpecMgrs.ui_mgr:ShowUI("ItemInfoUI", item_data.fragment_list[1])
    self:ResetSmeltPanel()
end

function GrabTreasureUI:ResetSmeltPanel()
    self.is_guid_selected = {}
    self:ChangeSelectMaterial(nil)
    self:ChangeSelectNum(0)
end

function GrabTreasureUI:ChangeSelectNum(num)
    local is_show_red_point = num and num > 0 or false
    self.selected_smelt_treasure_num = num
    self.select_material_item:FindChild("RedPoint"):SetActive(is_show_red_point)
    self.result_item:FindChild("RedPoint"):SetActive(is_show_red_point)
    if is_show_red_point then
        self.select_material_item:FindChild("RedPoint/Count"):GetComponent("Text").text = num
        self.result_item:FindChild("RedPoint/Count"):GetComponent("Text").text = num
    end
    self.smelt_cost_num_text.text = SpecMgrs.data_mgr:GetParamData("treasure_smelt_cost").count * self.selected_smelt_treasure_num
end

function GrabTreasureUI:GetAllCanSmeltTreasureDataList()
    local smelt_treasure_quality_list = SpecMgrs.data_mgr:GetParamData("smelt_treasure_quality_list").quality_list
    self.smelt_treasure_data_list = {}
    for _, quality in ipairs(smelt_treasure_quality_list) do
        local treasure_data_list = ComMgrs.dy_data_mgr.bag_data:GetTreasureListByQuality(quality) or {}
        for i, treasure_data in ipairs(treasure_data_list) do
            table.insert(self.smelt_treasure_data_list, treasure_data)
        end
    end
    self:SortTrasuerData(self.smelt_treasure_data_list)
    return self.smelt_treasure_data_list
end

function GrabTreasureUI:TipPanelComfirmBtnOnClick()
    local data = {treasure_id = self.cur_select_treasure_id, auto_use_item = self.tip_toggle.isOn}
    SpecMgrs.msg_mgr:SendQuickGrabTreasure(data, function(resp)
        if resp.errcode ~= 0 then
            PrintError("Get wrong errcode from serv in SendQuickGrabTreasure", data)
            return
        end
        SpecMgrs.ui_mgr:ShowUI("OneKeyGrabUI", resp)
    end)
    self:HideTipPanel()
end

function GrabTreasureUI:CheckSmeltCostItem()
    local cost_data = SpecMgrs.data_mgr:GetParamData("treasure_smelt_cost")
    local cost_item_id = cost_data.item_id
    local cost_item_num = cost_data.count
    local total_cost = cost_item_num * self.selected_smelt_treasure_num
    local item_count = ComMgrs.dy_data_mgr:ExGetItemCount(cost_item_id)
    if not item_count or item_count < total_cost then
        local item_data = SpecMgrs.data_mgr:GetItemData(cost_item_id)
        local str = string.format(UIConst.Text.ITEM_NOT_ENOUGH, item_data.name)
        SpecMgrs.ui_mgr:ShowUI("GuideTipsUI",{str_list = {str}, pos = {0, 241}})
        return false
    end
    return true
end

return GrabTreasureUI