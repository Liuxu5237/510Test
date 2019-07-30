--
-- Author: zhouweixiang
-- Date: 2016-11-25 10:10:42
--
local RoomListLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.RoomListLayer")

local GameRoomListLayer = class("GameRoomListLayer", RoomListLayer)
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local GameRuleLayer = appdf.req(appdf.GAME_SRC.."yule.oxbattle2.src.views.layer.GameRuleLayer")
--游戏房间列表

function GameRoomListLayer:ctor(scene, frameEngine, isQuickStart)
    self._searchPath = cc.FileUtils:getInstance():getSearchPaths()
	GameRoomListLayer.super.ctor(self, scene, isQuickStart)
	self._frameEngine = frameEngine
end

--添加搜索路径
function GameRoomListLayer:addSearchPath()
    local searchPath = device.writablePath .. "game/yule/oxbattle2/res/"
    cc.FileUtils:getInstance():addSearchPath(searchPath)
end

--初始化顶部UI
function GameRoomListLayer:initBg()
	local bg = display.newSprite("roomlist/Brnn_Room_bg1.jpg")
    :setPosition(display.cx, display.cy)
    :addTo(self)
    --左边人物动画
    local SensualOfficer =  ExternalFun.addEffectNode(self, "roomlist/", "brnn_js6", cc.p(220,-820))
    SensualOfficer:setOpacity(20)
    local spwan = cc.Spawn:create(cc.MoveTo:create(0.4, cc.p(270,-820)), cc.FadeTo:create(0.4, 255))
    local sequence = cc.Sequence:create(cc.DelayTime:create(0.2), spwan)
    SensualOfficer:runAction(sequence)

end

function GameRoomListLayer:onExit()
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("game_res.plist")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("game_res.png")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("roomlist/brnn_js6/brnn_js6.png")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("roomlist/brnntiyanshiwan/brnntiyanshiwan.png")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("roomlist/brnnputongchang/brnnputongchang.png")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("roomlist/brnngaojichang/brnngaojichang.png")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("roomlist/brnnkuaisukaishi/brnnkuaisukaishi.png")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("roomlist/GoldBean/GoldBean.png")
    print("GameRoomListLayer onExit")
    cc.FileUtils:getInstance():setSearchPaths(self._searchPath)
    dump(self:getOccupiedMemory(), "内存大小", 10)
end

function GameRoomListLayer:getOccupiedMemory()
    local neicun = cc.Director:getInstance():getTextureCache():getCachedTextureInfo()
    local a,b = string.find(neicun, "MB")
    a = a - 7
    local nc = string.sub(neicun, a, b)
    local c = string.sub(nc, 1,1)
    c = tonumber(c)
    if type(c) ~= "number" then nc = string.sub(neicun, a+1, b) end
    return nc
end

--初始化顶部UI
function GameRoomListLayer:initTopUI(enterGame)
    dump(GlobalUserItem.nCurGameKind)

    local bottomTopZorder = 10
    self.bottomTopLayer = display.newLayer()
    :setPosition(0, 0)
    :addTo(self, bottomTopZorder)

    local logoPath = "roomlist/logo_"..GlobalUserItem.nCurGameKind..".png"
    --标题
    local gameLogo = display.newSprite(logoPath)
    if nil ~= gameLogo then
        local logoSize = gameLogo:getContentSize()
        local offsetX = logoSize.width > 300 and 10 or 30
        gameLogo:addTo(self.bottomTopLayer)
        :setPosition(display.width - logoSize.width / 2 - offsetX, display.height - logoSize.height / 2 - 10 + 180)
    end

    --返回按钮
    local backBtn = ccui.Button:create('roomlist/Brnn_Room_fh1btn.png', '', '', 0)
	:setPosition(65, display.height - 65 + 180)
	:addTo(self.bottomTopLayer,1)
	:addTouchEventListener(function(ref, tType)
        if tType == ccui.TouchEventType.ended then
            ExternalFun.playCloseButtonClickEffect()
            self:removeFromParent()
        end
    end)
    --帮助按钮
    local helpBtn = ccui.Button:create('roomlist/Brnn_room_help.png', '', '', 0)
	:setPosition(65 + 112 + 10, display.height - 65 + 180)
	:addTo(self.bottomTopLayer,1)
	:addTouchEventListener(function(ref, tType)
        if tType == ccui.TouchEventType.ended then
            ExternalFun.playCloseButtonClickEffect()
            local rule = GameRuleLayer:create()
        	rule:addTo(self, 100)
        end
    end)

    local spwan = cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(0,-180)), cc.FadeTo:create(0.2, 255))
    local sequence = cc.Sequence:create(cc.DelayTime:create(0.4), spwan)
    self.bottomTopLayer:runAction(sequence)
end

--初始化房间按钮
function GameRoomListLayer:initRoomButton()

    local roomCount = #self.m_tabRoomListInfo
    dump(self.m_tabRoomListInfo, nil, 100)

    --X方向上的两边间距
    local spaceX = 0
    --列数
    local colNum = 1
    --行数
    local rowNum = 3
    --x方向上的间隔
    local intervalX = 40	
    --y方向上的间隔
    local intervalY = 180

    colNum = math.ceil(roomCount/rowNum)
    -- local enterGame = self._scene:getEnterGameInfo()
    local spinename = {"brnntiyanshiwan", "brnnputongchang", "brnngaojichang"}
    for i = 1, roomCount do
        local iteminfo = self.m_tabRoomListInfo[i]
        local wLv = (iteminfo == nil and 0 or iteminfo.wServerLevel)
        wLv = (wLv ~= 0) and wLv or 1
        local colIdx = (i - 1)%rowNum + 1
        local rowIdx = math.ceil(i/colNum)
        local curColNum = roomCount - rowNum*(rowIdx - 1)
        curColNum = curColNum > rowNum and rowNum or curColNum

        --按钮的位置
        local posX = display.cx + 180 - (curColNum - 1)*(intervalX/2) + (intervalX)*(colIdx - 1)
        local posY = display.cy + 180 + (colNum - 1)*(intervalY/2) - (intervalY)*(rowIdx - 1)

		local roomBtn =  ExternalFun.addEffectNodeButton(self, "roomlist/", spinename[wLv], cc.size(380,135), cc.p(posX, posY), cc.p(190, 67.5))

		local btnNormal = roomBtn:getRendererNormal()
        local roomBtnSize = roomBtn:getContentSize()

        --准入金额
        local enterScore = iteminfo.lEnterScore or 0
        if iteminfo.wServerType == 8 then 
            --体验场
            enterScore = 0
        end

        if enterScore <=0 then
            local minGold = display.newSprite('roomlist/Hlwz_txt_free.png')
            :setPosition(roomBtnSize.width/2 + 30, 45)
		    :addTo(roomBtn)
        elseif enterScore >= 1000 and enterScore < 100000 then
            local fontCount = string.len(enterScore)

            local enterStr = display.newSprite('roomlist/Hlwz_txt_zhunruchang.png')
		    :addTo(roomBtn)
            :setAnchorPoint(cc.p(0,0.5))
            local enterStrSize = enterStr:getContentSize()

            local goldNum = cc.LabelAtlas:_create(enterScore, "roomlist/shuzi.png", 20, 28, string.byte("/")) 
		    :setAnchorPoint(cc.p(0,0.5))
		    :addTo(roomBtn,1)

            local goldShadow = cc.LabelAtlas:_create(enterScore, "roomlist/shuzi.png", 20, 28, string.byte("/")) 
		    :setAnchorPoint(cc.p(0,0.5))
            :setOpacity(255*0.2)
            :setColor(cc.c3b(0,0,0))
		    :addTo(roomBtn)

            local wanStr = display.newSprite('roomlist/Hlwz_txt_wanzi.png')
            :hide()
		    :addTo(roomBtn)
            :setAnchorPoint(cc.p(0,0.5))
            local wanStrSize = wanStr:getContentSize()

            local totalWidth = enterStrSize.width + fontCount*20 + wanStrSize.width

            enterStr:setPosition(roomBtnSize.width/2 + 20 - totalWidth/2, 45)
            goldNum:setPosition(roomBtnSize.width/2 + 20 - totalWidth/2 + enterStrSize.width, 48)
            goldShadow:setPosition(roomBtnSize.width/2 + 20 - totalWidth/2 + enterStrSize.width - 3, 45)
            wanStr:setPosition(roomBtnSize.width/2 + 20 - totalWidth/2 + enterStrSize.width + fontCount*20, 45)
        else
            local fontCount = string.len(enterScore)

            local enterStr = display.newSprite('roomlist/Hlwz_txt_zhunruchang.png')
		    :addTo(roomBtn)
            :setAnchorPoint(cc.p(0,0.5))
            local enterStrSize = enterStr:getContentSize()

            local goldNum = cc.LabelAtlas:_create(enterScore, "roomlist/shuzi.png", 20, 28, string.byte("/")) 
		    :setAnchorPoint(cc.p(0,0.5))
		    :addTo(roomBtn,1)

            local goldShadow = cc.LabelAtlas:_create(enterScore, "roomlist/shuzi.png", 20, 28, string.byte("/")) 
		    :setAnchorPoint(cc.p(0,0.5))
            :setOpacity(255*0.3)
            :setColor(cc.c3b(0,0,0))
		    :addTo(roomBtn)

            local totalWidth = enterStrSize.width + fontCount*20
            enterStr:setPosition(roomBtnSize.width/2 - 5 - totalWidth/2, 45)
            goldNum:setPosition(roomBtnSize.width/2 - 5 - totalWidth/2 + enterStrSize.width, 48)
            goldShadow:setPosition(roomBtnSize.width/2 - 5 - totalWidth/2 + enterStrSize.width - 3, 48)
        end

        --状态
        local state = 1
        local stateFile = string.format('roomlist/hlwz_room_state_%s.png', state)
        local roomState = display.newSprite(stateFile)
        :setPosition(roomBtnSize.width-60, 45)
		:addTo(roomBtn)

        --按钮点击事件
        roomBtn:addTouchEventListener(function(ref, type)
        	if type == ccui.TouchEventType.began then
        		ref:setScale(1.03)
        	end
        	if type == ccui.TouchEventType.canceled then
        		ref:setScale(1.0)
        	end
            if type == ccui.TouchEventType.ended then
           		ref:setScale(1.0)
                ExternalFun.playCommonButtonClickEffect()
                if not iteminfo then
		            return
	            end
	            GlobalUserItem.nCurRoomIndex = iteminfo._nRoomIndex
	            GlobalUserItem.bPrivateRoom = (iteminfo.wServerType == yl.GAME_GENRE_PERSONAL)
	            self:getParent():onStartGame()
                return true
            end
        end)
	    
    end
end

--初始化底部UI
function GameRoomListLayer:initBottomUI()
    local bottomZorder = 10
    self.bottomLayer = display.newLayer()
    :setPosition(0, -180)
    :addTo(self, bottomZorder)

    --底背景
    local bottomBg = display.newSprite('roomlist/Hlwz_pic.png')
    :setAnchorPoint(0.5, 0)
    :setPosition(display.cx-163, 0)
    :addTo(self.bottomLayer)
    
    --快速开始按钮
    local function quickCallBack(ref, type)
    	if type == ccui.TouchEventType.began then
    		ref:setScale(1.03)
    	end
    	if type == ccui.TouchEventType.canceled then
    		ref:setScale(1.0)
    	end
        if type == ccui.TouchEventType.ended then
       		ref:setScale(1.0)
            ExternalFun.playCommonButtonClickEffect()
            print('快速开始')
        	self:getParent():quickStartNew()
            return true
        end
    end
    local fastButton = ExternalFun.addEffectNodeButton(self.bottomLayer, 'roomlist/', 'brnnkuaisukaishi', cc.size(345, 122), cc.p(display.width - 183, 41), cc.p(172.5, 61))
    :addTouchEventListener(quickCallBack)

    --头像
    local headBg = display.newSprite('roomlist/Hall_ZJM_Head_Bg_Boy.png')
    :setPosition(100 - 26, 100 - 50)
    :addTo(self.bottomLayer)
    local headBgSize = headBg:getContentSize()
    local head = ExternalFun.getClipHeadImage(GlobalUserItem, 'roomlist/Hall_ZJM_Head_Bg_Boy.png')
	if not tolua.isnull(head) then
        head:setPosition(headBgSize.width/2, headBgSize.height/2)
        head:addTo(headBg)
	end

    --昵称
    local nameStr = GlobalUserItem.szNickName
    nameStr = ExternalFun.subStringByWidth(nameStr, 180, '..', 26, "fonts/round_body.ttf")

    local nickName = cc.Label:createWithTTF(nameStr, "fonts/round_body.ttf", 26)
    :setAnchorPoint(cc.p(0,0.5))
    :setPosition(100 + 20, 28)
    :setTextColor(cc.c4b(255,255,255,255))
    :addTo(self.bottomLayer)


    --金豆背景
    local beanBg = display.newSprite('roomlist/Hlwz_xc_hldbg.png')
    :setPosition(458, 27)
    :addTo(self.bottomLayer)

    local beanBgSize = beanBg:getContentSize()
    --金豆
    -- local jsonName = 'roomlist/spine/GoldBean/GoldBean.json'
    -- local atlasName = 'roomlist/spine/GoldBean/GoldBean.atlas'
    -- local beanNode = sp.SkeletonAnimation:create(jsonName, atlasName, 0.7)
    -- :setPosition(22, beanBgSize.height/2)
    -- :addTo(beanBg)
    -- :setAnimation(0, "animation", true)
    local beanNode =  ExternalFun.addEffectNode(beanBg, "roomlist/", "GoldBean", cc.p(22, beanBgSize.height/2))

    --金豆数
    local str = string.formatNumberThousands(GlobalUserItem.lUserScore,true, ':')
    dump(str)
    self.userScore = cc.LabelAtlas:_create(str, 'roomlist/font_bean.png', 17, 26, string.byte('0'))
    :setAnchorPoint(cc.p(0.5, 0.5))
	:setPosition(beanBgSize.width/2, beanBgSize.height/2)
	:addTo(beanBg)
    :setScale(0.7)

    --增加金豆按钮
    local btnBean = ccui.Button:create('roomlist/Hlwz_xc_hldbtn.png', '', '')
    :addTo(beanBg)
    :setPosition(beanBgSize.width - 10, beanBgSize.height/2 + 10)
    :addTouchEventListener(function(ref, type)
        if type == ccui.TouchEventType.ended then
            ExternalFun.playCommonButtonClickEffect()
            self:getParent():addBankLayer()
        end
    end)

    self:initListener()

    local spwan = cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(0,180)), cc.FadeTo:create(0.2, 255))
    local sequence = cc.Sequence:create(cc.DelayTime:create(0.4), spwan)
    self.bottomLayer:runAction(sequence)
end

function GameRoomListLayer:updateBean()
    print('GameRoomListLayer 更新金币')
    local str = string.formatNumberThousands(GlobalUserItem.lUserScore,true,':')
    self.userScore:setString(str)
  
end

function GameRoomListLayer:initListener()
    self.m_listener = cc.EventListenerCustom:create(yl.RY_USERINFO_NOTIFY,handler(self, self.updateBean))
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(self.m_listener, self)
end

function GameRoomListLayer:onEnterRoom( frameEngine )
	print("自定义房间进入")
	if nil ~= frameEngine and frameEngine:SitDown(yl.INVALID_TABLE,yl.INVALID_CHAIR) then
        return true
	end
end

--获取开始坐下默认坐下位置
function GameRoomListLayer.getDefaultSit()
	return yl.INVALID_TABLE,yl.INVALID_CHAIR
end

return GameRoomListLayer