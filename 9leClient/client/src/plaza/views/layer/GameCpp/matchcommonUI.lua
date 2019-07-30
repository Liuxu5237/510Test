module("matchcommonUI", package.seeall)
local matchCommonUi = {
    
	mLayer_UI = nil,
	mGameUI = nil,
	m_MatchType = 0,
	mBiSaiResultLayer = nil,
	
}

local m_MatchCommonUI = nil

function matchCommonUi:create()
	
	local instance = {}

	setmetatable(instance, self)
	self.__index = self	
    self.mLayer_UI = DSBaseLayer.initWithJsonFile("matchCommonUi","MatchCommonUI.json")
	
	
	return instance
	
end

function matchCommonUi:init(gameUI)

	self.mGameUI = gameUI
	ds.MyNotification:getInstance():registerLuaEventCallBack("ReviseRankInfo", matchcommonUI.ReviseRankInfo)
    ds.MyNotification:getInstance():registerLuaEventCallBack("MatchWaitInfo", matchcommonUI.StartMatchWait)
    ds.MyNotification:getInstance():registerLuaEventCallBack("MatchFinishInfo",matchcommonUI.MatchFinish)
	ds.MyNotification:getInstance():registerLuaEventCallBack("FreshScoreOfDi",matchcommonUI.FreshScore)
	ds.MyNotification:getInstance():registerLuaEventCallBack("ShareResultSuccess",matchcommonUI.ShareResultSuccess)
	ds.MyNotification:getInstance():registerLuaEventCallBack("ShareResultFail",matchcommonUI.ShareResultFail)

	--初始化
	local gameID = ds.DF:shared():GetGameKindID()
	if (gameID == 10) then
		local renwu_btn = self.mGameUI:seekWidgetByNameOfRoot("renwu_bn")
		renwu_btn:setVisible(false)

	
		local scoreImg = self.mGameUI:seekWidgetByNameOfRoot("scoreImg")
		scoreImg:setVisible(false)

		local game_difen = self.mGameUI:seekWidgetByNameOfRoot("game_difen")
		game_difen:setVisible(false)
		local BisaiName = self.mGameUI:seekWidgetByNameOfRoot("BisaiName")
		BisaiName:setVisible(true)
		local nServerType = ds.CGameCenterManager:Instance():GetGameServerItem():GetGameServer():getServerType()
		if (nServerType == ds.Define.GAME_GENRE_FULL  or nServerType == ds.Define.GAME_GENRE_TIME ) then			
			if (nServerType == ds.Define.GAME_GENRE_FULL) then
				BisaiName:loadTexture("common/MatchUI/eqw3/haimanyuan.png")
				self.m_MatchType = 0
				if (ds.CGameCenterManager:Instance():GetGameServerItem() ~= nil) then
					local gameMath = ds.CGameCenterManager:Instance():GetGameServerItem():GetGameMatch()
					if (gameMath ~= nil) then
						local fee = gameMath:getMatchFee()
						if (gameMath:getMatchFee() ~= nil) then
							if (fee == 0) then
								BisaiName:loadTexture("common/MatchUI/eqw3/xinmanyuan.png")
								self.m_MatchType = 1
							end
						end
					end
				end
			else
				BisaiName:loadTexture("common/MatchUI/eqw3/dianshiyuxuan.png")
				self.m_MatchType = 2
			end
		else
			BisaiName:setVisible(false)
		end
	end
end

--处理排行榜
function matchCommonUi:InitRankLayer()
	local rankLayer = self.mLayer_UI:seekWidgetByNameOfRoot("RankLayer")

	local curRank = gameMatchInterface.matchParam.mCurrentRank
	if (curRank == 0) then
		curRank = 1
	end

	local wUserCount = gameMatchInterface.matchParam.mRemainUserNum
	if (wUserCount == 0) then
		wUserCount = gameMatchInterface.matchParam.mMatchTotalUser
	end
	local rankNum = self.mLayer_UI:seekWidgetByNodeName(rankLayer, "Rank_num")
	rankNum:setString(curRank.."/"..wUserCount)
	self:FreshUserScore()
end

--刷新低分和淘汰分数
function matchCommonUi:FreshUserScore()
	if (#gameMatchInterface.matchParam.mMatchInfo.szTitle > 0) then
		local rankLayer = self.mLayer_UI:seekWidgetByNameOfRoot("RankLayer")
		local taitaiscore = self.mLayer_UI:seekWidgetByNodeName(rankLayer, "taotai_score")
		local difenscore = self.mLayer_UI:seekWidgetByNodeName(rankLayer, "difen_score")
		difenscore:setString(gameMatchInterface.matchParam.mMatchInfo.szTitle[1])
		taitaiscore:setString(gameMatchInterface.matchParam.mMatchInfo.szTitle[2])
	end
end


function matchCommonUi:exit()
	ds.MyNotification:getInstance():unRegisterEventListener("ReviseRankInfo")
	ds.MyNotification:getInstance():unRegisterEventListener("MatchWaitInfo")
	ds.MyNotification:getInstance():unRegisterEventListener("MatchFinishInfo")
	ds.MyNotification:getInstance():unRegisterEventListener("FreshScoreOfDi")
	ds.MyNotification:getInstance():unRegisterEventListener("ShareResultSuccess")
	ds.MyNotification:getInstance():unRegisterEventListener("ShareResultFail")
end


--创建比赛成功或者失败的界面
function matchCommonUi:createBiSaiResultLayer(data)
	self.mBiSaiResultLayer = DSBaseLayer.initWithJsonFile("gameResultLayer","gameResultLayer.json")
	self.mLayer_UI:addChild(self.mBiSaiResultLayer,10)
	--self.mBiSaiResultLayer:Run(nil, 100)

	local gameResoultPanel = self.mGameUI:seekWidgetByNameOfRoot("gameResoultPanel")
	gameResoultPanel:setVisible(false)
	local isSuccess = false
	if (data.lGold > 0 or data.dwIngot > 0 or data.dwTicket > 0) then
		isSuccess = true
	end


	local shareLayer = self.mBiSaiResultLayer:seekWidgetByNameOfRoot("ShareRewardLayer")
	shareLayer:setTouchEnabled(true)
	shareLayer:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			sender:setVisible(false)
		end
	end)
	shareLayer:setVisible(false)

	if (isSuccess) then
		local winBg = self.mBiSaiResultLayer:seekWidgetByNameOfRoot("WinBg")
		winBg:setVisible(true)
		local failBg = self.mBiSaiResultLayer:seekWidgetByNameOfRoot("FailBg")
		failBg:setVisible(false)
		local contentText = self.mBiSaiResultLayer:seekWidgetByNodeName(winBg, "winLabel")
		local str = ds.StringData:shared():stringFromKey("BiSai_Win")
		contentText:setString(string.format(str,data.wUserRank))

		local menpiaNum = self.mBiSaiResultLayer:seekWidgetByNodeName(winBg, "menpaiNum")
		local MoneyRewardNum = self.mBiSaiResultLayer:seekWidgetByNodeName(winBg, "MoneyRewardNum")
		local IngotRewardNum = self.mBiSaiResultLayer:seekWidgetByNodeName(winBg, "IngotRewardNum")
		menpiaNum:setVisible(false)
		MoneyRewardNum:setVisible(false)
		IngotRewardNum:setVisible(false)

		local temp = {}
		if (data.lGold ~= nil and data.lGold > 0) then
			MoneyRewardNum:setVisible(true)
			MoneyRewardNum:setString("x"..ds.common.GetNumberOfShort(data.lGold))
			table.insert(temp, MoneyRewardNum)
		end

		if (data.dwTicket ~= nil and data.dwTicket > 0) then
			menpiaNum:setVisible(true)
			menpiaNum:setString("x"..ds.common.GetNumberOfShort(data.dwTicket))
			table.insert(temp, menpiaNum)
		end

		if (data.dwIngot ~= nil and data.dwIngot > 0) then
			IngotRewardNum:setVisible(true)
			IngotRewardNum:setString("x"..ds.common.GetNumberOfShort(data.dwIngot))
			table.insert(temp, IngotRewardNum)
		end

		if (#temp == 1) then
			local x,y = MoneyRewardNum:getPosition()
			temp[1]:setPosition(cc.p(x,y))
		elseif (#temp == 2) then
			local x,y = MoneyRewardNum:getPosition()
			temp[1]:setPosition(cc.p(-89 + 450,y))
			temp[2]:setPosition(cc.p(180 + 450,y))
		end
		--确定，离开游戏
		local conform_btn = self.mBiSaiResultLayer:seekWidgetByNodeName(winBg, "conform_btn")
		conform_btn:addTouchEventListener(function(sender,eventType)
			if eventType == ccui.TouchEventType.ended then
				if ds.IClientKernel:get() ~= nil then
					ds.IClientKernel:get():Intermit(ds.Define.enGameExitCode.GameExitCode_Normal)
				end
			end
		end)


		local UserName = self.mBiSaiResultLayer:seekWidgetByNodeName(shareLayer, "UserName")
		local MatchName = self.mBiSaiResultLayer:seekWidgetByNodeName(shareLayer, "MatchName")
		local UserRank = self.mBiSaiResultLayer:seekWidgetByNodeName(shareLayer, "UserRank")
		local MoneyNum = self.mBiSaiResultLayer:seekWidgetByNodeName(shareLayer, "MoneyNum")
		local IngotNum = self.mBiSaiResultLayer:seekWidgetByNodeName(shareLayer, "IngotNum")
		local MenPaiNum = self.mBiSaiResultLayer:seekWidgetByNodeName(shareLayer, "MenPaiNum")
		local MatchTime = self.mBiSaiResultLayer:seekWidgetByNodeName(shareLayer, "MatchTime")
		MoneyNum:setVisible(false)
		IngotNum:setVisible(false)
		MenPaiNum:setVisible(false)

		local pGlobalUserInfo = ds.CGlobalUserInfo:GetInstance()
		if (UserName) then
			UserName:setString(pGlobalUserInfo:getNickName())
		end

		local str = ds.GameScriptDataMananger:getString("str_Match_haixuan")
		if (self.m_MatchType == 0) then --海选
			str = ds.GameScriptDataMananger:getString("str_Match_haixuan")
		elseif (self.m_MatchType == 1) then  --新手
			str = ds.GameScriptDataMananger:getString("str_Match_xinshou")
		elseif (self.m_MatchType == 2) then  --电视
			str = ds.GameScriptDataMananger:getString("str_Match_TV")
		end
		MatchName:setString("\""..str.."\"")

		UserRank:setString(string.format(ds.StringData:shared():stringFromKey("mingci"),tostring(data.wUserRank)))

		local showTemp = {}
		if (data.lGold ~= nil and data.lGold > 0) then
			MoneyNum:setVisible(true)
			MoneyNum:setString(ds.common.GetNumberOfShort(data.lGold))
			table.insert(showTemp, MoneyNum)
		end

		if (data.dwTicket ~= nil and data.dwTicket > 0) then
			MenPaiNum:setVisible(true)
			MenPaiNum:setString(ds.common.GetNumberOfShort(data.dwTicket))
			table.insert(showTemp, MenPaiNum)
		end

		if (data.dwIngot ~= nil and data.dwIngot > 0) then
			IngotNum:setVisible(true)
			IngotNum:setString(ds.common.GetNumberOfShort(data.dwIngot))
			table.insert(showTemp, IngotNum)
		end

		if (#showTemp == 1) then
			local x,y = MoneyNum:getPosition()
			showTemp[1]:setPosition(cc.p(x,y))
		elseif (#showTemp == 2) then
			local x1,y1 = MoneyNum:getPosition()
			local x2,y2 = IngotNum:getPosition()
			showTemp[1]:setPosition(cc.p(x1,y1))
			showTemp[2]:setPosition(cc.p(x2,y2))
		end
		local year = os.date("%Y", ds.CoTimer:getGameWorldTime())
		local month = os.date("%m", ds.CoTimer:getGameWorldTime())
		local day = os.date("%d", ds.CoTimer:getGameWorldTime())

		local DateStr = string.format(ds.StringData:shared():stringFromKey("message_content_time"),tonumber(year), tonumber(month), tonumber(day))
		MatchTime:setString(DateStr)

		--分享
		local share_btn = self.mBiSaiResultLayer:seekWidgetByNodeName(winBg, "share_btn")
		share_btn:addTouchEventListener(function(sender,eventType)
			if eventType == ccui.TouchEventType.ended then
				local shareLayer = self.mBiSaiResultLayer:seekWidgetByNameOfRoot("ShareRewardLayer")
				shareLayer:setVisible(true)
				local laodPath = ""
            	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
            	if (targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD) then
                	laodPath = "MatchSharePic.png"
            	elseif(targetPlatform == cc.PLATFORM_OS_ANDROID) then
                	laodPath = "/sdcard/MatchSharePic.png"
            	end
            	if (laodPath ~= "") then
					local function afterCaptured(succeed, outputFile)
                		if succeed then
							local platforms = {}
            				--table.insert(platforms,ds.Define.Platform.WEIXIN)
            				table.insert(platforms,ds.Define.Platform.WEIXIN_CIRCLE)
                    		ds.MultiPlatformMgr:getInstance():OpenShare(platforms, nil,nil,outputFile,"","ShareResultSuccess", "ShareResultFail")
                		else
                    		ds.log("Capture screen failed.")
                		end
            		end
            		cc.utils:captureScreen(afterCaptured, laodPath)
            	end
			end
		end)
		
	else
		local winBg = self.mBiSaiResultLayer:seekWidgetByNameOfRoot("WinBg")
		winBg:setVisible(false)
		local failBg = self.mBiSaiResultLayer:seekWidgetByNameOfRoot("FailBg")
		failBg:setVisible(true)
		local contentText = self.mBiSaiResultLayer:seekWidgetByNodeName(failBg, "winLabel")
		local str = ds.StringData:shared():stringFromKey("BiSai_Fail")
		contentText:setString(string.format(str,data.wUserRank))

		local conform_btn = self.mBiSaiResultLayer:seekWidgetByNodeName(failBg, "conform_btn")
		conform_btn:addTouchEventListener(function(sender,eventType)
			if eventType == ccui.TouchEventType.ended then
				--退出游戏
				if ds.IClientKernel:get() ~= nil then
					ds.IClientKernel:get():Intermit(ds.Define.enGameExitCode.GameExitCode_Normal)
				end
			end
		end)

		local size = winBg:getContentSize()
		local x,y = conform_btn:getPosition()
		conform_btn:setPosition(cc.p(size.width/2, y))

		local share_btn = self.mBiSaiResultLayer:seekWidgetByNodeName(failBg, "share_btn")
		share_btn:addTouchEventListener(function(sender,eventType)
			if eventType == ccui.TouchEventType.ended then
				
			end
		end)
		share_btn:setVisible(false)
	end
end


--修改比赛的排行信息
function matchCommonUi:ReviseRank(data)
	local curRank = data:getData1()
	local wUserCount = data:getData2()
	--通过桌子ID找到底分和淘汰分
	local rankLayer = self.mLayer_UI:seekWidgetByNameOfRoot("RankLayer")
	local rankNum = self.mLayer_UI:seekWidgetByNodeName(rankLayer, "Rank_num")
	rankNum:setString(curRank.."/"..wUserCount)
end

--修改了比赛玩家等待信息
function matchCommonUi:StartMatchWaitInfo()
	local gameResoultPanel = nil
	local gameID = ds.DF:shared():GetGameKindID()
	if (gameID == 10) then
		gameResoultPanel = self.mGameUI:seekWidgetByNameOfRoot("gameResoultPanel")
	end
	
	if (gameResoultPanel ~= nil) then
		gameResoultPanel:setVisible(false)
	end
	
	if (ds.gameCommonUI) then
		ds.gameCommonUI:ShowWaitTips(true)
	end
end

--显示比赛的结算界面
function matchCommonUi:MatchFinishInfo()
	local info = gameMatchInterface.matchParam.mMatchResult
	self:createBiSaiResultLayer(info)

end

--刷新低分和淘汰分数
function  matchCommonUi:FreshUserScore()
	if (#gameMatchInterface.matchParam.mMatchInfo.szTitle > 0) then
		local rankLayer = self.mLayer_UI:seekWidgetByNameOfRoot("RankLayer")
		local taitaiscore = self.mLayer_UI:seekWidgetByNodeName(rankLayer, "taotai_score")
		local difenscore = self.mLayer_UI:seekWidgetByNodeName(rankLayer, "difen_score")
		difenscore:setString(gameMatchInterface.matchParam.mMatchInfo.szTitle[1])
		taitaiscore:setString(gameMatchInterface.matchParam.mMatchInfo.szTitle[2])
	end
end

--分享返回的结果
function matchCommonUi:ShareResult()
	if (self.mBiSaiResultLayer) then
		local shareLayer = self.mBiSaiResultLayer:seekWidgetByNameOfRoot("ShareRewardLayer")
		shareLayer:setVisible(false)
	end
	
end


function ReviseRankInfo(data)
	if (m_MatchCommonUI) then
		m_MatchCommonUI:ReviseRank(data)
	end
end

function StartMatchWait(data)
	if (m_MatchCommonUI) then
		m_MatchCommonUI:StartMatchWaitInfo()
	end
end

function MatchFinish(data)
	if (m_MatchCommonUI) then
		m_MatchCommonUI:MatchFinishInfo()
	end
end

function FreshScore(data)
	if (m_MatchCommonUI) then
		m_MatchCommonUI:FreshUserScore()
	end
end

function ShareResultSuccess(data)
	if (m_MatchCommonUI) then
		m_MatchCommonUI:ShareResult()
	end
end

function ShareResultFail(data)
	if (m_MatchCommonUI) then
		m_MatchCommonUI:ShareResult()
	end
end
-- 
--创建函数
function create(gameUI)
	m_MatchCommonUI = matchCommonUi:create()
	m_MatchCommonUI:init(gameUI)
	return m_MatchCommonUI
end

