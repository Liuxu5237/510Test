--
-- Author: luo
-- Date: 2016年12月26日 20:24:43
--
local HelpLayer = class("HelpLayer", cc.Layer)
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")

HelpLayer.BT_HOME = 1

function HelpLayer:ctor( )
    
    local page = ccui.PageView:create()
  	local x,y = yl.WIDTH/2,yl.HEIGHT/2
  	for i = 1, 4 do	
  	 	local layout=ccui.Layout:create()
        layout:setContentSize(yl.WIDTH,yl.WIDTH)	
    	local spHelp = display.newSprite("loading/preBg_0"..i..".png")
    	spHelp:setPosition(x,y)
    	layout:setPosition(x,y)
    	spHelp:addTo(layout)
    	page:addPage(layout)
	end
	page:setContentSize(yl.WIDTH,yl.WIDTH)
    page:setTouchEnabled(true)
    page:setAnchorPoint(cc.p(0,0))
    page:setPosition(0,0)
    --注册事件
    page:addEventListener(function(sender,event)
        if event==ccui.PageViewEventType.turning then
            --self:setName(page:getCurPageIndex())
        	print("45646546546549879873216245")
        end
    
    end)
    page:addTo(self)

	local function btnEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			local tag = sender:getTag()
			if HelpLayer.BT_HOME == tag then
				ExternalFun.playClickEffect()
				self:removeFromParent()
			end
		end
	end
	ccui.Button:create("game1_back_1.png", "game1_back_2.png", "p_bt_close_1.png")
	:move(yl.WIDTH -  50, yl.HEIGHT - 50)
	:setTag(HelpLayer.BT_HOME)
	:addTo(self)
	:addTouchEventListener(btnEvent)

	local homePage = 0
	ccui.Button:create("loading/bt_nextpage.png")
	:move(yl.WIDTH - 50,yl.HEIGHT / 2)
	:addTo(self)
	:addClickEventListener(function()
		ExternalFun.playClickEffect()
		homePage = page:getCurrentPageIndex()
		if homePage < 0 then
			homePage = 0
		end
		homePage = homePage + 1
		if homePage > 3 then
			homePage = 3
		end
		page:scrollToPage(homePage)
		end)

	ccui.Button:create("loading/bt_uppage.png")
	:move(50,yl.HEIGHT / 2)
	:addTo(self)
	:addClickEventListener(function()
		ExternalFun.playClickEffect()
		homePage = page:getCurrentPageIndex()
		homePage = homePage - 1
		if homePage < 0 then
			homePage = 0
		end
		page:scrollToPage(homePage)
		end)
end
return HelpLayer