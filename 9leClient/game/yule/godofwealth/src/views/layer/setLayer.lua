--系统菜单
local HelpLayer = appdf.req("game.yule.godofwealth.src.views.layer.HelpLayer")
local MenuLayer = appdf.req("game.yule.godofwealth.src.views.layer.MenuLayer")
local setLayer = class("setLayer",cc.Layer)

function setLayer:ctor(scene)
	self._scene = scene
end
--设置按钮可用
function setLayer:setBtnEnable(b_enable)
	self.menuLayer:getChildByName("btn_menu"):setEnabled(b_enable)
	self.menuLayer:getChildByName("btn_menu"):setBright(b_enable)
end

function setLayer:setBtnVisbel(b_enable)
	self.menuLayer:getChildByName("btn_menu"):setVisible(b_enable)
end
--退出
function setLayer:exitFunction()
	print("exitFunction")
	if self._scene._scene and self._scene._scene.onQueryExitGame then
		self._scene._scene:onQueryExitGame()
	end
end
--帮助
function setLayer:helpfunc() 
	if(not self.b_showHelp) then  --防重复显示
		self.b_showHelp = true
		HelpLayer:create(self)
				 :addTo(self,101)
	end
end
-- 摇一摇
function setLayer:shakingYes() 
	-- print(" --------- 【摇一摇 开】 -----------  ")
	-- self._scene.ShakingTemp = true
	--showPopupLayer(AdminLayer:create(self._scene))
	-- local cmddata = CCmd_Data:create(0)
	-- self._scene._scene:SendData(15,cmddata)
end

function setLayer:shakingNo() 
	-- print(" --------- 【摇一摇 关】 -----------  ")
	-- self._scene.ShakingTemp = false
	 dismissPopupLayer(self._scene._scene._adminLayer)
	return
end
-- 声音
function setLayer:soundNo() 
	print(" --------- 【声音 关】 -----------  ")
	self._scene.MusicTemp = false
	AudioEngine.stopAllEffects()
	AudioEngine.stopMusic()
end	
function setLayer:soundYes() 
	print(" --------- 【声音 开】 -----------  ")
	self._scene.MusicTemp = true
	if self._scene.MusicTemp then
		if self._scene.FreeRotationCount == 0 then
			AudioEngine.playMusic("mp3/BG.mp3",true)
		else
			AudioEngine.playMusic("mp3/FreeGameBG.mp3",true)
		end		
	end
end

function setLayer:initLayer()
	self.menuLayer = cc.CSLoader:createNode("GameMenu/HallLayer.csb")
	 					:addTo(self)

	self._IsMenuOpen = false;
	local menuList = MenuLayer:create(self):addTo(self)
	menuList:setVisible(false)
	menuList:init()

	local  btn_menu = self.menuLayer:getChildByName("btn_menu")
	btn_menu:addTouchEventListener(function (sender, eventType) 
		if eventType == ccui.TouchEventType.ended then
           	if self._scene.MusicTemp then
        		ccexp.AudioEngine:play2d("mp3/Button.mp3")
        	end
			menuList:LayerAnimation()
        end
	 end )
end
--游戏结束后调用
function setLayer:updateScore()
	--UserInfo:instance():UpdateModifyScore() 
	self.menuLayer:getChildByName("text_score"):setString(GlobalUserItem.lUserScore)
end
--显示赢了多少
function setLayer:setWinScore(nScore)
	self.menuLayer:getChildByName("text_win"):setString(nScore)
end
--获取当前值减去消耗
function setLayer:subScore(nScore)
	local score = tonumber(self.menuLayer:getChildByName("text_score"):getString()) - nScore
	self.menuLayer:getChildByName("text_score"):setString(score)
	
end
return setLayer
