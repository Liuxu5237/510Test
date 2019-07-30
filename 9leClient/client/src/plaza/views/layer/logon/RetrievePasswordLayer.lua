--注册界面

local RetrievePasswordLayer = class("RetrievePasswordLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")
local WebFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.WebFrame")

require("base.src.app.models.bit")
require("base.src.app.models.AppDF")
require("base.src.app.Toolkits.TimerProxy") --added ycc

local ServiceLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.other.ServiceLayer")

function RetrievePasswordLayer:ctor(delegate)

    self._delegate = delegate

    self._countDown = 120

    --节点事件
    ExternalFun.registerNodeEvent(self)

    local csbNode = ExternalFun.loadCSB("Logon/RetrievePassword/RetrievePasswordLayer.csb"):addTo(self)
    self._content = csbNode:getChildByName("content")

--    local logo  = self._content:getChildByName("sp_logo")
--    logo:setVisible(not yl.APPSTORE_VERSION)
    
    --返回
    local btnBack = self._content:getChildByName("btn_back")
    btnBack:addClickEventListener(function()
        --播放音效
        ExternalFun.playClickEffect()
        dismissPopupLayer(self)
    end)

    --验证码按钮
    self.btnCode = self._content:getChildByName("btn_code")
    self.btnCode:addClickEventListener(function()
            ExternalFun.playClickEffect()
            self:RequestValidationCode()
        end)
    local txt_downcount = self.btnCode:getChildByName("txt_countdown")
    txt_downcount:setString("获取验证码")
    txt_downcount:setVisible(true)

    --确定按钮
    local btnComfir = self._content:getChildByName("btn_comfir")
    btnComfir:addClickEventListener(function()
        ExternalFun.playClickEffect()
        self:ModifyPasswordRequest()
        end)

    --输入框
    self._editPhoneNumber = self:onCreateEditBox(self._content:getChildByName("sp_input_phonenum_bg"), "请输入手机号", false,true, 11)
    self._editCode = self:onCreateEditBox(self._content:getChildByName("sp_input_code_bg"), "请输入验证码", false,true, 6)
    self._editNewPass = self:onCreateEditBox(self._content:getChildByName("sp_input_newpass_bg"), "大于8位且为数字和字母组合", true,false, 32)
    self._editComfirPass = self:onCreateEditBox(self._content:getChildByName("sp_input_comfir_bg"), "请再次输入新密码", true,false, 32)
end
function RetrievePasswordLayer:onCreateEditBox(spEditBg, strholder, isPassword, isNumeric, maxLength)
    
    local inputMode = isNumeric and cc.EDITBOX_INPUT_MODE_NUMERIC or cc.EDITBOX_INPUT_MODE_SINGLELINE

    local sizeBg = spEditBg:getContentSize()
    local editBox = ccui.EditBox:create(cc.size(sizeBg.width - 150, sizeBg.height - 16), "")
        :move(sizeBg.width / 2 + 70, sizeBg.height / 2)
        :setFontSize(28)
        --:setFontColor(cc.BLACK)
        :setFontName("fonts/round_body.ttf")
        :setPlaceholderFontSize(20)
        :setPlaceHolder(strholder)
        :setMaxLength(maxLength)
        :setInputMode(inputMode)
        :addTo(spEditBg)
    --密码框
    if isPassword then
        editBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    end
    return editBox
end
--请求验证码
function RetrievePasswordLayer:RequestValidationCode()

   
    local _mobilePhoneNum = self._editPhoneNumber:getText()
    if _mobilePhoneNum == "" then
        showToast(nil, "请输入手机号", 1)
        return
    elseif string.len(_mobilePhoneNum) ~= 11 then
        showToast(nil, "请输入正确的手机号", 1)
        return
    end

     --倒计时未结束不能再次请求
    if self._countDown ~= 120 then
        return
    end
    
    self.btnCode:setEnabled(false)
    local txt_downcount = self.btnCode:getChildByName("txt_countdown")
    txt_downcount:setString(tostring(self._countDown).."s")
    txt_downcount:setVisible(true)
    
    self.entryId = cc.Director:getInstance():getScheduler():scheduleScriptFunc( function( dt )
                    if not appdf.isObject(self) then
                        return
                    end
                    if self._countDown <= 0 then
                        self._countDown = 120
                        cc.Director:getInstance():getScheduler():unscheduleScriptEntry( self.entryId )
                        self.btnCode:setEnabled(true)
                        --txt_downcount:setVisible(false)
                        txt_downcount:setString("获取验证码")
                        return
                    end
                    
                    self._countDown = self._countDown - 1
                    txt_downcount:setString(tostring(self._countDown).."s")
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
                --txt_downcount:setVisible(false)
                txt_downcount:setString("获取验证码")
                self._countDown = 120
                
            end
        end

    end)

    local action = {}
    action["A"] = "reset"
    action["mob"]  = _mobilePhoneNum        
    local pargams = {1,3,action}   

    local action2 = cjson.encode(pargams)       
    webFrame:wsSendString(action2) 

end
function RetrievePasswordLayer:getrand()
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

function RetrievePasswordLayer:ModifyPasswordRequest()

    local _mobilePhoneNum = string.lower(self._editPhoneNumber:getText())
    local _editcode = self._editCode:getText()
    local _password = self._editNewPass:getText()
    local _newpassword = self._editComfirPass:getText()
    if _mobilePhoneNum == "" then
        showToast(nil, "请输入手机号", 1)
        return
    elseif string.len(_mobilePhoneNum) ~= 11  then
        showToast(nil,"手机号格式错误",1)
        return
    elseif string.len(_editcode) ~= 6 then
        showToast(nil,"请输入6位数验证码",1)
        return
    elseif string.len(_password) < 8 or string.len(_password) > 32 then
        showToast(nil,"请输入8到32位密码",1)
        return
    elseif _password ~= _newpassword then
        showToast(nil,"两次输入的密码不一样",1)
        return
    end
    --[[WS/PasswordRetrieval.aspx?Mobile,TimeStamp,Code,Sign,password]]

    local webFrame = WebFrame:create(self, function(result, message2)
        --[1,103,{"mcode":"515538","mob":"18559102779","A":"repass","szPassWord":"12345678a","code":1}], 	

        local action2 = cjson.encode(message2)
        local message = cjson.decode(message2)
        if type(message) ~= "table" then
            return
        end

        if message[1] == 1 and message[2] == 103 then
            if message[3]["code"] == 1 then
                showToast(nil, "修改密码成功", 3)
                --账号重置
                self._delegate._logonLayer._editAccount:setText(_mobilePhoneNum)
                --密码框重置
                local password = GlobalUserItem.PasswordEncryption(_password)                    
                self._delegate._logonLayer._editPassword:setText(password)
                self:runAction(cc.Sequence:create(
                    cc.DelayTime:create(2),
                    cc.CallFunc:create(function()
                        dismissPopupLayer(self)
                        end)))
            else
                showToast(nil, "修改密码失败", 3)
                
            end
        end 

    end)

    local action = {}
    action["A"] = "repass"
    action["mob"] = _mobilePhoneNum
    action["szPassWord"] = GlobalUserItem.PasswordEncryption(_password)
    action["mcode"]  = _editcode        
    local pargams = {1,3,action}   

    local action2 = cjson.encode(pargams)       
    webFrame:wsSendString(action2) 
end

function RetrievePasswordLayer:onShow()
    
    local px, py = self._content:getPosition()

    self._content:setPosition(px, py + appdf.HEIGHT / 2)

    --动画跳入
    self._content:runAction(cc.EaseBackOut:create(cc.MoveTo:create(0.4, cc.p(px, py))))
end

function RetrievePasswordLayer:onExit()
    print("离开")
    self:stopAllActions()
    if self.entryId ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.entryId)
    end
end
return RetrievePasswordLayer