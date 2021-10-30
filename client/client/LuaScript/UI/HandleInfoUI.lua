local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local UIFuncs = require("UI.UIFuncs")
local HandleInfoUI = class("UI.HandleInfoUI",UIBase)
local SoundConst = require("Sound.SoundConst")
HandleInfoUI.need_sync_load = true

local custom_event_map = {
    SealAnimStop = "SealAnimStop",
    FlipAnimStop = "FlipAnimStop",
}

local kBeginRotationZ = 0
local kEndRotationZ = 90
local kRotationTime = 0.3

function HandleInfoUI:DoInit()
    HandleInfoUI.super.DoInit(self)
    self.prefab_path = "UI/Common/HandleInfoUI"
    self.dy_great_hall_data = ComMgrs.dy_data_mgr.great_hall_data
    self.info_comp_dict = {} -- {old = {[1] = }, new = {[1]}}
    self.info_cache = {}
    self.anim_timer = nil -- 计时器
end

function HandleInfoUI:OnGoLoadedOk(res_go)
    HandleInfoUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function HandleInfoUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    HandleInfoUI.super.Show(self)
end

function HandleInfoUI:Update(delta_time)
    if not self.is_res_ok then return end
    if self.anim_timer then
        self.anim_timer = self.anim_timer + delta_time
        local target_rotation_z
        if self.anim_timer >= kRotationTime then
            target_rotation_z = kBeginRotationZ
            self:_UpdateInfoComp(self.info_comp_dict.old_info, self.info_cache)
            self.anim_timer = nil
            self.wait_for_anim = nil
            self:SetCloseBtn(true)
        else
            target_rotation_z = tween.easing.inOutQuad(self.anim_timer, kBeginRotationZ, kEndRotationZ, kRotationTime)
        end
        self.rotation_point_rect.localRotation = Quaternion.Euler(0, 0, target_rotation_z)
    end
end

function HandleInfoUI:InitRes()
    self.close_bg_btn = self.main_panel:FindChild("CloseBg"):GetComponent("Button")
    self:AddClick(self.main_panel:FindChild("CloseBg"), function ()
        SpecMgrs.ui_mgr:HideUI(self)
    end, SoundConst.SoundID.SID_CLoseBtnClick)
    self.close_btn = self.main_panel:FindChild("CloseBtn"):GetComponent("Button")
    self:AddClick(self.main_panel:FindChild("CloseBtn"), function ()
        SpecMgrs.ui_mgr:HideUI(self)
    end, SoundConst.SoundID.SID_CLoseBtnClick)
    self.rotation_point_rect = self.main_panel:FindChild("Content/Book/RotationPoint"):GetComponent("RectTransform")
    self.info_comp_dict.new_info = {}
    self.info_comp_dict.old_info = {}
    local old_info = self.main_panel:FindChild("Content/Book/RotationPoint/OldInfo")
    old_info:FindChild("Tile/Text"):GetComponent("Text").text = UIConst.Text.HANDLE_INFO
    local comp_dict = self.info_comp_dict.old_info
    comp_dict.info_count = old_info:FindChild("Tile/Image1/Count"):GetComponent("Text")
    comp_dict.bg_icon = old_info:FindChild("Bg"):GetComponent("Image")
    comp_dict.hero_icon = old_info:FindChild("Bg/BlackBg/Hero_Part/Icon"):GetComponent("Image")
    comp_dict.hero_name = old_info:FindChild("Bg/BlackBg/Hero_Part/Name"):GetComponent("Text")
    comp_dict.info_des1 = old_info:FindChild("Bg/BlackBg/Text"):GetComponent("Text")
    comp_dict.info_des2 = old_info:FindChild("InfoDescription"):GetComponent("Text")

    comp_dict.select_text_list = {}
    comp_dict.select_btn = {}

    local select_go1 = old_info:FindChild("SelectList/Select1")
    self:AddClick(select_go1, function ()
        self:SelectBtnOnClick(1)
    end)
    comp_dict.select_text_list[1] = select_go1:FindChild("Text"):GetComponent("Text")
    comp_dict.select_btn[1] = select_go1

    local select_go2 = old_info:FindChild("SelectList/Select2")
    self:AddClick(select_go2, function ()
        self:SelectBtnOnClick(2)
    end)
    comp_dict.select_btn[2] = select_go2
    comp_dict.select_text_list[2] = select_go2:FindChild("Text"):GetComponent("Text")

    local new_info = self.main_panel:FindChild("Content/Book/RotationPoint/NewInfo")
    new_info:FindChild("Tile/Text"):GetComponent("Text").text = UIConst.Text.HANDLE_INFO
    local comp_dict = self.info_comp_dict.new_info

    comp_dict.info_count = new_info:FindChild("Tile/Image1/Count"):GetComponent("Text")
    comp_dict.hero_icon = new_info:FindChild("Bg/BlackBg/Hero_Part/Icon"):GetComponent("Image")
    comp_dict.bg_icon = new_info:FindChild("Bg"):GetComponent("Image")
    comp_dict.hero_name = new_info:FindChild("Bg/BlackBg/Hero_Part/Name"):GetComponent("Text")
    comp_dict.info_des1 = new_info:FindChild("Bg/BlackBg/Text"):GetComponent("Text")
    comp_dict.info_des2 = new_info:FindChild("InfoDescription"):GetComponent("Text")
    comp_dict.select_text_list = {}
    comp_dict.select_text_list[1] = new_info:FindChild("SelectList/Select1/Text"):GetComponent("Text")
    comp_dict.select_text_list[2] = new_info:FindChild("SelectList/Select2/Text"):GetComponent("Text")
end

--播放印章动画和翻页动画
function HandleInfoUI:_PlayInfoEffect()
    if self:_CheckInfoCount() then
        self.anim_timer = 0
        self:_UpdateInfoCache()
        self:_UpdateInfoComp(self.info_comp_dict.new_info, self.info_cache) --
    else
        SpecMgrs.ui_mgr:HideUI(self)
    end
end

function HandleInfoUI:SetCloseBtn(is_on)
    self.close_btn.interactable = is_on
    self.close_bg_btn.interactable = is_on
end

function HandleInfoUI:InitUI()
    self:SetCloseBtn(true)
    self:_UpdateInfoCache()
    self:_UpdateInfoComp(self.info_comp_dict.old_info, self.info_cache)
end

function HandleInfoUI:Hide()
    self.anim_timer = nil
    self.wait_for_anim = nil
    HandleInfoUI.super.Hide(self)
end

function HandleInfoUI:_UpdateInfoCache()
    self.info_cache = {}
    local info_cache = self.info_cache
    local info_hero_id = ComMgrs.dy_data_mgr:ExGetRandomHeroID()
    if info_hero_id then
        info_cache.hero_data = SpecMgrs.data_mgr:GetHeroData(info_hero_id)
    end
    local serv_info_data = self.dy_great_hall_data:GetInfoData()
    info_cache.item_id = serv_info_data.item_id
    info_cache.count = serv_info_data.count
    info_cache.info_data = SpecMgrs.data_mgr:GetInfoData(serv_info_data.info_id)
    if not info_cache.info_data then PrintError("info data don't have info_id ", serv_info_data.info_id) end
    info_cache.info_count_str = string.format(UIConst.Text.SPRIT, self:_GetInfoCount(), self:_GetInfoMaxCount())
end

function HandleInfoUI:_UpdateInfoComp(comp_dict, info_cache)
    local hero_data = info_cache.hero_data
    if hero_data then
        local unit_data = SpecMgrs.data_mgr:GetUnitData(hero_data.unit_id)
        self:AssignSpriteByIconID(unit_data.icon, comp_dict.hero_icon)
        comp_dict.hero_name.text = hero_data.name
    end
    comp_dict.info_count.text = info_cache.info_count_str
    local info_data = info_cache.info_data
    comp_dict.info_des1.text = info_data.info_content[1]
    comp_dict.info_des2.text = info_data.info_content[2]
    self:AssignSpriteByIconID(info_data.bg, comp_dict.bg_icon)
    -- 选项一，根据服务器给的奖励来定
    if comp_dict.select_text_list then
        local select_str1 = self:_GetSelectStr(info_data.select_content1, info_cache.item_id, info_cache.count)
        comp_dict.select_text_list[1].text = select_str1
        --选项二，根据自己的等级获得经验值
        local select_str2 = self:_GetSelectStr(info_data.select_content2, CSConst.Virtual.Exp, self.dy_great_hall_data:GetInfoExp())
        comp_dict.select_text_list[2].text = select_str2
    end
end

function HandleInfoUI:_GetSelectStr(content_str, item_id, item_count)
    local tb = {item_id = item_id, change_name_color = true}
    local str = string.render(UIConst.Text.INFO_REWARD, {
        color = UIFuncs.GetQualityColorStr(tb),
        s1 = content_str,
        s2 = UIFuncs.GetItemName(tb),
        s3 = item_count,})
    return str
end

function HandleInfoUI:_CheckInfoCount()
    local count = self:_GetInfoCount()
    if count then
        return count > 0
    else
        return false
    end
end

function HandleInfoUI:_GetInfoCount()
    return self.dy_great_hall_data:GetInfoCount()
end

function HandleInfoUI:_GetInfoMaxCount()
    return self.dy_great_hall_data:GetInfoMaxCount()
end

function HandleInfoUI:SelectBtnOnClick(index)
    if not self:_CheckInfoCount() then end
    if self.wait_for_anim then return end
    self.wait_for_anim = true
    self:SetCloseBtn(false)
    SpecMgrs.msg_mgr:SendMsg("SendHandleInfo", {id = index}, function(resp)
        if not self.is_res_ok then return end
        self:_PlayInfoEffect()
    end)
end

return HandleInfoUI