
--
-- Author: Tang
-- Date: 2016-08-09 14:46:36
--
local GameViewLayer = class("GameViewLayer", function(scene)
	    local gameViewLayer = display.newLayer()
	    return gameViewLayer
    end)

--Tag
---------------------------------------------------------------------------------
GameViewLayer.VIEW_TAG = 
{
    tag_bg        = 200,
    tag_autoshoot = 210,
    tag_autolock = 211,
    tag_gameScore= 212,
    tag_gameMultiple = 213,
    tag_grounpTips = 214,
    tag_GoldCycle = 3000, 
    tag_GoldCycleTxt = 4000,
    tag_Menu = 5000,
    tag_MenuT = 5001,
    tag_GoldsText = 1000,
}
local CHANGE_MULTIPLE_INTERVAL =  0.8
local  TAG = GameViewLayer.VIEW_TAG

local ExternalFun = require(appdf.EXTERNAL_SRC.."ExternalFun")
local HeadSprite = appdf.req(appdf.EXTERNAL_SRC .. "HeadSprite")
local g_var = ExternalFun.req_var
local ClipText = appdf.EXTERNAL_SRC .. "ClipText"
local module_pre = "game.yule.xlkpy.src"	
local game_cmd = appdf.HEADER_SRC .. "CMD_GameServer"
local PRELOAD = require(module_pre..".views.layer.PreLoading") 
local CannonSprite = require(module_pre..".views.layer.Cannon1")
local cmd = module_pre .. ".models.CMD_LKPYGame"
local SetLayer = require(module_pre..".views.layer.SettingLayer") 

local scheduler = cc.Director:getInstance():getScheduler()  --
local Game_CMD = appdf.req(module_pre .. ".models.CMD_LKPYGame")
local HelpLayer = appdf.req(module_pre .. ".views.layer.HelpLayer")  --
--local SettingLayer = appdf.req(module_pre .. ".views.layer.SettingLayer")  --

local random = math.random  --
----------------------------------------------------------------------------
--local rewardPos = 
--{
--    cc.p(270,610),z
--	cc.p(667,610),
--	cc.p(1082,610),
--	cc.p(270,200),
--	cc.p(667,200),
--	cc.p(1082,200),
--	cc.p(204,399),
--	cc.p(1130,399)
--}

local rewardPos = 
{
    cc.p(205,610),
	cc.p(1129,610),
	cc.p(205,200),
	cc.p(1129,200),
	cc.p(1082,610),
	cc.p(1082,200),
	cc.p(204,399),
	cc.p(1130,399)
}

function GameViewLayer:ctor( scene )
    --local runScene = cc.Director:getInstance():getRunningScene()
    --gameShowToast(runScene, "捕鱼场景丫丫11111", 3)
--    if 1 then
--        return 
--    end
    ExternalFun.registerTouchEvent(self)

    self._tag = 0
	self._scene = scene

	self:addSerchPaths()
    --gameShowToast(runScene, "捕鱼场景丫丫22222", 3)
    PRELOAD.setEnded(false)
    self._gameFrame = scene._gameFrame

    self.m_pUserItem = self._gameFrame:GetMeUserItem()
    --gameShowToast(runScene, "捕鱼场景丫丫3333333", 3)
    --预加载资源
    PRELOAD.loadTextures()
    --gameShowToast(runScene, "捕鱼场景丫丫55555555", 3)
    --气泡特效
    self.particle1 = cc.ParticleSystemQuad:create("particle/particle_bubbleup.plist")
    self.particle1:setPosition(300, 0)
    self.particle1:setScale(1.2)

    self.particle1:setPositionType(cc.POSITION_TYPE_GROUPED)
    self._scene.fishBg:addChild(self.particle1, 3)

    self.particle2 = cc.ParticleSystemQuad:create("particle/particle_bubbleup.plist")
    self.particle2:setPosition(1034, 0)
    self.particle2:setScale(1.2)
    self.particle2:setPositionType(cc.POSITION_TYPE_GROUPED)
    self._scene.fishBg:addChild(self.particle2, 3)

    --注册事件
    ExternalFun.registerTouchEvent(self,true)
    self.m_TAG = TAG
    self.m_bCanChangeMultple = true
    self.m_touchTime = 0
    --dyj1(FC++)
    self.Themoney = 0
    --dyj2
    self.Music = true 
    --
end


function GameViewLayer:onExit()

    self:unscheduleWaveSea()

    PRELOAD.unloadTextures()
    PRELOAD.removeAllActions()

    PRELOAD.resetData()

    self:StopLoading(true)

    --播放大厅背景音乐
    ExternalFun.playPlazzBackgroudAudio()

    --重置搜索路径
    local oldPaths = cc.FileUtils:getInstance():getSearchPaths();
    local newPaths = {};
    local a = nil 
    for k,v in pairs(oldPaths) do
        a = nil 
        a = string.match(tostring(v), "/xlkpy/")
        if tostring(v) ~= tostring(self._searchPath) and nil == a then
            table.insert(newPaths, v);
        end
    end
    cc.FileUtils:getInstance():setSearchPaths(newPaths);
    
    --清理锁表
    GlobalUserItem.dwLockKindID = 0
end

function GameViewLayer:StopLoading( bRemove )
    PRELOAD.StopAnim(bRemove)
end

function GameViewLayer:getDataMgr( )
    return self:getParentNode():getDataMgr()
end

function GameViewLayer:getParentNode( )
    return self._scene;
end

function GameViewLayer:addSerchPaths( )
   --搜索路径
    local gameList = self._scene._scene:getApp()._gameList;
    local gameInfo = {};
    for k,v in pairs(gameList) do
          if tonumber(v._KindID) == tonumber(Game_CMD.KIND_ID) then
            gameInfo = v;
            break;
        end
    end

    if nil ~= gameInfo._KindName then
        self._searchPath = device.writablePath.."game/" .. gameInfo._Module .. "/res/";
        cc.FileUtils:getInstance():addSearchPath(self._searchPath);
    end

    --搜索路径
    if device.platform == "windows" then
        cc.FileUtils:getInstance():addSearchPath("game/yule/xlkpy/res/")
    end
    if device.platform == "ios" then
        cc.FileUtils:getInstance():addSearchPath("game/yule/xlkpy/res/")
    end
    if device.platform == "android" then
        cc.FileUtils:getInstance():addSearchPath("game/yule/xlkpy/res/")
    end
end

function GameViewLayer:hideBtnSchedule()

    local function  update(dt)
        local time = currentTime()
        if time - self.m_touchTime >= 30000 then
            if self.menu:isVisible() then
                self:unHideBtnSchedule()
                self.menu:setVisible(false)
                self.menuT:setVisible(true)

--                self.exit:runAction(cc.MoveTo:create(0.2,cc.p(-50,530)))
--                self.sound:runAction(cc.MoveTo:create(0.2,cc.p(-50,400)))
--                self.help:runAction(cc.MoveTo:create(0.2,cc.p(-50,270)))
--                self.btn_speed:runAction(cc.MoveTo:create(0.2, cc.p(-50,400)))
                --self.byself:runAction(cc.MoveTo:create(0.2,cc.p(1380,450)))
                --self.lock:runAction(cc.MoveTo:create(0.2,cc.p(1380,330)))
                --self.upScore:runAction(cc.MoveTo:create(0.2,cc.p(1380,550)))
                --self.downScore:runAction(cc.MoveTo:create(0.2,cc.p(1380,230)))

                self.btn_speed:runAction(cc.MoveTo:create(0.2, cc.p(60, 400)))
                self.sound:runAction(cc.MoveTo:create(0.2,cc.p(1334+35,375)))
                self.exit:runAction(cc.MoveTo:create(0.2,cc.p(1334+35,750-500)))
                self.help:runAction(cc.MoveTo:create(0.2,cc.p(1334+35,500)))
                self.upScore:runAction(cc.MoveTo:create(0.2,cc.p(1250,550)))
                self.downScore:runAction(cc.MoveTo:create(0.2,cc.p(1250,230)))
                self.menuBg:runAction(cc.MoveTo:create(0.2,cc.p(1334+self.menuBg:getContentSize().width/2,375))) 
                self.menu:runAction(cc.MoveTo:create(0.2,cc.p(1334-self.menu:getContentSize().width/2,375)))
                self.menuT:runAction(cc.MoveTo:create(0.2,cc.p(1334-self.menu:getContentSize().width/2,375)))
                self.ifmenu = false
            else
                self:unHideBtnSchedule()
            end
        end
    end

    if nil == self.m_hideBtnSchedule then
        self.m_hideBtnSchedule = scheduler:scheduleScriptFunc(update, 1, false)
    end
    
end

function GameViewLayer:unHideBtnSchedule()

    if nil ~= self.m_hideBtnSchedule then
        scheduler:unscheduleScriptEntry(self.m_hideBtnSchedule)
        self.m_hideBtnSchedule = nil
    end
    
end

function GameViewLayer:changeMultipleSchedule( dt )

    local function  update(dt)
       self:multipleUpdate()
    end

    if nil == self.multipleSchedule then
        self.multipleSchedule = scheduler:scheduleScriptFunc(update, dt, false)
    end
    
end

function GameViewLayer:unMultipleSchedule()
    self.m_bCanChangeMultple = true
    if nil ~= self.multipleSchedule then
        scheduler:unscheduleScriptEntry(self.multipleSchedule)
        self.multipleSchedule = nil
    end
end

function GameViewLayer:multipleUpdate()
    self:unMultipleSchedule()  
end

function GameViewLayer:initView(  )
    local runScene = cc.Director:getInstance():getRunningScene()
    --gameShowToast(runScene, "开始进入场景111111", 3)

    -- 播放背景音乐
    --ExternalFun.playBackgroudAudio("LOAD_BACK.mp3")
    self._setLayer = SetLayer:create(self):addTo(self, 100003)

    local bg =  ccui.ImageView:create("background/game_bg_4.png")
	bg:setAnchorPoint(cc.p(.5,.5))
    bg:setTag(TAG.tag_bg)
    bg:setName("bg")
	bg:setPosition(cc.p(yl.WIDTH/2,yl.HEIGHT/2))
	self._scene.fishBg:addChild(bg, -1)

    if self._scene.m_nChairID < 3 then
        bg:setRotation(180)
        self.particle1:setRotation(180)
        self.particle1:setPosition(cc.p(300, yl.HEIGHT))
        self.particle2:setRotation(180)
        self.particle2:setPosition(cc.p(1034, yl.HEIGHT))
    end

   self.ifmenu = true

    local function callBack( sender, eventType)
        self:ButtonEvent(sender,eventType)
    end

    --gameShowToast(runScene, "开始进入场景2222222", 3)
    --自动射击
    self.byself = ccui.Button:create("game_res/byself0.png")
    --self.byself:setScale(0.9)
    --self.byself:setPosition(cc.p(1250,455))
    self.byself:setPosition(cc.p(667+self.byself:getContentSize().width/2+10,self.byself:getContentSize().height/2+5))
    self.byself:setTag(TAG.tag_autoshoot)
    self.byself:addTouchEventListener(callBack)
    self:addChild(self.byself,20)

    --自动锁定
    self.lock = ccui.Button:create("game_res/lock0.png")
    --self.lock:setScale(0.9)
    --self.lock:setPosition(cc.p(1250,325))1380,330
    self.lock:setPosition(cc.p(667-self.lock:getContentSize().width/2-10,self.lock:getContentSize().height/2+5))
    self.lock:setTag(TAG.tag_autolock)
    self.lock:addTouchEventListener(callBack)
    self:addChild(self.lock,20)

   self.upScore = ccui.Button:create("game_res/upscore.png", "")      --上分
   self.upScore:setVisible(false)
		--:setTag(UPSCORE)
    --self.upScore:setPosition(cc.p(1250,580))
    self.upScore:setPosition(cc.p(1250,550))
    self.upScore:setScale(1.1)
	self.upScore:setName("upscore")
	self:addChild(self.upScore,20)
	self.upScore:addTouchEventListener(function (sender , eventType)
        local currTime = currentTime()
        local aaa  = currTime - self._scene.FirstTime
        if eventType == ccui.TouchEventType.ended and aaa > 50 then
            self.m_touchTime = currTime
            self:hideBtnSchedule()
    	    self._scene.FirstTime = aaa
            local scoredata=CCmd_Data:create(1)
            scoredata:setcmdinfo(yl.MDM_GF_GAME , Game_CMD.SUB_C_ADDORDOWNSCORE)
            scoredata:pushbool(true)
            --发送失败
            if not self._scene:sendNetData(scoredata) then
                --print("发送上分消息失败")
            else
            local cannonPos = self._scene.m_nChairID
            cannonPos = CannonSprite.getPos(self._scene._dataModel.m_reversal,cannonPos)
                if self._scene.Copylscore - self._scene.ScoreM >= 0 then
                    self._scene.ScoreCount = self._scene.ScoreCount + self._scene.ScoreM
                    self._scene.Copylscore = self._scene.Copylscore - self._scene.ScoreM
                else
                    self._scene.ScoreCount = self._scene.ScoreCount + self._scene.Copylscore
                    self._scene.Copylscore = 0
                end
                self._scene.m_cannonLayer:updateUpScore( self._scene.ScoreCount , cannonPos+1)
            end
        end
    end)
   
	self.downScore = ccui.Button:create("game_res/downscore.png", "")        --下分
    self.downScore:setVisible(false)
		--:setTag(DOWNSCORE)
	--self.downScore:setPosition(cc.p(1250,200))
	self.downScore:setPosition(cc.p(1250,230))
    self.downScore:setScale(1.1)
	self.downScore:setName("downscore")
	self:addChild(self.downScore,20)
	self.downScore:addTouchEventListener(function (sender , eventType)
        local currTime = currentTime()
        local aaa  = currTime - self._scene.FirstTime
        if eventType == ccui.TouchEventType.ended and aaa > 50 then
            self.m_touchTime = currTime
            self:hideBtnSchedule()
    	    self._scene.FirstTime = aaa
            local scoredata = CCmd_Data:create(1)
            scoredata:setcmdinfo(yl.MDM_GF_GAME, Game_CMD.SUB_C_ADDORDOWNSCORE)
            scoredata:pushbool(false)
            --发送失败
            if not  self._scene:sendNetData(scoredata) then
                --print("发送上分消息失败")
            else
            local cannonPos = self._scene.m_nChairID
                    cannonPos = CannonSprite.getPos(self._scene._dataModel.m_reversal,cannonPos)
            if self._scene.ScoreCount > 0 then
                self._scene.Copylscore = self._scene.Copylscore + self._scene.ScoreCount
                self._scene.ScoreCount = 0
            end
                self._scene.m_cannonLayer:updateUpScore(self._scene.ScoreCount,cannonPos + 1)
            end
        end
    end)



--菜单
    self.menu = ccui.Button:create("game_res/show_hide.png","game_res/show_hide.png")
    self.menu:setTag(TAG.tag_Menu)
    --self.menu:setPosition(cc.p(30,120))
    self.menu:setPosition(cc.p(1334-self.menu:getContentSize().width/2,375))
    self.menu:setScale(1.3)
    self.menu:setVisible(false)
    self.menu:addTouchEventListener(function (sender,eventType)
        if eventType == ccui.TouchEventType.ended  then
                self:unHideBtnSchedule()
				
				self._isShow_Hide = false
                --self.exit:runAction(cc.MoveTo:create(0.2,cc.p(-50,530)))
                --self.sound:runAction(cc.MoveTo:create(0.2,cc.p(-50,400)))
                --self.help:runAction(cc.MoveTo:create(0.2,cc.p(-50,270)))
                --self.btn_speed:runAction(cc.MoveTo:create(0.2, cc.p(-50,400)))
                --self.byself:runAction(cc.MoveTo:create(0.2,cc.p(1380,450)))
                --self.lock:runAction(cc.MoveTo:create(0.2,cc.p(1380,330)))
                --self.upScore:runAction(cc.MoveTo:create(0.2,cc.p(1380,550)))
                --self.downScore:runAction(cc.MoveTo:create(0.2,cc.p(1380,230)))
                self.btn_speed:runAction(cc.MoveTo:create(0.2, cc.p(60, 400)))
                self.sound:runAction(cc.MoveTo:create(0.2,cc.p(1334+35,375)))
                self.exit:runAction(cc.MoveTo:create(0.2,cc.p(1334+35,750-500)))
                self.help:runAction(cc.MoveTo:create(0.2,cc.p(1334+35,500)))
                self.upScore:runAction(cc.MoveTo:create(0.2,cc.p(1250,550)))
                self.downScore:runAction(cc.MoveTo:create(0.2,cc.p(1250,230)))
                self.menuBg:runAction(cc.MoveTo:create(0.2,cc.p(1334+self.menuBg:getContentSize().width/2,375)))
                self.menu:runAction(cc.MoveTo:create(0.2,cc.p(1334-self.menu:getContentSize().width/2,375)))
                self.menuT:runAction(cc.MoveTo:create(0.2,cc.p(1334-self.menu:getContentSize().width/2,375)))
                self.ifmenu = false
                self.menu:setVisible(false)
                self.menuT:setVisible(true) 
        end
    end)
    self:addChild(self.menu,20)

    self.menuT = ccui.Button:create("game_res/show_isVisible.png","game_res/show_isVisible.png")
    self.menuT:setTag(TAG.tag_MenuT)
    self.menuT:setVisible(true)
    --self.menuT:setPosition(cc.p(30,120))
    self.menuT:setPosition(cc.p(1334-self.menu:getContentSize().width/2,375))
    self.menuT:setScale(1.3)
    self.menuT:addTouchEventListener(function (sender,eventType)
        if eventType == ccui.TouchEventType.ended  then
            self.m_touchTime = currentTime()
			
			self._isShow_Hide = true
			
            self:hideBtnSchedule()
            --self.exit:runAction(cc.MoveTo:create(0.2,cc.p(100,530)))
            --self.sound:runAction(cc.MoveTo:create(0.2,cc.p(180,400)))
            --self.help:runAction(cc.MoveTo:create(0.2,cc.p(100,270)))
           -- self.btn_speed:runAction(cc.MoveTo:create(0.2, cc.p(60, 400)))
            --self.byself:runAction(cc.MoveTo:create(0.2,cc.p(1250,450)))
            --self.lock:runAction(cc.MoveTo:create(0.2,cc.p(1250,330)))
            --self.upScore:runAction(cc.MoveTo:create(0.2,cc.p(1250,550)))
            --self.downScore:runAction(cc.MoveTo:create(0.2,cc.p(1250,230)))
            self.btn_speed:runAction(cc.MoveTo:create(0.2, cc.p(-50, 400)))
            self.sound:runAction(cc.MoveTo:create(0.2,cc.p(1334-35,375)))
            self.exit:runAction(cc.MoveTo:create(0.2,cc.p(1334-35,750-500)))
            self.help:runAction(cc.MoveTo:create(0.2,cc.p(1334-35,500)))
            self.upScore:runAction(cc.MoveTo:create(0.2,cc.p(1400,550)))
            self.downScore:runAction(cc.MoveTo:create(0.2,cc.p(1400,230)))
            self.menuBg:runAction(cc.MoveTo:create(0.2,cc.p(1334-self.menuBg:getContentSize().width/2,375)))
            self.menu:runAction(cc.MoveTo:create(0.2,cc.p(1334-self.menu:getContentSize().width/2-self.menuBg:getContentSize().width,375)))
            self.menuT:runAction(cc.MoveTo:create(0.2,cc.p(1334-self.menu:getContentSize().width/2-self.menuBg:getContentSize().width,375)))
            self.ifmenu = true    
            self.menu:setVisible(true)
            self.menuT:setVisible(false)
        end
    end)
    self:addChild(self.menuT,20)


--菜单背景
    self.menuBg = ccui.ImageView:create("game_res/toll_kuang.png")
    self.menuBg:setPosition(cc.p(1334+self.menuBg:getContentSize().width/2,375))
    self.menuBg:setTag(4)
    self.menuBg:setScale(1.3)
    self.menuBg:addTouchEventListener(function (sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:unHideBtnSchedule()
                self:subMenuEvent(sender,eventType)
                --print("吞吞吐吐拖")
            end
        end)
    self:addChild(self.menuBg,19)

--退出
    self.exit = ccui.Button:create("game_res/exit.png")
    --self.exit:setPosition(cc.p(100,530))
    self.exit:setPosition(cc.p(1334+35,750-500))
    self.exit:setTag(4)
    self.exit:setScale(1.3)
    self.exit:addTouchEventListener(function (sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:unHideBtnSchedule()
                self:subMenuEvent(sender,eventType)
                --print("吞吞吐吐拖")
            end
        end)
    self:addChild(self.exit,20)

--声音
--    self.sound = ccui.Button:create("game_res/sound0.png")
    self.sound = ccui.Button:create("game_res/toll_btn_setting.png")
    --self.sound:setPosition(cc.p(180,400))
    self.sound:setPosition(cc.p(1334+35,375))
    self.sound:setScale(1.3)
    self.sound:setTag(3)
    self:addChild(self.sound,20)

--    self.sound0 = ccui.ImageView:create("game_res/sound1.png")
--    self.sound0:setPosition(cc.p(self.sound:getContentSize().width/2,self.sound:getContentSize().width/2))
--    self.sound:addChild(self.sound0)

    self.sound:addTouchEventListener(function (sender,eventType)
        if eventType == ccui.TouchEventType.ended  then
            self._setLayer:showLayer()
--            if self.sound0:isVisible() then 
--                self.sound0:setVisible(false)

--               AudioEngine.stopMusic()
--            else
--                 AudioEngine.playMusic(cc.FileUtils:getInstance():fullPathForFilename(Game_CMD.Music_Back_1),true)
--                self.Music = true
--                self.sound0:setVisible(true)
--            end
        end
        end)

    --加速
    self.btn_speed = ccui.Button:create("game_res/speed_fast.png", "")
    self.btn_speed:setVisible(false)
    --self.btn_speed:setPosition(cc.p(60, 400))
    self.btn_speed:setPosition(cc.p(60, 400))
    self.btn_speed:setScale(1.3)
    self.btn_speed:setTag(10)
    self.btn_speed:addTouchEventListener(function(ref, tType)
        if tType == ccui.TouchEventType.ended then
            self.m_touchTime = currentTime()
            self:hideBtnSchedule()
            if ref:getTag() == 10 then
                --加载特效
                self.speed_effect:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.RotateBy:create(2, -360))))
                self.btn_speed:setTag(20)
                self.btn_speed:loadTextureNormal("game_res/speed_slow.png")
                self._scene.m_cannonLayer.m_bulletSpeed = 0.5		--加速速度      
			elseif ref:getTag() == 20 then
          		--停止特效
				self.speed_effect:stopAllActions()
                self.btn_speed:setTag(10)
                self.btn_speed:loadTextureNormal("game_res/speed_fast.png")
                self._scene.m_cannonLayer.m_bulletSpeed = 0.2       --原始速度
            end
        end
    end)
    self:addChild(self.btn_speed, 20)

    self.speed_effect = cc.Sprite:create("game_res/speed_effect.png")
    self.speed_effect:setPosition(cc.p(self.btn_speed:getContentSize().width / 2, self.btn_speed:getContentSize().height / 2))
    self.btn_speed:addChild(self.speed_effect,1)

--帮助
    self.help = ccui.Button:create("game_res/help.png")
    --self.help:setPosition(cc.p(100,270))
    self.help:setPosition(cc.p(1334+35,500))
    self.help:setTag(2)
    self.help:setScale(1.3)
    self.help:addTouchEventListener(function (sender,eventType)
            if eventType == ccui.TouchEventType.ended  then
                self.m_touchTime = currentTime()
                self:hideBtnSchedule()
                self:subMenuEvent(sender,eventType)
            end
        end)
    self:addChild(self.help,20)

    --水波效果
    local render = cc.RenderTexture:create(1334,750)
    render:beginWithClear(0,0,0,0)
    local water = cc.Sprite:createWithSpriteFrameName("water_0.png")
    if water then
        water:setScale(2.5)
        water:setOpacity(200)
        water:setBlendFunc(gl.SRC_ALPHA,gl.ONE)
        water:visit()
        render:endToLua()
        water:addChild(render)
        render:setPosition(667,375) 
        water:setPosition(667,375)
        self._scene.m_fishLayer:addChild(water, 1000)
        local ani1 = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("WaterAnim"))
        local ani2 = ani1:reverse()
        local action = cc.RepeatForever:create(cc.Sequence:create(ani1,ani2))
        water:runAction(action)
    end
end

function GameViewLayer:onTouchBegan(touch, event)
    if self._isShow_Hide then
	    return true
	end
	
	return false
end

--上分
function GameViewLayer:sendUpScrore( )
    local currTime = currentTime()
    local aaa  = currTime -  0
        if  aaa > 50 then
            self.m_touchTime = currTime
            self:hideBtnSchedule()
    	    self._scene.FirstTime = aaa
            local scoredata=CCmd_Data:create(1)
            scoredata:setcmdinfo(yl.MDM_GF_GAME , Game_CMD.SUB_C_ADDORDOWNSCORE)
            scoredata:pushbool(true)
            --发送失败
            if not self._scene:sendNetData(scoredata) then
                --print("发送上分消息失败")
            else
            local cannonPos = self._scene.m_nChairID
            cannonPos = CannonSprite.getPos(self._scene._dataModel.m_reversal,cannonPos)
                if self._scene.Copylscore - self._scene.ScoreM >= 0 then
                    self._scene.ScoreCount = self._scene.ScoreCount + self._scene.ScoreM
                    self._scene.Copylscore = self._scene.Copylscore - self._scene.ScoreM
                else
                    self._scene.ScoreCount = self._scene.ScoreCount + self._scene.Copylscore
                    self._scene.Copylscore = 0
                end
                self._scene.m_cannonLayer:updateUpScore( self._scene.ScoreCount , cannonPos+1)
            end
        end

end
--
function GameViewLayer:initUserInfo()
    --用户分数 
    local score = cc.Label:createWithCharMap("game_res/scoreNum.png",16,22,string.byte("0"))
    --local score = cc.Label:createWithCharMap("game_res/numberlabel_gold_big.png",26,34,string.byte("."))
    --print(string.format("------------------用户分数 %d------------", self._scene.m_pUserItem.lScore))
    score:setString((ExternalFun.strFormatScore(self._scene.m_pUserItem.lScore,score,true))*100)
    score:setAnchorPoint(0.5,0.5)
    score:setScale(0.9)
    score:setTag(TAG.tag_gameScore)
    score:setPosition(163, 22)
    --self:addChild(score,22)
end

function GameViewLayer:updateUserScore( score )
    local _score  = self:getChildByTag(TAG.tag_gameScore)
    if nil ~=  _score then
        _score:setString(string.format("%d",score))
    end
end

function GameViewLayer:updateMultiple( multiple )
    local _Multiple = self:getChildByTag(TAG.tag_gameMultiple)
    if nil ~=  _Multiple then
        _Multiple:setString(tostring(multiple))
    end

end

function GameViewLayer:updteBackGround(param, delayTime)
    
    local bg = self._scene.fishBg:getChildByName("bg")    --Tag(TAG.tag_bg)

    if bg  then
        local call = cc.CallFunc:create(function()
            bg:removeFromParent(true)
        end)


        local bgfile = string.format("background/game_bg_%d.png", param)
        local _bg = cc.Sprite:create(bgfile)
        _bg:setPosition(yl.WIDTH / 2 + yl.WIDTH, yl.HEIGHT / 2)
        self._scene.fishBg:addChild(_bg, -1)
        if self._scene.m_nChairID < 3 then
            _bg:setRotation(180)
        end
        local newCall = cc.CallFunc:create(function()
            _bg:setTag(TAG.tag_bg)
            _bg:setName("bg")
        end)
        _bg:runAction(cc.Sequence:create(cc.MoveTo:create(delayTime, cc.p(yl.WIDTH / 2, yl.HEIGHT / 2)), call, newCall))
    end

    --鱼阵浪潮
    local groupTips = cc.Sprite:create()
    groupTips:initWithSpriteFrameName("wave_1.png")
    local animation = cc.AnimationCache:getInstance():getAnimation("waveAnim")
    if nil ~= animation then
        local action = cc.RepeatForever:create(cc.Animate:create(animation))
        groupTips:runAction(action)
    end
    groupTips:setPosition(cc.p(yl.WIDTH + 180,yl.HEIGHT/2))
    groupTips:setLocalZOrder(1)
    groupTips:setName("wave")
    self._scene.m_fishLayer:addChild(groupTips,30)

    local callFunc1 = cc.CallFunc:create(function()
            self:unscheduleWaveSea()
        end)

    local callFunc2 = cc.CallFunc:create(function()
            groupTips:removeFromParent(true)
        end)

    
    local moveTo1 = cc.MoveTo:create(delayTime, cc.p(180, yl.HEIGHT / 2))
    local delayTime1 = (180 + 200) / (1334 / delayTime)
    local moveTo2 = cc.MoveTo:create(delayTime1, cc.p(-200, yl.HEIGHT / 2))
    groupTips:runAction(cc.Sequence:create(moveTo1, callFunc1, moveTo2, callFunc2))

    self:scheduleWaveSea()
end

function GameViewLayer:scheduleWaveSea()

    local function update()
        if nil ~= self._scene and nil ~= self._scene.m_fishLayer then
            local groupTips = self._scene.m_fishLayer:getChildByName("wave")
            if nil ~= groupTips then
                local recWave = groupTips:getBoundingBox()
                for k,v in pairs(self._scene._dataModel.m_fishList) do
                    local fishPos = cc.p(v:getPositionX(), v:getPositionY())
                    if cc.rectContainsPoint(recWave, fishPos) or not cc.rectContainsPoint(cc.rect(0,0,yl.WIDTH,yl.HEIGHT), fishPos) then
                        v.m_CreatDelayTime = 10000
                    end
                end
                for k,v in pairs(self._scene.bullet) do
                    local fishPos = cc.p(v:getPositionX(), v:getPositionY())
                    if cc.rectContainsPoint(recWave, fishPos) then
                        v.ifdie = true
                    end
                end
            end
        end
    end

    if nil == self.m_scheduleWaveSea then
        self.m_scheduleWaveSea = scheduler:scheduleScriptFunc(update, 0, false)
    end
end

function GameViewLayer:unscheduleWaveSea()

    if nil ~= self.m_scheduleWaveSea then
        scheduler:unscheduleScriptEntry(self.m_scheduleWaveSea)
        self.m_scheduleWaveSea = nil
    end
end

function GameViewLayer:setAutoShoot(b,target)
                 
    if b then
        local auto = cc.Sprite:create("game_res/byself1.png")
        auto:setTag(1)
        auto:setScale(0.9)
        auto:setPosition(target:getContentSize().width/2, target:getContentSize().height/2)
        target:removeChildByTag(1)
        target:addChild(auto)

    else
         target:removeChildByTag(1)
    end
          
end

function GameViewLayer:setAutoLock(b,target)
          
    if b then
        local lock = cc.Sprite:create("game_res/lock1.png")
        lock:setTag(1)
        lock:setScale(0.9)
        lock:setPosition(target:getContentSize().width/2, target:getContentSize().height/2)
        target:removeChildByTag(1)
        target:addChild(lock)

    else
         target:removeChildByTag(1)

         --取消自动射击
         self._scene._dataModel.m_fishIndex = Game_CMD.INT_MAX

        --删除自动锁定图标
         local cannonPos = self._scene.m_nChairID
         cannonPos = CannonSprite.getPos(self._scene._dataModel.m_reversal,cannonPos)

         local cannon = self._scene.m_cannonLayer:getCannoByPos(cannonPos + 1)
         cannon:removeLockTag()

    end              
end


function GameViewLayer:onBankSuccess( )
    self._scene:dismissPopWait()
    local bank_success = self._scene.bank_success
    self._scene.Copylscore = self._scene.Copylscore + (bank_success.lUserScore - self.Themoney)
    showToast(cc.Director:getInstance():getRunningScene(), bank_success.szDescribrString, 2)
    GlobalUserItem.lUserInsure = bank_success.lUserInsure
    self:refreshScore()
    if true then
        return
    end
    
    if nil == bank_success then
        return
    end

    local addScore = bank_success.lUserScore - GlobalUserItem.lUserScore
    --dyj1
    --GlobalUserItem.lUserScore = self._scene._dataModel.m_secene.lPlayCurScore[1][self._scene.m_nChairID + 1] + addScore
    GlobalUserItem.lUserScore = self._scene.m_pUserItem.lScore + addScore
    --print("-------------------------------------4:"..self.m_pUserItem.lScore)
    --print("-------------------------------------44:"..GlobalUserItem.lUserScore)
    --dyj2

    
    --print("onBankSuccess addScore lUserScore",addScore,bank_success.lUserScore,GlobalUserItem.lUserScore)
    self:refreshScore()

end

--银行操作失败
function GameViewLayer:onBankFailure( )

     self._scene:dismissPopWait()
    local bank_fail = self._scene.bank_fail
    if nil == bank_fail then
        return
    end

    showToast(cc.Director:getInstance():getRunningScene(), bank_fail.szDescribeString, 2)
end


  --刷新游戏币
function GameViewLayer:refreshScore( )
    --携带游戏币
    --dyj1
    local str = ExternalFun.numberThousands(self._scene.m_pUserItem.lScore)
    --dyj2
    self.Themoney = self._scene.m_pUserItem.lScore

    if string.len(str) > 19 then
        str = string.sub(str, 1, 19)
    end

    if true == self._scene.m_bLeaveGame then
        --print("----------LeaveGame refreshScore---------------")
        return
    end
    
    if nil == self.textCurrent then
        return
    end
    self.textCurrent:setString(str)

    --银行存款
    str = ExternalFun.numberThousands(GlobalUserItem.lUserInsure)
    if string.len(str) > 19 then
        str = string.sub(str, 1, 19)
    end

    self.textBank:setString(ExternalFun.numberThousands(GlobalUserItem.lUserInsure))


   --dyj1
    --用户分数
   self:updateUserScore(self._scene.m_pUserItem.lScore)
   --dyj2

end


--子菜单
function GameViewLayer:subMenuEvent( sender , eventType)
    
    local function addBG()
        local bg = ccui.ImageView:create()
        bg:setContentSize(cc.size(yl.WIDTH, yl.HEIGHT))
        bg:setScale9Enabled(true)
        bg:setPosition(yl.WIDTH/2, yl.HEIGHT/2)
        bg:setTouchEnabled(true)
        self:addChild(bg,50)
        bg:addTouchEventListener(function (sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                bg:removeFromParent(true)
                self.textCurrent = nil
                self.textBank = nil

            end
        end)

        return bg
    end


    local function showPopWait()
        self._scene:showPopWait()
    end

    --关闭等待
    local function dismissPopWait()
        self._scene:dismissPopWait()
    end

    local tag = sender:getTag()
    if 1 == tag then --银行

        --申请取款
        local function sendTakeScore( lScore,szPassword )
            local cmddata = ExternalFun.create_netdata(g_var(game_cmd).CMD_GR_C_TakeScoreRequest)
            cmddata:setcmdinfo(g_var(game_cmd).MDM_GR_INSURE, g_var(game_cmd).SUB_GR_TAKE_SCORE_REQUEST)
            cmddata:pushbyte(g_var(game_cmd).SUB_GR_TAKE_SCORE_REQUEST)
            cmddata:pushscore(lScore)
            cmddata:pushstring(md5(szPassword),yl.LEN_PASSWORD)

            self._scene:sendNetData(cmddata)
        end


        local function onTakeScore( )
                --参数判断
                local szScore = string.gsub( self.m_editNumber:getText(),"([^0-9])","")
                local szPass =   self.m_editPasswd:getText()

                if #szScore < 1 then 
                    showToast(cc.Director:getInstance():getRunningScene(),"请输入操作金额！",2)
                    return
                end

                local lOperateScore = tonumber(szScore)
                if lOperateScore<1 then
                    showToast(cc.Director:getInstance():getRunningScene(),"请输入正确金额！",2)
                    return
                end

                if #szPass < 1 then 
                    showToast(cc.Director:getInstance():getRunningScene(),"请输入银行密码！",2)
                    return
                end
                if #szPass <6 then
                    showToast(cc.Director:getInstance():getRunningScene(),"密码必须大于6个字符，请重新输入！",2)
                    return
                end

                showPopWait()
                sendTakeScore(lOperateScore,szPass)
                
         end


        local  bg = addBG()

        local csbNode = ExternalFun.loadCSB("game_res/Bank.csb", bg)
        csbNode:setAnchorPoint(0.5,0.5)
        csbNode:setPosition(yl.WIDTH/2,yl.HEIGHT/2)

--当前游戏币
        self.textCurrent =  csbNode:getChildByName("Text_Score")
        local pos = cc.p(self.textCurrent:getPositionX(),self.textCurrent:getPositionY())
        local text = self.textCurrent:getString()
        self.textCurrent:removeFromParent(true)

        self.textCurrent = cc.Label:createWithTTF(text, "fonts/round_body.ttf", 20)
        self.textCurrent:setPosition(pos.x, pos.y)
        csbNode:addChild(self.textCurrent)


--银行存款
        self.textBank    =  csbNode:getChildByName("Text_inSave")
        pos = cc.p(self.textBank:getPositionX(),self.textBank:getPositionY())
        text = self.textBank:getString()

        self.textBank:removeFromParent(true)

        self.textBank = cc.Label:createWithTTF(text, "fonts/round_body.ttf", 20)
        self.textBank:setPosition(pos.x, pos.y)
        csbNode:addChild(self.textBank)

        self:refreshScore()

--输入取出金额

        local take = csbNode:getChildByName("Text_tipNum")
        pos = cc.p(take:getPositionX(),take:getPositionY())
        text = take:getString()

        take:removeFromParent(true)

        take = cc.Label:createWithTTF(text, "fonts/round_body.ttf", 20)
        take:setPosition(pos.x, pos.y)
        csbNode:addChild(take)


--输入银行密码  

        local password = csbNode:getChildByName("Text_tipPassWord")
        pos = cc.p(password:getPositionX(),password:getPositionY())
        text = password:getString()

        password:removeFromParent(true)

        password = cc.Label:createWithTTF(text, "fonts/round_body.ttf", 20)
        password:setPosition(pos.x, pos.y)
        csbNode:addChild(password)

--取款按钮
        local btnTake = csbNode:getChildByName("btn_takeout")
        btnTake:addTouchEventListener(function( sender , envetType )
            if envetType == ccui.TouchEventType.ended then
                onTakeScore()
            end
        end)

--关闭按钮
        local btnClose = csbNode:getChildByName("bt_close")
        btnClose:addTouchEventListener(function( sender , eventType )
            if eventType == ccui.TouchEventType.ended then
                bg:removeFromParent(true)
            end
        end)

------------------------------------EditBox---------------------------------------------------


--取款金额
    local editbox = ccui.EditBox:create(cc.size(325, 47),"bank_res/edit_frame.png")
        :setPosition(cc.p(30,take:getPositionY()))
        :setFontName("fonts/round_body.ttf")
        :setPlaceholderFontName("fonts/round_body.ttf")
        :setFontSize(24)
        :setPlaceholderFontSize(24)
        :setMaxLength(32)
        :setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
        :setPlaceHolder("请输入取款金额")
    csbNode:addChild(editbox)
    self.m_editNumber = editbox
  

    --取款密码
    editbox = ccui.EditBox:create(cc.size(325, 47),"bank_res/edit_frame.png")
        :setPosition(cc.p(30,password:getPositionY()))
        :setFontName("fonts/round_body.ttf")
        :setPlaceholderFontName("fonts/round_body.ttf")
        :setFontSize(24)
        :setPlaceholderFontSize(24)
        :setMaxLength(32)
        :setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
        :setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
        :setPlaceHolder("请输入取款密码")
    csbNode:addChild(editbox)
    self.m_editPasswd = editbox
   

---------------------------------------------------------------------------------------------------------

    elseif 2 == tag then --帮助
    
        --添加帮助层
        self.helpLayer = HelpLayer:create()
        self.helpLayer:addTo(self,30)

    elseif 3 == tag then --设置
    --添加帮助层
--        self.settingLayer= SettingLayer:create()       --------临时注释
--        self.settingLayer:addTo(self,30)              ---------
---------------------------------------------------------------------------
--        local bMute = false

--        local  bg = addBG()

--        local csbNode = ExternalFun.loadCSB("setting_res/setting.csb", bg)
--        csbNode:setAnchorPoint(0.5,0.5)
--        csbNode:setPosition(yl.WIDTH/2,yl.HEIGHT/2)

--        local btnClose = csbNode:getChildByName("bt_close")


--         btnClose:addTouchEventListener(function ( sender , eventType )
--            if eventType == ccui.TouchEventType.ended then
--                bg:removeFromParent(true)
--            end
--        end)

--        local txt_version = csbNode:getChildByName("txt_version")
--        txt_version:setVisible(false)
--        local mgr = self._scene._scene:getApp():getVersionMgr()
--        local verstr = mgr:getResVersion(Game_CMD.KIND_ID) or "0"
--        verstr = "游戏版本:" .. appdf.BASE_C_VERSION .. "." .. verstr
--        --print("----- verstr ----"..verstr)
--        local lbVersion =  cc.Label:createWithSystemFont(verstr, "Microsoft Yahei", 20)
--        lbVersion:setAnchorPoint(cc.p(1,0.5))
--        lbVersion:setColor(cc.c3b(210, 230, 240))
--        lbVersion:setPosition(cc.p(txt_version:getPositionX(), txt_version:getPositionY()))
--        csbNode:addChild(lbVersion)

--静音按钮
--        local muteBtn = csbNode:getChildByName("btn_mute")

--        if  GlobalUserItem.bVoiceAble or GlobalUserItem.bSoundAble then
--            muteBtn:loadTextureNormal("setting_res/bt_check_no.png")
--        end


--        if (self._tag == 0) and not (GlobalUserItem.bVoiceAble and GlobalUserItem.bSoundAble) then
--            self._tag = 1
--        end

--        muteBtn:addTouchEventListener(function( sender,eventType )

--            if eventType == ccui.TouchEventType.ended then

--                GlobalUserItem.bVoiceAble = not GlobalUserItem.bVoiceAble
--                GlobalUserItem.bSoundAble = GlobalUserItem.bVoiceAble

--                if  self._tag == 1 then
--                    self._tag = 2
--                    muteBtn:loadTextureNormal("setting_res/bt_check_yes.png")
--                    AudioEngine.setMusicVolume(0)
--                    AudioEngine.pauseMusic() 
--                    GlobalUserItem.bSoundAble = false
--                    GlobalUserItem.bVoiceAble = false
--                    return
--                end

--                if GlobalUserItem.bVoiceAble then

--                    muteBtn:loadTextureNormal("setting_res/bt_check_no.png")
--                    AudioEngine.resumeMusic()
--                    AudioEngine.setMusicVolume(1.0)     
--                else
--                    muteBtn:loadTextureNormal("setting_res/bt_check_yes.png")
--                    AudioEngine.setMusicVolume(0)
--                    AudioEngine.pauseMusic() -- 暂停音乐
--                end
--            end
--        end)


    else --结算
        
        --self._scene:onQueryExitGame(true)
        self._scene:onQueryExitGame()
    end
end


function GameViewLayer:ButtonEvent( sender , eventType)
    
    if eventType == ccui.TouchEventType.ended then

            local function getCannonPos()
                 --获取自己炮台
              local cannonPos = self._scene.m_nChairID

              cannonPos = CannonSprite.getPos(self._scene._dataModel.m_reversal,cannonPos)
              
              return cannonPos
            end

            local tag = sender:getTag()

            if tag == TAG.tag_autoshoot then --自动射击

              self._scene._dataModel.m_autoshoot = not self._scene._dataModel.m_autoshoot

              if self._scene._dataModel.m_autoshoot then
                  self._scene._dataModel.m_autolock = false
              end
                
              self:setAutoShoot(self._scene._dataModel.m_autoshoot,sender)
              local lock = self:getChildByTag(TAG.tag_autolock)
              self:setAutoLock(self._scene._dataModel.m_autolock,lock)

              local isauto = false
              
              if self._scene._dataModel.m_autoshoot or self._scene._dataModel.m_autolock then
                  isauto =  true
              end
             
              local cannon = self._scene.m_cannonLayer:getCannoByPos(getCannonPos() + 1)
              cannon:setAutoShoot(isauto)

              if self._scene._dataModel.m_autoshoot then
                  cannon:removeLockTag()
              end
                    
            elseif tag == TAG.tag_autolock then --自动锁定
                 
              self._scene._dataModel.m_autolock = not self._scene._dataModel.m_autolock
              if self._scene._dataModel.m_autolock then
                  self._scene._dataModel.m_autoshoot = false
              end
              
              local auto = self:getChildByTag(TAG.tag_autoshoot)
              self:setAutoShoot(self._scene._dataModel.m_autoshoot,auto)
              self:setAutoLock(self._scene._dataModel.m_autolock,sender) 

              local isauto = false

              if self._scene._dataModel.m_autoshoot or self._scene._dataModel.m_autolock then
                  isauto =  true
              end
             
              local cannon = self._scene.m_cannonLayer:getCannoByPos(getCannonPos() + 1)
              cannon:setAutoShoot(isauto)

              if self._scene._dataModel.m_autoshoot then
                  cannon:removeLockTag()
              end
            end
    end
end


function GameViewLayer:Showtips( tips )
  
    local lb =  cc.Label:createWithTTF(tips, "fonts/round_body.ttf", 20)
    local bg = ccui.ImageView:create("game_res/clew_box.png")
    lb:setTextColor(cc.YELLOW)
    bg:setScale9Enabled(true)
    bg:setContentSize(cc.size(lb:getContentSize().width + 60  , 40))
    bg:setScale(0.1)
    lb:setPosition(bg:getContentSize().width/2, 20)
    bg:addChild(lb)

    self:ShowTipsForBg(bg)

end

function GameViewLayer:Showtips1( tips, tips_score )
  
    local lb = display.newSprite(tips_score)
    local lb1 = display.newSprite(tips)
    
    local bg = display.newSprite("tips/tips_bg.png")
    local panel = ccui.Layout:create()
    panel:setAnchorPoint(0.5, 0.5)
    panel:setContentSize(500, 200)
    panel:addChild(bg)
    bg:setPosition(panel:getContentSize().width / 2, 70)
    bg:setTag(1)
    panel:addChild(lb)
    lb:setPosition(panel:getContentSize().width / 2, 63)
    lb:setTag(2)
    panel:addChild(lb1)
    lb1:setPosition(panel:getContentSize().width / 2, 145)
    lb1:setTag(3)
    self:ShowTipsForBg(panel)

end

function GameViewLayer:getCoinPos(pos, num)
    pos = cc.p(pos.x + random(-5,5), pos.y + random(-8,8))
    if num == 1 then
        return pos
    elseif num == 2 then
        return cc.p(pos.x - 90, pos.y)
    elseif num == 3 then
        return cc.p(pos.x + 90, pos.y)
    elseif num == 4 then
        return cc.p(pos.x - 180, pos.y)
    elseif num == 5 then
        return cc.p(pos.x + 180, pos.y)
    end
end


--dyj1 (保留)
function GameViewLayer:ShowCoin( score,wChairID,pos,fishtype )

--  local nMyNum = self.m_pUserItem.wChairID >= 3
--  local nPlayerNum = wChairID >= 3
    local nMyNum = self.m_pUserItem.wChairID >= 1
    local nPlayerNum = wChairID >= 1
  self._scene._dataModel:playEffect(Game_CMD.Coinfly)
  
  local nPos = wChairID
--获取炮台
  nPos = CannonSprite.getPos(self._scene._dataModel.m_reversal,nPos)

   local cannon = self._scene.m_cannonLayer:getCannoByPos(nPos + 1)

   if nil == cannon then
      return
   end

    local cannonPos = cc.p(cannon:getPositionX(),cannon:getPositionY())

   local anim = cc.AnimationCache:getInstance():getAnimation("GoldAnim")
   local coinNum = 1
   local frameName = "gold_coin_0.png"
   local distant = 62

   --金币类型
    if score ~= nil and  score == 100 then
        coinNum = 1
    elseif  score ~= nil and score >= 200 and score <= 1000 then
        coinNum = 2
    elseif  score ~= nil and score >= 1100 and score <= 10000 then
        coinNum = 3
    elseif  score ~= nil and score >= 11000 and score <= 100000 then
        coinNum = 4
    elseif  score ~= nil and score > 100000 then
        coinNum = 5
    end
    
    if nil ~= anim then
        local action = cc.RepeatForever:create(cc.Animate:create(anim))
        --local ss = ExternalFun.strFormatScore(score,num,false)
        local ss = score
              ss = string.gsub(ss,"/","")
              ss = string.gsub(ss,"[.]","/")
       -- local num = cc.LabelAtlas:_create(string.format("%d", score),"game_res/scoreNum1.png",46,58,string.byte("0"))

        local num = cc.LabelAtlas:_create(ss,"game_res/numberlabel_gold_silver.png",40,62,string.byte("/"))
        num:setAnchorPoint(0.5,0.5)
        num:setPosition(pos)
        self:addChild(num, 21)

       local silverBanner = cc.Sprite:create("game_res/toll_add_othercoin.png")
      
       silverBanner:setPosition(cc.p((silverBanner:getContentSize().width * 1.33) - (silverBanner:getContentSize().width * 2) ,num:getContentSize().height / 2 ))

        num:addChild(silverBanner)
        num:setScale(0.9)

        num:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(function()
            num:removeFromParent(true)
        end))) --cc.RemoveSelf:create(true)))

        for i=1,coinNum do
            local coin = cc.Sprite:createWithSpriteFrameName(frameName)
            coin:runAction(action:clone())
            local coinPos = self:getCoinPos(pos, i)
            coin:setPosition(coinPos)
            self:addChild(coin, 20)
            local tempTime = math.sqrt((coinPos.x - cannonPos.x) * (coinPos.x - cannonPos.x) + (coinPos.y - cannonPos.y) * (coinPos.y - cannonPos.y)) * 0.003 + random(-10,10) * 0.01
            if tempTime <= 0 then
                tempTime = 0.3
            end
            coin:runAction(cc.Sequence:create(cc.MoveTo:create(tempTime, cannonPos), cc.CallFunc:create(function()
                coin:removeFromParent(true)
            end)))   --cc.RemoveSelf:create(true)))
        end

    end

    local angle = 70.0
    local time = 0.12
    local moveY = 30.0

    if  fishtype ~= nil and fishtype >= Game_CMD.FishType.FishType_JianYu and fishtype <= Game_CMD.FishType.FishType_LiKui then
        self._scene._dataModel:playEffect(Game_CMD.bingo)
        local reward = self:getChildByTag(TAG.tag_GoldCycle + wChairID )
        if nil == reward then
            local reward = cc.Sprite:create()
            reward:setTag(TAG.tag_GoldCycle + wChairID)
            reward:initWithSpriteFrameName("Reward_Box_0.png")
            local pos = wChairID
            pos = CannonSprite.getPos(self._scene._dataModel.m_reversal, pos)
            reward:setPosition(rewardPos[pos + 1] or cc.p(667,375))
            self:addChild(reward,6)
            local animation = cc.AnimationCache:getInstance():getAnimation("rewardCircleAnim")
            if nil ~= animation then
                local action = cc.RepeatForever:create(cc.Animate:create(animation))
                reward:runAction(action)
                reward:runAction(cc.Sequence:create(cc.DelayTime:create(time*16),cc.CallFunc:create(function()
                    reward:removeFromParent()
                end)))--cc.RemoveSelf:create(true)))
            end

            local goldTxt = self:getChildByTag(TAG.tag_GoldCycleTxt + wChairID)
            if goldTxt == nil then
                --goldTxt = cc.LabelAtlas:_create(string.format("%d", score),"game_res/scoreNum1.png",46,58,string.byte("0"))
                local bToFloat = 100 == self._scene._dataModel.m_secene.MinShoot --100倍整数
                local fScaleNum = bToFloat and 0.9 or 0.6
                --local ss = ExternalFun.strFormatScore(score,goldTxt,bToFloat)
                local ss = score
                      ss = string.gsub(ss,"/","")
                      ss = string.gsub(ss,"[.]","/")
                goldTxt = cc.LabelAtlas:_create(ss,"game_res/plus_num.png",38,65,string.byte("/"))
                goldTxt:setAnchorPoint(0.5,0.5)
                goldTxt:setScale(fScaleNum)
                goldTxt.lScore = score
                goldTxt:setPosition(rewardPos[pos + 1] or cc.p(667,375))      --(pos.x, pos.y)          
                self:addChild(goldTxt,6)

                local action = cc.Sequence:create(cc.RotateTo:create(time*2,angle),cc.RotateTo:create(time*4,-angle),cc.RotateTo:create(time*2,0))
                local action0 = action:clone()
                local call = cc.CallFunc:create(function()  
                    goldTxt:removeFromParent(true)
                    goldTxt = nil
                end)

                goldTxt:runAction(cc.Sequence:create(action, action0, call))
            end
        end
    end

    if  fishtype~=nil and fishtype ~= Game_CMD.FishType_BaoXiang then

    --local bannerText = cc.LabelAtlas:_create(string.format("%d", score),"game_res/mutipleNum.png",14,17,string.byte("0"))
    
    --local ss = ExternalFun.strFormatScore(score,bannerText,false)
    local ss = score
          ss = string.gsub(ss,"/","")
          ss = string.gsub(ss,"[.]","/")
    local bannerText = cc.LabelAtlas:_create(ss,"game_res/plus_num.png",38,62,string.byte("/"))
    bannerText:setTag(TAG.tag_GoldsText)
    bannerText:setAnchorPoint(cc.p(0.5,0.5))
    bannerText:setScale(0.9)
    if cannon.m_nBannerColor == 0 then
        cannon.m_nBannerColor = 1
    else
        cannon.m_nBannerColor = 0
    end
    
    local goldBanner = cc.Sprite:create("game_res/toll_add_mycoin.png")
   
    local scale = 1.5
    local posArray = {}
    local initPos = -105
    --posArray[1] = initPos
    local moveX = 0
    local moveY = 30
    local tMoveX = 39 * scale
    local tMoveY = 0
    for i = 1, 10 do
        --posArray[i] = initPos - i * 39 * scale
        posArray[i] = initPos
    end
    if nPos ==3 or nPos ==1 then 
        if nMyNum == nPlayerNum then --最后停止的位置
            --goldBanner:setPosition(cc.p(cannonPos.x + posArray[#cannon.m_goldList + 2] + 90, cannonPos.y - 27))
            goldBanner:setPosition(cc.p(cannonPos.x - posArray[#cannon.m_goldList + 2] + 40, cannonPos.y - 27-10))
            --golds:setPosition(cc.p(goldBanner:getContentSize().width / 2, - 25 ))
        else
             moveY = -30
            --goldBanner:setPosition(cc.p(cannonPos.x + posArray[#cannon.m_goldList + 2] + 90, cannonPos.y + 5))
            goldBanner:setPosition(cc.p(cannonPos.x - posArray[#cannon.m_goldList + 2] + 40, cannonPos.y + 5-10))
            --golds:setPosition(cc.p(goldBanner:getContentSize().width / 2, 35))
        end
    elseif  nPos ==0 or nPos ==2 then
       if nMyNum == nPlayerNum then --最后停止的位置
            --goldBanner:setPosition(cc.p(cannonPos.x + posArray[#cannon.m_goldList + 2] + 90, cannonPos.y - 27))
            goldBanner:setPosition(cc.p(cannonPos.x + posArray[#cannon.m_goldList + 2] -280, cannonPos.y - 27-10))
            --golds:setPosition(cc.p(goldBanner:getContentSize().width / 2, - 25 ))
        else
             moveY = -30
            --goldBanner:setPosition(cc.p(cannonPos.x + posArray[#cannon.m_goldList + 2] + 90, cannonPos.y + 5))
            goldBanner:setPosition(cc.p(cannonPos.x +  posArray[#cannon.m_goldList + 2] -280, cannonPos.y + 5-10))
            --golds:setPosition(cc.p(goldBanner:getContentSize().width / 2, 35))
        end
    end 
    if nPos == 6 then --两边停止的最终位置
        goldBanner:setPosition(cc.p(cannonPos.x -10, cannonPos.y - posArray[#cannon.m_goldList + 2] - 100))
        --golds:setPosition(cc.p(goldBanner:getContentSize().width / 2, - 20))
        goldBanner:setRotation(90)
        moveX = 30
        moveY = 0
        tMoveX = 0
        tMoveY = -39 * scale
    elseif nPos == 7 then
        goldBanner:setPosition(cc.p(cannonPos.x + 10, cannonPos.y + posArray[#cannon.m_goldList + 2] + 100))
       -- golds:setPosition(cc.p(goldBanner:getContentSize().width / 2, - 20))
        goldBanner:setRotation(270)
        moveX = -30
        moveY = 0
        tMoveX = 0
        tMoveY = 39 * scale
    end

    local seAction = cc.Sequence:create(cc.MoveBy:create(1.5,cc.p(moveX,moveY)), cc.DelayTime:create(0.8))--0.3

    local index = #cannon.m_goldList

    if index >= 3 then
        local node = cannon.m_goldList[3]
        local text = node:getChildByTag(TAG.tag_GoldsText)
        if nil ~= text and nil~=text.lScore then
            text.lScore = text.lScore + score
            text:setString(string.format("%0.2f", text.lScore))
        end
    else
        self:addChild(goldBanner, 19)
        
       --bannerText:setPosition(cc.p(goldBanner:getContentSize().width / 2, goldBanner:getContentSize().height / 2 ))
        
        bannerText:setPosition(cc.p(bannerText:getContentSize().width/2+goldBanner:getContentSize().width ,goldBanner:getContentSize().height / 2 ))
        --yuanBanner:setPosition(cc.p(bannerText:getContentSize().width+goldBanner:getContentSize().width+yuanBanner:getContentSize().width/2,goldBanner:getContentSize().height / 2 ))

        goldBanner:addChild(bannerText)
        --goldBanner:addChild(yuanBanner)
        
       -- table.insert(cannon.m_goldList,goldBanner)
        goldBanner:runAction(cc.Sequence:create(seAction, cc.CallFunc:create(function()
            -- if nil ==  cannon.m_goldList then
            --     return
            -- end 

            -- if #cannon.m_goldList  and (#cannon.m_goldList == 1 or goldBanner == cannon.m_goldList[1]) then
            --     goldBanner:removeAllChildren()
            --     goldBanner:removeFromParent(true)
            --     table.remove(cannon.m_goldList,1)
            -- end
            -- if #cannon.m_goldList > 1 then
            --     for i = 1, #cannon.m_goldList do
            --         local node = cannon.m_goldList[i]
            --         if node then                
            --             node:runAction(cc.Sequence:create(cc.MoveBy:create(0.6,cc.p(tMoveX,tMoveY)),  cc.CallFunc:create(function()
            --                cannon:moveAllBannerAndGolds(node)

            --             end) ))
            --         end
            --     end
            -- end
            goldBanner:removeFromParent(true)

      end)))
    end

end
end
--dyj2

function GameViewLayer:ShowAwardTip(data)


 local fishName = {"小黄刺鱼","小草鱼","热带黄鱼","大眼金鱼","热带紫鱼","小丑鱼","河豚鱼","狮头鱼","灯笼鱼","海龟","神仙鱼","蝴蝶鱼","铃铛鱼","剑鱼","魔鬼鱼","大白鲨","大金鲨",
    "巨型黄金鲨","金龙","绿色千年龟摇钱树","银色千年龟摇钱树","金色千年龟摇钱树","漂流瓶","屠龙刀","火山","宝箱","元宝"}

  local labelList = {}

  local tipStr  = ""
  local tipStr1 = ""
  local tipStr2 = ""

  if data.nFishMultiple >= 50 then
    if data.nScoreType == Game_CMD.SupplyType.EST_Cold then
       tipStr = "捕中了"..fishName[data.nFishType+1]..",获得"
    elseif data.nScoreType == Game_CMD.SupplyType.EST_Laser then
       tipStr = "使用激光,获得"
    end

  tipStr1 = string.format("%d倍 %d分数",data.nFishMultiple,data.lFishScore)
  if data.nFishMultiple > 500 then
     tipStr2 = "超神了!!!"
  elseif data.nFishMultiple == 19 then
       tipStr2 = "运气爆表!!!"   
  else
      tipStr2 = "实力超群!!!"     
  end

  local name = data.szPlayName
  local tableStr = nil
  if data.wTableID == self._scene.m_nTableID  then 
    tableStr = "本桌玩家"

  else
       tableStr = string.format("第%d桌玩家",data.wTableID+1)

  end

  local lb1 =  cc.Label:createWithTTF(tableStr, "fonts/round_body.ttf", 20)
  lb1:setTextColor(cc.YELLOW)
  lb1:setAnchorPoint(0,0.5)
  table.insert(labelList, lb1)
 

  local lb2 =  cc.Label:createWithTTF(name, "fonts/round_body.ttf", 20)
  lb2:setTextColor(cc.RED)
  lb2:setAnchorPoint(0,0.5)
  table.insert(labelList, lb2)

  local lb3 =  cc.Label:createWithTTF(tipStr, "fonts/round_body.ttf", 20)
  lb3:setTextColor(cc.YELLOW)
  lb3:setAnchorPoint(0,0.5)
  table.insert(labelList, lb3)

  local lb4 =  cc.Label:createWithTTF(tipStr1, "fonts/round_body.ttf", 20)
  lb4:setTextColor(cc.RED)
  lb4:setAnchorPoint(0,0.5)
  table.insert(labelList, lb4)

  local lb5 =  cc.Label:createWithTTF(tipStr2, "fonts/round_body.ttf", 20)
  lb5:setTextColor(cc.YELLOW)
  lb5:setAnchorPoint(0,0.5)
  table.insert(labelList, lb5)

  else

    local lb1 =  cc.Label:createWithTTF("恭喜你捕中了补给箱,获得", "fonts/round_body.ttf", 20)
    lb1:setTextColor(cc.YELLOW)
    lb1:setAnchorPoint(0,0.5)

    local lb1 =  cc.Label:createWithTTF(string.format("%d倍 %d分数 !", data.nFishMultiple,data.lFishScore), "fonts/round_body.ttf", 20)
    lb1:setTextColor(cc.RED)
    lb1:setAnchorPoint(0,0.5)

    table.insert(labelList, lb1)
    table.insert(labelList, lb2)

  end



  local length = 60
  for i=1,#labelList do
    local lb = labelList[i]
    lb:setPosition(length - 30 , 20)
    length =  length + lb:getContentSize().width + 5 
  end


   local bg = ccui.ImageView:create("game_res/clew_box.png")
    bg:setScale9Enabled(true)
  
    bg:setContentSize(length,40)
    bg:setScale(0.1)

    for i=1,#labelList do
      local lb = labelList[i]
      bg:addChild(lb)
    end

    self:ShowTipsForBg(bg)
    labelList = {}
end


function GameViewLayer:ShowTipsForBg( bg )

  local infoCount = #self._scene.m_infoList
  local sublist = {}

  while infoCount >= 3 do

    local node = self._scene.m_infoList[1]
    table.remove(self._scene.m_infoList,1)
    node:removeFromParent(true)

    for i=1,#self._scene.m_infoList do
      local bg1 = self._scene.m_infoList[i]
      bg1:runAction(cc.FadeTo:create(0.2, 0))
    end

    infoCount = #self._scene.m_infoList
  end

  bg:setPosition(yl.WIDTH/2, 375)
  self:addChild(bg,2000)
  table.insert(self._scene.m_infoList, bg)

  local call = cc.CallFunc:create(function()
    bg:removeAllChildren()
    bg:removeFromParent(true)
    for i=1,#self._scene.m_infoList do
      local _bg = self._scene.m_infoList[i]
      if bg == _bg then
        table.remove(self._scene.m_infoList,i)
        break
      end
    end

  end)
  local c1 = bg:getChildByTag(1)
  local c2 = bg:getChildByTag(2)
  local c3 = bg:getChildByTag(3)
  if c1 then
    c1:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.FadeTo:create(2, 0)))
  end
  if c2 then
    c2:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.FadeTo:create(2, 0)))
  end
  if c3 then
    c3:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.FadeTo:create(2, 0)))
  end
  bg:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.FadeTo:create(2, 0),call)) 
end

--打中宝箱
function GameViewLayer:catchBox(wChairID, index)
    index = index or 0
    index = index + 1
    local pos = wChairID
    pos = CannonSprite.getPos(self._scene._dataModel.m_reversal, pos)

    local spZhuan = cc.Sprite:create("tips/ZhuanPan.png")
	spZhuan:addTo(self, 20)
	spZhuan:setPosition(rewardPos[pos + 1])
	
	local spZhuanZhen = cc.Sprite:create("tips/ZhuanPanZhen.png")
	spZhuanZhen:addTo(self, 20)
	spZhuanZhen:setPosition(rewardPos[pos + 1])

    local angle = 45 / 2 * (index * 2 - 1) + 360 * 5
	local act = cc.RotateTo:create(3, angle)
	local easeRotate = cc.EaseCircleActionOut:create(act)
	local call1 = cc.CallFunc:create(function()
		local sp = display.newSprite(string.format("tips/tips_box_%d.png", index))
			sp:setPosition(rewardPos[pos + 1])
			sp:addTo(self, 20)
			sp:setName("tips_reward")
	end)
	local call2 = cc.CallFunc:create(function()
		local sp = self:getChildByName("tips_reward")
		if sp ~= nil then
			sp:removeFromParent(true)
		end
        spZhuan:removeFromParent(true)
        spZhuanZhen:removeFromParent(true)
	end)

	spZhuan:runAction(cc.Sequence:create(easeRotate, call1, cc.DelayTime:create(1.5), call2))

end

return GameViewLayer
