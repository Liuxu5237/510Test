--
-- Author: Hello World
-- Date: 2018-08-04 16:12:51
--
local HeadBackground = class("HeadBackground", cc.Node)

function HeadBackground:ctor()
	self.headbackground = cc.Sprite:createWithSpriteFrameName("Brnn_online_iconBg.png")
	:addTo(self)
    self.size = self.headbackground:getContentSize()
    self.twostate_headbackground = cc.Sprite:createWithSpriteFrameName("Brnn_Room_Table_Head_Bg_Boy.png")
    :addTo(self.headbackground)
    :align(display.CENTER, self.size.width/2, self.size.height/2)
end

return HeadBackground