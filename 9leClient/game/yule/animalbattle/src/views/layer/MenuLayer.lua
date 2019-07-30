local module_pre = "game.yule.animalbattle.src"
local ExternalFun =  appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

local SettingLayer = appdf.req(module_pre .. ".views.layer.SettingLayer")
local BankLayer=appdf.req(module_pre .. ".views.layer.BankLayer")

local PlayerlistLayer=appdf.req(module_pre .. ".views.layer.PlayerlistLayer")

local MenuLayer=class("MenuLayer",cc.Layer)
local popZorder=10
function MenuLayer:ctor(scene,menuX,menuY)
	

	menubg = cc.Sprite:create("im_menu_bg.png")
	menubg:setAnchorPoint(cc.p(0,1))
	menubg:setPosition(cc.p(21,663))
	self:addChild(menubg)

	--introBtn=ccui.Button:create("introbtn.png","introbtndown.png")
	setBtn=ccui.Button:create("bt_set_0.png","bt_set_1.png")
	qiutBtn = ccui.Button:create("bt_qiut_0.png","bt_qiut_1.png")
	helpBtn=ccui.Button:create("bt_help_0.png","bt_help_1.png")
	--bankBtn=ccui.Button:create("bt_bank_0.png","bt_bank_1.png")
	--playerBtn=ccui.Button:create("playerbtn.png","playerbtndown.png")

	helpBtn:setPosition(cc.p(90,166))
	--bankBtn:setPosition(cc.p(90,166))
	--playerBtn:setPosition(menuX,menuY-2*h)
	--introBtn:setPosition(menuX,menuY-3*h)
	
	setBtn:setPosition(cc.p(90,105))
	qiutBtn:setPosition(cc.p(90,42))

	--introBtn:addClickEventListener(function() self:removeSelf()  scene._scene._scene:popHelpLayer(yl.HTTP_URL .. "/Mobile/Introduce.aspx?kindid=123&typeid=0") end)
	setBtn:addClickEventListener(function()  self:removeSelf() 
		local set = SettingLayer:create(scene,popZorder)
        scene:addChild(set, popZorder)
		  end)

	qiutBtn:addClickEventListener(function()  self:removeSelf() 
		scene._scene:onKeyBack()
		end)

		  
	--playerBtn:addClickEventListener(function() self:removeSelf() scene:addChild(PlayerlistLayer:create(scene:getPlayerList()),popZorder) end )

	-- bankBtn:addClickEventListener(function() 
	-- self:removeSelf() 
	-- if 0 == GlobalUserItem.cbInsureEnabled then
   	--  	showToast(scene, "初次使用，请先开通银行！", 1)
    -- 	return 
	-- end
	-- scene._bankLayer=BankLayer:create(scene) 
	-- scene:addChild(scene._bankLayer,popZorder) 
	-- end )

	helpBtn:addClickEventListener(function() 
		self:removeSelf() 
		showPopupLayer( BankLayer:create(scene) , false)
	end )

	--self:addChild(playerBtn)
	menubg:addChild(helpBtn)
	--self:addChild(introBtn)
	menubg:addChild(setBtn)
	menubg:addChild(qiutBtn)

	ExternalFun.registerTouchEvent(self,true)
	
end

function MenuLayer:onTouchBegan()
	return true
end

function MenuLayer:onTouchEnded()
	self:removeFromParent()
end

	


return MenuLayer

