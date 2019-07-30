--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")
local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local ClientConfig = appdf.req(appdf.BASE_SRC .."app.models.ClientConfig")

local IAPLayer = class("IAPLayer",function(scene)
        local gameViewLayer = display.newLayer()
    return gameViewLayer
end)

IAPLayer.CBT_SCORE			= 1
IAPLayer.CBT_BEAN			= 2
IAPLayer.CBT_VIP			= 3
IAPLayer.CBT_PROPERTY		= 4
IAPLayer.CBT_ENTITY		= 5

IAPLayer.BT_SCORE			= 30
IAPLayer.BT_VIP			= 50
IAPLayer.BT_PROPERTY		= 60
IAPLayer.BT_GOODS			= 120
IAPLayer.BT_BEAN			= 520

IAPLayer.BT_ORDERRECORD    = 1001
IAPLayer.BT_BAG            = 1002

local SHOP_BUY = {}
SHOP_BUY[IAPLayer.BT_SCORE] = "shop_score_buy"
SHOP_BUY[IAPLayer.BT_BEAN] = "shop_bean_buy"
SHOP_BUY[IAPLayer.BT_VIP] = "shop_vip_buy"
SHOP_BUY[IAPLayer.BT_PROPERTY] = "shop_prop_buy"
SHOP_BUY[IAPLayer.BT_GOODS] = "shop_goods_buy"

-- 支付模式
local APPSTOREPAY = 10 -- iap支付
local THIRDPAY = 20 -- 第三方支付



function  IAPLayer:ctor(scene)
    self._scene = scene
    local winSize = cc.Director:getInstance():getVisibleSize()
    local  node = cc.CSLoader:createNode("IAP/IAPLayer.csb")
    node:setScale(winSize.width / 1334,winSize.height / 740)
    node:addTo(self)

    self:reloadBeanList()

    local function onToucher(touch,event)
        if event == ccui.TouchEventType.ended then
            self:removeFromParent()
        end
    end

    self._panel = node:getChildByName("Panel_1")
    self._panel:setTouchEnabled(true)
    self._panel:addTouchEventListener(onToucher)
    local nos = node:getChildByName("Image_1")
    local function ipacallback(tag,events)
        if events == ccui.TouchEventType.ended then
            self:onButtonClickedEvent(tag:getTag(),event)
        end
    end

    local function onTouchers(touch,event)

    end
    nos:setTouchEnabled(true)
    nos:addTouchEventListener(onTouchers)
    local lo1 = nos:getChildByName("Button_1")
    lo1:setTag(1)
    lo1:addTouchEventListener(ipacallback)

    local lo2 = nos:getChildByName("Button_2")
    lo2:setTag(2)
    lo2:addTouchEventListener(ipacallback)

   self.m_nPayMethod = APPSTOREPAY
end

function IAPLayer:reloadBeanList()
    --self:onClearShowList()
    GlobalUserItem.tabShopCache["shopBeanList"] = {}
    self._beanList = {}
    self:loadPropertyAndVip(IAPLayer.CBT_BEAN)
end

--按键监听
function IAPLayer:onButtonClickedEvent(tag,sender)
		--游戏豆获取
        local item = self._beanList[tag]
        if nil == item then
            return
        end
        local bThirdPay = true
        showToast(self, "准备开始支付", 2)
        if ClientConfig.APPSTORE_VERSION 
            and (targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD) then
            if self.m_nPayMethod == APPSTOREPAY then
                bThirdPay = false
                local payparam = {}
                payparam.http_url = yl.HTTP_URL
                payparam.uid = GlobalUserItem.dwUserID
                payparam.productid = item.nProductID
                payparam.price = item.price

                self._scene:showPopWait()
                self:runAction(cc.Sequence:create(cc.DelayTime:create(5), cc.CallFunc:create(function()
                    self._scene:dismissPopWait()
                end)))
                showToast(self, "正在连接iTunes Store...", 4)
                local function payCallBack(param)
                    if type(param) == "string" and "true" == param then
                        GlobalUserItem.setTodayPay()

                        showToast(self, "支付成功", 2)
                        --更新用户游戏豆
                        GlobalUserItem.dUserBeans = GlobalUserItem.dUserBeans + item.count
                        --通知更新        
                        local eventListener = cc.EventCustom:new(yl.RY_USERINFO_NOTIFY)
                        eventListener.obj = yl.RY_MSG_USERWEALTH
                        cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)

                        --重新请求支付列表
                        --self:reloadBeanList()

                        --self:updateScoreInfo()
                        --更新房卡
                        self._scene:updateCardRoomNum()
                    else
                        showToast(self, "支付异常", 2)
                    end
                end
                MultiPlatform:getInstance():thirdPartyPay(yl.ThirdParty.IAP, payparam, payCallBack)
            end
        end

--        if bThirdPay then
----            if false == ShopPay:isPayMethodValid() then
----                showToast(self, "支付服务未开通!", 2, cc.c4b(250,0,0,255))
----                return
----            end
--            if nil == self.m_payLayer then
--                self.m_payLayer = ShopPay:create(self)
--                self:addChild(self.m_payLayer)
--            end            
--            local sprice = string.format("%.2f元", item.price)
--            self.m_payLayer:refresh(item.count, item.name, sprice, item.price, item.appid)
--            self.m_payLayer:showLayer(true)
--        end			
end



function IAPLayer:requestPayList(isIap)
    isIap = isIap or 0
    local beanurl = yl.HTTP_URL .. "/WS/MobileInterface.ashx"
    local ostime = os.time()

    self._scene:showPopWait()
    appdf.onHttpJsionTable(beanurl ,"GET","action=GetPayProduct&userid=" .. GlobalUserItem.dwUserID .. "&time=".. ostime .. "&signature=".. GlobalUserItem:getSignature(ostime) .. "&typeID=" .. isIap,function(sjstable,sjsdata)
        dump(sjstable, "支付列表", 6)
        local errmsg = "获取支付列表异常!"
        self._scene:dismissPopWait()
        if type(sjstable) == "table" then
            local sjdata = sjstable["data"]
            local msg = sjstable["msg"]
            errmsg = nil
            if type(msg) == "string" then
                errmsg = msg
            end

            if type(sjdata) == "table" then
                local isFirstPay = sjdata["IsPay"] or "0"
                isFirstPay = tonumber(isFirstPay)
                local sjlist = sjdata["list"]
                if type(sjlist) == "table" then
                    for i = 1, #sjlist do
                        local sitem = sjlist[i]
                        local item = {}
                        item.price = sitem["Price"]
                        item.isfirstpay = isFirstPay
                        item.paysend = sitem["AttachCurrency"] or "0"
                        item.paysend = tonumber(item.paysend)
                        item.paycount = sitem["PresentCurrency"] or "0"
                        item.paycount = tonumber(item.paycount)
                        item.price = tonumber(item.price)
                        item.count = item.paysend + item.paycount
                        item.description  = sitem["Description"]                                        
                        item.name = sitem["ProductName"]
                        item.sortid = tonumber(sitem["SortID"]) or 0
                        item.nOrder = 0
                        item.appid = tonumber(sitem["AppID"])
                        item.nProductID = sitem["ProductID"] or ""

                        --首充赠送
                        if 0 ~= item.paysend then
                            --当日未首充
                            if 0 == isFirstPay then
                                item.nOrder = 1
                                table.insert(self._beanList, item)
                            end
                        else
                            table.insert(self._beanList, item)
                        end                                             
                    end
                    table.sort(self._beanList, function(a,b)
                            if a.nOrder ~= b.nOrder then
                                return a.nOrder > b.nOrder
                            else
                                return a.sortid < b.sortid
                            end
                        end)
                    GlobalUserItem.tabShopCache["shopBeanList"] = self._beanList
                    --self:onUpdateBeanList()
                end
            end
        end

        if type(errmsg) == "string" and "" ~= errmsg then
            showToast(self,errmsg,2,cc.c3b(250,0,0))
        end 
        if #self._beanList == 0 then
            local item = {}
            item.appid       = 1
            item.count       = 0
            item.description = "游戏货币"
            item.isfirstpay  = 0
            item.nOrder      = 0
            item.nProductID  = "1000001"
            item.name        = "5房卡"
            item.paycount    = 0
            item.paysend     = 0
            item.price       = 40
            item.sortid      = 0
            table.insert(self._beanList, item)
            local items = {}
            items.appid       = 2
            items.count       = 0
            items.description = "游戏货币"
            items.isfirstpay  = 0
            items.nOrder      = 0
            items.nProductID  = "1000002"
            items.name        = "10房卡"
            items.paycount    = 0
            items.paysend     = 0
            items.price       = 78
            items.sortid      = 0
            table.insert(self._beanList, items)
        end

        dump(self._beanList,"beanList",6)

    end)
end


--网络请求
function IAPLayer:loadPropertyAndVip(tag)	
	local this = self
    local typid = 0

    local cbt = self:getChildByTag(tag)
    if nil ~= cbt then
        if nil ~= self._shopTypeIdList[cbt:getName()] then
            typid = self._shopTypeIdList[cbt:getName()].TypeID
        end
    end

    --实物特殊处理
    if tag == IAPLayer.CBT_ENTITY then
    	self:onUpdateGoodsList()
    --游戏豆额外处理
    elseif tag == IAPLayer.CBT_BEAN then
        if 0 ~= #self._beanList then
            self:onUpdateBeanList()
            return
        end
    	self._scene:showPopWait()
        if ClientConfig.APPSTORE_VERSION  
            and (targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD) then
            -- 内购开关
            appdf.onHttpJsionTable(yl.HTTP_URL .. "/WS/MobileInterface.ashx","GET","action=iosnotappstorepayswitch",function(jstable,jsdata)
                local errmsg = "获取支付配置异常!"
                if type(jstable) == "table" then
                    local jdata = jstable["data"]
                    if type(jdata) == "table" then
                        local valid = jdata["valid"] or false
                        if true == valid then
                            errmsg = nil
                            local value = jdata["State"] or "0"
                            value = tonumber(value)
                            if 1 == value then
                                GlobalUserItem.tabShopCache["nPayMethod"] = APPSTOREPAY
                                self.m_nPayMethod = APPSTOREPAY
                                self:requestPayList(1)
                            else
                                GlobalUserItem.tabShopCache["nPayMethod"] = THIRDPAY
                                -- 请求列表
                                self:requestPayList()
                            end                            
                        end
                    end
                end

                self._scene:dismissPopWait()
                if type(errmsg) == "string" and "" ~= errmsg then
                    showToast(self,errmsg,2,cc.c3b(250,0,0))
                end
            end)
        else
            -- 请求列表
            self:requestPayList()
        end
    else
        if tag == IAPLayer.CBT_VIP and 0 ~= #self._vipList then
            self:onUpdateVIP()
            return
        elseif tag == IAPLayer.CBT_PROPERTY and 0 ~= #self._propertyList then
            self:onUpdateProperty()
            return
        elseif tag == IAPLayer.CBT_SCORE and 0 ~= #self._scoreList then
            self:onUpdateScore()
            return
        end
        self:requestPropertyList(typid, tag)
    end	
end


return  IAPLayer