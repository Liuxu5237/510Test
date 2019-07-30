--
-- Author: Your Name
-- Date: 2015-09-24 18:58:44
--
local BetLayer = class("BetLayer", function ()
    return cc.Layer:create()
end)
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local HeadSprite = appdf.req(appdf.EXTERNAL_SRC .. "HeadSprite")

require "cocos.init"
local module_pre = "game.yule.xiyou.src"
local Data = appdf.req(module_pre .. ".models.Data")
local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
local scheduler = cc.Director:getInstance():getScheduler()
local schedulerEntry = nil
local schedulerEntryTime = nil
--local GameMenuLayer = import("GameMenu.GameMenuLayer")
local TAG_START             = 100


local MaxTimes = 1   ---最大赔率

local enumTable = 
{
    "BT_JETTONSCORE_0", --下注按钮
    "BT_JETTONSCORE_1",
    "BT_JETTONSCORE_2",
    "BT_JETTONSCORE_3",
    "BT_JETTONSCORE_4",
    "BT_JETTONSCORE_5",
    "BT_JETTONSCORE_6",
}
local TAG_ENUM = ExternalFun.declarEnumWithTable(TAG_START, enumTable)
function BetLayer:ctor(scene)
	self._scene = scene
	Data.Bets = {}
    self:init()
end

function BetLayer:onEnter()
    -- 下注历史
    Data.history = {}
    print("BetLayer OnEnter")
end 

function BetLayer:onExit()
    -- 删除监听
    if self.eventLockTimeListener then 
        eventDispatcher:removeEventListener(self.eventLockTimeListener)
    end 

    -- 关闭定时器
    if schedulerEntry then 
        scheduler:unscheduleScriptEntry(schedulerEntry)
        schedulerEntry = nil
    end

    -- 关闭定时器
    if schedulerEntryTime then 
        scheduler:unscheduleScriptEntry(schedulerEntryTime)
        schedulerEntryTime = nil
    end


    print("-------------------------BetLayer:onExit---------------------------")
    --Data.msgMgr[Data.SUB_S_BET] = nil
end 

function BetLayer:init()
	self:setTouchEnabled(true)
	self:registerScriptHandler(function (event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end)

    -- 还原
    Data.sureBet = 0
    Data.betCur = 0
    if Data.isJackpot then
        Data.isJackpot = false
        require("script.MainLayer").WinTmpSprite:setVisible(false)
        require("script.MainLayer").WinTmpSpriteWin:setVisible(false)
    end
    self._node = cc.CSLoader:createNode("Edit/BetLayer.csb")
    
    --self._node:getChildByName("System"):setVisible(false)
    self:addChild(self._node)

      --下注筹码
      self.m_JettonBtn = {}
      --下注按钮背后光
      self.m_JettonLight = nil
      --选中筹码
      self.m_nJettonSelect = 1
  
      local function btnEvent( sender, eventType )
       
        if eventType == ccui.TouchEventType.began then
                sender:setScale(1.05) 
        end
        if eventType == ccui.TouchEventType.canceled then
            sender:setScale(1.00) 
        end 
        if eventType == ccui.TouchEventType.ended then
            self:onButtonClickedEvent(sender:getTag(), sender)
        end
    end


      for i=1,6 do
          local str = string.format("bt_jetton_%d", i)
          local btn = self._node:getChildByName(str)
          btn:setTag(TAG_ENUM.BT_JETTONSCORE_0+i-1)
          btn:addTouchEventListener(btnEvent)
          self.m_JettonBtn[i] = btn
      end
       --下注按钮背后光
       self.m_JettonLight = self._node:getChildByName("im_jetton_effect")
       self.m_JettonLight:runAction(cc.RepeatForever:create(cc.Blink:create(1.0,1)))

       self:setJettonEnable(true)
    -- 清理下注
    Data.Bets = {}

    self.CanClick = true
    -- 下注
    self:BetEventAttouch(self._node)
    -- 按钮事件
    self:buttonEvent(self._node)

    local bTime = true
    local chip_OK = self._node:getChildByName("Bet_OK")
    local chip_NO = self._node:getChildByName("Bet_NO")
    self.Jackpot = self._node:getChildByName("JackpotNum")
    self.Jackpot:setPosition(cc.p(285,509))
    self.Jackpot:setString(string.format("%.2f", math.random(100000,999999)))
    self:GameJackpot()
    AudioEngine.playEffect("Sound/BetBegin.mp3")

    -- 剩余时间
    ------------------------------------------------------------------------------
    Data.BeginTime = os.time()
    Data.BetTime = Data.DEFINE_BET_TIME
    local limit = cc.LabelAtlas:_create("" .. Data.BetTime,"General/NumTime.png",64,62,46)
    limit:setAnchorPoint(cc.p(0.5,0.5))
    limit:setPosition(cc.p(667,550))
    limit:setScale(0.9)
    self:addChild(limit, 10)

    local resumeGrossini = function(time)
        Data.BetTime = Data.DEFINE_BET_TIME - (os.time() - Data.BeginTime) --Data.BetTime -1
        if Data.BetTime < 0 then 
            Data.BetTime = 0
        end 

        if Data.BetTime <= 5 then
            local event = cc.EventCustom:new("BetTimeEndSystem")
            eventDispatcher:dispatchEvent(event)

            if Data.BetTime == 0 then
                self.CanClick = false
                if bTime then
                    bTime = false
                    AudioEngine.playEffect("Sound/BetEnd.mp3")
                end
                --AudioEngine.playEffect("Sound/TimeEnd.mp3")
                self._node:getChildByName("Unit"):setEnabled(false)
                self._node:getChildByName("Clear"):setEnabled(false)
                self._node:getChildByName("Confirm"):setEnabled(false)
                self._node:getChildByName("Unit"):setBright(false)
                self._node:getChildByName("Clear"):setBright(false)
                self._node:getChildByName("Confirm"):setBright(false) 

                if Data.sureBet then 
                    if Data.sureBet == 0 then 
                        Data.Bets = {}
                        --Data.sureBet = 0
                        Data.betCur = 0
                        -- 更新
                        self:updateBetInfo(self._node)
                    else 
                        Data.Bets = {}
                        for i = 0, 14 do 
                            Data.Bets[i] = Data.lastBets[i]
                        end 
                        self:updateBetInfo(self._node)
                    end 
                else 
                    Data.Bets = {}
                    --Data.sureBet = 0
                    Data.betCur = 0
                    -- 更新
                    self:updateBetInfo(self._node)
                end

                -- 关闭定时器
                if schedulerEntryTime then 
                    scheduler:unscheduleScriptEntry(schedulerEntryTime)
                    schedulerEntryTime = nil
                end
            else 
                AudioEngine.playEffect("Sound/Time.mp3")
            end
        end

        limit:setString("" .. Data.BetTime)
    end 
    schedulerEntryTime = scheduler:scheduleScriptFunc(resumeGrossini, 1.0, false)
    --------------------------------------------------------------------------------

    local resumeGrossini = function(time)
        --定时器
        if Data.bHistory then
            self:updateHistory()
        end
    end 
    schedulerEntry = scheduler:scheduleScriptFunc(resumeGrossini, 0.1, false)
    
    Data.curScore = GlobalUserItem.lUserScore
    self.cridit = cc.Label:createWithTTF(Data.curScore, "fonts/round_body.ttf", 20) 
    self.cridit:setAnchorPoint(cc.p(0,0.5))
    --self.cridit:setScale(0.8)
    self.cridit:setPosition(cc.p(97,30))
    self:addChild(self.cridit, 1)

    self.curbet = cc.LabelAtlas:_create("0","General/NumScore.png",21,30,46)
    self.curbet:setAnchorPoint(cc.p(0,0.5))
    --self.curbet:setScale(0.8)
    self.curbet:setPosition(cc.p(330,43))
    self:addChild(self.curbet, 1)

    self.curwin = cc.LabelAtlas:_create("0","General/NumScore.png",21,30,46)
    self.curwin:setAnchorPoint(cc.p(0,0.5))
    --self.curwin:setScale(0.8)
    self.curwin:setPosition(cc.p(573,43))
    self:addChild(self.curwin, 1)

    -- self.betType = cc.Sprite:create("General/x".. Data.curBetType .. ".png")
    -- self.betType:setAnchorPoint(cc.p(0.5,0.5))
    -- self.betType:setPosition(cc.p(175,25))
    -- self:addChild(self.betType, 1)

    -- -- 玩家信息
    -- local sysMenuLayer = GameMenuLayer.new(function()
    --         GameApp:exitGame()
    --         print("==================188======================")
    --     end, function() 
    --         self:addChild(import("script.HelpLayer").new(), 126)
    --         --cc.Director:getInstance():getRunningScene():addChild(import("script.HelpLayer").new(), 126)
    --     end )
    -- self:addChild(sysMenuLayer,200)

    -- 更新分数
    --Data.msgMgr[1234] = nil
    --Data.msgMgr[1234] = function()
    self:updateBetInfo(self._node)
        --end
    self:onUpdateUserInfo()

end 

function BetLayer:addChip( dataBuffer )
     --下注成功提示
     local chip_OK = self._node:getChildByName("Bet_OK")
     local chip_NO = self._node:getChildByName("Bet_NO")
     --Data.msgMgr[Data.SUB_S_ADD_CHIPS] = function(receiveBuffer)
        local yes = 0 
        local bChip = false
        local index = 1
        local nbet = {}
        yes = dataBuffer:readbyte()
        print("是否下注成功[失败(0) 成功(1)]："..yes)

        for i = 1, 15 do 
            nbet[i] = dataBuffer:readint()
            --print("nbet " .. i-1 .. " " .. nbet[i])
            if nbet[i] > 0 then
                bChip = true
            end
        end

        if yes == 1 then 
            if bChip then
                chip_OK:setVisible(true)
            end
        else
            chip_NO:setVisible(true)
        end           
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
            chip_OK:setVisible(false)
            chip_NO:setVisible(false)
        end),nil))
    --end 
end

-- 创建历史记录
function BetLayer:updateHistory()
    Data.bHistory = false
    -- 关闭定时器
    if schedulerEntry then 
        scheduler:unscheduleScriptEntry(schedulerEntry)
        schedulerEntry = nil
    end

    release_print("------------创建历史记录--------------")
    local history = cc.ScrollView:create()
    local hisLen = #Data.HistoryList
    local tmpNode = cc.Node:create()
    tmpNode:setContentSize(cc.size(hisLen*106 ,160))
    history:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    history:setViewSize(cc.size(848, 160))
    history:setContentSize(cc.size(hisLen*106 ,160))
    history:setBounceable(true)
    history:setTouchEnabled(true)

    local typeList = {"Bank","Tie","Player"}
    local roleList = {"Sun_Red","Sun_Green","Sun_Yellow",
                      "Sha_Red","Sha_Green","Sha_Yellow",
                      "Niu_Red","Niu_Green","Niu_Yellow",
                      "Monkey_Red","Monkey_Green","Monkey_Yellow"}
    for index = 1, hisLen do 
        local node = cc.Node:create()
        node:setContentSize(cc.size(106,160))
        local history = Data.HistoryList[index]
        local tmpSprite = cc.Sprite:create("General/" .. typeList[history.color+1] ..".png")
        tmpSprite:setPosition(cc.p(60,120))
        tmpSprite:setScale(0.75)
        node:addChild(tmpSprite,1)
        if history.type == 0 then 
            tmpSprite = cc.Sprite:create("General/" .. roleList[history.index%13] ..".png")
            tmpSprite:setScale(0.75)
            tmpSprite:setPosition(cc.p(60,60))
        else 
            tmpSprite = cc.Sprite:create("History/" .. history.type ..".png")
            tmpSprite:setPosition(cc.p(60,60))
        end 

        node:addChild(tmpSprite,0)

        node:setAnchorPoint(1,0.5)
        node:setPosition(cc.p(index*106,80))
        tmpNode:addChild(node)
    end 
    tmpNode:setAnchorPoint(cc.p(0,0))
    tmpNode:setPosition(cc.p(0,0))
    history:addChild(tmpNode)
    history:setPosition(cc.p(188,380))
    if hisLen > 8 then 
        history:setContentOffset(cc.p((hisLen-8)*-106,0), false)
    end 
    self:addChild(history,10)
end

-- 更新下注信息
function BetLayer:updateBetInfo(nodeEdit)
	local textPanel = nodeEdit:getChildByName("Panel")
	Data.betCur = 0
	for i = 0, 14 do 
		local value = Data.Bets[i]
		if not value then 
			value = 0
		end 
		-- 加
		Data.betCur = Data.betCur + value 
		textPanel:getChildByName("Bet_" .. i):getChildByTag(4):setString("" .. value)
	end 

	-- 更新当前分数
	-- 分数
    Data.curScore =GlobalUserItem.lUserScore
    print("Cur Score " .. Data.curScore)
    -- 分数
    local showScore = Data.curScore - Data.betCur
    if showScore < 0 then 
        showScore = 0
    end 
    local persentNum = math.floor(showScore)
    local limitNum = math.floor(showScore - persentNum)
    --local CreditText = textPanel:getChildByName("Credit")
    --[[if limitNum < 10 then 
        CreditText:setString(persentNum .. ".0" .. limitNum)
    else 
        CreditText:setString(persentNum .. "." .. limitNum)
    end]]
    self.cridit:setString(showScore)
    print("cur bet " ..Data.betCur )
    self.curbet:setString(Data.betCur)
	self.curwin:setString("" .. Data.curWin)

    local event = cc.EventCustom:new("eventCustomRefush")
    event._usedata = showScore .. "_" .. 0
    eventDispatcher:dispatchEvent(event)

    
    self:updateJettonList(Data.curScore - Data.betCur*MaxTimes)
end 

function BetLayer:updateJettonList(score) 
    print("更新下注按钮萝莉莉" .. score)
    print(self.m_nJettonSelect)
    print(Data.curBetTypeValue[self.m_nJettonSelect])
    local btjettonscore = 0
    local judgeindex = 0
    if self.m_nJettonSelect == 0 then
        self.m_nJettonSelect = 1
    end
    for i=1,6 do
        btjettonscore =  Data.curBetTypeValue[i]
        local judgescore = btjettonscore*MaxTimes
        if judgescore > score then
            self.m_JettonBtn[i]:setEnabled(false)
        else
            self.m_JettonBtn[i]:setEnabled(true)
            judgeindex = i
        end
    end
    if self.m_nJettonSelect > judgeindex then
        self.m_nJettonSelect = judgeindex
        if judgeindex == 0 then
            self:setJettonEnable(false)
        else
            self.m_JettonLight:setPosition(self.m_JettonBtn[judgeindex]:getPosition())
        end
    end
end

-- 刷新单个数字
function BetLayer:refushBetInfo(nodeEdit)

end 

-- 按钮事件处理
function BetLayer:buttonEvent(nodeEdit)
    local function sendBet()
        --sendPack = ""
        local cmddata = CCmd_Data:create(60)

        local needUpdate = false
        local curBet = 0
        Data.lastBets = {}
        for i = 0, 14 do 
            local vBet = Data.Bets[i]
            Data.lastBets[i] = vBet
            if not vBet then 
                vBet = 0
            end  
            if vBet > 0 then 
                needUpdate = true 
            end 
            curBet = curBet + vBet
            print("下注金额 " .. vBet)
            cmddata:pushint(vBet)
            -- local bTmp = bpack("i", vBet)
            -- cclog(hex(bTmp));
            --sendPack = sendPack .. bTmp
        end 
        -- 记录上次下注
        

        -- 记录总下注
        Data.sureBet = curBet
        -- 发送下注消息
        self._scene._scene:SendData(Data.SUB_C_BET,cmddata)
        --SendGameMsg(Data.SUB_C_BET, string.len(sendPack), sendPack)
    end

    -- 退出游戏
    -- local SystemButton = nodeEdit:getChildByName("System")
    -- SystemButton:setVisible(false)
    -- SystemButton:addTouchEventListener(function(sender, eventType) 
    --         if eventType == TOUCH_EVENT_ENDED then
    --             --ccexp.AudioEngine:play2d("Sound/Button.mp3")
    --             AudioEngine.playEffect("Hall/Sound/Button.mp3")
    --             print("SystemButton Clicked!")
                
    --             --self:addChild(import("script.HelpLayer").new(), 10)
    --             cc.Director:getInstance():getRunningScene():addChild(import("Hall/SystemLayer").new(function()
    --                 print("GameApp:exitGame()")
    --                 GameApp:exitGame()
    --             end,function() 
    --                 -- 帮助
    --                 cc.Director:getInstance():getRunningScene():addChild(import("script.HelpLayer").new(), LOCAL_LEVEL_HELP)
    --             end), LOCAL_LEVEL_SYSTEM)
    --         end
    --     end)

    --倍率
 	local returnButton = nodeEdit:getChildByName("Unit") 
    returnButton:addTouchEventListener(function(sender, eventType) 
        	if eventType == TOUCH_EVENT_ENDED then
                AudioEngine.playEffect("Sound/ChangeBet.mp3")
            	print("returnButton Clicked!")
            	
                if self.CanClick then 
                    Data.curBetType = Data.curBetType + 1
                    if Data.curBetType > 5 then 
                        Data.curBetType = 1
                    end 

                    --self.betType:setSpriteFrame(cc.Sprite:create("General/x" .. Data.curBetType .. ".png"):getSpriteFrame()) 
        	   end 
            end

    	end)

    -- 重置
    local resetButton = nodeEdit:getChildByName("Clear")
    -- 下注
    local confirmButton = nodeEdit:getChildByName("Confirm")

    resetButton:setEnabled(false)
    resetButton:setBright(false)

    resetButton:addTouchEventListener(function(sender, eventType) 
        	if eventType == TOUCH_EVENT_ENDED then
                AudioEngine.playEffect("Sound/Bet.mp3")
            	release_print("resetButton Clicked!")
                if self.CanClick then
                    local size = #Data.history
                    release_print("Data.history " .. size)
                    if size > 0 then 
                        local info = Data.history[#Data.history]
                    
                        if info then 
                            Data.history[#Data.history] = nil
                            local curIndexBet = Data.Bets[info[1]]
                            local value = info[2]
 
                            -- 下注区域减少
                            Data.Bets[info[1]] = curIndexBet - value
                            
                            local textPanel = nodeEdit:getChildByName("Panel")
                            textPanel:getChildByName("Bet_" .. info[1]):getChildByTag(4):setString("" .. Data.Bets[info[1]])

                            -- 总下注减少
                            Data.betCur = Data.betCur - value 
                            self.curbet:setString("" .. Data.betCur)

                            -- 分数
                            Data.curScore = GlobalUserItem.lUserScore
                            local showScore = Data.curScore - Data.betCur
                            if showScore < 0 then 
                                showScore = 0
                            end 
                            self.cridit:setString(showScore)

                            sendBet()
                            -- 可undo为0
                            if #Data.history == 0 then 
                                resetButton:setEnabled(false)
                                resetButton:setBright(false)
                                confirmButton:setEnabled(false)
                                confirmButton:setBright(false)
                            else 
                                confirmButton:setEnabled(true)
                                confirmButton:setBright(true)
                            end
                            release_print("总押注："..Data.betCur)
                            release_print("原本总分："..GlobalUserItem.lUserScore)
                            release_print("总分："..showScore)
                            -- 更新分数
                            local event = cc.EventCustom:new("eventCustomRefush")
                            event._usedata = showScore .. "_" .. 0
                            eventDispatcher:dispatchEvent(event)

                        end
                    end
                end 
        	end
    	end)

	
    --下注
    confirmButton:setEnabled(false)
    confirmButton:setBright(false)
    confirmButton:addTouchEventListener(function(sender, eventType) 
        	if eventType == TOUCH_EVENT_ENDED then
                AudioEngine.playEffect("Sound/Sure.mp3")
            	print("confirmButton Clicked!")
                --[[
                local function sendBet()
                    sendPack = ""
                    local needUpdate = false
                    local curBet = 0
                    for i = 0, 14 do 
                        local vBet = Data.Bets[i]
                        if not vBet then 
                            vBet = 0
                        end  
                        if vBet > 0 then 
                            needUpdate = true 
                        end 
                        curBet = curBet + vBet

                        local bTmp = bpack("i", vBet)
                        cclog(hex(bTmp));
                        sendPack = sendPack .. bTmp
                    end 
                    -- 记录上次下注
                    Data.lastBets = Data.Bets

                    -- 记录总下注
                    Data.sureBet = curBet
                    -- 发送下注消息
                    SendGameMsg(Data.SUB_C_BET, string.len(sendPack), sendPack)
                end ]]
                if self.CanClick then
                    Data.IsClean = false
                    sendBet()
                    Data.sureBet = Data.betCur
                    Data.sureButton = true
                    confirmButton:setEnabled(false)
                    confirmButton:setBright(false)
                    resetButton:setEnabled(true)
                    resetButton:setBright(true)


                    local event = cc.EventCustom:new("eventCustomBetRet")
                    event._usedata = true
                    eventDispatcher:dispatchEvent(event)
                end 
        	end
    	end)
end 

-- 监听下注事件
function BetLayer:BetEventAttouch(nodeEdit)
    -- 初始
    local headFile = {"Monkey_1","Sun_1","sha_1","Niu_1","Monkey_1","Sun_1","sha_1","Niu_1","Monkey_1","Sun_1","sha_1","Niu_1","Bank","Tie","Player"}
    local headGrayBet = {1,1,1,1,2,2,2,2,3,3,3,3,1,2,3}

    -- 点击事件
    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        if cc.rectContainsPoint(rect, locationInNode) then
            return true
        end
        return false
    end

    -- 
    local function onTouchEnded(touch, event)
        if not self.CanClick then
            return 
        end 

        if self.m_nJettonSelect == 0  then
            return
        end
        local target = event:getCurrentTarget()
        -- 分数
        Data.curScore = GlobalUserItem.lUserScore
        --Data.curScore = 5000
        print("curBet " .. Data.curScore)
        dump(self.m_nJettonSelect)
        local jettonscore = Data.curBetTypeValue[self.m_nJettonSelect]

        --print("sprite onTouchesEnded..")
        local curBet = Data.Bets[target:getTag()]
        if not curBet then 
            curBet = 0
        end 

        local selfscore  = (jettonscore + Data.betCur)*MaxTimes
        print("当前下注：" .. jettonscore)
        print("已经下注" .. Data.betCur)
        if  selfscore > Data.curScore then
            showToast(self,"已超过个人最大下注值",1)
            return
        end
        if curBet >= 10000000 then 
            return 
        end 
        --curBet = curBet + Data.curBetType
        -- 大于单位下注
        local curBetValue = Data.curBetTypeValue[self.m_nJettonSelect]
        dump(curBetValue)
        dump(Data.curBetTypeValue)
        dump(self.m_nJettonSelect)
        local disBet = 0

        if curBet + curBetValue > 200000000 then 
            print("Data.curBetType " .. curBetValue)
            disBet = 1000 - curBet
        else 
            disBet = curBetValue
        end 
        -- print("disbet " .. disBet)
        -- 下注大于分数
        local tmpScore = (Data.betCur + disBet)
        print("tmpScore " .. tmpScore)
        if tmpScore > Data.curScore then 
            return
            --disBet = math.floor(Data.curScore - Data.betCur*10)
        end
        
        AudioEngine.playEffect("Sound/Bet.mp3")
        print("disbet " .. disBet)
        print("curBet " .. curBet)
        curBet = curBet + disBet
        print("curBet " .. curBet)
        -- 总下注增加
        Data.betCur = Data.betCur + disBet 
        self.curbet:setString("" .. Data.betCur)
        -- 赋值
        Data.Bets[target:getTag()] = curBet

        print("curBet " .. curBet)
        print("【下注位置】:" .. target:getTag())

        -- 添加历史记录
        local history = {}
        history[1] = target:getTag()
        history[2] = disBet
        Data.history[#Data.history+1] = history

        
         
         local cmddata = CCmd_Data:create(60)
         local needUpdate = false
         local curBet2 = 0
         Data.lastBets = {}
         for i = 0, 14 do 
             local vBet = Data.Bets[i]
             Data.lastBets[i] = vBet
             if not vBet then 
                 vBet = 0
             end  
             if vBet > 0 then 
                 needUpdate = true 
             end 
             curBet2 = curBet2 + vBet
             print("下注金额 " .. vBet)
             cmddata:pushint(vBet)
       
         end 
         -- 记录总下注
         Data.sureBet = curBet2
         -- 发送下注消息
         self._scene._scene:SendData(Data.SUB_C_BET,cmddata)
         
        -- -- 下注
        target:getChildByTag(4):setString("" .. curBet)
        target:getChildByTag(1):setVisible(true)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function()
            target:getChildByTag(1):setVisible(false)
        end),nil))
        
        local showScore = Data.curScore - Data.betCur
        if showScore < 0 then 
            showScore = 0
        end 

        --[[
        local persentNum = math.floor(showScore)
        local limitNum = math.floor(showScore - persentNum*100)

        if limitNum < 10 then 
            CreditText:setString(persentNum .. ".0" .. limitNum)
        else 
            CreditText:setString(persentNum .. "." .. limitNum)
        end ]]
        self.cridit:setString(showScore)
        -- --target:setColor(cc.c3b(255, 0, 0))

        -- nodeEdit:getChildByName("Confirm"):setEnabled(true)
        -- nodeEdit:getChildByName("Confirm"):setBright(true)
        -- nodeEdit:getChildByName("Clear"):setEnabled(true)
        -- nodeEdit:getChildByName("Clear"):setBright(true)

        -- -- 更新分数
        -- local event = cc.EventCustom:new("eventCustomRefush")
        -- event._usedata = showScore .. "_" .. 0
        -- eventDispatcher:dispatchEvent(event)
    end

    local initDouble = {}

    for i = 1, 3 do 
        for j =1, 4 do 
            local double = Data.arrayProbability[Data.nInitDouble[i]+1]
            initDouble[(i-1)*4+j] = double[j]
        end 
    end 
    initDouble[13] = 2
    initDouble[14] = 8
    initDouble[15] = 2

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

    -- 监听点击图片
    local betContain = nodeEdit:getChildByName("Panel")
    if betContain then 
        for i = 0, 14 do 
            local sprite = betContain:getChildByName("Bet_" ..i)
            
            if sprite then 
                local gray_bet = cc.Sprite:create("General/"..headGrayBet[i+1]..".png") 
                gray_bet:setPosition(cc.p(114,40))
                gray_bet:setScaleX(1.18)
                gray_bet:setScaleY(1.09)
                gray_bet:setVisible(false)
                sprite:addChild(gray_bet,1,1)

                -- 头像，下注，倍率
                local head = cc.Sprite:create("General/" .. headFile[i+1] .. ".png") 
                if i >= 12 and i <= 14 then
                    head:setPosition(cc.p(45,40))
                    sprite:addChild(head,1,2)
                else
                    if i == 1 or i == 5 or i == 9 then
                        head:setPosition(cc.p(45,41))
                        sprite:addChild(head,1,2)
                    else
                        head:setPosition(cc.p(45,43))
                        sprite:addChild(head,1,2)
                    end
                end

                local double = cc.LabelAtlas:_create("" .. initDouble[i+1],"General/NumDouble.png",22,28,46)
                double:setAnchorPoint(cc.p(0.5,0.5))
                double:setPosition(cc.p(159,59))
                sprite:addChild(double, 1,3)

                local bet = cc.LabelAtlas:_create("0","General/NumScore.png",21,30,46)
                bet:setAnchorPoint(cc.p(0.5,0.5))
                bet:setScale(0.9)
                bet:setPosition(cc.p(159,21))
                sprite:addChild(bet, 1,4)

                --print("sprite:addTouchEventListener")
                local listener = cc.EventListenerTouchOneByOne:create()
                listener:setSwallowTouches(true)
                listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
                listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
                eventDispatcher:addEventListenerWithSceneGraphPriority(listener, sprite)

                --gray_bet:setVisible(true)
                --self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()

                --end),nil))
            end 
        end 
    end 
end 

-- 彩金变化
function BetLayer:GameJackpot()
    self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
        self.Jackpot:setPosition(cc.p(285,509))
        self.Jackpot:setString(string.format("%.2f", math.random(100000,999999)))
        self:GameJackpot()
    end )))
end



--设置下注按钮是否可以点击
function BetLayer:setJettonEnable(value)
    for k,v in pairs(self.m_JettonBtn) do
        v:setEnabled(value)
    end
    if nil ~= self.m_JettonLight then
        self.m_JettonLight:setVisible(value)
        if value == false then
            self.m_JettonLight:stopAllActions()
        elseif value == true then
            self.m_JettonLight:runAction(cc.RepeatForever:create(cc.Blink:create(1.0,1)))
        end
    end
end

--下注响应
function BetLayer:onJettonButtonClicked(tag, ref)
    print("tag是" .. tag)
    self.m_nJettonSelect = tag
    self.m_JettonLight:setPosition(ref:getPosition())
end

--按钮点击事件
function BetLayer:onButtonClickedEvent(tag,ref)
	if TAG_ENUM.BT_JETTONSCORE_0 <= tag and TAG_ENUM.BT_JETTONSCORE_6 >= tag then
        self:onJettonButtonClicked(ref:getTag()-TAG_ENUM.BT_JETTONSCORE_0+1, ref)
	end
end

function BetLayer:onUpdateUserInfo()
	
	--设置玩家头像
	local avatar = self._node:getChildByName("sp_avatar")
	if nil ~= avatar then
		avatar:updateHead(GlobalUserItem)
	else
		local avatarFrame = self._node:getChildByName("sp_head")
		HeadSprite:createClipHead(GlobalUserItem, 64, "sp_avatar_mask_64.png")
			  :setPosition(avatarFrame:getPosition())
			  :setName("sp_avatar")
			  :addTo(self._node)
	end

	local txtNickName = self._node:getChildByName("lab_nick")
	--昵称判断不大于14个字符长度
	local signstrtable = ExternalFun.utf8StringSplit(GlobalUserItem.szNickName)
    local signstr = ""
    local signlen = 1
    for i = 1, #signstrtable do
        if signlen > 10 then
            break
        end
        local str = signstrtable[i]
        local dropping = string.byte(str)
        if dropping >= 128 then
            signlen = signlen + 2
        else
            signlen = signlen + 1
        end
        signstr = signstr..str
    end
    print(signlen)
    if signlen > 10 then
        signstr = signstr.."..."
    end
	txtNickName:setString(signstr)
end

return BetLayer