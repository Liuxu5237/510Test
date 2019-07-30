local GameViewLayer = class("GameViewLayer", function(scene)
    local gameViewLayer = display.newLayer()
    return gameViewLayer
end )

if not yl then
    require("client.src.plaza.models.yl")
end

local GameChat = appdf.req(appdf.CLIENT_SRC .. "plaza.views.layer.game.GameChatLayer")
--local cmd = appdf.req(appdf.GAME_SRC .. "yule.dzshowhand.src.models.CMD_Game") 
-- local SetLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.other.OptionSettingLayer")
local PopupInfoHead = appdf.req("client.src.external.PopupInfoHead")
local GameEndView = appdf.req(appdf.GAME_SRC .. "yule.dzshowhand.src.views.layer.GameEndView")
local AnimationMgr = appdf.req(appdf.EXTERNAL_SRC .. "AnimationMgr")
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local g_var = ExternalFun.req_var
local GameChatLayer = appdf.req(appdf.CLIENT_SRC .. "plaza.views.layer.game.GameChatLayer")
local module_pre = "game.yule.dzshowhand.src"
local Define = appdf.req(module_pre .. ".models.Define")
local SliderLayer = appdf.req(appdf.GAME_SRC .. "yule.dzshowhand.src.views.layer.SliderLayer")
local BankLayer = appdf.req(appdf.GAME_SRC.."yule.dzshowhand.src.views.layer.BankLayer")
local SettingLayer = appdf.req(appdf.GAME_SRC.."yule.dzshowhand.src.views.layer.SettingLayer")
local RuleLayer = appdf.req(appdf.GAME_SRC.."yule.dzshowhand.src.views.layer.RuleLayer")
local ProgressTimeLayer = appdf.req(appdf.GAME_SRC.."yule.dzshowhand.src.views.layer.ProgressTimerNode")
local TAG_ENUM = Define.TAG_ENUM
local TAG_ZORDER = Define.TAG_ZORDER






local cmd = appdf.req(appdf.GAME_SRC .. "yule.dzshowhand.src.models.CMD_Game")
--local cmd = appdf.req(module_pre .. ".models.CMD_Game")
--local Define = appdf.req(module_pre .. ".models.Define")
--local GameRoleItem = appdf.req(module_pre .. ".views.layer.GameRoleItem")
--local CardSprite = appdf.req(module_pre .. ".views.layer.gamecard.CardSprite")
--local CardsNode = appdf.req(module_pre .. ".views.layer.gamecard.CardsNode")
local GameLogic = appdf.req(module_pre .. ".models.GameLogic")
--local GameResultLayer = appdf.req(module_pre .. ".views.layer.GameResultLayer")
--local SettingLayer = appdf.req(module_pre .. ".views.layer.SettingLayer")





local ClipText = appdf.req(appdf.EXTERNAL_SRC .. "ClipText")


local module_pre = "game.qipai.land.src"

--local GameResultLayer = appdf.req(module_pre .. ".views.layer.GameResultLayer")
--local SettingLayer = appdf.req(module_pre .. ".views.layer.SettingLayer")

--local Define = appdf.req(module_pre .. ".models.Define")

local posChat = { cc.p(175, 635), cc.p(175, 395), cc.p(524, 312), cc.p(1159, 395), cc.p(1159, 635), cc.p(1159, 395), cc.p(1159, 635), cc.p(1159, 395) }
--local TAG_ZORDER = Define.TAG_ZORDER

GameViewLayer.AddScoreBtnNum = 6        -- 加注按钮个数

GameViewLayer.BT_CHIP = 8
GameViewLayer.BT_CHIP_1 = 9
GameViewLayer.BT_CHIP_2 = 10
GameViewLayer.BT_CHIP_3 = 11
GameViewLayer.BT_CHIP_4 = 12
GameViewLayer.BT_CHIP_5 = 13
GameViewLayer.BT_CHIP_6 = 14

GameViewLayer.CHIPNUM = 100
local BTN_CHAT = 104
local BT_CHAT = 105
local BTN_HELP =106

--zorder
GameViewLayer.HEAD_ZORDER = 2
GameViewLayer.USERNAME_TEXT_ZORDER = 4
GameViewLayer.USERSTATUS_TEXT_ZORDER = 2
GameViewLayer.USERSCORE_TEXT_ZORDER = 4
GameViewLayer.GAMEEND_IMG_ZORDER = 5
GameViewLayer.GAMEEND_TEXTSCORE = 6
GameViewLayer.ZORDER_NODESPINE = 10   -- spine动画节点的zorder

--动画类型
GameViewLayer.SPINE_SLIDER_ALLIN   = 1   --加注滑条上的allin动画
GameViewLayer.SPINE_USER_ALLIN      = 2   --玩家头像上的allin动画
GameViewLayer.SPINE_DESK_ALLIN     = 3   --桌面的allin动画
GameViewLayer.SPINE_SLIDER              = 4   --滑块的背景动画
GameViewLayer.SPINE_ADDSCORE_DAPAI   = 5  --大牌加分动画
GameViewLayer.SPINE_USERKUANG_DAPAI = 6  --大牌头像框动画
GameViewLayer.SPINE_HULU              = 7     --葫芦
GameViewLayer.SPINE_JINGANG          = 8   --金刚
GameViewLayer.SPINE_TONGHUASHUN = 9  --同花顺
GameViewLayer.SPINE_HJ_TONGHUASHUN =  10 --皇家同花顺
GameViewLayer.SPINE_ADDSCORE      = 11     --普通的加分
GameViewLayer.SPINE_NPC              = 12   --npc小姐姐
GameViewLayer.SPINE_HEGUAN           = 13   --荷官
GameViewLayer.SPINE_YOUWIN           = 14   --你赢了







 

function GameViewLayer:OnResetView()
    self._scene:HideScoreControl()
    self:ClearnView()
    -- self:SetCenterScore(0)
    self:SetOperatStatus(INVALID_CHAIR)
    self:OnCloseClockView()
end

function GameViewLayer:onExit()
    print("GameViewLayer onExit")
    -- cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(cmd.RES .. "game/card.plist")
    -- cc.Director:getInstance():getTextureCache():removeTextureForKey(cmd.RES .. "game/card.png")
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("gameScene_oxex.plist")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("gameScene_oxex.png")
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("game/GameRes850/game_layer.plist")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("game/GameRes850/game_layer.png")
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("game/Card/card.plist")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("game/Card/card.png")

    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
end

function GameViewLayer:getParentNode()
    return self._scene
end

function GameViewLayer:GetMeChairID()
    return self._scene:GetMeChairID()
end

function GameViewLayer:GetMeViewID()
    return self:SwitchViewChairID(self:GetMeChairID())
end

function GameViewLayer:SwitchViewChairID(wChairID)
    return self._scene:SwitchViewChairID(wChairID)
end
-- 初始化
function GameViewLayer:ctor(scene)
    self._scene = scene
    
    --时钟
	self.m_TimeProgress = {}

	    -- 聊天层
    self.m_chatLayer = nil

    --是否展示菜单
    self.m_bShowMenu = false	
	
    -- display.loadSpriteFrames(cmd.RES .. "game/card.plist", cmd.RES .. "game/card.png")
    display.loadSpriteFrames(cmd.RES .. "game/game.plist", cmd.RES .. "game/game.png")
    display.loadSpriteFrames(cmd.RES.."game/GameRes850/game_layer.plist",cmd.RES.."game/GameRes850/game_layer.png")
    display.loadSpriteFrames(cmd.RES.."game/Card/card.plist",cmd.RES.."game/Card/card.png")
    --添加搜索路径
    cc.FileUtils:getInstance():addSearchPath(cmd.RES);

    self.m_pGLPosNode = nil
    --玩家的携带金币
    self.m_CurUserMaxScore = 0
    -- 坐标节点
    self.m_tGLPosTable = { }
    -- 左边位置
    self.m_tUserNode = { }
    -- 用户节点
    self.m_tOperator = { }
    -- 操作按钮
    self.m_pCardLayer = nil
    self.m_pCardBg    = nil 
    -- 扑克层
    self.m_tHandCard = { }
    for i = 1, cmd.GAME_PLAYER	 do
        self.m_tHandCard[i] = { }
    end
    --扑克数据
    self.m_tHandCardDate = {}
    for i = 1,((cmd).GAME_PLAYER) do
        self.m_tHandCardDate[i] = {}
    end
    --spine动画节点
    self.m_tSpineNode = nil
    --spine动画管理节点
    self.m_tSpineManager = {}
    --GAME_PLAYER+1 存放的是左面的spine动画
    for i=1,((cmd).GAME_PLAYER)+1 do
        self.m_tSpineManager[i] = {}
    end
    -- 手牌
    self.m_tCenterCard = { }
    --桌面手牌数据
    self.m_tCenterCardData = {}
    -- 中心扑克
    self.m_UserChat = { }
    self.m_UserExpression = { }
    self._scene = scene
    self.nChip = { }
    -- 加注倍数  GameViewLayer.AddScoreBtnNum = 3
    self.m_csbNode = nil
    self.m_tSendCard = { }
    self._chatLayer = GameChatLayer:create(self._scene._gameFrame):addTo(self._scene, 4)
    self.m_sparrowUserItem = { }
    --聊天气泡框
    self.m_UserChatView = {}

    --游戏结算时的扑克
    self.gameEndCardImg = {}
    for i=1,((cmd).GAME_PLAYER) do
        self.gameEndCardImg[i] ={}
    end
    --计算时扑克的位置
    self.gameEndCardImgPos = {}
    for i=1,((cmd).GAME_PLAYER) do
        self.gameEndCardImgPos[i] = {}
    end 

    -- 注册onExit()
    ExternalFun.registerNodeEvent(self)
    -- 注册touch事件
    local bSwallow = false
    ExternalFun.registerTouchEvent(self, bSwallow)

    -- 加载csb资源
    local rootLayer, csbNode = ExternalFun.loadRootCSB("game/GameLayer.csb", self)
    self.m_csbNode = csbNode
    local Panel_Btn = csbNode:getChildByName("Panel_Btn")
	
	
	--聊天窗口层
	self.m_GameChat = GameChat:create(scene._gameFrame)
		:setLocalZOrder(10)
        :addTo(self)

    -- 按钮回调
    local btcallback = function(ref, type)
        if type == ccui.TouchEventType.began then
            ExternalFun.popupTouchFilter(1, false)
        elseif type == ccui.TouchEventType.canceled then
            ExternalFun.dismissTouchFilter()
        elseif type == ccui.TouchEventType.ended then
            ExternalFun.dismissTouchFilter()
            self:OnButtonClickedEvent(ref:getTag(), ref)
        end
    end

    -- 筹码缓存
    self.nodeChipPool = cc.Node:create():addTo(self)


    --菜单按钮
    self.m_btnMenu = csbNode:getChildByName("btn_menu")
    self.m_btnMenu:setTag(BT_MENU)
    self.m_btnMenu:addTouchEventListener(btcallback)
    
    
    --菜单界面
    self.m_nodeMenu = csbNode:getChildByName("node_menu")
    self.m_nodeMenu:setVisible(false)
    self.m_nodeMenu:setLocalZOrder(100)


    --换桌按钮
    self.m_btnChangeSeat = self.m_nodeMenu:getChildByName("btn_huanzuo")
    self.m_btnChangeSeat:setTag(BT_CHANGESEAT)
    self.m_btnChangeSeat:addTouchEventListener(btcallback)


    --取款按钮
    self.m_btnBank = self.m_nodeMenu:getChildByName("btn_bank")
    self.m_btnBank:setTag(BT_BANK)
    --self.m_btnBank:setEnabled(false)
    self.m_btnBank:addTouchEventListener(btcallback)

    --规则按钮
    self.m_btnRule = self.m_nodeMenu:getChildByName("btn_rule")
    self.m_btnRule:setTag(BT_RULE)
    self.m_btnRule:addTouchEventListener(btcallback)

    --设置界面
    self.m_btnSet = self.m_nodeMenu:getChildByName("btn_set")
    self.m_btnSet:setTag(BT_SET)
    self.m_btnSet:addTouchEventListener(btcallback)

    --返回界面
    self.m_return = self.m_nodeMenu:getChildByName("btn_return")
    self.m_return:setTag(BT_EXIT)
    self.m_return:addTouchEventListener(btcallback)


    --聊天按钮
    self.m_btnChat = csbNode:getChildByName("btnChat")
    self.m_btnChat:setTag(BT_CHAT)
    self.m_btnChat:addTouchEventListener(btcallback)



    -- 准备按钮
    self._BtnReady = csbNode:getChildByName("Button_Start")
    self._BtnReady:setTag(BT_READY)
    self._BtnReady:setVisible(true)
    self._BtnReady:addTouchEventListener(btcallback)

    -- 设置操作按钮
    local tOperatorName = { 'Btn_Add', 'Btn_Follow', 'Btn_GiveUp', 'Btn_ShowHand', 'Btn_Pass' }
    local tOperatorTag = { BT_ADD, BT_FOLLOW, BT_GIVEUP, BT_SHOWHAND, BT_PASS }
    for i, name in ipairs(tOperatorName) do
        local obj = Panel_Btn:getChildByName(name)
        obj:setTag(tOperatorTag[i])
        obj:addTouchEventListener(btcallback)
        obj:setVisible(false)
        table.insert(self.m_tOperator, i, obj)
    end

    -- 获取扑克层
    self.m_pCardLayer = csbNode:getChildByName("GameCardLayer")

    --扑克背景框
    self.m_pCardBg = csbNode:getChildByName("GameCardBg")
    self.m_pCardBg:setVisible(false)

    -- 初始化用户信息
    csbNode:getChildByName("UserInfoNode"):setVisible(false)
    self.m_pGLPosNode = csbNode:getChildByName("GLPosNode")
    self.m_tGLPosTable.UserInfo = { }
    for i = 1, ((cmd).GAME_PLAYER) do
        local CSBNode = self.m_pGLPosNode:getChildByName("user_"..i)
        local pos = cc.p(csbNode:getPosition())
        CSBNode:setVisible(false)
        CSBNode:setScale(0.8)
        csbNode:setLocalZOrder(10)
        self.m_tUserNode[i] = CSBNode
        self.m_tGLPosTable.UserInfo[i] = pos
        CSBNode:getChildByName("zhuangflag"):setVisible(false)
        CSBNode:getChildByName("img_status"):setVisible(false)

        --设置zorder
        CSBNode:getChildByName("UserName"):setLocalZOrder(GameViewLayer.USERNAME_TEXT_ZORDER)
        CSBNode:getChildByName("img_status"):setLocalZOrder(GameViewLayer.USERSTATUS_TEXT_ZORDER)
        CSBNode:getChildByName("Text_UserCurScore"):setLocalZOrder(GameViewLayer.USERSCORE_TEXT_ZORDER)

        --结算的背景
        local gameEnd_imgBg = CSBNode:getChildByName("Image_end_bg")
        gameEnd_imgBg:setVisible(false)
        gameEnd_imgBg:setLocalZOrder(GameViewLayer.GAMEEND_IMG_ZORDER)

        --结算分数
        local text_score = CSBNode:getChildByName("text_score")
        :setLocalZOrder(GameViewLayer.GAMEEND_TEXTSCORE)
        :setVisible(false)

        --下注
        CSBNode:getChildByName("Img_TableChip"):setVisible(false)

        --游戏结算时的扑克   
        self.gameEndCardImg[i][1] = gameEnd_imgBg:getChildByName("img_card1")
        self.gameEndCardImg[i][2] = gameEnd_imgBg:getChildByName("img_card2")
        self.gameEndCardImgPos[i][1] = cc.p(self.gameEndCardImg[i][1]:getPosition())
        self.gameEndCardImgPos[i][2] = cc.p(self.gameEndCardImg[i][2]:getPosition())

        --聊天气泡框
        self.m_UserChatView[i] = CSBNode:getChildByName("img_chatbg")
        self.m_UserChatView[i]:setVisible(false)

        self.m_TimeProgress[i] = ProgressTimeLayer:create(self._scene,self.m_tUserNode[i],0,100)
        self.m_TimeProgress[i]:setPosition(cc.p(2,7))
    end

    --玩家手牌位置
    self.m_tUserCardNode = {}
    for i = 1,((cmd).GAME_PLAYER) do

        self.m_tUserCardNode[i] =self.m_pGLPosNode:getChildByName("user_card_"..i)
        :setVisible(false)

    end

    


    -- 获取坐标位置
    self.m_tGLPosTable.SendCardStart = cc.p(self.m_pGLPosNode:getChildByName("SendCardStart"):getPosition())
    self.m_tGLPosTable.CenterCardStart = cc.p(self.m_pGLPosNode:getChildByName("CenterCardStart"):getPosition())
    self.m_tGLPosTable.ChipStart = cc.p(self.m_pGLPosNode:getChildByName("Node_Chip"):getPosition())
    for i = 1, 5 do
        self.m_tSendCard[i] = self.m_pGLPosNode:getChildByName("Img_Card_" .. i)
        self.m_tSendCard[i]:setVisible(false)
    end

    -- 筹码加注选择界面
    -- 加注节点
    self._AddScoreNode = csbNode:getChildByName("AddScoreNode")
    local AddScoreNode, AddScoreCSBNode = ExternalFun.loadRootCSB("game/AddScoreNode.csb", self._AddScoreNode)
    -- self._AddScoreNode:addChild(AddScoreCSBNode)
    AddScoreCSBNode:move(480, 40)
    -- 加注背景
    self.m_ChipBG = AddScoreCSBNode:getChildByName("AddScoreBg")
    self.m_ChipBG:setTag(BT_GOLDCONTROL)
    self.m_ChipBG:setVisible(false)

    self.m_tOperator[#self.m_tOperator + 1] = self.m_ChipBG

    -- 添加加注选择按钮
    self.btChip = { }
    for i = 1, GameViewLayer.AddScoreBtnNum do
        self.btChip[i] = self.m_ChipBG:getChildByName("Button_" .. i)
        :setPressedActionEnabled(true)
        :setTag(GameViewLayer.BT_CHIP + i)
        self.btChip[i]:addTouchEventListener(btcallback)

        -- 文本
        local AddScoreText = self.btChip[i]:getChildByName("Text_1")
        :setTag(GameViewLayer.CHIPNUM)
    end
    -- 中心奖池分数
    self.TotalScore = csbNode:getChildByName("Img_TotalScore"):setVisible(false)

    --大小盲注信息
    self.m_textCellScore = csbNode:getChildByName("txt_cellScore")
    :setString("")
    --底池分数
    self.m_textTotalScore = csbNode:getChildByName("txt_TotalScore")
       -- 语音动画
	       -- 语音按钮 gameviewlayer -> gamelayer -> clientscene
    --self:getParentNode():getParentNode():createVoiceBtn(cc.p(1250, 120), 0, top)
    --AnimationMgr.loadAnimationFromFrame("record_play_ani_%d.png", 1, 3, cmd.VOICE_ANIMATION_KEY)

    --加注slider
    self.m_tSliderLayer =  SliderLayer:create(self)
    :addTo(self.m_csbNode)
    :setPosition(cc.p(1175,73))
    :setVisible(false)

    --spine节点
    self.m_tSpineNode = cc.Node:create()
    self.m_tSpineNode:addTo(self)
    self.m_tSpineNode:setLocalZOrder(GameViewLayer.ZORDER_NODESPINE)

  
    AudioEngine.playMusic("sound_res/sound/back.mp3",true) --开启背景音乐
end


-- 文本聊天
function GameViewLayer:onUserChat(chatdata, viewId)
    local roleItem = self.m_tabUserHead[viewId]
    if nil ~= roleItem then
        roleItem:textChat(chatdata.szChatString)
    end
end

-- 表情聊天
function GameViewLayer:onUserExpression(chatdata, viewId)
    local roleItem = self.m_tabUserHead[viewId]
    if nil ~= roleItem then
        roleItem:browChat(chatdata.wItemIndex)
    end
end

-- 设置庄家
function GameViewLayer:SetDFlag(wDUserChairID, isZhuang)
    local nViewID = self:SwitchViewChairID(wDUserChairID)
    local ZhuangFlag = self.m_tUserNode[nViewID]:getChildByName("zhuangflag")
    ZhuangFlag:setVisible(isZhuang)
    ZhuangFlag:setLocalZOrder(6)
end
--设置用户每局携带分数
function GameViewLayer:SetCurUserMaxScore(wChairID,CurUserMaxScore)
    local nViewID = self:SwitchViewChairID(wChairID)
    -- 筹码
    local Text_UserCurScore = self.m_tUserNode[nViewID]:getChildByName("Text_UserCurScore")
    Text_UserCurScore:setString(tostring(CurUserMaxScore))
    self.m_CurUserMaxScore = CurUserMaxScore
end
-- 设置每人当局下注
function GameViewLayer:SetTotalScore(wChairID, lTotalScore)
    local nViewID = self:SwitchViewChairID(wChairID)
    -- 筹码
    print("下注玩身上金额" .. lTotalScore .." viewid ".. nViewID)
    local Text_Chip = self.m_tUserNode[nViewID]:getChildByName("Img_Chip"):getChildByName("Text")
    Text_Chip:setString(tostring(lTotalScore))
    self:addUserScore(wChairID,-lTotalScore)
end

-- 设置当轮下注
function GameViewLayer:SetUserTableScore(wChairID, lTableScore)
    local nViewID = self:SwitchViewChairID(wChairID)
    print("设置当轮下注额" .. lTableScore)
    -- 筹码
    local Text_TableChip = self.m_tUserNode[nViewID]:getChildByName("Img_TableChip"):getChildByName("Text")
    Text_TableChip:setString(tostring(lTableScore))
    self.m_tUserNode[nViewID]:getChildByName("Img_TableChip"):setVisible(true)
    if lTableScore <=0 then
        self.m_tUserNode[nViewID]:getChildByName("Img_TableChip"):setVisible(false)
    end

end

-- 设置游戏初始积分（改成每人总是输赢）
function GameViewLayer:SetGameInitScore(wChairID, lGameInitScore)
    local nViewID = self:SwitchViewChairID(wChairID)
    -- 用户积分
    local Text_UserGameScore = self.m_tUserNode[nViewID]:getChildByName("Img_Coin"):getChildByName("Text")
    Text_UserGameScore:setString(tostring(lGameInitScore))
end

-- 设置中心分数
function GameViewLayer:SetCenterScore(lCenterScore)
    self.TotalScore:setVisible(true)
    local text = self.TotalScore:getChildByName("Text_TotalScore")
    text:setString(tostring(lCenterScore))
    self.m_textTotalScore:setString("底池:"..lCenterScore)

    local icon = self.TotalScore:getChildByName("Img_1")
    local iconIndex = 1    
    if lCenterScore <= 10*self.m_lCellScore then
        iconIndex = 1
    elseif lCenterScore <= 50*self.m_lCellScore then
        iconIndex = 2
    elseif lCenterScore <= 100*self.m_lCellScore then
        iconIndex = 3
    elseif lCenterScore <= 200*self.m_lCellScore then
        iconIndex = 4
    else 
        iconIndex = 5
    end

    icon:loadTexture("game/GameRes850/texasHoldem_c"..iconIndex..".png",UI_TEX_TYPE_PLIST)

end

-- 设置开牌数据
function GameViewLayer:SetCardData(wChairID, tCardData, bGray)
    assert(type(tCardData) == "table" and #tCardData == 2)
    local nViewID = self:SwitchViewChairID(wChairID)
    for i, obj in ipairs(self.m_tHandCard[nViewID]) do
        self:UpdateCardSpriteByValue(obj, tCardData[i])
        if bGray then
            obj:setColor(cc.c3b(77, 77, 77))
        end
    end
end

--设置玩家手牌的可见性
function GameViewLayer:setUserCardVisible(nChairID,isVisible)

    local viewid = self:SwitchViewChairID(nChairID)

    if isVisible == nil then

        isVisible = false
   
    end

    for i,obj in ipairs(self.m_tHandCard[viewid]) do

        obj:setVisible(isVisible)
    
    end

end

-- 设置操作状态
function GameViewLayer:SetOperatStatus(wChairID, cbStatus)
    assert(wChairID)
    local nViewID = self:SwitchViewChairID(wChairID)
    if wChairID == INVALID_CHAIR then
        for i = 1, ((cmd).GAME_PLAYER) do
            self.m_tUserNode[i]:getChildByName("img_status"):setVisible(false)
            self.m_tUserNode[i]:getChildByName("UserName"):setVisible(true)
        end
    else
        self.m_tUserNode[nViewID]:getChildByName("UserName"):setVisible(false)
        local img_status = self.m_tUserNode[nViewID]:getChildByName("img_status")
        img_status:setVisible(true)
        img_status:loadTexture("game/GameRes850/texasHoldem_txt_state_"..cbStatus..".png",UI_TEX_TYPE_PLIST)

        if cbStatus == BT_SHOWHAND then

            self:showUserAllin(nViewID)

        end
        
    end
end

--设置赢的状态
function GameViewLayer:WinerFlag(wChairID,String)
   local nViewID = self:SwitchViewChairID(wChairID)
    local Text_Name = self.m_tUserNode[nViewID]:getChildByName("UserName")
    Text_Name:setColor(cc.c3b(155,165,0))
    Text_Name:setString(tostring(String))
end
-- 创建牌
function GameViewLayer:CreateCardSpriteByValue(cbCardData)
    assert(cbCardData, 'cbCardData is nil')
    local obj = ccui.ImageView:create(string.format("game/Card/card_%02d.png", cbCardData), ccui.TextureResType.plistType)
    obj:setTag(cbCardData)
    return obj
end

-- 更新牌值
function GameViewLayer:UpdateCardSpriteByValue(obj, cbCardData)
    assert(obj)
    local sName = string.format("game/Card/card_%02d.png", cbCardData)
    obj:loadTexture(sName, UI_TEX_TYPE_PLIST)
end

-- 更新时钟
function GameViewLayer:OnUpdataClockView(nViewID, nTimes)
    if not nViewID or nViewID == yl.INVALID_CHAIR then
        return
    end
    local Img_Clock = self.m_tUserNode[nViewID]:getChildByName("Img_Clock")
    Img_Clock:setVisible(false)  --不显示时钟
    local Text = Img_Clock:getChildByName("Text")
    Text:setString(string.format("%02d", nTimes))
end

-- 关闭时钟
function GameViewLayer:OnCloseClockView(nViewID)
    for i = 1, ((cmd).GAME_PLAYER) do
        local Img_Clock = self.m_tUserNode[i]:getChildByName("Img_Clock")
        Img_Clock:setVisible(false)
    end
    local progress = self.m_TimeProgress[nViewID]
    if progress ~= nil then
        progress:stopAllActions()
        progress:setVisible(false)
        progress:stop()
    end
end

-- 更新用户显示
function GameViewLayer:OnUpdateUser(nViewID, userItem)
    if not nViewID or nViewID == yl.INVALID_CHAIR then
        print("OnUpdateUser viewid is nil")
        return
    end
    self.m_sparrowUserItem[nViewID] = userItem
    self.m_tUserNode[nViewID]:setVisible(userItem ~= nil)

    if not userItem then
        self.m_tUserNode[nViewID]:setVisible(false)
        return
    else
        -- 准备标识
        self.m_tUserNode[nViewID]:getChildByName("Image_Ready"):setVisible(yl.US_READY == userItem.cbUserStatus)
        -- 头像
        local head = self.m_tUserNode[nViewID]:getChildByName("head")
        -- 头像背景
        local Img_Head = self.m_tUserNode[nViewID]:getChildByName("Img_Head")
        -- 用户初始积分
        local Text_Coin = self.m_tUserNode[nViewID]:getChildByName("Img_Coin"):getChildByName("Text")
        -- 用户累计下注
        local Text_Chip = self.m_tUserNode[nViewID]:getChildByName("Img_Chip"):getChildByName("Text")
        -- 用户当轮下注
        local Text_TableChip = self.m_tUserNode[nViewID]:getChildByName("Img_TableChip"):getChildByName("Text") 
        --self.m_tUserNode[nViewID]:getChildByName("Img_TableChip"):setVisible(false)
        -- 昵称
        local Text_Name = self.m_tUserNode[nViewID]:getChildByName("UserName")
        -- 关闭时钟
        self:OnCloseClockView(nViewID)

        Img_Head:setVisible(false)
        Text_Name:setString(userItem.szNickName)
  
        if not head then
            head = PopupInfoHead:createNormal(userItem, 90)
            head:enableInfoPop(false, self.m_tGLPosTable.UserInfo[nViewID], cc.p(0, 0))
            head:setName("head")
            head:setPosition(cc.p(Img_Head:getPosition()))
            self.m_tUserNode[nViewID]:addChild(head)
            head:updateHead(userItem)
        else
            head:updateHead(userItem)
            -- 掉线头像变灰
            if userItem.cbUserStatus == yl.US_OFFLINE then
                convertToGraySprite(head.m_head.m_spRender)
            else
                convertToNormalSprite(head.m_head.m_spRender)
            end
        end
    end
end

-- 注册触摸
function GameViewLayer:onTouchBegan(touch, event)
    return self.m_ChipBG:isVisible()
end

function GameViewLayer:onTouchMoved(touch, event)

end

function GameViewLayer:onTouchEnded(touch, event)
    local touchPos = touch:getLocation()
    touchPos = self.m_ChipBG:convertToNodeSpace(touchPos)
    local rect = self.m_ChipBG:getBoundingBox()
    if not cc.rectContainsPoint(rect, touchPos) then
        self.m_ChipBG:setVisible(false)
        self._scene:UpdateScoreControl()
        self.m_tSliderLayer:setVisible(false)
    end
end

-- 筹码移动动画
function GameViewLayer:ChipMoveAction(wViewChairId, num, notani)
    if not num or num < 1 or not self.m_lCellScore or self.m_lCellScore < 1 then
        return
    end
    if num > self.nChip[#self.nChip] then
        num = self.nChip[#self.nChip] * 3
    end
    local chipscore = num
    while
        chipscore > 0
    do
        local strChip
        local strScore
        if chipscore >= self.m_lCellScore * self.nChip[3] then
            strChip = "#bigchip_2.png"
            chipscore = chipscore - self.m_lCellScore * self.nChip[3]
            strScore =(self.m_lCellScore * self.nChip[3]) .. ""
        elseif chipscore >= self.m_lCellScore * self.nChip[2] then
            strChip = "#bigchip_1.png"
            chipscore = chipscore - self.m_lCellScore * self.nChip[2]
            strScore =(self.m_lCellScore * self.nChip[2]) .. ""
        else
            strChip = "#bigchip_0.png"
            chipscore = chipscore - self.m_lCellScore
            strScore = self.m_lCellScore .. ""
        end
        local chip = display.newSprite(strChip)
        :setScale(0.5)
        :setPosition(cc.p(self.m_tUserNode[wViewChairId]:getPosition()))
        :addTo(self.nodeChipPool)

        cc.Label:createWithTTF(strScore, "fonts/round_body.ttf", 30)
        :move(54, 53)
        :setColor(cc.c3b(48, 48, 48))
        :addTo(chip)

        chip:runAction(cc.MoveTo:create(0.2, cc.p(self.m_tGLPosTable.ChipStart.x + math.random(600), self.m_tGLPosTable.ChipStart.y + math.random(-50))))

    end
    self._scene._soundManager:playEffectCommon(1,1)
end

-- 清理视图
function GameViewLayer:ClearnView()
    self:ClearnCard()
    self:ClearnClip()
    self:ClearnSettlementView()
    self:ClearnSpine()
end

--清理结算视图
function GameViewLayer:ClearnSettlementView()

    --玩家结算时展示的牌置亮
    for i = 1,((cmd).GAME_PLAYER) do
        
        for k,v in ipairs(self.gameEndCardImg[i]) do

            v:setColor(cc.c3b(255,255,255))

        end

        self.m_tUserNode[i]:getChildByName("Image_end_bg"):setVisible(false)
        
    end
    
end

--清理spine
function GameViewLayer:ClearnSpine()
    self.m_tSpineNode:removeAllChildren()
end

-- 清理筹码
function GameViewLayer:ClearnClip()
    self.nodeChipPool:removeAllChildren()
end

-- 清理牌
function GameViewLayer:ClearnCard()
    self.m_pCardLayer:removeAllChildren()
    self.m_pCardBg:setVisible(false)

    for i = 1, ((cmd).GAME_PLAYER) do
        self.m_tHandCard[i] = { }
    end
    self.m_tCenterCard = { }
    self.m_tCenterCardData = {}

    -- test code--
    -- for i = 1, 5 do
    --        self:SendCardAction(0, 0x02, TO_CENTER_CARD)
    --    end
end

function GameViewLayer:setMoveType(moveType)

    if moveType ~= nil then

        self.m_tMoveType = moveType

    else

        self.m_tMoveType = AA_NIL

    end
    
end

function GameViewLayer:getMoveType()
    
    if self.m_tMoveType == nil then

        return AA_NIL

    else

        return self.m_tMoveType

    end

end

-- 筹码移动
function GameViewLayer:DrawMoveAnte(wChairID, iMoveType, lTableScore)
    local nViewID = self:SwitchViewChairID(wChairID)
    if lTableScore <= 0 then
        return
    end
    if iMoveType == AA_BASEFROM_TO_BASEDEST then
        -- 底注筹码下注（玩家加注）
        local fromPos = cc.p(self.m_tUserNode[nViewID]:getChildByName("Img_Head"):getPosition())
        local chipNode = self.m_tUserNode[nViewID]:getChildByName("chipPos")
        local toPos = cc.p(chipNode:getPositionX(),chipNode:getPositionY())
        self:doAction(5,fromPos,toPos,self.m_tUserNode[nViewID])
    elseif iMoveType == AA_CENTER_TO_BASEFROM then
        -- 中间筹码移至下注（赢的人）
        self:WinTheChipAction(nViewID)
    elseif iMoveType == AA_BASEDEST_TO_CENTER then
        -- 加注合并到中间(下注完成)
        local posX,posY = self.m_tUserNode[nViewID]:getChildByName("chipPos"):getPosition()
        local fromPos= self.m_tUserNode[nViewID]:convertToWorldSpace(cc.p(posX,posY))
        local toPos = cc.p(self.TotalScore:getPosition())
        self:doAction(5,fromPos,toPos,self.m_csbNode)
        
    end
end

-- 发牌动画
function GameViewLayer:SendCardAction(wChairID, cbCardData, SendCardType)
    local fDelay = 0.2
    -- 用户校验
    if not wChairID or wChairID == yl.INVALID_CHAIR then
        return
    end
    -- 转换视图
    local nViewID = self:SwitchViewChairID(wChairID)
    -- 是否显示牌值
    local isShowCardValue = false
    local fScale = nil
    if nViewID == cmd.MY_VIEWID then
        fScale = 0.5
    else
        fScale = 0.4
    end
    local fMoveTimes = 0.2
    -- 起始发牌位置
    local SendCardStartPos = self.m_tGLPosTable.SendCardStart
    -- 创建背面牌
    local spCard = self:CreateCardSpriteByValue(0x00)
    spCard:setPosition(cc.p(SendCardStartPos.x + 30, SendCardStartPos.y + 5))
    spCard:addTo(self.m_pCardLayer)
    spCard:setScale(0.01)
    -- 目的位置
    local EndPos = nil
    if SendCardType == TO_USERCARD then
        -- 用户扑克
        local nIndex = #self.m_tHandCard[nViewID] + 1
        EndPos = cc.p(self.m_tUserCardNode[nViewID]:getChildByName("card_"..nIndex):getPosition())
        self.m_tHandCard[nViewID][nIndex] = spCard
        self.m_tHandCardDate[nViewID][nIndex] = cbCardData
        self._scene._soundManager:playEffectCommon(3,1)
        --发牌动画
        local action = cc.Sequence:create(
            cc.Spawn:create(cc.EaseOut:create(cc.MoveTo:create(0.2,EndPos),1.2),cc.RotateTo:create(0.2,720),cc.ScaleTo:create(0.2,fScale)),
            cc.RotateTo:create(0,0),
            cc.DelayTime:create(0.7),
            cc.CallFunc:create(function ()
             -- 如果是自己，显示牌值
             if isShowCardValue then
                --self:UpdateCardSpriteByValue(spCard, cbCardData)
            end
        end))
        spCard:stopAllActions()
        spCard:setScale(0.2)
        spCard:runAction(action)
        

        if #self.m_tHandCard[cmd.MY_VIEWID] == ((cmd).MAX_COUNT) and nViewID == cmd.MY_VIEWID then 
            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function ()
                self:showUserPuke(TO_USERCARD,cmd.MY_VIEWID)
            end)))
        end

        -- 更新操作
        self._scene:OnSendFinish()
    elseif SendCardType == TO_CENTER_CARD then
        -- 中心扑克
        self.m_pCardBg:setVisible(true)
        local nIndex = #self.m_tCenterCard + 1
        local pos = cc.p(self.m_tSendCard[nIndex]:getPosition())
        fScale = self.m_tSendCard[nIndex]:getScale()
        spCard:setScale(fScale)
        self.m_tCenterCard[nIndex] = spCard
        self.m_tCenterCardData[nIndex] = cbCardData

        -- 创建翻牌动画
        local OrbitCamera1 = cc.OrbitCamera:create(fMoveTimes, 1, 0, 0, -90, 0, 0)

        local OrbitCamera2 = cc.OrbitCamera:create(fMoveTimes, 1, 0, 90, -90, 0, 0)
        

        if nIndex <= 3 then
            self:showDeskPuke(nIndex)
        else
            spCard:runAction(cc.Sequence:create(cc.MoveTo:create(0.13,cc.p(pos.x,pos.y)),OrbitCamera1, cc.CallFunc:create( function()
                self:UpdateCardSpriteByValue(spCard, cbCardData)
                self._scene._soundManager:playEffectCommon(3,6)
            end ), OrbitCamera2))
        end

        

        -- 更新操作
        self._scene:OnSendFinish()
        -- 断线重连，显示用户牌值
    elseif SendCardType == TO_SHOWUSERCARD then
        local nIndex = #self.m_tHandCard[nViewID] + 1
        
        local card = self.m_tUserCardNode[nViewID]:getChildByName("card_"..nIndex)
        EndPos = cc.p(card:getPosition())
        self.m_tHandCard[nViewID][nIndex] = spCard
        spCard:setScale(fScale)
        spCard:setPosition(EndPos)

        -- 如果是自己，显示牌值
        if isShowCardValue then
            self:UpdateCardSpriteByValue(spCard, cbCardData)
        end

        -- 更新操作
        self._scene:OnSendFinish()
        -- 断线重连，显示中心牌值
    elseif SendCardType == TO_SHOWCENTER_CARD then
        -- 中心扑克
        self.m_pCardBg:setVisible(true)
        local nIndex = #self.m_tCenterCard + 1
        local pos = cc.p(self.m_tSendCard[nIndex]:getPosition())
        fScale = self.m_tSendCard[nIndex]:getScale()
        spCard:setPosition(pos)
        spCard:setScale(fScale)
        self.m_tCenterCard[nIndex] = spCard

        self:UpdateCardSpriteByValue(spCard, cbCardData)

        -- 更新操作
        self._scene:OnSendFinish()

    end
end

--弃牌
function GameViewLayer:onGiveUp(viewid)
	
 	if viewid == cmd.MY_VIEWID then
 
        local cardRoot = self.m_tHandCard[viewid]
        local pukeNum = #self.m_tHandCard[viewid]
		if cardRoot == nil then return end
		local spos =cc.p(self.TotalScore:getPosition())
		local i = 0

		if cardRoot ~= nil then
			for i=1,pukeNum do
				local cardSpr = cardRoot[i]
				if cardSpr == nil then return end
                --显示背面
                self:UpdateCardSpriteByValue(cardSpr, 0)
			end
	 
		end

		function runFinish()

			self._scene._soundManager:playEffectCommon(6)
			i = i + 1
			if i > pukeNum then
				i = pukeNum
				return
			end

			local cardSpr = cardRoot[i]
            local cardSpr0 = cardSpr:clone()
			local cardSpr1 = cardSpr:clone()
			if cardSpr == nil then return end

			self:UpdateCardSpriteByValue(cardSpr, 0)
			self:UpdateCardSpriteByValue(cardSpr0, 0)
			self:UpdateCardSpriteByValue(cardSpr1, 0)

			cardSpr0:setOpacity(80)
			cardSpr1:setOpacity(50)
		 
			local ooo = cc.DelayTime:create(0.15)
			local ttt = cc.CallFunc:create(runFinish)
			local aaa = cc.EaseOut:create(cc.MoveTo:create(0.3, cc.p(spos.x ,spos.y)),2)
			local bbb = cc.RotateBy:create(0.3,360)
			local ccc = cc.FadeTo:create(0.1, 0)
			local kkk = cc.ScaleTo:create(0.3,0.2)

			local ooo0 = cc.DelayTime:create(0.1)
			local aaa0 = cc.EaseOut:create(cc.MoveTo:create(0.3, cc.p(spos.x,spos.y)),2)
			local bbb0 = cc.RotateBy:create(0.4,360)
			local ccc0 = cc.FadeTo:create(0.1, 0)
			local kkk0 = cc.ScaleTo:create(0.3,0.2)

			local ooo1 = cc.DelayTime:create(0.1)
			local aaa1 = cc.EaseOut:create(cc.MoveTo:create(0.3, cc.p(spos.x + 50,spos.y )),2)
			local bbb1 = cc.RotateBy:create(0.45,360)
			local ccc1 = cc.FadeTo:create(0.1, 0)
            local kkk1 = cc.ScaleTo:create(0.3,0.2)
            

			local ddd = cc.CallFunc:create(function()

			 	cardSpr:setVisible(false)
			 	cardSpr0:removeFromParent()
			 	cardSpr1:removeFromParent()
			 	cardSpr:setOpacity(255)

			 	if i == pukeNum then
			 
	 				if viewid == cmd.MY_VIEWID then
						for j=1,pukeNum do
							
                            local cardSpr = cardRoot[j]
                            cardSpr:setColor(cc.c3b(77, 77, 77))
							
 
							cardSpr:setScale(0.5)
							cardSpr:setRotation(0)
					 
							self:UpdateCardSpriteByValue(cardSpr, self.m_tHandCardDate[viewid][j])
						 
                            cardSpr:stopAllActions()
                            local card = self.m_tUserCardNode[viewid]:getChildByName("card_"..j)
                            local movePos = cc.p(card:getPosition())
							cardSpr:setPosition(cc.p(movePos.x,movePos.y - 200))
							cardSpr:runAction(cc.EaseOut:create(cc.MoveTo:create(0.4,movePos),1))
							cardSpr:setVisible(true)
						end
					  
					end

					print("============DzpkPukeCcsView:onGiveUp2==========")
			 	end
			end)
 
			cardSpr:runAction(cc.Sequence:create(ooo,ttt,cc.Spawn:create(aaa,bbb,kkk),ccc,ddd))
			cardSpr0:runAction(cc.Sequence:create(ooo0,cc.Spawn:create(aaa0,bbb0,kkk0),ccc0))
			cardSpr1:runAction(cc.Sequence:create(ooo1,cc.Spawn:create(aaa1,bbb1,kkk1),ccc1))
 
		end

		runFinish()
		 
 	else
 		local cardRoot = self.m_tHandCard[viewid]
		if cardRoot == nil then return print("return huiqu le") end
		local spos =cc.p(self.TotalScore:getPosition())
		for i=1,#cardRoot do
			local cardSpr = cardRoot[i]
			if cardSpr == nil then return print("return huiqu le2") end
            self:UpdateCardSpriteByValue(cardSpr, 0)
            local spawn = cc.Spawn:create(cc.EaseOut:create(cc.MoveTo:create(0.2, spos),1),cc.RotateTo:create(0.2,720),cc.ScaleTo:create(0.2,0.1))
			local action = cc.Sequence:create(spawn,cc.FadeTo:create(0.1, 0),cc.CallFunc:create(function()
			 	cardSpr:setVisible(false)
			 	cardSpr:setOpacity(255)
			end))
	 
			cardSpr:stopAllActions()
			cardSpr:runAction(action)
		end
 	end
	
end

--翻牌动画
function GameViewLayer:FlipCardAni (viewid,FlipType)
    if viewid == nil then
        return
    end

    if TO_USERCARD == FlipType then  --用户的牌
    end
end

-- 移动扑克
function GameViewLayer:DrawMoveCard(wChairID, iMoveType, cbCardData)
    local nViewID = self:SwitchViewChairID(wChairID)
    if iMoveType == TO_USERCARD then
        -- 用户扑克
        self:SendCardAction(wChairID, cbCardData, TO_USERCARD)
    elseif iMoveType == TO_SHOWUSERCARD then
        -- 用户扑克(不要动画效果，用于断线重连)
        self:SendCardAction(wChairID, cbCardData, TO_SHOWUSERCARD)
    elseif iMoveType == TO_CENTER_CARD then
        -- 中心扑克
        self:SendCardAction(wChairID, cbCardData, TO_CENTER_CARD)
    elseif iMoveType == TO_SHOWCENTER_CARD then
        -- 中心扑克(不要动画效果，用于断线重连)
        self:SendCardAction(wChairID, cbCardData, TO_SHOWCENTER_CARD)
    elseif iMoveType == TO_GIVEUP_CARD then
        -- 回收扑克(弃牌)
        self:onGiveUp(nViewID)
    end
end

-- 设置底分
function GameViewLayer:SetCellScore(m_lCellScore)
    self.m_lCellScore = m_lCellScore
    self.m_textCellScore:setString(string.format("小/大盲注%d/%d",m_lCellScore,m_lCellScore*2))
end

-- 赢得筹码动画
function GameViewLayer:WinTheChipAction(wWinnerViewID)
    -- 筹码动作
    local children = self.nodeChipPool:getChildren()
    self._scene._soundManager:playEffectCommon(1,2)
    for k, v in pairs(children) do
        v:runAction(cc.Sequence:create(cc.DelayTime:create(0.1 *(#children - k)),
        cc.MoveTo:create(0.5, cc.p(self.m_tUserNode[wWinnerViewID]:getPosition())),
        cc.CallFunc:create( function()
            self.nodeChipPool:removeAllChildren()
        end )))
    end
end


-- 按键响应
function GameViewLayer:OnButtonClickedEvent(tag, ref)
    ExternalFun.playClickEffect()
    if tag == BT_EXIT then
        self._scene:onQueryExitGame()
    elseif tag == BT_READY then
        -- 准备
        self._BtnReady:setVisible(false)
        self._scene:onStartGame(true)
    elseif tag == BT_GIVEUP then
        -- 弃牌
        self._scene:OnGiveUp()
    elseif tag == BT_ADD then
        -- 加注
        self._scene:OnAddScore()
    elseif tag == GameViewLayer.BT_CHIP_1 then
        self._scene:OnOKScore(self.nChip[1])
    elseif tag == GameViewLayer.BT_CHIP_2 then
        self._scene:OnOKScore(self.nChip[2])
    elseif tag == GameViewLayer.BT_CHIP_3 then
        self._scene:OnOKScore(self.nChip[3])
    elseif tag == GameViewLayer.BT_CHIP_4 then
        self._scene:OnOKScore(self.nChip[4])
    elseif tag == GameViewLayer.BT_CHIP_5 then
        self._scene:OnOKScore(self.nChip[5])
    elseif tag == BT_FOLLOW then
        -- 跟注
        self._scene:OnFollow()
        -- elseif tag == BT_SHOWHAND then
    elseif tag == GameViewLayer.BT_CHIP_6  then
        -- 梭哈（全下）
        self._scene:OnShowHand()
    elseif tag == BT_PASS then
        -- 让牌
        self._scene:OnPassCard()
    elseif tag == BT_CHAT then
	    self._chatLayer:showGameChat(true)
		self:ShowMenu(false)
    elseif tag == BT_SET then
        self:showMenuSecondLayer(BT_SET,true)
        self:ShowMenu(false)
      
    --玩法
    elseif  BTN_HELP == tag then
       self._scene._scene:popHelpLayer(cmd.KIND_ID, 0)
    elseif BT_CHANGESEAT == tag then
        --2017.7.16 坐下状态以上才能换桌，防止分数不够被剔除后点换桌提示网络断开
        local MeUserItem = self._scene._gameFrame:GetMeUserItem()
        if MeUserItem.cbUserStatus >= yl.US_SIT then
            self._scene:onChangeDesk()
            --self.m_AreaMenu:setVisible(self.m_bShowMenu)
            self:ShowMenu(false)
            self:OnResetView() 								--重置
        else
            self._scene:onExitTable()
        end 								--重置
    elseif BT_MENU == tag then
        self:ShowMenu(not self.m_bShowMenu)
    elseif BT_BANK == tag then  --银行
        --self:showMenuSecondLayer(BT_BANK,true)
        self:ShowMenu(false)
        showToast(self,"功能尚未开放，敬请期待！",2)
    elseif BT_RULE == tag then
        self:showMenuSecondLayer(BT_RULE,true)
        self:ShowMenu(false)
    end
	
end

-- function GameViewLayer:ShowMenu(bShow)
-- 	local this = self
-- 	if self.m_bShowMenu ~= bShow then
-- 		self.m_bShowMenu = bShow
		
-- 		if self.m_bShowMenu == true and not self.m_AreaMenu:isVisible() then
-- 			self.m_AreaMenu:setVisible(true)
-- 			self.m_AreaMenu:runAction(
-- 				cc.Sequence:create(
-- 					cc.MoveTo:create(0.3,cc.p(240 + 96,692)),
-- 					cc.CallFunc:create(
-- 					function()
-- 						this:setMenuBtnEnabled(true)
-- 					end
-- 				)))
		
-- 		end
-- 	end
-- end

-- 更新可以加注的按钮
function GameViewLayer:UpdateAddScoreBtn(CanAddMaxScore,m_lTotalScore)
    for i = 1, GameViewLayer.AddScoreBtnNum - 1 do
        local isShow =(CanAddMaxScore >= (self.nChip[i] +m_lTotalScore))
        self.btChip[i]:setVisible(isShow)
    end
        self.btChip[GameViewLayer.AddScoreBtnNum]:setVisible(true)
end

-- 显示隐藏按钮
function GameViewLayer:ShowWindow(nTag, bShow)
    for _, obj in pairs(self.m_tOperator) do
        if obj and obj:getTag() == nTag then
            obj:setVisible(bShow)
        end
    end
    self.m_tSliderLayer :setVisible(self.m_ChipBG:isVisible()) 
end

-- 显示聊天
function GameViewLayer:ShowUserChat(viewid, message)
    if message and #message > 0 then
        self._chatLayer:showGameChat(false)
        -- 取消上次
        if self.m_UserChat[viewid] then
            self.m_UserChat[viewid]:stopAllActions()
            self.m_UserChat[viewid]:removeFromParent()
            self.m_UserChat[viewid] = nil
        end

        -- 创建label
        local limWidth = 24 * 12
        local labCountLength = cc.Label:createWithTTF(message, "fonts/round_body.ttf", 24)
     --   if labCountLength:getContentSize().width > limWidth then
            self.m_UserChat[viewid] = cc.Label:createWithTTF(message, "fonts/round_body.ttf", 24, cc.size(limWidth, 0))
       -- else
        --    self.m_UserChat[viewid] = cc.Label:createWithTTF(message, "fonts/round_body.ttf", 24)
      --  end
        local text = self.m_UserChatView[viewid]:getChildByName("text")
        self.m_UserChat[viewid]:setColor(cc.c3b(239,222,157))
        self.m_UserChat[viewid]:setPosition(cc.p(text:getPosition()))
        self.m_UserChat[viewid]:setAnchorPoint(cc.p(text:getAnchorPoint()))
        self.m_UserChat[viewid]:addTo(self.m_UserChatView[viewid], 3)

        -- 改变气泡大小
        self.m_UserChatView[viewid]:setContentSize(self.m_UserChat[viewid]:getContentSize().width + 28, 83)
        :setVisible(true)
        -- 动作
        self.m_UserChat[viewid]:runAction(cc.Sequence:create(
        cc.DelayTime:create(3),
        cc.CallFunc:create( function()
            self.m_UserChatView[viewid]:setVisible(false)
            self.m_UserChat[viewid]:removeFromParent()
            self.m_UserChat[viewid] = nil
        end )
        ))
    end
end

-- 显示表情
function GameViewLayer:ShowUserExpression(wViewChairId, wItemIndex)
    if wItemIndex and wItemIndex >= 0 then
        self._chatLayer:showGameChat(false)
        -- 取消上次
        if self.m_UserExpression[wViewChairId] then
            self.m_UserExpression[wViewChairId]:stopAllActions()
            self.m_UserExpression[wViewChairId]:removeFromParent()
            self.m_UserExpression[wViewChairId] = nil
        end
        -- 创建表情
        local strName = string.format("e(%d).png", wItemIndex)
        local m_UserExpressionView = cc.Sprite:createWithSpriteFrameName(strName)
        self.m_UserExpression[wViewChairId] = m_UserExpressionView
        self.m_UserExpression[wViewChairId]:setAnchorPoint(cc.p(0.5, 0))
        self.m_UserExpression[wViewChairId]:move(50, 50)
        self.m_UserChatView[wViewChairId]:addChild(self.m_UserExpression[wViewChairId], 3)

        -- 改变气泡大小
        --self.m_UserChatView[wViewChairId]:setContentSize(90, 100)
        :setVisible(true)

        self.m_UserExpression[wViewChairId]:runAction(cc.Sequence:create(
        cc.DelayTime:create(3),
        cc.CallFunc:create( function(ref)
            self.m_UserChatView[wViewChairId]:setVisible(false)
            self.m_UserExpression[wViewChairId]:removeFromParent()
            self.m_UserExpression[wViewChairId] = nil
        end )))
    end
end

--录音开始
function GameViewLayer:onUserVoiceStart(viewid)
    -- 取消文字，表情
        self._chatLayer:showGameChat(false)
        -- 取消上次
        if self.m_UserExpression[viewid] then
            self.m_UserExpression[viewid]:stopAllActions()
            self.m_UserExpression[viewid]:removeFromParent()
            self.m_UserExpression[viewid] = nil
        end

    -- 语音动画
    local param = AnimationMgr.getAnimationParam()
    param.m_fDelay = 0.1
    param.m_strName = cmd.VOICE_ANIMATION_KEY
    local animate = AnimationMgr.getAnimate(param)
    self.m_actVoiceAni = cc.RepeatForever:create(animate)

    self.m_UserExpression[viewid] = display.newSprite( cmd.RES .. "game/blank.png")
    :move(posChat[viewid].x, posChat[viewid].y + 15)
    :setAnchorPoint(cc.p(0.5, 0.5))
    :addTo(self, 3)
    if viewId == 2 or viewId == 3 then
        self.m_UserExpression[viewid]:setRotation(180)
    end
    self.m_UserExpression[viewid]:runAction(self.m_actVoiceAni)

    -- 改变气泡大小
    --self.m_UserChatView[viewid]:setContentSize(90, 100)
    :setVisible(true)
end
--录音结束
function GameViewLayer:onUserVoiceEnded(viewId)
    if self.m_UserExpression[viewId] then
        self.m_UserExpression[viewId]:removeFromParent()
        self.m_UserExpression[viewId] = nil
        self.m_UserChatView[viewId]:setVisible(false)
    end
end
-- 更新加注倍数
function GameViewLayer:UpdataAddScoreMultiple(cellscore, AddScoreMultiple)
    if cellscore == 0 or cellscore == nil then
        cellscore = 1
    end
    if not AddScoreMultiple or not cellscore then
        for i = 1, GameViewLayer.AddScoreBtnNum - 1 do
            self.btChip[i]:getChildByTag(GameViewLayer.CHIPNUM):setString("0")
        end
        return
    end

    -- 设置倍数
    for i = 1, GameViewLayer.AddScoreBtnNum - 1 do
        self.nChip[i] = AddScoreMultiple[i] + cellscore
    end

    -- 设置下注倍数
    for i = 1, GameViewLayer.AddScoreBtnNum - 1 do
        self.btChip[i]:getChildByTag(GameViewLayer.CHIPNUM):setString(self.nChip[i])
    end
    self.btChip[GameViewLayer.AddScoreBtnNum]:getChildByTag(GameViewLayer.CHIPNUM):setString("全下")

    local Text_UserCurScore = self.m_tUserNode[cmd.MY_VIEWID]:getChildByName("Text_UserCurScore")
    --local maxScore = tonumber(Text_UserCurScore:getString())  --dan999
    local maxScore = self._scene:GetMaxScore()
    self.m_tSliderLayer:resetMin(self.nChip[1],maxScore)

end
function GameViewLayer:ShowMenu(isShow)
    if isShow == nil then
        isShow = false
    end
    self.m_bShowMenu = isShow
    
    if isShow == true then
        if self.m_nodeMenu:isVisible()== true then
            return
        end
        local action1 = cc.MoveBy:create(0,cc.p(0,20))
        local action2 = cc.Show:create()
        local action3 = cc.FadeIn:create(0.3)
        local action4 = cc.MoveBy:create(0.3,cc.p(0,-20))
        local action5 = cc.Sequence:create(action1,action2,cc.Spawn:create(action3,action4))
        self.m_nodeMenu:runAction(action5)
        self.m_btnMenu:setBrightStyle(ccui.BrightStyle.highlight)
    else
        if self.m_nodeMenu:isVisible() == false  then
            return
        end
        local action1 = cc.FadeOut:create(0.3)
        local action2 = cc.MoveBy:create(0.3,cc.p(0,20))
        local action3 = cc.MoveBy:create(0,cc.p(0,-20))
        local action4 = cc.Hide:create()
        local action5 = cc.Sequence:create(cc.Spawn:create(action1,action2),action3,action4)
       self.m_nodeMenu:runAction(action5)
       self.m_btnMenu:setBrightStyle(ccui.BrightStyle.normal)
    end
end

function GameViewLayer:doAction(num,fromPos,toPos,parent,callback)

	if num == nil or fromPos == nil or toPos == nil then
		return
    end
    self._scene._soundManager:playEffectCommon(1,1)

	local i = 1

	function delay()

		if i < num then
			local jetton = display.newSprite("#game/GameRes850/texasHoldem_jesson_tip.png")
			jetton:setPosition(fromPos) 
			
			if parent ~= nil then
				parent:addChild(jetton)
			else
				self.m_csbNode:addChild(jetton)
			end
			local action = cc.EaseOut:create(cc.MoveTo:create(0.3, toPos),2)
			local action2 = cc.FadeTo:create(0.3, 0)
			local action3 = cc.Sequence:create(cc.DelayTime:create(0.05),cc.CallFunc:create(function()  delay() end))

			jetton:runAction(cc.Sequence:create(action3,action,action2,cc.CallFunc:create(function() jetton:removeFromParent() end)))
		end

		i = i + 1
    end
    
	delay()

	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(
			function()
				if callback ~= nil then
					callback()
				end
			end
		),nil))
end


--发完牌之后的牌值显示动画:玩家
function GameViewLayer:showUserPuke(type,viewid)
    
   if type == TO_USERCARD then  --用户的牌

    local card1Pos = cc.p(self.m_tUserCardNode[viewid]:getChildByName("card_1"):getPosition())
    
    function onFinish()

        for i=1,2 do

            local spCard = self.m_tHandCard[viewid][i]

            local cbCardData = self.m_tHandCardDate[viewid][i]

            self:UpdateCardSpriteByValue(spCard, cbCardData)
        
            local returnPos = cc.p(self.m_tUserCardNode[viewid]:getChildByName("card_"..i):getPosition())
           
            if i > 1 then

                spCard:runAction(cc.Sequence:create(cc.EaseOut:create(cc.MoveTo:create(0.2,cc.p(returnPos.x+4,returnPos.y)),1),

                                                    cc.EaseOut:create(cc.MoveTo:create(0.1,returnPos),1),

                                                    cc.CallFunc:create(function()
                                                        -- body
                                                    end)
                                                ))
             
            end
        end
    end


    for i = 1, 2  do
       
        local action =cc.Sequence:create(cc.EaseOut:create(cc.MoveTo:create(0.2,cc.p(card1Pos.x,card1Pos.y)),1),

                                     cc.MoveTo:create(0.05,cc.p(card1Pos.x,card1Pos.y+10)),

                                     cc.EaseOut:create(cc.MoveTo:create(0.2,card1Pos),1),

                                     cc.DelayTime:create(0.1),

                                     cc.CallFunc:create(function ( ... )

                                         if i == 2 then

                                            onFinish()

                                         end

                                     end))
                                    
        self.m_tHandCard[viewid][i]:stopAllActions()
        self.m_tHandCard[viewid][i]:runAction(action)

    end

   end

end

--桌面的扑克显示动画
function GameViewLayer:showDeskPuke(index)

    local card1Pos = cc.p(self.m_tSendCard[1]:getPosition())

    local cardSp = self.m_tCenterCard[index]

    if cardSp == nil then
    end

    cardSp:stopAllActions()

    function onFinish()

        for i=1,3 do

            local cardSp = self.m_tCenterCard[i]

            local cardDate = self.m_tCenterCardData[i]

            local pos = cc.p(self.m_tSendCard[i]:getPosition())

            if i > 1 then
                
                cardSp:stopAllActions()

                -- 创建翻牌动画
                local OrbitCamera1 = cc.OrbitCamera:create(0.2, 1, 0, 0, -90, 0, 0)

                local OrbitCamera2 = cc.OrbitCamera:create(0.2, 1, 0, 90, -90, 0, 0)

                cardSp:runAction(cc.Sequence:create(cc.EaseOut:create(cc.MoveTo:create(0.2,cc.p(pos.x+4,pos.y)),1),

                                                    cc.EaseOut:create(cc.MoveTo:create(0.1,pos),1),

                                                    OrbitCamera1,

                                                    cc.CallFunc:create(function()
                                                        
                                                        self:UpdateCardSpriteByValue(cardSp,cardDate)

                                                    end),

                                                    OrbitCamera2

                                                    ))
            else

                 -- 创建翻牌动画
                 local OrbitCamera1 = cc.OrbitCamera:create(0.2, 1, 0, 0, -90, 0, 0)

                 local OrbitCamera2 = cc.OrbitCamera:create(0.2, 1, 0, 90, -90, 0, 0)

                cardSp:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),

                                                    OrbitCamera1,

                                                    cc.CallFunc:create(function()
                                                        
                                                        self:UpdateCardSpriteByValue(cardSp,cardDate)

                                                    end),

                                                    OrbitCamera2

                                                    ))
   
            end
        end
    end

    cardSp:setRotation(0)

    cardSp:setScale(0.01)

    local fScale = self.m_tSendCard[index]:getScale()

    cardSp:runAction(cc.Sequence:create(

        cc.Spawn:create(

            cc.EaseOut:create(cc.MoveTo:create(0.4,card1Pos),1),

            cc.ScaleTo:create(0.4,fScale),

            cc.RotateTo:create(0.4,0)
        ),
        cc.CallFunc:create(function ()

            if index == 3 then

                self:runAction(cc.Sequence:create(

                    cc.DelayTime:create(0.5),

                    cc.CallFunc:create(function ( )

                    onFinish()

                end)))
               
            end
        end)
    ))


end

function GameViewLayer:GameEnd(GameEndData)

    self.m_gameEndData = GameEndData

    if GameEndData == nil then

        return

    end

    --清理动画节点
    self.m_tSpineNode:removeAllChildren()

    
    for i = 1,((cmd).GAME_PLAYER) do 

        local userItem = self.m_gameEndData.userItem[i]

        if userItem ~= nil then

            self:ShowPukeGameEnd(i-1,self.m_gameEndData.tHandCard[i],self.m_gameEndData.tEndScore[i] > 0,self.m_gameEndData.tCardType[i])
        
        end
    
    end

   

    --显示大牌动画：显示所有玩家中的最大的牌型
    local maxCardType = 0 

    for k,v in ipairs(self.m_gameEndData.tCardType) do

        if maxCardType > v then

            maxCardType = v

        end

    end

    if maxCardType > 6 then

        -- local spine = self:playSpine(maxCardType)

        -- spine:setPosition(cc.p(yl.WIDTH/2,yl.HEIGHT/2))

        -- spine:setAnimation(0,"animation",false)

        -- spine:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.RemoveSelf:create()))

        self._scene._soundManager:playEffectCommon(maxCardType+3)

    end


    --显示开始按钮
    self:runAction(cc.Sequence:create(cc.DelayTime:create(5.0),cc.CallFunc:create(function (  )

        self._BtnReady:setVisible(true)

    end)))
    
end

--显示结算分数
function GameViewLayer:showSettlementScore(nChairID,score,cardType)

    local viewid = self:SwitchViewChairID(nChairID)

    local text_score = self.m_tUserNode[viewid]:getChildByName("text_score")

    text_score:setVisible(true)

    local colorWin = cc.c3b(252,216,134)

    local colorLose = cc.c3b(171,190,219)

    if score > 0 then
      
        text_score:setColor(colorWin)
        
        text_score:setString("+"..score)

    else

        text_score:setColor(colorLose)

        text_score:setString(""..score)

    end

    --加分动画
    local gameEndImgBg = self.m_tUserNode[viewid]:getChildByName("Image_end_bg")

    local spine = nil  

    local scoreMove = function ()
        
        local startPos = cc.p(text_score:getPosition())

        local endPos = cc.p(startPos.x,startPos.y+100)

        text_score:stopAllActions()

        text_score:runAction(cc.Sequence:create(cc.MoveTo:create(0.3,endPos),cc.DelayTime:create(3),cc.Hide:create(),cc.MoveTo:create(0,startPos)))

    end 

    if score > 0  then

        --加分的spine动画
        local addScoreSpine = function ()

            -- if cardType > 6 then

            --     spine=self:playSpine(GameViewLayer.SPINE_ADDSCORE_DAPAI)
    
            -- else
    
            --     spine = self:playSpine(GameViewLayer.SPINE_ADDSCORE_DAPAI) --SPINE_ADDSCORE
    
            -- end
    
    
            -- local pos = cc.p(self.m_tUserNode[viewid]:getPosition())
    
            -- spine:setPosition(cc.p(pos.x,pos.y+6))
    
            -- spine:setAnimation(0,"animation",false)

            -- spine:setScale(0.7)        
        end

         --播放筹码移动动画
         local callback = function ()
            scoreMove()
            addScoreSpine()
         end
         local fromPos= cc.p(self.TotalScore:getPosition())
         local toPos = cc.p(self.m_tUserNode[viewid]:getPosition())
         self:doAction(5,fromPos,toPos,self.m_csbNode,callback)
    else

        scoreMove()
    
    end


    

     --播放你赢了动画
    if viewid == cmd.MY_VIEWID then

        if score > 0 then

            -- local spine = self:playSpine(GameViewLayer.SPINE_YOUWIN)

            -- spine:setPosition(cc.p(yl.WIDTH/2,yl.HEIGHT/2+300))

            -- spine:setAnimation(0,"animation",false)

            -- spine:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.RemoveSelf:create()))

            self._scene._soundManager:playEffectCommon(7)

        else

            self._scene._soundManager:playEffectCommon(8)

        end

    end
    

end


--展示牌型
function GameViewLayer:ShowUserCardGroup(nChairID,cardType,isWin,overCardData,handCardData,callback)

    local viewid  = self:SwitchViewChairID(nChairID)

    --只有自己才做牌的亮暗处理
    if viewid ~= cmd.MY_VIEWID  then

        return

    end

    --牌的亮暗处理
    
    local colorLiang = cc.c3b(255,255,255)

    local colorAn = cc.c3b(74,74,74)

    local deskCard = self.m_tCenterCard

    local deskCardDate = self.m_tCenterCardData

    --先让所有的牌亮
    for j,obj in ipairs(deskCard) do

        if obj ~= nil then
            
            obj:setColor(colorLiang)

        end
        
    end

    --如果自己弃牌，不做安排处理
    if cardType ==0 then

        --return

    end



    local onFinsh = function ()

        local userCard = self.gameEndCardImg[viewid]

        for k,v in ipairs(userCard) do

          if v ~= nil then

            v:setColor(colorLiang)

         end

        end

        --玩家手牌要暗掉的牌
       for k,v in ipairs(handCardData) do

          local isAn = true

          for j,obj in ipairs(overCardData) do 

              if v == obj then

                  isAn = false

                  break

              end

          end

          if isAn == true then

              userCard[k]:setColor(colorAn)

          end

          if k == #handCardData then

            if callback ~= nil then

                callback()

            else
                --显示结算分数
                for i=1,((cmd).GAME_PLAYER) do
        
                    local userItem = self.m_gameEndData.userItem[i]
    
                    if userItem ~= nil then
    
                       self:showSettlementScore(i-1,self.m_gameEndData.tEndScore[i],self.m_gameEndData.tCardType[i])
    
                       self:addUserScore(i-1,self.m_gameEndData.tEndScore[i])
    
                    end
    
                end

            end

          end
    
       end
        
    end




    --桌面上要暗掉的牌
    for k,v in ipairs(deskCardDate) do

        local isAn = true

        for j,obj in ipairs(overCardData) do 

            if v == obj then
                
               isAn = false

                break

            end
            
        end

        if isAn == true then

            deskCard[k]:setColor(colorAn) 

        end

        if k == #deskCardDate then

            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function ()

                onFinsh()
                
            end)))

        

        end

    end

    
    
    
end

--播放骨骼动画
function GameViewLayer:playSpine(type,parent)

    if type == nil then

        return
        
    end

    local json =cmd.RES.."animation/spine/"

    local atlas =cmd.RES.."animation/spine/"

    if type == GameViewLayer.SPINE_SLIDER_ALLIN then

        json = json.."dzpk_allinfirebox/dzpk_allinfirebox.json"

        atlas = atlas.."dzpk_allinfirebox/dzpk_allinfirebox.atlas"

    elseif type == GameViewLayer.SPINE_USER_ALLIN  then
        
        json = json.."dzpk_quanyafire/dzpk_quanyafire.json"

        atlas = atlas.."dzpk_quanyafire/dzpk_quanyafire.atlas"

    elseif type == GameViewLayer.SPINE_DESK_ALLIN then

        json = json.."dzpk_biankuangeffect/yszbiankuangfireeffect.json"

        atlas = atlas.."dzpk_biankuangeffect/yszbiankuangfireeffect.atlas"

    elseif type == GameViewLayer.SPINE_SLIDER then

        json = json.."dzpk_allinjt/dzpk_allinjt.json"

        atlas = atlas.."dzpk_allinjt/dzpk_allinjt.atlas"

    elseif type == GameViewLayer.SPINE_ADDSCORE_DAPAI then

        json = json.."dzpk_dapaijiafenlizi/dzpk_dapaijiafenlizi.json"

        atlas = atlas.."dzpk_dapaijiafenlizi/dzpk_dapaijiafenlizi.atlas"

    elseif type == GameViewLayer.SPINE_USERKUANG_DAPAI then

        json = json.."dzpk_dpxuserkuang/dzpk_dpxuserkuang.json"

        atlas = atlas.."dzpk_dpxuserkuang/dzpk_dpxuserkuang.atlas"

    elseif type == GameViewLayer.SPINE_HJ_TONGHUASHUN then

        json = json.."dzpk_hjtonghuashun/dzpk_hjtonghuashun.json"

        atlas = atlas.."dzpk_hjtonghuashun/dzpk_hjtonghuashun.atlas"

    elseif type == GameViewLayer.SPINE_HULU then

        json = json.."dzpk_hulu/dzpk_hulu.json"

        atlas = atlas.."dzpk_hulu/dzpk_hulu.atlas"

    elseif type == GameViewLayer.SPINE_ADDSCORE then

        json = json.."dzpk_jiafenlizi/dzpk_jiafenlizi.json"

        atlas = atlas.."dzpk_jiafenlizi/dzpk_jiafenlizi.atlas"

    elseif type == GameViewLayer.SPINE_JINGANG then

        json = json.."dzpk_jingang/dzpk_jingang.json"

        atlas = atlas.."dzpk_jingang/dzpk_jingang.atlas"

    elseif type == GameViewLayer.SPINE_NPC then

        json = json.."dzpk_npc/dzpk_npc.json"

        atlas = atlas.."dzpk_npc/dzpk_npc.atlas"

    elseif type == GameViewLayer.SPINE_HEGUAN then
 
        json = json.."dzpk_nvheguan/dzpk_nvheguan.json"

        atlas = atlas.."dzpk_nvheguan/dzpk_nvheguan.atlas"

    elseif type == GameViewLayer.SPINE_YOUWIN then

        json = json.."dzpk_youwin/dzpk_youwin.json"

        atlas = atlas.."dzpk_youwin/dzpk_youwin.atlas"

    elseif type == GameViewLayer.SPINE_TONGHUASHUN then

        json = json.."dzpk_tonghuashun/dzpk_tonghuashun.json"

        atlas = atlas.."dzpk_tonghuashun/dzpk_tonghuashun.atlas"



    end

    local spine = sp.SkeletonAnimation:create(json,atlas)

    spine:setAnimation(0,"animation",false)

    spine:setTag(type)

    if parent == nil then

        spine:addTo(self.m_csbNode)

    else

        spine:addTo(parent)

    end

    

    if type == GameViewLayer.SPINE_DESK_ALLIN then

        spine:setRotation(90)

    end

    return spine

end

--结算时显示扑克
function GameViewLayer:ShowPukeGameEnd(nChairID,cardData,isWin,cardType)

    if not nChairID or nChairID == yl.INVALID_CHAIR then
        return
    end

    local viewid = self:SwitchViewChairID(nChairID)

    if viewid == nil then

        return

    end

    local gemeEndImgBg = self.m_tUserNode[viewid]:getChildByName("Image_end_bg")
    
    --设置牌型
    local imgStatus = gemeEndImgBg:getChildByName("Image_cardtype_win")
    gemeEndImgBg:getChildByName("Image_cardtype_lose"):setVisible(false)
    gemeEndImgBg:getChildByName("Image_cardtype_win"):setVisible(false)
    local _cardtype = cardType == 0 and 1 or cardType
    -- card Type == 11 ？？？？  card Type == 21 ？？？
    if isWin == true then
        imgStatus:loadTexture("game/GameRes850/texasHoldem_txt_win_".._cardtype..".png",UI_TEX_TYPE_PLIST)
        imgStatus:setVisible(true)
    else
        imgStatus = gemeEndImgBg:getChildByName("Image_cardtype_lose")
        imgStatus:loadTexture("game/GameRes850/texasHoldem_txt_lose_".._cardtype..".png",UI_TEX_TYPE_PLIST)
        imgStatus:setVisible(true)
    end

    --设置背景
    if isWin == true then
        gemeEndImgBg:setVisible(true)

        if cardType> 6  then  --大牌用另外一个框  

            gemeEndImgBg:loadTexture("game/GameRes850/texasHoldem_show_win_big.png",UI_TEX_TYPE_PLIST)

            --播放大牌特效

            -- local spine  = self:playSpine(GameViewLayer.SPINE_USERKUANG_DAPAI)

            -- local pos =cc.p (self.m_tUserNode[viewid]:getPosition())

            -- spine:setPosition(pos)

            -- spine:setScale(0.73)

            -- spine:setAnimation(0,"animation",false)
            

        else

            gemeEndImgBg:loadTexture("game/GameRes850/texasHoldem_show_win.png",UI_TEX_TYPE_PLIST)

        end

    elseif isWin == false then

        gemeEndImgBg:setVisible(true)

        gemeEndImgBg:loadTexture("game/GameRes850/texasHoldem_show_lose.png",UI_TEX_TYPE_PLIST)

    end



    self.m_tUserNode[viewid]:getChildByName("Image_end_bg"):setVisible(true)

    local card1Pos = cc.p( self.gameEndCardImg[viewid][1]:getPosition())

    local onFinish = function ( )

        for i=1,2 do
            
            local spCard = self.gameEndCardImg[viewid][i]

            local spCardPos = self.gameEndCardImgPos[viewid][i]

            self:UpdateCardSpriteByValue(spCard,cardData[i])

            if i > 1 then
                
                spCard:stopAllActions()

                spCard:runAction(cc.Sequence:create(cc.EaseOut:create(cc.MoveTo:create(0.2,cc.p(spCardPos.x+4,spCardPos.y)),1),

                cc.EaseOut:create(cc.MoveTo:create(0.1,spCardPos),1),

                cc.CallFunc:create(function()

                    if i == 2 then

                        for i = 1,((cmd).GAME_PLAYER) do 

                            local userItem = self.m_gameEndData.userItem[i]
                    
                            if userItem ~= nil then
                    
                               self:ShowUserCardGroup(i-1,self.m_gameEndData.tCardType[i],self.m_gameEndData.tEndScore[i] > 0,self.m_gameEndData.tHandCardOver[i],self.m_gameEndData.tHandCard[i])

                            end
                        end                  
                    end

                end)
            ))

            end

        end
    end

    for i = 1, 2  do
       
        local action =cc.Sequence:create(cc.EaseOut:create(cc.MoveTo:create(0.2,cc.p(card1Pos.x,card1Pos.y)),1),

                                     cc.MoveTo:create(0.05,cc.p(card1Pos.x,card1Pos.y+10)),

                                     cc.EaseOut:create(cc.MoveTo:create(0.2,card1Pos),1),

                                     cc.DelayTime:create(0.1),

                                     cc.CallFunc:create(function ( ... )

                                         if i == 2 then

                                            onFinish()

                                         end

                                     end))
                                    
        self.gameEndCardImg[viewid][i]:stopAllActions()

        self.gameEndCardImg[viewid][i]:runAction(action)

    end



end

function GameViewLayer:showUserAllin(viewid)

    if viewid == nil then

        return

    end

    -- --玩家框上的allin动画
    -- local spine = self:playSpine(GameViewLayer.SPINE_USER_ALLIN)

    -- local pos = cc.p(self.m_tUserNode[viewid]:getPosition())
    
    -- spine:setPosition(cc.p(pos.x+1.5,pos.y+4))

    -- spine:setScale(0.8)

    -- spine:setAnimation(0,"animation",true)

    -- --桌面框的allin动画
    -- local spineDeskAllin = self:playSpine(GameViewLayer.SPINE_DESK_ALLIN)

    -- spineDeskAllin:setAnimation(0,"animation",true)

    -- spineDeskAllin:setPosition(cc.p(yl.WIDTH/2,yl.HEIGHT/2))

    -- spineDeskAllin:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.RemoveSelf:create()))

    
end


function GameViewLayer:addUserScore(nChairID,score)

    local nViewID = self:SwitchViewChairID(nChairID)
    -- 筹码
    local Text_UserCurScore = self.m_tUserNode[nViewID]:getChildByName("Text_UserCurScore")


    local  curSocre = self.m_CurUserMaxScore + score

    Text_UserCurScore:setString(tostring(curSocre))

end

--显示菜单的二级界面
function GameViewLayer:showMenuSecondLayer(tag,isShow)

   local layer = nil

    if tag == BT_BANK then

        layer = BankLayer:create(self._scene)

        layer:addTo(self.m_csbNode,10)

        self._scene._bankLayer = layer

    elseif tag == BT_SET then

        layer = SettingLayer:create(self._scene)

        layer:addTo(self.m_csbNode,10)

        self._scene._settingLayer = layer

    elseif tag == BT_RULE then

        layer = RuleLayer:create(self._scene)

        layer :addTo(self.m_csbNode)
  
    end
end

--跟新玩家金币
function GameViewLayer:updateAsset(viewid,score)
    -- 筹码
    local Text_UserCurScore = self.m_tUserNode[viewid]:getChildByName("Text_UserCurScore")

    
    local curSocre = tonumber(Text_UserCurScore:getString())

    curSocre = curSocre + score

    Text_UserCurScore:setString(tostring(curSocre))
end

--银行操作成功
function GameViewLayer:onBankSuccess( )
	if self._scene._bankLayer and not tolua.isnull(self._scene._bankLayer) then
		self._scene._bankLayer:onBankSuccess()
	end
end

--银行操作失败
function GameViewLayer:onBankFailure( )
	if self._scene._bankLayer and not tolua.isnull(self._scene._bankLayer) then
		self._scene._bankLayer:onBankFailure()
	end
end
function GameViewLayer:onGetBankInfo(bankinfo)
	if self._scene._bankLayer and not tolua.isnull(self._scene._bankLayer) then
		self._scene._bankLayer:onGetBankInfo(bankinfo)
	end
end

return GameViewLayer