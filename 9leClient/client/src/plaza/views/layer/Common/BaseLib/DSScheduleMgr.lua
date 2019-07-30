module("DSScheduleMgr", package.seeall)

local tSchedulerID = {}

function schedule(func, time, key, paused, isOnce)
	if (key == nil or key == "") then
		ds.log("key is not nil")
		return
	end

	if (func == nil or func == "" or (type(func) ~= "function" and type(func) ~= "string")) then
		ds.log("func is not nil")
		return
	end 

	time = time or 1
	paused = paused and true or false

	local id = getScheduleIdByKey(key)
	local scheduler = cc.Director:getInstance():getScheduler()

	if (id ~= nil) then
		ds.log("have exist schedule")
		scheduler:unscheduleScriptEntry(id)
        id = nil
	end

	id = scheduler:scheduleScriptFunc(function()
		if (type(func) == "function") then
			func(time)
		elseif (type(func) == "string") then
			ds.common.ConvertFunc(func)(time)
		end

		if (isOnce) then
			unschedule(key)
		end

	end, time, paused) 

	tSchedulerID[key] = id
end

function scheduleOnce(func, time, key, paused)
	schedule(func, time, key, paused, true)
end


function getScheduleIdByKey(key)
	local id = nil
	for k, v in pairs(tSchedulerID) do
		if k == key then
			id = v
			break
		end
	end

	return id
end

function unschedule(key)
	local id = getScheduleIdByKey(key)
	if (id ~= nil) then
		local scheduler = cc.Director:getInstance():getScheduler()
		scheduler:unscheduleScriptEntry(id)
		tSchedulerID[key] = nil
	end
end

function unallschedule()

	local scheduler = cc.Director:getInstance():getScheduler()
	for k,v in pairs(tSchedulerID) do
		scheduler:unscheduleScriptEntry(v)
	end
	tSchedulerID = {}
end
