--
-- Author: Tang
-- Date: 2016-08-09 10:31:00
--炮台
local CannonLayer = class("CannonLayer", cc.Layer)

local module_pre = "game.yule.lkpy.src"			
local ExternalFun = require(appdf.EXTERNAL_SRC.."ExternalFun")
local cmd = module_pre..".models.CMD_LKGame"
local Cannon = module_pre..".views.layer.Cannon"
local g_var = ExternalFun.req_var
local scheduler = cc.Director:getInstance():getScheduler()
CannonLayer.enum = 
{

	Tag_userNick =1, 	

	Tag_userScore=2,

	Tag_GameScore = 10,
	Tag_Buttom = 70 ,

	Tag_Cannon = 200,

}

local TAG =  CannonLayer.enum
function CannonLayer:ctor(viewParent)
	self.bullet_count = {} --子弹数量

	self.parent = viewParent
	self._dataModel = self.parent._dataModel
	self._gameView  = self.parent._gameView
	self._gameFrame  = self.parent._gameFrame
	
	--自己信息
	self.m_pUserItem = self._gameFrame:GetMeUserItem()
    self.m_nTableID  = self.m_pUserItem.wTableID
    self.m_nChairID  = self.m_pUserItem.wChairID
    self.m_dwUserID  = self.m_pUserItem.dwUserID

    self.m_cannonList = {} --炮台列表

    self._userList    = {}

    self.rootNode = nil

    self.m_userScore = 0	--用户分数 

--炮台位置
    self.m_pCannonPos = 
    {
		-- cc.p(271,100),
	    -- cc.p(667,100),
	    -- cc.p(1082,100),

	    -- cc.p(1082,700),

	    -- cc.p(667,700),
	    -- cc.p(271,700),

	    
    	cc.p(180,700),
	    cc.p(617,700),
	    cc.p(1042,700),

	    -- cc.p(1292,400),

	    cc.p(1042,50),
	    cc.p(617,50),
	    cc.p(180,50),

	    -- cc.p(41,400),
	    
	}

--gun位置
	self.m_GunPlatformPos =
	{

		-- cc.p(271,70),
	    -- cc.p(667,70),
	    -- cc.p(1082,70),

	    -- cc.p(1082,732),

	    -- cc.p(667,732),
	    -- cc.p(271,732),

		cc.p(181,732),
		cc.p(617,732),
		cc.p(1042,732),

		-- cc.p(cc.Director:getInstance():getVisibleSize().width-20,400),

		cc.p(1042,25),

		cc.p(617,25),
		cc.p(181,25),

		-- cc.p(20,400),
	}

--用户信息背景
	self.m_NickPos = cc.p(78+15,14)
	self.m_ScorePos = cc.p(185-7,41 + 11)

	self.myPos = 0			--视图位置


	-- self:init()

	--  --注册事件
	-- ----print(("fffffffffffffffffffffffffffffffffff")
	-- self:setName("fff")
    ExternalFun.registerTouchEvent(self,false)
	local csbNode = ExternalFun.loadCSB("game_res/Cannon.csb", self)
	self.rootNode = csbNode
	for i=1,8 do
		self:HiddenCannonByChair(i)
	end
 	-----------------------------new add  -----------------------------------------------
 	self.canFire = true
 	self.updateCanFire = nil
 	self.userScore = {}
 	self.current_bullet_kind_ = {}
 	self.current_angle_ = {}
	self.current_mulriple_ = {}
	self.fish_score_ = {}
	self.bullet_count_ = {}
	----print(("5655555555555555555555555555")
	for i=1, 6 do
		self.bullet_count_[i] = 0
	end
end

function CannonLayer:init()
	 --注册事件


	--初始化自己炮台
	local myCannon = g_var(Cannon):create(self)
	print("woicao11 -----------------  " , self._dataModel,myCannon.m_pos)
	myCannon:initWithUser(self.m_pUserItem)
	myCannon:setPosition(self.m_pCannonPos[myCannon.m_pos + 1])
	self:removeChildByTag(TAG.Tag_Cannon + myCannon.m_pos + 1)
	myCannon:setTag(TAG.Tag_Cannon + myCannon.m_pos + 1)
	------------------------创建上分下分按钮---------------------------------
	local function touchEvent(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
	        local scalTo = cc.ScaleTo:create(0.08,sender:getScale()*1.1)
			local scalTo1 = cc.ScaleTo:create(0.08,sender:getScale())
			local call = cc.CallFunc:create(function()		
	  	       sender:setScale(1)
	   		end)	
			local seq = cc.Sequence:create(scalTo,scalTo1,call)
			sender:runAction(seq)

        	local tag = sender:getTag()

        	if tag == 1 then
        		myCannon:addPao()
	        else
	        	myCannon:cutPao()
	        end
        end
    end
    local scoreBtnImg = {"cannon/increase.png", "cannon/decrease.png" }
    for i=1,2 do 
		local scoreBtn = ccui.Button:create()
		scoreBtn:setTag(i)
	    scoreBtn:setTouchEnabled(true)
	    scoreBtn:setScale9Enabled(true)
	    scoreBtn:loadTextures(scoreBtnImg[i], scoreBtnImg[i], "")
	    if i == 1 then
		    if myCannon.m_pos + 1 > 3 then
		    	scoreBtn:setPositionX(-10)
				scoreBtn:setPositionY(50)
			-- elseif myCannon.m_pos + 1 == 4 then
			-- 	scoreBtn:setPositionX(50)
			-- 	scoreBtn:setPositionY(100)
			-- elseif myCannon.m_pos + 1 == 8 then
			-- 	scoreBtn:setPositionX(50)
			-- 	scoreBtn:setPositionY(100)
			else
				scoreBtn:setPositionX(-10)
				scoreBtn:setPositionY(50)
			end
		else
			if myCannon.m_pos + 1 >3 then
				scoreBtn:setPositionX(110)
				scoreBtn:setPositionY(50)
			-- elseif myCannon.m_pos + 1 == 4 then
			-- 	scoreBtn:setPositionX(50)
			-- 	scoreBtn:setPositionY(-10)
			-- elseif myCannon.m_pos + 1 == 8 then
			-- 	scoreBtn:setPositionX(50)
			-- 	scoreBtn:setPositionY(-10)
			else
				scoreBtn:setPositionX(110)
				scoreBtn:setPositionY(50)
			end
		end
	    
	    --scoreBtn:setContentSize(cc.size(38, 40))
		scoreBtn:addTouchEventListener(touchEvent)
		scoreBtn:setVisible(false)
	    myCannon:addChild(scoreBtn)
    end
	

    ------------------------创建上分下分按钮---------------------------------
	self.mypos = myCannon.m_pos + 1
	self:initCannon()

	self:addChild(myCannon)

	--位置提示
	-- ----print(("当前位置是------------------------------------------",myCannon.m_pos)
	local realTipPos  = cc.p(myCannon:getPositionX(), 180)
	local animUpPos   = cc.p(myCannon:getPositionX(),210)
	local animDownPos = cc.p(myCannon:getPositionX(),180)

	if myCannon.m_pos < 3 then
		realTipPos  = cc.p(myCannon:getPositionX(), yl.HEIGHT-200)
		animUpPos   = cc.p(myCannon:getPositionX(), yl.HEIGHT-200)
		animDownPos = cc.p(myCannon:getPositionX(), yl.HEIGHT-230)

  	end
	-- if myCannon.m_pos <= 2 then
	-- 	  realTipPos  = cc.p(myCannon:getPositionX(), yl.HEIGHT-200)
	-- 	  animUpPos   = cc.p(myCannon:getPositionX(), yl.HEIGHT-200)
	-- 	  animDownPos = cc.p(myCannon:getPositionX(), yl.HEIGHT-230)
	-- elseif myCannon.m_pos == 3 then
	-- 	realTipPos    = cc.p(myCannon:getPositionX()-200, myCannon:getPositionY()-20)
	-- 	animUpPos     = cc.p(myCannon:getPositionX()-200, myCannon:getPositionY()-20)
	-- 	animDownPos   = cc.p(myCannon:getPositionX()-230, myCannon:getPositionY()-20)
	-- elseif myCannon.m_pos == 7 then
	-- 	realTipPos    = cc.p(myCannon:getPositionX()+200, myCannon:getPositionY()-20)
	-- 	animUpPos     = cc.p(myCannon:getPositionX()+200, myCannon:getPositionY()-20)
	-- 	animDownPos   = cc.p(myCannon:getPositionX()+230, myCannon:getPositionY()-20)
	-- end

	-- ----print(("真实位置是-:::::::::::::::::::::::::::::::::::::::: ",realTipPos.x, realTipPos.y)
	local tipsImage = ccui.ImageView:create("game_res/pos_tips.png")
	tipsImage:setAnchorPoint(cc.p(0.5,0.0))
	tipsImage:setPosition(realTipPos)
	self:addChild(tipsImage)


	local arrow = ccui.ImageView:create("game_res/pos_arrow.png")
	arrow:setAnchorPoint(cc.p(0.5,1.0))

	local arrowPos   = cc.p(tipsImage:getContentSize().width/2, 3)
	if myCannon.m_pos< 3 then
		arrowPos = cc.p(tipsImage:getContentSize().width/2, 50)
		arrow:setRotation(180)
	end
	-- if myCannon.m_pos <= 2 then
	-- 	arrowPos = cc.p(tipsImage:getContentSize().width/2, 50)
	-- 	arrow:setRotation(180)
	-- elseif myCannon.m_pos == 3 then
	-- 	arrowPos = cc.p(tipsImage:getContentSize().width, 25)
	-- 	arrow:setRotation(-90)
	-- elseif myCannon.m_pos == 7 then
	-- 	arrowPos = cc.p(0, 25)
	-- 	arrow:setRotation(90)
	-- end
	
	arrow:setPosition(arrowPos)
	tipsImage:addChild(arrow)


	--跳跃动画
	local jumpUP = cc.MoveTo:create(0.4, animUpPos)
	local jumpDown =  cc.MoveTo:create(0.4,animDownPos)
	tipsImage:runAction(cc.Repeat:create(cc.Sequence:create(jumpUP,jumpDown), 20))

	tipsImage:runAction(cc.Sequence:create(cc.DelayTime:create(5),cc.CallFunc:create(function (  )
		tipsImage:removeFromParent()
	end)))

	local pos = self.m_nChairID
	self:showCannonByChair(pos+1)
	self:initUserInfo(pos+1,self.m_pUserItem)
	
	local cannonInfo ={d=self.m_dwUserID,c=pos+1,cid = self.m_nChairID}
	table.insert(self.m_cannonList,cannonInfo)
	--默认设置子弹分数为100
	myCannon:setMultiple(1000)
end	

function CannonLayer:initCannon()

	local mypos = self.m_nChairID

	if self._dataModel.m_reversal then 
		-- mypos = 5 - mypos
	end

	-- for i=1,8 do
	-- 	--if i~= mypos then
	-- 		self:HiddenCannonByChair(i)
	-- --	end
	-- end
end

function CannonLayer:initUserInfo(viewpos,userItem)
	local rpos = viewpos
	if viewpos == 4 then
		viewpos = 6
	elseif viewpos == 5 then
		viewpos = 5
	elseif viewpos == 6 then
		viewpos = 4

	end
	-- if viewpos == 4 then
	-- 	viewpos = 1
	-- elseif viewpos == 5 then
	-- 	viewpos = 2
	-- elseif viewpos == 6 then
	-- 	viewpos = 3
	-- end

	-- if viewpos == 4 then
	-- 	viewpos = 8
	-- elseif viewpos == 5 then
	-- 	viewpos = 6
	-- elseif viewpos == 6 then
	-- 	viewpos = 5
	-- elseif viewpos == 7 then
	-- 	viewpos = 4
	-- elseif viewpos == 8 then
	-- 	viewpos = 7
	-- end
	local infoBG = self.rootNode:getChildByName(string.format("im_info_bg_%d", viewpos))
	-- infoBG:initWithFile("game_res/num_clear_multiple.png",cc.rect(0,0,16,17))
	infoBG:initWithFile("score_fish_box1.png")
		if viewpos == 4 or viewpos == 5 or viewpos ==6 then
			infoBG:setPositionY(50)
			if viewpos == 4 then
				infoBG:setPositionX(self.m_GunPlatformPos[6].x  +160)
			elseif viewpos == 5 then
				infoBG:setPositionX(self.m_GunPlatformPos[viewpos].x  + 160)
			elseif viewpos == 6 then
				infoBG:setPositionX(self.m_GunPlatformPos[4].x  + 160)
			end
			
			print("111112PPP" .. infoBG:getPositionX())
		elseif viewpos == 1 or viewpos == 2 or viewpos ==3 then
			--infoBG:setFlippedX(false)
			infoBG:initWithFile("score_fish_box2.png")
			infoBG:setPositionX(self.m_GunPlatformPos[viewpos].x +160)
		end

	self.userScore[rpos] = cc.Label:createWithCharMap("credit_num.png",16,24,string.byte("0"))
	self.userScore[rpos]:setTag(TAG.Tag_userScore)
	self.userScore[rpos]:setScaleX(0.8)

	if rpos <=3 then
		self.userScore[rpos]:setAnchorPoint(0,0.5)
		self.userScore[rpos]:setPosition(self.m_ScorePos.x-50, self.m_ScorePos.y-10)
		
	elseif rpos > 3 then
		self.userScore[rpos]:setAnchorPoint(0,0.5)
		self.userScore[rpos]:setPosition(self.m_ScorePos.x-106, self.m_ScorePos.y)
	end

	-- if rpos >= 5 and rpos <= 7 then
	-- 	self.userScore[rpos]:setAnchorPoint(1,0.5)
	-- 	self.userScore[rpos]:setPosition(self.m_ScorePos.x, self.m_ScorePos.y)
	-- elseif rpos <= 3 then
	-- 	self.userScore[rpos]:setAnchorPoint(1,0.5)
	-- 	self.userScore[rpos]:setPosition(self.m_ScorePos.x-115, self.m_ScorePos.y)
	-- elseif rpos == 4 then
	-- 	self.userScore[rpos]:setAnchorPoint(0,0.5)
	-- 	self.userScore[rpos]:setPosition(self.m_ScorePos.x-115, self.m_ScorePos.y)
	-- else
		-- self.userScore[rpos]:setAnchorPoint(0,0.5)
		-- self.userScore[rpos]:setPosition(self.m_ScorePos.x-115, self.m_ScorePos.y)
	-- end

	local nick = cc.Label:createWithSystemFont("","Arial",20)
	nick:setString(userItem.szNickName)
	nick:setName("nickname")
	nick:setPosition(self.m_NickPos.x, self.m_NickPos.y)
	if rpos<=3 then
		nick:setPosition(self.m_ScorePos.x-80, self.m_NickPos.y+62)
	end
	infoBG:addChild(nick)

	--dump(self.userScore[rpos]:getPositionX(),"self.userScore[rpos]:")
	--print("rpos position :"..rpos)
	self.userScore[rpos]:setString(0)
	infoBG:removeChildByTag(TAG.Tag_userScore)
	infoBG:addChild(self.userScore[rpos])

	if rpos<=3 then
		self.userScore[rpos]:setRotation(180)
		nick:setRotation(180)
	end
	-- if rpos<=3 then
	-- 	self.userScore[rpos]:setRotation(180)
	-- elseif rpos == 4 then

	-- elseif rpos == 8 then

	-- end
end
--设置鱼币数
function CannonLayer:setFishGold(chair, score)
	if score < 0 then
		return
	end
	if self.userScore[chair] ~= nil then
		self.userScore[chair]:setString( score )
		self.bullet_count_[chair] =  score
	end
	
	--print("setFish Gols chair" .. chair .."score is ".. score)
	--dump(self.userScore)
end

function CannonLayer:getFishGold( chair )
	--dump(self.userScore)
	--print("getFishGold chair " .. chair)
	if self.userScore[chair] ~= nil then
		--print("getfish gold enter : " .. self.userScore[chair]:getString())
		return tonumber(self.userScore[chair]:getString())
	end
	return nil
end
function CannonLayer:updateMultiple( mutiple,cannonPos )
	----print(("mutiple,cannonPos ",mutiple,cannonPos)
	local gunPlatformButtom = self:getChildByTag(TAG.Tag_Buttom+cannonPos)
	if gunPlatformButtom~=nil then 
		local labelMutiple = gunPlatformButtom:getChildByTag(500)
		-- ----print(("labelMutiple ",labelMutiple)
		if nil ~= labelMutiple then
			labelMutiple:setString(string.format("%d", mutiple))
		end
	end
end

-- function CannonLayer:updateUserScore( score,cannonpos )
	
-- 	local infoBG = self.rootNode:getChildByName(string.format("im_info_bg_%d", cannonpos))
-- 	if infoBG == nil then
-- 		return
-- 	end
-- 	local scoreLB = infoBG:getChildByTag(TAG.Tag_userScore)
-- 	if score >= 0 and nil ~= scoreLB then
-- 		scoreLB:setString(string.format("%d", score))
-- 	end

-- 	local mypos = self.m_nChairID
-- 	if self._dataModel.m_reversal then 
-- 		mypos = 5 - mypos
-- 	end

-- 	if mypos == cannonpos - 1 then
-- 		self.parent._gameView:updateUserScore(score)
-- 	end
-- end


function CannonLayer:HiddenCannonByChair( chair )

	local rchair = chair

	if chair == 4 then
		chair = 6
	elseif chair == 5 then
		chair = 5
	elseif chair == 6 then
		chair = 4
	end

	-- if chair == 4 then
	-- 	chair = 8
	-- elseif chair == 5 then
	-- 	chair = 6
	-- elseif chair == 6 then
	-- 	chair = 5
	-- elseif chair == 7 then
	-- 	chair = 4
	-- elseif chair == 8 then
	-- 	chair = 7
	-- end
	-- if chair == 1 then
	-- 	chair = 4
	-- elseif chair == 2 then
	-- 	chair = 5
	-- elseif chair == 3 then
	-- 	chair = 6
	-- elseif chair == 4 then
	-- 	chair = 3
	-- elseif chair == 5 then
	-- 	chair = 2
	-- elseif chair == 6 then
	-- 	chair = 1
	-- elseif chair == 7 then
	-- 	chair = 7
	-- elseif chair == 8 then
	--  	chair = 8
	-- end

	local infoBG = self.rootNode:getChildByName(string.format("im_info_bg_%d", chair))
	infoBG:initWithFile("score_fish_box.png")
	infoBG:setVisible(false)

	local gunPlatformCenter = self.rootNode:getChildByName(string.format("gunPlatformCenter_%d", chair))
	gunPlatformCenter:setVisible(false)

	self:removeChildByTag(TAG.Tag_Buttom + rchair)

end

function CannonLayer:showCannonByChair( chair )

	local rchair = chair
	
	if chair == 4 then
		chair = 6
	elseif chair == 5 then
		chair = 5
	elseif chair == 6 then
		chair = 4
	end

	-- if chair == 4 then
	-- 	chair = 8
	-- elseif chair == 5 then
	-- 	chair = 6
	-- elseif chair == 6 then
	-- 	chair = 5
	-- elseif chair == 7 then
	-- 	chair = 4
	-- elseif chair == 8 then
	-- 	chair = 7
	-- end

	-- if chair == 1 then
	-- 	chair = 4
	-- elseif chair == 2 then
	-- 	chair = 5
	-- elseif chair == 3 then
	-- 	chair = 6
	-- elseif chair == 4 then
	-- 	chair = 1
	-- elseif chair == 5 then
	-- 	chair = 2
	-- elseif chair == 6 then
	-- 	chair = 3
	-- end
	

	local infoBG = self.rootNode:getChildByName(string.format("im_info_bg_%d", chair))
	infoBG:initWithFile("score_fish_box.png")
	----print(("showCannonByChair infoBG ", chair, infoBG)
	if infoBG == nil then
		return
	end
	print("show chair " .. rchair )
	infoBG:setVisible(true) --玩家信息

	local gunPlatformCenter = self.rootNode:getChildByName(string.format("gunPlatformCenter_%d", chair))
	gunPlatformCenter:setVisible(true)
	


	local gunPlatformButtom = cc.Sprite:create("game_res/gunPlatformButtom.png")
	local hypos = self.m_GunPlatformPos[rchair]
	gunPlatformButtom:setPosition(hypos.x, hypos.y)
	gunPlatformButtom:setTag(TAG.Tag_Buttom+rchair)
	self:removeChildByTag(TAG.Tag_Buttom+rchair)
	self:addChild(gunPlatformButtom,5)

	if chair ==4 or chair == 5 or chair == 6 then
		gunPlatformCenter:setPosition(hypos.x, hypos.y+15)
	else
		gunPlatformCenter:setPosition(hypos.x, hypos.y)
	end
	--倍数
	local labelMutiple = cc.LabelAtlas:create("1","game_res/mutipleNum.png",14,17,string.byte("0"))
	labelMutiple:setTag(500)
	labelMutiple:setAnchorPoint(0.5,0.5)
	labelMutiple:setPosition(gunPlatformButtom:getContentSize().width/2,22)
	gunPlatformButtom:removeChildByTag(1)
	gunPlatformButtom:addChild(labelMutiple,1)

	if rchair < 3 then
		gunPlatformButtom:setRotation(180)
		labelMutiple:setRotation(180)
		gunPlatformButtom:setFlippedX(true)
	
	end
	-- if rchair <= 3 then
	-- 	gunPlatformButtom:setRotation(180)
	-- 	labelMutiple:setRotation(180)
	-- 	gunPlatformButtom:setFlippedX(true)
	-- elseif rchair == 4 then
	-- 	gunPlatformButtom:setRotation(-90)
	-- 	-- labelMutiple:setRotation(-90)
	-- elseif rchair == 8 then
	-- 	gunPlatformButtom:setRotation(90)
	-- 	-- labelMutiple:setRotation(90)
	-- end
end

function CannonLayer:getCannon(pos)
	if pos~=nil then 
		local cannon = self:getChildByTag(pos + TAG.Tag_Cannon)
		return cannon 
	else
		return nil
	end
end


function CannonLayer:getCannoByPos( pos )
	local cannon = self:getChildByTag(TAG.Tag_Cannon + pos)
	return cannon
end

-- function CannonLayer:getChairByCannon( viewid )
-- 	local chairID = yl.INVALID_CHAIR
-- 	if self._dataModel.m_reversal then 
-- 		chairID = math.abs(6-viewid)
-- 	else	
-- 	   chairID = viewid - 1 
-- 	end
-- 	return chairID
-- end


-- function CannonLayer:getUserIDByCannon(viewid)

-- 	local userid = 0
-- 	if #self.m_cannonList > 0 then
-- 		for i=1,#self.m_cannonList do
-- 			local cannonInfo = self.m_cannonList[i]
-- 			if cannonInfo.c == viewid then
-- 				userid = cannonInfo.d
-- 				break
-- 			end
-- 		end
--  	end
	
-- 	 return userid
-- end

function CannonLayer:onEnter( )
	
end


function CannonLayer:onEnterTransitionFinish(  )

  
end

function CannonLayer:onExit( )

	self.m_cannonList = nil
end

function CannonLayer:compute_collision( bird_x,  bird_y, bird_width,  bird_height,  bird_rotation,bullet_x,  bullet_y,  bullet_radius )
	local sint, cost;
	local w, h, rx, ry, r;

	cost = math.cos(bird_rotation);
	sint = math.sin(bird_rotation);

	w = bird_width;
	h = bird_height;
	r = bullet_radius;
	rx = (bullet_x - bird_x) * cost + (bullet_y - bird_y) * sint;
	ry = -(bullet_x - bird_x) * sint + (bullet_y - bird_y) * cost;

	local tmin = function ( a,b)
		if a<b then
			return a
		else
			return b
		end
	end

	local tmax = function ( a,b )
		if a<b then
			return b
		else
			return a
		end
	end

	local dx = tmin(rx, w*0.5);
	dx = tmax(dx, -w*0.5);

	local dy = tmin(ry, h*0.5);
	dy = tmax(dy, -h*0.5);

	return (rx - dx)*(rx - dx) + (ry - dy)*(ry - dy) <= r*r;
end

function CannonLayer:onTouchBegan(touch, event)
	-- ----print(("_exchangeSceneing ", self._dataModel._exchangeSceneing)
	if self._dataModel._exchangeSceneing  then 	--切换场景中不能发炮
		return false
	end
	if self.canFire == false then return false end
	local pos = touch:getLocation()
	local cannon = self:getCannon(self.mypos)
	if cannon ~= nil then
		--切换鱼
	  if cannon._dataModel.m_autolock then

		local isHaveFish = function ( touch  )
			local pos1 = touch:getLocation()
			local pt_bullet = cc.p(pos1.x,720 - pos1.y)
			local fish_pos
			for k,v in pairs(self.parent._dataModel.m_fishList) do 
				fish_pos = { x = v:getPositionX() , y =720 - v:getPositionY()}
				local tempV = v.m_data.fish_kind+1
				if v.m_data.fish_kind >= 40 then
				
					if v.m_data.item_+1 == 1 then
						tempV = 2
					elseif v.m_data.item_+1 == 2 then
						tempV = 1
					else
						tempV = v.m_data.item_+1
					end
				end 
				local w = self.parent.fish_bounding_box_width_[tempV]
				local h = self.parent.fish_bounding_box_height_[tempV]
				local fish_rotation = v:getRotation() * g_var(cmd).M_PI /180

				local __fish = self.parent._dataModel.m_fishList[self.parent._dataModel.m_fishIndex]

        		if __fish:getChildByName("last") then
            		__fish:getChildByName("last"):removeFromParent()
				end
				if self:compute_collision(fish_pos.x,fish_pos.y ,w,h,fish_rotation ,pt_bullet.x,pt_bullet.y ,10) then
					
					--切换成当前锁定目标
					cannon:setLockAngle(v.m_data.fish_id)
					self.parent._dataModel.m_fishIndex = v.m_data.fish_id
					return true
				end

			end
			return false
		end

		if isHaveFish(touch) then
			cannon:shoot(cc.p(pos.x,pos.y), true)
		else
			cannon:shoot(cc.p(pos.x,pos.y), true)
		end
		--cannon:setAutoShoot(true)

	  else
     	
		cannon:shoot(cc.p(pos.x,pos.y), true)

		self.parent:setSecondCount(120)
	  end	
		
	end

	return true
end

function CannonLayer:onTouchMoved(touch, event)
	
	local cannon = self:getCannon(self.mypos)

	if nil ~= cannon then
		local pos = touch:getLocation()

		cannon:shoot(cc.p(pos.x,pos.y), true)
		self.parent:setSecondCount(120)

	end
end

function CannonLayer:onTouchEnded(touch, event )
	
	local cannon = self:getCannon(self.mypos)

	if nil ~= cannon then

		local pos = touch:getLocation()

		cannon:shoot(cc.p(pos.x,pos.y), false)
		self.parent:setSecondCount(120)
	end

	local function updateCanFire(dt)
		self.canFire = true
		scheduler:unscheduleScriptEntry(self.updateCanFire)
		self.updateCanFire = nil
	end

	if nil == self.updateCanFire then
		self.canFire = false
		self.updateCanFire = scheduler:scheduleScriptFunc(updateCanFire, self._dataModel.m_secene.nBulletCoolingTime/1000-0.1, false)
	end
end

--新加
function CannonLayer:onSceneAddUser( wTableID,wChairID,useritem)

	local pos = wChairID
 
    if pos + 1 == self.m_pos then  --过滤自己
 		return
 	end

    self:showCannonByChair(pos + 1)
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
	self:addChild(Cannon)
	self:initUserInfo(pos + 1,useritem)

	local cannonInfo ={d=useritem.dwUserID,c=pos+1,cid = useritem.wChairID}
	table.insert(self.m_cannonList,cannonInfo)

	table.insert(self._userList, useritem)


end
--用户进入
function CannonLayer:onEventUserEnter( wTableID,wChairID,useritem )
	
    print("add user " .. useritem.wChairID .. "; nick " .. useritem.szNickName)
     dump(useritem,"addUserdata->>>")
    -- if wChairID > 5 or wTableID ~= self.m_nTableID or wChairID == self.m_nChairID then
    if wTableID ~= self.m_nTableID or wChairID == self.m_nChairID then
    	----print(("添加炮台时 不是同一个桌子，或者是自己 就忽略")
    	return
    end

    local pos = wChairID
    -- if self._dataModel.m_reversal then 
    -- 	pos = 5 -pos 
    -- end
    ----print(("pos ",pos , self.m_pos)
    if pos + 1 == self.m_pos then  --过滤自己
 		return
 	end

    self:showCannonByChair(pos + 1)
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
	--add by zzy
	Cannon:setMultiple(1000)
	self:addChild(Cannon)
	self:initUserInfo(pos + 1,useritem)

	local cannonInfo ={d=useritem.dwUserID,c=pos+1,cid = useritem.wChairID}
	table.insert(self.m_cannonList,cannonInfo)

	table.insert(self._userList, useritem)
	
	-- dump(self.m_pCannonPos[Cannon.m_pos + 1])
	-- dump(self._userList)
	-- dump(self.m_cannonList)
	-- self:setFishGold(useritem.wChairID+1, useritem.lScore)
end

--用户状态
function CannonLayer:onEventUserStatus(useritem,newstatus,oldstatus)
	----print(("用户状态数据 CannonLayer onEventUserStatus ",useritem,newstatus,oldstatus)
	----print(("oldstatus.wTableID ",oldstatus.wTableID, self.m_nTableID)
	--dump(useritem,"useritem->>>")
	--dump(newstatus,"newstatus->>>")
	--dump(oldstatus,"oldstatus->>>")

	local curTableID = newstatus.wTableID --进入取新的状态

	if newstatus.wTableID == yl.INVALID_TABLE then --离开 取oldstatus
		curTableID = oldstatus.wTableID
	end

	if curTableID ~= self.m_nTableID  then
		----print(("不是本桌用户....")
		return
	end
	-- --dump(useritem,"useritem->>>")
	-- --dump(newstatus,"newstatus->>>")
	-- --dump(oldstatus,"oldstatus->>>")
	-- ----print(("? ",yl.US_FREE,yl.US_NULL)
	-- error("ss")
    if newstatus.cbUserStatus == yl.US_FREE or  newstatus.cbUserStatus == yl.US_NULL then
  	    if #self.m_cannonList > 0 then
  	    	for i=1,#self.m_cannonList do

      	    	local cannonInfo = self.m_cannonList[i]
      	    	if cannonInfo.d == useritem.dwUserID then
      	    		print("用户离开"..cannonInfo.c)

					  self:HiddenCannonByChair(cannonInfo.c)
					  self.userScore[cannonInfo.c  ]:getParent():getChildByName("nickname"):removeFromParent()
					  self.userScore[cannonInfo.c  ] = nil
      	    		-- --dump(cannonInfo)
      	    		-- local  chair  = self:getChairByCannon(cannonInfo.c)
      	    		-- self._dataModel.m_secene.lPalyCurScore[1][cannonInfo.cid+1] = 0 
      	    		-- self._dataModel.m_secene.nMultipleIndex[1][cannonInfo.cid+1] = 0
      	    		-- self:setFishGold(self._dataModel.userScore.chair_id+1, scoreData.fish_score)
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
		          		cannon:removeChildByTag(1000)
			          	cannon:removeTypeTag()
		          	    cannon:removeLockTag()
		          	    cannon:removeFromParent()
		          	end
      	    		break
      	    	end
  	   		end
  	    end 
    else
    	self._gameFrame:QueryUserInfo( self.m_nTableID, useritem.wChairID)
    end
end
----------------------------------------------------------------new add-----------------------------
--[[
* @brief 改变打到鱼得到的分数
* @param [in] chair_id            谁的炮
* @param [in] swap_fish_score     改变的分数
* @return 
--]]
function CannonLayer:setFishScore( chair_id, swap_fish_score )
	-- assert(chair_id < g_var(cmd).GAME_PLAYER+1)
	-- if chair_id >= g_var(cmd).GAME_PLAYER+1 then return end
	if swap_fish_score <= 0 then
		self.bullet_count_[chair_id] = 0
	else
		--print("setFishScore :",chair_id, swap_fish_score)
		--print("self.bullet_count[chair_id] ",self.bullet_count_[chair_id])
		self.bullet_count_[chair_id] = self.bullet_count_[chair_id] + swap_fish_score
	end
end

--* @brief 初始分数和子弹数
--* @param [in] *bullet     子弹
--* @param [in] *fish       分数
function CannonLayer:initFishScoreAndBulletCount(chair_id, bullet, fishScore )
	-- for i=1, g_var(cmd).GAME_PLAYER do
		
		chair_id = chair_id +1
		self.bullet_count_[chair_id] = bullet
		self.fish_score_[chair_id]   = fishScore
		--print("initFishScoreAndBulletCount=== ",chair_id,bullet)
	-- end
end

--设置炮子弹的类型
-- @param [in] chair_id     谁的炮
-- @param [in] bullet_kind  子弹的类型
function CannonLayer:switch(chair_id, bullet_kind)
	chair_id = chair_id + 1
	assert(chair_id < g_var(cmd).GAME_PLAYER+1)
	if chair_id >= g_var(cmd).GAME_PLAYER+1 then
		----print(("炮弹return----------------------switch")
		return
	end

	self.current_bullet_kind_[chair_id] = bullet_kind
end

function CannonLayer:getCurrentBulletKind(chair_id)
	chair_id = chair_id + 1
	print("chair_id" .. chair_id)
	assert(chair_id < g_var(cmd).GAME_PLAYER+1)
	if chair_id >= g_var(cmd).GAME_PLAYER+1 then
		----print(("getCurrentBulletKind----------------------switch")
		return
	end

	return self.current_bullet_kind_[chair_id]
end
--设置玩家当前炮的角度 chair_id 谁的炮， angle 角度
function CannonLayer:setCurrentAngle(chair_id, angle)
	chair_id = chair_id + 1
	assert(chair_id < g_var(cmd).GAME_PLAYER+1)
	if chair_id >= g_var(cmd).GAME_PLAYER+1 then
		----print(("炮弹return----------------------switch")
		return
	end
	self.current_angle_[chair_id] = angle
end
--获取玩家当前炮的角度
function CannonLayer:getCurrentAngle(chair_id)
	chair_id = chair_id + 1
	return self.current_angle_[chair_id]
end
--设置玩家当前倍数
function CannonLayer:setCannonMulriple(chair_id, mulriple)
	chair_id = chair_id + 1
	assert(chair_id < g_var(cmd).GAME_PLAYER+1)
	if chair_id >= g_var(cmd).GAME_PLAYER+1 then
		----print(("炮弹return----------------------switch")
		return
	end
	self.current_mulriple_[chair_id] = mulriple
end
function CannonLayer:getCannonMulriple( chair_id )
	chair_id = chair_id + 1
	return self.current_mulriple_[chair_id]
end
function CannonLayer:addBulletCount(chair_id, score)
	chair_id = chair_id + 1
	assert(chair_id < g_var(cmd).GAME_PLAYER+1)
	if chair_id >= g_var(cmd).GAME_PLAYER+1 then
		----print(("子弹return----------------------switch")
		return
	end
	--print("addBulletCount====",chair_id,score)
	self.bullet_count_[chair_id] = score
end

function CannonLayer:getBulletsCount(chair_id)
	chair_id = chair_id + 1
	return self.bullet_count_[chair_id]
end

function CannonLayer:changeFishScoreToBullets(chair_id, count, score)
	chair_id = chair_id + 1
	assert(chair_id < g_var(cmd).GAME_PLAYER+1)
	if chair_id >= g_var(cmd).GAME_PLAYER+1 then
		----print(("score return----------------------switch")
		return
	end
	--print("changeFishScoreToBullets--- 3 ",chair_id, count)
	self.bullet_count_[chair_id] = count
	self.fish_score_[chair_id] = score
end

--还原打到的鱼分数
function  CannonLayer:resetFishScore( chair_id )
	chair_id = chair_id + 1
	assert(chair_id < g_var(cmd).GAME_PLAYER+1)
	if chair_id >= g_var(cmd).GAME_PLAYER+1 then
		----print(("还原return----------------------switch")
		return
	end
	----print(("444444444444444444444444444")
	self.fish_score_[chair_id]   = 0
	self.bullet_count_[chair_id] = 0
end

--获取金币数量
function CannonLayer:getFishMoney(chair_id)
	--no todo
end
return CannonLayer