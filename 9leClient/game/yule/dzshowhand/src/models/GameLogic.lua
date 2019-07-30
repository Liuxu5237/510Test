local GameLogic = {}

--*****************************扑克类型*********************************--
--[[
//数值掩码
#define LOGIC_MASK_COLOR		0xF0                //花色掩码
#define LOGIC_MASK_VALUE		0x0F                //数值掩码
]]
LOGIC_MASK_COLOR                = 0xF0              --花色掩码
LOGIC_MASK_VALUE                = 0x0F              --花色掩码

--[[
//扑克类型
#define CT_SINGLE				1					//单牌类型
#define CT_ONE_LONG				2					//对子类型
#define CT_TWO_LONG				3					//两对类型
#define CT_THREE_TIAO			4					//三条类型
#define CT_SHUN_ZI				5					//顺子类型
#define CT_TONG_HUA				6					//同花类型
#define CT_HU_LU				7					//葫芦类型
#define CT_TIE_ZHI				8					//铁支类型
#define CT_TONG_HUA_SHUN		9					//同花顺型
#define CT_KING_TONG_HUA_SHUN   10					//皇家同花顺
]]
CT_SINGLE				        = 1					--单牌类型
CT_ONE_LONG				        = 2					--对子类型
CT_TWO_LONG				        = 3					--两对类型
CT_THREE_TIAO			        = 4					--三条类型
CT_SHUN_ZI				        = 5					--顺子类型
CT_TONG_HUA				        = 6					--同花类型
CT_HU_LU				        = 7					--葫芦类型
CT_TIE_ZHI				        = 8					--铁支类型
CT_TONG_HUA_SHUN		        = 9					--同花顺型
CT_KING_TONG_HUA_SHUN           = 10				--皇家同花顺

--取模
function GameLogic:mod(a,b)
    return a - math.floor(a/b)*b
end

--获得牌的数值（1 -- 13）
function GameLogic:getCardValue(cbCardData)
    return self:mod(cbCardData, 16)
end

--获得牌的颜色（0 -- 4）
function GameLogic:getCardColor(cbCardData)
    return math.floor(cbCardData/16)
end

function GameLogic:getCardLogicValue(cbCardData)
	local cbCardValue = self:getCardValue(cbCardData)

	if cbCardValue == 1 then
		cbCardValue = cbCardValue + 13
	end

	return cbCardValue
end

--拷贝表
function GameLogic:copyTab(st)
    local tab = {}
    for k, v in pairs(st) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = self:copyTab(v)
        end
    end
    return tab
 end

--牌的排序
function GameLogic:sortCard(cardData)
	local cardDataTemp = self:copyTab(cardData)
    local num = table.getn(cardDataTemp)
    --先排颜色
    for i = 1, num - 1 do
        for j = 1, num - i do
            if cardDataTemp[j] < cardDataTemp[j + 1] then
                cardDataTemp[j], cardDataTemp[j + 1] = cardDataTemp[j + 1], cardDataTemp[j]
            end
        end
    end
    --再排大小
	for i = 1, num - 1 do
		for j = 1, num - i do
	        if self:getCardLogicValue(cardDataTemp[j]) < self:getCardLogicValue(cardDataTemp[j + 1]) then
	            cardDataTemp[j], cardDataTemp[j + 1] = cardDataTemp[j + 1], cardDataTemp[j]
	        end
		end
	end
    return cardDataTemp
end

--获得牌型
function GameLogic:getCardType(card)
	if #card ~= 3 then return false end

	local cardData = self:sortCard(card)

	local cbSameColor = true
	local bLineCard = true
	local cbFirstColor = self:getCardColor(cardData[1])
	local cbFirstValue = self:getCardLogicValue(cardData[1])
	--牌型分析
	for i = 1, 3 do
		if cbFirstColor ~= self:getCardColor(cardData[i]) then cbSameColor = false end
		if cbFirstValue ~= self:getCardLogicValue(cardData[i] + i - 1) then bLineCard = false end

		if cbSameColor == false and bLineCard == false then break end
	end
	--特殊A23
	if false == bLineCard then
		local bOne = false
		local bTwo = false
		local bThree = false
		for i = 1, 3 do
			if self:getCardValue(cardData[i]) == 1 then
				bOne = true
			elseif self:getCardValue(cardData[i]) == 2 then
				bTwo = true
			elseif self:getCardValue(cardData[i]) == 3 then
				bThree = true
			end
		end
		if bOne and bTwo and bThree then 
			bLineCard = true
		end
	end
	--顺金类型
	if cbSameColor and bLineCard then
		return GameLogic.CT_SHUN_JIN
	end
	--顺子类型
	if false == cbSameColor and bLineCard then
		return GameLogic.CT_SHUN_ZI
	end
	--金花类型
	if cbSameColor and false == bLineCard then
		return GameLogic.CT_JIN_HUA
	end
	--牌型分析
	local bDouble = false
	local bPanther = true
	--对牌类型
	for i = 1, 3 - 1 do
		for j = i + 1 , 3 do
			if self:getCardLogicValue(cardData[i]) == self:getCardLogicValue(cardData[j]) then
				bDouble = true
				break
			end
		end
		if bDouble then break end
	end
	--三条（豹子）分析
	for i = 1, 3 do
		if bPanther and cbFirstValue ~= self:getCardLogicValue(cardData[i]) then
			bPanther = false
		end
	end
	--对子和豹子判断
	if bDouble then
		if bPanther then
			return GameLogic.CT_BAO_ZI
		else
			return GameLogic.CT_DOUBLE
		end
	end
	--特殊235
	local bTwo = false
	local bThree = false
	local bFive = false
	for i = 1, 3 do
		if self:getCardValue(cardData[i]) == 2 then
			bTwo = true
		elseif self:getCardValue(cardData[i]) == 3 then
			bThree = true
		elseif self:getCardValue(cardData[i]) == 5 then
			bFive = true
		end
	end
	if bTwo and bThree and bFive then
		return GameLogic.CT_SPECIAL
	end


	return GameLogic.CT_SINGLE
end

return GameLogic