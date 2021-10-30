local Object = require("CommonBase.Object")
local TalkCmp = class("UI.UICmp.TalkCmp")

local path_dict = {
    talk_white = "UI/UIPrefab/talk_white",
    talk_white_down = "UI/UIPrefab/talk_white_down"
}

local talk_prefab_list = {
    "talk_white",
    "talk_white_down",
}

function TalkCmp:DoInit(ui, parent, prefab_index, is_arrow_right, get_talk_cb, change_time)
    self.owner = ui
    local prefab_name = talk_prefab_list[prefab_index]
    local path = path_dict[prefab_name]
    local prefab = SpecMgrs.res_mgr:GetPrefabSync(path)
    self.go = self.owner:GetUIObject(prefab, parent)
    self:SetTalkCb(get_talk_cb)
    self:SetTalkChangeTime(change_time)
    self:SetArrowDir(is_arrow_right)
    self.tag = "TalkCmp" .. self.go:GetInstanceID()
    local ret = self.owner:IsRegisterUIDestroyEvent(self.tag)
    if ret then
        PrintError("slide_select_cmp:tag is register", self.tag)
    end
    self.owner:RegisterUIDestroyEvent(self.tag, self.DoDestroy, self)
end

function TalkCmp:UpdateTalkContent(str)
    if not self:_CheckGO() then return end
    str = str or self:_GetTalkFromCb()
    self.go:FindChild("Text"):GetComponent("Text").text = str
end

function TalkCmp:SetTalkCb(cb)
    self.get_talk_cb = cb
    local str = self:_GetTalkFromCb()
    self:UpdateTalkContent(str)
end

function TalkCmp:_GetTalkFromCb()
    if self.get_talk_cb then
        return self.get_talk_cb(self.owner)
    end
end

function TalkCmp:SetTalkChangeTime(change_time)
    self.owner:RemoveDynamicUI(self.go)
    if change_time then
        local change_talk_time = self.go:GetComponent("UIAnimBase").time_ / 2 -- 在隐藏一半的时候换文字
        self.go:GetComponent("UIAnimBase").enabled = false
        self.owner:AddDynamicUI(self.go, function (time)
            if not self:_CheckGO() then return end
            self.owner:AddTimer(function ()
                self:UpdateTalkContent()
            end, change_talk_time, 1)
            self.go:GetComponent("UIAnimBase").enabled = true
        end, change_time, 0)
    end
end

function TalkCmp:SetArrowDir(is_right)
    is_right = is_right == nil or is_right
    local scale = Vector3.New(is_right and 1 or -1, 1, 1)
    self.go:GetComponent("RectTransform").localScale = scale
    self.go:FindChild("Text"):GetComponent("RectTransform").localScale = scale
end

function TalkCmp:_CheckGO()
    if not IsNil(self.go) then
        return true
    end
end

function TalkCmp:DoDestroy()
    self.owner:UnregisterUIDestroyEvent(self.tag)
    self.owner:DelUIObject(self.go)
end

return TalkCmp