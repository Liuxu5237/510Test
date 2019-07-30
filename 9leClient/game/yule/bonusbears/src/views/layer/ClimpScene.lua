
local ClimpScene = class("ClimpScene",function(scene)
	local ClimpScene =  display.newLayer()
return ClimpScene
end)
local ExternalFun =  appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local rect_trees ={
	cc.rect(166,150,60,690)
   ,cc.rect(400,150,60,690)
   ,cc.rect(624,150,60,690)
   ,cc.rect(832,150,96,690)
   ,cc.rect(1110,150,60,690)
   } 
   
   -- local branchs={ --0表示左边1右边 
   -- 	{
   -- 		{0,-260},{0,-730},{1,-900},{1,-1380},{0,-1735},{1,-1873},{1,-2380}, 
   -- 	},
   -- 	{
   -- 		{1,-307},{0,-552},{0,-1044},{1,-1175},{1,-1664},{0,-2040},{1,-2170},{0,-2530} , 
   -- 	},
   -- 	{
   -- 		{1,-230},{0,-430},{1,-778} ,{1,-1280} ,	{0,-1924} , {1,-2280} , {0,-2427} ,
   -- 	},
   -- 	{
   -- 		{1,-211},{0,-524},{0,-1025} ,{1,-1142},{1,-1632} , {0,-2017} ,{1,-2137} , {0,-2507} , 
   -- 	},
   -- 	{
   -- 		{0,-362},{1,-755},{0,-860},{1,-1250} ,{1,-1740} ,{0,-1850} ,{1,-2240} , 		
   -- 	}
   -- } 
   
   local branchs={ --0表示左边1右边  
	   {
		   {0,-260},{1,-390},{0,-730},{1,-900},{0,-1240},
	   },
	   {
		   {1,-307},{0,-552},{1,-680},{0,-1044},{1,-1175},
	   },
	   {
		   {1,-230},{0,-430},{1,-778},{0,-920},{1,-1280},
	   },
	   {
		   {1,-211},{0,-524},{1,-640},{0,-1025} ,{1,-1142},
	   },
	   {
		   {1,-242},{0,-362},{1,-755},{0,-860},{1,-1250} ,{1,-1740},
	   }
   } 
   

function ClimpScene:ctor(scene)
	--注册node事件
	ExternalFun.registerNodeEvent(self)

	self._scene = scene
	self:initdata()
	self:initUi()
end

function ClimpScene:initdata(  )
	--指定创建的csb
	self.RESOURCE_FILENAME = "FreeLayer.csb"
  
	self.bear =nil 
	self.tree_bg =nil 
	self.Bouns = nil
	self.Leaf = nil

	self.pickCount=5 
	self.pickPrize=10 

	self.tab_splite=nil ;	
end

function ClimpScene:initUi(  )

	--require("app.views.system"):SetVisible(self,false);
	--require("app.views.system"):setBtnEnable(self,false);
	AudioEngine.playMusic("mp3/Bear_BJ.mp3",true)

	self.csbNode = cc.CSLoader:createNode(self.RESOURCE_FILENAME)
	:addTo(self, 1)

	self.branchIndex=1
	self.treeIndex=1
	self.yy =1 -- 爬动距离
	self.canClick =false ;

	self:initAnimCache(); 
	self._scene._scene:enterHoney();
	self.Leaf = self.csbNode:getChildByName("Leaf") 
	self.Leaf:setLocalZOrder(550)
	self.Bouns = self.csbNode:getChildByName("Bouns_1")  --进入熊爬树背景界面
	self.Bouns:setLocalZOrder(800)
	self.Bouns:setVisible(true)
	self.tree_bg = self.csbNode:getChildByName("tree_2")  
	--进入动画
	local startbg = self.csbNode:getChildByName("startbg") 
	startbg:setLocalZOrder(999)
	startbg:setVisible(true)
	startbg:setPositionX(1580)
	startbg:runAction(cc.Sequence:create(cc.EaseBackOut:create(cc.MoveBy:create(1, cc.p(-1550, 0))),cc.CallFunc:create(function()
		
	end)));
	startbg:getChildByName("btn_start"):addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioEngine.playEffect("mp3/Button.mp3")
			--ClimpScene:startClimp(4,10000)
			self.Bouns:setVisible(false)
			sender:setEnabled(false)
			self.csbNode:getChildByName("startbg"):setVisible(false)
		end
	end)
	--正常动画
	local normalAnim =cc.Animation:create()
	for i = 1 ,6 do 
		local str = string.format("Animation/normal/%d.png",i-1)
		normalAnim:addSpriteFrameWithFile(str)
	end 
	normalAnim:setDelayPerUnit(0.8/6) 
	normalAnim:setLoops(999)
	cc.AnimationCache:getInstance():addAnimation(normalAnim,"normalAnim"); 
    --local  normalAnim = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("normalAnim")) 
	self.bear = display.newSprite("Animation/normal/0.png")
	self.bear:setScaleX(1.7);
	self.bear:setScaleY(1.23);
	self.bear:setLocalZOrder(500)
    self.bear:move(709,231)
        :addTo(self.csbNode)
		:runAction(cc.Animate:create(normalAnim))
	
	--添加触摸判断
	local layer = display.newLayer()
	layer:setTouchEnabled(true)
	layer:addTo(self)
	:onTouch(handler(self,self.onTouch))
	
	 
	for i,branchs1 in pairs(branchs) do  
		for ind,point in pairs(branchs1) do 
			local sp_branch = display.newSprite("climb/branch.png") 
			if(point[1] ==0 )then 
				sp_branch:setRotationSkewY(180)
				local sp_honey = display.newSprite("climb/honey.png")
				if i < 5 then
					sp_honey:setPosition(65+(i-1)*132,(point[2]*-1)+310)
				else
					sp_honey:setPosition(65+(i-1)*140,(point[2]*-1)+310)
				end
				sp_honey:setName("x"..i.."y"..ind);
				self.tree_bg:addChild(sp_honey,999);
				
				sp_branch:setPosition(176+(i-1)*230,(point[2]*-1)+180)
			else 
				local sp_honey = display.newSprite("climb/honey.png")
				if i < 3 then
					sp_honey:setPosition(170+(i-1)*145,(point[2]*-1)+310)
				elseif i >= 3 and i < 5 then
					sp_honey:setPosition(170+(i-1)*137,(point[2]*-1)+310)
				else
					sp_honey:setPosition(170+(i-1)*142,(point[2]*-1)+310)
				end
				sp_honey:setName("x"..i.."y"..ind);
				self.tree_bg:addChild(sp_honey,999);
				
				sp_branch:setPosition(186+(i-1)*229,(point[2]*-1)+180)
			end
			sp_branch:setAnchorPoint(0,0)
			self.tree_bg:addChild(sp_branch)
		end
	end 
	 

end


function ClimpScene:splite(_pickCount,_pickPrize)
	 if(_pickPrize==0) then 
		return 	{0};
	 end
	 local tab={}		
	 local _count =_pickCount
	 local prize =_pickPrize
	 local yushu = prize%_count
	 local pingjun = (prize-yushu)/_count;
	 local rand = 0;
	 for i =1,_count do 
		if(rand==0)then  
			rand = math.random(1,pingjun*0.8)
			table.insert(tab, pingjun-rand )
		else  	
			table.insert(tab, pingjun+rand )
			rand=0		
		end 
	 end
	 tab[1] =tab[1]+ yushu
	 if(rand ~= 0) then 
			tab[_count] =tab[_count]+ rand
	 end 
	 for i = 1, _count do
		print("第 "..i.." 次:"..tab[i]*100) 
	 end
	return 	tab;	
end 



function ClimpScene:startClimp(_pcount,_pprize)
	if _pcount > 4 then
		_pcount = 4
	end
	self.pickCount = _pcount
	self.pickPrize = (_pprize)
	print(" 能够抓几次 ：".._pcount)
	print(" 能够抓的钱 ：".._pprize)
	self.canClick=true;
	self.tab_splite =self:splite(self.pickCount,self.pickPrize/100)
end

local bgY =0 
function  ClimpScene:updateDown(dt)
	if self.tree_bg:getPositionY() <= 1960 then
	 	self.tree_bg:setPositionY(self.tree_bg:getPositionY()+12); 
	 	print("self.tree_bg:"..self.tree_bg:getPositionY())
	end

	if self.tree_bg:getPositionY() > 1960 and self.tree_bg:getPositionY() < 1986 then 
	 	local aniClimb = cc.AnimationCache:getInstance():getAnimation("PendantAnim");
		self.bear:stopAllActions();
		self.bear:runAction(cc.Animate:create(aniClimb));
		self:unscheduleUpdate()
		
		self:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function()
			local endbg = self.csbNode:getChildByName("endbg") 
			endbg:setLocalZOrder(999)
			endbg:getChildByName("text_all"):setString(self.pickCount)
			endbg:getChildByName("text_prize"):setString(self.pickPrize)
			endbg:getChildByName("btn_close"):addTouchEventListener(function(sender, eventType)
				if eventType == ccui.TouchEventType.ended then 
					AudioEngine.playEffect("mp3/Button.mp3")
					--cc.Director:getInstance():popScene()
					--require("app.views.system"):setBtnEnable(MainScene._self,true);
					--SendMsg:exitClimp()
					self._scene._scene:exitClimp()
					--主界面按钮恢复
					--local MainScene = import("app.views.MainScene")
					self._scene:setBtnEnble(true) --按钮禁用
					self._scene.BalanceText = GlobalUserItem.lUserScore;
					self._scene.GameBalanceText:setString(self._scene.BalanceText)
					
					self:setVisible(false)
    				self:removeAllChildren()
    				self:removeFromParent()
				end
			end)
			endbg:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
				AudioEngine.stopMusic()
				AudioEngine.playEffect("mp3/Bear_End.mp3")
				endbg:setVisible(true)
			end )))
		end),nil))
	end 
end

local BearGrasp = false
function ClimpScene:Calculation(_y)
	--print("aaaaaaaaaa:".._y) 
	print("bbbbbbbbbb:"..branchs[self.treeIndex][self.branchIndex][2]) 
	if _y % 50 > 0 and _y % 50 < 1 then
		AudioEngine.playEffect("mp3/Bear_Move.mp3")
	end
	--
	BearGrasp = false
	if self.treeIndex == 1 then 
		if (_y < 1645 and _y > 1644) and branchs[self.treeIndex][1][2] == -260 then
			BearGrasp = true 
		elseif (_y < 1485 and _y > 1484) and branchs[self.treeIndex][2][2] == -390 then
			BearGrasp = true 
		elseif (_y < 1056 and _y > 1055) and branchs[self.treeIndex][3][2] == -730 then
			BearGrasp = true 
		elseif (_y < 875 and _y > 874) and branchs[self.treeIndex][4][2] == -900 then
			BearGrasp = true
		elseif (_y < 453 and _y > 452) and branchs[self.treeIndex][5][2] == -1240 then
			BearGrasp = true 
		elseif (_y < 265 and _y > 264) and branchs[self.treeIndex][6][2] == -1380 then
			BearGrasp = true
		elseif (_y > -159 and _y < -158) and branchs[self.treeIndex][7][2] == -1735 then
			BearGrasp = true
		elseif (_y > -331 and _y < -330) and branchs[self.treeIndex][8][2] == -1873 then
			BearGrasp = true
		elseif (_y > -951 and _y < -950) and branchs[self.treeIndex][9][2] == -2380 then
			BearGrasp = true
		end
	elseif self.treeIndex == 2 then  
		if (_y < 1595 and _y > 1594) and branchs[self.treeIndex][1][2] == -307 then
			BearGrasp = true 
		elseif (_y < 1307 and _y > 1306) and branchs[self.treeIndex][2][2] == -552 then
			BearGrasp = true
		elseif (_y < 1143 and _y > 1142) and branchs[self.treeIndex][3][2] == -680 then
			BearGrasp = true
		elseif (_y < 691 and _y > 690) and branchs[self.treeIndex][4][2] == -1044 then
			BearGrasp = true
		elseif (_y < 515 and _y > 514) and branchs[self.treeIndex][5][2] == -1175 then
			BearGrasp = true
		elseif (_y > -86 and _y < -85) and branchs[self.treeIndex][6][2] == -1664 then
			BearGrasp = true
		elseif (_y > -527 and _y < -526) and branchs[self.treeIndex][7][2] == -2040 then
			BearGrasp = true
		elseif (_y > -707 and _y < -706) and branchs[self.treeIndex][8][2] == -2170 then
			BearGrasp = true
		elseif (_y > -1127 and _y < -1126) and branchs[self.treeIndex][9][2] == -2530 then
			BearGrasp = true
		end	
	elseif self.treeIndex == 3 then  
		if (_y < 1686 and _y > 1685) and branchs[self.treeIndex][1][2] == -230 then
			BearGrasp = true 
		elseif (_y < 1444 and _y > 1443) and branchs[self.treeIndex][2][2] == -430 then
			BearGrasp = true 
		elseif (_y < 1005 and _y > 1004) and branchs[self.treeIndex][3][2] == -778 then
			BearGrasp = true 
		elseif (_y < 843 and _y > 842) and branchs[self.treeIndex][4][2] == -920 then
			BearGrasp = true 
		elseif (_y < 381 and _y > 380) and branchs[self.treeIndex][5][2] == -1280 then
			BearGrasp = true 
		elseif (_y > -401 and _y < -400) and branchs[self.treeIndex][6][2] == -1924 then
			BearGrasp = true 
		elseif (_y > -826 and _y < -825) and branchs[self.treeIndex][7][2] == -2280 then
			BearGrasp = true 
		elseif (_y > -996 and _y < -995) and branchs[self.treeIndex][8][2] == -2427 then
			BearGrasp = true
		end
	elseif self.treeIndex == 4 then  
		if (_y < 1708 and _y > 1707) and branchs[self.treeIndex][1][2] == -211 then
			BearGrasp = true 
		elseif (_y < 1323 and _y > 1322) and branchs[self.treeIndex][2][2] == -524 then
			BearGrasp = true 
		elseif (_y < 1173 and _y > 1172) and branchs[self.treeIndex][3][2] == -640 then
			BearGrasp = true 
		elseif (_y < 715 and _y > 714) and branchs[self.treeIndex][4][2] == -1025 then
			BearGrasp = true 
		elseif (_y < 553 and _y > 552) and branchs[self.treeIndex][5][2] == -1142 then
			BearGrasp = true
		elseif (_y > -46 and _y < -45) and branchs[self.treeIndex][6][2] == -1632 then
			BearGrasp = true
		elseif (_y > -513 and _y < -512) and branchs[self.treeIndex][7][2] == -2017 then
			BearGrasp = true
		elseif (_y > -669 and _y < -668) and branchs[self.treeIndex][8][2] == -2137 then
			BearGrasp = true
		elseif (_y > -1111 and _y < -1110) and branchs[self.treeIndex][9][2] == -2507 then
			BearGrasp = true
		end
	elseif self.treeIndex == 5 then 
		if (_y < 1683 and _y > 1682) and branchs[self.treeIndex][1][2] == -242 then
			BearGrasp = true
		elseif (_y < 1536 and _y > 1535) and branchs[self.treeIndex][2][2] == -362 then
			BearGrasp = true
		elseif (_y < 1033 and _y > 1032) and branchs[self.treeIndex][3][2] == -755 then
			BearGrasp = true
		elseif (_y < 915 and _y > 914) and branchs[self.treeIndex][4][2] == -860 then
			BearGrasp = true
		 elseif (_y < 431 and _y > 430) and branchs[self.treeIndex][5][2] == -1250 then
		 	BearGrasp = true
		 elseif (_y > -175 and _y < -174) and branchs[self.treeIndex][6][2] == -1740 then
		 	BearGrasp = true
		 elseif (_y > -304 and _y < -303) and branchs[self.treeIndex][7][2] == -1850 then
		 	BearGrasp = true
		 elseif (_y > -787 and _y < -786) and branchs[self.treeIndex][8][2] == -2240 then
		 	BearGrasp = true
		end
	end 	
end

function ClimpScene:update2(dt) 
		self.yy =self.yy+ 1 
		local y = self.tree_bg:getPositionY();
		local y1 = self.Leaf:getPositionY();
		self.tree_bg:setPositionY(y-1); 
		self.Leaf:setPositionY(y1-1);
		self:Calculation(y)
		if(BearGrasp)then  --发现2边有树枝 
		 	self:unscheduleUpdate() 
		 	self.bear:stopAllActions(); 
			
		 	local dirStr = "aniRight"
		 	--位置
		 	if( branchs[self.treeIndex][self.branchIndex][1]==0)then 
		 		dirStr="aniLeft"
		 		--self.bear:setPositionX(self.bear:getPositionX()-10)
		 	else 
		 		--self.bear:setPositionX(self.bear:getPositionX()+10)	
		 	end
		 	local  animLeftOrRight = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation(dirStr))  
		 	AudioEngine.playEffect("mp3/Bear_Zhuo.mp3")
		 	--climp 
			
		 	self.bear:runAction(cc.Sequence:create(animLeftOrRight,cc.CallFunc:create(function()
		 		local _honey =self.tree_bg:getChildByName("x"..self.treeIndex.."y"..self.branchIndex);
				
		 		--遇到了蜜蜂
		 		if(self.branchIndex >self.pickCount )then 
		 			AudioEngine.playEffect("mp3/Bear_FengWo.mp3")
		 			self:unscheduleUpdate()
		 			_honey:setTexture(cc.Sprite:create("climb/honeycomb.png"):getTexture())
					
		 			local  beizeAnim = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("CatchAnim")) 
					  
		 			self.bear:stopAllActions();
					
		 			self.bear:runAction(cc.Spawn:create(cc.Sequence:create(beizeAnim),cc.Sequence:create(cc.DelayTime:create(2.0),cc.CallFunc:create(function()
		 				bgY = self.tree_bg:getPositionY();
		 				print("bgY"..bgY)
		 				local aniClimb = cc.AnimationCache:getInstance():getAnimation("FallAnim");
						self.bear:stopAllActions();
						self.bear:runAction(cc.Animate:create(aniClimb));

						self:scheduleUpdateWithPriorityLua(handler(self,self.updateDown),0)
		 			end))));
					
		 			self.branchIndex=self.branchIndex+1
		 		else	
		 			AudioEngine.playEffect("mp3/Bear_FengMi.mp3")
		 			_honey:setVisible(false)
					local tip =self.csbNode:getChildByName("tip");
					tip:getChildByName("text_win"):setString(self.tab_splite[self.branchIndex]*100);
					tip:setLocalZOrder(9999)
					tip:setOpacity(255);
					tip:setVisible(true);
					tip:runAction(cc.Sequence:create(cc.DelayTime:create(0.8),cc.CallFunc:create(function()
						--位置
						--self.bear:setPositionX(rect_trees[self.treeIndex].x+28)
						local  aniClimb = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("aniClimb")) 
						self.bear:stopAllActions();
						self.bear:runAction(aniClimb);
						self:scheduleUpdateWithPriorityLua(handler(self,self.update2),0)
					
					end),cc.FadeOut:create(0.2)));
					self.branchIndex=self.branchIndex+1
				end 
		 	end)));
		end
		--if(self.tree_bg:getPositionY() <= -900)then  
		--	self:unscheduleUpdate() 
		--end 
end

--爬树
function ClimpScene:climp(i) 
	local Tree_X = 0
	self.canClick=false;
	self.csbNode:getChildByName("pan_climb"):setVisible(false) 
	
	self.treeIndex = i 
	if i == 1 then
		Tree_X = 18
	elseif i == 2 then
		Tree_X = 20
	elseif i == 3 then
		Tree_X = 26
	elseif i == 4 then
		Tree_X = 48
	elseif i == 5 then
		Tree_X = 30
	end
	self.bear:setPosition(rect_trees[i].x+Tree_X,rect_trees[i].y+160);
	
	local aniClimb = cc.AnimationCache:getInstance():getAnimation("aniClimb"); 
	self.bear:stopAllActions();
	self.bear:runAction(cc.Animate:create(aniClimb));
				 
	self:scheduleUpdateWithPriorityLua(handler(self,self.update2),0)
end

function ClimpScene:onTouch(event) 
	if not self.canClick then return end 
	if event.name ~= "began" then return end 
    local x, y = event.x, event.y 
	for i =1,5 do
		if cc.rectContainsPoint(rect_trees[i], cc.p(x,y))  then 
			self:climp(i)
			print("点击了第"..i.."课树")  
			return 
		end 
	end
end

function ClimpScene:initAnimCache()
	--爬的动画
	local aniClimb =cc.Animation:create()
	for i = 1 ,14 do 
		local str = string.format("Animation/bclimb/%d.png",i-1)
		aniClimb:addSpriteFrameWithFile(str)
	end 
	aniClimb:setDelayPerUnit(1.2/14) 
	aniClimb:setLoops(999)
	cc.AnimationCache:getInstance():addAnimation(aniClimb,"aniClimb");
	--吃右边
	local aniRight =cc.Animation:create()
	for i = 1 ,17 do  
		local str = string.format("Animation/right/%d.png",i-1)
		aniRight:addSpriteFrameWithFile(str)
	end 
	aniRight:setDelayPerUnit(1.8/17) 
	aniRight:setLoops(1)
	cc.AnimationCache:getInstance():addAnimation(aniRight,"aniRight");
	--吃左边
	local aniLeft =cc.Animation:create()
	for i = 1 ,17 do  
		local str = string.format("Animation/left/%d.png",i-1)
		aniLeft:addSpriteFrameWithFile(str)
	end 
	aniLeft:setDelayPerUnit(1.8/17) 
	aniLeft:setLoops(1)
	cc.AnimationCache:getInstance():addAnimation(aniLeft,"aniLeft"); 
	
	--beize动画
	local beizeAnim =cc.Animation:create()
	for i = 1 ,7 do 
		local str = string.format("Animation/beize/%d.png",i-1)
		beizeAnim:addSpriteFrameWithFile(str)
	end 
	beizeAnim:setDelayPerUnit(1.0/7)
	beizeAnim:setLoops(2)
	cc.AnimationCache:getInstance():addAnimation(beizeAnim,"beizeAnim"); 

	--遇到蜜蜂
	local CatchAnim =cc.Animation:create()
	for i = 1 ,14 do 
		local str = string.format("Animation/Catch/%d.png",i-1)
		CatchAnim:addSpriteFrameWithFile(str)
	end
	CatchAnim:setDelayPerUnit(2.5/14) 
	CatchAnim:setLoops(1) 
	cc.AnimationCache:getInstance():addAnimation(CatchAnim,"CatchAnim"); 
	--遇到蜜蜂后下落
	local FallAnim =cc.Animation:create()
	for i = 1 ,6 do 
		local str = string.format("Animation/Fall/%d.png",i-1)
		FallAnim:addSpriteFrameWithFile(str)
	end 
	FallAnim:setDelayPerUnit(1.0/6)
	FallAnim:setLoops(-1)
	cc.AnimationCache:getInstance():addAnimation(FallAnim,"FallAnim"); 
	--摔倒地上
	local PendantAnim =cc.Animation:create()
	for i = 1 ,20 do  
		local str = string.format("Animation/Pendant/%d.png",i-1)
		PendantAnim:addSpriteFrameWithFile(str)
	end 
	PendantAnim:setDelayPerUnit(1.8/20) 
	PendantAnim:setLoops(1)
	cc.AnimationCache:getInstance():addAnimation(PendantAnim,"PendantAnim"); 
end
return ClimpScene
