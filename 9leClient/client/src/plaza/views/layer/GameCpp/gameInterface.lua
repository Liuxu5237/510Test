module("game", package.seeall)

--c++调用
function setGameBaseData(gameID)
	
	if gameID == 601 then
		ds.DF:shared():init(gameID,6,ds.CPlatformGameConfig:shared():getValue(gameID,"game_current_version"),ds.CPlatformGameConfig:shared():getValue(gameID,"game_name"))
	elseif gameID == 602 then
		ds.DF:shared():init(gameID,6,ds.CPlatformGameConfig:shared():getValue(gameID,"game_current_version"),ds.CPlatformGameConfig:shared():getValue(gameID,"game_name"))
	elseif gameID == 2015 then
		ds.DF:shared():init(gameID,4,ds.CPlatformGameConfig:shared():getValue(gameID,"game_current_version"),ds.CPlatformGameConfig:shared():getValue(gameID,"game_name"))
	elseif gameID == 30 then
		ds.DF:shared():init(gameID,3,ds.CPlatformGameConfig:shared():getValue(gameID,"game_current_version"),ds.CPlatformGameConfig:shared():getValue(gameID,"game_name"))
	elseif gameID == 557 then
		ds.DF:shared():init(gameID,4,ds.CPlatformGameConfig:shared():getValue(gameID,"game_current_version"),ds.CPlatformGameConfig:shared():getValue(gameID,"game_name"))
	elseif gameID == 108 then
		ds.DF:shared():init(gameID,100,ds.CPlatformGameConfig:shared():getValue(gameID,"game_current_version"),ds.CPlatformGameConfig:shared():getValue(gameID,"game_name"))
	elseif gameID == 570 then
		ds.DF:shared():init(gameID,4,ds.CPlatformGameConfig:shared():getValue(gameID,"game_current_version"),ds.CPlatformGameConfig:shared():getValue(gameID,"game_name"))
--elseif gameID == 127 then
	--	ds.DF:shared():init(gameID,100,ds.CPlatformGameConfig:shared():getValue(gameID,"game_current_version"),ds.CPlatformGameConfig:shared():getValue(gameID,"game_name"))
	end
end

function createGameInstance(gameID)

	if gameID == 601 then
		ds.CGameFrameEngine:Get():SetGameFrameEngineSink(ds.DntgClientKernelSink:Get())
	elseif gameID == 602 then
		ds.CGameFrameEngine:Get():SetGameFrameEngineSink(ds.LkpyClientKernelSink:Get())
	elseif gameID == 2015 then
		ds.CGameFrameEngine:Get():SetGameFrameEngineSink(ds.CGameFrameEngineOX4:Get())
	elseif gameID == 30 then
		ds.CGameFrameEngine:Get():SetGameFrameEngineSink(ds.CGameFrameEngineLord:Get())
	elseif gameID == 557 then
		ds.CGameFrameEngine:Get():SetGameFrameEngineSink(ds.CGameFrameEngineMJ:Get())	
	elseif gameID == 108 then
		ds.CGameFrameEngine:Get():SetGameFrameEngineSink(ds.CGameFrameEngineBetcar:Get())	
	elseif gameID == 570 then
		ds.CGameFrameEngine:Get():SetGameFrameEngineSink(ds.CGameFrameEngineJAMJ:Get())
--elseif gameID == 127 then
	--	ds.CGameFrameEngine:Get():SetGameFrameEngineSink(ds.GameFrameEngineJsys:Get())	
	end
end
 
--启动游戏 逻辑
function SetupGameClientLogic()

	ds.log("game.SetupGameClientLogic")
	if ds.game ~= nil then
		ds.game:initDynomicData()
	end
end
 
 --重置游戏 逻辑 
function ResetGameClientLogic()
	
	ds.log("game.ResetGameClientLogic")
	ds.game:initDynomicData()
end

--关闭游戏 逻辑
function CloseGameClientLogic()

	ds.log("game.CloseGameClientLogic")
	
	--销毁游戏共同ui
	if ds.gameCommonUI ~= nil then
		ds.gameCommonUI:Destroy()
	end
	
	--销毁房卡共同ui
	if ds.gameprivatecommonUi ~= nil then
		ds.gameprivatecommonUi:Destroy()
	end
	
	if ds.newgameprivatecommonUi ~= nil then
		ds.newgameprivatecommonUi:Destroy()
	end

	DSCommon.g_gameState = DSCommon.g_tGameState["hall"]
	
	if ds.game ~= nil then
		ds.game:initDynomicData()
		ds.game = nil
		
		DSResouresMgr.DeleteLuaResoures(ds.DF:shared():GetGameKindID())
	else
		local gameID = ds.DF:shared():GetGameKindID();
		if gameID == 601 then
			ds.DntgClientKernelSink:Destroy()
		elseif gameID == 602 then
			ds.LkpyClientKernelSink:Destroy()	
		elseif gameID == 2015 then
			ds.CGameFrameEngineOX4:Destroy()	
		elseif gameID == 30 then
			ds.CGameFrameEngineLord:Destroy()
		elseif gameID == 577 then
			ds.CGameFrameEngineMJ:Destroy()
		elseif gameID == 570 then
			ds.CGameFrameEngineJAMJ:Destroy()
		end
	end
	
	LoadingLayer.destroyResource(ds.DF:shared():GetGameKindID())
	
	collectgarbage("collect")
end

--场景消息
function OnEventSceneMessage(cbGameStatus,bLookonUser,packet,dataSize)
	
	ds.log("game.OnEventSceneMessage"..cbGameStatus)
	ds.game:OnEventSceneMessage(cbGameStatus,bLookonUser,packet,dataSize)
end

--游戏消息
function OnEventGameMessage(subCmdID,packet,dataSize)
	ds.log("game.OnEventGameMessage"..subCmdID)
	ds.game:OnEventGameMessage(subCmdID,packet,dataSize)
end

--语音消息

--游戏场景初始化
function Init(gameScene)
	ds.log("game.Init")
	DSCommon.g_gameState = DSCommon.g_tGameState["game"]
	ds.game:Init(gameScene)
end

--启动游戏  视图
function SetupGameClientView()
	ds.log("game.SetupGameClientView")
	ds.game:SetupGameClientView()
end

--重置游戏  视图
function ResetGameClientView()
	ds.log("game.ResetGameClientView")
	ds.game:ResetGameClientView()
end

--关闭游戏 视图
function CloseGameClientView()
	ds.log("game.CloseGameClientView")
	ds.game:CloseGameClientView()
end

--玩家进入
function OnEventUserEnter(pIClientUserItem,bLookonUser)
	ds.log("game.OnEventUserEnter")
	if ds.game ~= nil then

		ds.game:OnEventUserEnter(pIClientUserItem,bLookonUser)
	end
    if ds.gameprivatecommonUi ~= nil then
     
        ds.gameprivatecommonUi:OnEventUserEnter(pIClientUserItem,bLookonUser)  
    end
	if ds.newgameprivatecommonUi ~= nil then
     
        ds.newgameprivatecommonUi:OnEventUserEnter(pIClientUserItem,bLookonUser)  
    end
end

--玩家离开
function OnEventUserLeave(pIClientUserItem,bLookonUser)
	ds.log("game.OnEventUserLeave")
	if ds.game ~=nil then
		ds.game:OnEventUserLeave(pIClientUserItem,bLookonUser)
	end
	
    if ds.gameprivatecommonUi ~= nil then
     
        ds.gameprivatecommonUi:OnEventUserLeave(pIClientUserItem,bLookonUser)  
    end
	if ds.newgameprivatecommonUi ~= nil then
     
        ds.newgameprivatecommonUi:OnEventUserLeave(pIClientUserItem,bLookonUser)  
    end
end

--玩家状态
function OnEventUserStatus(pIClientUserItem,bLookonUser)
	ds.log("game.OnEventUserStatus")
	ds.game:OnEventUserStatus(pIClientUserItem,bLookonUser)
end

--玩家分数
function OnEventUserScore(pIClientUserItem,bLookonUser)
	local pGlobalUserInfo = ds.CGlobalUserInfo:GetInstance()
	local puser = pGlobalUserInfo:getUserID()
	local iuser = pIClientUserItem:GetUserID()
	ds.log("UserInfo,IClientUserItem")
	ds.log(puser,iuser)
	if pGlobalUserInfo:getUserID() == pIClientUserItem:GetUserID() then
		ds.MyNotification:getInstance():dispatchEvent("game_event",ds.MTData:create(ds.GameEventIDDefine.GAME_EVENT_ID_JUDGE_LOW_INSURE))
	end
	ds.log("game.OnEventUserScore")
	if ds.game ~= nil then
		ds.game:OnEventUserScore(pIClientUserItem,bLookonUser)	
	end
	
	if ds.gameCommonUI ~= nil then
		--共同ui处理玩家的金币，元宝，积分变化
      ds.gameCommonUI:OnEventUserScore()
	end
end

--玩家属性
function OnEventUserAttrib(pIClientUserItem,bLookonUser)
	ds.log("game.OnEventUserAttrib")
	ds.game:OnEventUserAttrib(pIClientUserItem,bLookonUser)
end

--触摸开始
function ccTouchBegan(pTouch,pEvent)
	ds.log("game.ccTouchBegan")
	if( ds.game ~= nil ) then
		ds.game:ccTouchBegan(pTouch,pEvent)
	end
end

--触摸移动
function ccTouchMoved(pTouch,pEvent)
	ds.log("game.ccTouchMoved")
	if( ds.game ~= nil ) then
		ds.game:ccTouchMoved(pTouch,pEvent)
	end
end

--触摸结束
function ccTouchEnded(pTouch,pEvent)
	ds.log("game.ccTouchEnded")
	if( ds.game ~= nil ) then
		ds.game:ccTouchEnded(pTouch,pEvent)
	end
end

--游戏切入后台
function OnGameEnterBackground()
	ds.log("game.OnGameEnterBackground")
	ds.game:OnGameEnterBackground()
end

--游戏切入前台
function OnGameEnterForeground()
	ds.log("game.OnGameEnterForeground")
	ds.game:OnGameEnterForeground()
end

--断线重连回来
function OnReconnectResumeGame()
	ds.log("game.OnReconnectResumeGame")
	
	if ds.game ~= nil then
		ds.game:OnReconnectResumeGame()
	end
	
	if ds.gameCommonUI ~= nil then
		ds.gameCommonUI:OnReconnectResumeGame()
	end
	if ds.gameprivatecommonUi ~= nil then
		ds.gameprivatecommonUi:OnReconnectResumeGame()
	end
	if ds.newgameprivatecommonUi ~= nil then
		ds.newgameprivatecommonUi:OnReconnectResumeGame()
	end
end

--检测到网络断开
function OnDetectNetDown()
	ds.log("game.OnDetectNetDown")
	--ds.game:OnDetectNetDown()
end

--检测到网络恢复
function OnEnterReconnectState()
	ds.log("game.OnDetectNetDown")
    if ds.game ~= nil then
	   ds.game:OnEnterReconnectState()
    else
        ds.error("gameend.OnEnterReconnectState")   
    end
end

function OnGFWaitTips()
	ds.log("game.OnGFWaitTips")
end


function OnSubWaitBack()
	ds.log("game.OnSubWaitBack")
	if ds.gameCommonUI ~= nil then
		ds.gameCommonUI:OnSubWaitBack()
	end
	
end

function onEnterTransitionDidFinish()
	ds.log("game.onEnterTransitionDidFinish")
end


function OnGFTableMessage(strMessage)
	
	ds.log("OnGFTableMessage",strMessage)
end

function setSocketSink(ISocketSink)
    GameFrameEngine:setCCCallSink(ISocketSink)
end

function setGameFrameEngine(pGameFrameEngine)
    GameFrameEngine = pGameFrameEngine

end

function sendCCData(pData)
   --GameFrameEngine:sendSocketData(pData)
   GameFrameEngine:sendSocketData(pData,true)
end

function OnStartGame(KindID)
   mLoading = LoadingLayer.create(KindID, "game.GameLoadingCallBack")
end

function GameLoadingCallBack()
	local gameCenterManager = ds.CGameCenterManager:Instance()
	gameCenterManager:CreateKernel()
end

function RoomNotificationCallBack(MTData)
    local eventId = tonumber(MTData:getData1())

    --19游戏初始化成功
	if(eventId == 19) then	
		OnGameInitSuccess()
	--20游戏初始化失败
	elseif(eventId == 20) then	
		OnGameInitFail()
    end
end

--游戏初始化成功
function OnGameInitSuccess()
	if (mLoading ~= nil) then
		mLoading:removeFromParent()
		mLoading = nil
	end
end

--游戏初始化失败
function OnGameInitFail()
	if (mLoading ~= nil) then
		mLoading:removeFromParent()
		mLoading = nil
	end
end








