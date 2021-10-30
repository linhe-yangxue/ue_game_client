local UIBase = require("UI.UIBase")
local UIFuncs = require("UI.UIFuncs")
local UnitConst = require("Unit.UnitConst")

local HudUI = class("UI.HudUI",UIBase)

local kComboShowTime = 10
local kComboEffectDuration = 0.2

local kHudTypePreText = {
    [UnitConst.UNITHUD_TYPE.Hurt] = "-",
    [UnitConst.UNITHUD_TYPE.HurtCritical] = "-",
    [UnitConst.UNITHUD_TYPE.Cure] = "+",
    [UnitConst.UNITHUD_TYPE.TotalHurt] = "s",
}

function HudUI:DoInit()
    HudUI.super.DoInit(self)
    self.prefab_path = "UI/Common/HudUI"
    self.hud_temp_dict = {}    -- hud_type索引飘字预设
    self.cache_hud_list = {}
    self.hud_parent_tb = {}
    self.combo_hud_tb = {}
end

function HudUI:OnGoLoadedOk(res_go)
    HudUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
end

function HudUI:InitRes()
    self.hud_panel = self.main_panel:FindChild("Hud")
    local temp_group = self.main_panel:FindChild("Temp")
    self.default_combo_pos = temp_group:FindChild("HudCombo").localPosition
    for type_name, hud_type in pairs(UnitConst.UNITHUD_TYPE) do
        self.hud_temp_dict[hud_type] = temp_group:FindChild("Hud" .. type_name)
    end
    for _, data in ipairs(self.cache_hud_list) do
        self:ShowHud(data)
    end
    temp_group:SetActive(false)
end

-- hud_type 飘字类型, value 飘字数值, point_go 目标点物体(取位置), offset 位置偏移
-- is_in_battle 战斗状态
-- 连击: guid, value 单段攻击总伤害, target_count 单段攻击目标数量
-- 技能: spell_id
function HudUI:ShowHud(data)
    if not self.is_res_ok then
        table.insert()
        return
    end
    if not self:IsVisible() then return end
    if data.hud_type == UnitConst.UNITHUD_TYPE.Combo or data.hud_type == UnitConst.UNITHUD_TYPE.TotalCure then
        self:ShowComboItem(data)
        return
    end

    if not data.point_go then return end
    local pos = data.point_go.position
    if data.is_in_battle == true then
        local main_camera_cmp = SpecMgrs.camera_mgr:GetMainCamera():GetComponent("Camera")
        local main_camera_pos = main_camera_cmp:WorldToViewportPoint(pos)
        local ui_camera_cmp = SpecMgrs.camera_mgr:GetUICamera():GetComponent("Camera")
        pos = ui_camera_cmp:ViewportToWorldPoint(main_camera_pos)
    end
    local temp = self.hud_temp_dict[data.hud_type]
    if not temp then return end
    local item = self:GetUIObject(temp, self:GetHudParent(data.hud_type))

    if data.hud_type == UnitConst.UNITHUD_TYPE.Spell then
        -- img item
        local spell_data = SpecMgrs.data_mgr:GetSpellData(data.spell_id)
        UIFuncs.AssignSpriteByIconID(spell_data.icon, item:FindChild("Image"):GetComponent("Image"))
    elseif data.value then
        -- text item
        data.value = (kHudTypePreText[data.hud_type] or "") .. math.floor(math.abs(data.value or 0))
        item:FindChild("Text"):GetComponent("Text").text = data.value
    end

    self:AddListener(item, function ()
        self:RemoveListener(item)
        self:DelUIObject(item)
    end)
    item:GetComponent("UIHudText"):ShowHud(pos, data.offset or Vector2.zero)
end

function HudUI:GetHudParent(hud_type)
    if not self.hud_parent_tb[hud_type] then
        local go = GameObject.New(hud_type)
        local go_rect = go:AddComponent(UnityEngine.RectTransform)
        go:SetParent(self.hud_panel, false)
        go_rect.sizeDelta = self.hud_panel:GetComponent("RectTransform").rect.size
        local index = 0
        for i = 1, hud_type do
            if self.hud_parent_tb[i] then index = index + 1 end
        end
        go:SetSiblingIndex(index)
        self.hud_parent_tb[hud_type] = go
    end
    return self.hud_parent_tb[hud_type]
end

function HudUI:ShowComboItem(data)
    if not self.combo_hud_tb[data.guid] then
        local item = self:GetUIObject(self.hud_temp_dict[data.hud_type])
        local parent = self:GetHudParent(data.hud_type)
        item:SetParent(parent, false)
        if data.point_go then item.localPosition = self.default_combo_pos end
        item:GetComponent("UIHudText"):ShowHud(data.point_go and data.point_go.position or item.position, data.offset or Vector2.zero)
        self.combo_hud_tb[data.guid] = {item = item, combo_count = 0, combo_hurt = 0}
    end
    local item_data = self.combo_hud_tb[data.guid]
    item_data.show_time = kComboShowTime
    item_data.combo_count = item_data.combo_count + (data.target_count or 1)
    item_data.combo_hurt = item_data.combo_hurt + math.floor(data.value)
    local combo_text = item_data.item:FindChild("ComboText")
    if combo_text then
        local count_text = (kHudTypePreText[data.hud_type] or "") .. item_data.combo_count
        combo_text:GetComponent("Text").text = count_text
    end
    local hurt_text = (kHudTypePreText[UnitConst.UNITHUD_TYPE.TotalHurt] or "") .. item_data.combo_hurt
    if item_data.combo_hurt == 0 then -- 伤害为0 不显示
        item_data.item:FindChild("HurtText"):GetComponent("Text").text = ""
    else
        item_data.item:FindChild("HurtText"):GetComponent("Text").text = hurt_text
    end

    -- if data.hud_type == UnitConst.UNITHUD_TYPE.Combo then
    --     local combo_effect = item_data.item:FindChild("Image")
    --     if self.combo_effect_timer then
    --         combo_effect:SetActive(false)
    --         self.combo_effect_timer = nil
    --     else
    --         combo_effect:SetActive(true)
    --         self.combo_effect_timer = SpecMgrs.timer_mgr:AddTimer(function ()
    --             combo_effect:SetActive(false)
    --             self.combo_effect_timer = nil
    --         end, kComboEffectDuration, 1)
    --     end
    -- end
end

function HudUI:DelComboItem(guid)
    local item_data = self.combo_hud_tb[guid]
    if item_data then
        local unit = ComMgrs.unit_mgr:GetUnitByGuid(guid)
        if unit then
            unit:UnregisterUnitDestroyEvent("HudUI")
        end
        -- if item_data.hud_type == UnitConst.UNITHUD_TYPE.Combo then
        --     item_data.item:FindChild("Image"):SetActive(false)
        --     self.combo_effect_timer = nil
        -- end
        self:DelUIObject(item_data.item)
        self.combo_hud_tb[guid] = nil
    end
end

function HudUI:Update(delta_time)
    if next(self.combo_hud_tb) then
        for guid, item_data in pairs(self.combo_hud_tb) do
            item_data.show_time = item_data.show_time - delta_time
            if item_data.show_time <= 0 then
                self:DelComboItem(guid)
            end
        end
    end
end

return HudUI