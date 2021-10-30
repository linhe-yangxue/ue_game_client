local UIBase = require("UI.UIBase")

local SlideSelectCmp = class("UI.UICmp.SlideSelectCmp", UIBase)

function SlideSelectCmp:DoInit(ui, go)
    SlideSelectCmp.super.DoInit(self)
    self.owner = ui
    self.tag = "SlideSelectCmp" .. go:GetInstanceID()
    local ret = self.owner:IsRegisterUIDestroyEvent(self.tag)
    if ret then
        PrintError("slide_select_cmp:tag is register", self.tag)
    end
    self.owner:RegisterUIDestroyEvent(self.tag, self.DoDestroy, self)
    self.slide_select_view_go = go
    self.slide_select_cmp = go:GetComponent("UISlideSelect")
    if not self.slide_select_cmp then
        PrintError("slide_select_cmp: not found UISlideSelect cmp", self.owner.class_path)
    end
    self.slide_select_cmp:Init()
end

function SlideSelectCmp:ListenSelectUpdate(cb)
    self:AddUISlideSelectChange(self.slide_select_view_go, cb)
end

function SlideSelectCmp:ListenSlideBegin(cb)
    self:AddUISlideSelectBegin(self.slide_select_view_go, cb)
end

function SlideSelectCmp:ListenSlideEnd(cb)
    self:AddUISlideSelectEnd(self.slide_select_view_go, cb)
end

function SlideSelectCmp:SetParam(cell_width, count)
    self.slide_select_cmp:SetParam(cell_width, count)
end

function SlideSelectCmp:SetDraggable(draggable)
    self.slide_select_cmp:SetDraggable(draggable)
end

function SlideSelectCmp:SlideToIndex(index)
    self.slide_select_cmp:SlideToIndex(index)
end

function SlideSelectCmp:SetToIndex(index)
    self.slide_select_cmp:SetToIndex(index)
end

function SlideSelectCmp:SlideByOffset(offset)
    self.slide_select_cmp:SlideByOffset(offset)
end

function SlideSelectCmp:ResetLoopOffset()
    self.slide_select_cmp:ResetLoopOffset()
end

function SlideSelectCmp:DoDestroy()
    self.owner:UnregisterUIDestroyEvent(self.tag)
    SlideSelectCmp.super.DoDestroy(self)
end

return SlideSelectCmp