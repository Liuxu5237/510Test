--排行榜列表
local RankingLayer = class("RankingLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local HeadSprite = appdf.req(appdf.EXTERNAL_SRC .. "HeadSprite")
local ClipText = appdf.EXTERNAL_SRC .. "ClipText"
local g_var = ExternalFun.req_var
local WebFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.WebFrame")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")
local QueryDialog = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.QueryDialog")

local ActivityIndicator = appdf.req(appdf.CLIENT_SRC .. "plaza.views.layer.general.ActivityIndicator")

local ListType = 
{
    TodayRank = 1,
    TotalRank = 2
}

function RankingLayer:ctor(delegate)
    self:setDelegate(delegate)
    local csbNode = ExternalFun.loadCSB("Rank/Rank.csb"):addTo(self)
    self._layout = csbNode:getChildByName("sp_rank_bg")
    local btn_close = csbNode:getChildByName("btn_close")
    btn_close:addClickEventListener(function()        
        --播放音效
        ExternalFun.playClickEffect()
        dismissPopupLayer(self)
    end)

    --初始化分类按钮列表
    self._btnCategorys = {}
    --排行记录
    self._recordLists = {}
    self._recordTableViews = {}

    -- for i = 1,2 do
    --     local btnCategory = csbNode:getChildByName("btn_rank_" .. i)
    --     btnCategory:addEventListener(function()           
    --         self:onClickCategory(i)
    --     end)
    --     self._btnCategorys[i] = btnCategory
    --     self:InitPanel(i)
    -- end

    -- self._btnCategorys[1]:setVisible(false)
    self:InitPanel(ListType.TotalRank)

    --游戏币
    local txtGold = csbNode:getChildByName("sp_gold_bg"):getChildByName("txt_gold")
    
    local str = ExternalFun.numberThousands(GlobalUserItem.lUserScore)
    str = string.gsub(str,",",":")
    txtGold:setString(str)
    local txtwith = txtGold:getContentSize().width
    local txtlen = string.len(str)
    if txtlen >= 11 then
        txtGold:setScale(170 / txtwith)
    end

    --信息面板
    self._userInfo = csbNode:getChildByName("sp_rank_userinfo"):setVisible(false):setScale(0)
    self._userInfo:getChildByName("btn_infoclose")
    :addClickEventListener(function()
        self._userInfo:runAction(cc.Sequence:create(cc.ScaleTo:create(0.15, 0), cc.CallFunc:create(function()
            self._userInfo:setVisible(false)
            end)))
        
        end)



    --初始化变量
    self._listType = 0
    self._nickNameFontConfig = string.getConfig(appdf.DEF_FONT, 24)
    self._nickNameFontConfig.upperEnSize = 16

    self._signFontConfig = string.getConfig(appdf.DEF_FONT, 20)
    self._signFontConfig.upperEnSize = 20
    
    --活动指示器
    self._activity = ActivityIndicator:create()
    self._activity:setPosition(cc.p(500,280))
    self._activity:addTo(self._layout)

    self:loadRankingList(ListType.TotalRank)
end

--设置委托
function RankingLayer:setDelegate(delegate)

    self._delegate = delegate

    return self
end

--加载排行榜列表
function RankingLayer:loadRankingList(listType)
    
    self._listType = listType
    --self._rankList = GlobalUserItem.tabRankCache[listType]

    --if self._rankList == nil then
    self:requestRankList(listType)
    --end
end

--------------------------------------------------------------------------------------------------------------------
-- 事件处理

--更新列表
function RankingLayer:onUpdateRankingList(listType, list)

    if listType == self._listType then
        self._recordLists[listType] = list
        self._recordTableViews[listType]:reloadData()
        --self._rankList = list       
        --self._tableView:reloadData()
    end
end

--------------------------------------------------------------------------------------------------------------------
-- TableView 数据源

--子视图数量
function RankingLayer:numberOfCellsInTableView(view)
    
    local tag = view:getTag()
    
    if self._recordLists[tag] == nil then
        return 0
    end
    return #self._recordLists[tag]
    
    --return self._rankList and (#self._rankList - 1) or 0
end

--子视图大小
function RankingLayer:cellSizeForTable(view, idx)

    return 900, 77
end

--获取子视图
function RankingLayer:tableCellAtIndex(view, idx)   
    
    --修正下标
    idx = idx + 1

    local cell = view:dequeueCell()
    if nil == cell then

        cell = cc.TableViewCell:create()

        --背景按钮
        local btnBg = ccui.Button:create("Rank/btn_rank_item_n.png", "Rank/btn_rank_item_n.png", "Rank/btn_rank_item_n.png")
            :setTag(1)
            :setAnchorPoint(0, 1)
            :setPosition(3, 78)
            :setSwallowTouches(false)
            :addTo(cell)
        
        --头像
        HeadSprite:createClipHead(nil, 65, "sp_avatar_mask_73.png")
            :setTag(2)
            :setPosition(127, 38)
            :addTo(btnBg)
        --名次
        ccui.TextAtlas:create()
            :setProperty("0","Rank/sp_rank_number.png",27,43,"0")
            :setTag(3)
            :setPosition(45,35)
            :setVisible(false)
            :addTo(btnBg)     
        --名次
        --[[ccui.Text:create("", "fonts/round_body.ttf", 36)
            :setTag(3)
            :setPosition(26, 70)
            :setTextColor(cc.c3b(209, 104, 41))
            :enableOutline(cc.WHITE, 2)
            :enableShadow(cc.c3b(110, 100, 110), cc.size(2, -2))
            :setVisible(false)
            :addTo(btnBg)]]

        --奖牌
        cc.Sprite:create()
            :setTag(4)
            :setPosition(45, 38)
            :setVisible(false)
            :addTo(btnBg)

        --昵称
        ccui.Text:create("玩家昵称", "fonts/round_body.ttf", 24)
            :setTag(5)
            :setAnchorPoint(0, 0.5)
            :setPosition(170, 55)
            :addTo(btnBg)

        --金币图标
         cc.Sprite:createWithSpriteFrameName("img_gold.png")
            :setAnchorPoint(0,0.5)
            :setPosition(590,35)
            :addTo(btnBg)

        --金币
        ccui.Text:create("0", "fonts/round_body.ttf", 26)
            :setTag(6)
            :setAnchorPoint(0, 0.5)
            :setPosition(630, 35)
            :setTextColor(cc.c3b(234, 200, 47))            
            :addTo(btnBg)

        --签名
        ccui.Text:create("个人签名", "fonts/round_body.ttf", 18)
        :setTag(7)
        :setAnchorPoint(0, 0.5)
        :setPosition(170, 18)
        :setTextColor(cc.c3b(255,196,93))
        :addTo(btnBg)

        --新版logo
        -- cc.Sprite:create()
        -- :setTag(8)
        -- :setScale(0.8)
        -- :setPosition(490, 35)
        -- :setVisible(false)
        -- :addTo(btnBg)
        cc.Sprite:create()
        :setTag(9)
        --:setScale(0.8)
        :setPosition(127, 38)
        :setVisible(false)
        :addTo(btnBg)
    end

    --绑定下标
    cell:setTag(idx)
    local tag = view:getTag()
    local item = self._recordLists[tag][idx]
    local btnBg = cell:getChildByTag(1)
    local headSprite = btnBg:getChildByTag(2)
    local txtRank = btnBg:getChildByTag(3)
    local spMedal = btnBg:getChildByTag(4)
    local txtNickName = btnBg:getChildByTag(5)
    local txtGold = btnBg:getChildByTag(6)
    local txtSign = btnBg:getChildByTag(7)
    local newlogo = btnBg:getChildByTag(8)
    local headBg = btnBg:getChildByTag(9)

    --[[local scaling = 0.38
    if self._listExpansion then  
        scaling = 1
    end
    txtNickName:setVisible(self._listExpansion)
    txtGold:setVisible(self._listExpansion)
    --btnBg:setScaleX(scaling)]]

    --排名
    if idx >= 1 and idx <= 3 then
        --local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("sp_rank_medal_%d.png", idx))
        local str = string.format("Rank/sp_rank_order_%d.png", idx)
        spMedal:setTexture(str)
        spMedal:setVisible(true)

        txtRank:setString("")
        txtRank:setVisible(false)

        -- local str_1 = string.format( "Rank/%02d.png",idx )
        -- newlogo:setTexture(str_1)
        -- newlogo:setVisible(true)

        local str_2 = string.format( "Rank/headborder_%d.png",idx )
        headBg:setTexture(str_2)
        headBg:setVisible(true)
        --昵称
        txtNickName:setTextColor(cc.c3b(255, 0, 0))

    else
        txtNickName:setTextColor(cc.c3b(255,255,255))        
        spMedal:setVisible(false)
        --newlogo:setVisible(false)
        headBg:setVisible(false)

        txtRank:setString(idx)
        txtRank:setVisible(true)
    end

    --头像
    headSprite:updateHead({ wFaceID = item[5] })

    --昵称
    txtNickName:setString(string.EllipsisByConfig(item[4], 200, self._nickNameFontConfig))
    txtNickName:setString(item[4])

    --金币
    txtGold:setString(ExternalFun.numberThousands(tonumber(item[6])))
    
    --字符串全提出来
    local signstrtable = ExternalFun.utf8StringSplit(item[7])
    local signstr = ""
    local signlen = 1
    for i = 1, #signstrtable do
        if signlen >= 40 then
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
    --print(signlen)
    if signlen >= 40 then
        signstr = signstr.."..."
    end
    --print(signstr)
    --签名
    --local signstr = SubUTF8String(item.UnderWrite,40)
    --print(signstr)
    txtSign:setString(signstr)

    if idx >= 1 and idx <= 3 then
        txtSign:setString(string.EllipsisByConfig(signstr, 260, self._signFontConfig))
    else
        txtSign:setString(string.EllipsisByConfig(signstr, 450, self._signFontConfig))
    end

    return cell
end

--子视图点击
function RankingLayer:tableCellTouched(view, cell)
    
    local index = cell:getTag()     
    if self._delegate and self._delegate.onClickRankUserItem then
        local item =  self._recordLists[self._listType][index]
        self:onClickRankUserInfo(item)
    end
end


function RankingLayer:onClickRankUserInfo(userItem)
    local head = self._userInfo:getChildByName("img_head")
    if head then
        head:removeFromParent()
    end
    local headSprite = HeadSprite:createClipHead({ wFaceID = userItem[5] or userItem[5] }, 120, "sp_avatar_mask_120.png")
    headSprite:setPosition(186,483)
    headSprite:addTo(self._userInfo)
    headSprite:setName("img_head")

    local nickname = self._userInfo:getChildByName("txt_nickName")--:setString(userItem.NickName)
    local signstrtable = ExternalFun.utf8StringSplit(userItem[4])
    local signstr = ""
    local signlen = 1
    for i = 1, #signstrtable do
        if signlen >= 12 then
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
    --print(signlen)
    if signlen >= 12 then
        signstr = signstr.."..."
    end
    nickname:setString(signstr)

    local Gameid = self._userInfo:getChildByName("txt_gameid"):setString("（ID："..tostring(userItem[2]).."）")

    local sex = self._userInfo:getChildByName("sp_sex")
    sex:setPositionX(Gameid:getPositionX() + Gameid:getContentSize().width + 27)
    if userItem[3] == 0 then
        sex:setTexture("Rank/sp_girl.png")
    else
        sex:setTexture("Rank/sp_boy.png")
    end

    self._userInfo:getChildByName("txt_underwrite")
    :ignoreContentAdaptWithSize(false)
    :setSize(cc.size(250, 84)) 
    :setString(userItem[7])

    local txtGold = self._userInfo:getChildByName("txt_gold")
    
    local str = ExternalFun.numberThousands(userItem[6])
    str = string.gsub(str,",",":")
    txtGold:setString(str)
    local txtwith = txtGold:getContentSize().width
    local txtlen = string.len(str)
    if txtlen >= 11 then
        txtGold:setScale(185 / txtwith)
    end
    self._userInfo:setVisible(true)
    self._userInfo:runAction(cc.Sequence:create(cc.ScaleTo:create(0.15, 1)))
    
    local btn_openwx = self._userInfo:getChildByName("Button_1")

    if userItem[8] ~= "" then
        local lab_wx = string.sub(userItem[8],string.find(userItem[8],":")+1,string.len(userItem[8]))
        btn_openwx:addClickEventListener(function ( )
            -- MultiPlatform:getInstance():copyToClipboard(lab_wx)
            -- --showToast(nil,"成功复制微信【xxxxxx】到剪贴板，打开微信中",3)
            -- self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(function ( )
            -- MultiPlatform:getInstance():openWX()
            -- end)))
            self:onclickOpenWx(lab_wx)
            
        end)
    else
        btn_openwx:addClickEventListener(function ( )
          
        end)
    end
    
    --dump(userItem)
end

function RankingLayer:onclickOpenWx(  lab_wx )
    if self._dialog then
        return
    end
    self._dialog = QueryDialog:create("微信号["..lab_wx.."]已复制，是否打开微信",function(bReTry)
                if bReTry == true then
                    MultiPlatform:getInstance():copyToClipboard(lab_wx)
                    self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(function ( )
                        MultiPlatform:getInstance():openWX()
                        self._dialog = nil
                    end)))
                else
                    self._dialog = nil
                end
            end)
        :setCanTouchOutside(false)
        :addTo(self)

end
--------------------------------------------------------------------------------------------------------------------
-- 网络请求

function RankingLayer:RankCallBack( result,message2 )
    print("RankCallBack" .. result)
    print(message2)
    local action2 = cjson.encode(message2)
    local message = cjson.decode(message2)
    self._activity:stop()
    if message[1] == 3 and message[2] == 101 then
        local jstable = message[3]
        table.sort(jstable,function ( x,y )
            return tonumber(x[1]) < tonumber(y[1])
        end)
        local tempList = {}
        for i = 1, #jstable do
            local item = jstable[i]
    
            if item[7] == nil or item[7] == "" then
                item[7] = "这个家伙很懒，什么都没留下"
            end
            table.insert(tempList, item)
        end
       
        GlobalUserItem.tabRankCache[2] = tempList
    
        self:onUpdateRankingList(2, tempList)
    end
   
    
end

--请求排行榜
function RankingLayer:requestRankList(listType)

    local actions = { "getwinscorerank","getscorerank" }

    self._activity:start()

    local action = {}
    action["TaskID"] =10000
    local pargams = {3,1,action}
    local action2 = cjson.encode(pargams)

    self._webFrame = WebFrame:create(self, function(result, message)
        if self.RankCallBack then
            self:RankCallBack(result,message)            
        end
    end)
    
    self._webFrame:wsSendString(action2) 

    -- appdf.onHttpJsionTable(yl.HTTP_URL .. "/WS/PhoneRank.ashx","GET","action="..actions[listType].."&pageindex=1&pagesize=30&userid="..GlobalUserItem.dwUserID,function(jstable,jsdata)

    --     --对象已经销毁
    --     if not appdf.isObject(self) then
    --         return
    --     end

    --     self._activity:stop()

    --     if type(jstable) ~= "table" then
    --         return
    --     end

    --     local tempList = {}
    --     for i = 1, #jstable do
    --         local item = jstable[i]

    --         if item.UnderWrite == nil or item.UnderWrite == "" then
    --             item.UnderWrite = "这个家伙很懒，什么都没留下"
    --         end
    --         table.insert(tempList, item)
    --     end

    --     GlobalUserItem.tabRankCache[listType] = tempList

    --     self:onUpdateRankingList(listType, tempList)
    -- end)
end
function RankingLayer:InitPanel(index)
    local numberOfCellsInTableView = function(view)
        return self:numberOfCellsInTableView(view)
    end
    local cellSizeForTable = function(view, idx)
        return self:cellSizeForTable(view, idx)
    end
    local tableCellAtIndex = function(view, idx)    
        return self:tableCellAtIndex(view, idx)
    end
    local tableCellTouched = function(view, cell)
        return self:tableCellTouched(view, cell)
    end

    --排行列表
    local tableView = cc.TableView:create(cc.size(905, 605))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)    
    tableView:setAnchorPoint(cc.p(0, 0))
    tableView:setPosition(cc.p(8, 45))
    tableView:setContentSize(905, 605)
    tableView:setDelegate()
    tableView:addTo(self._layout)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)

    tableView:reloadData()

    -- --tips
    -- local tip_icon = cc.Sprite:create("Bank/icon.png")
    -- tip_icon:setPosition(cc.p(650,22))
    -- tip_icon:addTo(self._layout)

    -- local tip_lable = cc.Label:createWithTTF("【温馨提示】排行榜仅限v5会员上榜","fonts/round_body.ttf",20)
    -- tip_lable:setAnchorPoint(cc.p(0,0.5))
    -- tip_lable:setPosition(cc.p(665,22))
    -- tip_lable:setTextColor(cc.c3b(142, 208, 245))
    -- tip_lable:addTo(self._layout)

    --保存
    if index == ListType.TodayRank then
        tableView:setTag(ListType.TodayRank)
        self._recordTableViews[ListType.TodayRank] = tableView
    elseif index == ListType.TotalRank then
        tableView:setTag(ListType.TotalRank)
        self._recordTableViews[ListType.TotalRank] = tableView
    end
end
--点击分类按钮
function RankingLayer:onClickCategory(index)
    --播放按钮音效
    ExternalFun.playClickEffect()

    for i = 1, 2 do
        self._btnCategorys[i]:setSelected(index == i)
        self._recordTableViews[i]:setVisible(index == i)
    end
    --获取排行记录
    if index == ListType.TodayRank then
        self:loadRankingList(ListType.TodayRank)
    elseif index == ListType.TotalRank then
        self:loadRankingList(ListType.TotalRank)
    end
end

return RankingLayer