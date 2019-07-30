--
-- Author: Your Name
-- Date: 2015-09-24 18:58:25
--

local ResultLayer = class("ResultLayer", function ()
    return cc.Layer:create()
end)

require "cocos.init"
local module_pre = "game.yule.xiyou.src"
local Data = appdf.req(module_pre .. ".models.Data")
local scheduler = cc.Director:getInstance():getScheduler()
local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
local schedulerEntry = nil 
local HeadSprite = appdf.req(appdf.EXTERNAL_SRC .. "HeadSprite")
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local QueryDialog = appdf.req("app.views.layer.other.QueryDialog")
function ResultLayer:ctor(scene)
    print("进来222222222")
    self._scene = scene
    self:init()
end

function ResultLayer:onEnter()
	--Data.nTurnIndex = 0
end 

function ResultLayer:onExit()
    
end 

function ResultLayer:init()
	self:setTouchEnabled(true)
	self:registerScriptHandler(function (event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end)

    local node = cc.CSLoader:createNode("Edit/BetLayer.csb")
    self:addChild(node)
    --昵称 

    --设置玩家头像
	local avatar = node:getChildByName("sp_avatar")
	if nil ~= avatar then
		avatar:updateHead(GlobalUserItem)
	else
		local avatarFrame = node:getChildByName("sp_head")
		HeadSprite:createClipHead(GlobalUserItem, 64, "sp_avatar_mask_64.png")
			  :setPosition(avatarFrame:getPosition())
			  :setName("sp_avatar")
			  :addTo(node)
	end

	local txtNickName = node:getChildByName("lab_nick")
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
    
    --按钮灰掉
    for i=1,6 do
        local str = string.format("bt_jetton_%d", i)
        local btn = node:getChildByName(str)
        btn:setEnabled(false)
    end
    node:getChildByName("im_jetton_effect"):setVisible(false)

    if Data.nStartType == Data.Choi_Line then
        require("script.MainLayer").WinJackpot:setVisible(false)
        require("script.MainLayer").WinJackpotWin:setVisible(false)
        -- local WinJackpot = cc.Sprite:create("General/Jackpot.png")
        -- WinJackpot:setPosition(cc.p(288,515))
        -- self:addChild(WinJackpot, 10)
        
        -- local WinJackpotWin = cc.LabelAtlas:_create("" .. Data.GameJackpotScore,"General/NumScore.png",21,30,46)
        -- WinJackpotWin:setAnchorPoint(cc.p(0.5,0.5))
        -- WinJackpotWin:setPosition(cc.p(288,509))
        -- self:addChild(WinJackpotWin, 20)
    end

    self.Jackpot = node:getChildByName("JackpotNum")
    self.Jackpot:setPosition(cc.p(285,509))
    self.Jackpot:setString(string.format("%.2f", math.random(100000,999999)))
    if Data.bJackpot2 then
        Data.bJackpot2 = false
        self:GameJackpot()
    end

    Data.curScore = GlobalUserItem.lUserScore
    --print("Cur Score " .. Data.curScore)
    -- 分数
    local showScore = Data.curScore
    if showScore < 0 then 
        showScore = 0
    end 

 
    self.cridit = cc.Label:createWithTTF(Data.curScore, "fonts/round_body.ttf", 20) 
    self.cridit:setAnchorPoint(cc.p(0,0.5))
    --self.cridit:setScale(0.8)
    self.cridit:setPosition(cc.p(97,30))
    self:addChild(self.cridit, 1)

    -- 更新分数
    --Data.msgMgr[1234] = nil
    --Data.msgMgr[1234] = function()
            self.cridit:setString("" .. GlobalUserItem.lUserScore)
        --end

    if not Data.sureBet then 
        Data.sureBet = 0
    end 
    
    print("---------------:"..Data.sureBet)
    self.curbet = cc.LabelAtlas:_create("" .. Data.sureBet,"General/NumScore.png",21,30,46)
    self.curbet:setAnchorPoint(cc.p(0,0.5))
    --self.curbet:setScale(0.8)
    self.curbet:setPosition(cc.p(337,43))
    self:addChild(self.curbet, 1)

    self.curwin = cc.LabelAtlas:_create("" ..Data.nStartWin,"General/NumScore.png",21,30,46)
    self.curwin:setAnchorPoint(cc.p(0,0.5))
    --self.curwin:setScale(0.8)
    self.curwin:setPosition(cc.p(580,43))
    self:addChild(self.curwin, 1)

    -- self.betType = cc.Sprite:create("General/x".. Data.curBetType .. ".png")
    -- self.betType:setAnchorPoint(cc.p(0.5,0.5))
    -- self.betType:setPosition(cc.p(175,25))
    -- self:addChild(self.betType, 1)

    -- if Data.nStartType == Data.Choi_Line then 
    --     local tmpSprite = cc.Sprite:create("Ani/Bet/0.png")
    --     tmpSprite:setPosition(cc.p(360,59))
    --     self:addChild(tmpSprite, 1)

    --     local animFrames = {}
    --     for i = 1,11 do 
    --         local sprite = cc.Sprite:create("Ani/Bet/" .. (i-1) .. ".png")
    --         animFrames[i] = sprite:getSpriteFrame()
    --     end

    --     local animation = cc.Animation:createWithSpriteFrames(animFrames, 0.07)
    --     tmpSprite:runAction( cc.RepeatForever:create( cc.Animate:create(animation) ) )

    --     --local fade = cc.Sequence:create(cc.FadeTo:create(0.5, 50),cc.FadeTo:create(0.5, 255))
    --     --tmpSprite:runAction(cc.RepeatForever:create(fade))
    -- end 

    -- 刷新数值显示
    self:BetEventAttouch(node)

    local function onTouchBegan(touch, event)
        return true
    end

    local eventDispatcher = self:getEventDispatcher()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function(touches, event)
        if self.removeEventListenerCallback then 
            self.removeEventListenerCallback()
            self.removeEventListenerCallback = nil 
        end

        --self:removeFromParent(true)
        print("游戏结束")
        --SendGameMsg(Data.SUB_C_ROUND_END,0,"") 
    end, cc.Handler.EVENT_TOUCH_ENDED)

    eventDispatcher:addEventListenerWithFixedPriority(listener, -129)
    self.removeEventListenerCallback = function()
            eventDispatcher:removeEventListener(listener)
        end 

    -- 输赢显示
    local nodewin = cc.Node:create()
    nodewin:setPosition(700,350)
    nodewin:setAnchorPoint(0.5,0.5)
    nodewin:setScale(0.65)
    self:addChild(nodewin,100)

    local winleft = cc.Sprite:create("General/WinBack.png")
    winleft:setAnchorPoint(cc.p(1,0.5))
    winleft:setPosition(cc.p(-150,0))
    nodewin:addChild(winleft, 10)

    winleft = cc.LabelAtlas:_create("" .. Data.nStartWin,"General/Num_8.png",96,136,46)
    winleft:setAnchorPoint(cc.p(0,0.5))
    winleft:setPosition(cc.p(-70,0))
    nodewin:addChild(winleft, 10)

    node:getChildByName("Unit"):setVisible(false)
    node:getChildByName("Unit"):setEnabled(false)
    node:getChildByName("Unit"):setBright(false)
    node:getChildByName("Confirm"):setEnabled(false)
    node:getChildByName("Confirm"):setBright(false)
    node:getChildByName("Confirm"):setVisible(false)
    node:getChildByName("Clear"):setEnabled(false)
    node:getChildByName("Clear"):setBright(false)
    node:getChildByName("Clear"):setVisible(false)

    -- New Game
    local newGameButton = node:getChildByName("NewGame")
    newGameButton:setVisible(false)

    self:runAction(cc.Sequence:create(cc.DelayTime:create(5),cc.CallFunc:create(function()
        if self.removeEventListenerCallback then 
            self.removeEventListenerCallback()
            self.removeEventListenerCallback = nil 
        end

        --self:removeFromParent(true)
        print("游戏结束")

        local cmddata = CCmd_Data:create(0)
        dump(self._scene)
        dump(self._scene._scene)
        --self._scene._scene._scene:SendData(Data.SUB_C_ROUND_END,cmddata) 
        self:getParent()._scene:SendData(Data.SUB_C_ROUND_END,cmddata) 
        if self:getParent()._scene.isStandUp == true then
            self:getParent():GoldIsGoOn()
        end
        
    end )))
end 


-- 监听下注事件
function ResultLayer:BetEventAttouch(nodeEdit)
    -- 初始
    local headFile = {"Monkey_1","Sun_1","sha_1","Niu_1","Monkey_1","Sun_1","sha_1","Niu_1","Monkey_1","Sun_1","sha_1","Niu_1","Bank","Tie","Player"}
    local initDouble = {}
    local gray_Wukong = nil
    local gray_Sha = nil
    local gray_Niu = nil
    local gray_Last = nil

    for i = 1, 3 do 
        for j =1, 4 do 
            local double = Data.arrayProbability[Data.nInitDouble[i]+1]
            initDouble[(i-1)*4+j] = double[j]
        end 
    end 
    initDouble[13] = 2
    initDouble[14] = 8
    initDouble[15] = 2

    local fadeinandout = {}
    local orderIndex = {1,5,9,2,6,10,3,7,11,0,4,8,12,13,14}
    for i = 1, 10 do 
        local index = Data.nStartIndex[i]
        
        if index == -1 or not index then 
            break
        end 

        index = index %13
        if index ~= 0 then 
            index = orderIndex[index]
            fadeinandout[index] = true
        end 
    end

    fadeinandout[12+Data.nStartColor] = true

    -- 监听点击图片
    local betContain = nodeEdit:getChildByName("Panel")
    if betContain then 
        for i = 0, 11 do 
            local sprite = betContain:getChildByName("Bet_" ..i)
            if sprite then 
                gray = cc.Sprite:create("General/gray.png") 
                gray:setPosition(cc.p(114,40))
                sprite:addChild(gray,1,1)
                gray:setVisible(false)

                -- 头像，下注，倍率
                local head = cc.Sprite:create("General/" .. headFile[i+1] .. ".png") 
                if i == 1 or i == 5 or i == 9 then
                    head:setPosition(cc.p(45,40))
                    sprite:addChild(head,1,2)
                else
                    head:setPosition(cc.p(45,43))
                    sprite:addChild(head,1,2)
                end

                local double = cc.LabelAtlas:_create("" .. initDouble[i+1],"General/NumDouble.png",22,28,46)
                double:setAnchorPoint(cc.p(0.5,0.5))
                double:setPosition(cc.p(159,59))
                sprite:addChild(double, 1,3)

                local betinfo = Data.lastBets[i]
                if not betinfo then 
                    betinfo = 0
                end 

                local bet = cc.LabelAtlas:_create("" ..betinfo,"General/NumScore.png",21,30,46)
                bet:setAnchorPoint(cc.p(0.5,0.5))
                bet:setScale(0.9)
                bet:setPosition(cc.p(159,21))
                sprite:addChild(bet, 1,4)

                ---------------------------------------------------------------------
                if i == 0 or i == 4 or i == 8 then
                    gray_Wukong = cc.Sprite:create("General/gray_Wukong.png") 
                    gray_Wukong:setPosition(cc.p(114,42))
                    sprite:addChild(gray_Wukong,1,5)
                    gray_Wukong:setVisible(false)
                elseif i == 2 or i == 6 or i == 10 then
                    gray_Sha = cc.Sprite:create("General/gray_Sha.png") 
                    gray_Sha:setPosition(cc.p(114,42))
                    sprite:addChild(gray_Sha,1,5)
                    gray_Sha:setVisible(false)
                elseif i == 3 or i == 7 or i == 11 then
                    gray_Niu = cc.Sprite:create("General/gray_Niu.png") 
                    gray_Niu:setPosition(cc.p(114,42))
                    sprite:addChild(gray_Niu,1,5)
                    gray_Niu:setVisible(false)
                else
                    gray_Last = cc.Sprite:create("General/gray_Last.png") 
                    gray_Last:setPosition(cc.p(114,42))
                    sprite:addChild(gray_Last,1,5)
                    gray_Last:setVisible(false)
                end
                ---------------------------------------------------------------------

                -- 闪烁
                if fadeinandout[i] or Data.nStartType == Data.Choi_FourInOne or Data.nStartType == Data.Choi_Line then 
                    gray:setVisible(true)
                    local fade = cc.Sequence:create(cc.FadeTo:create(0.5, 50),cc.FadeTo:create(0.5, 255))
                    sprite:runAction(cc.RepeatForever:create(fade))
                else
                    if i == 0 or i == 4 or i == 8 and not fadeinandout[i] then
                        gray_Wukong:setVisible(true)
                    elseif i == 2 or i == 6 or i == 10  and not fadeinandout[i] then
                        gray_Sha:setVisible(true)
                    elseif i == 3 or i == 7 or i == 11  and not fadeinandout[i] then
                        gray_Niu:setVisible(true)
                    elseif not fadeinandout[i] then
                        gray_Last:setVisible(true)
                    end
                end 
            end 
        end 

        for i = 12, 14 do 
            local sprite = betContain:getChildByName("Bet_" ..i)
            if sprite then 
                gray = cc.Sprite:create("General/gray.png") 
                gray:setPosition(cc.p(114,40))
                sprite:addChild(gray,1,1)
                gray:setVisible(false)

                -- 头像，下注，倍率
                local head = cc.Sprite:create("General/" .. headFile[i+1] .. ".png") 
                head:setPosition(cc.p(45,40))
                sprite:addChild(head,1,2)

                local double = cc.LabelAtlas:_create("" .. initDouble[i+1],"General/NumDouble.png",22,28,46)
                double:setAnchorPoint(cc.p(0.5,0.5))
                double:setPosition(cc.p(159,59))
                sprite:addChild(double, 1,3)

                local betinfo = Data.lastBets[i]
                if not betinfo then 
                    betinfo = 0
                end 

                local bet = cc.LabelAtlas:_create("" ..betinfo,"General/NumScore.png",21,30,46)
                bet:setAnchorPoint(cc.p(0.5,0.5))
                bet:setScale(0.9)
                bet:setPosition(cc.p(159,21))
                sprite:addChild(bet, 1,4)

                ---------------------------------------------------------------------
                gray_Last = cc.Sprite:create("General/gray_Last.png") 
                gray_Last:setPosition(cc.p(114,42))
                sprite:addChild(gray_Last,1,5)
                gray_Last:setVisible(false)
                ---------------------------------------------------------------------

                -- 闪烁
                if fadeinandout[i] then 
                    gray:setVisible(true)
                    local fade = cc.Sequence:create(cc.FadeTo:create(0.5, 50),cc.FadeTo:create(0.5, 255))
                    sprite:runAction(cc.RepeatForever:create(fade))
                else
                    gray_Last:setVisible(true)
                end 
            end 
        end
    end 

    Data.lastBets = {}
end 

-- 彩金变化
function ResultLayer:GameJackpot()
    self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
        self.Jackpot:setPosition(cc.p(285,509))
        self.Jackpot:setString(string.format("%.2f", math.random(100000,999999)))
        self:GameJackpot()
    end )))
end

return ResultLayer