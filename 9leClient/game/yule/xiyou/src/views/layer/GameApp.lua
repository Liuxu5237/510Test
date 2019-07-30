--
-- Author: Your Name
-- Date: 2015-09-24 19:51:21
--

require "cocos.init"
local GameApp = class("GameApp")

local Data = require("script.Data")
--cc.exports.json = {}
--require "cocos.cocos2d.json"
local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

function GameApp:ctor()
end

function GameApp:run()
    print("=============GameApp 322==============")
    
    Data.msgMgr[Data.SUB_S_START_GAME] = function(receiveBuffer)
        if Data.nGameState then 
            print(" Data.nGameState " .. Data.nGameState)
        end 
        if Data.nGameState ~= 1 then 
            return
        end 

        print("Data.msgMgr[Data.SUB_S_START_GAME]")
        local index = 1
        index, Data.nStartType = bunpack(receiveBuffer,"i",index)
        print("nStartType " .. Data.nStartType)
        print("【中奖说明】" .. Data.GameTypeResult[Data.nStartType+1])
        index, Data.nStartColor = bunpack(receiveBuffer,"i",index)
        print("nStartColor " .. Data.nStartColor)
        Data.nStartIndex = {}
        local nTmpIndex = -1
        local arPtChange = {23,24,25,1,2,3,4,5,6,7,8,9,
                            13,
                            10,11,12,14,15,16,17,18,19,20,21,22}
        for i = 1, 10 do 
            index, nTmpIndex = bunpack(receiveBuffer,"i",index)
            if (0 < nTmpIndex and 26 > nTmpIndex) then
                Data.nStartIndex[i] = arPtChange[nTmpIndex]
            else
                Data.nStartIndex[i] = nTmpIndex
            end
            print("nStartIndex " .. i .. " " .. Data.nStartIndex[i])
        end
        
        print("【停止的位置】 "  .. Data.nStartIndex[1]) 
        Data.nStartRoll = {}
        for i = 1, 2 do 
            index, Data.nStartRoll[i] = bunpack(receiveBuffer,"i",index)
            print("nStartRoll " .. i .. " " .. Data.nStartRoll[i])
        end

        --Data.nStartIndex[2] = Data.nStartIndex[1]
        --Data.nStartIndex[1] = 0
        --Data.nStartType = Data.Choi_FourInOne
        --Data.nStartRoll[2] = 2
        --Data.nStartRoll[1] = 1

        index, Data.nStartWin = bunpack(receiveBuffer,"S",index)
        print("【------------输赢----------】nStartWin " .. Data.nStartWin)
        
        index, Data.nFirstAttack = bunpack(receiveBuffer,"b",index)
        print("【------------谁先手----------】 " .. Data.nFirstAttack)
        index, Data.nActionNum = bunpack(receiveBuffer,"b",index)
        print("【------------谁赢----------】 " .. Data.nActionNum)
        index, Data.nBaozou = bunpack(receiveBuffer,"b",index)
        print("【------------是否暴走----------】 " .. Data.nBaozou)
        index, Data.GameJackpotScore = bunpack(receiveBuffer,"S",index)
        index, Data.GameJackpotWin = bunpack(receiveBuffer,"S",index)
        print("【彩金值】 " .. Data.GameJackpotScore)
        print("【彩金值1】 " .. Data.GameJackpotWin)

        -- 转动和动作索引
        Data.nStartIndexBegin = 1
        Data.nStartActionBegin = 1
        Data.nRunAnimal = {}

        -- 历史记录
        local history = {}
        history.type = Data.nStartType
        history.color = Data.nStartColor
        history.index = Data.nStartIndex[1]
        if history.index == 0 or history.index == 13 then 
            history.index = Data.nStartIndex[2]
        end 

        Data.HistoryList[#Data.HistoryList+1] = history
        local tmpCount = #Data.HistoryList
        if tmpCount > 24 then 
            for i = 1, 24 do 
                Data.HistoryList[i] = Data.HistoryList[i+1]
            end 

            Data.HistoryList[25] = nil
        end
        Data.bHistory = true
        --self:enterScene("MainLayer")
        local event = cc.EventCustom:new("GameEndBet")
        eventDispatcher:dispatchEvent(event)
    end 

    -- 状态改变
    Data.msgMgr[Data.SUB_S_RESET_GAMESTATE] = function(receiveBuffer)
       
    end 

    -- 状态改变
    Data.msgMgr[Data.SUB_S_INIT] = function(receiveBuffer)
        print("Data.msgMgr[Data.SUB_S_INIT]")
        local index = 1
        index, Data.nGameState = bunpack(receiveBuffer,"i",index)
        print("Data.nGameState " .. Data.nGameState)
        index, Data.nLessTime = bunpack(receiveBuffer,"i",index)
        print("Data.nLessTime " .. Data.nLessTime)
        Data.nInitDouble = {}
        for i = 1, 3 do 
            index, Data.nInitDouble[i] = bunpack(receiveBuffer,"i",index)
            print(" Data.nInitDouble[" .. i .."]" .. Data.nInitDouble[i])
        end

        index, Data.nScore = bunpack(receiveBuffer,"i",index)
        print("Data.nScore " .. Data.nScore)

        if Data.nGameState == 1 then 
            local event = cc.EventCustom:new("GameBeginBet")
            eventDispatcher:dispatchEvent(event)
            --self:enterScene("BetLayer")
        else 
            -- 等待下一局
            Data.GameBegin = false
            --local event = cc.EventCustom:new("GameEndBet")
            --eventDispatcher:dispatchEvent(event)
            --self:enterScene("MainLayer")
        end 
    end
    
    --Data.GameBegin = true
    SendGameMsg(Data.SUB_C_SCENE_ENTER,0,"")
    self:enterScene("MainLayer")
    --self:enterScene("BattleLayer")
end

function GameApp:showMemoryUsage()
	--local sharedTextureCache = CCTextureCache:sharedTextureCache()
    --printInfo(string.format("LUA VM MEMORY USED: %0.2f KB", collectgarbage("count")))
    --sharedTextureCache:dumpCachedTextureInfo()
    --printInfo("----------")
end

function GameApp:enterScene(sceneName, transitionType, time, more)
    local scenePackageName =  "script." .. sceneName
    local sceneClass = import(scenePackageName)
	local sceneGame = cc.Scene:create()
    sceneGame:addChild(sceneClass.new())
    cc.Director:getInstance():pushScene(sceneGame)
end

function GameApp:enterTransScene(sceneName, time)
	local scenePackageName =  "script." .. sceneName
    local sceneClass = import(scenePackageName)
	local sceneGame = cc.Scene:create()
    sceneGame:addChild(sceneClass.new())
    sceneGame = cc.TransitionSlideInR:create(time, sceneGame)
    cc.Director:getInstance():replaceScene(sceneGame)
end

function GameApp:exitGame()
   
end 

return GameApp