local UIBase = require("UI.UIBase")

local LoopListCmp = class("UI.UICmp.LoopListCmp", UIBase)

function LoopListCmp:DoInit(ui, go)
    LoopListCmp.super.DoInit(self)
    self.owner = ui
    self.tag = "LoopListCmp".. go:GetInstanceID()
    local ret = self.owner:IsRegisterUIDestroyEvent(self.tag)
    if ret then
        PrintError("LoopListCmp:tag is register",self.tag)
    end
    self.owner:RegisterUIDestroyEvent(self.tag, self.DoDestroy, self)
    self.loop_list_go = go
    self.loop_list_comp = go:GetComponent("UILoopListView")
    if not self.loop_list_comp then
        PrintError("LoopListCmp: not found UILoopListView cmp", self.owner.class_path)
    end
end

function LoopListCmp:Refresh(is_play_init_anim)
    self.loop_list_comp:Refresh(is_play_init_anim)
end

function LoopListCmp:SelectIndex(index, is_show_anim)
    if is_show_anim == nil then
        is_show_anim = true
    end
    self.loop_list_comp:SelectIndex(index, is_show_anim)
end

function LoopListCmp:SelectNext()
    self.loop_list_comp:SelectNext()
end

function LoopListCmp:SelectLast()
    self.loop_list_comp:SelectLast()
end

function LoopListCmp:ListenItemSelect(cb)
    self:AddLoopListItemSelect(self.loop_list_go, cb)
end

function LoopListCmp:GetCurIndex()
    return self.loop_list_comp:GetCurIndex()
end

function LoopListCmp:DoDestroy()
    self.owner:UnregisterUIDestroyEvent(self.tag)
    LoopListCmp.super.DoDestroy(self)
end

return LoopListCmp