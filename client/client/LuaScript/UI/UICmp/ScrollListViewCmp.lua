local UIBase = require("UI.UIBase")
local ScrollListViewCmp = class("UI.UICmp.ScrollListViewCmp", UIBase)

--  滚动列表
function ScrollListViewCmp:DoInit(ui, go)
    ScrollListViewCmp.super.DoInit(self)
    self.owner = ui
    self.tag = "ScrollListViewCmp" .. go:GetInstanceID()
    local ret = self.owner:IsRegisterUIDestroyEvent(self.tag)
    if ret then
        PrintError("ScrollListViewCmp: tag is register", self.tag)
    end
    self.owner:RegisterUIDestroyEvent(self.tag, self.DoDestroy, self)
    self.scroll_list_go = go
    self.scorll_list_cmp = go:GetComponent("UIScrollListView")
end

function ScrollListViewCmp:Start(total_count, show_count)
    self.scorll_list_cmp:InitScrollListView(total_count, show_count)
end

function ScrollListViewCmp:ResetScrollListView(start_index)
    self.scorll_list_cmp:ResetScrollListView(start_index)
end

function ScrollListViewCmp:ListenerViewChange(cb)
    self:AddScrollListView(self.scroll_list_go, cb)
end

function ScrollListViewCmp:ChangeTotalCount(total_count)
    self.scorll_list_cmp:ChangeTotalCount(total_count)
end

function ScrollListViewCmp:DoDestroy()
    self.owner:UnregisterUIDestroyEvent(self.tag)
    ScrollListViewCmp.super.DoDestroy(self)
end

function ScrollListViewCmp:GetStartFlagIndex()
    return self.scorll_list_cmp:GetStartFlagIndex()
end

function ScrollListViewCmp:GetEndFlagIndex()
    return self.scorll_list_cmp:GetEndFlagIndex()
end

return ScrollListViewCmp