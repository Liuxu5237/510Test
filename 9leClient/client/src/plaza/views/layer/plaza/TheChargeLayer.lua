--设置页面
local TheChargeLayer = class("TheChargeLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")
local HeadSprite = appdf.req(appdf.EXTERNAL_SRC .. "HeadSprite")
local ShopLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.ShopLayer")
local ModifyPasswordLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.ModifyPasswordLayer")
local PaymentLayer = appdf.req(appdf.CLIENT_SRC .. "plaza.views.layer.plaza.PaymentLayer")
local RequestManager = appdf.req(appdf.CLIENT_SRC .. "plaza.models.RequestManager")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")

local FIRSTPAY_PRICE = 6        --首充价格
local REWARD_SCORE = 100000     --首充奖励分数

function TheChargeLayer:ctor(delegate,poplayercallback)
    
    self._delegate = delegate
    self._popLayerCallBcak = poplayercallback
    self._bean = GlobalUserItem.dUserBeans

    --节点事件
    --ExternalFun.registerNodeEvent(self)

    local csbNode = ExternalFun.loadCSB("TheCharge/TheCharge.csb"):addTo(self)
    self._content = csbNode:getChildByName("content")
    local isFirstPay = not GlobalUserItem.bFirstPay
    local payBeforScore = GlobalUserItem.lUserScore
    --设置背景回调
    setbackgroundcallback(function(bEnter)
        if bEnter then
            RequestManager.requestUserScoreInfo(function(result, message)
                if appdf.isObject(self) then
                end
                print("wo;lailemam")
                if type(message) == "string" and message ~= "" then
                    showToast(nil, message, 2)
                end
                if GlobalUserItem.lUserScore > payBeforScore then
                    GlobalUserItem.bFirstPay = true
                    if self._delegate == nil then
                        print("shit1111")
                    return 
                    end

                    self._delegate:isFirstPayUser()
                    if appdf.isObject(self) then
                         removebackgroundcallback()
                         removebackgroundcallback()
                        self:onExit()     
                    end
                end
                
            end)
        end
    end)
    
    --商城
    local btnShopt = self._content:getChildByName("Btn_Shop")
    btnShopt:addClickEventListener(function()
        --播放音效
        ExternalFun.playClickEffect()
        if appdf.CHANNEL_ID == 2001 then

            local payparam = {}
			local ostime = os.time()
			local account = GlobalUserItem.szAccount 
			payparam.billno = ""..ostime..account
			payparam.flag = ""..FIRSTPAY_PRICE
			--payparam.productid = tostring(math.ceil(productid)) --转为string 否则在oc UTF8String报错
			payparam.price = ""..FIRSTPAY_PRICE
			
			showPopWait()
			self:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function()
				dismissPopWait()
			end)))
			showToast(nil, "爱玩悦商店...", 2)
			
			local function payCallBack(param)
				if type(param) == "string" and "true" == param then
					
					showToast(nil, "支付成功", 2)
					
					--刷新游戏豆列表
					self:requestBeanList()
					
					--刷新用户分数信息
					RequestManager.requestUserScoreInfo(function(result, message)
						
						if type(message) == "string" and message ~= "" then
							showToast(nil, message, 2)		
						end
						
						if 0 == result then
							--刷新当前列表
							self:updateList(self._listType)
                            --self._delegate:isFirstPayUser()
						end
					end)
				else
					showToast(nil, "支付失败", 2)
				end
			end
			
			MultiPlatform:getInstance():AWYZF_z(yl.ThirdParty.AYW, payparam, payCallBack)

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
					self:requestBeanList()
					
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
		
        self:requestBeanList()
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
--            price, count, itemid, productid

--            local FIRSTPAY_PRICE = 6        --首充价格
--            local REWARD_SCORE = 100000     --首充奖励分数
--           //  input = tostring(input)
              local lPice = FIRSTPAY_PRICE*100   --单位分所以*100
              local lProp = tostring(REWARD_SCORE)  --道名 购买的金币 唯一的
              local callbackinfo = tostring(lPice)
              callbackinfo = callbackinfo..":"..lProp
              yijie:pay(lPice, lProp, 1, callbackinfo, "", payTYYCallBack)
        
        else
            showPopupLayer(             --价格          数量    项目ID
                PaymentLayer:create(FIRSTPAY_PRICE, REWARD_SCORE, 2, function(result)
                
                if 0 == result then
                    print("回调成功")
                    showToast(nil,"支付成功",2)
                    RequestManager.requestUserScoreInfo(nil)
                    GlobalUserItem.bFirstPay = true
                    self._delegate:isFirstPayUser()
                    -- if appdf.isObject(self) then
                    --     self:onExit()     
                    -- end
                end
                end,isFirstPay)
                )
        end
    end)

    --关闭
    local btnClose = self._content:getChildByName("Btn_Close")
    btnClose:addClickEventListener(function()
        --播放音效
        ExternalFun.playClickEffect()
        self:onExit()
    end)
    -- 内容跳入
    AnimationHelper.jumpIn(self._content)
end

function TheChargeLayer:onExit()
    print("首充退出")
    removebackgroundcallback()
    if self._popLayerCallBcak then
        self._popLayerCallBcak()
    end    
    dismissPopupLayer(self)
end


------------------------------------------------------------------------------------------------------------
-- 事件处理

return TheChargeLayer