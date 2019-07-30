

--加注 滑条界面

local SliderLayer = class("SliderLayer",function (scene)

    local node = cc.Node:create()

    return node

end)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

local cmd = appdf.req(appdf.GAME_SRC.."yule.dzshowhand.src.models.CMD_Game")

function SliderLayer:ctor(scene)

    self._scene = scene

    --筹码的数量
    self._chipCount = 34

    --筹码之间的间隔
    self.chipInterval = cc.p(0,10)

    --筹码开始摆放位置
    self.chipStartPos = cc.p(0,0)

    --chip
    self.ChipSp = {}

    --筹码的位置
    self.ChipSpPos = {}

    self._percent = 0

    --最下下注
    self._MaxScore = m_lTurnMaxScore

    --加载csb
    local csbNode = ExternalFun.loadCSB(cmd.RES.."game/AddSocreSliderNode.csb",self)

    self._csbNode = csbNode


    --slider容器
    self.layout_slider = csbNode:getChildByName("panel_slider")
    
    :setLocalZOrder(5)

    --分数背景
    self.m_tScoreBg = self.layout_slider:getChildByName("img_score_bg")

    --加注按钮
    self.btn_addScore = self.m_tScoreBg:getChildByName("btn_add")

    :addTouchEventListener(function (ref,eventType )

        if eventType == ccui.TouchEventType.ended then

            self:setPercent(self._percent+0.1)

        end
    end)

    --减注按钮
    self.btn_reduceScore = self.m_tScoreBg:getChildByName("btn_reduce")

    :addTouchEventListener(function (ref,eventType )

        if eventType == ccui.TouchEventType.ended then

            self:setPercent(self._percent-0.1)

        end
    end)


    --加注分数
    self.txt_score = self.m_tScoreBg:getChildByName("text_add_score")

    :setString("0")


    local chip1 = self.layout_slider:getChildByName("img_chip_1")

    :setVisible(false)

    self.chipStartPos = cc.p(chip1:getPosition())


    local chip2 = self.layout_slider:getChildByName("img_chip_2")

    :setVisible(false)

    self.chipInterval = cc.p(chip2:getPositionX()-chip1:getPositionX(),chip2:getPositionY()-chip1:getPositionY())

    --添加监听

    self.layout_slider:addTouchEventListener(handler (self,self.onTouch))

    self.layoutSize = self.layout_slider:getContentSize()

    for i=1,self._chipCount do
        
        local chipSp = self.layout_slider:getChildByName("img_chip_"..i)

        self.ChipSp[i] = chipSp

        chipSp:setVisible(false)

        self.ChipSpPos[i] = cc.p(chipSp:getPosition())

    end

    -- --添加spine动画
    -- local spine = self._scene:playSpine(4,csbNode)

    -- spine:setPosition(cc.p(20,695/2-120))

    -- spine:setAnimation(0,"animation",true)

    -- --allin

    -- self._spineAllin = self._scene:playSpine(1,csbNode)

    -- self._spineAllin:setPosition(cc.p(27,300))

    -- self._spineAllin:setVisible(false)
    
    

    --加注按钮

    local btnAdd = csbNode:getChildByName("Btn_Add")

    :addTouchEventListener(function (ref,eventType )

        if eventType == ccui.TouchEventType.ended then

            local addScore = tonumber(self.txt_score:getString())

           self._scene:getParent():OnOKScore(addScore)

        end
    end)


    
end


function SliderLayer:onTouch(target,event)

    if event == ccui.TouchEventType.began then

        local pos =  target:getTouchBeganPosition()

        self:updatePercentByTouchPos(pos)
        
    elseif event == ccui.TouchEventType.moved then

        local pos = target:getTouchMovePosition()

        self:updatePercentByTouchPos(pos)

    elseif event == ccui.TouchEventType.ended then

        local pos = target:getTouchEndPosition()

        self:updatePercentByTouchPos(pos)

    end
    
end

function SliderLayer:updatePercentByTouchPos(touchWorldPos)

   local pos = self.layout_slider:convertToNodeSpace(touchWorldPos)

   print("pos:x "..pos.x.."  pos:y  "..pos.y)

   local percent = 0

   local percent = pos.y/self.layoutSize.height
   
   self:setPercent(percent)
end

function SliderLayer:setPercent(percent)

    if percent >1 then

        percent = 1
    
    elseif percent < 0 then
        
        percent = 0
    
    end

    local count = 0

    self._percent = percent

    count = math.floor(34*percent)-1

    if count < 1 then

        count = 1

    end

    if count > 34 then

        count = 34

    end

    for k,v in ipairs(self.ChipSp) do

        v:setVisible(false)

        v:stopAllActions()

    end

    for i=1,count do

        local chipSp = self.ChipSp[i]

        :setVisible(true)

        :setOpacity(255)

        :setRotation(0)
        
        :setPosition(self.ChipSpPos[i])

    end
   --重新设置位置
   local pos = cc.p(self.ChipSp[count]:getPosition())

   --设置分数
   self.txt_score:setString(""..math.floor(self._MaxScore*percent))

   self.m_tScoreBg:setPositionY(pos.y)

   self:doLastJettonAction(count+1)

--    if percent == 1 then

--      self._spineAllin:setVisible(true)

--      self._spineAllin:setAnimation(0,"idle",true)

--    else

--     self._spineAllin:stopAllActions()

--     self._spineAllin:setVisible(false)
    
   --end
    
end

--初始化最小分数
function SliderLayer:resetMin(minScore,maxScore)

    self._MaxScore = maxScore

    local percent = minScore/maxScore

    self:setPercent(percent)
    
end

function SliderLayer:doLastJettonAction(num)
	
	if num > 34 then
		return
	end
	
    local item = self.ChipSp[num]

	if item ~= nil then
		item:stopAllActions()
		item:setPositionY(self.ChipSpPos[num].y + 50)
		item:setOpacity(0)
		item:setVisible(true)
		--先倾斜
		item:setRotation(60)
		local fadeto = cc.FadeTo:create(0.1,255)
		local mo = cc.MoveTo:create(0.1,cc.p(self.ChipSpPos[num].x,self.ChipSpPos[num].y + 10))
		local span = cc.Spawn:create(fadeto,mo)

		--第二阶段
		local ro2 = cc.RotateTo:create(0.05, -20)
		local mo2 = cc.MoveTo:create(0.05,cc.p(self.ChipSpPos[num].x,self.ChipSpPos[num].y+ 20))


		--第三阶段
		local mo3 = cc.MoveTo:create(0.05,cc.p(self.ChipSpPos[num].x,self.ChipSpPos[num].y))

		--第四阶段
		local ro4 = cc.RotateTo:create(0.05, 10)
		local mo4 = cc.MoveTo:create(0.05,cc.p(self.ChipSpPos[num].x,self.ChipSpPos[num].y+ 5))
		
		--第五个阶段
		local ro5 = cc.RotateTo:create(0.05, 0)
		local mo5 = cc.MoveTo:create(0.05,cc.p(self.ChipSpPos[num].x,self.ChipSpPos[num].y))
		local span2 = cc.Spawn:create(ro5,mo5)

		item:runAction(cc.Sequence:create(span,ro2,mo2,mo3,ro4,mo4,span2,nil))
	end
	
end

return SliderLayer
