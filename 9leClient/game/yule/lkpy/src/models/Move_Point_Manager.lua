--
-- Author: Liuxu
-- Date: 2018-08-25 13:17:55

local Move_Point_Manager = class("Move_Point_Manager")


function Move_Point_Manager:ctor(_x , _y ,_angle)
	
	self:initPoint(_x , _y ,_angle)
	return self
end

function Move_Point_Manager:initPoint(_x , _y ,_angle)
	
	self._positionX = _x
	self._positongY = _y
	self._angle 	= _angle

end

function Move_Point_Manager:getPosition(  )
	return self._positionX , self._positongY
end

return Move_Point_Manager