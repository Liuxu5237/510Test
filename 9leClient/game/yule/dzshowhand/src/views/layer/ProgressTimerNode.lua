
--进度条

local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")

local cmd = appdf.req(appdf.GAME_SRC .. "yule.dzshowhand.src.models.CMD_Game")

local ProgressTimeLayer = class("ProgressTimerLayer",function(userNode,time,startPerCent,endPercent,callBack)

    local node = cc.Node:create()

    return node

end)

--[[

userNode:玩家节点
startPercent:开始位置
startPercent:结束位置
callBack :回调
]]
function ProgressTimeLayer:ctor(scene,userNode,startPerCent,endPercent,callBack)

self._startPercent = 0

self._scene = scene

self._endPercent = 100

self._callBack = nil

self._particlePoint = {}

self._timePercent = {}

self:addTo(userNode)

if startPerCent ~= nil then

    self._startPercent = startPerCent

end

if endPercent ~=nil then

    self._endPercent = endPercent

end

if callBack ~=nil then

    self._callBack = callBack

end


self._progressTime =  cc.ProgressTimer:create(display.newSprite("#game/GameRes850/texasHoldem_time_bg.png"))
:setColor(cc.c3b(205,236,8))
:setScale(1.0)
:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
:setPosition(cc.p(0,0))
-- 0-->100 动画方向 逆时针
:setReverseDirection(false)
-- 设置中心点
-- self._Timer:setMidpoint(cc.p(0.5, 0.5))
:setVisible(false)

self:addChild(self._progressTime)

--粒子特效
self._particle = cc.ParticleSystemQuad:create(cmd.RES.."animation/particle/touxianglizi.plist")
:move(self._progressTime:getContentSize().width/2, self._progressTime:getContentSize().height)
:addTo(self._progressTime)

end

function ProgressTimeLayer:start(time,callBack)

    self._time = 20

    if time ~= nil then

        self._time = time

    end

    self:getParticlePoint()

    self._particle:setVisible(true)
    self:particleAni(time)
    self:colorChangeAni(time)

    self._progressTime:runAction(cc.Sequence:create(cc.Show:create(),
    cc.ProgressFromTo:create(time,self._startPercent,self._endPercent),
    cc.CallFunc:create(function ()
        if callBack ~= nil then
            self:stop(callBack)
        else
            self:stop()
        end
        
    end)))

    self:runAction(cc.Sequence:create(cc.DelayTime:create(time/2),cc.CallFunc:create(function ()
        if self._particle:isVisible() then
            self._scene:PlaySound(cmd.RES .. "sound_res/half_time.mp3")
        end
    end)))
    
    
end

--获取particle运动的点
function ProgressTimeLayer:getParticlePoint()

    local csbNode = ExternalFun.loadCSB(cmd.RES.."ProgressLayer/ProgressNode.csb",self)
    :setVisible(false)

    local child = csbNode:getChildByName("progress"):getChildren()

    local childCount = #child

    for i = 1,childCount do 

        local point = csbNode:getChildByName("progress"):getChildByName("point_"..i)

        self._particlePoint[i] = cc.p(point:getPosition())

    end

    --计算总路程
    local sume_route = 0;
    local route = {}
    self._timePercent = {}

    for i=1,#self._particlePoint do
        
        local point1 = self._particlePoint[i]

        local point2 = nil 

        if i == #self._particlePoint then

            point2 = self._particlePoint[1]

        else

            point2 = self._particlePoint[i+1]

        end

        route[i] =  math.sqrt(math.pow(math.abs(point1.x-point2.x),2)+math.pow(math.abs(point1.y-point2.y),2))

        sume_route = sume_route + route[i]

    end

    for i = 1,#self._particlePoint do

        if i== 5 then

            self._timePercent[i] = (route[i]/sume_route-0.015)*self._time

        elseif i== 11 then
         
            self._timePercent[i] = (route[i]/sume_route-0.027)*self._time

        elseif i ==12 then

            self._timePercent[i] = (route[i]/sume_route-0.023)*self._time

        elseif i == 7 then

            self._timePercent[i] = (route[i]/sume_route+0.025)*self._time
        else


            self._timePercent[i] = (route[i]/sume_route)*self._time

        end

    end


    csbNode:removeFromParent()    
end

--播放粒子动画
function ProgressTimeLayer:particleAni(time)
    if tolua.isnull(self._particle) then return end

    self._particle:setPosition(self._particlePoint[1])

    local actionTable = {}

    for i=1,#self._particlePoint do

        local endPoint = nil

        if i == #self._particlePoint then
        
            endPoint = self._particlePoint[1]

        else

            endPoint = self._particlePoint[i+1]

        end

        local action = cc.MoveTo:create(self._timePercent[i],endPoint)

        table.insert(actionTable,action)
        
    end

    self._particle:runAction(cc.Sequence:create(actionTable))
end


--播放颜色变更动画
function ProgressTimeLayer:colorChangeAni(time)    
    local colorTable = {
        cc.c3b(130, 200, 8),
        cc.c3b(205, 236, 5),
        cc.c3b(249, 222, 11),
        cc.c3b(249, 179, 11),
        cc.c3b(249, 153, 11),
        cc.c3b(232, 44, 2),
        cc.c3b(232, 44, 2)
    }

    self._progressTime:setColor(colorTable[1])

    local actionTable = {}
    for i = 1, #colorTable do
        local ani = cc.TintTo:create((1/#colorTable)*time, colorTable[i].r, colorTable[i].g, colorTable[i].b)
        table.insert(actionTable, ani)
    end
    local seq = cc.Sequence:create(actionTable)
    self._progressTime:runAction(seq)
end

function ProgressTimeLayer:stop(callBack)

    self._particle:stopAllActions()
    self._progressTime:stopAllActions()
    self._progressTime:setPercentage(0)
    self._particle:setVisible(false)
    self._particle:setPosition(self._progressTime:getContentSize().width/2, self._progressTime:getContentSize().height)
    if callBack ~= nil then
        callBack()
    end
end

return ProgressTimeLayer