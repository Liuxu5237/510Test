--系统菜单

local system = class("system")
local _str = "menuLayer" 
system.b_showHelp =false;
--开始游戏
function system:SetVisible(_self,b_visible)
	if _self:getChildByName(_str) ~=nil then
		_self:getChildByName(_str):getChildByName("Text_3"):setVisible(b_visible);
		_self:getChildByName(_str):getChildByName("text_win"):setVisible(b_visible);
		_self:getChildByName(_str):getChildByName("text_score"):setVisible(b_visible);
		_self:getChildByName(_str):getChildByName("Text_2_0"):setVisible(b_visible);
		_self:getChildByName(_str):getChildByName("Image_1"):setVisible(b_visible);
	end
end

--设置按钮可用
function system:setBtnEnable(_self,b_enable)
	if _self:getChildByName(_str) ~=nil then
		_self:getChildByName(_str):getChildByName("btn_menu"):setEnabled(b_enable)
		_self:getChildByName(_str):getChildByName("btn_menu"):setBright(b_enable)
	end
end

function system:showTextWin(_self)
	if _self:getChildByName(_str) ~=nil then
		_self:getChildByName(_str):getChildByName("text_win"):setVisible(true);
		_self:getChildByName(_str):getChildByName("Text_2_0"):setVisible(true);
	end
end

function system:setBtnVisible(_self,b_enable)
	if _self:getChildByName(_str) ~=nil then
		print("------------!!!!!!!!!!!!---------------")
		_self:getChildByName(_str):getChildByName("btn_menu"):setVisible(b_enable) 
	end
end

function system:initLayer(_self)
	 local menuLayer = cc.CSLoader:createNode("HallLayer.csb") 
	 menuLayer:getChildByName("Text_3"):setVisible(false);
	 menuLayer:getChildByName("text_win"):setVisible(false);
	 menuLayer:getChildByName("text_score"):setVisible(false);
	 menuLayer:getChildByName("Text_2_0"):setVisible(false);
	 menuLayer:getChildByName("Image_1"):setVisible(false);
	 menuLayer:setLocalZOrder(100)
	 menuLayer:setName(_str);
	 _self:addChild(menuLayer) 
	 
		local function exitFunction()
			print("exitFunction")
			--停止音频
			AudioEngine.stopAllEffects()
			AudioEngine.stopMusic()
			
			--清理定时器
			local MainScene = import("app.views.MainScene")
			MainScene.autoCount=0;
			MainScene.freeleft=-1;
			if MainScene.BonusRandomText >= 0 then
				MainScene:startBonusTime(false);
				if not(MainScene._self.schedulerIDWin == nil) then
					cc.Director:getInstance():getScheduler():unscheduleScriptEntry(MainScene._self.schedulerIDWin);
					MainScene._self.schedulerIDWin = nil;
				end
			end
			--清空缓存
			package.loaded["app.MyApp"] = nil
			package.loaded["app.views.MainScene"] = nil
			package.loaded["app.views.HelpScene"] = nil
			package.loaded["app.views.MinGameScene"] = nil
			package.loaded["app.views.GameBroadCast"] = nil
			package.loaded["app.views.logic"] = nil
			package.loaded["app.views.sendmsg"] = nil
			package.loaded["app.views.system"] = nil
			
			
			--_self:addChild(import("Hall/ExitLayer").new(), 10)
		end
		local function helpfunc() 
			if(not system.b_showHelp) then  --防重复显示
				system.b_showHelp = true ; 
				local view =_self:getApp():createView("HelpScene") 
				local scene = display.newScene("HelpScene")
				scene:addChild(view)
				cc.Director:getInstance():pushScene(scene)
			end
			--点击了隐藏掉 menuLIst
			local menuList =cc.Director:getInstance():getRunningScene():getChildByName("menuList");
			if(menuList) then
				cc.Director:getInstance():getRunningScene():removeChildByName("menuList",true); 
			end
		end
	 local  btn_menu =menuLayer:getChildByName("btn_menu")
	 btn_menu:addTouchEventListener(function (sender, eventType) 
			if eventType == ccui.TouchEventType.ended then
                AudioEngine.playMusic("Hall/Sound/Button.mp3")
				local menuList = import("Hall/SystemLayer").new(exitFunction, helpfunc)
				menuList:setName("menuList");
                cc.Director:getInstance():getRunningScene():addChild(menuList, 8)
                --self:addChild(import("Hall/SystemLayer").new(exitFunction), 10)
                --self:addChild(import("Hall/ExitLayer").new(exitFunction), 10)
            end
	 end ) 
end
--游戏结束后调用
function system:updateScore(_self)
	--UserInfo:instance():UpdateModifyScore() 
	_self:getChildByName(_str):getChildByName("text_score"):setString(string.format("%.2f", UserInfo:instance():getScore()/100))
end
--显示赢了多少
function system:setWinScore(_self,nScore)
	_self:getChildByName(_str):getChildByName("text_win"):setString(string.format("%.2f", nScore))
end
-- function system:updateScore(_self)
-- 	UserInfo:instance():UpdateModifyScore() 
-- 	_self:getChildByName(_str):getChildByName("text_score"):setString(string.format("%.2f", UserInfo:instance():getScore()/100))
-- end
--获取当前值减去消耗
function system:subScore(_self,nScore)
	local score = tonumber(_self:getChildByName(_str):getChildByName("text_score"):getString()) - nScore
	_self:getChildByName(_str):getChildByName("text_score"):setString(score)
end
return system
