--房间控制器

local RoomLayer = class("RoomLayer", cc.Layer)

local QueryDialog = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.QueryDialog")

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

local GameFrameEngine = appdf.req(appdf.CLIENT_SRC.."plaza.models.GameFrameEngine")

local RoomViewLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.room.RoomViewLayer")
local UserInfoLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.UserInfoLayer")
local TablePasswordLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.TablePasswordLayer")

local GameScene = appdf.req(appdf.CLIENT_SRC.."plaza.views.GameScene")

--私人房命令
local cmd_private = appdf.req(appdf.CLIENT_SRC .. "privatemode.header.CMD_Private")
local cmd_pri_game = cmd_private.game

--当前平台
local targetPlatform = cc.Application:getInstance():getTargetPlatform()

--映射函数
local MAP_FUNC_NAMES = { 
    "onExitTable",
    "onEventGameScene",
    "onEventUserScore",
    "onEventGameMessage",
    "onSocketInsureEvent",
    "onUserChat",
    "onUserExpression",
    "onUserVoiceStart",
    "onUserVoiceEnded",
    "OnResetGameEngine",
    "onSubSystemMessage"
}

RoomLayer._instance = nil

function RoomLayer:getInstance()
    return RoomLayer._instance
end

function RoomLayer:ctor(delegate)

    RoomLayer._instance = self

    --保存数据
    self._delegate = delegate

    --创建游戏框架
    self._gameFrame = GameFrameEngine:create(self, function(result, message)
        self:onGameFrameCallBack(result, message)
    end)
    self._gameFrame:setViewFrame(self)

    local contentSize = self:getContentSize()

    --锁桌按钮
    self._btnLock = ccui.Button:create("Room/bt_lock_0.png", "Room/bt_lock_1.png")
    self._btnLock:setPosition(50, 620)
    self._btnLock:setScale(0.8)
    self._btnLock:setVisible(false)
    self._btnLock:addTo(self, 100)
    self._btnLock:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()

        self:onClickTableLock()
    end)

    --快速加入按钮
    self._btnQuickJoin = ccui.Button:create("Room/bt_quick_join_0.png", "Room/bt_quick_join_1.png")
    self._btnQuickJoin:setAnchorPoint(1, 0.5)
    self._btnQuickJoin:setPosition(contentSize.width, contentSize.height / 2)
    self._btnQuickJoin:setVisible(false)
    self._btnQuickJoin:addTo(self, 100)
    self._btnQuickJoin:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()

        self:onClickQuickJoin()
    end)

    --映射函数
    for i = 1, #MAP_FUNC_NAMES do
        local func_name = MAP_FUNC_NAMES[i]
        if self[func_name] == nil then 
            self[func_name] = function(...)
                local gameLayer = self:getGameLayer()
                if gameLayer then
                    local func = gameLayer[func_name]
                    if func then
                        func(gameLayer, unpack({...}, 2))
                    end
                end
            end
        end
    end
end

------------------------------------------------------------------------------------------------------------
-- 事件处理

--点击锁桌
function RoomLayer:onClickTableLock()

    if self._gameFrame:isSocketServer() then
        
        showPopupLayer(TablePasswordLayer:create(function(password)
                
            if password ~= nil and password ~= "" then
                --发送密码
                self._gameFrame:SendEncrypt(password)
            end
        end))
    end
end

--点击快速加入
function RoomLayer:onClickQuickJoin()

    if self._gameFrame:QueryChangeDesk() then
        showPopWait()
    end
end

------------------------------------------------------------------------------------------------------------
-- 房间操作

--重置房间
function RoomLayer:resetRoom()

    --清空信息
    self._gameInfo = nil
    self._roomInfo = nil

    --隐藏按钮
    self._btnLock:setVisible(false)
    self._btnQuickJoin:setVisible(false)
end

--登录房间
function RoomLayer:logonRoom(wKindID, wServerID)
    --获取游戏信息
    local gameInfo = MyApp:getInstance():getGameInfo(wKindID)
    if nil == gameInfo then
        QueryDialog:create("游戏信息不存在",function(bReTry)end)
                :addTo(cc.Director:getInstance():getRunningScene())
        print("游戏信息不存在", wKindID)
        return
    end
    --获取房间信息
    local roomInfo = GlobalUserItem.getGameRoomInfo(wKindID, wServerID)
    if nil == roomInfo then
        QueryDialog:create("房间信息不存在",function(bReTry)end)
                :addTo(cc.Director:getInstance():getRunningScene())
        print("房间信息不存在", wServerID)
        return
    end
    --重置房间
    self:resetRoom()

    --保存信息
    self._gameInfo = gameInfo
    self._roomInfo = roomInfo


    GlobalUserItem.tabEnterGame = gameInfo
    GlobalUserItem.bPrivateRoom = self:isPrivateRoom()

    --showPopWait()

    --发起连接
    self._gameFrame:onCloseSocket()
    self._gameFrame:onInitData()
	self._gameFrame:setKindInfo(gameInfo._KindID, gameInfo._KindVersion)
	self._gameFrame:onLogonRoom(roomInfo)
end

--登录私人房
function RoomLayer:logonPrivateRoom(wKindID, wServerID, logonCallBack)

    self._privateLogonCallBack = logonCallBack

    self:logonRoom(wKindID, wServerID)
end

--关闭房间
function RoomLayer:closeRoom()
    --清理进度界面
    if nil ~= self.m_scheduleUpdate then
        local scheduler = cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(self.m_scheduleUpdate)
        self.m_scheduleUpdate = nil
    end
    local scene = cc.Director:getInstance():getRunningScene()
    local layer = scene:getChildByTag(2000) 
    if nil ~= layer then            
        self.loadingBar:stopAllActions()
        self.loadingBar = nil
        if nil ~= self.sp_load_act then
            self.sp_load_act:stopAllActions()
        end
        layer:stopAllActions()
        layer:removeFromParent()
    end
    --退出房间
    self:onExitRoom()
end

--关闭游戏
function RoomLayer:closeGame()

    if self._gameScene then
        
        --self._delegate:getApp():popScene()
        self._gameScene:removeFromParent()
        self._gameScene = nil

        --AudioEngine.stopMusic()

        dismissPopWait()
    end
end

--创建桌子
function RoomLayer:createTable(data)

    self._gameFrame:sendSocketData(data)
end

------------------------------------------------------------------------------------------------------------
-- 功能函数

--是否是私人房
function RoomLayer:isPrivateRoom()
    
    if self._roomInfo and self._roomInfo.wServerType == yl.GAME_GENRE_PERSONAL then
        return true
    end

    return false
end

--是否进入了房间
function RoomLayer:isEnterRoom()

    return self._gameFrame:isSocketServer()
end

--开始保持活动连接
function RoomLayer:startKeepAlive()

    if self._scheduleKeepAlive then
        return
    end

    print("开始保持活动连接")

    --定时发送内核检测数据（手机版在收到内核检测后，没有主动回复，所以在这里定时发送防止掉线）
    self._scheduleKeepAlive = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()

        if self._gameFrame:isSocketServer() then

            print("发送心跳检测包...")

            local dataBuffer = CCmd_Data:create(0)
	        dataBuffer:setcmdinfo(0,1)
            self._gameFrame:sendSocketData(dataBuffer)
        end
    end, 5, false)
end

--停止保持活动连接
function RoomLayer:stopKeepAlive()
    
    if self._scheduleKeepAlive then
        
        print("停止保持活动连接")

        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._scheduleKeepAlive) 
        self._scheduleKeepAlive = nil
    end
end

--添加搜索路径
function RoomLayer:addSearchPath()

    local gameInfo = self._gameInfo

    if nil ~= gameInfo then
        local searchPath
        if LOCAL_DEVELOP == 1 then
            searchPath = "game/" .. gameInfo._Module .. "/res/";
        else
            searchPath = device.writablePath.."game/" .. gameInfo._Module .. "/res/";
        end
        
        cc.FileUtils:getInstance():addSearchPath(searchPath);

        print("RoomLayer:addSearchPath( \"" .. searchPath .. "\" )")
    end
end

--移除搜索路径
function RoomLayer:removeSearchPath()

    local gameInfo = self._gameInfo
    if nil ~= gameInfo then
        local pos = string.find(gameInfo._Module, "/")
        local gamedir = string.sub(gameInfo._Module, pos + 1, -2)

        --重置搜索路径
        local oldPaths = cc.FileUtils:getInstance():getSearchPaths();
        local newPaths = {};
        for k,v in pairs(oldPaths) do
            if string.find(tostring(v), gamedir) == nil then
                table.insert(newPaths, v);
            else
                print("RoomLayer:removeSearchPath( \"" .. v .. "\" )")
            end
        end

        cc.FileUtils:getInstance():setSearchPaths(newPaths);
    end
end

--添加私人房搜索路径
function RoomLayer:addPrivateSearchPath()

    local gameInfo = self._gameInfo

    if nil ~= gameInfo then
        self._priSearchPath = device.writablePath.."game/" .. gameInfo._Module .. "/res/privateroom/";
        cc.FileUtils:getInstance():addSearchPath(self._priSearchPath)

        print("RoomLayer:addPrivateSearchPath( \"" .. self._priSearchPath .. "\" )")
    end   
end

--移除私人房搜索路径
function RoomLayer:removePrivateSearchPath()

    --重置搜索路径
    local oldPaths = cc.FileUtils:getInstance():getSearchPaths()
    local newPaths = {}
    for k,v in pairs(oldPaths) do
        if tostring(v) ~= tostring(self._priSearchPath) then
            table.insert(newPaths, v)
        else
            print("RoomLayer:removePrivateSearchPath( \"" .. v .. "\" )")
        end
    end
    cc.FileUtils:getInstance():setSearchPaths(newPaths)
end

------------------------------------------------------------------------------------------------------------
-- 数据接口

--获取当前游戏信息
function RoomLayer:getEnterGameInfo()
    
    return GlobalUserItem.tabEnterGame
end

--获取桌子信息
function RoomLayer:getTableInfo(wTableID)

    return self._gameFrame:getTableInfo(wTableID)
end

--获取桌子用户信息
function RoomLayer:getTableUserItem(wTableID, wChairID)

    return self._gameFrame:getTableUserItem(wTableID, wChairID)
end

--获取游戏场景
function RoomLayer:getGameScene()
    
    return self._gameScene
end

--获取游戏层
function RoomLayer:getGameLayer()
    
    if self._gameScene == nil then
        return nil
    end

    return self._gameScene:getGameLayer()
end

------------------------------------------------------------------------------------------------------------
-- RoomViewLayer 回调

--点击桌椅
function RoomLayer:onSitDown(wTableID, wChairID)
    
    local userItem = self:getTableUserItem(wTableID, wChairID)

    if userItem then
        
        --显示用户信息
        showPopupLayer(UserInfoLayer:create(userItem))
    else
        
        --获取桌子信息
        local tableInfo = self:getTableInfo(wTableID + 1)
        if tableInfo == nil then
            return
        end

        local sitdown = function(tableid, chairid, pass)

            --showPopWait()
            self:GameLoadingView()
            --发送坐下请求
            self._gameFrame:SitDown(wTableID, wChairID, pass)
        end

        --需要输入密码
        if tableInfo.cbTableLock == 1 then
        
            showPopupLayer(TablePasswordLayer:create(function(password)
                
                --坐下
                sitdown(wTableID, wChairID, password)
            end))
        else
            --坐下
            sitdown(wTableID, wChairID)
        end
    end
end

------------------------------------------------------------------------------------------------------------
-- GameScene 回调

function RoomLayer:onKeyBack()

    self:closeGame()

    --如果是直接进入的类型，关闭房间
    if self._roomViewLayer == nil then
        self:closeRoom()
    end
end

------------------------------------------------------------------------------------------------------------
-- GameFrameEngine 回调

function RoomLayer:onGameFrameCallBack(result, message)

    local bClose = false

    if type(result) == "table" then

        local main = result.m
        local sub = result.s
        local data = message

        --私人房命令
        if main == cmd_pri_game.MDM_GR_PERSONAL_TABLE then
            
            if type(message) == "string" and message ~= "" then

                QueryDialog:create(message, nil, nil, QueryDialog.QUERY_SURE)
	                        :addTo(self._delegate)

                bClose = true
            end

            if sub == cmd_pri_game.SUB_GR_CREATE_SUCCESS then               --创建成功
                bClose = true
            elseif sub == cmd_pri_game.SUB_GR_PERSONAL_TABLE_TIP then       --私人房数据
                --刷新私人房数据
                if self._priGameLayer ~= nil then
                    self._priGameLayer:onRefreshInfo()
                end
            end

            -- 通知私人房事件      
            local eventListener = cc.EventCustom:new(yl.RY_PERSONAL_TABLE_NOTIFY)
            eventListener.obj = { cmd = sub, data = message }
            cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)

        end
    else
        function failcallback ()
            local scene = cc.Director:getInstance():getRunningScene()
            local layer = scene:getChildByTag(2000) 
            if nil ~= layer then            
                self.loadingBar:stopAllActions()
                self.loadingBar = nil
                if nil ~= self.sp_load_act then
                    self.sp_load_act:stopAllActions()
                end
                layer:stopAllActions()
                layer:removeFromParent()
            elseif self._gameScene ~= nil then
                dismissPopWait()
                self:onExitRoom(-1)
            end
        end

        if type(message) == "string" and message ~= "" then
            QueryDialog:create(message, function(bReTry)
                    failcallback()
                end, nil, QueryDialog.QUERY_SURE)
	                   :addTo(cc.Director:getInstance():getRunningScene())
        end

        bClose = true
    end

    --关闭房间
    if bClose then

        dismissPopWait()

        self:onExitRoom(-1)
    end
end

--进入房间
function RoomLayer:onEnterRoom()
    
    print("RoomLayer:onEnterRoom()")
    if cc.PLATFORM_OS_WINDOWS == targetPlatform then
        self._delegate:unSetWindowsCloseEvent()
    end
    --添加游戏搜索路径
    self:addSearchPath()

    --添加私人房搜索路径
    if self:isPrivateRoom() then
        self:addPrivateSearchPath()
    end

    --私人房登录回调
    if self._privateLogonCallBack then
        self._privateLogonCallBack()
        self._privateLogonCallBack = nil
        return
    end

    --开始保持活动连接
    self:startKeepAlive()

    dismissPopWait()

    --通知进入房间
    if self._delegate and self._delegate.onEnterRoom then
        self._delegate:onEnterRoom()
    end 

    local bAutoJoin = false
    bAutoJoin = bAutoJoin --or GlobalUserItem.isAntiCheat()               --防作弊
    bAutoJoin = bAutoJoin or self._gameFrame:GetChairCount() >= 100     --百人游戏
    bAutoJoin = bAutoJoin or (self._roomInfo.wServerLevel >= 10)         --快速场
    bAutoJoin = bAutoJoin or self._delegate._bIsQuickStart              --游戏房间界面快速开始
    local roomcount = GlobalUserItem.getRoomCount(tonumber(self._gameInfo._KindID))
    --直接进入游戏
    if bAutoJoin then
        if self._gameFrame:GetChairCount() >= 100 and self._delegate._bIsQuickStart and roomcount == 1 then
            self._delegate._bIsQuickStart = true
            -- if self._gameInfo._KindID == tostring(1040) then
            --     self._delegate._bIsQuickStart = false
            -- end
        -- elseif roomcount == 1 and self._delegate._bIsQuickStart then
        --     self._delegate._bIsQuickStart = true
        elseif roomcount == 1  then
            self._delegate._bIsQuickStart = true
        else
            self._delegate._bIsQuickStart = false
        end
        local wTableID = self._gameFrame:GetTableID()
        local wChairID = self._gameFrame:GetChairID()

		if wTableID == yl.INVALID_TABLE and wChairID == yl.INVALID_CHAIR and self._gameFrame:QueryChangeDesk() then
            if self._gameInfo._KindID == tostring(516) or self._gameInfo._KindID == tostring(601) or self._gameInfo._KindID == tostring(19) 
            or self._gameInfo._KindID == tostring(14) or self._gameInfo._KindID == tostring(20) or self._gameInfo._KindID == tostring(21)
            or self._gameInfo._KindID == tostring(22) then
			    showPopWait()
            end
            --self:GameLoadingView()
		end
		return
    end

	--自定义房间界面处理登陆成功消息
	local modulestr = string.gsub(self._gameInfo._KindName, "%.", "/")
	local customRoomFile = ""
	if cc.PLATFORM_OS_WINDOWS == targetPlatform or LOCAL_DEVELOP == 1 then
		customRoomFile = "game/" .. modulestr .. "src/views/GameRoomListLayer.lua"
	else
		customRoomFile = "game/" .. modulestr .. "src/views/GameRoomListLayer.luac"
	end
    print("读取路径="..customRoomFile)
	if cc.FileUtils:getInstance():isFileExist(customRoomFile) then
		if (appdf.req(customRoomFile):onEnterRoom(self._gameFrame)) then
			--showPopWait()
		else
            showToast(nil, "进入房间失败", 2)
			--退出房间
            self:closeRoom()
		end
    else
        --普通房间，创建房间视图
        if self._roomViewLayer then
            self._roomViewLayer:removeFromParent()
        end

        self._roomViewLayer = RoomViewLayer:create(self):addTo(self)
	end
end

--离开房间
function RoomLayer:onExitRoom(code, message)

    print("RoomLayer:onExitRoom()")
    if self._gameInfo ~= nil then 
        -- 显示大厅
        if self._gameInfo._KindID == tostring(601) then
            -- 查询滚动公告 b捕鱼是吧 我就要查询公告 咬我
            self._delegate:requestRollNotice()
            -- 大厅动画再放一次
            self._delegate:shopAction()
            -- 退出捕鱼 没背景音乐？
        end
    end
    ExternalFun.playPlazzBackgroudAudio()
    if cc.PLATFORM_OS_WINDOWS == targetPlatform then
        self._delegate:unSetWindowsCloseEvent()
        self._delegate:setWindowsCloseEvent()
    end
    self._delegate:setVisible(true)


    --停止保持活动连接
    self:stopKeepAlive()

    --关闭游戏
    self:closeGame()

    --关闭连接
    if self._gameFrame:isSocketServer() then
        self._gameFrame:onCloseSocket()
    end

    --清理游戏搜索路径
    self:removeSearchPath()

    --私人房
    if self:isPrivateRoom() then
        --清理搜索路径
        self:removePrivateSearchPath()
        --清理房间数据
        GlobalUserItem.tabPriRoomData = {}
        GlobalUserItem.bPrivateRoom = false
    end

    --重置游戏包
	for k ,v in pairs(package.loaded) do
		if k ~= nil then 
			if type(k) == "string" then
				if string.find(k,"game.qipai.") ~= nil or string.find(k,"game.yule.") ~= nil then
					print("package kill:"..k) 
					package.loaded[k] = nil
				end
			end
		end
	end	

    --清理游戏信息
    GlobalUserItem.tabEnterGame = nil

    --更新房间人数
--    self._roomInfo.dwOnLineCount = self._gameFrame:GetOnlineCount()
--    self._roomInfo.dwAndroidCount = 0

    --移除房间视图
    if self._roomViewLayer then
        self._roomViewLayer:removeFromParent()
        self._roomViewLayer = nil
    end

    --通知离开房间
    if self._delegate and self._delegate.onExitRoom then
        self._delegate:onExitRoom(code, message)
    end

    --重置房间
    self:resetRoom()
end

--进入桌子
function RoomLayer:onEnterTable()

    print("RoomLayer:onEnterTable(" .. self._gameFrame:GetTableID() .. ", " .. self._gameFrame:GetChairID() .. ")")

    dismissPopWait()
    --PRELOAD.bLoadingFinish = true  
    if self._gameInfo == nil  then
        print("self._gameinfo == nil , so what are you doing now")
        self:onExitTable()
        self:onExitRoom(-1,nil)
        return;
    end 
    if self._gameInfo._KindID == tostring(516) or self._gameInfo._KindID == tostring(601) or self._gameInfo._KindID == tostring(19)
    or self._gameInfo._KindID == tostring(14) or self._gameInfo._KindID == tostring(20) or self._gameInfo._KindID == tostring(21)
    or self._gameInfo._KindID == tostring(22) then
        --通知进入桌子
        print(type(self._gameInfo._KindID))
        if self._delegate and self._delegate.onEnterTable then
            self._delegate:onEnterTable()
        end

        if self._gameScene == nil then

            self._gameScene = GameScene:create(self)
            self._gameScene:addTo(cc.Director:getInstance():getRunningScene())

            self._gameFrame:SendGameOption()

            --隐藏大厅
            self._delegate:setVisible(false)
        else --换桌

        --发送游戏选项，获取场景信息
            self._gameFrame:SendGameOption()
        end
    else
        dump(self._roomInfo)
        GlobalUserItem.oxexRoomName = nil
        --牛牛有动态加入,在这里来判断房间等级
        if self._gameInfo._KindID == tostring(27) or self._gameInfo._KindID == tostring(102)
         or self._gameInfo._KindID == tostring(36) then
            local lCellScore = tonumber(self._roomInfo.wSortID)
            local str = "初级场"
            if lCellScore == 3 then
                str = "中级场"
            elseif lCellScore == 4 then
                str = "高级场"
            elseif lCellScore == 5 then
                str = "富豪场"
            end
            GlobalUserItem.oxexRoomName = str
        -- elseif self._gameInfo._KindID == tostring(36) then
        --     local lCellScore = tonumber(self._roomInfo.lCellScore)
        --     local str = "初级场"
        --     if lCellScore > 5000 and lCellScore <= 50000 then
        --         str = "中级场"
        --     elseif lCellScore > 50000 and lCellScore <= 200000 then
        --         str = "高级场"
        --     elseif lCellScore > 200000 then
        --         str = "富豪场"
        --     end
        --     GlobalUserItem.oxexRoomName = str
        end
        
        self.bLoadingFinish = true
        if GlobalUserItem.bIsChangeTableUser then
            --GlobalUserItem.bIsChangeTableUser = false
            self:Finish()
        end
    end
    --[[通知进入桌子
    if self._delegate and self._delegate.onEnterTable then
        self._delegate:onEnterTable()
    end

    if self._gameScene == nil then

        self._gameScene = GameScene:create(self)
        self._gameScene:addTo(cc.Director:getInstance():getRunningScene())

        self._gameFrame:SendGameOption()

        --隐藏大厅
        self._delegate:setVisible(false)

--        --进入游戏场景
--        self._delegate:getApp():pushScene(appdf.CLIENT_SRC.."plaza.views.GameScene",nil,0,nil,function(scene)
--            self._gameScene = scene
--            self._gameScene:setDelegate(self)

--            --发送游戏选项，获取场景信息
--            self._gameFrame:SendGameOption()

--            --创建游戏层
--            self._gameScene:createGameLayer()

--            --如果是私人房，添加私人房游戏层
--            if self._roomInfo.wServerType == yl.GAME_GENRE_PERSONAL then
--                local modulestr = string.gsub(self._gameInfo._KindName, "%.", "/")
--                local gameFile = ""
--                if cc.PLATFORM_OS_WINDOWS == targetPlatform then
--                    gameFile = "game/" .. modulestr .. "src/privateroom/PriGameLayer.lua"
--                else
--                    gameFile = "game/" .. modulestr .. "src/privateroom/PriGameLayer.luac"
--                end
--                if cc.FileUtils:getInstance():isFileExist(gameFile) then
--                    local gameLayer = self._gameScene:getGameLayer()
--                    local priGameLayer = appdf.req(gameFile):create( gameLayer )
--                    if nil ~= priGameLayer then
--                        gameLayer._gameView:addChild(priGameLayer)
--                        gameLayer._gameView._priView = priGameLayer
--                        self._priGameLayer = priGameLayer

--                        --刷新私人房数据
--                        if next(GlobalUserItem.tabPriRoomData) ~= nil then
--                            self._priGameLayer:onRefreshInfo()
--                        end
--                    end
--                end
--            end
--        end)
    else --换桌

        --发送游戏选项，获取场景信息
        self._gameFrame:SendGameOption()
    end]]

end

--离开桌子
function RoomLayer:onExitTable()

    --显示大厅
    self._delegate:setVisible(true)

    --通知游戏场景
    local gameLayer = self:getGameLayer()
    if gameLayer and gameLayer.onExitTable then
        gameLayer:onExitTable()
    end

    --通知离开桌子
    if self._delegate and self._delegate.onExitTable then
        self._delegate:onExitTable()
    end

    if self.m_scheduleEveryGame~=nil then
        local scheduler = cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(self.m_scheduleEveryGame)
        self.m_scheduleEveryGame= nil
    end
end

--获取到桌子信息
function RoomLayer:onGetTableInfo()

    if self._roomViewLayer ~= nil then

        --创建桌子列表
        self._roomViewLayer:createTableList(self._gameFrame:GetTableCount(), self._gameFrame:GetChairCount())

        --显示按钮
        self._btnLock:setVisible(true)
        self._btnQuickJoin:setVisible(true)
    end
end

--桌子状态
function RoomLayer:onEventTableStatus(wTableID, cbTableStatus)
	
    if self._roomViewLayer ~= nil then
        self._roomViewLayer:updateTable(wTableID)
    end
end

--玩家进入
function RoomLayer:onEventUserEnter(wTableID, wChairID, userItem)
	
    --通知游戏场景
    local gameLayer = self:getGameLayer()
    if gameLayer and gameLayer.onEventUserEnter then
        gameLayer:onEventUserEnter(wTableID, wChairID, userItem)
    end

    if self._roomViewLayer ~= nil and wTableID ~= yl.INVALID_TABLE then
        
        self._roomViewLayer:updateChair(wTableID, wChairID, userItem)
    end
end

--玩家状态
function RoomLayer:onEventUserStatus(userItem, newStatus, oldStatus)
	
    --通知游戏场景
    local gameLayer = self:getGameLayer()
    if gameLayer and gameLayer.onEventUserStatus then
        gameLayer:onEventUserStatus(userItem, newStatus, oldStatus)
    end

    if self._roomViewLayer ~= nil then

        --有三种状态，1.坐下 2.站起 3.换座位

        --坐下
        if oldStatus.wTableID == yl.INVALID_TABLE and newStatus.wTableID ~= yl.INVALID_TABLE then

            self._roomViewLayer:updateChair(newStatus.wTableID, newStatus.wChairID, userItem)

        --站起
        elseif oldStatus.wTableID ~= yl.INVALID_TABLE and newStatus.wTableID == yl.INVALID_TABLE then

            self._roomViewLayer:updateChair(oldStatus.wTableID, oldStatus.wChairID, nil)

        --换桌/换桌位
        elseif oldStatus.wTableID ~= yl.INVALID_TABLE and newStatus.wTableID ~= yl.INVALID_TABLE and (oldStatus.wTableID ~= newStatus.wTableID or oldStatus.wChairID ~= newStatus.wChairID) then

            self._roomViewLayer:updateChair(oldStatus.wTableID, oldStatus.wChairID, nil)
            self._roomViewLayer:updateChair(newStatus.wTableID, newStatus.wChairID, userItem)
        end
    end

end

--用户分数
--function RoomLayer:onEventUserScore(item)

--    --通知游戏场景
--    local gameLayer = self:getGameLayer()
--    if gameLayer and gameLayer.onEventUserScore then
--        gameLayer:onEventUserScore(item)
--    end
--end

--场景信息
--function RoomLayer:onEventGameScene(cbGameStatus,dataBuffer)

--    --通知游戏场景
--    local gameLayer = self:getGameLayer()
--    if gameLayer and gameLayer.onEventGameScene then
--        gameLayer:onEventGameScene(cbGameStatus,dataBuffer)
--    end
--end

--游戏消息
--function RoomLayer:onEventGameMessage(sub,dataBuffer)

--    --通知游戏场景
--    local gameLayer = self:getGameLayer()
--    if gameLayer and gameLayer.onEventGameMessage then
--        gameLayer:onEventGameMessage(sub,dataBuffer)
--    end
--end

--私人桌数据
function RoomLayer:onEventPersonalTable(sub,pData)


end

--请求失败
function RoomLayer:onRequestFailure(code, message)

    dismissPopWait()

    if type(message) == "string" and message ~= "" then
        showToast(nil, message, 2)
        self._delegate._isClickGame = false
        if cc.PLATFORM_OS_WINDOWS == targetPlatform then
            self._delegate:unSetWindowsCloseEvent()
            self._delegate:setWindowsCloseEvent()
        end
    end
    if nil ~= self.m_scheduleUpdate then
        local scheduler = cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(self.m_scheduleUpdate)
        self.m_scheduleUpdate = nil
    end
    local scene = cc.Director:getInstance():getRunningScene()
    local layer = scene:getChildByTag(2000) 
    if nil ~= layer then            
        self.loadingBar:stopAllActions()
        self.loadingBar = nil
        if nil ~= self.sp_load_act then
            self.sp_load_act:stopAllActions()
        end
        layer:stopAllActions()
        layer:removeFromParent()
    end
end
--------------------------------------------------------------------------------------------
--添加进度条
function RoomLayer:GameLoadingView( kindID )
    --CurrencyPreLoading.resetData()
   
    self.loadingPer = 20
    self.bLoadingFinish = false
    local scene = cc.Director:getInstance():getRunningScene()
    local layer = display.newLayer()
    layer:setTag(2000)
    scene:addChild(layer,30)
    --斗地主 因为不是防作弊了， 这里不用这个图片了
    if kindID == 9999999 then

        local function updateDDZ( dt )
            local scheduler = cc.Director:getInstance():getScheduler()
            scheduler:unscheduleScriptEntry(self.m_scheduleDDZ)
            self.m_scheduleDDZ= nil
            
            if self.loadingPer<100 then
                local exit= ccui.Button:create("plaza/game_leave.png", "plaza/game_leave.png", "plaza/game_leave.png")
                :setPosition(cc.p(63,711))
                exit:addClickEventListener(function(  )
                    self:onExitTable()
                    self:onExitRoom(-1,nil)
                    
                end)
                local scene1 = cc.Director:getInstance():getRunningScene()
                local layer1 = scene1:getChildByTag(2000) 
                layer1:addChild(exit)
            end
           
        end
        local scheduler = cc.Director:getInstance():getScheduler()
        self.m_scheduleDDZ = scheduler:scheduleScriptFunc(updateDDZ, 5, false)


        local loadingBG = ccui.ImageView:create("Room/loading/game_pipei.png")
        loadingBG:setTag(1)
        loadingBG:setTouchEnabled(true)
        loadingBG:setPosition(cc.p(yl.WIDTH/2,yl.HEIGHT/2))
        layer:addChild(loadingBG)

        local waitTips = cc.Sprite:create("Room/loading/label_pipei.png")
        waitTips:setPosition(cc.p(640,400))
        loadingBG:addChild(waitTips)

        local dian = cc.Sprite:create("Room/loading/img_tipicon.png")
        dian:setVisible(false)
        dian:setPosition(cc.p(waitTips:getPositionX()+waitTips:getContentSize().width/2+30,waitTips:getPositionY()))
        layer:addChild(dian)
    
        local dian2 = cc.Sprite:create("Room/loading/img_tipicon.png")
        dian2:setVisible(false)
        dian2:setPosition(cc.p(waitTips:getPositionX()+waitTips:getContentSize().width/2+70,waitTips:getPositionY()))
        layer:addChild(dian2)
    
        local dian3 = cc.Sprite:create("Room/loading/img_tipicon.png")
        dian3:setVisible(false)
        dian3:setTag(102)                
        dian3:setPosition(cc.p(waitTips:getPositionX()+waitTips:getContentSize().width/2+110,waitTips:getPositionY()))
        layer:addChild(dian3)

        dian:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function (  )
            dian:setVisible(true)
        end),cc.DelayTime:create(0.3),cc.CallFunc:create(function (  )
            dian2:setVisible(true)
        end),cc.DelayTime:create(0.3),cc.CallFunc:create(function (  )
            dian3:setVisible(true)
        end),cc.DelayTime:create(0.1),cc.CallFunc:create(function (  )
            dian:setVisible(false)
    
            dian3:setVisible(false)
    
            dian2:setVisible(false)
        end),nil)))

        self.loadingBar = cc.ProgressTimer:create(cc.Sprite:create("Room/loading/game_bar.png"))
        self.loadingBar:setVisible(false)
        self.loadingBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        self.loadingBar:setMidpoint(cc.p(0.0,0.5))
        self.loadingBar:setBarChangeRate(cc.p(1,0))
        --CurrencyPreLoading.loadingBar:setPercentage(20)
        self.loadingBar:runAction(cc.ProgressTo:create(0.1,20))
        loadingBG:addChild(self.loadingBar)

        self.sp_load_act = nil

    else
        
        local loadingBG = ccui.ImageView:create("Room/loading/game_load_bg.jpg")

        if kindID == 2075 then
            loadingBG:loadTexture("Room/loading/game_friut.jpg")
        elseif kindID == 2099 then
            loadingBG:loadTexture("Room/loading/game_2099.jpg")
        end


        local function updateEveryGame( dt )
            local scheduler = cc.Director:getInstance():getScheduler()

            if self.m_scheduleEveryGame~=nil then
                scheduler:unscheduleScriptEntry(self.m_scheduleEveryGame)
            else
                return
            end
            self.m_scheduleEveryGame=nil
            
            if self.loadingPer<100  then
           
                self:onExitTable()
                self:onExitRoom(-1,nil)
                QueryDialog:create("服务器开了个小差哟，稍后再试", function(bReTry)

                end, nil, QueryDialog.QUERY_SURE)
                            :addTo(cc.Director:getInstance():getRunningScene())

    
            end
           
        end
        local scheduler = cc.Director:getInstance():getScheduler()
        self.m_scheduleEveryGame = scheduler:scheduleScriptFunc(updateEveryGame, 7, false)


        loadingBG:setTag(1)
        loadingBG:setTouchEnabled(true)
        loadingBG:setPosition(cc.p(yl.WIDTH/2,yl.HEIGHT/2))
        layer:addChild(loadingBG)
    
        local loadingBarBG = ccui.ImageView:create("Room/loading/game_bar_bg.png")
        loadingBarBG:setTag(2)
        loadingBarBG:setPosition(cc.p(yl.WIDTH/2,340))
        layer:addChild(loadingBarBG)
    
        self.loadingBar = cc.ProgressTimer:create(cc.Sprite:create("Room/loading/game_bar.png"))
        self.loadingBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        self.loadingBar:setMidpoint(cc.p(0.0,0.5))
        self.loadingBar:setBarChangeRate(cc.p(1,0))
        --CurrencyPreLoading.loadingBar:setPercentage(20)
        self.loadingBar:setPosition(cc.p(loadingBarBG:getContentSize().width/2,loadingBarBG:getContentSize().height/2))
        self.loadingBar:runAction(cc.ProgressTo:create(0.1,20))
        loadingBarBG:addChild(self.loadingBar)
    
        cc.Sprite:create("Room/loading/game_load_txt.png")
                 :setPosition(cc.p(yl.WIDTH/2,380))
                 :addTo(layer)
        local sp_load_icon = cc.Sprite:create("Room/loading/sp_load_icon.png")
                 :setPosition(cc.p(yl.WIDTH/2,480))
                 :addTo(layer)
        self.sp_load_act = cc.Sprite:create("Room/loading/sp_load_act.png")
        self.sp_load_act:setPosition(cc.p(sp_load_icon:getContentSize().width/2,sp_load_icon:getContentSize().height/2))
        self.sp_load_act:addTo(sp_load_icon)
        self.sp_load_act:runAction(cc.RepeatForever:create(cc.RotateBy:create(1 , 360)))

    end

    local function createSchedule( )
        local function update( dt )
            self:updatePercent(dt)
        end
        local scheduler = cc.Director:getInstance():getScheduler()
        self.m_scheduleUpdate = scheduler:scheduleScriptFunc(update, 0, false)
    end
    createSchedule()
end

function RoomLayer:updatePercent(dt )
    if self.bLoadingFinish then
        if self.loadingPer == 20 then
            self.loadingPer = 80
        end
        self.loadingPer = self.loadingPer + 2
        self.loadingBar:setPercentage(self.loadingPer)
    end

    if self.loadingPer >= 100  then
        local scheduler = cc.Director:getInstance():getScheduler()
        if self.m_scheduleEveryGame~=nil then
            scheduler:unscheduleScriptEntry(self.m_scheduleEveryGame)
        end
        self.m_scheduleEveryGame=nil

        self.loadingBar:setPercentage(self.loadingPer)
        self.bLoadingFinish = false
        self:Finish()       
    end
end
function RoomLayer:Finish()
    if nil ~= self.m_scheduleUpdate then
        local scheduler = cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(self.m_scheduleUpdate)
        self.m_scheduleUpdate = nil
    end
    local scene = cc.Director:getInstance():getRunningScene()
    local layer = scene:getChildByTag(2000) 
    if nil ~= layer then
        --local callfunc = cc.CallFunc:create(function()          
            self.loadingBar:stopAllActions()
            self.loadingBar = nil
            if nil ~= self.sp_load_act then
                self.sp_load_act:stopAllActions()
            end
            layer:stopAllActions()
            layer:removeFromParent()
            self._delegate._isClickGame = false
        --end)
        --layer:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),callfunc))
    end
    --通知进入桌子
    if self._delegate and self._delegate.onEnterTable then
        self._delegate:onEnterTable()
    end

    if self._gameScene == nil then

        self._gameScene = GameScene:create(self)
        self._gameScene:addTo(cc.Director:getInstance():getRunningScene())
        self._gameFrame:SendGameOption()

        --隐藏大厅
        self._delegate:setVisible(false)
    else --换桌
        --发送游戏选项，获取场景信息
        self._gameFrame:SendGameOption()
    end
end

return RoomLayer