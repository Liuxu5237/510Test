--游戏记录
local GameRecord = class("GameRecord")
local MaxItem = 35

function GameRecord:ctor( delegate,node )
	self._delegate = delegate
	self._node = node
	self._currentRecordNumber = 0
end

function GameRecord:getPos(index)
	local line = math.floor((index - 1) / 5)
	local list = ((index - 1) % 5)
 
	local offsetX = 62
	local offsetY = 40
	local beginPosX = 28
	local beginPosY = 180
	
	local pos = {}
	pos.x = beginPosX +  offsetX * line
	pos.y = beginPosY - offsetY * list
	if line % 2 == 1 then
		beginPosY = 20
		pos.y = beginPosY + offsetY * list
	end
	return pos
end

function GameRecord:getCurrentRecordNumber()
	return self._currentRecordNumber
end

function GameRecord:getMaxRecordNumber()
	return MaxItem
end

function GameRecord:AddGameRecord(type)


--	local function addspr()

--        if self._currentRecordNumber >0 then
--            local item = self._node:getChildByTag(self._currentRecordNumber)
--		    item:removeChildByTag(1)
--        end

--		self._currentRecordNumber = self._currentRecordNumber + 1
--		if self._currentRecordNumber > MaxItem then
--			self._currentRecordNumber = MaxItem
--		end

--		local pos = self:getPos(self._currentRecordNumber)
--		cc.Sprite:create("game/gamerecord_"..type..".png")
--				 :move(cc.p(pos.x,pos.y))
--				 :setTag(self._currentRecordNumber)
--				 :setScale(0.1)
--				 :addTo(self._node,1)
--				 :runAction(cc.Sequence:create(cc.ScaleTo:create(0.5,1),cc.CallFunc:create(function(sender)
--				 		cc.Sprite:create("game/gamerecordnew.png")
--				 		:move(cc.p(12,20.5))
--				 		:setTag(1)
--				 		:addTo(sender,1)
--				 	end)))

--	end
--	--如果达到承受上限
--	if self._currentRecordNumber == MaxItem then
--		--删除第一个	
--		for i = 1, MaxItem do
--			local item = self._node:getChildByTag(i)
--			--挨个挨个移动
--			if i == 1 then
--				item:removeFromParent()
--			else
--				local itempos = self:getPos(i - 1)
--				if i == MaxItem then
--					item:removeChildByTag(1)
--				end
--				item:runAction(cc.Sequence:create(cc.MoveTo:create(0.5,cc.p(itempos.x,itempos.y)),
--					cc.CallFunc:create(function()
--						item:setTag(i - 1)
--						end)
--					))

--			end

--		end
--	end
--	addspr()
end

function GameRecord:GameRecordList()
	if nil == self._delegate then
		return
	end

--	local mgr = self._delegate:getDataMgr()
--	--统计数据
--	local vec = mgr:getRecords()
--	self._currentRecordNumber = #vec
--	local beginPosX, beginPosY = 28, 180
--	local offsetX, offsetY = 62, 40
--	for i = 1, self._currentRecordNumber do
--		local rec = vec[i]
--		local pos = self:getPos(i)
--		local spr = cc.Sprite:create("game/gamerecord_"..rec.m_cbGameResult..".png")
--				 :move(cc.p(pos.x,pos.y))
--				 :setTag(i)
--				 :addTo(self._node,1)
--		if i == self._currentRecordNumber then
--			cc.Sprite:create("game/gamerecordnew.png")
--				 :move(cc.p(12,20.5))
--				 :setTag(1)
--				 :addTo(spr,1)
--		end
--	end
end


return GameRecord