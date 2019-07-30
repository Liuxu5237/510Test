--[[
    字游戏喇叭
       
    功能：播放维护公告 
]]
local GameNotice = class("GameNotice", function(msg)
	local gameNotice = display.newLayer()
return gameNotice
end)

--msg 显示信息

--实现单例
GameNotice._instance = nil
function GameNotice:getInstance(  )
	if nil == GameNotice._instance then
		print("new instance")
		GameNotice._instance = GameNotice:create()
	end
	return GameNotice._instance
end

function GameNotice:ctor(msg,pos)

	self.isAllFalse  = false 

	self.txtList = {}
	self.colorList = {}
	self.isWorking = false
	self._msg  = nil

	self._spbg = cc.Sprite:create("sp_trumpet_bg.png")
	self._spbg:setPosition(pos)
	self._spbg:setAnchorPoint(cc.p(0.5,0.5))
	self._spbg:addTo(self)

	self._icon = cc.Sprite:create("img_trumpet.png")
	self._icon:setPosition(cc.p(214,24))
	self._icon:setAnchorPoint(cc.p(0.5,0.5))
	self._icon:addTo(self._spbg)

	self._layout = ccui.Layout:create()
	self._layout:setContentSize(cc.size(575,30))
	self._layout:setPosition(cc.p(237,13))
	self._layout:setAnchorPoint(cc.p(0,0))
	self._layout:setClippingEnabled(true)
	self._layout:setTouchEnabled(true)
	self._layout:addTo(self._spbg)

	self._trutxt = cc.Label:createWithTTF(tostring(msg), "fonts/round_body.ttf", 24)
	self._trutxt:setAnchorPoint(cc.p(0,0.5))
	self._trutxt:setPosition(cc.p(20,12))
	self._trutxt:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	self._trutxt:addTo(self._layout)

	self:hidden()

	self.Timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function (  )
		if self.txtList ~= nil then
			if #self.txtList > 0 and self.isWorking == false then
				local msg = self.txtList[1]	
				table.remove( self.txtList,1 )
				local color = self.colorList[1]
				table.remove(self.colorList,1)
				self:showTrugTxt(msg,color)
			end
		end
		
	end, 1/60, false)
end


function GameNotice:setAllFalse( isfalse  )
	self.isAllFalse = isfalse
end

function GameNotice:getIsWorking(  )
	return self.isWorking
end

function GameNotice:closeTime( )
	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.Timer)
	self:dismiss()
end

function GameNotice:addTrugTxt(msg,type)
	table.insert( self.txtList ,msg )
	if type == nil  then
		type = 0
	end
	table.insert( self.colorList , type)
end

--取消消失
function GameNotice:showTrugTxt(msg ,color)
	
	if #msg <=0	 then
		return
	end

	if self.isWorking == true then
		return
	end

	
	--更新内容
	self:show()
	self.isWorking = true
	self._trutxt:setString(tostring(msg))
	if color == 1 then
		self._trutxt:setTextColor(cc.YELLOW)
	else
		self._trutxt:setTextColor(cc.WHITE)
	end
	
	local containerWidth = self._trutxt:getParent():getContentSize().width
	local contentSize = self._trutxt:getContentSize()
	--初始化位置
	self._trutxt:setPosition(containerWidth, 12)
	
	--更新动画
	self._trutxt:stopAllActions()
	self._trutxt:runAction(
		--cc.RepeatForever:create(
			cc.Sequence:create(
				cc.CallFunc:create(function() self._trutxt:setPosition(containerWidth, 12) end),
				cc.MoveBy:create(7 + contentSize.width / 80, cc.p(-contentSize.width - containerWidth, 0))
				,cc.CallFunc:create(function() 
					self:hidden() 
					
					self.isWorking = false 				
				end)
			)
		--)
	)

end

function GameNotice:hidden()
	self:setVisible(false)
end

function GameNotice:show(  )
	if self.isAllFalse == false then
		self:setVisible(true)
	end
end

function GameNotice:dismiss()
	self:stopAllActions()
	self:removeFromParent()
end

return GameNotice
