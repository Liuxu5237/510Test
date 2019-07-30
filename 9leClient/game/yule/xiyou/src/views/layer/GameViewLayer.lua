--
-- Author: Your Name
-- Date: 2015-09-24 18:58:25
--

local GameViewLayer = class("GameViewLayer", function ()
    local gameViewLayer = display.newLayer()
    return gameViewLayer
end)

if not yl then
    require("client.src.plaza.models.yl")
end

require "cocos.init"
local ExternalFun 	    =  appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local module_pre = "game.yule.xiyou.src"
local Data = appdf.req(module_pre .. ".models.Data")
local scheduler = cc.Director:getInstance():getScheduler()
local BattleLayer = appdf.req(appdf.GAME_SRC.."yule.xiyou.src.views.layer.BattleLayer")
local BetLayer = appdf.req(appdf.GAME_SRC.."yule.xiyou.src.views.layer.BetLayer")
local MapLayer = appdf.req(appdf.GAME_SRC.."yule.xiyou.src.views.layer.MapLayer")
local TypeShowLayer = appdf.req(appdf.GAME_SRC.."yule.xiyou.src.views.layer.TypeShowLayer")
local SlotLayer = appdf.req(appdf.GAME_SRC.."yule.xiyou.src.views.layer.SlotLayer")
local HelpLayer = appdf.req(appdf.GAME_SRC.."yule.xiyou.src.views.layer.HelpLayer")
local QueryDialog = appdf.req("app.views.layer.other.QueryDialog")

local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
local schedulerEntry = nil 
local schedulerEnd = nil 
--local TypeShowLayer = import("script.TypeShowLayer")

local frameCache = cc.SpriteFrameCache:getInstance()
local musicID = nil
local musicBack = nil
local musicType = nil
local node = nil
GameViewLayer.WinTmpSprite    = nil
GameViewLayer.WinTmpSpriteWin = nil
GameViewLayer.WinJackpot      = nil
GameViewLayer.WinJackpotWin   = nil


function GameViewLayer:ctor(scene)
	--注册node事件
	ExternalFun.registerNodeEvent(self)
	self._scene = scene
    self:init()

end

function GameViewLayer:onEnter()
    math.randomseed(os.time()) 
	--Data.nTurnIndex = 0
    frameCache:addSpriteFrames("headAni.plist") 
    self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function()
        AudioEngine.playMusic("Sound/Back_0.mp3", true) 
    end )))
end 

function GameViewLayer:onExit()

    frameCache:removeSpriteFramesFromFile("headAni.plist")
    if schedulerEntry then 
        scheduler:unscheduleScriptEntry(schedulerEntry)
        schedulerEntry = nil
    end

    if musicID then 
        AudioEngine.stopMusic()
        musicID = nil
    end

    if schedulerEnd then 
        scheduler:unscheduleScriptEntry(schedulerEnd)
        schedulerEnd = nil
    end

    Data.canPlay = false
    -- 删除监听
    if self.eventCustomTurnListener then 
        eventDispatcher:removeEventListener(self.eventCustomTurnListener)
    end 

    if self.TurnListener then 
        eventDispatcher:removeEventListener(self.TurnListener)
    end 
    
    if self.EndTurnListener then 
        eventDispatcher:removeEventListener(self.EndTurnListener)
    end

    if self.EndSlotTurnListener then 
        eventDispatcher:removeEventListener(self.EndSlotTurnListener)
    end

    if self.ShakeListener then 
        eventDispatcher:removeEventListener(self.ShakeListener)
    end

    if self.BeginBetListener then 
        eventDispatcher:removeEventListener(self.BeginBetListener)
    end

    if self.EndBetListener then 
        eventDispatcher:removeEventListener(self.EndBetListener)
    end

    if self.BackPressListen then 
        eventDispatcher:removeEventListener(self.BackPressListen)
    end 

    if self.SlotVisibleFalseListener then 
        eventDispatcher:removeEventListener(self.SlotVisibleFalseListener)
    end 
    
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("YangJian.plist")
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("Monkey_VS.plist")
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("PK_1.plist")
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("PK_GZ_10.plist")
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("PK_BaoZou0.plist")
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("PK_LW_10.plist")
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("PK_Monkey0.plist")
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("PK_Monkey_20.plist")
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("PK_YJ_30.plist")
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("PK_ZZ_10.plist")

    self._scene:gameAppExit()
    --重置搜索路径
	local oldPaths = cc.FileUtils:getInstance():getSearchPaths();
	local newPaths = {};
	for k,v in pairs(oldPaths) do
		if tostring(v) ~= tostring(self._searchPath) then
			table.insert(newPaths, v);
		end
	end
    cc.FileUtils:getInstance():setSearchPaths(newPaths);
    self:stopAllActions()
	--停止音频
	AudioEngine.stopAllEffects()
    AudioEngine.stopMusic()
    
end 
--[[
--监听手机返回键
function GameViewLayer:return_key()
    --监听手机返回键
    local key_listener = cc.EventListenerKeyboard:create()
    --返回键回调
    
    --lua中得回调，分清谁绑定，监听谁，事件类型是什么
    key_listener:registerScriptHandler(key_return,cc.Handler.EVENT_KEYBOARD_PRESSED)
    local eventDispatch = self:getEventDispatcher()
    eventDispatch:addEventListenerWithSceneGraphPriority(key_listener,self)
end]]

function GameViewLayer:init()
    --cc.SpriteFrameCache:getInstance():addSpriteFrames("PK.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("PK_1.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("YangJian.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("Monkey_VS.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("PK_GZ_10.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("PK_BaoZou0.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("PK_LW_10.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("PK_Monkey0.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("PK_Monkey_20.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("PK_YJ_30.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("PK_ZZ_10.plist")
    print("qqqqqqqqqq1qqqqqqqq")
	self:setTouchEnabled(true)
	self:registerScriptHandler(function (event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end)

    self.BackPressListen = cc.EventListenerKeyboard:create()
    --返回键回调
    
    --lua中得回调，分清谁绑定，监听谁，事件类型是什么
    self.BackPressListen:registerScriptHandler(function(code, event) 
            print("GameViewLayer BackPressListen! " .. code)
            local runSence = cc.Director:getInstance():getRunningScene()
            if runSence then 
                runSence:addChild(import("Hall/ExitLayer").new(function() 
                        GameApp:exitGame()
                    end ) ,129)
            end
        end ,cc.Handler.EVENT_KEYBOARD_PRESSED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.BackPressListen,self)

    local map = MapLayer:create(self) 
    self:addChild(map,0)

    --加载csb
    node = cc.CSLoader:createNode("Edit/MainLayer.csb")
    self:addChild(node,2)
        
    self:initButton()
    
    self.Jackpot = node:getChildByName("JackpotNum")
    self.Jackpot:setPosition(cc.p(285,509))
    self.Jackpot:setString(string.format("%.2f", math.random(100000,999999)))
    Data.FightBG = node:getChildByName("BG")

    local cellPanel = node:getChildByName("CellPanel")
    cellPanel:setLocalZOrder(2)
    self.cell = {}
    for i = 1 , 26 do 
        self.cell[i] = cellPanel:getChildByName("Cell_" .. (i-1))
    end 

    self.battlePanel = node:getChildByName("BattlePanel")
    self.battlePanel:setVisible(true)


    -- 播放动画
    --self:playAni()
    --self:BeginTurnTable(20, 5)

    local slot =  SlotLayer:create(self)
    slot:setPosition(cc.p(420,360))  
    self:addChild(slot,1)

    local zhuang = cc.Sprite:create("General/Player.png")
    zhuang:setPosition(cc.p(1070,535))
    self:addChild(zhuang,1)
    zhuang:setVisible(false)

    schedulerEnd = scheduler:scheduleScriptFunc(function(time) 
            --SendGameMsg(Data.SUB_C_ROUND_END,0,"")
        end, 30, false)

    --self:playAniEnd()
    self:stopAllActions()

    -- 悟空站立
    self.wukong = cc.Node:create()
    local wukongspi = cc.Sprite:create("Ani/Stay/0.png")
    local wukongFrames = {}
        for i = 1,38 do 
            local sprite = cc.Sprite:create("Ani/Stay/" .. i-1 .. ".png")
            wukongFrames[i] = sprite:getSpriteFrame()
        end

    local wukongation = cc.Animation:createWithSpriteFrames(wukongFrames, 0.25)
    self:addChild(self.wukong,2)
    self.wukong:setPosition(cc.p(950,330))
    wukongspi:runAction(cc.RepeatForever:create(cc.Animate:create(wukongation)))
    wukongspi:setScale(1.25)
    self.wukong:addChild(wukongspi)
   
    -- 转动监听
    self.TurnListener = cc.EventListenerCustom:create("TurnNext",function() 
        print("转动11111")
            -- 南天门
            if Data.nBaozou == 1 and (Data.nStartIndex[1] == 0 or Data.nStartIndex[1] == 13) and Data.nStartIndexBegin == 2 then 
                --self.wukong:setVisible(false)
                Data.TurnFirst = true
                self:BeginTurnTable(Data.nStartIndex[Data.nStartIndexBegin], 100)
                Data.nStartIndexBegin = Data.nStartIndexBegin + 1
                -- 特殊奖励
                AudioEngine.playEffect("Sound/Cloud.mp3")
                -- 悟空站立
                --self.wukong:removeAllChildren(true)
                --local wukongspi = cc.Sprite:create("Ani/Chong/0.png")
                local wukongFrames = {}
                    for i = 1,6 do 
                        local sprite = cc.Sprite:create("Ani/Chong/" .. i-1 .. ".png")
                        wukongFrames[i] = sprite:getSpriteFrame()
                    end

                local wukongation = cc.Animation:createWithSpriteFrames(wukongFrames, 0.1)
                self.wukong:setPosition(cc.p(550,370))
                --self.wukong:addChild(wukongspi,2)
                --self.wukong:setScale(1.25)
                wukongspi:stopAllActions()
                wukongspi:runAction(cc.Sequence:create(cc.Animate:create(wukongation),cc.CallFunc:create(function()
                            self.wukong:setVisible(false)
                            if musicID then 
                                AudioEngine.stopMusic()
                                musicID = nil
                            end
                            musicID = 1; 

                            self:GameFightBegin()
                            AudioEngine.playMusic("Sound/BattleBack_".. Data.nStartRoll[1] .. ".mp3", true)

                            self.BattleLayer = BattleLayer:create(self)
                            self.battlePanel:addChild(self.BattleLayer, 12, 122)

                            AudioEngine.playEffect("Sound/Normal.mp3")
                        end )))
                
            else 
                 if Data.nStartIndex[Data.nStartIndexBegin] and Data.nStartIndex[Data.nStartIndexBegin] ~= -1 then 
                    Data.TurnFirst = false
                    AudioEngine.playEffect("Sound/Begin.mp3")
                    self:BeginTurnTable(Data.nStartIndex[Data.nStartIndexBegin], 1)
                    Data.nStartIndexBegin = Data.nStartIndexBegin + 1
                else 
                    print(" 【显示结果】 "..Data.GameTypeResult[Data.nStartType+1])

                     --感觉是这里 
                    local anifiles = {"Bank","Tie","Player"}
                    zhuang:stopAllActions()
                    zhuang:setTexture("General/" .. anifiles[Data.nStartColor+1] .. ".png")
                    -- Data.nStartType == 0  普通奖励
                    -- Data.nStartType >= 1  特殊奖励
                    local nTime = 0
                    local nResult = {"0","0","3","20","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20"}
                    if Data.nStartType > 0 then 
                        nTime = 4.5
                        Data.studioXiaoAni:setVisible(false)
                        Data.FightBG:setVisible(false)
                        Data.TypeResult = ccs.Armature:create("TypeResult")
                        Data.TypeResult:getAnimation():play("TypeResult_"..nResult[Data.nStartType], -1, 0)
                        Data.TypeResult:setPosition(cc.p(667,375))
                        Data.TypeResult:setScaleX(2.61)
                        Data.TypeResult:setScaleY(2.08)
                        Data.TypeResult:setLocalZOrder(0)
                        self:addChild(Data.TypeResult)      
                        musicType = AudioEngine.playEffect("Sound/FourInOne.mp3")       
                    end

                    self:runAction(cc.Sequence:create(cc.DelayTime:create(nTime),cc.CallFunc:create(function()
                        ----------------------【连线彩金】--------------------
                        self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(function()
                            if Data.nStartType == Data.Choi_Line then
                                Data.isJackpot = true
                                -- GameViewLayer.WinJackpot = cc.Sprite:create("General/Jackpot.png")
                                -- GameViewLayer.WinJackpot:setPosition(cc.p(288,515))
                                -- self:addChild(GameViewLayer.WinJackpot, 10)
                                
                                -- GameViewLayer.WinJackpotWin = cc.LabelAtlas:_create("" .. Data.GameJackpotScore,"General/NumScore.png",21,30,46)
                                -- GameViewLayer.WinJackpotWin:setAnchorPoint(cc.p(0.5,0.5))
                                -- GameViewLayer.WinJackpotWin:setPosition(cc.p(288,509))
                                -- self:addChild(GameViewLayer.WinJackpotWin, 20)

                                -- GameViewLayer.WinTmpSprite = cc.Sprite:create("Ani/Jackpot/0.png")
                                -- GameViewLayer.WinTmpSprite:setPosition(cc.p(640,525))
                                -- self:addChild(GameViewLayer.WinTmpSprite, 10)

                                -- GameViewLayer.WinTmpSpriteWin = cc.LabelAtlas:_create("" .. Data.GameJackpotWin,"General/Number1.png",20,32,46)
                                -- GameViewLayer.WinTmpSpriteWin:setAnchorPoint(cc.p(0.5,0.5))
                                -- GameViewLayer.WinTmpSpriteWin:setPosition(cc.p(640,508))
                                -- self:addChild(GameViewLayer.WinTmpSpriteWin, 20)
                            end
                        end )))
                        ------------------------------------------------------
                        if Data.nStartType > 0 then
                            AudioEngine.stopEffect(musicType)
                            Data.TypeResult:setVisible(false)
                        end
                        if Data.nStartType == Data.Choi_None then 
                            self:playAniGray()
                        end
                        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
                            self:playAniMusic()
                            slot:setVisible(false)
                        end )))
                        self:runAction(cc.Sequence:create(cc.DelayTime:create(3.0),cc.CallFunc:create(function()
                            self:playAni()
                        end )))
                        
                        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function()
                                if Data.isFight then
                                    Data.isFight = false
                                    Data.studioXiaoAni:setVisible(false)
                                end
                                local wukongFrames = {}
                                for i = 1,38 do 
                                    local sprite = cc.Sprite:create("Ani/Stay/" .. i-1 .. ".png")
                                    wukongFrames[i] = sprite:getSpriteFrame()
                                end

                                local wukongation = cc.Animation:createWithSpriteFrames(wukongFrames, 0.25)
                                wukongspi:stopAllActions()
                                wukongspi:runAction(cc.RepeatForever:create(cc.Animate:create(wukongation)))
                                self.wukong:setPosition(cc.p(950,330))
                                self.wukong:setVisible(true)

                                self.TypeShowLayer = TypeShowLayer:create(nil,self) 
                                self:addChild(self.TypeShowLayer, 10)
                                print("=================【战斗退出】=================")
                                --SendGameMsg(Data.SUB_C_ROUND_END,0,"") 
                            end ),cc.DelayTime:create(5),cc.CallFunc:create(function()
                                --self.battlePanel:setVisible(false)
                                --if musicID then 
                                    --ccexp.AudioEngine:stop(musicID)
                                    --musicID = nil
                                --end

                                --musicID = AudioEngine.playEffect("Sound/Back_0.mp3", true)
                        end )))
                    end )))
                end                
            end


        end)
 
    -- 战斗结束 停止转动
    self.EndTurnListener = cc.EventListenerCustom:create("EndTurnNext",function() 
            Data.studioXiaoAni:setVisible(false)
            -- 站立笑
            Data.studioXiaoAni = ccs.Armature:create("BossWin")
            if Data.WhoWin == 1 then
                Data.studioXiaoAni:getAnimation():play("WuKong_vs_Win", -1, 1)
            elseif Data.WhoWin == 2 then 
                Data.studioXiaoAni:getAnimation():play(Data.NewXiaoBattle[Data.nStartRoll[1]+1], -1, 1)
            end
            Data.studioXiaoAni:setPosition(cc.p(667,375))
            Data.studioXiaoAni:setScaleX(2.61)
            Data.studioXiaoAni:setScaleY(2.08)
            Data.studioXiaoAni:setLocalZOrder(1)
            node:addChild(Data.studioXiaoAni)
            self:endRotation()
            print("这里这里这里")
           
        end)

    -- 头像隐藏
    self.SlotVisibleFalseListener = cc.EventListenerCustom:create("SlotVisibleFalse",function() 
            print("33333333333333")
            slot:setVisible(false)
        end)

    self.ResetStayListener = cc.EventListenerCustom:create("ResetStay",function() 
            --slot:setVisible(false)
        end)

    -- 震动
    self.ShakeListener = cc.EventListenerCustom:create("ShakeScreen",function() 
            self.battlePanel:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),
                cc.MoveTo:create(0.05,cc.p(8,4)),
                cc.MoveTo:create(0.05,cc.p(4,8)),
                cc.MoveTo:create(0.05,cc.p(6,6)),
                cc.MoveTo:create(0.05,cc.p(0,0)),
                cc.MoveTo:create(0.05,cc.p(8,8)),
                cc.MoveTo:create(0.05,cc.p(4,4)),
                cc.MoveTo:create(0.05,cc.p(6,0)),
                cc.MoveTo:create(0.05,cc.p(0,0))
                    --cc.Spawn:create(cc.MoveBy:create(0.25,cc.p(-10,8)))
                ))
        end)

    -- 头像停止转动
    self.EndSlotTurnListener = cc.EventListenerCustom:create("EndSlotTurnNext",function() 
            -- 悟空切换动画

            local anifiles = {"Bank","Tie","Player"}
            local sprite1 = cc.Sprite:create("General/" .. anifiles[Data.nStartColor+1] .. ".png")
            zhuang:setSpriteFrame(sprite1:getSpriteFrame())
            if Data.nStartRoll[1] ~= Data.nStartRoll[2] or Data.nStartIndex[1] == 0 or Data.nStartIndex[1] == 13 then 
                
                local tmpNode = cc.Node:create()
                self:addChild(tmpNode)
                tmpNode:runAction(cc.Sequence:create(cc.DelayTime:create(2.5),cc.CallFunc:create(function() 
                                -- 停止
                               
                                local wukongFrames = {}
                                for i = 1,38 do 
                                    local sprite = cc.Sprite:create("Ani/Stay/" .. i-1 .. ".png")
                                    wukongFrames[i] = sprite:getSpriteFrame()
                                end

                                local wukongation = cc.Animation:createWithSpriteFrames(wukongFrames, 0.25)
                                wukongspi:stopAllActions()
                                wukongspi:runAction(cc.RepeatForever:create(cc.Animate:create(wukongation)))
                                
                            end ),cc.DelayTime:create(1.5),cc.CallFunc:create(function()
                                tmpNode:removeFromParent(true)
                                --闲庄跟动画一起停 从445行修改
                                
                                zhuang:stopAllActions()
                                zhuang:setTexture("General/" .. anifiles[Data.nStartColor+1] .. ".png")
                            end )
                        ))

                self:endRotation()
                if Data.nStartIndex[1] == 0 or Data.nStartIndex[1] == 13 then 
                    print("66666666666666666666666666")
                    --slot:setVisible(false)
                end 
                
            else
                AudioEngine.playEffect("Sound/Cloud.mp3")
                print("2222222222222222")
                slot:setVisible(false)
                -- 悟空站立
                --self.wukong:removeAllChildren(true)
                --local wukongspi = cc.Sprite:create("Ani/Chong/0.png")
                local wukongFrames = {}
                    for i = 1,6 do 
                        local sprite = cc.Sprite:create("Ani/Chong/" .. i-1 .. ".png")
                        wukongFrames[i] = sprite:getSpriteFrame()
                    end

                local wukongation = cc.Animation:createWithSpriteFrames(wukongFrames, 0.1)
                self.wukong:setPosition(cc.p(550,370))
                --self.wukong:addChild(wukongspi,2)
                --self.wukong:setScale(1.25)
                wukongspi:stopAllActions()
                wukongspi:runAction(cc.Sequence:create(cc.Animate:create(wukongation),cc.CallFunc:create(function()
                            self.wukong:setVisible(false)
                        end )))

                self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function()
                            if musicID then 
                                
                                AudioEngine.stopMusic()
                                musicID = nil
                            end
                            musicID = 1; 

                            self:GameFightBegin()
                            AudioEngine.playMusic("Sound/BattleBack_".. Data.nStartRoll[1] .. ".mp3", true)

                            self.BattleLayer = BattleLayer:create(self)
                            self.battlePanel:addChild(self.BattleLayer, 12, 122)

                        end )))
            end
        end)

    if Data.GameBegin then
        -- 普通
        Data.TurnFirst = true
        print(""..Data.nStartIndexBegin)
        dump(Data.nStartIndex,"有报错1")
        self:BeginTurnTable(Data.nStartIndex[Data.nStartIndexBegin], 100)
        Data.nStartIndexBegin = Data.nStartIndexBegin + 1
        
        local tmpNode = cc.Node:create()
        self:addChild(tmpNode)
        tmpNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function() 
                        local event = cc.EventCustom:new("BeginSlotTurnNext")
                        eventDispatcher:dispatchEvent(event)

                        AudioEngine.playEffect("Sound/Chong.mp3")          
                         -- 开始转动
                        slot:beginSlot()
                        AudioEngine.playEffect("Sound/Normal.mp3")
                       

                        local anifiles = {"Bank","Tie","Player"}
                        local animFrames = {}
                        for i = 1,3 do 
                            local sprite = cc.Sprite:create("General/" .. anifiles[i] .. ".png")
                            animFrames[i] = sprite:getSpriteFrame()
                        end

                        local animation = cc.Animation:createWithSpriteFrames(animFrames, 0.15)
                        zhuang:runAction(cc.RepeatForever:create(cc.Animate:create(animation)))  

                        -- 切换悟空动画
                        local wukongFrames = {}
                            for i = 1,11 do 
                                local sprite = cc.Sprite:create("Ani/Flying/" .. i-1 .. ".png")
                                wukongFrames[i] = sprite:getSpriteFrame()
                            end

                        local wukongation = cc.Animation:createWithSpriteFrames(wukongFrames, 0.07)
                        wukongspi:stopAllActions()
                        wukongspi:runAction(cc.RepeatForever:create(cc.Animate:create(wukongation)))
                        print("=======================================")
                    end ),cc.DelayTime:create(1.5),cc.CallFunc:create(function()
                        
                    end ),cc.DelayTime:create(1.5),cc.CallFunc:create(function()
                         -- 庄和闲
                         zhuang:stopAllActions()
                        tmpNode:removeFromParent(true)
                    end )
                ))

        

        --musicID = AudioEngine.playEffect("Sound/Back_0.mp3", true)
    else
        self:GameJackpot()
        Data.GameBegin = true
        self.pColorLayer = cc.LayerColor:create(cc.c4b(128, 128, 128, 255*0.75), 1334, 750)
        self:addChild(self.pColorLayer, 100)
        local tmpSprite = cc.Sprite:create("General/waitfornext.png")
        tmpSprite:setVisible(true)
        tmpSprite:setPosition(cc.p(677,375))
        self.pColorLayer:addChild(tmpSprite)
    end 
    --musicID = AudioEngine.playEffect("Sound/Back_0.mp3", true)
    musicId =1;
    self.BetLayer = nil
    -- 下注
    self.BeginBetListener = cc.EventListenerCustom:create("GameBeginBet",function() 
            if Data.NeedChange then 
                if musicID then  
                    AudioEngine.stopMusic()
                    musicID = nil
                end
                Data.BackMusic = Data.BackMusic + 1
                Data.BackMusic = Data.BackMusic%3
                musicID =1; 
                AudioEngine.playMusic("Sound/Back_".. Data.BackMusic .. ".mp3", true)
            end 

            if self.pColorLayer then 
                self.pColorLayer:removeFromParent(true)
                self.pColorLayer = nil
            end 

            local resultLayer = self:getChildByTag(199)
            if resultLayer then 
                resultLayer:removeFromParent(true)
                resultLayer = nil
            end 

            self.wukong:setVisible(true)
            slot:setVisible(false)
            print("-------------【开始下注】------------")
            Data.canPlay = false
            self:resetPlayAni()

            self.BetLayer = BetLayer:create(self)
            self:addChild(self.BetLayer, 12, 122)
           
        end )

    -- 结束下注【开始转动】
    self.EndBetListener = cc.EventListenerCustom:create("GameEndBet",function() 
            slot:setVisible(true)
            wukongspi:setSpriteFrame(cc.Sprite:create("Ani/Stay/0.png"):getSpriteFrame())
            self.battlePanel:removeAllChildren()
            self.battlePanel:setVisible(true)
            self.wukong:setPosition(cc.p(950,330))
            self.wukong:setVisible(true)

            if self.BetLayer then 
                self.BetLayer:removeFromParent(true)
                self.BetLayer = nil
                --self:removeChildByTag()
                
                -- 普通
                Data.TurnFirst = true
                self:BeginTurnTable(Data.nStartIndex[Data.nStartIndexBegin], 100)
                Data.nStartIndexBegin = Data.nStartIndexBegin + 1
                
                local tmpNode = cc.Node:create()
                self:addChild(tmpNode)
                tmpNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function() 
                                local event = cc.EventCustom:new("BeginSlotTurnNext")
                                eventDispatcher:dispatchEvent(event)

                                AudioEngine.playEffect("Sound/Chong.mp3")          
                                 -- 开始转动
                                slot:beginSlot()
                                AudioEngine.playEffect("Sound/Normal.mp3")
                                -- 庄和闲
                                zhuang:setVisible(true)
                                zhuang:stopAllActions()
                                local anifiles = {"Bank","Tie","Player"}
                                local animFrames = {}
                                for i = 1,3 do 
                                    local sprite = cc.Sprite:create("General/" .. anifiles[i] .. ".png")
                                    animFrames[i] = sprite:getSpriteFrame()
                                end

                                local animation = cc.Animation:createWithSpriteFrames(animFrames, 0.15)
                                zhuang:runAction(cc.RepeatForever:create(cc.Animate:create(animation)))  

                                -- 切换悟空动画
                                local wukongFrames = {}
                                    for i = 1,11 do 
                                        local sprite = cc.Sprite:create("Ani/Flying/" .. i-1 .. ".png")
                                        wukongFrames[i] = sprite:getSpriteFrame()
                                    end

                                local wukongation = cc.Animation:createWithSpriteFrames(wukongFrames, 0.07)
                                wukongspi:stopAllActions()
                                wukongspi:runAction(cc.RepeatForever:create(cc.Animate:create(wukongation)))
                                print("===================开始转动====================")
                                if Data.bJackpot1 then
                                    Data.bJackpot1 = false
                                    self:GameJackpot()
                                end
                            end ),cc.DelayTime:create(1.5),cc.CallFunc:create(function()
                                
                            end ),cc.DelayTime:create(1.5),cc.CallFunc:create(function()
                                tmpNode:removeFromParent(true)
                            end )
                        ))

            end 
        end )

    eventDispatcher:addEventListenerWithFixedPriority(self.TurnListener, 1)
    eventDispatcher:addEventListenerWithFixedPriority(self.EndTurnListener, 1)
    eventDispatcher:addEventListenerWithFixedPriority(self.EndSlotTurnListener, 1)
    eventDispatcher:addEventListenerWithFixedPriority(self.ShakeListener, 1)
    eventDispatcher:addEventListenerWithFixedPriority(self.BeginBetListener, 1)
    eventDispatcher:addEventListenerWithFixedPriority(self.EndBetListener, 1)
    eventDispatcher:addEventListenerWithFixedPriority(self.SlotVisibleFalseListener, 1)
end 

-- 初始转动设置
function GameViewLayer:BeginTurnTable(nTurnTableTarget, nTimes)
    print ("nTurnTableTarget " ..  nTurnTableTarget)
    print ("Data.nTurnIndex " ..  Data.nTurnIndex)
    Data.nTurnTransit = Data.TURN_TABLE_MAX*nTimes 
    if nTurnTableTarget > Data.nTurnIndex then 
        Data.nTurnTransit = Data.nTurnTransit + (nTurnTableTarget - Data.nTurnIndex)
    else 
        Data.nTurnTransit = Data.nTurnTransit + (Data.TURN_TABLE_MAX - Data.nTurnIndex) + nTurnTableTarget
    end 

    -- 重置Cell状态

    -- 亮的个数
    Data.nBrightCount = 1
    Data.nTurnTarget = nTurnTableTarget
    Data.nTurnTableCount = 10
    Data.nTurnTableDelay = Data.nTurnTableCount
    Data.bTurnTable = true 
    Data.nTurnIndex = Data.nTurnIndex - 1
    Data.nTurnCount = 0

    -- 开始循环
    local resumeGrossini = function(time)
            if Data.bTurnTable then 
                if Data.TurnFirst then  
                    Data.updateTime = Data.updateTime + time 
                    if Data.updateTime > 0.02 then 
                        self:updateRotation(time)
                        Data.updateTime = Data.updateTime - 0.02
                    end 
                    
                else
                    self:updateRotationTwo(time)
                end  
            end

            if Data.canPlay then 
                self:updateAnimal(time)
            end 

            --[[
            Data.updateTime = Data.updateTime + time 
            if Data.updateTime > Data.dltTime then 
                Data.updateTime = Data.updateTime - Data.dltTime
                self:updateRotation(time)
            end ]]
        end 

    Data.updateTime = 0.0
    --Data.dltTime = 0.02

    -- 还在运行。暂停
    if schedulerEntry then 
        scheduler:unscheduleScriptEntry(schedulerEntry)
        schedulerEntry = nil
    end 

    if Data.GameBegin then 
        schedulerEntry = scheduler:scheduleScriptFunc(resumeGrossini, 0, false)
    end 
end 

-- 停止
function GameViewLayer:endRotation()
    local turnCount = math.floor((Data.nTurnTransit - Data.nTurnCount)/Data.TURN_TABLE_MAX)
    Data.nTurnCount = Data.nTurnCount + (turnCount-1)*Data.TURN_TABLE_MAX
end 

-- 中奖灰色闪烁
function GameViewLayer:playAniGray()
    local n = Data.nStartIndex[1]
    local nWingray_X = {837,963,1089,1216,1216,1216,1216,1216,1216, 1089,963,837,0,483,357,230,104, 104,105,103,104,102,227,352,483}
    local nWingray_Y = {645,645,645 ,645 ,536 ,427 ,313 ,204 ,93    ,94  ,94 ,94 ,0,94 ,94 ,94,93,  205,315,425,536,645,645,645,647}
    local schedulerWingray = nil
    local nTimeCount = 0
    local Wingray = cc.Sprite:create("General/Wingray.png")
    Wingray:setPosition(cc.p(nWingray_X[n],nWingray_Y[n]))
    self:addChild(Wingray, 100)
    local resumeGrossiniTime = function(time)
        nTimeCount = nTimeCount + 1
        if nTimeCount % 2 == 0 then
            Wingray:setVisible(true)
        else
            Wingray:setVisible(false)
        end
        
        if nTimeCount == 7 then
            Wingray:setVisible(false)
            if schedulerWingray then 
               scheduler:unscheduleScriptEntry(schedulerWingray)
               schedulerWingray = nil
            end
        end
    end 
    schedulerWingray = scheduler:scheduleScriptFunc(resumeGrossiniTime, 0.3, false)
end

-- 播放动画声音
function GameViewLayer:playAniMusic()
    -- 音效
    local targetIndex = Data.nStartIndex[1]
    if targetIndex == 0 or targetIndex == 13 then 
        targetIndex = Data.nStartIndex[2]
    end 

    if Data.nStartType ~= 0 then 
        --AudioEngine.playEffect("Sound/Reward_Open.mp3")
        local tmpNode = cc.Node:create()
        self:addChild(tmpNode)
        tmpNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function() 
                targetIndex = math.floor((targetIndex%13 - 1)/3)
                --AudioEngine.playEffect("Sound/" .. targetIndex .. ".mp3")
                --if Data.nStartType ~= Data.Choi_Line and Data.nStartType ~= Data.Choi_None then 
                AudioEngine.playEffect("Sound/Reward_" .. Data.nStartType .. ".mp3") 
                -- 四海归一
                if Data.nStartType == Data.Choi_FourInOne then
                    AudioEngine.playEffect("Sound/Reward_41.mp3")
                end 
            end))) 
    end

    -- 更新玩家分数
    --UserInfo:instance():UpdateModifyScore()
end

-- 播放动画
function GameViewLayer:playAni()
    print("===================66666======================")
    Data.canPlay = true
    Data.frameDel = 0.16
    Data.aniTime = 0.0
    Data.aniCurframe = 0
    Data.loopBegin = 11
    Data.loopEnd = 14
    Data.delFrame = 1
    Data.cellType = {-1,1,1,1,2,2,2,3,3,3,0,0,0,-1,1,1,1,2,2,2,3,3,3,0,0,0}
    Data.curHeadPosition = {}

    Data.headOffset = {}
    Data.headOffset[1] = {x=0,y=0}
    Data.headOffset[2] = {x=0,y=-13}
    Data.headOffset[3] = {x=0,y=-13}
    Data.headOffset[4] = {x=0,y=-13}
    Data.headOffset[5] = {x=-13,y=-13}
    Data.headOffset[6] = {x=-20,y=0}
    Data.headOffset[7] = {x=-20,y=0}
    Data.headOffset[8] = {x=-20,y=0}
    Data.headOffset[9] = {x=-20,y=0}
    Data.headOffset[10] = {x=-13,y=13}
    Data.headOffset[11] = {x=0,y=30}
    Data.headOffset[12] = {x=0,y=30}
    Data.headOffset[13] = {x=0,y=30}
    Data.headOffset[14] = {x=0,y=0}
    Data.headOffset[15] = {x=0,y=10}
    Data.headOffset[16] = {x=0,y=10}
    Data.headOffset[17] = {x=0,y=10}
    Data.headOffset[18] = {x=16,y=16}
    Data.headOffset[19] = {x=23,y=0}
    Data.headOffset[20] = {x=23,y=0}
    Data.headOffset[21] = {x=21,y=0}
    Data.headOffset[22] = {x=21,y=0}
    Data.headOffset[23] = {x=15,y=-15}
    Data.headOffset[24] = {x=0,y=-28}
    Data.headOffset[25] = {x=0,y=-28}
    Data.headOffset[26] = {x=0,y=-28}

    for i = 2, Data.TURN_TABLE_MAX do 
        if Data.nRunAnimal[i-1] or (Data.nStartType == Data.Choi_FourInOne and i ~= 14) then 
            Data.curHeadPosition[i] = {}
            Data.curHeadPosition[i].x = self.cell[i]:getPositionX()
            Data.curHeadPosition[i].y = self.cell[i]:getPositionY()
            local frameName = "Role/".. Data.cellType[i] .. "/" .. Data.aniCurframe .. ".png"
            print(frameName)
            if i ~= 14 and Data.nRunAnimal[i-1] or (Data.nStartType == Data.Choi_FourInOne) then
                self.cell[i]:setColor(cc.c3b(255, 255, 255))
                self.cell[i]:setSpriteFrame(frameCache:getSpriteFrame(frameName))
                self.cell[i]:setPosition(cc.p(Data.curHeadPosition[i].x+Data.headOffset[i].x, Data.curHeadPosition[i].y+Data.headOffset[i].y))
            end
        end  
    end 

    print("===================77777======================")
end 

-- 结束播放动画
function GameViewLayer:playAniEnd()
    Data.canPlay = false
    for i = 1, Data.TURN_TABLE_MAX do 
        if Data.nRunAnimal[i-1] or (Data.nStartType == Data.Choi_FourInOne) then 
            self.cell[i]:setPosition(cc.p(Data.curHeadPosition[i].x, Data.curHeadPosition[i].y))
        end
    end 
    Data.nRunAnimal = {}
end 

-- 结束播放动画
function GameViewLayer:resetPlayAni()
    local tmpHeadList = {"Sun_Red","Sun_Green","Sun_Yellow",
                     "Sha_Red","Sha_Green","Sha_Yellow",
                     "Niu_Red","Niu_Green","Niu_Yellow",
                     "Monkey_Red","Monkey_Green","Monkey_Yellow"}

    for i = 1, Data.TURN_TABLE_MAX do 
        if Data.curHeadPosition then 
            if Data.curHeadPosition[i] then 
                self.cell[i]:setPosition(cc.p(Data.curHeadPosition[i].x, Data.curHeadPosition[i].y))
                if i < 14 then
                    self.cell[i]:setSpriteFrame(cc.Sprite:create("General/" .. tmpHeadList[i-1]..".png"):getSpriteFrame())
                elseif i > 14 then  
                    self.cell[i]:setSpriteFrame(cc.Sprite:create("General/" .. tmpHeadList[i-14]..".png"):getSpriteFrame())
                end  
            end
            self.cell[i]:setColor(cc.c3b(50, 50, 50))
        end 
    end 
    Data.nRunAnimal = {}
end 

-- 播放动画
function GameViewLayer:updateAnimal(time)
    Data.aniTime = Data.aniTime + time
    if Data.aniTime > Data.frameDel then 
        for i = 2, Data.TURN_TABLE_MAX do 
            if i == 14 then 
            else 
                if Data.nRunAnimal[i-1] or (Data.nStartType == Data.Choi_FourInOne) then 
                    local frameName = "Role/".. Data.cellType[i] .. "/" .. Data.aniCurframe .. ".png"
                    --print(" frameName " .. frameName)
                    self.cell[i]:setSpriteFrame(frameCache:getSpriteFrame(frameName))
                end 
            end 
        end 

        Data.aniTime = Data.aniTime - Data.frameDel
        -- 切换一帧
        if Data.aniCurframe >= Data.loopEnd then 
            Data.aniCurframe = Data.loopEnd - 1
            Data.delFrame = -1
        elseif Data.aniCurframe == Data.loopBegin then 
            Data.aniCurframe = Data.loopBegin + 1
            Data.delFrame = 1
        else 
            Data.aniCurframe = Data.aniCurframe + Data.delFrame
        end 
    end 
end 

-- 转动更新
function GameViewLayer:updateRotation(time)
    if Data.bTurnTable then 
        if Data.nTurnTableDelay > 0 then 
            Data.nTurnTableDelay = Data.nTurnTableDelay -1
        end 

        if Data.nTurnTableDelay == 0 then 
            Data.nTurnTableCurrent = (Data.nTurnTableCurrent + 1)%Data.TURN_TABLE_MAX
            -- 移动数量
            Data.nTurnCount = Data.nTurnCount + 1

            if Data.nTurnTableCurrent == Data.nTurnTarget and Data.nTurnCount == Data.nTurnTransit then 
                
                if Data.TurnFirst then 
                    if Data.nTurnTableCurrent == 0 or Data.nTurnTableCurrent == 13 then 
                        Data.TurnFirst = false
                        AudioEngine.playEffect("Sound/Door.mp3")

                        local event = cc.EventCustom:new("SlotVisibleFalse")
                        eventDispatcher:dispatchEvent(event)
                    else 
                        --AudioEngine.playEffect("Sound/RunEnd.mp3")
                        AudioEngine.playEffect("Sound/Door.mp3")
                        self.battlePanel:setVisible(false)
                    end 
                else 
                    AudioEngine.playEffect("Sound/End.mp3")
                end 

                -- 赋值
                Data.nRunAnimal[Data.nTurnTableCurrent] = true

                Data.bTurnTable = false
                Data.nBrightCount = 1
                Data.nTurnIndex = Data.nTurnTableCurrent
                self.cell[Data.nTurnTarget+1]:setColor(cc.c3b(255, 255, 255))
                self:runAction(cc.Sequence:create(cc.DelayTime:create(0.8),cc.CallFunc:create(function()
                            local event = cc.EventCustom:new("TurnNext")
                            eventDispatcher:dispatchEvent(event)
                        end )))
                --self:playAni()
                
            end 

            if Data.TurnFirst then 
                if (Data.nTurnCount +7)> Data.nTurnTransit then 
                    AudioEngine.playEffect("Sound/Turn.mp3")
                end 
            end 
        end 

        -- 第一圈速度
        if Data.nTurnTableLaps == 0 then 
            if Data.nTurnCount < (Data.nTurnTransit - Data.TURN_TABLE_MAX) then
                if Data.nTurnTableDelay == 0 then 
                    -- 加速，延时减少
                    if Data.nTurnTableCount > 1 then 
                        Data.nTurnTableCount = Data.nTurnTableCount -1
                    end 

                    -- 新加延时
                    Data.nTurnTableDelay = Data.nTurnTableCount
                    -- 亮个数
                    if Data.nBrightCount < 6 and Data.nTurnTableLaps == 0 then 
                        Data.nBrightCount = Data.nBrightCount + 1
                    end 
                end 
            elseif Data.nTurnCount == (Data.nTurnTransit - Data.TURN_TABLE_MAX) then 
                Data.nTurnTableCount = 1
                Data.nTurnTableDelay = 1
            else 
                if Data.nTurnTableDelay == 0 then 
                    if (Data.nTurnTransit - Data.nTurnCount)%4 == 0 then 
                        Data.nTurnTableCount = Data.nTurnTableCount + 1

                        if Data.nBrightCount > 1 then 
                            Data.nBrightCount = Data.nBrightCount - 1
                        end 
                    end

                    if (Data.nTurnTransit - Data.nTurnCount) < (Data.TURN_TABLE_MAX - 15) then 
                        Data.nTurnTableCount = Data.nTurnTableCount + 1
                    end  

                    -- 新加延时
                    Data.nTurnTableDelay = Data.nTurnTableCount
                    if Data.nTurnTableDelay > 12 then 
                        Data.nTurnTableDelay = 12
                    end 
                end 
            end  
        end 
    end 

    -- 更新转动信息
    for i = 1, Data.TURN_TABLE_MAX do 
        if not Data.nRunAnimal[i - 1] then 
            self.cell[i]:setColor(cc.c3b(50, 50, 50))
        end 
    end 

    local nTurnTableIndex = Data.nTurnTableCurrent 
    for i = Data.nBrightCount , 1 , -1 do 
        if not Data.nRunAnimal[i - 1] then 
            self.cell[nTurnTableIndex+1]:setColor(cc.c3b(255, 255, 255))
        end 
        --print(nTurnTableIndex)
        nTurnTableIndex = (nTurnTableIndex + Data.TURN_TABLE_MAX - 1)%Data.TURN_TABLE_MAX;
    end 
end 

-- 转动更新
function GameViewLayer:updateRotationTwo(time)
    if Data.bTurnTable then 
        if Data.nTurnTableDelay > 0 then 
            Data.nTurnTableDelay = Data.nTurnTableDelay -1
        end 

        if Data.nTurnTableDelay == 0 then 
            Data.nTurnTableCurrent = (Data.nTurnTableCurrent + 1)%Data.TURN_TABLE_MAX
            -- 移动数量
            Data.nTurnCount = Data.nTurnCount + 1

            if Data.nTurnTableCurrent == Data.nTurnTarget and Data.nTurnCount == Data.nTurnTransit then 
                -- 停止转动
                AudioEngine.playEffect("Sound/End.mp3")
                -- 赋值
                Data.nRunAnimal[Data.nTurnTableCurrent] = true
                self.battlePanel:setVisible(false)
                Data.bTurnTable = false
                Data.nBrightCount = 1
                Data.nTurnIndex = Data.nTurnTableCurrent

                self.cell[Data.nTurnTarget+1]:setColor(cc.c3b(255, 255, 255))

                self:runAction(cc.Sequence:create(cc.DelayTime:create(0.8),cc.CallFunc:create(function()
                            local event = cc.EventCustom:new("TurnNext")
                            eventDispatcher:dispatchEvent(event)
                        end )))
                --self:playAni()
                
            end 
        end 

        -- 第一圈速度
        if Data.nTurnTableLaps == 0 then 
            if Data.nTurnCount < (Data.nTurnTransit - Data.TURN_TABLE_MAX) then
                if Data.nTurnTableDelay == 0 then 
                    -- 加速，延时减少
                    if Data.nTurnTableCount > 1 then 
                        Data.nTurnTableCount = Data.nTurnTableCount -1
                    end 

                    -- 新加延时
                    Data.nTurnTableDelay = Data.nTurnTableCount
                    -- 亮个数
                    if Data.nBrightCount < 6 and Data.nTurnTableLaps == 0 then 
                        Data.nBrightCount = Data.nBrightCount + 1
                    end 
                    --print("3Data.nTurnTableDelay " .. Data.nTurnTableDelay)

                    if (Data.nTurnCount +6)> Data.nTurnTransit then 
                        AudioEngine.playEffect("Sound/Turn.mp3")
                    end 
                    
                end 
            elseif Data.nTurnCount == (Data.nTurnTransit - Data.TURN_TABLE_MAX) then 
                Data.nTurnTableCount = 1
                Data.nTurnTableDelay = 1
                --print("2Data.nTurnTableDelay " .. Data.nTurnTableDelay)
            else 
                if Data.nTurnTableDelay == 0 then 
                    if (Data.nTurnTransit - Data.nTurnCount)%4 == 0 then 
                        Data.nTurnTableCount = Data.nTurnTableCount + 1

                        if Data.nBrightCount > 1 then 
                            Data.nBrightCount = Data.nBrightCount - 1
                        end 
                    end

                    if (Data.nTurnTransit - Data.nTurnCount) < (Data.TURN_TABLE_MAX - 15) then 
                        Data.nTurnTableCount = Data.nTurnTableCount + 1
                    end  

                    -- 新加延时
                    Data.nTurnTableDelay = 1--Data.nTurnTableCount
                    --print("1Data.nTurnTableDelay " .. Data.nTurnTableDelay)
                end 
            end  
        end 
    end 

    -- 更新转动信息
    for i = 1, Data.TURN_TABLE_MAX do 
        if not Data.nRunAnimal[i - 1] then 
            self.cell[i]:setColor(cc.c3b(50, 50, 50))
        end 
    end 

    local nTurnTableIndex = Data.nTurnTableCurrent 
    for i = Data.nBrightCount , 1 , -1 do 
        if not Data.nRunAnimal[nTurnTableIndex] then 
            self.cell[nTurnTableIndex+1]:setColor(cc.c3b(255, 255, 255))
        end 
        --print(nTurnTableIndex)
        nTurnTableIndex = (nTurnTableIndex + Data.TURN_TABLE_MAX - 1)%Data.TURN_TABLE_MAX;
    end 
end 

-- 进入打斗的VS
function GameViewLayer:GameFightBegin()
    AudioEngine.stopMusic()
    -- 开始进入播放进入战斗
    local arm = Data.nStartRoll[1] + 1
    local enterani = Data.NewVs[arm]
    if Data.nStartIndex[1] == 0 or Data.nStartIndex[1] == 13 then 
        enterani = Data.NewBaoVs[arm]
    end 

    Data.studioAni = ccs.Armature:create("Action")
    Data.studioAni:getAnimation():play(enterani, -1, 0)
    Data.studioAni:setPosition(cc.p(667,360))
    Data.studioAni:setScaleX(2.61)
    Data.studioAni:setScaleY(2.08)
    AudioEngine.playEffect("Sound/VS.mp3")
    Data.studioAni:setLocalZOrder(100)
    self:addChild(Data.studioAni)

    self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
        Data.FightBG:setVisible(true)
        local n = math.random(1,4)
        print("==========================:"..n)
        Data.FightBG:setTexture("BG/"..(n-1)..".png")
    end )))
end

-- 彩金变化
function GameViewLayer:GameJackpot()
    Data.bJackpot1 = false
    self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
        self.Jackpot:setPosition(cc.p(285,509))
        self.Jackpot:setString(string.format("%.2f", math.random(100000,999999)))
        self:GameJackpot()
    end )))
end

--操作按钮
function GameViewLayer:initButton()
	self:registerTouch()
	self.bBtnInOutside = false
	self._menuLayout = nil
	local  btcallback = function(ref, type)
        if type == ccui.TouchEventType.ended then
         	self:onButtonClickedEvent(ref:getTag(),ref)
        end
    end

	self.btSwitch = ccui.Button:create("GameMenu/bt_switch_0.png", "GameMenu/bt_switch_1.png", "")
		:move(cc.p(65,700))
		:setTag(10002)
		:addTo(self,99999)
	self.btSwitch:addTouchEventListener(btcallback)

	self.btPanel = cc.Sprite:create("GameMenu/sp_menubg.png")
		:move(cc.p(30,665))
		:setAnchorPoint(cc.p(0,1))
		:setVisible(false)
		:setScale(0)
		:addTo(self,99999)

	self.btExit = ccui.Button:create("GameMenu/bt_takeBack_0.png", "GameMenu/bt_takeBack_1.png", "")
		:move(cc.p(101,99))
		:setTag(10001)
		--:setTouchEnabled(false)
		:addTo(self.btPanel)
	self.btExit:addTouchEventListener(btcallback)

	self.btHelp = ccui.Button:create("GameMenu/bt_help_0.png", "GameMenu/bt_help_1.png", "")
		:move(cc.p(101,21))
		:setTag(10003)
		:addTo(self.btPanel)
	self.btHelp:addTouchEventListener(btcallback)


end


--按钮点击事件
function GameViewLayer:onButtonClickedEvent(tag,ref)
	if tag == 10001 then
		self:onButtonSwitchAnimate()
        self._scene:onQueryExitGame()
	elseif tag == 10002 then
		print("BT_SWITCH")
		self:onButtonSwitchAnimate()
	elseif tag == 10003 then
		self:onButtonSwitchAnimate()
        self.b_showHelp = true
		HelpLayer:create(self)
        :addTo(self,101)
       
	else
		showToast(self,"功能尚未开放！",1)
	end
end

function GameViewLayer:onButtonSwitchAnimate()
	local time = 0.2
	local helpshow = self.btPanel:isVisible()
	local scaleLv = helpshow and 0 or 1
	--self.btPanel:setVisible(true)

	--简单的缩放功能
	self.btPanel:runAction(cc.Sequence:create(
						   cc.ScaleTo:create(time,scaleLv),
						   cc.CallFunc:create(function()
						   		self.bBtnInOutside = not helpshow
						   		--self.btExit:setTouchEnabled(self.bBtnInOutside)
						   		--self.btHelp:setTouchEnabled(self.bBtnInOutside)
						   		self.btPanel:setVisible(not helpshow)
						   		--self._menuLayout:setVisible(not helpshow)
						   end)))
end

function GameViewLayer:registerTouch()

	local function onTouchBegan( touch, event )
			return self:isVisible()
		end
		local function onTouchEnded( touch, event )
			if self.btPanel:isVisible() == true then
				self:onButtonSwitchAnimate()
			end	
		end
	
		local listener = cc.EventListenerTouchOneByOne:create();
		listener:setSwallowTouches(true)
		self.listener = listener;
		listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN );
		listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED );
		local eventDispatcher = self:getEventDispatcher();
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);
end

--用户分数
function GameViewLayer:onGetUserScore( useritem )
	--自己
	if useritem.dwUserID == GlobalUserItem.dwUserID then
		-- self.BalanceText = useritem.lScore
       -- --self:resetSelfInfo()
       Data.curScore =GlobalUserItem.lUserScore
	end
end

function GameViewLayer:GoldIsGoOn(  )
    
    QueryDialog:create("金币不足,请到商城购买金币", function(bReTry)
        self:runAction(cc.Sequence:create(
            cc.CallFunc:create(
                function () 
                    self._scene._gameFrame:setEnterAntiCheatRoom(false)
                    self._scene._gameFrame:StandUp(1)
                    self._scene:onExitRoom()
                end
                ),
            cc.DelayTime:create(3),
            cc.CallFunc:create(
                function ()
                    --强制离开游戏(针对长时间收不到服务器消息的情况)
                    --print("delay leave")
                    self._scene:onExitRoom()
                end
                )
            )
        )
    end,nil,QueryDialog.QUERY_SURE)
    :setCanTouchOutside(false)
    :addTo(self,1000)
end


return GameViewLayer