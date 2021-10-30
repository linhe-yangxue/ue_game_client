local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local SelectFlagUI = class("UI.SelectFlagUI",UIBase)

local my_flag_type = 2

--  选择旗帜
function SelectFlagUI:DoInit()
    SelectFlagUI.super.DoInit(self)
    self.prefab_path = "UI/Common/SelectFlagUI"
end

function SelectFlagUI:OnGoLoadedOk(res_go)
    SelectFlagUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function SelectFlagUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    SelectFlagUI.super.Show(self)
end

function SelectFlagUI:InitRes()
    local panel = self.main_panel:FindChild("Panel")
    panel:FindChild("Title/Text"):GetComponent("Text").text = UIConst.Text.SELECT_FLAG
    self.confirm_btn = panel:FindChild("ConfirmBtn")
    self:AddCooldownClick(self.confirm_btn, function()
        self:ClickConfirmBtn()
    end)
    self.confirm_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.START_GAME
    self.flay_icon = panel:FindChild("CurFlag/FlayIcon"):GetComponent("Image")
    self.content = panel:FindChild("ViewPort/Content")
    self.flag_item = self.content:FindChild("FlagItem")
    self.flag_item:SetActive(false)
end

function SelectFlagUI:InitUI()
    self:ClearRes()
    self:UpdateData()
    self:UpdateUIInfo()
    self.flag_selector:SelectObj(1)
end

function SelectFlagUI:UpdateData()
    self.flag_data_list = {}
    for i,v in ipairs(SpecMgrs.data_mgr:GetAllFlagData()) do
        if v.type == my_flag_type then
            table.insert(self.flag_data_list, v)
        end
    end
end

function SelectFlagUI:UpdateUIInfo()
    for i, v in ipairs(self.flag_data_list) do
        local item = self:GetUIObject(self.flag_item, self.content)
        UIFuncs.AssignSpriteByIconID(v.icon, item:FindChild("Icon"):GetComponent("Image"))
        table.insert(self.flag_obj_list, item)
    end
    self.flag_selector = UIFuncs.CreateSelector(self, self.flag_obj_list, function(i)
        self.select_flag_data = self.flag_data_list[i]
        UIFuncs.AssignSpriteByIconID(self.flag_data_list[i].icon, self.flay_icon)
    end)
end

function SelectFlagUI:ClickConfirmBtn()
    SpecMgrs.msg_mgr:SendModifyRoleFlag({flag_id = self.select_flag_data.id}, function(resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.CONNECT_SERVER_WRONG)
        else
            SpecMgrs.stage_mgr:GotoStage("GuideStage")
        end
    end)
end

function SelectFlagUI:ClearRes()
    self.flag_selector = nil
    self:ClearGoDict("flag_obj_list")
end

function SelectFlagUI:Hide()
    self:ClearRes()
    SelectFlagUI.super.Hide(self)
end

return SelectFlagUI