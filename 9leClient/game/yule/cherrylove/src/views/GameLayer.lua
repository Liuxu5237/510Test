local GameModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameModel")
local GameLayer = class("GameLayer", GameModel)

local module_pre = "game.yule.cherrylove.src"; 

local ExternalFun =  appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local cmd = module_pre .. ".models.CMD_Game"

local GameViewLayer = appdf.req(module_pre .. ".views.layer.GameViewLayer")
local g_var = ExternalFun.req_var
local GameLogic = appdf.req(module_pre .. ".models.GameLogic")
local QueryDialog = appdf.req("base.src.app.views.layer.other.QueryDialog")

--local AdminLayer = appdf.req("game.yule.fengshenbang.src.views.layer.AdminLayer")


function GameLayer:ctor( frameEngine,scene )
    self.m_bLeaveGame = false
    self._gameLogic = GameLogic
	self.name = "GameLayer"
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

function GameLayer:getParentNode( )
    return self._scene
end

-- -- 场景信息
function GameLayer:onEventGameScene(cbGameStatus,dataBuffer)
	if cbGameStatus == 100 or cbGameStatus == 101	then                      --空闲状态
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
	cmddata:pushbyte((free and 1 or 0))
	self:SendData(g_var(cmd).SUB_C_SCENE_START,cmddata)
end
--发送扑克牌小游戏请求
function GameLayer:guessCard(cardtype) 
	local cmddata = CCmd_Data:create(1)
	cmddata:pushbyte(cardtype)  
	self:SendData(g_var(cmd).SUB_C_GUESS_CARD,cmddata)
end

function GameLayer:onEventGameMessage(msgSubId,dataBuffer)
	print("@@@@@@@@@@@@@@@@@@@@@@@msgId"..msgSubId) 
	if  msgSubId == g_var(cmd).SUB_S_START_GAME  then  
		local index=1 
		local icon ={}  
		local win=0	 
		for i = 1, 15 do
			icon[i] = dataBuffer:readbyte()
			print(icon[i])
		end
		--index,win =string.unpack(data,"S",index) 
		win = GlobalUserItem:readScore(dataBuffer)
		print("######win:"..win) 
		self._gameView:startRoll(icon,win)
	elseif msgSubId == g_var(cmd).SUB_S_WIN_CAIJIN then  
		local index=1
		local nCaiJinID =0
		local sCaiJinWin =0
		nCaiJinID =dataBuffer:readbyte()
		sCaiJinWin =GlobalUserItem:readScore(dataBuffer) 
		self._gameView:getJackpotWin(nCaiJinID,sCaiJinWin)
	elseif msgSubId == g_var(cmd).SUB_S_GUESS_RESULT  then
		local win =0        
		win =GlobalUserItem:readScore(dataBuffer)
		print("win:"..win)
		--待定
		--require("app.views.PlayScene"):startGame(win)
		self._gameView.z_MinGame:startGame(win)
		-- self._gameView.play:startGame(personIdx,iswin,win)
		 self:sendReady()
	elseif msgSubId ==  g_var(cmd).SUB_S_FREE_SCENE then  
		local index=1
		local nfreetime =0 --剩余次数
		local nbetline =0  --押注线数
		local nlinebet =0  --单线押注 
		local nGameWin =0  --原中奖金额 
		local nFreeCountWin =0  --原中奖金额 
		nfreetime =dataBuffer:readbyte() 
		nbetline =dataBuffer:readbyte() 
		nlinebet =GlobalUserItem:readScore(dataBuffer)
		nGameWin =GlobalUserItem:readScore(dataBuffer)
		nFreeCountWin =GlobalUserItem:readScore(dataBuffer)

		local icon ={} -- 
		for i = 1, 15 do
			icon[i] =dataBuffer:readbyte()
			print(icon[i])
		end
		
		self.nfreetime =nfreetime 
		self.nbetline =nbetline 
		self.nlinebet =nlinebet 
		self.nGameWin =nGameWin
		self.nFreeCountWin =nFreeCountWin
		self.icon =icon
		self._gameView:reConnect()
	end
end

function GameLayer:onEventUserScore( item )
    self._gameView:onGetUserScore(item)
end

function  GameLayer:onEventUserStatus( useritem,newstatus,oldstatus )
	if newstatus.cbUserStatus == 2 then
		self:sendReady()
	end
end

return GameLayer