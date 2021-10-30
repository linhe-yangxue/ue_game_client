local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local CSFunction = require("CSCommon.CSFunction")

local StrenghthenMasterUI = class("UI.StrenghthenMasterUI", UIBase)

local kStrenghthenMasterType = {
    EquipStrengthen = 1,
    EquipRefine = 2,
    TreasureStrengthen = 3,
    TreasureRefine = 4,
}

function StrenghthenMasterUI:DoInit()
    StrenghthenMasterUI.super.DoInit(self)
    self.prefab_path = "UI/Common/StrenghthenMasterUI"
    self.dy_night_club_data = ComMgrs.dy_data_mgr.night_club_data
    self.dy_bag_data = ComMgrs.dy_data_mgr.bag_data
    self.dy_func_unlock_data = ComMgrs.dy_data_mgr.func_unlock_data
    self.equip_item_list = {}
    self.cultivate_op_data = {}
    self.attr_item_list = {}
    self.strengthen_cost_item = SpecMgrs.data_mgr:GetParamData("strengthen_equip_cost_coin").item_id
end

function StrenghthenMasterUI:OnGoLoadedOk(res_go)
    StrenghthenMasterUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function StrenghthenMasterUI:Hide()
    self:UpdateOpPanel()
    self:ClearAttrAndEquipItem()
    StrenghthenMasterUI.super.Hide(self)
end

function StrenghthenMasterUI:Show(lineup_id)
    self.lineup_id = lineup_id
    if self.is_res_ok then
        self:InitUI()
    end
    StrenghthenMasterUI.super.Show(self)
end

function StrenghthenMasterUI:InitRes()
    local content = self.main_panel:FindChild("Content")
    local top_panel = content:FindChild("Top")
    top_panel:FindChild("Text"):GetComponent("Text").text = UIConst.Text.STRENGTHEN_MASTER
    self:AddClick(top_panel:FindChild("CloseBtn"), function ()
        self:Hide()
    end)

    local tab_list = content:FindChild("TabList")
    self.equip_strengthen_btn = tab_list:FindChild("EquipStrengthen")
    self.equip_strengthen_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.EQUIPMENT_STRENGTHEN
    self.equip_strengthen_select = self.equip_strengthen_btn:FindChild("Select")
    self.equip_strengthen_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.EQUIPMENT_STRENGTHEN
    self:AddClick(self.equip_strengthen_btn, function ()
        self:UpdateOpPanel(kStrenghthenMasterType.EquipStrengthen)
    end)
    local es_op_data = {}
    es_op_data.btn_cmp = self.equip_strengthen_btn:GetComponent("Button")
    es_op_data.select = self.equip_strengthen_select
    es_op_data.schedule_text = UIConst.Text.STRENGTHEN_SCHEDULE
    es_op_data.tip_text = UIConst.Text.EQUIP_STRENGTHEN_TIP
    es_op_data.lv_text = UIConst.Text.EQUIP_STRENGTHEN_LV
    es_op_data.condition_text = UIConst.Text.EQUIP_STRENGTHEN_CONDITION
    es_op_data.no_attr_text = UIConst.Text.ES_NO_ATTR_TIP
    es_op_data.master_lv_list = SpecMgrs.data_mgr:GetAllESmasterData()
    es_op_data.lv_limit = CSConst.StrengthenLimitRate * ComMgrs.dy_data_mgr:ExGetRoleLevel()
    es_op_data.part_type = CSConst.EquipPartType.Equip
    es_op_data.cultivate_op = CSConst.TreasureCultivateOperation.Strengthen
    self.cultivate_op_data[kStrenghthenMasterType.EquipStrengthen] = es_op_data

    self.equip_refine_btn = tab_list:FindChild("EquipRefine")
    self.equip_refine_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.EQUIPMENT_REFINE
    self.equip_refine_select = self.equip_refine_btn:FindChild("Select")
    self.equip_refine_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.EQUIPMENT_REFINE
    self:AddClick(self.equip_refine_btn, function ()
        self:UpdateOpPanel(kStrenghthenMasterType.EquipRefine)
    end)
    local er_op_data = {}
    er_op_data.btn_cmp = self.equip_refine_btn:GetComponent("Button")
    er_op_data.select = self.equip_refine_select
    er_op_data.schedule_text = UIConst.Text.REFINE_SCHEDULE
    er_op_data.tip_text = UIConst.Text.EQUIP_REFINE_TIP
    er_op_data.lv_text = UIConst.Text.EQUIP_REFINE_LV
    er_op_data.condition_text = UIConst.Text.EQUIP_REFINE_CONDITION
    er_op_data.no_attr_text = UIConst.Text.ER_NO_ATTR_TIP
    er_op_data.master_lv_list = SpecMgrs.data_mgr:GetAllERmasterData()
    er_op_data.lv_limit = #SpecMgrs.data_mgr:GetEquipmentRefineLvList()
    er_op_data.part_type = CSConst.EquipPartType.Equip
    er_op_data.cultivate_op = CSConst.TreasureCultivateOperation.Refine
    er_op_data.func_unlock_id = CSConst.FuncUnlockId.EquipRefine
    self.cultivate_op_data[kStrenghthenMasterType.EquipRefine] = er_op_data

    self.treasure_strengthen_btn = tab_list:FindChild("TreasureStrengthen")
    self.treasure_strengthen_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.TREASURE_STRENGTHEN
    self.treasure_strengthen_select = self.treasure_strengthen_btn:FindChild("Select")
    self.treasure_strengthen_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.TREASURE_STRENGTHEN
    self:AddClick(self.treasure_strengthen_btn, function ()
        self:UpdateOpPanel(kStrenghthenMasterType.TreasureStrengthen)
    end)
    local ts_op_data = {}
    ts_op_data.btn_cmp = self.treasure_strengthen_btn:GetComponent("Button")
    ts_op_data.select = self.treasure_strengthen_select
    ts_op_data.schedule_text = UIConst.Text.STRENGTHEN_SCHEDULE
    ts_op_data.tip_text = UIConst.Text.TREASURE_STRENGTHEN_TIP
    ts_op_data.lv_text = UIConst.Text.TREASURE_STRENGTHEN_LV
    ts_op_data.condition_text = UIConst.Text.TREASURE_STRENGTHEN_CONDITION
    ts_op_data.no_attr_text = UIConst.Text.TS_NO_ATTR_TIP
    ts_op_data.master_lv_list = SpecMgrs.data_mgr:GetAllTSmasterData()
    ts_op_data.lv_limit = #SpecMgrs.data_mgr:GetAllStrengthenLvData()
    ts_op_data.part_type = CSConst.EquipPartType.Treasure
    ts_op_data.cultivate_op = CSConst.TreasureCultivateOperation.Strengthen
    self.cultivate_op_data[kStrenghthenMasterType.TreasureStrengthen] = ts_op_data

    self.treasure_refine_btn = tab_list:FindChild("TreasureRefine")
    self.treasure_refine_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.TREASURE_REFINE
    self.treasure_refine_select = self.treasure_refine_btn:FindChild("Select")
    self.treasure_refine_select:FindChild("Text"):GetComponent("Text").text = UIConst.Text.TREASURE_REFINE
    self:AddClick(self.treasure_refine_btn, function ()
        self:UpdateOpPanel(kStrenghthenMasterType.TreasureRefine)
    end)
    local tr_op_data = {}
    tr_op_data.btn_cmp = self.treasure_refine_btn:GetComponent("Button")
    tr_op_data.select = self.treasure_refine_select
    tr_op_data.schedule_text = UIConst.Text.REFINE_SCHEDULE
    tr_op_data.tip_text = UIConst.Text.TREASURE_REFINE_TIP
    tr_op_data.lv_text = UIConst.Text.TREASURE_REFINE_LV
    tr_op_data.condition_text = UIConst.Text.TREASURE_REFINE_CONDITION
    tr_op_data.no_attr_text = UIConst.Text.TR_NO_ATTR_TIP
    tr_op_data.master_lv_list = SpecMgrs.data_mgr:GetAllTRmasterData()
    tr_op_data.lv_limit = #SpecMgrs.data_mgr:GetTreasureRefineLvList()
    tr_op_data.part_type = CSConst.EquipPartType.Treasure
    tr_op_data.cultivate_op = CSConst.TreasureCultivateOperation.Refine
    tr_op_data.func_unlock_id = CSConst.FuncUnlockId.TreasureRefine
    self.cultivate_op_data[kStrenghthenMasterType.TreasureRefine] = tr_op_data

    local master_content = content:FindChild("Content")
    local strengthen_schedule = master_content:FindChild("StrengthSchedule")
    self.strengthen_schedule_text = strengthen_schedule:FindChild("Header/Title"):GetComponent("Text")
    local equip_content = strengthen_schedule:FindChild("Content")
    for i = 1, CSConst.MasterEquipCount.Equip do
        local equip_item = equip_content:FindChild("EquipItem" .. i)
        table.insert(self.equip_item_list, equip_item)
    end
    self.equip_tip_text = equip_content:FindChild("Tip"):GetComponent("Text")

    local attr_panel = master_content:FindChild("AttrPanel")
    self.attr_header_title = attr_panel:FindChild("Header/Title"):GetComponent("Text")
    local attr_content = attr_panel:FindChild("AttrContent")
    self.no_attr_tip = attr_content:FindChild("NoAttrTip")
    self.no_attr_tip_text = self.no_attr_tip:GetComponent("Text")

    self.left_attr_panel = attr_content:FindChild("LeftAttr")
    self.left_lv_text = self.left_attr_panel:FindChild("Lv"):GetComponent("Text")
    self.left_condition_text = self.left_attr_panel:FindChild("Condition"):GetComponent("Text")
    self.left_attr_item = self.left_attr_panel:FindChild("AttrItem")

    self.right_attr_panel = attr_content:FindChild("RightAttr")
    self.right_lv_text = self.right_attr_panel:FindChild("Lv"):GetComponent("Text")
    self.right_condition_text = self.right_attr_panel:FindChild("Condition"):GetComponent("Text")
    self.right_attr_item = self.right_attr_panel:FindChild("AttrItem")
    self.next_lv_img = attr_content:FindChild("Image")

    local btn_panel = content:FindChild("BtnPanel")
    local close_btn = btn_panel:FindChild("CloseBtn")
    close_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CLOSE_TEXT
    self:AddClick(close_btn, function ()
        self:Hide()
    end)
    self.easy_strengthen_btn = btn_panel:FindChild("EasyStrengthenBtn")
    self.easy_strengthen_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.EASY_STRENGTHEN_TEXT
    self.easy_strengthen_btn_cmp = self.easy_strengthen_btn:GetComponent("Button")
    self.easy_strengthen_disable = self.easy_strengthen_btn:FindChild("Disable")
    -- self.easy_strengthen_disable:FindChild("Text"):GetComponent("Text").text = UIConst.Text.EASY_STRENGTHEN_TEXT
    self:AddClick(self.easy_strengthen_btn, function ()
        self:EasyStrengthen()
    end)
end

function StrenghthenMasterUI:InitUI()
    if not self.lineup_id then
        self:Hide()
        return
    end
    self.lineup_data = self.dy_night_club_data:GetLineupData(self.lineup_id)
    self:InitOpBtnState()
    self:UpdateOpPanel(kStrenghthenMasterType.EquipStrengthen)
end

function StrenghthenMasterUI:InitOpBtnState()
    local treasure_flag = true
    for i, part_data in ipairs(SpecMgrs.data_mgr:GetAllEquipPartData()) do
        if part_data.part_type == CSConst.EquipPartType.Treasure then
            if not self.lineup_data.equip_dict[i] then
                treasure_flag = false
                break
            end
        end
    end
    self.treasure_strengthen_btn:GetComponent("Button").interactable = treasure_flag
    self.treasure_refine_btn:GetComponent("Button").interactable = treasure_flag
end

function StrenghthenMasterUI:UpdateOpPanel(op_code)
    if self.cur_op == op_code then return end
    if self.cur_op then
        local last_op_data = self.cultivate_op_data[self.cur_op]
        last_op_data.select:SetActive(false)
        last_op_data.btn_cmp.interactable = true
    end
    self:ClearAttrAndEquipItem()
    self.cur_op = op_code
    if not self.cur_op then return end
    local cur_op_data = self.cultivate_op_data[self.cur_op]
    cur_op_data.select:SetActive(true)
    cur_op_data.btn_cmp.interactable = false
    self:InitMasterPanel()
end

function StrenghthenMasterUI:InitMasterPanel()
    self:ClearAttrAndEquipItem()
    local op_data = self.cultivate_op_data[self.cur_op]
    self.strengthen_schedule_text.text = op_data.schedule_text
    self.equip_tip_text.text = op_data.tip_text
    self.strengthen_schedule_text.text = op_data.schedule_text
    self.easy_strengthen_btn:SetActive(self.cur_op == kStrenghthenMasterType.EquipStrengthen)
    if self.cur_op == kStrenghthenMasterType.EquipStrengthen then
        local strengthen_lv_limit = CSConst.StrengthenLimitRate * ComMgrs.dy_data_mgr:ExGetRoleLevel()
        local strengthen_flag = false
        for i, part_data in ipairs(SpecMgrs.data_mgr:GetAllEquipPartData()) do
            if part_data.part_type == CSConst.EquipPartType.Equip then
                local equip_info = self.dy_bag_data:GetBagItemDataByGuid(self.lineup_data.equip_dict[i])
                if equip_info.strengthen_lv < strengthen_lv_limit then
                    strengthen_flag = true
                    break
                end
            end
        end
        self.easy_strengthen_btn_cmp.interactable = strengthen_flag
        self.easy_strengthen_disable:SetActive(not strengthen_flag)
    end

    local index = 0
    local equip_dict = self.lineup_data.equip_dict
    for i, part_data in ipairs(SpecMgrs.data_mgr:GetAllEquipPartData()) do
        if part_data.part_type == op_data.part_type then
            index = index + 1
            local equip_info = self.dy_bag_data:GetBagItemDataByGuid(self.lineup_data.equip_dict[i])
            local equip_data = SpecMgrs.data_mgr:GetItemData(equip_info.item_id)
            local quality_data = SpecMgrs.data_mgr:GetQualityData(equip_data.quality)
            local cur_lv = op_data.cultivate_op == CSConst.TreasureCultivateOperation.Strengthen and equip_info.strengthen_lv or equip_info.refine_lv

            local equip_item = self.equip_item_list[index]
            self:AddClick(equip_item:FindChild("EquipIcon"), function ()
                if cur_lv >= op_data.lv_limit then return end
                if op_data.func_unlock_id and not self.dy_func_unlock_data:IsFuncUnlock(op_data.func_unlock_id) then
                    SpecMgrs.ui_mgr:ShowTipMsg(UIFuncs.GetFuncLockTipStr(op_data.func_unlock_id))
                    return
                end
                self:Hide()
                if part_data.part_type == CSConst.EquipPartType.Equip then
                    SpecMgrs.ui_mgr:ShowUI("EquipmentCultivateUI", equip_info.guid, op_data.cultivate_op)
                elseif part_data.part_type == CSConst.EquipPartType.Treasure then
                    SpecMgrs.ui_mgr:ShowUI("TreasureCultivateUI", equip_info.guid, op_data.cultivate_op)
                end
            end)
            UIFuncs.AssignSpriteByIconID(quality_data.bg, equip_item:FindChild("EquipIcon"):GetComponent("Image"))
            UIFuncs.AssignSpriteByIconID(equip_data.icon, equip_item:FindChild("EquipIcon/Icon"):GetComponent("Image"))
            UIFuncs.AssignSpriteByIconID(quality_data.frame, equip_item:FindChild("EquipIcon/Frame"):GetComponent("Image"))
            equip_item:FindChild("Name"):GetComponent("Text").text = equip_data.name
            local schedule_bar = equip_item:FindChild("ScheduleBar")
            schedule_bar:FindChild("CurSchedule"):GetComponent("Image").fillAmount = cur_lv / op_data.lv_limit
            schedule_bar:FindChild("ScheduleValue"):GetComponent("Text").text = string.format(UIConst.Text.PER_VALUE, cur_lv, op_data.lv_limit)
            equip_item:SetActive(true)
        end
    end

    local master_lv_dict = op_data.cultivate_op == CSConst.TreasureCultivateOperation.Strengthen and self.lineup_data.strengthen_master_lv or self.lineup_data.refine_master_lv
    local master_lv = master_lv_dict[op_data.part_type]
    self.attr_header_title.text = string.format(op_data.lv_text, master_lv)
    local cur_es_master_data = op_data.master_lv_list[master_lv]
    self.no_attr_tip:SetActive(cur_es_master_data == nil)
    self.left_attr_panel:SetActive(cur_es_master_data ~= nil)
    if not cur_es_master_data then
        self.no_attr_tip_text.text = op_data.no_attr_text
    else
        self.left_lv_text.text = string.format(op_data.lv_text, master_lv)
        self.left_condition_text.text = string.format(op_data.condition_text, cur_es_master_data.equip_lv)
        if cur_es_master_data.add_anger and cur_es_master_data.add_anger > 0 then
            local anger_item = self:GetUIObject(self.left_attr_item, self.left_attr_panel)
            anger_item:GetComponent("Text").text = string.format(UIConst.Text.CUR_ANGER_FORMAT, cur_es_master_data.add_anger)
            table.insert(self.attr_item_list, anger_item)
        end
        for i, attr in ipairs(cur_es_master_data.attr_list) do
            local attr_item = self:GetUIObject(self.left_attr_item, self.left_attr_panel)
            table.insert(self.attr_item_list, attr_item)
            attr_item:GetComponent("Text").text = UIFuncs.GetAttrStr(attr, cur_es_master_data.attr_value_list[i])
        end
    end
    local next_es_master_lv = master_lv + 1
    local next_es_master_data = op_data.master_lv_list[next_es_master_lv]
    self.right_attr_panel:SetActive(next_es_master_data ~= nil)
    self.next_lv_img:SetActive(next_es_master_data ~= nil)
    if next_es_master_data then
        self.right_lv_text.text = string.format(op_data.lv_text, master_lv + 1)
        self.right_condition_text.text = string.format(op_data.condition_text, next_es_master_data.equip_lv)
        if next_es_master_data.add_anger and next_es_master_data.add_anger > 0 then
            local anger_item = self:GetUIObject(self.right_attr_item, self.right_attr_panel)
            anger_item:GetComponent("Text").text = string.format(UIConst.Text.NEXT_ANGER_FORMAT, next_es_master_data.add_anger)
            table.insert(self.attr_item_list, anger_item)
        end
        for i, attr in ipairs(next_es_master_data.attr_list) do
            local attr_item = self:GetUIObject(self.right_attr_item, self.right_attr_panel)
            table.insert(self.attr_item_list, attr_item)
            attr_item:GetComponent("Text").text = UIFuncs.GetAttrStr(attr, next_es_master_data.attr_value_list[i], true)
        end
    end
end

function StrenghthenMasterUI:EasyStrengthen()
    local total_cost = self:CalcEasyStrengthenCost()
    local item_data = SpecMgrs.data_mgr:GetItemData(self.strengthen_cost_item)
    if total_cost > 0 then
        local data = {
            title = UIConst.Text.EASY_STRENGTHEN_TEXT,
            item_id = self.strengthen_cost_item,
            need_count = total_cost,
            desc = string.format(UIConst.Text.STRENGTHEN_SUBMIT_TIP, item_data.name, UIFuncs.AddCountUnit(total_cost)),
            remind_tag = "EasyStrengthen",
            confirm_cb = function ()
                SpecMgrs.msg_mgr:SendQuickStrengthenEquipment({lineup_id = self.lineup_id}, function (resp)
                    if resp.errcode ~= 0 then
                        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.STRENGTH_FAILED)
                    else
                        self.lineup_data = self.dy_night_club_data:GetLineupData(self.lineup_id)
                        self:InitMasterPanel()
                    end
                end)
            end,
        }
        SpecMgrs.ui_mgr:ShowItemUseRemindByTb(data)
    else
        SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.STRENGTHEN_MATERIAL_NOT_ENOUGH)
    end
end

function StrenghthenMasterUI:CalcEasyStrengthenCost()
    local strengthen_lv_limit = CSConst.StrengthenLimitRate * ComMgrs.dy_data_mgr:ExGetRoleLevel()
    local total_money = ComMgrs.dy_data_mgr:ExGetCurrencyCount(self.strengthen_cost_item)
    local total_cost = 0
    for i, part_data in ipairs(SpecMgrs.data_mgr:GetAllEquipPartData()) do
        if part_data.part_type == CSConst.EquipPartType.Equip then
            local equip_info = self.dy_bag_data:GetBagItemDataByGuid(self.lineup_data.equip_dict[i])
            if equip_info.strengthen_lv < strengthen_lv_limit then
                local cur_cost = 0
                local cur_add_lv = equip_info.strengthen_lv + 1
                while total_cost + cur_cost < total_money and cur_add_lv <= strengthen_lv_limit do
                    total_cost = total_cost + cur_cost
                    cur_cost = CSFunction.get_equip_strengthen_cost(equip_info.item_id, cur_add_lv)
                    cur_add_lv = cur_add_lv + 1
                end
                if cur_add_lv <= strengthen_lv_limit then return total_cost end
            end
        end
    end
    return total_cost
end

function StrenghthenMasterUI:ClearAttrAndEquipItem()
    for _, attr_item in ipairs(self.attr_item_list) do
        self:DelUIObject(attr_item)
    end
    self.attr_item_list = {}
    for _, equip_item in ipairs(self.equip_item_list) do
        equip_item:SetActive(false)
    end
end

return StrenghthenMasterUI