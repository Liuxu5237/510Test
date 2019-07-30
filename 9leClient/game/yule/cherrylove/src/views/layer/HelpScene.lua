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

local MAXZORDER=100

function HelpScene:initdata()
	self.RESOURCE_FILENAME = "HelpLayer.csb"
	
	self.btn_Button1=nil
	self.btn_Button2=nil
	self.btn_Button3=nil
	self.btn_back=nil
	self.btn_Show=nil
	self.btn_Hide=nil
	self.n_helpIndex =1
	
	self.sp_help1=nil
	self.sp_help2=nil
	self.sp_help3=nil
	self.sp_help4=nil
	self.textures = nil
	self.pageView= nil 
	self.help4_Y = 1122
end	

function HelpScene:initUi()

	self._csbNode = cc.CSLoader:createNode("HelpLayer.csb")
			:addTo(self, 1)
	--require("app.views.system"):SetVisible(self._self,false);
	--require("app.views.system"):setBtnVisible(self._self,false);
	self.n_helpIndex =1
	self.help4_Y = 1122
	
	self.sp_help=self._csbNode:getChildByName("sp_help") 
	if self.sp_help then 
		self.sp_help:setVisible(false)
	end 
	self.pageView=self._csbNode:getChildByName("pv") 
	self.sp_help1=cc.Sprite:create("help/imageHelp1.png") 
	self.sp_help2=cc.Sprite:create("help/imageHelp2.png") 
	self.sp_help3=cc.Sprite:create("help/imageHelp3.png") 
	self.sp_help4=self._csbNode:getChildByName("imageHelp4") 
	self.sp_help1:setScaleX(1.67);
	self.sp_help1:setScaleY(1.25);
	self.sp_help2:setScaleX(1.67);
	self.sp_help2:setScaleY(1.25);
	self.sp_help3:setScaleX(1.67);
	self.sp_help3:setScaleY(1.25);
	
	self.sp_help4:setPosition(667,self.help4_Y)
	self.sp_help4:setScaleX(1.67);
	self.sp_help4:setScaleY(1.25);
	self.textures ={self.sp_help1,self.sp_help2,self.sp_help3}
	
	for i,sp in pairs (self.textures or {}) do 
		sp:setAnchorPoint(0,0);
		local layout = ccui.Layout:create()
		layout:setContentSize(cc.size(1334, 750))
		layout:addChild(sp);
		self.pageView:addPage(layout)
	end  

	self.btn_back=self._csbNode:getChildByName("btn_back") 
	self.btn_Show=self._csbNode:getChildByName("btn_Show") 
	self.btn_Hide=self._csbNode:getChildByName("btn_Hide") 
	self.btn_Button1=self._csbNode:getChildByName("Button_1") 
	self.btn_Button2=self._csbNode:getChildByName("Button_2") 
	self.btn_Button3=self._csbNode:getChildByName("Button_3") 
	-- self.btn_Button1:setEnabled(false)
	-- self.btn_Button1:setBright(false) 
		
	self.btn_Button1:setLocalZOrder(MAXZORDER)
	self.btn_Button2:setLocalZOrder(MAXZORDER)
	self.btn_Button3:setLocalZOrder(MAXZORDER)
	self.btn_back:setLocalZOrder(MAXZORDER)
	self.btn_Show:setLocalZOrder(MAXZORDER)
	self.btn_Hide:setLocalZOrder(MAXZORDER)

	local function pageViewEvent(sender, eventType)
        if eventType == ccui.PageViewEventType.turning then
            local pageView = sender
            self.n_helpIndex = pageView:getCurPageIndex() + 1
			self:onChange()
        end
    end 

    self.pageView:addEventListener(pageViewEvent)
	self:addlistener()
	
end



function HelpScene:Onhelp4Dowm()
	if self.help4_Y <= 375 then
		self:OnBackEnabled(true);
		self:OnHideVisible(true);
		self:OnHideEnabled(true);	
		return;
	end

	self.help4_Y = self.help4_Y - 50
	self.sp_help4:setPosition(667,self.help4_Y)
	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.01),cc.CallFunc:create(function()
		self:Onhelp4Dowm()
	end),nil))
end

function HelpScene:Onhelp4Up()
	if self.help4_Y >= 1122 then
		self:OnBackEnabled(true);
		self:OnShowEnabled(true);
		self:OnHideVisible(false);
		return;
	end


	self.help4_Y = self.help4_Y + 50
	self.sp_help4:setPosition(667,self.help4_Y)
	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.01),cc.CallFunc:create(function()
		self:Onhelp4Up()
	end),nil))
end

function HelpScene:addlistener()
	--·µ»Ø
	self.btn_back:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioEngine.playEffect("mp3/Button.mp3")
			self:setVisible(false)
    		self:removeAllChildren()
    		self:removeFromParent()
			--cc.Director:getInstance():popScene()
			--require("app.views.system").b_showHelp = false ;
		end
	end)
	--Show
	self.btn_Show:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioEngine.playEffect("mp3/Button.mp3")
			self:OnBackEnabled(false)
			self:OnShowEnabled(false)	
			self:Onhelp4Dowm()
		end
	end)

	--Hide
	self.btn_Hide:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioEngine.playEffect("mp3/Button.mp3")
			self:OnBackEnabled(false)
			self:OnHideEnabled(false)	
			self:Onhelp4Up()
		end
	end)
end

function HelpScene:onChange()
	if self.n_helpIndex == 1 then 
		self:SetVisible(false,true,true,true);
	elseif self.n_helpIndex == 2 then 
		self:SetVisible(true,false,true,true)
	elseif self.n_helpIndex == 3 then 
		self:SetVisible(true,true,false,true)
	end
end 

function HelpScene:SetVisible(b_Visible1,b_Visible2,b_Visible3,b_Visible4)
	self.btn_Button1:setEnabled(b_Visible1);
	self.btn_Button1:setBright(b_Visible1);
	self.btn_Button2:setEnabled(b_Visible2);
	self.btn_Button2:setBright(b_Visible2);
	self.btn_Button3:setEnabled(b_Visible3);
	self.btn_Button3:setBright(b_Visible3);
end

function HelpScene:OnBackEnabled(b_Enabled)
	self.btn_back:setEnabled(b_Enabled);
	self.btn_back:setBright(b_Enabled);
end

function HelpScene:OnShowEnabled(b_Enabled)
	self.btn_Show:setEnabled(b_Enabled);
	self.btn_Show:setBright(b_Enabled);
end

function HelpScene:OnHideEnabled(b_Enabled)
	self.btn_Hide:setEnabled(b_Enabled);
	self.btn_Hide:setBright(b_Enabled);

end

function HelpScene:OnHideVisible(b_Visible)
	self.btn_Hide:setVisible(b_Visible);
end
 
return HelpScene
