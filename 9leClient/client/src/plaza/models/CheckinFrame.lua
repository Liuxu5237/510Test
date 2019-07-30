--[[
	签到接口
	2016_06_16 Ravioyla
]]

local BaseFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.BaseFrame")
local CheckinFrame = class("CheckinFrame",BaseFrame)
local WebFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.WebFrame")

function CheckinFrame:ctor(view,callbcak)
	CheckinFrame.super.ctor(self,view,callbcak)
end

--
CheckinFrame.QUERYCHECKIN = 0
CheckinFrame.CHECKINDONE = 1
CheckinFrame.GETMEMBERGIFT = 2
CheckinFrame.QUERYMEMBERGIFT = 3
CheckinFrame.BASEENSURETAKE = 4
CheckinFrame.BASEENSUREQUERY = 5

--连接结果
function CheckinFrame:onConnectCompeleted()

	print("============Checkin onConnectCompeleted============")
	print("CheckinFrame:onConnectCompeleted oprateCode="..self._oprateCode)

	if self._oprateCode == CheckinFrame.QUERYCHECKIN then			--查询
		self:sendCheckinQuery()
	elseif self._oprateCode == CheckinFrame.CHECKINDONE then		--签到
		self:sendCheckinDone()
	elseif self._oprateCode == CheckinFrame.GETMEMBERGIFT then		--领取会员礼包
		self:sendGetMemberGift()
	elseif self._oprateCode == CheckinFrame.QUERYMEMBERGIFT then 	--查询会员礼包
		self:sendCheckMemberGift()		
	elseif self._oprateCode == CheckinFrame.BASEENSURETAKE then 	--领取低保
		self:sendBaseEnsureTake()		
	elseif self._oprateCode == CheckinFrame.BASEENSUREQUERY then 	--低保参数查询
		self:sendBaseEnsureLoad()
	else
		self:onCloseSocket()
		if nil ~= self._callBack then
			self._callBack(-1,"未知操作模式！")
		end
	end

end

--网络信息
function CheckinFrame:onSocketEvent(main,sub,pData)
	print("============Checkin onSocketEvent============")
	print("*socket event:"..main.."#"..sub) 
	local bRes = false
	if main == yl.MDM_GP_USER_SERVICE then --用户服务
		if sub == yl.SUB_GP_CHECKIN_INFO then 						--查询签到
			bRes = self:onSubCheckinInfo(pData)
		elseif sub == yl.SUB_GP_CHECKIN_RESULT then 				--签到结果
			bRes = self:onSubCheckinResult(pData)
		elseif sub == yl.SUB_GP_MEMBER_QUERY_INFO_RESULT then 		--查询礼包结果
			self:onSubCheckMemberGift(pData)
		elseif sub == yl.SUB_GP_MEMBER_DAY_GIFT_RESULT then 		--领取礼包结果
			bRes = self:onSubGetMemberGift(pData)
		elseif sub == yl.SUB_GP_MEMBER_DAY_PRESENT_RESULT then
			self:onSubGetVipPresent(pData)
		elseif sub == yl.SUB_GP_BASEENSURE_RESULT then 				--领取低保结果
			self:onSubBaseEnsureResult(pData)
		elseif sub == yl.SUB_GP_BASEENSURE_PARAMETER then 			--低保参数
			self:onSubBaseEnsureParam(pData)
		else
			local message = string.format("未知命令码：%d-%d",main,sub)
			if nil ~= self._callBack then
				self._callBack(-1,message)
			end			
		end
	end

	if not bRes then
		self:onCloseSocket()
	end	
end

function CheckinFrame:onSubCheckinInfo(pData)
	--[[struct CMD_GP_CheckInInfo
{	
	WORD							wSeriesDate;						//连续日期
	bool							bTodayChecked;						//签到标识
	DOUBLE							lRewardGold[LEN_WEEK];				//奖励金币
	INT                             continuouday;                       //已经领取
};
]]
	print("============CheckinFrame:onSubCheckinInfo============")
	GlobalUserItem.wSeriesDate = pData:readword()
	print("wSeriesDate-"..GlobalUserItem.wSeriesDate)
	GlobalUserItem.bTodayChecked = pData:readbool()
	print("bTodayChecked="..tostring(GlobalUserItem.bTodayChecked))
	GlobalUserItem.bQueryCheckInData = true
	for i=1,yl.LEN_WEEK do
		GlobalUserItem.lCheckinRewards[i] = pData:readdouble(pData)
		print("lCheckinRewards["..i.."]-"..GlobalUserItem.lCheckinRewards[i])
	end
	GlobalUserItem.nContinuouDay = pData:readint()
	print("nContinuouDay"..GlobalUserItem.nContinuouDay)
	if GlobalUserItem.bTodayChecked == true then
		--非会员标记当日已签到
		if GlobalUserItem.cbMemberOrder == 0 then
			GlobalUserItem.setTodayCheckIn()
		end
	end

	if nil ~= self._callBack then
		return self._callBack(1)
	end	
end

function CheckinFrame:onSubCheckinResult(pData)
	-- CMD_GP_CheckInResult
	print("============CheckinFrame:onSubCheckinResult============")
	--local Success = pData:readbool()
	GlobalUserItem.bTodayChecked = pData:readbool()
	print("======================================================="..tostring(GlobalUserItem.bTodayChecked))
	local lscore = GlobalUserItem:readScore(pData)
	local dbeans = pData:readdouble()
	local szTip = pData:readstring()
	GlobalUserItem.bQueryCheckInData = true
	if GlobalUserItem.bTodayChecked == true then
		GlobalUserItem.lUserScore = lscore
		GlobalUserItem.dUserBeans = dbeans
		print("GlobalUserItem.dUserBeans = "..tostring(dbeans))
		--GlobalUserItem.wSeriesDate = GlobalUserItem.wSeriesDate + 1

		--非会员标记当日已签到
		if GlobalUserItem.cbMemberOrder == 0 then
			GlobalUserItem.setTodayCheckIn()
		end
	end

	--通知更新        
	--[[local eventListener = cc.EventCustom:new(yl.RY_USERINFO_NOTIFY)
    eventListener.obj = yl.RY_MSG_USERWEALTH
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)]]

	if nil ~= self._callBack then
		return self._callBack(10,szTip)
	end	
end

function CheckinFrame:onSubCheckMemberGift(pData)

	print("============ CheckinFrame:onSubCheckMemberGift ============")
	local bPresent = pData:readbool()
	local bGift = pData:readbool()
	local giftCount = pData:readdword()
	print("gift count " .. giftCount)

	local gifts = {}
	for i=1,giftCount do
		local item = {}		 
		item.count = pData:readword()
		item.id = pData:readword()

		--手机端筛选
		--if item.id > 100 then
			table.insert(gifts,item)
		--end		
	end
	-- 加入会员奖励
	local item = {}
	item.count = GlobalUserItem.MemberList[GlobalUserItem.cbMemberOrder]._present or 0
	print("奖励 " .. item.count)
	if 0 ~= item.count then
		item.id = "money"
		table.insert(gifts,item)
	end	

	if nil ~= self._callBack then
		if bGift then
			self._callBack(CheckinFrame.QUERYMEMBERGIFT, gifts, true)
		else
			if GlobalUserItem.cbMemberOrder ~= 0 then
				GlobalUserItem.setTodayCheckIn()
			end
			self._callBack(CheckinFrame.QUERYMEMBERGIFT, gifts, false)
		end
	end
end

function CheckinFrame:onSubGetMemberGift(pData)
	print("============ CheckinFrame:onSubGetMemberGift ============")

	local bSuccessed = pData:readbool()
	local szTip = pData:readstring()

	print("Gift tips " .. szTip)
	if nil ~= self._callBack then
		return self._callBack(CheckinFrame.GETMEMBERGIFT,"")
	end 
	return false
end

-- 会员送金结果
-- CMD_GP_MemberDayPresentResult
function CheckinFrame:onSubGetVipPresent(pData)
	print("============ CheckinFrame:onSubGetVipPresent ============")
	local bSuccessed = pData:readbool()
	local score = GlobalUserItem:readScore(pData)
	local szTip = pData:readstring()
	if bSuccessed then
		GlobalUserItem.lUserScore = score
		--通知更新        
		local eventListener = cc.EventCustom:new(yl.RY_USERINFO_NOTIFY)
	    eventListener.obj = yl.RY_MSG_USERWEALTH
	    cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
	end
	print("Present tips " .. szTip)
end

function CheckinFrame:onSubBaseEnsureResult(pData)
	--CMD_GP_BaseEnsureResult
	print("============CheckinFrame:onSubBaseEnsureResult============")
	local bSuccess = pData:readbool()
	local lscore = GlobalUserItem:readScore(pData)
	local szTip = pData:readstring()

	if true == bSuccess then
		GlobalUserItem.lUserScore = lscore
		--通知更新        
		local eventListener = cc.EventCustom:new(yl.RY_USERINFO_NOTIFY)
	    eventListener.obj = yl.RY_MSG_USERWEALTH
	    cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
	end
	if nil ~= self._callBack then
		self._callBack(2,szTip)
	end
end


function Split(szFullString, szSeparator)  
	local nFindStartIndex = 1  
	local nSplitIndex = 1  
	local nSplitArray = {}  
	while true do  
	   local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)  
	   if not nFindLastIndex then  
		nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))  
		break  
	   end  
	   nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)  
	   nFindStartIndex = nFindLastIndex + string.len(szSeparator)  
	   nSplitIndex = nSplitIndex + 1  
	end  
	return nSplitArray  
end  

function CheckinFrame:webCheckQueryCallBack( result,message2 )
	
	--print(type(message2))
	local action = cjson.encode(message2)
	local message = cjson.decode(message2)
	dump(message)
	if message[1] == 3 and message[2] == 102 then
		GlobalUserItem.wSeriesDate = message[3]["105"][2] 
		if message[3]["1001"][1] == 3 then
			GlobalUserItem.bTodayChecked = true
		else 
			GlobalUserItem.bTodayChecked = false
		end
		GlobalUserItem.bQueryCheckInData = true
	else
		return
	end

	local list 
	if message[3] ~= nil then
		for i=1,yl.LEN_WEEK do

			list = Split(message[3][string.format( "10%d",i )][4],":")
			local t1 , t2 = math.modf(i/2)
			if t2~=0 then
				list[3] = list[3] / 100
			end
			GlobalUserItem.lCheckinRewards[i] = tonumber(list[3])

			if message[3][string.format( "10%d",i )][2] == message[3][string.format( "10%d",i )][3] then
				GlobalUserItem.nContinuouDay = message[3][string.format( "10%d",i )][2]
			end
		end
		dump(GlobalUserItem.lCheckinRewards)

		--GlobalUserItem.nContinuouDay = message[3]["101"][2]
		
	end
	
	if GlobalUserItem.bTodayChecked == true then
		--非会员标记当日已签到
		if GlobalUserItem.cbMemberOrder == 0 then
			GlobalUserItem.setTodayCheckIn()
		end
	end

	if nil ~= self._callBack then
		return self._callBack(1)
	end	

end

--查询签到
function CheckinFrame:onCheckinQuery()
	--操作记录
	self._oprateCode = CheckinFrame.QUERYCHECKIN


	local _webFrame = WebFrame:create(nil, function(result, message)
		if self.webCheckQueryCallBack then
			self:webCheckQueryCallBack(result,message)
		end
    end)
	local action = {}
    action["tp"] = 8
    local pargams = {3,2,action}
    local action2 = cjson.encode(pargams)
   
	_webFrame:wsSendString(action2) 

end


--执行签到
function CheckinFrame:onCheckinDone()
	--操作记录
	self._oprateCode = CheckinFrame.CHECKINDONE

	-- local _webFrame = WebFrame:create(nil, function(result, message)
    --     self:webOnCheckInDone(result,message)
    -- end,true)

    -- local pargams = {3,5}
    -- local action2 = cjson.encode(pargams)
   
	-- _webFrame:wsSendString(action2) 


	-- if not self:onCreateSocket(yl.LOGONSERVER,yl.LOGONPORT) and nil ~= self._callBack then
	-- 	self._callBack(-1,"建立连接失败！")
	-- end
end

--查询礼包
function CheckinFrame:onCheckMemberGift()
	--操作记录
	self._oprateCode = CheckinFrame.QUERYMEMBERGIFT
	if not self:onCreateSocket(yl.LOGONSERVER,yl.LOGONPORT) and nil ~= self._callBack then
		self._callBack(-1,"建立连接失败！")
	end
end

--获取礼包
function CheckinFrame:onGetMemberGift()
	--操作记录
	self._oprateCode = CheckinFrame.GETMEMBERGIFT
	if not self:onCreateSocket(yl.LOGONSERVER,yl.LOGONPORT) and nil ~= self._callBack then
		self._callBack(-1,"建立连接失败！")
	end
end

--领取低保
function CheckinFrame:onBaseEnsureTake()
	--操作记录
	self._oprateCode = CheckinFrame.BASEENSURETAKE
	if not self:onCreateSocket(yl.LOGONSERVER,yl.LOGONPORT) and nil ~= self._callBack then
		self._callBack(-1,"建立连接失败！")
	end
end

-- 查询低保
function CheckinFrame:onBaseEnsureLoad()
	--操作记录
	self._oprateCode = CheckinFrame.BASEENSUREQUERY
	if not self:onCreateSocket(yl.LOGONSERVER,yl.LOGONPORT) and nil ~= self._callBack then
		self._callBack(-1,"建立连接失败！")
	end
end


return CheckinFrame