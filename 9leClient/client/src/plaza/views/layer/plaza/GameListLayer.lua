-- 游戏列表
local GameListLayer = class("GameListLayer", ccui.ScrollView)

local ClientUpdate = appdf.req(appdf.BASE_SRC.."app.controllers.ClientUpdate")

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

local QueryDialog = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.QueryDialog")

function GameListLayer:ctor(scene)
	print("============= 游戏列表界面创建 =============")

    self._scene = scene

    self:setDirection(ccui.ScrollViewDir.horizontal)--(ccui.ScrollViewDir.horizontal) --vertical
    self:setScrollBarEnabled(false)
    self:setBounceEnabled(true)
    --self:setInnerContainerSize(cc.size(1800, 540))
   -- self:addTo(self)
    self._isClickGame = false
    self._gameLists = {
		--{25, 200, 36}, --苹果审核游戏
		{  998, 14 ,2075, 28},
		{ 28,102, 27, 36,200,1040},
		--{ 510 },
		{ 34,29,122,140,118,998,123},
		{ 30,31,32,13,2075,516,2099,2068},
        { 22,14,601,20,21},
    }
    self._gameListsNewToSpine = {
		--{25, 200, 36}, --苹果审核游戏
		{  "lhd", "lkpy" ,"sglx", "ssz"},
		{ "ssz","ernn", "srnn", "tbnn","hbddz","hbsl"},
		--{ 510 },
		{ "xyzb","brnn","hl30m","hcjlb","brsb","lhd","fqzs"},
		{ "pjl","xzw","ytnl","fsb","sglx","shz","csll","csd"},
        { "xmby","lkpy","dntg","yqs","jcby"},
	}
end

--------------------------------------------------------------------------------------------------------------------
-- 功能方法
function GameListLayer:updateGameList2(gamelist,panel)
   self._gameindex = gamelist
    print("更新游戏列表2")
    if gamelist == 0 then
        return
    end
    self._gamePanel = panel;
    if gamelist == 1 then
        self:setVisible(false)
        panel:setVisible(true)
        --local game1 = panel:getChildByName("gameTag1");
        local game2 = panel:getChildByName("gameTag2");
        local game3 = panel:getChildByName("gameTag3");
        local game4 = panel:getChildByName("gameTag4");
        local game5 = panel:getChildByName("gameTag5");
        local game6 = panel:getChildByName("gameTag6");
        local game7 = panel:getChildByName("gameTag7");
       
        game2:addClickEventListener(function()
            if not self._isClickGame then
                self._isClickGame = true
                self:onClickGame(998)
            end
        end)
        
        game3:addClickEventListener(function()
            if not self._isClickGame then
                self._isClickGame = true
                self:onClickGame(30)
            end
        end)
        game4:addClickEventListener(function()
            if not self._isClickGame then
                self._isClickGame = true
                self:onClickGame(36)
            end
        end)
        game5:addClickEventListener(function()
            if not self._isClickGame then
                self._isClickGame = true
                self:onClickGame(14)
            end
        end)
        game6:addClickEventListener(function()
            if not self._isClickGame then
                self._isClickGame = true
                self:onClickGame(31)
            end
        end)
        game7:addClickEventListener(function()
            if not self._isClickGame then
                self._isClickGame = true
                self:onClickGame(102)
            end
        end)
        game2:setTag(998)
        game3:setTag(30)
        game4:setTag(36)
        game5:setTag(14)
        game6:setTag(31)
        game7:setTag(102)

        game2:removeAllChildren()
        game3:removeAllChildren()
        game4:removeAllChildren()
        game5:removeAllChildren()
        game6:removeAllChildren()
        game7:removeAllChildren()

    else 
        panel:setVisible(false)
        self:setVisible(true)
        self._gameListNewToSpine = self._gameListsNewToSpine[gamelist]
        self:updateGameList(self._gameLists[gamelist])
    end 
    
end
--更新游戏列表
function GameListLayer:updateGameList(gamelist)

    print("更新游戏列表")
   
    --保存游戏列表
    self._gameList = gamelist

    --清空子视图
    self:removeAllChildren()

    if #gamelist == 0 then
        return
    end
    
    --设置内容高度
    local contentSize = self:getContentSize()
    local iconCX            =   271
    local iconCY            =   250
    local spacing           =   20+15
    local columns           =   9
    local lines             =   math.ceil( #gamelist / columns )
    local containerWidth    =   contentSize.width
    local containerHeight   =   lines * iconCY + (lines - 1) * spacing - 35

    --判断容器高度是否小于最小高度
    if containerHeight < contentSize.height then
        containerHeight = contentSize.height
    end
    --local num = #gamelist%2 == 0 and #gamelist/2 or math.ceil(#gamelist/2)
    --local num2 = #gamelist%2 == 0 and 2 or 1
    local num = #gamelist
    local num3 = 0
    for i = 1, #gamelist do
        --for j=1,2 do
           
            -- local row       =   math.floor( (i - 1) / columns )
            -- local col       =   (i - 1) % columns
            -- local x         =   col * spacing + (col + 0.5) * iconCX
            -- local y         =   containerHeight - (row + (row + 0.5) * iconCY)
            local x 
            local y 
            if i < 9 then
                if i <5 then
                    x = 175 + (i-1) * iconCX
                    y = 427 
                else
                    x = 175 + (i-5) * iconCX
                    y = 427 -250
                end
            elseif i >=9 then
                local ii = 4 + ( math.ceil((i-8)/2) ) 
                local j =  i%2 == 0 and 2 or 1
                x =  175 + (ii-1)*iconCX
                y =  427 - (j-1)*iconCY
            end

            --游戏图标
            --local filestr = "GameList/game_"..gamelist[i]..".png"
            --游戏图标按钮
           
            local jsonName = "GameList/spine/"..self._gameListNewToSpine[i]..".json"
	        local atlasName = "GameList/spine/"..self._gameListNewToSpine[i]..".atlas"
	        local chessEffectNode = sp.SkeletonAnimation:create(jsonName, atlasName, 1.0)
	        :setPosition(cc.p(x-125,y-20-3+118))
	        :addTo(self,-1)
            :setAnimation(0, "animation", true)

            local btnGameIcon = ccui.Button:create("plaza/alpha2.png","plaza/alpha2.png","plaza/alpha2.png")
            btnGameIcon:setPosition(cc.p(x,y-20-3))
            btnGameIcon:setTag(gamelist[i]) --游戏KindID做为Tag
          
            btnGameIcon:addTo(self,2)
            local sizeW = x+iconCX;
            if sizeW>1500 then sizeW = sizeW+200 end
            if sizeW <containerWidth then sizeW = containerWidth end
            self:setInnerContainerSize(cc.size(sizeW, containerHeight))

            -- local btnGameIcon = ccui.Button:create(filestr, filestr, filestr)

            -- btnGameIcon:setPosition(cc.p(x,y-20-3))
            -- btnGameIcon:setTag(gamelist[i]) --游戏KindID做为Tag
          
            -- btnGameIcon:addTo(self)
            -- local sizeW = x+iconCX;
            -- if sizeW>1500 then sizeW = sizeW+200 end
            -- if sizeW <containerWidth then sizeW = containerWidth end
            -- self:setInnerContainerSize(cc.size(sizeW, containerHeight))

            btnGameIcon:addClickEventListener(function()
                if not self._isClickGame then
                    self._isClickGame = true
                    self:onClickGame(self._gameList[i])
                end
            end)
       -- end
       
    end
    --滚动的到前面
    self:jumpToTop()
end

--下载游戏
function GameListLayer:downloadGame(gameinfo)
    
    print("downloadGame  ",self._updategame)
    if self._updategame then
        showToast(nil, "正在更新 “" .. self._updategame._GameName .. "” 请稍后", 2)
        return
    end

    --保存更新的游戏
    self._updategame = gameinfo

    local app = self._scene:getApp()
    --写死  多渠道下载游戏 走同一个地址
    local updateUrl
    if appdf.ENV == 2 then                  --正式服
        updateUrl= "http://cdn.hjy510.com/Download/Phone"
    elseif appdf.ENV == 4 then              --内网
        updateUrl= "http://cdn.hjy510.com/Download/Phone"
    else                                    --正式服
        updateUrl= "http://cdn.hjy510.com/Download/Phone"        
    end

     if  appdf.isErrorLogin == true then
        updateUrl = "http://quwangame.oss-cn-hangzhou.aliyuncs.com/Download/Phone"
     end

    --local updateUrl = app:getUpdateUrl()--"http://5185931.oss-cn-hangzhou.aliyuncs.com/qipai/land.zip"

    --下载地址
    local fileurl = updateUrl .. "/game/" .. string.sub(gameinfo._Module, 1, -2) .. ".zip"
    print(fileurl)
    --文件名
    local pos = string.find(gameinfo._Module, "/")
    local savename = string.sub(gameinfo._Module, pos + 1, -2) .. ".zip"
    --保存路径
    local savepath = nil
    local unzippath = nil
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if cc.PLATFORM_OS_WINDOWS == targetPlatform then
		savepath = device.writablePath .. "download/game/" .. gameinfo._Type .. "/"
        unzippath = device.writablePath .. "game/" .. gameinfo._Type .. "/"
    else
        savepath = device.writablePath .. "game/" .. gameinfo._Type .. "/"
        unzippath = device.writablePath .. "game/" .. gameinfo._Type .. "/"
	end

    print("savepath: " .. savepath)
    print("savename: " .. savename)
    print("unzippath: " .. unzippath)
    self:showGameProgress(gameinfo._KindID, 0)
    --下载游戏压缩包
    downFileAsync(fileurl, savename, savepath, function(main, sub)

        --对象已经被销毁
        if not appdf.isObject(self) then
            return
        end

		--下载回调
		if main == appdf.DOWN_PRO_INFO then --进度信息
			print(sub)
            self:showGameProgress(gameinfo._KindID, sub)

		elseif main == appdf.DOWN_COMPELETED then --下载完毕

            local zipfile = savepath .. savename

            --解压
            unZipAsync(zipfile, unzippath, function(result)
				
                --删除压缩文件
                os.remove(zipfile)

                --清空正在更新的游戏状态
                self._updategame = nil

                self:hideGameProgress(gameinfo._KindID)

                if result == 1 then
                    --保存版本记录
                    app:getVersionMgr():setResVersion(gameinfo._ServerResVersion, gameinfo._KindID)

                    showToast(nil, "“" .. gameinfo._GameName .. "” 下载完毕", 2)
                    --播放音效
                    self:playFinishEffect()
                    self:OnEnterGame(gameinfo)
                else
                    showToast(nil, "“" .. gameinfo._GameName .. "” 解压失败", 2)
                    self._isClickGame = false
                end

			end)

		else

            --清空正在更新的游戏状态
            self._updategame = nil

            self:hideGameProgress(gameinfo._KindID)

            showToast(nil, "“" .. gameinfo._GameName .. "” 下载失败，错误码：" ..main, 2)

            self._isClickGame = false

		end
	end)
end


-- 自动进入            
function GameListLayer:OnEnterGame(gameinfo)

     --获取房间列表                        
    local roomList = GlobalUserItem.roomlist[tonumber(gameinfo._KindID)]
    local roomCount = roomList and #roomList or 0
    dump(roomList)
    local myScore = tonumber(GlobalUserItem.lUserScore)
    
    if roomCount == 0 then
        showToast(nil, "抱歉，游戏房间暂未开放，请稍后再试！", 2)
        self._isClickGame = false
        return 
    end
   
    --判断金币是否满足进入最低的房间
    if myScore < roomList[1].lEnterScore and GlobalUserItem.getRoomCount(tonumber(gameinfo._KindID)) == 1 then
        local str = "进入游戏失败\n抱歉，您的游戏成绩低于当前游戏的最低进入成绩"..tostring(roomList[1].lEnterScore).."，不能进入当前游戏!"
        QueryDialog:create(str, function()
            self._scene:onShowShop()
            end, nil, QueryDialog.QUERY_SURE)
                            :addTo(self._scene)
        self._isClickGame = false                  
        return
    end

    local retRommCount = roomCount > 1 and true or false

    if retRommCount == true then

        self:OnAutoGame(gameinfo,false)

    else
     -- 直接进入游戏
        if gameinfo._KindID ~= tostring(516) and gameinfo._KindID ~= tostring(601) and gameinfo._KindID ~= tostring(19) then
            self._scene._roomLayer:GameLoadingView(tonumber(gameinfo._KindID))
        end
        self:OnAutoGame(gameinfo,true)
    end 
    
end


--进入房间
--更新游戏
function GameListLayer:OnAutoGame(gameinfo,bAutoGame)

   --根据分数判断适合加入哪个房间
    local myScore = tonumber(GlobalUserItem.lUserScore)
     
     --获取房间列表                        
    local roomList = GlobalUserItem.roomlist[tonumber(gameinfo._KindID)]
    local roomCount = roomList and #roomList or 0
    

    local wServerID = nil
    
    table.sort(roomList,function(a,b)
            return a.lEnterScore < b.lEnterScore
            end)
    if roomCount > 0 then
        --if myScore >= roomList[1].lEnterScore then
            wServerID = roomList[1].wServerID
        --end
    else
        return
    end
    for k, v in pairs(roomList) do 
        if myScore >= v.lEnterScore then
            wServerID = v.wServerID
        end
    end

    if bAutoGame == false then
        self._scene:onClickGame(tonumber(gameinfo._KindID))--OnAutoGameHide()
    end
    self._scene._bIsQuickStart = bAutoGame;
   -- self._roomListLayer:showRoomList(tonumber(gameinfo._KindID))

    self._scene:onOuatGameLIst(tonumber(gameinfo._KindID),true)
    if bAutoGame then
        self._scene:onClickRoom(wServerID, tonumber(gameinfo._KindID))
    end
end

--更新游戏
function GameListLayer:updateGame(gameinfo)

    if self._updategame then
        showToast(nil, "正在更新 “" .. self._updategame._GameName .. "” 请稍后", 2)
        return
    end

    --保存更新的游戏
    self._updategame = gameinfo

    local app = self._scene:getApp()
    local updateUrl
    if appdf.ENV == 2 then                  --正式服
        updateUrl= "http://cdn.hjy510.com/Download/Phone"
    elseif appdf.ENV == 4 then              --内网
        updateUrl= "http://cdn.hjy510.com/Download/Phone"
    else                                    --正式服
        updateUrl= "http://cdn.hjy510.com/Download/Phone"        
    end
    
    local newfileurl = updateUrl.."/game/"..gameinfo._Module.."res/filemd5List.json"
    local src = nil
	local dst = nil
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if cc.PLATFORM_OS_WINDOWS == targetPlatform then
        dst = device.writablePath .. "game/" .. gameinfo._Type .. "/"
        src = device.writablePath.."game/"..gameinfo._Module.."res/filemd5List.json"
    else
        dst = device.writablePath .. "game/" .. gameinfo._Type .. "/"
        src = device.writablePath.."game/"..gameinfo._Module.."res/filemd5List.json"
	end

	local downurl = updateUrl .. "/game/" .. gameinfo._Type .. "/"

	--创建更新
	self._update = ClientUpdate:create(newfileurl,dst,src,downurl)
	self._update:upDateClient(self)
end


--显示游戏进度
function GameListLayer:showGameProgress(wKindID, nPercent)
    print("showGameProgress :",wKindID)
    --游戏图标
    local gameicon = self:getChildByTag(wKindID)
   -- gameicon = self._gamePanel:getChildByName("gameTag1");
    if not gameicon then
        gameicon = self._gamePanel:getChildByTag(wKindID)
    end
    
    if self._gameindex == 1 then
        gameicon = self._gamePanel:getChildByTag(wKindID)
    end
   
    if not gameicon then
        return
    else 
        
    end
    
   local contentSize = gameicon:getContentSize()

    --遮罩
    local mask = gameicon:getChildByTag(1)
    if mask == nil then

        --if self._gameindex == 1 then
            mask = cc.Sprite:create("plaza/loadbarbg.png")--ccui.Layout:create()
            --:setClippingEnabled(true)
            :setTag(1)
            :setAnchorPoint(cc.p(0.5, 0.5))
            :setPosition(cc.p(gameicon:getContentSize().width/2,gameicon:getContentSize().height/2))
            :addTo(gameicon)
            -- local sp = cc.Sprite:create(string.format( "GameList/game_%d.png",wKindID ))
            -- :setColor(cc.c3b(150, 150, 150))
            -- :setAnchorPoint(cc.p(0, 0))
            -- :setPosition(0, 0)
            -- :addTo(mask,-1)
            local spbar = cc.Sprite:create("plaza/loading.png")
            :setPosition(113/2, 113/2)
            :addTo(mask,1,3)
            --最远来的
--         else
--             mask = ccui.Layout:create()
--             :setClippingEnabled(true)
--             :setAnchorPoint(cc.p(0, 0))
--             :setPosition(0, 0)
--             :setTag(1)
--             :addTo(gameicon)

-- gameicon:clone()
--             :setColor(cc.c3b(150, 150, 150))
--             :setAnchorPoint(cc.p(0, 0))
--             :setPosition(0, 0)
--             :addTo(mask)
        --end
    end

   -- mask:setContentSize(contentSize.width, contentSize.height * (100 - nPercent) / 100)

    if mask:getChildByTag(3) ~= nil then
        mask:getChildByTag(3):setRotation(360/100*nPercent)
    end
    --进度
    local progress = gameicon:getChildByTag(2)
    if progress == nil then
        progress = cc.Label:createWithTTF("0%", "fonts/round_body.ttf", 32)
                        :enableOutline(cc.c4b(0,0,0,255), 1)
                        :setPosition(contentSize.width / 2, contentSize.height / 2)
                        :setTag(2)
                        :addTo(gameicon)
    end

    if nPercent == 100 then 
        progress:setString("正在安装...")
    else
        progress:setString(nPercent .. "%")
    end
end

--隐藏游戏进度
function GameListLayer:hideGameProgress(wKindID)

    --游戏图标
    local gameicon = self:getChildByTag(wKindID)
    if not gameicon then
        gameicon = self._gamePanel:getChildByTag(wKindID)
        if not gameicon then
            return
        end
    end

    gameicon:removeAllChildren()
end

--播放完成音效
function GameListLayer:playFinishEffect()
    --播放音效
    ExternalFun.playPlazaEffect("gameDownFinish.mp3")   
end
--------------------------------------------------------------------------------------------------------------------
-- 事件处理

--点击游戏
function GameListLayer:onClickGame(wKindID)

    print("点击游戏图标", wKindID)

    --播放按钮音效
    ExternalFun.playClickEffect()

    local app = self._scene:getApp()

    --判断游戏是否存在
    local gameinfo = app:getGameInfo(wKindID)
    if not gameinfo then 
        showToast(nil, "大爷，人家还没准备好呢！", 2)
        self._isClickGame = false
        return
    end

    if LOCAL_DEVELOP == 1 then
        --判断是否开放房间
        if GlobalUserItem.getRoomCount(wKindID) == 0 then
            showToast(nil, "抱歉，游戏房间暂未开放，请稍后再试！", 2)
            self._isClickGame = false
            return
        end

        --通知进入游戏类型
        if self._scene and self._scene.onClickGame then
            self._scene:onClickGame(wKindID)
        end
    else
        local version = tonumber(app:getVersionMgr():getResVersion(gameinfo._KindID))
        if version == nil then --下载游戏
            print("下载游戏")
            self:downloadGame(gameinfo)

        elseif gameinfo._ServerResVersion > version then --更新游戏
            print("更新游戏")
            self:updateGame(gameinfo)

        else
            --判断是否开放房间
            if GlobalUserItem.getRoomCount(wKindID) == 0 then
                showToast(nil, "抱歉，游戏房间暂未开放，请稍后再试！", 2)
                self._isClickGame = false
                return
            end
            --根据房间数判断进入游戏还是进入房间列表
            if GlobalUserItem.getRoomCount(wKindID) == 1 then
                --直接进入游戏
                self:OnEnterGame(gameinfo)
            else
                --通知进入游戏类型
                if self._scene and self._scene.onClickGame then
                    self._scene:onClickGame(wKindID)
                end
            end
        end
    end
    
end

--------------------------------------------------------------------------------------------------------------------
-- ClientUpdate 回调

--更新进度
function GameListLayer:onUpdateProgress(sub, msg, mainpersent)
    
    if self._updategame then
        self:showGameProgress(self._updategame._KindID, math.ceil(mainpersent))
    end
end

--更新结果
function GameListLayer:onUpdateResult(result,msg)

    self:hideGameProgress(self._updategame._KindID)

    if result == true then
        msg = "“" .. self._updategame._GameName .. "” 更新完毕"

        --保存版本记录
        self._scene:getApp():getVersionMgr():setResVersion(self._updategame._ServerResVersion, self._updategame._KindID)

        --播放音效
        self:playFinishEffect()
        --自动进入游戏
        self:OnEnterGame(self._updategame)
    else
        msg = "“" .. self._updategame._GameName .. "” " .. msg
        self._isClickGame = false
    end

    --清空正在更新的游戏状态
    self._updategame = nil
    self._update = nil
    self._isClickGame = false
    showToast(nil, msg, 2)
end

return GameListLayer