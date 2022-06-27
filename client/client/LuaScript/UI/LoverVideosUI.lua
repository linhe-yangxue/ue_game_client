local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local UnitConst = require("Unit.UnitConst")
local LoverVideosUI = class("UI.LoverVideosUI",UIBase)

local sync_num = 9
local redpoint_control_id_list = {
    CSConst.RedPointControlIdDict.LoverSkill,
    CSConst.RedPointControlIdDict.LoverStar
}

-- 后宫列表ui
function LoverVideosUI:DoInit()
    LoverVideosUI.super.DoInit(self)
    self.prefab_path = "UI/Common/LoverVideosUI"
    self.star_limit = SpecMgrs.data_mgr:GetParamData("lover_star_lv_limit").f_value
    self.lover_video_data = SpecMgrs.data_mgr:GetAllLoverPortrait()
    self.lover_data = ComMgrs.dy_data_mgr.lover_data
    self.lover_id2lover_card = {}
    self.grid_column_count = 3
    self.lover_card_list_top = 30
    self.lover_card_list_y_spacing = 28
    self.lover_redpoint_list = {}
    self.cur_frame_obj_list = {}
end

function LoverVideosUI:OnGoLoadedOk(res_go)
    LoverVideosUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function LoverVideosUI:Show(param_tb)
    self.data = param_tb
    self.own_lover_videos = self.data.own_lover_videos
    self.impersonal_lover_videos = self.data.impersonal_lover_videos
    if self.is_res_ok then
        self:InitUI()
    end
    LoverVideosUI.super.Show(self)
end

function LoverVideosUI:InitRes()
    self:InitTopBar()
    --  下方信息
    local show_lover_panel = self.main_panel:FindChild("ShowLoverPanel")

    --  妃子列表
    local lover_frame = show_lover_panel:FindChild("LoverFrame")
    self.lover_card = lover_frame:FindChild("Temp/LoverCard")
    self.possess_title = lover_frame:FindChild("Temp/PossessTitle")
    self.not_possess_title = lover_frame:FindChild("Temp/NotPossessTitle")
    self.row_grid = lover_frame:FindChild("Temp/RowGrid")
    self.lover_card_rect = self.lover_card:GetComponent("RectTransform")

    self.lover_content = lover_frame:FindChild("LoverList/Viewport/Content")
    self.lover_content_rect = lover_frame:FindChild("LoverList/Viewport/Content"):GetComponent("RectTransform")

    self.flop_anim_first = show_lover_panel:FindChild("ui_lover_chouka_1")
    self.flop_anim_second = self.main_panel:FindChild("ui_lover_chouka_2")
    self.video_title_text = show_lover_panel:FindChild("VideoTitle/Text"):GetComponent("Text")
    --self.anim_mask = self.main_panel:FindChild("AnimMask")

    self.lover_card:SetActive(false)
end

function LoverVideosUI:InitUI()
    self.not_possess_lover_tb = {}
    self.process_tb = {}
    self.create_obj_list = {}
    self.load_num = 0
    self:UpdateUIInfo()
end

function LoverVideosUI:UpdateUIInfo()
    self.lover_discuss_recover_item = SpecMgrs.data_mgr:GetParamData("lover_discuss_recover_item").item_id
    self.lover_info_tb = self.own_lover_videos
    self.not_possess_lover_tb = self.impersonal_lover_videos
    local not_possess_num = #self.not_possess_lover_tb
    local possess_num = #self.lover_info_tb
    local total_number = not_possess_num + possess_num
    self.video_title_text.text = "已激活：" .. possess_num .. "/" .. total_number
    --  妃子列表布局
    self.lover_card_y = self.lover_card_rect.sizeDelta.y
    self:CreateRow(self.row_grid, self.lover_card, possess_num, not_possess_num)
end

function LoverVideosUI:Update()

end

--创建视频列表
function LoverVideosUI:CreateRow(row_grid_temp, lover_temp, lover_num, not_lover_num)
    local row_grid_obj = self:GetUIObject(row_grid_temp, self.lover_content, false)
    table.insert(self.create_obj_list, row_grid_obj)
    for i = 1, lover_num do
        local lover_id = self.lover_info_tb[i].lover_id
        local obj = self:GetUIObject(lover_temp, row_grid_obj , false)
        table.insert(self.create_obj_list, obj)

        self:SetLoverCardMsg(obj, lover_id, self.lover_info_tb[i].video_name,self.lover_video_data[self.lover_info_tb[i].video_id])
        local lover_gift_btn = obj:FindChild("ButtonGift")
        local lover_gift_btn_img = lover_gift_btn:FindChild("Image"):GetComponent("Image")
        if self.lover_info_tb[i].reward_status == 0 then
            UIFuncs.AssignUISpriteSync("UIRes/LoverGift/gift01", "gift01", lover_gift_btn_img)
        else
            UIFuncs.AssignUISpriteSync("UIRes/LoverGift/gift01_1", "gift01_1", lover_gift_btn_img)
        end

        self:AddClick(lover_gift_btn, function ()
            if self.lover_info_tb[i].reward_status == 0 then
                SpecMgrs.msg_mgr:SendLoverVideosReward({lover_video_id = self.lover_info_tb[i].video_id}, function (resp)
                    if resp.errcode == 0 then
                        self.lover_info_tb[i].reward_status = resp.reward_status
                        UIFuncs.AssignUISpriteSync("UIRes/LoverGift/gift01_1", "gift01_1", lover_gift_btn_img)
                    end
                end)
            else
                SpecMgrs.ui_mgr:ShowMsgBox("该视频道具已领取！")
            end
        end)

        --spine角色添加
        self:SetLoverCardUnit(obj, lover_id)
        self.lover_id2lover_card[lover_id] = obj
        obj:FindChild("Mask"):SetActive(false)
        local lover_redpoint = SpecMgrs.redpoint_mgr:AddRedPoint(self, obj, CSConst.RedPointType.HighLight, redpoint_control_id_list, lover_id)
        table.insert(self.lover_redpoint_list, lover_redpoint)

    end
    for i = 1, not_lover_num do
        local lover_id = self.not_possess_lover_tb[i].lover_id
        local obj = self:GetUIObject(lover_temp, row_grid_obj , false)
        table.insert(self.create_obj_list, obj)
        self:SetNotPorcessCard(obj, self.not_possess_lover_tb[i],self.not_possess_lover_tb[i].video_name,self.lover_video_data[self.not_possess_lover_tb[i].video_id])
        obj:FindChild("Mask"):SetActive(true)
        self:SetLoverCardUnit(obj, lover_id)
    end
    local column_num = math.ceil(lover_num / self.grid_column_count)
    local grid_rect = row_grid_obj:GetComponent("RectTransform")
    local y_length = column_num * (self.lover_card_y + self.lover_card_list_y_spacing) + self.lover_card_list_top
    grid_rect.sizeDelta = Vector2.New(grid_rect.sizeDelta.x, y_length)
end

--未解锁的情人信息
function LoverVideosUI:SetNotPorcessCard(lover_card, not_possess_lover_tb, lover_card_name,reward_list)
    lover_card:FindChild("GiftStatus"):SetActive(true)
    lover_card:FindChild("GiftStatus"):GetComponent("Text").text = "未激活"
    lover_card:FindChild("TitleNameBg/NameText"):GetComponent("Text").text = lover_card_name
    local lover_video_Bg = lover_card:FindChild("videoBg"):GetComponent("Image")
    UIFuncs.AssignUISpriteSync("UIRes/LoverGift/videoBg1", "videoBg1", lover_video_Bg)
    local lover_gift_Play = lover_card:FindChild("ButtonPlay")
    lover_gift_Play:SetActive(true)
    self:AddClick(lover_gift_Play, function ()
        SpecMgrs.ui_mgr:ShowMsgBox("该视频还未解锁，敬请期待！")
    end)
    local item_check_list = lover_card:FindChild("ItemCheckList")
    local check_item_list = item_check_list:FindChild("ViewPort/CheckItemList")
    local item_bg = lover_card:FindChild("ItemBg")
    local item_list = reward_list.gift_item_list
    for i = #item_list, 1, -1 do
        local item = UIFuncs.SetItem(self, reward_list.gift_item_list[i], reward_list.gift_num_list[i], check_item_list)
        table.insert(self.cur_frame_obj_list, item)
    end
    local lover_gift_btn = lover_card:FindChild("ButtonGift")
    local lover_gift_btn_img = lover_gift_btn:FindChild("Image"):GetComponent("Image")
    UIFuncs.AssignUISpriteSync("UIRes/LoverGift/gift01", "gift01", lover_gift_btn_img)
    item_bg:SetActive(false)
    item_check_list:SetActive(false)
    not_possess_lover_tb["lover_gift_btn_status"] = 0
    self:AddClick(lover_gift_btn, function ()
        if not_possess_lover_tb.lover_gift_btn_status == 0 then
            item_bg:SetActive(true)
            item_check_list:SetActive(true)
            not_possess_lover_tb.lover_gift_btn_status = 1
        elseif not_possess_lover_tb.lover_gift_btn_status == 1 then
            item_bg:SetActive(false)
            item_check_list:SetActive(false)
            not_possess_lover_tb.lover_gift_btn_status = 0
        end

    end)
    self:AddClick(lover_card:FindChild("TriggerBtn"), function()
        if not_possess_lover_tb.lover_gift_btn_status == 1 then
            item_bg:SetActive(false)
            item_check_list:SetActive(false)
            not_possess_lover_tb.lover_gift_btn_status = 0
        end
    end)
end

--已解锁情人信息
function LoverVideosUI:SetLoverCardMsg(lover_card, lover_id, lover_card_name)
    lover_card:FindChild("GiftStatus"):SetActive(true)
    lover_card:FindChild("GiftStatus"):GetComponent("Text").text = "已拥有"
    lover_card:FindChild("TitleNameBg/NameText"):GetComponent("Text").text = lover_card_name
    local lover_video_Bg = lover_card:FindChild("videoBg"):GetComponent("Image")
    UIFuncs.AssignUISpriteSync("UIRes/LoverGift/videoBg1", "videoBg1", lover_video_Bg)
    local lover_gift_Play = lover_card:FindChild("ButtonPlay")
    lover_gift_Play:SetActive(true)
    self:AddClick(lover_gift_Play, function ()
        SpecMgrs.ui_mgr:ShowUI("LoverPlayUI",lover_id)
    end)
    local item_check_list = lover_card:FindChild("ItemCheckList")
    local item_bg = lover_card:FindChild("ItemBg")
    item_bg:SetActive(false)
    item_check_list:SetActive(false)
end

--创建spine模型
function LoverVideosUI:SetLoverCardUnit(lover_card, lover_id)
    local lover_image = lover_card:FindChild("LoverImage")
    self:CreateUnit(lover_id, lover_image)
end

--清除spine模型
function LoverVideosUI:CreateUnit(unit_id, lover_image)
    self.load_num = self.load_num + 1
    local unit
    if self.load_num > sync_num then
        unit = self:AddCardUnit(unit_id, lover_image, nil, nil, nil, true)
    else
        unit = self:AddCardUnit(unit_id, lover_image)
    end
    unit:StopAllAnimationToCurPos()
end

function LoverVideosUI:Hide()
    for _, redpoint in ipairs(self.lover_redpoint_list) do
        SpecMgrs.redpoint_mgr:RemoveRedPoint(redpoint)
        self.lover_redpoint_list = {}
    end
    self:DelObjDict(self.create_obj_list)
    for _, go in pairs(self.cur_frame_obj_list) do
        self:DelUIObject(go)
    end
    self.cur_frame_obj_list = {}
    LoverVideosUI.super.Hide(self)
end

return LoverVideosUI
