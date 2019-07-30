--
-- Author: zhouweixiang
-- Date: 2016-12-27 16:03:00
--
--游戏记录
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

local GameRecordLayer = class("GameRecordLayer", cc.Layer)
GameRecordLayer.BT_CLOSE = 1

function GameRecordLayer:ctor(viewParent)
	self.m_parent = viewParent

	--加载csb资源
	local csbNode = ExternalFun.loadCSB("LudanLayer.csb", self)

	local sp_bg = csbNode:getChildByName("im_ludan_bg")
	self.m_spBg = sp_bg
	--关闭按钮
	local function btnEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			self:onButtonClickedEvent(sender:getTag(), sender);
		end
	end

	local btn = sp_bg:getChildByName("bt_close")
	btn:setTag(GameRecordLayer.BT_CLOSE)
	btn:addTouchEventListener(btnEvent)

	local layoutbg = csbNode:getChildByName("layout_bg")
	layoutbg:setTag(GameRecordLayer.BT_CLOSE)
	-- layoutbg:addTouchEventListener(btnEvent)

	--
	self.m_content = sp_bg:getChildByName("layout_content")
	self.m_content:setScrollBarEnabled(false)

	self.kuang = sp_bg:getChildByName("taindixuanhuang")
	self.kuang:setCascadeOpacityEnabled(false)
	self.kuang:setOpacity(0)
end

function GameRecordLayer:onButtonClickedEvent( tag, sender )
	ExternalFun.playClickEffect()
	if GameRecordLayer.BT_CLOSE == tag then
		self:setVisible(false)
	end
end

function GameRecordLayer:refreshRecord(vecRecord)
	self:setVisible(true)
	if nil == vecRecord then
		return
	end
	self.m_content:removeAllChildren()

	for i,v in ipairs(vecRecord) do
		local pimage = cc.Sprite:createWithSpriteFrameName("im_ludan_win.png")
		if v.bWinTianMen == false then
			pimage:setSpriteFrame("im_ludan_failure.png")
		end
		pimage:setPosition(27+(i-1)*99, 93*3 + 43)
		self.m_content:addChild(pimage)

		pimage = cc.Sprite:createWithSpriteFrameName("im_ludan_win.png")
		if v.bWinDiMen == false then
			pimage:setSpriteFrame("im_ludan_failure.png")
		end
		pimage:setPosition(27+(i-1)*99, 93*2 + 43)
		self.m_content:addChild(pimage)

		pimage = cc.Sprite:createWithSpriteFrameName("im_ludan_win.png")
		if v.bWinXuanMen == false then
			pimage:setSpriteFrame("im_ludan_failure.png")
		end
		pimage:setPosition(27+(i-1)*99, 93 + 43)
		self.m_content:addChild(pimage)

		pimage = cc.Sprite:createWithSpriteFrameName("im_ludan_win.png")
		if v.bWinHuangMen == false then
			pimage:setSpriteFrame("im_ludan_failure.png")
		end
		pimage:setPosition(27+(i-1)*99, 43)	
		self.m_content:addChild(pimage) 

		if i == 15 then
			self.m_content:removeChildByTag(i-1, true) 
			self.m_content:removeChildByTag(i, true)
			local node = cc.Sprite:createWithSpriteFrameName("Brnn_Record_xuanzhong.png"):setScaleX(1.1):setTag(i)
			self.m_content:addChild(node)
			node:setPosition(27+(i-1)*99, 93 + 43)
			self.m_content:jumpToBottom()
		else
			self.m_content:removeChildByTag(i-1, true) 
			local node = cc.Sprite:createWithSpriteFrameName("Brnn_Record_xuanzhong.png"):setScaleX(1.1):setTag(i)
			self.m_content:addChild(node)
			node:setPosition(24+(i-1)*99, 181)
		end
	end
	self.m_content:scrollToRight(0, false)
end

return GameRecordLayer