--
-- Author: Tang
-- Date: 2016-08-09 10:31:32
-- 预加载资源
local PreLoading = {}
local module_pre = "game.yule.lkpy.src"	
local cmd = module_pre .. ".models.CMD_LKGame"
local ExternalFun = require(appdf.EXTERNAL_SRC.."ExternalFun")
local g_var = ExternalFun.req_var

local Game_Path_Manager = appdf.req(module_pre .. ".models.Game_Path_Manager")

PreLoading.bLoadingFinish = false
PreLoading.loadingPer = 0
PreLoading.bFishData = false
local mycoroutine = appdf.req(module_pre..".models.mycoroutine")


function PreLoading.resetData()
	PreLoading.bLoadingFinish = false
	PreLoading.loadingPer = 0
	PreLoading.bFishData = false
end

function PreLoading.StopAnim(bRemove)

	local scene = cc.Director:getInstance():getRunningScene()
	local layer = scene:getChildByTag(2000) 

	if not layer  then
		return
	end

	if not bRemove then
		if nil ~= PreLoading.fish then
			PreLoading.fish:stopAllActions()
		end
	else
	
		layer:stopAllActions()
		layer:removeFromParent()
	end
end

function PreLoading.loadTextures(GameScene)


	Game_Path_Manager:shared()
	Game_Path_Manager:initialise_paths()


	PreLoading.GameLoadingView()

	local m_nImageOffset = 0

	local totalSource = 1--17 


	local newPlist = 
	{
		"gunbullet.plist",
		"fish_dead.plist",
		"fish_dead1.plist",
		"fish_dead2.plist",
		"fish_dead3.plist",
		"fish_dead4.plist",
		"fish_move.plist",
		"fish_move1.plist",
		"fish_move2.plist",
		"fish_move3.plist",
		"fish_move4.plist",
		"fish_move5.plist",
		"fish_move6.plist",
		"fish_move7.plist",
		"fish_move8.plist",
		"fish_move9.plist",
		"fish_move10.plist",
		"lock_fish.plist",
		"fish_gold.plist",
		"wave.plist",
		"boom_darts.plist",
		"bomb.plist",
		"blue.plist",
		"watch.plist",
	}
	local newPng = 
	{
		"gunbullet.png",
		"fish_dead.png",
		"fish_dead1.png",
		"fish_dead2.png",
		"fish_dead3.png",
		"fish_dead4.png",
		"fish_move.png",
		"fish_move1.png",
		"fish_move2.png",
		"fish_move3.png",
		"fish_move4.png",
		"fish_move5.png",
		"fish_move6.png",
		"fish_move7.png",
		"fish_move8.png",
		"fish_move9.png",
		"fish_move10.png",
		"lock_fish.png",
		"fish_gold.png",
		"wave.png",
		"boom_darts.png",
		"bomb.png",
		"blue.png",
		"watch.png",
	}

	local resNum = #newPng

	-- local loadText = ccui.Text:create()
 --    loadText:setString("")
 --    loadText:setFontSize(20)
 --    loadText:setTouchScaleChangeEnabled(true)
 --    loadText:setPosition(cc.p(200,600))
 --    loadText:setTouchEnabled(true)

    for i=1,3 do
    	cc.SpriteFrameCache:getInstance():addSpriteFrames("cannon/gun1_"..i..".png")
    end
    cc.SpriteFrameCache:getInstance():addSpriteFrames("lock_fish/lock_line.png")

    cc.SpriteFrameCache:getInstance():addSpriteFrames("jetton.png")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("jetton_bgc1.png")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("jetton_bgc2.png")

	local function imageLoaded(texture)
   		if nil == GameScene or nil == PreLoading.m_scheduleUpdate then 
   			return
   		end
   		-- --print("Image loaded:..."..texture:getPath())
        m_nImageOffset = m_nImageOffset + 1

        PreLoading.loadingPer = 20 + m_nImageOffset*2

        if m_nImageOffset == totalSource then

        	--加载PLIST
        	-- for i=1,#newPlist do
        		if m_nImageOffset == 1 then
        			-- cc.SpriteFrameCache:getInstance():addSpriteFrames("game_res/"..newPlist[i])
        			cc.SpriteFrameCache:getInstance():addSpriteFrames("game_res/"..newPlist[m_nImageOffset])
        		else
        			-- cc.SpriteFrameCache:getInstance():addSpriteFrames("fish/"..newPlist[i])
        			cc.SpriteFrameCache:getInstance():addSpriteFrames("fish/"..newPlist[m_nImageOffset])
        		end
        	-- end

        	----print("资源加载 ",m_nImageOffset)
        	-- loadText:setString("资源加载v1.0: "..m_nImageOffset)
        	totalSource = totalSource + 1
    		-- cc.Director:getInstance():pause()
        	if m_nImageOffset == resNum then
        		GameScene:sceneKindTrace()
        		PreLoading.readAniams()
        		PreLoading.bLoadingFinish = true
        		----print("加载完成hehe ",m_nImageOffset)
        		-- loadText:setString("加载完成hehe "..m_nImageOffset)

        		--通知
				local event = cc.EventCustom:new(g_var(cmd).Event_LoadingFinish)
				cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
				local event = cc.EventCustom:new(g_var(cmd).Event_FishCreate)
        		cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
				-- --print("这是啥？？？？？？？？？",tostring(PreLoading.bFishData))
				if PreLoading.bFishData then
					
					local scene = cc.Director:getInstance():getRunningScene()
					local layer = scene:getChildByTag(2000) 

					if not layer  then
						return
					end

					PreLoading.loadingPer = 100
					PreLoading.updatePercent(PreLoading.loadingPer)
					local callfunc = cc.CallFunc:create(function()
						-- PreLoading.loadingBar:stopAllActions()
						-- PreLoading.loadingBar = nil
			
						layer:stopAllActions()
						layer:removeFromParent()
					end)

					layer:stopAllActions()
					layer:runAction(cc.Sequence:create(cc.DelayTime:create(2.2),callfunc))
				end

	        	----print("资源加载完成")
	        	-- loadText:setString("资源加载完成 ")
	        else
	        	cc.Director:getInstance():getTextureCache():addImageAsync("fish/"..newPng[m_nImageOffset+1], imageLoaded)
	        	----print("加载png ",m_nImageOffset+1)
	        	-- loadText:setString("加载png "..m_nImageOffset+1)

        	end
        	
        	
        end
    end
    
    local function 	loadImages()
      	cc.Director:getInstance():getTextureCache():addImageAsync("game_res/gunbullet.png", imageLoaded)
    end


    local function createSchedule( )
    	local function update( dt )
    		-- --print("一直加载进度？ ",PreLoading.loadingPer)
    -- 		PreLoading.loadingPer = PreLoading.loadingPer + 50 
    -- 		PreLoading.updatePercent(PreLoading.loadingPer)
    -- 		if PreLoading.loadingPer >= 100 then
    -- 		    PreLoading.bLoadingFinish = true  
    -- 		    local event = cc.EventCustom:new(g_var(cmd).Event_LoadingFinish)
				-- cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
    -- 			PreLoading.Finish()
    -- 		end
			PreLoading.updatePercent(PreLoading.loadingPer)
		end

		local scheduler = cc.Director:getInstance():getScheduler()
		PreLoading.m_scheduleUpdate = scheduler:scheduleScriptFunc(update, 0.5, false)
    end

	loadImages()

 --    local scene = cc.Director:getInstance():getRunningScene()
	-- local layer = scene:getChildByTag(2000) 
	-- layer:addChild(loadText,100)
	-- local function menuCloseCallback( sender,eventType)
 --        if eventType == ccui.TouchEventType.ended then
 --            -- cc.Director:getInstance():resume()
 --        end
 --    end
 --    loadText:addTouchEventListener(menuCloseCallback)

	createSchedule()

	PreLoading.addEvent()

end

function PreLoading.addEvent()

   --通知监听
  local function eventListener(event)
  	--print("通知加载完成-------------------------------------")
  	cc.Director:getInstance():getEventDispatcher():removeCustomEventListeners(g_var(cmd).Event_FishCreate)
	PreLoading.Finish()
  end

  local listener = cc.EventListenerCustom:create(g_var(cmd).Event_FishCreate, eventListener)
  cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)

end

function PreLoading.Finish()
	
	PreLoading.bFishData = true
	--print("加载完成了-----------------------",PreLoading.bLoadingFinish)
	if  PreLoading.bLoadingFinish then
		PreLoading.loadingPer = 100
		PreLoading.updatePercent(PreLoading.loadingPer)

		local scene = cc.Director:getInstance():getRunningScene()
		local layer = scene:getChildByTag(2000) 

		if nil ~= layer then
			local callfunc = cc.CallFunc:create(function()
				-- PreLoading.loadingBar:stopAllActions()
				-- PreLoading.loadingBar = nil
				-- PreLoading.fish:stopAllActions()
				PreLoading.fish = nil
				layer:stopAllActions()
				layer:removeFromParent()

			end)

			layer:stopAllActions()
			layer:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),callfunc))

		end
	end
end

function PreLoading.GameLoadingView()
	
	local scene = cc.Director:getInstance():getRunningScene()
	local layer = display.newLayer()
	layer:setTag(2000)
	scene:addChild(layer,30)

	local loadingBG = ccui.ImageView:create("loading/bg.png")
	-- loadingBG:setVisible(false)
	loadingBG:setTag(1)
	loadingBG:setTouchEnabled(true)
	loadingBG:setPosition(cc.p(yl.WIDTH/2,yl.HEIGHT/2))
	layer:addChild(loadingBG)

	local bar = cc.Sprite:create("loading/loading_bar.png")

    PreLoading.loadingBar = cc.ProgressTimer:create(bar)
	PreLoading.loadingBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	PreLoading.loadingBar:setAnchorPoint(cc.p(0, 0))
	PreLoading.loadingBar:setMidpoint(cc.p(0.0,0.5))
	PreLoading.loadingBar:setBarChangeRate(cc.p(1,0))
    PreLoading.loadingBar:setPosition(cc.p(257, 33))
    PreLoading.loadingBar:runAction(cc.ProgressTo:create(0.2,1))
    loadingBG:addChild(PreLoading.loadingBar)

    PreLoading.fish = cc.Sprite:create("loading/loading_bar_ico.png")
    PreLoading.fish:setAnchorPoint(cc.p(0, 0.5))
    PreLoading.fish:setPosition(cc.p(230,80))
    loadingBG:addChild(PreLoading.fish)

	local move = cc.MoveTo:create(0.2,cc.p(1180*(24/100), 80))
	move:setTag(1)
    PreLoading.fish:runAction(move)

	-- local callfunc = cc.CallFunc:create(function()
	-- 	mycoroutine.create()
	-- end)
 --    layer:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),callfunc))
end

function PreLoading.updatePercent(percent )
	
	if nil ~= PreLoading.fish then

		local dt = 0.1
		-- if percent == 100 then
		-- 	dt = 0.1
		-- end
		PreLoading.loadingBar:runAction(cc.ProgressTo:create(dt,percent))
		--if percent == 100 then
			-- PreLoading.loadingBar:setScaleX(1.1)
		--end

		cc.Director:getInstance():getActionManager():removeActionByTag(1, PreLoading.fish)
		local move =  cc.MoveTo:create(dt, cc.p(230 + 935*(percent/100), 80))
		move:setTag(1)
		PreLoading.fish:runAction(move)

	end

	if PreLoading.bLoadingFinish then
		----print("删除加载计时器？？？？？？？？？？？？？？？？？？？？？？？")
		if nil ~= PreLoading.m_scheduleUpdate then
			-- PreLoading.fish:setVisible(false)
    		local scheduler = cc.Director:getInstance():getScheduler()
			scheduler:unscheduleScriptEntry(PreLoading.m_scheduleUpdate)
			PreLoading.m_scheduleUpdate = nil
		end
	end

end


function PreLoading.unloadTextures( )
	local delFile = 
	{
		"gunbullet.",
		"fish_dead.",
		"fish_dead1.",
		"fish_dead2.",
		"fish_dead3.",
		"fish_dead4.",
		"fish_move.",
		"fish_move1.",
		"fish_move2.",
		"fish_move3.",
		"fish_move4.",
		"fish_move5.",
		"fish_move6.",
		"fish_move7.",
		"fish_move8.",
		"fish_move9.",
		"fish_move10.",
		"lock_fish.",
		"fish_gold.",
		"boom_darts.",
		"bomb.",
		"blue.",
	}
	for i=1, #delFile do
		local qz = "fish/"
		if i == 1 then
			qz = "game_res/"
		end
		cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(qz..delFile[i].."plist")
		cc.Director:getInstance():getTextureCache():removeTextureForKey(qz..delFile[i].."png")
	end

    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
	if nil ~= PreLoading.m_scheduleUpdate then
		local scheduler = cc.Director:getInstance():getScheduler()
		scheduler:unscheduleScriptEntry(PreLoading.m_scheduleUpdate)
		PreLoading.m_scheduleUpdate = nil
	end
end


--[[
@function : readAnimation
@file : 资源文件
@key  : 动作 key
@num  : 幀数
@time : float time 
@formatBit 

]]

function PreLoading.readAnimation(file, key, num, time,formatBit)
	local frames = {}
   	local actionTime = time
	for i=1,num do

		local frameName
		if formatBit == 1 then
			frameName = string.format(file.."%d.png", i-1)
		elseif formatBit == 2 then
		 	frameName = string.format(file.."%2d.png", i-1)
		end
		local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
		
		table.insert(frames, frame)
	end

	local  animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
   	cc.AnimationCache:getInstance():addAnimation(animation, key)
end

function PreLoading.readAniByFileName( file,width,height,rownum,linenum,savename)
	local frames = {}
	for i=1,rownum do
		for j=1,linenum do
			
			local frame = cc.SpriteFrame:create(file,cc.rect(width*(j-1),height*(i-1),width,height))
			table.insert(frames, frame)
		end
		
	end
	local  animation =cc.Animation:createWithSpriteFrames(frames,0.03)
   	cc.AnimationCache:getInstance():addAnimation(animation, savename)
end

function PreLoading.removeAllActions()
	-- error("zzz")
	--鱼游动动画
	for i=1,g_var(cmd).Fish_MOVE_TYPE_NUM do
		
		local key = string.format("animation_fish_move%d", i)
		cc.AnimationCache:getInstance():removeAnimation(key)

		if i == g_var(cmd).Fish_MOVE_TYPE_NUM then
			key = string.format("animation_fish_move%d", i+1)
			cc.AnimationCache:getInstance():removeAnimation(key)
		end
	end

	-- --鱼死亡动画
	for i=1,g_var(cmd).Fish_DEAD_TYPE_NUM do
		local key = string.format("animation_fish_dead%d", i)
		cc.AnimationCache:getInstance():removeAnimation(key)
	end	

	for i=1, 10 do 
		local key  = string.format("animation_bullet1_norm%d", i)
		local key1 = string.format("animation_bullet2_norm%d", i)
		local key2 = string.format("animation_bullet3_norm%d", i)
		local key4 = string.format("animation_bullet4_norm%d", i)

		cc.AnimationCache:getInstance():removeAnimation(key)
		cc.AnimationCache:getInstance():removeAnimation(key1)
		cc.AnimationCache:getInstance():removeAnimation(key2)
		cc.AnimationCache:getInstance():removeAnimation(key4)
	end

	for i=1, 4 do
		local key  = string.format("animation_spbullet_norm%d", i)
		cc.AnimationCache:getInstance():removeAnimation(key)
	end

	cc.AnimationCache:getInstance():removeAnimation("goldAnim")
	cc.AnimationCache:getInstance():removeAnimation("bingoAnim")
	cc.AnimationCache:getInstance():removeAnimation("BombAnim")
	cc.AnimationCache:getInstance():removeAnimation("BlueIceAnim")
	cc.AnimationCache:getInstance():removeAnimation("BombDartsAnim")

end

function PreLoading.readAniams()

	local fishFrameMoveNum =
	{
		16,12,24,
	    24,24,25,
	    12,10,12,
	    60,20,24,
	    16,24,12,
	    24,20,24,
	    24,24,9,
	    9,20,15,
	    15,8,1
	}

	local fishFrameDeadNum =
	{
		5,3,3,
	    10,3,6,
	    3,6,4,
	    7,4,4,
	    4,3,6,
	    6,4,3,
	    4,20,9,
	    15,8,2
	}

	local frames = {}
	-- PreLoading.readAnimation("water","WaterAnim",16,0.12,1)

	--鱼游动动画
	for i=1, g_var(cmd).Fish_MOVE_TYPE_NUM do
		local actionTime = 0.09
		frames = {}
		local num = fishFrameMoveNum[i]
    	for j=1,num do
	        local frameName = string.format("fish%d_%02d.png",i,j) --fish2_01  fish14_16
	        if i <= 3 then 
	        	-- --print("load frameName : ",frameName)
	        end
	      --  --print("frameName is =========================================================="..frameName)
	        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
	        table.insert(frames, frame)
    	end

    	local animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
		local key = string.format("animation_fish_move%d", i)
		cc.AnimationCache:getInstance():addAnimation(animation, key)

		--最后一个加载特殊的
		if i == g_var(cmd).Fish_MOVE_TYPE_NUM then
			frames = {}
			local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("fish24.png") 
	        table.insert(frames, frame)

	        local animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
			local key = string.format("animation_fish_move%d", i+1)
			cc.AnimationCache:getInstance():addAnimation(animation, key)
		end
	end

	--鱼死亡动画
	for i=1,g_var(cmd).Fish_DEAD_TYPE_NUM do
		frames = {}
		local actionTime = 0.1
		local num = fishFrameDeadNum[i]

    	for j=1,num do
	        local frameName = string.format("fish%d_d_%02d.png",i,j)  --    fish2_d_01  fish23_d_01
	        -- --print("load dead frameName : ",frameName)
	        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
	        table.insert(frames, frame)
    	end

    	local animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
		local key = string.format("animation_fish_dead%d", i)

		cc.AnimationCache:getInstance():addAnimation(animation, key)
 		-- if i == 3 then error("stiop") end
	end

	----加载子弹动画
	for i=1,10 do
		frames = {}
		local actionTime = 0.5
    	for j=1,2 do
	        local frameName = string.format("bullet1_norm%d_%02d.png",i,j)
	        ----print("load bullet frameName : ",frameName)
	        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
	        table.insert(frames, frame)
    	end

    	local animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
		local key = string.format("animation_bullet1_norm%d",i)

		cc.AnimationCache:getInstance():addAnimation(animation, key)
 
	end

	for i=1,10 do
		frames = {}
		local actionTime = 0.5
    	for j=1,2 do
	        local frameName = string.format("bullet2_norm%d_%02d.png",i,j)
	        ----print("load bullet frameName : ",frameName)
	        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
	        table.insert(frames, frame)
    	end

    	local animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
		local key = string.format("animation_bullet2_norm%d",i)

		cc.AnimationCache:getInstance():addAnimation(animation, key)
 
	end

	for i=1,10 do
		frames = {}
		local actionTime = 0.5
    	for j=1,2 do
	        local frameName = string.format("bullet3_norm%d_%20d.png",i,j)
	        ----print("load bullet frameName : ",frameName)
	        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
	        table.insert(frames, frame)
    	end

    	local animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
		local key = string.format("animation_bullet3_norm%d",i)

		cc.AnimationCache:getInstance():addAnimation(animation, key)
 
	end

	for i=1,10 do
		frames = {}
		local actionTime = 0.5
    	for j=1,2 do
	        local frameName = string.format("bullet4_norm%d_%02d.png",i,j)
	        ----print("load bullet frameName : ",frameName)
	        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
	        table.insert(frames, frame)
    	end

    	local animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
		local key = string.format("animation_bullet4_norm%d",i)

		cc.AnimationCache:getInstance():addAnimation(animation, key)
 
	end

	--加载特殊子弹
	for i=1, 4 do
		frames = {}
		local actionTime = 0.5
		for j=1, 2 do
			local frameName = string.format("bullet%d_ion_%02d.png",i,j) -- bullet2_ion_01.png
	        ----print("load bullet sp frameName : ",frameName)
	        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
	        table.insert(frames, frame)
		end

		local animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
		local key = string.format("animation_spbullet_norm%d",i)

		cc.AnimationCache:getInstance():addAnimation(animation, key)
	end

	--金币图
	frames = {}
	for i=1, 12 do 
		local actionTime = 0.08
		local frameName = string.format("coin2_%02d.png",i) -- coin2_01.png
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)
        frames[i] = frame

        if i == 12 then
			local animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
			local key = "goldAnim"

			cc.AnimationCache:getInstance():addAnimation(animation, key)
		end
	end

	frames = {}
	for i=1, 10 do 
		local actionTime = 0.08
		local frameName = string.format("bingo_%02d.png",i) -- bingo__01.png
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)
        frames[i] = frame

        if i == 10 then
			local animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
			local key = "bingoAnim"

			cc.AnimationCache:getInstance():addAnimation(animation, key)
		end
	end

	frames = {}
	for i=1, 2 do 
		local actionTime = 0.1
		local frameName = string.format("wave_%d.png",i)
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)
        frames[i] = frame

        if i == 2 then
			local animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
			local key = "waveAnim"

			cc.AnimationCache:getInstance():addAnimation(animation, key)
		end
	end

	-- --元宝鱼游动动画
	-- frames = {}
	-- local actionTime = 0.05
	-- for i=1,2 do
	-- 	local frameName = string.format("fishMove_ignot_%d.png", i)
	-- 	local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
	-- 	table.insert(frames, frame)
	-- end

	-- local  animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
 --   	cc.AnimationCache:getInstance():addAnimation(animation, "fish_ignot_move")

 --   	--元宝鱼死亡动画
 --   	frames = {}
 --   	local actionTime = 0.05
	-- for i=1,8 do
	-- 	local frameName = string.format("fishDead_ignot_%d.png", i)
	-- 	local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
	-- 	table.insert(frames, frame)
	-- end

	-- local  animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
 --   	cc.AnimationCache:getInstance():addAnimation(animation, "fish_ignot_dead")

 --   	--元宝鱼游戏币翻滚动画
 --   	frames = {}
 --   	local actionTime = 0.05
	-- for i=1,15 do
	-- 	local frameName = string.format("ignot_coin_%d.png", i)
	-- 	local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
	-- 	table.insert(frames, frame)
	-- end

	-- local  animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
 --   	cc.AnimationCache:getInstance():addAnimation(animation, "fish_ignot_coin")

   	-- PreLoading.readAnimation("water_","WaterAnim",12,0.12,1)
   	-- PreLoading.readAnimation("fort_","FortAnim",6,0.02,1)
   	-- PreLoading.readAnimation("fort_light_", "FortLightAnim", 6, 0.02,1);
    -- PreLoading.readAnimation("silver_coin_", "SilverAnim", 12, 0.05,1);
    -- PreLoading.readAnimation("gold_coin_", "GoldAnim", 12, 0.08,1);
    -- PreLoading.readAnimation("copper_coin_", "CopperAnim", 10, 0.05,1);
    PreLoading.readAnimation("boom", "BombAnim", 32,0.1,2);
    PreLoading.readAnimation("boom_darts", "BombDartsAnim", 33,0.03,1);
    PreLoading.readAnimation("blue", "BlueIceAnim", 22,0.03,2);
    -- PreLoading.readAnimation("bullet_", "BulletAnim", 10,1);
    -- PreLoading.readAnimation("light_", "LightAnim", 16, 0.05,1);
    PreLoading.readAnimation("watch_", "watchAnim", 24, 0.08,1);

    -- PreLoading.readAniByFileName("game_res/fish_bomb_ball.png", 70, 70, 2, 5, "FishBall")
    -- PreLoading.readAniByFileName("game_res/fish_bomb_light.png", 40, 256, 1, 6, "FishLight")
end

return PreLoading