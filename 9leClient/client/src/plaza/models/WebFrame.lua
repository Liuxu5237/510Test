local WebFrame = class("WebFrame")

--ws://59.111.94.110:8099/  ws://ioslogin.5185931.com:8099/
-- if device.platform == "ios" then
--     WebFrame._webSocket= WebSocket:create("ws://ioslogin.5185931.com:8099/")     
-- else 
--     WebFrame._webSocket= WebSocket:create("ws://androidlogin.5185931.com:8099/")  
-- end
--g_webSocket= WebSocket:create("ws://59.111.94.110:8099/")      

g_webSocket = nil

function WebFrame:getInstance()
    
    if nil == g_webSocket then
        if device.platform == "ios" then
           g_webSocket= WebSocket:create("ws://logon.hjy510.com:8099/")  
        else 
            g_webSocket= WebSocket:create("ws://logon.hjy510.com:8099/")  
        end 
    
    end

    return g_webSocket
end

--切屏通知
local listenerCustom=cc.EventListenerCustom:create("APP_ENTER_BACKGROUND_ENENT_WEBCLOSE",function (event)
    -- WebFrame:onCloseWebSocket2222()
end)  
local listenerCustom2=cc.EventListenerCustom:create("APP_ENTER_BACKGROUND_ENENT_WEBRECONNECTED",function (event)
    yl.isShuashuashua = true
    if yl.IsWxEnterBack ~=true  then
        yl.DidEnterBackground = true
        WebFrame:onCloseWebSocket2222()
    end
end)  
local customEventDispatch=cc.Director:getInstance():getEventDispatcher()
customEventDispatch:addEventListenerWithFixedPriority(listenerCustom, 1)
customEventDispatch:addEventListenerWithFixedPriority(listenerCustom2, 1)

function WebFrame:getSocketState(  )
    if g_webSocket ~= nil then
        return g_webSocket:getReadyState()
    end
end

function WebFrame:ctor(view,callback,isHttp)
    if yl.CurrentScene ~= yl.nowScene.Z_LOGONSCENE then
        WebFrame:getInstance()
    end
    
    --print("开启" .. g_webSocket:getReadyState())
    --print(string.format("%p",self._web))
    self._viewFrame = view
    self._callBack = callback
	
    --self._strData = nil
    self._IsHttp  = isHttp

    self._connectCount = 1

    if nil ~= g_webSocket then 
        
        g_webSocket:registerScriptHandler(handler(self, self.wsSendTextOpen),cc.WEBSOCKET_OPEN) 
        g_webSocket:registerScriptHandler(handler(self, self.wsSendTextMessage),cc.WEBSOCKET_MESSAGE) 
        g_webSocket:registerScriptHandler(handler(self, self.wsSendTextClose),cc.WEBSOCKET_CLOSE) 
        g_webSocket:registerScriptHandler(handler(self, self.wsSendTextError),cc.WEBSOCKET_ERROR) 
    end 
    
end


function WebFrame:reLogonCallBack( result,message2 )
   
        local this = self
        dismissPopWait()
        print("登录webframe" .. message2)
        local action2 = cjson.encode(message2)
        local message = cjson.decode(message2)
           
        if message[2] == 102 then
            yl.IsWxEnterBack = false
  
            local strdata1 = WebFrame:getStrData()
               
            if strdata1~=nil then
                   
                WebFrame:wsSendString(strdata1)
            end
            
           if yl.isShuashuashua == true then
                local eventListener = cc.EventCustom:new("ry_WebConnectGame")
                cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
           end
	
    
        end
    
end
--websocket handler
function WebFrame:wsSendTextOpen(strData)
    print("Send Text WS was opened.") 
    print("open status" .. g_webSocket:getReadyState())


    if yl.reConnectWebInit  == true then

        yl._clientConnectedCount = 0

        yl.reConnectWebInit  = false
        yl.isClientConnectedFailed  = true

        --在这停定时器 我看你怎么办 小伙子
        if yl.dddddschedule then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(yl.dddddschedule)
            yl.dddddschedule = nil
        end

        if g_webSocket:getReadyState() == 1 then
            WebFrame:create(self, function(result, message2)
                if self.reLogonCallBack then
                    self:reLogonCallBack(result,message2)
                end
           end)
           g_webSocket:sendString(yl.logonMsg)
        else
			yl._clientConnectedCount  = yl._clientConnectedCount +1
        end
    end

    if yl.CurrentScene == yl.nowScene.Z_LOGONSCENE then
        --print("登ddd" .. yl.webStrdata)
     
        yl._clientConnectedCount = 0
        yl.isClientConnectedFailed  = false

        if yl.LogonSchedule then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(yl.LogonSchedule)
            yl.LogonSchedule = nil
        end
        
        if self._callBack == nil    then
            --如果是空 发通知去登陆重新建立callback 再发送
            local eventListener = cc.EventCustom:new("ry_ReConnectLogonCallback")
            cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
        else
            g_webSocket:sendString(yl.webStrdata)
        end
        
    end
    --开启心跳
    self:start()
    yl.isClientBack = false
end

function WebFrame:wsSendTextMessage(strData)
    
    --self:reset()
    if self._IsHttp == true then
        self._IsHttp=false
        self._callBack(0,strData)
        return
    end
    if self._callBack == nil then
        return
    end
    if strData == "[0,1]" then
        print("心跳")
        return
    end
    --if string.find( strData,"1,100,") == nil  or string.find( strData,"2,99,") == nil then
       --dump(yl.webStrdata)
        yl.webStrdata = nil
    --end

    if type(strData) ~= "table" then
        --1,106 -> 1,106, 
        if string.find( strData,"1,106,") ~= nil then
            print("重斤游戏" .. strData)
            local message = cjson.decode(strData)
            yl.isReExit = true
            if message[3]["KindID"] == 102 then
                return
            end
            yl.reKindID = message[3]["KindID"]
            yl.reServerID = message[3]["ServerID"]
            return
        end
        if string.find( strData,"3,107,") ~= nil then
            local message = cjson.decode(strData)
            dump(message)
            yl.GAME_CURNUMBER   = message[3]["Num"]
            yl.GAME_TARNUMBER  = 3 
            yl.GAME_BOOSNUMBER = yl.GAME_TARNUMBER

            return
        end
        if string.find( strData,"3,108,") ~= nil then
            local message = cjson.decode(strData)
            dump(message)

            local eventListener = cc.EventCustom:new("ry_GetHbAward")
            eventListener._usedata = {["Hbmessage"] = message}
            cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)

            return
        end
        if string.find( strData,"6,255,") ~= nil then
            local message = cjson.decode(strData)
            --dump(message)
            if message[3]["T"] == 4 then

                function split( str,reps )
                    local resultStrList = {}
                    string.gsub(str,'[^'..reps..']+',function ( w )
                        table.insert(resultStrList,w)
                    end)
                    return resultStrList
                end

                if message[3]["C"] == nil then
                    return
                end
                local notice = split(message[3]["C"],"|")
                if notice[4] ~=nil then
                    return
                end
                local str 
                if notice[3] == nil then
                   return
                end
                if tonumber(notice[3]) < 10000000  then
                    str = "".. "恭喜玩家【"..notice[1].."】在"..notice[2].."赢得【"..notice[3].."】金币，真是可喜可贺！" 
                elseif tonumber(notice[3]) >= 10000000 and tonumber(notice[3]) < 20000000 then 
                    str = "".. "恭喜玩家【"..notice[1].."】在"..notice[2].."天降洪福一举暴击赢得【"..notice[3].."】金币！"
                    
                elseif tonumber(notice[3]) >= 20000000 then
                    str = "".. "恭喜玩家【"..notice[1].."】在"..notice[2].."绝技梭哈【"..notice[3].."】金币，让我们一起顶礼膜拜！"
                end

                local eventListener = cc.EventCustom:new("ry_GetGameNotice")
                eventListener._usedata = {["NoticeMsg"] = str}
                cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)

            elseif message[3]["T"] == 3  and message[3]["R"] ~= 1 then     --后台发布公告直接显示
                local str = message[3]["C"]
                local eventListener = cc.EventCustom:new("ry_GetNetNotice")
                eventListener._usedata = {["NoticeMsg"] = str , ["NoticeType"] = 1}
                cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
            elseif message[3]["T"] == 3  and message[3]["R"] == 1 then
                print("R= 1" , message[3]["C"])
                yl.m_RepeatNotice = message[3]["C"]
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

            elseif message[3]["T"] == 8 then     --停服公告直接显示
                local str = message[3]["C"]
                local eventListener = cc.EventCustom:new("ry_GetGameNotice")
                eventListener._usedata = {["NoticeMsg"] = str}
                cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
            end
            if message[3]["T"] == 2000 then
                -- showToast(nil,"房间暂时关闭",2)
                
                -- if self._viewFrame._viewFrame.onExitTable and self._viewFrame._viewFrame.onExitRoom then
                --     self._viewFrame._viewFrame:onExitTable()
                --     self._viewFrame._viewFrame:onExitRoom(-1,nil)
                -- end
                
            end
            if message[3]["T"] == 1000 and message[3]["C"] == 31 and yl.isTT ~= true then
                 local eventListener = cc.EventCustom:new("ry_WebClose")
                 eventListener._usedata = {["msg"] = 2}
                 cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
                 
            end
            if message[3]["T"] == 1000 and message[3]["C"] == 216 then
                yl.isTT = true
                local eventListener = cc.EventCustom:new("ry_WebClose")
                 eventListener._usedata = {["msg"] = 3}
                 cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
                if self._viewFrame and self._viewFrame.onSocketEvent then
                    self._viewFrame:onSocketEvent(777,31)
                 end
            end
            --金币不足被弹出
            if message[3]["T"] == 2 and message[3]["C"] == 5 then
                yl.isOuted = true
                local eventListener = cc.EventCustom:new("ry_KillClock")
                cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
            end
            return
        end

        if string.find( strData,"6,200,") ~= nil then
            local message = cjson.decode(strData)
            dump(message)
            if  self._viewFrame.onSocketEvent ~= nil then
                self._viewFrame:onSocketEvent(message[1],message[2],message[3])
            end
            return
        end

    else
        -- if cjson.decode(strData)[1] == 1 and cjson.decode(strData) == 102  then
        --     return
        -- end
    end
    
    
    if  self._viewFrame ~= nil and self._viewFrame._roomInfo ~= nil and self._viewFrame._roomInfo.wKindID == 601 then
       if type(strData)~= "table"  then
            
        elseif type(strData) == "table" then

            local len = table.getn(strData)
            local mid, sid = strData[5], strData[7]+strData[8]*256
            if  mid == 6 and sid == 101 then
                mid = 100
            end

            if mid == 8  then
                mid = 3
            end
            if mid  == 9 then
                mid = 200
            end
            
            --捕鱼控制命令
            if sid == 165 then
                sid = 305
            elseif sid == 76 then
                sid = 406
            elseif sid == 92 then
                sid = 512
            elseif sid == 90 then
                sid = 510
            elseif sid == 88 then
                sid = 508
            elseif sid == 87 then 
                sid = 507
            end

    
            local cmd = CCmd_Data:create(len-8)
            cmd:setcmdinfo(mid, sid)
            cmd:resetread()
            for i=9,len,1 do
                cmd:pushbyte(strData[i])
            end
            cmd:resetread()
            print("websocket"..len.."["..mid..","..sid.."]")
            local str = "["
            for i=9,len,1 do
                str = str..string.format("%02X", strData[i])
            end
            print(str.."]")
            --捕鱼
            if self._viewFrame and self._viewFrame.onScoketRyFish and self._viewFrame._roomInfo.wKindID == 601 then
                self._viewFrame:onScoketRyFish(cmd)
            end
            return
        end

    end

    if type(strData) == "table" then
        local len = table.getn(strData)
        local mid, sid = strData[5], strData[7]+strData[8]*256


        local cmd = CCmd_Data:create(len-8)
        cmd:setcmdinfo(mid, sid)
        cmd:resetread()
        for i=9,len,1 do
            cmd:pushbyte(strData[i])
        end
        cmd:resetread()
        print("websocket"..len.."["..mid..","..sid.."]")
        local str = "["
        for i=9,len,1 do
            str = str..string.format("%02X", strData[i])
        end
        print(str.."]")
        local cm1 = cmd
        if self._viewFrame and self._viewFrame.onSocketEvent then
            self._viewFrame:onSocketEvent(mid,sid,cmd)
        end
       
        return
    end
	local strInfo= "websocket "..strData..", "   
	print(strInfo)
    if self._viewFrame and self._viewFrame._gameFrame and self._viewFrame._gameFrame.webLogonGameCallBack then
        print("self._viewFrame._gameFrame:webLogonGameCallBack")
        self._viewFrame._gameFrame:webLogonGameCallBack(0,strData)
    elseif  self._viewFrame and self._viewFrame.onSocketEvent and self._viewFrame._roomInfo~=nil then
        if self._viewFrame._roomInfo.wKindID == 1040 then
            local msg =    cjson.decode(strData)
            if msg[1] == 9 and msg[2] == 103 then
                self._viewFrame:onSocketEvent(msg[1],msg[2],msg[3])
            elseif msg[1] == 9 and msg[2] == 130 then
                self._viewFrame:onSocketEvent(msg[1],msg[2],msg[3])
            elseif msg[1] == 9 and msg[2] == 131 then
                self._viewFrame:onSocketEvent(msg[1],msg[2],msg[3])
            else
                self._callBack(0,strData)
            end
        else
            self._callBack(0,strData)
        end
    else	
	    self._callBack(0,strData)
    end
end


function WebFrame:wsSendTextClose(strData)
    print("_wsiSendText websocket instance closed.") 
    --print("关闭状态" .. g_webSocket:getReadyState())
    --print("关闭后重连")

    g_webSocket = nil 
    self._viewFrame = nil
    self._callBack  = nil
    --self._strData   = nil
    self._IsHttp    = nil
    
    if yl.heartSchedule ~= nil then
        print(" 停止计时器")
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(yl.heartSchedule)
        yl.heartSchedule = nil
    end

    if yl.CurrentScene ~= yl.nowScene.Z_LOGONSCENE then
        if yl.isClientBack ~= true or yl.DidEnterBackground == true then
            yl.DidEnterBackground = false
            local eventListener = cc.EventCustom:new("ry_WebClose")
            eventListener._usedata = {["msg"] = 1}
            cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
        end
    end
    
    -- if yl.isClientBack ~= true then
    -- --断开后 大厅 收到消息重连
    --     local eventListener = cc.EventCustom:new("ry_WebClose")
    --     eventListener._usedata = {["msg"] = 1}
    --     cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
    -- end
    -- if yl.DidEnterBackground == true then
    --     yl.DidEnterBackground = false
    --     local eventListener = cc.EventCustom:new("ry_EnterBackWebClose")
    --     eventListener._usedata = {["msg"] = 1}
    --     cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
    -- end

    -- --断开后 子游戏重连
    -- if self._viewFrame and self._viewFrame.onSocketEvent then
    --     self._viewFrame:onSocketEvent(777,32)
    -- end
    
end

function WebFrame:wsSendTextError(strData)
	print("sendText Error was fired") 
end

function WebFrame:wsInitWebScoket(  )

    -- added by luis 上一个websocket对象还没有销毁 需要把消息注销掉
    if g_webSocket and not tolua.isnull(g_webSocket) then
        g_webSocket:unregisterScriptHandler(cc.WEBSOCKET_OPEN);
        g_webSocket:unregisterScriptHandler(cc.WEBSOCKET_MESSAGE);
        g_webSocket:unregisterScriptHandler(cc.WEBSOCKET_CLOSE);
        g_webSocket:unregisterScriptHandler(cc.WEBSOCKET_ERROR);
        g_webSocket = nil
    end
    
    WebFrame:getInstance()
    
    if nil ~= g_webSocket then 
         
        g_webSocket:registerScriptHandler(handler(self, self.wsSendTextOpen),cc.WEBSOCKET_OPEN) 
        g_webSocket:registerScriptHandler(handler(self, self.wsSendTextMessage),cc.WEBSOCKET_MESSAGE) 
        g_webSocket:registerScriptHandler(handler(self, self.wsSendTextClose),cc.WEBSOCKET_CLOSE) 
        g_webSocket:registerScriptHandler(handler(self, self.wsSendTextError),cc.WEBSOCKET_ERROR) 
        
    end
end

function WebFrame:getStrData(  )
    return yl.webStrdata
end
--websocket sendString

function WebFrame:wsSendString(strData)
    print("发送的消息".. strData)
    --print("wsSendString socket status" ..g_webSocket:getReadyState() )
 
    if strData == "[0,1]" then
        g_webSocket:sendString(strData)     
        return
    end

    if yl.CurrentScene == yl.nowScene.Z_LOGONSCENE then
        if g_webSocket then
            if g_webSocket:getReadyState() == 1   then
                g_webSocket:sendString(strData)
            end
        else
            yl.webStrdata = strData
            self:wsInitWebScoket()
        end
        return;
    end

    if g_webSocket ~= nil then
        local a = g_webSocket:getReadyState()

        if a~=1  then
            if string.find( strData,"1,11,") == nil then
                yl.webStrdata = strData
            end        
            g_webSocket:close()
            self:wsInitWebScoket()
            
            if yl.isShuashuashua == false then
                local this = self
                self.sch1 = cc.Director:getInstance():getScheduler():scheduleScriptFunc( function( dt )
                    if this.sch1~=nil then
                        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(this.sch1)
                        this.sch1 = nil
                        if g_webSocket:getReadyState() == 1 then
                            if strData ~= nil then
                                g_webSocket:sendString(strData)            
                            end
                        end
                    end
                  
                end,2,false)
            end
        else
            g_webSocket:sendString(strData)
        end

    -- else
        
    --     local eventListener = cc.EventCustom:new("ry_WebClose")
    --     eventListener._usedata = {["msg"] = 1}
    --     cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
    end
    
    
    return true
end

--webframe 心跳
function WebFrame:start(  )

    local this = self
    if yl.heartSchedule ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(yl.heartSchedule)
    end
    yl.heartSchedule = cc.Director:getInstance():getScheduler():scheduleScriptFunc( function( dt )
        this:wsSendString("[0,1]")  
    end,15,false)

end

function WebFrame:reset(  )
    -- if nil ~= self.heartSchedule then
    --     cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.heartSchedule)        
    --     self.heartSchedule = nil
    -- end
    -- self:start()
end

--退出房间
function WebFrame:onCloseWebSocket(  )
    print("333333")
    if self then

        yl.isClientBack = true
        if g_webSocket ~= nil then
            g_webSocket:close()
        end
        -- self:wsInitWebScoket()
    end
end

function WebFrame:onCloseWebSocket2222(  )
    if yl.CurrentScene == yl.nowScene.Z_LOGONSCENE then
       return
    end
    if g_webSocket~=nil then
        print("onCloseWebSocket2222 status" .. g_webSocket:getReadyState())
        if g_webSocket:getReadyState() == 2 then
            showToast(nil,"神游中",2)
        end
        if g_webSocket:getReadyState() == 3 then
            self:wsSendTextClose()
        else 
            g_webSocket:close()
        end
    end
end


--连接OK
function WebFrame:onConnectCompeleted()
end

--网络信息(短连接)
function WebFrame:onSocketEvent(main,sub,pData)
end

--网络消息(长连接)
function WebFrame:onGameSocketEvent(main,sub,pData)
end

return WebFrame