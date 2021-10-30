local RedPointBase = class("UI.RedPointTypeClass.RedPointBase")

-----必要通用方法 begin-------------
function RedPointBase:DoInit(param_tb)
    local ui_go = param_tb.ui.go
    if IsNil(ui_go) then return false end
    self.go = param_tb.go
    return true
end

function RedPointBase:DoDestroy()
    if not IsNil(self.go) then
        GameObject.Destroy(self.go)
    end
    self.go = nil
end

function RedPointBase:Show()
    return not IsNil(self.go)
end

function RedPointBase:Hide()
    return not IsNil(self.go)
end
-----必要通用方法 end-------------
return RedPointBase