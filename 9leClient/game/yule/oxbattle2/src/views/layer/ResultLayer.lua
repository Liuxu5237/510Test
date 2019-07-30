--游戏结算层
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local ClipText = appdf.req(appdf.EXTERNAL_SRC .. "ClipText")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.oxbattle2.src.models.GameLogic")
local CardSprite = appdf.req(appdf.GAME_SRC.."yule.oxbattle2.src.views.layer.CardSprite")

local GameResultLayer = class("GameResultLayer", cc.Layer)
local wincolor = cc.c3b(255, 247, 178)
local failedcolor = cc.c3b(178, 243, 255)

function GameResultLayer:ctor(viewParent)
	self.m_parent = viewParent
	--玩家姓名
	self.my_name = self.m_parent:getMeUserItem().szNickName
	--庄家姓名
	self.bank_name = "系统坐庄"
	--自己是否是庄家
	self.isBank = false
	self.m_ResultNode = nil
	--庄家是否通杀
	self.isAll_Kills = false
	--控件
	self:initResultLayer()
end

function GameResultLayer:initResultLayer()
	local csbNode = ExternalFun.loadCSB("GameResult.csb", self)
	csbNode:setVisible(false)
	self:InitializationControl(csbNode)
end

--初始化控件
function GameResultLayer:InitializationControl(csbNode)
	self.m_ResultNode = csbNode
    --背景图片
	local temp = csbNode:getChildByName("im_result_bg")
	self.m_spBg = temp
    --玩家信息
	local mylist = temp:getChildByName("mylist")
	self.mylist = mylist
	local myname = self.mylist:getChildByName("myname")
	self.myname = myname
	self.m_selfscore = self.mylist:getChildByName("txt_self_win")
    --庄家信息
	local banklist = temp:getChildByName("banklist")
	self.banklist = banklist
	self.m_bankerscore = self.banklist:getChildByName("txt_banker_win")
	local bankname = self.banklist:getChildByName("bankname")
	self.bankname = bankname
    --详细信息
	local result_diagram = temp:getChildByName("result")
	self.result_diagram = result_diagram
	--通杀图片
	local all_kills = temp:getChildByName("all_kills")
	self.all_kills = all_kills
    --排行信息，根据是否通杀来判断是否显示
	local rank_list = temp:getChildByName("rank_list")
	self.rank_list = rank_list
	--第一名玩家名字和分数
	local first = rank_list:getChildByName("first")
	self.first = first
	self.first_name = first:getChildByName("first_name")
	self.first_score = first:getChildByName("first_score")
	--第二名玩家名字和分数
	local second = rank_list:getChildByName("second")
	self.second = second
	self.second_name = second:getChildByName("second_name")
	self.second_score = second:getChildByName("second_score")
	--第三名玩家名字和分数
	local third = rank_list:getChildByName("third")
	self.third = third
	self.third_name = third:getChildByName("third_name")
	self.third_score = third:getChildByName("third_score")
	--第四名玩家名字和分数
	local fourth = rank_list:getChildByName("fourth")
	self.fourth = fourth
	self.fourth_name = fourth:getChildByName("fourth_name")
	self.fourth_score = fourth:getChildByName("fourth_score")
	--第五名玩家名字和分数
	local fifth = rank_list:getChildByName("fifth")
	self.fifth = fifth
	self.fifth_name = fifth:getChildByName("fifth_name")
	self.fifth_score = fifth:getChildByName("fifth_score")
	--四个区域的分数
	local detailslist = temp:getChildByName("detailslist")
	--天
	local tian = detailslist:getChildByName("tian")
	self.tian = tian
	self.tian_score = tian:getChildByName("tian_score")
	--地
	local di = detailslist:getChildByName("di")
	self.di = di
	self.di_score = di:getChildByName("di_score")
	--玄
	local xuan = detailslist:getChildByName("xuan")
	self.xuan = xuan
	self.xuan_score = xuan:getChildByName("xuan_score")
	--黄
	local huang = detailslist:getChildByName("huang")
	self.huang = huang
	self.huang_score = huang:getChildByName("huang_score")

    --确定按钮
	local close_btn = temp:getChildByName("close_btn")
	close_btn:addTouchEventListener(
		function ( ref, eventType )
			if ccui.TouchEventType.began == eventType then 
				ref:setScale(1.05)
			end
			if ccui.TouchEventType.canceled == eventType then 
				ref:setScale(1.00)
			end
			if ccui.TouchEventType.ended == eventType then 
				self:setVisible(false)
				ref:setScale(1.00)
			end
		end)
end

function GameResultLayer:showGameResult(selfscore, bankerscore, event, bankeruser) 
	if event then
		event.wBankerUser = tonumber(bankeruser)
	end
	self.m_lselfscore = selfscore
	self.m_lselfreturnscore = selfreturnscore
	self.m_lbankerscore = bankerscore
	self:ProcessingMessages(event)
	self:IsBankerKilling()
	self:showGameResultData(event)
	self:setVisible(true)
end

function GameResultLayer:showGameResultData(event)

	self.m_ResultNode:setVisible(true)
	self.m_ResultNode:stopAllActions()

	self.m_spBg:setScale(0.1)
	self.m_spBg:runAction(cc.ScaleTo:create(0.2, 1.0))

	self:SetValue()
	self:ChangeTheTexture()
	self:SettingTheDisplayStatus()
	self:AddCardsToTheParentNode(event)
end

--处理服务端发过来的消息
function GameResultLayer:ProcessingMessages(event)
	--自己是否是庄家
	self.isBank = self.m_parent:isMeChair(event.wBankerUser)
	--牌的信息
	self.card_size = event.cbTableCardArray
	--四个区域输赢信息
	local content = event.lPosScore or nil
	--前五名的分数
	local first_fifth_scores = event.lResultScore[1]
	--前五名的昵称
	local first_fifth_nicknames = event.szResultNickName[1]
	--庄家姓名
	if event.wBankerUser ~= yl.INVALID_CHAIR then
		self.bank_name = self.m_parent:getDataMgr():getChairUserList()[event.wBankerUser+1].szNickName
	end
	self:SetUpRankings(first_fifth_scores, first_fifth_nicknames)
	self:TextAssignment(content)
end

--判断庄家有没有通杀
function GameResultLayer:IsBankerKilling()
 	for i=2,#self.card_size do
    	if GameLogic:CompareCard(self.card_size[1], GameLogic:GetCardType(self.card_size[1], #self.card_size[1]), self.card_size[i], GameLogic:GetCardType(self.card_size[i], #self.card_size[i])) == 1 then
    		self.isAll_Kills = false
    		break
    	else
    		self.isAll_Kills = true
    	end 
    end
 end 

 --对CSB文本进行赋值
 function GameResultLayer:TextAssignment(content)
	self.tian_score_get = content[1][1]
	self.di_score_get = content[1][2]
	self.xuan_score_get = content[1][3]
	self.huang_score_get = content[1][4]
 end

 --设置排名
 function GameResultLayer:SetUpRankings(tScore, tName)
 	local rank = {self.first, self.second, self.third, self.fourth, self.fifth}
 	local name = {self.first_name, self.second_name, self.third_name, self.fourth_name, self.fifth_name}
 	local score = {self.first_score, self.second_score, self.third_score, self.fourth_score, self.fifth_score}
 	for i=1,#tScore-1 do
 		local max = i
 		for j=i+1,#tScore do
	 		if tScore[max] < tScore[j] then 
	 			max = j
	 		end
 		end
 		tScore[i], tScore[max] = tScore[max], tScore[i]
		tName[i], tName[max] = tName[max], tName[i]
 	end
 	dump(tScore, "排序后的分数", 10)
 	dump(tName, "排序后的名字", 10)
 	for k=1,#tScore do
 		name[k]:setString(tName[k])
 		score[k]:setString(tScore[k])
 		if tScore[k] <= 0 then 
 			rank[k]:setVisible(false)
 		else
 			rank[k]:setVisible(true)
 		end 
 	end
 end

--添加牌到对应区域
function GameResultLayer:AddCardsToTheParentNode(event)
	--牌的数据
	local card_data = event.cbTableCardArray
	local parent_node_sequence = {self.banklist, self.tian, self.di, self.xuan, self.huang}
	local place_position = {cc.p(250, 33.5), cc.p(270, 33.5), cc.p(290, 33.5), cc.p(310, 43.5), cc.p(330, 43.5), 
							cc.p(70, 11.5), cc.p(90, 11.5), cc.p(110, 11.5), cc.p(130, 23.5), cc.p(150, 23.5), 
							cc.p(70, 11.5), cc.p(90, 11.5), cc.p(110, 11.5), cc.p(130, 23.5), cc.p(150, 23.5), 
							cc.p(70, 11.5), cc.p(90, 11.5), cc.p(110, 11.5), cc.p(130, 23.5), cc.p(150, 23.5),
							cc.p(70, 11.5), cc.p(90, 11.5), cc.p(110, 11.5), cc.p(130, 23.5), cc.p(150, 23.5)
						}
	for i=1,5 do
		for j=1,5 do
			if self.card_size[i][j] == 65 then self.card_size[i][j] = 78 end
			if self.card_size[i][j] == 66 then self.card_size[i][j] = 79 end
		end
	end
	local niuvalue = {}
    for i=1,5 do
        niuvalue[i] = GameLogic:GetCardType(self.card_size[i], #self.card_size[i])
    end
	for i=1,5 do
		--添加牌
		GameLogic:GetCardType(self.card_size[i], #self.card_size[i])--逻辑排序
		for j=1,#self.card_size[i] do
			if not tolua.isnull(parent_node_sequence[i]:getChildByName("brand"..i.."_"..j)) then
				parent_node_sequence[i]:getChildByName("brand"..i.."_"..j):setCardValue(self.card_size[i][j])
				parent_node_sequence[i]:getChildByName("brand"..i.."_"..j):setScale(0.25)
			else
				local brand = CardSprite:createCard(self.card_size[i][j])
				:setScale(0.25)
				:setName("brand"..i.."_"..j)
				:addTo(parent_node_sequence[i])
				:setPosition(place_position[i*(#self.card_size[i])-(#self.card_size[i]-j)]) 
			end
		end
		--添加牌面大小
		self:AddCardSize(card_data, parent_node_sequence, place_position, i)
		
	end
end

--设置庄通杀，排名是否显示
function GameResultLayer:SettingTheDisplayStatus()
	--根据庄家是否通杀来决定图片是否显示
	if self.isAll_Kills then 
		self.all_kills:setVisible(true)  --显示庄通杀图片
		self.rank_list:setVisible(false) --隐藏前五名玩家分数
	else
		self.all_kills:setVisible(false) --隐藏庄通杀图片
		self.rank_list:setVisible(true)  --显示前五名玩家分数
	end
end

--通过结局分数改变纹理图片
function GameResultLayer:ChangeTheTexture()
	if self.m_lselfscore >= 0 then
		self.result_diagram:setSpriteFrame("Brnn_Win_bt1.png") --, UI_TEX_TYPE_PLIST
		self.m_spBg:setTexture("game_res/Brnn_Win_bg1.png")--,UI_TEX_TYPE_LOCAL
		ExternalFun.playSoundEffect("WIN.mp3")
	else
		self.result_diagram:setSpriteFrame("Brnn_Failed_bt1.png") --, UI_TEX_TYPE_PLIST
		self.m_spBg:setTexture("game_res/Brnn_Failed_bg1.png") --,UI_TEX_TYPE_LOCAL
		ExternalFun.playSoundEffect("LOSE.mp3")
	end
end

--设置数值
function GameResultLayer:SetValue()
	local winstr = ExternalFun.numberThousands(self.m_lselfscore)
	self.m_selfscore:setString(winstr)

	local bankerstr = ExternalFun.numberThousands(self.m_lbankerscore)
	self.m_bankerscore:setString(bankerstr)

	local tian = ExternalFun.numberThousands(self.tian_score_get)
	self.tian_score:setString(tian)

	local di = ExternalFun.numberThousands(self.di_score_get)
	self.di_score:setString(di)

	local xuan = ExternalFun.numberThousands(self.xuan_score_get)
	self.xuan_score:setString(xuan)

	local huang = ExternalFun.numberThousands(self.huang_score_get)
	self.huang_score:setString(huang)

	self.myname:setString(self.my_name)
	self.bankname:setString(self.bank_name)
end

function GameResultLayer:AddCardSize(card_data, parent_node_sequence, place_position, order)
	local deck = GameLogic:GetCardType(card_data[order], #card_data[order])
	if not tolua.isnull(parent_node_sequence[order]:getChildByName("deck_size")) then 
		parent_node_sequence[order]:getChildByName("deck_size"):setSpriteFrame(string.format("Brnn_%d.png", deck))
	else  --第一次创建纹理
		local deck_size = cc.Sprite:createWithSpriteFrameName(string.format("Brnn_%d.png", deck))
		:setName("deck_size")
		:addTo(parent_node_sequence[order])
		:setPosition(place_position[(order*(#card_data[order]))].x, place_position[(order*(#card_data[order]))].y)
	end
end

function GameResultLayer:clear()
	
end

return GameResultLayer