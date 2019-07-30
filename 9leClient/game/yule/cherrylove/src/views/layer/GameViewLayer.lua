--导入游戏逻辑文件

--创建GameViewLayer
local GameViewLayer = class("GameViewLayer",function(scene)
	local gameViewLayer =  display.newLayer()
return gameViewLayer
end)
--导入游戏逻辑文件
local module_pre = "game.yule.cherrylove.src"

local ExternalFun =  appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

local HeadSprite = appdf.req(appdf.EXTERNAL_SRC .. "HeadSprite")
local PlayScene = appdf.req(module_pre .. ".views.layer.PlayScene")
local g_var = ExternalFun.req_var
local cmd = module_pre .. ".models.CMD_Game"
local GameNotice = appdf.req(appdf.BASE_SRC .."app.views.layer.other.GameNotice")
local HelpLayer = appdf.req(module_pre..".views.layer.HelpScene")
local QueryDialog = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.QueryDialog")

GameViewLayer.RES_PATH = "game/yule/cherrylove/res/"

local nWinTime = 0.25
local MAXZORDER=999999
local MAXLINE =30
local DHIGHT=750
local DWIDHT=1334
local playMp3Index = 1;
local FreeMult = 2
local GI_WILD = 12

local SPINROLL =-1 
local AUTOROLL =1  --自动旋转autoFlag
local FREEROLL =2  --免费旋转autoFlag

function GameViewLayer:ctor(scene)
	--注册node事件
	ExternalFun.registerNodeEvent(self)

	self._scene = scene
	self:initdata()
	self:preloadUI()
	self:initUi()
end
function GameViewLayer:initdata()
	--指定创建的csb
	self.RESOURCE_FILENAME = "MainScene.csb"

	self.BonusText = 0
	self.PromptText = 0
	self.Major = 0
	self.Minor = 0
	self.BonusSchedulerEntry =nil ----彩金定时器
	self.autoSchedulerEntry =nil  --自动旋转定时器
	self.b_sendMsgCallback = true; --发送网络消息是否回调
	--变量 
	self.ROLLING=false; --是否在转
	self.RUNING=false; --正在滚动
	self.ready =false; --是否可以游戏，服务端返回才能开始游戏
	self.autoFlag=SPINROLL; --是不是自动旋转 用于显示不同stop按钮
	self.lines=MAXLINE;  --选择几条线
	self.betIndex=1;
	self.bet ={1000,5000,10000,20000,50000,100000} --单线押注

	self.rollCount=0  --滚动完成几条线 
	self.autoCount=0 -- 自动旋转剩余次数
	self.tab ={{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}}--结果集

	--中奖信息
	self.winNumb =nil --线金额
	self.winLines =nil --线
	self.winOdds  =nil--赔率
	self.winLinePoints=nil --线具体的点
	self.TotalBet = 0; --总押注
	self.linebet = 0; --单线押注
	self.gameWin =0; --游戏赢了

	--table
	self.table_pans ={} --滚动窗口1
	self.table_lines ={} --所有中奖线 
	self.table_BtnLines ={} --所有按钮
	self.table_winStars ={} --赢了后添加的框框
	self.goinFreeStepEntry=nil  --进入免费游戏定时器 

	--免费
	self.freeleft=-1  --免费旋转剩余 
	self.freeleft_OK = false; --已经在免费游戏中
	self.freeWinCount =0 --免费游戏赢了总额
	self.text_mult =nil --免费游戏翻倍数
	self.text_free_win=nil --免费赢取
	self.isFreeOver = false

	--文本
	self.text_bet = nil
	self.text_lines=nil
	self.text_totalbet=nil
	self.GameBalanceText = nil --玩家金币
	self.BalanceText = 0
	self.text_tipwin=nil --赢了后中间提示
	self.text_spins_left=nil
	--autospin 
	self.pan_normal=nil
	self.pan_free=nil
	self.YouWon=nil
	--按钮定义
	self.btn_autostop = nil --auto_stop按钮
	self.btn_autospin = nil --auto_spin按钮
	self.btn_stop = nil --stop按钮
	self.btn_spin = nil --spin按钮
	self.btn_lines_sub= nil
	self.btn_lines_add= nil
	self.btn_bet_sub= nil
	self.btn_bet_add= nil 
	self.btn_game=nil
	self.btn_freespin=nil
	self.btn_freestop=nil

	self.rollBgMp3Id = nil --滚动声音ID  
	self.playWinMusicEntry =nil --免费游戏播放声音定时器

	self.LineWins = {} --每条线中奖额
	self.GameLineCount = 0 --总共中了多少条线

	-------------------------------- 普通选择赋值
	self.VoiceWinGold = nil; --普通中奖结算音效
	self.VoiceFreeWinGold = nil; --免费结束中奖结算音效
	self.GameScatterWinOK = false; --Scatter有得分
	self.nScatter = 0;  --Scatter有多少
	self.ScatterMp3Id = nil --滚动声音ID
	self.tab_xing ={};  --两个Scatter后的火动画
	self.GameStopOK = false; --点击了stop
	self.rollCountTemp=0;  --滚动完成几条线
	self.GameRollFunNum = 0 --没有网络旋转
	self.serverWin=0 --服务端返回的 win 金额
	self.serverIcos={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0} --结果
	-------------------------------- 免费游戏赋值
	self.GameWinScatter = false; 
	self.FreeGame_OK = false;
	self.FreeGameAgain_OK = false;
	self.sp_logo =nil --游戏logo
	self.Prompt = {}; --logo
	self.mainbg_free = nil;
	-------------------------------- --BigWin赋值
	self.spBigWin = nil;
	self.GameBigWin = false;
	self.BigWinOK = false;
	---------------------------------

	----------------------------- 彩金赋值
	self.BonusRandomText = 0 --彩金转动触发
	self.Random_JackotText = 0;
	self.MajorText = 0;
	self.MinorText = 0;
	self.Random_Jackot = 0;
	self.Major = 0;
	self.Minor = 0;
	----------------------------- 中奖线提示赋值
	self.GameLine = nil;
	self.GameLine_Line = 0;
	self.GameWin = nil;
	self.GameWin_Win = 0;
	self.GameWin_Line = 0;
	self.GameTotal = nil;
	self.GameTotal_Win = 0;
	self.GameScatter = nil;
	self.GameScatter_Win = 0;
	----------------------------- 彩金动画赋值
	self.GameJackotTag = false;
	self.JackpotPanel = nil;
	self.JackpotMajor = nil;
	self.JackpotMinor = nil;
	self.JackpotRandom = nil;
	self.JackpotXing = nil;
	self.JackpotJinbi = nil;
	self.JackpotText = nil;
	self.JackpotTextNum = 0;
	self.JackpotTextID = 0;
	-------------------------------
	self.AniFiveLine = nil; --中五连线动画
	self.bFiveLine = false;
	------------------------------滚动条
	self.gameBroadCast = nil
	------------------------------动画
	self.CherryLoveOpen2 = nil
	self.CherryLoveOpen3 = nil
	self.CherryLoveOpen4 = nil
	self.CherryLoveStand2 = nil
	self.CherryLoveStand3 = nil
	self.CherryLoveStand4 = nil

	self.CherryLoveTwo = nil
	self.CherryLoveTwo_Move = nil
	self.CherryLoveThree = nil
	self.CherryLoveThree_Move = nil
	self.CherryLoveFour = nil
	self.CherryLoveFour_Move = nil
	self.bCherryLoveTwo_Move = false
	self.bCherryLoveThree_Move = false
	self.bCherryLoveFour_Move = false

	self.GameWildTwo = false
	self.GameWildThree = false
	self.GameWildFour = false
	self.WildOK = false
	------------------------------
	self.isFreeOK = false
	self.GameOldSocre = 0

	self.btn_maxBet =nil
end
function GameViewLayer:preloadUI()
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
	cc.Director:getInstance():getTextureCache():addImage("roll3_1.png")
	cc.Director:getInstance():getTextureCache():addImage("roll3_2.png")
	cc.Director:getInstance():getTextureCache():addImage("roll1245_1.png")
	cc.Director:getInstance():getTextureCache():addImage("roll1245_2.png")
	cc.Director:getInstance():getTextureCache():addImage("roll1245_3.png")
	cc.Director:getInstance():getTextureCache():addImage("roll1245_4.png")
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("Jackpot/5ofkind.ExportJson")
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("CherryLoveWild/CherryLoveWild.ExportJson")
end
function GameViewLayer:initUi()

	-- require("app.views.system"):initLayer(self)
	-- require("app.views.system"):SetVisible(self,false);

	--节点事件
	local function onNodeEvent(event)
		if event == "exit" then
			self:onExit()
		end
	end
	self:registerScriptHandler(onNodeEvent)
	
	self._csbNode = cc.CSLoader:createNode("MainScene.csb")
		:addTo(self, 1)

		
	local  btcallback = function(ref, type)
		if type == ccui.TouchEventType.ended then
			self:footBtnClick(ref,ref:getTag())
		end
	end
	--添加按钮监听
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if (cc.PLATFORM_OS_WINDOWS == targetPlatform)   then 
		local function onKeyPressed(key, event)
	        local target = event:getCurrentTarget()
	       	if key== 59 then 
	       		 if self.btn_stop:isVisible() or self.btn_freestop:isVisible() then 
	       		 	print("按键停止")
	       		 	if self.freeleft == -1 then
						btcallback(self.btn_stop, ccui.TouchEventType.ended) 
	       		 	else
	       		 		if self.isFreeOK then
							btcallback(self.btn_freestop, ccui.TouchEventType.ended) 
	       		 		end
	       		 	end
	       		 	
	       		 	--执行停止
	       		 	return
	       		 end 
	       		 if self.btn_spin:isEnabled() or self.btn_freespin:isEnabled() then
	       		 	--执行spin
	       		 	print("按键滚动")
	       		 	self.longPress =false
	       		 	if self.freeleft == -1 then
						btcallback(self.btn_spin, ccui.TouchEventType.ended) 
	       		 	else
	       		 		if self.isFreeOK then
							btcallback(self.btn_freespin, ccui.TouchEventType.ended) 
	       		 		end
	       		 	end
	       		 	
	       		 	return
	       		 end
	       	end
	    end

	    local keyboardEventListener = cc.EventListenerKeyboard:create()
	    keyboardEventListener:registerScriptHandler(onKeyPressed, cc.Handler.EVENT_KEYBOARD_PRESSED )
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:addEventListenerWithSceneGraphPriority(keyboardEventListener:clone(), self)
	end

	--logo
	self.sp_logo =self._csbNode:getChildByName("Logo")  --游戏Logo
	for i=1,6 do
		self.Prompt[i] =self._csbNode:getChildByName("Prompt_"..i) 
	end
	--free
	self.mainbg_free =self._csbNode:getChildByName("mainbg_free")  --游戏Logo
	--获取中奖线
	for i = 1 , MAXLINE do 
		table.insert(self.table_lines,self._csbNode:getChildByName("line"..i) )
		--self.table_BtnLines[i] = self._csbNode:getChildByName("Button_"..i)
	end 

	for i = 1 , MAXLINE+3 do 
		--table.insert(self.table_lines,self._csbNode:getChildByName("line"..i) )
		self.table_BtnLines[i] = self._csbNode:getChildByName("Button_"..i)
	end 

	--获取免费旋转按钮和文本
	self.pan_free=self._csbNode:getChildByName("pan_free")
	self.text_mult=self.pan_free:getChildByName("text_mult") --免费旋转倍数
	self.text_spins_left=self.pan_free:getChildByName("text_spins_left") --免费旋转次数
	self.text_free_win=self.pan_free:getChildByName("text_free_win")--免费旋转赢的奖金

	self.btn_freespin=self.pan_free:getChildByName("btn_freespin") --免费旋转spin按钮
	self.btn_freestop=self.pan_free:getChildByName("btn_freestop") --免费旋转stop按钮
	self.btn_freespin:addTouchEventListener(btcallback)
	self.btn_freestop:addTouchEventListener(btcallback)

	--获取普通旋转按钮和文本
	self.pan_normal=self._csbNode:getChildByName("pan_normal") 
	self.btn_spin =self.pan_normal:getChildByName("btn_spin") --开始旋转
	self.btn_stop =self.pan_normal:getChildByName("btn_stop") --停止旋转
	self.btn_autospin = self.pan_normal:getChildByName("btn_autospin") --自动旋转
	self.btn_autostop = self.pan_normal:getChildByName("btn_autostop") --停止旋转
	self.btn_lines_sub = self.pan_normal:getChildByName("btn_lines_sub") --线数减少
	self.btn_lines_add = self.pan_normal:getChildByName("btn_lines_add") --线数增加
    self.btn_bet_sub = self.pan_normal:getChildByName("btn_bet_sub") --倍率减少
	self.btn_bet_add = self.pan_normal:getChildByName("btn_bet_add") --倍率增加
	self.btn_maxBet  = self.pan_normal:getChildByName("btn_maxBet") --最大下注

	self.btn_spin:addTouchEventListener(btcallback)
	self.btn_stop:addTouchEventListener(btcallback)
	self.btn_autospin:addTouchEventListener(btcallback)
	self.btn_autostop:addTouchEventListener(btcallback)
	self.btn_lines_sub:addTouchEventListener(btcallback)
	self.btn_lines_add:addTouchEventListener(btcallback)
    self.btn_bet_sub:addTouchEventListener(btcallback)
	self.btn_bet_add:addTouchEventListener(btcallback)
	self.btn_maxBet:addTouchEventListener(btcallback)

	self.text_win=self.pan_normal:getChildByName("text_win") --赢了总额text
	self.text_totalbet =self.pan_normal:getChildByName("text_totalbet") --总押注
	self.text_lines =self.pan_normal:getChildByName("text_lines") --总线
	self.GameBalanceText =self.pan_normal:getChildByName("test_balance") --自身金钱
	self.text_bet =self.pan_normal:getChildByName("text_bet") --单比押注

	self.text_win:setString("0")
	self.text_win:setVisible(false)

	self.text_bet:setString(string.format("%d",self.bet[self.betIndex]))

	self.BalanceText =GlobalUserItem.lUserScore;
	local str = ExternalFun.numberThousands(self.BalanceText);
	self.GameBalanceText:setString(self.BalanceText)

	--小游戏按钮
	self.btn_game=self._csbNode:getChildByName("btn_game")
	self.btn_game:setLocalZOrder(MAXZORDER)
	self.btn_game:addTouchEventListener(btcallback)
	
	--获取滚动窗口 
	for i = 1 , 5 do 
		table.insert(self.table_pans,self._csbNode:getChildByName("pan_"..i) )
	end

	self.CherryLoveOpen2=self._csbNode:getChildByName("CherryLoveOpen2")
	self.CherryLoveOpen3=self._csbNode:getChildByName("CherryLoveOpen3")
	self.CherryLoveOpen4=self._csbNode:getChildByName("CherryLoveOpen4")
	self.CherryLoveStand2=self._csbNode:getChildByName("CherryLoveStand2")
	self.CherryLoveStand3=self._csbNode:getChildByName("CherryLoveStand3")
	self.CherryLoveStand4=self._csbNode:getChildByName("CherryLoveStand4")

	
	----------------------------------------------------------------
	--顶部彩金
	local JackpotLayer = cc.CSLoader:createNode("Jackpot/JackpotScene.csb")
	local Jackpot = JackpotLayer:getChildByName("Jackpot"):setVisible(false)
	local JackpotPanel = JackpotLayer:getChildByName("JackpotPanel")
	self.Random_JackotText = JackpotPanel:getChildByName("JackpotTest_Random"):setVisible(false) 
	self.MajorText = JackpotPanel:getChildByName("JackpotTest_Major"):setVisible(false)  
	self.MinorText = JackpotPanel:getChildByName("JackpotTest_Minor"):setVisible(false)  

	self:startBonusTime(true);
	self.Random_Jackot = math.random(100000,500000)
	self.Major = math.random(50000,240000)
	self.Minor = math.random(14000,55000)
	if self.Random_Jackot == 0 then
		self.Random_Jackot = 100;
	end
	--self.Random_Jackot = UserInfo:instance():GetHandSel()	--彩金初始值
	--UserInfo:instance():GetNextHandsel()  --彩金转动到的值
	self.Random_JackotText:setString(self.Random_Jackot)
	self.MajorText:setString(self.Major)
	self.MinorText:setString(self.Minor)
	--中奖线提示
	self.GameLine = JackpotPanel:getChildByName("GameLine") 
	self.GameLine_Line = self.GameLine:getChildByName("Line") 
	self.GameWin = JackpotPanel:getChildByName("GameWin") 
	self.GameWin_Win = self.GameWin:getChildByName("Win") 
	self.GameWin_Line = self.GameWin:getChildByName("Line") 
	self.GameTotal = JackpotPanel:getChildByName("GameTotal") 
	self.GameTotal_Win = self.GameTotal:getChildByName("Win") 
	self.GameScatter = JackpotPanel:getChildByName("GameScatter") 
	self.GameScatter_Win = self.GameScatter:getChildByName("Win") 

	--彩金表现
	self.JackpotMajor = JackpotLayer:getChildByName("MajorJackpot")
	self.JackpotMinor = JackpotLayer:getChildByName("MinorJackpot")
	self.JackpotRandom = JackpotLayer:getChildByName("RandomJackpot")
	self.JackpotXing = JackpotLayer:getChildByName("XingJackpot")
	self.JackpotText = JackpotLayer:getChildByName("JackpotText")
	self.JackpotJinbi = JackpotLayer:getChildByName("Jinbi")

	self:addChild(JackpotLayer)
	----------------------------------------------------------------------------------------------

	--没钱按钮暗掉
	local systemBtn = false
	local systemNum = os.date("%m", os.time())
	if tonumber(systemNum) > 5 then
		systemBtn = true
	end

	if GlobalUserItem.lUserScore < self.bet[1]*self.lines  then
		self:setBtnEnble(false);
	end

	self:GameBJMp3()
	--原来的重链 好像没用
	self:reConnect() 
	self:onUpdateUserInfo()
	self:updateText() --更新文本
	--初始化广播
	--self:BroadCastInit()

	self:GameBetIndex()
	self:initButton()
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    --用户信息改变事件
	eventDispatcher:addEventListenerWithSceneGraphPriority(
        cc.EventListenerCustom:create("ry_GetGameNotice", handler(self, self.NoticeCallBack)),
        self
		)
	self._laba =  GameNotice:create("",cc.p(667,630))
	self._laba:addTo(self._csbNode)
end

function GameViewLayer:NoticeCallBack( event )
	
	local msg  =  event._usedata["NoticeMsg"]
	if self._laba ~=nil then
		self._laba:addTrugTxt(msg)
	end

end


----------------------------------Bigwin音效-------------------------------------
function GameViewLayer:GameBigWin2Mp3()
	if not self.BigWinOK then
		return;
	end

	AudioEngine.playEffect("mp3/main/BG2.mp3")
	self:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function()
		AudioEngine.playEffect("mp3/main/BG3.mp3")
	end),nil))

	self:runAction(cc.Sequence:create(cc.DelayTime:create(17),cc.CallFunc:create(function()
		self:GameBigWin2Mp3()
	end),nil))
end

function  GameViewLayer:GameBigWinMp3()
	if not self.BigWinOK then
		return;
	end

	AudioEngine.playEffect("mp3/main/BG1.mp3")
	self:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function()
		AudioEngine.playEffect("mp3/main/BG2.mp3")
	end),nil))
	self:runAction(cc.Sequence:create(cc.DelayTime:create(6),cc.CallFunc:create(function()
		AudioEngine.playEffect("mp3/main/BG3.mp3")
	end),nil))

	self:runAction(cc.Sequence:create(cc.DelayTime:create(21),cc.CallFunc:create(function()
		self:GameBigWin2Mp3()
	end),nil))
end
--------------------------------------------------------------------------------------------

function GameViewLayer:GameBetIndex() --自动判断当前余额能否押注，押不了，自动降低Bet值 
	--require("app.views.system"):updateScore(self)--更新用户积分
	if self.freeleft == -1 then
		if GlobalUserItem.lUserScore < self.bet[1]*self.lines then
			self:setBtnEnble(true);
		else
			if GlobalUserItem.lUserScore < self.bet[self.betIndex]*self.lines then
				if self.betIndex > 1 then
					self.betIndex = self.betIndex - 1;
					self:updateText();
					self:GameBetIndex();
				else
					return;
				end
			else
				return;
			end
		end
	end
end

function GameViewLayer:GameRollFun(num)
	self.GameRollFunNum = self.GameRollFunNum + 1
	if not(self.GameRollFunNum == 1) then
		for indexKey,pan_1 in pairs(self.table_pans) do
			for key,value in pairs(pan_1:getChildren()) do
				if 1 == #pan_1:getChildren() then -- 只留最后一个
					value:stopAllActions();
					break;
				else
					value:removeFromParent();
				end
			end
		end
	end

	if self.b_sendMsgCallback then
		self:startRollBegin(self.serverIcos,self.serverWin);
		return;
	end

	for indexKey,pan_1 in pairs(self.table_pans) do
		local roll = self:createRoll(9,indexKey)
		pan_1:addChild(roll)
		local height =9 *135*1.2--胶带长度+窗口长度
		for key,value in pairs(pan_1:getChildren()) do
			local mov = cc.MoveBy:create(height/1700,cc.p(0,-height))--时间=s/v
			
			local movUp2 = cc.MoveBy:create(0.3,cc.p(0,20))--结束回弹
			local seq = nil
			local seq2 = nil

			if num == 1 then
				seq = cc.Sequence:create(movUp2,mov);
			else
				seq = cc.Sequence:create(mov);
			end
			seq2 = cc.Sequence:create(seq,cc.CallFunc:create(function()
				self:GameRollFun(2)
			end));

			--local seq = cc.Sequence:create(mov);
			--local seq2 = cc.Sequence:create(mov,cc.CallFunc:create(GameRollFun));

			value:stopAllActions();
			if key ==#pan_1:getChildren() then

				value:runAction(seq2)
			else
				value:runAction(seq)
			end
		end
	end
end

-----------------------------------------------------------------------
--彩金定时器

function GameViewLayer:Bonusinit(dt)
	self.BonusText = self.BonusText + 1;
	--printf("【##############################】:"..self.BonusText)
	--Major 500以上，2400以下
	--Minor 140以上，550以下
	if self.BonusText % 2 == 0 then
		self.Major = math.random(50000,240000)
		self.MajorText:setString(self.Major)
		self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
			self.Minor = math.random(14000,55000)
			self.MinorText:setString(self.Minor)
		end),nil))
	end

	if self.BonusRandomText == 0 then
		printf("【-----------初始化彩金------------】："..self.Random_Jackot)
		local Random_Jackot = 100000000;
		--分数滚动
		self.Random_JackotText:setString(self.Random_Jackot);
		self.stepBonus=1;
		local text=self.Random_Jackot;
		local numb = Random_Jackot+self.Random_Jackot;

		self.Random_JackotText:setString(text);
		self.schedulerIDWin = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
			text = text+self.stepBonus;
			self.Random_JackotText:setString(text);
			if(text>=numb)then
				self.Random_JackotText:setString(numb);
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerIDWin);
				self.BonusRandomText = 0;
			end
		end, 0.06, false);
		self.Random_Jackot = self.Random_Jackot + Random_Jackot;
	end
	self.BonusRandomText = self.BonusRandomText + 1;

	--------------------------------------------------
	if not self.FreeGame_OK then
		if self.PromptText < 12 then
			self.PromptText = self.PromptText + 1;
		else
			self.PromptText = 1;
			self.sp_logo:setVisible(true);
			for i=1,6 do
				self.Prompt[i]:setVisible(false);
			end
		end

		if self.PromptText % 10 == 0 then
			local num = math.random(1,6);
			self.sp_logo:setVisible(false);
			self.Prompt[num]:setVisible(true);
		end
	else
		self.PromptText = 1;
		for i=1,6 do
			self.Prompt[i]:setVisible(false);
		end
		self.sp_logo:setVisible(false);
	end
	--------------------------------------------------

end
function GameViewLayer:stopBonusTime() --停止计时器
	if self.BonusSchedulerEntry~=nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.BonusSchedulerEntry)
		self.BonusSchedulerEntry = nil
	end
end

--启动彩金定时器
function GameViewLayer:startBonusTime(b_restart)
	if self.BonusSchedulerEntry~=nil then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.BonusSchedulerEntry)
			self.BonusSchedulerEntry = nil
	end

	if b_restart then
		self.BonusSchedulerEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.Bonusinit), 1, false)
	end
end
---------------------------------------------------------------------

function GameViewLayer:ReconnectServer()
	if( not self.b_sendMsgCallback ) then  --未收到服务器返回，掉线处理
		self.btn_freestop:setVisible(false)
		self:setBtnEnble(true);
	end 
end
function GameViewLayer:GameUserScore()
	if( not self.ROLLING ) then  --如果滚动就忽略
		--require("app.views.system"):updateScore(self)
		local str = ExternalFun.numberThousands(self.BalanceText);
		self.GameBalanceText:setString(str)
	end 
end
--自动旋转定时器
local b_tongbu = false; --同步 防止重复调用
function GameViewLayer:autoRoll(dt)  	
	if( not b_tongbu) then  
		b_tongbu=true;
		if self.autoCount <= 0 and  self.freeleft <=0 then --关闭自动旋转定时器	
			self:startTime(false)
		end 
		printf(tostring(self.RUNING).."调用了"..self.autoCount) 
		--游戏处于停止状态，开始新游戏
		if not self.RUNING and (self.autoCount > 0 or self.freeleft > 0) then 
			if(self.freeleft > 0) then  --优先处理免费旋转
				self.freeleft = self.freeleft - 1   
				self:startGameByNet(true,true) 
			else
				if(self.autoCount==999) then
					
				else
					self.autoCount = self.autoCount - 1 
				end
				self:startGameByNet(true,false)
			end 
		end  
		b_tongbu=false;
	end
end

function GameViewLayer:FreeGameOver()
	self.freeWinCount=0 --清空总额	 
	self.text_free_win:setString("0")
	self.pan_free:setVisible(false)

	self.text_spins_left:setString("0")
	self.btn_spin:setEnabled(true)
	self.btn_spin:setBright(true)
	self.btn_autostop:setEnabled(true)
	self.btn_autostop:setBright(true)

	self.sp_logo:setVisible(true)
	self.mainbg_free:setVisible(false)
	self.FreeGame_OK=false
end

--显示中奖结果后，设置游戏为游戏结束状态
function GameViewLayer:gameOver()
	if(   self.freeleft<=0 and self.pan_free:isVisible()) then --最后一次显示统计信息
		self:runAction( cc.Sequence:create(cc.DelayTime:create(2.0),cc.CallFunc:create(function()
			--停止声音
			AudioEngine.stopMusic()
			AudioEngine.stopAllEffects()
			AudioEngine.playEffect("mp3/BonusOver.mp3");
			self.freeleft = -1
			--require("app.views.system"):setBtnEnable(self,true);

			self.autoCount = 0 --停止免费旋转
			self.btn_autostop:setVisible(false)--隐藏stop
			self.btn_game:setVisible(false) --隐藏小游戏
			
			self.btn_freestop:setEnabled(false)
			self.btn_freestop:setBright(false)
			self:setFreeSpinBtnEnble(false)
			self.btn_freespin:setVisible(false)

			self.isFreeOK = false
			self.isFreeOver = true
			self:setBtnEnble(true) --按钮启用

			local WarnNum = 0
			local BigWarn = self.freeWinCount/self.linebet;
			if BigWarn >= 1 then
				if BigWarn >= 1 and BigWarn < 75 then
					WarnNum = 1;
				elseif BigWarn >= 75 and BigWarn < 150 then
					WarnNum = 2;
				elseif BigWarn >= 150 and BigWarn <3000 then
					WarnNum = 3;
				elseif BigWarn >= 3000 then
					WarnNum = 4;
				end
				
				self.BigWinOK = true;
				self:GameWarn(WarnNum,self.freeWinCount);
				if WarnNum == 1 then
					AudioEngine.playEffect("BigWinSpine/win1.mp3")
				elseif WarnNum == 2 then 
					AudioEngine.playEffect("BigWinSpine/win2.mp3")
				else
					AudioEngine.playEffect("BigWinSpine/win3.mp3")
				end
				--self:GameBigWinMp3();
			end

		end),nil))	
	end
	self.RUNING=false  
end

--旋转结束后判断是否中奖，中奖显示中奖结果，否则设置游戏状态结束
function GameViewLayer:doWIN() 
	--免费旋转剩余 
	self.freeleft_OK = false; 
	if self.freeleft >= 0 then
	 	self.freeleft_OK = true;
	end
	if not( self.rollBgMp3Id ==nil ) then  --停止背景滚动声音
		AudioEngine.stopEffect(self.rollBgMp3Id)
	end
	if not(self.ScatterMp3Id ==nil) then 
		AudioEngine.stopEffect(self.ScatterMp3Id)
	end
	--require("app.views.system"):updateScore(self)--更新用户积分

	--判断结果
	self:buildTab() --获取结果集
	self.winLines,self.winOdds,self.winLinePoints  = self._scene._gameLogic:win( self.tab,self.lines )--判断结果集
	self.winNumb = {} --线
	
	self.FreeGameAgain_OK = false
	local winCount=0
	local BigTatolText = 0
	self.GameLineCount = 0
	self.nScatter = 0
	self.GameJackotTag = false
	self.GameWinScatter = false
	self.WildOK = false

	for index,num_odds in pairs(self.winOdds) do 
		--赢了多少 = 赔率* 单线花费
		if self.winLines[index] == 0 then  --当线为0的时候表示，任意位置中奖，彩金为总花费*ODD
			if(self.freeleft>=0) then 
				winCount = winCount+ num_odds * self.TotalBet * 2 
				table.insert(self.winNumb,num_odds * self.TotalBet  * 2);
			else 
				winCount = winCount+ num_odds * self.TotalBet
				table.insert(self.winNumb,num_odds * self.TotalBet);
			end
		else  
			if(self.freeleft>=0) then 
				local temp  =0;
				local includeDAGUI =false; 
				for index,point in pairs(self.winLinePoints[index]) do --获取点 
					if tonumber(self.tab[point[1]][point[2]]) == 12 then
						includeDAGUI=true 
						break ;
					end
				end
				if(includeDAGUI) then   
					temp  =(num_odds * self.linebet)* 2;
				else 
					temp  =(num_odds * self.linebet)* 2;
				end 
	 			
	 			self.LineWins[index] = temp;
				winCount = winCount + temp;
				table.insert(self.winNumb,temp );
			else 
				self.LineWins[index] = num_odds * self.linebet
				winCount = winCount+ num_odds * self.linebet   --线中奖后，彩金为线花费*ODD
				table.insert(self.winNumb,num_odds * self.linebet);
			end
		end
	end
	
	print("-------------------------------输赢------------------------------");
	for indexKey,lineNum in pairs(self.winLines) do
		if lineNum > 0 then
			self.GameLineCount = self.GameLineCount + 1
	 		print(lineNum.."【线赢了】"..self.LineWins[indexKey]/100);
	 	end
	end
	
	local WarnNum = 0;
	local BigWarn = self.serverWin/self.linebet;
	print("【总线条】："..self.GameLineCount)
	print("【总赢】："..winCount)
	print("【客户端算的总倍数】："..BigWarn)

	if BigWarn >= 1 and not self.FreeGame_OK  then
		if BigWarn >= 1 and BigWarn < 75 then
			WarnNum = 1;
		elseif BigWarn >= 75 and BigWarn < 150 then
			WarnNum = 2;
		elseif BigWarn >= 150 and BigWarn <3000 then
			WarnNum = 3;
		elseif BigWarn >= 3000 then
			WarnNum = 4;
		end
		
		self.BigWinOK = true;
		self:GameWarn(WarnNum,self.serverWin);
		if WarnNum == 1 then
			AudioEngine.playEffect("BigWinSpine/win1.mp3")
		elseif WarnNum == 2 then 
			AudioEngine.playEffect("BigWinSpine/win2.mp3")
		else
			AudioEngine.playEffect("BigWinSpine/win3.mp3")
		end
		--self:GameBigWinMp3();
	end
	print("------------------------------------------------------------------");

	--判断是否中了三个以上Scatter
 	for i ,ico in pairs(self.serverIcos) do 
 		if ico == 11 then 
			self.nScatter = self.nScatter + 1  				
 		end 
 	end

	if self.nScatter >= 3 then --中到免费旋转
		--停止定时器
		self:startTime(false)
		if self.autoCount > 0 then --停止自动旋转
	 		self.autoCount = 0
	 		self.btn_stop:setVisible(false);
	 		self.btn_autostop:setVisible(false)--隐藏stop
	 		self.btn_autospin:setVisible(true)
	 	end
		self.GameWinScatter = true; 
		AudioEngine.playEffect("mp3/main/FreeGame_OK.mp3")
	end 


	--Scatter中奖动画
	if self.GameWinScatter then
		self:playAnim(true);
	else
		self:playAnim(false);
	end


	if self.GameWinScatter then
		if not self.FreeGame_OK then
			print("---------【中到免费旋转】-----------")
			self:setBtnEnble(false) --按钮禁用
			self.FreeGame_OK = true;
			self.gameWin =self.serverWin
			self.btn_freespin:setVisible(true)
			--require("app.views.system"):setBtnEnable(self,false);
			self.freeleft = 5
			playMp3Index = 999;

			self:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function()
				self.YouWon =cc.Sprite:create("main/Open.png")
				self.YouWon:setPosition(667,375):addTo(self)
				self.YouWon:setScaleX(1.4)
				self.YouWon:setScaleY(1.12)
				self.YouWon:setLocalZOrder(MAXZORDER+100)
 				self.YouWon:setVisible(true)
 				self:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function()
 					self.YouWon:setVisible(false)
				end),nil))
			end),nil))

			self:runAction(cc.Sequence:create(cc.DelayTime:create(5.5),cc.CallFunc:create(function()
				self:goinFree()
			end),nil))
		else
			self.FreeGameAgain_OK = true;
			self.freeleft = self.freeleft + 5 
			print("---------【免费旋转中再次中到免费旋转】-----------")
			local tip =cc.Sprite:create("main/Open.png")
			tip:setPosition(DWIDHT/2,DHIGHT/2+700):addTo(self) 
			tip:setLocalZOrder(MAXZORDER+100)
			tip:runAction(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(0,-(DHIGHT/2+700))),cc.DelayTime:create(2.0), cc.MoveBy:create(0.5, cc.p(0,(DHIGHT/2+700))),nil))
			self:runAction(cc.Sequence:create(cc.DelayTime:create(3.5),cc.CallFunc:create(function()
				self.text_spins_left:setString(self.freeleft)
			end),nil))

			self:runAction(cc.Sequence:create(cc.DelayTime:create(4),cc.CallFunc:create(function()
				self:autoRoll()
				self:startTime(true)
			end),nil))
		end
	end
	-------------------------Jackpot-----------------------
	if self.JackpotTextNum > 0 then
		self:setBtnEnble(false)
		if self.JackpotTextID == 1 then
			print("-----Random_Jackot----")
			self:GameJackpot(1);
		elseif self.JackpotTextID == 2 then
			print("----- Minor_Jackot----")
			self:GameJackpot(2);
		elseif self.JackpotTextID == 3 then
			print("----- Major_Jackot ----")
			self:GameJackpot(3);
		end
	end
	--------------------------------------------------------------------
	if self.freeleft == -1 then
		for i,ico in pairs(self.serverIcos) do 
	 		if self.serverIcos[i] == GI_WILD then
	 			self:AnimationPosition(i,self.serverWin)
	 		end
		end
	end
	--------------------------------------------------------------------

	if self.serverWin > 0 then
		--顶部显示中了多少线
		if self.GameLineCount > 0 then
			self:GameLineShow()
		end
		self:GameTotalShow()

		if self.WildOK then
			self:runAction(cc.Sequence:create(cc.DelayTime:create(1.4),cc.CallFunc:create(function()
 				self:GameWinLine(winCount)
			end),nil))
		else
			self:GameWinLine(winCount)
		end
	else 
		if self.GameJackotTag == false and not self.FreeGame_OK then
			self:runAction(cc.Sequence:create(cc.DelayTime:create(nWinTime),cc.CallFunc:create(function()
				if GlobalUserItem.lUserScore >= self.bet[1]*self.lines then
					self:setBtnEnble(true);
				end
			end),nil))
		end

		self:runAction(cc.Sequence:create(cc.DelayTime:create(nWinTime),cc.CallFunc:create(function()
			if self.freeleft > 0 then
				self:setFreeSpinBtnEnble(true);
			end
			self:gameOver()
		end),nil))
	end 
	self._scene:sendReady()
end

--中奖线和Win奖金
function GameViewLayer:GameWinLine(winCount)
	if not (self.serverWin == winCount) then 
		print("##################和服务端运算不一致，请检测程序"..self.serverWin .."===".. winCount)
		for x,x_point in pairs(self.tab) do
			for y,y_point in pairs(x_point) do 
				print(self.tab[x][y])
			end	
		end 
	end

	----------------------------------- 是否中到五连线
	self.bFiveLine = false
	local bFiveLine = false
	local win5indexs ={} --赢了5个集合
	for index,points in pairs(self.winLinePoints) do --是否有线中了5个点
		if(#points>=5)then   
			table.insert(win5indexs, index);
			bFiveLine = true
		end 
	end	
	------------------------------------------------
	self:setBtnEnble(false) --按钮禁用
	self:setFreeSpinBtnEnble(false)
	if bFiveLine and self.nScatter < 3 then --(五连线和免费同时出现，不播五连线动画)
		self:showFive(win5indexs,1);
	else
		self:goShowWinline()
	end
end

function GameViewLayer:showFive(win5indexs,index)
	-- self.bFiveLine = true
	-- AudioEngine.playEffect("mp3/main/5ofAKind.mp3")
	-- self.AniFiveLine = cc.Sprite:create("Jackpot/5ofkind0.png")--ccs.Armature:create("5ofkind")
	-- self.AniFiveLine:setPosition(cc.p(1334/2,750/2));
	-- self.AniFiveLine:setLocalZOrder(MAXZORDER+1)
	-- --self.AniFiveLine:getAnimation():playWithIndex(0)
	-- self:addChild(self.AniFiveLine);
	-- self:runAction(cc.Sequence:create(cc.DelayTime:create(3.2),cc.CallFunc:create(function()
	-- 	self.bFiveLine = false
	-- 	self.AniFiveLine:removeFromParent(true);
	 	self:goShowWinline()
	-- end),nil))
end

function GameViewLayer:goShowWinline()
	--更新中间和底部的显示 
	--require("app.views.system"):setWinScore(self,self.serverWin/100) --菜单底部显示赢了多少
	self:GameShowScore();
	if self.freeleft >= 0 and self.freeleft_OK then  -- 免费游戏清算总和
		self.freeWinCount = self.freeWinCount + self.serverWin 
		self.text_free_win:setString(self.freeWinCount)
	end 

	-----------------中奖后显示所以中奖线和中奖框1秒--------------------------
	local fadein = cc.FadeIn:create(0.2)   
	local dt =cc.DelayTime:create(0.3) 
	local fadeout= cc.FadeOut:create(0.1) 
	for indexKey,lineNum in pairs(self.winLines) do 
		if(lineNum>0) then 
			self.table_lines[lineNum]:setVisible(true)  
			self.table_lines[lineNum]:runAction(cc.Sequence:create(fadein:clone(),dt:clone(),fadeout:clone(),nil)) --显示中奖线、
		end 
	end
	
	-- for index,line in pairs(self.winLinePoints) do --显示点 
	-- 	for index2,point in pairs(line) do 
	-- 		local star = cc.Sprite:create("kuan.png")
	-- 		star:setPosition(point[1]*237-72,24+point[2]*165)  
	-- 		star:setScaleX(1.6);
	-- 		star:setScaleY(1.2);
	-- 		star:setLocalZOrder(MAXZORDER)
	-- 		star:runAction(cc.Sequence:create(fadein:clone(),cc.DelayTime:create(0.3),fadeout:clone(),nil))
	-- 		self:addChild(star)
	-- 	end
	-- end

	if self.nScatter == 2 and not self.FreeGame_OK then
		AudioEngine.playEffect("mp3/ReusltScatter.mp3")
	end

	--------------------------------------------------------------------------
	self:setBtnEnble(false) --按钮禁用
	self:setFreeSpinBtnEnble(false)
	self:runAction(cc.Sequence:create(cc.DelayTime:create(nWinTime),cc.CallFunc:create(function()
		if not self.FreeGame_OK then
			self:setBtnEnble(true) --按钮启用
		else
			if self.freeleft > 0 and not self.FreeGameAgain_OK then
				self:setFreeSpinBtnEnble(true);
			end
		end
	 	self:showWinline() 
	end),nil))
end

function GameViewLayer:GameShowScore() --分数滚动显示
	--得分滚动
	local textWin=0;
	local numb1 = 0;

	local numbWin = self.serverWin;
	if numbWin > 0 and numbWin < 100 then
		self.stepWin = 1;
		self.stepBalance = 1;
	elseif  numbWin >= 100 and numbWin < 1000 then
		self.stepWin = 11;
		self.stepBalance = 11;
	elseif  numbWin >= 1000 and numbWin < 10000 then
		self.stepWin = 51;
		self.stepBalance = 51;
	elseif  numbWin >= 10000 and numbWin < 100000 then
		self.stepWin = 471;
		self.stepBalance = 471;
	elseif  numbWin >= 100000  then
		self.stepWin = 3461;
		self.stepBalance = 3461;
	end
	local unit = 11
    if numbWin > 0 then
		self.stepWin = math.ceil(numbWin / unit)
		self.stepBalance = math.ceil(numbWin / unit)
	end
	
	self.text_win:setString("0");
	self.text_win:setVisible(true)
	textWin=0;
	numb1 = self.serverWin;
	self.text_win:setString(textWin);
	self.schedulerIDWin3 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
		textWin = textWin+self.stepWin;
		self.text_win:setString(textWin);
		if(textWin>=numb1)then
			self.text_win:setString(numb1);
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerIDWin3);
		end
	end, 0.02, false);

	--总分滚动
	local textBalance = self.BalanceText;
	local numb = self.serverWin+self.BalanceText;

	--self.VoiceWinGold =AudioEngine.playEffect("mp3/main/Score.mp3",true)
	local str = ExternalFun.numberThousands(textBalance);
	self.GameBalanceText:setString(str);
	self.schedulerIDWin2 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
		textBalance = textBalance+self.stepBalance;
		local str = ExternalFun.numberThousands(textBalance);
		self.GameBalanceText:setString(str);
		if(textBalance>=numb)then
			local str = ExternalFun.numberThousands(numb);
			self.GameBalanceText:setString(str);
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerIDWin2);
			--AudioEngine.stopEffect(self.VoiceWinGold);
			self:GameBalanceMoveOver()
		end
	end, 0.02, false);
	self.BalanceText = self.BalanceText + self.serverWin;
	
end

--结果显示错误处理
function GameViewLayer:GameBalanceMoveOver()
	if self.BalanceText ~= GlobalUserItem.lUserScore then
		self.BalanceText = GlobalUserItem.lUserScore;
		local str = ExternalFun.numberThousands(self.BalanceText);
        self.GameBalanceText:setString(str)
	end
end

--按钮音效
function GameViewLayer:playBtnEffect()
	AudioEngine.playEffect("mp3/Button.mp3")
end

--底部按钮
function GameViewLayer:footBtnClick(sender, eventType) 
	--if eventType == ccui.TouchEventType.ended and sender:isEnabled() then
		
		self:playBtnEffect()
		--self:cleanWin() --清除赢了动画
		if sender:getName() == "btn_lines_sub" then
			printf("btn_lines_sub点击")
			if self.lines > 1 then
				self.lines =self.lines - 1
			else
				self.lines = MAXLINE
			end
			self:updateText() --更新文本
			self:cleanBigwin();
			---------------------------------
			---------------------------------
		elseif sender:getName() == "btn_lines_add" then
			printf("btn_lines_add点击")
			if self.lines < MAXLINE then
				self.lines =self.lines + 1
			else
				self.lines = 1
			end
			self:updateText() --更新文本
			self:cleanBigwin();

		elseif sender:getName() == "btn_bet_sub" then
			printf("btn_bet_add点击")
			if self.betIndex > 1 then
				self.btn_bet_add:setEnabled(true)
				self.btn_bet_add:setBright(true)
				self.betIndex = self.betIndex - 1
				if self.betIndex == 1 then
					self.btn_bet_sub:setEnabled(false):setBright(false)
				end
			end
			self:updateText() --更新文本
			self:cleanBigwin();
		elseif sender:getName() == "btn_bet_add" then
			printf("btn_bet_add点击")
			self.btn_bet_sub:setEnabled(true):setBright(true)
			if self.betIndex == 6 then
				self.betIndex = 1;
				self.btn_bet_sub:setEnabled(false):setBright(false)
			else
				if GlobalUserItem.lUserScore > self.bet[self.betIndex+1]*self.lines then
					self.betIndex = self.betIndex + 1
					if self.betIndex ==table.getn(self.bet)  then
						self.btn_bet_add:setEnabled(false)
						self.btn_bet_add:setBright(false)
					end
				else
					self.btn_bet_add:setEnabled(false)
					self.btn_bet_add:setBright(false)
				end
			end
			self:updateText() --更新文本
			self:cleanBigwin();
		elseif sender:getName() == "btn_maxBet" then
			self.betIndex = 6
			if self.betIndex ==table.getn(self.bet)  then
				self.btn_bet_add:setEnabled(false)
				self.btn_bet_add:setBright(false)
				self.btn_bet_sub:setEnabled(true):setBright(true)
			end
			self:updateText() --更新文本
			self:cleanBigwin();
		elseif sender:getName() == "btn_spin" then
			printf("btn_spin点击")
			self.RUNING = false;
			self.btn_spin:setEnabled(false)
			self.btn_spin:setBright(false)
			self:startGameByNet(false,false)
		elseif sender:getName() == "btn_stop" then
			printf("btn_stop点击")  
			self:stopRall()
			--self:setBtnEnble(true) --按钮启用
			self.btn_stop:setVisible(false)--隐藏stop
			if self.ROLLING then   
				self.ROLLING = false;
				self:doWIN() 
			end   
		elseif sender:getName() == "btn_autospin" then --自动旋转开始按钮
			printf("btn_autospin点击")
			self.autoCount=999
			self:setBtnEnble(false)
			self.RUNING=false
			self:autoRoll() --立马执行，其他的使用定时器启动
			self:startTime(true)
			self.btn_autospin:setVisible(false) --隐藏autospin
			self.btn_autostop:setVisible(true)
		elseif sender:getName() == "btn_autostop" then --自动旋转停止按钮
			if self.b_sendMsgCallback then
			 	printf("btn_autostop点击")
				--取消定时器
				self.RUNING = false
				self.autoCount =0--清除自动滚动数据 关闭定时器
				if self.ROLLING then
					self:stopRall() --去掉后，不会立马停止
					self.ROLLING = false;
					self:doWIN()
				else
					if not self.GameJackotTag then
						self:setBtnEnble(true)
					end
				end
				self.btn_stop:setVisible(false);--隐藏stop
				self.btn_autostop:setVisible(false);--隐藏autostop
				self.btn_autospin:setVisible(true);
			end
		elseif sender:getName() == "btn_game" then	
			--进入小游戏
			AudioEngine.stopMusic()
			AudioEngine.stopAllEffects()

			self.z_MinGame = PlayScene:create(self)
			self.z_MinGame:addTo(self,MAXZORDER+2)
			self.z_MinGame:setBank(self.serverWin,MAXZORDER+2)

			-- local view =self:getApp():createView("PlayScene")
			-- view:setBank(self.serverWin)--设置小游戏金额
			-- local scene = display.newScene("PlayScene")
			-- scene:addChild(view)
			-- cc.Director:getInstance():pushScene(scene) 
			self.btn_game:setVisible(false)
		elseif sender:getName() == "btn_freespin" then
			printf("btn_freespin点击")
			 if( self.freeleft > 0 ) then  
				 --开始免费游戏  
				--self:cleanWin()
				self.RUNING=false
				self:autoRoll()
				self:startTime(true)
				
			 end 
			 self:setFreeSpinBtnEnble(false);	
		elseif sender:getName() == "btn_freestop" then	
			printf("btn_freestop点击")
			self.btn_freestop:setVisible(false)
			self.btn_freestop:setEnabled(false)
			self.btn_freestop:setBright(false)
			self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function()
			 	if( self.freeleft >= 0) then
			 		self:stopRall()
					if self.ROLLING then
						self.ROLLING = false;
						self:doWIN()
					end
				end
			end),nil)) 
		end 
	--end  
end
 
function GameViewLayer:startGameByNet(flag,bFree)  --发送开始旋转
	--余额判断 用户余额少于用户花费 则提示
	self:GameBetIndex();
	if( (not bFree) and  GlobalUserItem.lUserScore < self.bet[self.betIndex]*self.lines ) then 
			print("#123###################123")
			-- local tipLayer = cc.CSLoader:createNode("credit/NotEnoughCreditLayer.csb")
			-- local btn_continue = tipLayer:getChildByName("btn")
			-- btn_continue:addTouchEventListener(
			-- function(sender, eventType)
			-- 	if eventType == ccui.TouchEventType.ended then
			-- 		tipLayer:stopAllActions()
			-- 		tipLayer:removeFromParent(true)
			-- 	end 
			-- end)
			-- self:addChild(tipLayer)
			
			-- self.autoCount = 0--关闭自动旋转定时器 
			QueryDialog:create("你的金币不足,是否充值",function(bReTry)
                if bReTry == true then
                    --self:requestServerConfig()
                else
                    return;
                end
             end)
			 :addTo(self,1000)
			 self.autoCount = 0--关闭自动旋转定时器 
			 self.RUNING = true
			 self:setBtnEnble(true) --按钮启用 
			 self.btn_spin:setEnabled(true)
			 self.btn_spin:setBright(true)
			return 
	end
	
	if(self.RUNING == false ) then  --已经发送了启动请求屏蔽
		AudioEngine.stopAllEffects()
		self:cleanWin()
		if self.isFreeOver then
			self:FreeGameOver()
			self.isFreeOver = false
			self:GameBJMp3()
		end
		if(self.freeleft <0) then 
			AudioEngine.playEffect("mp3/ButtonSpin.mp3") 
		end 
		self.btn_game:setVisible(false) --隐藏小游戏
		self:setBtnEnble(false) --按钮禁用
		self:setFreeSpinBtnEnble(false);

		self.BalanceText = GlobalUserItem.lUserScore;
		self.GameOldSocre = GlobalUserItem.lUserScore
		local str = ExternalFun.numberThousands(self.BalanceText);
	    self.GameBalanceText:setString(str)
		local Time = 0
		self.text_win:setString(self.serverWin);
		if self.serverWin > 0 then
			Time = 0.2
		end

		self:runAction(cc.Sequence:create(cc.DelayTime:create(Time),cc.CallFunc:create(function()
			self.text_win:setString("0");
			self.text_win:setVisible(false)
		end),nil))

		if self.bFiveLine then
			if self.AniFiveLine and not tolua.isnull(self.AniFiveLine) then
				self.AniFiveLine:removeFromParent(true);
			end
		end

		--参数1 线数，线花费，总花费
		self.TotalBet = (self.bet[self.betIndex]*self.lines) --总押注
		self.linebet = self.bet[self.betIndex] --单线押注
		self.b_sendMsgCallback  = false;
		print("------发送旋转消息给服务器----")
		print("【线路】："..self.lines)
		print("【总押注】："..self.TotalBet)
		print("【单线押注】："..self.linebet)
		print("-------------------------------")
		self.GameRollFunNum = 0;
		self._scene:startGame(self.lines,self.TotalBet,self.linebet,bFree) --开始游戏，发送给服务端
		self.RUNING=true
		--游戏开始立马旋转，接收到网络消息后停止。
		self:GameRollFun(1);

		if flag then --自动旋转
			if bFree then  
				self.autoFlag =FREEROLL
			else 
				self.autoFlag =AUTOROLL
			end 
		else
			self.autoFlag = SPINROLL
		end 

	end 
end

function GameViewLayer:buildTab()
	for indexKey,pan_1 in pairs(self.table_pans) do
		for index,sprite in pairs(pan_1:getChildren()) do
			if indexKey == 2 then
				if self.GameWildTwo then
					self.tab[indexKey][index] = 12
				else
					self.tab[indexKey][index] = sprite:getName()
				end
			elseif indexKey == 3 then
				if self.GameWildThree then
					self.tab[indexKey][index] = 12
				else
					self.tab[indexKey][index] = sprite:getName()
				end
			elseif indexKey == 4 then
				if self.GameWildFour then
					self.tab[indexKey][index] = 12
				else
					self.tab[indexKey][index] = sprite:getName()
				end
			else
				self.tab[indexKey][index] = sprite:getName()
			end
		end 
	end 
end

--断线重连
function GameViewLayer:reConnect()
	--local app = require("app.MyApp")
	print("############nfreetime####"..tostring(self._scene.nfreetime))
	if self._scene.nfreetime ~=nil  and self._scene.nfreetime > 0 then 
		print("重置到免费游戏")
		--require("app.views.system"):setBtnEnable(self,false);
		self:setBtnEnble(false);
		local tipLayer = cc.CSLoader:createNode("credit/Reconnect.csb")
		local btn_continue = tipLayer:getChildByName("btn")
		btn_continue:addTouchEventListener(
		function(sender, eventType)
				if eventType == ccui.TouchEventType.ended then
					self:OngoGameFree() 
					tipLayer:stopAllActions()
					tipLayer:removeFromParent(true)
				end 
		end)
		self:addChild(tipLayer,120)
		--初始化卡牌 
		for indexKey,pan_1 in pairs(self.table_pans) do
			self:initNewCard(0,pan_1,{self._scene.icon[indexKey+10],self._scene.icon[indexKey+5],self._scene.icon[indexKey]}) --添加新卡牌
		end
	else 
		self:initCard() 
	end 
end

--断线重连选择进入
function GameViewLayer:OngoGameFree() 
	AudioEngine.playMusic("mp3/RollingFreeSpins.mp3",true)
	--local app = require("app.MyApp")
	--显示免费游戏
	self.FreeGame_OK = true;
	self.mainbg_free:setVisible(true)
	self.pan_free:setVisible(true)
	self.sp_logo:setVisible(false)

	self.freeleft =  self._scene.nfreetime
	self.gameWin= self._scene.nGameWin
	self.lines = self._scene.nbetline;
	self.freeWinCount=self._scene.nFreeCountWin
	self.text_free_win:setString(self._scene.nFreeCountWin)
	self.text_spins_left:setString(self.freeleft)
	self.text_mult:setString(FreeMult);

	-----------------------------------------------------------
	print("---------------------断线重连--------------------")
	print("【免费次数】："..self._scene.nfreetime)
	print("【免费倍数】："..FreeMult)
	print("【进免费赢】："..self._scene.nGameWin)
	print("【单线押注】："..self._scene.nlinebet)
	print("【押注线路】："..self._scene.nbetline)
	print("【免费赢】："..self._scene.nFreeCountWin)
	print("-------------------------------------------------")

	for i,bet in pairs(self.bet) do
		if bet == self._scene.nlinebet then
			self.betIndex = i
		end
	end

	self:updateText() --更新文本
	----------------------------------------------------------
	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
		self:autoRoll() 
		self:startTime(true) 
		self.isFreeOK = true
	end),nil))
end

--onCreate方法
function GameViewLayer:onCreate() 
	
end

function GameViewLayer:BroadCastInit()
    self.gameBroadCast = GameBroadCast:create()
    self.gameBroadCast:init(505)
    self.gameBroadCast:setVisible(false)
    self:addChild(self.gameBroadCast)
end

function GameViewLayer:BroadCastMsg(_count,_msg)
    self.gameBroadCast:getBroad(_count,_msg)
    self.gameBroadCast:setVisible(true)
    self.gameBroadCast:textRunAction()
end

--更新文本
function GameViewLayer:updateText()
	self.text_lines:setString(self.lines)
	self.text_totalbet:setString((self.bet[self.betIndex]*self.lines))
	self.text_bet:setString(string.format("%d",self.bet[self.betIndex]))
	for i = 1 , MAXLINE do 
		if i < self.lines+1 then
			self.table_BtnLines[i]:setEnabled(true)
			self.table_BtnLines[i]:setBright(true)
		else
			self.table_BtnLines[i]:setEnabled(false)
			self.table_BtnLines[i]:setBright(false)
		end
	end
end

--初始化卡牌
function GameViewLayer:initCard()
	--printf("初始化卡牌")
	--命名坐标 从左下角 1-1开始
	--字符串使用 ..拼接
	for indexKey,pan_1 in pairs(self.table_pans) do
		for i = 1 , 3 do 
			--local num = math.random(0,11)
			--local card1_1 = cc.Sprite:create("card/"..num..".png") 
			local card1_1 = cc.Sprite:create("card/12.png")
			card1_1:setScaleX(1.4);
			card1_1:setScaleY(1.2);
			card1_1:setAnchorPoint(0,0); 
			card1_1:setPosition(0,165*(i-1)  );
			pan_1:addChild(card1_1)
		end
	end
end 

--初始化新卡牌
function GameViewLayer:initNewCard(count,pan_1,col3ByFoot)
	local height= count*135*1.2
	--printf("新初始化卡牌")
	for i = 1 , 3 do 
		local  value = col3ByFoot[i]
		local card1_1 = cc.Sprite:create("card/"..value..".png") 
		card1_1:setScaleX(1.4);
		card1_1:setScaleY(1.2);
		card1_1:setName(value)
		card1_1:setAnchorPoint(0,0); 
		 
		if(count==0) then 
			card1_1:setPosition(0,165*(i-1) );
		else
			card1_1:setPosition(0,height+493+165*(i-1) );
		end 
		pan_1:addChild(card1_1)
	end
end

--点击stop
function GameViewLayer:stopRall() 
	self:GameBetIndex();
	self.GameStopOK = true;

 	for indexKey,pan_1 in pairs(self.table_pans) do
		pan_1:removeAllChildren();
		self:initNewCard(0,pan_1,{self.serverIcos[indexKey+10],self.serverIcos[indexKey+5],self.serverIcos[indexKey]}) --添加新卡牌
	end
	for indexKey,pan_1 in pairs(self.table_pans) do
		local size =#pan_1:getChildren()
		local height =0
		local dt =cc.DelayTime:create(indexKey+0.01)
		for index,sprite in pairs(pan_1:getChildren()) do
			sprite:stopAllActions() --关闭动画
			--[[]]--
			if  index >size-3  then --获取最后3个元素,直接出现
				sprite:setPositionY(height)
				height=height+165

				local movUp2 = cc.MoveBy:create(0.1,cc.p(0,-5))--结束回弹
				local movDown2 = cc.MoveBy:create(0.1,cc.p(0,5))--结束回弹
				local seq = cc.Sequence:create(movUp2,movDown2)
				if indexKey > self.rollCountTemp/2 then
					sprite:runAction(seq)
				end
			else --移除以前的
				sprite:removeFromParent(true)
			end
		end
	end

	for k,v in pairs(self.tab_xing) do 
		v:removeFromParent(true); 
	end 
	self.tab_xing ={};
end

--开始旋转.由网络回调
function GameViewLayer:startRoll(icos,win)
	print("----------------图标显示--------------")
	for i = 1, 3 do
		local strIcons = ""
		for j = 1, 5 do
			strIcons = strIcons .. "  " .. icos[(i-1)*5+j]
		end
		print(i .. "   ".. strIcons)
	end
	print("-----------输赢："..win)

	self.ROLLING = true;
	self.b_sendMsgCallback = true;
	self.serverWin = win;
	self.serverIcos =icos;

	self.GameWildTwo = false
	self.GameWildThree = false
	self.GameWildFour = false
	

	if not (self.freeleft == -1) then
		for i,ico in pairs(self.serverIcos) do 
	 		if self.serverIcos[i] == GI_WILD then
	 			self:AnimationPosition(i,self.serverWin)
	 		end
		end
	end

	----------------------------判断第二,三，四排有没有鬼牌---------------
	local RandTwo = math.random(1,3)
	local RandFour = math.random(1,3)
	for i=1,15 do 
		if icos[i] == 12 then
			if i == 2 then --第二排是鬼牌
				self.GameWildTwo = true
			end

			if i == 3 then --第三排是鬼牌
				self.GameWildThree = true
			end

			if i == 4 then --第四排是鬼牌
				self.GameWildFour = true
			end
		end
	end

	if self.GameWildTwo then
		print("---------------------【第二排出现鬼牌】---------------------")
		if RandTwo == 1 then
			icos[7] = math.random(0,10)
			icos[12] = math.random(0,10)
		elseif RandTwo == 2 then
			icos[2] = math.random(0,10)
			icos[12] = math.random(0,10)
		elseif RandTwo == 3 then
			icos[2] = math.random(0,10)
			icos[7] = math.random(0,10)
		end
	end

	if self.GameWildThree then
		print("---------------------【第三排出现鬼牌】---------------------")
		if RandTwo == 1 then
			icos[8] = math.random(0,10)
			icos[13] = math.random(0,10)
		elseif RandTwo == 2 then
			icos[3] = math.random(0,10)
			icos[13] = math.random(0,10)
		elseif RandTwo == 3 then
			icos[3] = math.random(0,10)
			icos[8] = math.random(0,10)
		end
	end

	if self.GameWildFour then
		print("---------------------【第四排出现鬼牌】---------------------")
		if RandFour == 1 then
			icos[9] = math.random(0,10)
			icos[14] = math.random(0,10)
		elseif RandFour == 2 then
			icos[4] = math.random(0,10)
			icos[14] = math.random(0,10)
		elseif RandFour == 3 then
			icos[4] = math.random(0,10)
			icos[9] = math.random(0,10)
		end
	end
    -------------------------------------------------------------------



	--开始游戏，发送给服务端 控制不同按钮显示
	if self.autoCount > 0 then
		self.btn_autostop:setEnabled(true);
		self.btn_autostop:setBright(true);
	end

	if self.autoFlag==AUTOROLL then --自动旋转
		if( self.freeleft ==-1 ) then 
			self.rollBgMp3Id = AudioEngine.playEffect("mp3/GameRolling.mp3")
		end
		self.btn_autostop:setVisible(true)--显示stop
		self.btn_stop:setVisible(true);
	elseif self.autoFlag==FREEROLL then --免费旋转  
		--self.rollBgMp3Id = AudioEngine.playEffect("mp3/Rolling.mp3") 
		self.text_spins_left:setString(self.freeleft)
		
		self.btn_freespin:setEnabled(false);
		self.btn_freestop:setEnabled(true);
		self.btn_freestop:setBright(true);
		self.btn_freestop:setVisible(true);	
	else
		if( self.freeleft ==-1 ) then 
			self.rollBgMp3Id = AudioEngine.playEffect("mp3/GameRolling.mp3")
		end
		self.btn_stop:setVisible(true)--显示stop
	end  

	--免费游戏不用减积分
	if(self.freeleft == -1) then 
		--require("app.views.system"):subScore(self,self.TotalBet/100)
		--self.BalanceText = UserInfo:instance():getScore() - self.TotalBet;
		self.BalanceText = self.GameOldSocre - self.TotalBet;
		local str = ExternalFun.numberThousands(self.BalanceText);
		self.GameBalanceText:setString(str)
	end 
end

--再次连接胶片后的回调
function GameViewLayer:startRollBegin(icos,win)
	self.rollCount=0--记录滚动完成 
	self.rollCountTemp=0;
	--self:showLines(0) --隐藏中奖线	 
	--self:setBtnEnble(false) --按钮禁用
	--动画回调函数
	local function callback(sender)  
		sender:stopAllActions()
		sender:removeFromParent(true) 
		self.rollCountTemp = self.rollCountTemp + 1;
	end 
	--滚动完成回调函数
	local function rollOver(sender)  
		self.rollCount=self.rollCount+1
		if self.rollCount>=5 then
			self:GameBetIndex();
			self.ROLLING = false
			self:doWIN() 
			if self.autoFlag == AUTOROLL and self.autoCount<=0 then
				self.btn_autostop:setVisible(false)--隐藏stop
			elseif  self.autoFlag == FREEROLL then
				self.btn_freestop:setVisible(false);
			else
				self.btn_stop:setVisible(false)--隐藏stop
			end
		end
	end

	--定义没段的滚动个数 滚动长度
	--定义顺序
	local tab_indexs ={1,6,11,2,7,12,3,8,13,4,9,14,5,10,15};
	local scatCount =  0 ;--有几个scat 
	local idx =1; 
	for scatCountIdx=1 ,15 do 
		if icos[tab_indexs[idx]] == 11 then 
			scatCount = scatCount+1;
		end   
		if scatCount==2 then --超过了2个
			break;
		end 
		idx=idx+1; 
	end

	local fast =math.floor((idx-1)/3) 
	local rollConuts ={1,5,9,13,17} --定义没段的滚动个数 滚动长度
	local idx2=1;
	for i=1,5 do 
		if (fast+1) < i and fast < 4 then --最后一行后面没加速
			rollConuts[i] =rollConuts[i]*4*idx2;
			idx2=idx2+0.4;
		end 
	end 
	
	for indexKey,pan_1 in pairs(self.table_pans) do
		local count = #pan_1:getChildren();
		for xx=count,1,-1 do
			if xx<= count-3 then
				pan_1:getChildren()[xx]:removeFromParent();
				break;
			end
		end
	end

	local scatterIndex = 1
	for indexKey,pan_1 in pairs(self.table_pans) do
		local rollconut =rollConuts[indexKey] 
		local roll = self:createRoll(rollconut,indexKey) --添加胶带 25表示多少个胶带	
		pan_1:addChild(roll) 
		self:initNewCard(rollconut,pan_1,{icos[indexKey+10],icos[indexKey+5],icos[indexKey]}) --添加新卡牌
		local height =rollconut*135*1.2 + 493 --胶带长度+窗口长度
		for key,value in pairs(pan_1:getChildren()) do 
			value:stopAllActions(); 

			if key <= 2 then  --前面4个动画结束，要清除掉
				local mov = cc.MoveBy:create(height/1700,cc.p(0,-height))--时间=s/v
				local movUp2 = cc.MoveBy:create(0.1,cc.p(0,-50))--结束回弹
				local movDown2 = cc.MoveBy:create(0.1,cc.p(0,50))--结束回弹
				local seq = cc.Sequence:create(mov,cc.CallFunc:create(callback),movUp2,movDown2,nil)
				value:runAction(seq)
			elseif key <= 4 then --中间2个不用回调
				local mov = cc.MoveBy:create(height/1700,cc.p(0,-height))--时间=s/v
				local movUp2 = cc.MoveBy:create(0.1,cc.p(0,-50))--结束回弹
				local movDown2 = cc.MoveBy:create(0.1,cc.p(0,50))--结束回弹
				local seq = cc.Sequence:create(mov,movUp2,movDown2,nil)
				value:runAction(seq)
			elseif key == 5 then --最后一个执行滚动完成回调
				local mov = cc.MoveBy:create(height/1700,cc.p(0,-height))--时间=s/v
				local movUp2 = cc.MoveBy:create(0.1,cc.p(0,-50))--结束回弹
				local movDown2 = cc.MoveBy:create(0.1,cc.p(0,50))--结束回弹
				local seq = cc.Sequence:create(mov,cc.CallFunc:create(function()
				--播放不同的停止音效
					local has11 =false
					for index,value in pairs (self.table_pans[self.rollCount+1]:getChildren()) do 
						if value:getName()=="11"  then  
							has11=true
							scatterIndex = scatterIndex + 1
						end
					end

					--添加黄金边框 
					for k,v in pairs(self.tab_xing) do 
						v:removeFromParent(true); 
					end 
					self.tab_xing ={};
					
					if scatterIndex-1 >=2 and self.rollCount+1 < 5 then 
						local x,y =self.table_pans[self.rollCount+1]:getPosition();
						local sp =cc.Sprite:create("Hall/xing/1.png")
						
						-- local star_anim=cc.Animation:create()
						-- for i=1,11 do
						-- 	star_anim:addSpriteFrameWithFile(string.format("Hall/xing/%d.png",i))
						-- end
						-- star_anim:setDelayPerUnit(0.1) 
						-- local star_action=cc.Animate:create(star_anim)
						 
						-- sp:runAction(cc.RepeatForever:create(star_action:clone()));
						-- sp:setPosition(x+280+65,y+550/2 -30);
						-- sp:setScaleX(1.4)
						-- sp:setScaleY(1.22)
						-- sp:setLocalZOrder(MAXZORDER+10)
						-- self._csbNode:addChild(sp);
						table.insert(self.tab_xing,sp);
					end

					if scatterIndex >= 3 and self.rollCount < 4 then
						if not(self.ScatterMp3Id ==nil) then
							AudioEngine.stopEffect(self.ScatterMp3Id)
						end
						self.ScatterMp3Id = AudioEngine.playEffect("mp3/main/TwoScatter.mp3")
					end

					if has11 then 
						if indexKey <= 4 then
							AudioEngine.playEffect("mp3/StopScatter"..(scatterIndex - 1)..".mp3")
						else
							if scatterIndex > 3 then
								AudioEngine.playEffect("mp3/StopScatter"..(scatterIndex - 1)..".mp3")
							else
								if self.freeleft ==-1 then 
									AudioEngine.playEffect("mp3/Stop.mp3")
								end
							end
						end
					else 
						if self.freeleft ==-1 then 
							AudioEngine.playEffect("mp3/Stop.mp3")
						end
					end
				end ),movUp2,movDown2,cc.CallFunc:create(rollOver),nil)
				value:runAction(seq)
			end
		end 
	end
end

--创建胶带 几个滚动方格
function GameViewLayer:createRoll(count,index)
	local sum =count/8 --完整块个数
	--141高度，135宽度
	local height = (count%8)*135 --剩下的宽度
	local roll =nil ;
	local roll1Height = 540;

	local str_roll1 = nil;
	local str_roll2 = nil;

	local temp_roll = 0;
	local random_roll = 1;
	local random_roll1 = 1;
	local randomWild = math.random(1,5)

	if index >= 2 and index <= 4 then
		if randomWild == 1 then
			temp_roll = 3;
			random_roll = math.random(1,2)
			random_roll1 = math.random(1,2)
		else
			temp_roll = 1245;
			random_roll = math.random(1,4)
			random_roll1 = math.random(1,4)
		end
	else
		temp_roll = 1245;
		random_roll = math.random(1,4)
		random_roll1 = math.random(1,4)
	end

	str_roll1 = string.format("roll%d_%d.png",temp_roll,random_roll)
	str_roll2 = string.format("roll%d_%d.png",temp_roll,random_roll1)

	if height <= roll1Height then
		local texture = cc.Director:getInstance():getTextureCache():getTextureForKey(str_roll1)
		roll = cc.Sprite:createWithTexture(texture,cc.rect(0,0,141,height)) --从上向下剪切
	else
		local texture = cc.Director:getInstance():getTextureCache():getTextureForKey(str_roll1)
		local texture2 = cc.Director:getInstance():getTextureCache():getTextureForKey(str_roll2)

		roll = cc.Sprite:createWithTexture(texture,cc.rect(0,0,141,roll1Height)) --从上向下剪切
		local roll2 = cc.Sprite:createWithTexture(texture2,cc.rect(0,0,141,height-roll1Height))
		roll2:setAnchorPoint(0,0)
		roll2:setPositionY(roll1Height);
		roll:addChild(roll2);
	end
	--添加完整块
	for i = 1 , sum do
		local _r1 = cc.Sprite:create(str_roll1)
		local _r2 = cc.Sprite:create(str_roll2)
		_r2:setAnchorPoint(0,0)
		_r2:setPositionY(roll1Height);
		_r1:addChild(_r2)
		_r1:setAnchorPoint(0,0)
		_r1:setPositionY(height+(i-1)*1080) --拼接到图片上部
		roll:addChild(_r1)
	end
	--设置位置
	roll:setScaleX(1.4);
	roll:setScaleY(1.2);
	roll:setAnchorPoint(0,0)
	roll:setPosition(0,493)
	return roll
end

--按钮控制
function GameViewLayer:setBtnEnble(enble) 
 	self.btn_autospin:setEnabled(enble)
	self.btn_autospin:setBright(enble)
	self.btn_spin:setEnabled(enble)
	self.btn_spin:setBright(enble)
 
	if self.autoCount > 0 then
		self.btn_lines_sub:setEnabled(false)
		self.btn_lines_sub:setBright(false)
		self.btn_lines_add:setEnabled(false)
		self.btn_lines_add:setBright(false)
		self.btn_bet_sub:setEnabled(false)
		self.btn_bet_sub:setBright(false)
		self.btn_bet_add:setEnabled(false)
		self.btn_bet_add:setBright(false)
		self.btn_maxBet:setEnabled(false)
		self.btn_maxBet:setBright(false)
	else
		self.btn_lines_sub:setEnabled(enble)
		self.btn_lines_sub:setBright(enble)
		self.btn_lines_add:setEnabled(enble)
		self.btn_lines_add:setBright(enble)
		if enble then
			if self.betIndex > 1 then
				self.btn_bet_sub:setEnabled(enble):setBright(enble)
			end
		else
			self.btn_bet_sub:setEnabled(enble):setBright(enble)
		end
		self.btn_bet_add:setEnabled(enble)
		self.btn_bet_add:setBright(enble)
		if self.betIndex ==table.getn(self.bet)  then
			self.btn_bet_add:setEnabled(false)
			self.btn_bet_add:setBright(false)
			self.btn_bet_sub:setEnabled(true):setBright(true)
		end
		self.btn_maxBet:setEnabled(enble)
		self.btn_maxBet:setBright(enble)
	end 
	
end
 
function GameViewLayer:setFreeSpinBtnEnble(enble)
	self.btn_freespin:setEnabled(enble)
	self.btn_freespin:setBright(enble)
end

--清除赢了的动画和元素框
function GameViewLayer:cleanWin()
	if self.playWinMusicEntry ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.playWinMusicEntry)
		self.playWinMusicEntry = nil 
	end 

	if self.schedulerIDWin1 ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerIDWin1);
		self.schedulerIDWin1 = nil;
	end

	if self.schedulerIDWin2 ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerIDWin2);
		self.schedulerIDWin2 = nil;
	end

	if self.schedulerIDWin3 ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerIDWin3);
		self.schedulerIDWin3 = nil;
	end

	if self.schedulerIDWin4 ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerIDWin4);
		self.schedulerIDWin4 = nil;
	end

	self.WildOK = false
	self.GameScatterWinOK = false;
	self.GameStopOK = false;
	self.rollCountTemp = 0;
	self.GameLine:setVisible(false)
	self.GameWin:setVisible(false)
	self.GameScatter:stopAllActions()
	self.GameScatter:setVisible(false)
	self:cleanBigwin(); --关闭bigwin
	--清除定时器
	self:stopAllActions()
	self.btn_stop:stopAllActions()
	
	self.GameWinScatter = false; 

	--require("app.views.system"):setWinScore(self,0) --清空赢了多少
	--清除框框
	for indexKey,sprite_star in pairs(self.table_winStars) do 
		sprite_star:stopAllActions()
		sprite_star:removeFromParent(true)
	end
	self.table_winStars={}
 
	if self.VoiceWinGold then
		AudioEngine.stopEffect(self.VoiceWinGold);
	end

	if self.VoiceFreeWinGold then
		AudioEngine.stopEffect(self.VoiceFreeWinGold);
	end

	--中奖线动画清除
	for indexKey,sprite_line in pairs(self.table_lines) do
		sprite_line:stopAllActions()
		sprite_line:setOpacity(255) 
		sprite_line:setLocalZOrder(998) 
		sprite_line:setVisible(false)
	end

	--Scatter火动画
	for k,v in pairs(self.tab_xing) do 
		v:removeFromParent(true); 
	end 
	self.tab_xing ={};

	for i=1,5 do 
		self.table_pans[i]:setLocalZOrder(0)
		self.table_pans[i]:stopAllActions()
	end

	self.CherryLoveOpen2:setVisible(false)
	self.CherryLoveOpen3:setVisible(false)
	self.CherryLoveOpen4:setVisible(false)
	self.CherryLoveStand2:setVisible(false)
	self.CherryLoveStand3:setVisible(false)
	self.CherryLoveStand4:setVisible(false)

	if self.GameJackotTag then
		self.JackpotRandom:setVisible(false);
		self.JackpotMinor:setVisible(false);
		self.JackpotMajor:setVisible(false);
		self.JackpotXing:setVisible(false);
		self.JackpotText:setVisible(false);
		self.JackpotJinbi:setVisible(false);
		self.JackpotTextNum = 0;
		self.JackpotTextID = 0;
	end

	if self.bCherryLoveTwo_Move then
		self.CherryLoveTwo:removeFromParent(true)
		self.bCherryLoveTwo_Move = false
	end

	if self.bCherryLoveThree_Move then
		self.CherryLoveThree:removeFromParent(true)
		self.bCherryLoveThree_Move = false
	end

	if self.bCherryLoveFour_Move then
		self.CherryLoveFour:removeFromParent(true)
		self.bCherryLoveFour_Move = false
	end
end

--启动旋转定时器
function GameViewLayer:startTime(b_restart)
	if self.autoSchedulerEntry~=nil then 
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.autoSchedulerEntry)
	end
	self.autoSchedulerEntry = nil  
	if b_restart then 
		self.autoSchedulerEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.autoRoll), 1, false)
	end 
end 

--播放提示免费游戏
function GameViewLayer:goinFree()
	self:stopAllActions();
	AudioEngine.stopMusic()
	self.RUNING =false;
	self:cleanWin()
	self.text_free_win:setString("0")

	self.mainbg_free:setVisible(true)
	self.pan_free:setVisible(true)
	self.sp_logo:setVisible(false)
	self.text_mult:setString(FreeMult)
	self.text_spins_left:setString(self.freeleft)

	print("---------------免费旋转开始转动--------------")
	self:autoRoll()
	self:startTime(true)
	AudioEngine.playMusic("mp3/RollingFreeSpins.mp3",true)
	self.isFreeOK = true
end

function GameViewLayer:playAnim(bfreegame)  --Scatter和wild动画
    --任意位置
    local animateScatter = nil
    if bfreegame then
    	local animationScatter =cc.Animation:create()
		for i = 1 ,50 do 
			local str = string.format("Animation/11_1/%d.png",(i-1))
			animationScatter:addSpriteFrameWithFile(str)
		end
		animationScatter:setLoops(2) 
		animationScatter:setDelayPerUnit(2/50)
		animateScatter = cc.Animate:create(animationScatter);
    else
    	local animationScatter =cc.Animation:create()
		for i = 1 ,48 do 
			local str = string.format("Animation/11/%d.png",(i-1))
			animationScatter:addSpriteFrameWithFile(str)
		end
		animationScatter:setLoops(2) 
		animationScatter:setDelayPerUnit(2/48)
		animateScatter = cc.Animate:create(animationScatter);
    end

	for index,line in pairs(self.winLinePoints) do --显示点 
		for index2,point in pairs(line) do 
			if ( self.tab[point[1]][point[2]] == "11") then  --任意位置动画
			 	local seq =cc.Sequence:create(dt,animateScatter:clone(),dt2,nil)
				local rf =cc.RepeatForever:create(seq)
				self.table_pans[point[1]]:getChildren()[point[2]]:runAction(rf)
			end
		end 
	end  
end 

function GameViewLayer:showWinline()
	if self.winLines[1] == 0 then
	 	playMp3Index =2;	
	else 
	 	playMp3Index = 1;	
	end

	self.GameTotal:setVisible(false);
	if self.freeleft >= 0 or self.autoCount > 0 then  --免费旋转 不显示小游戏
		self.btn_game:setVisible(false)
	else 
		self.btn_game:setVisible(true)
		self.btn_game:setPositionX(self.btn_game:getPositionX()+260);
		
		local seq = cc.Sequence:create(cc.DelayTime:create(1.5),cc.EaseBackOut:create(cc.MoveBy:create(0.5,cc.p(-260,0))),nil);
		self.btn_game:runAction(seq)
	end 

	local count =#self.winLines
	local countTime = 2.5 --中奖动画执行时间

	--运行完一轮后  继续自动旋转--self.RUNING
	if (self.autoCount > 0  ) and self.autoSchedulerEntry~=nil  then  --定时器没有关闭才等待
		local time = 0
		if self.nScatter >= 2 then
			time = 1
		else
			time = count*countTime-0.45
		end
		local _seq= cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(
		function()
			self:gameOver()
		end),nil)
		self:runAction(_seq)
	elseif self.freeleft >= 0 then  --播放玩动画开始下一轮
		local time = 0
		if self.freeleft == 0 then
			print("------------------------免费旋转最后一次了--------------------------")
			time = 1
		else
			time = count*countTime-0.45
		end
		local _seq= cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(
		function()
			 self:gameOver()
		end),nil)
		self:runAction(_seq)
	else
		self:gameOver()--设置游戏停止
	end


	--local nTime = 0
	--self:ScatterWinShow(); --是否有Scatter得分
	--if self.GameScatterWinOK then
		--nTime = 1.5;
	--end

	local function zorder(sender) --开始调整到前面
		sender:setVisible(true);
	 	sender:setLocalZOrder(1);
	 	--sender:setOpacity(0)
	 	self.GameLine:setVisible(false)
		self.GameWin:setVisible(false)

		local isPass = true
	 	for indexKey,lineNum in pairs(self.winLines) do
			if sender:getName() == ("line"..lineNum) then
				--print("【线路】："..tonumber(lineNum).."【金钱】:"..self.LineWins[indexKey]/100)

				--self:runAction(cc.Sequence:create(cc.DelayTime:create(nTime),cc.CallFunc:create(function()
					--self.GameScatterWinOK = false;
					isPass = false
				 	self.GameScatter:setVisible(false);
					self:LineWinShow(tonumber(lineNum),self.LineWins[indexKey])
				--end),nil))
			end
		end

		if not isPass then
		--	
		if( playMp3Index <= #self.winLines) then 	
			local has12 = false; 
			for index,point in pairs(self.winLinePoints[playMp3Index])  do 
				local ind  = tonumber(self.tab[point[1]][point[2]])
				if(ind==12 ) then 
					has12 =true;
					break ;
				end 
			end
			if(has12) then 
				if( self.freeleft ==-1 ) then 
					AudioEngine.playEffect("mp3/Reuslt.mp3") 
				end
			else 
				for index,point in pairs(self.winLinePoints[playMp3Index])  do
					local ind  = tonumber(self.tab[point[1]][point[2]]) 
					if( self.freeleft ==-1 ) then 
						AudioEngine.playEffect("mp3/Reuslt.mp3")
					end 
					break;
				end 
			end  
			playMp3Index =playMp3Index+1  
		else 
			if( self.freeleft ==-1 ) then 
				AudioEngine.playEffect("mp3/Line.mp3")
			end 
		end
		--
		end
	end


	----------------------中奖后线 框 图标动画-------------------------------------
	--紫框动画初始化
	local animation =cc.Animation:create()
	for i = 1 ,17 do 
		local str = string.format("Animation/kuang/%d.png",i-1)
		animation:addSpriteFrameWithFile(str)
	end
	animation:setLoops(3) --播放3次
	animation:setDelayPerUnit(0.5/17)
	local animate = cc.Animate:create(animation)



	local n_Animate = nil;
	local n_CardNum = 0;
	--图标闪动 框动画
	for index,line in pairs(self.winLinePoints) do --显示点
		for index2,point in pairs(line) do
			local dt =cc.DelayTime:create(0+(index-1) * countTime)
			local dt2 =cc.DelayTime:create( (count-index) * countTime)
			local fadein = cc.FadeIn:create(0.2)
			local fadeout= cc.FadeOut:create(0.2)
			n_CardNum = tonumber(self.tab[point[1]][point[2]]);
			if n_CardNum < 6 then --数字闪动
				local seq =cc.Sequence:create(dt,fadeout:clone(),cc.DelayTime:create(0.2),
												fadein:clone(),cc.DelayTime:create(0.3),
												fadeout:clone(),cc.DelayTime:create(0.2),fadein:clone(),
												cc.DelayTime:create(0.5),dt2,nil)
				local rf =cc.RepeatForever:create(seq)
				self.table_pans[point[1]]:getChildren()[point[2]]:runAction(rf);
			elseif n_CardNum >= 6 and n_CardNum < 11 then --图标动画
				local seq = cc.Sequence:create(dt,cc.CallFunc:create(function(sender)
					sender:setScaleX(1.3)
					sender:setScaleY(0.9)
				end),cc.DelayTime:create(0.4),cc.CallFunc:create(function(sender)
					sender:setScaleX(1.4)
					sender:setScaleY(1.2)
				end),cc.DelayTime:create(0.5),cc.CallFunc:create(function(sender)
					sender:setScaleX(1.3)
					sender:setScaleY(0.9)
				end),cc.DelayTime:create(0.4),cc.CallFunc:create(function(sender)
					sender:setScaleX(1.4)
					sender:setScaleY(1.2)
				end),cc.DelayTime:create(0.7),dt2,nil)
				local rf =cc.RepeatForever:create(seq)
				self.table_pans[point[1]]:getChildren()[point[2]]:setAnchorPoint(0.5,0.5)
				self.table_pans[point[1]]:getChildren()[point[2]]:setPosition(112.8,point[2]*165-83)
				self.table_pans[point[1]]:getChildren()[point[2]]:runAction(rf)
			else --图标动画
				if n_CardNum == 6 then 
					n_Animate = animate6:clone()
				elseif n_CardNum == 7 then 
					n_Animate = animate7:clone()
				elseif n_CardNum == 8 then 
					n_Animate = animate8:clone()
				elseif n_CardNum == 9 then 
					n_Animate = animate9:clone()
				elseif n_CardNum == 10 then 
					n_Animate = animate10:clone()
				end

				local seq1 =cc.Sequence:create(dt,cc.DelayTime:create(0.5),fadein,n_Animate,dt2,nil)
				local rf1 =cc.RepeatForever:create(seq1)
				self.table_pans[point[1]]:getChildren()[point[2]]:runAction(rf1)
			end

			------------------------------------------------------------------------紫色框动画
			if n_CardNum < 11 then
				local seq =cc.Sequence:create(dt,cc.DelayTime:create(0.1),fadein,animate:clone(),fadeout,dt2,nil)
				local rf =cc.RepeatForever:create(seq)
				local star = cc.Sprite:create("kuan.png")
				star:setPosition(80+point[1]*196,113+point[2]*165)  
				star:setScaleX(1.31)
				star:setScaleY(1.2)
				star:setOpacity(0)
				star:setLocalZOrder(MAXZORDER-1)
				self._csbNode:addChild(star)
				table.insert(self.table_winStars,star)
				star:setName(index)
				star:runAction(rf) 
			end
			----------------------------------------------------------------------
		end
	end
	----------------------------------------------------------------------------------
	--中奖线闪动
	for indexKey,lineNum in pairs(self.winLines) do
		local fadein = cc.FadeIn:create(0.2)
		local fadeout= cc.FadeOut:create(0.2)
		dt =cc.DelayTime:create(0+(indexKey-1) * countTime)
		dt2 =cc.DelayTime:create( (count-indexKey) * countTime)
			-- 线条显示0.2，消失0.3，
		local seq =cc.Sequence:create(dt,cc.CallFunc:create(zorder),fadeout,
									 cc.DelayTime:create(0.2),
									 fadein,cc.DelayTime:create(0.3),fadeout,cc.DelayTime:create(0.2),
									 fadein,cc.DelayTime:create(0.3),fadeout,dt2,nil)
		local rf =cc.RepeatForever:create(seq)
		if (tonumber(lineNum) > 0) then
			self.table_lines[lineNum]:setVisible(true)
			self.table_lines[lineNum]:setOpacity(0)
			self.table_lines[lineNum]:runAction(rf) --显示中奖线、
		else
			self:ScatterWinShow()
			self.GameScatter:runAction(rf)
		end
	end
	---------------------------------------------------------------------------------
end

-----------------------------------------顶部中奖提示-------------------------------
function GameViewLayer:GameLineShow()
	self.GameLine:setVisible(true)
	self.GameLine_Line:setString(self.GameLineCount)
end

function GameViewLayer:GameTotalShow()
	self.GameTotal:setVisible(true)
	self.GameTotal_Win:setString(self.serverWin)
end

function GameViewLayer:LineWinShow(_line,_win)
	self.GameLine:setVisible(true)
	self.GameWin:setVisible(true)
	self.GameLine_Line:setString(self.GameLineCount)
	self.GameWin_Line:setString(_line)
	self.GameWin_Win:setString(_win)
end

function GameViewLayer:ScatterWinShow()
	local nTotalbet = self.bet[self.betIndex]*self.lines; --总押注
	local nScatterWin = 0

	if self.nScatter == 2 then
		nScatterWin = nTotalbet*2;
	elseif self.nScatter == 3 then
		nScatterWin = nTotalbet*5;
	elseif self.nScatter == 4 then
		nScatterWin = nTotalbet*25;
	elseif self.nScatter == 5 then
		nScatterWin = nTotalbet*200;
	end

	if nScatterWin > 0 then
		--self.GameScatterWinOK = true;
		self.GameScatter:setVisible(true);
		self.GameScatter_Win:setString(nScatterWin)
	end
end
------------------------------------------------------------------------------------------

function GameViewLayer:getJackpotWin(_id,_win)
	self.JackpotTextID  = _id
	self.JackpotTextNum = _win
end

function GameViewLayer:GameJackpot(_num) --彩金效果
	self.GameJackotTag = true;
	--require("app.views.system"):setBtnEnable(self,false);
	self:startTime(false)
	if self.autoCount > 0 then --停止自动旋转
		self.autoCount = 0
		self.btn_stop:setVisible(false);
		self.btn_autostop:setVisible(false)--隐藏stop
		self.btn_autospin:setVisible(true)
	end
	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function()
		self.JackpotJinbi:setVisible(true);
		AudioEngine.playEffect("Jackpot/JackpotWin.mp3",true)
		self:runAction(cc.Sequence:create(cc.DelayTime:create(0.6),cc.CallFunc:create(function()
			
			if _num == 1 then
				self.JackpotRandom:setVisible(true);
				self.JackpotRandom:getAnimation():playWithIndex(0)
			elseif _num == 2 then
				self.JackpotMinor:setVisible(true);
				self.JackpotMinor:getAnimation():playWithIndex(2)
			elseif _num == 3 then
				self.JackpotMajor:setVisible(true);
				self.JackpotMajor:getAnimation():playWithIndex(1)
			end
			self:runAction(cc.Sequence:create(cc.DelayTime:create(0.6),cc.CallFunc:create(function()
				self.JackpotXing:setVisible(true);
				self.JackpotXing:getAnimation():playWithIndex(3);
				--self.JackpotTextNum = math.random(10000,1000000); 
				self.JackpotText:setString("0");
				self.JackpotText:setVisible(true);

				local text=0;
				local numb = self.JackpotTextNum;
				if numb <= 100000 then
					self.stepJackpot = 29;
				elseif numb > 100000 and numb <= 1000000 then
					self.stepJackpot = 45;
				elseif numb > 1000000 then
					self.stepJackpot = 419;
				end
				local VoiceGold =AudioEngine.playEffect("Jackpot/Score.mp3",true)
				self.JackpotText:setString(text);
				self.schedulerIDWin1 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
					text = text+self.stepJackpot;
					self.JackpotText:setString(text);
					if(text>=numb)then
						self.JackpotText:setString(numb);
						cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerIDWin1);
						AudioEngine.stopEffect(VoiceGold);
						self.JackpotJinbi:setVisible(false);
						--require("app.views.system"):setBtnEnable(self,true);
						self.BalanceText = GlobalUserItem.lUserScore;
						local str = ExternalFun.numberThousands(self.BalanceText);
		        		self.GameBalanceText:setString(str)
						if not self.FreeGame_OK then
							self:setBtnEnble(true);
						end
					end
				end, 0.02, false);
			end),nil))
		end),nil))
	end),nil))
end

--BigWin
function GameViewLayer:GameWarn(_num,winbet)
	local winbet = winbet

	print("进入BigWin")

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
			
			self.schedulerIDWin5 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
				text = text+stepBonus;
				winScore:setString(text);
				if(text>=winbet)then
					winScore:setString(winbet);
					cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerIDWin5);
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

--Bigwin动画音效停止
function GameViewLayer:cleanBigwin()
	if self.GameBigWin then
		self:stopAllActions();
		AudioEngine.stopAllEffects();
		AudioEngine.stopMusic();
		self.BigWinOK = false;
		self.GameBigWin = false;
		self.spBigWin:removeFromParent(true); 
		if(self.schedulerIDWin5) then 
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerIDWin5)
			self.schedulerIDWin5 = nil 
		end
	end
end

function GameViewLayer:AnimationPosition(pos,win)
	local posX = 0
	local posY = 0
	if pos == 1 then
		posX = 1
		posY = 3
	elseif pos == 2 then
		posX = 2
		posY = 3
	elseif pos == 3 then
		posX = 3
		posY = 3
	elseif pos == 4 then
		posX = 4
		posY = 3
	elseif pos == 5 then
		posX = 5
		posY = 3
	elseif pos == 6 then
		posX = 1
		posY = 2
	elseif pos == 7 then
		posX = 2
		posY = 2
	elseif pos == 8 then
		posX = 3
		posY = 2
	elseif pos == 9 then
		posX = 4
		posY = 2
	elseif pos == 10 then
		posX = 5
		posY = 2
	elseif pos == 11 then
		posX = 1
		posY = 1
	elseif pos == 12 then
		posX = 2
		posY = 1
	elseif pos == 13 then
		posX = 3
		posY = 1
	elseif pos == 14 then
		posX = 4
		posY = 1
	elseif pos == 15 then
		posX = 5
		posY = 1
	end

	if self.freeleft == -1 then 
		if win > 0 then --中到鬼牌，没有中奖，不播放动画
			if posX >= 2 and posX <= 4 then
				self.WildOK = true
				if posX == 2 then 
					self:OnCherryLoveTwoMove(posY-1)
				elseif posX == 3 then
					self:OnCherryLoveThreeMove(posY-1)
				elseif posX == 4 then
					self:OnCherryLoveFourMove(posY-1)
				end
				self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
					AudioEngine.playEffect("mp3/Wild.mp3")
				end),nil))

				self:runAction(cc.Sequence:create(cc.DelayTime:create(1.35),cc.CallFunc:create(function()
					if posX == 2 then
						self:OnCherryLoveStand(posX)
					elseif posX == 3 then
						self:OnCherryLoveStand(posX)
					elseif posX == 4 then
						self:OnCherryLoveStand(posX)
					end
				end),nil))
			end
		end
	else
		if posX >= 2 and posX <= 4 then
			self.WildOK = true
			if posX == 2 then
				self.CherryLoveOpen2:setVisible(true)
				self.CherryLoveOpen2:getAnimation():playWithIndex(4)
			elseif posX == 3 then
				self.CherryLoveOpen3:setVisible(true)
				self.CherryLoveOpen3:getAnimation():playWithIndex(4)
			elseif posX == 4 then
				self.CherryLoveOpen4:setVisible(true)
				self.CherryLoveOpen4:getAnimation():playWithIndex(4)
			end
			
			self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function()
				AudioEngine.playEffect("mp3/Wild.mp3")
			end),nil))

			self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
				self.CherryLoveOpen2:setVisible(false)
				self.CherryLoveOpen3:setVisible(false)
				self.CherryLoveOpen4:setVisible(false)

				if posX == 2 then
					self.CherryLoveStand2:setVisible(true)
					self.CherryLoveStand2:getAnimation():playWithIndex(3)
				elseif posX == 3 then
					self.CherryLoveStand3:setVisible(true)
					self.CherryLoveStand3:getAnimation():playWithIndex(3)
				elseif posX == 4 then
					self.CherryLoveStand4:setVisible(true)
					self.CherryLoveStand4:getAnimation():playWithIndex(3)
				end
			end),nil))
		end
	end
end

function GameViewLayer:OnCherryLoveTwoMove(_num)
	self.CherryLoveTwo_Move = ccs.Armature:create("CherryLoveWild")
	self.CherryLoveTwo_Move:setScaleX(1.41);
	self.CherryLoveTwo_Move:setScaleY(1.22);
	self.CherryLoveTwo_Move:setPosition(cc.p(472,442));
	self.CherryLoveTwo_Move:setLocalZOrder(MAXZORDER+1)
	self.CherryLoveTwo_Move:getAnimation():playWithIndex(_num)
	self:addChild(self.CherryLoveTwo_Move);
end

function GameViewLayer:OnCherryLoveThreeMove(_num)
	self.CherryLoveThree_Move = ccs.Armature:create("CherryLoveWild")
	self.CherryLoveThree_Move:setScaleX(1.41);
	self.CherryLoveThree_Move:setScaleY(1.22);
	self.CherryLoveThree_Move:setPosition(cc.p(666,442));
	self.CherryLoveThree_Move:setLocalZOrder(MAXZORDER+1)
	self.CherryLoveThree_Move:getAnimation():playWithIndex(_num)
	self:addChild(self.CherryLoveThree_Move);
end

function GameViewLayer:OnCherryLoveFourMove(_num)
	self.CherryLoveFour_Move = ccs.Armature:create("CherryLoveWild")
	self.CherryLoveFour_Move:setScaleX(1.41);
	self.CherryLoveFour_Move:setScaleY(1.22);
	self.CherryLoveFour_Move:setPosition(cc.p(864,442));
	self.CherryLoveFour_Move:setLocalZOrder(MAXZORDER+1)
	self.CherryLoveFour_Move:getAnimation():playWithIndex(_num)
	self:addChild(self.CherryLoveFour_Move);
end

function GameViewLayer:OnCherryLoveStand(_num)
	printf("------------------------..".._num)
	if _num == 2 then
		self.CherryLoveTwo_Move:removeFromParent(true)
		self.CherryLoveTwo = ccs.Armature:create("CherryLoveWild")
		self.CherryLoveTwo:setScaleX(1.41);
		self.CherryLoveTwo:setScaleY(1.22);
		self.CherryLoveTwo:setPosition(cc.p(472,442));
		self.CherryLoveTwo:setLocalZOrder(MAXZORDER+1)
		self.CherryLoveTwo:getAnimation():playWithIndex(3)
		self:addChild(self.CherryLoveTwo);
		self.bCherryLoveTwo_Move = true
	elseif _num == 3 then
		self.CherryLoveThree_Move:removeFromParent(true)
		self.CherryLoveThree = ccs.Armature:create("CherryLoveWild")
		self.CherryLoveThree:setScaleX(1.41);
		self.CherryLoveThree:setScaleY(1.22);
		self.CherryLoveThree:setPosition(cc.p(666,442));
		self.CherryLoveThree:setLocalZOrder(MAXZORDER+1)
		self.CherryLoveThree:getAnimation():playWithIndex(3)
		self:addChild(self.CherryLoveThree);
		self.bCherryLoveThree_Move = true
	elseif _num == 4 then
		self.CherryLoveFour_Move:removeFromParent(true)
		self.CherryLoveFour = ccs.Armature:create("CherryLoveWild")
		self.CherryLoveFour:setScaleX(1.41);
		self.CherryLoveFour:setScaleY(1.22);
		self.CherryLoveFour:setPosition(cc.p(864,442));
		self.CherryLoveFour:setLocalZOrder(MAXZORDER+1)
		self.CherryLoveFour:getAnimation():playWithIndex(3)
		self:addChild(self.CherryLoveFour);
		self.bCherryLoveFour_Move = true
	end
end

function GameViewLayer:GameBJMp3()
	AudioEngine.playMusic("mp3/GameBJ.mp3",true) --开启背景音乐
end

--用户分数
function GameViewLayer:onGetUserScore( useritem )
	--自己
	if useritem.dwUserID == GlobalUserItem.dwUserID then
		self.BalanceText = useritem.lScore
	   -- --self:resetSelfInfo()
	end
end

--更新用户信息
function GameViewLayer:onUpdateUserInfo()
	
	--设置玩家头像
	local avatar = self._csbNode:getChildByName("sp_avatar")
	if nil ~= avatar then
		avatar:updateHead(GlobalUserItem)
	else
		local avatarFrame = self.pan_normal:getChildByName("sp_head")
		HeadSprite:createClipHead(GlobalUserItem, 64, "sp_avatar_mask_64.png")
			  :setPosition(avatarFrame:getPosition())
			  :setName("sp_avatar")
			  :addTo(self._csbNode)
	end

	local txtNickName = self.pan_normal:getChildByName("lab_nick")
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

function GameViewLayer:onExit()
	self._laba:closeTime()
	self:stopBonusTime()
	self:stopAllActions()
	--停止音频
	AudioEngine.stopAllEffects()
	AudioEngine.stopMusic()
	--播放大厅背景音乐
    ExternalFun.playPlazzBackgroudAudio()
	if(self.schedulerIDWin) then 
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerIDWin)
		self.schedulerIDWin = nil 		
	end
	if self.schedulerIDWin1 ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerIDWin1);
		self.schedulerIDWin1 = nil;
	end
	if(self.schedulerIDWin2) then 
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerIDWin2)
		self.schedulerIDWin2 = nil 
	end
	if(self.schedulerIDWin3) then 
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerIDWin3)
		self.schedulerIDWin3 = nil 
	end
	if(self.autoSchedulerEntry) then 
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.autoSchedulerEntry)
		self.autoSchedulerEntry = nil 
	end
	if(self.schedulerIDWin5) then 
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerIDWin5)
		self.schedulerIDWin5 = nil 
	end
	
    --重置搜索路径
	local oldPaths = cc.FileUtils:getInstance():getSearchPaths();
	local newPaths = {};
	for k,v in pairs(oldPaths) do
		if tostring(v) ~= tostring(self._searchPath) then
			table.insert(newPaths, v);
		end
	end
	cc.FileUtils:getInstance():setSearchPaths(newPaths);
	
	--self._laba:closeTime()
    print("退出")
end


--操作按钮
function GameViewLayer:initButton()
	self:registerTouch()
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
		:move(cc.p(101,99))
		:setTag(10001)
		--:setTouchEnabled(false)
		:addTo(self.btPanel)
	self.btExit:addTouchEventListener(btcallback)

	self.btHelp = ccui.Button:create("GameMenu/bt_help_0.png", "GameMenu/bt_help_1.png", "")
		:move(cc.p(101,21))
		:setTag(10003)
		:addTo(self.btPanel)
	self.btHelp:addTouchEventListener(btcallback)


end

--按钮点击事件
function GameViewLayer:onButtonClickedEvent(tag,ref)
	if tag == 10001 then
		self._scene:onQueryExitGame()
	elseif tag == 10002 then
		print("BT_SWITCH")
		self:onButtonSwitchAnimate()
	elseif tag == 10003 then

		self.b_showHelp = true
		HelpLayer:create(self)
				 	 :addTo(self,MAXZORDER+2)
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

function GameViewLayer:registerTouch()

	local function onTouchBegan( touch, event )
			return self:isVisible()
		end
		local function onTouchEnded( touch, event )
			if self.btPanel:isVisible() == true then
				self:onButtonSwitchAnimate()
			end	
		end
	
		local listener = cc.EventListenerTouchOneByOne:create();
		listener:setSwallowTouches(true)
		self.listener = listener;
		listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN );
		listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED );
		local eventDispatcher = self:getEventDispatcher();
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);
end

return GameViewLayer
