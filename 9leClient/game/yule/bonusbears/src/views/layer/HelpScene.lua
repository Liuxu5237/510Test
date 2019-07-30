 
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
function HelpScene:initdata(  )
	self.RESOURCE_FILENAME = "HelpLayer.csb"

	self.btn_Button1=nil
	self.btn_Button2=nil
	self.btn_back=nil
	self.n_helpIndex =1

	self.sp_help1=nil
	self.sp_help2=nil

	self.textures = nil
	self.pageView= nil 
	self.help4_Y = 1100
end

function HelpScene:initUi(  )
	self._csbNode = cc.CSLoader:createNode("HelpLayer.csb")
					:addTo(self, 1)

	self.n_helpIndex =1
	self.help4_Y = 1100
	
	self.sp_help=self._csbNode:getChildByName("sp_help") 
	if self.sp_help then 
		self.sp_help:setVisible(false)
	end 
	self.pageView=self._csbNode:getChildByName("pv") 
	self.sp_help1=cc.Sprite:create("help/imageHelp1.png") 
	self.sp_help2=cc.Sprite:create("help/imageHelp2.png") 
	-- self.sp_help1:setScaleX(1.6);
	-- self.sp_help1:setScaleY(1.2);
	-- self.sp_help2:setScaleX(1.6);
	-- self.sp_help2:setScaleY(1.2);

	self.textures ={self.sp_help1,self.sp_help2}
	
	for i,sp in pairs (self.textures or {}) do 
		sp:setAnchorPoint(0,0);
		sp:setScaleX(1.04)
		sp:setScaleY(1.08)
		local layout = ccui.Layout:create()
		layout:setContentSize(cc.size(1334, 750))
		layout:addChild(sp);
		self.pageView:addPage(layout)
	end  

	self.btn_back=self._csbNode:getChildByName("btn_back") 
	
	self.btn_Button1=self._csbNode:getChildByName("Button_1") 
	self.btn_Button2=self._csbNode:getChildByName("Button_2") 
	--self.btn_Button1:setEnabled(false)
	--self.btn_Button1:setBright(false) 
		
	self.btn_Button1:setLocalZOrder(MAXZORDER)
	self.btn_Button2:setLocalZOrder(MAXZORDER)
	self.btn_back:setLocalZOrder(MAXZORDER)

	local function pageViewEvent(sender, eventType)
        if eventType == ccui.PageViewEventType.turning then
            local pageView = sender
            self.n_helpIndex = pageView:getCurPageIndex() + 1
			self:onChange()
        end
    end 

    self.pageView:addEventListener(pageViewEvent)
	--Ìí¼ÓÊÂ¼þ¼àÌý
	self:addlistener()
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
end

function HelpScene:onChange()
	if self.n_helpIndex == 1 then 
		self:SetVisible(false,true,true,true);
	elseif self.n_helpIndex == 2 then 
		self:SetVisible(true,false,true,true)
	end
end 

function HelpScene:SetVisible(b_Visible1,b_Visible2,b_Visible3,b_Visible4)
	self.btn_Button1:setEnabled(b_Visible1);
	self.btn_Button1:setBright(b_Visible1);
	self.btn_Button2:setEnabled(b_Visible2);
	self.btn_Button2:setBright(b_Visible2);
end

function HelpScene:OnBackEnabled(b_Enabled)
	self.btn_back:setEnabled(b_Enabled);
	self.btn_back:setBright(b_Enabled);
end

return HelpScene
