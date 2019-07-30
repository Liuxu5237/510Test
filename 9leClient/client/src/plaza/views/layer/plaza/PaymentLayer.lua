--支付页面
local PaymentLayer = class("PaymentLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")
local WebFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.WebFrame")

function PaymentLayer:ctor(amount, count, appid, callback,isFirstRecharge)

    --保存参数
    self._amount = amount
    self._count = count
    self._appid = appid
    self._callback = callback
    self._isFistPay = isFirstRecharge

    local csbNode = ExternalFun.loadCSB("Pay/PaymentLayer.csb"):addTo(self)
    self._content = csbNode:getChildByName("content")
    self._txtName = self._content:getChildByName("txt_name")
    self._txtAmount = self._content:getChildByName("txt_amount")

    --温馨提示
    self._content:getChildByName("txt_ts"):setVisible(false)
    self._content:getChildByName("sp_ico"):setVisible(false)

    --设置商品名称
    self._txtName:setString(count .. "游戏币")
    if isFirstRecharge then
        self._txtName:setString("首充礼包")
    end
    --设置价格
    self._txtAmount:setString(amount .. "元")

    --关闭
    local btnClose = self._content:getChildByName("btn_close")
    btnClose:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()

        dismissPopupLayer(self)
    end)

    --微信
    local btnWechatpay = self._content:getChildByName("btn_wechatpay")
    btnWechatpay:addClickEventListener(function()
        
        --播放音效
        ExternalFun.playClickEffect()

        self:onThirdPartyPay(yl.ThirdParty.WECHAT)
    end)

    --支付宝
    local btnAlipay = self._content:getChildByName("btn_alipay")
    btnAlipay:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()

        self:onThirdPartyPay(yl.ThirdParty.zhifu_1)
    end)

    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if cc.PLATFORM_OS_WINDOWS == targetPlatform then
        btnWechatpay:setVisible(false);
        btnAlipay:setPositionX(self._content:getContentSize().width / 2);
    end

    --是否显示支付宝
    -- local bShowAlipay = (device.platform ~= "ios")
    -- btnAlipay:setVisible(bShowAlipay)

    -- if not bShowAlipay then
    --     local x, y = btnWechatpay:getPosition();
    --     btnWechatpay:setPosition(self._content:getContentSize().width / 2, y)
    -- end

    -- 内容跳入
    AnimationHelper.jumpIn(self._content)
end

------------------------------------------------------------------------------------------------------------
-- 事件处理

--第三方支付
function PaymentLayer:onThirdPartyPay(plat)

    local platNameEN = ""
    local platNameCN = ""
    if plat == yl.ThirdParty.WECHAT then
        platNameEN = "wx"
        platNameCN = "微信"
    elseif plat == yl.ThirdParty.zhifu_1 then
        platNameEN = "zfb"
        platNameCN = "支付宝"
    else
        return
    end

    --价格
    --self._amount = 1

    if plat == yl.ThirdParty.WECHAT then
        --判断应用是否安装
        if false == MultiPlatform:getInstance():isPlatformInstalled(plat) then
            showToast(nil, platNameCN .. "未安装, 无法进行" .. platNameCN .. "支付", 2)
            return
        end 

        self:wxZhifu()

    elseif plat == yl.ThirdParty.zhifu_1 then
        self:aliWapPay()
    end
    
end

function PaymentLayer:wxZhifuCallBack( result,message2 )
    
    print("微信支付webframe" .. message2)
    local action2 = cjson.encode(message2)
    local message = cjson.decode(message2)

    dismissPopWait()
    local jstable = message
    print(type(jstable))
    yl.IsWxEnterBack = false
    if nil ~= jstable and type(jstable) == "table" then
        local bSucc = jstable[3]["return_code"]
        if nil ~= bSucc and bSucc == "success" then
            local payparam = {}
            payparam["info"] = cjson.encode(jstable[3])
            --订单id
            payparam["orderid"] = jstable[3]["orderid"]						
            --价格
            payparam["price"] = self._amount
            --商品名
            payparam["name"] = self._txtName:getString()
            local function payCallBack(param)


                if type(param) == "string" and "true" == param then
                    GlobalUserItem.setTodayPay()
                            
                    showToast(nil, "支付成功", 2)

                    self._callback(0)

                    dismissPopupLayer(self)
                else
                    showToast(nil, "支付失败", 2)
                end
            end
            yl.IsWxEnterBack = true
            dump(payparam)
            MultiPlatform:getInstance():thirdPartyPay(yl.ThirdParty.WECHAT, payparam, payCallBack)
        else
            print("支付失败3")
            
            if message["code"] == 210 then
                showToast(nil, "已经首冲过了yo~", 2)
            else
                showToast(nil, "微信支付订单获取异常", 2)
            end
            return
        end
    else
        print("支付失败1")
        showToast(nil, "微信支付订单获取异常", 2)
        return
    end
    
end
-- 微信原生支付
function PaymentLayer:wxZhifu( )
    
    self._webFrame = WebFrame:create(self, function(result, message)
        if self.wxZhifuCallBack then
            self:wxZhifuCallBack(result,message)
        end
    end)

    local infotable = {}
    local url = ""
    if self._isFistPay then

        local action = {}
        action["RcvUserID"] = GlobalUserItem.dwUserID
        action["CateID"]= 1100
        action["dwCount"]= 1
        action["ptype"] = 1     --1 微信充值
        local pargams = {4,10,action}
       
        local action2 = cjson.encode(pargams)
        dump(action2)
        self._webFrame:wsSendString(action2)

    else
    
        local action = {}
        action["RcvUserID"] = GlobalUserItem.dwUserID
        action["CateID"]= self._appid
        action["dwCount"]= 1
        action["ptype"] = 1     --1 微信充值
        local pargams = {4,10,action}
       
        local action2 = cjson.encode(pargams)
        dump(action2)
        self._webFrame:wsSendString(action2)

    end
    -- local action = cjson.encode(infotable)
    -- --print("action= ".. action)
    -- action = appdf.encodeBase64(action)

    showPopWait()

   
end

-- 支付宝web支付
function PaymentLayer:aliWapPay()
    local infotable = {}
    local url = ""
    if self._isFistPay then             --FirstRecharge
         url = "https://bpi.hjy510.com" .. "/PayMobile/AlipayWapGF/AliWapPayHandler.ashx?a="   
        local ostime = os.time()
        infotable["UserID"] = "" .. GlobalUserItem.dwUserID
        infotable["TimeStamp"] = "" .. ostime
        infotable["Sign"] = GlobalUserItem:getSignature(ostime)
        infotable["Totalfee"] = "" .. self._amount
        --infotable["Score"] = self._count
        --infotable["Currency"] = self._appid
        infotable["PropID"] = 1100
    else
        url = "https://bpi.hjy510.com" .. "/PayMobile/AlipayWapGF/AliWapPayHandler.ashx?a="   
        local ostime = os.time()
        infotable["UserID"] = "" .. GlobalUserItem.dwUserID
        infotable["TimeStamp"] = "" .. ostime
        infotable["Sign"] = GlobalUserItem:getSignature(ostime)
        infotable["Totalfee"] = "" .. self._amount
        infotable["PropID"] = self._appid
    end
    local action = cjson.encode(infotable)
    action = appdf.encodeBase64(action)
    
    url = url .. action
    dump(url)
    cc.Application:getInstance():openURL(url)
end

return PaymentLayer