local GameModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameModel")
local GameLayer = class("GameLayer", GameModel)

local module_pre = "game.yule.twenty.src";

local ExternalFun =  appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local cmd = module_pre .. ".models.CMD_Game"

local GameViewLayer = appdf.req(module_pre .. ".views.layer.GameViewLayer")
local g_var = ExternalFun.req_var
local GameLogic = appdf.req(module_pre .. ".models.GameLogic")
local QueryDialog = appdf.req("base.src.app.views.layer.other.QueryDialog")

local AdminLayer = appdf.req("game.yule.twenty.src.views.layer.AdminLayer")

function GameLayer:ctor( frameEngine,scene )
    self.m_bLeaveGame = false
    self._gameLogic = GameLogic
    ExternalFun.registerNodeEvent(self)
    GameLayer.super.ctor(self,frameEngine,scene)
    self:sendReady()
end

function GameLayer:onExit()
    GameLayer.super.onExit(self)
end

function GameLayer:CreateView()
    return GameViewLayer:create(self):addTo(self)
end


function GameLayer:getDataMgr( )
    return self._dataModle
end


function GameLayer:onEventUserEnter( wTableID,wChairID,useritem )
    print("add user " .. useritem.wChairID .. "; nick " .. useritem.szNickName)

end


function GameLayer:getParentNode( )
    return self._scene
end

-- -- 场景信息
function GameLayer:onEventGameScene(cbGameStatus,dataBuffer)
	if cbGameStatus == g_var(cmd).SUB_S_FREE_SCENE	then                      --空闲状态
        self:onEventGameSceneFree(dataBuffer)
	end
end
function GameLayer:onEventGameSceneFree(buffer)    --空闲
	print("============================场景==========================")
	local aa = buffer:readbyte()
	local nSpecial = buffer:readbyte()
	--GameViewLayer.ready = true
	if nSpecial == 1 then
		print("发送重连")
		self:sendReConnect()
	else
		--self._gameView:initUi()
	end
end

-- 发送准备
function GameLayer:sendReady()
    --self:KillGameClock()
    self:SendUserReady()
end
function GameLayer:sendReConnect()
	local cmddata = CCmd_Data:create(0)
	self:SendData(g_var(cmd).SUB_C_FREE_SCENE,cmddata)
end

--发送游戏开始
function GameLayer:startGame(line,bet,linecost,free)
	local cmddata = CCmd_Data:create(18)
	cmddata:pushbyte(line)
	cmddata:pushscore(bet)
	cmddata:pushscore(linecost)
    cmddata:pushbool((free and 1 or 0))
	self:SendData(g_var(cmd).SUB_C_SCENE_START,cmddata)
end

function GameLayer:onEventGameMessage(sub,dataBuffer)
	print("@@@@@@@@@@@@@@@@@@@@@@@msgId"..sub) 
	--游戏结果
	if sub == g_var(cmd).SUB_S_START_GAME then  
		local icon = {}
		local win = 0
		for i = 1, 15 do
			icon[i] = dataBuffer:readbyte()
		end
		win = GlobalUserItem:readScore(dataBuffer)
		print("######win:"..win) 
		self._gameView:startRoll(icon,win)
        self:sendReady()
	elseif sub == g_var(cmd).SUB_S_WIN_CAIJIN then  
		local nCaiJinID = 0
		local sCaiJinWin = 0
		nCaiJinID = dataBuffer:readbyte()
		sCaiJinWin = GlobalUserItem:readScore(dataBuffer)
		self._gameView:getJackpotWin(nCaiJinID,sCaiJinWin)
	elseif sub == g_var(cmd).SUB_C_FREE_SCENE then
		local nfreetime=0
		local nfreeAlltime = 0
		local nlinebet = 0
		local nFreeCountWin = 0
		local icon ={}
		nfreetime = dataBuffer:readbyte()--string.unpack(data,"b",index) 
		nfreeAlltime = dataBuffer:readbyte()--string.unpack(data,"b",index) 
		nlinebet = GlobalUserItem:readScore(dataBuffer)--string.unpack(data,"S",index) 
		nFreeCountWin = GlobalUserItem:readScore(dataBuffer)--string.unpack(data,"S",index) 
		for i = 1, 15 do
			icon[i] = dataBuffer:readbyte()--string.unpack(data,"b",index) 
		end
		--require("app.views.MainScene"):ShowReconne()
		print("剩余次数--->>:"..nfreetime)
		print("总次数--->>:"..nfreeAlltime)
		print("单线押注--->>:"..nlinebet)
		print("免费赢取分数--->>:"..nFreeCountWin)
		for i=1 ,15 do
			release_print("-------服务器图标第"..i.."个是"..icon[i])
		end
		--self._gameView:initUi()
		self._gameView:Reconnection(nfreetime,nfreeAlltime,nlinebet,nFreeCountWin,icon)
		---------------------控制面板----------------------------
	elseif sub == g_var(cmd).SUB_S_MCURTENTSTOCK then
		local cmd_table = ExternalFun.read_netdata(g_var(cmd).CMD_S_CurrentStock, dataBuffer)
		self._adminLayer = AdminLayer:create(self,cmd_table):addTo(self)
	elseif sub == g_var(cmd).SUB_S_XIUGAICHENGGONG then
		if not appdf.isObject(self._adminLayer) then
            return
        end
        showToast(self._adminLayer,"操作成功!!!",2)
    elseif sub == g_var(cmd).SUB_C_REQUEST_S_USERROSTER then
    	if not appdf.isObject(self._adminLayer) then
    		return
    	end
    	--local cmd_table = ExternalFun.read_netdata(g_var(cmd).CMD_S_KongZhi,dataBuffer)
    	self._adminLayer:onRefreshUserList(dataBuffer)
	end 
end

function GameLayer:onEventUserScore( item )
    self._gameView:onGetUserScore(item)
end

return GameLayer