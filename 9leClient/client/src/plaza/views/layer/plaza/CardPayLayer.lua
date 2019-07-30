--实卡支付页面
local CardPayLayer = class("CardPayLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")

local RequestManager = appdf.req(appdf.CLIENT_SRC.."plaza.models.RequestManager")
local WebFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.WebFrame")

function CardPayLayer:ctor(amount, count)

    local csbNode = ExternalFun.loadCSB("Pay/CardPayLayer.csb"):addTo(self)
    self._content = csbNode:getChildByName("content")

    --关闭
    local btnClose = self._content:getChildByName("btn_close")
    btnClose:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()

        dismissPopupLayer(self)
    end)

    --确定支付
    local btnOK = self._content:getChildByName("btn_ok")
    btnOK:addClickEventListener(function()

        self:onClickOK()
    end)

    --取消支付
    --[[local btnCancel = self._content:getChildByName("btn_cancel")
    btnCancel:addClickEventListener(function()

        self:onClickCancel()
    end)]]

    --卡号
    local spEditCardBg = self._content:getChildByName("sp_edit_card_bg")
    local size = spEditCardBg:getContentSize()
    self._editCard = ccui.EditBox:create(cc.size(size.width - 16, size.height - 16), "")
		    :move(size.width / 2, size.height / 2)
            :setFontSize(30)
            :setFontColor(cc.BLACK)
		    :setFontName("fonts/round_body.ttf")
		    :setMaxLength(50)
            :setPlaceHolder("请输入充值卡号")
            :setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		    :addTo(spEditCardBg)

    --密码
    local spEditPasswordBg = self._content:getChildByName("sp_edit_password_bg")
    size = spEditPasswordBg:getContentSize()
    self._editPassword = ccui.EditBox:create(cc.size(size.width - 16, size.height - 16), "")
		    :move(size.width / 2, size.height / 2)
            :setFontSize(30)
            :setFontColor(cc.BLACK)
		    :setFontName("fonts/round_body.ttf")
		    :setMaxLength(50)
            :setPlaceHolder("请输入充值卡密码")
            :setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		    :addTo(spEditPasswordBg)

    -- 内容跳入
    AnimationHelper.jumpIn(self._content, function()
        
        --编辑框在动画后有BUG，调整大小让编辑框可以显示文字
        self._editCard:setContentSize(self._editCard:getContentSize())
        self._editPassword:setContentSize(self._editPassword:getContentSize())
    end)
end

------------------------------------------------------------------------------------------------------------
-- 事件处理

--确定支付
function CardPayLayer:onClickOK()

    --播放音效
    ExternalFun.playClickEffect()

    --检查参数
    local cardid = self._editCard:getText()
    local cardpwd = self._editPassword:getText()
    
    print("======",cardid,"============",string.len(cardid))
    cardid = string.gsub(cardid," ","")
    cardid = string.gsub(cardid,"\t","")
    cardid = string.gsub(cardid,"\n","")

    cardpwd = string.gsub(cardpwd," ","")
    cardpwd = string.gsub(cardpwd,"\t","")
    cardpwd = string.gsub(cardpwd,"\n","")

    print("======1",cardid,"============",string.len(cardid))
    if cardid == "" then
        showToast(nil, "请输入充值卡号", 2)
        return
    end

    if cardpwd == "" then
        showToast(nil, "请输入充值卡密码", 2)
        return
    end

    local this = self
    local _webframe = WebFrame:create(self, function(result, message)
        dismissPopWait()
        local message2 = cjson.decode(message)
        if message2["code"] == 0 then
            showToast(nil,"充值成功！",2)
            
            --充值成功, 刷新分数信息
            RequestManager.requestUserScoreInfo(nil)
            dismissPopupLayer(this)
            
        elseif message2["code"] == 207 then     -- 密码错误 和卡号不存在 同一个code
            showToast(nil,"抱歉！您要充值的卡号不存在。如有疑问请联系客服中心。",2)
        elseif message2["code"] == 208 then
            showToast(nil,"抱歉！您的充值卡已被使用。如有疑问请联系客服中心。",2)
        elseif message2["code"] == 209 then
            showToast(nil,"抱歉，您已使用过该类型体验卡。如有疑问请联系客服中心。",2)
        elseif message2["code"] == 218 then
            showToast(nil,"抱歉！充值卡已过期，请核查后重试。",2)
        elseif message2["code"] == 219 then
            showToast(nil,"抱歉！您的充值卡密码错误，请核查后重试。",2)
        end
    end)
    
    showPopWait()

    cardpwd = GlobalUserItem.PasswordEncryption(cardpwd)
    
    local action = {}
    action["SerialID"] = cardid
    action["Password"] = cardpwd
    local pargams = {4,11,action}
    local action2 = cjson.encode(pargams)
    _webframe:wsSendString(action2)

    -- --生成订单
    -- local url = yl.HTTP_URL .. "/WS/PayCardFill4Wap.ashx"
    -- local ostime = os.time()
    
    -- local infotable = {}
    -- infotable["UserID"] = "" .. GlobalUserItem.dwUserID
    -- infotable["TimeStamp"] = "" .. ostime
    -- infotable["Sign"] = GlobalUserItem:getSignature(ostime)
    -- infotable["SerialID"] = cardid
    -- infotable["P"] = cardpwd
    -- local action = cjson.encode(infotable)
    -- action = appdf.encodeBase64(action)

    -- showPopWait()

    -- appdf.onHttpJsionTable(url,"POST",action,function(jstable,jsdata)
        
    --     --"{"code":0,"msg":"抱歉！您要充值的卡号不存在。如有疑问请联系客服中心。","data":{"valid":false}}"
    --     dismissPopWait()
    --     print("====card===")
    --     appdf.printTable(jstable )
    --     appdf.printTable(jsdata)
    -- 	if type(jstable) == "table" then
            
    --         if type(jstable["data"]) == "string" and jstable["data"] ~= "" then
    --             showToast(nil, jstable["data"], 2)
    --         end

    --         local ok = jstable["msg"]
    --         if type(ok) == "string" and ok ~= "" then
    --             --充值成功, 刷新分数信息
    --             RequestManager.requestUserScoreInfo(function(result, message)

    --                 if type(message) == "string" and message ~= "" then
    --                     showToast(nil,message,2)		
	--                 end
    --             end)

    --             dismissPopupLayer(self)
    --         end

    --         return
	-- 	end

    --     showToast(nil, "支付异常", 2)
    -- end)
end

--取消支付
function CardPayLayer:onClickCancel()

    --播放音效
    ExternalFun.playClickEffect()

    dismissPopupLayer(self)
end

return CardPayLayer