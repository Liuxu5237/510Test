module("gameMatchInterface", package.seeall)

matchParam = {
	mMatchWaittingCount = 0,
	mMatchTotalUser = 0,
		
	--mMatchFee = 0,
	mMatchDesc = {
		szTitle = {},
		szDescribe = {},
		crTitleColor = 0,
		crDescribeColor = 0,	
	},
	
	mMatchInfo = {
		wGameCount = 0,
		szTitle = {},
	},
	
	mMatchWaitTip = {
		lScore = 0,
		wRank = 0,
		wCurTableRank = 0,
		wUserCount = 0,
		wPlayingTable = 0,
		szMatchName = "",
	},
	
	mMatchResult = {
		wGameType = 0,
		lGold = 0,
		dwIngot = 0,
		dwExperience = 0,
		dwTicket = 0,--门票
		szUserName = "",
		szMatchName = "",
		wUserRank = 0,
		wUserCount = 0,
	},
	
	mMatchRankList = {
		wCount = 0,
		sRankData = {},
	},
	
	mMatchRewad = nil,
	
	--金币更新
	mMatchGoldUpdate = {
		lCurrGold,
        lCurrIngot,
		lCurrentTicket,
        dwCurrExprience,
	},
		
	--当前比赛状态
	mMatchStatus = {},
	
	--报名信息
	mSignupMatchInfo = {},
	--当前进入的房间ID
	mCurMatchServerID = 0, 

	--剩余人数
	mRemainUserNum = 0,
	--当前排名
	mCurrentRank = 0,
	
	
--比赛房间管理*********************************************************************************************************
	--	
	mKindID = 0,
	mMatchRoomList = nil,			--比赛房间列表指针
	--定时赛房间计时器
	mMatchTimerID = nil,
	mVectorTimer = nil,
	
	--用户报名信息
	mStrMatchTelePhone = nil,		--联系电话
	mStrMatchPlayerName = nil,		--用户姓名
--	*********************************************************************************************************
}

function RunTimer(kindID)
	if kindID == nil then	
		return
	end
	
	local bOpen = false
	if matchParam.mMatchTimerID == nil then
		bOpen = true
	elseif matchParam.mKindID ~= kindID then
		--重新开启定时器
		KillTimer();
		bOpen = true
	end
	
	matchParam.mKindID = kindID
	--开启定时器
	if bOpen == true then
		
		local function OnTime()
			if matchParam.mVectorTimer ~= nil then
				for k, v in pairs(matchParam.mVectorTimer) do 
					if (v ~= nil) and (v > -1) then
						matchParam.mVectorTimer[k] = matchParam.mVectorTimer[k] - 1
						if matchParam.mMatchRoomList then
							matchParam.mMatchRoomList:onServerTimer(k,v)
						end
					end
				end
				
			end
		end
			
		local scheduler = cc.Director:getInstance():getScheduler()	
		matchParam.mMatchTimerID = scheduler:scheduleScriptFunc(OnTime, 1, false)
	end
		
end

function setMatchListPtr(ptr)
	matchParam.mMatchRoomList = ptr
end

function KillTimer(serverID)
	if matchParam.mMatchTimerID ~= nil then
		if serverID == nil then
			local scheduler = cc.Director:getInstance():getScheduler()
			scheduler:unscheduleScriptEntry(matchParam.mMatchTimerID)		
			matchParam.mMatchTimerID = nil
			matchParam.mVectorTimer = nil
		else
			if matchParam.mVectorTimer == nil then
				matchParam.mVectorTimer = {}
			end
			if matchParam.mVectorTimer[serverID] == nil then				
				matchParam.mVectorTimer[serverID] = {}
			end
			matchParam.mVectorTimer[serverID] = -1
		end
	end
end

function setTimer(serverID,TimerNumber)
	if (serverID == nil) or (serverID == 0) or (TimerNumber == nil) then
		return
	end
	
	if matchParam.mVectorTimer == nil then
		matchParam.mVectorTimer = {}
	end
	if( matchParam.mVectorTimer[serverID] == nil or matchParam.mVectorTimer[serverID] > TimerNumber or matchParam.mVectorTimer[serverID] < 1 ) then 
		matchParam.mVectorTimer[serverID] = TimerNumber
	end
end

function getTimer(serverID)
	if (serverID == nil) or (serverID == 0) or (matchParam.mMatchTimerID == nil) or (matchParam.mVectorTimer == nil) then
		return nil
	end
	
	return matchParam.mVectorTimer[serverID]
end

function getCallUserInfo()
	return matchParam.mStrMatchPlayerName, matchParam.mStrMatchTelePhone
end

--*********************************************************************************************

--c++调用
function OnSocketMainMatch(subCmd,packet,dataSize)
	ds.log("OnSocketMainMatch subCmd = "..subCmd.." size = "..dataSize)
	--报名费提示
	if subCmd == ds.GameServer.SUB_GR_MATCH_FEE then
		local lMatchFee = packet:read8Byte()
		if lMatchFee > 0 then
			
			--显示提示
			
		else			
			local gameCenterManager = ds.CGameCenterManager:Instance()
			local serverItem = gameCenterManager:GetServerItem()
			if (serverItem == nil) then
				return true
			end
							
			local msg = ds.PacketWriteAide:new()
			msg:write8Byte(lMatchFee)
			
			serverItem:SendSocketData(ds.GameServer.MDM_GR_MATCH,ds.GameServer.SUB_GR_MATCH_FEE,msg:getBuffer(), msg:getPosition())
		end
		
		return true
	--更新人数
	elseif subCmd == ds.GameServer.SUB_GR_MATCH_NUM then
		
		local WaittingCount = packet:read4Byte()
		local TotalUser = packet:read4Byte()
        matchParam.mMatchTotalUser = TotalUser
		--显示比赛人数
		local tempMatchList = MatchListLayer.getMatchList()	
		if tempMatchList ~= nil then
			tempMatchList:PlayerCountUpdata(WaittingCount,TotalUser)
		end
		
		return true
				
	--比赛状态
	elseif subCmd == ds.GameServer.SUB_GR_MATCH_STATUS then
			
		onSubMatchStaus(packet:readByte())
		return true 
	--剩余时间
	elseif subCmd == ds.GameServer.SUB_GR_MATCH_REMAIN then
		local endTimer = packet:read8Byte()
		local pGameServerItem = ds.CGameCenterManager:Instance():GetGameServerItem()
		if pGameServerItem ~= nil and pGameServerItem:GetGameMatch() then
			pGameServerItem:GetGameMatch():setMatchEndTime(endTimer)
		end
		local tempMatchList = MatchListLayer.getMatchList()
		if tempMatchList ~= nil then
			tempMatchList:setMatchTimer(endTimer,nil)
		end
		
		return true
	--比赛描述
	elseif subCmd == ds.GameServer.SUB_GR_MATCH_DESC then
	
		for i = 0, 3 do
			matchParam.mMatchDesc.szTitle[i] = packet:readString(64)
		end
		
		for i = 0, 3 do
			matchParam.mMatchDesc.szDescribe[i] = packet:readString(64)
		end
		
		matchParam.mMatchDesc.crTitleColor = packet:read4Byte()
		matchParam.mMatchDesc.crDescribeColor = packet:read4Byte()
			
		return true
	--比赛奖励
	elseif subCmd == ds.GameServer.SUB_GR_MATCH_REWARD then
		matchParam.mMatchRewad = {
			nCount = ( dataSize / ( 16*2 + 8 + 8) ) - 1,
			strMatchInfo = {},
			lScore = {},	
			dwIngot = {},
			dwTickets = {},
		}
		
		for i = 0, matchParam.mMatchRewad.nCount do
			matchParam.mMatchRewad.strMatchInfo[i] = packet:readString(16)

			matchParam.mMatchRewad.lScore[i] = packet:read8Byte()
		
			matchParam.mMatchRewad.dwIngot[i] = packet:read4Byte()
		
			matchParam.mMatchRewad.dwTickets[i] = packet:read4Byte()
		end
		
		local tempMatchList = MatchListLayer.getMatchList()
		if tempMatchList ~= nil then
			tempMatchList:UpdataMatchRewad()
		end
		return true
	--金币更新
	elseif subCmd == ds.GameServer.SUB_GR_MATCH_GOLDUPDATE then
		matchParam.mMatchGoldUpdate.lCurrGold = packet:read8Byte()
		matchParam.mMatchGoldUpdate.lCurrIngot = packet:read8Byte()
		matchParam.mMatchGoldUpdate.lCurrentTicket = packet:read8Byte()
		matchParam.mMatchGoldUpdate.dwCurrExprience = packet:read4Byte()
		
		--不需要读取经验
		local pGlobalUserInfo = ds.CGlobalUserInfo:GetInstance()	
		pGlobalUserInfo:setUserScore(matchParam.mMatchGoldUpdate.lCurrGold)
		pGlobalUserInfo:setUserIngot(matchParam.mMatchGoldUpdate.lCurrIngot)
		pGlobalUserInfo:setUserTickets(matchParam.mMatchGoldUpdate.lCurrentTicket)
					
		local tempMatchList = MatchListLayer.getMatchList()
		if tempMatchList ~= nil then
			tempMatchList:UpdataUserInfo()	
		end
		return true
	elseif subCmd == ds.GameServer.SUB_GR_MATCH_RESULT then	
		
		matchParam.mMatchResult.wGameType = packet:read2Byte()
		matchParam.mMatchResult.lGold = packet:read8Byte()
		matchParam.mMatchResult.dwIngot = packet:read4Byte()
		matchParam.mMatchResult.dwExperience = packet:read4Byte()
		matchParam.mMatchResult.dwTicket = packet:read4Byte()
		matchParam.mMatchResult.szUserName = packet:readString(32)
		matchParam.mMatchResult.szMatchName = packet:readString(32)
		matchParam.mMatchResult.wUserRank = packet:read2Byte()
		matchParam.mMatchResult.wUserCount = packet:read2Byte()

		-- local pGlobalUserInfo = ds.CGlobalUserInfo:GetInstance()	
		-- pGlobalUserInfo:setUserScore(matchParam.mMatchResult.lGold + pGlobalUserInfo:getUserScore())
		-- pGlobalUserInfo:setUserTickets(matchParam.mMatchResult.dwTicket + pGlobalUserInfo:getUserTickets())
		-- pGlobalUserInfo:setUserIngot(matchParam.mMatchResult.dwIngot + pGlobalUserInfo:getUserIngot())
		
		
		ds.MyNotification:getInstance():dispatchEvent("MatchFinishInfo")
		
		--比赛结果
		return true
	elseif subCmd == ds.GameServer.SUB_GR_MATCH_BINDINFO then
		matchParam.mStrMatchPlayerName = packet:readString(ds.Define.LEN_NICKNAME)
		matchParam.mStrMatchTelePhone = packet:readString(ds.Define.LEN_MOBILE_PHONE)

		return true
	end
	
	return false
end

function OnSocketFrameMatch(subCmd,packet,dataSize)
	ds.log(subCmd,packet,dataSize)
	if subCmd == ds.GameServer.SUB_GR_MATCH_INFO then
		for i = 0, 3 do
			ds.log("matchParam.mMatchInfo.szTitle:",matchParam.mMatchInfo.szTitle[i])
			matchParam.mMatchInfo.szTitle[i] = packet:readString(64)
		end
		matchParam.wGameCount = packet:read2Byte()

		ds.MyNotification:getInstance():dispatchEvent("FreshScoreOfDi")
		--处理比赛信息
		return true
	elseif subCmd == ds.GameServer.SUB_GR_MATCH_WAIT_TIP then
		
		-- if dataSize ~= 0 then
		-- 	matchParam.mMatchWaitTip.lScore = packet:read8Byte()
			
		-- 	matchParam.mMatchWaitTip.wRank = packet:read2Byte()
		-- 	matchParam.mMatchWaitTip.wCurTableRank = packet:read2Byte()
		-- 	matchParam.mMatchWaitTip.wUserCount = packet:read2Byte()
		-- 	matchParam.mMatchWaitTip.wPlayingTable = packet:read2Byte()
		-- 	matchParam.mMatchWaitTip.szMatchName = packet:readString(32)

		ds.log("matchParam.mMatchWaitTip:")

		ds.MyNotification:getInstance():dispatchEvent("MatchWaitInfo")
		-- else
			
			
		-- end
		
		--比赛等待提示
		return true
		
	elseif subCmd == ds.GameServer.SUB_GR_MATCH_RESULT then	
		
		matchParam.mMatchResult.wGameType = packet:read2Byte()
		matchParam.mMatchResult.lGold = packet:read8Byte()
		matchParam.mMatchResult.dwIngot = packet:read4Byte()
		matchParam.mMatchResult.dwExperience = packet:read4Byte()
		matchParam.mMatchResult.dwTicket = packet:read4Byte()
		matchParam.mMatchResult.szUserName = packet:readString(32)
		matchParam.mMatchResult.szMatchName = packet:readString(32)
		matchParam.mMatchResult.wUserRank = packet:read2Byte()
		matchParam.mMatchResult.wUserCount = packet:read2Byte()

		-- local pGlobalUserInfo = ds.CGlobalUserInfo:GetInstance()	
		-- pGlobalUserInfo:setUserScore(matchParam.mMatchResult.lGold + pGlobalUserInfo:getUserScore())
		-- pGlobalUserInfo:setUserTickets(matchParam.mMatchResult.dwTicket + pGlobalUserInfo:getUserTickets())
		-- pGlobalUserInfo:setUserIngot(matchParam.mMatchResult.dwIngot + pGlobalUserInfo:getUserIngot())
		
		
		ds.MyNotification:getInstance():dispatchEvent("MatchFinishInfo")
		
		--比赛结果
		return true
	
	elseif subCmd == ds.GameServer.SUB_GR_MATCH_RankList then
		-- 比赛排名
		matchParam.mMatchRankList.wCount = packet:read4Byte()
		
		return true
	elseif subCmd == ds.GameServer.SUB_GR_MATCH_RemainUser then
		-- 剩余人数
		matchParam.mRemainUserNum = packet:read2Byte()
		ds.MyNotification:getInstance():dispatchEvent("ReviseRankInfo",ds.MTData:create(matchParam.mCurrentRank,matchParam.mRemainUserNum))
		return true
	elseif subCmd == ds.GameServer.SUB_GR_MATCH_CurrentRank then
		-- 比赛排名
		matchParam.mCurrentRank = packet:read2Byte()
		ds.MyNotification:getInstance():dispatchEvent("ReviseRankInfo",ds.MTData:create(matchParam.mCurrentRank,matchParam.mRemainUserNum))
		
		return true
	elseif subCmd == ds.GameServer.SUB_GR_USER_RESPOND_QUIT then	--请求退出消息
		GameCommonUi.QueryQuitGame(packet:readByte())
		return true
	end
	
	return false
end

function onSubMatchStaus(matchState)
	DSWaitingLayer.dismiss()
	
	--MS_NULL        =  0x00     ,           --没有状态
	--MS_SIGNUP      =  0x01     ,           --报名状态
	--MS_MATCHING    =    0x02   ,           --比赛进行
	--MS_MATCHEND    =    0x03   ,           --比赛结束
	--MS_OUT         =  0x04     ,           --淘汰状态
	--MS_TRUSTEE     =  0x05     ,           --比赛结束
		
	local pGameServerItem = ds.CGameCenterManager:Instance():GetGameServerItem()
	if pGameServerItem ~= nil then
		local pGameServer = pGameServerItem:GetGameServer()
		local serverID = pGameServer:getServerID()
		
		-- 设置房间比赛状态
		matchParam.mMatchStatus[serverID] = matchState
		
		if matchState ~= ds.Define.MS_MATCHING and matchState ~= ds.Define.MS_SIGNUP then
			matchParam.mCurMatchServerID = 0
			setMatchSignup(serverID, false);
		end
		
		--更新UI 
		local tempMatchList = MatchListLayer.getMatchList()
		if tempMatchList ~= nil then
			tempMatchList:MatchStateUpdata(matchState,pGameServerItem,serverID)
		end
	end
end

function OnSunLogonSignupInfo(packet, size)
	
	if (size % 10) == 0 then
		local nServerCount = size / 10
		for i = 1, nServerCount do
			local ServerID			  = packet:read2Byte()					-- 房间标识
			
			matchParam.mSignupMatchInfo[ServerID] = {}		
			matchParam.mSignupMatchInfo[ServerID].dwMatchID = packet:read4Byte()	-- 比赛标识
			matchParam.mSignupMatchInfo[ServerID].dwMatchNO = packet:read4Byte()	-- 比赛场次
			matchParam.mSignupMatchInfo[ServerID].bMatchSign = false				-- 报名标识
		end
		
	end
end
--设置参赛状态
function NotifyListServer()
	if matchParam.mSignupMatchInfo == nil or ds.common.GetTableLenth(matchParam.mSignupMatchInfo) == 0 then
		return
	end

	local pServerListData = ds.CServerListData:shared()
	for Id, MatchItem in pairs(matchParam.mSignupMatchInfo) do
		
		local pGameServerItem = pServerListData:SearchGameServer(Id)
		
		if pGameServerItem ~= nil and pGameServerItem:GetGameServer() then
			local ServerType  = pGameServerItem:GetGameServer():getServerType();
			if ServerType == ds.Define.GAME_GENRE_TIME then
				matchParam.mSignupMatchInfo[Id].bMatchSign = true
			end
		end	
		
	end		
end

--获取参赛状态
function getMatchSignup( serverID )
	if serverID == nil or serverID == 0 or matchParam.mSignupMatchInfo == nil or matchParam.mSignupMatchInfo[serverID] == nil then
		return false
	end
	return matchParam.mSignupMatchInfo[serverID].bMatchSign
end

function setMatchSignup( serverID, bState )
	if serverID == nil or serverID == 0 or bState == nil or
		matchParam.mSignupMatchInfo == nil or matchParam.mSignupMatchInfo[serverID] == nil then
		return
	end
	
	matchParam.mSignupMatchInfo[serverID].bMatchSign = bState
	
end

--获取比赛赛状态
function getMatchStatus( serverID )
	if matchParam.mMatchStatus == nil or matchParam.mMatchStatus[serverID] == nil then
		return ds.Define.MS_NULL
	end
	
	return matchParam.mMatchStatus[serverID]
end

--查找电视赛房间
function Find_TVMatchServerItem()
	local pServerListData = ds.CServerListData:shared()
	local GameServerCount = pServerListData:GetGameServerCount()
	for i = 0, GameServerCount - 1 do
		local pGameServerItem = pServerListData:SearchGameServerByIndex(i)
		if pGameServerItem ~= nil then
				
			local pGameServer = pGameServerItem:GetGameServer()
			local pGameMatch = pGameServerItem:GetGameMatch()
			if pGameServer ~= nil and pGameMatch ~= nil then
			
				if pGameServer:getServerType() == ds.Define.GAME_GENRE_TIME and pGameMatch:getMatchFeeType() == ds.GameServer.MATCH_FEE_TYPE_TICKET then 
					return pGameServerItem, pGameMatch
				end	
			end			
		end
	end
	return nil
end

--游戏房间是否连接状态
function IsServer()
	if ds.IServerItem:get() ~= nil and ds.IServerItem:get():IsService() == true then
		return true
	end
	return false
end
--连接游戏房间
function ConnectServer(pGameServerItem)
	if pGameServerItem ~= nil then
		ds.CGameCenterManager:Instance():connectServer(pGameServerItem)
		DSWaitingLayer.create()
	end
end

function DisconnectServer()
	if ds.IServerItem:get() ~= nil and ds.IServerItem:get():IsService() == true then
		ds.CGameCenterManager:Instance():disconnectServer()
	end
end

--申请报名
function Send_BaoMingApply(cost)
	if ds.IServerItem:get() ~= nil and cost ~= nil then
		local packet = ds.PacketWriteAide:new()
		packet:write8Byte(cost)
		local bSesult = ds.IServerItem:get():SendSocketDataLua(ds.GameServer.MDM_GR_MATCH,ds.GameServer.SUB_GR_MATCH_FEE, packet)
		if (bSesult == false) then
			local title = ds.StringData:shared():stringFromKey("Dialog_title")
			local text = ds.StringData:shared():stringFromKey("System_Tips_3")
			DSDialogLayer.create(ds.Dialog.Type.AFFIRM, text, title, nil, nil, function()
				--			
			end, nil, nil, nil, ccc3(241,211,128), ccc3(249,223,130))	
		else	 
			--DSWaitingLayer.create()
		end
	end
end

--上传玩家的名字和电话号码
function Send_UserNameOrIphoneApply(name, iphoneNum)
	if ds.IServerItem:get() ~= nil then
		local packet = ds.PacketWriteAide:new()
		packet:writeString(name, ds.Define.LEN_NICKNAME)
		packet:writeString(iphoneNum, ds.Define.LEN_USER_IPHONE)
		local bSesult = ds.IServerItem:get():SendSocketDataLua(ds.GameServer.MDM_GR_MATCH,ds.GameServer.SUB_GR_MATCH_BINDINFO, packet)
		if (bSesult == false) then
			local title = ds.StringData:shared():stringFromKey("Dialog_title")
			local text = ds.StringData:shared():stringFromKey("System_Tips_3")
			DSDialogLayer.create(ds.Dialog.Type.AFFIRM, text, title, nil, nil, function()
				--			
			end, nil, nil, nil, ccc3(241,211,128), ccc3(249,223,130))	
		else	 
			--DSWaitingLayer.create()	 
		end
	end
end

--取消报名
function Send_CancelBaoMing()
	if ds.IServerItem:get() ~= nil then

		local bSesult = ds.IServerItem:get():SendSocketData(ds.GameServer.MDM_GR_MATCH,ds.GameServer.SUB_GR_LEAVE_MATCH)
		if (bSesult == false) then
			local title = ds.StringData:shared():stringFromKey("Dialog_title")
			local text = ds.StringData:shared():stringFromKey("System_Tips_3")
			DSDialogLayer.create(ds.Dialog.Type.AFFIRM, text, title, nil, nil, function()
				--			
			end, nil, nil, nil, ccc3(241,211,128), ccc3(249,223,130))	
		else
			DSWaitingLayer.create()	
			 
		end
	end
end

function setMachTimerTelephone(phone)
	matchParam.mStrMatchTelephone = phone
end

function setMachTimerPlayerName(name)
	matchParam.mStrMatchPlayerName = name
end


	
			

