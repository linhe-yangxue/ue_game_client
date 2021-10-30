local AIConst = require("AI.AIConst")

local ActScript = DECLARE_MODULE("AI.NodeHandles.ActScript")

function ActScript:InitByNodeData(node_data)
    self.script = node_data.script
end

local _math = {}

for k, v in pairs(math) do
    _math[k] = v
end

_math.random = function (a, b) -- 随机浮点数
    if a == nil then
        if b == nil then
            return math.random()
        else
            a = 1
        end
    else
        if b == nil then
            b = a
            a = 1
        end
    end
    return a + (b - a) * math.random()
end

_math.randint = function(a, b) -- 随机整数
    return math.random(a, b)
end

ActScript.chunk_run_script = [==[
    --%s#
    return function (_tree)
        local variables = _tree.variables
        local parent_tb = _tree.parent_tb 
        %s
    end
]==]

function ActScript:GetChunk()
    --  替换lua的随机方法
    local env = {}
    setmetatable(env, {__index = _G})
    env.math = _math

    local script_str = string.format(ActScript.chunk_run_script, self.ai_tree.ai_data.id, self.script)
    local ret, msg = LoadLua(script_str, env)
    if ret then
        return ret()
    else
        PrintError(msg)
    end
end

function ActScript:Start()
    if not self.script_chunk then
        self.script_chunk = ActScript.GetChunk(self)
    end
    if self.script_chunk then
        local ret = self.script_chunk(self.ai_tree)
        if ret then
            return AIConst.Status_Success
        else
            return AIConst.Status_Failed
        end
    else
        return AIConst.Status_Failed
    end
end

return ActScript
