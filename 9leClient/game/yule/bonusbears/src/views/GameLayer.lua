local GameModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameModel")
local GameLayer = class("GameLayer", GameModel)

local module_pre = "game.yule.bonusbears.src"; 

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
function GameLayer:startGame(line,bet,linecost,bfree)
	
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

function GameLayer:enterGameable() 
	local cmddata = CCmd_Data:create()
	self:SendData(g_var(cmd).SUB_C_ENTER_GAMBLE,cmddata)
end
--退出小游戏
function GameLayer:exitGameable() 
	local cmddata = CCmd_Data:create()
	self:SendData(g_var(cmd).SUB_C_GUESS_CARD_AUTO_LEAVE,cmddata)
end
--转完后发送
function GameLayer:stepOver() 
	local cmddata = CCmd_Data:create()
	self:SendData(g_var(cmd).SUB_C_STEP_OVER,cmddata)
end
function GameLayer:exitClimp()  
	local cmddata = CCmd_Data:create()
	self:SendData(g_var(cmd).SUB_C_BONUS_EXIT,cmddata)
end 
function GameLayer:enterHoney()
	local cmddata = CCmd_Data:create()
	self:SendData(g_var(cmd).SUB_C_BONUS_ENTER,cmddata)
end 

function GameLayer:getShell(sNum,rand) 
	local cmddata = CCmd_Data:create()
	self:SendData(g_var(cmd).SUB_C_GAMBLE_SHELL,cmddata)

	-- local sendPack ="" 
	-- sendPack = sendPack..string.pack("I",sNum) 
	-- sendPack = sendPack..string.pack("i",rand)  		
	-- print(sNum.."####"..rand)
	-- print("发送获取贝壳请求startGame@@@@@@@@@@@@@@@length:"..string.len(sendPack))
	-- SendGameMsg(SendMsg.SUB_C_GAMBLE_SHELL,string.len(sendPack),sendPack)	
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
	elseif msgSubId == g_var(cmd).SUB_S_BONUS_ENTER  then --爬树
		local index=1  
		local sCount=0		--总共抓几次
		local sPrize=0		--一起多少钱 
		sCount = dataBuffer:readint()
		sPrize = GlobalUserItem:readScore(dataBuffer) 
		-- index,sCount =string.unpack(data,"i",index) 
		-- index,sPrize =string.unpack(data,"I",index)  
		-- print("######sCount:"..sCount.."######sPrize:"..sPrize)
		--require("app.views.ClimpScene"):startClimp(sCount,sPrize)
		self._gameView.z_climpLayer:startClimp(sCount,sPrize)
	elseif msgSubId == g_var(cmd).SUB_S_GUESS_RESULT  then
		local index=1
		local leftTime =0 --剩余次数
		local cardItem =0 --扑克数据
		local win =0       --赢了多少
		-- index,leftTime =string.unpack(data,"H",index) 
		-- index,cardItem =string.unpack(data,"H",index) 
		-- index,win =string.unpack(data,"S",index) 
		-- print("leftTime:"..leftTime.."cardItem:"..cardItem.."win:"..win)
		-- require("app.views.PlayScene"):startGame(leftTime,cardItem,win)
	elseif msgSubId ==  g_var(cmd).SUB_S_GAMBLE_LEAVE  then 
		local index=1 
		local win =0       --赢了多少
		local cardItem =0 --扑克数据
		-- index,win =string.unpack(data,"S",index)  
		-- index,cardItem =string.unpack(data,"H",index)  
		-- print("SUB_S_GAMBLE_LEAVE############cardItem:"..cardItem.."win:"..win)
		-- require("app.views.PlayScene"):startGame(-1,cardItem,win) 
	elseif msgSubId ==  g_var(cmd).SUB_S_FREE_SCENE then  
		print("这样进来")
		local index=1
		local nfreetime =0 --剩余次数
		local nbetline =0  --押注线数
		local nlinebet =0  --单线押注 
		local nGameWin =0  --原中奖金额 
		local nFreeCountWin =0  --原中奖金额 
		print(" " .. nfreetime)
		nfreetime =dataBuffer:readbyte() 
		nbetline =dataBuffer:readbyte() 
		nlinebet =GlobalUserItem:readScore(dataBuffer)
		nGameWin =GlobalUserItem:readScore(dataBuffer)
		nFreeCountWin =GlobalUserItem:readScore(dataBuffer)
		print(nfreetime.." "..nbetline.." "..nlinebet.." "..nGameWin)
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
		dump(self.icon)
		print(self.nfreetime.." "..self.nbetline.." "..self.nlinebet.." "..self.nGameWin)
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