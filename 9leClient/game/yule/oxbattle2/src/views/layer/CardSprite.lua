--
-- Author: zhong
-- Date: 2016-06-27 11:36:40
--

local GameLogic = appdf.req(appdf.GAME_SRC.."yule.oxbattle2.src.models.GameLogic")
local CardSprite = class("CardSprite", cc.Sprite);

CardSprite.Name = {
	"puke_big_diamond_%d.png",
	"puke_big_club_%d.png",
	"puke_big_heart_%d.png",
	"puke_big_spade_%d.png",
	"puke_big_0%d.png",
}

--纹理宽高
local CARD_WIDTH = 158;
local CARD_HEIGHT = 208;
local BACK_Z_ORDER = 2;

------
--set/get
function CardSprite:setDispatched( var )
	self.m_bDispatched = var;
end

function CardSprite:getDispatched(  )
	if nil ~= self.m_bDispatched then
		return self.m_bDispatched;
	end
	return false;
end
------

function CardSprite:ctor()
	self.m_cardData = 0
	self.m_cardValue = 0
	self.m_cardColor = 0
end

--创建卡牌
function CardSprite:createCard( cbCardData )
	if nil == cbCardData then return end
	local Value = GameLogic.GetCardValue(cbCardData)
	local Color = GameLogic.GetCardColor(cbCardData)
	local sp = CardSprite.new()
	sp.m_cardData = cbCardData
	sp.m_cardValue = Value 
	sp.m_cardColor = Color 

	sp:updateSprite();
	--扑克背面
	sp:createBack();

	return sp;
end

--设置卡牌数值
function CardSprite:setCardValue( cbCardData )
	self.m_cardData = cbCardData;
	self.m_cardValue = GameLogic.GetCardValue(cbCardData) --math.mod(cbCardData, 16) --bit:_and(cbCardData, 0x0F)
	self.m_cardColor = GameLogic.GetCardColor(cbCardData) --math.floor(cbCardData / 16) --bit:_rshift(bit:_and(cbCardData, 0xF0), 4)
	
	self:updateSprite();
end

--更新纹理资源
function CardSprite:updateSprite(  )
	local m_cardData = self.m_cardData;
	local m_cardValue = self.m_cardValue;
	local m_cardColor = self.m_cardColor;

	self:setTag(m_cardData);

	if 0 ~= m_cardData then
		self:setSpriteFrame(string.format(self.Name[m_cardColor+1], m_cardValue))
		self:setScaleX(80 / CARD_WIDTH) 
        self:setScaleY(110 / CARD_HEIGHT)
	else
		--使用背面纹理区域
		self:setSpriteFrame("plist_puke_back.png")
		self:setScaleX(80 / CARD_WIDTH) 
        self:setScaleY(110 / CARD_HEIGHT)
	end
end

--显示扑克背面
function CardSprite:showCardBack(var)
	if nil ~= self.m_spBack then
		self.m_spBack:setVisible(var);
	end	
end

--创建背面
function CardSprite:createBack(  )
	-- local cardSize = self:getBoundingBox()
	local cardSize = self:getContentSize()
    local m_spBack = cc.Sprite:createWithSpriteFrameName("plist_puke_back.png")
    m_spBack:setPosition(cardSize.width * 0.5, cardSize.height * 0.5);
    m_spBack:setVisible(false);
    self:addChild(m_spBack);
    m_spBack:setLocalZOrder(BACK_Z_ORDER);
    self.m_spBack = m_spBack;
end

return CardSprite;