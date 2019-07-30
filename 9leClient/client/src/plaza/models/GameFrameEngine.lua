local BaseFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.BaseFrame")
local WebFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.WebFrame")
local GameFrameEngine = class("GameFrameEngine",BaseFrame)

local UserItem = appdf.req(appdf.CLIENT_SRC.."plaza.models.ClientUserItem")
local game_cmd = appdf.req(appdf.HEADER_SRC .. "CMD_GameServer")
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local GameChatLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.game.GameChatLayer")

local cmd_private = appdf.req(appdf.CLIENT_SRC .. "privatemode.header.CMD_Private")
local cmd_pri_game = cmd_private.game

local QueryDialog = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.QueryDialog")

--全局变量
g_gameframe = nil

function GameFrameEngine:getInstance()
    return g_gameframe
end


function GameFrameEngine:ctor(view,callbcak)
	GameFrameEngine.super.ctor(self,view,callbcak)
	self._kindID = 0
	self._kindVersion = 0

	-- 短连接服务
	self._shotFrames = {}
	-- 语音队列
	self._tabVoiceMsgQueue = {}
	self._bPlayVoiceRecord = false

	g_gameframe = self
	
end

--添加短连接
function GameFrameEngine:addShotFrame(shotFrame)

    --查看是否重复
    for i = 1, #self._shotFrames do
        if self._shotFrames[i] == shotFrame then
            return
        end 
    end

    if appdf.isObject(shotFrame) then
        shotFrame._gameFrame = self
        table.insert(self._shotFrames, shotFrame)
    end
end

--移除短连接
function GameFrameEngine:removeShotFrame(shotFrame)

    for i = 1, #self._shotFrames do
        if self._shotFrames[i] == shotFrame then
            if appdf.isObject(shotFrame) then
                shotFrame._gameFrame = nil
            end
            table.remove(self._shotFrames, i)
            return
        end 
    end
end

function GameFrameEngine:setKindInfo(id,version)
	self._kindID = id 
	self._kindVersion = version
	return self
end

function GameFrameEngine:onInitData()

	--房间信息 以后转移
	self._wTableCount = 0
	self._wChairCount = 0
	self._wServerType = 0
	self._dwServerRule = 0
	self._UserList = {}
	self._tableUserList = {}
	self._tableStatus = {}
	self._delayEnter = false

	self._wTableID	 	= yl.INVALID_TABLE
	self._wChairID	 	= yl.INVALID_CHAIR
	self._cbTableLock	= 0
	self._cbGameStatus 	= 0
	self._cbAllowLookon	= 0
	self.bChangeDesk = false
	self.bEnterAntiCheatRoom = false 		--进入防作弊房间
	GlobalUserItem.bWaitQuit = false 		-- 退出等待
	self._tabVoiceMsgQueue = {}
	self._bPlayVoiceRecord = false
	self._nPlayVoiceId = nil
	self.isSendGameOption = false --		斗地主用到 不影响其他
end

--设置开启防作弊房
function GameFrameEngine:setEnterAntiCheatRoom( bEnter )
	self.bEnterAntiCheatRoom = bEnter
end

--连接房间
function GameFrameEngine:onLogonRoom(roomInfo)
	self._roomInfo = roomInfo --GlobalUserItem.GetRoomInfo()

	if not self._roomInfo and nil ~= self._callBack then
		self._callBack(-1,"获取房间信息失败！")
		return
	end
	if yl.IsCCGame(self._roomInfo.wKindID) then
		local pServerListData = ds.CServerListData:shared()
		print("=-0===============")
		print(pServerListData)
	    pServerListData:ClearGameServer()

        local GameServer = ds.tagGameServer:new()
        GameServer:setKindID(self._roomInfo.wKindID)
	    GameServer:setNodeID(self._roomInfo.wNodeID)
	    GameServer:setSortID(self._roomInfo.wSortID)
	    GameServer:setServerID(self._roomInfo.wServerID)
	    GameServer:setServerKind(self._roomInfo.wServerKind)
	    GameServer:setServerType(self._roomInfo.wServerType)
	    GameServer:setServerPort(self._roomInfo.wServerPort)
	    GameServer:setCellScore(self._roomInfo.lCellScore)
	    GameServer:setEnterScore(self._roomInfo.lEnterScore)
	    GameServer:setServerRule(self._roomInfo.dwServerRule)
	    GameServer:setOnLineCount(self._roomInfo.dwOnLineCount)
	    GameServer:setAndroidCount(self._roomInfo.dwAndroidCount)
	    GameServer:setFullCount(self._roomInfo.dwFullCount)

	    GameServer:setServerAddr(self._roomInfo.szServerAddr, yl.LEN_SERVER)
		GameServer:setServerName(self._roomInfo.szServerName, yl.LEN_SERVER)
		print(GameServer)

        pServerListData:InsertGameServer(GameServer)

		local GameServerItem = ds.CServerListData:shared():SearchGameServer(self._roomInfo.wServerID)
		print(GameServerItem)

		local GameCenterManager = ds.CGameCenterManager:Instance()
		print(GameCenterManager)
        GameCenterManager:connectServer(GameServerItem)
    end

	
	self._webFrame =WebFrame:create(self, function(result, message)
		if self.webLogonGameCallBack then
			self:webLogonGameCallBack(result,message)
		end
	end)
	
    --苹果审核的时候如果直接使用IP地址进入房间，可能因为IPV6的原因不能审核通过，当审核的时候直接使用登录域名进入房间，比较保险
    local szServerAddr = yl.APPSTORE_VERSION and yl.LOGONSERVER or self._roomInfo.szServerAddr
    --local wServerPort = self._roomInfo.wServerPort

	local wServerPort = self._roomInfo.wServerID
	if self._roomInfo.wKindID == 26 then
		self._wChairCount =200
	elseif self._roomInfo.wKindID == 200 then
		self._wChairCount =3
		--self:setEnterAntiCheatRoom(true)
	elseif self._roomInfo.wKindID == 29 then
		self._wChairCount =100
	end
	--change by zzy
	local action3 = {}
    action3["addr"] = "127.0.0.1"
    action3["port"]= wServerPort   
    local pargams3 = {2,1,action3}
   
    local action4 = cjson.encode(pargams3)
    --local msg =  cjson.decode(action2)   
	self._webFrame:wsSendString(action4) 
	
	print("登录房间："..szServerAddr.."#"..wServerPort)
	-- if not self:onCreateSocket(szServerAddr,wServerPort) and nil ~= self._callBack then
		-- self._callBack(-1,"建立连接失败！")
	-- end
end

function GameFrameEngine:webLogonGameCallBack( result,message2 )
	if message2 == nil then
		return
	end
	local action2 = cjson.encode(message2)
	local message = cjson.decode(message2)
	
	if  g_gameframe._CCSink ~= nil then
		if message[1] == 2 and message[2] == 100 then
			local pargams4 = {8,9}
			local action5 = cjson.encode(pargams4)
			self._webFrame:wsSendString(action5) 
		elseif message[1] == yl.MDM_GF_FRAME then --游戏状态
			if message[2] == yl.SUB_GF_GAME_STATUS then
				self._cbGameStatus = message[3]["bGameStatus"]
				self._cbAllowLookon = message[3]["bAllowLookon"]
				
			end
		elseif message[1] == 8  then
			print(message)
	
			local newstatus = {}
			newstatus.wTableID   	= message[3]["T"]
			newstatus.wChairID   	= message[3]["C"]
			newstatus.cbUserStatus	= message[3]["S"]
	
			if message[2] == 100 then
				--print("666")
				dump(message)
				local useritem2 = self._UserList[message[3]["U"]]
				local newitem = UserItem:create()
				--记录自己桌椅号
				if message[3]["U"] ==  GlobalUserItem.dwUserID then
					self._wTableID = message[3]["T"]
					self._wChairID = message[3]["C"]
				end
				if useritem2 == nil  then
				
					--虚拟信息
					newitem.szNickName 		= message[3]["A"]
					newitem.dwUserID 		= message[3]["U"]
					newitem.cbUserStatus 	= message[3]["S"]
					newitem.wTableID 		= message[3]["T"]
					newitem.wChairID 		= message[3]["C"]
					newitem.lScore   		= message[3]["M"]
					newitem.cbGender   		= message[3]["G"]
					newitem.wFaceID			= message[3]["F"]
		
					self._UserList[newitem.dwUserID] = newitem
					print("self._UserList"..newitem.dwUserID.."|"..newitem.wTableID);
					-- self:onUpDataTableUser(newitem.wTableID,newitem.wChairID,newitem)
					-- if self._viewFrame and self._viewFrame.onEventUserEnter then
					-- 	self._viewFrame:onEventUserEnter(newitem.wTableID,newitem.wChairID,newitem)
					-- end
					-- --发送查询
					-- self:QueryUserInfo(newstatus.wTableID,newstatus.wChairID)
					
				elseif useritem2~=nil then
					
					local strData = message
					local mid, sid = strData[1], strData[2]
					if mid == 8  then
						mid = 3
					end
					if sid == 100 then
						sid = 102
					end
					message[3]["dwUserID"] 		= message[3]["U"]
					message[3]["cbUserStatus"] 	= message[3]["S"]
					message[3]["wTableID"] 		= message[3]["T"]
					message[3]["wChairID"] 		= message[3]["C"]
					
					local dataBuffer = CCmd_Data:create()
					dataBuffer:setcmdinfo(mid,sid)					
					dataBuffer:pushdword(message[3]["dwUserID"])
					dataBuffer:pushword(message[3]["wTableID"])
					dataBuffer:pushword(message[3]["wChairID"])
					dataBuffer:pushbyte(message[3]["cbUserStatus"])

					if self.onScoketRyFish then
						self:onScoketRyFish(dataBuffer)
					end

					mid = 1
					sid = 102
	
					local dataBuffer = CCmd_Data:create()
					dataBuffer:setcmdinfo(mid,sid)					
	
					if self.onScoketRyFish then
						self:onScoketRyFish(dataBuffer)
					end

				end
				
				if useritem2 == nil then
					
					--初始化玩家信息
					message[3]["dwUserID"] 		= message[3]["U"]
					message[3]["szNickName"] 	= message[3]["A"]
					message[3]["cbUserStatus"] 	= message[3]["S"]
					message[3]["wTableID"] 		= message[3]["T"]
					message[3]["wChairID"] 		= message[3]["C"]
					message[3]["lScore"] 		= message[3]["M"]
					message[3]["cbGender"] 		= message[3]["G"]
					message[3]["wFaceID"]		= message[3]["F"]
					message[3]["cbGender"]		= message[3]["G"]

					--dump(message)
					local strData = message
					-- local len = table.getn(strData)

					local mid, sid = strData[1], strData[2]
					if mid == 8  then
						mid = 3
					end
					
					local dataBuffer = CCmd_Data:create()
					dataBuffer:setcmdinfo(mid,sid)
					dataBuffer:pushdword("")
					dataBuffer:pushdword(message[3]["dwUserID"])

					dataBuffer:pushword(message[3]["wFaceID"])
					dataBuffer:pushdword("")

					dataBuffer:pushbyte(message[3]["cbGender"])
					dataBuffer:pushbyte("")

					dataBuffer:pushword(message[3]["wTableID"])
					dataBuffer:pushword(message[3]["wChairID"])
					dataBuffer:pushbyte(message[3]["cbUserStatus"])

					dataBuffer:pushscore(message[3]["lScore"])
					dataBuffer:pushscore("")
					dataBuffer:pushscore("")

					dataBuffer:pushdword("")
					dataBuffer:pushdword("")
					dataBuffer:pushdword("")
					dataBuffer:pushdword("")
					dataBuffer:pushdword("")
					dataBuffer:pushscore("")
					dataBuffer:pushdword("")
					dataBuffer:pushdword("11")

					--push 两个word 再push一个string
					dataBuffer:pushword(32)
					dataBuffer:pushword(10)
					dataBuffer:pushstring(message[3]["szNickName"],32)
					
					if self.onScoketRyFish then
						self:onScoketRyFish(dataBuffer)
					end


					-- 牛逼 无敌 给后进入的用户两个状态
					local strData = message
					local mid, sid = strData[1], strData[2]
					if mid == 8  then
						mid = 3
					end
					if sid == 100 then
						sid = 102
					end
				
					local dataBuffer = CCmd_Data:create()
					dataBuffer:setcmdinfo(mid,sid)					
					dataBuffer:pushdword(message[3]["dwUserID"])
					dataBuffer:pushword(65535)
					dataBuffer:pushword(65535)
					dataBuffer:pushbyte(message[3]["cbUserStatus"])

					if self.onScoketRyFish then
						self:onScoketRyFish(dataBuffer)
					end

					local dataBuffer2 = CCmd_Data:create()
					dataBuffer2:setcmdinfo(mid,sid)					
					dataBuffer2:pushdword(message[3]["dwUserID"])
					dataBuffer2:pushword(message[3]["wTableID"])
					dataBuffer2:pushword(message[3]["wChairID"])
					dataBuffer2:pushbyte(message[3]["cbUserStatus"])

					if self.onScoketRyFish then
						self:onScoketRyFish(dataBuffer2)
					end


				end
				
			elseif message[2] == 110 then
				
				--模拟房间配置
				local mid = 2
				local sid = 101

				local dataBuffer = CCmd_Data:create()
				dataBuffer:setcmdinfo(mid,sid)					
				dataBuffer:pushword(60)
				dataBuffer:pushword(6)
				dataBuffer:pushword(1 )
				dataBuffer:pushdword(54263824)
				if GlobalUserItem.dwUserRight == 1 then
					dataBuffer:pushdword(536870912)
				else
					dataBuffer:pushdword(0)
				end
				dataBuffer:pushdword(0)

				if self.onScoketRyFish then
					self:onScoketRyFish(dataBuffer)
				end
				
			elseif message[2] == 112 then
				--坐下
				
				if yl.isReExit and yl.reServerID ~= 0 and  yl.reKindID ~= 0 then

					
					
					if self._viewFrame and self._viewFrame.onEnterTable then
						self._viewFrame:onEnterTable()
					end

					yl.isReExit =false

					local reUserItem= self._UserList[GlobalUserItem.dwUserID]
					
						mid = 3
						sid = 102
		
						local dataBuffer = CCmd_Data:create()
						dataBuffer:setcmdinfo(mid,sid)					
						dataBuffer:pushdword(reUserItem.dwUserID )
						dataBuffer:pushword(reUserItem.wTableID)
						dataBuffer:pushword(reUserItem.wChairID )
						dataBuffer:pushbyte(reUserItem.cbUserStatus)
	
						if self.onScoketRyFish then
							self:onScoketRyFish(dataBuffer)
						end
	
						mid = 1
						sid = 102
		
						local dataBuffer = CCmd_Data:create()
						dataBuffer:setcmdinfo(mid,sid)					
		
						if self.onScoketRyFish then
							self:onScoketRyFish(dataBuffer)
						end
					
						local reMessage = {}
						reMessage["U"] = reUserItem.dwUserID 
						reMessage["C"] = reUserItem.wChairID 
						reMessage["T"] = reUserItem.wTableID
						reMessage["S"] = reUserItem.cbUserStatus
			
						--self:onSocketUserStatus(reMessage)
						--reMessage["S"] = 5
						self:onSocketUserStatus(reMessage)

					return
				end

				local action6 = {}
				action6["wTableID"] = "0"
				action6["wChairID"]= 65535  
				action6["szTablePass"]= ""
				local pargams5 = {8,1,action6}
		   
				local action7 = cjson.encode(pargams5)
				self._webFrame:wsSendString(action7)
			elseif message[2] == 101 then	
				--更新游戏状态	
				if self._UserList ~=nil then
					if message[3]["S"] == 2 or message[3]["S"] == 5 then
						local useritem = self._UserList[message[3]["U"]]
						if(useritem == nil) then 
							
						end
						
						self:onSocketUserStatus(message[3])
					else
						if message[3]["S"] == 0 then
							print("起立状态 离开")
							if g_gameframe._CCSink ~= nil then
								g_gameframe:setCCCallSink(nil)
							end
							
							--离开房间刷新用户状态 到大厅才能发送查询消息
							local _webFrame = WebFrame:create(nil, function(result, message)
								self._roomInfo = nil
							end,true)
			
							local action2 = {}
							action2["port"]= 0   
							local pargams = {2,1,action2}
			   
							local action = cjson.encode(pargams)
							_webFrame:wsSendString(action) 
							if self._viewFrame == nil then
								print("这咋办 ")
							end
							
							self._viewFrame:onExitRoom()


							return
						end
						local strData = message
						local mid, sid = 3,102
						
						local dataBuffer = CCmd_Data:create()
						dataBuffer:setcmdinfo(mid,sid)
						dataBuffer:pushdword(message[3]["U"])
						dataBuffer:pushword(yl.INVALID_TABLE)
						dataBuffer:pushword(message[3]["C"])
						dataBuffer:pushbyte(message[3]["S"])
						--捕鱼 用户离开 自己发一个0的消息
						--2018 0722去掉 不知道当时为什么加
						local dataBuffer2 = CCmd_Data:create()
						dataBuffer2:setcmdinfo(mid,sid)
						dataBuffer2:pushdword(message[3]["U"])
						dataBuffer2:pushword(yl.INVALID_TABLE)
						dataBuffer2:pushword(message[3]["C"])
						dataBuffer2:pushbyte("0")
		
						if self.onScoketRyFish then
							self:onScoketRyFish(dataBuffer)
						end

						if self.onScoketRyFish then
							--self:onScoketRyFish(dataBuffer2)
						end
					end
					
				else
					
				end

			elseif message[2] == 102 then --更新游戏分数

				local strData = message
				local mid, sid = 3,101

				local dataBuffer = CCmd_Data:create()
				dataBuffer:setcmdinfo(mid,sid)
				dataBuffer:pushdword(message[3]["U"])
				dataBuffer:pushscore(message[3]["M"])
			
				if self.onScoketRyFish then
					self:onScoketRyFish(dataBuffer)
				end  
				
				local newitem = self._UserList[message[3]["U"]]
				if newitem~=nil then
					newitem.dwUserID 		= message[3]["U"]
					newitem.lScore   		= message[3]["M"]
	
					--自己信息
					if newitem.dwUserID == GlobalUserItem.dwUserID and self:IsAllowPlazzScoreChange() then
						print("更新金币" .. GlobalUserItem.lUserScore)
						GlobalUserItem.lUserScore = newitem.lScore
						--GlobalUserItem.dUserBeans = item.dBeans
					end
					if self._viewFrame and self._viewFrame.onEventUserScore then
						self._viewFrame:onEventUserScore(newitem)
					end
	
				end
				
			
			
			elseif message[2] == 103 then 
				
				--房间停服
				if message[3]["wOperatorValue"]== 66   then
					local scene = cc.Director:getInstance():getRunningScene()
	
					self:StandUp(1)
					
					self._viewFrame:onExitTable()
					self._viewFrame:onExitRoom(-1,nil)
					
					local _webFrame = WebFrame:create(nil, function(result, message)
						local RequestManager = appdf.req(appdf.CLIENT_SRC.."plaza.models.RequestManager")
						RequestManager.requestUserScoreInfo(nil)
	
					end,true)
				
					local action2 = {}
					action2["port"]= 0   
					local pargams = {2,1,action2}
				   
					local action = cjson.encode(pargams)
					_webFrame:wsSendString(action) 
	
					QueryDialog:create("房间暂时维护，请关注官方公告~", function(bConfirm)
	
					end, nil, QueryDialog.QUERY_SURE):addTo(scene)
		
				end

			end

		end
		return
	end

	--新捕鱼 牛逼
	if self._roomInfo.wKindID == 19 then
		if message[1] == 2 and message[2] == 100 then
			--change by zzy
			local pargams4 = {8,9}
			local action5 = cjson.encode(pargams4)
			self._webFrame:wsSendString(action5) 
		elseif message[1] == yl.MDM_GF_FRAME then --游戏状态
			if message[2] == yl.SUB_GF_GAME_STATUS then
				self._cbGameStatus = message[3]["bGameStatus"]
				self._cbAllowLookon = message[3]["bAllowLookon"]
	
				-- if self._viewFrame and self._viewFrame.onEventGameScene then

				-- 	self._viewFrame:onEventGameScene(self._cbGameStatus,message[3])
				-- 	self._viewFrame:onEventGameMessage(100,nil)

				-- end
			end
			
		elseif message[1] == 8  then
			print(message)
	
			local newstatus = {}
			newstatus.wTableID   	= message[3]["T"]
			newstatus.wChairID   	= message[3]["C"]
			newstatus.cbUserStatus	= message[3]["S"]
	
			if message[2] == 100 then
				dump(message)
				local useritem2 = self._UserList[message[3]["U"]]
				local newitem = UserItem:create()
				--记录自己桌椅号
				if message[3]["U"] ==  GlobalUserItem.dwUserID then
					self._wTableID = message[3]["T"]
					self._wChairID = message[3]["C"]
				end
				if useritem2 == nil and message[3]["T"] ~= 65535 then
				
					--虚拟信息
					newitem.szNickName 		= message[3]["A"]
					newitem.dwUserID 		= message[3]["U"]
					newitem.cbUserStatus 	= message[3]["S"]
					newitem.wTableID 		= message[3]["T"]
					newitem.wChairID 		= message[3]["C"]
					newitem.lScore   		= message[3]["M"]
					newitem.cbGender   		= message[3]["G"]
					newitem.wFaceID			= message[3]["F"]
		
					self._UserList[newitem.dwUserID] = newitem
					print("self._UserList"..newitem.dwUserID.."|"..newitem.wTableID);
					--self:onUpDataTableUser(newitem.wTableID,newitem.wChairID,newitem)
					if newitem.dwUserID == 6378 then
						print("is me 1")
					end
					
					if self._viewFrame and self._viewFrame.onEventUserEnter then
						print("GameFrameEngine onevnetuser Enter ")
						self._viewFrame:onEventUserEnter(newitem.wTableID,newitem.wChairID,newitem)
					end
					--发送查询
					self:QueryUserInfo(newstatus.wTableID,newstatus.wChairID)
				elseif useritem2~=nil then
					useritem2.wTableID 		= message[3]["T"]
					useritem2.wChairID 		= message[3]["C"]
	
					self:onUpDataTableUser(useritem2.wTableID,useritem2.wChairID,useritem2)
				end
	
				if useritem2 == nil then
					print("进来11111")
					-- 记录旧状态
					local oldstatus = {}
					oldstatus.wTableID = newitem.wTableID
					oldstatus.wChairID = newitem.wChairID
					oldstatus.cbUserStatus = newitem.cbUserStatus
					--更新信息
					newitem.cbUserStatus = newstatus.cbUserStatus
					newitem.wTableID = newstatus.wTableID
					newitem.wChairID = newstatus.wChairID
	
					if newitem.dwUserID == GlobalUserItem.dwUserID then
			
						if self._viewFrame and self._viewFrame.onEnterRoom then
							self._viewFrame:onEnterRoom()
						end
			
						if self._viewFrame and self._viewFrame.onEnterTable then
							print("进到桌子0")
							self._viewFrame:onEnterTable()
						end
					end
	
					if self._viewFrame and self._viewFrame.onEventUserStatus then
						print("进来222222")
						if newitem.dwUserID == GlobalUserItem.dwUserID then
							GlobalUserItem.lUserScore = tonumber(newitem.lScore)
						end
						self._viewFrame:onEventUserStatus(newitem,newstatus,oldstatus)
					   end
					
				end
				
				--self:onSocketUserEnter2(message[3])
			elseif message[2] == 110 then
				
				
			elseif message[2] == 112 then
	
				--if yl.isShuaShuaShuaShua == false then
					if yl.isReExit and yl.reServerID ~= 0 and  yl.reKindID ~= 0 then
						yl.isReExit = false
						return
					 end
				-- else
				-- 	yl.isShuaShuaShuaShua = false
				-- end
				
	
				local action6 = {}
				action6["wTableID"] = "0"
				action6["wChairID"]= 65535  
				action6["szTablePass"]= ""
				local pargams5 = {8,1,action6}
		   
				local action7 = cjson.encode(pargams5)
				self._webFrame:wsSendString(action7)

			elseif message[2] == 101 then		
	
				 local useritem = self._UserList[message[3]["U"]]
				if(useritem == nil) then 
					return 
				end
				self:onSocketUserStatus(message[3]);
				
			elseif message[2] == 102 then --更新游戏分数
	
				local newitem = self._UserList[message[3]["U"]]
				if newitem~=nil then
					newitem.dwUserID 		= message[3]["U"]
					newitem.lScore   		= message[3]["M"]
					local newstatus = {}
					newstatus.wTableID = newitem.wTableID
					newstatus.wChairID = newitem.wChairID
					newstatus.cbUserStatus = newitem.cbUserStatus
					local oldstatus = {}
					oldstatus.wTableID = newitem.wTableID
					oldstatus.wChairID = newitem.wChairID
					oldstatus.cbUserStatus = oldstatus.cbUserStatus
					
					if self._viewFrame and self._viewFrame.onEventUserStatus then
						self._viewFrame:onEventUserStatus(newitem,newstatus,oldstatus)
					end
					--自己信息
					if newitem.dwUserID == GlobalUserItem.dwUserID and self:IsAllowPlazzScoreChange() then
						
						GlobalUserItem.lUserScore = newitem.lScore
						print("更新金币" .. GlobalUserItem.lUserScore)
						--GlobalUserItem.dUserBeans = item.dBeans
					end
					if self._viewFrame and self._viewFrame.onEventUserScore then
						self._viewFrame:onEventUserScore(newitem)
					end
				end
				
				   
			elseif message[2] == 103 then 
				--坐下失败
				if message[3]["wOperatorValue"]== 72   then
	
					self._viewFrame:onExitTable()
					self._viewFrame:onExitRoom(-1,nil)
					
					QueryDialog:create("金币不足，不能进入房间", function(bConfirm)
						
					end, nil, QueryDialog.QUERY_SURE):addTo(self._viewFrame)
		
				end
				--房间停服
				if message[3]["wOperatorValue"]== 66   then
					local scene = cc.Director:getInstance():getRunningScene()
	
					self:StandUp(1)
					
					self._viewFrame:onExitTable()
					self._viewFrame:onExitRoom(-1,nil)
					
					local _webFrame = WebFrame:create(nil, function(result, message)
						local RequestManager = appdf.req(appdf.CLIENT_SRC.."plaza.models.RequestManager")
						RequestManager.requestUserScoreInfo(nil)
	
					end,true)
				
					local action2 = {}
					action2["port"]= 0   
					local pargams = {2,1,action2}
				   
					local action = cjson.encode(pargams)
					_webFrame:wsSendString(action) 
	
					QueryDialog:create("房间暂时维护，请关注官方公告~", function(bConfirm)
	
					end, nil, QueryDialog.QUERY_SURE):addTo(scene)
		
				end
	
				if message[3]["wOperatorValue"]== 59   then
					self._viewFrame:onExitTable()
					self._viewFrame:onExitRoom(-1,nil)
					
					QueryDialog:create("你正在桌上游戏，暂时不能离开位置！", function(bConfirm)
						
					end, nil, QueryDialog.QUERY_SURE):addTo(self._viewFrame)
				end
	
			end
		end
		return
	end

	if message[1] == 2 and message[2] == 100 then
		--change by zzy
		if message[3]["port"] == 0 and message[3]["sid"] == 0 then
			return
		end
		local pargams4 = {8,9}
        local action5 = cjson.encode(pargams4)
		self._webFrame:wsSendString(action5) 
    elseif message[1] == yl.MDM_GF_FRAME then --游戏状态
        if message[2] == yl.SUB_GF_GAME_STATUS then
		    self._cbGameStatus = message[3]["bGameStatus"]
			self._cbAllowLookon = message[3]["bAllowLookon"]

		elseif message[2] == yl.SUB_GF_GAME_SCENE and self._roomInfo.wKindID == 1040 then
			--红包扫雷特殊处理
			if self._viewFrame and self._viewFrame.onEventGameScene then
				self._viewFrame:onEventGameScene(self._cbGameStatus,message[3])
			end
		end
		
	elseif message[1] == 8  then
		print(message)

		local newstatus = {}
		newstatus.wTableID   	= message[3]["T"]
		newstatus.wChairID   	= message[3]["C"]
		newstatus.cbUserStatus	= message[3]["S"]

		if message[2] == 100 then
			dump(message)
			local useritem2 = self._UserList[message[3]["U"]]
			local newitem = UserItem:create()
			--记录自己桌椅号
			if message[3]["U"] ==  GlobalUserItem.dwUserID then
				self._wTableID = message[3]["T"]
				self._wChairID = message[3]["C"]
			end
			if useritem2 == nil and message[3]["T"] ~= 65535 then
			
				--虚拟信息
				newitem.szNickName 		= message[3]["A"]
				newitem.dwUserID 		= message[3]["U"]
				newitem.cbUserStatus 	= message[3]["S"]
				newitem.wTableID 		= message[3]["T"]
				newitem.wChairID 		= message[3]["C"]
				newitem.lScore   		= message[3]["M"]
				newitem.cbGender   		= message[3]["G"]
				newitem.wFaceID			= message[3]["F"]
	
				self._UserList[newitem.dwUserID] = newitem
                print("self._UserList"..newitem.dwUserID.."|"..newitem.wTableID);
				self:onUpDataTableUser(newitem.wTableID,newitem.wChairID,newitem)
                if self._viewFrame and self._viewFrame.onEventUserEnter then
			        self._viewFrame:onEventUserEnter(newitem.wTableID,newitem.wChairID,newitem)
		        end
				--发送查询
				self:QueryUserInfo(newstatus.wTableID,newstatus.wChairID)
            elseif useritem2~=nil then
                useritem2.wTableID 		= message[3]["T"]
				useritem2.wChairID 		= message[3]["C"]

                self:onUpDataTableUser(useritem2.wTableID,useritem2.wChairID,useritem2)
			end

			if useritem2 == nil then
				print("进来11111")
				-- 记录旧状态
				local oldstatus = {}
				oldstatus.wTableID = newitem.wTableID
				oldstatus.wChairID = newitem.wChairID
				oldstatus.cbUserStatus = newitem.cbUserStatus
				--更新信息
				newitem.cbUserStatus = newstatus.cbUserStatus
				newitem.wTableID = newstatus.wTableID
				newitem.wChairID = newstatus.wChairID

				if newitem.dwUserID == GlobalUserItem.dwUserID then
		
					if self._viewFrame and self._viewFrame.onEnterRoom then
						self._viewFrame:onEnterRoom()
					end
		
					if self._viewFrame and self._viewFrame.onEnterTable then
						print("进到桌子0")
						self._viewFrame:onEnterTable()
					end
				end

				if self._viewFrame and self._viewFrame.onEventUserStatus then
					print("进来222222")
					if newitem.dwUserID == GlobalUserItem.dwUserID then
						GlobalUserItem.lUserScore = tonumber(newitem.lScore)
					end
					
					self._viewFrame:onEventUserStatus(newitem,newstatus,oldstatus)
		   		end
			end
			
			--self:onSocketUserEnter2(message[3])
		elseif message[2] == 110 then
			--print("坐下")
			-- if self._wTableID ~= yl.INVALID_TABLE then
			-- 	if self._viewFrame and self._viewFrame.onEnterTable then
			-- 		self._viewFrame:onEnterTable()
			-- 	end
			-- end
			--斗地主红包
			if self._roomInfo.wKindID == 200 then
			
				local pargams = {3,7}
				local action = cjson.encode(pargams)
				self._webFrame:wsSendString(action)
	
			end
		elseif message[2] == 112 then

			--if yl.isShuaShuaShuaShua == false then
				if yl.isReExit and yl.reServerID ~= 0 and  yl.reKindID ~= 0 then
					yl.isReExit = false
					return
			 	end
			-- else
			-- 	yl.isShuaShuaShuaShua = false
			-- end
			
			local action6 = {}
			action6["wTableID"] = "0"
			action6["wChairID"]= 65535  
			action6["szTablePass"]= ""
			local pargams5 = {8,1,action6}
	   
			local action7 = cjson.encode(pargams5)
			self._webFrame:wsSendString(action7)
			--self:SendUserReady()
		elseif message[2] == 101 then		

		 	local useritem = self._UserList[message[3]["U"]]
            if(useritem == nil) then return end
			self:onSocketUserStatus(message[3]);
			
		elseif message[2] == 102 then --更新游戏分数

			local newitem = self._UserList[message[3]["U"]]
			if newitem~=nil then
				newitem.dwUserID 		= message[3]["U"]
				newitem.lScore   		= message[3]["M"]
				local newstatus = {}
				newstatus.wTableID = newitem.wTableID
				newstatus.wChairID = newitem.wChairID
				newstatus.cbUserStatus = newitem.cbUserStatus
				local oldstatus = {}
				oldstatus.wTableID = newitem.wTableID
				oldstatus.wChairID = newitem.wChairID
				oldstatus.cbUserStatus = oldstatus.cbUserStatus
				
				if self._viewFrame and self._viewFrame.onEventUserStatus then
					self._viewFrame:onEventUserStatus(newitem,newstatus,oldstatus)
				end
				--自己信息
				if newitem.dwUserID == GlobalUserItem.dwUserID and self:IsAllowPlazzScoreChange() then
					
					GlobalUserItem.lUserScore = newitem.lScore
					print("更新金币" .. GlobalUserItem.lUserScore)
					--GlobalUserItem.dUserBeans = item.dBeans
				end
				if self._viewFrame and self._viewFrame.onEventUserScore then
					self._viewFrame:onEventUserScore(newitem)
				end
			end
			
			   
		elseif message[2] == 103 then 
			--坐下失败
			if message[3]["wOperatorValue"]== 72   then

				self._viewFrame:onExitTable()
				self._viewFrame:onExitRoom(-1,nil)
				
				QueryDialog:create("金币不足，不能进入房间", function(bConfirm)
					
				end, nil, QueryDialog.QUERY_SURE):addTo(self._viewFrame)
	
			end
			--房间停服
			if message[3]["wOperatorValue"]== 66   then
				local scene = cc.Director:getInstance():getRunningScene()

				self:StandUp(1)
				
				self._viewFrame:onExitTable()
				self._viewFrame:onExitRoom(-1,nil)
				
				local _webFrame = WebFrame:create(nil, function(result, message)
					local RequestManager = appdf.req(appdf.CLIENT_SRC.."plaza.models.RequestManager")
    				RequestManager.requestUserScoreInfo(nil)

				end,true)
			
				local action2 = {}
				action2["port"]= 0   
				local pargams = {2,1,action2}
			   
				local action = cjson.encode(pargams)
				_webFrame:wsSendString(action) 

				QueryDialog:create("房间暂时维护，请关注官方公告~", function(bConfirm)

				end, nil, QueryDialog.QUERY_SURE):addTo(scene)
	
			end

			if message[3]["wOperatorValue"]== 59   then
				self._viewFrame:onExitTable()
				self._viewFrame:onExitRoom(-1,nil)
				
				self:StandUp(1)
				QueryDialog:create("你正在桌上游戏，暂时不能离开位置！", function(bConfirm)
					
				end, nil, QueryDialog.QUERY_SURE):addTo(cc.Director:getInstance():getRunningScene())
			end

		end
	end
	
end

--发送数据
function GameFrameEngine:sendSocketData(pData , isDntg)

	if self._webFrame == nil then
		self._callBack(-1)
		return false
	end

    --print("GameFrameEngine:sendSocketData")
    local l1 = math.floor((pData:getlen()+8)/256)
    local l2 = math.mod(pData:getlen()+8,256)
    local bindata = string.char(l2,l1,1,1)
    print("sendinfo ("..pData:getmain()..","..pData:getsub()..")"..pData:getlen().."["..l1..","..l2.."]")
	if isDntg==true then	
		if pData:getmain() == 3 and pData:getsub() ==4 then
			bindata = bindata..string.char(8,0)
			bindata = bindata..string.char(4,0)	

		end	
		if pData:getmain() == 100 then
			bindata = bindata..string.char(6,0)
			bindata = bindata..string.char(pData:getsub(),0)
		elseif pData:getmain() == 200 then
			 bindata = bindata..string.char(9,0)
			if pData:getsub() == 205 then
				bindata = bindata..string.char(65,0)
			elseif pData:getsub() == 405 then
				bindata = bindata..string.char(75,0)
			elseif pData:getsub() == 505 then
				bindata = bindata..string.char(85,0)
			elseif pData:getsub() == 506 then
				bindata = bindata..string.char(86,0)
			elseif pData:getsub() == 507 then
				bindata = bindata..string.char(87,0)
			elseif pData:getsub() == 509 then
				bindata = bindata..string.char(89,0)
			else
				bindata = bindata..string.char(pData:getsub(),0)
			end
			
		end
	else
		bindata = bindata..string.char(pData:getmain(),0)	
		bindata = bindata..string.char(pData:getsub(),0)
		
	end
    --bindata = bindata..string.char(pData:getsub(),0)
    local len = pData:getlen()
    pData:resetread()
    for i=1,len,1 do
        bindata = bindata..string.char(pData:readbyte())
    end
    self._webFrame:wsSendString(bindata);
--	local tabCache = {}
--	tabCache["main"] = pData:getmain()
--	tabCache["sub"] = pData:getsub()
--	tabCache["len"] = pData:getlen()
--	tabCache["kindid"] = GlobalUserItem.nCurGameKind
--	table.insert( self.m_tabCacheMsg, tabCache )
--	if #self.m_tabCacheMsg > 5 then
--		table.remove(self.m_tabCacheMsg, 1)
--	end
--	if not self._socket:sendData(pData) then
--		self:onSocketError("发送数据失败！")
--		return false
--	end
	return true
end

--连接结果
function GameFrameEngine:onConnectCompeleted()
	if nil ~= self._socket then
		self._socket:setdelaytime(0)
	end

	local dataBuffer = CCmd_Data:create(213)

	--初始化参数
	self:onInitData()

	dataBuffer:setcmdinfo(yl.MDM_GR_LOGON,yl.SUB_GR_LOGON_MOBILE)
	dataBuffer:pushword(self._kindID)
	dataBuffer:pushdword(self._kindVersion)
	
	dataBuffer:pushbyte(yl.DEVICE_TYPE)
	dataBuffer:pushword(0x0011)
	dataBuffer:pushword(255)

	dataBuffer:pushdword(GlobalUserItem.dwUserID)
	dataBuffer:pushstring(GlobalUserItem.szDynamicPass,33)
	dataBuffer:pushstring(GlobalUserItem.szRoomPasswd,33)
	dataBuffer:pushstring(GlobalUserItem.szMachine,33)

	if not self:sendSocketData(dataBuffer) and nil ~= self._callBack then
		self._callBack(-1,"发送登录失败！")
	end
end

--网络信息
function GameFrameEngine:onSocketEvent(main,sub,dataBuffer)

	--登录信息
	if main == yl.MDM_GR_LOGON then
		self:onSocketLogonEvent(sub,dataBuffer)
	--配置信息
	elseif main == yl.MDM_GR_CONFIG then
		self:onSocketConfigEvent(sub,dataBuffer)
	--用户信息
	elseif main == yl.MDM_GR_USER then
		self:onSocketUserEvent(sub,dataBuffer)
	--状态信息
	elseif main == yl.MDM_GR_STATUS then
		self:onSocketStatusEvent(sub,dataBuffer)
	elseif main == yl.MDM_GF_FRAME then
		self:onSocketFrameEvent(sub,dataBuffer)
	elseif main == yl.MDM_GF_GAME then
		if self._viewFrame and self._viewFrame.onEventGameMessage then
			self._viewFrame:onEventGameMessage(sub,dataBuffer)
		end
	--红包消息
	elseif main == yl.MDM_GR_REDENVEL then
		self:onSocketHBEvent(sub,dataBuffer)
	--雷炸消息
	elseif main == yl.MDM_GR_THNDER then
		self:onSocketMinesweeper(sub,dataBuffer)
    --系统消息
    elseif main == cmd_pri_game.MDM_CM_SYSTEM then
        self:onSocketSystemCommand(sub,dataBuffer)
    --私人桌信息
    elseif main == cmd_pri_game.MDM_GR_PERSONAL_TABLE then
        self:onSocketPersonalTableEvent(sub,dataBuffer)
	elseif main == game_cmd.MDM_GR_INSURE then
		if self._viewFrame and self._viewFrame.onSocketInsureEvent then
			self._viewFrame:onSocketInsureEvent(sub,dataBuffer)
		end

		-- 短连接服务
        for i = 1, #self._shotFrames do
            local shotFrame = self._shotFrames[i]
            if appdf.isObject(shotFrame) and shotFrame.onGameSocketEvent then
                shotFrame:onGameSocketEvent(main, sub, dataBuffer)
            end
        end
	--[[elseif main == game_cmd.MDM_GR_TASK 
		or main == game_cmd.MDM_GR_PROPERTY 
		then
		-- 短连接服务
		if nil ~= self._shotFrame and nil ~= self._shotFrame.onGameSocketEvent then
			self._shotFrame:onGameSocketEvent(main,sub,dataBuffer)
		end]]
	elseif main == 777 then
		self:onOffLine(sub)
	else
		-- 短连接服务
        for i = 1, #self._shotFrames do
            local shotFrame = self._shotFrames[i]
            if appdf.isObject(shotFrame) and shotFrame.onGameSocketEvent then
                shotFrame:onGameSocketEvent(main, sub, dataBuffer)
            end
        end
	end
end


function GameFrameEngine:onOffLine( sub )
	if sub == 31 then
		if self._viewFrame then
			local scene = cc.Director:getInstance():getRunningScene()
			QueryDialog:create("您的帐号已被冻结，请联系客服！", function(bConfirm)
				yl.isTT = false
				GlobalUserItem.bWaitQuit = false            
				self._viewFrame:onExitTable(3)
			end, nil, QueryDialog.QUERY_SURE):addTo(scene)
		end
	elseif sub == 32 then

	end
end

function GameFrameEngine:onSocketMinesweeper(sub,dataBuffer)
	
	if sub == yl.SUB_GR_USER_THNDER then
		local eventListener = cc.EventCustom:new("ry_GetMineIdent")
		eventListener._usedata = {["Mine_suc"] = dataBuffer}
		cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
	elseif sub == yl.SUB_GR_USER_DISMANTLING then
        local eventListener = cc.EventCustom:new("snedry_GetMineIdent")
		eventListener._usedata = {["Mine_suc"] = dataBuffer}
		cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
    elseif sub == yl.SUB_GR_USER_REDDATA then
        local eventListener = cc.EventCustom:new("detailed_GetMineIdent")
		eventListener._usedata = {["Mine_suc"] = dataBuffer}
		cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
	end
end

function GameFrameEngine:onSocketHBEvent(sub,dataBuffer)
	--房间配置
	if sub == yl.SUB_GR_GAME_RED_ENVELOPESD then
		self:onSocketHBAward(dataBuffer)
	end
end

function GameFrameEngine:onSocketLogonEvent(sub,dataBuffer)
	--登录完成
	if sub == game_cmd.SUB_GR_LOGON_FINISH then	
		self:onSocketLogonFinish()
	-- 登录成功
	elseif sub == game_cmd.SUB_GR_LOGON_SUCCESS then
		local cmd_table = ExternalFun.read_netdata(game_cmd.CMD_GR_LogonSuccess, dataBuffer)
		dump(cmd_table, "CMD_GR_LogonSuccess", 4)
	--登录失败
	elseif sub == game_cmd.SUB_GR_LOGON_FAILURE then	
		local errorCode = dataBuffer:readint()
		local msg = dataBuffer:readstring()
		print("登录房间失败:"..errorCode.."#"..msg)
		self:onCloseSocket()
		if nil ~= self._callBack then
			self._callBack(-1,"登录房间失败:"..errorCode.."#\n"..msg)
		end		
	--升级提示
	elseif sub == game_cmd.SUB_GR_UPDATE_NOTIFY then
		if nil ~= self._callBack then
			self._callBack(-1,"版本信息错误")
		end		
	end
end

--登录完成
function GameFrameEngine:onSocketLogonFinish()
--	if self._delayEnter == true then
--		return
--	end	
	print("登录完成")
	local myUserItem   =  self:GetMeUserItem()
	if not myUserItem and nil ~= self._callBack then
		self._callBack(-1,"获取自己信息失败！")
		return
	end
	if GlobalUserItem.bPrivateRoom and PriRoom then		
		PriRoom:getInstance():onLoginPriRoomFinish()
	else
		if self._wTableID ~= yl.INVALID_TABLE then
			if self._viewFrame and self._viewFrame.onEnterTable then
				self._viewFrame:onEnterTable()
				--showToast(self._viewFrame,"找到游戏桌子，正在获取场景中...",1)
			end
			--self:SendGameOption()
		else
			if self._viewFrame and self._viewFrame.onEnterRoom then
				self._viewFrame:onEnterRoom()
			end
		end
	end
end

--房间配置
function GameFrameEngine:onSocketConfigEvent(sub,dataBuffer)
	--房间配置
	if sub == yl.SUB_GR_CONFIG_SERVER then
		self._wTableCount  		= dataBuffer:readword()
		self._wChairCount  		= dataBuffer:readword()
		self._wServerType  		= dataBuffer:readword()
		self._dwServerRule 		= dataBuffer:readdword()
		GlobalUserItem.dwServerRule = self._dwServerRule
		local dwUserRight 		= dataBuffer:readdword()
		local dwMasterRight		= dataBuffer:readdword()
		yl.GAME_CURNUMBER		= dataBuffer:readword()
		yl.GAME_TARNUMBER		= dataBuffer:readword()
		if yl.GAME_CURNUMBER == nil  then
			yl.GAME_CURNUMBER   = 0
		end
		if yl.GAME_TARNUMBER == nil then
			yl.GAME_TARNUMBER   = 0
		end
		yl.GAME_BOOSNUMBER = yl.GAME_TARNUMBER
		--print("红包 WINCOUNT " .. yl.GAME_CURNUMBER .. "targetnnumber : " .. yl.GAME_TARNUMBER)
		--是否进入防作弊
		self:setEnterAntiCheatRoom(GlobalUserItem.isAntiCheat())
		--print("房间配置[table:"..self._wTableCount.."][chair:"..self._wChairCount.."][type:"..self._wServerType.."][rule:"..self._dwServerRule.."]")
	--配置完成
	elseif sub == yl.SUB_GR_CONFIG_FINISH then

	end
end

function GameFrameEngine:GetTableCount()
	return self._wTableCount
end

function GameFrameEngine:GetChairCount()
	return self._wChairCount
end

function GameFrameEngine:GetServerType()
	return self._wServerType
end

function GameFrameEngine:GetServerRule()
	return self._dwServerRule
end

--房间取款准许
function GameFrameEngine:OnRoomAllowBankTake()
	return bit:_and(self._dwServerRule,0x00010000) ~= 0
end

--房间存款准许
function GameFrameEngine:OnRoomAllowBankSave()
	return bit:_and(self._dwServerRule,0x00040000) ~= 0
end

--游戏取款准许
function GameFrameEngine:OnGameAllowBankTake()
	return bit:_and(self._dwServerRule,0x00020000) ~= 0
end

--游戏存款准许
function GameFrameEngine:OnGameAllowBankSave()
	return bit:_and(self._dwServerRule,0x00080000) ~= 0
end

function GameFrameEngine:IsAllowAvertCheatMode( )
	return bit:_and(self._dwServerRule, yl.SR_ALLOW_AVERT_CHEAT_MODE) ~= 0
end

--是否更新大厅金币
function GameFrameEngine:IsAllowPlazzScoreChange()
	return (self._wServerType ~= yl.GAME_GENRE_SCORE) and (self._wServerType ~= yl.GAME_GENRE_EDUCATE)
end

--游戏赠送准许
function GameFrameEngine:OnGameAllowBankTransfer()
	return false
end

--用户信息
function GameFrameEngine:onSocketUserEvent(sub,dataBuffer)
	--等待分配
	if sub == game_cmd.SUB_GR_USER_WAIT_DISTRIBUTE then
		--showToast(self._viewFrame, "正在进行分组,请稍后...", 3)
		--print("正在进行分组,请稍后...")
	--用户进入
	elseif sub == yl.SUB_GR_USER_ENTER then
		self:onSocketUserEnter(dataBuffer)
	--用户积分
	elseif sub == yl.SUB_GR_USER_SCORE then
		self:onSocketUserScore(dataBuffer)
	--用户状态
	elseif sub == yl.SUB_GR_USER_STATUS then
		self:onSocketUserStatus(dataBuffer)
	--请求失败
	elseif sub == yl.SUB_GR_REQUEST_FAILURE then	
		self:onSocketRequestFailure(dataBuffer)
	end
end

--领取红包
function GameFrameEngine:onSocketHBAward( dataBuffer )
	
	local eventListener = cc.EventCustom:new("ry_GetHbAward")
	eventListener._usedata = {["HbAward_count"] = dataBuffer:readdouble(),["HbAward_Num"] = dataBuffer:readdouble()}
	--print("get AWard : " .. eventListener._usedata["HbAward_count"] .. "num : " ..  eventListener._usedata["HbAward_Num"])
	cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
	

	-- self.m_resizeListener = cc.EventListenerCustom:create("ry_GetHbAward",eventReSizeListener)
	--local function eventReSizeListener(event)
	-- self:getEventDispatcher():addEventListenerWithFixedPriority(self.m_resizeListener, 1)

	--yl.GAME_HBAWARD_COUNT  = dataBuffer:readdword()
end

--用户进入
function GameFrameEngine:onSocketUserEnter(dataBuffer)
	local userItem = UserItem:create()

	userItem.dwGameID		= dataBuffer:readdword()
	userItem.dwUserID		= dataBuffer:readdword()

	--自己判断
	local bMySelfInfo = (userItem.dwUserID == GlobalUserItem.dwUserID)

	--非法过滤
	if not self._UserList[GlobalUserItem.dwUserID]  then
		if	bMySelfInfo == false then
			print("还未有自己信息，不处理其他用户信息")
			return
		end
	else 
		if bMySelfInfo == true then
			print("已有自己信息，不再次处理自己信息")
			return
		end
	end

	local int64 = Integer64.new()

	--读取信息
	userItem.wFaceID 		= dataBuffer:readword()
	userItem.dwCustomID		= dataBuffer:readdword()

	userItem.cbGender		= dataBuffer:readbyte()
	userItem.cbMemberOrder	= dataBuffer:readbyte()

	userItem.wTableID		= dataBuffer:readword()
	userItem.wChairID		= dataBuffer:readword()
	userItem.cbUserStatus 	= dataBuffer:readbyte()

	userItem.lScore			= dataBuffer:readscore(int64):getvalue()
	userItem.lIngot			= dataBuffer:readscore(int64):getvalue()
	userItem.dBeans			= dataBuffer:readdouble()

	userItem.dwWinCount		= dataBuffer:readdword()
	userItem.dwLostCount	= dataBuffer:readdword()
	userItem.dwDrawCount	= dataBuffer:readdword()
	userItem.dwFleeCount	= dataBuffer:readdword()
	userItem.dwExperience	= dataBuffer:readdword()
	userItem.lIntegralCount = dataBuffer:readscore(int64):getvalue()
	userItem.dwAgentID		= dataBuffer:readdword()
	userItem.dwIpAddress 	= dataBuffer:readdword() -- ip地址	
	userItem.dwDistance	    = nil 					 -- 距离

	local curlen = dataBuffer:getcurlen()
	local datalen = dataBuffer:getlen()
	local tmpSize 
	local tmpCmd
	while curlen<datalen do
		tmpSize = dataBuffer:readword()
		tmpCmd = dataBuffer:readword()
		if not tmpSize or not tmpCmd then
		 	break
		end
		if tmpCmd == yl.DTP_GR_NICK_NAME then
			userItem.szNickName 	= dataBuffer:readstring(tmpSize/2)

			-- if not userItem.szNickName or (self:IsAllowAvertCheatMode() == true and userItem.dwUserID ~=  GlobalUserItem.dwUserID) then
			-- 	userItem.szNickName = "游戏玩家"
			-- end
		elseif tmpCmd == yl.DTP_GR_UNDER_WRITE then
			userItem.szUnderWrite = dataBuffer:readstring(tmpSize/2)
			if not userItem.szUnderWrite or (self:IsAllowAvertCheatMode() == true and userItem.dwUserID ~=  GlobalUserItem.dwUserID) then
				userItem.szUnderWrite = "这个家伙很懒，什么都没留下"
			end
		elseif tmpCmd == 15 then
			userItem.szThirdPartyUrl = dataBuffer:readstring(tmpSize / 2)
			print(userItem.szThirdPartyUrl)
		elseif tmpCmd == 0 then
			break
		else
			for i = 1, tmpSize do
				if not dataBuffer:readbyte() then
					break
				end
			end
		end
		curlen = dataBuffer:getcurlen()
	end
	print("GameFrameEngine enter ==> ", userItem.szNickName, userItem.dwIpAddress, userItem.dwDistance)

	-- userItem:testlog()

	--添加/更新到缓存
	local bAdded
	local item = self._UserList[userItem.dwUserID] 
	if item ~= nil then
		item.dwGameID		= userItem.dwGameID
		item.lScore			= userItem.lScore	
		item.lIngot			= userItem.lIngot	
		item.dBeans			= userItem.dBeans	
		item.wFaceID 		= userItem.wFaceID
		item.dwCustomID		= userItem.dwCustomID
		item.cbGender		= userItem.cbGender
		item.cbMemberOrder	= userItem.cbMemberOrder
		item.wTableID		= userItem.wTableID
		item.wChairID		= userItem.wChairID
		item.cbUserStatus 	= userItem.cbUserStatus
		item.dwWinCount 	= userItem.dwWinCount
		item.dwLostCount 	= userItem.dwLostCount
		item.dwDrawCount 	= userItem.dwDrawCount
		item.dwFleeCount 	= userItem.dwFleeCount
		item.dwExperience 	= userItem.dwExperience
		item.szNickName     = userItem.szNickName
		bAdded = true
	end

	if not bAdded then
		self._UserList[userItem.dwUserID] = userItem
	end

	--记录自己桌椅号
	if userItem.dwUserID ==  GlobalUserItem.dwUserID then
		self._wTableID = userItem.wTableID
		self._wChairID = userItem.wChairID
	end
	if userItem.wTableID ~= yl.INVALID_TABLE  and userItem.cbUserStatus ~= yl.US_LOOKON then
		self:onUpDataTableUser(userItem.wTableID,userItem.wChairID,userItem)
		if self._viewFrame and self._viewFrame.onEventUserEnter then
			self._viewFrame:onEventUserEnter(userItem.wTableID,userItem.wChairID,userItem)
		end
	end

	if bMySelfInfo == true and self._delayEnter == true then
		self._delayEnter = false
		self:onSocketLogonFinish()
	end

end

function GameFrameEngine:onScoketRyFish( pdata )
	-- dump(self._roomInfo)
	-- if yl.IsCCGame(self._roomInfo.wKindID) then
		if g_gameframe._CCSink ~= nil then
			--dump(pdata)
			g_gameframe._CCSink:onSocketCallBack(pdata)
		end
	--end
end

--用户积分
function GameFrameEngine:onSocketUserScore(dataBuffer)
	
	local dwUserID = dataBuffer:readdword()

	local int64 = Integer64.new()
	local item = self._UserList[dwUserID]
	if  item ~= nil then
		--更新数据
		item.lScore = dataBuffer:readscore(int64):getvalue()
		item.dBeans =  dataBuffer:readdouble()

		item.dwWinCount = dataBuffer:readdword()
		item.dwLostCount = dataBuffer:readdword()
		item.dwDrawCount = dataBuffer:readdword()
		item.dwFleeCount = dataBuffer:readdword()

		item.dwExperience = dataBuffer:readdword()

		print("更新用户["..dwUserID.."]["..item.szNickName.."]["..item.lScore.."]")
		
		--自己信息
		if item.dwUserID == GlobalUserItem.dwUserID and self:IsAllowPlazzScoreChange() then
			print("更新金币")
			--不从这里读红包 坑
			GlobalUserItem.lUserScore = item.lScore
			--GlobalUserItem.dUserBeans = item.dBeans
		end

		--通知更新界面
		if self._wTableID ~= yl.INVALID_TABLE and self._viewFrame and self._viewFrame.onEventUserScore  then
			self._viewFrame:onEventUserScore(item)
		end
	end  
end

--用户状态
function GameFrameEngine:onSocketUserStatus(dataBuffer)

	--读取信息
--	local dwUserID 		= dataBuffer:readdword()
	local dwUserID 		= dataBuffer["U"] 
	local newstatus = {}
--	newstatus.wTableID   	= dataBuffer:readword()
--	newstatus.wChairID   	= dataBuffer:readword()
--	newstatus.cbUserStatus	= dataBuffer:readbyte()
    newstatus.wTableID      = yl.INVALID_TABLE
	newstatus.wChairID   	= dataBuffer["C"]
	newstatus.cbUserStatus	= dataBuffer["S"]

	--过滤观看
	if newstatus.cbUserStatus == yl.US_LOOKON then
		return
	end

	--获取自己
	local myUserItem  =  self:GetMeUserItem()

	--未找到自己 (2017.7.9)
    if not myUserItem then
        return
    end
	if not myUserItem then

		if newstatus.wTableID ~= yl.INVALID_TABLE then
			self._delayEnter = true
			self:QueryUserInfo(newstatus.wTableID,newstatus.wChairID)
			return
		end

		--非法信息
		self:onCloseSocket()
		if nil ~= self._callBack then
			self._callBack(-1,"用户信息获取不正确,请重新登录！")
		end		
		return
	end	

	--自己判断
	local bMySelfInfo = (dwUserID == myUserItem.dwUserID)
	
	local useritem = self._UserList[dwUserID]

	--找不到用户
	if useritem == nil then
		--当前桌子用户
		if newstatus.wTableID ~= yl.INVALID_TABLE then
			--虚拟信息
			local newitem = UserItem:create()
			newitem.szNickName = "游戏玩家"
			newitem.dwUserID = dwUserID
			newitem.cbUserStatus = cbUserStatus
			newitem.wTableID = newstatus.wTableID
			newitem.wChairID = newstatus.wChairID

			self._UserList[dwUserID] = newitem
			self:onUpDataTableUser(newitem.wTableID,newitem.wChairID,newitem)
			--发送查询
			self:QueryUserInfo(newstatus.wTableID,newstatus.wChairID)
		end
		return
    else
        newstatus.wTableID = useritem.wTableID
	end

	-- 记录旧状态
	local oldstatus = {}
	oldstatus.wTableID = useritem.wTableID
	oldstatus.wChairID = useritem.wChairID
	oldstatus.cbUserStatus = useritem.cbUserStatus
	--更新信息
	useritem.cbUserStatus = newstatus.cbUserStatus
	useritem.wTableID = newstatus.wTableID
	useritem.wChairID = newstatus.wChairID

	--清除旧桌子椅子记录
	if oldstatus.wTableID ~= yl.INVALID_TABLE then
		--新旧桌子不同 新旧椅子不同
		if (oldstatus.wTableID ~= newstatus.wTableID) or (oldstatus.wChairID ~= newstatus.wChairID) then
			self:onUpDataTableUser(oldstatus.wTableID, oldstatus.wChairID, nil)
		end
	end
	--新桌子记录
	if newstatus.wTableID ~= yl.INVALID_TABLE then
		self:onUpDataTableUser(newstatus.wTableID, newstatus.wChairID, useritem)
	end

	--自己状态
	if  bMySelfInfo == true then

		self._wTableID = newstatus.wTableID
		self._wChairID = newstatus.wChairID
		--离开
		if newstatus.cbUserStatus == yl.US_NULL then
			print("自己离开")
			if self._viewFrame and self._viewFrame.onExitRoom and not GlobalUserItem.bWaitQuit then
              if yl.IsCCGame(self._roomInfo.wKindID) then
                 if g_gameframe._CCSink ~= nil then
                     g_gameframe:setCCCallSink(nil)
                  end
			  end
				--self._viewFrame:onExitRoom()

				--离开房间刷新用户状态 到大厅才能发送查询消息
				local _webFrame = WebFrame:create(nil, function(result, message)
					--print(" 收到2,1" )
					self._roomInfo = nil
				end,true)
			
				local action2 = {}
				action2["port"]= 0   
				local pargams = {2,1,action2}
			   
				local action = cjson.encode(pargams)
				_webFrame:wsSendString(action) 
			end
		--起立
		elseif newstatus.cbUserStatus == yl.US_FREE and oldstatus.cbUserStatus > yl.US_FREE then
			print("自己起立")
			if yl.IsCCGame(self._roomInfo.wKindID) then
				if g_gameframe._CCSink ~= nil then
					g_gameframe:setCCCallSink(nil)
				end
				self._viewFrame:onExitRoom()
			else
				if self._viewFrame and self._viewFrame.onExitTable and not GlobalUserItem.bWaitQuit then

					if  yl.isOuted == true then
						yl.isOuted = false

						if self._roomInfo.wKindID == 2099 or self._roomInfo.wKindID == 2075 
							or self._roomInfo.wKindID == 2068 or self._roomInfo.wKindID == 516
							or self._roomInfo.wKindID == 34 then

								if self._roomInfo.wKindID == 34 then
									if self._viewFrame and self._viewFrame.onEventUserStatus then
										self._viewFrame:onEventUserStatus(useritem,newstatus,oldstatus)
									end
								end
							return
						end
						

						self:StandUp(1) 					
						
						-- QueryDialog:create("金币不足，请到商城购买金币", function(bConfirm)
						-- 	self._viewFrame:onExitTable()
						-- end, nil, QueryDialog.QUERY_SURE):addTo(cc.Director:getInstance():getRunningScene())

						local scene = cc.Director:getInstance():getRunningScene()
						--创建遮罩
						local mask = ccui.Layout:create()
						mask:setContentSize(cc.Director:getInstance():getVisibleSize())
						mask:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
						mask:setBackGroundColor(cc.BLACK)
						mask:setBackGroundColorOpacity(153)
						mask:setTouchEnabled(true)
						mask:addTo(scene)
						mask:setOpacity(0)
						mask:runAction(cc.EaseSineOut:create(cc.FadeIn:create(0.4)))
						
						--背景
						local _content = display.newSprite("query_bg.png")
						:move(appdf.WIDTH / 2, appdf.HEIGHT / 2)
						:addTo(mask)
						local contentSize = _content:getContentSize()
						
						cc.Label:createWithTTF("金币不足，请到商城购买金币", "fonts/round_body.ttf", 32)
						:setTextColor(cc.c4b(255, 255, 255, 255))
						:setAnchorPoint(cc.p(0.5, 0.5))
						:setDimensions(640, 180)
						:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
						:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
						:move(contentSize.width / 2, 210)
						:addTo(_content)
						
						ccui.Button:create("bt_query_confirm_0.png", "")
						:move(contentSize.width / 2, 80)
						:addTo(_content)
						:addClickEventListener(function()
							GlobalUserItem.bWaitQuit = false            
							self._viewFrame:onExitTable()
							mask:removeFromParent()
						end)
						_content:setScale(0.85)

					elseif self.bEnterAntiCheatRoom then
						print("防作弊换桌")
						self.isSendGameOption = true
						self:OnResetGameEngine()
					elseif not self.bChangeDesk then
						self._viewFrame:onExitTable()
					else
						self.bChangeDesk = false
						self:OnResetGameEngine()
					end

					
					
				end
				--2017.5.29添加
				if self._viewFrame and self._viewFrame.onEventUserStatus then
					self._viewFrame:onEventUserStatus(useritem,newstatus,oldstatus)
				end
			end
		--坐下
		elseif newstatus.cbUserStatus >yl.US_FREE and oldstatus.cbUserStatus <yl.US_SIT then
			print("自己坐下")
			self.bChangeDesk = false
			if self._viewFrame and self._viewFrame.onEnterTable then
				self._viewFrame:onEnterTable()
			end
			--showToast(self._viewFrame,"找到游戏桌子，正在获取场景中...",1)
			--防作弊且是斗地主的时候  第二局开始的时候 发送场景规则获取场景信息 （第一次进入不能发， 第二次发）
			if self._roomInfo.wKindID == tonumber(200) and self.bEnterAntiCheatRoom == true	and self.isSendGameOption == true then
				self:SendGameOption()
			end
			
			if self._viewFrame and self._viewFrame.onEventUserStatus then
			 	self._viewFrame:onEventUserStatus(useritem,newstatus,oldstatus)
			end
		elseif newstatus.wTableID ~= yl.INVALID_TABLE and self.bChangeDesk == true then
			print("换位")
			if self._viewFrame and self._viewFrame.onEnterTable then
				self._viewFrame:onEnterTable()
			end
			--showToast(self._viewFrame,"找到游戏桌子，正在获取场景中...",1)
			self:SendGameOption()
			if self._viewFrame and self._viewFrame.onEventUserStatus then
				self._viewFrame:onEventUserStatus(useritem,newstatus,oldstatus)
			end
		else 
			print("自己新状态:"..newstatus.cbUserStatus)
			if self._viewFrame and self._viewFrame.onEventUserStatus then
				self._viewFrame:onEventUserStatus(useritem,newstatus,oldstatus)
			end
		end 
	--他人状态
	else
		--更新用户
		if oldstatus.wTableID ~= yl.INVALID_TABLE or newstatus.wTableID ~= yl.INVALID_TABLE then
			if self._viewFrame and self._viewFrame.onEventUserStatus then
				self._viewFrame:onEventUserStatus(useritem,newstatus,oldstatus)
			end
        else
            print("没更新")
		end
		--删除用户
		if newstatus.cbUserStatus == yl.US_NULL then
			self:onRemoveUser(dwUserID)
		end
		--新捕鱼
		if self._roomInfo.wKindID == 19 and newstatus.cbUserStatus == 1 then
			self:onRemoveUser(dwUserID)
		end
		
		if self._roomInfo.wKindID == 14 and newstatus.cbUserStatus == 1 then
			self:onRemoveUser(dwUserID)
		end
		if self._roomInfo.wKindID == 20 and newstatus.cbUserStatus == 1 then
			self:onRemoveUser(dwUserID)
		end
		if self._roomInfo.wKindID == 21 and newstatus.cbUserStatus == 1 then
			self:onRemoveUser(dwUserID)
		end
		if self._roomInfo.wKindID == 22 and newstatus.cbUserStatus == 1 then
			self:onRemoveUser(dwUserID)
		end
	end
end

--请求失败
function GameFrameEngine:onSocketRequestFailure(dataBuffer)
	local cmdtable = ExternalFun.read_netdata(game_cmd.CMD_GR_RequestFailure, dataBuffer)

	if  self._viewFrame and self._viewFrame.onRequestFailure then
		self._viewFrame:onRequestFailure(cmdtable.lErrorCode,cmdtable.szDescribeString)
 	else
 		print("not viewframe or not onRequestFailure")
	end
	
	if self.bChangeDesk == true  then
		self.bChangeDesk = false
		if  self._viewFrame and self._viewFrame.onExitTable and not GlobalUserItem.bWaitQuit then
			self._viewFrame:onExitTable()
		end
	end
	-- 清理锁表
	GlobalUserItem.dwLockServerID = 0
	GlobalUserItem.dwLockKindID = 0
end

--状态信息
function GameFrameEngine:onSocketStatusEvent(sub,dataBuffer)
	if sub == yl.SUB_GR_TABLE_INFO then
		print("SUB_GR_TABLE_INFO")
		local wTableCount = dataBuffer:readword()
		for i = 1, wTableCount do
			self._tableStatus[i] ={}
			self._tableStatus[i].cbTableLock = dataBuffer:readbyte()					
			self._tableStatus[i].cbPlayStatus = dataBuffer:readbyte()
			self._tableStatus[i].lCellScore = dataBuffer:readint()
		end
		if self._viewFrame and self._viewFrame.onGetTableInfo then
			self._viewFrame:onGetTableInfo()
		end
	elseif sub == yl.SUB_GR_TABLE_STATUS then	--桌子状态		
		local wTableID = dataBuffer:readword() + 1	
		self._tableStatus[wTableID] ={}
		self._tableStatus[wTableID].cbTableLock = dataBuffer:readbyte()					
		self._tableStatus[wTableID].cbPlayStatus = dataBuffer:readbyte()
		self._tableStatus[wTableID].lCellScore = dataBuffer:readint()

		--print("SUB_GR_TABLE_STATUS ==> " .. wTableID--[[ .. " ==> " .. self._tableStatus[wTableID].cbPlayStatus]])
		if self._viewFrame and self._viewFrame.onEventTableStatus then
			self._viewFrame:onEventTableStatus(wTableID-1, self._tableStatus[wTableID].cbPlayStatus)
		end
	end
end

--框架信息
function GameFrameEngine:onSocketFrameEvent(sub,dataBuffer)
	--游戏状态
	if sub == yl.SUB_GF_GAME_STATUS then
		self._cbGameStatus = dataBuffer:readword()
		self._cbAllowLookon = dataBuffer:readword()
	--游戏场景
	elseif sub == yl.SUB_GF_GAME_SCENE then
		print("lail")
		if self._viewFrame and self._viewFrame.onEventGameScene then
			print("场景进来")
			self._viewFrame:onEventGameScene(self._cbGameStatus,dataBuffer)
		else
			print("game scene did not respon")
			if not self._viewFrame then
				print ("viewframe is nl")
			else
				print("onEventGameScene is ni viewframe is"..self._viewFrame:getTag())
			end
		end
	--系统消息
	elseif sub == yl.SUB_GF_SYSTEM_MESSAGE then
		self:onSocketSystemMessage(dataBuffer)
	--动作消息
	elseif sub == yl.SUB_GF_ACTION_MESSAGE then
		self:onSocketActionMessage(dataBuffer)
	--用户聊天
	elseif sub == game_cmd.SUB_GF_USER_CHAT then
		
		local chat = ExternalFun.read_netdata(game_cmd.CMD_GF_S_UserChat, dataBuffer)
		--local chat =dataBuffer
		dump(chat)
		--获取玩家昵称
		local useritem = self._UserList[chat.dwSendUserID]
		if not  useritem then
			return
		end
		if self._wTableID == yl.INVALID_CHAIR or self._wTableID ~= useritem.wTableID then
			return
		end

		chat.szNick = useritem.szNickName

		GameChatLayer.addChatRecordWith(chat)

		if nil ~= self._viewFrame and nil ~= self._viewFrame.onUserChat then
			-- 播放声音
			local idx = GameChatLayer.compareWithText(chat.szChatString)
			if nil ~= idx then
				local sound_path = "sound/" .. useritem.cbGender .. "_" .. idx .. ".wav"
				if GlobalUserItem.bSoundAble then
					AudioEngine.playEffect(cc.FileUtils:getInstance():fullPathForFilename(sound_path),false)
				end
			end
			self._viewFrame:onUserChat(chat,useritem.wChairID)
		end
	--用户表情
	elseif sub == 121 then
		local expression = ExternalFun.read_netdata(game_cmd.CMD_GF_S_UserExpression, dataBuffer)
		--获取玩家昵称
		local useritem = self._UserList[expression.dwSendUserID]

		if not  useritem then
			return
		end
		if self._wTableID == yl.INVALID_CHAIR or self._wTableID ~= useritem.wTableID then
			return
		end
		
		expression.szNick = useritem.szNickName

		GameChatLayer.addChatRecordWith(expression, true)
		if nil ~= self._viewFrame and nil ~= self._viewFrame.onUserExpression then
			self._viewFrame:onUserExpression(expression,useritem.wChairID)
		end
	-- 用户语音
	elseif sub == game_cmd.SUB_GF_USER_VOICE then
		AudioRecorder:getInstance():saveRecordFile(dataBuffer, function(uid, tid, spath)
			local msgTab = {}
			msgTab.uid = uid
			msgTab.tid = tid
			msgTab.spath = spath
			table.insert(self._tabVoiceMsgQueue, msgTab)
			
			self:popVocieMsg()
        end)
	end
end

--系统命令
function GameFrameEngine:onSocketSystemCommand(dataBuffer)

	local wType = dataBuffer:readword()
	local wLength = dataBuffer:readword()
	local szString = dataBuffer:readstring()

    print("系统命令#"..wType.."#"..szString)

    QueryDialog:create(szString, function(bConfirm)
        end, nil, QueryDialog.QUERY_SURE):addTo(self._viewFrame)
end

--系统消息
function GameFrameEngine:onSocketSystemMessage(dataBuffer)
	local wType = dataBuffer:readword()
	local wLength = dataBuffer:readword()
	local szString = dataBuffer:readstring()
	print("系统消息#"..wType.."#"..szString)
	local bCloseRoom = bit:_and(wType,yl.SMT_CLOSE_ROOM)
	local bCloseGame = bit:_and(wType,yl.SMT_CLOSE_GAME)
	local bCloseLink = bit:_and(wType,yl.SMT_CLOSE_LINK)
	
	if self._viewFrame and self._viewFrame.onSubSystemMessage then
		self._viewFrame:onSubSystemMessage(wType,szString)
	end
--	if self._viewFrame then
--        if string.find(szString, "欢迎") == nil then
--		    showToast(nil,szString,2)
--        end
--	end
	if bCloseRoom ~= 0 or bCloseGame ~= 0 or bCloseLink ~=0 then
    --pw修改 防止退出游戏 用户手动离开
        
        --设置为等待退出，避免在用户状态改变时被强退，导致用户被剔除前看不到本轮游戏数据
        GlobalUserItem.bWaitQuit = true

       -- showToast(nil, szString, 5)

        local sequence = cc.Sequence:create(
            cc.DelayTime:create(1),
            cc.CallFunc:create(function()

                GlobalUserItem.bWaitQuit = false

                self:setEnterAntiCheatRoom(false)
		        if self._viewFrame and self._viewFrame.onExitRoom then
			        self._viewFrame:onExitRoom(wType, szString)
		        else
			        self:onCloseSocket()
		        end
            end)
        )

        cc.Director:getInstance():getRunningScene():runAction(sequence)

--        QueryDialog:create(szString, function(bConfirm)


--        end, nil, QueryDialog.QUERY_SURE):addTo(cc.Director:getInstance():getRunningScene())
	end
end

--系统动作
function GameFrameEngine:onSocketActionMessage(dataBuffer)
	local wType = dataBuffer:readword()
	local wLength = dataBuffer:readword()
	local nButtonType = dataBuffer:readint()
	local szString = dataBuffer:readstring()
	print("系统动作#"..wType.."#"..szString)
		
	local bCloseRoom = bit:_and(wType,yl.SMT_CLOSE_ROOM)
	local bCloseGame = bit:_and(wType,yl.SMT_CLOSE_GAME)
	local bCloseLink = bit:_and(wType,yl.SMT_CLOSE_LINK)

--	if self._viewFrame then
--        if string.find(szString, "欢迎") == nil then
--		    showToast(nil,szString,2)
--        end
--	end
	if bCloseRoom ~= 0 or bCloseGame ~= 0 or bCloseLink ~=0 then

        --设置为等待退出，避免在用户状态改变时被强退，导致用户被剔除前看不到本轮游戏数据
        GlobalUserItem.bWaitQuit = true

        showToast(nil, szString, 5)

        local sequence = cc.Sequence:create(
            cc.DelayTime:create(30),
            cc.CallFunc:create(function()

                GlobalUserItem.bWaitQuit = false

                self:setEnterAntiCheatRoom(false)
		        if self._viewFrame and self._viewFrame.onExitRoom then
			        self._viewFrame:onExitRoom(wType, szString)
		        else
			        self:onCloseSocket()
		        end
            end)
        )

        cc.Director:getInstance():getRunningScene():runAction(sequence)

--        QueryDialog:create(szString, function(bConfirm)


--        end, nil, QueryDialog.QUERY_SURE):addTo(cc.Director:getInstance():getRunningScene())
	end
end

----------------------------------------------------------------------------------------------------------
--私人桌信息

function GameFrameEngine:onSocketPersonalTableEvent(sub,pData)

    if cmd_pri_game.SUB_GR_CREATE_SUCCESS == sub then               -- 创建成功
        self:onSubCreateSuccess(pData)
    elseif cmd_pri_game.SUB_GR_CREATE_FAILURE == sub then           -- 创建失败
        self:onSubCreateFailure(pData)
    elseif cmd_pri_game.SUB_GR_CANCEL_TABLE == sub then             -- 解散桌子
        self:onSubTableCancel(pData)
    elseif cmd_pri_game.SUB_GR_CANCEL_REQUEST == sub then           -- 请求解散
        self:onSubCancelRequest(pData)
    elseif cmd_pri_game.SUB_GR_REQUEST_REPLY == sub then            -- 请求答复
        self:onSubRequestReply(pData)
    elseif cmd_pri_game.SUB_GR_REQUEST_RESULT == sub then           -- 请求结果
        self:onSubReplyResult(pData)
    elseif cmd_pri_game.SUB_GR_WAIT_OVER_TIME == sub then           -- 超时等待
        self:onSubWaitOverTime(pData)
    elseif cmd_pri_game.SUB_GR_PERSONAL_TABLE_TIP == sub then       -- 提示信息/游戏信息
        self:onSubTableTip(pData)
    elseif cmd_pri_game.SUB_GR_PERSONAL_TABLE_END == sub then       -- 结束
        self:onSubTableEnd(pData)
    elseif cmd_pri_game.SUB_GR_CANCEL_TABLE_RESULT == sub then      -- 私人房解散结果
        self:onSubCancelTableResult(pData)
    elseif cmd_pri_game.SUB_GR_CURRECE_ROOMCARD_AND_BEAN == sub then -- 强制解散桌子后的游戏豆和房卡数量
        self:onSubCancelTableScoreInfo(pData)
    elseif cmd_pri_game.SUB_GR_CHANGE_CHAIR_COUNT == sub then       -- 改变椅子数量
        self:onSubChangeChairCount(pData)
    elseif cmd_pri_game.SUB_GF_PERSONAL_MESSAGE == sub then         -- 私人房消息
        local cmd_table = ExternalFun.read_netdata(cmd_pri_game.Personal_Room_Message, pData)
        if nil ~= self._callBack then
            self._callBack(PERSONAL_TABLE_CMD(-1), cmd_table.szMessage)
        end
    end
end

-- 创建成功
function GameFrameEngine:onSubCreateSuccess( pData )
    local cmd_table = ExternalFun.read_netdata(cmd_pri_game.CMD_GR_CreateSuccess, pData)

    --{dBeans=924 dwDrawTimeLimit=0 lRoomCard=35 dwDrawCountLimit=5 szServerID="475108" }

    -- 个人财富
    GlobalUserItem.dUserBeans = cmd_table.dBeans
    GlobalUserItem.lRoomCard = cmd_table.lRoomCard

    -- 通知更新        
    local eventListener = cc.EventCustom:new(yl.RY_USERINFO_NOTIFY)
    eventListener.obj = yl.RY_MSG_USERWEALTH
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)

    if nil ~= self._callBack then
        self._callBack(PERSONAL_TABLE_CMD(cmd_pri_game.SUB_GR_CREATE_SUCCESS, cmd_table))
    end
end

-- 创建失败
function GameFrameEngine:onSubCreateFailure( pData )
    local cmd_table = ExternalFun.read_netdata(cmd_pri_game.CMD_GR_CreateFailure, pData)
    if nil ~= self._callBack then
        self._callBack(PERSONAL_TABLE_CMD(-1), cmd_table.szDescribeString)
    end
end

-- 解散桌子
function GameFrameEngine:onSubTableCancel( pData )
    local cmd_table = ExternalFun.read_netdata(cmd_pri_game.CMD_GR_CancelTable, pData)

    if nil ~= self._callBack then
        self._callBack(PERSONAL_TABLE_CMD(cmd_pri_game.SUB_GR_CANCEL_TABLE), cmd_table)
    end
end

-- 请求解散
function GameFrameEngine:onSubCancelRequest( pData )
    local cmd_table = ExternalFun.read_netdata(cmd_pri_game.CMD_GR_CancelRequest, pData)
    -- 自己不处理
    if cmd_table.dwUserID == GlobalUserItem.dwUserID then
        print("自己请求解散")
        return
    end
    if nil ~= self._callBack then
        self._callBack(PERSONAL_TABLE_CMD(cmd_pri_game.SUB_GR_CANCEL_REQUEST), cmd_table)
    end
end

-- 请求答复
function GameFrameEngine:onSubRequestReply( pData )
    local cmd_table = ExternalFun.read_netdata(cmd_pri_game.CMD_GR_RequestReply, pData)
    if nil ~= self._callBack then
        self._callBack(PERSONAL_TABLE_CMD(cmd_pri_game.SUB_GR_REQUEST_REPLY), cmd_table)
    end
end

-- 请求结果
function GameFrameEngine:onSubReplyResult( pData )
    local cmd_table = ExternalFun.read_netdata(cmd_pri_game.CMD_GR_RequestResult, pData)
    if nil ~= self._callBack then
        self._callBack(PERSONAL_TABLE_CMD(cmd_pri_game.SUB_GR_REQUEST_RESULT), cmd_table)
    end
end

-- 超时等待
function GameFrameEngine:onSubWaitOverTime( pData )
    local cmd_table = ExternalFun.read_netdata(cmd_pri_game.CMD_GR_WaitOverTime, pData)
    if nil ~= self._callBack then
        self._callBack(PERSONAL_TABLE_CMD(cmd_pri_game.SUB_GR_WAIT_OVER_TIME), cmd_table)
    end
end

-- 提示信息
function GameFrameEngine:onSubTableTip( pData )

    local cmd_table = ExternalFun.read_netdata(cmd_pri_game.CMD_GR_PersonalTableTip, pData)

    --{dwTableOwnerUserID=3 cbIsGoldOrGameScore=1 lIniScore=1000 szServerID="722273" dwPlayCount=0 dwPlayTime=1497183657 lCellScore=1 dwDrawTimeLimit=0 dwDrawCountLimit=5 cbIsJoinGame=0 }
    
    --保存房间数据
    GlobalUserItem.tabPriRoomData = cmd_table

    if nil ~= self._callBack then
        self._callBack(PERSONAL_TABLE_CMD(cmd_pri_game.SUB_GR_PERSONAL_TABLE_TIP), cmd_table)
    end
end

-- 结束消息
function GameFrameEngine:onSubTableEnd( pData )
    local cmd_table = ExternalFun.read_netdata(cmd_pri_game.CMD_GR_PersonalTableEnd, pData)
    if nil ~= self._callBack then
        self._callBack(PERSONAL_TABLE_CMD(cmd_pri_game.SUB_GR_PERSONAL_TABLE_END), cmd_table, pData)
    end
end

-- 私人房解散结果
function GameFrameEngine:onSubCancelTableResult( pData )
    local cmd_table = ExternalFun.read_netdata(cmd_pri_game.CMD_GR_DissumeTable, pData)
    if nil ~= self._callBack then
        self._callBack(PERSONAL_TABLE_CMD(cmd_pri_game.SUB_GR_CANCEL_TABLE_RESULT), cmd_table)
    end
end

-- 解散后财富信息
function GameFrameEngine:onSubCancelTableScoreInfo( pData )
    local cmd_table = ExternalFun.read_netdata(cmd_pri_game.CMD_GR_CurrenceRoomCardAndBeans, pData)
    -- 个人财富
    GlobalUserItem.dUserBeans = cmd_table.dbBeans
    GlobalUserItem.lRoomCard = cmd_table.lRoomCard
    -- 通知更新        
    local eventListener = cc.EventCustom:new(yl.RY_USERINFO_NOTIFY)
    eventListener.obj = yl.RY_MSG_USERWEALTH
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)

    if nil ~= self._callBack then
        self._callBack(PERSONAL_TABLE_CMD(cmd_pri_game.SUB_GR_CURRECE_ROOMCARD_AND_BEAN), cmd_table)
    end
end

-- 改变椅子数量
function GameFrameEngine:onSubChangeChairCount( pData )
    local cmd_table = ExternalFun.read_netdata(cmd_pri_game.CMD_GR_ChangeChairCount, pData)
    if nil ~= cmd_table.dwChairCount then
        self._wChairCount = cmd_table.dwChairCount
    end
end

----------------------------------------------------------------------------------------------------------

--更新桌椅用户
function GameFrameEngine:onUpDataTableUser(tableid,chairid,useritem)
	local id = tableid + 1
	local idex = chairid + 1
	if not self._tableUserList[id]  then
		self._tableUserList[id] = {}
	end
	if useritem then
		self._tableUserList[id][idex] = useritem.dwUserID
	else
		self._tableUserList[id][idex] = nil
	end
end

--获取桌子用户
function GameFrameEngine:getTableUserItem(tableid,chairid)
	local id = tableid + 1
	local idex = chairid + 1
	if self._tableUserList[id]  then
		local userid = self._tableUserList[id][idex] 
		if userid then
			return self._UserList[userid]
		end
	end
end

function GameFrameEngine:getTableInfo(index)
	if index > 0  then
		return self._tableStatus[index]
	end
end

--获取自己游戏信息
function GameFrameEngine:GetMeUserItem()
	return self._UserList[GlobalUserItem.dwUserID]
end

--获取游戏状态
function GameFrameEngine:GetGameStatus()
	return self._cbGameStatus
end

--设置游戏状态
function GameFrameEngine:SetGameStatus(cbGameStatus)
	self._cbGameStatus = cbGameStatus
end

--获取桌子ID
function GameFrameEngine:GetTableID()
	return self._wTableID
end

--获取椅子ID
function GameFrameEngine:GetChairID()
	return self._wChairID
end

--获取在线人数
function GameFrameEngine:GetOnlineCount()
    
    return table.nums(self._UserList)
end

--移除用户
function GameFrameEngine:onRemoveUser(dwUserID)
	self._UserList[dwUserID] = nil
end

--坐下请求
function GameFrameEngine:SitDown(table ,chair,password)
	local dataBuffer = CCmd_Data:create(70)
	dataBuffer:setcmdinfo(yl.MDM_GR_USER,yl.SUB_GR_USER_SITDOWN)
	dataBuffer:pushword(table)
	dataBuffer:pushword(chair)
	self._reqTable = table
	self._reqChair = chair
	if password then
		dataBuffer:pushstring(password,yl.LEN_PASSWORD)
	end

	--记录坐下信息
	if nil ~= GlobalUserItem.tabEnterGame and type(GlobalUserItem.tabEnterGame) == "table" then
		print("update game info")
		GlobalUserItem.tabEnterGame.nSitTable = table
		GlobalUserItem.tabEnterGame.nSitChair = chair
	end

	return self:sendSocketData(dataBuffer)
end

--查询用户
function GameFrameEngine:QueryUserInfo(table ,chair)
	local dataBuffer = CCmd_Data:create(4)
	dataBuffer:setcmdinfo(yl.MDM_GR_USER,yl.SUB_GR_USER_CHAIR_INFO_REQ)
	dataBuffer:pushword(table)
	dataBuffer:pushword(chair)
	return true --self:sendSocketData(dataBuffer)
end

--换位请求
function GameFrameEngine:QueryChangeDesk()
	if self._roomInfo.wKindID == tonumber(200) and self.bEnterAntiCheatRoom == true then
		self:SitDown(nil,nil,nil)
		-- local action6 = {}
		-- action6["wTableID"] = "0"
		-- action6["wChairID"]= 65535  
		-- action6["szTablePass"]= ""
		-- local pargams5 = {8,1,action6}
   
		-- local action7 = cjson.encode(pargams5)

		-- self._webFrame:wsSendString(action7)

		--self:SendUserReady()
	elseif self._roomInfo.wKindID == tonumber(27) or self._roomInfo.wKindID == tonumber(36) 
			or self._roomInfo.wKindID == tonumber(102) then
		self.bChangeDesk = true

		local action6 = {}
		action6["wTableID"] = "0"
		action6["wChairID"]= 65535  
		action6["szTablePass"]= ""
		local pargams5 = {8,1,action6}
		local action7 = cjson.encode(pargams5)

		self._webFrame:wsSendString(action7)
	else
		
		local dataBuffer = CCmd_Data:create(0)
		dataBuffer:setcmdinfo(yl.MDM_GR_USER,yl.SUB_GR_USER_CHAIR_REQ)

		return true --self:sendSocketData(dataBuffer)
	end
end

--起立请求
function GameFrameEngine:StandUp(bForce)
--	local dataBuffer = CCmd_Data:create(5)
--	dataBuffer:setcmdinfo(yl.MDM_GR_USER,yl.SUB_GR_USER_STANDUP)
--	dataBuffer:pushword(self:GetTableID())
--	dataBuffer:pushword(self:GetChairID())
--	dataBuffer:pushbyte(not bForce and 0 or 1)
--	return self:sendSocketData(dataBuffer)
    local action = {yl.MDM_GR_USER,yl.SUB_GR_USER_STANDUP}
    return self._webFrame:wsSendString(cjson.encode(action))
end

--发送准备
function GameFrameEngine:SendUserReady(dataBuffer)
	local userReady = dataBuffer
	if not userReady then
		userReady = CCmd_Data:create(0)
	end
	userReady:setcmdinfo(yl.MDM_GF_FRAME,yl.SUB_GF_USER_READY)
	return self:sendSocketData(userReady)
end

--场景规则
function GameFrameEngine:SendGameOption()
--	local dataBuffer = CCmd_Data:create(9)
--	dataBuffer:setcmdinfo(yl.MDM_GF_FRAME,yl.SUB_GF_GAME_OPTION)
--	dataBuffer:pushbyte(0)
--	dataBuffer:pushdword(appdf.VersionValue(6,7,0,1))
--	dataBuffer:pushdword(self._kindVersion)
--	return self:sendSocketData(dataBuffer)
    local action = {}
    action["bAllowLookon"] = 1
    local pargams = {yl.MDM_GF_FRAME,yl.SUB_GF_GAME_OPTION,action}
    local action2 = cjson.encode(pargams)
    return self._webFrame:wsSendString(action2)
end

--加密桌子
function GameFrameEngine:SendEncrypt(pass)
	local passlen = string.len(pass) * 2 --14--(ExternalFun.stringLen(pass)) * 2
	print("passlen ==> " .. passlen)
	local len = passlen + 4 + 13--(sizeof game_cmd.CMD_GR_UserRule)
	print("len ==> " .. len)
	local cmddata = CCmd_Data:create(len)
	cmddata:setcmdinfo(game_cmd.MDM_GR_USER, game_cmd.SUB_GR_USER_RULE)
	cmddata:pushbyte(0)
	cmddata:pushword(0)
	cmddata:pushword(0)
	cmddata:pushint(0)
	cmddata:pushint(0)
	cmddata:pushword(passlen)
	cmddata:pushword(game_cmd.DTP_GR_TABLE_PASSWORD)	
	cmddata:pushstring(pass, passlen / 2)

	return self:sendSocketData(cmddata)
end

--发送文本聊天 game_cmd.CMD_GF_C_UserChat
--[msg] 聊天内容
--[tagetUser] 目标用户
function GameFrameEngine:sendTextChat( msg, tagetUser , color)
	if type(msg) ~= "string" then
		print("聊天内容异常")
		return false, "聊天内容异常!"
	end
	--敏感词判断
	if true == ExternalFun.isContainBadWords(msg) then
		print("聊天内容包含敏感词汇")
		return false, "聊天内容包含敏感词汇!"
	end
	msg = msg .. "\0"

	tagetUser = tagetUser or yl.INVALID_USERID
	color = color or 16777215 --appdf.ValueToColor( 255,255,255 )
	local msgLen = string.len(msg)
	local defineLen = yl.LEN_USER_CHAT * 2

	local cmddata = CCmd_Data:create(266 - defineLen + msgLen * 2  + 6)
	
	cmddata:setcmdinfo(yl.MDM_GF_FRAME,game_cmd.SUB_GF_USER_CHAT)
	cmddata:pushdword(msgLen*2)
	cmddata:pushdword(color)
	cmddata:pushdword(GlobalUserItem.dwUserID)
	cmddata:pushdword(tagetUser)
	cmddata:pushstring(msg, msgLen)

	return self:sendSocketData(cmddata)
end

--发送表情聊天 game_cmd.CMD_GF_C_UserExpressio
--[idx] 表情图片索引
--[tagetUser] 目标用户
function GameFrameEngine:sendBrowChat( idx, tagetUser )
	tagetUser = tagetUser or yl.INVALID_USERID

	local cmddata = CCmd_Data:create(6 + 2)
	cmddata:setcmdinfo(6,game_cmd.SUB_GF_USER_EXPRESSION)
	cmddata:pushdword(idx)
	cmddata:pushdword(tagetUser)

	return self:sendSocketData(cmddata)
end

function GameFrameEngine:OnResetGameEngine()
	if self._viewFrame and self._viewFrame.OnResetGameEngine then
		self._viewFrame:OnResetGameEngine()
	end
end

function GameFrameEngine:popVocieMsg()
	if self._bPlayVoiceRecord then
		return
	end

	local msgTab = self._tabVoiceMsgQueue[1]
	if type(msgTab) == "table" then
		local uid = msgTab.uid
		local spath = msgTab.spath

		--获取玩家
		local useritem = self._UserList[uid]
		if nil ~= useritem then
			-- 录音开始
			if nil ~= self._viewFrame and nil ~= self._viewFrame.onUserVoiceStart then
				self._viewFrame:onUserVoiceStart(useritem, spath)
			end

			self._nPlayVoiceId = VoiceRecorderKit.startPlayVoice(spath)
        	AudioRecorder:getInstance():setFinishCallBack(self._nPlayVoiceId, function(voiceid, filename)
                print("play over " .. filename)
                VoiceRecorderKit.finishPlayVoice()                
                self._bPlayVoiceRecord = false
                self._nPlayVoiceId = nil

                -- 录音结束
                if nil ~= self._viewFrame and nil ~= self._viewFrame.onUserVoiceEnded then
                	self._viewFrame:onUserVoiceEnded(useritem, spath)
                end    
                self:setPlayingVoice(false)     
            end)
			self._bPlayVoiceRecord = true
		end
	end
	table.remove(self._tabVoiceMsgQueue, 1)
end

function GameFrameEngine:setPlayingVoice( bPlaying )
	self._bPlayVoiceRecord = bPlaying
	if false == bPlaying then
		self:popVocieMsg()
	end 
end

function GameFrameEngine:clearVoiceQueue()
	self._tabVoiceMsgQueue = {}
	self._bPlayVoiceRecord = false
	if nil ~= self._nPlayVoiceId then
		ccexp.AudioEngine:stop(self._nPlayVoiceId)
        VoiceRecorderKit.finishPlayVoice()
        self._nPlayVoiceId = nil
	end
	if nil ~= AudioRecorder:getInstance().clear then
		AudioRecorder:getInstance():clear()
	end
end

return GameFrameEngine