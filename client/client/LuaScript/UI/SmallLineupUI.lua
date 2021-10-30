local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local SmallLineupUI = class("UI.SmallLineupUI",UIBase)
local UIFuncs = require("UI.UIFuncs")

SmallLineupUI.need_sync_load = true


function SmallLineupUI:DoInit()
    SmallLineupUI.super.DoInit(self)
    self.prefab_path = "UI/Common/SmallLineupUI"
    self.cur_drag_seat_id = nil -- 当前拖拽的英雄对应的seat
    self.seat_parent_list = {} -- 存储6个seat 挂的父物体
    self.dy_hero_data = ComMgrs.dy_data_mgr.night_club_data

    self.pos_to_seat = {}
    self.seat_to_pos = {}
    self.seat_to_hero = {}
    self.seat_to_go = {} -- 英雄对应位置的go
    self.lineup_max_count = CSConst.LineupMaxCount
    self.v2_zero = Vector2.New(0, 0)
end

function SmallLineupUI:OnGoLoadedOk(res_go)
    SmallLineupUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function SmallLineupUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    SmallLineupUI.super.Show(self)
end

function SmallLineupUI:InitRes()
    self.top_level = self.main_panel:FindChild("Content/Content/TopLevel")
    self.hero_item_temp = self.main_panel:FindChild("Content/Content/HeroPart/1/Seat/Item")
    self.hero_item_temp:SetActive(false)

    local hero_part = self.main_panel:FindChild("Content/Content/HeroPart")
    for i = 1, self.lineup_max_count do
        table.insert(self.seat_parent_list, hero_part:FindChild(i .. "/Seat"))
    end
    self:AddClick(self.main_panel:FindChild("Content/Content/CloseBtn"), function ()
        self:Hide()
    end)
end

function SmallLineupUI:_ChangePosSeat(pos_id, seat_index)
    if not pos_id or not seat_index then return end
    self.pos_to_seat[pos_id] = seat_index
    self.seat_to_pos[seat_index] = pos_id
end

function SmallLineupUI:OnDrag(go, delta, position)
    local _, pos = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(self.top_level:GetComponent("RectTransform"), position, self.canvas.worldCamera)
    go:GetComponent("RectTransform").anchoredPosition = pos
end

function SmallLineupUI:OnRelease(go)
    local cur_go_position = UnityEngine.RectTransformUtility.WorldToScreenPoint(nil, go.position)
    for pos_id, seat_parent in ipairs(self.seat_parent_list) do
        if UnityEngine.RectTransformUtility.RectangleContainsScreenPoint(seat_parent.transform, cur_go_position) then
            self:SwitchHeroToPos(pos_id)
            return
        end
    end
    self:SwitchHeroToPos() -- 没拖到任何位置
end

function SmallLineupUI:InitUI()
    local lineup_data = self.dy_hero_data:GetAllLineupData()
    for seat_index, seat_data in pairs(lineup_data) do
        if seat_data.hero_id then
            self:_ChangePosSeat(seat_data.pos_id, seat_index)
            self.seat_to_hero[seat_index] = seat_data.hero_id
        end
    end
    for pos_id, seat_index in pairs(self.pos_to_seat) do
        local item = self:GetUIObject(self.hero_item_temp, self.seat_parent_list[pos_id])
        local hero_id = self.seat_to_hero[seat_index]
        UIFuncs.InitHeroGo({go = item, hero_id = hero_id})
        self:AddDrag(item, function (delta, position)
            if not self.cur_drag_seat_id then
                self.cur_drag_seat_id = seat_index
                item:SetParent(self.top_level, true)
            end
            self:OnDrag(item, delta, position)
        end)
        self:AddRelease(item, function ()
            if self.cur_drag_seat_id then
                self:OnRelease(item)
            end
        end)
        self.seat_to_go[seat_index] = item
    end
end

function SmallLineupUI:Hide()
    SpecMgrs.msg_mgr:SendMsg("SendHeroAdjustPosLineup", {pos_dict = self.pos_to_seat}, function (resp)
        self.pos_to_seat = {}
    end)
    for _, v in pairs(self.seat_to_go) do
        self:DelUIObject(v)
    end
    self.seat_to_pos = {}
    self.seat_to_hero = {}
    self.seat_to_go = {}
    SmallLineupUI.super.Hide(self)
end

function SmallLineupUI:_GetSendLineupData()
    local pos_dict = {}
    for hero_id, pos in pairs(self.hero_to_pos) do
        pos_dict[pos] = self.hero_to_seat[hero_id]
    end
    return pos_dict
end

function SmallLineupUI:SwitchHeroToPos(target_pos_id)
    local cur_seat_go = self.seat_to_go[self.cur_drag_seat_id]
    local old_pos_id = self.seat_to_pos[self.cur_drag_seat_id]
    local old_seat_parent = self.seat_parent_list[old_pos_id]
    local target_seat_id = self.pos_to_seat[target_pos_id]
    if not target_pos_id or (target_seat_id and target_seat_id == self.cur_drag_seat_id) then -- 拖到原有位置 或者 其他位置还原
        cur_seat_go:SetParent(old_seat_parent, false)
    else
        if target_seat_id then -- 需要交换位置
            local seat_go = self.seat_to_go[target_seat_id]
            self:_ChangePosSeat(old_pos_id, target_seat_id)
            seat_go:SetParent(old_seat_parent, false)
            seat_go.transform.anchoredPosition = self.v2_zero
        else -- 目标没有英雄
            self.pos_to_seat[old_pos_id] = nil
        end
        local target_seat_parent = self.seat_parent_list[target_pos_id]
        self:_ChangePosSeat(target_pos_id, self.cur_drag_seat_id)
        cur_seat_go:SetParent(target_seat_parent, false)
    end
    cur_seat_go.transform.anchoredPosition = self.v2_zero
    self.cur_drag_seat_id = nil
end

return SmallLineupUI