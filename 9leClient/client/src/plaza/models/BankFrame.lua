local BaseFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.BaseFrame")
local BankFrame = class("BankFrame",BaseFrame)
local logincmd = appdf.req(appdf.HEADER_SRC .. "CMD_LogonServer")
local game_cmd = appdf.req(appdf.HEADER_SRC .. "CMD_GameServer")
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local WebFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.WebFrame")


function BankFrame:ctor(view,callbcak)
	BankFrame.super.ctor(self,view,callbcak)
end

--银行刷新
BankFrame.OP_BANK_REFRESH = 0
--银行存款
BankFrame.OP_SAVE_SCORE = 1
--银行取款
BankFrame.OP_TAKE_SCORE = 2
--银行赠送
BankFrame.OP_SEND_SCORE = 3
--银行开通
BankFrame.OP_ENABLE_BANK = 4
--银行资料
BankFrame.OP_GET_BANKINFO = 5
--查询用户
BankFrame.OP_QUERY_USER = 6
-- 长连接开通银行
BankFrame.OP_ENABLE_BANK_GAME = 7

--连接结果
function BankFrame:onConnectCompeleted()
	print("BankFrame:onConnectCompeleted oprateCode="..self._oprateCode)

	if self._oprateCode == BankFrame.OP_BANK_REFRESH then			--刷新
		self:sendFlushScore()
	elseif self._oprateCode == BankFrame.OP_SAVE_SCORE then			--存入
		self:sendSaveScore()
	elseif self._oprateCode == BankFrame.OP_TAKE_SCORE then 		--取出
		self:sendTakeScore()
	elseif self._oprateCode == BankFrame.OP_SEND_SCORE then			--赠送
		self:sendTransferScore()
	elseif self._oprateCode == BankFrame.OP_ENABLE_BANK then  		--开通
		self:sendEnableBank()
	elseif self._oprateCode == BankFrame.OP_GET_BANKINFO then 		--获取银行信息
		self:sendGetBankInfo()
	elseif self._oprateCode == BankFrame.OP_QUERY_USER then
		self:sendQueryUserInfo()
	else
		self:onCloseSocket()
		if nil ~= self._callBack then
			self._callBack(-1,"未知操作模式！")
		end		
	end

end

--网络信息(短连接)
function BankFrame:onSocketEvent(main,sub,pData)
	local bCloseSocket = true
	if main == logincmd.MDM_GP_USER_SERVICE then --用户服务
		if sub == logincmd.SUB_GP_USER_INSURE_INFO then
			self:onSubGetBankInfo(pData)
		elseif sub == logincmd.SUB_GP_USER_INSURE_SUCCESS then
			self:onSubInsureSuccess(pData)
		elseif sub == logincmd.SUB_GP_USER_INSURE_FAILURE then
			self:onSubInsureFailue(pData)
		elseif sub == logincmd.SUB_GP_USER_INSURE_ENABLE_RESULT then
			self:onSubEnableBankResult(pData)
			bCloseSocket = false
		elseif sub == logincmd.SUB_GP_QUERY_USER_INFO_RESULT then
			
		else
			local message = string.format("未知命令码：%d-%d",main,sub)
			if nil ~= self._callBack then
				self._callBack(-1,message);
			end			
		end
	end

	if main == logincmd.MDM_GP_USER_SERVICE and sub == logincmd.SUB_GP_QUERY_USER_INFO_RESULT then
		self:onUserInfoResult(pData)
	else
		if bCloseSocket then
			self:onCloseSocket()
		end		
	end
end

--网络消息(长连接)
function BankFrame:onGameSocketEvent(main,sub,pData)
	if main == game_cmd.MDM_GR_INSURE then
		print("GameSocket Bank #" .. main .. "# #" .. sub .. "#")
		if sub == game_cmd.SUB_GR_USER_INSURE_INFO then 				--银行资料
			local cmd_table = ExternalFun.read_netdata(game_cmd.CMD_GR_S_UserInsureInfo, pData)
			GlobalUserItem.lUserScore = cmd_table.lUserScore
			GlobalUserItem.lUserInsure = cmd_table.lUserInsure
			if nil ~= self._callBack then
				self._callBack(BankFrame.OP_GET_BANKINFO,cmd_table)
			end
			--通知更新        
			local eventListener = cc.EventCustom:new(yl.RY_USERINFO_NOTIFY)
		    eventListener.obj = yl.RY_MSG_USERWEALTH
		    cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
		elseif sub == game_cmd.SUB_GR_USER_INSURE_SUCCESS then 			--银行成功
			local cmd_table = ExternalFun.read_netdata(game_cmd.CMD_GR_S_UserInsureSuccess, pData)
			GlobalUserItem.lUserScore= cmd_table.lUserScore
			GlobalUserItem.lUserInsure = cmd_table.lUserInsure
			--通知更新        
			local eventListener = cc.EventCustom:new(yl.RY_USERINFO_NOTIFY)
		    eventListener.obj = yl.RY_MSG_USERWEALTH
		    cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)

		    if nil ~= self._callBack then
				self._callBack(1,"操作成功！")
			end
		elseif sub == game_cmd.SUB_GR_USER_INSURE_FAILURE then 			--银行失败
			local cmd_table = ExternalFun.read_netdata(game_cmd.CMD_GR_S_UserInsureFailure, pData)
			if nil ~= self._callBack then
				self._callBack(-1,cmd_table.szDescribeString)
			end
		elseif sub == game_cmd.SUB_GR_USER_TRANSFER_USER_INFO then 		--用户资料
			local cmd_table = ExternalFun.read_netdata(game_cmd.CMD_GR_S_UserTransferUserInfo, pData)
			self._tabTarget.opTargetAcconts = cmd_table.szAccounts
			self._tabTarget.opTargetID = cmd_table.dwTargerUserID

			local buffer = ExternalFun.create_netdata(game_cmd.CMD_GP_C_TransferScoreRequest)
			buffer:setcmdinfo(game_cmd.MDM_GR_INSURE,game_cmd.SUB_GR_TRANSFER_SCORE_REQUEST)
			buffer:pushbyte(game_cmd.SUB_GR_TRANSFER_SCORE_REQUEST)
			buffer:pushscore(self._lOperateScore)		
			buffer:pushstring(cmd_table.szAccounts,yl.LEN_ACCOUNTS)
			buffer:pushstring(GlobalUserItem.PasswordEncryption(self._szPassword),yl.LEN_PASSWORD)
			buffer:pushstring("",yl.LEN_TRANS_REMARK)
			self._oprateCode = BankFrame.OP_SEND_SCORE

			if not self._gameFrame:sendSocketData(buffer) then
				self._callBack(-1,"发送转账失败！")
			end
		elseif sub == game_cmd.SUB_GR_USER_INSURE_ENABLE_RESULT then 	--开通结果
			local cmd_table = ExternalFun.read_netdata(game_cmd.CMD_GR_S_UserInsureEnableResult, pData)
			dump(cmd_table, "CMD_GR_S_UserInsureEnableResult", 6)

			GlobalUserItem.cbInsureEnabled = cmd_table.cbInsureEnabled
			if nil ~= self._callBack then
				self._callBack(BankFrame.OP_ENABLE_BANK_GAME,cmd_table.szDescribeString)
			end
		end
	end
end

function BankFrame:onSubEnableBankResult(pData)
	GlobalUserItem.cbInsureEnabled = pData:readbyte()
	local szTipString = pData:readstring()
	if nil ~= self._callBack then
		self._callBack(2,szTipString)
	end	
end

function BankFrame:onSubInsureSuccess(pData)
	local dwUserID = pData:readdword()
	if dwUserID == GlobalUserItem.dwUserID then
		GlobalUserItem.lUserScore= GlobalUserItem:readScore(pData)
		GlobalUserItem.lUserInsure = GlobalUserItem:readScore(pData)
		if nil ~= self._callBack then
			self._callBack(1,"操作成功！")
		end

		--通知更新        
		local eventListener = cc.EventCustom:new(yl.RY_USERINFO_NOTIFY)
	    eventListener.obj = yl.RY_MSG_USERWEALTH
	    cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
	end
end

function BankFrame:onSubInsureFailue(pData)
	local lError = pData:readint()
	local szError = pData:readstring()
	if nil ~= self._callBack then
		self._callBack(-1,szError)
	end	
end

--获取到银行资料
function BankFrame:onSubGetBankInfo( pData )
	local cmdtable = ExternalFun.read_netdata(logincmd.CMD_GP_UserInsureInfo, pData)
   

   dump(cmdtable)
	GlobalUserItem.lUserScore = cmdtable.lUserScore
	GlobalUserItem.lUserInsure = cmdtable.lUserInsure
	if nil ~= self._callBack then
		self._callBack(BankFrame.OP_GET_BANKINFO,cmdtable)
	end	
	--通知更新        
	local eventListener = cc.EventCustom:new(yl.RY_USERINFO_NOTIFY)
    eventListener.obj = yl.RY_MSG_USERWEALTH
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
end

function BankFrame:onUserInfoResult(pData)
	local cmdtable =  ExternalFun.read_netdata(logincmd.CMD_GP_UserTransferUserInfo, pData)
	self._target = cmdtable.szAccounts
	self._tabTarget.opTargetAcconts = cmdtable.szAccounts
	self._tabTarget.opTargetID = cmdtable.dwTargetGameID
	if nil ~= self._callBack then
		self._callBack(1,cmdtable)
	end

	--self._oprateCode = BankFrame.OP_SEND_SCORE
	--self:sendTransferScore()
end

--开通
function BankFrame:sendEnableBank()
	local EnableBank = CCmd_Data:create(202)
	local password = GlobalUserItem.szPassword
	local bankpass = GlobalUserItem.PasswordEncryption(self._szPassword)
	local machine  = GlobalUserItem.szMachine
	EnableBank:setcmdinfo(yl.MDM_GP_USER_SERVICE,yl.SUB_GP_USER_ENABLE_INSURE)
	EnableBank:pushdword(GlobalUserItem.dwUserID)
	EnableBank:pushstring(password,33)
	EnableBank:pushstring(bankpass,33)
	EnableBank:pushstring(machine,33)

	--发送失败
	if not self:sendSocketData(EnableBank) and nil ~= self._callBack then
		self._callBack(-1,"发送开通失败！")
	end
end

--刷新
function BankFrame:sendFlushScore()
	local FlushData = CCmd_Data:create(37)
	FlushData:setcmdinfo(yl.MDM_GP_USER_SERVICE,yl.SUB_GP_QUERY_INSURE_INFO)
	FlushData:pushdword(GlobalUserItem.dwUserID)
	FlushData:pushstring(GlobalUserItem.szPassword,33)

	--发送失败
	if not self:sendSocketData(FlushData) and nil ~= self._callBack then
		self._callBack(-1,"发送查询失败！")
	end
end

--存入
function BankFrame:sendSaveScore()
	local SaveData = CCmd_Data:create(204)
	SaveData:setcmdinfo(yl.MDM_GP_USER_SERVICE,yl.SUB_GP_USER_SAVE_SCORE)
	--SaveData:pushdword(GlobalUserItem.dwUserID)
	SaveData:pushstring(GlobalUserItem.szAccount,32)
	
	SaveData:pushscore(self._lOperateScore)
	SaveData:pushstring(GlobalUserItem.PasswordEncryption(GlobalUserItem.szPassword),33)
	SaveData:pushstring(GlobalUserItem.szMachine,33)
	--发送失败
	if not self:sendSocketData(SaveData) and nil ~= self._callBack then
		self._callBack(-1,"发送存款失败！")
	end
end

--取出
function BankFrame:sendTakeScore()
	local TakeData = CCmd_Data:create(204)
	TakeData:setcmdinfo(yl.MDM_GP_USER_SERVICE,yl.SUB_GP_USER_TAKE_SCORE)
	--TakeData:pushdword(GlobalUserItem.dwUserID)
	TakeData:pushstring(GlobalUserItem.szAccount,32)
	TakeData:pushscore(self._lOperateScore)
	TakeData:pushstring(GlobalUserItem.PasswordEncryption(self._szPassword),33)
	-- TakeData:pushstring(GlobalUserItem.szDynamicPass,33)
	TakeData:pushstring(GlobalUserItem.szMachine,33)
		--发送失败
	if not self:sendSocketData(TakeData) and nil ~= self._callBack then
		self._callBack(-1,"发送取款失败！")
	end
end

--发送赠送
function BankFrame:sendTransferScore()

	self._webFrame = WebFrame:create(self, function(result, message)
		if self.webBankCallBack then
			self:webBankCallBack(result,message)
		end
	end)
		
	local action = {}
	action["Score"] = self._lOperateScore
	action["ToUserID"] = self._OperateId
	action["pass"] = GlobalUserItem.PasswordEncryption(self._szPassword)
	local pargams = {1,23,action}
	local action2 = cjson.encode(pargams)
	self._webFrame:wsSendString(action2) 

end

--发送查询银行数据
function BankFrame:sendGetBankInfo(  )
	local cmd = CCmd_Data:create(70)
	cmd:setcmdinfo(logincmd.MDM_GP_USER_SERVICE,logincmd.SUB_GP_QUERY_INSURE_INFO)
	cmd:pushdword(GlobalUserItem.dwUserID)
	cmd:pushstring(GlobalUserItem.szPassword,yl.LEN_PASSWORD)

	if not self:sendSocketData(cmd) and nil ~= self._callBack then
		self._callBack(-1,"发送查询失败！")
	end
end

--发送查询用户信息
function BankFrame:sendQueryUserInfo( )
	local cmd = CCmd_Data:create(65)
	cmd:setcmdinfo(logincmd.MDM_GP_USER_SERVICE,logincmd.SUB_GP_QUERY_USER_INFO_REQUEST)
	cmd:pushbyte(0)
	cmd:pushstring(self._target, 32)

	if not self:sendSocketData(cmd) and nil ~= self._callBack then
		self._callBack(-1,"发送查询失败！")
	end
end

function BankFrame:onFlushBank()
	--操作记录
	self._oprateCode = BankFrame.OP_BANK_REFRESH
	if not self:onCreateSocket(yl.LOGONSERVER,yl.LOGONPORT) and nil ~= self._callBack then
		self._callBack(-1,"建立连接失败！")
	end
end

function BankFrame:webBankCallBack( result,message2 )
    print("webframe回调" .. result)
	print(message2)

    local action2 = cjson.encode(message2)
	local message = cjson.decode(message2)
	if message[1] == 1 then
		if message[2] == 120 then
			if message[3]["code"] == 0 then
				--存款成功
				local score = message[3]["Score"] or 0
				local Inscore = message[3]["InsureScore"] or 0
		
				GlobalUserItem.lUserScore = tonumber(score)
				GlobalUserItem.lUserInsure =tonumber(Inscore)
				
				local eventListener = cc.EventCustom:new(yl.RY_USERINFO_NOTIFY)
				eventListener.obj = yl.RY_MSG_USERWEALTH
				cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
				if nil ~= self._callBack then
					self._callBack(1,"操作成功！")
				end
			elseif message[3]["code"] == 202 then
				if nil ~= self._callBack then
					self._callBack(-1,"您正处于游戏房间，无法进行此操作")
				end
			elseif message[3]["code"] == 201 then
				if nil ~= self._callBack then
					self._callBack(-1,"游戏币不足")
				end
			end
		elseif message[2] == 121 then
			if message[3]["code"] == 0 then
				--取款成功
				local score = message[3]["Score"] or 0
				local Inscore = message[3]["InsureScore"] or 0
		
				GlobalUserItem.lUserScore = tonumber(score)
				GlobalUserItem.lUserInsure =tonumber(Inscore)
				
				local eventListener = cc.EventCustom:new(yl.RY_USERINFO_NOTIFY)
				eventListener.obj = yl.RY_MSG_USERWEALTH
				cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
				if nil ~= self._callBack then
					self._callBack(1,"操作成功！")
				end
			elseif message[3]["code"] == 202 then
				if nil ~= self._callBack then
					self._callBack(-1,"您正处于游戏房间，无法进行此操作")
				end
			elseif message[3]["code"] == 201 then
				if nil ~= self._callBack then
					self._callBack(-1,"游戏币不足")
				end
			elseif message[3]["code"] == 203 then
				if nil ~= self._callBack then
					self._callBack(-1,"银行密码错误!")
				end
			end
		elseif message[2] == 122 then 
			--开通银行	
			if message[3]["code"] == 0 then
				if nil ~= self._callBack then
					GlobalUserItem.cbInsureEnabled = 1
					self._callBack(2,"")
				end
			else
				if nil ~= self._callBack then
					self._callBack(-1,"开通失败")
				end	
			end
		elseif message[2] == 123 then 
			--转账	
			if message[3]["code"] == 0 then
				if nil ~= self._callBack then

					local _webFrame = WebFrame:create(nil, function(result, message)
						if self.webBankCallBack then
							self:webBankCallBack(result,message)
						end
					end,true)
					local pargams = {1,25}
					local action = cjson.encode(pargams)
					_webFrame:wsSendString(action)

					local pargams2 = {6,20}
					local action2 = cjson.encode(pargams2)
					_webFrame:wsSendString(action2) 

					self._callBack(1,"")
				end
			elseif message[3]["code"] == 3 then
				self._callBack(-1,"银行转账业务暂停")
			elseif message[3]["code"] == 4 then
				self._callBack(-1,"转账金额不能低于15万")
			elseif message[3]["code"] == 5 then
				self._callBack(-1,"目标用户不存在")
			elseif message[3]["code"] == 6 then
				self._callBack(-1,"不能给自己转账")
			elseif message[3]["code"] == 7 then
				self._callBack(-1,"转账双方至少有一方是vip5用户")
			elseif message[3]["code"] == 8 then
				self._callBack(-1,"银行密码错误")
			elseif message[3]["code"] == 9 then
				self._callBack(-1,"银行游戏币不足")
				
			else
				if nil ~= self._callBack then
					self._callBack(-1,"转账失败")
				end	
			end
		elseif message[2] == 104 then 
			--查询用户昵称
	
			if type(message[3])  ~= "table" then
				dismissPopWait()
				showToast(nil,"目标用户是空",2)
				return
			end
			self._tabTarget.opTargetAcconts = message[3]["NickName"]
			self._tabTarget.opTargetID = message[3]["GameID"]
			self._callBack(1,message[3])
		elseif message[2] == 125 then

			if message[3] ~= nil then
				self._callBack(5,message[3])
			end 
		end
	elseif message[1] == 6 and message[2] == 120 then
		--查询金币
		local score = message[3]["Score"] or 0
		local Inscore = message[3]["InsureScore"] or 0

		GlobalUserItem.lUserScore = tonumber(score)
		GlobalUserItem.lUserInsure =tonumber(Inscore)
	    
		local eventListener = cc.EventCustom:new(yl.RY_USERINFO_NOTIFY)
		eventListener.obj = yl.RY_MSG_USERWEALTH
		cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)

	end
	
end

function BankFrame:onSaveScore(lScore)
	--操作记录
	self._oprateCode = BankFrame.OP_SAVE_SCORE
	self._lOperateScore = lScore

	self._webFrame = WebFrame:create(self, function(result, message)
		if self.webBankCallBack then
			self:webBankCallBack(result,message)
		end
	end)
	
	local action = {}
    action["M"] = self._lOperateScore
    local pargams = {1,20,action}
    local action2 = cjson.encode(pargams)
	self._webFrame:wsSendString(action2) 

end

function BankFrame:onTakeScore(lScore,szPassword)
	--操作记录
	self._oprateCode = BankFrame.OP_TAKE_SCORE

	self._lOperateScore = lScore
	self._szPassword = szPassword

	self._webFrame = WebFrame:create(self, function(result, message)
		if self.webBankCallBack then
			self:webBankCallBack(result,message)
		end
	end)
	
	
	local action = {}
	action["M"] = self._lOperateScore
	action["P"] = GlobalUserItem.PasswordEncryption(szPassword)
    local pargams = {1,21,action}
    local action2 = cjson.encode(pargams)
	self._webFrame:wsSendString(action2) 
end

function BankFrame:onTransferScore(lScore,target,szPassword,byID)
	self._tabTarget = {}
	self._tabTarget.opTime = os.time()
	self._tabTarget.opScore = lScore
	self._tabTarget.opTargetID = target

	--参数记录
	self._lOperateScore = lScore
	self._target = target
    self._OperateId = tonumber(target)
	self._byID	= byID
	self._szPassword = szPassword

	--操作记录
	self._oprateCode = BankFrame.OP_QUERY_USER
	
	self._webFrame = WebFrame:create(self, function(result, message)
		if self.webBankCallBack then
			self:webBankCallBack(result,message)
		end
	end)
		
	local action = {}
	action["UserID"] = target
	local pargams = {1,4,action}
	local action2 = cjson.encode(pargams)
	self._webFrame:wsSendString(action2) 

end

function BankFrame:onEnableBank(szPassword)
	--操作记录
	self._oprateCode = BankFrame.OP_ENABLE_BANK

	self._webFrame = WebFrame:create(self, function(result, message)
        if self.webBankCallBack then
			self:webBankCallBack(result,message)
		end
	end)
	
	local action = {}
	action["P"] = ""
	action["PN"] = GlobalUserItem.PasswordEncryption(szPassword)
    local pargams = {1,22,action}
    local action2 = cjson.encode(pargams)
	self._webFrame:wsSendString(action2) 
	
end

--查询银行资料
function BankFrame:onGetBankInfo()
	--操作记录
	self._oprateCode = BankFrame.OP_GET_BANKINFO
	local _webFrame = WebFrame:create(nil, function(result, message)
		if self.webBankCallBack then
			self:webBankCallBack(result,message)
		end
    end,true)

 
    local pargams = {6,20}
    local action = cjson.encode(pargams)
    dump(action)
	_webFrame:wsSendString(action) 

	local pargams = {1,25}
    local action = cjson.encode(pargams)
    dump(action)
	_webFrame:wsSendString(action)
	
	-- if nil ~= self._gameFrame and self._gameFrame:isSocketServer() then
	-- 	local buffer = ExternalFun.create_netdata(game_cmd.CMD_GR_C_QueryInsureInfoRequest)
	-- 	buffer:setcmdinfo(game_cmd.MDM_GR_INSURE,game_cmd.SUB_GR_QUERY_INSURE_INFO)
	-- 	buffer:pushbyte(game_cmd.SUB_GR_QUERY_INSURE_INFO)
	-- 	buffer:pushstring(GlobalUserItem.szPassword,yl.LEN_PASSWORD)
	-- 	if not self._gameFrame:sendSocketData(buffer) then
	-- 		self._callBack(-1,"发送查询失败！")
	-- 	end
	-- else
	-- 	if not self:onCreateSocket(yl.LOGONSERVER,yl.LOGONPORT) and nil ~= self._callBack then
	-- 		self._callBack(-1,"建立连接失败！")
	-- 	end
	--end	
end

return BankFrame