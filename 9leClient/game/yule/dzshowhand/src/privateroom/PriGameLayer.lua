--
-- Author: HJL
-- Date: 2017-10-13 20:25:57
--
require("client.src.plaza.models.yl")

-- 私人房游戏顶层
local PrivateLayerModel = appdf.req(PriRoom.MODULE.PLAZAMODULE .."models.PrivateLayerModel")
local PriGameLayer = class("PriGameLayer", PrivateLayerModel)

local HeadSprite    = appdf.req(appdf.EXTERNAL_SRC .. "HeadSprite")
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local PopupInfoHead = appdf.req(appdf.EXTERNAL_SRC .. "PopupInfoHead")
local ClipText = appdf.req(appdf.EXTERNAL_SRC .. "ClipText")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")

local BTN_INVITE = 101
local BTN_SHARE = 102
local BTN_QUIT = 103
local BTN_CHAT = 104
local BTN_VOICE = 105

local BTN_DISMISS = 1
local BTN_ZANLI = 2
local BTN_SET = 3
local BTN_HELP = 4
local BTN_SWITCH = 5


function PriGameLayer:ctor( gameLayer )
   PriGameLayer.super.ctor(self, gameLayer)
    -- 加载csb资源
    local rootLayer, csbNode = ExternalFun.loadRootCSB("privateroom/PrivateGameLayer/PrivateGameLayer.csb", self )
    self.m_rootLayer = rootLayer
    self.m_csbNode = csbNode

    --按钮回调
    local function btncallback(ref, tType)
        if tType == ccui.TouchEventType.ended then
            self:onButtonClickedEvent(ref:getTag(),ref)
        end
    end

    -- 桌子操作按钮屏蔽层 回调
    local callbackShield = function(ref)
        local pos = ref:getTouchEndPosition()
        local rectBg = self.spTableBtBg:getBoundingBox()
        if not cc.rectContainsPoint(rectBg, pos) then
            self:showTableBt(false)
        end
    end
    self.layoutShield = ccui.Layout:create()
    :setContentSize(cc.size(display.width, display.height))
    :setTouchEnabled(false)
    :addTo(csbNode,1)
    self.layoutShield:addClickEventListener(callbackShield)
   
    --离开按钮
    
    self.m_btnInvite = csbNode:getChildByName("Btn_Exit")
    self.m_btnInvite:setTag(BTN_ZANLI)
    self.m_btnInvite:addTouchEventListener(btncallback)
		  
    --解散按钮
    
	self.m_btnInvite = csbNode:getChildByName("Btn_DissRoom")
    self.m_btnInvite:setTag(BTN_DISMISS)
    self.m_btnInvite:addTouchEventListener(btncallback)	   
		   
    --邀请按钮
    self.m_btnInvite = csbNode:getChildByName("bt_invite")
    self.m_btnInvite:setTag(BTN_INVITE)
    self.m_btnInvite:addTouchEventListener(btncallback)

     --背景
    local image_bg = csbNode:getChildByName("sp_roomInfoBg")

    -- 房间ID
    self.m_atlasRoomID = image_bg:getChildByName("Text_roomNum")
    self.m_atlasRoomID:setString("房号：1008611")
   
    --名称(改作扎码数量了)
   --local cbMaCount = self._gameLayer:getMaCount()
   -- self.m_textRoomName = image_bg:getChildByName("Text_ZhaMaCount"):setString("0个扎码")
    
    -- 局数
    self.m_atlasCount = image_bg:getChildByName("Text_index")
    self.m_atlasCount:setString("1 / 5 局")


end
--显示操作按钮
function PriGameLayer:showTableBt(bVisible)
    if self.spTableBtBg:isVisible() == bVisible then
        return false
    end

    local fSpacing = 120
    if bVisible == true then
        self.layoutShield:setTouchEnabled(true)
        self.btSwitch:setVisible(false)
        self.spTableBtBg:setVisible(true)
        self.spTableBtBg:runAction(cc.MoveBy:create(0.3, cc.p(- fSpacing, 0)))
    else
        self.layoutShield:setTouchEnabled(false)
        self.spTableBtBg:runAction(cc.Sequence:create(
        cc.MoveBy:create(0.5, cc.p(fSpacing, 0)),
        cc.CallFunc:create( function(ref)
            self.btSwitch:setVisible(true)
            self.spTableBtBg:setVisible(false)
        end )))
    end

    return true
end
function PriGameLayer:onButtonClickedEvent( tag, sender )

    if BTN_DISMISS == tag then              -- 请求解散游戏
        PriRoom:getInstance():queryDismissRoom()
    elseif BTN_INVITE == tag then
        PriRoom:getInstance():getPlazaScene():popTargetShare(function(target, bMyFriend)
            bMyFriend = bMyFriend or false
            local function sharecall( isok )
                if type(isok) == "string" and isok == "true" then
                    showToast(self, "分享成功", 2)
                end
            end
            local shareTxt = "房号" .. PriRoom:getInstance().m_tabPriData.szServerID .. 
                            "，局数" .. PriRoom:getInstance().m_tabPriData.dwDrawCountLimit .. 
                            "，人数" .. PriRoom:getInstance():getChairCount() .. 
                            "。德州扑克游戏精彩刺激, 一起来玩吧！"
            local friendC = "德州扑克房号" .. PriRoom:getInstance().m_tabPriData.szServerID .. 
                            "，局数" .. PriRoom:getInstance().m_tabPriData.dwDrawCountLimit .. 
                            "，人数" .. PriRoom:getInstance():getChairCount()
            local url = GlobalUserItem.szWXSpreaderURL or yl.HTTP_URL
            if bMyFriend then
                PriRoom:getInstance():getTagLayer(PriRoom.LAYTAG.LAYER_FRIENDLIST, function( frienddata )
                    local serverid = tonumber(PriRoom:getInstance().m_tabPriData.szServerID) or 0                    
                    PriRoom:getInstance():priInviteFriend(frienddata, GlobalUserItem.nCurGameKind, serverid, yl.INVALID_TABLE, friendC)
                end)
            elseif nil ~= target then
                MultiPlatform:getInstance():shareToTarget(target, sharecall, "德州扑克", shareTxt, url, "")
            end
        end)
    elseif BTN_SHARE == tag then
        print("分享")
        --GlobalUserItem.bAutoConnect = false
        PriRoom:getInstance():getPlazaScene():popTargetShare(function(target, bMyFriend)
            bMyFriend = bMyFriend or false
            local function sharecall( isok )
                if type(isok) == "string" and isok == "true" then
                    showToast(self, "分享成功", 2)
                end
                --GlobalUserItem.bAutoConnect = true
            end
            local url = GlobalUserItem.szWXSpreaderURL or yl.HTTP_URL
            -- 截图分享
            local framesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
            local area = cc.rect(0, 0, framesize.width, framesize.height)
            local imagename = "grade_share.jpg"
            if bMyFriend then
                imagename = "grade_share_" .. os.time() .. ".jpg"
            end
            ExternalFun.popupTouchFilter(0, false)
            captureScreenWithArea(area, imagename, function(ok, savepath)
                ExternalFun.dismissTouchFilter()
                if ok then
                    if bMyFriend then
                        PriRoom:getInstance():getTagLayer(PriRoom.LAYTAG.LAYER_FRIENDLIST, function( frienddata )
                            PriRoom:getInstance():imageShareToFriend(frienddata, savepath, "分享我的约战房战绩")
                        end)
                    elseif nil ~= target then
                        MultiPlatform:getInstance():shareToTarget(target, sharecall, "我的约战房战绩", "分享我的约战房战绩", url, savepath, "true")
                    end            
                end
            end)
        end)
   
     --暂离
     elseif BTN_ZANLI == tag then
         PriRoom:getInstance():getNetFrame()._gameFrame:setEnterAntiCheatRoom(false)                
         PriRoom:getInstance():getNetFrame()._gameFrame:onCloseSocket()
         self._gameLayer:onExitRoom()
   
   end
end

------
-- 继承/覆盖
------
-- 刷新界面
function PriGameLayer:onRefreshInfo()
    -- 房间ID
    self.m_atlasRoomID:setString(PriRoom:getInstance().m_tabPriData.szServerID or "000000")

    -- 局数
    local dwPlayCount = PriRoom:getInstance().m_tabPriData.dwPlayCount
    local dwDrawCountLimit = PriRoom:getInstance().m_tabPriData.dwDrawCountLimit
    local strcount =dwPlayCount .."/".. dwDrawCountLimit
    self.m_atlasCount:setString(strcount)
   
    self:onRefreshInviteBtn()

end

function PriGameLayer:onRefreshInviteBtn()

    if self._gameLayer.m_cbGameStatus ~= 0 then --不是空闲场景
        self.m_btnInvite:setVisible(false)
        return
    end
    -- 邀请按钮
    if nil ~= self._gameLayer.onGetSitUserNum then
        local chairCount = PriRoom:getInstance():getChairCount()
        if self._gameLayer:onGetSitUserNum() >= 2 then
            self.m_btnInvite:setVisible(false)
            return
        end
    end

    self.m_btnInvite:setVisible(true)
end

-- 私人房游戏结束
function PriGameLayer:onPriGameEnd( cmd_table )
 self:removeChildByName("private_end_layer")
    --房卡结算屏蔽层
    self.layoutShield = ccui.Layout:create()
        :setContentSize(cc.size(display.width, display.height))
        :setTouchEnabled(true)
        :addTo(self.m_rootLayer, 100)

    --结算
    local csbNode = ExternalFun.loadCSB("privateroom/PrivateGameOverLayer/PrivateGameOverLayer.csb", self)
    csbNode:setVisible(false)
    csbNode:setLocalZOrder(100)
    csbNode:setName("private_end_layer")

    local Panel_Fixed = csbNode:getChildByName("Panel_Fixed")
    local bg = Panel_Fixed:getChildByName("BG")

    local function btncallback(ref, tType)
        if tType == ccui.TouchEventType.ended then
            self:onButtonClickedEvent(ref:getTag(),ref)
        end
    end

    --大赢家
    local scoreList = cmd_table.lScore[1]
    local nRoomHostIndex = 1
    local scoreListTemp = clone(scoreList)
    table.sort(scoreListTemp)
    local scoreMax = scoreListTemp[#scoreListTemp]

    --全部成绩
    local jsonStr = cjson.encode(scoreList)
    LogAsset:getInstance():logData(jsonStr, true)

    for i = 1, 8 do
        local userItem = self._gameLayer:getUserInfoByChairID(i - 1)
        local nodeUser = bg:getChildByName("User_"..i)
        nodeUser:setVisible(nil ~= userItem)
        if userItem then
            --头像
            local userHead = nodeUser:getChildByName("userHead")
            local Pos =cc.p(userHead:getPosition()) 
	        local head = HeadSprite:createNormal(userItem, 90)
            if nil ~= head then
                   head:setAnchorPoint(cc.p(0.5,0.5))
                   head:setPosition(Pos)
                   nodeUser:addChild(head)
                   userHead:setLocalZOrder(999)
            end
            --昵称
            local textNickname = nodeUser:getChildByName("Text_Name")
                  textNickname:setString(userItem.szNickName)

            --总成绩
            local textGradeTotalNum = nodeUser:getChildByName("Text_GameScore")
                  textGradeTotalNum:setString(scoreList[i])

            --大赢家标志
            local maxWiner = nodeUser:getChildByName("maxWiner") 
            if scoreList[i] == scoreMax and scoreList[i] > 0 then
                 maxWiner:setVisible(true)
            else
                 maxWiner:setVisible(false)
            end
       end
    end
    --关闭按钮
    local btn = Panel_Fixed:getChildByName("Btn_Close")
    btn:setTag(BTN_QUIT)
    btn:addTouchEventListener(btncallback)

    -- 分享按钮
    local btn = Panel_Fixed:getChildByName("Btn_Share")
    btn:setTag(BTN_SHARE)
    btn:addTouchEventListener(btncallback)

    -- 退出按钮
    local btn = Panel_Fixed:getChildByName("Btn_Exit")
    btn:setTag(BTN_QUIT)
    btn:addTouchEventListener(btncallback)

  --  self:setButtonEnabled(false)
    csbNode:runAction(cc.Sequence:create(cc.DelayTime:create(3),
        cc.CallFunc:create(function()
            csbNode:setVisible(true)
        end)))
end

function PriGameLayer:setButtonEnabled(bEnabled)
    self.btSwitch:getChildByTag(BTN_DISMISS):setEnabled(bEnabled)
    self.btSwitch:getChildByTag(BTN_ZANLI):setEnabled(bEnabled)
    self.m_csbNode:getChildByTag(BTN_INVITE):setEnabled(bEnabled)
end

return PriGameLayer