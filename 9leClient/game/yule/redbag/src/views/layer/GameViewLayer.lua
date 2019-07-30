--
-- Author: zhong
-- Date: 2016-11-02 17:28:24
--


    --                    _oo0oo_
    --                   o8888888o
    --                   88" . "88
    --                   (| -_- |)
    --                   0\  =  /0
    --                 ___/`---'\___
    --               .' \\|     |// '.
    --              / \\|||  :  |||// \
    --             / _||||| -:- |||||- \
    --            |   | \\\  -  /// |   |
    --            | \_|  ''\---/''  |_/ |
    --            \  .-\__  '-'  ___/-. /
    --          ___'. .'  /--.--\  `. .'___
    --       ."" '<  `.___\_<|>_/___.' >' "".
    --      | | :  `- \`.;`\ _ /`;.`/ - ` : | |
    --      \  \ `_.   \_ __\ /__ _/   .-` /  /
    --  =====`-.____`.___ \_____/___.-`___.-'=====
    --                    `=---='


    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    --            佛祖保佑         永无BUG


local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local GameChatLayerD = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.game.GameChatLayerD")
local ClipText = appdf.req(appdf.EXTERNAL_SRC .. "ClipText")
local AnimationMgr = appdf.req(appdf.EXTERNAL_SRC .. "AnimationMgr")

local module_pre = "game.yule.redbag.src"
local cmd = appdf.req(module_pre .. ".models.CMD_Game")
local Define = appdf.req(module_pre .. ".models.Define")
local GameRoleItem = appdf.req(module_pre .. ".views.layer.GameRoleItem")
local GameLogic = appdf.req(module_pre .. ".models.GameLogic")
local GameResultLayer = appdf.req(module_pre .. ".views.layer.GameResultLayer")
local SettingLayer = appdf.req(module_pre .. ".views.layer.SettingLayer")
local GameFrameEngine = appdf.req(appdf.CLIENT_SRC.."plaza.models.GameFrameEngine")
local GameNotice = appdf.req(appdf.BASE_SRC .."app.views.layer.other.GameNotice")
local TAG_ENUM = Define.TAG_ENUM
local TAG_ZORDER = Define.TAG_ZORDER

local PopupInfoHead = appdf.EXTERNAL_SRC .. "PopupInfoHead"
local g_var = ExternalFun.req_var
local ChatItem = class("ChatItem", cc.Node)

local GameViewLayer = class("GameViewLayer",function(scene)
        local gameViewLayer = display.newLayer()
    return gameViewLayer
end)

local ZHB_SCORE     = 100

local ZHB_REDCOUNT  = 120

local ZHB_MINECOUNT = 130

local ZHB_CLEAR     =140

local ZHB_SEND      =141

local ZHB_CLOSE     =142

function GameViewLayer:ctor(scene)

    --注册node事件
    ExternalFun.registerNodeEvent(self)
    self._scene = scene
    --初始化
    self:paramInit()

    --排行榜
    self.m_rankInfo     = {}
    self.m_rankHeadSp   = {}
    self.m_rankNick     = {}
    self.m_rankScore    = {}

    --发红包界面
    self.m_laballScore  = nil
    self.m_labredCount  = nil
    self.m_labmineCount = nil
    self.m_btnSendHB    = nil
    self.numAllScore = nil
    self.numRedCount = nil   --默认个数5
    self.numMineCount = nil --默认雷点0
    self.numPeiLv = nil  --默认一倍
    self.LastScore = nil
    self.LastRedCount = nil     --上次包的个数 
    self.LastRedLeiDian = nil 
    --info
    self._tabAllScore = {100000,200000,500000}
    self._tabRedCount = {5,6,7,8,9,10}
    self._tabMineCount = {0,1,2,3,4,5,6,7,8,9}
    self._tabPeiLv     = {2,1.8,1.5,1.3,1.2,1.1}
    --按钮
    self.m_btnallScore = {}
    self.m_btnredCount = {}
    self.m_btnmineCount = {}
    self.m_clearScore  = nil

    --显示分数
    self.m_showScore = GlobalUserItem.lUserScore

    --是否显示菜单层
    self.m_bshowMenu = false
    
    --菜单栏
    self.m_menulayout = nil

    --拆的红包idx
    self.chaiHbKey = nil
    --发送红包记录
    --chairid,wnumber,wpoint,wrate,score
    self.m_MaiLeiIdt = nil
    self.m_tabSendHb = {}
    self.m_tabGameRecord = {}    --红包游戏记录儿
    --红包键表
    self.m_tabHbKey = {}

    --项目扎炸不炸就看你了。
    self.m_tabRedLei = {}
    --中间拆红包选择层 不解释
    --游戏记录
    self.m_RecordList = {}

     --抢包记录
    self.m_RobRecordList = {}

    --红包拆开记录
    self.m_ChaiRecord = {}

    --加载资源
    self:loadResource()
end


function GameViewLayer:registerTouch()

--local function onTouchBegan( touch, event )
--		return self:isVisible()
--	end
--local function onTouchEnded( touch, event )
--		local pos = touch:getLocation();

--    print("fhfjhj")

--	end

--	local listener = cc.EventListenerTouchOneByOne:create();
--	listener:setSwallowTouches(true)
--	self.listener = listener;
--    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN );
--    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED );
--    local eventDispatcher = self:getEventDispatcher();
--    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);

end
function GameViewLayer:paramInit()
   
    self._gameFrame = GameFrameEngine:getInstance()
end

function GameViewLayer:getParentNode()
    return self._scene
end

function GameViewLayer:addToRootLayer( node , zorder)
    if nil == node then
        return
    end

    self.m_rootLayer:addChild(node)
    if type(zorder) == "number" then
        node:setLocalZOrder(zorder)
    end    
end



function GameViewLayer:ShowPage(csbRecordNode,tmp,nindex,bGetInfos)
  if nindex == 0 then 
    -- tmp:setString("仅保留最近50条记录")
     csbRecordNode:getChildByName("Roblistview"):setVisible(false)
     csbRecordNode:getChildByName("ListView_1"):setVisible(true)
     csbRecordNode:getChildByName("btn_chaiRed"):loadTextureNormal("game/btn_tab1-0.png")
     csbRecordNode:getChildByName("btn_chaiRed"):loadTexturePressed("")
     csbRecordNode:getChildByName("btn_chaiRed"):loadTextureDisabled("")
     csbRecordNode:getChildByName("btn_sendRed"):loadTextureNormal("game/btn_tab2-1.png")
     csbRecordNode:getChildByName("btn_sendRed"):loadTexturePressed("")
     csbRecordNode:getChildByName("btn_sendRed"):loadTextureDisabled("")
     if bGetInfos == true then
         --self._scene:RedRecord()
     end
  else
     
    -- self._scene:SendRedRecord()
     ---tmp:setVisible(false)
    -- tmp:setString("仅保留最近30条记录")
     csbRecordNode:getChildByName("Roblistview"):setVisible(true)
     csbRecordNode:getChildByName("ListView_1"):setVisible(false)
     csbRecordNode:getChildByName("btn_chaiRed"):loadTextureNormal("game/btn_tab1-1.png")
     csbRecordNode:getChildByName("btn_chaiRed"):loadTexturePressed("")
     csbRecordNode:getChildByName("btn_chaiRed"):loadTextureDisabled("")
     csbRecordNode:getChildByName("btn_sendRed"):loadTextureNormal("game/btn_tab2-0.png")
     csbRecordNode:getChildByName("btn_sendRed"):loadTexturePressed("")
     csbRecordNode:getChildByName("btn_sendRed"):loadTextureDisabled("")
  end
 end
function GameViewLayer:loadResource()
   
    --播放背景音乐
    ExternalFun.playBackgroudAudio("bgm5.mp3")
    
    local rootLayer, csbNode = ExternalFun.loadRootCSB("game/GameLayer.csb", self)
    self.m_rootLayer = rootLayer
    self.m_csbNode = csbNode
    csbNode:getChildByName("Panel_2")
    :setSwallowTouches(false)
    :addTouchEventListener(function(ref, tType)
       if tType == ccui.TouchEventType.ended then
           print("dfdf")
           --奖励列表
         if self.m_recordLayer ~= nil then
           if  self.m_recordLayer:isVisible() == true then
               self.m_recordLayer:setVisible(false)
           end
         end
        --发红包
        if self.m_sendLayer ~= nil then
            if self.m_sendLayer:isVisible() == true then
            self:clearRed()
            self.m_sendLayer:setVisible(false)
            end
        end
--        if self.layer_Chai ~= nil then
--            if self.layer_Chai:isVisible() == true then
--            self.layer_Chai:setVisible(false)
--            self._btnChai:setVisible(true)
--            end
--        end
--        if self.layer_ChaiOver ~= nil then
--            if self.layer_ChaiOver:isVisible() == true then
--                self.layer_ChaiOver:setVisible(false)
--            end
--        end
--        if self.layer_ChaiRecord ~= nil then
--        if self.layer_ChaiRecord:isVisible() == true  then
--            self.layer_ChaiRecord:setVisible(false)
--        end
--       end
       end
  end)
   -- self:ChaiClone()
    local function btnEvent( sender, eventType )
        if eventType == ccui.TouchEventType.began then
            ExternalFun.popupTouchFilter(1, false)
        elseif eventType == ccui.TouchEventType.canceled then
            ExternalFun.dismissTouchFilter()
        elseif eventType == ccui.TouchEventType.ended then
            ExternalFun.dismissTouchFilter()
            self:onButtonClickedEvent(sender:getTag(), sender)
        end
    end
    
    self._rankArea = csbNode:getChildByName("rank_control")
    self._userInfo = csbNode:getChildByName("info")
    self._btnArea  = csbNode:getChildByName("btn_layout")
    self._chatArea = csbNode:getChildByName("chat_control")
  

    --排行榜
    for i=1,3 do
        self.m_rankInfo[i] = self._rankArea:getChildByName(string.format( "img_top%d",i ))
        self.m_rankInfo[i]:setVisible(false)
--        local head = g_var(PopupInfoHead):createNormal(GlobalUserItem, 68)
--        head:setPosition(self.m_rankInfo[i]:getChildByName(string.format( "top_userhead_%d",i )):getPosition())
--        self.m_rankInfo[i]:addChild(head,-1)

--        self.m_rankHeadSp[i] = head

        self.m_rankNick[i] = self.m_rankInfo[i]:getChildByName(string.format( "top_usernick_%d",i ))
        self.m_rankScore[i] = self.m_rankInfo[i]:getChildByName(string.format( "top_userscore_%d",i ))
    end

    --个人信息
    --self.m_head = self._userInfo:getChildByName("user_head")
    self.m_nick = self._userInfo:getChildByName("label_nick")
    self.m_score = self._userInfo:getChildByName("label_score")

    --按钮
    --战绩
    local btn  = self._btnArea:getChildByName("btn_record")
    btn:setTag(TAG_ENUM.BT_RECORD)
    btn:setSwallowTouches(true)
    btn:addTouchEventListener(btnEvent)

    --发红包
    btn = self._btnArea:getChildByName("btn_sendRed")
    btn:setTag(TAG_ENUM.BT_SENDRED)
    btn:setSwallowTouches(true)
    btn:addTouchEventListener(btnEvent)


    btn = csbNode:getChildByName("btn_menu")
    btn:setTag(TAG_ENUM.BT_MENU)
    btn:setSwallowTouches(true)
    btn:addTouchEventListener(btnEvent)

    --菜单栏
    self.m_menulayout = csbNode:getChildByName("layout_menu")
    self.m_menulayout:retain()
    self.m_menulayout:removeFromParent()
    self:addToRootLayer(self.m_menulayout, TAG_ZORDER.MENU_ZORDER)
    self.m_menulayout:release()
    self.m_menulayout:setScale(1.0, 0.01)
    self.m_menulayout:setVisible(false) 

    local layout_bg = csbNode:getChildByName("img_bg")
    layout_bg:setTouchEnabled(true)
    layout_bg:addClickEventListener(function()
        if self.m_bshowMenu == true then
            self.m_bshowMenu = false
            self.m_menulayout:setVisible(false)
        end
	end)
    
    local btn = self.m_menulayout:getChildByName("btn_help")
    btn:setTag(TAG_ENUM.BT_RULE)
    btn:setSwallowTouches(true)
    btn:addTouchEventListener(btnEvent)

    btn = self.m_menulayout:getChildByName("btn_close")
    btn:setTag(TAG_ENUM.BT_EXIT)
    btn:setSwallowTouches(true)
    btn:addTouchEventListener(btnEvent)
    --游戏核心之重点 老子的listview 保佑
    csbNode:getChildByName("Panel_Admin"):setVisible(false)

   csbNode:getChildByName("Panel_Admin"):getChildByName("Btn_Close"):addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
             csbNode:getChildByName("Panel_Admin"):setVisible(false)
        end
    end) 


    csbNode:getChildByName("Panel_Admin"):getChildByName("Btn_Update"):addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
              self._scene:sendAdmin()
        end
    end) 

    
    local btnAdmin = csbNode:getChildByName("Btn_Admin")
    btnAdmin:setTag(TAG_ENUM.BT_ADMIN)
     local bAdmin=GlobalUserItem.dwUserRight
   if bAdmin ~= 0 then
      btnAdmin:setVisible(true)
   end

   btnAdmin:addTouchEventListener(btnEvent)

    csbNode:getChildByName("Panel_Admin"):setVisible(false)
    self.m_hbTableView = csbNode:getChildByName("ChatHandle")
    local h1 = self.m_hbTableView:getInnerContainerSize().height
    local h2 = 0
    local pos1 = self.m_hbTableView:getInnerContainerPosition().y

    local function scroll_callback(sender, eventType)
        if eventType == 9 then
            if self._isNeedMove then
                h2 = self.m_hbTableView:getInnerContainerSize().height
                self.m_hbTableView:setInnerContainerPosition(cc.p(0, -h2 + (h1 + pos1)))
                self._isNeedMove = false
            end                
        elseif eventType == SCROLLVIEW_EVENT_SCROLLING then
            h1 = self.m_hbTableView:getInnerContainerSize().height
            pos1 = self.m_hbTableView:getInnerContainerPosition().y
        end      
    end

     self.m_hbTableView:addScrollViewEventListener(scroll_callback)
    --更新用户信息

   -- GlobalUserItem.szThirdPartyUrl = "http://thirdwx.qlogo.cn/mmopen/vi_32/PiajxSqBRaEJuZtpjT9evaIhfQ8KDXdiahicshndcSzZELkS0XnhtiaTegEnSbaxCiamJBb4Nib6opUxV2XFjCrYPSOA/132"
    self.m_head = g_var(PopupInfoHead):createNormal(GlobalUserItem, 60)
    self.m_head:setPosition(self._userInfo:getChildByName("user_head"):getPosition())
    self._userInfo:addChild(self.m_head)

    self.m_clipNick = ClipText:createClipText(cc.size(200, 24), GlobalUserItem.szNickName, "fonts/round_body.ttf", 20)
    self:SubNickName(self.m_clipNick,GlobalUserItem.szNickName,12)
    local tmp = self.m_nick
    self.m_clipNick:setPosition(tmp:getPosition())
    self.m_clipNick:setAnchorPoint(tmp:getAnchorPoint())
    self._userInfo:addChild(self.m_clipNick)
    tmp:removeFromParent()

    self:updateUserScore()

    --发红包初始化
    self.m_sendLayer = cc.Node:create()
    self.m_sendLayer:setVisible(false)
    self:addChild(self.m_sendLayer)

    local csbNode1 = ExternalFun.loadCSB("game/SendRed.csb", self.m_sendLayer)
    local csbSendNode  = csbNode1:getChildByName("Panel_1")
	 
	
    local function btnSendEvent( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            ExternalFun.dismissTouchFilter()
            self:onHbSendEvent(sender:getTag(), sender)
        end
    end


    self.m_laballScore = csbSendNode:getChildByName("lab_allScore")
    self.m_labredCount = csbSendNode:getChildByName("lab_redCount")
    self.m_labmineCount= csbSendNode:getChildByName("lab_mineCount")

    self.m_laballScore:setString("") 
    self.m_labredCount:setString("") 
    self.m_labmineCount:setString("")

    for i=1,3 do
        self.m_btnallScore[i] = csbSendNode:getChildByName(string.format("btn_redScore_%d",i))
        self.m_btnallScore[i]:setTag(ZHB_SCORE)
        self.m_btnallScore[i]:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                ExternalFun.dismissTouchFilter()
                --self.LastScore = self._tabAllScore[i]
                self.m_laballScore:setString(self._tabAllScore[i])
                self.numAllScore = self._tabAllScore[i]
            end
        end)        
    end
    
    self.m_clearScore = csbSendNode:getChildByName("btn_clear")
    self.m_clearScore:setTag(ZHB_CLEAR)
    self.m_clearScore:addTouchEventListener(btnSendEvent)  

    for i=1,6 do
        self.m_btnredCount[i] = csbSendNode:getChildByName(string.format( "btn_redCount_%d",i ))
        self.m_btnredCount[i]:setTag(ZHB_REDCOUNT)
        self.m_btnredCount[i]:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                ExternalFun.dismissTouchFilter()
                self.m_labredCount:setString(self._tabRedCount[i])
                self.numRedCount = self._tabRedCount[i]
                self.numPeiLv = self._tabPeiLv[i]
                --self.LastRedCount =self.numRedCount
  
            end
        end) 
    end

    for i=1,10 do
        self.m_btnmineCount[i]= csbSendNode:getChildByName(string.format( "btn_mineCount_%d",i ))
        self.m_btnmineCount[i]:setTag(ZHB_MINECOUNT)
        self.m_btnmineCount[i]:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                ExternalFun.dismissTouchFilter()
                self.m_labmineCount:setString(self._tabMineCount[i])
                self.numMineCount = self._tabMineCount[i]
                --self.LastRedLeiDian = self.numMineCount
            end
        end)   
    end
    --self.LastRedCount = self._tabRedCount[1]
    --self.LastRedLeiDian = self._tabMineCount[1]
    --self.m_labredCount:setString(self._tabRedCount[1])
    --self.m_labmineCount:setString(self._tabMineCount[1])

    self.m_btnSendHB = csbSendNode:getChildByName("btn_ok")
    self.m_btnSendHB:setTag(ZHB_SEND)
    self.m_btnSendHB:addTouchEventListener(btnSendEvent)      

    self.btn_closeHelp = csbSendNode:getChildByName("btn_close")
    self.btn_closeHelp:setTag(ZHB_CLOSE)
    self.btn_closeHelp:addTouchEventListener(btnSendEvent)

    
    --历史记录
    self.m_recordLayer = cc.Node:create()
    self.m_recordLayer:setVisible(false)
    self:addChild(self.m_recordLayer)

    local csbNode2 = ExternalFun.loadCSB("game/GameRecord.csb", self.m_recordLayer)
    local csbRecordNode  = csbNode2:getChildByName("Panel_1")
    self.m_recorNode = csbRecordNode
    csbRecordNode:setSwallowTouches(false)
    csbRecordNode:getChildByName("Image_1"):setSwallowTouches(true)
    csbRecordNode:getChildByName("Image_1"):setTouchEnabled(true)
   

    --头像
    local sp1 = csbRecordNode:getChildByName("sp_head")
    :setVisible(false)

    local recordHead = g_var(PopupInfoHead):createClipHead(GlobalUserItem, 72)
    recordHead:setPosition(335,666)
    csbRecordNode:addChild(recordHead)
    --记录
    local labcunt = ClipText:createClipText(cc.size(200, 24), "仅保留最近30条记录", "fonts/round_body.ttf", 18)
    local tmp = csbRecordNode:getChildByName("lab_recordCount")
    labcunt:setTextColor(cc.c3b(102,102,102))
    labcunt:setPosition(tmp:getPosition())
    labcunt:setAnchorPoint(tmp:getAnchorPoint())
    csbRecordNode:addChild(labcunt)
    tmp:removeFromParent()

     --拆红包记录
    self.m_recorNode:getChildByName("btn_chaiRed"):addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            ExternalFun.dismissTouchFilter()
            self:ShowPage(csbRecordNode,labcunt,0,true)
        end
    end)


    --发红包记录
    self.m_recorNode:getChildByName("btn_sendRed"):addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
           self:ShowPage(csbRecordNode,labcunt,1,true)
        end
    end)

    self:ShowPage(csbRecordNode,labcunt,0,false)

    local btnCloseRecord = csbRecordNode:getChildByName("btn_close")
    btnCloseRecord:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            ExternalFun.dismissTouchFilter()
            if nil ~= self.m_recordLayer then
                self.m_recordLayer:setVisible(false)
                --self:addRecord()
            end
        end
    end)

    self.m_recordListView = csbRecordNode:getChildByName("ListView_1")
    self.m_robListView    = csbRecordNode:getChildByName("Roblistview")
    self.m_robListView:setItemsMargin(30)
    self.m_recordListView:setItemsMargin(30)
   -- setItemsMargin

--    self.m_robListView:addEventListener(function(pSender, typeDer)
--      if typeDer == ON_SELECTED_ITEM_END then
--		 local item = pSender:getItem(listView:getCurSelectedIndex())
--         local variable =item:getnam ;
--      end
--    end)
    self.m_robListView:setScrollBarEnabled(false)
    self.m_recordListView:setScrollBarEnabled(false)
    self:loadListView()

    ----
    --拆红包界面
    self.m_getHbLayer = cc.Node:create()
    self.m_getHbLayer:setVisible(false)
    self:addChild(self.m_getHbLayer)

    local csbNode3 = ExternalFun.loadCSB("game/GetRedBag.csb", self.m_getHbLayer)
    self.layer_Chai        = csbNode3:getChildByName("Panel_1")
    :setVisible(false)
    self.layer_ChaiOver    = csbNode3:getChildByName("Panel_2")
    :setVisible(false)
    self.layer_ChaiRecord  = csbNode3:getChildByName("Panel_3")
    :setVisible(false)

--拆除记录
    self.layer_diffRecord  = self.layer_ChaiRecord:clone()
    local jbicon = cc.Sprite:create("game/jbsico.png")
    :setPosition(cc.p(699.52,466.73))
    jbicon:setName("Sprite_3")
    jbicon:setScale(0.6)
    self.layer_diffRecord:addChild(jbicon)

    local recordHead3 = nil 
    recordHead3 = g_var(PopupInfoHead):createClipHead(GlobalUserItem, 72)

    recordHead3:setPosition(667,620)
    self.layer_diffRecord:addChild(recordHead3)
    --昵称
     self.layer_diffRecord:getChildByName("lab_nick")
     self:SubNickName(self.layer_diffRecord:getChildByName("lab_nick"),GlobalUserItem.szNickName,12)
     self.layer_diffRecord:setVisible(false)
     csbRecordNode:addChild(self.layer_diffRecord)
           self.layer_diffRecord:getChildByName("btn_close"):addClickEventListener(function (  )
           self.layer_diffRecord:setVisible(false)
        end)
   
     self.layer_Chai:setSwallowTouches(true)
     self.layer_ChaiOver:setSwallowTouches(true)
     self.layer_ChaiRecord:setSwallowTouches(true)


 
--      self.layer_Chai:addTouchEventListener(function(ref, tType)
--            if tType == ccui.TouchEventType.ended then
--               print("sdsd");
--            end
--       end)

--        self.layer_ChaiOver:addTouchEventListener(function(ref, tType)
--            if tType == ccui.TouchEventType.ended then
--               print("sdsd");
--            end
--       end)

--        self.layer_ChaiRecord:addTouchEventListener(function(ref, tType)
--            if tType == ccui.TouchEventType.ended then
--               print("sdsd");
--            end
--       end)


    self.leftLingX  = self.layer_ChaiRecord:getChildByName("curLingq"):getPositionX()
    self.RightLingX = self.layer_ChaiRecord:getChildByName("Zonglingqu"):getPositionX()
    self.RightLingX=self.RightLingX+1
    self.SpaceX     = self.layer_ChaiRecord:getChildByName("lab_getInfo_0_0"):getPositionX()
    self.SpaceX = self.SpaceX+1

   -- self.CurIcoX =  self.layer_ChaiRecord:getChildByName("Sprite_3"):getPositionX()

    --三层的头像
    -- local recordHead = g_var(PopupInfoHead):createClipHead(GlobalUserItem, 63)
    -- recordHead:setPosition(667,608)
    -- self.layer_Chai:addChild(recordHead)

    -- local recordHead2 = g_var(PopupInfoHead):createClipHead(GlobalUserItem, 63)
    -- recordHead2:setPosition(667,608)
    -- self.layer_ChaiOver:addChild(recordHead2)

    -- local recordHead3 = g_var(PopupInfoHead):createClipHead(GlobalUserItem, 63)
    -- recordHead3:setPosition(667,608)
    -- self.layer_ChaiRecord:addChild(recordHead3)

    --三层的昵称
    self.tabNick = {}
    self.tabNick[1] = self.layer_Chai:getChildByName("lab_nick")
    self.tabNick[2] = self.layer_ChaiOver:getChildByName("lab_nick")
    self.tabNick[3] = self.layer_ChaiRecord:getChildByName("lab_nick")

    --三层关闭
    self.tabClose = {}
    self.tabClose[1] = self.layer_Chai:getChildByName("btn_close")
    self.tabClose[2] = self.layer_ChaiOver:getChildByName("btn_close")
    self.tabClose[3] = self.layer_ChaiRecord:getChildByName("btn_close")
    for i=1,3 do
        self.tabClose[i]:addClickEventListener(function (  )
            if nil ~= self.m_getHbLayer then
                self.m_getHbLayer:setVisible(false)
                self.layer_Chai:setVisible(false)
                self._btnChai:setVisible(true)
                self.layer_ChaiOver:setVisible(false)
                self.layer_ChaiRecord:setVisible(false)
			end
        end)
    end
    --两层的msg
    self.tabHbmsg = {}
    self.tabHbmsg[1] = self.layer_Chai:getChildByName("lab_hbmsg")
    self.tabHbmsg[2] = self.layer_ChaiRecord:getChildByName("lab_hbmsg")
    --第一层
    self._btnChai = self.layer_Chai:getChildByName("btn_chai")
    self._ScrentAnime = self.layer_Chai:getChildByName("Anime_Image")
    self._btnChai:addClickEventListener(function()
        self:ChaiHongbao()
    end)

    --第二层
    self.lab_Chaimsg = self.layer_ChaiOver:getChildByName("lab_gamover")
    self.lab_Chaimsg:setString("手慢了,红包拆完了")

    self.btn_showRecord = self.layer_ChaiOver:getChildByName("btn_showRecord")
    self.btn_showRecord:addClickEventListener(function (  )
        print("查看拆开记录" .. "show 第三层")
        self:showChaiRecord()
        -- self.layer_ChaiOver:setVisible(false)
        -- self.layer_ChaiRecord:setVisible(true)
    end)

    --第三层
    self.lab_getInfo = self.layer_ChaiRecord:getChildByName("lab_getInfo")
    self.lab_getScore= self.layer_ChaiRecord:getChildByName("lab_getScore")
    --领取红包list
    self.m_getHbListview = self.layer_ChaiRecord:getChildByName("ListView_1")
    self.m_recordListView:setScrollBarEnabled(false)
    self:loadGetListView()

    --自定义消息
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    --游戏 记录
	eventDispatcher:addEventListenerWithSceneGraphPriority(
        cc.EventListenerCustom:create("ry_GetMineIdent", handler(self, self.GameRedRecord)),
        self
        )


         --游戏详细记录
	eventDispatcher:addEventListenerWithSceneGraphPriority(
        cc.EventListenerCustom:create("detailed_GetMineIdent", handler(self, self.Gamedetailed)),
        self
        )


        --发包游戏 记录
	eventDispatcher:addEventListenerWithSceneGraphPriority(
        cc.EventListenerCustom:create("snedry_GetMineIdent", handler(self, self.GameSendRedRecord)),
        self
        )
    self:registerTouch()

end

--克隆模式
function GameViewLayer:ChaiClone( )
--670, 375
--    self.tempChaiImage = cc.Sprite:create("game/bHb1.png")
--    :setPosition(cc.p(670, 375))
--    local kaiImage = cc.Sprite:create("game/Btn_kai.png")
--    :setPosition(cc.p(230, 188))
--    local tempChaiX = cc.Sprite:create("game/btn_x.png")
--    :setPosition(cc.p(430, 584))
----    local recordHead = g_var(PopupInfoHead):createClipHead(GlobalUserItem, 63)
----    recordHead:setPosition(225,536)
----    recordHead:setTag(1)
--    --昵称
--    local labUserNick = ccui.Text:create("刘德华", "fonts/round_body.ttf", 24)
--    labUserNick:setColor(cc.c3b(255, 255, 255))
--    labUserNick:setTag(2)
--   -- labUserNick:setAnchorPoint(cc.p(0, 0))
--    labUserNick:setPosition(cc.p(223, 473))
--    local labRed= ccui.Text:create("的游戏红包", "fonts/round_body.ttf", 17)
--    labRed:setColor(cc.c3b(255, 212, 188))
--    labRed:setAnchorPoint(cc.p(0, 0.5))
--    labRed:setPosition(cc.p(176, 440))
--    local labRedInfo= ccui.Text:create("红包信息", "fonts/round_body.ttf", 32)
--    labRedInfo:setColor(cc.c3b(255, 245, 78))
--    labRedInfo:setAnchorPoint(cc.p(0.5, 0.5))
--    labRedInfo:setPosition(cc.p(223, 375))
--    labRedInfo:setTag(3)

--    self.tempChaiImage:addChild(labRedInfo)
--    self.tempChaiImage:addChild(labRed)
--    self.tempChaiImage:addChild(labUserNick)
--    self.tempChaiImage:addChild(tempChaiX)
--    self.tempChaiImage:addChild(kaiImage)
--    self.m_csbNode:addChild(self.tempChaiImage)
--    self.tempChaiImage:setVisible(false);
end

--如果当前包儿没抢完不能离开，不然后果自负
--场景消息
function GameViewLayer:bOverGame()

    local bQuitGame = true
    for i=1, #self.m_tabHbKey do 
         if self.m_tabSendHb[self.m_tabHbKey[i]].wGameID == GlobalUserItem.dwGameID then
            local RedLayer = self:GetHongItem(self.m_tabHbKey[i],1)
             if   RedLayer ~= nil then
                  if RedLayer:getChildByName("hongbaoer"):getTag() == 0 then
                    bQuitGame = false
                    break;
                  end
            end
        end
   end
     return bQuitGame
end
function GameViewLayer:SetSceneRed(dataBuffer)
    
    --偏移8个字节别问我什么

    --dump(dataBuffer)
    local count1 = dataBuffer["wRobotsend"]
    local count2 = dataBuffer["wRobotgrab"]
    local count3 = dataBuffer["wSendprobability"]
    local count4 = dataBuffer["wRobprobability"]
 
    local Moneyonestr =     dataBuffer["moneyone"]
    local moneytwostr =     dataBuffer["moneytwo"]
    local moneythreestr =   dataBuffer["moneyThree"]
    local nRedCount =       #(dataBuffer["StatusFree"])
    local curRedCount =     nRedCount
    local tab_tmp = {}
    for i=1,nRedCount do            
        tab_tmp[i] =        dataBuffer["StatusFree"][i]
    end
    --设置红包
    self._tabAllScore[1] = Moneyonestr
    self._tabAllScore[2] = moneytwostr
    self._tabAllScore[3] = moneythreestr
    for i=1,3 do
    local lBitScore = self._tabAllScore[i]/10000 
        lBitScore = lBitScore.."万"
        self.m_btnallScore[i]:setTitleText(lBitScore)
    end
    for i =#tab_tmp, 1,-1 do
        local t1 = tab_tmp[i][7]    
        if tab_tmp[i][8] == 1 then
            tab_tmp[i][8] = true
        else
            tab_tmp[i][8] = false 
        end       

        if tab_tmp[i][9] == 1  then
            tab_tmp[i][9] = true
        else
            tab_tmp[i][9] = false
        end
        local t2 = {szUserID = tab_tmp[i][12], strUrl = tab_tmp[i][11], wGameID = tab_tmp[i][10],
        wComplete=tab_tmp[i][9], wFaceID= tab_tmp[i][4],nickName =tab_tmp[i][1], 
        chairid =1,number = tab_tmp[i][2],point = tab_tmp[i][3],rate = tab_tmp[i][5],
        score = tab_tmp[i][6] ,bMeChia = tab_tmp[i][8]}
        table.insert(self.m_tabHbKey, 1 ,t1)
        self.m_tabSendHb[t1] = t2
        print("打印回调的红包")
        
        --就是我改的 添加 进红包
        self:InitHongbao(self.m_tabSendHb[t1],t1,1)
        --添加中雷儿信息
       
        for k=1,10 do 
            if tab_tmp[i][13][k]== ""  or tab_tmp[i][13][k]== nil  then
                break;
            else
                local cmd_table ={}
                cmd_table["szUserName"] = tab_tmp[i][13][k]
                local HongBaoItem = self:GetHongItem(tab_tmp[i][7],1)
                if HongBaoItem ~= nil then
                --有人拆雷的话 我就全部重新刷新不管了哇！
                 self:SetRedInfo(HongBaoItem,cmd_table)
                end
            end
        end
end
   --游动坐标子
--    local lSubRedCount = 5 - nRedCount
--    if lSubRedCount>0 then
--      for i=1 , lSubRedCount do
--          ExternalFun.read_netdata(cmd.CMD_S_StatusFree,dataBuffer)
--      end
--    end
   --排行榜
    local movewRedCount = #dataBuffer["wRanKing"]
 
    for i=1,movewRedCount do            
        tab_tmp[i] = dataBuffer["wRanKing"][i]
        self.m_rankInfo[i]:setVisible(true)
          local CurTheUserIte = {}
          CurTheUserIte.dwUserID = tab_tmp[i][3]
          CurTheUserIte.szThirdPartyUrl = tab_tmp[i][5]
          CurTheUserIte.dwCustomID = 0
          CurTheUserIte.cbMemberOrder = 0
          head= g_var(PopupInfoHead):createNormal(CurTheUserIte, 68)
      if CurTheUserIte.szThirdPartyUrl  ==""  or CurTheUserIte.szThirdPartyUrl ==  nil  then
          head:updateHead({ wFaceID = tab_tmp[i][2] })
      end
        head:setPosition(self.m_rankInfo[i]:getChildByName(string.format( "top_userhead_%d",i )):getPosition())
        self.m_rankInfo[i]:addChild(head,-1)
        self.m_rankHeadSp[i] = head
        self:SubNickName(self.m_rankNick[i],tab_tmp[i][4],6)
        local Condition = tab_tmp[i][1]
        local str = tostring(tab_tmp[i][1]).."万"
	    if Condition > 9999  and Condition < 99999999 then
		    str = tostring(Condition / 10000).."万"
	    elseif Condition > 99999999 then
		    str = tostring(Condition / 100000000).."亿"
	    end
            self.m_rankScore[i]:setString(str)
        end


--    -- RedInfo.szUserName
--     --添加中雷信息用户！

--         local HongBaoItem = self:GetHongItem(cmd_table.zIdentifier,1)
--        if HongBaoItem ~= nil then
--           --有人拆雷的话 我就全部重新刷新不管了哇！
--             self:SetRedInfo(HongBaoItem,cmd_table)
--        end


end
--领取完成
function GameViewLayer:RedLingOver( data )

    local RedKey = data:readdword()
    local RedLayer = self:GetHongItem(RedKey,1)
    if RedLayer ~= nil then
        if RedLayer:getChildByName("hongbaoer") ~= nil then
           -- RedLayer:setVisible(false)
            RedLayer:getChildByName("hongbaoer"):setTag(1)
            RedLayer:getChildByName("hongbaoer"):loadTextureNormal("game/fhbBG_1.png")
            RedLayer:getChildByName("hongbaoer"):getChildByName("chaiStatus"):setString("红包已拆完")
            --self.m_tabSendHb[RedKey].bMeChia
        end
    end
end
function GameViewLayer:MaiLeiCallBack( event )
    print("第二次发送红包")
    local bsuc = event._usedata["Mine_suc"]
    if bsuc == true then
        self.m_MaiLeiIdt = event._usedata["Mine_Ident"]
        print(self.m_MaiLeiIdt)
       -- self._scene:SendRedPacket(self.numRedCount,self.numMineCount,self.numPeiLv,self.numAllScore,self.m_MaiLeiIdt)
    else
        showToast(self,"发送红包失败",2)
        return
    end
end
--游戏记录
function GameViewLayer:GameRedRecord( dataBuffer )
    --local dataBuffer = event._usedata["Mine_suc"]
    local count = #dataBuffer
    local tab_tmp = {}
    self.m_RecordList = {} 
    self.m_recordListView:removeAllItems()
    for i=1,count do 
                 
       self.m_RecordList[i] = dataBuffer[i]
    end
 if nil ~=self.m_recordLayer then
     self.m_recordLayer:setVisible(true)
      self:loadListView()
   end
   
end



--游戏记录
function GameViewLayer:Gamedetailed( event )
    local dataBuffer = event._usedata["Mine_suc"]
    local count = dataBuffer:readbyte()
    self.layer_diffRecord:getChildByName("ListView_1"):removeAllItems()
    local RecordList={}
    for i=1,count do            
       RecordList[i] = ExternalFun.read_netdata(cmd.CMD_GR_UserDismanhongRed,dataBuffer)
    end
    if count == 1 then
        self.layer_diffRecord:setVisible(true)
        return 
    end


    local wGetNumber = RecordList[1].wGetNumber
    local wTotalNumber = RecordList[1].wTotalNumber
    local wGetmoney = RecordList[1].wGetmoney
    local wTotalmoney = RecordList[1].wTotalmoney


    self.layer_diffRecord:getChildByName("curLingq"):setString(tostring(wGetNumber))
    self.layer_diffRecord:getChildByName("Zonglingqu"):setString(tostring(wTotalNumber))
    local curLingCount = self.layer_diffRecord:getChildByName("curLingq"):getPositionX()
    local lingwinth = self.layer_diffRecord:getChildByName("curLingq"):getContentSize().width
    curLingCount = curLingCount+lingwinth+1
    self.layer_diffRecord:getChildByName("lab_getInfo_0_0"):setPositionX(curLingCount)
    local spacBit = self.layer_diffRecord:getChildByName("lab_getInfo_0_0"):getPositionX()
    local spaceWinth = self.layer_diffRecord:getChildByName("lab_getInfo_0_0"):getContentSize().width
    spacBit = spacBit+spaceWinth+1
    self.layer_diffRecord:getChildByName("Zonglingqu"):setPositionX(spacBit)


    local lScoretext = self.layer_diffRecord:getChildByName("lab_getScore")
    lScoretext:setString(""..ExternalFun.numberThousands(wGetmoney) .. "/" .. ExternalFun.numberThousands(wTotalmoney))

    local aaa =  lScoretext:getContentSize().width
    local abc = lScoretext:getPositionX()
    abc = abc - aaa-10
    self.layer_diffRecord:getChildByName("Sprite_3"):setPositionX(abc)
    self.layer_diffRecord:getChildByName("lab_hbmsg"):setString(self.redMes)

    for i=2,#RecordList do
        


--    {k = "wGetNumber",      t = "word"},	        --已经拆个数
--    {k = "wTotalNumber",    t = "word"},	        --总雷个数
--    {k = "wGetmoney",       t = "int"},	            --已经被拆金额
--    {k = "wTotalmoney",     t = "score"},	        --总金额
--    {k = "szUserName",      t = "string", s = 32},  --用户名称
--    {k = "wThunder",        t = "word"},	        --是否中雷0-1
--    {k = "wWinmoney",       t = "score"},           --拆雷金额
--    {k = "wTime",           t = "string" ,s = 32},  --拆雷时间
--    {k = "wFaceID",         t = "word"},            --头像ID
--    {k = "wGameID",         t = "dword"},			--用户标识
--    {k = "wHand",           t = "word"},			--手气最佳
--    {k = "wFaceAddressp",   t = "string", s = 256}, --头像地址


        local itemInfo = RecordList[i]

        local listItem = ccui.Layout:create()
        listItem:setContentSize(700,75)
        local CurTheUserIte = {}
        CurTheUserIte.dwUserID = GlobalUserItem.dwUserID
        CurTheUserIte.dwCustomID = 0
        CurTheUserIte.cbMemberOrder = 0
        CurTheUserIte.szThirdPartyUrl = itemInfo.wFaceAddressp
        local itemHead = g_var(PopupInfoHead):createNormal(CurTheUserIte, 52)
        if CurTheUserIte.szThirdPartyUrl == nil or CurTheUserIte.szThirdPartyUrl == "" then
            itemHead:updateHead({ wFaceID = itemInfo.wFaceID})
        end

        itemHead:setPosition(35,30)
        listItem:addChild(itemHead)

        local itemnick = ccui.Text:create(itemInfo.szUserName,"fonts/round_body.ttf",20)
        :setAnchorPoint(cc.p(0,0.5))
        :setTextColor(cc.c3b(0,0,0))
        :setPosition(cc.p(72,44))
        :addTo(listItem)
        self:SubNickName(itemnick,itemInfo.szUserName,12)

        local time = ccui.Text:create(itemInfo.wTime,"fonts/round_body.ttf",16)
        :setAnchorPoint(cc.p(0,0.5))
        :setTextColor(cc.c3b(187,187,187))
        :setPosition(cc.p(72,15))
        :addTo(listItem)

        if itemInfo.wThunder == 1 then
            local zhongicon = cc.Sprite:create("game/ico_zl.png")
            :setPosition(cc.p(250,45))
            :addTo(listItem)
        end


        --许仙
         local xuLine = cc.Sprite:create("game/xu.png")
            :setPosition(cc.p(160,-5))
            :addTo(listItem)

        local jbicon = cc.Sprite:create("game/jbsico.png")
        :setPosition(cc.p(322,44))
        :addTo(listItem)

        local score = ccui.Text:create(itemInfo.wWinmoney,"fonts/round_body.ttf",20)
        :setAnchorPoint(cc.p(0,0.5))
        :setTextColor(cc.c3b(0,0,0))
        :setPosition(cc.p(331,44))
        :addTo(listItem)
        --最佳手气王
        if itemInfo.wHand == 1 then 
            local zhongicon = cc.Sprite:create("game/sqzj.png")
            :setPosition(cc.p(354,16))
            :addTo(listItem)
        end

         self.layer_diffRecord:getChildByName("ListView_1"):pushBackCustomItem(listItem) 
    end

    self.layer_diffRecord:setVisible(true)
 
end

--发包游戏记录
function GameViewLayer:GameSendRedRecord( dataBuffer )

    dump(dataBuffer)
    local count = #dataBuffer
    local tab_tmp = {}
    self.m_robListView:removeAllItems()
    for i=1,count do            
        self.m_RobRecordList[i] = dataBuffer[i]
    end
 if nil ~=self.m_recordLayer then
     self.m_recordLayer:setVisible(true)
       self:RobListView()
   end
   
end

function GameViewLayer:ChaiHongbao(  )

    if nil ~= self.chaiHbKey then
    if self.m_tabSendHb[self.chaiHbKey] ~= nil then
        if self.m_tabSendHb[self.chaiHbKey].rate*self.m_tabSendHb[self.chaiHbKey].score>self.m_showScore then
            showToast(self,"亲，你身上的金币不够领取该红包！",2)
            return 
        end
    end
    --隐藏当前按钮
    self._btnChai:setVisible(false)
    self._ScrentAnime:setVisible(true)
    self._scene:SendChaiHongBao(self.chaiHbKey)
end
			
end

function GameViewLayer:ShowChaiHbSecond(  )
    self.m_getHbLayer:setVisible(true)
    self.layer_Chai:setVisible(false)
    self._btnChai:setVisible(true)
    self.layer_ChaiOver:setVisible(true)
    self.layer_ChaiRecord:setVisible(false)

    --拆完
    self.lab_Chaimsg:setString("手慢了,红包拆完了")
    --没拆完
    self.lab_Chaimsg:setString("多少钱")

end

function GameViewLayer:showChaiRecord(  )

--        self.m_getHbLayer:setVisible(true)
--        self.layer_ChaiRecord:setVisible(true)
--        self.layer_ChaiOver:setVisible(false)
--        self.layer_Chai:setVisible(false)
       self._scene:SendChaiHongBao(self.chaiHbKey)
end


    --指定红包显示中雷信息
function GameViewLayer:ZhongLeiChaiHbThird( dataBuffer )
    --我最怕我最怕 烟雨蒙蒙
    local cmd_table = ExternalFun.read_netdata(cmd.Send_S_UserInmine, dataBuffer)
    print("有人中雷啊啊啊啊啊啊啊啊啊啊啊啊")
    dump(cmd_table)
    if self.m_tabSendHb[cmd_table.zIdentifier] == nil then
       return 
    end
    if  GlobalUserItem.dwGameID == self.m_tabSendHb[cmd_table.zIdentifier].wGameID then
        if GlobalUserItem.dwGameID ~=cmd_table.wGameID then
            self.m_showScore = self.m_showScore+self.m_tabSendHb[cmd_table.zIdentifier].rate*self.m_tabSendHb[cmd_table.zIdentifier].score
            self:updateUserScore()
            print(self.m_showScore)
        end
    end

    --如果包儿不是自己的 中雷的话我就要扣钱哦
    if GlobalUserItem.dwGameID == cmd_table.wGameID then
       if  GlobalUserItem.dwGameID ~= self.m_tabSendHb[cmd_table.zIdentifier].wGameID then
           self.m_showScore = self.m_showScore-self.m_tabSendHb[cmd_table.zIdentifier].rate*self.m_tabSendHb[cmd_table.zIdentifier].score
           self:updateUserScore()
       end
    end

    if self.m_tabSendHb[cmd_table.zIdentifier]  ~= nil then
        local HongBaoItem = self:GetHongItem(cmd_table.zIdentifier,1)
        if HongBaoItem ~= nil then
           --有人拆雷的话 我就全部重新刷新不管了哇！

           if GlobalUserItem.dwGameID ==cmd_table.wGameID then
               ExternalFun.playSoundEffect("zhonglei.mp3")
           end
            --延迟
              self:runAction(cc.Sequence:create(cc.DelayTime:create(0.8), cc.CallFunc:create(function()
       
                        self:SetRedInfo(HongBaoItem,cmd_table)
                   end)))

            
        end
    end
end

function GameViewLayer:AdminList(data)
    
     --信息初始化  和往表里查数据 并且刷新表

    local count = data:readbyte()
    local tab_tmp = {}

    local listUser = self.m_csbNode:getChildByName("Panel_Admin"):getChildByName("ollUser_list")

    listUser:removeAllItems()
    for i=1,count do            
     tab_tmp[i] = ExternalFun.read_netdata(cmd.CMD_S_RedControl,data)
    --设置刷新数据
     self.m_csbNode:getChildByName("Panel_Admin"):getChildByName("Text_5_0"):setString(tostring(count))
     local pperuserList = self.m_csbNode:getChildByName("Panel_Admin"):getChildByName("Panel_Cloe"):clone()
     pperuserList:setName(tostring(tab_tmp[i].cbGameID))
     pperuserList:setVisible(true)
     pperuserList:getChildByName("Text_Game"):setString(tostring(tab_tmp[i].cbGameID))
     pperuserList:getChildByName("Text_Nick"):setString("123")
     self:SubNickName(pperuserList:getChildByName("Text_Nick"),tab_tmp[i].cbUserName,12)
     pperuserList:getChildByName("Text_WinScore"):setString(tostring(tab_tmp[i].cbWinmoery))

    local editRedBox = ccui.EditBox:create(cc.size(200, 80), "0")
	:move(1005,20)
    :setFontSize(36)
    :setFontColor(cc.BLACK)
	:setFontName("fonts/round_body.ttf")
	:setMaxLength(18)
    editRedBox:setTag(0)
    local Redholder = cc.Node:create()
    Redholder:setTag(0)
    Redholder:setName(tostring(tab_tmp[i].cbGameID))
    editRedBox:addChild(Redholder)
    editRedBox:setText(tostring(tab_tmp[i].cbSendporery))
    editRedBox:registerScriptEditBoxHandler(function(eventname,sender) self:editboxEventHandler(eventname,sender) end)
    pperuserList:addChild(editRedBox)
   


    local editEndporeryBox = ccui.EditBox:create(cc.size(200, 80), "0")
    editEndporeryBox:setTag(1)
	:move(1300,20)
    :setFontSize(36)
    :setFontColor(cc.BLACK)
	:setFontName("fonts/round_body.ttf")
	:setMaxLength(18)
     local Caiholder = cc.Node:create()
     Caiholder:setTag(0)
     Caiholder:setName(tostring(tab_tmp[i].cbGameID))
     editEndporeryBox:addChild(Caiholder)
     editEndporeryBox:setText(tostring(tab_tmp[i].cbEndporery))
     editEndporeryBox:registerScriptEditBoxHandler(function(eventname,sender) self:editboxEventHandler(eventname,sender) end)
     pperuserList:addChild(editEndporeryBox)
    
     listUser:pushBackCustomItem(pperuserList)
    end

end




function GameViewLayer:editboxEventHandler(eventType,sender)
   

     if eventType == "began" then
        -- 点击编辑框,输入法显示
        print("点击编辑框")
    elseif eventType == "ended" then
         -- 当编辑框失去焦点并且键盘消失的时候被调用
        print("当编辑框失去焦点并且键盘消失的时候被调用")
    elseif eventType == "changed" then
        -- 输入内容改变时调用
       -- local str = ExternalFun.numberTransiform(sender:getText())
      --  print(str)
      --  self._Capital:setString(str)
        printf("输入内容改变时调用")
    elseif eventType == "return" then
       
       local strUseGameID =  sender:getChildByTag(0):getName()
       UserPlater = self:GetUserGame(strUseGameID)
       if UserPlater ~= nil then
           local RedBit = UserPlater:getChildByTag(0):getText()
           self._scene:setRedBitInfo(tonumber(sender:getChildByTag(0):getName()),UserPlater:getChildByTag(0):getText(),UserPlater:getChildByTag(1):getText())
       end

    end


end
function GameViewLayer:GetUserGame(gameID)

    local listUser = self.m_csbNode:getChildByName("Panel_Admin"):getChildByName("ollUser_list")
    for i=1, listUser:getChildrenCount() do
    local  RedEnvelopes = listUser:getItem(i-1)
    if RedEnvelopes ~= nil then
       if RedEnvelopes:getName() == gameID then
          return RedEnvelopes
       end
    end
end 
    return nil 
end

--获取指定的红包ITEM
function GameViewLayer:GetHongItem(key, ntype)

    for i=1, self.m_hbTableView:getChildrenCount() do
    local  RedEnvelopes = self.m_hbTableView:getItem(i-1)
        if RedEnvelopes ~= nil then
              if RedEnvelopes:getName() == tostring(key) then
                 if ntype == 0 then
                    return i-1
                 else 
                     return RedEnvelopes
                 end

             end
        end
   end

   if ntype == 0 then
        return -1
    else 
        return nil 
   end
end



function GameViewLayer:SubNickName(ContorNick,strNick,nstrCount)
    --昵称判断不大于12个字符长度
	local signstrtable = ExternalFun.utf8StringSplit(strNick)
    local signstr = ""
    local signlen = 1
    for i = 1, #signstrtable do
        if signlen > nstrCount then
            break
        end
        local str = signstrtable[i]
        local dropping = string.byte(str)
        if dropping >= 128 then
            signlen = signlen + 2
        else
            signlen = signlen + 1
        end
        signstr = signstr..str
    end
    print(signlen)
    if signlen > nstrCount then
        signstr = signstr.."..."
    end
  ContorNick:setString(signstr)

  return signstr

end

function GameViewLayer:addMineInfo(moveRed,RedInfo)
    
    
    --有相同的中雷的包不处理
    local itemBed = moveRed:getChildByName("hongbaoer"):getChildByName(RedInfo.szUserName)
    if itemBed ~= nil then
       return ;
    end
    local RedLayer = moveRed:getContentSize()--.height
    RedLayer.height =RedLayer.height+32
    moveRed:setContentSize(RedLayer)
    local RedBtn = moveRed:getChildByName("hongbaoer"):getPositionY()+32
    moveRed:getChildByName("hongbaoer"):setPositionY(RedBtn)
    local zhongicon = cc.Sprite:create("game/ico_q.png")
    :setAnchorPoint(cc.p(0, 1))
    :setPosition(cc.p(40,-20-(moveRed:getTag()*32)))
    local labUserNick = ccui.Text:create(RedInfo.szUserName, "fonts/round_body.ttf", 19)
    labUserNick:setName(RedInfo.szUserName)
    labUserNick:setColor(cc.c3b(255, 255, 0))
    labUserNick:setAnchorPoint(cc.p(0, 1))
    labUserNick:setPosition(cc.p(85, -21 -(moveRed:getTag()*32)))
    self:SubNickName(labUserNick,RedInfo.szUserName,12)
    local zhongSign = cc.Sprite:create("game/ico_zl.png")
    :setAnchorPoint(cc.p(0, 1))
    :setPosition(cc.p(235, -15 -(moveRed:getTag()*32)))
    moveRed:getChildByName("hongbaoer"):addChild(zhongicon)
    moveRed:getChildByName("hongbaoer"):addChild(labUserNick)
    moveRed:getChildByName("hongbaoer"):addChild(zhongSign)
    self.m_hbTableView:requestDoLayout()
    self._isNeedMove = self:isNeedMove()
    moveRed:setTag( moveRed:getTag()+1)
end

--添加中雷
function GameViewLayer:SetRedInfo(RedEnvelopes,RedInfo)
    --dump(RedEnvelopes)
    --dump(RedInfo)
     local Key =  tonumber(RedEnvelopes:getName())
     local moveIndex = self:GetHongItem(Key,1)
     if moveIndex ~= nil then
        self:addMineInfo(moveIndex,RedInfo)
     end
end
--添加红包信息
function GameViewLayer:SetInMine(RedEnvelopes, RedInfo )

    local RedCount = RedEnvelopes:getTag()

    local zhongicon = cc.Sprite:create("game/ico_q.png")
    :setPosition(cc.p(40,-30+(RedCount*-30)))
    local labUserNick = ccui.Text:create(RedInfo.szUserName, "fonts/round_body.ttf", 19)
    labUserNick:setColor(cc.c3b(255, 255, 0))
    labUserNick:setAnchorPoint(cc.p(0, 0.5))
    labUserNick:setPosition(cc.p(68,-30+(RedCount*-30)))
    local zhongSign = cc.Sprite:create("game/ico_zl.png")
    :setPosition(cc.p(310,-30+(RedCount*-30)))
    RedEnvelopes:addChild(zhongicon)
    RedEnvelopes:addChild(labUserNick)
    RedEnvelopes:addChild(zhongSign)
    -- 更新红包节点数目我用的TAG 哦
    RedCount = RedCount+1
    RedEnvelopes:setTag(RedCount)
end
function GameViewLayer:ShowChaiHbThird( event )
    dump(event)

    --这个消息里面 gameie 当userid用
    --信息初始化  和往表里查数据 并且刷新表
    local dataBuffer = event
    local a = dataBuffer["cbIdentifier"]
    local count = #dataBuffer
    local tab_tmp = {}

    for i=1,count do            
        tab_tmp[i] = dataBuffer[i]
      --  dump(tab_tmp[i])
    end
    if tab_tmp[1] == nil  or self.m_tabSendHb[self.chaiHbKey] == nil  then
       return 
    end
    local wGetNumber = tab_tmp[1].SL
    local wTotalNumber = tab_tmp[1].ZSL
    local wGetmoney = tab_tmp[1].JB
    local wTotalmoney = tab_tmp[1].ZJB

   local MeInfo = false
   for i=2,#tab_tmp do
     if  tab_tmp[i].wGameID == GlobalUserItem.dwGameID   then
         MeInfo = true
     end
   end

   if wGetNumber == wTotalNumber then
       if self.chaiHbKey ~= nil then
          self.m_tabGameRecord[self.chaiHbKey] = tab_tmp
       end
   end

    if wGetNumber == wTotalNumber  and MeInfo == false  and self.m_tabSendHb[self.chaiHbKey].bMeChia == false then
       self.m_tabSendHb[self.chaiHbKey].bMeChia = true
       if self.layer_ChaiOver:isVisible() == false then
            self.m_getHbLayer:setVisible(true)
          --  self.layer_ChaHongBoInfo.bMeChiai:setVisible(false)
            self._btnChai:setVisible(true)
            self.layer_ChaiOver:setVisible(true)
            self.layer_ChaiRecord:setVisible(false)
            return 
           
       end

      
--         local RedLayer = self:GetHongItem(self.chaiHbKey,1)
--           if RedLayer ~= nil then
--              if RedLayer:getChildByName("hongbaoer") ~= nil then
--                 RedLayer:getChildByName("hongbaoer"):loadTextureNormal("game/fhbBG_2.png")
--                 RedLayer:getChildByName("hongbaoer"):getChildByName("chaiStatus"):setString("已拆")
--              end
--           end
        
    end
        self.m_getHbLayer:setVisible(true)
    --旋转操作
     if self.layer_Chai:isVisible() == true then
        self:rottAnime(self.chaiHbKey,wGetNumber == wTotalNumber)
    else
         self.layer_Chai:setVisible(false)
         self._btnChai:setVisible(true)
         self.layer_ChaiOver:setVisible(false)
         self.layer_ChaiRecord:setVisible(true)
    end

    self.layer_ChaiRecord:getChildByName("curLingq"):setString(tostring(wGetNumber))
    self.layer_ChaiRecord:getChildByName("Zonglingqu"):setString(tostring(wTotalNumber))
    local curLingCount = self.layer_ChaiRecord:getChildByName("curLingq"):getPositionX()
    local lingwinth = self.layer_ChaiRecord:getChildByName("curLingq"):getContentSize().width
    curLingCount = curLingCount+lingwinth+1
    self.layer_ChaiRecord:getChildByName("lab_getInfo_0_0"):setPositionX(curLingCount)
    local spacBit = self.layer_ChaiRecord:getChildByName("lab_getInfo_0_0"):getPositionX()
    local spaceWinth = self.layer_ChaiRecord:getChildByName("lab_getInfo_0_0"):getContentSize().width
    spacBit = spacBit+spaceWinth+1
    self.layer_ChaiRecord:getChildByName("Zonglingqu"):setPositionX(spacBit)

    self.lab_getScore:setString(""..ExternalFun.numberThousands(wGetmoney) .. "/" .. ExternalFun.numberThousands(wTotalmoney))

   local aaa =  self.lab_getScore:getContentSize().width
    local abc = self.lab_getScore:getPositionX()
    abc = abc - aaa-10
    self.layer_ChaiRecord:getChildByName("Sprite_3"):setPositionX(abc)
    if #self.m_ChaiRecord>0 then
        for i=1,#self.m_ChaiRecord do
            table.remove(self.m_ChaiRecord)
        end
    end
    for i=2,#tab_tmp do
     if  tab_tmp[i].GameID == GlobalUserItem.dwGameID   then
         if self.m_tabSendHb[self.chaiHbKey].bMeChia == false then
             self:runAction(cc.Sequence:create(cc.DelayTime:create(0.8), cc.CallFunc:create(function()
		          self.m_showScore = self.m_showScore + tonumber(tab_tmp[i].Score)
                  self:updateUserScore()
			   end)))
         end
        if wTotalNumber == wGetNumber and self.m_tabSendHb[self.chaiHbKey].bMeChia == false then
             self._scene:SendZhonglei(self.chaiHbKey,false)
        end
        --我自己拆了的话我就把这个红包设置已经拆了的状态
        if  self.chaiHbKey ~= nil then
            if self.m_tabSendHb[self.chaiHbKey].bMeChia == false  and  tab_tmp[i].SFZL == 1 then
                self:runAction(cc.Sequence:create(cc.DelayTime:create(0.8), cc.CallFunc:create(function()
		        self._scene:SendZhonglei(self.chaiHbKey,true)
			    end)))
            end
               self.m_tabSendHb[self.chaiHbKey].bMeChia = true
        end
     end
  end

  
    for i=2,#tab_tmp do
        local t1 =  { strUrl =tab_tmp[i].FaceAddress, wHand = tab_tmp[i].Hand ,faceid = tab_tmp[i].FaceID , nick = tab_tmp[i].NickName, time = tab_tmp[i].RQ,
                      isZhong = tab_tmp[i].SFZL, score = tab_tmp[i].Score }
        table.insert(self.m_ChaiRecord,1,t1)     
   end
    self.m_getHbListview:removeAllItems()
    self:loadGetListView()
end


--shit本地
function GameViewLayer:GameResult(tabResltus)
      --信息初始化  和往表里查数据 并且刷新表
    if tabResltus[1] == nil  or self.m_tabSendHb[self.chaiHbKey] == nil  then
       return 
    end
    local wGetNumber = tabResltus[1].SL
    local wTotalNumber = tabResltus[1].ZSL
    local wGetmoney = tabResltus[1].JB
    local wTotalmoney = tabResltus[1].ZJB

   local MeInfo = false
   for i=2,#tabResltus do
       if tabResltus[i].GameID == GlobalUserItem.dwGameID   then
         MeInfo = true
     end
   end

--   if wGetNumber == wTotalNumber then
--       if self.chaiHbKey ~= nil then
--          self.m_tabGameRecord[self.chaiHbKey] = tab_tmp
--       end
--   end

    if wGetNumber == wTotalNumber  and MeInfo == false  and self.m_tabSendHb[self.chaiHbKey].bMeChia == false then
        self.m_getHbLayer:setVisible(true)
        self.layer_Chai:setVisible(false)
        self._btnChai:setVisible(true)
        self.layer_ChaiOver:setVisible(true)
        self.layer_ChaiRecord:setVisible(false)
        self.m_tabSendHb[self.chaiHbKey].bMeChia = true
        return 
    end
        self.m_getHbLayer:setVisible(true)
    --旋转操作
     if self.layer_Chai:isVisible() == true then
        self:rottAnime()
    else
         self.layer_Chai:setVisible(false)
         self._btnChai:setVisible(true)
         self.layer_ChaiOver:setVisible(false)
         self.layer_ChaiRecord:setVisible(true)
    end

      self.layer_ChaiRecord:getChildByName("curLingq"):setPositionX(self.leftLingX)
      self.layer_ChaiRecord:getChildByName("Zonglingqu"):setPositionX(self.RightLingX)
      self.layer_ChaiRecord:getChildByName("lab_getInfo_0_0"):setPositionX(self.SpaceX)
      self.layer_ChaiRecord:getChildByName("curLingq"):setString(tostring(wGetNumber))
      self.layer_ChaiRecord:getChildByName("Zonglingqu"):setString(tostring(wTotalNumber))
       local lPosX = 0
        local lNumber = tonumber(wGetNumber)
        while math.floor(lNumber) > 0 do
              lNumber=lNumber/10;  
              lPosX = lPosX+1
        end
        if lPosX == 2 then
             local lspaceX =  self.layer_ChaiRecord:getChildByName("lab_getInfo_0_0"):getPositionX()
             lspaceX = lspaceX+10
             self.layer_ChaiRecord:getChildByName("lab_getInfo_0_0"):setPositionX(lspaceX)

             local ZongScoreX =  self.layer_ChaiRecord:getChildByName("Zonglingqu"):getPositionX()
             ZongScoreX = ZongScoreX+10
             self.layer_ChaiRecord:getChildByName("Zonglingqu"):setPositionX(ZongScoreX)
        end


    self.lab_getScore:setString(""..ExternalFun.numberThousands(wGetmoney) .. "/" .. ExternalFun.numberThousands(wTotalmoney))

   local aaa =  self.lab_getScore:getContentSize().width
    local abc = self.lab_getScore:getPositionX()
    abc = abc - aaa-10
    self.layer_ChaiRecord:getChildByName("Sprite_3"):setPositionX(abc)
    if #self.m_ChaiRecord>0 then
        for i=1,#self.m_ChaiRecord do
            table.remove(self.m_ChaiRecord)
        end
    end
    for i=2,#tabResltus do
       if  tabResltus[i].GameID == GlobalUserItem.dwGameID   then
         if self.m_tabSendHb[self.chaiHbKey].bMeChia == false then
             self:runAction(cc.Sequence:create(cc.DelayTime:create(0.8), cc.CallFunc:create(function()
		        ----  self.m_showScore = self.m_showScore + tonumber(tabResltus[i].wWinmoney)
                --  self:updateUserScore()
			   end)))
         end
        if wTotalNumber == wGetNumber and self.m_tabSendHb[self.chaiHbKey].bMeChia == false then
           --  self._scene:SendZhonglei(self.chaiHbKey,false)
        end
        --我自己拆了的话我就把这个红包设置已经拆了的状态
        if  self.chaiHbKey ~= nil then
            if self.m_tabSendHb[self.chaiHbKey].bMeChia == false  and  tabResltus[i].SFZL == 1 then
                self:runAction(cc.Sequence:create(cc.DelayTime:create(0.8), cc.CallFunc:create(function()
		       -- self._scene:SendZhonglei(self.chaiHbKey,true)
			    end)))
            end
               self.m_tabSendHb[self.chaiHbKey].bMeChia = true
        end
     end
  end

  
    for i=2,#tabResltus do
        local t1 =  { strUrl =tabResltus[i].FaceAddress,wHand = tabResltus[i].Hand ,faceid = tabResltus[i].FaceID , nick = tabResltus[i].NickName, time = tabResltus[i].RQ,
                      isZhong = tabResltus[i].SFZL, score = tabResltus[i].Score }
        table.insert(self.m_ChaiRecord,1,t1)     
   end
    self.m_getHbListview:removeAllItems()
    self:loadGetListView()
end
--旋转动画
function GameViewLayer:rottAnime(Key,bChiaover)

       local ScaleActivexiaoCall = cc.CallFunc:create(function( )
	    --给爸爸扩大吧
	    --加载动画
	   local LeftAnime = cc.ScaleTo:create(0.12, 1.0)

	   local call = cc.CallFunc:create(function( )
	   local actionBy = cc.ScaleBy:create(0.18 ,-1, 1)  
         -- self._btnChai:runAction(actionBy)
           local actHideAct = cc.Sequence:create(actionBy, actionBy:reverse())
	       self._ScrentAnime:runAction(actHideAct)
           self._ScrentAnime:runAction(cc.Sequence:create(cc.DelayTime:create(0.6), cc.CallFunc:create(function()
           self.layer_Chai:setVisible(false)
           self._btnChai:setVisible(true)
           self.layer_ChaiOver:setVisible(false)
           self.layer_ChaiRecord:setVisible(true)

           local RedLayer = self:GetHongItem(Key,1)
           if RedLayer ~= nil then
           if bChiaover == true then
              if RedLayer:getChildByName("hongbaoer") ~= nil then
                 RedLayer:getChildByName("hongbaoer"):loadTextureNormal("game/fhbBG_1.png")
                 RedLayer:getChildByName("hongbaoer"):getChildByName("chaiStatus"):setString("红包已拆完")
              end
           else
            if RedLayer:getChildByName("hongbaoer") ~= nil then
                 RedLayer:getChildByName("hongbaoer"):loadTextureNormal("game/fhbBG_2.png")
                 RedLayer:getChildByName("hongbaoer"):getChildByName("chaiStatus"):setString("已拆")
              end
          end

        end
			    end)))
	   end)
	   local m_actHideAct = cc.Sequence:create(LeftAnime, call)
         self._ScrentAnime:setVisible(true)
	     self._ScrentAnime:runAction(m_actHideAct)
  end)
    
    local ScalexiaoActive =cc.ScaleTo:create(0.12, 0.9)   -- cc.ScaleBy:create(2.0, 5.0, 1.0)  
	local seqLonguence = cc.Sequence:create(ScalexiaoActive,ScaleActivexiaoCall);
    self._ScrentAnime:setVisible(true)
	self._ScrentAnime:runAction(seqLonguence)
    ExternalFun.playSoundEffect("chai.mp3")
end
--下注成功
function GameViewLayer:addSendHbJetton( wFaceAddress,dwGameID,wchairid,wnumber,wpoint,wrate,wscore ,identifier)
    
    self.m_MaiLeiIdt = identifier
    --限定下容量 上帝保佑我 如果炸了立马卷铺盖跑路 
    if #self.m_tabHbKey >=30 then
        ---这里给我删除他下面的中雷信息你知道我的梦你知道我的痛
        self.m_tabSendHb[self.m_tabHbKey[30]] = nil
       -- self.m_tabGameRecord[self.m_tabHbKey[30]] = nil
        self:deleteRed(self.m_hbTableView:getItem(0))
        table.remove(self.m_tabHbKey)
    end
    --一条接受的红包消息
    local t1 = self.m_MaiLeiIdt
    local t2 = {strUrl = wFaceAddress, wGameID = dwGameID, chairid =wchairid,number = wnumber,point = wpoint,rate = wrate,score = wscore ,bMeChia = false}
    table.insert(self.m_tabHbKey, 1 ,t1)
    self.m_tabSendHb[t1] = t2

    print("打印回调的红包")
    --dump(self.m_tabSendHb)
    --就是我改的 添加 进红包
    self:InitHongbao(self.m_tabSendHb[t1],t1,0)
   -- self.m_hbTableView:reloadData()
   -- self:moveRecordToLastRowZ()

    if self:isMeChair(wchairid) then
       self.m_showScore = self.m_showScore - tonumber(wscore)
        if self.m_showScore < 0 then
            self.m_showScore = 0            
        end
       print("红包金额" .. tonumber(wscore))
       self:updateUserScore()
    end
end
--删除一个红包儿
function GameViewLayer:deleteRed(RedLayer)

    if RedLayer~= nil then
        self.m_hbTableView:removeItem(0)
    end
end

--产生一个红包
function GameViewLayer:InitHongbao( HongBoInfo, tKey,nType)
   
    self.notifyLayer = ccui.Layout:create()
    self.notifyLayer:setTag(0)
    self.notifyLayer:setContentSize(600,142)
    self.notifyLayer:ignoreAnchorPointForPosition(false)
    self.notifyLayer:setAnchorPoint(cc.p(0,1))
    self.notifyLayer:setName(tostring(tKey))

    --0代表没领取完  1 代表领完了   m_spHbBg:setTag(0)
    local HongLayoutSize = self.notifyLayer:getContentSize()
    local m_spHbBg = ccui.Button:create("game/fhbBG.png", "", "")
    m_spHbBg:setName("hongbaoer")
    m_spHbBg:setTag(0)
    m_spHbBg:setAnchorPoint(cc.p(0,1))
    m_spHbBg:setPosition(cc.p(109,HongLayoutSize.height-20))
    self.notifyLayer:addChild(m_spHbBg)
    self.m_hbTableView:pushBackCustomItem(self.notifyLayer)
    if HongBoInfo.wGameID == GlobalUserItem.dwGameID then
        self.m_hbTableView:jumpToPercentVertical(100)
        self._isNeedMove = false
    else
       self._isNeedMove = self:isNeedMove()
    end

    if HongBoInfo.bMeChia == true then
       -- m_spHbBg:setTag(1)
        m_spHbBg:loadTextureNormal("game/fhbBG_2.png")
    end

    --领取完了就不鸟他 
    if  HongBoInfo.wComplete == true then
        m_spHbBg:loadTextureNormal("game/fhbBG_1.png")
        m_spHbBg:setTag(1)
    end

    local useritem = self._scene:getDataMgr():getChairUserList()[HongBoInfo.chairid + 1]
    local msg = string.format("%d万金 / %d包 / 雷%d / %0.1f倍",HongBoInfo.score/10000,HongBoInfo.number,HongBoInfo.point,HongBoInfo.rate)  
    local m_labHbMsg =  cc.Label:createWithSystemFont(msg,"Arial",26)
  --  cc.LabelTTF:create(msg, "fonts/round_body.ttf", 23)
    m_labHbMsg:setAnchorPoint(cc.p(0, 0.5))
    m_labHbMsg:setPosition(cc.p(92,78))
    m_spHbBg:addChild(m_labHbMsg)
    
    local strchaiOver = "点击拆红包"
    if nType == 1 then
        --场景消息判断下]
        if HongBoInfo.bMeChia == true then
            strchaiOver = "已拆"
        end 
        if HongBoInfo.wComplete == true then
           strchaiOver = "红包已拆完"
        end
    end
    --拆完的信息儿
    chaiOver= cc.LabelTTF:create(strchaiOver, "fonts/round_body.ttf", 20)
    chaiOver:setAnchorPoint(cc.p(0, 0.5))
    chaiOver:setName("chaiStatus")
    chaiOver:setPosition(cc.p(96,50))
    m_spHbBg:addChild(chaiOver)

    --local nameNick = ""
    local m_labnick = nil 
    if nType == 0 then
        m_labnick = cc.LabelTTF:create(useritem.szNickName, "fonts/round_body.ttf", 17)
    else
        m_labnick = cc.LabelTTF:create(HongBoInfo.nickName, "fonts/round_body.ttf", 17)
    end
    m_labnick:setColor(cc.c3b(102,102,102))
    m_labnick:setAnchorPoint(cc.p(0, 0.5))
    m_labnick:setPosition(cc.p(30,12))
    m_spHbBg:addChild(m_labnick)
    local subszNickName = nil 
    if nType == 0 then
        subszNickName =  self:SubNickName(m_labnick,useritem.szNickName,12)
    else
        subszNickName =  self:SubNickName(m_labnick,HongBoInfo.nickName,12)
    end 
    
    local nick = string.format( "%s 的游戏红包",subszNickName)  
    m_labnick:setString(nick)
    m_spHbBg:addTouchEventListener(function(ref, tType)
            if tType == ccui.TouchEventType.ended then
                print("==============拆红包 ")
                 if nType == 1 then
                 local CurTheUserIte = self:clone(GlobalUserItem)
                 CurTheUserIte.szThirdPartyUrl = HongBoInfo.strUrl
                 self:DianJiChaiHb111(CurTheUserIte,msg,tKey,1,HongBoInfo.wFaceID,HongBoInfo.nickName) 
                 else
                    useritem.szThirdPartyUrl = HongBoInfo.strUrl
                    self:DianJiChaiHb111(useritem,msg,tKey,0,useritem.wFaceID,"") 
                 end
            end
       end)
        --添加死人脑壳
    local recordHead = nil 
    if nType == 1 then
        local CurTheUserIte = {}
        CurTheUserIte.dwCustomID = 0
        CurTheUserIte.cbMemberOrder = 0
        CurTheUserIte.dwUserID = HongBoInfo.szUserID
        CurTheUserIte.szThirdPartyUrl = HongBoInfo.strUrl
        recordHead= g_var(PopupInfoHead):createNormal(CurTheUserIte, 63)
      if  CurTheUserIte.szThirdPartyUrl  ==""  or CurTheUserIte.szThirdPartyUrl ==  nil  then
          recordHead:updateHead({ wFaceID = HongBoInfo.wFaceID})
      end
    else
        useritem.szThirdPartyUrl = HongBoInfo.strUrl
        recordHead = g_var(PopupInfoHead):createNormal(useritem, 63)
    end
       recordHead:setPosition(-53,85)
       recordHead:setTag(1)
       m_spHbBg:addChild(recordHead)
end


function GameViewLayer:isNeedMove()
    local pInner = self.m_hbTableView:getInnerContainer()
    local listheight  = self.m_hbTableView:getLayoutSize().height - pInner:getContentSize().height
    local pos = self.m_hbTableView:getInnerContainerPosition()
    local percent = 0
    if pos.y ~= 0 then
        percent = (pos.y / listheight) * 100.0
    end
    print("百分比",percent)
    if percent ~= 0 then
        return true
    else
        self.m_hbTableView:jumpToPercentVertical(100)
        return false
    end                
end
function GameViewLayer:clone(object)  
    local lookup_table = {}  
    local function _copy(object)  
        if type(object) ~= "table" then  
            return object  
        elseif lookup_table[object] then  
            return lookup_table[object]  
        end  
        local newObject = {}  
        lookup_table[object] = newObject  
        for key, value in pairs(object) do  
            newObject[_copy(key)] = _copy(value)  
        end  
        return setmetatable(newObject, getmetatable(object))  
    end  
    return _copy(object)  
end  

function GameViewLayer:loadGetListView(  )
 
    dump(self.m_ChaiRecord)
    for i=1,#self.m_ChaiRecord do
        
        local itemInfo = self.m_ChaiRecord[i]
        local listItem = ccui.Layout:create()
        listItem:setContentSize(700,75)
        local CurTheUserIte = {}
        CurTheUserIte.dwUserID = GlobalUserItem.dwUserID
        CurTheUserIte.dwCustomID = 0
        CurTheUserIte.cbMemberOrder = 0
        CurTheUserIte.szThirdPartyUrl = itemInfo.strUrl
        local itemHead = g_var(PopupInfoHead):createNormal(CurTheUserIte, 52)
        if CurTheUserIte.szThirdPartyUrl == nil or CurTheUserIte.szThirdPartyUrl == "" then
            itemHead:updateHead({ wFaceID = itemInfo.faceid})
        end

        itemHead:setPosition(35,30)
        listItem:addChild(itemHead)

        local itemnick = ccui.Text:create(itemInfo.nick,"fonts/round_body.ttf",20)
        :setAnchorPoint(cc.p(0,0.5))
        :setTextColor(cc.c3b(0,0,0))
        :setPosition(cc.p(72,44))
        :addTo(listItem)
        self:SubNickName(itemnick,itemInfo.nick,12)

        local time = ccui.Text:create(itemInfo.time,"fonts/round_body.ttf",16)
        :setAnchorPoint(cc.p(0,0.5))
        :setTextColor(cc.c3b(187,187,187))
        :setPosition(cc.p(72,15))
        :addTo(listItem)

        if itemInfo.isZhong == 1 then
            local zhongicon = cc.Sprite:create("game/ico_zl.png")
            :setPosition(cc.p(250,45))
            :addTo(listItem)
        end


        --许仙
         local xuLine = cc.Sprite:create("game/xu.png")
            :setPosition(cc.p(160,-5))
            :addTo(listItem)

        local jbicon = cc.Sprite:create("game/jbsico.png")
        :setPosition(cc.p(322,44))
        :addTo(listItem)

        local score = ccui.Text:create(itemInfo.score,"fonts/round_body.ttf",20)
        :setAnchorPoint(cc.p(0,0.5))
        :setTextColor(cc.c3b(0,0,0))
        :setPosition(cc.p(331,44))
        :addTo(listItem)
        --最佳手气王
        if itemInfo.wHand == 1 then 
            local zhongicon = cc.Sprite:create("game/sqzj.png")
            :setPosition(cc.p(354,16))
            :addTo(listItem)
        end

        self.m_getHbListview:pushBackCustomItem(listItem) 
    end

end

function GameViewLayer:addRecord( info )
    -- if nil ~= info then
    --     return
    -- end
    local info1 =  {msg = "9万金／雷6/3.0倍" , score = 999 , isZhong = true , ZhongScore = 6666,time = "09-09  16:43:18"}
    if #self.m_RecordList < 11 then
        table.insert(self.m_RecordList,1,info1)
    else
        table.remove(self.m_RecordList)
        table.insert(self.m_RecordList,1,info1)
    end
    self.m_recordListView:removeAllItems()
    self:loadListView()
end

function GameViewLayer:loadListView(  )
   
--   local svt = 5
--    for i=1, svt do 
--        local t2 = {wNumber = 50, wPoint = 5, wRate =1.8,wRedmoney = 10000,WinScore = -10000,SendUserName ="张飞",wRobListCount = 18}
--        table.insert(self.m_RobRecordList, 1 ,t2)
--    end

        for i=1,#self.m_RecordList do
   
        local itemInfo = self.m_RecordList[i]
        local listItem 
        local offy = 0
        if i%2 == 0 then
            listItem =  ccui.ImageView:create("game/qiang.png")
        else
            listItem =  ccui.ImageView:create("game/qiang1.png")
            offy = -25
        end
       
        --hbicon
        local hbicon = cc.Sprite:create("game/histhbico.png")
                        :setPosition(cc.p(15,40+offy))
                        :addTo(listItem)

        --hbmsg
        local msg = string.format("%d万金/雷%d/%0.1f倍",itemInfo.Score/10000,itemInfo.LD,itemInfo.BL)  
        local hbmsg = ccui.Text:create(msg,"fonts/round_body.ttf",19)
                        :setAnchorPoint(cc.p(0,0.5))
                        :setTextColor(cc.c3b(0,0,0))
                        :setPosition(cc.p(27,40+offy))
                        :addTo(listItem)

        local jbicon = cc.Sprite:create("game/fhbjbico.png")
                        :setPosition(cc.p(220,40+offy))
                        :setScale(0.77)
                        :addTo(listItem)
        
        --加儿
        local Jiascore = ccui.Text:create("+","fonts/round_body.ttf",16)
                        :setAnchorPoint(cc.p(0,0.5))
                        :setTextColor(cc.c3b(255,0,0))
                        :setPosition(cc.p(230,40+offy))
                        :addTo(listItem)

        --score
        local score = ccui.Text:create(itemInfo.CScore,"fonts/round_body.ttf",20)
                        :setAnchorPoint(cc.p(0,0.5))
                        :setTextColor(cc.c3b(255,0,0))
                        :setPosition(cc.p(241,40+offy))
                        :addTo(listItem)
        --手气最佳
        local lPosX = 0
        local lNumber = tonumber(itemInfo.CScore)
        while math.floor(lNumber) > 0 do
              lNumber=lNumber/10;  
              lPosX = lPosX+1
        end
       if itemInfo.Hand == true then
          local zhongicon = cc.Sprite:create("game/sqzj.png")
                            :setAnchorPoint(cc.p(0,0.5))
                            :setPosition(cc.p(260+lPosX*10,40+offy))
                            :addTo(listItem)
       end
        --中雷
        if itemInfo.SFZL == 1 then
            local zhongicon = cc.Sprite:create("game/ico_zl.png")
                            :setPosition(cc.p(475,41+offy))
                            :addTo(listItem)
            local jbicon2 = cc.Sprite:create("game/fhbjbico.png")
                            :setPosition(cc.p(528,40+offy))
                            :setScale(0.8)
                            :addTo(listItem)
           --减儿
        local Jiascore = ccui.Text:create("-","fonts/round_body.ttf",16)
                        :setAnchorPoint(cc.p(0,0.5))
                        :setTextColor(cc.c3b(0,157,70))
                        :setPosition(cc.p(538,40+offy))
                        :addTo(listItem)
            local losescore = ccui.Text:create(itemInfo.ZLJE,"fonts/round_body.ttf",20)
                            :setAnchorPoint(cc.p(0,0.5))
                            :setTextColor(cc.c3b(0,157,70))
                            :setPosition(cc.p(548,40+offy))
                            :addTo(listItem)
        end

        --时间
        local time = ccui.Text:create(itemInfo.RQ,"fonts/round_body.ttf",20)
                        :setAnchorPoint(cc.p(0,0.5))
                        :setTextColor(cc.c3b(153,153,153))
                        :setPosition(cc.p(633,40+offy))
                        :addTo(listItem)
        self.m_recordListView:pushBackCustomItem(listItem)

    end
end
function GameViewLayer:RobListView(  )
--     
--抢包记录 
    for i=1,#self.m_RobRecordList do
        local itemInfo = self.m_RobRecordList[i]
        local listItem 
        local listItem =ccui.Button:create("game/tiaomu.png", "game/tiaomu.png", "game/tiaomu.png")
        listItem:setName(tostring(itemInfo.HBID))
        listItem:addClickEventListener(function(sender, state)
        local sss = tonumber(sender:getName())
           self.redMes = sender:getChildByTag(998):getString()
           self._scene:SendRedDiffRecord(tonumber(sender:getName()))
        end)

     --   listItem:setContentSize(544,34)
        local clipNick = ClipText:createClipText(cc.size(200, 24), GlobalUserItem.szNickName, "fonts/round_body.ttf", 20)
        clipNick:setTextColor(cc.c3b(0,0,0))
        self:SubNickName(clipNick,GlobalUserItem.szNickName,12)
        clipNick:setPosition(cc.p(17,5))
        listItem:addChild(clipNick)

            --hbicon
        local hbicon = cc.Sprite:create("game/histhbico.png")
                        :setPosition(cc.p(195,18))
                        :addTo(listItem)

        --hbmsg
        local msg = string.format("%d万金/%d包/雷%d/%0.1f倍",itemInfo.SC/10000,itemInfo.HBSL,itemInfo.LD,itemInfo.BL)  
        local hbmsg = ccui.Text:create(msg,"fonts/round_body.ttf",19)
                        :setAnchorPoint(cc.p(0,0.5))
                        :setTextColor(cc.c3b(0,0,0))
                        :setPosition(cc.p(212,18))
                        :addTo(listItem)


        hbmsg:setTag(998)
        local jbicon = cc.Sprite:create("game/fhbjbico.png")
                        :setPosition(cc.p(450,18))
                        :setScale(0.77)
                        :addTo(listItem)

        --加儿
        local Jiascore = ccui.Text:create("+","fonts/round_body.ttf",16)
                        :setAnchorPoint(cc.p(0,0.5))
                        :setTextColor(cc.c3b(255,0,0))
                        :setPosition(cc.p(460,18))
                        :addTo(listItem)

        --score

        
        local score = ccui.Text:create(itemInfo.Endmoney,"fonts/round_body.ttf",20)
                        :setAnchorPoint(cc.p(0,0.5))
                        :setTextColor(cc.c3b(255,0,0))
                        :setPosition(cc.p(472,18))
                        :addTo(listItem)

            if tonumber(itemInfo.Endmoney) == -1 then
                score:setString("红包未拆完")
                score:setTextColor(cc.c3b(255,0,0))
                Jiascore:setTextColor(cc.c3b(255,0,0))
                Jiascore:setText("")
            
            elseif tonumber(itemInfo.Endmoney) >0 then
               score:setTextColor(cc.c3b(255,0,0))
               Jiascore:setTextColor(cc.c3b(255,0,0))
               Jiascore:setText("+")
            else
               if tonumber(itemInfo.Endmoney) == 0 then
                  score:setString("0")
                  else
                  score:setString(tostring(tonumber((itemInfo.Endmoney)*-1)))
               end
               Jiascore:setString("")
               Jiascore:setTextColor(cc.c3b(0,157,70))
               score:setTextColor(cc.c3b(0,157,70))
            end
                    --时间
        local time = ccui.Text:create(itemInfo.RQ,"fonts/round_body.ttf",20)
                        :setAnchorPoint(cc.p(0,0.5))
                        :setTextColor(cc.c3b(153,153,153))
                        :setPosition(cc.p(575,18))
                        :addTo(listItem)

                        
          self.m_robListView:pushBackCustomItem(listItem)

    end
end
--发红包页面按钮
function GameViewLayer:onHbSendEvent(tag, ref)   
    ExternalFun.playClickEffect()

    if ZHB_CLEAR ==  tag then  
    self.m_laballScore:setString("") 
    self.LastScore = nil
    self.numAllScore = nil

    elseif ZHB_SEND == tag then

      --发送塞红包消息
        if self.numAllScore == nil then
               showToast(self,"亲,请输入正确红包金额~",2)
               self:clearRed()
               return 
        elseif self.numRedCount == nil then
                showToast(self,"亲,请输入正确个数~",2)
                self:clearRed()
                return
        elseif self.numMineCount == nil then
                showToast(self,"亲,请输入正确雷点~",2)
                self:clearRed()
                return
        else
           if tonumber(self.numAllScore) > tonumber(GlobalUserItem.lUserScore) then
               showToast(self,"亲,您的金币不够发送红包哟~",2)
               self:clearRed()
               return
           end
        end
        
        self._scene:SendRedPacktByGame(self.numRedCount,self.numMineCount,self.numPeiLv,self.numAllScore)
        self:clearRed()
      
    elseif ZHB_CLOSE == tag then
        if nil ~= self.m_sendLayer then
            self:clearRed()
            self.m_sendLayer:setVisible(false)
       end
    end

end


function GameViewLayer:clearRed()
    self.m_laballScore:setString("") 
    self.m_labredCount:setString("") 
    self.m_labmineCount:setString("")
    self.m_sendLayer:setVisible(false)
    self.numPeiLv = nil  --默认一倍
    self.LastScore = nil
    --self.LastRedCount = 5
    --self.LastRedLeiDian = 0
    self.numAllScore = nil
    self.numRedCount = nil
    self.numMineCount = nil
end
--错误提示
function GameViewLayer:showToastError(resultID)
    
    if resultID == 0 then
       showToast(self,"亲，你身上的金币不够发送红包！",2)
    elseif resultID == 1 then
       showToast(self,"亲，你当前的金额不够领取该红包！",2)
   end

     
end
function GameViewLayer:onButtonClickedEvent(tag, ref)   
    ExternalFun.playClickEffect()
    if TAG_ENUM.BT_CHAT == tag then             --聊天       
        if nil == self.m_chatLayer then
            self.m_chatLayer = GameChatLayerD:create(self._scene._gameFrame)
            self:addToRootLayer(self.m_chatLayer, TAG_ZORDER.CHAT_ZORDER)
        end
        self.m_chatLayer:showGameChat(true)
    elseif TAG_ENUM.BT_RECORD ==  tag then      --战绩
        print("打开战绩")
        --self._scene:SendChaiHongBao(77)
        self:onClickRecord()
    elseif TAG_ENUM.BT_SENDRED ==  tag then      --发红包
        
        print("打开发红包")
        self:onClickSendHb()
   
--         self._notifyLayer = ccui.Layout:create()
--		:setContentSize(600,130)
--        :ignoreAnchorPointForPosition(false)
--        :setAnchorPoint(cc.p(0,1))
--		local sd=tostring(x)
--        x=x+1
--    self.m_pLable_ = cc.Label:createWithSystemFont(sd,"Arial",25)
--    self.m_pLable_:setPosition(cc.p(120,50))
--    self.m_spHbBg = ccui.Button:create("game/fhbBG.png", "", "")
--    self.m_spHbBg:setName("sdsds")
--    self.m_spHbBg:addChild(self.m_pLable_ )

--    self.m_spHbBg:setAnchorPoint(cc.p(0,1))
--    self.m_spHbBg:setPosition(cc.p(75,130))
--    self._notifyLayer:addChild(self.m_spHbBg)
--    self.m_hbTableView:pushBackCustomItem(self._notifyLayer)

--    --self.m_hbTableView:setInnerContainerSize(cc.size(0,0))
--       -- self:onClickSendHb()
--       --self.m_hbTableView:setInnerContainerPosition(cc.p(0,0))
--       self.m_hbTableView:jumpToPercentVertical(100)

    elseif TAG_ENUM.BT_MENU ==  tag then      --菜单
        print("打开菜单")
        self:showMenu()
    elseif TAG_ENUM.BT_ADMIN == tag then      --管理大大
        self:showAdmin()
    elseif TAG_ENUM.BT_RULE ==  tag then      --规则
        print("打开规则")
        self:onClickRule()
    elseif TAG_ENUM.BT_RULE ==  tag then      --退出
        print("退出")
        self:getParentNode():onQueryExitGame()
    elseif TAG_ENUM.BT_SET == tag then          --设置
        local set = SettingLayer:create()
        self:addToRootLayer(set, TAG_ZORDER.SET_ZORDER)
    elseif TAG_ENUM.BT_EXIT == tag then         --退出
        if self:bOverGame() == true then
            self:getParentNode():onQueryExitGame() 
        else 
          --self:getParentNode():onQueryExitGame() 
           showToast(self,"当前发送红包需要抢完才能离开请稍等~",2)
        end
    end
end


function GameViewLayer:moveRecordToLastRowZ(  )
    local container = self.m_hbTableView:getContainer()
    local needToLastRow = false
    -- if nil ~= container then
    --     needToLastRow = (container:getContentSize().height >= self.m_hbTableView:getViewSize().height)
    -- end
    -- if needToLastRow then
        self.m_hbTableView:setContentOffset(cc.p(0,0),false)
    --end
end

function GameViewLayer:getHbTableView( size )
    
    --tableiview create
    local m_tableView = cc.TableView:create(size)
    m_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    m_tableView:setAnchorPoint(cc.p(0,0))
    m_tableView:setPosition(cc.p(41,92))
    m_tableView:setDelegate()
    m_tableView:registerScriptHandler(handler(self,self.cellSizeForTableZ),cc.TABLECELL_SIZE_FOR_INDEX)
    m_tableView:registerScriptHandler(handler(self, self.tableCellAtIndexZ), cc.TABLECELL_SIZE_AT_INDEX)
	m_tableView:registerScriptHandler(handler(self, self.tableCellTouchedZ), cc.TABLECELL_TOUCHED)
	m_tableView:registerScriptHandler(handler(self, self.numberOfCellsInTableViewZ), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    return m_tableView
end

--tableview代理   
function GameViewLayer:cellSizeForTableZ( view , idx )
    --实时根据idx 来设置cell宽高
    return 421,130
end

function GameViewLayer:tableCellAtIndexZ( view , idx )
    local cell = view:dequeueCell()
	local dataitem = nil

    print("idx = " .. idx)
    if nil == cell then
        cell = cc.TableViewCell:new()

		dataitem = self:getDataItemAt(view,idx)
		if nil ~= dataitem then
			dataitem:setName("CHAT_ITEM_NAME")
			cell:addChild(dataitem)
		end
	else
		dataitem = cell:getChildByName("CHAT_ITEM_NAME")
    end
    
	if nil ~= dataitem then
		self:refreshDataItemAt(view, dataitem, idx)
	end

    cell:setTag(idx)
    
	return cell
end

function GameViewLayer:getDataItemAt( view , idx )
    local chatitem = ChatItem:create(idx)
    chatitem:setName("CHAT_ITEM_NAME")
    return chatitem
end

function GameViewLayer:refreshDataItemAt(view, item, idx)	
	if nil == item then
		return 
	end

	-- if CBT_TEXT == self.m_nSelect then
	-- 	local record = textChatConfig[idx + 1]
	-- 	if nil ~= record then
	-- 		item:refreshTextItem(record.strChat)
	-- 	end			
    -- elseif CBT_RECORD == self.m_nSelect then

    local DianJiChaiHb = function ( hbmsg ,isChai,key )
        self:DianJiChaiHb111(hbmsg,isChai,key)
    end

    local record = self.m_tabSendHb[self.m_tabHbKey[idx+1]]
    --dump(record)
    local useritem = self._scene:getDataMgr():getChairUserList()[record.chairid + 1]
    if nil ~= record then
		item:refreshHbItem(useritem,record.number,record.point,record.rate,record.score,DianJiChaiHb,self.m_tabHbKey[idx+1])
	end
	-- end

	local size = item:getContentSize()
	item:setPosition(size.width * 0.5, 0)
end


function GameViewLayer:tableCellTouchedZ( view , cell )
    
end

function GameViewLayer:numberOfCellsInTableViewZ( view  )
    return #self.m_tabHbKey
end
--点击拆红包
function GameViewLayer:DianJiChaiHb111( useritem,msg,redKey,nType, wfaceID, szNickName)
    --拆红包
    --设置下三个页面的通用变量
    self.chaiHbKey = redKey
    self.layer_Chai:removeChildByTag(1)
    self.layer_ChaiOver:removeChildByTag(1)
    self.layer_ChaiRecord:removeChildByTag(1)
    local recordHead = nil 
    recordHead = g_var(PopupInfoHead):createClipHead(useritem, 72)
    if useritem.szThirdPartyUrl == nil or useritem.szThirdPartyUrl == "" then
       recordHead:updateHead({ wFaceID = wfaceID })
    end
    recordHead:setPosition(667,608)
    recordHead:setTag(1)
    self.layer_Chai:addChild(recordHead)


    local recordHead2 = nil 
    recordHead2 = g_var(PopupInfoHead):createClipHead(useritem, 72)
     if useritem.szThirdPartyUrl == nil or useritem.szThirdPartyUrl == "" then
     recordHead2:updateHead({ wFaceID = wfaceID })
    end
    recordHead2:setPosition(667,608)
    recordHead2:setTag(1)
    self.layer_ChaiOver:addChild(recordHead2)

    local recordHead3 = nil 
    recordHead3 = g_var(PopupInfoHead):createClipHead(useritem, 72)
    if  useritem.szThirdPartyUrl == nil or useritem.szThirdPartyUrl == "" then
        recordHead3:updateHead({ wFaceID = wfaceID })
    end
    recordHead3:setPosition(667,620)
    recordHead3:setTag(1)
    self.layer_ChaiRecord:addChild(recordHead3)

    self.m_getHbLayer:setVisible(true)
    --判断下如果当前的红包已经被我XXOO 过 我就直接显示结果哈！
      local RedLayer = self:GetHongItem(self.chaiHbKey,1)
      if RedLayer:getChildByName("hongbaoer"):getTag() == 1 then
            --判断当前是否有列表
           if self.m_tabGameRecord[self.chaiHbKey] ~= nil then
                 self:GameResult(self.m_tabGameRecord[self.chaiHbKey])
                 --self._scene:SendChaiHongBao(self.chaiHbKey)
            else
                
       if self.m_tabSendHb[self.chaiHbKey].bMeChia == false then
            self.m_getHbLayer:setVisible(true)
            self.layer_Chai:setVisible(false)
            self._btnChai:setVisible(true)
            self.layer_ChaiOver:setVisible(true)
            self.layer_ChaiRecord:setVisible(false)
           -- self.m_tabSendHb[self.chaiHbKey].bMeChia = true
       else
         self._scene:SendChaiHongBao(self.chaiHbKey)
      end
      
     end
       else
         local RedString = RedLayer:getChildByName("hongbaoer"):getChildByName("chaiStatus"):getString()
         if self:isHongBaoChai(redKey) == false and  RedString ~="红包已拆完" then
            self.layer_Chai:setVisible(true)
            self._btnChai:setVisible(true)
            self.layer_ChaiOver:setVisible(false)
            self.layer_ChaiRecord:setVisible(false)
         else
            self._scene:SendChaiHongBao(self.chaiHbKey)
       end
    end
    --三层的昵称
    for i=1,3 do
      --  self.tabNick[i]:setString( useritem.szNickName)
        if nType ==0 then
             self:SubNickName(self.tabNick[i],useritem.szNickName,12)
        else
             self:SubNickName(self.tabNick[i],szNickName,12)
        end
    end
    for i=1,2 do
        self.tabHbmsg[i]:setString(msg)
    end
end

--是否已经被XXOO 过
function GameViewLayer:isHongBaoChai(key)

    if  self.m_tabSendHb[key] == nil then
      return false
    else
      --判断这个包儿拆过没哈！呵呵哈伊
      return self.m_tabSendHb[key].bMeChia
    end
end


function GameViewLayer:showMenu(  )
    if self.m_bshowMenu == false then
        self.m_bshowMenu = true
        self.m_menulayout:setVisible(true)
        self.m_menulayout:runAction(cc.ScaleTo:create(0.2, 1.0))
    else
        self.m_bshowMenu = false
        self.m_menulayout:runAction(cc.Sequence:create(
            cc.ScaleTo:create(0.2, 1.0, 0.0001), 
            cc.CallFunc:create(
                function()
                    self.m_menulayout:setVisible(false)
                end
                )
            )
        )
    end
end

--显示管理面板
function GameViewLayer:showAdmin(  )
    self.m_csbNode:getChildByName("Panel_Admin"):setVisible(true)
    self._scene:sendAdmin()
end

--规则
function GameViewLayer:onClickRule(  )
    
    self.m_ruleLayer = cc.Node:create()
    self:addChild(self.m_ruleLayer)

    local function btnEvent( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            if nil ~= self.m_ruleLayer then
                self.m_ruleLayer:setVisible(false)
                self.m_ruleLayer:removeFromParent()
			end
        end
    end 

    local csbNode1 = ExternalFun.loadCSB("game/GameRule.csb", self.m_ruleLayer)
    local csbNode  = csbNode1:getChildByName("Panel_1")
    self.guerrtNode =csbNode
    csbNode:setSwallowTouches(false)
	local img_bg = csbNode:getChildByName("Image_1")
	img_bg:addTouchEventListener(btnEvent)
	 
	local btn_closeHelp = csbNode:getChildByName("btn_close")
	btn_closeHelp:addTouchEventListener(btnEvent)

end

function GameViewLayer:onClickRecord(  )
     self._scene:RedRecord()
     self._scene:SendRedRecord()
end

--show发红包页面
function GameViewLayer:onClickSendHb( )
    if nil ~=self.m_sendLayer then
    --     --设置上次的金额
    --     if self.LastScore ~= nil then
    --        self.m_laballScore:setString(tostring(self.LastScore))
    --     end
    -- if self.LastRedCount ~= nil then
    --     self.m_labredCount:setString(tostring(self.LastRedCount))
    -- end
    -- if self.LastRedLeiDian ~= nil then
    --     self.m_labmineCount:setString(tostring(self.LastRedLeiDian))
    -- end
        self.m_sendLayer:setVisible(true)
  end
end

--更新分数
function GameViewLayer:updateUserScore(  )
    GlobalUserItem.lUserScore = self.m_showScore
	local str = ExternalFun.numberThousands(self.m_showScore)
	self.m_score:setString(str)
end

--更新排行榜
function GameViewLayer:updateRankInfo(  )
    
    self.m_rankHeadSp[1]:updateHead({ wFaceID = 0 })
    self.m_rankNick[1]:setString("柳絮飞飞")
    self.m_rankScore[1]:setString("99,1111")
    
end

--刷新用户分数
function GameViewLayer:onGetUserScore( useritem )
    --自己
    if useritem.dwUserID == GlobalUserItem.dwUserID then
        self.m_showScore = useritem.lScore
        self:updateUserScore()
    end
end

function GameViewLayer:isMeChair( wchair )
    local useritem = self._scene:getDataMgr():getChairUserList()[wchair + 1]
    if nil == useritem then
        return false
    else 
        return useritem.dwUserID == GlobalUserItem.dwUserID
    end
end


--ChatItem  
function ChatItem:ctor(idx)

    self.m_spHbBg = ccui.Button:create("game/fhbBG.png", "game/fhbBG.png", "game/fhbBG.png")
    self.m_spHbBg:setAnchorPoint(cc.p(0,0.5))
    self.m_spHbBg:setPosition(cc.p(65,55))
    self:addChild(self.m_spHbBg)
    
    self.m_labHbMsg = nil
    self.m_labnick  = nil
    self.m_isChai   = false
    self.m_userHead = nil

end

function ChatItem:refreshHbItem( useritem,number,point,rate,score ,_callback,key)
    self._callback = _callback
    local msg = string.format("%d万金/%d包/雷%d/%0.1f倍",score/10000,number,point,rate)  
    local nick = string.format( "%s 的游戏红包",useritem.szNickName )  
    dump(useritem)
    print(" " ..nick)
    if nil == self.m_labHbMsg then
        self.m_labHbMsg = cc.LabelTTF:create(msg, "fonts/round_body.ttf", 24)
        self.m_labHbMsg:setAnchorPoint(cc.p(0, 0.5))
        self.m_labHbMsg:setPosition(cc.p(100,70))

        self.m_spHbBg:addChild(self.m_labHbMsg)

        self.m_labnick = cc.LabelTTF:create(nick, "fonts/round_body.ttf", 17)
        self.m_labnick:setColor(cc.c3b(102,102,102))
        self.m_labnick:setAnchorPoint(cc.p(0, 0.5))
        self.m_labnick:setPosition(cc.p(30,12))
        self.m_spHbBg:addChild(self.m_labnick)


    else
        self.m_labHbMsg:setString(msg)
        self.m_labnick:setString(nick)
    end

    if nil ~= self.m_spHbBg and self._callback ~= nil then
        self.m_spHbBg:addClickEventListener(function()
            self._callback(useritem,msg,key)
        end)
       
    end
    self:addSendUser(useritem)

end

function ChatItem:addSendUser( useritem )
    --dump(useritem)
    if  useritem ~= nil  then
        self.m_userHead = g_var(PopupInfoHead):createNormal(useritem, 57)
        self.m_userHead:setPosition(30,78)
        self:addChild(self.m_userHead)
    end
end








function GameViewLayer:HbCallBack( event )

    
end

function GameViewLayer:createAnimation()
    
end

function GameViewLayer:unloadResource()
   
end
-- 重置
function GameViewLayer:reSetGame()
    self:reSetUserState()

    self.m_spTimer:setVisible(false)
    self.m_atlasTimer:setString("")
    -- 取消托管
    self.m_trusteeshipControl:setVisible(false)

    self.m_bMyCallBanker = false
    self.m_bMyOutCards = false
end

-- 重置(新一局)
function GameViewLayer:reSetForNewGame( isClearHand )
    
end

-- 重置用户状态
function GameViewLayer:reSetUserState()
    for k,v in pairs(self.m_tabReadySp) do
        v:setVisible(false)
    end

    for k,v in pairs(self.m_tabStateSp) do
        v:setSpriteFrame("blank.png")
    end
end

-- 重置用户信息
function GameViewLayer:reSetUserInfo()
    local score = self:getParentNode():GetMeUserItem().lScore or 0
    local str = ""
    if score < 0 then
        str = "." .. score
    else
        str = "" .. score        
    end 
    if string.len(str) > 11 then
        str = string.sub(str, 1, 11)
        str = str .. "///"
    end  

    self:convScoreToWanUnit(self.m_atlasScore,str)
end

function GameViewLayer:convScoreToWanUnit( label_score,score )
  
    local scc = ""

    scc = ExternalFun.numberThousands(score)
    scc = string.gsub(scc,"[,]",";")

    label_score:setString(tostring(scc))
end

function GameViewLayer:onExit()
    if nil ~= self.m_actRocketRepeat then
        self.m_actRocketRepeat:release()
        self.m_actRocketRepeat = nil
    end

    self:unloadResource()

end



function GameViewLayer:onClickReady()
    self.m_btnReady:setEnabled(false)
    self.m_btnReady:setVisible(false)

    self:getParentNode():sendReady()

    if self:getParentNode().m_bRoundOver then
        self:getParentNode().m_bRoundOver = false
        -- 界面清理
        --准备不清理手牌
        self:reSetForNewGame(true)
    end 
end


function GameViewLayer:outCardEffect(outViewId, outCards, vecCards)
    
end

function GameViewLayer:onChangePassBtnState( bEnable )
    self.m_btnPass:setEnabled(bEnable)
    if bEnable then
        self.m_btnPass:setOpacity(255)
    else
        self.m_btnPass:setOpacity(125)
    end
end

function GameViewLayer:onPassOutCard()
    
end

function GameViewLayer:getUserNick( viewId )
    if nil ~= self.m_tabUserHead[viewId] then
        return self.m_tabUserHead[viewId].m_userItem.szNickName
    end
    return ""
end

------
-- 扑克代理

-- 扑克状态变更
-- @param[cbCardData]       扑克数据
-- @param[status]           状态(ture:选取、false:非选取)
-- @param[cardsNode]        扑克节点
function GameViewLayer:onCardsStateChange( cbCardData, status, cardsNode )

end

-- 扑克选择
-- @param[selectCards]      选择扑克
-- @param[cardsNode]        扑克节点
function GameViewLayer:onSelectedCards( selectCards, cardsNode )
    
end

-- 牌数变动
-- @param[outCards]         出牌数据
-- @param[cardsNode]        扑克节点
function GameViewLayer:onCountChange( count, cardsNode, isOutCard )
    
end

------
-- 扑克代理

-- 提示出牌
-- @param[bOutCard]        是否出牌
function GameViewLayer:onPromptOut( bOutCard )
   
end

function GameViewLayer:onGameTrusteeship( bTrusteeship )
   
end

function GameViewLayer:updateClock( chair,clockId, cbTime)
    
end

function GameViewLayer:OnUpdataClockView( viewId, cbTime )
    
end
------------------------------------------------------------------------------------------------------------
--更新
------------------------------------------------------------------------------------------------------------

-- 文本聊天
function GameViewLayer:onUserChat(chatdata, viewId)
    local roleItem = self.m_tabUserHead[viewId]
    if nil ~= roleItem then
        roleItem:textChat(chatdata.szChatString)
    end
end

-- 表情聊天
function GameViewLayer:onUserExpression(chatdata, viewId)
    local roleItem = self.m_tabUserHead[viewId]
    if nil ~= roleItem then
        roleItem:browChat(chatdata.wItemIndex)
    end
end

-- 用户更新
function GameViewLayer:OnUpdateUser(viewId, userItem, bLeave)
    
end

function GameViewLayer:onUserReady(viewId, bReady)
    --用户准备
    if bReady then
        local readySp = self.m_tabReadySp[viewId]
        if nil ~= readySp then
            readySp:setVisible(true)
        end
    else
        local readySp = self.m_tabReadySp[viewId]
        if nil ~= readySp then
            readySp:setVisible(false)
        end
    end
end

function GameViewLayer:onGetCellScore( score )
    
    score = score or 0
    local str = ""
    if score < 0 then
        str = "." .. score
    else
        str = "" .. score        
    end 
    if string.len(str) > 11 then
        str = string.sub(str, 1, 11)
        str = str .. "///"
    end  
    self.m_textGameCall:setString(str) 
end

function GameViewLayer:updataCellScore(  )
    self.m_difen = self.m_difen*2
    self.m_atlasDiFeng:setString(tonumber(self.m_difen) .. "")

end
function GameViewLayer:onGetGameFree()
    if false == self:getParentNode():getFrame().bEnterAntiCheatRoom then
        self.m_btnReady:setEnabled(true)
        self.m_btnReady:setVisible(true)
    end    
end

function GameViewLayer:onGameStart()

    self:showWaitAni(false)
    --开始游戏清理手牌 true
    self:reSetForNewGame(true)

    self.m_nMaxCallScore = 0
    self.m_atlasDiFeng:setString("1")
    for k,v in pairs(self.m_tabBankerCard) do
        v:setVisible(false)
        v:setCardValue(0)
    end
    self.m_spInfoTip:setSpriteFrame("blank.png")
    for k,v in pairs(self.m_tabStateSp) do
        v:stopAllActions()
        v:setSpriteFrame("blank.png")
    end

    for k,v in pairs(self.m_tabCardCount) do
        v:setString("")
    end
    self.m_promptIdx = 0
end


function GameViewLayer:onGetGameCard(viewId, cards, bReEnter, pCallBack)
    
end

function GameViewLayer:onGetCallScore( callViewId, lastViewId, callScore, lastScore, bReEnter )
   
end

-- 获取到庄家信息
-- @param[bankerViewId]         庄家视图id
-- @param[cbBankerScore]        庄家分数
-- @param[bankerCards]          庄家牌
-- @param[bReEnter]             是否断线重连
function GameViewLayer:onGetBankerInfo(bankerViewId, cbBankerScore, bankerCards, bReEnter)
    
end

-- 用户出牌
-- @param[curViewId]        当前出牌视图id
-- @param[lastViewId]       上局出牌视图id
-- @param[lastOutCards]     上局出牌
-- @param[bRenter]          是否断线重连
function GameViewLayer:onGetOutCard(curViewId, lastViewId, lastOutCards, bReEnter)
   
end

--移除出牌
function GameViewLayer:removeOutCard( outViewId )
    print("remove out view id  : " .. outViewId)
    self.m_outCardsControl:removeChildByTag(outViewId)
end
--获取手牌数量
function GameViewLayer:getHandCardCount( ViewId )
    
    if ViewId ~=2 then
        return tonumber(self.m_tabCardCount[ViewId]:getString())
    end
    
end

-- 用户pass
-- @param[passViewId]       放弃视图id
function GameViewLayer:onGetPassCard( passViewId )
    
end

-- 游戏结束
function GameViewLayer:onGetGameConclude( rs )
    
end

function GameViewLayer:updateTruMessage( wType, szString)
    if self._laba ~=nil then
        self._laba:addTrugTxt(szString)
    end
end

function GameViewLayer:showWaitAni( isShow )
    
end
------------------------------------------------------------------------------------------------------------
--更新
------------------------------------------------------------------------------------------------------------

return GameViewLayer