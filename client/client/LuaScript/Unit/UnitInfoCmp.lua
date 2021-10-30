local UnitConst = require("Unit.UnitConst")
local UIConst = require("UI.UIConst")

local UnitInfoCmp = class("Unit.UnitInfoCmp")

local kMaxAngerShowCount = 4

function UnitInfoCmp:DoInit(owner)
    self.owner = owner
    self.info_item_tb = {}
end

function UnitInfoCmp:InitByGo(go)
    self.info_point = go:FindChild("UnitInfo")
    if not self.info_point then
        PrintError("UnitInfoCmp: unit_info point not found")
    end
end

function UnitInfoCmp:ShowBloodBar()
    self.blood_bar = self.info_point:FindChild("BloodBar")
    if not self.blood_bar then
        PrintError("UnitInfoCmp: unit blood_bar not found")
        return
    end
    self.blood_bar:SetActive(true)
    self.blood_bar_value_cmp = self.blood_bar:FindChild("Value"):GetComponent("Transform")
    self.blood_bar_value_cmp_start_scale = self.blood_bar_value_cmp.localScale
    self:SetHpValue()
end

function UnitInfoCmp:HideBloodBar()
    if self.blood_bar then
        self.blood_bar:SetActive(false)
        self.blood_bar = nil
    end
end

function UnitInfoCmp:SetHpValue()
    local cur_scale = self.blood_bar_value_cmp.localScale
    cur_scale.x = self.blood_bar_value_cmp_start_scale.x * (self.owner:GetHp() / self.owner:GetMaxHp())
    self.blood_bar_value_cmp.localScale = cur_scale
end

function UnitInfoCmp:ShowName()
    self.name_go = self.info_point:FindChild("Name")
    if not self.name_go then
        PrintError("UnitInfoCmp: unit name_go not found")
        return
    end
    self.name_go:SetActive(true)

    local unit_name
    if self.owner.monster_id then
        local monster_data = SpecMgrs.data_mgr:GetMonsterData(self.owner.monster_id)
        unit_name = monster_data.name or SpecMgrs.data_mgr:GetHeroData(monster_data.hero_id).name
    else
        unit_name = self.owner.unit_name or self.owner.unit_data.name
    end
    self.name_go:GetComponent("TextMesh").text = unit_name
end

function UnitInfoCmp:HideName()
    if self.name_go then
        self.name_go:SetActive(true)
        self.name_go = nil
    end
end

function UnitInfoCmp:ShowAnger()
    self.anger_go = self.info_point:FindChild("AngerList")
    if not self.anger_go then
        PrintError("UnitInfoCmp: unit anger_go not found")
        return
    end
    self.anger_go:SetActive(true)
    for i = 1, kMaxAngerShowCount do
        self.anger_go:FindChild("Anger" .. i .. "/Active"):GetComponent("Transform").localPosition = Vector3.New(0, 0, -1)
    end
    self.anger_count = self.anger_go:FindChild("Count")
    self:SetAngerValue()
end

function UnitInfoCmp:HideAnger()
    if self.anger_go then
        self.anger_go:SetActive(false)
        self.anger_go = nil
    end
end

function UnitInfoCmp:SetAngerValue()
    local anger_count = self.owner:GetAnger()
    local show_anger_count = anger_count > kMaxAngerShowCount and kMaxAngerShowCount or anger_count
    self.anger_count:SetActive(anger_count > kMaxAngerShowCount)
    if anger_count > kMaxAngerShowCount then self.anger_count:GetComponent("TextMesh").text = string.format(UIConst.Text.COUNT, anger_count) end
    for i = 1, show_anger_count do
        self.anger_go:FindChild("Anger" .. i .. "/Active"):SetActive(true)
    end
    for i = show_anger_count + 1, kMaxAngerShowCount do
        self.anger_go:FindChild("Anger" .. i .. "/Active"):SetActive(false)
    end
end

function UnitInfoCmp:SetInfoCmpColor(color)
    self:_SetInfoCmpColor(UnityEngine.SpriteRenderer, color)
    self:_SetInfoCmpColor(UnityEngine.TextMesh, color)
end

function UnitInfoCmp:_SetInfoCmpColor(cmp, color)
    local cmp_list = self.info_point:GetComponentsInChildren(cmp, true)
    local cmp_tb = {}
    for i = 0, cmp_list.Length - 1 do
        if cmp_list[i] then
            table.insert(cmp_tb, cmp_list[i])
        end
    end
    for i, image in ipairs(cmp_tb) do
        image.color = color
    end
end

function UnitInfoCmp:DestroyInfo()
    if not self.info_point then return end
    self:HideName()
    self:HideBloodBar()
    self:HideAnger()
end

function UnitInfoCmp:DestroyRes()
    self:DestroyInfo()
    self.info_point = nil
end

function UnitInfoCmp:DoDestroy()
    self:DestroyInfo()
end

return UnitInfoCmp