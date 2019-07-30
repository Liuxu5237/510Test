--导入游戏逻辑文件

--创建GameViewLayer
local GameViewLayer = class("GameViewLayer",function(scene)
		local gameViewLayer =  display.newLayer()
    return gameViewLayer
end)
--导入游戏逻辑文件
local module_pre = "game.yule.panjinlian.src"

local ExternalFun =  appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

local HeadSprite = appdf.req(appdf.EXTERNAL_SRC .. "HeadSprite")
local g_var = ExternalFun.req_var
local cmd = module_pre .. ".models.CMD_Game"
local GameNotice = appdf.req(appdf.BASE_SRC .."app.views.layer.other.GameNotice")
local HelpLayer = appdf.req(module_pre..".views.layer.HelpScene")
local MinGameLayer = appdf.req(module_pre .. ".views.layer.MinGameScene")
local GameFrameEngine = appdf.req(appdf.CLIENT_SRC.."plaza.models.GameFrameEngine")
local QueryDialog = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.QueryDialog")

GameViewLayer.RES_PATH = "game/yule/panjinlian/res/"

local MAX_LINE = 9
local C_PAN_SUM = 15
local MAX_BET_LEVEL = 5

local index_5ofkind = 0
local MAXZORDER=999999
local SettlementScheduler  = nil
local win_index = 0
local Indexaa1 = 0
--各种变量
local _SoundID = nil; 
local  IsPlay = nil;

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
	self.BonusSchedulerEntry =nil ----彩金定时器

	self.BonusText = 0
	self.Random_Jackot = 0
	self.Major = 0
	self.Minor = 0
	--各种婊
	self.table_CardPans = {}  -- 15 个容器
	self.table_line_nums = {}
	self.table_lines = {}
	self._gameFrame = GameFrameEngine:getInstance()
	local tmp_roomLevel =self._gameFrame._roomInfo.wServerLevel
	self.table_LineBet = {1000,2000,3000,4000,5000}
    if tonumber(tmp_roomLevel) == 1 then
        self.table_LineBet = {1000,2000,3000,4000,5000}
    elseif tonumber(tmp_roomLevel) == 2 then 
        self.table_LineBet = {10000,20000,30000,40000,50000}
    elseif tonumber(tmp_roomLevel) == 3 then 
        self.table_LineBet = {100000,200000,300000,400000,500000}
    elseif tonumber(tmp_roomLevel) == 4 then 
        self.table_LineBet = {500000,1000000,1500000,2000000,2500000}
    end
	
	self.table_ico = {}
	self.table_logic = {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}}
	self.table_win_lines = {}
	self.table_win_rate = {}
	self.table_win_point = {}
	self.table_show_cards = {}
	self.table_scatter_point = {}
	self.table_card_frame = {}
	self.table_temp_Card5 = {}
	self.table_free_Card5 = {}

	--Buttons
	self.btn_MinGame = nil
	self.btn_spin = nil
	self.btn_stop = nil
	self.btn_auto_spin = nil
	self.btn_auto_stop = nil
	self.btn_bet_add = nil
	self.btn_bet_sub = nil
	self.gameBroadCast = nil

	---全盘
	self.isAllwin = false
	self.AllSceneVal = nil
	----
	---中奖5 个 state
	self.isFive_state = false

	------
	self.bFiveLine = false

	-------------------------------- --BigWin赋值
	self.spBigWin = nil;
	self.GameBigWin = false;
	self.BigWinOK = false;
	----------
	self.AniFiveLine = nil 
	-- ----------------------------- 彩金赋值
	-- self.BonusRandomText = 0 --彩金转动触发
	-- self.Random_JackotText = 0;
	-- self.MajorText = 0;
	-- self.MinorText = 0;
	-- --Jackpot
	-- self.Game_Jackpot ={};
	-- self.JackpotPanel = nil
	-- self.JackpotMajor = nil
	-- self.JackpotMinor = nil
	-- self.JackpotRandom = nil
	-- self.JackpotXing = nil
	-- self.JackpotJinbi = nil
	-- self.GameJackotTag = false
	-- self.GameRandomJackot = false
	-- self.GameMinorJackot = false
	-- self.GameMajorJackot = false
	-- self.JackpotText = nil
	-- self.JackpotTextNum = 0
	-- self.JackpotTextID = 0
	-- ---------
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
	self.Sp_state = nil 
	self.State_Of = nil  
	self.NumOr_sp = nil 
	self.sp_CallBack = nil
	self.lines = MAX_LINE
	self.bet_level = 1
	self.line_bet = self.table_LineBet[self.bet_level]
	self.line_bet_last = 0
	self.sum_bet = self.line_bet*MAX_LINE
	self.win_bet = 0
	self.scatter_num = 0
	self.free_bg = nil
	self.free_count = 0
	self.free_count_max = 0
	self.free_game_sp = nil
	self.free_game_bgsp = nil
	self.free_game_RotateNumBG = nil
	self.CloseWin_sp = nil --免费旋转 结算版
	self.Linse_WinMun = 0
	self.DaGuiAirStopTime = 0

	--各种Text
	self.text_Scatter_to = nil 
	self.text_line_bet = nil
	self.text_sum_bet = nil
	self.text_win_bet = nil
	self.text_credit = nil
	self.mun_time_s = nil
	self.mun_max_val = nil
	self.test_CloseWin_val = nil  --免费旋转结算版的值

	--各种开关
	self.isAuto = false
	self.isRoll = false
	self.isMsg = false
	self.isFree = false
	self.isUpdataFree_val = false
	self.isAotuOr = false 
	self.isFree_Fnew = false
	self.isNotMsgAoyu = false
	self.GameOldSocre = 0
	---
	--最大押注
	self.btn_maxBet = nil
	self.GameRollFunNum = 0
	self.BalanceText = GlobalUserItem.lUserScore
end

function GameViewLayer:preloadUI(  )
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
	AudioEngine.stopMusic()
end

  ---self.Linse_WinMun
 function GameViewLayer:ButtonClick(sender,tag)
	--if eventType == ccui.TouchEventType.ended and sender:isEnabled() then
		if sender:getName() == "btn_spin" then
			--AudioEngine.playEffect("AudioClip/btn_io.mp3")
			self.isAotuOr = true
			if not self.isRoll then
				self:SendRoll()
			end
			self:StopMusic(true)
		elseif sender:getName() == "btn_stop" then
			--AudioEngine.playEffect("AudioClip/btn_io.mp3")
			sender:setEnabled(false):setBright(false):setVisible(false)
			self:StopRoll()
			self:DoWin()
			self:StopMusic(true)
		elseif sender:getName() == "btn_bet_add" then
			--AudioEngine.playEffect("AudioClip/btn_Other.mp3");
			self.bet_level = self.bet_level + 1
			if self.bet_level ==MAX_BET_LEVEL  then
				self.btn_bet_add:setEnabled(false)
				self.btn_bet_add:setBright(false)
			end
			if self.bet_level > MAX_BET_LEVEL then
				self.bet_level = 1
			end
			if self.bet_level == 1 then
				self.btn_bet_sub:setBright(false):setEnabled(false)
			else
				self.btn_bet_sub:setBright(true):setEnabled(true)
			end
			self.line_bet = self.table_LineBet[self.bet_level]
			self.sum_bet = self.line_bet*MAX_LINE
			self:UpdateText()
			self:StopMusic(false)
			--self:GameJackpot(3)
		elseif sender:getName() == "btn_bet_sub" then
			--AudioEngine.playEffect("AudioClip/btn_Other.mp3")
			self.bet_level = self.bet_level - 1
			if self.bet_level <= 1 then
				self.bet_level = 1
				sender:setBright(false):setEnabled(false)
			end
			self.btn_bet_add:setEnabled(true):setBright(true)
			--self:BroadCastMsg(1,"我在马路边捡到一块钱，交给警察叔叔手里边，警察卖了一包烟，警察不要脸")
			self.line_bet = self.table_LineBet[self.bet_level]
			self.sum_bet = self.line_bet*MAX_LINE
			self:UpdateText()
			self:StopMusic(false)
		elseif sender:getName() == "btn_auto" then
			--AudioEngine.playEffect("AudioClip/btn_Other.mp3")
			self.isAuto = true
			self.isAotuOr = false
			self:SendRoll()
			self.btn_auto_stop:setVisible(true)
			self:StopMusic(false)
		elseif sender:getName() == "btn_autostop" then
			--AudioEngine.playEffect("AudioClip/btn_Other.mp3")
			
			if self.isMsg then
				self.isAuto = false
				sender:setVisible(false)
				--self:stopAllActions()
				if self.isRoll then
					self.btn_stop:setEnabled(false):setBright(false):setVisible(false)
					self:StopRoll()
					self:DoWin()
				else
					if false == self.bFiveLine and false == self.GameJackotTag then 
						self:ButtonControl(true)
					end
				end
			-- else
			-- 	--self.isAuto = false
			-- 	self.isNotMsgAoyu = true
			-- 	self.btn_auto_stop:setVisible(false)
			-- 	self.btn_auto_spin:setVisible(true)
			end
			self:StopMusic(false)
		elseif sender:getName() == "btn_MinGame" then
			--AudioEngine.playEffect("AudioClip/btn_Other.mp3")
			--self:CleanWin()
			self.btn_MinGame:setPosition(1460,220)
			--self.text_win_bet:setVisible(false)
			MinGameLayer.soltWin = self.win_bet
			self.minLayer = MinGameLayer:create(self)
			:addTo(self,10)
			--require("app.views.MinGameScene").soltWin = self.win_bet
			--local view = self:getApp():createView("MinGameScene")
			--local scene = display.newScene("MinGameScene")
			--scene:addChild(view)
			--cc.Director:getInstance():pushScene(scene)
			self:StopMusic(false)
		elseif sender:getName() == "btn_maxBet" then
			self.bet_level = MAX_BET_LEVEL
			self.line_bet = self.table_LineBet[self.bet_level]
			self.sum_bet = self.line_bet*MAX_LINE
			if self.bet_level ==MAX_BET_LEVEL  then
				self.btn_bet_add:setEnabled(false)
				self.btn_bet_add:setBright(false)
				self.btn_bet_sub:setEnabled(true):setBright(true)
			end
			self:UpdateText()
			self:StopMusic(false)
		end
		self:cleanBigwin()
	--end
end

function GameViewLayer:initUi()
	--好像是系统帮助按钮 可以保留  suan le 去掉吧
	--require("src.views.system"):initLayer(self)
	--require("src.views.system"):SetVisible(self,false)
	--节点事件
	local function onNodeEvent(event)
		if event == "exit" then
			self:onExit()
		end
	end
	self:registerScriptHandler(onNodeEvent)
	
	self._csbNode = cc.CSLoader:createNode("MainScene.csb")
		:addTo(self, 1)

	self.free_game_sp = cc.Sprite:create()
	self.free_game_sp:setPosition(320,655):setVisible(false)  --feer_game_sp.png
	self:addChild(self.free_game_sp)
	self.sp_CallBack = cc.Sprite:create()
	self:addChild(self.sp_CallBack)
	self.free_game_bgsp = cc.Sprite:create("feer_game_sp.png")
	self.free_game_bgsp:setPosition(640,360):setVisible(false)  
	self:addChild(self.free_game_bgsp)

	--
	self.btn_MinGame = self._csbNode:getChildByName("btn_MinGame")
	self.btn_MinGame:setAnchorPoint(cc.p(0.5,0.5)):setPosition(1460, 220)
	self.btn_MinGame:setVisible(true)
	--self:addChild(self.btn_MinGame)
	--self.btn_MinGame:setTouchEnabled(false)
	--self.btn_MinGame:setBright(false)

	----  空格控制
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if (cc.PLATFORM_OS_WINDOWS == targetPlatform)   then 
		local function onKeyPressed(key, event)
	        local target = event:getCurrentTarget()
			release_print("key::"..key);
	       	if key== 59 then 
	       		 if self.btn_stop:isVisible() then 
					release_print("按键停止")
					self.ButtonClick(self.btn_stop, ccui.TouchEventType.ended) 
	       		 	--执行停止
	       		 	return
	       		 end 
	       		 if self.btn_spin:isEnabled() then
	       		 	--执行spin
					release_print("按键滚动")
					self.ButtonClick(self.btn_spin, ccui.TouchEventType.ended) 
	       		 	return
	       		 end
	       	end
	    end

	    local keyboardEventListener = cc.EventListenerKeyboard:create()
	    keyboardEventListener:registerScriptHandler(onKeyPressed, cc.Handler.EVENT_KEYBOARD_PRESSED )
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:addEventListenerWithSceneGraphPriority(keyboardEventListener:clone(), self)
	end
	------

	for i=1,C_PAN_SUM do
		table.insert(self.table_CardPans,self._csbNode:getChildByName("pan_"..i))
		table.insert(self.table_card_frame,self._csbNode:getChildByName("card_farme_"..i))
	end

	for i=1,5 do
		local sp_card = cc.Sprite:create("Ani/DH_11/air_free/21.png")
		sp_card:setPosition(self.table_CardPans[i+5]:getPositionX()+80.5,self.table_CardPans[i+5]:getPositionY()+72.5):setVisible(false)
		self._csbNode:addChild(sp_card)
		table.insert(self.table_free_Card5,sp_card)
	end

	for i=1,5 do
		local sp_card = cc.Sprite:create("Ani/DH_11/air_card9/20.png")
		sp_card:setPosition(self.table_CardPans[i+5]:getPositionX()+80.5,self.table_CardPans[i+5]:getPositionY()+72.5):setVisible(false)
		self._csbNode:addChild(sp_card)
		table.insert(self.table_temp_Card5,sp_card)
	end

	for i=1,MAX_LINE do
		table.insert(self.table_line_nums,self._csbNode:getChildByName("lb_"..i))
		table.insert(self.table_lines,self._csbNode:getChildByName("line"..i))
	end
	self.mun_time_s = self._csbNode:getChildByName("mun_time_s")
	self.mun_max_val = self._csbNode:getChildByName("mun_max_val")
	self.NumOr_sp =  self._csbNode:getChildByName("NumOr_sp")
	self.free_game_RotateNumBG = self._csbNode:getChildByName("RotateNumBG_sp")   -- AtlasLabel_1

	-- for i=1,5 do
	-- 	local sp_card = cc.Sprite:create()
	-- 	sp_card:setPosition(self.table_CardPans[i+5]:getPositionX()+80.5,self.table_CardPans[i+5]:getPositionY()+72.5)
	-- 	self._csbNode:addChild(sp_card)
	-- 	table.insert(self.table_temp_Card5,sp_card)
	-- end
	self.CloseWin_sp = self._csbNode:getChildByName("CloseWin_sp")
	self.free_bg = self._csbNode:getChildByName("mainbg_2")
	----Button
	self.btn_spin = self._csbNode:getChildByName("btn_spin")
	self.btn_stop = self._csbNode:getChildByName("btn_stop")
	self.btn_auto_spin = self._csbNode:getChildByName("btn_auto")
	self.btn_auto_stop = self._csbNode:getChildByName("btn_autostop")
	self.btn_bet_add = self._csbNode:getChildByName("btn_bet_add")
	self.btn_bet_sub = self._csbNode:getChildByName("btn_bet_sub")
	self.btn_maxBet = self._csbNode:getChildByName("btn_maxBet")
	local  btcallback = function(ref, type)
        if type == ccui.TouchEventType.ended then
         	self:ButtonClick(ref,ref:getTag())
        end
	end
	
	self.btn_spin:addTouchEventListener(btcallback)
	self.btn_stop:addTouchEventListener(btcallback)
	self.btn_auto_spin:addTouchEventListener(btcallback)
	self.btn_auto_stop:addTouchEventListener(btcallback)
	self.btn_bet_add:addTouchEventListener(btcallback)
	self.btn_bet_sub:addTouchEventListener(btcallback)
	self.btn_MinGame:addTouchEventListener(btcallback)
	self.btn_maxBet:addTouchEventListener(btcallback)
	----Button

	----Text
	self.text_Scatter_to = self._csbNode:getChildByName("RotateNumBG_sp"):getChildByName("AtlasLabel_1")
	self.text_line_bet = self._csbNode:getChildByName("text_bet")
	self.test_CloseWin_val = self._csbNode:getChildByName("CloseWin_sp"):getChildByName("test_CloseWin_val")
	self.text_sum_bet = self._csbNode:getChildByName("text_sum_bet")
	self.text_win_bet = self._csbNode:getChildByName("text_win")
	self.text_win_bet:setVisible(false)
	self.text_credit = self._csbNode:getChildByName("text_credit")
	local str = ExternalFun.numberThousands(self.BalanceText);
	self.text_credit:setString(str)
	
	self:InitCards()
	self:UpdateText()
	self:CreateAnimation()

	--五连中
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("Jackpot/5ofkind.ExportJson")

	--彩金表现
	self.JackpotPanel = cc.CSLoader:createNode("Jackpot/JackpotScene.csb")
	local Jackpot = self.JackpotPanel:getChildByName("Jackpot"):setVisible(false)
	local JackpotPanel = self.JackpotPanel:getChildByName("JackpotPanel")
	self.Random_JackotText = JackpotPanel:getChildByName("JackpotTest_Random"):setVisible(false) 
	self.MajorText = JackpotPanel:getChildByName("JackpotTest_Major"):setVisible(false) 
	self.MinorText = JackpotPanel:getChildByName("JackpotTest_Minor"):setVisible(false)

	self.JackpotMajor = self.JackpotPanel:getChildByName("MajorJackpot")
	self.JackpotMinor = self.JackpotPanel:getChildByName("MinorJackpot")
	self.JackpotRandom = self.JackpotPanel:getChildByName("RandomJackpot")
	self.JackpotXing = self.JackpotPanel:getChildByName("XingJackpot")
	self.JackpotText = self.JackpotPanel:getChildByName("JackpotText")
	self.JackpotJinbi = self.JackpotPanel:getChildByName("Jinbi")
	self:addChild(self.JackpotPanel)

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
	--广播去掉
	--self:BroadCastInit()
	
	self:GameBetIndex()

	local systemBtn = false
	local systemNum = os.date("%m", os.time())
	if tonumber(systemNum) > 5 then
		systemBtn = true
	end
	if self.BalanceText < self.table_LineBet[1]*MAX_LINE then
		self:ButtonControl(false)
	end

	self:GameBJMp3()

	self:initButton()
	self:onUpdateUserInfo()
	--self:addChild(JackpotLayer)
	--self._csbNode:addChild(JackpotLayer)
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

function GameViewLayer:GameBigWinMp3()
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

local is_moveVal = false
local function SettlementNum()
	is_moveVal = false
	self.test_CloseWin_val:setVisible(true)
	--print("···滚动分板self.win_bet..."..self.win_bet)
	if self.win_bet > 0 and not is_moveVal then
		Indexaa1 = self.win_bet/30
		is_moveVal = true
	-- else
	-- 	Indexaa1 = self.win_bet/50
	end
	
	--T_num = 30
	--print("................self.text_win_bet:getString()......"..self.text_win_bet:getString())
	if win_index >= self.win_bet then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(SettlementScheduler)
		SettlementScheduler = nil
	else
		win_index = win_index + Indexaa1
	end

	if win_index < self.win_bet then
		--print("···.......win_index....."..win_index)
	 	self.test_CloseWin_val:setString(win_index)
	else
		--print("···........self.win_bet........"..self.win_bet)
	 	self.test_CloseWin_val:setString(self.win_bet)
	 	self:NewManny()
	end
end

--免费结束播放赢了多少
function GameViewLayer:playWinAnim(numbWin)
	local text=0
	if numbWin > 0 and numbWin < 100 then
		self.stepWin = 1;
	elseif numbWin >= 100 and numbWin < 1000 then
		self.stepWin = 15;
	elseif numbWin >= 1000 and numbWin < 10000 then
		self.stepWin = 121;
	elseif numbWin >= 10000 and numbWin < 100000 then 
		self.stepWin = 1211;
	elseif numbWin >= 100000 and numbWin < 1000000 then
		self.stepWin = 12111;
	elseif numbWin >= 1000000 and numbWin < 10000000 then
		self.stepWin = 121111;
	elseif numbWin >= 10000000 then
		self.stepWin = 1211111;
	end

	self.test_CloseWin_val:setVisible(true)
	self.test_CloseWin_val:setString(text)

	--local VoiceWinGold = AudioEngine.playEffect("AudioClip/Score.mp3",true) 
	self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
		text = text+self.stepWin
		self.test_CloseWin_val:setString(text)

		if(text>=numbWin)then
			self.test_CloseWin_val:setString(numbWin)
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
			self:NewManny()
			--AudioEngine.stopEffect(VoiceWinGold)
		end 
	end, 0.02, false)  

end

------上分刷新分数
function GameViewLayer:GameUserScore()
	if( not self.isRoll) then  --如果滚动就忽略
		--require("app.views.system"):updateScore(self)
		local str = ExternalFun.numberThousands(self.BalanceText);
		self.text_credit:setString(str)
	end 
end
------
function GameViewLayer:GameBetIndex() --自动判断当前余额能否押注，押不了，自动降低Bet值 
	--system:updateScore(self)--更新用户积分
	if self.isFree == false then
		if self.BalanceText < self.table_LineBet[1]*MAX_LINE then
			self:ButtonControl(true);
		else
			if self.BalanceText < self.table_LineBet[self.bet_level]*MAX_LINE then
				if self.bet_level > 1 then
					self.bet_level = self.bet_level - 1;
					self:UpdateText()
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
------

-------------  广播 
function GameViewLayer:BroadCastInit()
	print("只初始化一次")
    self.gameBroadCast = GameBroadCast:create()
    --GameBroadCast:setGameCtrlLayer(self)
    self.gameBroadCast:init(540)
    self.gameBroadCast:setVisible(false)
   	self:addChild(self.gameBroadCast)
end
function GameViewLayer:BroadCastMsg(_count,_msg)
    self.gameBroadCast:getBroad(_count,_msg)
    self.gameBroadCast:setVisible(true)
    self.gameBroadCast:textRunAction()
end
--------------

function GameViewLayer:StopMusic(isf_t)
	if isf_t then
		AudioEngine.playEffect("AudioClip/btn_io.mp3")
	else
		AudioEngine.playEffect("AudioClip/btn_Other.mp3");
	end
end


function GameViewLayer:ButtonControl(isEnabled)
	self.btn_spin:setEnabled(isEnabled):setBright(isEnabled)
	self.btn_auto_spin:setEnabled(isEnabled):setBright(isEnabled)
	self.btn_bet_add:setEnabled(isEnabled):setBright(isEnabled)
	self.btn_maxBet:setEnabled(isEnabled):setBright(isEnabled)
	if self.bet_level ~= 1  then
		self.btn_bet_sub:setEnabled(isEnabled):setBright(isEnabled)
	end
	if self.bet_level ==table.getn(self.table_LineBet)  then
		self.btn_bet_add:setEnabled(false)
		self.btn_bet_add:setBright(false)
		self.btn_bet_sub:setEnabled(true):setBright(true)
	end
end
-- function GameViewLayer:ButtonControl_JP(isEnabled)
-- 	self.btn_spin:setEnabled(isEnabled):setBright(isEnabled)
-- 	self.btn_auto_spin:setEnabled(isEnabled):setBright(isEnabled)
-- 	self.btn_bet_add:setEnabled(isEnabled):setBright(isEnabled)
-- 	if self.bet_level ~= 1 then
-- 		self.btn_bet_sub:setEnabled(isEnabled):setBright(isEnabled)
-- 	end
-- end
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
--通用---------------------------------------------------------------------------------

function GameViewLayer:InitR_oncreate()
	if self.isFree_Fnew then
		self:R_oncreate()
	else
		self:InitCards()
	end
end

function GameViewLayer:CreateAnimation()
	for f_i=0,10 do
		local ani_temp = cc.Animation:create()
		local count = 23
		if f_i == 8 then count = 6 end
		for p_i = 1 ,count do
			ani_temp:addSpriteFrameWithFile(string.format("Ani/DH_%d/%d.png",f_i,p_i))
		end
		ani_temp:setDelayPerUnit(0.1)
		ani_temp:setLoops(998)
		cc.AnimationCache:getInstance():addAnimation(ani_temp,string.format("DH_%d",f_i))
	end

	local ani_card_frame = cc.Animation:create()
	for i=1,7 do
		ani_card_frame:addSpriteFrameWithFile(string.format("card_frame/%d.png",i))
	end
	ani_card_frame:setDelayPerUnit(0.1)
	ani_card_frame:setLoops(998)
	cc.AnimationCache:getInstance():addAnimation(ani_card_frame,"ani_cf")
	local ani_card8_fram = cc.Animation:create()
	for i=1,6 do
		ani_card8_fram:addSpriteFrameWithFile(string.format("Ani/DH_8/%d.png",i))
	end
	ani_card8_fram:setDelayPerUnit(0.08)
	ani_card8_fram:setLoops(1)
	ani_card8_fram:setRestoreOriginalFrame(true)  --是否初始状态
	cc.AnimationCache:getInstance():addAnimation(ani_card8_fram,"ani_cf8")
	local ani_card11_fram = cc.Animation:create()
	for i=1,21 do
		ani_card11_fram:addSpriteFrameWithFile(string.format("Ani/DH_11/air_free/%d.png",i))
	end
	ani_card11_fram:setDelayPerUnit(0.1)
	ani_card11_fram:setLoops(1)
	--ani_card11_fram:setRestoreOriginalFrame(true)
	cc.AnimationCache:getInstance():addAnimation(ani_card11_fram,"ani_cf11")

	local ani_card9 = cc.Animation:create()
	for i=1,20 do
		ani_card9:addSpriteFrameWithFile(string.format("Ani/DH_11/air_card9/%d.png",i))
	end
	ani_card9:setDelayPerUnit(0.15)
	ani_card9:setLoops(1)
	--ani_card9:setRestoreOriginalFrame(true)
	cc.AnimationCache:getInstance():addAnimation(ani_card9,"ani_card9")


	local ani_free_game = cc.Animation:create()
	for i=1,25 do
		ani_free_game:addSpriteFrameWithFile(string.format("Ani/TopScatter/%d.png",i))
	end
	ani_free_game:setDelayPerUnit(0.15)
	ani_free_game:setLoops(998)
	ani_free_game:setRestoreOriginalFrame(true)
	cc.AnimationCache:getInstance():addAnimation(ani_free_game,"free_game")

end

function GameViewLayer:UpdateText()
	self.text_line_bet:setString(self.line_bet)
	self.text_sum_bet:setString(self.sum_bet)
end

function GameViewLayer:InitCards()
	print("初始化卡")
	print("没有收到断线从连消息")
	for i,pan in pairs(self.table_CardPans) do
		local card = cc.Sprite:create("card/9.png")
		card:setAnchorPoint(0,0):setPosition(0,0):setTag(1)
		pan:addChild(card)
	end
end

function GameViewLayer:InitCards_Fnew()  --断线从连，上一把，的牌
	print("11111111111111111收到断线从连消息")
	print("self.table_CardPans...LONGHT..."..#self.table_CardPans)
	for i,pan in pairs(self.table_CardPans) do
		if i<=15 then
			print("self.table_ico%d....",i..self.table_ico[i])
			local card = cc.Sprite:create("card/"..self.table_ico[i].."_f.png")  --self.table_ico
			card:setAnchorPoint(0,0):setPosition(0,0):setTag(1)
			pan:addChild(card)
		end
	end
end

local tape_count = {1,4,7,10,13,2,5,8,11,14,3,6,9,12,15}

-- local aa={11,14,17,20,23,12,15,18,21,24,13,16,19,22,25}

function GameViewLayer:InitTape()   -- 新的胶带

	if self.isAllwin then
		tape_count = {1,0,0,0,4,2,0,0,0,5,3,0,0,0,6}
	else
		tape_count = {1,4,7,10,13,2,5,8,11,14,3,6,9,12,15}
	end
	-- if not self.isFree then
	-- 	tape_count = {1,4,7,10,13,2,5,8,11,14,3,6,9,12,15}
	-- else
	-- 	tape_count = {21,24,27,30,33,22,25,28,31,34,23,26,29,32,35}
	-- end

	for p_i,pan in pairs(self.table_CardPans) do
		local tape = cc.Sprite:create()
		local s_tape = nil 
		for t_i=1,tape_count[p_i] do
			if not self.isFree then 
				s_tape = cc.Sprite:create("card/tape_"..math.random(1,8)..".png")
			else 
				s_tape = cc.Sprite:create("card/tape_ani"..math.random(1,8)..".png")
			end 
			s_tape:setAnchorPoint(0,0):setPosition(0,(t_i-1)*145*2)
			tape:addChild(s_tape)
		end
		tape:setAnchorPoint(0,0):setPosition(0,145):setTag(2)
		pan:addChild(tape)
	end
end

function GameViewLayer:initNewCard(isStop) --初始化 新卡

	for i,pan in pairs(self.table_CardPans) do
		local card = nil
		if self.isFree then
			card = cc.Sprite:create("card/"..self.table_ico[i].."_f.png")
		else
			card = cc.Sprite:create("card/"..self.table_ico[i]..".png")
		end
		card:setName(self.table_ico[i])
		if isStop then
			card:setAnchorPoint(0,0):setPosition(0,0):setTag(1)
		else
			card:setAnchorPoint(0,0):setPosition(0,145+tape_count[i]*145*2):setTag(3)
		end
		pan:addChild(card)
	end
end

local Roll_num = 2 --没收到服务器数据时，免费旋转的胶带段
function GameViewLayer:OffLineRoll(num)
	self.GameRollFunNum = self.GameRollFunNum + 1
	if not(self.GameRollFunNum == 1) then
		for indexKey,pan_1 in pairs(self.table_CardPans) do
			for key,value in pairs(pan_1:getChildren()) do
				if 1 == #pan_1:getChildren() then -- 只留最后一个
					value:stopAllActions();
					value:setTag(1)
					break;
				else
					value:removeFromParent();
				end
			end
		end
	end

	if self.isMsg then
		--print("进入有网旋转")
		self:Rolling(self.table_ico,self.win_bet)
		return;
	end

	for p_i,pan in pairs(self.table_CardPans) do
		local tape = cc.Sprite:create()
		local s_tape = nil 
		for t_i=1,Roll_num do
			if not self.isFree then 
				s_tape = cc.Sprite:create("card/tape_"..math.random(1,8)..".png")
			else 
				s_tape = cc.Sprite:create("card/tape_ani"..math.random(1,8)..".png")
			end 
			s_tape:setAnchorPoint(0,0):setPosition(0,(t_i-1)*145*Roll_num)  --加胶带
			tape:addChild(s_tape)
		end
		tape:setAnchorPoint(0,0):setPosition(0,145)
		pan:addChild(tape)
	end

	for p_i,pan in pairs(self.table_CardPans) do 
		for c_i,card in pairs(pan:getChildren()) do
			local mov = cc.MoveBy:create(0.06*(2*Roll_num),cc.p(0,-145*(2*Roll_num)))
			
			local movUp2 = cc.MoveBy:create(0.3,cc.p(0,20))--结束回弹
			local seq = nil
			local seq2 = nil

			if num == 1 then
				seq = cc.Sequence:create(movUp2,mov);
			else
				seq = cc.Sequence:create(mov);
			end
			seq2 = cc.Sequence:create(seq,cc.CallFunc:create(function()
				self:OffLineRoll(2)
			end));

			--local seq = cc.Sequence:create(mov);
			--local seq2 = cc.Sequence:create(mov,cc.CallFunc:create(self:OffLineRoll));

			card:stopAllActions();
			if c_i ==#pan:getChildren() then
				card:runAction(seq2)
			else
				card:runAction(seq)
			end
		end
	end
end

function GameViewLayer:SendRoll() --点击开始按钮执行
	self:GameBetIndex()
	if self.isFree then
		if self.free_count > 0 then  
			self.free_count = self.free_count - 1
		end
		self.mun_time_s:setString(string.format(self.free_count))
	elseif (not self.isFree)  and (GlobalUserItem.lUserScore < self.sum_bet) then
		--self.text_credit:setString(UserInfo:instance():getScore() - self.sum_bet)
		--release_print("===================== spined to Val------"..UserInfo:instance():getScore());
		--release_print("================= self.sum_bet------"..self.sum_bet);
		print("进来了买")
		QueryDialog:create("你的金币不足,是否充值",function(bReTry)
			if bReTry == true then
				--self:requestServerConfig()
			else
				return;
			end
		 end)
		 :addTo(self,1000)
		 self:ButtonControl(true);
		 return;
	end
	if self.AllSceneVal ~= nil then
		self.AllSceneVal:removeFromParent(true)
		self.AllSceneVal = nil
	end
	index_5ofkind = 0 
	--self.win_bet = 0
	self.GameOldSocre = self.BalanceText
	self:CleanWin()
	self:cleanBigwin()
	self.btn_MinGame:stopAllActions()
	self.btn_MinGame:setEnabled(false)
	self.btn_MinGame:setPosition(1460,220) 
	self:ButtonControl(false)
	self.btn_stop:setEnabled(false):setBright(false)
	if not self.isFree then
		self.text_win_bet:setVisible(false)
	end
	if self.AniFiveLine and not tolua.isnull(self.AniFiveLine) then
		self.AniFiveLine:removeFromParent(true);
	end
	self.line_bet_last = self.line_bet
	self.isRoll = true
	self.isMsg = false
	self.isAllwin = false
	self.bFiveLine = false
	self.isNotMsgAoyu = false
	self.isFive_state = false
	self.GameJackotTag = false
	--print("self.line_bet.......######......."..self.line_bet)
	self._scene:startGame(self.lines,self.sum_bet,self.line_bet,self.isFree) --发送消息给服务器
	self.GameRollFunNum = 0
	self:OffLineRoll(1)
	--AudioEngine.playEffect("AudioClip/Spining.mp3")
end

function GameViewLayer:CleanWin() --停止边框数字闪动和线的闪动
	AudioEngine.stopAllEffects();
	--self:stopAllEffectsByZ()
	self:stopAllActions()
	self.sp_CallBack:stopAllActions()
	for i,line_num in pairs(self.table_line_nums) do   
		line_num:stopAllActions():setVisible(false)
	end
	for i,line_num in pairs(self.table_lines) do   
		line_num:stopAllActions():setVisible(false)
	end

	for i,frame in pairs(self.table_card_frame) do
		frame:stopAllActions():setVisible(false)
	end
	for i=1 , 5 do
		self.table_temp_Card5[i]:stopAllActions()
		self.table_temp_Card5[i]:setVisible(false) --self.table_free_Card5
	end
	for i=1 , 5 do
		self.table_free_Card5[i]:stopAllActions()
		self.table_free_Card5[i]:setVisible(false) --self.table_free_Card5
	end
	--------------------------
	self.Game_Jackpot ={};

	if self.JackpotWinMps then
		AudioEngine.stopEffect(self.JackpotWinMps);
	end
	if self.GameJackotTag then
		self.JackpotRandom:setVisible(false);
		self.JackpotMinor:setVisible(false);
		self.JackpotMajor:setVisible(false);
		self.JackpotXing:setVisible(false);
		self.JackpotText:setVisible(false);
		self.JackpotJinbi:setVisible(false);
	end
	self.JackpotTextNum = 0;
	self.JackpotTextID = 0;
end


function GameViewLayer:NewManny()
	local str = ExternalFun.numberThousands(self.BalanceText);
	self.text_credit:setString(str)
end 
local isuuuu = false
local time_msg = 0
local ininin  =  0
function GameViewLayer:StartRoll(ico,win)
	--self:NewManny()
	print("----------------图标显示--------------")
	for i = 1, 3 do
		local strIcons = ""
		for j = 1, 5 do
			strIcons = strIcons .. "  " .. ico[(i-1)*5+j]
		end
		print(i .. "   ".. strIcons)
	end
	print("----------- 输赢："..win)

	self.table_ico = {}
	self.table_ico = ico
	self.win_bet = win
	time_msg = 0

	release_print("···-----------------------------------------------服务器发来的钱Win-------------------------"..win)

	if self.table_ico[2] == 9 and self.table_ico[3] == 9 and self.table_ico[4] == 9 and self.table_ico[7]== 9 and self.table_ico[8]== 9 and self.table_ico[9]== 9 and self.table_ico[12]== 9 and self.table_ico[13]== 9 and self.table_ico[14]== 9 then
		self.isAllwin = true	
		local TempIco = self.table_ico[1] 
		if TempIco == self.table_ico[1] and TempIco == self.table_ico[5] and TempIco == self.table_ico[6] and TempIco == self.table_ico[10] and TempIco == self.table_ico[11] and TempIco == self.table_ico[15] then
			self.AllSceneVal = TempIco
		else
			self.AllSceneVal = nil
		end
	end

	if self.isAllwin then 
		if self.AllSceneVal ~= nil then
			self.AllSceneVal = cc.Sprite:create("AllScene/AllSame_"..self.AllSceneVal..".png")
			self.AllSceneVal:setPosition(640,440):setVisible(false)
			self:addChild(self.AllSceneVal,999)
		end
	end

	if self.isFree then
		for i=1 , 5 do
			if self.table_ico[i] == 9  then
				if self.isAllwin then
					time_msg = 5
				else
					time_msg = 2
				end
				release_print("免费中 ==== 出现鬼的地方........."..i)
				AudioEngine.playEffect("AudioClip/Free_Card9.mp3");
				local Card_11 = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("ani_cf11"))
				local seq_ani = cc.Sequence:create(cc.CallFunc:create(function()
													self.table_free_Card5[i]:setVisible(true)
													end),Card_11,
													cc.DelayTime:create(time_msg+0.2),
													cc.CallFunc:create(function()
													if self.isAllwin then
														self.AllSceneVal:setVisible(true)
													end
													--self.table_free_Card5[i]:setVisible(false)
													end),
													nil)
				self.table_free_Card5[i]:runAction(seq_ani)
			end
		end
	else
		for i=1 , 5 do
			if self.table_ico[i] == 9 and self.table_ico[i+5] == 9 and self.table_ico[i+10] == 9 then
				if self.isAllwin then
					time_msg = 5
				else
					time_msg = 2
				end
				release_print("出现鬼的地方........."..i)
				AudioEngine.playEffect("AudioClip/_Card9.mp3");
				local Card_11 = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("ani_card9"))
				local seq_ani = cc.Sequence:create(cc.CallFunc:create(function()
													self.table_temp_Card5[i]:setVisible(true)
													end),Card_11,
													cc.DelayTime:create(time_msg-1),
													cc.CallFunc:create(function()
													if self.isAllwin then
														self.AllSceneVal:setVisible(true)
													end
													--self.table_temp_Card5[i]:setVisible(false)
													end),
													nil)
				self.table_temp_Card5[i]:runAction(seq_ani)
			end
		end
	end
	
	self:runAction(cc.Sequence:create(cc.DelayTime:create(time_msg),cc.CallFunc:create(function()
								-- if self.isNotMsgAoyu then
								-- 	self:StopRoll()
								-- 	self:Settlement()
								-- else
									if self.isFree then
										if not self.isUpdataFree_val then
											self.isUpdataFree_val = true
										end
									end 
									self.isMsg = true
									self.btn_stop:setEnabled(true):setBright(true):setVisible(true)
								-- end
								end),nil))

	if not self.isFree then
		local  str = ExternalFun.numberThousands(self.GameOldSocre - self.sum_bet);
		self.text_credit:setString(str)
		--release_print("===================== spined to Val------"..UserInfo:instance():getScore());
		--release_print("================= self.sum_bet------"..self.sum_bet);
	end
end

function GameViewLayer:R_oncreate()
	self.Linse_WinMun = 0
	--local MyApp = require("app.MyApp")
	if self._scene.nfreetime ~= nil then
		--print("MyApp.nfreetime.....·"..MyApp.nfreetime)
		self.free_count = self._scene.nfreetime
		self.free_count_max = self._scene.nfreetimemax 
		self.line_bet = self._scene.nlinebet 
		self.win_bet = self._scene.nFreeCountWin
		self.Linse_WinMun = self.win_bet
		self.table_ico = {}
 		self.table_ico = self._scene.icon
 		print("断线单线押注金额。。。。。。。。。。"..self.line_bet)
		 release_print("断线前总金额。。。。。。。。。。"..self.win_bet)
		 local  str = ExternalFun.numberThousands(self.BalanceText-self.win_bet);
		self.text_credit:setString(str)
 		for _i,_v in ipairs(self.table_LineBet) do
 			if _v == self.line_bet then 
 				self.bet_level = _i
 				self.line_bet = self.table_LineBet[self.bet_level]
				self.sum_bet = self.line_bet*MAX_LINE
				self:UpdateText()
 			end
 		end
 		self.text_win_bet:setString(self.win_bet):setVisible(true)
 		if  not self.isFree then
 			--require("app.views.system"):setBtnEnable(self,false)
 			self.free_bg:setVisible(true)
 			--self.free_game_bgsp:setVisible(true) 
 			self.mun_time_s:setString(string.format(self.free_count))
			self.mun_max_val:setString(string.format(self.free_count_max))
			self.mun_max_val:setVisible(true)
			self.mun_time_s:setVisible(true)
 		end		
 		self.isFree_Fnew = true 
 		self.isFree = true
 		--self.isMsg = true
 		for i,pan in pairs(self.table_CardPans) do
 			pan:removeAllChildren(true)
 		end
 		self:InitCards_Fnew()
 		print("断线从连")
 		self.isRoll = false
 		self.isAuto = true
 		local tipLayer = cc.CSLoader:createNode("credit/Reconnect.csb")
			local btn_continue = tipLayer:getChildByName("btn")
			btn_continue:addTouchEventListener(
				function(sender, eventType)
					if eventType == ccui.TouchEventType.ended then
						tipLayer:stopAllActions()
						tipLayer:removeFromParent(true)
						self.mun_time_s:setString(string.format(self.free_count))
						self.mun_max_val:setString(string.format(self.free_count_max))
						local seq = cc.Sequence:create(cc.DelayTime:create(1),
												cc.CallFunc:create(function()  
													AudioEngine.playMusic("AudioClip/Free_brack.mp3",true);
													if not self.isRoll then
														self:SendRoll()
													end
													self.free_game_sp:setVisible(true)
													local free_game_ani = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("free_game"))
													local seq_feer = cc.Sequence:create(cc.DelayTime:create(0.5),free_game_ani,nil)
													self.free_game_sp:runAction(seq_feer)
												end),cc.CallFunc:create(function() self.free_game_bgsp:setVisible(false)
												self.NumOr_sp:setVisible(true)
												 end)
												,nil)
						self:runAction(seq)
					end
				end)
				self:addChild(tipLayer,102)
	elseif not self.isFree_Fnew then
		self:InitCards()
	end 	
end
function GameViewLayer:Rolling(ico,win)
	print("GetMsg into rolling-------------------------------------------------------------------")
	for indexKey,pan_1 in pairs(self.table_CardPans) do
		local count = #pan_1:getChildren();
		--print("···indexKey.."..indexKey.."...count.."..count)
		for xx=count,1,-1 do
			if xx<= count-1 then
				pan_1:getChildren()[xx]:removeFromParent();
				break;
			end
		end
	end
	self:InitTape()  --收到服务器数据后创建新的胶带 2
	self:initNewCard(false)  --初始化 新卡 3
	--self.btn_stop:setEnabled(true):setBright(true)

	local function CardCallBack12(sender) --sender，谁在调用 sender 就是谁
		sender:removeFromParent(true) --删除节点
	end

	local last_count = 0
	local Card8_count = 0
	local function CardCallBack3(sender)
		last_count = last_count + 1
		sender:setTag(1)
		--print("last_coun>>>>>>>>>>>>>>>>>>>>>>>>.."..last_count)
		release_print("落下来次数.."..last_count)
		if last_count >= C_PAN_SUM then
			last_count = 0
			self.btn_stop:setEnabled(false):setBright(false):setVisible(false)
			self:DoWin()
		end
		--print("sender:getName():::"..sender:getName())
		if sender:getName() == "8" then
			--print("last_count:::"..last_count)
			Card8_count = Card8_count + 1;
			AudioEngine.playEffect("AudioClip/scatter_"..Card8_count..".mp3")
			local Card_8 = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("ani_cf8"))
			sender:runAction(Card_8)
			if Card8_count == 3 then
				AudioEngine.playEffect("AudioClip/scatter_cont.mp3")
			end
		end
	end

for i,pan in pairs(self.table_CardPans) do
		------
		local movUp = cc.MoveBy:create(0.1,cc.p(0,20))
		local movDown2 = cc.MoveBy:create(0.1,cc.p(0,-20))--结束回弹
		-- local seq = cc.Sequence:create(movUp,movDown2,cc.CallFunc:create(function()
		-- 	if i > 10 and i < 16 then
		-- 		AudioEngine.playEffect("AudioClip/Down_stop.mp3")
		-- 	end
		-- end),nil)
		------
		local moveby = cc.MoveBy:create(0.06*(tape_count[i]*2+1),cc.p(0,-145*(tape_count[i]*2+1)))
		local seq_1 = cc.Sequence:create(moveby:clone(),cc.CallFunc:create(CardCallBack12),nil)
		local seq_2 = cc.Sequence:create(moveby:clone(),cc.CallFunc:create(CardCallBack12),nil)
		local seq_3 = cc.Sequence:create(moveby:clone(),cc.CallFunc:create(function()
			if i > 10 and i < 16 then
				AudioEngine.playEffect("AudioClip/Down_stop.mp3")
			end
		end),movUp,movDown2,cc.CallFunc:create(CardCallBack3),seq,nil)
		pan:getChildByTag(1):runAction(seq_1)
		pan:getChildByTag(2):runAction(seq_2)
		pan:getChildByTag(3):runAction(seq_3)
	end
end

function GameViewLayer:StopRoll()
	AudioEngine.stopAllEffects();
	--self:stopAllEffectsByZ()
	for i=1 , 5 do
		self.table_temp_Card5[i]:stopAllActions()
		self.table_temp_Card5[i]:setVisible(false)
	end
	for i=1 , 5 do
		self.table_free_Card5[i]:stopAllActions()
		self.table_free_Card5[i]:setVisible(false)
	end
	for i,pan in pairs(self.table_CardPans) do
		pan:removeAllChildren(true)
	end
	self:initNewCard(true)
end
function GameViewLayer:Btn_MinGameMove()  --小游戏按钮移动
	self.btn_MinGame:setEnabled(false)
	local MinTime = 0
	if self.AllSceneVal then 
		MinTime = 1
	else
		MinTime = #self.table_win_lines*0.5 + index_5ofkind
	end 
	release_print("小游戏时间.....  "..MinTime)
	local Mov_btn = cc.MoveTo:create(0.2,cc.p(1138,220))
	local seq_mov = cc.Sequence:create(cc.DelayTime:create(MinTime),Mov_btn,cc.CallFunc:create(function()
																	self.btn_MinGame:setEnabled(true)
																end),nil)
	self.btn_MinGame:runAction(seq_mov)

end

local WarnNum = 0;
local BigWarn = 0 ;
local isKiss = false
local isKongzhipaiBan = false
function GameViewLayer:DoWin()
	self:GameBetIndex()
	self.table_win_point = {}
	self:BuildLogicTab()

	-------------------------Jackpot-----------------------
	if self.JackpotTextNum > 0 then
		--if self.JackpotTextID < 4 then
			if self.JackpotTextID == 1 then
				print("-----Random_Jackot----")
				self:GameJackpot(1);
			elseif self.JackpotTextID == 2 then
				print("----- Major_Jackot ----")
				self:GameJackpot(2);
			elseif self.JackpotTextID == 3 then
				print("----- Minor_Jackot----")
				self:GameJackpot(3);
			end
		-- else
		-- 	--self.GameRedpacket()
		-- end
	end
	-------------------------Jackpot-----------------------

	for i=1,5 do
		self.table_temp_Card5[i]:setVisible(false)
		self.table_free_Card5[i]:setVisible(false)
	end

	if self.win_bet > 0 then
		if self.isFree then
			--self.Linse_WinMun = self.win_bet/100 + self.Linse_WinMun
		else
			self.Linse_WinMun = 0
		end
		self.table_win_lines,self.table_win_rate,self.table_win_point = self._scene._gameLogic:win(self.table_logic,self.lines)
		-- for i,v in ipairs(self.table_win_rate) do
		-- 	print(i.."········中奖的卡牌号······"..v)
		-- end
		
		self:ShowWin()

		if not self.isFree and self.scatter_num < 3 and self.isAotuOr and not self.isAotu then
			self:Btn_MinGameMove()
		end
		
	end
	WarnNum = 0;
	if self.isFree and self.free_count <= 0 then
		release_print("单局赢得钱值.."..self.win_bet)
		release_print("还在免费旋转")
		BigWarn = (self.Linse_WinMun*100)/self.line_bet
		release_print("BigWarn.."..BigWarn)
	elseif not self.isFree then
		release_print("不在免费旋转")
		BigWarn = self.win_bet/self.line_bet
	end
	 --print(".........self.win_bet......."..self.win_bet)  --self.Linse_WinMun
	 --print(".........self.line_bet......."..self.line_bet)
	-- print(".........BigWarn......."..BigWarn)
	if BigWarn >= 1 and not self.isFree then
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
		local BigWin_Act = cc.Sequence:create(cc.DelayTime:create(#self.table_win_lines*0.5 + index_5ofkind),cc.CallFunc:create(function()
				self:GameWarn(WarnNum,self.win_bet);
				if WarnNum == 1 then
					AudioEngine.playEffect("BigWinSpine/win1.mp3")
				elseif WarnNum == 2 then 
					AudioEngine.playEffect("BigWinSpine/win2.mp3")
				else
					AudioEngine.playEffect("BigWinSpine/win3.mp3")
				end
	
				end)
				,nil)
		self:runAction(BigWin_Act)
	elseif BigWarn >= 1 and self.free_count <= 0 and self.isFree then
		print("我已经进入免费旋转结束的Big")
			if BigWarn >= 1 and BigWarn < 75 then
				WarnNum = 1;
			elseif BigWarn >= 75 and BigWarn < 150 then
				WarnNum = 2;
			elseif BigWarn >= 150 then
				WarnNum = 3;
			end					
		self.BigWinOK = true;
		local BigWin_Act = cc.Sequence:create(cc.DelayTime:create(#self.table_win_lines*0.5 + index_5ofkind + 6),cc.CallFunc:create(function()
				self:GameWarn(WarnNum,self.win_bet);
				--self:GameBigWinMp3();  
				if WarnNum == 1 then
					AudioEngine.playEffect("BigWinSpine/win1.mp3")
				elseif WarnNum == 2 then 
					AudioEngine.playEffect("BigWinSpine/win2.mp3")
				else
					AudioEngine.playEffect("BigWinSpine/win3.mp3")
				end
				end)
				,nil)
		self:runAction(BigWin_Act)												
		--GameBigWinMp3();
	end

	if self.isFree then
		print("还在免费旋转")
	else
		print("不在免费旋转")
	end

	local tab_Scatter = {3,5,10}
	self.isRoll = false
	isKiss = false
	if self.scatter_num >= 5 then
		self.scatter_num = 5
		if not self.isFree then
		-- local aaa = UserInfo:instance():getScore()/100 
		-- aaa = aaa + (self.sum_bet/100) * 500
			self.Linse_WinMun = (self.sum_bet * 500) + self.Linse_WinMun
			--self.text_win_bet:setString(string.format("%.2f",self.win_bet/100)):setVisible(true)
			self.text_win_bet:setString(self.Linse_WinMun):setVisible(true)
			self.isFive_state = true
		else
			self.Linse_WinMun = (self.sum_bet * 500) + self.Linse_WinMun
			self.text_win_bet:setString(self.Linse_WinMun)
		end
	end
	if self.scatter_num >= 3 then --进入免费旋转
		print("(FFFFFFFFFFFFFFFFFFFFFFree!!!) Be free wait 4s ...")
		self.free_count = self.free_count + tab_Scatter[self.scatter_num % 3 +1]
		self.free_count_max = self.free_count_max + tab_Scatter[self.scatter_num % 3 +1]
		self.free_bg:setVisible(true)
		if not self.isFree then
			--require("app.views.system"):setBtnEnable(self,false)
			--self.text_win_bet:setVisible(false)
			self.free_game_bgsp:setVisible(true)
			-- if not self.isFree then
			-- 	self.Linse_WinMun = 0
			-- end
			--AudioEngine.stopAllEffect();
			AudioEngine.playEffect("AudioClip/Freegame.mp3");
			isKiss = true 
			self:ButtonControl(false)
			AudioEngine.playEffect("AudioClip/FreeGame_OK.mp3");
		elseif self.isFree then   -- self.free_game_RotateNumBG
			isKiss = true
			self.text_Scatter_to:setString(tab_Scatter[self.scatter_num % 3 +1])
			local Mov_Rotate = cc.MoveTo:create(0.5,cc.p(self.free_game_RotateNumBG:getPositionX(),168))
			local Mov_Rotate2 = cc.MoveTo:create(0.5,cc.p(self.free_game_RotateNumBG:getPositionX(),720))
			local seq_feer1 = cc.Sequence:create(cc.CallFunc:create(function() self.free_game_RotateNumBG:setVisible(true)
									self:ButtonControl(false)
									self.btn_spin:setEnabled(false):setBright(false)
									 end),
									Mov_Rotate,
									cc.CallFunc:create(function()
									AudioEngine.playEffect("AudioClip/FreeGame_OK.mp3")
									end),
									cc.DelayTime:create(3.0),
									Mov_Rotate2,
									cc.DelayTime:create(1),
									cc.CallFunc:create(function() self.free_game_RotateNumBG:setVisible(false)
									isKiss = false
									--self.btn_spin:setEnabled(true):setBright(true)
									 end)
									,nil)
			self.free_game_RotateNumBG:runAction(seq_feer1)
		end
		if self.isAuto then
			self.btn_auto_stop:setVisible(false)
		else
			self.isAuto = true   ------
		end
		self.mun_time_s:setString(string.format(self.free_count))
		self.mun_max_val:setString(string.format(self.free_count_max))
		local seq = cc.Sequence:create(cc.DelayTime:create(2 + 3.5),
										cc.CallFunc:create(function() 
											if not self.isFree  then
												self.free_game_sp:setVisible(true)
												local free_game_ani = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("free_game"))
												local seq_feer = cc.Sequence:create(cc.DelayTime:create(0.5),free_game_ani,nil)
												self.free_game_sp:runAction(seq_feer)
												self.isFree = true 
												self.text_win_bet:setString(0):setVisible(true)
											end
											if not self.isRoll then
												self:SendRoll()
											end
										end),cc.CallFunc:create(function() self.free_game_bgsp:setVisible(false)
										AudioEngine.playMusic("AudioClip/Free_brack.mp3",true);
										self.NumOr_sp:setVisible(true)
										self.mun_max_val:setVisible(true)
										self.mun_time_s:setVisible(true)
										 end)
										,nil)
		self:runAction(seq)
	else
		if self.isAuto then
			if self.isFree then
				print("free_count "..self.free_count)
				print("···index_5ofkind...>>>>"..index_5ofkind)
				if self.free_count <= 0 then
					isKiss = true
					win_index = 0
					AudioEngine.stopMusic();
					local close_sp111 = cc.Sequence:create(cc.DelayTime:create(2+index_5ofkind+#self.table_win_point*0.5),cc.CallFunc:create(function() self.CloseWin_sp:setVisible(true)
												self.test_CloseWin_val:setVisible(false)
												print("免费旋转完后..."..self.Linse_WinMun)
												self.win_bet = self.Linse_WinMun
												end),
												cc.DelayTime:create(1),
												cc.CallFunc:create(function()
												self:playWinAnim(self.Linse_WinMun)
												--SettlementScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(SettlementNum, 0.02, false)
												 end),cc.DelayTime:create(3.5),nil) 
					local close_sp = cc.Sequence:create(close_sp111,cc.CallFunc:create(function() 
												self.isFree = false
												self.isUpdataFree_val = false
												self.free_count_max = 0
												self.free_count = 0
												self.isAuto = false
												self.free_game_sp:stopAllActions()
												self.free_game_sp:setVisible(false)
												self.free_bg:setVisible(false)
												--require("app.views.system"):setBtnEnable(self,true)
												self.Linse_WinMun = 0 
												--isKiss = true
												self:ButtonControl(true)
												self.mun_time_s:setVisible(false)
												self.NumOr_sp:setVisible(false)
												self.mun_max_val:setVisible(false)
												--self.text_win_bet:setVisible(false)
												self.CloseWin_sp:setVisible(false)
												end),nil)
					self:runAction(close_sp)
					return
				end
			end
			local seq = cc.Sequence:create(cc.DelayTime:create(#self.table_win_point*0.5+2.5+index_5ofkind),cc.CallFunc:create(function()
					if not self.isRoll then
						if self.isAuto then
							self:SendRoll()
						end
					end
				end),nil)
			self:runAction(seq)
		else
			if self.win_bet <= 0 and not self.GameJackotTag or self.AllSceneVal then
				local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
						self:ButtonControl(true)
						end),nil)
				self:runAction(seq)
			end
		end

		if self.win_bet <= 0 and not isKiss and not self.GameJackotTag then
			local seq = cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
						self.btn_spin:setEnabled(true):setBright(true)
						end),nil)
			self:runAction(seq)
		end
	end

	self._scene:sendReady()

end

function GameViewLayer:BuildLogicTab()
	self.scatter_num = 0
	self.table_scatter_point = {}
	for c_i,v_col in pairs(self.table_logic) do
		for v_i,v in pairs(v_col) do
			self.table_logic[c_i][v_i] = self.table_ico[c_i+(3-v_i)*5]
			if self.table_logic[c_i][v_i] == 8 then
				self.scatter_num = self.scatter_num + 1
				--table.insert(self.table_scatter_point,{c_i,v_i})
				table.insert(self.table_scatter_point,c_i+(3-v_i)*5)
			end
		end
	end
end

function GameViewLayer:FiveWin()
	-- AudioEngine.playEffect("AudioClip/5ofAKind.mp3")
	-- self.AniFiveLine = cc.Sprite:create("Jackpot/5ofkind0.png")--ccs.Armature:create("5ofkind")
	-- self.AniFiveLine:setPosition(cc.p(1334/2,750/2));
	-- self.AniFiveLine:setLocalZOrder(9)
	-- --self.AniFiveLine:getAnimation():playWithIndex(0)
	-- self:addChild(self.AniFiveLine);
	-- self.bFiveLine = true
	-- local seq_card_5ofkind_1 = cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function()
	-- 					self.AniFiveLine:removeFromParent(true)
	-- 					for i,pan in pairs(self.table_CardPans) do
	-- 						pan:getChildByTag(1):setTexture("card/"..self.table_ico[i].."_nc.png")
	-- 					end
	-- 				end)
	-- 				,nil)
	-- self:runAction(seq_card_5ofkind_1)
end 
function GameViewLayer:atk_Stp()
	for i=1,5 do
		self.table_temp_Card5[i]:setVisible(false)
		self.table_free_Card5[i]:setVisible(false)
	end
	for i,pan in pairs(self.table_CardPans) do
		pan:getChildByTag(1):stopAllActions()   --变成黑白之前，停止所有动作
		pan:getChildByTag(1):setTexture("card/"..self.table_ico[i].."_nc.png")
	end
end

function GameViewLayer:ShowWin()
	self:atk_Stp()
	local time_space = 0.5
	if self.AllSceneVal then
		release_print("。。。。进入全盘游戏。。。。")
		for l_i,line_point in pairs(self.table_win_point) do
			for p_i,point in pairs(line_point) do
				local card_index = 5*(3-point[2])+point[1]
				local temp_ani_card = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("DH_"..self.table_ico[card_index]))
				local seq_card = cc.Sequence:create(cc.DelayTime:create(0),cc.CallFunc:create(function(sender)
				sender:setTexture("card/"..self.table_ico[card_index].."_nc.png")
				end),cc.DelayTime:create(0),temp_ani_card,nil)
				self.table_CardPans[card_index]:getChildByTag(1):runAction(seq_card)
			end
		end
		local seq = cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function()
			self:NewManny()
			if self.isAuto then
				self.btn_bet_add:setBright(false)
				self.btn_bet_sub:setBright(false)
				self.btn_maxBet:setBright(false)
			end
			if not isKiss and self.isFree then
				self.btn_spin:setEnabled(true):setBright(true)
			end
			self.Linse_WinMun = self.win_bet + self.Linse_WinMun
			self.text_win_bet:setString(self.Linse_WinMun):setVisible(true)
		end),nil)
		self.sp_CallBack:runAction(seq)
	else
		release_print("。。。。没有进入全盘，正常游戏。。。。")
		-- for l_i,line_point in pairs(self.table_win_point) do
		-- 	if #line_point == 5 and self.scatter_num<3 then  --中免费  不进入五连中
		-- 		index_5ofkind =  3.5
		-- 		if not self.bFiveLine  then
		-- 			self:FiveWin()
		-- 			--self.bFiveLine = true
		-- 		end
		-- 	end 
		-- end
		local Card_temp = -1
		local index_temp = 0
		print("....中5连....."..index_5ofkind)
		print("闪动：：：：：：：：：：：：：：：：：：：：：：：：：：：：：：：：：：：：：：：：：%%%%%%%%%%%%%%")
		for l_i,line_point in pairs(self.table_win_point) do
			if #line_point == 5 then
				release_print("....>>>个数>>>···"..#line_point)
				for p_i,point in pairs(line_point) do
					local card_index_5 = 5*(3-point[2])+point[1]
					local seq_card_5ofkind = cc.Sequence:create(cc.CallFunc:create(function(sender) 
						sender:setTexture("card/"..self.table_ico[card_index_5]..".png") end),
					nil)
					-- local seq_frame = cc.Sequence:create(temp_ani_frame_5,nil)
					-- self.table_CardPans[card_index_5]:getChildByTag(1):runAction(seq_card_5ofkind)
					local seq_frame = cc.Sequence:create(cc.CallFunc:create(function(sender)
						sender:setVisible(true)
						end),cc.DelayTime:create(3),cc.CallFunc:create(function(sender)
							sender:setVisible(false)
						end),nil)
					self.table_card_frame[card_index_5]:runAction(seq_frame)
				end
			end
		end
		--point闪动
		local is_onec = false
		for l_i,line_point in pairs(self.table_win_point) do
			for p_i,point in pairs(line_point) do
				local card_index = 5*(3-point[2])+point[1]
				release_print("·········"..self.table_ico[card_index])
						if self.table_ico[card_index] >= 0 and self.table_ico[card_index] < 8 then
							if self.table_ico[card_index] ~= Card_temp then 
								Card_temp = self.table_ico[card_index];
								index_temp = index_temp +1;
							end
						end
				local temp_ani_card = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("DH_"..self.table_ico[card_index]))
				local seq_card = cc.Sequence:create(cc.DelayTime:create(time_space*(l_i-1) + index_5ofkind),cc.CallFunc:create(function(sender)
					sender:setTexture("card/"..self.table_ico[card_index]..".png")
				end),cc.DelayTime:create(time_space),cc.CallFunc:create(function(sender)
					sender:setTexture("card/"..self.table_ico[card_index].."_nc.png")
				end),cc.DelayTime:create(time_space*(#self.table_win_point-l_i)),
				cc.CallFunc:create(function()
					if not is_onec then
						if index_temp == 1 then
							AudioEngine.playEffect("AudioClip/Card_"..Card_temp..".mp3");
							print("···播放···"..Card_temp)
						else
							AudioEngine.playEffect("AudioClip/Card_more.mp3");
							print("···播放多个···")
						end	 
						is_onec = true
					end
				end),temp_ani_card,nil)
				
				self.table_CardPans[card_index]:getChildByTag(1):runAction(seq_card)
				---播音效
				-- cc.CallFunc:create(function()
				-- 	if index_temp == 1 then
				-- 		AudioEngine.playEffect("AudioClip/Card_"..Card_temp..".mp3");
				-- 		print("···播放···"..Card_temp)
				-- 	else
				-- 		AudioEngine.playEffect("AudioClip/Card_more.mp3");
				-- 		print("···播放多个···")
				-- 	end	 
				-- end),

				local temp_ani_frame = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("ani_cf"))
				local seq_frame = cc.Sequence:create(cc.DelayTime:create(time_space*(l_i-1) + index_5ofkind),cc.CallFunc:create(function(sender)
					sender:setVisible(true)
				end),cc.DelayTime:create(time_space),cc.CallFunc:create(function(sender)
					sender:setVisible(false)
				end),cc.DelayTime:create(time_space*(#self.table_win_point-l_i)
				),cc.CallFunc:create(function(sender)
					sender:setVisible(true)
				end),temp_ani_frame,nil)
				self.table_card_frame[card_index]:runAction(seq_frame)
			end
		end
		--line闪动
		for i,line_i in pairs(self.table_win_lines) do
			local seq_line = cc.Sequence:create(cc.DelayTime:create(time_space*(i-1) + index_5ofkind),cc.CallFunc:create(function(sender)
				AudioEngine.playEffect("AudioClip/Line_mc.mp3");
				sender:getChildByName("LineFrame"):getChildByName("text_line_win"):setString(self.table_win_rate[i]*self.line_bet_last)
					self.Linse_WinMun = (self.table_win_rate[i]*self.line_bet_last) + self.Linse_WinMun
					self.text_win_bet:setString(self.Linse_WinMun):setVisible(true)
				sender:setVisible(true)
				self.table_line_nums[line_i]:setVisible(true)
				end),cc.DelayTime:create(time_space),cc.CallFunc:create(function(sender)

				sender:setVisible(false)
				self.table_line_nums[line_i]:setVisible(false)
			end),nil)
			-- if not self.isFree and not isKiss then
			-- 	self.text_win_bet:setVisible(false)
			-- end
			self.table_lines[line_i]:runAction(seq_line)
		end
		--line_num点闪动
		local seq = cc.Sequence:create(cc.DelayTime:create(#self.table_win_lines*time_space + index_5ofkind),cc.CallFunc:create(function()
			if not self.isUpdataFree_val then
				if self.isFive_state  then
					release_print("5 个ataest")
					self.text_win_bet:setString(self.win_bet):setVisible(true)
				end
				self:NewManny()
				self.Linse_WinMun = 0
			end
			
			if not self.isFree and self.scatter_num < 3 then
				self:ButtonControl(true)
			end
			if self.isAuto then
				self.btn_bet_add:setBright(false)
				self.btn_bet_sub:setBright(false)
				self.btn_maxBet:setBright(false)
			end
			if not isKiss and self.isFree then
				self.btn_spin:setEnabled(true):setBright(true)
			end
			for i,line_i in pairs(self.table_win_lines) do
				local seq_line_num = cc.Sequence:create(cc.CallFunc:create(function(sender)
					sender:setVisible(true)
				end),cc.DelayTime:create(0.15),cc.CallFunc:create(function(sender)
					sender:setVisible(false)
				end),cc.DelayTime:create(0.15),nil)
				self.table_line_nums[line_i]:runAction(cc.RepeatForever:create(seq_line_num))
			end
		end),nil)
		self.sp_CallBack:runAction(seq)
		--self.btn_spin:setEnabled(true):setBright(true)

		--scatter
		if self.scatter_num >= 3 then
			for i=1,self.scatter_num do
				local temp_ani = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("DH_10"))
				self.table_CardPans[self.table_scatter_point[i]]:getChildByTag(1):stopAllActions():runAction(temp_ani)
			end
		end
	end
end
--------
-- function GameViewLayer:GameRedpacket() --红包彩金
-- 	--self:startTime(false)
-- 	if self.isAuto then --停止自动旋转
--  		self.isAuto = false
--  		self.btn_stop:setVisible(false)
-- 		self.btn_auto_spin:setVisible(true)
-- 		self.btn_auto_stop:setVisible(false)
--  	end
	
-- 	cc.Director:getInstance():getRunningScene():addChild(import("Hall.RedpacketLayer").new(), 10)
-- 	local RedpacketLayer = import("Hall.RedpacketLayer")
-- 	RedpacketLayer:JackpotNumber(self.JackpotTextNum) --传送彩金总值
-- end
-- -------------------

--通用---------------------------------------------------------------------------------
function GameViewLayer:getJackpotWin(_id,_win)
	self.JackpotTextID  = _id
	self.JackpotTextNum = _win
end

function GameViewLayer:GameJackpot(_num) --彩金效果
	--require("app.views.system"):setBtnEnable(self,false)
	self:ButtonControl(false)
	if self.isAuto then --停止自动旋转
 		self.isAuto = false
 		self.btn_stop:setVisible(false)
		self.btn_auto_spin:setVisible(true)
		self.btn_auto_stop:setVisible(false)
 	end
	self.JackpotJinbi:setVisible(true)
	self.GameJackotTag = true
	self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function()
		for k,v in pairs(self.Game_Jackpot) do
			v:removeFromParent(true)
		end
		self.Game_Jackpot ={}
		self.JackpotWinMps = AudioEngine.playEffect("Jackpot/JackpotWin.mp3",true);

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
			self.JackpotText:setVisible(true)

			local text=0
			local numb = self.JackpotTextNum
			if numb <= 100000 then
				self.stepJackpot = 29
			elseif numb > 100000 and numb <= 1000000 then
				self.stepJackpot = 45
			elseif numb > 1000000 then
				self.stepJackpot = 419
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
					self.JackpotJinbi:setVisible(false)
					--require("app.views.system"):setBtnEnable(self,true)
					local  str = ExternalFun.numberThousands(self.BalanceText);
	        		self.text_credit:setString(str)
					--self:ButtonControl(true)
					self:ButtonControl(true)
				end
			end, 0.03, false); 
		end),nil))
	end),nil))
end

function GameViewLayer:GameWarn(_num, winbet)
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

--Bigwin动画音效停止
function GameViewLayer:cleanBigwin()
	if self.GameBigWin then
		self:stopAllActions();
		AudioEngine.stopAllEffects();
		--self:stopAllEffectsByZ()
		AudioEngine.stopMusic();
		self.BigWinOK = false;
		self.GameBigWin = false;
		self.spBigWin:removeFromParent(true); 

		if(self.schedulerIDWin3) then 
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerIDWin3)
			self.schedulerIDWin3 = nil 
		end
	end
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
		local avatarFrame = self._csbNode:getChildByName("sp_head")
		HeadSprite:createClipHead(GlobalUserItem, 64, "sp_avatar_mask_64.png")
			  :setPosition(avatarFrame:getPosition())
			  :setName("sp_avatar")
			  :addTo(self._csbNode)
	end

	local txtNickName = self._csbNode:getChildByName("lab_nick")
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
	--self:stopAllEffectsByZ()
	AudioEngine.stopMusic()
	--播放大厅背景音乐
    ExternalFun.playPlazzBackgroudAudio()
	if(self.schedulerIDWin) then 
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerIDWin)
		self.schedulerIDWin = nil 		
	end
	if(self.schedulerIDWin1) then 
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerIDWin1)
		self.schedulerIDWin1 = nil 
	end
	if(self.schedulerIDWin3) then 
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerIDWin3)
		self.schedulerIDWin3 = nil 
	end
	if(self.schedulerID) then 
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
		self.schedulerID = nil 
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
		self:onButtonSwitchAnimate()
		self._scene:onQueryExitGame()
	elseif tag == 10002 then
		print("BT_SWITCH")
		self:onButtonSwitchAnimate()
	elseif tag == 10003 then
		self:onButtonSwitchAnimate()
		self.b_showHelp = true
		HelpLayer:create(self)
				 	 :addTo(self,101)
	else
		showToast(self,"功能尚未开放！",1)
	end
end

function GameViewLayer:onButtonSwitchAnimate()
	local time = 0.2
	local helpshow = self.btPanel:isVisible()
	local scaleLv = helpshow and 0 or 1
	--self.btPanel:setVisible(true)

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
	
function GameViewLayer:stopAllEffectsByZ(  )
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
        return ccexp.AudioEngine:stopAll()
    else
        cc.SimpleAudioEngine:getInstance():stopAllEffects()
    end
end


function GameViewLayer:GameBJMp3()
	AudioEngine.playMusic("mp3/GameBJ2.mp3",true) --开启背景音乐
end

return GameViewLayer

 	 	 	 	 	 