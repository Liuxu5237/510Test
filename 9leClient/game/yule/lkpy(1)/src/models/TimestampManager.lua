--
-- Author: Liuxu
-- Date: 2018-08-25 10:26:25
-- 时间校验

local module_pre = "game.yule.lkpy.src"	

local TimestampManager = class("TimestampManager")

msInstance = nil
TimestampManager.s_mode = 0
TimestampManager.s_tt   = 0

function TimestampManager:shared()
    
    if nil == msInstance then
		msInstance = self
    end
    return msInstance
end

function TimestampManager:ctor()
	self.time_local_ 	= 0;
	self.current_tick_ 	= 0;
	self.time_trad_ 	= 0;
	self.server_time_ 	= 0;
	self.sc_diffrence_ 	= 0;
	self._time			= 0
    return
end

function TimestampManager:getTimeCheck()
	
	local str_time = ds.CoTimer:getCurrentTime()
	return str_time
end

function TimestampManager:timeCheck( clientTime , serverTime )	
	print("client " .. clientTime)
	print("serverTime" .. serverTime)

	if clientTime ~= 0 then
		self.time_local_ = clientTime
	else
		self.time_local_ = self:getTimeCheck()
	end

	clientTime = self:getTimeCheck()
	if clientTime > self.time_local_ then
		self.time_trad_ = (clientTime - self.time_local_) /2
	else
		self.time_trad_ = 0
	end

	self.server_time_ = serverTime + self.time_trad_
	self.sc_diffrence_ = self.server_time_ - clientTime

	self._time = self:getTimeCheck()

end

function TimestampManager:get_time_difference( packet_time)
	local myTrad1 = self:get_server_tick() - packet_time
	if myTrad1 < 0 then
		myTrad1 = 0
	end
	if myTrad1 > 2000 then
		myTrad1 = 2000
	end

	return myTrad1
end

function TimestampManager:get_trad()
	return self.time_trad_
end

function TimestampManager:get_server_tick()
	return self:getTimeCheck() + self.sc_diffrence_ 
end

return TimestampManager