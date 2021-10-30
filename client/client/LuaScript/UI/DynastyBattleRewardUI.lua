local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")

local DynastyBattleRewardUI = class("UI.DynastyBattleRewardUI", UIBase)

function DynastyBattleRewardUI:DoInit()
    DynastyBattleRewardUI.super.DoInit(self)
    self.prefab_path = "UI/Common/DynastyBattleRewardUI"
    self.reward_item_dict = {}
    self.reward_list = {}
end

function DynastyBattleRewardUI:OnGoLoadedOk(res_go)
    DynastyBattleRewardUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
    self:InitUI()
end

function DynastyBattleRewardUI:Hide()
    self:ClearAllCompleteEffect()
    DynastyBattleRewardUI.super.Hide(self)
end

function DynastyBattleRewardUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    DynastyBattleRewardUI.super.Show(self)
end

function DynastyBattleRewardUI:InitRes()
    local first_pass_award_content = self.main_panel:FindChild("Content")
    first_pass_award_content:FindChild("Top/Text"):GetComponent("Text").text = UIConst.Text.CLEAR_CHAPTER_REWARD_TEXT
    self:AddClick(first_pass_award_content:FindChild("Top/CloseBtn"), function ()
        self:Hide()
    end)
    local reward_list_content = first_pass_award_content:FindChild("RewardList/View/Content")
    self.reward_list_rect = reward_list_content:GetComponent("RectTransform")
    local reward_item = reward_list_content:FindChild("Item")
    self.reward_item_height = reward_item:GetComponent("RectTransform").rect.height
    reward_item:FindChild("Bottom/Status/GetBtn/Text"):GetComponent("Text").text = UIConst.Text.RECEIVE_TEXT
    local reward_item_pref = reward_item:FindChild("Bottom/AwardItemList/View/Content/Item")
    for id, reward_data in ipairs(SpecMgrs.data_mgr:GetAllCompeteRewardData()) do
        local reward_item = self:GetUIObject(reward_item, reward_list_content)
        local data = {}
        data.item = reward_item
        reward_item:FindChild("Title/Text"):GetComponent("Text").text = reward_data.desc
        local status_panel = reward_item:FindChild("Bottom/Status")
        local not_pass = status_panel:FindChild("NotPass")
        data.not_pass = not_pass
        not_pass:FindChild("Text"):GetComponent("Text").text = UIConst.Text.NOT_CLEAR
        local get_btn = status_panel:FindChild("GetBtn")
        data.get_btn = get_btn
        get_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.RECEIVE_TEXT
        self:AddClick(get_btn, function ()
            self:SendGetCompeteReward(id)
        end)
        local already_get = status_panel:FindChild("AlreadyGet")
        data.already_get = already_get
        already_get:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ALREADY_RECEIVE_TEXT
        for i, item_id in ipairs(reward_data.reward_list) do
            local item = self:GetUIObject(reward_item_pref, reward_item:FindChild("Bottom/AwardItemList/View/Content"))
            table.insert(self.reward_list, item)
            UIFuncs.InitItemGo({
                ui = self,
                go = item,
                item_id = item_id,
                count = reward_data.reward_value_list[i],
                click_cb = function ()
                    SpecMgrs.ui_mgr:ShowItemPreviewUI(item_id)
                end,
            })
        end
        self.reward_item_dict[id] = data
    end
end

function DynastyBattleRewardUI:InitUI()
    self:InitFirstPassAwardPanel()
    self.reward_list_rect.anchoredPosition = Vector2.zero
end

function DynastyBattleRewardUI:InitFirstPassAwardPanel()
    SpecMgrs.msg_mgr:SendGetCompeteRewardInfo({}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_COMPETE_REWARD_LIST_FAILED)
        else
            self:ClearAllCompleteEffect()
            for id, _ in ipairs(SpecMgrs.data_mgr:GetAllCompeteRewardData()) do
                local reward_item = self.reward_item_dict[id]
                reward_item.get_btn:SetActive(resp.compete_reward ~= nil and resp.compete_reward[id] == true)
                if resp.compete_reward ~= nil and resp.compete_reward[id] == true then
                    reward_item.effect = UIFuncs.AddCompleteEffect(self, reward_item.get_btn)
                end
                reward_item.not_pass:SetActive(resp.compete_reward ~= nil and resp.compete_reward[id] == false)
                reward_item.already_get:SetActive(resp.compete_reward ~= nil and resp.compete_reward[id] == nil)
            end
        end
    end)
end

function DynastyBattleRewardUI:SendGetCompeteReward(id)
    SpecMgrs.msg_mgr:SendGetCompeteReward({reward_id = id}, function (resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowMsgBox(UIConst.Text.GET_COMPETE_REWARD_FAILED)
        else
            self:InitFirstPassAwardPanel()
        end
    end)
end

function DynastyBattleRewardUI:ClearAllCompleteEffect()
    for _, reward_item in pairs(self.reward_item_dict) do
        if reward_item.effect then
            self:RemoveUIEffect(reward_item.get_btn, reward_item.effect)
        end
    end
end

return DynastyBattleRewardUI