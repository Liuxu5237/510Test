--
-- Author: zhong
-- Date: 2016-07-07 18:09:11
--
--玩家列表

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local ClipText = appdf.req(appdf.EXTERNAL_SRC .. "ClipText")
local PopupInfoHead = appdf.req(appdf.EXTERNAL_SRC .. "PopupInfoHead")

local UserItem = appdf.req(appdf.GAME_SRC.."yule.oxbattle2.src.views.layer.UserItem")

local UserListLayer = class("UserListLayer", cc.Layer)
--UserListLayer.__index = UserListLayer
UserListLayer.BT_CLOSE = 1

function UserListLayer:ctor( )
	--用户列
	self.m_userlist = {}

	--加载csb资源
	local csbNode = ExternalFun.loadCSB("UserListLayer.csb", self)

	local sp_bg = csbNode:getChildByName("sp_userlist_bg")
	self.m_spBg = sp_bg
	local content = sp_bg:getChildByName("content")

	--用户列表
	local m_tableView = cc.TableView:create(content:getContentSize())
	m_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	m_tableView:setPosition(content:getPosition())
	m_tableView:setDelegate()
	m_tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	m_tableView:registerScriptHandler(self.cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
	m_tableView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
	m_tableView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	sp_bg:addChild(m_tableView)
	self.m_tableView = m_tableView
	content:removeFromParent()

	--关闭按钮
	local function btnEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			self:onButtonClickedEvent(sender:getTag(), sender);
		end
	end
	local btn = sp_bg:getChildByName("close_btn")
	btn:setTag(UserListLayer.BT_CLOSE)
	btn:addTouchEventListener(btnEvent)

	local layout_bg = csbNode:getChildByName("layout_bg")
	layout_bg:setTag(UserListLayer.BT_CLOSE)
	layout_bg:addTouchEventListener(btnEvent)

	--在线人数文本
	btn = self.m_spBg:getChildByName("zaixian")
	self.zaixian = btn
	self.zaixian:setTag(UserListLayer.BT_CLOSE)

	content:removeFromParent()
end

function UserListLayer:refreshList( userlist )
	--dump(userlist, "看看人员变动",10)
	self:setVisible(true)
	self.m_userlist = userlist
	self.m_tableView:reloadData()
	if self.zaixian then
		self.zaixian:setString(#userlist.."在线")
	end
end

--tableview
function UserListLayer.cellSizeForTable( view, idx )
	return UserItem.getSize()
end

function UserListLayer:numberOfCellsInTableView( view )
	if nil == self.m_userlist then
		return 0
	else
		return math.ceil(#self.m_userlist / 3)
	end
end

function UserListLayer:tableCellAtIndex( view, idx )
	local cell = view:dequeueCell()
	
	if nil == self.m_userlist then
		return cell
	end
    
    local useritem = {}
    local item = {}
    local name = {}
	useritem[1] = self.m_userlist[(idx+1)*3-2]
	useritem[2] = self.m_userlist[(idx+1)*3-1]
	useritem[3] = self.m_userlist[(idx+1)*3]
	item[1] = nil
	item[2] = nil
	item[3] = nil
	name = {"user_item1_view", "user_item2_view", "user_item3_view"}
	if cell == nil then    
		cell = cc.TableViewCell:new()
		for i = 1, 3 do
			if useritem[i] then   --如果cell为空，且对象存在，则创建并加入cell
				item[i] = UserItem:create()
				item[i]:setPosition(view:getViewSize().width * (0.2 + 0.3 * (i-1)), 100)
				item[i]:setName(name[i])
				cell:addChild(item[i])
			end
		end
	else
		for i = 1, 3 do
			if cell:getChildByName(name[i]) == nil then   
				if useritem[i] then    --如果cell不为空，i号为空，但对象存在，则创建并加入cell
					item[i] = UserItem:create()
					item[i]:setPosition(view:getViewSize().width * (0.2 + 0.3 * (i-1)), 100)
					item[i]:setName(name[i])
					cell:addChild(item[i])
				end
			else
				if useritem[i] then   --如果cell不为空，i号不为空，对象存在，则直接获取
					item[i] = cell:getChildByName(name[i])
				else   --如果cell不为空，i号不为空，对象不存在，则从cell中删除
					cell:removeChildByName(name[i])
				end
			end
		end
	end
    
    --对cell里面的item进行更新
    for i = 1, 3 do  
    	if nil ~= useritem[i] and nil ~= item[i] then
			item[i]:refresh(useritem[i], false, 0.5)
		end
	end

	return cell
end
--

function UserListLayer:onButtonClickedEvent( tag, sender )
	ExternalFun.playClickEffect()
	if UserListLayer.BT_CLOSE == tag then
		self:setVisible(false)
	end
end

return UserListLayer