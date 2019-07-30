local GameModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameModel")
local GameLayer = class("GameLayer", GameModel)

local module_pre = "game.yule.redbag.src"
local ExternalFun =  appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local cmd = appdf.req(module_pre .. ".models.CMD_Game")
local GameLogic = appdf.req(module_pre .. ".models.GameLogic")
local GameViewLayer = appdf.req(module_pre .. ".views.layer.GameViewLayer")
local GameResultLayer = appdf.req(module_pre .. ".views.layer.GameResultLayer")
local GameFrame = appdf.req(appdf.GAME_SRC.."yule.redbag.src.models.GameFrame")

local g_var = ExternalFun.req_var

function GameLayer:ctor( frameEngine,scene )  
    if cc.FileUtils:getInstance():isFileExist(device.writablePath .. "game/yule/redbag/res/") then
        cc.FileUtils:getInstance():addSearchPath(device.writablePath .. "game/yule/redbag/res/",true)
    else
        cc.FileUtils:getInstance():addSearchPath("game/yule/redbag/res/",true)
    end      
    GameLayer.super.ctor(self, frameEngine, scene)
    self:OnInitGameEngine()

    self._dataModle = GameFrame:create()

    self._dataModle:removeAllUser()
    self._dataModle:initUserList(self:getUserList())

    self.HbMsgCount = 20
    self.HbRecord   = 10

    
end

function GameLayer:getDataMgr( )
    return self._dataModle
end

function GameLayer:getUserList(  )
    return self._gameFrame._UserList
end

----------用户消息
--用户进入
function GameLayer:onEventUserEnter(wTableID, wChairID, useritem)
	--缓存用户
    self._dataModle:addUser(useritem)
    self._gameView:onGetUserScore(useritem)
    
	--self._gameView:refreshUserList()
	--self._gameView:onGetUserScore(useritem)
end

--用户状态
function GameLayer:onEventUserStatus(useritem, newstatus, oldstatus)
	if newstatus == yl.US_FREE or newstatus == yl.US_NULL then
		self._dataModle:removeUser(useritem)
	else
		self._dataModle:updateUser(useritem)
	end
end

--用户分数
function GameLayer:onEventUserScore(useritem)
    self._dataModle:updateUser(useritem)
    self._gameView:onGetUserScore(useritem)

end

function GameLayer:onSubSystemMessage( wType, szString)
    
end

--获取gamekind
function GameLayer:getGameKind()
    return cmd.KIND_ID
end

--创建场景
function GameLayer:CreateView()
        
    return GameViewLayer:create(self)
        :addTo(self)
end

-- 场景信息
function GameLayer:onEventGameScene(cbGameStatus,dataBuffer)
    print("场景数据:" .. cbGameStatus)
    self.m_cbGameStatus = cbGameStatus
    self:onEventGameSceneFree(dataBuffer)
    self:dismissPopWait()
end


function GameLayer:onEventGameSceneFree(dataBuffer)
   self._gameView:SetSceneRed(dataBuffer)
end

function GameLayer:onEventGameMessage(sub,dataBuffer)
    if nil == self._gameView then
        return
    end
    
    if cmd.SUB_S_PLACE_JETTON == sub then                   --发送红包成功
        self:onSubGameJetton(dataBuffer)
    elseif cmd.SUB_S_PLACE_JETTON_FAIL == sub then          --发红包失败
        self:onSubGameJettonFail(dataBuffer)
    elseif cmd.SUB_S_SEND_RECORD == sub       then          --红包领取完毕
        self:onSubGameLIngquOver(dataBuffer)
    elseif cmd.SUB_S_CANCEL_BANKER == sub then              --领取红包
        self:onSubGameZhongPacket(dataBuffer)
    elseif cmd.SUB_S_AMDIN_COMMAND == sub then              --管理结果
        self:onSubGameAdmin(dataBuffer)
   	elseif sub == cmd.SUB_S_APPLY_BANKER then
        self:onSubGameRedPacket(dataBuffer)
    elseif sub == 130 then --记录
        self._gameView:GameRedRecord(dataBuffer)
    elseif sub == 131 then --发红包记录
        self._gameView:GameSendRedRecord(dataBuffer)
   end
end

function GameLayer:onSubGameJetton( dataBuffer )
    -- 游戏开始
    local cmd_table = ExternalFun.read_netdata(cmd.Send_S_RedPacket, dataBuffer)
    dump(cmd_table)
    local chairid = cmd_table.wChaid
    local wnumber = cmd_table.wNumber
    local wpoint  = cmd_table.wPoint
    local wrate   = cmd_table.wRate
    local score   = cmd_table.wRedmoney
    local identifier = cmd_table.wIdentifier
    self._gameView:addSendHbJetton(cmd_table.wFaceAddress,cmd_table.wGameID,chairid,wnumber,wpoint,wrate,score,identifier)   

end

function GameLayer:onSubGameJettonFail( dataBuffer )
    local resultID = dataBuffer:readbyte()
    self._gameView:showToastError(resultID)
    print("1111111111111111111111")
end


function GameLayer:onSubGameLIngquOver( date )
    self._gameView:RedLingOver(date)
end
function GameLayer:onSubGameRedPacket( date )
    self._gameView:ShowChaiHbThird(date)
end

 --中了地雷咋最恶心的地方来了  看哥哥showtime
 function GameLayer:onSubGameZhongPacket( date )

   -- eventListener._usedata = {["Mine_ChaiInfo"] = dataBuffer}
  -- local cmd_table = ExternalFun.read_netdata(cmd.CMD_GR_ChaiLeiInfo_Result,date);
    self._gameView:ZhongLeiChaiHbThird(date)
end


 function GameLayer:onSubGameAdmin( date )
    self._gameView:AdminList(date)
end

function GameLayer:onSubGameIsChai(  )
    --是否可拆
    self._gameView:ShowChaiHbSecond()
end

function GameLayer:SendShowChaiRecord(  )
    --发送查看红包记录
end

function GameLayer:onSubGameChaiRecord(  )
    --收到查看记录
    self._gameView:ShowChaiHbThird()
end
--用户进入
function GameLayer:OnUpdateUser( wChairID, useritem)
	print("dssdsdsd"..wChairID  )
	-- self._dataModle:addUser(useritem)
	-- self._gameView:refreshUserList()
	-- self._gameView:onGetUserScore(useritem)
end

------------------------------------------------------------------------------------------------------------
--网络处理
------------------------------------------------------------------------------------------------------------
function GameLayer:SendRedPacktByGame( redCount,mineCount,peiLv,allScore )
    --local cmddata = CCmd_Data:create()
    local cmddata =ExternalFun.create_netdata(cmd.SendRedPacket)
    cmddata:pushword(self:GetMeChairID())
    cmddata:pushword(redCount)
    cmddata:pushword(mineCount)
    cmddata:pushdouble(peiLv)
    cmddata:pushscore(allScore)
   -- cmddata:pushword(maiLeiIdt)
    dump(cmddata)
    dump(maiLeiIdt)
    self:SendData(cmd.SUB_C_SENDREDPACKET,cmddata)
    print("发送领取红包")
end
function GameLayer:SendZhonglei(chaiHbKey ,bChiLei)
     local cmddata = CCmd_Data:create(5)
    cmddata:pushdword(chaiHbKey)
    cmddata:pushbool(bChiLei)
    self:SendData(cmd.SUB_C_CANCEL_BANKER,cmddata )
    print("我中雷了")
end

function GameLayer:setRedBitInfo(GameID, strBit,ChiaBit)
    local cmddata = CCmd_Data:create(8)
    local bit = tonumber(strBit)
    local caibit = tonumber(ChiaBit)
    if bit == nil then
       bit = 0
    end
     if caibit == nil then
        caibit = 0
    end
    cmddata:pushdword(GameID)
    cmddata:pushword(bit)
    cmddata:pushword(caibit)
    self:SendData(cmd.SUB_C_UPDATE_STORAGE,cmddata)
end


function GameLayer:SendRedPacket( redCount,mineCount,peiLv,allScore ,maiLeiIdt)

    local cmddata = CCmd_Data:create()
    cmddata:pushword(self:GetMeChairID())
    cmddata:pushword(redCount)
    cmddata:pushword(mineCount)
    cmddata:pushword(peiLv)
    cmddata:pushscore(allScore)
    cmddata:pushword(maiLeiIdt)
    dump(cmddata)
    dump(maiLeiIdt)
    self:SendData(cmd.SUB_C_SENDREDPACKET,cmddata)
end



function GameLayer:sendAdmin( )
    local cmddata = CCmd_Data:create(0)
    self:SendData(cmd.SUB_C_AMDIN_COMMAND,cmddata)
end
function GameLayer:SendChaiHongBao( hbkey )
    local cmddata = CCmd_Data:create(4)
    cmddata:pushdword(hbkey)
    self:SendData(cmd.SUB_C_APPLY_BANKER,cmddata)
    print("发送拆红包" .. hbkey)
end

function GameLayer:reSetData()
    self.m_bIsMyBanker = false
    self.m_tabPromptList = {}
    self.m_tabCurrentCards = {}
    self.m_tabPromptCards = {}
    self.m_bLastCompareRes = false
    self.m_nLastOutViewId = cmd.INVALID_VIEWID
    self.m_tabLastCards = {}    
end

--获取记录
function GameLayer:RedRecord()
    local dataBuffer = CCmd_Data:create()
    dataBuffer:setcmdinfo(9,cmd.SUB_GR_USERMAILEI_REQUEST)
    self._gameFrame:sendSocketData(dataBuffer)
end

--暂时注释俩
--获取发包记录
function GameLayer:SendRedRecord()
    local dataBuffer = CCmd_Data:create()                    
    dataBuffer:setcmdinfo(9,cmd.SUB_GR_REDPACKET_RECORD)
    self._gameFrame:sendSocketData(dataBuffer)
end

--详细信息
function GameLayer:SendRedDiffRecord(RedKey)
    -- local dataBuffer = CCmd_Data:create(8)
    --  dataBuffer:pushint(2)   
    --  dataBuffer:pushdword(RedKey)         
    --  dataBuffer:setcmdinfo(yl.MDM_GR_USER,cmd.SUB_GR_RECORD_REDLIST)
    --  self._gameFrame:sendSocketData(dataBuffer)
end
---------------------------------------------------------------------------------------
------继承函数
function GameLayer:onEnterTransitionFinish()
    GameLayer.super.onEnterTransitionFinish(self)
end

function GameLayer:onExit()
    self:KillGameClock()
    self:dismissPopWait()
    GameLayer.super.onExit(self)
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
    ExternalFun.playPlazzBackgroudAudio()
    self._scene:onKeyBack()
end

-- 计时器响应
function GameLayer:OnEventGameClockInfo(chair,time,clockId)
    if nil ~= self._gameView and nil ~= self._gameView.updateClock then
        self._gameView:updateClock(chair,clockId, time)
    end
end

-- 设置计时器
function GameLayer:SetGameClock(chair,id,time)
    GameLayer.super.SetGameClock(self,chair,id,time)
end

function GameLayer:onGetSitUserNum()
    return table.nums(self._gameView.m_tabUserHead)
end

function GameLayer:getUserInfoByChairID( chairid )
    local viewId = self:SwitchViewChairID(chairid)
    return self._gameView.m_tabUserItem[viewId]
end

function GameLayer:OnResetGameEngine()
    self:reSetData() 
    GameLayer.super.OnResetGameEngine(self)
end



------------------------------------------------------------------------------------------------------------
--网络处理
------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------
--网络处理
------------------------------------------------------------------------------------------------------------

function GameLayer:getWinDir( score )
    print("## is my Banker")
    print(self.m_bIsMyBanker)
    print("## is my Banker")
    if true == self.m_bIsMyBanker then
        if score > 0 then
            return cmd.kLanderWin
        elseif score < 0 then
            return cmd.kLanderLose
        end
    else
        if score > 0 then
            return cmd.kFarmerWin
        elseif score < 0 then
            return cmd.kFarmerLose
        end
    end
    return cmd.kDefault
end
return GameLayer