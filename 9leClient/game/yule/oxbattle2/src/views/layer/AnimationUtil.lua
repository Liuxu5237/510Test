--
-- Author: Hello World
-- Date: 2018-07-19 16:04:48
--
AnimationUtil = {}

-- 播放序列帧
-- 注：需提前加载Plist文件（谁加载谁移除）
-- framePrefix：前缀
-- isFinishDel：是否完成销毁
-- delayDelTime：延迟销毁时间
-- return：Sprite
function AnimationUtil.playEffectFromSpriteFrame(framePrefix,startIndex,endIndex,fps,repeatCount,isFinishDel,delayDelTime)

    if endIndex < startIndex then return nil end
    local animationFrames = {}
    local numSize = string.len(tostring(endIndex))
    local formatStr = framePrefix.."%0"..numSize.."d.png"
    local time = 1/(fps or 30)
    local animate = cc.Animation:create()
    for i=startIndex,endIndex do
        local frameName = string.format(formatStr, i)
        local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)
        if spriteFrame then
            animate:addSpriteFrame(spriteFrame)
        end
    end
    animate:setDelayPerUnit(time)
    animate:setRestoreOriginalFrame(false)
    animate:setLoops(repeatCount or 1)
    local action = cc.Animate:create(animate)  
    local spr = cc.Sprite:create()
    if isFinishDel then
        spr:runAction(cc.Sequence:create(action, cc.DelayTime:create(delayDelTime or 1), cc.CallFunc:create(function()   
            if spr ~= nil then  
                spr:removeFromParent()  
                spr = nil  
            end  
        end)))  
    else
        spr:runAction(action)
    end

    return spr
end

return AnimationUtil