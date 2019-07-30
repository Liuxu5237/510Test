--                            _ooOoo_
--                           o8888888o
--                           88" . "88
--                           (| -_- |)
--                            O\ = /O
--                        ____/`---'\____
--                      .   ' \\| |// `.
--                      / \\||| : |||// \
--                     / _||||| -:- |||||- \
--                       | | \\\ - /// | |
--                     | \_| ''\---/'' | |
--                      \ .-\__ `-` ___/-. /
--                   ___`. .' /--.--\ `. . __
--                ."" '< `.___\_<|>_/___.' >'"".
--               | | : `- \`.;`\ _ /`;.`/ - ` : | |
--                 \ \ `-. \_ __\ /__ _/ .-` / /
--         ======`-.____`-.___\_____/___.-`____.-'======
--                            `=---='
--
--         .............................................
--                  佛祖保佑             永无BUG 
local GameModel = appdf.req(appdf.CLIENT_SRC .. "gamemodel.GameModel")
local GameLayer = class("GameLayer", GameModel)
local cmd = appdf.req(appdf.GAME_SRC .. "yule.dzshowhand.src.models.CMD_Game")
local GameLogic = appdf.req(appdf.GAME_SRC .. "yule.dzshowhand.src.models.GameLogic")
local GameViewLayer = appdf.req(appdf.GAME_SRC .. "yule.dzshowhand.src.views.layer.GameViewLayer")
local GameEndView = appdf.req(appdf.GAME_SRC .. "yule.dzshowhand.src.views.layer.GameEndView")
local QueryDialog = appdf.req("base.src.app.views.layer.other.QueryDialog")
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local GameServer_CMD = appdf.req(appdf.HEADER_SRC.."CMD_GameServer")
local SoundManager = appdf.req(appdf.GAME_SRC.."yule.dzshowhand.src.views.layer.SoundManager")

-- 全局变量定义
INVALID_CHAIR = yl.INVALID_CHAIR
TRUE = 1
FALSE = 0
IDI_START_GAME = cmd.IDI_START_GAME
IDI_USER_ADD_SCORE = cmd.IDI_USER_ADD_SCORE
IDI_GAME_END_DELAY = cmd.IDI_GAME_END_DELAY
TIME_START_GAME = cmd.TIME_START_GAME
TIME_USER_ADD_SCORE = cmd.TIME_USER_ADD_SCORE
SW_HIDE = false
SW_SHOW = true

-- 按钮tag
BT_EXIT = 0xF1
BT_READY = 0xF2
BT_GIVEUP = 0xF3
BT_FOLLOW = 0xF4
BT_ADD = 0xF5
BT_SHOWHAND = 0xF6
BT_PASS = 0xF7
BT_CHAT = 0xF8
BT_SET = 0xF9
BT_GOLDCONTROL = 0xFA
BT_CHANGESEAT  = 0xFB
BT_RULE = 0xFC
BT_BANK = 0xFD
BT_MENU = 0xFE
BT_OPERATOR_INFO = {
    [BT_GIVEUP] = "弃牌",
    [BT_FOLLOW] = "跟注",
    [BT_ADD] = "加注",
    [BT_SHOWHAND] = "全下",
    [BT_PASS] = "让牌",
}

-- 动画参数
TO_USERCARD = 1     -- 用户扑克
TO_GIVEUP_CARD = 2     -- 回收扑克
TO_CENTER_CARD = 3     -- 中心扑克
TO_SHOWUSERCARD = 4    -- 显示用户扑克
TO_SHOWCENTER_CARD = 5 -- 显示中心扑克
-- 移动类型
AA_BASEFROM_TO_BASEDEST = 0     -- 底注筹码下注
AA_BASEDEST_TO_CENTER = 1     -- 加注筹码移至中间
AA_CENTER_TO_BASEFROM = 2     -- 中加筹码移至底注
AA_NIL                = 3     -- 下注类型为nil

-- 游戏变量
GameScenecCount = 0
m_wMinChipInUser = 0       -- 小盲注
m_wCurrentUser = 0       -- 当前玩家
m_wBankerUser = 0       -- 庄家用户
m_lAddLessScore = 0       -- 加最小注
m_lTurnLessScore = 0       -- 最小下注
m_lTurnMaxScore = 0       -- 最大下注
m_lCellScore = 0       -- 单元下注
m_lCellMaxScore = 0       -- 单元最大下注
m_lTableScore = { }      -- 下注数目
m_lTotalScore = { }      -- 累计下注
m_lCenterScore = 0       -- 中心筹码
m_lBalanceScore = 0       -- 平衡筹码
m_cbPlayStatus = { }      -- 游戏状态
m_bAutoStart = false   -- 自动开始
m_dEndScore = { }      -- 结束分数
m_lRoundTotalScore = 0  --一轮的下注累计
m_cbCenterCardData = { }      -- 中心扑克 m_cbCenterCardData[MAX_CENTERCOUNT]

AddScoreMultiple = { 1, 3, 5, 10, 20 }   -- 加注选择
m_cbHandCardData = {
    { },{ },{ },{ },{ },{ },{ },{ },
}     -- 手上扑克 m_cbHandCardData[GAME_PLAYER][MAX_COUNT]
m_cbOverCardData = {
    { },{ },{ },{ },{ },{ },{ },{ },
}     -- 结束扑克 m_cbOverCardData[GAME_PLAYER][MAX_CENTERCOUNT]
m_cbEndCardKind = { 0, 0, 0, 0, 0, 0, 0, 0 }
m_cbEndCardKindView = { "单牌", "对子", "两对", "三条", "顺子", "同花", "葫芦", "四条", "同花顺", "皇家同花顺" }
-- *******************游戏数据函数************************--
-- 初始化界面
function GameLayer:ctor(frameEngine, scene)
    GameLayer.super.ctor(self, frameEngine, scene)
    self._soundManager = SoundManager:create()
end

-- 创建场景
function GameLayer:CreateView()
    cc.FileUtils:getInstance():addSearchPath(device.writablePath .. cmd.RES)
    return GameViewLayer:create(self)
    :addTo(self)
end

-- 初始化游戏数据
function GameLayer:OnInitGameEngine()
    GameLayer.super.OnInitGameEngine(self)
    GameScenecCount = 0
end

-- 重置游戏数据
function GameLayer:OnResetGameEngine()
    GameLayer.super.OnResetGameEngine(self)

    self._gameView:OnResetView()

    --m_wMinChipInUser = INVALID_CHAIR
    -- 小盲注
    m_wCurrentUser = INVALID_CHAIR
    -- 当前玩家
    m_wBankerUser = INVALID_CHAIR
    -- 庄家用户
    m_lAddLessScore = 0
    -- 加最小注
    m_lTurnLessScore = 0
    -- 最小下注
    m_lTurnMaxScore = 0
    -- 最大下注
    m_lCellScore = 0
    -- 单元下注
    m_lTableScore = {
        0,0,0,0,0,0,0,0
    }
    -- 下注数目
    m_lTotalScore = {
        0,0,0,0,0,0,0,0
    }
    -- 累计下注
    m_lCenterScore = 0
    -- 中心筹码
    m_lBalanceScore = 0
    -- 平衡筹码
    m_cbPlayStatus = {
        0,0,0,0,0,0,0,0
    }
    -- 游戏状态
    m_bAutoStart = false
    -- 自动开始
    m_dEndScore = {
        0,0,0,0,0,0,0,0
    }
    -- 结束分数
    m_cbCenterCardData = {
        0,0,0,0,0
    }
    -- 中心扑克 m_cbCenterCardData[MAX_CENTERCOUNT]
    m_cbHandCardData = {
        { },{ },{ },{ },{ },{ },{ },{ },
    }
    -- 手上扑克 m_cbHandCardData[GAME_PLAYER][MAX_COUNT]
    m_cbOverCardData = {
        { },{ },{ },{ },{ },{ },{ },{ },
    }
    m_cbEndCardKind = { 0, 0, 0, 0, 0, 0, 0, 0 }
    -- 发牌状态
    self.cbGameStatus = false
end

-- *******************游戏流程函数********************--
-- 场景信息 断线重连
function GameLayer:onEventGameScene(cbGameStatus, dataBuffer)
    GameScenecCount = GameScenecCount + 1
    if GameScenecCount > 1 then
        GameScenecCount = 0
        return
    end
    self.m_cbGameStatus = cbGameStatus
    -- 初始化已有玩家
    local Temp = nil
    for i = 1, ((cmd).GAME_PLAYER) do
        local userItem = self._gameFrame:getTableUserItem(self._gameFrame:GetTableID(), i - 1)
        local nViewID = self:SwitchViewChairID(i - 1)
        self._gameView:OnUpdateUser(nViewID, userItem)
    end

    -- 空闲状态
    if cbGameStatus == cmd.GAME_STATUS_FREE then

        local pStatusFree = ExternalFun.read_netdata(cmd.CMD_S_StatusFree, dataBuffer)
        dump(pStatusFree)
        -- 设置变量
        m_lTurnLessScore = pStatusFree.lCellMinScore;
        m_lTurnMaxScore = pStatusFree.lCellMaxScore;

        -- 设置游戏初始积分
        for i = 1, ((cmd).GAME_PLAYER) do
            self._gameView:SetGameInitScore(i - 1, 0)
            self._gameView:SetTotalScore(i - 1, 0)
            self._gameView:SetCurUserMaxScore(i-1,pStatusFree.lTakeMoney[1][i])
            self._gameView:SetUserTableScore(i - 1, 0)
        end
        -- 隐藏所有的操作按钮
        self:HideScoreControl()
        -- 显示准备按钮

        if not GlobalUserItem.isAntiCheat() then
            self._gameView._BtnReady:setVisible(self:GetMeUserItem().cbUserStatus == yl.US_SIT)
                -- 私人房无倒计时
            if not GlobalUserItem.bPrivateRoom then
                -- 设置倒计时
                self:SetGameClock(self:GetMeChairID(),cmd.IDI_START_GAME,cmd.TIME_START_GAME)
            end   
        end

        -- 游戏状态
    elseif cbGameStatus == cmd.GAME_STATUS_PLAY then

    --隐藏准备按钮
      self._gameView._BtnReady:setVisible(false)
        local CMD_S_StatusPlay = ExternalFun.read_netdata(cmd.CMD_S_StatusPlay, dataBuffer)
        dump(CMD_S_StatusPlay)
        -- 加注信息
        m_lCellScore = CMD_S_StatusPlay.lCellScore
        m_lAddLessScore = CMD_S_StatusPlay.lAddLessScore
        m_lTurnLessScore = CMD_S_StatusPlay.lTurnLessScore
        m_lTurnMaxScore = CMD_S_StatusPlay.lTurnMaxScore
        m_lCellMaxScore = CMD_S_StatusPlay.lCellMaxScore

        local TableAllScore = 0
        for i = 1, ((cmd).GAME_PLAYER) do
            local wChairID = i - 1
            TableAllScore = TableAllScore + CMD_S_StatusPlay.lTotalScore[1][i]
            m_lTotalScore[i] = CMD_S_StatusPlay.lTotalScore[1][i]
            m_lTableScore[i] =  CMD_S_StatusPlay.lTableScore[1][i]
            -- 设置累计下注
            self._gameView:SetTotalScore(wChairID, CMD_S_StatusPlay.lTotalScore[1][i])
            -- 设置当前下注
            self._gameView:SetUserTableScore(wChairID, CMD_S_StatusPlay.lTableScore[1][i])
            -- 设置游戏初始积分
            self._gameView:SetGameInitScore(i - 1, CMD_S_StatusPlay.lTakeMoney[1][i])
            --设置用户携带积分
            self._gameView:SetCurUserMaxScore(i-1,CMD_S_StatusPlay.lTakeMoney[1][i])
        end
         -- 设置底分
        self._gameView:SetCellScore(m_lCellScore)
        -- 设置中心分数
        self._gameView:SetCenterScore(TableAllScore)

        -- 加注倍数
        -- self._gameView:UpdataAddScoreMultiple(m_lAddLessScore-m_lCellScore, AddScoreMultiple)
        -- 状态信息
        -- 庄家
        self._gameView:SetDFlag(CMD_S_StatusPlay.wDUser, true)
        -- 小盲
        --m_wMinChipInUser = CMD_S_StatusPlay.wMinChipInUser
        -- 当前用户
        m_wCurrentUser = CMD_S_StatusPlay.wCurrentUser
        -- 用户状态
        for i = 1, ((cmd).GAME_PLAYER) do
            m_cbPlayStatus[i] = CMD_S_StatusPlay.cbPlayStatus[i]
        end

        -- 扑克信息
        -- 设置手牌
        for i = 1, ((cmd).GAME_PLAYER) do
            for j = 1, ((cmd).MAX_COUNT) do
                if m_cbPlayStatus[1][i] == TRUE then
                    local wChairID = i - 1
                    if self:GetMeChairID() == wChairID then
                        self._gameView:DrawMoveCard(wChairID, TO_SHOWUSERCARD, CMD_S_StatusPlay.cbHandCardData[1][j])
                    else
                        self._gameView:DrawMoveCard(wChairID, TO_SHOWUSERCARD, 0x00)
                    end
                end
            end
        end

        --  设置中心扑克
        for i = 1, #CMD_S_StatusPlay.cbCenterCardData[1] do
            if CMD_S_StatusPlay.cbCenterCardData[1][i] == 0x00 then
                break
            end
            self._gameView:DrawMoveCard(((cmd).GAME_PLAYER), TO_SHOWCENTER_CARD, CMD_S_StatusPlay.cbCenterCardData[1][i])
        end

        
        if m_wCurrentUser == self:GetMeChairID() then
           self:UpdateScoreControl()
        else
           self:HideScoreControl()
        end
        -- 设置时钟
        self:SetGameClock(m_wCurrentUser, cmd.IDI_USER_ADD_SCORE, cmd.TIME_USER_ADD_SCORE)
    end
    -- 刷新房卡
    if PriRoom and GlobalUserItem.bPrivateRoom then
        if nil ~= self._gameView._priView and nil ~= self._gameView._priView.onRefreshInfo then
            self._gameView._priView:onRefreshInfo()
        end
    end
    self:dismissPopWait()
end

-- 游戏开始
function GameLayer:OnSubGameStart(dataBuffer)
    print(dataBuffer:getlen())
    local pGameStart = ExternalFun.read_netdata(cmd.CMD_S_GameStart, dataBuffer)
    dump(pGameStart)
    self.cbGameStatus = true
    self.m_cbGameStatus = cmd.GAME_STATUS_PLAY
    -- 设置变量
    --m_wMinChipInUser = pGameStart.wMinChipInUser
    pGameStart.wMinChipInUser = 0
    m_wCurrentUser = pGameStart.wCurrentUser
    m_lAddLessScore = pGameStart.lAddLessScore
    m_lTurnLessScore = pGameStart.lTurnLessScore
    m_lTurnMaxScore = pGameStart.lTurnMaxScore
    m_lCellScore = pGameStart.lCellScore

    -- 加注信息
    m_lTableScore[pGameStart.wMinChipInUser + 1] = m_lTableScore[pGameStart.wMinChipInUser + 1] + m_lCellScore
    m_lTableScore[pGameStart.wMaxChipInUser + 1] = 2 * m_lCellScore
    m_lTotalScore[pGameStart.wMinChipInUser + 1] = m_lCellScore
    m_lTotalScore[pGameStart.wMaxChipInUser + 1] = 2 * m_lCellScore

    -- 设置界面
    self._gameView:SetDFlag(pGameStart.wDUser, true)
--    self._gameView:DrawMoveAnte(pGameStart.wMinChipInUser, AA_BASEFROM_TO_BASEDEST, m_lTotalScore[pGameStart.wMinChipInUser + 1])
--    self._gameView:DrawMoveAnte(pGameStart.wMaxChipInUser, AA_BASEFROM_TO_BASEDEST, m_lTotalScore[pGameStart.wMaxChipInUser + 1])
--    self._gameView:SetTotalScore(pGameStart.wMinChipInUser, m_lTotalScore[pGameStart.wMinChipInUser + 1])
--    self._gameView:SetTotalScore(pGameStart.wMaxChipInUser, m_lTotalScore[pGameStart.wMaxChipInUser + 1])

    -- 用户状态
    for i = 1, ((cmd).GAME_PLAYER) do
        -- 获取用户
        local userItem = self:getUserInfoByChairID(i - 1)
        -- 读取游戏状态
        m_cbPlayStatus[i] =(userItem == nil and FALSE or TRUE)
        -- 设置游戏积分显示
        self._gameView:SetCurUserMaxScore(i-1,pGameStart.lTakeMoney[1][i])
        self._gameView:SetGameInitScore(i - 1, pGameStart.lTakeMoney[1][i])
        self._gameView:SetTotalScore(i - 1,m_lTotalScore[i])
        self._gameView:SetUserTableScore(i - 1, m_lTableScore[i])
        self._gameView:DrawMoveAnte(i-1, AA_BASEFROM_TO_BASEDEST, m_lTotalScore[i])
    end

    -- 设置底分
    self._gameView:SetCellScore(m_lCellScore)

    -- 加注倍数选择
    -- self._gameView:UpdataAddScoreMultiple(m_lAddLessScore-1, AddScoreMultiple)
    -- 总计下注
    local lTotalScore = 0
    for i = 1, ((cmd).GAME_PLAYER) do
        lTotalScore = lTotalScore + m_lTableScore[i]
    end

    -- 设置中心分数
    self._gameView:SetCenterScore(lTotalScore)

    --初始化玩家信息
    for i=1,((cmd).GAME_PLAYER) do
        local userItem = self:getUserInfoByChairID(i - 1)
        if m_cbPlayStatus[i] == TRUE then
            local wChairID = i - 1
            self._gameView:OnUpdateUser(self:SwitchViewChairID(wChairID), userItem)
        end
        
    end

    -- 设置手牌
    m_cbHandCardData = pGameStart.cbCardData
    for j = 1, 2 do
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3*j),cc.CallFunc:create(function()
            local userCount = 0
            for i = 1, ((cmd).GAME_PLAYER) do
                local userItem = self:getUserInfoByChairID(i - 1)
                if m_cbPlayStatus[i] == TRUE then
                    local wChairID = i - 1
                    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1+0.1*userCount),cc.CallFunc:create(function ( )
                        self._gameView:DrawMoveCard(wChairID, TO_USERCARD, m_cbHandCardData[i][j])
                        userCount = userCount+1
                    end)))
                end
            end

        end)))
        
    end

    -- 设置时钟
    self:SetGameClock(m_wCurrentUser, cmd.IDI_USER_ADD_SCORE, cmd.TIME_USER_ADD_SCORE)

    -- 播放游戏开始音效
    self:PlaySound(cmd.RES .. "sound_res/GAME_START.wav")

    -- 刷新房卡
    if PriRoom and GlobalUserItem.bPrivateRoom then
        if nil ~= self._gameView._priView and nil ~= self._gameView._priView.onRefreshInfo then
            PriRoom:getInstance().m_tabPriData.dwPlayCount = PriRoom:getInstance().m_tabPriData.dwPlayCount + 1
            self._gameView._priView:onRefreshInfo()
        end
    end
end
--退出桌子
function GameLayer:onExitTable()
    self:KillGameClock()
    local MeItem = self:GetMeUserItem()
    if MeItem and MeItem.cbUserStatus > yl.US_FREE then
        self:showPopWait()
        self:runAction(cc.Sequence:create(
            cc.CallFunc:create(
                function () 
                    self._gameFrame:StandUp(1)
                end
                ),
            cc.DelayTime:create(10),
            cc.CallFunc:create(
                function ()
                    print("delay leave")
                    self:onExitRoom()
                end
                )
            )
        )
        return
    end

   self:onExitRoom()
end

--离开房间
function GameLayer:onExitRoom()
    self._scene:onKeyBack()
end

-- 游戏结束
function GameLayer:OnSubGameEnd(dataBuffer)
    self._soundManager:playEffectCommon(9)
    local pGameEnd = ExternalFun.read_netdata(cmd.CMD_S_GameEnd, dataBuffer)
    dump(pGameEnd)
    -- 积分信息
    m_dEndScore = pGameEnd.lGameScore[1]
    m_cbHandCardData = pGameEnd.cbCardData
    m_cbOverCardData = pGameEnd.cbLastCenterCardData


    self:HideScoreControl()
    self:KillGameTimer()

    -- 开牌标志
    m_bOpenCard = false

    -- 桌面金币移至中间
    for i = 1, ((cmd).GAME_PLAYER) do
        local wChairID = i - 1
        if m_lTableScore[i] > 0 and m_cbPlayStatus[i] == TRUE then
            --self._gameView:DrawMoveAnte(wChairID, AA_BASEDEST_TO_CENTER, m_lTableScore[i])
        end
        m_cbEndCardKind[i] = pGameEnd.cbLastCardKind[1][i]
        -- 开牌显示
        self._gameView:SetCardData(wChairID, m_cbHandCardData[i])
        self._gameView:setUserCardVisible(wChairID,false) --结算时影藏玩家手牌
    end

    -- 显示赢状态
    for i = 1, ((cmd).GAME_PLAYER) do
        local wChairID = i - 1
--        if m_cbPlayStatus[i] == TRUE then
--            if( pGameEnd.lGameScore[1][i]>0) then
--               self._gameView:WinerFlag(wChairID, "你赢了")
--            end
--        end
         self._gameView:SetGameInitScore(wChairID, pGameEnd.lTakeMoney[1][i])
         self._gameView:SetDFlag(wChairID, false)
    end
    self:OnGameOver()
    --    --延时定时器
    --    if pGameEnd.cbDelayOverGame > 0 then
    --        self:SetGameClock(self:GetMeChairID(), IDI_GAME_END_DELAY, pGameEnd.cbDelayOverGame)
    --    else
    --        self:SetGameClock(self:GetMeChairID(), IDI_GAME_END_DELAY, 2)
    --       --self:OnGameOver()
    --    end
end

-- 发送准备
function GameLayer:onStartGame(bReady)
    self:OnResetGameEngine()
    if bReady == true then
        self:SendUserReady()
        self.m_bStartGame = true
    end
end

-- 发牌结束
function GameLayer:OnSendFinish()
    if m_wCurrentUser == self:GetMeChairID() then
        self:UpdateScoreControl()
    end
    if m_wCurrentUser < ((cmd).GAME_PLAYER) then
        self:KillGameClock(IDI_USER_ADD_SCORE)
        self:SetGameClock(m_wCurrentUser, IDI_USER_ADD_SCORE, TIME_USER_ADD_SCORE)
    end
end

-- 游戏结束
function GameLayer:OnGameOver()
    -- 开牌按钮
    if m_bOpenCard then
        -- m_GameClientView.m_btOpenCard.ShowWindow(SW_SHOW);
    end

    -- 状态设置
    self:KillGameClock(IDI_USER_ADD_SCORE)

    -- 成绩显示在即时聊天对话框
    local tGameEnd = { }
    tGameEnd.tEndScore = m_dEndScore
    tGameEnd.tHandCardOver = m_cbOverCardData
    tGameEnd.tCardType = m_cbEndCardKind
    tGameEnd.userItem = { }
    tGameEnd.tHandCard = m_cbHandCardData
    for i = 1, ((cmd).GAME_PLAYER) do
        tGameEnd.userItem[i] = self._gameFrame:getTableUserItem(self:GetMeTableID(), i - 1)
        --tGameEnd.tCardType[i] = m_cbEndCardKindView[m_cbEndCardKind[i]]
    end


    --弃牌
    if m_cbEndCardKind[1] == 0 then
        --tGameEnd.tHandCard = m_cbHandCardData
        --tGameEnd.tHandCardOver = m_cbHandCardData
    end

    --显示结算
    self._gameView:GameEnd(tGameEnd)

    -- 延时显示结算
    self:runAction(cc.Sequence:create(cc.DelayTime:create(5), cc.CallFunc:create( function(ref)
        --self:addChild(GameEndView:create(self, tGameEnd))
    end )))

end

-- *******************操作函数************************--
-- 开牌按钮
function GameLayer:OnOpenCard()
    -- 发送数据
    local dataBuffer = CCmd_Data:create(0)
    self:SendData(SUB_C_OPEN_CARD, dataBuffer)
end

-- 放弃按钮
function GameLayer:OnGiveUp()
    -- 删除计时器
    self:KillGameClock(IDI_USER_ADD_SCORE);

    self:HideScoreControl()

    -- 发送数据
    local dataBuffer = CCmd_Data:create(0)
    self:SendData(SUB_C_GIVE_UP, dataBuffer)
end

-- 跟注按钮
function GameLayer:OnFollow()
    -- 删除定时器
    self:KillGameClock(IDI_USER_ADD_SCORE);
    -- 获取筹码
    local wMeChairID = self:GetMeChairID()
    --m_lTableScore[wMeChairID + 1] = m_lTableScore[wMeChairID + 1] + m_lTurnLessScore
    --m_lTotalScore[wMeChairID + 1] = m_lTotalScore[wMeChairID + 1] + m_lTurnLessScore

    --self._gameView:SetTotalScore(wMeChairID, m_lTotalScore[wMeChairID + 1])

    if m_lTableScore[wMeChairID + 1] ~= 0 then
        --self._gameView:DrawMoveAnte(wMeChairID, AA_BASEFROM_TO_BASEDEST, m_lTurnLessScore);
    end

    self:HideScoreControl()

    -- 发送数据
    local dataBuffer = CCmd_Data:create(8)
    dataBuffer:pushscore(m_lTurnLessScore)
    self:SendData(SUB_C_ADD_SCORE, dataBuffer)
end

-- 加注按钮
function GameLayer:OnAddScore()
    -- 显示加注界面
    self:HideScoreControl()
    self._gameView:ShowWindow(BT_GOLDCONTROL, SW_SHOW)
    -- 更新加注选项
    self._gameView:UpdataAddScoreMultiple(m_lTurnLessScore, AddScoreMultiple)
    -- 更新可以加注的按钮
     local wMeChairID = self:GetMeChairID();
     self._gameView:UpdateAddScoreBtn(m_lTurnMaxScore,m_lTotalScore[wMeChairID +1])
end

-- 让牌按钮
function GameLayer:OnPassCard()
    -- 删除定时器
    self:KillGameClock(IDI_USER_ADD_SCORE)
    self:HideScoreControl()

    -- 发送数据
    local dataBuffer = CCmd_Data:create(8)
    dataBuffer:pushscore(0)
    self:SendData(SUB_C_ADD_SCORE, dataBuffer)
end

-- 梭哈按钮
function GameLayer:OnShowHand()
    -- 删除定时器
    self:KillGameClock(IDI_USER_ADD_SCORE);

    -- 获取筹码
    local wMeChairID = self:GetMeChairID();
    --m_lTableScore[wMeChairID + 1] = m_lTableScore[wMeChairID + 1] + m_lTurnMaxScore;
    --m_lTotalScore[wMeChairID + 1] = m_lTotalScore[wMeChairID + 1] + m_lTurnMaxScore;
    self._gameView:SetTotalScore(wMeChairID, m_lTotalScore[wMeChairID + 1]);
    --self._gameView:SetUserTableScore(wMeChairID, m_lTurnMaxScore);

    self:HideScoreControl();

    -- 发送数据
    local dataBuffer = CCmd_Data:create(8)
    dataBuffer:pushscore(m_lTurnMaxScore)
    self:SendData(SUB_C_ADD_SCORE, dataBuffer)
end

function GameLayer:GetMaxScore()
   -- local wMeChairID = self:GetMeChairID();
   -- local maxScore = m_lTurnMaxScore - m_lTotalScore[wMeChairID + 1];
    return m_lTurnMaxScore
end

-- 确定加注操作
function GameLayer:OnOKScore(AddScore)
    -- 删除定时器
    self:KillGameClock(IDI_USER_ADD_SCORE)

    -- 隐藏操作按钮
    self:HideScoreControl()
    self._gameView.m_ChipBG:setVisible(false)

    -- 获取筹码
    local wMeChairID = self:GetMeChairID()
    --m_lTableScore[wMeChairID + 1] = m_lTableScore[wMeChairID + 1] + AddScore
    --m_lTotalScore[wMeChairID + 1] = m_lTotalScore[wMeChairID + 1] + AddScore

    -- 设置累计下注
    --self._gameView:SetTotalScore(wMeChairID, m_lTotalScore[wMeChairID + 1])

    -- 加注动画
    if AddScore > 0 then
        -- 设置本次下注
        --self._gameView:SetUserTableScore(wMeChairID, AddScore)
        --self._gameView:DrawMoveAnte(wMeChairID, AA_BASEFROM_TO_BASEDEST, AddScore)
    end

    -- 发送消息
    local dataBuffer = CCmd_Data:create(8)
    dataBuffer:pushscore(AddScore)
    self:SendData(SUB_C_ADD_SCORE, dataBuffer)
end

-- 取消加注操作
function GameLayer:OnCancelScore()
    self._gameView:ShowWindow(BT_GOLDCONTROL, SW_HIDE)
end

-- *******************消息函数************************--
-- 系统消息
function GameLayer:onSystemMessage(wType, szString)
    if wType == 501 or wType == 515 then
        print("金币不足消息", szString)
        GlobalUserItem.bWaitQuit = true
        -- self:onSubNoticeAddScore(szString)
    end
end

-- 游戏消息
function GameLayer:onEventGameMessage(sub, dataBuffer)
    if sub == SUB_S_GAME_START then
        -- 游戏开始
        self:OnSubGameStart(dataBuffer)
    elseif sub == SUB_S_ADD_SCORE then
        -- 用户加注
        self:OnSubAddScore(dataBuffer)
    elseif sub == SUB_S_GIVE_UP then
        -- 用户放弃
        self:OnSubGiveUp(dataBuffer)
    elseif sub == SUB_S_GAME_END then
        -- 游戏结束
        self:OnSubGameEnd(dataBuffer)
    elseif sub == SUB_S_SEND_CARD then
        -- 发送扑克
        self:OnSubSendCard(dataBuffer)
    elseif sub == SUB_S_OPEN_CARD then
        -- 用户开牌
        self:OnSubOpenCard(dataBuffer)
    else
        print("unknow gamemessage sub is" .. sub)
    end
end

-- 放弃消息
function GameLayer:OnSubGiveUp(dataBuffer)
    local pGiveUp = ExternalFun.read_netdata(cmd.CMD_S_GiveUp, dataBuffer)
    dump(pGiveUp,"放弃消息")
    local wGiveUpUser = pGiveUp.wGiveUpUser;
    -- 设置变量
    m_cbPlayStatus[wGiveUpUser + 1] = FALSE

    -- 界面设置
    --self._gameView:SetCardData(wGiveUpUser, m_cbHandCardData[wGiveUpUser + 1], true)
    self._gameView:DrawMoveCard(wGiveUpUser,TO_GIVEUP_CARD,0)
    self._gameView:SetOperatStatus(wGiveUpUser, BT_GIVEUP)

    if wGiveUpUser == self:GetMeChairID() then
        -- SetGameStatus(GAME_STATUS_FREE);
    end

    self:KillGameClock(IDI_USER_ADD_SCORE);

    -- 显示积分
    if wGiveUpUser == self:GetMeChairID() then

    end
    local useritem = self:getUserInfoByChairID(wGiveUpUser)
    self._soundManager:playUserSound(useritem,4)
    
    
end

-- 加注消息
function GameLayer:OnSubAddScore(dataBuffer)
    print("家住结构？？？")
    local pAddScore = ExternalFun.read_netdata(cmd.CMD_S_AddScore, dataBuffer)
    dump(pAddScore,"加注消息")
    -- 变量定义
    local wMeChairID = self:GetMeChairID()
    local wAddScoreUser = pAddScore.wAddScoreUser
    local lAddScoreCount = pAddScore.lAddScoreCount
    -- 设置变量
    m_wCurrentUser = pAddScore.wCurrentUser;
    m_lTurnLessScore = pAddScore.lTurnLessScore;
    m_lTurnMaxScore = pAddScore.lTurnMaxScore;
    m_lAddLessScore = pAddScore.lAddLessScore;

    -- 加注处理
    if wAddScoreUser ~= nil  then --wMeChairID
        -- 加注界面
        if pAddScore.lAddScoreCount > 0 then
            m_lTotalScore[wAddScoreUser + 1] = m_lTotalScore[wAddScoreUser + 1] + lAddScoreCount
            m_lTableScore[wAddScoreUser + 1] = m_lTableScore[wAddScoreUser + 1] + lAddScoreCount

            -- 更新加注按钮
            self._gameView:UpdataAddScoreMultiple(m_lTurnLessScore, AddScoreMultiple)
            self._gameView:DrawMoveAnte(wAddScoreUser, AA_BASEFROM_TO_BASEDEST, lAddScoreCount)
            self._gameView:SetUserTableScore(wAddScoreUser, lAddScoreCount)
            self._gameView:SetTotalScore(wAddScoreUser, m_lTotalScore[wAddScoreUser + 1])
        end
    end

    -- 总计下注
    local lTotalScore = 0
    for i = 1, ((cmd).GAME_PLAYER) do
        lTotalScore = lTotalScore + m_lTotalScore[i]
    end
    self._gameView:SetCenterScore(lTotalScore)

    -- 更新显示状态
    local useritem = self:getUserInfoByChairID(wAddScoreUser)
    if lAddScoreCount == 0 then
        -- 过牌
        self._gameView:SetOperatStatus(wAddScoreUser, BT_PASS)
        self._soundManager:playUserSound(useritem,5)
    elseif lAddScoreCount == m_lTurnMaxScore then
        -- 梭哈
        self._gameView:SetOperatStatus(wAddScoreUser, BT_SHOWHAND)
        self._soundManager:playUserSound(useritem,2)
        self._soundManager:playEffectCommon(14)
    elseif lAddScoreCount == m_lTurnLessScore then
        -- 跟注
        self._gameView:SetOperatStatus(wAddScoreUser, BT_FOLLOW)
        self._soundManager:playUserSound(3)
    else
        -- 加注
        self._gameView:SetOperatStatus(wAddScoreUser, BT_ADD)
        self._soundManager:playUserSound(1)
    end


    -- 控制界面
    if m_wCurrentUser == wMeChairID then
        self:UpdateScoreControl()
    end

    if m_wCurrentUser == INVALID_CHAIR then
        self:KillGameClock(IDI_USER_ADD_SCORE)
        -- 一轮平衡
        -- 中心积分累计
        for i = 1, ((cmd).GAME_PLAYER) do
            m_lCenterScore = m_lCenterScore + m_lTableScore[i]
        end
        -- 筹码移动
        local TableScore = m_lTableScore
        for i = 1, ((cmd).GAME_PLAYER) do
            if m_cbPlayStatus[i] == TRUE then
                if TableScore[i] ~= 0 then
                    local wChairID = i - 1
                    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function ()
                        self._gameView:DrawMoveAnte(wChairID, AA_BASEDEST_TO_CENTER, TableScore[i])        
                    end)))
                    local callback = function ()
                        self._gameView:SetUserTableScore(wChairID, 0)
                    end
                    if TableScore[i] > 0 then
                        self:performWithDelay(self,callback,0.7)
                    else
                        callback()
                    end  
                end
            end
            
        end
        m_lTableScore = { 0, 0, 0, 0, 0, 0, 0, 0 }

   
        
    elseif m_wCurrentUser < ((cmd).GAME_PLAYER) then
        self:KillGameClock(IDI_USER_ADD_SCORE)
        self:SetGameClock(m_wCurrentUser, IDI_USER_ADD_SCORE, TIME_USER_ADD_SCORE);
    end
end

-- 发牌消息
function GameLayer:OnSubSendCard(dataBuffer)
    local pSendCard = ExternalFun.read_netdata(cmd.CMD_S_SendCard, dataBuffer)
    dump(pSendCard,"发牌消息")
    local cbSendCardCount = pSendCard.cbSendCardCount
    local cbPublic = pSendCard.cbPublic
    -- 当前玩家
    m_wCurrentUser = pSendCard.wCurrentUser;
    m_cbCenterCardData = pSendCard.cbCenterCardData[1]

    -- 发送共牌
    if cbSendCardCount >= 3 and cbSendCardCount <= 5 and cbPublic == 0 then
        -- 发送共牌
        if cbSendCardCount == 3 then
            for j = 1, pSendCard.cbSendCardCount do
                self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1+0.05*j),cc.CallFunc:create(function ( )
                    self._soundManager:playEffectCommon(3,j+1)
                    self._gameView:DrawMoveCard(((cmd).GAME_PLAYER), TO_CENTER_CARD, m_cbCenterCardData[j])
                end)))
            end
        elseif cbSendCardCount > 3 then
            local bTemp = pSendCard.cbSendCardCount;
            self._soundManager:playEffectCommon(3,4)
            self._gameView:DrawMoveCard(((cmd).GAME_PLAYER), TO_CENTER_CARD, m_cbCenterCardData[bTemp]);
        end
    end

    if cbSendCardCount == 5 and cbPublic >= 1 then
        local bFirstCard = cbPublic
        if bFirstCard == 1 then
            bFirstCard = 1
        elseif bFirstCard == 2 then
            bFirstCard = 4
        elseif bFirstCard == 3 then
            bFirstCard = 5
        end
        for j = bFirstCard, pSendCard.cbSendCardCount do
            self._gameView:DrawMoveCard(((cmd).GAME_PLAYER), TO_CENTER_CARD, m_cbCenterCardData[j]);
            self._soundManager:playEffectCommon(3,4)
        end
    end
end

-- 开牌消息
function GameLayer:OnSubOpenCard(dataBuffer)
    local pOpenCard = ExternalFun.read_netdata(cmd.CMD_S_OpenCard, dataBuffer)
    dump(pOpenCard)
    for i = 1, ((cmd).GAME_PLAYER) do
        local wChairID = i - 1
        local pClientUserItem = self:getUserInfoByChairID(wChairID)etUserInfoByChairID(wChairID)
        if pClientUserItem and pClientUserItem.cbUserStatus ~= yl.US_READY then
            self._gameView:SetCardData(wChairID, m_cbHandCardData[i])
        end
    end
end


-- *******************功能函数************************--
-- 换位操作
function GameLayer:onChangeDesk()
    self._gameFrame:QueryChangeDesk()
end

-- 隐藏控制
function GameLayer:HideScoreControl()
    self._gameView:ShowWindow(BT_ADD, SW_HIDE)
    self._gameView:ShowWindow(BT_FOLLOW, SW_HIDE)
    self._gameView:ShowWindow(BT_GIVEUP, SW_HIDE)
    self._gameView:ShowWindow(BT_ADD, SW_HIDE)
    self._gameView:ShowWindow(BT_SHOWHAND, SW_HIDE)
    self._gameView:ShowWindow(BT_PASS, SW_HIDE)
    self._gameView:ShowWindow(BT_GOLDCONTROL, SW_HIDE)
end

-- 更新操作
function GameLayer:UpdateScoreControl()
    -- 显示让牌，跟注
    if m_lTurnLessScore > 0 then
        self._gameView:ShowWindow(BT_PASS, SW_HIDE)
        self._gameView:ShowWindow(BT_FOLLOW,(m_lTurnLessScore == m_lTurnMaxScore) and SW_HIDE or SW_SHOW)
    else
        self._gameView:ShowWindow(BT_PASS, SW_SHOW)
        self._gameView:ShowWindow(BT_FOLLOW, SW_HIDE)
    end

    -- 加注
    if m_lAddLessScore > m_lTurnMaxScore then
        self._gameView:ShowWindow(BT_ADD, SW_HIDE)
    -- 梭哈
      -- self._gameView:ShowWindow(BT_SHOWHAND, SW_SHOW)
    else
        self._gameView:ShowWindow(BT_ADD, SW_SHOW)
    end
    -- 弃牌
    self._gameView:ShowWindow(BT_GIVEUP, SW_SHOW)
end

function GameLayer:onUserChat(chatinfo, sendchair)
    if chatinfo and sendchair then
        local viewid = self:SwitchViewChairID(sendchair)
        if viewid and viewid ~= yl.INVALID_CHAIR then
            self._gameView:ShowUserChat(viewid, chatinfo.szChatString)
        end
    end
end

function GameLayer:onUserExpression(expression, sendchair)
    if expression and sendchair then
        local viewid = self:SwitchViewChairID(sendchair)
        if viewid and viewid ~= yl.INVALID_CHAIR then
            self._gameView:ShowUserExpression(viewid, expression.wItemIndex)
        end
    end
end

-- 语音播放开始
function GameLayer:onUserVoiceStart( useritem, filepath )
    self._gameView:onUserVoiceStart(self:SwitchViewChairID(useritem.wChairID))
end

-- 语音播放结束
function GameLayer:onUserVoiceEnded( useritem, filepath )
    self._gameView:onUserVoiceEnded(self:SwitchViewChairID(useritem.wChairID))
end

-- 游戏退出
function GameLayer:onExit()
    self:KillGameClock()
    self:dismissPopWait()
    GameLayer.super.onExit(self)
end

-- 退出桌子
function GameLayer:onExitTable()
    if self.m_querydialog then
        return
    end
    self:KillGameClock()
    local MeItem = self:GetMeUserItem()
    if MeItem and MeItem.cbUserStatus > yl.US_FREE then
        self:showPopWait()
        self:runAction(cc.Sequence:create(
        cc.CallFunc:create(
        function()
            self._gameFrame:StandUp(1)
        end
        ),
        cc.DelayTime:create(10),
        cc.CallFunc:create(
        function()
            print("delay leave")
            self:onExitRoom()
        end
        )
        )
        )
        return
    end

    self:onExitRoom()
end

-- 离开房间
function GameLayer:onExitRoom()
    self._scene:onKeyBack()
end

-- 用户视图转换
function GameLayer:SwitchViewChairID(chair)
    local nViewID = yl.INVALID_CHAIR
    local nChairCount = 8--self._gameFrame:GetChairCount()
    --print("椅子数目", nChairCount)
    local nChairID = self:GetMeChairID()
    if chair ~= yl.INVALID_CHAIR and chair < nChairCount then
        -- nViewID = math.mod(chair + math.floor(nChairCount * 3 / 2) - nChairID, nChairCount) + 1
        nViewID = math.mod(chair - nChairID + nChairCount, nChairCount) + 1
        --print("转换后的ID=", nViewID)
    end
    return nViewID
end

-- 当前玩家坐下人数
function GameLayer:onGetSitUserNum()
    local num = 0
    for i = 1, ((cmd).GAME_PLAYER) do
        if nil ~= self._gameView.m_sparrowUserItem[i] then
            num = num + 1
        end
    end
    return num
end

-- 用户椅子ID
function GameLayer:getUserInfoByChairID(chairId)
    return self._gameFrame:getTableUserItem(self._gameFrame:GetTableID(), chairId)
end

-- 获取gamekind
function GameLayer:getGameKind()
    return cmd.KIND_ID
end

-- 得到父节点
function GameLayer:getParentNode()
    return self._scene
end

-- 设置私有房的层级
function GameModel:addPrivateGameLayer(layer)
    if nil == layer then
        return
    end
    self._gameView:addChild(layer, 9)
end

-- 设置计时器
function GameLayer:SetGameClock(chair, id, time)
    GameLayer.super.SetGameClock(self, chair, id, time)
    local viewid = self:GetClockViewID()
    if viewid and viewid ~= yl.INVALID_CHAIR then
        local progress = self._gameView.m_TimeProgress[viewid]
        if progress ~= nil then
            local callback = function()
                    progress:setVisible(false)
                    self:OnEventGameClockInfo(viewid, id)
            end
            progress:stop()
            progress:setVisible(true)
            progress:start(time,callback)
        end
    end
end

-- 关闭计时器
function GameLayer:KillGameClock(notView)
    local nViewID = self:GetClockViewID()
    if nViewID and nViewID ~= yl.INVALID_CHAIR then
        -- 关闭计时器
        self._gameView:OnCloseClockView(nViewID)
    end
    GameLayer.super.KillGameClock(self, notView)
end

-- 删除时间
function GameLayer:KillGameTimer(nTimerID)
    self:KillGameClock(nil)
end

-- 获取当前正在玩的玩家数量
function GameLayer:getPlayingNum()
    local num = 0
    for i = 1, ((cmd).GAME_PLAYER) do
        if self.m_cbPlayStatus[i] == 1 then
            num = num + 1
        end
    end
    return num
end

-- 时钟处理
function GameLayer:OnEventGameClockInfo(chair, time, clockid)
    -- 房卡不托管
    if GlobalUserItem.bPrivateRoom then
        print("倒计时处理，房卡返回")
        if time <= 0 then
            return true
        end
    end
    if time < 5 then
        self._soundManager:playEffectCommon(4)
    end
    if clockid == IDI_START_GAME then
        if time <= 0 then
            self._gameFrame:setEnterAntiCheatRoom(false)
            -- 退出防作弊
            return true
        end
    elseif clockid == IDI_USER_ADD_SCORE then
        print("time多少"..time)
        if time == 0 then
            if m_wCurrentUser == self:GetMeChairID() then
                self:OnGiveUp()
                return true
            end
        end
    elseif clockid == IDI_GAME_END_DELAY then
        if time == 0 then
            self:OnGameOver()
            return true
        end
    end
end
-- 最少加注
function GameLayer:OnMinScore()
    -- m_GameClientView.m_GoldControl.SetGold((LONGLONG)(min(m_lAddLessScore,m_lTurnMaxScore)));
end

-- 最大加注
function GameLayer:OnMaxScore()
    -- m_GameClientView.m_GoldControl.SetGold((LONGLONG)m_lTurnMaxScore);
end

function GameLayer:CloseSecondLayer(tag)

    self._gameView:showMenuSecondLayer(tag,false)

end

--银行模块
function GameLayer:sendRequestBankInfo()
    local cmddata = CCmd_Data:create(67)
    cmddata:setcmdinfo(GameServer_CMD.MDM_GR_INSURE,GameServer_CMD.SUB_GR_QUERY_INSURE_INFO)
    cmddata:pushbyte(GameServer_CMD.SUB_GR_QUERY_INSURE_INFO)
    cmddata:pushstring(md5(GlobalUserItem.szPassword),yl.LEN_PASSWORD)

    self:sendNetData(cmddata)
end

function GameLayer:sendNetData( cmddata )
    return self._gameFrame:sendSocketData(cmddata)
end

--申请取款
function GameLayer:sendTakeScore(lScore, szPassword )
    local cmddata = ExternalFun.create_netdata(GameServer_CMD.CMD_GR_C_TakeScoreRequest)
    cmddata:setcmdinfo(GameServer_CMD.MDM_GR_INSURE, GameServer_CMD.SUB_GR_TAKE_SCORE_REQUEST)
    cmddata:pushbyte(GameServer_CMD.SUB_GR_TAKE_SCORE_REQUEST)
    cmddata:pushscore(lScore)
    cmddata:pushstring(md5(szPassword),yl.LEN_PASSWORD)

    self:sendNetData(cmddata)
end
--银行消息
function GameLayer:onSocketInsureEvent( sub,dataBuffer )
    self:dismissPopWait()
    if sub == GameServer_CMD.SUB_GR_USER_INSURE_SUCCESS then
        local cmd_table = ExternalFun.read_netdata(GameServer_CMD.CMD_GR_S_UserInsureSuccess, dataBuffer)
        self.bank_success = cmd_table
        GlobalUserItem.lUserScore = cmd_table.lUserScore
    	GlobalUserItem.lUserInsure = cmd_table.lUserInsure
        self._gameView:updateAsset(cmd.MY_VIEWID,GlobalUserItem.lUserScore)
        self._gameView:onBankSuccess()
    elseif sub == GameServer_CMD.SUB_GR_USER_INSURE_FAILURE then
        local cmd_table = ExternalFun.read_netdata(GameServer_CMD.CMD_GR_S_UserInsureFailure, dataBuffer)
        self.bank_fail = cmd_table

        self._gameView:onBankFailure()
    elseif sub == GameServer_CMD.SUB_GR_USER_INSURE_INFO then --银行资料
        local cmdtable = ExternalFun.read_netdata(GameServer_CMD.CMD_GR_S_UserInsureInfo, dataBuffer)
        dump(cmdtable, "cmdtable", 6)

        self._gameView:onGetBankInfo(cmdtable)
    else
        print("unknow gamemessage sub is ==>"..sub)
    end
end
function GameLayer:performWithDelay(node, callback, delay)
    local delay = cc.DelayTime:create(delay)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    node:runAction(sequence)
    return sequence
end
function GameLayer:getUserItem(chairid)
    local viewid = self:SwitchViewChairID(chairid)
    if viewid == cmd.MY_VIEWID then
       return self:GetMeUserItem()
    else
       return self._gameFrame:getTableUserItem(self._gameFrame:GetTableID(),chairid)
    end

end
return GameLayer  