module("GameNotificationMgr", package.seeall)
local mServerId = nil
local mLoading = nil
local DeskRoomListLayer = nil
function GameNotificationCallBack(MTData)

	local eventId = tonumber(MTData:getData1())
	DSWaitingLayer.dismiss()
	ds.log("eventId:",eventId)
	if (eventId == ds.GameEventIDDefine.GAME_EVENT_ID_CLOSE_GAME_CLIENT) then
	
	elseif (eventId == ds.GameEventIDDefine.GAME_EVENT_ID_ENTER_FOREGROUND) then
		DSWaitingLayer.create()
	elseif (eventId == ds.GameEventIDDefine.GAME_EVENT_ID_DETECT_NET_DOWN) then
		DSWaitingLayer.create()
	elseif ( eventId == ds.GameEventIDDefine.GAME_EVENT_ID_GAME_CLOSE) then
		OnGameClose(MTData:getData2())
	elseif (eventId == ds.GameEventIDDefine.GAME_EVENT_ID_CLOSE_GAME_CONFIRM) then
		OnCloseGameConfirm()
	elseif (eventId == ds.GameEventIDDefine.GAME_EVENT_ID_GOLD_NOT_ENOUGH) then
		OnGoldNotEnough()
	elseif (eventId == ds.GameEventIDDefine.GAME_EVENT_ID_RECONNECT_NET_ERROR) then
		OnReconnectNetError()
	elseif (eventId == ds.GameEventIDDefine.GAME_EVENT_ID_RECONNECT_UNKNOWN) then
		OnReconnectUnknown()
	elseif (eventId == ds.GameEventIDDefine.GAME_EVENT_ID_DETECT_NET_AGAIN) then
		OnDetectNetAgain(MTData:getPData())
	elseif (eventId == ds.GameEventIDDefine.GAME_EVENT_ID_DETECT_NET_TIME_OUT) then
		OnDetectNetTimeout()
	elseif (eventId == ds.GameEventIDDefine.GAME_EVENT_ID_SHOW_PAY) then
		OnShowPayPage()
	elseif (eventId == ds.GameEventIDDefine.GAME_EVENT_ID_SERVER_NOTIFY_CLOSE_CLIENT) then
		OnServerNotifyCloseClient()
		
	--跑马灯
	elseif (eventId == ds.GameEventIDDefine.GAME_EVENT_ID_SYSTEM_MSG) then
		OnRecvSystemMsg(MTData:getStr1())
	--来自服务器的系统消息
	elseif (eventId == ds.GameEventIDDefine.GAME_EVENT_ID_SUB_SYSTEM_MSG) then
		OnRecvRoomSystemMsg(MTData:getData2(),MTData:getData3(),MTData:getStr1())
	--判断是否达到领取低保的状态
	elseif (eventId == ds.GameEventIDDefine.GAME_EVENT_ID_JUDGE_LOW_INSURE) then
		OnJudgeLowInsure()
	end
	
end

--正常关闭游戏
function OnGameClose(exitCode)
	
	DSLayerMgr.modeSelectedNotify(1)
end

function OnCloseGameConfirm()

	local text = ds.StringData:shared():stringFromKey("in_game_status_quick_hint")
	local aff_Img = nil
	local nServerType = ds.CGameCenterManager:Instance():GetGameServerItem():GetGameServer():getServerType()
	if (nServerType == ds.Define.GAME_GENRE_FULL or nServerType == ds.Define.GAME_GENRE_TIME) then
		text = ds.StringData:shared():stringFromKey("in_game_status_quick_match")
		aff_Img = "common/Button_exit_text.png"
	end
	--DSDialogLayer.create(ds.Dialog.Type.AFFIRMANDCANCEL,text, nil, aff_Img, nil, function()
		if ds.IServerItem:get() ~= nil then
			ds.IClientKernel:get():SetGameStatus(ds.Define.GAME_STATUS_FREE)
			ds.IServerItem:get():OnGFGameClose(ds.Define.enGameExitCode.GameExitCode_Normal)
			--ds.IClientKernel:destory()
		end
	--end,true,"","")
end

function OnGoldNotEnough()
	
	local text = ds.StringData:shared():stringFromKey("user_need_recharge")
	local title = ds.StringData:shared():stringFromKey("system_tips_title")
	local confirmLabal = "PlatForm/Button/goRecharge.png"
	
	DSDialogLayer.create(ds.Dialog.Type.AFFIRMANDCANCEL,text,title,confirmLabal,nil,function()
		ds.MyNotification:getInstance():dispatchEvent("game_event",ds.MTData:create(ds.GameEventIDDefine.GAME_EVENT_ID_SHOW_PAY))
	end
	, nil, nil, nil, nil, nil, nil)
	
end

function OnReconnectNetError()
	
	local text = ds.StringData:shared():stringFromKey("System_Tips_26")
	DSDialogLayer.create(ds.Dialog.Type.AFFIRM,text, "",nil, nil, function()
		if ds.IClientKernel:get() ~= nil then
			
			ds.IClientKernel:get():Intermit(ds.Define.enGameExitCode.GameExitCode_Shutdown)
		end
	end)
end


function OnReconnectUnknown()
	
	DSLayerMgr.modeSelectedNotify(1)
end

--检测到网络
function OnDetectNetAgain(gameScene)

	local text = ds.StringData:shared():stringFromKey("System_Tips_28")
	DSDialogLayer.create(ds.Dialog.Type.NONEBUTTON,text, "",nil, nil, nil, nil)
	
	gameScene:OnNetDetectedInNetLossState()
end

--超时处理
function OnDetectNetTimeout()
	
	local text = ds.StringData:shared():stringFromKey("System_Tips_36")
	DSDialogLayer.create(ds.Dialog.Type.AFFIRM,text, "",nil, nil, nil, nil, function()
		if ds.IClientKernel:get() ~= nil then
			
			ds.IClientKernel:get():Intermit(ds.Define.enGameExitCode.GameExitCode_Shutdown)
		end
	end)
end

--显示充值界面
function OnShowPayPage()
	
	local nextLayer = RechargeLayer.create()
	if (nextLayer ~= nil) then
		nextLayer:Run(false)
	end
end

--服务器通知客户端关闭
function OnServerNotifyCloseClient()

	local text = ds.StringData:shared():stringFromKey("in_game_gold_lack")
	DSDialogLayer.create(ds.Dialog.Type.AFFIRM,text, "",nil, nil, function()
		if ds.IClientKernel:get() ~= nil then
			
			ds.IClientKernel:get():Intermit(ds.Define.enGameExitCode.GameExitCode_Normal)
		end
	end)
end

function OnRecvSystemMsg(strMsg)
	
	if ds.gameCommonUI ~= nil then
		
		ds.gameCommonUI:OnRecvSystemMsg(strMsg)
	end
	
end

--处理服务器的消息提示
function OnRecvRoomSystemMsg(msgType,nQuickMode,stringData)
	
	local nCloseRoomFlag = ds.LuaBitLib:bAnd(msgType,ds.CommonMsg.SMT_CLOSE_ROOM)
	local nCloseGameFlag = ds.LuaBitLib:bAnd(msgType,ds.CommonMsg.SMT_CLOSE_GAME)
	local nCloseLinkFlag = ds.LuaBitLib:bAnd(msgType,ds.CommonMsg.SMT_CLOSE_LINK)
	
	local nEjectFlag 	= ds.LuaBitLib:bAnd(msgType,ds.CommonMsg.SMT_EJECT)
	local nChatFlag 	= ds.LuaBitLib:bAnd(msgType,ds.CommonMsg.SMT_CHAT)
	
	--链接需要断开
	if nCloseRoomFlag > 0 or nCloseGameFlag > 0 or nCloseLinkFlag > 0 then
		
		local function confirmAndAutoDeal()
			
			--销毁客户端	
			if ds.IClientKernel:get() ~= nil  then
				ds.IClientKernel:get():Intermit(ds.Define.enGameExitCode.GameExitCode_Client_Active)	
			end
				
			if nCloseRoomFlag > 0 or nCloseLinkFlag > 0 or (nCloseGameFlag > 0 and nQuickMode > 0)then
		
				--关闭链接
				local gameCenterManager = ds.CGameCenterManager:Instance()
				local serverItem = gameCenterManager:GetServerItem()
				if (serverItem ~= nil) then
					serverItem:IntermitConnect(true)
				end
				
				--
				RoomNotificationMgr.func_server_close()
					
			end	
		end
					
		DSDialogLayer.create(ds.Dialog.Type.AFFIRM,stringData,ds.StringData:shared():stringFromKey("system_tips_title"),nil, nil, confirmAndAutoDeal, nil,confirmAndAutoDeal)
		
	else
		
		if nChatFlag > 0 then
			
			
		elseif nEjectFlag > 0 then
			
			DSDialogLayer.create(ds.Dialog.Type.AFFIRM,stringData,ds.StringData:shared():stringFromKey("system_tips_title"),nil, nil, nil, nil, nil)
		end
	end
	
end

function OnJudgeLowInsure()
	
	local pGlobalUserInfo = ds.CGlobalUserInfo:GetInstance()
	local userScore = pGlobalUserInfo:getUserScore()
	local userInsure = pGlobalUserInfo:getUserInsure()
	if userScore + userInsure >= 2000 then
		return
	end
	
	if LoginMission.m_cbBaseEnsureTodayTimes >= LoginMission.m_cbBaseEnsureMaxTimes then
		return
	end
	
	local function ConfirmReceiveReward()
		LowInsuranceMission.create()
	end
	local title = ds.StringData:shared():stringFromKey("remind_title")
	local insureReminds = ds.StringData:shared():stringFromKey("LowInsureReminds")
	local text = string.format(insureReminds,LoginMission.m_cbBaseEnsureTodayTimes + 1,LoginMission.m_cbBaseEnsureMaxTimes)
	
	DSDialogLayer.create(ds.Dialog.Type.AFFIRM,text,title,"PlatForm/WelfareUI/ReceiveAward.png",nil, ConfirmReceiveReward,nil,nil)--再加个非nil参数就会显示游戏弹框
	
end
