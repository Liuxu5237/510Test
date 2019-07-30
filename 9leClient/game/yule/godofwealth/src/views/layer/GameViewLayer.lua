--创建GameViewLayer
local GameViewLayer = class("GameViewLayer",function(scene)
		local gameViewLayer =  display.newLayer()
    return gameViewLayer
end)
--导入游戏逻辑文件
local module_pre = "game.yule.godofwealth.src"
--local system = appdf.req(module_pre .. ".views.layer.system")
local setLayer = appdf.req(module_pre .. ".views.layer.setLayer")

local ExternalFun =  appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

local HeadSprite = appdf.req(appdf.EXTERNAL_SRC .. "HeadSprite")

local HelpLayer = appdf.req(module_pre..".views.layer.HelpLayer")
local g_var = ExternalFun.req_var
local cmd = module_pre .. ".models.CMD_Game"
local GameNotice = appdf.req(appdf.BASE_SRC .."app.views.layer.other.GameNotice")



GameViewLayer.RES_PATH = "game/yule/godofwealth/res/"

--变量
local InitwinAndCount = 0 
local winAndCount = 0
local FreeGamewinAndCount = 0
local CountFreeGame = 0
--local Top_Sp = nil  				--普通顶部特效
--local Top_Scarrt = nil 			--Scarrt顶部特效
local FreeGameNumber = nil 			--FreeGame次数
local FreeGameCount = nil 			--FreeGame总次数
local FreeGameGoldBat = {}

local autoSchedulerEntry = nil 		--自动旋转定时器标示 
local AutoNumSchedulerEntry = nil 	--自动旋转定时器标示
local b_sendMsgCallback = true 		--发送网络消息是否回调
local BonusSchedulerEntry =nil 		----彩金定时器
local MAXZORDER = 999999
local typeRotationSpeed = 1
local NumautoRollIndex = 0
local VoiceGold1 = nil

function GameViewLayer:ctor(scene)
	--注册node事件
	ExternalFun.registerNodeEvent(self)

	self._scene = scene
	self:initdata()
	self:preloadUI()
	self:initUi()
end

function GameViewLayer:initdata()

	self.WinGoldCount = 0 --右下角显示Win金币
	self.Mainbg_1 = nil --背景图片
	self.ROLLING = false --是否在转
	self.ready = false --是否可以游戏，服务端返回才能开始游戏
	self.serverWin = 0 --服务端返回的 win 金额
	self.autoFlag = false --是不是自动旋转 用于显示不同stop按钮
	self.isWin = false --判断是否赢了
	self.lines = 9 --选择几条线
	self.betIndex = 1 --花费index
	self.bet = {100, 500, 1000, 2000, 5000, 10000, 100000, 200000} --花费,必须>=1
	self.serverIcos = {1, 1, 1, 4, 5, 2, 2, 2, 4, 5, 3, 3, 3, 4, 5}
	self.rollCount = 0  --滚动完成几条线 
	self.longPress = false  --判断是否长按
	self.autoCount = 0
	self.RUNING = false --正在滚动
	self.tab = {{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}}--结果集
	--中奖信息
	self.winNumb = nil --线金额
	self.winLines = nil --线
	self.winOdds  = nil--赔率
	self.winLinePoints = nil --线具体的点
	self.errorState = 0
	self.pan_numb = nil -- 中奖线金额
	--文本
	self.text_Score = nil --线金额
	self.text_autostop = nil
	--self.text_lines=nil
	self.text_bet = nil
	self.text_totalbet = nil
	self.text_win = nil --赢了总额text
	self.sp_win = nil --赢了总额的背景
	--容器
	self.pan_auto = nil
	--按钮定义
	self.btn_autostop = nil --auto_stop按钮
	self.btn_stop = nil --stop按钮
	self.btn_spin = nil --spin按钮
	-- self.btn_lines_sub= nil
	-- self.btn_lines_add= nil
	self.btn_bet_sub = nil
	self.btn_bet_add = nil 
	self.btn_max = nil  --最大花费
	self.sp_tipwin = nil
	self.text_tipwin = nil
	--table
	self.table_pans = {} --滚动窗口1
	self.table_lines = {} --所有中奖线
	self.table_leftBtns = {} --所有左边按钮
	self.table_rightBtns = {} --所有左边按钮
	self.table_winStars = {} --赢了后添加的框框

	self.LightLineNum = {}
	self.RightLineNum = {}

	self.FreeFaCai = false
	 
	self.rollBgMp3Id = nil --滚动声音ID 用于停止

	self.nScatter = 0

	self.FreeRotation = 0	    --免费旋转开关

	self.FreeRotationCount = 0    --免费旋转次数
	self.FreeRotationNum = 0    --已经免费旋转次数

	self.Redrich = {}   --红发财
	self.RedrichCount = 0  
	self.copyCard = {} --拷贝可更改的图标
	self.copyCard1 = {} --拷贝可更改的图标
	self.FreeGameFaCai = {}
	self.Animationgofree = {} --动画数组

	self.gofreeAnima = {} --红发财金币动画

	self.HongFaCaiArmature = {}

	self.LoseFreeGame = false
	self.LoseFaCai = false

	self.FreeBalance = false

	self.star = true

	self.NumBG = nil
	self.NumLabel = nil
	self.NumIdex = 0

	self.FreeGameOverBG = nil
	self.FreeGameLabel = nil

	self.AniFiveLine = nil  --中5个动画
	self.FaiCaiAndveryGood = false

	self.Handsel = 0

	self.IsStarFreeGame = 1
	self.Linepoint = 0

	self.autoNumCount = false
	self.Counter = 0
	self.FlotTime = 0
	self.CounterCount = 0
	---断线重链
	self.tipLayer = nil
	self.SurplusRotation = 0
	self.SurplusRotationCount = 0
	self.LienBet = 0
	self.WinGold = 0
	self.icon = {}

	self.ButtonAutoRoll = 0
	-------------------------------- --BigWin赋值
	self.spBigWin = nil
	self.GameBigWin = false
	self.BigWinOK = false

	self.TimeText = nil

	----------------------------- 彩金赋值
	self.BonusRandomText = 0 --彩金转动触发
	self.Random_JackotText = 0
	self.MajorText = 0
	self.MinorText = 0
	self.Random_Jackot = 0
	self.Major = 0
	self.Minor = 0

	----------------------------- 彩金动画赋值
	self.GameJackotTag = false
	self.JackpotPanel = nil
	self.JackpotMajor = nil
	self.JackpotMinor = nil
	self.JackpotRandom = nil
	self.JackpotXing = nil
	self.JackpotJinbi = nil
	self.JackpotText = nil
	self.JackpotTextNum = 0
	------------------------------

	----------------------------------Bigwin音效-------------------------------------
	self.GameRollFunNum = 0 --没有网络旋转

	self.gameBroadCast = nil

	self.Music_Scatter = 0
	self.IsWhole = 0

	--self.JackpotBigWin = nil

	self.btBetLines_3 = nil
	------------------------------ 音效
	self.MusicOpen = nil
	self.MusicClose = nil
	self.MusicTemp = true 
	------------------------------ 摇一摇
	self.ShakingOpen = nil
	self.ShakingClose = nil
	self.ShakingTemp = false
	----------------------------- 断网
	self.NotLineKuang = nil
	self.NotLineBtn = nil
	self.pColorLayer = nil
	--------------------------------------------------------------------------
	self.Panel_Calick = {}
	self.Panel_Gray = {}
	self.Panel_CalickCode = 0
	self.GameRollCode = 0
	self.RollBool = false
	self.isMusic = true

	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    --用户信息改变事件
	eventDispatcher:addEventListenerWithSceneGraphPriority(
        cc.EventListenerCustom:create("ry_GetGameNotice", handler(self, self.NoticeCallBack)),
        self
        )
end

function GameViewLayer:NoticeCallBack( event )
	
	local msg  =  event._usedata["NoticeMsg"]
	
	if self._laba ~=nil then
		self._laba:addTrugTxt(msg)
	end

end

function GameViewLayer:preloadUI()
	--添加路径
	--cc.FileUtils:getInstance():addSearchPath("game/yule/godofwealth/res/",true)

	--搜索路径
    local gameList = self._scene:getParentNode():getApp()._gameList;
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

    
	--添加缓存
	cc.Director:getInstance():getTextureCache():addImage("roll.png")
	cc.Director:getInstance():getTextureCache():addImage("roll1.png")
	cc.Director:getInstance():getTextureCache():addImage("roll2.png")

	--动画缓存
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("Jackpot/5ofkind.ExportJson")
	--初始动画
	self:initAnima()
	--音乐缓存
	AudioEngine.preloadEffect("mp3/Button.mp3")
	AudioEngine.preloadEffect("mp3/Reuslt.mp3")
	AudioEngine.preloadEffect("mp3/Rolling.mp3")
	AudioEngine.preloadEffect("mp3/Spin.mp3")
	AudioEngine.preloadEffect("mp3/Stop.mp3")
	AudioEngine.preloadEffect("mp3/TwoFa.mp3")
	AudioEngine.preloadEffect("mp3/FreeGameA.mp3")
	AudioEngine.preloadEffect("mp3/FreeGame_OK.mp3")
	AudioEngine.preloadEffect("mp3/FreeGame_OK_1.mp3")
	AudioEngine.preloadEffect("mp3/FreeGame_OK_2.mp3")
	for i=1,9 do
		AudioEngine.preloadEffect("mp3/Line_"..i..".mp3")
	end
	for j=1,5 do
		AudioEngine.preloadEffect("mp3/scatter_"..j..".mp3")
	end
end

function GameViewLayer:initUi()
	--节点事件
	local function onNodeEvent(event)
		if event == "exit" then
			self:onExit()
		end
	end
	self:registerScriptHandler(onNodeEvent)

	self._csbNode = cc.CSLoader:createNode("MainScene.csb")
					:addTo(self, 1)
	self:initButton()
	--音效开关
	--self:setMusicOn_Off()
	--if GlobalUserItem.bVoiceAble then
		if self.FreeRotationCount == 0 then
			AudioEngine.playMusic("mp3/BG.mp3",true)
		else
			AudioEngine.playMusic("mp3/FreeGameBG.mp3",true)
		end		
	--end
	--self._setLayer = setLayer:create(self):addTo(self, 3)
	--self._setLayer:initLayer()
	self.gofreeAnima = {0, 0, 0, 0, 0}

	--获取控件引用
	for i = 1, 5 do
		self.HongFaCaiArmature[i] = self._csbNode:getChildByName("HongFaCaiArmature_"..i)
		self.HongFaCaiArmature[i]:setVisible(false)
	end
	self.pan_numb = self._csbNode:getChildByName("pan_numb") 
	self.pan_numb:setLocalZOrder(9999)

	self.text_Score = self._csbNode:getChildByName("text_Score")

	self.BalanceText = GlobalUserItem.lUserScore--GlobalUserItem.lUserScore
	self:FormatScore(self.text_Score,self.BalanceText)
	--self.text_Score:setString(self.BalanceText)

	--获取中奖线
	for i = 1 , 9 do 
		table.insert(self.table_lines,self._csbNode:getChildByName("line"..i) )
	end

	for i = 1, 15 do
		table.insert(self.table_winStars,self._csbNode:getChildByName("WinFream_"..i) )
	 end 
	for i = 1 ,9 do
		self.LightLineNum[i] = self._csbNode:getChildByName("lineNum"..i)
		self.RightLineNum[i] = self._csbNode:getChildByName("lineNum1_"..i)
	end  
	--获取text 
	self.Mainbg_1 = self._csbNode:getChildByName("mainbg_1") 
	FreeGameNumber = self._csbNode:getChildByName("FreeGameLabel") 
	FreeGameCount = self._csbNode:getChildByName("FreeGameLabel1") 
	FreeGameNumber:setString("")
	FreeGameCount:setString("")
	self.sp_win = self._csbNode:getChildByName("sp_win") 
	self.sp_tipwin = self._csbNode:getChildByName("sp_tipwin") 
	self.sp_tipwin:setLocalZOrder(999999)
	self.sp_tipwin:setVisible(false)

	self.text_tipwin = self.sp_tipwin:getChildByName("text_tipwin")

	self.text_win = self.sp_win:getChildByName("text_win") --赢了总额text
	self.text_win:setString("")
	self.text_bet =self._csbNode:getChildByName("text_bet")
	self.text_totalbet =self._csbNode:getChildByName("text_totalbet")
	self.text_autostop =self._csbNode:getChildByName("text_autostop")

	--头像信息
	self:onUpdateUserInfo()
	self:updateText() --更新文本
	--获取按钮
	self.btn_autostop = self._csbNode:getChildByName("btn_autostop")
	self.btn_stop = self._csbNode:getChildByName("btn_stop")
	self.btn_spin = self._csbNode:getChildByName("btn_spin")
	
	self.btn_bet_sub = self._csbNode:getChildByName("btn_bet_sub")
	
	self.btn_bet_add = self._csbNode:getChildByName("btn_bet_add")
	
	self.btn_max = self._csbNode:getChildByName("btn_max")
	self.btn_max:addTouchEventListener(handler(self,self.footBtnClick))
	self.btn_bet_sub:addTouchEventListener(handler(self,self.footBtnClick))
	self.btn_bet_add:addTouchEventListener(handler(self,self.footBtnClick))
	self.btn_stop:addTouchEventListener(handler(self,self.footBtnClick)) 
	self.btn_autostop:addTouchEventListener(handler(self,self.footBtnClick)) 

	if self.betIndex == 1 then
		self.btn_bet_sub:setEnabled(false)
		self.btn_bet_sub:setBright(false)
	end

	self.NumBG=self._csbNode:getChildByName("NumBG")
	self.NumLabel=self.NumBG:getChildByName("NumLabel")

	self.FreeGameOverBG=self._csbNode:getChildByName("FreeGameOverBG")
	self.FreeGameLabel=self.FreeGameOverBG:getChildByName("FreeGameOverLabel")
	self.FreeGameOverBG:setLocalZOrder(100)
	self.FreeGameOverBG:setVisible(false)
	--获取滚动窗口 
	for i = 1 , 15 do 
		table.insert(self.table_pans,self._csbNode:getChildByName("pan_"..i) )
	end 
	 
	self.btn_spin:addTouchEventListener(handler(self,self.spinClick))
	--初始化卡牌
	self:IsCreateInitCard()
	--self:SystemTime()
	--self:BroadCastInit()
	self:GameBetIndex()
	--断网提示
	--self:createNotLineBack()
	--摇一摇
	--self:onAccelerometer()
	--self:setShakingOn_Off()
	-------------
    self:initPansEventListener()
    local btn_admin = self._csbNode:getChildByName("btn_admin")
    btn_admin:addClickEventListener(function()
    	print("132132131")
    		local cmddata = CCmd_Data:create(0)
			self._scene:SendData(15,cmddata)
    	end)
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if cc.PLATFORM_OS_WINDOWS == targetPlatform then
    	local listener = cc.EventListenerKeyboard:create()
        listener:registerScriptHandler(function(keyCode, event)
				if keyCode == cc.KeyCode.KEY_SPACE then
					if self.btn_spin:isVisible() and self.btn_spin:isEnabled() then
						self:spinClick(self.btn_spin,ccui.TouchEventType.began)
						self:spinClick(self.btn_spin,ccui.TouchEventType.ended)
					elseif self.btn_stop:isVisible() and self.btn_stop:isEnabled() then
						self:footBtnClick(self.btn_stop,ccui.TouchEventType.ended)
					end 
				end
        	end, cc.Handler.EVENT_KEYBOARD_RELEASED)

        cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
    end
	
	self._laba =  GameNotice:create("",cc.p(667,630))
	self._laba:addTo(self._csbNode)

end


------------------------音效关闭或停止------------------------
function GameViewLayer:setMusicOn_Off()
    function musicOpenCallback(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			print("【音效开启】")
			self:onTouchMusic(false, true)

			self.MusicTemp = true
			if self.MusicTemp then
				if self.FreeRotationCount == 0 then
					AudioEngine.playMusic("mp3/BG.mp3",true)
				else
					AudioEngine.playMusic("mp3/FreeGameBG.mp3",true)
				end		
			end
		end
	end
	self.MusicOpen = ccui.Button:create("Hall/PublicFile/soundno1.png", "Hall/PublicFile/soundno2.png", "Hall/PublicFile/soundno3.png")
	self.MusicOpen:setPosition(1190, 685)
	self.MusicOpen:addTouchEventListener(musicOpenCallback)
	self:addChild(self.MusicOpen,200)


	function musicCloseCallback(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			print("【音效关闭】")
			self:onTouchMusic(true, false)
			self.MusicTemp = false

			AudioEngine.stopAllEffects()
			AudioEngine.stopMusic()
		end
	end
	self.MusicClose = ccui.Button:create("Hall/PublicFile/soundoff1.png", "Hall/PublicFile/soundoff2.png", "Hall/PublicFile/soundoff3.png")
	self.MusicClose:setPosition(1190, 685)
	self.MusicClose:addTouchEventListener(musicCloseCallback)
	self:addChild(self.MusicClose,200)

  	self:onTouchMusic(false, true)
end
function GameViewLayer:onTouchMusic(openEnbled, closeEnbled)
	self.MusicOpen:setVisible(openEnbled)
	self.MusicOpen:setEnabled(openEnbled)
	self.MusicOpen:setBright(openEnbled)

    self.MusicClose:setVisible(closeEnbled)
	self.MusicClose:setEnabled(closeEnbled)
	self.MusicClose:setBright(closeEnbled)
end
function GameViewLayer:playBtnEffect() 
	if self.MusicTemp then
		AudioEngine.playEffect("mp3/Button.mp3")
	end
end
--Bigwin动画音效停止
function GameViewLayer:cleanBigwin()
	if self.GameBigWin then
		self:stopAllActions()
		AudioEngine.stopAllEffects()
		--AudioEngine.stopMusic()
		self.BigWinOK = false
		self.GameBigWin = false
		self.spBigWin:removeFromParent(true) 
		if(self.schedulerIDWin3) then 
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerIDWin3)
			self.schedulerIDWin3 = nil 
		end
	end
end
----底部按钮
function GameViewLayer:footBtnClick(sender, eventType) 
	if eventType == ccui.TouchEventType.ended then
		self:playBtnEffect()
		if sender:getName() == "btn_bet_sub" then
			print("btn_bet_1111add点击")
			if self.betIndex > 1 then
				self.betIndex =self.betIndex - 1
				if self.betIndex ==1 then
					self.btn_bet_sub:setEnabled(false)
					self.btn_bet_sub:setBright(false)
				end
			end
			if self.BigWinOK== true then
				self:cleanBigwin()
				release_print("----执行停止cleanBigwin")
			end
			self:updateText() --更新文本
		elseif sender:getName() == "btn_bet_add" then
			release_print("btn_bet_add点击")
			if self.betIndex < table.getn(self.bet) then
				self.betIndex = self.betIndex + 1
				self.btn_bet_sub:setEnabled(true)
				self.btn_bet_sub:setBright(true)
			else  
				self.betIndex = 0
				self.betIndex = self.betIndex + 1
				self.btn_bet_sub:setEnabled(false)
				self.btn_bet_sub:setBright(false)
			end
			if self.BigWinOK== true then
				self:cleanBigwin()
				release_print("----执行停止cleanBigwin")
			end
			self:updateText() --更新文本
		elseif sender:getName() == "btn_stop" then
			if self.BigWinOK== true then
				self:cleanBigwin()
				print("----执行停止cleanBigwin")
			end
			if self.MusicTemp then
				AudioEngine.playEffect("mp3/Stop.mp3")
			end
			if self.FreeRotation==0 then
				print("收费旋转下点击-->btn_stop")
				self.btn_spin:setEnabled(false)
				self.btn_stop:setEnabled(false)
			 	self.btn_stop:setBright(false)
				 	
				if self.Redrich[1] ==1 and (self.Redrich[2]==1 or self.Redrich[3]==1 or self.Redrich[4]==1 or self.Redrich[5]==1) then
					local b = math.random(1,2)
					self:randomSprite(1,6,11,b)
				end

				if self.Redrich[2] ==1 and (self.Redrich[1]==1 or self.Redrich[3]==1 or self.Redrich[4]==1 or self.Redrich[5]==1) then
					local b = math.random(1,2)
					self:randomSprite(2,7,12,b)
		
				end

				if self.Redrich[3] ==1 and (self.Redrich[2]==1 or self.Redrich[1]==1 or self.Redrich[4]==1 or self.Redrich[5]==1) then
					local b = math.random(1,2)
					self:randomSprite(3,8,13,b)
			
				end

				if self.Redrich[4] ==1 and (self.Redrich[2]==1 or self.Redrich[3]==1 or self.Redrich[1]==1 or self.Redrich[5]==1) then
					local b = math.random(1,2)
					self:randomSprite(4,9,14,b)
			
				end

				if self.Redrich[5] ==1 and (self.Redrich[1]==1 or self.Redrich[2]==1 or self.Redrich[3]==1 or self.Redrich[4]==1) then
					local b = math.random(1,2)
					self:randomSprite(5,10,15,b)

				end
				if self.ROLLING then
					self.ROLLING = false
					if self.GameRollCode == 0 then
						self:stopRall()
					else
						self:stopRallcode()
					end
					self:doWIN()

				end
			elseif self.FreeRotation==1 then
				print("免费旋转下点击-->btn_stop")
				if self.FreeFaCai==true then
				else
					for i=1,15 do
			    		self.FreeGameFaCai[i]:setOpacity(0)
			    		self.FreeGameFaCai[i]:setVisible(false)
			   		end

					if self.ROLLING then
						self.ROLLING = false
			   			self:stopRall()
						self:setCard()
						self:doWIN() 
					end
				end
			end
		elseif sender:getName() == "btn_autostop" then --自动旋转按钮
	 		if self.BigWinOK== true then
				self:cleanBigwin()
			end
			if b_sendMsgCallback then
				self.RUNING = false 
				self.autoCount =0      ---清除自动滚动数据 关闭定时器
				self.star=true
				for i=1,11 do
					self.Animationgofree[i]:setLoops(3)
				end
				if self.ROLLING then
					self.ROLLING = false
					self.ButtonAutoRoll=1
					AudioEngine.stopAllEffects()
		   			self:stopRall()
					self:doWIN()
				else
					 	self:runAction(cc.Sequence:create(
					 	cc.DelayTime:create(1.5),cc.CallFunc:create(function(sender)
					 	self:setBtnVisible(true,false,true,false,true,true)
					 	self:setBtnEnble(true,false,true,false,true,true)
					 	self:setBtnBright(true,false,true,false,true,true)
					 	if self.betIndex <=1 then
						 	self.btn_bet_sub:setEnabled(false)
							self.btn_bet_sub:setBright(false)
						 else
						 	self.btn_bet_sub:setEnabled(true)
							self.btn_bet_sub:setBright(true)
						 end
					 	end)))
				end
				self.btn_stop:setVisible(false)--隐藏stop
				self.btn_autostop:setVisible(false)--隐藏autostop
				self.btn_max:setVisible(true)
			end
		elseif  sender:getName() == "btn_max" then
			--设定最大值，并启动游戏
			if self.BigWinOK== true then
				self:cleanBigwin()
				release_print("----执行停止cleanBigwin")
			end
			if self.FreeRotation==1 then

				self.autoCount=self.FreeRotationCount - self.FreeRotationNum
				self:autoRoll()
				autoSchedulerEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()self:autoRoll()end, 0.5, false)
			elseif self.FreeRotation==0 then
				
				self.lines =9
				self.autoCount=99999999999999
				   self.btn_max:setVisible(false)
				   self.btn_autostop:setVisible(true)
				if self.ROLLING then
					release_print("self.ROLLING -------->>>   true")
				else
					release_print("self.ROLLING -------->>>   false")
				end
				AudioEngine.stopAllEffects()
		   		self:stopRall()
				self.RUNING = false
				self:autoRoll() --立马执行，其他的使用定时器启动
				autoSchedulerEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
					self:autoRoll() end, 0.5, false)
				release_print("-btn_autospin--开启滚动---")
			end
		end 
		
	end  
end
function GameViewLayer:autoRoll(dt)  
	if self.autoCount <= 0 then --取消自动旋转定时器

		if(autoSchedulerEntry) then 
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(autoSchedulerEntry)
			autoSchedulerEntry=nil 		
		end 
	end
	if not self.RUNING and self.autoCount > 0   then 
		self:startGameByNet(true)
		if self.star then
			self.star=false
			for i=1,11 do
				self.Animationgofree[i]:setLoops(1)
			end
		end
	end


end

function GameViewLayer:stopRall() 
	self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(function()
		if self.IsStarFreeGame~=2 then
			AudioEngine.stopAllEffects()
		end
	end)))
	--AudioEngine.stopAllEffects()
	--AudioEngine.stopMusic()	
	--self.ROLLING = false

	for indexKey,pan_1 in pairs(self.table_pans) do
		local size = #pan_1:getChildren()
		--local height =0  
		for index,sprite in pairs(pan_1:getChildren()) do
			sprite:stopAllActions() --关闭动画 
			if  index >size-1  then --获取最后3个元素,直接出现
				sprite:setPositionY(0)
			
			 
			else --移除以前的
				sprite:removeFromParent(true)
			end 
		end 
	end 
	
end
--清除赢了的动画和元素框
function GameViewLayer:cleanWin()
	if self.isWin then 
		self.isWin = false
		winAndCount = 0
		self.sp_win:stopAllActions()
		self.sp_win:setVisible(false)--隐藏赢了多少 
		--self._setLayer:setWinScore(self,0) --清空赢了多少
		self.sp_tipwin:stopAllActions()
		self.sp_tipwin:setVisible(false)
		--self.sp_tipwin:setOpacity(0) --隐藏赢了多少	
		self:stopAllActions()
		
		----self.JackpotBigWin:setVisible(false)

		--清除框框
		for indexKey,sprite_star in pairs(self.table_winStars) do 
			sprite_star:stopAllActions()
			sprite_star:setVisible(false)
		end
		--self.table_winStars={}
		--中奖线动画清除
		for indexKey,sprite_line in pairs(self.table_lines) do
			sprite_line:stopAllActions()
			sprite_line:setOpacity(255)
			sprite_line:setVisible(false)
		end
		-- --中奖金额动画清除
		-- for indexKey,lineNum in pairs(self.winLines) do  
		-- 	if (tonumber(lineNum) > 0) then   
		-- 			self.pan_numb:getChildByName("line"..lineNum):stopAllActions()
		-- 			self.pan_numb:getChildByName("line"..lineNum):setOpacity(255)
		-- 			self.pan_numb:getChildByName("line"..lineNum):setVisible(false)
		-- 	end
		-- end 
			
		if self.FreeRotation == 1 then
			self.sp_win:setVisible(true)
		else

			self.sp_win:setVisible(false)
		end
		self.RedrichCount = 0  
		for i = 1, 5 do
			self.Redrich[i] = 0
		end
	end 
end
--按钮显示
function GameViewLayer:setBtnVisible(IsShowSpin,IsShowStop,IsShowMax,IsShowAutostop,IsShowAdd,IsShowSub)
	self.btn_spin:setVisible(IsShowSpin)
	self.btn_stop:setVisible(IsShowStop)
	self.btn_max:setVisible(IsShowMax)
	self.btn_autostop:setVisible(IsShowAutostop)
	self.btn_bet_add:setVisible(IsShowAdd)
	self.btn_bet_sub:setVisible(IsShowSub)
end

--按钮点击
function GameViewLayer:setBtnEnble(IsShowSpin,IsShowStop,IsShowMax,IsShowAutostop,IsShowAdd,IsShowSub)
	self.btn_spin:setEnabled(IsShowSpin)
	self.btn_stop:setEnabled(IsShowStop)
	self.btn_max:setEnabled(IsShowMax)
	self.btn_autostop:setEnabled(IsShowAutostop)
	self.btn_bet_add:setEnabled(IsShowAdd)
	self.btn_bet_sub:setEnabled(IsShowSub)
end

--按钮状态
function GameViewLayer:setBtnBright(IsShowSpin,IsShowStop,IsShowMax,IsShowAutostop,IsShowAdd,IsShowSub)
	self.btn_spin:setBright(IsShowSpin)
	self.btn_stop:setBright(IsShowStop)
	self.btn_max:setBright(IsShowMax)
	self.btn_autostop:setBright(IsShowAutostop)
	self.btn_bet_add:setBright(IsShowAdd)
	self.btn_bet_sub:setBright(IsShowSub)
end
function GameViewLayer:GameBetIndex() --自动判断当前余额能否押注，押不了，自动降低Bet值 
	print("---------------进入GameBetIndex------------ ")
	print("---------我的筹码------- "..self.BalanceText)
	print("---------总押注------- "..self.bet[self.betIndex] * self.lines)
	--self._setLayer:updateScore()--更新用户积分
	if self.BalanceText < self.bet[1] * self.lines then
		print("-----------关闭按钮----------")
		self:setBtnEnble(false,false,false,false,false,false)
		self:setBtnBright(false,false,false,false,false,false)
		self.btn_spin:setVisible(true)
	else
		if self.BalanceText < self.bet[self.betIndex] * self.lines then
			if self.betIndex > 1 then
				self.betIndex = self.betIndex - 1
				self:updateText()
				print("----下降筹码阀值---当前总押注 "..self.bet[self.betIndex]*self.lines)
				self:GameBetIndex()
			else
				return
			end
		else
			return
		end
	end
end
--创建胶带 几个滚动方格
function GameViewLayer:createRoll(count)
	local sum =count/10 --完整块个数
	--134高度，145宽度
	local height = (count%10)*153 --剩下的宽度
	local roll =nil 
	local roll1Height = 1530 
	if height <= roll1Height then 
		local texture = cc.Director:getInstance():getTextureCache():getTextureForKey("roll.png")  
		roll = cc.Sprite:createWithTexture(texture,cc.rect(0,0,153,height)) --从上向下剪切
	else 
		local texture = cc.Director:getInstance():getTextureCache():getTextureForKey("roll.png")  
		roll = cc.Sprite:createWithTexture(texture,cc.rect(0,0,153,roll1Height)) --从上向下剪切 
	end  
	--添加完整块
	for i = 1 , sum do 
		local _r1 = cc.Sprite:create("roll.png")
		_r1:setAnchorPoint(0,0)
		_r1:setPositionY(height+(i-1)*roll1Height) --拼接到图片上部
		roll:addChild(_r1)
	end  
		 -- roll:setScaleX(1.25)
		 -- roll:setScaleY(0.94)
	return roll
end
function GameViewLayer:buildTab()
	for x = 1, 5 do
		for y = 1,3 do
			local _begin = 15 - y * 5 + x
			self.tab[x][y] = self.serverIcos[_begin] 
		end 
	end  
end

function GameViewLayer:VeryGood()

	self:setCardDark()
	

	for index,line in pairs(self.winLinePoints) do --显示点
			for index2,point in pairs(line) do
				if #line ==5 then
					local idx =self:getIndexByXY(point[1],point[2])
					local card   =cc.Sprite:create("card/"..self.serverIcos[idx]..".png")
					self.table_pans[idx]:getChildren()[1]:setTexture(card:getTexture())
				end
			end
	end


	local pColorLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 255*0.80), appdf.WIDTH, appdf.HEIGHT)
    self:addChild(pColorLayer, 100)
    pColorLayer:setVisible(true)

	self.AniFiveLine = ccs.Armature:create("5ofkind")
	self.AniFiveLine:setPosition(cc.p(appdf.WIDTH/2,appdf.HEIGHT/2))
	self.AniFiveLine:setLocalZOrder(100)
	self.AniFiveLine:getAnimation():playWithIndex(0)
	if self.MusicTemp then
		AudioEngine.playEffect("Jackpot/5ofAKind.mp3",false)
	end
	self:addChild(self.AniFiveLine)
	--self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
	if self.AniFiveLine~=nil then
		release_print("------进来")
		self:runAction(cc.Sequence:create(cc.DelayTime:create(3.15),cc.CallFunc:create(function()
			pColorLayer:setVisible(false)
			self.AniFiveLine:removeFromParent(true)
			self.AniFiveLine=nil
			if FaiCaiAndveryGood  then
				print("----FaiCaiAndveryGood true-----")
				self:showWinline()
				self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(function()
					--self.JackpotBigWin:setVisible(true)
				end),nil))
				self:runAction(cc.Sequence:create(cc.DelayTime:create(2.5),cc.CallFunc:create(function()
					--self.JackpotBigWin:setVisible(false)
				end),nil))
			else
				print("----FaiCaiAndveryGood false-----")
				self:showWin() 
				self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(function()
					--self.JackpotBigWin:setVisible(true)
				end),nil))		
				self:runAction(cc.Sequence:create(cc.DelayTime:create(2.5),cc.CallFunc:create(function()
					--self.JackpotBigWin:setVisible(false)
				end),nil))
			end
						 		
		end),nil))
	end
	--end),nil))
end

--游戏结束后判断
function GameViewLayer:doWIN()
	if not( self.rollBgMp3Id ==nil ) then --停止背景滚动声音
		AudioEngine.stopEffect(self.rollBgMp3Id)
	end
	--self._setLayer:updateScore()--更新用户积分
	--判断结果
	self:buildTab() --获取结果集

	self.winLines,self.winOdds,self.winLinePoints  = self._scene._gameLogic:win( self.tab,self.lines )--判断结果集

	self.winNumb = {} --线
	self.GameJackotTag = false
	local winCount = 0
	for index,num_odds in pairs(self.winOdds) do 
		--赢了多少 = 赔率* 单线花费  ==小王
		if self.winLines[index] == 0 then  --当线为0的时候表示，任意位置中奖，彩金为总花费*ODD
			winCount = winCount+ num_odds * self.bet[self.betIndex]*self.lines
			table.insert(self.winNumb,num_odds * self.bet[self.betIndex]*self.lines)
		else   
			winCount = winCount+ num_odds * self.bet[self.betIndex]  --线中奖后，彩金为线花费*ODD
			table.insert(self.winNumb,num_odds * self.bet[self.betIndex])
		end		 
	end

	for i,v in ipairs(self.Redrich) do
		print(i.." :----------------: "..v)
	end
	--赢了则显示中奖结果
	if self.serverWin > 0 then  	
		local GameBigWinindex = 0
		for i = 1, 15 do
			self.FreeGameFaCai[i]:setOpacity(0)
		    self.FreeGameFaCai[i]:setVisible(false)
		end
		for i = 1, 5 do
			if self.Redrich[i]==1 then
				self.RedrichCount=self.RedrichCount+1
				if self.RedrichCount>=2 then
					if self.MusicTemp then
						AudioEngine.playEffect("mp3/TwoFa.mp3")
					end
				end
			end
		end
		if self.serverWin / self.bet[self.betIndex] >= 1 and self.FreeRotation == 0  then
			if  self.serverWin / self.bet[self.betIndex] >= 1 and  self.serverWin / self.bet[self.betIndex] < 75  then
				GameBigWinindex = 1
			elseif self.serverWin / self.bet[self.betIndex] >= 75 and  self.serverWin / self.bet[self.betIndex] < 150  then
				GameBigWinindex = 2
			elseif self.serverWin / self.bet[self.betIndex] >= 150 then
				GameBigWinindex=3
			end
			self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(function()
				self.BigWinOK = true
				self:GameWarn(GameBigWinindex,self.serverWin)
				if GameBigWinindex == 1 then
					AudioEngine.playEffect("BigWinSpine/win1.mp3")
				elseif GameBigWinindex == 2 then 
					AudioEngine.playEffect("BigWinSpine/win2.mp3")
				else
					AudioEngine.playEffect("BigWinSpine/win3.mp3")
				end
				--self:GameBigWinMp3()
				end),nil))
		end
		print("----------------"..self.serverWin)
		print("--DoWin > 0--self.RedrichCount---:"..self.RedrichCount)
		self.IsWhole = 0
		for l_i,line_point in pairs(self.winLinePoints) do
			if #line_point == 5 then
				self.IsWhole = self.IsWhole + 1
			end
			if self.Linepoint < #line_point then
				self.Linepoint= #line_point
			end

			if  l_i == table.getn(self.winLinePoints)	then 
			 	release_print("----取每条线最大的值---"..self.Linepoint)
				if self.Linepoint ==5 and self.RedrichCount < 2  then
					release_print("------中了5个--没2列发财--")
					self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
						release_print("---VeryGood-!!!!!!!")
						self:VeryGood()
					end),nil))
				elseif self.Linepoint ==5 and self.RedrichCount >= 2 and self.FreeRotation ==0   then
					release_print("------中了5个- 有2列发财---")
					FaiCaiAndveryGood=true
					self:showWinRedrich()
				elseif self.Linepoint ==5 and self.FreeRotation ==1 and self.RedrichCount >= 2 then
					release_print(self.FreeRotationNum.."---------自动旋转中VeryGood---------"..self.FreeRotationCount )
					FaiCaiAndveryGood=true
					self:VeryGood()
				else
					release_print("-------1111111111111111")
					self:showWin()
				end
			end
		end
			
		if not (self.serverWin == winCount) then 
			--print("#############################################################################和服务端运算不一致，请检测程序"..self.serverWin .."===".. winCount)
			for x,x_point in pairs(self.tab) do
				for y,y_point in pairs(x_point) do 
					--print("---运算不一致---  "..self.tab[x][y])
				end	
			end
			--self.errorState=1
			--error("和服务端运算不一致，请检测程序") 
		end

		self.sp_win:setVisible(true) 

	else
		
		for i = 1,15 do
			self.FreeGameFaCai[i]:setOpacity(0)
		    self.FreeGameFaCai[i]:setVisible(false)
		end

		for i = 1, 5 do
			if self.Redrich[i]==1 then
				self.RedrichCount=self.RedrichCount+1
			end
		end
		release_print("--DoWin < 0--self.RedrichCount---:"..self.RedrichCount)

		if self.RedrichCount >= 2 and self.FreeRotation == 0 then
			release_print("没中奖下 有中2列或以上红发财")
			self.LoseFaCai=true
			self:showWinRedrich()
			self:runAction(cc.Sequence:create(
				cc.DelayTime:create(2.3),cc.CallFunc:create(function(sender)
					self.RUNING=false
					self:GameBetIndex()
				end)))
		else
			if self.FreeRotation==1 then
				if self.FreeBalance then
					release_print("-----------免费下中免费没中任何奖励")
					for i=1,15 do
						if self.serverIcos[i] == 8 then
							self.NumIdex=self.NumIdex+1

						end
					end
					if self.NumIdex >=5 then
						self.NumLabel:setString("50")
						self.NumIdex=0
						--release_print("!!!!!!!!!!!!!!55555555555555!!!!!!!!!!!!!!!!!!!!!!")
						--AudioEngine.stopMusic()
						--AudioEngine.playEffect("mp3/FreeGame_OK.mp3",false)
						--self:runAction(cc.Sequence:create(
						--cc.DelayTime:create(3.0),cc.CallFunc:create(function(sender)
						--release_print("!!!!!!!!!!!!!!!!!!55555555!!!!!!!!!!!!!!!!!!")
						self:InitBG()
						--end)))
						
					elseif self.NumIdex ==4 then
						self.NumLabel:setString("20")
						self.NumIdex=0
						--release_print("!!!!!!!!!!!!!!!!!!4444444!!!!!!!!!!!!!!!!!!")
						--AudioEngine.stopMusic()
						--AudioEngine.playEffect("mp3/FreeGame_OK.mp3",false)
						--self:runAction(cc.Sequence:create(
						-- cc.DelayTime:create(3.0),cc.CallFunc:create(function(sender)
						 	--release_print("!!!!!!!!!!!!!!!!!!44444444444444444444!!!!!!!!!!!!!!!!!!")
						self:InitBG()
						--end)))
					elseif self.NumIdex ==3 then
						self.NumLabel:setString("10")
						self.NumIdex=0
						release_print("!!!!!!!!!!!!!!!!!!3333333333!!!!!!!!!!!!!!!!!!")
						-- AudioEngine.stopMusic()
						-- AudioEngine.playEffect("mp3/FreeGame_OK.mp3",false)
						-- self:runAction(cc.Sequence:create(
						--  cc.DelayTime:create(3.0),cc.CallFunc:create(function(sender)
						--  	release_print("!!!!!!!!!!!!!!!!!!333333333333333!!!!!!!!!!!!!!!!!!")
							self:InitBG()
						--end)))
					elseif self.NumIdex<3 then
						self.NumIdex=0
					end
					
				else
					for i=1,9 do
						self.LightLineNum[i]:stopAllActions()
						self.RightLineNum[i]:stopAllActions()
						self.LightLineNum[i]:setOpacity(0)
						self.RightLineNum[i]:setOpacity(0)
						self.LightLineNum[i]:setVisible(false)
						self.RightLineNum[i]:setVisible(false)
					end
					for i=1,5 do
						self.HongFaCaiArmature[i]:stopAllActions()
						self.HongFaCaiArmature[i]:setVisible(false)
					end
					self:runAction(cc.Sequence:create(
						cc.DelayTime:create(1.0),cc.CallFunc:create(function(sender)
						self.RUNING=false
					end)))
				end
				--self.RUNING=false
				if self.FreeRotationNum == self.FreeRotationCount then
					self.FreeRotation = 0
					self.IsStarFreeGame = 1

					release_print("self.IsStarFreeGame..--退出免费旋转--"..self.IsStarFreeGame)
					self.FreeGameOverBG:setVisible(true)
					self.Counter=1
					self:InitFreeGameOver()
					self.autoNumCount=true
					self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function()
						self:NumautoRoll() --立马执行，其他的使用定时器启动
						if self.MusicTemp then
							VoiceGold1 =AudioEngine.playEffect("mp3/main/Score.mp3",true)
						end
						AutoNumSchedulerEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
							self:NumautoRoll()end,0.03,false)
					end),nil))
				end
			elseif self.FreeRotation == 0 then
				release_print("-!!!!!!!!!!!!!!!!!!!!!!!@@@@@@@@@@")
				if self.autoCount < 1 then
					release_print("-------手动旋转没中奖-------进入")
					if self.nScatter >=3 and self.Handsel==0 and self.JackpotTextNum <=0  then
						self.LoseFreeGame=true
						self:showWin() 
						release_print("!@@@@@############")
					elseif self.Handsel==0 and self.nScatter<3 and self.JackpotTextNum <=0  then
						self.RUNING=false
						self.IsStarFreeGame=1
						local dt = cc.DelayTime:create(0.5)
					    local seq = cc.Sequence:create(dt,cc.CallFunc:create(function()
						    release_print("!!!!!!!!!!!!!!!!!!!!!!@@@@@@@@@@@@@@@@@@@@@@@@@@@######")
						    self:setBtnVisible(true,false,true,false,true,true)
							self:setBtnEnble(true,false,true,false,true,true)
							self:setBtnBright(true,false,true,false,true,true)
							if self.betIndex <=1 then
								self.btn_bet_sub:setEnabled(false)
								self.btn_bet_sub:setBright(false)
							else
								self.btn_bet_sub:setEnabled(true)
								self.btn_bet_sub:setBright(true)
							end
							self:GameBetIndex()
						end),nil)
					    self:runAction(seq)
					    
					elseif self.JackpotTextNum > 0 then
						if self.JackpotTextID == 1 then
							release_print("---1122--Random_Jackot----")
							self:GameJackpot(1)
							self.RUNING=true
						-- self:setBtnVisible(true,false,true,false,true,true)
						-- self:setBtnEnble(false,false,false,false,false,false)
						-- self:setBtnBright(false,false,false,false,false,false)
						elseif self.JackpotTextID == 2 then
							release_print("----- Minor_Jackot ----")
							self:GameJackpot(2)
							self.RUNING=true
						elseif self.JackpotTextID == 3 then
							release_print("----- Major_Jackot ----")
							self:GameJackpot(3)
							self.RUNING=true
						end
					end
				elseif self.autoCount > 0 then
					release_print("-------自动旋转完毕没中奖----进入")
					if self.nScatter >=3 and self.Handsel==0 and self.JackpotTextNum <=0 then
						self.LoseFreeGame=true
						self:showWin() 
						self:GameBetIndex()
					elseif self.nScatter <3 and self.Handsel==0 and self.JackpotTextNum <=0  then
						 self:setBtnVisible(true,false,false,true,true,true)
						 self:setBtnEnble(false,false,false,true,false,false)
						 self:setBtnBright(false,false,false,true,false,false)
						self:runAction(cc.Sequence:create(
							cc.DelayTime:create(0.3),cc.CallFunc:create(function(sender)
								self.RUNING=false
								self.IsStarFreeGame=1
							end)))
					elseif self.JackpotTextNum > 0 then
						if self.JackpotTextID == 1 then
							release_print("--autoCount>0---Random_Jackot----")
							self:GameJackpot(1)
							self.RUNING=true
						elseif self.JackpotTextID == 2 then
							release_print("--autoCount>0--- Minor_Jackot ----")
							self:GameJackpot(2)
							self.RUNING=true
						elseif self.JackpotTextID == 3 then
							release_print("--autoCount>0--- Major_Jackot ----")
							self:GameJackpot(3)
							self.RUNING=true
						end
					end
				end
			end
		end
	end
	------------------------------------------------------
	self:GameRollEnd()
end

function GameViewLayer:showWinRedrich()
	if self.Redrich[1] == 1 then		
		self.HongFaCaiArmature[1]:setVisible(true)
		self.HongFaCaiArmature[1]:getAnimation():playWithIndex(0)
		self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function()
			local card1 = cc.Sprite:create("card/10.png")
			self.table_pans[1]:getChildren()[1]:setTexture(card1:getTexture())
			self.table_pans[6]:getChildren()[1]:setTexture(card1:getTexture())
			self.table_pans[11]:getChildren()[1]:setTexture(card1:getTexture())
		end),nil))

		self:runAction(cc.Sequence:create(cc.DelayTime:create(2.1),cc.CallFunc:create(function()
			self.HongFaCaiArmature[1]:setVisible(false)
		end),nil))
	end
	if self.Redrich[2] == 1 then
			
		self.HongFaCaiArmature[2]:setVisible(true)
		self.HongFaCaiArmature[2]:getAnimation():playWithIndex(0)
		self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function()
						
			local card1  = cc.Sprite:create("card/10.png")
			self.table_pans[2]:getChildren()[1]:setTexture(card1:getTexture())
			self.table_pans[7]:getChildren()[1]:setTexture(card1:getTexture())
			self.table_pans[12]:getChildren()[1]:setTexture(card1:getTexture())
		end),nil))
		self:runAction(cc.Sequence:create(cc.DelayTime:create(2.1),cc.CallFunc:create(function()
			self.HongFaCaiArmature[2]:setVisible(false)
		end),nil))		
	end
	if self.Redrich[3] == 1 then
		self.HongFaCaiArmature[3]:setVisible(true)
		self.HongFaCaiArmature[3]:getAnimation():playWithIndex(0)
		self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function()
							
			local card1  =cc.Sprite:create("card/10.png")
			self.table_pans[3]:getChildren()[1]:setTexture(card1:getTexture())
			self.table_pans[8]:getChildren()[1]:setTexture(card1:getTexture())
			self.table_pans[13]:getChildren()[1]:setTexture(card1:getTexture())
		end),nil))
		self:runAction(cc.Sequence:create(cc.DelayTime:create(2.1),cc.CallFunc:create(function()
			self.HongFaCaiArmature[3]:setVisible(false)
		end),nil))
	end
	if self.Redrich[4] == 1 then
		self.HongFaCaiArmature[4]:setVisible(true)
		self.HongFaCaiArmature[4]:getAnimation():playWithIndex(0)
		self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function()
							
			local card1 = cc.Sprite:create("card/10.png")
			self.table_pans[4]:getChildren()[1]:setTexture(card1:getTexture())
			self.table_pans[9]:getChildren()[1]:setTexture(card1:getTexture())
			self.table_pans[14]:getChildren()[1]:setTexture(card1:getTexture())
		end),nil))
		self:runAction(cc.Sequence:create(cc.DelayTime:create(2.1),cc.CallFunc:create(function()
			self.HongFaCaiArmature[4]:setVisible(false)
		end),nil))
		
	end
	if self.Redrich[5] == 1 then
		self.HongFaCaiArmature[5]:setVisible(true)
		self.HongFaCaiArmature[5]:getAnimation():playWithIndex(0)
		self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function()
						
			local card1  =cc.Sprite:create("card/10.png")
			self.table_pans[5]:getChildren()[1]:setTexture(card1:getTexture())
			self.table_pans[10]:getChildren()[1]:setTexture(card1:getTexture())
			self.table_pans[15]:getChildren()[1]:setTexture(card1:getTexture())
		end),nil))
		self:runAction(cc.Sequence:create(cc.DelayTime:create(2.1),cc.CallFunc:create(function()
			self.HongFaCaiArmature[5]:setVisible(false)
		end),nil))
	end
	self:runAction(cc.Sequence:create(cc.DelayTime:create(2.3),cc.CallFunc:create(function()
		if self.LoseFaCai == true then
			release_print("------没中奖下 2列红发财")
			if self.autoCount >= 1 then
				self:setBtnVisible(true,false,false,true,true,true)
				self:setBtnEnble(false,false,false,false,false,false)
				self:setBtnBright(false,false,false,false,false,false)
			else
				self:setBtnVisible(true,false,true,false,true,true)
				self:setBtnEnble(true,false,true,false,true,true)
				self:setBtnBright(true,false,true,false,true,true)	
			end
		else
			if FaiCaiAndveryGood ==false then
				self:showWinline()
			elseif FaiCaiAndveryGood ==true and self.nScatter <3 then
			 	self:VeryGood()
			end
		end
	end),nil))
end

function GameViewLayer:NumautoRoll(dt)  
	if self.autoNumCount == false then --取消自动旋转定时器
		if(AutoNumSchedulerEntry) then 
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(AutoNumSchedulerEntry)
			AutoNumSchedulerEntry=nil 
			--self.FreeGameLabel:setString(self.WinGoldCount)
		end 
	end


	if self.autoNumCount == true  then 
		local GameBigWinindex = 0
		if self.CounterCount >= self.WinGoldCount then
			self.CounterCount = self.WinGoldCount
			self.autoNumCount = false
			self.FreeGameLabel:setString(self.CounterCount)
			if VoiceGold1 then
				AudioEngine.stopEffect(VoiceGold1)
			end
		else
			
			NumautoRollIndex= self.WinGoldCount / 50
			self.CounterCount=self.CounterCount + NumautoRollIndex
			self.FreeGameLabel:setString(self.CounterCount)
			if self.CounterCount >= self.WinGoldCount then
				self.CounterCount=self.WinGoldCount
				if VoiceGold1 then
					AudioEngine.stopEffect(VoiceGold1)
				end
				self.FreeGameLabel:setString(self.CounterCount)
				if self.WinGoldCount / self.bet[self.betIndex]>=1 then
				 if self.WinGoldCount / self.bet[self.betIndex] >=1 and self.WinGoldCount / self.bet[self.betIndex] <75  then
				 	GameBigWinindex=1
				 elseif self.WinGoldCount / self.bet[self.betIndex] >=75 and self.WinGoldCount / self.bet[self.betIndex] <150  then
				 	GameBigWinindex=2
				 elseif self.WinGoldCount / self.bet[self.betIndex] >=150 then
				 	GameBigWinindex=3
				 end
				 self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(function()
				 	
					self.BigWinOK = true
					self:GameWarn(GameBigWinindex,self.WinGoldCount)
					if GameBigWinindex == 1 then
						AudioEngine.playEffect("BigWinSpine/win1.mp3")
					elseif GameBigWinindex == 2 then 
						AudioEngine.playEffect("BigWinSpine/win2.mp3")
					else
						AudioEngine.playEffect("BigWinSpine/win3.mp3")
					end
					--GameBigWinMp3()
				 	end),nil))
				end
				self:runAction(cc.Sequence:create(cc.DelayTime:create(2.5),cc.CallFunc:create(function()
						--self.BalanceText = GlobalUserItem.lUserScore
						--self.text_Score:setString(self.BalanceText)
						self.FreeGameOverBG:setVisible(false)
						self.FreeGameLabel:setString("")
						self.CounterCount = 0
						self.btn_spin:loadTextures("GameButton/Spin_1.png","GameButton/spin_2.png","GameButton/spin_3.png")
						local bg = cc.Sprite:create("Image/Normal.png")

						self.Mainbg_1:setTexture(bg:getTexture())
						--Top_Scarrt:stopAllActions()
						--Top_Scarrt:setVisible(false)
						AudioEngine.stopAllEffects()
						if self.MusicTemp then
							AudioEngine.playMusic("mp3/BG.mp3",true)
						end
						self:setBtnVisible(true,false,true,false,true,true)
						self:setBtnEnble(true,false,true,false,true,true)
						self:setBtnBright(true,false,true,false,true,true)
						if self.betIndex <=1 then
						 	self.btn_bet_sub:setEnabled(false)
							self.btn_bet_sub:setBright(false)
						 else
						 	self.btn_bet_sub:setEnabled(true)
							self.btn_bet_sub:setBright(true)
						 end
						--self._setLayer:setBtnEnable(true)
						FreeGameNumber:setVisible(false)
						FreeGameCount:setVisible(false)
						self.FreeRotationNum=0
						self.FreeRotationCount=0
						self.text_win:setString("")
						self.sp_win:setVisible(false)
						typeRotationSpeed=1
						self.FreeRotation=0
						FreeGamewinAndCount=0
						winAndCount=0
						for i=1,5 do
							FreeGameGoldBat[i]:setVisible(false)
						end

				end),nil))
			end
		end
	end	
end
function GameViewLayer:showWinFreeGame()
	--GameViewLayer:setCardDark(); 

	if self.nScatter == 3 then

	 		self.FreeRotationCount = self.FreeRotationCount+ 10 ;
	elseif self.nScatter == 4 then

	 		self.FreeRotationCount = self.FreeRotationCount+ 20;

	elseif self.nScatter >= 5 then

	 		self.FreeRotationCount = self.FreeRotationCount+ 50;

	end

	for i,ico in pairs(self.serverIcos) do 
		if ico == 8 then
			self.table_pans[i]:getChildren()[1]:runAction(cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("Anim"..self.serverIcos[i])))
		end
 	end
 -- 	self.btn_spin:setVisible(true);
	-- self.btn_spin:setEnabled(false);
	-- self.btn_spin:setBright(false);
	if self.LoseFreeGame ==false then
		self:showWinline();
	else
		release_print("--------进入没中间播放动画")
		
		self:ShowLoseFreeGame()
	end
end
function GameViewLayer:ShowLoseFreeGame()
	release_print("--------进入了ShowLoseFreeGame--------")
	--self._setLayer:setBtnEnable(false);
	self.IsStarFreeGame=2;
	if self.MusicTemp then
		AudioEngine.playEffect("mp3/FreeGame_OK.mp3",false);
	end
	self:runAction(cc.Sequence:create(cc.DelayTime:create(4.0),cc.CallFunc:create(function(sender) 
				if self.MusicTemp then
					AudioEngine.playEffect("mp3/FreeGame_OK_2.mp3",false)
				end
	end),nil));
	self:runAction(cc.Sequence:create(cc.DelayTime:create(3.0),cc.CallFunc:create(function(sender) 
			
			local sp_Scatter = cc.Sprite:create("Anim/SCATTER/1.png")
			sp_Scatter:setLocalZOrder(999);
			sp_Scatter:setPosition(667,375);
			sp_Scatter:setScaleX(2.6);
			sp_Scatter:setScaleY(1.95);
			self:addChild(sp_Scatter);
			local seq = cc.CallFunc:create(function(sender) 
					if self.MusicTemp then
						AudioEngine.playEffect("mp3/FreeGame_OK_1.mp3");
					end
				end)


			local amo = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("AnimSCATTER"));
			--local m_spawn = cc.Spawn(seq1,);
			sp_Scatter:runAction(cc.Sequence:create(seq,amo,cc.CallFunc:create(function(sender)
				AudioEngine.stopMusic();
				if self.MusicTemp then
					AudioEngine.playMusic("mp3/FreeGameBG.mp3",true)
				end 
				sp_Scatter:setScaleX(0);
				sp_Scatter:setScaleY(0);
				self.btn_spin:loadTextures("GameButton/FreeSpin_1.png","GameButton/FreeSpin_2.png","GameButton/FreeSpin_3.png")
				local bg = cc.Sprite:create("Image/FreeBG.png");
				self.Mainbg_1:setTexture(bg:getTexture())
				--Top_Sp:stopAllActions()
				--Top_Sp:setVisible(false);
				self:setCard();
				--Top_Scarrt:setVisible(true);
				--local Top_action444=cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("AnimaFreeGame"))
				--local Top_Forever33 = cc.RepeatForever:create(Top_action444);
				--Top_Scarrt:runAction(Top_Forever33);
				FreeGameNumber:setVisible(true);
				FreeGameCount:setVisible(true);
				FreeGameNumber:setString(self.FreeRotationNum);
				FreeGameCount:setString(self.FreeRotationCount);
				for i=1,5 do
					FreeGameGoldBat[i]:setVisible(true);
				end

				self.sp_win:setVisible(true);
				self.autoCount=self.FreeRotationCount;
				self:FreeGamePlay();
			end),nil))
	end),nil));
end

function GameViewLayer:showWin() 
	self.isWin =true
	local count = #self.winLines
	local countTime = 1 --中奖动画执行时间
		winAndCount = 0
		if self.nScatter >= 3 and self.FreeRotation == 0 then
				self.FreeRotation = 1
				--self._setLayer:setBtnEnable(false)
				for i = 1, 11 do
					self.Animationgofree[i]:setLoops(1)
				end
				self.btn_stop:setVisible(false)
				self.btn_stop:setEnabled(false)
				self.btn_stop:setBright(false)

				self.btn_spin:setVisible(true)
				self.btn_spin:setEnabled(false)
				self.btn_spin:setBright(false)
				self:showWinFreeGame()
				release_print("进入FreeGame")

		elseif self.nScatter < 3 and  self.FreeRotation == 1 then
				release_print("----self.nScatter--->>"..self.nScatter)

				for i=1,11 do
					self.Animationgofree[i]:setLoops(1)
				end
				self:showWinline()
				release_print("进入自动旋转  self.RedrichCount >=0个发财")
		else
			
		end
		if self.RedrichCount < 2 and self.FreeRotation == 0  then
			self:showWinline()			     
			release_print("执行正常判断")
		
		elseif self.RedrichCount >= 2 and self.FreeRotation == 0 and FaiCaiAndveryGood ==false then
			--有中2列以上红发财   
			release_print("有中2列或以上红发财")
			------inScene:showWinline()
			self:showWinRedrich()		
		end
end
function GameViewLayer:setCardDark()--图标变暗
	for i=1,15 do 
		local card  =cc.Sprite:create("gray/"..self.serverIcos[i]..".png")
		self.table_pans[i]:getChildren()[1]:setTexture(card:getTexture())
	end 
end 

function GameViewLayer:setCard()--图标变亮
	for i=1,15 do 
		local card  =cc.Sprite:create("card/"..self.serverIcos[i]..".png")
		self.table_pans[i]:getChildren()[1]:setTexture(card:getTexture())
	end 
end
function GameViewLayer:getIndexByXY(x,y)
	if(y == 1)then 
		return 10 + x
	end 
	if(y == 2)then 
		return 5 + x
	end 	
	return x
end

function GameViewLayer:NumGlitter()
	print("-------数字闪烁--------------")
	for i,lineNum in ipairs(self.winLines) do
		if (tonumber(lineNum) > 0) then 
			local SeqStarLines = cc.CallFunc:create(function(sender)
				self.LightLineNum[lineNum]:setOpacity(255)
				self.RightLineNum[lineNum]:setOpacity(255)
				self.LightLineNum[lineNum]:setVisible(true) 
				self.RightLineNum[lineNum]:setVisible(true)
			end)

			local SeqStopLines = cc.CallFunc:create(function(sender)
				self.LightLineNum[lineNum]:setVisible(false)
				self.RightLineNum[lineNum]:setVisible(false)
			end)

			local SeqlineNum = cc.Sequence:create(SeqStarLines,cc.DelayTime:create(0.25),SeqStopLines,cc.DelayTime:create(0.25))
			local ShowNumber = cc.RepeatForever:create(SeqlineNum)
			self.LightLineNum[lineNum]:runAction(ShowNumber)
		end
	end
end

function GameViewLayer:FreeGamePlay()
	if  self.FreeRotationNum == self.FreeRotationCount then
		self.FreeRotation=0;
		
		self.btn_spin:loadTextures("GameButton/Spin_1.png","GameButton/spin_2.png","GameButton/spin_3.png")
		
		local bg   =cc.Sprite:create("Image/Normal.png");
		self.Mainbg_1:setTexture(bg:getTexture())

		--Top_Scarrt:stopAllActions()
		--Top_Scarrt:setVisible(false);
	
		FreeGameNumber:setVisible(false);
		FreeGameCount:setVisible(false);
		
		self.text_win:setString("");
		self.sp_win:setVisible(false);
		typeRotationSpeed=1;
		--Top_Sp:setVisible(true);
		--local Top_action012=cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("CaiShenDao"))
		--local Top_Forever66 = cc.RepeatForever:create(Top_action012);
		--Top_Sp:runAction(Top_Forever66);
		self.FreeRotation=0;
		FreeGamewinAndCount=0;
		winAndCount=0;
		for i=1,5 do
			FreeGameGoldBat[i]:setVisible(false);
		end
		system:setBtnEnable(self,true);
	end
	--winAndCount=0;
	release_print("进入了 FreeGamePlay播放动画--->> ")
	self:runAction(cc.Sequence:create(
		cc.DelayTime:create(1)
		,cc.CallFunc:create(function(sender)
			self.RUNING=false
			self:autoRoll() --立马执行，其他的使用定时器启动
			autoSchedulerEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()self:autoRoll()end, 0.5, false)
	end)))
end

function GameViewLayer:showWinline()
	local count = #self.winLines
	local countTime = 0.7 --中奖动画执行时间

	if self.autoCount > 0 then  
		local _seq = cc.Sequence:create(cc.DelayTime:create(count*countTime),cc.CallFunc:create(
			function()
				self:cleanWin()
			end),nil)
		self:runAction(_seq)	
	end
	self:setCardDark() 
	for i=1,15 do
		self.FreeGameFaCai[i]:setOpacity(0)
		self.FreeGameFaCai[i]:setVisible(false)
	end
	print("进入了 showWinline--->> ")
	for indexKey,lineNum in pairs(self.winLines) do 
		if (tonumber(lineNum) > 0) then  
			local fadein = cc.FadeIn:create(0.1)
			local dt =cc.DelayTime:create( 0.1+(indexKey-1) * countTime)--等待队列前执行完成=当前索引*单个时间

			local fadeout= cc.FadeOut:create(0.05) 
			local dt2 =cc.DelayTime:create( (count-indexKey+1) * countTime)--等待队列后执行完成=当前索引*单个时间
	
			local seq =cc.Sequence:create(dt,cc.CallFunc:create(function(sender)
					sender:setVisible(true)
					sender:setLocalZOrder(1)
					for i=1,15 do
						self.FreeGameFaCai[i]:setOpacity(0)
						self.FreeGameFaCai[i]:setVisible(false)
					end

					for index,line in pairs(self.winLinePoints) do --显示点 
						for index2,point in pairs(line) do 
							local idx =self:getIndexByXY(point[1],point[2]) 
							self.table_pans[idx]:getChildren()[1]:setTexture("card/"..self.serverIcos[idx]..".png")
						end
					end
					if self.MusicTemp then
						AudioEngine.playEffect("mp3/Line_"..indexKey..".mp3",false)
					end
					print(lineNum.."------播放线条声音----------"..indexKey)
					for i, v in pairs (self.table_lines[lineNum]:getChildByName("LineNum"..lineNum):getChildren() ) do 	
						if  (i == 1 ) then 
							if self.winNumb[indexKey] / self.bet[self.betIndex] >=100 then
								--self.JackpotBigWin:setVisible(true)
								self:runAction(cc.Sequence:create(cc.DelayTime:create(2.5),cc.CallFunc:create(function() 
									--self.JackpotBigWin:setVisible(false)
								end)))		
							end
								
							v:setString(self.winNumb[indexKey])
							self.WinGoldCount=self.WinGoldCount+self.winNumb[indexKey]
							self.text_tipwin:setString(self.WinGoldCount)
							self.sp_tipwin:setVisible(true)
							self.text_win:setString(self.WinGoldCount)
							if self.FreeRotation == 0 then
								str = string.gsub(self.text_Score:getString(),",","")
								local a = tonumber(str) + self.winNumb[indexKey]
								self:FormatScore(self.text_Score,a)
								--self.text_Score:setString(a)
							end
							break
						end
					end			 
				end),fadein,cc.DelayTime:create(0.2),fadeout,dt2,nil)
				local rf =cc.RepeatForever:create(seq)
				self.table_lines[lineNum]:setVisible(true) 
				self.table_lines[lineNum]:setOpacity(0) 
				self.table_lines[lineNum]:runAction(seq) --显示中奖线、
				local fadein1 = cc.FadeIn:create(0.1)
				local dt1 =cc.DelayTime:create( 0.1+(indexKey-1) * countTime)--等待队列前执行完成=当前索引*单个时间
				local fadeout1= cc.FadeOut:create(0.05) 
				local dt21 =cc.DelayTime:create( (count-indexKey) * countTime)--等待队列后执行完成=当前索引*单个时间
				local seq1 =cc.Sequence:create(dt,cc.CallFunc:create(function(sender)
					sender:setVisible(true)
					sender:setLocalZOrder(1)
				end),fadein1,cc.DelayTime:create(0.5),fadeout1,dt21,nil)
				local rf1 =cc.RepeatForever:create(seq1)
				self.LightLineNum[lineNum]:runAction(seq1)

				local fadein2 = cc.FadeIn:create(0.1)
				local dt2 =cc.DelayTime:create( 0.1+(indexKey-1) * countTime)--等待队列前执行完成=当前索引*单个时间
				local fadeout2= cc.FadeOut:create(0.05) 
				local dt22 =cc.DelayTime:create( (count-indexKey) * countTime)--等待队列后执行完成=当前索引*单个时间
				local seq2 =cc.Sequence:create(dt,cc.CallFunc:create(function(sender)
					sender:setVisible(true)
					sender:setLocalZOrder(1)
					for i=1,15 do
							self.FreeGameFaCai[i]:setOpacity(0)
							self.FreeGameFaCai[i]:setVisible(false)
					end

				end),fadein2,cc.DelayTime:create(0.2),fadeout2,dt22,nil)
				local rf2 =cc.RepeatForever:create(seq2)
				self.RightLineNum[lineNum]:runAction(seq2)
				
			end
		end

		for l_i,line_point in pairs(self.winLinePoints) do
			for p_i,point in pairs(line_point) do
				local card_index = 5*(3-point[2])+point[1]
				local temp_ani_frame = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("Frame"))
				local seq_frame = cc.Sequence:create(cc.DelayTime:create(0.1 + (l_i - 1) * countTime),
					cc.CallFunc:create(function(sender)
						sender:setVisible(true)
					end),
					cc.DelayTime:create(0.5),
					cc.CallFunc:create(function(sender)
						sender:setVisible(false)
					end),
					cc.DelayTime:create((count - l_i) * countTime ),
					cc.CallFunc:create(function(sender)
						sender:setVisible(true)
					end),temp_ani_frame,nil)
					self.table_winStars[card_index]:runAction(seq_frame)
				end
			end
			self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function() 
				self.sp_tipwin:setVisible(false)
			end)))

			print("免费旋转开关---->"..self.FreeRotation)
			if self.FreeRotation==1 then
				print("---播放中奖免费动画---")
				if self.nScatter < 3 then
				end
				print("-----IsStarFreeGame----"..self.IsStarFreeGame)
				if self.IsStarFreeGame == 1 then
					self:runAction(cc.Sequence:create(
						cc.DelayTime:create(0.65 * #self.winLines),
						cc.CallFunc:create(function(sender)
							for index,line in pairs(self.winLinePoints) do --显示点
								for index2,point in pairs(line) do
									local idx =self:getIndexByXY(point[1],point[2])
									print("!!!!!!!!!!!!!!!!免费2!!!!!!!!!!!!!!!!")
									self.table_pans[idx]:getChildren()[1]:runAction(
								  		cc.Sequence:create(
											cc.CallFunc:create(function(sender)
												self:NumGlitter()
									 		end),cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("Anim"..self.serverIcos[idx]))
									 		,cc.CallFunc:create(function(sender)
									 			local card = cc.Sprite:create("card/"..self.serverIcos[idx]..".png")
												self.table_pans[idx]:getChildren()[1]:setTexture(card:getTexture())
												if index == table.getn(self.winLinePoints)  then
													if index2 == table.getn(line) then
														release_print("第1次进入免费旋转")
														self.btn_max:setVisible(true)
														self.btn_autostop:setVisible(false)
														self.btn_stop:setVisible(false)
														self.btn_spin:setVisible(true)														
														--self._setLayer:setBtnEnable(false)
														self.IsStarFreeGame=2
														AudioEngine.stopMusic()
														AudioEngine.stopAllEffects()
														if self.MusicTemp then
															AudioEngine.playEffect("mp3/FreeGame_OK.mp3")
														end
														self:runAction(cc.Sequence:create(cc.DelayTime:create(3.0),
															cc.CallFunc:create(function(sender)
																if self.MusicTemp then
																	AudioEngine.playEffect("mp3/FreeGame_OK_1.mp3")
																end
																local dt = cc.DelayTime:create(1.0)
													    		local seq = cc.Sequence:create(dt,cc.CallFunc:create(function()
													        		if self.MusicTemp then
													        			AudioEngine.playEffect("mp3/FreeGame_OK_2.mp3",false)
													        		end
													   			end),nil)
														self:runAction(seq)

														local sp_Scatter = cc.Sprite:create("Anim/SCATTER/1.png")
														sp_Scatter:setLocalZOrder(999)
														sp_Scatter:setPosition(667, 375)
														sp_Scatter:setScaleX(2.6)
														sp_Scatter:setScaleY(1.95)
														self:addChild(sp_Scatter)
														sp_Scatter:runAction(cc.Sequence:create(
															cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("AnimSCATTER")),	
																cc.CallFunc:create(function(sender)																
																	AudioEngine.stopMusic()
																	if self.MusicTemp then
																		AudioEngine.playMusic("mp3/FreeGameBG.mp3",true)
																	end
																	sp_Scatter:setScaleX(0)
																	sp_Scatter:setScaleY(0)
																	self.btn_spin:loadTextures("GameButton/FreeSpin_1.png","GameButton/FreeSpin_2.png","GameButton/FreeSpin_3.png")
																	local bg   =cc.Sprite:create("Image/FreeBG.png")
																	self.Mainbg_1:setTexture(bg:getTexture())
																	self:setCard()
																	FreeGameNumber:setVisible(true)
																	FreeGameCount:setVisible(true)
																	FreeGameNumber:setString(self.FreeRotationNum)
																	FreeGameCount:setString(self.FreeRotationCount)
																	for i = 1, 5 do
																		FreeGameGoldBat[i]:setVisible(true)
																	end
																	self.sp_win:setVisible(true)
																	self.autoCount=self.FreeRotationCount
																	self:FreeGamePlay()
																end)))
															end)))
													end
												end
									end)))
								end
							end
							end)))
			else
				local DelayTime = 0
				for i,v in ipairs(self.winLines) do
					DelayTime = DelayTime + 1
				end
				self:runAction(cc.Sequence:create(
				cc.DelayTime:create(DelayTime*0.64),
				cc.CallFunc:create(function(sender) 
					release_print("免费旋转播放动画--【1】")
					self:NumGlitter()
					for index,line in pairs(self.winLinePoints) do --显示点
						for index2,point in pairs(line) do 
							local idx =self:getIndexByXY(point[1],point[2])
							self.table_pans[idx]:getChildren()[1]:runAction(cc.Sequence:create(cc.Spawn:create(cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("Anim"..self.serverIcos[idx])),
								cc.CallFunc:create(function(sender)
									local indx = 0
									if self.FreeRotationNum == self.FreeRotationCount then
										self.btn_spin:setVisible(true)
										self.btn_spin:setEnabled(false)
										self.btn_spin:setBright(false)
										self.btn_stop:setVisible(false)
									else
										self.btn_stop:setVisible(false)
										self.btn_spin:setVisible(true)
										self.btn_spin:setEnabled(true)
										self.btn_spin:setBright(true)
									end
									print("!!!!!!!!!!!!免费!!!!!!!!!!!!!!!!!!!!")
									if self.IsWhole >= 9 then
										if self.MusicTemp then
											AudioEngine.playEffect("mp3/CardWhole/"..self.serverIcos[idx]..".mp3")
										end
									else
										if self.MusicTemp then
											AudioEngine.playEffect("mp3/Card/"..self.serverIcos[idx]..".mp3")
											print("免费旋转播放动画声音--------mp3/Card/"..self.serverIcos[idx]..".mp3")
										end
									end
									print("-----------------免费---------------------")
									if self.FreeRotationNum == self.FreeRotationCount then
										
										self.btn_spin:setVisible(true)
										self.btn_spin:setEnabled(false)
										self.btn_spin:setBright(false)
									end
									for i = 1,15 do
										if self.serverIcos[i] == 8 then
											indx = indx + 1
										end
										if i == 15 then
											for j = 1, 15 do
												if indx >= 3 and self.serverIcos[j] == 8 then
												self.table_pans[j]:getChildren()[1]:runAction(cc.Sequence:create(
												cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("Anim8"))
												,cc.CallFunc:create(function(sender)
													local card   =cc.Sprite:create("card/8.png")
													self.table_pans[j]:getChildren()[1]:setTexture(card:getTexture())
													indx=0
													end)
												))
											end
										end
									end
								end
							end)),
							cc.CallFunc:create(function(sender)
								local card   =cc.Sprite:create("card/"..self.serverIcos[idx]..".png")
								self.table_pans[idx]:getChildren()[1]:setTexture(card:getTexture())
								if index == table.getn(self.winLinePoints)  then
									if index2 == table.getn(line) then
										for i = 1, 15 do
											if self.serverIcos[i] == 8 then
												self.NumIdex=self.NumIdex+1												
											end
											if i == 15 then
												if self.NumIdex >= 5 then
													self.NumLabel:setString("50")
													self:InitBG()
													self.NumIdex=0
												elseif self.NumIdex == 4  then
													self.NumLabel:setString("20")
													self:InitBG()
													self.NumIdex=0
												elseif self.NumIdex==3  then
													self.NumLabel:setString("10")
													self:InitBG()
													self.NumIdex = 0
												elseif self.NumIdex < 3  then
													self.RUNING = false
													self.NumIdex = 0
												end
												
											end
										end
										
								print("已旋转次数:"..self.FreeRotationNum)
								print("总旋转次数:"..self.FreeRotationCount)
								
								if self.FreeRotationNum == self.FreeRotationCount then
									release_print("---------退出免费旋转")
									self.btn_spin:setVisible(true)
									self.btn_spin:setEnabled(false)
									self.btn_spin:setBright(false)
									self.FreeRotation=0
									self.IsStarFreeGame=1
									self.FreeGameOverBG:setVisible(true)
									self.Counter=1
									self:InitFreeGameOver()
									self.autoNumCount=true
									self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function()
										self:NumautoRoll() --立马执行，其他的使用定时器启动
										if self.MusicTemp then
											VoiceGold1 =AudioEngine.playEffect("mp3/main/Score.mp3",true)
										end
									AutoNumSchedulerEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
										self:NumautoRoll()end,0.03,false)
									end),nil))
									print("IsStarFreeGame-退出免费旋转--"..self.IsStarFreeGame)									
								end
							end
						end
				end)))
			end
		end
		print("第1次免费旋转播放动画--END")
		end)))
		end
		else
			release_print("--播放不是中奖免费的动画--")
			self:runAction(cc.Sequence:create(
				cc.DelayTime:create(0.64 * #self.winLines),
				cc.CallFunc:create(function(sender) 
					self:NumGlitter()
					--AudioEngine.playEffect("mp3/Card/"..self.serverIcos[idx]..".mp3")
					for index,line in pairs(self.winLinePoints) do --显示点
						for index2,point in pairs(line) do 
							local idx =self:getIndexByXY(point[1],point[2])
							self.table_pans[idx]:getChildren()[1]:runAction(cc.Sequence:create(cc.CallFunc:create(function(sender)
							    if self.autoCount < 1 then
							    	--print("------11111111111111111111111111")
									 self:setBtnVisible(true,false,true,false,true,true)
									 self:setBtnEnble(true,false,true,false,true,true)
									 self:setBtnBright(true,false,true,false,true,true)
									 if self.betIndex <=1 then
									 	self.btn_bet_sub:setEnabled(false)
										self.btn_bet_sub:setBright(false)
									 else
									 	self.btn_bet_sub:setEnabled(true)
										self.btn_bet_sub:setBright(true)
									 end
									release_print("!!!!!!!!!!!!!不是免费!!!!!!!!!!!!!!!!!!!")
									if self.MusicTemp then
										if self.IsWhole>=9 then
											AudioEngine.playEffect("mp3/CardWhole/"..self.serverIcos[idx]..".mp3")
										else
											AudioEngine.playEffect("mp3/Card/"..self.serverIcos[idx]..".mp3")
										end
									end
									release_print("--------------------------------------")
								elseif self.autoCount > 0 then
									--print("------2222222222222222222222222222")
									 self:setBtnVisible(true,false,false,true,true,true)
									 self:setBtnEnble(true,false,false,true,false,false)
									 self:setBtnBright(true,false,false,true,false,false)
									release_print("!!!!!!!!!!!!不是!!!!!!!!!!!!!!!!!!!!")
									if self.MusicTemp then
										if self.IsWhole>=9 then
											AudioEngine.playEffect("mp3/CardWhole/"..self.serverIcos[idx]..".mp3")
										else
											AudioEngine.playEffect("mp3/Card/"..self.serverIcos[idx]..".mp3")
										end
									end
									release_print("--------------------------------------")
								end
								
							end),cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("Anim"..self.serverIcos[idx]))
							,cc.CallFunc:create(function(sender)

								local card   =cc.Sprite:create("card/"..self.serverIcos[idx]..".png")
								self.table_pans[idx]:getChildren()[1]:setTexture(card:getTexture())
								if index == table.getn(self.winLinePoints)  then
									if index2 == table.getn(line) then
										self.RUNING = false
									end
								end
							end)
							))

						end
					end
					self:GameBetIndex()
				end)
			))
		end	
end
function GameViewLayer:InitBG()
	self.NumBG:setVisible(true)
	FreeGameCount:setString(self.FreeRotationCount)
	local moveto = cc.MoveTo:create(1.0, cc.p(appdf.WIDTH / 2, appdf.HEIGHT / 2 + 100))
	local moveby = cc.MoveTo:create(1.0, cc.p(appdf.WIDTH / 2, 1000))
	self.NumBG:runAction(cc.Sequence:create(moveto,cc.DelayTime:create(2.0),moveby,cc.CallFunc:create(function(sender)
			self.RUNING = false
			self.NumLabel:setString("0")
			if self.MusicTemp then
				AudioEngine.playMusic("mp3/FreeGameBG.mp3",true)
			end
		end)))
	
end
function GameViewLayer:createCard(pan_1,tiem)
	local li = math.ceil((2300 * tiem) / 158)
	if #pan_1:getChildren() < li then
		for i=#pan_1:getChildren(),li do
			local card1_1 = cc.Sprite:create("card/"..math.random(0,10)..".png")
			card1_1:setAnchorPoint(0,0) 
			card1_1:setPosition(0,158*(i-1))
			card1_1:setTag(i)
			pan_1:addChild(card1_1)
		end
	elseif #pan_1:getChildren() > li then
		for key,value in pairs(pan_1:getChildren()) do
			if key > li then
				value:removeFromParent()
			end
		end
	end
end

function GameViewLayer:initPansEventListener()
	for i = 1,#self.table_pans do
		local pan_1 = self.table_pans[i] 
		pan_1:setTouchEnabled(false)
		self.Panel_Calick[i] = ccui.Layout:create()
		self.Panel_Calick[i]:setContentSize(pan_1:getContentSize())
		self.Panel_Calick[i]:setScaleX(pan_1:getScaleX())
		self.Panel_Calick[i]:setScaleY(pan_1:getScaleY())
		self.Panel_Calick[i]:setPosition(pan_1:getPosition())
		self.Panel_Calick[i]:setClippingEnabled(true)
		self.Panel_Calick[i]:setTag(i)
		self.Panel_Calick[i]:setVisible(false)
        self._csbNode:addChild(self.Panel_Calick[i],pan_1:getLocalZOrder())
        self:createCard(self.Panel_Calick[i],1)
	end
	for i = 1, 5 do
		local pan_1 = self.table_pans[i] 
		local width = pan_1:getContentSize().width
		local height = ((pan_1:getScaleY() * pan_1:getContentSize().height) + pan_1:getPositionY()) - self.table_pans[i+10]:getPositionY()
		self.Panel_Gray[i] = ccui.Layout:create()
		self.Panel_Gray[i]:setContentSize(width,height)
		self.Panel_Gray[i]:setBackGroundColorType(1)
		self.Panel_Gray[i]:setOpacity(0)
		self.Panel_Gray[i]:setBackGroundColor(cc.c3b(0,0,0))
		self.Panel_Gray[i]:setScaleX(pan_1:getScaleX())
		self.Panel_Gray[i]:setPosition(self.table_pans[i+10]:getPosition())
		self.Panel_Gray[i]:setTag(i)
		self.Panel_Gray[i]:setTouchEnabled(true)
	    self._csbNode:addChild(self.Panel_Gray[i], 10000)
	    self.Panel_Gray[i]:addClickEventListener(function(sender)
			if not self.btn_spin:isVisible() or not self.btn_spin:isEnabled() 
				or self.autoCount > 0 or self.RollBool then
				print("======================return V ",self.btn_spin:isVisible())
				print("======================return E ",self.btn_spin:isEnabled())
				print("======================return A "..self.autoCount)
				print("======================return R ",self.RollBool)
				return
			end
			print("--------initPansEventListener-----------")
			sender:setTouchEnabled(false)
			local tag = tonumber(sender:getTag())
			for i = 1, 3 do
				self.GameRollCode = self.GameRollCode + 1
				self.Panel_CalickCode = tag
				tag = tag + 5
				self:startGameRoll(false)
			end
		end)
	end
end

function GameViewLayer:startGameRoll(bool)  --发送开始旋转
	--余额判断 用户余额少于用户花费 则提示
	self:GameBetIndex()
	if ( self.BalanceText < self.lines * self.bet[self.betIndex]) then
		print("#123###################123")
		local tipLayer = cc.CSLoader:createNode("credit/NotEnoughCreditLayer.csb")
		local btn_continue = tipLayer:getChildByName("btn")
		btn_continue:addTouchEventListener(
		function(sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				tipLayer:stopAllActions()
				tipLayer:removeFromParent(true)
			end 
		end)
		self:addChild(tipLayer)
		self.autoCount = 0--关闭自动旋转定时器 
		return 
	end
 	
	-- 第一次
	if self.GameRollCode == 1 then
		if  self.sp_tipwin:isVisible() then
			self.sp_tipwin:setVisible(true)
		end
		 
		-- if self.JackpotBigWin:isVisible() then
		-- 	self.JackpotBigWin:setVisible(false)
		-- end
		AudioEngine.stopAllEffects()
		self:cleanWin()
		self:showLines(0) --隐藏中奖线	 

		self:setBtnVisible(true,false,true,false,true,true)
		self:setBtnEnble(true,false,false,false,false,false)
		self:setBtnBright(true,false,false,false,false,false)
		for i = 1, 9 do
			self.LightLineNum[i]:stopAllActions()
			self.RightLineNum[i]:stopAllActions()
			self.LightLineNum[i]:setOpacity(0)
			self.RightLineNum[i]:setOpacity(0)
			self.LightLineNum[i]:setVisible(false)
			self.RightLineNum[i]:setVisible(false)
		end
		--参数1 线数，线花费，总花费
		b_sendMsgCallback = false
		self.RUNING =true
		self.ROLLING = true
		self.autoFlag = false
		self.JackpotTextNum = 0
		self.GameRollFunNum = 0
		for i = 1, 5 do
			self.HongFaCaiArmature[i]:stopAllActions()
			self.HongFaCaiArmature[i]:setVisible(false)
		end
		local score = self.lines * self.bet[self.betIndex]
		self:onAnalogPay(score)
		self._scene:startGame(self.lines, self.lines * self.bet[self.betIndex], self.bet[self.betIndex]) --开始游戏，发送给服务端
	elseif self.GameRollCode == #self.Panel_Calick then
		self.btn_spin:setVisible(false)
		self.btn_stop:setVisible(true)
	end
	--游戏开始立马旋转，接收到网络消息后停止。
	self:GameRollFunCode(self.Panel_CalickCode,bool)	
end

function GameViewLayer:setCardPoint(pan_1)
	for i,value in pairs(pan_1:getChildren()) do
		if value:getPositionY() <= -158 then
			local j = i-1
			if i == 1 then
				j = #pan_1:getChildren()
			end
			value:setPositionY(pan_1:getChildren()[j]:getPositionY()+158)
		end
	end
end

function GameViewLayer:GameRollFunCode(code,bool)
	self.table_pans[code]:removeAllChildren()
	self.table_pans[code]:setVisible(false)
	local pan_1 = self.Panel_Calick[code]
	pan_1:setVisible(true)
	local tiem = 1.0
	if bool then
		local t = (code%5==0 and 5 or code%5) -1
		tiem = 0.5 + (0.3*t)
	end
	local tebs = {1,1,1,1,1,2,2,2,2,2,3,3,3,3,3}
	tiem = tiem + tebs[code]*0.2
	self:createCard(pan_1,tiem)
	self:setCardPoint(pan_1)

	pan_1:stopAllActions()
    pan_1:runAction(cc.RepeatForever:create(
    	cc.Sequence:create(cc.DelayTime:create(0),
    		cc.CallFunc:create(function(sender)
	   			self:setCardPoint(pan_1)
	   			if b_sendMsgCallback then
		   			if not self.btn_stop:isEnabled() then
		   				self.btn_stop:setEnabled(true)
						self.btn_stop:setBright(true)
	   				end
					--if self.MusicTemp and bool and self.isMusic then
					--	self.isMusic = false
					--	self.rollBgMp3Id = AudioEngine.playEffect("mp3/GameRolling.mp3")
					--end
	   			end
		end),
    nil)))

    local nRollingCount = 0
   	local function Roll(code)
   		local height = (#pan_1:getChildren() * 158) - pan_1:getContentSize().height
		for key,value in pairs(pan_1:getChildren()) do
			local mov = cc.MoveBy:create(tiem,cc.p(0,-height))--时间=s/v
			value:stopAllActions()
			if key ==#pan_1:getChildren() then
				local seq2 = cc.Sequence:create(mov,cc.CallFunc:create(function(sender)
					if b_sendMsgCallback then
						pan_1:stopAllActions()
						self:endRollCode(code,self.serverIcos,bool)
					else
						nRollingCount = nRollingCount + 1
						if nRollingCount > 15 then
							--self:setNotLineBack(true)
						end
						Roll(code)
					end
				end))
				value:runAction(seq2)
			else
				value:runAction(mov)
			end
		end
   end
   Roll(code)
end
function GameViewLayer:endRollCode(code,icos,bool)
	local pan_1 = self.Panel_Calick[code]
	local height = 0
	local y = 0
	local card = {}
	local zheight = 0
	for i,value in pairs(pan_1:getChildren()) do
		local pointy = value:getPositionY()
		if pointy >= pan_1:getContentSize().height then
			zheight = value:getPositionY()
			value:setTexture(("card/"..icos[code]..".png"))
			table.insert(card,i)
			height = pointy
			break
		end
	end
	self:setCardPoint(pan_1)
	for key,value in pairs(pan_1:getChildren()) do 
		value:stopAllActions()
		local myCardBool = false
		local mov = cc.MoveBy:create(height/2300,cc.p(0,-height))--时间=s/v
		for i,v in pairs(card) do
			if key == v then
				myCardBool = true
				break
			end
		end
		if myCardBool then
			local movUp2 = cc.MoveBy:create(0.1,cc.p(0,-10))--结束回弹
			local movDown2 = cc.MoveBy:create(0.1,cc.p(0,10))--结束回弹
			local seq = cc.Sequence:create(mov,movUp2,movDown2,nil)
			if key == card[1] and code >= 11 then --用一个执行滚动完成回调
				seq = cc.Sequence:create(mov,movUp2,movDown2,cc.DelayTime:create(0.1),cc.CallFunc:create(function()
					if not self.ROLLING then
						return
					end
					if self.MusicTemp then
						AudioEngine.playEffect("mp3/Stop.mp3")
					end
					self.Panel_Gray[code-10]:setOpacity(128)
					local mybool = false
					if code == self.Panel_CalickCode then
						if bool then
							mybool = true
						else
							if self.GameRollCode >= #self.Panel_Calick then
								mybool = true
							end
						end
					end
					if mybool then
						self:stopRallcode()
						self:doWIN()
					end
				end),nil)
			end
			value:runAction(seq)
		else
			value:runAction(mov)
		end
	end 
end
function GameViewLayer:stopRallcode() 
	self:GameBetIndex()
	self:endRoll(self.serverIcos,self.serverWin)
 	for indexKey,pan_1 in pairs(self.table_pans) do
 		self.Panel_Calick[indexKey]:setVisible(false)
		pan_1:removeAllChildren()
		pan_1:setVisible(true)
		local sp =cc.Sprite:create("card/"..self.serverIcos[indexKey]..".png")
		sp:setAnchorPoint(0,0)
		pan_1:addChild(sp)
	end
end

function GameViewLayer:endRoll(icos,win)
	self.ROLLING = true
	self.Linepoint = 0
	self.Handsel = 0
	self:setBtnVisible(true,false,true,false,true,true)
	self:setBtnEnble(false,false,false,false,false,false)
	self:setBtnBright(false,false,false,false,false,false)
	if self.autoCount <= 0 and self.FreeRotation == 0 and self.GameRollCode == 0 then
		self.btn_spin:setVisible(false)
		self.btn_stop:setVisible(true)
		self.btn_stop:setEnabled(true)
		self.btn_stop:setBright(true)
	elseif self.autoCount > 0 and self.FreeRotation == 0 then
		self.btn_spin:setEnabled(false)
		self.btn_autostop:setVisible(true)
		self.btn_autostop:setEnabled(true)
		self.btn_autostop:setBright(true)
		self.btn_stop:setVisible(true)
		self.btn_stop:setEnabled(true)
		self.btn_stop:setBright(true)
	end
	if self.AniFiveLine ~= nil then
		self:stopAllActions()
		self.AniFiveLine:removeFromParent(true)
		self.AniFiveLine=nil
	end

	FaiCaiAndveryGood = false

	for indexKey,sprite_star in pairs(self.table_winStars) do 
		sprite_star:stopAllActions()
		sprite_star:setVisible(false)
	end
	for i = 1, 9 do
		self.LightLineNum[i]:stopAllActions()
		self.RightLineNum[i]:stopAllActions()
		self.LightLineNum[i]:setOpacity(0)
		self.RightLineNum[i]:setOpacity(0)
		self.LightLineNum[i]:setVisible(false)
		self.RightLineNum[i]:setVisible(false)
	end

	for i = 1, 5 do
		self.HongFaCaiArmature[i]:stopAllActions()
		self.HongFaCaiArmature[i]:setVisible(false)
	end
	if self.FreeRotation == 0 then
		--self.text_Score:setString(GlobalUserItem.lUserScore)
	end

	self.RedrichCount = 0  

	self.serverIcos = icos
	self.nScatter = 0
	if self.FreeRotation == 1 then
		self.copyCard = icos
		self:FreerotationAnima()
	end

	if self.FreeRotation == 0 then
		self.WinGoldCount = 0
		self.text_win:setString("")
	end

	--self._setLayer:subScore(self.lines * self.bet[self.betIndex])
	if self.FreeRotation == 0 then
		local a = GlobalUserItem.lUserScore - (self.lines * self.bet[self.betIndex])
		--self.text_Score:setString(a)
	end

	self.serverWin = win

	for i = 1, 15 do
		if self.copyCard[i] == 8 then
			self.nScatter = self.nScatter + 1
		end

		if i == 15 then
			if self.FreeRotation == 1 and self.nScatter >= 3 then
				print("中FreeGame的个数"..self.nScatter)
				if self.nScatter == 5 then
	 				self.autoCount = self.autoCount + 50
	 				self.FreeRotationCount = self.FreeRotationCount + 50
		 			self.FreeRotation = 1
					self.IsStarFreeGame = 2
					self.FreeBalance = true
	 				print("中FreeGame的个数5"..self.nScatter)
				elseif self.FreeRotation == 1 and self.nScatter == 4 then
	 				self.autoCount=self.autoCount+20
	 				self.FreeRotationCount = self.FreeRotationCount + 20
		 			self.FreeRotation = 1
					self.IsStarFreeGame = 2
					self.FreeBalance = true
	 				release_print("中FreeGame的个数4"..self.nScatter)

				elseif self.FreeRotation == 1 and self.nScatter == 3 then
	 				self.autoCount=self.autoCount+10
	 				self.FreeRotationCount = self.FreeRotationCount+ 10
		 			self.FreeRotation=1
					self.IsStarFreeGame=2
					self.FreeBalance=true
	 				release_print("中FreeGame的个数3"..self.nScatter)
				end
					self.nScatter=0
					release_print("中FreeGame后在中FreeGame"..self.nScatter)
			end
		end
	end
		
	self.rollCount = 15
	if self.autoCount <= 0 then
  		self.btn_autostop:setVisible(false)
		self.btn_stop:setVisible(false)
		self.btn_stop:setEnabled(false)
		self.btn_stop:setBright(false)
	else
  		self.btn_autostop:setEnabled(false)
		self.btn_autostop:setBright(false)
		self.btn_stop:setVisible(false)
		self.btn_stop:setEnabled(false)
		self.btn_stop:setBright(false)
	end
	self.btn_spin:setVisible(true)

end

function GameViewLayer:GameRollEnd()
	print("=================GameViewLayer:GameRollEnd()================")
	self.GameRollCode = 0
	self.RollBool = false
	self.isMusic = true
	for i, pan_1 in pairs(self.table_pans) do
		pan_1:setVisible(true)
		self.Panel_Calick[i]:stopAllActions()
		self.Panel_Calick[i]:removeAllChildren()
		if i<=5 then
			self.Panel_Gray[i]:stopAllActions()
			self.Panel_Gray[i]:setOpacity(0)
		end
	end
	if self.autoCount <= 0 then
		for i=1,#self.Panel_Gray do
			self.Panel_Gray[i]:setTouchEnabled(true)
		end
	end
	self._scene:sendReady()
end
function GameViewLayer:GameJackpot(_num) --彩金效果
	--self._setLayer:setBtnEnable(false)
	self:setBtnVisible(true,false,true,false,true,true)
	self:setBtnEnble(false,false,false,false,false,false)
	self:setBtnBright(false,false,false,false,false,false)
	self.autoCount=0

	self.GameJackotTag = true
	self:BeinJackpot()
end
function GameViewLayer:GameWarn(_num ,winbet)
	local winbet = winbet

	print("进入BigWin")
	-- self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function()
	-- 	----------------------------------bigwin-------------------------------------
	-- 	self.GameBigWin = true
	-- 	self.spBigWin =cc.Sprite:create("Hall/Warn/BigWin".._num..".png")
	-- 	self.spBigWin:setScaleX(2.6);
	-- 	self.spBigWin:setScaleY(2.2);
	-- 	self.spBigWin:setPosition(640,450);
	-- 	self.spBigWin:setLocalZOrder(MAXZORDER+1)
	-- 	self:addChild(self.spBigWin);
	-- 	self.spBigWin:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(0.3,0.5),cc.ScaleTo:create(0.3,2.0))))
	-- end),nil))
	if _num > 1 then
		self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function()
			----------------------------------bigwin-------------------------------------
			self.GameBigWin = true
	
			self.spBigWin = cc.Node:create()
			self:addChild(self.spBigWin);
			
			local Partic_gold = cc.ParticleSystemQuad:create("BigWinSpine/goldpen4.plist")  
			Partic_gold:setAutoRemoveOnFinish(true)    --设置播放完毕之后自动释放内存  
			Partic_gold:setPosition(cc.p(0,100))  
			self.spBigWin:addChild(Partic_gold,1)  
	
	
			jsonName = 'BigWinSpine/BigWin.json'
			atlasName = 'BigWinSpine/BigWin.atlas'
			local chessEffectNode = sp.SkeletonAnimation:create(jsonName, atlasName, 1.0)
			:setPosition(cc.p(self.spBigWin:getContentSize().width/2 , self.spBigWin:getContentSize().height/2))
			:addTo(self.spBigWin,2)
			:setAnimation(0, "animation", true)
	
			local winScore = cc.LabelAtlas:_create("0", "BigWinSpine/numb.png", 80, 113, string.byte("0")) 
			winScore:setPosition(cc.p(0,-70)) 
			winScore:setAnchorPoint(cc.p(0.5,0.5))
			self.spBigWin:addChild(winScore,3)   
	
			--分数滚动  0.02s 一次  1s 50次 5万 控制在4s
			local stepBonus=1000;
			if winbet > 200000 then
				stepBonus = winbet / 4 / 50 
			end
			local text=0
			
			self.schedulerIDWin3 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
				text = text+stepBonus;
				winScore:setString(text);
				if(text>=winbet)then
					winScore:setString(winbet);
					cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerIDWin3);
				end
			end, 0.02, false);
	
			self.spBigWin:setPosition(667,450);
			self.spBigWin:setLocalZOrder(MAXZORDER+1)
		
		end),nil))
		
	else 
		self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function()
			self.GameBigWin = true
	
			self.spBigWin = cc.Node:create()
			self:addChild(self.spBigWin);

			local Partic_gold = cc.ParticleSystemQuad:create("BigWinSpine/goldpen2.plist")  
			Partic_gold:setAutoRemoveOnFinish(true)    --设置播放完毕之后自动释放内存  
			Partic_gold:setPosition(cc.p(0,100))  
			self.spBigWin:addChild(Partic_gold,1)  

			local scorebg = cc.Sprite:create("BigWinSpine/goldbg.png")
			scorebg:setPosition(cc.p(self.spBigWin:getContentSize().width/2,self.spBigWin:getContentSize().height/2)) 
			scorebg:setAnchorPoint(cc.p(0.5,0.5))
			scorebg:setScale(7)
			scorebg:setOpacity(0)
			self.spBigWin:addChild(scorebg,1) 
			
			local winScore = cc.LabelAtlas:_create(":"..winbet, "BigWinSpine/numb.png", 80, 113, string.byte("0")) 
			winScore:setPosition(cc.p(scorebg:getContentSize().width/2,scorebg:getContentSize().height/2)) 
			winScore:setAnchorPoint(cc.p(0.5,0.5))
			scorebg:addChild(winScore,1)   
			
			scorebg:runAction(cc.Spawn:create(cc.ScaleTo:create(0.2,1),cc.FadeIn:create(0.5)))
			
			self.spBigWin:setPosition(640,375);
			self.spBigWin:setLocalZOrder(MAXZORDER+1)
		
		end),nil))
	end
end

function GameViewLayer:FreerotationAnima()

				if self.serverIcos[1] == 10 and self.serverIcos[6]==10 and self.serverIcos[11] == 10 then
					self.Redrich[1] =1 ;
					
				else
					self.Redrich[1] =0 ;
				end

				if self.serverIcos[2] == 10 and self.serverIcos[7]==10 and self.serverIcos[12] == 10 then
					self.Redrich[2] =1 ;
				else
					self.Redrich[2] =0 ;
				end

				if self.serverIcos[3] == 10 and self.serverIcos[8]==10 and self.serverIcos[13] == 10 then
					self.Redrich[3] =1 ;
				else
					self.Redrich[3] =0 ;
				end

				if self.serverIcos[4] == 10 and self.serverIcos[9]==10 and self.serverIcos[14] == 10 then
					self.Redrich[4] =1 ;
				else
					self.Redrich[4] =0 ;
				end

				if self.serverIcos[5] == 10 and self.serverIcos[10]==10 and self.serverIcos[15] == 10 then
					self.Redrich[5] =1 ;
				else
					self.Redrich[5] =0 ;
				end

				if  self.Redrich[1] == 1  then
					if self.FreeRotation == 1 then
						self.FreeFaCai=true;
						self:showWinFreeRedrich()
					end	
				end

				if  self.Redrich[2] == 1  then
					if self.FreeRotation == 1 then
						self.FreeFaCai=true;
						self:showWinFreeRedrich()
					end
					
				end 

				if self.Redrich[3] == 1  then
					if self.FreeRotation == 1 then
						self.FreeFaCai=true;
						self:showWinFreeRedrich()
					end
		
				end

				if self.Redrich[4] == 1  then
					if self.FreeRotation == 1 then
						self.FreeFaCai=true;
						self:showWinFreeRedrich()
					end
				end

				if self.Redrich[5] == 1  then 
					if self.FreeRotation == 1 then
						self.FreeFaCai=true;
						self:showWinFreeRedrich()
					end
				end
end

--开始旋转.由网络回调
function GameViewLayer:startRoll(icos,win)
	self.ROLLING = true
	self.Linepoint=0
	self.Handsel=0
	self:setBtnVisible(true,false,true,false,true,true)
	self:setBtnEnble(false,false,false,false,false,false)
	self:setBtnBright(false,false,false,false,false,false)
	if self.autoCount <= 0 and self.FreeRotation== 0 and self.GameRollCode == 0 then
		self.btn_spin:setVisible(false)
		self.btn_stop:setVisible(true)
		self.btn_stop:setEnabled(true)
		self.btn_stop:setBright(true)
	elseif self.autoCount > 0 and self.FreeRotation==0 then
		self.btn_spin:setEnabled(false)
		self.btn_autostop:setVisible(true)
		self.btn_autostop:setEnabled(true)
		self.btn_autostop:setBright(true)
		self.btn_stop:setVisible(true)
		self.btn_stop:setEnabled(true)
		self.btn_stop:setBright(true)
	end
	if self.AniFiveLine~=nil then
		self:stopAllActions()
		self.AniFiveLine:removeFromParent(true)
		self.AniFiveLine=nil
	end

	FaiCaiAndveryGood =false

	for indexKey,sprite_star in pairs(self.table_winStars) do 
		sprite_star:stopAllActions()
		sprite_star:setVisible(false)
	end

	for i=1,9 do
		self.LightLineNum[i]:stopAllActions()
		self.RightLineNum[i]:stopAllActions()
		self.LightLineNum[i]:setOpacity(0)
		self.RightLineNum[i]:setOpacity(0)
		self.LightLineNum[i]:setVisible(false)
		self.RightLineNum[i]:setVisible(false)
	end

	for i=1,5 do
		self.HongFaCaiArmature[i]:stopAllActions()
		self.HongFaCaiArmature[i]:setVisible(false)
	end
	if self.FreeRotation ==0 then
		--self.text_Score:setString(GlobalUserItem.lUserScore)
	end
	self.RedrichCount = 0 
	self.serverIcos= icos
	self.nScatter=0
	if self.FreeRotation == 1 then
	 	self.copyCard=icos
	 	self:FreerotationAnima()
	end
	
	if self.FreeRotation == 0 then
		self.WinGoldCount=0
		self.text_win:setString("")
	end
	--self._setLayer:subScore(self.lines*self.bet[self.betIndex])
	if self.FreeRotation == 0 then
		local a =(GlobalUserItem.lUserScore-(self.lines*self.bet[self.betIndex]))
		--self.text_Score:setString(a)
	end
	
	if self.MusicTemp then
		self.rollBgMp3Id = AudioEngine.playEffect("mp3/Rolling.mp3") 
	end
	self.serverWin = win

	local height = {}
	if typeRotationSpeed == 1 then
		height={1,4-0.3,7-0.6,10-0.9,13-1.2,2-0.1,5-0.4,8-0.7,11-1,14-1.3,3-0.2,6-0.5,9-0.8,12-1.1,15-1.4}
		if self.Redrich[5] == 1  then 
			if self.FreeRotation == 1 then
				release_print("----5----!!!!!!!!!")
				height={1,4-0.3,7-0.6,10-0.9,3,2-0.1,5-0.4,8-0.7,11-1,3,3-0.2,6-0.5,9-0.8,12-1.1,3}
			end
		elseif self.Redrich[4] == 1 then
			if self.FreeRotation == 1 then
				release_print("----4----!!!!!!!!!")
				height={1,4-0.3,7-0.6,3,13-1.2,2-0.1,5-0.4,8-0.7,3,14-1.3,3-0.2,6-0.5,9-0.8,3,15-1.4}
			end
		elseif self.Redrich[5] == 1 and  self.Redrich[4] == 1 then
			if self.FreeRotation == 1 then
				release_print("----4 5----!!!!!!!!!")
				height={1,4-0.3,7-0.6,3,3,2-0.1,5-0.4,8-0.7,3,3,3-0.2,6-0.5,9-0.8,3,3}
			end
		else
			height={1,4-0.3,7-0.6,10-0.9,13-1.2,2-0.1,5-0.4,8-0.7,11-1,14-1.3,3-0.2,6-0.5,9-0.8,12-1.1,15-1.4}
		end	 
	elseif typeRotationSpeed == 2 then
		 height={1*5,4*5-0.3,7*5-0.6,10*5-0.9,13*5-1.2,2*5-0.1,5*5-0.4,8*5-0.7,11*5-1,14*5-1.3,3*5-0.2,6*5-0.5,9*5-0.8,12*5-1.1,15*5-1.4}
	end
	for i = 1, 15 do 
		height[i] =height[i]+2
	end

	local bAuto =self.autoFlag --开始游戏，发送给服务端
	if bAuto then --自动旋转
		self.text_autostop:setString(self.autoCount)
		self.text_autostop:setVisible(false)

	else

	end 

	
	--动画回调函数
	local function callback(sender)  
		sender:stopAllActions()	
		sender:removeFromParent(true) 
	end
	self.rollCount=0--记录滚动完成 
	--bAuto2 = bAuto
	--滚动完成回调函数
	local function rollOver(sender)  

		self.rollCount=self.rollCount+1
			

		--printf("滚完了"..self.rollCount)
		if self.rollCount ==3 or self.rollCount==6 or self.rollCount==9 or self.rollCount==12  or self.rollCount==15 then
			if self.MusicTemp then
				AudioEngine.playEffect("mp3/Stop.mp3")
			end
		end
		if self.copyCard[self.rollCount] ~=10 then
			if self.ROLLING == true then
				local card  =cc.Sprite:create("card/"..self.copyCard[self.rollCount]..".png")
				self.table_pans[self.rollCount]:getChildren()[1]:setTexture(card:getTexture())
			end
		end


			--print("---sender:getName()--->>>  "..sender:getName())
			if sender:getName() == "10" and  self.FreeRotation == 0 and self.RedrichCount < 2  then
				--print("--------播放发财位置---->>"..self.rollCount)
				sender:runAction(cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("gofree1")))
			elseif sender:getName() == "8" and self.FreeRotation == 0  then
				--print("-------播放FreeGame位置--->>"..self.rollCount)
				sender:runAction(cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("gofree")))
				self.Music_Scatter=self.Music_Scatter+1
				if self.MusicTemp then
					AudioEngine.playEffect("mp3/scatter_"..self.Music_Scatter..".mp3")
				end
			elseif sender:getName() == "8" and self.FreeRotation == 1  then
				self.Music_Scatter=self.Music_Scatter+1
				if self.MusicTemp then
					AudioEngine.playEffect("mp3/scatter_"..self.Music_Scatter..".mp3")	
				end		   						   
			end

		if self.rollCount>=15 then
			if self.autoCount <=0 then
		  		self.btn_autostop:setVisible(false)
				self.btn_stop:setVisible(false)
				self.btn_stop:setEnabled(false)
				self.btn_stop:setBright(false)
			else
		  		self.btn_autostop:setEnabled(false)
				self.btn_autostop:setBright(false)
				self.btn_stop:setVisible(false)
				self.btn_stop:setEnabled(false)
				self.btn_stop:setBright(false)
			end
			self.ROLLING = false
			self.btn_spin:setVisible(true)

			self:doWIN()
			if  self.autoCount==0 then 
				self.text_autostop:setVisible(false)
			else

			end
		end
	end

	for i=1,15 do
		if self.copyCard[i] == 8 then
			self.nScatter = self.nScatter + 1
		end

		if i== 15 then
			if self.FreeRotation == 1 and self.nScatter>=3 then
				release_print("中FreeGame的个数"..self.nScatter)
				if self.nScatter == 5 then
	 				self.autoCount=self.autoCount+50
	 				self.FreeRotationCount = self.FreeRotationCount+ 50 
		 			self.FreeRotation=1
					self.IsStarFreeGame=2
					self.FreeBalance=true
	 				release_print("中FreeGame的个数5"..self.nScatter)
				elseif self.FreeRotation == 1 and self.nScatter == 4 then
	 				self.autoCount=self.autoCount+20
	 				self.FreeRotationCount = self.FreeRotationCount+ 20
		 			self.FreeRotation=1
					self.IsStarFreeGame=2
					self.FreeBalance=true
	 				release_print("中FreeGame的个数4"..self.nScatter)

				elseif self.FreeRotation == 1 and self.nScatter == 3 then
	 				self.autoCount=self.autoCount+10
	 				self.FreeRotationCount = self.FreeRotationCount+ 10
		 			self.FreeRotation=1
					self.IsStarFreeGame=2
					self.FreeBalance=true
	 				release_print("中FreeGame的个数3"..self.nScatter)
				end
					self.nScatter=0
					release_print("中FreeGame后在中FreeGame"..self.nScatter)
			end
		end
	end
		
	for i = 1, 15 do
		local roll = self:createRoll(height[i])
		roll:setAnchorPoint(0,0)
		roll:setPosition(0,153)
		self.table_pans[i]:addChild(roll)

		local sp =cc.Sprite:create("card/"..self.copyCard[i]..".png")
		-- sp:setScaleX(1.25)
		-- sp:setScaleY(0.94)
		sp:setAnchorPoint(0,0)
		sp:setPosition(0,153+153*height[i])
		sp:setName(self.copyCard[i])
		self.table_pans[i]:addChild(sp)
	
		local hh =height[i]*153+153
		for key,value in pairs(self.table_pans[i]:getChildren()) do 
			if key < 3 then  --前面2个动画结束，要清除掉
				--local movUp = cc.MoveBy:create(0.2,cc.p(0,25)) --开始回弹
				local mov = cc.MoveBy:create(hh/1500,cc.p(0,-hh-0))--时间=s/v 100为回弹的距离
				local movUp2 = cc.MoveBy:create(0.1,cc.p(0,5))--结束回弹
				local movDown2 = cc.MoveBy:create(0.1,cc.p(0,-5))--结束回弹
				local seq = cc.Sequence:create(mov,cc.CallFunc:create(callback),movUp2,movDown2,nil)
				value:runAction(seq)
				 
			else --最后一个执行滚动完成回调
				--local movUp = cc.MoveBy:create(0.2,cc.p(0,25))
				local mov = cc.MoveBy:create(hh/1500,cc.p(0,-hh-0))--时间=s/v 100为回弹的距离
				local movUp2 = cc.MoveBy:create(0.1,cc.p(0,5))--结束回弹
				local movDown2 = cc.MoveBy:create(0.1,cc.p(0,-5))--结束回弹
				local seq = cc.Sequence:create(mov,cc.CallFunc:create(rollOver),movUp2,movDown2,nil)
				value:runAction(seq)
				
			end
		end
	end
end
function GameViewLayer:OffLineRoll()
	self.GameRollFunNum = self.GameRollFunNum + 1
	for i = 1, 5 do
		self.HongFaCaiArmature[i]:stopAllActions()
		self.HongFaCaiArmature[i]:setVisible(false)
	end
	if not(self.GameRollFunNum == 1) then
		for indexKey, pan_1 in pairs(self.table_pans) do
			for key, value in pairs(pan_1:getChildren()) do
				if 1 == #pan_1:getChildren() then -- 只留最后一个
					value:stopAllActions()
					break
				else
					value:removeFromParent()
				end
			end
		end
	end

	if b_sendMsgCallback then
		self.Music_Scatter = 0
		self.IsWhole = 0
		self:startRoll(self.serverIcos,self.serverWin)
		return
	else
		if self.GameRollFunNum > 15 then
			--self:setNotLineBack(true)
		end
	end

	local height={}
	height = {1, 4 - 0.3, 7 - 0.6, 10 - 0.9, 13 - 1.2, 2 - 0.1, 5 - 0.4, 8 - 0.7, 11 - 1, 14 - 1.3, 3 - 0.2, 6 - 0.5, 9 - 0.8, 12 - 1.1, 15 - 1.4}
	for i = 1, 15 do 
		height[i] = height[i] + 2
	end

	for indexKey, pan_1 in pairs(self.table_pans) do
		local roll = self:createRoll(height[indexKey])
		roll:setAnchorPoint(0,0)
		roll:setPosition(0,153)
		--roll:setPosition(30, 0)
		pan_1:addChild(roll)
		local height =2 * 153 * 1--胶带长度+窗口长度
		for key,value in pairs(pan_1:getChildren()) do
			local mov = cc.MoveBy:create(height/1530,cc.p(0,-height))--时间=s/v
			local seq = cc.Sequence:create(mov)
			local seq2 = cc.Sequence:create(mov,cc.CallFunc:create(function()
				self:OffLineRoll()
				end))

			value:stopAllActions()
			if key ==#pan_1:getChildren() then

				value:runAction(seq2)
			else
				value:runAction(seq)
			end
		end
	end

end
--显示中奖线
function GameViewLayer:showLines(num) 
	if num > 0  then
		--GameViewLayer:cleanWin()
	end
	for i = 1 , 9 do 
		if i <= num then
			self.table_lines[i]:setOpacity(255)
			self.table_lines[i]:setVisible(true)
		else
			self.table_lines[i]:setVisible(false)
		end
	end
	--自动隐藏线
	if num > 0  then 
		if hideLineEntry then --取消以前的重新启动定时
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(hideLineEntry)
			hideLineEntry =nil 
		end 
		hideLineEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
				if  hideLineEntry   then --取消以前的重新启动定时
					cc.Director:getInstance():getScheduler():unscheduleScriptEntry(hideLineEntry)
					hideLineEntry =nil 
				end  
				
				for i = 1 , 9 do 
					self.table_lines[i]:setVisible(false)
				end 
			end , 2, false) 
	end 
end
function GameViewLayer:startGameByNet(flag) 
	--余额判断 用户余额少于用户花费 则提示
	if  self.sp_tipwin:isVisible() then
		self.sp_tipwin:setVisible(true)
	end
	self:GameBetIndex()
	if GlobalUserItem.lUserScore < self.lines * self.bet[self.betIndex] then
		print("#123###################123")
		local tipLayer = cc.CSLoader:createNode("credit/NotEnoughCreditLayer.csb")
		local btn_continue = tipLayer:getChildByName("btn")
		btn_continue:addTouchEventListener(
		function(sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				tipLayer:stopAllActions()
				tipLayer:removeFromParent(true)
			end 
		end)
		self:addChild(tipLayer)	
		self.autoCount = 0--关闭自动旋转定时器 
		return 
	end
	
 	AudioEngine.stopAllEffects()
	self:cleanWin()
  	if self.autoCount >= 1 then

  	end
  		if self.MusicTemp then
			AudioEngine.playEffect("mp3/Spin.mp3")
		end
		self:showLines(0) --隐藏中奖线	 
		--参数1 线数，线花费，总花费
		b_sendMsgCallback  = false
		self.JackpotTextNum = 0
		self.GameRollFunNum = 0
		for i = 1, 5 do
			self.HongFaCaiArmature[i]:stopAllActions()
			self.HongFaCaiArmature[i]:setVisible(false)
		end
		local score = self.lines * self.bet[self.betIndex]
		self:onAnalogPay(score)
		self._scene:startGame(self.lines,self.lines*self.bet[self.betIndex],self.bet[self.betIndex]) --开始游戏，发送给服务端
		self:OffLineRoll()
		if self.autoCount > 0 then
			self.btn_autostop:setEnabled(false)
			self.btn_autostop:setBright(false)
			self.btn_spin:setEnabled(false)
			self.btn_spin:setBright(false)
		end
		self.RUNING = true
		self.autoFlag = flag
end

function GameViewLayer:GameBtnSpin()
 	if self.GameRollCode == 0 then
		for i=1,#self.Panel_Calick do
			self.Panel_Calick[i]:setTouchEnabled(false)
		end
		self.RollBool = true
		self:startGameByNet(false) 
	else
		for i=1,#self.Panel_Gray do
			if self.Panel_Gray[i]:isTouchEnabled() then
				self.Panel_Gray[i]:setTouchEnabled(false)
				local tag = i
				for i=1,3 do
					self.GameRollCode = self.GameRollCode + 1
					self.Panel_CalickCode = tag
					tag = tag + 5
					self:startGameRoll(true)
				end
			end
		end
		if self.MusicTemp then
			AudioEngine.playEffect("mp3/Spin.mp3")
		end 
	end
 end 
function GameViewLayer:spinClick(sender, eventType)
print("点击")
	
	if eventType == ccui.TouchEventType.began then
		self:cleanWin()
		self.longPress =false
	elseif eventType == ccui.TouchEventType.ended then
		if self.BigWinOK== true then
			self:cleanBigwin()
			release_print("----执行停止cleanBigwin")
		end

		if self.autoCount <=0 then
			self:setBtnVisible(true,false,true,false,true,true)
			self:setBtnEnble(false,false,false,false,false,false)
			self:setBtnBright(false,false,false,false,false,false)
		else
			self:setBtnVisible(true,false,false,true,true,true)
			self:setBtnEnble(false,false,false,false,false,false)
			self:setBtnBright(false,false,false,false,false,false)
		end

		self:cleanWin()
		for i=1,9 do
			self.LightLineNum[i]:stopAllActions()
			self.RightLineNum[i]:stopAllActions()
			self.LightLineNum[i]:setOpacity(0)
			self.RightLineNum[i]:setOpacity(0)
			self.LightLineNum[i]:setVisible(false)
			self.RightLineNum[i]:setVisible(false)
		end
		self:GameBtnSpin()
		for i=1,5 do
			self.HongFaCaiArmature[i]:setVisible(false)	
		end
	end 
 
end
--初始动画
function GameViewLayer:initAnima()
	local animationgofree3222 =cc.Animation:create() --进入动画
	for i = 1 ,12 do
		local str = string.format("Anim/8/"..i..".png")
		animationgofree3222:addSpriteFrameWithFile(str)
	end
	animationgofree3222:setLoops(1)
	animationgofree3222:setDelayPerUnit(0.05)
	cc.AnimationCache:getInstance():addAnimation(animationgofree3222,"gofree")
	local animationgofree =cc.Animation:create() --进入动画
	for i = 1 ,6 do
		local str = string.format("Frame_"..i..".png")
		animationgofree:addSpriteFrameWithFile(str)
	end

	animationgofree:setLoops(1000000)
	animationgofree:setDelayPerUnit(0.15)
	cc.AnimationCache:getInstance():addAnimation(animationgofree,"Frame")

	 self.Animationgofree[1] =cc.Animation:create() --进入动画
	for i = 1 ,17 do
		local str = string.format("Anim/0/"..i..".png")
		self.Animationgofree[1]:addSpriteFrameWithFile(str)
	end
	self.Animationgofree[1]:setLoops(3)
	self.Animationgofree[1]:setDelayPerUnit(0.15)
	cc.AnimationCache:getInstance():addAnimation(self.Animationgofree[1],"Anim0")

	self.Animationgofree[2] =cc.Animation:create() --进入动画
	for i = 1 ,17 do
		local str = string.format("Anim/1/"..i..".png")
		self.Animationgofree[2]:addSpriteFrameWithFile(str)
	end
	self.Animationgofree[2]:setLoops(3)
	self.Animationgofree[2]:setDelayPerUnit(0.15)
	cc.AnimationCache:getInstance():addAnimation(self.Animationgofree[2],"Anim1")

	self.Animationgofree[3] =cc.Animation:create() --进入动画
	for i = 1 ,17 do
		local str = string.format("Anim/2/"..i..".png")
		self.Animationgofree[3]:addSpriteFrameWithFile(str)
	end
	self.Animationgofree[3]:setLoops(3)
	self.Animationgofree[3]:setDelayPerUnit(0.15)
	cc.AnimationCache:getInstance():addAnimation(self.Animationgofree[3],"Anim2")

	self.Animationgofree[4] =cc.Animation:create() --进入动画
	for i = 1 ,17 do
		local str = string.format("Anim/3/"..i..".png")
		self.Animationgofree[4]:addSpriteFrameWithFile(str)
	end
	self.Animationgofree[4]:setLoops(3)
	self.Animationgofree[4]:setDelayPerUnit(0.15)
	cc.AnimationCache:getInstance():addAnimation(self.Animationgofree[4],"Anim3")

	self.Animationgofree[5] =cc.Animation:create() --进入动画
	for i = 1 ,17 do
		local str = string.format("Anim/4/"..i..".png")
		self.Animationgofree[5]:addSpriteFrameWithFile(str)
	end
	self.Animationgofree[5]:setLoops(3)
	self.Animationgofree[5]:setDelayPerUnit(0.15)
	cc.AnimationCache:getInstance():addAnimation(self.Animationgofree[5],"Anim4")

	self.Animationgofree[6] =cc.Animation:create() --进入动画
	for i = 1 ,17 do
		local str = string.format("Anim/5/"..i..".png")
		self.Animationgofree[6]:addSpriteFrameWithFile(str)
	end
	self.Animationgofree[6]:setLoops(3)
	self.Animationgofree[6]:setDelayPerUnit(0.15)
	cc.AnimationCache:getInstance():addAnimation(self.Animationgofree[6],"Anim5")

	self.Animationgofree[7] =cc.Animation:create() --进入动画
	for i = 1 ,17 do
		local str = string.format("Anim/6/"..i..".png")
		self.Animationgofree[7]:addSpriteFrameWithFile(str)
	end
	self.Animationgofree[7]:setLoops(3)
	self.Animationgofree[7]:setDelayPerUnit(0.15)
	cc.AnimationCache:getInstance():addAnimation(self.Animationgofree[7],"Anim6")

	self.Animationgofree[8] =cc.Animation:create() --进入动画
	for i = 1 ,17 do
		local str = string.format("Anim/7/"..i..".png")
		self.Animationgofree[8]:addSpriteFrameWithFile(str)
	end
	self.Animationgofree[8]:setLoops(3)
	self.Animationgofree[8]:setDelayPerUnit(0.15)
	cc.AnimationCache:getInstance():addAnimation(self.Animationgofree[8],"Anim7")

	self.Animationgofree[9] =cc.Animation:create() --进入动画
	for i = 1 ,16 do
		local str = string.format("Anim/8/FreeWin"..i..".png")
		self.Animationgofree[9]:addSpriteFrameWithFile(str)
	end
	self.Animationgofree[9]:setLoops(3)
	self.Animationgofree[9]:setDelayPerUnit(0.15)
	cc.AnimationCache:getInstance():addAnimation(self.Animationgofree[9],"Anim8")

	self.Animationgofree[10] =cc.Animation:create() --进入动画
	for i = 1 ,17 do
		local str = string.format("Anim/9/"..i..".png")
		self.Animationgofree[10]:addSpriteFrameWithFile(str)
	end
	self.Animationgofree[10]:setLoops(3)
	self.Animationgofree[10]:setDelayPerUnit(0.15)
	cc.AnimationCache:getInstance():addAnimation(self.Animationgofree[10],"Anim9")

	self.Animationgofree[11] =cc.Animation:create() --进入动画
	for i = 1 ,17 do
		local str = string.format("Anim/10/Win"..i..".png")
		self.Animationgofree[11]:addSpriteFrameWithFile(str)
	end
	self.Animationgofree[11]:setLoops(3)
	self.Animationgofree[11]:setDelayPerUnit(0.15)
	cc.AnimationCache:getInstance():addAnimation(self.Animationgofree[11],"Anim10")

	self.Animationgofree[12] =cc.Animation:create() --进入动画
	for i = 1 ,41 do
		local str = string.format("Anim/SCATTER/"..i..".png")
		self.Animationgofree[12]:addSpriteFrameWithFile(str)
	end
	self.Animationgofree[12]:setLoops(1)
	self.Animationgofree[12]:setDelayPerUnit(0.1)
	cc.AnimationCache:getInstance():addAnimation(self.Animationgofree[12],"AnimSCATTER")

	local animationgofree13 =cc.Animation:create() --进入动画
	for i = 1 ,35 do
		local str = string.format("Anim/HongFaCai/"..i..".png")
		animationgofree13:addSpriteFrameWithFile(str)
	end
	animationgofree13:setLoops(1)
	animationgofree13:setDelayPerUnit(0.1)
	cc.AnimationCache:getInstance():addAnimation(animationgofree13,"HongFaCai")

	local animationgofree14 =cc.Animation:create() --进入动画
	for i = 1 ,21 do
		local str = string.format("Anim/Top/"..i..".png")
		animationgofree14:addSpriteFrameWithFile(str)
	end
	animationgofree14:setLoops(2)
	animationgofree14:setDelayPerUnit(0.15)
	cc.AnimationCache:getInstance():addAnimation(animationgofree14,"CaiShenDao")

	local animationgofree15 =cc.Animation:create() --进入动画
	for i = 1 ,25 do
		local str = string.format("Anim/TopScatter/"..i..".png")
		animationgofree15:addSpriteFrameWithFile(str)
	end
	animationgofree15:setLoops(1)
	animationgofree15:setDelayPerUnit(0.15)
	cc.AnimationCache:getInstance():addAnimation(animationgofree15,"AnimaFreeGame")

	local animationgofree16 =cc.Animation:create() --进入动画
	for i = 1 ,29 do
		local str = string.format("Anim/FreeGameA/"..i..".png")
		animationgofree16:addSpriteFrameWithFile(str)
	end
	animationgofree16:setLoops(1)
	animationgofree16:setDelayPerUnit(0.05)
	cc.AnimationCache:getInstance():addAnimation(animationgofree16,"FreeGameA")

	for i=1,15 do
		self.FreeGameFaCai[i]= cc.Sprite:create("card/10.png")
		self.FreeGameFaCai[i]:setLocalZOrder(0)
		self.FreeGameFaCai[i]:setScaleX(1.25)
		self.FreeGameFaCai[i]:setScaleY(0.94)
		self.FreeGameFaCai[i]:setVisible(false)
		self:addChild(self.FreeGameFaCai[i])
	end
	local point = {cc.p(213.27,513), cc.p(425.27,513), cc.p(639.27,513), cc.p(853.27,513), cc.p(1067.27,513),
				   cc.p(212.27,362.13), cc.p(425.27,362.13), cc.p(639.27,362.13), cc.p(853.27,362.13), cc.p(1067.27,362.13),
				   cc.p(213,210.75), cc.p(425,210.75), cc.p(639,210.75), cc.p(853,210.75), cc.p(1067,210.75)}
	for i = 1, 15 do 
		self.FreeGameFaCai[i]:setPosition(point[i])
	end
	-- self.FreeGameFaCai[1]:setPosition(213.27,513)
	-- self.FreeGameFaCai[2]:setPosition(425.27,513)
	-- self.FreeGameFaCai[3]:setPosition(639.27,513)
	-- self.FreeGameFaCai[4]:setPosition(853.27,513)
	-- self.FreeGameFaCai[5]:setPosition(1067.27,513)

	-- self.FreeGameFaCai[6]:setPosition(212.27,362.13)
	-- self.FreeGameFaCai[7]:setPosition(425.27,362.13)
	-- self.FreeGameFaCai[8]:setPosition(639.27,362.13)
	-- self.FreeGameFaCai[9]:setPosition(853.27,362.13)
	-- self.FreeGameFaCai[10]:setPosition(1067.27,362.13)

	-- self.FreeGameFaCai[11]:setPosition(213,210.75)
	-- self.FreeGameFaCai[12]:setPosition(425,210.75)
	-- self.FreeGameFaCai[13]:setPosition(639,210.75)
	-- self.FreeGameFaCai[14]:setPosition(853,210.75)
	-- self.FreeGameFaCai[15]:setPosition(1067,210.75)

	local animationgofree =cc.Animation:create() --进入发牌动画
	for i = 1 ,16 do
		local str = string.format("Anim/10/"..i..".png")
		animationgofree:addSpriteFrameWithFile(str)
	end
	animationgofree:setLoops(1)
	animationgofree:setDelayPerUnit(0.1)
	cc.AnimationCache:getInstance():addAnimation(animationgofree,"gofree1")
		for i=1,5 do
			FreeGameGoldBat[i]=cc.Sprite:create("Anim/FreeGameA/1.png")
			FreeGameGoldBat[i]:setLocalZOrder(0)
			self:addChild(FreeGameGoldBat[i])
			if i==1 then
				FreeGameGoldBat[i]:setPosition(210,350)
			elseif i==2 then
				FreeGameGoldBat[i]:setPosition(425,350)
			elseif i==3 then
				FreeGameGoldBat[i]:setPosition(635,350)
			elseif i==4 then
				FreeGameGoldBat[i]:setPosition(850,350)
			elseif i==5 then
				FreeGameGoldBat[i]:setPosition(1065,350)
			end
			FreeGameGoldBat[i]:setVisible(false)	
		end

	for i = 1, 5 do
		self.gofreeAnima[i]=cc.Sprite:create("Anim/HongFaCai/1.png")
		self.gofreeAnima[i]:setScale(0, 0)
	end
	-- self.gofreeAnima[1]=cc.Sprite:create("Anim/HongFaCai/1.png")
	-- self.gofreeAnima[1]:setScale(0, 0)
	-- self.gofreeAnima[2]=cc.Sprite:create("Anim/HongFaCai/1.png")
	-- self.gofreeAnima[2]:setScale(0, 0)
	-- self.gofreeAnima[3]=cc.Sprite:create("Anim/HongFaCai/1.png")
	-- self.gofreeAnima[3]:setScale(0, 0)
	-- self.gofreeAnima[4]=cc.Sprite:create("Anim/HongFaCai/1.png")
	-- self.gofreeAnima[4]:setScale(0, 0)
	-- self.gofreeAnima[5]=cc.Sprite:create("Anim/HongFaCai/1.png")
	-- self.gofreeAnima[5]:setScale(0, 0)
end
--初始卡牌
function GameViewLayer:IsCreateInitCard()
	if self.SurplusRotation > 0 then
		self.tipLayer = cc.CSLoader:createNode("credit/Reconnect.csb")
		self:addChild(self.tipLayer)
		local btn_continue = self.tipLayer:getChildByName("btn")
		btn_continue:addTouchEventListener(foBtnClick)

		self.btn_spin:loadTextures("GameButton/FreeSpin_1.png","GameButton/FreeSpin_2.png","GameButton/FreeSpin_3.png")
		self:setBtnVisible(false,true,false,true,true,true)
		self:setBtnEnble(false,true,false,false,false,false)
		self:setBtnBright(false,true,false,false,false,false)
		self.tipLayer:setVisible(true)
		self.tipLayer:runAction(cc.RepeatForever:create(
	    	cc.Sequence:create(cc.DelayTime:create(0.1),
	    		cc.CallFunc:create(function(sender)
	    			if self.Panel_Gray ~= nil then
	    				for i=1,#self.Panel_Gray do
							self.Panel_Gray[i]:setTouchEnabled(false)
						end
						sender:stopAllActions()
	    			end
				end),
	    	nil)
	    ))
		
		for i = 1, 15 do
			release_print("---===========================->>>"..app.Icon[i])
			local sp = cc.Sprite:create("card/"..app.Icon[i]..".png") 
			sp:setAnchorPoint(0,0)
			-- sp:setScaleX(1.25)
			-- sp:setScaleY(0.94)
			sp:setPosition(0,0)
			self.table_pans[i]:addChild(sp)
		end
		self.text_bet:setString(self.LienBet)  
		self.text_totalbet:setString(self.LienBet * 9)
		self.text_win:setString(self.WinGold)
		--self.BalanceText = self.BalanceText - self.WinGold
		--self.text_Score:setString(self.BalanceText)
		for i = 1, 15 do 
			local card = cc.Sprite:create("card/"..self.icon[i]..".png")
			self.table_pans[i]:getChildren()[1]:setTexture(card:getTexture())
		end
		local dt = cc.DelayTime:create(1.5)
	    local seq = cc.Sequence:create(dt,cc.CallFunc:create(function()
	    	if self.MusicTemp then
	        	AudioEngine.playMusic("mp3/FreeGameBG.mp3",true)
	        end
	    end),nil)
	    self:runAction(seq)
		--self._setLayer:setBtnEnable(false)
		release_print("-------2222----!!!!!!!--------") 
	else
		--self.tipLayer:setVisible(false)
		self:initCard()
		--self.BalanceText = self.BalanceText - self.WinGold
		--self.text_Score:setString(self.BalanceText)
		-- local dt = cc.DelayTime:create(1.5)
	 --    local seq = cc.Sequence:create(dt,cc.CallFunc:create(function()
	 --        if self.MusicTemp then
	 --        	AudioEngine.playMusic("mp3/BG.mp3",true)
	 --        end
	 --    end),nil)
	 --    self:runAction(seq)
		release_print("---------1111--@@@@@@@--------")	
	end

end
--初始化卡牌
function GameViewLayer:initCard()
	for i = 1, 15 do
		local sp = cc.Sprite:create("card/10.png") 
		sp:setAnchorPoint(0,0)
		sp:setPosition(0,0)
		self.table_pans[i]:addChild(sp)
	end 
end 

--更新文本
function GameViewLayer:updateText()
	--GameViewLayer.text_lines:setString(GameViewLayer.lines)
	self.text_bet:setString( self.bet[self.betIndex] )  
	self.text_totalbet:setString( self.lines * self.bet[self.betIndex])
end

function GameViewLayer:randomSprite(i,j,k,l)

		if l == 1 then
			local index = {i, j, k}
			local random = math.random(2, 3)
			local randomSprite1 = math.random(0, 7)
			self.copyCard[index[random]] = randomSprite1
			--return index[random],randomSprite1
		elseif l == 2 then
			local index = {i, j, k}
			local random = math.random(2,3)
			local random1 = math.random(2,3)
			local randomSprite1 = math.random(0,7)
			local randomSprite2 = math.random(0,7)
			if random ~= random1  then
				self.copyCard[index[random]] = randomSprite1
				self.copyCard[index[random1]] = randomSprite2
				--return index[random],index[random1],randomSprite1,randomSprite2
			else
				self.copyCard[index[random]] = randomSprite1
				self.copyCard[index[random1]] = randomSprite2
			end
		end
	

end

function GameViewLayer:startRoll2(icos,win)
	print("----------------图标显示--------------")
	for i = 1, 3 do
		local strIcons = ""
		for j = 1, 5 do
			strIcons = strIcons .. "  " .. icos[(i - 1) * 5 + j]
		end
		print(i .. "   ".. strIcons)
	end
	print("----------- 输赢："..win)
		b_sendMsgCallback = true 

		self.Linepoint = 0
		self.Handsel = 0	

		if self.AniFiveLine ~= nil then
			self:stopAllActions()
			self.AniFiveLine:removeFromParent(true)
			self.AniFiveLine = nil
		end
		for i = 1, 9 do
			self.LightLineNum[i]:stopAllActions()
			self.RightLineNum[i]:stopAllActions()
			self.LightLineNum[i]:setOpacity(0)
			self.RightLineNum[i]:setOpacity(0)
			self.LightLineNum[i]:setVisible(false)
			self.RightLineNum[i]:setVisible(false)
		end
		FaiCaiAndveryGood = false

		for indexKey,sprite_star in pairs(self.table_winStars) do 
			sprite_star:stopAllActions()
			sprite_star:setVisible(false)
		end
		self.serverIcos = icos
		self.serverWin = win
		local x = {0, 0, 0, 0, 0}
		self.Redrich = x
		self.RedrichCount = 0
		self.FreeBalance = false
		self.LoseFreeGame = false
		self.LoseFaCai = false
		
		if self.FreeRotation == 0 then
			for i = 1, 15 do
				self.copyCard[i] = icos[i]
				if i == 15 then
					if self.copyCard[1] == 10 and self.copyCard[6] == 10 and self.copyCard[11] == 10 then
						self.Redrich[1] = 1
					else
						self.Redrich[1] = 0
					end

					if self.copyCard[2] == 10 and self.copyCard[7] == 10 and self.copyCard[12] == 10 then
						self.Redrich[2] = 1
					else
						self.Redrich[2] = 0
					end

					if self.copyCard[3] == 10 and self.copyCard[8] == 10 and self.copyCard[13] == 10 then
						self.Redrich[3] = 1
					else
						self.Redrich[3] = 0
					end

					if self.copyCard[4] == 10 and self.copyCard[9] == 10 and self.copyCard[14] == 10 then
						self.Redrich[4] = 1
					else
						self.Redrich[4] = 0
					end

					if self.copyCard[5] == 10 and self.copyCard[10] == 10 and self.copyCard[15] == 10 then
						self.Redrich[5] = 1
					else
						self.Redrich[5] = 0
					end

					if self.copyCard[8] == 13 then
					   self.copyCard[8] = 8
					   self.Handsel = 1
					   self.serverWin = 666
					elseif self.copyCard[8] == 14 then 
					   self.copyCard[8] = 8
					   self.Handsel=2
					   self.serverWin = 888
					elseif self.copyCard[8] == 15 then 
					   self.copyCard[8] = 8
					   self.Handsel = 3
					   self.serverWin = 1088
					end
				end
			end
			if self.Redrich[1] == 1 and (self.Redrich[2] == 1 or self.Redrich[3] == 1 or self.Redrich[4] == 1 or self.Redrich[5] == 1) then
				local b = math.random(1,2)
				self:randomSprite(1, 6, 11, b)
			end

			if self.Redrich[2] == 1 and (self.Redrich[1] == 1 or self.Redrich[3] == 1 or self.Redrich[4] == 1 or self.Redrich[5] == 1) then
				local b = math.random(1,2)
				self:randomSprite(2, 7, 12, b)
			end

			if self.Redrich[3] == 1 and (self.Redrich[2] == 1 or self.Redrich[1] == 1 or self.Redrich[4] == 1 or self.Redrich[5] == 1) then
				local b = math.random(1,2)
				self:randomSprite(3, 8, 13, b)
			end

			if self.Redrich[4] == 1 and (self.Redrich[2] == 1 or self.Redrich[3] == 1 or self.Redrich[1] == 1 or self.Redrich[5] == 1) then
				local b = math.random(1,2)
				self:randomSprite(4, 9, 14, b)
			end

			if self.Redrich[5] == 1 and (self.Redrich[1]== 1 or self.Redrich[2]== 1 or self.Redrich[3] == 1 or self.Redrich[4] == 1) then
				local b = math.random(1,2)
				self:randomSprite(5, 10, 15, b)
			end
		end		

		if self.FreeRotation == 1 then
			self.btn_spin:setVisible(false)
			self.btn_stop:setVisible(true)
			self.btn_stop:setEnabled(true)
			self.btn_stop:setBright(true)
			for i = 1, 15 do
				self.FreeGameFaCai[i]:setOpacity(0)
			    self.FreeGameFaCai[i]:setVisible(false)
			end
			self.autoCount = self.autoCount - 1 
			self.FreeRotationNum = self.FreeRotationNum + 1
			FreeGameNumber:setString(self.FreeRotationNum)
			if self.FreeFaCai == true then
				self.FreeFaCai = false
			end
		else
			self.autoCount = self.autoCount - 1 
		end
		
end
--模拟扣分
function GameViewLayer:onAnalogPay(score)
	self.BalanceText = self.BalanceText - score
	self:FormatScore(self.text_Score,self.BalanceText)
	--self.text_Score:setString(self.BalanceText)
end
function GameViewLayer:FormatScore(node,score)
	local str = ExternalFun.numberThousands(score)
	--str = string.gsub(str,",",":")
	node:setString(str)
	local txtwith = node:getContentSize().width
	local txtlen = string.len(str)
	if txtlen >= 11 then
		node:setScale(145 / txtwith)
	end
end
--刷新分数
function GameViewLayer:resetSelfInfo()
	--校验分数
	--self.BalanceText = GlobalUserItem.lUserScore
	self.text_Score:setString(self.BalanceText)
end
--用户分数
function GameViewLayer:onGetUserScore( useritem )
    --自己
    if useritem.dwUserID == GlobalUserItem.dwUserID then
        self.BalanceText = useritem.lScore
        --self:resetSelfInfo()
    end
end
--重连
function GameViewLayer:Reconnection(SurplusRotation,SurplusRotationCount,LienBet,WinGold,icon)
	print("---SurplusRotation---"..SurplusRotation)
	print("---SurplusRotationCount---"..SurplusRotationCount)
	print("---WinGold---"..WinGold)
	self.SurplusRotation = SurplusRotation;
	self.SurplusRotationCount = SurplusRotationCount;
	self.LienBet = LienBet;
	self.WinGold = WinGold;
	self.icon = icon;
	print("------self.LienBet-------"..self.LienBet)

	for i,bet in pairs(self.bet) do
		if bet == self.LienBet then
			self.betIndex = i
		end
	end
	--release_print("------self.LienBet--11111111111111-----"..table.getn(self.bet))
	--self.bet ={1,2,3,4,5,6,7,8,9,10,20,30,40,50} --花费,必须>=1
	self.WinGoldCount = WinGold;

end

function GameViewLayer:onExit()
	self:stopAllActions()
	--停止音频
	AudioEngine.stopAllEffects()
	AudioEngine.stopMusic()
	--播放大厅背景音乐
    ExternalFun.playPlazzBackgroudAudio()
	if(autoSchedulerEntry) then 
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(autoSchedulerEntry)
		autoSchedulerEntry = nil 		
	end
	if(AutoNumSchedulerEntry) then 
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(AutoNumSchedulerEntry)
		AutoNumSchedulerEntry = nil 
	end
	if(self.schedulerIDWin3) then 
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerIDWin3)
		self.schedulerIDWin3 = nil 
	end
	AudioEngine.unloadEffect("mp3/Button.mp3")
	AudioEngine.unloadEffect("mp3/Reuslt.mp3")
	AudioEngine.unloadEffect("mp3/Rolling.mp3")
	AudioEngine.unloadEffect("mp3/Spin.mp3")
	AudioEngine.unloadEffect("mp3/Stop.mp3")
	AudioEngine.unloadEffect("mp3/TwoFa.mp3")
	AudioEngine.unloadEffect("mp3/FreeGameA.mp3")
	AudioEngine.unloadEffect("mp3/FreeGame_OK.mp3")
	AudioEngine.unloadEffect("mp3/FreeGame_OK_1.mp3")
	AudioEngine.unloadEffect("mp3/FreeGame_OK_2.mp3")
	for i = 1, 9 do
		AudioEngine.unloadEffect("mp3/Line_"..i..".mp3")
	end
	for j = 1, 5 do
		AudioEngine.unloadEffect("mp3/scatter_"..j..".mp3")
	end
	cc.Director:getInstance():getTextureCache():removeTextureForKey("roll.png")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("roll1.png")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("roll2.png")
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()

    --重置搜索路径
	local oldPaths = cc.FileUtils:getInstance():getSearchPaths();
	local newPaths = {};
	for k,v in pairs(oldPaths) do
		if tostring(v) ~= tostring(self._searchPath) then
			table.insert(newPaths, v);
		end
	end
	cc.FileUtils:getInstance():setSearchPaths(newPaths);
	
	self._laba:closeTime()
    print("退出")
end

--更新用户信息
function GameViewLayer:onUpdateUserInfo()
	
	--设置玩家头像
	local avatar = self._csbNode:getChildByName("sp_avatar")
	if nil ~= avatar then
		avatar:updateHead(GlobalUserItem)
	else
		local avatarFrame = self._csbNode:getChildByName("sp_head")
		HeadSprite:createClipHead(GlobalUserItem, 64, "sp_avatar_mask_64.png")
			  :setPosition(avatarFrame:getPosition())
			  :setName("sp_avatar")
			  :addTo(self._csbNode)
	end

	local txtNickName = self._csbNode:getChildByName("text_nickname")
	--昵称判断不大于14个字符长度
	local signstrtable = ExternalFun.utf8StringSplit(GlobalUserItem.szNickName)
    local signstr = ""
    local signlen = 1
    for i = 1, #signstrtable do
        if signlen > 10 then
            break
        end
        local str = signstrtable[i]
        local dropping = string.byte(str)
        if dropping >= 128 then
            signlen = signlen + 2
        else
            signlen = signlen + 1
        end
        signstr = signstr..str
    end
    print(signlen)
    if signlen > 10 then
        signstr = signstr.."..."
    end
	txtNickName:setString(signstr)
end

--按钮点击事件
function GameViewLayer:onButtonClickedEvent(tag,ref)
	if tag == 10001 then
		self._scene:onQueryExitGame()
	elseif tag == 10002 then
		print("BT_SWITCH")
		self:onButtonSwitchAnimate()
	elseif tag == 10003 then
		--if(not self.b_showHelp) then  --防重复显示
		print("HELPPPPPPPPPPPPP")
			self.b_showHelp = true
			HelpLayer:create(self)
				 	 :addTo(self,101)
		--end
	else
		showToast(self,"功能尚未开放！",1)
	end
end
function GameViewLayer:onButtonSwitchAnimate()
	local time = 0.2
	local helpshow = self.btPanel:isVisible()
	local scaleLv = helpshow and 0 or 1
	self.btPanel:setVisible(true)

	--简单的缩放功能
	self.btPanel:runAction(cc.Sequence:create(
						   cc.ScaleTo:create(time,scaleLv),
						   cc.CallFunc:create(function()
						   		self.bBtnInOutside = not helpshow
						   		--self.btExit:setTouchEnabled(self.bBtnInOutside)
						   		--self.btHelp:setTouchEnabled(self.bBtnInOutside)
						   		self.btPanel:setVisible(not helpshow)
						   		--self._menuLayout:setVisible(not helpshow)
						   end)))
end
--操作按钮
function GameViewLayer:initButton()

	self.bBtnInOutside = false
	self._menuLayout = nil
	local  btcallback = function(ref, type)
        if type == ccui.TouchEventType.ended then
         	self:onButtonClickedEvent(ref:getTag(),ref)
        end
    end

	self.btSwitch = ccui.Button:create("GameMenu/bt_switch_0.png", "GameMenu/bt_switch_1.png", "")
		:move(cc.p(65,700))
		:setTag(10002)
		:addTo(self,20)
	self.btSwitch:addTouchEventListener(btcallback)

	self.btPanel = cc.Sprite:create("GameMenu/sp_menubg.png")
		:move(cc.p(30,665))
		:setAnchorPoint(cc.p(0,1))
		:setVisible(false)
		:setScale(0)
		:addTo(self,21)

	self.btExit = ccui.Button:create("GameMenu/bt_takeBack_0.png", "GameMenu/bt_takeBack_1.png", "")
		:move(cc.p(91,104))
		:setTag(10001)
		--:setTouchEnabled(false)
		:addTo(self.btPanel)
	self.btExit:addTouchEventListener(btcallback)

	self.btHelp = ccui.Button:create("GameMenu/bt_help_0.png", "GameMenu/bt_help_1.png", "")
		:move(cc.p(91,41))
		:setTag(10003)
		:addTo(self.btPanel)
	self.btHelp:addTouchEventListener(btcallback)

	-- self._menuLayout = ccui.Layout:create()
	-- 	:setContentSize(cc.size(1334,750))
	-- 	:setPosition(cc.p(0,0))
	-- 	:setAnchorPoint(cc.p(0,0))
	-- 	:setTouchEnabled(true)
	-- 	:addTo(self,19)
	-- 	:addClickEventListener(function()
	-- 		self:onButtonSwitchAnimate()
	-- 		end)

end

return GameViewLayer