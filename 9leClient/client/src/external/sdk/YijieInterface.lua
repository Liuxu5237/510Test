
YijieInterface = class()

    local luaj = require "cocos.cocos2d.luaj"
    local className = "com/snowfish/cn/ganga/base/SFLuaAdaper"



--注册SDK初始化回调
function YijieInterface:setSDKInitListener(callback)

	print("yj call setSDKInitListener ", callback)
	local signs = "(I)V"
	local methodName = "setInitListener"
	local args = {callback}
	luaj.callStaticMethod(className, methodName, args, signs)
end

--注册登陆回调
function YijieInterface:setLoginListener(callback)

	print("yj call setLoginListener ", callback)
	local signs = "(I)V"
	local methodName = "setLoginListener"
	local args = {callback}
	luaj.callStaticMethod(className, methodName, args, signs)
end

--登陆函数
function YijieInterface:login(prama)
	print("yj call login ", prama)
	local signs = "(Ljava/lang/String;)V"
	local methodName = "login"
	local args = {prama}
	luaj.callStaticMethod(className, methodName, args, signs)
end

--登出函数
function YijieInterface:logout(prama)
	print("yj call logout ", prama)
	local signs = "(Ljava/lang/String;)V"
	local methodName = "logout"
	local args = {prama}
	luaj.callStaticMethod(className, methodName, args, signs)
end


--退出函数
function YijieInterface:exit(exitCallback)
	print("yj call exit ")
	local signs = "(I)V"
	local methodName = "exit"
	local args = {exitCallback}
	luaj.callStaticMethod(className, methodName, args, signs)
end

--支付回调扩展函数
function YijieInterface:setPayResultExtendListener(payresultextendCallback)
	print("yj call setPayResultExtendListener ")
	local signs = "(I)V"
	local methodName = "setPayResultExtendListener"
	local args = {payresultextendCallback}
	luaj.callStaticMethod(className, methodName, args, signs)
end


--音乐开关
function YijieInterface:isMusicEnable()
	print("yj call isMusicEnable ")
	local signs = "()Z"
	local methodName = "isMusicEnabled"
	local args = {}
	local ok,ret = luaj.callStaticMethod(className, methodName, args, signs)
	if not ok then
		print("callExit error")
		return false
	else
		print("callExit ret:", ret)
		return ret
	end
end


--充值接口
function YijieInterface:charge(name, price, count, callbackInfo, callbackurl, callbackFunc)
	print("yj call charge ", name, price, count, callbackInfo, callbackurl, callbackFunc)
	local signs = "(Ljava/lang/String;IILjava/lang/String;Ljava/lang/String;I)V"
	local methodName = "charge"
	local args = {name, price, count, callbackInfo, callbackurl, callbackFunc}
	luaj.callStaticMethod(className, methodName, args, signs)
end


--支付接口
function YijieInterface:pay(price, name, count, callbackInfo, callbackurl, callbackFunc)
	print("yj call pay ", price, name, count, callbackInfo, callbackurl, callbackFunc)
	local signs = "(ILjava/lang/String;ILjava/lang/String;Ljava/lang/String;I)V"
	local methodName = "pay"
	local args = {price, name, count, callbackInfo, callbackurl, callbackFunc}
	luaj.callStaticMethod(className, methodName, args, signs)
end


--支付扩展接口
function YijieInterface:payExtend(price, name, itemCode, remian, count, callbackInfo, callbackUrl, callbackFunc)
	print("yj call payExtend ", price, name, itemCode, remian, count, callbackInfo, callbackUrl, callbackFunc)
	local signs = "(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;I)V"
	local methodName = "payExtend"
	local args = {price, name, itemCode, remian, count, callbackInfo, callbackUrl, callbackFunc}
	luaj.callStaticMethod(className, methodName, args, signs)
end


--设置角色
function YijieInterface:setRoleData(id, nmae, level, zoneId, zoneName)
	print("yj call setRoleData ", id, nmae, level, zoneId, zoneName)
	local signs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
	local methodName = "setRoleData"
	local args = {id, nmae, level, zoneId, zoneName}
	luaj.callStaticMethod(className, methodName, args, signs)
end


--扩展接口 int
function YijieInterface:setDataInt(key, value)
	print("yj call setDataInt ", key,value)
	local signs = "(Ljava/lang/String;I)V"
	local methodName = "setDataInt"
	local args = {key, value}
	luaj.callStaticMethod(className, methodName, args, signs)
end

--扩展接口 Boolean
function YijieInterface:setDataBoolean(key, value)
	print("yj call setDataBoolean ", key,value)
	local signs = "(Ljava/lang/String;Z)V"
	local methodName = "setDataBoolean"
	local args = {key, value}
	luaj.callStaticMethod(className, methodName, args, signs)
end

--扩展接口 String
function YijieInterface:setDataString(key, value)
  print("yj call setDataString ", key,value)
	local signs = "(Ljava/lang/String;Ljava/lang/String;)V"
	local methodName = "setDataString"
	local args = {key, value}
	luaj.callStaticMethod(className, methodName, args, signs)
end

--扩展接口 float
function YijieInterface:setDataFloat(key, value)
  print("yj call setDataFloat ", key,value)
	local signs = "(Ljava/lang/String;F)V"
	local methodName = "setDataFloat"
	local args = {key, value}
	luaj.callStaticMethod(className, methodName, args, signs)
end


--扩展接口  返回时json例如：{"index":0, "tag":"testTag", "value":"3"}
function YijieInterface:extend(data, count, callbackFunc)
	print("yj call extend ", data,count, callbackFunc)
	local signs = "(Ljava/lang/String;II)V"
	local methodName = "extend"
	local args = {data, count, callbackFunc}
	local ok, ret = luaj.callStaticMethod(className, methodName, args, signs)
	if not ok then
		print("extend error")
		return nil
	else
		print("extend ret", ret)
		return ret
	end
end

--登录成功验证
function YijieInterface:loginCheck(userInfo)
	  local xhr = cc.XMLHttpRequest:new() -- http请求
      xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING -- 响应类型
      local urlStr = cpLoginCheckUrl.."?app="..encodeURI(userInfo["productCode"])
      urlStr = urlStr.."&sdk="..encodeURI(userInfo["channelId"])
      urlStr = urlStr.."&uin="..encodeURI(userInfo["channelUserId"])
      urlStr = urlStr.."&sess="..encodeURI(userInfo["token"])
      print("yj loginCheck=", urlStr)
      xhr:open("GET", urlStr) -- 打开链接
 
      -- 状态改变时调用
      local function onReadyStateChange()
        -- 显示状态文本
        local reponse = string.upper(xhr.response)
        print("yj response = ", reponse)
        if (reponse == "SUCCESS") then
         print("chengg")
        else
            print("shiitt")
      end
    end
 
      -- 注册脚本回调方法
      xhr:registerScriptHandler(onReadyStateChange)
      xhr:send() -- 发送请求	
end
