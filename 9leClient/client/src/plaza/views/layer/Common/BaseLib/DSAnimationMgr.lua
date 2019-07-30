module("DSAnimationMgr", package.seeall)

function createBreathAni(isRepeat)
	local action1 = cc.ScaleTo:create(0.3,1.1)
	local action2 = cc.ScaleTo:create(0.2,1.2)
	local action3 = cc.ScaleTo:create(0.2,1.0)
	local action4 = cc.ScaleTo:create(0.2,0.95)
	local action4 = cc.ScaleTo:create(0.2,0.9)
	local action5 = cc.ScaleTo:create(0.3,1.0)

	local action6 = cc.DelayTime:create(2)
	local action = nil
	if (isRepeat) then
		action = cc.Repeat:create(cc.Sequence:create(action1,action2,action3,action4,action5,action6), 99999)
		--action = cc.Sequence:create(action1,action2,action3,action4,action5)
	else
		action = cc.Sequence:create(action1,action2,action3,action4,action5,action6)
	end

	return action
end