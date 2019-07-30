--登陆短信验证界面

local LogonCheckUserLayer = class("LogonCheckUserLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")
local WebFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.WebFrame")

require("base.src.app.models.bit")
require("base.src.app.models.AppDF")
require("base.src.app.Toolkits.TimerProxy") --added ycc
local QueryDialog = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.QueryDialog")
function LogonCheckUserLayer:ctor(delegate,phonenum)

    self._delegate = delegate
    self._countDown = 120
    self._mobilePhoneNum = ""..tostring(phonenum)

    --节点事件
    ExternalFun.registerNodeEvent(self)

    local csbNode = ExternalFun.loadCSB("Logon/LogonCheckUser.csb"):addTo(self)
    self._content = csbNode:getChildByName("content")

    --手机号码锤子号还有天宇游

    print("验证喽")
    local str = "****"
    if appdf.CHANNEL_ID == 1004  or appdf.CHANNEL_ID == 2001 then
      str = "****"--self._mobilePhoneNum
    else
       if string.len(self._mobilePhoneNum) == 11 then
        local str1 = string.sub(self._mobilePhoneNum,1,3)
        local str2 = string.sub(self._mobilePhoneNum,8,-1)
        str = str1.."****"..str2
        print(str)
    --[[else
        QueryDialog:create("系统提示".."\n请正确输入手机号码",function(bReTry)
            if bReTry == true then
                self:runAction(cc.Sequence:create(
                    cc.DelayTime:create(0.5),
                    cc.CallFunc:create(function()
                        dismissPopupLayer(self)
                    end)))           
            end            
        end, nil, QueryDialog.QUERY_SURE)
                   :addTo(self)]]
    end
  end

    
   

    local btn_close = self._content:getChildByName("btn_close")
    btn_close:addClickEventListener(function()
        ExternalFun.playClickEffect()
        if appdf.CHANNEL_ID == 1004   then
--        appdf.req(appdf.CHANNE_SDK_SRC.."YijieInterface")  --易接SDK
--        local yijie = YijieInterface.new()
--            yijie:logout("logout")--登出
--            yijie:login("login")       
         self._delegate:onTYYReturnByCheckUser()
       end

        dismissPopupLayer(self)
        end)

    local txt_phonenum = self._content:getChildByName("txt_PhoneNum")
    txt_phonenum:setString(str)


    --确定按钮
    local btn_comfir = self._content:getChildByName("btn_comfir")
    btn_comfir:addClickEventListener(function()
            ExternalFun.playClickEffect()
            
            if appdf.CHANNEL_ID == 1004  or appdf.CHANNEL_ID == 2001 then
                self:onTYYRequestLogonCheckUser()
            else
                self:onRequestLogonCheckUser()
           end

        end)

    --验证码
    self.btnCode = self._content:getChildByName("btn_getcode")
    self.btnCode:addClickEventListener(function()
            ExternalFun.playClickEffect()
            if appdf.CHANNEL_ID == 1004 or appdf.CHANNEL_ID == 2001 then
                self:RequestTYYValidationCode()
            else
                self:RequestValidationCode()
           end
            
        end)

    --倒计时
    self.txt_downcount = self._content:getChildByName("txt_countdown")
    self.txt_downcount:setVisible(false)
    self.txt_downcount:setScaleX(0.92)
    --输入框
    self._editCode = self:onCreateEditBox(self._content:getChildByName("sp_codeinputbg"), "输入验证码", false,true, 6)
end
--请求验证码
function LogonCheckUserLayer:RequestValidationCode()

    --倒计时未结束不能再次请求
    if self._countDown ~= 120 then
        return
    end
    
    self.btnCode:setEnabled(false)
    self.txt_downcount:setString(tostring(self._countDown).."s后重新发送")
    self.txt_downcount:setVisible(true)
    
    self.entryId = cc.Director:getInstance():getScheduler():scheduleScriptFunc( function( dt )
                    if not appdf.isObject(self) then
                        return
                    end
                    if self._countDown <= 0 then
                        self._countDown = 120
                        if self.entryId then
                            cc.Director:getInstance():getScheduler():unscheduleScriptEntry( self.entryId )
                            self.entryId = nil
                        end
                        self.btnCode:setEnabled(true)
                        self.txt_downcount:setVisible(false)
                        return
                    end
                    self._countDown = self._countDown - 1
                    self.txt_downcount:setString(tostring(self._countDown).."s后重新发送")

                    end,1,false)


    local webFrame = WebFrame:create(self, function(result, message2)
        
        local action2 = cjson.encode(message2)
        local message = cjson.decode(message2)
        if type(message) ~= "table" then
            return
        end
        WebFrame:getInstance():close()

        if message[1] == 1 and message[2] == 103 then
            if message[3]["code"] == 1 then
                showToast(nil,"发送成功",2)
            else
                showToast(nil, "发送失败", 3)
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry( self.entryId )
                self.btnCode:setEnabled(true)
                txt_downcount:setVisible(false)
                self._countDown = 120
                
            end
        end

    end)

    local action = {}
    action["A"] = "reset"
    action["mob"]  = self._mobilePhoneNum        
    local pargams = {1,3,action}   

    local action2 = cjson.encode(pargams)       
    webFrame:wsSendString(action2) 

end


--第三方请求验证码
function LogonCheckUserLayer:RequestTYYValidationCode()

    --倒计时未结束不能再次请求
    if self._countDown ~= 120 then
        return
    end
    
    self.btnCode:setEnabled(false)
    self.txt_downcount:setString(tostring(self._countDown).."s后重新发送")
    self.txt_downcount:setVisible(true)
    
    self.entryId = cc.Director:getInstance():getScheduler():scheduleScriptFunc( function( dt )
                    if not appdf.isObject(self) then
                        return
                    end
                    if self._countDown <= 0 then
                        self._countDown = 120
                        if self.entryId then
                            cc.Director:getInstance():getScheduler():unscheduleScriptEntry( self.entryId )
                            self.entryId = nil
                        end
                        self.btnCode:setEnabled(true)
                        self.txt_downcount:setVisible(false)
                        return
                    end
                    self._countDown = self._countDown - 1
                    self.txt_downcount:setString(tostring(self._countDown).."s后重新发送")

                    end,1,false)
    local url = yl.HTTP_URL .. "/WS/VerificationCode2.aspx"
    local infotable = {}
    infotable["UID"] = "" .. self._mobilePhoneNum
    infotable["NUMBER"] = 0
    if appdf.CHANNEL_ID == 1004 then
        infotable["NUMBER"] = 8
    end
    if appdf.CHANNEL_ID == 2001 then
        infotable["NUMBER"] = 7
    end

    
    local action = cjson.encode(infotable)
    action = appdf.encodeBase64(action)

    local prefix = self:getrand()
    if prefix == "" then
        prefix = "abcde"
    end
    action = prefix..action

    appdf.onHttpJsionTable(url ,"POST", action, function(jstable,jsdata)
        --对象已经销毁
        if not appdf.isObject(self) then
            return
        end

        if type(jstable) ~= "table" then
            return
        end
        local data = jstable["data"]
        local msg = jstable["msg"]
        --判断发送是否成功
        if type(msg) == "string" and "" ~= data then
            if msg ~= "success" then
                -- 收到验证码后 
                showToast(nil, data, 3)
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry( self.entryId )
                self.btnCode:setEnabled(true)
                self.txt_downcount:setVisible(false)
                self._countDown = 120
            else
                showToast(nil, data, 3)
            end
        end       
    end)
end
function LogonCheckUserLayer:onExit()
    print("离开")
    if self._player_update ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._player_update)
    end
end

--创建输入框
function LogonCheckUserLayer:onCreateEditBox(spEditBg, strholder, isPassword, isNumeric, maxLength)    
    local inputMode = isNumeric and cc.EDITBOX_INPUT_MODE_NUMERIC or cc.EDITBOX_INPUT_MODE_SINGLELINE

    local sizeBg = spEditBg:getContentSize()
    local editBox = ccui.EditBox:create(cc.size(sizeBg.width - 16, sizeBg.height - 16), "")
        :move(sizeBg.width / 2, sizeBg.height / 2)
        :setFontSize(30)
        :setFontColor(cc.BLACK)
        :setFontName("fonts/round_body.ttf")
        :setPlaceholderFontSize(30)
        :setPlaceHolder(strholder)
        :setMaxLength(maxLength)
        :setInputMode(inputMode)
        :addTo(spEditBg) 
    return editBox
end

--------------------------------------------------------------------------------------------------------------------
-- 事件处理
--确定登陆
function LogonCheckUserLayer:onRequestLogonCheckUser()
    --网站先验证成功直接登陆


    local webFrame = WebFrame:create(self, function(result, message2)
        
        local action2 = cjson.encode(message2)
        local message = cjson.decode(message2)
        if type(message) ~= "table" then
            return
        end
        
        if message[1] == 1 and message[2] == 103 then
            if message[3]["code"] == 1 then
                --走服务器
                self:onLogonAccount()
            else
                showToast(nil, "验证失败", 3)
            end
        end

    end)

    local action = {}
    action["A"] = "bind"
    action["mob"]  = self._mobilePhoneNum
    action["mcode"] = self._editCode:getText()
    action["machineSerial"] = MultiPlatform:getInstance():getMachineId()  
    action["szComputerID2"] = MultiPlatform:getInstance():getMachineId2()   
    local pargams = {1,3,action}   

    local action2 = cjson.encode(pargams)     
    webFrame:wsSendString(action2) 

end


function LogonCheckUserLayer:onTYYRequestLogonCheckUser()
    --网站先验证成功直接登陆

    local codeID = self._editCode:getText()
    local url = yl.HTTP_URL .. "/WS/SMS.ashx"
    local infotable = {}
    infotable["UID"] = "" .. self._mobilePhoneNum
    infotable["NUMBER"] = 0
    if appdf.CHANNEL_ID == 1004 then
        infotable["NUMBER"] = 8
    end
    if appdf.CHANNEL_ID == 2001 then
        infotable["NUMBER"] = 7
    end


    infotable["randcode"] = "" .. codeID
    local action = cjson.encode(infotable)
    action = appdf.encodeBase64(action)

    local prefix = self:getrand()
    if prefix == "" then
        prefix = "abcde"
    end
    action = prefix..action
    --验证验证码
    appdf.onHttpJsionTable(url ,"GET", "action=checkyzm3".."&data="..action, function(jstable,jsdata)

        --对象已经销毁
        if not appdf.isObject(self) then
            return
        end
        if type(jstable) == "table" then
            local data = jstable["data"]
            local msg = jstable["msg"]
            --判断发送是否成功
            if type(msg) == "string" and "" ~= data then
                if msg ~= "success" then
                    -- 收到验证码后 
                    showToast(self, data, 3)
                else
                    --走服务器
                    self:onTYYLogonAccount()
                end

            end
        end
    end)
end


--第三方登陆
function LogonCheckUserLayer:onTYYLogonAccount()
    if self._delegate and self._delegate.onLogonByTyy then
        self._delegate:onLogonByTyy(self._mobilePhoneNum,1)
    end
end

--登陆
function LogonCheckUserLayer:onLogonAccount()
    if self._delegate and self._delegate.onLogonAccountByCheckUser then
        self._delegate:onLogonAccountByCheckUser(1)
    end
end

function LogonCheckUserLayer:onShow()
    
    local px, py = self._content:getPosition()

    self._content:setPosition(px, py + appdf.HEIGHT / 2)

    --动画跳入
    self._content:runAction(cc.EaseBackOut:create(cc.MoveTo:create(0.4, cc.p(px, py))))
end

--获取随机码    
function LogonCheckUserLayer:getrand()
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

return LogonCheckUserLayer