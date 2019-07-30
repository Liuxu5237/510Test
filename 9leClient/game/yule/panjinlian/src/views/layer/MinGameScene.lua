--local system = import(".system")

local MinGameScene = class("MinGameScene",function(scene)
	local MinGameScene =  display.newLayer()
return MinGameScene
end)
local ExternalFun =  appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

function MinGameScene:ctor(scene)
	--注册node事件
	ExternalFun.registerNodeEvent(self)

	self._scene = scene
	self:initdata()
	self:initUi()
end

function MinGameScene:initdata()
	--需要加载的界面
	self.RESOURCE_FILENAME = "MinGameScene.csb"
	--------
	self.soltWin = nil ;
	self.Card_Tag = -1 ;
	self.Card_index = 0 ;

	--text_Win
	self.Win_sp = nil 
	self.Lose_sp = nil 
	self.Current_Win = nil 
	self.Bet_win = nil
	self.Result_win = nil 
	--变量
	self.win = 0 
	self.Suit = nil
	self.isMag = false


	-- button
	self.But_Heit = nil
	self.But_Meih = nil
	self.But_Hongt = nil
	self.But_Fangk = nil
	self.But_Black = nil
	self.But_Red = nil
	--val
	--table
	-- local TYPE_Red = 0x01		--红色牌面
	-- local TYPE_Black = 0x02		--黑色牌面

	-- local TYPE_Fangk = 0x10		--方块牌面
	-- local TYPE_Meih	= 0x20		--梅花牌面	
	-- local TYPE_Hongt = 0x30		--红桃牌面
	-- local TYPE_Heit = 0x40		--黑桃牌面

	self.msgCar = {6,4,5,3,2,1}
	self.CardVals = {"ht_","mh_","hon_","fk_"}	
	self.CardVals_1 = {"mh_","hon_","fk_"}	
	self.CardVals_2 = {"ht_","hon_","fk_"}				
	self.CardVals_3 = {"ht_","mh_","fk_"}				
	self.CardVals_4 = {"ht_","mh_","hon_"}		
end

function MinGameScene:initUi(  )
	self.Card_index = 0
	--require("app.views.system"):SetVisible(self.self,false)
	--require("app.views.system"):setBtnVisible(self.self,false)

	-- local sprite_Card = cc.Sprite:create("MinGame/Card/back.png")
	-- 	sprite_Card:setPosition(640,300)
	-- 	sprite_Card:setScale(2.5)
	-- 	self.self._csbNode:addChild(sprite_Card)

	self.csbNode = cc.CSLoader:createNode(self.RESOURCE_FILENAME)
	:addTo(self, 1)
	self._csbNode = self.csbNode:getChildByName("Panel_1")
	print("self.soltWin::"..self.soltWin)

	self.But_Heit =self._csbNode:getChildByName("btn_Hei")
	self.But_Meih =self._csbNode:getChildByName("btn_Mei")
	self.But_Hongt = self._csbNode:getChildByName("btn_Hong")
	self.But_Fangk = self._csbNode:getChildByName("btn_Fang")

	self.But_Black = self._csbNode:getChildByName("btn_Black")
	self.But_Red = self._csbNode:getChildByName("btn_Red")

	self.But_Colloct =  self._csbNode:getChildByName("Current_Win")


	--self.Current_Win  = self._csbNode:getChildByName("Current_Win")
	self.Bet_win = self._csbNode:getChildByName("text_Bet")
	self.Result_win = self._csbNode:getChildByName("text_Result")
	self.Result_win:setLocalZOrder(999)
	self.Bet_win:setLocalZOrder(999)
	--self.Current_Win:setString(nil)
	self.Bet_win:setString(self.soltWin):setVisible(true)
	self.Result_win:setString(0):setVisible(true)


	self.Win_sp = cc.Sprite:create("MinGame/WIN.png")  --self.Lose_sp
	self.Win_sp:setPosition(640,310):setAnchorPoint(0.5,0.5)
	self.Win_sp:setVisible(false)
	self._csbNode:addChild(self.Win_sp,999)
	self.Lose_sp = cc.Sprite:create("MinGame/LOSE.png")  --self.Lose_sp
	self.Lose_sp:setPosition(640,310):setAnchorPoint(0.5,0.5)
	self.Lose_sp:setVisible(false)
	self._csbNode:addChild(self.Lose_sp,999)

	self.But_Heit:addTouchEventListener(handler(self,self.footBtnClick))
	self.But_Meih:addTouchEventListener(handler(self,self.footBtnClick))
	self.But_Hongt:addTouchEventListener(handler(self,self.footBtnClick))
	self.But_Fangk:addTouchEventListener(handler(self,self.footBtnClick))

	self.But_Black:addTouchEventListener(handler(self,self.footBtnClick))
	self.But_Red:addTouchEventListener(handler(self,self.footBtnClick))
	
	self.But_Colloct:addTouchEventListener(handler(self,self.footBtnClick))
end
		

function MinGameScene:footBtnClick(sender, eventType)
	self.Card_Tag =-1
	if eventType == ccui.TouchEventType.ended then 
		AudioEngine.playEffect("AudioClip/btn_Other.mp3");	
		if sender:getName() == "btn_Hei" then
			print("But_Heit点击") 
			self.Card_Tag = 1

		elseif sender:getName() == "btn_Mei" then
		 	print("But_Meih点击")
		 	self.Card_Tag = 2

		elseif sender:getName() == "btn_Hong" then
		 	print("But_Hongt点击")
		 	self.Card_Tag = 3

		elseif sender:getName() == "btn_Fang" then
			print("But_Fangk点击")
			self.Card_Tag = 4

		elseif sender:getName() == "btn_Black" then
			print("But_Black点击")
			self.Card_Tag = 5

		elseif sender:getName() == "btn_Red" then
			print("but_Red点击按钮")
			self.Card_Tag = 6

		elseif sender:getName() == "Current_Win" then
			print("Button_Colloct点击按钮")
			print("结束小游戏")
			self._scene:NewManny()
			local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
													--cc.Director:getInstance():popScene()
													self:setVisible(false)
    												self:removeAllChildren()
    												self:removeFromParent()
													end),
													nil)
			self:runAction(seq)
		end
		if self.Card_Tag < 7 and  self.Card_Tag > 0 and self.Card_index < 6 then
			print("给服务器传送数据；；；；；稍等..."..self.Card_Tag)
			self.Card_index = self.Card_index + 1
			print("self.msgCar[self.Card_Tag]...."..self.msgCar[self.Card_Tag])
			self._scene._scene:guessCard(self.msgCar[self.Card_Tag])
		end
		self:setBtn(false)
	end
end

function MinGameScene:setBtn(enble)
	self.But_Heit:setEnabled(enble):setBright(enble)
	self.But_Meih:setEnabled(enble):setBright(enble)
	self.But_Hongt:setEnabled(enble):setBright(enble)
	self.But_Fangk:setEnabled(enble):setBright(enble)
	self.But_Black:setEnabled(enble):setBright(enble)
	self.But_Red:setEnabled(enble):setBright(enble)
	self.But_Colloct:setEnabled(enble):setBright(enble)
end 

function MinGameScene:ShowPoker()
	if self.isMag then
		self.Suit = nil
		print("Win:::赢了多少..."..self.win)
		print("第几次..."..self.Card_index)
		local CardVal = math.random(1,13)
		local CardValCm = math.random(1,2)
		local CardValF = math.random(1,3)
		print("CardVal..."..CardVal)
		print("CardValCm..."..CardValCm)
		print("CardValF..."..CardValF)
		if self.win > 0 then
			if self.Card_Tag >=1 and self.Card_Tag <= 4 then
				self.Suit = self.CardVals[self.Card_Tag]..CardVal
			elseif self.Card_Tag >=5 and self.Card_Tag <= 6 then 
				if self.Card_Tag == 5 then
				self.Suit = self.CardVals[CardValCm]..CardVal	
				elseif self.Card_Tag == 6 then
				self.Suit = self.CardVals[CardValCm + 2]..CardVal
				end
			end
		elseif  self.win == 0  then
			if self.Card_Tag == 1 then
				self.Suit = self.CardVals_1[CardValF]..CardVal
			elseif self.Card_Tag == 2 then
				self.Suit = self.CardVals_2[CardValF]..CardVal
			elseif self.Card_Tag == 3 then
				self.Suit = self.CardVals_3[CardValF]..CardVal
			elseif self.Card_Tag == 4 then
				self.Suit = self.CardVals_4[CardValF]..CardVal	
			elseif self.Card_Tag == 5 then
				self.Suit = self.CardVals[CardValCm + 2]..CardVal	
			elseif self.Card_Tag == 6 then
				self.Suit = self.CardVals[CardValCm]..CardVal
			end
		end
		print("self.Suit...牌型和花色:::::::::::...."..self.Suit)
		local sprite_Card = cc.Sprite:create("MinGame/Card/"..self.Suit..".png")
		sprite_Card:setPosition(670,321)
		sprite_Card:setScaleX(1.66)
		sprite_Card:setScaleY(1.44)
		self._csbNode:addChild(sprite_Card)
		local movUp = cc.DelayTime:create(2)
		if self.win > 0  and self.Card_index < 5 then
			self.Result_win:setString(self.win)
			local mov = cc.Spawn:create(cc.DelayTime:create(0.5),cc.MoveTo:create(0.5, cc.p((460 + (self.Card_index -1)* 122) ,570)),cc.ScaleTo:create(0.5,0.6))
			local seq = cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function() self.Win_sp:setVisible(true) end),movUp,cc.CallFunc:create(function() self.Win_sp:setVisible(false) end),mov,cc.CallFunc:create(function() 
														--self.Win_sp:setVisible(false)
														self.Bet_win:setString(self.win)
														self:setBtn(true)
														end),
														nil)
			sprite_Card:runAction(seq)
		else
			
			self._scene:NewManny()
			self.Result_win:setString(self.win)
			local seq = cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function() self.Lose_sp:setVisible(true) end),movUp,cc.CallFunc:create(function()
				self.Lose_sp:setVisible(false)
				self.Bet_win:setString(self.win)
			end),cc.DelayTime:create(1),cc.CallFunc:create(function()
				--cc.Director:getInstance():popScene()
				self:setVisible(false)
    			self:removeAllChildren()
    			self:removeFromParent()
			end),nil)
			self:runAction(seq)
		end
	end
end

function MinGameScene:StartRoll(win)
	print("sssssssssss.."..win)
	self.win = win
	self.isMag = true
	self:ShowPoker()
end

return MinGameScene