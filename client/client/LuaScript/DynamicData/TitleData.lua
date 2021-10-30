local EventUtil = require("BaseUtilities.EventUtil")
local UIConst = require("UI.UIConst")
local TitleData = class("DynamicData.TitleData")

EventUtil.GeneratorEventFuncs(TitleData, "UpdateTitleInfoEvent")
EventUtil.GeneratorEventFuncs(TitleData, "UpdateWearTitleEvent")
EventUtil.GeneratorEventFuncs(TitleData, "UpdateAddTitleEvent")
EventUtil.GeneratorEventFuncs(TitleData, "UpdateDeleteTitleEvent")

local kGetTitleShowUIName = "MainSceneUI"

function TitleData:DoInit()
    self.wearing_id = nil
    self.title_dict = {}
    self.cache_title_list = {}
end

function TitleData:NotifyTitleInfo(msg)
    if msg.wearing_id then
        self.wearing_id = msg.wearing_id
    end
    self.title_dict = msg.title_dict
    self:DispatchUpdateTitleInfoEvent()
end

function TitleData:NotifyWearTitle(msg)
    self.wearing_id = msg.wearing_id
    self:DispatchUpdateWearTitleEvent()
end

function TitleData:NotifyAddTitle(msg)
    self.title_dict[msg.title_id] = msg.getting_ts
    if not SpecMgrs.ui_mgr:GetUI("GetTitleUI") or not SpecMgrs.ui_mgr:GetUI("GetTitleUI").is_visible then
        if SpecMgrs.ui_mgr:GetCurShowTopUIName() == kGetTitleShowUIName then
            SpecMgrs.ui_mgr:ShowUI("GetTitleUI")
        else
            table.insert(self.cache_title_list, msg.title_id)
            if not SpecMgrs.ui_mgr:IsRegisterTopUIChangeEvent("TitleData") then
                SpecMgrs.ui_mgr:RegisterTopUIChangeEvent("TitleData", function ()
                    if SpecMgrs.ui_mgr:GetCurShowTopUIName() == kGetTitleShowUIName then
                        SpecMgrs.ui_mgr:UnregisterTopUIChangeEvent("TitleData")
                        SpecMgrs.ui_mgr:ShowUI("GetTitleUI", self.cache_title_list)
                        self.cache_title_list = {}
                    end
                end)
            end
        end
    end
    self:DispatchUpdateAddTitleEvent(msg.title_id)
end

function TitleData:NotifyDeleteTitle(msg)
    if self.wearing_id == msg.title_id then
        self.wearing_id = nil
    end
    self.title_dict[msg.title_id] = nil
    self:DispatchUpdateDeleteTitleEvent()
end

function TitleData:GetWearingTitle()
    return self.wearing_id
end

function TitleData:GetTitleGetTime(id)
    return self.title_dict[id]
end

function TitleData:GetOwnTitleNum()
    return table.getCount(self.title_dict)
end

function TitleData:GetOwnTypeTitleNum(_type)
    local num = 0
    local not_own_num = 0
    for title_id, title_data in pairs(SpecMgrs.data_mgr:GetAllItemData()) do
        if title_data.sub_type == _type and self.title_dict[title_id] then
            num = num + 1
        end
        if title_data.sub_type == _type and not self.title_dict[title_id] then
            not_own_num = not_own_num + 1
        end
    end
    return num, not_own_num
end

function TitleData:GetSortTitleList(_type)
    local title_list = {}
    for title_id, title_data in pairs(SpecMgrs.data_mgr:GetAllItemData()) do
        if title_data.sub_type == _type then
            table.insert(title_list, title_data)
        end
    end
    table.sort(title_list, function (data1, data2)
        if self.title_dict[data1.id] and data1.id == self.wearing_id then return true end
        if self.title_dict[data2.id] and data2.id == self.wearing_id then return false end
        if not self.title_dict[data1.id] and self.title_dict[data2.id] then return false end
        if self.title_dict[data1.id] and not self.title_dict[data2.id] then return true end
        if not self.title_dict[data1.id] and not self.title_dict[data2.id] then
            if data1.id > data2.id then return true end
            return false
        end
        if self.title_dict[data1.id] > self.title_dict[data2.id] then return true end
        return false
    end)
    return title_list
end

function TitleData:ClearAll()
    if SpecMgrs.ui_mgr:IsRegisterTopUIChangeEvent("TitleData") then
        SpecMgrs.ui_mgr:UnregisterTopUIChangeEvent("TitleData")
    end
end

return TitleData