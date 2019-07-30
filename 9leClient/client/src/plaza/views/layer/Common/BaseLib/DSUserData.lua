module("DSUserData", package.seeall)

local mUserRoomCardCount = 0	--玩家房卡数量

--*************************
--房卡信息
--*************************
function setUserRoomCardCount(num)
	mUserRoomCardCount = num
end

function getUserRoomCardCount()

	return mUserRoomCardCount
end
