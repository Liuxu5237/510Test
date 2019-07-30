--
-- Author: Hello World
-- Date: 2018-07-19 16:04:07
--
local AnimationUtil = appdf.req(appdf.GAME_SRC.."yule.oxbattle2.src.views.layer.AnimationUtil")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.oxbattle2.src.models.GameLogic")
OpenPukeEffect = class("OpenPukeEffect")

OpenPukeEffect.normalMap = {
	[10] = { val = {v = false},col = {v = true, p = cc.p(288.32,150.28),s = 0.275,r = 90 }},
	[11] = { val = {v = false},col = {v = true, p = cc.p(288.34,158.99),s = 0.3992,r = 90 }},
	[12] = { val = {v = false},col = {v = true, p = cc.p(289.36,162.2),s = 0.3992,r = 90 }},
	[13] = { val = {v = true,p = cc.p(304.58,168.07),s = 0.321,r = 90},col = {v = true, p = cc.p(287.67,168.21),s = 0.3992 ,r = 90}},
	[14] = { val = {v = true,p = cc.p(304.58,168.07),s = 0.321,r = 90},col = {v = true, p = cc.p(287.67,168.21),s = 0.3992 ,r = 90}},
	[15] = { val = {v = true,p = cc.p(304.58,168.07),s = 0.321,r = 90},col = {v = true, p = cc.p(287.67,168.21),s = 0.3992 ,r = 90}},
	[16] = { val = {v = true,p = cc.p(304.58,168.07),s = 0.321,r = 90},col = {v = true, p = cc.p(287.67,168.21),s = 0.3992 ,r = 90}},
	[17] = { val = {v = true,p = cc.p(304.04,203.75),s = 0.321,r = 70},col = {v = true, p = cc.p(287.13,199.21),s = 0.3992 ,r = 70}},
}

OpenPukeEffect.map = {
	[10] = { val = {v = true,p = cc.p(288.2,150.5),s = 0.7,r = 90},col = {v = false}},
	[11] = { val = {v = true,p = cc.p(286.56,157.7),s = 0.7,r = 90},col = {v = false}},
	[12] = { val = {v = true,p = cc.p(288.37,162.39),s = 0.7,r = 90},col = {v = false}},
	[13] = { val = {v = true,p = cc.p(286.78,168.35),s = 0.7,r = 90},col = {v = false}},
	[14] = { val = {v = true,p = cc.p(288.03,167.43),s = 0.7,r = 90},col = {v = false}},
	[15] = { val = {v = true,p = cc.p(288.03,167.43),s = 0.7,r = 90},col = {v = false}},
	[16] = { val = {v = true,p = cc.p(288.03,167.43),s = 0.7,r = 90},col = {v = false}},
	[17] = { val = {v = true,p = cc.p(288.29,198.25),s = 0.7,r = 70},col = {v = false}},
}


-- 翻牌动画
function OpenPukeEffect:create(cardData,frameStr,_fps)
	dump(cardData,"卡牌数据是------------------", 10)

	local fps = _fps or 20
	local frameCount = 23

	local spr = AnimationUtil.playEffectFromSpriteFrame(frameStr,1,frameCount,fps,1,true,0.1)

	local valSpr = nil 
	local colorSpr = nil 
	local animationMap = {}

	local isNormalCardOrJoker = cardData ~= 65 and cardData ~= 66
  	if isNormalCardOrJoker then

	  	local value = GameLogic.GetCardValue(cardData)
	  	local color = GameLogic.GetCardColor(cardData)
		local valueColor = color % 2
		local valueSprName = string.format("plist_puke_value_%d_%d.png", valueColor, value)
		local colorSprName = string.format("plist_puke_color_small_%d.png", color)
		valSpr = cc.Sprite:createWithSpriteFrameName(valueSprName)
		colorSpr = cc.Sprite:createWithSpriteFrameName(colorSprName)
		valSpr:setRotation(90)
		colorSpr:setRotation(90)
		valSpr:setVisible(false)
		colorSpr:setVisible(false)
		spr:addChild(valSpr)
		spr:addChild(colorSpr)

		animationMap = self.normalMap
	else
		local valueSprName = "plist_puke_joker_small_%d.png"
		valueSprName = string.format(valueSprName, cardData == 66 and 1 or 0)
		
		valSpr = cc.Sprite:createWithSpriteFrameName(valueSprName)
		valSpr:setRotation(90)
		valSpr:setVisible(false)
		spr:addChild(valSpr)
		animationMap = self.map
	end


	local frameIndex = 0
	local updateFrame = function()

		frameIndex = frameIndex + 1

		local config = animationMap[frameIndex] 

		if config == nil then
			valSpr:setVisible(false)
			if colorSpr then colorSpr:setVisible(false) end
		 	return 
		end

		valSpr:setVisible(config.val.v)	

		if colorSpr then colorSpr:setVisible(config.col.v) end
		if config.val.v then
			valSpr:setPosition(config.val.p)
			valSpr:setScale(config.val.s)
			valSpr:setRotation(config.val.r)
		end
		if config.col.v then
			if colorSpr then
				colorSpr:setPosition(config.col.p)
				colorSpr:setScale(config.col.s)
				colorSpr:setRotation(config.col.r)
			end
		end
	end

	local delayTime = 1/fps
	spr:runAction(cc.Repeat:create(cc.Sequence:create(cc.CallFunc:create(updateFrame),cc.DelayTime:create(delayTime)), frameCount))

    return spr
end

openPukeEffect = OpenPukeEffect:new()
return openPukeEffect