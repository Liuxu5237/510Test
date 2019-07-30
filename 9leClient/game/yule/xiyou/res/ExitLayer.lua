--
-- Author: Your Name
-- Date: 2015-09-23 16:59:22
--
local ExitLayer = class("ExitLayer", function ()
    return cc.Layer:create()
end)

function ExitLayer:ctor(exitfunc)
    self:init(exitfunc)
end

function ExitLayer:onEnter()
	print("ExitLayer OnEnter")
end 

function ExitLayer:onExit()
	print("ExitLayer OnExit")
end 

function ExitLayer:init(exitfunc)
    self:registerScriptHandler(function (event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end)

    local node = cc.CSLoader:createNode("ExitLayer.csb")
    self:addChild(node)

   local cancelButton = node:getChildByName("Cancel")
    cancelButton:addTouchEventListener(function(sender, eventType) 
        	if eventType == TOUCH_EVENT_ENDED then
                AudioEngine.playEffect("mp3/Button.mp3")
            	print("cancelButton Clicked!")
            	self:removeFromParent(true)
        	end
    	end)

    local confirmButton = node:getChildByName("Confirm")
    confirmButton:addTouchEventListener(function(sender, eventType) 
            if eventType == TOUCH_EVENT_ENDED then
                AudioEngine.playEffect("mp3/Button.mp3")
                print("confirmButton Clicked!")
				cc.FileUtils:getInstance():purgeCachedEntries() --清空缓存
                if exitfunc then 
                    exitfunc()
                end 
                ExitGame()
            end
        end)
end 

return ExitLayer