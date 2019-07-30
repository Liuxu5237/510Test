--
-- Author: Tang
-- Date: 2016-10-11 17:22:24
--
--[[
	游戏交互层
]]
local GameViewLayer = class("GameViewLayer",function(scene)
		local gameViewLayer =  display.newLayer()
    return gameViewLayer
end)
local module_pre = "game.yule.luxurycar.src"
--external
--
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local g_var = ExternalFun.req_var
local ClipText = appdf.EXTERNAL_SRC .. "ClipText"
local PopupInfoHead = appdf.EXTERNAL_SRC .. "PopupInfoHead"
--
local  BankerList = module_pre..".views.layer.BankerList"
local  UserList = module_pre..".views.layer.UserList"
local  SettingLayer = module_pre..".views.layer.SettingLayer"
local  Chat = module_pre..".views.layer.Chat"
local cmd = module_pre .. ".models.CMD_Game"
local game_cmd = appdf.HEADER_SRC .. "CMD_GameServer"
local QueryDialog   = require("app.views.layer.other.QueryDialog")
local GameNotice = appdf.req(appdf.BASE_SRC .."app.views.layer.other.GameNotice")

local TAG_ZORDER = 
{	
	CLOCK_ZORDER = 10,
	BANK_ZORDER	 = 30,
	SET_ZORDER	 = 40,
	HELP_ZORDER	 = 50
}
local TAG_ENUM = 
{
	TAG_USERNICK = 1000,
	TAG_USERSCORE = 2000
}
local TAG_EFFECT = 
{
	TAG_START	=1,
	TAG_DOWN    =2,
	TAG_LOOP    =3,
	TAG_JETTON  =4,
	TAG_WARING  =5
}

--申请庄家
GameViewLayer.unKnown = 0
GameViewLayer.unApply = 1	--未申请
GameViewLayer.applyed = 2	--已申请
function GameViewLayer:ctor(scene)

	self._scene = scene
	self.oneCircle	= 32		--一圈32个豪车
	--self.oneCircle	= 16		--一圈16个豪车
	self.index = 2				--豪车索引	
 	self.time = 0.03			--转动时间间隔
 	self.count = 0				--转动次数
 	self.endindex = -1			--停止位置
	self.JettonIndex = -1
	self.lastJettonIndex = 0
 	self.bContinueRecord = true  
 	self.bAnimate		 = false
 	self.bPoints		 = false
 	self._bank = nil             --银行
 	self._bankerView= nil        --上庄列表
 	self._UserView = nil         --玩家列表
 	self._ChatView = nil         --聊天
	self._isShowAddRect = false
 	self.m_cbGameStatus = 0
	self.m_eApplyStatus = GameViewLayer.unApply
	 
	AudioEngine.stopMusic()
	AudioEngine.playMusic("sound_res/BACK_GROUND_DRAW.wav",true)

	self.arr_jetton = {1000,10000,100000,1000000,5000000,10000000}
	self.car_points = {}
	self.car_rota = {}
	for i=1,8 do
		self.car_points[i] = cc.p(358+84*(i-1),616)
	end
	self.car_points[9] = cc.p(991,602)
	self.car_points[10] = cc.p(1041,574)
	self.car_points[11] = cc.p(1083,523)
	self.car_points[12] = cc.p(1108,473)
	self.car_points[13] = cc.p(1108,400)
	self.car_points[14] = cc.p(1097,353)
	self.car_points[15] = cc.p(1073,303)
	self.car_points[16] = cc.p(1027,260)
	for i=17,24 do
		self.car_points[i] = cc.p(967-84*(i-17),232)
	end
	self.car_points[25] = cc.p(332,247)
	self.car_points[26] = cc.p(290,271)
	self.car_points[27] = cc.p(250,341)
	self.car_points[28] = cc.p(225,368)
	self.car_points[29] = cc.p(225,437)
	self.car_points[30] = cc.p(238,496)
	self.car_points[31] = cc.p(263,546)
	self.car_points[32] = cc.p(304,591)

	for i=1,32 do
		if i>=1 and i<=8 then
			self.car_rota[i] = 0

		elseif i>=9 and i<=11 then
			self.car_rota[i] = 22.5*(i-8)
		elseif i>=12 and i<=13 then
			self.car_rota[i] = 90
		elseif i>=14 and i<=16 then
			self.car_rota[i] = 90+22.5*(i-13)

		elseif i>=17 and i<=24 then
			self.car_rota[i] = 180

		elseif i>=25 and i<=27 then
			self.car_rota[i] = 180+22.5*(i-24)
		elseif i>=28 and i<=29 then
			self.car_rota[i] = 270
		elseif i>=30 and i<=32 then
			self.car_rota[i] = 270+22.5*(i-29)
		end
		
	end

	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    --用户信息改变事件
	eventDispatcher:addEventListenerWithSceneGraphPriority(
        cc.EventListenerCustom:create("ry_GetGameNotice", handler(self, self.NoticeCallBack)),
        self
		)
	
	self:gameDataInit()
	--初始化csb界面
	self:initCsbRes()
	self:initTableJettons({0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0})
	self:showMyselfInfo()
	self:initTableview()
	
	 --注册事件
 	ExternalFun.registerTouchEvent(self,true)
	
	 
end

function GameViewLayer:NoticeCallBack( event )
	
	local msg  =  event._usedata["NoticeMsg"]
	
	if self._laba ~=nil then
		self._laba:addTrugTxt(msg)
	end
	
end

	
function GameViewLayer:restData()
	self.index = 2			
 	self.time = 0.05
 	self.count = 0
 	self.endindex = -1
	self.bAnimate = true
	--self:SetJettonIndex(1)
 	
 	if self:GetJettonRecord() == 0 then
 		self.bContinueRecord = true
 	else
 		self.bContinueRecord = false
 	end
end
function GameViewLayer:getTimeQueue(index)
	
	local a1 = 0.1
	local a96 = ((self._scene.m_cbLeftTime-(0.1*32))*2)/96 - a1
	local per = (a96 - a1)/(96-1)
	local  time  = a1 + (index - 1) * per
	--[[print("a96 is ========== >"..a96)
	print("per is ================>"..per)
	print("time is =================== >"..time..",index is ================= >"..index)]]
	return time
end
function GameViewLayer:setTimePer()
	local percent = self._scene.m_cbLeftTime / 20
	self.time = self.time * percent
end
function GameViewLayer:gameDataInit(  )
	--搜索路径
    local gameList = self:getParentNode():getParentNode():getApp()._gameList;
    local gameInfo = {};
    for k,v in pairs(gameList) do 
        if tonumber(v._KindID) == tonumber(g_var(cmd).KIND_ID) then
            gameInfo = v;
            break;
        end
    end
    if nil ~= gameInfo._Module then
		if LOCAL_DEVELOP == 1 then
			self._searchPath = "game/" .. gameInfo._Module .. "/res/";
		else
			self._searchPath = device.writablePath.."game/" .. gameInfo._Module .. "/res/";
		end
    	
        cc.FileUtils:getInstance():addSearchPath(self._searchPath);
    end
    --加载资源
	self:loadRes()
end
function GameViewLayer:getParentNode( )
	return self._scene;
end
function GameViewLayer:getDataMgr( )
	return self:getParentNode():getDataMgr()
end
function GameViewLayer:showPopWait( )
	self:getParentNode():showPopWait()
end
function GameViewLayer:loadRes()
end
function GameViewLayer:initTableview()
	local bankerBG =  self._rootNode:getChildByName("zhuang_listBG")
	self._bankerView = g_var(BankerList):create(self._scene._dataModle)
	self._bankerView:setContentSize(cc.size(260, 310))
	self._bankerView:setAnchorPoint(cc.p(0.0,0.0))
	self._bankerView:setPosition(cc.p(10, 21))
	bankerBG:addChild(self._bankerView)
end
function GameViewLayer:showMyselfInfo()
	local useritem = self._scene:GetMeUserItem()
	--玩家头像
	local head = g_var(PopupInfoHead):createNormal(GlobalUserItem, 65)
	head:setPosition(43,44)
	self:addChild(head)
	head:enableInfoPop(false)
	--玩家昵称
	local nick =  g_var(ClipText):createClipText(cc.size(120, 20),useritem.szNickName);
	nick:setAnchorPoint(cc.p(0.0,0.5))
	nick:setPosition(110,53)
	self:addChild(nick,5)
	--用户游戏币
	self.m_scoreUser = 0
	
	if nil ~= useritem then
		self.m_scoreUser = useritem.lScore;
	end	
	local str = ExternalFun.numberThousands(0)
	if string.len(str) > 11 then
		str = string.sub(str,1,11) .. "...";
	end

	local coin =  cc.Label:createWithTTF(str, "fonts/round_body.ttf", 20)
	coin:setTextColor(cc.c3b(71,255,255))
	coin:setTag(TAG_ENUM.TAG_USERSCORE)
	coin:setAnchorPoint(cc.p(0.0,0.5))
	coin:setPosition(110,24)
	self:addChild(coin,5)


	--icon 
	local icon_gold =self._rootNode:getChildByName("sp_icon")
	icon_gold:setScale(0.8)
	icon_gold:loadTexture("plaza/game_gold.png")
end
function GameViewLayer:updateScore(score)   --更新分数
	self.m_scoreUser = score
	local str = ExternalFun.numberThousands(score);
	if string.len(str) > 11 then
		str = string.sub(str,1,11) .. "...";
	end
	local userScore = self:getChildByTag(TAG_ENUM.TAG_USERSCORE)
	userScore:setString(str)
end
---------------------------------------------------------------------------------------
--界面初始化
function GameViewLayer:initCsbRes()
	local rootLayer, csbNode = ExternalFun.loadRootCSB("game_res/Game.csb",self)
	self._rootNode = csbNode
	
	self._laba =  GameNotice:create("",cc.p(667,630))
	self._laba:addTo(self._rootNode)

	self:resetRollCarPos()
	self:setClockTypeIsVisible(false)
	self:initButtons()
	
end
function GameViewLayer:initButtons()  --初始化按钮
	
	--银行
	local function callfunc(ref,eventType)
        if eventType == ccui.TouchEventType.ended then
       		self:btnBankEvent(ref, eventType)
        end
    end
   --银行
	local btn =  self._rootNode:getChildByName("btn_bank")
	btn:addTouchEventListener(callfunc)
--上庄列表
	local banker = self._rootNode:getChildByName("btn_zhuang")
	banker:addTouchEventListener(function (ref,eventType)
            if eventType == ccui.TouchEventType.ended then
           		self:BankerEvent(ref, eventType)
            end
        end)
	self:InitBankerInfo()
--玩家列表
  local userlist = self._rootNode:getChildByName("btn_userlist")
  userlist:addTouchEventListener(function (ref,eventType)
            if eventType == ccui.TouchEventType.ended then
           		self:UserListEvent(ref, eventType)
            end
        end)
--聊天
    local chat = self._rootNode:getChildByName("btn_chat")
    chat:addTouchEventListener(function (ref,eventType)
            if eventType == ccui.TouchEventType.ended then
           		self:ChatEvent(ref, eventType)
            end
        end)
	--下注筹码
	local addview = self._rootNode:getChildByName("add_rect")
	for i=1,g_var(cmd).JETTON_COUNT do
		local btn = self._rootNode:getChildByName(string.format("bet_%d", i))
		btn:setTag(100+i)
		--print("猜我是多少 ： " .. self._scene.BetArray[i])
		btn:loadTextureNormal(string.format("client/res/Jetton/Button_chip_%d.png",self.arr_jetton[i]))
		btn:loadTextureDisabled(string.format("client/res/Jetton/Button_chip_%d_dis.png", self.arr_jetton[i]))
		btn:setEnabled(false)
		btn:addTouchEventListener(function (ref,eventType)
            if eventType == ccui.TouchEventType.ended then
           		self:JettonEvent(ref, eventType)
            end
        end)
	end
	--游戏记录
	local record = self._rootNode:getChildByName("btn_record")
	record:addTouchEventListener(function (ref,eventType)
            if eventType == ccui.TouchEventType.ended then
           		self:ShowRecord()
            end
        end)
	--续压按钮
	local continueBtn =  addview:getChildByName("btn_continue")
	continueBtn:addTouchEventListener(function (ref,eventType)
            if eventType == ccui.TouchEventType.ended then
           		self:ContinueEvent(ref, eventType)
            end
        end)
	--申请庄家
	local bankerBG =  self._rootNode:getChildByName("zhuang_listBG")
	local applyBtn = bankerBG:getChildByName("btn_apply")
	applyBtn:addTouchEventListener(function (ref,eventType)
            if eventType == ccui.TouchEventType.ended then
           		self:ApplyEvent(ref, eventType)
            end
        end)
	--下注区域
	for i=1,g_var(cmd).AREA_COUNT do
		local btn = addview:getChildByName(string.format("bet_area_%d", i))
		btn:setTag(200+i)
		btn:addTouchEventListener(function (ref,eventType)
            if eventType == ccui.TouchEventType.ended then
				if self:GetJettonIndexInvalid() then
					
					self:playEffectByz(TAG_EFFECT.TAG_JETTON)
            		local circle = addview:getChildByName(string.format("circle_%d",i))
           			circle:runAction(cc.Sequence:create(cc.CallFunc:create(function()
           				circle:setVisible(true)
           			end),cc.DelayTime:create(0.2),cc.CallFunc:create(function()
           				 circle:setVisible(false)
           			end)))
           			self:PlaceJettonEvent(ref,eventType)
           		else
       				if self.m_cbGameStatus == g_var(cmd).GS_PLACE_JETTON then
       					local runScene = cc.Director:getInstance():getRunningScene()
						showToast(runScene, "请选择目标筹码", 1)	
       				end
            	end
            end
        end)
	end
	--返回按钮
	local back = self._rootNode:getChildByName("btn_back")
	back:addTouchEventListener(function (ref,eventType)
            if eventType == ccui.TouchEventType.ended then
           		self._scene:onExitTable()
            end
        end)
	--设置按钮
	local help = self._rootNode:getChildByName("btn_set")
	help:addTouchEventListener(function (ref,eventType)
            if eventType == ccui.TouchEventType.ended then
  				local mgr = self._scene._scene:getApp():getVersionMgr()
    			local verstr = mgr:getResVersion(g_var(cmd).KIND_ID) or "0"
    			verstr = "游戏版本:" .. appdf.BASE_C_VERSION .. "." .. verstr
		        local set = g_var(SettingLayer):create(verstr)
		        self:addChild(set, TAG_ZORDER.SET_ZORDER)
		        --self:addToRootLayer(set, TAG_ZORDER.SET_ZORDER)
            end
		end)
		
	local addrect =  self._rootNode:getChildByName("add_rect")
	addrect:setLocalZOrder(20)
	--下注按钮
	self._btnJetton = self._rootNode:getChildByName("btnJetton")
	self._btnJetton:setEnabled(false)
	self._btnJetton:addTouchEventListener(function (ref,eventType)
		if eventType == ccui.TouchEventType.ended then
			
			if self._isShowAddRect == false then
				self:AddViewSlipToShow()
			else
				self:AddViewSlipToHidden()
			end
		end
	end)

	--帮助按钮
	self._btnHelp = self._rootNode:getChildByName("btn_help")
	self._btnHelp:addTouchEventListener(function (ref,eventType)
		if eventType == ccui.TouchEventType.ended then
			self:createHelpLayer()
		end
	end)

	--总下注
	self._allJettonCount = cc.LabelBMFont:create("", "game_res/hcScore.fnt") 
	local tms = self._rootNode:getChildByName("TotalJettonCount")
	self._allJettonCount:setScale(1.5)
	self._allJettonCount:setPosition(cc.p(tms:getPositionX(),tms:getPositionY()-9))
	self._allJettonCount:setAnchorPoint(tms:getAnchorPoint())
	--self._allJettonCount:setScale(0.75) 
	self._rootNode:addChild(self._allJettonCount,5)
	
	tms:removeFromParent()

	--指针 
	self._speedFin = self._rootNode:getChildByName("speedFinger")
	self._speedFinL = self._rootNode:getChildByName("speedFinger_0")
	self._speedFinL:setVisible(false)
	
	--按钮刷刷刷
	self._btnJettonEffectNode = self._rootNode:getChildByName("btnJettonEffect")

	local sp_liuguang = self._btnJettonEffectNode:getChildByName("Sprite_1")
	local spriteFrame = cc.SpriteFrameCache:getInstance( )  
	spriteFrame:addSpriteFrames("GameRes/GameCar/liuguang.plist")  
	local animation =cc.Animation:create()  
		for i=0,14 do  
			local frameName =string.format("%02d.png",i)                  
			local spriteFrame = spriteFrame:getSpriteFrameByName(frameName)  
			animation:addSpriteFrame(spriteFrame)                                    
		end  
		animation:setDelayPerUnit(0.05)          --设置两个帧播放时间   
		local action =cc.Animate:create(animation)      
		sp_liuguang:runAction(cc.RepeatForever:create(action))  
	
	--场景刷刷刷
	local RollPanel = self._rootNode:getChildByName("Panel_roll")
	--油门
	self._progressbg = RollPanel:getChildByName("img_proA")

	local Scene_liu = RollPanel:getChildByName("Scene_liu")
	Scene_liu:setVisible(true)
	spriteFrame:addSpriteFrames("GameRes/GameCar/benchi/Effect/changjing/changjing.plist")  
	local animation2 =cc.Animation:create()  
		for i=0,10 do  
			local frameName =string.format("c_%02d.png",i)                  
			local spriteFrame = spriteFrame:getSpriteFrameByName(frameName)  
			animation2:addSpriteFrame(spriteFrame)                                    
		end  
		animation2:setDelayPerUnit(0.08)          --设置两个帧播放时间   
		local action =cc.Animate:create(animation2)      
		Scene_liu:runAction(cc.RepeatForever:create(action))  

	--白光
	self._shotNode  = self._rootNode:getChildByName("ShotNode")
	self._shotTabel = {}
			
	for i=1,8 do
		self._shotTabel[i] = self._shotNode:getChildByName(string.format("Sprite_%d",i ))
		self._shotTabel[i]:setVisible(false)
	end
	
	

end

function GameViewLayer:createHelpLayer()
    self.m_helpLayer = cc.Node:create()
    self:addChild(self.m_helpLayer)

    --按钮事件
    local function btnEvent( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            if nil ~= self.m_helpLayer then
				self.m_helpLayer:setVisible(false)
			end
        end
    end 

	 --加载csb资源
	 local csbNode = ExternalFun.loadCSB("game_res/helpLayer.csb", self.m_helpLayer)
	 local img_bg = csbNode:getChildByName("Image_1")
     local layout_bg = csbNode:getChildByName("layout_bg")
	 layout_bg:addTouchEventListener(btnEvent)
	 
	 local btn_closeHelp = csbNode:getChildByName("btn_close")
	 btn_closeHelp:addTouchEventListener(btnEvent)
	 
	 --帮助内容
	
	 local txt_help =  cc.Label:createWithTTF("", "fonts/round_body.ttf", 24)
	 txt_help:setDimensions(480,150)
	 txt_help:setTextColor(cc.c3b(220,208,237))
	 txt_help:setString("1、豪车漂移是网络流行的转盘游戏。游戏中有4个汽车标志，大小两种代表8个不同的下注区域，游戏趣味强。\n2、黄色大注，紫色小注")
	 txt_help:setAnchorPoint(cc.p(0.0,1))
	 txt_help:setPosition(cc.p(67,256))
	 img_bg:addChild(txt_help)
end

function GameViewLayer:initTableJettons(table0,table1) --初始化下注区域筹码数目
	local addview = self._rootNode:getChildByName("add_rect")
	for i=1,g_var(cmd).AREA_COUNT do
		local jettonNode0 = addview:getChildByName(string.format("Node_%d_1", i))
		local jettonNode1 = addview:getChildByName(string.format("Node_%d_2", i))
		if nil == jettonNode0:getChildByTag(1) then
			local num = cc.Label:createWithTTF(table0[i] , "fonts/round_body.ttf", 20)
			num:setAnchorPoint(cc.p(1,0.5))
			num:setTag(1)
			num:setPosition(cc.p(jettonNode0:getContentSize().width/2,jettonNode0:getContentSize().height/2))
			jettonNode0:addChild(num)
		else
			local num = jettonNode0:getChildByTag(1)
			num:setString(table0[i] )
		end
		if nil == jettonNode1:getChildByTag(1) then
			local num = cc.Label:createWithTTF(table1[i], "fonts/round_body.ttf", 20)
			num:setAnchorPoint(cc.p(1,0.5))
			num:setTextColor(cc.c3b(255,254,143))
			num:setTag(1)
			num:setPosition(cc.p(jettonNode1:getContentSize().width/2,jettonNode1:getContentSize().height/2))
			jettonNode1:addChild(num)
		else
			local num = jettonNode1:getChildByTag(1)
			num:setString(table1[i])
		end
	end
end
--校准位置
function GameViewLayer:resetRollCarPos()
-- 	local RollPanel = self._rootNode:getChildByName("Panel_roll")
-- 	--转盘半径
--  	local radius = 295
--  	local center = cc.p(RollPanel:getContentSize().width/2,RollPanel:getContentSize().height/2)
-- --获取转盘上的车
-- 	for i=1,self.oneCircle do
-- 		 local radian = math.rad(22.5*(i-1))
-- 		 local x = radius * math.sin(radian);
--    		 local y = radius * math.cos(radian);
--  		local car = RollPanel:getChildByName(string.format("car_index_%d",i))
--  		car:setPosition(center.x + x, center.y + y)
--  	end
end
--启动转动动画
function GameViewLayer:rollAction(isEnter)
	print("self.m_cbGameStatus is ================================ >"..self.m_cbGameStatus)
	
	if self.m_cbGameStatus == g_var(cmd).GS_GAME_END then
		local RollPanel = self._rootNode:getChildByName("Panel_roll")
		if nil == RollPanel then
			print("RollPanel is nil .....")
		end
		local function runCircle()
			self.points = {}
		 	for i=1,self.oneCircle do
		 		local car = RollPanel:getChildByName(string.format("car_index_%d",i))
		 		local pos = cc.p(car:getPositionX(),car:getPositionY())
		 		table.insert(self.points, pos)
		 	end
		 	
		 	self.count = 0
		 	self:setTimePer()
		 	self.index = self.oneCircle-math.mod(self.oneCircle-self.endindex+1,self.oneCircle)
		 	self:RunCircleAction(isEnter)
		end
		--20倍开奖 
		if self:GetViewIndexByEndIndex(self.endindex) < 4 then 
			local function breathAllCar()
				for i=1,32 do
					local car = RollPanel:getChildByName(string.format("car_index_%d",i))
					local circle = cc.Sprite:create("game_res/tubiao39.png")
					circle:setTag(1)
					if i == 1 or i == 5 or i == 9 or i == 13 then
						circle:setOpacity(90)
					else
						circle:setOpacity(60)
					end
				 	circle:setPosition(cc.p(car:getContentSize().width/2,car:getContentSize().height/2))
				 	--car:addChild(circle)
				 	local callfunc = cc.CallFunc:create(function()
				 		car:removeChildByTag(1)
				 		car:stopAllActions()
				 	end)
				 	local seq = cc.Sequence:create(cc.ScaleTo:create(0.2,1.2),cc.ScaleTo:create(0.2,1.0))
				 	--car:runAction(cc.Repeat:create(seq, 100))
				 	local delay = cc.Sequence:create(cc.DelayTime:create(3),callfunc)
				 	--car:runAction(delay)
				 	
				end
			end
			breathAllCar()
			self._scene.m_cbLeftTime = self._scene.m_cbLeftTime -3
			local callfunc = cc.CallFunc:create(function (  )
		
				 	runCircle()
			end)
			self:runAction(cc.Sequence:create(cc.DelayTime:create(3),callfunc))
		else
		runCircle()
			
		end
	end
end
--初始化菜单按钮
function GameViewLayer:InitMenu()
	
end
function GameViewLayer:onResetView()
	self:gameDataReset()
end
function GameViewLayer:onExit()
	self:onResetView()
	self._laba:closeTime()
end
function GameViewLayer:gameDataReset(  )
	--资源释放
	--播放大厅背景音乐
	ExternalFun.playPlazzBackgroudAudio()
	--重置搜索路径
	local oldPaths = cc.FileUtils:getInstance():getSearchPaths();
	local newPaths = {};
	for k,v in pairs(oldPaths) do
		if tostring(v) ~= tostring(self._searchPath) then
			table.insert(newPaths, v);
		end
	end
	cc.FileUtils:getInstance():setSearchPaths(newPaths);
end
----------------------------------------------------------------------------------------
--庄家信息
function GameViewLayer:InitBankerInfo()
	--昵称
	local bankerBG =  self._rootNode:getChildByName("zhuang_listBG")
	local info = {"昵称:","成绩:","筹码:","当前庄数:"}
	for i=1,4 do
		local node = bankerBG:getChildByName(string.format("Node_%d", i))
		local lb =  cc.Label:createWithTTF(info[i], "fonts/round_body.ttf", 20)
		lb:setAnchorPoint(cc.p(1.0,0.5))
		lb:setTextColor(cc.c3b(36,236,255))
		lb:setPosition(node:getContentSize().width + 80, node:getContentSize().height/2)
		node:addChild(lb)
	end
end
--更新庄家信息
function GameViewLayer:ShowBankerInfo(info)
	if (type(info) ~= "table") or (#info==0) then
		return
	end
	local bankerBG =  self._rootNode:getChildByName("zhuang_listBG")
	bankerBG:removeChildByTag(2)
	local colors = {cc.c3b(255,255,255),cc.c3b(0,255,42),cc.c3b(255,204,0),cc.c3b(0,255,210)}
	--昵称、成绩、筹码、当前庄数
	for i=1,4 do
		local node = bankerBG:getChildByName(string.format("Node_%d_1", i))
		local label = node:getChildByTag(2)
		if nil == label then
			if 1 == i or 3 == i then
				label =  g_var(ClipText):createClipText(cc.size(140, 20),info[i])
			else
			
				label =  cc.Label:createWithTTF(info[i], "fonts/round_body.ttf", 20)
			end
			
			label:setAnchorPoint(cc.p(0.0,0.5))
			label:setTag(2)
			label:setTextColor(colors[i])
			label:setPosition(20, node:getContentSize().height/2)
			node:addChild(label)
		else
			label:setString(info[i])
		end
	end
	--玩家头像
		local headBG = ccui.ImageView:create("game_res/dikuang6.png")
		bankerBG:removeChildByTag(5)
		headBG:setAnchorPoint(cc.p(0.0,1.0))
		headBG:setTag(5)
		headBG:setPosition(cc.p(30,bankerBG:getContentSize().height - 100))
		bankerBG:addChild(headBG)
		local  useritem = info[5]
		if useritem then
			local head = g_var(PopupInfoHead):createClipHead(useritem, 47)
			head:setPosition(cc.p(headBG:getContentSize().width/2,headBG:getContentSize().height/2))
			head:setTag(1)
			headBG:addChild(head)
		end
		
end
----------------------------------------------------------------------------------------
function GameViewLayer:addRecordAssert(cbCarIndex )
	if cbCarIndex == nil then
		return
	end
	if cbCarIndex <=0 or cbCarIndex > 32 then
		error("24",0)
	end
	if #self._scene.m_RecordAssert < g_var(cmd).RECORD_MAX then --少于8条记录
		
		table.insert(self._scene.m_RecordAssert, cbCarIndex)
	else
		--删除第一条记录
		table.remove(self._scene.m_RecordAssert,1)
		table.insert(self._scene.m_RecordAssert, cbCarIndex)
	end
end
function GameViewLayer:freshRecord()
	local info  = self._scene._info
	self:ShowBankerInfo(info)
	self:SetEndView(true)
	self._scene.m_RecordList = {}
	for i=1,#self._scene.m_RecordAssert do
		local cardIndex = self._scene.m_RecordAssert[i]
		table.insert(self._scene.m_RecordList,cardIndex)
	end
	local record = self._rootNode:getChildByName("record_cell")
	if not self.bPoints then
		self.bPoints = true
		self._points = {}
		for i=1,5 do
			local pos = cc.p(59,86+(i-1)*91)
			table.insert(self._points,pos)
		end
	end
	if record:isVisible() then
		record:removeAllChildren()
		
	--记录第一个
	local recell_bg = cc.Sprite:create("GameRes/GameCar/benchi/bc_21.png")
	recell_bg:setScale(0.6)
	recell_bg:setPosition(cc.p(59,86+(5-1)*91))
	recell_bg:addTo(record)

		--刷新记录
		for i=1,#self._scene.m_RecordList do
			local viewIndex = 0
			local list = self._scene.m_RecordList[i]
			viewIndex = self:GetViewIndexByEndIndex(list)
			local cell = ccui.ImageView:create("game_res/"..string.format("record_%d.png",viewIndex))
					
			if list%2 == 1  then
				recell_bg:setScale(0.8)				
				cell:setScale(1.3)
			elseif list%2 == 0 then 
				cell:setScale(0.75)
				recell_bg:setScale(0.45)
			end
			cell:setPosition(self._points[i])
			record:addChild(cell)
		end
	end
end
--游戏记录
function GameViewLayer:addRcord( cbCarIndex )
	if cbCarIndex == nil then
		return
	end
	if cbCarIndex <=0 or cbCarIndex > 32 then
		error("24",0)
	end
	if #self._scene.m_RecordList < g_var(cmd).RECORD_MAX then --少于8条记录
		
		table.insert(self._scene.m_RecordList, cbCarIndex)
	else
		--删除第一条记录
		table.remove(self._scene.m_RecordList,1)
		table.insert(self._scene.m_RecordList, cbCarIndex)
	end
	local record = self._rootNode:getChildByName("record_cell")
	if not self.bPoints then
		self.bPoints = true
		self._points = {}
		for i=1,5 do
			local pos = cc.p(59,86+(i-1)*91)
			table.insert(self._points,pos)
		end
	end
	if record:isVisible() then
		record:removeAllChildren()
		--记录第一个
	local recell_bg = cc.Sprite:create("GameRes/GameCar/benchi/bc_21.png")
	recell_bg:setPosition(cc.p(59,86+(5-1)*91))
	recell_bg:addTo(record)

		--刷新记录
		for i=1,#self._scene.m_RecordList do
			local viewIndex = 0
			local list = self._scene.m_RecordList[i]
			viewIndex = self:GetViewIndexByEndIndex(list)
			local cell = ccui.ImageView:create("game_res/"..string.format("record_%d.png",viewIndex))
			if list%2 == 1  then
				recell_bg:setScale(0.8)				
				cell:setScale(1.3)
			elseif list%2 == 0 then 
				cell:setScale(0.75)
				recell_bg:setScale(0.45)
			end
			cell:setPosition(self._points[i])
			record:addChild(cell)
		end
	end
end
function GameViewLayer:GetViewIndexByEndIndex( list )
	local viewIndex = 0

	if list == 1 or list == 9 or list == 17 or list == 25 then 
		--大宝马
		viewIndex = 0 
	elseif list == 2 or list == 10 or list == 18 or list == 26 then
		--小宝马
		viewIndex = 0
	elseif list == 3 or list == 11 or list == 19 or list == 27 then
		--大奔驰
		viewIndex = 1
	
	elseif list == 4 or list == 12 or list == 20 or list == 28 then
		--小奔驰
		viewIndex = 1
		
	elseif list == 5 or list == 13 or list == 21 or list == 29 then
		--大大众
		viewIndex = 2
		
	elseif list == 6 or list == 14 or list == 22 or list == 30 then
		--小大众
		viewIndex = 2
		
	elseif list == 7 or list == 15 or list == 23 or list == 31 then
		--大卡迪拉克
		viewIndex = 3
	
	elseif list == 8 or list == 16 or list == 24 or list == 32 then
		--小凯迪拉克
		viewIndex = 3
				
	end

	-- if list == 1  or list == 2 or list == 12 or list == 16  then 
	-- 	viewIndex = 0 
	-- elseif list == 5 or list == 3 or list == 6 or list == 15 then
	-- 	viewIndex = 1
	-- elseif list == 9 or list == 4 or list == 7 or list == 10 then
	-- 	viewIndex = 2	
	-- elseif list == 13 or list == 8 or list == 11 or list == 14 then
	-- 	viewIndex = 3	
	-- end
	return viewIndex
end
function GameViewLayer:HiddenRecord()
	local record = self._rootNode:getChildByName("record_cell")
	record:setVisible(true)
end
function GameViewLayer:ShowRecord()
	local record = self._rootNode:getChildByName("record_cell")
	if record:isVisible() then
		record:setVisible(true)
		return
	end
	record:setVisible(true)
	record:removeAllChildren()
	--记录第一个
	local recell_bg = cc.Sprite:create("GameRes/GameCar/benchi/bc_21.png")
	recell_bg:setScale(0.6)
	recell_bg:setPosition(cc.p(59,86+(5-1)*91))
	recell_bg:addTo(record)

	--刷新记录
	for i=1,#self._scene.m_RecordList do
		local viewIndex = 0
		local list = self._scene.m_RecordList[i]
		viewIndex = self:GetViewIndexByEndIndex(list)
		local cell = ccui.ImageView:create("game_res/"..string.format("record_%d.png",viewIndex))
		
		if list%2 == 1  then
			recell_bg:setScale(0.8)				
			cell:setScale(1.3)
		elseif list%2 == 0 then 
			cell:setScale(0.75)
			recell_bg:setScale(0.45)
		end

		cell:setPosition(self._points[i])
		record:addChild(cell)
	end
end
--更新区域筹码
function GameViewLayer:UpdateAreaJetton()
	
	local table = self:ConvertToViewAreaIndex(self._scene.m_lAllJettonScore)
	self:initTableJettons(table,self._scene.m_lCurrentAddscore)

	--print("总下注 更新 " .. self:allScoreForText(self:GetAllPlaceJetton()))
	--更新下注总额
	local tmp_allScore = self:allScoreForText(self:GetAllPlaceJetton())
	self._allJettonCount:setString(tmp_allScore)
end


function GameViewLayer:allScoreForText(score)
    score=score or -1  --IORI--
	local scorestr = ExternalFun.formatScore(score)

	scorestr = string.format("%.1f", score / 10000)
	scorestr = string.gsub(scorestr,"[.]",":")
	return scorestr
end


--转换成视图索引
function GameViewLayer:ConvertToViewAreaIndex(param)
	if type(param) ~= "table"  or #param ~= g_var(cmd).AREA_COUNT then
		return
	end
	local table = {0,0,0,0,0,0,0,0}
	
	table[1] = param[g_var(cmd).ID_BMW]
	table[2] = param[g_var(cmd).ID_BENZ]
	table[3] = param[g_var(cmd).ID_JAGUAR]
	table[4] = param[g_var(cmd).ID_LANDROVER]
	table[5] = param[g_var(cmd).ID_MASERATI]
	table[6] = param[g_var(cmd).ID_FERRARI]
	table[7] = param[g_var(cmd).ID_LAMBORGHINI]
	table[8] = param[g_var(cmd).ID_PORSCHE]
	return table
end
--重置下注
function GameViewLayer:CleanAllBet()
	
	local addview = self._rootNode:getChildByName("add_rect")
	for i=1,g_var(cmd).AREA_COUNT do
		local jettonNode0 = addview:getChildByName(string.format("Node_%d_1", i))
		local jettonNode1 = addview:getChildByName(string.format("Node_%d_2", i))
		if nil ~= jettonNode0:getChildByTag(1) then
			local num = jettonNode0:getChildByTag(1)
			num:setString("0")
		end
		if nil ~= jettonNode1:getChildByTag(1) then
			local num = jettonNode1:getChildByTag(1)
			num:setString("0")
		end
	end
end
-------------------------------------------------------------------------------------------
--玩家列表
function GameViewLayer:UserListEvent( ref,eventType )
	if self._UserView == nil then
		self._UserView = g_var(UserList):create(self._scene._dataModle)
		self:addChild(self._UserView,30)
		self._UserView:reloadData()
	else
		self._UserView:setVisible(true)
		self._UserView:reloadData()
	end
end
--按钮事件
function GameViewLayer:BankerEvent(ref,eventType)
	--打开上庄列表界面
	local bankerView = self._rootNode:getChildByName("zhuang_listBG")
	bankerView:setVisible(true)
	--隐藏聊天
	local chatView = self._rootNode:getChildByName("chat_BG")
	chatView:setVisible(false)
end
function GameViewLayer:ChatEvent(ref,eventType)
	--隐藏上庄列表界面
	local bankerView = self._rootNode:getChildByName("zhuang_listBG")
	bankerView:setVisible(false)
	--打开聊天
	local chatView = self._rootNode:getChildByName("chat_BG")
	chatView:setVisible(true)
	if not self._ChatView then 
		self._ChatView = g_var(Chat):create(chatView,self._scene._dataModle,self._scene._gameFrame)
		chatView:addChild(self._ChatView)
	end
end
--------------------------------------------------------------------------------------------
--银行操作成功
function GameViewLayer:onBankSuccess( )
     self._scene:dismissPopWait()
    local bank_success = self._scene.bank_success
    if nil == bank_success then
        return
    end
    GlobalUserItem.lUserScore = bank_success.lUserScore
    GlobalUserItem.lUserInsure = bank_success.lUserInsure
    self:refreshScore()
    showToast(cc.Director:getInstance():getRunningScene(), bank_success.szDescribrString, 2)
end
--银行操作失败
function GameViewLayer:onBankFailure( )
     self._scene:dismissPopWait()
    local bank_fail = self._scene.bank_fail
    if nil == bank_fail then
        return
    end
    showToast(cc.Director:getInstance():getRunningScene(), bank_fail.szDescribeString, 2)
end
  --刷新游戏币
function GameViewLayer:refreshScore( )
    --携带游戏币
    local str = ExternalFun.numberThousands(GlobalUserItem.lUserScore)
    if string.len(str) > 19 then
        str = string.sub(str, 1, 19)
    end
    self.textCurrent:setString(str)
    --银行存款
    str = ExternalFun.numberThousands(GlobalUserItem.lUserInsure)
    if string.len(str) > 19 then
        str = string.sub(str, 1, 19)
    end
    
    self.textBank:setString(ExternalFun.numberThousands(GlobalUserItem.lUserInsure))
end
--银行
function GameViewLayer:btnBankEvent(ref,eventType)
	if eventType == ccui.TouchEventType.ended then
		if 0 ==GlobalUserItem.cbInsureEnabled then --判断是否已经开通银行
			showToast(cc.Director:getInstance():getRunningScene(), "请开通银行", 2)
			return
		end
		 --申请取款
        local function sendTakeScore( lScore,szPassword )
            local cmddata = ExternalFun.create_netdata(g_var(game_cmd).CMD_GR_C_TakeScoreRequest)
            cmddata:setcmdinfo(g_var(game_cmd).MDM_GR_INSURE, g_var(game_cmd).SUB_GR_TAKE_SCORE_REQUEST)
            cmddata:pushbyte(g_var(game_cmd).SUB_GR_TAKE_SCORE_REQUEST)
            cmddata:pushscore(lScore)
            cmddata:pushstring(GlobalUserItem.PasswordEncryption(szPassword),yl.LEN_PASSWORD)
            self._scene:sendNetData(cmddata)
        end
       	 local function onTakeScore( )
                --参数判断
                local szScore = string.gsub( self.m_editNumber:getText(),"([^0-9])","")
                local szPass =   self.m_editPasswd:getText()
                if #szScore < 1 then 
                    showToast(cc.Director:getInstance():getRunningScene(),"请输入操作金额！",2)
                    return
                end
                local lOperateScore = tonumber(szScore)
                if lOperateScore<1 then
                    showToast(cc.Director:getInstance():getRunningScene(),"请输入正确金额！",2)
                    return
                end
                if #szPass < 1 then 
                    showToast(cc.Director:getInstance():getRunningScene(),"请输入银行密码！",2)
                    return
                end
                if #szPass <6 then
                    showToast(cc.Director:getInstance():getRunningScene(),"密码必须大于6个字符，请重新输入！",2)
                    return
                end
                self:showPopWait()
                sendTakeScore(lOperateScore,szPass)
                
         end
		if nil ==  self._bank then
			self._bank = ccui.ImageView:create()
			self._bank:setContentSize(cc.size(yl.WIDTH, yl.HEIGHT))
	        self._bank:setScale9Enabled(true)
	        self._bank:setPosition(yl.WIDTH/2, yl.HEIGHT)
	        self._bank:setTouchEnabled(true)
	        self:addChild(self._bank,TAG_ZORDER.BANK_ZORDER)
	        self._bank:addTouchEventListener(function (sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                 self._bank:runAction(cc.MoveTo:create(0.2,cc.p(yl.WIDTH/2, yl.HEIGHT*1.5)))
             
            end
        end)
	        --加载CSB
	        local csbnode = cc.CSLoader:createNode("game_res/Bank.csb");
	        csbnode:setPosition(self._bank:getContentSize().width/2	, self._bank:getContentSize().height/2)
		    self._bank:addChild(csbnode);
		--当前游戏币
			 local curNode = csbnode:getChildByName("Node_Current") 
			 self.textCurrent = cc.Label:createWithTTF("0", "fonts/round_body.ttf", 20)
			 self.textCurrent:setTextColor(cc.YELLOW)
			 self.textCurrent:setAnchorPoint(cc.p(0.0,0.5))
			 self.textCurrent:setPosition(-15, curNode:getContentSize().height/2)
			 curNode:addChild(self.textCurrent)
		--银行游戏币
			local bankNode = csbnode:getChildByName("Node_2")
			self.textBank = cc.Label:createWithTTF("0", "fonts/round_body.ttf", 20)	
			self.textBank:setTextColor(cc.YELLOW)
			self.textBank:setAnchorPoint(cc.p(0.0,0.5))
			self.textBank:setPosition(-15, bankNode:getContentSize().height/2)
			bankNode:addChild(self.textBank)
			self:refreshScore()
			--取款金额
		    local editbox = ccui.EditBox:create(cc.size(246, 44),"bank_res/dikuang26.png")
		        :setPosition(cc.p(28.5,0))
		        :setFontName("fonts/round_body.ttf")
		        :setPlaceholderFontName("fonts/round_body.ttf")
		        :setFontSize(24)
		        :setPlaceholderFontSize(24)
		        :setMaxLength(32)
		        :setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		        :setPlaceHolder("请输入取款金额")
		    csbnode:addChild(editbox)
		    self.m_editNumber = editbox
		  
		    --取款密码
		    editbox = ccui.EditBox:create(cc.size(246, 44),"bank_res/dikuang26.png")
		        :setPosition(cc.p(28.5,-62))
		        :setFontName("fonts/round_body.ttf")
		        :setPlaceholderFontName("fonts/round_body.ttf")
		        :setFontSize(24)
		        :setPlaceholderFontSize(24)
		        :setMaxLength(32)
		       
		        :setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
		        :setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		        :setPlaceHolder("请输入取款密码")
		    csbnode:addChild(editbox)
		    self.m_editPasswd = editbox
        --取款按钮
	        local btnTake = csbnode:getChildByName("btn_take")
	        btnTake:addTouchEventListener(function( sender , envetType )
	            if envetType == ccui.TouchEventType.ended then
	                onTakeScore()
	            end
	        end)
		    --关闭按钮
			local btnClose = csbnode:getChildByName("btn_close")
        	btnClose:addTouchEventListener(function( sender , eventType )
            if eventType == ccui.TouchEventType.ended then
                self._bank:runAction(cc.MoveTo:create(0.2,cc.p(yl.WIDTH/2, yl.HEIGHT*1.5)))
            end
       	 end)
		end
		
		self._bank:runAction(cc.MoveTo:create(0.2,cc.p(yl.WIDTH/2, yl.HEIGHT/2)))
	end
end
---------------------------------------------------------------------------------------------
function GameViewLayer:setMorenJetton( index  , isJettonStatus)
	
	if isJettonStatus then
		self:SetJettonIndex(index)
	end
	self.lastJettonIndex = index
end

--加注
function GameViewLayer:JettonEvent( ref ,eventType )
	if eventType == ccui.TouchEventType.ended then
		local btn = ref
		local index = btn:getTag() - 100 
		self:SetJettonIndex(index)
		self.lastJettonIndex = index
	end
end
--续压
function GameViewLayer:ContinueEvent( ref,eventType )
	if self:GetJettonRecord() > self.m_scoreUser then
		local runScene = cc.Director:getInstance():getRunningScene()
		showToast(runScene, "下注筹码不足", 1)
		self.bContinueRecord = true
		self:updateControl(g_var(cmd).Continue)
		return
	end
	self.bContinueRecord = true
	for i=1,#self._scene.m_lContinueRecord do  
		if self._scene.m_lContinueRecord[i] > 0 then
			--发送加注 i是逻辑索引
			self._scene:sendUserBet(i,self._scene.m_lContinueRecord[i])
			--视图索引
			local areaIndex = self:GetViewAreaIndex(i)
			self._scene.m_lCurrentAddscore[areaIndex] = self._scene.m_lCurrentAddscore[areaIndex] + self._scene.m_lContinueRecord[i]
			self._scene.m_lAllJettonScore[i] = self._scene.m_lAllJettonScore[i] + self._scene.m_lContinueRecord[i]
		end
	end
	--刷新桌面坐标
	self:UpdateAreaJetton()
	--刷新操作按钮
	self:updateControl(g_var(cmd).Jettons)
	self:updateControl(g_var(cmd).Continue)
end
--申请庄家
function GameViewLayer:ApplyEvent( ref,eventType )
	if self.m_eApplyStatus == GameViewLayer.unKnown then
		return
	end
	local userItem = self._scene:GetMeUserItem()
	print("当前状态 = "..self.m_eApplyStatus)
	if self.m_eApplyStatus == GameViewLayer.unApply then 
		--发送申请
		print("============发送申请=============================")
		local cmddata = ExternalFun.create_netdata(g_var(cmd).CMD_S_ApplyBanker)
	    cmddata:pushword(userItem.wChairID)
   		self._scene:SendData(g_var(cmd).SUB_C_APPLY_BANKER, cmddata)
	elseif self.m_eApplyStatus == GameViewLayer.applyed then
		print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
		--发送取消
		local cmddata = ExternalFun.create_netdata(g_var(cmd).CMD_S_ApplyBanker)
	    cmddata:pushword(userItem.wChairID)
   		self._scene:SendData(g_var(cmd).SUB_C_CANCEL_BANKER, cmddata)
	end
	self.m_eApplyStatus = GameViewLayer.unKnown
end
function GameViewLayer:PlaceJettonEvent( ref,eventType )
	local btn = ref
	local areaIndex = btn:getTag() - 200	--转换成视图索引
	local userItem = self._scene:GetMeUserItem()
	--当前庄家是自己
	if userItem.wChairID == self._scene.m_wBankerUser then
		return
	end
	local logicAreaIndex = self:GetLogicAreaIndex(areaIndex)	--逻辑索引
	
	if self:GetTotalCurrentPlaceJetton() + self._scene.BetArray[self.JettonIndex] > self._scene.m_lUserMaxScore  then
		return
	end
	if self._scene.BetArray[self.JettonIndex] > userItem.lScore*self._scene.m_nMultiple  then
		return
	end
	self._scene.m_lCurrentAddscore[areaIndex] = self._scene.m_lCurrentAddscore[areaIndex] + self._scene.BetArray[self.JettonIndex]
	self._scene.m_lAllJettonScore[logicAreaIndex] = self._scene.m_lAllJettonScore[logicAreaIndex] + self._scene.BetArray[self.JettonIndex]
	--发送加注
	self._scene:sendUserBet(logicAreaIndex,self._scene.BetArray[self.JettonIndex])
	--刷新桌面坐标
	self:UpdateAreaJetton()
	--刷新操作按钮
	self:updateControl(g_var(cmd).Jettons)
	self:updateControl(g_var(cmd).Continue)
	self:playEffect("sound_res/ADD_GOLD.wav")
end
-------------------------------------------------------------------------------------------------------------------------------------
function GameViewLayer:SetJettonIndex( index )	--筹码索引
	--local addview = self._rootNode:getChildByName("add_rect")
	if index <= 0 or index > g_var(cmd).JETTON_COUNT then
	
		local lightCircle = self._rootNode:getChildByTag(200)
		if nil ~= lightCircle then
			lightCircle:setVisible(false)
		end
		return
	end
	self.JettonIndex = index
	--选择的目标筹码
	local jetton = self._rootNode:getChildByName(string.format("bet_%d", index))
	if not self._rootNode:getChildByTag(200) then  --光圈
		local lightCircle = ccui.ImageView:create("GameRes/GameCar/benchi/bt_score_light.png")
		lightCircle:setAnchorPoint(cc.p(0.5,0.5))
		lightCircle:setScaleX(1.25)
		lightCircle:setScaleY(1.2)
		lightCircle:setPosition(cc.p(jetton:getPositionX(),jetton:getPositionY()))
		lightCircle:setTag(200)
		self._rootNode:addChild(lightCircle)
	else
		local lightCircle = self._rootNode:getChildByTag(200)
		lightCircle:setVisible(true)
		lightCircle:setPosition(cc.p(jetton:getPositionX(),jetton:getPositionY()))
	end
end
function GameViewLayer:GetJettonIndexInvalid() --获取索引
	if self.JettonIndex <= 0 or self.JettonIndex > g_var(cmd).JETTON_COUNT then
		return false
	end
	return true
end
function GameViewLayer:SetClockType(timetype) --设置倒计时
	local RollPanel = self._rootNode:getChildByName("Panel_roll")
	--中间空间时间的tip csb里隐藏了
	local typeImage = RollPanel:getChildByName("time_type")
	typeImage:setVisible(false)
	if timetype == g_var(cmd).CLOCK_FREE then
		self:updateScore(self.m_scoreUser)
		typeImage:loadTexture("game_res/tubiao42.png")
	elseif timetype == g_var(cmd).CLOCK_ADDGOLD then
		typeImage:loadTexture("game_res/tubiao41.png")
	else
		typeImage:loadTexture("game_res/tubiao40.png")
	end
end
function GameViewLayer:SetApplyStatus( status )
	if self.m_eApplyStatus == status then
		return
	end
	self.m_eApplyStatus = status
	self:SetApplyTexture()
end
function GameViewLayer:SetApplyTexture()
	local bankerBG =  self._rootNode:getChildByName("zhuang_listBG")
	local applyBtn = bankerBG:getChildByName("btn_apply")
	if self.m_eApplyStatus == GameViewLayer.unApply then 
		applyBtn:loadTextureNormal("game_res/anniu9.png")
	elseif self.m_eApplyStatus == GameViewLayer.applyed then
		applyBtn:loadTextureNormal("game_res/anniu11.png")
		
	end
end
function GameViewLayer:setClockTypeIsVisible(visible) --倒计时类型
	local RollPanel = self._rootNode:getChildByName("Panel_roll")
	local typeImage = RollPanel:getChildByName("time_type")
	typeImage:setVisible(visible)
end
--结束 结算 面板 
function GameViewLayer:SetEndView(visible)
	--local RollPanel = self._rootNode:getChildByName("Panel_roll")
	local endview = self._rootNode:getChildByName("endView")
	endview:setVisible(visible)

	local img_index 
	--获取车名
	--宝马 奔驰 捷豹 路虎  5倍  
	--小 宝马 2 10 18  26  奔驰 4 12 20 28 大众 6 14 22 30 保时捷 8 16 24 32   5倍
	--大 宝马 1 9 19 27    奔驰 3 11 19 27 大众 5 13 21 29 保时捷 7 15 23 31   20倍
	--捷报 = 大众
	-- 路虎 =  卡迪拉克
	local cartype = endview:getChildByName("Car_Type")
	if self.endindex == 1 or self.endindex == 9 or self.endindex == 17 or self.endindex == 25 then 
		--大宝马
	    img_index = 11
	elseif self.endindex == 2 or self.endindex == 10 or self.endindex == 18 or self.endindex == 26 then
		--小宝马 
		img_index = 11
	elseif self.endindex == 3 or self.endindex == 11 or self.endindex == 19 or self.endindex == 27 then
		--大奔驰 
		img_index = 13
	elseif self.endindex == 4 or self.endindex == 12 or self.endindex == 20 or self.endindex == 28 then
		--小奔驰
		img_index = 13
	elseif self.endindex == 5 or self.endindex == 13 or self.endindex == 21 or self.endindex == 29 then
		--大大众     
		img_index = 15
	elseif self.endindex == 6 or self.endindex == 14 or self.endindex == 22 or self.endindex == 30 then
		--小捷豹
		img_index = 15
	elseif self.endindex == 8 or self.endindex == 16 or self.endindex == 24 or self.endindex == 32 then
		--小路虎
		img_index = 10
	elseif self.endindex == 7 or self.endindex == 15 or self.endindex == 23 or self.endindex == 31 then
		--大路虎
		img_index = 10	
	end

	if img_index ~=nil then
		self:showGameEndedAni(img_index)
	end
end
--结算动画 
function GameViewLayer:showGameEndedAni( index )
	--结算特效
	--local RollPanel = self._rootNode:getChildByName("Panel_roll")
	local endview = self._rootNode:getChildByName("endView")
	
	local spriteFrame = cc.SpriteFrameCache:getInstance( )  
	spriteFrame:addSpriteFrames("GameRes/GameCar/kaijiang.plist")  
	local animation =cc.Animation:create()  
	for i=0,39 do  
		local frameName =string.format("k%02d.png",i)                  
		local spriteFrame = spriteFrame:getSpriteFrameByName(frameName)  
	   animation:addSpriteFrame(spriteFrame)                                    
	end  
   	animation:setDelayPerUnit(0.08)          --设置两个帧播放时间   
	local action =cc.Animate:create(animation)      
	endview:runAction(cc.Sequence:create(action,cc.DelayTime:create(1.0),cc.CallFunc:create(function (  )
		endview:setVisible(false)
	end),nil))  

	--print(" index 是多少 : " .. index)
	local showIcon = cc.Sprite:create(string.format("GameRes/GameCar/benchi/bc_%d.png",tonumber(index)))
	showIcon:setPosition(cc.p(endview:getContentSize().width/2,endview:getContentSize().height/2))
	endview:addChild(showIcon)
	showIcon:setTag(7)
	showIcon:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5,1.6),cc.ScaleTo:create(0.5,1.3),cc.DelayTime:create(2.2),cc.DelayTime:create(1.0),
			cc.CallFunc:create(function (  )
				showIcon:setVisible(false)
			end),nil))

end
function GameViewLayer:SetEndInfo(lBankerScore,lUserScore)
	--local RollPanel = self._rootNode:getChildByName("Panel_roll")
	local endview = self._rootNode:getChildByName("endView")
	local infoBG = endview:getChildByName("end_detail")
	if nil ~= infoBG then
		infoBG:removeChildByTag(1)
		infoBG:removeChildByTag(2)
		lBankerScore = lBankerScore * self._scene.m_nMultiple
		lUserScore = lUserScore * self._scene.m_nMultiple
		local str 
	    if lBankerScore >= 0 then
	        str = "+"..ExternalFun.numberThousands(lBankerScore)
	    else
	        str = ExternalFun.numberThousands(lBankerScore)
	    end
	    local str1 
	    if lUserScore >= 0 then
	        str1 = "+"..ExternalFun.numberThousands(lUserScore)
	    else
	        str1 = ExternalFun.numberThousands(lUserScore)
	    end
		--庄家输赢
		local BankerWinScore = cc.Label:createWithTTF(str, "fonts/round_body.ttf", 20)
		BankerWinScore:setTag(1)
		BankerWinScore:setTextColor(cc.c3b(36,236,255))
		BankerWinScore:setAnchorPoint(cc.p(0.0,0.5))
		BankerWinScore:setPosition(110,56)
		infoBG:addChild(BankerWinScore)
		--玩家输赢
		local UserWinScore = cc.Label:createWithTTF(str1, "fonts/round_body.ttf", 20)
		UserWinScore:setTag(2)
		UserWinScore:setTextColor(cc.c3b(255,204,0))
		UserWinScore:setAnchorPoint(cc.p(0.0,0.5))
		UserWinScore:setPosition(110,25)
		infoBG:addChild(UserWinScore)
	end
end
function GameViewLayer:GetLogicAreaIndex( cbArea )
	local logicIndex = -1
	if cbArea == 1 then
		--宝马
		logicIndex = g_var(cmd).AREA_BMW
	elseif cbArea == 2 then
		--奔驰
		logicIndex = g_var(cmd).AREA_BENZ
	elseif cbArea == 3 then
		--捷豹
		logicIndex = g_var(cmd).AREA_JAGUAR
	elseif cbArea == 4 then
		--路虎
		logicIndex = g_var(cmd).AREA_LANDROVER
	elseif cbArea == 5 then
		--玛莎拉蒂
		logicIndex = g_var(cmd).AREA_MASERATI	
	elseif cbArea == 6 then
		--法拉利
		logicIndex = g_var(cmd).AREA_FERRARI
	elseif cbArea == 7 then
		--兰博基尼
		logicIndex = g_var(cmd).AREA_LAMBORGHINI
	elseif cbArea == 8 then
		--保时捷
		logicIndex = g_var(cmd).AREA_PORSCHE
	end
	return logicIndex + 1
end
function GameViewLayer:GetViewAreaIndex( logicIndex )
	logicIndex = logicIndex - 1
	local viewIndex = -1
	if logicIndex == g_var(cmd).AREA_BMW then
		--宝马
		viewIndex = 1
	elseif logicIndex == g_var(cmd).AREA_BENZ then
		--奔驰
		viewIndex = 2
	elseif logicIndex == g_var(cmd).AREA_JAGUAR then
		--捷豹
		viewIndex = 3
	elseif logicIndex == g_var(cmd).AREA_LANDROVER then
		--路虎
		viewIndex = 4
	elseif logicIndex == g_var(cmd).AREA_MASERATI then
		--玛莎拉蒂
		viewIndex = 5
	elseif logicIndex == g_var(cmd).AREA_FERRARI then
		--法拉利
		viewIndex = 6
	elseif logicIndex == g_var(cmd).AREA_LAMBORGHINI then
		--兰博基尼
		viewIndex = 7
	elseif logicIndex == g_var(cmd).AREA_PORSCHE then
		--保时捷
		viewIndex = 8
	end
	return viewIndex
	
end
function GameViewLayer:GetTotalCurrentPlaceJetton()
	local cur = 0
	for i=1,#self._scene.m_lCurrentAddscore do
		cur = cur + self._scene.m_lCurrentAddscore[i]
	end
	return cur
end
function GameViewLayer:GetAllPlaceJetton()
	local total = 0
	for i=1,#self._scene.m_lAllJettonScore do
		total = total + self._scene.m_lAllJettonScore[i]
	end
	return total
end
function GameViewLayer:GetJettonRecord()
	local record = 0
	for i=1,#self._scene.m_lContinueRecord do
		record = record + self._scene.m_lContinueRecord[i]
	end
	return record
end
----------------------------------------------------------------------------------------------------------------------------------------
function GameViewLayer:TouchUserInfo()  --点击用户头像显示信息
	
end
--------------------------------------------------------------
--------------------------------------------------------------
--倒计时
function GameViewLayer:createClockView(time,viewtype)
	if nil ~= self.m_pClock then
		self.m_pClock:removeFromParent()
		self.m_pClock = nil
	end
	if nil ~= self.m_pClockz then
		self.m_pClockz:removeFromParent()
		self.m_pClockz = nil
	end
	local RollPanel = self._rootNode:getChildByName("Panel_roll")
	if viewtype == 0 then --转盘界面
		local mtime = self._rootNode:getChildByName("mTime")
		self.m_pClock = cc.LabelAtlas:create(string.format("%d",time),"GameRes/GameCar/benchi/num_cutDown.png",84,77,string.byte("0"))
		self.m_pClock:setAnchorPoint(mtime:getAnchorPoint())
		self.m_pClock:setPosition(mtime:getPosition())
		self._rootNode:addChild(self.m_pClock, TAG_ZORDER.CLOCK_ZORDER)
	else  --下注界面
		local addview = self._rootNode:getChildByName("add_rect")
		local time_tips = addview:getChildByName("time_tips")
		self.m_pClock = cc.LabelAtlas:create(string.format("%d",time),"GameRes/GameCar/benchi/num_cutDown.png",84,77,string.byte("0"))
		self.m_pClock:setAnchorPoint(time_tips:getAnchorPoint())
		self.m_pClock:setPosition(time_tips:getPosition())
		addview:addChild(self.m_pClock)
		--转盘时间和下注同步 新建clock
		local mtime = self._rootNode:getChildByName("mTime")
		self.m_pClockz = cc.LabelAtlas:create(string.format("%d",time),"GameRes/GameCar/benchi/num_cutDown.png",84,77,string.byte("0"))
		self.m_pClockz:setAnchorPoint(mtime:getAnchorPoint())
		self.m_pClockz:setPosition(mtime:getPosition())
		self._rootNode:addChild(self.m_pClockz, TAG_ZORDER.CLOCK_ZORDER)
	end
end
function GameViewLayer:UpdataClockTime(clockTime)
	
	if nil ~= self.m_pClock then
		self.m_pClock:setString(string.format("%d",clockTime))
	end
	if nil ~= self.m_pClockz then
		self.m_pClockz:setString(string.format("%d",clockTime))
	end
	
	if clockTime == 0 then
		self:LogicTimeZero()
	end
end
function GameViewLayer:LogicTimeZero()  --倒计时0处理
	local RollPanel = self._rootNode:getChildByName("Panel_roll")
	local typeImage = RollPanel:getChildByName("time_type")
	typeImage:setVisible(false)
	if nil ~= self.m_pClock then
		self._scene:KillGameClock()
		self.m_pClock:removeFromParent()
		self.m_pClock = nil
	end
	if nil ~= self.m_pClockz then
		self.m_pClockz:removeFromParent()
		self.m_pClockz = nil
	end
	if self.m_cbGameStatus == g_var(cmd).GAME_SCENE_FREE then
		self:removeAction()
		self:restData()
		self:RollDisAppear()
		self:AddViewSlipToShow()
	elseif self.m_cbGameStatus ==  g_var(cmd).GS_PLACE_JETTON then
		self:AddViewSlipToHidden()
		self:playEffect("sound_res/STOPADD_GOLD.wav")
	elseif self.m_cbGameStatus == g_var(cmd).GS_GAME_END then
	    local info  = self._scene._info
	    self:ShowBankerInfo(info)
		self:SetEndView(true)
		--清理下注
		self:initTableJettons({0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0})
		--隐藏时间类型
 		self:setClockTypeIsVisible(false)
 		--self:
 		if self._scene.m_bAllowJoin then
 			--插入记录
	    	self:addRcord(self.endindex)
 		end
 		--移除倒计时
		if nil ~= self.m_pClock then
			self._scene:KillGameClock()
			self.m_pClock:removeFromParent()
			self.m_pClock = nil
		end
		
	end
end
--------------------------------------------------------------
function GameViewLayer:GetJettons()		--下注筹码
	local btns = {}
	--local addview = self._rootNode:getChildByName("add_rect")
	for i=1,g_var(cmd).JETTON_COUNT do
		local btn = self._rootNode:getChildByName(string.format("bet_%d", i))
		table.insert(btns, btn)
	end
	return btns
end
function GameViewLayer:updateControl(ButtonType)  --更新按钮状态
	local userItem = self._scene:GetMeUserItem()
	if ButtonType == g_var(cmd).Apply then         --申请庄家按钮
		local bankerBG =  self._rootNode:getChildByName("zhuang_listBG")
		local applyBtn = bankerBG:getChildByName("btn_apply")
		if userItem.lScore * self._scene.m_nMultiple < self._scene.m_lApplyBankerCondition  then
			applyBtn:setEnabled(false)
		else
			if self.m_cbGameStatus ~= g_var(cmd).GAME_SCENE_FREE and userItem.wChairID == self._scene.m_wBankerUser or not self._scene.bEnableSysBanker then
				applyBtn:setEnabled(false)
				return
			end
			applyBtn:setEnabled(true)
		end
	elseif ButtonType == g_var(cmd).Jettons then   --加注按钮
		local totalCurrentAddScore = 0
		for i=1,#self._scene.m_lCurrentAddscore do
			totalCurrentAddScore = totalCurrentAddScore + self._scene.m_lCurrentAddscore[i]
		end
		local tmp_index = 0
		local btns = self:GetJettons()
		for i=1,#btns do
			if self.m_cbGameStatus == g_var(cmd).GS_PLACE_JETTON then
				
				if self._scene.BetArray[i] > self._scene.m_lUserMaxScore-totalCurrentAddScore or self._scene.BetArray[i] > userItem.lScore*self._scene.m_nMultiple or not self._scene.bEnableSysBanker then
					btns[i]:setEnabled(false)
					--self._btnJetton:setEnabled(false)
					if self.JettonIndex == i then 
						--self:SetJettonIndex(0)
					end
				else
					self._btnJetton:setEnabled(true)
					btns[i]:setEnabled(true)
					tmp_index = i
					--self:SetJettonIndex(i)
					
				end
			else
				btns[i]:setEnabled(false)
				self._btnJetton:setEnabled(false)
				if self.JettonIndex == i then 
					self:SetJettonIndex(0)
				end
			end
		end

		if self.JettonIndex > tmp_index then
			self.JettonIndex = tmp_index
			self:SetJettonIndex(self.JettonIndex)
		end
		
	elseif ButtonType == g_var(cmd).Continue then  --续压按钮
		--dump(self._scene.m_lContinueRecord, "self._scene.m_lContinueRecord is =========>	", 6)
		local addview = self._rootNode:getChildByName("add_rect")
		local ContinueBtn = addview:getChildByName("btn_continue")
		if self.bContinueRecord then --每局续压只能一次
			ContinueBtn:setEnabled(false)
			return
		end
		if self.m_cbGameStatus ~= g_var(cmd).GS_PLACE_JETTON  or self:GetJettonRecord() == 0 then 
			ContinueBtn:setEnabled(false)
		else
			ContinueBtn:setEnabled(true)
		end
	end	
end

function GameViewLayer:updateLastJetton(index)
	if index == nil  or index == 0 then
		return
	end
	if self.m_scoreUser >= self.arr_jetton[index] then
		self:SetJettonIndex(index)
	elseif self.m_scoreUser >=1000 then
		self:SetJettonIndex(1)
	end
	
end
------------------------------------------------------------------------------------------------------------
--动画
function GameViewLayer:RollApear(isEnter) --转盘出现

	--转动之前  计时器隐藏  执行闪光刷刷刷  和 背景溜光
	self:setClockTypeIsVisible(visible)
	--闪光 刷
	for i=1,8 do
		self._shotTabel[i]:setVisible(true)
		self._shotTabel[i]:runAction(cc.Sequence:create(cc.Blink:create(1.0,1),
			cc.DelayTime:create(0.5),
			cc.Blink:create(1.5,3),cc.CallFunc:create(function (  )
				--self._shotTabel[i]:setVisible(false)
				
			end),nil))
	end 

	-- self._btnJetton:setEnabled(true)
	-- self._btnJetton:setEnabled(false)
	self._isShowAddRect = false	
	local addview = self._rootNode:getChildByName("add_rect")
	addview:setPosition(cc.p(667,-300))

	self:SetEndView(false)
	self:CleanAllBet()
	local RollPanel = self._rootNode:getChildByName("Panel_roll")
	local callfunc = cc.CallFunc:create(function()
		self:rollAction(isEnter)
	end)
	if not self.bAnimate then 
		RollPanel:setPosition(cc.p(667,375))
		self:rollAction(isEnter)
		return
	end
	--延迟三秒在 转动   指针动画 
	--20 20 40 40

	local call_startSound = cc.CallFunc:create(function (  )
		self:playEffectByz(TAG_EFFECT.TAG_START)
	end)
	local call_stopSound = cc.CallFunc:create(function (  )
		self:playEffectByz(TAG_EFFECT.TAG_DOWN)
	end)
	local call_loopSound = cc.CallFunc:create(function (  )
		self:playEffectByz(TAG_EFFECT.TAG_LOOP)
	end)
	local call_waringSound = cc.CallFunc:create(function (  )
		self:playEffectByz(TAG_EFFECT.TAG_WARING)
	end)

	local delay_1 = cc.DelayTime:create(1.0)
	local ro1 = cc.RotateBy:create(0.4,20)
	local ro2 = cc.RotateBy:create(0.5,40)
	
	local delay_2 = cc.DelayTime:create(1.0)
	local ro_re1 = cc.RotateBy:create(0.4,-20)
	local ro_re2 = cc.RotateBy:create(0.5,-40)

	local ro3 = cc.RotateBy:create(4,200)
	local delay_3 = cc.DelayTime:create(2)
	local ro3Toba = cc.RotateBy:create(3,-200)

	local repe1 = cc.Repeat:create(cc.Sequence:create(ro1,ro_re1,nil),2)
	local repe2 = cc.Repeat:create(cc.Sequence:create(ro2,ro_re2,nil),2)
	local repe3 = cc.Sequence:create(ro3,delay_3,ro3Toba,nil)
	

	self._speedFin:runAction(cc.Sequence:create(delay_1,repe1,repe2,delay_2,repe3,nil))


	local delay_12 = cc.DelayTime:create(1.0)

	local ro12 = cc.RotateBy:create(0.4,20)
	local ro22 = cc.RotateBy:create(0.5,40)

	local delay_22 = cc.DelayTime:create(1.0)
	local ro_re12 = cc.RotateBy:create(0.4,-20)
	local ro_re22 = cc.RotateBy:create(0.5,-40)

	local repe12 = cc.Repeat:create(cc.Sequence:create(ro12,ro_re12,nil),2)
	local repe22 = cc.Repeat:create(cc.Sequence:create(ro22,ro_re22,nil),2)
	local ro4 = cc.RotateBy:create(4,260)
	local delay_4 = cc.DelayTime:create(2)
	local ro4Toba = cc.RotateBy:create(3,-260)
	local repe4 = cc.Sequence:create(ro4,delay_4,ro4Toba,nil)

	self._speedFinL:runAction(cc.Sequence:create(delay_12,repe12,repe22,delay_22,repe4,nil))

	
	local sp_prob = cc.Sprite:create("GameRes/GameCar/benchi/processB.png")
	local delay_13 = cc.DelayTime:create(1.0)
	local pgto_1 = cc.ProgressTo:create(0.4, 10)  
	local pgto_2 = cc.ProgressTo:create(0.4, 0)  
	
	local delay_132 = cc.DelayTime:create(1.0)
	local pgto_3 = cc.ProgressTo:create(0.5, 20)  
	local pgto_4 = cc.ProgressTo:create(0.5, 0)  
	local repe13 = cc.Repeat:create(cc.Sequence:create(pgto_1,pgto_2,nil),2)
	local repe23 = cc.Repeat:create(cc.Sequence:create(pgto_3,pgto_4,nil),2)

	local delay_43 = cc.DelayTime:create(2)
	local pgto_5 = cc.ProgressTo:create(4, 80) 
	local pgto_6 = cc.ProgressTo:create(3, 0)   
	local repe43 = cc.Sequence:create(pgto_5,delay_43,pgto_6,nil)

	local play_1 = cc.ProgressTimer:create(sp_prob) 
	play_1:setScale(1.1)
	play_1:setRotation(180)
    play_1:setType( cc.PROGRESS_TIMER_TYPE_RADIAL )  
    RollPanel:addChild(play_1)  
    play_1:setPosition(self._progressbg:getPosition())
	play_1:runAction(cc.Sequence:create(delay_13,repe13,repe23,delay_132,repe43,cc.CallFunc:create(function (  )
		play_1:removeFromParent()
	end),nil)) 
	

	self:runAction(cc.Sequence:create(call_waringSound,cc.DelayTime:create(1.2),call_waringSound,cc.DelayTime:create(1.0),call_startSound,cc.DelayTime:create(6.5),call_loopSound,cc.DelayTime:create(3.0),call_stopSound,nil))

	RollPanel:stopAllActions()
	RollPanel:runAction(cc.Sequence:create(cc.DelayTime:create(2.8),cc.MoveTo:create(0.4,cc.p(667,375)),callfunc))

	-- RollPanel:stopAllActions()
	-- RollPanel:runAction(cc.Sequence:create(cc.MoveTo:create(0.4,cc.p(667,385)),callfunc))
end
function GameViewLayer:RollDisAppear() --转盘弹出

	local RollPanel = self._rootNode:getChildByName("Panel_roll")
	if not self.bAnimate then 
		--RollPanel:setPosition(cc.p(667,980))
		RollPanel:setPosition(cc.p(667,375))
		return
	end
	--
	for i=1,8 do
		self._shotTabel[i]:setVisible(false)
	end 
	  
	RollPanel:stopAllActions()
	RollPanel:runAction(cc.MoveTo:create(0.4,cc.p(667,375)))
end
--加注界面弹出
function GameViewLayer:AddViewSlipToShow() --下注界面
	if self.m_cbGameStatus == g_var(cmd).GS_GAME_END  then
		return
	end
	self._isShowAddRect = true	
	local addview = self._rootNode:getChildByName("add_rect")
	if not self.bAnimate then 
		addview:setPosition(cc.p(667,390))
		return
	end
	addview:stopAllActions()
	
	addview:runAction(cc.MoveTo:create(0.2,cc.p(667,390)))
end
--加注界面隐藏
function GameViewLayer:AddViewSlipToHidden()

	self._isShowAddRect = false	
	local addview = self._rootNode:getChildByName("add_rect")
	if not self.bAnimate then 
		addview:setPosition(cc.p(667,-300))
		return
	end
	addview:stopAllActions()

	addview:runAction(cc.MoveTo:create(0.1,cc.p(667,-300)))
end
function GameViewLayer:RunCircleAction(isEnter)	--转动动画
	
	local RollPanel = self._rootNode:getChildByName("Panel_roll")

 	--光圈默认位置
 	if nil == self.firstRoll then
	 	self.firstRoll = cc.Sprite:create("GameRes/GameCar/benchi/btnEffect.png")
		self.firstRoll:setPosition(self.points[1].x, self.points[1].y)
		self.firstRoll:setScale(0.62)
	 	self.firstRoll:setTag(1)
		 RollPanel:addChild(self.firstRoll)
		 
		-- self.m_car = cc.Sprite:create("GameRes/GameCar/benchi/car.png")
		-- self.m_car:setPosition(self.car_points[1].x, self.car_points[1].y)
		-- self.m_car:setTag(4)
		-- RollPanel:addChild(self.m_car)
		-- self.m_car:setRotation(self.car_rota[self.index])	
		-- if isEnter == false then
		-- 	self.m_car:setVisible(false)
		-- else 
		-- 	self.m_car:setVisible(true)
		-- end


		self.secondRoll = cc.Sprite:create("GameRes/GameCar/benchi/btnEffect.png")
		self.secondRoll:setScale(0.62)
	 	self.secondRoll:setPosition(self.points[32].x, self.points[32].y)
	 	self.secondRoll:setTag(2)
	 	RollPanel:addChild(self.secondRoll)
		self.thirdRoll = cc.Sprite:create("GameRes/GameCar/benchi/btnEffect.png")
		self.thirdRoll:setScale(0.62)
	 	self.thirdRoll:setPosition(self.points[31].x, self.points[31].y)
	 	self.thirdRoll:setTag(3)
	 	RollPanel:addChild(self.thirdRoll)
 	end
	
	 --RollPanel:getChildByName(string.format("car_index_1")):getChildByName("bg"):loadTexture("GameRes/GameCar/benchi/bc_21.png")
 	local delay = cc.DelayTime:create(self.time)
 	local call = cc.CallFunc:create(function()
 		if self.firstRoll == nil then
 			return
 		end
		 self.firstRoll:setPosition(cc.p(self.points[self.index].x,self.points[self.index].y))

		 	
		if self.m_car ~= nil then
	   		self.m_car:setPosition(self.car_points[self.index].x, self.car_points[self.index].y)
	  	 	self.m_car:setRotation(self.car_rota[self.index])
  		end

 		local index = self.oneCircle-math.mod(self.oneCircle-self.index + 1,self.oneCircle)
 		if nil ~= self.secondRoll then
 			self.secondRoll:setPosition(cc.p(self.points[index].x,self.points[index].y))
 		end
 		if nil ~= self.thirdRoll then
 			index = self.oneCircle-math.mod(self.oneCircle-index+1,self.oneCircle)
 			self.thirdRoll:setPosition(cc.p(self.points[index].x,self.points[index].y))
 		end
 		local car = RollPanel:getChildByName(string.format("car_index_%d",self.index))
 		car:removeChildByTag(1)
 		car:stopAllActions()
 		car:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,1.2),cc.ScaleTo:create(0.1,1.0)))
 		self.index = math.mod(self.index,self.oneCircle) + 1
 		self.count = self.count + 1
 		
 		if self.count == self.oneCircle * 2 then 	
 			self.secondRoll:removeFromParent()
 			self.thirdRoll:removeFromParent()
 			self.secondRoll = nil
 			self.thirdRoll  = nil
 		elseif self.count > self.oneCircle * 2 and self.count < self.oneCircle*3 then
 			self.time = self:getTimeQueue(self.count-self.oneCircle * 2)
 		elseif self.count >= self.oneCircle*3 then
 			self.time = 0.8
 			if self.index  == self.endindex + 1 then
				 self:EndBreath(car)

 				local info  = self._scene._info
			    self:ShowBankerInfo(info)
				self:SetEndView(true)
				--隐藏时间类型
		 		self:setClockTypeIsVisible(false)
		 		if self._scene.m_bAllowJoin then
		 			--插入记录
			    	self:addRcord(self.endindex)
			    	m_bAllowJoin = false
		 		end
		 		--移除倒计时
				if nil ~= self.m_pClock then
					self._scene:KillGameClock()
					self.m_pClock:removeFromParent()
					self.m_pClock = nil
				end
 				return
 			end
 		end
 		self:RunCircleAction(isEnter)
 	end)
 	self:runAction(cc.Sequence:create(delay,call))
end
--目标位置
function GameViewLayer:EndBreath(car)
	local callfunc = cc.CallFunc:create(function()
		self:EndBreath(car)
	end)
	car:runAction(cc.Sequence:create(cc.ScaleTo:create(0.4,1.2),cc.ScaleTo:create(0.4,1.0),callfunc))
	
	if car:getChildByTag(7) == nil then
		local end_effect = cc.Sprite:create("game_res/endEffect.png")
		end_effect:setPosition(cc.p(car:getContentSize().width/2,car:getContentSize().height/2))
		end_effect:setTag(7)
		car:addChild(end_effect,-1)
		end_effect:runAction(cc.Sequence:create(cc.RotateBy:create(2,720),cc.CallFunc:create(function (  )
			end_effect:setVisible(false)
		end),cc.DelayTime:create(9.0),cc.CallFunc:create(function (  )
			end_effect:removeFromParent()
		end),nil))	
	end

end
--停止动作
function GameViewLayer:removeAction()
	local RollPanel = self._rootNode:getChildByName("Panel_roll")
	for i=1,32 do
		local car = RollPanel:getChildByName(string.format("car_index_%d",i))
		if nil ~= car then
			car:stopAllActions()
			--car:removeChildByTag(7)
		end
	end
	self:stopAllActions()
	
	if nil ~= self.firstRoll then
		self.firstRoll:removeFromParent()
		self.firstRoll = nil
	end
	if nil~= self.m_car then
		self.m_car:removeFromParent()
		self.m_car = nil
	end
	if nil ~= self.secondRoll then
		self.secondRoll:removeFromParent()
		self.secondRoll = nil
	end
	if nil ~= self.thirdRoll then
		self.thirdRoll:removeFromParent()
		self.thirdRoll = nil
	end
end
-----------------------------------------------------------------------------------------------------------------
--用户聊天
function GameViewLayer:userChat(nick, chatstr)
	if not self._ChatView or not  self._ChatView.onUserChat then
		return
	end
    self._ChatView:onUserChat(nick,chatstr)
end
--用户表情
function GameViewLayer:userExpression(nick, index)
    if not self._ChatView or not self._ChatView.onUserExpression  then
		return
	end
    self._ChatView:onUserExpression(nick,index)
end
----------------------------------------------------------------------------------------------------------------------
function GameViewLayer:onTouchBegan(touch, event)
	print("luxurycar onTouchBegan...")
	return true
end
function GameViewLayer:onTouchMoved(touch, event)
	print("luxurycar onTouchMoved...")
end
function GameViewLayer:onTouchEnded(touch, event )
	print("luxurycar onTouchEnded...")
end
-----------------------------------------------------------------------------------------------------------------------
function GameViewLayer:playEffect( file )
	if not GlobalUserItem.bVoiceAble then
		return
	end
	AudioEngine.playEffect(file)
end
function GameViewLayer:playBackGroundMusic(cbStatus)
	if not GlobalUserItem.bVoiceAble then
		return
	end
	if cbStatus == g_var(cmd).GS_PLACE_JETTON then --下注
		--AudioEngine.stopMusic()
		self:playEffect("sound_res/PLEASE_ADD_GOLD.wav")
	elseif cbStatus == g_var(cmd).GS_GAME_END  then
		--AudioEngine.stopMusic()
		if not AudioEngine.isMusicPlaying() then
			AudioEngine.playMusic("sound_res/BACK_GROUND_DRAW.wav",true)
		end
	elseif cbStatus == g_var(cmd).GS_GAME_FREE or cbStatus == g_var(cmd).GAME_SCENE_FREE then
		--AudioEngine.stopMusic()
		--if not AudioEngine.isMusicPlaying() then
			--AudioEngine.playMusic("sound_res/BACK_GROUND_FREE.wav",true)	
		--end
		if not AudioEngine.isMusicPlaying() then
			AudioEngine.playMusic("sound_res/BACK_GROUND_DRAW.wav",true)
		end
	end
end

function GameViewLayer:playEffectByz( value )
	if not GlobalUserItem.bVoiceAble then
		return
	end
	
	if value == TAG_EFFECT.TAG_START then
		self:playEffect("sound_res/bcbm_start.wav")
	elseif value == TAG_EFFECT.TAG_DOWN then
		self:playEffect("sound_res/bcbm_stop.wav")
	elseif value == TAG_EFFECT.TAG_LOOP then
		self:playEffect("sound_res/bcbm_loop.wav")
	elseif value == TAG_EFFECT.TAG_JETTON then
		self:playEffect("sound_res/coins_fly_in.wav")
	elseif value == TAG_EFFECT.TAG_WARING then
		self:playEffect("sound_res/bcbm_waring.wav")
	end
end

return GameViewLayer