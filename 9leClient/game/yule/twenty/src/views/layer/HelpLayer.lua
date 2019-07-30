--帮助页面
local HelpLayer = class("HelpLayer", cc.Layer)



function HelpLayer:ctor(delegate)
	self._delegate = delegate 
	self.btn_right=nil --右
	self.btn_left=nil  --左
	self.btn_back=nil  --返回按钮
	self.PageView=nil  --滚动容器

	self.n_helpIndex =1   --当前页面

	self.sp_help1=nil --帮助1
	self.sp_help2=nil --帮助2
	self.sp_help3=nil --帮助3
	self.textures = nil
	self:initui()
end

--添加事件监听
function HelpLayer:addlistener()
	--返回
	self.btn_back:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioEngine.playEffect("Voice/Button.mp3")
		elseif eventType == ccui.TouchEventType.ended then
            self._delegate:OnCloseHelp()
			self:removeFromParent()
		end
	end) 
		--右
	self.btn_right:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			--AudioEngine.playEffect("mp3/Button.mp3")
			if self.n_helpIndex < 4 then
				self.n_helpIndex = self.n_helpIndex + 1 
				self:onChange()
				self.pageView:scrollToPage(self.n_helpIndex-1)
			end
		end
	end)
	--左
	self.btn_left:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			--AudioEngine.playEffect("mp3/Button.mp3")
			if self.n_helpIndex > 1 then
				self.n_helpIndex = self.n_helpIndex - 1 
				self:onChange()
				self.pageView:scrollToPage(self.n_helpIndex-1)
			end
		end
	end)
end

function HelpLayer:onChange()
		if(self.n_helpIndex==1)then 
			self.btn_left:setEnabled(false)
			self.btn_left:setBright(false)  
		end  
		if(self.n_helpIndex==3)then 
			self.btn_right:setEnabled(false)
			self.btn_right:setBright(false)
		end  
		if(self.n_helpIndex>1 and self.n_helpIndex <3) then 
			self.btn_left:setEnabled(true)
			self.btn_left:setBright(true)  
			self.btn_right:setEnabled(true)
			self.btn_right:setBright(true)  
		end 
end

function HelpLayer:initui()

    self.csbNode = cc.CSLoader:createNode("HelpScene.csb")
	self.csbNode:addTo(self)
	self.n_helpIndex = 1
	self._self=self;

	--初始化控件  
	self.sp_help=self.csbNode:getChildByName("sp_help") 
	if self.sp_help then 
		self.sp_help:setVisible(false)
	end 
	self.pageView=self.csbNode:getChildByName("pv") 

	self.sp_help1=cc.Sprite:create("Help/1.png")
	self.sp_help2=cc.Sprite:create("Help/2.png")
	self.sp_help3=cc.Sprite:create("Help/3.png")
	--self.sp_help4=cc.Sprite:create("Help/4.png")
	self.textures ={self.sp_help1,self.sp_help2,self.sp_help3,--[[self.sp_help4]]}
	for i,sp in pairs (self.textures or {}) do 
		sp:setAnchorPoint(0,0);
		local layout = ccui.Layout:create()
		layout:setContentSize(cc.size(810, 440))
		layout:addChild(sp);
		self.pageView:addPage(layout)
	end	
	self.btn_right=self.csbNode:getChildByName("btn_right") 
	self.btn_back=self.csbNode:getChildByName("btn_back") 
	self.btn_left=self.csbNode:getChildByName("btn_left") 
	self.btn_left:setEnabled(false)
	self.btn_left:setBright(false) 
 
 	local function pageViewEvent(sender, eventType)
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
return HelpLayer
