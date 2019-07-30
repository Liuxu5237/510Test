--
-- Author: Tang
-- Date: 2016-08-09 10:45:28
--鱼
local module_pre = "game.yule.lkpy.src"	
local Game_Path_Manager = appdf.req(module_pre .. ".models.Game_Path_Manager")

appdf.req(module_pre .. ".models.HighAction")

local MATERIAL_DEFAULT = cc.PhysicsMaterial(0.1, 0.5, 0.5)
local Fish = class("Fish",function(fishData,target)
	local fish =  display.newSprite()
	return fish
end)

local FISHTAG = 
{
	TAG_GUAN = 10
}
local M_PI   = 3.14159265358979323846
local M_PI_2 = 1.57079632679489661923

local module_pre = "game.yule.lkpy.src"			
local ExternalFun = require(appdf.EXTERNAL_SRC.."ExternalFun")
local cmd = module_pre..".models.CMD_LKGame"
local g_var = ExternalFun.req_var
local scheduler = cc.Director:getInstance():getScheduler()

function Fish:ctor(fishData,target)
	self.isDead = false
	self.scaleSpeed = g_var(cmd).WSCALE
	self.m_bezierArry = {}
	self.trace_vector = {}

	local tempV = fishData.fish_kind+1
	if fishData.fish_kind >= 40 then
				
		if fishData.item_+1 == 1 then
			tempV = 2
		elseif fishData.item_+1 == 2 then
			tempV = 1
		else
			tempV = fishData.item_+1
		end
	end 

	self.fishCreateData = fishData
	self.boxWidth  = target.fish_bounding_box_width_[tempV]
	self.boxHeight = target.fish_bounding_box_height_[tempV]
	self._scene = target
	self.m_schedule = nil
	self.runIndex = 1
	self.m_data = fishData
	target.selectFishList[fishData.fish_kind] = { id = fishData.fish_id, can = true }
	self.trace_index_ = 0
	-- self.m_data.speed =	
	-- self.m_producttime = fishData.nProductTime --wyf
	-- self.m_producttime = 20
	-- self.m_ydtime = 0 			--鱼游动时间
	self.m_pathIndex = 1
	self.m_nQucikClickNum = 0
	self.m_fTouchInterval = 0
	self:setPosition(cc.p(-500,-500))
	self:setTag(g_var(cmd).Tag_Fish)
	self._dataModel = target._dataModel
	-- --dump(self.fishCreateData,"-->self.fishCreateData")
	self:initWithType(self.fishCreateData,target)
	self.multipleNum = nil

	-- self.fish_bounding_box_width={55,60,80,70,80, 90,90,120,150,110, 145,120,180,255,180, 270,290,500,400,404, 200,180,140,130,340, 340,340,460,460,460, 150,150,150,150,150, 150,150,150,150,150};		--鱼边界框的宽度
	-- self.fish_bounding_box_height={15,25,32,43,54,70,40,55,47,112,80,150,70,88,180,80,90,170,100,100,245,100,140,130,130,130,130,130,130,130,150,150,150,150,150,150,150,150,150,150};
	 --注册事件
    ExternalFun.registerTouchEvent(self,true)
end
 
--设置物理属性
function Fish:initPhysicsBody()
	-- --print("自身大小款高 ",self:getContentSize().width) 
	-- --print("self:getContentSize().height",self:getContentSize().height)
	-- --print("x,y ",self:getPosition().x)
	-- --print("yy ",self:getPositionX())
	--精确的话需要在编辑器里做成plist画碰撞圈-> physicsEditor

	local tempV
	if self.m_data.fish_kind >= 40 then
		
		if self.m_data.item_+1 == 1 then
			tempV = 2
		elseif self.m_data.item_+1 == 2 then
			tempV = 1
		else
			tempV = self.m_data.item_+1
		end
	else
		tempV =  self.m_data.fish_kind+1
	end

	 local w,h = self._scene.fish_bounding_box_width_[tempV], self._scene.fish_bounding_box_height_[tempV]

	-- local cube = cc.PhysicsBody:createBox(self:getContentSize(), MATERIAL_DEFAULT)
	local cube = cc.PhysicsBody:createBox(cc.size(w, h), MATERIAL_DEFAULT)
	--local cube = cc.PhysicsBody:createBox(cc.size(self.boxWidth, self.boxHeight), MATERIAL_DEFAULT)
    self:setPhysicsBody(cube)
    --刚体属性
    self:getPhysicsBody():setCategoryBitmask(1)
    self:getPhysicsBody():setCollisionBitmask(0)
    self:getPhysicsBody():setContactTestBitmask(2)
    self:getPhysicsBody():setGravityEnable(false)
    --------------------------------------------------
	-- local fishtype = self.fishCreateData.fish_kind
	-- local body = self._dataModel:getBodyByType(fishtype)

	-- if body == nil then
	-- 	--print("body is nil.......")
	-- 	return
	-- end

	-- self:setPhysicsBody(body)

	-- --设置刚体属性
 --    self:getPhysicsBody():setCategoryBitmask(1)
 --    self:getPhysicsBody():setCollisionBitmask(0)
 --    self:getPhysicsBody():setContactTestBitmask(2)
 --    self:getPhysicsBody():setGravityEnable(false)
end
--鱼是否死了
function Fish:setState(is)
	if is == nil then is = true end
	self.isDead = is
end
function Fish:getState()
	return self.isDead
end
function Fish:setMultiple(num)
	-- --print("李逵倍数是 ",num)
	if self.multipleNum == nil then
		self.multipleNum = cc.LabelAtlas:create("1","game_res/mutipleNum.png",14,17,string.byte("0"))
	    self.multipleNum:setTag(66)
	    self.multipleNum:setScale(2.0)
	    self.multipleNum:setAnchorPoint(0, 0.5)
	    self.multipleNum:setPosition(self:getContentSize().width/2, self:getContentSize().height/2)
	    self:addChild(self.multipleNum)
	end
	self.multipleNum:setString(num)
end

function Fish:CalculateRotateAngle( pntBegin,  pntNext )
	
	local dRotateAngle = math.atan2(math.abs(pntBegin.x - pntNext.x), math.abs(pntBegin.y - pntNext.y));

	
	if (pntNext.x >= pntBegin.x) then
	
		if (pntNext.y >= pntBegin.y) then
			--不做任何处理
		
			dRotateAngle = M_PI - dRotateAngle;
		
		end 
	else
	
		--第二象限
		if (pntNext.y >= pntBegin.y)	then
			dRotateAngle = M_PI + dRotateAngle;
		else--第三象限
			dRotateAngle = 2 * M_PI - dRotateAngle;
		end
	end
	dRotateAngle = dRotateAngle * 180 / M_PI +90;
	return dRotateAngle;
end

function Fish:move_angle( )
	local temp_value = 0;
	temp_value = self:CalculateRotateAngle(self.m_ptCurrent, self.m_ptLast);

	self:setRotation(temp_value);
end

function Fish:updateMovePos()
	local data = self.m_data
	if self.m_scheduleMovePos~=nil then
		scheduler:unscheduleScriptEntry(self.m_scheduleMovePos)
		self.m_scheduleMovePos = nil
	end
	
						 
	--test-------------
	-- local loadText = ccui.Text:create()
 --    loadText:setString(data.fish_id.."|"..data.fish_kind)
 --    loadText:setFontSize(20)
 --    loadText:setTouchScaleChangeEnabled(true)
 --    loadText:setPosition(cc.p(10,10))
 --    loadText:setTouchEnabled(true)
 --    self:addChild(loadText)
 --    local function menuCloseCallback( sender,eventType)
 --        if eventType == ccui.TouchEventType.ended then
 --        	--print("cur click id ",data.fish_id)
 --        	--dump(data)
 --        	--dump(data.init_pos)
 --            cc.Director:getInstance():pause()
 --        end
 --    end
 --    loadText:addTouchEventListener(menuCloseCallback)
	--test-------------

	self._Time = 0
	

	if self.fishCreateData.fish_TTType == 1 then
		--print("path id :" ..self.fishCreateData.path_id_ .. "path type :" .. self.fishCreateData.path_type_)
		local a = Game_Path_Manager:shared():get_paths(self.fishCreateData.path_id_,self.fishCreateData.path_type_)
		-- local zzz = {}
		-- for i=1,#a do
		-- 	local zz = {}
		-- 	zz["_angle"] 	= a[i]._angle
		-- 	zz["_positionX"] =a[i]._positionX
		-- 	zz["_positionY"] =a[i]._positongY
		-- 	table.insert(zzz,zz)
		-- end
		-- local str_offest = string.format( "(%f,%f)",self.fishCreateData.path_offset_.x,self.fishCreateData.path_offset_.y )
		-- local action2 = cjson.encode(zzz)
		-- local action =  ds.Action_Move_Point6:create(0.26, action2,str_offest);

		-- local rel_action = action:getInnerAction()
		-- local seq = cc.Sequence:create(cc.DelayTime:create(self.fishCreateData.path_delay_),
		-- 						rel_action,
		-- 						cc.DelayTime:create(5.0),
		-- 						cc.CallFunc:create(function (  )
		-- 							self._dataModel.m_fishList[data.fish_id] = nil
		-- 							self.m_scheduleMovePos = nil
		-- 							self:stopAllActions()
		-- 							self:removeFromParent()
		-- 							self = nil
		-- 						end))
								
		-- local act_sped = cc.Speed:create(seq,self.fishCreateData.speed_)
		-- self:runAction(act_sped) 
		-- act_sped:step(0)
		-- act_sped:step(self.fishCreateData.elapsed_)

		local speed 	= self.fishCreateData.speed_
		local offset_  	= self.fishCreateData.path_offset_
		local _duration = 0.26 * (#a)
		local _elapsed = 0
		local move_points_ = a
		--设置初始角度
		self:setRotation(90 -  a[1]._angle )
		self:setPosition(cc.p( a[1]._positionX,720 - a[1]._positongY))

		local daly = 0
		local  aa = 1
		local  bb = 1
		local dur2 = 0
		local dur3 = _duration
		if self.fishCreateData.path_delay_ > 0  then
			dur2 = self.fishCreateData.path_delay_
		end

		local fishCount = 0
		local first = true
		if first then
			first = false
			if self.m_data.fish_kind >= g_var(cmd).FishKind.FISH_KIND_25 and self.m_data.fish_kind <= g_var(cmd).FishKind.FISH_KIND_27 then
				fishCount = 2
			elseif self.m_data.fish_kind >= g_var(cmd).FishKind.FISH_KIND_28 and self.m_data.fish_kind <= g_var(cmd).FishKind.FISH_KIND_30 then --大四喜
				fishCount = 3
			end
			
		end
		
		local function updatePos( dt )
			if self._dataModel.dingping == true then return end
			_elapsed = _elapsed + (dt * speed )
		
			local time = math.max(0,math.min(_elapsed/_duration,1))

			local function update( time )
				_elapsed = time * _duration
				local fDiff;
				local fIndex = time * (#a);
				local index = math.floor(fIndex) ;
				if index <= 0 then
					index = 1
				end
				fDiff = fIndex - index;
				if (index >= #(move_points_)) then
	
					index = math.floor(#(move_points_) - 1)  ;
				end
				local move_point = {}
				if (index<#(move_points_) - 1) then
	
					local move_point1 = move_points_[index];
					local move_point2 = move_points_[index + 1];
			
					move_point._positionX= move_point1._positionX*(1.0 - fDiff) + move_point2._positionX*fDiff;
					move_point._positongY= move_point1._positongY*(1.0 - fDiff) + move_point2._positongY*fDiff;
					move_point._angle = move_point1._angle*(1.0 - fDiff) + move_point2._angle*fDiff;
			
					if (math.abs(move_point1._angle - move_point2._angle) > 180.0) then
					
						move_point._angle = move_point1._angle;
					end
				
				else
				
					move_point = move_points_[index];
				end

				local angle = 90 - move_point._angle;
				self:setPosition(cc.p(move_point._positionX,720 - move_point._positongY))
				self:setRotation(angle)
				if self then
					if _elapsed >= _duration then
						self:setVisible(false);
					else
						self:setVisible(true)
					end
				end
				
				if self then
					if _elapsed >= _duration then
						if nil ~= self.m_scheduleMovePos then
							scheduler:unscheduleScriptEntry(self.m_scheduleMovePos)
							self._dataModel.m_fishList[data.fish_id] = nil
							self.m_scheduleMovePos = nil
							self:stopAllActions()
							self:removeFromParent()
							self = nil
						end
					end
				end

			end
			
			update(time)
			
			
		end

	--定时器
	if nil == self.m_scheduleMovePos then
		
		local this  = self
		local seq  = cc.Sequence:create(cc.DelayTime:create(dur2/speed),
								cc.CallFunc:create(function (  )
									this.m_scheduleMovePos = scheduler:scheduleScriptFunc(updatePos, 0, false)
								end))
		
		 self:runAction(seq)

	end

	elseif self.fishCreateData.fish_TTType ==	2 then
		--print("开始解析222？？？？？？")
		self.m_ptCurrent, self.m_ptLast = {x = 0, y = 0},{x = 0, y = 0}

		local delta_ = {x = 0,y = 0}

		delta_.x = self.fishCreateData.end_.x - self.fishCreateData.start_.x
		delta_.y = self.fishCreateData.end_.y - self.fishCreateData.start_.y
		local start1 = self.fishCreateData.start_
		local bird_speed = self.fishCreateData.speed_;
	
		local length = math.sqrt(delta_.x * delta_.x + delta_.y * delta_.y);
		local _duration = length / bird_speed;
		local _elapsed = 0
		local function updatePos( dt )
			if self._dataModel.dingping == true then return end
			_elapsed = _elapsed + dt
			local time = math.max(0,math.min(_elapsed/_duration,1))
			if _elapsed >= _duration then
				if nil ~= self.m_scheduleMovePos then
					scheduler:unscheduleScriptEntry(self.m_scheduleMovePos)
					self._dataModel.m_fishList[data.fish_id] = nil
					self.m_scheduleMovePos = nil
					self:stopAllActions()
					self:removeFromParent()
					self = nil
				end
				return
			end
			local function update( time )
				_elapsed = _duration * time;
				local pt = cc.p(start1.x + delta_.x * time, start1.y + delta_.y * time);
				self:setPosition(cc.p(pt.x,720-pt.y));
				self.m_ptCurrent = pt
				self:move_angle()
				self.m_ptLast = pt
			end
			update(time)
		end 

		--定时器
		if nil == self.m_scheduleMovePos then
			
			local this  = self
			local seq  = cc.Sequence:create(cc.DelayTime:create(self.fishCreateData.path_delay_/self.fishCreateData.path_delay_),
								cc.CallFunc:create(function (  )
									this.m_scheduleMovePos = scheduler:scheduleScriptFunc(updatePos, 0, false)
								end))
			
		 	self:runAction(seq)

		end


	elseif self.fishCreateData.fish_TTType ==	3 then
		self.m_ptCurrent, self.m_ptLast = {x = 0, y = 0},{x = 0, y = 0}

		local center_ 			= self.fishCreateData.center_
		local radius_ 			= self.fishCreateData.radius_
		local rotate_duration_ 	= self.fishCreateData.rotate_duration_
		local start_angle_ 		= self.fishCreateData.start_angle_
		local rotate_angle_		= self.fishCreateData.rotate_angle_
		local move_duration_	= self.fishCreateData.move_duration_
		local speed_			= self.fishCreateData.speed_
		local stage_ 			= 0;
		local angle_ 			= M_PI_2 + start_angle_;
		local _duration 		= rotate_duration_ + move_duration_;

		local is_center_bird 	= false
		if radius_ == 0 then
			is_center_bird =true
		end

		local _elapsed = 0
		local delta_ = {x = 0,y = 0}
		local function updatePos( dt )
			if self._dataModel.dingping == true then return end
			if _elapsed >= _duration then
				if nil ~= self.m_scheduleMovePos then
					scheduler:unscheduleScriptEntry(self.m_scheduleMovePos)
					self._dataModel.m_fishList[data.fish_id] = nil
					self.m_scheduleMovePos = nil
					self:stopAllActions()
					self:removeFromParent()
					self = nil
				end
				return
			end

			_elapsed = _elapsed + dt
			local time = math.max(0,math.min(_elapsed/_duration,1))
			local function update( time )
				_elapsed = time * _duration
				if stage_ == 0 and time * _duration >= rotate_duration_ then
					--散开
					stage_  = 1;
					delta_.x = math.cos(angle_)
					delta_.y = math.sin(angle_)
				end
				if stage_ == 0 then
					--位置
					local angle2 = start_angle_ + rotate_angle_*time
					local pt    = {x = 0, y = 0};
					pt.x = center_.x + radius_ * math.cos(angle2)
					pt.y = center_.y + radius_ * math.sin(angle2)
					self:setPosition(cc.p( pt.x, 720 - pt.y))
					--角度
					self.m_ptCurrent = pt;
					if is_center_bird then
						self:setRotation(angle2 * 180 / M_PI)
					else
						self:move_angle()
					end
					self.m_ptLast = pt
				else
					--散开
					local pt = {x = self:getPositionX() , y = 720 - self:getPositionY()}
					pt.x = pt.x + speed_ * (time/4) * delta_.x;
					pt.y = pt.y + speed_ * (time/4) * delta_.y;
					self:setPosition(cc.p(pt.x,720 - pt.y))
					self.m_ptCurrent = pt;
					self:move_angle()
					self.m_ptLast = pt
				end

				
			end
			update(time)
		end

		--定时器
		if nil == self.m_scheduleMovePos then
			local this  = self
			local seq  = cc.Sequence:create(cc.DelayTime:create(self.fishCreateData.path_delay_),
								cc.CallFunc:create(function (  )
									this.m_scheduleMovePos = scheduler:scheduleScriptFunc(updatePos, 0, false)
								end))
			
		 	self:runAction(seq)

		end


	elseif self.fishCreateData.fish_TTType ==	4 then	

		--print("开始解析4444？？？？？？")
		self.m_ptCurrent, self.m_ptLast = {x = 0, y = 0},{x = 0, y = 0}
		local start_ 			= self.fishCreateData.start_
		local pause_ 			= self.fishCreateData.pause_
		local end_ 				= self.fishCreateData.end_
		local bird_speed_		= self.fishCreateData.speed_
		local pause_time_		= self.fishCreateData.pause_time_
		local start_angle_		= self.fishCreateData.start_angle_

		local front_delta_ = {x =pause_.x - start_.x, y = pause_.y - start_.y } 
		local length = math.sqrt(front_delta_.x * front_delta_.x + front_delta_.y * front_delta_.y);
		local front_time_ = length / bird_speed_;
		local back_delta_ = {x =end_.x - pause_.x, y = end_.y - pause_.y } 
		length = math.sqrt(back_delta_.x * back_delta_.x + back_delta_.y * back_delta_.y);
		local back_time_ = length / bird_speed_;
		local _duration = front_time_ + pause_time_ + back_time_;

		local _elapsed = 0
		local function updatePos( dt )
			if self._dataModel.dingping == true then return end
			if _elapsed >= _duration then
				if nil ~= self.m_scheduleMovePos then
					scheduler:unscheduleScriptEntry(self.m_scheduleMovePos)
					self._dataModel.m_fishList[data.fish_id] = nil
					self.m_scheduleMovePos = nil
					self:stopAllActions()
					self:removeFromParent()
					self = nil
				end
				return
			end

			_elapsed = _elapsed + dt
			local time = math.max(0,math.min(_elapsed/_duration,1))

			local function update( time )
				_elapsed = time * _duration
				local pt = {x = self:getPositionX() , y = self:getPositionY()}
				if _elapsed <= front_time_ then
					time = _elapsed / front_time_;
					pt.x = start_.x + front_delta_.x * time
					pt.y = start_.x + front_delta_.y * time
					self:setPosition(cc.p(pt.x,720 - pt.y))
					--角度
					self.m_ptCurrent = pt;
					self:move_angle();
					self.m_ptLast = pt;
				elseif _elapsed > (front_time_ + pause_time_) then
					time= (_elapsed - (front_time_ + pause_time_)) / back_time_;
					pt.x = pause_.x + back_delta_.x * time ;
					pt.y = pause_.y + back_delta_.y * time ;
					self:setPosition(cc.p(pt.x, 720 - pt.y))
					--角度
					self.m_ptCurrent = pt;
					self:move_angle();
					self.m_ptLast = pt;
				elseif start_.x == pause_.x and start_.y == pause_.y then
					pt.x = pause_.x
					pt.y = pause_.y
					self:setPosition(cc.p(pt.x,720 - pt.y))
					self:setRotation((start_angle_ - M_PI_2) * 180 / M_PI);
				end
			end
			update(time)
		end
		--定时器
		if nil == self.m_scheduleMovePos then
			local this  = self
			local seq  = cc.Sequence:create(cc.DelayTime:create(1),
								cc.CallFunc:create(function (  )
									this.m_scheduleMovePos = scheduler:scheduleScriptFunc(updatePos, 0, false)
								end))
			
		 	self:runAction(seq)

		end


	end

	

	if 1 then
		return
	end

	if data.trace_type == 0 then --直线
		dump(init_pos)
		local speed = self:calcDistance(init_pos[1].x,init_pos[1].y,init_pos[2].x,init_pos[2].y) / distance / 33
		local angle = self._dataModel:getAngleByTwoPoint(init_pos[1], init_pos[2])
		self:setRotation(angle)

   		local function updatePos(dt)
   			if self._dataModel.dingping == true then return end
			self._Time = self._Time + dt
			local pos = self:getPosByValue(init_pos[1].x, init_pos[1].y, init_pos[2].x, init_pos[2].y, self._Time / speed)
			self:setPosition(cc.p(pos.x,pos.y))

			if self._Time/speed >= 1 then
    			if nil ~= self.m_scheduleMovePos then
					scheduler:unscheduleScriptEntry(self.m_scheduleMovePos)
					self.m_scheduleMovePos = nil
					self._dataModel.m_fishList[data.fish_id] = nil
					self:stopAllActions()
					self:removeFromParent()
					self = nil
				end
			end
		end

		if nil == self.m_scheduleMovePos then
			self.m_scheduleMovePos = scheduler:scheduleScriptFunc(updatePos, 0, false)
		end
	elseif data.trace_type == 1 then --曲线
	    local index = 0
	    local temp_pos0 = {x=0,y=0}
	    local t = 0
	    local count = init_count-1
	    local temp_pos = {x=0, y=0, angle=1}
	    local temp_value = 0
	    local begin = 1
	    local endMax = 1000
	    local jumpNum = 1000
	    local testID = nil
	    local delTime = 0

    	while t < 1 do
	    	temp_pos.x = 0
	        temp_pos.y = 0
	        index = 0
			while index <= count do
				--pow  t的index次方
	            temp_value = math.pow(t, index) * math.pow(1-t, count - index) * self:combination(count, index)
	            temp_pos.x = temp_pos.x + ( init_pos[index+1].x * temp_value )
	            temp_pos.y = temp_pos.y + ( init_pos[index+1].y * temp_value )
	            index = index + 1
	        end
	        local pos_space = 0
	        local len = #self.trace_vector
	        if len > 0 then
	            local back_pos = self.trace_vector[len]
	            pos_space = self:calcDistance(back_pos.x, back_pos.y, temp_pos.x, temp_pos.y)
	        end

            if len > 0 then
                local temp_dis = self:calcDistance(temp_pos.x, temp_pos.y, temp_pos0.x, temp_pos0.y)
                if temp_dis ~= 0 then
                    local temp_value = (temp_pos.x - temp_pos0.x) / temp_dis
                    if temp_pos.y - temp_pos0.y >= 0 then
                        temp_pos.angle = math.acos(temp_value)
                    else
                        temp_pos.angle = -math.acos(temp_value)
                    end
                else
                    temp_pos.angle = 1
                end
            else
                temp_pos.angle = 1
            end

            local vdata = {x = temp_pos.x, y= temp_pos.y, angle = temp_pos.angle}
            self.trace_vector[#self.trace_vector+1] = vdata

            temp_pos0.x = temp_pos.x
            temp_pos0.y = temp_pos.y

	        t = t + 0.1
    	end

        local speedVector = {}
        for i=1,#self.trace_vector-1 do
        	local posInfo1 = self.trace_vector[i]
        	local posInfo2 = self.trace_vector[i+1]

        	local juli = self:calcDistance(posInfo1.x, posInfo1.y, posInfo2.x, posInfo2.y)
        	speedVector[i] = juli / distance / 30
        end
        local trace_vector = self.trace_vector
        --先设置初始朝向
        self:setRotation( self._dataModel:getAngleByTwoPoint(init_pos[1], trace_vector[2]) )

        local curAngle  = self:getRotation() % 360
        local curAngle1 = self._dataModel:getAngleByTwoPoint(init_pos[1], trace_vector[3])
        --夹角
        local cur = (curAngle1 - curAngle)
        if cur > 180  then  cur = 360 - cur end
        if cur < -180 then  cur = 360 + cur end

		local index1 = 1
		local index2 = 2
		self:setPosition(init_pos[1])
		local first = true
		local fishCount = 0
		if first then
			first = false
			if self.m_data.fish_kind >= g_var(cmd).FishKind.FISH_KIND_25 and self.m_data.fish_kind <= g_var(cmd).FishKind.FISH_KIND_27 then
				fishCount = 2
			elseif self.m_data.fish_kind >= g_var(cmd).FishKind.FISH_KIND_28 and self.m_data.fish_kind <= g_var(cmd).FishKind.FISH_KIND_30 then --大四喜
				fishCount = 3
			end

			-- if fishCount ~= nil then
			-- 	local x0 = init_pos[1][1].x
			-- 	local y0 = init_pos[1][1].y
			-- 	local dx, dy = 0,0

			-- 	local fishTable = {}
			-- 	fishTable[1] = self
			-- 	local cell_width = self:getContentSize().width * g_var(cmd).WSCALE
			-- 	local radius = (fishCount-1)*cell_width/2
			-- 	for i=1, fishCount do
			-- 		local childFish = self:getChildByName("fish"..i)
			-- 		if childFish ~= nil then
			-- 			fishTable[i+1] = childFish
			-- 		end
			-- 		if radius < 0 then
			-- 			dx = x0 + radius * math.cos(self.trace_vector[1].angle)
			-- 			dy = y0 + radius * math.sin(self.trace_vector[1].angle)
			-- 		else
			-- 			dx = x0 - radius * math.cos(self.trace_vector[1].angle - g_var(cmd).M_PI)
			-- 			dy = y0 - radius * math.sin(self.trace_vector[1].angle - g_var(cmd).M_PI)
			-- 		end
			-- 		--print("self.trace_vector[1].angle ",self.trace_vector[1].angle,x0, y0,dx,dy)
			-- 		error("dd")
			-- 		local nowPos = self._scene._dataModel:convertCoordinateSystem(cc.p(dx, dy), 0, self._scene._dataModel.m_reversal) 
			-- 		-- local angle = self._dataModel:getAngleByTwoPoint(m_oldPoint, nowPos)
			-- 		if fishTable[i] ~= nil then
			-- 			if i == 1 then
			-- 				fishTable[i]:setPosition(nowPos)
			-- 			else
			-- 				local hypos = self:convertToNodeSpace( nowPos ) --世界坐标转换到本地
			-- 				fishTable[i]:setPosition(hypos)
			-- 			end
			-- 			-- if i == 1 then
			-- 			-- 	fishTable[i]:setRotation(angle)
			-- 			-- end
			-- 		end			
			-- 		-- m_oldPoint = nowPos
			-- 		radius = radius - cell_width
			-- 	end
			-- end
		end
		local createTime = 0
		local inTimes = 0
		local ops = nil
   		local function updatePos(dt)
   			if self._dataModel.dingping == true then return end
			self._Time = self._Time + dt
			if fishCount ~= 0 then --大三元四喜用
				createTime = createTime + dt
				if createTime >= 1.1 then
					createTime = 0
					fishCount = fishCount - 1
					inTimes = inTimes + 1
					local childFish = self:getChildByName("fish"..inTimes)
					childFish:setVisible(true)
					local hypos = self:convertToNodeSpace( init_pos[1] ) --世界坐标转换到本地
					childFish:setPosition(cc.p(hypos.x, hypos.y))
				end
			end

			local pos = self:getPosByValue(trace_vector[index1].x, trace_vector[index1].y, trace_vector[index2].x, trace_vector[index2].y , self._Time/speedVector[index1] )
			self:setPosition(cc.p(pos.x,pos.y))

			if trace_vector[index2+1] ~= nil then
				local posNext = self:getPosByValue(trace_vector[index2].x, trace_vector[index2].y, trace_vector[index2+1].x, trace_vector[index2+1].y , self._Time/speedVector[index2] )
				local _angle = self._dataModel:getAngleByTwoPoint(pos, posNext)
				self:setRotation( _angle )
			end

			if self._Time / speedVector[index1] >= 1 then
				index1 = index1 + 1
				index2 = index1 + 1
				self._Time = 0

				if trace_vector[index2] == nil then
	    			if nil ~= self.m_scheduleMovePos then
						scheduler:unscheduleScriptEntry(self.m_scheduleMovePos)
						self._dataModel.m_fishList[data.fish_id] = nil
						self.m_scheduleMovePos = nil
						self:stopAllActions()
						self:removeFromParent()
						self = nil
					end
				end
			end
		end

		--定时器
		if nil == self.m_scheduleMovePos then
			self.m_scheduleMovePos = scheduler:scheduleScriptFunc(updatePos, 0, false)
		end
	elseif data.trace_type == 2 then --场景5的鱼

		local angle = self._dataModel:getAngleByTwoPoint(init_pos[1], init_pos[2])
		self:setRotation(angle)
		local _index = 1
   		local function updatePos(dt)
   			if self._dataModel.dingping == true then return end
   			if _index == -1 then return end
   			local _data = init_pos[_index]
			if _data ~= nil then
				_index = _index + 1
				self:setPosition(cc.p(_data.x, _data.y))

				local nextP = init_pos[_index]
				if nextP ~= nil then
					local angle = self._dataModel:getAngleByTwoPoint(_data, nextP)
					self:setRotation(angle)
				end
				-- self:setRotation(_data.angle)
			else
				scheduler:unscheduleScriptEntry(self.m_scheduleMovePos)
				self.m_scheduleMovePos = nil
				self._dataModel.m_fishList[data.fish_id] = nil
				self:stopAllActions()
				self:removeFromParent()
				self = nil
			end
		end

		if nil == self.m_scheduleMovePos then
			self.m_scheduleMovePos = scheduler:scheduleScriptFunc(updatePos, 0.033, false)
		end
	elseif data.trace_type == 3 then --场景2的鱼潮，需要等待
		local speed = self:calcDistance(init_pos[1].x,init_pos[1].y,init_pos[2].x,init_pos[2].y) / distance / 33
		local angle = self._dataModel:getAngleByTwoPoint(init_pos[1], init_pos[2])
		self:setRotation(angle)
		local waitY    = data.waitY
		local waitTime = data.waitTime
		local shouldWait = false
		local haveWait = 0
		local isBigFish= false
		if waitY == 0 then
			isBigFish = true
		end
   		local function updatePos(dt)
   			if self._dataModel.dingping == true then return end
			if shouldWait == true or isBigFish == true then
				haveWait = haveWait + dt
				-- --print("haveWait ",haveWait, waitTime)
				if haveWait >= waitTime then --等待时间已过 可以走了
					shouldWait = false
				else
					return
				end
			end
			self._Time = self._Time + dt

			local pos = self:getPosByValue(init_pos[1].x, init_pos[1].y, init_pos[2].x, init_pos[2].y, self._Time / speed)
			self:setPosition(cc.p(pos.x,pos.y))
			if pos.y >= waitY and pos.y <= waitY+distance and isBigFish == false then
				shouldWait = true 
				return
			end
			if self._Time/speed >= 1 then
    			if nil ~= self.m_scheduleMovePos then
					scheduler:unscheduleScriptEntry(self.m_scheduleMovePos)
					self.m_scheduleMovePos = nil
					self._dataModel.m_fishList[data.fish_id] = nil
					self:stopAllActions()
					self:removeFromParent()
					self = nil
				end
			end
		end

		if nil == self.m_scheduleMovePos then
			self.m_scheduleMovePos = scheduler:scheduleScriptFunc(updatePos, 0, false)
		end
	end
end
function Fish:getRotationByAngle(angle, t)
	local _angle = t*angle

	return _angle
end
function Fish:getPosByValue(x1,y1,x2,y2,t)
	local Pos = {x,y}
	Pos.x = x2 - x1
	Pos.y = y2 - y1
	if t > 1 then t = 1 end
	Pos.x = x1 + Pos.x * t
	Pos.y = y1 + Pos.y * t

	return Pos
end

function Fish:unScheduleFish()
	if nil ~= self.m_schedule then
		scheduler:unscheduleScriptEntry(self.m_schedule)
		self.m_schedule = nil
	end
	if nil ~= self.m_scheduleMovePos then
		scheduler:unscheduleScriptEntry(self.m_scheduleMovePos)
		self.m_scheduleMovePos = nil
	end
	if self.updateRotate ~= nil then
		scheduler:unscheduleScriptEntry(self.updateRotate)
		self.updateRotate = nil
	end
end

function Fish:onEnter()
	self:updateMovePos()
end

function Fish:onExit( )
	self._dataModel.m_InViewTag[self.m_data.fish_id] = nil
	self:unScheduleFish()
end

function Fish:onTouchBegan(touch, event)
	

	local point = touch:getLocation()
	point = self:convertToNodeSpace(point)

	local rect = self:getBoundingBox()

	rect = cc.rect(0,0,rect.width,rect.height) 

	return cc.rectContainsPoint( rect, point )  

end

function Fish:onTouchEnded(touch, event )
	-- local __fish = self._dataModel.m_fishList[self._dataModel.m_fishIndex]
    -- if __fish ~= nil then
    --     if __fish:getChildByName("last") then
    --         __fish:getChildByName("last"):removeFromParent()
    --     end
    -- end
	-- --切换成当前锁定目标
	-- self._dataModel.m_fishIndex	= self.m_data.fish_id
	-- if self._dataModel.m_autolock  then
	-- 	local cannon = self._scene.m_cannonLayer:getCannoByPos(self._scene.m_nChairID + 1)
	--     if cannon ~= nil then
	--         -- --print("iiiiiiiiiiiiiiiiiiiIIIIIIIIIIIIIIIII")
	--         cannon:setLockAngle(self._dataModel.m_fishIndex)
	--     end
	-- end
	-- --print("fish touch ended ",self:getPositionX(), self:getPositionY(),self._dataModel.m_fishIndex)
end


function Fish:initWithType( param,target)
	-- self:initBezierConfig(param)
end

function Fish:initBezierConfig( param )
	
	if type(param) ~= "table" then
		--print("传入参数类型有误 initBezierConfig, the param should be a type of table")
		return
	end
	-- --print("param.init_count  ",param.init_count)
	-- --dump(param.init_pos, "pos data ------>>>")
	for i=1,param.init_count do
		local bezier =  param.init_pos[1][i]
		bezier.x = bezier.x * g_var(cmd).WSCALE
		bezier.y = bezier.y * g_var(cmd).HSCALE
		local bconfig = 
		{
			cc.p(bezier.x, bezier.y),
	        cc.p(bezier.x, bezier.y),
	        cc.p(bezier.x, bezier.y)
		}


		table.insert(self.m_bezierArry, bconfig)
	end
end

function Fish:PointOnCubicBezier(pathIndex,t)

	local bconfig = 
		{
			dAx = 0,
			dBx = 0,
			dCx = 0,
			dAy = 0,
			dBy = 0,
			dCy = 0
		}

    local result = {}
	local tSquard = 0
	local tCubed = 0
	local param = self.m_data
	bconfig = self.m_bezierArry[pathIndex]

	local bezier =  param.TBzierPoint[1] -- table
	local tbp =  bezier[pathIndex]
	tSquard = t*t
	tCubed = tSquard*t
	-- result.x = (bconfig.dAx * tCubed) + (bconfig.dBx * tSquard) + (bconfig.dCx * t) + tbp.BeginPoint.x --wyf
	result.x = (bconfig.dAx * tCubed) + (bconfig.dBx * tSquard) + (bconfig.dCx * t) + 20
	-- result.y = (bconfig.dAy * tCubed) + (bconfig.dBy * tSquard) + (bconfig.dCy * t) + tbp.BeginPoint.y --wyf
	result.y = (bconfig.dAy * tCubed) + (bconfig.dBy * tSquard) + (bconfig.dCy * t) + 20

	return result
end

function Fish:RotatePoint(pcircle,dradian,ptsome)

	local tmp = {}
	ptsome.x = ptsome.x - pcircle.x
	ptsome.y = ptsome.y - pcircle.y

	tmp.x = ptsome.x*math.cos(dradian) - ptsome.y*math.sin(dradian) + pcircle.x
	tmp.y = ptsome.x * math.sin(dradian) + ptsome.y*math.cos(dradian) + pcircle.y

	return tmp
end

function Fish:getBirdPostion( bird_rank , mBirdNum)

	-- 鱼的数量
	local now_p = {x = 0, y = 0};
	local angle = 0;
	local radian;
	local length = 95;
	if (mBirdNum == 1) then
		return now_p;
	elseif (mBirdNum == 2) then
		angle = 180 * bird_rank;
		length = 80;
	elseif (mBirdNum == 3) then
		angle = 120 * bird_rank;
		length = 95;
	elseif (mBirdNum == 4) then
		angle = 90 * bird_rank;
	elseif (mBirdNum == 5 and bird_rank ~= 4) then
		angle = 90 * bird_rank;
	elseif (mBirdNum == 5 and bird_rank == 4) then 
		return now_p;
	end


	radian = angle * 0.01745329252;
	now_p.x = length * math.cos(radian);
	now_p.y = length * math.sin(radian);

	return now_p;

end

function Fish:initAnim()
	-- if self.m_data.fish_kind <= 22 then return end
	local namestr = ""
	local aniName = ""
	local show = true
	local function initSelfAnim(name, ani, widget)
		widget:initWithSpriteFrameName(name)
		if self.m_data.fish_kind == g_var(cmd).FishKind.FISH_KIND_24 then
			-- --print("转圈----------------")
   			-- local repeatAction = cc.RepeatForever:create(cc.RotateBy:create(3, 20000))
   			-- widget:runAction(repeatAction)
   			local ro = 1
   			local function updateRotate(dt)
   				if ro > 360 then ro = 1 end
				self:setRotation(ro)
				ro = ro + 2
			end

			if nil == self.updateRotate then
				self.updateRotate = scheduler:scheduleScriptFunc(updateRotate, 0, false)
			end
	   	else
			local animation = cc.AnimationCache:getInstance():getAnimation(ani)
			if nil ~= animation then
		   		local action = cc.RepeatForever:create(cc.Animate:create(animation))
		   		widget:runAction(action)
		   		--渐变出现
		   		widget:setOpacity(0)
		   		widget:runAction(cc.FadeTo:create(0.2,255))
			end
		end
	end

	local function createDi(pic)
		local di = display.newSprite()
		di:initWithSpriteFrameName(pic)

		local act1 = cc.RotateTo:create(2, 180)
	    local act2 = cc.RotateTo:create(2, 360)
	    local seq  = cc.Sequence:create(act1, act2)
	    local rep1 = cc.RepeatForever:create(seq)
    	di:runAction(rep1)
		
		return di
	end

	function createPhysicsBody(widget)
		-- local cube = cc.PhysicsBody:createBox(widget:getContentSize(), MATERIAL_DEFAULT)
		--print("boxWidth-------------------------------- ",self.boxWidth, self.boxHeight)
		local cube = cc.PhysicsBody:createBox(cc.size(self.boxWidth, self.boxHeight), MATERIAL_DEFAULT)
	    widget:setPhysicsBody(cube)
	    --刚体属性
	    widget:getPhysicsBody():setCategoryBitmask(1)
	    widget:getPhysicsBody():setCollisionBitmask(0)
	    widget:getPhysicsBody():setContactTestBitmask(2)
	    widget:getPhysicsBody():setGravityEnable(false)
	end

	if self.m_data.fish_kind <= g_var(cmd).FishKind.FISH_KIND_23 then
		local tempV = 0
		if self.m_data.fish_kind+1 == 1 then
			tempV = 2
		elseif self.m_data.fish_kind+1 == 2 then
			tempV = 1
		else
			tempV = self.m_data.fish_kind+1
		end
		namestr = string.format("fish%d_01.png", tempV)
		aniName = string.format("animation_fish_move%d", tempV)
	elseif self.m_data.fish_kind == g_var(cmd).FishKind.FISH_KIND_24 then --超级炸弹就一个图 所以直接是图片名
		show = false
		--print("炸弹出来了。。。。。")
		namestr = "fish24.png"
		aniName = string.format("animation_fish_move%d", self.m_data.fish_kind+1)
		initSelfAnim(namestr, aniName, self)
		-- local act1 = cc.RotateTo:create(1, 180)
	 --    local act2 = cc.RotateTo:create(1, 360)
	 --    local seq  = cc.Sequence:create(act1, act2)
	 --    local rep1 = cc.RepeatForever:create(seq)
  --   	self:runAction(rep1)

  		-- local repeatAction = cc.RepeatForever:create(cc.RotateBy:create(3.0, 360))

    -- 	self:runAction(repeatAction)
	else
		--特殊处理
		if self.m_data.fish_kind >= g_var(cmd).FishKind.FISH_KIND_25 and self.m_data.fish_kind <= g_var(cmd).FishKind.FISH_KIND_27 then --大三元
			-- --print("大三元出来了------------------------------------------ ",self.m_data.fish_kind)
			show = false
			if self.m_data.fish_kind == g_var(cmd).FishKind.FISH_KIND_25 then
				namestr = string.format("fish%d_01.png", 4)
				aniName = string.format("animation_fish_move%d", 4)
			elseif self.m_data.fish_kind == g_var(cmd).FishKind.FISH_KIND_26 then
				namestr = string.format("fish%d_01.png", 5)
				aniName = string.format("animation_fish_move%d", 5)
			else
				namestr = string.format("fish%d_01.png", 7)
				aniName = string.format("animation_fish_move%d", 7)
			end
			initSelfAnim(namestr, aniName, self)
			self:setName("dasanyuan")
			for i=1,2 do
				local di = createDi("dish.png")
				di:setName("di")
				--di:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2))
	   			local _fish = display.newSprite()
				_fish:addChild(di, -1)
				_fish:setName("fish"..i)
				--位置
				local fatherpos = self:getAnchorPointInPoints()
				local birdpos = {x = fatherpos.x + self:getBirdPostion(i,2).x,y =fatherpos.y + self:getBirdPostion(i,2).y  }
				_fish:setPosition(cc.p(birdpos.x,birdpos.y))

				initSelfAnim(namestr, aniName, _fish)
				createPhysicsBody(_fish)
				self:addChild(_fish)

				di:setPosition(cc.p(_fish:getContentSize().width/2, _fish:getContentSize().height/2))
				if i == 1 then
					_fish:setZOrder(-1)
					local di1 = createDi("dish.png")
					di1:setName("di")
					di1:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2))
					self:addChild(di1, -1)
				end
			end
		elseif self.m_data.fish_kind >= g_var(cmd).FishKind.FISH_KIND_28 and self.m_data.fish_kind <= g_var(cmd).FishKind.FISH_KIND_30 then --大四喜
			-- --print("大四喜出来了-------------------------------------- ",self.m_data.fish_kind)
			show = false
			if self.m_data.fish_kind == g_var(cmd).FishKind.FISH_KIND_28 then
				namestr = string.format("fish%d_01.png", 6)
				aniName = string.format("animation_fish_move%d", 6)
			elseif self.m_data.fish_kind == g_var(cmd).FishKind.FISH_KIND_29 then
				namestr = string.format("fish%d_01.png", 8)
				aniName = string.format("animation_fish_move%d", 8)
			else
				namestr = string.format("fish%d_01.png", 10)
				aniName = string.format("animation_fish_move%d", 10)
			end
			initSelfAnim(namestr, aniName, self)
			self:setName("dasixi")
			local psize = self:getContentSize()
			
			for i=1,3 do
				local di = createDi("dish.png")
				di:setName("di")
				--di:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2))
	   			local _fish = display.newSprite()
				_fish:addChild(di, -1)
				_fish:setName("fish"..i)
				--_fish:setVisible(false)
				initSelfAnim(namestr, aniName, _fish)
				createPhysicsBody(_fish)
				self:addChild(_fish)

				--位置
				local fatherpos = self:getAnchorPointInPoints()
				local birdpos = {x = fatherpos.x + self:getBirdPostion(i,3).x,y =fatherpos.y + self:getBirdPostion(i,3).y  }
				_fish:setPosition(cc.p(birdpos.x,birdpos.y))

				di:setPosition(cc.p(_fish:getContentSize().width/2, _fish:getContentSize().height/2))
				if i == 1 then
					local di1 = createDi("dish.png")
					di1:setName("di")
					di1:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2))
					self:addChild(di1, -1)
				end
			end
		elseif self.m_data.fish_kind <= g_var(cmd).FishKind.FISH_KIND_31 then  --鱼王
			show = false
			-- --print("鱼王出来了 ----------------------------------------",self.m_data.fish_kind)
			namestr = string.format("fish%d_01.png", self.m_data.fish_kind-29)
			aniName = string.format("animation_fish_move%d", self.m_data.fish_kind-29)
			initSelfAnim(namestr, aniName, self)
   			local di = createDi("halo.png")
   			di:setName("di")
   			di:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2))
			self:addChild(di, -1)
		elseif self.m_data.fish_kind >= 40 then
			show = false
			-- --print("鱼王出来了 ----------------------------------------",self.m_data.fish_kind)
			local tempV
			if self.m_data.item_+1 == 1 then
				tempV = 2
			elseif self.m_data.item_+1 == 2 then
				tempV = 1
			else
				tempV = self.m_data.item_+1
			end

			-- if self.m_data.item_ == 0 then
			-- 	namestr = string.format("fish%d_01.png", 1)
			-- 	aniName = string.format("animation_fish_move%d", 1)
			-- else 
				namestr = string.format("fish%d_01.png", tempV)
				aniName = string.format("animation_fish_move%d", tempV)
			--end
			initSelfAnim(namestr, aniName, self)

		end
	end
	--print("fish init anim: " .. namestr  .. aniName .. "Q" .. self.m_data.fish_kind)
	dump(show)
	if show then
		initSelfAnim(namestr, aniName, self)
	end
end

--死亡处理
function Fish:deadDeal()

	self:setState(true)
	self._scene.selectFishList[self.m_data.fish_kind] = nil
	self._dataModel.m_fishList[self.m_data.fish_id] = nil --为了不让锁鱼状态持续射击已经死亡状态的鱼
	self:setColor(cc.WHITE)
	self:stopAllActions()
	self:unScheduleFish()
	self:getPhysicsBody():setCategoryBitmask(8)



	local aniName = string.format("animation_fish_dead%d",self.m_data.fish_kind+1)
	local ani = cc.AnimationCache:getInstance():getAnimation(aniName)
	print("鱼死亡了 ----------",self.m_data.fish_kind ,aniName, ani)
	local parent = self:getParent()

	--print("self.m_data.fish_kind--------------------",self.m_data.fish_kind)
	if self.m_data.fish_kind >= g_var(cmd).FishKind.FISH_KIND_18 and  self.m_data.fish_kind <= g_var(cmd).FishKind.FISH_KIND_21 then

	 	local ding = cc.ParticleSystemQuad:create("game/yule/lkpy/res/fish/bomb01.plist")
	   	ding:setAnchorPoint(cc.p(0.5 , 0.5))
	    ding:setPosition(0,0)
	    ding:retain()
	    local batch = cc.ParticleBatchNode:createWithTexture(ding:getTexture())
	    batch:addChild(ding,20)
	    self:addChild(batch, 20)

	elseif self.m_data.fish_kind == g_var(cmd).FishKind.FISH_KIND_24   then

	 	local ding = cc.ParticleSystemQuad:create("game/yule/lkpy/res/fish/bomb02_1.plist")
	 	--ding:setAnchorPoint(cc.p(0.5 , 0.5))
	    ding:setPosition(self:getPositionX(),self:getPositionY())
	    ding:retain()
	    local batch = cc.ParticleBatchNode:createWithTexture(ding:getTexture())
	    batch:addChild(ding)
	    self._scene:addChild(batch, 20)

	    local ding2 = cc.ParticleSystemQuad:create("game/yule/lkpy/res/fish/bomb02_2.plist")
	   -- ding2:setAnchorPoint(cc.p(0.5 , 0.5)) 
	    ding2:setPosition(self:getPositionX(),self:getPositionY())
	    ding2:retain()
	    local batch2 = cc.ParticleBatchNode:createWithTexture(ding2:getTexture())
	    batch2:addChild(ding2,21)
	    self._scene:addChild(batch2, 21)

	    local ding3 = cc.ParticleSystemQuad:create("game/yule/lkpy/res/fish/bomb02_3.plist")
	    --ding3:setAnchorPoint(cc.p(0.5 , 0.5))
	    ding3:setPosition(self:getPositionX(),self:getPositionY())
	    ding3:retain()
	    local batch3 = cc.ParticleBatchNode:createWithTexture(ding3:getTexture())
	    batch3:addChild(ding3,22)
	    self._scene:addChild(batch3, 22)
		local call = cc.CallFunc:create(function()
			batch:removeFromParent()
			batch2:removeFromParent()	
			batch3:removeFromParent()
		end)

		batch3:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),call))
	elseif self.m_data.fish_kind == g_var(cmd).FishKind.FISH_KIND_23 then 
		local radius = 580
		local nBomb = 12

		local pos = cc.p(self:getPositionX(),self:getPositionY())
		for i=1,nBomb do
			local boomAnim = cc.AnimationCache:getInstance():getAnimation("BombAnim")
			local bomb = cc.Sprite:create()
			bomb:setPosition(self:getPositionX(),self:getPositionY())
			bomb:runAction(cc.Animate:create(boomAnim))
			self._scene:addChild(bomb,50)
			if boomAnim then
				local purPos = cc.p(0,0)
				purPos.x = pos.x + radius * self._dataModel.m_cosList[30*i]
				purPos.y = pos.y + radius * self._dataModel.m_sinList[30*i]

				local move = cc.MoveTo:create(0.8,cc.p(purPos.x,purPos.y))

				local call = cc.CallFunc:create(function()	
					bomb:removeFromParent()
				end)

				bomb:runAction(cc.Sequence:create(move,call))
			end
		end
		local m1 = cc.MoveBy:create(0.05,cc.p(20*2,20*2))
		local m2 = cc.MoveBy:create(0.1,cc.p(-40*2,-40*2))
		local m3 = cc.MoveBy:create(0.05,cc.p(20*2,20*2))
		local s1 = cc.Sequence:create(m1,m2,m3)
		local r1 = cc.RepeatForever:create(s1)
		self._scene:runAction(s1) 
	elseif self.m_data.fish_kind >= g_var(cmd).FishKind.FISH_KIND_25 then

	 	local ding = cc.ParticleSystemQuad:create("game/yule/lkpy/res/fish/bomb03_1.plist")
	    --ding:setAnchorPoint(cc.p(0.5 , 0.5)) 
	    ding:setPosition(self:getPositionX(),self:getPositionY())
	    ding:retain()
	    local batch = cc.ParticleBatchNode:createWithTexture(ding:getTexture())
	    batch:addChild(ding)
	    self._scene:addChild(batch, 20)

	    local ding2 = cc.ParticleSystemQuad:create("game/yule/lkpy/res/fish/bomb03_2.plist")
	   -- ding2:setAnchorPoint(cc.p(0.5 , 0.5)) 
	    ding2:setPosition(self:getPositionX(),self:getPositionY())
	    ding2:retain()
	    local batch2 = cc.ParticleBatchNode:createWithTexture(ding2:getTexture())
	    batch2:addChild(ding2,21)
	    self._scene:addChild(batch2, 21)

	    local ding3 = cc.ParticleSystemQuad:create("game/yule/lkpy/res/fish/bomb03_3.plist")
	   -- ding3:setAnchorPoint(cc.p(0.5 , 0.5)) 
	    ding3:setPosition(self:getPositionX(),self:getPositionY())
	    ding3:retain()
	    local batch3 = cc.ParticleBatchNode:createWithTexture(ding3:getTexture())
	    batch3:addChild(ding3,22)
	    self._scene:addChild(batch3, 22)

	    local ding4 = cc.ParticleSystemQuad:create("game/yule/lkpy/res/fish/bomb03_4.plist")
	   -- ding4:setAnchorPoint(cc.p(0.5 , 0.5)) 
	    ding4:setPosition(self:getPositionX(),self:getPositionY())
	    ding4:retain()
	    local batch4 = cc.ParticleBatchNode:createWithTexture(ding4:getTexture())
	    batch4:addChild(ding4,23)
	    self._scene:addChild(batch4, 23)
	    local call = cc.CallFunc:create(function()
			batch:removeFromParent()
			batch2:removeFromParent()	
			batch3:removeFromParent()
			batch4:removeFromParent()
		end)

		batch4:runAction(cc.Sequence:create(cc.DelayTime:create(2.0),call))
				local m1 = cc.MoveBy:create(0.05,cc.p(20*2,20*2))
		local m2 = cc.MoveBy:create(0.1,cc.p(-40*2,-40*2))
		local m3 = cc.MoveBy:create(0.05,cc.p(20*2,20*2))
		local s1 = cc.Sequence:create(m1,m2,m3)
		local r1 = cc.RepeatForever:create(s1)
		self._scene:runAction(s1) 
	elseif self.m_data.fish_kind == g_var(cmd).FishKind.FISH_KIND_22 then --定屏特效
		local function playDingEffect(  )
	        local node = cc.Node:create()
	        local fishX, fishY = self:getPositionX(),self:getPositionY()
	        node:setPosition(cc.p(self:getPositionX(),self:getPositionY()))
	        self._scene:addChild(node)
	        for i=1, 30 do 
	            local ding = cc.Sprite:create("Effect_Pause.png")
	            ding:setScale(0.1)
	            node:addChild(ding)
	            local bhTime = 1.5
	            local randomX, randomY = math.random(-fishX,yl.WIDTH-fishX), math.random(-fishY,yl.HEIGHT-fishY)
	            local randomScale = math.random(8,12) / 10
	            ding:runAction(cc.ScaleTo:create(bhTime,randomScale,randomScale))
	            local move = cc.MoveTo:create(bhTime, cc.p(randomX, randomY))
	            local fade = cc.FadeOut:create(0.8)
	            local call = cc.CallFunc:create(function()
	                node:removeFromParent()
	            end)
	            ding:runAction(cc.Sequence:create(move, fade, call))
	        end
	    end
	    playDingEffect()
	end

	local function playDeadAnim()
		local times = 1
		--dump(ani)
		local repeats = cc.Repeat:create(cc.Animate:create(ani), times)
		local call = cc.CallFunc:create(function()	
			-- --print("播放完了删除本身")
			self._dataModel.m_fishList[self.m_data.fish_id] = nil
		   	self:unScheduleFish()
  	       	self:removeFromParent()
   		end)
		local action = cc.Sequence:create(repeats,call)
		self:runAction(action)
	end
	if nil ~= ani then
		-- --print("播放死亡动画")
		playDeadAnim()
	else
		local returnRealVal = 
		{
			[g_var(cmd).FishKind.FISH_KIND_25] = 4,
			[g_var(cmd).FishKind.FISH_KIND_26] = 5,
			[g_var(cmd).FishKind.FISH_KIND_27] = 7,

			[g_var(cmd).FishKind.FISH_KIND_28] = 6,
			[g_var(cmd).FishKind.FISH_KIND_29] = 8,
			[g_var(cmd).FishKind.FISH_KIND_30] = 10,
		}
		-- --print("没有这个死亡动画删除本身")
		if self.m_data.fish_kind >= g_var(cmd).FishKind.FISH_KIND_25 and self.m_data.fish_kind <= g_var(cmd).FishKind.FISH_KIND_27 then --三元
			aniName = string.format("animation_fish_dead%d",returnRealVal[self.m_data.fish_kind] )
			ani = cc.AnimationCache:getInstance():getAnimation(aniName)
		elseif self.m_data.fish_kind >= g_var(cmd).FishKind.FISH_KIND_28 and self.m_data.fish_kind <= g_var(cmd).FishKind.FISH_KIND_30 then --四喜
			aniName = string.format("animation_fish_dead%d",returnRealVal[self.m_data.fish_kind] )
			ani = cc.AnimationCache:getInstance():getAnimation(aniName)
		elseif self.m_data.fish_kind >= g_var(cmd).FishKind.FISH_KIND_31 then --鱼王
			aniName = string.format("animation_fish_dead%d",self.m_data.fish_kind + 1 - g_var(cmd).FishKind.FISH_KIND_31 )
			ani = cc.AnimationCache:getInstance():getAnimation(aniName)
		else --真的没有了
			self._dataModel.m_fishList[self.m_data.fish_id] = nil
			self:unScheduleFish()
			self:removeFromParent()
			return false
		end
		playDeadAnim()
	end
end




--转换坐标
function  Fish:setConvertPoint( point )
		
	 local WIN32_W = cc.Director:getInstance():getVisibleSize().width
	 local WIN32_H = cc.Director:getInstance():getVisibleSize().height

	 local scalex = yl.WIDTH/WIN32_W
	 local scaley = yl.HEIGHT/WIN32_H

	 local pos = cc.p(point.x*scalex,(WIN32_H-point.y)*scaley) 

	 self:setPosition(pos)
end


--鱼停留
function Fish:Stay(time)
	error("ssssssssstay ")
	-- self:unScheduleFish()
	-- local call = cc.CallFunc:create(function()	
	-- 	self:schedulerUpdate()
	-- end)
	-- local delay = cc.DelayTime:create(time/1000)

	-- self:runAction(cc.Sequence:create(delay,call))


end

--[[
* @brief  两点距离
* @param [in] x1       位置1x坐标
* @param [in] y1       位置1y坐标
* @param [in] x2       位置2x坐标
* @param [in] y2       位置2y坐标
* @return  返回结果
--]]
function Fish:calcDistance(x1, y1, x2, y2) --求距离
	--print("ff ",x1, y1, x2, y2)
    return math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
end
--[[
* @brief  组合
* @param [in] count    多少个元素
* @param [in] r        取出多少个
* @return  返回结果
--]]
function Fish:combination(count, r)
	-- --print("combination ",count, r, self:factorial(count),self:factorial(r), self:factorial(count - r)        )
    return self:factorial(count) / ( self:factorial(r) * self:factorial(count - r) )
end
--[[
* @brief  阶乘
* @param [in] chair_id     多少阶乘
* @return  返回结果
--]]
function Fish:factorial(number)
    local factorial = 1
    local temp = number
    -- --print(" number ",number)
    for i=1, number do
        factorial = factorial * temp
        -- --print("factorial ",factorial, temp)
        temp = temp - 1
    end
    return factorial
end

return Fish