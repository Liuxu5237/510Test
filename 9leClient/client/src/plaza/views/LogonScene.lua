--[[
  登录界面
      2015_12_03 C.P
      功能：登录/注册
--]]

cc.FileUtils:getInstance():addSearchPath("base/src/")
cc.FileUtils:getInstance():addSearchPath("base/res/")
cc.FileUtils:getInstance():addSearchPath("client/src/")
cc.FileUtils:getInstance():addSearchPath("client/res/")
local LogonScene = class("LogonScene", cc.load("mvc").ViewBase)

if not yl then
	appdf.req(appdf.CLIENT_SRC.."plaza.models.yl")
end
if not GlobalUserItem then
	appdf.req(appdf.CLIENT_SRC.."plaza.models.GlobalUserItem")
end

local PopWait = appdf.req(appdf.BASE_SRC.."app.views.layer.other.PopWait")
local QueryExit = appdf.req(appdf.BASE_SRC.."app.views.layer.other.QueryDialog")

local GameServerItem   = appdf.req(appdf.CLIENT_SRC.."plaza.models.GameServerItem")
local WebFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.WebFrame")
local LogonFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.LogonFrame")
local LogonLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.logon.LogonLayer")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local PopupLayerManager = appdf.req(appdf.EXTERNAL_SRC .. "PopupLayerManager")
local RequestManager = appdf.req(appdf.CLIENT_SRC.."plaza.models.RequestManager")
local CheckinFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.CheckinFrame")
local QueryDialog = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.QueryDialog")
local NoticeLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.NoticeLayer")

local  LogonLayerTianY = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.logon.LogonLayerTY")
--local ValidateLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.ValidateLayer")

local targetPlatform = cc.Application:getInstance():getTargetPlatform()


local cjson = appdf.req("cjson")


--全局处理lua错误
cc.exports.g_LuaErrorHandle = function ()
	cc.exports.bHandlePopErrorMsg = true
	if isDebug() then
		print("debug return")
		return true
	else
		print("release return")
		return false
	end
end

--加载配置
function LogonScene.onceExcute()
    
    --挪到welcome 

	local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")
	--文件日志
	LogAsset:getInstance():init(MultiPlatform:getInstance():getExtralDocPath(), true, true)

	--配置微信
	MultiPlatform:getInstance():thirdPartyConfig(yl.ThirdParty.WECHAT, yl.WeChat)
	--配置
    if not yl.APPSTORE_VERSION then
	     MultiPlatform:getInstance():thirdPartyConfig(yl.ThirdParty.zhifu_1, yl.zhifu_1)
    end
	--配置分享
	MultiPlatform:getInstance():configSocial(yl.SocialShare)
	--配置高德
	--MultiPlatform:getInstance():thirdPartyConfig(yl.ThirdParty.AMAP, yl.AMAP)

    --IP
    appdf.onHttpJsionTable("http://2019.ip138.com/ic.asp","GET",nil,function(jstable,jsdata)
    	dump(jsdata)
    	print(type(jsdata))

		if type(jsdata) == "string" then
			local indexfirst  = string.find(jsdata,"[[]")
			print(indexfirst)
			local indexend = string.find(jsdata,"[]]")
            local str = string.sub(jsdata,indexfirst+1,indexend-1)
            str = "{".."\"cip\":\""..str .."\"".."}"
			print(str1)
			strtable = cjson.decode(str)
            dump(strtable)
        else
            appdf.onHttpJsionTable("http://pv.sohu.com/cityjson","GET",nil,function(jstable,jsdata)
                dump(jsdata)
                print(type(jsdata))
        
                if type(jsdata) == "string" then
                    local indexfirst = string.find(jsdata,"{")
                    print(indexfirst)
                    local indexend = string.find(jsdata,"}")
                    local str = string.sub(jsdata,indexfirst,indexend)
                    print(str)
                    strtable = cjson.decode(str)
                    dump(strtable)
                end
            end)
        end

    end)


    --我也很伤心 初始化好后 就发
    function sdkInitCallbackFunc(jPrama)
        local data = cjson.decode(jPrama);	
    
        if data["tag"] == "success" then
             
	    elseif data["tag"] == "fail" then
		
	    end		
    end   

    if appdf.CHANNEL_ID == 1004 then
        appdf.req("client.src.external.sdk.YijieInterface")  --易接SDK
        local yijie = YijieInterface.new()
        yijie:setSDKInitListener(sdkInitCallbackFunc)
    end
   
end
LogonScene.onceExcute()

function LogonScene:requestServerConfig()

     --/抢救状态
    if  appdf.isErrorLogin == true then
        
        appdf.ENV = 2

        appdf.isErrorLogin  =true
        
        appdf.HTTP_SERVER_URLS[appdf.ENV] = cc.UserDefault:getInstance():getStringForKey("WZHTAddress")          
        appdf.HTTP_SERVER_URL =appdf.HTTP_SERVER_URLS[appdf.ENV]
        yl.HTTP_SERVER_URL =  appdf.HTTP_SERVER_URL

		--公告地址
        appdf.HTTP_NOTICE_URL_LIST[appdf.ENV] = cc.UserDefault:getInstance():getStringForKey("NoticeAddress")         
        appdf.HTTP_NOTICE_URL  = appdf.HTTP_NOTICE_URL_LIST[1]
        yl.HTTP_NOTICE_URL     = appdf.HTTP_NOTICE_URL  

        --支付宝配置
        yl.zhifu_1[4] =  yl.HTTP_URL .. "/Pay/ZFB/notify_url.aspx"

--       -- 服务器区分列表
--		--appdf.SERVER_LIST[1]=cc.UserDefault:getInstance():getStringForKey("HKAddress")  -- 区分ios android
--		if device.platform == "ios" then
--			appdf.SERVER_LIST[appdf.ENV]=cc.UserDefault:getInstance():getStringForKey("IOSAddress") 
--		else
--			appdf.SERVER_LIST[appdf.ENV]=cc.UserDefault:getInstance():getStringForKey("AndroidAddress") 					
--		end

        appdf.LOGONSERVER  = appdf.SERVER_LIST[appdf.ENV]          --登录地址;/
        -- 登陆地址列表
        yl.SERVER_LIST[1]= appdf.LOGONSERVER 
        -- 当前地址索引
        yl.CURRENT_INDEX = 1
        yl.TOTAL_COUNT = #yl.SERVER_LIST
	    yl.LOGONSERVER	= yl.SERVER_LIST[yl.CURRENT_INDEX] --@login_ip


    else
        local enjoinApple= cc.UserDefault:getInstance():getIntegerForKey("isAppAuditing")

		--审核开关 1 审核 2 通过
		if tonumber(enjoinApple) == 1 then 
			yl.APPAuditing = true
            --马甲包特殊处理
            --yl.IS_MAJIA   = true
		else
			yl.APPAuditing = false
             --马甲包特殊处理
            yl.IS_MAJIA   = false
		end
        yl.APPSTORE_VERSION =  (device.platform == "ios") and yl.APPAuditing 

		--测试时打开注释
		--appdf.ENV = 2
					
		--1.香港 2.正式服 3测试
		--网站地址不用动态 这个只能热更
		--提审 打包网站地址为香港网站地址，然后热更把地址改为正式服
        --后台网站地址
        
       appdf.HTTP_SERVER_URLS[appdf.ENV] = cc.UserDefault:getInstance():getStringForKey("WZHTAddress")          
       appdf.HTTP_SERVER_URL =appdf.HTTP_SERVER_URLS[appdf.ENV]
       yl.HTTP_SERVER_URL =  appdf.HTTP_SERVER_URL

		--公告地址
       appdf.HTTP_NOTICE_URL_LIST[appdf.ENV] = cc.UserDefault:getInstance():getStringForKey("NoticeAddress")         
       appdf.HTTP_NOTICE_URL  = appdf.HTTP_NOTICE_URL_LIST[1]
       yl.HTTP_NOTICE_URL     = appdf.HTTP_NOTICE_URL  

       --支付宝配置
       yl.zhifu_1[4] =  yl.HTTP_URL .. "/Pay/ZFB/notify_url.aspx"

       -- 服务器区分列表
		--appdf.SERVER_LIST[1]=cc.UserDefault:getInstance():getStringForKey("HKAddress")  -- 区分ios android
		if device.platform == "ios" then
			appdf.SERVER_LIST[appdf.ENV]=cc.UserDefault:getInstance():getStringForKey("IOSAddress") 
		else
			appdf.SERVER_LIST[appdf.ENV]=cc.UserDefault:getInstance():getStringForKey("AndroidAddress")
            --appdf.SERVER_LIST[appdf.ENV] = "192.168.31.219"
		end

       appdf.LOGONSERVER  = appdf.SERVER_LIST[appdf.ENV]          --登录地址;/
       -- 登陆地址列表
       yl.SERVER_LIST[1]= appdf.LOGONSERVER 
       -- 当前地址索引
       yl.CURRENT_INDEX = 1
       yl.TOTAL_COUNT = #yl.SERVER_LIST
		yl.LOGONSERVER	= yl.SERVER_LIST[yl.CURRENT_INDEX] --@login_ip
     end

       
	
end






    --登陆验证
function LogonScene:encodeURI(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end

function LogonScene:webLogonCallBack( result,message2 )
    print("真的登录webframe" .. message2)
    local action2 = cjson.encode(message2)
    local message = cjson.decode(message2)

    if yl.LogonSchedule then
        yl._clientConnectedCount = 0
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(yl.LogonSchedule)
        yl.LogonSchedule = nil
    end

    --微信登录
    if message[3]~= nil and message[3]["lErrorCode"] == 1062 then
        local action = {}
        action["ChannelID"] = self:getChannelID()
        action["szAccounts"]= self._tThirdData.accounts
        action["szPassWord"]= GlobalUserItem.PasswordEncryption(self._tThirdData.pwd) 
        action["machineSerial"] = MultiPlatform:getInstance():getMachineId()
        action["szComputerID2"] = MultiPlatform:getInstance():getMachineId2()   
        action["IP"] = strtable.cip
        local pargams = {1,11,action}
       
        local action2 = cjson.encode(pargams)
        self._webFrame:wsSendString(action2) 
        --超时弹窗
        self:scheduleCallback()
    end

    --[1,101,{"lErrorCode":56},"122.228.29.63"]

    --微信登录
    if message[1] == 1 and message[2] == 101  then

        dismissPopWait()

        if message[3]["lErrorCode"] == 217 then
            --微信
            if self._Operate == 3 then
                --不存在 去注册
                local action = {}
  
                action["szAccounts"]        = self._tThirdData.accounts
                action["szPassWord"]        = GlobalUserItem.PasswordEncryption(self._tThirdData.pwd)                     
                action["szSpreader"]        = 0
                action["wFaceID"]           = math.random(1, 5)
                action["cbGender"]          = self._tThirdData.gender    
                action["dwPlazaVersion"]    = self:getChannelID()
                action["szTrueName"]        = ""
                action["szComputerID"]      = MultiPlatform:getInstance():getMachineId()
                action["szComputerID2"] =   MultiPlatform:getInstance():getMachineId2()   
 
                action["wCityNum"]          = ""
                action["cbEnjoyType"]       = ""
                action["szNickName"]        = self._tThirdData.nickname
                action["szIdentity"]        = ""
                action["szEnjoyCode"]       = ""
                action["channelid"]         = self:getChannelID()
                action["szThirdPartyUrl"]    = self._tThirdData.headurl
                action["IP"] = strtable.cip
                local pargams = {1,3,action}      
                local action2 = cjson.encode(pargams)  
 
                self._webFrame:wsSendString(action2) 
            else
                showToast(nil,"账号不存在，请确认您的账号",2)
            end
            return

        elseif message[1] == 1 and message[2] == 101 and message[3]["lErrorCode"] == 1060 then
            showToast(nil,"今日注册机器码达到上限",2)
            return
        elseif message[1] == 1 and message[2] == 101 and message[3]["lErrorCode"] == 1059 then
            showToast(nil,"今日注册IP达到上限",2)
            return
        --登录错误
        elseif message[1] == 1 and message[2] == 101 and message[3]["lErrorCode"] == 1 then
            showToast(nil,"账号不存在，请确认您的账号",2)
            return
        elseif message[1] == 1 and message[2] == 101 and message[3]["lErrorCode"] == 54 then
            showToast(nil,"账号不存在或者登录密码错误，请确认您账号密码",2)
            return
        elseif message[1] == 1 and message[2] == 111 and message[3]["code"] == 203 then
            showToast(nil,"登录密码错误，请确认您的密码",2)
            return
        elseif message[1] == 1 and message[2] == 101 and message[3]["lErrorCode"] == 214 then
            --需要验证
            self._logonLayer:onChenckUsertips()
            return
        elseif  message[1] == 1 and message[2] == 101 and message[3]["lErrorCode"] == 206 then
            showToast(nil,"手机验证码错误，请您仔细检查哟!",2)
            return
        elseif  message[1] == 1 and message[2] == 101 and message[3]["lErrorCode"] == 56 then
            
            showToast(nil,"您的账号已被冻结，详细信息请联系客服处理!",2)
            return    
        end
 
    end

    --强行推出游戏 挪到webframe里面
    if message[1] == 1 and message[2] == 106 then
        -- yl.isReExit = true
        -- yl.reKindID = message[3]["KindID"]
        -- yl.reServerID = message[3]["ServerID"]

    end
    --登录成功回调
    if message[2] == 100 then
        print("用户信息设置")

        GlobalUserItem.cbGender         = message[3]["cbGender"]
        GlobalUserItem.wFaceID          = message[3]["wFaceID"]
        GlobalUserItem.dwCustomID       = message[3]["wFaceID"]
        GlobalUserItem.dwUserID         = message[3]["dwUserID"]
        GlobalUserItem.dwGameID         = message[3]["GameID"]
            
        GlobalUserItem.szAccount        = message[3]["accounts"]
        GlobalUserItem.szNickName       = message[3]["nickname"]
        GlobalUserItem.lUserScore       = tonumber(message[3]["dwFortuneCoin"]) 
        GlobalUserItem.dUserBeans       =  message[3]["dwGold"]
        GlobalUserItem.cbInsureEnabled  = message[3]["isInsure"]
        GlobalUserItem.szMobilePhone    = message[3]["Phone"]
        GlobalUserItem.szThirdPartyUrl  = message[3]["FU"]
        GlobalUserItem.dwUserRight      = message[3]["C"]
        GlobalUserItem.szSign           = message[3]["szSign"]
        GlobalUserItem.cbMemberOrder    = message[3]["V"]  
        --1 开 0关 赠送开关
        GlobalUserItem.cbTransfer       = message[3]["Z"]  
        if message[3]["bFirstPay"] == 1  then
            GlobalUserItem.bFirstPay = true
        else
            GlobalUserItem.bFirstPay = false
        end
        if message[3]["cfg"] ~= nil then
            if message[3]["cfg"]["bulletin"] ~=nil then
                yl.m_RepeatNotice               = message[3]["cfg"]["bulletin"]
            end
            if message[3]["cfg"]["bank"] ~=nil then
                if self:getApp()._funList == nil then
                    self:getApp()._funList = {}
                end
                if message[3]["cfg"]["bank"] == 1 then
                    self:getApp()._funList.GiveModule  = 2 -- 有赠送
                else
                    self:getApp()._funList.GiveModule  = 1 -- 没有赠送
                end
               
            end
        end
       
        
        --GlobalUserItem.bFirstPay    = message[3]["bFirstPay"]
        
        self:onLogonCallBack(1,"")

        self._tempAllRoom = {}

        if  appdf.CHANNEL_ID == 107 then 
            local action = {}
            action["deviceid"]        = MultiPlatform:getInstance():getMachineIdByZ()
            action["accounts"]        = GlobalUserItem.szAccount
            action["gameid"]          = GlobalUserItem.dwGameID
            local pargams = {1,27,action}
           
            local action2 = cjson.encode(pargams)
            self._webFrame:wsSendString(action2) 
        end
    elseif message[2] == 99 then
        print("房间信息")
        print("wkindid" ..message[3]["wKindID"][1])
        print(#message[3]["szServerName"])
        local itemcount = #message[3]["szServerName"]
        --读取房间信息
	    for i = 1,itemcount do
		    local item = GameServerItem:create()
						:onInit(message[3],i)
		    if not item then 
			    break
		    end
	
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
		
        end
        
        --撸一份sortid  serverLeverl

        for k,v in pairs(self._tempAllRoom) do
             
            local z =#self._tempAllRoom[k]
                    
                if k ~= 200 then
                    local ztroom = self._tempAllRoom[k][z]
                    table.remove(self._tempAllRoom[k])
                    table.insert( self._tempAllRoom[k], 1 ,ztroom )
                    self._tempAllRoom[k][1].wServerType = 8
                    for j=1,#self._tempAllRoom[k] do
                        self._tempAllRoom[k][j].wSortID = j 
                        self._tempAllRoom[k][j].wServerLevel = j - 1
                    end
                elseif k == 200 then
                    for j=1,#self._tempAllRoom[k] do
                        self._tempAllRoom[k][j].wSortID = j 
                        self._tempAllRoom[k][j].wServerLevel = j
                    end
                    
                end
                   
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
        --dump(GlobalUserItem.roomlist)

    elseif message[1] == 1 and message[2] == 102 then
        dismissPopWait()
        yl.IsWxEnterBack = false
        yl.CurrentScene	= yl.nowScene.Z_CLIENTSCENE
        self:getApp():enterSceneEx(appdf.CLIENT_SRC.."plaza.views.ClientScene",nil,0)  
    end

    
end

-- 初始化界面
function LogonScene:onCreate()
    
    yl.CurrentScene	= yl.nowScene.Z_LOGONSCENE

    if cc.PLATFORM_OS_WINDOWS == targetPlatform then
        ds.MyNotification:getInstance():registerLuaEventCallBack("WINDWOS_CLOSE",function()
            if self._dialog then
                return
            end
            self._dialog = QueryDialog:create("是否退出510游戏？",function(bReTry)
                        if bReTry == true then
                            os.exit(0)
                        else
                            self._dialog = nil
                        end
                    end)
                    :setCanTouchOutside(false)
                    :addTo(self)
        end)
    end

    self:requestServerConfig()
	print("LogonScene:onCreate()")


     --安卓返回键
     if device.platform == "android" then
        local function onrelease(code, event)

            if code == cc.KeyCode.KEY_BACK then
                if self._dialog1 then
                    return
                end
                if self._logonLayer ~= nil then
                    dismissPopupLayer(self._logonLayer)
                    self:onLogonLayerClose()
                end
                self._dialog1 = QueryDialog:create("是否退出510游戏？",function(bReTry)
    
                        if bReTry == true then
                            os.exit(0)
                        else
                            self._dialog1 = nil
                        end
                            end)
                            :addTo(self)
    
            elseif code == cc.KeyCode.KEY_HOME then
    
            end
    
        end
    
        --监听手机返回键
        local listener = cc.EventListenerKeyboard:create()
        listener:registerScriptHandler(onrelease, cc.Handler.EVENT_KEYBOARD_RELEASED)
        --lua中得回调，分清谁绑定，监听谁，事件类型是什么
        local eventDispatcher =cc.Director:getInstance():getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener,self)
    end

    local this = self
    local dispacther = cc.Director:getInstance():getEventDispatcher()
	dispacther:addEventListenerWithSceneGraphPriority(
        cc.EventListenerCustom:create("ry_ReConnectLogonCallback", handler(self, function ( event )
            self._webFrame = WebFrame:create(self, function(result, message)
                self:webLogonCallBack(result,message)
            end)
            self._webFrame:wsSendString(yl.webStrdata) 
        end)),
        self
		)

    --伤心
    function awylogin( jstable)
        --发起登陆消息
        local action2 = cjson.encode(jstable)
        local msg =  cjson.decode(jstable)   --json转table  
        --print("爱悦玩难受想哭:" .. action2)
        --第三方校验
        --print(type(msg))
        
        local url = "https://api.123awy.com/Api/Member/CheckLogin?"

        local sessid = msg["sessid"]
        local gametoken = msg["gametoken"]
        local time = msg["time"]
        local uid = msg["uid"]
        local username = msg["username"]
        local pwd = msg["pwd"]
        self.m_idUseID = uid
        self._zAWYData = 
        {
            uid = uid,
            pwd = pwd,
            username = username,
            platform = 7,
        }

        local sign = "100016"..uid..gametoken..sessid..time.."16fe111b28003f27596146a260850364"
        --print("加密前的md5" .. sign)
        sign =  string.lower( md5(sign) )
        --print("加密后的md5" .. sign)

        local action  = url .. "appid=100016" .. "&uid="..uid.."&token="..gametoken.."&time="..time.."&sessid="..sessid.."&sign="..sign
        appdf.onHttpJsionTable(action ,"GET", "", function(jstring,jsdata)
            --对象已经销毁
            -- if not appdf.isObject(self) then
            --     return
            -- end
            -- dump(jsdata)
            -- print(type(jsdata))
            if type(jsdata) ~= "string" then
                return
            end
            
            --判断发送是否成功
            if jsdata == "success" then
                --showToast(nil, "校验成功", 3)
                self:onLogonByAwy(uid,username,pwd)
            elseif msg == "fail_1" then
                showToast(nil, "token不能为空", 2)
            elseif msg == "fail_2" then
                showToast(nil, "签名错误,请重新登陆", 2)
            elseif msg == "fail_3" then
                showToast(nil, "签名错误,请重新登陆", 2)
            elseif msg == "fail_4" then
                showToast(nil, "用户登陆错误", 2)
            elseif msg == "fail_5" then
                showToast(nil, "登陆失败", 2)
            end        
        end)

    end


    
    --登陆回调易接 登录成功验证
    function loginYiWnback(jPrama)
	    local data = cjson.decode(jPrama);
     
	    if data["result"] == "success" then--登陆成功
            --发起登陆消息
            local url = yl.HTTP_URL.."/YiJie/Check.aspx"
                
            local sessid = data["token"]
            local uid = data["channelUserId"]
            self._zAWYData = 
            {   
                uid = uid,

            }

            GlobalUserItem.thirdPartyData = self._zAWYData
            local action  = url.."?app="..self:encodeURI(data["productCode"])
            action = action.."&sdk="..self:encodeURI(data["channelId"])
            action = action.."&uin="..self:encodeURI(data["channelUserId"])
            action = action.."&sess="..self:encodeURI(data["token"])
     
            appdf.onHttpJsionTable(action ,"GET", "", function(jstring,jstable)
      
            local isNewActivity = cjson.decode(jstable)
    
            if isNewActivity["msg"] == "success" then
         
                appdf.req("client.src.external.sdk.YijieInterface")  --易接SDK
                local yijie = YijieInterface.new()
                yijie:setRoleData(uid, uid, "1", "1", "一区")
         
                -- 校验成功 去发起登陆
                self:onLogonByTyy(uid,0)
			    local tab = {}
			    tab["roleId"]="1"
			    tab["roleName"]=uid
			    tab["roleLevel"]="1"
			    tab["zoneId"]="1"
			    tab["zoneName"]="一区"
			    tab["balance"]="0"
			    tab["vip"]="1"
			    tab["partyName"]="无帮派"
			    tab["roleCTime"]="21322222"
			    tab["roleLevelMTime"]="54456556"
                local jsonData = cjson.encode(tab)
                yijie:setDataString("enterServer",jsonData); -- 选择服务器进入时调用   必接

            else
  
                showToast(nil, "验证失败~", 2)
                appdf.req("client.src.external.sdk.YijieInterface")  --易接SDK
                local yijie = YijieInterface.new()
                yijie:login("login")       
                  
            end  

        end)

	elseif data["result"] == "fail" then--登陆失败
          appdf.req("client.src.external.sdk.YijieInterface")  --易接SDK
          local yijie = YijieInterface.new()
          showToast(nil, "登录失败~", 2)
          yijie:login("login")
	elseif data["result"] == "logout" then--登出回调
--          appdf.req(appdf.CHANNE_SDK_SRC.."YijieInterface")  --易接SDK
--          local yijie = YijieInterface.new()
--          showToast(nil, "登录失败~", 2)
--          yijie:logout("logout")--登出
--          yijie:login("login")
--          print("sdfdfsdfe")
	end
end

    --网络处理
    self._logonFrame = LogonFrame:create(self, function(result, message)
        self:onLogonCallBack(result, message)
    end)


    --节点事件
    ExternalFun.registerNodeEvent(self)

    --背景
    cc.Sprite:create("base/res/loginBG.jpg")
    :setAnchorPoint(0.5,0.5)
    --:setScaleY(1.1)
    :setPosition(appdf.WIDTH/2, appdf.HEIGHT/2)
    :addTo(self)

      --左上角图标
      self._LeftLog = cc.Sprite:create("base/res/logo222.png")
       :setPosition(appdf.WIDTH / 2 , appdf.HEIGHT / 2 +60)
       ---:setScale(0.5)
       :addTo(self)

 
    --logo
    self._logo = cc.Sprite:create("base/res/loginBG_niu.png")
        :setPosition(appdf.WIDTH / 2 +355, appdf.HEIGHT / 2 +5)
        :setVisible(false)        
       -- :setOpacity(yl.APPSTORE_VERSION and 0 or 255)
        :addTo(self)

--    --animal
--     self._animal = cc.Sprite:create("base/res/Logingirl.png")
--         :setPosition(appdf.WIDTH / 2 , appdf.HEIGHT / 2 -10)
--         :addTo(self)


    --温馨提示
    self.ReminderImage = cc.Sprite:create("base/res/botzhgao.png")
    :setPosition(appdf.WIDTH / 2 ,20)
    :addTo(self)

    if appdf.CHANNEL_ID == 2001 then
        if yl.APPSTORE_VERSION == false  then 
            --爱悦玩处理
            self._animal:setVisible(false)
            self._logo:setVisible(false)
            self._LeftLog:setVisible(false)
            MultiPlatform:getInstance():initAWYWithLogin(awylogin)
            return
        end
    end 


     --如果是这鸟 他就是易接哦
    if appdf.CHANNEL_ID == 1004 then
        
        appdf.req("client.src.external.sdk.YijieInterface")  --易接SDK
        local yijie = YijieInterface.new()
            
        yijie:setLoginListener(loginYiWnback)
        yijie:login("login") print("11122121")
        return 
  
    end 
    
   
    --公告
    local btnNotice = ccui.Button:create("Logon/Logon/btn_notice.png","")
	btnNotice:setPosition(appdf.WIDTH -50, appdf.HEIGHT -50)
    btnNotice:addClickEventListener(function() 
        
	end)
	btnNotice:setVisible(not yl.APPSTORE_VERSION)
    btnNotice:addTo(self)
    btnNotice:setVisible(false)

--    --提示文本
--    local tip = "v " .. appdf.BASE_C_VERSION .. "." .. (self:getApp()._version:getResVersion() or appdf.BASE_C_RESVERSION .. "." .. appdf.CHANNEL_ID)
--	self._txtTips = cc.Label:createWithTTF(tip, "fonts/round_body.ttf", 24)
--		:setTextColor(cc.WHITE)
--		:setAnchorPoint(cc.p(1,0))
--		:enableOutline(cc.c4b(0,0,0,255), 1)
--		:move(appdf.WIDTH,0)
--		:addTo(self)

    --微信登录
    self._btnLogonWx = ccui.Button:create("Logon/LoginBtn1.png", "")
    self._btnLogonWx:setPosition(appdf.WIDTH / 2 - 230, 150)
    self._btnLogonWx:setVisible(true)
    self._btnLogonWx:addClickEventListener(function() self:onClickWx() end)
    self._btnLogonWx:addTo(self)

    --游客登录
    self._btnLogonVisitor = ccui.Button:create("Logon/logon_visitor_0.png", "Logon/logon_visitor_1.png")
    self._btnLogonVisitor:setPosition(appdf.WIDTH / 2, 130)
    self._btnLogonVisitor:setVisible(false)
    self._btnLogonVisitor:addClickEventListener(function() self:onClickVisitor() end)
    self._btnLogonVisitor:addTo(self)

    --账号登录
    self._btnLogonAccount = ccui.Button:create("Logon/LoginBtn2.png", "")
    self._btnLogonAccount:setPosition(appdf.WIDTH / 2 +220, 150)
    self._btnLogonAccount:setVisible(true)
    self._btnLogonAccount:addClickEventListener(function() self:onClickAccount() end)
    self._btnLogonAccount:addTo(self)


    --刷新按钮
    self:onRefreshLogonButtons()

	--读取配置
	GlobalUserItem.LoadData()

    --背景音乐
    ExternalFun.playPlazzBackgroudAudio()
 
    if yl.APPSTORE_VERSION  then 
		self:onPassReview()
    end
    
    -- self._webFrame = WebFrame:create(self, function(result, message)
    --     self:webLogonCallBack(result,message)
    -- end)

    --暂时不用[CRL][2017.12.11]
    --[[--键盘监听事件
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(function(keyCode, event)
            if keyCode == cc.KeyCode.KEY_BACK then
                if self.isQuery == nil then
                    self.isQuery = QueryDialog:create("是否退出510游戏？",function(bReTry)
                        if bReTry == true then
                            os.exit(0)
                        end
                        self.isQuery = nil
                    end)
                    :addTo(self)
                end
            end
        end, cc.Handler.EVENT_KEYBOARD_RELEASED )
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)--]]
    --微信第一次登录赠送奖励
--    if GlobalUserItem.thirdPartyData.accounts == nil or GlobalUserItem.thirdPartyData.accounts == "" then

--        if yl.SHOW_WECHAT_REWARD == nil then
--            yl.SHOW_WECHAT_REWARD = true
--            showToast(self, "微信首次登录即可获得30万游戏币哦，快来领取吧！", 10)
--        end
--    end





--    local url = "http://192.168.31.242:8011/YiJie/Check.aspx"


--       local action  = url.."?app=".."123"
--      action = action.."&sdk=".."123"
--      action = action.."&uin=".."123"
--      action = action.."&sess=".."332"
--      print(action)
--      print("565656")

--        appdf.onHttpJsionTable(action ,"GET", "", function(jstring,jstable)

--              print(type(jstable))

--            local action2 = cjson.decode(jstable)


--              local msg = action2["msg"]
--             local data = action2["data"]


--               print("msg111:--------")
--               print(jstring)
--                print("2222222:--------")
--               print(jstable)
--               print(type(jstable))


--            if type(jstable) == "table" then        
--            local isNewActivity = jstable["msg"]

--             print(isNewActivity)
--            dump(isNewActivity)

--            --判断发送是否成功
--               print("vvvvvvvvvvvvv")
--            if isNewActivity == "success" then
--            print("xiaokKK")
--                -- 校验成功 去发起登陆
--                  self:onLogonByTyy(uid)

--            else
--                showToast(nil, "登陆失败~", 2)       
--                 print("888")                 
--            end  
--           end 

--        end)



end

function LogonScene:onLogonByAwy( uid ,username,pwd)

    --print("平台编号" .. yl.PLATFORM_LIST[1])
    --dump(self._zAWYData)
    print("===========爱悦玩登录===========")
    showPopWait(true, 10)
    self._Operate = 4
    --参数记录
    self._szAccount = uid
    self._szNickName = username    
	self._szPassword = GlobalUserItem.PasswordEncryption(pwd)
    self._logonFrame:onLoginByAWY(uid, username,self._szPassword, 7)
    
     --防止用户登录一直转圈
     self:runAction(cc.Sequence:create(cc.DelayTime:create(10.0), cc.CallFunc:create(function()
        dismissPopWait()
    end)))
end


--天宇游
function LogonScene:onLogonByTyy(uid, verIphoen)

    --print("平台编号" .. yl.PLATFORM_LIST[1])
    --dump(self._zAWYData)
    print("===========天宇游登录===========")
    print(uid)
    showPopWait(true, 10)
    self._Operate = 5
    --参数记录
    self._szAccount = uid
    --没验证之前全部传递0
    self._logonFrame:onLoginByTYY(uid,8,verIphoen)
     --防止用户登录一直转圈
     self:runAction(cc.Sequence:create(cc.DelayTime:create(10.0), cc.CallFunc:create(function()
        dismissPopWait()
    end)))
end

function LogonScene:onPassReview()
    self._LeftLog:setVisible(false)
    self._btnLogonVisitor:setVisible(true)
    self._btnLogonVisitor:setPosition(appdf.WIDTH / 2 - 230, 134)
    self._btnLogonWx:setVisible(false)
    self._btnLogonAccount:setPosition(cc.p(appdf.WIDTH / 2 +220 , 134))
end
--------------------------------------------------------------------------------------------------------------------
-- 事件处理

--退出场景
function LogonScene:onExit()
    if cc.PLATFORM_OS_WINDOWS == targetPlatform then
        ds.MyNotification:getInstance():unRegisterEventListener("WINDWOS_CLOSE")
    end
    if self._logonFrame:isSocketServer() then
        self._logonFrame:onCloseSocket()
    end
end

--进入场景完成
function LogonScene:onEnterTransitionFinish()

    self:runAction(
        cc.CallFunc:create(function()

            --显示安全验证
            --showPopupLayer(ValidateLayer:create())
        end)
    )

end

--刷新登录按钮
function LogonScene:onRefreshLogonButtons()

    local logonBtns = {}

--    if MultiPlatform.getInstance():isPlatformInstalled(yl.ThirdParty.WECHAT) then --已安装微信，才显示微信登录
--        table.insert(logonBtns, self._btnLogonWx)
--    end
--    --if not GlobalUserItem.getBindingAccount() then  --绑定过账号，就不显示游客登录了
--      -- table.insert(logonBtns, self._btnLogonVisitor)
--    --end

    --没有游客登录 微信按钮永远显示
    table.insert(logonBtns, self._btnLogonAccount)

    if yl.APPSTORE_VERSION  then 
        table.insert(logonBtns,self._btnLogonVisitor)
    else
        table.insert(logonBtns, self._btnLogonWx)
    end 
    
    local xStart = appdf.WIDTH / 2 + 350 * (1 - #logonBtns)
--    if #logonBtns == 1 then
--        xStart = appdf.WIDTH / 2
--    elseif #logonBtns == 2 then
--        xStart = appdf.WIDTH / 2 - 190
--    else
--        xStart = appdf.WIDTH / 2 - 380
--    end

--    for i = 1, #logonBtns do
--        logonBtns[i]:setVisible(true)
--        logonBtns[i]:setPosition(xStart + (i - 1) * 380, 130)
--    end

    --保存登录按钮
    self._logonButtons = logonBtns
end

--显示动画
function LogonScene:onShowAnimation()

    local nodes = { self._logo, self._animal }

    for i = 1, #nodes do

        local px, py = nodes[i]:getPosition()
        nodes[i]:setPosition(px, py + appdf.HEIGHT / 2)

        --动画跳入
        nodes[i]:runAction(cc.EaseBackOut:create(cc.MoveTo:create(0.4, cc.p(px, py))))
    end
end

--微信登录
function LogonScene:onClickWx()

    yl.IsWxEnterBack = true
    self._webFrame = WebFrame:create(self, function(result, message)
        self:webLogonCallBack(result,message)
    end)
    print("===========微信登录===========")

    --播放音效
    ExternalFun.playClickEffect()

    --平台判定
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_ANDROID == targetPlatform) then
		
        self._Operate = 3
        self._tThirdData = GlobalUserItem.thirdPartyData
        --dump(self._tThirdData)

	    showPopWait(true, 10)

        --使用保存的数据登录
        if type(self._tThirdData.accounts) == "string" and self._tThirdData.accounts ~= "" then

            local action = {}
            action["ChannelID"] = self:getChannelID()
            action["szAccounts"]= self._tThirdData.accounts 
            action["szPassWord"]= GlobalUserItem.PasswordEncryption(self._tThirdData.pwd)
            action["machineSerial"] = MultiPlatform:getInstance():getMachineId()
            action["szComputerID2"] = MultiPlatform:getInstance():getMachineId2()   
            action["IP"] = strtable.cip
            local pargams = {1,11,action}
                   
            local action2 = cjson.encode(pargams)

            self._webFrame:wsSendString(action2) 
            --超时弹窗
            self:scheduleCallback()
            --self._logonframe:onloginbythirdparty(self._tThirdData.accounts, self._tThirdData.nickname, self._tThirdData.gender, self._tThirdData.platform)
            return
        end

        local function loginCallBack ( param )

		    dismissPopWait()

		    if type(param) == "string" and string.len(param) > 0 then
			    local ok, datatable = pcall(function()
					    return cjson.decode(param)
			    end)
			    if ok and type(datatable) == "table" then
				    --dump(datatable, "微信数据", 5)
				    local accounts = datatable["unionid"] or ""
				    local nickname = datatable["screen_name"] or ""
				    local headurl = datatable["profile_image_url"] or ""
				    local gender = datatable["gender"] or "0"
				    gender = tonumber(gender)
				    local pwd = datatable["unionid"] or ""
				    self._tThirdData = 
				    {
					    accounts = accounts,
					    nickname = nickname,
                        headurl = headurl,
                        gender = gender,
                        pwd    = pwd,
					    platform = yl.PLATFORM_LIST[yl.ThirdParty.WECHAT],
				    }

                    --dump(self._tThirdData)

                    showPopWait()

                    
                    local action = {}
                    action["ChannelID"] = self:getChannelID()
                    action["szAccounts"]= accounts 
                    action["szPassWord"]= GlobalUserItem.PasswordEncryption(pwd)
                    action["machineSerial"] = MultiPlatform:getInstance():getMachineId()
                    action["szComputerID2"] = MultiPlatform:getInstance():getMachineId2()   
                    action["IP"] = strtable.cip
                    local pargams = {1,11,action}
                   
                    local action2 = cjson.encode(pargams)

                    self._webFrame:wsSendString(action2) 

				    --self._logonFrame:onLoginByThirdParty(accounts, nickname, gender, yl.PLATFORM_LIST[yl.ThirdParty.WECHAT])
			    end
		    end
	    end

        MultiPlatform:getInstance():thirdPartyLogin(yl.ThirdParty.WECHAT, loginCallBack)

        --防止用户取消微信登录一直转圈
        self:runAction(cc.Sequence:create(cc.DelayTime:create(5), cc.CallFunc:create(function()
			dismissPopWait()
		end)))
	elseif cc.PLATFORM_OS_WINDOWS == targetPlatform then
        if not getScreenSize then
            showToast(nil, "不支持的登录平台 ==> " .. targetPlatform, 2)
            return
        end
        self._Operate = 3
        -- self._tThirdData = GlobalUserItem.thirdPartyData
        -- --dump(self._tThirdData)

        -- showPopWait(true, 10)

        -- --使用保存的数据登录
        -- if type(self._tThirdData.accounts) == "string" and self._tThirdData.accounts ~= "" then
        --     self._logonFrame:onLoginByThirdParty(self._tThirdData.accounts, self._tThirdData.nickname, self._tThirdData.gender, self._tThirdData.platform)
        --     return
        -- end
        WebFrame:getInstance()
        self._webFrame = WebFrame:create(self, function(result, message)
            self:webLogonCallBack(result,message)
        end)

        --WIN32微信登陆界面
        local LogonLayerWithWin32 = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.logon.LogonLayerForWin")
        
        --隐藏
        self._logo:setVisible(false)

        self.ReminderImage:setVisible(false)
        for i = 1, #self._logonButtons do
            self._logonButtons[i]:setVisible(false)
        end
        self._logonLayer = LogonLayerWithWin32:create(self)
        showPopupLayer(self._logonLayer, false)
    else
		showToast(nil, "不支持的登录平台 ==> " .. targetPlatform, 2)
	end
end

function LogonScene:onLogonByWin32Wx( accounts, nickname, gender )
   
    local action = {}
    action["ChannelID"] = 4
    action["szAccounts"]= accounts 
    action["szPassWord"]= GlobalUserItem.PasswordEncryption(accounts)
    action["machineSerial"] = MultiPlatform:getInstance():getMachineId()
    action["IP"] = strtable.cip
    local pargams = {1,11,action}
   
    local action2 = cjson.encode(pargams)

    self._webFrame:wsSendString(action2) 

end

--游客登录
function LogonScene:onClickVisitor()

    print("===========游客登录===========")

    --播放音效
    ExternalFun.playClickEffect()

--	showPopWait(true,10)

--	self._Operate = 2
--	self._logonFrame:onLogonByVisitor()



  
end

--账号登录
function LogonScene:onClickAccount()

    print("===========账号登录===========")
    --播放音效
    ExternalFun.playClickEffect()

    --隐藏
    self._logo:setVisible(false)

    self.ReminderImage:setVisible(false)
   -- self._animal:setVisible(false)

    for i = 1, #self._logonButtons do
        self._logonButtons[i]:setVisible(false)
    end
    self._logonLayer = LogonLayer:create(self)
    showPopupLayer(self._logonLayer, false)
end

--------------------------------------------------------------------------------------------------------------------
-- LogonLayer 回调

--登录框关闭
function LogonScene:onLogonLayerClose()
    
    self._logo:setVisible(false)
    --self._animal:setVisible(true)

    for i = 1, #self._logonButtons do
        self._logonButtons[i]:setVisible(true)
    end


    if self.ReminderImage ~= nil then
        self.ReminderImage:setVisible(true)
    end

    --显示动画
    --self:onShowAnimation()
end

function LogonScene:scheduleCallback(  )
    print("开启啊啊啊啊")
    if yl.LogonSchedule == nil then
        yl.LogonSchedule = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
            
            yl._clientConnectedCount  = yl._clientConnectedCount +1

            if yl._clientConnectedCount <=3 then
                WebFrame:wsInitWebScoket()
            else
                dismissPopWait()
                yl._clientConnectedCount = 0
                yl.isClientConnectedFailed  = false
                if yl.LogonSchedule then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(yl.LogonSchedule)
                    yl.LogonSchedule = nil
                end

                --重启socket失败
                local qq = QueryDialog:create("网络连接超时",function(bReTry)
                
                end,nil,QueryDialog.QUERY_SURE)
                if self._logonLayer then
                    qq:addTo(self._logonLayer)
                else
                    qq:addTo(self)
                end
               

            end
         end, 2, false)
    else
        if yl.LogonSchedule then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(yl.LogonSchedule)
            yl.LogonSchedule = nil
        end
    end

end

--账号登录
function LogonScene:onLogonAccount(szAccount, szPassword, bSave, bAuto)
    --ws12882 e10adc3949ba59abbe56e057f20f883e
    --by ws "ws12882"
        
    self._webFrame = WebFrame:create(self, function(result, message)
        self:webLogonCallBack(result,message)
    end)
    
    local action = {}
    action["ChannelID"] = self:getChannelID()
    action["szAccounts"]= szAccount
    szPassword = GlobalUserItem.PasswordEncryption(szPassword)
    action["szPassWord"]= szPassword
    action["machineSerial"] = MultiPlatform:getInstance():getMachineId()
    action["szComputerID2"] = MultiPlatform:getInstance():getMachineId2()   
    action["IP"] = strtable.cip
    local pargams = {1,11,action}
   
    local action2 = cjson.encode(pargams)
    --local msg =  cjson.decode(action2)   
    self._webFrame:wsSendString(action2) 
    --超时弹窗
    self:scheduleCallback()
    
	--参数记录
	self._szAccount = szAccount
	self._szPassword = GlobalUserItem.PasswordEncryption(szPassword)
     --local Verification = 0
	 self._bAuto = bAuto
	 self._bSave = bSave

    showPopWait(true,10)
    self._Operate = 0
	-- self._logonFrame:onLogonByAccount(szAccount, self._szPassword, Verification)
end

--短信验证后账号登录
function LogonScene:onLogonAccountByCheckUser(Verification)

    self:onLogonAccount(self._szAccount,self._szPassword,self._bSave,self._bAuto)
    --showPopWait(true,10)
    -- self._Operate = 0
    -- self._logonFrame:onLogonByAccount(self._szAccount, self._szPassword, Verification)
end

--------------------------------------------------------------------------------------------------------------------
-- RegisterLayer 回调

--账号注册
function LogonScene:onRegisterAccount(szAccount, szNickName, szPassword, szSpreader ,mcode)

	--参数记录
	self._szAccount = szAccount
	self._szPassword = GlobalUserItem.PasswordEncryption(szPassword)
	self._bAuto = false
	self._bSave = true
	self._gender = math.random(1)

	--showPopWait(true,10)

    self._Operate = 1
    

    local action = {}
    szPassword = GlobalUserItem.PasswordEncryption(szPassword)
    action["A"]         = "mreg"
    action["mob"]       = szAccount
    action["NickName"]  = szNickName
    action["szPassWord"]= szPassword 
    action["mcode"]     = mcode
    action["ChannelID"] = self:getChannelID()
    action["wFaceID"]   = math.random(1, 5)
    action["cbGender"]  = math.random(0,1)    
    action["szComputerID"] =MultiPlatform:getInstance():getMachineId()
    action["szComputerID2"] = MultiPlatform:getInstance():getMachineId2()   
    action["IP"] = strtable.cip
    local pargams = {1,3,action}
   
    local action2 = cjson.encode(pargams)

    self._webFrame = WebFrame:create(self, function(result, message)
        self:webLogonCallBack(result,message)
    end)
    
    self._webFrame:wsSendString(action2) 
    --超时弹窗
    self:scheduleCallback()
	--self._logonFrame:onRegister(szAccount, szNickName, self._szPassword, self._gender,szSpreader)
end

--------------------------------------------------------------------------------------------------------------------
-- LogonFrame 回调

function LogonScene:getChannelID(  )
    local _channelid 
    if device.platform == "ios" and appdf.CHANNEL_ID == 1 then
        _channelid = 0
    elseif  device.platform == "android" or device.platform == "ios" then
		_channelid = appdf.CHANNEL_ID
	elseif device.platform == "windows" then
		_channelid =4
    end
    return _channelid
end
--短信验证返回
function LogonScene:onTYYReturnByCheckUser()

    self._logo:setVisible(false)
    if self.ReminderImage ~= nil then
        self.ReminderImage:setVisible(true)
    end

    if  self._logonLayer ~= nil then
        dismissPopupLayer(self._logonLayer)
    end


    appdf.req("client.src.external.sdk.YijieInterface")  --易接SDK
    local yijie = YijieInterface.new()
	yijie:logout("logout")--登出
    yijie:login("login")--登陆
end

function LogonScene:onLogonCallBack(result, message)
    if type(message) == "string" and message ~= "" then
        showToast(nil, message, 2)
        if appdf.CHANNEL_ID == 1004  then
        if  self._logonLayer ~= nil then
            dismissPopupLayer(self._logonLayer)
       end
        if result ~= 9 then
         if result ~= 1 then
            local sequence = cc.Sequence:create(
            cc.DelayTime:create(3),
            cc.CallFunc:create(function()
              local yijie = YijieInterface.new()
	          yijie:logout("logout")--登出
              yijie:login("login")--登陆
            end)
        )
        cc.Director:getInstance():getRunningScene():runAction(sequence)
      end

       end

     end
  end
    if result ~= 1 then
        dismissPopWait()
    end
    if result == 1 then --成功
		--本地保存
		if self._Operate == 2 then 					--游客登录
			GlobalUserItem.bAutoLogon = false
			GlobalUserItem.bSavePassword = false
			GlobalUserItem.szPassword = GlobalUserItem.PasswordEncryption("com.5185931.yx217.pass")
			--GlobalUserItem.szAccount = GlobalUserItem.szNickName
		elseif self._Operate == 3 then 				--微信登陆
			GlobalUserItem.szThirdPartyUrl = self._tThirdData.headurl
			GlobalUserItem.szPassword = GlobalUserItem.PasswordEncryption("com.5185931.yx217.pass")
			GlobalUserItem.bThirdPartyLogin = true
			GlobalUserItem.thirdPartyData = self._tThirdData
			--GlobalUserItem.szAccount = GlobalUserItem.szNickName

            --保存第三方登录数据，下次可以直接登录不用验证
            cc.UserDefault:getInstance():setStringForKey("thirdparty_accounts", self._tThirdData.accounts)
            cc.UserDefault:getInstance():setStringForKey("thirdparty_nickname", self._tThirdData.nickname)
            cc.UserDefault:getInstance():setStringForKey("thirdparty_headurl", self._tThirdData.headurl)
            cc.UserDefault:getInstance():setIntegerForKey("thirdparty_gender", self._tThirdData.gender)
            cc.UserDefault:getInstance():setIntegerForKey("thirdparty_platform", self._tThirdData.platform)
            cc.UserDefault:getInstance():setStringForKey("thirdparty_pwd", self._tThirdData.pwd)

            dump(self._tThirdData)
        elseif self._Operate == 4 then  --爱玩悦登陆
            GlobalUserItem.bThirdPartyLogin = true
			GlobalUserItem.thirdPartyData = self._zAWYData

        elseif self._Operate == 5 then  --天宇游登陆
          GlobalUserItem.bThirdPartyLogin = true
		  GlobalUserItem.szPassword = GlobalUserItem.PasswordEncryption("com.5185931.yx217.pass")
          
        else
            GlobalUserItem.szPassword = self._szPassword
			GlobalUserItem.bAutoLogon = self._bAuto
			GlobalUserItem.bSavePassword = self._bSave
			GlobalUserItem.onSaveAccountConfig()
		end
        dismissPopWait()
        if cc.PLATFORM_OS_WINDOWS == targetPlatform then
            self._logonLayer:onExit()
            --closeWebWindow()
        end
        --self:getApp():enterSceneEx(appdf.CLIENT_SRC.."plaza.views.ClientScene",nil,0)
        --拦截登陆查询数据
        --[[只做查询,成功或失败都不管]]
--        if nil == self._checkInFrame then
--            self._checkInFrame = CheckinFrame:create(self, function(result, msg, subMessage)
--                if result == 1 then

--                end
--                RequestManager.requestLotteryConfig(function(result, message)
--                    if result == 0 then
--                        print("成功了,滚吧")
--                    end 
--                    --不管你转盘成功或失败,我继续查活动
--                    RequestManager.requestQueryActivityStatus(function(result, message)
--                        if result == 0 then
--                            print("活动也查完了,资源要不要下载你说了算")
--                        end            
--                        if yl.HTTP_SUPPORT then
--                            local ostime = os.time()
--                            appdf.onHttpJsionTable(yl.HTTP_URL .. "/WS/MobileInterface.ashx","GET","action=GetMobileShareConfig&userid=" .. GlobalUserItem.dwUserID .. "&time=".. ostime .. "&signature=".. GlobalUserItem:getSignature(ostime),function(jstable,jsdata)
--                                dismissPopWait()
--                                if not appdf.isObject(self) then
--                                    return
--                                end
--                                local msg = nil
--                                if type(jstable) == "table" then
--                                    local data = jstable["data"]
--                                    msg = jstable["msg"]
--                                    if type(data) == "table" then
--                                        local valid = data["valid"]
--                                        if valid then
--                                            local count = data["FreeCount"] or 0
--                                            GlobalUserItem.nTableFreeCount = tonumber(count)
--                                            local sharesend = data["SharePresent"] or 0
--                                            GlobalUserItem.nShareSend = tonumber(sharesend)
--                                            local onlineCount = data["Online"] or 0
--                                            GlobalUserItem.OnlineBaseCount = tonumber(onlineCount)
--                                            --进入游戏列表
--                                            self:getApp():enterSceneEx(appdf.CLIENT_SRC.."plaza.views.ClientScene","FADE",1)
--                                            return
--                                        end
--                                    end
--                                end
--                                local str = "游戏登陆异常"
--                                if type(msg) == "string" then
--                                    str = str .. ":" .. msg
--                                end
--                                showToast(nil, str, 3, cc.c3b(250,0,0))
--                            end)
--                        else
--                            --整理代理游戏列表
--                            if table.nums(self._logonFrame.m_angentServerList) > 0 then
--                                self:arrangeGameList(self._logonFrame.m_angentServerList)
--                            else
--                                self:getApp()._gameList = GlobalUserItem.m_tabOriginGameList
--                            end
--                            --进入游戏列表
--                            self:getApp():enterSceneEx(appdf.CLIENT_SRC.."plaza.views.ClientScene","FADE",1)
--                            --FriendMgr:getInstance():reSetAndLogin()
--                        end
--                    end)
--                end)
--                self._checkInFrame:onCloseSocket()
--                self._checkInFrame = nil
--            end)
--        end
--        self._checkInFrame:onCloseSocket()
--        --查签到信息
--        self._checkInFrame:onCheckinQuery()
    elseif result == 9 then --需要短信验证
        if appdf.CHANNEL_ID == 1004  or appdf.CHANNEL_ID == 2001 then
             print(GlobalUserItem.thirdPartyData["uid"])
              self._logonLayer = LogonLayerTianY:create(self)
              showPopupLayer(self._logonLayer, false)
             self._logonLayer:onChenckUsertips(GlobalUserItem.thirdPartyData["uid"])
         else 
           self._logonLayer:onChenckUsertips()
     end
    end
end
return LogonScene