--导入游戏逻辑文件

--创建GameViewLayer
local GameViewLayer = class("GameViewLayer",function(scene)
	local gameViewLayer =  display.newLayer()
return gameViewLayer
end)
--导入游戏逻辑文件
local module_pre = "game.yule.bonusbears.src"

local ExternalFun =  appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

local HeadSprite = appdf.req(appdf.EXTERNAL_SRC .. "HeadSprite")
local g_var = ExternalFun.req_var
local cmd = module_pre .. ".models.CMD_Game"
local GameNotice = appdf.req(appdf.BASE_SRC .."app.views.layer.other.GameNotice")
local HelpLayer = appdf.req(module_pre..".views.layer.HelpScene")
local ClimpScene = appdf.req(module_pre .. ".views.layer.ClimpScene")
local GameNotice = appdf.req(appdf.BASE_SRC .."app.views.layer.other.GameNotice")
local QueryDialog = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.QueryDialog")


GameViewLayer.RES_PATH = "game/yule/bonusbears/res/"

local nWinTime = 0
local MAXZORDER=999999
local MAXLINE =25
local DHIGHT=750
local DWIDHT=1334
local  playMp3Index = 1 ;

local SPINROLL =-1 
local AUTOROLL =1  --×Ô¶¯Ðý×ªautoFlag
local FREEROLL =2  --Ãâ·ÑÐý×ªautoFlag  
local b_sendMsgCallback = true; --·¢ËÍÍøÂçÏûÏ¢ÊÇ·ñ»Øµ÷



function GameViewLayer:ctor(scene)
	--注册node事件
	ExternalFun.registerNodeEvent(self)

	self._scene = scene
	self:initdata()
	self:preloadUI()
	self:initUi()
end

function GameViewLayer:initdata(  )
	--指定创建的csb
	self.RESOURCE_FILENAME = "MainScene.csb"

	self.autoSchedulerEntry =nil  --×Ô¶¯Ðý×ª¶¨Ê±Æ÷
	self.BonusSchedulerEntry =nil ----²Ê½ð¶¨Ê±Æ÷
	--±äÁ¿ 
	self.ROLLING=false; --ÊÇ·ñÔÚ×ª
	self.RUNING=false; --ÕýÔÚ¹ö¶¯
    self.ready =false; --ÊÇ·ñ¿ÉÒÔÓÎÏ·£¬·þÎñ¶Ë·µ»Ø²ÅÄÜ¿ªÊ¼ÓÎÏ·
    self.autoFlag=SPINROLL; --ÊÇ²»ÊÇ×Ô¶¯Ðý×ª ÓÃÓÚÏÔÊ¾²»Í¬stop°´Å¥
    self.lines=MAXLINE;  --Ñ¡Ôñ¼¸ÌõÏß
    self.betIndex=1;

    self.bet ={1000,5000,10000,20000,50000,100000} --µ¥ÏßÑº×¢

    self.rollCount=0  --¹ö¶¯Íê³É¼¸ÌõÏß 
    self.autoCount=0 -- ×Ô¶¯Ðý×ªÊ£Óà´ÎÊý
    self.tab ={{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}}--½á¹û¼¯

	--ÖÐ½±ÐÅÏ¢
    self.winNumb =nil --Ïß½ð¶î
    self.winLines =nil --Ïß
    self.winOdds  =nil--ÅâÂÊ
    self.winLinePoints=nil --Ïß¾ßÌåµÄµã
    self.TotalBet = 0; --×ÜÑº×¢
    self.linebet = 0; --µ¥ÏßÑº×¢
    self.gameWin =0; --ÓÎÏ·Ó®ÁË

	--table
    self.table_pans ={} --¹ö¶¯´°¿Ú1
    self.table_lines ={} --ËùÓÐÖÐ½±Ïß 
    self.table_BtnLines ={} --ËùÓÐ°µÉ«°´Å¥
    self.table_DarkBtnLines ={} --ËùÓÐ°µÉ«°´Å¥Êý×Ö
    self.table_winStars ={} --Ó®ÁËºóÌí¼ÓµÄ¿ò¿ò
    self.goinFreeStepEntry=nil  --½øÈëÃâ·ÑÓÎÏ·¶¨Ê±Æ÷ 

	--Ãâ·Ñ
    self.freeleft=-1  --Ãâ·ÑÐý×ªÊ£Óà 
    self.freeleft_OK = false; --ÒÑ¾­ÔÚÃâ·ÑÓÎÏ·ÖÐ
    self.freeWinCount =0 --Ãâ·ÑÓÎÏ·Ó®ÁË×Ü¶î
    self.text_mult =nil --Ãâ·ÑÓÎÏ··­±¶Êý
    self.text_free_win=nil --Ãâ·ÑÓ®È¡

	--ÎÄ±¾
    self.text_lines=nil
	self.text_totalbet=nil
	self.text_bet = nil
    self.GameBalanceText = nil --Íæ¼Ò½ð±Ò
    self.BalanceText = 0
    self.text_tipwin=nil --Ó®ÁËºóÖÐ¼äÌáÊ¾
    self.text_spins_left=nil
	--autospin 
    self.pan_normal=nil
    self.pan_free=nil

	--°´Å¥¶¨Òå
    self.btn_autostop = nil --auto_stop°´Å¥
    self.btn_autospin = nil --auto_spin°´Å¥
    self.btn_stop = nil --stop°´Å¥
    self.btn_spin = nil --spin°´Å¥
    self.btn_lines_sub= nil
    self.btn_lines_add= nil
    self.btn_bet_sub= nil
    self.btn_bet_add= nil 
    self.btn_game=nil
    self.btn_freespin=nil
    self.btn_freestop=nil

    self.rollBgMp3Id = nil --¹ö¶¯ÉùÒôID  
    self.playWinMusicEntry =nil --Ãâ·ÑÓÎÏ·²¥·ÅÉùÒô¶¨Ê±Æ÷

    self.LineWins = {} --Ã¿ÌõÏßÖÐ½±¶î
    self.GameLineCount = 0 --×Ü¹²ÖÐÁË¶àÉÙÌõÏß

	-------------------------------- ÆÕÍ¨Ñ¡Ôñ¸³Öµ
    self.VoiceWinGold = nil; --ÆÕÍ¨ÖÐ½±½áËãÒôÐ§
    self.VoiceFreeWinGold = nil; --Ãâ·Ñ½áÊøÖÐ½±½áËãÒôÐ§
    self.GameScatterWinOK = false; --ScatterÓÐµÃ·Ö
    self.nScatter = 0;  --ScatterÓÐ¶àÉÙ
    self.nGameWild = 0;
    self.ScatterMp3Id = nil --¹ö¶¯ÉùÒôID
    self.tab_xing ={};  --Á½¸öScatterºóµÄ»ð¶¯»­
    self.GameStopOK = false; --µã»÷ÁËstop
    self.rollCountTemp=0;  --¹ö¶¯Íê³É¼¸ÌõÏß
    self.GameRollFunNum = 0 --Ã»ÓÐÍøÂçÐý×ª
    self.serverWin=0 --·þÎñ¶Ë·µ»ØµÄ win ½ð¶î
    self.serverIcos={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0} --½á¹û
	-------------------------------- Ãâ·ÑÓÎÏ·¸³Öµ
    self.FreeGamePicture = nil
    self.BounsPicture = nil
    self.GameWinScatter = false; 
    self.GameWinWild = false;
    self.FreeGame_OK = false;
    self.FreeGameAgain_OK = false;
    self.Game_gofree ={}; --½øÈëÃâ·Ñ¶¯»­
    self.sp_logo =nil --ÓÎÏ·logo
    self.mainbg_free = nil;
	-------------------------------- --BigWin¸³Öµ
    self.spBigWin = nil;
    self.GameBigWin = false;
    self.BigWinOK = false;
	---------------------------------
	
	----------------------------- ²Ê½ð¸³Öµ
    self.BonusRandomText = 0 --²Ê½ð×ª¶¯´¥·¢
    self.Random_JackotText = 0;
    self.MajorText = 0;
    self.MinorText = 0;
    self.Random_Jackot = 0;
    self.Major = 0;
    self.Minor = 0;
	----------------------------- ÖÐ½±ÏßÌáÊ¾¸³Öµ
    self.GameLine = nil;
    self.GameLine_Line = 0;
    self.GameWin = nil;
    self.GameWin_Win = 0;
    self.GameWin_Line = 0;
    self.GameTotal = nil;
    self.GameTotal_Win = 0;
    self.GameScatter = nil;
    self.GameScatter_Win = 0;
	----------------------------- ²Ê½ð¶¯»­¸³Öµ
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
	------------------------------
    self.bFreeGameOver = false
    self.isFreeOK = false
	------------------------------
    self.sp_tipwin=nil   --赢了后中间提示
    self.text_tipwin=nil --赢了后中间提示
	------------------------------
	self.GameOldSocre = 0
	self.btn_maxBet = nil
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
	
	cc.Director:getInstance():getTextureCache():addImage("BonusBearsPlist/MainUI.png")
	--Ìí¼Ó»º´æ
	cc.Director:getInstance():getTextureCache():addImage("roll3_1.png")
	cc.Director:getInstance():getTextureCache():addImage("roll3_2.png")
	cc.Director:getInstance():getTextureCache():addImage("roll1245_1.png")
	cc.Director:getInstance():getTextureCache():addImage("roll1245_2.png")
	cc.Director:getInstance():getTextureCache():addImage("roll1245_3.png")
	cc.Director:getInstance():getTextureCache():addImage("roll1245_4.png")
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("Jackpot/5ofkind.ExportJson")

	AudioEngine.stopMusic()

end

function GameViewLayer:initUi(  )
	
	-- require("app.views.system"):initLayer(self)
	-- require("app.views.system"):showTextWin(self);
	-- require("app.views.system"):SetVisible(self,false);

	local  btcallback = function(ref, type)
        if type == ccui.TouchEventType.ended then
         	self:footBtnClick(ref,ref:getTag())
        end
	end

	local function onNodeEvent(event)
		if event == "exit" then
			self:onExit()
		end
	end

	self:registerScriptHandler(onNodeEvent)
	
	self._csbNode = cc.CSLoader:createNode("MainScene.csb")
		:addTo(self, 1)

		
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

	self.FreeGamePicture = self._csbNode:getChildByName("FreeGame")
	self.FreeGamePicture:setLocalZOrder(MAXZORDER+100)
	self.BounsPicture = self._csbNode:getChildByName("Bouns")
	self.BounsPicture:setLocalZOrder(MAXZORDER+100)

	--»ñÈ¡ÖÐ½±Ïß
	for i = 1 , MAXLINE do 
		table.insert(self.table_lines,self._csbNode:getChildByName("line"..i) )
	end 

	for i = 1 , MAXLINE+1 do 
		self.table_BtnLines[i] = self._csbNode:getChildByName("LeftLineBtn"..i)
		self.table_DarkBtnLines[i] = self._csbNode:getChildByName("DarkLineNum_"..i)
	end 

	--»ñÈ¡Ãâ·ÑÐý×ª°´Å¥ºÍÎÄ±¾
	self.pan_free=self._csbNode:getChildByName("pan_free")
	--self.text_mult=self.pan_free:getChildByName("text_mult") --Ãâ·ÑÐý×ª±¶Êý
	self.text_spins_left=self.pan_free:getChildByName("text_spins_left") --Ãâ·ÑÐý×ª´ÎÊý
	self.text_free_win=self.pan_free:getChildByName("text_free_win")--Ãâ·ÑÐý×ªÓ®µÄ½±½ð

	self.btn_freespin=self.pan_free:getChildByName("btn_freespin") --Ãâ·ÑÐý×ªspin°´Å¥
	self.btn_freestop=self.pan_free:getChildByName("btn_freestop") --Ãâ·ÑÐý×ªstop°´Å¥
	self.btn_freespin:addTouchEventListener(btcallback)
	self.btn_freestop:addTouchEventListener(btcallback)

	--»ñÈ¡ÆÕÍ¨Ðý×ª°´Å¥ºÍÎÄ±¾
	self.pan_normal=self._csbNode:getChildByName("pan_normal") 
	self.btn_spin =self.pan_normal:getChildByName("btn_spin") --¿ªÊ¼Ðý×ª
	self.btn_stop =self.pan_normal:getChildByName("btn_stop") --Í£Ö¹Ðý×ª
	self.btn_autospin = self.pan_normal:getChildByName("btn_autospin") --×Ô¶¯Ðý×ª
	self.btn_autostop = self.pan_normal:getChildByName("btn_autostop") --Í£Ö¹Ðý×ª
	self.btn_lines_sub = self.pan_normal:getChildByName("btn_lines_sub") --ÏßÊý¼õÉÙ
	self.btn_lines_add = self.pan_normal:getChildByName("btn_lines_add") --ÏßÊýÔö¼Ó
    self.btn_bet_sub = self.pan_normal:getChildByName("btn_bet_sub") --±¶ÂÊ¼õÉÙ
	self.btn_bet_add = self.pan_normal:getChildByName("btn_bet_add") --±¶ÂÊÔö¼Ó
	self.btn_maxBet = self.pan_normal:getChildByName("btn_maxBet")

	self.btn_spin:addTouchEventListener(btcallback)
	self.btn_stop:addTouchEventListener(btcallback)
	self.btn_autospin:addTouchEventListener(btcallback)
	self.btn_autostop:addTouchEventListener(btcallback)
	self.btn_lines_sub:addTouchEventListener(btcallback)
	self.btn_lines_add:addTouchEventListener(btcallback)
    self.btn_bet_sub:addTouchEventListener(btcallback)
	self.btn_bet_add:addTouchEventListener(btcallback)
	self.btn_maxBet:addTouchEventListener(btcallback)
	if self.betIndex == 1 then
		self.btn_bet_sub:setEnabled(false):setBright(false)
	end
	self.text_bet =self.pan_normal:getChildByName("text_bet") --×ÜÏß
	self.text_win=self.pan_normal:getChildByName("text_win") --Ó®ÁË×Ü¶îtext
	self.text_totalbet =self.pan_normal:getChildByName("text_totalbet") --×ÜÑº×¢
	self.text_lines =self.pan_normal:getChildByName("text_lines") --×ÜÏß
	self.GameBalanceText =self.pan_normal:getChildByName("test_balance") --×ÔÉí½ðÇ®

	self.text_win:setString("0")
	self.text_win:setVisible(false)

	self.BalanceText = GlobalUserItem.lUserScore;
	local str = ExternalFun.numberThousands(self.BalanceText);
	self.GameBalanceText:setString(str)

	--Ð¡ÓÎÏ·°´Å¥
	--self.btn_game=self._csbNode:getChildByName("btn_game")
	--self.btn_game:setLocalZOrder(MAXZORDER)
	--self.btn_game:addTouchEventListener(btcallback)
	
	--»ñÈ¡¹ö¶¯´°¿Ú 
	for i = 1 , 5 do 
		table.insert(self.table_pans,self._csbNode:getChildByName("pan_"..i) )
	end

	--中间win
	self.sp_tipwin = cc.Sprite:create("youwin/win.png")
	self.sp_tipwin:setPosition(667,447)         
	self.sp_tipwin:setLocalZOrder(MAXZORDER+200)
	self:addChild(self.sp_tipwin)

	self.text_tipwin = cc.LabelAtlas:_create("" .. 0,"youwin/font.png",97,136,46)
	self.text_tipwin:setAnchorPoint(cc.p(0.5,0.5))
	self.text_tipwin:setPosition(667,300)         
	self.text_tipwin:setLocalZOrder(MAXZORDER+200)
	self:addChild(self.text_tipwin)

	self.sp_tipwin:setVisible(false)
	self.text_tipwin:setVisible(false)

	----------------------------------------------------------------
	--¶¥²¿²Ê½ð
	local JackpotLayer = cc.CSLoader:createNode("Jackpot/JackpotScene.csb")
	local Jackpot = JackpotLayer:getChildByName("Jackpot"):setVisible(false)
	local JackpotPanel = JackpotLayer:getChildByName("JackpotPanel")
	self.Random_JackotText = JackpotPanel:getChildByName("JackpotTest_Random") 
	self.MajorText = JackpotPanel:getChildByName("JackpotTest_Major") 
	self.MinorText = JackpotPanel:getChildByName("JackpotTest_Minor") 

	self:startBonusTime(true);
	self.Random_Jackot = math.random(100000,500000)
	self.Major = math.random(50000,240000)
	self.Minor = math.random(14000,55000)
	if self.Random_Jackot == 0 then
		self.Random_Jackot = 100;
	end
	--self.Random_Jackot = UserInfo:instance():GetHandSel()	--彩金初始值
	--UserInfo:instance():GetNextHandsel()  --彩金转动到的值
	self.Random_JackotText:setString(self.Random_Jackot):setVisible(false)
	self.MajorText:setString(self.Major):setVisible(false)
	self.MinorText:setString(self.Minor):setVisible(false)
	--ÖÐ½±ÏßÌáÊ¾
	self.GameLine = JackpotPanel:getChildByName("GameLine") 
	self.GameLine_Line = self.GameLine:getChildByName("Line") 
	self.GameWin = JackpotPanel:getChildByName("GameWin") 
	self.GameWin_Win = self.GameWin:getChildByName("Win") 
	self.GameWin_Line = self.GameWin:getChildByName("Line") 
	self.GameTotal = JackpotPanel:getChildByName("GameTotal") 
	self.GameTotal_Win = self.GameTotal:getChildByName("Win") 
	self.GameScatter = JackpotPanel:getChildByName("GameScatter") 
	self.GameScatter_Win = self.GameScatter:getChildByName("Win") 

	--²Ê½ð±íÏÖ
	self.JackpotMajor = JackpotLayer:getChildByName("MajorJackpot")
	self.JackpotMinor = JackpotLayer:getChildByName("MinorJackpot")
	self.JackpotRandom = JackpotLayer:getChildByName("RandomJackpot")
	self.JackpotXing = JackpotLayer:getChildByName("XingJackpot")
	self.JackpotText = JackpotLayer:getChildByName("JackpotText")
	self.JackpotJinbi = JackpotLayer:getChildByName("Jinbi")

	self:addChild(JackpotLayer)
	----------------------------------------------------------------------------------------------

	--Ã»Ç®°´Å¥°µµô
	local systemBtn = false
	local systemNum = os.date("%m", os.time())
	if tonumber(systemNum) > 5 then
		systemBtn = true
	end

	if GlobalUserItem.lUserScore < self.bet[1]*self.lines  then
		self:setBtnEnble(false);
	end
	self:GameBJMp3()
	self:onUpdateUserInfo()
	self:initButton()
	self:reConnect()
	self:updateText() --¸üÐÂÎÄ±¾
	--self:OnAnimation();
	--初始化广播
	--self:BroadCastInit()
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


--
function GameViewLayer:footBtnClick(sender, tag) 
	--if eventType == ccui.TouchEventType.ended and sender:isEnabled()  then
	
		self:playBtnEffect()
		--self:cleanWin() --Çå³ýÓ®ÁË¶¯»­
		if sender:getName() == "btn_lines_sub" then
			printf("btn_lines_sub")
			if self.lines > 1 then
				self.lines =self.lines - 1
			else
				self.lines = 25
			end
			self:showLines(tonumber(self.lines))
			self:updateText() --¸üÐÂÎÄ±¾
			self:cleanBigwin();
			---------------------------------
			--------------------------------
		elseif sender:getName() == "btn_lines_add" then
			printf("btn_lines_add")
			if self.lines < MAXLINE then
				self.lines =self.lines + 1
			else
				self.lines = 1
			end
			self:showLines(tonumber(self.lines))
			self:updateText() --¸üÐÂÎÄ±¾
			self:cleanBigwin();
		elseif sender:getName() == "btn_bet_sub" then
			printf("btn_bet_sub")
			if self.betIndex > 1 then
				self.btn_bet_add:setEnabled(true)
				self.btn_bet_add:setBright(true)
				self.betIndex = self.betIndex - 1
				if self.betIndex == 1 then
					self.btn_bet_sub:setEnabled(false):setBright(false)
				end
			end
			self:updateText() --¸üÐÂÎÄ±¾
			self:cleanBigwin();
		elseif sender:getName() == "btn_bet_add" then
			printf("btn_bet_add")
			self.btn_bet_sub:setEnabled(true):setBright(true)
			if self.betIndex == table.getn(self.bet) then
				self.betIndex = 1
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
			self:updateText() --¸üÐÂÎÄ±¾
			self:cleanBigwin();
			--------------------------
		elseif sender:getName() == "btn_maxBet" then
			self.betIndex = table.getn(self.bet)
			if self.betIndex ==table.getn(self.bet)  then
				self.btn_bet_add:setEnabled(false)
				self.btn_bet_add:setBright(false)
				self.btn_bet_sub:setEnabled(true):setBright(true)
			end
			self:updateText() 
			self:cleanBigwin();
		elseif sender:getName() == "btn_spin" then
			printf("btn_spin")
			self.RUNING = false;
			self.btn_spin:setEnabled(false)
			self.btn_spin:setBright(false)
			self:startGameByNet(false,false)
		elseif sender:getName() == "btn_stop" then
			printf("btn_stop")  
			self:stopRall()
			--self:setBtnEnble(true) --°´Å¥ÆôÓÃ
			self.btn_stop:setVisible(false)--Òþ²Østop
			if self.ROLLING then   
				self.ROLLING = false;
				self:doWIN() 
			end   
		elseif sender:getName() == "btn_autospin" then --×Ô¶¯Ðý×ª¿ªÊ¼°´Å¥
			printf("btn_autospin")
			self.autoCount=999
			self:setBtnEnble(false)
			self.RUNING=false
			self:autoRoll() --Á¢ÂíÖ´ÐÐ£¬ÆäËûµÄÊ¹ÓÃ¶¨Ê±Æ÷Æô¶¯
			self:startTime(true)
			self.btn_autospin:setVisible(false) --Òþ²Øautospin
			self.btn_autostop:setVisible(true)
		elseif sender:getName() == "btn_autostop" then --×Ô¶¯Ðý×ªÍ£Ö¹°´Å¥
			if b_sendMsgCallback then
			 	printf("btn_autostop")
				--È¡Ïû¶¨Ê±Æ÷
				self.RUNING = false
				self.autoCount =0--Çå³ý×Ô¶¯¹ö¶¯Êý¾Ý ¹Ø±Õ¶¨Ê±Æ÷
				if self.ROLLING then
					self:stopRall() --È¥µôºó£¬²»»áÁ¢ÂíÍ£Ö¹
					self.ROLLING = false;
					self:doWIN()
				else
					if not self.GameJackotTag then
						self:setBtnEnble(true)
					end
				end
				--self:setBtnEnble(true);
				self.btn_stop:setVisible(false);--Òþ²Østop
				self.btn_autostop:setVisible(false);--Òþ²Øautostop
				self.btn_autospin:setVisible(true);
			end
		elseif sender:getName() == "btn_freespin" then
			printf("btn_freespin")
			 if( self.freeleft > 0 ) then  
				 --¿ªÊ¼Ãâ·ÑÓÎÏ·  
				--self:cleanWin()
				self.RUNING=false
				self:autoRoll()
				self:startTime(true)
				
			 end 
			 self:setFreeSpinBtnEnble(false);	
		elseif sender:getName() == "btn_freestop" then	
			printf("btn_freestop")
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
----------------------------------BigwinÒôÐ§-------------------------------------
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

function GameViewLayer:GameBetIndex() --×Ô¶¯ÅÐ¶Ïµ±Ç°Óà¶îÄÜ·ñÑº×¢£¬Ñº²»ÁË£¬×Ô¶¯½µµÍBetÖµ 
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

function  GameViewLayer:GameRollFun(num)
	self.GameRollFunNum = self.GameRollFunNum + 1
	if not(self.GameRollFunNum == 1) then
		for indexKey,pan_1 in pairs(self.table_pans) do
			for key,value in pairs(pan_1:getChildren()) do
				if 1 == #pan_1:getChildren() then -- Ö»Áô×îºóÒ»¸ö
					value:stopAllActions();
					break;
				else
					value:removeFromParent();
				end
			end
		end
	end

	if b_sendMsgCallback then
		self:startRollBegin(self.serverIcos,self.serverWin);
		return;
	end

	for indexKey,pan_1 in pairs(self.table_pans) do
		local roll = self:createRoll(9,indexKey)
		pan_1:addChild(roll)
		local height =9 *115*1.2--½º´ø³¤¶È+´°¿Ú³¤¶È
		for key,value in pairs(pan_1:getChildren()) do
			
			--local mov = cc.MoveBy:create(height/1700,cc.p(0,-height))--Ê±¼ä=s/v
			--local seq = cc.Sequence:create(mov);
			--local seq2 = cc.Sequence:create(mov,cc.CallFunc:create(GameRollFun));

			local mov = cc.MoveBy:create(height/1700,cc.p(0,-height))--时间=s/v
			local movUp2 = cc.MoveBy:create(0.3,cc.p(0,20))--结束回弹
			local seq = nil
			local seq2 = nil
			--if num == 1 then-- cc.DelayTime:create(indexKey*0.1),
				if num == 1 then
					seq = cc.Sequence:create(movUp2,mov);
				else
					seq = cc.Sequence:create(mov);
				end

				seq2 = cc.Sequence:create(seq,cc.CallFunc:create(function()
					self:GameRollFun(2)
				end));
			-- else
			-- 	seq = cc.Sequence:create(mov);
			-- 	seq2 = cc.Sequence:create(mov,cc.CallFunc:create(function()
			-- 		GameRollFun(2)
			-- 	end));
			-- end

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
--²Ê½ð¶¨Ê±Æ÷
local BonusText = 0
local Major = 0
local Minor = 0
function GameViewLayer:Bonusinit(dt)
	BonusText = BonusText + 1;
	--printf("¡¾##############################¡¿:"..BonusText)
	--Major 500ÒÔÉÏ£¬2400ÒÔÏÂ
	--Minor 140ÒÔÉÏ£¬550ÒÔÏÂ
	if BonusText % 2 == 0 then
		self.Major = math.random(50000,240000)
		self.MajorText:setString(self.Major)
		self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
			self.Minor = math.random(14000,55000)
			self.MinorText:setString(self.Minor)
		end),nil))
	end

	if self.BonusRandomText == 0 then
		printf("------------Jackot------------:"..self.Random_Jackot)
		local Random_Jackot = 100000000;
		--·ÖÊý¹ö¶¯
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

--Æô¶¯²Ê½ð¶¨Ê±Æ÷
function GameViewLayer:startBonusTime(b_restart)
	if self.BonusSchedulerEntry~=nil then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.BonusSchedulerEntry)
			self.BonusSchedulerEntry = nil
	end

	if b_restart then
		self.BonusSchedulerEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.Bonusinit), 1, false)
	end
end
---------------------------------------------------------------------

function GameViewLayer:ReconnectServer()
	if( not b_sendMsgCallback ) then  --Î´ÊÕµ½·þÎñÆ÷·µ»Ø£¬µôÏß´¦Àí
		self.btn_freestop:setVisible(false)
		self:setBtnEnble(true);
	end 
end
function GameViewLayer:GameUserScore()
	if( not self.ROLLING ) then  --Èç¹û¹ö¶¯¾ÍºöÂÔ
		local str = ExternalFun.numberThousands(self.BalanceText);
		self.GameBalanceText:setString(str)
	end 
end
--×Ô¶¯Ðý×ª¶¨Ê±Æ÷ 
local b_tongbu = false; --Í¬²½ ·ÀÖ¹ÖØ¸´µ÷ÓÃ
function GameViewLayer:autoRoll(dt)  	
	 if( not b_tongbu) then  
		b_tongbu=true;
		if self.autoCount <= 0 and  self.freeleft <=0 then --¹Ø±Õ×Ô¶¯Ðý×ª¶¨Ê±Æ÷
			self:startTime(false)
		end 
	 
		printf(tostring(self.RUNING).."-----"..self.autoCount) 
		--ÓÎÏ·´¦ÓÚÍ£Ö¹×´Ì¬£¬¿ªÊ¼ÐÂÓÎÏ·
		if not self.RUNING and (self.autoCount > 0 or self.freeleft > 0) then 
			if(self.freeleft > 0) then  --ÓÅÏÈ´¦ÀíÃâ·ÑÐý×ª 
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

--ÏÔÊ¾ÖÐ½±½á¹ûºó£¬ÉèÖÃÓÎÏ·ÎªÓÎÏ·½áÊø×´Ì¬
function GameViewLayer:gameOver()
	if(   self.freeleft<=0 and self.pan_free:isVisible()) then --×îºóÒ»´ÎÏÔÊ¾Í³¼ÆÐÅÏ¢
		self:runAction( cc.Sequence:create(cc.DelayTime:create(2.0),cc.CallFunc:create(function()
			--Í£Ö¹ÉùÒô
			AudioEngine.stopMusic()
			AudioEngine.stopAllEffects()
			AudioEngine.playEffect("mp3/BonusOver.mp3");
			self.freeleft = -1
			--require("app.views.system"):setBtnEnable(self,true);

			self.autoCount = 0 --Í£Ö¹Ãâ·ÑÐý×ª
			self.btn_autostop:setVisible(false)--Òþ²Østop

			self.btn_freestop:setEnabled(false)
			self.btn_freestop:setBright(false)
			self.btn_freestop:setVisible(false)
			self.btn_freespin:setVisible(false)
			self:setFreeSpinBtnEnble(false)
			
			self.isFreeOK = false
			self:setBtnEnble(true) --按钮启用 
			self.bFreeGameOver = true

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

			print("-------------- 免费结束 -------------")  
		end)));	
	end
	self.RUNING=false  
end


function GameViewLayer:freeGameOver()
	if self.bFreeGameOver then
		self:playBtnEffect()
		AudioEngine.stopMusic()
		self.freeWinCount=0 --Çå¿Õ×Ü¶î	 
		self.text_free_win:setString("0")
		self.pan_free:setVisible(false)
		self.text_spins_left:setString("0")
		self.FreeGame_OK=false
	end
end

--Ðý×ª½áÊøºóÅÐ¶ÏÊÇ·ñÖÐ½±£¬ÖÐ½±ÏÔÊ¾ÖÐ½±½á¹û£¬·ñÔòÉèÖÃÓÎÏ·×´Ì¬½áÊø
function GameViewLayer:doWIN() 
	self.bFreeGameOver = false
	--Ãâ·ÑÐý×ªÊ£Óà 
	self.freeleft_OK = false; 
	if self.freeleft >= 0 then
	 	self.freeleft_OK = true;
	end
	if not( self.rollBgMp3Id ==nil ) then  --Í£Ö¹±³¾°¹ö¶¯ÉùÒô
		AudioEngine.stopEffect(self.rollBgMp3Id)
	end
	if not(self.ScatterMp3Id ==nil) then 
		AudioEngine.stopEffect(self.ScatterMp3Id)
	end
	self._scene:stepOver()
	--ÅÐ¶Ï½á¹û
	self:buildTab() --»ñÈ¡½á¹û¼¯
	self.winLines,self.winOdds,self.winLinePoints  = self._scene._gameLogic:win( self.tab,self.lines )--ÅÐ¶Ï½á¹û¼¯
	self.winNumb = {} --Ïß
	
	self.FreeGameAgain_OK = false
	local winCount=0
	local BigTatolText = 0
	self.GameLineCount = 0
	self.nScatter = 0
	self.nGameWild = 0
	self.GameJackotTag = false

	for index,num_odds in pairs(self.winOdds) do 
		--Ó®ÁË¶àÉÙ = ÅâÂÊ* µ¥Ïß»¨·Ñ
		if self.winLines[index] == 0 then  --µ±ÏßÎª0µÄÊ±ºò±íÊ¾£¬ÈÎÒâÎ»ÖÃÖÐ½±£¬²Ê½ðÎª×Ü»¨·Ñ*ODD
			if(self.freeleft>=0) then 
				winCount = winCount+ num_odds * self.TotalBet * 3 
				table.insert(self.winNumb,num_odds * self.TotalBet  * 3);
			else 
				winCount = winCount+ num_odds * self.TotalBet
				table.insert(self.winNumb,num_odds * self.TotalBet);
			end
		else  
			if(self.freeleft>=0) then 
				local temp  =0;
				local includeDAGUI =false; 
				for index,point in pairs(self.winLinePoints[index]) do --»ñÈ¡µã 
					if tonumber(self.tab[point[1]][point[2]]) == 12 then
						includeDAGUI=true 
						break ;
					end
				end
				if(includeDAGUI) then   
					temp  =(num_odds * self.linebet /2)* 3;
				else 
					temp  =(num_odds * self.linebet)* 3;
				end 
	 			
	 			self.LineWins[index] = temp;
				winCount = winCount + temp;
				table.insert(self.winNumb,temp );
			else 
				self.LineWins[index] = num_odds * self.linebet
				winCount = winCount+ num_odds * self.linebet   --ÏßÖÐ½±ºó£¬²Ê½ðÎªÏß»¨·Ñ*ODD
				table.insert(self.winNumb,num_odds * self.linebet);
			end
		end
	end
	
	print("-------------------------------win or lost------------------------------");
	for indexKey,lineNum in pairs(self.winLines) do
		if lineNum > 0 then
			self.GameLineCount = self.GameLineCount + 1
	 		print(lineNum.." win "..self.LineWins[indexKey]);
	 	end
	end
	
	local WarnNum = 0;
	local BigWarn = self.serverWin/self.linebet;
	print("Line£º"..self.GameLineCount)
	print("Win£º"..winCount) 
	print("Bet£º"..BigWarn)

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
	--ScatterÖÐ½±¶¯»­
  	self:playAnim();

	--ÅÐ¶ÏÊÇ·ñÖÐÁËÈý¸öÒÔÉÏScatter
 	for i ,ico in pairs(self.serverIcos) do 
 		if ico == 11 then 
			self.nScatter = self.nScatter + 1  				
 		end 
 	end

 	 for i ,ico in pairs(self.serverIcos) do 
 		if ico == 12 then 
			self.nGameWild = self.nGameWild + 1  				
 		end 
 	end
 	----------------------------------------------------------------------------ÐÜÅÀÊ÷Ð¡ÓÎÏ·
 	if self.nScatter >= 3 then --ÖÐµ½Ãâ·ÑÐý×ª
		--Í£Ö¹¶¨Ê±Æ÷
		if self.autoCount > 0 then --Í£Ö¹×Ô¶¯Ðý×ª
	 		self.autoCount = 0
	 		self.btn_stop:setVisible(false);
	 		self.btn_autostop:setVisible(false)--Òþ²Østop
	 		self.btn_autospin:setVisible(true)
	 	end
	 	self:startTime(false)
	 	self:setBtnEnble(false) --°´Å¥½ûÓÃ
		self.GameWinScatter = true; 
		AudioEngine.playEffect("mp3/main/FreeGame_OK.mp3")
	end 

	if self.GameWinScatter then
		self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function()
			self:cleanWin();
			local fadein = cc.FadeIn:create(0.2)   
			local dt =cc.DelayTime:create(1) 
			local fadeout= cc.FadeOut:create(0.2) 
			self.BounsPicture:setVisible(true);
			self.BounsPicture:runAction(cc.Sequence:create(fadein:clone(),dt:clone(),fadeout:clone(),nil))

			self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function()
				self:goinTreeGame()
			end),nil))
		end),nil))
	end
 	----------------------------------------------------------------------------Ãâ·ÑÐý×ª
	if self:isFreeGame() then --ÖÐµ½Ãâ·ÑÐý×ª
		--Í£Ö¹¶¨Ê±Æ÷
		if self.autoCount > 0 then --Í£Ö¹×Ô¶¯Ðý×ª
	 		self.autoCount = 0
	 		self.btn_stop:setVisible(false);
	 		self.btn_autostop:setVisible(false)--Òþ²Østop
	 		self.btn_autospin:setVisible(true)
	 	end
	 	self:playAnim234()
	 	self:startTime(false)
		self.GameWinWild = true; 
		AudioEngine.playEffect("mp3/main/FreeGame_OK.mp3")
	end 

	if self.GameWinWild then
		if not self.FreeGame_OK then
			print("--------- Free OK -----------")
			self:setBtnEnble(false) --°´Å¥½ûÓÃ
			self.FreeGame_OK = true;
			self.gameWin =self.serverWin
			--require("app.views.system"):setBtnEnable(self,false);
			self.freeleft = 5
			playMp3Index = 999;
			self.btn_freespin:setVisible(true)
			self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function()
 				self.FreeGamePicture:setVisible(true)
			end),nil))
			self:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function()
 				self.FreeGamePicture:setVisible(false)
 				self:goinFreeGame()	
			end),nil))
		else
			self.FreeGameAgain_OK = true;
			self.freeleft = self.freeleft + 5
			print("---------Free ok Free-----------")
			local tip =cc.Sprite:create("freetip/15More.png")
			tip:setScaleX(1.6);
			tip:setScaleY(1.2);
			tip:setPosition(DWIDHT/2,DHIGHT+200):addTo(self) 
			tip:setLocalZOrder(MAXZORDER+1)
			tip:runAction(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(0,-(DHIGHT/2+200))),cc.DelayTime:create(2.0), cc.MoveBy:create(0.5, cc.p(0,(DHIGHT/2+200))),nil))
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

	if self.serverWin > 0 then
		--¶¥²¿ÏÔÊ¾ÖÐÁË¶àÉÙÏß
		if self.GameLineCount > 0 then
			self:GameLineShow()
		end
		self:GameTotalShow()
		self:GameWinLine(winCount)
	else 
		self:GameBalanceMoveOver()
		if self.GameJackotTag == false and not self.FreeGame_OK and self.nScatter < 3 then
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

--ÖÐ½±ÏßºÍWin½±½ð
function GameViewLayer:GameWinLine(winCount)
	if not (self.serverWin == winCount) then 
		print("##################Wrong : "..self.serverWin .."===".. winCount)
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
	if bFiveLine and self.nGameWild < 3 then --(五连线和免费同时出现，不播五连线动画)
		self:showFive(win5indexs,1)
	else
		self:goShowWinline()
	end
end

function GameViewLayer:showFive(win5indexs,index)
	-- self.bFiveLine = true
	-- AudioEngine.playEffect("mp3/main/5ofAKind.mp3")
	-- self.AniFiveLine = cc.Sprite:create("Jackpot/5ofkind0.png")----ccs.Armature:create("5ofkind")
	-- self.AniFiveLine:setPosition(cc.p(1334/2,750/2));
	-- self.AniFiveLine:setLocalZOrder(10)
	-- --self.AniFiveLine:getAnimation():playWithIndex(0)
	-- self:addChild(self.AniFiveLine);
	-- self:runAction(cc.Sequence:create(cc.DelayTime:create(3.2),cc.CallFunc:create(function()
	-- 	self.bFiveLine = false
	-- 	self.AniFiveLine:removeFromParent(true);
	 	self:goShowWinline()
	-- end),nil))
end

function GameViewLayer:goShowWinline()
	self:GameShowScore();
	if self.freeleft >= 0 and self.freeleft_OK then  -- Ãâ·ÑÓÎÏ·ÇåËã×ÜºÍ
		self.freeWinCount = self.freeWinCount + self.serverWin 
		self.text_free_win:setString(self.freeWinCount)
	end 

	-----------------ÖÐ½±ºóÏÔÊ¾ËùÒÔÖÐ½±ÏßºÍÖÐ½±¿ò1Ãë--------------------------
	local fadein = cc.FadeIn:create(0.2)   
	local dt =cc.DelayTime:create(0.5) 
	local fadeout= cc.FadeOut:create(0.1) 
	for indexKey,lineNum in pairs(self.winLines) do 
		if(lineNum>0) then 
			self.table_lines[lineNum]:setVisible(true)  
			self.table_lines[lineNum]:runAction(cc.Sequence:create(fadein:clone(),dt:clone(),fadeout:clone(),nil)) --ÏÔÊ¾ÖÐ½±Ïß¡¢
		end 
	end
	
	--self.sp_tipwin:setVisible(true)
	--self.text_tipwin:setVisible(true)
	--------------------------------------------------------------------------
	self:setBtnEnble(false) --°´Å¥½ûÓÃ
	self:setFreeSpinBtnEnble(false)
	self:runAction(cc.Sequence:create(cc.DelayTime:create(nWinTime),cc.CallFunc:create(function()
		if not self.FreeGame_OK and self.nScatter < 3 then
			self:setBtnEnble(true) --°´Å¥ÆôÓÃ
		else
			if self.freeleft > 0 and not self.FreeGameAgain_OK then
				self:setFreeSpinBtnEnble(true);
			end
		end
	end),nil))

	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
		self:showWinline() 
	end),nil))
end

function GameViewLayer:GameShowScore() --·ÖÊý¹ö¶¯ÏÔÊ¾
	--µÃ·Ö¹ö¶¯
	local textWin=0;
	local numb1 = 0;
	local GameBalanceMoveOver = false;

	local numbWin = self.serverWin;
	if numbWin > 0 and numbWin < 100 then
		self.stepWin = 1;
	elseif numbWin >= 100 and numbWin < 1000 then
		self.stepWin = 18;
	elseif numbWin >= 1000 and numbWin < 10000 then
		self.stepWin = 151;
	elseif numbWin >= 10000 and numbWin < 100000 then 
		self.stepWin = 1471;
	elseif numbWin >= 100000 and numbWin < 1000000 then
		self.stepWin = 13461;
	elseif numbWin >= 1000000 and numbWin < 10000000 then
		self.stepWin = 143461;
	elseif numbWin >= 10000000 then
		self.stepWin = 1543461;
	end

	self.text_win:setString("0");
	self.text_win:setVisible(true)
	textWin=0;
	numb1 = self.serverWin;
	self.text_win:setString(textWin);
	self.text_tipwin:setString(textWin);
	self.schedulerIDWin3 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
		textWin = textWin+self.stepWin;
		self.text_win:setString(textWin);
		self.text_tipwin:setString(textWin);
		if(textWin>=numb1)then
			self.text_win:setString(numb1);
			self.text_tipwin:setString(numb1);
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerIDWin3);
			--self:GameTotalShow()
			self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(function()
	 			self.sp_tipwin:setVisible(false)
	 			self.text_tipwin:setVisible(false)
	 			--self:showWinline()
			end),nil))
		end
	end, 0.02, false);

	--×Ü·Ö¹ö¶¯
	local textBalance = self.BalanceText 
	local numb = self.serverWin+self.BalanceText;

	--self.VoiceWinGold =AudioEngine.playEffect("mp3/main/Score.mp3",true)
	local str = ExternalFun.numberThousands(textBalance);
	self.GameBalanceText:setString(str);
	self.schedulerIDWin2 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
		--AudioEngine.stopEffect(self.VoiceWinGold);
		textBalance = textBalance+self.stepWin;
		local str = ExternalFun.numberThousands(textBalance);
		self.GameBalanceText:setString(str);
		if(textBalance>=numb)then
			local str = ExternalFun.numberThousands(numb);
			self.GameBalanceText:setString(str);
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerIDWin2);
			
			self:GameBalanceMoveOver()
		end
	end, 0.02, false);
	self.BalanceText = self.BalanceText + self.serverWin;

end

--结果显示错误处理
function GameViewLayer:GameBalanceMoveOver()
	printf("=================== 转动停止 ===================")
	printf("【桌面分】："..self.BalanceText)
	printf("【大厅分】："..GlobalUserItem.lUserScore)
	printf("================================================")
	if self.BalanceText ~= GlobalUserItem.lUserScore then
		self.BalanceText = GlobalUserItem.lUserScore;
		local str = ExternalFun.numberThousands(self.BalanceText);
        self.GameBalanceText:setString(str)
	end
end

--°´Å¥ÒôÐ§
function GameViewLayer:playBtnEffect()
	AudioEngine.playEffect("mp3/Button.mp3")
end

function GameViewLayer:buildTab()
	for indexKey,pan_1 in pairs(self.table_pans) do
		for index,sprite in pairs(pan_1:getChildren()) do
			self.tab[indexKey][index] = sprite:getName()
			--printf(sprite:getName())
		end 
	end 
end

function GameViewLayer:startGameByNet(flag,bFree)  --·¢ËÍ¿ªÊ¼Ðý×ª
	--Óà¶îÅÐ¶Ï ÓÃ»§Óà¶îÉÙÓÚÓÃ»§»¨·Ñ ÔòÌáÊ¾
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
		
		-- self.autoCount = 0--¹Ø±Õ×Ô¶¯Ðý×ª¶¨Ê±Æ÷ 
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
	
	if(self.RUNING == false ) then  --ÒÑ¾­·¢ËÍÁËÆô¶¯ÇëÇóÆÁ±Î
		self:freeGameOver()
		AudioEngine.stopAllEffects()
		self:cleanWin()
		if(self.freeleft <0) then 
			AudioEngine.playEffect("mp3/ButtonSpin.mp3") 
			self:GameBJMp3()
		end 
		self:setBtnEnble(false) --°´Å¥½ûÓÃ
		self:setFreeSpinBtnEnble(false);

		self.BalanceText = GlobalUserItem.lUserScore
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

		--²ÎÊý1 ÏßÊý£¬Ïß»¨·Ñ£¬×Ü»¨·Ñ
		self.TotalBet = (self.bet[self.betIndex]*self.lines) --×ÜÑº×¢
		self.linebet = self.bet[self.betIndex] --µ¥ÏßÑº×¢
		b_sendMsgCallback  = false;
		print("------·下注÷----")
		print("self.lines"..self.lines)
		print("self.TotalBetº"..self.TotalBet)
		print("self.linebet"..self.linebet)
		print("-------------------------------")
		self.GameRollFunNum = 0;
		self._scene:startGame(self.lines,self.TotalBet,self.linebet,bFree) --¿ªÊ¼ÓÎÏ·£¬·¢ËÍ¸ø·þÎñ¶Ë
		self.RUNING=true
		--ÓÎÏ·¿ªÊ¼Á¢ÂíÐý×ª£¬½ÓÊÕµ½ÍøÂçÏûÏ¢ºóÍ£Ö¹¡£
		self:GameRollFun(1);

		if flag then --×Ô¶¯Ðý×ª
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

--¶ÏÏßÖØÁ¬
function GameViewLayer:reConnect()
	--local app = require("app.MyApp")
	--print("############nfreetime####"..tostring(app.nfreetime))
	if self._scene.nfreetime ~=nil  and self._scene.nfreetime > 0 then
		print("ÖØÖÃµ½Ãâ·ÑÓÎÏ·") 
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
		tipLayer:addTo(self,102)
		--self:addChild(tipLayer)
	 	--³õÊ¼»¯¿¨ÅÆ 
		for indexKey,pan_1 in pairs(self.table_pans) do
			self:initNewCard(0,pan_1,{self._scene.icon[indexKey+10],self._scene.icon[indexKey+5],self._scene.icon[indexKey]}) --Ìí¼ÓÐÂ¿¨ÅÆ
		end
	else 
		self:initCard() 
	end 
end

--¶ÏÏßÖØÁ¬Ñ¡Ôñ½øÈë
function GameViewLayer:OngoGameFree() 
	AudioEngine.playMusic("mp3/FreeGame.mp3",true)
	--local app = require("app.MyApp")
	--ÏÔÊ¾Ãâ·ÑÓÎÏ·
	self.FreeGame_OK = true;
	self.pan_free:setVisible(true)

	self.freeleft =  self._scene.nfreetime
	self.gameWin= self._scene.nGameWin
	self.lines = self._scene.nbetline;
	self.freeWinCount=self._scene.nFreeCountWin
	self.text_free_win:setString(self._scene.nFreeCountWin)
	self.text_spins_left:setString(self.freeleft)

	-----------------------------------------------------------
	print("---------------------重连回来免费--------------------")
	print("¡¾Ãâ·Ñ´ÎÊý¡¿£º"..self._scene.nfreetime)
	print("¡¾½øÃâ·ÑÓ®¡¿£º"..self._scene.nGameWin)
	print("¡¾µ¥ÏßÑº×¢¡¿£º"..self._scene.nlinebet)
	print("¡¾Ñº×¢ÏßÂ·¡¿£º"..self._scene.nbetline)
	print("¡¾Ãâ·ÑÓ®¡¿£º"..self._scene.nFreeCountWin)
	print("-------------------------------------------------")

	for i,bet in pairs(self.bet) do
		if bet == self._scene.nlinebet then
			self.betIndex = i
		end
	end
	self:updateText() --¸üÐÂÎÄ±¾
	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
	 	print("---------------Ãâ·ÑÐý×ª¿ªÊ¼×ª¶¯--------------")
		 self:autoRoll()
		self:startTime(true)
		self.isFreeOK = true
	end),nil))
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

--³õÊ¼»¯¿¨ÅÆ
function GameViewLayer:initCard()
	--printf("³õÊ¼»¯¿¨ÅÆ")
	--ÃüÃû×ø±ê ´Ó×óÏÂ½Ç 1-1¿ªÊ¼
	--×Ö·û´®Ê¹ÓÃ ..Æ´½Ó
	for indexKey,pan_1 in pairs(self.table_pans) do
		for i = 1 , 3 do 
			--local num = math.random(0,11)
			--local card1_1 = cc.Sprite:create("card/"..num..".png") 
			local card1_1 = cc.Sprite:create("card/12.png")
			card1_1:setScaleX(1.6);
			card1_1:setScaleY(1.2);
			card1_1:setAnchorPoint(0,0); 
			card1_1:setPosition(0,142*(i-1)  );
			pan_1:addChild(card1_1)
		end
	end
end 

--³õÊ¼»¯ÐÂ¿¨ÅÆ
function GameViewLayer:initNewCard(count,pan_1,col3ByFoot)
	local height= count*115*1.2
	--printf("ÐÂ³õÊ¼»¯¿¨ÅÆ")
	for i = 1 , 3 do 
		local  value = col3ByFoot[i]
		local card1_1 = cc.Sprite:create("card/"..value..".png") 
		card1_1:setScaleX(1.6);
		card1_1:setScaleY(1.2);
		card1_1:setName(value)
		card1_1:setAnchorPoint(0,0); 
		 
		if(count==0) then 
			card1_1:setPosition(0,142*(i-1) );
		else
			card1_1:setPosition(0,height+421+142*(i-1) );
		end 
		pan_1:addChild(card1_1)
	end
end

--¸üÐÂÎÄ±¾
function GameViewLayer:updateText()
	self.text_lines:setString(self.lines)
	self.text_totalbet:setString(self.bet[self.betIndex]*self.lines)
	self.text_bet:setString(self.bet[self.betIndex])
	for i = 1 , MAXLINE do 
		if i < self.lines+1 then
			self.table_BtnLines[i]:setVisible(false)
			self.table_DarkBtnLines[i]:setVisible(false)
		else
			self.table_BtnLines[i]:setVisible(true)
			self.table_DarkBtnLines[i]:setVisible(true)
		end
	end
end

--µã»÷stop
function GameViewLayer:stopRall() 
	self:GameBetIndex();
	self.GameStopOK = true;

 	for indexKey,pan_1 in pairs(self.table_pans) do
		pan_1:removeAllChildren();
		self:initNewCard(0,pan_1,{self.serverIcos[indexKey+10],self.serverIcos[indexKey+5],self.serverIcos[indexKey]}) --Ìí¼ÓÐÂ¿¨ÅÆ
	end
	for indexKey,pan_1 in pairs(self.table_pans) do
		local size =#pan_1:getChildren()
		local height =0
		local dt =cc.DelayTime:create(indexKey+0.01)
		for index,sprite in pairs(pan_1:getChildren()) do
			sprite:stopAllActions() --¹Ø±Õ¶¯»­
			--[[]]--
			if  index >size-3  then --»ñÈ¡×îºó3¸öÔªËØ,Ö±½Ó³öÏÖ
				sprite:setPositionY(height)
				height=height+142

				local movUp2 = cc.MoveBy:create(0.1,cc.p(0,-5))--½áÊø»Øµ¯
				local movDown2 = cc.MoveBy:create(0.1,cc.p(0,5))--½áÊø»Øµ¯
				local seq = cc.Sequence:create(movUp2,movDown2)
				if indexKey > self.rollCountTemp/2 then
					sprite:runAction(seq)
				end
			else --ÒÆ³ýÒÔÇ°µÄ
				sprite:removeFromParent(true)
			end
		end
	end

	for k,v in pairs(self.tab_xing) do 
		v:removeFromParent(true); 
	end 
	self.tab_xing ={};
end

--¿ªÊ¼Ðý×ª.ÓÉÍøÂç»Øµ÷
function GameViewLayer:startRoll(icos,win)
	self.ROLLING = true;
	b_sendMsgCallback = true;
	self.serverWin = win;
	self.serverIcos =icos;
	--¿ªÊ¼ÓÎÏ·£¬·¢ËÍ¸ø·þÎñ¶Ë ¿ØÖÆ²»Í¬°´Å¥ÏÔÊ¾
	if self.autoCount > 0 then
		self.btn_autostop:setEnabled(true);
		self.btn_autostop:setBright(true);
	end

	if self.autoFlag==AUTOROLL then --×Ô¶¯Ðý×ª
		self.btn_autostop:setVisible(true)--ÏÔÊ¾stop
		self.btn_stop:setVisible(true);
	elseif self.autoFlag==FREEROLL then --Ãâ·ÑÐý×ª  
		--self.rollBgMp3Id = AudioEngine.playEffect("mp3/Rolling.mp3") 
		self.text_spins_left:setString(self.freeleft)
		
		self.btn_freespin:setEnabled(false);
		self.btn_freestop:setEnabled(true);
		self.btn_freestop:setBright(true);
		self.btn_freestop:setVisible(true);	
	else
		self.btn_stop:setVisible(true)--ÏÔÊ¾stop
	end  

	--Ãâ·ÑÓÎÏ·²»ÓÃ¼õ»ý·Ö
	if(self.freeleft == -1) then 
		self.BalanceText = self.GameOldSocre - self.TotalBet;
		local str = ExternalFun.numberThousands(self.BalanceText);
		self.GameBalanceText:setString(str)
	end 
end

--ÔÙ´ÎÁ¬½Ó½ºÆ¬ºóµÄ»Øµ÷
function GameViewLayer:startRollBegin(icos,win)
	self.rollCount=0--¼ÇÂ¼¹ö¶¯Íê³É 
	self.rollCountTemp=0;
	--self:showLines(0) --Òþ²ØÖÐ½±Ïß	 
	--self:setBtnEnble(false) --°´Å¥½ûÓÃ
	--¶¯»­»Øµ÷º¯Êý
	local function callback(sender)  
		sender:stopAllActions()
		sender:removeFromParent(true) 
		self.rollCountTemp = self.rollCountTemp + 1;
	end 
	--¹ö¶¯Íê³É»Øµ÷º¯Êý
	local function rollOver(sender)  
		self.rollCount=self.rollCount+1
		if self.rollCount>=5 then
			self:GameBetIndex();
			self.ROLLING = false
			self:doWIN() 
			if self.autoFlag == AUTOROLL and self.autoCount<=0 then
				self.btn_autostop:setVisible(false)--Òþ²Østop
			elseif  self.autoFlag == FREEROLL then
				self.btn_freestop:setVisible(false);
			else
				self.btn_stop:setVisible(false)--Òþ²Østop
			end
		end
	end

	--¶¨ÒåÃ»¶ÎµÄ¹ö¶¯¸öÊý ¹ö¶¯³¤¶È
	--¶¨ÒåË³Ðò
	local tab_indexs ={1,6,11,2,7,12,3,8,13,4,9,14,5,10,15};
	local scatCount =  0 ;--ÓÐ¼¸¸öscat 
	local idx =1; 
	for scatCountIdx=1 ,15 do 
		if icos[tab_indexs[idx]] == 11 then 
			scatCount = scatCount+1;
		end   
		if scatCount==2 then --³¬¹ýÁË2¸ö
			break;
		end 
		idx=idx+1; 
	end

	local fast =math.floor((idx-1)/3) 
	local rollConuts ={1,5,9,13,17} --¶¨ÒåÃ»¶ÎµÄ¹ö¶¯¸öÊý ¹ö¶¯³¤¶È
	local idx2=1;
	for i=1,5 do 
		if (fast+1) < i and fast < 4 then --×îºóÒ»ÐÐºóÃæÃ»¼ÓËÙ
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
		local roll = self:createRoll(rollconut,indexKey) --Ìí¼Ó½º´ø 25±íÊ¾¶àÉÙ¸ö½º´ø	
		pan_1:addChild(roll) 
		self:initNewCard(rollconut,pan_1,{icos[indexKey+10],icos[indexKey+5],icos[indexKey]}) --Ìí¼ÓÐÂ¿¨ÅÆ
		local height =rollconut*115*1.2 + 421 --½º´ø³¤¶È+´°¿Ú³¤¶È
		for key,value in pairs(pan_1:getChildren()) do 
			value:stopAllActions(); 

			if key <= 2 then  --Ç°Ãæ4¸ö¶¯»­½áÊø£¬ÒªÇå³ýµô
				local mov = cc.MoveBy:create(height/1700,cc.p(0,-height))--Ê±¼ä=s/v
				local movUp2 = cc.MoveBy:create(0.1,cc.p(0,-50))--½áÊø»Øµ¯
				local movDown2 = cc.MoveBy:create(0.1,cc.p(0,50))--½áÊø»Øµ¯
				local seq = cc.Sequence:create(mov,cc.CallFunc:create(callback),movUp2,movDown2,nil)
				value:runAction(seq)
			elseif key <= 4 then --ÖÐ¼ä2¸ö²»ÓÃ»Øµ÷
				local mov = cc.MoveBy:create(height/1700,cc.p(0,-height))--Ê±¼ä=s/v
				local movUp2 = cc.MoveBy:create(0.1,cc.p(0,-50))--½áÊø»Øµ¯
				local movDown2 = cc.MoveBy:create(0.1,cc.p(0,50))--½áÊø»Øµ¯
				local seq = cc.Sequence:create(mov,movUp2,movDown2,nil)
				value:runAction(seq)
			elseif key == 5 then --×îºóÒ»¸öÖ´ÐÐ¹ö¶¯Íê³É»Øµ÷
				local mov = cc.MoveBy:create(height/1700,cc.p(0,-height))--Ê±¼ä=s/v
				local movUp2 = cc.MoveBy:create(0.1,cc.p(0,-50))--½áÊø»Øµ¯
				local movDown2 = cc.MoveBy:create(0.1,cc.p(0,50))--½áÊø»Øµ¯
				local seq = cc.Sequence:create(mov,cc.CallFunc:create(function()
				--²¥·Å²»Í¬µÄÍ£Ö¹ÒôÐ§
					local has11 =false
					for index,value in pairs (self.table_pans[self.rollCount+1]:getChildren()) do 
						if value:getName()=="11"  then  
							has11=true
							scatterIndex = scatterIndex + 1
						end
					end

					--Ìí¼Ó»Æ½ð±ß¿ò 
					for k,v in pairs(self.tab_xing) do 
						v:removeFromParent(true); 
					end 
					self.tab_xing ={};
					
					if scatterIndex-1 >=2 and self.rollCount+1 < 5 then 
						local x,y =self.table_pans[self.rollCount+1]:getPosition();
						local sp =cc.Sprite:create("xing/1.png")
						
						local star_anim=cc.Animation:create()
						for i=1,11 do
							star_anim:addSpriteFrameWithFile(string.format("xing/%d.png",i))
						end
						star_anim:setDelayPerUnit(0.1) 
						local star_action=cc.Animate:create(star_anim)
						 
						sp:runAction(cc.RepeatForever:create(star_action:clone()));
						sp:setPosition(x+280+13,y+550/2 -65);
						sp:setScaleX(1.32)
						sp:setScaleY(1.04)
						self:addChild(sp);
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

--´´½¨½º´ø ¼¸¸ö¹ö¶¯·½¸ñ
function GameViewLayer:createRoll(count,indexKey)
	local sum =count/8 --ÍêÕû¿é¸öÊý
	--141¸ß¶È£¬135¿í¶È
	local height = (count%8)*115 --Ê£ÏÂµÄ¿í¶È
	local roll =nil ;
	local roll1Height = 460;

	local str_roll1 = nil;
	local str_roll2 = nil;

	local temp_roll = 0;
	local random_roll = 1;
	local random_roll1 = 1;
	local randomWild = math.random(1,5)

	if randomWild == 1 then
		temp_roll = 3;
		if indexKey == 1 or indexKey == 5 then
			random_roll = 2
			random_roll1 = 2
		else
			random_roll = math.random(1,2)
			random_roll1 = math.random(1,2)
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
		roll = cc.Sprite:createWithTexture(texture,cc.rect(0,0,115,height)) --´ÓÉÏÏòÏÂ¼ôÇÐ
	else
		local texture = cc.Director:getInstance():getTextureCache():getTextureForKey(str_roll1)
		local texture2 = cc.Director:getInstance():getTextureCache():getTextureForKey(str_roll2)

		roll = cc.Sprite:createWithTexture(texture,cc.rect(0,0,115,roll1Height)) --´ÓÉÏÏòÏÂ¼ôÇÐ
		local roll2 = cc.Sprite:createWithTexture(texture2,cc.rect(0,0,115,height-roll1Height))
		roll2:setAnchorPoint(0,0)
		roll2:setPositionY(roll1Height);
		roll:addChild(roll2);
	end
	--Ìí¼ÓÍêÕû¿é
	for i = 1 , sum do
		local _r1 = cc.Sprite:create(str_roll1)
		local _r2 = cc.Sprite:create(str_roll2)
		_r2:setAnchorPoint(0,0)
		_r2:setPositionY(roll1Height);
		_r1:addChild(_r2)
		_r1:setAnchorPoint(0,0)
		_r1:setPositionY(height+(i-1)*920) --Æ´½Óµ½Í¼Æ¬ÉÏ²¿
		roll:addChild(_r1)
	end
	--ÉèÖÃÎ»ÖÃ
	roll:setScaleX(1.6);
	roll:setScaleY(1.2);
	roll:setAnchorPoint(0,0)
	roll:setPosition(0,464)
	return roll
end

--°´Å¥¿ØÖÆ
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

--Çå³ýÓ®ÁËµÄ¶¯»­ºÍÔªËØ¿ò
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

	self.GameTotal:setVisible(false)
	self.sp_tipwin:setVisible(false)
	self.text_tipwin:setVisible(false)
	self.GameScatterWinOK = false;
	self.GameStopOK = false;
	self.rollCountTemp = 0;
	self.GameLine:setVisible(false)
	self.GameWin:setVisible(false)
	self.GameScatter:stopAllActions()
	self.GameScatter:setVisible(false)
	self:cleanBigwin(); --¹Ø±Õbigwin
	--Çå³ý¶¨Ê±Æ÷
	self:stopAllActions()
	self.btn_stop:stopAllActions()
	
	self.GameWinScatter = false; 
	self.GameWinWild = false;

	--Çå³ý¿ò¿ò
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

	--Scatter»ð¶¯»­
	for k,v in pairs(self.tab_xing) do 
		v:removeFromParent(true); 
	end 
	self.tab_xing ={};

	--½øÈëÃâ·Ñ¶¯»­
	for k,v in pairs(self.Game_gofree) do
		v:removeFromParent(true);
	end
	self.Game_gofree ={};
	
	--ÖÐ½±Ïß¶¯»­Çå³ý
	for indexKey,sprite_line in pairs(self.table_lines) do
		sprite_line:stopAllActions()
		sprite_line:setOpacity(255) 
		sprite_line:setLocalZOrder(998) 
		sprite_line:setVisible(false)
	end

	for i=1,5 do 
		self.table_pans[i]:setLocalZOrder(0)
		self.table_pans[i]:stopAllActions()
	end

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
end

--Æô¶¯Ðý×ª¶¨Ê±Æ÷
function GameViewLayer:startTime(b_restart)
		if self.autoSchedulerEntry~=nil then 
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.autoSchedulerEntry)
		end
		self.autoSchedulerEntry = nil  
		if b_restart then 
			self.autoSchedulerEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.autoRoll), 1, false)
		end 
end 

--Ãâ·ÑÓÎÏ·
function GameViewLayer:goinFreeGame() 
	print("------------½øÈëÃâ·ÑÓÎÏ·-------------")
	self:stopAllActions();
	self.RUNING =false;
	self:cleanWin();
	self.pan_free:setVisible(true)
	self.text_spins_left:setString(self.freeleft)
	self.text_free_win:setString("0")

	self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
	 	print("---------------Ãâ·ÑÐý×ª¿ªÊ¼×ª¶¯--------------")
		self:autoRoll()
		self:startTime(true)
		AudioEngine.playMusic("mp3/FreeGame.mp3",true)
		self.isFreeOK = true
	end),nil))

end

--ÐÜÅÀÊ÷ÓÎÏ·
function GameViewLayer:goinTreeGame() 
	print("-----------进小游戏了----------")
	self.z_climpLayer = ClimpScene:create(self)
	:addTo(self,10)

	-- local view =self:getApp():createView("ClimpScene") 
	-- local scene = display.newScene("ClimpScene")
	-- scene:addChild(view)
	-- cc.Director:getInstance():pushScene(scene)  
end

function GameViewLayer:playAnim234() --234ÁÐÐÜÐèÒª²¥·Å¶¯»­
	--¿É±ä    
	local animationWild =cc.Animation:create()
	for i = 1 ,20 do 
		local str = string.format("Animation/12/%d.png",(i-1))
		animationWild:addSpriteFrameWithFile(str)
	end
	animationWild:setLoops(2) --²¥·Å2´Î
	animationWild:setDelayPerUnit(2/20)
	local animateWild = cc.Animate:create(animationWild);
	
	for  i =2,4 do 
		for index,card in pairs(self.table_pans[i]:getChildren()) do --ÏÔÊ¾µã  
			if card:getName()== "12" then ----¿É±ä¶¯»­
				local seq =cc.Sequence:create(animateWild:clone(),nil)
				local rf =cc.RepeatForever:create(seq)
				card:stopAllActions();
				card:runAction(rf);
			end 
		end 
	end 
end 

function GameViewLayer:playAnim() 
	--ÈÎÒâÎ»ÖÃ
	local animationScatter =cc.Animation:create()
	for i = 1 ,11 do 
		local str = string.format("Animation/11/%d.png",(i-1))
		animationScatter:addSpriteFrameWithFile(str)
	end
	animationScatter:setLoops(2) --²¥·Å2´Î
	animationScatter:setDelayPerUnit(2/11)
	local animateScatter = cc.Animate:create(animationScatter);

	--¿É±ä  
	local animationWild =cc.Animation:create()
	for i = 1 ,20 do 
		local str = string.format("Animation/12/%d.png",(i-1))
		animationWild:addSpriteFrameWithFile(str)
	end
	animationWild:setLoops(2) --²¥·Å2´Î
	animationWild:setDelayPerUnit(2/20)
	local animateWild = cc.Animate:create(animationWild);

	for index,line in pairs(self.winLinePoints) do --ÏÔÊ¾µã 
		for index2,point in pairs(line) do 
			if ( self.tab[point[1]][point[2]] == "11") then  --ÈÎÒâÎ»ÖÃ¶¯»­
			 	local seq =cc.Sequence:create(dt,animateScatter:clone(),dt2,nil)
				local rf =cc.RepeatForever:create(seq)
				self.table_pans[point[1]]:getChildren()[point[2]]:runAction(rf)
			elseif  self.tab[point[1]][point[2]] == "12" then ----¿É±ä¶¯»­
			 	local seq =cc.Sequence:create(animateWild:clone(),nil)
				local rf =cc.RepeatForever:create(seq)
				--self.table_pans[point[1]]:getChildren()[point[2]]:runAction(rf)
				local layout = cc.Sprite:create("Animation/12/0.png")
				layout:setScaleX(1.6);
				layout:setScaleY(1.2);
				layout:setLocalZOrder(MAXZORDER+1-point[2])
				layout:setPosition(point[1]*203+30+30,point[2]*141+70+60);
				layout:runAction(rf);
				table.insert(self.table_winStars,layout)
				self._csbNode:addChild(layout)
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

	local count =#self.winLines
	local countTime = 2.5 --ÖÐ½±¶¯»­Ö´ÐÐÊ±¼ä

	--ÔËÐÐÍêÒ»ÂÖºó  ¼ÌÐø×Ô¶¯Ðý×ª--self.RUNING
	if (self.autoCount > 0  ) and self.autoSchedulerEntry~=nil  then  --¶¨Ê±Æ÷Ã»ÓÐ¹Ø±Õ²ÅµÈ´ý
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
	elseif self.freeleft >= 0 then  --²¥·ÅÍæ¶¯»­¿ªÊ¼ÏÂÒ»ÂÖ
		local time = 0
		if self.freeleft == 0 then
			print("------------------------Ãâ·ÑÐý×ª×îºóÒ»´ÎÁË--------------------------")
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
		self:gameOver()--ÉèÖÃÓÎÏ·Í£Ö¹
	end


	local nTime = 0
	--self:ScatterWinShow(); --ÊÇ·ñÓÐScatterµÃ·Ö
	if self.GameScatterWinOK then
		nTime = 1.5;
	end

	local function zorder(sender) --¿ªÊ¼µ÷Õûµ½Ç°Ãæ
		sender:setVisible(true);
	 	sender:setLocalZOrder(1);
	 	--sender:setOpacity(0)
	 	self.GameLine:setVisible(false)
		self.GameWin:setVisible(false)

	 	for indexKey,lineNum in pairs(self.winLines) do
			if sender:getName() == ("line"..lineNum) then
				--print("¡¾ÏßÂ·¡¿£º"..tonumber(lineNum).."¡¾½ðÇ®¡¿:"..self.LineWins[indexKey]/100)

				--self:runAction(cc.Sequence:create(cc.DelayTime:create(nTime),cc.CallFunc:create(function()
					self.GameScatterWinOK = false;
				 	self.GameScatter:setVisible(false);
					self:LineWinShow(tonumber(lineNum),self.LineWins[indexKey])
				--end),nil))
			end
		end

		if( playMp3Index <= #self.winLines) then   	
			local has12 = false; 
			for index,point in pairs(self.winLinePoints[playMp3Index])  do 
				local ind  = tonumber(self.tab[point[1]][point[2]])
				if(ind==12 ) then 
					has12 =true;
					break ;
				end 
			end
			if( self.freeleft ==-1 ) then 
				if(has12) then 
					AudioEngine.playEffect("mp3/Wild.mp3") 
				else 
					for index,point in pairs(self.winLinePoints[playMp3Index])  do
						local ind  = tonumber(self.tab[point[1]][point[2]]) 
						if ind < 6 then  
							AudioEngine.playEffect("mp3/WinNumber.mp3") 
						else  
							AudioEngine.playEffect("mp3/WinAnimal.mp3")
						end 
						break;
					end 
				end  
			end
			playMp3Index =playMp3Index+1  
		else 
			AudioEngine.playEffect("mp3/Line.mp3")
		end  
	end

	----------------------ÖÐ½±ºóÏß ¿ò Í¼±ê¶¯»­-------------------------------------
	-- --×Ï¿ò¶¯»­³õÊ¼»¯
	-- local animation =cc.Animation:create()
	-- for i = 1 ,17 do 
	-- 	local str = string.format("Animation/kuang/%d.png",i-1)
	-- 	animation:addSpriteFrameWithFile(str)
	-- end
	-- animation:setLoops(3) --²¥·Å3´Î
	-- animation:setDelayPerUnit(0.5/17)
	-- local animate = cc.Animate:create(animation)



	local n_Animate = nil;
	local n_CardNum = 0;
	--Í¼±êÉÁ¶¯ ¿ò¶¯»­
	for index,line in pairs(self.winLinePoints) do --ÏÔÊ¾µã
		for index2,point in pairs(line) do
			local dt =cc.DelayTime:create(0+(index-1) * countTime)
			local dt2 =cc.DelayTime:create( (count-index) * countTime)
			local fadein = cc.FadeIn:create(0.2)
			local fadeout= cc.FadeOut:create(0.2)
			n_CardNum = tonumber(self.tab[point[1]][point[2]]);
			if n_CardNum < 11 then --Êý×ÖÉÁ¶¯
				local seq =cc.Sequence:create(dt,fadeout:clone(),cc.DelayTime:create(0.2),
												fadein:clone(),cc.DelayTime:create(0.3),
												fadeout:clone(),cc.DelayTime:create(0.2),fadein:clone(),
												cc.DelayTime:create(0.5),dt2,nil)
				local rf =cc.RepeatForever:create(seq)
				self.table_pans[point[1]]:getChildren()[point[2]]:runAction(rf);
			else --Í¼±ê¶¯»­
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
		end
	end
	----------------------------------------------------------------------------------
	--ÖÐ½±ÏßÉÁ¶¯
	for indexKey,lineNum in pairs(self.winLines) do
		-- if  (tonumber(lineNum) > 0) then
		-- 	local fadein = cc.FadeIn:create(0.2)
		-- 	local fadeout= cc.FadeOut:create(0.2)
		-- 	dt =cc.DelayTime:create(0+(indexKey-1) * countTime)
		-- 	dt2 =cc.DelayTime:create( (count-indexKey) * countTime)
		-- 		-- ÏßÌõÏÔÊ¾0.2£¬ÏûÊ§0.3£¬
		-- 	local seq =cc.Sequence:create(dt,cc.CallFunc:create(zorder),fadeout,
		-- 								 cc.DelayTime:create(0.2),
		-- 								 fadein,cc.DelayTime:create(0.3),fadeout,cc.DelayTime:create(0.2),
		-- 								 fadein,cc.DelayTime:create(0.3),fadeout,dt2,nil)
		-- 	local rf =cc.RepeatForever:create(seq)
		-- 	self.table_lines[lineNum]:setVisible(true)
		-- 	self.table_lines[lineNum]:setOpacity(0)
		-- 	self.table_lines[lineNum]:runAction(rf) --ÏÔÊ¾ÖÐ½±Ïß¡¢
		-- end
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

-----------------------------------------¶¥²¿ÖÐ½±ÌáÊ¾-------------------------------
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
	local nTotalbet = self.bet[self.betIndex]*self.lines; --×ÜÑº×¢
	local nScatterWin = 0;

	if self.nScatter == 2 then
		nScatterWin = nTotalbet*1;
	elseif self.nScatter == 3 then
		nScatterWin = nTotalbet*5;
	elseif self.nScatter == 4 then
		nScatterWin = nTotalbet*20;
	elseif self.nScatter == 5 then
		nScatterWin = nTotalbet*100;
	end

	if nScatterWin > 0 then
		self.GameScatterWinOK = true;
		self.GameScatter:setVisible(true);
		self.GameScatter_Win:setString(nScatterWin)
	end
end
------------------------------------------------------------------------------------------

function GameViewLayer:getJackpotWin(_id,_win)
	self.JackpotTextID  = _id
	self.JackpotTextNum = _win
end

function GameViewLayer:GameJackpot(_num) 
	self.GameJackotTag = true;
	--require("app.views.system"):setBtnEnable(self,false);
	self:startTime(false)
	if self.autoCount > 0 then 
		self.autoCount = 0
		self.btn_stop:setVisible(false);
		self.btn_autostop:setVisible(false)
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
function GameViewLayer:GameWarn(_num , winbet)
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

--Bigwin¶¯»­ÒôÐ§Í£Ö¹
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

local hideLineEntry = nil
--ÏÔÊ¾ÖÐ½±Ïß
function GameViewLayer:showLines(num) 
	if num > 0  then
		--self:cleanWin()
	end
	for i = 1 , MAXLINE do 
		if i <= num then
			self.table_lines[i]:setOpacity(255)
			self.table_lines[i]:setVisible(true)
		
		else
			self.table_lines[i]:setVisible(false)
		end
	end
	--×Ô¶¯Òþ²ØÏß
	if num > 0  then 
		if  hideLineEntry   then --È¡ÏûÒÔÇ°µÄÖØÐÂÆô¶¯¶¨Ê±
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(hideLineEntry)
			hideLineEntry =nil 
		end 
		hideLineEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
				if  hideLineEntry   then --È¡ÏûÒÔÇ°µÄÖØÐÂÆô¶¯¶¨Ê±
					cc.Director:getInstance():getScheduler():unscheduleScriptEntry(hideLineEntry)
					hideLineEntry =nil 
				end  
				
				for i = 1 , MAXLINE do 
					self.table_lines[i]:setVisible(false)
				end 
			end , 2, false) 
	end 
end

--ÅÐ¶Ï2£¬3,4 ÁÐÊÇ·ñ¶¼ÓÐÐÜ
function GameViewLayer:isFreeGame()
	local bflag1 = false 
	local bflag2 = false 
	local bflag3 = false 
	for index,m_pan in pairs(self.tab) do 
		if  index == 2 then  
			for index2,numb in pairs(m_pan) do 
				if numb == "12" then 
					bflag1 =true 
					break 
				end 
			end
		end 
		if  index == 3 then  
			for index2,numb in pairs(m_pan) do 
				if numb == "12" then 
					bflag2 =true 
					break 
				end 
			end
		end 
		if  index == 4 then  
			for index2,numb in pairs(m_pan) do 
				if numb == "12" then 
					bflag3 =true 
					break 
				end 
			end
		end 
	end 
	if  bflag1 and bflag2 and bflag3 then 
		return true 
	else  
		return false
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
	local avatar = self.pan_normal:getChildByName("sp_avatar")
	if nil ~= avatar then
		avatar:updateHead(GlobalUserItem)
	else
		local avatarFrame = self.pan_normal:getChildByName("sp_head")
		HeadSprite:createClipHead(GlobalUserItem, 64, "sp_avatar_mask_64.png")
			  :setPosition(avatarFrame:getPosition())
			  :setName("sp_avatar")
			  :addTo(self.pan_normal)
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
	if(self.schedulerIDWin1) then 
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerIDWin1)
		self.schedulerIDWin1 = nil 
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

function GameViewLayer:GameBJMp3()
	AudioEngine.playMusic("mp3/GameBJ3.mp3",true) --开启背景音乐
end

return GameViewLayer
