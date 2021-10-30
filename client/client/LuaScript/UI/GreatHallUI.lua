local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local GreatHallUI = class("UI.GreatHallUI", UIBase)
local SoundConst = require("Sound.SoundConst")
local UIFuncs = require("UI.UIFuncs")

GreatHallUI.need_sync_load = true

function GreatHallUI:DoInit()
    GreatHallUI.super.DoInit(self)
    self.prefab_path = "UI/Common/GreatHallUI"
    self.great_hall_data = ComMgrs.dy_data_mgr.great_hall_data
    self.hall_info_item = SpecMgrs.data_mgr:GetParamData("hall_info_item").item_id
    self.hall_info_item_data = SpecMgrs.data_mgr:GetItemData(self.hall_info_item)
end

function GreatHallUI:OnGoLoadedOk(res_go)
    GreatHallUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function GreatHallUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    GreatHallUI.super.Show(self)
end

function GreatHallUI:InitRes()
    -- 初始化主面板
    local main_panel = self.main_panel
    self.bg_img = main_panel:GetComponent("Image") -- Todo 背景会变化，根据什么待定
    local top_bar = main_panel:FindChild("TopBar")
    UIFuncs.InitTopBar(self, top_bar, "GreatHallPanel")
    self.unit_parent = self.go:FindChild("Bg/UnitParent")
    local btn_list = main_panel:FindChild("Btn_List")
    self:AddClick(btn_list:FindChild("Recruit_Btn"), function()
    --Todo 招募界面
    end, SoundConst.SoundID.SID_SecondBtnClick)

    self.back_icon_image = main_panel:FindChild("Head"):GetComponent("Image")

    --info_btn
    self.info_btn = btn_list:FindChild("Info_Btn")
    self.info_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.HANDLE_INFO
    self:AddClick(self.info_btn, function()
        self:InfoBtnOnClick()
    end, SoundConst.SoundID.SID_SecondBtnClick)

    self.info_cool_go = self.info_btn:FindChild("Cool_Time")
    self.info_cool_text_go = self.info_cool_go:FindChild("Text")
    self.info_cool_text = self.info_cool_text_go:GetComponent("Text")

    --cmd_btn
    self.cmd_btn = btn_list:FindChild("Cmd_Btn")
    self.cmd_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.HANDLE_CMD
    self:AddClick(self.cmd_btn, function()
        SpecMgrs.ui_mgr:ShowUI("HandleCmdUI")
    end, SoundConst.SoundID.SID_SecondBtnClick)
    self.main_panel:FindChild("BottonBar/Text"):GetComponent("Text").text = UIConst.Text.GREAT_HALL_TIP
end

function GreatHallUI:_UpdateDefaultUnit()
    local unit_id = SpecMgrs.data_mgr:GetParamData("party_default_unit").unit_id
    self:RemoveUnit(self.unit)
    self.unit_id = unit_id
    self.unit = self:AddFullUnit(unit_id, self.unit_parent)
end

function GreatHallUI:InitUI()
    self.great_hall_data:RegisterUpdateInfoEvent("GreatHallUI", function ()
        self:_UpdateInfoCooling()
    end)
    self:RegisterEvent(ComMgrs.dy_data_mgr, "UpdateCurrencyEvent", function (_, currency)
        UIFuncs.UpdateCurrencyItemNum(self._item_to_text_list, currency)
    end)
    self:_UpdateDefaultUnit()
    local role_id = ComMgrs.dy_data_mgr:ExGetRoleId()
    local role_data = SpecMgrs.data_mgr:GetRoleLookData(role_id)
    local icon_id = SpecMgrs.data_mgr:GetUnitData(role_data.unit_id).back_icon
    self:AssignSpriteByIconID(icon_id, self.back_icon_image)
    self:_UpdateInfoCooling()
end

function GreatHallUI:InfoBtnOnClick()
    if self:_CheckInfoCount() then
        SpecMgrs.ui_mgr:ShowUI("HandleInfoUI")
    else
        if not UIFuncs.CheckItemCount(self.hall_info_item, 1, true) then return end
        local param_tb = {
            title = UIConst.Text.RECOVER_INFO,
            max_select_num = ComMgrs.dy_data_mgr:ExGetItemCount(self.hall_info_item),
            confirm_cb = function (select_num)
                self:SendUseHallItem(select_num)
            end,
            get_content_func = function(select_num)
                return self:GetSelectItemUseUIContent(select_num)
            end,
        }
        SpecMgrs.ui_mgr:ShowSelectItemUseByTb(param_tb)
    end
end

function GreatHallUI:Hide()
    self.great_hall_data:UnregisterUpdateInfoEvent("GreatHallUI")
    self.great_hall_data:UnregisterUpdateCmdEvent("GreatHallUI")
    GreatHallUI.super.Hide(self)
end

function GreatHallUI:_UpdateInfoCooling()
    local is_has_info = self:_CheckInfoCount()
    if self.is_has_info ~= is_has_info then
        self.info_cool_go:SetActive(not is_has_info)
        self.is_has_info = is_has_info
        if is_has_info then
            self:RemoveDynamicUI(self.info_cool_text_go)
        else
            self:_UpdateInfoCoolText()
        end
    end
end

function GreatHallUI:_CheckInfoCount()
    local count = self.great_hall_data:GetInfoCount()
    if count then
        return count > 0, count
    else
        return false
    end
end

function GreatHallUI:_UpdateInfoCoolText()
    local info_cool_time = self.great_hall_data:GetInfoCoolDownTime()
    if not info_cool_time then
        return
    end
    self:AddDynamicUI(self.info_cool_text_go, function(active_time)
        local cool_time = info_cool_time - active_time
        self.info_cool_text.text = UIFuncs.TimeDelta2Str(cool_time,3)
    end, 1, 0)
end

function GreatHallUI:_CheckCmdCount(index)
    local count = self.great_hall_data:GetCmdCount(index)
    if count then
        return count > 0, count
    else
        return false
    end
end

function GreatHallUI:GetSelectItemUseUIContent(select_num)
    local content_tb = {}
    content_tb.item_dict = {[self.hall_info_item] = select_num}
    local item_name = SpecMgrs.data_mgr:GetItemData(self.hall_info_item).name
    content_tb.desc_str = string.format(UIConst.Text.RECOVER_INFO_TEXT, select_num, item_name, select_num)
    return content_tb
end

function GreatHallUI:SendUseHallItem(select_num)
    local param_tb = {item_id = self.hall_info_item, count = select_num}
    SpecMgrs.msg_mgr:SendMsg("SendUseHallItem", param_tb)
end

return GreatHallUI