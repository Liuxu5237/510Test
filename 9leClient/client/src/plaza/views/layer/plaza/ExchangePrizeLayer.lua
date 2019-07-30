--兑奖页面
local ExchangePrizeLayer = class("ExchangePrizeLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local HeadSprite = appdf.req(appdf.EXTERNAL_SRC .. "HeadSprite")

local ActivityIndicator = appdf.req(appdf.CLIENT_SRC .. "plaza.views.layer.general.ActivityIndicator")
local QueryDialog = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.QueryDialog")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")
local WebFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.WebFrame")


local ListType = 
{
    WXList = 1,
    GoldList = 2,
    RecodeList = 3
}

function ExchangePrizeLayer:ctor(delegate)
    self:setDelegate(delegate)
    local csbNode = ExternalFun.loadCSB("ExchangePrize/ExchangePrize.csb"):addTo(self)
    self._layout = csbNode:getChildByName("content")
    local btn_close = self._layout:getChildByName("btn_back")
    btn_close:setPosition(cc.p(btn_close:getPositionX()+15,btn_close:getPositionY()+5))
    btn_close:addClickEventListener(function()        
        --播放音效
        ExternalFun.playClickEffect()
        dismissPopupLayer(self)
    end)

    self.sp_process = self._layout:getChildByName("sp_process")
    self.sp_process:setVisible(false)

    local bt_closeprocess = self.sp_process:getChildByName("btn_close")
    bt_closeprocess:addClickEventListener(function()
        ExternalFun.playClickEffect()
        self.sp_process:setVisible(false)
        end)

    self._btnCheckred = self._layout:getChildByName("btn_checkred")
    self._btnCheckred:setVisible(false)
    self._btnCheckred:addClickEventListener(function()
        ExternalFun.playClickEffect()
        self.sp_process:setVisible(not self.sp_process:isVisible())
        end)
    --初始化分类按钮列表
    self._btnCategorys = {}
    self._layoutTableViews = {}
    self._recodeList = {}

    local pos1y = self._layout:getChildByName("btn_category_1"):getPositionY()
    local pos2y = self._layout:getChildByName("btn_category_2"):getPositionY()
    self._layout:getChildByName("btn_category_2"):setPositionY(pos1y)
    self._layout:getChildByName("btn_category_3"):setPositionY(pos2y)

    for i = 1,3 do
        local btnCategory = self._layout:getChildByName("btn_category_" .. i)
        btnCategory:addEventListener(function()           
            self:onClickCategory(i)
        end)
        self._btnCategorys[i] = btnCategory
        local layout = self._layout:getChildByName("layout_exchange_" .. i)
        self._layoutTableViews[i] = layout
        if i == ListType.RecodeList then
            self:InitPanel()
        end
        if i == ListType.WXList then
            btnCategory:setVisible(false)
            layout:setVisible(false)
        end
    end
   
    --活动指示器
    self._activity = ActivityIndicator:create()
    self._activity:setPosition(cc.p(500,280))
    self._activity:addTo(self._layout)
    self:onUpdateRedInfo()
    --self:requestExchangeInfoList(ListType.WXList)
    --self:onClickCategory(ListType.WXList)
    self:onClickCategory(ListType.GoldList)
end

--更新红包信息
function ExchangePrizeLayer:onUpdateRedInfo()
    local txtBean = self._layout:getChildByName("sp_red_info"):getChildByName("txt_red")
    local str = GlobalUserItem.dUserBeans
    str = string.format("%.2f", tonumber(str))
    --str = string.gsub(str,"[.]",";")
    txtBean:setString(str)
end

--设置委托
function ExchangePrizeLayer:setDelegate(delegate)

    self._delegate = delegate
    return self
end

--加载奖励列表
function ExchangePrizeLayer:updatePrizeList(listType)
    --判断是否为当前列表
    if self._listType ~= listType then
        return
    end
    self._layoutTableViews[listType]:removeAllChildren()

    local marginX       = 0  --X边距
    local marginY       = 0  --Y边距
    local spaceX        = 30  --X间距
    local spaceY        = 25  --Y间距
    
    local listCount     = self:getListCount(listType)
    local colCount      = 4
    local lineCount     = math.ceil(listCount / colCount)
    local itemSize      = cc.size(244, 305)
    local contentSize   = self._layoutTableViews[listType]:getContentSize()
    local containerWidth    = contentSize.width
    local containerHeight = contentSize.height
    
    --创建列表
    for i = 0, listCount - 1 do        
        local row   = math.floor(i / colCount)
        local col   = i % colCount
        local x     =(marginX + itemSize.width / 2 + col *(spaceX + itemSize.width))
        local y     = containerHeight -(marginY + itemSize.height / 2 + row *(spaceY + itemSize.height))
        local item  = self:getListItem(listType, i + 1)
        item:setPosition(x, y)
        item:addTo(self._layoutTableViews[listType])
    end
end

function ExchangePrizeLayer:getListItem(listType, index)
    
    local itemInfo = {}
    if listType == ListType.WXList then
        itemInfo = GlobalUserItem.tabExchangeCache.ExchangeWXList[index]
    elseif listType == ListType.GoldList then
        itemInfo = GlobalUserItem.tabExchangeCache.ExchangeGoldList[index]
    end

    local itemId = itemInfo.ID      --道具ID
    local itemPrice = itemInfo.JG   --道具价格
    local itemName = itemInfo.Name  --道具名称
    local itemCount = itemInfo.SL   --道具数量
    local itemType = itemInfo.Type  --道具类型

    local item = ccui.Button:create("ExchangePrize/sp_item_bg.png")
    local itemSize = item:getContentSize()
    item:addClickEventListener(function()       
        self:onClickExchange(itemType,itemPrice,itemId)
    end)
    local icon_str = ""
    if listType == ListType.WXList then
        icon_str = "ExchangePrize/sp_red_1.png"
    else
        if index > 4 then
            index = 4
        end
        icon_str = "ExchangePrize/sp_gold_"..index..".png"
    end
    
    --商品图标
    local iconItem = cc.Sprite:create(icon_str)
    iconItem:setPosition(itemSize.width / 2, 190)
    iconItem:addTo(item)

    --商品名称
    local txtItemName = cc.Label:createWithTTF(itemName, "fonts/round_body.ttf", 26)
    txtItemName:setAnchorPoint(0.5, 0.5)
    txtItemName:setPosition(itemSize.width / 2, itemSize.height-30)
    txtItemName:addTo(item)
    
    --商品数量
    local txtItemCount = cc.Label:createWithTTF("剩余:"..itemCount, "fonts/round_body.ttf", 20)
    txtItemCount:setAnchorPoint(0.5, 0.5)
    txtItemCount:setPosition(itemSize.width / 2, 90)
    txtItemCount:setTextColor(cc.c3b(255,255,255))
    txtItemCount:addTo(item)
    
    --价格按钮
    local btnPrice = cc.Sprite:create("ExchangePrize/btn_exchange_item.png")
    btnPrice:setPosition(itemSize.width / 2, 49/2+5)
    btnPrice:addTo(item)

    local txtPrice = cc.LabelAtlas:_create(itemPrice, "ExchangePrize/sp_number_1.png", 17, 24, string.byte("0"))
    txtPrice:setAnchorPoint(0.5, 0.5)
    txtPrice:setPosition(95, 28)
    txtPrice:addTo(btnPrice)
    
    --兑换类型显示游戏豆图标
    local str_iconpath = "ExchangePrize/icon_red.png"

    --价格按钮图标
    local iconPrice = cc.Sprite:create(str_iconpath)
    iconPrice:addTo(btnPrice)
    
    local priceBtnWidth = btnPrice:getContentSize().width
    local priceTextWidth = txtPrice:getContentSize().width
    local priceIconWidth = iconPrice:getContentSize().width
        
    --调整位置
    local iconX =(priceBtnWidth - priceIconWidth - priceTextWidth - 4) / 2 + priceIconWidth / 2
    iconPrice:setPosition(iconX, 25)
    txtPrice:setPosition(iconX + priceIconWidth / 2 + priceTextWidth / 2 + 4, 25)
       
    return item
end

function ExchangePrizeLayer:webClickExchangeCallBack( result,message2 ,Type) 
    local action2 = cjson.encode(message2)
    local message = cjson.decode(message2)
    if type(message) ~= "table" then
        return
    end
    self._activity:stop()
    dismissPopWait()

    if message["code"] == 212 then
        showToast(nil,"红包余额不足，请参与游戏赢现金红包！",2)
    elseif message["code"] == 211 then
        showToast(nil,"奖品数量不足，请联系客服!",2)
    elseif message["code"] == 1 then
        local jstable = message
        
        
        if Type == ListType.WXList then
            showToast(nil,"兑换成功",2)
        elseif Type == ListType.GoldList then
            showToast(nil,"兑换成功",2)
           
        end
       
        --列表更新
        self:requestExchangeInfoList(Type)

        local _webFrame = WebFrame:create(nil, function(result, message)
            if self.webClickExchangeCallBack then
                self:webClickExchangeCallBack(result,message)
            end
        end,true)
    
        local pargams = {6,20}
        local action = cjson.encode(pargams)
        dump(action)
        _webFrame:wsSendString(action) 

       
        --通知更新
        local eventListener = cc.EventCustom:new(yl.RY_USERINFO_NOTIFY)
        eventListener.obj = yl.RY_MSG_USERWEALTH
        cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)

    elseif  message[1] == 6 and message[2] == 120 then
		--查询金币
		local score = message[3]["Score"] or 0
        local Inscore = message[3]["InsureScore"] or 0
        local dwBeans = message[3]["Integral"] or 0

		GlobalUserItem.lUserScore = tonumber(score)
        GlobalUserItem.lUserInsure =tonumber(Inscore)
        GlobalUserItem.dUserBeans    = tonumber(dwBeans)
   
        --本地更新
        self:onUpdateRedInfo()
        
		local eventListener = cc.EventCustom:new(yl.RY_USERINFO_NOTIFY)
		eventListener.obj = yl.RY_MSG_USERWEALTH
		cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)

    end
end

function ExchangePrizeLayer:onClickExchange(Type,Price,PrizeId)

    self._activity:start()

    local webFrame = WebFrame:create(self, function(result, message)
        if self.webClickExchangeCallBack then
            self:webClickExchangeCallBack(result,message,Type)
        end
    end)

    local action = {}
    action["id"] = PrizeId     
    action["num"]= 1           
    local pargams = {4,51,action}   

    local action2 = cjson.encode(pargams)       
    webFrame:wsSendString(action2) 



    -- local url = appdf.HTTP_URL.."/WS/CashPrizes.ashx"
    -- local infotable = {}
    -- local ostime = os.time()
    -- infotable["UserID"] = "" .. GlobalUserItem.dwUserID
    -- infotable["TimeStamp"] = "" .. ostime
    -- infotable["Sign"] = GlobalUserItem:getSignature(ostime)
    -- infotable["Type"] = Type
    -- infotable["JG"] = Price
    -- infotable["PrizeID"] = PrizeId
    -- local action = cjson.encode(infotable)
    -- action = appdf.encodeBase64(action)
    -- action = "param="..action
    -- self._activity:start()
    -- appdf.onHttpJsionTable(url ,"POST", action, function(jstable,jsdata)

    --     --对象已经销毁
    --     if not appdf.isObject(self) then
    --         return
    --     end
        -- self._activity:stop()
        -- if type(jstable) ~= "table" then
        --     return
        -- end
        -- local list = jstable
        -- if type(list.msg) == "string" then
        --     if list.msg ~= "success" then
        --         showToast(nil,list.data,2)
        --         return
        --     else
        --         if Type == ListType.WXList then
        --             --[[QueryDialog:create(list.data.."\n兑换码: "..list.DHM.."\n兑换码将保存到兑换记录,或点击确定复制",function(bReTry)
        --                 if bReTry == true then
        --                 MultiPlatform:getInstance():copyToClipboard(list.DHM)
        --                 showToast(nil, "已复制到剪贴板", 2)
        --                 end
        --             end)
        --             :addTo(self)]]
        --             showToast(nil,list.data,2)
        --         elseif Type == ListType.GoldList then
        --             showToast(nil,list.data,2)
        --             GlobalUserItem.lUserScore = list.Score
        --         end
        --         GlobalUserItem.dUserBeans = list.Currency
                               
        --         --本地更新
        --         self:onUpdateRedInfo()
        --         --列表更新
        --         self:requestExchangeInfoList(Type)
        --         --通知更新
        --         local eventListener = cc.EventCustom:new(yl.RY_USERINFO_NOTIFY)
        --         eventListener.obj = yl.RY_MSG_USERWEALTH
        --         cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
        --     end
        -- end
    -- end)
end

--获取列表数量
function ExchangePrizeLayer:getListCount(listType)
    if listType == ListType.WXList then
        return GlobalUserItem.tabExchangeCache.ExchangeWXList and #GlobalUserItem.tabExchangeCache.ExchangeWXList or 0
    elseif listType == ListType.GoldList then
        return GlobalUserItem.tabExchangeCache.ExchangeGoldList and #GlobalUserItem.tabExchangeCache.ExchangeGoldList or 0
    end
end
--------------------------------------------------------------------------------------------------------------------
-- 事件处理

--更新列表
function ExchangePrizeLayer:onUpdateRankingList(listType, list)

    if listType == self._listType then
        --self._recordLists[listType] = list
        --self._recordTableViews[listType]:reloadData()
        --self._rankList = list       
        --self._tableView:reloadData()
    end
end

--------------------------------------------------------------------------------------------------------------------
-- TableView 数据源

--子视图数量
function ExchangePrizeLayer:numberOfCellsInTableView(view)
    return self._recodeList and #self._recodeList or 0
end


--子视图大小
function ExchangePrizeLayer:cellSizeForTable(view, idx)

    return 1140, 55
end

--获取子视图
function ExchangePrizeLayer:tableCellAtIndex(view, idx)   
    
    --修正下标
    idx = idx + 1

    local cell = view:dequeueCell()
    if nil == cell then

        cell = cc.TableViewCell:create()

        for i = 1, 5 do
            ccui.Text:create("", "fonts/round_body.ttf", 21)
                     :setTag(i)
                     :setTextColor(cc.c3b(201, 216, 241))
                     :setPosition((i - 1) * 210 + 105,30)
                     :addTo(cell)
        end
        cc.Sprite:create("ExchangePrize/sp_record_linex.png")
            :setTag(6)
            :setPosition(525, 0)
            :addTo(cell)

        ccui.Button:create("ExchangePrize/btn_copy_id_n.png","")
            :setTag(7)
            :setPosition(1075, 30)
            :addTo(cell)
    end

    --绑定下标
    cell:setTag(idx)
    local tag = view:getTag()
    local item = self._recodeList[idx]
    local txttime = cell:getChildByTag(1)
    local txtname = cell:getChildByTag(2)
    local txtred = cell:getChildByTag(3)
    local txtcode = cell:getChildByTag(4)
    local txtmark = cell:getChildByTag(5)

    local btn_copy = cell:getChildByTag(7)
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    btn_copy:addClickEventListener(function()
            if cc.PLATFORM_OS_WINDOWS == targetPlatform then
                local str = ""..item.DHM
                WindowsCopy(str)
            else
                MultiPlatform:getInstance():copyToClipboard(item.DHM)
            end
            showToast(nil, "已复制到剪贴板", 2)
        end)

    txttime:setString(item.ChangeDate)
    txtname:setString(item.PrizeName)
    txtred:setString(item.SL)
    local strcode = item.DHM
    if strcode == "" then
        strcode = "--"
    end
    txtcode:setString(strcode)
    local strbz = item.BZ
    if strbz == "" then
        strbz = "--"
    end
    txtmark:setString(strbz)
    return cell
end

--子视图点击
function ExchangePrizeLayer:tableCellTouched(view, cell)    
    
end

--------------------------------------------------------------------------------------------------------------------
-- 网络请求

function ExchangePrizeLayer:webExchangeCallBack( result,message2 ,listType)

    local action2 = cjson.encode(message2)
    local message = cjson.decode(message2)

    self._activity:stop()

    local jstable = message
    if type(jstable) ~= "table" then
        return
    end

    local list = jstable
    dump(list)
    if listType == ListType.WXList then
        --保存
        GlobalUserItem.tabExchangeCache.ExchangeWXList = list
        --更新列表
        self:updatePrizeList(ListType.WXList)      
    elseif listType == ListType.GoldList then         
        --保存
        GlobalUserItem.tabExchangeCache.ExchangeGoldList = list
        --更新列表
        self:updatePrizeList(ListType.GoldList)          
    elseif listType == ListType.RecodeList then
        --保存
        self._recodeList = list
        self._tableView:reloadData()
    end

end
--请求兑换信息
function ExchangePrizeLayer:requestExchangeInfoList(listType)
    -- https://interface.5185931.com:7417/WS/PropShop.ashx?action=getprizes&type=2	
    -- -response-[{"ID":4,"Type":2,"Name":"5万金币","JG":5.00,"SL":64},{"ID":5,"Type":2,"Name":"11万金币","JG":10.00,"SL":97},{"ID":6,"Type":2,"Name":"60万金币","JG":50.00,"SL":100},{"ID":7,"Type":2,"Name":"135万金币","JG":100.00,"SL":100}]	   
     
    -- https://interface.5185931.com:7417/WS/PropShop.ashx?action=getprizes&type=1	
    -- -response-[{"ID":1,"Type":1,"Name":"10元红包","JG":10.00,"SL":42},{"ID":2,"Type":1,"Name":"50元红包","JG":50.00,"SL":10},{"ID":3,"Type":1,"Name":"100元红包","JG":100.00,"SL":5}]	
   
    --  https://interface.5185931.com:7417/WS/PropShop.ashx?action=getprizesrecord&userid=6367&signature=A4490C501370D90D2F730F1B614F538E&time=1525601526
    --  -response-[{"ChangeDate":"2018/5/6 18:10:35","PrizeName":"5万金币","SL":5.00,"DHM":"","BZ":"兑换成功"}]	

    --兑换
    -- https://interface.5185931.com:7417/WS/CashPrizes.ashx?param=eyJQcml6ZUlEIjo0LCJKRyI6NSwiVXNlcklEIjoiNjM2NyIsIlRpbWVTdGFtcCI6IjE1MjU2MDE0NjMiLCJTaWduIjoiNTA0QUREQkFGRTVEODRCQUYyOTExMTkzOUVBQTEwNTUiLCJUeXBlIjoyfQ==	
    -- -response-{"msg":"success","data":"兑换成功","Score":70068,"Currency":0.08}	
    self._activity:start()

    local webFrame = WebFrame:create(self, function(result, message)
        if self.webExchangeCallBack then
            self:webExchangeCallBack(result,message,listType)
        end
        
    end)

    local action = {}
    action["tp"] = listType                
    local pargams = {4,50,action}   
    if listType == ListType.RecodeList then
        pargams = {4,52}           
    end
    local action2 = cjson.encode(pargams)       
    webFrame:wsSendString(action2) 

end
function ExchangePrizeLayer:InitPanel()
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
    self._tableView = cc.TableView:create(cc.size(1140, 485))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)    
    self._tableView:setAnchorPoint(cc.p(0, 0))
    self._tableView:setPosition(cc.p(0, 45))
    self._tableView:setContentSize(1050, 485)
    self._tableView:setDelegate()
    self._tableView:addTo(self._layoutTableViews[3])
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    self._tableView:reloadData()
end
--点击分类按钮
function ExchangePrizeLayer:onClickCategory(index)
    --播放按钮音效
    ExternalFun.playClickEffect()

    for i = 1, 3 do
        self._btnCategorys[i]:setSelected(index == i)
        self._layoutTableViews[i]:setVisible(index == i)
    end
    self.sp_process:setVisible(false)
    --self._btnCheckred:setVisible(index ~= 3)
    --防止重复执行
    if index == self._listType then
        return
    end
    self._listType = index
    --获取兑换数据
    --微信兑换
    if index == ListType.WXList then
        --if GlobalUserItem.tabExchangeCache.ExchangeWXList == nil then
            self:requestExchangeInfoList(ListType.WXList)
            --return
        --end        
    --金币兑换
    elseif index == ListType.GoldList then       
        --if GlobalUserItem.tabExchangeCache.ExchangeGoldList == nil then
            self:requestExchangeInfoList(ListType.GoldList)
            --return
        --end       
    --兑换记录
    elseif index == ListType.RecodeList then
        self:requestExchangeInfoList(ListType.RecodeList)
        return 
    end
    --self:updatePrizeList(index)
end

return ExchangePrizeLayer