GameBroadCast = class("GameBroadCast", 
    function()
        return cc.Layer:create()
    end
)

GameBroadCast._bkImg = nil
GameBroadCast._bkImgLeft = nil
GameBroadCast._bkImgRight = nil
GameBroadCast._bkImgText = nil
--GameBroadCast.BroadText = ""
GameBroadCast.BroadCount = 0;

-----
GameBroadCast.BroadTextArr = {}
GameBroadCast.isPlay = false
GameBroadCast._self = NULL
-----

local function runTextAction()
    if GameBroadCast.BroadCount == 0 then
        return;
    end
end

function GameBroadCast:create()
    local layer = GameBroadCast.new()
    return layer
end

--------------------
function GameBroadCast:getBroad(_count,_Text)
    GameBroadCast.BroadCount = GameBroadCast.BroadCount + _count
    for i=1,_count do
        table.insert(GameBroadCast.BroadTextArr,_Text)
    end
    print("插入广播 ".._count.." 条，共有广播 "..GameBroadCast.BroadCount.." 条")
end
--------------------

function GameBroadCast:textRunAction()
    if GameBroadCast.isPlay == false then
        GameBroadCast.isPlay = true
        GameBroadCast._bkImgText:setString(GameBroadCast.BroadTextArr[1])
        GameBroadCast._bkImgText:setPositionY(GameBroadCast._bkImg:getPositionY())
        GameBroadCast._bkImgText:setVisible(true)
        local seq = cc.Sequence:create(cc.CallFunc:create(function(sender)
            sender:setPositionX(1250)
        end),cc.MoveBy:create(30, cc.p(-3000,0)),nil)
        GameBroadCast._bkImgText:runAction(seq)
        local nTime = GameBroadCast:getTime(string.len(GameBroadCast.BroadTextArr[1]))
        self:runAction(cc.Sequence:create(cc.DelayTime:create(nTime),cc.CallFunc:create(function()
             GameBroadCast._bkImgText:stopAllActions()
             GameBroadCast._bkImgText:setVisible(false)
             table.remove(GameBroadCast.BroadTextArr,1)
             GameBroadCast.BroadCount = GameBroadCast.BroadCount - 1
             print("播放完毕！剩余广播 "..GameBroadCast.BroadCount)
             self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
                if GameBroadCast.BroadCount > 0 then
                    GameBroadCast.isPlay = false
                    self:textRunAction()
                else
                    GameBroadCast.isPlay = false
                    import("app.views.MainScene").gameBroadCast:setVisible(false)
                end
             end),nil))
        end),nil))
    end
end

function GameBroadCast:init(_y)
    local BroadScene = cc.CSLoader:createNode("broadcast/Scene.csb")
    local BroadPanel = BroadScene:getChildByName("Panel")
    BroadPanel:setPositionY(_y)
    GameBroadCast._bkImg = BroadPanel:getChildByName("Guangbo")
    GameBroadCast._bkImgLeft = BroadPanel:getChildByName("left")
    GameBroadCast._bkImgRight = BroadPanel:getChildByName("right")
    GameBroadCast._bkImgText = BroadPanel:getChildByName("Text")

    --self:textRunAction()
    self:addChild(BroadScene)
end

function GameBroadCast:getTime(_textLen)
    local nTime = 14
    if _textLen >= 1 and _textLen <= 18 then
        nTime = 14
    elseif _textLen >= 19 and _textLen <= 27 then
        nTime = 15
    elseif _textLen >= 28 and _textLen <= 36 then
        nTime = 16
    elseif _textLen >= 37 and _textLen <= 45 then
        nTime = 17
    elseif _textLen >= 46 and _textLen <= 54 then
        nTime = 18
    elseif _textLen >= 55 and _textLen <= 63 then
        nTime = 19
    elseif _textLen >= 64 and _textLen <= 72 then
        nTime = 20
    elseif _textLen >= 73 and _textLen <= 81 then
        nTime = 21
    elseif _textLen >= 82 and _textLen <= 90 then
        nTime = 22
    elseif _textLen >= 91 and _textLen <= 99 then
        nTime = 23
    elseif _textLen >= 100 and _textLen <= 108 then
        nTime = 24
    elseif _textLen >= 109 and _textLen <= 117 then
        nTime = 25
    elseif _textLen > 117 then
        nTime = 30
    end

    return nTime
end
