--[[
	手游大厅界面
	2015_12_03 C.P
]]
cc.FileUtils:getInstance():addSearchPath("base/src/")
cc.FileUtils:getInstance():addSearchPath("base/res/")
cc.FileUtils:getInstance():addSearchPath("client/src/")
cc.FileUtils:getInstance():addSearchPath("client/res/")
-- 场景声明
local WebFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.WebFrame")
local ClientScene = class("ClientScene", cc.load("mvc").ViewBase)

-- 导入功能
if not yl then
	appdf.req(appdf.CLIENT_SRC.."plaza.models.yl")
end
if not GlobalUserItem then
	appdf.req(appdf.CLIENT_SRC.."plaza.models.GlobalUserItem")
end

local QueryDialog = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.QueryDialog")
local PopWait = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.PopWait")

local CheckinFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.CheckinFrame")
local RequestManager = appdf.req(appdf.CLIENT_SRC.."plaza.models.RequestManager")

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local HeadSprite = appdf.req(appdf.EXTERNAL_SRC .. "HeadSprite")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")

local RankingListLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.RankingListLayer")
local GameListLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.GameListLayer")
local RoomListLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.RoomListLayer")
local RoomLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.room.RoomLayer")
local PersonalInfoLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.PersonalInfoLayer")
local UserInfoLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.UserInfoLayer")
local LogonRewardLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.LogonRewardLayer")
local WelfareLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.WelfareLayer")
local NoticeLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.NoticeLayer")
local ShopLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.ShopLayer")
local OptionLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.OptionLayer")
local BankLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.BankLayer")
local BankEnableLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.BankEnableLayer")
local MySpreaderLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.MySpreaderLayer")
local CustomerServiceLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.CustomerServiceLayer")
local ActivityLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.ActivityLayer")
local RankingLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.RankingLayer")
local TaskLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.TaskLayer")
local TheChargeLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.TheChargeLayer")
local ExchangePrizeLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.ExchangePrizeLayer")
local ShareLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.ShareLayer")
local GameNotice = appdf.req(appdf.BASE_SRC .."app.views.layer.other.GameNotice")


appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.GameLoading.LoadingLayer")
appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.Common.init")
appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.GameCpp.init")

--Z序表
local ZORDER = 
{
	ROOM_LIST                               = 8,
	ROOM                                    = 9,
	GAME_LIST                               = 10,
	TRUMPET                                 = 11,
	RANK_LIST                               = 20,
	CATEGORY_LIST                           = 30,
	TOP_BAR                                 = 40,
	BOTTOM_BAR                              = 50,
    GAME_PANEL                              = 60,   
	POPUP_INFO                              = 100000,
	PANEL_RANK                              = 100001,
}

--层标签表
local LayerTag = 
{
	GAME_LIST                               = 0,
	ROOM_LIST                               = 1,
	ROOM                                    = 2,
}

local targetPlatform = cc.Application:getInstance():getTargetPlatform()

--push层标签
function ClientScene:pushLayerTag(layerTag)

	self._layerTagList[#self._layerTagList + 1] = layerTag

	return layerTag
end

--pop层标签
function ClientScene:popLayerTag()
	
	local layerTag = self._layerTagList[#self._layerTagList]

	if nil ~= layerTag then
		self._layerTagList[#self._layerTagList] = nil
	end

	return layerTag
end

--获取当前层标签
function ClientScene:getCurrentLayerTag()

	return self._layerTagList[#self._layerTagList]
end

-- 初始化界面
function ClientScene:onCreate()

	--self._clientConnectedCount = 0
	--缓存公共资源
	self:cachePublicRes()

	-- 初始化游戏列表  1040 ->516
	self._gameLists = {
		--{25, 200, 36}, --苹果审核游戏
		{  998, 19 ,2075, 13},
		{ 200, 102, 27, 36},
		--{ 510 },
		{ 26,122,140,118,998,123},
		{ 13,2075,516,2099,2068 },
        { 19,601},
	}
	if yl.APPSTORE_VERSION  then 
		self._gameLists[1] = { 601,516, 104, 140, 122, 36}
		self._gameLists[2] = { 102, 27, 36}
	end 

	--层标签列表
	self._layerTagList = {}

	--事件监听
	self:initEventListener()

	--节点事件
	ExternalFun.registerNodeEvent(self)

	--加载csb资源
	local rootLayer, csbNode = ExternalFun.loadRootCSB( "plaza/PlazaLayer.csb", self )
	local timeline = ExternalFun.loadTimeLine( "plaza/PlazaLayer.csb" )
	local areaTop = csbNode:getChildByName("area_top"):setLocalZOrder(ZORDER.TOP_BAR)
	local areaBottom = csbNode:getChildByName("area_bottom"):setLocalZOrder(ZORDER.BOTTOM_BAR)
	local areaRank = csbNode:getChildByName("area_rank"):setLocalZOrder(ZORDER.RANK_LIST)
	local areaCategory = csbNode:getChildByName("area_category"):setLocalZOrder(ZORDER.CATEGORY_LIST)
	local areaTrumpet = csbNode:getChildByName("area_trumpet"):setLocalZOrder(ZORDER.TRUMPET)
	local areaRankOpen = csbNode:getChildByName("Panel_rank_open"):setLocalZOrder(ZORDER.PANEL_RANK):setVisible(false)--排行榜展开
	local areaRankOpenBG = areaRankOpen:getChildByName("sp_rankopen_bg")
	local areaUserInfo = areaTop:getChildByName("la_playerinfo")
    local gamePanel = csbNode:getChildByName("Panel_game");


	self._layout = csbNode
	self._areaTop = areaTop
	self._areaBottom = areaBottom
	self._areaRank = areaRank
	self._areaCategory = areaCategory
	self._areaTrumpet222 = areaTrumpet
    self._gamePanel = gamePanel;
	areaTrumpet:setVisible(false)
	if self._areaTrumpet == nil then
		self._areaTrumpet =GameNotice:create("",cc.p(areaTrumpet:getPositionX(),areaTrumpet:getPositionY()))
		self._areaTrumpet:addTo(areaTrumpet:getParent())
		local str = "510游戏，提倡健康休闲的游戏理念，严禁赌博、严禁私下交易"
		self._areaTrumpet:addTrugTxt( yl.m_RepeatNotice == "" and str or yl.m_RepeatNotice, yl.m_RepeatNotice == "" and 0 or 1)
	end

	--一分钟一次广告
	if yl.noticeSchedule then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(yl.noticeSchedule)
		yl.noticeSchedule = nil
	end
	if yl.m_RepeatNotice ~= ""  and  yl.noticeSchedule == nil then
		yl.noticeSchedule = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
			local eventListener = cc.EventCustom:new("ry_GetGameNotice")
			eventListener._usedata = {["NoticeMsg"] = yl.m_RepeatNotice, ["NoticeType"] = 1}
			cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
		 end, 60, false)
	end

	self._areaRankOpen = areaRankOpen
	self._areaRankOpen_bg = areaRankOpenBG
	self._areaUserInfo = areaUserInfo
	self._bIsRankActionOver = false
	self._bIsQuickStart = false

	self._isCheckIn = false
	self._isRremoveEnterMask = false
	
	self.zz_isMoving = false
	self.z_isMoving  = false
	--播放时间轴动画
	csbNode:runAction(timeline)
	timeline:gotoFrameAndPlay(0, true)

	
	--logo
	--[[local logo = areaTop:getChildByName("sp_logo")
	if yl.APPSTORE_VERSION then
		logo:setTexture("plaza/sp_logo_appstore.png")
	end]]
	--添加一层
	self._morebuttonLayout = csbNode:getChildByName("la_more")
	self._enterMaskLayer = self._morebuttonLayout:clone()
	self._morebuttonLayout:setVisible(false)
	self._morebuttonLayout:setSwallowTouches(false)
	self._morebuttonLayout:setZOrder(ZORDER.PANEL_RANK)
	self._morebuttonLayout:addClickEventListener(function()
		print("点击")       
		if self.area_morebutton:isVisible() then
			self:onClickMoreButton()
		end
	 end)

	--遮罩层弹窗未结束大厅所有控件无法点击
	self._enterMaskLayer:setVisible(true)
	self._enterMaskLayer:setSwallowTouches(true)
	self._enterMaskLayer:addTo(self,10000)

	--引导层	0 第一次打开  1 打开过了
	
	if cc.UserDefault:getInstance():getIntegerForKey("isGuide") == 0 then
		cc.UserDefault:getInstance():setIntegerForKey("isGuide",1)
		self._guideMaskLayer = self._morebuttonLayout:clone()
		self._guideMaskLayer:setVisible(true)
		self._guideMaskLayer:setSwallowTouches(true)
		self._guideMaskLayer:addTo(self,10000)

		local contensize = self._guideMaskLayer:getContentSize()
		local sp_guide = cc.Sprite:create("plaza/zy_layer.png")
		:setPosition(cc.p(contensize.width/2,contensize.height/2))
		:addTo(self._guideMaskLayer)

		local btn_closeGuide = ccui.Button:create("plaza/zy_btn.png","")
		btn_closeGuide:setPosition(cc.p(contensize.width/2,contensize.height/2))
		btn_closeGuide:addTo(self._guideMaskLayer)
		btn_closeGuide:setTag(1)
		btn_closeGuide:addClickEventListener(function ( )
			if self.Guidschedule ~= nil then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.Guidschedule)
				self.Guidschedule = nil
			end
			self._guideMaskLayer:removeFromParent()
			self:QueryCheckIn()
		end)

		local lab_time = cc.Label:createWithTTF("", "fonts/round_body.ttf", 26)
		lab_time:setTextColor(cc.YELLOW)
		lab_time:setPosition(cc.p(202,41))
		lab_time:setTag(2)
		lab_time:addTo(btn_closeGuide)
	end
	
	--返回按钮
	self._btnBack = areaTop:getChildByName("btn_back")
	self._btnBack:setVisible(false)
				 :addClickEventListener(function() self:onClickBack() end)

	--滚动喇叭
	self._txtTrumpet = areaTrumpet:getChildByName("panel_trumpet"):getChildByName("txt_trumpet")
	self._txtTrumpet:setString("")

	--游戏列表
	self._gameListLayer = GameListLayer:create(self)
												:setContentSize(1150,550)--(908 + (yl.APPSTORE_VERSION and self._areaCategory:getContentSize().width or 0), 512)
												:setPosition(16, 82)
						--                      :setBackGroundColorType(LAYOUT_COLOR_SOLID)
						--                      :setBackGroundColor(cc.BLACK)
						--                      :setBackGroundColorOpacity(50)
												:addTo(self._layout, ZORDER.GAME_LIST)
	--房间列表
	self._roomListLayer = RoomListLayer:create(self)
												:setVisible(false)
												:addTo(self._layout, ZORDER.ROOM_LIST)
	--房间
	self._roomLayer = RoomLayer:create(self):setVisible(false)
										:addTo(self._layout, ZORDER.ROOM)

	--排行榜分类按钮
	self._rankCategoryBtns = {}
	--[[for i = 1, 2 do
		local btnRankCategory = areaRank:getChildByName("btn_rank_category_" .. i)
		btnRankCategory:addEventListener(function(ref, type)
			self:onClickRankCategory(i)
		end)

		self._rankCategoryBtns[i] = btnRankCategory
	end

	self.isShowRank = true;

	self.rank_btn = ccui.Button:create("plaza/btn_l.png")
	self.rank_btn:setPosition(self._areaRank:getContentSize().width+17, self._areaRank:getContentSize().height/2)
	self.rank_btn:addClickEventListener(function() 
	print("点击------")
		self:onClickRankShow(self.isShowRank)

	end)
	self.rank_btn:addTo(self._areaRank)
	

	self._areaCategory:setVisible(not yl.APPSTORE_VERSION)]]

	--排行榜列表
	--[[self._rankListLayer = RankingListLayer:create(cc.size(105, 355))
								:setDelegate(self)
								:setAnchorPoint(0, 0)
								:setPosition(9, 70)
								:addTo(areaRank)]]

	--隐藏排行榜
	if yl.APPSTORE_VERSION then
		self._areaRank:setVisible(false)
	end

	--排行榜展开按钮
	--[[local btn_rank_open = areaRank:getChildByName("btn_rank_open")
	btn_rank_open:addClickEventListener(function ()
		if self._bIsRankActionOver then
			self:onClickRankOpen()
		end
	end)]]
	self._isOpenRank = false;
	self:requestRankStatus()
	--底部排行榜按钮
	self.btn_rankopen_down = areaBottom:getChildByName("btn_rank")
	self.btn_rankopen_down:addClickEventListener(function ()
			--self:onClickRankOpen()
			--ExternalFun.playClickEffect()
			--showPopupLayer(RankingLayer:create(self))
			--self:getApp()._funList.EnjoinRanking == 0 and 
			if self._isOpenRank then
				showPopupLayer(RankingLayer:create(self))
			else
			 	QueryDialog:create("排行榜暂未开放，请持续关注游戏动态！", nil, nil, QueryDialog.QUERY_SURE):addTo(self)
			end
	end)
	--排行榜收缩按钮
	--[[local btn_rank_shrink = areaRankOpen:getChildByName("btn_rank_shrink")
	btn_rank_shrink:addClickEventListener(function ()
		if self._bIsRankActionOver then
			self:onClickRankOpen()
		end
	end)
	areaRankOpen:getChildByName("Panel_touchclose"):addClickEventListener(function ()
		if self._bIsRankActionOver then
			self:onClickRankOpen()
		end
	end)]]
	--游戏分类按钮
	self._gameCategoryBtns = {}
	for i = 1, 5 do
		local btnGameCategory = areaCategory:getChildByName("btn_category_" .. i)
		btnGameCategory:addEventListener(function(ref, type)
			self:onClickGameCategory(i, true)
		end)

		self._gameCategoryBtns[i] = btnGameCategory
	end

	--创建活动
	--self._activityLayer = ActivityLayer:create()
	--活动按钮
	local btnActivity = self._areaBottom:getChildByName("btn_activity")
	btnActivity:setVisible(not yl.APPSTORE_VERSION)
	btnActivity:addClickEventListener(function()

		--播放音效
		--ExternalFun.playClickEffect()

		--QueryDialog:create("活动暂未开放，请持续关注游戏动态！", nil, nil, QueryDialog.QUERY_SURE):addTo(self)

		showPopupLayer(ActivityLayer:create())
	end)

	
	--福利按钮
	--[[local btnWelfare = self._areaTop:getChildByName("btn_welfare")
	btnWelfare:setVisible(not yl.APPSTORE_VERSION)
	btnWelfare:addClickEventListener(function()

		--播放音效
		ExternalFun.playClickEffect()

		showPopupLayer(WelfareLayer:create())
	end)]]

	--福利动画
	--local aniWelfare = self._areaTop:getChildByName("sp_welfare_ani")
	--aniWelfare:setVisible(not yl.APPSTORE_VERSION)
	self.area_morebutton = self._areaBottom:getChildByName("sp_morebg")
	self.area_morebutton:setTexture("plaza/botbarMoreBG.png")
	--注销按钮
	local btn_exit = self.area_morebutton:getChildByName("btn_exit")
	btn_exit:loadTextureNormal("plaza/botMoreBtn_1.png")
	btn_exit:addClickEventListener(function ()
		--播放音效
		ExternalFun.playClickEffect()
		QueryDialog:create("是否返回到登陆界面？",function(bReTry)
					if bReTry == true then
						self:onSwitchAccount()
					end
				end)
				:addTo(self)
		
	end)
	--公告按钮
	local btnNotice = self._areaBottom:getChildByName("btn_notice")
	btnNotice:setVisible(not yl.APPSTORE_VERSION)
	btnNotice:addClickEventListener(function()

		--播放音效
		ExternalFun.playClickEffect()

		showPopupLayer(NoticeLayer:create())
	end)

	-- --客服按钮
	local btnService = self.area_morebutton:getChildByName("btn_service")
	--btnService:setPosition(cc.p(btn_exit:getPositionX(),btn_exit:getPositionY()))
	btnService:addClickEventListener(function()
		ExternalFun.playClickEffect()
		showPopupLayer(CustomerServiceLayer:create())
		--CustomerServiceLayer:create():addTo(self)
	end)
	--设置按钮
	local btnSetting = self.area_morebutton:getChildByName("btn_setting")
	btnSetting:addClickEventListener(function()

		--播放音效
		ExternalFun.playClickEffect()

		showPopupLayer(OptionLayer:create(self))
	end)

	--更多按钮
	local btn_more = self._areaBottom:getChildByName("btn_more")
	btn_more:addClickEventListener(function()
		ExternalFun.playClickEffect()
		self:onClickMoreButton()
		--self.area_morebutton:setVisible(not self.area_morebutton:isVisible())
	end)
	
	--首充按钮
	self.btnFirstRecharge = self._areaTop:getChildByName("btn_change")
	self.btnFirstRecharge:addClickEventListener(function ()
		 --播放音效
		ExternalFun.playClickEffect()

		showPopupLayer(TheChargeLayer:create(self))
	end)
	--转盘按钮 
	self.btnRunner = self._areaTop:getChildByName("btn_duobao")
	self.btnRunner:addClickEventListener(function ()
		 --播放音效
		ExternalFun.playClickEffect()
		if nil == self._checkInFrame then
			self._checkInFrame = CheckinFrame:create(self, function(result, msg, subMessage)
				if result == 1 then
				end
				self._checkInFrame:onCloseSocket()
				self._checkInFrame = nil
			end)
		end
		self._checkInFrame:onCloseSocket()
		--查签到信息
		self._checkInFrame:onCheckinQuery()
		if GlobalUserItem.bLotteryConfiged then
			--显示领奖页面
			showPopupLayer(LogonRewardLayer:create(), getPopupMaskCount() == 0)
		else
			--转盘还没配置，获取转盘数据
			showPopWait()
			RequestManager.requestLotteryConfig(function(result, message)               
				dismissPopWait()
				if result == 0 then
					--显示领奖页面
					showPopupLayer(LogonRewardLayer:create(), getPopupMaskCount() == 0)
				end
			end)
		end
	end)

	--分享按钮
	self.btn_share = self._areaTop:getChildByName("btn_share")
	self.btn_share:addClickEventListener(function()
		ExternalFun.playClickEffect()
		showPopupLayer(ShareLayer:create())
	end)

	--任务按钮
	self.btnTask = self._areaBottom:getChildByName("btn_task")
	self.btnTask:addClickEventListener(function()
			--播放音效
			ExternalFun.playClickEffect()
			if self:getApp()._funList.EnjoinTask == 0 then
				showPopupLayer(TaskLayer:create())
			else
				QueryDialog:create("任务暂未开放，请持续关注游戏动态！", nil, nil, QueryDialog.QUERY_SURE):addTo(self)
			end        
		end)

	--商城按钮
	self.btnShop = self._areaBottom:getChildByName("btn_shop")
	self.btnShop:addClickEventListener(function()

		--播放音效
		ExternalFun.playClickEffect()

		ShopLayer:create():addTo(self)
	end)
	jsonName = 'plaza/spine/skeleton.json'
	atlasName = 'plaza/spine/skeleton.atlas'
	local btnShopNode = sp.SkeletonAnimation:create(jsonName, atlasName, 1.0)
	:setPosition(cc.p(0,self.btnShop:getContentSize().height))
	:addTo(self.btnShop)
	:setAnimation(0, "animation", true)
	--商城动画
	self:shopAction()

	--银行按钮
	self.btnBank = self._areaBottom:getChildByName("btn_bank")
	self.btnBank:addClickEventListener(function()
		-- if self:getApp()._funList == nil then
		-- 	self:getApp()._funList = {}
		-- end
		-- if self:getApp()._funList.GiveModule ~= 2 or self:getApp()._funList.GiveModule  ~= 1 then
		-- 	self:getApp()._funList.GiveModule  = 2
		-- end
		--播放音效
		ExternalFun.playClickEffect()

		if GlobalUserItem.cbInsureEnabled == 0 then
			showPopupLayer(BankEnableLayer:create(function()
				BankLayer:create(2):addTo(self)
			end))
		else
			BankLayer:create(2):addTo(self)
		end
	end)

	--兑换按钮
	self.btn_exchange = self._areaBottom:getChildByName("btn_exchange")
	self.btn_exchange:addClickEventListener(function()
		--ExternalFun.playClickEffect()
		self._exchange = ExchangePrizeLayer:create()
		showPopupLayer(self._exchange)
		end)

	--头像按钮
	local btnAvatar = self._areaUserInfo:getChildByName("btn_avatar")
	btnAvatar:addClickEventListener(function()
		
		if yl.APPSTORE_VERSION == false then 
			self:onClickAvatar()			
		end 
	end)

	--vip
	self.img_viplv = self._areaUserInfo:getChildByName("sp_VIP_lv")

	--复制ID
	self.btnCopyID = self._areaUserInfo:getChildByName("btn_copyid")
	self.btnCopyID:addClickEventListener(function()
		
		--播放音效
		ExternalFun.playClickEffect()
		if cc.PLATFORM_OS_WINDOWS == targetPlatform then
			local str = ""..GlobalUserItem.dwGameID
			WindowsCopy(str)
		else
			MultiPlatform:getInstance():copyToClipboard("昵称："..GlobalUserItem.szNickName.."，ID："..GlobalUserItem.dwGameID)
		end

		
		showToast(nil, "已复制到剪贴板", 2)
	end)
	
	--推荐人
	--[[local btnSpreader = self._areaBottom:getChildByName("btn_spreader")
	btnSpreader:addClickEventListener(function()
		
		--播放音效
		ExternalFun.playClickEffect()

		showPopupLayer(MySpreaderLayer:create())
	end)
	--隐藏推荐人按钮
	btnSpreader:setVisible(false)]]

	--增加游戏币按钮
	local btnAddGold = self._areaUserInfo:getChildByName("area_gold_info"):getChildByName("btn_add_gold")
	btnAddGold:addClickEventListener(function()

		--播放音效
		ExternalFun.playClickEffect()

		ShopLayer:create(2):addTo(self)
	end)

	--增加游戏豆按钮
	local btnAddBean = self._areaUserInfo:getChildByName("area_bean_info"):getChildByName("btn_add_bean")
	btnAddBean:addClickEventListener(function()
		
		--播放音效
		ExternalFun.playClickEffect()

		showPopupLayer(ExchangePrizeLayer:create())
	end)

	--妹纸呢
	self._youngsister = self._layout:getChildByName("Image_girl")
	self._youngsister:loadTexture("plaza/img_girl.png")
	--self._youngsister:setTouchEnabled(true)
	self._zClickCount = 0
	self._zIsShowCai = false
	self._youngsister:addClickEventListener(function()
		--print("妹子来了。。。。 妹子额")
		if self._zIsShowCai == false then
			--if type == ccui.TouchEventType.ended then
				self._zClickCount = self._zClickCount+1
				if self._zClickCount >=10 then
					
					self._zClickCount = 0
					self._youngsister:runAction(cc.Sequence:create(cc.CallFunc:create(function (  )
						self._youngsister:loadTexture("plaza/girl_1.png")
						self._zIsShowCai= true
					end),cc.DelayTime:create(2.0),
					cc.CallFunc:create(function (  )
						self._youngsister:loadTexture("plaza/img_girl.png")
						self._zIsShowCai= false
					end),nil))
				end
			--end
		end
		
	end)
	self._youngsister:setVisible(false)
	
	--背景
	self._plazaBg = self._layout:getChildByName("sp_plaza_bg")
	
	--保存初始坐标(动画用)
	self._ptAreaRank = cc.p(self._areaRank:getPosition())
	self._ptAreaCategory = cc.p(self._areaCategory:getPosition())
	self._ptGameListLayer = cc.p(self._gameListLayer:getPosition())
	self._ptAreaBottom = cc.p(self._areaBottom:getPosition())
	self._ptYoungSister = cc.p(self._youngsister:getPosition())
	self._ptUserInfo = cc.p(self._areaUserInfo:getPosition())

	--
	local a22 =self._gamePanel:getChildByName("gameTag2")
	local a33 =self._gamePanel:getChildByName("gameTag3")
	local a44 =self._gamePanel:getChildByName("gameTag4")
	local a55 =self._gamePanel:getChildByName("gameTag5")
	local a66 =self._gamePanel:getChildByName("gameTag6")
	local a77 =self._gamePanel:getChildByName("gameTag7")
	local gameA = {a22,a33,a44,a55,a66,a77}
	for i=1,6 do
		local emitter_1 = cc.ParticleSystemQuad:create("plaza/particle_star11.plist")  
		emitter_1:setAutoRemoveOnFinish(true)    --设置播放完毕之后自动释放内存  
		emitter_1:setPosition(cc.p(a22:getContentSize().width/2,a22:getContentSize().height/2))  
		gameA[i]:addChild(emitter_1,102)  
	end
	 --棋牌按钮特效
	jsonName = 'GameList/spine/lhd.json'
	atlasName = 'GameList/spine/lhd.atlas'
	local chessEffectNode = sp.SkeletonAnimation:create(jsonName, atlasName, 1.0)
	:setPosition(cc.p(a22:getPositionX()-a22:getContentSize().width/2,a22:getPositionY()+120))
	:addTo(self._gamePanel,-1)
	:setAnimation(0, "animation", true)
	 
	 jsonName = 'GameList/spine/pjl.json'
	 atlasName = 'GameList/spine/pjl.atlas'
	 local chessEffectNode = sp.SkeletonAnimation:create(jsonName, atlasName, 1.0)
	 :setPosition(cc.p(a33:getPositionX()-a33:getContentSize().width/2,a33:getPositionY()+120))
	 :addTo(self._gamePanel,-1)
	 :setAnimation(0, "animation", true)
	
	jsonName = 'GameList/spine/tbnn.json'
	atlasName = 'GameList/spine/tbnn.atlas'
	local chessEffectNode = sp.SkeletonAnimation:create(jsonName, atlasName, 1.0)
	:setPosition(cc.p(a44:getPositionX()-a44:getContentSize().width/2,a44:getPositionY()+120))
	:addTo(self._gamePanel,-1)
	:setAnimation(0, "animation", true)
	 
	 jsonName = 'GameList/spine/lkpy.json'
	 atlasName = 'GameList/spine/lkpy.atlas'
	 local chessEffectNode = sp.SkeletonAnimation:create(jsonName, atlasName, 1.0)
	 :setPosition(cc.p(a55:getPositionX()-a55:getContentSize().width/2,a55:getPositionY()+120))
	 :addTo(self._gamePanel,-1)
	 :setAnimation(0, "animation", true)
	 
	jsonName = 'GameList/spine/xzw.json'
	atlasName = 'GameList/spine/xzw.atlas'
	local chessEffectNode = sp.SkeletonAnimation:create(jsonName, atlasName, 1.0)
	:setPosition(cc.p(a66:getPositionX()-a66:getContentSize().width/2,a66:getPositionY()+120))
	:addTo(self._gamePanel,-1)
	:setAnimation(0, "animation", true)

	jsonName = 'GameList/spine/ernn.json'
	atlasName = 'GameList/spine/ernn.atlas'
	local chessEffectNode = sp.SkeletonAnimation:create(jsonName, atlasName, 1.0)
	:setPosition(cc.p(a77:getPositionX()-a77:getContentSize().width/2,a77:getPositionY()+120))
	:addTo(self._gamePanel,-1)
	:setAnimation(0, "animation", true)


	-- local url = "http://thirdwx.qlogo.cn/mmopen/vi_32/PiajxSqBRaEJuZtpjT9evaIhfQ8KDXdiahicshndcSzZELkS0XnhtiaTegEnSbaxCiamJBb4Nib6opUxV2XFjCrYPSOA/132"
	-- appdf.onHttpImage(url,function(aa)
	-- 	print("aaaaaaaaaaadfsfdsf")
	-- 	end)
	--首充按钮隐藏
	self:isFirstPayUser()
	--更新用户信息
	self:onUpdateUserInfo()

	--注册通知
	self:registerListenerClient()
	--更新在线人数
	--self:onUpdateOnlineCount()
	--滚动播放
	self:RollingPlaybackEvent()
	--初始化游戏列表
	self:onClickGameCategory(1)

	--查询滚动公告
	--self:requestRollNotice()

	--查询签到信息
	--self:requestCheckinInfo()
	
	--self:showTypeTips()
	--滚起来吧
	--self:RollingGamePanel()
	--审核状态 
	if yl.APPSTORE_VERSION  then 
		self:onPassReview()
		--马甲包特殊处理
		if yl.IS_MAJIA then
			self:onClickGame(200)
		end 
	end 
	--安卓马夹包
	if yl.IS_ANDROID_MAJIA ==true then
		self:onClickGameByAndroidMajia(200)
		self:onPassReviewByAndroid()
	end
	--播放粒子效果
	local emitter1 = cc.ParticleSystemQuad:create("plaza/particle_guangYing.plist")  
	emitter1:setAutoRemoveOnFinish(true)    --设置播放完毕之后自动释放内存  
	emitter1:setPosition(cc.p(display.cx,display.cy))  
	self._layout:addChild(emitter1,1)  
	--sc粒子
	local emitter_sc = cc.ParticleSystemQuad:create("plaza/particle_jbgg.plist")  
	emitter_sc:setAutoRemoveOnFinish(true)    --设置播放完毕之后自动释放内存  
	emitter_sc:setPosition(cc.p(self.btnFirstRecharge:getContentSize().width/2,self.btnFirstRecharge:getContentSize().height/2))  
	self.btnFirstRecharge:addChild(emitter_sc,102)  

	local emitter_Runner = cc.ParticleSystemQuad:create("plaza/main_button_particle.plist")  
	emitter_Runner:setAutoRemoveOnFinish(true)    --设置播放完毕之后自动释放内存  
	emitter_Runner:setPosition(cc.p(self.btnRunner:getContentSize().width/2,self.btnRunner:getContentSize().height/2))  
	self.btnRunner:addChild(emitter_Runner,102)  

	local emitter_share = cc.ParticleSystemQuad:create("plaza/main_button_particle.plist")  
	emitter_share:setAutoRemoveOnFinish(true)    --设置播放完毕之后自动释放内存  
	emitter_share:setPosition(cc.p(self.btn_share:getContentSize().width/2,self.btn_share:getContentSize().height/2))  
	self.btn_share:addChild(emitter_share,102)  
	
	local emitter2 = cc.ParticleSystemQuad:create("plaza/particleStarRedMoney.plist")  
	emitter2:setAutoRemoveOnFinish(true)    --设置播放完毕之后自动释放内存  
	emitter2:setPosition(cc.p(-20,display.cy))  
	self._layout:addChild(emitter2,1)  

	

	-- self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
	-- 	local emitter_gun = cc.ParticleSystemQuad:create("plaza/gungun.plist")  
    --         emitter_gun:setAutoRemoveOnFinish(true)  
    --         emitter_gun:setPosition(cc.p(game3:getContentSize().width/2,game3:getContentSize().height/2-110))  
    --         game3:addChild(emitter_gun,102)  
	-- end)))
	--查询活动状态
	--self:requestQueryActivityStatus()
	
    game.setGameFrameEngine(self._roomLayer._gameFrame)
    ds.MyNotification:getInstance():registerLuaEventCallBack("room_event",game.RoomNotificationCallBack)
   -- 
end

function ClientScene:showTypeTips(  )
	
	local t_tips = cc.UserDefault:getInstance():getStringForKey("tipsTime")
	if t_tips == "" then
		cc.UserDefault:getInstance():setStringForKey("tipsTime",os.time() )
		local tipsCount = 1
	
			self.m_tips = self._areaCategory:getChildByName("img_tips")
			self.m_tips:setVisible(true)
			self.m_tips:runAction(  cc.Repeat:create(cc.Sequence:create(cc.MoveBy:create(0.4,cc.p(-40,0)),cc.MoveBy:create(0.4,cc.p(40,0)),cc.CallFunc:create(function (  )
				tipsCount = tipsCount + 1 
				if tipsCount >= 4 then
					self.m_tips :setVisible(false)
				end
			end)),3)   )
	else
		local t_cha = tonumber(t_tips) - os.time()
		if t_cha > 86400 then
			return
		else
			local tipsCount = 1
	
			self.m_tips = self._areaCategory:getChildByName("img_tips")
			self.m_tips:setVisible(true)
			self.m_tips:runAction(  cc.Repeat:create(cc.Sequence:create(cc.MoveBy:create(0.4,cc.p(-40,0)),cc.MoveBy:create(0.4,cc.p(40,0)),cc.CallFunc:create(function (  )
				tipsCount = tipsCount + 1 
				if tipsCount >= 4 then
					self.m_tips :setVisible(false)
				end
			end)),3)   )
		end
	end
	
end

function ClientScene:registerListenerClient()

    local dispacther = cc.Director:getInstance():getEventDispatcher()
	dispacther:addEventListenerWithSceneGraphPriority(
        cc.EventListenerCustom:create("ry_WebClose", handler(self, self.backLogonScene)),
        self
		)
	dispacther:addEventListenerWithSceneGraphPriority(
        cc.EventListenerCustom:create("ry_GetGameNotice", handler(self, self.NoticeCallBack)),
        self
		)
	dispacther:addEventListenerWithSceneGraphPriority(
        cc.EventListenerCustom:create("ry_GetNetNotice", handler(self, self.NoticeCallBack)),
        self
		)
	dispacther:addEventListenerWithSceneGraphPriority(
    cc.EventListenerCustom:create("ry_WebConnectGame", handler(self, self.backLogonGame)),
    self
	)
	
	dispacther:addEventListenerWithSceneGraphPriority(
        cc.EventListenerCustom:create("ry_GameLeaveForWebClose", handler(self, self.GameLeaveForWebClose)),
        self
		)
	dispacther:addEventListenerWithSceneGraphPriority(
        cc.EventListenerCustom:create("ry_EnterBackWebClose", handler(self, self.EnterbackLogonScene)),
        self
		)
		
end

--gamelist滚动起来吧／／
function ClientScene:RollingGamePanel()
	--self._gamePanel
	local animation =cc.Animation:create()
	for i=1,36 do  						
		local frameName =string.format("plaza/5/bkuang500%02d.png",i-1) 
		local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrameByName(frameName)
		animation:addSpriteFrame(spriteFrame)
	end   
	animation:setDelayPerUnit(0.05)        
	animation:setRestoreOriginalFrame(true) 
	
	self.tagame1X = self._gamePanel:getChildByName("gameTag1"):getPositionX()
	self.tagame1Y = self._gamePanel:getChildByName("gameTag1"):getPositionY()

	local baseX = self._gamePanel:getChildByName("gameTag4"):getPositionX()+141
	self._gamePanel:getChildByName("Sprite_1"):setZOrder(10)
	self._itemmaxcount = 4
	self.posindex = {}
	self.tab_clickgame = {29,28,20,21}
	self.tab_game = {"gameTag1","gameTag2","gameTag3","gameTag4"}

	local game1 = self._gamePanel:getChildByName("gameTag1");
    local game2 = self._gamePanel:getChildByName("gameTag2");
    local game3 = self._gamePanel:getChildByName("gameTag3");
    local game4 = self._gamePanel:getChildByName("gameTag4");
       
	game1:addClickEventListener(function()
		if self.zz_isMoving == true then
			return
		end
        if not self._gameListLayer._isClickGame then
            self._gameListLayer._isClickGame = true
            self._gameListLayer:onClickGame(998)
        end
    end)
        
	game2:addClickEventListener(function()
		if self.zz_isMoving == true then
			return
		end
        if not self._gameListLayer._isClickGame then
            self._gameListLayer._isClickGame = true
            self._gameListLayer:onClickGame(14)
        end
    end)
	game3:addClickEventListener(function()
		if self.zz_isMoving == true then
			return
		end
        if not self._gameListLayer._isClickGame then
            self._gameListLayer._isClickGame = true
            self._gameListLayer:onClickGame(2075)
        end
    end)
	game4:addClickEventListener(function()
		if self.zz_isMoving == true then
			return
		end
        if not self._gameListLayer._isClickGame then
            self._gameListLayer._isClickGame = true
            self._gameListLayer:onClickGame(27)
        end
	end)
		
	for i = 1, self._itemmaxcount do 
		local str = "plaza/lslide_"..tostring(i)..".png"
	    local btn = ccui.Button:create(str,str,str)
		btn:setName("gameTag"..i+4)
	    btn:setAnchorPoint(cc.p(0,0))
	    btn:move(cc.p(baseX + (i-1)*250 , -4))
		
		btn:setTag(self.tab_clickgame[i])
		btn:addClickEventListener(function ()
			if self.zz_isMoving == true then
				return
			end
			if not self._gameListLayer._isClickGame then
				self._gameListLayer._isClickGame = true
				self._gameListLayer:onClickGame(self.tab_clickgame[i])
			end

		end)
		btn:addTo(self._gamePanel)
		local sp = cc.Sprite:create("plaza/alpha.png")
        sp:setPosition(cc.p(btn:getContentSize().width/2,btn:getContentSize().height/2))
        sp:addTo(btn,10)
        
	    local action =cc.Animate:create(animation)
		sp:runAction(cc.RepeatForever:create(action))
		
		table.insert(self.posindex, baseX + (i-1)*250)
		table.insert(self.tab_game, "gameTag"..i+4)
	end

	self:layoutActionByZ()
	self:onTouchEventListenerByZ()
end

function ClientScene:layoutActionByZ(  )
	for i=1,#self.tab_game do	
		local moveDistance = 184 + 250 * (self._itemmaxcount - 1)
		local z_move1 = cc.MoveBy:create(10,cc.p(-moveDistance,0))
		local z_delayTime = cc.DelayTime:create(2.0)
		local z_backPos = cc.MoveBy:create(10,cc.p(moveDistance,0))
		local z_delayTime2 = cc.DelayTime:create(2.0)
		local z_Action = cc.RepeatForever:create(cc.Sequence:create(z_move1,z_delayTime,z_backPos,z_delayTime2))					
		local btn = self._gamePanel:getChildByName(self.tab_game[i])
		btn:runAction(z_Action)
	end	
end

function ClientScene:onTouchEventListenerByZ()
	local function onTouchBegan(touch,event)
    	local locationInNode = self:convertToNodeSpace(touch:getLocation())
    	local size = self._gamePanel:getContentSize()
    	local rect = cc.rect(16,85,size.width,size.height)
    	--print("================",self.b_ismoveing,cc.rectContainsPoint(rect,locationInNode))
    	if cc.rectContainsPoint(rect,locationInNode)  then
			--print("lskjfslkdfjlsdjflsdkfj")
			for i=1,#self.tab_game do				
				local btn = self._gamePanel:getChildByName(self.tab_game[i])
				btn:stopAllActions()
			end
    		return true
    	end
    	return false
    end

	local function onTouchMoved(touch,event)   
		self.z_isMoving = false
		for i=1,#self.tab_game do				
			local btn = self._gamePanel:getChildByName(self.tab_game[i])
			btn:stopAllActions()
		end 
		local x = self._gamePanel:getChildByName(self.tab_game[1]):getPositionX()
		local y = self._gamePanel:getChildByName(self.tab_game[1]):getPositionY()
		local ofDistance = 184 + 250 * (self._itemmaxcount - 1)
		local locationInNode = self:convertToNodeSpace(touch:getLocation())	
		local delta = touch:getDelta()
		local deltax = delta.x
		local deltay = delta.y
		if deltax ~=0 then
			self.z_isMoving = true
		end
	
		if deltax > 2 then --向右
			if  x   >= self.tagame1X  then
				return
			end		
		elseif deltax < -2 then	--向左
			if  x <= self.tagame1X - ofDistance then
				return
			end			
		end
		for i=1,#self.tab_game do				
			local btn = self._gamePanel:getChildByName(self.tab_game[i])
			btn:setPosition(cc.p(btn:getPositionX()+deltax,btn:getPositionY()))
		end
    
    end

    local function onTouchEnded(touch, event)
    	if self.z_isMoving == true then
			self.zz_isMoving = true
			self.z_isMoving = false
		else
			self.zz_isMoving = false
		end
    end

	self._clipLayout = ccui.Layout:create()
			:setSwallowTouches(true)
			:setContentSize(cc.size(1200,540))
			:setAnchorPoint(cc.p(0,0))
			:move(cc.p(0,0))
			:addTo(self._gamePanel,11)

	self.m_Listener =  cc.EventListenerTouchOneByOne:create()
	--self.m_Listener:setSwallowTouches(true)
    self.m_Listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    self.m_Listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)
    self.m_Listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
	local dispacther = cc.Director:getInstance():getEventDispatcher()
    dispacther:addEventListenerWithSceneGraphPriority(self.m_Listener, self._clipLayout)
end

--滚动播放
function ClientScene:RollingPlaybackEvent()

	local btcallback = function(ref, eventtype)
		local tag = ref:getTag()
		print(tag)
        if eventtype == ccui.TouchEventType.ended then
         	if tag == 1 then
				if not self._isClickGame then
					self._gameListLayer._isClickGame = true
					self._gameListLayer:onClickGame(20)
				end
			elseif tag == 2 then
				if not self._isClickGame then
	                self._gameListLayer._isClickGame = true
					self._gameListLayer:onClickGame(2075)
				end
			elseif tag == 3 then
				if not self._isClickGame then
	                self._gameListLayer._isClickGame = true
					self._gameListLayer:onClickGame(32)
				end
				-- local activitylayer = ActivityLayer:create()
				-- dump(activitylayer._activityList)
				-- showPopupLayer(activitylayer)
				-- for i = 1, #activitylayer._activityList do
				-- 	if activitylayer._activityList[i].ActivityID == 2004 then
				-- 		print("活动")
				-- 		activitylayer:onClickImage(i)
				-- 	end
				-- end
			end
        end
    end

	self._rollLayout = ccui.Layout:create()
		:setContentSize(cc.size(284,465))
		:setClippingEnabled(true)
		:setAnchorPoint(cc.p(0,0))
		-- :setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
		-- :setBackGroundColor(cc.BLACK)
		:move(cc.p(50,110))
		:addTo(self._layout,7)
	self._itemmaxcount = 3
	self.posindex = {}
	for i = 1, self._itemmaxcount do 
		local str = "plaza/slideGameIMG"..tostring(i)..".png"
       cc.Sprite:create(str)
       	:setTag(i)
       	:setAnchorPoint(cc.p(0,0))
       	:move(cc.p((i - 1)*284,  0))
       	:addTo(self._rollLayout)
       table.insert(self.posindex, (i - 1)*284)
	end
	self._curbtnTag = 1
	self:layoutAction()
	self:onTouchEventListener()
end
--容器动画
function ClientScene:layoutAction()
	--local moveposy = {{0, -546, -946}, {546, 0, -546}, {-546, 546, 0}}
	--local moveposy = {{0, 546, 946}, {946, 0, 546}, {546, 946, 0}}
	local action = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(5),cc.CallFunc:create(function()
			self.b_ismoveing = true
			self._curbtnTag = self._curbtnTag + 1
			if self._curbtnTag > self._itemmaxcount then
				self._curbtnTag = 1
			end
			local lastpos = self.posindex[#self.posindex]
			table.remove(self.posindex,#self.posindex)
			table.insert(self.posindex,1,lastpos)
			-- for i = #posindex, 1, -1 do
			-- 	if i ~= 1 then 
			-- 		posindex[i] = posindex[i - 1]
			-- 	else
			-- 		posindex[i] = lastpos
			-- 	end
			-- end
			for i = 1, self._itemmaxcount do 
				local btn = self._rollLayout:getChildByTag(i)
				btn:runAction(cc.Sequence:create(cc.MoveBy:create(0.2,cc.p(-284, 0)),cc.CallFunc:create(function()
					btn:move(cc.p(self.posindex[i],0))--moveposy[curindex][i]))
					-- local offset = curindex - i
					-- if curindex == maxcount and i == 1 then
					-- 	offset = -1
					-- end
					-- btn:move(cc.p(0,offset * 546))
					if i == self._itemmaxcount then
						self.b_ismoveing = false
					end
				end)))
			end
		end)))
	self._rollLayout:runAction(action)
end
--添加一个滑动
function ClientScene:onTouchEventListener(node)
	local function onTouchBegan(touch,event)
    	local locationInNode = self:convertToNodeSpace(touch:getLocation())
    	local size = self._rollLayout:getContentSize()
    	local rect = cc.rect(40,122,size.width,size.height)
    	print("================",self.b_ismoveing,cc.rectContainsPoint(rect,locationInNode))
    	if cc.rectContainsPoint(rect,locationInNode) and not self.b_ismoveing then
    		print("lskjfslkdfjlsdjflsdkfj")
    		return self._rollLayout:isVisible()
    	end
    	return false
    end

    local function onTouchMoved(touch,event)    	
        local delta = touch:getDelta()  
        local deltax = delta.x
        local deltay = delta.y
    	if deltax > 2 then --向上划动
            self.bMove = true
            self.bMoveUp = true
            self._rollLayout:stopAllActions()
    	elseif deltax < -2 then --向下滑动 
            self.bMove = true               
            self.bMoveUp = false
            self._rollLayout:stopAllActions()
    	end
    end

    local function onTouchEnded(touch, event)
    	if self.bMove then
    		self.b_ismoveing = true
    		if self.bMoveUp then
    			local curtag = self._curbtnTag
    			self._curbtnTag = self._curbtnTag - 1
				if self._curbtnTag < 1 then
					self._curbtnTag = self._itemmaxcount 
				end

    			local lastpos = self.posindex[1]
				table.remove(self.posindex, 1)
				table.insert(self.posindex, lastpos)
				--动画播放前做一次坐标调整				
				for i = 1, self._itemmaxcount do					
					--if curtag ~= i then						
						local btn = self._rollLayout:getChildByTag(curtag)
						btn:move(cc.p( (i - 1) * -284,0))
					--end
					curtag = curtag - 1
					if curtag < 1 then
						curtag = 3
					end
				end
				

	            for i = 1, self._itemmaxcount do 
					local btn = self._rollLayout:getChildByTag(i)
					btn:runAction(cc.Sequence:create(cc.MoveBy:create(0.2,cc.p(284, 0)),cc.CallFunc:create(function()
						--btn:move(cc.p(0,self.posindex[i]))
						if i == self._itemmaxcount then
							self:layoutAction()
							self.b_ismoveing = false
						end
						
					end)))
				end
    		else
    			self._curbtnTag = self._curbtnTag + 1
				if self._curbtnTag > self._itemmaxcount then
					self._curbtnTag = 1
				end
	    		local lastpos = self.posindex[#self.posindex]
				table.remove(self.posindex,#self.posindex)
				table.insert(self.posindex,1,lastpos)
	            for i = 1, self._itemmaxcount do 
					local btn = self._rollLayout:getChildByTag(i)
					btn:runAction(cc.Sequence:create(cc.MoveBy:create(0.2,cc.p(-284,0 )),cc.CallFunc:create(function()
						btn:move(cc.p(self.posindex[i],0))
						if i == self._itemmaxcount then
							
							self:layoutAction()
							self.b_ismoveing = false
						end
					end)))
				end
			end
    	else
    		if self._curbtnTag == 1 then
				if not self._gameListLayer._isClickGame then
					self._gameListLayer._isClickGame = true
					self._gameListLayer:onClickGame(20)
				end
			elseif self._curbtnTag == 2 then
				if not self._gameListLayer._isClickGame then
	                self._gameListLayer._isClickGame = true
					self._gameListLayer:onClickGame(2075)
				end
			elseif self._curbtnTag == 3 then
				if not self._isClickGame then
	                self._gameListLayer._isClickGame = true
					self._gameListLayer:onClickGame(32)
				end
				-- local activitylayer = ActivityLayer:create()
				-- showPopupLayer(activitylayer)
				-- for i = 1, #activitylayer._activityList do
				-- 	if activitylayer._activityList[i].ActivityID == 2004 then
				-- 		print("活动")
				-- 		activitylayer:onClickImage(i)
				-- 	end
				-- end
			end
    	end
    	self.bMove = nil
    	self.bMoveUp = nil
    end

    self.m_Listener =  cc.EventListenerTouchOneByOne:create()
    --self.m_Listener:setSwallowTouches(true)
    self.m_Listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    self.m_Listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)
    self.m_Listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)

    local dispacther = cc.Director:getInstance():getEventDispatcher()
    dispacther:addEventListenerWithSceneGraphPriority(self.m_Listener, self._rollLayout)
	-- dispacther:addEventListenerWithSceneGraphPriority(
    --     cc.EventListenerCustom:create("ry_WebClose", handler(self, self.backLogonScene)),
    --     self
	-- 	)
	-- dispacther:addEventListenerWithSceneGraphPriority(
    --     cc.EventListenerCustom:create("ry_GetGameNotice", handler(self, self.NoticeCallBack)),
    --     self
	-- 	)
	-- dispacther:addEventListenerWithSceneGraphPriority(
    -- cc.EventListenerCustom:create("ry_WebConnectGame", handler(self, self.backLogonGame)),
    -- self
	-- )
	
	-- dispacther:addEventListenerWithSceneGraphPriority(
    --     cc.EventListenerCustom:create("ry_GameLeaveForWebClose", handler(self, self.GameLeaveForWebClose)),
    --     self
	-- 	)
	-- dispacther:addEventListenerWithSceneGraphPriority(
    --     cc.EventListenerCustom:create("ry_EnterBackWebClose", handler(self, self.EnterbackLogonScene)),
    --     self
	-- 	)
		
		
end
--弹出判断
function ClientScene:onPopupPageJudge()
	if self.ddschedule then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.ddschedule)
		self.ddschedule = nil
	end
	if yl.APPSTORE_VERSION  then 
		if tolua.isnull(self._enterMaskLayer) then
		else
			self._enterMaskLayer:removeFromParent()		
		end
		return
	end 

	--当时是否签到
	local bCheckInToday = GlobalUserItem.bTodayChecked
	--是否有首冲资格
	local bFirstPay = GlobalUserItem.bFirstPay
	--活动必弹
	local activity = true
	function delaytime(func)
		self:runAction(cc.Sequence:create(
			cc.DelayTime:create(0.5),
			cc.CallFunc:create(function()
				if func then
					func()
				end
			end)
			)
		)
	end
	--如果还没签到
	if false == bCheckInToday then
		local function chenck()
			showPopupLayer(LogonRewardLayer:create(function()
				if false == bFirstPay then
					delaytime(showPopupLayer(TheChargeLayer:create(self,function (  )
						--self:showTypeTips()
					end),getPopupMaskCount() == 0))
				else
					--delaytime(showPopupLayer(ActivityLayer:create(),getPopupMaskCount() == 0))
				end
			end),getPopupMaskCount() == 0)
		end
		if GlobalUserItem.bLotteryConfiged == false then
			RequestManager.requestLotteryConfig(function(result, message)
				if result == 0 then
					--显示领奖页面
					chenck() 
				end
			end)
		else
			--显示领奖页面
			chenck() 
		end
	elseif false == bFirstPay then
		showPopupLayer(TheChargeLayer:create(self,function (  )
			--self:showTypeTips()
		end), getPopupMaskCount() == 0)
	else
		--showPopupLayer(ActivityLayer:create(),getPopupMaskCount() == 0)
	end
	if tolua.isnull(self._enterMaskLayer) then
	else
		self._enterMaskLayer:removeFromParent()		
	end
end
--有无首冲按钮
function ClientScene:isFirstPayUser()
	if GlobalUserItem.bFirstPay == true then
		self.btnFirstRecharge:setVisible(false)
		self.btnRunner:setPositionX(1075)
		self.btn_share:setPositionX(1196)
	end
end

--商城动画
function ClientScene:shopAction()
	--星光
	local sp_shop_star = self.btnShop:getChildByName("sp_shop_star")  
	sp_shop_star:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(1),cc.FadeIn:create(1),cc.RotateBy:create(1.0,90))))

	local sp_shop_action = self.btnShop:getChildByName("sp_shop_action")

	local animation =cc.Animation:create()
	for i=1,2 do  
		local frameName =string.format("sp_shop_light_%d.png",i) 
		print("frameName =%s",frameName)  
		local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrameByName(frameName)
		animation:addSpriteFrame(spriteFrame)
	end   
	animation:setDelayPerUnit(0.25)          --设置两个帧播放时间 
	animation:setRestoreOriginalFrame(true)    --动画执行后还原初始状态 
	local action =cc.Animate:create(animation)
	sp_shop_action:runAction(cc.RepeatForever:create(action))
end

--审核状态
function ClientScene:onPassReview()
	self.btnFirstRecharge:setVisible(false)
	self.btnRunner:setVisible(false)
	self._areaUserInfo:getChildByName("area_bean_info"):setVisible(false)
	self.btn_share:setVisible(false)
	self.btn_exchange:setVisible(false)
	self._areaTrumpet:setVisible(false)
	self.btnTask:setVisible(false)
	self.btnBank:setVisible(false)
	self.btn_rankopen_down:setVisible(false)
	self.btnCopyID:setVisible(false)
	self.img_viplv:setVisible(false)
	
end

--安卓马甲状态
function ClientScene:onPassReviewByAndroid(  )
	self.btnFirstRecharge:setVisible(false)
	self.btn_share:setVisible(false)
	self.btn_exchange:setVisible(false)
	self.btnTask:setVisible(false)
	self.btnBank:setVisible(false)
	self.btn_rankopen_down:setVisible(false)
	self.img_viplv:setVisible(false)
	self._areaBottom:getChildByName("btn_activity"):setVisible(false)
	self._areaBottom:getChildByName("btn_notice"):setVisible(false)
	--self._areaBottom:getChildByName("btn_service"):setVisible(false)
end

--初始化事件监听
function ClientScene:initEventListener()

	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

	--用户信息改变事件
	eventDispatcher:addEventListenerWithSceneGraphPriority(
		cc.EventListenerCustom:create(yl.RY_USERINFO_NOTIFY, handler(self, self.onUserInfoChange)),
		self
		)

	--暂时不用[CRL][2017.12.11]
	--[[--键盘监听事件
	local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(function(keyCode, event)
            if keyCode == cc.KeyCode.KEY_BACK then
               local currentLayerTag = self:getCurrentLayerTag()
               print("当前层 = "..tostring(currentLayerTag))
				--房间列表返回
				if currentLayerTag == LayerTag.ROOM_LIST then
					self:onClickBack()
					print("当前层 = "..tostring(currentLayerTag))
				elseif currentLayerTag == LayerTag.ROOM then
					if self._roomLayer._gameScene._gameLayer and self._roomLayer._gameScene._gameLayer.onQueryExitGame then
						self._roomLayer._gameScene._gameLayer:onQueryExitGame()
					end
					--self:popLayerTag()
				else
					if self.isQuery == nil then
						self.isQuery = QueryDialog:create("是否退出510游戏？",function(bReTry)
							if bReTry == true then
								os.exit(0)
							end
							self.isQuery = nil
						end)
						:addTo(self)
					end
				end
            end
            end, cc.Handler.EVENT_KEYBOARD_RELEASED )
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)--]]
end

------------------------------------------------------------------------------------------------------------
-- 事件处理

--场景切换完毕
function ClientScene:onEnterTransitionFinish()

	print("场景切换完毕")
	yl.ClientToLogon = false
	yl.CurrentScene	= yl.nowScene.Z_CLIENTSCENE
	if yl.isReExit and yl.reServerID ~= 0 and  yl.reKindID ~= 0 then
		self._enterMaskLayer:removeFromParent()
		if self._guideMaskLayer ~= nil then
			self._guideMaskLayer:removeFromParent()
		end
		self:onClickGame(yl.reKindID)
		self._roomListLayer:onQuickStartJduge(yl.reServerID,yl.reKindID)
		return
	end
	
	--引导页
	if self._guideMaskLayer ~= nil  then
		local removeGuidLayerCount = 20
		--local isRemoveMask = false
		local txt_lab = self._guideMaskLayer:getChildByTag(1):getChildByTag(2)
		txt_lab:setString(removeGuidLayerCount)
		self.Guidschedule = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
			txt_lab:setString(removeGuidLayerCount)
			if removeGuidLayerCount <1 then
				--isRemoveMask = true
				if self.Guidschedule ~= nil then
					cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.Guidschedule)
					self.Guidschedule = nil
				end
				self._guideMaskLayer:removeFromParent()
				self:QueryCheckIn()
			end	
			removeGuidLayerCount = removeGuidLayerCount - 1
		end, 1, false)
	else 
		self:QueryCheckIn()
	end

end

function ClientScene:QueryCheckIn()
	--查询签到信息
	--3秒没有请求回答 就什么也不弹并移除enterMaskLayer
	local removeMaskLayerCount = 1
	local isRemoveMask = false
	self.ddschedule = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
		if removeMaskLayerCount >= 3 then
			isRemoveMask = true
			if self.ddschedule ~= nil then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.ddschedule)
				self.ddschedule = nil
			end
			self._enterMaskLayer:removeFromParent()
		end	
		removeMaskLayerCount = removeMaskLayerCount + 1
	end, 1, false)

    if nil == self._checkInFrame then
		self._checkInFrame = CheckinFrame:create(self, function(result, msg, subMessage)
			if isRemoveMask == true then
				return
			end
            if result == 1 then
            	--请求转盘信息
				RequestManager.requestLotteryConfig( function(result, message)
					if isRemoveMask == true then
						return
					end
                	if result == 0 then
                    	--请求活动信息
                		-- RequestManager.requestQueryActivityStatus( function(result, message)
                		-- 	if isRemoveMask == true then
						-- 		return
						-- 	end
                    	-- 	if result == 0 then
                        -- 		print("活动也查完了,资源要不要下载你说了算")
                        		
    							-- self:runAction(cc.Sequence:create(
    							-- 				-- cc.DelayTime:create(0.1),
    							                --cc.CallFunc:create( function()
                                                --self:onPopupPageJudge()
    							                --end )))
                    	--	end
                    		-- 是时候弹出页面了
                        	self:onPopupPageJudge()
                		--end )
                	else
                		-- 是时候弹出页面了
                        self:onPopupPageJudge()
                	end
            	end )
            else
            	--失败继续弹页面
            	self:onPopupPageJudge()
            end
            self._checkInFrame:onCloseSocket()
            self._checkInFrame = nil
        end )
    end
    self._checkInFrame:onCloseSocket()
    -- 查签到信息
    self._checkInFrame:onCheckinQuery()
    if cc.PLATFORM_OS_WINDOWS == targetPlatform then
    	self:setWindowsCloseEvent()
    end
end




--显示商店
function ClientScene:onShowShop()
 ShopLayer:create():addTo(self)
end
--用户信息改变
function ClientScene:onUserInfoChange(event)
	
	print("----------ClientScene:onUserInfoChange------------")

	local msgWhat = event.obj
	if nil ~= msgWhat then

		if msgWhat == yl.RY_MSG_USERWEALTH then
			--更新财富
			self:onUpdateScoreInfo()
		elseif msgWhat == yl.RY_MSG_USERHEAD then
			--更新用户信息
			self:onUpdateUserInfo()
		end
	end
end

--更新用户信息
function ClientScene:onUpdateUserInfo()
	
	--设置玩家头像
	local avatar = self._areaUserInfo:getChildByName("sp_avatar")
	if nil ~= avatar then
		avatar:updateHead(GlobalUserItem)
	else
		local avatarFrame = self._areaUserInfo:getChildByName("sp_avatar_frame")
        print(avatarFrame:getPosition())
		HeadSprite:createClipHead(GlobalUserItem, 64, "sp_avatar_mask_64.png")
			  :setPosition(avatarFrame:getPosition())
			  :setName("sp_avatar")
			  :addTo(self._areaUserInfo)
	end

	--玩家昵称
	local avatarFrame = self._areaUserInfo:getChildByName("sp_avatar_frame")
	--[[local spnicknamebg = self._areaBottom:getChildByName("sp_name_bg")
	spnicknamebg:setLocalZOrder(avatarFrame:getLocalZOrder() - 2)]]
	local txtNickName = self._areaUserInfo:getChildByName("txt_nickname")
	--昵称判断不大于14个字符长度
	local signstrtable = ExternalFun.utf8StringSplit(GlobalUserItem.szNickName)
    local signstr = ""
    local signlen = 1
    for i = 1, #signstrtable do
        if signlen > 14 then
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
    if signlen > 14 then
        signstr = signstr.."..."
    end
	txtNickName:setString(signstr)

	--游戏ID
	local txtGameID = self._areaUserInfo:getChildByName("txt_gameid")
	txtGameID:setString("ID:"..GlobalUserItem.dwGameID)
	txtGameID:setFontSize(20)
	txtGameID:setTextColor(cc.c4b(255,236,127,255))
	--会员等级
	local MemberOrder = self._areaUserInfo:getChildByName("sp_VIP_lv")
	local orderstr = "topVipIcon_"..GlobalUserItem.cbMemberOrder..".png"
	print("===================="..orderstr)
	MemberOrder:setPositionX(213)
	MemberOrder:loadTexture(orderstr,UI_TEX_TYPE_PLIST)


	--更新分数
	self:onUpdateScoreInfo()
end

--更新分数信息
function ClientScene:onUpdateScoreInfo()

	--游戏币
	local txtGold = self._areaUserInfo:getChildByName("area_gold_info"):getChildByName("txt_gold")
	
	local str = ExternalFun.numberThousands(GlobalUserItem.lUserScore)
	dump(str)
	--str = string.gsub(str,",",":")
	txtGold:setString(str)
	local txtwith = txtGold:getContentSize().width
	local txtlen = string.len(str)
	-- if txtlen >= 11 then
	-- 	txtGold:setScale(170 / txtwith)
	-- end

	--游戏豆
	local txtBean = self._areaUserInfo:getChildByName("area_bean_info"):getChildByName("txt_bean")
	str = GlobalUserItem.dUserBeans
	--print("游戏豆 = "..str)
--	str = string.format("%.2f", str)
--	str = string.gsub(str,"[.]",";")
	txtBean:setString(str)
	local with = txtBean:getContentSize().width
	local len = string.len(str)
	if len > 5 then
		txtBean:setScale(85 / with)
	end

	if self._exchange and self._exchange.onUpdateRedInfo then
		print("兑换信息刷新")
		self._exchange:onUpdateRedInfo()
	end
end

--更新在线人数
function ClientScene:onUpdateOnlineCount()

	local onlineCount = GlobalUserItem.getRealOnlineCount()
	onlineCount = onlineCount + GlobalUserItem.OnlineBaseCount + math.random(0, 50)

	--在线人数
	--local txtOnlineCount = self._areaRank:getChildByName("area_online_count"):getChildByName("txt_online_count")
	--txtOnlineCount:setString("在线人数：" .. onlineCount)
end

--点击排行榜分类
function ClientScene:onClickRankCategory(index)
	
	--播放按钮音效
	ExternalFun.playClickEffect()

	for i = 1, #self._rankCategoryBtns do
		self._rankCategoryBtns[i]:setSelected(index == i)
	end

	--防止重复执行
	if index == self._rankCategoryIndex then
		return
	end
	self._rankCategoryIndex = index

	print("切换排行分类", index)

	--加载排行榜
	self._rankListLayer:loadRankingList(index)
end


--排行榜收缩
function ClientScene:onClickRankShow(isShow)
	if isShow == true then
		self.rank_btn:loadTextureNormal("plaza/btn_r.png")
		self.isShowRank = false
		AnimationHelper.moveOutTo(self._gameListLayer, 0.4, cc.p(self._ptGameListLayer.x -300, self._ptGameListLayer.y))
		self._gameListLayer:setContentSize(1208 + (yl.APPSTORE_VERSION and self._areaCategory:getContentSize().width or 0), 512)
		AnimationHelper.jumpInTo(self._roomListLayer, 0.4, cc.p(0, 0), 0, 6)
		AnimationHelper.moveOutTo(self._areaRank, 0.4, cc.p(self._ptAreaRank.x -300, self._ptAreaRank.y))
	else
		self.rank_btn:loadTextureNormal("plaza/btn_l.png")
		self.isShowRank = true
		AnimationHelper.moveOutTo(self._gameListLayer, 0.4, cc.p(self._ptGameListLayer.x ,self._ptGameListLayer.y),function ( )
			  self._gameListLayer:setContentSize(908 + (yl.APPSTORE_VERSION and self._areaCategory:getContentSize().width or 0), 512)
			  end)
							 

		AnimationHelper.jumpInTo(self._roomListLayer, 0.4, cc.p(0, 0), 0, 6)
		AnimationHelper.moveOutTo(self._areaRank, 0.4, cc.p(self._ptAreaRank.x, self._ptAreaRank.y))
	end          
end
function ClientScene:onChangeIndex()

end
--点击游戏分类
function ClientScene:onClickGameCategory(index, enableSound)
	
	--播放按钮音效
	if enableSound then
		ExternalFun.playClickEffect()
	end

	for i = 1, #self._gameCategoryBtns do
		self._gameCategoryBtns[i]:setSelected(index == i)
	end

	--防止重复执行
	if index == self._gameCategoryIndex then
		return
	end
	self._gameCategoryIndex = index

	print("切换游戏分类", index)
	if index == 1 then
		self._rollLayout:setVisible(true)
		self:layoutAction()
	else	
		self._rollLayout:setVisible(false)
		self._rollLayout:stopAllActions()
	end
	--更新游戏列表
	self._gameListLayer:updateGameList2(index,self._gamePanel)

--    --切换动画
--    self._gameListLayer:stopAllActions()
--    self._gameListLayer:setPosition(cc.p(325 + 454, 97))
--    self._gameListLayer:runAction(cc.EaseSineInOut:create(cc.MoveTo:create(0.3, cc.p(325, 97))))
  
--    --3D翻转动画
--    local scheduler = cc.Director:getInstance():getScheduler()

--    if (self._schedualId) then
--        scheduler:unscheduleScriptEntry(self._schedualId)
--        self._schedualId = 0
--    end

--    self._rotation3D = -45
--    self._rotationAlpha = 0
--    self._schedualId = scheduler:scheduleScriptFunc(function()

--        if self._rotation3D >= 0 then
--            scheduler:unscheduleScriptEntry(self._schedualId)
--            self._schedualId = 0
--            self._rotation3D = 0
--            self._rotationAlpha = 255
--        end

--        self._gameListLayer:setRotation3D(cc.vec3(self._rotation3D, 0, 0));
--        self._gameListLayer:setOpacity(self._rotationAlpha)
--        self._rotation3D = self._rotation3D + 2
--        self._rotationAlpha = (self._rotation3D + 45) * 255 / 45
--    end, 0, false)
	
end

--点击头像
function ClientScene:onClickAvatar()

	--播放按钮音效
	ExternalFun:playClickEffect()

	--显示个人信息
	showPopupLayer(PersonalInfoLayer:create())
end

--点击返回
function ClientScene:onClickBack()

	--播放按钮音效
	ExternalFun:playClickEffect()
	--这尼玛是只能点一下的节奏啊
	self._gameListLayer._isClickGame = false

	local currentLayerTag = self:getCurrentLayerTag()

	--房间列表返回
	if currentLayerTag == LayerTag.ROOM_LIST then

		--防止重复执行
		if self._gameListLayer:getNumberOfRunningActions() > 0 then
			return
		end

		--内部还有层级没返回
		if self._roomListLayer:onKeyBack() == false then
			return
		end

		--隐藏返回按钮
		self._btnBack:setVisible(false)
		
		--显示喇叭
		if self._areaTrumpet:getIsWorking() == false then
			self._areaTrumpet:setVisible(false)
		else 
			self._areaTrumpet:setVisible(true)
		end
		self._areaTrumpet:setAllFalse(false)
		 
		--显示首充按钮
		if not GlobalUserItem.bFirstPay then
			self.btnFirstRecharge:setVisible(true)
		end
		--显示转轮按钮
		self.btnRunner:setVisible(true)
		--显示分享按钮
		self.btn_share:setVisible(true)

		--背景图
		self._plazaBg:setTexture("plaza/plaza_bg.jpg")
		--替换顶部资源
		self._areaTop:setTexture("plaza/sp_top_bar.png")

		--停止动画
		self._areaRank:stopAllActions()
		self._areaCategory:stopAllActions()
		self._gameListLayer:stopAllActions()
		self._roomListLayer:stopAllActions()

		--执行动画
		AnimationHelper.jumpInTo(self._areaRank, 0.4, cc.p(self._ptAreaRank.x, self._ptAreaRank.y), 6, 0)
		AnimationHelper.jumpInTo(self._areaCategory, 0.4, cc.p(self._ptAreaCategory.x, self._ptAreaCategory.y), -6, 0)
		AnimationHelper.jumpInTo(self._gameListLayer, 0.4, cc.p(self._ptGameListLayer.x, self._ptGameListLayer.y), -6, 0)
		AnimationHelper.jumpInTo(self._areaBottom, 0.4,  cc.p(self._ptAreaBottom.x, self._ptAreaBottom.y), 6, 0)
		AnimationHelper.jumpInTo(self._youngsister, 0.4, cc.p(self._ptYoungSister.x,self._ptYoungSister.y), 6, 0)
		AnimationHelper.moveOutTo(self._areaUserInfo ,0.4, cc.p(self._ptUserInfo.x,self._ptUserInfo.y),function() self._btnBack:setVisible(false) self._gamePanel :setVisible(self._gameCategoryIndex == 1) end)


		AnimationHelper.moveOutTo(self._roomListLayer, 0.2, cc.p(0, -100))
		AnimationHelper.alphaOutTo(self._roomListLayer, 0.2, 0, function() self._roomListLayer:setVisible(false) end)
 
		if self.isShowRank == false then
			self.isShowRank = true
			self._gameListLayer:setContentSize(908 + (yl.APPSTORE_VERSION and self._areaCategory:getContentSize().width or 0), 512)
			self.rank_btn:loadTextureNormal("plaza/btn_l.png")
		end
		--轮播显示
		self._rollLayout:setVisible(true)
		self:layoutAction()
		if self._gameCategoryIndex ~=1 then
			self._rollLayout:setVisible(false)
		end
		--self:showTypeTips()
		--self:onClickRankShow(true)
		--移除层
		self:popLayerTag()

	--房间返回
	elseif currentLayerTag == LayerTag.ROOM then
		--关闭房间
		self._roomLayer:closeRoom()
	end

	--审核状态 
	if yl.APPSTORE_VERSION  then 
		self:onPassReview()
		self:onPassReviewByAndroid()
	end 
end

--点击更多按钮
function ClientScene:onClickMoreButton()
	local ismorebuttonopen = self.area_morebutton:isVisible()
	local scale = 0
	local scaleinitial = 1
	if not ismorebuttonopen then
		scale = 1
		scaleinitial = 0
	end
	self.area_morebutton:setScale(scaleinitial)
	self.area_morebutton:setVisible(true)
	self.area_morebutton:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,scale),cc.CallFunc:create(function ()
		self.area_morebutton:setVisible(not ismorebuttonopen)
		self._morebuttonLayout:setVisible(not ismorebuttonopen)
		end)))
	--self.area_morebutton:setVisible(not self.area_morebutton:isVisible())
end
------------------------------------------------------------------------------------------------------------
-- RankingListLayer 回调

--点击排行榜用户
function ClientScene:onClickRankUserItem(userItem)
	
	--播放按钮音效
	ExternalFun:playClickEffect()

	showPopupLayer(UserInfoLayer:create(userItem))
end
--排行榜展开
function ClientScene:onClickRankOpen( )
	--播放音效
	ExternalFun.playClickEffect()
	self._bIsRankActionOver = false;
	--[[local RankIsShow = self._areaRank:isVisible()
	local arearank_beginpos = cc.p(-77,375)
	local arearank_endpos = cc.p(77,375)
	local arearank_actionpos = nil
	if (not RankIsShow) then
		arearank_actionpos = arearank_endpos
		self._areaRank:setPosition(arearank_beginpos)
		self._areaRank:setVisible(not RankIsShow)
	else
		arearank_actionpos = arearank_beginpos
	end
	]]
	local RankIsUnfloding = self._areaRankOpen:isVisible()
	local beginPos = cc.p(-1334,0)
	local endPos = cc.p(0,0)
	local actionPos = nil;
	if (not RankIsUnfloding) then
		actionPos = endPos
		self._areaRankOpen:setPosition(beginPos)
		self._areaRankOpen:setVisible(not RankIsUnfloding)
	else
		actionPos = beginPos
	end
	self._areaRankOpen:runAction(cc.Sequence:create(cc.MoveTo:create(0.3,actionPos), cc.CallFunc:create(function()
				self._areaRankOpen:setVisible(not RankIsUnfloding)
				self._bIsRankActionOver = true
			end)))
	--[[if not RankIsUnfloding then
		self._areaRank:runAction(cc.Sequence:create(cc.MoveTo:create(0.3,arearank_actionpos), cc.CallFunc:create(function()
			self._areaRankOpen:runAction(cc.Sequence:create(cc.MoveTo:create(0.3,actionPos), cc.CallFunc:create(function()
					self._areaRankOpen:setVisible(not RankIsUnfloding)     
			end)))
			--self._areaRank:setVisible(not RankIsShow)
			self._bIsRankActionOver = true
		end)))
	else
		self._areaRankOpen:runAction(cc.Sequence:create(cc.MoveTo:create(0.3,actionPos), cc.CallFunc:create(function()
			self._areaRank:runAction(cc.Sequence:create(cc.MoveTo:create(0.3,arearank_actionpos), cc.CallFunc:create(function()
				self._areaRank:setVisible(not RankIsShow)
			end)))   
			self._areaRankOpen:setVisible(not RankIsUnfloding)
			self._bIsRankActionOver = true
		end)))
	end]]
end

--设置我的排行榜信息
function ClientScene:setMySelfRankInfo(myselflist)
	dump(myselflist)
	local sp_rank_myself = self._areaRankOpen:getChildByName("sp_rank_myself")
	--头像
	HeadSprite:createClipHead(nil, 96, "sp_avatar_mask_96.png")
		:setTag(2)
		:setPosition(210, 60)
		:addTo(sp_rank_myself)
	--名次
	ccui.TextAtlas:create()
		:setProperty("0","plaza/sp_rank_number.png",42,53,"0")
		:setTag(3)
		:setPosition(75,80)
		:setVisible(false)
		:addTo(sp_rank_myself)     
	--奖牌
	cc.Sprite:create()
		:setTag(4)
		:setPosition(75, 75)
		:setVisible(false)
		:addTo(sp_rank_myself)

	--昵称
	ccui.Text:create("玩家昵称", "fonts/round_body.ttf", 25)
		:setTag(5)
		:setAnchorPoint(0, 0.5)
		:setPosition(345, 85)
			--:setTextColor(cc.c3b(185, 211, 255))
		:addTo(sp_rank_myself)
		--金币背景
	cc.Sprite:createWithSpriteFrameName("sp_rankgold_bg.png")
		:setAnchorPoint(0,0.5)
		:setPosition(345,40)
		:addTo(sp_rank_myself)
		--金币图标
	cc.Sprite:createWithSpriteFrameName("img_gold.png")
		:setAnchorPoint(0,0.5)
		:setPosition(340,38)
		:addTo(sp_rank_myself)
	--金币
	ccui.Text:create("0", "fonts/round_body.ttf", 30)
		:setTag(6)
		:setAnchorPoint(0, 0.5)
		:setPosition(390, 40)
		:setTextColor(cc.c3b(255,255,0))
		:addTo(sp_rank_myself)

	local item = myselflist
	local headSprite = sp_rank_myself:getChildByTag(2)
	local txtRank = sp_rank_myself:getChildByTag(3)
	local spMedal = sp_rank_myself:getChildByTag(4)
	local txtNickName = sp_rank_myself:getChildByTag(5)
	local txtGold = sp_rank_myself:getChildByTag(6)

	--排名
	local idx = item.Rank
	if idx >= 1 and idx <= 3 then
		local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("sp_rank_order_%d.png", idx))
		spMedal:setSpriteFrame(frame)
		spMedal:setVisible(true)

		txtRank:setString("")
		txtRank:setVisible(false)
	else
		spMedal:setVisible(false)

		txtRank:setString(idx)
		txtRank:setVisible(true)
	end

	--头像
	headSprite:updateHead({ wFaceID = item.FaceID })

	--昵称
	txtNickName:setString(string.EllipsisByConfig(item.NickName, 200, self._nickNameFontConfig))
	txtNickName:setString(item.NickName)

	--金币
	txtGold:setString(ExternalFun.numberThousands(tonumber(item.Score)))
end
------------------------------------------------------------------------------------------------------------
-- GameListLayer 回调

--快速加入隐藏
function ClientScene:OnAutoGameHide()
  --隐藏喇叭
	self._areaTrumpet:setVisible(false)

	--更多隐藏
	if self.area_morebutton:isVisible() then
		self:onClickMoreButton()
	end

	--隐藏首充按钮
	self.btnFirstRecharge:setVisible(false)
	--隐藏转轮按钮
	self.btnRunner:setVisible(false)
	--隐藏分享按钮
	self.btn_share:setVisible(false)
	--替换顶部资源
	self._areaTop:setTexture("plaza/roomTopBg.png")
	self._plazaBg:setTexture("RoomList/roomBg.jpg")
	--重置状态
	self._areaRank:setPosition(self._ptAreaRank):stopAllActions()
	self._areaCategory:setPosition(self._ptAreaCategory):stopAllActions()
	self._gameListLayer:setPosition(self._ptGameListLayer):stopAllActions()
	self._roomListLayer:setPosition(0, -100):setOpacity(0):setVisible(true):stopAllActions()

	
	--执行动画
	AnimationHelper.moveOutTo(self._areaRank, 0.4, cc.p(self._ptAreaRank.x - 500, self._ptAreaRank.y))
	AnimationHelper.moveOutTo(self._areaCategory, 0.4, cc.p(self._ptAreaCategory.x + 1500, self._ptAreaCategory.y))
	AnimationHelper.moveOutTo(self._gameListLayer, 0.4, cc.p(self._ptGameListLayer.x + 1500, self._ptGameListLayer.y))
	AnimationHelper.moveOutTo(self._areaBottom, 0.4,  cc.p(self._ptAreaBottom.x, self._ptAreaBottom.y - 200))
	AnimationHelper.moveOutTo(self._youngsister, 0.4, cc.p(self._ptYoungSister.x - 600,self._ptYoungSister.y))
	AnimationHelper.moveOutTo(self._areaUserInfo ,0.4, cc.p(self._ptUserInfo.x + 200,self._ptUserInfo.y+20),function() self._btnBack:setVisible(true) end)

	AnimationHelper.jumpInTo(self._roomListLayer, 0.4, cc.p(0, 0), 0, 6)
	AnimationHelper.alphaInTo(self._roomListLayer, 0.3, 255)
    if self._gameCategoryIndex ~= 1 then self._gamePanel :setVisible(false) end
	--保存游戏信息（私人房查询需要)
	GlobalUserItem.nCurGameKind = wKindID

end

--直接显示房间列表
function ClientScene:onClickGameByAndroidMajia( wKindID )
	--防止重复执行
	if self._gameListLayer:getNumberOfRunningActions() > 0 then
		return
	end

	--隐藏喇叭
	self._areaTrumpet:setVisible(false)
	self._areaTrumpet:setAllFalse(true)
	--更多隐藏
	if self.area_morebutton:isVisible() then
		self:onClickMoreButton()
	end

	--隐藏首充按钮
	self.btnFirstRecharge:setVisible(false)
	--隐藏转轮按钮
	self.btnRunner:setVisible(false)
	--隐藏分享按钮
	self.btn_share:setVisible(false)

	--轮播隐藏
	self._rollLayout:setVisible(false)
	self._rollLayout:stopAllActions()
	--替换顶部资源
	self._areaTop:setTexture("plaza/roomTopBg.png")
	self._plazaBg:setTexture("RoomList/roomBg.jpg")
	--重置状态
	self._areaRank:setPosition(self._ptAreaRank):stopAllActions()
	self._areaCategory:setPosition(self._ptAreaCategory):stopAllActions():setVisible(false)
	self._gameListLayer:setPosition(self._ptGameListLayer):stopAllActions():setVisible(false)
	self._roomListLayer:setOpacity(0):setVisible(true):stopAllActions()

	--执行动画
	AnimationHelper.moveOutTo(self._areaRank, 0, cc.p(self._ptAreaRank.x - 500, self._ptAreaRank.y))
	AnimationHelper.moveOutTo(self._areaCategory, 0, cc.p(self._ptAreaCategory.x + 1500, self._ptAreaCategory.y))
	AnimationHelper.moveOutTo(self._gameListLayer, 0, cc.p(self._ptGameListLayer.x + 1500, self._ptGameListLayer.y))
	AnimationHelper.moveOutTo(self._areaBottom,0,  cc.p(self._ptAreaBottom.x, self._ptAreaBottom.y - 200))
	AnimationHelper.moveOutTo(self._youngsister, 0, cc.p(self._ptYoungSister.x - 600,self._ptYoungSister.y))
	AnimationHelper.moveOutTo(self._areaUserInfo ,0, cc.p(self._ptUserInfo.x + 200,self._ptUserInfo.y+20),function() self._btnBack:setVisible(true)

		if yl.IS_ANDROID_MAJIA == true then
			self._btnBack:setVisible(false)
			--self._areaUserInfo:setPosition(cc.p(self._ptUserInfo.x,self._ptUserInfo.y))
			self._areaBottom:setPosition(cc.p(self._ptAreaBottom.x,self._ptAreaBottom.y))
		end
	end)
    if self._gameCategoryIndex ~= 1 then self._gamePanel :setVisible(false) end

	AnimationHelper.jumpInTo(self._roomListLayer, 0, cc.p(0, 0), 0, 6)
	AnimationHelper.alphaInTo(self._roomListLayer, 0, 255)

	--保存游戏信息（私人房查询需要)
	GlobalUserItem.nCurGameKind = wKindID

	local isPriModeGame = MyApp:getInstance():isPrivateModeGame(wKindID)
	isPriModeGame = false
	if isPriModeGame then
		--显示房间分类
		self._roomListLayer:showRoomCategory(wKindID)
	else
		--显示房间列表
        self._gamePanel :setVisible(false)
		self._roomListLayer:showRoomList(wKindID,true)
	end

	--保存层
	self:pushLayerTag(LayerTag.ROOM_LIST)
end
--点击游戏
function ClientScene:onClickGame(wKindID)

	--防止重复执行
	-- if self._gameListLayer:getNumberOfRunningActions() > 0 then
	-- 	return
	-- end

	--显示返回按钮
	--self._btnBack:setVisible(true)

	--隐藏喇叭
	self._areaTrumpet:setVisible(false)
	self._areaTrumpet:setAllFalse(true)
	--更多隐藏
	if self.area_morebutton:isVisible() then
		self:onClickMoreButton()
	end

	--隐藏首充按钮
	self.btnFirstRecharge:setVisible(false)
	--隐藏转轮按钮
	self.btnRunner:setVisible(false)
	--隐藏分享按钮
	self.btn_share:setVisible(false)

	--停止动作
	-- local  tmpTaggame1x = self._gamePanel:getChildByName("gameTag1"):getPositionX()
	-- local backdis 		= self.tagame1X - tmpTaggame1x
	-- for i=1,#self.tab_game do				
	-- 	local btn = self._gamePanel:getChildByName(self.tab_game[i])
	-- 	btn:stopAllActions()
	-- 	btn:runAction(cc.MoveBy:create(0,cc.p(backdis,0)))
	-- end
	--轮播隐藏
	self._rollLayout:setVisible(false)
	self._rollLayout:stopAllActions()
	--替换顶部资源
	self._areaTop:setTexture("plaza/roomTopBg.png")
	self._plazaBg:setTexture("RoomList/roomBg.jpg")
	--重置状态
	self._areaRank:setPosition(self._ptAreaRank):stopAllActions()
	self._areaCategory:setPosition(self._ptAreaCategory):stopAllActions()
	self._gameListLayer:setPosition(self._ptGameListLayer):stopAllActions()
	self._roomListLayer:setPosition(0, -100):setOpacity(0):setVisible(true):stopAllActions()

	--执行动画
	AnimationHelper.moveOutTo(self._areaRank, 0.4, cc.p(self._ptAreaRank.x - 500, self._ptAreaRank.y))
	AnimationHelper.moveOutTo(self._areaCategory, 0.4, cc.p(self._ptAreaCategory.x + 1500, self._ptAreaCategory.y))
	AnimationHelper.moveOutTo(self._gameListLayer, 0.4, cc.p(self._ptGameListLayer.x + 1500, self._ptGameListLayer.y))
	AnimationHelper.moveOutTo(self._areaBottom, 0.4,  cc.p(self._ptAreaBottom.x, self._ptAreaBottom.y - 200))
	AnimationHelper.moveOutTo(self._youngsister, 0.4, cc.p(self._ptYoungSister.x - 600,self._ptYoungSister.y))
	AnimationHelper.moveOutTo(self._areaUserInfo ,0.4, cc.p(self._ptUserInfo.x + 200,self._ptUserInfo.y+20),function() self._btnBack:setVisible(true)

		if yl.APPSTORE_VERSION and yl.IS_MAJIA then 
			self._btnBack:setVisible(false)
			self._areaUserInfo:setPosition(cc.p(self._ptUserInfo.x,self._ptUserInfo.y))
			self._areaBottom:setPosition(cc.p(self._ptAreaBottom.x,self._ptAreaBottom.y))
		end 
	end)
    if self._gameCategoryIndex ~= 1 then self._gamePanel :setVisible(false) end
	AnimationHelper.jumpInTo(self._roomListLayer, 0.4, cc.p(0, 0), 0, 6)
	AnimationHelper.alphaInTo(self._roomListLayer, 0.3, 255)

	--保存游戏信息（私人房查询需要)
	GlobalUserItem.nCurGameKind = wKindID

	local isPriModeGame = MyApp:getInstance():isPrivateModeGame(wKindID)
	isPriModeGame = false
	if isPriModeGame then
		--显示房间分类
		self._roomListLayer:showRoomCategory(wKindID)
	else
		--显示房间列表
        self._gamePanel :setVisible(false)
		self._roomListLayer:showRoomList(wKindID,true)
	end

	--保存层
	self:pushLayerTag(LayerTag.ROOM_LIST)

end

--快速加入
function  ClientScene:onOuatGameLIst(wKindID,bshow)
    self._gamePanel :setVisible(false)
	self._roomListLayer:showRoomList(wKindID,bshow)
end
------------------------------------------------------------------------------------------------------------
-- RoomListLayer 回调

--点击房间
function ClientScene:onClickRoom(wServerID, wKindID)

	--登录房间
	self._roomLayer:logonRoom(wKindID, wServerID)
end
------------------------------------------------------------------------------------------------------------
-- RoomLayer 回调

--进入房间
function ClientScene:onEnterRoom()
	
	print("ClientScene:onEnterRoom()")

	--显示房间
	self._roomLayer:setVisible(true)

	--隐藏房间列表
	self._roomListLayer:setVisible(false)

	--保存层
	self:pushLayerTag(LayerTag.ROOM)
end

--离开房间
function ClientScene:onExitRoom(code, message)

	print("ClientScene:onExitRoom(code = " .. tostring(code) .. ")")

	--显示错误提示
	if type(message) == "string" and message ~= "" then
		QueryDialog:create(message, nil, nil, QueryDialog.QUERY_SURE):addTo(self)
	end

	--隐藏房间
	self._roomLayer:setVisible(false)

	--显示房间列表
	if code == -1 then
		--显示房间列表
		--self._roomListLayer:setVisible(true)
		if nil ~= self._roomLayer.m_scheduleUpdate then
        	local scheduler = cc.Director:getInstance():getScheduler()
        	scheduler:unscheduleScriptEntry(self._roomLayer.m_scheduleUpdate)
        	self._roomLayer.m_scheduleUpdate = nil
    	end
		local scene = cc.Director:getInstance():getRunningScene()
    	local layer = scene:getChildByTag(2000) 
    	if nil ~= layer then   
            self._roomLayer.loadingBar:stopAllActions()
            self._roomLayer.loadingBar = nil
            if nil ~= self._roomLayer.sp_load_act then
                self._roomLayer.sp_load_act:stopAllActions()
            end
            layer:stopAllActions()
            layer:removeFromParent()
    	end
    end
--         --动画显示房间列表
--        self._roomListLayer:setPosition(0, -100):setOpacity(0):setVisible(true):stopAllActions()
--        AnimationHelper.jumpInTo(self._roomListLayer, 0.4, cc.p(0, 0), 0, 6)
--        AnimationHelper.alphaInTo(self._roomListLayer, 0.3, 255)
		if self._bIsQuickStart ~= true then
			--快速加入显示房间列表

			--动画显示房间列表
			self._roomListLayer:setPosition(0, -100):setOpacity(0):setVisible(true):stopAllActions()
			AnimationHelper.jumpInTo(self._roomListLayer, 0.4, cc.p(0, 0), 0, 6)
			AnimationHelper.alphaInTo(self._roomListLayer, 0.3, 255)
			self._roomListLayer:ShowRommList()
		end	  

	--这尼玛是只能点一下的节奏啊
	self._gameListLayer._isClickGame = false
	--清理快速加入标志
	self._bIsQuickStart = false
	--移除层
	if self:getCurrentLayerTag() == LayerTag.ROOM then
		self:popLayerTag()
	end
		
	--AnimationHelper.moveOutTo(self._areaUserInfo ,0, cc.p(self._ptUserInfo.x,self._ptUserInfo.y),function() self._btnBack:setVisible(false) self._gamePanel :setVisible(self._gameCategoryIndex == 1) end)

	--更新积分
	self:onUpdateScoreInfo()

	--更新在线人数
	--self:onUpdateOnlineCount()

	--移除没使用的纹理
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
end

--离开桌子
function ClientScene:onExitTable()

	--更新积分
	self:onUpdateScoreInfo()
end

------------------------------------------------------------------------------------------------------------
-- OptionLayer 回调

function ClientScene:NoticeCallBack( event )
	
	local msg  =  event._usedata["NoticeMsg"]
	local type =  event._usedata["NoticeType"]
	if self._areaTrumpet ~=nil then
		self._areaTrumpet:addTrugTxt(msg,type)
	end

end

function ClientScene:getChannelID(  )
    local _channelid 
    if device.platform == "ios" and appdf.CHANNEL_ID == 1 then
        _channelid = 0
    elseif  device.platform == "android" or device.platform == "ios" then
		_channelid = appdf.CHANNEL_ID
	elseif device.platform == "windows" then
		_channelid =4
    end
    return _channelid
end

function ClientScene:backLogonScene( event )
	print("冲脸啊 大哥")
	local this = self
	local msg = event._usedata["msg"]

	if msg == 1 and self.showdialog ~= true then
				local action = {}
				action["ChannelID"] = self:getChannelID()
				action["szAccounts"]= GlobalUserItem.szAccount
			
				if GlobalUserItem.bThirdPartyLogin == true then
					action["szPassWord"]= GlobalUserItem.PasswordEncryption(GlobalUserItem.thirdPartyData.pwd) 
				else
					action["szPassWord"]= GlobalUserItem.PasswordEncryption(GlobalUserItem.szPassword)

				end
				action["machineSerial"] = MultiPlatform:getInstance():getMachineId()
				action["szComputerID2"] = MultiPlatform:getInstance():getMachineId2()
				action["IP"] = strtable.cip
				local pargams = {1,11,action}
			   
				local action2 = cjson.encode(pargams)
				yl.logonMsg	 = action2

				showPopWait(true,19)

        		yl.webStrdata = strData
				
				if yl._clientConnectedCount == 0 then
					WebFrame:wsInitWebScoket()
				end

				yl.reConnectWebInit  = true

				 if yl.dddddschedule == nil then
					yl.dddddschedule = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
						
						yl._clientConnectedCount  = yl._clientConnectedCount +1

						if yl._clientConnectedCount <=3 then
							WebFrame:wsInitWebScoket()
						elseif yl._clientConnectedCount ==5 or yl._clientConnectedCount ==7 or yl._clientConnectedCount == 9 then
							WebFrame:wsInitWebScoket()
						elseif yl._clientConnectedCount>9 then
							dismissPopWait()
							yl._clientConnectedCount = 0
							yl.isClientConnectedFailed  = false
							if yl.dddddschedule then
								cc.Director:getInstance():getScheduler():unscheduleScriptEntry(yl.dddddschedule)
								yl.dddddschedule = nil
							end
							
							--重启socket失败
							QueryDialog:create("网络连接超时",function(bReTry)
							if bReTry == true then
								if self._roomLayer._gameScene then
									self._roomLayer:stopKeepAlive()
								end
								self:onSwitchAccount()
							end
							end,nil,QueryDialog.QUERY_SURE)
							:addTo(cc.Director:getInstance():getRunningScene())
						end
				 	end, 2, false)
				 end
	
	elseif msg == 2 then
		self.showdialog = true
		print("T下线")
		--WebFrame:onCloseWebSocket()

		QueryDialog:create("用户数据发生改变，被迫下线！",function(bReTry)
			if bReTry == true then
				self._roomLayer:stopKeepAlive()
				self:onSwitchAccount()
				self.showdialog = false
			end
			end,nil,QueryDialog.QUERY_SURE)
			:addTo(cc.Director:getInstance():getRunningScene())

		
	elseif msg == 3 then
		self.showdialog = true
		QueryDialog:create("您的帐号已被冻结，请联系客服！",function(bReTry)
			if bReTry == true then
				yl.isTT = false
				self:onSwitchAccount()
				self.showdialog = false
			end
		end,nil,QueryDialog.QUERY_SURE)
		:addTo(self,99999)
	end
	
end

function ClientScene:GameLeaveForWebClose(  )
	--重启socket失败
	QueryDialog:create("网络连接超时",function(bReTry)
		if bReTry == true then
			if self._roomLayer._gameScene then
				self._roomLayer:stopKeepAlive()
			end
			self:onSwitchAccount()
		end
		end,nil,QueryDialog.QUERY_SURE)
		:addTo(cc.Director:getInstance():getRunningScene())
end

function ClientScene:backLogonGame( event )
	local this = self
	if this._roomLayer._gameScene and this._roomLayer._gameScene._gameLayer  then
		if this._roomLayer._gameFrame and this._roomLayer._gameFrame._roomInfo.wKindID 
			and this._roomLayer._gameFrame._roomInfo.wServerID then
				   
			local kkid =this._roomLayer._gameFrame._roomInfo.wKindID
			local ssid =this._roomLayer._gameFrame._roomInfo.wServerID
			if kkid ~= 601 then
				this._roomLayer:onExitTable(3)
			end
			this._roomLayer:onExitRoom(-1,nil)
			--this:onClickGame(kkid)
			this._roomListLayer:onQuickStartJduge(ssid,kkid)		
		end
	end		
end

function ClientScene:reLogonCallBack( result, message2 )
	
	local this = self
	dismissPopWait()
	print("登录webframe" .. message2)
	local action2 = cjson.encode(message2)
	local message = cjson.decode(message2)
	   
	if message[2] == 102 then
		yl.IsWxEnterBack = false
		if self.dddddschedule then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.dddddschedule)
			self.dddddschedule = nil
		end
		   
		local strdata1 = WebFrame:getStrData()
		   
		if strdata1~=nil and string.find( strdata1,"1,11,") == nil then
			   
			WebFrame:wsSendString(strdata1)
		end
	   
		if this._roomLayer._gameScene and this._roomLayer._gameScene._gameLayer  then
			if this._roomLayer._gameFrame and this._roomLayer._gameFrame._roomInfo.wKindID 
				and this._roomLayer._gameFrame._roomInfo.wServerID then
					   
				local kkid =this._roomLayer._gameFrame._roomInfo.wKindID
				local ssid =this._roomLayer._gameFrame._roomInfo.wServerID
				this._roomLayer:onExitTable(3)
				this._roomLayer:onExitRoom(-1,nil)
				this:onClickGame(kkid)
				this._roomListLayer:onQuickStartJduge(ssid,kkid)		
			end
		end		

	end
end

--切换账号
function ClientScene:onSwitchAccount(isClose )

	if self._areaTrumpet then
		self._areaTrumpet:closeTime()
	end
	
	--关闭房间
	if self._roomLayer:isEnterRoom() then
		self._roomLayer:closeRoom()
	end
	if cc.PLATFORM_OS_WINDOWS == targetPlatform then
		self:unSetWindowsCloseEvent()
	end
	if yl.noticeSchedule then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(yl.noticeSchedule)
		yl.noticeSchedule = nil
	end
	--爱悦玩登出
	if appdf.CHANNEL_ID == 2001 then
        MultiPlatform:getInstance():loginOutAWY()
    end

    --天宇游登出
	if appdf.CHANNEL_ID == 1004 then
        appdf.req("client.src.external.sdk.YijieInterface")  --易接SDK
        local yijie = YijieInterface.new()
        print("logout")
	    yijie:logout("logout")--登出
	end
	yl.CurrentScene	= yl.nowScene.Z_LOGONSCENE
	yl.ClientToLogon = true
	self:getApp():enterSceneEx(appdf.CLIENT_SRC.."plaza.views.LogonScene","FADE",1)
	
	GlobalUserItem.reSetData()
	--读取配置
	GlobalUserItem.LoadData()

	--if not isClose then
		yl.reConnectWebInit  = false
		WebFrame:onCloseWebSocket()
		
	--end


end

------------------------------------------------------------------------------------------------------------
-- 辅助功能

--缓存公共资源
function ClientScene:cachePublicRes(  )
	cc.SpriteFrameCache:getInstance():addSpriteFrames("client/res/plaza/kk/1.plist")
	cc.SpriteFrameCache:getInstance():addSpriteFrames("client/res/plaza/kk/2.plist")
	cc.SpriteFrameCache:getInstance():addSpriteFrames("client/res/plaza/kk/3.plist")
	cc.SpriteFrameCache:getInstance():addSpriteFrames("client/res/plaza/kk/4.plist")

	cc.SpriteFrameCache:getInstance():addSpriteFrames("public/public.plist")
	local dict = cc.FileUtils:getInstance():getValueMapFromFile("public/public.plist")

	local framesDict = dict["frames"]
	if nil ~= framesDict and type(framesDict) == "table" then
		for k,v in pairs(framesDict) do
			local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(k)
			if nil ~= frame then
				frame:retain()
			end
		end
	end

	cc.SpriteFrameCache:getInstance():addSpriteFrames("plaza/plaza.plist")	
	dict = cc.FileUtils:getInstance():getValueMapFromFile("plaza/plaza.plist")
	framesDict = dict["frames"]
	if nil ~= framesDict and type(framesDict) == "table" then
		for k,v in pairs(framesDict) do
			local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(k)
			if nil ~= frame then
				frame:retain()
			end
		end
	end
end

--释放公共资源
function ClientScene:releasePublicRes(  )
	local dict = cc.FileUtils:getInstance():getValueMapFromFile("public/public.plist")
	local framesDict = dict["frames"]
	if nil ~= framesDict and type(framesDict) == "table" then
		for k,v in pairs(framesDict) do
			local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(k)
			if nil ~= frame and frame:getReferenceCount() > 0 then
				frame:release()
			end
		end
	end

	dict = cc.FileUtils:getInstance():getValueMapFromFile("plaza/plaza.plist")
	framesDict = dict["frames"]
	if nil ~= framesDict and type(framesDict) == "table" then
		for k,v in pairs(framesDict) do
			local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(k)
			if nil ~= frame and frame:getReferenceCount() > 0 then
				frame:release()
			end
		end
	end
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("public/public.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("public/public.png")
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("plaza/plaza.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("plaza/plaza.png")
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
end

function ClientScene:setWindowsCloseEvent()

	ds.MyNotification:getInstance():registerLuaEventCallBack("WINDWOS_CLOSE",function()
    	if self._dialog then
            return
        end
        self._dialog = QueryDialog:create("是否退出510游戏？",function(bReTry)
			        if bReTry == true then
				        os.exit(0)
				    else
				    	self._dialog = nil
			        end
		        end)
		        :addTo(self,100002)
    	end)
end

function ClientScene:unSetWindowsCloseEvent()
	ds.MyNotification:getInstance():unRegisterEventListener("WINDWOS_CLOSE")
end

------------------------------------------------------------------------------------------------------------
-- 网络请求

--获取滚动公告
function ClientScene:requestRollNotice()

	if 1 then 
		if self._areaTrumpet ~= nil then
			self._areaTrumpet:closeTime()
			self._areaTrumpet = nil
		end

		self._areaTrumpet =GameNotice:create("",cc.p(self._areaTrumpet222:getPositionX(),self._areaTrumpet222:getPositionY()))
		self._areaTrumpet:addTo(self._areaTrumpet222:getParent())

		self._areaTrumpet:setVisible(false)
		self._areaTrumpet:setAllFalse(true)

		return;
	end
	--去除换行
	if self._isGunFirst == true then
		return;
	end
		jsdata ="510游戏，提倡健康休闲的游戏理念，严禁赌博、严禁私下交易"--string.gsub( jsdata,"%s+","")

		--更新内容
		self._txtTrumpet:setString(jsdata)

		local containerWidth = self._txtTrumpet:getParent():getContentSize().width
		local contentSize = self._txtTrumpet:getContentSize()

		--初始化位置
		self._txtTrumpet:setPosition(containerWidth, 15)

		--更新动画
		self._txtTrumpet:stopAllActions()
		self._txtTrumpet:runAction(
			--cc.RepeatForever:create(
				cc.Sequence:create(
					cc.CallFunc:create(function() self._txtTrumpet:setPosition(containerWidth, 15) end),
					cc.MoveBy:create(15 + contentSize.width / 172, cc.p(-contentSize.width - containerWidth, 0))
					--cc.CallFunc:create(function (  )
						--self._isGunFirst = true
						--self._areaTrumpet:setVisible(false)
					--end)
				)
			--)
		)

	--[[local url = yl.HTTP_NOTICE_URL .. "/Interface/Notice.ashx"
	appdf.onHttpJsionTable(url ,"GET","",function(jstable,jsdata)

		--去除换行
		jsdata = string.gsub( jsdata,"%s+","")

		--更新内容
		self._txtTrumpet:setString(jsdata)

		local containerWidth = self._txtTrumpet:getParent():getContentSize().width
		local contentSize = self._txtTrumpet:getContentSize()

		--初始化位置
		self._txtTrumpet:setPosition(containerWidth, 15)

		--更新动画
		self._txtTrumpet:stopAllActions()
		self._txtTrumpet:runAction(
			cc.RepeatForever:create(
				cc.Sequence:create(
					cc.CallFunc:create(function() self._txtTrumpet:setPosition(containerWidth, 15) end),
					cc.MoveBy:create(15 + contentSize.width / 172, cc.p(-contentSize.width - containerWidth, 0))
				)
			)
		)
	end)]]
end

--获取签到信息
function ClientScene:requestCheckinInfo()

	--苹果审核不显示登录奖励
	if yl.APPSTORE_VERSION then
		return
	end

	if nil == self._checkInFrame then

		self._checkInFrame = CheckinFrame:create(self, function(result, msg, subMessage)

			if result == 1 then

				local showFunc = function()
					
					if GlobalUserItem.bShowedLottery == true then
						return
					end

					GlobalUserItem.bShowedLottery = true

					self:runAction(cc.Sequence:create(
									cc.DelayTime:create(2.0),
									cc.CallFunc:create(function()
										--显示领奖页面
										showPopupLayer(LogonRewardLayer:create(), getPopupMaskCount() == 0)
									end)
									)
								)
				end

				--今日还没签到
				if false == GlobalUserItem.bTodayChecked then

					--获取抽奖配置
					if GlobalUserItem.bLotteryConfiged == false then

						RequestManager.requestLotteryConfig(function(result, message)

							if result == 0 then
								--显示领奖页面
								showFunc()
							end
						end)
					else
						--显示领奖页面
						showFunc()
					end
				end
			end

			self._checkInFrame:onCloseSocket()
			self._checkInFrame = nil
		end)
	end

	self._checkInFrame:onCloseSocket()
	--查签到信息
	self._checkInFrame:onCheckinQuery()
end

----获取抽奖配置
--function ClientScene:requestLotteryConfig()

--    --获取抽奖奖品配置
--	local url = yl.HTTP_URL .. "/WS/Lottery.ashx"
-- 	appdf.onHttpJsionTable(url ,"GET","action=LotteryConfig",function(jstable,jsdata)

--        if type(jstable) == "table" then
--            local data = jstable["data"]
--            if type(data) == "table" then
--                local valid = data["valid"]
--                if nil ~= valid and true == valid then
--                    local list = data["list"]
--                    if type(list) == "table" then
--                        for i = 1, #list do
--                            --配置转盘
--                            local lottery = list[i]

--                            GlobalUserItem.dwLotteryQuotas[i] = lottery.ItemQuota
--                            GlobalUserItem.cbLotteryTypes[i] = lottery.ItemType
--                        end

--                        --抽奖已配置
--                        GlobalUserItem.bLotteryConfiged = true

--                        --今日还没签到，弹出签到页面
--			            if false == GlobalUserItem.bTodayChecked then
--                            self:runAction(cc.Sequence:create(
--                                                cc.DelayTime:create(1.0),
--                                                cc.CallFunc:create(function()

--                                                        showPopupLayer(LogonRewardLayer:create())
--                                                    end),
--                                                nil
--                                                )
--                                            )
--                        end
--                    end
--                end
--            end
--        end
--    end)
--end

--查询活动状态
function ClientScene:requestQueryActivityStatus()

	--显示过了就不请求了
	if GlobalUserItem.bShowedActivity == true then
		return
	end

	local url = yl.HTTP_URL .. "/WS/NativeWeb.ashx"
	local ostime = os.time()
	appdf.onHttpJsionTable(url ,"GET","action=queryactivitystatus&userid=" .. GlobalUserItem.dwUserID .. "&time=".. ostime .. "&signature=".. GlobalUserItem:getSignature(ostime),function(jstable,jsdata)

		if type(jstable) ~= "table" then
			return
		end

		local isNewActivity = jstable["SFTJ"]
		--活动列表
		self._activityList = jstable["Activitylist"]

		if isNewActivity ~= 1 then
			return
		end

		GlobalUserItem.bShowedActivity = true

		self:runAction(cc.Sequence:create(
			cc.DelayTime:create(3.0),
			cc.CallFunc:create(function()
				print("=================================什么情况")
				--显示活动页面
				showPopupLayer(ActivityLayer:create(), getPopupMaskCount() == 0)
			end)
			)
		)
	end)
end

--查询是否有排行榜开启权限
function ClientScene:requestRankStatus()
	local url = yl.HTTP_URL .. "/WS/PhoneRank.ashx"
	local ostime = os.time()
	appdf.onHttpJsionTable(url ,"GET","action=getrankswitch&userid=" .. GlobalUserItem.dwUserID.. "&time=".. ostime .. "&signature=".. GlobalUserItem:getSignature(ostime),function(jstable,jsdata)
		if type(jsdata) ~= "string" then
			return
		end
		if jsdata == "0" then
			print("==========sdfdf=================")
			self._isOpenRank = true
		end
	end)
end

return ClientScene