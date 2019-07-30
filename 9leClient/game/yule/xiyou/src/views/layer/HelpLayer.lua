--
-- Author: Your Name
-- Date: 2015-09-24 18:58:25
--

local HelpLayer = class("HelpLayer", function ()
    return cc.Layer:create()
end)

require "cocos.init"
local module_pre = "game.yule.xiyou.src"
local Data = appdf.req(module_pre .. ".models.Data")
local scheduler = cc.Director:getInstance():getScheduler()
local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
local schedulerEntry = nil 

function HelpLayer:ctor(scene)
    self._scene = scene
    self:init()
end

function HelpLayer:onEnter()
	--Data.nTurnIndex = 0
end 

function HelpLayer:onExit()
    
end 

function HelpLayer:init()
	self:setTouchEnabled(true)
    --self:setSwallowTouches(true)
	self:registerScriptHandler(function (event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end)

    local node = cc.CSLoader:createNode("Edit/HelpLayer.csb")
    self:addChild(node)

    pageView = node:getChildByName("PageView")
    for i = 1 , 4 do
        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(1334, 750))
            
        local imageView = ccui.ImageView:create()
        imageView:setTouchEnabled(true)
        imageView:setScale9Enabled(true)
        imageView:loadTexture("help/help".. i .. ".png")
        imageView:setContentSize(cc.size(1334, 750))
        imageView:setPosition(cc.p(layout:getContentSize().width / 2, layout:getContentSize().height / 2))
        layout:addChild(imageView)
            
        pageView:addPage(layout)
    end

    local function pageViewEvent(sender, eventType)
        if eventType == ccui.PageViewEventType.turning then
            local pageView = sender
            local pageInfo = string.format("page %d " , pageView:getCurPageIndex() + 1)
            local tmpPage = pageView:getCurPageIndex()
            if tmpPage == 0 then 
                node:getChildByName("ButtonLeft"):setEnabled(false)
                node:getChildByName("ButtonLeft"):setBright(false)
            elseif tmpPage == 3 then 
                node:getChildByName("ButtonRight"):setEnabled(false)
                node:getChildByName("ButtonRight"):setBright(false)
            else 
                node:getChildByName("ButtonRight"):setEnabled(true)
                node:getChildByName("ButtonRight"):setBright(true)
                node:getChildByName("ButtonLeft"):setEnabled(true)
                node:getChildByName("ButtonLeft"):setBright(true)
            end
        end
    end 

    pageView:addEventListener(pageViewEvent)

    -- 重置
    local resetButton = node:getChildByName("Return")
    resetButton:addTouchEventListener(function(sender, eventType) 
            if eventType == TOUCH_EVENT_ENDED then
                AudioEngine.playEffect("Hall/Sound/Button.mp3")
                print("resetButton Clicked!")
                self:removeFromParent(true)
            end
        end)

    local leftButton = node:getChildByName("ButtonLeft")
    leftButton:setEnabled(false)
    leftButton:setBright(false)

    local rightButton = node:getChildByName("ButtonRight")
    leftButton:addTouchEventListener(function(sender, eventType) 
            if eventType == TOUCH_EVENT_ENDED then
                AudioEngine.playEffect("Hall/Sound/Button.mp3")
                print("leftButton Clicked!")
                --self:removeFromParent(true)
                local tmpPage = pageView:getCurPageIndex() - 1
                if tmpPage <= 0 then 
                    tmpPage = 0
                    leftButton:setEnabled(false)
                    leftButton:setBright(false)
                else 
                    rightButton:setEnabled(true)
                    rightButton:setBright(true)
                end 
                pageView:scrollToPage(tmpPage)
            end
        end)

    
    rightButton:addTouchEventListener(function(sender, eventType) 
            if eventType == TOUCH_EVENT_ENDED then
                AudioEngine.playEffect("Hall/Sound/Button.mp3")
                print("rightButton Clicked!")
                --self:removeFromParent(true)
                local tmpPage = pageView:getCurPageIndex() + 1
                if tmpPage >= 3 then 
                    tmpPage = 3
                    rightButton:setEnabled(false)
                    rightButton:setBright(false)
                else 
                    leftButton:setEnabled(true)
                    leftButton:setBright(true)
                end

                pageView:scrollToPage(tmpPage)
            end
        end)
end 


return HelpLayer