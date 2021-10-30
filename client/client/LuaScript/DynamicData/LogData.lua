local LogData = class("DynamicData.LogData")
--local MapLogicConst = require("MapLogic.MapLogicConst")
local CSConst = require("CSCommon.CSConst")

local kNovicePlotName = {
    ruchang = "plot-ruchang",
    xuanchong = "plot-xuanchong",
    chuansong = "plot-chuansong",
    jiujiuchuchang = "plot-jiujiuchuchang",
    chakanyifu = "plot-chakanyifu",
    yaokunlaixi = "plot-yaokunlaixi",
    shengqiao = "plot-shengqiao",
    diaoxiaqiao = "plot-diaoxiaqiao",
    churujitan = "plot-churujitan",
    shenrujitan = "plot-shenrujitan",
    jieshu = "plot-jieshu",
}

function LogData:DoInit()
    self.startup_node_list = {} --启动log结点
    self.notive_node_list = {}  --新手指引log结点
end

function LogData:ClearAll()
    self.startup_node_list = {}
    self.notive_node_list = {}
end

function LogData:SendCutsceneNewBeeLog(plot_name)
    if plot_name == kNovicePlotName.ruchang then
        self:SendNewBeeLog(CSConst.CilentProcessType.NOVICE_CUTSCENES_RUCHANG)
    elseif plot_name == kNovicePlotName.xuanchong then
        self:SendNewBeeLog(CSConst.CilentProcessType.NOVICE_CUTSCENES_XUANCHONG)
    elseif plot_name == kNovicePlotName.chuansong then
        self:SendNewBeeLog(CSConst.CilentProcessType.NOVICE_CUTSCENES_CHUANSONG)
    elseif plot_name == kNovicePlotName.jiujiuchuchang then
        self:SendNewBeeLog(CSConst.CilentProcessType.NOVICE_CUTSCENES_JIUJIUCHUCHANG)
    elseif plot_name == kNovicePlotName.chakanyifu then
        self:SendNewBeeLog(CSConst.CilentProcessType.NOVICE_CUTSCENES_CHAKANYIFU)
    elseif plot_name == kNovicePlotName.yaokunlaixi then
        self:SendNewBeeLog(CSConst.CilentProcessType.NOVICE_CUTSCENES_YAOHUNLAIXI)
    elseif plot_name == kNovicePlotName.shengqiao then
        self:SendNewBeeLog(CSConst.CilentProcessType.NOVICE_CUTSCENES_SHENGQIAO)
    elseif plot_name == kNovicePlotName.diaoxiaqiao then
        self:SendNewBeeLog(CSConst.CilentProcessType.NOVICE_CUTSCENES_DIAOXIAQIAO)
    elseif plot_name == kNovicePlotName.churujitan then
        self:SendNewBeeLog(CSConst.CilentProcessType.NOVICE_CUTSCENES_CHURU_JITAN)
    elseif plot_name == kNovicePlotName.shenrujitan then
        self:SendNewBeeLog(CSConst.CilentProcessType.NOVICE_CUTSCENES_SHENRU_JITAN)
    elseif plot_name == kNovicePlotName.jieshu then
        self:SendNewBeeLog(CSConst.CilentProcessType.NOVICE_CUTSCENES_JIESHU)
    end
end

function LogData:SendCaptureNewBeeLog(c_type, e_type)
    -- if c_type == MapLogicConst.CONDITION.COND_FinishCapture then
    --     --并且在新手场景
    --     if e_type == 1001004 then--黄牛怪
    --         self:SendNewBeeLog(CSConst.CilentProcessType.NOVICE_CAPTURE_HUANGNIU)
    --     elseif e_type == 1001007 then--饕餮
    --         self:SendNewBeeLog(CSConst.CilentProcessType.NOVICE_CAPTURE_TAOTIE)
    --     end
    -- end
end

-- function LogData:SendSelectPetNewBeeLog(pet_id)
--     self:SendNewBeeLog(CSConst.CilentProcessType.NOVICE_GET_PET)
-- end


--镶嵌新手引导，只发送开始引导结点以及引导结束结点
-- function LogData:SendInlayGuideNewBeeLog(guide_id)
--     if guide_id == 18001 then--引导开始id
--         self:SendNewBeeLog(CSConst.CilentProcessType.NOVICE_INLAY_GUIDE_BEGIN)
--     elseif guide_id == 18004 then --引导结束id
--         self:SendNewBeeLog(CSConst.CilentProcessType.NOVICE_INLAY_GUIDE_END)
--     end
-- end

function LogData:SendNewBeeLog(cilent_process)
    local use_time = 0
    local log_time = Time:GetServerTime()
    local last_node = self.notive_node_list[#self.notive_node_list]
    if last_node then
use_time = log_time - last_node.log_time
    end
    table.insert(self.notive_node_list, {log_time = log_time})
    local data = {
        event_name = cilent_process,
        use_time = use_time,
        net_type = 1
    }
    if SpecMgrs.msg_mgr.SendNewBeeLog then
        SpecMgrs.msg_mgr:SendNewBeeLog(data)
    end
end

function LogData:SendStartUpTranLog(cilent_process) --发送启动转化日志
    local use_time = 0
    local log_time = Time:GetServerTime()
    local last_node = self.startup_node_list[#self.startup_node_list]
    if last_node then
        use_time = log_time - last_node.log_time
    end
    table.insert(self.startup_node_list , {log_time = log_time})
    local data = {
        use_time = use_time,
        net_type = 1
    }
    --PrintError(data)
    SpecMgrs.sdk_mgr:LogEvent(cilent_process, data)
end

return LogData