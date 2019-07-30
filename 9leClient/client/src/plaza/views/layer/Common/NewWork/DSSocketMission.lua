module("DSPSocketMission", package.seeall)

local SocketMission = {}

function SocketMission:init()  
	local instance = {}

	setmetatable(instance, self)
	self.__index = self
    return instance
end

function SocketMission:setUrl(url, port)
	ds.CSocketMission:setUrl(url, port)
end

function SocketMission:start()
	ds.CSocketMission:start()
end
