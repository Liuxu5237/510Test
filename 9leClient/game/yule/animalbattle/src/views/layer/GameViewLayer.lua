local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local module_pre = "game.yule.animalbattle.src"
local cmd = appdf.req(module_pre .. ".models.CMD_Game")
local ZhuanPanAni=appdf.req(module_pre .. ".views.ZhuanPanAni")
local MenuLayer=appdf.req(module_pre..".views.layer.MenuLayer")
local PlayerlistLayer=appdf.req(module_pre .. ".views.layer.PlayerlistLayer")
local HeadSprite = appdf.req(appdf.EXTERNAL_SRC .. "HeadSprite")
local ClipText = appdf.req(appdf.EXTERNAL_SRC .. "ClipText")
local GameNotice = appdf.req(appdf.BASE_SRC .."app.views.layer.other.GameNotice")

local DEBUG=1
if DEBUG==1 then
	dbg_assert=assert
	dbg_print=print
else
	dbg_assert=function() end
	dbg_print=function() end
end

local GameViewLayer = class("GameViewLayer",function(scene)
        return display.newLayer()
end)

--下注数值
GameViewLayer.m_BTJettonScore = { 1000, 10000, 100000, 1000000, 5000000, 10000000}

--下注值对应金币个数
GameViewLayer.m_JettonGoldBaseNum = {1, 1, 2, 2, 3, 3, 4}


function GameViewLayer:ctor(scene)

	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    --用户信息改变事件
	eventDispatcher:addEventListenerWithSceneGraphPriority(
        cc.EventListenerCustom:create("ry_GetGameNotice", handler(self, self.NoticeCallBack)),
        self
		)
		
	--缓存筹码
	cc.SpriteFrameCache:getInstance():addSpriteFrames("client/res/Jetton/Chouma.plist")	

	self._scene = scene

	self.m_tabPlayerList={}
	self.turnTableRecords={}

	self.noteNumBtns={}
	self.betBtns={}

	self._record = {}
	self.m_goldList = {{},{}}

	--是否播放金币飞入音效
	self.m_bPlayGoldFlyIn = true
	 --下注倒计时
	 self.m_fJettonTime = 0.1
	--续压
	self.bContinueRecord = true  
	
	--下注按钮的tag
	self.m_nJettonSelect = 0
	--筹码按钮
	self.csbNode=ExternalFun.loadCSB("MainScene.csb",self)

	self.m_JettonLight = appdf.getNodeByName(self.csbNode,"im_jetton_select")
	--self.m_JettonLight:runAction(cc.RepeatForever:create(cc.Blink:create(1.0,1)))

	for i=1,6 do --6个赌注大小按钮
		self.noteNumBtns[i]=appdf.getNodeByName(self.csbNode,"betnum"..i)
		self.noteNumBtns[i].m_noteNum=math.pow(10,i+2)
		if i==5 then
			self.noteNumBtns[i].m_noteNum = 5000000
		elseif i == 6 then
			self.noteNumBtns[i].m_noteNum = 10000000
		end
		self.noteNumBtns[i]:setTag(i)
		self.noteNumBtns[i]:loadTextureNormal(string.format("client/res/Jetton/Button_chip_%d.png", self.noteNumBtns[i].m_noteNum), 0)
		self.noteNumBtns[i]:loadTextureDisabled(string.format("client/res/Jetton/Button_chip_%d_dis.png", self.noteNumBtns[i].m_noteNum), 0)
		self.noteNumBtns[i]:setScale(0.89)
		self.noteNumBtns[i]:addClickEventListener(function(sender) 
			self.m_nJettonSelect = i
			self.m_JettonLight:setPosition(sender:getPosition())
			self._scene:OnNoteSwitch(sender) 
		end)
	end

	
	--动物图片
	self.aniPos = {}
	self.anibg = {}
	for i=1,28 do
		local sp1=appdf.getNodeByName(self.csbNode,"Sprite_"..i)
		self.anibg[i] = sp1
		self.aniPos[i] =cc.p( sp1:getPosition() )
	end

	--下注按钮
	self.betBtnPoses={}
	self._blink = {}
	local touzhubg = self.csbNode:getChildByName("Touzhubg")
    for i=1,11 do --11个动物下注按钮 --betBtns[i]对应
    	local btn=appdf.getNodeByName(self.csbNode,"Button_"..i)
		btn.m_kind=i
		self.betBtns[i]=btn
		btn:addClickEventListener(function(sender)
			self._scene:OnPlaceJetton(sender) 
		end)
		self.betBtnPoses[i]=cc.p( btn:getPosition() )

		self._blink[i] = appdf.getNodeByName(self.csbNode,"blink_"..i)
		self._blink[i]:setVisible(false)
    end

	

    --self.backBtn=appdf.getNodeByName(self.csbNode,"backbtn")
    self.setBtn=appdf.getNodeByName(self.csbNode,"setbtn")
    self.continueBtn=appdf.getNodeByName(self.csbNode,"continuebtn")
	self.continueBtn:loadTextureDisabled("BTN-xutou3.png",0)
	
    --self.backBtn:addClickEventListener(function() self._scene:onKeyBack() end)
    local x,y=self.setBtn:getPosition()
    self.setBtn:addClickEventListener(function() self:addChild(MenuLayer:create(self,x,y),100) end)
    --self.clearBtn:addClickEventListener(function() self._scene:OnCleanJetton() end)
	self.continueBtn:addClickEventListener(function() 
		self.bContinueRecord = true
		
		if self:GetJettonRecord() >GlobalUserItem.lUserScore then
			local runScene = cc.Director:getInstance():getRunningScene()
			showToast(runScene, "下注筹码不足", 1)
		else
			self._scene:OnLastPlaceJetton() 	
		end
		self:updateXuya()
	end)

    self.timeTextImg=ccui.ImageView:create()

    local countBg=appdf.getNodeByName(self.csbNode,"countbg")
	self.timeTextImg:setPosition(110,26)
	self.timeClock = appdf.getNodeByName(countBg,"count_time")
    countBg:addChild(self.timeTextImg)

    self.recordbg=appdf.getNodeByName(self.csbNode,"recordbg")
 
    self.storagebg=appdf.getNodeByName(self.csbNode,"storagebg")



    self.recordView=nil

    self:initZhuanpan()

    self.storageLabelAtlas=cc.LabelAtlas:create("", "storage.png", 21, 31, string.byte("0")) 
    			:setAnchorPoint(0,0.5)
    			:setPosition(92,24)
    			:addTo(self.storagebg)


	self.m_pJettonNumber = 
	{
        --{k = 100, i = 1},
		{k = 1000, i = 1},
		{k = 10000, i = 2}, 
		{k = 100000, i = 3}, 
		{k = 1000000, i = 4},  
		{k = 5000000, i = 5},
		{k = 10000000, i = 6} 
    }
	self.goldLayer =  appdf.getNodeByName(self.csbNode,"gold_layer")
	--几个label
	--self.m_goldList = {} --下注筹码
	self.alljet =0
	self.myjet =0

	local tms1 = appdf.getNodeByName(self.csbNode,"label_curscore")
	self.lab_curscore = cc.Label:createWithTTF("", "fonts/round_body.ttf", 22)
	:setTextColor(cc.c3b(255,220,50))
	:setAnchorPoint(cc.p(0,0.5))
	:setPosition(tms1:getPosition())
	:addTo(tms1:getParent())
	tms1:removeFromParent()

	local tms2 = appdf.getNodeByName(self.csbNode,"label_total")
	self.lab_totalscore = cc.Label:createWithTTF("", "fonts/round_body.ttf", 22)
	:setTextColor(cc.c3b(255,220,50))
	:setAnchorPoint(cc.p(0,0.5))
	:setPosition(tms2:getPosition())
	:addTo(tms2:getParent())
	tms2:removeFromParent()

	local tms3 = appdf.getNodeByName(self.csbNode,"label_alljet")
	self.lab_alljet = cc.Label:createWithTTF("", "fonts/round_body.ttf", 22)
	:setTextColor(cc.WHITE)
	:setAnchorPoint(cc.p(0,0.5))
	:setPosition(tms3:getPosition())
	:addTo(tms3:getParent())
	tms3:removeFromParent()

	local tms4 = appdf.getNodeByName(self.csbNode,"label_myjet")
	self.lab_myjet = cc.Label:createWithTTF("", "fonts/round_body.ttf", 22)
	:setTextColor(cc.WHITE)
	:setAnchorPoint(cc.p(0,0.5))
	:setPosition(tms4:getPosition())
	:addTo(tms4:getParent())
	tms4:removeFromParent()

	--底部用户信息
	local tms5 = appdf.getNodeByName(self.csbNode,"lab_nick")
	self.label_nick = ClipText:createClipText(cc.size(150,24), "", "fonts/round_body.ttf", 20)
	self.label_nick:setTextColor(cc.WHITE)
	self.label_nick:setAnchorPoint(cc.p(0,0.5))
	self.label_nick:setPosition(tms5:getPosition())
	self.label_nick:addTo(tms5:getParent())
	self.label_nick:setString(GlobalUserItem.szNickName)
	tms5:removeFromParent()

	--头像
	self.headBG = appdf.getNodeByName(self.csbNode,"img_head")
	local head =HeadSprite:createNormal(GlobalUserItem, 48)
	head:setPosition(cc.p(self.headBG:getContentSize().width/2,self.headBG:getContentSize().height/2))
	head:setTag(1)
	self.headBG:addChild(head)
	
	appdf.getNodeByName(self.csbNode,"gold_icon"):setScale(1.0)
	local tms6 = appdf.getNodeByName(self.csbNode,"labl_score")
	self.lab_userscore = cc.Label:createWithTTF("", "fonts/round_body.ttf", 22)
	:setTextColor(cc.c3b(255,220,50))
	:setAnchorPoint(cc.p(0,0.5))
	:setPosition(tms6:getPosition())
	:addTo(tms6:getParent())
	tms6:removeFromParent()
	

    self.brightRects={} --闪烁亮框

    for i=1,3 do
    	self.brightRects[i]=cc.Sprite:create("WinFrame"..i..".png")
    	self.brightRects[i]:addTo(touzhubg)
    		:setVisible(false)
    		--:setScale(1.2,1.2)
    	self.brightRects[i].m_bVisible=false
    end
	--  self.brightRects[1]:setScale(1.3,1.3) --普通动物	
	--  self.brightRects[2]:setScale(1.3,1.3)  --鲨鱼
	--  self.brightRects[3]:setScale(1.15,1.15)  --飞禽或走兽

	 self:updateTotalScore(0)
	 self:updateCurrentScore(0)
     self:updateShowTurnTableRecord();
	--self.bAllowOpeningAni=false

   --self.storageLabelAtlas:setVisible(false)
   --	self:testPlayerlistLayer()
   --self:testRecord()
   -- self.testShowJieSuan=nil
   -- if self.testShowJieSuan==1 then
  	-- 	self:showJieSuanView(8,10,155)
   -- end

   self._laba =  GameNotice:create("",cc.p(667,630))
   self._laba:addTo(self.csbNode)

   --注册node事件
   ExternalFun.registerNodeEvent(self)

end

function GameViewLayer:NoticeCallBack( event )
	
		local msg  =  event._usedata["NoticeMsg"]
	
		if self._laba ~=nil then
			self._laba:addTrugTxt(msg)
		end
	
end


function GameViewLayer:animationForFirstOpening(duration)
	  self.firstOpeningAni=ZhuanPanAni:create(self,0,0,duration)
  	  self.firstOpeningAni:animationForFirstOpening()
end

-- function GameViewLayer:stopGameOverAnimations()
-- 	self:removeFirstOpeningAni()
-- 	self.oldStatus=self.m_cbGameStatus
-- 	self.statusTimeLeft= self.cbTimeLive
-- 	self.backgroundTime=os.time()
-- 	--self:stopAllActions()
-- 	if self.jsLayer and not tolua.isnull(self.jsLayer) then
-- 		self.jsLayer:removeSelf()
-- 	end
-- 	for k,brightRect in pairs(self.brightRects) do
-- 		if brightRect and not tolua.isnull(brightRect) then
-- 			brightRect:stopAllActions()
-- 			brightRect:setVisible(false)
-- 		end
-- 	end
-- end

-- --需和GameOver一致
-- ----  转两次
--    -- 转盘  js     空闲   二次转盘   js2
-- 	--1-10, 11-13, 14-15, 16-25    ,26-28

-- --转一次
-- 	--转盘,js
-- 	--1-12,13-17 
-- function GameViewLayer:resumeGameOverAnimations()
-- 	if nil==self.backgroundTime then return end
-- 	local curTime=os.time()
-- 	local timeElapsed=curTime-self.backgroundTime
-- 	if self.oldStatus~=cmd.GS_GAME_END or timeElapsed>=self.statusTimeLeft-3 then--开奖状态剩余时间<=3时不再显示动画
-- 		return
-- 	end
-- 	-- if nil==self.turnTableTarget then
-- 	-- 	self:animationforFirstAnimation() 
-- 	-- 	return
-- 	-- end

-- 	local bTurnTwoTime=0 --temp delete
-- 	local timeLeft=self.statusTimeLeft - timeElapsed 
-- 	if bTurnTwoTime==1 then
-- 		-- local elapsed=30-timeLeft
-- 		-- if elapsed<10 then   --zhuanpan
-- 		-- 	self.zhuanPanAni:resumeZhuanPan(timeElapsed)
-- 		-- 	调度第二次转盘
-- 		-- elseif elapsed<13 then --js
-- 		-- 	self:showJieSuanView()
-- 		-- 	调度第二次转盘
-- 		-- elseif elapsed<15 then
-- 		-- 	--空闲
-- 		-- elseif elapsed<25 then --zhuanpan2
-- 		-- 	self.zhuanPanAni=zhuanPanAni:create(...)
-- 		-- elseif elapsed<28 --js2
-- 		-- 	self:showJieSuanView()
-- 		-- end
-- 	else
		
-- 		 local elapsed=20-timeLeft
-- 		 if elapsed<12 then   --zhuanpan
-- 		 	self.zhuanPanAni:resumeZhuanPan(timeElapsed)
-- 		 elseif elapsed<17 then
-- 		 	self:showJieSuanView(self.resultKind1,17-elapsed,self.shaYuAddMulti)
-- 		 end
-- 	end
-- end

function GameViewLayer:testPlayerlistLayer()
	local playerlist={}
	for i=1,3 do 
		playerlist[i]={}
		playerlist[i].szNickName="玩家"..i.."号"
		playerlist[i].wFaceID=100+i
		playerlist[i].lScore=i*i*i*i+10000
	end
	self:addChild(PlayerlistLayer:create(playerlist),10000)
end

--没用到
function GameViewLayer:testRecord()
	-- self.turnTableRecords={0,1,2,3,4,5,6,7,8,9}--,10,11,0,1,2,3,4,5,6,7,8,9,10,11,5,6,7}
	local i=0
	while i<69 do
		i=i+1
		self:AddTurnTableRecord(i%10)
		self:updateShowTurnTableRecord()
	end
end

function GameViewLayer:getPlayerList()
	--return self.m_tabPlayerList
	return self._scene:getPlayerList()
end

function GameViewLayer:AddTurnTableRecord(betResultId)
	local len=#self.turnTableRecords
	if len >10*cmd.RECORD_COUNT_MAX then   --10可以换成任意大于1的数字
		for i=1,cmd.RECORD_COUNT_MAX-1 do	                    --删除old记录，只保留最近的cmd.RECORD_COUNT_MAX-1个
			self.turnTableRecords[i]=self.turnTableRecords[i+1+len-cmd.RECORD_COUNT_MAX]
		end
		for i=cmd.RECORD_COUNT_MAX,len do
			self.turnTableRecords[cmd.RECORD_COUNT_MAX]=nil
		end
	end
	table.insert(self.turnTableRecords,betResultId)
end

function GameViewLayer:updateShowTurnTableRecord()

	local recordTable=self.turnTableRecords
	local len=#recordTable

	local w,h=68,52
	local cellW=50

	local function scrollViewDidScroll(view)
		local limit=(10-len)*cellW
		if len>10 and view:getContentOffset().x<limit then --view:runAction实现拖拉反弹
			view:setContentOffset(cc.p(limit,0))
		elseif len<=10 and view:getContentOffset().x<0 then
			view:setContentOffset(cc.p(0,0))
		end
	end 

	local function numberOfCellsInTableView()
		return cmd.RECORD_COUNT_MAX 
	end

	local function cellSizeForTable(view,idx) 
    	return cellW,h
	end

	local function tableCellAtIndex(view, idx) --idx从0开始

		local betResId                 --设定recordTable排在后面的（即tableView最顶部的）为最近的的历史记录
		if len<=cmd.RECORD_COUNT_MAX then
			betResId=recordTable[1+idx] 
		else 
			betResId=recordTable[len-cmd.RECORD_COUNT_MAX+1+idx]
		end

		--recordTable保存bet结果ID
    	local cell=view:dequeueCell()
    	
		--local posIndex={4,0,1,2,6,7,5,3,10,8,9,11}--第i种动物在记录合集图中的位置序号
		local posIndex={8,4,7,3,6,5,2,0,1,11,10,9}
    	if nil==cell then
    		cell=cc.TableViewCell:create()
    	end

    	if nil==betResId then
    		cell:removeAllChildren()
    	else
    		local sp=cell:getChildByTag(betResId)
    		if nil==sp or tolua.isnull(sp) then
    			cell:removeAllChildren()
    			local sp2 = cc.Sprite:create("aniatlas1.png",cc.rect(posIndex[1+betResId]*50,0,50,50))
	        		:setAnchorPoint(cc.p(0,0))
	        		:setPosition(0,0)
	        		:setTag(betResId)
					:addTo(cell)

	        end
	    end
    	
    	return cell
	end

	if self.recordView then 
		self.recordView:removeSelf()
	end


	local tableView=cc.TableView:create(cc.size(50*10,h))
	tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
	tableView:setPosition(cc.p(6,2))
    tableView:setDelegate()
	--appdf.getNodeByName(self.csbNode,"recordbg"):addChild(tableView)
	if nil==self.historyLight then
		self.historyLight = cc.Sprite:create("historyLight.png")
		self.historyLight:setPosition(cc.p(475+5,26))
		self.historyLight:setTag(20)
		appdf.getNodeByName(self.csbNode,"recordbg"):addChild(self.historyLight)
	end

    tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
    --self.recordView=tableView
	tableView:reloadData()
	
	 --dump(self.turnTableRecords)
	self:updateRecord_z()

    if #recordTable>10 then
    	--local n=math.min(#recordTable,cmd.RECORD_COUNT_MAX)-10
    	--tableView:setContentOffset(cc.p(-n*cellW,0))
    end
end

-- --recordTable
--重写刷新记录
function GameViewLayer:updateRecord_z(  )	
	if self._record~=nil then
		for i=1,#self._record do
			self._record[i]:removeFromParent()
		end
		self._record = {}
	end
	--dump(self.turnTableRecords)
	if self.turnTableRecords ==nil then
		return
	end
	local tmp_posIndex={8,4,7,3,6,5,2,0,1,11,10,9}
	local count  = #self.turnTableRecords
	if count <=0 then
		return
	end
	local c_count = 1

	if count>10 then
		c_count = count-9
	end
	local a = 1
	for i=count,c_count ,-1 do
		local sp2 = cc.Sprite:create("aniatlas1.png",cc.rect(tmp_posIndex[1+self.turnTableRecords[i]]*50,0,50,50))
		:setAnchorPoint(cc.p(0,0))
		:setScale(0.95)
		:setPosition(500+7-50*a,1)
		:setTag(a)
		table.insert( self._record,sp2 )
		appdf.getNodeByName(self.csbNode,"recordbg"):addChild(sp2)	
		a = a+1
	end

end

function GameViewLayer:initZhuanpan()
	for i=1,28 do
		local kind=ZhuanPanAni.zhuanpanPosToKind(i)
		local kindToIndex={8,4,7,3,6,5,2,0,1,11,10,9} --在动物合集图上的位置索引
		local circle=self.anibg[i]
		circle:setPosition(self.aniPos[i])
		local ani=cc.Sprite:create("aniatlas2.png",cc.rect(kindToIndex[kind+1]*110,0,110,80))
		ani:setPosition(circle:getContentSize().width/2,circle:getContentSize().height/2)
		--self:addChild(circle)
		circle:addChild(ani)
	end
end

function GameViewLayer:brightRectBlink(index,showtime,pos)
	self.brightRects[index]:setVisible(true)
			:setPosition(pos)
	self.brightRects[index].m_bVisible=true
	self.brightRects[index]:runAction(cc.Sequence:create(
			cc.Blink:create(showtime,math.ceil(showtime)),
			cc.CallFunc:create(function() self.brightRects[index]:setVisible(false) self.brightRects[index].m_bVisible=false end)))
end

function GameViewLayer:showHuShanHuShan()
	for i = 1,11 do
		--self._blink[i]:setVisible(true)
		self._blink[i]:runAction(cc.Sequence:create(cc.Blink:create(2,2),cc.CallFunc:create(function (  )
			self._blink[i]:setVisible(false)
		end)))
	end
end

function  GameViewLayer:showJieSuanView(resultKind,showtime,shaYuAddMulti)
	--print("resultKind: ",resultKind)
	--print("showtime11112212aaaa: ",showtime)
	showtime = 6 --showtime

	if resultKind<0 or resultKind>11 or showtime<=0 then return end
	if resultKind~=  cmd.JS_YIN_SHA then 
  		ExternalFun.playSoundEffect( "ANIMAL_SOUND_"..(resultKind)..".wav")
  	end

  	local resultKindToBetBtn={2,3,4,5,6,7,8,1,9,-2,-3,9} 
  	local brightRectPos=self.betBtnPoses[ resultKindToBetBtn[resultKind+1] ]

	local jsLayer=display.newLayer(cc.c4b(60,60,67,100))
	self.jsLayer=jsLayer
	jsLayer:addTo(self)
	if resultKind==cmd.JS_TONG_SHA or resultKind==cmd.JS_TONG_PEI then
		local scaleAct=cc.ScaleBy:create(showtime/3,3)
		local rotateAct=cc.RotateBy:create(showtime/6,20)

		local sp=cc.Sprite:create("js"..resultKind..".png")
		:addTo(jsLayer)
		:setPosition(display.center)
		
		if resultKind==cmd.JS_TONG_SHA then
			sp:runAction(cc.Sequence:create(rotateAct,rotateAct:reverse(),scaleAct,scaleAct:reverse() ))
		end
	elseif resultKind==cmd.JS_JIN_SHA or resultKind==cmd.JS_YIN_SHA then
		
		self:brightRectBlink(2,showtime,brightRectPos)

		if resultKind==cmd.JS_JIN_SHA then
			display.newSprite("jssharklight.png")
				:addTo(jsLayer)
				:setPosition(display.center)
				:runAction(cc.RotateBy:create(showtime,360))
		else
			local emitter1 = cc.ParticleSystemQuad:create("Flower1.plist")
			--local emitter2 = cc.ParticleSystemQuad:create("Flower1.plist")
			jsLayer:addChild(emitter1,10)
			--jsLayer:addChild(emitter2,10)
			emitter1:setPosition(yl.WIDTH/2,yl.HEIGHT/2)--:setScale(1.3,1.1)
			--emitter2:setPosition(yl.WIDTH/2+230,yl.HEIGHT/2)--:setScale(1.3,1.1)
		end
		local shark=display.newSprite("js"..resultKind..".png")
			:addTo(jsLayer)
			:setPosition(display.center)
		if resultKind==cmd.JS_YIN_SHA then
			local x,y=shark:getPosition()
			local sz=shark:getContentSize()
			cc.LabelAtlas:create(shaYuAddMulti,"jssharkdigits.png",37,54,string.byte("0"))
				:setAnchorPoint(0.5,0.5)
				:addTo(shark)
				:setPosition(571,64)
			cc.LabelAtlas:create(24+shaYuAddMulti,"jssharkdigits.png",37,54,string.byte("0"))
				:setAnchorPoint(0.5,0.5)
				:addTo(shark)
				:setPosition(746,64)
		end
	else

		self:brightRectBlink(1,showtime,brightRectPos)
		if resultKind<=3 then 
			self:brightRectBlink(3,showtime,self.betBtnPoses[cmd.ID_FEI_QIN])
		else
			self:brightRectBlink(3,showtime,self.betBtnPoses[cmd.ID_ZOU_SHOU])
		end

		local light=display.newSprite("jslight.png")
		light:addTo(jsLayer)
		light:setPosition(display.center)
		light:runAction(cc.RotateBy:create(showtime,360))
		--local kindToIndex={}  --种类在图集中的位置索引，一致，故省略
		local w,h=297,176
		cc.Sprite:create("jsaniatlas.png",cc.rect( 297*resultKind,0,297,176))
			:addTo(jsLayer)
			:setPosition(yl.WIDTH/2,yl.HEIGHT/2+50)

		cc.Sprite:create("jsnum"..resultKind..".png")
			:addTo(jsLayer)
			:setPosition(display.center.x,300)
	end

	jsLayer:runAction(
		cc.Sequence:create(
			cc.DelayTime:create(showtime),
			cc.CallFunc:create(function() 
				--if self.testShowJieSuan==1 then self:showJieSuanView(resultKind+1,showtime,shaYuAddMulti) end--for test temp delete
					jsLayer:removeSelf()
					self:JieSuanJinBiAni(resultKindToBetBtn[resultKind+1])					
					end)
		))
											
	
end


function GameViewLayer:JieSuanJinBiAni( resultKind )
	if self.m_cbGameStatus ~= cmd.GS_GAME_END then
		return 
	end
	--local posIndex={8,4,7,3,6,5,2,0,1,11,10,9}
	--通杀 通赔情况 金币不进行下注区域移动 
	if resultKind > 0 then
		--金币都集合到胜利区域
		self:showGoldToArea(resultKind)
		self.goldLayer:runAction(cc.Sequence:create(cc.DelayTime:create(1.2), cc.CallFunc:create(
            function ()
               self:JieSuanJinBiFly()
            end
        )))
		elseif resultKind == -1 then
			--通赔
			self:JieSuanJinBiFly()
		elseif resultKind == -2 then
			--通杀
			self:JieSuanJinBiFly()
	end
	
	--然后分开飞
end

function GameViewLayer:showGoldToArea( resultKind )
	
	local cellindex = 0
	local outnum = 0
	ExternalFun.playSoundEffect("coinCollide.wav")

	for i=1,2 do
		local goldnum = #self.m_goldList[i]
		if goldnum == nil then
			break
		end
		local cellnum = math.floor(goldnum/7)
		for j=1,goldnum do

			local endpos =self:getRandPos(self.betBtnPoses[resultKind],resultKind)
			
			local goldicon =  self.m_goldList[i][j]
			outnum = outnum + 1
			local moveaction = self:getMoveAction(cc.p(goldicon:getPosition()), endpos, 0, 1)
			goldicon:runAction(cc.Sequence:create(cc.DelayTime:create(cellindex*0.04), moveaction, cc.CallFunc:create(
					function ()
						--goldicon:setVisible(false)
						--goldicon:removeFromParent()
					end
				)))

			if outnum >= cellnum then
				cellindex = cellindex + 1
				outnum = 0
			end		
		end
	end

end

--输赢金币飞动画
function GameViewLayer:JieSuanJinBiFly(  )
	
	local endpos 
	local cellindex = 0
	local outnum = 0
	
	ExternalFun.playSoundEffect("coinCollide.wav")

	for i=1,2 do
		local goldnum = #self.m_goldList[i]
		if goldnum == nil then
			break
		end
		local cellnum = math.floor(goldnum/7)
		
		for j=1,goldnum do

			local goldicon =  self.m_goldList[i][j]
			if i == 1 then
				if  self.WinScore ~=nil then
					if  tonumber(self.WinScore)>0 then
						endpos = cc.p(-162,-227)
					else
						endpos = cc.p(1050,103)
					end
				else
					endpos = cc.p(1050,103)
				end
								
			else
				endpos = cc.p(1050,103)
			end
			local moveaction = self:getMoveAction(cc.p(goldicon:getPosition()), endpos, 0, 1)
			goldicon:runAction(cc.Sequence:create(cc.DelayTime:create(cellindex*0.04), moveaction, cc.CallFunc:create(
					function ()
						goldicon:setVisible(false)
						--pgold:removeFromParent()
						--goldicon:removeFromParent()
					end
				)))

			outnum = outnum + 1
			if outnum >= cellnum then
				cellindex = cellindex + 1
				outnum = 0
			end				
		end
	end

	--self:updateShowJet()

end

function GameViewLayer:enableBetBtns(bEnable) 
	for i=1,11 do
		self.betBtns[i]:setEnabled(bEnable)
	end
end

function GameViewLayer:enableAllBtns(bEnable)
	for i=1,6 do
		self.noteNumBtns[i]:setEnabled(bEnable)
	end
	if nil ~= self.m_JettonLight then
        self.m_JettonLight:setVisible(bEnable)
    end
	for i=1,11 do
		self.betBtns[i]:setEnabled(bEnable)
	end
	self.continueBtn:setEnabled(bEnable)
end

function GameViewLayer:enable_NoteNum_Clear_ContinueBtn(bEnable)
	for i=1,6 do
		self.noteNumBtns[i]:setEnabled(bEnable)
	end
	if nil ~= self.m_JettonLight then
        self.m_JettonLight:setVisible(bEnable)
    end
	self.continueBtn:setEnabled(bEnable)
end

function GameViewLayer:disableNoteNumBtns(startIndex)
	for i=startIndex,6 do
		self.noteNumBtns[i]:setEnabled(false)
	end
	if nil ~= self.m_JettonLight then
		self.m_JettonLight:setVisible(false)
		if startIndex~=1 then
			self.m_JettonLight:setVisible(true)
			--self.m_JettonLight:setPosition(self.noteNumBtns[startIndex-1]:getPosition())			
		end
    end
end

--重写更新续压接口
function GameViewLayer:updateXuya()  --更新按钮状态
	--dump(self._scene.m_lContinueRecord, "self._scene.m_lContinueRecord is =========>	", 6)
	if self.bContinueRecord then --每局续压只能一次
		self.continueBtn:setEnabled(false)
		return
	end
	if self.m_cbGameStatus ~= cmd.GS_PLACE_JETTON  or self:GetJettonRecord() == 0 then 
		self.continueBtn:setEnabled(false)
	else
		self.continueBtn:setEnabled(true)
	end	
end

--重写 更新下注按钮  原来的看不懂太乱了
function GameViewLayer:updateJettonList( score )

	local btjettonscore = 0
    local judgeindex = 0
    if self.m_nJettonSelect == 0 then
        self.m_nJettonSelect = 1
    end
    for i=1,6 do
        --change by zzy
        --btjettonscore = btjettonscore + GameViewLayer.m_BTJettonScore[i]
        btjettonscore =  GameViewLayer.m_BTJettonScore[i]
		local judgescore = btjettonscore
		
		if judgescore > score then
            self.noteNumBtns[i]:setEnabled(false)
        else
            self.noteNumBtns[i]:setEnabled(true)
            judgeindex = i
		end

    end
    if self.m_nJettonSelect > judgeindex then
		self.m_nJettonSelect = judgeindex
        if judgeindex ~= 0 then
            self.m_JettonLight:setPosition(self.noteNumBtns[judgeindex]:getPosition())
        
        end
    end
end

function GameViewLayer:enableNoteNumBtns(endIndex)
	for i=1,endIndex do
		self.noteNumBtns[i]:setEnabled(true)
	end
	-- if nil ~= self.m_JettonLight then
	-- 	self.m_JettonLight:setVisible(true)
	-- 	--self.m_JettonLight:runAction(cc.RepeatForever:create(cc.Blink:create(1.0,1)))
	-- 	self.m_JettonLight:setPosition(self.noteNumBtns[endIndex]:getPosition())
    -- end
end

local leftAligned=0
local centerAligned=1
local rightAligned=2

local storageDigitKind=1
local countDigitKind=2
local totalbetDigitKind=3
local mybetDigitKind=4
local totalscoreDigitKind=5
local assetDigitKind=6
local curscoreDigitKind=7
local digitSpriteConfig={ --数字图片配置  --彩金池靠右对齐，其余居中对齐  --dis表示数字间间距
	{name="storagenum",filepath="storage.png",w=50,h=40 ,dis=5,align=leftAligned}, --彩金池 --pos为中心距离
	{name="countnum",filepath="countnum.png",w=31,h=40,dis=5,align=centerAligned}, --倒计时 --以下pos为最右距离
	{name="totalbetnum",filepath="allbetnum.png",w=12,h=16,dis=0,align=centerAligned},  --总下注
	{name="mybetnum",filepath="mebetnum.png",w=12,h=16,dis=0,align=centerAligned},  --自己下注
	{name="scorenum",filepath="score.png",w=17,h=20,dis=0,align=centerAligned},   --总得分 ,可能为负数
	{name="assetnum",filepath="score.png",w=17,h=20,dis=0,align=centerAligned},	--玩家资产
	{name="curscorenum",filepath="score.png",w=17,h=20,dis=0,align=centerAligned},
}



function GameViewLayer:updateNumberPic(kind,bg,pos,number)--左对齐则pos为左边界位置，中心对齐则pos为中心位置
	dbg_assert(bg)
	dbg_assert(not tolua.isnull(bg))
	--print("updateNumberPic kind: ",kind)

	local numbersNode=bg:getChildByName(digitSpriteConfig[kind].name)
	if numbersNode and not tolua.isnull(numbersNode) then
		numbersNode:removeSelf()
	end

	if nil==number then return end
	
	local function getDigits(number)
		dbg_assert(number)
		local sign=number>=0 and 1 or -1
		if number<0 then number=-number end
		local digits={}
		if number==0 then
			digits[1]=0
			return digits
		end
		while number~=0 do
			local residue=number%10
			number=math.floor(number/10)
			table.insert(digits,residue)
		end
		if sign<0 then table.insert(digits,'-') end  --else table.insert(digits,'+') 
		return digits
	end

	local function newDigitSp(filepath,digit,w,h) --digit单个数字0-9
		if digit=='+' then 
			digit=10 
		elseif digit=='-' then 
			digit=11 
		end
		return cc.Sprite:create( filepath,cc.rect(w*digit,0,w,h) )
	end

	local digits=getDigits(number) --将number的每个位上数字存入table
	dbg_assert(#digits>0)

	local dsc=digitSpriteConfig[kind]
	local node=cc.Node:create() --对于一个size为0的node，setAnchorPoint(,)会对其子节点的显示有影响吗?
	node:addTo(bg):setName(digitSpriteConfig[kind].name)
	
	--print("number: ",number)
	for i=1,#digits do
		--print(i,digits[i])
		local sp= newDigitSp(dsc.filepath,digits[i],dsc.w,dsc.h)
		--print("digits[i]: ",digits[i])
		--print("number: ",number)
		sp:addTo(node)
		sp:setAnchorPoint(0,0)
		sp:setPosition( (dsc.dis+dsc.w)*(#digits-i),0 )
	end

	local totalWidth= (#digits) * (dsc.dis+dsc.w)
	if dsc.align==centerAligned then
		node:setPosition(pos.x-totalWidth/2,pos.y)
	elseif dsc.align==rightAligned then
		node:setPosition( pos.x-totalWidth,pos.y)
	elseif dsc.align==leftAligned then
		node:setPosition(pos)
	end
end



function GameViewLayer:updateTotalBets(tabBets)
	--print("updateTotalBets")
	for i=1,cmd.AREA_COUNT-1 do
		--print(i..":  "..(tabBets[i] or 0))
		if tabBets[i]==0 then
			self:updateTotalBet(i,nil)
		else
			self:updateTotalBet(i,tabBets[i],tabBets[i])
		end
	end
end

function GameViewLayer:updateMyBets(tabBets)
	for i=1,cmd.AREA_COUNT-1 do
		if tabBets[i]==0 then
			self:updateMyBet(i,nil)
		else
			self:updateMyBet(i,tabBets[i],tabBets[i]) -- 续投更新 我下注和总下注
		end
	end
end

function GameViewLayer:updateTotalBet(kind,num,score)
	--print("kind: ",kind)
	local bg=self.betBtns[kind]
	local sz=bg:getContentSize()
	local x=sz.width/2
	-- if kind-1==cmd.AREA_FEI_QIN or kind-1==cmd.AREA_ZOU_SHOU then
	-- 	x=x-50
	-- end
	--self.lab_alljet = cc
	if nil~=score  then 
		self.alljet = self.alljet+score
		self.lab_alljet:setString(ExternalFun.numberThousands(tonumber(self.alljet)))
	end
	
	self:updateNumberPic( totalbetDigitKind,bg,cc.p(x,109),num )
end

function GameViewLayer:updateMyBet(kind,num,score)
	local bg=self.betBtns[kind]
	local sz=bg:getContentSize()
	local x=sz.width/2
	-- if kind-1==cmd.AREA_FEI_QIN or kind-1==cmd.AREA_ZOU_SHOU then
	-- 	x=x-50
	-- end
	if nil~=score then
		self.myjet = self.myjet+score
		self.lab_myjet:setString(ExternalFun.numberThousands(tonumber(self.myjet)))

	end
	
	self:updateNumberPic( mybetDigitKind,bg,cc.p(x,4),num )
end
function GameViewLayer:updateShowJet()
	self.myjet =0
	self.lab_myjet:setString("")
	self.alljet =0
	self.lab_alljet:setString("")
	self:resetGame()
end

function GameViewLayer:playBackgroundMusic()
	if self.m_cbGameStatus==cmd.GS_GAME_END then
		 ExternalFun.playBackgroudAudio( "GAME_START.wav" )
	else
		 ExternalFun.playBackgroudAudio("GAME_FREE.wav")
	end
end

function GameViewLayer:updateCurrentScore(score)
	--self:updateNumberPic( curscoreDigitKind,appdf.getNodeByName(self.csbNode,"curscorebg"),cc.p(185,17),score )
	self.lab_curscore:setString(ExternalFun.numberThousands(tonumber(score)))
end

function GameViewLayer:updateTotalScore(score)
	--self:updateNumberPic( totalscoreDigitKind,appdf.getNodeByName(self.csbNode,"totalscore"),cc.p(185,17),score )
	self.lab_totalscore:setString(ExternalFun.numberThousands(tonumber(score)))
end

function GameViewLayer:updateAsset(assetNum)
	--self:updateNumberPic( assetDigitKind,appdf.getNodeByName(self.csbNode,"asset"),cc.p(185,17),assetNum )
	self.lab_userscore:setString(ExternalFun.numberThousands(tonumber(assetNum)))
end

function GameViewLayer:updateCountDown(clockTime)
	--self:updateNumberPic( countDigitKind,appdf.getNodeByName(self.csbNode,"countbg"),cc.p(230,10),clockTime)
	self.timeClock:setString(string.format("%02d",tonumber(clockTime)))
end

function GameViewLayer:updateStorage(num) --彩金池
	--self:updateNumberPic( storageDigitKind,appdf.getNodeByName(self.csbNode,"storagebg"),cc.p(100,10),num)
    self.storageLabelAtlas:setString(num)
end

function GameViewLayer:enableBtns(bEnable)
	for i=1,6 do
		self.noteNumBtns[i]:setEnabled(bEnable)
	end
	self.continueBtn:setEnabled(bEnable)
end

function GameViewLayer:SetGameStatus(gameStatus) --设置显示得分
	self.m_cbGameStatus=gameStatus
end

function GameViewLayer:updateTimeTextImg() --休闲时间、下注时间、开奖时间 图片

	if self.m_cbGameStatus==cmd.GAME_STATUS_FREE then
		self.timeTextImg:loadTexture("xiuxianshijian.png",0)   --LOCAL = 0,PLIST = 1
	elseif self.m_cbGameStatus==cmd.GS_PLACE_JETTON then
		self.timeTextImg:loadTexture("xiazhushijian.png",0)
	elseif self.m_cbGameStatus==cmd.GS_GAME_END	then
		self.timeTextImg:loadTexture("kaijiangshijian.png",0)
	else 
		dbg_assert(false)
	end
end

function  GameViewLayer:removeFirstOpeningAni( )
	if self.firstOpeningAni and not tolua.isnull(self.firstOpeningAni) then
		self.firstOpeningAni:removeSelf()
		self.firstOpeningAni=nil
	end
end

local function printn(n,...)
	local i=0
	while i<n do
		i=i+1
		print(...)
	end
end

function GameViewLayer:OnUpdataClockView(clockViewChair,clockTime)

	local t=os.time()

	self.cbTimeLive=clockTime
	self:updateCountDown(clockTime)
	if self.m_cbGameStatus==cmd.GS_PLACE_JETTON and clockTime<5 then
		ExternalFun.playSoundEffect( "TIME_WARIMG.wav")
	end

	if (self.m_cbGameStatus~=cmd.GS_GAME_END or (clockTime>0 and clockTime<=3)) then
		if self.jsLayer and not tolua.isnull(self.jsLayer) then
			if self.testShowJieSuan~=1 then self.jsLayer:removeSelf() end
		end

		if self.zhuanPanAni and not tolua.isnull(self.zhuanPanAni) then
			self.zhuanPanAni:removeSelf()
			--printn(100000,"clockTime: ",clockTime,"  m_cbGameStatus: ",self.m_cbGameStatus)
		end
		for i=1,#self.brightRects do
			if true==self.brightRects[i].m_bVisible then
				--printn(100,i.." clockTime: ",clockTime,"  m_cbGameStatus: ",self.m_cbGameStatus)
				self.brightRects[i]:stopAllActions()
				self.brightRects[i]:setVisible(false)
				self.brightRects[i].m_bVisible=false
			end
		end
	end

	local dt
	dt=self.lastupdataT==nil and 0 or t-self.lastupdataT
	if dt<=1 
	  or (self._lastStatus==cmd.GS_PLACE_JETTON and self.m_cbGameStatus==cmd.GS_PLACE_JETTON and dt<self._lastTimeLive) 
	  or (self._lastStatus==cmd.GS_GAME_END and self.m_cbGameStatus==cmd.GS_GAME_END and dt<self._lastTimeLive)
	then
		--donothing
	else
		--print("dt: ",dt)
		self._scene:clearBets()
	end

	if self._lastStatus==cmd.GS_GAME_END  and dt>=self._lastTimeLive then --and self._lastTimeLive>0
		self:updateCurrentScore(0)
	end

	if self.bTurnTwoTime==1 and self._lastStatus==cmd.GS_GAME_END and self.m_cbGameStatus==cmd.GS_GAME_END and self._lastTimeLive-dt>3 and self._lastTimeLive-dt<13 then
		self.bTurnTwoTime=0
		self.showAnims(self,2)
	end

	if clockViewChair == self._scene:SwitchViewChairID(self._scene:GetMeChairID())  then
		if self.m_cbGameStatus == cmd.GS_PLACE_JETTON then
			self.m_bPlayGoldFlyIn = true
			self.m_fJettonTime = math.min(0.1, clockTime)
		end
	end

	self.lastupdataT=t
	self._lastStatus=self.m_cbGameStatus
	self._lastTimeLive=clockTime
end

function GameViewLayer:GameOver( nTurnTableTarget, curGameScore,cumulativeScore ,shaYuAddMulti) --转盘结束后更新记录 self.tabRecords
 	self.nTurnTableTarget=nTurnTableTarget
 	self.resultKind1= ZhuanPanAni.zhuanpanPosToKind(nTurnTableTarget[1])
	 self.shaYuAddMulti=shaYuAddMulti
	 self.WinScore = curGameScore
	 --print("WinScore :"..self.WinScore)
 --bTurnTwoTime为1时，开奖时间为30秒	                   
 	local totalSec=20-3
	self.bTurnTwoTime=0
	if nTurnTableTarget[2]>=1 and nTurnTableTarget[2]<=28  then self.bTurnTwoTime=1 end
	local deltaT=2 --连续两次开奖动画间隔时间
	local dur=8.2 --转盘时间
	local durations={dur,0}
	if self.bTurnTwoTime==1 then
		totalSec=(30-2-deltaT)/2  --=13
		durations[1]=dur-2
		durations[2]=dur-2
	end

	local function showAnims(self,i)
		if self.m_cbGameStatus~=cmd.GS_GAME_END then return end
		self:AddTurnTableRecord(ZhuanPanAni.zhuanpanPosToKind(nTurnTableTarget[i]))
		local zhuanPanAni=ZhuanPanAni:create(self,1,nTurnTableTarget[i],durations[i],totalSec)
		self.zhuanPanAni=zhuanPanAni
		local resultKind=ZhuanPanAni.zhuanpanPosToKind(nTurnTableTarget[i])
		local function callback(resttime)
			if self.m_cbGameStatus~=cmd.GS_GAME_END then return end
			self:showJieSuanView(resultKind,resttime,shaYuAddMulti)
			self:updateShowTurnTableRecord()
			self:updateCurrentScore(curGameScore)
			self:updateTotalScore(cumulativeScore)
			self:updateAsset(GlobalUserItem.lUserScore+curGameScore)
			--self:updateShowJet()	
		end
		zhuanPanAni:ZhuanPan(callback)
	end
	
	showAnims(self,1)
	
	-- if bTurnTwoTime==1 then  --放到updataClockView了，后台切换
	-- 	self:runAction(
	-- 		cc.Sequence:create(cc.DelayTime:create(totalSec+deltaT),
	-- 			cc.CallFunc:create(function() showAnims(self,2) end))
	-- 		)
	-- end
	self.showAnims=showAnims
end


function GameViewLayer:onExit()
	for i=8,11 do
		cc.Director:getInstance():getTextureCache():removeTextureForKey("js"..i..".png")
	end
	
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("client/res/Jetton/Chouma.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("client/res/Jetton/Chouma.png")
	
	cc.Director:getInstance():getTextureCache():removeTextureForKey("background.png")
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()

	--停止音效 ios
	ccexp.AudioEngine:stopAll()   

    ExternalFun.playPlazzBackgroudAudio()

	self._laba:closeTime()
	
end

--银行操作成功
function GameViewLayer:onBankSuccess( )
	if self._bankLayer and not tolua.isnull(self._bankLayer) then
		self._bankLayer:onBankSuccess()
	end
end

function GameViewLayer:onBankFailure( )
	if self._bankLayer and not tolua.isnull(self._bankLayer) then
		self._bankLayer:onBankFailure()
	end
end

function GameViewLayer:onGetBankInfo(bankinfo)
	if self._bankLayer and not tolua.isnull(self._bankLayer) then
		self._bankLayer:onGetBankInfo(bankinfo)
	end
end

function GameViewLayer:OnUpdateUser(viewId, userItem, bLeave)
    local myViewId=self._scene:SwitchViewChairID(self._scene:GetMeChairID()) 
    if viewId==myViewId then
    	return 
    end
	if bLeave then
		self.m_tabPlayerList[viewId]=nil
		--print(viewId.." leave")
	else
		if userItem then
			--print("viewId", viewId)
			self.m_tabPlayerList[viewId]=userItem
		end
	end
end

function GameViewLayer:resetGame(  )
	--self.goldLayer:removeAllChildren()
	self.goldLayer:removeAllChildren()
	self.m_goldList = {{},{}}
	self.m_bPlayGoldFlyIn = true
	if self:GetJettonRecord() == 0 then
		self.bContinueRecord = true
	else
		self.bContinueRecord = false
	end
	
end
--获取下注显示金币个数
function GameViewLayer:getGoldNum(lscore)
    local goldnum = 1
    for i=1,6 do
        if lscore >= GameViewLayer.m_BTJettonScore[i] then
            goldnum = i
        end
    end
    return GameViewLayer.m_JettonGoldBaseNum[goldnum]
end

--获取移动动画
--inorout,0表示加速飞出,1表示加速飞入
--isreverse,0表示不反转,1表示反转
function GameViewLayer:getMoveAction(beginpos, endpos, inorout, isreverse)
    local offsety = (endpos.y - beginpos.y)*0.7
    local controlpos = cc.p(beginpos.x, beginpos.y+offsety)
    if isreverse == 1 then
        offsety = (beginpos.y - endpos.y)*0.7
        controlpos = cc.p(endpos.x, endpos.y+offsety)
    end
    local bezier = {
        controlpos,
        endpos,
        endpos
    }
    local beaction = cc.BezierTo:create(0.3, bezier)
    if inorout == 0 then
        return cc.EaseOut:create(beaction, 1)
    else
        return cc.EaseIn:create(beaction, 1)
    end
end

--获取随机显示位置
function GameViewLayer:getRandPos(nodeArea, index)
    local beginpos = cc.p(nodeArea.x-65, nodeArea.y-63)

    local offsetx = math.random()
    local offsety = math.random()

	if index == 9 then
		beginpos = cc.p(nodeArea.x-130, nodeArea.y-60)
		return cc.p(9+beginpos.x + offsetx*230, 58+beginpos.y + offsety*38)
	end
    return cc.p(9+beginpos.x + offsetx*100, 58+beginpos.y + offsety*38)
end


function GameViewLayer:showUserJetton(pPlaceJetton, isContinue)
  
	self.m_fJettonTime = 0.1
    local goldnum = self:getGoldNum(pPlaceJetton.lJettonScore)
    local beginpos = cc.p(1050,103)
    local offsettime = math.min(self.m_fJettonTime, 1)

	if isContinue == true then
		goldnum  = math.random(1,6)
	end
	--print("placeuserID: " .. pPlaceJetton.wPlaceUser)
	if pPlaceJetton.wChairID==self._scene:GetMeChairID() then
		beginpos = cc.p(-162,-227) 
		ExternalFun.playSoundEffect("ADD_GOLD.wav")		
    else    
		offsettime = math.min(self.m_fJettonTime, 3)  
		if self.m_bPlayGoldFlyIn == true then
			ExternalFun.playSoundEffect("ADD_GOLD.wav")
			self.m_bPlayGoldFlyIn = false
		end
	end
	
    for i=1,goldnum do

            local b  = math.random(1,6)
			local goldnum1 = self.m_pJettonNumber[b].k
			local pgold = cc.Sprite:createWithSpriteFrameName(string.format("ChouMa_%d.png",goldnum1))
            --local pgold = cc.Sprite:create()
            --pgold:setTexture(string.format("client/res/Jetton/ChouMa_%d.png",goldnum1))
			pgold:setPosition(beginpos)
			pgold:setScale(0.7)
			local touzhubg = self.csbNode:getChildByName("Touzhubg")
			--touzhubg:addChild(pgold)
			self.goldLayer:addChild(pgold)
			
			
			if pPlaceJetton.wChairID==self._scene:GetMeChairID() then
				table.insert(self.m_goldList[1], pgold)
			else    
				table.insert(self.m_goldList[2], pgold)
			end
			
            if i == 1 then
                local moveaction = self:getMoveAction(beginpos, self:getRandPos(self.betBtnPoses[pPlaceJetton.cbJettonArea],pPlaceJetton.cbJettonArea), 0, 0)
                pgold:runAction(moveaction)
            else
                local randnum = math.random()*offsettime
                pgold:setVisible(false)
                pgold:runAction(cc.Sequence:create(cc.DelayTime:create(randnum), cc.CallFunc:create(
                        function ()
                            local moveaction = self:getMoveAction(beginpos, self:getRandPos(self.betBtnPoses[pPlaceJetton.cbJettonArea],pPlaceJetton.cbJettonArea), 0, 0)
                            pgold:setVisible(true)
                            pgold:runAction(moveaction)
                        end
                    )))
			end
			
			

    end
    
    
end

--续压
function GameViewLayer:GetJettonRecord()
	local record = 0
	--dump(self._scene.m_lContinueRecord)
	for i=1,#self._scene.m_lContinueRecord do
		record = record + self._scene.m_lContinueRecord[i]
	end
	return record
end

return GameViewLayer
