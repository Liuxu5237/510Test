--游戏商城
local ShopLayer = class("ShopLayer", cc.Layer)

local QueryDialog = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.QueryDialog")

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")

local ActivityIndicator = appdf.req(appdf.CLIENT_SRC .. "plaza.views.layer.general.ActivityIndicator")
local PaymentLayer = appdf.req(appdf.CLIENT_SRC .. "plaza.views.layer.plaza.PaymentLayer")
local CardPayLayer = appdf.req(appdf.CLIENT_SRC .. "plaza.views.layer.plaza.CardPayLayer")

local ShopDetailFrame = appdf.req(appdf.CLIENT_SRC .. "plaza.models.ShopDetailFrame")
local RequestManager = appdf.req(appdf.CLIENT_SRC .. "plaza.models.RequestManager")

local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local WebFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.WebFrame")

--列表类型
local ListType =
{
	Bean = 1,
	Gold = 2,
	RoomCard = 3,
	VIP  = 4
}

--道具类型
local PropertyType =
{
	Bean = 1,
	Gold = 2,
	RoomCard = 3,
	VIP  = 4,
	RoomCard = 8
}

--支付方式
local PaymentType = 
{
	Bean = 1,
	Rmb = 2
}

function ShopLayer:ctor(listType)
	math.randomseed(string.reverse(os.time()))

	--初始化分类按钮列表
	self._btnCategorys = {}
	--初始化列表类型
	self._listType = 0
	
	--网络处理
	self._shopDetailFrame = ShopDetailFrame:create(self, function(result, message)
		self:onShopDetailCallBack(result, message)
	end)
	
	--事件监听
	self:initEventListener()
	
	--节点事件
	ExternalFun.registerNodeEvent(self)
	
	local csbNode = ExternalFun.loadCSB("Shop/ShopLayer.csb"):addTo(self)
	--self._top = csbNode:getChildByName("top")
	self._content = csbNode:getChildByName("content")
	self._txtgold = self._content:getChildByName("gold_info"):getChildByName("txt_gold")
	self._txtBean = self._content:getChildByName("bean_info"):getChildByName("txt_bean")
	self._content:getChildByName("bean_info"):setVisible(false)
	--self._txtRoomCard = self._top:getChildByName("roomcard_info"):getChildByName("txt_roomcard")
	
	--审核隐藏
	--local txtDescription = self._content:getChildByName("txt_description")
	--txtDescription:setVisible(not yl.APPSTORE_VERSION)
	
	--self._top:getChildByName("roomcard_info"):setVisible(not yl.APPSTORE_VERSION)
	--隐藏房卡
	--self._top:getChildByName("roomcard_info"):setVisible(false)
	
	--返回
	local btnBack = self._content:getChildByName("btn_back")
	btnBack:addClickEventListener(function()
		
		--播放音效
		ExternalFun.playClickEffect()
		
		self:removeFromParent()
	end)
	
	--分类按钮
	for i = 1, 4 do
		
		local btnCategory = self._content:getChildByName("btn_category_" .. i)
		btnCategory:addEventListener(function(ref, type)
			
			self:onClickCategory(i, true)
		end)
		
		self._btnCategorys[i] = btnCategory
		
		if i == ListType.RoomCard then
			btnCategory:setVisible(not yl.APPSTORE_VERSION)
		end
	end
	--隐藏豆子按钮
	local btnbean = self._content:getChildByName("btn_category_1")
	local pos1 = cc.p(btnbean:getPosition())
	btnbean:setVisible(false)

	--移动金币坐标
	local btngold = self._content:getChildByName("btn_category_2")
	local pos2 = cc.p(btngold:getPosition())
	
	--隐藏房卡按钮
	local btnFanka = self._content:getChildByName("btn_category_3")
	btnFanka:setVisible(false)
	
	--vip充值
	local btnvip  = self._content:getChildByName("btn_category_4")
	local pos3 = cc.p(btnvip:getPosition())

	--充值卡兑换
	local btnCardPay = self._content:getChildByName("btn_card_pay")
	btnCardPay:setVisible(not yl.APPSTORE_VERSION)
	btnCardPay:addClickEventListener(function()
		
		self:onClickCardPay()
	end)
	
	btnvip:setPosition(pos1)

	
	--local label_des = self._content:getChildByName("txt_description")
	--label_des:setString("商城说明：\n游戏豆为552游戏中心通用平台币，可用于兑换游戏币在游戏中进行消耗，还可用于兑换房卡邀请好友共同游戏。")
	
	--列表容器
	self._listContainer = self._content:getChildByName("list_container")
	self._listContainer:setScrollBarEnabled(false)
	
	--活动指示器
	self._activity = ActivityIndicator:create()
	self._activity:setPosition(yl.WIDTH / 2, yl.HEIGHT / 2)
	self._activity:stop()
	self._activity:addTo(self, 100)
	
	--更新分数信息
	self:onUpdateScoreInfo()

	--随机vip列表
	if GlobalUserItem.tabShopCache.shopVipList ~= nil then
		GlobalUserItem.tabShopCache.shopVipList = self:shuffle(GlobalUserItem.tabShopCache.shopVipList)
	end

	--选中指定分类
	self:onClickCategory(listType or ListType.VIP)
	
	--刷新用户分数信息
	RequestManager.requestUserScoreInfo(nil)
end

--初始化事件监听
function ShopLayer:initEventListener()
	
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	
	--用户信息改变事件
	eventDispatcher:addEventListenerWithSceneGraphPriority(
	cc.EventListenerCustom:create(yl.RY_USERINFO_NOTIFY, handler(self, self.onUserInfoChange)),
	self
	)

	eventDispatcher:addEventListenerWithSceneGraphPriority(
        cc.EventListenerCustom:create("ry_GetGroptype", handler(self, self.GetGroptype)),
        self
        )
end

------------------------------------------------------------------------------------------------------------
-- 事件处理
function ShopLayer:onExit()
	removebackgroundcallback()
	if self._shopDetailFrame:isSocketServer() then
		self._shopDetailFrame:onCloseSocket()
	end
end

function ShopLayer:GetGroptype(event)
	
	local message  =  event._usedata["gro_list"]

	dump(message)
	self._activity:stop()
	if type(message) ~= "table" then
		return
	end
	
	local list = message
	
	local goldlist = {}
	local viplist  = {}
	for i=1,#message do
		local item = message[i]
		if item.ClientType == 1 then
			table.insert( goldlist,item )
		elseif item.ClientType == 2 then
			table.insert( viplist,item )
		end
	end
		
	--排序
	table.sort(goldlist, function(a, b)
		return a.CateID < b.CateID
	end)

	--随机vip列表
	viplist = self:shuffle(viplist)

	GlobalUserItem.tabShopCache.shopGoldList = goldlist

	GlobalUserItem.tabShopCache.shopVipList = viplist
	dump(GlobalUserItem.tabShopCache.shopVipList)
	--更新列表
	self:updateList(self._listType)	
	
	
end

--用户信息改变
function ShopLayer:onUserInfoChange(event)
	
	print("----------ShopLayer:onUserInfoChange------------")
	
	local msgWhat = event.obj
	if nil ~= msgWhat and msgWhat == yl.RY_MSG_USERWEALTH then
		--更新财富
		self:onUpdateScoreInfo()
	end
end

--更新分数信息
function ShopLayer:onUpdateScoreInfo()

	local str = ExternalFun.numberThousands(GlobalUserItem.lUserScore)
    str = string.gsub(str,",",":")
    self._txtgold:setString(str)
    local txtwith = self._txtgold:getContentSize().width
    local txtlen = string.len(str)
    if txtlen >= 11 then
        self._txtgold:setScale(200 / txtwith)
    end
	
	--self._txtBean:setString(ExternalFun.numberThousands(GlobalUserItem.dUserBeans))
	--self._txtRoomCard:setString(ExternalFun.numberThousands(GlobalUserItem.lRoomCard))
end

--点击分类
function ShopLayer:onClickCategory(index, enableSound)
	
	print("index = "..index)
	print("click = "..self._listType)
	--播放按钮音效
	if enableSound then
		ExternalFun.playClickEffect()
	end
	
	for i = 1, #self._btnCategorys do
		self._btnCategorys[i]:setSelected(index == i)
	end
	
	--防止重复执行
	if index == self._listType then
		return
	end
	
	self._listType = index
	
	
	--游戏豆
	if index == ListType.Bean then
		
		if GlobalUserItem.tabShopCache.shopBeanList == nil then
			--self:requestBeanList()
			self:requestPropertyList(PropertyType.Bean)
			return
		end
		
		--游戏币
	elseif index == ListType.Gold or index == ListType.VIP then
		
		if GlobalUserItem.tabShopCache.shopGoldList == nil then
			self:requestPropertyList(PropertyType.Gold)
			return
		end
		--房卡
	elseif index == ListType.RoomCard then
		
		if GlobalUserItem.tabShopCache.shopRoomCardList == nil then
			self:requestPropertyList(PropertyType.RoomCard)
			return
		end
	end
	
	--更新列表
	self:updateList(index)
end

--点击充值卡兑换
function ShopLayer:onClickCardPay()
	
	--播放音效
	ExternalFun.playClickEffect()
	
	showPopupLayer(CardPayLayer:create())
end

--获取随机码    
function ShopLayer:getrand()
    local prefixLable = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    mytime = os.time()
    mytime = string.reverse(mytime)
    math.randomseed(mytime)
    local prefix = ""
    for i = 1, 5 do
        num = math.random(1, 62)
        local letter = string.sub(prefixLable,num, num)
        prefix = prefix..letter
    end
    return prefix
end


--点击价格按钮									--价格  数量   项目ID  产品ID
function ShopLayer:onClickPrice(listType, index, price, count, itemid, productid)
	
	print("点击价格按钮", listType, index)
	
	--播放音效
	ExternalFun.playClickEffect()
	
	if listType == PaymentType.Rmb then
		
		--苹果支付
		if yl.APPSTORE_VERSION and(targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD) then
			
			local payparam = {}
			payparam.http_url = yl.HTTP_URL
			payparam.uid = GlobalUserItem.dwUserID
			payparam.productid = tostring(math.ceil(productid)) --转为string 否则在oc UTF8String报错
			payparam.price = price
			
			showPopWait()
			self:runAction(cc.Sequence:create(cc.DelayTime:create(5), cc.CallFunc:create(function()
				dismissPopWait()
			end)))
			showToast(nil, "正在连接iTunes Store...", 4)
			
			local function payCallBack(param)
				if type(param) == "string" and "true" == param then
					
					showToast(nil, "支付成功", 2)
					
					--刷新游戏豆列表
					--self:requestBeanList()
					
					--刷新用户分数信息
					RequestManager.requestUserScoreInfo(function(result, message)
						
						if type(message) == "string" and message ~= "" then
							showToast(nil, message, 2)		
						end
						if 0 == result then
							--刷新当前列表
							self:updateList(self._listType)
						end
					end)
				else
					showToast(nil, "支付失败", 2)
				end
			end
			
			MultiPlatform:getInstance():thirdPartyPay(yl.ThirdParty.IAP, payparam, payCallBack)
		
		elseif appdf.CHANNEL_ID == 2001 --[[爱悦玩zf--]] then
	
			local payparam = {}
			local ostime = os.time()
			local account = GlobalUserItem.szAccount 
			payparam.billno = ""..ostime..account
			payparam.flag = ""..price
			--payparam.productid = tostring(math.ceil(productid)) --转为string 否则在oc UTF8String报错
			payparam.price = ""..price
			
			showPopWait()
			self:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function()
				dismissPopWait()
			end)))
			showToast(nil, "爱玩悦商店...", 2)
			
			local function payCallBack(param)
				if type(param) == "string" and "true" == param then
					
					showToast(nil, "支付成功", 2)
					
					--刷新游戏豆列表
					--self:requestBeanList()
					
					--刷新用户分数信息
					RequestManager.requestUserScoreInfo(function(result, message)
						
						if type(message) == "string" and message ~= "" then
							showToast(nil, message, 2)		
						end
						
						if 0 == result then
							--刷新当前列表
							self:updateList(self._listType)
						end
					end)
				else
					showToast(nil, "支付失败", 2)
				end
			end
			
			 MultiPlatform:getInstance():AWYZF_z(yl.ThirdParty.AYW, payparam, payCallBack)

           elseif appdf.CHANNEL_ID == 1004 --[[天宇游]] then
	
			local payparam = {}
			local ostime = os.time()
			local account = GlobalUserItem.szAccount 
			payparam.billno = ""..ostime..account
			--payparam.flag = ""..price
			--payparam.price = ""..price
			showPopWait()
			self:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function()
				dismissPopWait()
			end)))
			showToast(nil, "天宇游商店...", 2)
			
			local function payTYYCallBack(param)
        		local cjson = appdf.req("cjson")
	    		local data = json.decode(param);
    
	   			if data["result"] == "success" then--支付成功
		
        			RequestManager.requestUserScoreInfo(function(result, message)
						
						if type(message) == "string" and message ~= "" then
							showToast(nil, message, 2)		
						end
						
						if 0 == result then
							--刷新当前列表
							self:updateList(self._listType)
						end
					end)

	    		elseif data["result"] == "oderno" then--获得订单号
	    		elseif data["result"] == "fail" then--支付失败
		    		showToast(nil, "支付失败", 2)
	    		end
			 end
			 
            printf("laileh") 
            appdf.req("client.src.external.sdk.YijieInterface")  --易接SDK
            local yijie = YijieInterface.new()
            --price, count, itemid, productid

          -- //  input = tostring(input)
              local lPice = price*100   --单位分所以*100
              local lProp = tostring(count)  --道名 购买的金币 唯一的
              local callbackinfo = tostring(lPice)
              callbackinfo = callbackinfo..":"..lProp
              yijie:pay(lPice, lProp, 1, callbackinfo, "", payTYYCallBack)

		else                                        
			
			--设置背景回调
			setbackgroundcallback(function(bEnter)
				print("回来")
				if bEnter then
					RequestManager.requestUserScoreInfo(function(result, message)
						
						if type(message) == "string" and message ~= "" then
							showToast(nil, message, 2)		
						end
						
						if 0 == result then
							--刷新当前列表
							self:updateList(self._listType)
						end
					end)
				end
			end)
			
			--显示其他支付页面
			showPopupLayer(
			PaymentLayer:create(price, count, itemid, function(result)
				
				if 0 == result then
					
					--刷新游戏豆列表
					--self:requestBeanList()
					
					--刷新用户分数信息
					RequestManager.requestUserScoreInfo(function(result, message)
						
						if type(message) == "string" and message ~= "" then
							showToast(nil, message, 2)		
						end
						
						if 0 == result then
							--刷新当前列表
							self:updateList(self._listType)
						end
					end)
				end
			end)
			)
			
		end
		
	elseif listType == PaymentType.Bean then
		
		--判断游戏豆是否足够
		if GlobalUserItem.dUserBeans == 0 or GlobalUserItem.dUserBeans < price then
			showToast(nil, "您的游戏豆不足，请先进行充值！", 2)
			return
		end
		
		--购买道具数量
		local propertyCount =(index == self:getListCount(listType) and price or 1)
		
		local callback = function(isOK)
			
			if isOK then
				showPopWait()
				
				--购买游戏币
				self._shopDetailFrame:onPropertyBuy(yl.CONSUME_TYPE_CASH, propertyCount, itemid, 0)
			end
		end
		
		QueryDialog:create("您要使用 " .. price .. " 游戏钻兑换 " .. count .. " 游戏币吗？", callback, nil, QueryDialog.QUERY_SURE_CANCEL)
		:addTo(self)
	elseif listType == ListType.RoomCard then
		
		--判断游戏豆是否足够
		if GlobalUserItem.dUserBeans == 0 or GlobalUserItem.dUserBeans < price then
			showToast(nil, "您的游戏钻不足，请先进行充值！", 2)
			return
		end
		
		--购买道具数量
		local propertyCount = price
		
		local callback = function(isOK)
			
			if isOK then
				showPopWait()
				
				--购买房卡
				self._shopDetailFrame:onPropertyBuy(yl.CONSUME_TYPE_CASH, propertyCount, itemid, 0)
			end
		end
		
		QueryDialog:create("您要使用 " .. price .. " 游戏钻兑换 " .. count .. " 房卡吗？", callback, nil, QueryDialog.QUERY_SURE_CANCEL)
		:addTo(self)
	end
end

------------------------------------------------------------------------------------------------------------
-- 界面操作
--获取列表数量
function ShopLayer:getListCount(listType)
	
	--游戏豆
	if listType == ListType.Bean then
		return GlobalUserItem.tabShopCache.shopBeanList and #GlobalUserItem.tabShopCache.shopBeanList or 0
		
		--游戏币
	elseif listType == ListType.Gold then
		return GlobalUserItem.tabShopCache.shopGoldList and #GlobalUserItem.tabShopCache.shopGoldList or 0
		
		--房卡
	elseif listType == ListType.RoomCard then
		return GlobalUserItem.tabShopCache.shopRoomCardList and 8 or 0
	elseif listType == ListType.VIP then
		return GlobalUserItem.tabShopCache.shopVipList and #GlobalUserItem.tabShopCache.shopVipList or 0
	end
	
	return 0
end

--获取列表
function ShopLayer:getListItem(listType, index)
	
	--图标数量
	local icon_counts = {7, 8, 1,8}
	--图标前缀
	local icon_prefixs = {"icon_bean_", "icon_gold_", "icon_roomcard_","VipIcon"}
	--热卖状态
	local hot_statuss = {
		{0, 1, 0, 1, 0, 1, 1, 0},
		{1, 1, 0, 1, 1, 1, 0, 0},
		{0, 1, 1, 0, 0, 1, 0, 0},
		{0, 1, 1, 0, 0, 1, 0, 0}
	}
	
	--商品数量
	local itemCount = 0
	local itemPrice = 0
	local itemId = 0
	local Desc   = ""
	local productId = ""
	local flagVisible = false
	local flagText = ""
	local flagFontSize = 27
	local giftVisible = false
	local giftText = ""
	local descriptionVisible = false
	local isHot =(hot_statuss[listType] [index] == 1) --是否热卖
	
	local itemInfo = {}
	if listType == ListType.Bean then
		itemInfo = GlobalUserItem.tabShopCache.shopBeanList[index]
	elseif listType == ListType.Gold then
		itemInfo = GlobalUserItem.tabShopCache.shopGoldList[index]
	elseif listType == ListType.VIP then
		itemInfo = GlobalUserItem.tabShopCache.shopVipList[index]
	end
	--最后两个item添加热卖标志
	local zIconCount = self:getListCount(listType)
	local zIsHot = false
	if index == zIconCount-1 or index == zIconCount then
		zIsHot = true
	end

	itemCount 	= itemInfo.CateName     --道具数量
	itemPrice 	= itemInfo.Price   		--支付额
	itemId 		= itemInfo.CateID 		--道具ID
	productId 	= itemInfo.PayType 		--支付方式:1、游戏豆2、现金
	Desc 		= itemInfo.Desc
	if productId == 3 then
		productId = 2
	end

	if listType ~= 4 then
		--背景
		--local item = cc.Sprite:create("Shop/sp_item_bg.png")
		--local itemSize = item:getContentSize()
		local item = ccui.Button:create("Shop/sp_item_bg.png","Shop/sp_item_bg.png")
		local itemSize = item:getContentSize()
		item:addClickEventListener(function()		
			--原来produciid = productType 内购恒等于2  改为productId = price
			self:onClickPrice(productId, index, itemPrice, itemCount, itemId, itemPrice)
		end)
		
		--热卖
		if zIsHot == true then
			local hot = cc.Sprite:create("Shop/hot.png")
			hot:setAnchorPoint(cc.p(0,1))
			hot:setPosition(cc.p(0+5,itemSize.height-5))
			hot:addTo(item)
		end

		--商品图标
		local iconItem = cc.Sprite:create("Shop/icons/" .. icon_prefixs[listType] ..index--[[(index <= icon_counts[listType] and index or icon_counts[listType])]] .. ".png")
		iconItem:setPosition(itemSize.width / 2, 180)
		iconItem:addTo(item)
		
		--商品数量
		local txtItemCount = cc.Label:createWithTTF(tostring(itemCount), "fonts/round_body.ttf", 26) --cc.LabelAtlas:_create(itemCount, "Shop/sp_number_2.png", 20, 28, string.byte("0"))
		txtItemCount:setAnchorPoint(0.5, 0.5)
		txtItemCount:setPosition(itemSize.width / 2, itemSize.height-30)
		txtItemCount:addTo(item)
		
		--商品描述
		local txtItemDescription = ccui.Text:create("", "fonts/round_body.ttf", 18)
		txtItemDescription:setColor(cc.c3b(179, 151, 117))
		txtItemDescription:setPosition(itemSize.width / 2, 92)
		txtItemDescription:setVisible(descriptionVisible)
		txtItemDescription:addTo(item)
		
		--标签背景
		--[[local flagBg = cc.Sprite:create("Shop/sp_flag_bg.png")
		flagBg:setPosition(56, 195)
		flagBg:setVisible(flagVisible)
		flagBg:addTo(item)
		
		--标签文本
		local txtFlag = ccui.Text:create(flagText, "fonts/round_body.ttf", flagFontSize)
		txtFlag:setPosition(42, 80)
		txtFlag:enableOutline(cc.c3b(208, 22, 21), 3)
		txtFlag:setRotation(- 45)
		txtFlag:addTo(flagBg, 1)]]
		
		--赠送背景
		--[[local giftBg = cc.Sprite:create("Shop/sp_gift_bg.png")
		giftBg:setPosition(198, 236)
		giftBg:setVisible(giftVisible)
		giftBg:addTo(item)
		
		--赠送文本
		local txtGift = ccui.Text:create(giftText, "fonts/round_body.ttf", 22)
		txtGift:setPosition(54, 27)
		txtGift:enableOutline(cc.c3b(5, 110, 0), 1)
		txtGift:addTo(giftBg)]]
		
		--价格按钮
		local btnPrice = cc.Sprite:create("Shop/btn_price_0.png")
		btnPrice:setPosition(itemSize.width / 2, 42)
		btnPrice:addTo(item)
		--btnPrice:addClickEventListener(function()
			
			--self:onClickPrice(btnPrice._productid, index, btnPrice._price, btnPrice._count, btnPrice._itemid, btnPrice._productid)
		--end)
		btnPrice._price = itemPrice		--价格
		btnPrice._count = itemCount 	--数量
		btnPrice._itemid = itemId 		--道具ID
		btnPrice._productid = productId --支付方式
		
		--价格按钮内容
		--[[local txtPrice = ccui.Text:create(listType == ListType.Bean and "￥" .. itemPrice or itemPrice, "fonts/round_body.ttf", 36)
		txtPrice:setPosition(95, 35)
		txtPrice:enableOutline(cc.c3b(176, 71, 30), 2)
		txtPrice:addTo(btnPrice)]]

		local txtPrice =  cc.Label:createWithTTF(itemPrice .. "元", "fonts/round_body.ttf", 26) --cc.LabelAtlas:_create(itemPrice, "Shop/sp_number_3.png", 22, 32, string.byte("0"))
		txtPrice:setAnchorPoint(0.5, 0.5)
		txtPrice:setPosition(95, 25)
		txtPrice:addTo(btnPrice)
		
		--兑换类型显示游戏豆图标
		local str_iconpath = ""
		--print("支付方式"..productId)
		if productId == PaymentType.Rmb then
			str_iconpath = "Shop/icon_rmb.png"
		else
			str_iconpath = "Shop/icon_bean.png"
		end	
		--价格按钮图标
	--	local iconPrice = cc.Sprite:create(str_iconpath)
	--	iconPrice:addTo(btnPrice)
		
		local priceBtnWidth = btnPrice:getContentSize().width
		local priceTextWidth = txtPrice:getContentSize().width
		--local priceIconWidth = iconPrice:getContentSize().width
			
		--调整位置
		local iconX =(priceBtnWidth  - priceTextWidth - 4) / 2 
		--iconPrice:setPosition(iconX, 33)
		txtPrice:setPosition(iconX  + priceTextWidth / 2 + 4, 25)
		
		
		return item
	else

		local lab_wx = string.sub(Desc,string.find(Desc,":")+1,string.len(Desc))

		local item = ccui.Button:create("Shop/VIPlistBG.png","Shop/VIPlistBG.png")
		local itemSize = item:getContentSize()
		item:addClickEventListener(function()		
			self:onclickOpenWx(lab_wx)
		end)
		
		--商品图标
		local iconItem = cc.Sprite:create("Shop/icons/VipIcon.png")
		iconItem:setPosition(itemSize.width / 2, 200)
		iconItem:addTo(item)
		
		--商品描述
		local txtItemDescription = ccui.Text:create(Desc, "fonts/round_body.ttf", 26)
		txtItemDescription:setColor(cc.c3b(255, 246, 192))
		txtItemDescription:setPosition(itemSize.width / 2, 110)
		txtItemDescription:addTo(item)
	
		--价格按钮
		local btnPrice = cc.Sprite:create("Shop/VipBtn.png")
		btnPrice:setPosition(itemSize.width / 2, 50)
		btnPrice:addTo(item)

		return item
	end
	
end

function ShopLayer:onclickOpenWx(  lab_wx )
    if self._dialog then
        return
    end
    self._dialog = QueryDialog:create("微信号["..lab_wx.."]已复制，是否打开微信",function(bReTry)
                if bReTry == true then
                    MultiPlatform:getInstance():copyToClipboard(lab_wx)
                    self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(function ( )
                        MultiPlatform:getInstance():openWX()
                        self._dialog = nil
                    end)))
                else
                    self._dialog = nil
                end
            end)
        :setCanTouchOutside(false)
        :addTo(self)

end

--更新列表 
function ShopLayer:updateList(listType)
	
	--非当前选择的列表，不更新
	if self._listType ~= listType then
		return
	end
	
	--清空列表
	self._listContainer:removeAllChildren()
	
	local marginX		= 38  --X边距
	local marginY		= 28  --Y边距
	local spaceX			= 30  --X间距
	local spaceY			= 20  --Y间距
	
	local listCount		= self:getListCount(listType)
	local colCount		= 4
	local lineCount		= math.ceil(listCount / colCount)
	local itemSize		= cc.size(258, 319)
	local contentSize	= self._listContainer:getContentSize()
	local containerWidth	= contentSize.width
	local containerHeight = marginY * 2 + lineCount * itemSize.height +(lineCount - 1) * spaceY;
	
	--判断容器高度是否小于最小高度
	if containerHeight < contentSize.height then
		containerHeight = contentSize.height
	end
	
	--设置容器大小
	self._listContainer:setInnerContainerSize(cc.size(containerWidth, containerHeight))
	
	--创建列表
	for i = 0, listCount - 1 do
		
		while true do
			
			if yl.APPSTORE_VERSION and (i == 7  or i == 0 ) then
				break
			end
		
			local row	= math.floor(i / colCount)
			local col	= i % colCount
			local x		=(marginX + itemSize.width / 2 + col *(spaceX + itemSize.width))

			if yl.APPSTORE_VERSION and i<4 then
				 x		=(marginX + itemSize.width / 2 + (col-1) *(spaceX + itemSize.width))
			end

			local y		= containerHeight -(marginY + itemSize.height / 2 + row *(spaceY + itemSize.height))
			
			local item	= self:getListItem(listType, i + 1)
			item:setPosition(x, y+20)
			item:addTo(self._listContainer)


			break
		end
		

	end
end

------------------------------------------------------------------------------------------------------------
-- ShopDetailFrame 回调
function ShopLayer:onShopDetailCallBack(result, message)
	
	print("======== ShopLayer:onShopDetailCallBack ========")
	
	dismissPopWait()
	
	if type(message) == "string" and message ~= "" then
		showToast(nil, message, 2)		
	end
	
	--道具购买成功
	if result == 1 then
		
		--刷新用户分数信息
		RequestManager.requestUserScoreInfo(function(result, message)
			
			if type(message) == "string" and message ~= "" then
				showToast(nil, message, 2)		
			end
			
			if 0 == result then
				--刷新当前列表
				self:updateList(self._listType)
			end
		end)
	end
	
	--需要返回道具是否自己使用，否则底层默认使用该道具
	return true
end

------------------------------------------------------------------------------------------------------------
-- 网络请求
--获取游戏豆列表
function ShopLayer:requestBeanList()
	
	self._activity:start()
	
	local url = yl.HTTP_URL .. "/WS/MobileInterface.ashx"
	local ostime = os.time()
	appdf.onHttpJsionTable(url, "GET", "action=GetPayProduct&userid=" .. GlobalUserItem.dwUserID .. "&time=" .. ostime .. "&signature=" .. GlobalUserItem:getSignature(ostime) .. "&typeID=1", function(jstable, jsdata)
		print("print shop jstable:")
		appdf.printTable(jstable)
		print("print shop jsdata:")
		appdf.printTable(jsdata)
		
		--对象已经销毁
		if not appdf.isObject(self) then
			return
		end
		
		self._activity:stop()
		
		if type(jstable) ~= "table" then
			return
		end
		
		local msg = jstable.msg
		if type(msg) == "string" then
			
			--弹出消息
		end
		
		local data = jstable.data
		if type(data) ~= "table" then
			return
		end
		
		--是否首充
		--GlobalUserItem.bFirstPay = not(data.IsPay == 1)
		
		local list = data.list
		if type(list) ~= "table" then
			return
		end
		
		--排序
		table.sort(list, function(a, b)
			return a.SortID < b.SortID
		end)
		print("print shop list:")
		appdf.printTable(list)
		--保存
		GlobalUserItem.tabShopCache.shopBeanList = list
		
		--更新游戏豆列表
		self:updateList(ListType.Bean)
	end)
end

--获取道具列表
function ShopLayer:requestPropertyList(typeID)
	
	self._activity:start()
	

	local _webFrame = WebFrame:create(nil, function(result, message)

    end,true)

    local action = {}
    local pargams = {4,1}
    local action2 = cjson.encode(pargams)
	_webFrame:wsSendString(action2) 

end

function ShopLayer:shuffle(t)
    if type(t)~="table" then
        return
    end
    local tab={}
    local index=1
    while #t~=0 do
        local n=math.random(0,#t)
        if t[n]~=nil then
            tab[index]=t[n]
            table.remove(t,n)
            index=index+1
        end
    end
    return tab
end

return ShopLayer 