--帮助页面

local HelpScene = class("HelpScene",function(scene)
	local HelpScene =  display.newLayer()
return HelpScene
end)
local ExternalFun =  appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

function HelpScene:ctor(scene)
	--注册node事件
	ExternalFun.registerNodeEvent(self)

	self._scene = scene
	self:initdata()
	self:initUi()
end
function HelpScene:initdata(  )
	self.RESOURCE_FILENAME = "HelpLayer.csb"--需要加载的界面

	self.btn_back = nil  --返回按钮

	self.bg_sprite_1 = nil --背景图片1
	self.bg_sprite_2 = nil --背景图片2
	self.bg_sprite_3 = nil --背景图片3
	self.bg_sprite_4 = nil --背景图片4

	self.btn_Button1 = nil --底部按钮1
	self.btn_Button2 = nil --底部按钮2
	self.btn_Button3 = nil --底部按钮3
	self.btn_Button4 = nil --底部按钮4

	self.pageView = nil
	self.textures = {}

	self.n_helpIndex = 1
end
function HelpScene:initUi(  )


	self._csbNode = cc.CSLoader:createNode("HelpLayer.csb")
					:addTo(self, 1)
	--初始化控件
	self.btn_back = self._csbNode:getChildByName("btn_back")
	self.pageView = self._csbNode:getChildByName("page_view")
	self.btn_Button1 = self._csbNode:getChildByName("btn_1")
	self.btn_Button2 = self._csbNode:getChildByName("btn_2")
	self.btn_Button3 = self._csbNode:getChildByName("btn_3")
	self.btn_Button4 = self._csbNode:getChildByName("btn_4")
	--self.btn_Button1:setBright(false)
	self.bg_sprite_1=cc.Sprite:create("help/bang1.png")
	self.bg_sprite_2=cc.Sprite:create("help/bang2.png")
	self.bg_sprite_3=cc.Sprite:create("help/bang3.png")
	self.bg_sprite_4=cc.Sprite:create("help/bang4.png")

	self.textures={self.bg_sprite_1,self.bg_sprite_2,self.bg_sprite_3,self.bg_sprite_4}

	for i,sp in pairs (self.textures or {}) do
		sp:setAnchorPoint(0,0)
		local layout = ccui.Layout:create()
		layout:setContentSize(cc.size(1334, 750))
		layout:addChild(sp)
		self.pageView:addPage(layout)
	end


	local function pageViewEvent(sender, eventType)
		print("进来")
	    if eventType == ccui.PageViewEventType.turning then
	    	local pageView = sender
	        self.n_helpIndex = pageView:getCurPageIndex() + 1
			self:onChange()
	    end
	end
	self.pageView:addEventListener(pageViewEvent)
	  
	 --添加事件监听
	self:addlistener()
end

--添加事件监听
function HelpScene:addlistener()
	--返回
	self.btn_back:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioEngine.playEffect("mp3/Button.mp3")
		elseif eventType == ccui.TouchEventType.ended then
			self:setVisible(false)
    		self:removeAllChildren()
    		self:removeFromParent()
		end
	end) 
end

function HelpScene:onChange()
	print("滑动漏"..self.n_helpIndex)
	if self.n_helpIndex == 1 then
		self:SetVisible(false,true,true,true)
	elseif self.n_helpIndex == 2 then
		self:SetVisible(true,false,true,true)
	elseif self.n_helpIndex == 3 then
		self:SetVisible(true,true,false,true)
	elseif self.n_helpIndex == 4 then
		self:SetVisible(true,true,true,false)
	end
end 

function HelpScene:SetVisible(b_Visible1,b_Visible2,b_Visible3,b_Visible4)
	self.btn_Button1:setBright(b_Visible1)
	self.btn_Button2:setBright(b_Visible2)
	self.btn_Button3:setBright(b_Visible3)
	self.btn_Button4:setBright(b_Visible4)
end

return HelpScene
