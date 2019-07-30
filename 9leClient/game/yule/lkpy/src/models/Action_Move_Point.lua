--
-- Author: Liuxu
-- Date: 2018-08-28 
-- 移动
local module_pre = "game.yule.lkpy.src"	

local Action_Move_Point = class("Action_Move_Point", cc.CCActionInterval)
local Move_Poiots 		= appdf.req(module_pre .. ".models.Move_Point_Manager")

function Action_Move_Point:ctor(d , points , offset)
	
	self.move_points_ = {} --里面放Move_Poiots类型
	

	local move_point  = {}
	for i=1,#points do
		if offset._x ~= 0 or offset._y ~=0 then
			move_point = points[i]
			local x1 ,y1 = move_point:getPosition()
			move_point._positionX = x1 + offset.x
			move_point._positionY = y1 + offset.y
			table.insert(self.move_points_,move_point)
		else
			table.insert(self.move_points_,points[i])
		end
	end

	self._duration = d*(#self.move_points_)

	
    return self
end

function Action_Move_Point:update( time )	
	
	
end


return Action_Move_Point