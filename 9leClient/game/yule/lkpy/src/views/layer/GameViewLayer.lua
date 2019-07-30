
--
-- Author: Tang
-- Date: 2016-08-09 14:46:36
--
local GameViewLayer = class("GameViewLayer", function(scene)
			local gameViewLayer = display.newLayer()
			return gameViewLayer

	end)

--Tag
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
    tag_Menu = 5000
}
local CHANGE_MULTIPLE_INTERVAL =  0.8
local  TAG = GameViewLayer.VIEW_TAG

local ExternalFun = require(appdf.EXTERNAL_SRC.."ExternalFun")
local g_var = ExternalFun.req_var
local ClipText = appdf.EXTERNAL_SRC .. "ClipText"
local module_pre = "game.yule.lkpy.src"	
local game_cmd = appdf.HEADER_SRC .. "CMD_GameServer"
local PRELOAD = require(module_pre..".views.layer.PreLoading") 
local cmd = module_pre .. ".models.CMD_LKGame"
local scheduler = cc.Director:getInstance():getScheduler()

function GameViewLayer:ctor( scene )
    self.showTips = false
    self._tag = 0
	self._scene = scene
	self:addSerchPaths()
    --预加载资源
    --print("预加载资源---------------")
    PRELOAD.loadTextures(scene)

      --注册事件
    ExternalFun.registerTouchEvent(self,true)
    self.m_bCanChangeMultple = true
end

function GameViewLayer:onExit()
    --print("退出加载资源---------------")
    local cannon = self._scene.m_cannonLayer:getCannoByPos(self._scene.m_nChairID + 1)
    if cannon~=nil then 
        cannon:setAutoShoot(false)
    end
    PRELOAD.unloadTextures()
    PRELOAD.removeAllActions()
    PRELOAD.loadingBar = nil

    PRELOAD.resetData()

    self:StopLoading(true)

    --播放大厅背景音乐
    ExternalFun.playPlazzBackgroudAudio()

    --重置搜索路径
    local oldPaths = cc.FileUtils:getInstance():getSearchPaths();
    local newPaths = {};
    for k,v in pairs(oldPaths) do
        if tostring(v) ~= tostring(self._searchPath) then
            table.insert(newPaths, v);
        end
    end
    cc.FileUtils:getInstance():setSearchPaths(newPaths);

end

function GameViewLayer:StopLoading( bRemove )
    --print("停止加载---------------")
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
          if tonumber(v._KindID) == tonumber(g_var(cmd).KIND_ID) then
            gameInfo = v;
            break;
        end
    end

    if nil ~= gameInfo._KindName then
        self._searchPath = device.writablePath.."game/" .. gameInfo._Module .. "/res/";
        -- self._searchPath = "game/" .. gameInfo._Module .. "/res/";
        -- --print("self._searchPath ",self._searchPath)
        -- --print("fa ",device.writablePath)
        -- error("fff")
        cc.FileUtils:getInstance():addSearchPath(self._searchPath);
    end


end

-- function GameViewLayer:changeMultipleSchedule( dt )

--     local function  update( dt  )
--         self:multipleUpdate()
--     end

--     if nil == self.multipleSchedule then
--         self.multipleSchedule = scheduler:scheduleScriptFunc(update, dt, false)
--     end
    
-- end

-- function GameViewLayer:unMultipleSchedule()
--     self.m_bCanChangeMultple = true
--     if nil ~= self.multipleSchedule then
--         scheduler:unscheduleScriptEntry(self.multipleSchedule)
--         self.multipleSchedule = nil
--     end
-- end

-- function GameViewLayer:multipleUpdate()
--     self:unMultipleSchedule()  
-- end
function GameViewLayer:setCurGold( gold )
    self.labelMutiple:setString(gold)
end
function GameViewLayer:initView(  scneneID)
    local bg =  ccui.ImageView:create("Scene/bg"..scneneID..".jpg")
	bg:setAnchorPoint(cc.p(.5,.5))
    bg:setTag(TAG.tag_bg)
	bg:setPosition(cc.p(yl.WIDTH/2,yl.HEIGHT/2))
	self:addChild(bg)
    local water = self:createWater()
    bg:addChild(water)
    --------------------------创建底部UI-------------------------------
    local leftright = {"self_info/left_img.png", "self_info/right_img.png"}
    for i=1,2 do --两边边框
        local kuang = ccui.ImageView:create(leftright[i])
        kuang:setAnchorPoint(cc.p(0, 0))
        if i == 1 then
            kuang:setAnchorPoint(cc.p(0, 0))
            kuang:setPosition(cc.p(0, 0))
        else
            kuang:setAnchorPoint(cc.p(1, 0))
            kuang:setPosition(cc.p(yl.WIDTH, 0))
        end
        kuang:setVisible(false)
        self:addChild(kuang,6)
    end

    local nickNameBg = ccui.ImageView:create("self_info/nickname_bg.png")
    nickNameBg:setAnchorPoint(cc.p(0.5,0.5))
    nickNameBg:setPosition(cc.p(190, 21))
    :setVisible(false)
    self:addChild(nickNameBg,6)

    local nick =  cc.Label:createWithTTF(self._scene._gameFrame:GetMeUserItem().szNickName, "fonts/round_body.ttf", 18)
    nick:setTextColor(cc.WHITE)
    nick:setAnchorPoint(0.5,0.5)
    nick:setPosition(70,20)
    :setVisible(false)
    nickNameBg:addChild(nick)

    local selfMoney = ccui.ImageView:create("self_info/money_bg.png")
    selfMoney:setAnchorPoint(cc.p(0.5,0.5))
    selfMoney:setPosition(cc.p(380, 21))
    :setVisible(false)
    self:addChild(selfMoney,6)

    self.labelMutiple = cc.LabelAtlas:create("1","game_res/mutipleNum.png",14,17,string.byte("0"))
    self.labelMutiple:setTag(222)
    self.labelMutiple:setAnchorPoint(0, 0.5)
    self.labelMutiple:setPosition(85,20)
    self.labelMutiple:setString(GlobalUserItem.lUserScore)
    selfMoney:addChild(self.labelMutiple)

    --               1自动       2最大分    3上分      4下分      5锁鱼    6帮助     7返回
    --local btnImg = {"btnAuto", "btnMax", "btnAdd", "btnCut", "btnLock", "btnHelp", "btnBack"}

    local btnImg = {"btnHelp", "btnAdd", "btnSup","btnExit", "btnLock", "btnAuto", "btnShow"}

    local function btnCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local tag = sender:getTag()
            local function getCannonPos()
                --获取自己炮台
                local cannonPos = self._scene.m_nChairID
                return cannonPos
            end
            if tag == 1 then
                self:help()
            elseif tag == 2 then
                --加跑
                local cannon = self._scene.m_cannonLayer:getCannoByPos(getCannonPos() + 1)
                cannon:addPao()
	       
                --self:setScore(4)
            elseif tag == 3 then
                --减泡
                local cannon = self._scene.m_cannonLayer:getCannoByPos(getCannonPos() + 1)
                cannon:cutPao()
                --self:setScore(0)
            elseif tag == 6 then
                --自动开炮

                sender:setName("autoshoot")
                self._scene._dataModel.m_autoshoot = not self._scene._dataModel.m_autoshoot
                if self._scene._dataModel.m_autoshoot then
                    sender:loadTextures("game_res/"..btnImg[6].."3.png", "game_res/"..btnImg[6].."4.png", "")
                else
                    sender:loadTextures("game_res/"..btnImg[6].."1.png", "game_res/"..btnImg[6].."2.png", "")
                end

                local cannon = self._scene.m_cannonLayer:getCannoByPos(getCannonPos() + 1)
                cannon:setAutoShoot(self._scene._dataModel.m_autoshoot)
                --self:setScore(1)
            elseif tag == 4 then
                self._scene:onQueryExitGame()
            elseif tag == 5 then
                -- --print("old state:::::::::::::: ",self._scene._dataModel.m_autolock)
                self._scene._dataModel.m_autolock = not self._scene._dataModel.m_autolock

                local isauto = false
                local cannon = self._scene.m_cannonLayer:getCannoByPos(getCannonPos() + 1)
                -- --print("auto ::::::::::  ", self._scene._dataModel.m_autolock)
                if self._scene._dataModel.m_autolock then
                    --cannon:setAutoShoot(true)
                    
                    isauto =  true
                    sender:setName("autolock")
                    sender:loadTextures("game_res/"..btnImg[5].."3.png", "game_res/"..btnImg[5].."4.png", "")
                    -- --创建切换锁鱼目标按钮
                    -- if sender:getChildByName("change") == nil then
                    --     local function btnCallChange( _sender, _eventType )
                    --         if _eventType == ccui.TouchEventType.ended then
                                local find = false
                                local rect = cc.rect(0,0,yl.WIDTH,yl.HEIGHT)
                                local function findSelect()
                                    for i=g_var(cmd).FishKind.FISH_KIND_31, g_var(cmd).FishKind.FISH_KIND_10 , -1 do 
                                        if self._scene.selectFishList[i] ~= nil then
                                            if self._scene.selectFishList[i].can == true then
                                                --print("btnCallChange---------------------",i,self._scene.selectFishList[i].id)
                                                local fish = self._scene._dataModel.m_fishList[self._scene.selectFishList[i].id]
                                                 --print("fish---------11----------",fish)
                                                if fish ~= nil then
                                                    local pos = cc.p(fish:getPositionX(),fish:getPositionY())
                                                    if cc.rectContainsPoint( rect, pos ) then
                                                        find = true
                                                        local __fish = self._scene._dataModel.m_fishList[self._scene._dataModel.m_fishIndex]
                                                        if __fish ~= nil then
                                                            if __fish:getChildByName("last") then
                                                                __fish:getChildByName("last"):removeFromParent()
                                                            end
                                                        end
                                                        self._scene._dataModel.m_fishIndex = self._scene.selectFishList[i].id
                                                        cannon:setLockAngle(self._scene._dataModel.m_fishIndex)
                                                        self._scene.selectFishList[i].can = false
                                                        break
                                                    end
                                                else
                                                    self._scene.selectFishList[i] = nil
                                                end
                                            end
                                        end
                                    end
                                end
                                findSelect()
                                if find == false then
                                    for i=g_var(cmd).FishKind.FISH_KIND_10, g_var(cmd).FishKind.FISH_KIND_31 do 
                                        if self._scene.selectFishList[i] ~= nil then
                                            self._scene.selectFishList[i].can = true
                                        end
                                    end
                                    findSelect()
                                end
                            --end
                        --end
                    --     local btn = ccui.Button:create()
                    --     btn:setName("change")
                    --     btn:setTouchEnabled(true)
                    --     btn:loadTextures("game_res/btnChange1.png", "game_res/btnChange2.png", "")
                    --     btn:setPosition(cc.p(-10, 0))
                    --     btn:addTouchEventListener(btnCallChange)
                    --     sender:addChild(btn,1)
                    --     btn:runAction(cc.MoveTo:create(0.6, cc.p(0,50)))
                    -- else
                    --     sender:getChildByName("change"):setPositionY(sender:getChildByName("change"):getPositionY()-50)
                    --     sender:getChildByName("change"):setVisible(true)
                    --     sender:getChildByName("change"):runAction(cc.MoveTo:create(0.6, cc.p(0,50)))
                    -- end
                else
                    local __fish = self._scene._dataModel.m_fishList[self._scene._dataModel.m_fishIndex]
                    if __fish ~= nil then
                        if __fish:getChildByName("last") then
                             __fish:getChildByName("last"):removeFromParent()
                        end
                     end
                    self._scene._dataModel.m_fishIndex = g_var(cmd).INT_MAX
                    --取消锁鱼 但不取消自动
                    --cannon:setAutoShoot(false)
                    if cannon~=nil then 
                        cannon:unDelLockEntry()
                        cannon:removeLockTag() --取消锁鱼标志
                        cannon:setFishIndex(g_var(cmd).INT_MAX)
                    end
                    sender:loadTextures("game_res/"..btnImg[5].."1.png", "game_res/"..btnImg[5].."2.png", "")
                    --隐藏切换鱼目标按钮
                    if sender:getChildByName("change") ~= nil then
                        -- --print("隐藏切换鱼目标按钮")
                        sender:getChildByName("change"):setVisible(false)
                    end
                end
                if isauto == true and self._scene._dataModel.m_autoshoot == false then
                    self._scene.selectFishAngle = true
                else
                    self._scene.selectFishAngle = false
                end
            -- elseif tag == 6 then
            --     --取消自动开炮
            --     self._scene._dataModel.m_autoshoot = false
            --     local isauto = false

            --     sender:loadTextures("game_res/"..btnImg[7].."3.png", "game_res/"..btnImg[7].."4.png", "")
                
            --     local cannon = self._scene.m_cannonLayer:getCannoByPos(getCannonPos() + 1)
            --     cannon:setAutoShoot(false)
                --self:help()
            elseif tag == 7 then
                --隐藏
                self._scene._dataModel.m_isHide = not self._scene._dataModel.m_isHide
                if not self._scene._dataModel.m_isHide then
                    
                    sender:loadTextures("game_res/"..btnImg[7].."3.png", "game_res/"..btnImg[7].."4.png", "")
                else
                    sender:loadTextures("game_res/"..btnImg[7].."1.png", "game_res/"..btnImg[7].."2.png", "")
                end
                   
                for i=1,#btnImg-1 do
                    self:getChildByTag(i):setVisible(not self._scene._dataModel.m_isHide)
                end
            else --退出游戏
                self._scene:onQueryExitGame()
            end
        end
    end
    
    local btnBeginPos = 560
    for i=1,#btnImg do
        local btn = ccui.Button:create()
        btn:setTag(i)
        btn:setTouchEnabled(true)
       
        btn:loadTextures("game_res/"..btnImg[i].."1.png", "game_res/"..btnImg[i].."2.png", "")
        if i == 7  then
            btn:loadTextures("game_res/"..btnImg[i].."3.png", "game_res/"..btnImg[i].."4.png", "")
        end

        btn:setPosition(cc.p(50, 720 -60 - 105*i))
        if i>4 then
            btn:setPosition(cc.p(1280, 720 -50 - 100*(i-3)))
        end
        btn:addTouchEventListener(btnCallBack)
        --btn:setScale(0.8)
        self:addChild(btn,10)
    end
    self:help()
    --------------------------创建底部UI-------------------------------
    -- local render = cc.RenderTexture:create(1334,750)
    -- render:beginWithClear(0,0,0,0)
    -- render:setPosition(667,375)
    -- render:endToLua()
    -- self:addChild(render)

-- sprite->runAction(CCRepeatForever::create(CCSequence::create(animate,NULL)));
    --水波效果
    -- local render = cc.RenderTexture:create(1334,750)
    -- render:beginWithClear(0,0,0,0)
    -- -- local water = ccui.ImageView:create("water1.png")
    -- -- local water = cc.Sprite:createWithSpriteFrameName("Scene/water1.png")
    -- local water = cc.Sprite:create()
    -- water:setScale(2.5)
    -- water:setOpacity(120)
    -- water:setBlendFunc(gl.SRC_ALPHA,gl.ONE)
    -- water:visit()
    -- render:endToLua()
    -- water:addChild(render)
    -- render:setPosition(667,375) 
    -- -- water:setPosition(667,375)
    -- water:setPosition(0,0)
    -- self:addChild(water, 1)

    -- local ani1 = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("WaterAnim"))
    -- local ani2 = ani1:reverse()

    -- local action = cc.RepeatForever:create(cc.Sequence:create(ani1,ani2))
    -- water:runAction(action)

end

--水纹
function GameViewLayer:createWater()
    local sp = cc.Sprite:create()
    sp:setScale(1.2)
    local animation = cc.Animation:create()
    for i=1, 16 do 
        animation:addSpriteFrameWithFile("Scene/water"..i..".png")
    end
    sp:setPosition(cc.p(667, 375))
    animation:setDelayPerUnit(2 / 16.0)
    animation:setRestoreOriginalFrame(true)
    local action = cc.Animate:create(animation)
    sp:runAction(cc.RepeatForever:create(cc.Sequence:create(action, action:reverse())))

    return sp
end
function GameViewLayer:setLockByFish(b)
    self._scene._dataModel.m_autolock = b
    self._scene.selectFishAngle = b
    if b == false then
        if self:getChildByName("autolock") ~= nil then
            self:getChildByName("autolock"):loadTextures("game_res/btnLock1.png", "game_res/btnLock2.png", "")
            if self:getChildByName("autolock"):getChildByName("change") ~= nil then
                -- --print("隐藏切换鱼目标按钮")
                self:getChildByName("autolock"):getChildByName("change"):setVisible(false)
            end
        end
    end
end
function GameViewLayer:setAutoByScore( b )
    if b == false then
        if self:getChildByName("autoshoot") ~= nil then
            self:getChildByName("autoshoot"):loadTextures("game_res/btnAuto1.png", "game_res/btnAuto2.png", "")
        end
    end
end
--帮助
function GameViewLayer:help()
    if self:getChildByName("help") == nil then

        local function clickHelp( sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:getChildByName("help"):setVisible(false)
            end
        end

        local helpBtn = ccui.Button:create()
        helpBtn:setName("help")
        helpBtn:setTouchEnabled(true)
        helpBtn:loadTextures("help/help_fish.png", "help/help_fish.png", "help/help_fish.png")
        helpBtn:setPosition(cc.p(yl.WIDTH/2,yl.HEIGHT/2))
        helpBtn:addTouchEventListener(clickHelp)
        self:addChild(helpBtn,200)
        
        local closeBtn = ccui.Button:create()
        closeBtn:loadTextures("help/btn_cancel_1.png", "help/btn_cancel_2.png", "help/btn_cancel_2.png")
        closeBtn:setPosition(cc.p(helpBtn:getContentSize().width-32, helpBtn:getContentSize().height-26))
        closeBtn:setAnchorPoint(cc.p(1,1))
        closeBtn:addTouchEventListener(clickHelp)
        helpBtn:addChild(closeBtn)
    else
        if self:getChildByName("help"):isVisible() == true then
            self:getChildByName("help"):setVisible(false)
        else
            self:getChildByName("help"):setVisible(true)
        end
    end
end
-- max 上分 下分
function GameViewLayer:setScore(buyType)
    if buyType == 1 then -- 下分
        local cmddata = ExternalFun.create_netdata(g_var(cmd).C_ExchangeFishScoreToBullets)
        cmddata:setcmdinfo(yl.MDM_GF_GAME, g_var(cmd).SUB_C_CALE_FISHSCORETOBULLETS)

        cmddata:pushbool(false)
        --print("发送下分消息 类型 : ",buyType)
        self._scene:sendNetData(cmddata)
    elseif buyType == 0 then 
        print("点击上分")

        --上分
        local cmddata = ExternalFun.create_netdata(g_var(cmd).C_ExchangeFishScore)
        cmddata:setcmdinfo(yl.MDM_GF_GAME, 200)
        cmddata:pushscore(GlobalUserItem.lUserScore)
        self._scene:sendNetData(cmddata)
    
        
    else
        -- if buyType == 0 then
        --     local try_max = false
        --     local buy_success = false
        --     if buyType >= 3 then
        --         buyType = 2
        --     end

        --     -- while try_max and (_type >= 0) && (_type < 3) do
        --     --     local need_user_score = 
        --     -- end
        --     if _type == 2 then
        --         buyType = 0
        --     end
        -- end

        local cmddata = ExternalFun.create_netdata(g_var(cmd).C_ExchangeFishScore)
        cmddata:setcmdinfo(yl.MDM_GF_GAME, g_var(cmd).SUB_C_EXCHANGE_FISHSCORE)

        cmddata:pushbyte(buyType)
        cmddata:pushbyte(0)
        cmddata:pushword(0)
        cmddata:pushint(0)
        cmddata:pushscore(0)
        cmddata:pushscore(0)
        --print("发送上分消息 类型 : ",buyType)
        self._scene:sendNetData(cmddata)

          --发送失败
        -- if not  self.frameEngine or not self.frameEngine:sendSocketData(cmddata) then
        --  self.frameEngine._callBack(-1,"发送上分消息失败")
        -- end
    end
end
function GameViewLayer:setAutoLock(b,target)
          
    if b then
        local lock = cc.Sprite:create("game_res/bt_check_yes.png")
        lock:setTag(1)
        lock:setPosition(target:getContentSize().width/2, target:getContentSize().height/2)
        target:removeChildByTag(1)
        target:addChild(lock)

    else
         target:removeChildByTag(1)

         --取消自动射击
         self._scene._dataModel.m_fishIndex = g_var(cmd).INT_MAX

        --删除自动锁定图标
         local cannonPos = self._scene.m_nChairID
         if self._scene._dataModel.m_reversal then 
           cannonPos = 5 - cannonPos
         end

         local cannon = self._scene.m_cannonLayer:getCannoByPos(cannonPos + 1)
         cannon:removeLockTag()

    end              
end
-- function GameViewLayer:initUserInfo()
--     --用户昵称
--     local nick = cc.Label:createWithCharMap("game_res/num_multiple.png",19,20,string.byte("0"))
--     nick:setString("1:")
--     nick:setAnchorPoint(0.0,0.5)
--     nick:setPosition(410,22)
--     nick:setTag(TAG.tag_gameMultiple)
--     self:addChild(nick,22)


--     --用户分数 
--     local score = cc.Label:createWithCharMap("game_res/scoreNum.png",16,22,string.byte("0"))
--     score:setString(string.format("%d", 0))
--     score:setAnchorPoint(0.0,0.5)
--     score:setTag(TAG.tag_gameScore)
--     score:setPosition(71, 22)
--     self:addChild(score,22)
-- end

-- function GameViewLayer:updateUserScore( score )
    
--     local _score  = self:getChildByTag(TAG.tag_gameScore)
--     if nil ~=  _score then
--         _score:setString(string.format("%d",score))
--         -- _score:setString(166)
--     end
-- end

-- function GameViewLayer:updateMultiple( multiple )
--     local _Multiple = self:getChildByTag(TAG.tag_gameMultiple)
--     if nil ~=  _Multiple then
--         _Multiple:setString(string.format("%d:",multiple))
--         -- _Multiple:setString(167)
--     end

-- end

function GameViewLayer:updteBackGround(param)


    local bg = self:getChildByTag(TAG.tag_bg)

    if bg  then
        local call = cc.CallFunc:create(function()
            bg:removeFromParent()
        end)

        bg:runAction(cc.Sequence:create(cc.FadeTo:create(2.5,0),call))

        local bgfile = string.format("game_res/game_bg_%d.png", param)
        local _bg = cc.Sprite:create(bgfile)
        _bg:setPosition(yl.WIDTH/2, yl.HEIGHT/2)
        _bg:setOpacity(0)
        _bg:setTag(TAG.tag_bg)
        self:addChild(_bg)

        _bg:runAction(cc.FadeTo:create(5,255))
    end

    --鱼阵提示
    local groupTips = ccui.ImageView:create("game_res/fish_grounp.png")
    groupTips:setPosition(cc.p(yl.WIDTH/2,yl.HEIGHT/2))
    groupTips:setTag(TAG.tag_grounpTips)
    self:addChild(groupTips,30)

    local callFunc = cc.CallFunc:create(function()
            groupTips:removeFromParent()
        end)

    groupTips:runAction(cc.Sequence:create(cc.DelayTime:create(5.0),callFunc))

       
end

function GameViewLayer:setAutoShoot(b,target)
                 
    if b then

        local auto = cc.Sprite:create("game_res/bt_check_yes.png")
        auto:setTag(1)
        auto:setPosition(target:getContentSize().width/2, target:getContentSize().height/2)
        target:removeChildByTag(1)
        target:addChild(auto)

    else
         target:removeChildByTag(1)
    end

end


--银行操作成功
-- function GameViewLayer:onBankSuccess( )
--      self._scene:dismissPopWait()

--     local bank_success = self._scene.bank_success
--     if nil == bank_success then
--         return
--     end

--     --local addScore = bank_success.lUserScore - GlobalUserItem.lUserScore
--     GlobalUserItem.lUserScore = bank_success.lUserScore 
--     GlobalUserItem.lUserInsure = bank_success.lUserInsure


--     --print("onBankSuccess addScore lUserScore",addScore,bank_success.lUserScore,GlobalUserItem.lUserScore)

--     self:refreshScore()


--     showToast(cc.Director:getInstance():getRunningScene(), bank_success.szDescribrString, 2)
-- end

--银行操作失败
-- function GameViewLayer:onBankFailure( )

--      self._scene:dismissPopWait()
--     local bank_fail = self._scene.bank_fail
--     if nil == bank_fail then
--         return
--     end

--     showToast(cc.Director:getInstance():getRunningScene(), bank_fail.szDescribeString, 2)
-- end


--   --刷新游戏币
-- function GameViewLayer:refreshScore( )
--      --携带游戏币
--     local str = ExternalFun.numberThousands(self._scene._dataModel.m_secene.lPalyCurScore[1][self._scene.m_nChairID+1])
--     if string.len(str) > 19 then
--         str = string.sub(str, 1, 19)
--     end
--     if nil == self.textCurrent then
--         return
--     end
--     self.textCurrent:setString(str)

--     --银行存款
--     str = ExternalFun.numberThousands(GlobalUserItem.lUserInsure)
--     if string.len(str) > 19 then
--         str = string.sub(str, 1, 19)
--     end

--     --self._scene._dataModel.m_secene.lPalyCurScore[1][self._scene.m_nChairID + 1] = GlobalUserItem.lUserScore

--     self.textBank:setString(ExternalFun.numberThousands(GlobalUserItem.lUserInsure))

--     --用户分数
--     self:updateUserScore(self._scene._dataModel.m_secene.lPalyCurScore[1][self._scene.m_nChairID + 1])

    
--     --获取炮台视图位置
--     local cannonPos = self._scene.m_nChairID
--     if self._scene._dataModel.m_reversal then 
--       cannonPos = 5 - cannonPos
--     end
--     --更新炮台分数
--     self._scene.m_cannonLayer:updateUserScore(self._scene._dataModel.m_secene.lPalyCurScore[1][self._scene.m_nChairID+1],cannonPos+1 )

-- end

--子菜单
-- function GameViewLayer:subMenuEvent( sender , eventType)
    
--     local function addBG()
--         local bg = ccui.ImageView:create()
--         bg:setContentSize(cc.size(yl.WIDTH, yl.HEIGHT))
--         bg:setScale9Enabled(true)
--         bg:setPosition(yl.WIDTH/2, yl.HEIGHT/2)
--         bg:setTouchEnabled(true)
--         self:addChild(bg,50)
--         bg:addTouchEventListener(function (sender,eventType)
--             if eventType == ccui.TouchEventType.ended then
--                 bg:removeFromParent()
--                 self.textCurrent = nil
--                 self.textBank = nil

--             end
--         end)

--         return bg
--     end


--     local function showPopWait()
--         self._scene:showPopWait()
--     end

--     --关闭等待
--     local function dismissPopWait()
--         self._scene:dismissPopWait()
--     end

--     local tag = sender:getTag()
--     if 1 == tag then --银行

--         --申请取款
--         local function sendTakeScore( lScore,szPassword )
--             local cmddata = ExternalFun.create_netdata(g_var(game_cmd).CMD_GR_C_TakeScoreRequest)
--             cmddata:setcmdinfo(g_var(game_cmd).MDM_GR_INSURE, g_var(game_cmd).SUB_GR_TAKE_SCORE_REQUEST)
--             cmddata:pushbyte(g_var(game_cmd).SUB_GR_TAKE_SCORE_REQUEST)
--             cmddata:pushscore(lScore)
--             cmddata:pushstring(md5(szPassword),yl.LEN_PASSWORD)

--             self._scene:sendNetData(cmddata)
--         end


--         local function onTakeScore( )
--                 --参数判断
--                 local szScore = string.gsub( self.m_editNumber:getText(),"([^0-9])","")
--                 local szPass =   self.m_editPasswd:getText()

--                 if #szScore < 1 then 
--                     showToast(cc.Director:getInstance():getRunningScene(),"请输入操作金额！",2)
--                     return
--                 end

--                 local lOperateScore = tonumber(szScore)
--                 if lOperateScore<1 then
--                     showToast(cc.Director:getInstance():getRunningScene(),"请输入正确金额！",2)
--                     return
--                 end

--                 if #szPass < 1 then 
--                     showToast(cc.Director:getInstance():getRunningScene(),"请输入银行密码！",2)
--                     return
--                 end
--                 if #szPass <6 then
--                     showToast(cc.Director:getInstance():getRunningScene(),"密码必须大于6个字符，请重新输入！",2)
--                     return
--                 end

--                 showPopWait()
--                 sendTakeScore(lOperateScore,szPass)
                
--          end


--         local  bg = addBG()

--         local csbNode = ExternalFun.loadCSB("game_res/Bank.csb", bg)
--         csbNode:setAnchorPoint(0.5,0.5)
--         csbNode:setPosition(yl.WIDTH/2,yl.HEIGHT/2)

-- --当前游戏币
--         self.textCurrent =  csbNode:getChildByName("Text_Score")
--         local pos = cc.p(self.textCurrent:getPositionX(),self.textCurrent:getPositionY())
--         local text = self.textCurrent:getString()
--         self.textCurrent:removeFromParent()

--         self.textCurrent = cc.Label:createWithTTF(text, "fonts/round_body.ttf", 20)
--         self.textCurrent:setPosition(pos.x, pos.y)
--         csbNode:addChild(self.textCurrent)


-- --银行存款
--         self.textBank    =  csbNode:getChildByName("Text_inSave")
--         pos = cc.p(self.textBank:getPositionX(),self.textBank:getPositionY())
--         text = self.textBank:getString()

--         self.textBank:removeFromParent()

--         self.textBank = cc.Label:createWithTTF(text, "fonts/round_body.ttf", 20)
--         self.textBank:setPosition(pos.x, pos.y)
--         csbNode:addChild(self.textBank)

--         self:refreshScore()

-- --输入取出金额

--         local take = csbNode:getChildByName("Text_tipNum")
--         pos = cc.p(take:getPositionX(),take:getPositionY())
--         text = take:getString()

--         take:removeFromParent()

--         take = cc.Label:createWithTTF(text, "fonts/round_body.ttf", 20)
--         take:setPosition(pos.x, pos.y)
--         csbNode:addChild(take)


-- --输入银行密码  

--         local password = csbNode:getChildByName("Text_tipPassWord")
--         pos = cc.p(password:getPositionX(),password:getPositionY())
--         text = password:getString()

--         password:removeFromParent()

--         password = cc.Label:createWithTTF(text, "fonts/round_body.ttf", 20)
--         password:setPosition(pos.x, pos.y)
--         csbNode:addChild(password)

-- --取款按钮
--         local btnTake = csbNode:getChildByName("btn_takeout")
--         btnTake:addTouchEventListener(function( sender , envetType )
--             if envetType == ccui.TouchEventType.ended then
--                 onTakeScore()
--             end
--         end)

-- --关闭按钮
--         local btnClose = csbNode:getChildByName("bt_close")
--         btnClose:addTouchEventListener(function( sender , eventType )
--             if eventType == ccui.TouchEventType.ended then
--                 bg:removeFromParent()
--             end
--         end)

-- ------------------------------------EditBox---------------------------------------------------


-- --取款金额
--     local editbox = ccui.EditBox:create(cc.size(325, 47),"bank_res/edit_frame.png")
--         :setPosition(cc.p(30,take:getPositionY()))
--         :setFontName("fonts/round_body.ttf")
--         :setPlaceholderFontName("fonts/round_body.ttf")
--         :setFontSize(24)
--         :setPlaceholderFontSize(24)
--         :setMaxLength(32)
--         :setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
--         :setPlaceHolder("请输入取款金额")
--     csbNode:addChild(editbox)
--     self.m_editNumber = editbox
  

--     --取款密码
--     editbox = ccui.EditBox:create(cc.size(325, 47),"bank_res/edit_frame.png")
--         :setPosition(cc.p(30,password:getPositionY()))
--         :setFontName("fonts/round_body.ttf")
--         :setPlaceholderFontName("fonts/round_body.ttf")
--         :setFontSize(24)
--         :setPlaceholderFontSize(24)
--         :setMaxLength(32)
--         :setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
--         :setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
--         :setPlaceHolder("请输入取款密码")
--     csbNode:addChild(editbox)
--     self.m_editPasswd = editbox
   

-- ---------------------------------------------------------------------------------------------------------

--     elseif 2 == tag then --帮助

--         local  bg = addBG()

--         local csbNode = ExternalFun.loadCSB("game_res/Help.csb", bg)
--         csbNode:setAnchorPoint(0.5,0.5)
--         csbNode:setPosition(yl.WIDTH/2,yl.HEIGHT/2)

--         --切换按钮
--         local btnLayout = csbNode:getChildByName("btn_layout")
--         local btnOperate = btnLayout:getChildByName("Button_operate")
--         local btnAward = btnLayout:getChildByName("Button_award")
--         local btnGift = btnLayout:getChildByName("Button_gift")

--         local btnClose = csbNode:getChildByName("btn_close")


--         --背景
--         local  operateBG = csbNode:getChildByName("help_operate")
--         local  awardBG = csbNode:getChildByName("help_award")
--         local  giftBG  = csbNode:getChildByName("help_gift")


--         --添加点击事件
--         btnOperate:addTouchEventListener(function ( sender , eventType )
--             if eventType == ccui.TouchEventType.ended then
--                 operateBG:setVisible(true)
--                 awardBG:setVisible(false)
--                 giftBG:setVisible(false)
--             end
--         end)

--         btnAward:addTouchEventListener(function ( sender , eventType )
--             if eventType == ccui.TouchEventType.ended then
--                 operateBG:setVisible(false)
--                 awardBG:setVisible(true)
--                 giftBG:setVisible(false)



--               if nil == awardBG:getChildByTag(1) then 
--                 ----dump(self._scene._dataModel.m_secene.nFishMultiple, "the mutiple is ======================= >   ", 6)
--                 local gameMultiple = self._scene._dataModel.m_secene.nFishMultiple
             
--                 for i=1,21 do
                
--                     if gameMultiple[i][1] == gameMultiple[i][2] then
--                         local value = gameMultiple[i][1]
--                         local mutiple = cc.LabelAtlas:create(string.format("%d:",value),"game_res/num_help.png",19,20,string.byte("0"))
--                         mutiple:setTag(i)
--                         mutiple:setPosition(90 + math.mod((i-1),5)*170, awardBG:getContentSize().height -145 -  math.floor((i-1)/5) * 70)
--                         awardBG:addChild(mutiple)

--                     else

--                         local value = gameMultiple[i][1]
--                         local mutiple = cc.LabelAtlas:create(string.format("%d",value),"game_res/num_help.png",19,20,string.byte("0"))
--                         mutiple:setTag(i)
--                         mutiple:setPosition(120 + math.mod((i-1),5)*170, awardBG:getContentSize().height -145 - math.floor((i-1)/5) * 70)
--                         awardBG:addChild(mutiple)


--                         local sign = cc.Sprite:create()
--                         sign:setAnchorPoint(0.5,0.5)
--                         sign:initWithFile("game_res/num_clear_multiple.png",cc.rect(0,0,16,17))
--                         sign:setPosition(120 + math.mod((i-1),5)*170, awardBG:getContentSize().height -150 -  math.floor((i-1)/5) * 70)
--                         awardBG:addChild(sign)


--                         local _value = gameMultiple[i][2]
--                         local _mutiple = cc.LabelAtlas:create(string.format("%d:",_value),"game_res/num_help.png",19,20,string.byte("0"))
--                         _mutiple:setTag(i)
--                         _mutiple:setPosition(130 + math.mod((i-1),5)*170, awardBG:getContentSize().height -160 - math.floor((i-1)/5) * 70)
--                         awardBG:addChild(_mutiple)
    
--                     end
--                 end  
--              end

--             end
--         end)

--         btnGift:addTouchEventListener(function ( sender , eventType )
--             if eventType == ccui.TouchEventType.ended then
--                 operateBG:setVisible(false)
--                 awardBG:setVisible(false)
--                 giftBG:setVisible(true)

--             end
--         end)

--         --关闭
--          btnClose:addTouchEventListener(function ( sender , eventType )
--             if eventType == ccui.TouchEventType.ended then
--                 bg:removeFromParent()
--             end
--         end)

--     elseif 3 == tag then --设置

--         local bMute = false

--         local  bg = addBG()

--         local csbNode = ExternalFun.loadCSB("game_res/Setting.csb", bg)
--         csbNode:setAnchorPoint(0.5,0.5)
--         csbNode:setPosition(yl.WIDTH/2,yl.HEIGHT/2)

--         local btnClose = csbNode:getChildByName("bt_close")


--          btnClose:addTouchEventListener(function ( sender , eventType )
--             if eventType == ccui.TouchEventType.ended then
--                 bg:removeFromParent()
--             end
--         end)

--         local txt_version = csbNode:getChildByName("txt_version")
--         txt_version:setVisible(false)
--         local mgr = self._scene._scene:getApp():getVersionMgr()
--         local verstr = mgr:getResVersion(g_var(cmd).KIND_ID) or "0"
--         verstr = "游戏版本:" .. appdf.BASE_C_VERSION .. "." .. verstr
--         --print("----- verstr ----"..verstr)
--         local lbVersion =  cc.Label:createWithSystemFont(verstr, "Microsoft Yahei", 23)
--         lbVersion:setAnchorPoint(cc.p(1,0.5))
--         lbVersion:setColor(cc.c3b(137, 225, 252))
--         lbVersion:setPosition(cc.p(txt_version:getPositionX(), txt_version:getPositionY()))
--         csbNode:addChild(lbVersion)

-- --静音按钮
--         local muteBtn = csbNode:getChildByName("btn_mute")
        
--         if  GlobalUserItem.bVoiceAble or GlobalUserItem.bSoundAble then
--             muteBtn:loadTextureNormal("setting_res/bt_check_no.png")
--         end

        
--         if (self._tag == 0) and not (GlobalUserItem.bVoiceAble and GlobalUserItem.bSoundAble) then
--             self._tag = 1
--         end

--         muteBtn:addTouchEventListener(function( sender,eventType )

--             if eventType == ccui.TouchEventType.ended then

--                 GlobalUserItem.bVoiceAble = not GlobalUserItem.bVoiceAble
--                 GlobalUserItem.bSoundAble = GlobalUserItem.bVoiceAble

--                 if  self._tag == 1 then
--                     self._tag = 2
--                     muteBtn:loadTextureNormal("setting_res/bt_check_yes.png")
--                     AudioEngine.setMusicVolume(0)
--                     AudioEngine.pauseMusic() 
--                     GlobalUserItem.bSoundAble = false
--                     GlobalUserItem.bVoiceAble = false
--                     return
--                 end

--                 if GlobalUserItem.bVoiceAble then

--                     muteBtn:loadTextureNormal("setting_res/bt_check_no.png")
--                     AudioEngine.resumeMusic()
--                     AudioEngine.setMusicVolume(1.0)     
--                 else
--                     muteBtn:loadTextureNormal("setting_res/bt_check_yes.png")
--                     AudioEngine.setMusicVolume(0)
--                     AudioEngine.pauseMusic() -- 暂停音乐
--                 end
--             end
--         end)


--     else --结算
--         local  bg = addBG()

--         local csbNode = ExternalFun.loadCSB("game_res/GameClear.csb", bg)
--         csbNode:setAnchorPoint(0.5,0.5)
--         csbNode:setPosition(yl.WIDTH/2,yl.HEIGHT/2)

--         --按钮
--         local quit = csbNode:getChildByName("btn_gameQuit")
--         quit:addTouchEventListener(function(sender,eventType)
--             if eventType == ccui.TouchEventType.ended then
--                  bg:removeFromParent()
--                 self._scene:onQueryExitGame()
--             end
--         end)

--         local back = csbNode:getChildByName("btn_gameBack")
--         back:addTouchEventListener(function(sender,eventType)
--             if eventType == ccui.TouchEventType.ended then
--                  bg:removeFromParent()
--             end
--         end)

--  --子弹消耗
--        local bulletConsum = csbNode:getChildByName("Text_bulletConsum")
--        local  pos  = cc.p(bulletConsum:getPositionX(),bulletConsum:getPositionY())
--        local anrchor = bulletConsum:getAnchorPoint()
--        bulletConsum:removeFromParent()

--        bulletConsum = cc.LabelAtlas:create(string.format("%d",self._scene._dataModel.m_secene.lBulletConsume[1][self._scene.m_nChairID+1]),"game_res/num_award.png",21,21,string.byte("0"))
--        bulletConsum:setPosition(pos.x, pos.y)
--        bulletConsum:setAnchorPoint(anrchor)
--        csbNode:addChild(bulletConsum)

  
--   --捕鱼收获
--        local getNum = self._scene._dataModel.m_getFishScore
--        local fishGet = csbNode:getChildByName("Text_fishGet")  
--        pos  = cc.p(fishGet:getPositionX(),fishGet:getPositionY())
--        anrchor = fishGet:getAnchorPoint()
--        fishGet:removeFromParent()

--        fishGet = cc.LabelAtlas:create(string.format("%d",getNum),"game_res/num_award.png",21,21,string.byte("0"))
--        fishGet:setPosition(pos.x, pos.y)
--        fishGet:setAnchorPoint(anrchor)
--        csbNode:addChild(fishGet)  

--        local gameMultiple = self._scene._dataModel.m_secene.nFishMultiple
--         for i=1,21 do


--             if gameMultiple[i][1] == gameMultiple[i][2] then
--                 local value = gameMultiple[i][1]
--                 local mutiple = cc.LabelAtlas:create(string.format("%d:",value),"game_res/num_help.png",19,20,string.byte("0"))
--                 mutiple:setTag(i)
--                 mutiple:setPosition(-350 + math.mod((i-1),5)*175, csbNode:getContentSize().height + 150 -  math.floor((i-1)/5) * 70)
--                 csbNode:addChild(mutiple)

--             else

--                 local value = gameMultiple[i][1]
--                 local mutiple = cc.LabelAtlas:create(string.format("%d",value),"game_res/num_help.png",19,20,string.byte("0"))
--                 mutiple:setTag(i)
--                 mutiple:setPosition(-350 + math.mod((i-1),5)*175, csbNode:getContentSize().height + 150 -  math.floor((i-1)/5) * 70)
--                 csbNode:addChild(mutiple)


--                 local sign = cc.Sprite:create()
--                 sign:setAnchorPoint(0.5,0.5)
--                 sign:initWithFile("game_res/num_clear_multiple.png",cc.rect(0,0,16,17))
--                 sign:setPosition(-340 + math.mod((i-1),5)*175, csbNode:getContentSize().height + 143 -  math.floor((i-1)/5) * 70)
--                 csbNode:addChild(sign)


--                 local _value = gameMultiple[i][2]
--                 local _mutiple = cc.LabelAtlas:create(string.format("%d:",_value),"game_res/num_help.png",19,20,string.byte("0"))
--                 _mutiple:setTag(i)
--                 _mutiple:setPosition(-330 + math.mod((i-1),5)*175, csbNode:getContentSize().height + 135 -  math.floor((i-1)/5) * 70)
--                 csbNode:addChild(_mutiple)
            
--             end


--             local count = self._scene.m_catchFishCount[i]

--             local sign = cc.Sprite:create()
--             sign:setAnchorPoint(0.5,0.5)
--             sign:initWithFile("game_res/num_clear_strip.png",cc.rect(17*12,0,17,15))
--             sign:setPosition(-350 + math.mod((i-1),5)*175, csbNode:getContentSize().height + 187 -  math.floor((i-1)/5) * 70)
--             csbNode:addChild(sign)

--             local _count = cc.LabelAtlas:create(string.format("%d",count),"game_res/num_clear_strip.png",17,15,string.byte("0"))
--             _count:setTag(i)
--             _count:setPosition(-340 + math.mod((i-1),5)*175, csbNode:getContentSize().height + 180 -  math.floor((i-1)/5) * 70)
--             csbNode:addChild(_count)
--          end

--    --用户分数
--         local userScore = csbNode:getChildByName("Text_totalScore")  

--         pos  = cc.p(userScore:getPositionX(),userScore:getPositionY())
--         anrchor = userScore:getAnchorPoint()
--         userScore:removeFromParent()

--         userScore = cc.LabelAtlas:create(string.format("%d",self._scene._dataModel.m_secene.lPalyCurScore[1][self._scene.m_nChairID+1]),"game_res/num_award.png",21,21,string.byte("0"))
--         userScore:setPosition(pos.x, pos.y)
--         userScore:setAnchorPoint(anrchor)
--         csbNode:addChild(userScore)    
--     end
-- end


function GameViewLayer:ButtonEvent( sender , eventType)
    --print("ButtonEvent  ",sender, eventType)
    if eventType == ccui.TouchEventType.ended then

        local function getCannonPos()
            --获取自己炮台
            local cannonPos = self._scene.m_nChairID
            if self._scene._dataModel.m_reversal then 
                cannonPos = 5 - cannonPos
            end
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

        elseif tag == TAG.tag_Menu then --菜单

            local MenuBG = ccui.ImageView:create()
            MenuBG:setContentSize(cc.size(yl.WIDTH, yl.HEIGHT))
            MenuBG:setScale9Enabled(true)
            MenuBG:setPosition(yl.WIDTH/2, yl.HEIGHT/2)
            MenuBG:setTouchEnabled(true)
            self:addChild(MenuBG,21)
            MenuBG:addTouchEventListener(function (sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        MenuBG:removeFromParent()
                    end
                end)


            --添加菜单背景
            local bg = ccui.ImageView:create("game_res/im_bt_frame.png")
            bg:setScale9Enabled(true)
            bg:setContentSize(cc.size(bg:getContentSize().width, 380))
            bg:setAnchorPoint(1.0,0.0)

            bg:setPosition(yl.WIDTH - 5, -260)
            MenuBG:addChild(bg)

            bg:runAction(cc.MoveTo:create(0.2,cc.p(yl.WIDTH-5,60)))

            local function subCallBack( sender , eventType )
                if eventType == ccui.TouchEventType.ended  then
                    sender:getParent():getParent():removeFromParent()
                    self:subMenuEvent(sender,eventType)
                end
            end

            --添加子菜单
            local bank = ccui.Button:create("game_res/bt_bank_0.png","game_res/bt_bank_1.png")
            bank:setTag(1)
            bank:addTouchEventListener(subCallBack)
            bank:setPosition(bg:getContentSize().width/2, bg:getContentSize().height - 53)
            bg:addChild(bank)

            local help = ccui.Button:create("game_res/bt_help_0.png","game_res/bt_help_1.png")
            help:setTag(2)
            help:addTouchEventListener(subCallBack)
            help:setPosition(bg:getContentSize().width/2, bg:getContentSize().height - 143)
            bg:addChild(help)

            local set = ccui.Button:create("game_res/bt_setting_0.png","game_res/bt_setting_1.png")
            set:setTag(3)
            set:addTouchEventListener(subCallBack)
            set:setPosition(bg:getContentSize().width/2, bg:getContentSize().height - 143 - 90 - 5)
            bg:addChild(set)

            local clear = ccui.Button:create("game_res/bt_clearing_0.png","game_res/bt_clearing_1.png")
            clear:setTag(4)
            clear:addTouchEventListener(subCallBack)
            clear:setPosition(bg:getContentSize().width/2, bg:getContentSize().height - 143 - 180 - 5)
            bg:addChild(clear)

        end
    end
end

function GameViewLayer:getImgByKind( fishKind )
    local img = nil
    if fishKind == g_var(cmd).FishKind.FISH_KIND_18 then
        img = "fish18_01.png"
    elseif fishKind == g_var(cmd).FishKind.FISH_KIND_19 then
        img = "fish19_01.png"
    elseif fishKind == g_var(cmd).FishKind.FISH_KIND_20 then
        img = "fish20_01.png"
    elseif fishKind == g_var(cmd).FishKind.FISH_KIND_21 then
        img = "fish21_01.png"
    end
    return img
end

function GameViewLayer:ShowSystemTip( tip )
    local lb =  cc.Label:createWithTTF(tip, "fonts/round_body.ttf", 30)
    lb:setTextColor(cc.RED)
end
function GameViewLayer:Showtips( tips, fishKind, color, time )
    if tips == 0 or tips == 5   then
       return
    end
    
    if self.showTips == true then
        
        self:runAction(cc.Sequence:create(cc.DelayTime:create(2.0),cc.CallFunc:create(function (  )
            self.showTips = false
        end)))
        return
    end

    self.showTips = true

    local lb =  cc.Label:createWithTTF(tips, "fonts/round_body.ttf", 30)
    local bg = ccui.ImageView:create("fish/dyll.png")
    local c  = color or cc.YELLOW
    lb:setTextColor(c)
    --bg:setScale9Enabled(true)
    -- bg:setContentSize(cc.size(lb:getContentSize().width + 60  , 40))
    -- bg:setScale(0.1)
    lb:setPosition(bg:getContentSize().width/2, 30)
    lb:setVisible(false)
    bg:addChild(lb,3)

    local fish_logo = cc.Sprite:create(string.format("fish/dy%d.png",tips))
    fish_logo:setPosition(bg:getContentSize().width/2, 100)
    bg:addChild(fish_logo)

    self:ShowTipsForBg(bg, time)

    if fishKind ~= nil then
        local img  = self:getImgByKind(fishKind)
        if img == nil then return end
        -- local fish = cc.Sprite:createWithSpriteFrameName(img)
        -- fish:setScale(0.9)
        -- fish:setPosition(bg:getContentSize().width/2, 30)
        -- bg:addChild(fish,2)
    end
end

function GameViewLayer:ShowCoinT( score,wChairID,pos,fishtype )

end
function GameViewLayer:ShowCoin( score,wChairID,pos,fishtype )

  ----print("score.."..score.."wChairID.."..wChairID.."fishtype.."..fishtype)

  self._scene._dataModel:playEffect(g_var(cmd).Coinfly)

  local silverNum = {2,2,3,4,4}
  local goldNum = {1,1,1,2,2,3,3,4,5,6,8,16,16,16,18,18,18}
  
  local nMyNum = self._scene.m_nChairID/3
  local playerNum = wChairID/3

  local cannonPos = wChairID
--获取炮台
  -- if self._scene._dataModel.m_reversal then 
  --    cannonPos = 5 - cannonPos
  --  end

   local cannon = self._scene.m_cannonLayer:getCannoByPos(cannonPos + 1)

   if nil == cannon then
      return
   end

   local anim = nil
   local coinNum = 1
   local frameName = nil
   local distant = 50


  if fishtype < 5 then
    anim = cc.AnimationCache:getInstance():getAnimation("SilverAnim")
    frameName = "silver_coin_0.png"
    coinNum = silverNum[fishtype+1]
  elseif fishtype>=5 and fishtype<17 then
    anim = cc.AnimationCache:getInstance():getAnimation("GoldAnim")
    frameName = "gold_coin_0.png"

    coinNum = goldNum[fishtype+1]

  elseif fishtype == g_var(cmd).FishType.FishType_YuanBao then
    anim = cc.AnimationCache:getInstance():getAnimation("FishIgnotCoin")
    frameName = "ignot_coin_0.png"
    coinNum = 1
  end

  local posX = {}
  local initX = -105
  posX[1] = initX

  for i=2,10 do
    posX[i] = initX-(i-1)*39
  end

  local node = cc.Node:create()
  node:setAnchorPoint(0.5,0.5)
  node:setContentSize(cc.size(distant*5 , distant*4))
  
  if coinNum > 5 then
    node:setContentSize(cc.size(distant*5 , distant*2+40))
  end

  node:setPosition(pos.x, pos.y)
  self._scene.m_cannonLayer:addChild(node,1)

  if nil ~= anim then
      local action = cc.RepeatForever:create(cc.Animate:create(anim))
     
      if coinNum > 10 then
        coinNum = 10
      end

     local num = cc.LabelAtlas:create(string.format("%d", score),"game_res/num_game_gold.png",37,34,string.byte("0"))
     num:setAnchorPoint(0.5,0.5)
     num:setPosition(node:getContentSize().width/2, node:getContentSize().height-140)
     node:addChild(num)
     local call = cc.CallFunc:create(function()
       num:removeFromParent()
     end)

     num:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),call))

     local secondNum = coinNum
     if coinNum > 5 then
        secondNum = coinNum/2 
     end

     local node1 = cc.Node:create()
     node1:setContentSize(cc.size(distant*secondNum, distant))
     node1:setAnchorPoint(0.5,0.5)
     node1:setPosition(node:getContentSize().width/2, distant/2)
     node:addChild(node1)

     for i=1,secondNum do
       local coin = cc.Sprite:createWithSpriteFrameName(frameName)
       coin:runAction(action:clone())
       coin:setPosition(distant/2+(i-1)*distant, distant/2)
       node1:addChild(coin)
     end

     if coinNum > 5 then
       local firstNum = coinNum - secondNum
       local node2 = cc.Node:create()
       node2:setContentSize(cc.size(distant*firstNum, distant))
       node2:setAnchorPoint(0.5,0.5)
       node2:setPosition(node:getContentSize().width/2, distant*3/2)
       node:addChild(node2)

     end
  end

  local cannonPos = cc.p(cannon:getPositionX(),cannon:getPositionY())
  local call = cc.CallFunc:create(function()
    node:removeFromParent()
  end)

  node:runAction(cc.Sequence:create(cc.MoveBy:create(1.0,cc.p(0,40)),cc.MoveTo:create(0.5,cannonPos),call))

  local angle = 70.0
  local time = 0.12
  local moveY = 30.0

  if fishtype >= g_var(cmd).FishType.FishType_JianYu and fishtype <= g_var(cmd).FishType.FishType_LiKui then
    self._scene._dataModel:playEffect(g_var(cmd).bingo)
    local goldCycle = self:getChildByTag(TAG.tag_GoldCycle + wChairID )
    if nil == goldCycle then
        goldCycle = cc.Sprite:create("game_res/goldCircle.png")
        goldCycle:setTag(TAG.tag_GoldCycle + wChairID)

        goldCycle:setPosition(pos.x, pos.y)
        self:addChild(goldCycle,6)
        local call = cc.CallFunc:create(function( )
           goldCycle:removeFromParent()
        end)
        goldCycle:runAction(cc.Sequence:create(cc.RotateBy:create(time*18,360*1.3),call))
    end


    local goldTxt = self:getChildByTag(TAG.tag_GoldCycleTxt + wChairID)
    if goldTxt == nil then

      goldTxt = cc.LabelAtlas:create(string.format("%d", score),"game_res/mutipleNum.png",14,17,string.byte("0"))
      goldTxt:setAnchorPoint(0.5,0.5)

      goldTxt:setPosition(pos.x, pos.y)          
      self:addChild(goldTxt,6)

      local action = cc.Sequence:create(cc.RotateTo:create(time*2,angle),cc.RotateTo:create(time*4,-angle),cc.RotateTo:create(time*2,0))
      local call = cc.CallFunc:create(function()  
          goldTxt:removeFromParent()
      end)

      goldTxt:runAction(cc.Sequence:create(action,call))

    end

  end

end

function GameViewLayer:ShowAwardTip(data)


 local fishName = {"小黄刺鱼","小草鱼","热带黄鱼","大眼金鱼","热带紫鱼","小丑鱼","河豚鱼","狮头鱼","灯笼鱼","海龟","神仙鱼","蝴蝶鱼","铃铛鱼","剑鱼","魔鬼鱼","大白鲨","大金鲨","双头企鹅"
    ,"巨型黄金鲨","金龙","李逵","水浒传","忠义堂","爆炸飞镖","宝箱","元宝鱼"}

  local labelList = {}

  local tipStr  = ""
  local tipStr1 = ""
  local tipStr2 = ""

  if data.nFishMultiple >= 50 then
    if data.nScoreType == g_var(cmd).SupplyType.EST_Cold then
       tipStr = "捕中了"..fishName[data.nFishType+1]..",获得"
    elseif data.nScoreType == g_var(cmd).SupplyType.EST_Laser then
      
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


function GameViewLayer:ShowTipsForBg( bg, time )
    local infoCount = #self._scene.m_infoList
    -- local sublist = {}

    while infoCount >= 3 do
        local node = self._scene.m_infoList[1]
        table.remove(self._scene.m_infoList,1)
        node:removeFromParent()

        for i=1,#self._scene.m_infoList do
            local bg = self._scene.m_infoList[i]
            bg:runAction(cc.MoveBy:create(0.2,cc.p(0,100)))
        end

        infoCount = #self._scene.m_infoList
    end

    bg:setPosition(yl.WIDTH/2, yl.HEIGHT/2 + 100*infoCount)
    self:addChild(bg,30)
    table.insert(self._scene.m_infoList, bg)

    local call = cc.CallFunc:create(function()
        bg:removeFromParent()
        for i=1,#self._scene.m_infoList do
            local _bg = self._scene.m_infoList[i]
            if bg == _bg then
                table.remove(self._scene.m_infoList,i)
                break
            end
        end

        if #self._scene.m_infoList > 0 then
            for i=1,#self._scene.m_infoList do
                local _bg = self._scene.m_infoList[i]
                _bg:runAction(cc.MoveBy:create(0.2,cc.p(0,100)))
            end
        end

    end)
    local t = time or 2
    bg:runAction(cc.Sequence:create(cc.DelayTime:create(t), call)) 

end

-- show jetton
function GameViewLayer:showJetton(catch_bird)
    local con = self._scene.m_cannonLayer:getCannoByPos(catch_bird.chair_id_ + 1)
    local jettonCount = #con.jettonList
    local dtime = 2.5
    while jettonCount >= 3 do
        local node = con.jettonList[1]
        table.remove(con.jettonList,1)
        node._jetton:removeFromParent()
        node._bg:removeFromParent()

        for i=1,#con.jettonList do
            local _jetton = con.jettonList[i]._jetton
            local _bg = con.jettonList[i]._bg
            _jetton:runAction(cc.MoveBy:create(dtime,cc.p(32,0)))
            _bg:runAction(cc.MoveBy:create(dtime,cc.p(32,0)))
        end

        jettonCount = #con.jettonList
    end

    local viewpos = catch_bird.chair_id_ + 1
    -- if viewpos == 4 then
    --     viewpos = 8
    -- elseif viewpos == 5 then
    --     viewpos = 6
    -- elseif viewpos == 6 then
    --     viewpos = 5
    -- elseif viewpos == 7 then
    --     viewpos = 4
    -- elseif viewpos == 8 then
    --     viewpos = 7
    -- end
    if viewpos == 4 then
		viewpos = 6
	elseif viewpos == 5 then
		viewpos = 5
	elseif viewpos == 6 then
		viewpos = 4
	end
    print("catch_bird.chair_id_ " .. catch_bird.chair_id_)
    local rootNode = self._scene.m_cannonLayer.rootNode:getChildByName(string.format("im_info_bg_%d", viewpos))
    local jetton   = cc.Sprite:create("jetton.png")
    jetton:setAnchorPoint(cc.p(0.5,0))
    local hei = jetton:getContentSize().height/35
    local ceng = catch_bird.catch_gold_/10000
    local height_j = hei*ceng
    if height_j>372 then 
        height_j = 372
    elseif height_j<hei then 
        height_j = hei
    end
 

    jetton:setTextureRect(cc.rect(0,0,32,height_j)) 

    local color = "jetton_bgc1.png"
    if con.jettonNum % 2 == 1 then
        color = "jetton_bgc2.png"
    end
    con.jettonNum = con.jettonNum + 1
    local bg      = cc.Sprite:create(color)
    local numlen = #tostring(catch_bird.catch_gold_)
    local scalexs = 1
    if numlen <= 3 then
        scalexs = 0.5
    elseif numlen <= 4 then
        scalexs = 0.6
    elseif numlen <= 5 then
        scalexs = 0.8
    end
    bg:setScaleX(scalexs)

    local bottomY = 61
    bg:setAnchorPoint(cc.p(1,0))
    local posY = height_j+2
    bg:setPositionY((bottomY+posY))
    -- bg:runAction(cc.MoveTo:create(0.2, cc.p(bg:getPositionX(), bottomY+posY)))

    local jeNum = cc.LabelAtlas:create(string.format("%d", catch_bird.catch_gold_),"jetton_num.png",12,17,string.byte("0"))
    jeNum:setAnchorPoint(0,0)
    if scalexs == 0.5 then
        jeNum:setPositionX(10)
    else
        jeNum:setPositionX(3)
    end
    jeNum:setName("num")
    jeNum:setScaleX(1+(1-scalexs))

    if catch_bird.chair_id_ >= 0 and catch_bird.chair_id_ <= 2 then
        jeNum:setRotation(180)
        jeNum:setAnchorPoint(1,1)
    elseif catch_bird.chair_id_ == 3 then
        -- jetton:setRotation(-180)
        -- bg:setRotation(-180)
        -- bg:setAnchorPoint(cc.p(0,0))
        -- bottomY =  bottomY - 47
        -- bg:setPositionY((bottomY-posY))
        -- bg:runAction(cc.MoveTo:create(0.2, cc.p(bg:getPositionX(), bottomY-posY)))
    elseif catch_bird.chair_id_ == 7 then
        jetton:setRotation(180)
        bg:setRotation(180)
        bg:setAnchorPoint(cc.p(0,0))
        bottomY =  bottomY - 47
        bg:setPositionY((bottomY-posY))
        -- bg:runAction(cc.MoveTo:create(0.2, cc.p(bg:getPositionX(), bottomY-posY)))
    end 
    bg:setVisible(false)
    bg:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(function()
        bg:setVisible(true)
    end)))
    if jettonCount == 0 then
        jetton:setPosition(cc.p(130, bottomY))
        bg:setPositionX(jetton:getPositionX()+(bg:getContentSize().width*scalexs/2))
    elseif jettonCount == 1 then
        jetton:setPosition(cc.p(130-jetton:getContentSize().width, bottomY))
        bg:setPositionX(jetton:getPositionX()+bg:getContentSize().width*scalexs/2)
    else
        jetton:setPosition(cc.p(130-jetton:getContentSize().width*2, bottomY))
        bg:setPositionX(jetton:getPositionX()+bg:getContentSize().width*scalexs/2)
    end

    bg:addChild(jeNum)

    rootNode:addChild(jetton)
    rootNode:addChild(bg)
    table.insert(con.jettonList, {_jetton = jetton, _bg = bg})

    local call = cc.CallFunc:create(function()
        -- --print("###########hgehe ",#con.jettonList)
        -- error("aa")
        if con.jettonList == nil then return end
        
        for i=1,#con.jettonList do
            local _je = con.jettonList[i]._jetton
            -- --print("del ",jetton, _je)
            if jetton == _je then
                -- --print("删除了",i)
                jetton:removeFromParent()
                bg:removeFromParent()
                table.remove(con.jettonList, i)
                break
            end
        end

        if #con.jettonList > 0 then
            for i=1,#con.jettonList do
                local _je = con.jettonList[i]._jetton
                local _bg = con.jettonList[i]._bg
                -- --print("### ",#con.jettonList, i, _je, _bg)
                _je:runAction(cc.MoveBy:create(dtime,cc.p(jetton:getContentSize().width,0)))
                _bg:runAction(cc.MoveBy:create(dtime,cc.p(jetton:getContentSize().width,0)))
            end
        end

    end)
    local t = 2
    local sq = cc.Sequence:create(cc.DelayTime:create(t), call)
    sq:setTag(111)
    jetton:runAction(sq) 
    -- bg:runAction(cc.Sequence:create(cc.DelayTime:create(t))) 
end

return GameViewLayer
