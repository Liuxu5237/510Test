--
-- Author: Your Name
-- Date: 2015-09-24 18:58:25
--

local SlotLayer = class("SlotLayer", function ()
    return cc.Layer:create()
end)

require "cocos.init"
local module_pre = "game.yule.xiyou.src"
local Data = appdf.req(module_pre .. ".models.Data")
local scheduler = cc.Director:getInstance():getScheduler()
local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
local schedulerEntry = nil 
local ArmatureDataMgr = ccs.ArmatureDataManager:getInstance()

function SlotLayer:ctor(scene)
    self._scene = scene
    self:init()
end

function SlotLayer:onEnter()
	--Data.nTurnIndex = 0
    cc.SpriteFrameCache:getInstance():addSpriteFrames("light0.plist")
end 

function SlotLayer:onExit()
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("light0.plist")
    if self.schedulerEntry then 
        scheduler:unscheduleScriptEntry(self.schedulerEntry)
        self.schedulerEntry = nil
    end

    if self.SlotStopOne then 
        eventDispatcher:removeEventListener(self.SlotStopOne)
    end 
    
    if self.SlotStopTwo then 
        eventDispatcher:removeEventListener(self.SlotStopTwo)
    end

    if self.BeginSlotEvent then 
        eventDispatcher:removeEventListener(self.BeginSlotEvent)
    end
end 

function SlotLayer:init()
	self:setTouchEnabled(true)
	self:registerScriptHandler(function (event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end)

    local slotBack = cc.Sprite:create("General/SlotBack.png")
    self:addChild(slotBack)

    local drawNode = cc.Sprite:create("General/Black.png")
    --drawNode:setScale(1.08)
    local clipNode = cc.ClippingNode:create()
    clipNode:setPosition(cc.p(102,88))
    clipNode:setStencil(drawNode)
    --clipNode:setContentSize(100,100)
    slotBack:addChild(clipNode)

    self.slotHead = cc.Node:create()
    self.slotHead:setContentSize(cc.size(124,568*2))
    local head = cc.Sprite:create("General/Head_1.png")
    head:setAnchorPoint(0.5,0.125)
    head:setPosition(cc.p(0,0))

    local head1 = cc.Sprite:create("General/Head_1.png")
    head1:setAnchorPoint(0.5,0.125)
    head1:setPosition(cc.p(0,568))
    self.slotHead:addChild(head,0,0)
    self.slotHead:addChild(head1,0,1)
    clipNode:addChild(self.slotHead)

    drawNode = cc.Sprite:create("General/Black.png")
    --drawNode:setScale(1.08)
    clipNode = cc.ClippingNode:create()
    clipNode:setPosition(cc.p(242,88))
    clipNode:setStencil(drawNode)
    --clipNode:setContentSize(100,100)
    slotBack:addChild(clipNode)

    self.slotHead1 = cc.Node:create()
    self.slotHead1:setContentSize(cc.size(124,568*2))
    head = cc.Sprite:create("General/Head_1.png")
    head:setAnchorPoint(0.5,0.125)
    head:setPosition(cc.p(0,0))

    head1 = cc.Sprite:create("General/Head_1.png")
    head1:setAnchorPoint(0.5,0.125)
    head1:setPosition(cc.p(0,568))
    self.slotHead1:addChild(head,0,0)
    self.slotHead1:addChild(head1,0,1)
    clipNode:addChild(self.slotHead1)

    --self:beginSlot()
    self.SlotOneCanStop = false 
    self.SlotTwoCanStop = false
    self.SlotOneStop = true
    self.SlotTwoStop = true
    -- 转动监听
    self.SlotStopOne = cc.EventListenerCustom:create("SlotStopOne",function() 
            self.SlotOneCanStop = true
        end )

    self.SlotStopTwo = cc.EventListenerCustom:create("SlotStopTwo",function() 
            self.SlotTwoCanStop = true
        end )

    self.BeginSlotEvent = cc.EventListenerCustom:create("BeginSlotEvent",function() 
            self:beginSlot()
        end )

end 



function SlotLayer:beginSlot()
    self.slotHead:getChildByTag(0):setSpriteFrame(cc.Sprite:create("General/Head_2.png"):getSpriteFrame())
    self.slotHead:getChildByTag(1):setSpriteFrame(cc.Sprite:create("General/Head_2.png"):getSpriteFrame())
    self.slotHead1:getChildByTag(0):setSpriteFrame(cc.Sprite:create("General/Head_2.png"):getSpriteFrame())
    self.slotHead1:getChildByTag(1):setSpriteFrame(cc.Sprite:create("General/Head_2.png"):getSpriteFrame())
    self.SlotOneStop = false
    self.SlotTwoStop = false
    self.SlotOneCanStop = false 
    self.SlotTwoCanStop = false

    self.loopTimes = 0
    self.loopTimes1 = 0
    self.head1End = nil
    self.head2End = nil
    -- 开始循环
    local resumeGrossini = function(time)
            if not self.SlotOneStop then 
                local posy = self.slotHead:getPositionY()
                posy = posy + time*-850
                if posy < -568 then 
                    self.loopTimes = self.loopTimes + 1
                    posy = posy + 568
                end 

                -- 可停止
                if self.loopTimes >= 5 then 
                    if not self.SlotOneCanStop then 
                        self.SlotOneCanStop = true
                    end
                end 

                self.slotHead:setPositionY(posy)

                -- 可停止
                if self.SlotOneCanStop then 
                    local targetY = Data.nStartRoll[1]*-142
                    if posy >  targetY - 20 and posy < targetY + 20 then 
                        self.SlotOneStop = true
                        self.SlotOneCanStop = false
                        self.slotHead:setPositionY(targetY)
                        -- 切换资源
                        self.slotHead:getChildByTag(0):setSpriteFrame(cc.Sprite:create("General/Head_1.png"):getSpriteFrame())
                        self.slotHead:getChildByTag(1):setSpriteFrame(cc.Sprite:create("General/Head_1.png"):getSpriteFrame())
                    end 
                end 
            end 

            if not self.SlotTwoStop then
                -----------------
                local posy = self.slotHead1:getPositionY()
                posy = posy + time*-850
                if posy < -568 then 
                    self.loopTimes1 = self.loopTimes1 + 1
                    posy = posy + 568
                end 

                if self.loopTimes1 >= 7 then 
                    if not self.SlotTwoCanStop then 
                        self.SlotTwoCanStop = true
                    end 
                end 

                self.slotHead1:setPositionY(posy)

                -- 可停止
                if self.SlotTwoCanStop then 
                    local target1Y = Data.nStartRoll[2]*-142
                    if posy >  target1Y - 20 and posy < target1Y + 20 then 
                        self.SlotTwoStop = true
                        self.SlotTwoCanStop = false
                        self.slotHead1:setPositionY(target1Y)
                        -- 切换资源
                        self.slotHead1:getChildByTag(0):setSpriteFrame(cc.Sprite:create("General/Head_1.png"):getSpriteFrame())
                        self.slotHead1:getChildByTag(1):setSpriteFrame(cc.Sprite:create("General/Head_1.png"):getSpriteFrame())
                    end 
                end
            end 

            if self.SlotOneStop and self.SlotTwoStop then 
                if self.schedulerEntry then 
                    scheduler:unscheduleScriptEntry(self.schedulerEntry)
                    self.schedulerEntry = nil
                    
                    if Data.nStartRoll[1] == Data.nStartRoll[2] then 
                        AudioEngine.playEffect("Sound/DoubleRole.mp3")

                        
                        ArmatureDataMgr:addArmatureFileInfo("Edit/light.ExportJson");
                        local skillshow = ccs.Armature:create("light")
                        skillshow:setPosition(cc.p(0,0))
                        --local node = cc.CSLoader:createNode("Edit/BattleLayer.csb")
                        skillshow:getAnimation():playWithIndex(0, -1, 0)
                        self:addChild(skillshow,1)
                    end 
                    
                    self:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function()
                            Data.MapSpeed = 150
                            local event = cc.EventCustom:new("EndSlotTurnNext")
                            eventDispatcher:dispatchEvent(event)
                        end )))
                end
            end 
        end 

    self.schedulerEntry = scheduler:scheduleScriptFunc(resumeGrossini, 0, false)
end 

return SlotLayer