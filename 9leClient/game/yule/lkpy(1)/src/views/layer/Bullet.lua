--
-- Author: Tang
-- Date: 2016-08-09 10:26:25
-- 子弹

local Bullet = class("Bullet", 	cc.Sprite)

local module_pre = "game.yule.lkpy.src"			
local ExternalFun = require(appdf.EXTERNAL_SRC.."ExternalFun")
local cmd = module_pre..".models.CMD_LKGame"
local g_var = ExternalFun.req_var
local scheduler = cc.Director:getInstance():getScheduler()
local AnimationMgr = appdf.req(appdf.EXTERNAL_SRC .. "AnimationMgr")
local TimestampManager 		= appdf.req(module_pre .. ".models.TimestampManager")

Bullet.bulletType =
{
   Normal_Bullet = 0, --正常炮
   Bignet_Bullet = 1,--网变大
   Special_Bullet = 2--加速炮
}

local Type =  Bullet.bulletType

function Bullet:ctor(angle,chairId,score,mutipleIndex,CannonType,cannon)
	self.chairId = chairId
    self.m_Type = Type.Normal_Bullet
    self.m_fishIndex = g_var(cmd).INT_MAX --鱼索引
    self.m_cannonPos = -1 --炮台索引	
    self.m_index     = -1 --子弹索引
    --self.m_netColor = cc.RED
    self.m_moveDir = cc.p(0,0)
    self.m_targetPoint = cc.p(0,0)
    self.m_isSelf = false

    self.orignalAngle = 0

    self.m_cannon = cannon
    self._dataModule = self.m_cannon._dataModel
    self._gameFrame  = self.m_cannon.frameEngine
    self.gameLayer = self.m_cannon.parent.parent
    -- self.m_speed = self._dataModule.m_gameConfig.bullet_speed[1][1]/1000*25	--子弹速度
	--self.m_speed = self._dataModule.m_gameConfig.bullet_speed[1][1]	--子弹速度
	self.m_speed = self._dataModule.m_gameConfig.bullet_speed[1]	--子弹速
    -- self.m_speed = self.m_speed--*2
    -- --print("子弹速度 ------------------  ",self.m_speed, self._dataModule.m_gameConfig.bullet_speed[1][1] )
    self.m_nScore = score --子弹分数
    self.m_nMultipleIndex = mutipleIndex
    self.angle = angle

    self:initWithAngle(angle, chairId, score, CannonType)

   	 --注册事件
    ExternalFun.registerTouchEvent(self,false)
end


function Bullet:initWithAngle(angle,chairId,score,CannonType)
	-- body bullet1_norm1_01  bullet4_norm1_01
	local nBulletNum = self:getBulletNum()

	local file = nil
	local ani  = nil
	local kind = self.m_cannon.parent:getCurrentBulletKind(chairId)
	
	if kind <= 3 then
		file = string.format("bullet%d_norm%d_01.png",nBulletNum,chairId+1)
		ani  = string.format("animation_bullet%d_norm%d", nBulletNum, chairId+1)
	else
		--离子子弹
		file = string.format("bullet%d_ion_01.png", kind-3) --bullet2_ion_01 bullet3_ion_01  bullet4_ion_01
		ani  = string.format("animation_spbullet_norm%d",kind-3)
	end
	--print("bullet file----------------------------- ",kind, file)
	self:initWithSpriteFrameName(file)
	self:setRotation(angle)
	
	self.m_moveDir = cc.pForAngle(math.rad(90-self:getRotation()))
 
	local animation = cc.AnimationCache:getInstance():getAnimation(ani)
	if nil ~= animation then
   		local action = cc.RepeatForever:create(cc.Animate:create(animation))
   		self:runAction(action)
	end
end

function Bullet:setIndex( index )
	--子弹索引
	self.m_index = index
end

function Bullet:setIsSelf( isself )
	self.m_isSelf = isself
end

function Bullet:setNetColor( color )
	self.m_netColor = color
end

function Bullet:setFishIndex( index )
	self.m_fishIndex = index
end


function Bullet:onEnter( )
	-- --print("创建子弹这个计时器")
	self:schedulerUpdate()

end


function Bullet:onExit( )
	-- --print("这就退出了。？？？？？")
	-- error("wocao ?")
	self:removeAllComponents()
	self:unSchedule()
end


function Bullet:schedulerUpdate() 
	local function updateBullet( dt )
		self:update(dt)
	end
	--定时器
	if nil == self.m_schedule then
		self.m_schedule = scheduler:scheduleScriptFunc(updateBullet, 0.033, false)
	end

end

function Bullet:unSchedule()
	if nil ~= self.m_schedule then
		scheduler:unscheduleScriptEntry(self.m_schedule)
		self.m_schedule = nil
	end
end

function Bullet:getBulletNum( )
	local bulletNum = 2 --默认两个炮管
	if self.m_nMultipleIndex >= 1000 and self.m_nMultipleIndex < 5000 then 
		bulletNum = 3 --三个炮管
	elseif self.m_nMultipleIndex >= 5000 then
		bulletNum = 4 --四个炮管
	end

	return bulletNum
end



function Bullet:setType( type )
	self.m_Type = type
	if	self.m_Type == Type.Special_Bullet  then
		self.m_speed = self.m_speed * 2
	end
end

function Bullet:initPhysicsBody()
	if self.m_fishIndex  ~= g_var(cmd).INT_MAX then

		return	
	end

	self:setPhysicsBody(cc.PhysicsBody:createBox(self:getContentSize()))
    self:getPhysicsBody():setCategoryBitmask(2)
    self:getPhysicsBody():setCollisionBitmask(0)
    self:getPhysicsBody():setContactTestBitmask(1)
    self:getPhysicsBody():setGravityEnable(false)
end

function Bullet:changeDisplayFrame( chairId , score)
	local nBulletNum = self:getBulletNum()
	local frame = string.format("Bullet%d_Normal_%d_b.png", nBulletNum,chairId + 1)
	self:setSpriteFrame(frame)
end

function Bullet:update( dt )
	-- --print("更新子弹 bullet update ",self.m_fishIndex)
	if self.m_fishIndex == g_var(cmd).INT_MAX then
		-- --print("正常发射")
		self:normalUpdate(dt) --正常发射
	else
		-- --print("锁定鱼")
		self:followFish(dt) --锁定鱼
	end
end

--正常发射
function Bullet:normalUpdate( dt )

	local movedis = self.m_speed --* dt
	local movedir = cc.p(self.m_moveDir.x*movedis,self.m_moveDir.y*movedis)  
	local pos = cc.p(self:getPositionX()+movedir.x,self:getPositionY()+movedir.y)
	-- --print("bullet pos ",dt , self.m_speed, pos.x, pos.y)
	self:setPosition(pos.x,pos.y)
	local rect = cc.rect(0,0,yl.WIDTH,yl.HEIGHT)
	pos = cc.p(self:getPositionX(),self:getPositionY())

	if not cc.rectContainsPoint(rect,pos) then
		-- --print("碰到墙了弹回来")
		if pos.x<0 or pos.x>yl.WIDTH then
			local angle = self:getRotation()
			self:setRotation(-angle)
			if pos.x<0 then
			   pos.x = 0
			else
				pos.x = yl.WIDTH
			end
		else
			local angle = self:getRotation()
			self:setRotation(-angle + 180)
			if pos.y<0 then
				pos.y = 0
			else
				pos.y = yl.HEIGHT
			end
		end

		self.m_moveDir = cc.pForAngle(math.rad(90-self:getRotation()))
		local movedis = self.m_speed --* dt
		local moveDir = cc.p(self.m_moveDir.x*movedis,self.m_moveDir.y*movedis) 
		pos = cc.p(self:getPositionX()+moveDir.x, self:getPositionY()+moveDir.y)
		self:setPosition(pos.x,pos.y)
	end

end

--锁定鱼
function Bullet:followFish(dt)
	
	local fish = self._dataModule.m_fishList[self.m_fishIndex]

	if nil == fish then --没招到这条鱼
		self.m_fishIndex = g_var(cmd).INT_MAX
		self:initPhysicsBody()
		return
	end
	
	local rect = cc.rect(0,0,yl.WIDTH,yl.HEIGHT)
	local fishPos = cc.p(fish:getPositionX(),fish:getPositionY())
	--鱼超出屏幕外了 给子弹加碰撞盒
	if not cc.rectContainsPoint(rect, fishPos) then
		self.m_fishIndex = g_var(cmd).INT_MAX
		self:initPhysicsBody()
		return
	end

	-- if self._dataModule.m_reversal then
	-- 	fishPos = cc.p(yl.WIDTH - fishPos.x , yl.HEIGHT - fishPos.y)
	-- end


	-- local angle = self._dataModule:getAngleByTwoPoint(fishPos, cc.p(self:getPositionX(),self:getPositionY()))
	-- self:setRotation(angle)
	-- self.m_moveDir = cc.pForAngle(math.rad(90-angle))

	-- self.m_moveDir = cc.pForAngle(math.rad(90-self:getRotation()))
	

	-- local movedis = self.m_speed --* dt
	-- local movedir = cc.pMul(self.m_moveDir,movedis)

	-- self:setPosition(self:getPositionX()+movedir.x,self:getPositionY()+movedir.y)

	local posX, posY = fishPos.x - self:getPositionX(), fishPos.y - self:getPositionY()
	local lize = cc.pNormalize(cc.p(posX, posY))

	local _posX = self:getPositionX() + lize.x * self.m_speed
	local _posY = self:getPositionY() + lize.y * self.m_speed

	self:setPosition(cc.p(_posX, _posY))

	if cc.pGetDistance(fishPos,cc.p(self:getPositionX(),self:getPositionY()) ) <= self.m_speed then
		self:setPosition(fishPos)
		self:fallingNet(fish)
		self:removeFromParent()
	end

end

--撒网
function Bullet:fallingNet(fish)
	--print("m_data ",fish.m_data.fish_id)
	-- error("sf")
	print("撒网------------------------------------撒网")
	local points1 = {cc.p(-25,0),cc.p(25,0)} --两个网
	local points2 = {cc.p(0,20),cc.p(-math.cos(3.14/6)*20,-math.sin(3.14/6)*20),cc.p(math.cos(3.14/6)*20,-math.sin(3.14/6)*20)} --三个网
	local points3 = {cc.p(-25,25),cc.p(25,25),cc.p(25,-25),cc.p(-25,-25)} --四个网

	self:unSchedule()

	local parent = self:getParent()
	if parent == nil then
		return
	end

	local bulletNum = 0
	local tmp = {}
	bulletNum = self:getBulletNum()

	if bulletNum == 2 then
		tmp = points1
	elseif bulletNum == 3 then
		tmp = points2
	elseif bulletNum == 4 then
		tmp = points3
	end

	local offset =  cc.pMul(self.m_moveDir,20)
	local rect = nil


		local str = "game/yule/lkpy/res/net"..bulletNum..".csb"
		local rootLayer, csbNode = ExternalFun.loadRootCSB(str, parent)
		local action = cc.CSLoader:createTimeline(str)
		local pos = cc.p(self:getPositionX(),self:getPositionY())
		csbNode:setAnchorPoint(cc.p(0.5,0.5))
	    csbNode:setPosition( pos)
	    csbNode:setRotation(self.angle)
	    rootLayer:setZOrder(20)
	    
		local function onFrameEvent( frame )
			if nil == frame then
	            return
	        end        

	        local str = frame:getEvent()
	        --print("frame event ==> "  .. str)
	        rootLayer:removeFromParent()
		end
	    action:setFrameEventCallFunc(onFrameEvent)
		   action:gotoFrameAndPlay(0,false)
		   action:setTimeSpeed(1.5)
	    rootLayer:runAction(action)
	   -- local param = AnimationMgr.getAnimationParam()
	   --  param.m_fDelay = 0.5 
	   --  param.m_bRestore = true
	   --  param.m_strName = "game_res/net"..(bulletNum-1)..".plist"
	   --  param.m_bLoop = false
	   --  AnimationMgr.playAnimation(self.gameLayer,param)

	if self.m_isSelf then
		--print("销毁。。。" .. self._dataModule.m_bulletCount)
	--销毁子弹个数
	 self._dataModule.m_bulletCount = self._dataModule.m_bulletCount - 1
	 if self._dataModule.m_bulletCount<=0 then
	 	self._dataModule.m_bulletCount = 0
	 end


		if fish ~= nil then
			local function setRedColor( fish_ )
				fish_:stopActionByTag(66)
				fish_:setColor(cc.RED)
				local sq = cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(function()
					fish_:setColor(cc.c3b(255,255,255))
				end) )
				sq:setTag(66)
				fish_:runAction(sq)
			end
			if fish:getName() == "dasanyuan" or fish:getName() == "dasixi" then
				local fishT = {}
				fishT[1] = fish
				if fish:getChildByName("fish1") ~= nil then
					fishT[2] =  fish:getChildByName("fish1")
				end
				if fish:getChildByName("fish2") ~= nil then
					fishT[3] =  fish:getChildByName("fish2")
				end
				if fish:getChildByName("fish3") ~= nil then
					fishT[4] =  fish:getChildByName("fish3")
				end
				for i=1,#fishT do
					setRedColor(fishT[i])
					if fishT[i]:getChildByName("di") ~= nil then
						setRedColor(fishT[i]:getChildByName("di"))
					end
				end
			elseif fish:getParent():getName() == "dasanyuan" or fish:getParent():getName() == "dasixi" then
				local fishT = {}
				fishT[1] = fish
				if fish:getChildByName("fish1") ~= nil then
					fishT[2] =  fish:getChildByName("fish1")
				end
				if fish:getChildByName("fish2") ~= nil then
					fishT[3] =  fish:getChildByName("fish2")
				end
				if fish:getChildByName("fish3") ~= nil then
					fishT[4] =  fish:getChildByName("fish3")
				end
				for i=1,#fishT do 
					setRedColor(fishT[i])
					if fishT[i]:getChildByName("di") ~= nil then
						setRedColor(fishT[i]:getChildByName("di"))
					end
				end
			else
				setRedColor(fish)
				if fish:getChildByName("di") ~= nil then
					setRedColor(fish:getChildByName("di"))
				end
			end
		end
	
		local net = cc.Sprite:create("game_res/im_net.png") 
		if self.m_Type == Type.Normal_Bullet or self.m_Type == Type.Special_Bullet  then
			net = cc.Sprite:create("game_res/im_net.png")
		elseif self.m_Type == Type.Bignet_Bullet then
			net = cc.Sprite:create("game_res/im_net_big.png")
		end


		local pos = cc.p(self:getPositionX(),self:getPositionY())
		pos = cc.pAdd(pos,offset)
		local catchPos = self._dataModule:convertCoordinateSystem(pos, 2, self._dataModule.m_reversal)
		net:setPosition(catchPos)

		local rect = net:getBoundingBox()
		rect.width = rect.width - 20 + bulletNum*10
		rect.height = rect.height - 20 + bulletNum*10

		--self:sendCatchMsg(fish)

	end
	self._dataModule:playEffect(g_var(cmd).casting)
end

function Bullet:sendCatchMsg(fish)
	--print("sendCatchMsg fish ",fish)
	if fish == nil then
		error("nil")
	end
	if fish.m_data == nil then
		fish = fish:getParent()
	end
	--print("id ",fish.m_data.fish_kind)
	if self.m_cannon.parent == nil then 
		return
	end
	local kind = fish.m_data.fish_kind
	local bkind = self.m_cannon.parent:getCurrentBulletKind(self.chairId)
	--击中李逵发送下
	if kind == g_var(cmd).FishKind.FISH_KIND_21 and self.gameLayer.max_bullet_multiple_ == self.m_cannon:getMultiple() then 
		local cmddata = ExternalFun.create_netdata(g_var(cmd).C_HitFishLK) --计算包长度
		cmddata:setcmdinfo(yl.MDM_GF_GAME, g_var(cmd).SUB_C_HIT_FISH_I)
		cmddata:pushword(self.chairId) --玩家ID
		cmddata:pushword(0) --玩家ID
		cmddata:pushint(fish.m_data.fish_id) --鱼ID
		cmddata:pushint(bkind)
		cmddata:pushint(self.m_cannon:getMultiple())

		if not self._gameFrame:sendSocketData(cmddata) then
			self._gameFrame._callBack(-1,"hit_lkfish")
		end
	end

	if kind == g_var(cmd).FishKind.FISH_KIND_23 or kind == g_var(cmd).FishKind.FISH_KIND_24 or (kind >= g_var(cmd).FishKind.FISH_KIND_31 and kind <= g_var(cmd).FishKind.FISH_KIND_40) then
		--扫描鱼信息
		self:catchSweepFish(fish)
		return
	end
	-- local bulletNum = self:getBulletNum()
	
	--别的鱼
	local cmddata = ExternalFun.create_netdata(g_var(cmd).C_CatchFish) --计算包长度
	cmddata:setcmdinfo(yl.MDM_GF_GAME, g_var(cmd).SUB_C_CATCH_FISH)

	cmddata:pushword(self.chairId) --玩家ID
	cmddata:pushword(0) --玩家ID
	cmddata:pushint(fish.m_data.fish_id) --鱼ID
	cmddata:pushint(bkind)  --子弹种类
	cmddata:pushint(0) --子弹ID
	cmddata:pushint(0) --客户端子弹ID
	cmddata:pushint(self.m_cannon:getMultiple()) --倍数

	if nil ==  self._gameFrame or nil == self._gameFrame.sendSocketData then
    	return
    end
    -- --print("发送捕鱼消息")
    --发送失败
	if not self._gameFrame:sendSocketData(cmddata) then
		self._gameFrame._callBack(-1,"zzz")
	end
end

--扫描鱼
function Bullet:catchSweepFish( fish )
	local kind = fish.m_data.fish_kind
	-- local bulletNum = self:getBulletNum()
	local bkind = self.m_cannon.parent:getCurrentBulletKind(self.chairId)
	local tmp = {}
	local cmddata = ExternalFun.create_netdata(g_var(cmd).C_CatchSweepFish) --计算包长度
	cmddata:setcmdinfo(yl.MDM_GF_GAME, g_var(cmd).SUB_C_CATCH_SWEEP_FISH)

	cmddata:pushword(self.chairId) --玩家ID
	cmddata:pushword(0) --子弹ID
	cmddata:pushint(0) --子弹ID
	cmddata:pushint(0)
	cmddata:pushint(bkind)
	cmddata:pushint(self.m_cannon:getMultiple()) 
	cmddata:pushint(fish.m_data.fish_id) --鱼ID
	local count = 1
	if kind == g_var(cmd).FishKind.FISH_KIND_23 then --局部炸弹
		local w, h = self.gameLayer.bomb_range_width, self.gameLayer.bomb_range_width
		--print("炸弹范围是----  ",w, h)
		local rect = fish:getBoundingBox()
		rect.width = w
		rect.height= h
		-- rect.x = rect.x-w/2
		-- rect.y = rect.y-h/2
		--draw
		-- local drawNode = cc.DrawNode:create()
		-- --print("pos ",rect.x, rect.y, rect.width, rect.height)

	 --    drawNode:drawLine( cc.p(rect.x, rect.y), cc.p(rect.x+rect.width, rect.y), cc.c4f(1,1,1,1))--下边线
	 --    drawNode:drawLine( cc.p(rect.x, rect.y), cc.p(rect.x, rect.y+rect.height), cc.c4f(1,1,1,1))--左边线
	 --    drawNode:drawLine( cc.p(rect.x, rect.y+rect.height), cc.p(rect.x+rect.width, rect.y+rect.height), cc.c4f(1,1,1,1))--上边线
	 --    drawNode:drawLine( cc.p(rect.x+rect.width, rect.y), cc.p(rect.x+rect.width, rect.y+rect.height), cc.c4f(1,1,1,1)) --右边线

	    -- drawNode:drawRect(cc.p(rect.x,rect.y), cc.p(rect.x+rect.width,rect.y+rect.height), cc.c4f(1,1,0,1))
	    -- self.m_cannon.parent.parent._gameView:addChild(drawNode, 20)

		for k,v in pairs(self._dataModule.m_fishList) do
			local _fish = v
			if _fish.m_data.fish_kind ~= g_var(cmd).FishKind.FISH_KIND_24 then --局部炸弹炸不死全屏炸弹
				local _rect = _fish:getBoundingBox()
				_rect.w, _rect.h = 1,1
				local bIntersect = cc.rectIntersectsRect(rect,_rect) --炸弹范围内
				if bIntersect then
					tmp[count] = _fish
					
					count = count + 1
					if count > g_var(cmd).MAX_FISH_COUNT then --最多300个鱼
						break
					end
				end
			end
		end
	elseif kind == g_var(cmd).FishKind.FISH_KIND_24 then --全局炸弹
		for k,v in pairs(self._dataModule.m_fishList) do --寻找网内的鱼
			local _fish = v
			local _rect = _fish:getBoundingBox()
			local rect  = cc.rect(0,0,yl.WIDTH,yl.HEIGHT)
			local bIntersect = cc.rectIntersectsRect(rect,_rect)
			if bIntersect then
				tmp[count] = _fish
					
				count = count + 1
				if count > g_var(cmd).MAX_FISH_COUNT then --最多300个鱼
					break
				end
			end
		end
	elseif kind >= g_var(cmd).FishKind.FISH_KIND_31 and kind <= g_var(cmd).FishKind.FISH_KIND_40 then --鱼王
		local fkind = kind - g_var(cmd).FishKind.FISH_KIND_31

		for k,v in pairs(self._dataModule.m_fishList) do
			if v.m_data.fish_kind == fkind then --同类型的鱼
				local _rect = fish:getBoundingBox()
				local rect  = cc.rect(0,0,yl.WIDTH,yl.HEIGHT)
				local bIntersect = cc.rectIntersectsRect(rect,_rect)
				if bIntersect then
					tmp[count] = _fish
						
					count = count + 1
					if count > g_var(cmd).MAX_FISH_COUNT then --最多300个鱼
						break
					end
				end
			end
		end
	end
	--print("扫描鱼数量",count)
	cmddata:pushint(count) --鱼数量
	for k,v in pairs(tmp) do 
		cmddata:pushint(v.m_data.fish_id)
		--print("扫描鱼ID ", v.m_data.fish_id,self._dataModule.m_fishList[v.m_data.fish_id])
	end
	-- for k,v in pairs(self._dataModule.m_fishList) do
		-- --print("本地鱼ID ",v.m_data.fish_id)
	-- end
	for i=#tmp+1 ,g_var(cmd).MAX_FISH_COUNT do 
		cmddata:pushint(0)
	end
	if nil ==  self._gameFrame or nil == self._gameFrame.sendSocketData then
    	return
    end
    -- --print("发送捕鱼(扫描)消息")

    --发送失败
	if not self._gameFrame:sendSocketData(cmddata) then
		self._gameFrame._callBack(-1,"zzzz")
	end
end

--发送捕获消息
function Bullet:sendCathcFish( rect )
	local tmp = {}

	for k,v in pairs(self._dataModule.m_fishList) do --寻找网内的鱼
		local fish = v
		local pos = fish:getPosition()
		local _rect = fish:getBoundingBox()

		local bIntersect = cc.rectIntersectsRect(rect,_rect)
		if bIntersect then
			table.insert(tmp, fish)
		end

	end

	local count = 0 --网中符合条件的鱼的个数
	local catchList = {}
	local isBigFish = true
	local bigFishList = {}

	--筛选大鱼
	local bigIndex = {}
	for i=1,#tmp do
		local fish = tmp[i]
		if fish.fishCreateData.nFishState ~= g_var(cmd).FishState.FishState_Normal then
			table.insert(bigFishList,fish)
			table.insert(bigIndex,i)
		end
	end

	for i=1,#bigIndex do
		table.remove(tmp,bigIndex[i])
	end

	bigIndex = {}

	--把大鱼插入队列的前端
	if 0 ~= #bigFishList then
		for i=1,#bigFishList do
			local fish = bigFishList[i]
			table.insert(tmp, 1,fish)
		end
	end
	
	bigFishList = nil

	--取出前5条鱼
	if #tmp > 5 then
		count = 5
	else
		count = #tmp
	end

	for i=1,count do
		local fish = tmp[i]
		table.insert(catchList,fish)
	end

--发送消息包
	local request = {0,0,0,0,0}

	for i=1,#catchList do
		local fish = catchList[i]
		request[i] = fish.m_data.nFishKey
	end

	local cmddata = CCmd_Data:create(24)
   	cmddata:setcmdinfo(yl.MDM_GF_GAME, g_var(cmd).SUB_C_CATCH_FISH);
    cmddata:pushint(self.m_index)
    for i=1,5 do
    	cmddata:pushint(request[i])
    end

     if nil ==  self._gameFrame or nil == self._gameFrame.sendSocketData then
    	return
    end

    --发送失败
	if not self._gameFrame:sendSocketData(cmddata) then
		self._gameFrame._callBack(-1,"")
	end
end

return Bullet