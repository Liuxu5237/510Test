--
-- Author: Hello World
-- Date: 2018-07-14 17:25:07
--规则界面
local GameRuleLayer = class("GameRuleLayer", cc.Layer)
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

function GameRuleLayer:ctor()
	--加载csb资源
	local csbNode = ExternalFun.loadCSB("HelpLayer.csb", self) 

	local function btnEvent( sender, eventType )
		if eventType == ccui.TouchEventType.began then
            sender:setScale(1.05) 
        end
        if eventType == ccui.TouchEventType.canceled then
            sender:setScale(1.00) 
        end
		if eventType == ccui.TouchEventType.ended then
			sender:setScale(1.00)
            self:removeFromParent()
        end
	end
	--规则背景图
	local rule_bg = csbNode:getChildByName("rule_bg")


	local rule_scrollview = rule_bg:getChildByName("rule_scrollview")
	rule_scrollview:setScrollBarEnabled(false) 
	--关闭按钮
	local btn_close = rule_bg:getChildByName("btn_close")
	btn_close:addTouchEventListener(btnEvent)

	--关闭触控
    self:setTouchEnabled(true)
    self:registerScriptTouchHandler(function (event,x,y)
        return true
    end)
end

return GameRuleLayer