-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
-- 总结算页面

local GameEndView = class("GameEndView", cc.Layer)
local HeadSprite = appdf.req(appdf.EXTERNAL_SRC .. "HeadSprite")
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local cmd = appdf.req(appdf.GAME_SRC .. "yule.dzshowhand.src.models.CMD_Game")
local TAG_BTN_NEXT = 0xF0
local TAG_BTN_CLOSE = 0xF1
local TAG_BTN_EXIT = 0xF2

function GameEndView:ctor(scene, tGameEnd)
    self._scene = scene
    self.m_tGameEnd = tGameEnd

    local this = self

    ExternalFun.registerNodeEvent(self)
    -- display.loadSpriteFrames(cmd.RES .. "game/card.plist", cmd.RES .. "game/card.png")
    -- 加载csb资源
    local rootLayer, csbNode = ExternalFun.loadRootCSB(cmd.RES .. "game/GameEndViewLayer.csb", self)
    self.m_csbNode = csbNode

    local Panel_Fixed = csbNode:getChildByName("Panel_Fixed")

    -- 按钮回调
    local btcallback = function(ref, type)
        if type == ccui.TouchEventType.ended then
            this:OnButtonClickedEvent(ref:getTag(), ref)
        end
    end

    -- 下一局
    local Btn_Next = Panel_Fixed:getChildByName("Btn_Next")
    Btn_Next:setTag(TAG_BTN_NEXT)
    Btn_Next:addTouchEventListener(btcallback)

    -- 关闭
    local Btn_Close = Panel_Fixed:getChildByName("Btn_Close")
    Btn_Close:setTag(TAG_BTN_CLOSE)
    Btn_Close:addTouchEventListener(btcallback)

    -- 用户信息
    for i = 1, GAME_PLAYER do
        local userInfo = Panel_Fixed:getChildByName("UserInfo_" .. i)
        local userItem = self.m_tGameEnd.userItem[i]
        userInfo:setVisible(userItem ~= nil)
        if userItem then
            -- 头像
            local userHead = userInfo:getChildByName("userHead")
            local Pos = cc.p(userHead:getPosition())
            local head = HeadSprite:createNormal(userItem, 90)
            if nil ~= head then
                head:setAnchorPoint(cc.p(0.5, 0.5))
                head:setPosition(Pos)
                userHead:addChild(head)
            end
            -- 分数
            local userGameScore = userInfo:getChildByName("Text_UserScore")
            local lGameScore = self.m_tGameEnd.tEndScore[i]
            userGameScore:setString((lGameScore > 0 and('+') or '') .. tostring(lGameScore))

            -- 昵称
            local Text_Name = userInfo:getChildByName("Text_UserName")
             Text_Name:setString( userItem.szNickName)
      
            -- 用户手牌
            local UserHandCard = userInfo:getChildByName("Node_UserHandCard")
            local CardCount = #self.m_tGameEnd.tHandCard[i]
            for j = 1, CardCount do
                local HandCard = UserHandCard:getChildByName("Image_" .. j)
                self._scene._gameView:UpdateCardSpriteByValue(HandCard, self.m_tGameEnd.tHandCard[i][j])
            end
            -- 弃牌。显示2张手牌 隐藏剩下的三张
            if CardCount == 2 then
                for j = 1, MAX_CENTERCOUNT - CardCount do
                    local HandCard = UserHandCard:getChildByName("Image_" ..(CardCount + j))
                    HandCard:setVisible(false)
                end
            end
            -- 牌的类型
            local UserCardType = UserHandCard:getChildByName("Text_CardType")
            UserCardType:setString(self.m_tGameEnd.tCardType[i])
        end
    end

end

function GameEndView:onExit()
    -- self.Panel_Head:release()
end

function GameEndView:OnButtonClickedEvent(tag, ref)
    if tag == TAG_BTN_NEXT or tag == TAG_BTN_CLOSE then
        self._scene:onStartGame(true)
        self:removeFromParent()
    elseif tag == TAG_BTN_EXIT then
        self._scene:onExitTable()
    end
end

-- 视图转换
function GameEndView:SwitchViewChairID(wChairID)
    return self._scene:SwitchViewChairID(wChairID)
end

return GameEndView