--
-- Author: Tang
-- Date: 2016-08-09 10:27:07
--炮
local Cannon = class("Cannon", cc.Sprite)
local module_pre = "game.yule.lkpy.src"
local ExternalFun = require(appdf.EXTERNAL_SRC.."ExternalFun")
local cmd = module_pre..".models.CMD_LKGame"
local Bullet = require(module_pre..".views.layer.Bullet")
local QueryDialog = appdf.req("base.src.app.views.layer.other.QueryDialog")
local g_var = ExternalFun.req_var
local scheduler = cc.Director:getInstance():getScheduler()
local TimestampManager 		= appdf.req(module_pre .. ".models.TimestampManager")


Cannon.Tag =
{

	Tag_Award = 10,
	Tag_Light = 20,
	Tag_Type  = 30,
	Tag_lock  = 3000

}

local TagEnum = Cannon.Tag

function Cannon:ctor(viewParent)
	cc.SpriteFrameCache:getInstance():addSpriteFrames("game_res/gunbullet.plist","game_res/gunbullet.png")

	self.m_pos = 2    --炮台位置
	self.canFindAngle = true
	self.m_fort = nil
	self.m_nickName = nil
	self.m_score = nil
	self.m_multiple = nil
	self.m_isShoot = false
	self.m_canShoot = true
	self.m_autoShoot = false
	self.m_typeTime = 0
	self.orignalAngle = 0
	self.m_fishIndex = g_var(cmd).INT_MAX
	self.m_index  = 0 --子弹索引
	self.m_ChairID  = yl.INVALID_CHAIR
	self.m_autoShootSchedule = nil
	self.m_otherShootSchedule = nil
	self.m_typeSchedule = nil

	self.m_targetPoint = cc.p(0,0)
	self.m_cannonPoint = cc.p(0,0)
	self.m_firelist = {}

	self.m_nCurrentBulletScore = 1
	self.m_nMutipleIndex = 0

	self.m_Type = g_var(cmd).CannonType.Normal_Cannon --当前发射类型
	self.parent = viewParent

	self._dataModel = self.parent._dataModel
	self._gameView  = self.parent._gameView
	-- --print("woicao22 -----------------  ",self._dataModel)
	self.frameEngine = self.parent._gameFrame

	self.m_laserPos = cc.p(0,0)

	self.m_laserConvertPos = cc.p(0,0)

	self.m_laserBeginConvertPos = cc.p(0,0)

    --获取自己信息
	self.m_pUserItem = self.frameEngine:GetMeUserItem()
  	self.m_nTableID  = self.m_pUserItem.wTableID
  	self.m_nChairID  =  self.m_pUserItem.wChairID

    --其他玩家信息
  	self.m_pOtherUserItem = nil
  	--jetton num++
  	self.jettonNum = 0
  	self.jettonHaveNum = 0
  	self.canFire = true
  	self.canDel  = false
  	self.superBullet = false
  	self.jettonList = {}
  	--注册事件
    ExternalFun.registerTouchEvent(self,false)
end

function Cannon:initWithUser(userItem)

	self.m_ChairID = userItem.wChairID
	if self.m_ChairID ~= self.m_nChairID then
		self.m_pOtherUserItem = userItem
	end

	self:setContentSize(100,100)
	self:removeChildByTag(1000)
	self.m_fort = cc.Sprite:createWithSpriteFrameName("gun1_1.png")
	self.m_fort:setTag(1000)
	self.m_fort:setPosition(50,50)
	self:addChild(self.m_fort,1)
	self.m_pos = userItem.wChairID

	if self._dataModel.m_reversal then
		-- self.m_pos = 5 - self.m_pos
	end
	-- --print("fffffffffffffffffffffff  ",self.m_pos)
	if self.m_pos <= 2 then
		self.m_fort:setRotation(180)
	end
	-- if self.m_pos < 3 then
	-- 	self.m_fort:setRotation(180)
	-- elseif self.m_pos == 3 then
	-- 	self.m_fort:setRotation(-90)
	-- elseif self.m_pos == 7 then
	-- 	self.m_fort:setRotation(90)
	-- end
end
--是否是超级子弹
function Cannon:setSuperBullet(is)
	self.superBullet = is

	local bulletNum = 1 --默认两个炮管
	if self.m_nMutipleIndex >= 1000 and self.m_nMutipleIndex < 5000 then
		bulletNum = 2 --三个炮管
	elseif self.m_nMutipleIndex >= 5000 then
		bulletNum = 3 --四个炮管
	end

	local pic = string.format("gun1_%d.png", bulletNum )
	if self.superBullet == true then
		pic = string.format("gun2_%d.png", bulletNum )
	end
	self.m_fort:setSpriteFrame(pic)

	if is then
		local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("card_ion.png")
		if frame ~= nil then
			local sp = self:getChildByName("fuzi")
			if sp == nil then

				local pos = cc.p(160,145)

				if self.m_nChairID <= 2 then
					pos = cc.p(160,0)
				elseif self.m_nChairID == 3 then
					pos = cc.p(-40,-85)
				elseif self.m_nChairID == 7 then
					pos = cc.p(145,-50)
				end
				sp = cc.Sprite:createWithSpriteFrame(frame)
				self:removeChildByName("fuzi")
				sp:setName("fuzi")
				sp:setPosition(pos.x,pos.y)
				self:addChild(sp)
				sp:runAction(cc.RepeatForever:create(CirCleBy:create(1.0,cc.p(pos.x,pos.y),10)))
			else

			end
		end
	else
		self:removeChildByName("fuzi")
	end
end
--设置倍数
function Cannon:setMultiple(multiple)
    
	self.m_nMutipleIndex = multiple
	local bulletNum = 1 --默认两个炮管
	if multiple >= 1000 and multiple < 5000 then
		bulletNum = 2 --三个炮管
	elseif multiple >= 5000 then
		bulletNum = 3 --四个炮管
	end

	local pic = string.format("gun1_%d.png", bulletNum )
	if self.superBullet == true then
		pic = string.format("gun2_%d.png", bulletNum )
	end
	self.m_fort:setSpriteFrame(pic)
	self.parent:updateMultiple(multiple,self.m_pos+1)
end

--获取当前倍数
function Cannon:getMultiple()
	return self.m_nMutipleIndex
end

function Cannon:setFishIndex(index)
	self.m_fishIndex = index
end
--自己开火
function Cannon:shoot( vec , isbegin )

	if not self.m_canShoot then
		-- --print("1111111111111111111")
		self.m_isShoot = isbegin
		return
	end

	--print("2222222222222222222")
	if self.m_cannonPoint.x == 0 and self.m_cannonPoint.y == 0 then
		self.m_cannonPoint = self:convertToWorldSpace(cc.p(self.m_fort:getPositionX(),self.m_fort:getPositionY()))
		-- --print(" hehe ",self.m_cannonPoint.x, self.m_cannonPoint.y)
	end

	self.m_laserPos.x = vec.x
	self.m_laserPos.y = vec.y

	local angle = nil
	if self.m_pos < 3 then
		angle = self._dataModel:getAngleByTwoPoint(self.m_cannonPoint, vec, -90)
	else
		angle = self._dataModel:getAngleByTwoPoint(vec, self.m_cannonPoint, 90)
	end
	-- if self.m_pos < 3 then
	-- 	angle = self._dataModel:getAngleByTwoPoint(self.m_cannonPoint, vec, -90)
	-- elseif self.m_pos == 3 then
	-- 	angle = self._dataModel:getAngleByTwoPoint(self.m_cannonPoint, vec, -90)
	-- elseif self.m_pos == 7 then
	-- 	angle = self._dataModel:getAngleByTwoPoint(self.m_cannonPoint, vec, -90)
	-- else
	-- 	angle = self._dataModel:getAngleByTwoPoint(vec, self.m_cannonPoint, 90)
	-- end

	self.m_targetPoint = vec
	-- --print("gun angle ",angle)
	if angle < 90  then
		if not self._dataModel.m_autolock then
			-- --print("设置旋转角度")
			self.m_fort:setRotation(angle) --设置枪的旋转角度
		else
			-- --print("vec pos: ", vec.x, vec.y)
		end
	end

	if self.m_autoShoot~=nil and self.m_autoShoot then
		-- --print("-------------------m_autoShoot return------------------11")
		return
	end
	
	if not self.m_isShoot and isbegin then
		self.m_isShoot = true
		-- if self.canFire then
			local time = self._dataModel.m_secene.nBulletCoolingTime / 1000

			self:autoUpdate(0)
			self:autoSchedule(time)
		-- end
	end

	if not isbegin then
		self.m_isShoot = false
		self:unAutoSchedule()
	end

end

--制造子弹
function Cannon:productBullet( isSelf, fishIndex, netColor,chairid)

	self.m_index = self.m_index + 1
	local angle = self.m_fort:getRotation()
	local testAngle = angle
	self:setFishIndex(self._dataModel.m_fishIndex)
	-- --print("子弹“  ",self.m_ChairID)
	local bullet0 = Bullet:create(angle,chairid,self.m_nCurrentBulletScore,self.m_nMutipleIndex,self.m_Type,self)

	angle = math.rad(90-angle)
	local movedir = cc.pForAngle(angle)
	movedir = cc.p(movedir.x * 25 , movedir.y * 25)
	local offset = cc.p(25 * math.sin(angle),5 * math.cos(angle))
	local moveBy = cc.MoveBy:create(0.065,cc.p(-movedir.x*0.65,-movedir.y * 0.65))
	self.m_fort:runAction(cc.Sequence:create(moveBy,moveBy:reverse()))

	bullet0:setType(self.m_Type)
	bullet0:setIndex(self.m_index)
	if isSelf == 1 or isSelf == 2 then 
		bullet0:setIsSelf(true)
	else
		bullet0:setIsSelf(false)
	end
	bullet0:setFishIndex(fishIndex)
	bullet0:initPhysicsBody()
	bullet0:setTag(g_var(cmd).Tag_Bullet)
	local pos = cc.p(self.m_cannonPoint.x+movedir.x,self.m_cannonPoint.y+movedir.y)
	pos = cc.p(pos.x , pos.y - offset.y/2)
	bullet0:setPosition(pos)
	self.parent.parent._gameView:addChild(bullet0,5) --self.parent.parent为GameLayer

	if isSelf == 1 then
		self.canFindAngle = false
		self.parent.parent:setSecondCount(120)

		local cmddata = ExternalFun.create_netdata(g_var(cmd).C_UserFire) --计算包长度
   		cmddata:setcmdinfo(yl.MDM_GF_GAME, g_var(cmd).SUB_C_FIRE	)

   		local bkind = self.parent:getCurrentBulletKind(self.m_ChairID)
   		-- local bulletNum = bullet0:getBulletNum()


   		if testAngle < 90 then
   			testAngle = testAngle+360
   		end
		
		  -- testAngle =    testAngle * 180 / g_var(cmd).M_PI ;
		--自己撸一个角度

	local pt_offest = {x = self.m_laserPos.x,y = 720 - self.m_laserPos.y}
	local rorate = 0.0

	local sb 
	if self.m_nChairID+1 == 1 then
		sb = 6
	elseif self.m_nChairID+1 == 2 then
		sb = 5
	elseif self.m_nChairID+1 == 3 then
		sb = 4
	elseif self.m_nChairID+1 == 4 then
		sb = 3
	elseif self.m_nChairID+1 == 5 then
		sb = 2
	elseif self.m_nChairID+1 == 6 then
		sb = 1
	end
	local pt_how = self.parent.m_pCannonPos[sb]
	local pt_rorate = {x = 0,y =0}
	local M_PI   = 3.14159265358979323846
	local M_PI_2 = 1.57079632679489661923
	if self.m_nChairID  == 1 or self.m_nChairID  == 2 or self.m_nChairID  ==0 then
		pt_rorate.x = pt_offest.x - pt_how.x 
		pt_rorate.y = pt_offest.y - pt_how.y
		if pt_rorate.y >= 0 then
			rorate = math.atan2(pt_rorate.y, pt_rorate.x) + M_PI_2
		else
			if pt_rorate.x >= 0 then
				rorate = M_PI_2
			else 
				rorate = M_PI_2 + M_PI
			end
		end
	elseif self.m_nChairID  == 3 or self.m_nChairID  == 4 or self.m_nChairID  == 5 then
		pt_rorate.x = pt_offest.x - pt_how.x 
		pt_rorate.y = pt_offest.y - pt_how.y
		if pt_rorate.y <= 0 then
			rorate = math.atan2(pt_rorate.y, pt_rorate.x) + M_PI_2
		else
			if pt_rorate.x >= 0 then
				rorate = M_PI_2
			else 
				rorate = M_PI_2 + M_PI
			end
		end
	end
	--rorate =  rorate* 180 / M_PI;
	-- dump(pt_offest,"便宜啊")
	-- print(math.rad(testAngle))
	-- dump(rorate,"rorate")
	-- print(TimestampManager:get_server_tick())
		--cmddata:pushfloat(math.rad(testAngle)) --角
		cmddata:pushfloat(rorate)	
		cmddata:pushint(TimestampManager:get_server_tick())
		cmddata:pushfloat(500)
		cmddata:pushint(self:getMultiple()) --子弹倍数
		cmddata:pushint(fishIndex) --锁鱼ID
		cmddata:pushword(1) --子弹类
		   
   		--cmddata:pushint(0) --客户端子弹ID

   		self._dataModel:playEffect(g_var(cmd).fire)
   		 --发送失败

		if  self.frameEngine~=nil and not self.frameEngine:sendSocketData(cmddata) then
			if self.frameEngine~=nil then
				self.frameEngine._callBack(-1,"发送开火息失败")
			end
		end
	end
end
--自己开火
function Cannon:autoUpdate(dt)

	if self._dataModel._exchangeSceneing then 	--切换场景中不能发炮
		return
	end
	--限制子弹个数
	--print("开火..."..self._dataModel.m_bulletCount)
	if self._dataModel.m_bulletCount >= self._dataModel.m_bulletCountMax then
		return;
	end
	self._dataModel.m_bulletCount = self._dataModel.m_bulletCount + 1

	self:setFishIndex(self._dataModel.m_fishIndex)

	local mutiple = self:getMultiple() --当前倍数
	local score = self.parent:getFishGold(self.m_ChairID+1)
	print("score ",score, mutiple,self.m_ChairID)
	if score < mutiple then
		self:unAutoSchedule()
		self.m_autoShoot = false
    	--更改状态
    	-- --print("self._dataModel.m_autoShoot ",self._dataModel,self._dataModel.m_autolock ,self._dataModel.m_autoshoot)
    	if self._dataModel.m_autoshoot then
    		-- --print("更改状态::::::::::::::::::::::false")
    		self._dataModel.m_autoshoot = false
    		self._gameView:setAutoByScore(false)
    	end
    	--
		if nil == self._queryDialog then
      		local this = self
	    	self._queryDialog = QueryDialog:create("游戏币不足,请充值或者上分！", function(ok)
	        this._queryDialog = nil
	    	end):setCanTouchOutside(false)
	        :addTo(cc.Director:getInstance():getRunningScene())
    	end
    	--]]
    	return
	end

	if self.m_autoShoot or self._dataModel.m_autolock then

		-- if self.m_fishIndex == g_var(cmd).INT_MAX then
		-- 	--print("-------------- self.m_fishIndex == g_var(cmd).INT_MAX  return----------")
		-- 	 self:removeLockTag()
		-- 	 return
		-- end

		local fish = self._dataModel.m_fishList[self.m_fishIndex]
		-- -- if self._dataModel.m_autolock then
		-- 	if fish == nil then
		-- 		self:removeLockTag()
		-- 	    return
		-- 	end
		local index = self.m_fishIndex
		if fish ~= nil then
			local pos = cc.p(fish:getPositionX(),fish:getPositionY())
			local angle = nil

			if self.m_pos < 3 then
				angle = self._dataModel:getAngleByTwoPoint(self.m_cannonPoint, pos,-90)

			else
				angle = self._dataModel:getAngleByTwoPoint(pos, self.m_cannonPoint, 90)
			end
			-- if self.m_pos < 3 then
			-- 	angle = self._dataModel:getAngleByTwoPoint(self.m_cannonPoint, pos,-90)
			-- elseif self.m_pos == 3 then
			-- 	angle = self._dataModel:getAngleByTwoPoint(self.m_cannonPoint, pos, -90)
			-- elseif self.m_pos == 7 then
			-- 	angle = self._dataModel:getAngleByTwoPoint(self.m_cannonPoint, pos, -90)
			-- else
			-- 	angle = self._dataModel:getAngleByTwoPoint(pos, self.m_cannonPoint, 90)
			-- end

			if angle < 90  then
				self.m_fort:setRotation(angle) --设置枪的旋转角度
			end
		else
			index = g_var(cmd).INT_MAX
		end
		self:productBullet(1,index,self._dataModel:getNetColor(1),self.m_nChairID)
	else
		self:productBullet(1,g_var(cmd).INT_MAX,self._dataModel:getNetColor(1),self.m_nChairID)
	end
end
--根据锁鱼设定角度
function Cannon:unDelLockEntry()
	if self.autoLockFindAngle ~= nil then
		scheduler:unscheduleScriptEntry(self.autoLockFindAngle)
		self.autoLockFindAngle = nil
	end
	self:removeLockTag()
	if self.parent:getChildByName("line") then
		self.parent:getChildByName("line"):removeFromParent()
	end
	local fish = self._dataModel.m_fishList[self._dataModel.m_fishIndex]
	if fish ~= nil then
		if fish:getChildByName("last") then
			fish:getChildByName("last"):removeFromParent()
		end
	end
end
function Cannon:setLockAngle(fishid)
	if fishid == g_var(cmd).INT_MAX then
		self:unDelLockEntry()
		-- self:removeLockTag()
		-- if self.parent:getChildByName("line") then
		-- 	self.parent:getChildByName("line"):removeFromParent()
		-- end
	end
	if self.autoLockFindAngle ~= nil then
		scheduler:unscheduleScriptEntry(self.autoLockFindAngle)
		self.autoLockFindAngle = nil
	end
	if self._dataModel.m_fishList[fishid] ~= nil then
		local fish = self._dataModel.m_fishList[fishid]
		self.canFindAngle = true
		local POST = cc.p(0,0)
		local fishData = fish.m_data
		--锁鱼图标在炮台周围转圈 位置后边调整吧
		local frameName = string.format("fish_lock%d.png", fishData.fish_kind)
		-- local frameName = string.format("%d_%d.png", 10, 1)
		local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)
		if nil ~= frame then
			local sp = self:getChildByTag(TagEnum.Tag_lock)
			if nil == sp then
				local myNum     = self.m_nChairID/3
				local playerNum = self.m_ChairID/3

				local pos = cc.p(40,-60)

				if self.m_nChairID > 2 then
					pos = cc.p(40,145)
				
				end

				-- if self.m_nChairID <= 2 then
				-- 	pos = cc.p(-40,0)
				-- elseif self.m_nChairID == 7 then
				-- 	pos = cc.p(145,90)
				-- else
				-- end
				sp = cc.Sprite:createWithSpriteFrame(frame)
				self:removeLockTag()
				sp:setTag(TagEnum.Tag_lock)
				sp:setPosition(pos.x,pos.y)
				self:addChild(sp)
				sp:runAction(cc.RepeatForever:create(CirCleBy:create(1.0,cc.p(pos.x,pos.y),10)))
			else
				sp:setSpriteFrame(frame)
			end 
		else
			self:removeLockTag()
		end

		local function setRangle( id )
			if self.m_cannonPoint.x == 0 and self.m_cannonPoint.y == 0 then
				self.m_cannonPoint = self:convertToWorldSpace(cc.p(self.m_fort:getPositionX(),self.m_fort:getPositionY()))
			end
			local fish = self._dataModel.m_fishList[id]
			local pos = cc.p(fish:getPositionX(),fish:getPositionY())
			local angle = nil

			if self.m_pos < 3 then
				angle = self._dataModel:getAngleByTwoPoint(self.m_cannonPoint, pos,-90)
			else
				angle = self._dataModel:getAngleByTwoPoint(pos, self.m_cannonPoint, 90)
			end
			-- if self.m_pos < 3 then
			-- 	angle = self._dataModel:getAngleByTwoPoint(self.m_cannonPoint, pos,-90)
			-- elseif self.m_pos == 3 then
			-- 	angle = self._dataModel:getAngleByTwoPoint(self.m_cannonPoint, pos, -90)
			-- elseif self.m_pos == 7 then
			-- 	angle = self._dataModel:getAngleByTwoPoint(self.m_cannonPoint, pos, -90)
			-- else
			-- 	angle = self._dataModel:getAngleByTwoPoint(pos, self.m_cannonPoint, 90)
			-- end
			if angle < 90  then
				self.m_fort:setRotation(angle) --设置枪的旋转角度
			end
		end
		local tx, ty = 0,0
		local function setLastFishPao()
			if fish:getChildByName("last") == nil then
				local sp = cc.Sprite:create()
				sp:initWithSpriteFrameName("lock_flag_"..(self.m_ChairID+1)..".png")
				sp:setName("last")
				fish:addChild(sp)
				--local point = fish:convertToNodeSpace(cc.p(tx, ty))
				sp:setPosition(cc.p(fish:getContentSize().width/2,fish:getContentSize().height/2))
			end
		end
		local function updateAuto(dt)
			if self._dataModel.m_fishList[fishid] == nil then
				self:unDelLockEntry()
				return
			end
			if self.m_cannonPoint.x == 0 and self.m_cannonPoint.y == 0 then
				self.m_cannonPoint = self:convertToWorldSpace(cc.p(self.m_fort:getPositionX(),self.m_fort:getPositionY()))
			end
			if self.canFindAngle == true then
				setRangle(fishid)
			end

			if self.parent:getChildByName("line") then
				self.parent:getChildByName("line"):removeFromParent()
			end
			local node = cc.Node:create()
			node:setAnchorPoint(cc.p(0, 0))
			node:setName("line")
			self.parent:addChild(node)
			local wid = 50
			local num = cc.pGetDistance( cc.p( fish:getPositionX(), fish:getPositionY() ) , cc.p( self.m_cannonPoint.x, self.m_cannonPoint.y ) ) / wid
			num = math.floor(num)
			POST.x, POST.y = self.m_cannonPoint.x, self.m_cannonPoint.y
			for i=1, num do
				local posX, posY = fish:getPositionX() - POST.x, fish:getPositionY() - POST.y
				local lize = cc.pNormalize(cc.p(posX, posY))

				local _posX = POST.x + lize.x * wid
				local _posY = POST.y + lize.y * wid
				POST.x, POST.y = _posX, _posY
				if i == num then
					tx, ty = _posX, _posY
					-- sp:initWithSpriteFrameName("lock_flag_"..(self.m_ChairID+1)..".png")
					setLastFishPao()
				else
					local sp = cc.Sprite:create()
					node:addChild(sp)
					sp:initWithSpriteFrameName("lock_line.png")
					sp:setPosition(cc.p(_posX, _posY))
				end

			end
		end

		if nil == self.autoLockFindAngle then
			self.autoLockFindAngle = scheduler:scheduleScriptFunc(updateAuto, 0, false)
		end

	end
end
function Cannon:autoSchedule(dt)
	local delTime = 0
	local function updateAuto(dt)
		if self~=nil and self.autoUpdate~=nil then 
		 self:autoUpdate(dt)
		end
	end

	if nil == self.m_autoShootSchedule then
		self.m_autoShootSchedule = scheduler:scheduleScriptFunc(updateAuto, dt, false)
	end
end

function Cannon:unAutoSchedule(_type)
	if nil ~= self.m_autoShootSchedule then
		scheduler:unscheduleScriptEntry(self.m_autoShootSchedule)
		self.m_autoShootSchedule = nil
	end
end
--其他玩家开火
function Cannon:othershoot( firedata )

	table.insert(self.m_firelist,firedata)
	local time = self._dataModel.m_secene.nBulletCoolingTime/1000

	self:otherSchedule(time)
end
function Cannon:otherSchedule(dt)

	local function updateOther(dt)
		if self~=nil and self.otherUpdate~=nil then 
			self:otherUpdate(dt)
		end
	end
	-- --print("其他玩家发射子弹咯 ",self.m_otherShootSchedule, dt)
	if nil == self.m_otherShootSchedule then
		self.m_otherShootSchedule = scheduler:scheduleScriptFunc(updateOther, dt, false)
	end

end

function Cannon:unOtherSchedule()
	if nil ~= self.m_otherShootSchedule then
		scheduler:unscheduleScriptEntry(self.m_otherShootSchedule)
		self.m_otherShootSchedule = nil
	end
end
--其他玩家开火
function Cannon:otherUpdate(dt)

	if 0 == #self.m_firelist then
		self:unOtherSchedule()
		self.m_isShoot = false
		--print("eeeeeeeeeeend---------------")
		return
	end

	-- if not self._dataModel._bFishInView then
	-- 	return
	-- end

	----print("the num is ............................."..table.nums(self._dataModel.m_InViewTag))
	----dump(self._dataModel.m_InViewTag, "the in view tag is ====================== >", 6)
	-- if 0 == table.nums(self._dataModel.m_InViewTag) then
		----print("the view is not fish")
		-- return
	-- end

	local fire = self.m_firelist[1]
	table.remove(self.m_firelist,1)

	-- local pos = cc.p(fire.ptPos.x,fire.ptPos.y)
	local fireAngle = fire.rotation_
	local pos = cc.p(500, 500)
	-- pos = self._dataModel:convertCoordinateSystem(pos, 1, self._dataModel.m_reversal)

	if self.m_cannonPoint.x == 0 and self.m_cannonPoint.y == 0 then
		self.m_cannonPoint = self:convertToWorldSpace(cc.p(self.m_fort:getPositionX(),self.m_fort:getPositionY()))
	end
	--local angle = self._dataModel:getAngleByTwoPoint(pos, self.m_cannonPoint)
	local _angle = math.deg(fireAngle)
	--print("=-=======================   ",fireAngle,_angle)
	self.m_fort:setRotation(_angle)
	--print("其他玩家发射了。。===",fire.android_chairid,self.m_nChairID)
	--if fire.android_chairid == self.m_nChairID then
		--self:productBullet(2, fire.lock_bird_id_, cc.WHITE,fire.chair_id_)
	--else
		self:productBullet(0, fire.lock_bird_id_, cc.WHITE,self.m_nChairID)
	--end

	--更新分数
	-- self._dataModel.m_secene.lPalyCurScore[1][self.m_pOtherUserItem.wChairID+1] = self._dataModel.m_secene.lPalyCurScore[1][self.m_pOtherUserItem.wChairID+1] - fire.nBulletScore
	----print("==============lPalyCurScore ===============",self.m_pOtherUserItem.wChairID,self._dataModel.m_secene.lPalyCurScore[1][self.m_pOtherUserItem.wChairID+1])
	-- self:updateScore(self._dataModel.m_secene.lPalyCurScore[1][self.m_pOtherUserItem.wChairID+1])
end
--自动射击
function Cannon:setAutoShoot( b )

	self.m_autoShoot = b
	if self.m_cannonPoint.x == 0 and self.m_cannonPoint.y == 0 then
		self.m_cannonPoint = self:convertToWorldSpace(cc.p(self.m_fort:getPositionX(),self.m_fort:getPositionY()))
	end

	if self.m_autoShoot then

		local time =  self._dataModel.m_secene.nBulletCoolingTime/1000
		--print("开启自动射击")
		self:autoSchedule(time)

	else
		--print("取消自动射击")
		self:unAutoSchedule()
	end
end

function Cannon:unTypeSchedule()
	if nil ~= self.m_typeSchedule then
		if self:getChildByTag(TagEnum.Tag_Light) then
			self:removeChildByTag(TagEnum.Tag_Light)
		end
		scheduler:unscheduleScriptEntry(self.m_typeSchedule)
		self.m_typeSchedule = nil
	end
end


function Cannon:removeLockTag()
	if self:getChildByTag(TagEnum.Tag_lock) then
		self:removeChildByTag(TagEnum.Tag_lock)
	end
end


function Cannon:removeTypeTag()
	if self:getChildByTag(TagEnum.Tag_Type) then
		self:removeChildByTag(TagEnum.Tag_Type)
	end
end

function Cannon:getKindNum(beishu)
    local kind = 2 --默认两个炮管
    if beishu >= 1000 and beishu < 5000 then
        kind = 3 --三个炮管
    elseif beishu >= 5000 then
        kind = 4 --四个炮管
    end
    kind = kind - 1

    return kind
end

function Cannon:addPao()
	local current_bullet_kind_ = self.parent:getCurrentBulletKind(self.m_pos)
	if current_bullet_kind_ >= 4 then
		return
	end
	local glayer = self.parent.parent
	local max = glayer.max_bullet_multiple_
	local min = glayer.min_bullet_multiple_

	if self.m_nMutipleIndex == max then
		self.m_nMutipleIndex = min
	elseif self.m_nMutipleIndex < 10 then
		self.m_nMutipleIndex = self.m_nMutipleIndex + 1
		if self.m_nMutipleIndex > max then
			self.m_nMutipleIndex = max
		end
	elseif self.m_nMutipleIndex >= 10 and self.m_nMutipleIndex < 100 then
		self.m_nMutipleIndex = self.m_nMutipleIndex + 10
		if self.m_nMutipleIndex > max then
			self.m_nMutipleIndex = max
		end
	elseif self.m_nMutipleIndex >= 100 and self.m_nMutipleIndex < 1000 then
		self.m_nMutipleIndex = self.m_nMutipleIndex + 100
		if self.m_nMutipleIndex > max then
			self.m_nMutipleIndex = max
		end
	elseif self.m_nMutipleIndex >= 1000 and self.m_nMutipleIndex < 10000 then
		self.m_nMutipleIndex = self.m_nMutipleIndex + 1000
		if self.m_nMutipleIndex > max then
			self.m_nMutipleIndex = max
		end
	elseif self.m_nMutipleIndex >= 10000 and self.m_nMutipleIndex < 100000 then
		self.m_nMutipleIndex = self.m_nMutipleIndex + 10000
		if self.m_nMutipleIndex > max then
			self.m_nMutipleIndex = max
		end
	elseif self.m_nMutipleIndex >= 100000 and self.m_nMutipleIndex < 1000000 then
		self.m_nMutipleIndex = self.m_nMutipleIndex + 100000
		if self.m_nMutipleIndex > max then
			self.m_nMutipleIndex = max
		end
	elseif self.m_nMutipleIndex >= 1000000 and self.m_nMutipleIndex < 10000000 then
		self.m_nMutipleIndex = self.m_nMutipleIndex + 1000000
		if self.m_nMutipleIndex > max then
			self.m_nMutipleIndex = max
		end
	else
		self.m_nMutipleIndex = self.m_nMutipleIndex + 10000000
		if self.m_nMutipleIndex > max then
			self.m_nMutipleIndex = max
		end
	end

	if self.m_nMutipleIndex < 100 then
		current_bullet_kind_ = (current_bullet_kind_ / 4 )* 4
	elseif self.m_nMutipleIndex >= 100 and self.m_nMutipleIndex < 1000 then
		current_bullet_kind_ = (current_bullet_kind_ / 4 )* 4 + 1
	elseif self.m_nMutipleIndex >= 1000 and self.m_nMutipleIndex < 5000 then
		current_bullet_kind_ = (current_bullet_kind_ / 4 )* 4 + 2
	else
		current_bullet_kind_ = (current_bullet_kind_ / 4 )* 4 + 3
	end
	local kind = self:getKindNum(self.m_nMutipleIndex)
	self.parent:switch(self.m_pos, kind)
	self.parent:setCannonMulriple(self.m_pos, self.m_nMutipleIndex)
	self:setMultiple(self.m_nMutipleIndex)

	self._dataModel:playEffect(g_var(cmd).cannonSwitch)
end

function Cannon:cutPao()
	local current_bullet_kind_ = self.parent:getCurrentBulletKind(self.m_pos)
	if current_bullet_kind_ >= 4 then
		return
	end
	local glayer = self.parent.parent
	local max = glayer.max_bullet_multiple_
	local min = glayer.min_bullet_multiple_

	if self.m_nMutipleIndex == min then
		self.m_nMutipleIndex = max
	elseif self.m_nMutipleIndex <= 10 then
		self.m_nMutipleIndex = self.m_nMutipleIndex - 1
		if self.m_nMutipleIndex < min then
			self.m_nMutipleIndex = min
		end
	elseif self.m_nMutipleIndex >= 10 and self.m_nMutipleIndex < 100 then
		self.m_nMutipleIndex = self.m_nMutipleIndex - 10
		if self.m_nMutipleIndex < min then
			self.m_nMutipleIndex = min
		end
	elseif self.m_nMutipleIndex >= 100 and self.m_nMutipleIndex < 1000 then
		self.m_nMutipleIndex = self.m_nMutipleIndex - 100
		if self.m_nMutipleIndex < min then
			self.m_nMutipleIndex = min
		end
	elseif self.m_nMutipleIndex >= 1000 and self.m_nMutipleIndex <= 9000 then
		self.m_nMutipleIndex = self.m_nMutipleIndex - 1000
		if self.m_nMutipleIndex < min then
			self.m_nMutipleIndex = min
		end
	elseif self.m_nMutipleIndex >9000 and self.m_nMutipleIndex <= 10000 then
		self.m_nMutipleIndex = self.m_nMutipleIndex - 900
		if self.m_nMutipleIndex < min then
			self.m_nMutipleIndex = min
		end
	elseif self.m_nMutipleIndex > 10000 and self.m_nMutipleIndex < 100000 then
		self.m_nMutipleIndex = self.m_nMutipleIndex - 10000
		if self.m_nMutipleIndex < min then
			self.m_nMutipleIndex = min
		end
	elseif self.m_nMutipleIndex >= 100000 and self.m_nMutipleIndex < 1000000 then
		self.m_nMutipleIndex = self.m_nMutipleIndex - 100000
		if self.m_nMutipleIndex < min then
			self.m_nMutipleIndex = min
		end
	elseif self.m_nMutipleIndex >= 1000000 and self.m_nMutipleIndex < 10000000 then
		self.m_nMutipleIndex = self.m_nMutipleIndex - 1000000
		if self.m_nMutipleIndex < min then
			self.m_nMutipleIndex = min
		end
	else
		self.m_nMutipleIndex = self.m_nMutipleIndex - 10000000
		if self.m_nMutipleIndex < min then
			self.m_nMutipleIndex = min
		end
	end

	local current_bullet_kind_ = self.parent:getCurrentBulletKind(self.m_pos)
	if self.m_nMutipleIndex < 100 then
		current_bullet_kind_ = (current_bullet_kind_ / 4 )* 4
	elseif self.m_nMutipleIndex >= 100 and self.m_nMutipleIndex < 1000 then
		current_bullet_kind_ = (current_bullet_kind_ / 4 )* 4 + 1
	elseif self.m_nMutipleIndex >= 1000 and self.m_nMutipleIndex < 5000 then
		current_bullet_kind_ = (current_bullet_kind_ / 4 )* 4 + 2
	else
		current_bullet_kind_ = (current_bullet_kind_ / 4 )* 4 + 3
	end
	local kind = self:getKindNum(self.m_nMutipleIndex)
	self.parent:switch(self.m_pos, kind)
	self.parent:setCannonMulriple(self.m_pos, self.m_nMutipleIndex)
	self:setMultiple(self.m_nMutipleIndex)

	self._dataModel:playEffect(g_var(cmd).cannonSwitch)
end

return Cannon