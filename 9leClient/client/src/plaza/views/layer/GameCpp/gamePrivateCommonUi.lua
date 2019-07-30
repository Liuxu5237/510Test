module("GamePrivateCommonUi", package.seeall)

local gamePrivateCommonUi = {
    
	mLayer_UI = nil,
    m_MaxPlayer = 0,
	m_KindId =0,
    m_Player = {},
	m_RoomID = 0,
    m_playCout = 0,
  
	--音乐设置界面
    mLayer_SettingLayer = nil,
	mBtn_SettingLayer_Close = nil,
    mSld_SettingLayer_GameSlider = nil,
    mSld_SettingLayer_PlaySlider = nil,
	mBtn_SettingLayer_dissolveroom  = nil,
	mBtn_SettingLayer_back = nil,
    m_bIsshowSet = false,
    
    
    
	  
	--按钮合集
	mBtn_mLayer_invitefriend = nil,
	mBtn_mLayer_set = nil,
    nBtn_mLayer_huatong =nil,
    
    
    --房间信息
    mLayer_gameInfoLayer = nil,
    mText_gameInfoLayer_roomid = nil,
    mText_gameInfoLayer_playcount =nil,
    mText_gameInfoLayer_gametotal = nil,
    mText_gameInfoLayer_gamename = nil,
    
    
    
    --房间解散
    mLayer_dissolveroomLayer = nil,
    mBtn_dissolveroomLayer_agreen = nil,
    mBtn_dissolveroomLayer_refuse = nil,
     
    --总的结束
    mLayer_gameEndLayer = nil,
    mBtn_gameEndLayer_back = nil,
    mBtn_gameEndLayer_jixu  = nil,
    mBtn_gameEndLayer_share = nil,
	m_bIsShowHead = false,
    
    
    m_shareSprite = nil,
       
    
}

function gamePrivateCommonUi:create()
	
	local instance = {}

	setmetatable(instance, self)
	self.__index = self	
    self.mLayer_UI = DSBaseLayer.initWithJsonFile("gameprivatecommonUi","gameprivatecommonUiLayer.json")
	
	--音乐设置界面
    self.mLayer_SettingLayer = self.mLayer_UI:seekWidgetByNameOfRoot("setting_pannel")
    --背景
	self.mSettingLayer_BgWidget = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_SettingLayer, "bg_widget")
    --关闭按钮
	self.mBtn_SettingLayer_Close = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_SettingLayer, "btn_close")
    --背景音乐滑动条
    self.mSld_SettingLayer_GameSlider = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_SettingLayer, "game_slider")
    --游戏音效滑动条
	self.mSld_SettingLayer_PlaySlider = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_SettingLayer, "play_slidr")
    --解散按钮
    self.mBtn_SettingLayer_dissolveroom =self.mLayer_UI:seekWidgetByNodeName(self.mLayer_SettingLayer, "btn_jiesan")
	--返回大厅的按钮
	self.mBtn_SettingLayer_back =self.mLayer_UI:seekWidgetByNodeName(self.mLayer_SettingLayer, "btn_back")
    
    --按钮合集
    --设置按钮
    self.mBtn_mLayer_set = self.mLayer_UI:seekWidgetByNameOfRoot("btn_set")
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
    --游戏名字
	self.mText_gameInfoLayer_gamename = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_gameInfoLayer, "game_name")
    
    
    --解散房间
    self.mLayer_dissolveroomLayer = self.mLayer_UI:seekWidgetByNameOfRoot("jiesan_pannle")
    --同意解散
	self.mBtn_dissolveroomLayer_agreen = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_dissolveroomLayer, "btn_tongyi")
    --拒绝解散
	self.mBtn_dissolveroomLayer_refuse = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_dissolveroomLayer, "btn_jujuejiesan")
    
    
    
    --总的结束
    self.mLayer_gameEndLayer = self.mLayer_UI:seekWidgetByNameOfRoot("game_endpannel")
    --返回按钮
	self.mBtn_gameEndLayer_back = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_gameEndLayer, "btn_back")
    --在来一局
	self.mBtn_gameEndLayer_jixu = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_gameEndLayer, "btn_jixu")
    --微信分享
    self.mBtn_gameEndLayer_share = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_gameEndLayer, "btn_share")
    
    self.m_KindId= ds.DF:shared():GetGameKindID()
	self.m_MaxPlayer= ds.DF:shared():GetGamePlayer()
	local strResourceFileName = ds.CPlatformGameConfig:shared():getValue(self.m_KindId,"game_resource")
	ds.GameScriptDataMananger:loadGameScriptData(strResourceFileName.."/gameConfig.xml")

    ds.MyNotification:getInstance():registerLuaEventCallBack("dissolveroom",GamePrivateCommonUi.DissolveRoomCallBack)
    ds.MyNotification:getInstance():registerLuaEventCallBack("privateroominfo",GamePrivateCommonUi.ShowRoomInfoCallBack)
    ds.MyNotification:getInstance():registerLuaEventCallBack("prviategameendmajiang",GamePrivateCommonUi.ShowPrivateGameEndCallBack)
	ds.MyNotification:getInstance():registerLuaEventCallBack("LoadProfileUrl",GamePrivateCommonUi.ShowPrivateWeiXinCallBackda)
    ds.MyNotification:getInstance():registerLuaEventCallBack("ShowLuaJieSuan",GamePrivateCommonUi.ShowPrivateEndLayer)
  --ds.MyNotification:getInstance():registerLuaEventCallBack("SharePrivateFail",gamePrivateCommonUi.ShareResultFail)
    
   

	return instance
	
end

function gamePrivateCommonUi:init()
	
	self.mLayer_SettingLayer:setVisible(false)
	self.mLayer_dissolveroomLayer:setVisible(false)
	self.mLayer_gameEndLayer:setVisible(false)

 
        
	--邀请好友
   	self.mBtn_mLayer_invitefriend:addTouchEventListener(function(sender, eventType)      
		if eventType == ccui.TouchEventType.ended then
           --local index= privateInterface.privateData.CMD_GF_Private_Room_Info.bGameRuleIdex
            local rule_text =  self:getShareRuleText(privateInterface.privateData.CMD_GF_Private_Room_Info.bGameRuleIdex)
            local   playtotal =privateInterface.privateData.CMD_GF_Private_Room_Info.dwPlayTotal
            
            local platforms = {ds.Define.Platform.WEIXIN,ds.Define.Platform.WEIXIN_CIRCLE}


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
            local pic = ds.StringData:shared():stringFromKey("SharePicture")
            local link = ds.StringData:shared():stringFromKey("ShareLink_Room")..data
           
            share_title=share_title.."-"..tostring(self.m_RoomID) 
            local text = ds.StringData:shared():stringFromKey("InviteFriend")
            text=string.format(text,tonumber(self.m_RoomID),playtotal)   
			--local str =  text.." "..share_title.." "..pic.." "..link 
			--ds.error(str)                              
            ds.MultiPlatformMgr:getInstance():OpenShare(platforms, text, share_title, pic, link, "", "", false)
 
		end
	end)
    
   --音乐设置按钮
  	self.mBtn_mLayer_set:addTouchEventListener(function(sender, eventType)      
		if eventType == ccui.TouchEventType.ended then
			if ds.IClientKernel:get()~= nil then
				
				if ds.IClientKernel:get():GetGameStatus() >= ds.Define.GAME_STATUS_PLAY or self.m_playCout >= 1 then
					self.mBtn_SettingLayer_dissolveroom:setVisible(true)
					self.mBtn_SettingLayer_back:setVisible(false)
				end
			end
            self.mLayer_SettingLayer:setVisible(true)
		end
	end)
    
    --设置界面解散游戏按钮
    self.mBtn_SettingLayer_dissolveroom:addTouchEventListener(function(sender, eventType)      
		if eventType == ccui.TouchEventType.ended then
			
			local text = ""
            if self.m_playCout ==0 then
			    text = ds.StringData:shared():stringFromKey("dissolveroom_free")
            else
               text = ds.StringData:shared():stringFromKey("dissolveroom")
            end
			DSDialogLayer.create(ds.Dialog.Type.AFFIRMANDCANCEL,text, nil,nil, nil, function()
				
                local bDismiss = 1
                privateInterface.SenddissolveroomMsg(bDismiss) 

	        end,true,"","")        
		end
	end)
    
	--关闭设置界面
	self.mBtn_SettingLayer_Close:addTouchEventListener(function(sender, eventType)      
		if eventType == ccui.TouchEventType.ended then
			self.mLayer_SettingLayer:setVisible(false)
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
	end)
	
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
                if (self.m_shareSprite == nil) then
                    self.m_shareSprite = cc.Sprite:create("PlatForm/Global/Share.png")
                    local winSize = self.mLayer_UI:getContentSize()
                    self.m_shareSprite:setPosition(cc.p(winSize.width - 20, 20));
                    self.m_shareSprite:setAnchorPoint(cc.p(1, 0));
                    self.mLayer_UI:addChild(self.m_shareSprite)
                    self.m_shareSprite:setScale(0.1)
                end

                self.m_shareSprite:setVisible(true)
                local function afterCaptured(succeed, outputFile)
					if(self ~= nil ) then 
						if succeed then
							if (self.m_shareSprite ~= nil) then
								self.m_shareSprite:removeFromParent()
								self.m_shareSprite = nil
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
function gamePrivateCommonUi:DissolveRoomView(data)
    
    local dwDissUserCout =data:getData1()
    local dwNotAgreeUserCout = data:getData2()
    self.mLayer_SettingLayer:setVisible(false)
	
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
        kChairID[DissChairID+1]=0
        if self.m_Player[DissChairID] ~= nil then
            local kName = self.m_Player[DissChairID]:GetNickName()
            palyernaemWidget:setString(kName)
            local text_DissPrivateState = self.mLayer_UI:seekWidgetByNodeName(palyernaemWidget,"text_DissPrivateState")
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
        kChairID[NotAgreeChairID+1]=0
        
        if self.m_Player[NotAgreeChairID]~= nil then
            local kName = self.m_Player[NotAgreeChairID]:GetNickName()
            palyernaemWidget:setString(kName)
            local text_DissPrivateState = self.mLayer_UI:seekWidgetByNodeName(palyernaemWidget,"text_DissPrivateState")
            local str_notagreen = ds.StringData:shared():stringFromKey("notagreen_text")
            text_DissPrivateState:setString(str_notagreen)
        end    
    end
    
    for i=0,self.m_MaxPlayer -1 do
		
		if kChairID[i+1] == 1 then
			local playername =string.format("player%d_name",i+1)
            local palyernaemWidget = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_dissolveroomLayer,playername)
          
            if self.m_Player[i] ~= nil then
                local kName = self.m_Player[i]:GetNickName()
                palyernaemWidget:setString(kName)
				local text_DissPrivateState =  self.mLayer_UI:seekWidgetByNodeName(palyernaemWidget,"text_DissPrivateState")
				text_DissPrivateState:setString("") 
            end
		end
    end
	if ds.IClientKernel:get():GetGameStatus() >= ds.Define.GAME_STATUS_PLAY or self.m_playCout >=1 then
		self.mLayer_dissolveroomLayer:setVisible(true)
	else
		self.mLayer_dissolveroomLayer:setVisible(false)	
	end
end


--显示房间信息
function gamePrivateCommonUi:ShowRoomInfoView(RoomID,PlayCout,PlayTotal)

	self.m_RoomID = RoomID
	self.m_playCout = PlayCout
	local str_game = ds.CPlatformGameConfig:shared():getValue(self.m_KindId,"game_name")
    self.mLayer_gameInfoLayer:setVisible(true)
    self.mText_gameInfoLayer_roomid:setString(tostring(RoomID))
    self.mText_gameInfoLayer_playcount:setString(tostring(self.m_playCout))
    self.mText_gameInfoLayer_gametotal:setString(tostring(PlayTotal))
    self.mText_gameInfoLayer_gamename:setString(str_game)
	local pGlobalUserInfo = ds.CGlobalUserInfo:GetInstance()
	if pGlobalUserInfo:getUserID() == privateInterface.privateData.CMD_GF_Private_Room_Info.dwCreateUserID then
		self.mBtn_SettingLayer_dissolveroom:setVisible(true)
		self.mBtn_SettingLayer_back:setVisible(false)
	else
	    self.mBtn_SettingLayer_dissolveroom:setVisible(false)
		self.mBtn_SettingLayer_back:setVisible(true)
	end
	
   
end

--显示房卡房间总的结束
function  gamePrivateCommonUi:ShowPtivateGameEnd()
    if self.mLayer_gameEndLayer:isVisible() == true then
        return   
    end
    --最大游戏人数	   
	if(ds.common.GetTableLenth(privateInterface.privateData.CMD_GF_Private_End_Info.lPlayerWinLose) ~= self.m_MaxPlayer or 
		ds.common.GetTableLenth(privateInterface.privateData.CMD_GF_Private_End_Info.lPlayerAction) ~=4*privateInterface.privateData.MAX_PRIVATE_ACTION) then
		
        ds.log("lPlayerWinLose.size() != MAX_PLAYER")
        return 
    end
    
    for i=0, self.m_MaxPlayer-1 do
        if (self.m_Player[i]~= nil) then
      
            local iChairID  = self.m_Player[i]:GetChairID()
            local str_PrivateEndPlayer =string.format("player%d",iChairID+1)
            local PrivateEndPlayer = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_gameEndLayer,str_PrivateEndPlayer)
        
            local player_icon = self.mLayer_UI:seekWidgetByNodeName(PrivateEndPlayer,"icon")
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
			
		
             
            local userid = self.m_Player[i]:GetGameID()
            local text_userid = self.mLayer_UI:seekWidgetByNodeName(PrivateEndPlayer,"lab_id")
            text_userid:setString(tostring(userid))
        
            local username = self.m_Player[i]:GetNickName()
            local text_nickname =  self.mLayer_UI:seekWidgetByNodeName(PrivateEndPlayer,"lab_name")
            text_nickname:setString(username)
            for j= 0,4 do
                local ActionTxt =string.format("ActionTxt%d",j)
                local text_ActionTxt = self.mLayer_UI:seekWidgetByNodeName(PrivateEndPlayer,ActionTxt)
                local str ="X"..tostring(privateInterface.privateData.CMD_GF_Private_End_Info.lPlayerAction[iChairID*privateInterface.privateData.MAX_PRIVATE_ACTION+j])
                text_ActionTxt:setString(str)
               
            end
            local TotalScore =self.mLayer_UI:seekWidgetByNodeName(PrivateEndPlayer,"lab_score")
            TotalScore:setString(privateInterface.privateData.CMD_GF_Private_End_Info.lPlayerWinLose[iChairID])
            local img_fangzhu =self.mLayer_UI:seekWidgetByNodeName(PrivateEndPlayer,"img_fangzhu")
            if self.m_Player[i]:GetUserID() ==privateInterface.privateData.CMD_GF_Private_Room_Info.dwCreateUserID then
            
                img_fangzhu:setVisible(true)
		    else
                img_fangzhu:setVisible(false)    
            end
		end
    end
	
	
end


function gamePrivateCommonUi:getShareRuleText(ruleindex)
  
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
function gamePrivateCommonUi:OnEventUserEnter(pIClientUserItem,bLookonUser)
    if bLookonUser == true then
		return
	end    
    local length = ds.common.GetTableLenth(self.m_Player) 
    local chairid  = pIClientUserItem:GetChairID()  
    self.m_Player[chairid] = pIClientUserItem
end

--玩家离开
function gamePrivateCommonUi:OnEventUserLeave(pIClientUserItem,bLookonUser)

	if bLookonUser == true then
		return
	end
	local chairid  = pIClientUserItem:GetChairID()
    self.m_Player[chairid] = nil 
end

--分享游戏截图返回
function gamePrivateCommonUi:ShareResult()
   --待定
  

end



--共同ui销毁
function gamePrivateCommonUi:Destroy()
	
	ds.MyNotification:getInstance():unRegisterEventListener("dissolveroom")
    ds.MyNotification:getInstance():unRegisterEventListener("privateroominfo")
    ds.MyNotification:getInstance():unRegisterEventListener("prviategameendmajiang")
	ds.MyNotification:getInstance():unRegisterEventListener("LoadProfileUrl")
	ds.MyNotification:getInstance():unRegisterEventListener("ShowLuaJieSuan")
    --ds.MyNotification:getInstance():unRegisterEventListener("SharePrivateSuccess")
	--ds.MyNotification:getInstance():unRegisterEventListener("SharePrivateFail")
    self.mLayer_UI:stopAllActions()
	self.mLayer_UI:Close()
	ds.gameprivatecommonUi = nil  
end





function gamePrivateCommonUi:OnReconnectResumeGame()
	
	if ds.IClientKernel:get():GetGameStatus() >= ds.Define.GAME_STATUS_PLAY or self.m_playCout>=1 then
		self.mBtn_mLayer_invitefriend:setVisible(false)
	else
		self.mBtn_mLayer_invitefriend:setVisible(true)	
	end
 	

end

function gamePrivateCommonUi:ShowWeiXinHead(userid,StrSavePath)
	
	if self.m_bIsShowHead == false then
		return
	end
	for i=0, self.m_MaxPlayer-1 do
        if (self.m_Player[i]~= nil) then
      
            local iChairID  = self.m_Player[i]:GetChairID()
            local str_PrivateEndPlayer =string.format("player%d",iChairID+1)
            local PrivateEndPlayer = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_gameEndLayer,str_PrivateEndPlayer)
            local player_icon = self.mLayer_UI:seekWidgetByNodeName(PrivateEndPlayer,"icon")
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


function gamePrivateCommonUi:ShowPrivateEndLayerView()
	
	self.mLayer_gameEndLayer:setVisible(true)
end

--创建函数
function create()
	
	local gameprivatecommonUiLayer = gamePrivateCommonUi:create()
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
	
	if ds.gameprivatecommonUi ~= nil then
		ds.gameprivatecommonUi:DissolveRoomView(data)	
	end
	
end
function ShowRoomInfoCallBack(data)
	if ds.gameprivatecommonUi ~= nil then
		ds.gameprivatecommonUi:ShowRoomInfoView(data:getData1(),data:getData2(),data:getData3())	
	end
end
function ShowPrivateEndLayer()
	
	if ds.gameprivatecommonUi ~= nil then
		ds.gameprivatecommonUi:ShowPrivateEndLayerView()
	end
	
end
function ShowPrivateWeiXinCallBackda(data)
	
	if ds.gameprivatecommonUi ~= nil then
		ds.gameprivatecommonUi:ShowWeiXinHead(data:getData2(),data:getStr1())
	end
	
end

function ShowPrivateGameEndCallBack()
	
	if ds.gameprivatecommonUi ~= nil then
		ds.gameprivatecommonUi:ShowPtivateGameEnd()
	end
	
end
