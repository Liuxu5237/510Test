-- 房间列表
local RoomListLayer = class("RoomListLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

local RoomCreateLayer = appdf.req(appdf.CLIENT_SRC.."privatemode.plaza.src.views.RoomCreateLayer")
local RoomJoinLayer = appdf.req(appdf.CLIENT_SRC.."privatemode.plaza.src.views.RoomJoinLayer")
local RoomRecordLayer = appdf.req(appdf.CLIENT_SRC.."privatemode.plaza.src.views.RoomRecordLayer")
local QueryDialog = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.QueryDialog")

function RoomListLayer:ctor(delegate)
    
    self._delegate = delegate

    --开启级联透明度
    self:setCascadeOpacityEnabled(true)

    --背景
    --[[self._content = cc.Sprite:create("RoomList/sp_background.png")
    self._content:setPosition(display.center)
    self._content:addTo(self)]]
    --标题背景
    self._titlebg = cc.Sprite:create("RoomList/titlebg.png")
    self._titlebg:setPosition(display.width / 2, display.height - 135)
    -- self._titlebg:setScaleY(0.6)
    -- self._titlebg:setScaleX(0.7)
    self._titlebg:addTo(self)

    --房间列表视图
    self._scrollView = ccui.ScrollView:create()
    self._scrollView:setDirection(ccui.ScrollViewDir.horizontal)
    self._scrollView:setAnchorPoint(cc.p(0,0))
--    self._scrollView:setBackGroundColor(cc.RED)
--    self._scrollView:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
--    self._scrollView:setBackGroundColorOpacity(100)
    self._scrollView:setBounceEnabled(true)
    self._scrollView:setScrollBarEnabled(false)
    --self._scrollView:setContentSize(cc.size(1510, 538))
    --self._scrollView:setInnerContainerSize(cc.size(1710, 538))
    self._scrollView:setPosition(0, 115)
    self._scrollView:setVisible(false)
    self._scrollView:addTo(self)

    --房间固定列表
    -- self._roomlayout = ccui.Layout:create()
    -- self._roomlayout:setAnchorPoint(cc.p(0,0))
    -- self._roomlayout:setContentSize(cc.size(display.width, display.height/2 - 40))
    -- self._roomlayout:setPosition(cc.p(0,145))
    -- self._roomlayout:setCascadeOpacityEnabled(true)
    -- self._roomlayout:setVisible(false)
    -- self._roomlayout:addTo(self)

    --房间分类视图
    self._categoryView = ccui.Layout:create()
    self._categoryView:setAnchorPoint(cc.p(0.5,0.5))
--    self._categoryView:setBackGroundColor(cc.RED)
--    self._categoryView:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
--    self._categoryView:setBackGroundColorOpacity(100)
    self._categoryView:setContentSize(cc.size(1210, 538))
    self._categoryView:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2 - 15)
    self._categoryView:setCascadeOpacityEnabled(true)
    self._categoryView:setVisible(false)
    self._categoryView:addTo(self)

    self._touchListener = function(ref, type)
        --改变按钮点击颜色
        if type == ccui.TouchEventType.began then
            ref:setColor(cc.c3b(200, 200, 200))
        elseif type == ccui.TouchEventType.ended or ccui.TouchEventType.canceled then
            ref:setColor(cc.WHITE)
        end
    end

    --游戏币场
    self._btnGoldRoom = ccui.Button:create("RoomList/icon_gold_room.png", "RoomList/icon_gold_room.png")
    self._btnGoldRoom:addTouchEventListener(self._touchListener)
    self._btnGoldRoom:addClickEventListener(function() self:onClickGoldRoom() end)
    self._btnGoldRoom:addTo(self._categoryView)

    --创建房间
    self._btnCreateRoom = ccui.Button:create("RoomList/icon_create_room.png", "RoomList/icon_create_room.png")
    self._btnCreateRoom:addTouchEventListener(self._touchListener)
    self._btnCreateRoom:addClickEventListener(function() self:onClickCreateRoom() end)
    self._btnCreateRoom:addTo(self._categoryView)

    --加入房间
    self._btnJoinRoom = ccui.Button:create("RoomList/icon_join_room.png", "RoomList/icon_join_room.png")
    self._btnJoinRoom:addTouchEventListener(self._touchListener)
    self._btnJoinRoom:addClickEventListener(function() self:onClickJoinRoom() end)
    self._btnJoinRoom:addTo(self._categoryView)

    --我的房间
    self._btnMyRoom = ccui.Button:create("RoomList/icon_my_room.png", "RoomList/icon_my_room.png")
    self._btnMyRoom:setPosition(self._categoryView:getContentSize().width - 26, self._categoryView:getContentSize().height / 2)
    self._btnMyRoom:addTouchEventListener(self._touchListener)
    self._btnMyRoom:addClickEventListener(function() self:onClickMyRoom() end)
    self._btnMyRoom:addTo(self._categoryView)
end

------------------------------------------------------------------------------------------------------------
-- 公共接口

--显示房间分类
function RoomListLayer:showRoomCategory(wKindID)

    print("显示房间分类")

    --保存游戏类型
    self._kindID = wKindID

    --显示
    self._categoryView:setVisible(true)
    self._scrollView:setVisible(false)

    local centerX = self._categoryView:getContentSize().width / 2
    local centerY = self._categoryView:getContentSize().height / 2

    local normalRoomCount = GlobalUserItem.getNormalRoomCount(wKindID)
    if normalRoomCount > 0 then
        self._btnGoldRoom:setPosition(centerX - 360, centerY)
        self._btnCreateRoom:setPosition(centerX, centerY)
        self._btnJoinRoom:setPosition(centerX + 360, centerY)
    else
        self._btnCreateRoom:setPosition(centerX - 250, centerY)
        self._btnJoinRoom:setPosition(centerX + 250, centerY)
    end

    --是否显示游戏币场
    self._btnGoldRoom:setVisible(normalRoomCount > 0)
end

--房间列表刷新
function  RoomListLayer:ShowRommList()
 --self._roomlayout:setVisible(true)
 self._scrollView:setVisible(true)
 local vecChildren = self._scrollView:getChildren()
	for k,v in pairs(vecChildren) do
		v:setVisible(true)
	end

     --保存层
    --self._delegate:pushLayerTag(1)
end
--显示房间列表
function RoomListLayer:showRoomList(wKindID,bshow)
    
    print("显示房间列表", wKindID)

    --保存游戏类型
    self._kindID = wKindID

    --清空子视图
    self._scrollView:removeAllChildren()
    --self._roomlayout:removeAllChildren()
    self._titlebg:removeAllChildren()
    if self.btnQuickStart ~= nil then
        self.btnQuickStart:removeFromParent()
    end
    
    --显示
    self._categoryView:setVisible(false)
    self._scrollView:setVisible(true)
    --self._roomlayout:setVisible(bshow)

    --获取房间列表
    local roomList = GlobalUserItem.roomlist[wKindID]
    local roomCount = roomList and #roomList or 0
    table.sort(roomList,function(a,b)
            return a.lEnterScore < b.lEnterScore
            end)

    self._scrollView:setContentSize(cc.size(1510, 538))  

    local marginX           =   48  --X边距
    local marginY           =   26  --Y边距
    local spaceX            =   34  --X间距
    local spaceY            =   12  --Y间距

    local colCount          =   3
    local roomLines         =   math.ceil( roomCount / colCount )
    local roomSize          =   cc.size(245, 449)
    local contentSize       =   self._scrollView:getContentSize()--self._scrollView:getContentSize()
    local containerWidth    =   contentSize.width
    local containerHeight   =   marginY * 2 + roomLines * roomSize.height + (roomLines - 1) * spaceY;

    --判断容器高度是否小于最小高度
    if containerHeight < contentSize.height then
        containerHeight = contentSize.height
    end

    --设置容器大小
   
    if roomCount > 4 then
        self._scrollView:setInnerContainerSize(cc.size(containerWidth+210, contentSize.height))
    else 
        self._scrollView:setInnerContainerSize(cc.size(containerWidth, contentSize.height))
    end  

    --从中点位置向两边延伸
    local layoutmid = contentSize.width / 2
    local layout_btn = ccui.Layout:create()
    :setAnchorPoint(cc.p(0, 0))
    local layoutwidth = 0
    local btn_width  = 0
    --创建房间
    for i = 0, roomCount - 1 do

        --房间信息
        local roomInfo = roomList[i + 1]
        local iconfile  =   string.format("RoomList/icon_room_%d.png", roomInfo.wServerLevel % 10)
        local row       =   math.floor( i / colCount )
        local col       =   i % colCount
        local x         =   (marginX + roomSize.width / 2 + col * (spaceX + roomSize.width))
        local y         =   containerHeight - (marginY + roomSize.height / 2 + row * (spaceY + roomSize.height))


        local btnRoom = ccui.Button:create(iconfile, iconfile, iconfile)
        --x = btnRoom:getContentSize().width / 2 + (btnRoom:getContentSize().width + 5) * i + 20
        x = btnRoom:getContentSize().width / 2 + (btnRoom:getContentSize().width + 55) * i + 120
        --y = btnRoom:getContentSize().height / 2
        y = self._scrollView:getContentSize().height / 2 - 50
        btnRoom:setPosition(x, y)
        if roomCount == 2 then
            btnRoom:setPosition(x+ btnRoom:getContentSize().width+35, y)
        end
        btnRoom:setVisible(bshow)
        btnRoom:setCascadeOpacityEnabled(true)
        btnRoom:addTo(layout_btn)--(self._roomlayout)--(self._scrollView)
        btnRoom:addTouchEventListener(self._touchListener)
        btnRoom:addClickEventListener(function()
            
            --self:onClickRoom(roomInfo.wServerID)
            --全部都是快速开始咯
            
            self:onQuickStartJduge(roomInfo.wServerID)
        end)
        layoutwidth = x + btnRoom:getContentSize().width / 2 + 20
        btn_width = btnRoom:getContentSize().width / 2
        --房间名称
        --[[local nServerNameLen = string.len(roomInfo.szServerName)
        local txtServerName = ccui.Text:create(roomInfo.szServerName, "fonts/round_body.ttf", (nServerNameLen > 10) and 32 or 36)
                                       :setPosition(175, 180)
                                       :setTextColor(cc.WHITE)
                                       :enableOutline(cc.c4b(0,0,0,255), 1)
                                       :addTo(btnRoom)]]


        --底分
        --[[local txtCellScore = ccui.Text:create(roomInfo.lCellScore, "fonts/round_body.ttf", 32)
                                       :setPosition(155, 140)
                                       :setTextColor(cc.WHITE)
                                       :addTo(btnRoom)]]
        --入场条件说明
        --体验房排除
        if tonumber(roomInfo.wServerType) ~= 8 then
            local strsm = ""
            local txtCellScoresm = ccui.Text:create("","fonts/round_body.ttf", 20)
                                            :setPosition(158,178)
                                            :addTo(btnRoom)
            local txtcolor = nil
            if roomInfo.wSortID == 1 then
                txtcolor = cc.c3b(97,53,27)
            elseif roomInfo.wSortID == 2 then
                txtcolor = cc.c3b(54,76,33)
            elseif roomInfo.wSortID == 3 then
                txtcolor = cc.c3b(72,57,140)
            elseif roomInfo.wSortID == 4 then
                txtcolor = cc.c3b(106,21,18)
            end
            if txtcolor ~= nil then
                txtCellScoresm:setTextColor(txtcolor)
            end
           

            local txtCellScore = ccui.TextAtlas:create()
                                                :setProperty("0","RoomList/sp_cellscorenum.png",16,25,"0")
                                                :setPosition(125,70)
                                                :setString(tostring(roomInfo.lCellScore))
                                                :addTo(btnRoom)
            if self._kindID == 27 or self._kindID == 102 then
                strsm = ""
                txtCellScore:setVisible(false)
                txtCellScoresm:setVisible(false)
                local sp_cellscore = cc.Sprite:create("RoomList/sp_gamescore.png")
                                              :setPosition(125,70)
                                              :addTo(btnRoom)
            elseif self._kindID == 601 or self._kindID == 19 then
                txtCellScore:setVisible(false)
                txtCellScoresm:setVisible(false)
                local sp_cellscore = cc.Sprite:create("RoomList/sp_dntg_score_"..tostring(roomInfo.wSortID-1)..".png")
                                              :setPosition(125,70)
                                              :addTo(btnRoom)
            elseif self._kindID == 516 then
                strsm = "最低押分"
                local serverlevel = tonumber(roomInfo.wServerLevel)
                local minbet = 100
                --没办法,定死吧
                if serverlevel == 2 then
                    minbet = 1000
                elseif serverlevel == 3 then
                    minbet = 10000
                elseif serverlevel == 4 then
                    minbet = 100000
                end
                local maxbet = minbet * 8
                local str = minbet..":"..maxbet
                txtCellScore:setScale(0.65)
                txtCellScoresm:setTextColor(cc.c3b(255, 251, 240))
                -- txtCellScore:setString(str)
                txtCellScore:setString(str)
                local txtwidth = txtCellScore:getContentSize().width
                if txtwidth > 200 then
                    txtCellScore:setScale(115 / txtwidth)
                end
            elseif self._kindID == 14 or self._kindID == 20  or self._kindID == 21  or self._kindID == 22 then
                --strsm = "最低押分"
                local serverlevel = tonumber(roomInfo.wServerLevel)
                local minbet = 100
                local maxbet = 1000
                --没办法,定死吧
                if serverlevel == 2 then
                    minbet = 1000
                    maxbet = 10000
                elseif serverlevel == 3 then
                    minbet = 10000
                    maxbet = 100000
                elseif serverlevel == 4 then
                    minbet = 100000
                    maxbet = 300000
                end
                local str = minbet..":"..maxbet
                txtCellScore:setScale(0.65)
                txtCellScoresm:setTextColor(cc.c3b(255, 251, 240))
                -- txtCellScore:setString(str)
                txtCellScore:setString(str)
                local txtwidth = txtCellScore:getContentSize().width
                if txtwidth > 200 then
                    txtCellScore:setScale(115 / txtwidth)
                end
            elseif self._kindID == 30 or self._kindID == 31  or self._kindID == 32  then
                --strsm = "最低押分"
                --三个拉霸
                local serverlevel = tonumber(roomInfo.wServerLevel)
                local minbet = 1000
                local maxbet = 100000
                --没办法,定死吧
                if self._kindID == 30  then
                    if serverlevel == 1 then
                        minbet = 1000
                        maxbet = 5000
                    elseif serverlevel == 2 then
                        minbet = 10000
                        maxbet = 50000
                    elseif serverlevel == 3 then
                        minbet = 100000
                        maxbet = 500000
                    elseif serverlevel == 4 then
                        minbet = 500000
                        maxbet = 2500000
                    end
                end
                
                local str = minbet..":"..maxbet
                txtCellScore:setScale(0.65)
                txtCellScoresm:setTextColor(cc.c3b(255, 251, 240))
                -- txtCellScore:setString(str)
                txtCellScore:setString(str)
                local txtwidth = txtCellScore:getContentSize().width
                if txtwidth > 200 then
                    txtCellScore:setScale(115 / txtwidth)
                end
            end

            txtCellScoresm:setString(strsm)
            --在线人数
            local dwTotalOnlineCount = roomInfo.dwOnLineCount + roomInfo.dwAndroidCount
            local fOnlineRatio = dwTotalOnlineCount / roomInfo.dwFullCount
            local strOnlineStatus = "空闲"
            if roomInfo.dwOnLineCount >= 10 then
                strOnlineStatus = "火爆"
            end
            --[[if fOnlineRatio > 2 / 3 then
                strOnlineStatus = "繁忙"
            elseif fOnlineRatio > 1 / 3 then
                strOnlineStatus = "拥挤" 
            end]]
            local txtOnlineStatus = ccui.Text:create(strOnlineStatus, "fonts/round_body.ttf", 20)
                                           :setAnchorPoint(cc.p(0.5,0.5))
                                           :setPosition(cc.p(148,60))
                                           :setTextColor(cc.WHITE)
                                           :addTo(btnRoom)
                                           :setVisible(false)

            --进入限制
            local strEnterLimit = "0"
            if roomInfo.lEnterScore >= 10000 then
                strEnterLimit = roomInfo.lEnterScore / 10000 .. "万"
            elseif roomInfo.lEnterScore > 0 then
                strEnterLimit = roomInfo.lEnterScore
            end
            local txtEnterScore = ccui.Text:create("进场条件: "..strEnterLimit, "fonts/round_body.ttf", 20)
                                           :setAnchorPoint(cc.p(0.5,0.5))
                                           :setPosition(65 + 60 , 30)
                                           :setTextColor(cc.WHITE)
                                           :addTo(btnRoom)
        end
    end
    layout_btn:setContentSize(1510,145)
    layout_btn:setPosition(cc.p(-50, 0))
    --layout_btn:setPosition(cc.p( btn_width + 20 + i * 100 , 0))
    layout_btn:addTo(self._scrollView)

    self.roomName = cc.Sprite:create("RoomList/gamelogo_"..tostring(self._kindID)..".png")
    :setPosition(cc.p(self._titlebg:getContentSize().width/2,self._titlebg:getContentSize().height/2))
    --:setScaleY(1.2)    
    :addTo(self._titlebg)
    --快速开始
    self.btnQuickStart = ccui.Button:create("RoomList/quickstart.png", "RoomList/quickstart.png", "RoomList/quickstart.png")
    self.btnQuickStart:setPosition(display.width / 2,self.btnQuickStart:getContentSize().height/2)
    self.btnQuickStart:addTo(self)
    self.btnQuickStart:setVisible(bshow)
    self.btnQuickStart:setVisible(roomCount > 0)
    self.btnQuickStart:addClickEventListener(function()
        self:onQuickStartJduge()
        end)
        
    if yl.APPSTORE_VERSION and yl.IS_MAJIA then 
        self.btnQuickStart:removeFromParent()
        self.roomName:removeFromParent()
    end
    if yl.IS_ANDROID_MAJIA == true  then
        self.btnQuickStart:removeFromParent()
        self.roomName:removeFromParent()
    end 
    --滚动的到前面
    self._scrollView:jumpToTop()
end

------------------------------------------------------------------------------------------------------------
-- 事件处理

--点击返回
function RoomListLayer:onKeyBack()
    
    return true
    --local privateRoomCount = GlobalUserItem.getPrivateRoomCount(self._kindID)
    --if self._scrollView:isVisible() then
        --if privateRoomCount > 0 then --显示房间分类
            --self._categoryView:setVisible(true)
            --self._scrollView:setVisible(false)
            --return false
        --end
    --end

    --return true
end

--点击游戏币场
function RoomListLayer:onClickGoldRoom()

    --播放按钮音效
    ExternalFun.playClickEffect()

    self:showRoomList(self._kindID,true)
end

--点击创建房间
function RoomListLayer:onClickCreateRoom()

    --播放按钮音效
    ExternalFun.playClickEffect()

    showPopupLayer(RoomCreateLayer:create(self._kindID))
end

--点击加入房间
function RoomListLayer:onClickJoinRoom()

    --播放按钮音效
    ExternalFun.playClickEffect()

    showPopupLayer(RoomJoinLayer:create(self._kindID))
end

--点击我的房间
function RoomListLayer:onClickMyRoom()

    --播放按钮音效
    ExternalFun.playClickEffect()

    showPopupLayer(RoomRecordLayer:create(self._kindID))
end

--点击房间
function RoomListLayer:onClickRoom(wServerID)
    -- print("点击房间图标", wServerID)
    local roomList = GlobalUserItem.roomlist[self._kindID]
    local myScore = GlobalUserItem.lUserScore
    --判断金币是否满足进入最低的房间
    for k,v in pairs(roomList) do
        if v.wServerID == wServerID then
            if tonumber(myScore) < v.lEnterScore then
                local str = "进入游戏失败\n抱歉，您的游戏成绩低于当前游戏的最低进入成绩"..tostring(v.lEnterScore).."，不能进入当前游戏!"
                QueryDialog:create(str, function()
                    self._delegate:onShowShop()
                 end, nil, QueryDialog.QUERY_SURE)
                            :addTo(self)                
                return
            end
        end
    end
    dump(roomList)
    if self._kindID == 516 or self._kindID == 601  or self._kindID == 19 or self._kindID == 14 
    or self._kindID == 20 or self._kindID == 21 or self._kindID == 22 then
        showPopWait(true,3)
    else
        self._delegate._roomLayer:GameLoadingView(self._kindID)
    end
    --播放按钮音效
    ExternalFun.playClickEffect()

    if self._delegate and self._delegate.onClickRoom then
        self._delegate:onClickRoom(wServerID, self._kindID)
    end
end

--快速加入判断
function RoomListLayer:onQuickStartJduge(wServerID, zKindID)

    if zKindID ~=nil then
        self._kindID = zKindID
    end
    --根据分数判断适合加入哪个房间
    local myScore = GlobalUserItem.lUserScore
    local roomList = GlobalUserItem.roomlist[self._kindID]
    local roomCount = roomList and #roomList or 0
    local _wServerID = wServerID
   
    table.sort(roomList,function(a,b)
            return a.lEnterScore < b.lEnterScore
            end)
    if _wServerID == nil then
        if roomCount > 0 then
            --if myScore >= roomList[1].lEnterScore then
            if roomList[1].wServerType ~= 8 then
                _wServerID = roomList[1].wServerID
            elseif roomCount >= 2 then
                _wServerID = roomList[2].wServerID
            end
            --end
        else
            return
        end
    
        for k, v in pairs(roomList) do
            if v.wServerType ~= 8 then
                if myScore >= v.lEnterScore then
                    _wServerID = v.wServerID
                end
            end
        end
    end
    if _wServerID == nil then
        return
    end
    self._delegate._bIsQuickStart = true;
    self:onClickRoom(_wServerID)
end
return RoomListLayer