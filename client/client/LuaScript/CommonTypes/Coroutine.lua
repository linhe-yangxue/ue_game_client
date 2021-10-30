local create = coroutine.create
local running = coroutine.running
local resume = coroutine.resume
local yield = coroutine.yield

local _co_tb = setmetatable({}, {__mode = "v"}) -- 使用弱表引用，自动gc

function coroutine.pstart(f, error_handle, ...)
	local eh = function(err)
		ErrorHandle(err)
		if error_handle then
			error_handle(err)
		end
	end
	local args = table.pack(...)
	local co = nil
	co = create(function()
					xpcall(f, eh, table.unpack(args, 1, args.n))
					-- f(table.unpack(args, 1, args.n))
					_co_tb[co] = nil
			    end)

	if running() == nil then
		local flag, msg = resume(co, ...)

		if not flag then
			PrintError(debug.traceback(co, msg))
		end
	else
		local action = function()
			local flag, msg = resume(co, table.unpack(args, 1, args.n))
			if not flag then
				PrintError(debug.traceback(co, msg))
			end
		end

		_co_tb[co] = CoTimer:AddTimer(action, 0)
	end
	return co
end

function coroutine.start(f, ...)
	return coroutine.pstart(f, nil, ...)
end

function coroutine.wait(t, co, ...)
	local args = table.pack(...)
	co = co or running()

	local action = function()
		local flag, msg = resume(co, table.unpack(args, 1, args.n))
		
		if not flag then
			msg = debug.traceback(co, msg)
			Debugger.LogError("coroutine error:{0}", msg)
			return
		end
	end
	
	_co_tb[co] = CoTimer:AddTimer(action, t)
	return yield()
end

function coroutine.continue(co)
	local timer = _co_tb[co]
	if timer ~= true then
		return
	end
	_co_tb[co] = nil
	local flag, msg = resume(co)
	if not flag then
		msg = debug.traceback(co, msg)
		Debugger.LogError("coroutine error:{0}", msg)
	end
end

function coroutine.pause(co)
	co = co or running()
	local timer = _co_tb[co]
	if timer and timer ~= true then
		CoTimer:RemoveTimer(timer)
	end
	_co_tb[co] = true
	return yield()
end

function coroutine.step(co, ...)
	local args = table.pack(...)
	co = co or running()
	
	local action = function()
		local flag, msg = resume(co, table.unpack(args, 1, args.n))
	
		if not flag then
			msg = debug.traceback(co, msg)
			Debugger.LogError("coroutine error:{0}", msg)
			return
		end
	end

	_co_tb[co] = CoTimer:AddTimer(action, 0)

	return yield()
end

function coroutine.clear(co)
	co = co or running()
	local timer = _co_tb[co]
	_co_tb[co] = nil
	if timer and timer ~= true then
		CoTimer:RemoveTimer(timer)
	end
end
