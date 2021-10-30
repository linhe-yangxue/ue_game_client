local UIBase = require("UI.UIBase")

local CoverUI = class("UI.CoverUI", UIBase)

function CoverUI:DoInit()
    CoverUI.super.DoInit(self)
    self.prefab_path = "UI/Common/CoverUI"
    self.is_show = false
    self._ticker_list = {}
    self.cb_list = {}
end

function CoverUI:OnGoLoadedOk(res_go)
    CoverUI.super.OnGoLoadedOk(self, res_go)
    self:InitRes()
end

function CoverUI:Show(cb)
    table.insert(self.cb_list, cb)
    if self.is_show then
        return
    end
    self.is_show = true
    CoverUI.super.Show(self)
    self:PlayOnShow()
end

function CoverUI:Hide()
    if not self.is_show then
        return
    end
    self.is_show = false
    self:PlayOnHide(function()
        CoverUI.super.Hide(self)
    end)
end

function CoverUI:InitRes()
    self.canvas_group = self.main_panel:GetComponent("CanvasGroup")
end

function CoverUI:PlayOnShow()
    local func = function(delta)
        if IsNil(self.go) then
            return false
        end
        self.canvas_group.alpha = delta
        return true
    end
    self.ticker = self:AddTicker(0.15, func, function()
        for _, cb in ipairs(self.cb_list) do
            cb()
        end
        self.cb_list = {}
    end)
end

function CoverUI:PlayOnHide(cb)
    local func = function(delta)
        if IsNil(self.go) then
            return false
        end
        self.canvas_group.alpha = 1 - delta
        return true
    end
    self.ticker = self:AddTicker(0.15, func, cb)
end

function CoverUI:Update(delta_time)
    local alive_tickers = {}
    local now = SpecMgrs.timer_mgr:Now()
    for _, ticker in ipairs(self._ticker_list) do
        if not ticker.is_delete then
            if ticker.begin_time + ticker.duration >= now then
                local param = (now - ticker.begin_time) / ticker.duration
                if ticker.func(param) then
                    table.insert(alive_tickers, ticker)
                end
            else
                ticker.func(1)
                if ticker.finish_func then
                    ticker.finish_func()
                end
            end
        end
    end
    self._ticker_list = alive_tickers
end

--在sec_time秒内每帧调用一次func(),参数为(当前时间-开始时间)/持续时间,若func返回false或nil则立刻移除该Ticker,否则在Ticker正常结束后会调用一次finish_func
--sec_time:持续时间，不能为空！ func:持续时间内反复调用的方法，不能为空！ finish_func:结束后调用的方法，可以为空
function CoverUI:AddTicker(sec_time, func, finish_func)
    if not func then
        return
    end
    local msec_time = math.max(0, math.ceil(sec_time * 1000))
    local new_ticker = { duration = msec_time, begin_time = SpecMgrs.timer_mgr:Now(), func = func, finish_func = finish_func }
    table.insert(self._ticker_list, new_ticker)
    return new_ticker
end

function CoverUI:RemoveTicker(ticker)
    ticker.is_delete = true
end

return CoverUI