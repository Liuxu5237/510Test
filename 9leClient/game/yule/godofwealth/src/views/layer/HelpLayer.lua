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
			if self._delegate.MusicTemp then
				AudioEngine.playEffect("mp3/Button.mp3")
			end
		elseif eventType == ccui.TouchEventType.ended then
			self._delegate.b_showHelp = false
			self:removeFromParent()
			
		end
	end) 

		--右
	self.btn_right:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			--AudioEngine.playEffect("mp3/Button.mp3")
			if self.n_helpIndex < 3 then
				self.n_helpIndex = self.n_helpIndex + 1 
				self:onChange()
				self.PageView:scrollToPage(self.n_helpIndex-1)
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
				self.PageView:scrollToPage(self.n_helpIndex-1)
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
	local csbNode = cc.CSLoader:createNode("HelpLayer.csb")
	csbNode:addTo(self)
	self.n_helpIndex = 1
	self = self;
	--self._delegate:setBtnVisbel(self,false);
	--初始化控件  
	self.btn_back=csbNode:getChildByName("btn_back")
	self.PageView=csbNode:getChildByName("PageView")
	self.btn_right=csbNode:getChildByName("btn_right") 
	self.btn_left=csbNode:getChildByName("btn_left") 
	self.btn_left:setEnabled(false)
	self.btn_left:setBright(false) 

	self.sp_help1=cc.Sprite:create("help/HelpBG_01.png")
	-- self.sp_help1:setScaleX(1.25);
	-- self.sp_help1:setScaleY(0.94);
	self.sp_help2=cc.Sprite:create("help/HelpBG_02.png")
	-- self.sp_help2:setScaleX(1.25);
	-- self.sp_help2:setScaleY(0.94);
	self.sp_help3=cc.Sprite:create("help/HelpBG_03.png")
	-- self.sp_help3:setScaleX(1.25);
	-- self.sp_help3:setScaleY(0.94);
	self.textures ={self.sp_help1,self.sp_help2,self.sp_help3}
	for i,sp in pairs (self.textures or {}) do 
		sp:setAnchorPoint(0,0);
		local layout = ccui.Layout:create()
		layout:setContentSize(cc.size(1334, 750))
		layout:addChild(sp);
		self.PageView:addPage(layout)
	end	

	local function pageViewEvent(sender, eventType)
        if eventType == ccui.PageViewEventType.turning then
            local pageView = sender
            self.n_helpIndex = pageView:getCurPageIndex() + 1
			self:onChange()
        end
	end
	
 	self.PageView:addEventListener(pageViewEvent)
	--添加事件监听
	self:addlistener()
	
end   
return HelpLayer
