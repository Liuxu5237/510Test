--
-- Author: Your Name
-- Date: 2015-09-24 18:58:25
--

local HistoryLayer = class("HistoryLayer", function ()
    return cc.Layer:create()
end)

require "cocos.init"
local module_pre = "game.yule.xiyou.src"
local Data = appdf.req(module_pre .. ".models.Data")
local scheduler = cc.Director:getInstance():getScheduler()
local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
local schedulerEntry = nil 

function HistoryLayer:ctor()
    self:init()
end

function HistoryLayer:onEnter()
	--Data.nTurnIndex = 0
end 

function HistoryLayer:onExit()
    
end 

function HistoryLayer:init()
	self:setTouchEnabled(true)
	self:registerScriptHandler(function (event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end)

    
end 


return HistoryLayer