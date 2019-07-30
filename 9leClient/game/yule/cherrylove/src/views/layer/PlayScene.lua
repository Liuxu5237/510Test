--local system = import(".system")

local PlayScene = class("PlayScene",function(scene)
	local PlayScene =  display.newLayer()
return PlayScene
end)
local ExternalFun =  appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

function PlayScene:ctor(scene)
	--注册node事件
	ExternalFun.registerNodeEvent(self)

	self._scene = scene
	self:initdata()
	self:initUi()
end



local spaceX = 80  --间隔
local bRED = false
local bBLACK = false

function PlayScene:initdata()
	--需要加载的界面
	self.RESOURCE_FILENAME = "GameScene.csb"
	--按钮定义 
	self.btn_collect=nil
	self.sp_1=nil
	self.text_bank=nil
	self.text_double=nil 
	--变量
	self.bank=5.00  
	self.posX = 500 
	self.nleftTime = 0
end

function PlayScene:initUi()
	self.nleftTime = 0
	self.posX = 500 
	math.randomseed(os.time())
	--获取按钮 	
	--require("app.views.system"):setBtnVisible(PlayScene._self,false);

	local function onNodeEvent(event)
		if event == "exit" then
			self:onExit()
		end
	end
	self:registerScriptHandler(onNodeEvent)

	self._csbNode = cc.CSLoader:createNode(self.RESOURCE_FILENAME)
			:addTo(self, 1)

	local function btnClick(sender, eventType) 
		if eventType == ccui.TouchEventType.began then 
			print("点击了"..sender:getName())
			AudioEngine.playEffect("mp3/ButtonInfo.mp3")
			if sender:getName() == "btn_black" then
				bBLACK = true
				self:setBtn(false)
				self:startGameByNet() 
			elseif sender:getName() == "btn_red" then		
				bRED = true
				self:setBtn(false)
				self:startGameByNet()
			elseif sender:getName() == "btn_collect" then
				self:setBtn(false)
				self:ExitPlayGame()
			end 
		end
	end
	self.btn_collect=self._csbNode:getChildByName("btn_collect") 
	self.btn_collect:addTouchEventListener(btnClick)
	self.btn_black=self._csbNode:getChildByName("btn_black") 
	self.btn_black:addTouchEventListener(btnClick)
	self.btn_red=self._csbNode:getChildByName("btn_red") 
	self.btn_red:addTouchEventListener(btnClick)
	self.sp_1=self._csbNode:getChildByName("sp_1") 
 
	self.text_bank=self._csbNode:getChildByName("text_bank") 
	self.text_double=self._csbNode:getChildByName("text_double")  
	
	self.text_bank:setString(self.bank)
	self.text_double:setString("0") 
	--主窗口调用
	--self:initText()
	
	AudioEngine.playMusic("mp3/Gamble.mp3", true)
end



function PlayScene:initText()
	 
	self.text_bank:setString(self.bank)
	self.text_double:setString(self.bank*2) 
end

function PlayScene:setBank(_bank)
	self.bank=_bank
	--self:initText()
	self.text_bank:setString(self.bank)
	print("设置#################"..self.bank)
end

--随机一涨牌
local function randCard()
	local num = 2--math.random(1,4)
	local str_path =""
	if(num == 1) then  
		str_path = str_path.."fk"
	elseif(num == 2) then  
		str_path = str_path.."ht"
	elseif(num == 3) then  
		str_path = str_path.."hon"
	elseif(num == 4) then  
		str_path = str_path.."mh"
	end
	local num2 = math.random(1,13)
	return num,cc.Sprite:create("poker/"..str_path.."_"..num2..".png")
end
function PlayScene:callback111()
	--赢了后调用 
	if self.nleftTime > 0 and self.nleftTime < 5 then 
		self:setBtn(true) 
	else
		local dt =cc.DelayTime:create(2)--等待 
		local seq =cc.Sequence:create(dt,cc.CallFunc:create(function()
			self:ExitPlayGame() 
		end),nil)
		self:runAction(seq)	
	 end 

end 
--16进制数据获取个位和十位
function PlayScene:getCardVal(n0x_val)
	local str16 =string.format("%x",n0x_val)
	local cardType = string.sub(str16,1,1) --十位
	local cardNum  =tonumber( "0x"..string.sub(str16,2))   --个位
	return cardType,cardNum
end

function PlayScene:startGame(win)
	local nCardBlack = {2,4}
	local nCardRed 	 = {1,3}
	local nCardRand = math.random(1,2);
	local nCardType = math.random(1,13);
	local nCardNum = 0
	self.nleftTime = self.nleftTime + 1
	--判断是否赢了   --红色--黑色 
	print("赢了没" .. win)
	if(win > 0)  then
		if bBLACK then  -- 猜黑色赢了 客户端给出一张黑色的牌
			nCardNum = nCardBlack[nCardRand] * 16 + nCardType
		else -- 猜红色赢了 客户端给出一张红色的牌
			nCardNum = nCardRed[nCardRand] * 16 + nCardType
		end

		--显示牌 
		local sp_card=self:initCard(nCardNum)
		sp_card:setScale(0.95,0.95)
		sp_card:setPosition(self.sp_1:getPosition())
		self:addChild(sp_card,10)

		AudioEngine.playEffect("mp3/GambleWin.mp3")
		--if(num%2 ==1  and cardType == RED) or (num%2 == 0  and cardType == BLACK)  then  
		self.bank = win --self.bank * 2 
		self:initText()
		
		local dt =cc.DelayTime:create(2)--等待 
		local spa =cc.Spawn:create(cc.MoveTo:create(0.6,cc.p(self.posX,530)),cc.ScaleTo:create(0.6,0.4))
		local seq =cc.Sequence:create(dt,spa,cc.CallFunc:create(handler(self,self.callback111)),nil)
		sp_card:runAction(seq)
		self.posX =self.posX+spaceX
	else
		if bBLACK then  -- 猜黑色赢了 客户端给出一张红色的牌
			nCardNum = nCardRed[nCardRand] * 16 + nCardType
		else -- 猜红色赢了 客户端给出一张黑色的牌
			nCardNum = nCardBlack[nCardRand] * 16 + nCardType
		end

		--显示牌 
		local sp_card=self:initCard(nCardNum)
		sp_card:setScale(0.95,0.95)
		sp_card:setPosition(self.sp_1:getPosition())
		self:addChild(sp_card,10)

		AudioEngine.playEffect("mp3/GambleLost.mp3")
		--输了
		local dt =cc.DelayTime:create(2)--等待 
		local seq =cc.Sequence:create(dt,cc.CallFunc:create(
		function()
			self:ExitPlayGame()
		end),nil)
		sp_card:runAction(seq)
	end  

	bRED = false
	bBLACK = false
end

function PlayScene:startGameByNet(cardType) 
	print("#################self.bank:"..self.bank)
	--SendMsg:guessCard()
	--猜牌 传1 ？ 纳尼
	self._scene._scene:guessCard(1)
end


function PlayScene:setBtn(enble)
	self.btn_collect:setEnabled(enble) 
	self.btn_collect:setBright(enble) 
	self.btn_black:setEnabled(enble) 
	self.btn_black:setBright(enble)
	self.btn_red:setEnabled(enble) 
	self.btn_red:setBright(enble)
end 


--初始化一涨牌
function PlayScene:initCard(n0x_val)
	local cardType , cardNum= self:getCardVal(n0x_val)
	local str_path=""
	if(cardType == "1") then  
		str_path = str_path.."fk"
	elseif(cardType == "2") then  
		str_path = str_path.."mh"
	elseif(cardType == "3") then  
		str_path = str_path.."hon"
	elseif(cardType == "4") then  
		str_path = str_path.."ht"
	end
	--print("$$$$$$$$$$$$$$$$$$$$$".."poker/"..str_path.."_"..cardNum..".png")
	return cc.Sprite:create("poker/"..str_path.."_"..cardNum..".png")
end

function PlayScene:ExitPlayGame()
	self.nleftTime = 0
	AudioEngine.stopMusic()
	--cc.Director:getInstance():popScene()
	
	--UserInfo:instance():UpdateModifyScore()
	self._scene.GameBalanceText:setString(string.format("%d",GlobalUserItem.lUserScore))
	self._scene:GameBJMp3()

	self:setVisible(false)
    self:removeAllChildren()
    self:removeFromParent()
end

return PlayScene
