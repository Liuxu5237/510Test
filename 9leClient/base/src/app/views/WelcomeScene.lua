--[[
	欢迎界面
			2015_12_03 C.P
	功能：本地版本记录读取，如无记录，则解压原始大厅及附带游戏
--]]

local WelcomeScene = class("WelcomeScene", cc.load("mvc").ViewBase)

local ClientUpdate = appdf.req(appdf.BASE_SRC .. "app.controllers.ClientUpdate")
local QueryDialog = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.QueryDialog")
local ClientConfig = appdf.req(appdf.BASE_SRC .."app.models.ClientConfig")

if cc.FileUtils:getInstance():isFileExist(device.writablePath .. "client/src/plaza/models/yl.lua") or
    cc.FileUtils:getInstance():isFileExist(device.writablePath .. "client/src/plaza/models/yl.luac") then
    appdf.req(appdf.CLIENT_SRC .. "plaza.models.yl")
end

--全局toast函数(ios/android端调用)
cc.exports.g_NativeToast = function (msg)
	local runScene = cc.Director:getInstance():getRunningScene()
	if nil ~= runScene then
		showToastNoFade(runScene, msg, 2)
	end
end

--平台
local targetPlatform = cc.Application:getInstance():getTargetPlatform()

function WelcomeScene:onCreate()

    --配置挪用到 最前面
    -- if not yl then
	--     appdf.req(appdf.CLIENT_SRC.."plaza.models.yl")
    -- end

    -- local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")
	-- --文件日志
	-- LogAsset:getInstance():init(MultiPlatform:getInstance():getExtralDocPath(), true, true)

	-- --配置微信
	-- MultiPlatform:getInstance():thirdPartyConfig(yl.ThirdParty.WECHAT, yl.WeChat)
	-- --配置
    -- if not yl.APPSTORE_VERSION then
	--      MultiPlatform:getInstance():thirdPartyConfig(yl.ThirdParty.zhifu_1, yl.zhifu_1)
    -- end
	-- --配置分享
    -- MultiPlatform:getInstance():configSocial(yl.SocialShare)

    -----

    --初始化变量
    self._updateQueue = {}
    self._updateIndex = 1

    if targetPlatform == cc.PLATFORM_OS_WINDOWS then
        ds.MyNotification:getInstance():registerLuaEventCallBack("WINDWOS_CLOSE",function()
            print("==================LUA显示关闭====================")
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
                    :addTo(self)
        end)
    end     
      --背景
    cc.Sprite:create("base/res/loginBG.jpg")
        :setPosition(appdf.WIDTH/2, appdf.HEIGHT/2)
        :addTo(self)

    local filestr = "base/res/logo.png"
    if cc.UserDefault:getInstance():getIntegerForKey("res_client_DTT") == 2 then
        filestr = "base/res/logo222.png"
    end
--    --左上角图标
    self._LeftLog = cc.Sprite:create(filestr)
        :setPosition(appdf.WIDTH / 2 , appdf.HEIGHT / 2 +60)
        --:setScale(0.5)
        :addTo(self)

--    --logo
   self._logo = cc.Sprite:create("base/res/loginBG_niu.png")
       :setPosition(appdf.WIDTH / 2 +355, appdf.HEIGHT / 2 +5)
       :setVisible(false)
       :addTo(self)

    --animal
    -- cc.Sprite:create("base/res/Logingirl.png")
    --     :setPosition(appdf.WIDTH / 2 , appdf.HEIGHT / 2 -10)
    --     :addTo(self)

--     --温馨提示
--    cc.Sprite:create("base/res/botzhgao.png")
--    :setPosition(appdf.WIDTH / 2,20)
--    :addTo(self)

    --提示文本
	self._txtTips = cc.Label:createWithTTF("", "fonts/round_body.ttf", 24)
		:setTextColor(cc.WHITE)
		:setAnchorPoint(cc.p(1,0))
		:enableOutline(cc.c4b(0,0,0,255), 1)
		:move(appdf.WIDTH,0)
		:addTo(self)

    --进度条
    self._loadingBg = cc.Sprite:create("base/res/loading_bg.png")
                        :setPosition(appdf.WIDTH / 2, 104)
                        :addTo(self)
    self._loadingBar = cc.Sprite:create("base/res/loading_bar.png")
                        :setAnchorPoint(0, 0)
                        :setPosition(0, -5)
    self._loadingLayout = ccui.Layout:create()
                            :setClippingEnabled(true)
                            :setContentSize(self._loadingBar:getContentSize())
                            :setAnchorPoint(cc.p(0, 0.5))
                            :setPosition((appdf.WIDTH - self._loadingBar:getContentSize().width) / 2, 110)
                            :addChild(self._loadingBar)
                            :addTo(self)
--    self._txtProgress = cc.Label:createWithTTF("100%", "fonts/round_body.ttf", 24)
--		                    :setTextColor(cc.WHITE)
--		                    :enableOutline(cc.c4b(0,0,0,255), 1)
--		                    :move(appdf.WIDTH / 2, 104)
--		                    :addTo(self)


     --进度提示文本
	self._txtLoadTips = cc.Label:createWithTTF("0%", "fonts/round_body.ttf", 36)
		:setTextColor(cc.WHITE)
		:setAnchorPoint(cc.p(0,0))
		:enableOutline(cc.c4b(0,0,0,255), 1)
		:setPosition(appdf.WIDTH / 2 +7, appdf.HEIGHT /2-257)
		:addTo(self)

    --更新等待
	cc.SpriteFrameCache:getInstance():addSpriteFrames("base/res/GameLding.plist")
   
--    self._UpGameLdoing = cc.Sprite:createWithSpriteFrameName("GameLding_1.png")
--     :setAnchorPoint(0.0,0.5)
--     :setPosition(appdf.WIDTH / 2 +50, appdf.HEIGHT /2-240)
--     :addTo(self)

     self._UpGame = cc.Sprite:create("base/res/0.png")
       :setPosition(appdf.WIDTH / 2 -90, appdf.HEIGHT /2-235)
       :addTo(self)

    --隐藏进度条
   self:showProgressBar(false)
	if LOCAL_DEVELOP == 1 then
 	    self:getApp()._gameList = {}
 	    --self:getApp()._updateUrl = URL_REQUEST .. "/"
 	    self._newVersion = appdf.BASE_C_VERSION
		self:getApp()._version:setVersion(self._newVersion)
		self:getApp()._version:save()
		self:requestServerConfig()
	else
		--无版本信息, 解压自带ZIP
        local nResversion = tonumber(self:getApp()._version:getResVersion())
        local nClientversion = cc.UserDefault:getInstance():getIntegerForKey("res_client_DTT")
        --是空 就是0
        if nClientversion == 0 then
            cc.UserDefault:getInstance():setIntegerForKey("res_client_DTT", appdf.BASE_C_VERSION)
        end
		if nil == nResversion then
        	--解压客户端
        	print("无版本信息, 解压自带ZIP")
            --if cc.PLATFORM_OS_WINDOWS == targetPlatform then
            --    self:requestServerConfig()
            --else
	 		    self:unZipApp()
            --end       
		else
	    	--获取服务器配置
        	print("获取服务器配置")
	    	self:requestServerConfig()
		end 
	end
    
end

--解压客户端
function WelcomeScene:unZipApp()

    -- if cc.PLATFORM_OS_WINDOWS == targetPlatform then
    --   self:enterClient()
    --     return
    -- end

	if self._unZip == nil then --大厅解压
		-- 状态提示
		self._txtTips:setString("请稍候...")
		self._unZip = 0
		--解压
		local dst = device.writablePath
		unZipAsync(cc.FileUtils:getInstance():fullPathForFilename("client.zip"),dst,function(result)
				self:unZipApp()
			end)
	elseif self._unZip == 0 then --默认游戏解压
		self._unZip = 1
		--解压
		local dst = device.writablePath
		unZipAsync(cc.FileUtils:getInstance():fullPathForFilename("game.zip"),dst,function(result)
				self:unZipApp()
			end)
	else 			-- 解压完成
		self._unZip = nil
		--更新本地版本号
        self:getApp()._version:setResVersion(appdf.BASE_C_RESVERSION)
        --设置自带游戏版本号（苹果因为要审核，所以必须要自带游戏，这里设置自带游戏默认版本号）
        if targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
		    for k ,v in pairs(appdf.BASE_GAME) do
			    self:getApp()._version:setResVersion(v.version,v.kind)
		    end
        end
		--self._txtTips:setString("解压完成！")

		--解压完了请求服务器配置
	    self:requestServerConfig()
	end
end

--更新客户端
function WelcomeScene:updateApp()

    QueryDialog:create("有新的版本，是否现在下载升级？",function(bConfirm)

	        if bConfirm == true then       
                         	
			    print("更新客户端")	
                
                if device.platform == "ios" then
                    cc.UserDefault:getInstance():setIntegerForKey("res_client_DTT", self._newVersion)
                    cc.Application:getInstance():openURL(self._iosUpdateUrl)
                elseif device.platform == "android" then
                    --[CRL][2017.12.11]
                    --调用C++下载
                    local luaj = require "cocos.cocos2d.luaj"
                    local className = "org/cocos2dx/lua/AppActivity"
                    local sigs = "()Ljava/lang/String;"
                    local ok,ret = luaj.callStaticMethod(className,"getSDCardDocPath",{},sigs)
                    if ok then

                        -- showToast(self,"测试删除版本22",20)
                        -- local aa = cc.FileUtils:getInstance():fullPathForFilename("base/src/app/models/AppDF.lua")
                        -- cc.FileUtils:getInstance():removeFile(device.writablePath.."".."base/src/app/models/AppDF.lua")
                        -- cc.FileUtils:getInstance():removeFile(device.writablePath.."".."version.plist")        

                        local dstpath = ret .. "/update/"
                        local filepath = dstpath .. "5185931.apk"
                        if cc.FileUtils:getInstance():isFileExist(filepath) then
                            cc.FileUtils:getInstance():removeFile(filepath)
                        end
                        if false == cc.FileUtils:getInstance():isDirectoryExist(dstpath) then
                            cc.FileUtils:getInstance():createDirectory(dstpath)
                        end
                        --这个地址必须是http,暂时无法支持https
                        --http://5185931.oss-cn-hangzhou.aliyuncs.com/Download/5185931.apk
                        downFileAsync(self._androidUpdateUrl,"5185931.apk",dstpath,function(main,sub)
                            --下载回调
                            if main == appdf.DOWN_PRO_INFO then --进度信息
                                self:updateProgressBar(sub)
                            elseif main == appdf.DOWN_COMPELETED then --下载完毕
                                self:showProgressBar(false)
                                --安装apk                     
                                local args = {filepath}
                                sigs = "(Ljava/lang/String;)V"
                                ok,ret = luaj.callStaticMethod(className, "installClient",args, sigs)
                                if ok then
                                    cc.UserDefault:getInstance():setIntegerForKey("res_client_DTT", self._newVersion)
                                    os.exit(0)
                                end
                            else
                                QueryDialog:create("下载失败".."\n是否重试？",function(bReTry)
                                        if bReTry == true then
                                            self:updateApp()
                                        else
                                            os.exit(0)
                                        end
                                    end)
                                :setCanTouchOutside(false)
                                :addTo(self)
                            end
                        end)
                    else
                        os.exit(0)
                    end
                elseif device.platform == "windows" then
                    local dstpath = device.writablePath
                    if not getWindowsVersion then
                        cc.Application:getInstance():openURL(self._windowsUpdateUrl)
                    else
                        downFileAsync(self._windowsUpdateUrl,"5185931.exe",dstpath,function(main,sub)
                            --下载回调
                            if main == appdf.DOWN_PRO_INFO then --进度信息
                                self:updateProgressBar(sub)
                            elseif main == appdf.DOWN_COMPELETED then --下载完毕
                                self:showProgressBar(false)
                                --安装EXE
                                local fRet = InstallEXE(dstpath.."5185931.exe")
                                if fRet then
                                    os.exit(0)
                                end
                            else
                                QueryDialog:create("下载失败".."\n是否重试？",function(bReTry)
                                    if bReTry == true then
                                        self:updateApp()
                                    else
                                        os.exit(0)
                                    end
                                end)
                                :setCanTouchOutside(false)
                                :addTo(self)
                                end
                            end)
                    end
                else
                    cc.Application:getInstance():openURL(self._androidUpdateUrl)
                end
		    else
			    os.exit(0)
	        end					
	    end)
	    :addTo(self)
end

--更新资源
function WelcomeScene:updateRes()

    if #self._updateQueue == 0 then
        
        --进入客户端
      self:enterClient()
    else
        
        --下载当前项
        local config = self._updateQueue[self._updateIndex]
        self._update = ClientUpdate:create(config.newfileurl, config.dst, config.src, config.downurl)
		self._update:upDateClient(self)
    end
end

--显示进度条
function WelcomeScene:updateProgressBar(percent)
    
    if self._loadingBar:isVisible() == false then
        self:showProgressBar(true)
    end
    


    local contentSize = self._loadingBar:getContentSize()

    local curLoad = math.ceil(percent).."%"
     self._txtLoadTips:setString(curLoad)
    self._loadingLayout:setContentSize(contentSize.width * percent / 100, contentSize.height)
  --  self._txtProgress:setString(math.ceil(percent) .. "%")
end

--隐藏进度条
function WelcomeScene:showProgressBar(isShow)
    
    self._loadingBg:setVisible(isShow)
    self._loadingBar:setVisible(isShow)
    self._loadingLayout:setVisible(isShow)
   -- self._txtProgress:setVisible(isShow)
     self._UpGame:setVisible(isShow)
    -- self._UpGameLdoing:setVisible(isShow)
     self._txtLoadTips:setVisible(isShow)

--   if  isShow == true then

--      _SpaceLading =cc.Animation:create()                                                                         
--    for i=0,3 do  
--        local frameName =string.format("GameLding_%d.png",i) 
--        print("frameName =%s",frameName)  
--        local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrameByName(frameName) 
--       _SpaceLading:addSpriteFrame(spriteFrame) 
--    end   


--    _SpaceLading:setDelayPerUnit(0.35)        
--    local action =cc.Animate:create(_SpaceLading) 
--    self._UpGameLdoing:runAction(cc.RepeatForever:create(action)) 
--    else


--    self._UpGameLdoing:stopAllActions()

--   end



end

--进入客户端
function WelcomeScene:enterClient()

	--重置大厅与游戏
	for k ,v in pairs(package.loaded) do
		if k ~= nil then 
			if type(k) == "string" then
				if string.find(k,"plaza.") ~= nil or string.find(k,"game.") ~= nil then
					print("package kill:"..k) 
					package.loaded[k] = nil
				end
			end
		end
	end	

    --重置配置参数
   -- yl = nil

    --显示版本号
    if device.platform == "windows" then
        self._txtTips:setString("v " .. appdf.BASE_C_WINDOWS_VERSION .. "." .. (self:getApp()._version:getResVersion() or appdf.BASE_C_RESVERSION) .. "." .. appdf.CHANNEL_ID)
	else
        self._txtTips:setString("v " .. (cc.UserDefault:getInstance():getIntegerForKey("res_client_DTT") or appdf.BASE_C_VERSION) .. "." .. (self:getApp()._version:getResVersion() or appdf.BASE_C_RESVERSION) .. "." .. appdf.CHANNEL_ID)
    end
	--场景切换
    self:runAction(cc.Sequence:create(
			--cc.DelayTime:create(1),
			cc.CallFunc:create(function()
                if cc.PLATFORM_OS_WINDOWS == targetPlatform then  
                    ds.MyNotification:getInstance():unRegisterEventListener("WINDWOS_CLOSE")
                end
				self:getApp():enterSceneEx(appdf.CLIENT_SRC.."plaza.views.LogonScene",nil,0)
			end)
	))	
end

--------------------------------------------------------------------------------------------------------------------
-- ClientUpdate 回调

--下载开始
function WelcomeScene:onUpdateBegin(count)
    
    if count == 0 then 
        return
    end

    local config = self._updateQueue[self._updateIndex]

    if config.isBase then

        --需要重启客户端s
        self._needRestart = true 
        --设置base更新状态
        cc.UserDefault:getInstance():setBoolForKey("baseupdate", true)
        --显示状态
        self._txtTips:setString("更新主程序资源...")

    elseif config.isClient then
        
        --显示状态
        self._txtTips:setString("更新大厅资源...")

    end
end

--下载进度
function WelcomeScene:onUpdateProgress(sub, msg, mainpersent)

    --更新进度条
    self:updateProgressBar(mainpersent)
end

--下载结果
function WelcomeScene:onUpdateResult(result,msg)

    if result == true then

        local config = self._updateQueue[self._updateIndex]
        if config.isBase then
            --设置base更新状态
            cc.UserDefault:getInstance():setBoolForKey("baseupdate", false)
        end

        --下载下一项
        if self._updateIndex < #self._updateQueue then

            self._updateIndex = self._updateIndex + 1
            self:updateRes()

        else --下载完成

            --隐藏进度条
            self:showProgressBar(false)
            --更新本地大厅版本
            self:getApp()._version:setResVersion(self._newResVersion)
            if self._needRestart then

                --重启客户端 本次更新需要重启才能生效，请重新启动客户端
                --QueryDialog:create("本次更新会自动帮您重启客户端",function(bConfirm)
                    --刷新资源
                    cc.FileUtils:getInstance():purgeCachedEntries() 
                    --刷新代码
	                for k ,v in pairs(package.loaded) do
		                if k ~= nil and string.find(k,"cocos.") == nil then 
                            package.loaded[k] = nil
		                end
                    end	
                    require("app.MyApp"):create():run()
			        --os.exit(0)				
	            --end, nil, QueryDialog.QUERY_SURE)
	            --:addTo(self)
            else

                --进入登录界面
            self:enterClient()
            end
        end
    else


    	--重试询问
		QueryDialog:create("("..self._update:getUpdateFileName()..")".. msg.."\n是否重试？",function(bReTry)
				if bReTry == true then
					self:updateRes()
				else
					os.exit(0)
				end
			end)
			:addTo(self)
    end
end

--------------------------------------------------------------------------------------------------------------------
-- 网路请求

--请求服务器配置
function WelcomeScene:requestServerConfig()
    print("--------requestServerConfig------")
	self._txtTips:setString("获取服务器信息...")
    print("DDDDDDDDDDDDDDDDDDF   ")

	--数据解析
	local vcallback = function(datatable)
	 	local succeed = false
	 	local msg = "网络获取失败！"
	 	if type(datatable) == "table" then	 		
            local databuffer = datatable["data"]
            if databuffer then
                --返回结果
	 		    succeed = databuffer["valid"]
	 		    --提示文字
	 		    local tips = datatable["msg"]
	 		    if tips and tips ~= cjson.null then
	 			    msg = tips
	 		    end
	 		    --获取信息
	 		    if succeed == true then	 
                print("获取服务器信息 获取服务器信息 获取服务器信息")
	 		    	self:getApp()._serverConfig = databuffer		     
 				    --下载地址
 				    self:getApp()._updateUrl = databuffer["downloadurl"]								--test zhong "http://172.16.4.140/download/"
                     --大厅版本
 				    self._newVersion = tonumber(databuffer["clientversion"])          						--test zhong  0
                    --PC大厅版本
                    self._newWindowsVersion = tonumber(databuffer["pcversion"])
 				    --大厅资源版本
 				    self._newResVersion = tonumber(databuffer["resversion"])
 				    --苹果大厅更新地址
 				    self._iosUpdateUrl = databuffer["ios_url"]
                    --安卓大厅更新地址
                    self._androidUpdateUrl = databuffer["android_url"]
                    --PC大厅更新地址
                    self._windowsUpdateUrl = databuffer["pcurl"]
                    --功能列表
                    self:getApp()._funList = {}
                    --排行榜是否开启"EnjoinTask":1,"EnjoinRanking":1,"EnjoinApple":1}
                    self:getApp()._funList.EnjoinRanking = databuffer["EnjoinRanking"]
                    --赠送是否开启
                    --self:getApp()._funList.GiveModule = databuffer["GiveButton"]
                    --任务是否开启
					self:getApp()._funList.EnjoinTask =  databuffer["EnjoinTask"]
					--是否强制更新
					self._froceUpdate = databuffer["ForcedUpdate"]
					
					--默认 1审核 2通过
					local enjoinApple = tonumber(databuffer["EnjoinApple"])
					local baseApp     = cc.UserDefault:getInstance():getIntegerForKey("isAppAuditing")
					if baseApp==0 and enjoinApple==1 then --审核中
						cc.UserDefault:getInstance():setIntegerForKey("isAppAuditing",1)
					elseif baseApp==1 and enjoinApple==1 then
						cc.UserDefault:getInstance():setIntegerForKey("isAppAuditing",1)
					else
						cc.UserDefault:getInstance():setIntegerForKey("isAppAuditing",2)
					end

					cc.UserDefault:getInstance():setStringForKey("WZHTAddress", databuffer["WZHTAddress"])
					cc.UserDefault:getInstance():setStringForKey("NoticeAddress", databuffer["NoticeAddress"])
					cc.UserDefault:getInstance():setStringForKey("HKAddress", databuffer["HKAddress"])
					cc.UserDefault:getInstance():setStringForKey("IOSAddress", databuffer["IOSAddress"])
					cc.UserDefault:getInstance():setStringForKey("AndroidAddress", databuffer["AndroidAddress"])					

 				    local nNewV = self._newResVersion
					local nCurV =tonumber(self:getApp()._version:getResVersion())
					if nNewV and nCurV then
						if nNewV > nCurV then

                            --更新目录
                            local updatefolders = { "base", "client" }

                            for i = 1, #updatefolders do
                                
                                local folder = updatefolders[i]
                                local updateConfig = {}

                                updateConfig.isBase = (folder == "base")
					 		    updateConfig.isClient = (folder == "client")
					 		    updateConfig.newfileurl = self:getApp()._updateUrl.."/" .. folder .. "/res/filemd5List.json"
							    updateConfig.downurl = self:getApp()._updateUrl .. "/"

                                if cc.PLATFORM_OS_WINDOWS == targetPlatform and true then
                                    if folder == "base" and getInstallationPath then
                                        local installPath = getInstallationPath();
                                        local index = string.find(installPath,"Game510.exe")
                                        print("============",index)
                                        installPath = string.sub(installPath,1,index - 1)
                                        print(installPath)
                                        updateConfig.dst = installPath
                                        updateConfig.src = installPath.. folder .. "/res/filemd5List.json"
                                    else
                                        updateConfig.dst = device.writablePath
                                        updateConfig.src = device.writablePath.. folder .. "/res/filemd5List.json"
                                    end
                                else
                                    updateConfig.dst = device.writablePath
							        updateConfig.src = device.writablePath .. folder .. "/res/filemd5List.json"
                                end

					 		    table.insert(self._updateQueue, updateConfig)
                            end
						end
					end		 

 				    --游戏列表
 				    local rows = databuffer["gamelist"]
 				    self:getApp()._gameList = {}
 				    for k,v in pairs(rows) do
 					    local gameinfo = {}
                        print("------gamelist----",k,v)
                        gameinfo._KindID = v["KindID"]
                        if gameinfo._KindID =="104" then
                            gameinfo._KindID ="26"
                        end
                        gameinfo._GameName = v["KindName"]
 					    gameinfo._KindName = string.lower(v["ModuleName"]) .. "."
 					    gameinfo._Module = string.gsub(gameinfo._KindName, "[.]", "/")
 					    gameinfo._KindVersion = v["ClientVersion"]
 					    gameinfo._ServerResVersion = tonumber(v["ResVersion"])
 					    gameinfo._Type = gameinfo._Module
 					    --检查本地文件是否存在
 					    local path = device.writablePath .. "game/" .. gameinfo._Module
 					    gameinfo._Active = cc.FileUtils:getInstance():isDirectoryExist(path)
 					    local e = string.find(gameinfo._KindName, "[.]")
 					    if e then
 					    	gameinfo._Type = string.sub(gameinfo._KindName,1,e - 1)
 					    end
 					    -- 排序
 					    gameinfo._SortId = tonumber(v["SortID"]) or 0

 					    table.insert(self:getApp()._gameList, gameinfo)
 				    end

                   
 				    table.sort( self:getApp()._gameList, function(a, b)
 				    	return a._SortId > b._SortId
 				    end)
	 		    end
            end	 		
	 	end

         local nCurClientV =cc.UserDefault:getInstance():getIntegerForKey("res_client_DTT")
         print("nCurClientV " .. nCurClientV)
        if succeed then --成功
			if LOCAL_DEVELOP == 1 then
				self:enterClient()
			else
                if device.platform == "windows" and true then
                    if getWindowsVersion then
                        appdf.BASE_C_WINDOWS_VERSION = getWindowsVersion()
                    else
                        --没有版本信息就强更新
                        self:updateApp()
                        return
                    end
                    if self._newWindowsVersion and self._newWindowsVersion > appdf.BASE_C_WINDOWS_VERSION and self._froceUpdate then
                        --更新PC客户端
                        self:updateApp()
                    else
                        --更新资源
                        self:updateRes()
                    end
                else
    				--判断是否需要重新下载完整App
     	        	if self._newVersion and self._newVersion > nCurClientV and self._froceUpdate then
                    	--更新客户端
                    	self:updateApp()
                	else
                    	--更新资源
                    	self:updateRes()
                	end
                end
			end

        else            --失败


        --我真的怕你了yl 那我在LOGOIN 里面来设置你 不就可以了吗

      --  appdf.ENV = 2

        appdf.isErrorLogin  =true
        

       --还有游戏列表 你他妈给我争气啊

        for k,v in pairs(appdf.NoterGameList) do
 					  
            local gameinfo = {}
            print("------gamelist----",k,v)
 			gameinfo._KindID = v["KindID"]
            gameinfo._GameName = v["KindName"]
 			gameinfo._KindName = string.lower(v["ModuleName"]) .. "."
 			gameinfo._Module = string.gsub(gameinfo._KindName, "[.]", "/")
 			gameinfo._KindVersion = v["ClientVersion"]
 			gameinfo._ServerResVersion = tonumber(v["ResVersion"])
 			gameinfo._Type = gameinfo._Module
 			--检查本地文件是否存在
 			local path = device.writablePath .. "game/" .. gameinfo._Module
 			gameinfo._Active = cc.FileUtils:getInstance():isDirectoryExist(path)
 			local e = string.find(gameinfo._KindName, "[.]")
 			if e then
 				gameinfo._Type = string.sub(gameinfo._KindName,1,e - 1)
 			end
 			-- 排序
 			gameinfo._SortId = tonumber(v["SortID"]) or 0

 			table.insert(self:getApp()._gameList, gameinfo)

 		end

        --更新资源
        self:updateRes()

--            --提示重试
--            self._txtTips:setString("")
--	        QueryDialog:create(msg.."\n是否重试？",function(bReTry)
--			        if bReTry == true then
--				        self:requestServerConfig()
--			        else
--				        os.exit(0)
--			        end
--		        end)
--		        :addTo(self)
        end
	end


    local typeID = (device.platform == "ios" and 1 or 2) --1.ios 2.android

   --读取本地渠道号
    local fileUitls=cc.FileUtils:getInstance()
    if device.platform == "ios" then
        self._zpath = "channel.plist"
    elseif device.platform == "android" then
        self._zpath = "base/channel.plist"
    end

   
   if cc.FileUtils:getInstance():isFileExist(self._zpath) then
       self._channelInfo  = fileUitls:getValueMapFromFile(self._zpath)
       appdf.CHANNEL_ID =self._channelInfo["channelid"]
   end


	appdf.onHttpJsionTable(appdf.HTTP_URL .. "/WS/MobileInterface.ashx","get","action=getgamelist&TypeID="..typeID.."&channelid="..appdf.CHANNEL_ID
	.."&VersionNumber="..appdf.BASE_C_VERSION.."."..appdf.BASE_C_RESVERSION,vcallback)

    print("DDDDDDDDDDDDDDDDDD   ",appdf.HTTP_URL)
end

return WelcomeScene