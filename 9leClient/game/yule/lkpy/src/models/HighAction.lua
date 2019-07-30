--
-- Author: liuxu
-- Date: 2018-09-21
-- 自定义动作


--动作管理器 
ccActionManager = class("ccActionManager")


function ccActionManager:ctor(  )
	self.targetActionsMap = {}  --目标节点与其动画映射表
end

function ccActionManager:runAction( action,target ,du)	--绑定并执行动画
	self.du = du
	assert(action ~=nil and target ~=nil , "action and target musetbe non_nil")

	action:startWithTarget(target)
	if not self.targetActionsMap[target] then
		self.targetActionsMap[target] = {}
	end
	table.insert(self.targetActionsMap[target], action)

	--目标移除场景时， 晴空对应动作
	target:onNodeEvent("exit",function (  )
		self.targetActionsMap[target] = nil
	end)

	--启动主循环
	local scheduler = cc.Director:getInstance():getScheduler()
	if not self.mainScheduleId then
		self.mainScheduleId = scheduler:scheduleScriptFunc(function ( dt)
			self:update(dt)
		end,0,false)
	end

end

function ccActionManager:update( dt ) 
    local hasAction = false
    for target,actionLst in pairs(self.targetActionsMap) do
		for key,action in ipairs(actionLst) do
			if self.du ~=nil then
				action:step(self.du*dt)
			else
				action:step(dt)
			end
           
            hasAction = true
            if action:isDone() then
                actionLst[key] = nil -- 清除已完成动画
            end
        end
    end

    if not hasAction then
        if self.mainScheduleId then
            local scheduler = cc.Director:getInstance():getScheduler()
            scheduler:unscheduleScriptEntry(self.mainScheduleId)
            self.mainScheduleId = nil
        end
    end
end
g_ccActionManager = ccActionManager:create()

local Action = class("Action") -- 动作基类
--[[
Action.m_target = nil -- 动画的目标节点
]]
function Action:ctor()
end
function Action:startWithTarget( target )
    self.m_target = target
end
function Action:getTarget()
    return self.m_target
end
function Action:initWithDuration( duration )
    self.m_elapsed = 0 -- 已执行时间
    self.m_duration = duration -- 总时间
end
function Action:getDuration()
    return self.m_duration
end
function Action:step( dt ) -- 将动作执行时间线转换为进度线
    self.m_elapsed = self.m_elapsed + dt
    local percent = math.max(0,math.min(self.m_elapsed/self.m_duration,1))
    self:update(percent)
end
function Action:isDone()
    return self.m_elapsed > self.m_duration
end
function Action:update( percent )
end



local module_pre = "game.yule.lkpy.src"	

local Move_Poiots 		= appdf.req(module_pre .. ".models.Move_Point_Manager")
ccAction_Move_Point6 = class("ccAction_Move_Point6",Action)
function ccAction_Move_Point6:ctor( d,points , offset )
    -- endPos: period*n + pos 
	
	self.move_points_ = {} --里面放Move_Poiots类型
	
	for i=1,#points do
		local move_point  = {}
		move_point = points[i]
		--dump(points[i])
		local x1 ,y1 = points[i]._positionX, points[i]._positongY

		if offset._x ~= 0 or offset._y ~=0 then
			
			move_point._positionX = x1 + offset.x
			move_point._positongY = y1 + offset.y
			table.insert(self.move_points_,move_point)
		else
			table.insert(self.move_points_,points[i])
		end
	end
	--dump(self.move_points_)
	self:initWithDuration(d*(#self.move_points_))

    --self.m_endPos = endPos
    -- self.m_periodWidth = periodWidth
    -- self.m_periodHeight = periodHeight
end
function ccAction_Move_Point6:startWithTarget( target )
    self.super.startWithTarget(self,target)
    -- self.m_startPos = cc.p(target:getPositionX(),target:getPositionY())
    -- self.m_deltaLen = cc.pSub(self.m_endPos,self.m_startPos)
end
function ccAction_Move_Point6:update( percent )

	--print("percent " .. percent)
	self.m_elapsed = percent * self.m_duration;
	
	local fDiff;
	local fIndex = percent * #(self.move_points_)
	local index = math.ceil(fIndex) ;

	--print("self.move size" .. #self.move_points_)
	
	fDiff = fIndex - index;

	if (index >= #(self.move_points_)) then
	
		index = math.ceil(#(self.move_points_) - 1)  ;
	end

	local move_point = {}
	--print("findex" .. index)
	if (index<#(self.move_points_) - 1) then
	
		local move_point1 = self.move_points_[index];
		local move_point2 = self.move_points_[index + 1];

		move_point._positionX= move_point1._positionX*(1.0 - fDiff) + move_point2._positionX*fDiff;
		move_point._positongY= move_point1._positongY*(1.0 - fDiff) + move_point2._positongY*fDiff;
		move_point._angle = move_point1._angle*(1.0 - fDiff) + move_point2._angle*fDiff;

		if (math.abs(move_point1._angle - move_point2._angle) > 180.0) then
		
			move_point._angle = move_point1._angle;
		end
	
	else
	
		move_point = self.move_points_[index];
	end


	local angle = 90 - move_point._angle;

	self.m_target:setPosition(cc.p(move_point._positionX,720 - move_point._positongY));

	self.m_target:setRotation(angle);

	if ( self.m_target) then
	
		if (self.m_elapsed >= self.m_duration) then
		
			self.m_target:setVisible(false);
		
		else
		
			self.m_target:setVisible(true);
		end
	end

	

    -- local curPosX = self.m_periodWidth and (self.m_startPos.x + self.m_deltaLen.x * percent) % self.m_periodWidth or self.m_startPos.x
    -- local curPosY = self.m_periodHeight and (self.m_startPos.y + self.m_deltaLen.y * percent) % self.m_periodHeight or self.m_startPos.y
    -- self.m_target:setPosition(cc.p(curPosX,curPosY))
    -- print("ccMoveToPeriod:update  curPosX:",curPosX,"curPosY:",curPosY,"startPosY:",self.m_startPos.y)
end

