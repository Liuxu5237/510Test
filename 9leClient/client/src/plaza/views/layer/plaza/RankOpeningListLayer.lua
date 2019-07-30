--排行榜列表
local RankOpeningListLayer = class("RankOpeningListLayer", function(size)
    return ccui.Layout:create():setContentSize(size)
end)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local HeadSprite = appdf.req(appdf.EXTERNAL_SRC .. "HeadSprite")

local ActivityIndicator = appdf.req(appdf.CLIENT_SRC .. "plaza.views.layer.general.ActivityIndicator")



function RankOpeningListLayer:ctor(list)
	
    --初始化变量
    self._listType = 0
    self._nickNameFontConfig = string.getConfig(appdf.DEF_FONT, 24)
    self._nickNameFontConfig.upperEnSize = 16
    --tableview 回调
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
    size = {width = 695,height = 530}
	self._tableView = cc.TableView:create(size)
	self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)    
    self._tableView:setAnchorPoint(cc.p(0, 0))
	self._tableView:setPosition(cc.p(0, 0))
	self._tableView:setDelegate()
	self._tableView:addTo(self)
	self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	self._tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
	self._tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)

    --活动指示器
    --[[self._activity = ActivityIndicator:create()
    self._activity:setPosition(size.width / 2, size.height / 2)
    self._activity:addTo(self)]]

    self:onUpdateRankingList(list)
end

--设置委托
function RankOpeningListLayer:setDelegate(delegate)

    self._delegate = delegate

    return self
end

--加载排行榜列表
function RankOpeningListLayer:loadRankingList(listType)
    
    self._listType = listType

    self._tableView:reloadData()
end

--------------------------------------------------------------------------------------------------------------------
-- 事件处理

--更新列表
function RankOpeningListLayer:onUpdateRankingList(list)  
    self._rankList = list
    self._tableView:reloadData()
end

--------------------------------------------------------------------------------------------------------------------
-- TableView 数据源

--子视图数量
function RankOpeningListLayer:numberOfCellsInTableView(view)
    --排名最后一个为我的排名故减1
    return self._rankList and (#self._rankList - 1) or 0
end

--子视图大小
function RankOpeningListLayer:cellSizeForTable(view, idx)

    return 692, 125
end

--获取子视图
function RankOpeningListLayer:tableCellAtIndex(view, idx)	
    
    --修正下标
    idx = idx + 1

    local cell = view:dequeueCell()
    if nil == cell then

        cell = cc.TableViewCell:create()

        --背景按钮
        local btnBg = ccui.Button:create("btn_rank_item_n.png", "btn_rank_item_s.png", "btn_rank_item_n.png", ccui.TextureResType.plistType)
            :setTag(1)
            :setAnchorPoint(0, 1)
            :setPosition(4, 120)
            :setSwallowTouches(false)
            :addTo(cell)
        
        --头像
        HeadSprite:createClipHead(nil, 96, "sp_avatar_mask_96.png")
            :setTag(2)
            :setPosition(200, 60)
            :addTo(btnBg)
        --名次
        ccui.TextAtlas:create()
            :setProperty("0","plaza/sp_rank_number.png",42,53,"0")
            :setTag(3)
            :setPosition(70,56)
            :setVisible(false)
            :addTo(btnBg)     
        --[[ccui.Text:create("", "fonts/round_body.ttf", 36)
            :setTag(3)
            :setPosition(75, 56)
            :setTextColor(cc.c3b(209, 104, 41))
            :enableOutline(cc.WHITE, 2)
            :enableShadow(cc.c3b(110, 100, 110), cc.size(2, -2))
            :setVisible(false)
            :addTo(btnBg)]]

        --奖牌
        cc.Sprite:create()
            :setTag(4)
            :setPosition(70, 56)
            :setVisible(false)
            :addTo(btnBg)

        --昵称
        ccui.Text:create("玩家昵称", "fonts/round_body.ttf", 25)
            :setTag(5)
            :setAnchorPoint(0, 0.5)
            :setPosition(335, 85)
            --:setTextColor(cc.c3b(185, 211, 255))
            :addTo(btnBg)
        --金币背景
        cc.Sprite:createWithSpriteFrameName("sp_rankgold_bg.png")
            :setAnchorPoint(0,0.5)
            :setPosition(335,40)
            :addTo(btnBg)
        --金币图标
         cc.Sprite:createWithSpriteFrameName("img_gold.png")
            :setAnchorPoint(0,0.5)
            :setPosition(330,38)
            :addTo(btnBg)
        --金币
        ccui.Text:create("0", "fonts/round_body.ttf", 30)
            :setTag(6)
            :setAnchorPoint(0, 0.5)
            :setPosition(380, 40)
            :setTextColor(cc.c3b(255,255,0))
            :addTo(btnBg)
    end

    --绑定下标
    cell:setTag(idx)

    local item = self._rankList[idx]
    local btnBg = cell:getChildByTag(1)
    local headSprite = btnBg:getChildByTag(2)
    local txtRank = btnBg:getChildByTag(3)
    local spMedal = btnBg:getChildByTag(4)
    local txtNickName = btnBg:getChildByTag(5)
    local txtGold = btnBg:getChildByTag(6)

    --排名
    if idx >= 1 and idx <= 3 then
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("sp_rank_order_%d.png", idx))
        spMedal:setSpriteFrame(frame)
        spMedal:setVisible(true)

        txtRank:setString("")
        txtRank:setVisible(false)
    else
        spMedal:setVisible(false)

        txtRank:setString(idx)
        txtRank:setVisible(true)
    end

    --头像
    headSprite:updateHead({ wFaceID = item.FaceID })

    --昵称
    txtNickName:setString(string.EllipsisByConfig(item.NickName, 200, self._nickNameFontConfig))
    txtNickName:setString(item.NickName)

    --金币
    txtGold:setString(ExternalFun.numberThousands(tonumber(item.RankScore)))

    return cell
end

--子视图点击
function RankOpeningListLayer:tableCellTouched(view, cell)  
    local index = cell:getTag()    
    print("点击="..index) 
    if self._delegate._delegate and self._delegate._delegate.onClickRankUserItem then
        local item = self._rankList[index]
        self._delegate._delegate:onClickRankUserItem(item)
    end
end
return RankOpeningListLayer