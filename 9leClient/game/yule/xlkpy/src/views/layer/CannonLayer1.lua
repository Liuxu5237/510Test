--
-- Author: Tang
-- Date: 2016-08-09 10:31:00
--炮台
local CannonLayer = class("CannonLayer", cc.Layer)

local module_pre = "game.yule.xlkpy.src"			
local ExternalFun = require(appdf.EXTERNAL_SRC.."ExternalFun")
local cmd = module_pre..".models.CMD_LKPYGame"
local Cannon = module_pre..".views.layer.Cannon1"
local g_var = ExternalFun.req_var
local CannonSprite = require(module_pre..".views.layer.Cannon1")
local Game_CMD = appdf.req(module_pre .. ".models.CMD_LKPYGame")
local CHANGE_MULTIPLE_INTERVAL =  0.1
CannonLayer.enum = 
{

	Tag_userNick  =   1, 	

	Tag_userScore =   2,

	Tag_GameScore =   10,
	Tag_Buttom    =   70,

	Tag_Cannon    =   200,

}

local TAG =  CannonLayer.enum
function CannonLayer:ctor(viewParent)
	
	self.parent = viewParent
	self._dataModel = self.parent._dataModel

	self._gameFrame  = self.parent._gameFrame
	
	--自己信息
	self.m_pUserItem = self._gameFrame:GetMeUserItem()
    self.m_nTableID  = self.m_pUserItem.wTableID
    self.m_nChairID  = self.m_pUserItem.wChairID
    self.m_dwUserID  = self.m_pUserItem.dwUserID

    self.m_cannonList = {} --炮台列表

    self._userList    = {}

    self.rootNode = nil
    self.m_bulletSpeed = 0.5  -- 子弹加速 0.5 原始速度0.2

    self.m_userScore = 0	--用户分数 
    self.m_myCannon = nil
--炮台位置
--    self.m_pCannonPos = 
--    {
--    	cc.p(270,710),--0
--	    cc.p(667,710),--1
--	    cc.p(1082,710),--2
--	    cc.p(270,100),--3
--	    cc.p(667,100),--4
--	    cc.p(1082,100),--5
--	    cc.p(54,399),--6
--	    cc.p(1280,399)--7
--	}
    self.m_pCannonPos = 
    {
    	cc.p(440.86,750-20.5-28),
	    cc.p(908.05,750-20.5-28),
	    cc.p(440.83,20.5+28+59.5),
	    cc.p(908.05,20.5+28+59.5),
        cc.p(667,100),
	    cc.p(460,28+32),
        cc.p(54,399),
        cc.p(1280,399)
	}

--gun位置单价
--	self.m_GunPlatformPos =
--	{

--		cc.p(271,742),
--		cc.p(667,742),
--		cc.p(1082,742),
--		cc.p(271,15),
--		cc.p(667,15),
--		cc.p(1082,15),
--		cc.p(14,399),
--		cc.p(1320,399)

--	}
    self.m_GunPlatformPos = 
    {
    	cc.p(440.86,730),
        cc.p(908.05,730),
	    cc.p(440.83,20),
	    cc.p(908.05,20),
    	cc.p(271,15),
	    cc.p(460,28),
        cc.p(14,399),
        cc.p(1320,399)
	}
--用户信息背景
	self.m_NickPos = cc.p(90,14)
	--self.m_ScorePos = cc.p(95,45)
	self.m_ScorePos = cc.p(350-15,15)

	self.myPos = 0			--视图位置
    self.SecondTime = 0

	self:init()

    self.m_bullet_limit_count = 20
    self.m_bullet_cur_count = 0

	 --注册事件
    ExternalFun.registerTouchEvent(self,false)
end

function CannonLayer:init()
	
	--加载csb资源
	-- local csbNode = ExternalFun.loadCSB("game_res/Cannon.csb", self)
	local csbNode = ExternalFun.loadCSB("game_res/Cannon_1.csb", self)
    self.rootNode = csbNode

	--初始化自己炮台
	local myCannon = g_var(Cannon):create(self)

	myCannon:initWithUser(self.m_pUserItem)
	myCannon:setPosition(self.m_pCannonPos[myCannon.m_pos + 1])
	self:removeChildByTag(TAG.Tag_Cannon + myCannon.m_pos + 1)
	myCannon:setTag(TAG.Tag_Cannon + myCannon.m_pos + 1)
	self.mypos = myCannon.m_pos + 1
	self:initCannon()
	self:addChild(myCannon, 1)
    

	--位置提示
	local tipsImage = ccui.ImageView:create("game_res/pos_tips.png")
	tipsImage:setAnchorPoint(cc.p(0.5,0.0))
	tipsImage:setPosition(cc.p(myCannon:getPositionX(),180))
	self:addChild(tipsImage)

	local arrow = ccui.ImageView:create("game_res/pos_arrow.png")
	arrow:setAnchorPoint(cc.p(0.5,0.5))
	arrow:setPosition(cc.p(tipsImage:getContentSize().width/2,-10))
	tipsImage:addChild(arrow)
	local caonnonX = myCannon:getPositionX()

	local jumpUpX = caonnonX
	local jumpUpY = 210

	local jumpDownX = caonnonX
	local jumpDownY = 180
	
	if 6 == self.m_nChairID then
		jumpUpX = 230
		jumpUpY = 371

		jumpDownX = 200
		jumpDownY = 371
		arrow:setPosition(cc.p(-30,tipsImage:getContentSize().height/2))
		arrow:setRotation(90)
	elseif 7 == self.m_nChairID then
		jumpUpX = 1104
		jumpUpY = 371

		jumpDownX = 1134
		jumpDownY = 371
		arrow:setPosition(cc.p(170,tipsImage:getContentSize().height/2))
		arrow:setRotation(270)
	end
	--print(string.format("jumpUpX %d jumpUpY %d jumpDownX %d jumpDownY %d", jumpUpX,jumpUpY,jumpDownX,jumpDownY))
	--跳跃动画
	local jumpUP = cc.MoveTo:create(0.4,cc.p(jumpUpX,jumpUpY))
	local jumpDown =  cc.MoveTo:create(0.4,cc.p(jumpDownX,jumpDownY))
	tipsImage:runAction(cc.Repeat:create(cc.Sequence:create(jumpUP,jumpDown), 20))

	tipsImage:runAction(cc.Sequence:create(cc.DelayTime:create(9),cc.CallFunc:create(function (  )
		tipsImage:removeFromParent(true)
	end)))

	local pos = self.m_nChairID
	pos = CannonSprite.getPos(self._dataModel.m_reversal,pos)
	self:showCannonByChair(pos+1)
	self:initUserInfo(pos+1,self.m_pUserItem)
	
	local cannonInfo ={d=self.m_dwUserID,c=pos+1, cid = self.m_nChairID}
	table.insert(self.m_cannonList,cannonInfo)

    --dyj1
    --(dyj)
    --默认 
	local tMultipleValue = 1000
    --print("单炮价值：" .. tMultipleValue)
	self:updateMultiple(tMultipleValue, pos + 1)
    --dyj2

    --xy  上分显示
    self:frUpScore(self.parent.Copylscore , pos + 1)

end	
--初始 上分显示  lsc -> 分数
function CannonLayer:frUpScore(lsc , chairPos)

	print("初始化上分显示111 =============== ",lsc)
    self:updateUpScore(lsc , chairPos)
    self.parent.ScoreCount = lsc
end
--
function CannonLayer:showPos()
	--位置提示
	local tipsImage = ccui.ImageView:create("game_res/pos_tips.png")
	tipsImage:setAnchorPoint(cc.p(0.5,0.0))
	tipsImage:setPosition(cc.p(self.m_myCannon:getPositionX(),180))
	self:addChild(tipsImage)

	local arrow = ccui.ImageView:create("game_res/pos_arrow.png")
	arrow:setAnchorPoint(cc.p(0.5,1.0))
	arrow:setPosition(cc.p(tipsImage:getContentSize().width/2,3))
	tipsImage:addChild(arrow)

	local jumpUpX = self.m_myCannon:getPositionX()
	local jumpUpY = 210

	local jumpDownX = self.m_myCannon:getPositionX()
	local jumpDownY = 180
	--print(string.format("jumpUpX %d jumpUpY %d jumpDownX %d jumpDownY %d", jumpUpX,jumpUpY,jumpDownX,jumpDownY))
	if 6 == self.m_nChairID then
		jumpUpX = 210
		jumpUpX = self.m_myCannon:getPositionY()

		jumpDownX = 180
		jumpDownY = self.m_myCannon:getPositionY()
	end
	--跳跃动画
	local jumpUP = cc.MoveTo:create(0.4,cc.p(jumpUpX,jumpUpY))
	local jumpDown =  cc.MoveTo:create(0.4,cc.p(jumpDownX,jumpDownY))
	tipsImage:runAction(cc.Repeat:create(cc.Sequence:create(jumpUP,jumpDown), 20))

	tipsImage:runAction(cc.Sequence:create(cc.DelayTime:create(5),cc.CallFunc:create(function (  )
		tipsImage:removeFromParent(true)
	end)))
end


function CannonLayer:initCannon()

	local mypos = self.m_nChairID

	mypos = CannonSprite.getPos(self._dataModel.m_reversal,mypos)

--	for i=1,8 do
--		if i~= mypos+1 then
--			self:HiddenCannonByChair(i)
--		end
--	end
    for i=1,4 do
		if i~= mypos+1 then
			self:HiddenCannonByChair(i)
		end
	end
end


function CannonLayer:initUserInfo(viewpos,userItem)
    
	local infoBG = self.rootNode:getChildByName(string.format("im_info_bg_%d", viewpos))

	if infoBG == nil then
		return
	end
	--print("---------------initUserInfo---------------------------",userItem.wChairID,userItem.lScore)
	--local nick =  cc.Label:createWithSystemFont(userItem.szNickName,"Aril",18)--cc.Label:createWithTTF(userItem.szNickName, "fonts/round_body.ttf", 18)
	--local scoreNum = cc.Label:createWithCharMap("game_res/scoreNum.png",16,22,string.byte("0"))
	local scoreNum = cc.LabelAtlas:_create("0", "game_res/numberlabel_gold_big1.png", 27, 34, string.byte("+"))
	--用户昵称
	--local nickPosX = self.m_NickPos.x
	--local nickPosY = self.m_NickPos.y
	self.m_ScorePos = cc.p(350-15,15)
    scoreNum:setScale(0.9)
	local scoreX = self.m_ScorePos.x
	local scoreY = self.m_ScorePos.y
	--self.m_NickPos = cc.p(78,14)
--	self.m_ScorePos = cc.p(350-15,15)
	--if userItem.wChairID >= 6 then
--	if userItem.wChairID >= 4 then
--		nickPosX = 120
--		nickPosY = 56
--		scoreX = 85
--		scoreY = 26
--		nick:setRotation(180)
--		scoreNum:setRotation(180)
--	end

	
	--nick:setTextColor(cc.WHITE)
	--nick:setAnchorPoint(0.5,0.5)
	--nick:setTag(TAG.Tag_userNick)
	--nick:setPosition(nickPosX, nickPosY)
	--infoBG:removeChildByTag(TAG.Tag_userNick)
	--infoBG:addChild(nick)

	--用户分数
	--scoreNum:setString(string.format("%d", 0))
    scoreNum:setString(0.00)
    --dyj1  --xy 初始分数
    if self._dataModel.m_secene.fish_score ~= nil then
       local ss = (ExternalFun.strFormatScore(self._dataModel.m_secene.fish_score[1][userItem.wChairID+1] / 1,scoreNum,false))*100

       print("初始化玩家金币 == ",ss)
--       ss = string.gsub(ss,"/","")
--       ss = string.gsub(ss,"[.]","/")
       scoreNum:setString(ss)
       --scoreNum:setString(string.format("%d",ss ))
       --scoreNum:setString(string.format("%d", math.floor(self._dataModel.m_secene.fish_score[1][userItem.wChairID+1] / 1) ) )   
       --print("初始咔咔")     
    end
    
--    --dyj2
	scoreNum:setAnchorPoint(1,0)
	scoreNum:setTag(TAG.Tag_userScore)
    --scoreNum:setScale(1.2)
	scoreNum:setPosition(scoreX, scoreY)
	infoBG:removeChildByTag(TAG.Tag_userScore)
	infoBG:addChild(scoreNum)

	--if viewpos<4 then
--	if viewpos<2 then
--		--nick:setRotation(180)
--		scoreNum:setRotation(180)
--	end

end
--更新 单个炮弹价值 显示
function CannonLayer:updateMultiple( mutiple,cannonPos )
    print("炮台的倍数:" .. mutiple)
    
	local gunPlatformButtom = self:getChildByTag(TAG.Tag_Buttom+cannonPos)
	local labelMutiple = gunPlatformButtom:getChildByTag(500)
	if nil ~= labelMutiple then
		
		local ss= (ExternalFun.strFormatScore(mutiple,labelMutiple,false))*100
		
		labelMutiple:setString(ss)
		--labelMutiple:setString(string.format("%d", mutiple ))
	end
end

--dyj1(FC++)  刷新分数显示
function CannonLayer:updateUpScore( score,cannonpos )

	--print("携带的分数:" .. score)
	local infoBG = self.rootNode:getChildByName(string.format("im_info_bg_%d", cannonpos))
	if infoBG == nil then
		return
	end
	local scoreLB = infoBG:getChildByTag(TAG.Tag_userScore)
	if score >= 0 and nil ~= scoreLB then

	local ss= (ExternalFun.strFormatScore(score,scoreLB,false))*100

     print("更新玩家金币 == ",ss)
    --local ss = string.formatNumberThousands(string.format("%d", score),true,"/")
--       ss = string.gsub(ss,"/","")
--       ss = string.gsub(ss,"[.]","/")
		scoreLB:setString(ss)  
		--scoreLB:setString(string.format("%d", score))  -- math.floor(score / 100)) )
        --print("kkkkkkkkkkk   "  .. score)
	end
end

--dyj2
function CannonLayer:updateUserScore( score,cannonpos )
	
	local infoBG = self.rootNode:getChildByName(string.format("im_info_bg_%d", cannonpos))
	if infoBG == nil then
		return
	end
	local mypos = self.m_nChairID

	mypos = CannonSprite.getPos(self._dataModel.m_reversal,mypos)

	if mypos == cannonpos - 1 then
		self.parent._gameView:updateUserScore(score)
	end
end


function CannonLayer:HiddenCannonByChair( chair )
	print("隐藏隐藏.........."..chair)

    local cannonPos = CannonSprite.getPos(self._dataModel.m_reversal, chair - 1)
    local cannon = self:getCannoByPos(cannonPos + 1)

    if cannon ~= nil then
        for i = #cannon.m_goldList, 1, -1 do
            cannon.m_goldList[i]:removeFromParent()
            table.remove(cannon.m_goldList, i)
        end
    end
    
	local infoBG = self.rootNode:getChildByName(string.format("im_info_bg_%d", chair))
	infoBG:setVisible(false)

	local gunPlatformCenter = self.rootNode:getChildByName(string.format("gunPlatformCenter_%d", chair))
	gunPlatformCenter:setVisible(false)
    gunPlatformCenter:removeChildByTag(100)
	self:removeChildByTag(TAG.Tag_Buttom + chair)

end

function CannonLayer:showCannonByChair( chair , wChairID)   
    if wChairID then
         print("椅子号：" .. wChairID)
    end

	local infoBG = self.rootNode:getChildByName(string.format("im_info_bg_%d", chair))


	if infoBG == nil then
		return
	end

	infoBG:setVisible(true) --玩家信息
	local gunPlatformCenter = self.rootNode:getChildByName(string.format("gunPlatformCenter_%d", chair))
	      gunPlatformCenter:setVisible(true)
    --dyj1
    if chair == CannonSprite.getPos(self._dataModel.m_reversal,self.m_nChairID)+1 then
       local apox=0
       local apoy=0
       local lpox=0
       local lpoy=0
     --  if chair<7 then
       if chair<3 then
--          apox=10
--          apoy=80
--          lpox=160
--          lpoy=80
          apox=-18
          apoy=30
          lpox=160-18
          lpoy=30
       else
--          apox=160
--          apoy=-30
--          lpox=10
--          lpoy=-30     
          apox=-20
          apoy=30
          lpox=150-10
          lpoy=30
       end

        local add = ccui.Button:create("game_res/add.png","","")
                add:setTag(100)
                add:setPosition(cc.p(lpox,lpoy))
                add:addTo(gunPlatformCenter)
                add:addTouchEventListener(function( sender , eventType )
                        local currTime = currentTime()
                        local aaa  = currTime - self.SecondTime
                        if eventType == ccui.TouchEventType.ended and aaa > 50 then
                            if not self.parent._gameView.m_bCanChangeMultple then
                                return 
                            end
                            local cannonPos = self.m_nChairID
                            cannonPos = CannonSprite.getPos(self._dataModel.m_reversal,cannonPos)
                            local cannon = self.parent.m_cannonLayer:getCannoByPos(cannonPos + 1)
                            self._dataModel:playEffect(Game_CMD.SWITCHING_RUN)
                            local curMultiple = self.parent.CurrShoot[1][self.m_nChairID+1]

                            if curMultiple >= self._dataModel.m_secene.MaxShoot then
                                curMultiple = self._dataModel.m_secene.MaxShoot
                            elseif curMultiple >= 1000000 and curMultiple < 10000000 and curMultiple < self._dataModel.m_secene.MaxShoot then
                                curMultiple = curMultiple + 1000000
                            elseif curMultiple >= 100000 and curMultiple < 1000000 and curMultiple < self._dataModel.m_secene.MaxShoot then
                                curMultiple = curMultiple + 100000
                            elseif curMultiple >= 10000 and curMultiple < 100000 and curMultiple < self._dataModel.m_secene.MaxShoot then
                                curMultiple = curMultiple + 10000
                            ------------------------------------------------------------------------------------------------------------------
							elseif curMultiple >= 1000 and curMultiple < 10000 and curMultiple < self._dataModel.m_secene.MaxShoot then
								curMultiple = curMultiple + 1000
							elseif curMultiple >= 100 and curMultiple < 1000 and curMultiple < self._dataModel.m_secene.MaxShoot then
								curMultiple = curMultiple + 100
                            end

                            self.parent._gameView.m_bCanChangeMultple = false
                            print("最大火力："  .. self._dataModel.m_secene.MaxShoot)
                            self.parent._gameView:changeMultipleSchedule(CHANGE_MULTIPLE_INTERVAL)
                            self.parent.CurrShoot[1][self.m_nChairID+1] = curMultiple
                            print("火力级别：  " .. curMultiple)
                            cannon:setMultiple(self.parent.CurrShoot[1][self.m_nChairID+1])
                        end
                    end)
        local less = ccui.Button:create("game_res/less.png","","")
                less:setTag(100)
                less:setPosition(cc.p(apox,apoy))
                less:addTo(gunPlatformCenter)
                less:addTouchEventListener(function( sender , eventType )
                        local currTime = currentTime()
                        local aaa  = currTime - self.SecondTime
                        if eventType == ccui.TouchEventType.ended and aaa > 50 then
                            if not self.parent._gameView.m_bCanChangeMultple then
                                return 
                            end
                            local cannonPos = self.m_nChairID
                            cannonPos = CannonSprite.getPos(self._dataModel.m_reversal,cannonPos)
                            local cannon = self.parent.m_cannonLayer:getCannoByPos(cannonPos + 1)
                            self._dataModel:playEffect(Game_CMD.SWITCHING_RUN)
                            local curMultiple = self.parent.CurrShoot[1][self.m_nChairID+1]

                            if curMultiple > 1000000 and curMultiple > self._dataModel.m_secene.MinShoot then
                                curMultiple = curMultiple - 1000000
                            elseif curMultiple > 100000 and curMultiple > self._dataModel.m_secene.MinShoot then
                                curMultiple = curMultiple - 100000
                            elseif curMultiple > 10000 and curMultiple > self._dataModel.m_secene.MinShoot then
                                curMultiple = curMultiple - 10000
                            --------------------------------------------------------------------------------------------------
							elseif curMultiple > 1000 and curMultiple > self._dataModel.m_secene.MinShoot then
								curMultiple = curMultiple - 1000
							elseif curMultiple > 100 and curMultiple > self._dataModel.m_secene.MinShoot then
								curMultiple = curMultiple - 100
                            elseif curMultiple <= self._dataModel.m_secene.MinShoot then 
                                curMultiple = self._dataModel.m_secene.MinShoot
                                --curMultiple = 1
                            end
                            print("最小火力：" .. self._dataModel.m_secene.MinShoot)
                            self.parent._gameView.m_bCanChangeMultple = false
                            self.parent._gameView:changeMultipleSchedule(CHANGE_MULTIPLE_INTERVAL)
                            self.parent.CurrShoot[1][self.m_nChairID+1] = curMultiple
                            print("火力级别：  " .. curMultiple)
                            cannon:setMultiple(self.parent.CurrShoot[1][self.m_nChairID+1])
                        end
                    end)
       
    end

    if chair<7 and chair>3 then
        infoBG:setPositionY(infoBG:getContentSize().height/2)
        --gunPlatformCenter:setPositionY(50)
        gunPlatformCenter:setPositionY(gunPlatformCenter:getContentSize().height/2)
    end
    --dyj2

	local gunPlatformButtom = cc.Sprite:create("game_res/gunPlatformButtom.png")
	gunPlatformButtom:setPosition(self.m_GunPlatformPos[chair].x, self.m_GunPlatformPos[chair].y)
	gunPlatformButtom:setTag(TAG.Tag_Buttom+chair)
	self:removeChildByTag(TAG.Tag_Buttom+chair)
	self:addChild(gunPlatformButtom,5)

	--倍数
	--local labelMutiple = cc.LabelAtlas:_create(tostring(self._dataModel.m_secene.MinShoot),"game_res/mutipleNum.png",14,17,string.byte("0"))
    local ss = (ExternalFun.strFormatScore(self._dataModel.m_secene.MinShoot,labelMutiple,false))*100              
	local labelMutiple = cc.Label:createWithSystemFont(ss,"Arial", 22)
    labelMutiple:setTextColor(cc.c4b(0,175,0,255))
	labelMutiple:setTag(500)
	labelMutiple:setAnchorPoint(0.5,0.5)
-- 	labelMutiple:setAnchorPoint(0,0.5)
	labelMutiple:setPosition(gunPlatformButtom:getContentSize().width/2,21)
    print("加加加:" .. tostring(self._dataModel.m_secene.MinShoot))

	if nil ~= wChairID and self.parent.CurrShoot~=nil then
		local tMultipleValue = self.parent.CurrShoot[1][wChairID+1]
		if self.parent.CurrShoot[1] == nil  or #self.parent.CurrShoot[1] <1 then
			if self.parent.reGameOption == true then
				return
			end
			self.parent._gameFrame:SendGameOption()
			self.parent.reGameOption = true
			return
		end

        ss = (ExternalFun.strFormatScore(tMultipleValue,labelMutiple,false) )*100         
		labelMutiple:setString(ss)
		--labelMutiple:setString(string.format("%d",tMultipleValue))
        --print("加加加")
	end
	gunPlatformButtom:removeChildByTag(1)
	gunPlatformButtom:addChild(labelMutiple,1)
	--print("chair id",chair)
--	if chair<4 then
--		gunPlatformButtom:setRotation(180)
--		gunPlatformButtom:setFlippedX(true)

--		labelMutiple:setRotation(180)
--	elseif chair == 7 then
--		gunPlatformButtom:setRotation(90)
--	elseif chair == 8 then
--		gunPlatformButtom:setRotation(270)
--	end
end


function CannonLayer:getCannon(pos)
	
	local cannon = self:getChildByTag(pos + TAG.Tag_Cannon)
	return cannon 

end


function CannonLayer:getCannoByPos( pos )

	local cannon = self:getChildByTag(TAG.Tag_Cannon + pos)
	return  cannon

end


function CannonLayer:getUserIDByCannon(viewid)

	local userid = 0
	if #self.m_cannonList > 0 then
		for i=1,#self.m_cannonList do
			local cannonInfo = self.m_cannonList[i]
			if cannonInfo.c == viewid then
				userid = cannonInfo.d
				break
			end
		end
 	end
	
	 return userid
end

function CannonLayer:onEnter( )
	
end


function CannonLayer:onEnterTransitionFinish(  )

  
end

function CannonLayer:onExit( )

	self.m_cannonList = nil
end

function CannonLayer:onTouchBegan(touch, event)

	if self._dataModel._exchangeSceneing  then 	--切换场景中不能发炮
		return false
	end

	local cannon = self:getCannon(self.mypos)

	if nil ~= cannon then
		local pos = touch:getLocation()

		cannon:shoot(pos, true)

		self.parent:setSecondCount(60)
		
	end

	return true
end

function CannonLayer:onTouchMoved(touch, event)
	
	local cannon = self:getCannon(self.mypos)

	if nil ~= cannon then
		local pos = touch:getLocation()

		cannon:shoot(cc.p(pos.x,pos.y), true)
		self.parent:setSecondCount(60)

	end
end

function CannonLayer:onTouchEnded(touch, event )
	
	local cannon = self:getCannon(self.mypos)

	if nil ~= cannon then
		local pos = touch:getLocation()

		cannon:shoot(cc.p(pos.x,pos.y), false)
		self.parent:setSecondCount(60)
	end
end

--用户进入
function CannonLayer:onEventUserEnter( wTableID,wChairID,useritem )
    --print("add user " .. useritem.wChairID .. "; nick " .. useritem.szNickName)

    if wTableID ~= self.m_nTableID or wChairID == self.m_nChairID then
    	return
    end

    local pos = wChairID
    pos = CannonSprite.getPos(self._dataModel.m_reversal,pos)
    --print(string.format("-----------------------------onEventUserEnter wChairID %d pos %d score %d---------------------", wChairID,pos,useritem.lScore))
    if pos + 1 == self.m_pos then  --过滤自己
 		return
 	end
 	
    self:showCannonByChair(pos + 1,wChairID)
 	self:removeChildByTag(TAG.Tag_Cannon + pos + 1)
 	if #self.m_cannonList > 0 then
 		for i=1,#self.m_cannonList do
 			local cannonInfo = self.m_cannonList[i]
 			if cannonInfo.d == useritem.dwUserID then
 				table.remove(self.m_cannonList,i)
 				break
 			end
 		end
 	end
 	if #self._userList > 0 then
 		for i=1,#self._userList do
 			local Item = self._userList[i]
 			if Item.dwUserID == useritem.dwUserID then
 				table.remove(self._userList,i)
 				break
 			end
 		end
 	end
 	
    local Cannon = g_var(Cannon):create(self)
	Cannon:initWithUser(useritem)
	Cannon:setPosition(self.m_pCannonPos[Cannon.m_pos + 1])
	Cannon:setTag(TAG.Tag_Cannon + Cannon.m_pos + 1)
	self:addChild(Cannon, 1)
	self:initUserInfo(pos + 1,useritem)

	local cannonInfo ={d=useritem.dwUserID,c=pos+1,cid = useritem.wChairID}
	table.insert(self.m_cannonList,cannonInfo)

	table.insert(self._userList, useritem)
end

--用户状态
function CannonLayer:onEventUserStatus(useritem,newstatus,oldstatus)

        if oldstatus.cbUserStatus == yl.US_FREE then
  		    if newstatus.wTableID ~= self.m_nTableID  then
  			    --print("不是本桌用户....")
  			    return
		    end
        end
        if newstatus.cbUserStatus == yl.US_FREE or  newstatus.cbUserStatus == yl.US_NULL then
                
        		if useritem.wChairID ==  self.m_nChairID then
        			self.parent.m_bLeaveGame = true
        			PRELOAD.setEnded(true)
        		end

          	    if #self.m_cannonList > 0 then
          	    	for i=1,#self.m_cannonList do

	          	    	local cannonInfo = self.m_cannonList[i]
	          	    	if cannonInfo.d == useritem.dwUserID then
	          	    		--print("用户离开"..cannonInfo.c)
	          	    		self:HiddenCannonByChair(cannonInfo.c)
                            self.parent._dataModel.m_secene.fish_score[1][cannonInfo.cid + 1] = 0
	          	    		table.remove(self.m_cannonList,i)

		          	    	if #self._userList > 0 then
						 		for i=1,#self._userList do
						 			local Item = self._userList[i]
						 			if Item.dwUserID == useritem.dwUserID then
						 				table.remove(self._userList,i)
						 				break
						 			end
						 		end
						 	end


	          	    	    local cannon = self:getChildByTag(TAG.Tag_Cannon + cannonInfo.c)
				          	if nil ~= cannon then
				          		--print("用户离开 nil ~= cannon")
				          		cannon:removeChildByTag(1000)
					          	cannon:removeTypeTag()
				          	    cannon:removeLockTag()
				          	    cannon:removeFromParent(true)
				          	end

	          	    	 
	          	    		break
	          	    	end
          	   		 end
          	    end 
        else
        	self._gameFrame:QueryUserInfo( self.m_nTableID,useritem.wChairID)
        end

end

return CannonLayer