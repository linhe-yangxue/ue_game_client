local SprotoLoader = require "Sproto.sprotoloader"
local SprotoCore = require "sproto.core"

local sproto_env = {BASE_PACKAGE = "base_package", PROTO_ID_C2S = 1, PROTO_ID_S2C = 2}
sproto_env.sproto_list = {
    {
        id = sproto_env.PROTO_ID_C2S,
        filename = 'c2s.spb',
    },
    {
        id = sproto_env.PROTO_ID_S2C,
        filename = 's2c.spb',
    },
}

function sproto_env:init(sp_path, call_back, ...)
    if self.is_inited then
        call_back(...)
        return
    end
    self.call_back_list = self.call_back_list or {}
    if call_back then
        local args = {...}
        table.insert(self.call_back_list, {cb = call_back, args = args})
    end
    if self.is_called_init then
        return
    end
    self.is_called_init = true
    sp_path = sp_path or "sproto"
    self.init_count = 0
    for _, item in ipairs(self.sproto_list) do
        local full_path = sp_path .. '/' .. item.filename
        local bytes = SpecMgrs.res_mgr:GetTextAssetSync(full_path)
        SprotoLoader.save(bytes, item.id)
        self.init_count = self.init_count + 1
        if self.call_back_list and self.init_count == #self.sproto_list then
            for _, cb_tb in ipairs(self.call_back_list) do
                cb_tb.cb(table.unpack(cb_tb.args))
            end
            self.is_inited = true
        end
    end
end

return sproto_env