require("base.src.app.models.bit")
require("base.src.app.models.AppDF")
require("base.src.app.Toolkits.TimerProxy") --added ycc

appdf.req("base.src.app.views.layer.other.Toast")
cjson = require("cjson")

if device.platform ~= "windows" then
	cc.FileUtils:getInstance():addSearchPath(device.writablePath)
end
cc.FileUtils:getInstance():addSearchPath(device.writablePath.."client/res/")

--本地调试
LOCAL_DEVELOP = 0
if LOCAL_DEVELOP == 1 then
	cc.FileUtils:getInstance():addSearchPath("./game/")
	cc.FileUtils:getInstance():addSearchPath("client/src/")
	cc.FileUtils:getInstance():addSearchPath("client/res/")
	cc.FileUtils:getInstance():addSearchPath("./command/") 
end

--联机Debug，不联机调试时设置为0
REMOTE_DEBUG = 0
if REMOTE_DEBUG == 1 then
	--此处IP填写本机的局域网IP，调试的手机如果是真机需保证在同一个局域网中
	local breakSocketHandle,debugXpCall = require("LuaDebugjit")("169.254.199.49",7003)
	cc.Director:getInstance():getScheduler():scheduleScriptFunc(breakSocketHandle, 0.3, false)
	function __G__TRACKBACK__(errorMessage)  
    	debugXpCall();  
	end 
end

local Version = import(".models.Version")

MyApp = MyApp or class("MyApp", cc.load("mvc").AppBase)
MyApp._instance = nil

function MyApp:onCreate()

    --保存实例
    MyApp._instance = self

    math.randomseed(os.time())
    --搜素路径添加
	cc.FileUtils:getInstance():addSearchPath(device.writablePath.."client/res/")
	
	--版本信息
	self._version = Version:create()
	--游戏信息
	self._gameList = {}
	--更新地址
	self._updateUrl = ""
	--初次启动获取的配置信息
	self._serverConfig = {}
end

--获取单例
function MyApp:getInstance()
    return MyApp._instance
end

--获取版本管理器
function MyApp:getVersionMgr()
    print("--------getVersionMgr------")
	return self._version
end

--获取游戏列表
function MyApp:getGameList()
    return self._gameList
end

--获取更新地址
function MyApp:getUpdateUrl()
    return self._updateUrl
end

--获取游戏信息
function MyApp:getGameInfo(wKindID)

    for k,v in pairs(self._gameList) do
        print(k,v,v._KindID)
		if tonumber(v._KindID) == tonumber(wKindID) then
			return v
		end
	end

	return nil
end

--是否是房卡游戏
function MyApp:isPrivateModeGame(wKindID)
    
    local gameInfo = self:getGameInfo(wKindID)
    if gameInfo == nil then
        return false
    end

    local isPriModeGame = cc.FileUtils:getInstance():isDirectoryExist(device.writablePath .. "game/" .. gameInfo._Module .. "/src/privateroom")
    return isPriModeGame
end

return MyApp
