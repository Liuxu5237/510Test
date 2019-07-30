module("GameCommonUi", package.seeall)

local gameCommonUi = {
    
	mLayer_UI = nil,
	
	--音乐设置界面
    mLayer_SettingLayer = nil,
	mSettingLayer_BgWidget = nil,
	mBtn_SettingLayer_Close = nil,
    mBtn_SettingLayer_GameMusic= nil,
    mBtn_SettingLayer_PlayMusic = nil,
	m_bSettingShow = false,
	  
	--开始游戏按钮和等待分桌的提示
	mBtn_mLayer_StartGame = nil,
	mImg_mLayer_WaitDistribute = nil,
	   
	
	--下拉按钮和下拉列表按钮集合
	mBtn_mLayer_PullDown = nil,
	mLayer_CommonBtnLayer = nil,	  	  
 	mCommonBtnLayer_BgWidget = nil,
	mBtn_CommonBtnLayer_ChangeDesk = nil, 
	mBtn_CommonBtnLayer_Recover = nil,
	mBtn_CommonBtnLayer_Setting = nil,
	mBtn_CommonBtnLayer_Rule  = nil,
	mBtn_CommonBtnLayer_Leave = nil,
	
	--语音按钮和语音列表
	mLayer_TalkLayer = nil,
    mImg_mLayer_SoundBg = nil,
	mlist_mLayer_biaoqingList = nil,
	mlist_mLayer_liaotianList = nil,
	mBtn_TalkLayer_biaoqiang = nil,
	mBtn_TalkLayer_liaotian = nil,
	
	m_bShowYuYinText = false,
	
	
	--规则弹框
	mLayer_RuleLayer = nil,
	mRuleLayer_BgWidget = nil,
    mRuleLayer_FrameInner = nil,
	mRuleLayer_WebView = nil,
	m_bShowRule = false,
	m_MaxbiaoqingList = 8,
	--炮马灯文字框
	mBgLayout = nil,
	mLabMessage = nil,
	
	--跑马灯的文字是否在运行
	m_isMove = false,
	--跑马灯文字序列
	mMessageQueue = {},

  --手机电池电量信息,信号,时间
	Lab_mlayer_Time = nil,
	Img_mLayer_Power = nil,
	Img_mLayer_Wife = nil,
	Img_mLayer_signal = nil,
	
	--个人信息的控件
	mLayer_info = nil,
	--mLab_icon = nil,
	mText_name = nil,
	mText_goldNum = nil,
	mText_yuanbaoNum = nil,
	mBtn_recharge = nil,
	mMessageBg = nil,
	mText_jifenNum = nil,
	mBiSaiResultLayer = nil,
	mText_zhanjiNum = nil,
	--服务器类型
	m_GameServerType = nil,
	m_gameScene = nil,


	mYuYinTimerID = nil,		--语音ID
}

function gameCommonUi:create()
	
	local instance = {}

	setmetatable(instance, self)
	self.__index = self	
    self.mLayer_UI = DSBaseLayer.initWithJsonFile("gameCommonUi","gameCommonUILayer.json")
	
	--音乐设置界面
    self.mLayer_SettingLayer = self.mLayer_UI:seekWidgetByNameOfRoot("setting_pannel")
	self.mSettingLayer_BgWidget = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_SettingLayer, "bg_widget")
	self.mBtn_SettingLayer_Close = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_SettingLayer, "close")
    self.mBtn_SettingLayer_GameMusic = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_SettingLayer, "game_music")
	self.mBtn_SettingLayer_PlayMusic = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_SettingLayer, "play_music")
	--个人设置界面
	self.mLayer_info = self.mLayer_UI:seekWidgetByNameOfRoot("layerInfo") 
	--self.mLab_icon = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_info,"icon")
	self.mText_name = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_info,"name")
	self.mText_goldNum = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_info,"goldNum")
	self.mText_yuanbaoNum = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_info,"yuanbaoNum")
	self.mBtn_recharge = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_info,"recharge")
	self.mText_jifenNum = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_info,"jifenNum")
	self.mText_zhanjiNum = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_info,"zhanjiNum")
	self.mBtn_recharge:setTouchEnabled(true)

	
	--开始游戏按钮和等待分桌的提示
    self.mBtn_mLayer_StartGame = self.mLayer_UI:seekWidgetByNameOfRoot("zhunbei_bn")
	self.mImg_mLayer_WaitDistribute = self.mLayer_UI:seekWidgetByNameOfRoot("wait_distribute")
	
	--下拉按钮和下拉列表按钮集合
	self.mBtn_mLayer_PullDown = self.mLayer_UI:seekWidgetByNameOfRoot("xiala_bn")
    self.mLayer_CommonBtnLayer = self.mLayer_UI:seekWidgetByNameOfRoot("button_pannel")
    self.mCommonBtnLayer_BgWidget = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_CommonBtnLayer, "bg_widget")
	self.mBtn_CommonBtnLayer_ChangeDesk =  self.mLayer_UI:seekWidgetByNodeName(self.mLayer_CommonBtnLayer, "huanzhuo_bn")
	
	self.mBtn_CommonBtnLayer_Recover = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_CommonBtnLayer, "shouqi_bn")
	self.mBtn_CommonBtnLayer_Setting = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_CommonBtnLayer, "setting_bn")
	self.mBtn_CommonBtnLayer_Leave =  self.mLayer_UI:seekWidgetByNodeName(self.mLayer_CommonBtnLayer, "back_bn")
    self.mBtn_CommonBtnLayer_Rule =  self.mLayer_UI:seekWidgetByNodeName(self.mLayer_CommonBtnLayer, "rule_bn")
	
	
	
	--语音按钮和语音列表
	self.mBtn_mLayer_Sound = self.mLayer_UI:seekWidgetByNameOfRoot("yuyin_bn")
	self.mLayer_TalkLayer = self.mLayer_UI:seekWidgetByNameOfRoot("talk_panel")
	self.mImg_mLayer_SoundBg = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_TalkLayer,"bg_widget")
	self.mlist_mLayer_biaoqingList = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_TalkLayer, "list_biaoqing")
	self.mlist_mLayer_liaotianList = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_TalkLayer, "list_changyunyu")
	self.mBtn_TalkLayer_liaotian = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_TalkLayer,"btn_changyongyu")
	self.mBtn_TalkLayer_biaoqiang = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_TalkLayer,"btn_biaoqiang")
	
	--规则弹框 
	self.mLayer_RuleLayer = self.mLayer_UI:seekWidgetByNameOfRoot("rule_pannel")
	self.mRuleLayer_BgWidget = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_RuleLayer, "bg_widget")
	self.mRuleLayer_FrameInner =  self.mLayer_UI:seekWidgetByNodeName(self.mLayer_RuleLayer, "FrameInner")
	
	--加载游戏中的字典
	local gameid= ds.DF:shared():GetGameKindID()
	local strResourceFileName = ds.CPlatformGameConfig:shared():getValue(gameid,"game_resource")
	ds.GameScriptDataMananger:loadGameScriptData(strResourceFileName.."/gameConfig.xml")


	local winSize = cc.Director:getInstance():getWinSize()
	self.mMessageBg = cc.Scale9Sprite:create("PlatForm/HallUI/MessageBg.png")
    self.mMessageBg:setCapInsets(CCRectMake(200, 28, 2, 2))
    self.mMessageBg:setPosition(cc.p(winSize.width/2 - 850/2 + 26, winSize.height - 40))
    self.mMessageBg:setAnchorPoint(cc.p(0, 0))
    self.mMessageBg:setContentSize(cc.size(850, 48))
    self.mLayer_UI:addChild(self.mMessageBg)
    self.mMessageBg:setVisible(false)
	
	--跑马灯的界面
	self.mBgLayout = ccui.Layout:create()
	self.mBgLayout:setContentSize(cc.size(684,40))
	self.mBgLayout:setSize(cc.size(684,40))
	self.mBgLayout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
	self.mBgLayout:setBackGroundColor(cc.c3b(0x30,0x30,0x30))
	self.mBgLayout:setBackGroundColorOpacity(0)

	self.mBgLayout:setPosition(324, winSize.height - 40)
	self.mBgLayout:setClippingEnabled(true)
	self.mBgLayout:setVisible(false)
	ds.common.setClippingType(self.mBgLayout)
	self.mLayer_UI:addChild(self.mBgLayout)


	--跑马灯文字框
	self.mLabMessage = cc.LabelTTF:create("",ds.common.ZI_MARKERFELT, 30)
	self.mLabMessage:setColor(cc.c3b(255,255,0))
	self.mLabMessage:setAnchorPoint(cc.p(0,0))
	self.mBgLayout:addChild(self.mLabMessage)
	
	self.mMessageQueue = {}
	
	self.m_isMove = false
	local function messageUPdate()
		
		if self.m_isMove == true then
			return
		end
		
		if ds.common.GetTableLenth(self.mMessageQueue) == 0 then	
			if ( self.mBgLayout ~= nil) then
				self.mBgLayout:setVisible(false)
			end
			if ( self.mMessageBg ~= nil) then
				self.mMessageBg:setVisible(false)	
			end
			return
		end
		self:ShowSystemMsg()
	end
	DSScheduleMgr.schedule(messageUPdate,3,"common_ui_message_update")

     --手机电池电量信息,信号,时间
	self.Lab_mlayer_Time =self.mLayer_UI:seekWidgetByNameOfRoot("lab_time")
	self.Img_mLayer_Power = self.mLayer_UI:seekWidgetByNameOfRoot("img_power")
	self.Img_mLayer_signal = self.mLayer_UI:seekWidgetByNameOfRoot("img_xinhao")
	self.Img_mLayer_Wife =  self.mLayer_UI:seekWidgetByNameOfRoot("img_wifi")
	--服务器类型
	self.m_GameServerType = ds.CGameCenterManager:Instance():GetGameServerItem():GetGameServer():getServerType()
    ds.MyNotification:getInstance():registerLuaEventCallBack("game_talk",GameCommonUi.recvGameTalk)	


	return instance
	
end

function gameCommonUi:init()
	
	self.mLayer_SettingLayer:setVisible(false)
	self.mLayer_CommonBtnLayer:setVisible(false)
	self.mImg_mLayer_WaitDistribute:setVisible(false)
	self.mLayer_RuleLayer:setVisible(false)
	self.mLayer_TalkLayer:setVisible(false)
	self.mBtn_CommonBtnLayer_ChangeDesk:setEnabled(false)
	self.mBtn_CommonBtnLayer_ChangeDesk:setOpacity(125)
    local CGameCenterManager = ds.CGameCenterManager:Instance()
    local mCServerItem = CGameCenterManager:GetServerItem()
    local IsDistributionTable = mCServerItem:IsDistributionTable()
    if ds.IClientKernel:get():IsMatchRoom() or IsDistributionTable == false then
         self.mBtn_mLayer_StartGame:setVisible(false)	
	end
	--开始游戏
   	self.mBtn_mLayer_StartGame:addTouchEventListener(function(sender, eventType)      
		if eventType == ccui.TouchEventType.ended then
			self.mBtn_mLayer_StartGame:setVisible(false)
			if ds.IServerItem:get() then
				ds.IServerItem:get():SendSocketData(ds.GameServer.MDM_GR_USER,ds.GameServer.SUB_GR_USER_CHAIR_REQ)
			end
		end
	end)

	--下拉按钮
   	self.mBtn_mLayer_PullDown:addTouchEventListener(function(sender, eventType)      
		if eventType == ccui.TouchEventType.ended then
		    self.mLayer_CommonBtnLayer:setVisible(true)
		end
	end)
    
	--下拉列表的背景
	self.mCommonBtnLayer_BgWidget:addTouchEventListener(function(sender, eventType)      
		if eventType == ccui.TouchEventType.ended then
		    self.mLayer_CommonBtnLayer:setVisible(false)
		end
	end)
    

	
	
	--换桌按钮
	self.mBtn_CommonBtnLayer_ChangeDesk:addTouchEventListener(function(sender, eventType)    
        if eventType == ccui.TouchEventType.ended then
	    
			local text = ds.StringData:shared():stringFromKey("change_desk")	
			DSDialogLayer.create(ds.Dialog.Type.AFFIRMANDCANCEL,text, nil,nil, nil, function()
	            if ds.IServerItem:get() then
				    ds.IServerItem:get():SendSocketData(ds.GameServer.MDM_GR_USER,ds.GameServer.SUB_GR_USER_CHAIR_REQ)
			    end  
	    end,true,"","")	
		end
	end)

	--规则按钮
	self.mBtn_CommonBtnLayer_Rule:addTouchEventListener(function(sender, eventType)      
		if eventType == ccui.TouchEventType.ended then

			self.m_bShowRule = not self.m_bShowRule
			self.mLayer_RuleLayer:setVisible( self.m_bShowRule)
			local targetPlatform = cc.Application:getInstance():getTargetPlatform()
			if (targetPlatform == cc.PLATFORM_OS_ANDROID or targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD) then
    	
			    local gameID= ds.DF:shared():GetGameKindID()
                local  Link = ds.CPlatformGameConfig:shared():getValue(gameID,"Rule_html")
				local size = self.mRuleLayer_FrameInner:getContentSize()
				local webView = ccexp.WebView:create()
				webView:setPosition(cc.p(size.width/2, size.height/2))
				webView:setContentSize(size.width , size.height )
				webView:loadURL(Link)
				webView:setScalesPageToFit(true)

				webView:setOnShouldStartLoading(function(sender, url)
        	--ds.log("onWebViewShouldStartLoading, url is ", url)
				return true
			end)
			webView:setOnDidFinishLoading(function(sender, url)
        	--ds.log("onWebViewDidFinishLoading, url is ", url)
			end)
			webView:setOnDidFailLoading(function(sender, url)
        	--ds.log("onWebViewDidFinishLoading, url is ", url)
			end)
    	
			self.mRuleLayer_FrameInner:addChild(webView)
			self.mRuleLayer_WebView = webView
	
		end		
	end		
	end)
	--IOS审核
	local IsIOS = tonumber(ds.StaticData:shared():stringFromKey("apple_pay_show"))
	if (IsIOS == 1) then
		self.mBtn_CommonBtnLayer_Rule:setEnabled(false)
		self.mBtn_CommonBtnLayer_Rule:setOpacity(155)
	end
	
	--规则界面的背景
	self.mRuleLayer_BgWidget:addTouchEventListener(function(sender, eventType)      
		if eventType == ccui.TouchEventType.ended then
		    self.mLayer_RuleLayer:setVisible(false)
	        self.m_bShowRule = false
			if self.mRuleLayer_WebView ~= nil then
				self.mRuleLayer_WebView:removeFromParent()
			    self.mRuleLayer_WebView = nil
				
			end
		end
	end)
	
	--设置按钮
	self.mBtn_CommonBtnLayer_Setting:addTouchEventListener(function(sender, eventType)      
		if eventType == ccui.TouchEventType.ended then
			
			self.m_bSettingShow = not self.m_bSettingShow
		
			self.mLayer_SettingLayer:setVisible(self.m_bSettingShow)
			self.mBtn_SettingLayer_GameMusic:setSelected(ds.SoundFun:Instance():GetIsPalyMusic())
			self.mBtn_SettingLayer_PlayMusic:setSelected(ds.SoundFun:Instance():GetIsPlayEffect())
 
		end
	end)
     
	--收起下拉列表
	self.mBtn_CommonBtnLayer_Recover:addTouchEventListener(function(sender, eventType)      
		if eventType == ccui.TouchEventType.ended then
		    self.mLayer_CommonBtnLayer:setVisible(false)
		end
	end)
    
	--退出按钮
	self.mBtn_CommonBtnLayer_Leave:addTouchEventListener(function(sender, eventType)      
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
	
    
	--设置音乐界面的关闭按钮
	self.mBtn_SettingLayer_Close:addTouchEventListener(function(sender, eventType)      
		if eventType == ccui.TouchEventType.ended then
		    self.mLayer_SettingLayer:setVisible(false)
	        self.m_bSettingShow = false
		end
	end)
     
	--设置音乐界面的背景
	self.mSettingLayer_BgWidget:addTouchEventListener(function(sender, eventType)      
		if eventType == ccui.TouchEventType.ended then
		    self.mLayer_SettingLayer:setVisible(false)
	        self.m_bSettingShow = false
		end
	end)
	
    --设置音乐界面的背景音乐
	self.mBtn_SettingLayer_GameMusic:addEventListener(function(sender, eventType)       
	
		if eventType == ccui.CheckBoxEventType.selected then
			ds.SoundFun:Instance():SetPlayMusic(true)
		elseif eventType == ccui.CheckBoxEventType.unselected then
			ds.SoundFun:Instance():SetPlayMusic(false)
		end
	end)
	self.mBtn_SettingLayer_GameMusic:setSelected(ds.SoundFun:Instance():GetIsPalyMusic())
	
	--设置音乐界面的打牌音效
	self.mBtn_SettingLayer_PlayMusic:addEventListener(function(sender, eventType)        
	
		if eventType == ccui.CheckBoxEventType.selected then
			ds.SoundFun:Instance():SetEffect(true)
		elseif eventType == ccui.CheckBoxEventType.unselected then
			ds.SoundFun:Instance():SetEffect(false)
		end
	end)
	self.mBtn_SettingLayer_PlayMusic:setSelected(ds.SoundFun:Instance():GetIsPalyMusic())
	
	--[[--语音列表
	--sound_list:setClippingType(ccui.ClippingType.scissor)
	ds.common.setClippingType(self.mlist_mLayer_SoundList)                              
	self.mlist_mLayer_SoundList:setBounceEnabled(true)
	local tChild = self.mlist_mLayer_SoundList:getChildren()
	for i = 0, #tChild - 1 do
		local index = i+1
		--tChild[i]:setTouchScaleChangeEnabled(true)
		tChild[index]:setTouchEnabled(true)
		tChild[index]:setTag(index)
		tChild[index]:addTouchEventListener(function(sender,eventType)
			if eventType == ccui.TouchEventType.ended then
				local tag = sender:getTag()
				self.mlist_mLayer_SoundList:setVisible(false)
				self.mImg_mLayer_SoundBg:setVisible(false)
				self.m_bShowYuYinText = not self.m_bShowYuYinText
			    --pc端从0开始
		        ds.MyNotification:getInstance():dispatchEvent("SendYunYinTag",ds.MTData:create(i))
				--限制语音发送频率
				self:setYuYinBtn(false);
				self:setYuYinTimer();
			end
		end)
	end--]]
	--[[local function onImageViewClicked(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
			local tag = sender:getTag()
			local str = ds.StringData:shared():stringFromKey("biaoqing_strFilePath") 
			local biaaoqing_Path = string.format(str,tag)	
			local chaird =ds.IClientKernel:get():GetMeChairID()
			self.m_gameScene:sendTalkBiaoQing(chaird,biaaoqing_Path)
			
        end
    end

	 
    for i = 0, self.m_MaxbiaoqingCount-1 do
		local str_biaoqing = string.format("biaoqing_%d",i)
		local img_biaoqing = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_TalkLayer,str_biaoqing)
        img_biaoqing:setTouchEnabled(true)
        img_biaoqing:setTag(i)
        img_biaoqing:addTouchEventListener(onImageViewClicked)
    end
	--]]
	self:ShowDefaultTalkLayer()
	--语音按钮
	self.mBtn_mLayer_Sound:addTouchEventListener(function(sender, eventType)                     
		 if eventType == ccui.TouchEventType.ended then
		 	self.m_bShowYuYinText = not self.m_bShowYuYinText
	
			self.mLayer_TalkLayer:setVisible(self.m_bShowYuYinText)
			
        end
	end)
	--语音背景
    self.mImg_mLayer_SoundBg:addTouchEventListener(function(sender, eventType)      
		if eventType == ccui.TouchEventType.ended then
		    self.mLayer_TalkLayer:setVisible(false)
			self.m_bShowYuYinText = false
		end
	end)

	--常用语按钮
	 self.mBtn_TalkLayer_liaotian:addTouchEventListener(function(sender, eventType)      
		if eventType == ccui.TouchEventType.ended then
			if self.mlist_mLayer_liaotianList:isVisible() == true then
				return 
			else
				self.mBtn_TalkLayer_liaotian:loadTextures("common/Talk/changyongyu.png","","")
				self.mBtn_TalkLayer_biaoqiang:loadTextures("common/Talk/bk_biaoqing.png","","")
				self.mlist_mLayer_liaotianList:setVisible(true)
				self.mlist_mLayer_biaoqingList:setVisible(false)
				
			end
			
		end
	end)
	
	--表情按钮
	 self.mBtn_TalkLayer_biaoqiang:addTouchEventListener(function(sender, eventType)      
		if eventType == ccui.TouchEventType.ended then
			if self.mlist_mLayer_biaoqingList:isVisible() == true then
				return 
			else
				self.mBtn_TalkLayer_liaotian:loadTextures("common/Talk/bk_changyongyu.png","","")
				self.mBtn_TalkLayer_biaoqiang:loadTextures("common/Talk/biaoqing.png","","")
				self.mlist_mLayer_liaotianList:setVisible(false)
				self.mlist_mLayer_biaoqingList:setVisible(true)
				
			end
		
		end
	end)
	
	--充值按钮
	self.mBtn_recharge:addTouchEventListener(function(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			
          ds.MyNotification:getInstance():dispatchEvent("game_event",ds.MTData:create(ds.GameEventIDDefine.GAME_EVENT_ID_SHOW_PAY))
			
		end
	end)
	
	--个人信息初始化
	local pGlobalUserInfo = ds.CGlobalUserInfo:GetInstance()
	self.mText_name:setString(pGlobalUserInfo:getNickName())
	self.mText_goldNum:setString(ds.common.GetNumberOfShort(pGlobalUserInfo:getUserScore()))
	self.mText_yuanbaoNum:setString(ds.common.GetNumberOfShort(pGlobalUserInfo:getUserIngot()))
	
	--[[if (self.mLab_icon ~= nil) then
		
		local headId = pGlobalUserInfo:getFaceID()	
		local path = ds.common.YRComGetHeadImageById(headId)
		self.mLab_icon:loadTexture(path, ccui.TextureResType.plistType)
	end--]]


	local nServerType = ds.CGameCenterManager:Instance():GetGameServerItem():GetGameServer():getServerType()
	if (nServerType == ds.Define.GAME_GENRE_FULL or nServerType == ds.Define.GAME_GENRE_TIME) then
	--if (true) then
		self.mText_goldNum:setVisible(false)
		self.mText_yuanbaoNum:setVisible(false)
		self.mBtn_recharge:setVisible(false)
		self:FreshScoreOfBisai()
		self.mBtn_CommonBtnLayer_ChangeDesk:setEnabled(false)
		self.mBtn_CommonBtnLayer_ChangeDesk:setOpacity(155)
	elseif (nServerType ~= ds.Define.GAME_GENRE_EDUCATE) then
		self.mText_goldNum:setVisible(true)
		self.mText_yuanbaoNum:setVisible(true)
		self.mBtn_recharge:setVisible(true)
		self.mText_jifenNum:setVisible(false)
	end
	if self.m_GameServerType ==ds.Define.GAME_GENRE_EDUCATE then
		self.mText_goldNum:setVisible(false)
		self.mText_yuanbaoNum:setVisible(false)
		self.mBtn_recharge:setVisible(false)
		self.mBtn_CommonBtnLayer_ChangeDesk:setOpacity(125)
		self.mBtn_mLayer_StartGame:setVisible(false)
	end
	
	
--显示手机相关信息
    local function ShowPhoneInformation()
		local Time =  ds.CoTimer:getGameWorldTimeStr()
		self.Lab_mlayer_Time:setString(Time)
	
	    local power_level = ds.MultiPlatformMgr:getInstance():GetBatteryLevel()
		self:ShowPowerLever(power_level)
		local NetType = ds.MultiPlatformMgr:getInstance():GetNetType()
		local Net_level = ds.MultiPlatformMgr:getInstance():GetNetLevel()
	    self:ShowNetLevel(NetType,Net_level)
	end   	
	ShowPhoneInformation()
	DSScheduleMgr.schedule(ShowPhoneInformation,5,"common_ui_message_phone")
end

--查询是否可以退出游戏
function QueryQuitGame(nResult)
	
	--正在游戏中
	local nServerType = ds.CGameCenterManager:Instance():GetGameServerItem():GetGameServer():getServerType()
	if 1 == nResult then
		if nServerType== ds.Define.GAME_GENRE_EDUCATE then
			local text = ds.StringData:shared():stringFromKey("dissolveroom")
			DSDialogLayer.create(ds.Dialog.Type.AFFIRMANDCANCEL,text, nil,nil, nil, function()
				
                local bDismiss = 1
                privateInterface.SenddissolveroomMsg(bDismiss) 

	        end,true,"","")    
		else
	
			local text = ds.StringData:shared():stringFromKey("in_game_status_quick_hint")	
			if (nServerType == ds.Define.GAME_GENRE_FULL or nServerType == ds.Define.GAME_GENRE_TIME) then
				text = ds.StringData:shared():stringFromKey("in_game_status_quick_match")
				aff_Img = "common/Button_exit_text.png"
			end
		
			DSDialogLayer.create(ds.Dialog.Type.AFFIRMANDCANCEL,text, nil,aff_Img, nil, function()
				if ds.IClientKernel:get() then
					ds.IClientKernel:get():Intermit(ds.Define.enGameExitCode.GameExitCode_Normal)
					--ds.IClientKernel:get():GetUserInfo().cbUserStatus = ds.Define.US_FREE
				end  
			end,true,"","")
		end
		
	else	--不在游戏中
		if nServerType == ds.Define.GAME_GENRE_EDUCATE then
			local text = ""
			local pGlobalUserInfo = ds.CGlobalUserInfo:GetInstance()
			if privateInterface.privateData.CMD_GF_Private_Room_Info.dwPlayCout == privateInterface.privateData.CMD_GF_Private_Room_Info.dwPlayTotal then
				if ds.IClientKernel:get() then
					ds.IClientKernel:get():Intermit(ds.Define.enGameExitCode.GameExitCode_Normal)
				end
			end
			if pGlobalUserInfo:getUserID() == privateInterface.privateData.CMD_GF_Private_Room_Info.dwCreateUserID then
				if privateInterface.privateData.CMD_GF_Private_Room_Info.dwPlayCout ==0 then
					text = ds.StringData:shared():stringFromKey("dissolveroom_free")
				else
					text = ds.StringData:shared():stringFromKey("dissolveroom")		
				end
				DSDialogLayer.create(ds.Dialog.Type.AFFIRMANDCANCEL,text, nil,nil, nil, function()
				
					local bDismiss = 1
					privateInterface.SenddissolveroomMsg(bDismiss) 

				end,true,"","")
			else
				if privateInterface.privateData.CMD_GF_Private_Room_Info.dwPlayCout ==0  then
					if ds.IClientKernel:get() then
						ds.IClientKernel:get():Intermit(ds.Define.enGameExitCode.GameExitCode_Normal)
					end
				else
					local text = ds.StringData:shared():stringFromKey("dissolveroom")		
			
					DSDialogLayer.create(ds.Dialog.Type.AFFIRMANDCANCEL,text, nil,nil, nil, function()
				
						local bDismiss = 1
						privateInterface.SenddissolveroomMsg(bDismiss) 

					end,true,"","")		
				end
				--ds.IClientKernel:get():setUserStatus (ds.Define.US_FREE)
				--local cbUserStatus = ds.IClientKernel:get():getUserStatus()
			end  
				 
		else
			if ds.IClientKernel:get() then
				ds.IClientKernel:get():Intermit(ds.Define.enGameExitCode.GameExitCode_Normal)
				--ds.IClientKernel:get():setUserStatus (ds.Define.US_FREE)
				--local cbUserStatus = ds.IClientKernel:get():getUserStatus()
			end  
	    end
	end
	
		
end

local function ShowPlayerInformation()
	--[[local name = --]]
	
end

--处理等待分组返回
function gameCommonUi:OnSubWaitBack()                                        
	
	self.mImg_mLayer_WaitDistribute:setVisible(true)
	self.mBtn_mLayer_StartGame:setVisible(false)
end

--接收系统消息
function gameCommonUi:OnRecvSystemMsg(strMsg)

	table.insert(self.mMessageQueue,0,strMsg)
	
end

--显示系统消息
function gameCommonUi:ShowSystemMsg()
	
	local strMsg = self.mMessageQueue[#self.mMessageQueue]
	self.mMessageQueue[#self.mMessageQueue] = nil
	
	self.mBgLayout:setVisible(true)
	self.mMessageBg:setVisible(true)
	self.m_isMove = true
	self.mLabMessage:setString(strMsg)
	
	local label_pos = self.mBgLayout:getSize()
	self.mLabMessage:setPosition(cc.p(label_pos.width,5))
	
	local move_distance = string.len(strMsg) * 20
	if move_distance < label_pos.width then
		
		move_distance = move_distance
	end
	
	local time = (move_distance / 100) < 25 and 25 or (move_distance / 150)
	local move = cc.MoveBy:create((move_distance / 150),cc.p(-move_distance,0))
	local sequence = cc.Sequence:create(move,cc.CallFunc:create(function()
		
		self.m_isMove = false
		
		if ds.common.GetTableLenth(self.mMessageQueue) == 0 then		
			self.mBgLayout:setVisible(false)
			self.mMessageBg:setVisible(false)
		end
	end))
	
	self.mLabMessage:runAction(sequence)
end

 --显示电池电量
function gameCommonUi:ShowPowerLever(power_level)      
	local power_level_1 =  self.mLayer_UI:seekWidgetByNodeName(self.Img_mLayer_Power, "dianliang_1")
	local power_level_2=  self.mLayer_UI:seekWidgetByNodeName(self.Img_mLayer_Power, "dianliang_2")
	local power_level_3 =  self.mLayer_UI:seekWidgetByNodeName(self.Img_mLayer_Power, "dianliang_3")
	if power_level == 0 then
		power_level_1:setVisible(false)
		power_level_2:setVisible(false)
		power_level_3:setVisible(false)
			
	elseif  power_level == 1 then
		power_level_1:setVisible(true)
		power_level_2:setVisible(false)
		power_level_3:setVisible(false)
			
    elseif  power_level == 2 then
		power_level_1:setVisible(true)
		power_level_2:setVisible(true)
		power_level_3:setVisible(false)
			
	elseif  power_level == 3 then
		power_level_1:setVisible(true)
		power_level_2:setVisible(true)
		power_level_3:setVisible(true)
	end
		
end

function gameCommonUi:ShowNetLevel(NetType,Net_level)
  
	local wifi_level_1 =  self.mLayer_UI:seekWidgetByNodeName(self.Img_mLayer_Wife, "wifi_1")
	local wifi_level_2=  self.mLayer_UI:seekWidgetByNodeName(self.Img_mLayer_Wife, "wifi_2")
	local wifi_level_3 =  self.mLayer_UI:seekWidgetByNodeName(self.Img_mLayer_Wife, "wifi_3")
	self.Img_mLayer_signal:setVisible(false)
	self.Img_mLayer_Wife:setVisible(false)
	if NetType== 0 then
		self.Img_mLayer_signal:setVisible(false)
		self.Img_mLayer_Wife:setVisible(false)
	
    elseif NetType == 1 then
		self.Img_mLayer_signal:setVisible(true)
		self.Img_mLayer_Wife:setVisible(false)
	elseif NetType == 2 then
		self.Img_mLayer_signal:setVisible(false)
		self.Img_mLayer_Wife:setVisible(true)

		if Net_level == 0 then
			self.Img_mLayer_Wife:setVisible(false)
			
		elseif Net_level == 1 then
			self.Img_mLayer_Wife:setVisible(true)
			wifi_level_1:setVisible(false)
			wifi_level_2:setVisible(false)
			wifi_level_3:setVisible(false)
			
    	elseif Net_level == 2 then
			self.Img_mLayer_Wife:setVisible(true)
			wifi_level_1:setVisible(true)
			wifi_level_2:setVisible(false)
			wifi_level_3:setVisible(false)
			
		elseif Net_level == 3 then
			self.Img_mLayer_Wife:setVisible(true)
			wifi_level_1:setVisible(true)
			wifi_level_2:setVisible(true)
			wifi_level_3:setVisible(false)
		elseif Net_level == 4 then
			self.Img_mLayer_Wife:setVisible(true)
			wifi_level_1:setVisible(true)
			wifi_level_2:setVisible(true)
			wifi_level_3:setVisible(true)
		end
	end

end

--重连游戏进入
function gameCommonUi:OnReconnectResumeGame()
	
	self.mBtn_mLayer_StartGame:setVisible(false)
   	self.mImg_mLayer_WaitDistribute:setVisible(false)
	self.mBtn_CommonBtnLayer_ChangeDesk:setEnabled(false)
    self.mBtn_CommonBtnLayer_ChangeDesk:setOpacity(125)	
	
	self:setYuYinBtn(true)
end


--共同的金币刷新
function gameCommonUi:OnEventUserScore()
    
	local pGlobalUserInfo = ds.CGlobalUserInfo:GetInstance()
	self.mText_goldNum:setString(ds.common.GetNumberOfShort(pGlobalUserInfo:getUserScore()))
	self.mText_yuanbaoNum:setString(ds.common.GetNumberOfShort(pGlobalUserInfo:getUserIngot()))
end

--显示正在匹配对手
function gameCommonUi:ShowWaitTips(flag)
	self.mImg_mLayer_WaitDistribute:setVisible(flag)
end

function gameCommonUi:FreshScoreOfBisai()
	if (self.mText_jifenNum ~= nil) then
		self.mText_jifenNum:setVisible(true)
		local CGameCenterManager = ds.CGameCenterManager:Instance()	
		local mCServerItem = CGameCenterManager:GetServerItem()	
		local item = mCServerItem:GetMeUserItem();
		if item ~= nil then
			ds.log("item:GetUserGrade:",item:GetUserGrade())
			self.mText_jifenNum:setString(item:GetUserGrade())
		end
	end
end



--共同ui销毁
function gameCommonUi:Destroy()
	
	DSScheduleMgr.unschedule("common_ui_message_update")
	DSScheduleMgr.unschedule("common_ui_message_phone")
    ds.MyNotification:getInstance():unRegisterEventListener("game_talk")	
	self.mLayer_UI:Close()
	ds.gameCommonUI = nil
end

--设置语音按钮状态
function gameCommonUi:setYuYinBtn(bEnable)
	self.mBtn_mLayer_Sound:setEnabled(bEnable)
	if bEnable == true then
		self.mBtn_mLayer_Sound:setOpacity(255)
	else
		self.mBtn_mLayer_Sound:setOpacity(123)
	end
end
--设置语音时间间隔
function gameCommonUi:setYuYinTimer()
	local scheduler = cc.Director:getInstance():getScheduler()
	--先关闭下定时器
	if self.mYuYinTimerID ~= nil then
		scheduler:unscheduleScriptEntry(self.mYuYinTimerID)
		self.mYuYinTimerID = nil
	end
	
	--设置定时器
	self.mYuYinTimerID = scheduler:scheduleScriptFunc(function()
		if self.mYuYinTimerID ~= nil then
			scheduler:unscheduleScriptEntry(self.mYuYinTimerID)
			self.mYuYinTimerID = nil
		end
		
		self:setYuYinBtn(true)
	end, 6, false)
end
	
--创建函数
function create(mgamescene)
	local gameCommonUILayer = gameCommonUi:create()
	gameCommonUILayer.m_gameScene = mgamescene
	gameCommonUILayer:init()
	return gameCommonUILayer
end
--接收聊天的事件
function recvGameTalk(MTData)
	if ds.game ~= nil then
		ds.game:showTalkState(MTData:getPData())
	end
end
--显示房卡分数
function gameCommonUi:showPrivateUserScore()
	self.mText_zhanjiNum:setVisible(true)
	self.mText_zhanjiNum:setString(tostring(privateInterface.getPrivateScore(ds.IClientKernel:get():GetMeChairID())))
end

--显示默认状态下的聊天框
function gameCommonUi:ShowDefaultTalkLayer()

	self.mlist_mLayer_biaoqingList:setVisible(false)
	self.mlist_mLayer_liaotianList:setVisible(true)
	ds.common.setClippingType(self.mlist_mLayer_liaotianList)
	ds.common.setClippingType(self.mlist_mLayer_biaoqingList)
	self.mBtn_TalkLayer_liaotian:loadTextures("common/Talk/changyongyu.png","","")
	self.mBtn_TalkLayer_biaoqiang:loadTextures("common/Talk/bk_biaoqing.png","","")
	local liaotian_count =  ds.GameScriptDataMananger:getString("yunyin_count")
	liaotian_count = tonumber(liaotian_count)
	local m_talk_textlayer =  self.mLayer_UI:seekWidgetByNodeName(self.mLayer_TalkLayer, "talk_textlayer")
	for i=0, liaotian_count-1 do
		local talk_textlayer = m_talk_textlayer:clone()
		
		local text = string.format("text_talk%d",i)
		text = ds.GameScriptDataMananger:getString(text)
		talk_textlayer:setTag(i)
		local changyongyu_text =  self.mLayer_UI:seekWidgetByNodeName(talk_textlayer,"text_changyongyu")
		changyongyu_text:setString(text)
        self.mlist_mLayer_liaotianList:pushBackCustomItem(talk_textlayer)	
	end
	self.mlist_mLayer_liaotianList:setBounceEnabled(true)
	local tChild = self.mlist_mLayer_liaotianList:getChildren()
	for i = 0, #tChild - 1 do
		local index = i+1
		tChild[index]:setTouchEnabled(true)
		local img_select = self.mLayer_UI:seekWidgetByNodeName(tChild[index],"img_select")
		tChild[index]:addTouchEventListener(function(sender,eventType)
			if eventType == ccui.TouchEventType.began then
					img_select:setVisible(true)
			end
			if eventType == ccui.TouchEventType.moved then
				img_select:setVisible(false)
			end
			if eventType == ccui.TouchEventType.ended then
				img_select:setVisible(false)
				local tag = sender:getTag()
				self.m_bShowYuYinText = false
				self.mLayer_TalkLayer:setVisible(false)
				local chaird =ds.IClientKernel:get():GetMeChairID()
				local soundPath = self:GetSoundFilePath(tag)
				local text = string.format("text_talk%d",i)
				text = ds.GameScriptDataMananger:getString(text)
				soundPath =soundPath..":"..text
				self.m_gameScene:sendTalkDefine(chaird,soundPath)
			end
		end)
	end
	local biaoqing_info = self.mLayer_UI:seekWidgetByNodeName(self.mLayer_TalkLayer, "biaoqing_info")
	local biaoqing_count = 0
	local function onImageViewClicked(sender, eventType)
		if eventType == ccui.TouchEventType.began then
			sender:setScale(1.00)
		end
		if  eventType == ccui.TouchEventType.moved then
			sender:setScale(0.75)
		end
        if eventType == ccui.TouchEventType.ended then
			local tag = sender:getTag()
			sender:setScale(0.75)
			local biaaoqing_Path = string.format("common/Talk/EE%d.png",tag)	
			local chaird =ds.IClientKernel:get():GetMeChairID()
			self.m_gameScene:sendTalkBiaoQing(chaird,biaaoqing_Path)
			self.mLayer_TalkLayer:setVisible(false)
			self.m_bShowYuYinText = false
        end
    end
	for i=0, self.m_MaxbiaoqingList-1 do
		local  mbiaoqing_info = biaoqing_info:clone()
		local tChild = mbiaoqing_info:getChildren()
		for  i = 0,#tChild-1 do
			local a  =#tChild
			local index = i +1
			if biaoqing_count == 33 then
				tChild[index]:setVisible(false)
			else
				
				tChild[index]:setTouchEnabled(true)
				tChild[index]:setTag(biaoqing_count)
				local str_biaoqingPath = string.format("common/Talk/EE%d.png",biaoqing_count)
				tChild[index]:loadTexture(str_biaoqingPath,ccui.TextureResType.localType)
				biaoqing_count= biaoqing_count+1
				tChild[index]:addTouchEventListener(onImageViewClicked)
			end
		end
		self.mlist_mLayer_biaoqingList:pushBackCustomItem(mbiaoqing_info)	
	end
end


--获得单个游戏的语音文件的路径
function gameCommonUi:GetSoundFilePath(idx)
	local gameid= ds.DF:shared():GetGameKindID()
	local pGlobalUserInfo =ds.CGlobalUserInfo:GetInstance()
	local sex = pGlobalUserInfo:getGender()
	local kName = ""
	if (sex == 1) then
		kName = string.format("joker/fmale/%d.wav",idx+1)
	else
		kName = string.format("joker/male/%d.wav",idx+1)
	end
	
	return kName
end