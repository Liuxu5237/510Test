--注册界面

local RegisterLayer = class("RegisterLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")
require("base.src.app.models.bit")
require("base.src.app.models.AppDF")
require("base.src.app.Toolkits.TimerProxy") --added ycc
local WebFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.WebFrame")
local GameServerItem   = appdf.req(appdf.CLIENT_SRC.."plaza.models.GameServerItem")

local ServiceLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.other.ServiceLayer")

function RegisterLayer:ctor(delegate)
    print("txt_downcount")
    self._delegate = delegate

    --节点事件
    ExternalFun.registerNodeEvent(self)

    local csbNode = ExternalFun.loadCSB("Logon/RegisterLayer.csb"):addTo(self)
    self._content = csbNode:getChildByName("content")

--    local logo  = self._content:getChildByName("Image_Lgoin")
--    logo:setVisible(not yl.APPSTORE_VERSION)

    --返回
    local btnBack = self._content:getChildByName("btn_back")
    btnBack:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()

        --通知关闭
        if self._delegate and self._delegate.onRegisterLayerClose then
            self._delegate:onRegisterLayerClose()
        end      

        dismissPopupLayer(self)
    end)

    --验证码
    local btnVerification  = self._content:getChildByName("Btn_Verification")
    local txt_downcount = btnVerification:getChildByName("Tex_VerifMiss");
    btnVerification:addClickEventListener(function()
    
     
        ExternalFun.playClickEffect()

        local szAccount = self._editAccount:getText()
	    if szAccount == "" then
		    showToast(nil, "请输入手机号", 1)
            return
        elseif string.len(szAccount) ~= 11 then
            showToast(nil, "请输入正确的手机号", 1)
            return
        end
        


      --改变状态
      self._content:getChildByName("Btn_Verification"):setEnabled(false)
      self._content:getChildByName("Btn_Verification"):getChildByName("Tex_VerifMiss"):setVisible(true)
      self._UpMissTimer = 119       --默认2分钟




      self._player_update = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()

      local btnVerification  = self._content:getChildByName("Btn_Verification")
     -- btnVerification:setEnabled(false)
        
        if self._UpMissTimer<=0 then
            --btnVerification:getChildByName("Tex_VerifMiss"):setVisible(false)
            btnVerification:getChildByName("Tex_VerifMiss"):setString("获取验证码")
            btnVerification:setEnabled(true)
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._player_update)
            self._player_update = nil 
            self._UpMissTimer = 120 
        else
            local curMiss = ""..self._UpMissTimer.."s"
            btnVerification:getChildByName("Tex_VerifMiss"):setString(curMiss)
            self._UpMissTimer = self._UpMissTimer - 1 
    end

    end, 1, false)
    print("txt_downcount")
    txt_downcount:setVisible(true)
    txt_downcount:setString("获取验证码")
    local action = {}
    action["mob"] = szAccount
    action["A"] = "rcode"
    local pargams = {1,3,action}
   
    local action2 = cjson.encode(pargams)

    local this = self
    self._webFrame = WebFrame:create(self, function(result, message2)
        
        local action2 = cjson.encode(message2)
        local message = cjson.decode(message2)
        
        WebFrame:getInstance():close()

        if message[3]["code"] == 0 then
                -- 收到验证码后 
                showToast(self,"发送成功", 3)
        elseif message[3]["code"] == 205 then
            showToast(self,"手机号已存在，请更换手机号注册~",2)
            btnVerification:getChildByName("Tex_VerifMiss"):setVisible(true)
            btnVerification:setEnabled(true)
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._player_update)
            self._player_update = nil
            self._UpMissTimer = 120
        end
           
    end)
    
    self._webFrame:wsSendString(action2) 

    end)

    --输入框
    self._editAccount = self:onCreateEditBox(self._content:getChildByName("sp_edit_account_bg"), false, true, 12,1)
    self._editNickName = self:onCreateEditBox(self._content:getChildByName("sp_edit_Nick_bg"), false, false, 12,5)
    self._editVerification  = self:onCreateEditBox(self._content:getChildByName("sp_edit_nickname_bg"), false, false, 12,2)
    self._editPassword = self:onCreateEditBox(self._content:getChildByName("sp_edit_pwd_bg"), true, false, 20,3)
    self._editSpreader = self:onCreateEditBox(self._content:getChildByName("sp_edit_spreader_bg"), true, false, 20,4)
    
    --同意协议
    self._checkAgreement = self._content:getChildByName("check_agreement")

    --游戏协议
    local btnAgreement = self._content:getChildByName("btn_agreement")
    btnAgreement:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()

        self:onClickAgreement()
    end)

    --注册
    local btnRegister = self._content:getChildByName("btn_register")
    btnRegister:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()

        self:onWebVersionRegister()
    end)


end
function RegisterLayer:onExit()
    print("离开")
    if self._player_update ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._player_update)
    end
end

function RegisterLayer:updates(ft)
   print("erLayer:update");
   local btnVerification  = self._content:getChildByName("Btn_Verification")

    self._content:getChildByName("Tex_VerifMiss"):setVisible(true)
    if self._UpMissTimer<0 then
       -- btnVerification:getChildByName("Tex_VerifMiss"):setVisible(false)
       btnVerification:getChildByName("Tex_VerifMiss"):setString("获取验证码")
        btnVerification:setEnabled(true)
        scheduler:unscheduleScriptEntry(self._player_update)
        self._player_update = nil 
    else
    local curMiss = ""..self._UpMissTimer.."s"
    btnVerification:getChildByName("Tex_VerifMiss"):setString(curMiss)
    self._UpMissTimer = self._UpMissTimer - 1 
    end
   

end
function RegisterLayer:onShow()
    
    local px, py = self._content:getPosition()

    self._content:setPosition(px, py + appdf.HEIGHT / 2)

    --动画跳入
    self._content:runAction(cc.EaseBackOut:create(cc.MoveTo:create(0.4, cc.p(px, py))))
end

--创建输入框
function RegisterLayer:onCreateEditBox(spEditBg, isPassword, isNumeric, maxLength, nSeleIndex)
    print("onCreateEditBox")
    local btnVerification  = self._content:getChildByName("Btn_Verification")
    local txt_downcount = btnVerification:getChildByName("Tex_VerifMiss");
    txt_downcount:setVisible(true)
    txt_downcount:setString("获取验证码")
    local inputMode = isNumeric and cc.EDITBOX_INPUT_MODE_NUMERIC or cc.EDITBOX_INPUT_MODE_SINGLELINE

    local PlaceHolder = "";
    --初始字体
    if nSeleIndex == 1 then
      PlaceHolder = "输入手机号"
    elseif nSeleIndex == 2 then
       PlaceHolder = "请输入验证码"
    elseif nSeleIndex == 3 then
       PlaceHolder = "大于8位且为数字和字母组合"
    elseif nSeleIndex == 4 then
       PlaceHolder = "请重复输入一次密码" 
    elseif nSeleIndex == 5 then
       PlaceHolder = "请输入昵称"
    end

    local sizeBg = spEditBg:getContentSize()
    local editBox = ccui.EditBox:create(cc.size(sizeBg.width - 170, sizeBg.height - 16), "")
		:move(sizeBg.width / 2 + 80, sizeBg.height / 2-2)
        :setFontSize(22)
        :setFontColor(cc.WHITE)
		:setFontName("fonts/round_body.ttf")
		:setMaxLength(maxLength)
        :setInputMode(inputMode)
		:addTo(spEditBg)
        :setPlaceholderFontSize(22)
        :setPlaceHolder(PlaceHolder)

    --密码框
    if isPassword then
        editBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    end

    return editBox
end

--------------------------------------------------------------------------------------------------------------------
-- 事件处理

function RegisterLayer:registerCallBack( result,message2 )
    print("registerCallBack" .. result)
    
    local action2 = cjson.encode(message2)
    local message = cjson.decode(message2)
    --注册
    if message[1] == 1 and message[2] == 101 and message[3]["lErrorCode"] == 206 then
        showToast(self,"手机验证码错误，请您仔细检查哟!",2)
        return
    end
    self._delegate:webLogonCallBack(result,message2)

end

--点击游戏条款
function RegisterLayer:onClickAgreement()

    showPopupLayer(ServiceLayer:create(self), false)
end

--注册
function RegisterLayer:onWebVersionRegister()

    --网站先验证 在走
	-- 判断 非 数字、字母、下划线、中文 的帐号
	local szAccount = self._editAccount:getText()
	local filter = string.find(szAccount, "^[a-zA-Z0-9_\128-\254]+$")
	if szAccount ~= "" and nil == filter then
		showToast(nil, "帐号包含非法字符, 请重试!", 1)
		return
	end

    szAccount = string.gsub(szAccount, " ", "")

    -- _editNickName 变成了验证码
	local szNickName = self._editVerification:getText()
	if szNickName == ""  then
		showToast(nil, "请输入验证码!", 1)
		return
	end


    local szPassword = string.gsub(self._editPassword:getText(), " ", "")

    local szSpreader = string.gsub(self._editSpreader:getText(), " ", "")

    local len =0

     len = ExternalFun.stringLen(szPassword)
	if len < 8 or len > 12 then
		showToast(nil,"密码必须为8~12个字符，请重新输入！",2);
		return
	end	

    if string.find(szPassword, "^[%w]+$") then
        if string.find(szPassword, "^[%a]+$") or string.find(szPassword, "^[%d]+$") then
		    showToast(self, "密码必须为数字字母组合, 请重新输入", 2)
		    return
	    end
    else
        showToast(self, "密码必须为数字字母组合, 请重新输入", 2)
		return
    end

    if szPassword ~= szSpreader then
        showToast(self, "两次输入的密码不一样, 请重新输入", 2)
        return 
    end

    self:onClickRegister()

    -- szNickName = string.gsub(szNickName, " ", "")


    -- local url = yl.HTTP_URL .. "/WS/SMS.ashx"
    -- local infotable = {}
    -- infotable["mobile"] = "" .. szAccount
    -- infotable["randcode"] = "" .. szNickName
    -- infotable["sendtype"] = "" .. "24"
    -- local action = cjson.encode(infotable)
    -- action = appdf.encodeBase64(action)

    -- local prefix = self:getrand()
    -- if prefix == "" then
    --     prefix = "abcde"
    -- end
    -- action = prefix..action
    

    --   --验证验证码
    -- appdf.onHttpJsionTable(url ,"GET", "action=checkyzm".."&data="..action, function(jstable,jsdata)

    --     --对象已经销毁
    --     if not appdf.isObject(self) then
    --         return
    --     end
    --     if type(jstable) == "table" then
    --         local data = jstable["data"]
    --         local msg = jstable["msg"]
    --         --判断发送是否成功
    --         if type(msg) == "string" and "" ~= data then
    --             if msg ~= "success" then
    --                 -- 收到验证码后 
    --                 showToast(self, data, 3)
    --             else
    --             --走服务器
    --                 self:onClickRegister()
    --             end

    --         end
    --     end
    -- end)





--	local szPassword = string.gsub(self._editPassword:getText(), " ", "")

--	local szSpreader = string.gsub(self._editSpreader:getText(), " ", "")

--    local len = ExternalFun.stringLen(szAccount)
--	if len < 6 or len > 31 then
--		showToast(nil, "游戏帐号必须为6~31个字符，请重新输入！", 2);
--		return
--	end

--    len = ExternalFun.stringLen(szNickName)
--	if len < 6 or len > 31 then
--		showToast(nil, "游戏昵称必须为6~31个字符，请重新输入！", 2);
--		return
--	end

--	--判断emoji
--    if ExternalFun.isContainEmoji(szAccount) then
--        showToast(nil, "帐号包含非法字符,请重试", 2)
--        return
--    end

--    if ExternalFun.isContainEmoji(szNickName) then
--        showToast(nil, "昵称包含非法字符,请重试", 2)
--        return
--    end

--	--判断是否有非法字符
--	if true == ExternalFun.isContainBadWords(szAccount) then
--		showToast(nil, "帐号中包含敏感字符,不能注册", 2)
--		return
--	end

--	if true == ExternalFun.isContainBadWords(szNickName) then
--		showToast(nil, "昵称中包含敏感字符,不能注册", 2)
--		return
--	end

--	len = ExternalFun.stringLen(szPassword)
--	if len < 6 or len > 12 then
--		showToast(nil,"密码必须为6~12个字符，请重新输入！",2);
--		return
--	end	

--    if string.find(szPassword, "^[%w]+$") then
--        if string.find(szPassword, "^[%a]+$") or string.find(szPassword, "^[%d]+$") then
--		    showToast(self, "密码必须为数字字母组合, 请重新输入", 2)
--		    return
--	    end
--    else
--        showToast(self, "密码必须为数字字母组合, 请重新输入", 2)
--		return
--    end

--	-- 与帐号不同
--	if string.lower(szPassword) == string.lower(szAccount) then
--		showToast(nil,"密码不能与帐号相同，请重新输入！",2);
--		return
--	end

--    if self._checkAgreement:isSelected() == false then
--		showToast(nil,"请先阅读并同意《游戏中心服务条款》！",2);
--		return
--	end

--    if self._delegate and self._delegate.onRegisterAccount then
--	    self._delegate:onRegisterAccount(szAccount, szNickName, szPassword, szSpreader)
--    end
end



--注册
function RegisterLayer:onClickRegister()

    --网站先验证 在走
	-- 判断 非 数字、字母、下划线、中文 的帐号
	local szAccount = self._editAccount:getText()
	local filter = string.find(szAccount, "^[a-zA-Z0-9_\128-\254]+$")
	if szAccount ~= "" and nil == filter then
		showToast(nil, "帐号包含非法字符, 请重试!", 1)
		return
	end

    szAccount = string.gsub(szAccount, " ", "")

   
	local szNickName = self._editNickName:getText()
	if szNickName == ""  then
		showToast(nil, "请输入昵称!", 1)
		return
	end


    --  昵称判断
    local szVerification = string.gsub(self._editNickName:getText(), " ", "")


    local VerLen =0

    VerLen = ExternalFun.stringLen(szVerification)

     if VerLen < 6 or VerLen > 12 then
		showToast(nil,"昵称必须大于6个或者小于12个字符",2);
		return
	end	



    local szPassword = string.gsub(self._editPassword:getText(), " ", "")

    local szSpreader = string.gsub(self._editSpreader:getText(), " ", "")

    local len =0

     len = ExternalFun.stringLen(szPassword)
	if len < 8 or len > 12 then
		showToast(nil,"密码必须为8~12个字符，请重新输入！",2);
		return
	end	

    if string.find(szPassword, "^[%w]+$") then
        if string.find(szPassword, "^[%a]+$") or string.find(szPassword, "^[%d]+$") then
		    showToast(self, "密码必须为数字字母组合, 请重新输入", 2)
		    return
	    end
    else
        showToast(self, "密码必须为数字字母组合, 请重新输入", 2)
		return
    end

    if szPassword ~= szSpreader then
        showToast(self, "两次输入的密码不一样, 请重新输入", 2)
        return 
    end

    szNickName = string.gsub(szNickName, " ", "")

    if self._delegate and self._delegate.onRegisterAccount then
	    self._delegate:onRegisterAccount(szAccount, self._editNickName:getText(), szPassword, szSpreader,self._editVerification:getText())
    end
end
--获取随机码    
function RegisterLayer:getrand()
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

--------------------------------------------------------------------------------------------------------------------
-- ServiceLayer 回调

--同意条款
function RegisterLayer:onConfirmAgreement()

    self._checkAgreement:setSelected(true)
end

return RegisterLayer