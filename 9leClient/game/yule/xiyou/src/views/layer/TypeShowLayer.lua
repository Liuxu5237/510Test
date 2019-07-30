--
-- Author: Your Name
-- Date: 2015-09-29 10:12:36
--
local TypeShowLayer = class("TypeShowLayer", function ()
    return cc.Layer:create()
end)

require "cocos.init"
local module_pre = "game.yule.xiyou.src"
local Data = appdf.req(module_pre .. ".models.Data")
local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
local scheduler = cc.Director:getInstance():getScheduler()
local schedulerEntry = nil 
local ArmatureDataMgr = ccs.ArmatureDataManager:getInstance()
local ResultLayer = appdf.req(appdf.GAME_SRC.."yule.xiyou.src.views.layer.ResultLayer")

function TypeShowLayer:ctor(result,scene)
    self._scene = scene
    print("TypeShowLayer:ctor()")
    self.resultType = result
    self:init()
end

function TypeShowLayer:onEnter()
end 

function TypeShowLayer:onExit()
    if schedulerEntry then 
        scheduler:unscheduleScriptEntry(schedulerEntry)
        schedulerEntry = nil
    end
end 

function TypeShowLayer:init()
	self:setTouchEnabled(true)
	self:registerScriptHandler(function (event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end)

    --Data.sureBet = 0
    -- 更新
    local event = cc.EventCustom:new("eventCustomRefush")
    eventDispatcher:dispatchEvent(event)

    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
            Data.FightBG:setVisible(false)
            print("进来11111222222")
    		if Data.nStartType == 0 then 
                self:showBaseResult()
            else
                self:showTypeResult()
            end 
        end ),cc.DelayTime:create(7),cc.CallFunc:create(function()
            local ResultLayer = ResultLayer:create(self)
            self:getParent():addChild(ResultLayer, 20,199)
    		self:removeFromParent(true)
            --print("SendGameMsg(Data.SUB_C_ROUND_END)")
            --SendGameMsg(Data.SUB_C_ROUND_END,0,"")  

            -- 发送开始下一轮消息
            if Data.resultAudioID then 
                AudioEngine:pauseEffect(Data.resultAudioID)
                Data.resultAudioID = nil
            end 
    	end )))

end 

-- 一般奖励
function TypeShowLayer:showBaseResult()
    local index = Data.nStartIndex[1]
    if index == 0 or index == 13 then 
        index = Data.nStartIndex[2]
    end 

    local color = ((index%13)-1)%3
    local typeSprite = cc.Sprite:create("Reward/" .. color .. ".png")
    typeSprite:setAnchorPoint(0.5,0.5)
    typeSprite:setPosition(cc.p(640,360))
    typeSprite:setScale(10)
    typeSprite:runAction(cc.ScaleTo:create(0.5,1.25))
    self:addChild(typeSprite)

    local roleid = math.floor(((index %13)-1)/3)
    local rolelist = {"Sun","sha","Niu","Monkey"}
    -- 角色
    local roleSprite = cc.Sprite:create("General/" .. rolelist[roleid+1] .. ".png")
    roleSprite:setAnchorPoint(0.5,0.5)
    roleSprite:setPosition(cc.p(94,94))
    typeSprite:addChild(roleSprite)

    local doubleIndex = {1,5,9,2,6,10,3,7,11,0,4,8,12,13,14}
    local initDouble = {}
    for i = 1, 3 do 
        for j =1, 4 do 
            local double = Data.arrayProbability[Data.nInitDouble[i]+1]
            initDouble[(i-1)*4+j] = double[j]
        end 
    end 
    initDouble[13] = 2
    initDouble[14] = 8
    initDouble[15] = 2

    local value = initDouble[doubleIndex[(index %13)]+1]
    local typeMusic = {"Sound/Bank.mp3","Sound/Tie.mp3","Sound/Player.mp3"} 
    

    print(" value " .. value)
    local doubleShow = cc.LabelTTF:create("" .. value, "Arial", 46) --cc.LabelAtlas:_create("" .. value ,"Hall/Num/Num_1.png",40,40,46)
    doubleShow:setAnchorPoint(cc.p(0.5,0.5))
    doubleShow:setScale(0.5)
    doubleShow:setRotation(90)
    doubleShow:setPosition(cc.p(94+70,94))
    typeSprite:addChild(doubleShow, 1)

    doubleShow = cc.LabelTTF:create("" .. value, "Arial", 46)--cc.LabelAtlas:_create("" .. value ,"Hall/Num/Num_1.png",40,40,46)
    doubleShow:setAnchorPoint(cc.p(0.5,0.5))
    doubleShow:setScale(0.5)
    doubleShow:setRotation(270)
    --doubleShow:setRotation3D(cc.vec3(0,180,0))
    doubleShow:setPosition(cc.p(94-70,94))
    typeSprite:addChild(doubleShow, 1)

    doubleShow = cc.LabelTTF:create("" .. value, "Arial", 46)--cc.LabelAtlas:_create("" .. value ,"Hall/Num/Num_1.png",40,40,46)
    doubleShow:setAnchorPoint(cc.p(0.5,0.5))
    doubleShow:setScale(0.5)
    
    doubleShow:setPosition(cc.p(94,94-70))
    typeSprite:addChild(doubleShow, 1)

    doubleShow = cc.LabelTTF:create("" .. value, "Arial", 46)--cc.LabelAtlas:_create("" .. value ,"Hall/Num/Num_1.png",40,40,46)
    doubleShow:setAnchorPoint(cc.p(0.5,0.5))
    doubleShow:setScale(0.5)
    
    doubleShow:setPosition(cc.p(94,94+70))
    typeSprite:addChild(doubleShow, 1)

    AudioEngine.playEffect(typeMusic[Data.nStartColor+1])
    self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function()
            AudioEngine.playEffect("Sound/Role_" .. (index %13) .. ".mp3")
        end ),cc.DelayTime:create(2.5),cc.CallFunc:create(function()
            local typeIndex = math.floor(((index%13)-1)/3)
            AudioEngine.playEffect("Sound/" .. typeIndex ..".mp3")
        end )))
end

-- 特殊奖励
function TypeShowLayer:showTypeResult()
    local index = Data.nStartIndex[1]
    if index == 0 or index == 13 then 
        index = Data.nStartIndex[2]
    end 
    
    AudioEngine.playEffect("Sound/Reward_Open.mp3")

    local color = ((index%13)-1)%3
    local typeSprite = cc.Sprite:create("Reward/" .. color .. ".png")
    typeSprite:setAnchorPoint(0.5,0.5)
    typeSprite:setPosition(cc.p(640,360))
    typeSprite:setScale(10)
    typeSprite:runAction(cc.ScaleTo:create(0.5,1.25))
    self:addChild(typeSprite)

    local roleid = math.floor(((index %13)-1)/3)
    local rolelist = {"Sun","sha","Niu","Monkey"}
    -- 角色
    local roleinfo = "General/" .. rolelist[roleid+1] .. ".png"
    print("role info  " .. roleinfo)
    local roleSprite = cc.Sprite:create(roleinfo)
    roleSprite:setAnchorPoint(0.5,0.5)
    roleSprite:setPosition(cc.p(94,94))
    typeSprite:addChild(roleSprite)

    local doubleIndex = {1,5,9,2,6,10,3,7,11,0,4,8,12,13,14}
    local initDouble = {}
    for i = 1, 3 do 
        for j =1, 4 do 
            local double = Data.arrayProbability[Data.nInitDouble[i]+1]
            initDouble[(i-1)*4+j] = double[j]
        end 
    end 
    initDouble[13] = 2
    initDouble[14] = 8
    initDouble[15] = 2

    local value = initDouble[doubleIndex[(index %13)]+1]
    --print(" value " .. value)
    local doubleShow = cc.LabelTTF:create("" .. value, "Arial", 46)--cc.LabelAtlas:_create("" .. value ,"Hall/Num/Num_1.png",40,40,46)
    doubleShow:setAnchorPoint(cc.p(0.5,0.5))
    doubleShow:setScale(0.5)
    doubleShow:setRotation(90)
    doubleShow:setPosition(cc.p(94+70,94))
    typeSprite:addChild(doubleShow, 1)

    doubleShow = cc.LabelTTF:create("" .. value, "Arial", 46)--cc.LabelAtlas:_create("" .. value ,"Hall/Num/Num_1.png",40,40,46)
    doubleShow:setAnchorPoint(cc.p(0.5,0.5))
    doubleShow:setScale(0.5)
    doubleShow:setRotation(270)
    --doubleShow:setRotation3D(cc.vec3(0,180,0))
    doubleShow:setPosition(cc.p(94-70,94))
    typeSprite:addChild(doubleShow, 1)

    doubleShow = cc.LabelTTF:create("" .. value, "Arial", 46)--cc.LabelAtlas:_create("" .. value ,"Hall/Num/Num_1.png",40,40,46)
    doubleShow:setAnchorPoint(cc.p(0.5,0.5))
    doubleShow:setScale(0.5)
    
    doubleShow:setPosition(cc.p(94,94-70))
    typeSprite:addChild(doubleShow, 1)

    doubleShow = cc.LabelTTF:create("" .. value, "Arial", 46)--cc.LabelAtlas:_create("" .. value ,"Hall/Num/Num_1.png",40,40,46)
    doubleShow:setAnchorPoint(cc.p(0.5,0.5))
    doubleShow:setScale(0.5)
    
    doubleShow:setPosition(cc.p(94,94+70))
    typeSprite:addChild(doubleShow, 1)

    -- 庄闲和音效
    local typeMusic = {"Sound/Bank.mp3","Sound/Tie.mp3","Sound/Player.mp3"} 
    local typeSprite = cc.Sprite:create("Reward/" .. Data.nStartType .. ".png")
    
    typeSprite:setAnchorPoint(0.5,0.5)
    typeSprite:setPosition(cc.p(360,360))
    typeSprite:setScale(10)
    typeSprite:runAction(cc.ScaleTo:create(0.5,1.25))
    self:addChild(typeSprite)
    
    --if Data.nStartType ~= Data.Choi_Line then 
        --AudioEngine.playEffect("Sound/Reward_" .. Data.nStartType .. ".mp3")
    --end 
    AudioEngine.playEffect(typeMusic[Data.nStartColor+1])
    self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function()
            AudioEngine.playEffect("Sound/Role_" .. (index %13) .. ".mp3")
        end ),cc.DelayTime:create(2.5),cc.CallFunc:create(function()
            local typeIndex = math.floor(((index%13)-1)/3)
            AudioEngine.playEffect("Sound/" .. typeIndex ..".mp3")
        end )))
end

function TypeShowLayer:showSelf()

    --[[
    local back = cc.Sprite:create("Maps/back_0.png")
    back:setPosition(640, 360)
    local animFrames = {}
    for i = 0, 3 do 
        local frame = cc.Sprite:create( string.format("Maps/back_%d.png", i)):getSpriteFrame()
        animFrames[i] = frame
    end

    repeatAction = cc.RepeatForever:create(cc.Animate:create(cc.Animation:createWithSpriteFrames(animFrames, 0.25)))
    back:runAction(repeatAction)

    self:addChild(back)

    local typeResult = cc.Sprite:create("Reward/" .. self.resultType ..  "/0.png")
    typeResult:setPosition(640, 360)
    animFrames = {}
    for i = 0, 6 do 
        local frame = cc.Sprite:create( string.format("Reward/%d/%d.png",self.resultType ,i)):getSpriteFrame()
        animFrames[i] = frame
    end

    animation = cc.Animation:createWithSpriteFrames(animFrames, 0.15)
    typeResult:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.Animate:create(animation),cc.DelayTime:create(2.5),
        cc.CallFunc:create(function()
                typeResult:removeFromParent(true)
            end)
        ))

    self:addChild(typeResult, 1)
    ]]
end 



return TypeShowLayer