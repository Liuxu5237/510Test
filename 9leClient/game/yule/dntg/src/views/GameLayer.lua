--
-- Author: Tang
-- Date: 2016-08-08 17:26:37
--游戏交互层


local GameLayer = class("GameLayer", function(frameEngine,scene)
  --创建物理世界
      cc.Director:getInstance():getRunningScene():initWithPhysics()
      cc.Director:getInstance():getRunningScene():getPhysicsWorld():setGravity(cc.p(0,-100))
        local gameLayer = display.newLayer()
        return gameLayer
end)  

require("cocos.init")  
local ExternalFun = require(appdf.EXTERNAL_SRC.."ExternalFun")
local g_var = ExternalFun.req_var
local module_pre = "game.yule.dntg.src"  
local ExternalFun = require(appdf.EXTERNAL_SRC.."ExternalFun")
local cmd = module_pre..".models.CMD_DntgGame"

function GameLayer:ctor( frameEngine,scene )
  self._scene = scene
  self._gameFrame = frameEngine
  self._gameFrame:setKindInfo(cmd.KIND_ID,cmd.VERSION)
  self:addSerchPaths()
end

function GameLayer:addSerchPaths( )
   --搜索路径
    local gameList = self._scene:getApp()._gameList;
    local gameInfo = {};
    for k,v in pairs(gameList) do
          if tonumber(v._KindID) == tonumber(g_var(cmd).KIND_ID) then
            gameInfo = v;
            break;
        end
    end

    if nil ~= gameInfo._KindName then
        self._searchPath = device.writablePath.."game/" .. gameInfo._Module .. "/res/";
        self._searchGamePath = device.writablePath.."game/" .. gameInfo._Module .. "/res/dntgGameScene";
        cc.FileUtils:getInstance():addSearchPath(self._searchPath);
        cc.FileUtils:getInstance():addSearchPath(self._searchGamePath);
    end


end

function GameLayer:onEnter( )
  print("onEnter of gameLayer")
end

function GameLayer:onEnterTransitionFinish(  )
  print("onEnterTransitionFinish of gameLayer")
end

function GameLayer:onExit()
  print("gameLayer onExit()....")
end

--触摸事件
function GameLayer:onTouchBegan(touch, event)
	return true
end

function GameLayer:onTouchMoved(touch, event)
end

function GameLayer:onTouchEnded(touch, event )
end

--用户进入
function GameLayer:onEventUserEnter( wTableID,wChairID,useritem ) 
end

--用户状态
function GameLayer:onEventUserStatus(useritem,newstatus,oldstatus)
end

--用户分数
function GameLayer:onEventUserScore( item )
    print("onEventUserScore...")
end

--显示等待
function GameLayer:showPopWait()
    if self._scene and self._scene.showPopWait then
        self._scene:showPopWait()
    end
end

--关闭等待
function GameLayer:dismissPopWait()
    if self._scene and self._scene.dismissPopWait then
        self._scene:dismissPopWait()
    end
end

--退出询问
function GameLayer:onQueryExitGame()
    -- body
end

function GameLayer:onExitTable()
     self._scene:onKeyBack()
end

function  GameLayer:onKeyBack()
    self._gameFrame:StandUp(1)
    return true
end

return GameLayer