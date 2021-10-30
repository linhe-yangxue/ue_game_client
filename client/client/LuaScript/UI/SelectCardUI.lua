local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local SelectCardUI = class("UI.SelectCardUI",UIBase)
local kDelayTime = 0.2

function SelectCardUI:DoInit()
    SelectCardUI.super.DoInit(self)
    self.prefab_path = "UI/Common/SelectCardUI"
    self.card_list = {}
    self.card_no_selected_icon = SpecMgrs.data_mgr:GetParamData("card_no_selected").icon
    self.card_selected_icon = SpecMgrs.data_mgr:GetParamData("card_selected").icon
end

function SelectCardUI:OnGoLoadedOk(res_go)
    SelectCardUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function SelectCardUI:Show(param_tb)
    self.send_func_name = param_tb.send_func_name
    if self.is_res_ok then
        self:InitUI()
    end
    SelectCardUI.super.Show(self)
    self:ResetCard()
end

function SelectCardUI:InitRes()
    self.card_item_parent = self.main_panel:FindChild("CardList")
    self.card_item_temp = self.card_item_parent:FindChild("Temp")
    local item_parent = self.card_item_temp:FindChild("CardFront/Item")
    UIFuncs.GetIconGo(self, item_parent, nil, UIConst.PrefabResPath.ItemWithName1)
    self.card_item_temp:SetActive(false)
    self.main_panel:FindChild("CardList/Top/Title"):GetComponent("Text").text = UIConst.Text.SELECT_CARD_TIPS
    self.get_item_text = self.main_panel:FindChild("CardList/Bottom/Text"):GetComponent("Text")
    self:AddClick(self.main_panel:FindChild("Bg"),function ()
        if self.has_selected then
            self:Hide()
        end
    end)
end

function SelectCardUI:ResetCard()
    for i = 1, self.card_num do
        self.card_list[i]:GetComponent("Animator"):SetBool("is_play", false)
        self:AssignSpriteByIconID(self.card_no_selected_icon, self.card_list[i]:FindChild("CardFront"):GetComponent("Image"))
    end
end

function SelectCardUI:InitUI()
    self:ClearAllItem()
    self.card_num = SpecMgrs.data_mgr:GetParamData("card_num").f_value
    for i = 1, self.card_num do
        local go = self:GetUIObject(self.card_item_temp, self.card_item_parent)
        go:FindChild("Btn"):SetActive(true)
        table.insert(self.card_list, go)
        self:AddClick(go:FindChild("Btn"), function ()
            self:CardOnClick(i)
            go:FindChild("Btn"):SetActive(false)
        end)

    end
    self.get_item_text.gameObject:SetActive(false)
end

function SelectCardUI:Hide()
    self:ClearAllItem()
    self:ClearTimer()
    self.select_index = nil
    self.has_selected = nil
    SelectCardUI.super.Hide(self)
end

function SelectCardUI:CardOnClick(index)
    if self.select_index then return end
    self.select_index = index
    self:AssignSpriteByIconID(self.card_selected_icon, self.card_list[index]:FindChild("CardFront"):GetComponent("Image"))
    if self.select_cb then
        self.select_cb(index)
    end
    local func = SpecMgrs.msg_mgr[self.send_func_name]
    if not func then
        PrintError("There is no func", self.send_func_name)
    else
        func(SpecMgrs.msg_mgr, {reward_index = index}, function (resp)
            if resp.errcode ~= 0 then
                PrintError("Get wrong errcode from serv SendGrabTreasuerSelectReward reward_index", index)
                return
            end
            self:StartAnim(resp.reward_list)
        end)
    end
end

function SelectCardUI:StartAnim(reward_list)
    for i = 1, self.card_num do
        local go = self.card_list[i]:FindChild("CardFront/Item/Item")
        local tb = {go = go, item_id = reward_list[i].item_id, count = reward_list[i].count, ui = self}
        UIFuncs.InitItemGo(tb)
        self.card_list[i]:GetComponent("Animator"):SetBool("is_play", true)
    end
    self.wait_for_anim_end_timer = SpecMgrs.timer_mgr:AddTimer(function ()
        self.wait_for_anim_end_timer = nil
        self.get_item_text.gameObject:SetActive(true)
        local item_name = UIFuncs.GetItemName({item_id = reward_list[self.select_index].item_id, is_on_dark_bg = true})
        self.get_item_text.text = string.format(UIConst.Text.GET_ITME_TEXT,item_name)
        self.has_selected = true
    end, kDelayTime, 1)
end

function SelectCardUI:ClearTimer()
    if self.wait_for_anim_end_timer then
        SpecMgrs.timer_mgr:RemoveTimer(self.wait_for_anim_end_timer)
        self.wait_for_anim_end_timer = nil
    end
end

function SelectCardUI:ClearAllItem ()
    for _, go in ipairs(self.card_list) do
        self:DelUIObject(go)
    end
    self.card_list = {}
end

return SelectCardUI
