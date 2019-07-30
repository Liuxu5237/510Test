--
-- Author: Your Name
-- Date: 2015-09-23 16:59:22
--
local GameMenuLayer = class("GameMenuLayer", function ()
    return cc.Layer:create()
end)
require "cocos.init"
local Data = import("script.Data")
local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

function GameMenuLayer:ctor(exitFunction,helpfunc)
    self:init(exitFunction,helpfunc)
end

function GameMenuLayer:onEnter()
	print("GameMenuLayer OnEnter")
end 

function GameMenuLayer:onExit()
	print("GameMenuLayer OnExit")
    -- 删除监听
    if self.eventCustomRefushListener then 
        eventDispatcher:removeEventListener(self.eventCustomRefushListener)
    end
    if self.eventCustomBetRetListener then 
        eventDispatcher:removeEventListener(self.eventCustomBetRetListener)
    end
    
end 

function GameMenuLayer:init(exitFunction,helpfunc)
    self:registerScriptHandler(function (event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end)

    local sysNode = cc.CSLoader:createNode("GameMenu/HallLayer.csb") 
    sysNode:getChildByName("text_score"):setString((UserInfo:instance():getScore())/100) --用户剩余积分文本
    sysNode:getChildByName("text_win"):setString(0/100)

    self:addChild(sysNode) 
     
    local  btn_menu = sysNode:getChildByName("btn_menu")
    btn_menu:addTouchEventListener(function(sender, eventType) 
            if eventType == ccui.TouchEventType.ended then
                ccexp.AudioEngine:play2d("Hall/Sound/Button.mp3")
                cc.Director:getInstance():getRunningScene():addChild(import("Hall/SystemLayer").new(exitFunction, helpfunc), 8)
                --self:addChild(import("Hall/SystemLayer").new(exitFunction), 10)
                --self:addChild(import("Hall/ExitLayer").new(exitFunction), 10)
            end
        end)

    local scoreText = sysNode:getChildByName("text_score")
    local winText = sysNode:getChildByName("text_win")
    -- 监听刷新
    local function eventCustomRefush(event)
        print("eventCustomRefush")
        local userData = event._usedata
        if userData then 
            local str = string.split(userData,'_')
            scoreText:setString("" .. tonumber(str[1])/100)
            winText:setString("" .. tonumber(str[2])/100)
        else 
            UserInfo:instance():UpdateModifyScore() 
            local score = UserInfo:instance():getScore()/100
            print("" .. score)
            scoreText:setString("" .. score)
            winText:setString("0")
        end 
    end

    -- 监听下注成功
    local function eventCustomBetRet(event)
        print("eventCustomBetRet")
        local userData = event._usedata
        -- local success = nil
        -- if userData then 
        --     -- 显示成功
        --     success = cc.Sprite:create("Hall/ok.png")
        -- else 
        --     -- 显示失败
        --     success = cc.Sprite:create("Hall/no.png")
        -- end 

        -- self:addChild(success)
        -- success:setPosition(cc.p(640,-80))
        -- --success:setPosition(cc.p(750,210))
        -- success:runAction(cc.Sequence:create(cc.MoveTo:create(0.5,cc.p(640,360)),cc.DelayTime:create(3),cc.CallFunc:create(function() 
        --         success:removeFromParent(true)
        --     end )))
    end

    self.eventCustomRefushListener = cc.EventListenerCustom:create("eventCustomRefush",eventCustomRefush)
    eventDispatcher:addEventListenerWithFixedPriority(self.eventCustomRefushListener, 1)
    self.eventCustomBetRetListener = cc.EventListenerCustom:create("eventCustomBetRet",eventCustomBetRet)
    eventDispatcher:addEventListenerWithFixedPriority(self.eventCustomBetRetListener, 1)
end

return GameMenuLayer