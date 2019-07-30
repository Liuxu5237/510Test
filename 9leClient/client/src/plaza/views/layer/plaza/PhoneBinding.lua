--绑定页面
local PhoneBindingLayer = class("PhoneBindingLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")

local ModifyFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.ModifyFrame")
local QueryDialog = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.QueryDialog")
local WebFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.WebFrame")

function PhoneBindingLayer:ctor(delegate)

    --初始化变量
    self._selectedIndex = 1
    self._mobilePhoneNum = ""
    self._verificationCode = ""
    self._countDown = 120
    self._delegate = delegate

    --节点事件
    ExternalFun.registerNodeEvent(self)

    local csbNode = ExternalFun.loadCSB("PhoneBinding/PhoneBinding.csb"):addTo(self)
    self._content = csbNode:getChildByName("content")

    --关闭
    local btnClose = self._content:getChildByName("btn_close")
    btnClose:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()

        dismissPopupLayer(self)
    end)

    --确定按钮
    local btnBinding = self._content:getChildByName("btn_ok")
    btnBinding:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()

        self:onClickBinding()
    end)

    --验证码按钮
    local btngetcode = self._content:getChildByName("btn_getcode")
    btngetcode:addClickEventListener(function()
        --播放音效
        ExternalFun.playClickEffect()
        self:GetMobilePhoneVerificationCode()
        end)
    --输入背景
    local sp_bg = self._content:getChildByName("sp_bg")
    --选项按钮
    --[[for i = 1, 2 do

        local btnTab = self._content:getChildByName("btn_tab_" .. i)
        btnTab:addEventListener(function()
            self:onSelectTab(i)
        end)

        self._btnTabs[i] = btnTab
        self._panels[i] = self._content:getChildByName("panel_" .. i)
    end]]

    --输入框
    self._editExistPhoneNum = self:onCreateEditBox(sp_bg:getChildByName("sp_edit_phone_bg"), "请输入手机号",false, true, 11)
    self._editExistCode = self:onCreateEditBox(sp_bg:getChildByName("sp_edit_code_bg"), "输入验证码",false, true, 6)
    self._editExistCode:setEnabled(false)
    self._editcodebg = sp_bg:getChildByName("sp_edit_code_bg"):setOpacity(100)
    -- 内容跳入
    AnimationHelper.jumpIn(self._content, function()
        
        --编辑框在动画后有BUG，调整大小让编辑框可以显示文字
       
        self._editExistPhoneNum:setContentSize(self._editExistPhoneNum:getContentSize())
        self._editExistCode:setContentSize(self._editExistCode:getContentSize())
    end)
end
-----------------------------------------------------------------------------------------------------------
--请求验证码
function PhoneBindingLayer:GetMobilePhoneVerificationCode()
    self._mobilePhoneNum = self._editExistPhoneNum:getText()
    local len = #self._mobilePhoneNum
    --local filter = string.find(self._mobilePhoneNum, "^[a-zA-Z\128-\254]+$")
    if self._mobilePhoneNum == nil then
        showToast(nil,"请输入您的11位手机号！",2)
        return
    elseif len ~= 11 then
        showToast(nil,"请输入您的11位手机号！",2)
        return
    end

    --倒计时未结束不能再次请求
    if self._countDown ~= 120 then
        return
    end
    
    local btngetcode = self._content:getChildByName("btn_getcode")
    btngetcode:setEnabled(false)
    btngetcode:setOpacity(50)
    local txt_downcount = self._content:getChildByName("txt_downcount")
    txt_downcount:setString(tostring(self._countDown).."秒后重新发送")
    txt_downcount:setVisible(true)
    
    self.entryId = cc.Director:getInstance():getScheduler():scheduleScriptFunc( function( dt )
                    if not appdf.isObject(self) then
                        return
                    end
                    if self._countDown <= 0 then
                        self._countDown = 120
                        cc.Director:getInstance():getScheduler():unscheduleScriptEntry( self.entryId )
                        btngetcode:setEnabled(true)
                        btngetcode:setOpacity(255)
                        txt_downcount:setVisible(false)
                        return
                    end
                    
                    self._countDown = self._countDown - 1
                    txt_downcount:setString(tostring(self._countDown).."秒后重新发送")
                    end,1,false)


    
    local action = {}
    action["mob"] = self._mobilePhoneNum 
    action["A"] = "rcode"
    local pargams = {1,3,action}
   
    local action2 = cjson.encode(pargams)

    
    local _webFrame = WebFrame:create(self, function(result, message2)
        
        local action2 = cjson.encode(message2)
        local message = cjson.decode(message2)
        
        if message[3]["code"] == 0 then
            --走服务器
            self._editExistCode:setEnabled(true)
            self._editcodebg:setOpacity(255)
        elseif message[3]["code"] == 205 then

            showToast(self,"手机号已存在，请更换手机号绑定~",2)
            self._countDown = 120
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry( self.entryId )
            btngetcode:setEnabled(true)
            btngetcode:setOpacity(255)
            txt_downcount:setVisible(false)
        end
           
    end)
    
    _webFrame:wsSendString(action2) 


    -- local url = yl.HTTP_URL .. "/WS/send.aspx"
    -- local infotable = {}
    -- infotable["mobile"] = "" .. self._mobilePhoneNum
    -- infotable["sendtype"] = "" .. "46"
    -- local action = cjson.encode(infotable)
    -- action = appdf.encodeBase64(action)
    -- local prefix = self:getrand()
    -- if prefix == "" then
    --     prefix = "abcde"
    -- end
    -- action = prefix..action

    -- appdf.onHttpJsionTable(url ,"POST", action, function(jstable,jsdata)
    --     --对象已经销毁
    --     if not appdf.isObject(self) then
    --         return
    --     end

    --     if type(jstable) ~= "table" then
    --         return
    --     end
    --     local data = jstable["data"]
    --     local msg = jstable["msg"]
    --     --判断发送是否成功
    --     if type(msg) == "string" and "" ~= data then
    --         if msg ~= "success" then
    --             -- 收到验证码后 
    --             showToast(nil, data, 3)
    --             self._countDown = 120
    --             cc.Director:getInstance():getScheduler():unscheduleScriptEntry( self.entryId )
    --             btngetcode:setEnabled(true)
    --             btngetcode:setOpacity(255)
    --             txt_downcount:setVisible(false)
    --         else
    --             --走服务器
    --             self._editExistCode:setEnabled(true)
    --             self._editcodebg:setOpacity(255)
    --         end
    --     end       
    -- end)
end
------------------------------------------------------------------------------------------------------------
-- 事件处理

function PhoneBindingLayer:onExit()
    print("页面关闭")
    self:stopAllActions()
    if self.entryId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry( self.entryId )
    end
end

--创建编辑框
function PhoneBindingLayer:onCreateEditBox(spEditBg, strholder, isPassword, isNumeric, maxLength)
    
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

--点击绑定
function PhoneBindingLayer:onClickBinding()
    local phonenum = self._editExistPhoneNum:getText()
    local codeid = self._editExistCode:getText()
    local codeidlen = string.len(codeid)
    if phonenum ~= self._mobilePhoneNum then
        showToast(nil,"更改手机号之后请重新获取验证码",2)
        self._countDown = 120
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry( self.entryId )
        self._content:getChildByName("btn_getcode"):setEnabled(true)
        self._content:getChildByName("btn_getcode"):setOpacity(255)
        self._content:getChildByName("txt_downcount"):setVisible(false)
        return
    end
    if codeid == nil or codeidlen ~= 6 then
        showToast(nil,"请输入正确的手机验证码",2)
        return
    end

    local action = {}
    action["mob"] = phonenum
    action["mcode"] = codeid
    local pargams = {1,7,action}
   
    local action2 = cjson.encode(pargams)

    local _webFrame = WebFrame:create(self, function(result, message2)
        
        local action2 = cjson.encode(message2)
        local message = cjson.decode(message2)
        
        if message[3]["code"] == 0 then
            showToast(nil,"绑定成功",2)
            GlobalUserItem.szMobilePhone = phonenum
            if self._delegate and self._delegate.isBindingPhone then
                self._delegate:isBindingPhone()    
            end           
            self:runAction(cc.Sequence:create(
                cc.DelayTime:create(1),
                cc.CallFunc:create(function()
                    dismissPopupLayer(self)
                    end)))
        else
            showToast(nil, "绑定失败", 3)
        end
           
    end)
    
    _webFrame:wsSendString(action2) 


    -- local url = appdf.HTTP_URL.."/WS/BindMobilePhone.aspx"

    -- local infotable = {}
    -- local ostime = os.time()
    -- infotable["UserID"] = "" .. GlobalUserItem.dwUserID
    -- --infotable["Accounts"] = "" .. GlobalUserItem.szAccount
    -- --infotable["Password"] = "" .. GlobalUserItem.szPassword
    -- infotable["Mobile"] = "" .. phonenum
    -- infotable["TimeStamp"] = "" .. ostime
    -- infotable["Code"] = "" .. codeid
    -- infotable["Sign"] = GlobalUserItem:getSignature(ostime)
    -- local action = cjson.encode(infotable)
    -- action = appdf.encodeBase64(action)
    -- local prefix = self:getrand()
    -- if prefix == "" then
    --     prefix = "abcde"
    -- end
    -- action = prefix..action
    -- print(infotable.Mobile)
    -- appdf.onHttpJsionTable(url ,"POST", action, function(jstable,jsdata)

    --         if not appdf.isObject(self) then
    --             return
    --         end
    --         --[[if jstable == 0 then
    --             showToast(nil,"绑定成功",2)
    --             GlobalUserItem.szMobilePhone = phonenum
    --             if self._delegate and self._delegate.isBindingPhone then
    --                 self._delegate:isBindingPhone()    
    --             end           
    --             self:runAction(cc.Sequence:create(
    --                 cc.DelayTime:create(1),
    --                 cc.CallFunc:create(function()
    --                     dismissPopupLayer(self)
    --                     end)))
    --         else
    --             showToast(nil,"绑定失败",2)
    --         end]]
    --         if type(jstable) ~= "table" then
    --             return
    --         end
    --         local data = jstable["data"]
    --         local msg = jstable["msg"]
    --         --判断发送是否成功
    --         if type(msg) == "string" and "" ~= data then
    --             if msg ~= "success" then
    --                 -- 收到验证码后 
    --                 showToast(nil, data, 3)
    --             else
    --                 showToast(nil,"绑定成功",2)
    --                 GlobalUserItem.szMobilePhone = phonenum
    --                 if self._delegate and self._delegate.isBindingPhone then
    --                     self._delegate:isBindingPhone()    
    --                 end           
    --                 self:runAction(cc.Sequence:create(
    --                     cc.DelayTime:create(1),
    --                     cc.CallFunc:create(function()
    --                         dismissPopupLayer(self)
    --                         end)))
    --             end
    --         end       
    --     end)

end
--获取随机码    
function PhoneBindingLayer:getrand()
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
return PhoneBindingLayer