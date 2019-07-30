--
-- Author: zhouweixiang
-- Date: 2016-11-28 14:17:03
--
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local ClipText = appdf.req(appdf.EXTERNAL_SRC .. "ClipText")
local PopupInfoHead = appdf.req(appdf.EXTERNAL_SRC .. "PopupInfoHead")
local HeadSprite = appdf.req(appdf.EXTERNAL_SRC.."HeadSprite")

local Game_CMD = appdf.req(appdf.GAME_SRC.."yule.oxbattle2.src.models.CMD_Game")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.oxbattle2.src.models.GameLogic")

local CardSprite = appdf.req(appdf.GAME_SRC.."yule.oxbattle2.src.views.layer.CardSprite")
local SitRoleNode = appdf.req(appdf.GAME_SRC.."yule.oxbattle2.src.views.layer.SitRoleNode") 
local GameRuleLayer = appdf.req(appdf.GAME_SRC.."yule.oxbattle2.src.views.layer.GameRuleLayer")

--弹出层
local SettingLayer = appdf.req(appdf.GAME_SRC.."yule.oxbattle2.src.views.layer.SettingLayer")
local UserListLayer = appdf.req(appdf.GAME_SRC.."yule.oxbattle2.src.views.layer.UserListLayer")
local ApplyListLayer = appdf.req(appdf.GAME_SRC.."yule.oxbattle2.src.views.layer.ApplyListLayer")
local GameRecordLayer = appdf.req(appdf.GAME_SRC.."yule.oxbattle2.src.views.layer.GameRecordLayer")
local GameResultLayer = appdf.req(appdf.GAME_SRC.."yule.oxbattle2.src.views.layer.GameResultLayer")
local OpenPukeEffect = appdf.req(appdf.GAME_SRC.."yule.oxbattle2.src.views.layer.OpenPukeEffect")
local HeadBackground = appdf.req(appdf.GAME_SRC.."yule.oxbattle2.src.views.layer.HeadBackground")
local ChatLayer = appdf.req(appdf.GAME_SRC.."yule.oxbattle2.src.views.layer.ChatLayer")
local GameFrameEngine = appdf.req(appdf.CLIENT_SRC.."plaza.models.GameFrameEngine")
local GameViewLayer = class("GameViewLayer",function(scene)
        local gameViewLayer = display.newLayer()
    return gameViewLayer
end)

local TAG_START             = 100
-- 游戏背景音乐
local bgMusic = {}
bgMusic[1]="ingameBGMMono1.mp3"
bgMusic[2]="ingameBGMMono2.mp3"

local enumTable = 
{
    "HEAD_BANKER",  --庄家头像
    "TAG_NIU_TXT",  --牛点数
    "TAG_CARD",     --牌
    "BT_MENU",		--菜单按钮
    "BT_LUDAN",     --路单
    "BT_BANK",		--银行
    "BT_CLOSEBANK", --关闭银行
    "BT_TAKESCORE",	--银行取款
    "BT_SET",       --设置
    "BT_HELP",      --帮助
    "BT_QUIT",      --退出
    "BT_SUPPERROB", --超级抢庄
    "BT_APPLY",     --申请上庄
    "BT_USERLIST",  --用户列表
    "BT_USERNUM",   --玩家在线人数
    "BT_JETTONAREA_0",  --下注区域
    "BT_JETTONAREA_1",
    "BT_JETTONAREA_2",
    "BT_JETTONAREA_3",
    "BT_JETTONSCORE_0", --下注按钮
    "BT_JETTONSCORE_1",
    "BT_JETTONSCORE_2",
    "BT_JETTONSCORE_3",
    "BT_JETTONSCORE_4",
    "BT_JETTONSCORE_5",
    "BT_JETTONSCORE_6",
    "BT_JETTONSCORE_7",
    "BT_SEAT_0",       --坐下  
    "BT_SEAT_1",
    "BT_SEAT_2",
    "BT_SEAT_3",
    "BT_SEAT_4",  
    "BT_SEAT_5",
    "BT_BANK_BUTTON",  --头像旁边的银行按钮
    "BT_LAYOUT_BG",
}
local TAG_ENUM = ExternalFun.declarEnumWithTable(TAG_START, enumTable)

enumTable = {
    "ZORDER_JETTON_GOLD_Layer", --下注时金币层级
    "ZORDER_CARD_Layer", --牌层
    "ZORDER_GOLD_Layer", --金币层
    "ZORDER_Other_Layer", --用户列表层等
    "ZORDER_Tips_Layer", --提示层
    "ZORDER_NIGHT_Layer", --夜间层
}
local ZORDER_LAYER = ExternalFun.declarEnumWithTable(2, enumTable)

local enumApply =
{
    "kCancelState",
    "kApplyState",
    "kApplyedState",
    "kSupperApplyed"
}

GameViewLayer._apply_state = ExternalFun.declarEnumWithTable(0, enumApply)
local APPLY_STATE = GameViewLayer._apply_state


local MaxTimes = 10   ---最大赔率

--下注数值
GameViewLayer.m_BTJettonScore = {100, 1000, 10000, 100000, 1000000, 5000000, 10000000}

--下注值对应金币个数
GameViewLayer.m_JettonGoldBaseNum = {1, 1, 1, 1, 1, 1, 1}--{1, 1, 2, 2, 3, 3, 4}
--获得基本金币个数
GameViewLayer.m_WinGoldBaseNum = {2, 2, 4, 4, 6, 6, 6}
--获得最多金币个数
GameViewLayer.m_WinGoldMaxNum = {6, 6, 8, 8, 12, 12, 12}
--下注时记录的金币
GameViewLayer.continued_detention = {{},{},{},{}}
--上一局押注的金币
GameViewLayer.bets_on_the_board = {{},{},{},{}}

--发牌位置
local cardpoint = {cc.p(620, 662), cc.p(196, 245), cc.p(196+246, 245), cc.p(196+246*2, 245), cc.p(196+246*3,245)}
--自己头像位置
local selfheadpoint = cc.p(63, 57)
--庄家头像位置
local bankerheadpoint = cc.p(345, 670) 
--玩家列表按钮位置
local userlistpoint = cc.p(43.88, 182.10)
--四个玩家头像的位置
local userheadpoint = {cc.p(80,490), cc.p(80,360), cc.p(1254,490), cc.p(1254,360)}


function GameViewLayer:ctor(scene)
    --关闭触控
    self:setTouchEnabled(true)
    self:registerScriptTouchHandler(function (event,x,y)
        return true
    end)
	--注册node事件
    ExternalFun.registerNodeEvent(self)	

	self._scene = scene

    --初始化
    self:paramInit()

	--加载资源
	self:loadResource()

    ExternalFun.playBackgroudAudio(self:getBgMusic())
end

-- 获取游戏背景音乐名字
function GameViewLayer:getBgMusic(index)
	local i = index
	if index==nil then
		i=math.random(1,2)
	elseif bgMusic[index]==nil then
		i=1
	end
	return bgMusic[i]
end

function GameViewLayer:paramInit()
    --当前场次
    self.m_currentfield = self:getRoomLevelStr()

    --用户列表
    self:getDataMgr():initUserList(self:getParentNode():getUserList())

    --是否显示菜单层
    self.m_bshowMenu = false

    --菜单栏
    self.m_menulayout = nil

    --庄家背景框
    self.m_bankerbg = nil
    --庄家名称
    self.m_bankerName = nil

    --自己背景框
    self.m_selfbg = nil

    --下注筹码
    self.m_JettonBtn = {}

    --下注按钮背后光
    self.m_JettonLight = nil

    --选中筹码
    self.m_nJettonSelect = 2

    --自己区域下注分
    self.m_lUserJettonScore = {}
    --自己下注总分
    self.m_lUserAllJetton = 0
    --所有玩家下注总分
    self.m_tAllScore = 0

    --玩家区域总下注分
    self.m_lAllJettonScore = {}
    --下注区域
    self.m_JettonArea = {}

    --自己下注分数背景
    self.m_selfJettonBG = {}
    --总下注分数文字
    self.m_tAllJettonScore = {}

    --牌显示层
    self.m_cardLayer = nil

    --金币显示层
    self.m_goldLayer = nil

    --金币列表 self.m_goldList[1]用来记录庄家从四个下注区域一共赢了多少金币数量，后4个用来记录对应区域的金币数量
    self.m_goldList = {{}, {}, {}, {}, {}}

    --玩家列表层
    self.m_userListLayer = nil

    --上庄列表层
    self.m_applyListLayer = nil

    --游戏银行层
    self.m_bankLayer = nil

    --路单层
    self.m_GameRecordLayer = nil

    --游戏结算层
    self.m_gameResultLayer = nil

    --倒计时Layout
    self.m_timeLayout = nil

    --当前庄家
    self.m_wBankerUser = yl.INVALID_CHAIR
    --当前庄家分数
    self.m_lBankerScore = 0

    --系统能否做庄
    self.m_bEnableSysBanker = false

    --游戏状态
    self.m_cbGameStatus = Game_CMD.GAME_SCENE_FREE
    --剩余时间
    self.m_cbTimeLeave = 0

    --显示分数
    self.m_showScore = self.m_currentfield == "体验场" and self._scene:GetMeUserItem().lScore or GlobalUserItem.lUserScore

    --最大下注
    self.m_lUserMaxScore = 0

    --申请条件
    self.m_lApplyBankerCondition = 0

    --区域限制
    self.m_lAreaLimitScore = 0

    --桌面扑克数据
    self.m_cbTableCardArray = {}
    --桌面扑克
    self.m_CardArray = {}
    --桌面牛点数显示
    self.m_niuPointLayout = {}
    --赢了闪光效果
    self.m_winEffect = {}
    --输了的透明层
    self.m_failedEffect = {}

    --区域输赢
    self.m_bUserOxCard = {}
    --区域输赢倍数
    self.m_Multiple = {}
    --牛数值
    self.m_niuPoint = {}

    --是否练习房，练习房不能使用银行
    self.m_bGenreEducate = false

    --自己占位
    self.m_nSelfSitIdx = nil

    --用户坐下配置
    self.m_tabSitDownConfig = {}
    self.m_tabSitDownUser = {}
    --自己坐下
    self.m_nSelfSitIdx = nil

    --座位
    self.m_TableSeat = {}

    --游戏结算数据
    --坐下玩家赢分
    self.m_lOccupySeatUserWinScore = nil

    --本局赢分
    self.m_lSelfWinScore = 0

    --庄家赢分
    self.m_lBankerWinScore = 0
    --庄家昵称
    self.m_tBankerName = ""

    --超级抢庄按钮
    self.m_btSupperRob = nil
    --申请状态
    self.m_enApplyState = APPLY_STATE.kCancelState
    --超级抢庄申请
    self.m_bSupperRobApplyed = false
    --超级抢庄配置
    self.m_tabSupperRobConfig = {}
    --金币抢庄提示
    self.m_bRobAlert = false
    --当前抢庄用户
    self.m_wCurrentRobApply = yl.INVALID_CHAIR

    --是否播放金币飞入音效``
    self.m_bPlayGoldFlyIn = true
    --下注倒计时
    self.m_fJettonTime = 0.1
    --四个玩家头像
    self.playheadbackground = {}
end

function GameViewLayer:loadResource()
    --加载卡牌纹理
    cc.SpriteFrameCache:getInstance():addSpriteFrames("game/yule/oxbattle2/res/frames/brnn_openCard_plist.plist", "game/yule/oxbattle2/res/frames/brnn_openCard_plist.png")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("game/yule/oxbattle2/res/frames/plist_puke.plist", "game/yule/oxbattle2/res/frames/plist_puke.png")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("game/yule/oxbattle2/res/im_card.plist", "game/yule/oxbattle2/res/im_card.png")

    local rootLayer, csbNode = ExternalFun.loadRootCSB("game/yule/oxbattle2/res/GameScene.csb", self)
	self.m_rootLayer = rootLayer
    self.m_scbNode = csbNode

    --剩余下注数
    self.remainder_note = cc.LabelTTF:create("剩余下注数：0", "Arial", 20) 
    self.remainder_note:setColor(cc.c3b(255, 255, 255))
    self:addToRootLayer(self.remainder_note, 1)
    self.remainder_note:setPosition(542, 568)
    :setColor(cc.c3b(0x46, 0xA2, 0x46))

	local function btnEvent( sender, eventType )
        if sender:getTag() == TAG_ENUM.BT_JETTONSCORE_7 then 
            if eventType == ccui.TouchEventType.began then
                sender:setScale(1.05) 
            end
            if eventType == ccui.TouchEventType.canceled then
                sender:setScale(1.00) 
            end
        end
        if eventType == ccui.TouchEventType.ended then
            self:onButtonClickedEvent(sender:getTag(), sender)
        end
    end
    --菜单按钮
    local  btn = csbNode:getChildByName("bt_menu")
    btn:setTag(TAG_ENUM.BT_MENU)
    btn:addTouchEventListener(btnEvent)

    --菜单栏
    self.m_menulayout = csbNode:getChildByName("layout_menu")
    self.m_menulayout:retain()
    self.m_menulayout:removeFromParent()
    self:addToRootLayer(self.m_menulayout, ZORDER_LAYER.ZORDER_Other_Layer)
    self.m_menulayout:release()
    self.m_menulayout:setScale(1.0, 0.01)
    self.m_menulayout:setVisible(false) 
    --场次
    btn = csbNode:getChildByName("Field") 
    btn:setString(self.m_currentfield.."\n 1号场")

    --路单
    btn = csbNode:getChildByName("bt_ludan")
    btn:setTag(TAG_ENUM.BT_LUDAN)
    btn:addTouchEventListener(btnEvent)

    --银行
    btn = self.m_menulayout:getChildByName("bt_bank")
    btn:setTag(TAG_ENUM.BT_BANK)
    btn:addTouchEventListener(btnEvent)

    --设置
    btn = self.m_menulayout:getChildByName("bt_set")
    btn:setTag(TAG_ENUM.BT_SET)
    btn:addTouchEventListener(btnEvent)

    --帮助
    btn = self.m_menulayout:getChildByName("bt_help")
    btn:setTag(TAG_ENUM.BT_HELP)
    btn:addTouchEventListener(btnEvent)
    

    --退出
    btn = self.m_menulayout:getChildByName("bt_quit")
    btn:setTag(TAG_ENUM.BT_QUIT)
    btn:addTouchEventListener(btnEvent)

    --超级抢庄
    self.m_btSupperRob = csbNode:getChildByName("bt_supperrob")
    self.m_btSupperRob:setTag(TAG_ENUM.BT_SUPPERROB)
    self.m_btSupperRob:addTouchEventListener(btnEvent)
    self.m_btSupperRob:setEnabled(false)

    --申请上庄
    btn = csbNode:getChildByName("bt_apply")
    btn:setTag(TAG_ENUM.BT_APPLY)
    btn:addTouchEventListener(btnEvent)

    --玩家列表
    btn = csbNode:getChildByName("bt_userlist")
    btn:setVisible(false)
    btn:setTag(TAG_ENUM.BT_USERLIST)
    btn:addTouchEventListener(btnEvent)

    --玩家人数
    btn = btn:getChildByName("renshu")
    btn:setTag(TAG_ENUM.BT_USERNUM)
    self.peoplenum = btn
    --self.peoplenum:setVisible(false)
    self.peoplenum:setString(#self:getDataMgr():getUserList())

    --聊天按钮
    btn = csbNode:getChildByName("btn_chat")
    btn:addClickEventListener(function() self.chatMsg:show() end)
    self.chatMsg = ChatLayer:create(self,self._scene)
    self.chatMsg:removeFromParent()
    self.chatMsg:hide()
    self:addToRootLayer(self.chatMsg,100)

    --夜间背景层
    self.layout_bg = csbNode:getChildByName("layout_bg")
    self.layout_bg:setTag(TAG_ENUM.BT_LAYOUT_BG)
    self.layout_bg:removeFromParent()
    self:addToRootLayer(self.layout_bg, ZORDER_LAYER.ZORDER_NIGHT_Layer)
    self.layout_bg:setPosition(0,0)
    self.layout_bg:setVisible(false)
    self.layout_bg:setTouchEnabled(false)
    local day = GlobalUserItem.bDayAble
    if day then 
        self.layout_bg:setVisible(false)
    else
        self.layout_bg:setVisible(true)
    end   
    
    --夜间提示背景
    self.nightPrompt_bg = csbNode:getChildByName("night_bg")
    self.nightPrompt_bg:removeFromParent()
    self:addToRootLayer(self.nightPrompt_bg, ZORDER_LAYER.ZORDER_Other_Layer + 1)
    self.nightPrompt_bg:setOpacity(0)

    --开始下注提示背景
    self.kaishixiazhu = csbNode:getChildByName("kaishixiazhu")
    self.kaishixiazhu:removeFromParent()
    self:addToRootLayer(self.kaishixiazhu, ZORDER_LAYER.ZORDER_Tips_Layer)
    self.kaishixiazhu:setOpacity(0)

    --结束下注提示背景
    self.tingzhixiazhu = csbNode:getChildByName("tingzhixiazhu")
    self.tingzhixiazhu:removeFromParent()
    self:addToRootLayer(self.tingzhixiazhu, ZORDER_LAYER.ZORDER_Tips_Layer)
    self.tingzhixiazhu:setOpacity(0)

    --倒计时
    self.m_timeLayout = csbNode:getChildByName("layout_time")
    self.m_timeLayout:setVisible(false)

    --庄家背景框
    self.m_bankerbg = csbNode:getChildByName("im_banker_bg")

    --自己背景框
    self.m_selfbg = csbNode:getChildByName("im_self_bg")
    self.m_selfbg:setCascadeOpacityEnabled(false)
    self.m_selfbg:setOpacity(0)

    --下注筹码
    for i=1,7 do
        local str = string.format("bt_jetton_%d", i-1)
        btn = csbNode:getChildByName(str)
        btn:setTag(TAG_ENUM.BT_JETTONSCORE_0+i-1)
        btn:addTouchEventListener(btnEvent)
        self.m_JettonBtn[i] = btn
    end
    --续押按钮
    btn = csbNode:getChildByName("bt_jetton_7")
    btn:setTag(TAG_ENUM.BT_JETTONSCORE_7)
    btn:addTouchEventListener(btnEvent)
    self.xy_btn = btn
    self.xy_btn:setEnabled(false)
    --下注按钮背后光
    self.m_JettonLight = csbNode:getChildByName("im_jetton_effect")
    self.m_JettonLight:runAction(cc.RepeatForever:create(cc.Blink:create(1.0,1)))

    --下注区域
    for i=1,4 do
        local str = string.format("bt_area_%d", i-1)
        btn = csbNode:getChildByName(str)
        btn:setTag(TAG_ENUM.BT_JETTONAREA_0+i-1)
        btn:addTouchEventListener(btnEvent)
        self.m_JettonArea[i] = btn

        btn = btn:getChildByName("txt_score")
        self.m_tAllJettonScore[i] = btn
        btn:setVisible(false)
    end

    --总下注
    btn = csbNode:getChildByName("zongxiazhu")
    self.m_tAllScoreTxt = btn:getChildByName("xiazhushu")
    self.m_tAllScoreTxt:setString("0")


    --座位
    for i=1,6 do
        local str = string.format("bt_seat_%d", i)
        btn = csbNode:getChildByName(str)
        btn:setTag(TAG_ENUM.BT_SEAT_0+i-1)
        btn:addTouchEventListener(btnEvent)
        self.m_TableSeat[i] = btn
    end

    --自己下注分数
    for i=1,4 do
        local str = string.format("im_jetton_score_bg_%d", i-1)
        btn = csbNode:getChildByName(str)
        btn:setCascadeOpacityEnabled(false)
        btn:setOpacity(0)
        self.m_selfJettonBG[i] = btn
        btn:setVisible(false)
    end

    self:initBankerInfo()
    self:initSelfInfo()
    self:placePlayerHead()

    --牌类层
    self.m_cardLayer = cc.Layer:create()
    self:addToRootLayer(self.m_cardLayer, ZORDER_LAYER.ZORDER_CARD_Layer)
    for i=1,5 do
        --赢的效果
        if i >= 2 then
            self.m_winEffect[i] = ccui.ImageView:create("im_effect_1.png", UI_TEX_TYPE_PLIST)
            self.m_winEffect[i]:setPosition(cardpoint[i].x+105, cardpoint[i].y)
            self.m_winEffect[i]:setVisible(false)
            self.m_cardLayer:addChild(self.m_winEffect[i])
        end
        local temp = {}
        for j=1,5 do
            temp[j] = CardSprite:createCard(0)
            temp[j]:setVisible(false)
            temp[j]:setAnchorPoint(0, 0.5)
            temp[j]:setTag(TAG_ENUM.TAG_CARD)
            self.m_cardLayer:addChild(temp[j])
            if j == 5 then 
                temp[j]:showCardBack(true)
            else
                temp[j]:showCardBack(false)
            end
        end
        self.m_CardArray[i] = temp
        --输的效果
        if i >= 2 then
            self.m_failedEffect[i] = ccui.ImageView:create("im_effect_0.png", UI_TEX_TYPE_PLIST)
            self.m_failedEffect[i]:setPosition(cardpoint[i].x+105, cardpoint[i].y)
            self.m_failedEffect[i]:setVisible(false)
            self.m_cardLayer:addChild(self.m_failedEffect[i])
        end

        self.m_niuPointLayout[i] = ccui.ImageView:create("im_point_failed_bg.png", UI_TEX_TYPE_PLIST)
        self.m_niuPointLayout[i]:setTag(TAG_ENUM.TAG_NIU_TXT)
        self.m_niuPointLayout[i]:setPosition(cardpoint[i].x+105, cardpoint[i].y-10)
        self.m_niuPointLayout[i]:setVisible(false)
        self.m_cardLayer:addChild(self.m_niuPointLayout[i])

        
    end

    --金币层
    self.m_goldLayer = cc.Layer:create()
    self:addToRootLayer(self.m_goldLayer, ZORDER_LAYER.ZORDER_JETTON_GOLD_Layer)
end

--获取房间等级名称
function GameViewLayer:getRoomLevelStr()
    local levelStr = '体验场'

    self._gameFrame = GameFrameEngine:getInstance()
    local tmplevel = self._gameFrame._roomInfo
    if tmplevel and tmplevel.wServerLevel then
        if tmplevel.wServerLevel == 0 then
            levelStr = '体验场'
        elseif tmplevel.wServerLevel == 1 then
            levelStr = '初级场'
        elseif tmplevel.wServerLevel == 2 then
            levelStr = '普通场'
        elseif tmplevel.wServerLevel == 3 then
            levelStr = '中级场'
        elseif tmplevel.wServerLevel == 4 then
            levelStr = '高级场'
        end
    end

    return levelStr
end

--初始化庄家信息
function GameViewLayer:initBankerInfo()
    local temp = self.m_bankerbg:getChildByName("txt_name")
    local pbankername = ClipText:createClipText(cc.size(160, 26), "无人坐庄");
    pbankername:setAnchorPoint(temp:getAnchorPoint())
    pbankername:setName(temp:getName())
    pbankername:setPosition(temp:getPosition())
    temp:removeFromParent()
    self.m_bankerbg:addChild(pbankername)
    self.m_bankerName = pbankername

    temp = self.m_bankerbg:getChildByName("txt_score")
    temp:setString("0")

    --temp = PopupInfoHead:createClipHead
end

--刷新庄家信息
function GameViewLayer:resetBankerInfo()
    self.m_bankerbg:removeChildByTag(TAG_ENUM.HEAD_BANKER, true)
    local temp = self.m_bankerbg:getChildByName("txt_score")
    if self.m_wBankerUser == yl.INVALID_CHAIR then
        self.m_bankerbg:removeChildByName("bankheadbackground")
        local bankheadbackground = HeadBackground:create()
        :setPosition(0, 39)
        :setName("bankheadbackground")
        :addTo(self.m_bankerbg)
        local phead = PopupInfoHead:createNormal(nil, 71)
        phead:setPosition(0, 0)
        phead:setTag(TAG_ENUM.HEAD_BANKER)
        phead:addTo(bankheadbackground)
    
        if self.m_bEnableSysBanker == false then
            self.m_bankerName:setString("无人坐庄")
            temp:setString("0")
        else
            self.m_bankerName:setString("系统坐庄")
            local bankerstr = string.formatNumberThousands(self.m_lBankerScore,true,"/")
            temp:setString(bankerstr)
        end
    else
        local userItem = self:getDataMgr():getChairUserList()[self.m_wBankerUser+1]
        if nil ~= userItem then
            self.m_bankerName:setString(userItem.szNickName)
            local bankerstr = string.formatNumberThousands(self.m_lBankerScore,true,"/")
            temp:setString(bankerstr)
            
            self.m_bankerbg:removeChildByName("bankheadbackground")
            if bankheadbackground then bankheadbackground:removeFromParent() end
            local bankheadbackground = HeadBackground:create()
            :setPosition(0, 39)
            :setName("bankheadbackground")
            :addTo(self.m_bankerbg)
            local temp = PopupInfoHead:createNormal(userItem, 71)
            temp:setPosition(0, 0)
            temp:setTag(TAG_ENUM.HEAD_BANKER)
            bankheadbackground:addChild(temp)
            temp:enableInfoPop(true, cc.p(bankerheadpoint.x, 280), cc.p(0, 1))
        end
    end
end

--刷新庄家分数
function GameViewLayer:resetBankerScore()
    temp = self.m_bankerbg:getChildByName("txt_score")
    -- local bankerstr = ExternalFun.formatScoreText(self.m_lBankerScore)
    local bankerstr = string.formatNumberThousands(self.m_lBankerScore,true,"/")
    temp:setString(bankerstr)
    if self.m_wBankerUser == yl.INVALID_CHAIR then
        if self.m_bEnableSysBanker == false then
            temp:setString("0")
        end
    end
end

--初始化自己信息
function GameViewLayer:initSelfInfo()
    --按钮事件
    local function btnEvent( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            self:onButtonClickedEvent(sender:getTag(), sender)
        end
    end 
    
    --自己头像位置
    local bankheadbackground = HeadBackground:create()
    :setPosition(22, 45)
    :addTo(self.m_selfbg)
    local temp = PopupInfoHead:createNormal(self:getMeUserItem(), 71)
    :addTo(bankheadbackground)
    temp:enableInfoPop(true)

    local temp = self.m_selfbg:getChildByName("txt_name")
    local pselfname = ClipText:createClipText(cc.size(145, 26), self:getMeUserItem().szNickName);
    pselfname:setAnchorPoint(temp:getAnchorPoint())
    pselfname:setPosition(temp:getPosition())
    pselfname:setName(temp:getName())
    temp:removeFromParent()
    self.m_selfbg:addChild(pselfname)

    local shopbutton = self.m_selfbg:getChildByName("Brnn_Battle_jd2jh"):setTag(TAG_ENUM.BT_BANK_BUTTON)
    :addTouchEventListener(btnEvent)

    temp = self.m_selfbg:getChildByName("txt_score")
    temp:setString(ExternalFun.formatScoreText(self.m_showScore))
end

--刷新自己信息
function GameViewLayer:resetSelfInfo()
    local txt_score = self.m_selfbg:getChildByName("txt_score")
    -- txt_score:setString(ExternalFun.formatScoreText(self.m_showScore))
    txt_score:setScale(0.8)
    txt_score:setString(string.formatNumberThousands(self.m_showScore,true,"/"))
end

--开始下一局，清空上局数据
function GameViewLayer:resetGameData()
    if nil ~= self.m_cardLayer then
        self.m_cardLayer:stopAllActions()
    end
    
    for i=1,5 do
        if self.m_niuPointLayout[i] ~= nil then
            self.m_niuPointLayout[i]:removeAllChildren()
            self.m_niuPointLayout[i]:setVisible(false)
        end
        if self.m_winEffect[i] ~= nil then
            self.m_winEffect[i]:stopAllActions()
            self.m_winEffect[i]:setVisible(false)
        end
        if self.m_failedEffect[i] ~= nil then
            self.m_failedEffect[i]:setVisible(false)
        end
        if self.m_CardArray[i] ~= nil then
            for k,v in pairs(self.m_CardArray[i]) do
                v:stopAllActions()
                v:setVisible(false)
                if k < 5 then
                    v:showCardBack(false)
                else
                    v:showCardBack(true)
                end
                -- v:showCardBack(true)
            end
        end
        
    end
    self.m_lAllJettonScore = {0,0,0,0,0}
    self.m_lUserJettonScore = {0,0,0,0,0}
    self.m_lUserAllJetton = 0
    self:updateAreaScore(false)

    --清空坐下用户下注分数
    for i=1,Game_CMD.MAX_OCCUPY_SEAT_COUNT do
        if nil ~= self.m_tabSitDownUser[i] then
            self.m_tabSitDownUser[i]:clearJettonScore()
        end
    end

    --金币清除
    self.m_goldLayer:removeAllChildren()
    self.m_goldList = {{}, {}, {}, {}, {}}
    self.m_goldLayer:retain()
    self.m_goldLayer:removeFromParent()
    self:addToRootLayer(self.m_goldLayer, ZORDER_LAYER.ZORDER_JETTON_GOLD_Layer)
    self.m_goldLayer:release()

    if nil ~= self.m_gameResultLayer then
        self.m_gameResultLayer:setVisible(false)
    end

    self.m_bPlayGoldFlyIn = true
end

function GameViewLayer:onExit()
    self:stopAllActions()
    self:unloadResource()
end

--释放资源
function GameViewLayer:unloadResource()
    --特殊处理game_res blank.png 冲突
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("game_res.plist")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("game_res.png")

    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("game_bank.plist")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("game_bank.png")

    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("win_effect.plist")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("win_effect.png")

    display.removeSpriteFrames("game/yule/oxbattle2/res/frames/brnn_openCard_plist.plist", "game/yule/oxbattle2/res/frames/brnn_openCard_plist.png")
    display.removeSpriteFrames("game/yule/oxbattle2/res/frames/plist_puke.plist", "game/yule/oxbattle2/res/frames/plist_puke.png")
    display.removeSpriteFrames("game/yule/oxbattle2/res/im_card.plist", "game/yule/oxbattle2/res/frames/im_card.png")
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()

    --播放大厅背景音乐
    ExternalFun.playPlazzBackgroudAudio()

    -- --重置搜索路径
    -- local oldPaths = cc.FileUtils:getInstance():getSearchPaths();
    -- local newPaths = {};
    -- for k,v in pairs(oldPaths) do
    --     if tostring(v) ~= tostring(self._searchPath) then
    --         table.insert(newPaths, v);
    --     end
    -- end
    -- cc.FileUtils:getInstance():setSearchPaths(newPaths);

    self:getDataMgr():removeAllUser()
    self:getDataMgr():clearRecord()

    if nil ~= self.m_gameResultLayer then
        self.m_gameResultLayer:clear()
    end
end

function GameViewLayer:onButtonClickedEvent(tag, ref)
	ExternalFun.playClickEffect()
	if TAG_ENUM.BT_MENU == tag then
		self:showMenu()
    elseif TAG_ENUM.BT_LUDAN == tag then
        if nil == self.m_GameRecordLayer then
            self.m_GameRecordLayer = GameRecordLayer:create(self)
            self:addToRootLayer(self.m_GameRecordLayer, ZORDER_LAYER.ZORDER_Other_Layer)
        end
        local recordList = self:getDataMgr():getGameRecord()     
        self.m_GameRecordLayer:refreshRecord(recordList) 
    elseif TAG_ENUM.BT_BANK == tag then
        self:showMenu()
        if self.m_bGenreEducate == true then
            showToast(self, "练习模式，不能使用银行", 1.5)
            return
        end
        if 0 == GlobalUserItem.cbInsureEnable then
            showToast(self, "初次使用，请先开通银行！", 1)
        end
        --空闲状态才能存款
        if nil == self.m_bankLayer then
            self:createBankLayer()
        end
        self.m_bankLayer:setVisible(true)
        self:refreshBankScore()
    elseif TAG_ENUM.BT_BANK_BUTTON == tag then
        if self.m_bGenreEducate == true then
            showToast(self, "练习模式，不能使用银行", 1.5)
            return
        end
        if 0 == GlobalUserItem.cbInsureEnable then
            showToast(self, "初次使用，请先开通银行！", 1)
        end
        --空闲状态才能存款
        if nil == self.m_bankLayer then
            self:createBankLayer()
        end
        self.m_bankLayer:setVisible(true)
        self:refreshBankScore()    
    elseif TAG_ENUM.BT_CLOSEBANK == tag  then
        if nil ~= self.m_bankLayer then
            self.m_bankLayer:setVisible(false)
        end
    elseif TAG_ENUM.BT_TAKESCORE == tag then
        self:onTakeScore()
    elseif TAG_ENUM.BT_SET == tag then
        self:showMenu()
        local mgr = self._scene:getParentNode():getApp():getVersionMgr()
        local verstr = mgr:getResVersion(Game_CMD.KIND_ID) or "0"
        verstr = "游戏版本:" .. appdf.BASE_C_VERSION .. "." .. verstr
        local setting = SettingLayer:create(verstr, self.layout_bg, self.nightPrompt_bg)
        self:addToRootLayer(setting, ZORDER_LAYER.ZORDER_Other_Layer)
    elseif TAG_ENUM.BT_HELP == tag then
        self:showMenu()
        local rule = GameRuleLayer:create()
        self:addToRootLayer(rule, ZORDER_LAYER.ZORDER_Other_Layer)
        --self._scene:getParentNode():popHelpLayer2(Game_CMD.KIND_ID, 0, 5)
    elseif TAG_ENUM.BT_QUIT == tag then
        self:showMenu()
        self._scene:onQueryExitGame()
    --座位按钮
    elseif TAG_ENUM.BT_SEAT_0 <= tag and TAG_ENUM.BT_SEAT_5 >= tag then
        self:onSitDownClick(ref:getTag()-TAG_ENUM.BT_SEAT_0+1, ref)
    --下注按钮
    elseif TAG_ENUM.BT_JETTONSCORE_0 <= tag and TAG_ENUM.BT_JETTONSCORE_6 >= tag then
        self:onJettonButtonClicked(ref:getTag()-TAG_ENUM.BT_JETTONSCORE_0+1, ref)
    --续押按钮
    elseif TAG_ENUM.BT_JETTONSCORE_7 == tag then
        self:continuedDetentionClicked(ref) 
        ref:setScale(1.0)
    --下注区域
    elseif TAG_ENUM.BT_JETTONAREA_0 <= tag and  TAG_ENUM.BT_JETTONAREA_3 >= tag then
        self:onJettonAreaClicked(ref:getTag()-TAG_ENUM.BT_JETTONAREA_0+1, ref)
    elseif tag == TAG_ENUM.BT_USERLIST then
        if nil == self.m_userListLayer then
            self.m_userListLayer = UserListLayer:create()
            self:addToRootLayer(self.m_userListLayer, ZORDER_LAYER.ZORDER_Other_Layer)
        end
        local userList = self:getDataMgr():getUserList()        
        self.m_userListLayer:refreshList(userList)
        self.peoplenum:setString(#userList)
    elseif tag == TAG_ENUM.BT_APPLY then
        if nil == self.m_applyListLayer then
            self.m_applyListLayer = ApplyListLayer:create(self)
            self:addToRootLayer(self.m_applyListLayer, ZORDER_LAYER.ZORDER_Other_Layer)
        end
        local userList = self:getDataMgr():getApplyBankerUserList()     
        self.m_applyListLayer:refreshList(userList)
    elseif tag == TAG_ENUM.BT_SUPPERROB then
        --超级抢庄
        if Game_CMD.SUPERBANKER_CONSUMETYPE == self.m_tabSupperRobConfig.superbankerType then
            local str = "超级抢庄将花费 " .. self.m_tabSupperRobConfig.lSuperBankerConsume .. ",确定抢庄?"
            local query = QueryDialog:create(str, function(ok)
                if ok == true then
                    self:getParentNode():sendRobBanker()
                end
            end):setCanTouchOutside(false)
                :addTo(self) 
        else
            self:getParentNode():sendRobBanker()
        end
    else
        showToast(self,"功能尚未开放！",1)
	end
end

--下注响应
function GameViewLayer:onJettonButtonClicked(tag, ref)
    self.m_nJettonSelect = tag
    self.m_JettonLight:setPosition(ref:getPosition())
end

--下注区域
function GameViewLayer:onJettonAreaClicked(tag, ref)
    --非下注状态
    if self.m_cbGameStatus ~= Game_CMD.GAME_SCENE_JETTON or self.m_nJettonSelect == 0 then
        return
    end

    if self:isMeChair(self.m_wBankerUser) == true then
        return
    end
    
    if self.m_bEnableSysBanker == 0 and self.m_wBankerUser == yl.INVALID_CHAIR then
        showToast(self,"无人坐庄，不能下注",1) 
        return
    end

    local jettonscore = GameViewLayer.m_BTJettonScore[self.m_nJettonSelect]
    --
    local selfscore  = (jettonscore + self.m_lUserAllJetton)*MaxTimes
    if  selfscore > self.m_lUserMaxScore then
        showToast(self,"已超过个人最大下注值",1)
        return
    end

    local areascore = self.m_lAllJettonScore[tag+1] + jettonscore
    if areascore > self.m_lAreaLimitScore then
        showToast(self,"已超过该区域最大下注值",1)
        return
    end

    if self.m_wBankerUser ~= yl.INVALID_CHAIR then
        local allscore = jettonscore
        for k,v in pairs(self.m_lAllJettonScore) do
            allscore = allscore + v
        end
        allscore = allscore*MaxTimes
        if allscore > self.m_lBankerScore then
            showToast(self,"总下注已超过庄家下注上限",1)
            return
        end
    end
    
    self.m_lUserAllJetton = self.m_lUserAllJetton + jettonscore
    self:updateJettonList(self.m_lUserMaxScore - self.m_lUserAllJetton*MaxTimes)
    local userself = self:getMeUserItem()   
    self:getParentNode():SendPlaceJetton(jettonscore, tag)
end

function GameViewLayer:onSitDownClick( tag, sender )
    print("sit ==> " .. tag)
    local useritem = self:getMeUserItem()
    if nil == useritem then
        return
    end

    --重复判断
    if nil ~= self.m_nSelfSitIdx and tag == self.m_nSelfSitIdx then
        return
    end

    if nil ~= self.m_nSelfSitIdx then --and tag ~= self.m_nSelfSitIdx  then
        showToast(self, "当前已占 " .. self.m_nSelfSitIdx .. " 号位置,不能重复占位!", 1)
        return
    end

    if nil ~= self.m_tabSitDownUser[tag] then
        showToast(self, self.m_tabSitDownUser[tag]:getNickName().."已经捷足先登了!", 1)
        return
    end

    --坐下条件限制
    if self.m_tabSitDownConfig.occupyseatType == Game_CMD.OCCUPYSEAT_CONSUMETYPE then --金币占座
        if useritem.lScore < self.m_tabSitDownConfig.lOccupySeatConsume then
            local str = "坐下需要消耗 " .. self.m_tabSitDownConfig.lOccupySeatConsume .. " 金币,金币不足!"
            showToast(self, str, 1)
            return
        end
        local str = "坐下将花费 " .. self.m_tabSitDownConfig.lOccupySeatConsume .. ",确定坐下?"
            local query = QueryDialog:create(str, function(ok)
                if ok == true then
                    self:getParentNode():sendSitDown(tag - 1, useritem.wChairID)
                end
            end):setCanTouchOutside(false)
                :addTo(self)
    elseif self.m_tabSitDownConfig.occupyseatType == Game_CMD.OCCUPYSEAT_VIPTYPE then --会员占座
        if useritem.cbMemberOrder < self.m_tabSitDownConfig.enVipIndex then
            local str = "坐下需要会员等级为 " .. self.m_tabSitDownConfig.enVipIndex .. " 会员等级不足!"
            showToast(self, str, 1)
            return
        end
        self:getParentNode():sendSitDown(tag - 1, self:getMeUserItem().wChairID)
    elseif self.m_tabSitDownConfig.occupyseatType == Game_CMD.OCCUPYSEAT_FREETYPE then --免费占座
        if useritem.lScore < self.m_tabSitDownConfig.lOccupySeatFree then
            local str = "免费坐下需要携带金币大于 " .. self.m_tabSitDownConfig.lOccupySeatFree .. " ,当前携带金币不足!"
            showToast(self, str, 1)
            return
        end
        self:getParentNode():sendSitDown(tag - 1, self:getMeUserItem().wChairID)
    end
end

function GameViewLayer:OnUpdataClockView(chair, time)
    local selfchair = self:getParent():GetMeChairID()
    if chair == self:getParentNode():SwitchViewChairID(selfchair) then
        local temp = self.m_timeLayout:getChildByName("txt_time")
        temp:setString(string.format("%02d", time))
        if self.m_cbGameStatus == Game_CMD.GAME_SCENE_JETTON then
            self.m_bPlayGoldFlyIn = true
            self.m_fJettonTime = math.min(0.1, time)
        end
    else
        if self.m_cbGameStatus ~= Game_CMD.GAME_SCENE_END then
            return
        end
        if time == self.m_cbTimeLeave then
            --刷新上一局的押注数目
            self:RefreshStakeNum()
            --发牌处理
            local action = cc.Sequence:create(cc.FadeTo:create(0.2, 255), cc.DelayTime:create(0.9), cc.FadeTo:create(0.2, 0),
            cc.CallFunc:create(function ()
                self:sendCard(true)
            end))
            local spawn = cc.Spawn:create(action, cc.CallFunc:create(function ( )  ExternalFun.playSoundEffect("STOP_W.wav") end))
            self.tingzhixiazhu:runAction(spawn)
            --self:sendCard(true)
        elseif time == self.m_cbTimeLeave-4  then
            --显示点数
            local action = cc.Sequence:create(cc.DelayTime:create(1.3), cc.CallFunc:create(function ()
                self:showCard(true)
            end))
            self:runAction(action)
        elseif time == self.m_cbTimeLeave-10 then
            --金币处理
            local action = cc.Sequence:create(cc.DelayTime:create(2.3), cc.CallFunc:create(function ()
                self:showGoldMove()
            end))
            self:runAction(action)
        end
    end
end

--获取数据
function GameViewLayer:getParentNode()
    return self._scene
end

function GameViewLayer:getMeUserItem()
    if nil ~= GlobalUserItem.dwUserID then
        return self:getDataMgr():getUidUserList()[GlobalUserItem.dwUserID]
    end
    return nil
end

function GameViewLayer:isMeChair( wchair )
    local useritem = self:getDataMgr():getChairUserList()[wchair + 1]
    if nil == useritem then
        return false
    else 
        return useritem.dwUserID == GlobalUserItem.dwUserID
    end
end

function GameViewLayer:addToRootLayer( node , zorder)
    if nil == node then
        return
    end

    self.m_rootLayer:addChild(node)
    node:setLocalZOrder(zorder)
end

function GameViewLayer:getChildFromRootLayer( tag )
    if nil == tag then
        return nil
    end
    return self.m_rootLayer:getChildByTag(tag)
end

function GameViewLayer:getDataMgr( )
    return self:getParentNode():getDataMgr()
end

function GameViewLayer:getApplyState(  )
    return self.m_enApplyState
end

function GameViewLayer:getApplyCondition(  )
    return self.m_llCondition
end

--获取能否上庄
function GameViewLayer:getApplyable(  )
    --自己超级抢庄已申请，则不可进行普通申请
    if APPLY_STATE.kSupperApplyed == self.m_enApplyState then
        return false
    end

    local userItem = self:getMeUserItem()
    if nil ~= userItem then
        return userItem.lScore > self.m_llCondition
    else
        return false
    end
end

--获取能否取消上庄
function GameViewLayer:getCancelable(  )
    return self.m_cbGameStatus == Game_CMD.GAME_SCENE_FREE
end

function GameViewLayer:logData(msg)
    local p = self:getParentNode()
    if nil ~= p.logData then
        p:logData(msg)
    end 
end

function GameViewLayer:showPopWait( )
    self:getParentNode():showPopWait()
end

function GameViewLayer:dismissPopWait( )
    self:getParentNode():dismissPopWait()
end

----网络消息处理------- 
function GameViewLayer:onGameSceneFree(cmd_table)
    --玩家分数
    self.m_lUserMaxScore = cmd_table.lUserMaxScore
    self.m_lApplyBankerCondition = cmd_table.lApplyBankerCondition
    self.m_cbTimeLeave = cmd_table.cbTimeLeave
    self.m_wBankerUser = cmd_table.wBankerUser
    self.m_lBankerScore = cmd_table.lBankerScore
    self.m_bEnableSysBanker = cmd_table.bEnableSysbanker
    self.m_lAreaLimitScore = cmd_table.lAreaLimitScore
    self.m_bGenreEducate = cmd_table.bGenreEducate
    self:resetBankerInfo()
    self:resetSelfInfo()
    self.m_cbGameStatus = Game_CMD.GAME_SCENE_FREE
    self:showGameStatus()
    self.m_lAllJettonScore = {0,0,0,0,0}
    self.m_lUserJettonScore = {0,0,0,0,0}
    self.m_lUserAllJetton = 0
    --获取到占位信息
    self:onGetSitDownInfo(cmd_table.occupyseatConfig, cmd_table.wOccupySeatChairID[1])
    --抢庄条件
    self:onGetApplyBankerCondition(cmd_table.lApplyBankerCondition, cmd_table.superbankerConfig)
    self:setJettonEnable(true)
    self:setXybtnEnable(false)
    self:updateAreaScore(false)
    self:updateJettonList(self.m_lUserMaxScore)
end

function GameViewLayer:onGameScenePlaying(cmd_table)
    dump(cmd_table)
    --玩家分数
    self.m_lUserMaxScore = cmd_table.lUserMaxScore
    self.m_lApplyBankerCondition = cmd_table.lApplyBankerCondition
    self.m_cbTimeLeave = cmd_table.cbTimeLeave
    self.m_wBankerUser = cmd_table.wBankerUser
    self.m_lBankerScore = cmd_table.lBankerScore
    self.m_bEnableSysBanker = cmd_table.bEnableSysbanker
    self.m_lAreaLimitScore = cmd_table.lAreaLimitScore
    self.m_bGenreEducate = cmd_table.bGenreEducate
    self:resetBankerInfo()
    self:resetSelfInfo()
    self.m_cbGameStatus = Game_CMD.GAME_SCENE_FREE
    self.m_lAllJettonScore = cmd_table.lAllJettonScore[1]
    self.m_lUserJettonScore = cmd_table.lUserJettonScore[1]
    self.m_lBankerWinScore = cmd_table.lBankerWinScore

    local bankername = "系统"
    if  self.m_wBankerUser ~= yl.INVALID_CHAIR then
        local useritem = self:getDataMgr():getChairUserList()[self.m_wBankerUser + 1]
        if nil ~= useritem then
            bankername = useritem.szNickName
        end
    end
    self:setXybtnEnable(false)
    self.m_tBankerName = bankername

    self.m_lSelfWinScore = cmd_table.lEndUserScore
    for k,v in pairs(self.m_lUserJettonScore) do
        self.m_lUserAllJetton = self.m_lUserAllJetton + v
    end
    
    self.m_cbTableCardArray = cmd_table.cbTableCardArray
    if cmd_table.cbGameStatus == Game_CMD.GAME_SCENE_JETTON then
        self.m_cbGameStatus = Game_CMD.GAME_SCENE_JETTON
        self:getParent():SetGameClock(self:getParent():GetMeChairID(), 1, cmd_table.cbTimeLeave)
        self:setJettonEnable(true)
        self:updateJettonList(self.m_lUserMaxScore - self.m_lUserAllJetton*MaxTimes)
        self:updateAreaScore(true)
    else
        self:setJettonEnable(false)
        --自己是否下注
        local jettonscore = 0
        for k,v in pairs(cmd_table.lUserJettonScore[1]) do
            jettonscore = jettonscore + v
        end
        --自己是否有输赢
        jettonscore = jettonscore + self.m_lSelfWinScore
        if jettonscore ~= 0 and self.m_cbTimeLeave > 8 then
            self:sendCard(false) 
            self:showCard(false)
            self:showGameEnd(false)
            --self:updateAreaScore(true)
            self.m_cbGameStatus = Game_CMD.GAME_SCENE_END
        else
            self.m_cbGameStatus = Game_CMD.GAME_SCENE_FREE
            self.m_cbTimeLeave = self.m_cbTimeLeave + 5
            self:getParent():SetGameClock(self:getParent():GetMeChairID(), 1, self.m_cbTimeLeave)
        end     
    end
    self:showGameStatus()
    --获取到占位信息
    self:onGetSitDownInfo(cmd_table.occupyseatConfig, cmd_table.wOccupySeatChairID[1])
    --抢庄条件
    self:onGetApplyBankerCondition(cmd_table.lApplyBankerCondition, cmd_table.superbankerConfig)
end

--空闲
function GameViewLayer:onGameFree(cmd_table)
    self.m_cbGameStatus = Game_CMD.GAME_SCENE_FREE
    self.m_cbTimeLeave = cmd_table.cbTimeLeave
    self:showGameStatus()

    self.m_lAllJettonScore = {0,0,0,0,0}
    self.m_lUserJettonScore = {0,0,0,0,0}
    self:resetGameData()
    self:setJettonEnable(true)
    self:setXybtnEnable(false)
    self:updateJettonList(self.m_lUserMaxScore)
    --上庄条件刷新
    self:refreshCondition()

    --申请按钮状态更新
    self:refreshApplyBtnState()
end

--开始下注
function GameViewLayer:onGameStart(cmd_table)
    local action = cc.Sequence:create(cc.FadeTo:create(0.2, 255), cc.DelayTime:create(0.9), cc.FadeTo:create(0.2, 0))
    local spawn = cc.Spawn:create(action, cc.CallFunc:create(function ( )  ExternalFun.playSoundEffect("START_W.wav") end))
    self.kaishixiazhu:runAction(spawn)
    self.m_cbGameStatus = Game_CMD.GAME_SCENE_JETTON
    self.m_cbTimeLeave = cmd_table.cbTimeLeave
    self.m_lUserMaxScore = cmd_table.lUserMaxScore
    self.m_wBankerUser = cmd_table.wBankerUser
    self.m_lBankerScore = cmd_table.lBankerScore
    self:showGameStatus()
    self:setJettonEnable(true)
    self:setXybtnEnable(true)
    self:resetBankerScore()
    self:updateJettonList(self.m_lUserMaxScore)
    if self:isMeChair(self.m_wBankerUser) == true then
        self:setJettonEnable(false)
    end

    self:resetBankerScore()
    --申请按钮状态更新
    self:refreshApplyBtnState()
end

--结束
function GameViewLayer:onGameEnd(cmd_table)
    dump(cmd_table, "结算时服务器传过来的数据", 10)
    self.m_cbGameStatus = Game_CMD.GAME_SCENE_END
    self.m_cbTableCardArray = cmd_table.cbTableCardArray
    self.m_lSelfWinScore = cmd_table.lUserScore
    self.m_lBankerWinScore = cmd_table.lBankerScore
    self.m_lOccupySeatUserWinScore = cmd_table.lOccupySeatUserWinScore

    local bankername = "系统"
    if  self.m_wBankerUser ~= yl.INVALID_CHAIR then
        local useritem = self:getDataMgr():getChairUserList()[self.m_wBankerUser + 1]
        if nil ~= useritem then
            bankername = useritem.szNickName
        end
    end
    self.m_tBankerName = bankername

    self:showGameStatus()
    self:setJettonEnable(false)
    self:setXybtnEnable(false)
end

--用户下注
function GameViewLayer:onPlaceJetton(cmd_table)
    --dump(cmd_table)
    if self:isMeChair(cmd_table.wChairID) == true then
        local oldscore = self.m_lUserJettonScore[cmd_table.cbJettonArea+1]
        self.m_lUserJettonScore[cmd_table.cbJettonArea+1] = oldscore + cmd_table.lJettonScore 
    end
    
    local oldscore = self.m_lAllJettonScore[cmd_table.cbJettonArea+1]
    self.m_lAllJettonScore[cmd_table.cbJettonArea+1] = oldscore + cmd_table.lJettonScore

    self:showUserJetton(cmd_table)
    self:updateAreaScore(true)
end

--下注失败
function GameViewLayer:onPlaceJettonFail(cmd_table)
    if self:isMeChair(cmd_table.wPlaceUser) == true then
        self.m_lUserAllJetton = self.m_lUserAllJetton - cmd_table.lPlaceScore 
    end
end

--提前开牌
function GameViewLayer:onAdvanceOpenCard()
    showToast(self, "下注已超上限，提前开牌", 1)
end

--申请上庄
function GameViewLayer:onApplyBanker( cmd_table)
    if self:isMeChair(cmd_table.wApplyUser) == true then
        self.m_enApplyState = APPLY_STATE.kApplyState
    end

    self:refreshApplyList()
end

--切换庄家
function GameViewLayer:onChangeBanker(cmd_table)
    dump(cmd_table, "切换庄家", 10)
    --上一个庄家是自己，且当前庄家不是自己，标记自己的状态
    if self.m_wBankerUser ~= wBankerUser and self:isMeChair(self.m_wBankerUser) then
        self.m_enApplyState = APPLY_STATE.kCancelState
    end
    self.m_wBankerUser = cmd_table.wBankerUser
    self.m_lBankerScore = cmd_table.lBankerScore
    self:resetBankerInfo()
    print("切换庄家", cmd_table.lBankerScore)

    --自己上庄
    if self:isMeChair(cmd_table.wBankerUser) == true then
        self.m_enApplyState = APPLY_STATE.kApplyedState
    end

    --如果是超级抢庄用户上庄
    if cmd_table.wBankerUser == self.m_wCurrentRobApply then
        self.m_wCurrentRobApply = yl.INVALID_CHAIR
        self:refreshCondition()
    end

    --坐下用户庄家
    local chair = -1
    for i = 1, Game_CMD.MAX_OCCUPY_SEAT_COUNT do
        if nil ~= self.m_tabSitDownUser[i] then
            chair = self.m_tabSitDownUser[i]:getChair()
            self.m_tabSitDownUser[i]:updateBanker(chair == cmd_table.wBankerUser)
        end
    end
end

--取消申请
function GameViewLayer:onGetCancelBanker(cmd_table)
    if self:isMeChair(cmd_table.wCancelUser) == true then
        self.m_enApplyState = APPLY_STATE.kCancelState
    end

    self:refreshApplyList()
end

--抢庄条件
function GameViewLayer:onGetApplyBankerCondition( llCon , rob_config)
    self.m_llCondition = llCon
    --超级抢庄配置
    self.m_tabSupperRobConfig = rob_config

    self:refreshCondition()
end

--超级抢庄申请
function GameViewLayer:onGetSupperRobApply(  )
    if yl.INVALID_CHAIR ~= self.m_wCurrentRobApply then
        self.m_bSupperRobApplyed = true
        ExternalFun.enableBtn(self.m_btSupperRob, false)
    end
    --如果是自己
    if true == self:isMeChair(self.m_wCurrentRobApply) then
        --普通上庄申请不可用
        self.m_enApplyState = APPLY_STATE.kSupperApplyed
    end
end

--超级抢庄用户离开
function GameViewLayer:onGetSupperRobLeave( wLeave )
    if yl.INVALID_CHAIR == self.m_wCurrentRobApply then
        --普通上庄申请不可用
        self.m_bSupperRobApplyed = false

        ExternalFun.enableBtn(self.m_btSupperRob, true)
    end
end

--座位坐下信息
function GameViewLayer:onGetSitDownInfo( config, info )
    self.m_tabSitDownConfig = config
    
    local pos = cc.p(0,0)
    --获取已占位信息
    for i = 1, Game_CMD.MAX_OCCUPY_SEAT_COUNT do
        print("sit chair " .. info[i])
        self:onGetSitDown(i - 1, info[i], false)
    end
end

--座位坐下
function GameViewLayer:onGetSitDown( index, wchair, bAni )
    if wchair ~= nil 
        and nil ~= index
        and index ~= Game_CMD.SEAT_INVALID_INDEX 
        and wchair ~= yl.INVALID_CHAIR then
        local useritem = self:getDataMgr():getChairUserList()[wchair + 1]

        if nil ~= useritem then
            --下标加1
            index = index + 1
            if nil == self.m_tabSitDownUser[index] then
                self.m_tabSitDownUser[index] = SitRoleNode:create(self, index)
                self.m_tabSitDownUser[index]:setPosition(self.m_TableSeat[index]:getPosition())
                self:addToRootLayer(self.m_tabSitDownUser[index], 1)
            end
            self.m_tabSitDownUser[index]:onSitDown(useritem, bAni, wchair == self.m_wBankerUser)

            if useritem.dwUserID == GlobalUserItem.dwUserID then
                self.m_nSelfSitIdx = index
            end
        end
    end
end

--座位失败/离开
function GameViewLayer:onGetSitDownLeave( index )
    if index ~= Game_CMD.SEAT_INVALID_INDEX 
        and nil ~= index then
        index = index + 1
        if nil ~= self.m_tabSitDownUser[index] then
            self.m_tabSitDownUser[index]:removeFromParent()
            self.m_tabSitDownUser[index] = nil
        end

        if self.m_nSelfSitIdx == index then
            self.m_nSelfSitIdx = nil
        end
    end
end

--银行操作成功
function GameViewLayer:onBankSuccess( )
    local bank_success = self:getParentNode().bank_success
    if nil == bank_success then
        return
    end
    GlobalUserItem.lUserScore = bank_success.lUserScore
    GlobalUserItem.lUserInsure = bank_success.lUserInsure

    if nil ~= self.m_bankLayer and true == self.m_bankLayer:isVisible() then
        self:refreshBankScore()
    end

    showToast(self, bank_success.szDescribrString, 2)
end

--银行操作失败
function GameViewLayer:onBankFailure( )
    local bank_fail = self:getParentNode().bank_fail
    if nil == bank_fail then
        return
    end

    showToast(self, bank_fail.szDescribeString, 2)
end

--银行资料
function GameViewLayer:onGetBankInfo(bankinfo)
    bankinfo.wRevenueTake = bankinfo.wRevenueTake or 10
    if nil ~= self.m_bankLayer then
        local str = "温馨提示:取款将扣除" .. bankinfo.wRevenueTake .. "‰的手续费"
        self.m_bankLayer.m_textTips:setString(str)
    end
end

-------界面显示更新--------
--菜单栏操作
function GameViewLayer:showMenu()
    if self.m_bshowMenu == false then
        self.m_bshowMenu = true
        self.m_menulayout:setVisible(true)
        self.m_menulayout:runAction(cc.ScaleTo:create(0.2, 1.0))
    else
    -- dump(TAG_ENUM.BT_MENU, "隐藏菜单层", 6)
        self.m_bshowMenu = false
        self.m_menulayout:runAction(cc.Sequence:create(
            cc.ScaleTo:create(0.2, 1.0, 0.0001), 
            cc.CallFunc:create(
                function()
                    self.m_menulayout:setVisible(false)
                end
                )
            )
        )
    end
end

--更新游戏状态显示
function GameViewLayer:showGameStatus()
    if self.m_cbGameStatus == Game_CMD.GAME_SCENE_END then
        self.m_timeLayout:setVisible(false)
    else
        self.m_timeLayout:setVisible(true)
        local icon = self.m_timeLayout:getChildByName("im_icon")
        local content = self.m_timeLayout:getChildByName("im_txt")
        local time = self.m_timeLayout:getChildByName("txt_time")
        time:setString(string.format("%02d", self.m_cbTimeLeave))
        if self.m_cbGameStatus == Game_CMD.GAME_SCENE_FREE then
            icon:loadTexture("im_time_free.png",UI_TEX_TYPE_PLIST)
            content:loadTexture("txt_time_free.png", UI_TEX_TYPE_PLIST)
        elseif self.m_cbGameStatus == Game_CMD.GAME_SCENE_JETTON then
            icon:loadTexture("im_time_jetton.png",UI_TEX_TYPE_PLIST)
            content:loadTexture("txt_time_jetton.png", UI_TEX_TYPE_PLIST)    
        end
    end
end

--发牌动画
function GameViewLayer:sendCard(banim)
    dump(self.m_cbTableCardArray)
    if banim then
        local delaytime = 0.1
        for i=1,5 do
            for j=1,5 do
                local card = self.m_CardArray[i][j]
                card:showCardBack(true)
                card:setCardValue(self.m_cbTableCardArray[i][j])
                card:runAction(cc.Sequence:create(cc.RotateTo:create(0, 45), cc.ScaleTo:create(0, 0.05)))
                local index = (i-1)*5 + j - 1
                card:setPosition(192, 589)
                card:runAction(cc.Sequence:create(cc.DelayTime:create(delaytime*index), cc.CallFunc:create(
                    function()
                        if j == 1 then
                            ExternalFun.playSoundEffect("out_card.mp3")
                        end
                        card:setOpacity(0)
                        card:setVisible(true)
                        card:runAction(cc.FadeTo:create(0.04, 255))
                        local controlpos = cc.p(192, 589)
                        local middlepos = cc.p(cardpoint[i].x+40, (card:getPositionY()+cardpoint[i].y)/2 + 50)
                        local endpos = cardpoint[i]
                        local bezier = {
                            controlpos,
                            middlepos,
                            endpos
                        }
                        local beaction = cc.BezierTo:create(0.33, bezier)
                        local sequence = cc.Sequence:create(cc.RotateTo:create(0.33, 0))
                        local spawn = cc.Spawn:create(sequence, beaction, cc.MoveBy:create(0.04*(j-1), cc.p(32*(j-1),0)), cc.ScaleTo:create(0.33, 80/158, 110/208))
                        card:runAction(spawn)
                    end
                )))  
                if i == 5 and j == 5 then
                    for i=1,5 do
                        for j=1,5 do
                            local card = self.m_CardArray[i][j]
                            local spawn = cc.Spawn:create(
                                cc.MoveBy:create(0.33, cc.p(-32*(5-j),0)),
                                cc.CallFunc:create(function ()
                                    if j ~= 5 then card:showCardBack(false) end
                                end)
                                )
                            local mvoe = cc.Sequence:create(cc.DelayTime:create(2.5), 
                                cc.MoveBy:create(0.33, cc.p(32*(5-j),0)),
                                spawn
                                )
                            card:runAction(mvoe)
                        end
                    end
                end   
            end
        end
    else
        for i=1,5 do
            for j=1,5 do
                local card = self.m_CardArray[i][j]
                card:setVisible(true)
                card:setPosition(cardpoint[i].x + (j-1)*32, cardpoint[i].y)
            end
        end
    end
    
end

--显示牌跟牌值
function GameViewLayer:showCard(banim)
    print("发牌动画时的牌值！！！！！！！！！！！！")
    dump(self.m_cbTableCardArray)
    local dumpcardata = clone(self.m_cbTableCardArray)
    --翻牌顺序
    local tTurnOverOrder = {[1]=2,[2]=3,[3]=4,[4]=5,[5]=1}
    --切换金币层层级显示
    self.m_goldLayer:retain()
    self.m_goldLayer:removeFromParent()
    self:addToRootLayer(self.m_goldLayer, ZORDER_LAYER.ZORDER_GOLD_Layer)
    self.m_goldLayer:release()
    --提前保存输赢背景
    local pbglayout = {}
    local niuvalue = {}
    for i=1,5 do
        pbglayout[i] = self.m_niuPointLayout[i]
        niuvalue[i] = GameLogic:GetCardType(self.m_cbTableCardArray[i], 5)
    end

    for i=1,5 do
        self.m_niuPoint[i] = niuvalue[i]
        -- 输了背景
        -- pbglayout[i]:setScale(0.7)
        pbglayout[i]:setVisible(false)
        pbglayout[i]:loadTexture("im_point_failed_bg.png", UI_TEX_TYPE_PLIST) 
        
        --牛几显示
        local ptemp = self:getNiuTxt("game_res/num_point.png", niuvalue[i], pbglayout[i]):setTag(999) 
        ptemp:setPosition(pbglayout[i]:getContentSize().width/2, pbglayout[i]:getContentSize().height/2)
        pbglayout[i]:addChild(ptemp)

        if i > 1 then
            local a, b = GameLogic:CompareCard(self.m_cbTableCardArray[1], self.m_niuPoint[1], self.m_cbTableCardArray[i], self.m_niuPoint[i])
            if a == 0 then
                print("比牌错误", self.m_niuPoint[1], self.m_niuPoint[i])
                dump(self.m_cbTableCardArray[1])
                dump(self.m_cbTableCardArray[i])
                return
            end
            self.m_bUserOxCard[i], self.m_Multiple[i] = a, b 

            local pwinscorebg = ccui.ImageView:create("im_jetton_score_bg.png", UI_TEX_TYPE_PLIST)
            pwinscorebg:setName("bunko")
            pwinscorebg:setVisible(false)
            pwinscorebg:setAnchorPoint(0.5, 1)
            pwinscorebg:setPosition(pbglayout[i]:getContentSize().width/2, -12)
            pbglayout[i]:addChild(pwinscorebg)

            local pwinscore = ccui.Text:create("", "fonts/round_body.ttf", 22)
            pwinscore:setFontSize(22)
            pwinscore:setColor(cc.c3b(255, 255, 0))
            pwinscore:setPosition(pwinscorebg:getContentSize().width/2, pwinscorebg:getContentSize().height/2)
            pwinscorebg:addChild(pwinscore)
            
            if self.m_lUserJettonScore[i] > 0 then
                local str = ExternalFun.formatScoreText(self.m_lUserJettonScore[i]*b)
                if a  == 1 then
                    str = "+"..str
                else
                    pwinscore:setColor(cc.c3b(30, 140, 210))
                    str = "-"..str
                end
                pwinscore:setString(str)
            else
                pwinscore:setString("没有下注")
            end 
        end


        local function showFunction(value)
            for j=1,5 do
                local card = self.m_CardArray[value][j]
                -- local cardvalue = self.m_cbTableCardArray[value][j]
                -- card:setCardValue(cardvalue)
                card:showCardBack(false)
                if j == 5 then 
                    card:showCardBack(true)
                    local eposx = card:getPositionX()
                    local eposy = card:getPositionY()
                    if pbglayout[value] ~= nil then
                        local function binkShow()
                            -- if value >= 2 then
                            --     --  闲家赢
                            --     if self.m_bUserOxCard[value] == 1 then
                            --         self.m_winEffect[value]:setVisible(true)
                            --         self.m_winEffect[value]:runAction(cc.RepeatForever:create(cc.Blink:create(1.0,1)))
                            --     else
                            --         self.m_failedEffect[value]:setVisible(true)
                            --     end
                            -- end
                            if value == 1 then 
                                for i = 2, 5 do
                                    pbglayout[i]:getChildByName("bunko"):setVisible(true) 
                                    if self.m_bUserOxCard[i] == 1 then
                                        self.m_winEffect[i]:setVisible(true)
                                        self.m_winEffect[i]:runAction(cc.RepeatForever:create(cc.Blink:create(1.0,1)))
                                    else
                                        self.m_failedEffect[i]:setVisible(true)
                                    end
                                end
                            end
                            for j = 1, 5 do 
                                self.m_CardArray[value][j]:setCardValue(self.m_cbTableCardArray[value][j])
                            end
                            if  niuvalue[value] > 1 then 
                                --最后两张牌弹起
                                self.m_CardArray[value][4]:runAction(cc.Sequence:create(cc.MoveBy:create(0.1, cc.p(0,15))))
                                self.m_CardArray[value][5]:runAction(cc.Sequence:create(cc.MoveBy:create(0.1, cc.p(0,15))))
                            end
                        end
                        --放大效果
                        local function action3()
                            ExternalFun.playSoundEffect("open_card.wav")
                            local soundValue = self.m_niuPoint[value] - 1
                            soundValue = soundValue > 10 and 10 or soundValue
                            ExternalFun.playSoundEffect("OX_"..soundValue.."_BANKER_SOUND.wav")
                            pbglayout[value]:setVisible(true)
                            pbglayout[value]:runAction(cc.Sequence:create(cc.CallFunc:create(function ()
                                pbglayout[value]:getChildByTag(999):setScale(0.8)
                                local ac = cc.ScaleTo:create(0.2,1)
                                pbglayout[value]:getChildByTag(999):runAction(ac)
                            end)
                            ))
                        end 
                        --翻牌动画
                        local function action1()
                            card:setVisible(false)
                            local animation = OpenPukeEffect:create(dumpcardata[value][5], "Brnn_openCard_")
                            :align(display.CENTER, eposx+40, eposy-40)
                            :addTo(self.m_cardLayer,100)
                        end
                        --显示牌面
                        local function action2()
                            card:setVisible(true)
                            card:showCardBack(false)
                        end
                        local cardaction = cc.Sequence:create(cc.DelayTime:create(0.3), cc.Spawn:create(cc.RotateTo:create(0.07,90), cc.MoveTo:create(0.07, cc.p(eposx+40, eposy+35))),
                            cc.CallFunc:create(action1),
                            cc.DelayTime:create(1.04),
                            cc.CallFunc:create(action2),
                            cc.RotateTo:create(0.07,0), 
                            cc.MoveTo:create(0.07, cc.p(eposx, eposy)),
                            cc.DelayTime:create(0.24),
                            cc.CallFunc:create(action3),
                            cc.DelayTime:create(0.1),
                            cc.CallFunc:create(binkShow)
                            )
                            card:runAction(cardaction)
                    end
                end
            end
        end

        if banim then
            self.m_cardLayer:runAction(cc.Sequence:create(cc.DelayTime:create((i-1)*1.2), cc.CallFunc:create(
                function ()
                    showFunction(tTurnOverOrder[i])
                end
                )))
        else
            showFunction(tTurnOverOrder[i])
        end
        
    end
end

--显示用户下注
function GameViewLayer:showUserJetton(cmd_table)
    -- 根据下注的额度来决定飞出去的金币图片
    local Amountofnote = cmd_table.lJettonScore
    --如果是自己，金币从自己出飞出
    if self.m_cbGameStatus ~= Game_CMD.GAME_SCENE_JETTON then
        return
    end
    local goldnum = self:getGoldNum(cmd_table.lJettonScore)
    local beginpos = userlistpoint
    local offsettime = math.min(self.m_fJettonTime, 1)
    if self:isMeChair(cmd_table.wChairID) == true then
        local tp = {[100] = 0,[1000] = 1,[10000] = 2,[100000] = 3,[1000000] = 4,[5000000] = 5,[10000000] = 6}
        self:Record_bet(cmd_table.cbJettonArea-1, tp[cmd_table.lJettonScore])
        beginpos = selfheadpoint
        ExternalFun.playSoundEffect("coins_fly_in.wav")
    else
        local seatUser = self:getIsUserSit(cmd_table.wChairID)
        --坐下玩家下注
        if seatUser ~= nil then
            local posindex = seatUser:getIndex()
            seatUser:addJettonScore(cmd_table.lJettonScore, cmd_table.cbJettonArea)
            beginpos = cc.p(self.m_TableSeat[posindex]:getPosition())
            ExternalFun.playSoundEffect("coins_fly_in.wav") 
        --其他玩家下注
        else
            offsettime = math.min(self.m_fJettonTime, 3)
            if self.m_bPlayGoldFlyIn == true then
                ExternalFun.playSoundEffect("coins_fly_in.wav")
                self.m_bPlayGoldFlyIn = false
            end
        end    
    end 
    for i=1,goldnum do 
        local tp = {[100] = 0,[1000] = 1,[10000] = 2,[50000] = 8,[100000] = 3,[500000] = 7,[1000000] = 4,[5000000] = 5,[10000000] = 6}
        local pgold = cc.Sprite:create("Jetton/ChouMa_"..tp[Amountofnote]..".png")--:setScale(0.33)--cc.Sprite:createWithSpriteFrameName(string.format("bt_score_%s_0.png",tp[Amountofnote])):setScale(0.33)
        pgold:setPosition(beginpos)
        self.m_goldLayer:addChild(pgold)
        
        if i == 1 then
            local moveaction = self:getMoveAction(beginpos, self:getRandPos(self.m_JettonArea[cmd_table.cbJettonArea]), 0, 0)
            pgold:runAction(moveaction)
        else
           local randnum = math.random()*offsettime
           pgold:setVisible(false)
           pgold:runAction(cc.Sequence:create(cc.DelayTime:create(randnum), cc.CallFunc:create(
                   function ()
                       local moveaction = self:getMoveAction(beginpos, self:getRandPos(self.m_JettonArea[cmd_table.cbJettonArea]), 0, 0)
                       pgold:setVisible(true)
                       pgold:runAction(moveaction)
                   end
               )))
        end
        table.insert(self.m_goldList[cmd_table.cbJettonArea+1], pgold)
    end
end

--结算金币处理
function GameViewLayer:showGoldMove()
    if self.m_cbGameStatus ~= Game_CMD.GAME_SCENE_END then
        return
    end
    local winAreaNum = 0
    local winScore = 0
    for i=1,Game_CMD.AREA_COUNT do
        --表示该区域庄家赢分
        if self.m_bUserOxCard[i+1] == -1 then
            winAreaNum = winAreaNum + 1
            winScore = winScore + self.m_lAllJettonScore[i+1]
            self:showGoldToZ(i)
        end
    end

    --庄家未赢钱
    if winScore == 0 then
       self:showGoldToArea()
    else
        -- 只要有一处下注区域庄家赢，就延迟0.6s后再放飞向闲家钱的动画
        self.m_goldLayer:runAction(cc.Sequence:create(cc.DelayTime:create(0.6), cc.CallFunc:create(
                function ()
                    self:showGoldToArea()
                end
            ))) 
    end
end

--显示金币飞到庄家处
function GameViewLayer:showGoldToZ(cbArea)
    local goldnum = #self.m_goldList[cbArea+1]
    if goldnum == 0 then
        return
    end
    ExternalFun.playSoundEffect("coinCollide.wav")
    --分十次飞行完成
    local cellnum = math.floor(goldnum/10)
    if cellnum == 0 then
        cellnum = 1
    end
    local cellindex = 0
    local outnum = 0
    for i=goldnum, 1, -1 do
        local pgold = self.m_goldList[cbArea+1][i]
        table.remove(self.m_goldList[cbArea+1], i)
        table.insert(self.m_goldList[1], pgold)
        outnum = outnum + 1
        local moveaction = self:getMoveAction(cc.p(pgold:getPosition()), bankerheadpoint, 1, 0)
        pgold:runAction(cc.Sequence:create(cc.DelayTime:create(cellindex*0.03), moveaction, cc.CallFunc:create(
                function ()
                    pgold:setVisible(false)
                end
            )))
        if outnum >= cellnum then
            cellindex = cellindex + 1
            outnum = 0
        end
    end
end

--显示金币庄家飞到下注区域
function GameViewLayer:showGoldToArea()
    if self.m_cbGameStatus ~= Game_CMD.GAME_SCENE_END then
        return
    end
    local failureScore = 0
    for i=1,Game_CMD.AREA_COUNT do
        --表示该区域庄家输分
        if self.m_bUserOxCard[i+1] == 1 then
            local lJettonScore = self.m_lAllJettonScore[i+1]
            if lJettonScore > 0 then
                self:showGoldToAreaWithID(i)
                failureScore = failureScore + lJettonScore
            end
        end
    end

    --庄家全赢
    if failureScore == 0 then
        --坐下用户
        for i = 1, Game_CMD.MAX_OCCUPY_SEAT_COUNT do
            if nil ~= self.m_tabSitDownUser[i] then
                local chair = self.m_tabSitDownUser[i]:getChair()
                local score = self.m_lOccupySeatUserWinScore[1][i]
                local useritem = self:getDataMgr():getChairUserList()[chair + 1]
                --金币动画
                self.m_tabSitDownUser[i]:gameEndScoreChange(useritem, score)
            end 
        end
        self:showGameEnd()
    else
        self.m_goldLayer:runAction(cc.Sequence:create(cc.DelayTime:create(0.8), cc.CallFunc:create(
                function ()
                    self:showGoldToUser()
                end
            )))
    end
end

function GameViewLayer:showGoldToAreaWithID(cbArea)
    ExternalFun.playSoundEffect("coinCollide.wav")
    local goldnum = self:getWinGoldNumWithAreaID(cbArea)
    local listnum = #self.m_goldList[1]
    print("输钱需要的金币数为："..goldnum)
    print("庄家赢取的金币数为："..listnum)
    --当前列表金币数不足
    local addnum = 0
    if goldnum > listnum then
        addnum = goldnum - listnum
    end
    local fornum = math.min(goldnum, listnum)

    if fornum > 0 then
        for i=1,fornum do
            local pgold = self.m_goldList[1][listnum-i+1]
            table.remove(self.m_goldList[1], listnum-i+1)
            table.insert(self.m_goldList[cbArea + 1], pgold)
            pgold:setPosition(bankerheadpoint)
            pgold:stopAllActions()
            pgold:runAction(cc.Sequence:create(cc.DelayTime:create(0.01*i), cc.CallFunc:create(
                    function ()
                        local moveaction = self:getMoveAction(bankerheadpoint, self:getRandPos(self.m_JettonArea[cbArea]), 0, 1)
                        pgold:setVisible(true)
                        pgold:runAction(moveaction)
                    end
                )
            ))
        end
    end
    

    if addnum == 0 then
        return
    end
    for i=1,addnum do
        local pgold = cc.Sprite:create("Jetton/ChouMa_1.png")--cc.Sprite:createWithSpriteFrameName(string.format("bt_score_1_0.png")):setScale(0.33)
        pgold:setPosition(bankerheadpoint)
        pgold:setVisible(false)
        self.m_goldLayer:addChild(pgold)

        table.insert(self.m_goldList[cbArea + 1], pgold)
        pgold:runAction(cc.Sequence:create(cc.DelayTime:create(0.01*(i+fornum)), cc.CallFunc:create(
                function ()
                    local moveaction = self:getMoveAction(bankerheadpoint, self:getRandPos(self.m_JettonArea[cbArea]), 0, 1)
                    pgold:setVisible(true)
                    pgold:runAction(moveaction)
                end
            )
        ))
    end
end

--显示金币下注区域飞到玩家
function GameViewLayer:showGoldToUser()
    if self.m_cbGameStatus ~= Game_CMD.GAME_SCENE_END then
        return
    end
    for i=1,Game_CMD.AREA_COUNT do
        --表示该区域庄家输分
        if self.m_bUserOxCard[i+1] == 1 then
            local lJettonScore = self.m_lAllJettonScore[i+1]
            if lJettonScore > 0 then
                self:showGoldAreaToUser(i)
            end
        end
    end

    self:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(
            function ()
                self:showGameEnd()
            end
        )))
end

function GameViewLayer:showGoldAreaToUser(cbArea)
    ExternalFun.playSoundEffect("coinCollide.wav")
    local listnum = #self.m_goldList[cbArea + 1]
    local nmultiple = self.m_Multiple[cbArea + 1]
    local selfgoldnum = self:getWinGoldNum(self.m_lUserJettonScore[cbArea+1]*nmultiple)
    if self.m_lUserJettonScore[cbArea+1] == self.m_lAllJettonScore[cbArea+1] then
        selfgoldnum = listnum
    end
    --自己金币移动
    self:GoldMoveToUserDeal(cbArea, selfgoldnum, selfheadpoint)

    --坐下用户
    for i = 1, Game_CMD.MAX_OCCUPY_SEAT_COUNT do
        if nil ~= self.m_tabSitDownUser[i] then
            local seatJettonScore = self.m_tabSitDownUser[i]:getJettonScoreWithArea(cbArea)
            if seatJettonScore > 0 then
                local seatGoldNum = self:getWinGoldNum(seatJettonScore*nmultiple)
                print("坐下用户金币数", seatGoldNum)
                local endpos = cc.p(self.m_TableSeat[i]:getPosition())
                self:GoldMoveToUserDeal(cbArea, seatGoldNum, endpos)

                local chair = self.m_tabSitDownUser[i]:getChair()
                local score = self.m_lOccupySeatUserWinScore[1][i]
                local useritem = self:getDataMgr():getChairUserList()[chair + 1]
                --金币动画
                self.m_tabSitDownUser[i]:gameEndScoreChange(useritem, score)
            end 
        end
    end

    listnum = #self.m_goldList[cbArea + 1]
    self:GoldMoveToUserDeal(cbArea, listnum, userlistpoint)
end

function GameViewLayer:GoldMoveToUserDeal(cbArea, goldNum, endpos)
    local listnum = #self.m_goldList[cbArea + 1]
    if goldNum > listnum then
        goldnum = listnum
    end
    if goldnum == 0 then
        return
    end
    for i=1,goldNum do
        local pgold = self.m_goldList[cbArea+1][listnum-i+1]
        table.remove(self.m_goldList[cbArea+1], listnum-i+1)
        pgold:runAction(cc.Sequence:create(cc.DelayTime:create(i*0.01), cc.CallFunc:create(
                function ()
                    local moveaction = self:getMoveAction(cc.p(pgold:getPosition()), endpos, 1, 1)
                    pgold:runAction(cc.Sequence:create(moveaction, cc.CallFunc:create(
                            function ()
                                pgold:removeFromParent()
                            end
                        )))
                end
            )))
    end
end

--显示游戏结算
function GameViewLayer:showGameEnd(bRecord)
    if self.m_cbGameStatus ~= Game_CMD.GAME_SCENE_END then
        return
    end
    if bRecord == nil then
        local record = Game_CMD.getEmptyGameRecord()
        record.bWinTianMen = self.m_bUserOxCard[2] == 1 and true or false
        record.bWinDiMen = self.m_bUserOxCard[3] == 1 and true or false
        record.bWinXuanMen = self.m_bUserOxCard[4] == 1 and true or false
        record.bWinHuangMen = self.m_bUserOxCard[5] == 1 and true or false

        self:getDataMgr():addGameRecord(record)
        self:refreshGameRecord()
    end
    
    --表示未赢分
    local jettonscore = 0
    for i,v in ipairs(self.m_lUserJettonScore) do
        jettonscore = jettonscore + v
    end
    if self.m_lSelfWinScore == 0 and jettonscore == 0 then
        return
    end

    --自己是庄家
    local isBanker = self:isMeChair(self.m_wBankerUser)

    if nil == self.m_gameResultLayer then
        self.m_gameResultLayer = GameResultLayer:create(self)
        self:addToRootLayer(self.m_gameResultLayer, ZORDER_LAYER.ZORDER_Other_Layer)
    end
    self.m_gameResultLayer:showGameResult(self.m_lSelfWinScore, self.m_lBankerWinScore, self.m_tBankerName, isBanker)
end

--设置下注按钮是否可以点击
function GameViewLayer:setJettonEnable(value)
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

--更新下注按钮
--score：可以下注金额*MaxTimes
function GameViewLayer:updateJettonList(score)
    local btjettonscore = 0
    local judgeindex = 0
    if self.m_nJettonSelect == 0 then
        self.m_nJettonSelect = 2
    end
    for i=1,7 do
        btjettonscore = btjettonscore + GameViewLayer.m_BTJettonScore[i]
        local judgescore = btjettonscore*MaxTimes
        if judgescore > score then
            self.m_JettonBtn[i]:setEnabled(false)
        else
            self.m_JettonBtn[i]:setEnabled(true)
            judgeindex = i
        end
    end
    if self.m_nJettonSelect > judgeindex then
        if judgeindex == 1 then judgeindex = 0 end
        self.m_nJettonSelect = judgeindex
        if judgeindex == 0 then
            self:setJettonEnable(false)
        else
            self.m_JettonLight:setPosition(self.m_JettonBtn[judgeindex]:getPosition())
        end
    end
end

--更新下注分数显示
function GameViewLayer:updateAreaScore(bshow)
    if bshow == false then
        for k,v in pairs(self.m_tAllJettonScore) do
            v:setVisible(false)
        end
        for k,v in pairs(self.m_selfJettonBG) do
            v:setVisible(false)
        end
        self.remainder_note:setString("剩余下注数：0")
        self.m_tAllScoreTxt:setString((string.formatNumberThousands("0",true,":")))
        return
    end

    self.m_tAllScore = 0
    for i=1,4 do
        if self.m_lUserJettonScore[i+1] > 0 then
            self.m_selfJettonBG[i]:setVisible(true)
            local txt_score = self.m_selfJettonBG[i]:getChildByName("txt_score")
            local my_gold = string.gsub(string.formatNumberThousands(self.m_lUserJettonScore[i+1]), "%.00", "")
            txt_score:setString(my_gold)
        end
        if self.m_lAllJettonScore[i+1] > 0 then
            self.m_tAllJettonScore[i]:setVisible(true)
            local all_gold = string.gsub(string.formatNumberThousands(self.m_lAllJettonScore[i+1]), "%.00", "")
            self.m_tAllJettonScore[i]:setString(all_gold)
            self.m_tAllScore = self.m_tAllScore + self.m_lAllJettonScore[i+1]
        end
    end
    self.m_tAllScoreTxt:setString((string.formatNumberThousands(self.m_tAllScore,true,":")))
    local syxz = string.formatNumberThousands(self.m_lBankerScore/10 - self.m_tAllScore)
    syxz = string.gsub(syxz, "%.%d+", "")
    self.remainder_note:setString("剩余下注数："..syxz)

end

--刷新游戏记录
function GameViewLayer:refreshGameRecord()
    if nil ~= self.m_GameRecordLayer and self.m_GameRecordLayer:isVisible() then
        local recordList = self:getDataMgr():getGameRecord()     
        self.m_GameRecordLayer:refreshRecord(recordList)
    end
end

--刷新列表
function GameViewLayer:refreshApplyList(  )
    if nil ~= self.m_applyListLayer and self.m_applyListLayer:isVisible() then
        local userList = self:getDataMgr():getApplyBankerUserList()     
        self.m_applyListLayer:refreshList(userList)
    end
end

--刷新申请列表按钮状态
function GameViewLayer:refreshApplyBtnState(  )
    if nil ~= self.m_applyListLayer and self.m_applyListLayer:isVisible() then
        self.m_applyListLayer:refreshBtnState()
    end
end

--刷新用户列表
function GameViewLayer:refreshUserList(  )
    if nil ~= self.m_userListLayer and self.m_userListLayer:isVisible() then
        local userList = self:getDataMgr():getUserList()        
        self.m_userListLayer:refreshList(userList)
        self.peoplenum:setString(#userList)
        local refreshtime = 1
        for i=1,5 do
            if refreshtime == 5 then 
                return
            end
            if userList[i] then 
                if userList[i].wChairID ~= 0 then 
                    self.playheadbackground[refreshtime]:removeChildByName("playhead"..refreshtime)
                    self.playheadbackground[refreshtime]:show()
                    local playhead = PopupInfoHead:createNormal(userList[i], 71)
                    :addTo(self.playheadbackground[refreshtime])
                    :setName("playhead"..refreshtime)
                    -- :enableInfoPop(true, userheadpoint[i], cc.p(0, 1))
                    refreshtime = refreshtime + 1
                else
                end
            else
                self.playheadbackground[refreshtime]:hide()
                refreshtime = refreshtime + 1
            end
        end
    end
end

--刷新抢庄按钮
function GameViewLayer:refreshCondition(  )
    local applyable = self:getApplyable()
    if applyable then
        ------
        --超级抢庄

        --如果当前有超级抢庄用户且庄家不是自己
        if (yl.INVALID_CHAIR ~= self.m_wCurrentRobApply) or (true == self:isMeChair(self.m_wBankerUser)) then
            ExternalFun.enableBtn(self.m_btSupperRob, false)
        else
            local useritem = self:getMeUserItem()
            --判断抢庄类型
            if Game_CMD.SUPERBANKER_VIPTYPE == self.m_tabSupperRobConfig.superbankerType then
                --vip类型             
                ExternalFun.enableBtn(self.m_btSupperRob, useritem.cbMemberOrder >= self.m_tabSupperRobConfig.enVipIndex)
            elseif Game_CMD.SUPERBANKER_CONSUMETYPE == self.m_tabSupperRobConfig.superbankerType then
                --游戏币消耗类型(抢庄条件+抢庄消耗)
                local condition = self.m_tabSupperRobConfig.lSuperBankerConsume + self.m_llCondition
                ExternalFun.enableBtn(self.m_btSupperRob, useritem.lScore >= condition)
            end
        end     
    else
        ExternalFun.enableBtn(self.m_btSupperRob, false)
    end
end

--刷新用户分数
function GameViewLayer:onGetUserScore( useritem )
    --自己
    if useritem.dwUserID == GlobalUserItem.dwUserID then
        self.m_showScore = useritem.lScore
        self:resetSelfInfo()

    end

    --坐下用户
    for i = 1, Game_CMD.MAX_OCCUPY_SEAT_COUNT do
        if nil ~= self.m_tabSitDownUser[i] then
            if useritem.wChairID == self.m_tabSitDownUser[i]:getChair() then
                self.m_tabSitDownUser[i]:updateScore(useritem.lScore)
            end
        end
    end

    --庄家
    if self.m_wBankerUser == useritem.wChairID then
        --庄家金币
        self.m_lBankerScore = useritem.lScore
        self:resetBankerScore()
    end
end

--获取牛显示字体
function GameViewLayer:getNiuTxt(imagefile, niuvalue, pbg)
    local width = 56
    local height = 60
    local playout = ccui.Layout:create()
    playout:setAnchorPoint(0.5, 0.5) 
    -- 根据牛牛点数来给背景框
    if niuvalue == GameLogic.BRNN_CT_POINT then
        pbg:loadTexture("im_point_failed_bg.png", UI_TEX_TYPE_PLIST)
    elseif niuvalue > GameLogic.BRNN_CT_POINT and niuvalue < GameLogic.BRNN_CT_SPECIAL_NIU5 then
        pbg:loadTexture("im_point_win_bg.png", UI_TEX_TYPE_PLIST)
    elseif niuvalue > GameLogic.BRNN_CT_SPECIAL_NIU4 and niuvalue < GameLogic.BRNN_CT_SPECIAL_NIU8 then
        pbg:loadTexture("im_point_win_bg1.png", UI_TEX_TYPE_PLIST)
    elseif niuvalue > GameLogic.BRNN_CT_SPECIAL_NIU7 and niuvalue < GameLogic.BRNN_CT_SPECIAL_NIUNIU then
        pbg:loadTexture("im_point_win_bg2.png", UI_TEX_TYPE_PLIST) 
    elseif niuvalue > GameLogic.BRNN_CT_SPECIAL_NIU9 and niuvalue <= GameLogic.BRNN_CT_SPECIAL_BOMEBOME then
        pbg:loadTexture("im_point_win_bg3.png", UI_TEX_TYPE_PLIST)  
    end 
    -- 等于12小王牛或者13大王牛
    if niuvalue == GameLogic.BRNN_CT_SPECIAL_NIUNIUXW or niuvalue == GameLogic.BRNN_CT_SPECIAL_NIUNIUDW then
        playout:setContentSize(cc.size(width*3, height))
    else
        playout:setContentSize(cc.size(width*2, height))
    end

    -- 等于16炸弹
    if niuvalue == GameLogic.BRNN_CT_SPECIAL_BOMEBOME then
        local psprite = cc.Sprite:create(imagefile)
        psprite:setTextureRect(cc.rect(width*16, 0, width*2, height))
        psprite:setAnchorPoint(0.0, 0.5)
        psprite:setPosition(0, height/2)
        playout:addChild(psprite)
        return playout
    end

    local pniu = cc.Sprite:create(imagefile)
    pniu:setTextureRect(cc.rect(width*10, 0, width, height))
    pniu:setAnchorPoint(0.0, 0.5)

    -- 小于11牛牛
    if niuvalue <= GameLogic.BRNN_CT_SPECIAL_NIUNIU then
        local pnum = cc.Sprite:create(imagefile)
        pnum:setTextureRect(cc.rect((niuvalue-1)*width, 0, width, height))
        pnum:setAnchorPoint(0.0, 0.5)
        --等于1无牛
        if niuvalue == GameLogic.BRNN_CT_POINT then
            pnum:setPosition(0,height/2)
            pniu:setPosition(width,height/2)
            playout:addChild(pnum)
            playout:addChild(pniu)
            return playout
        end
        pnum:setPosition(width,height/2)
        pniu:setPosition(0,height/2)
        playout:addChild(pnum)
        playout:addChild(pniu)
        return playout
    -- 等于14银牛或者15金牛
    elseif niuvalue == GameLogic.BRNN_CT_SPECIAL_NIUYING or niuvalue == GameLogic.BRNN_CT_SPECIAL_NIUKING then
        local posx = niuvalue==GameLogic.BRNN_CT_SPECIAL_NIUYING and (niuvalue-2)*width or (niuvalue-4)*width
        local pnum = cc.Sprite:create(imagefile)
        pnum:setTextureRect(cc.rect(posx, 0, width, height))
        pnum:setAnchorPoint(0.0, 0.5)
        pnum:setPosition(0,height/2)
        pniu:setPosition(width,height/2)
        playout:addChild(pnum)
        playout:addChild(pniu)
        return playout
    -- 等于12小王牛或者13大王牛
    elseif niuvalue == GameLogic.BRNN_CT_SPECIAL_NIUNIUXW or niuvalue == GameLogic.BRNN_CT_SPECIAL_NIUNIUDW then
        local posx = niuvalue==GameLogic.BRNN_CT_SPECIAL_NIUNIUXW and (niuvalue+2)*width or (niuvalue)*width
        local pnum = cc.Sprite:create(imagefile)
        pnum:setTextureRect(cc.rect(posx, 0, width, height))
        pnum:setAnchorPoint(0.0, 0.5)
        local pwang = cc.Sprite:create(imagefile)
        pwang:setTextureRect(cc.rect(15*width, 0, width, height))
        pwang:setAnchorPoint(0.0, 0.5)
        pnum:setPosition(0,height/2)
        pwang:setPosition(width, height/2)
        pniu:setPosition(width*2,height/2)
        playout:addChild(pwang)
        playout:addChild(pnum)
        playout:addChild(pniu)
    end

    return playout
end

--获取下注显示金币个数
function GameViewLayer:getGoldNum(lscore)
    local goldnum = 1
    for i=1,7 do
        if lscore >= GameViewLayer.m_BTJettonScore[i] then
            goldnum = i
        end
    end
    return GameViewLayer.m_JettonGoldBaseNum[goldnum]
end

--获取输钱区域需要金币数
function GameViewLayer:getWinGoldNumWithAreaID(cbArea)
    local goldnum = 0
    local nmultiple = self.m_Multiple[cbArea + 1]
    local lAllJettonScore = self.m_lAllJettonScore[cbArea + 1]
    goldnum = goldnum + self:getWinGoldNum(self.m_lUserJettonScore[cbArea + 1]*nmultiple)
    --全是自己下注
    if self.m_lUserJettonScore[cbArea+1] == self.m_lAllJettonScore[cbArea + 1] then
        return goldnum
    end
    lAllJettonScore = lAllJettonScore - self.m_lUserJettonScore[cbArea+1]

    --坐下用户
    for i = 1, Game_CMD.MAX_OCCUPY_SEAT_COUNT do
        if nil ~= self.m_tabSitDownUser[i] then
            local seatJettonScore = self.m_tabSitDownUser[i]:getJettonScoreWithArea(cbArea)
            if seatJettonScore > 0 then
               goldnum = goldnum + self:getWinGoldNum(seatJettonScore*nmultiple)
               lAllJettonScore = lAllJettonScore - seatJettonScore
            end 
        end
    end

    if lAllJettonScore <= 0 then
        return goldnum
    end

    goldnum = goldnum + self:getWinGoldNum(lAllJettonScore*nmultiple)
    return goldnum
end

--获取赢钱需要金币数
function GameViewLayer:getWinGoldNum(lscore)
    if lscore == 0 then
        return 0
    end
    local goldnum = 0
    for i=1,7 do
        if lscore >= GameViewLayer.m_BTJettonScore[i] then
            goldnum = i
        end
    end
    return GameViewLayer.m_WinGoldBaseNum[goldnum]
end

--获取随机显示位置
function GameViewLayer:getRandPos(nodeArea)
    local beginpos = cc.p(nodeArea:getPositionX()-80, nodeArea:getPositionY()-100)

    local offsetx = math.random()
    local offsety = math.random()

    return cc.p(beginpos.x + offsetx*160, beginpos.y + offsety*130)
end

--获取移动动画
--inorout,0表示加速飞出,1表示加速飞入
--isreverse,0表示不反转,1表示反转
function GameViewLayer:getMoveAction(beginpos, endpos, inorout, isreverse)
    local offsety = (endpos.y - beginpos.y)*0.7
    local controlpos = cc.p(beginpos.x, beginpos.y+offsety)
    if isreverse == 1 then
        offsety = (beginpos.y - endpos.y)*0.7
        controlpos = cc.p(endpos.x, endpos.y+offsety)
    end
    local bezier = {
        controlpos,
        endpos,
        endpos
    }
    local beaction = cc.MoveTo:create(0.42, endpos) --原先动画cc.BezierTo:create(0.42, bezier)
    if inorout == 0 then
        return cc.EaseOut:create(beaction, 1)
    else
        return cc.EaseIn:create(beaction, 1)
    end
end

--判断该用户是否坐下
function GameViewLayer:getIsUserSit(wChair)
    for i = 1, Game_CMD.MAX_OCCUPY_SEAT_COUNT do
        if nil ~= self.m_tabSitDownUser[i] then
            if wChair == self.m_tabSitDownUser[i]:getChair() then
                return self.m_tabSitDownUser[i]
            end
        end
    end
    return nil
end

--上庄状态
function GameViewLayer:applyBanker( state )
    if state == APPLY_STATE.kCancelState then
        self:getParentNode():sendApplyBanker()      
    elseif state == APPLY_STATE.kApplyState then
        self:getParentNode():sendCancelApply()
    elseif state == APPLY_STATE.kApplyedState then
        self:getParentNode():sendCancelApply()      
    end
end

------
--银行节点
function GameViewLayer:createBankLayer()
    self.m_bankLayer = cc.Node:create()
    self:addToRootLayer(self.m_bankLayer, ZORDER_LAYER.ZORDER_Other_Layer)

    --加载csb资源
    local csbNode = ExternalFun.loadCSB("BankLayer.csb", self.m_bankLayer)
    local sp_bg = csbNode:getChildByName("sp_bg")

    ------
    --按钮事件
    local function btnEvent( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            self:onButtonClickedEvent(sender:getTag(), sender)
        end
    end 
    --关闭按钮
    local btn = sp_bg:getChildByName("close_btn")
    btn:setTag(TAG_ENUM.BT_CLOSEBANK)
    btn:addTouchEventListener(btnEvent)

    local layout_bg = csbNode:getChildByName("layout_bg")
    layout_bg:setTag(TAG_ENUM.BT_CLOSEBANK)
    layout_bg:addTouchEventListener(btnEvent)

    --取款按钮
    btn = sp_bg:getChildByName("out_btn")
    btn:setTag(TAG_ENUM.BT_TAKESCORE)
    btn:addTouchEventListener(btnEvent)
    ------

    ------
    --编辑框
    --取款金额
    local tmp = sp_bg:getChildByName("count_temp")
    local editbox = ccui.EditBox:create(tmp:getContentSize(),"im_bank_edit.png",UI_TEX_TYPE_PLIST)
        :setPosition(tmp:getPosition())
        :setFontName("fonts/round_body.ttf")
        :setPlaceholderFontName("fonts/round_body.ttf")
        :setFontSize(24)
        :setPlaceholderFontSize(24)
        :setMaxLength(32)
        :setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
        :setPlaceHolder("请输入取款金额")
    sp_bg:addChild(editbox)
    self.m_bankLayer.m_editNumber = editbox
    tmp:removeFromParent()

    --取款密码
    tmp = sp_bg:getChildByName("passwd_temp")
    editbox = ccui.EditBox:create(tmp:getContentSize(),"im_bank_edit.png",UI_TEX_TYPE_PLIST)
        :setPosition(tmp:getPosition())
        :setFontName("fonts/round_body.ttf")
        :setPlaceholderFontName("fonts/round_body.ttf")
        :setFontSize(24)
        :setPlaceholderFontSize(24)
        :setMaxLength(32)
        :setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
        :setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
        :setPlaceHolder("请输入取款密码")
    sp_bg:addChild(editbox)
    self.m_bankLayer.m_editPasswd = editbox
    tmp:removeFromParent()
    ------

    --当前游戏币
    self.m_bankLayer.m_textCurrent = sp_bg:getChildByName("text_current")

    --银行游戏币
    self.m_bankLayer.m_textBank = sp_bg:getChildByName("text_bank")

    --取款费率
    self.m_bankLayer.m_textTips = sp_bg:getChildByName("text_tips")
    self:getParentNode():sendRequestBankInfo()
end

--取款
function GameViewLayer:onTakeScore()
    --参数判断
    local szScore = string.gsub(self.m_bankLayer.m_editNumber:getText(),"([^0-9])","")
    local szPass = self.m_bankLayer.m_editPasswd:getText()

    if #szScore < 1 then 
        showToast(self,"请输入操作金额！",2)
        return
    end

    local lOperateScore = tonumber(szScore)
    if lOperateScore<1 then
        showToast(self,"请输入正确金额！",2)
        return
    end

    if #szPass < 1 then 
        showToast(self,"请输入银行密码！",2)
        return
    end
    if #szPass <6 then
        showToast(self,"密码必须大于6个字符，请重新输入！",2)
        return
    end

    self:showPopWait()  
    self:getParentNode():sendTakeScore(szScore,szPass)
end

--刷新银行金币
function GameViewLayer:refreshBankScore( )
    --携带游戏币
    local str = ExternalFun.numberThousands(GlobalUserItem.lUserScore)
    if string.len(str) > 19 then
        str = string.sub(str, 1, 19)
    end
    self.m_bankLayer.m_textCurrent:setString(str)

    --银行存款
    str = ExternalFun.numberThousands(GlobalUserItem.lUserInsure)
    if string.len(str) > 19 then
        str = string.sub(str, 1, 19)
    end
    self.m_bankLayer.m_textBank:setString(ExternalFun.numberThousands(GlobalUserItem.lUserInsure))

    self.m_bankLayer.m_editNumber:setText("")
    self.m_bankLayer.m_editPasswd:setText("")
end
--记录押注
function GameViewLayer:Record_bet(tag, m_nJettonSelect)
    if tag >= 0 and tag <= 3 and m_nJettonSelect >= 0 and m_nJettonSelect <= 6 then 
        table.insert(self.continued_detention[tag+1], m_nJettonSelect)
    else
        print("输入的数据不合法")
        return
    end
end

--续押按钮
function GameViewLayer:continuedDetentionClicked(ref)
    if ref == nil then print("没有传入参数") return end
    ExternalFun.playSoundEffect("BT_CLICK.mp3")
    dump(self.bets_on_the_board, "上一局押注的金币", 10)
    for k,v in pairs(self.bets_on_the_board) do
        if #v > 0 then 
            for i,j in pairs(v) do
                self:onJettonAreaClick(k, j) 
            end
        end
    end  
    ref:setEnabled(false)
end

--更新上一局下注的金币数
function GameViewLayer:RefreshStakeNum()
    local isnil = 0
    for j=1,4 do
        if #self.continued_detention[j] == 0 then isnil = isnil+1 end
    end
    if isnil == 4 then 
        self.continued_detention = {{},{},{},{}} 
        return
    end
    for i=1,4 do
        self.bets_on_the_board[i] = self.continued_detention[i]
    end
    self.continued_detention = {{},{},{},{}} 
end

--获取上一局押注的金额总数
function GameViewLayer:getAllBetNum()
    local allbetnum = 0
    for i=1,4 do
        if #self.bets_on_the_board[i] > 0 then
            for k,v in pairs(self.bets_on_the_board[i]) do
                allbetnum = allbetnum + self.m_BTJettonScore[v+1]
            end
        end
    end
    return allbetnum
end
--设置续押按钮是否可以点击
function GameViewLayer:setXybtnEnable(value)
    if value then
        local isnil = 0
        for j=1,4 do
            if #self.bets_on_the_board[j] == 0 then isnil = isnil+1 end
        end
        if isnil ~= 4 then 
            self.xy_btn:setEnabled(true)
        else
            self.xy_btn:setEnabled(false)
        end
    else
        self.xy_btn:setEnabled(value)
    end
end

function GameViewLayer:onJettonAreaClick(tag, num)
    --非下注状态
    if self.m_cbGameStatus ~= Game_CMD.GAME_SCENE_JETTON or self.m_nJettonSelect == 0 or self.m_nJettonSelect == 1 then
        return
    end

    if self:isMeChair(self.m_wBankerUser) == true then 
        return
    end
    
    if self.m_bEnableSysBanker == 0 and self.m_wBankerUser == yl.INVALID_CHAIR then
        showToast(self,"无人坐庄，不能下注",1) 
        return
    end

    local jettonscore = GameViewLayer.m_BTJettonScore[num+1]
    --
    local selfscore  = (jettonscore + self.m_lUserAllJetton)*MaxTimes
    if  selfscore > self.m_lUserMaxScore then
        showToast(self,"已超过个人最大下注值",1)
        return
    end

    local areascore = self.m_lAllJettonScore[tag+1] + jettonscore
    if areascore > self.m_lAreaLimitScore then
        showToast(self,"已超过该区域最大下注值",1)
        return
    end

    if self.m_wBankerUser ~= yl.INVALID_CHAIR then
        local allscore = jettonscore
        for k,v in pairs(self.m_lAllJettonScore) do
            allscore = allscore + v
        end
        allscore = allscore*MaxTimes
        if allscore > self.m_lBankerScore then
            showToast(self,"总下注已超过庄家下注上限",1)
            return
        end
    end
    
    self.m_lUserAllJetton = self.m_lUserAllJetton + jettonscore
    self:updateJettonList(self.m_lUserMaxScore - self.m_lUserAllJetton*MaxTimes)
    local userself = self:getMeUserItem()   
    self:getParentNode():SendPlaceJetton(self.m_BTJettonScore[num+1], tag)
end

function GameViewLayer:placePlayerHead()
    local userList = self:getDataMgr():getUserList() 
    for i=1,4 do
        self.playheadbackground[i] = HeadBackground:create()
        :setPosition(userheadpoint[i])
        :setVisible(false)
        self:addToRootLayer(self.playheadbackground[i], 0)
    end 
    local refreshtime = 1
    for i=1,5 do
        if refreshtime == 5 then 
            return
        end
        if userList[i] then 
            if userList[i].wChairID ~= 0 then 
                self.playheadbackground[refreshtime]:removeChildByName("playhead"..refreshtime)
                local playhead = PopupInfoHead:createNormal(userList[i], 71)
                :addTo(self.playheadbackground[refreshtime])
                :setName("playhead"..refreshtime)
                -- :enableInfoPop(true, userheadpoint[i], cc.p(0, 1))
                refreshtime = refreshtime + 1
            else
            end
        else
            self.playheadbackground[refreshtime]:hide()
            refreshtime = refreshtime + 1
        end
    end      
end

--用户聊天
function GameViewLayer:userChat(isMe, nick, chatstr)
    if not self.chatMsg or not self.chatMsg.onUserChat then
        return
    end
    self.chatMsg:onUserChat(isMe,nick,chatstr)
end

--用户表情
function GameViewLayer:userExpression(nick, index)
    if not self.chatMsg or not self.chatMsg.onUserExpression  then
        return
    end

    self.chatMsg:onUserExpression(nick,index)
end

return GameViewLayer