local EventUtil = DECLARE_MODULE("BaseUtilities.EventUtil")

DECLARE_RUNNING_ATTR(EventUtil, "_event_cls_mods", {})

EventUtil.__RELOAD_AFTER = function ()
    for cls_mod, event_n_tb in pairs(EventUtil._event_cls_mods) do
        cls_mod.__UpdateEventCbRemove = nil
        cls_mod.__ClearAllEventCb = nil
        for evt_name, _ in pairs(event_n_tb) do
            EventUtil.GeneratorEventFuncs(cls_mod, evt_name)
        end
    end
end

EventUtil.kDefaultMaxEventFuncs = 30

-- 接口：辅助函数
function EventUtil.GeneratorEventFuncs(cls_tb, event_name, max_funcs_count)
    if not EventUtil._event_cls_mods[cls_tb] then
        EventUtil._event_cls_mods[cls_tb] = {}
    end
    EventUtil._event_cls_mods[cls_tb][event_name] = true
    max_funcs_count = max_funcs_count or EventUtil.kDefaultMaxEventFuncs
    cls_tb["Register" .. event_name] = function (self, tag, cb, ...)
            if tag == "_count" then
                PrintError("Can't not use tag == _count")
            end
            local param = table.pack(...)
            if param.n < 1 then
                param = nil
            end
            if not self.event_cb_list then
                self.event_cb_list = {}
            end
            if not self.event_cb_list[event_name] then
                self.event_cb_list[event_name] = {_count = 0}
            end
            local is_in_remove = self.delay_remove_event_cb_list and self.delay_remove_event_cb_list[event_name] and self.delay_remove_event_cb_list[event_name][tag]
            if not self.event_cb_list[event_name][tag] or is_in_remove then
                local cur_count = self.event_cb_list[event_name]._count + 1
                self.event_cb_list[event_name]._count = cur_count
                if cur_count > max_funcs_count then
                    PrintWarn("RegisterFunc Count Exceed max count may be have memory leak, event_name:", event_name, "tag:", tag, "cur_count:", cur_count, debug.traceback())
                end
            end
            if is_in_remove then
               self.delay_remove_event_cb_list[event_name][tag] = nil
            end
            self.event_cb_list[event_name][tag] = {cb = cb, param = param}
            self:__UpdateEventCbRemove()
        end
    cls_tb["IsRegister" .. event_name] = function (self, tag)
            local ret = self.event_cb_list and self.event_cb_list[event_name] and self.event_cb_list[event_name][tag] ~= nil
            ret = ret and not (self.delay_remove_event_cb_list and self.delay_remove_event_cb_list[event_name] and self.delay_remove_event_cb_list[event_name][tag] ~= nil)
            return ret
        end
    cls_tb["Unregister" .. event_name] = function (self, tag)
            if not self.event_cb_list then
                return
            end
            if not self.event_cb_list[event_name] then
                return
            end
            if not self.event_cb_list[event_name][tag] then
                return
            end
            if not self.delay_remove_event_cb_list then
                self.delay_remove_event_cb_list = {}
            end
            if not self.delay_remove_event_cb_list[event_name] then
                self.delay_remove_event_cb_list[event_name] = {}
            end
            if not self.delay_remove_event_cb_list[event_name][tag] then
                self.event_cb_list[event_name]._count = self.event_cb_list[event_name]._count - 1
            end
            self.delay_remove_event_cb_list[event_name][tag] = true
        end
    cls_tb["Dispatch" .. event_name] = function (self, ...)
        if not self.event_cb_list or not self.event_cb_list[event_name] then
            return
        end
        local delay_list = self.delay_remove_event_cb_list and self.delay_remove_event_cb_list[event_name] or {}
        local input_param = nil
        for tag, element in pairs(self.event_cb_list[event_name]) do
            if not delay_list[tag] and tag ~= "_count" then
                local param = element.param
                local param_n = param and param.n or 0
                if param_n == 0 then
                    element.cb(self, ...)
                elseif param_n == 1 then
                    element.cb(param[1], self, ...)
                elseif param_n == 2 then
                    element.cb(param[1], param[2], self, ...)
                else
                    input_param = input_param or table.pack(...)
                    local real_p = {table.unpack(param, 1, param_n)}
                    real_p[#real_p + 1] = self
                    for i = 1, input_param.n do
                        real_p[param_n + 1 + i] = input_param[i]
                    end
                    element.cb(table.unpack(real_p, 1, param_n + 1 + input_param.n))
                end
            end
        end
        if next(delay_list) then
            for tag, _ in pairs(delay_list) do
                self.event_cb_list[event_name][tag] = nil
            end
            self.delay_remove_event_cb_list[event_name] = nil
        end
    end
    if not cls_tb.__UpdateEventCbRemove then
        cls_tb.__UpdateEventCbRemove = function (self)
            if self.delay_remove_event_cb_list and self.event_cb_list then
                for e_n, r_list in pairs(self.delay_remove_event_cb_list) do
                    if self.event_cb_list[e_n] then
                        for tag, _ in pairs(r_list) do
                            self.event_cb_list[e_n][tag] = nil
                        end
                    end
                end
                self.delay_remove_event_cb_list = nil
            end
        end
    end
    if not cls_tb.__ClearAllEventCb then
        cls_tb.__ClearAllEventCb = function (self)
            self.delay_remove_event_cb_list = nil
            self.event_cb_list = nil
        end
    end
end

return EventUtil