--[[
	登录模块
]]

local BaseFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.BaseFrame")

local LogonFrame = class("LogonFrame",BaseFrame)

local GameServerItem   = appdf.req(appdf.CLIENT_SRC.."plaza.models.GameServerItem")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local logincmd = appdf.req(appdf.HEADER_SRC .. "CMD_LogonServer")

function LogonFrame:ctor(view,callback)

	LogonFrame.super.ctor(self,view,callback)
	self._plazaVersion = appdf.VersionValue(6,7,0,1)
	self._stationID = yl.STATION_ID
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	local tmp = yl.DEVICE_TYPE_LIST[targetPlatform]
	self._deviceType = tmp or yl.DEVICE_TYPE
	self._szMachine = MultiPlatform:getInstance():getMachineId()

	self.m_angentServerList = {}
	self._tempAllRoom = {}
end

--连接结果
function LogonFrame:onConnectCompeleted()

	if self._logonMode == 0 then
		self:sendLogon()
	elseif self._logonMode == 1 then
		self:sendRegister() 
	elseif self._logonMode == 2 then 
		self:sendVisitor()
	elseif self._logonMode == 3 then
		self:sendThirdPartyLogin()
	elseif self._logonMode == 4 then
		self:sendAWYLogin()
    elseif self._logonMode == 5 then
		self:sendTYYLogin()
	else
		self:onCloseSocket()
		if nil ~= self._callBack then
			self._callBack(-1,"未知登录模式！")
		end		
	end
	
end

--网络信息
function LogonFrame:onSocketEvent(main,sub,pData)
	if (main == yl.MDM_MB_LOGON) or (main == yl.MDM_GP_LOGON) then --登录命令
		self:onSubLogonEvent(sub,pData)
	elseif main == yl.MDM_MB_SERVER_LIST then --房间列表
		self:onRoomListEvent(sub,pData)
	end
end

--玩家信息
function LogonFrame:onSubLogonEvent(sub,pData)
	local sub =pData:getsub()
	--登录成功读取用户信息
	if sub == yl.SUB_MB_LOGON_SUCCESS then
		print("=========== 登录成功 ===========")
		GlobalUserItem.szMachine = self._szMachine
		GlobalUserItem.onLoadData(pData)
		GlobalUserItem.szIpAdress = MultiPlatform:getInstance():getClientIpAdress() or ""

		--重置房间
		GlobalUserItem.roomlist = {}
		if PriRoom then
			PriRoom:getInstance().m_tabPriModeGame = {}
		end
		self._tempAllRoom = {}
	--会员信息
	elseif sub == yl.SUB_GP_MEMBER_PARAMETER_RESULT then
		local count = pData:readword()
		GlobalUserItem.MemberList = {}
		for i=1,count do
			local item = {}
			item._order = pData:readbyte()
			item._name  = pData:readstring(16)
			item._right = pData:readdword()
			item._task  = pData:readdword()
			item._shop  = pData:readdword()
			item._insure= pData:readdword()
			item._present=pData:readdword()
			item._gift  = pData:readdword() 
			GlobalUserItem.MemberList[item._order] = item

			--dump(item, "会员信息", 6)
		end
	--登录失败
	elseif sub == yl.SUB_MB_LOGON_FAILURE then
		print("=========== 登录失败 ===========")
		-- CMD_MB_LogonFailure
		local cmdtable = ExternalFun.read_netdata(logincmd.CMD_MB_LogonFailure, pData)
		if 10 == cmdtable.lResultCode then
            --2017.7.28 这里有个很大的问题，注册超过限制也会返回10，就把游客账号隐藏了，这里去掉
			--GlobalUserItem.setBindingAccount()
			if nil ~= self._callBack then
				self._callBack(10,cmdtable.szDescribeString)
		    end
        end
		self:onCloseSocket()
		
		if nil ~= self._callBack then
			if 9 == cmdtable.lResultCode then
				self._callBack(9)
			else
				self._callBack(-1,cmdtable.szDescribeString)
			end
		end		
	--更新APP
	elseif sub == yl.SUB_MB_UPDATE_NOTIFY then
		local cbMustUpdate = pData:readbyte()
		local cbAdviceUpdate = pData:readbyte()
		local dwCurrentVersion = pData:readdword()
		print("update_notify:"..cbMustUpdate.."#"..cbAdviceUpdate.."#"..dwCurrentVersion)
		local tmpV = appdf.ValuetoVersion(dwCurrentVersion)
		print(tmpV.p.."."..tmpV.m.."."..tmpV.s.."."..tmpV.b)
		self:onCloseSocket()
		if nil ~= self._callBack then
			self._callBack(-1,"版本信息错误！")
		end		
	end
end

--房间信息
function LogonFrame:onRoomListEvent(sub,pData)
	if sub == yl.SUB_MB_LIST_FINISH then	--列表完成
		self:onCloseSocket();
		if self._logonMode == 0 then
			GlobalUserItem.szAccount = self._szAccount
			GlobalUserItem.szPassword = self._szPassword
			GlobalUserItem.bVisitor 	 = false
			GlobalUserItem.bWeChat = false
		elseif self._logonMode == 1 then
			GlobalUserItem.szAccount = self._szRegAccount
			GlobalUserItem.szPassword = self._szRegPassword
			GlobalUserItem.bVisitor 	 = false
			GlobalUserItem.bWeChat = false
		elseif self._logonMode == 2 then 						--游客登录
			GlobalUserItem.bVisitor  = true
			GlobalUserItem.bWeChat = false
		elseif self._logonMode == 3 then 						--微信登陆
			GlobalUserItem.bVisitor  = false
			GlobalUserItem.bWeChat = true
		elseif self._logonMode == 4 then 						--爱玩悦登录
			GlobalUserItem.bVisitor  = false
			GlobalUserItem.bWeChat = false
        elseif self._logonMode == 5 then 						--天宇游登录
			GlobalUserItem.bVisitor  = false
			GlobalUserItem.bWeChat = false
		end
		-- 整理列表
		for k,v in pairs(self._tempAllRoom) do
			table.sort(v, function(a, b)
				return a.wSortID < b.wSortID
			end)
			for i = 1, #v do
				v[i]._nRoomIndex = i
			end
			local roomlist = {}
			--记录游戏ID
			--table.insert(roomlist,k)
			--table.insert(roomlist,v)
			if PriRoom then
				PriRoom:getInstance().m_tabPriRoomList[k] = v
			end
			--加入缓存
			--table.insert(GlobalUserItem.roomlist,roomlist)
            GlobalUserItem.roomlist[k] = v
		end

		--登录完成
		self:onCloseSocket() --无状态
		if nil ~= self._callBack then
			self._callBack(1)
		end		
	elseif sub == yl.SUB_MB_LIST_SERVER then	--列表数据
		self:onSubRoomListInfo(pData)
	elseif sub == yl.SUB_MB_AGENT_KIND then 	--代理列表
		self:onSubAngentListInfo(pData)
	end
end

--房间列表
function LogonFrame:onSubRoomListInfo(pData)
	--计算房间数目
	local len = pData:getlen()
	print("=============== onSubRoomListInfo ================")
	print("onSubRoomListInfo:"..len)
	if (len - math.floor(len/yl.LEN_GAME_SERVER_ITEM)*yl.LEN_GAME_SERVER_ITEM) ~= 0 then
		print("roomlist_len_error"..len)
		return
	end
	local itemcount =  math.floor(len/yl.LEN_GAME_SERVER_ITEM)
	print("=============== onSubRoomListInfo ================ ", itemcount)
	
	--读取房间信息
	for i = 1,itemcount do
		local item = GameServerItem:create()
						:onInit(pData)
		if not item then 
			break
		end
		--dump(item, "item", 3)
		if nil == self._tempAllRoom[item.wKindID] then
			self._tempAllRoom[item.wKindID] = {}
		end

		if item.wServerType == yl.GAME_GENRE_PERSONAL then
			--if GlobalUserItem.bEnableRoomCard then
				if PriRoom then
					PriRoom:getInstance().m_tabPriModeGame[item.wKindID] = true
				end				
				table.insert(self._tempAllRoom[item.wKindID], item)
			--end
		else
			table.insert(self._tempAllRoom[item.wKindID], item)
		end		
		if item.wServerType == yl.GAME_GENRE_MATCH and MatchRoom then
			MatchRoom:getInstance().m_tabMatchModeGame[item.wKindID] = true
		end 
	end
end

function LogonFrame:onSubAngentListInfo(pData)
	self.m_angentServerList = {}
	--计算数目
	local len = pData:getlen()
	print("=============== onSubAngentListInfo ================")
	print("onSubAngentListInfo:"..len)
	if (len - math.floor(len/4)*4) ~= 0 then
		print("angentlist_len_error"..len)
		return
	end
	print("=============== onSubAngentListInfo ================")
	local itemcount =  math.floor(len/4)
	
	--读取房间信息
	for i = 1,itemcount do
		local kind = pData:readword()
		local sort = pData:readword()
		
		self.m_angentServerList[kind] = {KindID = kind, SortID = sort}
	end
end

function LogonFrame:onLogonByAccount(szAccount,szPassword,Verification)
	--数据保存
	self._szAccount = szAccount--"asd7002";
	self._szPassword= szPassword--md5("asd7002")
	self._szMobilePhone = "0123456789"
	self._szVerification = Verification --是否验证
	--记录模式
	self._logonMode = 0
	if not self:onCreateSocket(yl.LOGONSERVER,yl.LOGONPORT) and nil ~= self._callBack then
		self._callBack(-1,"建立连接失败！")
		return false
	end
	return true
end

function LogonFrame:onLogonByVisitor()
	--记录模式	
	self._logonMode = 2
	if not self:onCreateSocket(yl.LOGONSERVER,yl.LOGONPORT) and nil ~= self._callBack then
		self._callBack(-1,"建立连接失败！")
		return false
	end
	return true
end

function LogonFrame:onLoginByThirdParty(szAccount, szNick, cbgender, platform, szFaceAddress)
	--数据保存
	self._szAccount = szAccount
	self._szNickName = szNick
	self._cbLoginGender = cbgender
	self._cbPlatform = platform
	self._szFaceAddress = szFaceAddress

	--记录模式
	self._logonMode = 3
	if not self:onCreateSocket(yl.LOGONSERVER,yl.LOGONPORT) and nil ~= self._callBack then
		self._callBack(-1,"建立连接失败！")
		return false
	end
	return true
end


--爱悦玩
function LogonFrame:onLoginByAWY(uid,username,pwd,platform)
	--数据保存
	self._szAccount = uid
	self._szNickName = username
	self._szPassword = pwd
	self._cbPlatform = platform

	print("爱玩悦建立链接")
	--记录模式
	self._logonMode =4
	if not self:onCreateSocket(yl.LOGONSERVER,yl.LOGONPORT) and nil ~= self._callBack then
		self._callBack(-1,"建立连接失败！")
		return false
	end
	return true
end


--天宇游
function LogonFrame:onLoginByTYY(uid,platform,Verification)
	--数据保存
    self._szAccount = uid
	self._szNickName = ""
	self._szPassword = ""
	self._cbPlatform = platform
    self._szVerification = Verification --是否验证

    print("wawwwww");
    print(uid)
    print(self._szAccount)

	print("天宇游建立链接")
	--记录模式
	self._logonMode =5
	if not self:onCreateSocket(yl.LOGONSERVER,yl.LOGONPORT) and nil ~= self._callBack then
		self._callBack(-1,"建立连接失败！")
		return false
	end
	return true
end


function LogonFrame:onRegister(szAccount,szNickName,szPassword,cbGender,szSpreader)
	--数据保存
	self._szRegAccount = szAccount
    self._szRegNickName = szNickName
	self._szRegPassword= szPassword
	self._cbRegGender = cbGender
	self._szMobilePhone = "0123456789"
	self._szSpreader = szSpreader

	--记录模式
	self._logonMode = 1
	if not self:onCreateSocket(yl.LOGONSERVER,yl.LOGONPORT) and nil ~= self._callBack then
		self._callBack(-1,"建立连接失败！")
		return false
	end
	return true
end

function LogonFrame:sendLogon()
	local LogonData = CCmd_Data:create(261)
	LogonData:setcmdinfo(yl.MDM_MB_LOGON,yl.SUB_MB_LOGON_ACCOUNTS)
	LogonData:pushword(--[[GlobalUserItem.nCurGameKind]]yl.INVALID_WORD)
	LogonData:pushdword(self._plazaVersion)
	LogonData:pushbyte(self._deviceType)
	LogonData:pushstring(self._szPassword,yl.LEN_MD5)
	LogonData:pushstring(self._szAccount,yl.LEN_ACCOUNTS)
	LogonData:pushstring(self._szMachine,yl.LEN_MACHINE_ID)
	LogonData:pushstring(self._szMobilePhone,yl.LEN_MOBILE_PHONE)
	LogonData:pushword(self._szVerification)
    LogonData:pushstring(strtable.cip,16)
	--print("send logon:account-"..self._szAccount.." password-"..self._szPassword)
	--发送失败
	if not self:sendSocketData(LogonData) and nil ~= self._callBack then
		self._callBack(-1,"发送登录失败！")
	end
end

function LogonFrame:sendVisitor()
	local VisitorData = CCmd_Data:create(97)
	VisitorData:setcmdinfo(yl.MDM_MB_LOGON,yl.SUB_MB_LOGON_VISITOR)

	VisitorData:pushword(--[[GlobalUserItem.nCurGameKind]]yl.INVALID_WORD)
	VisitorData:pushdword(self._plazaVersion)
	VisitorData:pushbyte(self._deviceType)

	self._szMachine = MultiPlatform:getInstance():getMachineId()
	VisitorData:pushstring(self._szMachine,yl.LEN_MACHINE_ID)
	VisitorData:pushstring(self._szMobilePhone,yl.LEN_MOBILE_PHONE)

		--发送失败
	if not self:sendSocketData(VisitorData) and nil ~= self._callBack then
		self._callBack(-1,"发送游客登录失败！")
	end
end

function LogonFrame:sendThirdPartyLogin( )

	local cmddata = ExternalFun.create_netdata(logincmd.CMD_MB_LogonOtherPlatform)
	cmddata:setcmdinfo(logincmd.MDM_MB_LOGON,logincmd.SUB_MB_LOGON_OTHERPLATFORM)

	cmddata:pushword(--[[GlobalUserItem.nCurGameKind]]yl.INVALID_WORD)
	cmddata:pushdword(self._plazaVersion)
	cmddata:pushbyte(self._deviceType)
	cmddata:pushbyte(self._cbLoginGender)
	cmddata:pushbyte(self._cbPlatform)
	cmddata:pushstring(self._szAccount,33) --LEN_USER_UIN
	cmddata:pushstring(self._szNickName,yl.LEN_NICKNAME)
	cmddata:pushstring(self._szNickName,yl.LEN_COMPELLATION)	
	cmddata:pushstring(self._szMachine,yl.LEN_MACHINE_ID)
	cmddata:pushstring(self._szMobilePhone,yl.LEN_MOBILE_PHONE)
    cmddata:pushstring(strtable.cip,16)
	--渠道号
	if device.platform == "ios" and appdf.CHANNEL_ID == 1 then
        cmddata:pushword(0)
    elseif  device.platform == "android" or device.platform == "ios" then
		cmddata:pushword(appdf.CHANNEL_ID)
	elseif device.platform == "windows" then
		cmddata:pushword(4)
	end
	cmddata:pushstring(self._szFaceAddress, 256)
	if not self:sendSocketData(cmddata) and nil ~= self._callBack then
		self._callBack(-1,"发送微信登录失败！")
	end
end

--爱玩悦登陆
function LogonFrame:sendAWYLogin( )
	
	--print("爱玩悦登陆 :" .. self._szAccount .. self._szNickName)
	local cmddata = ExternalFun.create_netdata(logincmd.CMD_MB_LogonAiwanPlatform)

	cmddata:setcmdinfo(logincmd.MDM_MB_LOGON,logincmd.SUB_MB_LOGON_AIWAN)

	cmddata:pushword(--[[GlobalUserItem.nCurGameKind]]yl.INVALID_WORD)
	cmddata:pushdword(self._plazaVersion)
	cmddata:pushbyte(self._deviceType)
	cmddata:pushbyte(self._cbPlatform)
	--本地村 szaccount = uid  传的时候szaccount = username
	cmddata:pushstring(self._szAccount,yl.LEN_USER_UIN) 	--uid
	cmddata:pushstring(self._szMachine,yl.LEN_MACHINE_ID)	--machine
	cmddata:pushstring(self._szPassword,yl.LEN_PASSWORD) 	--account
	cmddata:pushstring(self._szNickName,yl.LEN_ACCOUNTS) 	--pwd
    cmddata:pushstring(strtable.cip,16)
	--渠道号
    cmddata:pushword(appdf.CHANNEL_ID)
	print("登陆参数")
	--dump(self._szAccount)
	if not self:sendSocketData(cmddata) and nil ~= self._callBack then
		self._callBack(-1,"发送爱悦玩登陆失败！")
	end
end



--天宇游登陆
function LogonFrame:sendTYYLogin( )
    

    self._szPassword =  GlobalUserItem.PasswordEncryption("com.5185931.yx217.pass")
    print("554422")
	local cmddata = ExternalFun.create_netdata(logincmd.CMD_MB_LogonAiwanPlatform)
     print("edfefe")

	cmddata:setcmdinfo(logincmd.MDM_MB_LOGON,logincmd.SUB_MB_LOGON_AIWAN)

     print("rthrthtrh")
	cmddata:pushword(--[[GlobalUserItem.nCurGameKind]]yl.INVALID_WORD)
     print("3524545")
     print(yl.INVALID_WORD)
     print("xiaobai11:")
	cmddata:pushdword(self._plazaVersion)
     print(self._plazaVersion)
     print("xiaobai22:")



	cmddata:pushbyte(self._deviceType)
       print(self._deviceType)
     print("xiaobai33:")

	cmddata:pushbyte(self._cbPlatform)

      print(self._cbPlatform)
     print("xiaobai44:")
	--本地村 szaccount = uid  传的时候szaccount = username
    print(self._szAccount)
    cmddata:pushstring(self._szAccount,yl.LEN_USER_UIN) 	--uid
     print(self.szUserUin)
     print("xiaobai88:")

     print(self._szAccount)
     print("xiaobai55:")


    cmddata:pushstring(self._szMachine,yl.LEN_MACHINE_ID)	--machine
	cmddata:pushstring(self._szPassword,yl.LEN_PASSWORD) 	--account
	cmddata:pushstring(self._szNickName,yl.LEN_ACCOUNTS) 	--pwd
    cmddata:pushstring(strtable.cip,16)
	--渠道号
    cmddata:pushword(appdf.CHANNEL_ID)
    cmddata:pushword(self._szVerification)

        

	print("登陆参数")

	--dump(self._szAccount)
	if not self:sendSocketData(cmddata) and nil ~= self._callBack then
		self._callBack(-1,"天宇游登陆失败！")
	end
end



function LogonFrame:sendRegister()

	local RegisterData = CCmd_Data:create(334)
	RegisterData:setcmdinfo(yl.MDM_MB_LOGON,yl.SUB_MB_REGISTER_ACCOUNTS)

	RegisterData:pushword(--[[GlobalUserItem.nCurGameKind]]yl.INVALID_WORD)
	RegisterData:pushdword(self._plazaVersion)
	RegisterData:pushbyte(self._deviceType)

	RegisterData:pushstring(self._szRegPassword,yl.LEN_MD5)

	RegisterData:pushword(1)
	RegisterData:pushbyte(self._cbRegGender)

	RegisterData:pushstring(self._szRegAccount,yl.LEN_ACCOUNTS)
	RegisterData:pushstring(self._szRegNickName,yl.LEN_NICKNAME)

	RegisterData:pushdword(tonumber(self._szSpreader))

	RegisterData:pushstring(self._szMachine,yl.LEN_MD5)
	RegisterData:pushstring(self._szMobilePhone,yl.LEN_MOBILE_PHONE)
	--RegisterData:pushstring(self._szVerifcode ,7)
    RegisterData:pushstring(strtable.cip,16)

	--渠道号
	if device.platform == "ios" and appdf.CHANNEL_ID == 1 then
        RegisterData:pushword(0)
    elseif  device.platform == "android" or device.platform == "ios" then
		RegisterData:pushword(appdf.CHANNEL_ID)
	elseif device.platform == "windows" then
		RegisterData:pushword(4)
    end

	local a = self._szMachine


	--发送失败
	if not self:sendSocketData(RegisterData) and nil ~= self._callBack then
		self._callBack(-1,"发送注册失败！")
	end
end
return LogonFrame