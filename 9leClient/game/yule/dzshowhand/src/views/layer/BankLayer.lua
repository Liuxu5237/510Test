
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

local BankLayer=class("BankLayer",cc.Layer)

function BankLayer:ctor(parentNode)

	self._parentNode=parentNode

	self.csbNode=ExternalFun.loadCSB("bank/BankLayer.csb",self)
	
	appdf.getNodeByName(self.csbNode,"Button_1"):addClickEventListener(
        function()
                self._parentNode._bankLayer = nil
                ExternalFun.playCloseButtonClickEffect()
                self:hide()
        end) 
    --注册触摸事件
    ExternalFun.registerTouchEvent(self, true)
    self.m_spBg=self.csbNode:getChildByName("bg")
	self.withdrawBtn=appdf.getNodeByName(self.csbNode,"Button_2")
	self.bg=appdf.getNodeByName(self.csbNode,"bg")
    self.withdrawBtn:addClickEventListener(function()
         ExternalFun.playCommonButtonClickEffect()
         self:onTakeScore() 
        end)

	self.curCoinLabel=appdf.getNodeByName(self.csbNode,"txt_gold")
    self.curCoinLabel:setString(string.format("%d",GlobalUserItem.lUserScore))
    		
    self.insureLabel=appdf.getNodeByName(self.csbNode,"txt_bank_balabce")
    self.insureLabel:setString(string.format("%d",GlobalUserItem.lUserInsure))

	local editHanlder = function(event,editbox)
		self:onEditEvent(event,editbox)
	end

    local edit_goldNumBg = self.bg:getChildByName("sprite_gold_num")
    edit_goldNumBg:setVisible(false)
	--金额输入
	self.edit_Score = ccui.EditBox:create(cc.size(600,75), ccui.Scale9Sprite:create("bank/Ysz_Bank_srk.png"))
		:move(edit_goldNumBg:getPosition())--450,360
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(30)
		:setPlaceholderFontSize(30)
		:setMaxLength(13)
		:setFontColor(cc.c4b(217,217,207,255))
		:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
		:setPlaceHolder("输入取款金额")
		:addTo(self.bg)
	self.edit_Score:registerScriptEditBoxHandler(editHanlder)

    local edit_passwordBg = self.bg:getChildByName("sprite_password") 
    edit_passwordBg:setVisible(false)
	--密码输入	
	self.edit_Password = ccui.EditBox:create(cc.size(600,75), ccui.Scale9Sprite:create("bank/Ysz_Bank_srk.png"))
		:move(edit_passwordBg:getPosition())
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(30)
		:setPlaceholderFontSize(30)
		:setMaxLength(32)
		:setFontColor(cc.c4b(195,199,239,255))
		:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:setPlaceHolder("输入取款密码")
		:addTo(self.bg)

    self.slider_goldNum = self.bg:getChildByName("slider")
    self.slider_goldNum:setPercent(0)
    self.slider_goldNum:addEventListener(function (ref,type)
          if type == 0 then  --changed
              local percent = ref:getPercent()
              local num = math.floor(percent/100*GlobalUserItem.lUserInsure)
              self.m_txt_slider:setString("%"..percent)
              self.edit_Score:setText(""..num)
          end
     end)
     self.m_txt_slider =self.bg:getChildByName("txt_slider_percent")
     self.m_txt_slider:setString("%"..0)

    self._parentNode:sendRequestBankInfo()
    self:show()
end

--输入框监听
function BankLayer:onEditEvent(event,editbox)
     if event == "changed" then  
        local src = editbox:getText()
        local num = tonumber(src)
        if num ==nil then
           return
        end
        local  percent = num/GlobalUserItem.lUserInsure*100
        if self.slider_goldNum ~= nil then 
           self.slider_goldNum:setPercent(percent)
           self.m_txt_slider :setString("%"..percent)
        end
     end
end


--取款
function BankLayer:onTakeScore()

    --参数判断
    local szScore = string.gsub(self.edit_Score:getText(),"([^0-9])","")
    local szPass = self.edit_Password:getText()

    if #szScore < 1 then 
        showToast(self,"请输入操作金额！",2)
        return
    end

    local lOperateScore = tonumber(szScore)
    if lOperateScore<1 then
        showToast(self,"请输入正确金额！",2)
        return
    end

    if lOperateScore > GlobalUserItem.lUserInsure then
        showToast(self,"您银行游戏币的数目余额不足,请重新输入游戏币数量！",2)
        return
    end

    if #szPass < 1 then 
        showToast(self,"请输入银行密码！",2)
        return
    end
    if #szPass <6 then
        showToast(self,"密码必须大于6个字符，请重新输入！",2)
        return
    end

    self._parentNode:sendTakeScore(szScore,szPass)
end

--刷新银行游戏币
function BankLayer:refreshBankScore( )
    --携带游戏币
    local str = ""..GlobalUserItem.lUserScore
    if string.len(str) > 19 then
        str = string.sub(str, 1, 19)
    end
    self.curCoinLabel:setString(str)

    --银行存款
    str = GlobalUserItem.lUserInsure..""
    if string.len(str) > 19 then
        str = string.sub(str, 1, 19)
    end
    self.insureLabel:setString(str)

    self.edit_Score:setText("")
    self.edit_Password:setText("")
end
------

--银行操作成功
function BankLayer:onBankSuccess( )
    local bank_success = self._parentNode.bank_success
    if nil == bank_success then
        return
    end

    self:refreshBankScore()

    showToast(self, bank_success.szDescribrString, 2)
end

--银行操作失败
function BankLayer:onBankFailure( )
    local bank_fail = self._parentNode.bank_fail
    if nil == bank_fail then
        return
    end

    showToast(self, bank_fail.szDescribeString, 2)
end

--银行资料
function BankLayer:onGetBankInfo(bankinfo)
    bankinfo.wRevenueTake = bankinfo.wRevenueTake or 10
    local str = "温馨提示:取款将扣除" .. bankinfo.wRevenueTake .. "‰的手续费"
    if self.m_textTips==nil or tolua.isnull(self.m_textTips) then
    	self.m_textTips=ccui.Text:create(str,"fonts/round_body.ttf",26)
    					:addTo(self.bg)
    					:setPosition(cc.p(545,85))
                        :setTextColor(cc.c4b(226,92,33,255))
    else
    	self.m_textTips:setString(str)
    end
end
function BankLayer:show()

    local fadeIn = cc.FadeIn:create(0.07)
    local bigger = cc.ScaleTo:create(0.07, 1.1)
    local spawn = cc.Spawn:create(fadeIn, bigger)
    local reNormal = cc.ScaleTo:create(0.21, 1.0)
    local action = cc.Sequence:create(spawn, reNormal)
    self:runAction(action)


end 
function BankLayer:hide()

    local spawnTime = 0.1
    local moveUp = cc.MoveBy:create(spawnTime, cc.p(0, 20))
    local fadeOut = cc.FadeOut:create(spawnTime)
    local smaller = cc.ScaleTo:create(spawnTime, 0.8)
    local spawn = cc.Spawn:create(moveUp, fadeOut, smaller)
    
    local action = cc.Sequence:create(spawn, callFun,cc.RemoveSelf:create())
    self:runAction(action)

end
--触摸回调
function BankLayer:onTouchBegan(touch, event)
    return self:isVisible()
end

function BankLayer:onTouchEnded(touch, event)
    local pos = touch:getLocation() 
    local m_spBg = self.m_spBg
    pos = m_spBg:convertToNodeSpace(pos)
    local rec = cc.rect(0, 0, m_spBg:getContentSize().width, m_spBg:getContentSize().height)
    if false == cc.rectContainsPoint(rec, pos) then
        self:hide()
    end
end
return BankLayer