--
-- Author: Your Name
-- Date: 2015-09-14 15:20:29
--
local MapLayer = class("MapLayer", function ()
    return cc.Layer:create()
end)

local module_pre = "game.yule.xiyou.src"
local Data = appdf.req(module_pre .. ".models.Data")
local scheduler = cc.Director:getInstance():getScheduler()
local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
local ArmatureDataMgr = ccs.ArmatureDataManager:getInstance()

function MapLayer:ctor(scene)
    self._scene = scene
	-- 块宽
	self.blockx = 200
    -- 宽块数
    self.blockcount = 10

    self:init()
end

function MapLayer:onEnter()
	print("MapLayer OnEnter")
	--cc.SpriteFrameCache:getInstance():addSpriteFrames("zwoptex/grossini.plist")
	--cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("animations/grossini-aliases.plist")
    ArmatureDataMgr:addArmatureFileInfo("Fight/Action.ExportJson");
    ArmatureDataMgr:addArmatureFileInfo("Fight/Action_1.ExportJson");  
    ArmatureDataMgr:addArmatureFileInfo("Fight/WuKongVS.ExportJson");     
    ArmatureDataMgr:addArmatureFileInfo("Fight/PK_BaoZou.ExportJson");
    ArmatureDataMgr:addArmatureFileInfo("Fight/PK_GZ_1.ExportJson"); 
    ArmatureDataMgr:addArmatureFileInfo("Fight/PK_ZZ_1.ExportJson");
    ArmatureDataMgr:addArmatureFileInfo("Fight/PK_Monkey.ExportJson");
    ArmatureDataMgr:addArmatureFileInfo("Fight/PK_LW_1.ExportJson");
    ArmatureDataMgr:addArmatureFileInfo("Fight/PK_YJ_3.ExportJson");
    ArmatureDataMgr:addArmatureFileInfo("Fight/BossWin.ExportJson");
    ArmatureDataMgr:addArmatureFileInfo("Fight/TypeResult.ExportJson");
    Data.bJackpot2 = true
end 

function MapLayer:onExit()
	print("MapLayer OnExit")
    if self.secedulocalUpdate then 
        scheduler:unscheduleScriptEntry(self.secedulocalUpdate)
        self.secedulocalUpdate = nil 
    end

    if self.EndSlotTurnListener then 
        eventDispatcher:removeEventListener(self.EndSlotTurnListener)
    end 
    
    if self.BeginSlotTurnNextListener then 
        eventDispatcher:removeEventListener(self.BeginSlotTurnNextListener)
    end

    if self.EndSlotTurnTwoListener then 
        eventDispatcher:removeEventListener(self.EndSlotTurnTwoListener)
    end
    
end 

function MapLayer:init()
	self:registerScriptHandler(function (event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end)

    local spriteBack = {}
    for i = 1, 20 do 
        spriteBack[i] = cc.Sprite:create("Maps/0/Map_" .. string.format("%02d",i) .. ".png")
        spriteBack[i]:setAnchorPoint(cc.p(0,0))
        spriteBack[i]:setPosition(cc.p((i-1)*240,0))
        self:addChild(spriteBack[i],0)
        --spriteBack[i]:setScaleY(2)
        if i <= 6 then 
            spriteBack[i+20] = cc.Sprite:create("Maps/0/Map_" .. string.format("%02d",i) .. ".png")
            spriteBack[i+20]:setAnchorPoint(cc.p(0,0))
            spriteBack[i+20]:setPosition(cc.p((i-1)*240+4800,0))
            --spriteBack[i+20]:setScaleY(2)
            self:addChild(spriteBack[i+20],0)
        end 
    end 

    self:setPositionX(-4800)
    local offsetX = 0
    local oldUpdate = 0
    local speed = 150
    
    self.secedulocalUpdate = scheduler:scheduleScriptFunc( function(time)
            local posx = self:getPositionX()+Data.MapSpeed*time
            if posx >0 then 
                posx = posx - 4800
            end 
            self:setPositionX(posx)
            
        end, 0, false)

    -- 头像停止转动
    self.EndSlotTurnListener = cc.EventListenerCustom:create("EndSlotTurnNext",function() 
            if self.secedulocalUpdate then 
                scheduler:unscheduleScriptEntry(self.secedulocalUpdate)
                self.secedulocalUpdate = nil 
            end

            self.secedulocalUpdate = scheduler:scheduleScriptFunc( function(time)
                local posx = self:getPositionX()+150*time
                if posx >0 then 
                    posx = posx - 4800
                end 
                self:setPositionX(posx)
                
                end, 0, false)
        end )

    self.EndSlotTurnTwoListener = cc.EventListenerCustom:create("EndSlotTurnTwoNext",function() 
            if self.secedulocalUpdate then 
                scheduler:unscheduleScriptEntry(self.secedulocalUpdate)
                self.secedulocalUpdate = nil 
            end

            self.secedulocalUpdate = scheduler:scheduleScriptFunc( function(time)
                local posx = self:getPositionX()+150*time
                if posx >0 then 
                    posx = posx - 4800
                end 
                self:setPositionX(posx)
                
                end, 0, false)
        end )

    self.BeginSlotTurnNextListener = cc.EventListenerCustom:create("BeginSlotTurnNext",function() 
            if self.secedulocalUpdate then 
                scheduler:unscheduleScriptEntry(self.secedulocalUpdate)
                self.secedulocalUpdate = nil 
            end

            self.secedulocalUpdate = scheduler:scheduleScriptFunc( function(time)
                local posx = self:getPositionX()+850*time
                if posx >0 then 
                    posx = posx - 4800
                end 
                self:setPositionX(posx)
                
                end, 0, false)
        end )

    eventDispatcher:addEventListenerWithFixedPriority(self.EndSlotTurnListener, 1)
    eventDispatcher:addEventListenerWithFixedPriority(self.BeginSlotTurnNextListener, 1)
    eventDispatcher:addEventListenerWithFixedPriority(self.EndSlotTurnTwoListener, 1)
end 

function MapLayer:updateBlock(posParentX)
	--local offset = math.mod(posParentX,2000)
	--local curBlock, posCur = math.modf(offset/-200)
	
end



return MapLayer