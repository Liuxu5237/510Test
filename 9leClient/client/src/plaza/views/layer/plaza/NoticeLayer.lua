--游戏公告
local NoticeLayer = class("NoticeLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")
local ActivityIndicator = appdf.req(appdf.CLIENT_SRC .. "plaza.views.layer.general.ActivityIndicator")
local WebFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.WebFrame")


local ZORDER = 
{
    WEBVIEW = 10,
    ACTIVITY = 10000,
}

function NoticeLayer:ctor()

    --默认选中项
    self._selectIndex = 0

    --初始列表
    self._list = {}

    local csbNode = ExternalFun.loadCSB("Notice/NoticeLayer.csb"):addTo(self)
    self._content = csbNode:getChildByName("content")

    --关闭
    local btnClose = self._content:getChildByName("btn_close")
    btnClose:addClickEventListener(function()
        
        --播放音效
        ExternalFun.playClickEffect()

        dismissPopupLayer(self)
    end)
    --公告内容容器
    self._noticeLayout = self._content:getChildByName("layou_notice")
    self._noticeLayout:setVisible(false)

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

    --公告列表
	self._tableView = cc.TableView:create(cc.size(235, 545))
	self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)    
    self._tableView:setAnchorPoint(cc.p(0, 0))
	self._tableView:setPosition(cc.p(26, 10))
	self._tableView:setDelegate()
	self._tableView:addTo(self._content)
	self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	self._tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
	self._tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    
    --活动指示器
    self._activity = ActivityIndicator:create()
    self._activity:setPosition(self._content:getContentSize().width / 2, self._content:getContentSize().height / 2)
    self._activity:addTo(self._content, ZORDER.ACTIVITY)

    --内容跳出
    AnimationHelper.jumpIn(self._content)

    --请求公告列表
    self:requestNoticeList()
end
--加载公告内容
function NoticeLayer:loadNoticeContent(index)
    if type(self._list) ~= "table" or #self._list == 0 then
        return
    end
    local noticelist = self._list[index]
    local _noticetitle = self._noticeLayout:getChildByName("txt_noticetitle")
    _noticetitle:setString(noticelist.Subject)
    local _noticedate = self._noticeLayout:getChildByName("txt_noticedate")
    _noticedate:setString(noticelist.IssueDate)
    local _noticecontent = self._noticeLayout:getChildByName("txt_noticecontent")
    _noticecontent:setString(noticelist.Body)
    self._noticeLayout:setVisible(true)
end

--------------------------------------------------------------------------------------------------------------------
-- TableView 数据源

--子视图数量
function NoticeLayer:numberOfCellsInTableView(view)
    
    return #self._list 
end

--子视图大小
function NoticeLayer:cellSizeForTable(view, idx)

    return 229, 92
end

--获取子视图
function NoticeLayer:tableCellAtIndex(view, idx)	
    
    local cell = view:dequeueCell()
    if nil == cell then

        cell = cc.TableViewCell:create()

        --背景
        cc.Sprite:create()
            :setAnchorPoint(0, 0)
            :setPosition(0, 0)
            :setTag(1)
            :addTo(cell)
        
        --类型
        ccui.Text:create("【公告】", "fonts/round_body.ttf", 22)
            :setAnchorPoint(cc.p(0,0.5))
            :setPosition(15, 65)
            :setTag(2)
            :addTo(cell)

        --标题
        ccui.Text:create("", "fonts/round_body.ttf", 17)
            :setAnchorPoint(cc.p(0,0.5))
            :setColor(cc.c3b(168, 236, 236))
            :setPosition(15, 30)
            :setTag(3)
            :addTo(cell)
    end

    cell.tag = idx

    local notice = self._list[idx + 1]

    --背景
    local bg = cell:getChildByTag(1)
    bg:setTexture(idx == self._selectIndex and "Notice/sp_item_bg_1.png" or "Notice/sp_item_bg_0.png")

    --标题
    local title = cell:getChildByTag(3)
    title:setString(notice.Subject)

    return cell
end

--子视图点击
function NoticeLayer:tableCellTouched(view, cell)
    
    local oldSelectIndex = self._selectIndex
    local index = cell.tag 

    if oldSelectIndex ~= index then

        self._selectIndex = index

        view:updateCellAtIndex(oldSelectIndex)
        view:updateCellAtIndex(index)

        --播放音效
        ExternalFun.playClickEffect()

        --加载页面
        self:loadNoticeContent(index + 1)
    end
end

--------------------------------------------------------------------------------------------------------------------
-- 网络请求

function NoticeLayer:webNoticeCallBack( result,message2 )
    local action2 = cjson.encode(message2)
    local message = cjson.decode(message2)
    if message[1] == 3 and message[2] == 103 then
        local jstable = message[3]

         --停止转圈
        self._activity:stop()

        --数据校验
        if type(jstable) ~= "table" then
            return
        end
        local list = jstable
        if type(list) ~= "table" or #list == 0 then
            return
        end
        --保存列表，加载第一页
        self._list = list
        self._tableView:reloadData()
        self:loadNoticeContent(1)

    end
end

--获取公告列表
function NoticeLayer:requestNoticeList()
    --yl.HTTP_SERVER_URL

    local webFrame = WebFrame:create(self, function(result, message)
        if self.webNoticeCallBack then
            self:webNoticeCallBack(result,message)
        end
    end)

    local action = {}
    action["tp"] = 26                 
    local pargams = {3,3,action}      
    local action2 = cjson.encode(pargams)       
    webFrame:wsSendString(action2) 

end

return NoticeLayer