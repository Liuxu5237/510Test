--
-- Author: Your Name
-- Date: 2015-09-23 16:59:22
--
local SystemLayer = class("SystemLayer", function ()
    return cc.Layer:create()
end)

local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

function SystemLayer:ctor(exitfunc, helpfunc)
    self:init(exitfunc,helpfunc)
end
-- 140 524
function SystemLayer:onEnter()
	print("SystemLayer OnEnter")
end 

function SystemLayer:onExit()
	print("SystemLayer OnExit")
    if self.BetTimeEndSystemListener then 
        eventDispatcher:removeEventListener(self.BetTimeEndSystemListener)
    end

    if self.removeEventListenerCallback then 
            self.removeEventListenerCallback()
            self.removeEventListenerCallback = nil 
    end
end 

function SystemLayer:init(exitfunc,helpfunc)
    self:registerScriptHandler(function (event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end)

    local node = cc.CSLoader:createNode("SystemLayer.csb")
    self:addChild(node)

    local function onTouchBegan(touch, event)
        return true
    end
    -- 获取按钮节点
    local panel = node:getChildByName("Panel")
    panel:runAction(cc.Spawn:create(cc.ScaleTo:create(0.15,1.0,1.0,1.0), cc.MoveTo:create(0.15,cc.p(140,570))))

    --local eventDispatcher = self:getEventDispatcher()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function(touches, event)
        if self.BetTimeEndSystemListener then 
            eventDispatcher:removeEventListener(self.BetTimeEndSystemListener)
        end
        --[[
        if self.removeEventListenerCallback then 
            self.removeEventListenerCallback()
            self.removeEventListenerCallback = nil 
        end 
        self:removeFromParent(true)
        ]]
        --self:addChild(import("Hall/ExitLayer").new(exitFunction), 10)
        local tmpAction = cc.Spawn:create(cc.MoveTo:create(0.15,cc.p(90,644)),cc.ScaleTo:create(0.15,0.3,0.3,0.3))
        panel:runAction(cc.Sequence:create(tmpAction, cc.CallFunc:create(function() 
                    self:removeFromParent(true)
                end)))
    end, cc.Handler.EVENT_TOUCH_ENDED)
    eventDispatcher:addEventListenerWithFixedPriority(listener, -129)

    self.removeEventListenerCallback = function()
            eventDispatcher:removeEventListener(listener)
        end 


    

    -- 返回大厅
    local lobbyButton = panel:getChildByName("Lobby")
    lobbyButton:addTouchEventListener(function(sender, eventType) 
            if eventType == TOUCH_EVENT_ENDED then
                ccexp.AudioEngine:play2d("Hall/Sound/Button.mp3")
                --[[
                cc.FileUtils:getInstance():purgeCachedEntries() --清空缓存
                if exitfunc then 
                    print("GameApp:exitGame success")
                    exitfunc()
                else 
                    print("GameApp:exitGame faild")
                end 
                ExitGame()]]
                cc.Director:getInstance():getRunningScene():addChild(import("ExitLayer").new(exitfunc), 129)
            end
        end)
    


    -- 帮助
    local helpButton = panel:getChildByName("Help")
    helpButton:addTouchEventListener(function(sender, eventType) 
            if eventType == TOUCH_EVENT_ENDED then
                ccexp.AudioEngine:play2d("Hall/Sound/Button.mp3")
                if helpfunc then 
                    helpfunc()
                end 
            end
        end)

     
    self.BetTimeEndSystemListener = cc.EventListenerCustom:create("BetTimeEndSystem",function() 
                local tmpAction = cc.Spawn:create(cc.MoveTo:create(0.15,cc.p(90,644)),cc.ScaleTo:create(0.15,0.3,0.3,0.3))
                panel:runAction(cc.Sequence:create(tmpAction, cc.CallFunc:create(function() 
                            self:removeFromParent(true)
                        end)))

                if self.BetTimeEndSystemListener then 
                    eventDispatcher:removeEventListener(self.BetTimeEndSystemListener)
                end
        end )

    eventDispatcher:addEventListenerWithFixedPriority(self.BetTimeEndSystemListener, 1)
end 

return SystemLayer