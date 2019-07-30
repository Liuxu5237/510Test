
module("DSWaitingLayer", package.seeall)

local mWaitingLayer = nil
local mSchedulerID = nil
function init(time)

    local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 154))

    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchMoved(touch, event)
        
    end

    local function onTouchEnded(touch, event)
        
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local waitSprite = cc.Sprite:create("PlatForm/Loading/loading_circle.png")
    waitSprite:setPosition(cc.p(visibleSize.width/2, visibleSize.height/2))
    layer:addChild(waitSprite)

    waitSprite:runAction(cc.RepeatForever:create(cc.RotateBy:create(1.5,360)))

    return layer
end



function create(time)
    if (mWaitingLayer) then
        mWaitingLayer:removeFromParent(true)
        mWaitingLayer = nil
    end
    local scheduler = cc.Director:getInstance():getScheduler()
    if (mSchedulerID ~= nil) then
        scheduler:unscheduleScriptEntry(mSchedulerID)
        mSchedulerID = nil
    end
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    mWaitingLayer = init(time)

    local scheduler = cc.Director:getInstance():getScheduler()
    if (mSchedulerID ~= nil) then
        scheduler:unscheduleScriptEntry(mSchedulerID)
        mSchedulerID = nil
    end
    mSchedulerID = scheduler:scheduleScriptFunc(function()  
        scheduler:unscheduleScriptEntry(mSchedulerID)
        mSchedulerID = nil
        if (mWaitingLayer) then
            mWaitingLayer:removeFromParent(true)
            mWaitingLayer = nil
        end
    end,20,false)     

    if (mWaitingLayer) then
        local _scene = cc.Director:getInstance():getRunningScene()
        if (_scene == nil) then
            _scene = cc.Scene:create()
            cc.Director:getInstance():runWithScene(_scene)
        end
        _scene:addChild(mWaitingLayer,ds.common.LOADING_Z_ORDER)
    end

    return mWaitingLayer
end


function dismiss()
    if (mWaitingLayer ~= nil) then
        mWaitingLayer:removeFromParent(true)
        mWaitingLayer = nil
    end
    local scheduler = cc.Director:getInstance():getScheduler()
    if (mSchedulerID ~= nil) then
        scheduler:unscheduleScriptEntry(mSchedulerID)
        mSchedulerID = nil
    end
end

function delete()
    if (mWaitingLayer ~= nil) then
        mWaitingLayer = nil
    end
    local scheduler = cc.Director:getInstance():getScheduler()
    if (mSchedulerID ~= nil) then
        scheduler:unscheduleScriptEntry(mSchedulerID)
        mSchedulerID = nil
    end
end

