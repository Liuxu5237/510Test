module("DSBaseData", package.seeall)
--游戏的渠道号
--[[
	1:官方渠道
	2:手心SDK
]]--
local mGameVersion = 1

function getGameVersion()
	return mGameVersion
end