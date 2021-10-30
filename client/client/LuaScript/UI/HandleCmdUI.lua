local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local HandleCmdUI = class("UI.HandleCmdUI",UIBase)
local UIFuncs = require("UI.UIFuncs")
local GConst = require("GlobalConst")
HandleCmdUI.need_sync_load = true

local top_bar_item_id_list = {
    CSConst.Virtual.Money,
    CSConst.Virtual.Food,
    CSConst.Virtual.Soldier,
}

function HandleCmdUI:DoInit()
    HandleCmdUI.super.DoInit(self)
    self.prefab_path = "UI/Common/HandleCmdUI"
    self.great_hall_data = ComMgrs.dy_data_mgr.great_hall_data
    self.cmd_data_list = SpecMgrs.data_mgr:GetAllLevyData()
    self.hall_cmd_item = SpecMgrs.data_mgr:GetParamData("hall_cmd_item").item_id
    self.hall_cmd_item_data = SpecMgrs.data_mgr:GetItemData(self.hall_cmd_item)
    self.cmd_count_text = {}
    self.attr_to_text_tb = {}
    self.levy_btn_list = {}
    self.top_bar_effect_item_list = {} -- 存储特效位置
    self.top_bar_item_to_text = {}
    self.cmd_effect_start_pos_list = {}
    self.cmd_effect_list = {}
    self.is_cmd_cooling_list = {}

    self.is_play_flip = true -- 是否播放翻页
end

function HandleCmdUI:OnGoLoadedOk(res_go)
    HandleCmdUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function HandleCmdUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    HandleCmdUI.super.Show(self)
end

function HandleCmdUI:Update(delta_time)
    if self.is_cmd_cooling_list then
        for index,is_cmd_cooling in ipairs(self.is_cmd_cooling_list) do
            if is_cmd_cooling then
                self:_UpdateCmdCoolText(index)
            end
        end
    end
end

function HandleCmdUI:InitRes()
    local cmd_data = self.great_hall_data:GetCmdData()
    local item_parent = self.main_panel:FindChild("Content/ItemList")
    for i, v in ipairs(cmd_data) do
        local go = item_parent:FindChild(i)
        self:_InitCmdContentItem(v, go)
        go:FindChild("Title"):GetComponent("Text").text = UIConst.Text.CMD_TITLE_LIST[i]
        self.cmd_effect_start_pos_list[i] = go:FindChild("Levy_Anim_Pos")
        local item_text = go:FindChild("Count"):GetComponent("Text")
        self.cmd_count_text[i] = item_text
        local levy_btn = go:FindChild("Levy_Btn")
        levy_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CMD_BTN_TEXT[i]
        self.levy_btn_list[i] = levy_btn
        go:FindChild("Recover_Btn/Text"):GetComponent("Text").text = UIConst.Text.RECOVER
        self:AddClick(go:FindChild("Recover_Btn"), function()
            self:RecoverBtnOnClick(i)
        end)
        self:AddCooldownClick(levy_btn, function ()
            self:LevyBtnOnClick(i)
        end, 0.2)
    end
    self:AddClick(self.main_panel:FindChild("CloseBg"),function ()
        SpecMgrs.ui_mgr:HideUI(self)
    end)
    self:_InitTopBar()
    self.main_panel:FindChild("Content/ItemList/OneKeyBtn/Text"):GetComponent("Text").text = UIConst.Text.ONE_KEY_CMD
    self:AddClick(self.main_panel:FindChild("Content/ItemList/OneKeyBtn"), function()
        self:OneKeyCmdBtnOnClick()
    end)
end

function HandleCmdUI:LevyBtnOnClick(index)
    if not self:_CheckCmdCount(index) then return end
    local cmd_data = self.cmd_data_list[index]
    local cast_item_id = cmd_data.cast_item_id
    if cast_item_id then
        local item_count = ComMgrs.dy_data_mgr:ExGetItemCount(cast_item_id)
        local attribute = cmd_data.influence_attribute
        local attribute_value = ComMgrs.dy_data_mgr:ExGetAtributeValue(attribute)
        local cost_num = math.ceil(attribute_value * cmd_data.trans_ratio)
        if item_count < cost_num then
            local item_data = SpecMgrs.data_mgr:GetItemData(cast_item_id)
            local str = string.format(UIConst.Text.ITEM_NOT_ENOUGH, item_data.name)
            SpecMgrs.ui_mgr:ShowMsgBox(str)
            return
        end
    end
    SpecMgrs.msg_mgr:SendMsg("SendPublichCmd", {id = index}, function(resp)
        if not self.is_res_ok then return end
        self:_PlayCmdSound(index)
        self:_PlayCmdEffect(index) -- 播放特效
    end)
end

function HandleCmdUI:_InitTopBar()
    local top_bar = self.main_panel:FindChild("Content/TopBar")
    UIFuncs.InitTopBar(self, top_bar, "HandleCmdPanel")
    local item_parent = top_bar:FindChild("Itemlist")
    for i, item_id in ipairs(top_bar_item_id_list) do
        self.top_bar_effect_item_list[i] = self._item_to_text_list[item_id][1].gameObject
    end
end

function HandleCmdUI:InitUI()
    self:RegisterEvent(self.great_hall_data, "UpdateCmdEvent", function ( _, index)
        self:_UpdateCmdCount(index)
    end)
    self:RegisterEvent(ComMgrs.dy_data_mgr, "UpdateCurrencyEvent", function (_, currency)
        UIFuncs.UpdateCurrencyItemNum(self._item_to_text_list, currency)
    end)
    self:UpdateCmdContentItem()
    self:_UpdateCmdCount()
end

function HandleCmdUI:Hide()
    self.great_hall_data:UnregisterUpdateCmdEvent("HandleCmdUI")
    for _,levy_effect in ipairs(self.cmd_effect_list) do
        if not levy_effect.is_end then
            levy_effect:EffectEnd()
        end
    end
    self.cmd_effect_list = {}
    HandleCmdUI.super.Hide(self)
end

function HandleCmdUI:_PlayCmdSound(index)
    local levy_data = SpecMgrs.data_mgr:GetLevyData(index)
    local sound_id = levy_data.sound_id
    self:PlayUISound(sound_id)
end

function HandleCmdUI:_PlayCmdEffect(index)
    local start_go = self.cmd_effect_start_pos_list[index]
    local end_go = self.top_bar_effect_item_list[index]
    local pos = UIFuncs.GetGoPositionV2(self, start_go)
    local end_pos = UIFuncs.GetGoPositionV2(self, end_go)
    local param_tb = {
        effect_id = self.great_hall_data:GetCmdData(index).effect_id,
        effect_type = CSConst.EffectType.ET_ToTarget,
        pos = pos,
        end_pos = end_pos,
    }
    local cmd_effect = SpecMgrs.effect_mgr:CreateEffectAutoGuid(param_tb)
    table.insert(self.cmd_effect_list, cmd_effect)
end

function HandleCmdUI:_InitCmdContentItem(content_data, go)
    local attribute = content_data.influence_attribute
    self.attr_to_text_tb[attribute] = {}

    self.attr_to_text_tb[attribute].attribute_text = go:FindChild("Bg/Attr"):GetComponent("Text") -- 显示属性的go
    self.attr_to_text_tb[attribute].levy_text = go:FindChild("Bg/Levy"):GetComponent("Text") -- 显示征收获得物品的go
    if content_data.cast_item_id then
        self.attr_to_text_tb[attribute].cast_text = go:FindChild("Bg/Cast"):GetComponent("Text")
    end
end

function HandleCmdUI:UpdateCmdContentItem()
    for i, cmd_data in ipairs(self.cmd_data_list) do
        local attribute = cmd_data.influence_attribute
        local attribute_value = ComMgrs.dy_data_mgr:ExGetAtributeValue(attribute)
        local attribute_str = UIFuncs.AddCountUnit(math.ceil(attribute_value))
        attribute_str = string.format(UIConst.Text.CMD_CONTENT_ATTRIBUTE,
            SpecMgrs.data_mgr:GetAttributeData(attribute).name,
            attribute_str)
        self.attr_to_text_tb[attribute].attribute_text.text = attribute_str

        local levy_item_id = cmd_data.levy_item_id
        local levy_item_str = UIFuncs.AddCountUnit(math.ceil(attribute_value * cmd_data.trans_ratio))
        local levy_str = string.format(UIConst.Text.CMD_CONTENT_LEVY[i], levy_item_str)
        self.attr_to_text_tb[attribute].levy_text.text = levy_str

        if cmd_data.cast_item_id then
            local cast_item_id = cmd_data.cast_item_id
            local cast_item_str = UIFuncs.AddCountUnit(math.ceil(attribute_value * cmd_data.trans_ratio))
            local cast_str = string.format(UIConst.Text.CMD_CONTENT_CAST,
                SpecMgrs.data_mgr:GetItemData(cast_item_id).name,
                cast_item_str)
            self.attr_to_text_tb[attribute].cast_text.text = cast_str
        end
    end
end

function HandleCmdUI:_UpdateCmdRedPoint()
    local is_show_cmd_red_point = self:_CheckCmdCount()
    if self.is_show_cmd_red_point ~= is_show_cmd_red_point then
        self.cmd_red_point:SetActive(is_show_cmd_red_point)
        self.is_show_cmd_red_point = is_show_cmd_red_point
    end
    if is_show_cmd_red_point then
        self.cmd_red_point_text.text = self:_GetCmdCount()
    end
end

function HandleCmdUI:_UpdateCmdCount(index)
    if index then
        self:_UpdateCmdCountByIndex(index)
    else
        for i = 1, #self.cmd_data_list do
            self:_UpdateCmdCountByIndex(i)
        end
    end
end

function HandleCmdUI:_UpdateCmdCountByIndex(index)
    if self:_CheckCmdCount(index) then
        local str = string.format(UIConst.Text.SPRIT,
            self:_GetCmdCount(index),
            self:_GetCmdMaxCount(index)
        )
        str = UIFuncs.ChangeStrColor(str, "Green1")
        self.cmd_count_text[index].text = str
        self.is_cmd_cooling_list[index] = false
        self.levy_btn_list[index]:SetActive(true)
    else
        self.is_cmd_cooling_list[index] = true
        self:_UpdateCmdCoolText(index)
        self.levy_btn_list[index]:SetActive(false)
    end
end

function HandleCmdUI:_UpdateCmdCoolText(index)
    local cmd_cool_time = self.great_hall_data:GetCmdCoolDownTime(index)
    if not cmd_cool_time then
        self.is_cmd_cooling_list[index] = false
        return
    end
    local str = UIFuncs.TimeDelta2Str(cmd_cool_time, 3)
    self.cmd_count_text[index].text = UIFuncs.ChangeStrColor(str, "Red1")
end

function HandleCmdUI:_CheckCmdCount(index)
    local count = self:_GetCmdCount(index)
    return count > 0
end

function HandleCmdUI:_GetCmdCount(index)
    return self.great_hall_data:GetCmdCount(index)
end

function HandleCmdUI:_GetCmdMaxCount(index)
    return self.great_hall_data:GetCmdMaxCount(index)
end

function HandleCmdUI:GetSelectItemUseUIContent(select_num)
    local content_tb = {}
    content_tb.item_dict = {[self.hall_cmd_item] = select_num}
    local item_name = SpecMgrs.data_mgr:GetItemData(self.hall_cmd_item).name
    content_tb.desc_str = string.format(UIConst.Text.RECOVER_CMD_TEXT, select_num, item_name, select_num)
    return content_tb
end

function HandleCmdUI:SendUseHallItem(select_num, cmd_id)
    local param_tb = {item_id = self.hall_cmd_item, count = select_num, cmd_id = cmd_id}
    SpecMgrs.msg_mgr:SendMsg("SendUseHallItem", param_tb)
end

function HandleCmdUI:RecoverBtnOnClick(cmd_id)
    if not UIFuncs.CheckItemCount(self.hall_cmd_item, 1, true) then return end
    local param_tb = {
        title = UIConst.Text.RECOVER_CMD,
        max_select_num = ComMgrs.dy_data_mgr:ExGetItemCount(self.hall_cmd_item),
        default_select_num = 1,
        confirm_cb = function (select_num)
            self:SendUseHallItem(select_num, cmd_id)
        end,
        get_content_func = function(select_num)
            return self:GetSelectItemUseUIContent(select_num)
        end,
    }
    SpecMgrs.ui_mgr:ShowSelectItemUseByTb(param_tb)
end

function HandleCmdUI:OneKeyCmdBtnOnClick()
    if self.is_wait then return end
    self.is_wait = true
    SpecMgrs.msg_mgr:SendMsg("SendPublichAllCmd", nil, function (resp)
        self.is_wait = nil
        if not self.is_res_ok then return end
        for index, _ in pairs(resp.cmd_dict) do
            self:_PlayCmdSound(index)
            self:_PlayCmdEffect(index)
        end
    end)
end

return HandleCmdUI