local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local ChangeFlagUI = class("UI.ChangeFlagUI",UIBase)

local my_flag_type = 2

--  选择旗帜
function ChangeFlagUI:DoInit()
    ChangeFlagUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ChangeFlagUI"
    self.cost_data = SpecMgrs.data_mgr:GetParamData("modify_role_flag_cost")
end

function ChangeFlagUI:OnGoLoadedOk(res_go)
    ChangeFlagUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function ChangeFlagUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    ChangeFlagUI.super.Show(self)
end

function ChangeFlagUI:InitRes()
    self:InitTopBar()
    self.title = self.main_panel:FindChild("Title")
    self.flag_title = self.main_panel:FindChild("FlagTitle")
    self.confirm_btn = self.main_panel:FindChild("ConfirmBtn")
    self:AddCooldownClick(self.confirm_btn, function()
        self:ClickConfirmBtn()
    end)
    self.confirm_btn_text = self.main_panel:FindChild("ConfirmBtn/Text"):GetComponent("Text")
    self.consume_text = self.main_panel:FindChild("ConsumeText")
    self.flay_icon = self.main_panel:FindChild("FlayIcon"):GetComponent("Image")
    self.content = self.main_panel:FindChild("ScrollRect/ViewPort/Content")
    self.flag_item = self.main_panel:FindChild("ScrollRect/ViewPort/Content/FlagItem")
    self.flag_item:SetActive(false)
end

function ChangeFlagUI:InitUI()
    self:ClearRes()
    self:SetTextVal()
    self:UpdateData()
    self:UpdateUIInfo()
    local cur_flag_id = ComMgrs.dy_data_mgr:ExGetRoleFlag()
    local select_index = self.flag_data_list[1].id ~= cur_flag_id and 1 or 2 -- 当前旗帜是第一个就选择第二个
    self.flag_selector:SelectObj(select_index)
end

function ChangeFlagUI:UpdateData()
    self.flag_data_list = {}
    for i,v in ipairs(SpecMgrs.data_mgr:GetAllFlagData()) do
        if v.type == my_flag_type then
            table.insert(self.flag_data_list, v)
        end
    end
end

function ChangeFlagUI:UpdateUIInfo()
    local icon_id = SpecMgrs.data_mgr:GetItemData(self.cost_data.item_id).icon
    self:SetTextPic(self.consume_text, string.format(UIConst.Text.COST_FORMAT, icon_id, self.cost_data.count))
    self.confirm_btn_text.text = UIConst.Text.CHANGE_FLAG_TEXT
    local cur_flag_id = ComMgrs.dy_data_mgr:ExGetRoleFlag()
    for i, v in ipairs(self.flag_data_list) do
        local item = self:GetUIObject(self.flag_item, self.content)
        local is_cur_flag = cur_flag_id == v.id
        item:FindChild("Using"):SetActive(is_cur_flag)
        item:GetComponent("Button").interactable = not is_cur_flag
        UIFuncs.AssignSpriteByIconID(v.icon, item:FindChild("Icon"):GetComponent("Image"))
        table.insert(self.flag_obj_list, item)
    end
    self.flag_selector = UIFuncs.CreateSelector(self, self.flag_obj_list, function(i)
        self.select_flag_data = self.flag_data_list[i]
        UIFuncs.AssignSpriteByIconID(self.flag_data_list[i].icon, self.flay_icon)
    end)
end

function ChangeFlagUI:SetTextVal()
    self.title:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SELECT_ICON
    self.flag_title:FindChild("Text"):GetComponent("Text").text = UIConst.Text.MY_FLAG
    self.flag_title:FindChild("Text"):GetComponent("Text").text = UIConst.Text.CHANGE_FLAG_TEXT
end

function ChangeFlagUI:ClickConfirmBtn()
    local flag_id = ComMgrs.dy_data_mgr:ExGetRoleFlag()
    if flag_id == self.select_flag_data.id then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.FLAG_SAME_TIP)
        return
    end

    local cost_data = {
        item_id = self.cost_data.item_id,
        need_count = self.cost_data.count,
        confirm_cb = function ()
            SpecMgrs.msg_mgr:SendModifyRoleFlag({flag_id = self.select_flag_data.id}, function(resp)
                if resp.errcode ~= 0 then
                    SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.CONNECT_SERVER_WRONG)
                else
                    SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.MODIFY_FLAG_SUCCESS)
                    SpecMgrs.ui_mgr:HideUI(self)
                end
            end)
        end,
        remind_tag = "ChangeFlagUI",
        title = UIConst.Text.CHANGE_FLAG_TEXT,
        desc = string.format(UIConst.Text.CHANGE_FLAG_FORMAT, SpecMgrs.data_mgr:GetItemData(self.cost_data.item_id).name, self.cost_data.count),
    }
    SpecMgrs.ui_mgr:ShowItemUseRemindByTb(cost_data)
end

function ChangeFlagUI:ClearRes()
    self:DelObjDict(self.flag_obj_list)
    self.flag_obj_list = {}
end

function ChangeFlagUI:Hide()
    self:ClearRes()
    ChangeFlagUI.super.Hide(self)
end

return ChangeFlagUI
