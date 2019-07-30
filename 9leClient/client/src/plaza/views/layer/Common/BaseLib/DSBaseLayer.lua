
module("DSBaseLayer", package.seeall)

local DSBaseLayer = class("DSBaseLayer")
DSBaseLayer.__index = DSBaseLayer
DSBaseLayer.__widget = nil  --根节点
DSBaseLayer.__type = nil    --界面类型
DSBaseLayer.__AniType = nil --进入的动画类型
DSBaseLayer.__isHave = false   --这个界面是否存在

--切换动画类型
ds = ds or {}
ds.BaseLayer = {}
ds.BaseLayer.SceneSwitchType = {
    LeftToRight = "LeftToRight",
    RightToLeft = "RightToLeft"
}

ds.BaseLayer.PosWindowsAnimationType = {
    ToLeft = "toLeft",
    ToRight = "toRight",
    ToUp = "toUp",
    ToDown = "toDown",
    ToScale = "toScale",
}


--继承target类
function DSBaseLayer.extend(target)
    local t = tolua.getpeer(target)
    if not t then
        t = {}
        tolua.setpeer(target, t)
    end
    setmetatable(t, DSBaseLayer)
    return target
end

--初始化：将json文件读入进来
function DSBaseLayer:init(FileName)
	self.__widget = ccs.GUIReader:getInstance():widgetFromJsonFile(FileName)
	if (self.__widget == nil) then 
		ds.log("file not exist!!")
		return
	end

    self:addChild(self.__widget)
end

--从根节点通过名字查找子节点
function  DSBaseLayer:seekWidgetByNameOfRoot(nodeName)
    return ccui.Helper:seekWidgetByName(self.__widget, nodeName)
end

--从指定的父节点通过名字来查找子节点
function  DSBaseLayer:seekWidgetByNodeName(parent, nodeName)
    return ccui.Helper:seekWidgetByName(parent, nodeName)
end

--关闭这个界面
function DSBaseLayer:Close()
    local layer = DSLayerMgr.SearchLayer(self.__type)
    if (layer ~= nil) then
        DSLayerMgr.DeleteLayer(self.__type)
    end
    self:removeFromParent(true)
end

--设置进入的动画类型
function DSBaseLayer:setPopAnimation(Ani_type)
    self.__AniType = Ani_type
end

--运行这个界面，将界面push到场景中
--isManager:是否需要管理
--zOrder：层级
function DSBaseLayer:Run(isManager ,zOrder)
    if (DSLayerMgr.IsHaveLayerByIndex(self.__type)) then
        ds.log("It can't be added again!!")
        return
    end

    local _scene = cc.Director:getInstance():getRunningScene()
    if (_scene == nil) then
        _scene = cc.Scene:create()
        cc.Director:getInstance():runWithScene(_scene)
    end

    if (zOrder == nil) then
        zOrder = 0
    end

    if(isManager ==nil) then
        isManager = false
    end


    self:PushAnimation()
    if (isManager) then
        DSLayerMgr.AddNewLayer(self, self.__type)
    end

    _scene:addChild(self, zOrder)
end

--push动画
function DSBaseLayer:PushAnimation()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local bg = self:seekWidgetByNameOfRoot("Bg")
    if (bg == nil) then
        return
    end
    local function FromRightToLeft()
        self:setPosition(cc.p(visibleSize.width + 10,0))
        local action = cc.EaseSineIn:create(cc.MoveTo:create(0.3, ccp(0,0)))
        self:runAction(action)
    end

    local function FromLeftToRight()
        self:setPosition(cc.p(-visibleSize.width - 10,0))
        local action = cc.EaseSineIn:create(cc.MoveTo:create(0.3, ccp(0,0)))
        self:runAction(action)
    end

    local function FromUpToDown()
        self:setPosition(cc.p(0, visibleSize.height + 10))
        local action = cc.EaseSineIn:create(cc.MoveTo:create(0.3, ccp(0,0)))
        self:runAction(action)
    end

    local function FromDownToUp()
        self:setPosition(cc.p(0, -visibleSize.height - 10))
        local action = cc.EaseSineIn:create(cc.MoveTo:create(0.3, ccp(0,0)))
        self:runAction(action)
    end

    local function FromSmallToBig()
        self:setScale(0.2)
        local action1 = cc.EaseSineInOut:create(cc.ScaleTo:create(0.2, 1.2))
        local action2 = cc.ScaleTo:create(0.05, 1)
        local action = cc.Sequence:create(action1, action2)
        self:runAction(action)
    end

    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if (targetPlatform == cc.PLATFORM_OS_MAC or targetPlatform == cc.PLATFORM_OS_ANDROID or targetPlatform == cc.PLATFORM_OS_IPHONE
        or targetPlatform == cc.PLATFORM_OS_IPAD) then
        if (self.__AniType == ds.BaseLayer.PosWindowsAnimationType.ToRight) then
            FromLeftToRight()
        elseif (self.__AniType == ds.BaseLayer.PosWindowsAnimationType.ToLeft) then
            FromRightToLeft()
        elseif (self.__AniType == ds.BaseLayer.PosWindowsAnimationType.ToDown) then
            FromUpToDown()
        elseif (self.__AniType == ds.BaseLayer.PosWindowsAnimationType.ToUp) then
            FromDownToUp()
        elseif (self.__AniType == ds.BaseLayer.PosWindowsAnimationType.ToScale) then
            FromSmallToBig()
        end
    end
end

--layer的转换（注意：这个会删除上一个layer,如果只是push的话，就用上面的Run()）
function LayerSwitch(type,curLayer, nextLayer, isManager)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    -- local _scene = cc.Director:getInstance():getRunningScene()
    -- if (_scene == nil) then
    --     _scene = cc.Scene:create()
    --     cc.Director:getInstance():runWithScene(_scene)
    -- end
    -- _scene:addChild(nextLayer)
    nextLayer:Run(isManager)

    local function FromRightToLeft()
        nextLayer:setPosition(cc.p(visibleSize.width + 10,0))
        local action1 = cc.Sequence:create(cc.MoveTo:create(0.5, ccp(-visibleSize.width - 10,0)),cc.CallFunc:create(function()
            curLayer:Close()
        end))
        local action2 = cc.MoveTo:create(0.5, ccp(0,0))
        curLayer:runAction(action1)
        nextLayer:runAction(action2)
    end

   local function FromLeftToRight()
        nextLayer:setPosition(cc.p(-visibleSize.width - 10,0))
        local action1 = cc.Sequence:create(cc.MoveTo:create(0.5, ccp(visibleSize.width + 10,0)),cc.CallFunc:create(function()
            curLayer:Close()
        end))
        local action2 = cc.MoveTo:create(0.5, ccp(0,0))
        curLayer:runAction(action1)
        nextLayer:runAction(action2)
    end

    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if (targetPlatform == cc.PLATFORM_OS_MAC or targetPlatform == cc.PLATFORM_OS_ANDROID or targetPlatform == cc.PLATFORM_OS_IPHONE
        or targetPlatform == cc.PLATFORM_OS_IPAD) then
        if (type == ds.BaseLayer.SceneSwitchType.RightToLeft) then
            FromRightToLeft()
        elseif (type == ds.BaseLayer.SceneSwitchType.LeftToRight) then
            FromLeftToRight()
        else
            curLayer:Close()
        end
    else
        curLayer:Close()
    end
end

--通过json来创建一个界面
function initWithJsonFile(type, NeedFileName)
    local layer = DSLayerMgr.SearchLayer(type)
    if (layer == nil) then
        local jsonFlie = nil
        --ds.MyConfigureData:shared():stringFromKey(type)
        layer = DSBaseLayer.extend(cc.Layer:create())
        if (NeedFileName ~= nil) then
            jsonFlie = NeedFileName
        end
        layer:init(jsonFlie)
        layer.__type = type
    end

    return layer   
end

