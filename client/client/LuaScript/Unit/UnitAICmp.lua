local AITree = require("AI.AITree")
local AIConst = require("AI.AIConst")
local UnitAICmp = class("Unit.UnitAICmp")

function UnitAICmp:DoInit(owner, ai_name)
    self.owner = owner
    self.main_ai_name = ai_name
    self.cur_ai_name = ai_name
    self.is_active_ai = false
    self._ai_hang_up_time = nil
    self._ai_hang_up_flag = false
end

function UnitAICmp:ActiveAI(temp_ai_name)
    if self.ai_tree then
        self.ai_tree:DoDestroy()
        self.ai_tree = nil
    end

    self.cur_ai_name = temp_ai_name and temp_ai_name or self.main_ai_name
    if not self.cur_ai_name then
        PrintError("UnitAICmp: not ai name ",self.owner.unit_name)
        return
    end
    local ai_data = SpecMgrs.data_mgr:GetAIData(self.cur_ai_name)
    if not ai_data then
        PrintError("UnitAICmp: not ai data",self.cur_ai_name)
        return
    end
    self.ai_tree = AITree.New()
    self.ai_tree:DoInit(self.owner)
    self.ai_tree:InitByAIData(ai_data)

    self.ai_tree:Start()
    self.is_active_ai = true
end

function UnitAICmp:InactiveAI()
    self.is_active_ai = false
end

function UnitAICmp:GetCurAIName()
    return self.cur_ai_name
end

function UnitAICmp:Update(delta_time)
    if self._ai_hang_up_flag then
        return
    end
    if self._ai_hang_up_time then
        self._ai_hang_up_time  = self._ai_hang_up_time - delta_time
        if self._ai_hang_up_time <= 0 then
            self._ai_hang_up_time = nil
        end
        return
    end
    if self.is_stop_ai then return end
    if self.is_active_ai and self.ai_tree then
        self.ai_tree:Update(delta_time)
    end
end


function UnitAICmp:SetStopAI(value)
    self.is_stop_ai = value
end

-- 挂起ai一定时间
function UnitAICmp:HangUpAI(is_hang_up, hang_up_time)
    self._ai_hang_up_flag = is_hang_up
    self._ai_hang_up_time = hang_up_time or AIConst.AI_HANG_UP_TIME.Normal_Time
end

function UnitAICmp:DoDestroy()
    if self.ai_tree then
        self.ai_tree:DoDestroy()
    end
    self.owner = nil
end

return UnitAICmp
