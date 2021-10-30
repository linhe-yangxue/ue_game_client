local beginTime = os.clock()
local unscaledTime = beginTime

Time = 
{
	fixedDeltaTime 	= 0,
	deltaTime 		= 0,
	frameCount 		= 1,
	timeScale		= 1,
	timeSinceLevelLoad 	= 0,
	unscaledDeltaTime	= 0,		
}

local mt = {}
mt.__index = function(obj, name)
	if name == "time" or name == "realtimeSinceStartup" then
		return os.clock() - beginTime
	elseif name == "unscaledTime" then
		return os.clock() - unscaledTime
	else
		return rawget(obj, name)		
	end
end

function Time:Init()
	self.frameCount	= UnityEngine.Time.frameCount
	self.fixedTime	= UnityEngine.Time.fixedTime 
	self.timeScale	= UnityEngine.Time.timeScale
	self.deltaTime = 0
	self.time = UnityEngine.Time.time
	self.msec_time = math.floor(self.time * 1000)
	self.server_time_diff = 0
	setmetatable(self, mt)
end

function Time:SetDeltaTime(deltaTime, unscaledDeltaTime)
	self.deltaTime = deltaTime
	self.frameCount = self.frameCount + 1
	self.timeSinceLevelLoad = self.timeSinceLevelLoad + deltaTime
	self.unscaledDeltaTime = unscaledDeltaTime
	self.time = UnityEngine.Time.time
	self.msec_time = math.floor(self.time * 1000)
end

function Time:GetTime()
	return self.time
end

function Time:SetServerTime(server_time)
	self.server_time_diff = server_time - GetTimeStamp()
end

function Time:GetServerTimeFloat()
	return self.server_time_diff + GetTimeStamp()
end

function Time:GetServerTime()
	return math.ceil(self.server_time_diff + GetTimeStamp())
end

function Time:SetFixedDelta(time)
	self.fixedDeltaTime = time
end

function Time:SetTimeScale(scale)
	self.timeScale = scale
	UnityEngine.Time.timeScale = scale
end

function Time:GetServerDate()
	return os.date("*t", math.ceil(self:GetServerTime()))
end

function Time:GetCurDayPassTime()
	local server_date_tb = self:GetServerDate()
	local pass_hour = server_date_tb.hour or 0
	local pass_min = server_date_tb.min or 0
	local pass_sec = server_date_tb.sec or 0
	local total_min = pass_hour * 60 + pass_min
	return total_min * 60 + pass_sec
end

function Time:GetServerWeekDay()
	return self:GetServerDate().wday - 1     --Sunday 0, Saturday 6
end

function Time:IsStatic()
	return self.timeScale == 0
end