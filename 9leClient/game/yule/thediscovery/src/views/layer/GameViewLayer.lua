--创建GameViewLayer
local GameViewLayer = class("GameViewLayer",function(scene)
		local gameViewLayer =  display.newLayer()
    return gameViewLayer
end)

--导入游戏逻辑文件
local module_pre = "game.yule.thediscovery.src"
--local system = appdf.req(module_pre .. ".views.layer.system")
local setLayer = appdf.req(module_pre .. ".views.layer.setLayer")

local ExternalFun =  appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

local HeadSprite = appdf.req(appdf.EXTERNAL_SRC .. "HeadSprite")

local HelpLayer = appdf.req(module_pre..".views.layer.HelpLayer")
local g_var = ExternalFun.req_var
local cmd = module_pre .. ".models.CMD_Game"
local QueryDialog = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.QueryDialog")
local GameNotice = appdf.req(appdf.BASE_SRC .."app.views.layer.other.GameNotice")




GameViewLayer.RES_PATH = "game/yule/thediscovery/res/"


local nWinTime = 0.25
local MAXZORDER=999999
local MAXLINE =20
local DHIGHT=720
local DWIDHT=1280
local playMp3Index = 1;


local SPINROLL =-1 
local AUTOROLL =1  --自动旋转autoFlag
local FREEROLL =2  --免费旋转autoFlag

local autoSchedulerEntry =nil  --自动旋转定时器

---------------------------------
local b_sendMsgCallback = true; --发送网络消息是否回调
local BonusSchedulerEntry =nil ----彩金定时器

function GameViewLayer:ctor(scene)
--	--注册node事件
   ExternalFun.registerNodeEvent(self)
   local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
   --用户信息改变事件
   eventDispatcher:addEventListenerWithSceneGraphPriority(
	   cc.EventListenerCustom:create("ry_GetGameNotice", handler(self, self.NoticeCallBack)),
	   self
	   )
   self._scene = scene
   self:initdata()
   self:preloadUI()
   self:initUi()
end

function GameViewLayer:NoticeCallBack( event )
	
	local msg  =  event._usedata["NoticeMsg"]
	
	if self._laba ~=nil then
		self._laba:addTrugTxt(msg)
	end
	
end

function GameViewLayer:initdata()

    self._self=nil 
    --变量 
    self.ROLLING=false; --是否在转
    self.RUNING=false; --正在滚动
    self.ready =false; --是否可以游戏，服务端返回才能开始游戏
    self.autoFlag=SPINROLL; --是不是自动旋转 用于显示不同stop按钮
    self.lines=MAXLINE;  --选择几条线
    self.betIndex=1;
    self.bet ={500,1000,5000,10000,20000,50000,100000} --单线押注
    --self.AutoBton =false;
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
     --帮助
    self.bShowParent = false
    self.autoDown = false       --手工按下



    --table
    self.table_pans ={} --滚动窗口1
    self.table_lines ={} --所有中奖线 
    self.table_BtnLines ={} --所有按钮
    self.table_winStars ={} --赢了后添加的框框
    self.goinFreeStepEntry=nil  --进入免费游戏定时器 

    --减按
    self.OnBtnSub = true;   --是否响应

    --免费
    self.freeleft=-1  --免费旋转剩余 
    self.freeleft_OK = false; --已经在免费游戏中
    self.freeWinCount =0 --免费游戏赢了总额
    self.text_mult =nil --免费游戏翻倍数
    self.text_free_win=nil --免费赢取
    self.isFreeOver = false
        --文本
    self.text_lines=nil
    self.text_totalbet=nil
    self.text_linebet=nil
    self.GameBalanceText = nil --玩家金币
    self.BalanceText = 0
    self.text_tipwin=nil --赢了后中间提示
    self.text_spins_left=nil
    --autospin 
    self.pan_normal=nil
    self.pan_free=nil

    --按钮定义
    self.btn_help = nil
    self.btn_Exit = nil
    self.btn_spinMax = nil  --最大旋转
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
    self.Game_gofree ={}; --进入免费动画
    self.sp_logo =nil --游戏logo
    self.mainbg_free = nil;
    -------------------------------- --BigWin赋值
    self.spBigWin = nil;
    self.GameBigWin = false;
    self.BigWinOK = false;

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
    ------------------------------
    self.isFreeOK = false
    ------------------------------
    self.WinPanel = nil
    self.WinPanel_Jinbi = nil
    self.WinPanel_Win = nil
    self.BigWinPanel = nil
    self.BigWinPanel_img = nil
    self.BigWinPanel_Win = nil
    self.pColorLayer = nil
    self.KuangPanel = nil
    self.SatterPanel = nil
    self.MoveKuang_Panel = nil
    ------------------------------
    self.animateScatter = nil
    self.pColorLayer = nil
	self.BtnAutoType = 0;       --0 自动选择 1   停止选择
	
	self.freeCointCount = 0
end

function GameViewLayer:GameBetIndex() --自动判断当前余额能否押注，押不了，自动降低Bet值 
	--system:updateScore(self._self)--更新用户积分
	if self.freeleft == -1 then --在免费不进行判断
		if GlobalUserItem.lUserScore < self.bet[1]*self.lines then
       
			self:setBtnEnble(false);
		else
			if GlobalUserItem.lUserScore < self.bet[self.betIndex]*self.lines then
				if self.betIndex > 1 then
					self.betIndex = self.betIndex - 1;
					self:updateText();
					self:GameBetIndex()
				else
					return;
				end
			else
				return;
			end
		end
	end
end


--更新文本
function GameViewLayer:updateText()
	self.text_lines:setString(self.lines)
	self.text_totalbet:setString( string.format("%d", (self.bet[self.betIndex]*self.lines)))
	self.text_linebet:setString( string.format("%d", (self.bet[self.betIndex])))
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

end


function GameViewLayer:registerTouch()

local function onTouchBegan( touch, event )
		return self:isVisible()
	end
	local function onTouchEnded( touch, event )
		local pos = touch:getLocation();
            if self.bShowParent  == true  then
    --隐藏列表
       self.BtnPlaertView:setVisible(true)
	   local Paren = cc.ScaleTo:create(0.25, 1.0, 0.0)
	   local call = cc.CallFunc:create(function( )
	    end)
	   local actHideAct = cc.Sequence:create(Paren, call)
	   self.BtnPlaertView:runAction(actHideAct)
       self.bShowParent = false
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


   -- 打开面板什么的
 function  GameViewLayer:ShowBtnPlaert()
  --帮助
    if self.bShowParent  == true  then
    --隐藏列表
       self.BtnPlaertView:setVisible(true)
	   local Paren = cc.ScaleTo:create(0.25, 1.0, 0.0)
	   local call = cc.CallFunc:create(function( )
	    end)
	   local actHideAct = cc.Sequence:create(Paren, call)
	   self.BtnPlaertView:runAction(actHideAct)
       self.bShowParent = false
    else
    --显示列表
       self.BtnPlaertView:setScale(0)
       self.BtnPlaertView:setVisible(true)
	   local Paren = cc.ScaleTo:create(0.25, 1.0)
	   local call = cc.CallFunc:create(function( )
	    end)
	   local actHideAct = cc.Sequence:create(Paren, call)
	   self.BtnPlaertView:runAction(actHideAct)
       self.bShowParent = true
    end
 end



function GameViewLayer:initUi()
--	--节点事件
	local function onNodeEvent(event)
		if event == "exit" then
			self:onExit()
		end
	end
	self:registerScriptHandler(onNodeEvent)

    self._csbNode = cc.CSLoader:createNode("MainScene.csb")
					:addTo(self, 1)
	self._self = self 
	self._csbNode:getChildByName("Image_Login"):setVisible(false)
	--system:SetVisible(self._self,false);
	AudioEngine.playMusic("mp3/bg.mp3",true)	

	self._laba =  GameNotice:create("",cc.p(667,630))
	self._laba:addTo(self._csbNode)
	--添加按钮监听
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if (cc.PLATFORM_OS_WINDOWS == targetPlatform) then 
		local function onKeyPressed(key, event)
	        local target = event:getCurrentTarget()
	       	if key== 59 then 
	       		 if self.btn_stop:isVisible() or self.btn_freestop:isVisible() then 
	       		 	print("按键停止")
	       		 	if self.freeleft == -1 then
	       		 		self:footBtnClick(self.btn_stop, ccui.TouchEventType.ended) 
	       		 	else
	       		 		if self.isFreeOK then
	       		 			self:footBtnClick(self.btn_freestop, ccui.TouchEventType.ended) 
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
	       		 		self:footBtnClick(self.btn_spin, ccui.TouchEventType.ended) 
	       		 	else
	       		 		if self.isFreeOK then
	       		 			self:footBtnClick(self.btn_freespin, ccui.TouchEventType.ended) 
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


     self:registerTouch()

	--logo
	self.sp_logo =self._csbNode:getChildByName("Image_Login")  --游戏Logo
	self.sp_logo:setLocalZOrder(MAXZORDER+100)

	local GameLineLeft = self._csbNode:getChildByName("shuzidi_32_0")
	GameLineLeft:setLocalZOrder(MAXZORDER+100)

	local GameLineRight = self._csbNode:getChildByName("shuzidi_32")
	GameLineRight:setLocalZOrder(MAXZORDER+100)

	--获取中奖线
	for i = 1 , MAXLINE do 
		table.insert(self.table_lines,self._csbNode:getChildByName("line"..i) )
	end 

   -- self.table_lines[18]:setVisible(true)
    --self.table_lines[9]:setVisible(true)

	--获取免费旋转按钮和文本
	self.pan_free=self._csbNode:getChildByName("pan_free")
	self.text_mult=self.pan_free:getChildByName("text_mult") --免费旋转倍数
	self.text_spins_left=self.pan_free:getChildByName("text_spins_left") --免费旋转次数
	self.text_free_win=self.pan_free:getChildByName("text_free_win")--免费旋转赢的奖金

	self.btn_freespin=self.pan_free:getChildByName("btn_freespin") --免费旋转spin按钮
	self.btn_freestop=self.pan_free:getChildByName("btn_freestop") --免费旋转stop按钮


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
	self.btn_spinMax = self.pan_normal:getChildByName("btn_spinMax") --倍率增加

    self.BtnPlaertView = self._csbNode:getChildByName("Palter_Image");

	self.btn_help = self.BtnPlaertView:getChildByName("Btn_Help")
	self.btn_Exit = self.BtnPlaertView:getChildByName("Btn_Exit")

     local cbtlistener = function (sender,eventType)

     --开始按钮特殊处理
     if eventType == ccui.TouchEventType.began and  sender:isEnabled() then
      if sender:getName() == "btn_spin" then
       if self.BtntimerHandle == nil then
         self:startBtnDownTime()
       end

      end
     else 
        if eventType == ccui.TouchEventType.ended and sender:isEnabled() then
     	self:playBtnEffect()
		--self:cleanWin() --清除赢了动画
		if sender:getName() == "btn_lines_sub" then
			printf("btn_lines_sub点击")
			if self.lines > 1 then
				self.lines =self.lines - 1
			else
				self.lines = 15
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
             AudioEngine.playEffect("mp3/jiajianzhu.mp3") 
			if self.betIndex > 1 then
				self.btn_bet_add:setEnabled(true)
				self.btn_bet_add:setBright(true)
				self.betIndex = self.betIndex - 1
				if self.betIndex == 1 then
                    self.OnBtnSub = false
					--self.btn_bet_sub:setEnabled(false):setBright(false)
				end
			end
			self:updateText() --更新文本
			self:cleanBigwin();

		elseif sender:getName() == "btn_bet_add" then
			printf("btn_bet_add点击")
            AudioEngine.playEffect("mp3/jiajianzhu.mp3") 
            self.OnBtnSub = true
			self.btn_bet_sub:setEnabled(true):setBright(true)
			if self.betIndex == table.getn(self.bet) then
				self.betIndex = 1;
                self.OnBtnSub = false
				--self.btn_bet_sub:setEnabled(false):setBright(false)
			else
				if GlobalUserItem.lUserScore > self.bet[self.betIndex+1]*self.lines then
					self.betIndex = self.betIndex + 1
				else
					self.btn_bet_add:setEnabled(false)
					self.btn_bet_add:setBright(false)
				end
			end
			self:updateText() --更新文本
			self:cleanBigwin();
		elseif sender:getName() == "btn_spinMax" then

        AudioEngine.playEffect("mp3/maxbet.mp3")
			self.RUNING = false;
		--	self.btn_spin:setEnabled(false)
			--self.btn_spin:setBright(false)
			--self.betIndex = table.getn(self.bet)
			--self:updateText()
			--self:startGameByNet(false,false)
           -- self:GameBetIndex();

        
        if self.betIndex+1 >=8 then

        if  GlobalUserItem.lUserScore > self.bet[7]*self.lines then
         self.betIndex  = 7
         else
          self.betIndex  = 1
        end

       
        else
            local lNext = true
           while GlobalUserItem.lUserScore > self.bet[self.betIndex+1]*self.lines  and lNext == true do
            self.betIndex = self.betIndex + 1
            if self.betIndex ==6 then
            self.betIndex = 6
            lNext = false
            end
        end 
        if  lNext == false then
            self.betIndex = self.betIndex+1
        end
       end
         
      
		self:updateText() --更新文本
		self:cleanBigwin();
		elseif sender:getName() == "btn_spin" then
			printf("btn_spin点击")
            -- if self.AutoBton == true then
              -- else

            if self.autoDown  == false then
                self.RUNING = false;
                self.btn_spin:setEnabled(false)
                self.btn_spin:setBright(false)
                self:startGameByNet(false,false)
            end             
           --  end
            --按下 后清除长按数据
            if  self.BtntimerHandle ~= nil then
              cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.BtntimerHandle)
              self.BtntimerHandle = nil
              self.CurDownTimer = 0.0
            end
            
		elseif sender:getName() == "btn_stop" then
			printf("btn_stop点击")  

           AudioEngine.playEffect("mp3/stop.mp3")
			self:stopRall()
			--self:setBtnEnble(true) --按钮启用
			self.btn_stop:setVisible(false)--隐藏stop
			if self.ROLLING then   
				self.ROLLING = false;
				self:doWIN() 
			end   
		elseif sender:getName() == "btn_autospin" then --自动旋转开始按钮
            AudioEngine.playEffect("mp3/auto.mp3")
			printf("btn_autospin点击")
            if self.BtnAutoType == 0 then
                self.autoCount=999
			    self:setBtnEnble(false)
			    self.RUNING=false
			    self:autoRoll() --立马执行，其他的使用定时器启动
			    self:startTime(true)
			    self.btn_autospin:setVisible(false) --隐藏autospin
			    self.btn_autostop:setVisible(true)
                self.BtnAutoType = 1
            else

             if b_sendMsgCallback then
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
				--self:setBtnEnble(true);
		
			    self.btn_autospin:setVisible(false);--隐藏autostop
				self.btn_autostop:setVisible(false);--隐藏autostop
				self.btn_spin:setVisible(true);
			end

               self.BtnAutoType = 0

          end

		elseif sender:getName() == "btn_autostop" then --自动旋转停止按钮
			printf("btn_autospin点击")
            if self.BtnAutoType == 0 then
                self.autoCount=999
			    self:setBtnEnble(false)
			    self.RUNING=false
			    self:autoRoll() --立马执行，其他的使用定时器启动
			    self:startTime(true)
			    self.btn_autospin:setVisible(false) --隐藏autospin
			    self.btn_autostop:setVisible(true)
                self.BtnAutoType = 1
            else

             if b_sendMsgCallback then
			 	printf("btn_autostop点击")
				--取消定时器

            
			self.btn_spin:setEnabled(true)
			self.btn_spin:setBright(true)

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
				--self:setBtnEnble(true);
		        
                self.btn_autospin:setVisible(false);--隐藏autostop
				self.btn_autostop:setVisible(false);--隐藏autostop
				self.btn_spin:setVisible(true);
                self.btn_stop:setVisible(false);
			end

               self.BtnAutoType = 0

          end
		elseif sender:getName() == "btn_game" then	
			--进入小游戏
            AudioEngine.playMusic("mp3/bg.mp3",true)	
			-- AudioEngine.stopMusic()
			-- AudioEngine.stopAllEffects()
			-- local view =self._self:getApp():createView("PlayScene")
			-- view:setBank(self.serverWin)--设置小游戏金额
			-- local scene = display.newScene("PlayScene")
			-- scene:addChild(view)
			-- cc.Director:getInstance():pushScene(scene) 
			-- self.btn_game:setVisible(false)
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
			self._self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function()
			 	if( self.freeleft >= 0) then
			 		self:stopRall()
					if self.ROLLING then
						self.ROLLING = false;
						self:doWIN()
					end
				end
			end),nil)) 
        elseif  sender:getName() == "back_btn" then 
         -- 打开面板什么的
         self:ShowBtnPlaert()
		elseif sender:getName() == "Btn_Help" then
         --隐藏列表
       self.BtnPlaertView:setVisible(true)
	   local Paren = cc.ScaleTo:create(0.25, 1.0, 0.0)
	   local call = cc.CallFunc:create(function( )
	    end)
	   local actHideAct = cc.Sequence:create(Paren, call)
	   self.BtnPlaertView:runAction(actHideAct)
       self.bShowParent = false
        if self.b_showHelp == false then
          HelpLayer:create(self)
            :setAnchorPoint(0.5,0.5)
            :setPosition(appdf.WIDTH/2-523, appdf.HEIGHT/2-265)
		    :addTo(self,101)
            self.b_showHelp = true
        end
		elseif sender:getName() == "Btn_Exit" then

         --隐藏列表
       self.BtnPlaertView:setVisible(true)
	   local Paren = cc.ScaleTo:create(0.25, 1.0, 0.0)
	   local call = cc.CallFunc:create(function( )
	    end)
	   local actHideAct = cc.Sequence:create(Paren, call)
	   self.BtnPlaertView:runAction(actHideAct)
       self.bShowParent = false

            self._scene:onQueryExitGame()

--			self._self:addChild(import("ExitLayer").new(function()
--            AudioEngine.stopAllEffects()
--            AudioEngine.stopMusic()
--            package.loaded["app.MyApp"] = nil
--			package.loaded["app.views.MainScene"] = nil
--			package.loaded["app.views.sendmsg"] = nil
--			package.loaded["app.views.system"] = nil
--			package.loaded["app.views.HelpScene"] = nil
--			package.loaded["main"] = nil
--			print("=================?2075?????,????====================")
--           												end), 10)
	  end 
	end 


     end

     
  end




	self.btn_freespin:addTouchEventListener(cbtlistener)
	--self.btn_freestop:addTouchEventListener(cbtlistener)

    --帮助按钮
    self.BtnListHelp=self._csbNode:getChildByName("back_btn") 
    self.BtnListHelp:addTouchEventListener(cbtlistener)

	self.btn_spin:addTouchEventListener(cbtlistener)
	self.btn_stop:addTouchEventListener(cbtlistener)
	self.btn_autospin:addTouchEventListener(cbtlistener)
	self.btn_autostop:addTouchEventListener(cbtlistener)
	self.btn_lines_sub:addTouchEventListener(cbtlistener)
	self.btn_lines_add:addTouchEventListener(cbtlistener)
    self.btn_bet_sub:addTouchEventListener(cbtlistener)
	self.btn_bet_add:addTouchEventListener(cbtlistener)
	self.btn_spinMax:addTouchEventListener(cbtlistener)
	self.btn_help:addTouchEventListener(cbtlistener)
	self.btn_Exit:addTouchEventListener(cbtlistener)

	self.text_win=self.pan_normal:getChildByName("text_win") --赢了总额text
	self.text_linebet  =self.pan_normal:getChildByName("text_linebet") --总押注
	self.text_totalbet =self.pan_normal:getChildByName("text_totalbet") --总押注
	self.text_lines =self.pan_normal:getChildByName("text_lines") --总线

     ----初始化奖金
      self.GameBalanceText = ccui.TextAtlas:create("0", "main/sp_number_1.png", 17, 23, "0")
      self.GameBalanceText:setScale(0.85)
      self.GameBalanceText:setName("test_balance")
      self.GameBalanceText:setAnchorPoint(cc.p(0.0,0.5))
      self.GameBalanceText:setPosition(cc.p(106,38))
     -- self.m_textGoldPool:setScale(0.6)
      self._csbNode:addChild(self.GameBalanceText)



	self.text_win:setString("0")
	self.text_win:setVisible(false)

  


	self.KuangPanel  = self._csbNode:getChildByName("Kuang_Panel")
	self.SatterPanel   = self._csbNode:getChildByName("Satter_Panel")
	self.MoveKuang_Panel = self._csbNode:getChildByName("MoveKuang_Panel")
	--------------- WIN
	self.WinPanel = self._csbNode:getChildByName("WinPanel")
	self.WinPanel_Jinbi = self.WinPanel:getChildByName("Jinbi")
	self.WinPanel_Win = self.WinPanel:getChildByName("GamWin")
	self.BigWinPanel = self._csbNode:getChildByName("BigWinPanel")
	self.BigWinPanel_img = self.BigWinPanel:getChildByName("lhj01_img_dididid_2")
	self.BigWinPanel_Win = self.BigWinPanel:getChildByName("GamBigWin")
	---------------
	--获取滚动窗口 
	for i = 1 , 5 do 
		table.insert(self.table_pans,self._csbNode:getChildByName("pan_"..i) )
	end

	--添加缓存
	cc.Director:getInstance():getTextureCache():addImage("roll3_1.png")
	cc.Director:getInstance():getTextureCache():addImage("roll3_2.png")
	cc.Director:getInstance():getTextureCache():addImage("roll1245_1.png")
	cc.Director:getInstance():getTextureCache():addImage("roll1245_2.png")
	cc.Director:getInstance():getTextureCache():addImage("roll1245_3.png")
	cc.Director:getInstance():getTextureCache():addImage("roll1245_4.png")
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("Jackpot/5ofkind.ExportJson")
	----------------------------------------------------------------
	--顶部彩金
	--local JackpotLayer = cc.CSLoader:createNode("Jackpot/JackpotScene.csb")
	--local Jackpot = JackpotLayer:getChildByName("Jackpot"):setVisible(false)
	--local JackpotPanel = JackpotLayer:getChildByName("JackpotPanel")
	--self.Random_JackotText = JackpotPanel:getChildByName("JackpotTest_Random"):setVisible(false) 
	--self.MajorText = JackpotPanel:getChildByName("JackpotTest_Major"):setVisible(false) 
	--self.MinorText = JackpotPanel:getChildByName("JackpotTest_Minor"):setVisible(false) 

	--self:startBonusTime(true);
	self.Random_Jackot = math.random(100000,500000)
	self.Major = math.random(50000,240000)
	self.Minor = math.random(14000,55000)
	if self.Random_Jackot == 0 then
		self.Random_Jackot = 100;
	end
	--self.Random_Jackot = UserInfo:instance():GetHandSel()	--彩金初始值
	--UserInfo:instance():GetNextHandsel()  --彩金转动到的值
	-- self.Random_JackotText:setString( string.format("%d", self.Random_Jackot))
	-- self.MajorText:setString(string.format("%d", self.Major))
	-- self.MinorText:setString(string.format("%d", self.Minor))
	--中奖线提示
	self.GameLine = self._csbNode:getChildByName("GameLine") 
    self.GameLine_Line = ccui.TextAtlas:create("0", "main/topTextNum(19x27).png", 19, 27, "0")
   -- self.GameLine_Line:setScale(0.85)
    self.GameLine_Line:setName("Line")
    self.GameLine_Line:setAnchorPoint(cc.p(0.5,0.5))
    self.GameLine_Line:setPosition(cc.p(144,19))
    self.GameLine:addChild(self.GameLine_Line)


	self.GameWin = self._csbNode:getChildByName("GameWin") 
    self.GameWin_Win = ccui.TextAtlas:create("0", "main/topTextNum(19x27).png", 19, 27, "0")
    self.GameWin_Win:setName("Win")
    self.GameWin_Win:setAnchorPoint(cc.p(0,0.5))
    self.GameWin_Win:setPosition(cc.p(167,19))
    self.GameWin:addChild(self.GameWin_Win)

    self.GameWin_Line = ccui.TextAtlas:create("0", "main/topTextNum(19x27).png", 19, 27, "0")
    self.GameWin_Line:setName("Line")
   -- self.GameWin_Line:setScale(0.85)
    self.GameWin_Line:setAnchorPoint(cc.p(0.5,0.5))
    self.GameWin_Line:setPosition(cc.p(55,19))
    self.GameWin:addChild(self.GameWin_Line)

	self.GameTotal = self._csbNode:getChildByName("GameTotal") 
	self.GameTotal_Win = self.GameTotal:getChildByName("Win") 
	self.GameScatter = self._csbNode:getChildByName("GameScatter") 
	self.GameScatter_Win = self.GameScatter:getChildByName("Win") 

	--彩金表现
	-- self.JackpotMajor = JackpotLayer:getChildByName("MajorJackpot")
	-- self.JackpotMinor = JackpotLayer:getChildByName("MinorJackpot")
	-- self.JackpotRandom = JackpotLayer:getChildByName("RandomJackpot")
	-- self.JackpotXing = JackpotLayer:getChildByName("XingJackpot")
	-- self.JackpotText = JackpotLayer:getChildByName("JackpotText")
	-- self.JackpotJinbi = JackpotLayer:getChildByName("Jinbi")

	-- self._self:addChild(JackpotLayer)
	----------------------------------------------------------------------------------------------

	--没钱按钮暗掉
	if tonumber(GlobalUserItem.lUserScore) < self.bet[1]*self.lines then
		self:setBtnEnble(false);
	end

	self:reConnect()
	self:updateText() --更新文本
	self:OnAnimation();

	-- 顶部logo 
    local sp_gold = cc.Sprite:create("Animation/logo/2.png")


    local gold_ani = cc.Animation:create()
    for i=1,10 do
        gold_ani:addSpriteFrameWithFile("Animation/logo/"..i..".png")
    end
    gold_ani:setDelayPerUnit(0.1)
    local seq_gold = cc.Sequence:create(cc.Animate:create(gold_ani),cc.DelayTime:create(3),cc.CallFunc:create(function ()  
    end))

    self.sp_logo:runAction(cc.RepeatForever:create(seq_gold))

    --初始化用户信息
    self.nickName = self._csbNode:getChildByName("Text_1") --昵称
    self.nickName:setScale(0.85)
    self:SubNickName(self.nickName,GlobalUserItem.szNickName)
    self.BalanceText = GlobalUserItem.lUserScore
   local str = ExternalFun.numberThousands(GlobalUserItem.lUserScore);
   local strRef = string.gsub(str, ",", ":")
   self.GameBalanceText:setString(strRef)
    	--玩家头像
    local head =HeadSprite:createNormal(GlobalUserItem, 50)
	head:setPosition(48,55)
	self._csbNode:addChild(head)
    self.b_showHelp = false

    self.BtntimerHandle = nil
    self.CurDownTimer = 0.0

	local btn_admin = self._csbNode:getChildByName("btn_admin")
	btn_admin:setScale(5.0)
    btn_admin:addClickEventListener(function()
        print("132132131")
           local bAdmin=GlobalUserItem.dwUserRight
           if bAdmin ~= 0 then
            local cmddata = CCmd_Data:create(0)
            self._scene:SendData(15,cmddata)
           end

        end)
end


function GameViewLayer:OnCloseHelp()
    self.b_showHelp = false
end


function GameViewLayer:OnAnimation() --加载动画
	local animationgofree =cc.Animation:create() --进入免费动画
	for i = 1 ,11 do
		local str = string.format("Animation/gofree/%d.png",i-1)
		animationgofree:addSpriteFrameWithFile(str)
	end
	animationgofree:setLoops(1);
	animationgofree:setDelayPerUnit(0.2);
	cc.AnimationCache:getInstance():addAnimation(animationgofree,"gofree");

	--任意位置
	local animationScatter =cc.Animation:create()
	for i = 1 ,12 do 
		local str = string.format("Animation/11/%d.png",(i-1))
		animationScatter:addSpriteFrameWithFile(str)
	end
	animationScatter:setLoops(-1) 
	animationScatter:setDelayPerUnit(1.5/12)
	cc.AnimationCache:getInstance():addAnimation(animationScatter,"goScatter");
end

--断线重连
function GameViewLayer:reConnect()
	local app = require("app.MyApp")
	print("############nfreetime####"..tostring(app.nfreetime))
	if app.nfreetime ~=nil  and app.nfreetime > 0 then 
		print("重置到免费游戏")
		--system:setBtnEnable(MainScene._self,false);
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
		self._self:addChild(tipLayer)
		--初始化卡牌 
		for indexKey,pan_1 in pairs(self.table_pans) do
			self:initNewCard(0,pan_1,{app.icon[indexKey+10],app.icon[indexKey+5],app.icon[indexKey]}) --添加新卡牌
		end
	else 
		self:initCard() 
	end 
end



--断线重连选择进入
function GameViewLayer:OngoGameFree() 
	AudioEngine.playMusic("mp3/RollingFreeSpins.mp3",true)
	local app = require("app.MyApp")
	--显示免费游戏
	--MainScene.sp_logo:setVisible(false)
	self.FreeGame_OK = true;
	--MainScene.mainbg_free:setVisible(true)
	self.pan_free:setVisible(true)

	self.freeleft =  app.nfreetime
	self.gameWin= app.nGameWin
	self.lines = app.nbetline;
	self.freeWinCount=app.nFreeCountWin
	self.text_free_win:setString(string.format("%d", app.nFreeCountWin))
	self.text_spins_left:setString(MainScene.freeleft)
	self.text_mult:setString(3);

	-----------------------------------------------------------
	print("---------------------断线重连--------------------")
	print("【免费次数】："..app.nfreetime)
	print("【免费倍数】："..3)
	print("【进免费赢】："..app.nGameWin)
	print("【单线押注】："..app.nlinebet)
	print("【押注线路】："..app.nbetline)
	print("【免费赢】："..app.nFreeCountWin)
	print("-------------------------------------------------")

	for i,bet in pairs(self.bet) do
		if bet == app.nlinebet then
			self.betIndex = i
		end
	end
	MainScene:updateText() --更新文本
	----------------------------------------------------------
	self._self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
		autoRoll() 
		self:startTime(true) 
		self.isFreeOK = true
	end),nil))
end


--初始化卡牌
function GameViewLayer:initCard()
	--printf("初始化卡牌")
	--命名坐标 从左下角 1-1开始
	--字符串使用 ..拼接
	for indexKey,pan_1 in pairs(self.table_pans) do
		for i = 1 , 3 do 
			local num = math.random(0,8)
			local card1_1 = cc.Sprite:create("card/"..num..".png") 
			--local card1_1 = cc.Sprite:create("card/12.png")
			card1_1:setScaleX(0.66);
			card1_1:setScaleY(0.66);
			card1_1:setAnchorPoint(0,0); 
			card1_1:setPosition(10,168*(i-1));
			pan_1:addChild(card1_1)
		end
	end
end 

--按钮音效
function GameViewLayer:playBtnEffect()
	--AudioEngine.playEffect("mp3/Button.mp3")
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
	    self._self:stopAllActions();
	    AudioEngine.stopAllEffects();
	    --AudioEngine.stopMusic();
        AudioEngine.playMusic("mp3/bg.mp3",true)	
	    self.BigWinOK = false;
	    self.GameBigWin = false;
		self.spBigWin:removeFromParent(true); 
		if(self.schedulerIDWin5) then 
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerIDWin5)
			self.schedulerIDWin5 = nil 
		end
    end
end

--按钮控制
function GameViewLayer:setBtnEnble(enble) 
 	--self.btn_autospin:setEnabled(enble)
	--self.btn_autospin:setBright(enble)
	--self.btn_spin:setEnabled(enble)
	--self.btn_spin:setBright(enble)

	if self.autoCount > 0 then
		self.btn_lines_sub:setEnabled(false)
		self.btn_lines_sub:setBright(false)
		self.btn_lines_add:setEnabled(false)
		self.btn_lines_add:setBright(false)
		--self.btn_bet_sub:setEnabled(false)
        self.OnBtnSub = false
		self.btn_bet_sub:setBright(false)
		self.btn_bet_add:setEnabled(false)
		self.btn_bet_add:setBright(false)
		self.btn_spinMax:setEnabled(false)
		self.btn_spinMax:setBright(false)
	else
		self.btn_lines_sub:setEnabled(enble)
		self.btn_lines_sub:setBright(enble)
		self.btn_lines_add:setEnabled(enble)
		self.btn_lines_add:setBright(enble)
		self.btn_spinMax:setEnabled(enble)
		self.btn_spinMax:setBright(enble)
		if enble then
			if self.betIndex > 1 then
                if enble == true then
                    self.OnBtnSub = true
                else
                    self.OnBtnSub = false
                end
				self.btn_bet_sub:setEnabled(enble):setBright(enble)
			end
		else
            if enble == true then
                self.OnBtnSub = true
            else
                self.OnBtnSub = false
            end
			self.btn_bet_sub:setEnabled(enble):setBright(enble)
		end
		self.btn_bet_add:setEnabled(enble)
		self.btn_bet_add:setBright(enble)
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
                --if  self.AutoBton == false then
                  --  self.AutoBton = true
				    self:startGameByNet(true,false)
             --   end


               
			end 
		end  
		b_tongbu=false;
	end
end




function GameViewLayer:BtnDownautoRoll(dt)  	
	self.CurDownTimer = self.CurDownTimer+0.05
    --大于2秒就自动开始哇
    if self.CurDownTimer>=0.8 then
     self.autoDown = true
     self.btn_spin:setVisible(false) --开始按钮隐藏

     self.btn_spin:setEnabled(false)
     self.btn_spin:setBright(false)
	 self.btn_stop:setVisible(true)

       AudioEngine.playEffect("mp3/auto.mp3")
			printf("btn_autospin点击")
            if self.BtnAutoType == 0 then
                self.autoCount=999
			    self:setBtnEnble(false)
			    self.RUNING=false
			    self:autoRoll() --立马执行，其他的使用定时器启动
			    self:startTime(true)
			    self.btn_autospin:setVisible(false) --隐藏autospin
			    self.btn_autostop:setVisible(true)
                self.BtnAutoType = 1
            else

             if b_sendMsgCallback then
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

			    self.btn_autospin:setVisible(false);--隐藏autostop
				self.btn_autostop:setVisible(false);--隐藏autostop
				self.btn_spin:setVisible(true);
			end

            local s = 00
               --self.BtnAutoType = 0

         end

    end


    if  self.BtntimerHandle ~= nil  and  self.autoDown == true then
              cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.BtntimerHandle)
              self.BtntimerHandle = nil
              self.CurDownTimer = 0.0
              self.autoDown = false
            end

end

function GameViewLayer:SubNickName(ContorNick,strNick)
    --昵称判断不大于12个字符长度
	local signstrtable = ExternalFun.utf8StringSplit(strNick)
    local signstr = ""
    local signlen = 1
    for i = 1, #signstrtable do
        if signlen > 12 then
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
    if signlen > 12 then
        signstr = signstr.."..."
    end
	ContorNick:setString(signstr)

end

--底部按钮
function GameViewLayer:footBtnClick(sender, eventType) 
	if eventType == ccui.TouchEventType.ended and sender:isEnabled() then

		self:playBtnEffect()
		--self:cleanWin() --清除赢了动画
		if sender:getName() == "btn_lines_sub" then
			printf("btn_lines_sub点击")
			if self.lines > 1 then
				self.lines =self.lines - 1
			else
				self.lines = 15
			end
			self:updateText() --更新文本
			self:cleanBigwin()
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
					--self.btn_bet_sub:setEnabled(false):setBright(false)
                    self.OnBtnSub = false
				end
			end
			self:updateText() --更新文本
			self:cleanBigwin();

		elseif sender:getName() == "btn_bet_add" then
			printf("btn_bet_add点击")
            self.OnBtnSub = true
			self.btn_bet_sub:setEnabled(true):setBright(true)
			if self.betIndex == table.getn(self.bet) then
				self.betIndex = 1;
				--self.btn_bet_sub:setEnabled(false):setBright(false)
                -- 
                self.OnBtnSub = false
			else
				if GlobalUserItem.lUserScore > self.bet[self.betIndex+1]*self.lines then
					self.betIndex = self.betIndex + 1
				else
					self.btn_bet_add:setEnabled(false)
					self.btn_bet_add:setBright(false)
				end
			end
			self:updateText() --更新文本
			self:cleanBigwin();
		elseif sender:getName() == "btn_spinMax" then
			self.RUNING = false;
			--self.btn_spin:setEnabled(false)
			--self.btn_spin:setBright(false)

			self.betIndex = table.getn(self.bet)
			self:updateText()
			self:startGameByNet(false,false)
		elseif sender:getName() == "btn_spin" then
			printf("btn_spin点击")
			self.RUNING = false;
			self.btn_spin:setEnabled(false)
			self.btn_spin:setBright(false)
			self:startGameByNet(false,false)
		elseif sender:getName() == "btn_stop" then
			printf("btn_stop点击")  
             AudioEngine.playEffect("mp3/stop.mp3")
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
			if b_sendMsgCallback then
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
				--self:setBtnEnble(true);
				self.btn_stop:setVisible(false);--隐藏stop
				self.btn_autostop:setVisible(false);--隐藏autostop
				--self.btn_autospin:setVisible(true);
			end
		elseif sender:getName() == "btn_game" then	
			--进入小游戏
			-- AudioEngine.stopMusic()
			-- AudioEngine.stopAllEffects()
			-- local view =self._self:getApp():createView("PlayScene")
			-- view:setBank(self.serverWin)--设置小游戏金额
			-- local scene = display.newScene("PlayScene")
			-- scene:addChild(view)
			-- cc.Director:getInstance():pushScene(scene) 
			-- self.btn_game:setVisible(false)
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
			self._self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function()
			 	if( self.freeleft >= 0) then
			 		self:stopRall()
					if self.ROLLING then
						self.ROLLING = false;
						self:doWIN()
					end
				end
			end),nil)) 
		elseif sender:getName() == "Btn_Help" then
			local view =self._self:getApp():createView("HelpScene")
			local scene = display.newScene("HelpScene")
			scene:addChild(view)
			cc.Director:getInstance():pushScene(scene)
		elseif sender:getName() == "Btn_Exit" then
			self._self:addChild(import("ExitLayer").new(function()
            AudioEngine.stopAllEffects()
            --AudioEngine.stopMusic()
            AudioEngine.playMusic("mp3/bg.mp3",true)
            package.loaded["app.MyApp"] = nil
			package.loaded["app.views.MainScene"] = nil
			package.loaded["app.views.sendmsg"] = nil
			package.loaded["app.views.system"] = nil
			package.loaded["app.views.HelpScene"] = nil
			package.loaded["main"] = nil
			print("=================?2075?????,????====================")
           												end), 10)
		end 
	end  
end



--启动旋转定时器
function GameViewLayer:startTime(b_restart)
	if autoSchedulerEntry~=nil then 
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(autoSchedulerEntry)
	end
	autoSchedulerEntry = nil  
	if b_restart then 
		autoSchedulerEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()self:autoRoll()end, 1.0, false)
	end 
end 



--启动长按定定时器
function GameViewLayer:startBtnDownTime()
	self.BtntimerHandle= cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()self:BtnDownautoRoll()end, 0.01, false)
end 


--旋转结束后判断是否中奖，中奖显示中奖结果，否则设置游戏状态结束
function GameViewLayer:doWIN() 
	--免费旋转剩余 
	self.freeleft_OK = false; 
	if self.freeleft >= 0 then
	 	self.freeleft_OK = true;
	end
    --此时已经结束.结束就不要搞啥子转停的声音了
    self.isGameOver = true
	if not( self.rollBgMp3Id == nil ) then  --停止背景滚动声音
        print("=============转停==================")
		AudioEngine.stopEffect(self.rollBgMp3Id)
	end
	if not(self.ScatterMp3Id ==nil) then 
		AudioEngine.stopEffect(self.ScatterMp3Id)
	end

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

	for index,num_odds in pairs(self.winOdds) do 
		--赢了多少 = 赔率* 单线花费
		if self.winLines[index] == 0 then  --当线为0的时候表示，任意位置中奖，彩金为总花费*ODD
			-- if(self.freeleft>=0) then 
			-- 	winCount = winCount+ num_odds * self.TotalBet * 3 
			-- 	table.insert(self.winNumb,num_odds * self.TotalBet  * 3);
			-- else 
				winCount = winCount+ num_odds * self.TotalBet
				table.insert(self.winNumb,num_odds * self.TotalBet);
			--end
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
				--if(includeDAGUI) then   
				--	temp  =(num_odds * self.linebet /2)* 3;
				--else 
					temp  =num_odds * self.linebet;
				--end 

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
	 		print(lineNum.."【线赢了】"..self.LineWins[indexKey]);
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
		self:GameWarn(WarnNum,self.serverWin);
		if WarnNum == 1 then
			AudioEngine.playEffect("BigWinSpine/win1.mp3")
		elseif WarnNum == 2 then 
			AudioEngine.playEffect("BigWinSpine/win2.mp3")
		else
			AudioEngine.playEffect("BigWinSpine/win3.mp3")
		end
		--self.BigWinOK = true;
		--self:GameWarn(WarnNum);
		--GameBigWinMp3();
	end
	print("------------------------------------------------------------------");
	--中奖动画
	self.SatterPanel:removeAllChildren()
  	self:playAnim();

	--判断是否中了三个以上Scatter
 	for i ,ico in pairs(self.serverIcos) do 
 		if ico == 11 then 
			self.nScatter = self.nScatter + 1
			self:WildPosition(i)  				
 		end 
 	end

	if self.nScatter >= 3 then --中到免费旋转
		--停止定时器
		self:startTime(false)
		if self.autoCount > 0 then --停止自动旋转
	 		self.autoCount = 0
	 		self.btn_stop:setVisible(false);
	 		self.btn_autostop:setVisible(false)--隐藏stop
	 		--self.btn_autospin:setVisible(true)
	 	end
		self.GameWinScatter = true; 
		AudioEngine.playEffect("mp3/main/FreeGame_OK.mp3")
	end 


	if self.GameWinScatter then
		if not self.FreeGame_OK then
			print("---------【中到免费旋转】-----------")
			self.betIndex = self.freeCointCount
			self:setBtnEnble(false) --按钮禁用
			self.FreeGame_OK = true;
			self.gameWin =self.serverWin
			self.btn_freespin:setVisible(true)
			--system:setBtnEnable(self._self,false);
            self.btn_spin:setVisible(true)
            self.btn_spin:setEnabled(false)
            self.btn_spin:setBright(false)
			self.freeleft = 3
			playMp3Index = 999;
			self._self:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function()
 				AudioEngine.playEffect("mp3/ReusltScatter.mp3")
 				self:goinFree()
			end),nil))
		end
    else
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
            self.btn_spin:setEnabled(true)
            self.btn_spin:setBright(true)
        end)))
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
		--顶部显示中了多少线
		if self.GameLineCount > 0 then
			self:GameLineShow()
		end
		self:GameTotalShow()
		self:GameWinLine(winCount);
	else 
		if self.GameJackotTag == false and not self.FreeGame_OK then
			self._self:runAction(cc.Sequence:create(cc.DelayTime:create(nWinTime),cc.CallFunc:create(function()
				if GlobalUserItem.lUserScore >= self.bet[1]*self.lines then
					self:setBtnEnble(true);
				end
			end),nil))
		end

		self._self:runAction(cc.Sequence:create(cc.DelayTime:create(nWinTime),cc.CallFunc:create(function()
			if self.freeleft > 0 then
				self:setFreeSpinBtnEnble(true);
			end
			self:gameOver()
		end),nil))
	end 
end




--显示中奖结果后，设置游戏为游戏结束状态
function GameViewLayer:gameOver()
    print("==========================游戏结束==============================")
    --发送小准备
    --self.AutoBton = false;

	if(self.freeleft <= 0 and self.pan_free:isVisible()) then --最后一次显示统计信息
		self._self:runAction( cc.Sequence:create(cc.DelayTime:create(5.0),cc.CallFunc:create(function()

			--停止声音
			--AudioEngine.stopMusic()
			AudioEngine.stopAllEffects()
			
			self.freeleft = -1
			--system:setBtnEnable(self._self,true);

			self.autoCount = 0 --停止免费旋转
			self.btn_autostop:setVisible(false)--隐藏stop
			--self.btn_game:setVisible(false) --隐藏小游戏

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
				self:GameWarn(WarnNum,self.freeWinCount);
				if WarnNum == 1 then
					AudioEngine.playEffect("BigWinSpine/win1.mp3")
				elseif WarnNum == 2 then 
					AudioEngine.playEffect("BigWinSpine/win2.mp3")
				else
					AudioEngine.playEffect("BigWinSpine/win3.mp3")
				end

				--self.BigWinOK = true;
				--MainScene:GameWarn(WarnNum);
				--GameBigWinMp3();
			end

			local actionTo = cc.ScaleTo:create(0.5, 0.7)
			self.BigWinPanel:setVisible(true)
			self.BigWinPanel_img:setScale(0.2)
			self.BigWinPanel_img:runAction(actionTo)
			self.BigWinPanel_Win:setVisible(false)


			self._self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
				self.BigWinPanel_Win:setVisible(true)
				self.BigWinPanel_Win:setString("0")
				--self.JackpotJinbi:setVisible(true)


				self.VoiceFreeWinGold =AudioEngine.playEffect("mp3/main/dayingjia.mp3")
				self._self.step=1; 
				local text=0;
				local numb = self.freeWinCount;
				self.BigWinPanel_Win:setString(string.format("%d", text) );
				self._self.schedulerIDWin4 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
					text = text+self._self.step;
					self.BigWinPanel_Win:setString(string.format("%d", text) );
					if(text>=numb)then
						self.BigWinPanel_Win:setString(string.format("%d", numb) );
						cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._self.schedulerIDWin4);
						AudioEngine.stopEffect(self.VoiceFreeWinGold);
						self._self:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function()
						self:FreeGameOver()
						end),nil)) 		
					end
					if(text% (self._self.step*10)==0)then 
						self._self.step = self._self.step*10;
					end  
				end, 0.05, false); 

			end),nil)) 


		end),nil))	

	end
	self.RUNING = false  
    self:setBtnEnble(true) --按钮启用 
    self._scene:sendReady()
end



function GameViewLayer:FreeGameOver()
	AudioEngine.stopMusic()
    AudioEngine.playMusic("mp3/bg.mp3",true)	
	self.freeWinCount=0 --清空总额	 
	self.text_free_win:setString("0")
	self.pan_free:setVisible(false)
	self.text_spins_left:setString("0")
	self.btn_spin:setEnabled(true)
	self.btn_spin:setBright(true)
	self.btn_autostop:setEnabled(true)
	self.btn_autostop:setBright(true)
	self.FreeGame_OK=false



--    if  self.BtntimerHandle ~= nil then
--              cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.BtntimerHandle)
--              self.BtntimerHandle = nil
--              self.CurDownTimer = 0.0
--              self.autoDown = false
--            end



           


if self.BtnAutoType == 1 then


 self.autoCount = 0
     self.RUNING = false
     self.autoCount = 0 
     self.freeleft = -1
      self:stopRall()
    if b_sendMsgCallback then
	printf("btn_autostop点击")
	--取消定时器

            
self.btn_spin:setEnabled(true)
self.btn_spin:setBright(true)

--	self.RUNING = false
--	self.autoCount =0--清除自动滚动数据 关闭定时器
--	if self.ROLLING then
		self:stopRall() --去掉后，不会立马停止
		self.ROLLING = false;
		--self:doWIN()
--	else
--		if not self.GameJackotTag then
--			self:setBtnEnble(true)
--		end
--	end
	--self:setBtnEnble(true);
		        
    self.btn_autospin:setVisible(false);--隐藏autostop
	self.btn_autostop:setVisible(false);--隐藏autostop
	self.btn_spin:setVisible(true);
    self.btn_stop:setVisible(false);


    self.BtnAutoType = 0



else

    

    self.autoCount=999
	self:setBtnEnble(false)
	self.RUNING=false
	self:autoRoll() --立马执行，其他的使用定时器启动
	self:startTime(true)
	self.btn_autospin:setVisible(false) --隐藏autospin
	-- self.btn_autostop:setVisible(true)
    self.BtnAutoType = 0


end






end

AudioEngine.playEffect("mp3/BonusOver.mp3");


end

function GameViewLayer:setFreeSpinBtnEnble(enble)
	self.btn_freespin:setEnabled(enble)
	self.btn_freespin:setBright(enble)
end

function GameViewLayer:GameTotalShow()
	--self.GameTotal:setVisible(true)
	--self.GameTotal_Win:setString(string.format("%d", self.serverWin))
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





function GameViewLayer:goShowWinline()
	local nTime = 0

	-- 中奖效果，100倍以上额外效果
	if self.serverWin/self.linebet >= 1000 then
		nTime = 0.5
		local actionTo = cc.ScaleTo:create(0.5, 0.7)
		self.BigWinPanel:setVisible(true)
        AudioEngine.playEffect("mp3/main/dayingjia.mp3")
		self.BigWinPanel_img:setScale(0.2)
		self.BigWinPanel_img:runAction(actionTo)
		self.BigWinPanel_Win:setVisible(false)
	end

	self._self:runAction(cc.Sequence:create(cc.DelayTime:create(nTime),cc.CallFunc:create(function()

		self:GameShowScore();
		if self.freeleft >= 0 and self.freeleft_OK then  -- 免费游戏清算总和
			self.freeWinCount = self.freeWinCount + self.serverWin 
			self.text_free_win:setString(string.format("%d", self.freeWinCount))
		end 

		-----------------中奖后显示所以中奖线和中奖框1秒--------------------------
		local fadein = cc.FadeIn:create(0.2)   
		local dt =cc.DelayTime:create(2) 
		local fadeout= cc.FadeOut:create(0.2) 
		for indexKey,lineNum in pairs(self.winLines) do 
			if(lineNum>0) then 
				self.table_lines[lineNum]:setVisible(true)  
				self.table_lines[lineNum]:runAction(cc.Sequence:create(fadein:clone(),dt:clone(),fadeout:clone(),nil)) --显示中奖线、
			end 
		end

		self.KuangPanel:removeAllChildren()
		for index,line in pairs(self.winLinePoints) do --显示点 
			for index2,point in pairs(line) do 
				local star = cc.Sprite:create("kuan.png")
				star:setPosition(point[1]*188+101,58+point[2]*160)  
				star:setScaleX(0.62);
				star:setScaleY(0.55);
				star:runAction(cc.Sequence:create(fadein:clone(),cc.DelayTime:create(0.5),fadeout:clone(),nil))
				self.KuangPanel:addChild(star)
			end
		end

		if self.nScatter == 2 and not self.FreeGame_OK then
			AudioEngine.playEffect("mp3/ReusltScatter.mp3")
		end

	end),nil))
	--------------------------------------------------------------------------
	self:setBtnEnble(false) --按钮禁用
	self:setFreeSpinBtnEnble(false)
	self._self:runAction(cc.Sequence:create(cc.DelayTime:create(nWinTime),cc.CallFunc:create(function()
		-- if not self.FreeGame_OK then
		-- 	MainScene:setBtnEnble(true) --按钮启用
		-- else
		-- 	if self.freeleft > 0 and not self.FreeGameAgain_OK then
		-- 		MainScene:setFreeSpinBtnEnble(true);
		-- 	end
		-- end
	 -- 	MainScene:showWinline() 
	end),nil))
end


function GameViewLayer:GameShowScore() --分数滚动显示
	--得分滚动
	local textWin=0;
	local numb1 = 0;

	local numbWin = self.serverWin;
    --一秒之内滚动完成
    local unit = 11
    if numbWin > 0 then
        self._self.stepWin = math.ceil(numbWin / unit)
        self._self.stepBalance = math.ceil(numbWin / unit)
    end
	-- if numbWin > 0 and numbWin < 100 then
	-- 	self._self.stepWin = 1;
	-- 	self._self.stepBalance = 1;
	-- elseif  numbWin >= 100 and numbWin < 1000 then
	-- 	self._self.stepWin = 11;
	-- 	self._self.stepBalance = 11;
	-- elseif  numbWin >= 1000 and numbWin < 10000 then
	-- 	self._self.stepWin = 51;
	-- 	self._self.stepBalance = 51;
	-- elseif  numbWin >= 10000 and numbWin < 100000 then
	-- 	self._self.stepWin = 471;
	-- 	self._self.stepBalance = 471;
	-- elseif  numbWin >= 100000  then
	-- 	self._self.stepWin = 3461;
	-- 	self._self.stepBalance = 3461;
	-- end

    if self.serverWin>0 then
        AudioEngine.playEffect("mp3/win.mp3") 
    end

	if self.serverWin/self.linebet >= 1000 then
		self.BigWinPanel_Win:setVisible(true)
		self.BigWinPanel_Win:setString("0")
		--self.JackpotJinbi:setVisible(true)
	else
        AudioEngine.playEffect("mp3/maojinbi.mp3") 
		self.WinPanel:setVisible(true)
		self.WinPanel_Win:setString("0");
	end

	self.text_win:setString("0");
	self.text_win:setVisible(true)
	textWin=0;
	numb1 = self.serverWin;
	self.text_win:setString(string.format("%d", textWin) );
	self.WinPanel_Win:setString(string.format("%d", textWin) );
	self.BigWinPanel_Win:setString(string.format("%d", textWin) );
	self._self.schedulerIDWin3 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
		textWin = textWin+self._self.stepWin;
		self.text_win:setString(string.format("%d", textWin) );
		self.WinPanel_Win:setString(string.format("%d", textWin) );
		self.BigWinPanel_Win:setString(string.format("%d", textWin) );
		if(textWin>=numb1)then
			self.text_win:setString(string.format("%d", numb1) );
			self.WinPanel_Win:setString(string.format("%d", numb1) );
			self.BigWinPanel_Win:setString(string.format("%d", numb1) );
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._self.schedulerIDWin3);

			self._self:runAction(cc.Sequence:create(cc.DelayTime:create(2.0),cc.CallFunc:create(function()
				if not self.FreeGame_OK then
					self:setBtnEnble(true) --按钮启用
				else
					if self.freeleft > 0 and not self.FreeGameAgain_OK then
						self:setFreeSpinBtnEnble(true);
					end
				end
			 	self:showWinline() 
			 	self:closeWinPanel()

			end),nil))

		end
	end, 0.02, false);

	--总分滚动
	local textBalance = self.BalanceText;
	local numb = self.serverWin+self.BalanceText;
	
	--self.VoiceWinGold =AudioEngine.playEffect("mp3/main/Score.mp3",true)
	self.VoiceWinGold =cc.SimpleAudioEngine:getInstance():playEffect("mp3/main/Score.mp3",true)

    local str = ExternalFun.numberThousands(textBalance);
    local strRef = string.gsub(str, ",", ":")
    self.GameBalanceText:setString(strRef)

	self._self.schedulerIDWin2 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
		textBalance = textBalance+self._self.stepBalance;
		local str = ExternalFun.numberThousands(textBalance);
        local strRef = string.gsub(str, ",", ":")
        self.GameBalanceText:setString(strRef)
		if(textBalance >= numb)then                      
			 local str = ExternalFun.numberThousands(GlobalUserItem.lUserScore);
             local strRef = string.gsub(str, ",", ":")
             self.GameBalanceText:setString(strRef)
            if self._self.schedulerIDWin2 then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._self.schedulerIDWin2);
                self._self.schedulerIDWin2 = nil
            end
			AudioEngine.stopEffect(self.VoiceWinGold);
			self:GameBalanceMoveOver()
		end
	end, 0.02, false);

	--self.BalanceText = self.BalanceText + self.serverWin;

end


function GameViewLayer:showWinline()
	if self.winLines[1] == 0 then
	 	playMp3Index =2;	
	else 
	 	playMp3Index = 1;	
	end

	self.GameTotal:setVisible(false);

	local count =#self.winLines
	local countTime = 2.5 --中奖动画执行时间

	--运行完一轮后  继续自动旋转--MainScene.RUNING
	if (self.autoCount > 0  ) and autoSchedulerEntry~=nil  then  --定时器没有关闭才等待
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
		self._self:runAction(_seq)
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
		self._self:runAction(_seq)
	else
		self:gameOver()--设置游戏停止
	end


	local nTime = 0
	--MainScene:ScatterWinShow(); --是否有Scatter得分
	if self.GameScatterWinOK then
		nTime = 1.5;
	end

	local function zorder(sender) --开始调整到前面
		sender:setVisible(true);
	 	--sender:setLocalZOrder(1);
	 	--sender:setOpacity(0)
	 	self.GameLine:setVisible(false)
		self.GameWin:setVisible(false)

		local isPass = true
	 	for indexKey,lineNum in pairs(self.winLines) do
			if sender:getName() == ("line"..lineNum) then
				--print("【线路】："..tonumber(lineNum).."【金钱】:"..MainScene.LineWins[indexKey]/100)

				--MainScene._self:runAction(cc.Sequence:create(cc.DelayTime:create(nTime),cc.CallFunc:create(function()
					isPass = false
					self.GameScatterWinOK = false;
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
					--AudioEngine.playEffect("mp3/Reuslt3.mp3") 
				end
			else 
				for index,point in pairs(self.winLinePoints[playMp3Index])  do
					local ind  = tonumber(self.tab[point[1]][point[2]]) 
					if ind >= 6 then  
						if( self.freeleft ==-1 ) then 
						--	AudioEngine.playEffect("mp3/Reuslt1.mp3") 
						end 
					else  
						if( self.freeleft ==-1 ) then 
							AudioEngine.playEffect("mp3/FreeSpinWin.wav")
						end 
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
	animation:setLoops(2) 
	animation:setDelayPerUnit(0.7/17)
	local animate = cc.Animate:create(animation)

	local n_Animate = nil;
	local n_CardNum = 0;
	--图标闪动 框动画
	self.MoveKuang_Panel:removeAllChildren()
	for index,line in pairs(self.winLinePoints) do --显示点
		for index2,point in pairs(line) do
			local dt =cc.DelayTime:create(0+(index-1) * countTime)
			local dt2 =cc.DelayTime:create( (count-index) * countTime)
			local fadein = cc.FadeIn:create(0.2)
			local fadeout= cc.FadeOut:create(0.2)
			n_CardNum = tonumber(self.tab[point[1]][point[2]]);
			if n_CardNum < 11 then --数字闪动
				local seq =cc.Sequence:create(dt,fadeout:clone(),cc.DelayTime:create(0.2),
												fadein:clone(),cc.DelayTime:create(0.3),
												fadeout:clone(),cc.DelayTime:create(0.2),fadein:clone(),
												cc.DelayTime:create(0.5),dt2,nil)
				local rf =cc.RepeatForever:create(seq)
				self.table_pans[point[1]]:getChildren()[point[2]]:runAction(rf);
			else
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
			local seq =cc.Sequence:create(dt,cc.DelayTime:create(0.1),fadein,animate:clone(),fadeout,dt2,nil)
			local rf =cc.RepeatForever:create(seq)
			local star = cc.Sprite:create("kuan.png")
			star:setPosition(point[1]*188+101,58+point[2]*160)  
			star:setScaleX(0.62)
			star:setScaleY(0.55)
			star:setOpacity(0)
			star:setLocalZOrder(MAXZORDER-1)
			self.MoveKuang_Panel:addChild(star)
			table.insert(self.table_winStars,star)
			star:setName(index)
			star:runAction(rf) 
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
		end
	end
	---------------------------------------------------------------------------------
end


--结果显示错误处理
function GameViewLayer:GameBalanceMoveOver()
	if self.BalanceText ~= GlobalUserItem.lUserScore then
	    self.BalanceText = GlobalUserItem.lUserScore;
        local str = ExternalFun.numberThousands(self.BalanceText);
        local strRef = string.gsub(str, ",", ":")
        self.GameBalanceText:setString(strRef)
	end
end



function GameViewLayer:LineWinShow(_line,_win)
	self.GameLine:setVisible(true)
	self.GameWin:setVisible(true)
	self.GameLine_Line:setString(self.GameLineCount)
	self.GameWin_Line:setString(_line)
	self.GameWin_Win:setString(string.format("%d", _win))
    AudioEngine.playEffect("mp3/FreeSpinWin.wav")

end

function GameViewLayer:showFive(win5indexs,index)
	--print("进五连")
	-- self.bFiveLine = true
	-- AudioEngine.playEffect("mp3/main/5ofAKind.mp3")
	-- self.AniFiveLine = cc.Sprite:create("Jackpot/5ofkind0.png")--ccs.Armature:create("5ofkind")
	-- self.AniFiveLine:setPosition(cc.p(1280/2,720/2));
	-- self.AniFiveLine:setLocalZOrder(MAXZORDER+1)
	-- --self.AniFiveLine:getAnimation():playWithIndex(0)
	-- self._self:addChild(self.AniFiveLine);
	-- self._self:runAction(cc.Sequence:create(cc.DelayTime:create(3.2),cc.CallFunc:create(function()
	-- 	self.bFiveLine = false
	-- 	self.AniFiveLine:removeFromParent(true);
	 	self:goShowWinline()
	-- end),nil))
end

-----------------------------------------顶部中奖提示-------------------------------
function GameViewLayer:GameLineShow()
	self.GameLine:setVisible(true)
	self.GameLine_Line:setString(self.GameLineCount)
end

function GameViewLayer:getJackpotWin(_id,_win)
	self.JackpotTextID  = _id
	self.JackpotTextNum = _win
end

function GameViewLayer:GameJackpot(_num) --彩金效果
	self.GameJackotTag = true;
	--system:setBtnEnable(self._self,false);
	self:startTime(false)
	if self.autoCount > 0 then --停止自动旋转
		self.autoCount = 0
		self.btn_stop:setVisible(false);
		self.btn_autostop:setVisible(false)--隐藏stop
		--self.btn_autospin:setVisible(true)
	end
	self._self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function()
		--self.JackpotJinbi:setVisible(true);
		AudioEngine.playEffect("Jackpot/JackpotWin.mp3",true)
		self._self:runAction(cc.Sequence:create(cc.DelayTime:create(0.6),cc.CallFunc:create(function()

			if _num == 1 then
				--self.JackpotRandom:setVisible(true);
				--self.JackpotRandom:getAnimation():playWithIndex(0)
			elseif _num == 2 then
				--self.JackpotMinor:setVisible(true);
				--self.JackpotMinor:getAnimation():playWithIndex(2)
			elseif _num == 3 then
				--self.JackpotMajor:setVisible(true);
				--self.JackpotMajor:getAnimation():playWithIndex(1)
			end
			self._self:runAction(cc.Sequence:create(cc.DelayTime:create(0.6),cc.CallFunc:create(function()
				--self.JackpotXing:setVisible(true);
				--self.JackpotXing:getAnimation():playWithIndex(3);
				--self.JackpotTextNum = math.random(10000,1000000); 
				--self.JackpotText:setString("0");
				--self.JackpotText:setVisible(true);

				local text=0;
				local numb = self.JackpotTextNum;
				if numb <= 100000 then
					self._self.stepJackpot = 29;
				elseif numb > 100000 and numb <= 1000000 then
					self._self.stepJackpot = 45;
				elseif numb > 1000000 then
					self._self.stepJackpot = 419;
				end
				local VoiceGold =AudioEngine.playEffect("Jackpot/Score.mp3",true)
				--self.JackpotText:setString(string.format("%d", text) );
				self._self.schedulerIDWin1 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
					text = text+self._self.stepJackpot;
					--self.JackpotText:setString(string.format("%d", text) );
					if(text>=numb)then
						--self.JackpotText:setString(string.format("%d", numb) );
						cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._self.schedulerIDWin1);
						AudioEngine.stopEffect(VoiceGold);
						--self.JackpotJinbi:setVisible(false);
						--system:setBtnEnable(self._self,true);
						self.BalanceText = GlobalUserItem.lUserScore;
		        		local str = ExternalFun.numberThousands(self.BalanceText);
                        local strRef = string.gsub(str, ",", ":")
                        self.GameBalanceText:setString(strRef)
						if not self.FreeGame_OK then
							self:setBtnEnble(true);
						end
					end
				end, 0.02, false);
			end),nil))
		end),nil))
	end),nil))
end


--清除赢了的动画和元素框
function GameViewLayer:cleanWin()
	if self.playWinMusicEntry ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.playWinMusicEntry)
		self.playWinMusicEntry = nil 
	end 

	if self._self.schedulerIDWin1 ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._self.schedulerIDWin1);
		self._self.schedulerIDWin1 = nil;
	end

	if self._self.schedulerIDWin2 ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._self.schedulerIDWin2);
		self._self.schedulerIDWin2 = nil;
	end

	if self._self.schedulerIDWin3 ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._self.schedulerIDWin3);
		self._self.schedulerIDWin3 = nil;
	end

	if self._self.schedulerIDWin4 ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._self.schedulerIDWin4);
		self._self.schedulerIDWin4 = nil;
	end

	self:closeWinPanel()
	self.GameScatterWinOK = false;
	self.GameStopOK = false;
	self.rollCountTemp = 0;
	self.GameLine:setVisible(false)
	self.GameWin:setVisible(false)
	self.GameScatter:stopAllActions()
	self.GameScatter:setVisible(false)
	self:cleanBigwin(); --关闭bigwin
	--清除定时器
	self._self:stopAllActions()
	self.btn_stop:stopAllActions()

	self.GameWinScatter = false; 

	--system:setWinScore(self._self,0) --清空赢了多少
    print("=========================",#self.table_winStars)
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
		--sprite_line:setLocalZOrder(998) 
		sprite_line:setVisible(false)
	end

	--Scatter火动画
	for k,v in pairs(self.tab_xing) do 
		v:removeFromParent(true); 
	end 
	self.tab_xing ={};

	--进入免费动画
	for k,v in pairs(self.Game_gofree) do
		v:removeFromParent(true);
	end
	self.Game_gofree ={};

	for i=1,5 do 
		--self.table_pans[i]:setLocalZOrder(0)
		self.table_pans[i]:stopAllActions()
	end

	if self.GameJackotTag then
		--self.JackpotRandom:setVisible(false);
		--self.JackpotMinor:setVisible(false);
		--self.JackpotMajor:setVisible(false);
		--self.JackpotXing:setVisible(false);
		--self.JackpotText:setVisible(false);
		--self.JackpotJinbi:setVisible(false);
		self.JackpotTextNum = 0;
		self.JackpotTextID = 0;
	end
end



function GameViewLayer:closeWinPanel()
	self.BigWinPanel:setVisible(false)
	self.BigWinPanel_Win:setString("0")
	--self.JackpotJinbi:setVisible(false)
	self.WinPanel:setVisible(false)
	self.WinPanel_Win:setString("0")
end

--播放提示免费游戏
function GameViewLayer:goinFree()
	self._self:stopAllActions();
	self.RUNING =false;
	self:cleanWin()
	self.text_free_win:setString("0.00")
	AudioEngine.playEffect("mp3/FreeSpinsBegin.wav")
	print("-------------播放进入免费旋转动画-------------")

	---------------------------------------------进入选择金罐游戏		
	for k,v in pairs(self.Game_gofree) do
		v:removeFromParent(true);
	end
	self.Game_gofree ={};

	self.pColorLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 255*0.80), 1334, 750)
    self._self:addChild(self.pColorLayer, 1)
    self.pColorLayer:setVisible(true)

	local sp_gofree = cc.Sprite:create("Animation/gofree/0.png")
	local star_action=cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("gofree"))
	sp_gofree:setScale(0.8);
	sp_gofree:runAction(star_action);
	sp_gofree:setLocalZOrder(0)
	sp_gofree:setPosition(640,350);
	self._self:addChild(sp_gofree,2);
	table.insert(self.Game_gofree,sp_gofree);
	------------------------------------------------

	self._self:runAction(cc.Sequence:create(cc.DelayTime:create(2.2),cc.CallFunc:create(function()
		local _BeginBtn = nil
		function BeginBtnCallback(sender, eventType)
	        if eventType == ccui.TouchEventType.ended then
	        	self.pColorLayer:setVisible(false)
				for k,v in pairs(self.Game_gofree) do
					v:removeFromParent(true);
				end
				self.Game_gofree ={};
				_BeginBtn:setVisible(false)
				self:closeWinPanel()
				print("---------------免费旋转开始转动--------------")
				self:autoRoll()
				self:startTime(true)
				AudioEngine.playMusic("mp3/RollingFreeSpins.mp3",true)
				self.isFreeOK = true
				self.pan_free:setVisible(true)
	        end
	    end

		_BeginBtn = ccui.Button:create("main/begin.png", "", "");
	    _BeginBtn:setPosition(637, 201)
	    _BeginBtn:setScale(0.8)
	    _BeginBtn:addTouchEventListener(BeginBtnCallback)
	    self._self:addChild(_BeginBtn,2)
	end),nil))
end


function GameViewLayer:WildPosition(pos)
	local posX = 0
	local posY = 0
	print("--------------------------:"..pos)
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


    local layout = cc.Sprite:create("Animation/11/0.png")
	local star_action=cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("goScatter"))
	layout:setScaleX(0.66)
	layout:setScaleY(0.66)
    local LcurPosX = posX*181+110
    local lCurPosY = posY*168+51;
    if posX == 2 then
        LcurPosX = LcurPosX+2
        lCurPosY = lCurPosY-4
    end
    if posX == 3 then
        LcurPosX = LcurPosX+14
        lCurPosY = lCurPosY-6
    end
    if posX == 4 then
        LcurPosX = LcurPosX+26
        lCurPosY = lCurPosY-5
    end

    if posX == 5 then
        LcurPosX = LcurPosX+37
        lCurPosY = lCurPosY-6
    end
	layout:setPosition(LcurPosX,lCurPosY);  -- i*181+99  i*162+52
	layout:runAction(star_action);
	table.insert(self.table_winStars,layout)
	--self._self:getResourceNode():addChild(layout)
	self.SatterPanel:addChild(layout)
end

function GameViewLayer:playAnim()  --Scatter和wild动画
	--可变  
	local animationWild =cc.Animation:create()
	for i = 1 ,12 do 
		local str = string.format("Animation/12/%d.png",(i-1))
		animationWild:addSpriteFrameWithFile(str)
	end
	animationWild:setLoops(2) 
	animationWild:setDelayPerUnit(1.5/12)
	local animateWild = cc.Animate:create(animationWild);

	for index,line in pairs(self.winLinePoints) do --显示点 
		for index2,point in pairs(line) do 
			if  self.tab[point[1]][point[2]] == "12" then ----可变动画
			 	local seq =cc.Sequence:create(animateWild:clone(),nil)
				local rf =cc.RepeatForever:create(seq)
				local layout = cc.Sprite:create("Animation/12/0.png")
				layout:setScale(0.66)
				layout:setLocalZOrder(MAXZORDER+200)
                local lCurPosX = point[1]*181+93
                local lCurPosY = point[2]*168+46
                if point[1] == 1 then
                 lCurPosX = lCurPosX+7
                end
                if point[1] == 2 then
                  lCurPosX = lCurPosX+13
                  lCurPosY = lCurPosY-4
                end
                 if point[1] == 3 then
                  lCurPosX = lCurPosX+22
                  lCurPosY = lCurPosY-6
                 end
                  if point[1] == 4 then
                  lCurPosX = lCurPosX+33
                  lCurPosY = lCurPosY-5
                 end

                  if point[1] == 5 then
                  lCurPosX = lCurPosX+38
                  lCurPosY = lCurPosY-5
                 end


				layout:setPosition(lCurPosX,lCurPosY) -- i*181+93 i*162+46
				layout:runAction(rf)
				table.insert(self.table_winStars,layout)
				self.SatterPanel:addChild(layout)
			end
		end 
	end  
end 



function GameViewLayer:buildTab()
	for indexKey,pan_1 in pairs(self.table_pans) do
		for index,sprite in pairs(pan_1:getChildren()) do
			self.tab[indexKey][index] = sprite:getName()
			--printf(sprite:getName())
		end 
	end 
end

function GameViewLayer:startGameByNet(flag,bFree)  --发送开始旋转
	--余额判断 用户余额少于用户花费 则提示
	self:GameBetIndex();
	if( (not bFree) and  GlobalUserItem.lUserScore < self.bet[self.betIndex]*self.lines ) then
            QueryDialog:create("你的金币不足,是否充值",function(bReTry)
                if bReTry == true then
                    --self:requestServerConfig()
                else
                    return;
                end
             end)
             :addTo(self,10)
--            return 
--			print("#123###################123")
--			local tipLayer = cc.CSLoader:createNode("credit/NotEnoughCreditLayer.csb")
--			local btn_continue = tipLayer:getChildByName("btn")
--			btn_continue:addTouchEventListener(
--			function(sender, eventType)
--				if eventType == ccui.TouchEventType.ended then
--					tipLayer:stopAllActions()
--					tipLayer:removeFromParent(true)
--				end 
--			end)
--			self._self:addChild(tipLayer)

--			self.autoCount = 0--关闭自动旋转定时器
        self.RUNING = true
        self:setBtnEnble(true) --按钮启用 
        self.btn_spin:setEnabled(true)
        self.btn_spin:setBright(true)
		return 
	end

	if(self.RUNING == false ) then  --已经发送了启动请求屏蔽
        self.isGameOver = false
		if self.isFreeOver then
			self:FreeGameOver()
			self.isFreeOver = false
		end
		AudioEngine.stopAllEffects()
		self:cleanWin()
		if(self.freeleft < 0) then
			--AudioEngine.playEffect("mp3/ButtonSpin.mp3") 
		end 
		--self.btn_game:setVisible(false) --隐藏小游戏
		self:setBtnEnble(false) --按钮禁用
		self:setFreeSpinBtnEnble(false);

		self.BalanceText =GlobalUserItem.lUserScore;
	    local str = ExternalFun.numberThousands(self.BalanceText);
        local strRef = string.gsub(str, ",", ":")
        self.GameBalanceText:setString(strRef)
		local Time = 0
		self.text_win:setString(string.format("%d", self.serverWin));
		if self.serverWin > 0 then
			Time = 0.2
		end

		self._self:runAction(cc.Sequence:create(cc.DelayTime:create(Time),cc.CallFunc:create(function()
			self.text_win:setString("0");
			self.text_win:setVisible(false)
		end),nil))

		if self.bFiveLine then
        	if self.AniFiveLine ~=  nil and not tolua.isnull(self.AniFiveLine) then
         		self.AniFiveLine:removeFromParent(true);
        	end	
		end

		--参数1 线数，线花费，总花费
		self.TotalBet = (self.bet[self.betIndex]*self.lines) --总押注
		self.linebet = self.bet[self.betIndex] --单线押注
		self.freeCointCount = self.betIndex
		b_sendMsgCallback  = false;
		print("------发送旋转消息给服务器----")
		print("【线路】："..self.lines)
		print("【总押注】："..self.TotalBet)
		print("【单线押注】："..self.linebet)
		print("-------------------------------")
		self.GameRollFunNum = 0;

		--self._self:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function()
			self._scene:startGame(self.lines,self.TotalBet,self.linebet,bFree) --开始游戏，发送给服务端
		--end),nil))
        AudioEngine.playEffect("mp3/start.mp3") 

		self.RUNING = true
		--游戏开始立马旋转，接收到网络消息后停止。
		self:GameRollFun();

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


function GameViewLayer:GameRollFun()
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

	if b_sendMsgCallback then
		self:startRollBegin(self.serverIcos,self.serverWin);
		return;
	end

	for indexKey,pan_1 in pairs(self.table_pans) do
		local roll = self:createRoll(9,indexKey)
		pan_1:addChild(roll)
		local height =9 *220*0.66--胶带长度+窗口长度
		for key,value in pairs(pan_1:getChildren()) do
			local mov = cc.MoveBy:create(height/1700,cc.p(0,-height))--时间=s/v
			local seq = cc.Sequence:create(mov);

            local seq2 = cc.Sequence:create(mov,cc.CallFunc:create(function()
				self:GameRollFun()
				end))



			value:stopAllActions();
			if key ==#pan_1:getChildren() then

				value:runAction(seq2)
			else
				value:runAction(seq)
			end
		end
	end
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
	print("----------- 输赢："..win)

	self.ROLLING = true;
	b_sendMsgCallback = true;
	self.serverWin = win;
	self.serverIcos =icos;
	--开始游戏，发送给服务端 控制不同按钮显示
	if self.autoCount > 0 then
		self.btn_autostop:setEnabled(true);
		self.btn_autostop:setBright(true);
	end

	if self.autoFlag == AUTOROLL then --自动旋转
		if( self.freeleft ==-1 ) then 
            local sTempSpirite=self._csbNode:getChildByName("Sprite_6") 
            sTempSpirite:runAction(cc.Sequence:create(cc.DelayTime:create(0.65),cc.CallFunc:create(function()
    			self.rollBgMp3Id  = AudioEngine.playEffect("mp3/zhuanting.mp3") 
    		end),nil))
		end
		self.btn_autostop:setVisible(true)--显示stop
		self.btn_stop:setVisible(true);
	elseif self.autoFlag == FREEROLL then --免费旋转  
		--MainScene.rollBgMp3Id = AudioEngine.playEffect("mp3/Rolling.mp3") 
		self.text_spins_left:setString(self.freeleft)
		
		self.btn_freespin:setEnabled(false);
		self.btn_freestop:setEnabled(true);
		self.btn_freestop:setBright(true);
		self.btn_freestop:setVisible(true);	
	else
		if( self.freeleft == -1 ) then
            local sTempSpirite=self._csbNode:getChildByName("Sprite_6") 
            sTempSpirite:runAction(cc.Sequence:create(cc.DelayTime:create(0.65),cc.CallFunc:create(function()
                if not self.isGameOver then
                    self.rollBgMp3Id  = AudioEngine.playEffect("mp3/zhuanting.mp3")
                end
            end),nil))
		end
		self.btn_stop:setVisible(true)--显示stop
        
	end  

	--免费游戏不用减积分
	if(self.freeleft == -1) then 
		--system:subScore(MainScene._self,MainScene.TotalBet/100)

        if self.serverWin == 0 then
         self.BalanceText = GlobalUserItem.lUserScore 
        else
         self.BalanceText = GlobalUserItem.lUserScore -self.serverWin
        end


		
        --- self.TotalBet;
		local str = ExternalFun.numberThousands(self.BalanceText);
        local strRef = string.gsub(str, ",", ":")
        self.GameBalanceText:setString(strRef)
	end 
end

--再次连接胶片后的回调
function GameViewLayer:startRollBegin(icos,win)
	self.rollCount=0--记录滚动完成 
	self.rollCountTemp=0;
	--MainScene:showLines(0) --隐藏中奖线	 
	--MainScene:setBtnEnble(false) --按钮禁用
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
		local roll = self:createRoll(rollconut) --添加胶带 25表示多少个胶带	
		pan_1:addChild(roll) 
		self:initNewCard(rollconut,pan_1,{icos[indexKey+10],icos[indexKey+5],icos[indexKey]}) --添加新卡牌
		local height =rollconut*220*0.66 + 485 --胶带长度+窗口长度
		for key,value in pairs(pan_1:getChildren()) do 
			value:stopAllActions(); 

			if key <= 2 then  --前面4个动画结束，要清除掉
				local mov = cc.MoveBy:create(height/1700,cc.p(0,-height))--时间=s/v
				local movUp2 = cc.MoveBy:create(0.1,cc.p(0,-10))--结束回弹
				local movDown2 = cc.MoveBy:create(0.1,cc.p(0,10))--结束回弹
				local seq = cc.Sequence:create(mov,cc.CallFunc:create(callback),movUp2,movDown2,nil)
				value:runAction(seq)
			elseif key <= 4 then --中间2个不用回调
				local mov = cc.MoveBy:create(height/1700,cc.p(0,-height))--时间=s/v
				local movUp2 = cc.MoveBy:create(0.1,cc.p(0,-10))--结束回弹
				local movDown2 = cc.MoveBy:create(0.1,cc.p(0,10))--结束回弹
				local seq = cc.Sequence:create(mov,movUp2,movDown2,nil)
				value:runAction(seq)
			elseif key == 5 then --最后一个执行滚动完成回调
				local mov = cc.MoveBy:create(height/1700,cc.p(0,-height))--时间=s/v
				local movUp2 = cc.MoveBy:create(0.1,cc.p(0,-10))--结束回弹
				local movDown2 = cc.MoveBy:create(0.1,cc.p(0,10))--结束回弹
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
--						local x,y =self.table_pans[self.rollCount+1]:getPosition();
--						local sp =cc.Sprite:create("xing/1.png")

--						local star_anim=cc.Animation:create()
--						for i=1,11 do
--							star_anim:addSpriteFrameWithFile(string.format("xing/%d.png",i))
--						end
--						star_anim:setDelayPerUnit(0.1) 
--						local star_action=cc.Animate:create(star_anim)

--						sp:runAction(cc.RepeatForever:create(star_action:clone()));
--						sp:setPosition(x+280-18,y+550/2 -42);
--						sp:setScaleX(1.2)
--						sp:setScaleY(1.17)
--						sp:setLocalZOrder(MAXZORDER+200)

--						self._csbNode:addChild(sp);
--						table.insert(self.tab_xing,sp);
					end

					if scatterIndex >= 3 and self.rollCount < 4 then
						if not(self.ScatterMp3Id ==nil) then
							AudioEngine.stopEffect(self.ScatterMp3Id)
						end
						--self.ScatterMp3Id = AudioEngine.playEffect("mp3/main/TwoScatter.mp3")
					end

					if has11 then
						if indexKey <= 4 then
							--AudioEngine.playEffect("mp3/StopScatter"..(scatterIndex - 1)..".mp3")
						else
							if scatterIndex > 3 then
								--AudioEngine.playEffect("mp3/StopScatter"..(scatterIndex - 1)..".mp3")
							else
								if self.freeleft ==-1 then 
									--AudioEngine.playEffect("mp3/Stop.mp3")
								end
							end
						end
					else 
						if self.freeleft ==-1 then 
							--AudioEngine.playEffect("mp3/Stop.mp3")
						end
					end
				end ),movUp2,movDown2,cc.CallFunc:create(rollOver),nil)
				value:runAction(seq)
			end
		end 
	end
end




function GameViewLayer:Reconnection(nfreetime,nfreeAlltime,nlinebet,nFreeCountWin,icon)

--免费游戏的时候什么按钮都是静止的

print("111111111111111111111111111111111")
    self.btn_bet_sub:setEnabled(false)
    self.btn_bet_sub:setBright(false)
    self.btn_bet_add:setEnabled(false)
    self.btn_bet_add:setBright(false)
    self.btn_spinMax:setEnabled(false)
    self.btn_spinMax:setBright(false)
    self.betIndex=1;
    for i = 1 , 7 do 
        if self.bet[i] == nlinebet then
             self.betIndex=i;
        end

    end





    self.freeleft=nfreetime



    	AudioEngine.playMusic("mp3/RollingFreeSpins.mp3",true)
	local app = require("app.MyApp")
	--显示免费游戏
	--MainScene.sp_logo:setVisible(false)
	self.FreeGame_OK = true;
	--MainScene.mainbg_free:setVisible(true)
	self.pan_free:setVisible(true)
        self.lines = 20
	self.freeleft = nfreetime
	self.gameWin= nFreeCountWin
	self.freeWinCount=nFreeCountWin
	--self.text_free_win:setString(string.format("%d", self.nFreeCountWin))
	self.text_spins_left:setString(self.freeleft)
	self.text_mult:setString(3);

--	-----------------------------------------------------------
--	print("---------------------断线重连--------------------")
--	print("【免费次数】："..self.nfreetime)
--	print("【免费倍数】："..3)
--	print("【进免费赢】："..self.nGameWin)
--	print("【单线押注】："..self.nlinebet)
--	print("【押注线路】："..self.nbetline)
--	print("【免费赢】："..self.nFreeCountWin)
--	print("-------------------------------------------------")

	for i,bet in pairs(self.bet) do
		if bet == app.nlinebet then
			self.betIndex = i
		end
	end

     self:updateText()

	----------------------------------------------------------
	self._self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
		self:autoRoll()
		self:startTime(true) 
		self.isFreeOK = true
	end),nil))



    
    


end

--初始化新卡牌
function GameViewLayer:initNewCard(count,pan_1,col3ByFoot)
	local height= count*220*0.66
	--printf("新初始化卡牌")
	for i = 1 , 3 do 
		local  value = col3ByFoot[i]
		local card1_1 = cc.Sprite:create("card/"..value..".png") 
		card1_1:setScaleX(0.66);
		card1_1:setScaleY(0.66);
		card1_1:setName(value)
		card1_1:setAnchorPoint(0,0); 

		if(count==0) then 
			card1_1:setPosition(10,168*(i-1));
		else
			card1_1:setPosition(10,height+485+168*(i-1));
		end 
		pan_1:addChild(card1_1)
	end
end

--创建胶带 几个滚动方格
function GameViewLayer:createRoll(count)
	local sum =count/8 --完整块个数
	--220高度，220宽度
	local height = (count%8)*220 --剩下的宽度
	local roll =nil ;
	local roll1Height = 880;

	local str_roll1 = nil;
	local str_roll2 = nil;

	local temp_roll = 0;
	local random_roll = 1;
	local random_roll1 = 1;
	local randomWild = math.random(1,5)

	if randomWild == 1 then
		temp_roll = 3;
		random_roll = math.random(1,2)
		random_roll1 = math.random(1,2)
	else
		temp_roll = 1245;
		random_roll = math.random(1,4)
		random_roll1 = math.random(1,4)
	end

	str_roll1 = string.format("roll%d_%d.png",temp_roll,random_roll)
	str_roll2 = string.format("roll%d_%d.png",temp_roll,random_roll1)

	if height <= roll1Height then
		local texture = cc.Director:getInstance():getTextureCache():getTextureForKey(str_roll1)
		roll = cc.Sprite:createWithTexture(texture,cc.rect(0,0,220,height)) --从上向下剪切
	else
		local texture = cc.Director:getInstance():getTextureCache():getTextureForKey(str_roll1)
		local texture2 = cc.Director:getInstance():getTextureCache():getTextureForKey(str_roll2)

		roll = cc.Sprite:createWithTexture(texture,cc.rect(0,0,220,roll1Height)) --从上向下剪切
		local roll2 = cc.Sprite:createWithTexture(texture2,cc.rect(0,0,220,height-roll1Height))
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
		_r1:setPositionY(height+(i-1)*1760) --拼接到图片上部
		roll:addChild(_r1)
	end
	--设置位置
	roll:setScaleX(0.80);
	roll:setScaleY(0.66);
	roll:setAnchorPoint(0,0)
	roll:setPosition(0,485)
	return roll
end

--点击stop
function GameViewLayer:stopRall() 
	self:GameBetIndex();
	self.GameStopOK = true;

 	for indexKey,pan_1 in pairs(self.table_pans) do
		pan_1:removeAllChildren();
		self._self:initNewCard(0,pan_1,{self.serverIcos[indexKey+10],self.serverIcos[indexKey+5],self.serverIcos[indexKey]}) --添加新卡牌
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
				height=height+168

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

function GameViewLayer:onExit()
    if autoSchedulerEntry ~= nil then
         cc.Director:getInstance():getScheduler():unscheduleScriptEntry(autoSchedulerEntry) 
    end

     if self.BtntimerHandle ~= nil then
         cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.BtntimerHandle) 
    end
	if(self.schedulerIDWin5) then 
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerIDWin5)
		self.schedulerIDWin5 = nil 
	end
	AudioEngine.stopMusic()
    --播放背景音乐
    ExternalFun.playBackgroudAudio("background.mp3")
    print("5555555555")
	self._laba:closeTime()
    
end

--用户分数
function GameViewLayer:onGetUserScore( useritem )
    --自己
    if useritem.dwUserID == GlobalUserItem.dwUserID then
       --self.BalanceText = useritem.lScore
        --self:resetSelfInfo()
    end
end


return GameViewLayer