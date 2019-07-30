local GameModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameModel")
local GameLayer = class("GameLayer", GameModel)

local module_pre = "game.yule.animalbattle.src"
local ExternalFun =  appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local cmd = appdf.req(module_pre .. ".models.CMD_Game")
local GameViewLayer = appdf.req(module_pre .. ".views.layer.GameViewLayer")
local GameServer_CMD = appdf.req(appdf.HEADER_SRC.."CMD_GameServer")

if LOCAL_DEVELOP == 1 then
	cc.FileUtils:getInstance():addSearchPath("game/yule/animalbattle/res")
else
	cc.FileUtils:getInstance():addSearchPath(device.writablePath.."game/yule/animalbattle/res")
end



--时间标识
local IDI_FREE			=		99									--空闲时间
local IDI_PLACE_JETTON	=		100									--下注时间
local IDI_DISPATCH_CARD	=		301									--发牌时间
local IDI_OPEN_CARD		=		302								    --发牌时间
local IDI_ANDROID_BET	=		1000	


--assignArray(destTable)清空array
--assignArray(destTable,srcTable)将srcTable的内容复制到destTable
--assignArray(destTable,n,value) 使destTable[i]=value,i=1,2...n
local function assignArray(destTable,...) --只改变table的array部分
	local var={...}
	if var[1]==nil then
		for i=1,#destTable do
			destTable[i]=nil
		end
	elseif type(var[1])=="table" then
		for i=1,#var[1] do
			destTable[i]=var[1][i]
		end
		destTable[#var[1]+1]=nil
	elseif type(var[1])=="number" then
		for i=1,var[1] do
			destTable[i]=var[2]
		end
		destTable[var[1]+1]=nil
	end
end

--onreset

--创建网络消息包
local function create_netdata( keyTable ) 
	local len = 0;
	for i=1,#keyTable do
		local keys = keyTable[i];
		local keyType = string.lower(keys["t"]);

		--todo 数组长度计算
		local keyLen = 0;
		if "byte" == keyType or "bool" == keyType then
			keyLen = 1;
		elseif "score" == keyType or "double" == keyType then
			keyLen = 8;
		elseif "word" == keyType or "short" == keyType then
			keyLen = 2;
		elseif "dword" == keyType or "int" == keyType or "float" == keyType then
			keyLen = 4;
		elseif "string" == keyType then
			keyLen = keys["s"];
		elseif "tchar" == keyType then
			keyLen = keys["s"] * 2
		elseif "ptr" == keyType then
			keyLen = keys["s"]
		else
			print("error keytype ==> ", keyType);
		end

		local multi=1
		local lenTable=keys["l"]
		if lenTable then
			dbg_assert("string" ~= keyType and "tchar" ~= keyType and "ptr" ~= keyType)
			for i=1,#lenTable do
				multi=multi*lenTable[i]
			end
		end

		len = len + keyLen*multi
	end
	print("net len ==> ", len)
	return CCmd_Data:create(len);
end

GameLayer.m_JettonScore = { 1000, 10000, 100000, 1000000, 5000000, 10000000}
GameLayer.m_isDyna = false


function GameLayer:ctor( frameEngine,scene )  
	local cmddata = create_netdata(cmd.CMD_C_ContinueJetton)
	 GameLayer.super.ctor(self, frameEngine, scene)
	 self:initData()
	 self._roomRule = self._gameFrame._dwServerRule
	 self.originalFPS=cc.Director:getInstance():getAnimationInterval()
	 cc.Director:getInstance():setAnimationInterval(1/30)

	 self.m_lContinueRecord  = {0,0,0,0,0,0,0,0,0,0,0}  --续压记录
	 self.m_bPlaceRecord = false
	 --cc.Director:getInstance():setDisplayStats(true)

	 -- setbackgroundcallback( function(bEnter)
	 -- 	if not bEnter then --切到后台
	 -- 		self._gameView:stopGameOverAnimations()
	 -- 	else              --切回前台
	 -- 		self._gameView:resumeGameOverAnimations()
	 -- 	end
	 -- end)

end

function GameLayer:initData()
	self.tabMyBets={}
	self.tabTotalBets={}
	self.m_nCumulativeScore=0 --总得分
	self.m_nAllPlayBet=0  --此次下注总和
	self.m_nCurrentNote=nil
	--self.bAllowOpeningAni=true
end

function GameLayer:CreateView()
	local this=self
    return GameViewLayer:create(this)
        :addTo(this)
end

function GameLayer:clearBets()
	self.m_nAllPlayBet=0
	for i=1,cmd.AREA_COUNT do
		self.tabMyBets[i]=0
		self.tabTotalBets[i]=0
	end
	self._gameView:updateMyBets(self.tabMyBets)    
	self._gameView:updateTotalBets(self.tabTotalBets)
end

function GameLayer:SetGameStatus(status)
	self.m_cbGameStatus=status
end

--退出桌子
function GameLayer:onExitTable()
	-- --先发强退
	-- if self.m_isDyna == true then
	-- 	local cmddata = create_netdata(cmd.CMD_C_GameUserLeave)
	-- 	cmddata:pushword(self:GetMeChairID())
	-- 	--发送消息
	-- 	local ret=self:SendData(cmd.SUB_C_GAMEUSER_LEAVE,cmddata)
	-- end
	local MeItem = self:GetMeUserItem()
	if MeItem and MeItem.cbUserStatus > yl.US_FREE then
		self:showPopWait()
		self:runAction(cc.Sequence:create(
			cc.CallFunc:create(
				function ()
					self._gameFrame:StandUp(1)
				end
				),
			cc.DelayTime:create(1),
			cc.CallFunc:create(
				function ()
					self:onExitRoom()
				end
				)
			)
		)
		return
	end
	self:onExitRoom()
end

--离开房间
function GameLayer:onExitRoom()
	-- removebackgroundcallback() 
	-- if type(self._scene.onBackgroundCallBack)=="function" then
	-- 	setbackgroundcallback(self._scene.onBackgroundCallBack)
	-- end

	self._gameFrame:onCloseSocket()
	self:KillGameClock()
	print("self.originalFPS: ",self.originalFPS)
	cc.Director:getInstance():setAnimationInterval(self.originalFPS)
	self._scene:onKeyBack()
end

local ithMsg=0
function GameLayer:onEventGameMessage(sub,dataBuffer)
	ithMsg=ithMsg+1
	--print("ithMsg: ",ithMsg)
	if sub== cmd.SUB_S_GAME_FREE then	--空闲时间
		return self:OnSubGameFree(dataBuffer)
	elseif sub==cmd.SUB_S_GAME_START then	--游戏开始
		return self:OnSubGameStart(dataBuffer)
	elseif sub==cmd.SUB_S_PLACE_JETTON then	--玩家下注
		return self:OnSubPlaceJetton(dataBuffer)
	elseif sub==cmd.SUB_S_GAME_END then	--游戏结束
		return self:OnSubGameEnd(dataBuffer)
	elseif sub==cmd.SUB_S_PLACE_JETTON_FAIL then--下注失败
		return self:OnSubPlaceJettonFail(dataBuffer)
	elseif sub==cmd.SUB_S_CEAN_JETTON then	--清除下注
		return self:OnSubClearJetton(dataBuffer)
	elseif sub==cmd.SUB_S_CONTINU_JETTON then	--更新下注
		return self:OnSubContinueJetton(dataBuffer)
    elseif sub == cmd.SUB_S_SEND_RECORD then --游戏记录
        return self:onSubGameRecord(dataBuffer)
	end
end


function GameLayer:onEventGameScene(cbGameStatus,dataBuffer)
	
	print("游戏状态 ：" .. cbGameStatus)
	if cbGameStatus==cmd.GAME_STATUS_FREE then
		local pStatusFree = ExternalFun.read_netdata(cmd.CMD_S_StatusFree, dataBuffer)

		ExternalFun.playBackgroudAudio( "GAME_FREE.wav" )
		self.m_nCurrentNote=0
		--设置状态
		self:SetGameStatus(cmd.GAME_STATUS_FREE)
		self._gameView:SetGameStatus(cmd.GAME_STATUS_FREE)
		self._gameView:updateTimeTextImg()
		self._gameView:updateAsset(GlobalUserItem.lUserScore)
		-- self._gameView:updateTotalScore(self.m_nCumulativeScore or 0)
		self._gameView:updateCurrentScore(0)
		self._gameView:enable_NoteNum_Clear_ContinueBtn(false)

		self:SetGameClock(self:GetMeChairID(),IDI_FREE,pStatusFree.cbTimeLeave)
				
		--self._gameView:updateStorage( pStatusFree.lStorageStart) --lStorageStart全部改成lBonus
	    self._gameView:updateStorage( pStatusFree.lBonus)--显示库存改成显示彩金
		--玩家信息
		self.m_lMeMaxScore=pStatusFree.lUserMaxScore
		--self._gameView:updatexxx(self.m_lMeMaxScore);

		self.m_lAreaLimitScore=pStatusFree.lAreaLimitScore
		
	elseif cbGameStatus==cmd.GS_PLACE_JETTON or cbGameStatus==cmd.GS_GAME_END then
		local pStatusPlay = ExternalFun.read_netdata(cmd.CMD_S_StatusPlay, dataBuffer)
		self:SetGameStatus(cbGameStatus)
		if cbGameStatus==cmd.GS_PLACE_JETTON then --self.tabTotalBets
			dump(pStatusPlay)

			for i=1,cmd.AREA_COUNT-1 do
				self.tabTotalBets[i]=pStatusPlay.lAllJettonScore[1][i+1]
			end
			self._gameView:updateTotalBets(self.tabTotalBets)

			self.m_isDyna = true
			self._gameView:SetGameStatus(cmd.GS_PLACE_JETTON)
			self._gameView:enableAllBtns(true)
			ExternalFun.playBackgroudAudio( "GAME_FREE.wav" )
			self._gameView:updateCurrentScore(0)
			self._gameView:updateXuya()
			self._gameView:updateJettonList(GlobalUserItem.lUserScore)
			-- self._gameView:disableNoteNumBtns(1)
			-- self.m_nCurrentNote=0
		elseif cbGameStatus==cmd.GS_GAME_END then
			ExternalFun.playBackgroudAudio( "GAME_START.wav" )
			self.m_nCurrentNote=0
			self._gameView:SetGameStatus(cmd.GS_GAME_END)
			self._gameView:enableAllBtns(false)
			
			-- if pStatusPlay.cbTimeLeave>=3 then
			-- 	self._gameView:animationForFirstOpening(pStatusPlay.cbTimeLeave-1)
			-- end
		end

		local nTimerID = (pStatusPlay.cbGameStatus==cmd.GS_GAME_END) and IDI_OPEN_CARD or IDI_PLACE_JETTON
		self:SetGameClock(self:GetMeChairID(), nTimerID, pStatusPlay.cbTimeLeave)
		self._gameView:updateAsset(GlobalUserItem.lUserScore-self.m_nAllPlayBet) 
		-- self._gameView:updateTotalScore(self.m_nCumulativeScore or 0) 
		self._gameView:updateTimeTextImg()

		--self._gameView:updateStorage( pStatusPlay.lStorageStart)
        self._gameView:updateStorage( pStatusPlay.lBonus)--显示库存改成显示彩金
        
		--玩家积分
		self.m_lMeMaxScore=pStatusPlay.lUserMaxScore;			
		--self._gameView:updatexxx(self.m_lMeMaxScore);
		
		self.m_lAreaLimitScore=pStatusPlay.lAreaLimitScore;

	end
end
function GameLayer:onSubGameRecord( dataBuffer )
     local recordCount = math.floor(dataBuffer:getlen()/13)
	 
	 --print("收到游戏记录消息")
    if recordCount >= 1 then
        --self._gameView.turnTableRecords = 
        for i=1,recordCount do
		  local record = ExternalFun.read_netdata(cmd.tagServerGameRecord,dataBuffer)
		  --print("打印游戏记录消息")
		  --dump(record)
          --self._gameView:addRcord(record.cbCarIndex)
          for j=1,12 do
            local betRes = record.bWinMen[1][j]

            if betRes==4 then
              local betResTrans
              if(j==1) then
                betResTrans = 7
              elseif(j>=2 and j<=8) then
                betResTrans = j-2
              elseif(j>=9) then
                betResTrans = j-1
              end
              self._gameView:AddTurnTableRecord(betResTrans)
              --self._gameView.updateShowTurnTableRecord()
              break
            end
            
          end 
          --print("record,".. record.bWinMen[1])
        end
        self._gameView:updateShowTurnTableRecord()
    end
end
function GameLayer:OnSubGameFree(dataBuffer)

	ExternalFun.playBackgroudAudio( "GAME_FREE.wav" )
	local pGameFree = ExternalFun.read_netdata(cmd.CMD_S_GameFree, dataBuffer)

	--设置时间
	self:SetGameClock(self:GetMeChairID(),IDI_FREE,pGameFree.cbTimeLeave)

	self.m_nCurrentNote=nil
	self.m_nAllPlayBet=0

	self:SetGameStatus(cmd.GAME_STATUS_FREE)
	self._gameView:SetGameStatus(cmd.GAME_STATUS_FREE)
	self._gameView:updateTimeTextImg()
	self._gameView:enableBetBtns(true)
	self._gameView:enable_NoteNum_Clear_ContinueBtn(false)

	self._gameView:updateAsset(GlobalUserItem.lUserScore)
	
	--self._gameView:updateStorage(pGameFree.lStorageStart) --彩池数字
    self._gameView:updateStorage(pGameFree.lBonus)--显示库存改成显示彩金
	assignArray(self.tabMyBets,cmd.AREA_COUNT-1,0)     --清空个人下注
	assignArray(self.tabTotalBets,cmd.AREA_COUNT-1,0)   --清空总下注
	self._gameView:updateMyBets(self.tabMyBets)    
	self._gameView:updateTotalBets(self.tabTotalBets)
	self._gameView:updateCurrentScore(0)
	self._gameView:updateXuya()
	self._gameView:updateShowJet()	
    
end

function GameLayer:OnSubGameStart(dataBuffer)

	local pGameStart = ExternalFun.read_netdata(cmd.CMD_S_GameStart, dataBuffer)

	print("pGameStart.cbTimeLeave: ",pGameStart.cbTimeLeave)
	--dbg_assert(pGameStart.cbTimeLeave<=30)
	--设置状态
	self:SetGameStatus(cmd.GS_PLACE_JETTON)
	self._gameView:SetGameStatus(cmd.GS_PLACE_JETTON)
	self._gameView:updateTimeTextImg()
	self._gameView:updateXuya()
	
	self._gameView:resetGame()
	self._gameView:enableAllBtns(true) 

	local startIndex=nil
	for i=1,6 do
		
		noteNum = self.m_JettonScore[i]

		if (GlobalUserItem.lUserScore-self.m_nAllPlayBet)/noteNum<1 then
			startIndex=i
			break
		end
	end

	--下注区域闪两下
	self._gameView:showHuShanHuShan()


	if nil~=startIndex then
		self._gameView:disableNoteNumBtns(startIndex)
	end


	self._gameView:updateAsset(GlobalUserItem.lUserScore)
	--self._gameView:updateStorage( pGameStart.lStorageStart ) --更新彩池数字
    self._gameView:updateStorage( pGameStart.lBonus )--显示库存改成显示彩金
	self._gameView:updateCurrentScore(0)
	--玩家信息
	self.m_lMeMaxScore=pGameStart.lUserMaxScore;  

	self._gameView:updateJettonList(GlobalUserItem.lUserScore)
	self.m_nCurrentNote = self.m_JettonScore[self._gameView.m_nJettonSelect]
	
	
	--设置时间
	self:SetGameClock(self:GetMeChairID(),IDI_PLACE_JETTON,pGameStart.cbTimeLeave);
    
end

function GameLayer:OnSubGameEnd(dataBuffer)
	ExternalFun.playBackgroudAudio( "GAME_START.wav" )
	local pGameEnd = ExternalFun.read_netdata(cmd.CMD_S_GameEnd, dataBuffer)

	self:SetGameStatus(cmd.GS_GAME_END)
	self._gameView:SetGameStatus(cmd.GS_GAME_END)
	self._gameView:updateTimeTextImg()
	self._gameView:removeFirstOpeningAni()
	self._gameView:updateXuya()
	
	self.m_nCurrentNote=nil
	self.m_nAllPlayBet=0
	self._gameView:enableAllBtns(false) 

	self.m_GameEndTime = pGameEnd.cbTimeLeave;

	--设置时间
	self:SetGameClock(self:GetMeChairID(),IDI_DISPATCH_CARD, pGameEnd.cbTimeLeave);

	self.m_nCumulativeScore=self.m_nCumulativeScore+pGameEnd.lUserScore

	self._gameView:GameOver(pGameEnd.cbTableCardArray[1], pGameEnd.lUserScore, self.m_nCumulativeScore,pGameEnd.cbShaYuAddMulti);
    
end

function GameLayer:getPlayerList(  )
    return self._gameFrame._UserList
end


function GameLayer:OnSubPlaceJetton(dataBuffer)  --done
	if self.m_cbGameStatus~=cmd.GS_PLACE_JETTON then
		return
	end

	local pPlaceJetton = ExternalFun.read_netdata(cmd.CMD_S_PlaceJetton, dataBuffer)
	local index=pPlaceJetton.cbJettonArea 
	dbg_assert(pPlaceJetton.lJettonScore)
	self._gameView:showUserJetton(pPlaceJetton)
	--print("cbJettonArea: ",index)
	--print("下注回调？？？？？pPlaceJetton.lJettonScore: ",pPlaceJetton.lJettonScore)
	self.tabTotalBets[index]=self.tabTotalBets[index] or 0
	self.tabTotalBets[index]=self.tabTotalBets[index]+pPlaceJetton.lJettonScore
	self._gameView:updateTotalBet(index,self.tabTotalBets[index],pPlaceJetton.lJettonScore)
	if pPlaceJetton.wChairID==self:GetMeChairID() then
		self.tabMyBets[index]=self.tabMyBets[index] or 0
		self.tabMyBets[index]=self.tabMyBets[index]+pPlaceJetton.lJettonScore
		self._gameView:updateMyBet(index,self.tabMyBets[index],pPlaceJetton.lJettonScore)
		--self.m_nAllPlayBet=self.m_nAllPlayBet+self.m_nCurrentNote
		if GlobalUserItem.lUserScore-self.m_nAllPlayBet>0 then
			self._gameView:updateAsset(GlobalUserItem.lUserScore-self.m_nAllPlayBet)
		else
			self._gameView:updateAsset(0)			
		end
		--self._gameView:updateAsset(GlobalUserItem.lUserScore-self.m_nAllPlayBet)

		if not self.m_bPlaceRecord then
            self.m_lContinueRecord = {0,0,0,0,0,0,0,0,0,0,0}
            self.m_bPlaceRecord = true
			self._gameView.bContinueRecord = true
			self._gameView:updateXuya()			
        end
		self.m_lContinueRecord[pPlaceJetton.cbJettonArea] = self.m_lContinueRecord[pPlaceJetton.cbJettonArea] + pPlaceJetton.lJettonScore  --续压记录
		
		local startIndex=nil
		for i=1,6 do
			noteNum = self.m_JettonScore[i]
			if (GlobalUserItem.lUserScore-self.m_nAllPlayBet)/noteNum<1 then
				startIndex=i
				break
			end
		end

		if nil~=startIndex then
			self._gameView:disableNoteNumBtns(startIndex)
			self._gameView:updateJettonList(GlobalUserItem.lUserScore-self.m_nAllPlayBet)
		end
	end
end

--下注失败
function GameLayer:OnSubPlaceJettonFail(dataBuffer) --done
	if self.m_cbGameStatus~=cmd.GS_PLACE_JETTON then
		return
	end
	
	local pPlaceJettonFail = ExternalFun.read_netdata(cmd.CMD_S_PlaceJettonFail, dataBuffer)
    if pPlaceJettonFail.wPlaceUser==self:GetMeChairID() then
    else
        local index=pPlaceJettonFail.lJettonArea
        self.tabTotalBets[index]=self.tabTotalBets[index]-pPlaceJettonFail.lPlaceScore
	    self._gameView:updateTotalBet(index,self.tabTotalBets[index])
    end
	print("pPlaceJettonFail.lJettonArea:",pPlaceJettonFail.lJettonArea)
	print("pPlaceJettonFail.lJettonArea:",pPlaceJettonFail.lJettonArea)
	print("pPlaceJettonFail.wPlaceUser:",pPlaceJettonFail.wPlaceUser)

end

function GameLayer:OnSubContinueJetton(dataBuffer) --done
	--showToast(self._gameView,"收到续投消息",3)
	if self.m_cbGameStatus~=cmd.GS_PLACE_JETTON then
		--showToast(self._gameView,"非下注时间，不处理",1)
		return
	end

	local  pLastJetton= ExternalFun.read_netdata(cmd.CMD_S_ContiueJetton, dataBuffer)
	for i=1,cmd.AREA_COUNT-1 do
		self.tabTotalBets[i]=pLastJetton.lAllJettonScore[1][i+1]
	end
	self._gameView:updateTotalBets(self.tabTotalBets)

	local temptest=0
	for i=1,cmd.AREA_COUNT-1 do
		self.tabMyBets[i]=pLastJetton.lUserJettonScore[1][i+1]

		if self.tabMyBets[i] ~=0 then
			local tmp_place = {}
			tmp_place["lJettonScore"] = self.tabMyBets[i]
			tmp_place["cbJettonArea"] = i
			tmp_place["wChairID"]	  = self:GetMeChairID()
			self._gameView:showUserJetton(tmp_place,true)
		end

		temptest=temptest+self.tabMyBets[i]
	end
	
	if self:GetMeChairID() == pLastJetton.wChairID then
		--showToast(self._gameView,"收到自己续投消息",1)
		-- local temptest=0
		-- for i=1,cmd.AREA_COUNT-1 do
		-- 	self.tabMyBets[i]=pLastJetton.lUserJettonScore[1][i+1]

		-- 	if self.tabMyBets[i] ~=0 then
		-- 		local tmp_place = {}
		-- 		tmp_place["lJettonScore"] = self.tabMyBets[i]
		-- 		tmp_place["cbJettonArea"] = i
		-- 		tmp_place["wChairID"]	  = self:GetMeChairID()
		-- 		self._gameView:showUserJetton(tmp_place,true)
		-- 	end

		-- 	temptest=temptest+self.tabMyBets[i]
		-- end
		--showToast(self._gameView,"收到自己续投消息,上盘总下注为"..temptest,1)
		--self._gameView:updateTotalBets(temptest)
		
		self._gameView:updateMyBets(self.tabMyBets)
		self.m_nAllPlayBet=0
		for i=1,cmd.AREA_COUNT-1 do
			self.m_nAllPlayBet=self.m_nAllPlayBet+self.tabMyBets[i]
		end
		self._gameView:updateAsset(GlobalUserItem.lUserScore-self.m_nAllPlayBet)
		
		local startIndex=nil
		for i=1,6 do
			noteNum = self.m_JettonScore[i]
			if (GlobalUserItem.lUserScore-self.m_nAllPlayBet)/noteNum<1 then
				startIndex=i
				break
			end
		end

		if nil~=startIndex then
			self._gameView:disableNoteNumBtns(startIndex)
		end
	
	end

end

function GameLayer:OnSubClearJetton(dataBuffer) --清除下注 --done
	if self.m_cbGameStatus~=cmd.GS_PLACE_JETTON then
		return
	end

	local  pCleanJetton=ExternalFun.read_netdata(cmd.CMD_S_CeanJetton, dataBuffer)
	for i=1,cmd.AREA_COUNT-1 do
		self.tabTotalBets[i]=pCleanJetton.lAllCPlaceScore[1][i+1]
	end

	self._gameView:updateTotalBets(self.tabTotalBets)

	if self:GetMeChairID()==pCleanJetton.wChairID then
		for i=1,cmd.AREA_COUNT-1 do
			self.m_nAllPlayBet=self.m_nAllPlayBet-(self.tabMyBets[i] or 0)
		end
		--dbg_assert(0==self.m_nAllPlayBet)
		self._gameView:updateAsset(GlobalUserItem.lUserScore-self.m_nAllPlayBet)
		assignArray(self.tabMyBets,cmd.AREA_COUNT-1,0)
		self._gameView:updateMyBets(self.tabMyBets)
	
		dbg_assert(0==self.m_nAllPlayBet)
		-- print("GlobalUserItem.lUserScore: ",GlobalUserItem.lUserScore)
		-- print("self.m_nAllPlayBet: ",self.m_nAllPlayBet)
		-- assert(false)
		local endIndex=nil
		for i=5,1,-1 do
			local noteNum=math.pow(10,i+1)
			if (GlobalUserItem.lUserScore-self.m_nAllPlayBet)>=noteNum then
				endIndex=i
				break
			end
		end

		if nil~=endIndex then
			self._gameView:enableNoteNumBtns(endIndex)
		end

	end
end


--银行消息
function GameLayer:onSocketInsureEvent( sub,dataBuffer )
    self:dismissPopWait()
    if sub == GameServer_CMD.SUB_GR_USER_INSURE_SUCCESS then
        local cmd_table = ExternalFun.read_netdata(GameServer_CMD.CMD_GR_S_UserInsureSuccess, dataBuffer)
        self.bank_success = cmd_table
        GlobalUserItem.lUserScore = cmd_table.lUserScore
    	GlobalUserItem.lUserInsure = cmd_table.lUserInsure
        self._gameView:updateAsset(GlobalUserItem.lUserScore-self.m_nAllPlayBet)
        self._gameView:onBankSuccess()
    elseif sub == GameServer_CMD.SUB_GR_USER_INSURE_FAILURE then
        local cmd_table = ExternalFun.read_netdata(GameServer_CMD.CMD_GR_S_UserInsureFailure, dataBuffer)
        self.bank_fail = cmd_table

        self._gameView:onBankFailure()
    elseif sub == GameServer_CMD.SUB_GR_USER_INSURE_INFO then --银行资料
        local cmdtable = ExternalFun.read_netdata(GameServer_CMD.CMD_GR_S_UserInsureInfo, dataBuffer)
        dump(cmdtable, "cmdtable", 6)

        self._gameView:onGetBankInfo(cmdtable)
    else
        print("unknow gamemessage sub is ==>"..sub)
    end
end

function GameLayer:sendNetData( cmddata )
    return self._gameFrame:sendSocketData(cmddata)
end

--申请取款
function GameLayer:sendTakeScore(lScore, szPassword )
    local cmddata = ExternalFun.create_netdata(GameServer_CMD.CMD_GR_C_TakeScoreRequest)
    cmddata:setcmdinfo(GameServer_CMD.MDM_GR_INSURE, GameServer_CMD.SUB_GR_TAKE_SCORE_REQUEST)
    cmddata:pushbyte(GameServer_CMD.SUB_GR_TAKE_SCORE_REQUEST)
    cmddata:pushscore(lScore)
    cmddata:pushstring(GlobalUserItem.PasswordEncryption(szPassword),yl.LEN_PASSWORD)

    self:sendNetData(cmddata)
end


--请求银行信息
function GameLayer:sendRequestBankInfo()
    local cmddata = CCmd_Data:create(67)
    cmddata:setcmdinfo(GameServer_CMD.MDM_GR_INSURE,GameServer_CMD.SUB_GR_QUERY_INSURE_INFO)
    cmddata:pushbyte(GameServer_CMD.SUB_GR_QUERY_INSURE_INFO)
    cmddata:pushstring(GlobalUserItem.szPassword,yl.LEN_PASSWORD)

    self:sendNetData(cmddata)
end


--清除按钮消息
function GameLayer:OnCleanJetton() --done

	if self.m_cbGameStatus~=cmd.GS_PLACE_JETTON then
		return
	end

	--构造数据
	local cmddata = create_netdata(cmd.CMD_C_CleanMeJetton)
	cmddata:pushword(self:GetMeChairID())  

	local ret=self:SendData(cmd.SUB_C_CLEAN_JETTON,cmddata) 

end

--加注按钮消息
function GameLayer:OnPlaceJetton(sender) --done
	if self.m_cbGameStatus~=cmd.GS_PLACE_JETTON then
		return
	end
 
 	local cbJettonArea=sender.m_kind
	--合法判断
	dbg_assert(cbJettonArea>=1 and cbJettonArea<cmd.AREA_COUNT)
	if (not (cbJettonArea>=1 and cbJettonArea<cmd.AREA_COUNT)) then  return  end
	--状态判断
	if (self.m_cbGameStatus~=cmd.GS_PLACE_JETTON) then
		
		return 
	end

	if self.m_nCurrentNote==nil or self.m_nCurrentNote<1000 then
		return
	end
	if GlobalUserItem.lUserScore <self.m_nCurrentNote  then
		return
	end

	while self.m_nCurrentNote>=1000 do  --100为最小注额
		if GlobalUserItem.lUserScore -self.m_nAllPlayBet < self.m_nCurrentNote and self._gameView.m_nJettonSelect~=0 then
			self.m_nCurrentNote=self.m_JettonScore[self._gameView.m_nJettonSelect]
		else
			break
		end
		
		if self.m_nCurrentNote<1000 then
			return 
		end
	end
	self._gameView:updateXuya() 
	
	dbg_assert(self.m_nCurrentNote>=1000)

	--先更新 再发送 下注成功
	if self.m_nAllPlayBet+self.m_nCurrentNote <= GlobalUserItem.lUserScore then
		self.m_nAllPlayBet=self.m_nAllPlayBet+self.m_nCurrentNote
		self._gameView:updateJettonList(GlobalUserItem.lUserScore-self.m_nAllPlayBet)		
	else
		return
	end

	--self._gameView:updateAsset(GlobalUserItem.lUserScore-self.m_nAllPlayBet)

	local cmddata = create_netdata(cmd.CMD_C_PlaceJetton)

	cmddata:pushbyte(cbJettonArea)   
	cmddata:pushscore(self.m_nCurrentNote)
	local ret=self:SendData(cmd.SUB_C_PLACE_JETTON,cmddata) 

	--ExternalFun.playClickEffect()
	--dbg_assert(ret and ret~=0)
	print("ret: ",ret)
end


--续投
function GameLayer:OnLastPlaceJetton( ) --done
	if self.m_cbGameStatus~=cmd.GS_PLACE_JETTON then
		--showToast(self._gameView,"非下注时间，点击无效",1)
		return
	end
	 
 	local cmddata = create_netdata(cmd.CMD_C_ContinueJetton)
	cmddata:pushword(self:GetMeChairID())
	
	--发送消息
	local ret=self:SendData(cmd.SUB_C_CONTINUE_JETTON,cmddata)

	-- if ret==true then showToast(self._gameView,"发送续投消息成功",1)
	-- 	else showToast(self._gameView,"发送续投消息失败",1)
	-- end

end

--切换下注大小按钮消息
function GameLayer:OnNoteSwitch(sender)
	if self.m_cbGameStatus~=cmd.GS_PLACE_JETTON then
		return
	end
	self.m_nCurrentNote=sender.m_noteNum
end

return GameLayer