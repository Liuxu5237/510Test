local GameModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameModel")
local GameLayer		= class("GameLayer", GameModel)
local module_pre	= "game.yule.xiyou.src"; 


local ExternalFun 	    =  appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local g_var 		    = ExternalFun.req_var
local GameViewLayer     = appdf.req(module_pre .. ".views.layer.GameViewLayer")
local Data              = appdf.req(module_pre .. ".models.Data")
local QueryDialog 	    = appdf.req("base.src.app.views.layer.other.QueryDialog")
local eventDispatcher   = cc.Director:getInstance():getEventDispatcher()

--local AdminLayer = appdf.req("game.yule.fengshenbang.src.views.layer.AdminLayer")

function GameLayer:ctor( frameEngine,scene )
    self.m_bLeaveGame = false
    self._gameFrame = frameEngine
    self._gameLogic = GameLogic
	self.name = "GameLayer"
	ExternalFun.registerNodeEvent(self)
	GameLayer.super.ctor(self,frameEngine,scene)

    self._scene = scene
	local cmddata = CCmd_Data:create(0)
	self:SendData(Data.SUB_C_SCENE_ENTER,cmddata)

    self:sendReady()
end

function GameLayer:onExit()
    GameLayer.super.onExit(self)
end

function GameLayer:CreateView()
    return GameViewLayer:create(self):addTo(self)
end

function GameLayer:getParentNode( )
    return self._scene
end

-- -- 场景信息
function GameLayer:onEventGameScene(cbGameStatus,dataBuffer)
    print("西游 场景 状态"..cbGameStatus)
    if cbGameStatus == 100 or cbGameStatus == 101	then    
        print("西游 场景2")                  --空闲状态
        self:onEventGameSceneFree(dataBuffer)
	end
end
function GameLayer:onEventGameSceneFree(dataBuffer)    --空闲
    print("GameStatusMsg   319")
    --self._gameView.BetLayer:setJettonEnable(true)
	local index = 1
    
    local tmpColor = {}
    for i = 1, 12 do 
       tmpColor[i] = dataBuffer:readint()
    	print( "tmpColor" .. i .. " " .. tmpColor[i])
    end 
    local tmpType = {}
    for i = 1, 12 do 
       tmpType[i] = dataBuffer:readint()
        print("tmpType " .. i .. " " .. tmpType[i])
    end
    local tmpIndex = 0
	tmpIndex = dataBuffer:readint()
    print("tmpIndex " .. tmpIndex)

    --tmpIndex = tmpIndex + 1
    for i = 1, 12 do 
    	local lindex = (tmpIndex + i)%12 + 1 

    	--if tmpType[lindex] ~= 0 then 
    	if tmpType[lindex] and tmpType[lindex] ~= 0 then 
    		print("tmpType[lindex] " .. tmpType[lindex] .. "  " .. lindex)
    		--if 
			-- 历史记录
		    local history = {}
		    -- 普通
		    if tmpType[lindex] >= Data.Choi_Count then 
		    	history.type = Data.Choi_None
		    	history.color = tmpColor[lindex]
		    	local nTmpIndex = tmpType[lindex] - Data.Choi_Count
				local arPtChange = {23,24,25,1,2,3,4,5,6,7,8,9}
				if (0 < nTmpIndex and 13 > nTmpIndex) then
					history.index = arPtChange[nTmpIndex]
				else
					history.index = nTmpIndex
				end
		    else
		    	history.type = tmpType[lindex]
		    	history.color = tmpColor[lindex]
		    	history.index = 1
		    end 

		    Data.HistoryList[#Data.HistoryList+1] = history
            Data.bHistory = true
    	end 
    end 
end


function GameLayer:onEventGameMessage(msgSubId,dataBuffer)
	print("@@@@@@@@@@@@@@@@@@@@@@@msgId"..msgSubId) 
    if  msgSubId == Data.SUB_S_START_GAME  then  
        --self._gameView.BetLayer:setJettonEnable(false)
 
		if Data.nGameState then 
            print(" Data.nGameState " .. Data.nGameState)
        end 
        if Data.nGameState ~= 1 then 
            return
        end 

        print("Data.msgMgr[Data.SUB_S_START_GAME]")
        local index = 1
        Data.nStartType = dataBuffer:readint()
        print("nStartType " .. Data.nStartType)
        print("【中奖说明】" .. Data.GameTypeResult[Data.nStartType+1])
        Data.nStartColor = dataBuffer:readint()
        print("nStartColor " .. Data.nStartColor)
        Data.nStartIndex = {}
        local nTmpIndex = -1
        local arPtChange = {23,24,25,1,2,3,4,5,6,7,8,9,
                            13,
                            10,11,12,14,15,16,17,18,19,20,21,22}
        for i = 1, 10 do 
            nTmpIndex = dataBuffer:readint()
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
            Data.nStartRoll[i] = dataBuffer:readint()
            print("nStartRoll " .. i .. " " .. Data.nStartRoll[i])
        end

        --Data.nStartIndex[2] = Data.nStartIndex[1]
        --Data.nStartIndex[1] = 0
        --Data.nStartType = Data.Choi_FourInOne
        --Data.nStartRoll[2] = 2
        --Data.nStartRoll[1] = 1

        Data.nStartWin = GlobalUserItem:readScore(dataBuffer)
        print("【------------输赢----------】nStartWin " .. Data.nStartWin)
        Data.nFirstAttack 		= dataBuffer:readbyte()
        print("【------------谁先手----------】 " .. Data.nFirstAttack)
        Data.nActionNum 	= dataBuffer:readbyte()
        print("【------------谁赢----------】 " .. Data.nActionNum)
        Data.nBaozou 	= dataBuffer:readbyte()
        print("【------------是否暴走----------】 " .. Data.nBaozou)
        Data.GameJackpotScore 	= GlobalUserItem:readScore(dataBuffer)
        Data.GameJackpotWin 	= GlobalUserItem:readScore(dataBuffer)
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
		
	elseif msgSubId ==  Data.SUB_S_RESET_GAMESTATE then  
		print("Data.msgMgr[Data.SUB_S_RESET_GAMESTATE]")
        local index = 1
        Data.cbGameVersion = dataBuffer:readbyte()
        print("Data.cbGameVersion " .. Data.cbGameVersion)
        local curScore = 0
       	curScore = dataBuffer:readscore() 
        print("CurScore " .. curScore)
        
        Data.nDouble = {}
        for i = 1, 3 do 
            Data.nDouble[i] = dataBuffer:readbyte() 
            print(" Data.nDouble[" .. i .."]" .. Data.nDouble[i])
        end
    elseif msgSubId ==  Data.SUB_S_INIT then  
       
		print("Data.msgMgr[Data.SUB_S_INIT]")
        local index = 1
        Data.nGameState =  	dataBuffer:readint()
        print("Data.nGameState " .. Data.nGameState)
        Data.nLessTime = 	dataBuffer:readint()
        print("Data.nLessTime " .. Data.nLessTime)
        Data.nInitDouble = {}
        for i = 1, 3 do 
            Data.nInitDouble[i] = dataBuffer:readint()
            print(" Data.nInitDouble[" .. i .."]" .. Data.nInitDouble[i])
        end

        Data.nScore = dataBuffer:readint()
        print("Data.nScore " .. Data.nScore)

        if Data.nGameState == 1 then 
            local event = cc.EventCustom:new("GameBeginBet")
            eventDispatcher:dispatchEvent(event)
        else 
            -- 等待下一局
            Data.GameBegin = false
        end 
    elseif msgSubId ==  Data.SUB_S_ADD_CHIPS then   --下注成功
        if self._gameView.BetLayer then
            self._gameView.BetLayer:setJettonEnable(true)
            self._gameView.BetLayer:updateBetInfo(self._gameView.BetLayer._node)
            self._gameView.BetLayer:addChip(dataBuffer)
        end
        
	end


end
-- 发送准备
function GameLayer:sendReady()
    --self:KillGameClock()
    self:SendUserReady()
end

function GameLayer:sendReConnect()
	local cmddata = CCmd_Data:create(0)
	self:SendData(g_var(cmd).SUB_C_FREE_SCENE,cmddata)
end


--待定 不知道干什么
-- 更新玩家分数
function GameUserScore(iSubID, strBuffer, size)
	print("=============更新玩家分数===============")
    local fucCallback = Data.msgMgr[1234]
    if fucCallback then 
        fucCallback()
    end
end 


function GameLayer:gameAppExit()
	print("==============================322 ExitGame===============================")
    AudioEngine.stopAllEffects()
    AudioEngine.stopMusic()
    package.loaded["views.GameApp"] = nil
    package.loaded["views.Data"] = nil
    package.loaded["views.BetLayer"] = nil
    package.loaded["views.BattleLayer"] = nil
    package.loaded["views.HelpLayer"] = nil
    package.loaded["views.HistoryLayer"] = nil
    package.loaded["views.MainLayer"] = nil
    package.loaded["views.MapLayer"] = nil
    package.loaded["views.SlotLayer"] = nil
    package.loaded["views.ResultLayer"] = nil
    package.loaded["views.TypeShowLayer"] = nil
    --package.loaded["Hall.ExitLayer"] = nil
    package.loaded["GameMenu.GameMenuLayer"] = nil
    package.loaded["main"] = nil
    _G.Data = nil
end

--监听手机返回键
function GameLayer:GameReturnKey(layer)
    --监听手机返回键
    local key_listener = cc.EventListenerKeyboard:create()
    --返回键回调
    local function key_return()
        local runSence = cc.Director:getInstance():getRunningScene()
		if runSence then 
			-- runSence:addChild(import("Hall/ExitLayer").new(function() 
			-- 		GameApp:exitGame()
			-- 	end ) ,129)
		end 
    end
    --lua中得回调，分清谁绑定，监听谁，事件类型是什么
    key_listener:registerScriptHandler(key_return,cc.Handler.EVENT_KEYBOARD_RELEASED)
    local eventDispatch = layer:getEventDispatcher()
    eventDispatch:addEventListenerWithSceneGraphPriority(key_listener,layer)
end

--发送游戏开始
function GameLayer:startGame(line,bet,linecost,bfree)
	
	local cmddata = CCmd_Data:create(18)
	cmddata:pushbyte(line)
	cmddata:pushscore(bet)
	cmddata:pushscore(linecost)
	cmddata:pushbyte((free and 1 or 0))
	self:SendData(g_var(cmd).SUB_C_SCENE_START,cmddata)
end


function GameLayer:onEventUserScore( item )
    self._gameView:onGetUserScore(item)
end

function  GameLayer:onEventUserStatus( useritem,newstatus,oldstatus )
	if newstatus.cbUserStatus == 2 then
		self:sendReady()
	end
end


--离开房间
function GameLayer:onExitRoom()
    --print("离开房间？ gamelayer")
    self._gameFrame:onCloseSocket()

    self._scene:onKeyBack()
end


function GameLayer:onQueryExitGame()
    local delayLeaveTime = 0.3
    
    local exit_timeOut = 3 --退出超时时间

    if self._queryDialog then
      return
    end

    self._queryDialog = QueryDialog:create("您要退出游戏么？", function(ok)
        if ok == true then
            self:runAction(cc.Sequence:create(
            cc.CallFunc:create(
                function () 
                    self._gameFrame:setEnterAntiCheatRoom(false)
                    self._gameFrame:StandUp(1)
                    self:onExitRoom()
                end
                ),
            cc.DelayTime:create(exit_timeOut),
            cc.CallFunc:create(
                function ()
                    --强制离开游戏(针对长时间收不到服务器消息的情况)
                    --print("delay leave")
                    self:onExitRoom()
                end
                )
            )
        )

        end
            self._queryDialog = nil
      end):setCanTouchOutside(false)
            :addTo(self)
end

function  GameLayer:onEventUserStatus( useritem,newstatus,oldstatus )
	if  useritem.dwUserID  == GlobalUserItem.dwUserID and  newstatus.cbUserStatus == 1 then
		self.isStandUp = true
	end
end

return GameLayer