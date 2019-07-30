--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
local QBasePlayer = class("QBasePlayer",function ()
	-- body
	return cc.Layer:create()
end)

local cmd = appdf.req(appdf.GAME_SRC.."yule.oxsixex.src.models.CMD_Game")
local CardSprite = appdf.req(appdf.GAME_SRC.."yule.oxsixex.src.views.bean.CardSprite")
local QScrollText = appdf.req(appdf.GAME_SRC.."yule.oxsixex.src.views.bean.QScrollText")
local NGResources = appdf.req(appdf.GAME_SRC.."yule.oxsixex.src.views.NGResources")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.oxsixex.src.models.GameLogic")

local AnimationRes = 
{
    --{name = "banker", file = GameViewLayer.RES_PATH.."animation_banker/banker_", nCount = 11, fInterval = 0.2, nLoops = 1},
    --{name = "faceFlash", file = GameViewLayer.RES_PATH.."animation_faceFlash/faceFlash_", nCount = 2, fInterval = 0.6, nLoops = -1},
    --{name = "lose", file = GameViewLayer.RES_PATH.."animation_lose/lose_", nCount = 17, fInterval = 0.1, nLoops = 1},
    --{name = "start", file = GameViewLayer.RES_PATH.."animation_start/start_", nCount = 11, fInterval = 0.15, nLoops = 1},
    --{name = "victory", file = GameViewLayer.RES_PATH.."animation_victory/victory_", nCount = 17, fInterval = 0.13, nLoops = 1},
    {name = "yellow", file = NGResources.GameRes.sAnimation_Yellow, nCount = 5, fInterval = 0.2, nLoops = 1},
    {name = "blue", file = NGResources.GameRes.sAnimation_Blue, nCount = 5, fInterval = 0.2, nLoops = 1}
}
local opencardtipspoint = {cc.p(870,710), cc.p(390,600), cc.p(390,370), cc.p(770,210), cc.p(950,370), cc.p(950,600)}

function QBasePlayer:ctor()
    self.m_nViewID_ = -1
    self.m_pImageHand_ = {}
    self.m_tHandCardData_ = {}
    self.m_pNodeType_ = nil
    self.m_pNodeContain_ = nil
    self.m_pTextJs_ = nil
    self.m_pImageBack_ = {}
    self.m_pImageTipsCard_ = nil
    self.vHeadPos = nil
    self.m_pImageChat_ = nil
    self:preloadUI()
end

function QBasePlayer:preloadUI()
    --display.loadSpriteFrames(NGResources.GameRes.sGameListPath,
    --                        NGResources.GameRes.sGamePngPath)

    for i = 1, #AnimationRes do
        local animation = cc.Animation:create()
        animation:setDelayPerUnit(AnimationRes[i].fInterval)
        animation:setLoops(AnimationRes[i].nLoops)

        for j = 1, AnimationRes[i].nCount do
            local strFile = AnimationRes[i].file..string.format("%d.png", j)
            animation:addSpriteFrameWithFile(strFile)
        end

        cc.AnimationCache:getInstance():addAnimation(animation, AnimationRes[i].name)
    end
end

function QBasePlayer:getAnimate(name, bEndRemove)
    local animation = cc.AnimationCache:getInstance():getAnimation(name)
    local animate = cc.Animate:create(animation)

    if bEndRemove then
        animate = cc.Sequence:create(animate, cc.CallFunc:create(function(ref)
            ref:removeFromParent()
        end))
    end

    return animate
end

function QBasePlayer:setViewID(id)
    self.m_nViewID_ = id
end

function QBasePlayer:initContain()
    if self.m_nViewID_ == cmd.MY_VIEW_CHAIRID then
        return
    end

    self.m_pNodeContain_ = cc.Node:create()
    self.m_pNodeContain_:setContentSize(cc.size(220.0,140.0))
    self:addChild(self.m_pNodeContain_)
    if self.m_nViewID_ == cmd.VIEW_TOP_MIDDLE  then
        self.m_pNodeContain_:setPosition(cc.p(self.vHeadPos.x + 80.0,self.vHeadPos.y - 70))
    elseif self.m_nViewID_ == cmd.VIEW_TOP_LEFFT then
        self.m_pNodeContain_:setPosition(cc.p(self.vHeadPos.x + 80.0,self.vHeadPos.y - 70))
    elseif self.m_nViewID_ == cmd.VIEW_MIDDLE_LEFFT  then
        self.m_pNodeContain_:setPosition(cc.p(self.vHeadPos.x + 80.0,self.vHeadPos.y - 70))
    elseif self.m_nViewID_ == cmd.VIEW_MIDDLE_RIGHT then
        self.m_pNodeContain_:setPosition(cc.p(self.vHeadPos.x - 320.0,self.vHeadPos.y - 70))
    elseif self.m_nViewID_ == cmd.VIEW_TOP_RIGHT then
        self.m_pNodeContain_:setPosition(cc.p(self.vHeadPos.x - 320.0,self.vHeadPos.y - 70))
    end
end

function QBasePlayer:initBackAct()
    local pTexture  = cc.Director:getInstance():getTextureCache():addImage(NGResources.GameRes.sCardPath)
    local pSprite = nil
    local x = display.width/2 - 45.0
    local y = 200
    if self.m_nViewID_ ~= cmd.MY_VIEW_CHAIRID then
        x = self.m_pNodeContain_:getPositionX() + 65.0
        y = self.m_pNodeContain_:getPositionY() + 160.0
    end
    for i=1,cmd.MAX_COUNT do
        local cardRect = cc.rect(2*119.2,4*161.8,119.2,161.8);
	    pSprite = cc.Sprite:createWithTexture(pTexture,cardRect)
        pSprite:setAnchorPoint(display.LEFT_BOTTOM)
        pSprite:setPosition(x,y)
        pSprite:setVisible(false)
        self:addChild(pSprite)
        table.insert(self.m_pImageBack_,pSprite)
    end
end

--显示牛几
function QBasePlayer:showCardTypeUI(iValue,iType)
    if self.m_pNodeType_ then
        self.m_pNodeType_:removeAllChildren()
    else
        self.m_pNodeType_ = cc.Node:create()
        self:addChild(self.m_pNodeType_,10)
        if self.m_nViewID_ == cmd.VIEW_TOP_MIDDLE  then
            self.m_pNodeType_:setPosition(cc.p(self.vHeadPos.x + 170.0,self.vHeadPos.y - 45))
        elseif self.m_nViewID_ == cmd.VIEW_TOP_LEFFT then
            self.m_pNodeType_:setPosition(cc.p(self.vHeadPos.x + 170.0,self.vHeadPos.y - 45))
        elseif self.m_nViewID_ == cmd.VIEW_MIDDLE_LEFFT  then
            self.m_pNodeType_:setPosition(cc.p(self.vHeadPos.x + 170.0,self.vHeadPos.y - 45))
        elseif self.m_nViewID_ == cmd.MY_VIEW_CHAIRID then
            self.m_pNodeType_:setPosition(cc.p(705.0,50.0))
        elseif self.m_nViewID_ == cmd.VIEW_MIDDLE_RIGHT then
            self.m_pNodeType_:setPosition(cc.p(self.vHeadPos.x - 170.0,self.vHeadPos.y - 45))
        elseif self.m_nViewID_ == cmd.VIEW_TOP_RIGHT then
            self.m_pNodeType_:setPosition(cc.p(self.vHeadPos.x - 170.0,self.vHeadPos.y - 45))
        end
    end

    local pSprite = nil
    if iType == GameLogic.OX_FIVE_KING then                 --五花牛
        pSprite = display.newSprite("#sp_five_f_ox.png")
    else                                                    --普通牛或无牛
        pSprite = display.newSprite("#ox_"..iValue..".png")
    end

    if pSprite then
        local spritePos = cc.p(0,2)
        if iValue == 0 then
            if self.m_nViewID_ == cmd.MY_VIEW_CHAIRID then
                spritePos.x = 68
            else
                if self.m_nViewID_ == cmd.VIEW_MIDDLE_RIGHT or self.m_nViewID_ == cmd.VIEW_TOP_RIGHT then
                    spritePos.x = -28
                else
                    spritePos.x = 28
                end
            end
        else
            spritePos.x = 0
        end
        pSprite:setPosition(spritePos)
        pSprite:setScale(0.8)
        self.m_pNodeType_:addChild(pSprite)
    end
    --[[local pSprite1 = nil
    local pSprite2 = nil
    local pGameViewObj = self:getParent()
    if pGameViewObj then
        pSprite1,pSprite2 = pGameViewObj:getCardTypeSprite(iValue,iType)
    end

    if pSprite1 and pSprite2 then
        local cSize = pSprite1:getContentSize()
        self.m_pNodeType_:setContentSize(cc.size(cSize.width*2,cSize.height))
        self.m_pNodeType_:addChild(pSprite1)
        self.m_pNodeType_:addChild(pSprite2)
        --pSprite1:setAnchorPoint(display.LEFT_BOTTOM)
        --pSprite2:setAnchorPoint(display.LEFT_BOTTOM)
        pSprite1:setPosition(cc.p(-cSize.width/2,0))
        pSprite2:setPosition(cc.p(cSize.width/2,0))
    elseif pSprite1 then
        local cSize = pSprite1:getContentSize()
        self.m_pNodeType_:setContentSize(cc.size(cSize.width*2,cSize.height))
        self.m_pNodeType_:addChild(pSprite1)
        pSprite1:setPosition(cc.p(0,0))
    end]]
end

function QBasePlayer:showJskUI(iScore)
    if self.m_pTextJs_== nil then
        self.m_pTextJs_ = ccui.TextAtlas:create()
        self:addChild(self.m_pTextJs_,9)

        --[[if self.m_nViewID_ == cmd.VIEW_MIDDLE_RIGHT or self.m_nViewID_ == cmd.VIEW_TOP_RIGHT then
            self.m_pTextJs_:setAnchorPoint(display.RIGHT_BOTTOM)
            self.m_pTextJs_:setPosition(cc.p(self.vHeadPos.x,self.vHeadPos.y))
        else
            self.m_pTextJs_:setAnchorPoint(display.LEFT_BOTTOM)]]
            self.m_pTextJs_:setPosition(cc.p(self.vHeadPos.x,self.vHeadPos.y))
        --end
    else
        self.m_pTextJs_:setVisible(true)
    end

    local strAnimate     
    if iScore >=0 then
        strAnimate = "yellow"
        self.m_pTextJs_:setProperty("/" .. iScore, NGResources.GameRes.sTextAddNum, 34, 35, "/")
    else
        strAnimate = "blue"
        self.m_pTextJs_:setProperty("/" .. iScore, NGResources.GameRes.sTextSubNum, 34, 35, "/")
    end

    local anchorPointX = 0.5
    local offsetX = 0
    local txtWidth = self.m_pTextJs_:getContentSize().width
    local txtPos = cc.p(self.vHeadPos.x,self.vHeadPos.y)
    if self.m_nViewID_ == cmd.VIEW_TOP_LEFFT or self.m_nViewID_ == cmd.VIEW_MIDDLE_LEFFT then
        anchorPointX = 0
        offsetX = 160
        txtPos.x = txtPos.x - 69
    elseif self.m_nViewID_ == cmd.VIEW_MIDDLE_RIGHT or self.m_nViewID_ == cmd.VIEW_TOP_RIGHT then
        anchorPointX = 1.0
        offsetX = -160
        txtPos.x = txtPos.x + 69
    end
    self.m_pTextJs_:setAnchorPoint(cc.p(anchorPointX,0.5))
    self.m_pTextJs_:setPosition(cc.p(txtPos.x,txtPos.y))

    --底部动画
    local nTime = 1.0
    self.spriteAnimate = display.newSprite()
        :setAnchorPoint(cc.p(anchorPointX,0.5))
        :move(cc.p(self.vHeadPos.x - offsetX,self.vHeadPos.y))
        :addTo(self, 8)
    self.spriteAnimate:runAction(cc.Sequence:create(
        cc.Spawn:create(
            cc.MoveBy:create(nTime, cc.p(0, 90)),
            self:getAnimate(strAnimate)
        ),
        cc.DelayTime:create(1),
        cc.CallFunc:create(function(ref)
            if self.spriteAnimate ~= nil then
                self.spriteAnimate:removeFromParent()
                self.spriteAnimate = nil
            end
        end)
    ))

    self.m_pTextJs_:runAction(cc.Sequence:create(
        cc.Spawn:create(
            cc.MoveBy:create(nTime, cc.p(0, 90)), 
            cc.FadeIn:create(nTime)
        ),
        cc.DelayTime:create(1.1),
        cc.CallFunc:create(function(ref)
            ref:setVisible(false)
            ref:setPosition(cc.p(self.vHeadPos.x,self.vHeadPos.y))
        end)
    ))
end

function QBasePlayer:showTipsOpenCard(bShow)
    if self.m_nViewID_ == cmd.MY_VIEW_CHAIRID then
        return
    end

    if self.m_pImageTipsCard_ then
        self.m_pImageTipsCard_:setVisible(bShow)
    else
        if bShow then
            self.m_pImageTipsCard_ = ccui.ImageView:create(NGResources.GameRes.sImageOpenCardPath,ccui.TextureResType.plistType)
            self:addChild(self.m_pImageTipsCard_,11)

            if self.m_nViewID_ ~= cmd.MY_VIEW_CHAIRID  then
                print("==============下标==============="..self.m_nViewID_)
                self.m_pImageTipsCard_:setPosition(cc.p(opencardtipspoint[self.m_nViewID_ + 1].x, opencardtipspoint[self.m_nViewID_ + 1].y))
            end
        end
    end
end

function QBasePlayer:removeCardTypeUI()
    if self.m_pNodeType_ then
        self.m_pNodeType_:removeAllChildren()
    end
end

function QBasePlayer:removeHandCardUI()
    for i,v in pairs(self.m_pImageHand_) do
        v:removeFromParent()
        v = nil
    end

    self.m_pImageHand_ = {}
    self.m_tHandCardData_ = {}
end

function QBasePlayer:removeDeskCardUI()
    if self.m_pNodeContain_ then
        self.m_pNodeContain_:removeAllChildren()
    end
end

function QBasePlayer:removeJskUI()
    if self.m_pTextJs_ then
        self.m_pTextJs_:setVisible(false)
    end
    if self.spriteAnimate ~= nil then
        self.spriteAnimate:stopAllActions()
        self.spriteAnimate:removeFromParent()
        self.spriteAnimate = nil
    end
end

function QBasePlayer:showChat(strChat)
    if self.m_pImageChat_ == nil then
        if self.m_nViewID_ == cmd.VIEW_MIDDLE_RIGHT or self.m_nViewID_ == cmd.VIEW_TOP_RIGHT then
            self.m_pImageChat_ = ccui.ImageView:create(NGResources.GameRes.sChatBj2,ccui.TextureResType.plistType)
            self.m_pImageChat_:setAnchorPoint(display.RIGHT_BOTTOM)
        else
            self.m_pImageChat_ = ccui.ImageView:create(NGResources.GameRes.sChatBj1,ccui.TextureResType.plistType)
            self.m_pImageChat_:setAnchorPoint(display.LEFT_BOTTOM)
        end
        self.m_pImageChat_:setPosition(cc.p(self.vHeadPos.x,self.vHeadPos.y + 55.0))
        self:addChild(self.m_pImageChat_,20)

        local pChat = QScrollText:create(strChat, 22.0, 7)
	    pChat:setAnchorPoint(display.LEFT_CENTER)
	    pChat:setPosition(cc.p(9.0, 24.0))
	    self.m_pImageChat_:addChild(pChat,1,1)
    else
        local pChat = self.m_pImageChat_:getChildByTag(1)
        if pChat then
            pChat:showStr(strChat)
        end

        self.m_pImageChat_:setVisible(true)
    end


end

function QBasePlayer:removeUI()
    self:removeCardTypeUI()
    self:removeHandCardUI()
    self:removeDeskCardUI()
    self:removeJskUI()
end


return QBasePlayer

