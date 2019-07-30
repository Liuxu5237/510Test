

local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")

local cmd = appdf.req(appdf.GAME_SRC .. "yule.dzshowhand.src.models.CMD_Game")

local RuleLayer = class("RuleLayer", function(scene)
	local ruleLayer = display.newLayer()
	return ruleLayer
end)

function RuleLayer:ctor(scene)

    self._scene = scene
    --注册触摸事件
    ExternalFun.registerTouchEvent(self, true)
    local csbNode = ExternalFun.loadCSB(cmd.RES.."Rule/rule.csb",self)

    --close
    local btn = csbNode:getChildByName("close")

    :addTouchEventListener(function (ref,TouchEvent)

        if TouchEvent == ccui.TouchEventType.ended then
            
            ExternalFun.playClickEffect()

                self:hide()

        end

    end)
    self.m_spBg = csbNode:getChildByName("img_bg")
    self:show()

end

function RuleLayer:show()

    local fadeIn = cc.FadeIn:create(0.07)
    local bigger = cc.ScaleTo:create(0.07, 1.1)
    local spawn = cc.Spawn:create(fadeIn, bigger)
    local reNormal = cc.ScaleTo:create(0.21, 1.0)
    local action = cc.Sequence:create(spawn, reNormal)
    self:runAction(action)


end 
function RuleLayer:hide()

    local spawnTime = 0.1
    local moveUp = cc.MoveBy:create(spawnTime, cc.p(0, 20))
    local fadeOut = cc.FadeOut:create(spawnTime)
    local smaller = cc.ScaleTo:create(spawnTime, 0.8)
    local spawn = cc.Spawn:create(moveUp, fadeOut, smaller)
    
    local action = cc.Sequence:create(spawn, callFun,cc.RemoveSelf:create())
    self:runAction(action)

end

--触摸回调
function RuleLayer:onTouchBegan(touch, event)
    return self:isVisible()
end

function RuleLayer:onTouchEnded(touch, event)
    local pos = touch:getLocation() 
    local m_spBg = self.m_spBg
    pos = m_spBg:convertToNodeSpace(pos)
    local rec = cc.rect(0, 0, m_spBg:getContentSize().width, m_spBg:getContentSize().height)
    if false == cc.rectContainsPoint(rec, pos) then
        self:hide()
    end
end

return RuleLayer