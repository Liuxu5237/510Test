local GameViewLayer = class("GameViewLayer",function(scene)
		local gameViewLayer =  display.newLayer()
    return gameViewLayer
end)
local module_pre = "game.yule.longhu.src"
--external
--
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local g_var = ExternalFun.req_var
local ClipText = appdf.EXTERNAL_SRC .. "ClipText"
local PopupInfoHead = appdf.EXTERNAL_SRC .. "PopupInfoHead"
--
local cmd = module_pre .. ".models.CMD_Game"
local game_cmd = appdf.HEADER_SRC .. "CMD_GameServer"
local QueryDialog   = require("app.views.layer.other.QueryDialog")

local GameLogic = appdf.req(module_pre .. ".models.GameLogic")
local GameRecord = appdf.req(module_pre .. ".views.layer.GameRecord")

--utils
--
local UserListLayer = module_pre .. ".views.layer.userlist.UserListLayer"
local ApplyListLayer = module_pre .. ".views.layer.userlist.ApplyListLayer"
local SettingLayer = module_pre .. ".views.layer.SettingLayer"
local WallBillLayer = module_pre .. ".views.layer.WallBillLayer"
local SitRoleNode = module_pre .. ".views.layer.SitRoleNode"
local GameCardLayer = module_pre .. ".views.layer.GameCardLayer"
local GameResultLayer = module_pre .. ".views.layer.GameResultLayer"


local scheduler = cc.Director:getInstance():getScheduler()

local GameNotice = appdf.req(appdf.BASE_SRC .."app.views.layer.other.GameNotice")

--
--用户头像
local HeadSprite = appdf.req(appdf.EXTERNAL_SRC .. "HeadSprite")

GameViewLayer.TAG_START				= 100
local enumTable = 
{
    "BT_RELATION",
    "BT_HELP",
	"BT_EXIT",
	"BT_START",
	"BT_LUDAN",
	"BT_BANK",
	"BT_SET",
	"BT_ROBBANKER",
	"BT_APPLYBANKER",
	"BT_USERLIST",
	"BT_APPLYLIST",
	"BANK_LAYER",
	"BT_CLOSEBANK",
	"BT_TAKESCORE"
}
local TAG_ENUM = ExternalFun.declarEnumWithTable(GameViewLayer.TAG_START, enumTable);
local zorders = 
{
	"CLOCK_ZORDER",
	"SITDOWN_ZORDER",
	"DROPDOWN_ZORDER",
	"DROPDOWN_CHECK_ZORDER",
	"GAMECARD_ZORDER",
	"SETTING_ZORDER",
	"ROLEINFO_ZORDER",
	"BANK_ZORDER",
	"USERLIST_ZORDER",
	"WALLBILL_ZORDER",
	"GAMERS_ZORDER",	
	"ENDCLOCK_ZORDER"
}
local TAG_ZORDER = ExternalFun.declarEnumWithTable(1, zorders);

local AdminContorl = 
{
	"Btn_Contorl",
    "Btn_AmendStock",
    "Btn_BankerWin",
    "Btn_BankerLost",
    "Btn_UpdatData",
    "Btn_LongWin",
    "Btn_HuWin",
    "Btn_HeWin",
    "Btn_Exec",
    "Btn_Close",
    "Btn_Store"
}

local TAG_Admin= ExternalFun.declarEnumWithTable(1, AdminContorl);

local enumApply =
{
	"kCancelState",
	"kApplyState",
	"kApplyedState",
	"kSupperApplyed"
}
GameViewLayer._apply_state = ExternalFun.declarEnumWithTable(0, enumApply)
local APPLY_STATE = GameViewLayer._apply_state

--默认选中的筹码
local DEFAULT_BET = 1

function GameViewLayer:ctor(scene)
	--注册node事件
	ExternalFun.registerNodeEvent(self)
	self.m_bPlayGoldFlyIn = 4
	self._scene = scene
    self:gameDataInit()
	--初始化csb界面
	self:initCsbRes()
   
end

function GameViewLayer:loadRes(  )
	--加载卡牌纹理
	--cc.Director:getInstance():getTextureCache():addImage("game/card.png");
    cc.SpriteFrameCache:getInstance():addSpriteFrames("game/trendAnime.plist")
    --下注特效
    cc.SpriteFrameCache:getInstance():addSpriteFrames("game/Betfire.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("game/Long_Effects.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("game/buzhidao_Effects.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("game/poker/pukes.plist")
end


function GameViewLayer:gameDataInit( )
--下注信息
	  --播放背景音乐
    ExternalFun.playBackgroudAudio("s_bg.MP3")
   -- AudioEngine.playMusic("sound_res/BG.mp3",true)
    --用户列表
	self:getDataMgr():initUserList(self:getParentNode():getUserList())

    --加载资源
	self:loadRes()

     --声音控制
    self.m_bPlaerSounder=true;

	--变量声明
	self.m_nJettonSelect = -1
	self.m_lHaveJetton = 0;
	self.m_llMaxJetton = 0;
	self.m_llCondition = 0;
	yl.m_bDynamicJoin = false;
	self.m_scoreUser = self:getMeUserItem().lScore or 0

    --界面控件
    self.GameNods = nil
	--下注信息
	self.m_tableJettonBtn = {};
	self.m_tableJettonArea = {};

    --没门区域
    self.m_tableJettonLong = 0;
    self.m_tableJettonHu = 0;
    self.m_tableJettonHe = 0;
    --总下注
    self.m_AllJettonHe={0,0,0}

    --真人下注金额
    self.m_AllPersonote={0,0,0}

    --闪动 动画
    self.m_TwinkleAnime={}

	--下注提示
	self.m_tableJettonNode = {};

	self.m_applyListLayer = nil
	self.m_userListLayer = nil
	self.m_wallBill = nil
	self.m_cardLayer = nil
	self.m_gameResultLayer = nil
	self.m_pClock = nil
	self.m_bankLayer = nil


     --发牌控制
    self.m_CaedContorlAnime = 0;
	--申请状态
	self.m_enApplyState = APPLY_STATE.kCancelState
	--超级抢庄申请
	self.m_bSupperRobApplyed = false
	--超级抢庄配置
	self.m_tabSupperRobConfig = {}
	--金币抢庄提示
	self.m_bRobAlert = false

	--用户坐下配置
	self.m_tabSitDownConfig = {}
	self.m_tabSitDownUser = {}
	--自己坐下
	self.m_nSelfSitIdx = nil

	--座位列表
	self.m_tabSitDownList = {}

	--当前抢庄用户
	self.m_wCurrentRobApply = yl.INVALID_CHAIR

	--当前庄家用户
	self.m_wBankerUser = yl.INVALID_CHAIR

	--选中的筹码
	self.m_nSelectBet = DEFAULT_BET

	--是否结算状态
	self.m_bOnGameRes = false

	--是否无人坐庄
	self.m_bNoBanker = false

	--
	self.m_bIsTwoNumber = 0

    --路单初始化 当前多少列多少行
    self.SingleRowTable = {row=1,column = 1}
    --当前路单类型 -1 代表没有  0  龙 1虎   2  和气生财
    self.CurSingleType =  - 1 
    --基础位置
    self.CurSingBaseX = 18.75
    self.CurSingBaseY= 92.10
    self.SingleTable = {}       --保存当前数据
--        self.SingleTable[1]=1
--     self.SingleTable[2]=2
--      self.SingleTable[3]=3
--    self:CopyNexSinger()

    --庄稼钱
    self.bankScore = nil
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


--初始化按钮
function GameViewLayer:InitGameBtns(csbParent)
   	--按钮列表
	local function btnEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			self:onButtonClickedEvent(sender:getTag(), sender);
		end
	end	

    --帮助图片
    self.m_ImageHelp = csbParent:getChildByName("Image_Help");
    self.m_ImageHelp:setGlobalZOrder(100)
    self.m_ImageHelp:setLocalZOrder(100)
    local btn = csbParent:getChildByName("back_btn");
	btn:setTag(TAG_ENUM.BT_RELATION);
	btn:addTouchEventListener(btnEvent);
    --帮助
    self.bShowParent = false
    self.BtnPlaertView = csbParent:getChildByName("Palter_Image");
    btn = self.BtnPlaertView:getChildByName("Button_11");
	btn:setTag(TAG_ENUM.BT_HELP);
	btn:addTouchEventListener(btnEvent);
    --离开
    btn = self.BtnPlaertView:getChildByName("Button_11_0");
	btn:setTag(TAG_ENUM.BT_EXIT);
	btn:addTouchEventListener(btnEvent);

    --上庄列表
	btn = csbParent:getChildByName("Banker_Layer"):getChildByName("apply_btn");
	btn:setTag(TAG_ENUM.BT_APPLYLIST);
	btn:addTouchEventListener(btnEvent);	
	self.m_btnApply = btn;


end
--刷新庄家信息
function GameViewLayer:onChangeBanker( wBankerUser, lBankerScore, bEnableSysBanker )
	print("更新庄家数据:" .. wBankerUser .. "; coin =>" .. lBankerScore)

	--上一个庄家是自己，且当前庄家不是自己，标记自己的状态
	if self.m_wBankerUser ~= wBankerUser and self:isMeChair(self.m_wBankerUser) then
		self.m_enApplyState = APPLY_STATE.kCancelState
	end
	self.m_wBankerUser = wBankerUser
	--获取庄家数据
	self.m_bNoBanker = false

	local nickstr = "";
	--庄家姓名
	if true == bEnableSysBanker then --允许系统坐庄
		if yl.INVALID_CHAIR == wBankerUser then
            nickstr = "系统坐庄"
            --如果异常出现0 手动改
            if lBankerScore == 0 then
                print("系统金币异常")
                lBankerScore = 10000000
            end
		else
			local userItem = self:getDataMgr():getChairUserList()[wBankerUser + 1];
			if nil ~= userItem then
				nickstr = userItem.szNickName 

				if self:isMeChair(wBankerUser) then
					self.m_enApplyState = APPLY_STATE.kApplyedState
				end
			else
				print("获取用户数据失败")
			end
		end	
	else
		if yl.INVALID_CHAIR == wBankerUser then
			nickstr = "无人坐庄"
			self.m_bNoBanker = true
		else
			local userItem = self:getDataMgr():getChairUserList()[wBankerUser + 1];
			if nil ~= userItem then
				nickstr = userItem.szNickName 

				if self:isMeChair(wBankerUser) then
					self.m_enApplyState = APPLY_STATE.kApplyedState
				end
			else
				print("获取用户数据失败")
			end
		end
	end

     self:SubNickName(self.m_clipBankerNick,nickstr)
     self.m_BankerScore:setVisible(true)

     if  yl.INVALID_CHAIR ~= wBankerUser then
           --绘制头像
        self.m_BankerFace:setVisible(true)
  
             --庄家头像
        local userItem = self:getDataMgr():getChairUserList()[wBankerUser + 1];
        local Bankerhead =HeadSprite:createNormal(userItem, 70)
	    Bankerhead:setPosition(self.m_BankerFace:getPosition())
        self.m_BankerVip:setVisible(true)
        Bankerhead:setTag(333)
        if self.GameNods:getChildByTag(333) ~= nil then
         self.GameNods:removeChildByTag(333)
        end
          self.m_SystemBanker:setVisible(false)
          self.GameNods:getChildByName("Banker_Layer"):addChild(Bankerhead)
        else
            --系统坐庄就默认哈
        self.m_BankerVip:setVisible(true)
        self.m_BankerFace:setVisible(true)
         self.m_SystemBanker:setVisible(true)
        if self.GameNods:getChildByTag(333) ~= nil then
         self.GameNods:removeChildByTag(333)
         end
     end

  

	--庄家金币
	--local str = string.formatNumberThousands(lBankerScore);
	--if string.len(str) > 11 then
	--	str = string.sub(str, 1, 7) .. "...";
	--end
	local str = ExternalFun.numberThousands(lBankerScore)
   local strRef = string.gsub(str, ",", ":")
	--[[if string.len(str) > 11 then
		str = string.sub(str,1,11) .. "...";
	end]]
	self.m_textBankerCoin:setString(strRef);

--	--如果是超级抢庄用户上庄
--	if wBankerUser == self.m_wCurrentRobApply then
--		self.m_wCurrentRobApply = yl.INVALID_CHAIR
--		self:refreshCondition()
--	end

--	--坐下用户庄家
--	local chair = -1
--	for i = 1, g_var(cmd).MAX_OCCUPY_SEAT_COUNT do
--		if nil ~= self.m_tabSitDownUser[i] then
--			chair = self.m_tabSitDownUser[i]:getChair()
--			self.m_tabSitDownUser[i]:updateBanker(chair == wBankerUser)
--		end
--	end
end


--初始化庄家信息
function GameViewLayer:initBankerInfo( ... )

    --系统坐庄头像
   self.m_SystemBanker=self.GameNods:getChildByName("Banker_Layer"):getChildByName("player_head_Noter")
	--庄家姓名
	self.m_clipBankerNick=self.GameNods:getChildByName("Banker_Layer"):getChildByName("BankerText")
	--self.m_clipBankerNick = g_var(ClipText):createClipText(tmp:getContentSize(), "");
--	self.m_clipBankerNick:setAnchorPoint(tmp:getAnchorPoint());
--	self.m_clipBankerNick:setPosition(tmp:getPosition());
--	self.GameNods:addChild(self.m_clipBankerNick);

--	--庄家金币
     
     self.m_textBankerCoin =  ccui.TextAtlas:create("0", "game/jiangchi.png", 24, 35, "0")
     self.m_textBankerCoin:setAnchorPoint(cc.p(0.0,0.5))
     self.m_textBankerCoin:setGlobalZOrder(1)
     self.m_textBankerCoin:setPosition(cc.p(130,38))
     self.m_textBankerCoin:setScale(0.45)
     self.GameNods:getChildByName("Banker_Layer"):addChild(self.m_textBankerCoin)
   	 self:reSetBankerInfo();


     --
      self.PoolImage = self.GameNods:getChildByName("Average_Image")
     ----初始化奖金
      self.m_textGoldPool = ccui.TextAtlas:create("0", "game/jiangChi_Num(19x25).png", 19, 25, "0")
      self.m_textGoldPool:setName("GoldPool_text")
      self.m_textGoldPool:setAnchorPoint(cc.p(0.0,0.5))
      self.m_textGoldPool:setPosition(cc.p(83,30))
     -- self.m_textGoldPool:setScale(0.6)
      self.PoolImage:addChild(self.m_textGoldPool)


end

--设置奖金数目
function GameViewLayer:SetGlodPool( Score )
    local str = ExternalFun.numberThousands(Score);
    local strRef = string.gsub(str, ",", ":")
	self.m_textGoldPool:setString(strRef);
end


function GameViewLayer:reSetBankerInfo(  )
	self.m_clipBankerNick:setString("");
	self.m_textBankerCoin:setString("");
    self.m_BankerScore=self.GameNods:getChildByName("Banker_Layer"):getChildByName("Image_1_0")
    --庄家头像
    self.m_BankerFace=self.GameNods:getChildByName("Banker_Layer"):getChildByName("player_head_0")
    --庄家标志
    self.m_BankerVip=self.GameNods:getChildByName("Banker_Layer"):getChildByName("Image_1_0_0")
    self.m_BankerVip:setVisible(false)
    self.m_BankerVip:setLocalZOrder(1100)
    self.m_BankerScore:setVisible(false)
end

--定时器更新
function GameViewLayer:OnUpdataClockView(chair, time)

  --根据不同的状态来给倒计时妈的B 给老子乱跑来跑去的    

 
    local lCurTimer = time
     if time<10 then
         lCurTimer = "0"..lCurTimer;
     end
     self.m_GameTimer:setString(lCurTimer)

     --根据下注状态设置大的倒计时

   print("当前状态="..self.m_cbGameStatus.."时间是="..time)
    if  self.m_cbGameStatus == 1 or self.m_cbGameStatus == 100 	then

       self.m_bPlayGoldFlyIn = self.m_bPlayGoldFlyIn+1
--        if time == 3 then
--            self:TimeShowAct(3)
--        end
--        if time == 0 then
--            ExternalFun.playSoundEffect("tingzhiBet.wav")
--          end
    end



end


function GameViewLayer:showTimerTip(tag,time)

    --根据不同的类型显示 庄家图片

     local lCurTimer = time
     if time<10 then
         lCurTimer = "0"..lCurTimer;
     end
   

	if  tag == 1	then                        --空闲状态
          self.m_Game_StuatusImage:setTexture("game/txt_time_free.png")
          self.m_Game_StuatusImage:setVisible(true)
          self.m_GameTimer:setString(lCurTimer)
          self.m_GameTimer:setVisible(true)
     end

	if   tag == 2	then                        --下注状态
          self.m_Game_StuatusImage:setTexture("game/txt_time_jetton.png")
          self.m_Game_StuatusImage:setVisible(true)
          self.m_GameTimer:setString(lCurTimer)
          self.m_GameTimer:setVisible(true)
    end

	if  tag == 3	then         
          self.m_Game_StuatusImage:setTexture("game/time_text2.png")
          self.m_Game_StuatusImage:setVisible(true)
          self.m_GameTimer:setString(lCurTimer)
          self.m_GameTimer:setVisible(true)
    end


 
end

--重设下注区域
function GameViewLayer:reSetForNewGame(  )
	
     self.m_tableJettonLong = 0;
     self.m_tableJettonHu = 0;
     self.m_tableJettonHe = 0;
      --总下注
    self.m_AllJettonHe[1] = 0
    self.m_AllJettonHe[2] = 0
    self.m_AllJettonHe[3] = 0
     --筹码数据
     self:cleanJettonArea()
     --发牌动画数据清理
     self:ReleCardAll()

     for i=1,3 do
		local tag = i;
         local str = string.format("MeJett_Image_%d", tag);
	     local strMeBetScore =  self.GameNods:getChildByName(str)
         if strMeBetScore ~= nil then
            local text_MyJecct = strMeBetScore:getChildByName("MtJect_text")
            text_MyJecct:setString("0")
            text_MyJecct:setVisible(false)
            strMeBetScore:setVisible(false)
         end

	end

      for i=1,3 do
		local tag = i ;
	     local strAllBetScore =  self.GameNods:getChildByName("AllBeg_"..tag)
         if strAllBetScore ~= nil then
            strAllBetScore:setString("0")
            strAllBetScore:setVisible(false)
         end

	end

    --闪动动画
     for i=1,3 do
        self.m_TwinkleAnime[i]:setVisible(false)
        self.m_TwinkleAnime[i]:stopAllActions()
     end

     --游戏结束
     self.GameOverWinImage:setVisible(false)
     self.GameOverWinImage:getChildByName("bonus_Image"):setVisible(false)
     self.GameOverWinImage:stopAllActions()
     self.GameOverWinImage:setScale(0)

     self.GameOverLostImage:setVisible(false)
     self.GameOverLostImage:getChildByName("bonus_Image"):setVisible(false)
     self.GameOverLostImage:stopAllActions()
     self.GameOverLostImage:setScale(0)

    -- self.PoolLoginImage:setVisible(false)
     for i = 1, 3 do
      local lContorl = self.GameOverWinImage:getChildByTag(i)
      if lContorl ~= nil then
        lContorl:setString("0")
        lContorl:setVisible(false)
      end
    end

     for i = 1, 3 do
      local lContorl = self.GameOverLostImage:getChildByTag(i)
      if lContorl ~= nil then
        lContorl:setString("0")
        lContorl:setVisible(false)
      end
    end


     self.m_AllPersonote[1]  = 0
     self.m_AllPersonote[2]  = 0
     self.m_AllPersonote[3]  = 0
     --筹码区域
     self.m_LongAddScore:setString("0")
     --hu
     self.m_HuAddScore:setString("0")
     self.m_HeAddScore:setString("0")
     self.m_TextContorlStatus:setString("状态无")
     self:getParentNode():UserInfos()

     self.m_CaedContorlAnime = 0;
end


--清理发牌动画数据
function GameViewLayer:ReleCardAll()

    --发牌动画    
    self.m_CardLongImage:setPosition(cc.p(676.13,498.59))
    self.m_CardHuImage:setPosition(cc.p(676.13,498.59))
    self.m_CardLongImage:setVisible(false)
    self.m_CardHuImage:setVisible(false)
    self.m_CardLongImage:stopAllActions()
    self.m_CardHuImage:stopAllActions()
    self.m_DeskLong:setVisible(false);
    self.m_DeskHu:setVisible(false)

   self.m_DeskLong:getChildByName("Sprite_7"):setVisible(true)
   self.m_DeskHu:getChildByName("Sprite_7"):setVisible(true)

end
function GameViewLayer:cleanJettonArea(  )
	--移除界面已下注

     for i=1,3 do
		local tag = i - 1;
		local str = string.format("Btn_%d", tag);
		local tag_btn = self.GameNods:getChildByName(str);
	    tag_btn:removeAllChildren()
    end
end


--游戏开始
function GameViewLayer:onGameStart( )
	--self.m_nJettonSelect = self.m_pJettonNumber[DEFAULT_BET].k;

    if self.m_nJettonSelect == -1 then
      self.m_nJettonSelect = self.m_pJettonNumber[DEFAULT_BET].k;
    end
	self.m_lHaveJetton = 0;

	--获取玩家携带游戏币	
	self:reSetUserInfo();

	self.m_bOnGameRes = false

	--不是自己庄家,且有庄家
	if false == self:isMeChair(self.m_wBankerUser) and false == self.m_bNoBanker then
		--下注
		self:ShowBankerBtn(true);
		--调整下注按钮
		self:adjustJettonBtn();
	end	

	--math.randomseed(tostring(os.time()):reverse():sub(1, 6))

	--申请按钮状态更新
	--self:refreshApplyBtnState()	
end


--网络消息

------
--网络接收
function GameViewLayer:onGetUserScore( item )
	--自己
    if item.dwUserID == GlobalUserItem.dwUserID then
        self:runAction(cc.Sequence:create(cc.DelayTime:create(15.0),cc.CallFunc:create(function (  )
            self:reSetUserInfo()
        end)))
    end

--    --坐下用户
--    for i = 1, g_var(cmd).MAX_OCCUPY_SEAT_COUNT do
--    	if nil ~= self.m_tabSitDownUser[i] then
--    		if item.wChairID == self.m_tabSitDownUser[i]:getChair() then
--    			self.m_tabSitDownUser[i]:updateScore(item)
--    		end
--    	end
--    end

    --庄家
    if self.m_wBankerUser == item.wChairID  then
    	--庄家金币
		--local str = string.formatNumberThousands(item.lScore);
		--if string.len(str) > 11 then
		--	str = string.sub(str, 1, 9) .. "...";
		--end
		local str = ExternalFun.numberThousands(item.lScore)
        local strRef = string.gsub(str, ",", ":")

        --self.m_textBankerCoin:setString(strRef);

        self.bankScore = strRef
       
    end

--    --系统坐庄也要扣钱
--    if self.m_wBankerUser ==  yl.INVALID_CHAIR then

--        local myscore = self.m_textUserCoint:getString()
--		myscore = string.gsub(myscore,":","")
--		myscore = tonumber(myscore)
--		myscore = myscore - my
--		local str = ExternalFun.numberThousands(myscore);
--        local strRef = string.gsub(str, ",", ":")
--	    self.m_textUserCoint:setString(strRef);
--    end
end

--获取能否上庄
function GameViewLayer:getApplyable(  )
	--自己超级抢庄已申请，则不可进行普通申请
	if APPLY_STATE.kSupperApplyed == self.m_enApplyState then
		return false
	end

	local userItem = self:getMeUserItem();
	if nil ~= userItem then
		return userItem.lScore > self.m_llCondition
	else
		return false
	end
end

--获取能否取消上庄
function GameViewLayer:getCancelable(  )
	return self.m_cbGameStatus == g_var(cmd).GAME_SCENE_FREE
end

--取消申请庄家
function GameViewLayer:onGetCancelBanker(  )
	if self:isMeChair(self:getParentNode().cmd_cancelbanker.wCancelUser) then
		self.m_enApplyState = APPLY_STATE.kCancelState
	end
	
	self:refreshApplyList()
end

--申请庄家
function GameViewLayer:onGetApplyBanker( )
	if self:isMeChair(self:getParentNode().cmd_applybanker.wApplyUser) then
		self.m_enApplyState = APPLY_STATE.kApplyState
	end

	self:refreshApplyList()
end

--刷新列表
function GameViewLayer:refreshApplyList(  )
	if nil ~= self.m_applyListLayer and self.m_applyListLayer:isVisible() then
		local userList = self:getDataMgr():getApplyBankerUserList()		
		self.m_applyListLayer:refreshList(userList)
	end
end

--上庄状态
function GameViewLayer:applyBanker( state )
	if state == APPLY_STATE.kCancelState then
		self:getParentNode():sendApplyBanker()		
	elseif state == APPLY_STATE.kApplyState then
		self:getParentNode():sendCancelApply()
	elseif state == APPLY_STATE.kApplyedState then
		self:getParentNode():sendCancelApply()		
	end
end



--调整下注按钮
function GameViewLayer:adjustJettonBtn(  )
	--可以下注的数额
	local lCanJetton = self.m_llMaxJetton - self.m_lHaveJetton;
	local lCondition = math.min(self.m_scoreUser, lCanJetton);

	for i=1,#self.m_tableJettonBtn do
		local enable = false
		if self.m_bOnGameRes then
			enable = false
		else
			enable = self.m_bOnGameRes or (lCondition >= self.m_pJettonNumber[i].k)
		end
		self.m_tableJettonBtn[i]:setEnabled(enable);
	end

	if self.m_nJettonSelect > self.m_scoreUser then
		self.m_nJettonSelect = -1;
	end

   
    --调整按钮状态
    if self.m_nJettonSelect  == - 1 then
      self:SelectObjectBtn(nil)
     else
      local BtnIndex = self:isJeectScore(self.m_nJettonSelect)
      if BtnIndex ~= nil then
           local BtnBject = self.m_tableJettonBtn[BtnIndex]
           if BtnBject ~= nil then
             self:SetBtnStatus(BtnBject)
             self:SelectObjectBtn(BtnBject)
           end
      end

    end
     

--	--筹码动画
--	local enable = lCondition >= self.m_pJettonNumber[self.m_nSelectBet].k;
--	if false == enable then
--		self.m_tabJettonAnimate[self.m_nSelectBet]:stopAllActions()
--		self.m_tabJettonAnimate[self.m_nSelectBet]:setVisible(false)
--	end
end

function GameViewLayer:isJeectScore( Score )

for i=1,#self.m_pJettonNumber do
    if self.m_pJettonNumber[i].k == Score then 
        return self.m_pJettonNumber[i].i-1
    end

 end  

end

function GameViewLayer:isMeChair( wchair )
	local useritem = self:getDataMgr():getChairUserList()[wchair + 1];
	if nil == useritem then
		return false
	else 
		return useritem.dwUserID == GlobalUserItem.dwUserID
	end
end


--游戏free
function GameViewLayer:onGameFree( )
	yl.m_bDynamicJoin = false
	self:reSetForNewGame()
    self:ShowBankerBtn(false)
    --self.m_nJettonSelect = -1
    self.m_bPlayGoldFlyIn = 4
end


function GameViewLayer:refreshUserList(  )
--	if nil ~= self.m_userListLayer and self.m_userListLayer:isVisible() then
--		local userList = self:getDataMgr():getUserList()		
--		self.m_userListLayer:refreshList(userList)
--	end
end

---------------------------------------------------------------------------------------


function GameViewLayer:onExit()

    scheduler:unscheduleScriptEntry(self.m_schedule)
    scheduler:unscheduleScriptEntry(self.m_Plerschedule)

    self._laba:closeTime()

end

function GameViewLayer:schedulerUpdate() 

 local function updateBullet( dt )
    
        self:update(dt)
	end


    local function PearupdateBullet( dt )
        self:Pearupdate(dt)
	end

	--定时器
	if nil == self.m_schedule then
		self.m_schedule = scheduler:scheduleScriptFunc(updateBullet, 0.21, false)
	end

    --定时器
	if nil == self.m_Plerschedule then
		self.m_Plerschedule = scheduler:scheduleScriptFunc(PearupdateBullet, 0.4, false)
	end
end

function GameViewLayer:Pearupdate(dt)
  self.m_bPlaerSounder = false
end


function GameViewLayer:update( dt )
	
    if  self.m_cbGameStatus == 1 or self.m_cbGameStatus == 100 	then
    if self.m_bPlaerSounder == true then
      ExternalFun.playSoundEffect("bet.mp3") 
    end  
   end
end

--界面初始化
function GameViewLayer:initCsbRes(  )

   self:schedulerUpdate()


	local rootLayer, csbNode = ExternalFun.loadRootCSB("game/GameLayer.csb", self);
    self.m_rootLayer = rootLayer
    --底部按钮
    self.GameNods = csbNode
	local bottom_sp = csbNode:getChildByName("bottom_sp");
	self.m_spBottom = bottom_sp;
    self.AllChip =  self.m_spBottom:getChildByName("clip_layout")

	local clip_layout = self.AllChip
	--游戏记录
	local game_record = csbNode:getChildByName("Image_4")
	-- game_record:setLocalZOrder(1000)
	self._gameRecord = GameRecord:create(self,game_record)

	local function clipEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			self:onJettonButtonClicked(sender:getTag(), sender);
		end
	end

    
   self._laba =  GameNotice:create("",cc.p(667,630))
   self._laba:addTo(self.m_rootLayer)


	self.m_pJettonNumber = 
	{
		{k = 1000, i =2},
		{k = 10000, i = 3}, 
		{k = 100000, i = 4}, 
		{k = 1000000, i = 5}, 
		{k = 5000000, i = 6},
		{k = 10000000, i = 7} 
	}

	self.m_tabJettonAnimate = {}
	for i=1,#self.m_pJettonNumber do
		local tag = i-1 
		local str = string.format("chip%d_btn", tag)
		local btn = clip_layout:getChildByName(str)
		btn:setTag(i)
		btn:addTouchEventListener(clipEvent)
		self.m_tableJettonBtn[i] = btn
        self.m_tableJettonBtn[i]:setEnabled(false)
	end  
    
    --初始化状态信息
      self.m_Game_StuatusImage = self.GameNods:getChildByName("Game_StatusImage")
      self.m_GameTimer= ccui.TextAtlas:create("", "game/daojishi.png", 25, 37, "0")
      self.m_GameTimer:setName("Timer_text")
      self.m_GameTimer:setAnchorPoint(cc.p(0.0,0.5))
      self.m_GameTimer:setPosition(cc.p(702,492))
      --self.m_GameTimer:setScale(0.6)
      self.GameNods:addChild(self.m_GameTimer)

        --倒计时
       self.m_CountDown = self.GameNods:getChildByName("Image_CountDown")
     --  self:TimeShowAct(3)
     

       --发牌动画
       self.m_CardLongImage= self.GameNods:getChildByName("Image_PukeLong")
       self.m_CardHuImage= self.GameNods:getChildByName("Image_PukeHu")
       self.m_CardLongImage:setLocalZOrder(1000)
       self.m_CardHuImage:setLocalZOrder(1000)

       self.m_DeskLong= self.GameNods:getChildByName("Image_DeskCardLong")
       self.m_DeskHu= self.GameNods:getChildByName("Image_DeskCardHu")

       --个人下注信息
     for i=1,3 do
	    local tag = i
	    local str = string.format("MeJett_Image_%d", tag);
	    local MeBject_Image = csbNode:getChildByName(str);
     --  game_record:getContentSize().width * game_record:getAnchorPoint().x
        local MeJeccteText= ccui.TextAtlas:create("0", "game/myzhu.png", 13, 19, "0")
        MeJeccteText:setName("MtJect_text")
        MeJeccteText:setAnchorPoint(cc.p(0.5,0.5))
        MeJeccteText:setPosition(cc.p(74,17))
        MeJeccteText:setVisible(false)
      --self.m_GameTimer:setScale(0.6)
        MeBject_Image:addChild(MeJeccteText)
	   
	end
 
	--初始化庄家信息
	  self:initBankerInfo();
    --初始化玩家信息
	  self:initUserInfo(); 

      --管理控制
      self:initContorl()


    --下注区域
	self:initJettonArea(self.GameNods);   

   	--按钮列表
	local function btnEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			self:onButtonClickedEvent(sender:getTag(), sender);
		end
	end	


    self:InitGameBtns(csbNode)

--   --离开
--	btn = csbNode:getChildByName("back_btn");
--	btn:setTag(TAG_ENUM.BT_EXIT);
--	btn:addTouchEventListener(btnEvent);

	local _TrendAnime = cc.Animation:create()
	for i = 1,10 do  
		local frameName =string.format("Strace_%d.png",i)
		local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrameByName(frameName)
		_TrendAnime:addSpriteFrame(spriteFrame)
	end  
	_TrendAnime:setDelayPerUnit(0.05)			--设置两个帧播放时间    
	_TrendAnime:setLoops(5)                
	_TrendAnime:setRestoreOriginalFrame(true)	--动画执行后还原初始状态
	cc.AnimationCache:getInstance():addAnimation(_TrendAnime, "_TrendAnime")


    --路单精灵
    self.SingleImage = self.GameNods:getChildByName("Image_baffle")

    self:registerTouch()
end



function GameViewLayer:getApplyState(  )
	return self.m_enApplyState
end

--下注条件
function GameViewLayer:onGetApplyBankerCondition( llCon)
	self.m_llCondition = llCon
end

--选择状态
function GameViewLayer:SetBtnStatus(BtnDes)
  local lBtnTag = BtnDes:getTag()
  local lScore = self.m_pJettonNumber[lBtnTag].k;
  BtnDes:loadTextureNormal("game/bet/BetBtn/bet_"..lScore.."_1.png")
end
--恢复所有状态
function GameViewLayer:SelectObjectBtn(BtnDes)

  if BtnDes == nil then
    for i = 1,#self.m_tableJettonBtn do

        local lBtnTag = self.m_tableJettonBtn[i]:getTag()
        local lScore = self.m_pJettonNumber[lBtnTag].k;
        self.m_tableJettonBtn[i]:loadTextureNormal("game/bet/BetBtn/bet_"..lScore.."_0.png")
     end 
    else
  for i = 1,#self.m_tableJettonBtn do
      if self.m_tableJettonBtn[i]:getTag() ~= BtnDes:getTag() then 
                local lBtnTag = self.m_tableJettonBtn[i]:getTag()
                local lScore = self.m_pJettonNumber[lBtnTag].k;
                self.m_tableJettonBtn[i]:loadTextureNormal("game/bet/BetBtn/bet_"..lScore.."_0.png")
             end
        end 
  end
  
end

--先是帮助
function GameViewLayer:ShowHelp()

    self.m_ImageHelp:setScale(0)
    self.m_ImageHelp:setVisible(true)
	local Paren = cc.ScaleTo:create(0.25, 1.0)
	local call = cc.CallFunc:create(function( )
	end)
	local actHideAct = cc.Sequence:create(Paren, call)
	self.m_ImageHelp:runAction(actHideAct)
end
--显示按钮狂
function GameViewLayer:ShowBtnPlaert()

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

function GameViewLayer:registerTouch()

local function onTouchBegan( touch, event )
		return self:isVisible()
	end
	local function onTouchEnded( touch, event )
		local pos = touch:getLocation();
        -- 关闭帮助按钮
        if self.m_ImageHelp:isVisible() then
	        local Paren = cc.ScaleTo:create(0.25, 0.0)
	        local call = cc.CallFunc:create(function( )
            self.m_ImageHelp:setVisible(false)
	        end)
	        local actHideAct = cc.Sequence:create(Paren, call)
	        self.m_ImageHelp:runAction(actHideAct)
        end
        --弹出按钮
        if self.BtnPlaertView:isVisible() then
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
function GameViewLayer:onButtonClickedEvent(tag,ref)
	ExternalFun.playClickEffect()
    if tag == TAG_ENUM.BT_RELATION then
    -- 打开面板什么的
        self:ShowBtnPlaert()
    elseif tag == TAG_ENUM.BT_HELP then
		 self:ShowHelp()
         --关闭暗流列表
        if self.BtnPlaertView:isVisible() then
           local Paren = cc.ScaleTo:create(0.25, 1.0, 0.0)
	       local call = cc.CallFunc:create(function( )
	        end)
	       local actHideAct = cc.Sequence:create(Paren, call)
	       self.BtnPlaertView:runAction(actHideAct)
           self.bShowParent = false
        end
    elseif tag == TAG_ENUM.BT_EXIT then

        if  self.m_cbGameStatus  == 1  or self.m_cbGameStatus== 100   then
            if self:isMeChair(self.m_wBankerUser) == true then
                showToast(self,"上庄期间不允许离开游戏，耐心等待吧~",2)
                return
            end
        end
		self._scene:onExitTable()
              --关闭暗流列表
        if self.BtnPlaertView:isVisible() then
           local Paren = cc.ScaleTo:create(0.25, 1.0, 0.0)
	       local call = cc.CallFunc:create(function( )
	        end)
	       local actHideAct = cc.Sequence:create(Paren, call)
	       self.BtnPlaertView:runAction(actHideAct)
           self.bShowParent = false
        end
	elseif tag == TAG_ENUM.BT_START then
		self:getParentNode():onStartGame()
	elseif tag == TAG_ENUM.BT_USERLIST then
		if nil == self.m_userListLayer then
			self.m_userListLayer = g_var(UserListLayer):create()
			self:addToRootLayer(self.m_userListLayer, TAG_ZORDER.USERLIST_ZORDER)
		end
		local userList = self:getDataMgr():getUserList()		
		self.m_userListLayer:refreshList(userList)
	elseif tag == TAG_ENUM.BT_APPLYLIST then
		if nil == self.m_applyListLayer then
			self.m_applyListLayer = g_var(ApplyListLayer):create(self)
			self:addToRootLayer(self.m_applyListLayer, TAG_ZORDER.USERLIST_ZORDER)
		end
		local userList = self:getDataMgr():getApplyBankerUserList()		
		self.m_applyListLayer:refreshList(userList)	
	elseif tag == TAG_ENUM.BT_BANK then
		--银行未开通
		if 0 == GlobalUserItem.cbInsureEnabled then
			showToast(self,"初次使用，请先开通银行！",1)
			return
		end

		if nil == self.m_cbGameStatus or g_var(cmd).GAME_PLAY == self.m_cbGameStatus then
			showToast(self,"游戏过程中不能进行银行操作",1)
			return
		end

		--房间规则
		local rule = self:getParentNode()._roomRule
		if rule == yl.GAME_GENRE_SCORE 
		or rule == yl.GAME_GENRE_EDUCATE then 
			print("练习 or 积分房")
		end
		if false == self:getParentNode():getFrame():OnGameAllowBankTake() then
			--showToast(self,"不允许银行取款操作操作",1)
			--return
		end

		if nil == self.m_bankLayer then
			self:createBankLayer()
		end
		self.m_bankLayer:setVisible(true)
		self:refreshScore()
	elseif tag == TAG_ENUM.BT_SET then
		local setting = g_var(SettingLayer):create()
		self:addToRootLayer(setting, TAG_ZORDER.SETTING_ZORDER)
	elseif tag == TAG_ENUM.BT_LUDAN then
		if nil == self.m_wallBill then
			self.m_wallBill = g_var(WallBillLayer):create(self)
			self:addToRootLayer(self.m_wallBill, TAG_ZORDER.WALLBILL_ZORDER)
		end
		self.m_wallBill:refreshWallBillList()
	elseif tag == TAG_ENUM.BT_ROBBANKER then
		--超级抢庄
		if g_var(cmd).SUPERBANKER_CONSUMETYPE == self.m_tabSupperRobConfig.superbankerType then
			local str = "超级抢庄将花费 " .. self.m_tabSupperRobConfig.lSuperBankerConsume .. ",确定抢庄?"
			local query = QueryDialog:create(str, function(ok)
		        if ok == true then
		            self:getParentNode():sendRobBanker()
		        end
		    end):setCanTouchOutside(false)
		        :addTo(self) 
		else
			self:getParentNode():sendRobBanker()
		end
	elseif tag == TAG_ENUM.BT_CLOSEBANK then
		if nil ~= self.m_bankLayer then
			self.m_bankLayer:setVisible(false)
		end
	elseif tag == TAG_ENUM.BT_TAKESCORE then
		self:onTakeScore()
	else
		showToast(self,"功能尚未开放！",1)
	end
end




function GameViewLayer:getApplyCondition(  )
	return self.m_llCondition
end

function GameViewLayer:addToRootLayer( node , zorder)
	if nil == node then
		return
	end
	self.m_rootLayer:addChild(node)
	node:setLocalZOrder(zorder)
end

--发送扑克
function GameViewLayer:SendCardAnime( )

    self.m_CardLongImage:setScale(0)
    self.m_CardHuImage:setScale(0)
    self.m_CardLongImage:setVisible(true)
    self.m_CardHuImage:setVisible(true)

    self.m_CardLongImage:runAction(cc.Sequence:create(cc.DelayTime:create(0.01),cc.CallFunc:create(function ()
            --龙
	local CardLongScale = cc.ScaleTo:create(1.0, 2.0, 2.0)
    local CardLongMove = cc.MoveTo:create(1.0, cc.p(329,398))
    local spaLong = cc.Spawn:create(CardLongScale, CardLongMove)

	local callLong = cc.CallFunc:create(function( )
		self:FlipCard(self.m_CardLongImage,1)
	end)

    local delay = cc.DelayTime:create(1)
	local seqLonguence = cc.Sequence:create(spaLong,callLong);

	self.m_CardLongImage:runAction(seqLonguence)
    ExternalFun.playSoundEffect("sendcard.wav")
                   
 end)))
       
end

--时间回调
function GameViewLayer:NextTimer(Time)

    if  Time == 1 then
        self.m_CountDown:setVisible(false)
        self.m_CountDown:stopAllActions()
        self.m_CountDown:setScale(0)
        else
        self:TimeShowAct(Time - 1)
   end

end

--翻转扑克
function GameViewLayer:FlipCard(Card,TagType)

 local CardSetting = self.m_DeskLong
    if TagType == 2 then
        CardSetting = self.m_DeskHu
    end
    if TagType == 1 then 
  
	  -- 小虎子
	local CardHuScale = cc.ScaleTo:create(1.0, 2.0, 2.0)
	local CardHuMove = cc.MoveTo:create(0.8, cc.p(991.99,398))
	local spaHu= cc.Spawn:create(CardHuScale, CardHuMove)

	local callHu = cc.CallFunc:create(function( )
        --2 张扑克发送完毕后就戳牌
		self:ShowDeskCard(TagType)
	end)

	local seqHuence = cc.Sequence:create(spaHu,callHu);

	self.m_CardHuImage:runAction(seqHuence)
    ExternalFun.playSoundEffect("sendcard.wav")
                   
  end


--    if self.m_CaedContorlAnime == TagType-1 then 

--	 self:ShowDeskCard(TagType)

--    end

end


--呵呵哈伊
function GameViewLayer:ShowDeskCard(TagType)
      -- = self.GameNods:getChildByName("Image_DeskCardLong")
      -- self.m_DeskHu= self.GameNods:getChildByName("Image_DeskCardHu")
    local cmd_gameend =self:getDataMgr().m_tabGameEndCmd
    --显示扑克
     
     local CardData = cmd_gameend.cbTableCardArray[1][TagType]
     local CardValue  = GameLogic.GetCardValue(CardData)
     local CardMask  = GameLogic.GetCardColor(CardData)
    -- self.m_DeskCardImage:setVisible(true)
    local CardSetting = self.m_DeskLong
    if TagType == 2 then
        CardSetting = self.m_DeskHu
    end
     CardSetting:setVisible(true)
	local ptrImage = nil 
	local CardTypeImage =CardSetting:getChildByName("Sprite_7")
	if CardMask == 0 then
        ptrImage = "hong_"
	end
	if CardMask == 16 then
		ptrImage = "mei_"
	end
	if CardMask == 32 then
		ptrImage = "fang_"
	end
	if CardMask == 48 then
		ptrImage = "hei_"
	end


    ptrImage =ptrImage..CardValue..".png"
	--设置数据哈
    local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrameByName(ptrImage)
    CardSetting:setSpriteFrame(spriteFrame)

	--还有其他事要做哦 就是显示闪动动画哈
	local SortLongValue   = GameLogic.GetCardValue( cmd_gameend.cbTableCardArray[1][1])
	local SortHuValue   = GameLogic.GetCardValue(cmd_gameend.cbTableCardArray[1][2])
	local icontype = nil
                
	if SortLongValue > SortHuValue then
		icontype = g_var(cmd).AREA_LOONG
	end
	if SortLongValue < SortHuValue then
		icontype = g_var(cmd).AREA_TIGER
	end
	if SortLongValue  == SortHuValue then
		icontype = g_var(cmd).AREA_EQUAL
	end


    --先来个动画戳牌
    local DeskPosk = self.m_CardLongImage
    if TagType == 2 then
      DeskPosk =self.m_CardHuImage
    end

    

    local X = DeskPosk:getPositionX()
    local Y  =DeskPosk:getPositionY()
    X=X+50

    local CardLongMove = cc.MoveTo:create(0.75,cc.p(X,Y))
    local spaLong = cc.Spawn:create(CardLongMove)

	local callLong = cc.CallFunc:create(function( )
		CardTypeImage:setVisible(true)
        self:NextMove(DeskPosk,TagType,icontype)
        --继续移动
	end)

	local seqLonguence = cc.Sequence:create(spaLong,callLong);

	DeskPosk:runAction(seqLonguence)

end


--播放特效
function GameViewLayer:AnimeEffects(AnimeType)

    
    if AnimeType == 1 then
    local sprite = cc.Sprite:createWithSpriteFrameName("ximage001.png")  
    sprite:setScale(1.65)
    sprite:setPosition(cc.p(self.GameNods:getContentSize().width / 2,self.GameNods:getContentSize().height / 2))  
    sprite:setName("longzi")
    self.GameNods:addChild(sprite)
   local animate = cc.Animation:create()  
    for i = 1, 19 do
      local frameName = "ximage00"..i..".png"  
      animate:addSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName))  
    end  
    animate:setDelayPerUnit(0.12) --时间间隔  
    animate:setRestoreOriginalFrame(false) --是否播放完后回到第一针  
    animate:setLoops(1)  --循环册书  
    local action = cc.Animate:create(animate)  
        sprite:runAction(cc.Sequence:create(action, cc.CallFunc:create(function()
        sprite:setVisible(false)
        self.GameNods:removeChildByName("longzi")
        
    end))) 

    ExternalFun.playSoundEffect("long.mp3")


   elseif AnimeType == 2 then
     
    local sprite = cc.Sprite:createWithSpriteFrameName("ximage001.png")  
    sprite:setScale(1.65)
    sprite:setPosition(cc.p(self.GameNods:getContentSize().width / 2,self.GameNods:getContentSize().height / 2))  
    sprite:setName("huzi")
    self.GameNods:addChild(sprite)
   local animate = cc.Animation:create()  
    for i = 1, 19 do
      local frameName = "hu_"..i..".png"  
      animate:addSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName))  
    end  
    animate:setDelayPerUnit(0.12) --时间间隔  
    animate:setRestoreOriginalFrame(false) --是否播放完后回到第一针  
    animate:setLoops(1)  --循环册书  
    local action = cc.Animate:create(animate)  
        sprite:runAction(cc.Sequence:create(action, cc.CallFunc:create(function()
        sprite:setVisible(false)
       self.GameNods:removeChildByName("huzi")
        
    end)))  
     ExternalFun.playSoundEffect("hu.mp3")
   end
   self:AnimeMove(AnimeType)
end


--移动走开动画
function GameViewLayer:CardEndMove(ImageCard , TagType, icontype)


    local curDeskPock = self.m_DeskLong
    if TagType == 2 then
     curDeskPock = self.m_DeskHu
    end


    curDeskPock:getChildByName("Sprite_7"):setVisible(false)

    local X = ImageCard:getPositionX()
    local Y  =ImageCard:getPositionY()
    X=X+95
    local CardLongMove = cc.MoveTo:create(0.7,cc.p(X,Y))
    local spaLong = cc.Spawn:create(CardLongMove)

	local callLong = cc.CallFunc:create(function( )

    ImageCard:setVisible(false)
    if  TagType == 2 then

    self:AnimeEffects(icontype+1 )
    --光圈给我嗨起来
    local cmd_gameend =self:getDataMgr().m_tabGameEndCmd
    local SortLongValue   = GameLogic.GetCardValue( cmd_gameend.cbTableCardArray[1][1])
	local SortHuValue   = GameLogic.GetCardValue(cmd_gameend.cbTableCardArray[1][2])
	local icontype = nil

	if SortLongValue > SortHuValue then
		local rep = cc.RepeatForever:create(cc.Blink:create(0.65,1))
		self.m_TwinkleAnime[1]:stopAllActions()
		self.m_TwinkleAnime[1]:runAction(rep)
		icontype = g_var(cmd).AREA_LOONG
	end

	if SortLongValue < SortHuValue then
		local rep = cc.RepeatForever:create(cc.Blink:create(0.65,1))
		self.m_TwinkleAnime[2]:stopAllActions()
		self.m_TwinkleAnime[2]:runAction(rep)
		icontype = g_var(cmd).AREA_TIGER
	end
	if SortLongValue  == SortHuValue then
		local rep = cc.RepeatForever:create(cc.Blink:create(0.65,1))
		self.m_TwinkleAnime[3]:stopAllActions()
		self.m_TwinkleAnime[3]:runAction(rep)
		icontype = g_var(cmd).AREA_EQUAL
	end
    else
        self:ShowDeskCard(2)
    end

   
end)

	local seqLonguence = cc.Sequence:create(spaLong,callLong);

	ImageCard:runAction(seqLonguence)
end

--继续移动
function GameViewLayer:NextMove(ImageCard , TagType, icontype)

    local X = ImageCard:getPositionX()
    local Y  =ImageCard:getPositionY()
    X=X-50
    local CardLongMove = cc.MoveTo:create(0.6,cc.p(X,Y))
    local spaLong = cc.Spawn:create(CardLongMove)

	local callLong = cc.CallFunc:create(function( )

    --回到最初的梦想了
    self:CardEndMove(ImageCard , TagType, icontype)
   
end)

	local seqLonguence = cc.Sequence:create(spaLong,callLong);

	ImageCard:runAction(seqLonguence)
end

--星星动画
function GameViewLayer:StarsAction(icontype)

    --闪动画面一起吧 
    if icontype == g_var(cmd).AREA_LOONG then
      local rep = cc.RepeatForever:create(cc.Blink:create(0.65,1))
	  self.m_TwinkleAnime[1]:stopAllActions()
	  self.m_TwinkleAnime[1]:runAction(rep)
    elseif icontype == g_var(cmd).AREA_TIGER then
      local rep = cc.RepeatForever:create(cc.Blink:create(0.65,1))
	  self.m_TwinkleAnime[2]:stopAllActions()
	  self.m_TwinkleAnime[2]:runAction(rep)
    elseif icontype == g_var(cmd).AREA_EQUAL then
      local rep = cc.RepeatForever:create(cc.Blink:create(0.65,1))
	  self.m_TwinkleAnime[3]:stopAllActions()
	  self.m_TwinkleAnime[3]:runAction(rep)

   end

	local x = 306
	local y = 398
	if icontype == g_var(cmd).AREA_TIGER then
		x = 1015
		y = 398
	elseif icontype == g_var(cmd).AREA_EQUAL then
		x = 658
		y = 492
	end
	
	local animation = cc.AnimationCache:getInstance():getAnimation("_TrendAnime")
	local stars = self.GameNods:getChildByName("Single_0")
	--stars:setLocalZOrder(2)
	stars:move(x,y)
	stars:setVisible(true)
	stars:setScale(1)
	--local delay = cc.DelayTime:create(1)
	local currnum = self._gameRecord:getCurrentRecordNumber()
	currnum = currnum + 1
	if currnum > self._gameRecord:getMaxRecordNumber() then
		currnum = self._gameRecord:getMaxRecordNumber()
	end
	local pos = self._gameRecord:getPos(currnum)
	local game_record = self.GameNods:getChildByName("Image_4")
	local posx = game_record:getPositionX() - game_record:getContentSize().width * game_record:getAnchorPoint().x
	local posy = game_record:getPositionY() - game_record:getContentSize().height * game_record:getAnchorPoint().y
	pos.x = pos.x + posx
	pos.y = pos.y + posy
	local action = cc.Animate:create(animation)
	local moveto = cc.MoveTo:create(0.5, cc.p(pos.x,pos.y))
	local scaleto = cc.ScaleTo:create(0.5,0.3)
	local callfunc = cc.CallFunc:create(function( )
		self._gameRecord:AddGameRecord(icontype)
		end)
	local spawn = cc.Spawn:create(action, moveto, --[[scaleto,--]]callfunc)
	stars:runAction(cc.Sequence:create(spawn, cc.CallFunc:create(function( )
		stars:setVisible(false)
       -- self:ShowGameOver(self:getDataMgr().m_tabGameEndCmd.lPlayAllScore,self:getDataMgr().m_tabGameEndCmd.GetPoolScore,true)
		end)))	
	
end
--倒计时动画
function GameViewLayer:TimeShowAct(Time)

        local CurTimeImage = "game/d"..Time..".png"
        self.m_CountDown:setTexture(CurTimeImage)
        --倒计时
        self.m_CountDown:setScale(0)
        self.m_CountDown:setVisible(true)

	    --加载动画
	   self.m_actShowAct = cc.ScaleTo:create(1.0, 3.0)
	   local call = cc.CallFunc:create(function( )
		    self.m_CountDown:setVisible(false)
            self:NextTimer(Time)
	    end)
	   self.m_actHideAct = cc.Sequence:create(self.m_actShowAct, call)
	   self.m_CountDown:runAction(self.m_actHideAct)

       ExternalFun.playSoundEffect("s_countdown3.mp3")

end
--下注区域
function GameViewLayer:initJettonArea( csbNode )

    for i=1,3 do
	    local tag = i - 1;
	    local str = string.format("Twinkle_%d", tag);
	    local Twinkle_Image = csbNode:getChildByName(str);
	    self.m_TwinkleAnime[i] = Twinkle_Image; 
	end

    --按钮列表
    local function btnEvent( sender, eventType )
	    if eventType == ccui.TouchEventType.ended then
		    self:onJettonAreaClicked(sender:getTag(), sender);
	    end
    end	

    for i=1,3 do
	    local tag = i - 1;
	    local str = string.format("Btn_%d", tag);
	    local tag_btn = csbNode:getChildByName(str);
	    tag_btn:setTag(i);
        --别慌兄弟伙自己下注的信息也要显示啥
	    tag_btn:addTouchEventListener(btnEvent);
	    self.m_tableJettonArea[i] = tag_btn; 
    end

--	--下注信息
--	local m_userJettonLayout = csbNode:getChildByName("jetton_control");
--	local infoSize = m_userJettonLayout:getContentSize()
--	local text = ccui.Text:create("本次下注为:", "fonts/round_body.ttf", 20)
--	text:setAnchorPoint(cc.p(1.0,0.5))
--	text:setPosition(cc.p(infoSize.width * 0.495, infoSize.height * 0.19))
--	m_userJettonLayout:addChild(text)
--	m_userJettonLayout:setLocalZOrder(100)
--	m_userJettonLayout:setVisible(false)

--	local m_clipJetton = g_var(ClipText):createClipText(cc.size(120, 23), "")
--	m_clipJetton:setPosition(cc.p(infoSize.width * 0.5, infoSize.height * 0.19))
--	m_clipJetton:setAnchorPoint(cc.p(0,0.5));
--	m_clipJetton:setTextColor(cc.c4b(255,165,0,255))
--	m_userJettonLayout:addChild(m_clipJetton)

--	self.m_userJettonLayout = m_userJettonLayout;
--	self.m_clipJetton = m_clipJetton;

--	self:reSetJettonArea(false);
end


--游戏结束
function GameViewLayer:onGetGameEnd(  )

    ExternalFun.playSoundEffect("tingzhiBet.wav")
	self.m_bOnGameRes = true
	--不可下注
	self:ShowBankerBtn(false)
    --self.m_nJettonSelect = -1
    --发牌动画
    self:SendCardAnime()
end

function GameViewLayer:onJettonAreaClicked( tag, ref )
	local m_nJettonSelect = self.m_nJettonSelect;

    if self.m_cbGameStatus  == 1  or self.m_cbGameStatus== 100 then
    if self.m_nJettonSelect >0 then

          --自己是庄家也不能下注
    if true == self:isMeChair(self.m_wBankerUser) then
      return ;
    end
    
    local area = tag - 1;	
    if self.m_llMaxJetton == 0 then
        print("异常")
        self.m_llMaxJetton = 10000000
    end
	if self.m_lHaveJetton > self.m_llMaxJetton then
		showToast(self,"已超过最大下注限额",1)
		self.m_lHaveJetton = self.m_lHaveJetton - m_nJettonSelect;
		return;
	end
    if m_nJettonSelect>10000000  then
     --异常
     self:getParentNode():sendUserTryBet(area, m_nJettonSelect,GlobalUserItem.lUserScore,self.m_lHaveJetton);	
    end
    if m_nJettonSelect<=0  then
     --异常
     self:getParentNode():sendUserTryBet(area, m_nJettonSelect,GlobalUserItem.lUserScore,self.m_lHaveJetton);	
    end
	--下注
	self:getParentNode():sendUserBet(area, m_nJettonSelect);	

  end

end

  
end


function GameViewLayer:onGetUserBet( cbAndroidUser )
	local data = self:getParentNode().cmd_placebet;
	if nil == data then
		return
	end
	local area = data.cbBetArea ;
	local wUser = data.wChairID;
	local llScore = data.lBetScore

     self.m_bPlaerSounder=true;

    self:refreshJettonNode(area+1, llScore, llScore, self:isMeChair(wUser))

	if self:isMeChair(wUser) then
		self.m_scoreUser = self.m_scoreUser - self.m_nJettonSelect;
		self.m_lHaveJetton = self.m_lHaveJetton + llScore;

        if area+1 == 1 then
            self.m_tableJettonLong = self.m_tableJettonLong+llScore
        end
        if area+1 == 2 then
            self.m_tableJettonHu = self.m_tableJettonHu+llScore
        end
        if area+1 == 3 then
            self.m_tableJettonHe = self.m_tableJettonHe+llScore
        end
     
		--调整下注按钮
		self:adjustJettonBtn();
        --更新自己下注信息
       local lstrMeJect = "MeJett_Image_"..area+1
       local strMeBetScore =  self.GameNods:getChildByName(lstrMeJect)
       strMeBetScore:setVisible(true)
       strMeBetScore  =   strMeBetScore:getChildByName("MtJect_text")

       if strMeBetScore ~= nil then
        if strMeBetScore:isVisible() ~= true then
         strMeBetScore:setVisible(true)
        end

        if area+1 == 1 then
            strMeBetScore:setString(self.m_tableJettonLong)
        end
        if area+1 == 2 then
             strMeBetScore:setString(self.m_tableJettonHu)
        end
        if area+1 == 3 then
             strMeBetScore:setString(self.m_tableJettonHe)
        end
       end

	end


        --保存真人下注
         --真人下注金额
         if cbAndroidUser == 0 then
             self.m_AllPersonote[area+1]  = self.m_AllPersonote[area+1]+llScore
             --筹码区域
             if area+1 == 1 then
             --龙
              self.m_LongAddScore:setString(self.m_AllPersonote[area+1])
             end
              if area+1 == 2 then
             --hu
              self.m_HuAddScore:setString(self.m_AllPersonote[area+1])
             end
              if area+1 == 3 then
             --he
              self.m_HeAddScore:setString(self.m_AllPersonote[area+1])
             end
         end


         --更新总筹码
        self.m_AllJettonHe[area+1] =  self.m_AllJettonHe[area+1]+llScore
        local strAllBet=  self.GameNods:getChildByName("AllBeg_"..area+1)
        if strAllBet ~= nil and (strAllBet:isVisible() ~= true) then
            strAllBet:setVisible(true)
        end
           local TransformationScore = self:itemNumberToString(self.m_AllJettonHe[area+1])
            strAllBet:setString(TransformationScore)
        --添加筹码
        self:AddChiBet(llScore,area+1)
     --   if self.m_bPlayGoldFlyIn == true then
			--ExternalFun.playSoundEffect("bet.mp3")
			--self.m_bPlayGoldFlyIn = false
		--end

        --可以播放声音
       
        if llScore>=1000000 then
         if self.m_bPlayGoldFlyIn >=4 then
             ExternalFun.playSoundEffect("audio_raise_100w.mp3")
             self.m_bPlayGoldFlyIn = 1
         end
        
       end

        
end


function GameViewLayer:itemNumberToString(num)  
    if num >= 100000 then  
        return string.format("%d万", math.floor(num / 10000))  
    elseif num >= 10000 then  
        if num % 10000 < 1000 then  
            return string.format("%d万", math.floor(num / 10000))  
        else  
            return string.format("%.1f万", (num - num % 1000)/10000)  
        end  
    else 
              local lQinScore =   num/1000
              lQinScore = "0."..lQinScore.."万"
              return lQinScore
                  
    end  
end  

function GameViewLayer:refreshJettonNode( node, my, total, bMyJetton )	
	if true == bMyJetton then
		--node.m_llMyTotal = node.m_llMyTotal + my
		print("爸爸下注了,下注金额"..my)
		local myscore = self.m_textUserCoint:getString()
		myscore = string.gsub(myscore,":","")
		myscore = tonumber(myscore)
		myscore = myscore - my
		local str = ExternalFun.numberThousands(myscore);
        local strRef = string.gsub(str, ",", ":")
	    self.m_textUserCoint:setString(strRef);
	end

    --更新总筹码

--	node.m_llAreaTotal = node.m_llAreaTotal + total
--	node:setVisible( node.m_llAreaTotal > 0)


end
function GameViewLayer:OnAddBject(area,RandPos, Lscore)
   	
   --创建一个筹码吧
   local  DeskBet= cc.Sprite:create("game/anniou/xiazhuanniou/"..Lscore..".png")
   if DeskBet ~= nil then
     DeskBet:setPosition(RandPos)
       self.m_tableJettonArea[area]:addChild(DeskBet)
    end
end


--下注特效
function GameViewLayer:NewBetFirs(area,RandPos, Lscore)

   local sprite = cc.Sprite:createWithSpriteFrameName("fire01.png")  
   sprite:setPosition(cc.p(RandPos.x,RandPos.y+80))  
   self.m_tableJettonArea[area]:addChild(sprite)
   local animate = cc.Animation:create()  
    for i = 1, 5 do  
        local frameName = "fire0"..i..".png"  
        animate:addSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName))  
    end  
    animate:setDelayPerUnit(0.065) --时间间隔  
    animate:setRestoreOriginalFrame(false) --是否播放完后回到第一针  
    animate:setLoops(1)  --循环册书  
    local action = cc.Animate:create(animate)  

    sprite:runAction(cc.Sequence:create(action, cc.CallFunc:create(function()
        --动画过后我在显示按钮  
        sprite:setVisible(false)
        self:OnAddBject(area,RandPos, Lscore)

    end))) 

 
end



--随机的位置给我添加一个小筹码儿
function GameViewLayer:AddChiBet( lUserJetton,area)
	
   local RandPos =  self:getBetRandomPos(self.m_tableJettonArea[area],area)
   --创建一个筹码吧
   local  DeskBet= cc.Sprite:create("game/anniou/xiazhuanniou/"..lUserJetton..".png")
   if DeskBet ~= nil then
     DeskBet:setPosition(RandPos)
             -- 爆炸特效
    if lUserJetton>=100000 then 
        self:NewBetFirs(area,RandPos,lUserJetton)
     else
      
        self.m_tableJettonArea[area]:addChild(DeskBet)
    end
  
  end

end

--播放滚动字母
function GameViewLayer:AnimeMove(AnimeType)
    
    self.GameNods:getChildByName("Win_MoveImage"):setLocalZOrder(1001)
    local lWinImage = self.GameNods:getChildByName("Win_MoveImage"):getChildByName("Image_Type")

    local AnimeWinImage =nil;
    if AnimeType == 1 then 
        lWinImage:setTexture("game/winText1.png")
    elseif AnimeType == 2 then
        lWinImage:setTexture("game/winText2.png")
    elseif AnimeType == 3 then
        lWinImage:setTexture("game/winText3.png")
    end

 
	local move1 = cc.MoveTo:create(0.9,cc.p(102.47,384.15))
	local delay = cc.DelayTime:create(1.3)
	local move2 = cc.MoveTo:create(0.3,cc.p(1157.77,384.15))
	local seq   =  cc.Sequence:create(move1,delay,move2,cc.CallFunc:create(function (  )
		  self.GameNods:getChildByName("Win_MoveImage"):setPosition(cc.p(-900,384.15))
          --呵呵哒给我
          self:AddSingle(AnimeType)
          --显示结算款 路单什么的
          self:ShowGameOver(self:getDataMgr().m_tabGameEndCmd.lPlayAllScore,self:getDataMgr().m_tabGameEndCmd.GetPoolScore,true)
	end))
	self.GameNods:getChildByName("Win_MoveImage"):runAction(seq)


end
--插入一个路单子吧
function GameViewLayer:AddSingle(SingleType)

--    --路单初始化 当前多少列多少行
--    self.SingleRowTable = {row=0,column = 0}
--    --当前路单类型 -1 代表没有  0  龙 1虎   2  和气生财
--    self.CurSingleType =  - 1 
--    --基础位置
--    self.CurSingBaseX = 533.38
--    self.CurSingBaseY= 218.62
    local filelstr = "game/historySIcon"..SingleType..".png"
    local SpriteSingle = cc.Sprite:create(filelstr)  
    -- 保存到以后要用到你
    table.insert(self.SingleTable, SingleType)

    --当前没有数据
     if self.CurSingleType == -1 then
         SpriteSingle:setPosition(cc.p(self.CurSingBaseX,self.CurSingBaseY))
         self.CurSingleType = SingleType
         self.SingleImage:addChild(SpriteSingle)
    else

        --要刷新数据呵呵等下哈！
        if self:isSingleUpdate(SingleType) == true then
        -- 直接给我删除了重新贴 可以不 磨磨蹭蹭的，
         self.SingleImage:removeAllChildren()
         self:SetSigerInfos()
        else
        if self:isSingleEnter(SingleType) == true  then
        --换行
            self.SingleRowTable.row = self.SingleRowTable.row + 1
            if self.SingleRowTable.row > 11 then
                self.SingleRowTable.row = 11
            end
            self.SingleRowTable.column = 1
            self.CurSingleType = SingleType
           local rowX =self.CurSingBaseX+(self.SingleRowTable.row-1)*27
           local rowY = self.CurSingBaseY- (self.SingleRowTable.column - 1) *26
          -- SpriteSingle:setPosition(cc.p(rowX,rowY)
           SpriteSingle:setPosition(cc.p(rowX,rowY))
           self.SingleImage:addChild(SpriteSingle)
        else
--        --不换行
           self.SingleRowTable.column = self.SingleRowTable.column+1
           self.CurSingleType = SingleType
                       --显示路单子
           local rowX = (self.CurSingBaseX+(self.SingleRowTable.row-1)*27)+(1*self.SingleRowTable.column-1)
           local rowY = self.CurSingBaseY- (self.SingleRowTable.column - 1) *26
          -- SpriteSingle:setPosition(cc.p(rowX,rowY)
           SpriteSingle:setPosition(cc.p(rowX,rowY))
           self.SingleImage:addChild(SpriteSingle)
       end


     end
   end


         self:setSigerCount()

end

--设置路单数据
function GameViewLayer:setSigerCount()
--  text_Single_1
    local long = 0
    local hu = 0
    local he = 0

    for i = 1 , #self.SingleTable do 
    if self.SingleTable[i] == 1 then
      long = long + 1
    end
    if self.SingleTable[i] == 2 then
      hu = hu + 1
    end
     if self.SingleTable[i] == 3 then
      he = he + 1
    end
  end

  self.GameNods:getChildByName("text_Single_0"):setString(long)
  self.GameNods:getChildByName("text_Single_1"):setString(he)
  self.GameNods:getChildByName("text_Single_2"):setString(hu)


end
--根据表 显示路单
function GameViewLayer:SetSigerInfos()
    --获取路单数据先
    self:CopyNexSinger()
    self.SingleRowTable.column = 1
    self.SingleRowTable.row = 1
    self.CurSingleType = -1 



    for i=1 , #self.SingleTable do 
        local curPos =self.SingleTable[i]
        local filelstr = "game/historySIcon"..curPos..".png"
        local SpriteSingle = cc.Sprite:create(filelstr)  

        -- if  self.SingleRowTable.row>=12 then 
        --     break
        -- end
            --当前没有数据
        if self.CurSingleType == -1 then
            SpriteSingle:setPosition(cc.p(self.CurSingBaseX,self.CurSingBaseY))
            self.CurSingleType =self.SingleTable[i]
            self.SingleImage:addChild(SpriteSingle)
        else
            if self:isSingleEnter(curPos) == true  then
                --换行
                self.SingleRowTable.row = self.SingleRowTable.row + 1
                self.SingleRowTable.column = 1
                self.CurSingleType = self.SingleTable[i]
                local rowX = self.CurSingBaseX + (self.SingleRowTable.row-1) * 27
                local rowY = self.CurSingBaseY - (self.SingleRowTable.column - 1) * 26
                -- SpriteSingle:setPosition(cc.p(rowX,rowY)
                SpriteSingle:setPosition(cc.p(rowX,rowY))
                self.SingleImage:addChild(SpriteSingle)
            else
                --不换行
                self.SingleRowTable.column = self.SingleRowTable.column+1
                self.CurSingleType = self.SingleTable[i]
                       --显示路单子
                local rowX = (self.CurSingBaseX+(self.SingleRowTable.row-1)*27)+(1*self.SingleRowTable.column-1)
                local rowY = self.CurSingBaseY- (self.SingleRowTable.column - 1) *26
                -- SpriteSingle:setPosition(cc.p(rowX,rowY)
                SpriteSingle:setPosition(cc.p(rowX,rowY))
                self.SingleImage:addChild(SpriteSingle)
            end

        end
    end

end

--复制路单数据
function GameViewLayer:CopyNexSinger()

--     local TempSingleTable ={}

--     for i = 1,#self.SingleTable do 
--        TempSingleTable[i] = self.SingleTable[i]
--     end
-- --    --删除以前的
-- --    for i=1, #self.SingleTable do
-- --       table.remove(self.SingleTable, i)
-- --    end

--     self.SingleTable = nil 
--     self.SingleTable={}

--     --静止连续的
--     local kissType = TempSingleTable[1]
--     local curIndex = 1
--     local baoji = false
--     local curPos = 1
--     for i = 1,#TempSingleTable do 
--         if kissType == TempSingleTable[i] and curIndex < 4  and baoji == false then
--             curIndex = curIndex + 1
--         else
--             baoji = true
--             self.SingleTable[curPos] = TempSingleTable[i]
--             curPos = curPos+1
--         end
--     end

    local curRow = 1    --当前行数
    local curTotl = 1   --当前行类型数量
    local curType = -1  --当前类型
    local game_record1 = {}
    for i = #self.SingleTable, 1, -1 do 
        if curType ~= -1 then
            --不同类型分行放
            if curType ~= self.SingleTable[i] then
                curTotl = 1
                curRow = curRow + 1
            --同类型数量大于4行数增加
            else
                curTotl = curTotl + 1
                if curTotl == 5 then
                    curTotl = 1
                    curRow = curRow + 1
                end
            end
        end
        print("==============",curRow)
        --超过十一行就不搞了
        if curRow > 11 then
            break
        end
        curType = self.SingleTable[i]
        table.insert(game_record1, curType)
    end

    --清数据
    self.SingleTable = {}
    --倒序改成正序
    for i = #game_record1, 1, -1 do
        table.insert(self.SingleTable, game_record1[i])
    end
    --self.SingleTable = game_record1
end
--当前是否换行
function GameViewLayer:isSingleEnter(SingleType)

 if self.SingleRowTable.column == 4 then
  return true
 end
  if  self.CurSingleType ~= SingleType then 
    return true
 end
 return  false 
end

--是否要刷新
function GameViewLayer:isSingleUpdate(SingleType)

 if self.SingleRowTable.row == 11 and self.SingleRowTable.column == 4 then
  return  true 
end

 if  self.SingleRowTable.row == 11 and self.CurSingleType ~= SingleType then 
    return true
end

    if  self.SingleRowTable.row >11 then
    return true
    end

 return  false 
end



function GameViewLayer:getBetRandomPos(nodeArea,area)
	if nil == nodeArea then
		return {x = 0, y = 0}
	end

   
	local nodeSize = cc.size(nodeArea:getContentSize().width / 2, nodeArea:getContentSize().height/3+40);
     if area == 3 then
       nodeSize.width  = nodeSize.width-50
       nodeSize.height= nodeSize.height-35
--    elseif area ==1 then
--       nodeSize.width  = nodeSize.width+100
--       nodeSize.height= nodeSize.height+15
--    elseif area ==2 then
--       nodeSize.width  = nodeSize.width+20
--       nodeSize.height= nodeSize.height+50
    end

	local xOffset = math.random()
	local yOffset = math.random()

	local posX = nodeArea:getAnchorPoint().x * nodeSize.width
    local posY = nodeArea:getAnchorPoint().y * nodeSize.height+60

    if area == 3 then
        posX=posX+80
        posY=posY-30
    elseif area ==1 then
        posX=posX+90
    elseif area ==2 then
        posY = posY+80
        posX=posX+30
    end
	
	return cc.p(xOffset * nodeSize.width + posX, yOffset * nodeSize.height + posY)
end


-- new BET
function GameViewLayer:NewBet(cbArea,cbIndex,cbBetIndex)
    --创建一个筹码吧

   local RandPos = self:getBetRandomPos(cbArea,cbBetIndex)
   local  DeskBet= cc.Sprite:create("game/bet/quyuBet/tabel_chip_"..cbIndex.."_0.png")
   DeskBet:setPosition(RandPos)
   cbArea:addChild(DeskBet)

end
--断线重连更新界面已下注
function GameViewLayer:reEnterGameBet( cbArea, llScore )
	local btn = self.m_tableJettonArea[cbArea];
	if nil == btn or 0 == llSocre then
		return;
	end

	local vec = self:getDataMgr().calcuteJetton(llScore, false);
	for k,v in pairs(vec) do
		local info = v;
		for i=1,info.m_cbCount do
			local str = string.format("tabel_chip_%d_0.png", info.m_cbIdx);
               self:NewBet(btn,info.m_cbIdx,cbArea)
			end
		end

    --更新总筹码
    self.m_AllJettonHe[cbArea] =  self.m_AllJettonHe[cbArea]+llScore
    local strAllBet=  self.GameNods:getChildByName("AllBeg_"..cbArea)
    if strAllBet ~= nil and (strAllBet:isVisible() ~= true) then
        strAllBet:setVisible(true)
    end
        local TransformationScore = self:itemNumberToString(self.m_AllJettonHe[cbArea])
        strAllBet:setString(TransformationScore)

end



--断线重连更新玩家已下注
function GameViewLayer:reEnterUserBet( cbArea, llScore )

	local btn = self.m_tableJettonArea[cbArea];
	if nil == btn or 0 == llSocre then
		return;
	end

     if cbArea == 1 then
            self.m_tableJettonLong = self.m_tableJettonLong+llScore
        end
        if cbArea == 2 then
            self.m_tableJettonHu = self.m_tableJettonHu+llScore
        end
        if cbArea == 3 then
            self.m_tableJettonHe = self.m_tableJettonHe+llScore
        end

      --更新自己下注信
       local lstrMeJect = "MeJett_Image_"..area
      local strMeBetScore =  self.GameNods:getChildByName("lstrMeJect")
       strMeBetScore:setVisible(true)
      strMeBetScore  =   strMeBetScore:getChildByName("MtJect_text")

       if strMeBetScore:isVisible() ~= true then
         strMeBetScore:setVisible(true)
       end
       if strMeBetScore ~= nil then
            if cbArea == 1 then
                strMeBetScore:setString(self.m_tableJettonLong)
            end
        if cbArea == 2 then
             strMeBetScore:setString(self.m_tableJettonHu)
        end
        if cbArea == 3 then
             strMeBetScore:setString(self.m_tableJettonHe)
        end
    end

end


--游戏进行
function GameViewLayer:reEnterStart( lUserJetton )
	self.m_nJettonSelect = self.m_pJettonNumber[DEFAULT_BET].k;
	self.m_lHaveJetton = lUserJetton;

	--获取玩家携带游戏币
	self.m_scoreUser = 0
	self:reSetUserInfo();

	self.m_bOnGameRes = false

	--不是自己庄家
	if false == self:isMeChair(self.m_wBankerUser) then
		self:ShowBankerBtn(true);
		--调整下注按钮
		self:adjustJettonBtn();
	end		
end



function GameViewLayer:getParentNode( )
	return self._scene;
end

function GameViewLayer:getDataMgr( )
	return self:getParentNode():getDataMgr()
end

--玩家信息
function GameViewLayer:getMeUserItem(  )
	if nil ~= GlobalUserItem.dwUserID then

		return self:getDataMgr():getUidUserList()[GlobalUserItem.dwUserID];
	end
	return nil;
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


----管理控制初始化
function GameViewLayer:initContorl(  )	

 local function clipEvent( sender, eventType )
	if eventType == ccui.TouchEventType.ended then
		self:onContorlButtonClicked(sender:getTag(), sender);
	end
 end
 
-- local AdminContorl = 
--{
--	"Btn_Contorl",
--    "Btn_AmendStock",
--    "Btn_BankerWin",
--    "Btn_BankerLost",
--    "Btn_UpdatData",
--    "Btn_LongWin",
--    "Btn_HuWin",
--    "Btn_HeWin"
--}


 self.m_lBtnContorl = self.GameNods:getChildByName("Btn_Contorl")
 if self.m_lBtnContorl ~= nil then
    self.m_lBtnContorl:setVisible(false)
    self.PanelContorl = self.GameNods:getChildByName("Panel_1")
    self.PanelContorl:setLocalZOrder(12000)
	self.m_lBtnContorl:setTag(TAG_Admin.Btn_Contorl)
	self.m_lBtnContorl:addTouchEventListener(clipEvent)

    --庄赢
     local Btnrs = self.PanelContorl:getChildByName("Btn_BankerWin")
     Btnrs:setTag(TAG_Admin.Btn_BankerWin)
	 Btnrs:addTouchEventListener(clipEvent)

     Btnrs = self.PanelContorl:getChildByName("Btn_BankerLost")
     Btnrs:setTag(TAG_Admin.Btn_BankerLost)
	 Btnrs:addTouchEventListener(clipEvent)

     Btnrs = self.PanelContorl:getChildByName("Btn_Update")
     Btnrs:setTag(TAG_Admin.Btn_UpdatData)
	 Btnrs:addTouchEventListener(clipEvent)

     Btnrs = self.PanelContorl:getChildByName("Btn_LongWin")
     Btnrs:setTag(TAG_Admin.Btn_LongWin )
	 Btnrs:addTouchEventListener(clipEvent)

     Btnrs = self.PanelContorl:getChildByName("Btn_Store_HuWin")
     Btnrs:setTag(TAG_Admin.Btn_HuWin)
	 Btnrs:addTouchEventListener(clipEvent)

     Btnrs = self.PanelContorl:getChildByName("Btn_Store_HeWin")
     Btnrs:setTag(TAG_Admin.Btn_HeWin)
	 Btnrs:addTouchEventListener(clipEvent)


     Btnrs = self.PanelContorl:getChildByName("Btn_exec")
     Btnrs:setTag(TAG_Admin.Btn_Exec)
	 Btnrs:addTouchEventListener(clipEvent)

     Btnrs = self.PanelContorl:getChildByName("Btn_Close")
     Btnrs:setTag(TAG_Admin.Btn_Close)
	 Btnrs:addTouchEventListener(clipEvent)

     --修改库存
     Btnrs = self.PanelContorl:getChildByName("Btn_Store")
     Btnrs:setTag(TAG_Admin.Btn_Store)
	 Btnrs:addTouchEventListener(clipEvent)



     


     --选择区域
     self.cbRegionIndex = -1;

     --筹码区域
     self.m_LongAddScore = self.PanelContorl:getChildByName("Text_LongAddScore")
     self.m_HuAddScore = self.PanelContorl:getChildByName("Text_HuAddScore")
     self.m_HeAddScore = self.PanelContorl:getChildByName("Text_HeAddScore")


     self.m_OffUserText = self.PanelContorl:getChildByName("Text_OffUser")
     self.m_FissfStoreText = self.PanelContorl:getChildByName("Text_FissfStore")
     self.m_TextContorlStatus= self.PanelContorl:getChildByName("Text_ContorStatus")
     self.m_ListUserContorl= self.PanelContorl:getChildByName("ListView_2")
     self._useritem= self.PanelContorl:getChildByName("Panel_8")
     self.m_AllWinScoreText = self.PanelContorl:getChildByName("Text_AllWinScore")
     self.m_CurWinScoreText = self.PanelContorl:getChildByName("Text_CurAllScore")


     --库存框
        self.m_TextField_Storeder =ccui.EditBox:create(cc.size(200,20), "")
		:move(cc.p(9,221))
        :setFontColor(cc.c3b(0,0,0))
        :setName("TextField_Storeder")
        :setAnchorPoint(cc.p(0.0,0.5))
        :setFontSize(28)
        :setFontColor(cc.WHITE)
		:setFontName("fonts/round_body.ttf")
		:setMaxLength(12)
        self.m_TextField_Storeder:setFontColor(cc.c3b(0,0,0))
        self.PanelContorl:addChild(self.m_TextField_Storeder)

 end

end

function GameViewLayer:ShowAdminBtn()
    self.m_lBtnContorl:setVisible(true)
end
--初始化玩家信息
function GameViewLayer:initUserInfo(  )	
	--玩家头像
	local tmp = self.m_spBottom:getChildByName("player_head")
    local head =HeadSprite:createNormal(GlobalUserItem, 55)
	head:setPosition(tmp:getPosition())
	self.m_spBottom:addChild(head)
	--head:enableInfoPop(false)

--	--玩家金币
      self.m_textUserCoint = ccui.TextAtlas:create("0", "game/jiangchi.png", 24, 35, "0")
      self.m_textUserCoint:setName("coin_text")
      self.m_textUserCoint:setAnchorPoint(cc.p(0.0,0.5))
      self.m_textUserCoint:setPosition(cc.p(148,24))
      self.m_textUserCoint:setScale(0.45)
      self.m_spBottom:addChild(self.m_textUserCoint)

      --用户昵称
      local myUser = self:getMeUserItem()
      local nickstr = myUser.szNickName

      local strNick = self.m_spBottom:getChildByName("Nick_text_")
      self:SubNickName(strNick,nickstr)
      self:reSetUserInfo()

      --结束面板初始化
      --结束框
     self.GameOverWinImage = self.GameNods:getChildByName("OverGame_Image_Win");
     self.GameOverWinImage:setLocalZOrder(1110)
     self.GameOverWinImage:setScale(0)
     local head =HeadSprite:createNormal(GlobalUserItem, 55)
	 head:setPosition(cc.p(415.90,200))
	 self.GameOverWinImage:addChild(head)
     --结束昵称
     local lMyNickName = self.GameOverWinImage:getChildByName("NickName_Text")
     self:SubNickName(lMyNickName,nickstr)
     local WinImage =  ccui.TextAtlas:create("0", "game/wwwdsd.png", 32, 40, "0")
     WinImage:setAnchorPoint(cc.p(0.5,0.5))
     WinImage:setTag(1)
     WinImage:setScale(0.7)
     WinImage:setVisible(false)
     WinImage:setPosition(cc.p(412.90,118))
     self.GameOverWinImage:addChild(WinImage)

     local PoolImage = ccui.TextAtlas:create("0", "game/jiangChi_Num(19x25).png", 19, 25, "0")
     PoolImage:setAnchorPoint(cc.p(0.0,0.5))
     PoolImage:setPosition(cc.p(55,22))
     PoolImage:setTag(2)
     self.GameOverWinImage:getChildByName("bonus_Image"):setVisible(false)
     self.GameOverWinImage:getChildByName("bonus_Image"):addChild(PoolImage)


     self.GameOverLostImage = self.GameNods:getChildByName("OverGame_Image_Lost");
     self.GameOverLostImage:setLocalZOrder(1111)
     self.GameOverLostImage:setScale(0)
     local head =HeadSprite:createNormal(GlobalUserItem, 55)
	 head:setPosition(cc.p(415.90,200))
	 self.GameOverLostImage:addChild(head)
     --结束昵称
     local lMyNickName = self.GameOverLostImage:getChildByName("NickName_Text")
     self:SubNickName(lMyNickName,nickstr)
     local LostImage =  ccui.TextAtlas:create("0", "game/sssdds.png", 32, 40, "0")
     LostImage:setAnchorPoint(cc.p(0.5,0.5))
     LostImage:setTag(1)
     LostImage:setScale(0.7)
     LostImage:setVisible(false)
     LostImage:setPosition(cc.p(412.90,118.08))
     self.GameOverLostImage:addChild(LostImage)

     local LostPoolImage = ccui.TextAtlas:create("0", "game/jiangChi_Num(19x25).png", 19, 25, "0")
     LostPoolImage:setAnchorPoint(cc.p(0.0,0.5))
     LostPoolImage:setPosition(cc.p(55,22))
     LostPoolImage:setTag(2)
     self.GameOverLostImage:getChildByName("bonus_Image"):setVisible(false)
     self.GameOverLostImage:getChildByName("bonus_Image"):addChild(LostPoolImage)


end

--显示结束面板
function GameViewLayer:ShowGameOver(WinScore , PoolScore , ScrentAnime)
    
    --刷新庄家成绩
    if self.bankScore~= nil then
       
        if yl.INVALID_CHAIR ~= self.m_wBankerUser then --系统坐庄
            self.m_textBankerCoin:setString(self.bankScore);
        end 
        self.bankScore = nil
    end
    
    --判断是否显示结束
  local ll = 0;
  local bShowOver = false
  if WinScore == 0 then
    for i=1,g_var(cmd).AREA_MAX do
        ll = self:getDataMgr().m_tabGameEndCmd.lPlayScore[1][i]     
        if ll ~= 0 then
            bShowOver = true
        end  
    end
    if bShowOver == false then
        return ;
    end
  end

   --刷新金币
   self:reSetUserInfo()

    local GameOverPalter = self.GameOverWinImage;
    if WinScore<0 then
          GameOverPalter = self.GameOverLostImage;
    end

    if WinScore >= 0 then
        local  WinImage = GameOverPalter:getChildByTag(1)
        local  strScore = ":"..WinScore
        WinImage:setString(strScore)
        WinImage:setVisible(true)
       -- ExternalFun.playSoundEffect("yingle.wav")
    else
        local  LostImage =GameOverPalter:getChildByTag(1)
        local  strScore = ":"..WinScore
        LostImage:setString(strScore)
        LostImage:setVisible(true)
       -- ExternalFun.playSoundEffect("shu.wav")
    end
    --是否有奖金
    if PoolScore>0 then
        local  PoolImage = GameOverPalter:getChildByName("bonus_Image")
        PoolImage:setVisible(true)
        local lPoolText = PoolImage:getChildByTag(2)
        local  strScore = ":"..PoolScore
        lPoolText:setString(strScore)
    end
    --是否动画
    GameOverPalter:setVisible(true)
    if ScrentAnime == true then
        --加载动画
	local CardScale  = cc.ScaleTo:create(0.7,1.0, 1)
	local call = cc.CallFunc:create(function( )
	end)
	local SpaceCard = cc.Sequence:create(CardScale, call)
	GameOverPalter:runAction(SpaceCard)
    else
         GameOverPalter:setScale(1.0)
   end

end

function GameViewLayer:reSetUserInfo()

	self.m_scoreUser = 0
	local myUser = self:getMeUserItem()
	if nil ~= myUser then
		self.m_scoreUser = myUser.lScore;
	end	
	print("自己金币:" .. ExternalFun.formatScore(self.m_scoreUser))
   local str = ExternalFun.numberThousands(self.m_scoreUser);
   local strRef = string.gsub(str, ",", ":")
	--[[if string.len(str) > 11 then
		str = string.sub(str,1,11) .. "...";
	end]]
	self.m_textUserCoint:setString(strRef);
end



function GameViewLayer:onJettonButtonClicked( tag, ref )
	if tag >= 1 and tag <= 6 then
		self.m_nJettonSelect = self.m_pJettonNumber[tag].k;
	else
		self.m_nJettonSelect = -1;
	end

	self.m_nSelectBet = tag
    self:SetBtnStatus(self.m_tableJettonBtn[tag])
    self:SelectObjectBtn(self.m_tableJettonBtn[tag])
	print("click jetton:" .. self.m_nJettonSelect)
end


--更新库存
function GameViewLayer:UpdateStore(StoreScore)
 self.m_TextField_Storeder:setText(StoreScore)
end
function GameViewLayer:onContorlButtonClicked( tag, ref )


--    local AdminContorl = 
--    {
--    "Btn_Contorl",
--    "Btn_AmendStock",
--    "Btn_BankerWin",
--    "Btn_BankerLost",
--    "Btn_UpdatData",
--    "Btn_LongWin",
--    "Btn_HuWin",
--    "Btn_HeWin"
--    }

--    local TAG_Admin= ExternalFun.declarEnumWithTable(1, AdminContorl);





if tag == TAG_Admin.Btn_UpdatData then
   --在线列表配置
   self:getParentNode():UserInfos()
end

if tag == TAG_Admin.Btn_Store then
   
   self:getParentNode():DissfStoreScore(self.m_TextField_Storeder:getText())
end

if tag == TAG_Admin.Btn_Close then
   --关闭面板
   self.PanelContorl:setVisible(false)
 end
 if tag == TAG_Admin.Btn_Contorl then
   --显示面板
   self.PanelContorl:setVisible(true)
    --在线列表配置
   self:getParentNode():UserInfos()
 end
 if tag == TAG_Admin.Btn_BankerWin then
 --庄家赢了
     self.cbRegionIndex = 1;
     self:getParentNode():SendContorl(1);	
     self.m_TextContorlStatus:setString("当前选择庄赢")
 end
  if tag == TAG_Admin.Btn_BankerLost then
 --庄家输了
     self.cbRegionIndex = 0;
     self:getParentNode():SendContorl(0);	
     self.m_TextContorlStatus:setString("当前选择庄输")
 end
 if tag == TAG_Admin.Btn_LongWin then
 --龙赢了
     self.cbRegionIndex = 2;
     self:getParentNode():SendContorl(2);	
     self.m_TextContorlStatus:setString("当前选择龙赢")
 end
 if tag == TAG_Admin.Btn_HuWin then
 --虎赢了
     self.cbRegionIndex = 3;
     self:getParentNode():SendContorl(3);	
     self.m_TextContorlStatus:setString("当前选择虎赢")
 end
 if tag == TAG_Admin.Btn_HeWin then
 --和赢了
  self.cbRegionIndex = 4;
  self:getParentNode():SendContorl(4);	
  self.m_TextContorlStatus:setString("当前选择和赢")
 end
 if tag == TAG_Admin.Btn_Exec then
 --执行命令
 if self.cbRegionIndex >-1 and self.cbRegionIndex <=4 then

  self:getParentNode():SendContorl(self.cbRegionIndex);	
  
  end


 end

end


--更新用户筹码
function GameViewLayer:onBetInfo( BetTable )
   

   --查找 节点
  local UpBetNodt =  self.m_ListUserContorl:getChildByTag(BetTable.wGameID)
   if UpBetNodt ~= nil then
    local AllScore = UpBetNodt:getChildByName("BankerText_0_8_0_0")
    local LongScore = UpBetNodt:getChildByName("BankerText_0_8_0_0_0")
    local HuScore = UpBetNodt:getChildByName("BankerText_0_8_0_0_0_1")
    local HeScore = UpBetNodt:getChildByName("BankerText_0_8_0_0_0_0")
    AllScore:setString(BetTable.lAllBet)
    LongScore:setString(BetTable.lLongBet)
    HuScore:setString(BetTable.lHuBet)
    HeScore:setString(BetTable.lHeBet)


   end

end

--用户列表
function GameViewLayer:onUserInfo( UserInfoTable )

 --绘制库存信息
 self.m_ListUserContorl:removeAllChildren()
 	self._itemInfo = {}
 	local admin = UserInfoTable.FishServerInfo[1]
 	print(UserInfoTable.cbColumnCount)
     dump(admin)
 	for i = 1, UserInfoTable.cbColumnCount do	
       if i == 1 then
         self.m_AllWinScoreText:setString(admin[i].wRoomWinLost)
         self.m_CurWinScoreText:setString(admin[i].wToDayLoset)
         self.m_OffUserText:setString(admin[i].wOnlineNumber)
       else
             local useritem = self._useritem:clone()
 		     local gameid = useritem:getChildByName("BankerText_0_1")
             local Nick = useritem:getChildByName("BankerText_0_2")
             local AllScore = useritem:getChildByName("BankerText_0_8_0_0")
             local LongScore = useritem:getChildByName("BankerText_0_8_0_0_0")
             local HuScore = useritem:getChildByName("BankerText_0_8_0_0_0_1")
             local HeScore = useritem:getChildByName("BankerText_0_8_0_0_0_0")
 		     gameid:setString(admin[i].wGameID)
             self:SubNickName(Nick,admin[i].szUserName)
             AllScore:setString("0")
             LongScore:setString("0")
             HuScore:setString("0")
             HeScore:setString("0")

             useritem:setTag(admin[i].wGameID)

 		    self.m_ListUserContorl:pushBackCustomItem(useritem)
       end

 	end


end
--更新用户下注失败
function GameViewLayer:onGetUserBetFail(  )
	local data = self:getParentNode().cmd_jettonfail;
	if nil == data then
		return;
	end

	--下注玩家
	local wUser = data.wPlaceUser;
	--下注区域
	local cbArea = data.cbBetArea + 1;
	--下注数额
	local llScore = data.lPlaceScore;

	if self:isMeChair(wUser) then
		--提示下注失败
		local str = string.format("下注 %s 失败 该区域超过了庄家最大额", ExternalFun.formatScore(llScore))
		showToast(self,str,1)
       -- self:ShowBankerBtn(false)
        --self.m_nJettonSelect = -1
      end


end

--更新扑克牌
function GameViewLayer:onGetGameCard( poolScore , WinScore,tabRes,cbTime )

    --直接显示桌面扑克

   local CardData = nil
   local CardMask = nil
   local CardValue = nil

   for i = 1, 2 do
   local CardSetting  = nil
   if i == 1 then
     CardSetting = self.m_DeskLong
     CardData = tabRes.m_idleCards;
     CardValue  = GameLogic.GetCardValue(CardData)
     CardMask  = GameLogic.GetCardColor(CardData)     
   else
     CardSetting = self.m_DeskHu
     CardData = tabRes.m_masterCards;
     CardValue  = GameLogic.GetCardValue(CardData)
     CardMask  = GameLogic.GetCardColor(CardData)
   end

  -----------------



    local ptrImage = nil 
	self.m_DeskLong:getChildByName("Sprite_7"):setVisible(false)
    self.m_DeskHu:getChildByName("Sprite_7"):setVisible(false)

	if CardMask == 0 then
		 ptrImage = "hong_"
	end
	if CardMask == 16 then
	     ptrImage = "mei_"
	end
	if CardMask == 32 then
	     ptrImage = "fang_"
	end
	if CardMask == 48 then
		ptrImage = "hei_"
	end
    
    ptrImage =ptrImage..CardValue..".png"
	--设置数据哈
    local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrameByName(ptrImage)
    CardSetting:setSpriteFrame(spriteFrame)
    CardSetting:setVisible(true)
    --还有其他事要做哦 就是显示闪动动画哈
	local SortLongValue   = GameLogic.GetCardValue(tabRes.m_idleCards)
	local SortHuValue   = GameLogic.GetCardValue(tabRes.m_masterCards)
	local icontype = nil
	if SortLongValue > SortHuValue then
		local rep = cc.RepeatForever:create(cc.Blink:create(0.65,1))
		self.m_TwinkleAnime[1]:stopAllActions()
		self.m_TwinkleAnime[1]:runAction(rep)
		icontype = g_var(cmd).AREA_LOONG
	end

	if SortLongValue < SortHuValue then
		local rep = cc.RepeatForever:create(cc.Blink:create(0.65,1))
		self.m_TwinkleAnime[2]:stopAllActions()
		self.m_TwinkleAnime[2]:runAction(rep)
		icontype = g_var(cmd).AREA_TIGER
	end
	if SortLongValue  == SortHuValue then
		local rep = cc.RepeatForever:create(cc.Blink:create(0.65,1))
		self.m_TwinkleAnime[3]:stopAllActions()
		self.m_TwinkleAnime[3]:runAction(rep)
		icontype = g_var(cmd).AREA_EQUAL
	end

    --结束面板走一波
   --  self:ShowGameOver(WinScore,poolScore,false)

    end

end

--显示下注按钮
function GameViewLayer:ShowBankerBtn(Show)
    
    for i = 1,#self.m_tableJettonBtn do
        self.m_tableJettonBtn[i]:setEnabled(Show)
    end

end

function GameViewLayer:reSet(  )

end

--游戏记录
function GameViewLayer:updateGameRecord(dataBuffer)
	  --游戏记录
    local len = dataBuffer:getlen();
    local recordcount = math.floor(len / g_var(cmd).RECORD_LEN);
    local game_record = {};
    --读取记录列表
    for i = 1, recordcount do
        if nil == dataBuffer then
            break;
        end
        local cbLoongCount = dataBuffer:readbyte();
        local cbtigerCount = dataBuffer:readbyte();
        if cbLoongCount > cbtigerCount then
          table.insert(game_record, 1)
        elseif cbLoongCount < cbtigerCount then
           table.insert(game_record, 2)
        elseif cbLoongCount == cbtigerCount then
            table.insert(game_record, 3)
        end
    end
    --区分段位
    local curRow = 1    --当前行数
    local curTotl = 1   --当前行类型数量
    local curType = -1  --当前类型
    local game_record1 = {}
    for i = #game_record, 1, -1 do
        
        if curType ~= -1 then
            --不同类型分行放
            if curType ~= game_record[i] then
                curTotl = 1
                curRow = curRow + 1
            --同类型数量大于4行数增加
            else
                curTotl = curTotl + 1
                if curTotl == 5 then
                    curTotl = 1
                    curRow = curRow + 1
                end
            end
        end
        print("==============",curRow)
        --超过十一行就不搞了
        if curRow > 11 then
            break
        end
        curType = game_record[i]
        table.insert(game_record1, curType)
    end

    --倒序改成正序
    for i = #game_record1, 1, -1 do
        table.insert(self.SingleTable, game_record1[i])
    end
    dump(game_record)
    dump(self.SingleTable)

    for i = 1, #self.SingleTable do
        local curPos =self.SingleTable[i]
        local filelstr = "game/historySIcon"..curPos..".png"
        local SpriteSingle = cc.Sprite:create(filelstr)  
        --当前没有数据
        if self.CurSingleType == -1 then
            SpriteSingle:setPosition(cc.p(self.CurSingBaseX,self.CurSingBaseY))
            self.CurSingleType = self.SingleTable[i]
            self.SingleImage:addChild(SpriteSingle)
        else
            -- if  self.SingleRowTable.row>11 then
            --     break
            -- end

            if self:isSingleEnter(curPos) == true  then
                --换行
                self.SingleRowTable.row = self.SingleRowTable.row + 1
                if  self.SingleRowTable.row > 11 then
                    self.SingleRowTable.row = 11
                end
                self.SingleRowTable.column = 1
                self.CurSingleType = self.SingleTable[i]
                local rowX = self.CurSingBaseX + (self.SingleRowTable.row - 1) * 27
                local rowY = self.CurSingBaseY - (self.SingleRowTable.column - 1) * 26
                SpriteSingle:setPosition(cc.p(rowX, rowY))
                self.SingleImage:addChild(SpriteSingle)
            else
                --不换行
                self.SingleRowTable.column = self.SingleRowTable.column + 1
                self.CurSingleType = self.SingleTable[i]
                --显示路单子
                local rowX = (self.CurSingBaseX + (self.SingleRowTable.row-1) * 27) + (1 * self.SingleRowTable.column - 1)
                local rowY = self.CurSingBaseY - (self.SingleRowTable.column - 1) * 26
                SpriteSingle:setPosition(cc.p(rowX, rowY))
                self.SingleImage:addChild(SpriteSingle)
            end
        end
    end
    self:setSigerCount()


--         --区分段位
--         local curRow = 1 --当前你的位置
--         local curTotl = 1
--         local curType =-1
--          for i=#game_record,1,-1 do
--           if curRow<=12  then

--             if  curType ~= game_record[i]  and  curType~= -1 then 
--                 curRow = curRow+1
--                 curTotl = 1
--             end

--             --连续的考虑下
--             if  curType == game_record[i]  and  curType~= -1 then 
--                 curTotl = curTotl+1
--                 if curTotl  ==5 then
--                  curTotl = 1
--                  curRow=curRow+1
--                 end

--             end
         
--          if  curRow<=11 then
--                 -- table.insert(self.SingleTable, SingleType)
--           if curType == -1 then
--              curType = game_record[i]
--             table.insert(self.SingleTable, game_record[i])
--             else
--              table.insert(self.SingleTable, game_record[i])
--              curType = game_record[i]
--           end
--          end

    

--           --换行考虑
        

--         end
   
--     end

--      for i=#self.SingleTable ,1,-1  do
--      local curPos =self.SingleTable[i]
--      local filelstr = "game/historySIcon"..curPos..".png"
--      local SpriteSingle = cc.Sprite:create(filelstr)  

--             --当前没有数据
--      if self.CurSingleType == -1 then
--          SpriteSingle:setPosition(cc.p(self.CurSingBaseX,self.CurSingBaseY))
--          self.CurSingleType =self.SingleTable[i]
--          self.SingleImage:addChild(SpriteSingle)
--     else
--          if  self.SingleRowTable.row>11 then
--           break
--          end

--         if self:isSingleEnter(curPos) == true  then
--         --换行
--             self.SingleRowTable.row = self.SingleRowTable.row+1
--             self.SingleRowTable.column = 1
--             self.CurSingleType = self.SingleTable[i]
--             local rowX =self.CurSingBaseX+(self.SingleRowTable.row-1)*27
--             local rowY = self.CurSingBaseY- (self.SingleRowTable.column - 1) *26
--           -- SpriteSingle:setPosition(cc.p(rowX,rowY)
--            SpriteSingle:setPosition(cc.p(rowX,rowY))
--            self.SingleImage:addChild(SpriteSingle)
--         else
-- --        --不换行
--            self.SingleRowTable.column = self.SingleRowTable.column+1
--            self.CurSingleType = self.SingleTable[i]
--                        --显示路单子
--            local rowX = (self.CurSingBaseX+(self.SingleRowTable.row-1)*27)+(1*self.SingleRowTable.column-1)
--            local rowY = self.CurSingBaseY- (self.SingleRowTable.column - 1) *26
--           -- SpriteSingle:setPosition(cc.p(rowX,rowY)
--            SpriteSingle:setPosition(cc.p(rowX,rowY))
--            self.SingleImage:addChild(SpriteSingle)
--        end

--      end
--    end

--    self:setSigerCount();
            
end


return GameViewLayer