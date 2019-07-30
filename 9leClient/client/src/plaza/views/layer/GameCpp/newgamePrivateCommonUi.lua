module("NewGamePrivateCommonUi", package.seeall)

local newGamePrivateCommonUi = {
    
	mLayer_UI = nil,
    m_MaxPlayer = 0,
	m_KindId =0,
    m_Player = {},
	m_RoomID = 0,
    m_playCout = 0,

	--按钮合集
	mBtn_mLayer_invitefriend = nil,

    nBtn_mLayer_huatong =nil,
    
    
    --房间信息
    mLayer_gameInfoLayer = nil,
    mText_gameInfoLayer_roomid = nil,
    mText_gameInfoLayer_playcount =nil,
    mText_gameInfoLayer_gametotal = nil,
 
    --语音按钮
	mBtn_mLayer_yunyin = nil,
	--语音显示
	mLayer_yunyinLayer = nil,
    
    
    
    --房间解散
    mLayer_dissolveroomLayer = nil,
    mBtn_dissolveroomLayer_agreen = nil,
    mBtn_dissolveroomLayer_refuse = nil,
     
    --总的结束
    mLayer_gameEndLayer = nil,
    mBtn_gameEndLayer_back = nil,
    mBtn_gameEndLayer_jixu  = nil,
    mBtn_gameEndLayer_share = nil,
	mText_gameEndLayer_gamename  = nil,
	mText_gameEndLayer_roomid = nil,
	mText_gameEndLayer_playcount = nil,
	mText_gameEndLayer_endtime  = nil,
	mText_gameEndLayer_time = nil,
	m_bIsShowHead = false,
    
    m_gameScene = nil,
    m_shareSprite = nil,
       
    
}

function newGamePrivateCommonUi:create()
	
	local instance = {}

	setmetatable(instance, self)
	self.__index = self	
    self.mLayer_UI = DSBaseLayer.initWithJsonFile("newgameprivatecommonUi","newgameprivatecommonUiLayer.json")
	
    --按钮合集
    --邀请好友
    self.mBtn_mLayer_invitefriend = self.mLayer_UI:seekWidgetByNameOfRoot("btn_yaoqing")
    --话筒按钮
    self.nBtn_mLayer_huatong = self.mLayer_UI:seekWidgetByNameOfRoot("btn_huatong")
    
    
    --房间信息
    self.mLayer_gameInfoLayer = self.mLayer_UI:seekWidgetByNameOfRoot("game_ifno")
    --房间id
	self.mText_gameInfoLayer_roomid = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_gameInfoLayer, "RoomID")
    --已经玩的居数
	self.mText_gameInfoLayer_playcount = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_gameInfoLayer, "play_count")
    --总的居数
    self.mText_gameInfoLayer_gametotal = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_gameInfoLayer, "game_total")

    
    
    --解散房间
    self.mLayer_dissolveroomLayer = self.mLayer_UI:seekWidgetByNameOfRoot("jiesan_pannle")
    --同意解散
	self.mBtn_dissolveroomLayer_agreen = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_dissolveroomLayer, "btn_tongyi")
    --拒绝解散
	self.mBtn_dissolveroomLayer_refuse = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_dissolveroomLayer, "btn_jujuejiesan")
    
	--语音按钮
	self.mBtn_mLayer_yunyin = self.mLayer_UI:seekWidgetByNameOfRoot("btn_yun")
	--显示说话
    self.mLayer_yunyinLayer = self.mLayer_UI:seekWidgetByNameOfRoot("yunyin_panel")
	
	
    --总的结束
    self.mLayer_gameEndLayer = self.mLayer_UI:seekWidgetByNameOfRoot("game_endpanel")
    --返回按钮
	self.mBtn_gameEndLayer_back = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_gameEndLayer, "btn_back")
    --在来一局
	self.mBtn_gameEndLayer_jixu = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_gameEndLayer, "btn_jixu")
    --微信分享
    self.mBtn_gameEndLayer_share = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_gameEndLayer, "btn_share")
	--二维码
	self.m_shareSprite = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_gameEndLayer, "img_erweima")
	--游戏名字
	self.mText_gameEndLayer_gamename = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_gameEndLayer, "game_title")
	--房间号
	self.mText_gameEndLayer_roomid = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_gameEndLayer, "text_roomid")
	--对局数
	self.mText_gameEndLayer_playcount = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_gameEndLayer, "text_playcount")
	--结束时间
	self.mText_gameEndLayer_endtime = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_gameEndLayer, "text_endtime")
	--结束的时间（到分钟）
	self.mText_gameEndLayer_time = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_gameEndLayer, "text_time")
	
    
    self.m_KindId= ds.DF:shared():GetGameKindID()
	self.m_MaxPlayer= ds.DF:shared():GetGamePlayer()
	local strResourceFileName = ds.CPlatformGameConfig:shared():getValue(self.m_KindId,"game_resource")
	ds.GameScriptDataMananger:loadGameScriptData(strResourceFileName.."/gameConfig.xml")

    ds.MyNotification:getInstance():registerLuaEventCallBack("dissolveroom",NewGamePrivateCommonUi.DissolveRoomCallBack)
    ds.MyNotification:getInstance():registerLuaEventCallBack("privateroominfo",NewGamePrivateCommonUi.ShowRoomInfoCallBack)
    ds.MyNotification:getInstance():registerLuaEventCallBack("prviategameend",NewGamePrivateCommonUi.ShowPtivateGameEndCallBack)
	ds.MyNotification:getInstance():registerLuaEventCallBack("LoadProfileUrl",NewGamePrivateCommonUi.ShowPtivateWeiXinCallBackda)
   --ds.MyNotification:getInstance():registerLuaEventCallBack("SharePrivateSuccess",gamePrivateCommonUi.ShareResultSuccess)
  --ds.MyNotification:getInstance():registerLuaEventCallBack("SharePrivateFail",gamePrivateCommonUi.ShareResultFail)
    
   

	return instance
	
end

function newGamePrivateCommonUi:init()

	self.mLayer_dissolveroomLayer:setVisible(false)
	self.mLayer_gameEndLayer:setVisible(false)

	--邀请好友
   	self.mBtn_mLayer_invitefriend:addTouchEventListener(function(sender, eventType)      
		if eventType == ccui.TouchEventType.ended then
           --local index= privateInterface.privateData.CMD_GF_Private_Room_Info.bGameRuleIdex
            local rule_text =  self:getShareRuleText(privateInterface.privateData.CMD_GF_Private_Room_Info.bGameRuleIdex)
            local platforms = {ds.Define.Platform.WEIXIN}
			local  playtotal =privateInterface.privateData.CMD_GF_Private_Room_Info.dwPlayTotal

			local tRoomInfo = 
            {
            }
            
            local CGameCenterManager = ds.CGameCenterManager:Instance()
			local mCServerItem = CGameCenterManager:GetServerItem()
			if (mCServerItem == nil) then
				return false
			end
			local ServerId = mCServerItem:GetServerAttribute():getServerID()
			tRoomInfo.kindId = self.m_KindId
			tRoomInfo.serverId = ServerId
			tRoomInfo.roomId = self.m_RoomID


            local info = json.encode(tRoomInfo)
            local str = "dushiapp://?info="..info
            local data = string.urlencode(str)


			local share_title = ds.CPlatformGameConfig:shared():getValue(self.m_KindId,"game_name") 
			local share_title_str = ds.StringData:shared():stringFromKey("privateshare_title")
            local pic = ds.StringData:shared():stringFromKey("SharePicture")
            local link = ds.StringData:shared():stringFromKey("ShareLink_Room")..data
           
            share_title=share_title..share_title_str
            local text = ds.StringData:shared():stringFromKey("InviteFriend")
			local  share_text =   ds.CPlatformGameConfig:shared():getValue(self.m_KindId,"share_text") 
            text=string.format(text,tonumber(self.m_RoomID),playtotal) 
			text = text..","..share_text  
			--local str =  text.." "..share_title.." "..pic.." "..link 
			--ds.error(str)                              
            ds.MultiPlatformMgr:getInstance():OpenShare(platforms, text, share_title, pic, link, "", "", false)
 
		end
	end)
    
  
	local function  talkend()
		ds.SoundFun:Instance():ResumeBackMusic()
		if self.mLayer_yunyinLayer:isVisible() == false then
			return
		end
		
		DSScheduleMgr.unschedule("TALK_TIME")
		DSScheduleMgr.unschedule("TALK_BUTTON")			--解除定时器
		self.mLayer_yunyinLayer:setVisible(false)
		local KfileName =ds.MultiPlatformMgr:getInstance():stopSoundRecord()
		local chaird =ds.IClientKernel:get():GetMeChairID()		
		self.m_gameScene:sendTalkFile(chaird,KfileName)
	end
	
    
	--语音按钮
	self.mBtn_mLayer_yunyin:addTouchEventListener(function(sender, eventType)      
	--[[if eventType == ccui.TouchEventType.began then
			if self.mLayer_yunyinLayer:isVisible() == true then			
				ds.MultiPlatformMgr:getInstance():stopSoundRecord()
				self.mLayer_yunyinLayer:setVisible(false)
				return
			end
			
			ds.SoundFun:Instance():PauseBackMusic()
			self.mLayer_yunyinLayer:setVisible(true)
			ds.MultiPlatformMgr:getInstance():startSoundRecord()
				
			local function OutTimeLogic()
				talkend()
			end
			DSScheduleMgr.scheduleOnce(OutTimeLogic,5.0, "TALK_TIME");		
		end
		if eventType == ccui.TouchEventType.ended then
			talkend()
		end --]]
		
		if eventType == ccui.TouchEventType.began then
			if self.mLayer_yunyinLayer:isVisible() == true then			
				ds.MultiPlatformMgr:getInstance():stopSoundRecord()
				self.mLayer_yunyinLayer:setVisible(false)
				return
			end
			local function OutTimeLogic()
				talkend()
			end
			self.sendvoice = false 
			local function yuyinExecute()		--设置话筒定时器函数				
					self.sendvoice = true

			end	
			ds.SoundFun:Instance():PauseBackMusic()
			self.mLayer_yunyinLayer:setVisible(true)
			ds.MultiPlatformMgr:getInstance():startSoundRecord()

			DSScheduleMgr.scheduleOnce(yuyinExecute,1.0, "TALK_BUTTON");	
			DSScheduleMgr.scheduleOnce(OutTimeLogic,5.0, "TALK_TIME");	

		end
		if eventType == ccui.TouchEventType.ended then 
			--self.biff = self.over - self.begin
			if self.sendvoice == true then
				talkend()
				
			else 
				ds.SoundFun:Instance():ResumeBackMusic()
				self.mLayer_yunyinLayer:setVisible(false)
				local str = ds.StringData:shared():stringFromKey("short_talk")
                DSDialogLayer.create(ds.Dialog.Type.NONEBUTTON, str)
				ds.MultiPlatformMgr:getInstance():stopSoundRecord()
				DSScheduleMgr.unschedule("TALK_BUTTON")			--解除定时器	
				DSScheduleMgr.unschedule("TALK_TIME")			
			end

		end  
	end)
	
	
	
  
     --房间解散
    --同意解散按钮
  	self.mBtn_dissolveroomLayer_agreen:addTouchEventListener(function(sender, eventType)      
		if eventType == ccui.TouchEventType.ended then
	        
            local text = ds.StringData:shared():stringFromKey("dissolveroom")
         
			DSDialogLayer.create(ds.Dialog.Type.AFFIRMANDCANCEL,text, nil,nil, nil, function()
                local bDismiss = 1
                privateInterface.SenddissolveroomMsg(bDismiss) 
	        end,true,"","")        
		end
	end)
     
    --拒绝解散
    self.mBtn_dissolveroomLayer_refuse:addTouchEventListener(function(sender, eventType)      
		if eventType == ccui.TouchEventType.ended then
	        
            local bDismiss = 0
            privateInterface.SenddissolveroomMsg(bDismiss)        
		end
	end)
    

    --结算界面返回
    self.mBtn_gameEndLayer_back:addTouchEventListener(function(sender, eventType)      
		if eventType == ccui.TouchEventType.ended then
	        
			local bSuccess = false
		    if ds.IServerItem:get() ~= nil then
				bSuccess = ds.IServerItem:get():SendSocketData( ds.GameServer.MDM_GR_USER, ds.GameServer.SUB_GR_USER_REQUEST_QUIT)
			end
			--添加下面的语句，是当客户端不能联网时，关闭不了游戏
			if false == bSuccess and ds.IClientKernel:get() then
				ds.IClientKernel:get():Intermit(ds.Define.enGameExitCode.GameExitCode_Normal)
			end
		end
	end)
	--[[
	--设置界面的返回
	self.mBtn_SettingLayer_back:addTouchEventListener(function(sender, eventType)      
		if eventType == ccui.TouchEventType.ended then
			local bSuccess = false
		    if ds.IServerItem:get() ~= nil then
				bSuccess = ds.IServerItem:get():SendSocketData(ds.GameServer.MDM_GR_USER, ds.GameServer.SUB_GR_USER_REQUEST_QUIT)
			end
			--添加下面的语句，是当客户端不能联网时，关闭不了游戏
			if false == bSuccess and ds.IClientKernel:get() then
				ds.IClientKernel:get():Intermit(ds.Define.enGameExitCode.GameExitCode_Normal)
			end
			
		end
	end)--]]
	
    --结算界面在来一局
    self.mBtn_gameEndLayer_jixu:addTouchEventListener(function(sender, eventType)      
		if eventType == ccui.TouchEventType.ended then
			local bSuccess = false
		    if ds.IServerItem:get() ~= nil then
				bSuccess = ds.IServerItem:get():SendSocketData(ds.GameServer.MDM_GR_USER, ds.GameServer.SUB_GR_USER_REQUEST_QUIT)
			end
			--添加下面的语句，是当客户端不能联网时，关闭不了游戏
			if false == bSuccess and ds.IClientKernel:get() then
				ds.IClientKernel:get():Intermit(ds.Define.enGameExitCode.GameExitCode_Normal)
			end
		end
	end)
    --结算界面的分享
    self.mBtn_gameEndLayer_share:addTouchEventListener(function(sender, eventType)      
		if eventType == ccui.TouchEventType.ended then
            local laodPath = ""
            local targetPlatform = cc.Application:getInstance():getTargetPlatform()
            if (targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD) then
                laodPath = "PrivateEndShare.png"
            elseif(targetPlatform == cc.PLATFORM_OS_ANDROID) then
                laodPath = "/sdcard/PrivateEndShare.png"
            end
            if (laodPath ~= "") then
				self.mBtn_gameEndLayer_jixu:setVisible(false)
				self.mBtn_gameEndLayer_share:setVisible(false)
				self.m_shareSprite:setVisible(true)

                local function afterCaptured(succeed, outputFile)
                    if(self ~= nil ) then
						if succeed then
							if (self.mBtn_gameEndLayer_jixu ~= nil ) then 
								self.mBtn_gameEndLayer_jixu:setVisible(true)
							end
							if( self.mBtn_gameEndLayer_share ~= nil ) then 
								self.mBtn_gameEndLayer_share:setVisible(true)
							end
							if( self.m_shareSprite ~= nil ) then 
								self.m_shareSprite:setVisible(false)
							end
							local text = ds.StringData:shared():stringFromKey("ShareContentTxt")
							local title = ds.StringData:shared():stringFromKey("ShareTitleTxt")
							local platforms = {}
							table.insert(platforms,ds.Define.Platform.WEIXIN)
							table.insert(platforms,ds.Define.Platform.WEIXIN_CIRCLE)
							ds.MultiPlatformMgr:getInstance():OpenShare(platforms, text,title,outputFile,"","SharePrivateSuccess", "SharePrivateFail")
						else
							ds.log("Capture screen failed.")
						end
					end
                end
                cc.utils:captureScreen(afterCaptured, laodPath)
            end        
		end
	end)

end

--房间解散界面
function newGamePrivateCommonUi:DissolveRoomView(data)
    
    local dwDissUserCout =data:getData1()
    local dwNotAgreeUserCout = data:getData2()
	
	self.mBtn_dissolveroomLayer_agreen:setVisible(true)
    self.mBtn_dissolveroomLayer_refuse:setVisible(true)

    if dwDissUserCout == 0 then
		local function setVisiblethis()
			
			self.mLayer_dissolveroomLayer:setVisible(false)
		end
		self.mBtn_dissolveroomLayer_agreen:setVisible(false)
        self.mBtn_dissolveroomLayer_refuse:setVisible(false) 
		self.mLayer_dissolveroomLayer:runAction(cc.Sequence:create(cc.DelayTime:create(3.0), cc.CallFunc:create(setVisiblethis)))
        return
    end
    local kChairID ={1,1,1,1}
    
    for i=0, dwDissUserCout-1 do
        local DissChairID= privateInterface.privateData.CMD_GF_Private_Dismiss_Info.dwDissChairID[i]
        if DissChairID == ds.IClientKernel:get():GetMeChairID() then
            self.mBtn_dissolveroomLayer_agreen:setVisible(false)
            self.mBtn_dissolveroomLayer_refuse:setVisible(false)    
        end
        local playername =string.format("player%d_name",DissChairID+1)
        local palyernaemWidget = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_dissolveroomLayer,playername)
		palyernaemWidget:setVisible(true)
		local playerDissPrivateState = string.format("player%d_DissPrivateState",DissChairID+1)
		local text_DissPrivateState = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_dissolveroomLayer,playerDissPrivateState)
		text_DissPrivateState:setVisible(true)
        kChairID[DissChairID+1]=0
        if self.m_Player[DissChairID] ~= nil then
            local kName = self.m_Player[DissChairID]:GetNickName()
            palyernaemWidget:setString(kName)
            local  str_agreen = ds.StringData:shared():stringFromKey("agreen_text")
            text_DissPrivateState:setString(str_agreen)
        end    
    end
    
    for i=0, dwNotAgreeUserCout-1 do
        local NotAgreeChairID= privateInterface.privateData.CMD_GF_Private_Dismiss_Info.dwNotAgreeChairID[i]
		if NotAgreeChairID == ds.IClientKernel:get():GetMeChairID() then
            self.mBtn_dissolveroomLayer_agreen:setVisible(false)
            self.mBtn_dissolveroomLayer_refuse:setVisible(false)    
        end
        local playername =string.format("player%d_name",NotAgreeChairID+1)
        local palyernaemWidget = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_dissolveroomLayer,playername)
		palyernaemWidget:setVisible(true)
		local playerDissPrivateState = string.format("player%d_DissPrivateState",NotAgreeChairID+1)
		local text_DissPrivateState = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_dissolveroomLayer,playerDissPrivateState)
		text_DissPrivateState:setVisible(true)
		kChairID[NotAgreeChairID+1]=0
        
        if self.m_Player[NotAgreeChairID]~= nil then
            local kName = self.m_Player[NotAgreeChairID]:GetNickName()
            palyernaemWidget:setString(kName)
            local str_notagreen = ds.StringData:shared():stringFromKey("notagreen_text")
            text_DissPrivateState:setString(str_notagreen)
			text_DissPrivateState:setVisible(true)
        end    
    end
    
    for i=0,self.m_MaxPlayer -1 do
		
		if kChairID[i+1] == 1 then
			local playername =string.format("player%d_name",i+1)
            local palyernaemWidget = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_dissolveroomLayer,playername)
			palyernaemWidget:setVisible(true)
          	local playerDissPrivateState = string.format("player%d_DissPrivateState",i+1)
			local text_DissPrivateState = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_dissolveroomLayer,playerDissPrivateState)
            text_DissPrivateState:setVisible(true)
			if self.m_Player[i] ~= nil then
                local kName = self.m_Player[i]:GetNickName()
                palyernaemWidget:setString(kName)
				text_DissPrivateState:setString("") 
            end
		end
    end
	if self.m_MaxPlayer == 3 then
		local playername =string.format("player%d_name",4)
        local palyernaemWidget = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_dissolveroomLayer,playername)	
		palyernaemWidget:setVisible(false)
		local playerDissPrivateState = string.format("player%d_DissPrivateState",4)
		local text_DissPrivateState = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_dissolveroomLayer,playerDissPrivateState)
        text_DissPrivateState:setVisible(false)
	end
	
	if ds.IClientKernel:get():GetGameStatus() >= ds.Define.GAME_STATUS_PLAY or self.m_playCout >=1 then
		self.mLayer_dissolveroomLayer:setVisible(true)
	else
		self.mLayer_dissolveroomLayer:setVisible(false)	
	end
end


--显示房间信息
function newGamePrivateCommonUi:ShowRoomInfoView(RoomID,PlayCout,PlayTotal)

	self.m_RoomID = RoomID
	self.m_playCout = PlayCout
    self.mLayer_gameInfoLayer:setVisible(true)
    self.mText_gameInfoLayer_roomid:setString(tostring(RoomID))
    self.mText_gameInfoLayer_playcount:setString(tostring(self.m_playCout))
    self.mText_gameInfoLayer_gametotal:setString(tostring(PlayTotal))
	local pGlobalUserInfo = ds.CGlobalUserInfo:GetInstance()
	
	if self.m_playCout>=1 then
		self.mBtn_mLayer_invitefriend:setVisible(false)
	end
  
end

--显示房卡房间总的结束
function  newGamePrivateCommonUi:ShowPtivateGameEnd(data)
    if self.mLayer_gameEndLayer:isVisible() == true then
        return   
    end
    --最大游戏人数	
	ds.log(ds.common.GetTableLenth(privateInterface.privateData.CMD_GF_Private_End_Info.lPlayerWinLose)) 
	ds.log(self.m_MaxPlayer)
	ds.log(ds.common.GetTableLenth(privateInterface.privateData.CMD_GF_Private_End_Info.lPlayerAction))

	if(ds.common.GetTableLenth(privateInterface.privateData.CMD_GF_Private_End_Info.lPlayerWinLose) ~= self.m_MaxPlayer or 
		ds.common.GetTableLenth(privateInterface.privateData.CMD_GF_Private_End_Info.lPlayerAction) ~=self.m_MaxPlayer*privateInterface.privateData.MAX_PRIVATE_ACTION) then
		
        ds.log("lPlayerWinLose.size() != MAX_PLAYER")
        return 
    end
	local str_game = ds.CPlatformGameConfig:shared():getValue(self.m_KindId,"game_name")
	self.m_shareSprite:setVisible(false)
	self.mText_gameEndLayer_gamename:setString(str_game)
	self.mText_gameEndLayer_roomid:setString(tostring(self.m_RoomID))
	self.mText_gameEndLayer_playcount:setString(tostring(self.m_playCout))
	local str_endtime = tostring(data:getData1()).."-"..tostring(data:getData2()).."-"..tostring(data:getData3())
	self.mText_gameEndLayer_endtime:setString(str_endtime)
	local Time =  ds.CoTimer:getGameWorldTimeStr()
	self.mText_gameEndLayer_time:setString(Time)
	
    
    for i=0, self.m_MaxPlayer-1 do
        if (self.m_Player[i]~= nil) then
      
            local iChairID  = self.m_Player[i]:GetChairID()
            local Player = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_gameEndLayer,"player")
			local PrivateEndPlayer=Player:clone()
            local player_icon = self.mLayer_UI:seekWidgetByNodeName(PrivateEndPlayer,"img_icon")
			local pGlobalUserInfo =  ds.CGlobalUserInfo:GetInstance()
			local str = self.m_Player[i]:GetProfileUrl()
			if( str ~="0") then
				self.m_bIsShowHead = true    
				local pimagicDownManager = ds.ImagicDownManager:GetInstance() 
				local  icon_str = pimagicDownManager:addDown(0,str,self.m_Player[i]:GetUserID())
				if icon_str ~="" then
					local Size = player_icon:getContentSize()  
					local fx =Size.width
					local fy =Size.height
					player_icon:loadTexture(icon_str)
					fScaleX = fx/player_icon:getContentSize().width;
					fScaleY = fy/player_icon:getContentSize().height;
					player_icon:setScaleX(fScaleX);
					player_icon:setScaleY(fScaleY);
					player_icon:setVisible(true)
					
				end
				
			else
				
				local Size = player_icon:getContentSize()  
				local fx =Size.width
				local fy =Size.height
				player_icon:loadTexture(ds.common.YRComGetHeadImageById(self.m_Player[i]:GetFaceID()),ccui.TextureResType.plistType)
				fScaleX = fx/player_icon:getContentSize().width;
				fScaleY = fy/player_icon:getContentSize().height;
				player_icon:setScaleX(fScaleX);
				player_icon:setScaleY(fScaleY);
				player_icon:setVisible(true)
			end
			
		
 
        
            local username = self.m_Player[i]:GetNickName()
            local text_nickname =  self.mLayer_UI:seekWidgetByNodeName(PrivateEndPlayer,"text_nickname")
            text_nickname:setString(username)
			local  length = tonumber(ds.GameScriptDataMananger:getString("actionCount"))
			for j= 0,length-1 do
				local ActionTxt =string.format("img_action%d",j)
				local str_Action = string.format("img_action%d",j)
				local str_Actionfile = ds.GameScriptDataMananger:getString(ActionTxt)
				local img_Action = self.mLayer_UI:seekWidgetByNodeName(PrivateEndPlayer,str_Action)
				img_Action:loadTexture(str_Actionfile)
				local text_action = string.format("text_action%d",j) 
				local text_ActionTxt = self.mLayer_UI:seekWidgetByNodeName(img_Action,text_action)
				local str ="X"..tostring(privateInterface.privateData.CMD_GF_Private_End_Info.lPlayerAction[iChairID*privateInterface.privateData.MAX_PRIVATE_ACTION+j])
				text_ActionTxt:setString(str) 
			end
			if length <4 then
				local str_Action = string.format("img_action%d",length)
				local img_Action = self.mLayer_UI:seekWidgetByNodeName(PrivateEndPlayer,str_Action)
				img_Action:setVisible(false)
			end
            local TotalScore =self.mLayer_UI:seekWidgetByNodeName(PrivateEndPlayer,"text_zongjifen")
            TotalScore:setString(privateInterface.privateData.CMD_GF_Private_End_Info.lPlayerWinLose[iChairID])
            local img_fangzhu =self.mLayer_UI:seekWidgetByNodeName(PrivateEndPlayer,"img_fangzhu")
            if self.m_Player[i]:GetUserID() ==privateInterface.privateData.CMD_GF_Private_Room_Info.dwCreateUserID then
            
                img_fangzhu:setVisible(true)
		    else
                img_fangzhu:setVisible(false)    
            end
				local str_flag_point =string.format("flag_point_%d",self.m_MaxPlayer)
				local flag_point = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_gameEndLayer,str_flag_point)
				local str_flag_point_player = string.format("flag_player%d",i+1)
				local flag_point_player = self.mLayer_UI:seekWidgetByNodeName(flag_point,str_flag_point_player)
				flag_point_player:addChild(PrivateEndPlayer)
				PrivateEndPlayer:setPosition(ccp(0,0))
			end
		
    end
	
	
	DSScheduleMgr.unschedule("UPDATAPTIVATEHEAD");
	local function UpdataPrivateHead()
		for i=0, self.m_MaxPlayer-1 do
			if (self.m_Player[i]~= nil) then
				local str = self.m_Player[i]:GetProfileUrl()
				local userid = self.m_Player[i]:GetUserID()
				self.m_bIsShowHead = true    
				local pimagicDownManager = ds.ImagicDownManager:GetInstance() 
				local  icon_str = pimagicDownManager:addDown(0,str,self.m_Player[i]:GetUserID())
				if icon_str ~="" then
					self:ShowWeiXinHead(userid,icon_str)
				end
			end
		end	
    end
DSScheduleMgr.scheduleOnce(UpdataPrivateHead,3,"UPDATAPTIVATEHEAD")
			
		
end


function newGamePrivateCommonUi:getShareRuleText(ruleindex)
	
    local rule_text = "" 
	  
    if ds.LuaBitLib:bAnd(ruleindex,ds.LuaBitLib:lShift(1,1)) ~= 0 then
        
		rule_text = rule_text.. ds.GameScriptDataMananger:getString("NCRule1").." ";
    end
    if ds.LuaBitLib:bAnd(ruleindex,ds.LuaBitLib:lShift(1,6))~=0 then
        
		rule_text = rule_text.. ds.GameScriptDataMananger:getString("NCRule6").." ";
    end
    if ds.LuaBitLib:bAnd(ruleindex,ds.LuaBitLib:lShift(1,7))~=0 then
        
		rule_text = rule_text.. ds.GameScriptDataMananger:getString("NCRule7").." ";
    end
    if ds.LuaBitLib:bAnd(ruleindex,ds.LuaBitLib:lShift(1,8))~=0 then
        
		rule_text = rule_text.. ds.GameScriptDataMananger:getString("NCRule8").." ";
    end
    if ds.LuaBitLib:bAnd(ruleindex,ds.LuaBitLib:lShift(1,9))~=0 then
        
		rule_text = rule_text.. ds.GameScriptDataMananger:getString("NCRule9").." ";
    end
    if ds.LuaBitLib:bAnd(ruleindex,ds.LuaBitLib:lShift(1,10))~=0 then
        
		rule_text = rule_text.. ds.GameScriptDataMananger:getString("NCRule10").." ";
    end
    if ds.LuaBitLib:bAnd(ruleindex,ds.LuaBitLib:lShift(1,11))~=0 then
        
		rule_text = rule_text.. ds.GameScriptDataMananger:getString("NCRule11").." ";
    end
    if ds.LuaBitLib:bAnd(ruleindex,ds.LuaBitLib:lShift(1,12))~=0 then
        
		rule_text = rule_text.. ds.GameScriptDataMananger:getString("NCRule12").." ";
    end
    if ds.LuaBitLib:bAnd(ruleindex,ds.LuaBitLib:lShift(1,13))~=0 then
        
		rule_text = rule_text.. ds.GameScriptDataMananger:getString("NCRule13").." ";
    end
    if ds.LuaBitLib:bAnd(ruleindex,ds.LuaBitLib:lShift(1,14))~=0 then
        
		rule_text = rule_text.. ds.GameScriptDataMananger:getString("NCRule14").." ";
    end
    if ds.LuaBitLib:bAnd(ruleindex,ds.LuaBitLib:lShift(1,16))~=0 then
        
		rule_text = rule_text.. ds.GameScriptDataMananger:getString("NCRule16").." ";
    end
    if ds.LuaBitLib:bAnd(ruleindex,ds.LuaBitLib:lShift(1,2))~=0 then
        
		rule_text = rule_text.. ds.GameScriptDataMananger:getString("NCRule2").." ";
    end
    if ds.LuaBitLib:bAnd(ruleindex,ds.LuaBitLib:lShift(1,3))~=0 then
        
		rule_text = rule_text.. ds.GameScriptDataMananger:getString("NCRule3").." ";
    end
    if ds.LuaBitLib:bAnd(ruleindex,ds.LuaBitLib:lShift(1,4))~=0 then
        
		rule_text = rule_text.. ds.GameScriptDataMananger:getString("NCRule4").." ";
    end
	if ds.LuaBitLib:bAnd(ruleindex,ds.LuaBitLib:lShift(1,5))~=0 then
        
		rule_text = rule_text.. ds.GameScriptDataMananger:getString("NCRule5").." ";
    end
	if ds.LuaBitLib:bAnd(ruleindex,ds.LuaBitLib:lShift(1,15))~=0 then
        
		rule_text = rule_text.. ds.GameScriptDataMananger:getString("NCRule15").." ";
    end
    return rule_text
    
end


--玩家进入
function newGamePrivateCommonUi:OnEventUserEnter(pIClientUserItem,bLookonUser)
    if bLookonUser == true then
		return
	end    
    local length = ds.common.GetTableLenth(self.m_Player) 
    local chairid  = pIClientUserItem:GetChairID()  
    self.m_Player[chairid] = pIClientUserItem
end

--玩家离开
function newGamePrivateCommonUi:OnEventUserLeave(pIClientUserItem,bLookonUser)

	if bLookonUser == true then
		return
	end
	local chairid  = pIClientUserItem:GetChairID()
    self.m_Player[chairid] = nil 
end

--分享游戏截图返回
function newGamePrivateCommonUi:ShareResult()
   --待定
  

end

function newGamePrivateCommonUi:ShowPrivateEndLayerView()
	
	self.mLayer_gameEndLayer:setVisible(true)
end


--共同ui销毁
function newGamePrivateCommonUi:Destroy()
	
	ds.MyNotification:getInstance():unRegisterEventListener("dissolveroom")
    ds.MyNotification:getInstance():unRegisterEventListener("privateroominfo")
    ds.MyNotification:getInstance():unRegisterEventListener("prviategameend")
	ds.MyNotification:getInstance():unRegisterEventListener("LoadProfileUrl")
	DSScheduleMgr.unschedule("UPDATAPTIVATEHEAD");
    --ds.MyNotification:getInstance():unRegisterEventListener("SharePrivateSuccess")
	--ds.MyNotification:getInstance():unRegisterEventListener("SharePrivateFail")
    self.mLayer_UI:stopAllActions()
	self.mLayer_UI:Close()
	ds.newgameprivatecommonUi = nil  
end





function newGamePrivateCommonUi:OnReconnectResumeGame()
	
	if ds.IClientKernel:get():GetGameStatus() >= ds.Define.GAME_STATUS_PLAY or self.m_playCout>=1 then
		self.mBtn_mLayer_invitefriend:setVisible(false)
	else
		self.mBtn_mLayer_invitefriend:setVisible(true)	
	end
	self.mLayer_dissolveroomLayer:setVisible(false)

end

function newGamePrivateCommonUi:ShowWeiXinHead(userid,StrSavePath)
	
	if self.m_bIsShowHead == false then
		return
	end
	for i=0, self.m_MaxPlayer-1 do
        if (self.m_Player[i]~= nil) then
      
            local iChairID  = self.m_Player[i]:GetChairID()
            local str_PrivateEndPlayer =string.format("player%d",iChairID+1)
            local PrivateEndPlayer = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_gameEndLayer,str_PrivateEndPlayer)
            local player_icon = self.mLayer_UI:seekWidgetByNodeName(PrivateEndPlayer,"icon")
			if( player_icon ~= nil ) then  
				if  self.m_Player[i]:GetUserID() == userid then
					local Size = player_icon:getContentSize()  
					local fx =Size.width
					local fy =Size.height
					player_icon:loadTexture(StrSavePath)
					fScaleX = fx/player_icon:getContentSize().width;
					fScaleY = fy/player_icon:getContentSize().height;
					player_icon:setScaleX(fScaleX);
					player_icon:setScaleY(fScaleY);
					player_icon:setVisible(true)
					player_icon:loadTexture(StrSavePath)
				end
			end
		end
	end
end

--创建函数
function create(mgamescene)
	local gameprivatecommonUiLayer = newGamePrivateCommonUi:create()
	gameprivatecommonUiLayer.m_gameScene = mgamescene
	gameprivatecommonUiLayer:init()
	return gameprivatecommonUiLayer
end

function ShareResultSuccess(data)
	self:ShareResult()
end

function ShareResultFail(data)
	self:ShareResult()
end


function DissolveRoomCallBack(data)
	
	if ds.newgameprivatecommonUi ~= nil then
		ds.newgameprivatecommonUi:DissolveRoomView(data)	
	end
	
end
function ShowRoomInfoCallBack(data)
	if ds.newgameprivatecommonUi ~= nil then
		ds.newgameprivatecommonUi:ShowRoomInfoView(data:getData1(),data:getData2(),data:getData3())	
	end
end
function ShowPtivateGameEndCallBack(data)
	
	if ds.newgameprivatecommonUi ~= nil then
		ds.newgameprivatecommonUi:ShowPtivateGameEnd(data)
	end
	
end
function ShowPtivateWeiXinCallBackda(data)
	
	if ds.newgameprivatecommonUi ~= nil then
		ds.newgameprivatecommonUi:ShowWeiXinHead(data:getData2(),data:getStr1())
	end
	
end




